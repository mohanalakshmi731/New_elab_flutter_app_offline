// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode, mapEquals;
import 'package:flutter/gestures.dart' show DeviceGestureSettings, DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 3 • Activity 5
/// Circuit Diagrams and Symbols.
///
/// Native Flutter port of `Cl7S-Ch3-A5-Circuit_Diagrams_and_Symbols.html`.
/// A 3D Bench (place parts from the tray, drag wires between terminals,
/// flip the safety-pin switch, test LED polarity) and a 2D Canvas (drag the
/// matching schematic symbols from the palette and tap them to draw wires).
class Ch3A5CircuitDiagramsAndSymbolsPage extends StatefulWidget {
  const Ch3A5CircuitDiagramsAndSymbolsPage({super.key});

  @override
  State<Ch3A5CircuitDiagramsAndSymbolsPage> createState() => _Ch3A5CircuitDiagramsAndSymbolsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, switchTap 2585.
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
  static const Color slate50 = Color(0xFFF8FAFC);
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

enum _Hud { info, success, error }

class _Ch3A5CircuitDiagramsAndSymbolsPageState extends State<Ch3A5CircuitDiagramsAndSymbolsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A5Scene _scene = _A5Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// HUD (HTML `showHUD`): i18n key ('@desc' = current step text) + type.
  String _hudKey = '@desc';
  _Hud _hudType = _Hud.info;
  int _hudSerial = 0;

  /// Component tray (HTML `buildTrayUI`): null = cleared.
  String? _trayMode;
  List<String> _trayItems = const [];

  /// Guards the HTML `autoAdvanceStep` timer against double scheduling.
  bool _advancing = false;
  Offset _pointer = Offset.zero;
  Offset _grab = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];
  _StepRule get _rule => _rules[_scene.scenario][_scene.step];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _loadScenario(0, notify: false);
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

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    final s = _scene;
    s.time = elapsed.inMicroseconds / 1e6;
    final arm = s.switchOn ? 1.0 : 0.0;
    s.arm += (arm - s.arm) * math.min(1, dt * 20);
    _frame.value = s.time;
  }

  // ------------------------------------------------------------- flow

  void _hud(String key, _Hud type) {
    _hudKey = key;
    _hudType = type;
    _hudSerial++;
  }

  void _tray(String? mode, [List<String> items = const []]) {
    _trayMode = mode;
    _trayItems = items;
  }

  /// HTML `loadScenario`.
  void _loadScenario(int idx, {bool notify = true}) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.reset(idx);
    _advancing = false;
    _lab.resetView(sound: false);
    _loadStep(0);
    if (notify) setState(() {});
  }

  /// HTML `loadStep`.
  void _loadStep(int idx) {
    final s = _scene;
    s.step = idx;
    _advancing = false;
    if (s.scenario == 1 && (idx == 1 || idx == 2)) {
      s.clearWires();
      // The HTML leaves the LED glowing with no wires; it goes dark here.
      s.ledOn = false;
    }
    final rule = _rule;
    if (s.is3D == rule.is2D) {
      if (rule.is2D) {
        _hud('hudToggle2D', _Hud.info);
        _tray(null);
      } else {
        _tray('2d', _items2D[s.scenario]);
        _hud('hud2DExplore', _Hud.info);
      }
    } else {
      _setupStepContent(idx);
      _hud('@desc', _Hud.info);
    }
    // Step 6 of scenario 2 says the circuit "will be validated" once the
    // diagram is correct: validate the existing battery-LED wire.
    if (s.scenario == 1 && idx == 5) {
      _lab.after(const Duration(milliseconds: 1200), () {
        if (!mounted || s.step != 5 || s.completed || s.scenario != 1) return;
        if (_hasBatteryLed()) {
          _Audio.play(_Sound.correct);
          setState(() => _autoAdvance('hudCircuitValidated'));
        }
      });
    }
  }

  /// HTML `setupStepContent`.
  void _setupStepContent(int idx) {
    final rule = _rule;
    if (_scene.scenario == 0) {
      if (idx == 0) _tray('3d', rule.items);
      if (idx == 1 || idx == 2 || idx == 5) _tray(null);
      if (idx == 3 || idx == 4) _tray('2d', rule.items);
    } else {
      if (idx == 0) _tray('3d', rule.items);
      if (idx == 1 || idx == 2 || idx >= 4) _tray(null);
      if (idx == 3) _tray('2d', rule.items);
    }
  }

  /// HTML `switchView`.
  void _switchView(bool to3D) {
    final s = _scene;
    if (s.is3D == to3D) return;
    _Audio.play(_Sound.click);
    setState(() {
      s.is3D = to3D;
      s.wireFrom = null;
      s.wireTo = null;
      s.draggingNode = null;
      if (!to3D) _lab.resetView(sound: false);
      if (s.completed) {
        _tray(null);
        _hud('hudScenarioComplete', _Hud.success);
        return;
      }
      final rule = _rule;
      if (!to3D) {
        _tray('2d', _items2D[s.scenario]);
        _hud(rule.is2D ? '@desc' : 'hud2DExplore', _Hud.info);
      } else if (!rule.is2D) {
        _setupStepContent(s.step);
        _hud('@desc', _Hud.info);
      } else {
        _tray(null);
        _hud('hudToggle3D', _Hud.info);
      }
    });
  }

  /// HTML `autoAdvanceStep`: success HUD, then the next step after 2.5 s or,
  /// on the last step, the check-mark burst and the observation popup.
  void _autoAdvance(String msgKey) {
    _hud(msgKey, _Hud.success);
    if (_advancing) return;
    _advancing = true;
    final s = _scene;
    final last = s.step == 5;
    if (last) {
      s.successAt = s.time;
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          s.successAt = -1;
          s.completed = true;
          _hud('hudScenarioComplete', _Hud.success);
          if (s.scenario == 1) s.ledFlash = true;
        });
        _Audio.play(_Sound.success);
        _lab.showScenarioConclusion(
          scenarioIndex: s.scenario,
          totalScenarios: 2,
          title: () => _t('keyObs'),
          body: () => _t(s.scenario == 0 ? 'sc1Obs' : 'sc2Obs'),
          delay: const Duration(milliseconds: 1000),
        );
      });
    } else {
      _lab.after(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        _Audio.play(_Sound.click);
        setState(() => _loadStep(s.step + 1));
      });
    }
  }

  // ------------------------------------------------------- 3D bench

  /// HTML `placeItem3D`.
  void _placeItem3D(String item) {
    final s = _scene;
    if (s.placed3D.contains(item)) return;
    _Audio.play(_Sound.drop);
    setState(() {
      s.placed3D.add(item);
      s.placedAt[item] = s.time;
      final rule = _rule;
      if (rule.reqCount > 0 && !rule.is2D && s.placed3D.length == rule.reqCount) {
        _Audio.play(_Sound.correct);
        _autoAdvance('hudPhysicalPlaced');
      }
    });
  }

  bool get _wiringAllowed {
    final s = _scene;
    return !s.completed && ((s.scenario == 0 && s.step == 1) || (s.scenario == 1 && (s.step == 1 || s.step == 2)));
  }

  /// Nearest placed terminal under [p] (hit sphere r = 1.5 like the HTML).
  _Term? _termAt(Offset p, {_Term? except}) {
    _Term? best;
    var bestD = double.infinity;
    for (final t in _terms) {
      if (!_scene.placed3D.contains(t.part) || identical(t, except)) continue;
      final w = _scene.termPos(t);
      final d = (_cam.project(w) - p).distance;
      if (d < 1.5 * _cam.scaleAt(w) && d < bestD) {
        best = t;
        bestD = d;
      }
    }
    return best;
  }

  /// Switch hit box (5 x 1.5 x 2.5) of Scenario 1.
  bool _switchAt(Offset p) {
    if (_scene.scenario != 0 || !_scene.placed3D.contains('switch')) return false;
    final c = _scene.partPos('switch');
    for (final y in const [0.75, 1.5]) {
      final w = _cam.onPlane(p, y);
      if (w != null && (w.x - c.x).abs() < 2.5 && (w.z - c.z).abs() < 1.25) return true;
    }
    return false;
  }

  /// Removes the wire on [t] (HTML: pointerdown on a wired terminal).
  void _removeWireAt(_Term t) {
    final s = _scene;
    final i = s.wires.indexWhere((w) => identical(w.$1, t) || identical(w.$2, t));
    if (i < 0) return;
    s.wires.removeAt(i);
    _Audio.play(_Sound.click);
    if (s.scenario == 1) {
      s.ledOn = false;
      s.ledX = false;
    }
  }

  void _benchDown(Offset p, {required bool drag}) {
    final s = _scene;
    final t = _termAt(p);
    if (t != null) {
      if (!_wiringAllowed) return;
      setState(() {
        if (s.connected(t)) {
          _removeWireAt(t);
          return;
        }
        _Audio.play(_Sound.click);
        if (drag) {
          s.wireFrom = t;
          s.wireTo = s.termPos(t);
        } else {
          // Released on the same terminal: no target (HTML error tone).
          _Audio.play(_Sound.wrong);
        }
      });
      return;
    }
    if (_switchAt(p) && (s.step == 2 || s.completed)) _toggleSwitch();
  }

  void _benchMove(Offset p) {
    final s = _scene;
    final from = s.wireFrom;
    if (from == null) return;
    s.wireTo = _cam.onPlane(p, s.termPos(from).y) ?? s.wireTo;
  }

  void _benchUp() {
    final s = _scene;
    final from = s.wireFrom;
    if (from == null) return;
    final target = _termAt(_pointer, except: from);
    setState(() {
      s.wireFrom = null;
      s.wireTo = null;
      if (target == null || target.part == from.part) {
        _Audio.play(_Sound.wrong);
        return;
      }
      s.wires.add((from, target));
      _Audio.play(_Sound.drop);
      if (s.scenario == 1) {
        _checkPolarity();
      } else {
        _checkWiring();
      }
    });
  }

  /// HTML `toggleSwitch` (Scenario 1 safety-pin switch).
  void _toggleSwitch() {
    final s = _scene;
    setState(() {
      s.switchOn = !s.switchOn;
      _Audio.play(_Sound.switchTap);
      if (s.switchOn) {
        _Audio.play(_Sound.correct);
        if (!s.completed) {
          _autoAdvance('hudSwitchClosed');
        } else {
          _hud('hudSwitchClosed', _Hud.success);
        }
      } else if (s.completed) {
        _hud('hudSwitchOpened', _Hud.info);
      }
    });
  }

  /// HTML `check3DWiringState`: every part needs two wire ends.
  void _checkWiring() {
    final s = _scene;
    if (s.scenario != 0 || s.wires.length < 3) return;
    int ends(String part) => s.wires.where((w) => w.$1.part == part || w.$2.part == part).length;
    if (ends('cell') >= 2 && ends('switch') >= 2 && ends('lamp') >= 2) {
      _Audio.play(_Sound.correct);
      _autoAdvance('hudCircuitSeries');
    }
  }

  /// HTML `check3DPolarityState` (Scenario 2 battery + LED).
  void _checkPolarity() {
    final s = _scene;
    if (s.wires.length < 2) return;
    var posPos = false, negNeg = false, posNeg = false, negPos = false;
    for (final (a, b) in s.wires) {
      final bat = a.part == 'battery' ? a : (b.part == 'battery' ? b : null);
      final led = a.part == 'led' ? a : (b.part == 'led' ? b : null);
      if (bat == null || led == null) continue;
      if (bat.id == 'pos' && led.id == 'pos') posPos = true;
      if (bat.id == 'neg' && led.id == 'neg') negNeg = true;
      if (bat.id == 'pos' && led.id == 'neg') posNeg = true;
      if (bat.id == 'neg' && led.id == 'pos') negPos = true;
    }
    if (s.step == 1) {
      if (posPos && negNeg) {
        s.ledOn = true;
        s.ledX = false;
        _Audio.play(_Sound.correct);
        _autoAdvance('hudLEDGlows');
      } else {
        _Audio.play(_Sound.wrong);
        _hud('hudLEDWrong1', _Hud.error);
        s.clearWires();
        s.ledOn = false;
      }
    } else if (s.step == 2) {
      if (posNeg && negPos) {
        s.ledOn = false;
        s.ledX = true;
        _Audio.play(_Sound.correct);
        _autoAdvance('hudLEDOFF');
      } else {
        _Audio.play(_Sound.wrong);
        _hud('hudLEDWrong2', _Hud.error);
        s.clearWires();
      }
    }
  }

  // ------------------------------------------------------- 2D canvas

  String? _nodeAt(Offset p) {
    final s = _scene;
    final keys = s.nodes.keys.toList().reversed;
    for (final k in keys) {
      if (Rect.fromCenter(center: s.nodes[k]!, width: _nodeSize, height: _nodeSize).contains(p)) return k;
    }
    return null;
  }

  bool get _canConnect {
    final s = _scene;
    return (s.scenario == 0 && s.step >= 5) || (s.scenario == 1 && s.step >= 4);
  }

  void _nodeTap(String type) {
    final s = _scene;
    if (s.completed) return;
    setState(() {
      if (!_canConnect) {
        _hud('hudPlaceSymbols', _Hud.info);
        return;
      }
      _Audio.play(_Sound.click);
      final sel = s.selected;
      if (sel == null) {
        s.selected = type;
        return;
      }
      if (sel != type) {
        _add2DWire(sel, type);
        _Audio.play(_Sound.drop);
        if (s.scenario == 1) {
          _check2DPolarity();
        } else {
          _check2DWiring();
        }
      }
      s.selected = null;
    });
  }

  /// HTML `add2DWire`: tapping an existing pair removes that wire.
  void _add2DWire(String a, String b) {
    final s = _scene;
    final i = s.conns.indexWhere((c) => (c.$1 == a && c.$2 == b) || (c.$1 == b && c.$2 == a));
    if (i >= 0) {
      s.conns.removeAt(i);
      _Audio.play(_Sound.click);
      return;
    }
    s.conns.add((a, b));
  }

  void _check2DWiring() {
    final s = _scene;
    if (s.scenario != 0) return;
    final used = {for (final c in s.conns) ...[c.$1, c.$2]};
    if (s.conns.length >= 3 && used.containsAll(const ['cell', 'switchON', 'lamp'])) {
      _Audio.play(_Sound.correct);
      _autoAdvance('hudSchematicMapped');
    } else if (s.conns.length == 2 && used.length == 3) {
      _hud('hudGreatRemaining', _Hud.info);
    }
  }

  bool _hasBatteryLed() => _scene.conns.any((c) => {c.$1, c.$2}.containsAll(const ['battery', 'led']));

  void _check2DPolarity() {
    final s = _scene;
    if (s.scenario != 1 || s.conns.isEmpty) return;
    if (_hasBatteryLed()) {
      _Audio.play(_Sound.correct);
      s.ledPulse = true;
      _autoAdvance('hudCircuitValidated');
    }
  }

  /// HTML `end2DDrag`: a symbol dropped from the palette at design point [p].
  void _dropSymbol(String item, Offset p) {
    final s = _scene;
    if (s.is3D) return;
    final rule = _rule;
    final allowed = rule.allowed ?? _items2D[s.scenario];
    setState(() {
      if (!allowed.contains(item)) {
        s.rejectAt = p;
        s.rejectUntil = s.time + 0.4;
        _Audio.play(_Sound.wrong);
        _hud('hudIncorrectSym', _Hud.error);
        return;
      }
      s.placed2D.add(item);
      s.nodes.remove(item);
      s.nodes[item] = Offset(p.dx.clamp(220.0, 880.0), p.dy.clamp(84.0, 437.0));
      _Audio.play(_Sound.drop);
      if (rule.is2D && rule.reqCount > 0 && s.placed2D.length == rule.reqCount && !s.completed) {
        _autoAdvance('hudMappedCanvas');
      }
      _tray('2d', rule.is2D && rule.items.isNotEmpty ? rule.items : _items2D[s.scenario]);
    });
  }

  // -------------------------------------------------------- gestures

  void _onTap(Offset p) {
    _pointer = p;
    if (_scene.is3D) {
      _benchDown(p, drag: false);
    } else {
      final n = _nodeAt(p);
      if (n != null) _nodeTap(n);
    }
  }

  void _onPanStart(Offset p) {
    _pointer = p;
    final s = _scene;
    if (s.is3D) {
      _benchDown(p, drag: true);
      return;
    }
    final n = _nodeAt(p);
    if (n == null) return;
    _grab = p - s.nodes[n]!;
    setState(() => s.draggingNode = n);
  }

  void _onPanUpdate(Offset p) {
    _pointer = p;
    final s = _scene;
    if (s.is3D) {
      _benchMove(p);
      return;
    }
    final n = s.draggingNode;
    if (n == null) return;
    final q = p - _grab;
    s.nodes[n] = Offset(q.dx.clamp(200.0, 900.0), q.dy.clamp(84.0, 448.0));
  }

  void _onPanEnd() {
    final s = _scene;
    if (s.is3D) {
      _benchUp();
    } else if (s.draggingNode != null) {
      setState(() => s.draggingNode = null);
    }
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final inset = labOverlayInsets(context, _lab);
        final sc = _scene;
        final rule = _rule;
        final needs2D = !sc.completed && rule.is2D && sc.is3D;
        final needs3D = !sc.completed && !rule.is2D && !sc.is3D;
        return LabShell(
          controller: _lab,
          icon: Icons.developer_board,
          title: _t('appTitle'),
          subtitle: _t('appSubtitle'),
          scenarioNames: [_t('sc1Title'), _t('sc2Title')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _loadScenario,
          objective: _data.objective,
          steps: _data.steps,
          currentStep: sc.step + 1,
          instruction: sc.completed ? _t('hudScenarioComplete') : null,
          actions: [
            if (needs2D)
              LabAction(
                label: _t('btn2DCanvas'),
                icon: Icons.polyline,
                highlight: true,
                silent: true,
                onTap: () => _switchView(false),
              ),
            if (needs3D)
              LabAction(
                label: _t('btn3DBench'),
                icon: Icons.view_in_ar,
                highlight: true,
                silent: true,
                onTap: () => _switchView(true),
              ),
          ],
          onReset: () => _loadScenario(0),
          showHud: false,
          showTools: sc.is3D,
          overlays: [
            if (sc.scenario == 0 && sc.step == 1 && sc.is3D && !sc.completed) _reference(s, inset),
            if (_trayMode != null) _trayPanel(p, s, inset),
            if (!sc.is3D && sc.successAt >= 0) _successBurst(s),
            _viewToggle(p, s, inset, needs2D: needs2D, needs3D: needs3D),
            _hudPanel(p, s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: DragTarget<String>(
              onWillAcceptWithDetails: (_) => !_scene.is3D,
              onAcceptWithDetails: (d) {
                final local = labGlobalToLocal(_stageKey, d.offset);
                if (local != null) _dropSymbol(d.data, local);
              },
              builder: (context, candidates, rejected) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  gestureSettings: const DeviceGestureSettings(touchSlop: 8),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  dragStartBehavior: DragStartBehavior.down,
                  onTapUp: (d) => _onTap(d.localPosition),
                  onPanStart: (d) => _onPanStart(d.localPosition),
                  onPanUpdate: (d) => _onPanUpdate(d.localPosition),
                  onPanEnd: (_) => _onPanEnd(),
                  onPanCancel: _onPanEnd,
                  child: CustomPaint(
                    key: _stageKey,
                    size: _design,
                    painter: sc.is3D
                        ? _BenchPainter(
                            scene: sc,
                            repaint: _frame,
                            isDark: _lab.isDark,
                            showLabels: _lab.showLabels,
                            labels: {for (final e in _labels3D.entries) e.key: _t(e.value.$1)},
                          )
                        : _SchematicPainter(
                            scene: sc,
                            repaint: _frame,
                            isDark: _lab.isDark,
                            title: _t('canvasTitle'),
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

  /// HTML view-mode pill: "3D Bench" / "2D Canvas"; the one the current
  /// step needs pulses.
  Widget _viewToggle(LabPalette p, double s, EdgeInsets inset, {required bool needs2D, required bool needs3D}) {
    Widget btn(IconData icon, String label, bool active, bool pulse, VoidCallback onTap) {
      final b = Material(
        color: active ? _Colors.zslYellow : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15 * s, color: active ? Colors.black : p.textMuted),
                SizedBox(width: 5 * s),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.black : p.textMuted,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12 * s,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return _Pulse(active: pulse, scale: s, child: b);
    }

    return Positioned(
      top: inset.top,
      left: inset.left,
      right: inset.right,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: LabGlassCard(
            palette: p,
            radius: 999,
            padding: EdgeInsets.all(4 * s),
            borderColor: _Colors.zslYellow.withValues(alpha: 0.3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                btn(Icons.view_in_ar, _t('btn3DBench'), _scene.is3D, needs3D, () => _switchView(true)),
                SizedBox(width: 4 * s),
                btn(Icons.polyline, _t('btn2DCanvas'), !_scene.is3D, needs2D, () => _switchView(false)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML component tray (left side of the canvas).
  Widget _trayPanel(LabPalette p, double s, EdgeInsets inset) {
    final is3D = _trayMode == '3d';
    return Positioned(
      left: inset.left + 2,
      top: inset.top + 48 * s,
      bottom: inset.bottom + 70 * s,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 80 * s,
          padding: EdgeInsets.all(6 * s),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0x80000000) : const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 5 * s),
                  margin: EdgeInsets.only(bottom: 6 * s),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
                  child: Text(
                    _t('tray').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w800, fontSize: 9.5 * s, letterSpacing: 1),
                  ),
                ),
                if (_trayItems.isEmpty)
                  Text(
                    _t('noItems'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.textMuted, fontSize: 9 * s),
                  )
                else
                  for (final item in _trayItems) ...[
                    _trayItem(item, is3D, p, s),
                    SizedBox(height: 6 * s),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trayItem(String item, bool is3D, LabPalette p, double s) {
    final placed = is3D ? _scene.placed3D.contains(item) : _scene.placed2D.contains(item);
    final icon = is3D
        ? Icon(
            item == 'cell' || item == 'battery'
                ? Icons.battery_charging_full
                : (item == 'lamp' || item == 'led' ? Icons.lightbulb : Icons.toggle_off),
            size: 24 * s,
            color: _Colors.zslYellow,
          )
        : SizedBox(
            width: 32 * s,
            height: 32 * s,
            child: CustomPaint(painter: _SymbolIconPainter(item, p.textStrong)),
          );
    final box = Container(
      padding: EdgeInsets.symmetric(vertical: 6 * s, horizontal: 3 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: placed ? Colors.transparent : p.border),
        boxShadow: placed ? null : const [BoxShadow(color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: 3 * s),
          Text(
            _t(item).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 8.5 * s),
          ),
        ],
      ),
    );
    final shown = placed
        ? Opacity(
            opacity: 0.4,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0, //
              ]),
              child: box,
            ),
          )
        : box;
    if (is3D) {
      return GestureDetector(onTap: placed ? null : () => _placeItem3D(item), child: shown);
    }
    return Draggable<String>(
      data: item,
      maxSimultaneousDrags: placed ? 0 : 1,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _Audio.play(_Sound.click),
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(
          opacity: 0.85,
          child: Container(
            width: 60 * s,
            height: 60 * s,
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Colors.zslYellow, width: 2),
              boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 25, offset: Offset(0, 10))],
            ),
            child: CustomPaint(painter: _SymbolIconPainter(item, const Color(0xFF0F172A))),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: box),
      child: shown,
    );
  }

  /// HTML `#reference-overlay` (Fig 3.12a), shown while wiring scenario 1.
  /// The HTML pins it top-right, over the lamp; it sits on the left here,
  /// where the (empty during wiring) tray would be.
  Widget _reference(double s, EdgeInsets inset) {
    return Positioned(
      top: inset.top + 50 * s,
      left: inset.left + 4,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 0.85),
          duration: const Duration(milliseconds: 500),
          builder: (context, v, child) => Opacity(opacity: v, child: child),
          child: Container(
            width: 132 * s,
            padding: EdgeInsets.all(6 * s),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _Colors.slate300, width: 2),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 25, offset: Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 3 * s),
                  margin: EdgeInsets.only(bottom: 4 * s),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _Colors.slate200))),
                  child: Text(
                    _t('figRef'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: const Color(0xFF1F2937), fontWeight: FontWeight.w800, fontSize: 9.5 * s),
                  ),
                ),
                AspectRatio(aspectRatio: 100 / 60, child: CustomPaint(painter: _ReferencePainter())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#success-overlay` check-mark burst on the 2D canvas.
  Widget _successBurst(double s) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_scene.successAt),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, v, child) => Opacity(
              opacity: v.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.5 + 0.5 * Curves.easeOutBack.transform(v), child: child),
            ),
            child: Icon(
              Icons.check_circle,
              size: 128 * s,
              color: _Colors.green,
              shadows: const [Shadow(color: Color(0x8022C55E), blurRadius: 20)],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML bottom HUD: status icon (info / success / error), "Current Task"
  /// and the message.
  Widget _hudPanel(LabPalette p, double s, EdgeInsets inset) {
    final msg = _hudKey == '@desc' ? _data.steps[_scene.step].action : _t(_hudKey);
    final (Color col, IconData icon) = switch (_hudType) {
      _Hud.success => (const Color(0xFF4ADE80), Icons.check),
      _Hud.error => (const Color(0xFFF87171), Icons.warning_amber_rounded),
      _Hud.info => (const Color(0xFF60A5FA), Icons.info),
    };
    final base = switch (_hudType) {
      _Hud.success => _Colors.green,
      _Hud.error => _Colors.red,
      _Hud.info => _Colors.blue,
    };
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: inset.bottom,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 512 * s),
            child: LabGlassCard(
              palette: p,
              padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
              borderColor: _Colors.zslYellow.withValues(alpha: 0.5),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_hudSerial),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 450),
                    builder: (context, v, child) {
                      final dx = _hudType == _Hud.error ? math.sin(v * math.pi * 6) * (1 - v) * 5 * s : 0.0;
                      final sc = _hudType == _Hud.success ? 0.8 + 0.3 * Curves.easeOutBack.transform(v) : 1.0;
                      return Transform.translate(offset: Offset(dx, 0), child: Transform.scale(scale: sc, child: child));
                    },
                    child: Container(
                      width: 32 * s,
                      height: 32 * s,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: base.withValues(alpha: 0.2)),
                      child: Icon(icon, size: 19 * s, color: col),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('currTask').toUpperCase(),
                          style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w800, fontSize: 9 * s, letterSpacing: 0.8),
                        ),
                        SizedBox(height: 1 * s),
                        Text(
                          msg,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w600, fontSize: 11.5 * f, height: 1.3),
                        ),
                      ],
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

/// HTML `animate-pulse-fast` + `ring-4 ring-yellow-500` on the view button
/// the current step requires.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.active, required this.scale, required this.child});

  final bool active;
  final double scale;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Pulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = 0.5 - 0.5 * math.cos(_c.value * 2 * math.pi);
        return Transform.scale(
          scale: 1 + 0.1 * v,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _Colors.zslYellow, width: 3 * widget.scale),
              boxShadow: [
                BoxShadow(
                  color: _Colors.zslYellow.withValues(alpha: 0.8 - 0.4 * v),
                  blurRadius: (15 - 10 * v) * widget.scale,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ============================================================ STRINGS
//
// Copied verbatim from `Cl7S-Ch3-A5-Circuit_Diagrams_and_Symbols.html`
// (EN + HI). Strings the HTML hard-coded in English only ('hud2DExplore',
// 'hudGreatRemaining', 'canvasTitle') have new Hindi translations.

const LabStringTable _i18n = {
  'en': {
    'appTitle': 'Circuit Diagrams and Symbols',
    'appSubtitle': 'Class 7 • Electricity: Circuits and their Components',
    'btn3DBench': '3D Bench',
    'btn2DCanvas': '2D Canvas',
    'tray': 'Tray',
    'currTask': 'Current Task',
    'figRef': 'Fig 3.12a Reference',
    'keyObs': 'Key Observation',
    'noItems': 'No items needed.',
    'hudScenarioComplete': 'Scenario Completed! Feel free to explore the 3D Bench and 2D Canvas.',
    'hudPlaceSymbols': 'Place all required symbols on canvas first!',
    'hudTapSeq1': 'Tap one symbol, then tap another to connect them with a wire.',
    'hudTapSeq2': 'Tap the Battery, then tap the LED to automatically complete the circuit.',
    'hudIncorrectSym': 'Incorrect symbol for this step!',
    'hudMappedCanvas': 'Symbols successfully mapped to canvas.',
    'hudPhysicalPlaced': 'All physical components placed on the workbench.',
    'hudCircuitSeries': 'Circuit wired completely in series!',
    'hudLEDGlows': 'LED glows! Current flows from positive to negative.',
    'hudLEDWrong1': 'Incorrect! Connect Positive (+) to Long Leg, Negative (-) to Short Leg.',
    'hudLEDOFF': 'LED does NOT glow. Current blocked in reverse.',
    'hudLEDWrong2': 'Incorrect! Connect Positive (+) to Short Leg to reverse it.',
    'hudSchematicMapped': 'Schematic Blueprint mapped correctly!',
    'hudCircuitValidated': 'Circuit Diagram Validated! Schematic complete.',
    'hudSwitchClosed': 'Switch closed! The circuit is complete and the lamp glows.',
    'hudSwitchOpened': 'Switch opened. The circuit is broken and the lamp is off.',
    'hudToggle3D': 'TOGGLE to 3D Bench to continue.',
    'hudToggle2D': 'TOGGLE to 2D Canvas to continue.',
    'hud2DExplore':
        '⚡ 2D Schematic Canvas: Drag symbols from the tray onto the blueprint canvas to explore, or switch back to 3D Bench to follow step-by-step instructions.',
    'hudGreatRemaining': 'Great! Now tap the remaining open symbols to close the circuit loop!',
    'canvasTitle': '2D Schematic Blueprint Canvas',
    'sc1Title': '1. Physical to Schematic Diagram',
    'sc2Title': '2. Drawing the LED Circuit',
    'cell': 'CELL',
    'battery': 'BATTERY',
    'lamp': 'LAMP',
    'led': 'LED',
    'switch': 'SWITCH',
    'switchON': 'SWITCH (ON)',
    'sc1Theory':
        'Symbols act as a scientific shorthand. Engineers use standardized symbols to represent electrical parts, making diagrams a universal language.',
    'sc1Obs':
        "You've successfully mapped a physical circuit to a standard schematic! These universal symbols make it easy for anyone around the world to understand, design, and troubleshoot circuits safely without needing the physical layout.",
    'sc2Theory':
        'LEDs (Light Emitting Diodes) allow current to flow in only one direction. Their standard symbol contains a triangle indicating the direction of conventional current flow.',
    'sc2Obs':
        'Great observation! LEDs have polarity. They only light up when current flows from the positive to the negative terminal. The triangle in the schematic symbol specifically points in this allowed direction.',
    'l_cell': 'Electric Cell',
    'l_bat': 'Battery Pack',
    'l_lamp': 'Incandescent Lamp',
    'l_led': 'LED',
    'l_switch': 'Safety Switch',
  },
  'hi': {
    'appTitle': 'परिपथ आरेख और प्रतीक',
    'appSubtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'btn3DBench': '3D बेंच',
    'btn2DCanvas': '2D कैनवास',
    'tray': 'ट्रे',
    'currTask': 'वर्तमान कार्य',
    'figRef': 'चित्र 3.12a संदर्भ',
    'keyObs': 'मुख्य अवलोकन',
    'noItems': 'किसी वस्तु की आवश्यकता नहीं है।',
    'hudScenarioComplete': 'परिदृश्य पूर्ण हुआ! 3D बेंच और 2D कैनवास का अन्वेषण करने के लिए स्वतंत्र महसूस करें।',
    'hudPlaceSymbols': 'पहले कैनवास पर सभी आवश्यक प्रतीक रखें!',
    'hudTapSeq1': 'तार से जोड़ने के लिए एक प्रतीक पर टैप करें, फिर दूसरे पर टैप करें।',
    'hudTapSeq2': 'सर्किट को स्वचालित रूप से पूरा करने के लिए बैटरी पर टैप करें, फिर एलईडी पर टैप करें।',
    'hudIncorrectSym': 'इस चरण के लिए गलत प्रतीक!',
    'hudMappedCanvas': 'प्रतीकों को सफलतापूर्वक कैनवास पर मैप किया गया।',
    'hudPhysicalPlaced': 'सभी भौतिक घटकों को वर्कबेंच पर रखा गया।',
    'hudCircuitSeries': 'परिपथ पूरी तरह से श्रृंखला में तारित है!',
    'hudLEDGlows': 'एलईडी चमकती है! करंट धनात्मक से ऋणात्मक की ओर बहता है।',
    'hudLEDWrong1': 'गलत! धनात्मक (+) को लंबे पैर से, ऋणात्मक (-) को छोटे पैर से जोड़ें।',
    'hudLEDOFF': 'एलईडी नहीं चमकती है। करंट उल्टी दिशा में अवरुद्ध है।',
    'hudLEDWrong2': 'गलत! इसे पलटने के लिए धनात्मक (+) को छोटे पैर से जोड़ें।',
    'hudSchematicMapped': 'योजनाबद्ध ब्लूप्रिंट सही ढंग से मैप किया गया!',
    'hudCircuitValidated': 'सर्किट आरेख मान्य! योजनाबद्ध पूर्ण।',
    'hudSwitchClosed': 'स्विच बंद! परिपथ पूरा हो गया है और लैंप चमकता है।',
    'hudSwitchOpened': 'स्विच खुला। परिपथ टूट गया है और लैंप बंद है।',
    'hudToggle3D': 'जारी रखने के लिए 3D बेंच पर टॉगल करें।',
    'hudToggle2D': 'जारी रखने के लिए 2D कैनवास पर टॉगल करें।',
    'hud2DExplore':
        '⚡ 2D योजनाबद्ध कैनवास: अन्वेषण के लिए ट्रे से प्रतीकों को ब्लूप्रिंट कैनवास पर खींचें, या चरण-दर-चरण निर्देशों का पालन करने के लिए 3D बेंच पर वापस जाएँ।',
    'hudGreatRemaining': 'बहुत बढ़िया! अब परिपथ लूप को बंद करने के लिए शेष खुले प्रतीकों पर टैप करें!',
    'canvasTitle': '2D योजनाबद्ध ब्लूप्रिंट कैनवास',
    'sc1Title': '1. भौतिक से योजनाबद्ध आरेख',
    'sc2Title': '2. LED परिपथ आरेखित करना',
    'cell': 'सेल',
    'battery': 'बैटरी',
    'lamp': 'लैंप',
    'led': 'एलईडी',
    'switch': 'स्विच',
    'switchON': 'स्विच (ON)',
    'sc1Theory':
        'प्रतीक एक वैज्ञानिक आशुलिपि के रूप में कार्य करते हैं। इंजीनियर विद्युत भागों का प्रतिनिधित्व करने के लिए मानकीकृत प्रतीकों का उपयोग करते हैं, जिससे आरेख एक सार्वभौमिक भाषा बन जाते हैं।',
    'sc1Obs':
        'आपने सफलतापूर्वक एक भौतिक परिपथ को एक मानक योजनाबद्ध में मैप किया है! ये सार्वभौमिक प्रतीक दुनिया भर में किसी के लिए भी परिपथों को समझना, डिज़ाइन करना और समस्या निवारण करना आसान बनाते हैं।',
    'sc2Theory':
        'LEDs (प्रकाश उत्सर्जक डायोड) करंट को केवल एक दिशा में प्रवाहित होने देते हैं। उनके मानक प्रतीक में एक त्रिकोण होता है जो पारंपरिक धारा प्रवाह की दिशा को दर्शाता है।',
    'sc2Obs':
        'महान अवलोकन! LEDs में ध्रुवीयता होती है। वे केवल तभी जलते हैं जब करंट धनात्मक से ऋणात्मक टर्मिनल की ओर प्रवाहित होता है। आरेखीय प्रतीक में त्रिकोण विशेष रूप से इस अनुमत दिशा को इंगित करता है।',
    'l_cell': 'इलेक्ट्रिक सेल',
    'l_bat': 'बैटरी पैक',
    'l_lamp': 'तापदीप्त लैंप',
    'l_led': 'एलईडी',
    'l_switch': 'सेफ्टी स्विच',
  },
};

/// Non-localised step rules from the HTML `getScenarios()`.
typedef _StepRule = ({bool is2D, List<String> items, int reqCount, List<String>? allowed});

const List<List<_StepRule>> _rules = [
  [
    (is2D: false, items: ['cell', 'lamp', 'switch'], reqCount: 3, allowed: null),
    (is2D: false, items: <String>[], reqCount: 0, allowed: null),
    (is2D: false, items: <String>[], reqCount: 0, allowed: null),
    (is2D: true, items: ['cell'], reqCount: 1, allowed: ['cell']),
    (is2D: true, items: ['lamp', 'switchON'], reqCount: 3, allowed: ['lamp', 'switchON']),
    (is2D: true, items: <String>[], reqCount: 0, allowed: null),
  ],
  [
    (is2D: false, items: ['battery', 'led'], reqCount: 2, allowed: null),
    (is2D: false, items: <String>[], reqCount: 0, allowed: null),
    (is2D: false, items: <String>[], reqCount: 0, allowed: null),
    (is2D: true, items: ['battery', 'led'], reqCount: 2, allowed: ['battery', 'led']),
    (is2D: true, items: <String>[], reqCount: 0, allowed: null),
    (is2D: true, items: <String>[], reqCount: 0, allowed: null),
  ],
];

/// All 2D palette symbols per scenario (HTML `items2D`).
const List<List<String>> _items2D = [
  ['cell', 'lamp', 'switchON'],
  ['battery', 'led'],
];

/// Mission objective + steps. `concept` = the HTML "Concept:" text and
/// `action` = the step description (also the HUD text for that step).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To build a simple physical circuit with an incandescent lamp and then correctly represent it using standard electrical symbols.',
      steps: [
        LabStep(
          concept: 'A physical circuit requires components: an energy source (cell), a consumer (lamp), and a controller (switch).',
          action: 'From the component tray, DRAG an electric cell, an incandescent lamp in a holder, and a switch onto the workbench.',
        ),
        LabStep(
          concept: 'Wires provide a conductive path. Connecting them forms a closed loop, essential for electron flow.',
          action:
              'DRAG the ends of the connecting wires from the tray to the connection points on the cell, switch, and lamp to build the circuit shown in the reference image (Fig. 3.12a).',
        ),
        LabStep(
          concept:
              'Closing the switch bridges the gap in the circuit. Electrons flow, heating the filament until it emits light.',
          action: "CLICK on the safety pin of the switch to move it to the 'ON' position, touching the other drawing pin.",
        ),
        LabStep(
          concept:
              'The electric cell symbol uses a long thin line for the positive terminal and a short thick line for the negative.',
          action:
              'Now, look at the diagram canvas on the right. From the symbol palette, DRAG the correct symbol for the electric cell and DROP it onto the canvas.',
        ),
        LabStep(
          concept:
              "The lamp is represented by a circle with a filament shape. A closed line with two dots represents an 'ON' switch.",
          action: "DRAG the correct symbols for the incandescent lamp and the switch in the 'ON' position onto the canvas.",
        ),
        LabStep(
          concept: 'Straight lines represent wires. This resulting schematic is a universal blueprint matching our physical setup.',
          action: 'Tap the symbols sequentially to automatically connect them with wires.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'Build a circuit with a battery and an LED, observe polarity, and draw its corresponding circuit diagram.',
      steps: [
        LabStep(
          concept: 'A battery is a collection of cells. An LED has a longer leg (positive) and a shorter leg (negative).',
          action: 'From the component tray, DRAG a battery (two cells), an LED, and connecting wires onto the workbench.',
        ),
        LabStep(
          concept: 'Correct polarity allows current to flow through the diode, causing the LED to light up.',
          action:
              'CONNECT the wire from the positive (+) terminal of the battery to the longer leg of the LED. Then, CONNECT the wire from the negative (-) terminal of the battery to the shorter leg of the LED.',
        ),
        LabStep(
          concept: 'Connecting in reverse blocks electron flow. The LED remains off, acting like a closed gate.',
          action:
              "Let's see what happens if we reverse the connections. DISCONNECT the wires from the LED (Click existing wire to remove). Now, CONNECT the wire from the positive (+) terminal of the battery to the shorter leg of the LED, and the negative (-) wire to the longer leg.",
        ),
        LabStep(
          concept: 'The battery symbol shows multiple cell symbols joined together. The LED symbol is a diode with light arrows.',
          action:
              'Reconnect the wires correctly so the LED glows again. Now, on the diagram canvas, DRAG the correct symbol for a battery and an LED from the symbol palette.',
        ),
        LabStep(
          concept: 'The triangle in the LED symbol points in the direction of conventional current (from + to -).',
          action: 'Tap the Battery, then tap the LED to automatically complete the circuit.',
        ),
        LabStep(
          concept: 'A correct schematic serves as an accurate, universal plan for the physical circuit.',
          action: 'Once the diagram is correct, the circuit will be validated.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'एक तापदीप्त लैंप के साथ एक साधारण भौतिक परिपथ बनाना और फिर मानक विद्युत प्रतीकों का उपयोग करके इसे सही ढंग से दर्शाना।',
      steps: [
        LabStep(
          concept:
              'एक भौतिक परिपथ के लिए घटकों की आवश्यकता होती है: एक ऊर्जा स्रोत (सेल), एक उपभोक्ता (लैंप), और एक नियंत्रक (स्विच)।',
          action: 'कंपोनेंट ट्रे से, एक इलेक्ट्रिक सेल, एक होल्डर में एक तापदीप्त लैंप, और एक स्विच को वर्कबेंच पर खींचें।',
        ),
        LabStep(
          concept: 'तार एक प्रवाहकीय पथ प्रदान करते हैं। उन्हें जोड़ना एक बंद लूप बनाता है, जो इलेक्ट्रॉन प्रवाह के लिए आवश्यक है।',
          action: 'परिपथ बनाने के लिए ट्रे से कनेक्टिंग तारों के सिरों को सेल, स्विच और लैंप पर कनेक्शन बिंदुओं तक खींचें।',
        ),
        LabStep(
          concept:
              'स्विच बंद करने से परिपथ में अंतर समाप्त हो जाता है। इलेक्ट्रॉन प्रवाहित होते हैं, फिलामेंट को तब तक गर्म करते हैं जब तक वह प्रकाश न दे।',
          action: "स्विच के 'ON' स्थिति में ले जाने के लिए सेफ्टी पिन पर क्लिक करें, जिससे यह दूसरी ड्राइंग पिन को छू सके।",
        ),
        LabStep(
          concept:
              'इलेक्ट्रिक सेल प्रतीक धनात्मक टर्मिनल के लिए एक लंबी पतली रेखा और ऋणात्मक के लिए एक छोटी मोटी रेखा का उपयोग करता है।',
          action:
              'अब, दाईं ओर आरेख कैनवास देखें। प्रतीक पैलेट से, इलेक्ट्रिक सेल के लिए सही प्रतीक को खींचें और इसे कैनवास पर छोड़ दें।',
        ),
        LabStep(
          concept:
              "लैंप को फिलामेंट आकार वाले एक वृत्त द्वारा दर्शाया जाता है। दो बिंदुओं वाली एक बंद रेखा 'ON' स्विच का प्रतिनिधित्व करती है।",
          action: "कैनवास पर तापदीप्त लैंप और 'ON' स्थिति में स्विच के लिए सही प्रतीकों को खींचें।",
        ),
        LabStep(
          concept:
              'सीधी रेखाएं तारों का प्रतिनिधित्व करती हैं। यह परिणामी योजनाबद्ध हमारे भौतिक सेटअप से मेल खाने वाला एक सार्वभौमिक ब्लूप्रिंट है।',
          action: 'तारों से स्वचालित रूप से जुड़ने के लिए प्रतीकों को क्रमिक रूप से टैप करें।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'बैटरी और एलईडी के साथ एक परिपथ बनाएं, ध्रुवीयता का निरीक्षण करें, और इसका संबंधित परिपथ आरेख बनाएं।',
      steps: [
        LabStep(
          concept: 'एक बैटरी सेलों का एक संग्रह है। LED का एक पैर लंबा (धनात्मक) और एक पैर छोटा (ऋणात्मक) होता है।',
          action: 'कंपोनेंट ट्रे से, वर्कबेंच पर एक बैटरी (दो सेल), एक LED और कनेक्टिंग तारों को खींचें।',
        ),
        LabStep(
          concept: 'सही ध्रुवीयता डायोड के माध्यम से करंट प्रवाहित होने देती है, जिससे LED जल जाती है।',
          action:
              'बैटरी के धनात्मक (+) टर्मिनल से LED के लंबे पैर तक तार कनेक्ट करें। फिर, बैटरी के ऋणात्मक (-) टर्मिनल से LED के छोटे पैर तक तार कनेक्ट करें।',
        ),
        LabStep(
          concept: 'विपरीत क्रम में जोड़ने से इलेक्ट्रॉन प्रवाह अवरुद्ध हो जाता है। LED बंद रहता है, एक बंद गेट की तरह काम करता है।',
          action:
              'आइए देखें कि यदि हम कनेक्शन को उलट देते हैं तो क्या होता है। LED से तारों को डिस्कनेक्ट करें। अब, बैटरी के धनात्मक (+) टर्मिनल से तार को LED के छोटे पैर से और ऋणात्मक (-) तार को लंबे पैर से कनेक्ट करें।',
        ),
        LabStep(
          concept: 'बैटरी प्रतीक एक साथ जुड़े कई सेल प्रतीकों को दर्शाता है। LED प्रतीक प्रकाश तीरों वाला एक डायोड है।',
          action:
              'तारों को सही ढंग से फिर से कनेक्ट करें ताकि LED फिर से चमकने लगे। अब, आरेख कैनवास पर, प्रतीक पैलेट से बैटरी और LED के लिए सही प्रतीक खींचें।',
        ),
        LabStep(
          concept: 'LED प्रतीक में त्रिकोण पारंपरिक धारा ( + से - की ओर) की दिशा में इंगित करता है।',
          action: 'बैटरी पर टैप करें, फिर परिपथ को स्वचालित रूप से पूरा करने के लिए LED पर टैप करें।',
        ),
        LabStep(
          concept: 'एक सही योजनाबद्ध भौतिक परिपथ के लिए एक सटीक, सार्वभौमिक योजना के रूप में कार्य करता है।',
          action: 'एक बार आरेख सही होने के बाद, परिपथ मान्य हो जाएगा।',
        ),
      ],
    ),
  ],
};

// ======================================================== 3D HELPERS
//
// The 3D Bench is the HTML Three.js scene (PerspectiveCamera FOV 45 at
// (0, 18, 22) looking at the origin) reproduced with a small pinhole camera
// in 1000x560 design space. The 2D Canvas is the HTML schematic layer.

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
    return l == 0 ? this : this * (1 / l);
  }

  _V3 withY(double v) => _V3(x, v, z);
}

const _V3 _up = _V3(0, 1, 0);

/// Directional light of the HTML scene: position (10, 20, 15).
final _V3 _light = const _V3(10, 20, 15).unit;

class _Cam {
  _Cam({required this.eye, required double fovDeg, required this.principal}) {
    f = (const _V3(0, 0, 0) - eye).unit;
    r = f.cross(_up).unit;
    u = r.cross(f);
    focal = (_design.height / 2) / math.tan(fovDeg * math.pi / 360);
  }

  final _V3 eye;
  final Offset principal;
  late final _V3 f, r, u;
  late final double focal;

  double depth(_V3 p) => (p - eye).dot(f);

  Offset project(_V3 p) {
    final d = p - eye;
    final z = d.dot(f);
    return Offset(principal.dx + d.dot(r) / z * focal, principal.dy - d.dot(u) / z * focal);
  }

  double scaleAt(_V3 p) => focal / depth(p);

  _V3? onPlane(Offset s, double planeY) {
    final dir = (f + r * ((s.dx - principal.dx) / focal) + u * (-(s.dy - principal.dy) / focal)).unit;
    if (dir.y.abs() < 1e-6) return null;
    final t = (planeY - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// HTML `camera.position.set(0, 18, 22)`, FOV 45.
final _Cam _cam = _Cam(eye: const _V3(0, 18, 22), fovDeg: 45, principal: const Offset(500, 262));

double _shadeK(_V3 n) => 0.6 + 0.45 * math.max(0, n.dot(_light));

Color _lit(Color c, double k) => k >= 1
    ? Color.lerp(c, Colors.white, (k - 1).clamp(0.0, 1.0))!
    : Color.lerp(c, Colors.black, (1 - k).clamp(0.0, 1.0))!;

Color _a(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

/// Axis-aligned box (BoxGeometry) with per-face shading and back-face culling.
void _box(Canvas canvas, _V3 c, _V3 half, Color color, {double opacity = 1, double spec = 0}) {
  const axes = [_V3(1, 0, 0), _up, _V3(0, 0, 1)];
  final h = [half.x, half.y, half.z];
  for (var a = 0; a < 3; a++) {
    for (final sgn in const [-1.0, 1.0]) {
      final n = axes[a] * sgn;
      final fc = c + n * h[a];
      if (n.dot(_cam.eye - fc) <= 0) continue;
      final o1 = axes[(a + 1) % 3] * h[(a + 1) % 3];
      final o2 = axes[(a + 2) % 3] * h[(a + 2) % 3];
      final path = _poly([
        _cam.project(fc + o1 + o2),
        _cam.project(fc + o1 - o2),
        _cam.project(fc - o1 - o2),
        _cam.project(fc - o1 + o2),
      ]);
      var col = _lit(color, _shadeK(n));
      if (spec > 0) {
        final hv = (_light + (_cam.eye - fc).unit).unit;
        col = Color.lerp(col, Colors.white, spec * math.pow(math.max(0, n.dot(hv)), 16).toDouble())!;
      }
      canvas.drawPath(path, Paint()..color = _a(col, opacity));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = _a(labShade(color, -0.45), 0.4 * opacity),
      );
    }
  }
}

/// Cylinder between [p0] and [p1] (any axis) with radii [r0] at p0 and [r1]
/// at p1 (CylinderGeometry; r0 != r1 gives a tapered base).
void _cyl(
  Canvas canvas,
  _V3 p0,
  _V3 p1,
  double r0,
  Color color, {
  double? r1,
  double opacity = 1,
  double spec = 0.25,
  bool caps = true,
  int seg = 36,
}) {
  final rr1 = r1 ?? r0;
  final axis = (p1 - p0).unit;
  final ref = axis.y.abs() > 0.9 ? const _V3(1, 0, 0) : _up;
  final pv = axis.cross(ref).unit;
  final qv = axis.cross(pv).unit;
  final step = 2 * math.pi / seg;
  _V3 rim(_V3 c, double r, double a) => c + pv * (math.cos(a) * r) + qv * (math.sin(a) * r);
  for (var i = 0; i < seg; i++) {
    final am = (i + 0.5) * step;
    final n = (pv * math.cos(am) + qv * math.sin(am)).unit;
    final mid = rim((p0 + p1) * 0.5, (r0 + rr1) / 2, am);
    if (n.dot(_cam.eye - mid) <= 0) continue;
    final a0 = i * step - step * 0.2;
    final a1 = (i + 1) * step + step * 0.2;
    final hv = (_light + (_cam.eye - mid).unit).unit;
    final s = spec * math.pow(math.max(0, n.dot(hv)), 18).toDouble();
    final col = Color.lerp(_lit(color, 0.5 + 0.55 * math.max(0, n.dot(_light)) + 0.1), Colors.white, s)!;
    canvas.drawPath(
      _poly([
        _cam.project(rim(p0, r0, a0)),
        _cam.project(rim(p0, r0, a1)),
        _cam.project(rim(p1, rr1, a1)),
        _cam.project(rim(p1, rr1, a0)),
      ]),
      Paint()..color = _a(col, opacity),
    );
  }
  if (!caps) return;
  for (final (c, r, n) in [(p0, r0, axis * -1), (p1, rr1, axis)]) {
    if (n.dot(_cam.eye - c) <= 0) continue;
    canvas.drawPath(
      _poly([for (var i = 0; i < seg; i++) _cam.project(rim(c, r, i * step))]),
      Paint()..color = _a(_lit(color, _shadeK(n) + 0.04), opacity),
    );
  }
}

/// Tube along [pts] (TubeGeometry): outline, body and a specular streak.
void _tube(Canvas canvas, List<_V3> pts, double radius, Color color, {double opacity = 1}) {
  if (pts.length < 2) return;
  final w = 2 * radius * _cam.scaleAt(pts[pts.length ~/ 2]);
  final path = Path();
  for (var i = 0; i < pts.length; i++) {
    final p = _cam.project(pts[i]);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  Paint stroke(double width, Color c) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = _a(c, opacity);
  canvas.drawPath(path, stroke(w + 1.4, labShade(color, -0.5)));
  canvas.drawPath(path, stroke(w, color));
  canvas.drawPath(path.shift(Offset(0, -w * 0.18)), stroke(w * 0.28, labShade(color, 0.45).withValues(alpha: 0.6)));
}

/// Three.js `QuadraticBezierCurve3` sampled into [n] segments.
List<_V3> _bezier(_V3 a, _V3 m, _V3 b, int n) => [
      for (var i = 0; i <= n; i++)
        a * ((1 - i / n) * (1 - i / n)) + m * (2 * (1 - i / n) * (i / n)) + b * ((i / n) * (i / n)),
    ];

/// Soft cast shadow of a vertical object (light from +x, +y, +z).
void _castShadow(Canvas canvas, _V3 base, double r, double h, {double opacity = 0.26}) {
  final tip = base + _V3(-_light.x / _light.y * h, 0, -_light.z / _light.y * h);
  final w = 2 * r * _cam.scaleAt(base);
  canvas.drawLine(
    _cam.project(base),
    _cam.project(tip),
    Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.18 + 2),
  );
}

// ============================================================ SCENE MODEL

@immutable
class _Term {
  const _Term(this.part, this.id, this.local);
  final String part;
  final String id;
  final _V3 local;
}

/// Bench positions from `placeItem3D`.
const Map<String, _V3> _partPos = {
  'cell': _V3(-8, 0, -2),
  'battery': _V3(-8, 0, -2),
  'lamp': _V3(6, 0, -2),
  'led': _V3(6, 0, -2),
  'switch': _V3(-1, 0, 6),
};

/// Wire terminals (`addTerminal`). The cell's negative terminal sits at the
/// front of its base: the HTML puts it at the centre of the base, where its
/// marker is hidden inside the cell body.
const List<_Term> _terms = [
  _Term('cell', 'pos', _V3(0, 3.3, 0)),
  _Term('cell', 'neg', _V3(0, 0.1, 1.35)),
  _Term('battery', 'pos', _V3(2.6, 0.5, -0.8)),
  _Term('battery', 'neg', _V3(-2.6, 0.5, 0.8)),
  _Term('lamp', 't1', _V3(-2.0, 0.4, 0)),
  _Term('lamp', 't2', _V3(2.0, 0.4, 0)),
  _Term('led', 'pos', _V3(0.4, 0, 0)),
  _Term('led', 'neg', _V3(-0.4, 0.5, 0)),
  _Term('switch', 't1', _V3(-2.5, 0.4, 0)),
  _Term('switch', 't2', _V3(2.5, 0.4, 0)),
];

/// Polarity "+" / "-" label anchors (HTML `labelsData.polarity`).
const Map<String, List<(_V3, bool)>> _polarity = {
  'cell': [(_V3(0, 3.6, 0), true), (_V3(0, -0.2, 1.75), false)],
  'battery': [(_V3(2.6, 1.0, -0.8), true), (_V3(-2.6, 1.0, 0.8), false)],
  'led': [(_V3(0.4, 0.0, 0.5), true), (_V3(-0.4, 0.5, 0.5), false)],
};

/// Object label key + height (HTML `labelsData`).
const Map<String, (String, double)> _labels3D = {
  'cell': ('l_cell', 4.5),
  'battery': ('l_bat', 3),
  'lamp': ('l_lamp', 5),
  'led': ('l_led', 4),
  'switch': ('l_switch', 3),
};

class _A5Scene {
  int scenario = 0;
  int step = 0;
  bool completed = false;
  bool is3D = true;
  double time = 0;

  // ----- 3D bench -----
  final Set<String> placed3D = {};
  final Map<String, double> placedAt = {};
  final List<(_Term, _Term)> wires = [];
  bool switchOn = false;

  /// 0 = arm open (rotation.y = PI/4), 1 = closed; eased each frame.
  double arm = 0;
  bool ledOn = false;
  bool ledX = false;
  _Term? wireFrom;
  _V3? wireTo;

  // ----- 2D canvas -----
  final Set<String> placed2D = {};
  final Map<String, Offset> nodes = {};
  final List<(String, String)> conns = [];
  String? selected;
  String? draggingNode;
  bool ledPulse = false;
  bool ledFlash = false;
  Offset? rejectAt;
  double rejectUntil = -1;
  double successAt = -1;

  /// Drop-in offset (world units) of a freshly placed bench part.
  double drop(String part) {
    final t0 = placedAt[part];
    if (t0 == null) return 0;
    final k = ((time - t0) / 0.35).clamp(0.0, 1.0);
    return 1.6 * (1 - Curves.easeOutCubic.transform(k));
  }

  _V3 partPos(String part) => _partPos[part]! + _V3(0, drop(part), 0);
  _V3 termPos(_Term t) => partPos(t.part) + t.local;
  bool connected(_Term t) => wires.any((w) => identical(w.$1, t) || identical(w.$2, t));

  void clearWires() {
    wires.clear();
    wireFrom = null;
    wireTo = null;
  }

  void reset(int scen) {
    scenario = scen;
    step = 0;
    completed = false;
    is3D = true;
    placed3D.clear();
    placedAt.clear();
    clearWires();
    switchOn = false;
    arm = 0;
    ledOn = false;
    ledX = false;
    placed2D.clear();
    nodes.clear();
    conns.clear();
    selected = null;
    draggingNode = null;
    ledPulse = false;
    ledFlash = false;
    rejectAt = null;
    rejectUntil = -1;
    successAt = -1;
  }
}

// ==================================================== 3D BENCH PAINTER

const Color _plasticBlack = Color(0xFF222222);
const Color _plasticRed = Color(0xFFDD3333);
const Color _plasticGray = Color(0xFF99AAB5);
const Color _metalCol = Color(0xFFCCCCCC);
const Color _termBase = Color(0xFF444444);
const Color _dotGreen = Color(0xFF22C55E);
const Color _dotYellow = Color(0xFFEAB308);
const Color _lampOn = Color(0xFFFFEA00);
const Color _ledRed = Color(0xFFFF4444);

class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _A5Scene scene;
  final bool isDark;
  final bool showLabels;

  /// Localised object labels keyed by part ('cell', 'battery'...).
  final Map<String, String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    // `--canvas-bg` radial gradient behind the transparent renderer.
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF020617)]
              : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width * 0.75)),
    );
    _table(canvas, size);

    if (s.switchOn && s.placed3D.contains('lamp')) {
      _pool(canvas, s.partPos('lamp'), const Color(0xFFFFEA00), 360, 0.5);
    }
    if (s.ledOn && s.placed3D.contains('led')) {
      _pool(canvas, s.partPos('led'), const Color(0xFFFF2222), 300, 0.45);
    }

    final parts = s.placed3D.toList()..sort((a, b) => _partPos[a]!.z.compareTo(_partPos[b]!.z));
    for (final p in parts) {
      switch (p) {
        case 'cell':
          _cell(canvas, s.partPos(p));
        case 'battery':
          _battery(canvas, s.partPos(p));
        case 'lamp':
          _lamp(canvas, s.partPos(p));
        case 'led':
          _led(canvas, s.partPos(p));
        case 'switch':
          _switch(canvas, s.partPos(p));
      }
    }

    // Wires lie on the bench (bezier sagging to y = 0.1).
    for (final (t1, t2) in s.wires) {
      final p1 = s.termPos(t1);
      final p2 = s.termPos(t2);
      final mid = _V3((p1.x + p2.x) / 2, 0.1, (p1.z + p2.z) / 2);
      final red = t1.id == 'pos' || t2.id == 'pos';
      _tube(canvas, _bezier(p1, mid, p2, 24), 0.12, red ? const Color(0xFFCC2222) : _plasticBlack);
    }
    // Wire being dragged from a terminal.
    final from = s.wireFrom;
    final to = s.wireTo;
    if (from != null && to != null) {
      _tube(canvas, [s.termPos(from), to], 0.12, _plasticBlack);
      labGlow(canvas, _cam.project(to), 16, _dotYellow, intensity: 0.6);
    }

    // Terminal markers: dark disc + green dot (yellow once wired).
    for (final t in _terms) {
      if (!s.placed3D.contains(t.part)) continue;
      final p = s.termPos(t);
      _cyl(canvas, p - const _V3(0, 0.1, 0), p, 0.25, _termBase, seg: 16);
      final c = _cam.project(p + const _V3(0, 0.15, 0));
      final r = 0.25 * _cam.scaleAt(p);
      final col = s.connected(t) ? _dotYellow : _dotGreen;
      final active = identical(s.wireFrom, t);
      if (active) labGlow(canvas, c, r * 4, col, intensity: 0.8);
      labSphere(canvas, c, r, col, highlight: 0.5, shade: 0.3);
    }

    if (s.ledX && s.placed3D.contains('led')) {
      // HTML `#led-x-mark` ("✗", red, 3rem) drawn as strokes so it never
      // depends on the font having the glyph.
      final c = _cam.project(s.partPos('led') + const _V3(0, 2, 0));
      void x(Paint paint, Offset o) {
        canvas.drawLine(c + o + const Offset(-14, -16), c + o + const Offset(14, 16), paint);
        canvas.drawLine(c + o + const Offset(13, -18), c + o + const Offset(-12, 17), paint);
      }

      x(
        Paint()
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = Colors.black.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        const Offset(0, 2),
      );
      x(
        Paint()
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFEF4444),
        Offset.zero,
      );
    }

    if (showLabels) {
      for (final p in parts) {
        final (_, h) = _labels3D[p]!;
        labText(
          canvas,
          labels[p] ?? p,
          _cam.project(s.partPos(p) + _V3(0, h, 0)),
          size: 15,
          weight: FontWeight.w700,
          color: Colors.white,
          background: Colors.black.withValues(alpha: 0.8),
          border: Colors.white.withValues(alpha: 0.2),
          borderWidth: 1,
          radius: 5,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        );
        for (final (local, pos) in _polarity[p] ?? const <(_V3, bool)>[]) {
          labText(
            canvas,
            pos ? '+' : '-',
            _cam.project(s.partPos(p) + local),
            size: 30,
            weight: FontWeight.w900,
            color: pos ? const Color(0xFFFF8888) : Colors.white,
            shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1))],
          );
        }
      }
    }
  }

  void _table(Canvas canvas, Size size) {
    final top = [
      _cam.project(const _V3(-25, 0, -25)),
      _cam.project(const _V3(25, 0, -25)),
      _cam.project(const _V3(25, 0, 25)),
      _cam.project(const _V3(-25, 0, 25)),
    ];
    final path = _poly(top);
    canvas.drawPath(
      path.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(const Color(0xFFDEB887), -0.12), const Color(0xFFDEB887), labShade(const Color(0xFFDEB887), 0.05)],
        ).createShader(Rect.fromLTRB(0, top[0].dy, size.width, size.height)),
    );
    canvas.save();
    canvas.clipPath(path);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8B5A2B).withValues(alpha: 0.10);
    for (var i = 0; i < 40; i++) {
      final z0 = -25 + i * 1.25;
      final g = Path();
      for (var x = -25.0; x <= 25; x += 1.25) {
        final p = _cam.project(_V3(x, 0, z0 + 0.2 * math.sin(x * 0.3 + i * 1.3)));
        x == -25 ? g.moveTo(p.dx, p.dy) : g.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(g, grain);
    }
    canvas.restore();
    canvas.drawLine(top[0], top[1], Paint()
      ..strokeWidth = 2
      ..color = labShade(const Color(0xFFDEB887), 0.25));
  }

  void _pool(Canvas canvas, _V3 at, Color c, double radius, double alpha) {
    final p = _cam.project(at);
    canvas.drawOval(
      Rect.fromCenter(center: p, width: radius * 2, height: radius * 1.3),
      Paint()
        ..shader = RadialGradient(colors: [c.withValues(alpha: alpha), c.withValues(alpha: alpha * 0.3), c.withValues(alpha: 0)],
                stops: const [0, 0.45, 1])
            .createShader(Rect.fromCenter(center: p, width: radius * 2, height: radius * 1.3)),
    );
  }

  void _cell(Canvas canvas, _V3 p) {
    _castShadow(canvas, p, 1.2, 3.3);
    _cyl(canvas, p, p + const _V3(0, 1.5, 0), 1.2, _plasticBlack, spec: 0.2);
    _cyl(canvas, p + const _V3(0, 1.5, 0), p + const _V3(0, 3.0, 0), 1.2, _plasticRed, spec: 0.3);
    _cyl(canvas, p + const _V3(0, 3.0, 0), p + const _V3(0, 3.3, 0), 0.4, _metalCol, spec: 0.7);
    // White "+" on the front (two thin boxes at z = 1.21).
    _box(canvas, p + const _V3(0, 2.25, 1.21), const _V3(0.3, 0.075, 0.05), Colors.white);
    _box(canvas, p + const _V3(0, 2.25, 1.21), const _V3(0.075, 0.3, 0.05), Colors.white);
  }

  void _battery(Canvas canvas, _V3 p) {
    _castShadow(canvas, p, 2.2, 2.2, opacity: 0.22);
    _box(canvas, p + const _V3(0, 0.25, 0), const _V3(2.75, 0.25, 1.5), _plasticBlack);
    for (final z in const [-0.8, 0.8]) {
      final y = p.y + 1.2;
      _cyl(canvas, _V3(p.x - 1.5, y, p.z + z), _V3(p.x, y, p.z + z), 1, _plasticBlack, spec: 0.2);
      _cyl(canvas, _V3(p.x, y, p.z + z), _V3(p.x + 1.5, y, p.z + z), 1, _plasticRed, spec: 0.3);
      _cyl(canvas, _V3(p.x + 1.5, y, p.z + z), _V3(p.x + 1.8, y, p.z + z), 0.3, _metalCol, spec: 0.7);
    }
  }

  void _lamp(Canvas canvas, _V3 p) {
    final on = scene.switchOn;
    _castShadow(canvas, p, 2.0, 4.8, opacity: on ? 0.12 : 0.26);
    _cyl(canvas, p, p + const _V3(0, 0.8, 0), 2.2, _plasticGray, r1: 2.0, spec: 0.2);
    _cyl(canvas, p + const _V3(0, 0.8, 0), p + const _V3(0, 1.8, 0), 1.0, _metalCol, spec: 0.7);
    final bc = p + const _V3(0, 3, 0);
    _box(canvas, bc, const _V3(0.3, 0.3, 0.05), on ? _lampOn : const Color(0xFF555555));
    final c = _cam.project(bc);
    final r = 1.8 * _cam.scaleAt(bc);
    if (on) {
      labGlow(canvas, c, r * 4.5, const Color(0xFFFFEA00), intensity: 0.75);
      labSphere(canvas, c, r, _lampOn, highlight: 0.7, shade: 0.15, opacity: 0.95);
      canvas.drawCircle(c, r * 0.5, Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.3));
    } else {
      labSphere(canvas, c, r, const Color(0xFF333333), opacity: 0.72, highlight: 0.5, shade: 0.4);
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(-r * 0.38, -r * 0.42), width: r * 0.5, height: r * 0.3),
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }
  }

  void _led(Canvas canvas, _V3 p) {
    final on = scene.ledOn;
    _castShadow(canvas, p, 0.8, 3.4, opacity: 0.2);
    _cyl(canvas, p + const _V3(0.4, 0, 0), p + const _V3(0.4, 2.0, 0), 0.08, _metalCol, spec: 0.6, seg: 12);
    _cyl(canvas, p + const _V3(-0.4, 0.5, 0), p + const _V3(-0.4, 2.0, 0), 0.08, _metalCol, spec: 0.6, seg: 12);
    _box(canvas, p + const _V3(0, 2, 0), const _V3(0.25, 0.25, 0.25), on ? const Color(0xFFFF2222) : const Color(0xFF555555));
    final capC = p + const _V3(0, 2.6, 0);
    final c = _cam.project(capC);
    final r = 0.8 * _cam.scaleAt(capC);
    if (on) labGlow(canvas, _cam.project(p + const _V3(0, 2, 0)), r * 5, const Color(0xFFFF2222), intensity: 0.9);
    final bounds = Rect.fromCircle(center: c, radius: r * 4);
    canvas.saveLayer(bounds, Paint()..color = Colors.black.withValues(alpha: on ? 1 : 0.7));
    final col = on ? const Color(0xFFFF2020) : _ledRed;
    labSphere(canvas, c, r, col, highlight: on ? 0.6 : 0.45, shade: 0.35);
    _cyl(canvas, p + const _V3(0, 1.4, 0), capC, 0.8, col, spec: 0.5, caps: false);
    canvas.restore();
  }

  void _switch(Canvas canvas, _V3 p) {
    _castShadow(canvas, p, 1.6, 0.8, opacity: 0.2);
    _box(canvas, p + const _V3(0, 0.2, 0), const _V3(2.5, 0.2, 1.25), _plasticGray, spec: 0.15);
    for (final x in const [-1.8, 1.8]) {
      _cyl(canvas, p + _V3(x, 0.4, 0), p + _V3(x, 0.8, 0), 0.4, _metalCol, spec: 0.7, seg: 20);
    }
    // Safety-pin arm: rotation.y = PI/4 (open) -> 0 (closed).
    final th = math.pi / 4 * (1 - scene.arm);
    final o = p + const _V3(-1.8, 0.7, 0);
    _V3 l(double lx, double lz) =>
        o + _V3(lx * math.cos(th) + lz * math.sin(th), 0, -lx * math.sin(th) + lz * math.cos(th));
    _tube(canvas, [l(-0.2, -0.15), l(3.6, -0.15)], 0.08, const Color(0xFFB8BEC6));
    _tube(canvas, [l(-0.2, 0.15), l(3.8, 0.15)], 0.1, const Color(0xFFC9CED5));
    canvas.drawPath(
      _poly([
        for (var i = 0; i < 20; i++)
          _cam.project(o + _V3(math.cos(i * math.pi / 10) * 0.25, 0, math.sin(i * math.pi / 10) * 0.25)),
      ]),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.16 * _cam.scaleAt(o)
        ..color = const Color(0xFFAEB4BC),
    );
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.scene != scene || !mapEquals(old.labels, labels);
}

// ================================================== 2D SYMBOLS / CANVAS

/// Draws the HTML `SVGs[type]` schematic symbol (24x24 viewBox) into [box].
void _paintSymbol(Canvas canvas, String type, Rect box, Color color) {
  final k = box.width / 24;
  Offset p(double x, double y) => box.topLeft + Offset(x * k, y * k);
  final line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2 * k
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;
  void seg(double x1, double y1, double x2, double y2) => canvas.drawLine(p(x1, y1), p(x2, y2), line);
  switch (type) {
    case 'cell':
      seg(9, 5, 9, 19);
      seg(15, 8, 15, 16);
    case 'lamp':
      canvas.drawCircle(p(12, 12), 6 * k, line);
      seg(9.17157, 14.8284, 14.8284, 9.17157);
      seg(9.17157, 9.17157, 14.8284, 14.8284);
    case 'switchON':
      canvas.drawCircle(p(6, 12), 2 * k, Paint()..color = color);
      canvas.drawCircle(p(18, 12), 2 * k, Paint()..color = color);
      seg(6, 12, 18, 12);
    case 'battery':
      seg(6, 5, 6, 19);
      seg(10, 8, 10, 16);
      seg(14, 5, 14, 19);
      seg(18, 8, 18, 16);
    case 'led':
      canvas.drawPath(_poly([p(6, 18), p(6, 6), p(15, 12)]), line);
      seg(15, 6, 15, 18);
      seg(18, 5, 20, 7);
      seg(20, 10, 22, 12);
  }
}

/// Node size on the blueprint (HTML `.svg-node` 64 px).
const double _nodeSize = 78;

class _SchematicPainter extends CustomPainter {
  _SchematicPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.title,
  }) : super(repaint: repaint);

  final _A5Scene scene;
  final bool isDark;
  final String title;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final t = s.time;
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC));
    final g1 = Paint()
      ..strokeWidth = 1
      ..color = isDark ? const Color(0x66334155) : const Color(0x4D94A3B8);
    for (var x = -800.0; x <= 1800; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), g1);
    }
    for (var y = -800.0; y <= 1400; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), g1);
    }
    final g2 = Paint()..color = isDark ? const Color(0x40475569) : const Color(0x66CBD5E1);
    for (var x = 10.0; x < size.width; x += 20) {
      for (var y = 10.0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1.5, g2);
      }
    }
    // Inset shadow around the blueprint.
    final frame = Offset.zero & size;
    canvas.drawRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Header chip with a pulsing yellow dot.
    final chip = labText(
      canvas,
      title.toUpperCase(),
      const Offset(16, 16),
      anchor: Alignment.topLeft,
      size: 17,
      weight: FontWeight.w800,
      letterSpacing: 0.6,
      color: isDark ? _Colors.slate50 : _Colors.slate900,
      background: isDark ? const Color(0xD90F172A) : const Color(0xE6FFFFFF),
      border: isDark ? const Color(0x26FFFFFF) : const Color(0x26000000),
      borderWidth: 1,
      radius: 8,
      padding: const EdgeInsets.fromLTRB(34, 8, 14, 8),
    );
    canvas.drawCircle(
      Offset(chip.left + 17, chip.center.dy),
      5,
      Paint()..color = _Colors.zslYellow.withValues(alpha: 0.55 + 0.45 * (0.5 + 0.5 * math.sin(t * 3))),
    );

    _wires(canvas, size);

    final order = s.nodes.keys.toList()..sort((a, b) => (a == s.draggingNode ? 1 : 0).compareTo(b == s.draggingNode ? 1 : 0));
    for (final type in order) {
      _node(canvas, type, s.nodes[type]!, t);
    }

    // Rejected symbol: red "X" ghost for 400 ms.
    final rej = s.rejectAt;
    if (rej != null && t < s.rejectUntil) {
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: rej, width: 64, height: 64), const Radius.circular(12));
      canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: 0.85));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFEF4444),
      );
      final x = Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFEF4444);
      canvas.drawLine(rej + const Offset(-13, -13), rej + const Offset(13, 13), x);
      canvas.drawLine(rej + const Offset(13, -13), rej + const Offset(-13, 13), x);
    }
  }

  void _wires(Canvas canvas, Size size) {
    final s = scene;
    final glow = s.completed || (s.scenario == 0 && s.conns.length >= 3) || (s.scenario == 1 && s.conns.isNotEmpty);
    for (final (n1, n2) in s.conns) {
      final a = s.nodes[n1];
      final b = s.nodes[n2];
      if (a == null || b == null) continue;
      final path = Path();
      void poly(List<Offset> pts) {
        path.moveTo(pts.first.dx, pts.first.dy);
        for (final p in pts.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
      }

      if (s.scenario == 1) {
        // Battery <-> LED: top and bottom loop drawn together.
        final topY = math.max(15.0, math.min(a.dy, b.dy) - 50);
        final botY = math.min(size.height - 15, math.max(a.dy, b.dy) + 50);
        poly([a, Offset(a.dx, topY), Offset(b.dx, topY), b]);
        poly([a, Offset(a.dx, botY), Offset(b.dx, botY), b]);
      } else {
        Offset? pos(String type) => n1 == type ? a : (n2 == type ? b : null);
        final c = pos('cell'), l = pos('lamp'), sw = pos('switchON');
        if (c != null && l != null) {
          poly([c, Offset(l.dx, c.dy), l]);
        } else if (l != null && sw != null) {
          poly([l, Offset(l.dx, sw.dy), sw]);
        } else if (sw != null && c != null) {
          poly([sw, Offset(c.dx, sw.dy), c]);
        } else {
          final mid = (a + b) / 2;
          if ((a.dy - b.dy).abs() > (a.dx - b.dx).abs()) {
            poly([a, Offset(a.dx, mid.dy), Offset(b.dx, mid.dy), b]);
          } else {
            poly([a, Offset(mid.dx, a.dy), Offset(mid.dx, b.dy), b]);
          }
        }
      }
      if (glow) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFF3B82F6).withValues(alpha: 0.75)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF3B82F6),
      );
    }
  }

  void _node(Canvas canvas, String type, Offset c, double t) {
    final s = scene;
    final isLed = type == 'led';
    final pulse = isLed && s.ledPulse && !s.ledFlash;
    final k = pulse ? 1 + 0.1 * (0.5 - 0.5 * math.cos(t * 2 * math.pi / 1.5)) : 1.0;
    final size = _nodeSize * k;
    final rect = Rect.fromCenter(center: c, width: size, height: size);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(14 * k));
    final lifted = s.draggingNode == type;
    canvas.drawRRect(
      rr.shift(Offset(0, lifted ? 8 : 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: lifted ? 0.35 : 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lifted ? 10 : 5),
    );
    if (pulse) {
      // `.glow-blue` drop shadow + `animate-pulse-fast` yellow glow.
      canvas.drawRRect(rr.inflate(4), Paint()
        ..color = const Color(0xFF3B82F6).withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawRRect(rr.inflate(2), Paint()
        ..color = _Colors.zslYellow.withValues(alpha: 0.35 + 0.3 * (k - 1) * 10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    final selected = s.selected == type;
    if (selected) {
      canvas.drawRRect(rr.inflate(4), Paint()..color = const Color(0x4DEAB308));
    }
    canvas.drawRRect(rr, Paint()..color = Colors.white);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = selected ? _Colors.zslYellow : const Color(0xFFCBD5E1),
    );
    final flash = isLed && s.ledFlash;
    final f = flash ? 0.5 + 0.5 * math.sin(t * 2 * math.pi) : 0.0;
    final iconBox = Rect.fromCenter(center: c, width: size * 44 / 64, height: size * 44 / 64);
    if (flash) {
      canvas.saveLayer(iconBox.inflate(30), Paint());
      final glowPaint = Paint()
        ..colorFilter = const ColorFilter.mode(Color(0xFFEF4444), BlendMode.srcIn)
        ..imageFilter = ImageFilter.blur(sigmaX: 2 + 6 * f, sigmaY: 2 + 6 * f);
      canvas.saveLayer(iconBox.inflate(30), glowPaint);
      _paintSymbol(canvas, type, iconBox, const Color(0xFFEF4444));
      canvas.restore();
      _paintSymbol(canvas, type, iconBox, const Color(0xFFEF4444));
      canvas.restore();
    } else {
      _paintSymbol(canvas, type, iconBox, const Color(0xFF0F172A));
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter old) =>
      old.isDark != isDark || old.title != title || old.scene != scene;
}

/// HTML `#reference-overlay` SVG (Fig 3.12a, viewBox 100 x 60).
class _ReferencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 100;
    canvas.scale(k);
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    canvas.drawRRect(rr(10, 20, 15, 30, 2), Paint()..color = const Color(0xFF333333));
    canvas.drawRRect(rr(10, 15, 15, 5, 2), Paint()..color = const Color(0xFFE11D48));
    canvas.drawCircle(const Offset(70, 20), 10, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(const Offset(70, 20), 10, Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF333333));
    canvas.drawRect(const Rect.fromLTWH(65, 30, 10, 10), Paint()..color = const Color(0xFF9CA3AF));
    canvas.drawRect(const Rect.fromLTWH(35, 45, 20, 5), Paint()..color = const Color(0xFFCBD5E1));
    Paint stroke(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = c;
    canvas.drawLine(const Offset(25, 35), const Offset(35, 47), stroke(const Color(0xFFEF4444)));
    canvas.drawLine(const Offset(55, 47), const Offset(65, 35), stroke(const Color(0xFF111111)));
    canvas.drawPath(
      Path()
        ..moveTo(17, 15)
        ..lineTo(17, 5)
        ..lineTo(70, 5)
        ..lineTo(70, 10),
      stroke(const Color(0xFFEF4444)),
    );
  }

  @override
  bool shouldRepaint(covariant _ReferencePainter old) => false;
}

/// Tray / drag-ghost icon for a 2D symbol.
class _SymbolIconPainter extends CustomPainter {
  _SymbolIconPainter(this.type, this.color);
  final String type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => _paintSymbol(canvas, type, Offset.zero & size, color);

  @override
  bool shouldRepaint(covariant _SymbolIconPainter old) => old.type != type || old.color != color;
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
