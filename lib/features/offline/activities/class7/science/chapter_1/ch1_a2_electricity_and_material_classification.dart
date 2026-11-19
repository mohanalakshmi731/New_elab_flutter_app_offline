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

/// Class 7 Science • Chapter 1 • Activity 2
/// Electricity and Material Classification ("The Glow Test").
///
/// Native Flutter port of
/// `Cl7S-Ch1-A2-Electricity_and_Material_Classification.html`.
/// Scenario 1: drag the battery and the bulb onto their spots, then wire
/// (+) and (-) to the bulb holder; the closed loop lights the bulb and
/// current particles flow. Scenario 2: test six materials in the gap of a
/// pre-built circuit, then sort them into Conductor / Insulator bins.
///
/// The toon-shaded Three.js workbench is redrawn with a small projector
/// using the HTML camera (eye (0, 40, 50), target origin, 40° FOV), so the
/// layout, drag planes and drop radii match the original.
class Ch1A2ElectricityAndMaterialClassificationPage extends StatefulWidget {
  const Ch1A2ElectricityAndMaterialClassificationPage({super.key});

  @override
  State<Ch1A2ElectricityAndMaterialClassificationPage> createState() =>
      _Ch1A2ElectricityAndMaterialClassificationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356.
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

// ======================================================== SCENE MODEL

/// Step kinds of the HTML `getScenariosData()`.
enum _Act { drag, wire, test, testMulti, sort }

class _StepDef {
  const _StepDef(this.act, {this.target, this.pos, this.start, this.end, this.targets = const []});
  final _Act act;
  final String? target;
  final _V3? pos;
  final String? start;
  final String? end;
  final List<String> targets;
}

const List<List<_StepDef>> _stepDefs = [
  [
    _StepDef(_Act.drag, target: 'battery', pos: _V3(-4, 1.0, -2)),
    _StepDef(_Act.drag, target: 'bulb', pos: _V3(12, 1.0, -2)),
    _StepDef(_Act.wire, start: 'term-pos', end: 'term-bulb'),
    _StepDef(_Act.wire, start: 'term-neg', end: 'term-bulb'),
  ],
  [
    _StepDef(_Act.test, target: 'coin'),
    _StepDef(_Act.test, target: 'spoon'),
    _StepDef(_Act.testMulti, targets: ['nail', 'eraser', 'wood', 'foil']),
    _StepDef(_Act.sort),
  ],
];

/// Gap between the two test terminals (HTML `objectsDict['gapTarget']`).
const _V3 _gapTarget = _V3(4, 1.0, 8);
const _V3 _binCond = _V3(-8, 1.0, 14);
const _V3 _binIns = _V3(8, 1.0, 14);

class _Obj {
  _Obj(this.id, {this.conductor = false, this.material = false});

  final String id;
  final bool conductor;
  final bool material;

  /// HTML `userData.startPos`.
  _V3 home = _V3.zero;
  _V3 pos = _V3.zero;
  bool draggable = true;

  /// Lying across the test terminals (rotated to bridge them).
  bool inGap = false;
  bool lifted = false;
  _Move? move;
}

class _Move {
  _Move(this.from, this.to, this.duration);
  final _V3 from;
  final _V3 to;
  final double duration;
  double t = 0;
}

/// A drawn wire (HTML `drawWire`): quadratic curve + 10 flow particles.
class _Wire {
  _Wire(this.a, this.b, this.color) {
    final dist = (b - a).length;
    final c = _V3((a.x + b.x) / 2, 1.5 + dist * 0.1, (a.z + b.z) / 2);
    pts = _bezier(a, c, b, n: 32);
  }

  final _V3 a;
  final _V3 b;
  final Color color;
  late final List<_V3> pts;

  _V3 at(double t) {
    final f = t.clamp(0.0, 1.0) * (pts.length - 1);
    final i = f.floor().clamp(0, pts.length - 2);
    return _V3.lerp(pts[i], pts[i + 1], f - i);
  }
}

class _World {
  final math.Random rnd = math.Random();
  int scenario = 0;
  int step = 0;
  double time = 0;

  final _Obj battery = _Obj('battery');
  final _Obj bulb = _Obj('bulb');
  final List<_Obj> items = [
    _Obj('coin', conductor: true, material: true),
    _Obj('spoon', material: true),
    _Obj('nail', conductor: true, material: true),
    _Obj('eraser', material: true),
    _Obj('wood', material: true),
    _Obj('foil', conductor: true, material: true),
  ];

  final List<_Wire> wires = [];
  final Set<String> usedTerminals = {};
  final Set<String> itemsTested = {};
  bool bulbOn = false;
  double glow = 0;

  /// Flow particle phase (HTML `p.userData.t += 0.005` per frame).
  double flow = 0;

  /// Wire being drawn from this terminal id (drag or tap-tap).
  String? wireStart;
  Offset? wirePointer;
  _Obj? dragging;

  bool get binsVisible => scenario == 1 && step >= 3;
  List<_Obj> get objects => scenario == 0 ? [battery, bulb] : [battery, bulb, ...items];
  _Obj item(String id) => items.firstWhere((o) => o.id == id);

  /// Terminal hit centres (HTML terminal hit spheres, radius 1.5).
  Map<String, _V3> get terminals => {
    'pos': battery.pos + const _V3(4, 1.0, 1.5),
    'neg': battery.pos + const _V3(-4, 1.0, 1.5),
    'b1': bulb.pos + const _V3(-2.5, 1.0, 1.5),
    'b2': bulb.pos + const _V3(2.5, 1.0, 1.5),
    if (scenario == 1) 'g1': _gapTarget + const _V3(-3, 1.0, 0),
    if (scenario == 1) 'g2': _gapTarget + const _V3(3, 1.0, 0),
  };

  static String termClass(String id) => switch (id) {
    'pos' => 'term-pos',
    'neg' => 'term-neg',
    'b1' || 'b2' => 'term-bulb',
    _ => 'term-gap',
  };

  void update(double dt) {
    time += dt;
    for (final o in objects) {
      final m = o.move;
      if (m == null) continue;
      m.t += dt / m.duration;
      if (m.t >= 1) {
        o.pos = m.to;
        o.move = null;
      } else {
        o.pos = _V3.lerp(m.from, m.to, Curves.easeOutCubic.transform(m.t));
      }
    }
    final target = bulbOn ? 1.0 : 0.0;
    glow += (target - glow) * math.min(1, dt * 12);
    if (bulbOn) flow = (flow + 0.005 * dt * 60) % 1;
  }
}

// ============================================================== STATE

class _Ch1A2ElectricityAndMaterialClassificationPageState extends State<Ch1A2ElectricityAndMaterialClassificationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _World _w = _World();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// A step advance is scheduled; blocks duplicate wires / drops meanwhile.
  bool _pending = false;
  double _dragPlaneY = 0;
  _V3 _dragOffset = _V3.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  _Cam get _cam => _cams[_w.scenario];
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_w.scenario];
  List<_StepDef> get _defs => _stepDefs[_w.scenario];
  _StepDef? get _def => _w.step < _defs.length ? _defs[_w.step] : null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadScenario(0);
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
      _last = elapsed;
      _w.update(dt);
      _frame.value = _w.time;
    })..start();
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

  // ------------------------------------------------------------ logic

  /// HTML `loadScenario(id)`: rebuilds the workbench for the scenario.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _pending = false;
    final w = _w
      ..scenario = index
      ..step = 0
      ..bulbOn = false
      ..glow = 0
      ..wireStart = null
      ..wirePointer = null
      ..dragging = null;
    w.wires.clear();
    w.usedTerminals.clear();
    w.itemsTested.clear();
    void place(_Obj o, _V3 p, {bool draggable = true}) {
      o
        ..home = p
        ..pos = p
        ..move = null
        ..inGap = false
        ..lifted = false
        ..draggable = draggable;
    }

    if (index == 0) {
      place(w.battery, const _V3(-20, 1.5, -5));
      place(w.bulb, const _V3(-20, 1.5, 5));
    } else {
      place(w.battery, const _V3(-2, 1.0, -6), draggable: false);
      place(w.bulb, const _V3(14, 1.0, -6), draggable: false);
      final t = w.terminals;
      w.wires
        ..add(_Wire(t['pos']!, t['b1']!, _cWireRed))
        ..add(_Wire(t['neg']!, const _V3(1.5, 1.5, 8), _cWireBlack))
        ..add(_Wire(t['b2']!, const _V3(6.5, 1.5, 8), _cWireRed));
      const px = [-23.0, -17.0], pz = [-8.0, 0.0, 8.0];
      for (var i = 0; i < w.items.length; i++) {
        place(w.items[i], _V3(px[i % 2], 1.5, pz[i ~/ 2]));
      }
    }
    _lab.hidePopup(sound: false);
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `advanceStep()`.
  void _advanceStep() {
    _pending = false;
    final n = _defs.length;
    setState(() {
      if (_w.step < n - 1) {
        _w.step++;
      } else {
        if (_w.scenario == 0) _w.bulbOn = true;
        _w.step = n;
        _Audio.play(_Sound.success);
        final scenario = _w.scenario;
        _lab.showScenarioConclusion(
          scenarioIndex: scenario,
          totalScenarios: 2,
          delay: const Duration(milliseconds: 3000),
          title: () => _t(scenario == 0 ? 'scen1_obsTitle' : 'scen2_obsTitle'),
          heading: () => _t('obsHeader'),
          body: () => _t(scenario == 0 ? 'scen1_obsText' : 'scen2_obsText'),
        );
      }
    });
  }

  void _advanceAfter(int ms) {
    _pending = true;
    _lab.after(Duration(milliseconds: ms), () {
      if (mounted) _advanceStep();
    });
  }

  void _setBulb(bool on) => _w.bulbOn = on;

  // ---------------------------------------------------------- gestures

  String? _terminalAt(Offset p) {
    String? best;
    var bestD = double.infinity;
    _w.terminals.forEach((id, c) {
      final d = (_cam.p(c) - p).distance;
      final r = math.max(1.5 * _cam.k(c), 18.0);
      if (d < r && d < bestD) {
        bestD = d;
        best = id;
      }
    });
    return best;
  }

  _Obj? _objectAt(Offset p) {
    _Obj? best;
    var bestScore = double.infinity;
    for (final o in _w.objects) {
      final b = _hitBox(o);
      final r = _cam.screenRect(o.pos + b.$1, b.$2);
      if (!r.contains(p)) continue;
      final score = (r.center - p).distance;
      if (score < bestScore) {
        bestScore = score;
        best = o;
      }
    }
    return best;
  }

  /// HTML hit boxes: battery 10x6x6, bulb 8x8x6, materials 6x4x6.
  (_V3, _V3) _hitBox(_Obj o) => switch (o.id) {
    'battery' => (const _V3(0, 2, 0), const _V3(5, 3, 3)),
    'bulb' => (const _V3(0, 3, 0), const _V3(4, 4, 3)),
    _ => (const _V3(0, 1, 0), const _V3(3, 2, 3)),
  };

  /// HTML pointerdown on a draggable: wrong-object check, then pick up.
  bool _tryPickUp(Offset p, {required bool startDrag}) {
    final o = _objectAt(p);
    if (o == null || !o.draggable) return false;
    final def = _def;
    if (def != null) {
      if ((def.act == _Act.drag || def.act == _Act.test) && def.target != o.id) {
        _lab.showToast(_t('msg_drag_err_obj'), isError: true);
        return true;
      }
      if (def.act == _Act.testMulti && !def.targets.contains(o.id)) return true;
    }
    if (!startDrag) return true;
    o
      ..move = null
      ..lifted = true;
    _w.dragging = o;
    _dragPlaneY = o.pos.y;
    final ip = _cam.onPlaneY(p, _dragPlaneY);
    _dragOffset = ip == null ? _V3.zero : ip - o.pos;
    _Audio.play(_Sound.pickup, volume: 0.45);
    return true;
  }

  void _onPanStart(DragStartDetails d) {
    if (!_lab.isLabActive || _w.dragging != null) return;
    final p = d.localPosition;
    final def = _def;
    if (def != null && def.act == _Act.wire && !_pending) {
      final t = _terminalAt(p);
      if (t != null) {
        if (_World.termClass(t) == def.start) {
          setState(() {
            _w
              ..wireStart = t
              ..wirePointer = p;
          });
          _Audio.play(_Sound.pop);
        } else {
          _lab.showToast(_t('msg_conn_err_start'), isError: true);
        }
        return;
      }
    }
    setState(() => _tryPickUp(p, startDrag: true));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_w.wireStart != null && _w.dragging == null) {
      _w.wirePointer = d.localPosition;
      return;
    }
    final o = _w.dragging;
    if (o == null) return;
    final ip = _cam.onPlaneY(d.localPosition, _dragPlaneY);
    if (ip == null) return;
    final q = ip - _dragOffset;
    o.pos = _V3(q.x.clamp(-26.0, 38.0), _dragPlaneY + 3, q.z.clamp(-16.0, 22.0));
  }

  void _onPanEnd() {
    final o = _w.dragging;
    if (o != null) {
      _w.dragging = null;
      o.lifted = false;
      setState(() => _handleDrop(o));
      return;
    }
    if (_w.wireStart != null && _w.wirePointer != null) {
      final end = _terminalAt(_w.wirePointer!);
      if (end == _w.wireStart) {
        // Released on the start terminal: keep it armed (tap-tap wiring).
        setState(() => _w.wirePointer = null);
        return;
      }
      setState(() => _finishWire(end));
    }
  }

  /// Tap support: tap the start terminal, then tap the destination.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    final def = _def;
    if (def != null && def.act == _Act.wire && !_pending) {
      final t = _terminalAt(p);
      if (_w.wireStart == null) {
        if (t == null) return;
        if (_World.termClass(t) == def.start) {
          setState(() => _w.wireStart = t);
          _Audio.play(_Sound.pop);
        } else {
          _lab.showToast(_t('msg_conn_err_start'), isError: true);
        }
      } else if (t == _w.wireStart) {
        setState(() => _w.wireStart = null);
      } else {
        setState(() => _finishWire(t));
      }
      return;
    }
    _tryPickUp(p, startDrag: false);
  }

  /// HTML pointerup while drawing a wire.
  void _finishWire(String? end) {
    final def = _def;
    final start = _w.wireStart;
    _w
      ..wireStart = null
      ..wirePointer = null;
    if (def == null || start == null) return;
    if (end == null) {
      _Audio.play(_Sound.wrong);
      return;
    }
    if (end != start && _World.termClass(end) == def.end && !_w.usedTerminals.contains(end)) {
      final t = _w.terminals;
      _w.wires.add(_Wire(t[start]!, t[end]!, def.start == 'term-pos' ? _cWireRed : _cWireBlack));
      _w.usedTerminals.addAll([start, end]);
      _Audio.play(_Sound.success);
      _lab.showToast(_t('msg_conn_success'), sound: false);
      _advanceAfter(800);
    } else {
      _lab.showToast(_t('msg_conn_err_dest'), isError: true);
    }
  }

  void _returnHome(_Obj o) => o.move = _Move(o.pos, o.home, 0.18);

  double _xzDist(_V3 a, _V3 b) => math.sqrt((a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z));

  /// HTML `handleDrop()`.
  void _handleDrop(_Obj obj) {
    final w = _w;
    final def = _def;
    obj.pos = _V3(obj.pos.x, _dragPlaneY, obj.pos.z);
    if (def == null || _pending) {
      _returnHome(obj);
      return;
    }
    switch (def.act) {
      case _Act.drag:
        final spot = def.pos!;
        if (_xzDist(obj.pos, spot) < 8) {
          obj
            ..pos = _V3(spot.x, 1.0, spot.z)
            ..draggable = false;
          _Audio.play(_Sound.drop);
          _lab.showToast(_t('msg_drag_success'));
          _advanceAfter(800);
        } else {
          _returnHome(obj);
          _Audio.play(_Sound.wrong);
        }
      case _Act.test || _Act.testMulti:
        if (_xzDist(obj.pos, _gapTarget) < 8) {
          obj
            ..pos = _V3(_gapTarget.x, 1.5, _gapTarget.z)
            ..inGap = true;
          _Audio.play(_Sound.drop);
          _setBulb(obj.conductor);
          if (obj.conductor) {
            _lab.showToast(_t('msg_test_success'));
          } else {
            _lab.showToast(_t('msg_test_fail'), sound: false);
            _Audio.play(_Sound.wrong);
          }
          for (final o in w.items) {
            o.draggable = false;
          }
          _pending = true;
          _lab.after(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            setState(() {
              _setBulb(false);
              obj.inGap = false;
              _returnHome(obj);
              for (final o in w.items) {
                o.draggable = true;
              }
              if (def.act == _Act.testMulti) {
                w.itemsTested.add(obj.id);
                if (w.itemsTested.length >= 4) {
                  _advanceStep();
                } else {
                  _pending = false;
                }
              } else {
                _advanceStep();
              }
            });
          });
        } else {
          _returnHome(obj);
          _Audio.play(_Sound.wrong);
        }
      case _Act.sort:
        String? bin;
        if (_xzDist(obj.pos, _binCond) < 9) bin = 'cond';
        if (_xzDist(obj.pos, _binIns) < 9) bin = 'ins';
        if (bin == null) {
          _returnHome(obj);
          return;
        }
        if ((bin == 'cond') == obj.conductor) {
          final b = bin == 'cond' ? _binCond : _binIns;
          obj
            ..pos = _V3(b.x + (w.rnd.nextDouble() - 0.5) * 6, 1.5, b.z + (w.rnd.nextDouble() - 0.5) * 6)
            ..draggable = false;
          _Audio.play(_Sound.drop);
          if (w.items.every((o) => !o.draggable)) {
            _Audio.play(_Sound.success);
            _lab.showToast(_t('msg_sort_success'), sound: false);
            _advanceAfter(1000);
          }
        } else {
          _lab.showToast(_t('msg_sort_err'), isError: true);
          _returnHome(obj);
        }
      case _Act.wire:
        _returnHome(obj);
    }
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        final done = _w.step >= _defs.length;
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        return LabShell(
          controller: _lab,
          icon: Icons.lightbulb,
          title: _t('title'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('scen1_title'), _t('scen2_title')],
          scenarioIndex: _w.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _w.step + 1,
          instruction: done ? '${_t('msg_act_comp')} ${_t('msg_check_obs')}' : null,
          sidebarExtraTitle: _t(_w.scenario == 0 ? 'scen1_contextTitle' : 'scen2_contextTitle'),
          sidebarExtra: _contextCard(p, s),
          onReset: _fullReset,
          stage: LabStage(
            designSize: _design,
            // The default 36 px pan slop would swallow short drags; the
            // HTML picked objects up on pointer-down.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: _onTapUp,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: _A2Painter(
                    world: _w,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    text: {for (final k in _labelKeys) k: _t(k)},
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The HTML mission box's "Why to Learn?" / "Scientific Context" note.
  Widget _contextCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: _Colors.primary.withValues(alpha: p.isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.primary.withValues(alpha: 0.45)),
      ),
      child: Text(
        _t(_w.scenario == 0 ? 'scen1_contextBody' : 'scen2_contextBody'),
        style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'title': 'Electricity and Material Classification',
    'subtitle': 'The Glow Test • Class 7 • The Ever-Evolving World of Science',
    'scen1_title': 'Scenario 1: Let There Be Light!',
    'scen2_title': 'Scenario 2: Conductor or Insulator?',
    'scen1_contextTitle': 'Why to Learn?',
    'scen1_contextBody':
        'A complete circuit needs a power source (battery), a conductive path (wires), and a load (bulb). Electricity flows from the positive (+) terminal to the negative (-) terminal in a closed loop.',
    'scen2_contextTitle': 'Scientific Context',
    'scen2_contextBody':
        'Conductors (like metals) allow electricity to pass easily. Insulators (like plastic/wood) block the flow. We test this by placing objects in the circuit gap.',
    'obsHeader': 'Observation',
    'scen1_obsTitle': 'The Complete Loop',
    'scen1_obsText':
        'A closed circuit requires an unbroken path from the source (battery), through the load (bulb), and back. You successfully completed an electric circuit! If the path is broken, the bulb will not glow.',
    'scen2_obsTitle': 'Material Classification',
    'scen2_obsText':
        'Based on the experiments, you observed that metals like Copper, Iron, and Aluminum are Conductors. Non-metals like Plastic, Rubber, and Wood block the current flow and are Insulators.',
    'msg_conn_err_start': 'Start connecting from the correct terminal.',
    'msg_conn_err_dest': 'Connect to the correct destination point.',
    'msg_conn_success': 'Connection Made successfully!',
    'msg_drag_err_obj': 'Please interact with the correct object for this step.',
    'msg_drag_success': 'Placed perfectly.',
    'msg_test_success': 'Circuit complete! The bulb glows.',
    'msg_test_fail': 'Current blocked. The bulb is dark.',
    'msg_sort_success': 'All materials sorted correctly!',
    'msg_sort_err': 'Incorrect bin. Think about your test results.',
    'msg_act_comp': 'Activity Complete! Well done.',
    'msg_check_obs': 'Review the observation popup.',
    'lbl_partsTray': 'Parts Tray',
    'lbl_matTray': 'Materials Tray',
    'lbl_terminals': 'TEST TERMINALS',
    'lbl_cond': 'CONDUCTORS',
    'lbl_ins': 'INSULATORS',
    'lbl_bulb': 'Light Bulb',
    'lbl_bat': '+ BATTERY',
    'lbl_coin': 'Copper Coin',
    'lbl_spoon': 'Plastic Spoon',
    'lbl_nail': 'Iron Nail',
    'lbl_eraser': 'Rubber Eraser',
    'lbl_wood': 'Wood Stick',
    'lbl_foil': 'Aluminum Foil',
    'lbl_intensity': 'Intensity: 100%',
  },
  'hi': {
    'title': 'विद्युत और सामग्री वर्गीकरण',
    'subtitle': 'द ग्लो टेस्ट • कक्षा 7 • विज्ञान की निरंतर विकसित होती दुनिया',
    'scen1_title': 'परिदृश्य 1: प्रकाश होने दो!',
    'scen2_title': 'परिदृश्य 2: सुचालक या कुचालक?',
    'scen1_contextTitle': 'वैज्ञानिक संदर्भ',
    'scen1_contextBody':
        'एक पूर्ण सर्किट के लिए पावर स्रोत (बैटरी), प्रवाहकीय पथ (तार) और लोड (बल्ब) की आवश्यकता होती है। बिजली एक बंद लूप में धनात्मक (+) टर्मिनल से ऋणात्मक (-) टर्मिनल की ओर बहती है।',
    'scen2_contextTitle': 'वैज्ञानिक संदर्भ',
    'scen2_contextBody':
        'सुचालक (Conductors) (जैसे धातु) बिजली को आसानी से गुजरने देते हैं। कुचालक (Insulators) (जैसे प्लास्टिक/लकड़ी) प्रवाह को रोकते हैं। हम सर्किट गैप में वस्तुओं को रखकर इसका परीक्षण करते हैं।',
    'obsHeader': 'अवलोकन',
    'scen1_obsTitle': 'संपूर्ण लूप',
    'scen1_obsText':
        'एक बंद सर्किट के लिए स्रोत (बैटरी) से लोड (बल्ब) और वापस तक एक अटूट पथ की आवश्यकता होती है। आपने एक इलेक्ट्रिक सर्किट सफलतापूर्वक पूरा कर लिया है! यदि पथ टूट जाता है, तो बल्ब नहीं चमकेगा।',
    'scen2_obsTitle': 'सामग्री वर्गीकरण',
    'scen2_obsText':
        'प्रयोगों के आधार पर, आपने देखा कि तांबा, लोहा और एल्यूमीनियम जैसी धातुएं सुचालक (Conductors) हैं। प्लास्टिक, रबर और लकड़ी जैसी गैर-धातुएं प्रवाह को रोकती हैं और कुचालक (Insulators) हैं।',
    'msg_conn_err_start': 'सही टर्मिनल से जोड़ना शुरू करें।',
    'msg_conn_err_dest': 'सही गंतव्य बिंदु से कनेक्ट करें।',
    'msg_conn_success': 'कनेक्शन सफलतापूर्वक हो गया!',
    'msg_drag_err_obj': 'कृपया इस चरण के लिए सही वस्तु के साथ बातचीत करें।',
    'msg_drag_success': 'पूरी तरह से रखा गया।',
    'msg_test_success': 'सर्किट पूरा हुआ! बल्ब चमकता है।',
    'msg_test_fail': 'धारा अवरुद्ध। बल्ब काला है।',
    'msg_sort_success': 'सभी सामग्रियों को सही ढंग से क्रमबद्ध किया गया!',
    'msg_sort_err': 'गलत डिब्बा। अपने परीक्षा परिणामों के बारे में सोचें।',
    'msg_act_comp': 'गतिविधि पूर्ण! बहुत बढ़िया।',
    'msg_check_obs': 'अवलोकन पॉपअप की समीक्षा करें।',
    'lbl_partsTray': 'पार्ट्स ट्रे',
    'lbl_matTray': 'सामग्री ट्रे',
    'lbl_terminals': 'परीक्षण टर्मिनल',
    'lbl_cond': 'सुचालक (CONDUCTORS)',
    'lbl_ins': 'कुचालक (INSULATORS)',
    'lbl_bulb': 'लाइट बल्ब',
    'lbl_bat': '+ बैटरी',
    'lbl_coin': 'तांबे का सिक्का',
    'lbl_spoon': 'प्लास्टिक का चम्मच',
    'lbl_nail': 'लोहे की कील',
    'lbl_eraser': 'रबर इरेज़र',
    'lbl_wood': 'लकड़ी की छड़ी',
    'lbl_foil': 'एल्युमिनियम फॉयल',
    'lbl_intensity': 'तीव्रता: 100%',
  },
};

/// Keys of every string the painter needs (resolved on each build).
const List<String> _labelKeys = [
  'lbl_partsTray', 'lbl_matTray', 'lbl_terminals', 'lbl_cond', 'lbl_ins', //
  'lbl_bulb', 'lbl_bat', 'lbl_coin', 'lbl_spoon', 'lbl_nail', 'lbl_eraser',
  'lbl_wood', 'lbl_foil', 'lbl_intensity',
];

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'Scenario 1: Let There Be Light!',
      objective: 'To build a functional, closed electrical circuit that can light up a bulb.',
      steps: [
        LabStep(
          concept: 'Place Power Source',
          action: 'Drag the Battery from the grey tray to the left yellow circle.',
          observation:
              'DRAG the battery from the parts tray and DROP it onto the designated spot on the workbench.',
        ),
        LabStep(
          concept: 'Place the Load',
          action: 'Drag the Bulb from the tray to the right yellow circle.',
          observation:
              'DRAG the light bulb with its holder from the parts tray and DROP it onto its spot on the workbench.',
        ),
        LabStep(
          concept: 'Connect Wire (+)',
          action: 'Click Battery (+) terminal, then click a Bulb terminal.',
          observation:
              'CLICK and DRAG a wire from the positive (+) terminal of the battery to one of the connection points on the bulb holder.',
        ),
        LabStep(
          concept: 'Close Circuit (-)',
          action: 'Click Battery (-) terminal, then click the remaining Bulb terminal.',
          observation:
              'CLICK and DRAG a second wire from the negative (-) terminal of the battery to the other connection point on the bulb holder.',
        ),
      ],
    ),
    LabScenarioData(
      title: 'Scenario 2: Conductor or Insulator?',
      objective:
          'To test different materials and classify them as either conductors or insulators based on whether they complete a circuit.',
      steps: [
        LabStep(
          concept: 'Test Copper Coin',
          action: 'Drag the Copper Coin into the gap on the table.',
          observation:
              'The lab starts with a pre-built circuit: a battery and a bulb connected by wires, but with a gap between two test terminals. DRAG the copper coin from the materials tray and DROP it into the gap, touching both terminals.',
        ),
        LabStep(
          concept: 'Test Plastic Spoon',
          action: 'Drag the Plastic Spoon into the gap on the table.',
          observation:
              'DRAG the copper coin back to the tray. Now, DRAG the plastic spoon from the materials tray and DROP it into the gap.',
        ),
        LabStep(
          concept: 'Test Remaining Items',
          action: 'Test the Nail, Eraser, Wood, and Foil in the gap.',
          observation:
              'Continue testing the remaining items from the tray: an iron nail, a rubber eraser, a wooden stick, and a piece of aluminum foil. DRAG each one into the gap, observe the result, and then return it to the tray.',
        ),
        LabStep(
          concept: 'Classify Materials',
          action: 'Sort all materials into the correct Conductors or Insulators bin.',
          observation:
              "After testing all items, two large bins appear on the screen labeled 'Conductors' and 'Insulators'. DRAG each test object from the tray and DROP it into the correct bin.",
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'परिदृश्य 1: प्रकाश होने दो!',
      objective: 'बल्ब को रोशन करने के लिए एक कार्यात्मक, बंद विद्युत सर्किट का निर्माण करना।',
      steps: [
        LabStep(
          concept: 'पावर स्रोत रखें',
          action: 'बैटरी को ट्रे से टेबल पर बाएँ पीले घेरे तक खींचें।',
          observation: 'पार्ट्स ट्रे से बैटरी को खींचें और इसे कार्यक्षेत्र (workbench) पर निर्धारित स्थान पर छोड़ें।',
        ),
        LabStep(
          concept: 'लोड रखें',
          action: 'बल्ब को ट्रे से टेबल पर दाएँ पीले घेरे तक खींचें।',
          observation: 'ट्रे से लाइट बल्ब को उसके होल्डर के साथ खींचें और इसे कार्यक्षेत्र पर उसके स्थान पर छोड़ें।',
        ),
        LabStep(
          concept: 'तार जोड़ें (+)',
          action: 'बैटरी (+) टर्मिनल पर क्लिक करें, फिर बल्ब टर्मिनल पर क्लिक करें।',
          observation:
              'बैटरी के धनात्मक (+) टर्मिनल से बल्ब होल्डर पर कनेक्शन बिंदुओं में से एक तक तार पर क्लिक करें और खींचें।',
        ),
        LabStep(
          concept: 'सर्किट पूरा करें (-)',
          action: 'बैटरी (-) टर्मिनल पर क्लिक करें, फिर बचे हुए बल्ब टर्मिनल पर क्लिक करें।',
          observation:
              'बैटरी के ऋणात्मक (-) टर्मिनल से बल्ब होल्डर पर दूसरे कनेक्शन बिंदु तक दूसरे तार पर क्लिक करें और खींचें।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'परिदृश्य 2: सुचालक या कुचालक?',
      objective: 'विभिन्न सामग्रियों का परीक्षण करें और उन्हें सुचालक या कुचालक के रूप में वर्गीकृत करें।',
      steps: [
        LabStep(
          concept: 'तांबे के सिक्के का परीक्षण',
          action: 'तांबे के सिक्के को टेबल पर गैप में खींचें।',
          observation:
              'लैब एक पूर्व-निर्मित सर्किट से शुरू होती है जिसमें एक गैप है। सामग्री ट्रे से तांबे के सिक्के को खींचें और इसे गैप में छोड़ें, दोनों टर्मिनलों को छूते हुए।',
        ),
        LabStep(
          concept: 'प्लास्टिक के चम्मच का परीक्षण',
          action: 'प्लास्टिक चम्मच को टेबल पर गैप में खींचें।',
          observation:
              'तांबे के सिक्के को वापस ट्रे में खींचें। अब, सामग्री ट्रे से प्लास्टिक के चम्मच को खींचें और इसे गैप में छोड़ें।',
        ),
        LabStep(
          concept: 'शेष वस्तुओं का परीक्षण',
          action: 'गैप में कील, इरेज़र, लकड़ी और पन्नी का परीक्षण करें।',
          observation:
              'ट्रे से शेष वस्तुओं का परीक्षण जारी रखें: एक लोहे की कील, एक रबर इरेज़र, एक लकड़ी की छड़ी, और एल्यूमीनियम पन्नी का एक टुकड़ा। प्रत्येक को गैप में खींचें, परिणाम देखें, और फिर इसे ट्रे में वापस कर दें।',
        ),
        LabStep(
          concept: 'सामग्रियों का वर्गीकरण',
          action: 'सभी सामग्रियों को सही डिब्बे (Conductors या Insulators) में क्रमबद्ध करें।',
          observation:
              "सभी वस्तुओं का परीक्षण करने के बाद, स्क्रीन पर 'सुचालक' और 'कुचालक' लेबल वाले दो बड़े डिब्बे दिखाई देते हैं। ट्रे से प्रत्येक परीक्षण वस्तु को खींचें और इसे सही डिब्बे में छोड़ें।",
        ),
      ],
    ),
  ],
};

// ====================================================== 3D PROJECTION

/// Design size of the stage; the projector reproduces the HTML camera
/// (40° FOV, eye (0, 40, 50) looking at the origin) on a 1000x560 viewport,
/// zoomed 1.25x onto the workbench.
const Size _design = Size(860, 480);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);

  static const _V3 zero = _V3(0, 0, 0);

  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);

  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);

  _V3 get unit {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }

  /// Rotation about Y with the Three.js sign convention.
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Pinhole camera matching a Three.js PerspectiveCamera.
class _Cam {
  _Cam({
    required this.eye,
    required _V3 target,
    required double fovDeg,
    required this.center,
    required double viewHeight,
  }) {
    f = (target - eye).unit;
    r = f.cross(const _V3(0, 1, 0)).unit;
    u = r.cross(f);
    focal = viewHeight / 2 / math.tan(fovDeg * math.pi / 360);
  }

  final _V3 eye;
  final Offset center;
  late final _V3 f, r, u;
  late final double focal;

  double depth(_V3 w) => (w - eye).dot(f);
  double k(_V3 w) => focal / math.max(depth(w), 0.05);

  Offset p(_V3 w) {
    final d = w - eye;
    final z = math.max(d.dot(f), 0.05);
    return Offset(center.dx + d.dot(r) / z * focal, center.dy - d.dot(u) / z * focal);
  }

  /// HTML `raycaster.ray.intersectPlane(dragPlane)`.
  _V3? onPlaneY(Offset s, double y) {
    final dir = f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal);
    if (dir.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  Rect screenRect(_V3 c, _V3 h) {
    var l = double.infinity, t = double.infinity, rr = -double.infinity, b = -double.infinity;
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final q = p(c + _V3(sx * h.x, sy * h.y, sz * h.z));
          l = math.min(l, q.dx);
          rr = math.max(rr, q.dx);
          t = math.min(t, q.dy);
          b = math.max(b, q.dy);
        }
      }
    }
    return Rect.fromLTRB(l, t, rr, b);
  }
}

/// One framing per scenario of the same HTML camera: the circuit bench
/// of scenario 1 sits higher up the desk, so it is centred lower.
final List<_Cam> _cams = [
  for (final cy in const [255.0, 208.75])
    _Cam(
      eye: const _V3(0, 40, 50),
      target: _V3.zero,
      fovDeg: 40,
      center: Offset(498.75, cy),
      viewHeight: 700,
    ),
];

/// Quadratic Bezier (THREE.QuadraticBezierCurve3).
List<_V3> _bezier(_V3 a, _V3 b, _V3 c, {int n = 30}) => [
      for (var i = 0; i <= n; i++)
        a * ((1 - i / n) * (1 - i / n)) + b * (2 * (1 - i / n) * (i / n)) + c * ((i / n) * (i / n)),
    ];

// HTML toon palette (`C`).
const Color _cBlue = Color(0xFF2B5B84);
const Color _cSilver = Color(0xFFE2E8F0);
const Color _cOutline = Color(0xFF1E293B);
const Color _cWoodTop = Color(0xFF986641);
const Color _cWoodBase = Color(0xFF7A4F30);
const Color _cTrayGrey = Color(0xFF8C9AA8);
const Color _cTrayDark = Color(0xFF606D7A);
const Color _cWireRed = Color(0xFFEA4335);
const Color _cWireBlack = Color(0xFF202124);
const Color _cBatteryBody = Color(0xFF202020);
const Color _cBatteryLabel = Color(0xFF4285F4);
const Color _cGlassOff = Color(0xFF333333);
const Color _cGlassOn = Color(0xFFFFFFE3); // 0xFFF7B0 + 0.2
const Color _cYellow = Color(0xFFFACC15);
const Color _cCopper = Color(0xFFC47B5A);
const Color _cPink = Color(0xFFF472B6);
const Color _cOrange = Color(0xFFFB923C);
const Color _cParticle = Color(0xFF00FFFF);

final _V3 _toonLight = const _V3(0.35, 0.85, 0.4).unit;

/// MeshBasicMaterial is unlit; a gentle face tint keeps the toon look while
/// giving the faces some depth.
Color _toon(Color c, _V3 n) {
  final k = 0.8 + 0.2 * math.max(0.0, n.dot(_toonLight));
  return Color.from(
    alpha: c.a,
    red: (c.r * k).clamp(0.0, 1.0),
    green: (c.g * k).clamp(0.0, 1.0),
    blue: (c.b * k).clamp(0.0, 1.0),
  );
}

class _Poly {
  _Poly(this.pts, this.n, this.color, {this.edges, this.outline = true, this.opacity = 1});

  final List<_V3> pts;
  final _V3 n;
  final Color color;
  final double opacity;

  /// Draw the black toon edges (HTML `addOutline` EdgesGeometry).
  final bool outline;

  /// Only these vertex index pairs are crease edges (null = all).
  final List<(int, int)>? edges;
}

/// Face collector + painter's-algorithm renderer with toon outlines.
class _R3 {
  _R3(this.canvas, this.cam);

  final Canvas canvas;
  final _Cam cam;
  final List<_Poly> _buf = [];

  void quad(List<_V3> pts, _V3 n, Color color, {bool outline = true, double opacity = 1}) =>
      _buf.add(_Poly(pts, n, color, outline: outline, opacity: opacity));

  void box(_V3 c, _V3 h, Color color, {double ry = 0, bool outline = true}) {
    _V3 pt(double sx, double sy, double sz) => c + _V3(sx * h.x, sy * h.y, sz * h.z).rotY(ry);
    _V3 nn(double x, double y, double z) => _V3(x, y, z).rotY(ry);
    void f(List<_V3> pts, _V3 n) => _buf.add(_Poly(pts, n, color, outline: outline));
    f([pt(1, -1, -1), pt(1, 1, -1), pt(1, 1, 1), pt(1, -1, 1)], nn(1, 0, 0));
    f([pt(-1, -1, -1), pt(-1, -1, 1), pt(-1, 1, 1), pt(-1, 1, -1)], nn(-1, 0, 0));
    f([pt(-1, 1, -1), pt(-1, 1, 1), pt(1, 1, 1), pt(1, 1, -1)], nn(0, 1, 0));
    f([pt(-1, -1, -1), pt(1, -1, -1), pt(1, -1, 1), pt(-1, -1, 1)], nn(0, -1, 0));
    f([pt(-1, -1, 1), pt(1, -1, 1), pt(1, 1, 1), pt(-1, 1, 1)], nn(0, 0, 1));
    f([pt(-1, -1, -1), pt(-1, 1, -1), pt(1, 1, -1), pt(1, -1, -1)], nn(0, 0, -1));
  }

  /// Cylinder / cone frustum from [a] (radius [ra]) to [b] (radius [rb]);
  /// only the rims are outlined, like EdgesGeometry on a smooth cylinder.
  void frustum(_V3 a, _V3 b, double ra, double rb, Color color,
      {int seg = 24, bool capA = true, bool capB = true, bool outline = true, double phase = 0}) {
    final axis = b - a;
    final len = axis.length;
    if (len < 1e-6) return;
    final w = axis * (1 / len);
    final ref = w.y.abs() < 0.95 ? const _V3(0, 1, 0) : const _V3(1, 0, 0);
    final u = w.cross(ref).unit;
    final v = w.cross(u);
    final slope = (ra - rb) / len;
    final ringA = <_V3>[], ringB = <_V3>[], dirs = <_V3>[];
    for (var i = 0; i < seg; i++) {
      final ang = phase + i / seg * 2 * math.pi;
      final d = u * math.cos(ang) + v * math.sin(ang);
      dirs.add(d);
      ringA.add(a + d * ra);
      ringB.add(b + d * rb);
    }
    final sharp = seg <= 8; // low-poly (e.g. 4/6 sided) shows every edge
    for (var i = 0; i < seg; i++) {
      final j = (i + 1) % seg;
      final n = ((dirs[i] + dirs[j]).unit + w * slope).unit;
      _buf.add(_Poly([ringA[i], ringA[j], ringB[j], ringB[i]], n, color,
          outline: outline, edges: sharp ? null : const [(0, 1), (2, 3)]));
    }
    if (capA && ra > 0) _buf.add(_Poly(ringA.reversed.toList(), w * -1, color, outline: outline));
    if (capB && rb > 0) _buf.add(_Poly(ringB, w, color, outline: outline));
  }

  void flush({double edgeWidth = 1.3}) {
    final eye = cam.eye;
    final items = <(_Poly, double)>[];
    for (final p in _buf) {
      var cx = 0.0, cy = 0.0, cz = 0.0;
      for (final v in p.pts) {
        cx += v.x;
        cy += v.y;
        cz += v.z;
      }
      final n = p.pts.length;
      final c = _V3(cx / n, cy / n, cz / n);
      if (p.n.dot(eye - c) <= 0) continue;
      items.add((p, cam.depth(c)));
    }
    _buf.clear();
    items.sort((a, b) => b.$2.compareTo(a.$2));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = edgeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = _cOutline;
    for (final (p, _) in items) {
      final pts = [for (final v in p.pts) cam.p(v)];
      final path = Path()..addPolygon(pts, true);
      final col = _toon(p.color, p.n);
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: p.opacity));
      if (p.opacity >= 0.99) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7
            ..color = col,
        );
      }
      if (!p.outline) continue;
      if (p.edges == null) {
        canvas.drawPath(path, edge);
      } else {
        for (final (i, j) in p.edges!) {
          canvas.drawLine(pts[i], pts[j], edge);
        }
      }
    }
  }

  /// Draws [parts] far-to-near (each part's faces are depth-sorted).
  void parts(List<(_V3, VoidCallback)> parts) {
    final eye = cam.eye;
    parts.sort((a, b) => (b.$1 - eye).length.compareTo((a.$1 - eye).length));
    for (final p in parts) {
      p.$2();
      flush();
    }
  }

  Rect hEllipse(_V3 c, double rx, [double? rz]) {
    final z = rz ?? rx;
    final l = cam.p(c - _V3(rx, 0, 0)), r = cam.p(c + _V3(rx, 0, 0));
    final b = cam.p(c - _V3(0, 0, z)), f = cam.p(c + _V3(0, 0, z));
    return Rect.fromLTRB(l.dx, b.dy, r.dx, f.dy);
  }

  Path hPath(_V3 c, double rx, double rz, {double ry = 0, int n = 28}) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a = i / n * 2 * math.pi;
      final q = cam.p(c + _V3(math.cos(a) * rx, 0, math.sin(a) * rz).rotY(ry));
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    return path..close();
  }

  void shadow(_V3 base, double rx, double rz, {double opacity = 0.25, double lift = 0, double ry = 0}) {
    final c = _V3(base.x - 0.25 * lift, base.y + 0.01, base.z - 0.25 * lift);
    canvas.drawPath(
      hPath(c, rx * (1 + lift * 0.05), rz * (1 + lift * 0.05), ry: ry),
      Paint()
        ..color = Colors.black.withValues(alpha: opacity / (1 + lift * 0.3))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (0.25 + lift * 0.2) * cam.k(c)),
    );
  }

  /// Toon tube (wires) with a dark outline.
  void tube(List<_V3> pts, double r, Color color, {double opacity = 1}) {
    if (pts.length < 2) return;
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = cam.p(pts[i]);
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    final w = 2 * r * cam.k(pts[pts.length ~/ 2]);
    Paint st(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c.withValues(alpha: c.a * opacity);
    canvas.drawPath(path, st(w + 2.6, _cOutline));
    canvas.drawPath(path, st(w, color));
    canvas.drawPath(path.shift(Offset(0, -w * 0.18)), st(w * 0.3, Colors.white.withValues(alpha: 0.22)));
  }
}

/// Regular dodecahedron (unit circumradius) as (normal, face) pairs, for
/// the crumpled aluminium foil (THREE.DodecahedronGeometry).
final List<(_V3, List<_V3>)> _dodeca = () {
  const phi = 1.618033988749895;
  const ip = 1 / phi;
  final s = 1 / math.sqrt(3);
  final verts = <_V3>[
    for (final x in const [-1.0, 1.0])
      for (final y in const [-1.0, 1.0])
        for (final z in const [-1.0, 1.0]) _V3(x, y, z) * s,
    for (final a in const [-1.0, 1.0])
      for (final b in const [-1.0, 1.0]) ...[
        _V3(0, a * ip, b * phi) * s,
        _V3(a * ip, b * phi, 0) * s,
        _V3(a * phi, 0, b * ip) * s,
      ],
  ];
  final normals = <_V3>[
    for (final a in const [-1.0, 1.0])
      for (final b in const [-1.0, 1.0]) ...[_V3(0, a, b * phi).unit, _V3(a, b * phi, 0).unit, _V3(a * phi, 0, b).unit],
  ];
  return [
    for (final n in normals)
      () {
        final face = ([...verts]..sort((p, q) => q.dot(n).compareTo(p.dot(n)))).take(5).toList();
        final c = face.reduce((a, b) => a + b) * 0.2;
        final u = (face[0] - c).unit, v = n.cross(u);
        double ang(_V3 a) => math.atan2((a - c).dot(v), (a - c).dot(u));
        face.sort((a, b) => ang(a).compareTo(ang(b)));
        return (n, face);
      }(),
  ];
}();

/// White sprite label (HTML `createLabelSprite`), drawn in a final pass.
class _Label {
  const _Label(this.text, this.at, {this.mult = 1});
  final String text;
  final _V3 at;
  final double mult;
}

void _drawLabels(Canvas canvas, _Cam cam, List<_Label> labels) {
  final placed = <(_Label, Rect, double)>[];
  final order = [...labels]..sort((a, b) => cam.depth(a.at).compareTo(cam.depth(b.at)));
  for (final l in order) {
    final size = (0.61 * l.mult * cam.k(l.at) * 1.3).clamp(10.5, 22.0);
    final tp = TextPainter(
      text: TextSpan(
        text: l.text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var rect = Rect.fromCenter(center: cam.p(l.at), width: tp.width + size * 1.2, height: tp.height + size * 0.45);
    // Keep the pill inside the stage (Hindi labels are wider).
    if (rect.left < 4) rect = rect.translate(4 - rect.left, 0);
    if (rect.right > _design.width - 4) rect = rect.translate(_design.width - 4 - rect.right, 0);
    for (var guard = 0; guard < 12; guard++) {
      Rect? hit;
      for (final q in placed) {
        if (q.$2.overlaps(rect.deflate(1))) {
          hit = q.$2;
          break;
        }
      }
      if (hit == null) break;
      rect = rect.translate(0, hit.top - rect.bottom - 2);
    }
    placed.add((l, rect, size));
  }
  for (final (l, rect, size) in placed.reversed) {
    labText(
      canvas,
      l.text,
      rect.center,
      size: size,
      color: const Color(0xFF0F172A),
      weight: FontWeight.w800,
      background: const Color(0xE6FFFFFF),
      border: const Color(0xFF0F172A),
      borderWidth: math.max(1.5, size * 0.1),
      radius: size * 0.45,
      padding: EdgeInsets.symmetric(horizontal: size * 0.6, vertical: size * 0.22),
    );
  }
}

// ============================================================ PAINTER

class _A2Painter extends CustomPainter {
  _A2Painter({
    required this.world,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
  }) : super(repaint: repaint);

  final _World world;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> text;

  String _s(String key) => text[key] ?? key;
  _Cam get cam => _cams[world.scenario];
  double _key(_V3 a) => cam.depth(a) - 2.0 * a.y;

  _StepDef? get _def {
    final defs = _stepDefs[world.scenario];
    return world.step < defs.length ? defs[world.step] : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = _R3(canvas, cam);
    final w = world;
    _background(canvas, size);
    _table(r);
    if (w.scenario == 0) {
      r.box(const _V3(-20, 1.25, 0), const _V3(6, 0.25, 10), _cTrayGrey);
      r.flush();
      _spot(r, const _V3(-4, 1.05, -2));
      _spot(r, const _V3(12, 1.05, -2));
    } else {
      _materialsTray(r);
      r.box(const _V3(4, 1.25, 8), const _V3(5, 0.25, 2), _cBlue);
      r.flush();
    }
    _shadows(r);

    final list = <(double, VoidCallback)>[
      (_key(w.battery.pos), () => _battery(r, w.battery.pos)),
      (_key(w.bulb.pos), () => _bulb(r, w.bulb.pos)),
      if (w.scenario == 1) ...[
        (_key(const _V3(1, 1.5, 8)), () => _terminal(r, const _V3(1, 1.5, 8))),
        (_key(const _V3(7, 1.5, 8)), () => _terminal(r, const _V3(7, 1.5, 8))),
        for (final o in w.items) (_key(o.pos), () => _item(r, o)),
      ],
      if (w.binsVisible) ...[
        (_key(_binCond + const _V3(0, 0, -6)) + 2, () => _binBack(r, _binCond, _cBlue)),
        (_key(_binIns + const _V3(0, 0, -6)) + 2, () => _binBack(r, _binIns, _cOrange)),
        (_key(_binCond + const _V3(0, 0, 6)), () => _binFront(r, _binCond, _cBlue)),
        (_key(_binIns + const _V3(0, 0, 6)), () => _binFront(r, _binIns, _cOrange)),
      ],
      for (final wire in w.wires) (_key(wire.at(0.5)) + 0.5, () => _wire(r, wire)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final e in list) {
      e.$2();
    }

    // Bulb halo (additive glow sprite).
    if (w.glow > 0.01) {
      final gc = w.bulb.pos + const _V3(0, 4, 0);
      labGlow(canvas, cam.p(gc), 7.5 * cam.k(gc), _cYellow, intensity: 0.85 * w.glow);
    }
    _wireHints(canvas);
    if (showLabels) _labels(canvas);
  }

  void _background(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFF334155));
    final c = Offset(size.width * 0.55, size.height * 0.45);
    final rad = size.width * 0.75;
    canvas.drawCircle(
      c,
      rad,
      Paint()
        ..shader = RadialGradient(colors: [
          (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF64748B)).withValues(alpha: 0.35),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: c, radius: rad)),
    );
  }

  /// 60 x 30 desk with base and four block legs.
  void _table(_R3 r) {
    for (final p in const [_V3(-20, -8, -11), _V3(32, -8, -11), _V3(-20, -8, 11), _V3(32, -8, 11)]) {
      r.box(p, const _V3(1.25, 7.5, 1.25), _cWoodBase);
    }
    r.flush();
    r.box(const _V3(6, -0.6, 0), const _V3(29, 0.6, 14), _cWoodBase);
    r.flush();
    r.box(const _V3(6, 0.5, 0), const _V3(30, 0.5, 15), _cWoodTop);
    r.flush();
    // Subtle wood grain on the top.
    final grain = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF5B3A1E).withValues(alpha: 0.18);
    for (var z = -13.0; z <= 13.0; z += 2.6) {
      r.canvas.drawLine(cam.p(_V3(-24, 1.001, z)), cam.p(_V3(36, 1.001, z)), grain);
    }
  }

  void _materialsTray(_R3 r) {
    r.box(const _V3(-20, 1.25, 0), const _V3(7, 0.25, 12), _cTrayDark);
    r.flush();
    r.parts([
      (const _V3(-20, 1.75, 0), () => r.box(const _V3(-20, 1.75, 0), const _V3(0.25, 0.5, 12), _cTrayGrey, outline: false)),
      (const _V3(-20, 1.75, -4), () => r.box(const _V3(-20, 1.75, -4), const _V3(7, 0.5, 0.25), _cTrayGrey, outline: false)),
      (const _V3(-20, 1.75, 4), () => r.box(const _V3(-20, 1.75, 4), const _V3(7, 0.5, 0.25), _cTrayGrey, outline: false)),
    ]);
  }

  /// Yellow placement ring (RingGeometry 3..3.5).
  void _spot(_R3 r, _V3 c) {
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(r.hPath(c, 3.5, 3.5, n: 40), Offset.zero)
      ..addPath(r.hPath(c, 3.0, 3.0, n: 40), Offset.zero);
    r.canvas.drawPath(ring, Paint()..color = _cYellow);
  }

  void _shadows(_R3 r) {
    final w = world;
    void sh(_Obj o, double rx, double rz, {double yaw = 0}) {
      final lift = o.lifted ? 3.0 : 0.0;
      r.shadow(_V3(o.pos.x, o.pos.y - lift, o.pos.z), rx, rz, lift: lift, ry: yaw);
    }

    sh(w.battery, 5.2, 2.7);
    sh(w.bulb, 4.2, 3.2);
    if (w.scenario == 1) {
      for (final o in w.items) {
        final yaw = o.inGap ? math.pi / 2 : 0.0;
        switch (o.id) {
          case 'coin' || 'foil':
            sh(o, 1.5, 1.5);
          case 'spoon':
            sh(o, 1.0, 3.0, yaw: yaw);
          case 'eraser':
            sh(o, 1.4, 1.9, yaw: yaw);
          default:
            sh(o, 0.6, 2.3, yaw: yaw);
        }
      }
    }
  }

  /// Binding post (HTML `buildTerminal`) whose base sits at [t].
  void _terminal(_R3 r, _V3 t) {
    r.frustum(t, t + const _V3(0, 0.3, 0), 0.8, 0.8, _cSilver, seg: 20);
    r.flush();
    r.frustum(t + const _V3(0, 0.25, 0), t + const _V3(0, 0.75, 0), 0.4, 0.4, Colors.white, seg: 16);
    r.flush();
  }

  /// Battery on its base plate: label band, caps, nub, + / - marks and
  /// two terminals (local (±4, 0.5, 1.5)).
  void _battery(_R3 r, _V3 p) {
    r.box(p + const _V3(0, 0.25, 0), const _V3(5, 0.25, 2.5), _cBlue);
    r.flush();
    final cy = p.y + 2.3;
    _V3 ax(double x) => _V3(p.x + x, cy, p.z);
    final top = cy + 1.83;
    r.parts([
      (ax(-3.5), () => r.frustum(ax(-3.7), ax(-3.3), 1.82, 1.82, _cSilver, seg: 32, capB: false)),
      (ax(-2.8), () => r.frustum(ax(-3.3), ax(-2.25), 1.8, 1.8, _cBatteryBody, seg: 32, capA: false, capB: false)),
      (ax(0), () => r.frustum(ax(-2.25), ax(2.25), 1.81, 1.81, _cBatteryLabel, seg: 32, capA: false, capB: false, outline: false)),
      (ax(2.8), () => r.frustum(ax(2.25), ax(3.3), 1.8, 1.8, _cBatteryBody, seg: 32, capA: false, capB: false)),
      (ax(3.5), () => r.frustum(ax(3.3), ax(3.7), 1.82, 1.82, _cSilver, seg: 32, capA: false)),
      (ax(3.9), () => r.frustum(ax(3.7), ax(4.1), 0.6, 0.6, _cSilver, seg: 20, capA: false)),
      (p + const _V3(4, 0.9, 1.5), () => _terminal(r, p + const _V3(4, 0.5, 1.5))),
      (p + const _V3(-4, 0.9, 1.5), () => _terminal(r, p + const _V3(-4, 0.5, 1.5))),
      (_V3(p.x, top + 1, p.z), () {
        r.box(_V3(p.x + 1.5, top, p.z), const _V3(0.1, 0.05, 0.4), Colors.white, outline: false);
        r.box(_V3(p.x + 1.5, top, p.z), const _V3(0.4, 0.05, 0.1), Colors.white, outline: false);
        r.box(_V3(p.x - 1.5, top, p.z), const _V3(0.4, 0.05, 0.1), Colors.white, outline: false);
      }),
    ]);
  }

  /// Bulb holder: plate, white base, grey inner ring, silver screw, glass
  /// globe with filament and two terminals (local (±2.5, 0.5, 1.5)).
  void _bulb(_R3 r, _V3 p) {
    final canvas = r.canvas;
    final glow = world.glow;
    r.box(p + const _V3(0, 0.25, 0), const _V3(4, 0.25, 3), _cBlue);
    r.flush();
    r.parts([
      (p + const _V3(0, 0.75, 0), () => r.frustum(p + const _V3(0, 0.5, 0), p + const _V3(0, 1.0, 0), 3, 2.5, Colors.white, seg: 32)),
      (p + const _V3(0, 1.15, 0), () => r.frustum(p + const _V3(0, 1.0, 0), p + const _V3(0, 1.3, 0), 2, 2, _cTrayGrey, seg: 32)),
      (p + const _V3(0, 2.0, 0), () => r.frustum(p + const _V3(0, 1.25, 0), p + const _V3(0, 2.75, 0), 1.2, 1.2, _cSilver, seg: 28)),
      (p + const _V3(-2.5, 0.9, 1.5), () => _terminal(r, p + const _V3(-2.5, 0.5, 1.5))),
      (p + const _V3(2.5, 0.9, 1.5), () => _terminal(r, p + const _V3(2.5, 0.5, 1.5))),
    ]);
    // Glass globe (SphereGeometry r 2.2): dark when off, pale yellow on.
    final gc = p + const _V3(0, 4, 0);
    final c = cam.p(gc);
    final k = cam.k(gc);
    final rad = 2.2 * k;
    final col = Color.lerp(_cGlassOff, _cGlassOn, glow)!;
    canvas.drawCircle(c, rad, Paint()..color = col.withValues(alpha: 0.9 + 0.08 * glow));
    // Filament (TorusGeometry r 0.6 facing the camera).
    final fil = Path();
    for (var i = 0; i <= 24; i++) {
      final a = i / 24 * 2 * math.pi;
      final q = cam.p(gc + _V3(0.6 * math.cos(a), 0.6 * math.sin(a), 0));
      i == 0 ? fil.moveTo(q.dx, q.dy) : fil.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(
      fil,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.16 * k
        ..color = Color.lerp(const Color(0xFF111827), const Color(0xFFF59E0B), glow)!.withValues(alpha: 0.75),
    );
    canvas.drawCircle(c.translate(-rad * 0.38, -rad * 0.4), rad * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.18 + 0.2 * glow));
    canvas.drawCircle(
      c,
      rad,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = _cOutline.withValues(alpha: 0.6),
    );
  }

  /// Test materials (HTML `buildItem`); items in the gap lie across it.
  void _item(_R3 r, _Obj o) {
    final p = o.pos;
    final yaw = o.inGap && o.id != 'coin' && o.id != 'foil' ? math.pi / 2 : 0.0;
    _V3 l(double x, double y, double z) => p + _V3(x, y, z).rotY(yaw);
    switch (o.id) {
      case 'coin':
        r.frustum(p, p + const _V3(0, 0.2, 0), 1.5, 1.5, _cCopper, seg: 36);
        r.flush();
        r.canvas.drawOval(
          r.hEllipse(p + const _V3(0, 0.21, 0), 1.1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = labShade(_cCopper, -0.25),
        );
      case 'spoon':
        final bowlC = l(0, 0.24, -1.2);
        final bowl = r.hPath(bowlC, 1.2, 1.68, ry: yaw);
        r.canvas.drawPath(bowl, Paint()..color = Colors.white);
        r.canvas.drawPath(r.hPath(bowlC + const _V3(0, 0.05, 0), 0.8, 1.15, ry: yaw),
            Paint()..color = const Color(0xFFE2E8F0));
        r.canvas.drawPath(
          bowl,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFF94A3B8),
        );
        r.box(l(0, 0.24, 1.5), const _V3(0.3, 0.1, 1.75), Colors.white, ry: yaw);
        r.flush();
      case 'nail':
        r.parts([
          (l(0, 0.3, 0), () => r.frustum(l(0, 0.3, -2), l(0, 0.3, 1.9), 0.15, 0.15, _cSilver, seg: 12)),
          (l(0, 0.3, 2), () => r.frustum(l(0, 0.3, 1.9), l(0, 0.3, 2.1), 0.5, 0.5, _cSilver, seg: 20)),
        ]);
      case 'eraser':
        r.box(l(0, 0.5, 0), const _V3(1.25, 0.5, 1.75), _cPink, ry: yaw);
        r.flush();
      case 'wood':
        r.frustum(l(0, 0.3, -2.25), l(0, 0.3, 2.25), 0.3, 0.3, _cWoodTop, seg: 16);
        r.flush();
      case 'foil':
        final c = p + const _V3(0, 1.12, 0);
        for (final (n, face) in _dodeca) {
          r.quad([for (final v in face) c + v * 1.2], n, _cSilver);
        }
        r.flush();
    }
  }

  /// Sorting bin (HTML `buildBin`, 14 x 4 x 12, opaque toon walls).
  void _binBack(_R3 r, _V3 b, Color c) {
    r.box(b + const _V3(0, 0.25, 0), const _V3(7, 0.25, 6), c);
    r.flush();
    r.parts([
      (b + const _V3(0, 2, -6), () => r.box(b + const _V3(0, 2, -6), const _V3(7, 2, 0.25), c)),
      (b + const _V3(-7, 2, 0), () => r.box(b + const _V3(-7, 2, 0), const _V3(0.25, 2, 6), c)),
      (b + const _V3(7, 2, 0), () => r.box(b + const _V3(7, 2, 0), const _V3(0.25, 2, 6), c)),
    ]);
  }

  void _binFront(_R3 r, _V3 b, Color c) {
    r.box(b + const _V3(0, 2, 6), const _V3(7, 2, 0.25), c);
    r.flush();
  }

  /// Wire tube + end rings; cyan current particles while the bulb glows.
  void _wire(_R3 r, _Wire wire) {
    final canvas = r.canvas;
    r.tube(wire.pts, 0.35, wire.color);
    for (final e in [wire.a, wire.b]) {
      final ring = r.hEllipse(e, 0.6);
      final k = cam.k(e);
      canvas.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.36 * k + 2
          ..color = _cOutline,
      );
      canvas.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.36 * k
          ..color = wire.color,
      );
    }
    final g = world.glow;
    if (g < 0.01) return;
    for (var i = 0; i < 10; i++) {
      final q = wire.at((i / 10 + world.flow) % 1);
      final c = cam.p(q);
      final rad = 0.28 * cam.k(q);
      labGlow(canvas, c, rad * 2.6, _cParticle, intensity: 0.5 * g);
      canvas.drawCircle(c, rad, Paint()..color = _cParticle.withValues(alpha: g));
    }
  }

  /// Wiring guidance: pulsing valid terminals and a rubber-band preview.
  void _wireHints(Canvas canvas) {
    final def = _def;
    if (def == null || def.act != _Act.wire) return;
    final w = world;
    final terms = w.terminals;
    final pulse = 0.5 + 0.5 * math.sin(w.time * 5);
    void ring(_V3 at, Color c, double a) {
      final e = _R3(canvas, cam).hEllipse(at + const _V3(0, -0.2, 0), 1.35);
      canvas.drawOval(
        e.inflate(2 + 3 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = c.withValues(alpha: a),
      );
    }

    final start = w.wireStart;
    if (start == null) {
      terms.forEach((id, c) {
        if (_World.termClass(id) == def.start) ring(c, _cYellow, 0.4 + 0.5 * pulse);
      });
      return;
    }
    ring(terms[start]!, _cYellow, 1);
    terms.forEach((id, c) {
      if (id != start && _World.termClass(id) == def.end && !w.usedTerminals.contains(id)) {
        ring(c, _Colors.green, 0.35 + 0.55 * pulse);
      }
    });
    final ptr = w.wirePointer;
    if (ptr != null) {
      final a = cam.p(terms[start]!);
      final color = def.start == 'term-pos' ? _cWireRed : const Color(0xFFCBD5E1);
      labDashedLine(
        canvas,
        a,
        ptr,
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = color,
        dash: 10,
        gap: 7,
        phase: -w.time * 30,
      );
      canvas.drawCircle(ptr, 6, Paint()..color = color);
    }
  }

  void _labels(Canvas canvas) {
    final w = world;
    const heights = {'coin': 3.2, 'spoon': 3.48, 'nail': 4.0, 'eraser': 4.0, 'wood': 3.6, 'foil': 5.24};
    _drawLabels(canvas, cam, [
      if (w.scenario == 0) _Label(_s('lbl_partsTray'), const _V3(-20, 2.75, -9)),
      if (w.scenario == 1) _Label(_s('lbl_matTray'), const _V3(-20, 2.75, -11)),
      _Label(_s('lbl_bat'), w.battery.pos + const _V3(0, 5.5, 0)),
      _Label(_s('lbl_bulb'), w.bulb.pos + const _V3(0, -1.5, 0)),
      if (w.bulbOn) _Label(_s('lbl_intensity'), w.bulb.pos + const _V3(0, 7.5, 0)),
      if (w.scenario == 1) ...[
        _Label(_s('lbl_terminals'), const _V3(4, -0.5, 8)),
        for (final o in w.items) _Label(_s('lbl_${o.id}'), o.pos + _V3(0, heights[o.id]!, 0)),
      ],
      if (w.binsVisible) ...[
        _Label(_s('lbl_cond'), _binCond + const _V3(0, 6, 0), mult: 1.2),
        _Label(_s('lbl_ins'), _binIns + const _V3(0, 6, 0), mult: 1.2),
      ],
    ]);
  }

  @override
  bool shouldRepaint(covariant _A2Painter old) =>
      old.world != world || old.isDark != isDark || old.showLabels != showLabels || !mapEquals(old.text, text);
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
