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

/// Class 7 Science • Chapter 5 • Activity 3
/// Combustion: Conditions and Products.
///
/// Native Flutter port of `Cl7S-Ch5-A3-Combustion__Conditions_and_Products.html`.
///
/// Scenario 1 (The Oxygen Requirement): drag two candles onto petri dishes,
/// drag the matchbox to the centre and click it for a lit match, light both
/// candles, cover the right one with a glass tumbler, Fast Forward (it goes
/// out, smoke), then test its dish with lime water (turns milky = CO₂).
///
/// Scenario 2 (The Ignition Temperature Requirement): a magnifying glass on
/// a cloudy day gives "not enough heat"; Make Sunny, focus the sun's rays
/// (light cones, thermometer rising to the ignition temperature), the paper
/// chars, smokes and burns; a lit match then ignites new paper instantly.
/// Each scenario ends with the Fire Triangle and the key observation.
class Ch5A3CombustionConditionsAndProductsPage extends StatefulWidget {
  const Ch5A3CombustionConditionsAndProductsPage({super.key});

  @override
  State<Ch5A3CombustionConditionsAndProductsPage> createState() =>
      _Ch5A3CombustionConditionsAndProductsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, splash 1311, fire 1348,
/// magic 871, whoosh 1492.
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
  splash('splash.mp3'),
  fire('fire.mp3'),
  magic('magic.mp3'),
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
  static const Color red600 = Color(0xFFDC2626);
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

/// Pan recognizer that only joins the arena for touches starting on a
/// draggable object (so empty-canvas drags still pan the zoomed canvas).
class _ObjectDragRecognizer extends PanGestureRecognizer {
  _ObjectDragRecognizer({required this.accept});

  bool Function(Offset local) accept;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && accept(event.localPosition);
}

double _distToSeg(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-6) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

enum _HudType { info, success, error }

class _Ch5A3CombustionConditionsAndProductsPageState
    extends State<Ch5A3CombustionConditionsAndProductsPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// HTML `currentStepId` (1-based).
  int _step = 1;

  /// HTML `isTaskActive` / `interactiveMeshes`.
  bool _taskActive = false;
  final List<_Item> _interactive = [];

  /// HUD message key ('' = the current step's task) and style.
  String _hudKey = '';
  _HudType _hudType = _HudType.info;

  bool _ffVisible = false; // Fast Forward (HUD action area)
  bool _sunnyVisible = false; // Make Sunny (weather controls)
  bool _thermoVisible = false;
  double _thermo = 0; // mercury height, 0..1

  // Drag state.
  _Item? _drag;
  double _grabDx = 0, _grabDz = 0;

  int get _scenario => _scene.scenario;

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

    _loadScenario(0);
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
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _scene.time = elapsed.inMicroseconds / 1e6;
    _scene.tickAnims();
    _frame.value = _scene.time;
  }

  // ------------------------------------------------------------ tweens

  void _tweenV3(_V3 Function() get, void Function(_V3) set, _V3 to, double ms,
      {Curve curve = Curves.linear, double delayMs = 0, VoidCallback? done, Object? tag}) {
    _scene.animate(ms, () {
      final from = get();
      return (t) => set(_V3.lerp(from, to, t));
    }, curve: curve, delayMs: delayMs, done: done, tag: tag);
  }

  void _tweenD(double Function() get, void Function(double) set, double to, double ms,
      {Curve curve = Curves.linear, double delayMs = 0, VoidCallback? done, Object? tag}) {
    _scene.animate(ms, () {
      final from = get();
      return (t) => set(from + (to - from) * t);
    }, curve: curve, delayMs: delayMs, done: done, tag: tag);
  }

  /// HTML `TWEEN(obj.position).to({x: startPos.x, z: startPos.z}, 300)`.
  void _returnToStart(_Item it) {
    final s = it.startPos;
    _tweenV3(() => it.pos, (v) => it.pos = v, _V3(s.x, it.pos.y, s.z), 300, tag: it);
  }

  void _setHud(String key, _HudType type) => setState(() {
        _hudKey = key;
        _hudType = type;
      });

  void _ok() => _Audio.play(_Sound.correct);
  void _err() => _Audio.play(_Sound.wrong);

  // ------------------------------------------------------------- scenes

  /// HTML `loadScenario(id)` (clearScene + scenario.init + loadStep(1)).
  void _loadScenario(int index) {
    _lab.cancelPending();
    _scene
      ..clear()
      ..scenario = index;
    _interactive.clear();
    _drag = null;
    _ffVisible = false;
    _sunnyVisible = false;
    _thermoVisible = false;
    _thermo = 0;
    if (index == 0) {
      _scene
        ..dish1 = _Dish(const _V3(-1.5, 0, 0))
        ..dish2 = _Dish(const _V3(1.5, 0, 0))
        ..light = 1;
    } else {
      // Cloudy sky, dim key light (0.4) and ambient (0.5).
      _scene
        ..sunny = 0
        ..light = 0.72;
    }
    _loadStep(1);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _loadScenario(index);
    });
  }

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `loadStep(stepId)`.
  void _loadStep(int n) {
    if (!mounted) return;
    setState(() {
      _step = n;
      _taskActive = false;
      _hudKey = '';
      _hudType = _HudType.info;
    });
    if (_scenario == 0) {
      _setupS1(n);
    } else {
      _setupS2(n);
    }
  }

  void _activate(List<_Item> items) {
    _interactive
      ..clear()
      ..addAll(items);
    _taskActive = true;
  }

  void _setupS1(int n) {
    final sc = _scene;
    switch (n) {
      case 1:
        sc.candle1 = _Item(_Kind.candle, const _V3(-1, 0.1, 3))..draggable = true;
        sc.candle2 = _Item(_Kind.candle, const _V3(1, 0.1, 3))..draggable = true;
        _activate([sc.candle1!, sc.candle2!]);
      case 2:
        sc.matchbox = _Item(_Kind.matchbox, const _V3(0, 0.175, 3))..draggable = true;
        _activate([sc.matchbox!]);
      case 3:
        sc.tumbler = _Item(_Kind.tumbler, const _V3(0, 0.1, 3))..draggable = true;
        _activate([sc.tumbler!]);
      case 4:
        setState(() => _ffVisible = true);
      case 5:
        setState(() => _ffVisible = false);
        sc.bottle = _Item(_Kind.bottle, const _V3(-1.5, 0.4, 3));
        sc.dropper = _Item(_Kind.dropper, const _V3(-0.8, 0.3, 3))..draggable = true;
        final t = sc.tumbler!;
        _tweenD(() => t.pos.y, (v) => t.pos = t.pos.withY(v), 1.6, 500);
        _activate([sc.dropper!]);
      case 6:
        _conclusion(oxygen: true);
    }
  }

  void _setupS2(int n) {
    final sc = _scene;
    switch (n) {
      case 1:
        sc
          ..paper = true
          ..paperScale = 1
          ..burn = 0;
        sc.magnifier = _Item(_Kind.magnifier, const _V3(-1.5, 0.4, 3))..draggable = true;
        _activate([sc.magnifier!]);
      case 2:
        final m = sc.magnifier!;
        _tweenV3(() => m.pos, (v) => m.pos = v, const _V3(-1.5, 0.4, 3), 800);
        setState(() => _sunnyVisible = true);
      case 3:
        sc.magnifier!.draggable = true;
        _activate([sc.magnifier!]);
      case 4:
        _tweenD(() => _thermo, (v) => _thermo = v, 0.8, 4000, done: _ignition);
      case 5:
        sc
          ..paperScale = 1
          ..burn = 0
          ..matchbox = (_Item(_Kind.matchbox, const _V3(2.5, 0.075, 1.5)))
          ..match = (_Item(_Kind.match, const _V3(2.0, 0.5, 2.0))..draggable = true);
        _activate([sc.match!]);
        _setHud('msg_drag_match', _HudType.info);
      case 6:
        _conclusion(oxygen: false);
    }
  }

  // ------------------------------------------------------- interactions

  /// HTML `stepData.interact(obj, action)`.
  void _interact(_Item it, String action) {
    if (_scenario == 0) {
      _interactS1(it, action);
    } else {
      _interactS2(it, action);
    }
    if (mounted) setState(() {});
  }

  void _interactS1(_Item it, String action) {
    final sc = _scene;
    switch (_step) {
      case 1:
        if (action != 'drop' || !it.draggable) return;
        final target = it == sc.candle1 ? sc.dish1! : sc.dish2!;
        if (it.pos.dist(target.pos) < 2.0) {
          it
            ..pos = _V3(target.pos.x, 0.05, target.pos.z)
            ..draggable = false
            ..placed = true;
          _ok();
          if (sc.candle1!.placed && sc.candle2!.placed) {
            _setHud('msg_both_placed', _HudType.success);
            _interactive.clear();
            _lab.after(const Duration(milliseconds: 1500), () => _loadStep(2));
          }
        } else {
          _returnToStart(it);
          _err();
        }
      case 2:
        final c1 = sc.candle1!, c2 = sc.candle2!;
        if (it == sc.matchbox) {
          if (action == 'drop' && it.state == 'initial') {
            if (it.pos.dist(const _V3(0, 0, 1)) < 2.0) {
              it
                ..pos = const _V3(0, 0.075, 1)
                ..draggable = false
                ..clickable = true
                ..state = 'center';
              _ok();
            } else {
              _returnToStart(it);
              _err();
            }
          } else if (action == 'click' && it.state == 'center') {
            it
              ..clickable = false
              ..state = 'match_out';
            sc.match = _Item(_Kind.match, const _V3(0, 0.5, 1))..draggable = true;
            _interactive.add(sc.match!);
            _ok();
            _Audio.play(_Sound.fire, volume: 0.35);
          }
        } else if (it == sc.match && action == 'drop') {
          if (!c1.lit && it.pos.dist(c1.pos) < 1.5) {
            _lightCandle(c1);
            _ok();
            _tweenV3(() => it.pos, (v) => it.pos = v, const _V3(0, 0.5, 1), 300, tag: it);
          } else if (c1.lit && !c2.lit && it.pos.dist(c2.pos) < 1.5) {
            _lightCandle(c2);
            _ok();
            sc.match = null;
            _interactive.clear();
            _lab.after(const Duration(milliseconds: 1500), () => _loadStep(3));
          } else {
            _returnToStart(it);
            _err();
          }
        }
      case 3:
        if (action != 'drop' || it != sc.tumbler) return;
        final c2 = sc.candle2!;
        if (it.pos.dist(c2.pos) < 1.5) {
          it
            ..pos = _V3(c2.pos.x, 0.05, c2.pos.z)
            ..draggable = false;
          _ok();
          _interactive.clear();
          _lab.after(const Duration(milliseconds: 1500), () => _loadStep(4));
        } else {
          _returnToStart(it);
          _err();
        }
      case 5:
        if (it != sc.dropper) return;
        if (action == 'drop' && it.state == 'initial') {
          if (it.pos.dist(sc.dish2!.pos) < 3.0) {
            it
              ..pos = const _V3(1.5, 1.2, 0)
              ..draggable = false
              ..clickable = true
              ..state = 'placed';
            _ok();
          } else {
            _returnToStart(it);
            _err();
          }
        } else if (action == 'click' && it.state == 'placed') {
          it.clickable = false;
          _releaseDrops(it);
        }
    }
  }

  void _interactS2(_Item it, String action) {
    final sc = _scene;
    if (action != 'drop') return;
    switch (_step) {
      case 1:
        if (it != sc.magnifier) return;
        if (it.pos.dist(const _V3(0, 0.01, 0)) < 3.0) {
          it
            ..pos = const _V3(0, 1.5, 0)
            ..draggable = false;
          _err();
          _setHud('msg_no_heat', _HudType.error);
          _interactive.clear();
          final sprite = _Sprite('msg_no_heat_sprite', const _V3(0, 2.0, 0), sc.time);
          sc.sprites.add(sprite);
          _lab.after(const Duration(milliseconds: 3000), () {
            sc.sprites.remove(sprite);
            _loadStep(2);
          });
        } else {
          _returnToStart(it);
          _err();
        }
      case 3:
        if (it != sc.magnifier) return;
        if (it.pos.dist(const _V3(0, 0.01, 0)) < 3.0) {
          it
            ..pos = const _V3(0, 1.5, 0)
            ..draggable = false;
          sc.cones = true;
          _thermoVisible = true;
          _setHud('msg_hold', _HudType.info);
          _interactive.clear();
          _lab.after(const Duration(milliseconds: 500), () => _loadStep(4));
        } else {
          _returnToStart(it);
          _err();
        }
      case 5:
        if (it != sc.match) return;
        if (it.pos.dist(const _V3(0, 0.01, 0)) < 2.0) {
          sc.match = null;
          _ok();
          _Audio.play(_Sound.fire);
          sc
            ..fire = 1
            ..fireGlow = false
            ..fireW = 2.0
            ..fireH = 2.5;
          final sprite = _Sprite('msg_lit_match', const _V3(0, 1.5, 0), sc.time);
          sc.sprites.add(sprite);
          _setHud('msg_lit_match', _HudType.success);
          _interactive.clear();
          _tweenD(() => sc.paperScale, (v) => sc.paperScale = v, 0, 1500, done: () {
            sc.fire = 0;
            _lab.after(const Duration(milliseconds: 1500), () {
              sc.sprites.remove(sprite);
              _loadStep(6);
            });
          });
        } else {
          // The HTML returns the match without an error sound here.
          _returnToStart(it);
        }
    }
  }

  /// HTML `lightCandle()`: flame visible, point light 0 -> 1.5 in 500 ms.
  void _lightCandle(_Item c) {
    c
      ..lit = true
      ..flame = 1;
    _Audio.play(_Sound.fire, volume: 0.4);
    _tweenD(() => c.light, (v) => c.light = v, 1, 500);
  }

  /// HTML `extinguishCandle()`: flame and glow shrink over 1.5 s, then a
  /// puff of smoke rises and fades over 2.5 s.
  void _extinguish(_Item c) {
    c.lit = false;
    _tweenD(() => c.light, (v) => c.light = v, 0, 1500);
    _tweenD(() => c.flame, (v) => c.flame = v, 0, 1500, done: () {
      final puff = _Puff(c.pos + const _V3(0, 1.0, 0), 0.4, 0.7);
      _scene.puffs.add(puff);
      _scene.animate(2500, () {
        final y0 = puff.pos.y;
        return (t) {
          puff
            ..pos = puff.pos.withY(y0 + 1.5 * t)
            ..size = 0.4 + 1.1 * t
            ..opacity = 0.7 * (1 - t);
        };
      }, done: () => _scene.puffs.remove(puff));
    });
  }

  /// HTML dropper click: squeeze, a drop falls, lime water turns milky.
  void _releaseDrops(_Item d) {
    final sc = _scene;
    _scene.animate(200, () => (t) => d.bulb = 1 - 0.2 * t, done: () {
      _scene.animate(200, () => (t) => d.bulb = 0.8 + 0.2 * t);
    });
    sc.drop = d.pos + const _V3(0, -0.2, 0);
    _Audio.play(_Sound.drop);
    _tweenV3(() => sc.drop!, (v) => sc.drop = v, _V3(d.pos.x, 0.05, d.pos.z), 400, done: () {
      sc.drop = null;
      _ok();
      _Audio.play(_Sound.splash, volume: 0.4);
      final dish = sc.dish2!
        ..liquid = const Color(0xFFFFEE00)
        ..opacity = 0.9;
      _lab.after(const Duration(milliseconds: 400), () {
        dish
          ..liquid = Colors.white
          ..opacity = 1;
        final t = sc.tumbler!;
        _tweenD(() => t.pos.y, (v) => t.pos = t.pos.withY(v), 0.05, 500);
        _tweenV3(() => d.pos, (v) => d.pos = v, const _V3(-0.8, 0.3, 3), 500);
        sc.sprites.add(_Sprite('msg_milky', dish.pos + const _V3(0, 1.0, 0), sc.time));
        _interactive.clear();
        _lab.after(const Duration(milliseconds: 3500), () => _loadStep(6));
      });
    });
  }

  /// HTML `triggerFastForward()`.
  void _fastForward() {
    _Audio.play(_Sound.whoosh);
    setState(() => _ffVisible = false);
    _extinguish(_scene.candle2!);
    _lab.after(const Duration(milliseconds: 2500), () => _loadStep(5));
  }

  /// HTML `triggerSunny()`: sunny sky, brighter warm key light.
  void _makeSunny() {
    _ok();
    setState(() => _sunnyVisible = false);
    final sc = _scene;
    _tweenD(() => sc.sunny, (v) => sc.sunny = v, 1, 1000);
    _tweenD(() => sc.light, (v) => sc.light = v, 1, 1000);
    _lab.after(const Duration(milliseconds: 2000), () => _loadStep(3));
  }

  /// Step 4 of scenario 2 once the gauge reaches the ignition mark.
  void _ignition() {
    if (!mounted) return;
    final sc = _scene;
    _ok();
    _setHud('msg_ign_reached', _HudType.success);
    sc.burn = 1;
    final smoke = _Puff(const _V3(0, 0.5, 0), 1.5, 0.8);
    sc.puffs.add(smoke);
    _scene.animate(2000, () => (t) {
          smoke
            ..pos = smoke.pos.withY(0.5 + 3.0 * t)
            ..size = 1.5 + 2.5 * t
            ..opacity = 0.8 * (1 - t);
        });
    _lab.after(const Duration(milliseconds: 600), () {
      _Audio.play(_Sound.fire);
      sc
        ..fire = 1
        ..fireGlow = true
        ..fireW = 1.5
        ..fireH = 2
        ..fireLight = 1;
      _tweenD(() => sc.paperScale, (v) => sc.paperScale = v, 0, 2000);
      _lab.after(const Duration(milliseconds: 2500), () {
        sc
          ..fire = 0
          ..fireLight = 0
          ..cones = false;
        sc.puffs.remove(smoke);
        final m = sc.magnifier!;
        _tweenV3(() => m.pos, (v) => m.pos = v, const _V3(-1.5, 0.4, 3), 500);
        setState(() {
          _thermoVisible = false;
          _thermo = 0;
        });
        _lab.after(const Duration(milliseconds: 1000), () => _loadStep(5));
      });
    });
  }

  // --------------------------------------------------------- conclusion

  /// Step 6: HTML `showOverlay("Fire Triangle", ...)`, then 4.5 s later
  /// `showObservation(msg_obs)` (which also re-opens the sidebar). The final
  /// popup keeps the fire triangle and offers Continue / Restart Lab like
  /// `LabController.showScenarioConclusion`.
  void _conclusion({required bool oxygen}) {
    final idx = _scenario;
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('fire_triangle'),
        heading: _t('concept_summary'),
        icon: Icons.change_history,
        extra: _FireTriangle(
          oxygenOut: oxygen,
          frame: _frame,
          fuel: _t('word_fuel'),
          oxygen: _t('word_oxygen'),
          heat: _t('word_heat'),
          caption: _t(oxygen ? 'word_oxygen' : 'word_heat'),
        ),
      ),
      sound: _Sound.magic,
    );
    _lab.completedScenarios.add(idx);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.after(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      _lab.openSidebar();
      _lab.showPopup(() => LabPopupContent(
            title: _t('key_obs'),
            icon: Icons.lightbulb,
            extra: _observationBody(idx),
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
          ));
    });
  }

  /// Parses the `<b>` / `<sub>` markup of the observation texts.
  List<InlineSpan> _markup(String src, TextStyle base) {
    final size = base.fontSize ?? 14;
    final re = RegExp(r'<b>(.*?)</b>|<sub>(.*?)</sub>');
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > i) out.add(TextSpan(text: src.substring(i, m.start)));
      if (m.group(1) != null) {
        out.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w800)));
      } else {
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Transform.translate(
            offset: Offset(0, size * 0.28),
            child: Text(m.group(2)!, style: base.copyWith(fontSize: size * 0.68)),
          ),
        ));
      }
      i = m.end;
    }
    if (i < src.length) out.add(TextSpan(text: src.substring(i)));
    return out;
  }

  Widget _observationBody(int idx) {
    final p = _Theme.of(_lab.isDark);
    return Builder(builder: (context) {
      final s = context.labScale;
      final body = TextStyle(
        color: p.text,
        fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.4),
        fontWeight: FontWeight.w500,
        height: 1.5,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(TextSpan(style: body, children: _markup(_t('msg_obs${idx + 1}'), body))),
          SizedBox(height: 12 * s),
          _FireTriangle(
            oxygenOut: idx == 0,
            frame: _frame,
            fuel: _t('word_fuel'),
            oxygen: _t('word_oxygen'),
            heat: _t('word_heat'),
            caption: _t(idx == 0 ? 'word_oxygen' : 'word_heat'),
            compact: true,
          ),
        ],
      );
    });
  }

  // ------------------------------------------------------------ gestures

  /// Raycast stand-in: screen distance (design px) from [p] to [it]'s
  /// outline, using the same geometry the painter draws.
  double _hitDist(_Item it, Offset p) {
    final q = it.pos;
    final k = _Cam.k(q);
    Offset pt(double dx, double dy, double dz) => _Cam.pt(q + _V3(dx, dy, dz));
    return switch (it.kind) {
      _Kind.candle => _distToSeg(p, pt(0, 0, 0), pt(0, 0.95, 0)) - 0.24 * k,
      _Kind.matchbox => (p - pt(0, 0, 0.1)).distance - 0.5 * k,
      _Kind.match => math.min(_distToSeg(p, pt(-0.2, 0, 0), pt(0.2, 0, 0)), (p - pt(0.2, 0.2, 0)).distance) -
          0.12 * k,
      _Kind.tumbler => _distToSeg(p, pt(0, 0, 0), pt(0, 1.4, 0)) - 0.42 * k,
      _Kind.dropper => _distToSeg(p, pt(0, -0.4, 0), pt(0, 0.6, 0)) - 0.3 * k,
      _Kind.bottle => _distToSeg(p, pt(0, -0.3, 0), pt(0, 0.45, 0)) - 0.26 * k,
      _Kind.magnifier => math.min(
          (p - pt(0, 0, 0)).distance - 0.6 * k,
          _distToSeg(p, pt(0, 0, 0.5), pt(0, 0, 1.3)) - 0.12 * k,
        ),
    };
  }

  _Item? _itemAt(Offset p) {
    _Item? best;
    var bestD = 10.0;
    final items = _scene.items.toList()
      ..sort((a, b) => _Cam.depth(a.pos).compareTo(_Cam.depth(b.pos)));
    for (final it in items) {
      final d = _hitDist(it, p);
      if (d < bestD) {
        bestD = d;
        best = it;
      }
    }
    return best;
  }

  bool get _canInteract => _lab.isLabActive && _taskActive && _interactive.isNotEmpty;

  bool _canDrag(Offset p) {
    if (!_canInteract || _drag != null) return false;
    final it = _itemAt(p);
    return it != null && it.draggable && _interactive.contains(it);
  }

  /// HTML `onPointerDown` for a draggable: remember startPos, lift 0.5.
  void _beginDrag(_Item it, Offset p) {
    final hit = _Cam.onPlaneY(p, 0.05);
    _scene.cancel(it);
    it.startPos = it.pos;
    _grabDx = hit == null ? 0 : it.pos.x - hit.x;
    _grabDz = hit == null ? 0 : it.pos.z - hit.z;
    _drag = it;
    _scene.dragged = it;
    final y0 = it.startPos.y;
    _tweenD(() => it.pos.y, (v) => it.pos = it.pos.withY(v), y0 + 0.5, 150, tag: it);
    _Audio.play(_Sound.pickup);
  }

  /// HTML `onPointerUp`: lower back (150 ms), then the step's drop logic.
  void _endDrag() {
    final it = _drag;
    if (it == null) return;
    _drag = null;
    _scene.dragged = null;
    _scene.cancel(it);
    _tweenD(() => it.pos.y, (v) => it.pos = it.pos.withY(v), it.startPos.y, 150, tag: it, done: () {
      if (mounted) _interact(it, 'drop');
    });
  }

  void _onDragStart(DragStartDetails d) {
    if (!_canInteract) return;
    final it = _itemAt(d.localPosition);
    if (it == null || !it.draggable || !_interactive.contains(it)) return;
    _beginDrag(it, d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final it = _drag;
    if (it == null) return;
    final hit = _Cam.onPlaneY(d.localPosition, 0.05);
    if (hit == null) return;
    it.pos = _V3((hit.x + _grabDx).clamp(-6.0, 6.0), it.pos.y, (hit.z + _grabDz).clamp(-4.0, 5.0));
  }

  void _onTapUp(TapUpDetails d) {
    if (!_canInteract) return;
    final it = _itemAt(d.localPosition);
    if (it == null) return;
    if (_interactive.contains(it)) {
      if (it.clickable) {
        _interact(it, 'click');
      } else if (it.draggable) {
        // A click on a draggable is a zero-length drag in the HTML.
        _beginDrag(it, d.localPosition);
        _endDrag();
      }
    } else if (it.draggable || it.clickable) {
      _err();
    }
  }

  // ------------------------------------------------------------------ UI

  LabAction _ffAction() => LabAction(
        label: _t('btn_fast_forward'),
        icon: Icons.fast_forward,
        highlight: true,
        silent: true,
        onTap: _fastForward,
      );

  LabAction _sunnyAction() => LabAction(
        label: _t('btn_sunny'),
        icon: Icons.wb_sunny,
        color: _Colors.slate800,
        foreground: _Colors.zslYellow,
        highlight: true,
        silent: true,
        onTap: _makeSunny,
      );

  List<LabAction> _actions() => [
        if (_ffVisible) _ffAction(),
        if (_sunnyVisible) _sunnyAction(),
      ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final pad = MediaQuery.paddingOf(context);
        final canvasUi = _lab.isLabActive && _lab.isSidebarOpen;
        return LabShell(
          controller: _lab,
          icon: Icons.local_fire_department,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('s1_opt'), _t('s2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          showHud: false,
          onReset: _fullReset,
          overlays: [
            _hud(context, p, s),
            if (_sunnyVisible && canvasUi)
              Positioned(
                top: 10 + pad.top,
                right: 62 + pad.right,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200 * s),
                  child: LabActionButton(action: _sunnyAction(), scale: s, expand: false),
                ),
              ),
            if (_thermoVisible)
              Positioned(
                right: 64 + pad.right,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, 0.1),
                    child: ValueListenableBuilder<double>(
                      valueListenable: _frame,
                      builder: (context, _, _) => _thermometer(p, s),
                    ),
                  ),
                ),
              ),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ObjectDragRecognizer: GestureRecognizerFactoryWithHandlers<_ObjectDragRecognizer>(
                  () => _ObjectDragRecognizer(accept: _canDrag),
                  (r) {
                    r
                      ..accept = _canDrag
                      ..gestureSettings = const DeviceGestureSettings(touchSlop: 6)
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = ((_) => _endDrag())
                      ..onCancel = _endDrag;
                  },
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _BenchPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML mini HUD: "Current Task", the task / feedback message (border
  /// green for success, red for errors) and the action area (Fast Forward).
  Widget _hud(BuildContext context, LabPalette p, double s) {
    final pad = MediaQuery.paddingOf(context);
    final text = !_lab.isLabActive
        ? _t('loading_instructions')
        : (_hudKey.isEmpty ? _data.steps[(_step - 1).clamp(0, 5)].action : _t(_hudKey));
    final accent = switch (_hudType) {
      _HudType.success => _Colors.green,
      _HudType.error => _Colors.red,
      _HudType.info => _Colors.zslYellow.withValues(alpha: 0.3),
    };
    return Positioned(
      left: 12,
      right: 60 + pad.right,
      bottom: 8 + pad.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 540 * s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                const BoxShadow(color: Color(0x55000000), blurRadius: 18),
                if (_hudType != _HudType.info) BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, size: 14 * s, color: _Colors.zslYellow),
                    SizedBox(width: 5 * s),
                    Flexible(
                      child: Text(
                        _t('hud_task').toUpperCase(),
                        style: TextStyle(
                          color: _Colors.zslYellow,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3 * s),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.textStrong, fontSize: 12 * s, fontWeight: FontWeight.w600, height: 1.3),
                ),
                if (_ffVisible && _lab.isLabActive && _lab.isSidebarOpen) ...[
                  SizedBox(height: 6 * s),
                  LabActionButton(action: _ffAction(), scale: s * 0.95, expand: false),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#thermometer-ui`: glass tube, mercury, ignition mark and bulb.
  Widget _thermometer(LabPalette p, double s) {
    final tubeH = 118.0 * s, tubeW = 16.0 * s;
    return Container(
      padding: EdgeInsets.fromLTRB(9 * s, 10 * s, 9 * s, 4 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.isDark ? _Colors.slate600 : _Colors.slate300, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: tubeW,
                height: tubeH,
                decoration: BoxDecoration(
                  color: p.isDark ? _Colors.slate700 : _Colors.slate200,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _Colors.slate400),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: _thermo.clamp(0.0, 1.0),
                      widthFactor: 1,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFFDC2626), Color(0xFFF87171)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: tubeH * 0.2 - 1.5 * s,
                left: 0,
                right: 0,
                child: Container(height: 3 * s, color: const Color(0xFF991B1B)),
              ),
              Positioned(
                top: tubeH * 0.2 - 14 * s,
                right: tubeW + 6 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 1 * s),
                  decoration: BoxDecoration(
                    color: (p.isDark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _t('ign_temp'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.isDark ? const Color(0xFFF87171) : _Colors.red600,
                      fontSize: 8.5 * s,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -5 * s),
            child: Container(
              width: 30 * s,
              height: 30 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Colors.red600,
                border: Border.all(color: _Colors.slate400),
                boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML `showOverlay("Fire Triangle", "Oxygen" | "Heat")` SVG: the triangle
/// with FUEL / OXYGEN / HEAT sides and a flame in the middle. OXYGEN is
/// crossed out (scenario 1) or HEAT highlighted and pulsing (scenario 2).
class _FireTriangle extends StatelessWidget {
  const _FireTriangle({
    required this.oxygenOut,
    required this.frame,
    required this.fuel,
    required this.oxygen,
    required this.heat,
    required this.caption,
    this.compact = false,
  });

  final bool oxygenOut;
  final ValueNotifier<double> frame;
  final String fuel, oxygen, heat, caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = context.labScale;
    final side = (compact ? 130.0 : 180.0) * s;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrianglePainter(
                      frame: frame,
                      oxygenOut: oxygenOut,
                      fuel: fuel,
                      oxygen: oxygen,
                      heat: heat,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.3),
                  child: ValueListenableBuilder<double>(
                    valueListenable: frame,
                    builder: (context, t, _) => Opacity(
                      opacity: oxygenOut ? 1 : 0.65 + 0.35 * (0.5 + 0.5 * math.sin(t * 4)),
                      child: Icon(
                        Icons.local_fire_department,
                        size: side * 0.3,
                        color: oxygenOut ? _Colors.slate500 : _Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13 * s, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.frame,
    required this.oxygenOut,
    required this.fuel,
    required this.oxygen,
    required this.heat,
  }) : super(repaint: frame);

  final ValueNotifier<double> frame;
  final bool oxygenOut;
  final String fuel, oxygen, heat;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 100;
    canvas.save();
    canvas.scale(k);
    final tri = Path()
      ..moveTo(50, 10)
      ..lineTo(90, 90)
      ..lineTo(10, 90)
      ..close();
    canvas.drawPath(
      tri,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.zslYellow,
    );
    labText(canvas, fuel, const Offset(50, 81), size: 10.5, color: const Color(0xFF4ADE80), weight: FontWeight.w800);

    canvas.save();
    canvas.translate(25, 50);
    canvas.rotate(-math.pi / 3);
    labText(canvas, oxygen, const Offset(0, -4), size: 10.5, weight: FontWeight.w800,
        color: oxygenOut ? _Colors.red.withValues(alpha: 0.5) : const Color(0xFF60A5FA));
    if (oxygenOut) {
      canvas.drawLine(const Offset(-30, -4), const Offset(30, 4), Paint()
        ..color = _Colors.red
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round);
    }
    canvas.restore();

    canvas.save();
    canvas.translate(75, 50);
    canvas.rotate(math.pi / 3);
    if (!oxygenOut) {
      final pulse = 0.5 + 0.5 * math.sin(frame.value * 4);
      canvas.scale(1 + 0.1 * pulse);
      labGlow(canvas, const Offset(0, -4), 22, _Colors.red, intensity: 0.5 + 0.4 * pulse);
    }
    labText(canvas, heat, const Offset(0, -4), size: 10.5, weight: FontWeight.w800,
        color: oxygenOut ? const Color(0xFFFB923C) : _Colors.red);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) =>
      old.oxygenOut != oxygenOut || old.fuel != fuel || old.oxygen != oxygen || old.heat != heat;
}

// ============================================================ STRINGS
//
// From the HTML `i18n` object (EN + HI; Telugu dropped). Popup texts use a
// tiny markup instead of HTML / MathJax: <b>bold</b>, <sub>subscript</sub>.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Combustion Conditions and Products',
    'app_subtitle': 'Class 7 • Changes Around Us: Physical and Chemical',
    'key_obs': 'Key Observation',
    'concept_summary': 'Concept Summary',
    'fire_triangle': 'Fire Triangle',
    'btn_sunny': 'Make Sunny',
    'ign_temp': 'Ignition\nTemp',
    'hud_task': 'Current Task',
    'loading_instructions': 'Loading experiment instructions...',
    'btn_fast_forward': 'Fast Forward',
    's1_opt': '1. The Oxygen Requirement',
    's2_opt': '2. The Ignition Temperature Requirement',
    'msg_both_placed': 'Both candles placed successfully.',
    'msg_milky': 'Lime water turns milky, confirming presence of CO2',
    'msg_obs1':
        '<b>Observation:</b> Covering the candle cut off the oxygen supply, causing the flame to extinguish. '
            'Furthermore, the lime water turned milky, proving that carbon dioxide (CO<sub>2</sub>) is a byproduct of '
            'combustion.\n\n<b>Conclusion:</b> Oxygen is an essential requirement for combustion.',
    'msg_no_heat': 'Not enough heat from the sun on a cloudy day.',
    'msg_no_heat_sprite': 'Not enough heat on a cloudy day',
    'msg_hold': 'Hold steady. Temperature is rising...',
    'msg_ign_reached': 'Ignition Temperature Reached!',
    'msg_drag_match': 'DRAG the lit match to the paper.',
    'msg_lit_match': "A lit match is already hotter than the paper's ignition temperature.",
    'msg_obs2':
        '<b>Observation:</b> Focused sunlight gradually heated the paper until it caught fire. A lighted match, '
            'however, ignited it instantly.\n\n<b>Conclusion:</b> For combustion to start, a fuel needs oxygen AND '
            'enough heat to reach its ignition temperature.',
    'lbl_candle': 'Candle (Fuel)',
    'lbl_petri': 'Petri Dish',
    'lbl_tumbler': 'Glass Tumbler',
    'lbl_matchbox': 'Matchbox',
    'lbl_dropper': 'Dropper',
    'lbl_bottle': 'Lime Water Bottle',
    'lbl_paper': 'Combustible Paper',
    'lbl_magnifier': 'Magnifying Glass',
    'lbl_tray': 'INVENTORY TRAY',
    'word_fuel': 'FUEL',
    'word_oxygen': 'OXYGEN',
    'word_heat': 'HEAT',
  },
  'hi': {
    'app_title': 'दहन की शर्तें और उत्पाद',
    'app_subtitle': 'कक्षा 7 • हमारे चारों ओर के परिवर्तन: भौतिक और रासायनिक',
    'key_obs': 'मुख्य अवलोकन',
    'concept_summary': 'अवधारणा सारांश',
    'fire_triangle': 'अग्नि त्रिभुज',
    'btn_sunny': 'धूप करें',
    'ign_temp': 'प्रज्वलन\nताप',
    'hud_task': 'वर्तमान कार्य',
    'loading_instructions': 'प्रयोग के निर्देश लोड हो रहे हैं...',
    'btn_fast_forward': 'फास्ट फॉरवर्ड',
    's1_opt': '1. ऑक्सीजन की आवश्यकता',
    's2_opt': '2. प्रज्वलन ताप की आवश्यकता',
    'msg_both_placed': 'दोनों मोमबत्तियां सफलतापूर्वक रखी गईं।',
    'msg_milky': 'चूने का पानी दूधिया हो जाता है, जिससे CO2 की उपस्थिति की पुष्टि होती है',
    'msg_obs1':
        '<b>अवलोकन:</b> मोमबत्ती को ढकने से ऑक्सीजन की आपूर्ति कट गई, जिससे लौ बुझ गई। इसके अलावा, चूने का पानी '
            'दूधिया हो गया, जो यह साबित करता है कि कार्बन डाइऑक्साइड (CO<sub>2</sub>) दहन का एक उपोत्पाद है।\n\n'
            '<b>निष्कर्ष:</b> दहन के लिए ऑक्सीजन एक आवश्यक आवश्यकता है।',
    'msg_no_heat': 'बादल वाले दिन सूरज से पर्याप्त गर्मी नहीं मिलती है।',
    'msg_no_heat_sprite': 'बादल वाले दिन पर्याप्त गर्मी नहीं',
    'msg_hold': 'स्थिर पकड़ें। तापमान बढ़ रहा है...',
    'msg_ign_reached': 'प्रज्वलन ताप पहुंच गया!',
    'msg_drag_match': 'जली हुई माचिस को कागज पर खींचें।',
    'msg_lit_match': 'एक जली हुई माचिस पहले से ही कागज के प्रज्वलन ताप से अधिक गर्म होती है।',
    'msg_obs2':
        '<b>अवलोकन:</b> केंद्रित धूप ने कागज को धीरे-धीरे तब तक गर्म किया जब तक कि उसमें आग न लग जाए। हालांकि, '
            'जली हुई माचिस ने इसे तुरंत जला दिया।\n\n<b>निष्कर्ष:</b> दहन शुरू होने के लिए, ईंधन को ऑक्सीजन और उसके '
            'प्रज्वलन ताप तक पहुंचने के लिए पर्याप्त गर्मी की आवश्यकता होती है।',
    'lbl_candle': 'मोमबत्ती (ईंधन)',
    'lbl_petri': 'पेट्री डिश',
    'lbl_tumbler': 'कांच का गिलास',
    'lbl_matchbox': 'माचिस',
    'lbl_dropper': 'ड्रॉपर',
    'lbl_bottle': 'चूने के पानी की बोतल',
    'lbl_paper': 'ज्वलनशील कागज',
    'lbl_magnifier': 'आवर्धक लेंस',
    'lbl_tray': 'सामग्री ट्रे',
    'word_fuel': 'ईंधन',
    'word_oxygen': 'ऑक्सीजन',
    'word_heat': 'गर्मी',
  },
};

// concept = HTML step title, action = its "Task" (also the HUD text),
// observation = its "Theory" (teacher-board text, kept as data).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually demonstrate that oxygen is essential for combustion and to identify carbon dioxide as a product.',
      steps: [
        LabStep(
          concept: 'Setup Combustible Substance',
          action:
              'DRAG two identical candles from the inventory tray and DROP them onto the two petri dishes on the lab bench.',
          observation:
              'Combustion is a chemical change where a substance reacts with oxygen, giving off heat and light. A combustible substance (fuel) is the first requirement.',
        ),
        LabStep(
          concept: 'Provide Heat (Ignition)',
          action:
              'DRAG the matchbox to the center of the screen. CLICK on the matchbox to get a lit match. DRAG the lit match to the wick of the first candle, then to the wick of the second candle.',
          observation: 'To start combustion, heat is required to bring the fuel to its ignition temperature.',
        ),
        LabStep(
          concept: 'Cut off Oxygen Supply',
          action: 'DRAG the glass tumbler from the inventory tray and DROP it over the candle on the right.',
          observation:
              'Air contains oxygen. What happens if we restrict the continuous supply of air to the burning candle?',
        ),
        LabStep(
          concept: 'Observe and Fast Forward',
          action: "Observe the two candles. CLICK the 'Fast Forward' button to speed up time.",
          observation:
              "The flame uses the oxygen trapped inside the tumbler. Once it's depleted, combustion stops.",
        ),
        LabStep(
          concept: 'Test for Products (CO₂)',
          action:
              'A bottle of lime water with a dropper appears. DRAG the dropper to the petri dish under the extinguished candle and CLICK to release a few drops of lime water into the dish.',
          observation:
              'During combustion, carbon from the wax reacts with oxygen to form Carbon Dioxide (CO₂). We use lime water to test for it. Ca(OH)₂ + CO₂ → CaCO₃ + H₂O',
        ),
        LabStep(
          concept: 'Conclusion',
          action:
              'Observe the final state. The uncovered candle is still burning, while the covered one is out, and the lime water in its dish is milky.',
          observation: 'Without oxygen, the fire triangle is broken, and combustion cannot be sustained.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually demonstrate that a combustible substance needs to be heated to its ignition temperature to start burning.',
      steps: [
        LabStep(
          concept: 'Cloudy Day Attempt',
          action:
              'A piece of paper is on a wooden surface. The background shows a cloudy sky. DRAG the magnifying glass from the inventory and HOLD it over the paper.',
          observation:
              'A combustible substance must reach a minimum temperature called the Ignition Temperature to catch fire.',
        ),
        LabStep(
          concept: 'Change Weather',
          action: 'CLICK the sun icon in the top corner of the screen to change the weather.',
          observation: "We need intense heat to raise the paper's temperature.",
        ),
        LabStep(
          concept: 'Focus Sunrays',
          action:
              'DRAG the magnifying glass and HOLD it over the paper again. Adjust its position until the bright spot is as small as possible.',
          observation: 'Sunlight is concentrated by the lens, focusing heat energy into a small spot.',
        ),
        LabStep(
          concept: 'Reaching Ignition Temperature',
          action: 'Continue to HOLD the magnifying glass steady. Observe the temperature gauge and the paper.',
          observation:
              'The minimum temperature at which a substance catches fire is its Ignition Temperature.',
        ),
        LabStep(
          concept: 'Instant Ignition',
          action:
              'A new piece of paper and a matchbox appear. DRAG the lit match from the matchbox and TOUCH it to the paper.',
          observation: 'A lit matchstick is already hotter than the ignition temperature of the paper.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the final result and the summary.',
          observation: 'Without sufficient heat to reach ignition temperature, combustion will not occur.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह दृश्य रूप से प्रदर्शित करने के लिए कि दहन के लिए ऑक्सीजन आवश्यक है और कार्बन डाइऑक्साइड को एक उत्पाद के रूप में पहचानने के लिए।',
      steps: [
        LabStep(
          concept: 'ज्वलनशील पदार्थ सेट करें',
          action: 'इन्वेंट्री ट्रे से दो समान मोमबत्तियों को खींचें और उन्हें लैब बेंच पर दो पेट्री डिश पर छोड़ दें।',
          observation:
              'दहन एक रासायनिक परिवर्तन है जहां कोई पदार्थ ऑक्सीजन के साथ प्रतिक्रिया करता है, जिससे गर्मी और प्रकाश निकलता है। एक ज्वलनशील पदार्थ (ईंधन) पहली आवश्यकता है।',
        ),
        LabStep(
          concept: 'गर्मी प्रदान करें (प्रज्वलन)',
          action:
              'माचिस को स्क्रीन के केंद्र में खींचें। जली हुई माचिस पाने के लिए माचिस पर क्लिक करें। जली हुई माचिस को पहली मोमबत्ती की बत्ती पर, फिर दूसरी मोमबत्ती की बत्ती पर खींचें।',
          observation: 'दहन शुरू करने के लिए, ईंधन को उसके प्रज्वलन ताप पर लाने के लिए गर्मी की आवश्यकता होती है।',
        ),
        LabStep(
          concept: 'ऑक्सीजन की आपूर्ति बंद करें',
          action: 'इन्वेंट्री ट्रे से कांच के गिलास को खींचें और इसे दाईं ओर की मोमबत्ती के ऊपर छोड़ दें।',
          observation:
              'हवा में ऑक्सीजन होती है। क्या होता है अगर हम जलती हुई मोमबत्ती में हवा की निरंतर आपूर्ति को प्रतिबंधित करते हैं?',
        ),
        LabStep(
          concept: 'निरीक्षण करें और फास्ट फॉरवर्ड करें',
          action: "दोनों मोमबत्तियों का निरीक्षण करें। समय को तेज करने के लिए 'फास्ट फॉरवर्ड' बटन पर क्लिक करें।",
          observation: 'लौ टंबलर के अंदर फंसी ऑक्सीजन का उपयोग करती है। इसके समाप्त होने के बाद, दहन रुक जाता है।',
        ),
        LabStep(
          concept: 'उत्पादों के लिए परीक्षण (CO₂)',
          action:
              'ड्रॉपर के साथ चूने के पानी की एक बोतल दिखाई देती है। ड्रॉपर को बुझी हुई मोमबत्ती के नीचे पेट्री डिश में खींचें और डिश में चूने के पानी की कुछ बूंदें छोड़ने के लिए क्लिक करें।',
          observation:
              'दहन के दौरान, मोम से कार्बन ऑक्सीजन के साथ प्रतिक्रिया करके कार्बन डाइऑक्साइड (CO₂) बनाता है। हम इसके परीक्षण के लिए चूने के पानी का उपयोग करते हैं। Ca(OH)₂ + CO₂ → CaCO₃ + H₂O',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action:
              'अंतिम स्थिति का निरीक्षण करें। बिना ढकी मोमबत्ती अभी भी जल रही है, जबकि ढकी हुई मोमबत्ती बुझ गई है, और उसकी डिश में चूने का पानी दूधिया हो गया है।',
          observation: 'ऑक्सीजन के बिना, अग्नि त्रिभुज टूट जाता है, और दहन जारी नहीं रह सकता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह प्रदर्शित करने के लिए कि किसी ज्वलनशील पदार्थ को जलना शुरू करने के लिए उसके प्रज्वलन ताप तक गर्म करने की आवश्यकता होती है।',
      steps: [
        LabStep(
          concept: 'बादल वाले दिन का प्रयास',
          action:
              'लकड़ी की सतह पर कागज का एक टुकड़ा है। पृष्ठभूमि में बादल छाए हुए आकाश को दिखाया गया है। इन्वेंट्री से आवर्धक लेंस खींचें और इसे कागज के ऊपर पकड़ें।',
          observation: 'आग पकड़ने के लिए एक ज्वलनशील पदार्थ को प्रज्वलन ताप नामक न्यूनतम तापमान तक पहुंचना चाहिए।',
        ),
        LabStep(
          concept: 'मौसम बदलें',
          action: 'मौसम बदलने के लिए स्क्रीन के शीर्ष कोने में सूर्य आइकन पर क्लिक करें।',
          observation: 'कागज का तापमान बढ़ाने के लिए हमें तेज गर्मी की आवश्यकता होती है।',
        ),
        LabStep(
          concept: 'सूर्य की किरणों को केंद्रित करें',
          action:
              'आवर्धक लेंस को फिर से खींचें और इसे कागज के ऊपर पकड़ें। इसकी स्थिति को तब तक समायोजित करें जब तक कि चमकीला स्थान जितना संभव हो उतना छोटा न हो जाए।',
          observation:
              'सूर्य का प्रकाश लेंस द्वारा केंद्रित होता है, जिससे ऊष्मीय ऊर्जा एक छोटे बिंदु पर केंद्रित हो जाती है।',
        ),
        LabStep(
          concept: 'प्रज्वलन ताप तक पहुँचना',
          action: 'आवर्धक लेंस को स्थिर रखना जारी रखें। तापमान गेज और कागज का निरीक्षण करें।',
          observation: 'वह न्यूनतम तापमान जिस पर कोई पदार्थ आग पकड़ता है, उसका प्रज्वलन ताप कहलाता है।',
        ),
        LabStep(
          concept: 'तत्काल प्रज्वलन',
          action: 'कागज का एक नया टुकड़ा और एक माचिस दिखाई देती है। माचिस से जली हुई माचिस निकालें और उसे कागज से छुएं।',
          observation: 'एक जली हुई माचिस पहले से ही कागज के प्रज्वलन ताप से अधिक गर्म होती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'अंतिम परिणाम और सारांश का निरीक्षण करें।',
          observation: 'प्रज्वलन ताप तक पहुंचने के लिए पर्याप्त गर्मी के बिना, दहन नहीं होगा।',
        ),
      ],
    ),
  ],
};

// ============================================================ 3D MATH
//
// The HTML renders a Three.js bench with a 45° perspective camera. A small
// perspective projector maps the same world coordinates (HTML scene units)
// onto the 1000x560 design stage, so object positions, drag planes and drop
// distances match the original exactly.

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
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  _V3 withY(double v) => _V3(x, v, z);
  double dist(_V3 o) => (this - o).length;

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective camera (fov 45°). The HTML camera sits at (0, 4.5, 9)
/// looking at the origin; here it looks slightly further forward so the
/// inventory tray stays clear of the bottom HUD on the 1000x560 stage.
class _Cam {
  static const _V3 eye = _V3(0, 4.6, 8.6);
  static const _V3 target = _V3(0, 0.25, 1.6);
  static final double _tanHalf = math.tan(22.5 * math.pi / 180);
  static final _V3 _f = (target - eye).unit;
  static final _V3 _r = _f.cross(const _V3(0, 1, 0)).unit;
  static final _V3 _u = _r.cross(_f);
  static final double _focal = _design.height / 2 / _tanHalf;

  static double depth(_V3 p) => (p - eye).dot(_f);

  static double k(_V3 p) => _focal / math.max(depth(p), 0.1);

  static Offset pt(_V3 p) {
    final d = p - eye;
    final kk = _focal / math.max(d.dot(_f), 0.1);
    return Offset(_design.width / 2 + d.dot(_r) * kk, _design.height / 2 - d.dot(_u) * kk);
  }

  static double tilt(_V3 p) => (eye - p).unit.y.abs().clamp(0.04, 1.0);

  static Rect ellipse(_V3 c, double r) {
    final a = r * k(c);
    return Rect.fromCenter(center: pt(c), width: 2 * a, height: 2 * a * tilt(c));
  }

  /// Ray through design point [s] intersected with the plane y = [h]
  /// (the HTML's invisible drag plane is y = 0.05).
  static _V3? onPlaneY(Offset s, double h) {
    final dir = _f +
        _r * ((s.dx - _design.width / 2) / _focal) +
        _u * (-(s.dy - _design.height / 2) / _focal);
    if (dir.y.abs() < 1e-6) return null;
    final t = (h - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// Where the sun of the sunny sky backdrop is drawn (texture 850, 100 of
/// 1024x512); the focused light beam is aimed at it.
const Offset _skySun = Offset(850 / 1024 * 1000, 100 / 512 * 560);

// ============================================================ SCENE MODEL

enum _Kind { candle, matchbox, match, tumbler, dropper, bottle, magnifier }

/// A movable lab object (HTML THREE.Group with userData).
class _Item {
  _Item(this.kind, this.pos) : startPos = pos;
  final _Kind kind;
  _V3 pos;

  /// HTML `userData.startPos` (where the current drag began).
  _V3 startPos;
  bool draggable = false;
  bool clickable = false;
  String state = 'initial';

  // Candle.
  bool lit = false;
  bool placed = false;
  double flame = 0; // flame sprite scale (0..1)
  double light = 0; // point light intensity (0..1)

  // Dropper bulb squeeze (scale).
  double bulb = 1;
}

class _Dish {
  _Dish(this.pos);
  final _V3 pos;
  Color liquid = const Color(0xFFFFEE00);
  double opacity = 0;
}

/// HTML smoke sprite.
class _Puff {
  _Puff(this.pos, this.size, this.opacity);
  _V3 pos;
  double size;
  double opacity;
}

/// HTML `createTextSprite(key)` placed in the scene (not tied to an item).
class _Sprite {
  _Sprite(this.key, this.pos, this.born);
  final String key;
  final _V3 pos;
  final double born;
}

/// One running tween (HTML TWEEN.Tween); [setup] captures start values.
class _Anim {
  _Anim(this.at, this.dur, this.curve, this.setup, this.done, this.tag);
  final double at;
  final double dur;
  final Curve curve;
  final void Function(double t) Function() setup;
  final VoidCallback? done;
  final Object? tag;
  void Function(double t)? apply;
}

class _Scene {
  int scenario = 0;
  double time = 0;

  // Scenario 1.
  _Dish? dish1, dish2;
  _Item? candle1, candle2, matchbox, match, tumbler, bottle, dropper;
  _V3? drop; // falling drop of lime water

  // Scenario 2.
  bool paper = false;
  double paperScale = 1;
  double burn = 0; // burn mark on the paper
  _Item? magnifier;
  bool cones = false; // focused light cones + spot light
  double fire = 0; // paper flame intensity
  bool fireGlow = true;
  double fireW = 1.5, fireH = 2;
  double fireLight = 0;

  /// 0 = cloudy, 1 = sunny sky (scenario 2).
  double sunny = 0;

  /// Key/ambient light level (HTML keyLight / ambientLight intensities).
  double light = 1;

  final List<_Puff> puffs = [];
  final List<_Sprite> sprites = [];
  final List<_Anim> anims = [];

  /// Object currently dragged (drawn highlighted).
  _Item? dragged;

  Iterable<_Item> get items => [candle1, candle2, matchbox, match, tumbler, bottle, dropper, magnifier]
      .whereType<_Item>();

  void clear() {
    dish1 = dish2 = null;
    candle1 = candle2 = matchbox = match = tumbler = bottle = dropper = magnifier = null;
    drop = null;
    paper = false;
    paperScale = 1;
    burn = 0;
    cones = false;
    fire = 0;
    fireLight = 0;
    sunny = 0;
    light = 1;
    puffs.clear();
    sprites.clear();
    anims.clear();
    dragged = null;
  }

  void animate(
    double ms,
    void Function(double t) Function() setup, {
    double delayMs = 0,
    Curve curve = Curves.linear,
    VoidCallback? done,
    Object? tag,
  }) {
    anims.add(_Anim(time + delayMs / 1000, ms / 1000, curve, setup, done, tag));
  }

  void cancel(Object tag) => anims.removeWhere((a) => a.tag == tag);

  void tickAnims() {
    if (anims.isEmpty) return;
    for (final a in List<_Anim>.of(anims)) {
      if (!anims.contains(a) || time < a.at) continue;
      a.apply ??= a.setup();
      final t = a.dur <= 0 ? 1.0 : ((time - a.at) / a.dur).clamp(0.0, 1.0);
      a.apply!(a.curve.transform(t));
      if (t >= 1) {
        anims.remove(a);
        a.done?.call();
      }
    }
  }
}

// ============================================================ PAINTER

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..color = color;

/// Side silhouette of an upright cylinder between ellipses [top] and [bot].
Path _bodyPath(Rect top, Rect bot) => Path()
  ..moveTo(top.left, top.center.dy)
  ..lineTo(bot.left, bot.center.dy)
  ..arcTo(bot, math.pi, -math.pi, false)
  ..lineTo(top.right, top.center.dy)
  ..arcTo(top, 0, -math.pi, false)
  ..close();

/// Shaded rod (match sticks, handles, wicks).
void _rod(Canvas c, Offset a, Offset b, double w, Color color) {
  final d = b - a;
  final len = d.distance;
  if (len < 0.5 || w <= 0) return;
  c.save();
  c.translate(a.dx, a.dy);
  c.rotate(math.atan2(d.dy, d.dx));
  final r = Rect.fromLTWH(0, -w / 2, len, w);
  c.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(w / 2)),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [labShade(color, 0.35), color, labShade(color, -0.4)],
        stops: const [0, 0.45, 1],
      ).createShader(r),
  );
  c.restore();
}

class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final String Function(String key) tr;

  /// Darkens colours under the dim cloudy-day lighting.
  Color _lit(Color c) => scene.light >= 1 ? c : labShade(c, -(1 - scene.light) * 0.8);

  @override
  void paint(Canvas canvas, Size size) {
    _background(canvas, size);
    _bench(canvas, size);
    _lightPools(canvas);

    // Flat things lying on the bench / tray first.
    _box(canvas, const _V3(0, 0.05, 3), const _V3(2.25, 0.05, 1.25), const Color(0xFFA0AAB5));
    if (scene.paper) _paper(canvas);
    for (final d in [scene.dish1, scene.dish2].whereType<_Dish>()) {
      _dish(canvas, d);
    }

    // Upright objects, far to near.
    final items = scene.items.toList()
      ..sort((a, b) => _Cam.depth(_anchor(b)).compareTo(_Cam.depth(_anchor(a))));
    for (final it in items) {
      _item(canvas, it);
    }
    final drop = scene.drop;
    if (drop != null) {
      labSphere(canvas, _Cam.pt(drop), math.max(3.0, 0.05 * _Cam.k(drop)), const Color(0xFFFFEE00));
    }
    if (scene.cones) _cones(canvas);
    if (scene.fire > 0) _fire(canvas);
    for (final p in scene.puffs) {
      _puff(canvas, p);
    }
    if (showLabels) _labels(canvas);
  }

  _V3 _anchor(_Item it) => switch (it.kind) {
        _Kind.tumbler => it.pos + const _V3(0, 0.75, 0),
        _Kind.candle => it.pos + const _V3(0, 0.4, 0),
        _Kind.magnifier => it.pos + const _V3(0, 0, 0.4),
        _ => it.pos,
      };

  // ------------------------------------------------------------ backdrop

  void _background(Canvas c, Size size) {
    final bleed = labBleed(size);
    if (scene.scenario == 0) {
      // CSS `.bg-standard` behind the transparent renderer.
      c.drawRect(
        bleed,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF020617)]
                : const [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
      return;
    }
    // Scenario 2: sky textures (scene.background), cross-faded.
    if (scene.sunny < 1) _cloudySky(c, size, 1);
    if (scene.sunny > 0) _sunnySky(c, size, scene.sunny);
  }

  void _cloudySky(Canvas c, Size size, double a) {
    final bleed = labBleed(size);
    c.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF64748B).withValues(alpha: a), const Color(0xFF94A3B8).withValues(alpha: a)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final sx = size.width / 1024, sy = size.height / 512;
    final cloud = Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: a);
    final shade = Paint()..color = const Color(0xFFB4BFCD).withValues(alpha: a);
    for (final (x, y, r) in const [(200.0, 150.0, 80.0), (300.0, 180.0, 100.0), (400.0, 160.0, 90.0), (700.0, 150.0, 90.0), (850.0, 120.0, 120.0)]) {
      c.drawOval(Rect.fromCenter(center: Offset(x * sx, y * sy + 6), width: 2 * r * sx, height: 2 * r * sy), shade);
    }
    for (final (x, y, r) in const [(200.0, 150.0, 80.0), (300.0, 180.0, 100.0), (400.0, 160.0, 90.0), (700.0, 150.0, 90.0), (850.0, 120.0, 120.0)]) {
      c.drawOval(Rect.fromCenter(center: Offset(x * sx, y * sy), width: 2 * r * sx, height: 2 * r * sy), cloud);
    }
  }

  void _sunnySky(Canvas c, Size size, double a) {
    final bleed = labBleed(size);
    c.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF4FACFE).withValues(alpha: a), const Color(0xFF00F2FE).withValues(alpha: a)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final s = size.width / 1024;
    c.save();
    c.translate(_skySun.dx, _skySun.dy);
    c.drawCircle(
      Offset.zero,
      250 * s,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE047).withValues(alpha: 0.8 * a),
            const Color(0xFFFDE047).withValues(alpha: 0),
          ],
          stops: const [0.16, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 250 * s)),
    );
    // Sun rays (slowly turning).
    c.rotate(scene.time * 0.05);
    final ray = Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.2 * a);
    for (var i = 0; i < 12; i++) {
      c.rotate(math.pi / 6);
      c.drawPath(
        Path()
          ..moveTo(-15 * s, 0)
          ..lineTo(15 * s, 0)
          ..lineTo(150 * s, 1000 * s)
          ..lineTo(-150 * s, 1000 * s)
          ..close(),
        ray,
      );
    }
    c.restore();
    c.drawCircle(_skySun, 60 * s, Paint()..color = const Color(0xFFF8FAFC).withValues(alpha: a));
  }

  /// HTML wooden bench (10 x 0.5 x 7 box, colour 0x9a6a38) on four legs.
  void _bench(Canvas c, Size size) {
    const legColor = Color(0xFF8B5A2B);
    for (final (x, z) in const [(-4.5, -3.0), (4.5, -3.0), (-4.5, 3.0), (4.5, 3.0)]) {
      _box(c, _V3(x, -2.125, z), const _V3(0.25, 1.625, 0.25), legColor);
    }
    const wood = Color(0xFF9A6A38);
    _box(c, const _V3(0, -0.25, 0), const _V3(5, 0.25, 3.5), wood);
    // Planks and grain on the top.
    final seam = _stroke(Colors.black.withValues(alpha: 0.22), 1.2);
    for (var i = 1; i < 8; i++) {
      final z = -3.5 + i * 0.875;
      c.drawLine(_Cam.pt(_V3(-5, 0, z)), _Cam.pt(_V3(5, 0, z)), seam);
    }
    final grain = _stroke(const Color(0xFF6B4423).withValues(alpha: 0.18), 1);
    for (var i = 0; i < 26; i++) {
      final z = -3.4 + i * 0.27;
      final x0 = -5 + 4 * (0.5 + 0.5 * math.sin(i * 2.3));
      c.drawLine(_Cam.pt(_V3(x0, 0, z)), _Cam.pt(_V3(math.min(5, x0 + 2.5 + (i % 3)), 0, z + 0.02)), grain);
    }
  }

  /// Warm light cast on the bench by lit candles and the burning paper.
  void _lightPools(Canvas c) {
    void pool(_V3 at, double r, Color color, double intensity) {
      if (intensity <= 0) return;
      final e = _Cam.ellipse(at, r);
      c.save();
      c.translate(e.center.dx, e.center.dy);
      c.scale(1, e.height / e.width);
      c.drawCircle(
        Offset.zero,
        e.width / 2,
        Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: 0.32 * intensity),
            color.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: Offset.zero, radius: e.width / 2)),
      );
      c.restore();
    }

    for (final cd in [scene.candle1, scene.candle2].whereType<_Item>()) {
      pool(cd.pos.withY(0.001), 2.2, const Color(0xFFFFAA55), cd.light);
    }
    pool(const _V3(0, 0.001, 0), 3, const Color(0xFFFFAA00), scene.fireLight);
  }

  /// Cuboid with its camera-facing faces shaded.
  void _box(Canvas c, _V3 center, _V3 half, Color color) {
    final x0 = center.x - half.x, x1 = center.x + half.x;
    final y0 = center.y - half.y, y1 = center.y + half.y;
    final z0 = center.z - half.z, z1 = center.z + half.z;
    Offset p(double x, double y, double z) => _Cam.pt(_V3(x, y, z));
    final base = _lit(color);
    final edge = _stroke(labShade(base, -0.5).withValues(alpha: 0.5), 1);
    void face(List<Offset> pts, Color fill) {
      final path = Path()..addPolygon(pts, true);
      c.drawPath(path, Paint()..color = fill);
      c.drawPath(path, edge);
    }

    const e = _Cam.eye;
    if (e.x < x0) face([p(x0, y0, z0), p(x0, y0, z1), p(x0, y1, z1), p(x0, y1, z0)], labShade(base, -0.28));
    if (e.x > x1) face([p(x1, y0, z0), p(x1, y0, z1), p(x1, y1, z1), p(x1, y1, z0)], labShade(base, -0.28));
    if (e.z > z1) face([p(x0, y0, z1), p(x1, y0, z1), p(x1, y1, z1), p(x0, y1, z1)], labShade(base, -0.12));
    if (e.y > y1) face([p(x0, y1, z0), p(x1, y1, z0), p(x1, y1, z1), p(x0, y1, z1)], labShade(base, 0.1));
  }

  /// Opaque upright cylinder / frustum.
  void _solid(Canvas c, _V3 base, double r, double y0, double y1, Color color, {double? rTop, bool top = true}) {
    final col = _lit(color);
    final eB = _Cam.ellipse(base.withY(y0), r);
    final eT = _Cam.ellipse(base.withY(y1), rTop ?? r);
    final body = _bodyPath(eT, eB);
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(col, -0.32),
          labShade(col, 0.2),
          col,
          labShade(col, -0.42),
        ], stops: const [0, 0.3, 0.62, 1]).createShader(body.getBounds()),
    );
    if (top) {
      c.drawOval(eT, Paint()..color = labShade(col, 0.1));
      c.drawOval(eT, _stroke(labShade(col, -0.3).withValues(alpha: 0.5), 1));
    }
  }

  // ------------------------------------------------------------- objects

  void _shadow(Canvas c, _V3 at, double r, {double opacity = 0.3}) {
    c.drawOval(_Cam.ellipse(_V3(at.x - 0.12, at.y + 0.001, at.z - 0.12), r), Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  void _item(Canvas c, _Item it) {
    if (scene.dragged == it) {
      labGlow(c, _Cam.pt(_anchor(it)), 0.7 * _Cam.k(it.pos), _Colors.zslYellow, intensity: 0.45);
    }
    switch (it.kind) {
      case _Kind.candle:
        _candle(c, it);
      case _Kind.matchbox:
        _matchbox(c, it);
      case _Kind.match:
        _match(c, it);
      case _Kind.tumbler:
        _tumbler(c, it);
      case _Kind.dropper:
        _dropper(c, it);
      case _Kind.bottle:
        _bottle(c, it);
      case _Kind.magnifier:
        _magnifier(c, it);
    }
  }

  /// HTML `createCandle`: wax 0.8 tall (r 0.22 -> 0.2), wick, sprite flame,
  /// glow and a warm point light.
  void _candle(Canvas c, _Item it) {
    final p = it.pos;
    _shadow(c, p, 0.3);
    const wax = Color(0xFFFFFDD0);
    _solid(c, p, 0.22, p.y, p.y + 0.8, wax, rTop: 0.2);
    final top = _Cam.ellipse(p.withY(p.y + 0.8), 0.2);
    c.drawOval(top.deflate(top.width * 0.12), Paint()..color = _lit(const Color(0xFFF5EFC0)));
    if (it.light > 0) {
      // Translucent wax glowing from the flame.
      c.drawOval(top.inflate(2), Paint()
        ..color = const Color(0xFFFFC46B).withValues(alpha: 0.35 * it.light)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    final wickA = _Cam.pt(p.withY(p.y + 0.8)), wickB = _Cam.pt(p.withY(p.y + 0.95));
    _rod(c, wickA, wickB, math.max(2.0, 0.03 * _Cam.k(p)), const Color(0xFF222222));
    if (it.flame > 0) {
      final k = _Cam.k(p);
      labGlow(c, _Cam.pt(p.withY(p.y + 1.1)), 0.75 * k * it.flame, const Color(0xFFFFAA00),
          intensity: 0.75 * math.max(it.light, it.flame));
      labFlame(c, wickB.translate(0, 2), 0.55 * k * it.flame, scene.time + p.x);
    }
  }

  /// HTML `createMatchbox`: black striker, tan drawer with matches (the red
  /// sleeve the HTML created but never added is drawn too).
  void _matchbox(Canvas c, _Item it) {
    final p = it.pos;
    _shadow(c, p.withY(p.y - 0.075), 0.42);
    _box(c, p, const _V3(0.21, 0.04, 0.25), const Color(0xFF222222));
    _box(c, p, const _V3(0.2, 0.075, 0.3), const Color(0xFFCC2222));
    _box(c, p + const _V3(0, -0.005, 0.37), const _V3(0.18, 0.065, 0.07), const Color(0xFFE6C280));
    final k = _Cam.k(p);
    for (var i = 0; i < 4; i++) {
      final x = p.x - 0.1 + i * 0.06;
      _rod(c, _Cam.pt(_V3(x, p.y + 0.06, p.z + 0.31)), _Cam.pt(_V3(x, p.y + 0.06, p.z + 0.42)),
          math.max(2.0, 0.024 * k), const Color(0xFFDEB887));
    }
  }

  /// HTML `createMatch`: stick along x, red head, burning flame.
  void _match(Canvas c, _Item it) {
    final p = it.pos;
    final k = _Cam.k(p);
    _rod(c, _Cam.pt(p + const _V3(-0.2, 0, 0)), _Cam.pt(p + const _V3(0.2, 0, 0)), math.max(2.5, 0.03 * k),
        const Color(0xFFDEB887));
    final head = _Cam.pt(p + const _V3(0.2, 0, 0));
    labSphere(c, head, math.max(3.0, 0.03 * k), const Color(0xFFCC0000));
    labGlow(c, head.translate(0, -0.1 * k), 0.4 * k, const Color(0xFFFFAA00), intensity: 0.7);
    labFlame(c, head.translate(0, -1), 0.36 * k, scene.time * 1.3);
  }

  /// HTML `createTumbler`: dark smoked glass, closed top, rim at the bottom.
  void _tumbler(Canvas c, _Item it) {
    final p = it.pos;
    final eB = _Cam.ellipse(p, 0.4), eT = _Cam.ellipse(p.withY(p.y + 1.4), 0.4);
    final body = _bodyPath(eT, eB);
    const glass = Color(0xFF1E293B);
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          glass.withValues(alpha: 0.62),
          glass.withValues(alpha: 0.32),
          glass.withValues(alpha: 0.26),
          glass.withValues(alpha: 0.58),
        ], stops: const [0, 0.3, 0.7, 1]).createShader(body.getBounds()),
    );
    c.drawOval(eT, Paint()..color = glass.withValues(alpha: 0.55));
    c.drawOval(eT, _stroke(Colors.white.withValues(alpha: 0.35), 1.2));
    c.drawPath(body, _stroke(const Color(0xFF94A3B8).withValues(alpha: 0.6), 1.2));
    c.drawArc(eB, 0, math.pi, false, _stroke(Colors.white.withValues(alpha: 0.45), 2.4));
    c.drawLine(
      Offset(eT.left + eT.width * 0.2, eT.center.dy + eT.height * 0.6),
      Offset(eB.left + eB.width * 0.2, eB.center.dy - 2),
      _stroke(Colors.white.withValues(alpha: 0.25), math.max(2.0, eT.width * 0.07)),
    );
  }

  /// HTML `createPetriDish`: dark glass dish with a lime water layer.
  void _dish(Canvas c, _Dish d) {
    final p = d.pos;
    _shadow(c, p, 0.66, opacity: 0.25);
    final eB = _Cam.ellipse(p, 0.6), eT = _Cam.ellipse(p.withY(0.05), 0.6);
    const glass = Color(0xFF1E293B);
    c.drawPath(_bodyPath(eT, eB), Paint()..color = glass.withValues(alpha: 0.7));
    c.drawOval(eT, Paint()..color = labShade(glass, 0.15).withValues(alpha: 0.55));
    if (d.opacity > 0) {
      c.drawOval(_Cam.ellipse(p.withY(0.04), 0.55), Paint()..color = d.liquid.withValues(alpha: d.opacity));
      c.drawOval(_Cam.ellipse(p.withY(0.04), 0.55).deflate(4), _stroke(Colors.white.withValues(alpha: 0.35 * d.opacity), 1));
    }
    c.drawOval(eT, _stroke(const Color(0xFF94A3B8).withValues(alpha: 0.85), 1.6));
  }

  /// HTML `createBottle`: clear glass, yellowish lime water, green label, cap.
  void _bottle(Canvas c, _Item it) {
    final p = it.pos;
    _shadow(c, p.withY(p.y - 0.3), 0.32);
    final eB = _Cam.ellipse(p.withY(p.y - 0.3), 0.25), eT = _Cam.ellipse(p.withY(p.y + 0.3), 0.25);
    final body = _bodyPath(eT, eB);
    c.drawPath(body, Paint()..color = Colors.white.withValues(alpha: 0.12));
    final lB = _Cam.ellipse(p.withY(p.y - 0.3), 0.23), lT = _Cam.ellipse(p.withY(p.y + 0.2), 0.23);
    c.drawPath(_bodyPath(lT, lB), Paint()..color = _lit(const Color(0xFFFFEE00)).withValues(alpha: 0.85));
    c.drawOval(lT, Paint()..color = _lit(const Color(0xFFFFF59D)).withValues(alpha: 0.9));
    _solid(c, p, 0.26, p.y - 0.2, p.y + 0.1, const Color(0xFF4ADE80), top: false);
    c.drawPath(body, _stroke(Colors.white.withValues(alpha: 0.5), 1.2));
    _solid(c, p, 0.2, p.y + 0.3, p.y + 0.45, const Color(0xFF222222));
  }

  /// HTML `createDropper`: tapered glass tube, yellow liquid, black bulb.
  void _dropper(Canvas c, _Item it) {
    final p = it.pos;
    final k = _Cam.k(p);
    final eT = _Cam.ellipse(p.withY(p.y + 0.2), 0.05), eB = _Cam.ellipse(p.withY(p.y - 0.2), 0.02);
    final body = _bodyPath(eT, eB);
    c.drawPath(body, Paint()..color = Colors.white.withValues(alpha: 0.2));
    final lT = _Cam.ellipse(p.withY(p.y + 0.05), 0.04), lB = _Cam.ellipse(p.withY(p.y - 0.15), 0.015);
    c.drawPath(_bodyPath(lT, lB), Paint()..color = _lit(const Color(0xFFFFEE00)).withValues(alpha: 0.9));
    c.drawPath(body, _stroke(Colors.white.withValues(alpha: 0.65), 1.2));
    labSphere(c, _Cam.pt(p.withY(p.y + 0.25)), math.max(5.0, 0.08 * k * it.bulb), _lit(const Color(0xFF333333)));
  }

  /// HTML `createMagnifier`: flat lens in a metal ring, handle towards +z.
  void _magnifier(Canvas c, _Item it) {
    final p = it.pos;
    final k = _Cam.k(p);
    if (p.y > 0.3) {
      c.drawOval(_Cam.ellipse(_V3(p.x - 0.3 * p.y, 0.002, p.z - 0.3 * p.y), 0.5), Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    final lens = _Cam.ellipse(p, 0.48);
    c.drawOval(
      lens,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            const Color(0xFFDBEAFE).withValues(alpha: 0.55),
            const Color(0xFF60A5FA).withValues(alpha: 0.35),
          ],
        ).createShader(lens),
    );
    final ring = _Cam.ellipse(p, 0.5);
    c.drawOval(ring, _stroke(_lit(const Color(0xFF334155)), math.max(4.0, 0.16 * k)));
    c.drawOval(ring, _stroke(_lit(const Color(0xFF94A3B8)), math.max(1.5, 0.05 * k)));
    c.drawArc(lens.deflate(lens.width * 0.15), math.pi * 1.1, 0.7, false,
        _stroke(Colors.white.withValues(alpha: 0.6), math.max(1.5, 0.03 * k)));
    _rod(c, _Cam.pt(p + const _V3(0, 0, 0.55)), _Cam.pt(p + const _V3(0, 0, 1.3)), math.max(5.0, 0.12 * k),
        _lit(const Color(0xFF222222)));
  }

  /// HTML `createPaper`: 2 x 2.5 sheet with a grid and a dark border,
  /// burn mark and shrinking while it burns (scale x, z -> 0).
  void _paper(Canvas c) {
    final s = scene.paperScale;
    if (s <= 0.01) return;
    _V3 at(double fx, double fz) => _V3(fx * s, 0.012, fz * 1.25 * s);
    final corners = [at(-1, -1), at(1, -1), at(1, 1), at(-1, 1)].map(_Cam.pt).toList();
    final sheet = Path()..addPolygon(corners, true);
    c.drawPath(sheet.shift(const Offset(2, 3)), Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    c.drawPath(sheet, Paint()..color = _lit(Colors.white));
    final grid = _stroke(_lit(const Color(0xFF94A3B8)), 1.2);
    for (var i = 1; i < 4; i++) {
      final f = -1 + i * 0.5;
      c.drawLine(_Cam.pt(at(f, -1)), _Cam.pt(at(f, 1)), grid);
      c.drawLine(_Cam.pt(at(-1, f)), _Cam.pt(at(1, f)), grid);
    }
    if (scene.burn > 0) {
      final e = _Cam.ellipse(const _V3(0, 0.013, 0), 0.42 * s);
      c.save();
      c.translate(e.center.dx, e.center.dy);
      c.scale(1, e.height / e.width * 1.25);
      c.drawCircle(
        Offset.zero,
        e.width / 2,
        Paint()
          ..shader = RadialGradient(colors: [
            Colors.black.withValues(alpha: scene.burn),
            const Color(0xFF442200).withValues(alpha: scene.burn),
            const Color(0x00442200),
          ], stops: const [0, 0.5, 1]).createShader(Rect.fromCircle(center: Offset.zero, radius: e.width / 2)),
      );
      c.restore();
    }
    c.drawPath(sheet, _stroke(scene.fire > 0 ? const Color(0xFFFF7A00) : _lit(const Color(0xFF334155)), 3.5));
  }

  // ------------------------------------------------------------- effects

  /// HTML light cones: sun -> lens (wide, faint) and lens -> paper
  /// (converging, brighter) plus the spot light's bright focus.
  void _cones(Canvas c) {
    const lensC = _V3(0, 1.5, 0);
    final lens = _Cam.ellipse(lensC, 0.48);
    const focus = _V3(0, 0.012, 0);
    final spot = _Cam.pt(focus);
    final spotR = math.max(2.0, 0.05 * _Cam.k(focus));
    const warm = Color(0xFFFFFBEB);

    // Top cone towards the sun.
    final from = lens.center;
    final dir = _skySun - from;
    final len = dir.distance;
    final u = dir / len;
    final n = Offset(-u.dy, u.dx);
    final a = lens.width / 2;
    final far = from + u * (len + 400);
    final top = Path()
      ..moveTo(from.dx + n.dx * a, from.dy + n.dy * a)
      ..lineTo(far.dx + n.dx * a * 4, far.dy + n.dy * a * 4)
      ..lineTo(far.dx - n.dx * a * 4, far.dy - n.dy * a * 4)
      ..lineTo(from.dx - n.dx * a, from.dy - n.dy * a)
      ..close();
    c.drawPath(
      top,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment(-u.dx, -u.dy),
          end: Alignment(u.dx, u.dy),
          colors: [warm.withValues(alpha: 0.2), warm.withValues(alpha: 0.05)],
        ).createShader(top.getBounds()),
    );

    // Bottom cone: lens (r 0.48) converging to a 0.05 spot on the paper.
    final bottom = Path()
      ..moveTo(lens.left, lens.center.dy)
      ..arcTo(lens, math.pi, -math.pi, false)
      ..lineTo(spot.dx + spotR, spot.dy)
      ..lineTo(spot.dx - spotR, spot.dy)
      ..close();
    c.drawPath(
      bottom,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [warm.withValues(alpha: 0.22), warm.withValues(alpha: 0.5)],
        ).createShader(bottom.getBounds()),
    );
    final pulse = 0.85 + 0.15 * math.sin(scene.time * 9);
    labGlow(c, spot, 0.45 * _Cam.k(focus) * pulse, const Color(0xFFFFF7AE), intensity: 1);
    c.drawCircle(spot, spotR * 1.6, Paint()..color = Colors.white);
  }

  /// Paper fire (HTML flame sprite at (0, 0.5, 0) + glow + fire light).
  void _fire(Canvas c) {
    final f = scene.fire;
    final base = _Cam.pt(const _V3(0, 0.02, 0));
    final k = _Cam.k(const _V3(0, 0.5, 0));
    labGlow(c, base.translate(0, -0.7 * k), (scene.fireGlow ? 1.5 : 1.0) * k * f, const Color(0xFFFFAA00),
        intensity: (scene.fireGlow ? 0.85 : 0.55) * f);
    final h = scene.fireH * 0.85 * k * f;
    final ps = scene.paperScale;
    if (ps > 0.15) {
      for (final (dx, dz, hh, ph) in const [
        (-0.55, -0.5, 0.55, 1.3),
        (0.5, -0.45, 0.62, 2.1),
        (-0.42, 0.55, 0.5, 3.7),
        (0.45, 0.52, 0.58, 4.4),
      ]) {
        labFlame(c, _Cam.pt(_V3(dx * ps, 0.02, dz * 1.25 * ps)), h * hh * ps.clamp(0.5, 1.0), scene.time + ph);
      }
    }
    labFlame(c, base.translate(-0.18 * k * f, 0), h * 0.7, scene.time + 0.7);
    labFlame(c, base.translate(0.2 * k * f, 0), h * 0.75, scene.time + 1.9);
    labFlame(c, base, h, scene.time);
  }

  void _puff(Canvas c, _Puff p) {
    if (p.opacity <= 0) return;
    final o = _Cam.pt(p.pos);
    final r = 0.5 * p.size * _Cam.k(p.pos);
    for (final (dx, dy, rr) in const [(0.0, 0.0, 1.0), (-0.35, 0.15, 0.7), (0.35, 0.1, 0.75), (0.0, -0.3, 0.65)]) {
      final cc = o + Offset(dx * r, dy * r);
      c.drawCircle(
        cc,
        r * rr,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFC8C8C8).withValues(alpha: 0.5 * p.opacity),
            const Color(0x00C8C8C8),
          ]).createShader(Rect.fromCircle(center: cc, radius: r * rr)),
      );
    }
  }

  // -------------------------------------------------------------- labels

  /// HTML text sprites: dark rounded panel, yellow border, white bold text.
  void _labels(Canvas c) {
    void label(String key, _V3 at, {double scale = 1, double opacity = 1}) {
      if (opacity <= 0.02) return;
      final f = (_Cam.k(at) / 80).clamp(0.92, 1.12) * scale;
      labText(
        c,
        tr(key),
        _Cam.pt(at),
        size: 15.5 * f,
        color: Colors.white,
        weight: FontWeight.w800,
        background: const Color(0xD90F172A),
        border: _Colors.zslYellow,
        borderWidth: 2,
        radius: 8,
        maxWidth: 300,
        padding: EdgeInsets.symmetric(horizontal: 10 * f, vertical: 4 * f),
        opacity: opacity,
      );
    }

    label('lbl_tray', const _V3(0, 0.15, 4.26), scale: 0.8);
    for (final d in [scene.dish1, scene.dish2].whereType<_Dish>()) {
      label('lbl_petri', d.pos + const _V3(0, 0.4, 0));
    }
    final mag = scene.magnifier;
    final held = mag != null && mag.pos.y > 1;
    if (scene.paper && scene.paperScale > 0.05 && !held && scene.fire <= 0) {
      final s = scene.paperScale;
      label('lbl_paper', _V3(0, 0.01 + 1.5 * s, 0), scale: s.clamp(0.4, 1.0), opacity: s);
    }
    for (final it in scene.items) {
      // Label heights follow the HTML sprites, nudged where two would
      // overlap on this stage (candles still on the tray, tumbler over a
      // candle).
      final overCandle = it.kind == _Kind.tumbler &&
          [scene.candle1, scene.candle2].any((c) => c != null && (c.pos.x - it.pos.x).abs() < 0.3 && (c.pos.z - it.pos.z).abs() < 0.3);
      final (key, dy) = switch (it.kind) {
        _Kind.candle => ('lbl_candle', it.placed ? 1.8 : 1.15),
        _Kind.tumbler => ('lbl_tumbler', overCandle ? 2.25 : 1.6),
        // Below the box while the lit match hovers right where it would be.
        _Kind.matchbox => ('lbl_matchbox', scene.match != null && scene.match!.pos.dist(it.pos) < 1 ? -0.35 : 0.5),
        _Kind.dropper => ('lbl_dropper', 0.6),
        _Kind.bottle => ('lbl_bottle', 0.8),
        _Kind.magnifier => ('lbl_magnifier', 0.6),
        _Kind.match => ('', 0.0),
      };
      if (key.isNotEmpty) label(key, it.pos + _V3(0, dy, 0));
    }
    for (final s in scene.sprites) {
      final lift = held && (s.pos.x - mag.pos.x).abs() < 1 ? 0.55 : 0.0;
      label(s.key, s.pos + _V3(0, lift, 0), opacity: ((scene.time - s.born) / 0.3).clamp(0.0, 1.0));
    }
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) => true;
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
