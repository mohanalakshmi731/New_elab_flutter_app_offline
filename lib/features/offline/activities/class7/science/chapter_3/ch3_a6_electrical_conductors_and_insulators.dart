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

/// Class 7 Science • Chapter 3 • Activity 6
/// Electrical Conductors & Insulators.
///
/// Native Flutter port of `Cl7S-Ch3-A6-Electrical_Conductors_and_Insulators.html`.
/// Scenario 1: drag the cell and the lamp from the materials tray onto the
/// workbench, pull wires from the terminals (cell + to lamp, cell - to the
/// left end of the testing gap, lamp to the right end) and drop the metal
/// key into the gap: the bulb glows and electrons flow. Scenario 2: remove
/// the key, test the wooden stick (the bulb stays off) and review the
/// summary. Afterwards any material can be tested freely.
class Ch3A6ElectricalConductorsAndInsulatorsPage extends StatefulWidget {
  const Ch3A6ElectricalConductorsAndInsulatorsPage({super.key});

  @override
  State<Ch3A6ElectricalConductorsAndInsulatorsPage> createState() => _Ch3A6ElectricalConductorsAndInsulatorsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, spark 2365, buzz 2594.
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
  spark('spark.mp3'),
  buzz('buzz.mp3');

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

class _Ch3A6ElectricalConductorsAndInsulatorsPageState extends State<Ch3A6ElectricalConductorsAndInsulatorsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// True while the intermediate observation popup is open; closing it
  /// advances the step (HTML `closeObservation`).
  bool _obsOpen = false;

  Offset? _panLocal;
  _V3 _dragOffset = const _V3(0, 0, 0);

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _lab.addListener(_onLabChanged);
    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.removeListener(_onLabChanged);
    _lab.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- animation

  static double _approach(double v, double target, double step) =>
      v < target ? math.min(target, v + step) : math.max(target, v - step);

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    final s = _scene;
    s.time = elapsed.inMicroseconds / 1e6;
    // HTML updateElectrons(): speed 0.5 loop per second; when blocked by an
    // insulator they only run over the first half of the loop (the painter
    // wraps them at 0.5). A shared phase keeps them evenly spaced at any
    // frame rate.
    final flowing = s.circuitClosed || s.showBlocked;
    if (flowing) s.flowPhase = (s.flowPhase + 0.5 * dt) % 1.0;
    s.electronA = _approach(s.electronA, flowing ? 1 : 0, dt * 6);
    s.glow = _approach(s.glow, s.circuitClosed ? 1 : 0, dt * 6);
    s.conductorA = _approach(s.conductorA, s.conductorBadge ? 1 : 0, dt / 0.3);
    s.insulatorA = _approach(s.insulatorA, s.insulatorBadge ? 1 : 0, dt / 0.3);
    _frame.value = s.time;
  }

  void _onLabChanged() {
    if (_obsOpen && _lab.popup == null) {
      _obsOpen = false;
      if (mounted) setState(_closeObservation);
    }
  }

  // ---------------------------------------------------------------- logic

  /// HTML `loadScenario(index)`.
  void _loadScenario(int index) {
    final s = _scene;
    _lab.cancelPending();
    _obsOpen = false;
    _lab.hidePopup(sound: false);
    s
      ..scenario = index
      ..step = 0
      ..complete = false
      ..showBlocked = false
      ..wiringSource = null
      ..wiringArmed = false
      ..wirePointer = null
      ..dragging = null;
    _clearGap();
    for (final it in _Item.values) {
      s.items[it] = s.itemHome(it);
    }
    if (index == 1) {
      // "The conduction tester circuit is already set up from the previous
      // scenario" (HTML autoBuildCircuit) with the metal key in the gap.
      if (!s.circuitBuilt) _autoBuildCircuit();
      s.items[_Item.key] = _gapCenter;
      s.gapOccupant = _Item.key;
      _setCircuit(true, sound: false);
      s.conductorBadge = true;
      s.removeBtn = true;
    } else {
      s
        ..batt = _battHome
        ..lamp = _lampHome
        ..battPlaced = false
        ..lampPlaced = false
        ..w1 = false
        ..w2 = false
        ..w3 = false
        ..circuitBuilt = false
        ..electronPath = const []
        ..electronCum = const [];
      _setCircuit(false, sound: false);
    }
    _renderSteps();
  }

  /// HTML `autoBuildCircuit()` (scenario 2 opened directly).
  void _autoBuildCircuit() {
    final s = _scene;
    s
      ..batt = const _V3(-6, 0.1, -2)
      ..lamp = const _V3(2, 0.1, -2)
      ..battPlaced = true
      ..lampPlaced = true
      ..w1 = true
      ..w2 = true
      ..w3 = true
      ..circuitBuilt = true;
    s.buildElectronPath();
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `setCircuitState(isClosed)` (+ the 60 Hz hum when the lamp lights).
  void _setCircuit(bool closed, {bool sound = true}) {
    if (closed && !_scene.circuitClosed && sound) _Audio.play(_Sound.buzz);
    _scene.circuitClosed = closed;
  }

  /// HTML `progressStep()`.
  void _progressStep() {
    final s = _scene;
    s.step++;
    final n = _stepTypes[s.scenario].length;
    if (s.step >= n) {
      s.complete = true;
      s.step = n;
    }
    _renderSteps();
  }

  /// HTML `renderSteps()`: observation / summary steps open their popup
  /// after 1.5 s.
  void _renderSteps() {
    final st = _scene.stepType;
    if (st == _StepType.observe || st == _StepType.summary) {
      final scen = _scene.scenario, step = _scene.step;
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scene.scenario != scen || _scene.step != step || _scene.complete) return;
        _triggerObservation();
      });
    }
  }

  /// HTML `closeObservation()`.
  void _closeObservation() {
    final st = _scene.stepType;
    if (st == _StepType.observe || st == _StepType.summary) _progressStep();
  }

  /// HTML `validatePlacement(obj)`.
  void _validatePlacement(_Comp comp) {
    final s = _scene;
    if (!s.complete && s.stepType != _StepType.place) return;
    final zone = comp == _Comp.battery ? _battZone : _lampZone;
    final pos = comp == _Comp.battery ? s.batt : s.lamp;
    final dist = math.sqrt(_BenchPainter._dist2(pos, zone));
    if (dist < 6.0) {
      final placed = _V3(zone.x, 0.1, zone.z);
      if (comp == _Comp.battery) {
        s
          ..batt = placed
          ..battPlaced = true;
      } else {
        s
          ..lamp = placed
          ..lampPlaced = true;
      }
      _Audio.play(_Sound.drop);
      if (!s.complete && s.battPlaced && s.lampPlaced) _progressStep();
    } else {
      _Audio.play(_Sound.wrong);
      if (comp == _Comp.battery) {
        s.batt = _battHome;
      } else {
        s.lamp = _lampHome;
      }
    }
  }

  /// HTML `validateWiring(srcId, tgtId)`.
  void _validateWiring(_Term src, _Term tgt) {
    final s = _scene;
    if (s.complete) return;
    bool pair(_Term a, _Term b) => (src == a && tgt == b) || (src == b && tgt == a);
    final st = s.stepType;
    if (st == _StepType.wire && pair(_Term.battPos, _Term.lampIn)) {
      s.w1 = true;
      _Audio.play(_Sound.spark);
      _progressStep();
    } else if (st == _StepType.wireGap && !s.w2 && pair(_Term.battNeg, _Term.gapLeft)) {
      s.w2 = true;
      _Audio.play(_Sound.spark);
    } else if (st == _StepType.wireGap && s.w2 && !s.w3 && pair(_Term.lampOut, _Term.gapRight)) {
      s
        ..w3 = true
        ..circuitBuilt = true;
      _Audio.play(_Sound.spark);
      s.buildElectronPath();
      _progressStep();
    } else {
      _lab.showToast(_t('err_connect'), isError: true);
    }
  }

  /// Drop of a test object (HTML onPointerUp, non-component branch).
  void _dropItem(_Item item) {
    final s = _scene;
    final pos = s.items[item]!;
    if (math.sqrt(_BenchPainter._dist2(pos, _gapCenter)) < 5.0) {
      s.items[item] = _gapCenter;
      s.gapOccupant = item;
      _validateTestMaterial(item);
    } else {
      if (s.gapOccupant == item) {
        _removeGapObject();
      } else {
        _Audio.play(_Sound.wrong);
      }
      s.items[item] = s.itemHome(item);
    }
  }

  /// HTML `validateTestMaterial(obj)`.
  void _validateTestMaterial(_Item item) {
    final s = _scene;
    if (!s.complete && s.stepType != _StepType.test) {
      _Audio.play(_Sound.wrong);
      s.items[item] = s.itemHome(item);
      s.gapOccupant = null;
      return;
    }
    if (s.complete || item == _testTargets[s.scenario]) {
      _Audio.play(_Sound.drop);
      if (item == _Item.key) {
        _setCircuit(true);
        s
          ..showBlocked = false
          ..conductorBadge = true;
      } else {
        _setCircuit(false);
        s
          ..showBlocked = true
          ..insulatorBadge = true;
      }
      _Audio.play(_Sound.correct);
      s.removeBtn = true;
      if (!s.complete) _progressStep();
    } else {
      _lab.showToast(_t('err_object'), isError: true);
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scene.gapOccupant != item) return;
        setState(_removeGapObject);
      });
    }
  }

  /// Empties the testing gap without advancing any step.
  void _clearGap() {
    final s = _scene;
    final occ = s.gapOccupant;
    if (occ != null) s.items[occ] = s.itemHome(occ);
    s
      ..gapOccupant = null
      ..showBlocked = false
      ..conductorBadge = false
      ..insulatorBadge = false
      ..removeBtn = false;
    _setCircuit(false);
  }

  /// HTML `removeGapObject()`: back to the tray; advances the "remove" step.
  void _removeGapObject() {
    _clearGap();
    if (!_scene.complete && _scene.stepType == _StepType.remove) _progressStep();
  }

  void _onRemovePressed() => setState(_removeGapObject);

  // ------------------------------------------------------- observations

  /// HTML `triggerObservation(stepData)`: the observation / summary popup.
  /// The last step's popup also carries the "Scenario Complete" box (the
  /// HTML sidebar conclusion shown once it is closed).
  void _triggerObservation() {
    final s = _scene;
    final scen = s.scenario;
    final isLast = s.step == _stepTypes[scen].length - 1;
    final isSummary = s.stepType == _StepType.summary;
    String heading() => isSummary ? _t('summary_str') : _t('observation_title');
    String body() => isSummary ? _t('s1_summary') : _t(scen == 0 ? 's0_obs' : 's1_obs');
    Widget extra() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSummary) _protectedWire() else _explanation(_t('th_expl_label'), _t(scen == 0 ? 's0_expl' : 's1_expl')),
        if (isLast) ...[SizedBox(height: 12 * context.labScale), _completeBox()],
      ],
    );
    if (isLast) {
      setState(_progressStep);
      _lab.showScenarioConclusion(
        scenarioIndex: scen,
        totalScenarios: 2,
        title: () => _t('observation_title'),
        heading: heading,
        body: body,
        extra: extra,
        delay: Duration.zero,
      );
      return;
    }
    _obsOpen = true;
    _lab.openSidebar();
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('observation_title'),
        icon: Icons.science,
        heading: heading(),
        body: body(),
        extra: extra(),
        actions: [
          LabAction(
            label: _lab.t('btn_continue'),
            icon: Icons.arrow_forward,
            color: _Colors.indigo600,
            foreground: Colors.white,
            onTap: () => _lab.hidePopup(sound: false),
          ),
        ],
      ),
    );
  }

  TextStyle _popupText() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    return TextStyle(
      color: p.text,
      fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.4),
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
  }

  /// "<b>Explanation:</b> …" paragraph of the HTML theory text.
  Widget _explanation(String label, String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w800, color: _Colors.zslYellow),
          ),
          TextSpan(text: text),
        ],
      ),
      style: _popupText(),
    );
  }

  /// HTML conclusion box ("Scenario Complete" + free-exploration note).
  Widget _completeBox() {
    final s = context.labScale;
    final p = _Theme.of(_lab.isDark);
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: _Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: _Colors.green, size: 18 * s),
              SizedBox(width: 6 * s),
              Expanded(
                child: Text(
                  _t('scenario_complete'),
                  style: TextStyle(color: _Colors.green, fontWeight: FontWeight.w800, fontSize: 13 * s),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          Text(
            _t('scenario_conclusion'),
            style: _popupText().copyWith(color: p.text, fontSize: 12 * s),
          ),
        ],
      ),
    );
  }

  /// The HTML summary SVG: a metal core covered by plastic insulation.
  Widget _protectedWire() {
    final s = context.labScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 110 * s,
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: _Colors.slate800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.slate700),
          ),
          child: CustomPaint(
            painter: _WirePainter(core: _t('wire_core'), cover: _t('wire_cover'), scale: s),
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          _t('wire_caption'),
          textAlign: TextAlign.center,
          style: TextStyle(color: _Theme.of(_lab.isDark).textMuted, fontSize: 11 * s, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ gestures

  bool _canStartWire(_Term t) {
    final st = _scene.stepType;
    if (st == _StepType.wire) return t == _Term.battPos;
    if (st == _StepType.wireGap) return t == _Term.battNeg || t == _Term.lampOut;
    return false;
  }

  _Term? _termAt(Offset pos) {
    _Term? best;
    var bestD = 26.0;
    for (final t in _Term.values) {
      final d = (_Cam.p(_scene.term(t)) - pos).distance;
      if (d < bestD) {
        bestD = d;
        best = t;
      }
    }
    return best;
  }

  /// Object under [pos] (HTML raycast on the interactables): the thin test
  /// objects by distance to their axis, then the front-most component.
  Object? _objectAt(Offset pos) {
    final s = _scene;
    _Item? best;
    var bestD = 18.0;
    for (final it in _Item.values) {
      final d = _itemDistance(s, it, pos);
      if (d < bestD) {
        bestD = d;
        best = it;
      }
    }
    if (best != null) return best;
    final comps = [_Comp.battery, _Comp.lamp]..sort((a, b) => _posOf(b).z.compareTo(_posOf(a).z));
    for (final c in comps) {
      if (_compHit(s, c, pos)) return c;
    }
    return null;
  }

  bool _canDrag(Object obj) {
    final s = _scene;
    if (s.gapOccupant != null && s.gapOccupant != obj) return false;
    if (s.complete) return obj is _Item;
    final st = s.stepType;
    if (st == _StepType.place && obj is _Comp) {
      return obj == _Comp.battery ? !s.battPlaced : !s.lampPlaced;
    }
    // Both test objects can be picked up; the wrong one is rejected with
    // the HTML "Incorrect object!" message once dropped in the gap.
    return st == _StepType.test && obj is _Item;
  }

  _V3 _posOf(Object o) => switch (o) {
    _Comp.battery => _scene.batt,
    _Comp.lamp => _scene.lamp,
    _Item it => _scene.items[it]!,
    _ => _gapCenter,
  };

  void _onPanStart(DragStartDetails d) {
    final s = _scene;
    final pos = d.localPosition;
    _panLocal = pos;
    if (s.dragging != null) return;
    if (s.wiringArmed) {
      s
        ..wiringArmed = false
        ..wiringSource = null;
    }
    final term = _termAt(pos);
    if (term != null && _canStartWire(term)) {
      // HTML onPointerDown on a terminal: a wire appears and follows.
      _Audio.play(_Sound.pickup);
      setState(() {
        s
          ..wiringSource = term
          ..wirePointer = _Cam.onPlane(pos, 0.5);
      });
      return;
    }
    final obj = _objectAt(pos);
    if (obj == null || !_canDrag(obj)) return;
    _Audio.play(_Sound.pickup);
    final p = _Cam.onPlane(pos, 0.5);
    final cur = _posOf(obj);
    _dragOffset = _V3(cur.x - p.x, 0, cur.z - p.z);
    setState(() => s.dragging = obj);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final s = _scene;
    _panLocal = d.localPosition;
    if (s.wiringSource != null && !s.wiringArmed) {
      s.wirePointer = _Cam.onPlane(d.localPosition, 0.5);
      return;
    }
    final obj = s.dragging;
    if (obj == null) return;
    final p = _Cam.onPlane(d.localPosition, 0.5);
    // Keep the object over the bench / tray area.
    final x = (p.x + _dragOffset.x).clamp(-13.0, 17.5);
    final z = (p.z + _dragOffset.z).clamp(-6.0, 6.5);
    switch (obj) {
      case _Comp.battery:
        s.batt = _V3(x, 0.1, z);
      case _Comp.lamp:
        s.lamp = _V3(x, 0.1, z);
      case _Item it:
        s.items[it] = _V3(x, 0.2, z);
    }
  }

  /// HTML `onPointerUp`.
  void _onPanEnd([DragEndDetails? _]) {
    final s = _scene;
    if (s.wiringSource != null && !s.wiringArmed) {
      final src = s.wiringSource!;
      final at = _panLocal;
      setState(() {
        s
          ..wiringSource = null
          ..wirePointer = null;
        final tgt = at == null ? null : _termAt(at);
        if (tgt != null) {
          _validateWiring(src, tgt);
        } else {
          _Audio.play(_Sound.wrong);
        }
      });
      return;
    }
    final obj = s.dragging;
    if (obj == null) return;
    setState(() {
      s.dragging = null;
      if (obj is _Comp) {
        _validatePlacement(obj);
      } else if (obj is _Item) {
        _dropItem(obj);
      }
    });
  }

  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    final pos = d.localPosition;
    final st = s.stepType;
    if (st == _StepType.wire || st == _StepType.wireGap) {
      final term = _termAt(pos);
      if (s.wiringArmed && s.wiringSource != null) {
        // Tap-tap wiring: second tap picks the other end.
        final src = s.wiringSource!;
        setState(() {
          s
            ..wiringSource = null
            ..wiringArmed = false;
          if (term == src) return;
          if (term != null) {
            _validateWiring(src, term);
          } else {
            _Audio.play(_Sound.wrong);
          }
        });
        return;
      }
      if (term != null && _canStartWire(term)) {
        _Audio.play(_Sound.pickup);
        setState(() {
          s
            ..wiringSource = term
            ..wiringArmed = true;
        });
      }
      return;
    }
    // "CLICK on the metal key to remove it" (scenario 2, step 1).
    final occ = s.gapOccupant;
    if (st == _StepType.remove && occ != null && _itemDistance(s, occ, pos) < 22) {
      _Audio.play(_Sound.click);
      setState(_removeGapObject);
    }
  }

  // ------------------------------------------------------------------ UI

  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.removeBtn)
        LabAction(
          label: _t('btn_remove'),
          icon: Icons.delete_outline,
          color: _Colors.slate100,
          foreground: _Colors.slate900,
          highlight: s.stepType == _StepType.remove,
          onTap: _onRemovePressed,
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
        return LabShell(
          controller: _lab,
          icon: Icons.electrical_services,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen0_opt'), _t('scen1_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step + 1,
          instruction: _scene.complete ? _t('scenario_conclusion') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('tester_title'),
          sidebarExtra: _testerStatus(p, s),
          onReset: _fullReset,
          showHud: false,
          overlays: [_hudOverlay(p, s)],
          stage: LabStage(
            designSize: _design,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: _onTapUp,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onPanCancel: _onPanEnd,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: _design,
                      painter: _BenchPainter(
                        scene: _scene,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        labels: (
                          cell: _t('lbl_cell'),
                          lamp: _t('lbl_lamp'),
                          key: _t('lbl_key'),
                          stick: _t('lbl_stick'),
                          tray: _t('lbl_tray'),
                          conductor: _t('badge_conductor'),
                          insulator: _t('badge_insulator'),
                          electron: _t('badge_electron'),
                        ),
                      ),
                    ),
                    _removeButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#remove-btn` (`.action-btn`) floating just below the gap.
  Widget _removeButton() {
    final g = _Cam.p(_gapCenter);
    final show = _scene.removeBtn && _scene.dragging == null;
    return Positioned(
      left: g.dx - 120,
      width: 240,
      top: g.dy + 64,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: Material(
              color: const Color(0xFFF1F5F9),
              elevation: 4,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _Audio.play(_Sound.click);
                  _onRemovePressed();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline, size: 17, color: _Colors.slate900),
                      const SizedBox(width: 6),
                      Text(
                        _t('btn_remove'),
                        style: const TextStyle(color: _Colors.slate900, fontSize: 14, fontWeight: FontWeight.w800),
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

  /// HTML `#bottom-hud`: "STEP n" chip + the short step hint. Hidden on
  /// observation / summary steps and once the scenario is complete.
  Widget _hudOverlay(LabPalette p, double s) {
    final st = _scene.stepType;
    final visible = st != null && st != _StepType.observe && st != _StepType.summary;
    if (!visible) return const SizedBox.shrink();
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final hud = _hud[_lab.lang.code]![_scene.scenario][_scene.step];
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: 8 + pad.bottom,
      child: LayoutBuilder(
        // Hidden while the canvas is too narrow (e.g. sidebar animating).
        builder: (context, box) => box.maxWidth < 150 * s
            ? const SizedBox.shrink()
            : Center(
                child: IgnorePointer(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 560 * s),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
                      decoration: BoxDecoration(
                        color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
                        borderRadius: BorderRadius.circular(18 * s),
                        border: Border.all(color: p.isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000)),
                        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 20, offset: Offset(0, 8))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 3 * s),
                            decoration: BoxDecoration(
                              color: _Colors.zslYellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${_t('step_str')} ${_scene.step + 1}',
                              style: TextStyle(
                                color: _Colors.zslYellow,
                                fontWeight: FontWeight.w800,
                                fontSize: 11 * s,
                              ),
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Flexible(
                            child: Text(
                              hud,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: p.textStrong,
                                fontWeight: FontWeight.w600,
                                fontSize: 12 * s,
                                height: 1.3,
                              ),
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

  /// Live state of the conduction tester (sidebar readout).
  Widget _testerStatus(LabPalette p, double s) {
    final sc = _scene;
    final f = s * _lab.fontScale;
    String yn(bool v) => v ? _t('yes') : _t('no');
    final wires = [sc.w1, sc.w2, sc.w3].where((w) => w).length;
    final occ = sc.gapOccupant;
    final circuit = !sc.circuitBuilt
        ? _t('circuit_none')
        : (sc.circuitClosed ? _t('circuit_closed') : _t('circuit_open'));
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
          LabInfoRow(palette: p, scale: f, label: _t('tester_cell'), value: yn(sc.battPlaced)),
          LabInfoRow(palette: p, scale: f, label: _t('tester_lamp'), value: yn(sc.lampPlaced)),
          LabInfoRow(palette: p, scale: f, label: _t('tester_wires'), value: '$wires / 3'),
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t('circuit'),
            value: circuit,
            valueColor: sc.circuitBuilt ? (sc.circuitClosed ? _Colors.green : _Colors.red) : null,
          ),
          Divider(color: p.cardBorder, height: 14 * s),
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t('tester_gap'),
            value: occ == null ? _t('gap_empty') : _t(occ == _Item.key ? 'lbl_key' : 'lbl_stick'),
          ),
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t('tester_bulb'),
            value: sc.circuitClosed ? _t('bulb_on') : _t('bulb_off'),
            valueColor: sc.circuitClosed ? _Colors.zslYellow : p.textMuted,
          ),
          if (sc.conductorBadge || sc.insulatorBadge) ...[
            SizedBox(height: 6 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
              decoration: BoxDecoration(
                color: sc.conductorBadge ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sc.conductorBadge ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              child: Text(
                (sc.conductorBadge ? _t('badge_conductor') : _t('badge_insulator')).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _Colors.slate900, fontWeight: FontWeight.w800, fontSize: 12 * f),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The HTML summary SVG (viewBox 24: indigo core 5..19, white sleeve 7..17).
class _WirePainter extends CustomPainter {
  _WirePainter({required this.core, required this.cover, required this.scale});

  final String core;
  final String cover;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG proportions: core x 5..19 (h 2), sleeve x 7..17 (h 4) of 24.
    final w = size.width, h = size.height;
    final cy = h * 0.5;
    final len = math.min(w * 0.86, h * 5);
    final x0 = (w - len) / 2;
    double x(double v) => x0 + (v - 5) / 14 * len;
    final th = math.min(h * 0.2, len / 14);
    final coreRect = Rect.fromLTRB(x(5), cy - th / 2, x(19), cy + th / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect, Radius.circular(th / 2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5B4FC), Color(0xFF6366F1), Color(0xFF4338CA)],
        ).createShader(coreRect),
    );
    final sleeve = Rect.fromLTRB(x(7), cy - th, x(17), cy + th);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sleeve, Radius.circular(th * 0.6)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFCBD5E1)],
        ).createShader(sleeve),
    );
    labText(
      canvas,
      core,
      Offset(coreRect.left, sleeve.bottom + 4 * scale),
      size: 10 * scale,
      color: const Color(0xFFA5B4FC),
      anchor: Alignment.topLeft,
      weight: FontWeight.w700,
    );
    labText(
      canvas,
      cover,
      Offset(sleeve.center.dx, sleeve.top - 5 * scale),
      size: 10 * scale,
      color: _Colors.slate200,
      anchor: Alignment.bottomCenter,
      weight: FontWeight.w700,
    );
  }

  @override
  bool shouldRepaint(covariant _WirePainter old) => old.core != core || old.cover != cover || old.scale != scale;
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Electrical Conductors & Insulators',
    'app_subtitle': 'Class 7 • Electricity: Circuits and their Components',
    'scen0_opt': 'Scenario 1: Testing a Conductor',
    'scen1_opt': 'Scenario 2: Testing an Insulator',
    'scenario_complete': 'Scenario Complete',
    'scenario_conclusion':
        'Scenario completed! You can now freely explore the lab by testing other materials on the workbench.',
    'observation_title': 'Observation',
    'badge_conductor': 'GOOD CONDUCTOR',
    'badge_insulator': 'POOR CONDUCTOR',
    'btn_remove': 'REMOVE',
    'badge_electron': 'ELECTRON FLOW',
    'lbl_tray': 'MATERIALS TRAY',
    'lbl_cell': 'Electric Cell',
    'lbl_lamp': 'Incandescent Lamp',
    'lbl_key': 'Metal Key',
    'lbl_stick': 'Wooden Stick',
    'err_connect': 'Incorrect connection.',
    'err_object': 'Incorrect object! Try again.',
    'step_str': 'STEP',
    'summary_str': 'Summary',
    // Theory (popup) parts. The HTML used <b>…</b> labels inside one string.
    'th_obs_label': 'Observation:',
    'th_expl_label': 'Explanation:',
    's0_obs': 'The bulb is glowing.',
    's0_expl':
        'This happens because the metal key is an electrical conductor. It allows electricity to flow through it, completing the circuit.',
    's1_obs': 'The bulb does not glow.',
    's1_expl':
        'This is because the wooden stick is an electrical insulator. It does not allow electricity to flow through it, so the circuit remains broken.',
    's1_summary':
        'Conductors complete the circuit and let the bulb glow. Insulators keep the circuit broken and the bulb stays off. This is why we use metals for wires (conductors) and cover them with plastic (insulators) for safety.',
    'wire_caption': 'Protected Electric Wire',
    'wire_core': 'Metal (conductor)',
    'wire_cover': 'Plastic (insulator)',
    'tester_title': 'Conduction Tester',
    'tester_cell': 'Cell placed',
    'tester_lamp': 'Lamp placed',
    'tester_wires': 'Wires connected',
    'tester_gap': 'In the gap',
    'tester_bulb': 'Bulb',
    'bulb_on': 'Glowing',
    'bulb_off': 'Off',
    'gap_empty': 'Empty',
    'yes': 'Yes',
    'no': 'No',
    'circuit': 'Circuit',
    'circuit_closed': 'Closed (complete)',
    'circuit_open': 'Open (broken)',
    'circuit_none': 'Not built',
  },
  'hi': {
    'app_title': 'विद्युत चालक और कुचालक',
    'app_subtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'scen0_opt': 'परिदृश्य 1: चालक का परीक्षण',
    'scen1_opt': 'परिदृश्य 2: कुचालक का परीक्षण',
    'scenario_complete': 'परिदृश्य पूर्ण',
    'scenario_conclusion':
        'परिदृश्य पूरा हुआ! अब आप कार्यक्षेत्र पर अन्य सामग्रियों का परीक्षण करके प्रयोगशाला में स्वतंत्र रूप से अन्वेषण कर सकते हैं।',
    'observation_title': 'अवलोकन',
    'badge_conductor': 'अच्छा चालक',
    'badge_insulator': 'खराब चालक (कुचालक)',
    'btn_remove': 'हटाएं',
    'badge_electron': 'इलेक्ट्रॉन प्रवाह',
    'lbl_tray': 'सामग्री ट्रे',
    'lbl_cell': 'विद्युत सेल',
    'lbl_lamp': 'तापदीप्त लैंप',
    'lbl_key': 'धातु की चाबी',
    'lbl_stick': 'लकड़ी की छड़ी',
    'err_connect': 'गलत कनेक्शन।',
    'err_object': 'गलत वस्तु! पुनः प्रयास करें।',
    'step_str': 'चरण',
    'summary_str': 'सारांश',
    'th_obs_label': 'अवलोकन:',
    'th_expl_label': 'स्पष्टीकरण:',
    's0_obs': 'बल्ब चमक रहा है।',
    's0_expl':
        'ऐसा इसलिए होता है क्योंकि धातु की चाबी एक विद्युत चालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति देती है, जिससे परिपथ पूरा हो जाता है।',
    's1_obs': 'बल्ब नहीं चमकता है।',
    's1_expl':
        'ऐसा इसलिए है क्योंकि लकड़ी की छड़ी एक विद्युत कुचालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति नहीं देती है, इसलिए परिपथ टूटा हुआ रहता है।',
    's1_summary':
        'चालक परिपथ को पूरा करते हैं और बल्ब को चमकने देते हैं। कुचालक परिपथ को टूटा हुआ रखते हैं और बल्ब बंद रहता है। यही कारण है कि हम सुरक्षा के लिए तारों (चालक) के लिए धातुओं का उपयोग करते हैं और उन्हें प्लास्टिक (कुचालक) से ढकते हैं।',
    'wire_caption': 'सुरक्षित विद्युत तार',
    'wire_core': 'धातु (चालक)',
    'wire_cover': 'प्लास्टिक (कुचालक)',
    'tester_title': 'चालन परीक्षक',
    'tester_cell': 'सेल रखा गया',
    'tester_lamp': 'लैंप रखा गया',
    'tester_wires': 'तार जुड़े',
    'tester_gap': 'गैप में',
    'tester_bulb': 'बल्ब',
    'bulb_on': 'चमक रहा है',
    'bulb_off': 'बंद',
    'gap_empty': 'खाली',
    'yes': 'हाँ',
    'no': 'नहीं',
    'circuit': 'परिपथ',
    'circuit_closed': 'बंद (पूर्ण)',
    'circuit_open': 'खुला (टूटा हुआ)',
    'circuit_none': 'नहीं बना',
  },
};

/// Step kinds of the HTML `LAB_DATA.scenarios[].steps[].type`.
enum _StepType { place, wire, wireGap, test, observe, remove, summary }

const List<List<_StepType>> _stepTypes = [
  [_StepType.place, _StepType.wire, _StepType.wireGap, _StepType.test, _StepType.observe],
  [_StepType.remove, _StepType.test, _StepType.observe, _StepType.summary],
];

/// HTML `targetObj` of each scenario's "test" step.
const List<_Item> _testTargets = [_Item.key, _Item.stick];

/// HTML `steps[].hud` (short text of the bottom HUD).
const Map<String, List<List<String>>> _hud = {
  'en': [
    [
      'DRAG cell and lamp to dotted zones.',
      'CLICK cell (+). DRAG to lamp terminal.',
      'CLICK cell (-). DRAG to left gap. CLICK lamp. DRAG to right gap.',
      'DRAG metal key into the gap.',
      'OBSERVE bulb glowing.',
    ],
    [
      "CLICK 'Remove' below the key.",
      'DRAG wooden stick into the gap.',
      'OBSERVE bulb is NOT glowing.',
      'Review learning outcomes.',
    ],
  ],
  'hi': [
    [
      'सेल और लैंप को बिंदीदार क्षेत्रों में खींचें।',
      'सेल (+) पर क्लिक करें। लैंप टर्मिनल तक खींचें।',
      'सेल (-) पर क्लिक करें। बाएँ गैप तक खींचें। लैंप पर क्लिक करें। दाएँ गैप तक खींचें।',
      'धातु की चाबी को गैप में खींचें।',
      'चमकते हुए बल्ब का अवलोकन करें।',
    ],
    [
      "चाबी के नीचे 'हटाएं' पर क्लिक करें।",
      'लकड़ी की छड़ी को गैप में खींचें।',
      'अवलोकन करें कि बल्ब नहीं चमक रहा है।',
      'सीखने के परिणामों की समीक्षा करें।',
    ],
  ],
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'To build a conduction tester and use it to identify a material that allows electricity to flow.',
      steps: [
        LabStep(
          concept: '',
          action:
              'DRAG the electric cell from the component tray and DROP it onto the workbench. DRAG the incandescent lamp (in its holder) and DROP it next to the cell.',
          observation: 'DRAG cell and lamp to dotted zones.',
        ),
        LabStep(
          concept: '',
          action:
              'CLICK on the positive (+) terminal of the cell. A wire will appear. DRAG the other end of this wire and CONNECT it to one of the terminals on the lamp holder.',
          observation: 'CLICK cell (+). DRAG to lamp terminal.',
        ),
        LabStep(
          concept: '',
          action:
              'CLICK on the negative (-) terminal of the cell. DRAG the new wire and DROP its free end to the left side of the testing area. CLICK on the other terminal of the lamp holder. DRAG the new wire and DROP its free end to the right side of the testing area, leaving a gap between the two wire ends.',
          observation: 'CLICK cell (-). DRAG to left gap. CLICK lamp. DRAG to right gap.',
        ),
        LabStep(
          concept: '',
          action:
              "From the 'Test Objects' tray, DRAG the metal key and DROP it into the gap, so it touches both free ends of the wires.",
          observation: 'DRAG metal key into the gap.',
        ),
        LabStep(
          concept: '',
          action:
              'OBSERVE that the bulb is glowing. This happens because the metal key is an electrical conductor. It allows electricity to flow through it, completing the circuit.',
          observation:
              'Observation: The bulb is glowing. Explanation: This happens because the metal key is an electrical conductor. It allows electricity to flow through it, completing the circuit.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To use the conduction tester to identify a material that blocks the flow of electricity.',
      steps: [
        LabStep(
          concept: '',
          action:
              'The conduction tester circuit is already set up from the previous scenario. CLICK on the metal key to remove it from the testing area and place it back in the tray.',
          observation: "CLICK 'Remove' below the key.",
        ),
        LabStep(
          concept: '',
          action:
              "From the 'Test Objects' tray, DRAG the wooden stick and DROP it into the gap, so it touches both free ends of the wires.",
          observation: 'DRAG wooden stick into the gap.',
        ),
        LabStep(
          concept: '',
          action:
              'OBSERVE that the bulb does not glow. This is because the wooden stick is an electrical insulator. It does not allow electricity to flow through it, so the circuit remains broken.',
          observation:
              'Observation: The bulb does not glow. Explanation: This is because the wooden stick is an electrical insulator. It does not allow electricity to flow through it, so the circuit remains broken.',
        ),
        LabStep(
          concept: '',
          action:
              'You have now learned the difference! Conductors complete the circuit and let the bulb glow. Insulators keep the circuit broken and the bulb stays off. This is why we use metals for wires (conductors) and cover them with plastic (insulators) for safety.',
          observation:
              'Summary: Conductors complete the circuit and let the bulb glow. Insulators keep the circuit broken and the bulb stays off. This is why we use metals for wires (conductors) and cover them with plastic (insulators) for safety.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'एक चालन परीक्षक का निर्माण करना और उसका उपयोग उस सामग्री की पहचान करने के लिए करना जो विद्युत प्रवाह की अनुमति देती है।',
      steps: [
        LabStep(
          concept: '',
          action:
              'घटक ट्रे से विद्युत सेल को खींचें (DRAG) और उसे कार्यक्षेत्र पर छोड़ें (DROP)। तापदीप्त लैंप (उसके धारक में) को खींचें और उसे सेल के बगल में छोड़ें।',
          observation: 'सेल और लैंप को बिंदीदार क्षेत्रों में खींचें।',
        ),
        LabStep(
          concept: '',
          action:
              'सेल के धनात्मक (+) टर्मिनल पर क्लिक (CLICK) करें। एक तार दिखाई देगा। इस तार के दूसरे सिरे को खींचें (DRAG) और इसे लैंप होल्डर के टर्मिनलों में से किसी एक से जोड़ें (CONNECT)।',
          observation: 'सेल (+) पर क्लिक करें। लैंप टर्मिनल तक खींचें।',
        ),
        LabStep(
          concept: '',
          action:
              'सेल के ऋणात्मक (-) टर्मिनल पर क्लिक करें। नए तार को खींचें और इसके मुक्त सिरे को परीक्षण क्षेत्र के बाईं ओर छोड़ें। लैंप होल्डर के दूसरे टर्मिनल पर क्लिक करें। नए तार को खींचें और इसके मुक्त सिरे को परीक्षण क्षेत्र के दाईं ओर छोड़ें, जिससे दोनों तारों के सिरों के बीच एक गैप (खाली स्थान) रह जाए।',
          observation: 'सेल (-) पर क्लिक करें। बाएँ गैप तक खींचें। लैंप पर क्लिक करें। दाएँ गैप तक खींचें।',
        ),
        LabStep(
          concept: '',
          action:
              "'परीक्षण वस्तु' ट्रे से, धातु की चाबी को खींचें और इसे गैप में छोड़ें, ताकि यह तारों के दोनों मुक्त सिरों को छुए।",
          observation: 'धातु की चाबी को गैप में खींचें।',
        ),
        LabStep(
          concept: '',
          action:
              'अवलोकन करें (OBSERVE) कि बल्ब चमक रहा है। ऐसा इसलिए होता है क्योंकि धातु की चाबी एक विद्युत चालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति देती है, जिससे परिपथ पूरा हो जाता है।',
          observation:
              'अवलोकन: बल्ब चमक रहा है। स्पष्टीकरण: ऐसा इसलिए होता है क्योंकि धातु की चाबी एक विद्युत चालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति देती है, जिससे परिपथ पूरा हो जाता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'विद्युत प्रवाह को रोकने वाली सामग्री की पहचान करने के लिए चालन परीक्षक का उपयोग करना।',
      steps: [
        LabStep(
          concept: '',
          action:
              'चालन परीक्षक परिपथ पिछले परिदृश्य से पहले ही स्थापित है। धातु की चाबी को परीक्षण क्षेत्र से हटाने के लिए उस पर क्लिक करें और उसे वापस ट्रे में रख दें।',
          observation: "चाबी के नीचे 'हटाएं' पर क्लिक करें।",
        ),
        LabStep(
          concept: '',
          action:
              "'परीक्षण वस्तु' ट्रे से, लकड़ी की छड़ी को खींचें और इसे गैप में छोड़ें, ताकि यह तारों के दोनों मुक्त सिरों को छुए।",
          observation: 'लकड़ी की छड़ी को गैप में खींचें।',
        ),
        LabStep(
          concept: '',
          action:
              'अवलोकन करें कि बल्ब नहीं चमकता है। ऐसा इसलिए है क्योंकि लकड़ी की छड़ी एक विद्युत कुचालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति नहीं देती है, इसलिए परिपथ टूटा हुआ रहता है।',
          observation:
              'अवलोकन: बल्ब नहीं चमकता है। स्पष्टीकरण: ऐसा इसलिए है क्योंकि लकड़ी की छड़ी एक विद्युत कुचालक है। यह अपने माध्यम से विद्युत प्रवाह की अनुमति नहीं देती है, इसलिए परिपथ टूटा हुआ रहता है।',
        ),
        LabStep(
          concept: '',
          action:
              'अब आपने अंतर जान लिया है! चालक परिपथ को पूरा करते हैं और बल्ब को चमकने देते हैं। कुचालक परिपथ को टूटा हुआ रखते हैं और बल्ब बंद रहता है। यही कारण है कि हम सुरक्षा के लिए तारों (चालक) के लिए धातुओं का उपयोग करते हैं और उन्हें प्लास्टिक (कुचालक) से ढकते हैं।',
          observation:
              'सारांश: चालक परिपथ को पूरा करते हैं और बल्ब को चमकने देते हैं। कुचालक परिपथ को टूटा हुआ रखते हैं और बल्ब बंद रहता है। यही कारण है कि हम सुरक्षा के लिए तारों (चालक) के लिए धातुओं का उपयोग करते हैं और उन्हें प्लास्टिक (कुचालक) से ढकते हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY

/// Design size of the stage.
const Size _design = Size(1000, 500);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);

  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 withY(double ny) => _V3(x, ny, z);

  static _V3 lerp(_V3 a, _V3 b, double t) => _V3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
}

/// Fixed perspective camera standing in for the HTML PerspectiveCamera
/// (40° FOV looking down at the workbench). It is slightly higher and
/// re-centred so the bench, tray and testing gap fill the design area.
class _Cam {
  _Cam._();

  static const double _el = 42 * math.pi / 180;
  static const double _dist = 26;
  static const _V3 target = _V3(4.2, 0, 0.4);
  static final _V3 eye = _V3(target.x, _dist * math.sin(_el), target.z + _dist * math.cos(_el));
  static final _V3 _f = _V3(0, -math.sin(_el), -math.cos(_el));
  static final _V3 _u = _V3(0, math.cos(_el), -math.sin(_el));
  static final double focal = (_design.height / 2) / math.tan(20 * math.pi / 180);
  static const Offset _c = Offset(500, 238);

  static double _depth(_V3 v) => (v - eye).dot(_f);

  /// Projects a world point to design coordinates.
  static Offset p(_V3 v) {
    final d = v - eye;
    final depth = d.dot(_f);
    return Offset(_c.dx + d.x / depth * focal, _c.dy - d.dot(_u) / depth * focal);
  }

  /// Design pixels per world unit at [v].
  static double k(_V3 v) => focal / _depth(v);

  /// Ellipse ratio (minor / major) of a horizontal circle at [v].
  static double tilt(_V3 v) {
    final a = p(v + const _V3(0, 0, 1)), b = p(v - const _V3(0, 0, 1));
    return ((a.dy - b.dy).abs() / 2 / k(v)).clamp(0.2, 1.0);
  }

  /// Intersection of the view ray through design point [s] with the
  /// horizontal plane at height [y] (the HTML invisible drag plane).
  static _V3 onPlane(Offset s, double y) {
    final a = (s.dx - _c.dx) / focal;
    final b = -(s.dy - _c.dy) / focal;
    final dir = _f + const _V3(1, 0, 0) * a + _u * b;
    final t = (y - eye.y) / dir.y;
    return eye + dir * t;
  }
}

// ============================================================ MODEL

enum _Item { key, stick }

enum _Comp { battery, lamp }

enum _Term { battPos, battNeg, lampIn, lampOut, gapLeft, gapRight }

// Tray homes (the HTML tray at x = 14; items re-spaced so they do not
// overlap each other) and the workbench targets.
const _V3 _battHome = _V3(14, 0.1, 0.55);
const _V3 _lampHome = _V3(14, 0.1, -3.1);
const _V3 _keyHome = _V3(14.3, 0.2, 3.3);
const _V3 _stickHome = _V3(14, 0.2, 4.35);
const _V3 _battZone = _V3(-6, 0.05, 0);
const _V3 _lampZone = _V3(2, 0.05, 0);
const _V3 _gapCenter = _V3(0, 0.2, 3);
const _V3 _gapLeft = _V3(-2, 0.2, 3);
const _V3 _gapRight = _V3(2, 0.2, 3);

/// Mutable scene state read by the painter every frame.
class _Scene {
  int scenario = 0;

  /// 0-based like the HTML `currentStep` (== steps.length when complete).
  int step = 0;
  bool complete = false;

  _V3 batt = _battHome;
  _V3 lamp = _lampHome;
  bool battPlaced = false;
  bool lampPlaced = false;
  final Map<_Item, _V3> items = {_Item.key: _keyHome, _Item.stick: _stickHome};

  bool w1 = false, w2 = false, w3 = false;
  bool circuitBuilt = false;
  bool circuitClosed = false;
  bool showBlocked = false;
  _Item? gapOccupant;

  bool conductorBadge = false;
  bool insulatorBadge = false;
  bool removeBtn = false;

  // Interaction.
  _Term? wiringSource;
  bool wiringArmed = false;
  _V3? wirePointer;
  Object? dragging; // _Comp or _Item

  // Animation.
  double time = 0;
  double glow = 0;
  double conductorA = 0, insulatorA = 0, electronA = 0;
  /// Shared progress of the 40 electrons (HTML `userData.progress`, which
  /// all advance at 0.5 loop / s). Electron i sits at `i / 40 + flowPhase`.
  double flowPhase = 0;
  List<_V3> electronPath = const [];
  List<double> electronCum = const [];

  _StepType? get stepType {
    final types = _stepTypes[scenario];
    if (complete || step >= types.length) return null;
    return types[step];
  }

  _V3 term(_Term t) => switch (t) {
    _Term.battPos => batt + const _V3(2.2, 0.5, 0),
    _Term.battNeg => batt + const _V3(-2.2, 0.5, 0),
    _Term.lampIn => lamp + const _V3(-1.2, 0.4, 0),
    _Term.lampOut => lamp + const _V3(1.2, 0.4, 0),
    _Term.gapLeft => _gapLeft,
    _Term.gapRight => _gapRight,
  };

  _V3 itemHome(_Item it) => it == _Item.key ? _keyHome : _stickHome;

  /// Midpoint used by the HTML `updateWireCurve` for each wire.
  static _V3 wireMid(int wire, _V3 a, _V3 b) {
    final m = _V3.lerp(a, b, 0.5);
    final y = math.max(a.y, b.y) + 0.5;
    return switch (wire) {
      1 => _V3(m.x, y, m.z - 3.0),
      2 => _V3(m.x - 3.0, y, m.z + 1.0),
      _ => _V3(m.x + 3.0, y, m.z + 1.0),
    };
  }

  /// End points of wire 1..3 (HTML w1: cell + to lamp, w2: cell - to the
  /// left gap end, w3: lamp to the right gap end).
  (_V3, _V3) wireEnds(int wire) => switch (wire) {
    1 => (term(_Term.battPos), term(_Term.lampIn)),
    2 => (term(_Term.battNeg), _gapLeft),
    _ => (term(_Term.lampOut), _gapRight),
  };

  /// HTML `buildElectronCurve()`: the closed loop the electrons follow.
  void buildElectronPath() {
    final bP = term(_Term.battPos), bN = term(_Term.battNeg);
    final l1 = term(_Term.lampIn), l2 = term(_Term.lampOut);
    final lampMid = _V3(lamp.x, 2.0, lamp.z);
    final pts = <_V3>[
      ..._catmull(bP, wireMid(1, bP, l1), l1, 24),
      lampMid,
      l2,
      ..._catmull(l2, wireMid(3, l2, _gapRight), _gapRight, 24).skip(1),
      _gapCenter,
      _gapLeft,
      ..._catmull(_gapLeft, wireMid(2, bN, _gapLeft), bN, 24).skip(1),
      bP,
    ];
    final cum = <double>[0];
    for (var i = 1; i < pts.length; i++) {
      cum.add(cum.last + (pts[i] - pts[i - 1]).length);
    }
    electronPath = pts;
    electronCum = cum;
  }

  /// Point at arc-length fraction [u] of the electron loop.
  _V3 electronAt(double u) {
    final path = electronPath;
    if (path.length < 2) return _gapCenter;
    final total = electronCum.last;
    final d = (u.clamp(0.0, 1.0)) * total;
    var i = 1;
    while (i < electronCum.length - 1 && electronCum[i] < d) {
      i++;
    }
    final seg = electronCum[i] - electronCum[i - 1];
    final t = seg <= 0 ? 0.0 : (d - electronCum[i - 1]) / seg;
    return _V3.lerp(path[i - 1], path[i], t);
  }
}

/// Points of a Catmull-Rom curve through [a], [m], [b] (HTML
/// `CatmullRomCurve3([pt1, mid, pt2])` with mirrored end tangents).
List<_V3> _catmull(_V3 a, _V3 m, _V3 b, int samples) {
  final p0 = a * 2 - m;
  final p3 = b * 2 - m;
  _V3 seg(_V3 q0, _V3 q1, _V3 q2, _V3 q3, double t) {
    final t2 = t * t, t3 = t2 * t;
    return (q1 * 2 + (q2 - q0) * t + (q0 * 2 - q1 * 5 + q2 * 4 - q3) * t2 + (q1 * 3 - q0 - q2 * 3 + q3) * t3) * 0.5;
  }

  final out = <_V3>[];
  final half = samples ~/ 2;
  for (var i = 0; i <= half; i++) {
    out.add(seg(p0, a, m, b, i / half));
  }
  for (var i = 1; i <= half; i++) {
    out.add(seg(a, m, b, p3, i / half));
  }
  return out;
}

/// Screen-space bounds of an object's 3D box (used for hit testing).
Rect _projectBox(_V3 o, _V3 min, _V3 max, {double inflate = 4}) {
  var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
  for (final x in [min.x, max.x]) {
    for (final y in [min.y, max.y]) {
      for (final z in [min.z, max.z]) {
        final p = _Cam.p(o + _V3(x, y, z));
        l = math.min(l, p.dx);
        r = math.max(r, p.dx);
        t = math.min(t, p.dy);
        b = math.max(b, p.dy);
      }
    }
  }
  final rect = Rect.fromLTRB(l, t, r, b).inflate(inflate);
  return rect;
}

/// Hit test of the cell / lamp: the cell's box, or the lamp's holder and
/// bulb silhouette (so the lamp no longer hides what is behind its glass).
bool _compHit(_Scene s, _Comp c, Offset pos) {
  if (c == _Comp.battery) {
    return _projectBox(s.batt, const _V3(-2.45, 0, -1.5), const _V3(2.45, 1.7, 1.5)).contains(pos);
  }
  final base = _projectBox(s.lamp, const _V3(-1.3, 0, -1.0), const _V3(1.3, 1.4, 1.0));
  return base.contains(pos) || _bulbOutline(s.lamp).contains(pos);
}

/// Radius of the HTML bulb lathe profile at height [y] (0..3.5).
double _bulbRadius(double y) {
  if (y < 1.0) return 0.7;
  if (y < 2.0) {
    final t2 = y - 1.0;
    return 0.7 + t2 * t2 * 1.1;
  }
  final t3 = (y - 2.0) / 1.5;
  return 1.8 * math.cos(t3 * math.pi / 2);
}

/// Projected rings of the bulb lathe (centre, half width, half height).
List<(Offset, double, double)> _bulbRings(_V3 o) => [
  for (var i = 0; i <= 30; i++)
    () {
      final y = i * (3.5 / 30);
      final at = o + _V3(0, y + 1.2, 0);
      final a = _bulbRadius(y) * _Cam.k(at);
      return (_Cam.p(at), a, a * _Cam.tilt(at));
    }(),
];

/// Silhouette of the HTML bulb (LatheGeometry) at lamp origin [o]: the
/// union of its projected horizontal rings, so the globe reads as round
/// from the elevated camera.
Path _bulbOutline(_V3 o) {
  final rings = _bulbRings(o).where((r) => r.$2 > 0.01).toList();
  var minX = double.infinity, maxX = -double.infinity;
  for (final r in rings) {
    minX = math.min(minX, r.$1.dx - r.$2);
    maxX = math.max(maxX, r.$1.dx + r.$2);
  }
  const n = 48;
  final top = <Offset>[], bottom = <Offset>[];
  for (var j = 0; j <= n; j++) {
    final x = minX + (maxX - minX) * j / n;
    var t = double.infinity, b = -double.infinity;
    for (final r in rings) {
      final dx = (x - r.$1.dx) / r.$2;
      if (dx.abs() > 1.0001) continue;
      final h = r.$3 * math.sqrt(math.max(0.0, 1 - dx * dx));
      t = math.min(t, r.$1.dy - h);
      b = math.max(b, r.$1.dy + h);
    }
    if (t.isFinite) {
      top.add(Offset(x, t));
      bottom.add(Offset(x, b));
    }
  }
  final path = Path()..moveTo(top.first.dx, top.first.dy);
  for (final p in top.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  for (final p in bottom.reversed) {
    path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// Screen distance from [pos] to the axis of a test object (0 on it).
double _itemDistance(_Scene s, _Item it, Offset pos) {
  final o = s.items[it]!;
  final a = _Cam.p(o + _V3(it == _Item.key ? -2.65 : -2.5, 0, 0));
  final b = _Cam.p(o + const _V3(2.5, 0, 0));
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  final t = len2 == 0 ? 0.0 : (((pos - a).dx * ab.dx + (pos - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (pos - (a + ab * t)).distance;
}

// ============================================================ PRIMITIVES

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

/// Projected axis-aligned box: top, front (+z) and the side facing the
/// camera. [faces] limits what is drawn ('t' top, 'f' front, 's' side).
void _box(Canvas c, _V3 min, _V3 max, Color color, {double opacity = 1, String faces = 'tfs', bool edges = true}) {
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  Offset p(double x, double y, double z) => _Cam.p(_V3(x, y, z));
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..color = a(labShade(color, -0.5).withValues(alpha: 0.55));
  if (faces.contains('s')) {
    final side = _Cam.eye.x > max.x
        ? [p(max.x, min.y, max.z), p(max.x, min.y, min.z), p(max.x, max.y, min.z), p(max.x, max.y, max.z)]
        : (_Cam.eye.x < min.x
              ? [p(min.x, min.y, max.z), p(min.x, min.y, min.z), p(min.x, max.y, min.z), p(min.x, max.y, max.z)]
              : null);
    if (side != null) {
      final path = _poly(side);
      c.drawPath(path, Paint()..color = a(labShade(color, -0.32)));
      if (edges) c.drawPath(path, edge);
    }
  }
  if (faces.contains('t')) {
    final top = _poly([p(min.x, max.y, min.z), p(max.x, max.y, min.z), p(max.x, max.y, max.z), p(min.x, max.y, max.z)]);
    c.drawPath(top, Paint()..color = a(labShade(color, 0.14)));
    if (edges) c.drawPath(top, edge);
  }
  if (faces.contains('f')) {
    final pts = [p(min.x, max.y, max.z), p(max.x, max.y, max.z), p(max.x, min.y, max.z), p(min.x, min.y, max.z)];
    final front = _poly(pts);
    c.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a(labShade(color, -0.04)), a(labShade(color, -0.22))],
        ).createShader(front.getBounds()),
    );
    if (edges) c.drawPath(front, edge);
  }
}

/// Upright (truncated) cone / cylinder standing on [base] (CylinderGeometry).
void _frustum(
  Canvas c,
  _V3 base,
  double h,
  double rBottom,
  double rTop,
  Color color, {
  double opacity = 1,
  bool metal = false,
  bool drawTop = true,
}) {
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final top = base + _V3(0, h, 0);
  final pb = _Cam.p(base), pt = _Cam.p(top);
  final kb = _Cam.k(base), kt = _Cam.k(top);
  final rb = rBottom * kb, rt = rTop * kt;
  final eb = rb * _Cam.tilt(base), et = rt * _Cam.tilt(top);
  final body = Path()
    ..moveTo(pt.dx - rt, pt.dy)
    ..lineTo(pb.dx - rb, pb.dy)
    ..arcTo(Rect.fromCenter(center: pb, width: rb * 2, height: eb * 2), math.pi, -math.pi, false)
    ..lineTo(pt.dx + rt, pt.dy)
    ..arcTo(Rect.fromCenter(center: pt, width: rt * 2, height: et * 2), 0, math.pi, false)
    ..close();
  final bounds = body.getBounds();
  c.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(
        colors: metal
            ? [
                a(labShade(color, -0.45)),
                a(labShade(color, 0.55)),
                a(color),
                a(labShade(color, -0.35)),
                a(labShade(color, 0.2)),
              ]
            : [a(labShade(color, -0.3)), a(labShade(color, 0.22)), a(color), a(labShade(color, -0.4))],
        stops: metal ? const [0, 0.28, 0.5, 0.8, 1] : const [0, 0.3, 0.6, 1],
      ).createShader(bounds),
  );
  if (drawTop) {
    c.drawOval(Rect.fromCenter(center: pt, width: rt * 2, height: et * 2), Paint()..color = a(labShade(color, 0.28)));
  }
}

/// Cylinder lying along the x axis from [from] to [to] (radius [r]).
void _hCyl(
  Canvas c,
  _V3 from,
  _V3 to,
  double r,
  Color color, {
  double opacity = 1,
  bool metal = false,
  bool capFrom = true,
  bool capTo = true,
}) {
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final pa = _Cam.p(from), pb = _Cam.p(to);
  final ra = r * _Cam.k(from), rb = r * _Cam.k(to);
  final body = _poly([pa.translate(0, -ra), pb.translate(0, -rb), pb.translate(0, rb), pa.translate(0, ra)]);
  final mid = Offset((pa.dx + pb.dx) / 2, (pa.dy + pb.dy) / 2);
  final rm = (ra + rb) / 2;
  final shader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: metal
        ? [a(labShade(color, 0.15)), a(labShade(color, 0.6)), a(color), a(labShade(color, -0.45))]
        : [a(labShade(color, 0.05)), a(labShade(color, 0.32)), a(color), a(labShade(color, -0.42))],
    stops: const [0, 0.3, 0.55, 1],
  ).createShader(Rect.fromCenter(center: mid, width: 10, height: rm * 2));
  c.drawPath(body, Paint()..shader = shader);
  // Visible end caps (only the face turned towards the camera).
  void cap(_V3 at, Offset p, double rr) {
    final dx = (_Cam.eye.x - at.x).abs() / (_Cam.eye - at).length;
    final w = (rr * 2 * dx).clamp(1.0, rr * 2);
    c.drawOval(Rect.fromCenter(center: p, width: w, height: rr * 2), Paint()..color = a(labShade(color, 0.12)));
    c.drawOval(
      Rect.fromCenter(center: p, width: w, height: rr * 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = a(labShade(color, -0.45)),
    );
  }

  if (capTo && to.x < _Cam.eye.x) cap(to, pb, rb);
  if (capFrom && from.x > _Cam.eye.x) cap(from, pa, ra);
}

/// Small glossy terminal sphere (HTML `createTerminal`, radius 0.25).
void _terminal(Canvas c, _V3 at, Color color, {double opacity = 1}) {
  final p = _Cam.p(at);
  final r = 0.3 * _Cam.k(at);
  labGroundShadow(c, p.translate(1, r * 0.7), r * 2.2, r * 0.8, opacity: 0.35 * opacity);
  labSphere(c, p, r, color, opacity: opacity, highlight: 0.55, outline: true);
  if (color.computeLuminance() < 0.05) {
    c.drawCircle(
      p,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.35 * opacity),
    );
  }
}

/// Insulated tube wire along [pts] (HTML TubeGeometry radius 0.12).
void _wire(Canvas c, List<_V3> pts, Color color) {
  if (pts.length < 2) return;
  final path = Path();
  final first = _Cam.p(pts.first);
  path.moveTo(first.dx, first.dy);
  var k = 0.0;
  for (final v in pts.skip(1)) {
    final p = _Cam.p(v);
    path.lineTo(p.dx, p.dy);
  }
  for (final v in pts) {
    k += _Cam.k(v);
  }
  final w = 0.26 * k / pts.length;
  Paint stroke(Color col, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = width
    ..color = col;
  c.drawPath(
    path.shift(const Offset(2, 5)),
    stroke(Colors.black.withValues(alpha: 0.18), w)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  c.drawPath(path, stroke(labShade(color, -0.45), w + 1.6));
  c.drawPath(path, stroke(color, w));
  final hi = color.computeLuminance() < 0.05 ? 0.35 : 0.45;
  c.drawPath(path.shift(Offset(0, -w * 0.22)), stroke(labShade(color, hi).withValues(alpha: 0.75), w * 0.28));
}

// ============================================================ PAINTER

typedef _BenchLabels = ({
  String cell,
  String lamp,
  String key,
  String stick,
  String tray,
  String conductor,
  String insulator,
  String electron,
});

class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final _BenchLabels labels;

  static const Color _wood = Color(0xFF8B5A2B);
  static const Color _holder = Color(0xFF1F2937);
  static const Color _metal = Color(0xFFD1D5DB);
  static const Color _metalDark = Color(0xFF475569);
  static const Color _stickWood = Color(0xFFD97706);
  static const Color _trayColor = Color(0xFF94A3B8);
  static const Color _red = Color(0xFFEF4444);
  static const Color _black = Color(0xFF111111);
  static const Color _yellow = Color(0xFFEAB308);
  static const Color _blue = Color(0xFF3B82F6);

  double get _t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    _background(canvas, size);
    _board(canvas);
    _tray(canvas);
    _zones(canvas);
    _lightPool(canvas);
    _gapArea(canvas);

    _terminal(canvas, _gapLeft, _yellow);
    _terminal(canvas, _gapRight, _yellow);
    if (scene.w1) _drawWire(canvas, 1, _red);
    if (scene.w2) _drawWire(canvas, 2, _black);
    if (scene.w3) _drawWire(canvas, 3, _yellow);
    _electrons(canvas);

    // Objects back to front (painter's algorithm); the dragged one last.
    final objs = <(double, Object)>[
      (scene.batt.z, _Comp.battery),
      (scene.lamp.z, _Comp.lamp),
      (scene.items[_Item.key]!.z, _Item.key),
      (scene.items[_Item.stick]!.z, _Item.stick),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final o in objs) {
      if (o.$2 != scene.dragging) _drawObject(canvas, o.$2);
    }
    if (scene.dragging != null) _drawObject(canvas, scene.dragging!);

    _hintRing(canvas);
    _tempWire(canvas);
    if (showLabels) _labels(canvas);
    _badges(canvas);
  }

  void _drawObject(Canvas c, Object o) {
    switch (o) {
      case _Comp.battery:
        _battery(c, scene.batt);
      case _Comp.lamp:
        _lamp(c, scene.lamp);
      case _Item.key:
        _key(c, scene.items[_Item.key]!);
      case _Item.stick:
        _stick(c, scene.items[_Item.stick]!);
    }
  }

  // ------------------------------------------------------- environment

  void _background(Canvas c, Size size) {
    final colors = isDark ? const [Color(0xFF83B6B1), Color(0xFF5D8885)] : const [Color(0xFFA1D1CC), Color(0xFF76A09E)];
    c.drawRect(
      labBleed(size),
      Paint()
        ..shader = RadialGradient(
          colors: colors,
          radius: 0.75,
        ).createShader(Rect.fromCircle(center: const Offset(500, 270), radius: 560)),
    );
  }

  void _board(Canvas c) {
    const min = _V3(-14, -0.4, -6), max = _V3(8, 0, 6);
    // Soft shadow below the bench.
    final s0 = _Cam.p(const _V3(-14, -0.4, 6.3)), s1 = _Cam.p(const _V3(8, -0.4, 6.3));
    c.drawRect(
      Rect.fromLTRB(s0.dx, s0.dy - 2, s1.dx, s0.dy + 14),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    _box(c, min, max, _wood, faces: 'f', edges: false);
    final top = _poly([
      _Cam.p(const _V3(-14, 0, -6)),
      _Cam.p(const _V3(8, 0, -6)),
      _Cam.p(const _V3(8, 0, 6)),
      _Cam.p(const _V3(-14, 0, 6)),
    ]);
    final b = top.getBounds();
    c.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_wood, -0.08), labShade(_wood, 0.1), labShade(_wood, 0.02)],
        ).createShader(b),
    );
    // Wood grain.
    c.save();
    c.clipPath(top);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = labShade(_wood, -0.35).withValues(alpha: 0.28);
    for (var z = -5.8; z < 6; z += 0.62) {
      final path = Path();
      for (var x = -14.0; x <= 8.0; x += 0.5) {
        final p = _Cam.p(_V3(x, 0, z + 0.09 * math.sin(x * 0.55 + z * 2.3) + 0.05 * math.sin(x * 1.7)));
        if (x == -14.0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      c.drawPath(path, grain);
    }
    c.restore();
    c.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(_wood, 0.25).withValues(alpha: 0.6),
    );
  }

  void _tray(Canvas c) {
    // Base (HTML trayBase 6 x 0.2 x 10 at x = 14) with a low rim.
    _box(c, const _V3(11, -0.2, -5), const _V3(17, 0, 5), _trayColor);
    const rim = Color(0xFF8391A6);
    _box(c, const _V3(11, 0, -5), const _V3(17, 0.3, -4.86), rim);
    _box(c, const _V3(11, 0, -5), const _V3(11.14, 0.3, 5), rim);
    _box(c, const _V3(16.86, 0, -5), const _V3(17, 0.3, 5), rim);
    // Dividers (HTML tDiv) between cell, lamp and test objects.
    _box(c, const _V3(11.14, 0, -1.36), const _V3(16.86, 0.3, -1.26), rim);
    _box(c, const _V3(11.14, 0, 2.5), const _V3(16.86, 0.3, 2.6), rim);
    _box(c, const _V3(11, 0, 4.86), const _V3(17, 0.3, 5), rim);
  }

  /// Dashed blue drop zones (HTML dropZoneBatt / dropZoneLamp).
  void _zones(Canvas c) {
    void zone(_V3 center, double w, double d, bool active) {
      final pts = [
        _Cam.p(center + _V3(-w / 2, 0, -d / 2)),
        _Cam.p(center + _V3(w / 2, 0, -d / 2)),
        _Cam.p(center + _V3(w / 2, 0, d / 2)),
        _Cam.p(center + _V3(-w / 2, 0, d / 2)),
      ];
      final path = _poly(pts);
      final pulse = 0.5 + 0.5 * math.sin(_t * 4);
      final color = active ? const Color(0xFF22C55E) : _blue;
      c.drawPath(path, Paint()..color = color.withValues(alpha: 0.08 + 0.08 * pulse + (active ? 0.12 : 0)));
      labDashedPath(
        c,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = color,
        dash: 12,
        gap: 6,
        phase: -_t * 12,
      );
    }

    final drag = scene.dragging;
    if (!scene.battPlaced) {
      zone(_battZone, 5, 4, drag == _Comp.battery && math.sqrt(_dist2(scene.batt, _battZone)) < 6);
    }
    if (!scene.lampPlaced) {
      zone(_lampZone, 4.5, 4.5, drag == _Comp.lamp && math.sqrt(_dist2(scene.lamp, _lampZone)) < 6);
    }
  }

  static double _dist2(_V3 a, _V3 b) => (a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z);

  /// Warm light spilled by the glowing bulb (HTML PointLight, distance 20).
  void _lightPool(Canvas c) {
    if (scene.glow <= 0.01) return;
    final base = scene.lamp.withY(0);
    final p = _Cam.p(base);
    final r = 7 * _Cam.k(base);
    c.save();
    c.translate(p.dx, p.dy);
    c.scale(1, _Cam.tilt(base));
    c.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3C4).withValues(alpha: 0.42 * scene.glow),
            const Color(0xFFFFE08A).withValues(alpha: 0.16 * scene.glow),
            const Color(0x00FFE08A),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );
    c.restore();
  }

  /// Highlights the testing gap while a test object is being dragged.
  void _gapArea(Canvas c) {
    final it = scene.dragging;
    if (it is! _Item) return;
    final pos = scene.items[it]!;
    final near = math.sqrt(_dist2(pos, _gapCenter)) < 5.0;
    final color = near ? const Color(0xFF22C55E) : _yellow;
    final path = _poly([
      _Cam.p(const _V3(-2.7, 0.02, 2.2)),
      _Cam.p(const _V3(2.7, 0.02, 2.2)),
      _Cam.p(const _V3(2.7, 0.02, 3.8)),
      _Cam.p(const _V3(-2.7, 0.02, 3.8)),
    ]);
    final pulse = 0.5 + 0.5 * math.sin(_t * 6);
    c.drawPath(path, Paint()..color = color.withValues(alpha: 0.12 + 0.12 * pulse));
    labDashedPath(
      c,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color,
      dash: 10,
      gap: 6,
      phase: -_t * 14,
    );
  }

  // --------------------------------------------------------- circuit

  void _drawWire(Canvas c, int n, Color color) {
    final (a, b) = scene.wireEnds(n);
    _wire(c, _catmull(a, _Scene.wireMid(n, a, b), b, 30), color);
  }

  /// Electron spheres moving round the loop (HTML `updateElectrons`).
  void _electrons(Canvas c) {
    if (scene.electronA <= 0.01 || scene.electronPath.isEmpty) return;
    final a = scene.electronA;
    // Blocked by an insulator: electrons leave the cell's (+) terminal, pass
    // the lamp and stop at the gap, then start again (HTML progress > 0.5
    // resets to 0). Electrons i and i + 20 coincide there, so draw 20.
    final blocked = scene.showBlocked;
    for (var i = 0; i < (blocked ? 20 : 40); i++) {
      final prog = (i / 40 + scene.flowPhase) % (blocked ? 0.5 : 1.0);
      final v = scene.electronAt(prog) + const _V3(0, 0.15, 0);
      final p = _Cam.p(v);
      final r = 0.2 * _Cam.k(v);
      labGlow(c, p, r * 2.6, const Color(0xFFCCFF00), intensity: 0.45 * a);
      labSphere(c, p, r, const Color(0xFFCCFF00), opacity: a, highlight: 0.6, shade: 0.25);
    }
  }

  // ---------------------------------------------------------- objects

  double _lift(Object o) => scene.dragging == o ? 0.4 : 0;

  void _battery(Canvas c, _V3 pos) {
    final o = pos + _V3(0, _lift(_Comp.battery), 0);
    final ground = _V3(pos.x, 0, pos.z);
    final k = _Cam.k(ground);
    labGroundShadow(
      c,
      _Cam.p(ground).translate(6, 4),
      5.2 * k,
      3.4 * k * _Cam.tilt(ground),
      opacity: scene.dragging == _Comp.battery ? 0.22 : 0.38,
    );
    _box(c, o + const _V3(-2.25, 0, -1.5), o + const _V3(2.25, 1.0, 1.5), _holder, faces: 'ts');
    final leftFirst = _Cam.eye.x > o.x;
    for (final z in const [-0.8, 0.8]) {
      void black() => _hCyl(c, o + _V3(-2, 0.8, z), o + _V3(0, 0.8, z), 0.6, const Color(0xFF111827), capTo: false);
      void orange() => _hCyl(c, o + _V3(0, 0.8, z), o + _V3(2, 0.8, z), 0.6, const Color(0xFFF97316), capFrom: false);
      void cap() => _hCyl(c, o + _V3(2.0, 0.8, z), o + _V3(2.2, 0.8, z), 0.2, _metal, metal: true);
      if (leftFirst) {
        black();
        orange();
        cap();
      } else {
        cap();
        orange();
        black();
      }
    }
    _box(c, o + const _V3(-2.25, 0, -1.5), o + const _V3(2.25, 1.0, 1.5), _holder, faces: 'f');
    // Brand stripe on the holder front.
    final s0 = _Cam.p(o + const _V3(-2.0, 0.5, 1.5)), s1 = _Cam.p(o + const _V3(2.0, 0.5, 1.5));
    c.drawLine(
      s0,
      s1,
      Paint()
        ..strokeWidth = 2
        ..color = const Color(0xFFF97316).withValues(alpha: 0.55),
    );
    _terminal(c, o + const _V3(2.2, 0.5, 0), _red);
    _terminal(c, o + const _V3(-2.2, 0.5, 0), _black);
    // "+" / "-" text sprites.
    final kp = _Cam.k(o + const _V3(2.2, 1.5, 0));
    const shadow = [
      Shadow(color: Color(0xCC000000), blurRadius: 3, offset: Offset(0, 1.5)),
      Shadow(color: Color(0x99000000), blurRadius: 1),
    ];
    labText(
      c,
      '+',
      _Cam.p(o + const _V3(2.4, 2.0, 0)),
      size: 1.25 * kp,
      color: _red,
      weight: FontWeight.w900,
      shadows: shadow,
    );
    labText(
      c,
      '−',
      _Cam.p(o + const _V3(-2.4, 2.0, 0)),
      size: 1.25 * kp,
      color: Colors.white,
      weight: FontWeight.w900,
      shadows: shadow,
    );
  }

  void _lamp(Canvas c, _V3 pos) {
    final o = pos + _V3(0, _lift(_Comp.lamp), 0);
    final ground = _V3(pos.x, 0, pos.z);
    final k = _Cam.k(o);
    final glow = scene.glow;
    labGroundShadow(
      c,
      _Cam.p(ground).translate(8, 3),
      3.4 * k,
      2.2 * k * _Cam.tilt(ground),
      opacity: scene.dragging == _Comp.lamp ? 0.22 : 0.38,
    );
    // Holder base and terminal studs.
    _frustum(c, o, 0.5, 0.4, 1.0, _holder);
    for (final sx in const [-1.0, 1.0]) {
      _hCyl(
        c,
        o + _V3(sx < 0 ? -1.2 : 0.75, 0.4, 0),
        o + _V3(sx < 0 ? -0.75 : 1.2, 0.4, 0),
        0.07,
        _metalDark,
        metal: true,
      );
    }
    _terminal(c, o + const _V3(-1.2, 0.4, 0), _red);
    _terminal(c, o + const _V3(1.2, 0.4, 0), _yellow);
    // Screw base with threads.
    _frustum(c, o + const _V3(0, 0.5, 0), 0.8, 0.5, 0.7, _metal, metal: true);
    for (var i = 0; i < 3; i++) {
      final at = o + _V3(0, 0.7 + i * 0.2, 0);
      final p = _Cam.p(at);
      final rr = (0.65 - i * 0.05) * _Cam.k(at);
      final rect = Rect.fromCenter(center: p, width: rr * 2, height: rr * 2 * _Cam.tilt(at));
      c.drawArc(
        rect,
        0,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.16 * _Cam.k(at)
          ..color = labShade(_metal, -0.18),
      );
      c.drawArc(
        rect.shift(const Offset(0, -1)),
        0.3,
        math.pi - 0.6,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.7),
      );
    }
    // Glass stem, support wires and filament (seen through the bulb).
    _frustum(c, o + const _V3(0, 1.3, 0), 1.2, 0.3, 0.15, const Color(0xFFE2E8F0), opacity: 0.55);
    final wirePaint = Paint()
      ..strokeWidth = math.max(1.2, 0.06 * k)
      ..strokeCap = StrokeCap.round
      ..color = _metalDark;
    c.drawLine(_Cam.p(o + const _V3(-0.15, 2.3, 0)), _Cam.p(o + const _V3(-0.3, 3.05, 0)), wirePaint);
    c.drawLine(_Cam.p(o + const _V3(0.15, 2.3, 0)), _Cam.p(o + const _V3(0.3, 3.05, 0)), wirePaint);
    final fil = Path();
    for (var i = 0; i <= 16; i++) {
      final a = math.pi * i / 16;
      final p = _Cam.p(o + _V3(0.25 * math.cos(a), 3.0 + 0.25 * math.sin(a), 0));
      i == 0 ? fil.moveTo(p.dx, p.dy) : fil.lineTo(p.dx, p.dy);
    }
    final filPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.5, 0.07 * k);
    c.drawPath(fil, filPaint..color = const Color(0xFF333333));

    // Bulb glass (HTML LatheGeometry profile).
    final bulb = _bulbOutline(o);
    final bounds = bulb.getBounds();
    final off = [
      Colors.white.withValues(alpha: 0.55),
      const Color(0xFFDDDDDD).withValues(alpha: 0.32),
      const Color(0xFF94A3B8).withValues(alpha: 0.42),
    ];
    final on = [
      const Color(0xFFFFFDF0).withValues(alpha: 0.97),
      const Color(0xFFFFE566).withValues(alpha: 0.93),
      const Color(0xFFF59E0B).withValues(alpha: 0.9),
    ];
    c.drawPath(
      bulb,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 0.85,
          colors: [for (var i = 0; i < 3; i++) Color.lerp(off[i], on[i], glow)!],
          stops: const [0, 0.55, 1],
        ).createShader(bounds),
    );
    c.drawPath(
      bulb,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Color.lerp(Colors.white.withValues(alpha: 0.75), const Color(0xFFFDE68A), glow)!,
    );
    // Faint equator of the globe (glass depth cue).
    final eq = o + const _V3(0, 3.2, 0);
    final eqK = _Cam.k(eq);
    c.drawOval(
      Rect.fromCenter(center: _Cam.p(eq), width: 3.6 * eqK, height: 3.6 * eqK * _Cam.tilt(eq)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.25 * (1 - glow)),
    );
    // Specular streak.
    final hl = Path()
      ..moveTo(_Cam.p(o + const _V3(-1.25, 3.9, 0)).dx, _Cam.p(o + const _V3(-1.25, 3.9, 0)).dy)
      ..quadraticBezierTo(
        _Cam.p(o + const _V3(-1.55, 3.3, 0)).dx,
        _Cam.p(o + const _V3(-1.55, 3.3, 0)).dy,
        _Cam.p(o + const _V3(-1.1, 2.6, 0)).dx,
        _Cam.p(o + const _V3(-1.1, 2.6, 0)).dy,
      );
    c.drawPath(
      hl,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.16 * k
        ..color = Colors.white.withValues(alpha: 0.55 * (1 - glow * 0.6)),
    );
    if (glow > 0.01) {
      final center = _Cam.p(o + const _V3(0, 3.0, 0));
      labGlow(c, center, 2.2 * k * 1.7, const Color(0xFFFFFAED), intensity: 0.9 * glow);
      labGlow(c, center, 1.3 * k, const Color(0xFFFFDD00), intensity: 0.6 * glow);
      c.drawPath(
        fil,
        filPaint
          ..color = const Color(0xFFFFFAED).withValues(alpha: glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      // Light rays.
      final rays = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.55 * glow);
      for (var i = 0; i < 10; i++) {
        final a = -math.pi / 2 + (i - 4.5) * 0.3;
        final len = (0.5 + 0.12 * math.sin(_t * 5 + i)) * k;
        final r0 = 2.15 * k;
        c.drawLine(
          center + Offset(math.cos(a), math.sin(a)) * r0,
          center + Offset(math.cos(a), math.sin(a)) * (r0 + len),
          rays,
        );
      }
    }
  }

  void _key(Canvas c, _V3 pos) {
    final o = pos + _V3(0, _lift(_Item.key), 0);
    final ground = _V3(pos.x - 0.1, 0, pos.z);
    final k = _Cam.k(ground);
    labGroundShadow(
      c,
      _Cam.p(ground).translate(4, 3),
      5.4 * k,
      1.4 * k * _Cam.tilt(ground),
      opacity: scene.dragging == _Item.key ? 0.2 : 0.35,
    );
    // Ring head (HTML TorusGeometry 0.5 / 0.15 lying flat at x = -2).
    Path ring(_V3 at) {
      final p = _Cam.p(at);
      final kk = _Cam.k(at), t = _Cam.tilt(at);
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCenter(center: p, width: 1.3 * kk, height: 1.3 * kk * t))
        ..addOval(Rect.fromCenter(center: p, width: 0.7 * kk, height: 0.7 * kk * t));
    }

    final head = o + const _V3(-2, 0, 0);
    for (final dy in const [-0.12, -0.08, -0.04, 0.0]) {
      c.drawPath(ring(head + _V3(0, dy, 0)), Paint()..color = labShade(_metalDark, -0.35));
    }
    final top = ring(head + const _V3(0, 0.05, 0));
    c.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_metalDark, 0.55), _metalDark, labShade(_metalDark, 0.25)],
        ).createShader(top.getBounds()),
    );
    // Shaft and teeth.
    _hCyl(c, o + const _V3(-1.5, 0, 0), o + const _V3(2.5, 0, 0), 0.15, _metalDark, metal: true);
    _box(c, o + const _V3(1.3, -0.1, 0), o + const _V3(1.7, 0.1, 0.4), labShade(_metalDark, 0.1));
    _box(c, o + const _V3(1.9, -0.1, 0), o + const _V3(2.3, 0.1, 0.3), labShade(_metalDark, 0.1));
  }

  void _stick(Canvas c, _V3 pos) {
    final o = pos + _V3(0, _lift(_Item.stick), 0);
    final ground = _V3(pos.x, 0, pos.z);
    final k = _Cam.k(ground);
    labGroundShadow(
      c,
      _Cam.p(ground).translate(4, 3),
      5.4 * k,
      0.9 * k * _Cam.tilt(ground),
      opacity: scene.dragging == _Item.stick ? 0.2 : 0.35,
    );
    _hCyl(c, o + const _V3(-2.5, 0, 0), o + const _V3(2.5, 0, 0), 0.2, _stickWood);
    final grain = Paint()
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = labShade(_stickWood, -0.4).withValues(alpha: 0.45);
    for (final g in const [(-2.3, 1.2, 0.09), (-0.8, 2.3, 0.02), (-2.0, 0.3, -0.06), (0.6, 2.2, -0.1)]) {
      c.drawLine(_Cam.p(o + _V3(g.$1, g.$3, 0.2)), _Cam.p(o + _V3(g.$2, g.$3, 0.2)), grain);
    }
  }

  // --------------------------------------------------------- overlays

  /// HTML `placeHintRing`: pulsing ring on the terminal to click / reach.
  _Term? _hintTerm() {
    final wiring = scene.wiringSource != null;
    switch (scene.stepType) {
      case _StepType.wire:
        return wiring ? _Term.lampIn : _Term.battPos;
      case _StepType.wireGap:
        if (!scene.w2) return wiring ? _Term.gapLeft : _Term.battNeg;
        return wiring ? _Term.gapRight : _Term.lampOut;
      default:
        return null;
    }
  }

  void _hintRing(Canvas c) {
    final term = _hintTerm();
    if (term == null) return;
    final p = _Cam.p(scene.term(term));
    final ph = (_t % 1.5) / 1.5;
    final r = 10 + 30 * ph;
    c.drawCircle(p, r, Paint()..color = _yellow.withValues(alpha: 0.4 * (1 - ph)));
    c.drawCircle(
      p,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _yellow.withValues(alpha: 1 - ph),
    );
  }

  /// The wire being pulled from a terminal (HTML `tempWire`).
  void _tempWire(Canvas c) {
    final src = scene.wiringSource;
    if (src == null) return;
    final a = _Cam.p(scene.term(src));
    final color = switch (src) {
      _Term.battPos => _red,
      _Term.battNeg => _black,
      _ => _yellow,
    };
    if (scene.wiringArmed) {
      final pulse = 0.5 + 0.5 * math.sin(_t * 8);
      c.drawCircle(
        a,
        13 + 4 * pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: 0.6 + 0.4 * pulse),
      );
      return;
    }
    final ptr = scene.wirePointer;
    if (ptr == null) return;
    final b = _Cam.p(ptr);
    c.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = labShade(color, -0.5).withValues(alpha: 0.9),
    );
    c.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = color == _black ? const Color(0xFF374151) : color,
    );
    labSphere(c, b, 6, const Color(0xFF9CA3AF), highlight: 0.6);
  }

  void _labels(Canvas c) {
    void label(String text, _V3 at, {Alignment anchor = Alignment.center}) => labText(
      c,
      text,
      _Cam.p(at),
      size: 15,
      weight: FontWeight.w700,
      color: isDark ? Colors.white : _Colors.slate900,
      background: isDark ? const Color(0xCC0F172A) : const Color(0xE6FFFFFF),
      border: isDark ? const Color(0x1AFFFFFF) : const Color(0x33000000),
      borderWidth: 1,
      radius: 6,
      anchor: anchor,
      letterSpacing: 0.5,
    );
    label(labels.tray, const _V3(10.9, 0.3, -4.3), anchor: Alignment.centerRight);
    label(labels.cell, scene.batt + _V3(0, 2.8 + _lift(_Comp.battery), 0));
    label(labels.lamp, scene.lamp + _V3(0, 5.2 + _lift(_Comp.lamp), 0), anchor: Alignment.bottomCenter);
    label(labels.key, scene.items[_Item.key]! + _V3(-0.4, 0.9 + _lift(_Item.key), 0), anchor: Alignment.bottomCenter);
    // In the tray the stick's label sits below it so it never covers the key's.
    final stick = scene.items[_Item.stick]!;
    final inTray = stick == _stickHome && scene.dragging != _Item.stick;
    label(
      labels.stick,
      inTray ? stick + const _V3(0, -0.2, 0.55) : stick + _V3(0.4, 0.9 + _lift(_Item.stick), 0),
      anchor: inTray ? Alignment.topCenter : Alignment.bottomCenter,
    );
  }

  /// HTML overlay badges: GOOD / POOR CONDUCTOR at the gap and the
  /// ELECTRON FLOW tag above wire 1.
  void _badges(Canvas c) {
    final g = _Cam.p(_gapCenter);
    void badge(String text, double a, Color bg, Color border) => labText(
      c,
      text.toUpperCase(),
      g + const Offset(0, 40),
      size: 14,
      weight: FontWeight.w800,
      color: _Colors.slate900,
      background: bg,
      border: border,
      borderWidth: 2,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      opacity: a,
      letterSpacing: 0.5,
    );
    if (scene.conductorA > 0.01) {
      badge(labels.conductor, scene.conductorA, const Color(0xFF86EFAC), const Color(0xFF22C55E));
    }
    if (scene.insulatorA > 0.01) {
      badge(labels.insulator, scene.insulatorA, const Color(0xFFFCA5A5), const Color(0xFFEF4444));
    }
    if (scene.electronA > 0.01 && scene.circuitBuilt) {
      final (a, b) = scene.wireEnds(1);
      final m = _Cam.p(_Scene.wireMid(1, a, b));
      final rect = labText(
        c,
        labels.electron.toUpperCase(),
        m - const Offset(12, 30),
        size: 15,
        weight: FontWeight.w800,
        color: const Color(0xFF854D0E),
        background: const Color(0xFFFEF08A),
        border: _yellow,
        borderWidth: 2,
        radius: 6,
        padding: const EdgeInsets.fromLTRB(12, 4, 36, 4),
        opacity: scene.electronA,
        letterSpacing: 0.5,
      );
      labArrow(
        c,
        Offset(rect.right - 30, rect.center.dy),
        Offset(rect.right - 10, rect.center.dy),
        color: const Color(0xFF854D0E).withValues(alpha: scene.electronA),
        width: 2.6,
        head: 8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.labels != labels || old.scene != scene;
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
