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

/// Class 7 Science • Chapter 3 • Activity 3
/// Constructing a Simple Electrical Circuit.
///
/// Native Flutter port of `Cl7S-Ch3-A3-Constructing_a_Simple_Electrical_Circuit.html`.
/// Drag components from the tray onto the workbench and drag wires between
/// terminals. Scenario 1 lights an incandescent lamp (then breaks and
/// rebuilds the circuit); scenario 2 shows LED polarity.
class Ch3A3ConstructingASimpleElectricalCircuitPage extends StatefulWidget {
  const Ch3A3ConstructingASimpleElectricalCircuitPage({super.key});

  @override
  State<Ch3A3ConstructingASimpleElectricalCircuitPage> createState() =>
      _Ch3A3ConstructingASimpleElectricalCircuitPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, spark 2365.
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

class _Ch3A3ConstructingASimpleElectricalCircuitPageState
    extends State<Ch3A3ConstructingASimpleElectricalCircuitPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _CircuitScene _scene = _CircuitScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  double _last = 0;
  bool _advancing = false;

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

    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      _scene.time = t;
      _scene.tick(t - _last);
      _last = t;
      _frame.value = t;
    })..start();
    _scene.build();
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

  // ============================================================ SCENARIOS

  /// HTML `loadScenario(index)`.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _advancing = false;
    _scene
      ..scenario = index
      ..build();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  /// HTML `resetLab()`: back to scenario 1.
  void _fullReset() => setState(() => _loadScenario(0));

  // ========================================================== HIT TESTING

  /// HTML terminal hit spheres (radius 1.2 x scale), nearest first.
  String? _hitTerminal(Offset p, {String? exclude}) {
    String? best;
    var bestD = double.infinity;
    for (final t in _scene.terms) {
      if (t.id == exclude) continue;
      final w = _scene.termPoint(t.id);
      final r = (1.2 * t.scale * _Cam.k(w)).clamp(18.0, 42.0);
      final d = (_Cam.v(w) - p).distance;
      if (d < r && d < bestD) {
        best = t.id;
        bestD = d;
      }
    }
    return best;
  }

  _Wire? _hitWire(Offset p) {
    for (final w in _scene.wires.reversed) {
      final pts = _wireScreen(_scene.termPoint(w.t1), _scene.termPoint(w.t2));
      for (var i = 1; i < pts.length; i++) {
        if (_segDist(p, pts[i - 1], pts[i]) < 12) return w;
      }
    }
    return null;
  }

  _Obj? _hitObj(Offset p) {
    final list = _scene.objs.values.where((o) => o.draggable).toList()..sort((a, b) => b.z.compareTo(a.z));
    for (final o in list) {
      if (_objRect(o).contains(p)) return o;
    }
    return null;
  }

  bool _hitAny(Offset p) {
    if (!_lab.isLabActive) return false;
    return _hitTerminal(p) != null || _hitWire(p) != null || _hitObj(p) != null;
  }

  // ========================================================== INTERACTION

  /// HTML `onPointerDown()`.
  void _down(Offset p) {
    final s = _scene;
    final t = _hitTerminal(p);
    if (t != null) {
      final existing = s.wiresAt(t);
      if (existing.isNotEmpty) {
        final w = existing.first;
        _removeWire(w);
        _startWiring(w.t1 == t ? w.t2 : w.t1);
        s.active!.end = _Cam.onPlane(p, 0.5);
      } else {
        _startWiring(t);
      }
      _Audio.play(_Sound.click);
      setState(() {});
      return;
    }
    final w = _hitWire(p);
    if (w != null) {
      final d1 = (_Cam.v(s.termPoint(w.t1)) - p).distance;
      final d2 = (_Cam.v(s.termPoint(w.t2)) - p).distance;
      _removeWire(w);
      _startWiring(d1 < d2 ? w.t2 : w.t1);
      s.active!.end = _Cam.onPlane(p, 0.5);
      _Audio.play(_Sound.click);
      setState(() {});
      return;
    }
    final o = _hitObj(p);
    if (o == null) return;
    final wired = s.terms.any((d) => d.owner == o.id && s.wiresAt(d.id).isNotEmpty);
    if (wired) {
      _lab.showToast(_t('err_wire'), isError: true);
      return;
    }
    s.dragged = o;
    _fadeZone(o.id, 0.5);
    _Audio.play(_Sound.pickup);
    setState(() {});
  }

  /// HTML `onPointerMove()`.
  void _move(Offset p) {
    final s = _scene;
    final o = s.dragged;
    if (o != null) {
      final q = _Cam.onPlane(p, 0.5);
      if (q != null) {
        o.x = q.x.clamp(-14.0, 14.0);
        o.z = q.z.clamp(-9.5, 9.5);
      }
    } else if (s.active != null) {
      s.active!.end = _Cam.onPlane(p, 0.5);
      s.active!.hovered = _hitTerminal(p, exclude: s.active!.start);
    }
  }

  /// HTML `onPointerUp()`.
  void _up(Offset p) {
    final s = _scene;
    final o = s.dragged;
    if (o != null) {
      s.dragged = null;
      _fadeZone(null, 0);
      _handleDrop(o);
    }
    final a = s.active;
    if (a != null) {
      if (a.hovered != null) {
        _finishWiring(a.hovered!);
      } else {
        _cancelWiring();
      }
    }
    setState(() {});
  }

  void _cancelGesture() {
    final o = _scene.dragged;
    if (o != null) {
      _scene.dragged = null;
      _fadeZone(null, 0);
      _handleDrop(o);
    }
    if (_scene.active != null) _cancelWiring();
    if (mounted) setState(() {});
  }

  /// Fades the drop-zone ring(s) for [id] to [to] (others to 0) in 200 ms.
  void _fadeZone(String? id, double to) {
    final s = _scene;
    final from = [s.zoneCell, s.zoneLamp, s.zoneBench];
    final target = [
      id == 'cell' ? to : 0.0,
      id == 'lamp' ? to : 0.0,
      id == 'battery' || id == 'led' ? to : 0.0,
    ];
    s.tween(0.2, Curves.linear, (v) {
      s.zoneCell = from[0] + (target[0] - from[0]) * v;
      s.zoneLamp = from[1] + (target[1] - from[1]) * v;
      s.zoneBench = from[2] + (target[2] - from[2]) * v;
    });
  }

  /// HTML `handleDrop()`: snap into the holder / onto the bench, or spring
  /// back to the tray.
  void _handleDrop(_Obj o) {
    final s = _scene;
    final x0 = o.x, y0 = o.y, z0 = o.z, yaw0 = o.yaw, spin0 = o.spin;
    _V3? target;
    double? yaw, spin;
    var ok = false;
    if (o.id == 'cell') {
      if ((o.pos - s.objs['cellHolder']!.pos).length < 4) {
        target = const _V3(-5, 0.7, 5);
        yaw = 0;
        ok = true;
      }
    } else if (o.id == 'lamp') {
      if ((o.pos - s.objs['lampHolder']!.pos).length < 4) {
        target = const _V3(-5, 0.8, -5);
        spin = math.pi * 4;
        ok = true;
      }
    } else if ((o.pos - const _V3(-2, 0, 0)).length < 8) {
      ok = true;
    }

    if (ok) {
      _Audio.play(_Sound.drop);
      if (target != null) {
        final t = target;
        s.tween(0.6, Curves.easeOutQuad, (v) {
          o.x = x0 + (t.x - x0) * v;
          o.y = y0 + (t.y - y0) * v;
          o.z = z0 + (t.z - z0) * v;
        });
        if (yaw != null) {
          final y1 = yaw;
          s.tween(1.0, Curves.easeOutQuad, (v) => o.yaw = yaw0 + (y1 - yaw0) * v);
        }
        if (spin != null) {
          final s1 = spin;
          s.tween(1.0, Curves.easeOutQuad, (v) => o.spin = spin0 + (s1 - spin0) * v);
        }
      }
      _lab.after(const Duration(milliseconds: 800), _validateStep);
    } else {
      _Audio.play(_Sound.wrong);
      final h = o.home;
      s.tween(0.5, Curves.easeOutBack, (v) {
        o.x = x0 + (h.x - x0) * v;
        o.y = y0 + (h.y - y0) * v;
        o.z = z0 + (h.z - z0) * v;
      });
      final homeYaw = o.id == 'cell' ? math.pi / 2 : 0.0;
      s.tween(0.5, Curves.linear, (v) {
        o.yaw = yaw0 + (homeYaw - yaw0) * v;
        o.spin = spin0 * (1 - v);
      });
      _lab.after(const Duration(milliseconds: 600), _validateStep);
    }
  }

  // =============================================================== WIRING

  /// HTML `startWiring()`.
  void _startWiring(String id) {
    final type = _scene.term(id).type;
    _scene.active = _ActiveWire(id, type == '+' ? _wireRed : (type == '-' ? _wireBlack : _wireGreen));
  }

  /// HTML `finishWiring()`.
  void _finishWiring(String end) {
    final s = _scene;
    final a = s.active!;
    if (a.start == end) return _cancelWiring();
    final t1 = s.term(a.start).type, t2 = s.term(end).type;
    var colorStr = 'green';
    if (t1 == '+' || t2 == '+') colorStr = 'red';
    if (t1 == '-' || t2 == '-') colorStr = 'black';
    s.wires.add(_Wire(a.start, end, a.color, colorStr));
    s.active = null;
    s.sparks.add(_Spark(s.time, s.termPoint(end)));
    _Audio.play(_Sound.spark);
    _checkCircuit();
    _lab.after(const Duration(milliseconds: 500), _validateStep);
  }

  /// HTML `cancelWiring()`.
  void _cancelWiring() {
    _scene.active = null;
    _checkCircuit();
  }

  /// HTML `removeWire()`.
  void _removeWire(_Wire w) {
    _scene.wires.remove(w);
    _checkCircuit();
    _lab.after(const Duration(milliseconds: 500), _validateStep);
  }

  // ========================================================== VALIDATION

  bool _same(String lampT) => _scene.linked('holder_pos', lampT) && _scene.linked('holder_neg', lampT);

  /// HTML `checkCircuit()`.
  void _checkCircuit() {
    final s = _scene;
    var glowing = false, blocked = false;
    if (s.scenario == 0) {
      final hasPos = s.linked('holder_pos', 'lamp_t1') || s.linked('holder_pos', 'lamp_t2');
      final hasNeg = s.linked('holder_neg', 'lamp_t1') || s.linked('holder_neg', 'lamp_t2');
      glowing = hasPos &&
          hasNeg &&
          !_same('lamp_t1') &&
          !_same('lamp_t2') &&
          s.objs['cell']!.x < 0 &&
          s.objs['lamp']!.x < 0;
    } else {
      final correct = s.linked('bat_pos', 'led_pos') && s.linked('bat_neg', 'led_neg');
      final reverse = s.linked('bat_pos', 'led_neg') && s.linked('bat_neg', 'led_pos');
      glowing = correct;
      blocked = !correct && reverse;
    }
    s
      ..glowing = glowing
      ..blocked = blocked;
  }

  /// HTML `validateStep()`.
  void _validateStep() {
    if (!mounted) return;
    final s = _scene;
    if (s.finished) return;
    _checkCircuit();
    final step = s.step;
    var ok = false;
    if (s.scenario == 0) {
      ok = switch (step) {
        0 => s.objs['cell']!.x < 0,
        1 => s.objs['lamp']!.x < 0,
        2 => s.wires.any((w) =>
            w.colorStr == 'red' && ['lamp_t1', 'lamp_t2'].any((l) => w.t1 == l || w.t2 == l)),
        3 => s.glowing,
        4 => !s.glowing && (_same('lamp_t1') || _same('lamp_t2')) && s.wires.length == 2,
        _ => s.glowing,
      };
    } else {
      ok = switch (step) {
        0 => s.objs['battery']!.x < 5,
        1 => s.objs['led']!.x < 5,
        2 => s.linked('bat_pos', 'led_pos'),
        3 => s.glowing,
        4 => s.wires.isEmpty,
        5 => s.blocked,
        _ => s.glowing,
      };
    }
    final last = _data.steps.length - 1;
    setState(() {
      s.statusAt = s.time;
      if (ok) {
        _Audio.play(_Sound.correct);
        s.status = _Status.complete;
        if (step < last) {
          if (!_advancing) {
            _advancing = true;
            _lab.after(const Duration(milliseconds: 1000), () {
              if (!mounted) return;
              setState(() {
                _advancing = false;
                s.step = math.min(s.step + 1, last);
                s.status = _Status.pending;
                s.statusAt = s.time;
              });
            });
          }
        } else {
          s.finished = true;
          s.status = _Status.done;
          _lab.after(const Duration(milliseconds: 2000), _showObservation);
        }
      } else {
        s.status = _Status.error;
        final at = s.statusAt;
        _lab.after(const Duration(milliseconds: 1500), () {
          if (!mounted || s.status != _Status.error || s.statusAt != at) return;
          setState(() => s.status = _Status.pending);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => _buildLab(context);

  /// HTML `showObservation()` (the shell re-opens the sidebar).
  void _showObservation() {
    if (!mounted) return;
    final n = _scene.scenario + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t('analysis'),
      heading: () => _t('obs_head_$n'),
      body: () => _t('obs_body_$n'),
    );
  }
}

// ============================================================ STRINGS
//
// From the HTML `I18N` and `ZSL_DATA` objects (Telugu dropped). Labels the
// HTML drew on the canvas and sidebar readouts are translated here too.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Constructing a Simple Electrical Circuit',
    'app_subtitle': 'Class 7 • Electricity: Circuits and their Components',
    'scen_1': 'Scenario 1: Lighting an Incandescent Lamp',
    'scen_2': 'Scenario 2: Understanding Polarity with an LED',
    'curr_task': 'Current Task Instruction',
    'analysis': 'Analysis & Outcomes',
    'comp_tray': 'Component Tray',
    'elec_cell': 'Electric Cell',
    'cell_holder': 'Cell Holder',
    'lamp': 'Lamp',
    'lamp_holder': 'Lamp Holder',
    'bat_9v': 'Battery Pack',
    'led': 'LED',
    'err_wire': 'Please disconnect wires before moving components.',
    'inv_complete': 'Investigation Complete!',
    'th_title1': 'Concept: Complete Circuit',
    'th_title2': 'Concept: Polarity',
    'theory_1':
        'An electrical circuit needs a power source (cell), a load (lamp), and a continuous path (wires) connecting the positive and negative terminals. Electricity must travel from one terminal of the cell, through the load, and back to the other terminal without any breaks to form a closed circuit.',
    'theory_2':
        'An LED (Light Emitting Diode) has polarity. It only allows electricity to pass through in one direction. Long wire: Positive (+) terminal. Short wire: Negative (-) terminal. If connected backwards, it blocks the flow and will not glow.',
    'obs_head_1': 'Excellent Analysis!',
    'obs_body_1':
        'You have successfully constructed a closed electrical circuit.\n\n• The incandescent lamp glows only when a continuous, unbroken path exists.\n• Current flows from the positive terminal, through the lamp\'s filament (causing it to heat up and glow), and back to the negative terminal.\n• Connecting both wires to a single terminal creates an incorrect or short circuit, preventing the lamp from functioning.',
    'obs_head_2': 'Great Observation!',
    'obs_body_2':
        'You have demonstrated the property of polarity in electronic components.\n\n• Unlike incandescent bulbs, LEDs allow electric current to flow in only one direction.\n• Connecting the longer leg (anode) to the positive terminal and the shorter leg (cathode) to the negative terminal forms a correct, glowing circuit.\n• Reversing the connection blocks the current completely, protecting the circuit but producing no light.',
    // Sidebar readouts (not in the HTML).
    'circuit_status': 'Circuit Status',
    'components': 'Components',
    'in_tray': 'In tray',
    'placed': 'Placed',
    'on_bench': 'On workbench',
    'state_glowing': 'Glowing',
    'state_off': 'Not glowing',
    'state_blocked': 'Blocked (connected backwards)',
    'wires_connected': 'Wires connected',
    'no_wires': 'No wires connected yet.',
    't_holder_pos': 'Cell Holder (+)',
    't_holder_neg': 'Cell Holder (-)',
    't_lamp_t1': 'Lamp Holder terminal 1',
    't_lamp_t2': 'Lamp Holder terminal 2',
    't_bat_pos': 'Battery (+)',
    't_bat_neg': 'Battery (-)',
    't_led_pos': 'LED long wire (+)',
    't_led_neg': 'LED short wire (-)',
  },
  'hi': {
    'app_title': 'एक साधारण विद्युत परिपथ का निर्माण',
    'app_subtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'scen_1': 'परिदृश्य 1: एक तापदीप्त लैंप जलाना',
    'scen_2': 'परिदृश्य 2: एलईडी के साथ ध्रुवीयता को समझना',
    'curr_task': 'वर्तमान कार्य निर्देश',
    'analysis': 'विश्लेषण और परिणाम',
    'comp_tray': 'घटक ट्रे',
    'elec_cell': 'विद्युत सेल',
    'cell_holder': 'सेल होल्डर',
    'lamp': 'लैंप',
    'lamp_holder': 'लैंप होल्डर',
    'bat_9v': 'बैटरी पैक',
    'led': 'एलईडी (LED)',
    'err_wire': 'घटकों को ले जाने से पहले कृपया तारों को डिस्कनेक्ट करें।',
    'inv_complete': 'अन्वेषण पूर्ण!',
    'th_title1': 'अवधारणा: पूर्ण परिपथ',
    'th_title2': 'अवधारणा: ध्रुवीयता',
    'theory_1':
        'विद्युत परिपथ को ऊर्जा स्रोत (सेल), लोड (लैंप), और धनात्मक और ऋणात्मक टर्मिनलों को जोड़ने वाले एक निरंतर पथ (तारों) की आवश्यकता होती है। बिजली को सेल के एक टर्मिनल से लोड के माध्यम से, और बिना किसी रुकावट के दूसरे टर्मिनल तक वापस जाना चाहिए ताकि एक बंद परिपथ बन सके।',
    'theory_2':
        'एक एलईडी (लाइट एमिटिंग डायोड) में ध्रुवीयता होती है। यह केवल एक दिशा में बिजली को गुजरने देता है। लंबा तार: धनात्मक (+) टर्मिनल। छोटा तार: ऋणात्मक (-) टर्मिनल। यदि उल्टा जोड़ा जाता है, तो यह प्रवाह को रोकता है और नहीं जलता है।',
    'obs_head_1': 'उत्कृष्ट विश्लेषण!',
    'obs_body_1':
        'आपने सफलतापूर्वक एक बंद विद्युत परिपथ का निर्माण किया है।\n\n• तापदीप्त लैंप केवल तभी जलता है जब एक निरंतर, अटूट पथ मौजूद हो।\n• करंट धनात्मक टर्मिनल से बहता है, लैंप के फिलामेंट से होकर (जिससे यह गर्म होता है और चमकता है), और वापस ऋणात्मक टर्मिनल की ओर जाता है।\n• दोनों तारों को एक ही टर्मिनल से जोड़ने पर गलत या शॉर्ट सर्किट बनता है, जिससे लैंप काम नहीं करता है।',
    'obs_head_2': 'महान अवलोकन!',
    'obs_body_2':
        'आपने इलेक्ट्रॉनिक घटकों में ध्रुवीयता के गुण का प्रदर्शन किया है।\n\n• तापदीप्त बल्बों के विपरीत, एलईडी विद्युत धारा को केवल एक दिशा में बहने देते हैं।\n• लंबे पैर (एनोड) को धनात्मक टर्मिनल और छोटे पैर (कैथोड) को ऋणात्मक टर्मिनल से जोड़ने पर एक सही, जलता हुआ परिपथ बनता है।\n• कनेक्शन को उलटने से करंट पूरी तरह से रुक जाता है, परिपथ की रक्षा होती है लेकिन कोई रोशनी नहीं होती है।',
    'circuit_status': 'परिपथ की स्थिति',
    'components': 'घटक',
    'in_tray': 'ट्रे में',
    'placed': 'रखा गया',
    'on_bench': 'कार्यक्षेत्र पर',
    'state_glowing': 'जल रहा है',
    'state_off': 'नहीं जल रहा',
    'state_blocked': 'अवरुद्ध (उल्टा जुड़ा)',
    'wires_connected': 'जुड़े हुए तार',
    'no_wires': 'अभी तक कोई तार नहीं जुड़ा है।',
    't_holder_pos': 'सेल होल्डर (+)',
    't_holder_neg': 'सेल होल्डर (-)',
    't_lamp_t1': 'लैंप होल्डर टर्मिनल 1',
    't_lamp_t2': 'लैंप होल्डर टर्मिनल 2',
    't_bat_pos': 'बैटरी (+)',
    't_bat_neg': 'बैटरी (-)',
    't_led_pos': 'एलईडी लंबा तार (+)',
    't_led_neg': 'एलईडी छोटा तार (-)',
  },
};

// ========================================================== SCENARIOS
//
// `action` = HTML `taskText`, `observation` = HTML `obsText`. Concepts are
// short titles written for the shell's target card.

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To correctly connect an electric cell, wires, and an incandescent lamp to form a complete circuit and make the lamp glow.',
      steps: [
        LabStep(
          concept: 'Place the Cell',
          action: 'DRAG the electric cell from the component tray and DROP it into the cell holder on the workbench.',
          observation: 'The cell snaps into place in the holder, with the positive terminal (+) correctly oriented.',
        ),
        LabStep(
          concept: 'Place the Lamp',
          action: 'DRAG the incandescent lamp from the tray and DROP it into the lamp holder on the workbench.',
          observation: 'The lamp screws into the holder and is ready for connection.',
        ),
        LabStep(
          concept: 'Red Wire (+)',
          action:
              "DRAG the red wire's end from the positive (+) terminal of the cell holder and CONNECT it to one of the terminals on the lamp holder.",
          observation: 'The wire visually connects the positive terminal of the cell to one terminal of the lamp.',
        ),
        LabStep(
          concept: 'Black Wire (-)',
          action:
              "DRAG the black wire's end from the negative (-) terminal of the cell holder and CONNECT it to the other, empty terminal on the lamp holder.",
          observation:
              "The circuit is completed, and the incandescent lamp's filament glows a bright yellow, illuminating the area around it.",
        ),
        LabStep(
          concept: 'Break the Circuit',
          action:
              "CLICK on the red wire's connection at the lamp holder to disconnect it. DRAG its free end and CONNECT it to the same terminal as the black wire.",
          observation:
              "The lamp immediately stops glowing because the circuit is no longer complete. Electricity is not flowing through the lamp's filament.",
        ),
        LabStep(
          concept: 'Rebuild the Circuit',
          action: 'Reconnect the wires correctly to make the lamp glow again.',
          observation:
              'The student successfully reconstructs the working circuit, reinforcing the concept of a complete path.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To discover that some components, like an LED, only work when connected in a specific direction in a circuit.',
      steps: [
        LabStep(
          concept: 'Place the Battery',
          action:
              'DRAG the two-cell battery from the component tray and DROP it onto the workbench. Notice the clearly marked positive (+) and negative (-) terminals.',
          observation: 'The battery is placed on the workbench, ready to be used as the power source.',
        ),
        LabStep(
          concept: 'Place the LED',
          action:
              'DRAG the LED (Light Emitting Diode) from the tray onto the workbench. Observe that it has one long wire (positive) and one short wire (negative).',
          observation:
              'The LED is placed on the workbench. The difference in the length of its two wire leads is clearly visible.',
        ),
        LabStep(
          concept: 'Red Wire to Long Leg',
          action:
              'DRAG the red wire from the positive (+) terminal of the battery and CONNECT it to the long wire (positive terminal) of the LED.',
          observation: 'The positive side of the circuit is connected correctly.',
        ),
        LabStep(
          concept: 'Black Wire to Short Leg',
          action:
              'DRAG the black wire from the negative (-) terminal of the battery and CONNECT it to the short wire (negative terminal) of the LED.',
          observation: 'The circuit is complete, and the LED lights up with a bright red glow.',
        ),
        LabStep(
          concept: 'Disconnect Both Wires',
          action:
              "Now, let's see what happens if we reverse the connections. DISCONNECT both wires from the LED by clicking on them.",
          observation: 'The LED turns off, and the wires are free to be reconnected.',
        ),
        LabStep(
          concept: 'Reverse the Connections',
          action:
              "CONNECT the red wire from the battery's positive (+) terminal to the LED's short wire. Then, CONNECT the black wire from the battery's negative (-) terminal to the LED's long wire.",
          observation:
              'The circuit is complete, but the LED does not glow. This demonstrates that the LED was connected backward.',
        ),
        LabStep(
          concept: 'Correct Polarity',
          action:
              'Reconnect the LED correctly to confirm your understanding: positive (+) to long wire, negative (-) to short wire.',
          observation:
              'The LED lights up brightly when the correct connections are restored, reinforcing the learning outcome.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'एक पूर्ण परिपथ बनाने और लैंप को जलाने के लिए विद्युत सेल, तारों और एक तापदीप्त लैंप को सही ढंग से जोड़ना।',
      steps: [
        LabStep(
          concept: 'सेल रखें',
          action: 'घटक ट्रे से विद्युत सेल को खींचें (DRAG) और इसे कार्यक्षेत्र पर सेल होल्डर में छोड़ें (DROP)।',
          observation: 'सेल होल्डर में अपनी जगह पर फिट हो जाता है, धनात्मक टर्मिनल (+) सही ढंग से उन्मुख होता है।',
        ),
        LabStep(
          concept: 'लैंप रखें',
          action: 'ट्रे से तापदीप्त लैंप को खींचें और कार्यक्षेत्र पर लैंप होल्डर में छोड़ें।',
          observation: 'लैंप होल्डर में कस जाता है और कनेक्शन के लिए तैयार है।',
        ),
        LabStep(
          concept: 'लाल तार (+)',
          action: 'सेल होल्डर के धनात्मक (+) टर्मिनल से लाल तार के सिरे को खींचें और इसे लैंप होल्डर के किसी एक टर्मिनल से जोड़ें।',
          observation: 'तार सेल के धनात्मक टर्मिनल को लैंप के एक टर्मिनल से जोड़ता है।',
        ),
        LabStep(
          concept: 'काला तार (-)',
          action: 'सेल होल्डर के ऋणात्मक (-) टर्मिनल से काले तार के सिरे को खींचें और इसे लैंप होल्डर के दूसरे खाली टर्मिनल से जोड़ें।',
          observation:
              'परिपथ पूरा हो गया है, और तापदीप्त लैंप का फिलामेंट चमकीला पीला जलता है, जो अपने आसपास के क्षेत्र को रोशन करता है।',
        ),
        LabStep(
          concept: 'परिपथ तोड़ें',
          action:
              'लैंप होल्डर पर लाल तार के कनेक्शन पर क्लिक करके उसे डिस्कनेक्ट करें। इसके मुक्त सिरे को खींचें और काले तार वाले उसी टर्मिनल से जोड़ें।',
          observation:
              'लैंप तुरंत जलना बंद कर देता है क्योंकि परिपथ अब पूरा नहीं है। बिजली लैंप के फिलामेंट से प्रवाहित नहीं हो रही है।',
        ),
        LabStep(
          concept: 'परिपथ फिर से बनाएँ',
          action: 'लैंप को फिर से जलाने के लिए तारों को सही ढंग से फिर से जोड़ें।',
          observation: 'छात्र सफलतापूर्वक कार्यशील परिपथ का पुनर्निर्माण करता है, जिससे एक पूर्ण पथ की अवधारणा सुदृढ़ होती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह खोजना कि कुछ घटक, जैसे एलईडी, केवल तभी काम करते हैं जब परिपथ में एक विशिष्ट दिशा में जुड़े हों।',
      steps: [
        LabStep(
          concept: 'बैटरी रखें',
          action:
              'घटक ट्रे से दो-सेल बैटरी को खींचें और इसे कार्यक्षेत्र पर छोड़ें। स्पष्ट रूप से चिह्नित धनात्मक (+) और ऋणात्मक (-) टर्मिनलों पर ध्यान दें।',
          observation: 'बैटरी कार्यक्षेत्र पर रखी गई है, ऊर्जा स्रोत के रूप में उपयोग के लिए तैयार है।',
        ),
        LabStep(
          concept: 'एलईडी रखें',
          action: 'ट्रे से एलईडी को कार्यक्षेत्र पर खींचें। ध्यान दें कि इसमें एक लंबा तार (धनात्मक) और एक छोटा तार (ऋणात्मक) है।',
          observation: 'एलईडी को कार्यक्षेत्र पर रखा गया है। इसके दोनों तारों की लंबाई में अंतर स्पष्ट रूप से दिखाई देता है।',
        ),
        LabStep(
          concept: 'लाल तार लंबे पैर से',
          action: 'बैटरी के धनात्मक (+) टर्मिनल से लाल तार खींचें और इसे एलईडी के लंबे तार (धनात्मक टर्मिनल) से जोड़ें।',
          observation: 'परिपथ का धनात्मक पक्ष सही ढंग से जुड़ा हुआ है।',
        ),
        LabStep(
          concept: 'काला तार छोटे पैर से',
          action: 'बैटरी के ऋणात्मक (-) टर्मिनल से काले तार को खींचें और इसे एलईडी के छोटे तार (ऋणात्मक टर्मिनल) से जोड़ें।',
          observation: 'परिपथ पूरा हो गया है, और एलईडी चमकीले लाल रंग के साथ जलती है।',
        ),
        LabStep(
          concept: 'दोनों तार हटाएँ',
          action: 'अब देखते हैं कि कनेक्शन उलटने पर क्या होता है। एलईडी से दोनों तारों पर क्लिक करके उन्हें डिस्कनेक्ट करें।',
          observation: 'एलईडी बंद हो जाती है, और तारों को फिर से जोड़ने के लिए स्वतंत्र हैं।',
        ),
        LabStep(
          concept: 'कनेक्शन उलटें',
          action:
              'बैटरी के धनात्मक (+) टर्मिनल से लाल तार को एलईडी के छोटे तार से जोड़ें। फिर, बैटरी के ऋणात्मक (-) टर्मिनल से काले तार को एलईडी के लंबे तार से जोड़ें।',
          observation: 'परिपथ पूरा है, लेकिन एलईडी नहीं जलती है। यह दर्शाता है कि एलईडी को उल्टा जोड़ा गया था।',
        ),
        LabStep(
          concept: 'सही ध्रुवीयता',
          action:
              'अपनी समझ की पुष्टि करने के लिए एलईडी को सही ढंग से फिर से जोड़ें: धनात्मक (+) को लंबे तार से, ऋणात्मक (-) को छोटे तार से।',
          observation: 'सही कनेक्शन बहाल होने पर एलईडी चमकती है, जिससे सीखने का परिणाम मजबूत होता है।',
        ),
      ],
    ),
  ],
};

// ======================================================== SCENE MODEL

const Size _design = Size(1000, 560);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double get length => math.sqrt(x * x + y * y + z * z);
}

/// The HTML PerspectiveCamera at (0, 15, 20) looking at the origin
/// (FOV 45), shifted 1.5 units so the component tray clears the tools.
class _Cam {
  _Cam._();
  static const double f = 1000, cx = 500, cy = 232, shift = -1.5;

  static double depth(double y, double z) => 25 - 0.6 * y - 0.8 * z;

  static Offset p(double x, double y, double z) {
    final d = depth(y, z);
    return Offset(cx + f * (x + shift) / d, cy - f * (0.8 * y - 0.6 * z) / d);
  }

  static Offset v(_V3 a) => p(a.x, a.y, a.z);

  /// Pixels per world unit at a point.
  static double k(_V3 a) => f / depth(a.y, a.z);

  /// Screen point -> world point on the horizontal plane y = [h]
  /// (the HTML `dragPlane`).
  static _V3? onPlane(Offset s, double h) {
    final a = (s.dx - cx) / f;
    final b = (cy - s.dy) / f;
    final dy = 0.8 * b - 0.6;
    if (dy >= -1e-6) return null;
    final t = (h - 15) / dy;
    if (t <= 0) return null;
    return _V3(a * t - shift, h, 20 + t * (-0.6 * b - 0.8));
  }
}

/// A terminal (HTML `createTerminal`): owner object + local position.
@immutable
class _TermDef {
  const _TermDef(this.id, this.owner, this.local, this.type, this.scale, this.color);
  final String id;
  final String owner;
  final _V3 local;

  /// '+', '-' or 't' (lamp holder).
  final String type;
  final double scale;
  final Color color;
}

const Map<int, List<_TermDef>> _termDefs = {
  0: [
    _TermDef('holder_pos', 'cellHolder', _V3(2.4, 0.5, 0), '+', 1, Color(0xFFEF4444)),
    _TermDef('holder_neg', 'cellHolder', _V3(-2.4, 0.5, 0), '-', 1, Color(0xFF111111)),
    _TermDef('lamp_t1', 'lampHolder', _V3(1.3, 0.4, 0), 't', 1, Color(0xFF94A3B8)),
    _TermDef('lamp_t2', 'lampHolder', _V3(-1.3, 0.4, 0), 't', 1, Color(0xFF94A3B8)),
  ],
  1: [
    _TermDef('bat_pos', 'battery', _V3(-2.6, 0.6, -0.8), '+', 0.8, Color(0xFFEF4444)),
    _TermDef('bat_neg', 'battery', _V3(-2.6, 0.6, 0.8), '-', 0.8, Color(0xFF111111)),
    _TermDef('led_pos', 'led', _V3(0.2, -0.9, 0), '+', 0.6, Color(0xFFEF4444)),
    _TermDef('led_neg', 'led', _V3(-0.2, -0.4, 0), '-', 0.6, Color(0xFF111111)),
  ],
};

class _Obj {
  _Obj(this.id, this.home, {this.yaw = 0, this.draggable = true})
      : x = home.x,
        y = home.y,
        z = home.z;

  final String id;
  final _V3 home;
  final bool draggable;
  double x, y, z;

  /// Cell: axis angle on the table (pi/2 = along z in the tray, 0 = along x).
  double yaw;

  /// Lamp: rotation about its vertical axis (screwing in).
  double spin = 0;

  _V3 get pos => _V3(x, y, z);
}

/// Wire colours (HTML `startWiring`): + red, - black, lamp terminal green.
const Color _wireRed = Color(0xFFEF4444);
const Color _wireBlack = Color(0xFF111111);
const Color _wireGreen = Color(0xFF22C55E);

class _Wire {
  _Wire(this.t1, this.t2, this.color, this.colorStr);
  final String t1;
  final String t2;
  final Color color;
  final String colorStr;
}

class _ActiveWire {
  _ActiveWire(this.start, this.color);
  final String start;
  final Color color;
  _V3? end;
  String? hovered;
}

class _Spark {
  _Spark(this.at, this.pos);
  final double at;
  final _V3 pos;
}

/// Minimal TWEEN.js replacement driven by the scene clock.
class _Anim {
  _Anim(this.start, this.dur, this.curve, this.apply);
  final double start;
  final double dur;
  final Curve curve;
  final void Function(double v) apply;
}

enum _Status { pending, complete, done, error }

class _CircuitScene {
  int scenario = 0;
  int step = 0;
  bool finished = false;
  double time = 0;

  final Map<String, _Obj> objs = {};
  final List<_Wire> wires = [];
  final List<_Spark> sparks = [];
  final List<_Anim> anims = [];
  _Obj? dragged;
  _ActiveWire? active;

  bool glowing = false;
  bool blocked = false;
  double glowLevel = 0;

  _Status status = _Status.pending;
  double statusAt = 0;

  /// Drop-zone ring opacities (HTML `STATE.zones`).
  double zoneCell = 0, zoneLamp = 0, zoneBench = 0;

  List<_TermDef> get terms => _termDefs[scenario]!;

  _TermDef term(String id) => terms.firstWhere((t) => t.id == id);

  /// Terminal base (group origin) in world space.
  _V3 termBase(String id) {
    final t = term(id);
    final o = objs[t.owner]!;
    return o.pos + t.local;
  }

  /// HTML hit mesh centre (y + 0.5 x scale): the wire end point.
  _V3 termPoint(String id) => termBase(id) + _V3(0, 0.5 * term(id).scale, 0);

  List<_Wire> wiresAt(String id) => [for (final w in wires) if (w.t1 == id || w.t2 == id) w];

  bool linked(String a, String b) => wires.any((w) => (w.t1 == a && w.t2 == b) || (w.t1 == b && w.t2 == a));

  /// HTML `clearScene()` + the factories of `loadScenario()`.
  void build() {
    objs.clear();
    wires.clear();
    sparks.clear();
    anims.clear();
    dragged = null;
    active = null;
    glowing = false;
    blocked = false;
    glowLevel = 0;
    zoneCell = zoneLamp = zoneBench = 0;
    step = 0;
    finished = false;
    status = _Status.pending;
    statusAt = time;
    if (scenario == 0) {
      objs['cellHolder'] = _Obj('cellHolder', const _V3(-5, 0, 5), draggable: false);
      objs['lampHolder'] = _Obj('lampHolder', const _V3(-5, 0, -5), draggable: false);
      objs['cell'] = _Obj('cell', const _V3(8, 1.3, 5), yaw: math.pi / 2);
      objs['lamp'] = _Obj('lamp', const _V3(8, 0.8, 0));
    } else {
      objs['battery'] = _Obj('battery', const _V3(8, 0, 5));
      objs['led'] = _Obj('led', const _V3(8, 0.9, -2));
    }
  }

  void tween(double dur, Curve curve, void Function(double v) apply) {
    anims.add(_Anim(time, dur, curve, apply));
  }

  /// Advances tweens, sparks and the glow fade (called every frame).
  void tick(double dt) {
    for (final a in List.of(anims)) {
      final t = ((time - a.start) / a.dur).clamp(0.0, 1.0);
      a.apply(a.curve.transform(t));
      if (t >= 1) anims.remove(a);
    }
    sparks.removeWhere((s) => time - s.at > 0.25);
    final target = glowing ? 1.0 : 0.0;
    final k = (dt / 0.3).clamp(0.0, 1.0);
    glowLevel += (target - glowLevel) * k;
  }
}

/// Claims a touch only when it starts on a component, terminal or wire,
/// so pans / pinches elsewhere still reach the zoomable canvas and short
/// drags are never swallowed by the pan slop.
class _ClaimRecognizer extends OneSequenceGestureRecognizer {
  _ClaimRecognizer();

  bool Function(Offset local)? hit;
  void Function(Offset local)? onDown;
  void Function(Offset local)? onMove;
  void Function(Offset local)? onUp;
  VoidCallback? onCancel;
  int? _pointer;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_pointer != null || !(hit?.call(event.localPosition) ?? false)) return;
    super.addAllowedPointer(event);
    _pointer = event.pointer;
    resolve(GestureDisposition.accepted);
    onDown?.call(event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _pointer) return;
    if (event is PointerMoveEvent) {
      onMove?.call(event.localPosition);
    } else if (event is PointerUpEvent) {
      _pointer = null;
      onUp?.call(event.localPosition);
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      _pointer = null;
      onCancel?.call();
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer == _pointer) {
      _pointer = null;
      onCancel?.call();
    }
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'circuit object drag';
}

// ============================================================ PAINTER

/// Camera position in world space (for face / cap visibility).
const _V3 _camPos = _V3(1.5, 15, 20);

/// HTML `updateTemporaryWire()` curve: Catmull-Rom through start, a mid
/// point lifted by min(dist * 0.25, 1.5), and end.
List<_V3> _wireCurve(_V3 a, _V3 b, {int n = 20}) {
  final dist = (b - a).length;
  final mid = (a + b) * 0.5 + _V3(0, math.min(dist * 0.25, 1.5), 0);
  final pts = [a, mid, b];
  final out = <_V3>[];
  for (var k = 0; k <= n; k++) {
    final u = k / n * 2;
    final i = math.min(u.floor(), 1);
    final t = u - i;
    final p0 = pts[math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[math.min(i + 2, 2)];
    double c(double a0, double a1, double a2, double a3) =>
        0.5 *
        (2 * a1 +
            (-a0 + a2) * t +
            (2 * a0 - 5 * a1 + 4 * a2 - a3) * t * t +
            (-a0 + 3 * a1 - 3 * a2 + a3) * t * t * t);
    out.add(_V3(c(p0.x, p1.x, p2.x, p3.x), c(p0.y, p1.y, p2.y, p3.y), c(p0.z, p1.z, p2.z, p3.z)));
  }
  return out;
}

List<Offset> _wireScreen(_V3 a, _V3 b) => [for (final q in _wireCurve(a, b)) _Cam.v(q)];

double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

Rect _boundsOf(Iterable<_V3> pts) {
  var r = Rect.zero;
  var first = true;
  for (final q in pts) {
    final s = _Cam.v(q);
    r = first ? Rect.fromLTWH(s.dx, s.dy, 0, 0) : r.expandToInclude(Rect.fromLTWH(s.dx, s.dy, 0, 0));
    first = false;
  }
  return r;
}

/// Screen rect of a draggable component (hit-testing, same geometry as drawn).
Rect _objRect(_Obj o) {
  final c = o.pos;
  switch (o.id) {
    case 'cell':
      final u = _V3(math.cos(o.yaw), 0, math.sin(o.yaw));
      return _boundsOf([c + u * 1.55, c - u * 1.3]).inflate(0.8 * _Cam.k(c) + 4);
    case 'lamp':
      final k = _Cam.k(c);
      return _boundsOf([c, c + const _V3(0, 2.1, 0)]).inflate(0.85 * k);
    case 'battery':
      return _boundsOf([
        for (final x in [-2.6, 2.6])
          for (final y in [0.0, 1.6])
            for (final z in [-1.8, 1.8]) c + _V3(x, y, z),
      ]).inflate(4);
    default:
      return _boundsOf([c + const _V3(-0.6, -0.9, 0), c + const _V3(0.6, 2.5, 0)]).inflate(8);
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
  }) : super(repaint: repaint);

  final _CircuitScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    canvas.drawRect(labBleed(size), Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0));
    _paintTable(canvas);
    _paintTray(canvas);
    _paintZones(canvas);

    final g = s.glowLevel;
    if (g > 0.01) {
      final o = s.objs[s.scenario == 0 ? 'lamp' : 'led'];
      if (o != null) {
        final ground = _V3(o.x, 0.02, o.z);
        final c = _Cam.v(ground);
        final k = _Cam.k(ground);
        final color = s.scenario == 0 ? const Color(0xFFFFDDAA) : const Color(0xFFFF2020);
        final r = (s.scenario == 0 ? 6.5 : 4.0) * k;
        final rect = Rect.fromCenter(center: c, width: 2 * r, height: 1.2 * r);
        canvas.drawOval(
          rect,
          Paint()
            ..blendMode = BlendMode.plus
            ..shader = RadialGradient(colors: [
              color.withValues(alpha: 0.42 * g),
              color.withValues(alpha: 0.12 * g),
              color.withValues(alpha: 0),
            ], stops: const [0, 0.45, 1]).createShader(rect),
        );
      }
    }

    // Components, back to front.
    final objs = s.objs.values.toList()..sort((a, b) => a.z.compareTo(b.z));
    for (final o in objs) {
      _drawObject(canvas, o, s);
    }

    // Wires (glowing circuits pulse yellow, HTML flow animation).
    final pulse = s.glowing ? (math.sin(s.time * 3) * 0.5 + 0.5) * 0.5 : 0.0;
    for (final w in s.wires) {
      _drawWire(canvas, s.termPoint(w.t1), s.termPoint(w.t2), w.color, pulse);
    }
    final a = s.active;
    if (a != null && a.end != null && (a.end! - s.termPoint(a.start)).length > 0.1) {
      _drawWire(canvas, s.termPoint(a.start), a.end!, a.color, 0);
      if (a.hovered != null) {
        final hp = _Cam.v(s.termPoint(a.hovered!));
        canvas.drawCircle(
          hp,
          18,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = _Colors.zslYellow.withValues(alpha: 0.9),
        );
      }
    }
    for (final sp in s.sparks) {
      final v = Curves.easeOutQuad.transform(((s.time - sp.at) / 0.2).clamp(0.0, 1.0));
      final c = _Cam.v(sp.pos);
      final r = 0.5 * _Cam.k(sp.pos) * (1 + v);
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFFFAA).withValues(alpha: 1 - v));
      labGlow(canvas, c, r * 1.8, const Color(0xFFFFFF88), intensity: 1 - v);
    }

    if (s.blocked && s.objs['led'] != null) _blockedIcon(canvas, _Cam.v(s.objs['led']!.pos + const _V3(0, 2.5, 0)) - const Offset(0, 62));
    if (showLabels) _paintLabels(canvas);
  }

  // ---------------------------------------------------------------- table

  /// HTML table: BoxGeometry(30, 0.5, 20), colour 0x8b5a2b.
  void _paintTable(Canvas canvas) {
    const wood = Color(0xFF8B5A2B);
    final top = _quad3(const _V3(-15, 0, -10), const _V3(15, 0, -10), const _V3(15, 0, 10), const _V3(-15, 0, 10));
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, -0.25), labShade(wood, 0.06), wood],
          stops: const [0, 0.55, 1],
        ).createShader(top.getBounds()),
    );
    // Subtle plank seams running across the bench.
    final seam = Paint()
      ..color = const Color(0xFF5C3A1A).withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    for (var z = -7.5; z < 10; z += 2.5) {
      canvas.drawLine(_Cam.p(-15, 0, z), _Cam.p(15, 0, z), seam);
    }
    final grain = Paint()..strokeWidth = 0.8;
    final rnd = math.Random(5);
    for (var i = 0; i < 70; i++) {
      final z = -10 + rnd.nextDouble() * 20;
      final x0 = -15 + rnd.nextDouble() * 22;
      grain.color = (rnd.nextBool() ? const Color(0xFFA0522D) : const Color(0xFF6B4226))
          .withValues(alpha: 0.18 + rnd.nextDouble() * 0.2);
      canvas.drawLine(_Cam.p(x0, 0, z), _Cam.p(x0 + 3 + rnd.nextDouble() * 6, 0, z), grain);
    }
    canvas.drawPath(
      top,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.45, -0.2),
          radius: 0.9,
          colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
        ).createShader(top.getBounds()),
    );
    final front = _quad3(const _V3(-15, 0, 10), const _V3(15, 0, 10), const _V3(15, -0.5, 10), const _V3(-15, -0.5, 10));
    canvas.drawPath(front, Paint()..color = labShade(wood, -0.35));
    canvas.drawLine(_Cam.p(-15, 0, -10), _Cam.p(15, 0, -10), Paint()..color = const Color(0x55FFE0B0)..strokeWidth = 1.5);
  }

  /// HTML component tray: BoxGeometry(8, 0.1, 18) at (8, 0.05, 0), 0x334155.
  void _paintTray(Canvas canvas) {
    const c = Color(0xFF334155);
    final top = _quad3(const _V3(4, 0.1, -9), const _V3(12, 0.1, -9), const _V3(12, 0.1, 9), const _V3(4, 0.1, 9));
    final left = _quad3(const _V3(4, 0.1, -9), const _V3(4, 0.1, 9), const _V3(4, 0, 9), const _V3(4, 0, -9));
    final front = _quad3(const _V3(4, 0.1, 9), const _V3(12, 0.1, 9), const _V3(12, 0, 9), const _V3(4, 0, 9));
    canvas.drawPath(
      Path.from(top).shift(const Offset(-4, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(left, Paint()..color = labShade(c, -0.4));
    canvas.drawPath(front, Paint()..color = labShade(c, -0.3));
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(c, -0.15), labShade(c, 0.08)],
        ).createShader(top.getBounds()),
    );
    canvas.drawPath(top, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x6694A3B8));
  }

  /// HTML drop-zone rings (RingGeometry 1.5..1.8, blue 0x3b82f6).
  void _paintZones(Canvas canvas) {
    final s = scene;
    void ring(_V3 c, double o) {
      if (o <= 0.01) return;
      final path = Path();
      for (var i = 0; i <= 48; i++) {
        final a = i / 48 * math.pi * 2;
        final q = _Cam.p(c.x + 1.65 * math.cos(a), c.y, c.z + 1.65 * math.sin(a));
        i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
      }
      final k = _Cam.k(c);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.3 * k..color = const Color(0xFF3B82F6).withValues(alpha: o));
      canvas.drawPath(path, Paint()..color = const Color(0xFF3B82F6).withValues(alpha: o * 0.18));
    }

    ring(const _V3(-5, 0.1, 5), s.zoneCell);
    ring(const _V3(-5, 0.1, -5), s.zoneLamp);
    ring(const _V3(-2, 0.1, 0), s.zoneBench);
  }

  // ---------------------------------------------------------------- labels

  void _label(Canvas canvas, String key, _V3 at) {
    final c = _Cam.v(at);
    labText(
      canvas,
      _t(key),
      c,
      size: 14,
      weight: FontWeight.w700,
      color: Colors.white,
      background: const Color(0xD90F172A),
      border: const Color(0x33FFFFFF),
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1))],
    );
  }

  /// HTML `addLabel()` chips (positions nudged so they do not cover parts).
  void _paintLabels(Canvas canvas) {
    final s = scene;
    _label(canvas, 'comp_tray', const _V3(8, 0.55, -8.2));
    for (final o in s.objs.values) {
      switch (o.id) {
        case 'cellHolder':
          _label(canvas, 'cell_holder', o.pos + const _V3(0, 0, 1.95));
        case 'lampHolder':
          _label(canvas, 'lamp_holder', o.pos + const _V3(0, 0, 2.5));
        case 'cell':
          _label(canvas, 'elec_cell', o.pos + const _V3(0, 1.5, 0));
        case 'lamp':
          _label(canvas, 'lamp', o.pos + const _V3(0, 2.4, 0));
        case 'battery':
          _label(canvas, 'bat_9v', o.pos + const _V3(0, 2.5, 0));
        case 'led':
          _label(canvas, 'led', o.pos + const _V3(0, 3, 0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
}

// ------------------------------------------------------------ helpers

Path _quad3(_V3 a, _V3 b, _V3 c, _V3 d) {
  final pa = _Cam.v(a), pb = _Cam.v(b), pc = _Cam.v(c), pd = _Cam.v(d);
  return Path()
    ..moveTo(pa.dx, pa.dy)
    ..lineTo(pb.dx, pb.dy)
    ..lineTo(pc.dx, pc.dy)
    ..lineTo(pd.dx, pd.dy)
    ..close();
}

/// Wire tube (radius 0.12), with a contact shadow on the bench.
void _drawWire(Canvas canvas, _V3 a, _V3 b, Color color, double pulse) {
  final pts = _wireCurve(a, b);
  final path = Path();
  final shadow = Path();
  for (var i = 0; i < pts.length; i++) {
    final q = _Cam.v(pts[i]);
    final sh = _Cam.p(pts[i].x - pts[i].y * 0.45, 0.01, pts[i].z - pts[i].y * 0.45);
    if (i == 0) {
      path.moveTo(q.dx, q.dy);
      shadow.moveTo(sh.dx, sh.dy);
    } else {
      path.lineTo(q.dx, q.dy);
      shadow.lineTo(sh.dx, sh.dy);
    }
  }
  final w = 0.24 * _Cam.k((a + b) * 0.5);
  Paint st(Color c, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;
  canvas.drawPath(shadow, st(Colors.black.withValues(alpha: 0.25), w)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  canvas.drawPath(path, st(labShade(color, -0.5), w + 2));
  canvas.drawPath(path, st(color, w));
  final hi = color.computeLuminance() < 0.05 ? const Color(0x88FFFFFF) : labShade(color, 0.45).withValues(alpha: 0.8);
  canvas.drawPath(path.shift(Offset(0, -w * 0.22)), st(hi, w * 0.25));
  if (pulse > 0) {
    canvas.drawPath(path, st(const Color(0xFFFFFF00).withValues(alpha: pulse * 0.8), w * 1.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path, st(const Color(0xFFFFFF00).withValues(alpha: pulse * 0.6), w));
  }
}

/// HTML `#blocked-icon` (white disc, red ring and slash).
void _blockedIcon(Canvas canvas, Offset c) {
  labGroundShadow(canvas, c + const Offset(0, 6), 44, 12, opacity: 0.35);
  canvas.drawCircle(c, 20, Paint()..color = const Color(0xFFF8FAFC));
  canvas.drawCircle(c, 20, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = const Color(0xFFEF4444));
  canvas.drawLine(
    c + const Offset(-12, -12),
    c + const Offset(12, 12),
    Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEF4444),
  );
}

// ====================================================== OBJECT DRAWING
//
// The Three.js meshes drawn through the perspective camera `_Cam`.

void _drawObject(Canvas canvas, _Obj o, _CircuitScene s) {
  switch (o.id) {
    case 'cellHolder':
      _shadow(canvas, o.pos, 2.6, 1.4);
      _box3(canvas, o.pos, 4.5, 0.5, 2.2, const Color(0xFF222222));
      final groove = _quad3(o.pos + const _V3(-1.9, 0.501, -0.75), o.pos + const _V3(1.9, 0.501, -0.75),
          o.pos + const _V3(1.9, 0.501, 0.75), o.pos + const _V3(-1.9, 0.501, 0.75));
      canvas.drawPath(groove, Paint()..color = const Color(0xFF0D0D0D));
    case 'lampHolder':
      _shadow(canvas, o.pos, 2.0, 2.0);
      _cyl3(canvas, o.pos, 0.4, 1.8, 1.6, const Color(0xFF222222));
      _cyl3(canvas, o.pos + const _V3(0, 0.4, 0), 0.6, 0.65, 0.65, const Color(0xFF94A3B8), metal: true);
      final hole = _ellipse(o.pos + const _V3(0, 1.0, 0), 0.45);
      canvas.drawOval(hole, Paint()..color = const Color(0xFF334155));
    case 'cell':
      _drawCell(canvas, o);
    case 'lamp':
      _drawLamp(canvas, o, s.scenario == 0 ? s.glowLevel : 0);
    case 'battery':
      _drawBattery(canvas, o);
    case 'led':
      _drawLed(canvas, o, s.scenario == 1 ? s.glowLevel : 0);
  }
  for (final d in s.terms.where((d) => d.owner == o.id)) {
    _drawTerminal(canvas, d, o.pos + d.local, connected: s.wiresAt(d.id).isNotEmpty, t: s.time);
  }
}

void _shadow(Canvas canvas, _V3 at, double rx, double rz, {double opacity = 0.35}) {
  final g = _V3(at.x - 0.35, 0.01, at.z - 0.35);
  final e = _ellipse(g, rx);
  final k = rz / rx;
  canvas.drawOval(
    Rect.fromCenter(center: e.center, width: e.width, height: e.height * k),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, e.height * 0.2 + 2),
  );
}

/// Screen ellipse of a horizontal circle of radius [r] centred at [c].
Rect _ellipse(_V3 c, double r) {
  final p = _Cam.v(c);
  final rx = (_Cam.v(c + _V3(r, 0, 0)) - p).dx.abs();
  final ry = (_Cam.v(c + _V3(0, 0, r)) - p).dy.abs();
  return Rect.fromCenter(center: p, width: 2 * rx, height: 2 * ry);
}

Shader _shade(Rect r, Color c, {bool metal = false}) => LinearGradient(
      colors: metal
          ? [labShade(c, -0.45), labShade(c, 0.1), labShade(c, 0.6), labShade(c, -0.05), labShade(c, -0.5)]
          : [labShade(c, -0.3), labShade(c, 0.05), labShade(c, 0.18), c, labShade(c, -0.35)],
      stops: const [0, 0.25, 0.55, 0.8, 1],
    ).createShader(r);

/// BoxGeometry([sx], [sy], [sz]) standing on [o] (bottom centre).
void _box3(Canvas canvas, _V3 o, double sx, double sy, double sz, Color color, {double opacity = 1}) {
  final x0 = o.x - sx / 2, x1 = o.x + sx / 2, ya = o.y, yb = o.y + sy, z0 = o.z - sz / 2, z1 = o.z + sz / 2;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  if (_camPos.x < x0) {
    canvas.drawPath(_quad3(_V3(x0, yb, z0), _V3(x0, yb, z1), _V3(x0, ya, z1), _V3(x0, ya, z0)),
        Paint()..color = a(labShade(color, -0.3)));
  }
  if (_camPos.x > x1) {
    canvas.drawPath(_quad3(_V3(x1, yb, z1), _V3(x1, yb, z0), _V3(x1, ya, z0), _V3(x1, ya, z1)),
        Paint()..color = a(labShade(color, -0.25)));
  }
  final front = _quad3(_V3(x0, yb, z1), _V3(x1, yb, z1), _V3(x1, ya, z1), _V3(x0, ya, z1));
  canvas.drawPath(
    front,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [a(labShade(color, 0.08)), a(labShade(color, -0.2))],
      ).createShader(front.getBounds()),
  );
  final top = _quad3(_V3(x0, yb, z0), _V3(x1, yb, z0), _V3(x1, yb, z1), _V3(x0, yb, z1));
  canvas.drawPath(top, Paint()..color = a(labShade(color, 0.14)));
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = a(labShade(color, 0.35).withValues(alpha: 0.5));
  canvas.drawLine(_Cam.p(x0, yb, z1), _Cam.p(x1, yb, z1), edge);
}

/// Upright CylinderGeometry(rt, rb, h) standing on [b].
void _cyl3(Canvas canvas, _V3 b, double h, double rb, double rt, Color color, {bool metal = false, double opacity = 1}) {
  final e0 = _ellipse(b, rb), e1 = _ellipse(b + _V3(0, h, 0), rt);
  final body = Path.combine(
    PathOperation.union,
    Path.combine(
      PathOperation.union,
      Path()..addOval(e0),
      Path()
        ..moveTo(e0.left, e0.center.dy)
        ..lineTo(e1.left, e1.center.dy)
        ..lineTo(e1.right, e1.center.dy)
        ..lineTo(e0.right, e0.center.dy)
        ..close(),
    ),
    Path()..addOval(e1),
  );
  final r = body.getBounds();
  if (opacity < 1) canvas.saveLayer(r.inflate(2), Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
  canvas.drawPath(body, Paint()..shader = _shade(r, color, metal: metal));
  canvas.drawOval(e1, Paint()..color = labShade(color, metal ? 0.35 : 0.18));
  if (opacity < 1) canvas.restore();
}

/// Horizontal cylinder between end centres [a] and [b] (radius [r]).
/// Caps facing the camera are filled with [capA] / [capB].
void _hcyl(Canvas canvas, _V3 a, _V3 b, double r, Color color, {Color? capA, Color? capB, bool metal = false}) {
  final d = b - a;
  final len = d.length;
  if (len < 1e-6) return;
  final u = d * (1 / len);
  final v2 = _V3(-u.z, 0, u.x);
  List<Offset> ring(_V3 c) => [
        for (var i = 0; i < 20; i++)
          _Cam.v(c + _V3(0, r * math.cos(i / 20 * math.pi * 2), 0) + v2 * (r * math.sin(i / 20 * math.pi * 2))),
      ];
  final ra = ring(a), rb = ring(b);
  final hull = _hull([...ra, ...rb]);
  final path = Path()..addPolygon(hull, true);
  final bounds = path.getBounds();
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: metal
            ? [labShade(color, 0.2), labShade(color, 0.65), color, labShade(color, -0.5)]
            : [labShade(color, 0.05), labShade(color, 0.4), color, labShade(color, -0.45)],
        stops: const [0, 0.28, 0.6, 1],
      ).createShader(bounds),
  );
  void cap(_V3 c, _V3 n, List<Offset> pts, Color? fill) {
    final toCam = _camPos - c;
    if (n.x * toCam.x + n.y * toCam.y + n.z * toCam.z <= 0) return;
    canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = fill ?? labShade(color, 0.12));
  }

  cap(a, u * -1, ra, capA);
  cap(b, u, rb, capB);
}

List<Offset> _hull(List<Offset> pts) {
  final p = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [...lower.sublist(0, lower.length - 1), ...upper.sublist(0, upper.length - 1)];
}

/// HTML `createTerminal()`: coloured base, metal post (pulsing yellow while
/// unconnected) and a +/- badge.
void _drawTerminal(Canvas canvas, _TermDef d, _V3 base, {required bool connected, required double t}) {
  final s = d.scale;
  _cyl3(canvas, base, 0.2 * s, 0.35 * s, 0.35 * s, d.color);
  final pulse = connected ? 0.0 : (math.sin(t * 5) * 0.5 + 0.5) * 0.8;
  final post = Color.lerp(const Color(0xFFCCCCCC), const Color(0xFFFFF176), pulse * 0.7)!;
  _cyl3(canvas, base + _V3(0, 0.2 * s, 0), 0.4 * s, 0.2 * s, 0.2 * s, post, metal: true);
  final k = _Cam.k(base);
  if (pulse > 0) labGlow(canvas, _Cam.v(base + _V3(0, 0.6 * s, 0)), 0.55 * s * k, const Color(0xFFDDDD22), intensity: pulse * 0.6);
  if (d.type == 't') return;
  final c = _Cam.v(base + _V3(0, 1.3 * s, 0));
  final r = 0.4 * s * k;
  canvas.drawCircle(c + const Offset(0, 2), r, Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  canvas.drawCircle(c, r, Paint()..color = d.type == '+' ? const Color(0xFFEF4444) : const Color(0xFF111111));
  canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x66FFFFFF));
  final bar = Paint()
    ..color = Colors.white
    ..strokeWidth = r * 0.28
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(c + Offset(-r * 0.5, 0), c + Offset(r * 0.5, 0), bar);
  if (d.type == '+') canvas.drawLine(c + Offset(0, -r * 0.5), c + Offset(0, r * 0.5), bar);
}

/// HTML `createCell()`: yellow body (r 0.8, length 2.5), metal bottom and a
/// positive nub. [o.yaw] gives the axis direction on the bench.
void _drawCell(Canvas canvas, _Obj o) {
  final u = _V3(math.cos(o.yaw), 0, math.sin(o.yaw));
  final c = o.pos;
  _shadow(canvas, c, 1.5, 1.0, opacity: 0.3);
  final neg = c - u * 1.25, pos = c + u * 1.25;
  _hcyl(canvas, neg - u * 0.05, neg + u * 0.05, 0.8, const Color(0xFFC0C0C0), metal: true);
  _hcyl(canvas, neg + u * 0.05, pos, 0.8, const Color(0xFFEAB308), capA: const Color(0xFFC0C0C0), capB: const Color(0xFFF2C94C));
  _hcyl(canvas, pos, pos + u * 0.3, 0.25, const Color(0xFFC0C0C0), metal: true, capB: const Color(0xFFE5E7EB));
}

/// HTML `createLamp()`: metal screw base, clear glass bulb, half-ring
/// filament on two posts. Glows warm when the circuit is closed.
void _drawLamp(Canvas canvas, _Obj o, double glow) {
  final c = o.pos;
  final k = _Cam.k(c);
  _shadow(canvas, c, 0.8, 0.8, opacity: 0.3);
  _cyl3(canvas, c, 0.6, 0.35, 0.4, const Color(0xFFC0C0C0), metal: true);
  for (var i = 1; i < 4; i++) {
    final e = _ellipse(c + _V3(0, 0.15 * i, 0), 0.39);
    canvas.drawArc(e, 0.2, math.pi - 0.4, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0xFF6B7280));
  }
  final bc = _Cam.v(c + const _V3(0, 1.3, 0));
  final br = 0.8 * k;
  final rect = Rect.fromCircle(center: bc, radius: br);
  final cs = math.cos(o.spin);
  final fil = Color.lerp(const Color(0xFF333333), const Color(0xFFFFF4C2), glow)!;
  final wire = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.5, 0.05 * k)
    ..strokeCap = StrokeCap.round
    ..color = fil;
  for (final sx in [-1.0, 1.0]) {
    canvas.drawLine(_Cam.v(c + _V3(sx * 0.2 * cs, 0.8, 0)), _Cam.v(c + _V3(sx * 0.2 * cs, 1.3, 0)), wire);
  }
  final arc = Rect.fromCenter(center: bc, width: 0.4 * k * cs.abs() + 1, height: 0.4 * k);
  if (glow > 0) {
    labGlow(canvas, bc, br * 3.2, const Color(0xFFFFDDAA), intensity: 0.9 * glow);
    canvas.drawArc(arc, math.pi, math.pi, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.18 * k
      ..color = const Color(0xFFFFCC33).withValues(alpha: 0.8 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }
  canvas.drawArc(arc, math.pi, math.pi, false, wire);
  canvas.drawCircle(
    bc,
    br,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        colors: [
          Color.lerp(const Color(0x40FFFFFF), const Color(0xCCFFFFE0), glow)!,
          Color.lerp(const Color(0x30E2E8F0), const Color(0xB3FFFF99), glow)!,
          Color.lerp(const Color(0x66CBD5E1), const Color(0xCCFFE680), glow)!,
        ],
        stops: const [0, 0.6, 1],
      ).createShader(rect),
  );
  canvas.drawCircle(bc, br, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = Colors.white.withValues(alpha: 0.6));
  canvas.drawCircle(bc + Offset(-br * 0.38, -br * 0.4), br * 0.16, Paint()..color = Colors.white.withValues(alpha: 0.75));
}

/// Text drawn flat at a world point (the HTML symbol sprites).
void _sign(Canvas canvas, String text, _V3 at, double size) {
  labText(
    canvas,
    text,
    _Cam.v(at),
    size: size,
    weight: FontWeight.w900,
    color: Colors.white,
    shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 3)],
  );
}

/// HTML `createBattery2Cell()`: walled holder (0x1a1a1a) with two AA cells
/// (red + black, nub on the left), + / - marks next to the terminals.
void _drawBattery(Canvas canvas, _Obj o) {
  final c = o.pos;
  final k = _Cam.k(c);
  const black = Color(0xFF1A1A1A);
  _shadow(canvas, c, 2.8, 2.1);
  _box3(canvas, c, 4.8, 0.6, 3.6, black);
  _box3(canvas, c + const _V3(0, 0.3, -1.6), 5.0, 1.0, 0.4, black);
  _box3(canvas, c + const _V3(-2.3, 0.3, 0), 0.4, 1.0, 3.6, black);
  _box3(canvas, c + const _V3(2.3, 0.3, 0), 0.4, 1.0, 3.6, black);
  for (final z in [-0.8, 0.8]) {
    final cc = c + _V3(0, 0.9, z);
    _hcyl(canvas, cc + const _V3(-2.0, 0, 0), cc + const _V3(-1.8, 0, 0), 0.2, const Color(0xFFC0C0C0), metal: true);
    _hcyl(canvas, cc + const _V3(-1.8, 0, 0), cc + const _V3(0.6, 0, 0), 0.65, const Color(0xFFEF4444));
    _hcyl(canvas, cc + const _V3(0.6, 0, 0), cc + const _V3(1.6, 0, 0), 0.65, const Color(0xFF111111));
    _sign(canvas, '+', cc + const _V3(-1.0, 0.7, 0), 0.75 * k);
  }
  _box3(canvas, c + const _V3(0, 0.3, 1.6), 5.0, 1.0, 0.4, black);
  _sign(canvas, '+', c + const _V3(-2.45, 0.8, -1.85), 0.8 * k);
  _sign(canvas, '-', c + const _V3(-2.45, 0.8, 1.85), 0.8 * k);
}

/// HTML `createLED()`: red lens (cylinder + dome) on a rim, long (+) and
/// short (-) legs. Glows bright red when connected the right way round.
void _drawLed(Canvas canvas, _Obj o, double glow) {
  final c = o.pos;
  final k = _Cam.k(c);
  _shadow(canvas, c - const _V3(0, 0.9, 0), 0.7, 0.5, opacity: 0.3);
  final leg = Paint()
    ..strokeWidth = math.max(2.0, 0.16 * k)
    ..strokeCap = StrokeCap.round;
  for (final (x, y0) in [(0.2, -0.9), (-0.2, -0.4)]) {
    final a = _Cam.v(c + _V3(x, y0, 0)), b = _Cam.v(c + _V3(x, 1.1, 0));
    canvas.drawLine(a, b, leg..color = const Color(0xFF6B7280));
    canvas.drawLine(a, b, Paint()..strokeWidth = math.max(1.2, 0.1 * k)..strokeCap = StrokeCap.round..color = const Color(0xFFD1D5DB));
  }
  const red = Color(0xFFEF4444);
  final lens = Color.lerp(red, const Color(0xFFFF0000), glow)!;
  if (glow > 0) labGlow(canvas, _Cam.v(c + const _V3(0, 1.7, 0)), 2.2 * k, const Color(0xFFFF2020), intensity: 0.85 * glow);
  _cyl3(canvas, c + const _V3(0, 1.05, 0), 0.15, 0.55, 0.55, Color.lerp(red, const Color(0xFFB91C1C), 0.2 - 0.2 * glow)!);
  final op = 0.8 + 0.2 * glow;
  _cyl3(canvas, c + const _V3(0, 1.2, 0), 0.8, 0.5, 0.5, lens, opacity: op);
  final top = _Cam.v(c + const _V3(0, 2.0, 0));
  final dome = Rect.fromCircle(center: top, radius: 0.5 * k);
  canvas.drawArc(
    dome,
    math.pi,
    math.pi,
    true,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.2),
        colors: [labShade(lens, 0.45 + 0.3 * glow).withValues(alpha: op), lens.withValues(alpha: op)],
      ).createShader(dome),
  );
  canvas.drawOval(_ellipse(c + const _V3(0, 2.0, 0), 0.5), Paint()..color = lens.withValues(alpha: op));
  if (glow > 0) {
    canvas.drawCircle(top + Offset(0, 0.25 * k), 0.35 * k, Paint()..color = const Color(0xFFFFE4E4).withValues(alpha: 0.55 * glow)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }
  final hi = Rect.fromPoints(_Cam.v(c + const _V3(-0.35, 2.1, 0)), _Cam.v(c + const _V3(-0.22, 1.3, 0)));
  canvas.drawRRect(RRect.fromRectAndRadius(hi, Radius.circular(hi.width)), Paint()..color = Colors.white.withValues(alpha: 0.35));
}

// ================================================================= UI

extension _A3Ui on _Ch3A3ConstructingASimpleElectricalCircuitPageState {
  Widget _buildLab(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.electric_bolt,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step + 1,
          instruction: _scene.finished ? _t('inv_complete') : null,
          sidebarExtraTitle: _t('circuit_status'),
          sidebarExtra: _statusPanel(p, s),
          onReset: _fullReset,
          showHud: false,
          overlays: [_hud(context, p, s)],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ClaimRecognizer: GestureRecognizerFactoryWithHandlers<_ClaimRecognizer>(
                  _ClaimRecognizer.new,
                  (r) => r
                    ..hit = _hitAny
                    ..onDown = _down
                    ..onMove = _move
                    ..onUp = _up
                    ..onCancel = _cancelGesture,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _CircuitPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar readout: component placement, lamp / LED state and wires.
  Widget _statusPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    final s0 = sc.scenario == 0;
    String place(String id) {
      final o = sc.objs[id];
      if (o == null) return '';
      final placed = s0 ? o.x < 0 : o.x < 5;
      return _t(placed ? (s0 ? 'placed' : 'on_bench') : 'in_tray');
    }

    final state = sc.glowing ? 'state_glowing' : (sc.blocked ? 'state_blocked' : 'state_off');
    final stateColor = sc.glowing ? _Colors.green : (sc.blocked ? _Colors.red : p.textMuted);
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
          for (final id in s0 ? const ['cell', 'lamp'] : const ['battery', 'led'])
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t(switch (id) { 'cell' => 'elec_cell', 'lamp' => 'lamp', 'battery' => 'bat_9v', _ => 'led' }),
              value: place(id),
            ),
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t(s0 ? 'lamp' : 'led'),
            value: _t(state),
            valueColor: stateColor,
          ),
          Divider(color: p.cardBorder, height: 12 * s),
          Text(
            '${_t('wires_connected')}: ${sc.wires.length}',
            style: TextStyle(color: p.textStrong, fontSize: 12 * f, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4 * s),
          if (sc.wires.isEmpty)
            Text(_t('no_wires'), style: TextStyle(color: p.textMuted, fontSize: 11.5 * f))
          else
            for (final w in sc.wires)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2 * f),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 3 * f),
                      width: 14 * f,
                      height: 6 * f,
                      decoration: BoxDecoration(
                        color: w.color,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: p.textMuted.withValues(alpha: 0.6), width: 0.8),
                      ),
                    ),
                    SizedBox(width: 6 * f),
                    Expanded(
                      child: Text(
                        '${_t('t_${w.t1}')}  ↔  ${_t('t_${w.t2}')}',
                        style: TextStyle(color: p.text, fontSize: 11.5 * f, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  /// The HTML bottom HUD: "Current Task Instruction" + task + status icon.
  Widget _hud(BuildContext context, LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    final sc = _scene;
    final text = sc.finished ? _t('inv_complete') : _data.steps[sc.step].action;
    final (IconData icon, Color fg, Color bg) = switch (sc.status) {
      _Status.complete => (Icons.check_rounded, _Colors.green, _Colors.green.withValues(alpha: 0.18)),
      _Status.done => (Icons.star_rounded, _Colors.zslYellow, _Colors.zslYellow.withValues(alpha: 0.2)),
      _Status.error => (Icons.close_rounded, _Colors.red, _Colors.red.withValues(alpha: 0.18)),
      _Status.pending => (Icons.more_horiz_rounded, _Colors.slate400, p.isDark ? _Colors.slate800 : _Colors.slate100),
    };
    final pulse = sc.status == _Status.pending || sc.status == _Status.error;
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: inset.bottom,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 620 * s),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12 * s),
                child: ColoredBox(
                  color: p.isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(height: 3.5 * s, color: _Colors.zslYellow),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 10 * s, 7 * s),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _t('curr_task').toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _Colors.zslYellow,
                                      fontSize: 9.5 * s,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: _lab.lang == LabLang.hi ? 0 : 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text(
                                    text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: p.textStrong,
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            ValueListenableBuilder<double>(
                              valueListenable: _frame,
                              builder: (context, t, child) => Opacity(
                                opacity: pulse ? 0.65 + 0.35 * math.sin(t * 4).abs() : 1,
                                child: child,
                              ),
                              child: Container(
                                width: 32 * s,
                                height: 32 * s,
                                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                                child: Icon(icon, size: 19 * s, color: fg),
                              ),
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
        ),
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
