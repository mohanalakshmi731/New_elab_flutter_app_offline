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

/// Class 7 Science • Chapter 2 • Activity 2
/// Exploring Natural Acid-Base Indicators.
///
/// Native Flutter port of `Cl7S-Ch2-A2-Exploring_Natural_Acid_Base_Indicators.html`.
/// Scenario 1: make red-rose indicator (petals → mortar, crush with the
/// pestle, transfer, add hot water, filter into a test tube) and test lemon
/// juice (magenta) and soap (green). Scenario 2: make turmeric paper, cut it
/// into strips and test soap (reddish-brown), lemon and sugar (no change).
class Ch2A2ExploringNaturalAcidBaseIndicatorsPage extends StatefulWidget {
  const Ch2A2ExploringNaturalAcidBaseIndicatorsPage({super.key});

  @override
  State<Ch2A2ExploringNaturalAcidBaseIndicatorsPage> createState() =>
      _Ch2A2ExploringNaturalAcidBaseIndicatorsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311.
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
  splash('splash.mp3');

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

/// Pan recognizer that only claims touches starting on a draggable object,
/// so camera pan / pinch keep working elsewhere.
class _ObjectPanRecognizer extends PanGestureRecognizer {
  _ObjectPanRecognizer({required this.accepts}) {
    // Small slop: objects can sit close to their targets on screen, and
    // this recognizer only claims touches that start on a draggable object.
    gestureSettings = const DeviceGestureSettings(touchSlop: 4);
  }
  bool Function(Offset local) accepts;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

// HTML step tables: valid target per step and its drop destination.
const List<String> _targets1 = [
  'petals', 'pestle', 'petals', 'kettle', 'funnel', 'beaker', 'dropper', 'dropper', //
];
const List<String> _targets2 = ['spoon', 'dropW', 'paper', 'scissors', 'dropS', 'dropL', 'dropSug'];
const List<String?> _dests1 = ['mortar', null, 'beaker', 'beaker', 'ttInd', 'funnel', null, null];
const List<String> _dests2 = ['petri', 'petri', 'petri', 'paper', 'st1', 'st2', 'st3'];
const Set<String> _tubeIds = {'ttInd', 'ttLemon', 'ttSoap'};
const Set<String> _stripIds = {'st1', 'st2', 'st3'};

class _Ch2A2ExploringNaturalAcidBaseIndicatorsPageState
    extends State<Ch2A2ExploringNaturalAcidBaseIndicatorsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// HTML `State.step` (0-based; == steps.length is the "done" step).
  int _step = 0;
  int _clickCount = 0;
  bool _crushing = false;
  bool _dryPending = false;

  /// Objects busy with a success animation, until this scene time.
  final Map<String, double> _busyUntil = {};
  _V3 _grabOff = const _V3(0, 0, 0);
  double _liftY = 1;

  int get _scenario => _scene.scenario;
  bool get _s1 => _scenario == 0;
  double get _now => _scene.time;
  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];
  bool get _done => _step >= _data.steps.length;
  String get _target => _s1 ? _targets1[_step] : _targets2[_step];
  bool get _isClickStep => _s1 && _step == 1;

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
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
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

  // ------------------------------------------------------------ scenario

  /// HTML `loadScenario()`: rebuild the bench and recentre the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.build(index);
    _scene.cam.overview(_now);
    _step = 0;
    _clickCount = 0;
    _crushing = false;
    _dryPending = false;
    _busyUntil.clear();
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `progressStep()`; the "done" step plays the success chime and
  /// opens the observation popup 4 s later.
  void _progress() {
    if (!mounted || _done) return;
    setState(() {
      _step++;
      if (_done) {
        _Audio.play(_Sound.success);
        final scenario = _scenario;
        _lab.showScenarioConclusion(
          scenarioIndex: scenario,
          totalScenarios: 2,
          delay: const Duration(milliseconds: 4000),
          title: () => _t('obsConc'),
          heading: () => _t('concTitle'),
          body: () => _t('conc${scenario + 1}'),
        );
      }
    });
  }

  void _progressLater() => _lab.after(const Duration(milliseconds: 500), _progress);

  void _snapBack(_Obj o) => o.pos.to(o.home, _now, 0.5, Curves.easeOutQuad);

  void _busy(_Obj o, double seconds) => _busyUntil[o.id] = _now + seconds;

  bool _isBusy(_Obj o) => (_busyUntil[o.id] ?? -1) > _now || o.pos.moving(_now);

  /// After [ms] milliseconds, runs [fn] inside setState (if still mounted).
  void _later(int ms, VoidCallback fn) => _lab.after(Duration(milliseconds: ms), () {
    if (mounted) setState(fn);
  });

  // --------------------------------------------------------- interaction

  /// Clickable object under [p] (HTML raycast on clickObjects). When pick
  /// boxes overlap, the current step's object wins, else the front-most.
  _Obj? _hitClickable(Offset p) {
    final v = _scene.view();
    _Obj? best;
    var bestZ = -double.infinity;
    for (final o in _scene.objs.values) {
      if (!o.clickable || !o.visible || o.dragging) continue;
      if (!_scene.bounds(o, v).inflate(6).contains(p)) continue;
      if (!_done && o.id == _target) return o;
      final z = o.pos.at(_now).z;
      if (z > bestZ) {
        bestZ = z;
        best = o;
      }
    }
    return best;
  }

  bool _canDrag(_Obj o) {
    if (_isBusy(o)) return false;
    if (_done) return o.clickable;
    return o.id == _target && !_isClickStep && !_dryPending;
  }

  bool _acceptsPointer(Offset local) {
    final o = _hitClickable(local);
    return o != null && _canDrag(o);
  }

  /// HTML `handlePointerDown`: wrong objects get a toast, the pestle is
  /// clicked straight away.
  void _onPointerDown(PointerDownEvent e) {
    final o = _hitClickable(e.localPosition);
    if (o == null || _done || _isBusy(o)) return;
    if (o.id == _target) {
      if (_dryPending) {
        _lab.showToast(_t('toastDryFirst'), isError: true);
      } else if (_isClickStep) {
        _crush();
      }
      return;
    }
    _lab.showToast(_t('toastWrongObj'), isError: true);
  }

  /// A tap (no drag) on the right object counts as a drop where it stands.
  void _onTapUp(TapUpDetails d) {
    final o = _hitClickable(d.localPosition);
    if (o == null || _done || _isClickStep || _dryPending || o.id != _target || _isBusy(o)) return;
    _lab.showToast(_t('toastCloser'), sound: false);
    _Audio.play(_Sound.wrong);
  }

  void _onPanStart(DragStartDetails d) {
    final o = _hitClickable(d.localPosition);
    if (o == null || !_canDrag(o)) return;
    final plane = _scene.view().unproject(d.localPosition, 0);
    if (plane == null) return;
    final p = o.pos.at(_now);
    _grabOff = _V3(plane.x - p.x, 0, plane.z - p.z);
    _liftY = o.home.y + 1;
    o.dragging = true;
    _scene.dragging = o;
    if (!_s1 && _step == 0 && o.id == 'spoon') _scene.spoonPowder = true;
    o.pos.set(_V3(p.x, _liftY, p.z));
    _Audio.play(_Sound.pickup);
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _scene.dragging;
    if (o == null) return;
    final plane = _scene.view().unproject(d.localPosition, 0);
    if (plane == null) return;
    o.pos.set(
      _V3((plane.x - _grabOff.x).clamp(-12.0, 12.0), _liftY, (plane.z - _grabOff.z).clamp(-4.5, 6.5)),
    );
  }

  void _onPanEnd(DragEndDetails _) {
    final o = _scene.dragging;
    if (o == null) return;
    setState(() => _release(o));
  }

  void _onPanCancel() {
    final o = _scene.dragging;
    if (o == null) return;
    setState(() {
      o.dragging = false;
      _scene.dragging = null;
      if (!_s1 && _step == 0) _scene.spoonPowder = false;
      o.pos.to(o.home, _now, 0.3, Curves.easeOutQuad);
    });
  }

  String? get _destId {
    if (_s1) {
      if (_step == 6) return _scene.seqPhase == 1 ? 'ttLemon' : 'ttInd';
      if (_step == 7) return _scene.seqPhase == 1 ? 'ttSoap' : 'ttInd';
      return _dests1[_step];
    }
    return _dests2[_step];
  }

  /// HTML `handlePointerUp`: success when released near the destination.
  void _release(_Obj o) {
    o.dragging = false;
    _scene.dragging = null;
    if (_done) {
      _snapBack(o);
      return;
    }
    final destId = _destId;
    if (destId == null) {
      o.pos.to(o.home, _now, 0.3, Curves.easeOutQuad);
      return;
    }
    final dest = _scene.o(destId);
    final p = o.pos.at(_now);
    var near = p.distXZ(dest.pos.at(_now)) < 2.2;
    // Neighbouring tubes / strips: the closest one must be the right one.
    final group = _tubeIds.contains(destId) ? _tubeIds : (_stripIds.contains(destId) ? _stripIds : null);
    if (near && group != null) {
      for (final id in group) {
        if (id != destId && p.distXZ(_scene.o(id).pos.at(_now)) < p.distXZ(dest.pos.at(_now))) {
          near = false;
        }
      }
    }
    if (near) {
      _success(o, dest);
      return;
    }
    if (!_s1 && _step == 0) _scene.spoonPowder = false;
    o.pos.to(o.home, _now, 0.3, Curves.easeOutQuad);
    _lab.showToast(_t('toastCloser'), sound: false);
    _Audio.play(_Sound.wrong);
  }

  /// HTML `handleTaskClick` for the pestle (3 clicks crush the petals).
  void _crush() {
    if (_crushing) return;
    final pestle = _scene.o('pestle');
    final m = _scene.o('mortar').pos.at(_now);
    setState(() {
      _crushing = true;
      _clickCount++;
    });
    _Audio.play(_Sound.drop);
    pestle.pos.to(_V3(m.x + 0.2, m.y + 1.2, m.z + 0.2), _now, 0.1);
    _lab.after(const Duration(milliseconds: 100), () {
      pestle.pos.to(_V3(m.x + 0.2, m.y + 0.3, m.z + 0.2), _now, 0.15);
    });
    _lab.after(const Duration(milliseconds: 250), () {
      pestle.pos.to(_V3(m.x + 0.2, m.y + 1.2, m.z + 0.2), _now, 0.15);
    });
    _lab.after(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final finished = _clickCount >= 3;
      setState(() {
        _crushing = false;
        if (finished) {
          _clickCount = 0;
          _scene.petalsCrushed = true;
          pestle.home = pestle.pos.v;
          _Audio.play(_Sound.pop);
        }
      });
      if (finished) _progress();
    });
  }

  /// HTML `handleTaskSuccess`: the object glides above the destination
  /// (300 ms), then the step-specific action runs.
  void _success(_Obj o, _Obj dest) {
    final scenario = _scenario, step = _step;
    final dp = dest.pos.at(_now);
    final up = (_s1 && step == 4) ? 2.7 : 2.5;
    o.pos.to(_V3(dp.x, dp.y + up, dp.z), _now, 0.3);
    _busy(o, 0.35);
    _later(300, () {
      if (_scenario != scenario || _step != step) return;
      if (scenario == 0) {
        _arrive1(o, dest, step);
      } else {
        _arrive2(o, dest, step);
      }
    });
  }

  void _arrive1(_Obj o, _Obj dest, int step) {
    final now = _now;
    final dp = dest.pos.at(now);
    switch (step) {
      case 0: // petals into the mortar, camera focuses on it
        final home = dp.up(0.2);
        o.pos.set(home);
        o.home = home;
        o.scale.set(0.6);
        _Audio.play(_Sound.pop);
        _scene.cam.focus(_V3(dp.x, 1, dp.z), const _V3(0, 4, 4), now, 1.0, Curves.easeOutCubic);
        _progressLater();
      case 2: // crushed petals into the beaker
        o.visible = false;
        _scene.pasteInBeaker = true;
        _scene.cam.focus(_V3(dp.x, 1, dp.z), const _V3(0, 4, 6), now, 0.8);
        _Audio.play(_Sound.pop);
        _progressLater();
      case 3: // kettle pours hot water; extract turns red
        o.pos.to(_V3(dp.x - 2.0, dp.y + 3.4, dp.z), now, 0.5);
        o.rot.to(-math.pi / 3, now, 0.5);
        _busy(o, 3.3);
        _progressLater();
        _later(500, () {
          _Audio.play(_Sound.splash);
          _scene.stream = _Stream('kettle', _V3(dp.x + 0.2, 0.3, dp.z), _cWater, width: 0.09);
          _scene.beakerLiquid = true;
          _scene.beakerColor.set(_cWater);
          _scene.beakerLevel.set(0.01);
          _scene.beakerLevel.to(1, _now, 1.5);
          _scene.particles = true;
          _scene.particlesT0 = _now + 1.0;
        });
        _later(1500, () => _scene.beakerColor.to(_cRed, _now, 1.5));
        _later(2700, () {
          _scene.stream = null;
          o.rot.set(0);
          _snapBack(o);
        });
      case 4: // funnel placed on the indicator test tube
        final home = _V3(dp.x, dp.y + 2.7, dp.z);
        o.pos.set(home);
        o.home = home;
        _Audio.play(_Sound.pop);
        _scene.cam.focus(_V3(dp.x, 1, dp.z), const _V3(0, 3, 6), now, 1.0);
        _progressLater();
      case 5: // beaker pours the extract through the filter
        final ind = _scene.o('ttInd').pos.at(now);
        o.pos.to(_V3(dp.x - 2.4, dp.y + 0.5, dp.z), now, 0.5);
        o.rot.to(-math.pi / 4, now, 0.5);
        _busy(o, 2.9);
        _progressLater();
        _later(500, () {
          _Audio.play(_Sound.splash);
          _scene.stream = _Stream('beaker', _V3(dp.x, dp.y + 0.6, dp.z), _cRed, width: 0.07);
          for (var i = 1; i <= 13; i++) {
            _scene.drips.add(
              _Drip(_V3(dp.x, dp.y - 0.6, dp.z), _V3(ind.x, ind.y + 0.5, ind.z), _cRed, _now + i * 0.3),
            );
          }
        });
        _later(2300, () {
          _scene.beakerLevel.to(0.01, _now, 0.5);
          _scene.particles = false;
          _scene.stream = null;
          o.rot.set(0);
          _scene.indLiquid = true;
          _scene.indLevel.set(0.01);
          _scene.indLevel.to(0.9, _now, 3.8);
          _snapBack(o);
        });
      case 6:
      case 7: // dropper: fill from the indicator, then test the tube
        _Audio.play(_Sound.pop);
        if (_scene.seqPhase == 0) {
          _scene.dropperLiquid = true;
          _scene.seqPhase = 1;
          _snapBack(o);
          _busy(o, 0.5);
          return;
        }
        _scene.dropperLiquid = false;
        _scene.seqPhase = 0;
        _scene.drips.add(_Drip(dp.up(2.45), dp.up(1.9), _cRed, now, dur: 0.2));
        _later(200, () {
          if (step == 6) {
            _scene.lemonColor.to(_cMagenta, _now, 0.3);
            _scene.acidicLabel = true;
          } else {
            _scene.soapColor.to(_cGreen, _now, 0.3);
            _scene.basicLabel = true;
          }
        });
        _snapBack(o);
        _progressLater();
    }
  }

  void _arrive2(_Obj o, _Obj dest, int step) {
    final now = _now;
    final dp = dest.pos.at(now);
    switch (step) {
      case 0: // spoon tips turmeric powder into the petri dish
        o.rot.to(math.pi / 4, now, 0.3);
        _busy(o, 1.4);
        _progressLater();
        _later(300, () {
          _scene.spoonPowder = false;
          _scene.petri = 1;
          _Audio.play(_Sound.splash);
          final tip = o.pos.at(_now);
          for (var i = 0; i < 5; i++) {
            _scene.drips.add(
              _Drip(
                _V3(tip.x - 0.3, tip.y - 0.3, tip.z),
                _V3(dp.x, 0.15, dp.z),
                _cTurmeric,
                _now + i * 0.06,
                dur: 0.25,
              ),
            );
          }
        });
        _later(800, () {
          o.rot.set(0);
          _snapBack(o);
        });
      case 1: // water dropper turns the powder into a paste
        _Audio.play(_Sound.splash);
        _scene.drips.add(_Drip(dp.up(2.45), _V3(dp.x, 0.15, dp.z), _cWater, now, dur: 0.25));
        _later(250, () => _scene.petri = 2);
        _snapBack(o);
        _progressLater();
      case 2: // filter paper soaks in the paste; "Dry Paper" appears
        final home = dp.up(0.2);
        o.pos.set(home);
        o.home = home;
        _scene.paper = 1;
        _dryPending = true;
        _Audio.play(_Sound.pop);
      case 3: // scissors cut the dried paper into 3 strips
        _Audio.play(_Sound.pop);
        _scene.snipT0 = now;
        _scene.o('paper').visible = false;
        _scene.paper = 3;
        for (final id in _stripIds) {
          _scene.o(id).visible = true;
        }
        _snapBack(o);
        _progressLater();
      case 4:
      case 5:
      case 6: // droppers test strip 1 / 2 / 3
        _Audio.play(_Sound.pop);
        _scene.drips.add(_Drip(dp.up(2.45), dp.up(0.02), o.id == 'dropL' ? _cYellow : _cSoap, now));
        _later(200, () {
          if (step == 4) {
            _scene.spot1 = true;
          } else if (step == 5) {
            _scene.spot2T0 = _now;
            _scene.tested2 = true;
          } else {
            _scene.spot3T0 = _now;
            _scene.tested3 = true;
          }
        });
        _snapBack(o);
        _progressLater();
    }
  }

  /// HTML dynamic "Dry Paper" button.
  void _dryPaper() {
    if (!_dryPending) return;
    setState(() {
      _dryPending = false;
      _scene.paper = 2;
    });
    _Audio.play(_Sound.pop);
    _progress();
  }

  // ------------------------------------------------------------------ UI

  List<LabAction> _actions() => [
    if (_dryPending)
      LabAction(label: _t('btnDry'), icon: Icons.air, highlight: true, silent: true, onTap: _dryPaper),
  ];

  Map<String, String> _labels() => {
    for (final k in const [
      'lblBowlPetals', 'lblMortar', 'lblBeaker', 'lblKettle', 'lblFunnel', 'lblInd', //
      'lblLemon', 'lblSoap', 'lblDropper', 'lblTurmeric', 'lblPetri', 'lblPaper', //
      'lblWater', 'lblSoapBase', 'lblLemonAcid', 'lblSugarNeutral', 'lblScissors', //
      'lblAcidic', 'lblBasic', 'lblPestle', 'lblSpoon', 'lblStrip', //
    ])
      k: _t(k),
  };

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
          icon: Icons.local_florist,
          title: _t('titleMain'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('scenario1Title'), _t('scenario2Title')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step + 1,
          instruction: _done ? _t('doneTask') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('obsTitle'),
          sidebarExtra: _observations(p, s),
          onReset: _fullReset,
          overlays: [if (_dryPending) _dryOverlay(s)],
          stage: LabStage(
            designSize: _design,
            child: Listener(
              onPointerDown: _onPointerDown,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  _ObjectPanRecognizer: GestureRecognizerFactoryWithHandlers<_ObjectPanRecognizer>(
                    () => _ObjectPanRecognizer(accepts: _acceptsPointer),
                    (r) => r
                      ..accepts = _acceptsPointer
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _onPanStart
                      ..onUpdate = _onPanUpdate
                      ..onEnd = _onPanEnd
                      ..onCancel = _onPanCancel,
                  ),
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    TapGestureRecognizer.new,
                    (r) => r.onTapUp = _onTapUp,
                  ),
                },
                child: CustomPaint(
                  size: _design,
                  painter: _IndicatorPainter(
                    scene: _scene,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    labels: _labels(),
                    lang: _lab.lang.code,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Live readout of what has been prepared and observed.
  Widget _observations(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final pending = _t('pending');
    Widget row(String label, String value, {Color? color, Color? dot}) => Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dot != null) ...[
            Container(
              width: 10 * s,
              height: 10 * s,
              margin: EdgeInsets.only(top: 3 * s),
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            SizedBox(width: 6 * s),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.textMuted, fontSize: 12 * f, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 8 * s),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color ?? (value == pending ? p.textMuted : p.textStrong),
                fontSize: 12 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    final rows = <Widget>[];
    if (_s1) {
      final crushes = _scene.petalsCrushed ? 3 : _clickCount;
      final ind = _scene.indLiquid
          ? _t('stReady')
          : (_scene.beakerLiquid ? _t('stExtracting') : _t('stNotReady'));
      rows
        ..add(row(_t('crushes'), '$crushes / 3', color: crushes == 3 ? _Colors.green : null))
        ..add(
          row(
            _t('rowIndicator'),
            ind,
            color: _scene.indLiquid ? const Color(0xFFFF4D7E) : null,
            dot: _scene.indLiquid ? _cRed : null,
          ),
        )
        ..add(row(_t('lblDropper'), _scene.dropperLiquid ? _t('lblInd') : pending))
        ..add(
          row(
            _t('lblLemon'),
            _scene.acidicLabel ? _t('resMagenta') : pending,
            dot: _scene.acidicLabel ? _cMagenta : _cYellow,
          ),
        )
        ..add(
          row(
            _t('lblSoap'),
            _scene.basicLabel ? _t('resGreen') : pending,
            dot: _scene.basicLabel ? _cGreen : _cSoap,
          ),
        );
    } else {
      final paper = [_t('stNotReady'), _t('stWet'), _t('stDry'), _t('stCut')][_scene.paper];
      String strip(int n) => labFormat(_t('lblStrip'), {'n': n});
      rows
        ..add(row(_t('rowPaper'), paper, dot: _scene.paper == 0 ? _cPlasticWhite : _cTurmeric))
        ..add(
          row(
            '${strip(1)} • ${_t('lblSoapBase')}',
            _scene.spot1 ? _t('resBrown') : pending,
            dot: _scene.spot1 ? _cSpotRed : null,
            color: _scene.spot1 ? const Color(0xFFDC2626) : null,
          ),
        )
        ..add(
          row(
            '${strip(2)} • ${_t('lblLemonAcid')}',
            _scene.tested2 ? _t('resNoChange') : pending,
            dot: _scene.tested2 ? _cTurmeric : null,
          ),
        )
        ..add(
          row(
            '${strip(3)} • ${_t('lblSugarNeutral')}',
            _scene.tested3 ? _t('resNoChange') : pending,
            dot: _scene.tested3 ? _cTurmeric : null,
          ),
        );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  /// HTML `#dynamic-ui-layer` "Dry Paper" button, centred on the canvas.
  Widget _dryOverlay(double s) {
    return Positioned.fill(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: v, child: child),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: LabActionButton(
              scale: s * 1.1,
              expand: false,
              action: LabAction(
                label: _t('btnDry'),
                icon: Icons.air,
                highlight: true,
                silent: true,
                onTap: _dryPaper,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================ STRINGS
// From the HTML `i18n` (EN / HI; Telugu dropped). HTML markup removed from
// task texts, KaTeX ($H^+$, $OH^-$) written as plain Unicode. Keys marked
// "new" are labels / readouts / hints added in this port.

const LabStringTable _i18n = {
  'en': {
    'titleMain': 'Exploring Natural Acid-Base Indicators',
    'subtitle': 'Class 7 • Acids, Bases and Salts',
    'scenario1Title': 'Scenario 1: The Red Rose Test',
    'scenario2Title': 'Scenario 2: The Turmeric Paper Test',
    'obsConc': 'Observation / Conclusion',
    'btnDry': 'Dry Paper',
    'toastWrongObj': 'Not the right object for this step.',
    'toastCloser': 'Move it closer to the target area.',
    'lblBowlPetals': 'Bowl & Petals',
    'lblMortar': 'Mortar',
    'lblBeaker': 'Beaker',
    'lblKettle': 'Hot Water Kettle',
    'lblFunnel': 'Filter Funnel',
    'lblInd': 'Indicator',
    'lblLemon': 'Lemon Juice',
    'lblSoap': 'Soap Sol.',
    'lblDropper': 'Dropper',
    'lblTurmeric': 'Turmeric',
    'lblPetri': 'Petri Dish',
    'lblPaper': 'Filter Paper',
    'lblWater': 'Water',
    'lblSoapBase': 'Soap (Base)',
    'lblLemonAcid': 'Lemon (Acid)',
    'lblSugarNeutral': 'Sugar (Neutral)',
    'lblScissors': 'Scissors',
    'lblAcidic': 'ACIDIC (Magenta)',
    'lblBasic': 'BASIC (Green)',
    'doneTask': 'Observation Complete! Check the popup on the canvas to review results.',
    'concTitle': 'Conclusion',
    'conc1':
        'Red Rose extract is a valid natural acid-base indicator. It is Red/Magenta in Acid and Green in Base.',
    'conc2':
        'Turmeric is an indicator that specifically detects bases by turning Reddish-Brown. It remains yellow in acids and neutral substances.',
    // new
    'lblPestle': 'Pestle',
    'lblSpoon': 'Spoon',
    'lblStrip': 'Strip {n}',
    'toastDryFirst': 'Click the Dry Paper button to dry the soaked paper.',
    'obsTitle': 'Observations',
    'crushes': 'Pestle crushes',
    'rowIndicator': 'Rose indicator',
    'rowPaper': 'Turmeric paper',
    'stNotReady': 'Not prepared',
    'stExtracting': 'Extracting…',
    'stReady': 'Ready (red)',
    'stWet': 'Soaked (wet)',
    'stDry': 'Dry',
    'stCut': 'Cut into 3 strips',
    'resMagenta': 'Magenta → Acidic',
    'resGreen': 'Green → Basic',
    'resBrown': 'Reddish-brown → Basic',
    'resNoChange': 'No change (yellow)',
    'pending': '—',
  },
  'hi': {
    'titleMain': 'प्राकृतिक अम्ल-क्षार सूचकों की खोज',
    'subtitle': 'कक्षा 7 • अम्ल, क्षारक और लवण',
    'scenario1Title': 'परिदृश्य 1: लाल गुलाब परीक्षण',
    'scenario2Title': 'परिदृश्य 2: हल्दी पेपर परीक्षण',
    'obsConc': 'अवलोकन / निष्कर्ष',
    'btnDry': 'कागज सुखाएं',
    'toastWrongObj': 'इस चरण के लिए सही वस्तु नहीं है।',
    'toastCloser': 'इसे लक्ष्य क्षेत्र के करीब ले जाएं।',
    'lblBowlPetals': 'कटोरा और पंखुड़ियां',
    'lblMortar': 'ओखली',
    'lblBeaker': 'बीकर',
    'lblKettle': 'गर्म पानी की केतली',
    'lblFunnel': 'फ़िल्टर फ़नल',
    'lblInd': 'सूचक',
    'lblLemon': 'नींबू का रस',
    'lblSoap': 'साबुन का घोल',
    'lblDropper': 'ड्रॉपर',
    'lblTurmeric': 'हल्दी',
    'lblPetri': 'पेट्री डिश',
    'lblPaper': 'फ़िल्टर पेपर',
    'lblWater': 'पानी',
    'lblSoapBase': 'साबुन (क्षारक)',
    'lblLemonAcid': 'नींबू (अम्ल)',
    'lblSugarNeutral': 'चीनी (उदासीन)',
    'lblScissors': 'कैंची',
    'lblAcidic': 'अम्लीय (मैजेंटा)',
    'lblBasic': 'क्षारीय (हरा)',
    'doneTask': 'अवलोकन पूर्ण! परिणाम देखने के लिए कैनवास पर पॉपअप देखें।',
    'concTitle': 'निष्कर्ष',
    'conc1':
        'लाल गुलाब का अर्क एक वैध प्राकृतिक अम्ल-क्षार सूचक है। यह अम्ल में लाल/मैजेंटा और क्षारक में हरा होता है।',
    'conc2':
        'हल्दी एक सूचक है जो विशेष रूप से क्षारकों का पता लगाता है, जो लाल-भूरा हो जाता है। यह अम्लों और उदासीन पदार्थों में पीला रहता है।',
    'lblPestle': 'मूसल',
    'lblSpoon': 'चम्मच',
    'lblStrip': 'स्ट्रिप {n}',
    'toastDryFirst': 'भीगे कागज को सुखाने के लिए "कागज सुखाएं" बटन पर क्लिक करें।',
    'obsTitle': 'अवलोकन',
    'crushes': 'मूसल से कुचलना',
    'rowIndicator': 'गुलाब सूचक',
    'rowPaper': 'हल्दी पेपर',
    'stNotReady': 'तैयार नहीं',
    'stExtracting': 'निष्कर्षण हो रहा है…',
    'stReady': 'तैयार (लाल)',
    'stWet': 'भीगा हुआ',
    'stDry': 'सूखा',
    'stCut': '3 स्ट्रिप्स में कटा',
    'resMagenta': 'मैजेंटा → अम्लीय',
    'resGreen': 'हरा → क्षारीय',
    'resBrown': 'लाल-भूरा → क्षारीय',
    'resNoChange': 'कोई बदलाव नहीं (पीला)',
    'pending': '—',
  },
};

// Steps: concept = HTML step title (without "Step n:"), action = task,
// observation = theory. The final "done" step is handled separately.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'Prepare an indicator from red rose petals and use it to test whether lemon juice and soap solution are acidic or basic.',
      steps: [
        LabStep(
          concept: 'Place Petals in Mortar',
          action: 'DRAG the Red Rose Petals into the Mortar.',
          observation:
              'Natural indicators can be extracted by crushing the plant material. This breaks cell walls, releasing the pigmented molecules.',
        ),
        LabStep(
          concept: 'Crush the Petals',
          action: 'CLICK the Pestle repeatedly to crush the petals.',
          observation:
              'Crushing increases the surface area for the hot water to extract the pigment efficiently.',
        ),
        LabStep(
          concept: 'Transfer to Beaker',
          action: 'DRAG the Crushed Petals from the mortar to the empty Beaker.',
          observation:
              'We need a transparent vessel to clearly observe the extraction process and color changes.',
        ),
        LabStep(
          concept: 'Add Hot Water',
          action: 'DRAG the Kettle to pour hot water into the beaker.',
          observation:
              'Hot water acts as a solvent. The heat provides kinetic energy, dissolving the indicator dye from the solid plant matter into the liquid.',
        ),
        LabStep(
          concept: 'Prepare Filter',
          action: 'DRAG the Filter Funnel and PLACE it on top of the empty Indicator Test Tube.',
          observation: 'Place the filter funnel securely on the test tube before pouring.',
        ),
        LabStep(
          concept: 'Filter the Extract',
          action: 'DRAG the Beaker and POUR the mixture into the filter funnel.',
          observation:
              'Filtration separates the solid residue (undissolved plant matter) from the filtrate (the colored indicator solution).',
        ),
        LabStep(
          concept: 'Test Lemon Juice (Acid)',
          action: 'DRAG the Dropper to the indicator, then DRAG it to the Lemon Juice test tube.',
          observation:
              'Acids release H⁺ ions in aqueous solution. Red rose indicator turns a distinct magenta/red color in the presence of an acid.',
        ),
        LabStep(
          concept: 'Test Soap Solution (Base)',
          action: 'DRAG the Dropper to the indicator, then DRAG it to the Soap Solution test tube.',
          observation:
              'Bases release OH⁻ ions. The indicator reacts with the base to change its molecular structure, resulting in a green color.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'Prepare turmeric indicator paper and use it to differentiate between acidic, basic, and neutral solutions.',
      steps: [
        LabStep(
          concept: 'Turmeric Powder',
          action: 'DRAG the Spoon to place turmeric powder into the Petri Dish.',
          observation: 'Turmeric contains curcumin, a chemical that acts as a pH indicator.',
        ),
        LabStep(
          concept: 'Make a Paste',
          action: 'DRAG the Water Dropper to the Petri Dish to make a paste.',
          observation: 'Adding water forms a paste, making it easier to apply to the paper.',
        ),
        LabStep(
          concept: 'Prepare Paper',
          action:
              'DRAG the Filter Paper into the Petri Dish to soak it. Then CLICK the Dry button on screen.',
          observation:
              'Filter paper absorbs the turmeric paste, creating indicator strips once dried.',
        ),
        LabStep(
          concept: 'Cut Strips',
          action: 'DRAG the Scissors to the dried paper to cut it into 3 strips.',
          observation:
              'We need separate strips to test different substances without cross-contamination.',
        ),
        LabStep(
          concept: 'Test Soap Solution (Base)',
          action: 'DRAG the Soap Dropper to Strip 1.',
          observation:
              'Curcumin changes from yellow to deep reddish-brown in basic conditions (pH > 7.4).',
        ),
        LabStep(
          concept: 'Test Lemon Juice (Acid)',
          action: 'DRAG the Lemon Dropper to Strip 2.',
          observation: 'In acidic conditions, curcumin remains yellow. There is no visible color change.',
        ),
        LabStep(
          concept: 'Test Sugar Solution (Neutral)',
          action: 'DRAG the Sugar Dropper to Strip 3.',
          observation:
              'Neutral solutions do not affect the pH enough to cause a color change in curcumin.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'लाल गुलाब की पंखुड़ियों से एक सूचक तैयार करें और इसका उपयोग यह परीक्षण करने के लिए करें कि नींबू का रस और साबुन का घोल अम्लीय है या क्षारीय।',
      steps: [
        LabStep(
          concept: 'ओखली में पंखुड़ियां रखें',
          action: 'ओखली में लाल गुलाब की पंखुड़ियों को खींचें (DRAG)।',
          observation:
              'कुचलकर पौधों की सामग्री से प्राकृतिक सूचक निकाले जा सकते हैं। इससे कोशिका भित्ति टूट जाती है, जिससे रंगद्रव्य मुक्त होते हैं।',
        ),
        LabStep(
          concept: 'पंखुड़ियों को कुचलें',
          action: 'पंखुड़ियों को कुचलने के लिए मूसल पर बार-बार क्लिक (CLICK) करें।',
          observation:
              'कुचलने से सतह का क्षेत्रफल बढ़ जाता है जिससे गर्म पानी वर्णक को कुशलता से निकाल सकता है।',
        ),
        LabStep(
          concept: 'बीकर में स्थानांतरित करें',
          action: 'ओखली से कुचली हुई पंखुड़ियों को खाली बीकर में खींचें (DRAG)।',
          observation:
              'रंग परिवर्तन और निष्कर्षण प्रक्रिया को स्पष्ट रूप से देखने के लिए हमें एक पारदर्शी बर्तन की आवश्यकता है।',
        ),
        LabStep(
          concept: 'गर्म पानी डालें',
          action: 'बीकर में गर्म पानी डालने के लिए केतली को खींचें (DRAG)।',
          observation:
              'गर्म पानी एक विलायक के रूप में कार्य करता है। गर्मी गतिज ऊर्जा प्रदान करती है, जो ठोस पदार्थ से सूचक डाई को तरल में घोलती है।',
        ),
        LabStep(
          concept: 'फ़िल्टर तैयार करें',
          action: 'फ़िल्टर फ़नल को खींचें (DRAG) और इसे खाली सूचक टेस्ट ट्यूब के ऊपर रखें।',
          observation: 'डालने से पहले फ़िल्टर फ़नल को टेस्ट ट्यूब पर सुरक्षित रूप से रखें।',
        ),
        LabStep(
          concept: 'अर्क को फ़िल्टर करें',
          action: 'बीकर को खींचें (DRAG) और मिश्रण को फ़िल्टर फ़नल में डालें।',
          observation:
              'निस्पंदन (Filtration) ठोस अवशेषों को छानकर रंगीन सूचक विलयन को अलग करता है।',
        ),
        LabStep(
          concept: 'नींबू के रस (अम्ल) का परीक्षण करें',
          action: 'ड्रॉपर को सूचक तक खींचें (DRAG), फिर इसे नींबू के रस वाली टेस्ट ट्यूब तक खींचें।',
          observation:
              'अम्ल जलीय घोल में H⁺ आयन छोड़ते हैं। अम्ल की उपस्थिति में लाल गुलाब सूचक मैजेंटा/लाल रंग में बदल जाता है।',
        ),
        LabStep(
          concept: 'साबुन के घोल (क्षारक) का परीक्षण करें',
          action: 'ड्रॉपर को सूचक तक खींचें (DRAG), फिर इसे साबुन के घोल वाली टेस्ट ट्यूब तक खींचें।',
          observation:
              'क्षारक OH⁻ आयन छोड़ते हैं। सूचक क्षारक के साथ प्रतिक्रिया करके अपनी आणविक संरचना बदलता है, जिससे हरा रंग बनता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'हल्दी सूचक पेपर तैयार करें और अम्लीय, क्षारीय और उदासीन विलयनों के बीच अंतर करने के लिए इसका उपयोग करें।',
      steps: [
        LabStep(
          concept: 'हल्दी पाउडर',
          action: 'हल्दी पाउडर को पेट्री डिश में रखने के लिए चम्मच को खींचें (DRAG)।',
          observation: 'हल्दी में करक्यूमिन होता है, एक रसायन जो pH सूचक के रूप में कार्य करता है।',
        ),
        LabStep(
          concept: 'पेस्ट बनाएं',
          action: 'पेस्ट बनाने के लिए पानी के ड्रॉपर को पेट्री डिश में खींचें (DRAG)।',
          observation: 'पानी मिलाने से एक पेस्ट बन जाता है, जिससे इसे कागज पर लगाना आसान हो जाता है।',
        ),
        LabStep(
          concept: 'पेपर तैयार करें',
          action:
              'भिगोने के लिए फ़िल्टर पेपर को पेट्री डिश में खींचें (DRAG)। फिर स्क्रीन पर Dry (सुखाएं) बटन पर CLICK करें।',
          observation: 'फ़िल्टर पेपर हल्दी के पेस्ट को सोख लेता है, सूखने पर सूचक स्ट्रिप्स बनाता है।',
        ),
        LabStep(
          concept: 'स्ट्रिप्स काटें',
          action: 'सूखे कागज को 3 स्ट्रिप्स में काटने के लिए कैंची को खींचें (DRAG)।',
          observation:
              'बिना संदूषण के विभिन्न पदार्थों का परीक्षण करने के लिए हमें अलग-अलग स्ट्रिप्स की आवश्यकता है।',
        ),
        LabStep(
          concept: 'साबुन के घोल (क्षारक) का परीक्षण करें',
          action: 'साबुन के ड्रॉपर को स्ट्रिप 1 तक खींचें (DRAG)।',
          observation:
              'क्षारीय परिस्थितियों (pH > 7.4) में करक्यूमिन पीले से गहरे लाल-भूरे रंग में बदल जाता है।',
        ),
        LabStep(
          concept: 'नींबू के रस (अम्ल) का परीक्षण करें',
          action: 'नींबू के ड्रॉपर को स्ट्रिप 2 तक खींचें (DRAG)।',
          observation:
              'अम्लीय परिस्थितियों में करक्यूमिन पीला ही रहता है। कोई दृश्यमान रंग परिवर्तन नहीं होता है।',
        ),
        LabStep(
          concept: 'चीनी के घोल (उदासीन) का परीक्षण करें',
          action: 'चीनी के ड्रॉपर को स्ट्रिप 3 तक खींचें (DRAG)।',
          observation:
              'उदासीन पदार्थ करक्यूमिन में रंग परिवर्तन का कारण बनने के लिए pH को पर्याप्त रूप से प्रभावित नहीं करते हैं।',
        ),
      ],
    ),
  ],
};

// ======================================================== SCENE MODEL
// World coordinates follow the HTML Three.js scene (x right, y up, z
// towards the viewer). A virtual perspective camera (target, pitch,
// distance) reproduces the HTML camera moves (overview, focus on the
// mortar / beaker / indicator tube).

const Size _design = Size(1000, 600);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  _V3 up(double dy) => _V3(x, y + dy, z);
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  double distXZ(_V3 o) => math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));
  static _V3 lerp(_V3 a, _V3 b, double t) =>
      _V3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
}

/// A tweenable number (TWEEN.js stand-in driven by the scene clock).
class _Val {
  _Val(this.v);
  double v;
  double _from = 0, _t0 = 0, _dur = 0;
  Curve _curve = Curves.linear;

  double at(double t) {
    if (_dur <= 0) return v;
    final u = ((t - _t0) / _dur).clamp(0.0, 1.0);
    return _from + (v - _from) * _curve.transform(u);
  }

  void to(double target, double now, double dur, [Curve curve = Curves.linear]) {
    _from = at(now);
    v = target;
    _t0 = now;
    _dur = dur;
    _curve = curve;
  }

  void set(double value) {
    v = value;
    _dur = 0;
  }
}

class _Pos {
  _Pos(this.v);
  _V3 v;
  _V3 _from = const _V3(0, 0, 0);
  double _t0 = 0, _dur = 0;
  Curve _curve = Curves.linear;

  _V3 at(double t) {
    if (_dur <= 0) return v;
    final u = ((t - _t0) / _dur).clamp(0.0, 1.0);
    return _V3.lerp(_from, v, _curve.transform(u));
  }

  bool moving(double t) => _dur > 0 && t < _t0 + _dur;

  void to(_V3 target, double now, double dur, [Curve curve = Curves.linear]) {
    _from = at(now);
    v = target;
    _t0 = now;
    _dur = dur;
    _curve = curve;
  }

  void set(_V3 value) {
    v = value;
    _dur = 0;
  }
}

class _Col {
  _Col(this.v);
  Color v;
  Color _from = Colors.transparent;
  double _t0 = 0, _dur = 0;

  Color at(double t) {
    if (_dur <= 0) return v;
    final u = ((t - _t0) / _dur).clamp(0.0, 1.0);
    return Color.lerp(_from, v, u)!;
  }

  void to(Color target, double now, double dur) {
    _from = at(now);
    v = target;
    _t0 = now;
    _dur = dur;
  }

  void set(Color c) {
    v = c;
    _dur = 0;
  }
}

/// Per-frame camera snapshot: projection and ground-plane unprojection.
class _View {
  _View(this.tx, this.ty, this.tz, double pitch, double dist, this.c)
      : cp = math.cos(pitch),
        sp = math.sin(pitch),
        s = _Cam.focal / dist,
        d = _Cam.focal;
  final double tx, ty, tz, cp, sp, s, d;
  final Offset c;

  /// Design position and pixels per world unit at that depth.
  ({Offset p, double k}) project(double x, double y, double z) {
    final rx = x - tx, ry = y - ty, rz = z - tz;
    final y2 = ry * cp - rz * sp;
    final z2 = ry * sp + rz * cp;
    final k = d / (d - z2 * s);
    return (p: Offset(c.dx + rx * s * k, c.dy - y2 * s * k), k: s * k);
  }

  ({Offset p, double k}) pv(_V3 v) => project(v.x, v.y, v.z);

  /// World (x, z) on the horizontal plane y = [planeY] under [screen].
  _V3? unproject(Offset screen, double planeY) {
    final ry = planeY - ty;
    final a = (c.dy - screen.dy) / s;
    final den = sp * d - a * s * cp;
    if (den.abs() < 1e-6) return null;
    final rz = (ry * cp * d - a * d + a * s * ry * sp) / den;
    final z2 = ry * sp + rz * cp;
    final k = d / (d - z2 * s);
    if (k <= 0 || k > 8) return null;
    final rx = (screen.dx - c.dx) / (s * k);
    return _V3(rx + tx, planeY, rz + tz);
  }
}

/// Animated virtual camera (HTML `camera` + `controls.target` tweens).
class _Cam {
  static const double focal = 58 * 13.42;
  final _Val tx = _Val(0.3), ty = _Val(0.9), tz = _Val(1.6);
  final _Val pitch = _Val(0.4636), dist = _Val(13.42);
  final _Val cx = _Val(490), cy = _Val(292);

  _View view(double t) =>
      _View(tx.at(t), ty.at(t), tz.at(t), pitch.at(t), dist.at(t), Offset(cx.at(t), cy.at(t)));

  /// Moves the camera to look at [target] from [offset] (HTML positions).
  void focus(_V3 target, _V3 offset, double now, double dur, [Curve curve = Curves.linear]) {
    tx.to(target.x, now, dur, curve);
    ty.to(target.y, now, dur, curve);
    tz.to(target.z, now, dur, curve);
    pitch.to(math.atan2(offset.y, offset.z), now, dur, curve);
    dist.to(math.sqrt(offset.y * offset.y + offset.z * offset.z), now, dur, curve);
    cx.to(500, now, dur, curve);
    cy.to(300, now, dur, curve);
  }

  /// HTML `recenterCamera()`: the overview of the whole bench.
  void overview(double now, {double dur = 1.0}) {
    tx.to(0.3, now, dur, Curves.easeOutCubic);
    ty.to(0.9, now, dur, Curves.easeOutCubic);
    tz.to(1.6, now, dur, Curves.easeOutCubic);
    pitch.to(0.4636, now, dur, Curves.easeOutCubic);
    dist.to(13.42, now, dur, Curves.easeOutCubic);
    cx.to(490, now, dur, Curves.easeOutCubic);
    cy.to(292, now, dur, Curves.easeOutCubic);
  }
}

/// World-space pick box of an object (relative to its position).
@immutable
class _Hit {
  const _Hit(this.rx, this.y0, this.y1, {double? rz, this.dx = 0}) : rz = rz ?? rx;
  final double rx, rz, y0, y1, dx;
}

class _Obj {
  _Obj(this.id, _V3 home,
      {this.labelKey, this.labelDy = 1, this.clickable = false, this.hit = const _Hit(0.5, 0, 1)})
      : home = home,
        pos = _Pos(home);

  final String id;
  _V3 home;
  final _Pos pos;

  /// Three.js `rotation.z` (radians, counter-clockwise from the front).
  final _Val rot = _Val(0);
  final _Val scale = _Val(1);
  bool visible = true;
  bool dragging = false;
  final String? labelKey;
  final double labelDy;
  final bool clickable;
  final _Hit hit;
}

/// A falling droplet (drips from the funnel, drops from droppers).
class _Drip {
  _Drip(this.from, this.to, this.color, this.t0, {this.dur = 0.2});
  final _V3 from, to;
  final Color color;
  final double t0, dur;
}

/// A pouring stream from a container lip down to a point.
class _Stream {
  _Stream(this.sourceId, this.to, this.color, {this.width = 0.1});
  final String sourceId;
  final _V3 to;
  final Color color;
  final double width;
}

// HTML `Mats` colours.
const Color _cGlass = Color(0xFFCCDDFF);
const Color _cMortar = Color(0xFF4A6B53);
const Color _cWoodLight = Color(0xFFA38062);
const Color _cWoodDark = Color(0xFF8B654A);
const Color _cKettle = Color(0xFFF4B41A);
const Color _cKettleOrange = Color(0xFFD95A20);
const Color _cPlasticDark = Color(0xFF222222);
const Color _cPlasticWhite = Color(0xFFEEEEEE);
const Color _cRed = Color(0xFFFF1155);
const Color _cMagenta = Color(0xFFFF00FF);
const Color _cGreen = Color(0xFF00FF44);
const Color _cYellow = Color(0xFFFFDD00);
const Color _cWater = Color(0xFFDDF0FF);
const Color _cSoap = Color(0xFFEEEEFF);
const Color _cMetal = Color(0xFFCCCCCC);
const Color _cRose = Color(0xFFD31145);
const Color _cRoseCrushed = Color(0xFF8B0000);
const Color _cTurmeric = Color(0xFFEAB308);
const Color _cPaste = Color(0xFFC2410C);
const Color _cSpotRed = Color(0xFF7F1D1D);
const Color _cSpotWet = Color(0xFFCA8A04);

class _Scene {
  double time = 0;
  int scenario = 0;
  final _Cam cam = _Cam();
  final Map<String, _Obj> objs = {};
  _Obj o(String id) => objs[id]!;

  // Scenario 1 (red rose) state.
  bool petalsCrushed = false;
  bool pasteInBeaker = false;
  bool beakerLiquid = false;
  final _Val beakerLevel = _Val(0);
  final _Col beakerColor = _Col(_cWater);
  bool particles = false;
  double particlesT0 = -10;
  bool indLiquid = false;
  final _Val indLevel = _Val(0);
  final _Col lemonColor = _Col(_cYellow);
  final _Col soapColor = _Col(_cSoap);
  bool acidicLabel = false, basicLabel = false;
  bool dropperLiquid = false;
  int seqPhase = 0;
  double pestleT0 = -10;

  // Scenario 2 (turmeric) state.
  bool spoonPowder = false;
  int petri = 0; // 0 empty, 1 powder, 2 paste
  int paper = 0; // 0 white, 1 soaked, 2 dry, 3 cut into strips
  bool spot1 = false;
  double spot2T0 = -10, spot3T0 = -10;
  bool tested2 = false, tested3 = false;
  double snipT0 = -10;

  // Shared effects.
  _Stream? stream;
  final List<_Drip> drips = [];
  _Obj? dragging;

  _View view() => cam.view(time);

  void _add(_Obj obj) => objs[obj.id] = obj;

  /// HTML `buildScenario1()` / `buildScenario2()`.
  void build(int s) {
    scenario = s;
    objs.clear();
    petalsCrushed = pasteInBeaker = beakerLiquid = particles = false;
    indLiquid = acidicLabel = basicLabel = dropperLiquid = false;
    beakerLevel.set(0);
    beakerColor.set(_cWater);
    indLevel.set(0);
    lemonColor.set(_cYellow);
    soapColor.set(_cSoap);
    seqPhase = 0;
    pestleT0 = particlesT0 = -10;
    spoonPowder = spot1 = tested2 = tested3 = false;
    petri = paper = 0;
    spot2T0 = spot3T0 = snipT0 = -10;
    stream = null;
    drips.clear();
    dragging = null;
    if (s == 0) {
      _add(_Obj('bowl', const _V3(-5.5, 0, 2.5)));
      _add(_Obj('petals', const _V3(-5.5, 0.3, 2.5),
          labelKey: 'lblBowlPetals', labelDy: 1.5, clickable: true, hit: const _Hit(0.8, -0.3, 0.6)));
      _add(_Obj('kettle', const _V3(-4.0, 0, -1.0),
          labelKey: 'lblKettle', labelDy: 3, clickable: true, hit: const _Hit(1.4, 0, 2.2)));
      _add(_Obj('mortar', const _V3(-2.0, 0, 2.0), labelKey: 'lblMortar', labelDy: 2));
      _add(_Obj('pestle', const _V3(-0.5, 0, 3.5),
          labelKey: 'lblPestle', labelDy: 2.7, clickable: true, hit: const _Hit(0.55, 0, 2.45)));
      _add(_Obj('beaker', const _V3(0.5, 0, 1.5),
          labelKey: 'lblBeaker', labelDy: 3, clickable: true, hit: const _Hit(1.2, 0, 2.5)));
      _add(_Obj('funnel', const _V3(2.0, 0.6, 3.5),
          labelKey: 'lblFunnel', labelDy: 2, clickable: true, hit: const _Hit(0.85, -0.6, 0.9)));
      _add(_Obj('rack', const _V3(4.8, 0, 0.5)));
      _add(_Obj('ttInd', const _V3(3.6, 0.2, 0.5), labelKey: 'lblInd', labelDy: 3.5));
      _add(_Obj('ttLemon', const _V3(4.8, 0.2, 0.5), labelKey: 'lblLemon', labelDy: 4.0));
      _add(_Obj('ttSoap', const _V3(6.0, 0.2, 0.5), labelKey: 'lblSoap', labelDy: 3.5));
      _add(_Obj('dropper', const _V3(3.0, 0, 2.5),
          labelKey: 'lblDropper', labelDy: 2, clickable: true, hit: const _Hit(0.4, 0, 1.85)));
    } else {
      _add(_Obj('tBox', const _V3(-5.0, 0.5, 1.5)));
      _add(_Obj('tPowder', const _V3(-5.0, 1.05, 1.5), labelKey: 'lblTurmeric', labelDy: 1.5));
      _add(_Obj('spoon', const _V3(-5.0, 0.2, 3.0),
          labelKey: 'lblSpoon', labelDy: 0.8, clickable: true,
          hit: const _Hit(1.4, -0.2, 0.35, rz: 0.4, dx: 0.75)));
      _add(_Obj('petri', const _V3(-2.0, 0.15, 2.0), labelKey: 'lblPetri', labelDy: 1.5));
      _add(_Obj('dropW', const _V3(-4.0, 0, 0.5),
          labelKey: 'lblWater', labelDy: 2, clickable: true, hit: const _Hit(0.4, 0, 1.85)));
      _add(_Obj('paper', const _V3(-1.0, 0.02, 4.0),
          labelKey: 'lblPaper', labelDy: 1.5, clickable: true, hit: const _Hit(1.0, -0.1, 0.3)));
      _add(_Obj('scissors', const _V3(1.0, 0.1, 4.0),
          labelKey: 'lblScissors', labelDy: 1.5, clickable: true,
          hit: const _Hit(0.85, -0.1, 0.25, rz: 0.4, dx: 0.35)));
      _add(_Obj('dropS', const _V3(2.5, 0, 1.0),
          labelKey: 'lblSoapBase', labelDy: 2, clickable: true, hit: const _Hit(0.4, 0, 1.85)));
      _add(_Obj('dropL', const _V3(4.5, 0, 1.0),
          labelKey: 'lblLemonAcid', labelDy: 2, clickable: true, hit: const _Hit(0.4, 0, 1.85)));
      _add(_Obj('dropSug', const _V3(6.5, 0, 1.0),
          labelKey: 'lblSugarNeutral', labelDy: 2, clickable: true, hit: const _Hit(0.4, 0, 1.85)));
      for (var i = 1; i <= 3; i++) {
        _add(_Obj('st$i', _V3(0.5 + 2.0 * i, 0.02, 3.0))..visible = false);
      }
    }
  }

  /// Screen bounds of an object's pick box: its silhouette in the plane
  /// through its centre, widened by the depth ellipse.
  Rect bounds(_Obj obj, _View v) {
    final p = obj.pos.at(time);
    final h = obj.hit;
    final a = v.project(p.x + h.dx - h.rx, p.y + h.y1, p.z);
    final b = v.project(p.x + h.dx + h.rx, p.y + h.y0, p.z);
    final ry = h.rz * a.k * v.sp;
    return Rect.fromLTRB(
      math.min(a.p.dx, b.p.dx),
      math.min(a.p.dy, b.p.dy) - ry,
      math.max(a.p.dx, b.p.dx),
      math.max(a.p.dy, b.p.dy) + ry,
    );
  }
}

// ============================================================ PAINTING

/// Local drawing frame of an object: origin = projected world position,
/// `k` pixels per unit; heights are foreshortened by the camera pitch.
class _F {
  _F(this.o, this.k, this.cp, this.sp);
  final Offset o;
  final double k, cp, sp;

  Offset p(double x, double y, [double z = 0]) => o + Offset(x * k, -y * k * cp + z * k * sp);

  /// Horizontal circle of radius [r] at height [y] (centre x, z).
  Rect ell(double y, double r, {double x = 0, double z = 0}) =>
      Rect.fromCenter(center: p(x, y, z), width: 2 * r * k, height: 2 * r * k * sp);
}

/// Deterministic pseudo random numbers (stable petal / chunk layouts).
double _rnd(int i, int salt) {
  final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
    required this.lang,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> labels;
  final String lang;

  late _View _v;
  double get t => scene.time;

  _F _frame(_V3 p) {
    final pr = _v.pv(p);
    return _F(pr.p, pr.k, _v.cp, _v.sp);
  }

  _F _objFrame(_Obj o) => _frame(o.pos.at(t));

  @override
  void paint(Canvas canvas, Size size) {
    _v = scene.view();
    _paintRoom(canvas, size);
    final items = <(double, void Function())>[];
    for (final o in scene.objs.values) {
      if (!o.visible || o.dragging) continue;
      final p = o.pos.at(t);
      var z = p.z;
      if (o.id == 'rack') z -= 0.02;
      if (o.id == 'funnel' || o.id == 'paper') z += 0.02;
      if (o.pos.moving(t) || o.rot.at(t) != 0) z += 0.3;
      if (o.id == 'bowl') {
        items.add((z - 0.01, () => _bowl(canvas, o, back: true)));
        items.add((z + 0.01, () => _bowl(canvas, o, back: false)));
        continue;
      }
      items.add((z, () => _drawObj(canvas, o)));
    }
    items.sort((a, b) => a.$1.compareTo(b.$1));
    for (final it in items) {
      it.$2();
    }
    _paintStream(canvas);
    final d = scene.dragging;
    if (d != null) _drawObj(canvas, d, lifted: true);
    _paintDrips(canvas);
    if (showLabels) _paintLabels(canvas);
  }

  void _drawObj(Canvas canvas, _Obj o, {bool lifted = false}) {
    if (lifted) {
      final p = o.pos.at(t);
      final g = _v.project(p.x + o.hit.dx, 0.01, p.z);
      labGroundShadow(canvas, g.p, o.hit.rx * 2.2 * g.k, o.hit.rz * 1.2 * g.k * _v.sp + 6,
          opacity: 0.35);
    }
    switch (o.id) {
      case 'petals':
        if (!_petalsInMortar || lifted) _petals(canvas, _objFrame(o), o.scale.at(t));
      case 'kettle':
        _kettle(canvas, o);
      case 'mortar':
        _mortar(canvas, o);
      case 'pestle':
        if (!_pestleOverMortar || lifted) _pestle(canvas, _objFrame(o));
      case 'beaker':
        _beaker(canvas, o);
      case 'funnel':
        _funnel(canvas, _objFrame(o));
      case 'rack':
        _rack(canvas, o);
      case 'ttInd':
        _tube(canvas, o, _cRed, scene.indLiquid ? scene.indLevel.at(t) : 0, 0.85);
      case 'ttLemon':
        _tube(canvas, o, scene.lemonColor.at(t), 0.9, 0.85);
      case 'ttSoap':
        _tube(canvas, o, scene.soapColor.at(t), 0.9, 0.8);
      case 'dropper':
        _dropper(canvas, o, scene.dropperLiquid ? _cRed : null);
      case 'dropW':
        _dropper(canvas, o, _cWater);
      case 'dropS':
        _dropper(canvas, o, _cSoap);
      case 'dropL':
        _dropper(canvas, o, _cYellow);
      case 'dropSug':
        _dropper(canvas, o, null);
      case 'tBox':
        _turmericBox(canvas, o);
      case 'tPowder':
        break; // drawn with the box
      case 'spoon':
        _spoon(canvas, o);
      case 'petri':
        _petri(canvas, o);
      case 'paper':
        _paper(canvas, o);
      case 'scissors':
        _scissors(canvas, o);
      default:
        if (o.id.startsWith('st')) _strip(canvas, o);
    }
  }

  bool get _petalsInMortar {
    final p = scene.objs['petals'];
    final m = scene.objs['mortar'];
    if (p == null || m == null || !p.visible || p.dragging || p.pos.moving(t)) return false;
    return p.pos.at(t).distXZ(m.home) < 0.3;
  }

  bool get _pestleOverMortar {
    final p = scene.objs['pestle'];
    final m = scene.objs['mortar'];
    if (p == null || m == null || p.dragging) return false;
    return p.pos.at(t).distXZ(m.home) < 0.6;
  }

  // -------------------------------------------------------------- room

  void _paintRoom(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF020617), Color(0xFF0F172A)]
              : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    // Lab bench 30 x 15 (top at y = 0) in dark wood 0x3d2817.
    Path quad(List<Offset> q) => Path()..addPolygon(q, true);
    const bench = Color(0xFF3D2817);
    final top = quad([
      _v.project(-15, 0, -7.5).p,
      _v.project(15, 0, -7.5).p,
      _v.project(15, 0, 7.5).p,
      _v.project(-15, 0, 7.5).p,
    ]);
    final tb = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(bench, -0.25), labShade(bench, 0.12)],
        ).createShader(tb),
    );
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var z = -7.0; z <= 7.5; z += 0.7) {
      canvas.drawLine(_v.project(-15, 0, z).p, _v.project(15, 0, z).p, grain);
    }
    final fl = _v.project(-15, 0, 7.5).p, fr = _v.project(15, 0, 7.5).p;
    final fbl = _v.project(-15, -0.5, 7.5).p, fbr = _v.project(15, -0.5, 7.5).p;
    canvas.drawPath(quad([fl, fr, fbr, fbl]), Paint()..color = labShade(bench, -0.45));
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, math.max(fbl.dy, fbr.dy), bleed.right, bleed.bottom),
      Paint()..color = isDark ? const Color(0xFF020617) : const Color(0xFFCBD5E1),
    );
    // Dark lab mat 20 x 10 (matGrid 0x222222) with a faint grid.
    final mat = quad([
      _v.project(-10, 0.01, -5).p,
      _v.project(10, 0.01, -5).p,
      _v.project(10, 0.01, 5).p,
      _v.project(-10, 0.01, 5).p,
    ]);
    canvas.drawPath(mat, Paint()..color = const Color(0xFF222222));
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = -10.0; x <= 10; x += 1) {
      canvas.drawLine(_v.project(x, 0.01, -5).p, _v.project(x, 0.01, 5).p, grid);
    }
    for (var z = -5.0; z <= 5; z += 1) {
      canvas.drawLine(_v.project(-10, 0.01, z).p, _v.project(10, 0.01, z).p, grid);
    }
    canvas.drawPath(
      mat,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  // -------------------------------------------------------- primitives

  Paint get _edge => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeJoin = StrokeJoin.round
    ..color = Colors.black.withValues(alpha: 0.45);

  Path _frustumPath(_F f, double y0, double r0, double y1, double r1) => Path()
    ..moveTo(f.p(-r0, y0).dx, f.p(-r0, y0).dy)
    ..lineTo(f.p(-r1, y1).dx, f.p(-r1, y1).dy)
    ..lineTo(f.p(r1, y1).dx, f.p(r1, y1).dy)
    ..lineTo(f.p(r0, y0).dx, f.p(r0, y0).dy)
    ..arcTo(f.ell(y0, r0), 0, math.pi, false)
    ..close();

  /// Solid vertical frustum (cylinder / cone) with a lit top cap.
  void _solid(Canvas canvas, _F f, double y0, double r0, double y1, double r1, Color c,
      {bool cap = true, double opacity = 1, bool outline = true}) {
    Color a(Color x) => x.withValues(alpha: x.a * opacity);
    final side = _frustumPath(f, y0, r0, y1, r1);
    final b = side.getBounds();
    canvas.drawPath(
      side,
      Paint()
        ..shader = LinearGradient(colors: [
          a(labShade(c, -0.35)),
          a(labShade(c, 0.22)),
          a(c),
          a(labShade(c, -0.45)),
        ], stops: const [0, 0.3, 0.62, 1]).createShader(b),
    );
    if (outline) canvas.drawPath(side, _edge);
    if (cap && r1 > 0) {
      final top = f.ell(y1, r1);
      canvas.drawOval(top, Paint()..color = a(labShade(c, 0.18)));
      if (outline) canvas.drawOval(top, _edge);
    }
  }

  /// Transparent glass vessel wall (open top).
  void _glass(Canvas canvas, _F f, double y0, double y1, double r, {bool roundBottom = false}) {
    final side = roundBottom
        ? (Path()
          ..moveTo(f.p(-r, y1).dx, f.p(-r, y1).dy)
          ..lineTo(f.p(-r, y0).dx, f.p(-r, y0).dy)
          ..arcToPoint(f.p(r, y0), radius: Radius.circular(r * f.k), clockwise: false)
          ..lineTo(f.p(r, y1).dx, f.p(r, y1).dy))
        : (Path()
          ..moveTo(f.p(-r, y1).dx, f.p(-r, y1).dy)
          ..lineTo(f.p(-r, y0).dx, f.p(-r, y0).dy)
          ..arcTo(f.ell(y0, r), math.pi, -math.pi, false)
          ..lineTo(f.p(r, y1).dx, f.p(r, y1).dy));
    canvas.drawPath(side, Paint()..color = _cGlass.withValues(alpha: 0.16));
    canvas.drawPath(
      side,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = _cGlass.withValues(alpha: 0.85),
    );
    final rim = f.ell(y1, r);
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.drawLine(
      f.p(-r * 0.6, y1 - (y1 - y0) * 0.1),
      f.p(-r * 0.6, y0 + (y1 - y0) * 0.12),
      Paint()
        ..strokeWidth = math.max(2, r * f.k * 0.12)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  /// Liquid column inside a vessel (flat or round bottom).
  void _liquid(Canvas canvas, _F f, double y0, double h, double r, Color c, double alpha,
      {bool roundBottom = false}) {
    if (h <= 0.001) return;
    final y1 = y0 + h;
    final col = c.withValues(alpha: alpha);
    final path = roundBottom
        ? (Path()
          ..moveTo(f.p(-r, y1).dx, f.p(-r, y1).dy)
          ..lineTo(f.p(-r, y0).dx, f.p(-r, y0).dy)
          ..arcToPoint(f.p(r, y0), radius: Radius.circular(r * f.k), clockwise: false)
          ..lineTo(f.p(r, y1).dx, f.p(r, y1).dy)
          ..close())
        : _frustumPath(f, y0, r, y1, r);
    final b = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(col, -0.2),
          labShade(col, 0.15),
          col,
          labShade(col, -0.3),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(b),
    );
    canvas.drawOval(f.ell(y1, r), Paint()..color = labShade(col, 0.25));
  }

  Offset _rotAround(Offset p, Offset c, double a) {
    final d = p - c;
    return c + Offset(d.dx * math.cos(a) - d.dy * math.sin(a), d.dx * math.sin(a) + d.dy * math.cos(a));
  }

  // ----------------------------------------------------- scenario 1

  /// Glass bowl (lower hemisphere r 1.2) holding the petals.
  void _bowl(Canvas canvas, _Obj o, {required bool back}) {
    final f = _objFrame(o);
    const r = 1.2;
    final c = f.p(0, r);
    final circle = Rect.fromCircle(center: c, radius: r * f.k);
    final rim = f.ell(r, r);
    final body = Path()
      ..moveTo(circle.left, c.dy)
      ..arcTo(circle, math.pi, -math.pi, false)
      ..close();
    if (back) {
      labGroundShadow(canvas, f.p(0, 0), r * 1.6 * f.k, 0.5 * f.k, opacity: 0.35);
      canvas.drawPath(body, Paint()..color = _cGlass.withValues(alpha: 0.14));
      canvas.drawOval(rim, Paint()..color = _cGlass.withValues(alpha: 0.12));
      return;
    }
    canvas.drawPath(
      Path()
        ..moveTo(circle.left, c.dy)
        ..arcTo(circle, math.pi, -math.pi, false),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _cGlass.withValues(alpha: 0.8),
    );
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawArc(
      circle.deflate(r * f.k * 0.18),
      math.pi * 0.62,
      math.pi * 0.25,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  /// 15 rose petals (scaled spheres); crushed = small dark-red bits.
  void _petals(Canvas canvas, _F f, double s) {
    final crushed = scene.petalsCrushed;
    for (var i = 0; i < 15; i++) {
      final at = f.p((_rnd(i, 1) - 0.5) * 0.8 * s, (_rnd(i, 2) - 0.5) * 0.3 * s, (_rnd(i, 3) - 0.5) * 0.8 * s);
      final w = (crushed ? 0.11 : 0.26) * f.k * s;
      final h = (crushed ? 0.09 : 0.32) * f.k * s * (0.45 + 0.55 * _rnd(i, 4));
      final rect = Rect.fromCenter(center: Offset.zero, width: w * 2, height: h * 2);
      final color = crushed ? _cRoseCrushed : _cRose;
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(_rnd(i, 5) * math.pi);
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [labShade(color, 0.3), color, labShade(color, -0.4)],
          ).createShader(rect),
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.55).withValues(alpha: 0.7),
      );
      canvas.restore();
    }
  }

  /// Kettle spout tip (design space) for the pouring stream.
  Offset _kettleSpout(_Obj o) {
    final f = _objFrame(o);
    return _rotAround(f.p(1.82, 1.32), f.o, -o.rot.at(t));
  }

  void _kettle(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final a = -o.rot.at(t);
    if (a == 0) labGroundShadow(canvas, f.p(0, 0), 3.2 * f.k, 0.9 * f.k * f.sp + 6, opacity: 0.35);
    canvas.save();
    canvas.translate(f.o.dx, f.o.dy);
    canvas.rotate(a);
    canvas.translate(-f.o.dx, -f.o.dy);
    // Handle: half torus (r 1.0) over the lid.
    final handle = Path();
    for (var i = 0; i <= 24; i++) {
      final th = math.pi * i / 24;
      final q = f.p(math.cos(th), 1.8 + math.sin(th));
      i == 0 ? handle.moveTo(q.dx, q.dy) : handle.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.12 * f.k
        ..strokeCap = StrokeCap.round
        ..color = _cWoodDark,
    );
    // Spout (orange cone, tilted 60°).
    final b0 = f.p(0.78, 0.7), b1 = f.p(1.82, 1.32);
    final dir = (b1 - b0) / (b1 - b0).distance;
    final n = Offset(-dir.dy, dir.dx);
    canvas.drawPath(
      Path()
        ..addPolygon([b0 + n * 0.3 * f.k, b1 + n * 0.1 * f.k, b1 - n * 0.1 * f.k, b0 - n * 0.3 * f.k], true),
      Paint()..color = _cKettleOrange,
    );
    canvas.drawCircle(b1, 0.1 * f.k, Paint()..color = labShade(_cKettleOrange, -0.4));
    _solid(canvas, f, 0, 1.4, 1.8, 0.7, _cKettle);
    _solid(canvas, f, 1.8, 0.75, 1.9, 0.75, _cKettleOrange);
    _solid(canvas, f, 1.85, 0.15, 2.15, 0.15, _cWoodDark);
    canvas.restore();
  }

  void _mortar(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    labGroundShadow(canvas, f.p(0, 0), 2.4 * f.k, 0.8 * f.k * f.sp + 6, opacity: 0.4);
    _solid(canvas, f, 0, 0.9, 1.2, 1.5, _cMortar, cap: false);
    final opening = f.ell(1.2, 1.45);
    canvas.drawOval(
      opening,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          colors: [labShade(_cMortar, -0.55), labShade(_cMortar, -0.25)],
        ).createShader(opening),
    );
    final rimRect = f.ell(1.2, 1.5);
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.22 * f.k * f.sp + 3
      ..color = labShade(_cMortar, 0.15);
    canvas.drawArc(rimRect, math.pi, math.pi, false, rimPaint);
    // Contents seen through the opening (petals, pestle head).
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(opening)
      ..addRect(Rect.fromLTRB(-1e4, -1e4, 1e4, opening.center.dy)));
    if (_petalsInMortar) _petals(canvas, _frame(scene.o('petals').pos.at(t)), scene.o('petals').scale.at(t));
    if (_pestleOverMortar) _pestle(canvas, _objFrame(scene.o('pestle')));
    canvas.restore();
    canvas.drawArc(rimRect, 0, math.pi, false, rimPaint);
    canvas.drawOval(rimRect.inflate(rimPaint.strokeWidth / 2), _edge);
  }

  void _pestle(Canvas canvas, _F f) {
    labSphere(canvas, f.p(0, 0.4), 0.5 * f.k, _cWoodLight);
    _solid(canvas, f, 0.3, 0.35, 2.1, 0.15, _cWoodLight, cap: false);
    labSphere(canvas, f.p(0, 2.1), 0.35 * f.k, labShade(_cWoodLight, 0.05));
  }

  /// Beaker lip (right rim point) in design space, for the pour stream.
  Offset _beakerLip(_Obj o) {
    final f = _objFrame(o);
    return _rotAround(f.p(1.2, 2.5), f.o, -o.rot.at(t));
  }

  void _beaker(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final a = -o.rot.at(t);
    if (a == 0) labGroundShadow(canvas, f.p(0, 0), 2.6 * f.k, 0.9 * f.k * f.sp + 6, opacity: 0.3);
    canvas.save();
    canvas.translate(f.o.dx, f.o.dy);
    canvas.rotate(a);
    canvas.translate(-f.o.dx, -f.o.dy);
    canvas.drawOval(f.ell(2.5, 1.2), Paint()..color = _cGlass.withValues(alpha: 0.1));
    if (scene.pasteInBeaker) {
      for (var i = 0; i < 35; i++) {
        final r = _rnd(i, 11) * 0.9, th = _rnd(i, 12) * math.pi * 2;
        final at = f.p(r * math.cos(th), 0.1 + _rnd(i, 13) * 0.2, r * math.sin(th));
        final s = 0.15 * f.k;
        final path = Path();
        for (var j = 0; j < 5; j++) {
          final an = j * math.pi * 2 / 5 + _rnd(i, 14) * 2;
          final q = at + Offset(math.cos(an) * s, math.sin(an) * s * 0.8);
          j == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
        }
        path.close();
        canvas.drawPath(path, Paint()..color = labShade(_cRoseCrushed, (_rnd(i, 15) - 0.5) * 0.5));
      }
    }
    if (scene.beakerLiquid) {
      final lv = scene.beakerLevel.at(t);
      final c = scene.beakerColor.at(t);
      _liquid(canvas, f, 0.05, 2.0 * lv, 1.15, c, c == _cWater ? 0.55 : 0.8);
    }
    if (scene.particles) {
      final spin = ((t - scene.particlesT0) / 3).clamp(0.0, 1.0) * math.pi * 8;
      for (var i = 0; i < 30; i++) {
        var x = (_rnd(i, 21) - 0.5) * 1.5, z = (_rnd(i, 22) - 0.5) * 1.5;
        final y = 0.2 + _rnd(i, 23) * 1.5;
        final cx = x * math.cos(spin) - z * math.sin(spin);
        z = x * math.sin(spin) + z * math.cos(spin);
        x = cx;
        canvas.drawCircle(
          f.p(x, y, z),
          (_rnd(i, 24) * 0.04 + 0.02) * f.k * 1.4,
          Paint()..color = _cRose,
        );
      }
    }
    _glass(canvas, f, 0, 2.5, 1.2);
    // Graduation marks.
    final tick = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 1; i <= 4; i++) {
      final y = 2.5 * i / 5;
      canvas.drawLine(f.p(0.55, y, 1.2 * 0.8), f.p(0.95, y, 1.2 * 0.6), tick);
    }
    canvas.restore();
  }

  void _funnel(Canvas canvas, _F f) {
    final spout = Rect.fromPoints(f.p(-0.1, 0), f.p(0.1, -0.6));
    canvas.drawRect(spout, Paint()..color = _cGlass.withValues(alpha: 0.35));
    canvas.drawRect(
      spout,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _cGlass.withValues(alpha: 0.85),
    );
    final cone = Path()
      ..moveTo(f.p(-0.8, 0.8).dx, f.p(-0.8, 0.8).dy)
      ..lineTo(f.p(-0.1, 0).dx, f.p(-0.1, 0).dy)
      ..lineTo(f.p(0.1, 0).dx, f.p(0.1, 0).dy)
      ..lineTo(f.p(0.8, 0.8).dx, f.p(0.8, 0.8).dy)
      ..arcTo(f.ell(0.8, 0.8), 0, math.pi, false)
      ..close();
    canvas.drawPath(cone, Paint()..color = _cGlass.withValues(alpha: 0.22));
    // Folded filter paper inside the cone.
    canvas.drawPath(
      Path()
        ..addPolygon([f.p(-0.68, 0.78), f.p(0, 0.12), f.p(0.68, 0.78)], true),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      cone,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _cGlass.withValues(alpha: 0.9),
    );
    canvas.drawOval(
      f.ell(0.8, 0.8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, 0.08 * f.k)
        ..color = _cPlasticWhite,
    );
  }

  /// Box in an object's local frame: front + top faces.
  void _box(Canvas canvas, _F f, double cx, double cy, double cz, double sx, double sy, double sz,
      Color c) {
    final x0 = cx - sx / 2, x1 = cx + sx / 2, y0 = cy - sy / 2, y1 = cy + sy / 2;
    final z0 = cz - sz / 2, z1 = cz + sz / 2;
    final top = Path()..addPolygon([f.p(x0, y1, z0), f.p(x1, y1, z0), f.p(x1, y1, z1), f.p(x0, y1, z1)], true);
    final front = Rect.fromPoints(f.p(x0, y1, z1), f.p(x1, y0, z1));
    canvas.drawPath(top, Paint()..color = labShade(c, 0.15));
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(c, -0.05), labShade(c, -0.25)],
        ).createShader(front),
    );
    canvas.drawPath(top, _edge);
    canvas.drawRect(front, _edge);
  }

  /// Screen band covered by the rack's top board front face.
  Rect? _rackBand() {
    final r = scene.objs['rack'];
    if (r == null) return null;
    final f = _objFrame(r);
    return Rect.fromPoints(f.p(-2, 1.6, 0.75), f.p(2, 1.4, 0.75));
  }

  void _rack(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    labGroundShadow(canvas, f.p(0, 0), 4.4 * f.k, 1.4 * f.k * f.sp + 6, opacity: 0.35);
    _box(canvas, f, 0, 0.1, 0, 4, 0.2, 1.5, _cWoodDark);
    _box(canvas, f, -1.9, 0.8, 0, 0.2, 1.5, 1.5, _cWoodDark);
    _box(canvas, f, 1.9, 0.8, 0, 0.2, 1.5, 1.5, _cWoodDark);
    _box(canvas, f, 0, 1.5, 0, 4, 0.2, 1.5, _cWoodDark);
    for (final x in [-1.2, 0.0, 1.2]) {
      canvas.drawOval(f.ell(1.6, 0.34, x: x), Paint()..color = labShade(_cWoodDark, -0.6));
    }
  }

  void _tube(Canvas canvas, _Obj o, Color liquid, double level, double alpha) {
    final f = _objFrame(o);
    canvas.save();
    final band = _rackBand();
    if (band != null) {
      canvas.clipPath(Path.combine(
        PathOperation.difference,
        Path()..addRect(const Rect.fromLTRB(-1e4, -1e4, 1e4, 1e4)),
        Path()..addRect(band),
      ));
    }
    if (level > 0) {
      _liquid(canvas, f, 0, 0.1 + 2.0 * level, 0.25, liquid, alpha, roundBottom: true);
    }
    _glass(canvas, f, 0, 2.5, 0.3, roundBottom: true);
    canvas.restore();
  }

  void _dropper(Canvas canvas, _Obj o, Color? liquid) {
    final f = _objFrame(o);
    if (!o.pos.moving(t) && !o.dragging) {
      labGroundShadow(canvas, f.p(0, 0), 0.6 * f.k, 0.2 * f.k + 3, opacity: 0.3);
    }
    final tube = Path()
      ..addPolygon([f.p(-0.1, 1.5), f.p(-0.05, 0), f.p(0.05, 0), f.p(0.1, 1.5)], true);
    canvas.drawPath(tube, Paint()..color = _cGlass.withValues(alpha: 0.35));
    if (liquid != null) {
      canvas.drawPath(
        Path()..addPolygon([f.p(-0.08, 1.1), f.p(-0.04, 0.1), f.p(0.04, 0.1), f.p(0.08, 1.1)], true),
        Paint()..color = liquid.withValues(alpha: 0.9),
      );
    }
    canvas.drawPath(
      tube,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = _cGlass.withValues(alpha: 0.95),
    );
    canvas.drawRect(
      Rect.fromCenter(center: f.p(0, 1.32), width: 0.26 * f.k, height: 0.1 * f.k),
      Paint()..color = const Color(0xFF111111),
    );
    labSphere(canvas, f.p(0, 1.5), 0.3 * f.k, _cPlasticDark, highlight: 0.35);
  }

  void _paintStream(Canvas canvas) {
    final s = scene.stream;
    if (s == null) return;
    final src = scene.objs[s.sourceId];
    if (src == null) return;
    final from = s.sourceId == 'kettle' ? _kettleSpout(src) : _beakerLip(src);
    final to = _v.pv(s.to);
    final ctrl = Offset(from.dx + (to.p.dx - from.dx) * 0.6, from.dy);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, to.p.dx, to.p.dy);
    final w = s.width * to.k;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 1.4
        ..color = s.color.withValues(alpha: 0.75),
    );
    labDashedPath(
      canvas,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.2, w * 0.4)
        ..color = Colors.white.withValues(alpha: 0.6),
      dash: 10,
      gap: 14,
      phase: -t * 160,
    );
  }

  void _paintDrips(Canvas canvas) {
    for (final d in scene.drips) {
      final u = (t - d.t0) / d.dur;
      if (u < 0 || u > 1) continue;
      final p = _v.pv(_V3.lerp(d.from, d.to, Curves.easeIn.transform(u)));
      final r = 0.08 * p.k + 1.5;
      final c = p.p;
      final path = Path()
        ..moveTo(c.dx, c.dy - r * 2)
        ..quadraticBezierTo(c.dx + r * 1.2, c.dy - r * 0.2, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - r * 1.2, c.dy - r * 0.2, c.dx, c.dy - r * 2)
        ..close();
      canvas.drawPath(path, Paint()..color = d.color.withValues(alpha: 0.95));
      canvas.drawCircle(c.translate(-r * 0.3, -r * 0.3), r * 0.28, Paint()..color = Colors.white70);
    }
  }

  // ----------------------------------------------------- scenario 2

  void _turmericBox(Canvas canvas, _Obj o) {
    final p = o.pos.at(t);
    final f = _frame(_V3(p.x, 0, p.z));
    labGroundShadow(canvas, f.p(0, 0, 0.3), 1.6 * f.k, 0.6 * f.k * f.sp + 6, opacity: 0.35);
    _box(canvas, f, 0, 0.5, 0, 1.2, 1, 1.2, _cWoodLight);
    _solid(canvas, f, 1.0, 0.4, 1.1, 0.4, _cTurmeric);
    canvas.drawOval(
      f.ell(1.12, 0.22, x: -0.05),
      Paint()..color = labShade(_cTurmeric, 0.25),
    );
  }

  void _spoon(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final a = -o.rot.at(t);
    if (a == 0 && !o.dragging) {
      labGroundShadow(canvas, f.p(0.8, -0.2), 2.6 * f.k, 0.25 * f.k + 4, opacity: 0.3);
    }
    canvas.save();
    canvas.translate(f.o.dx, f.o.dy);
    canvas.rotate(a);
    canvas.translate(-f.o.dx, -f.o.dy);
    canvas.drawLine(
      f.p(0, 0),
      f.p(2, 0),
      Paint()
        ..strokeWidth = 0.1 * f.k + 1
        ..strokeCap = StrokeCap.round
        ..color = labShade(_cMetal, -0.15),
    );
    canvas.drawLine(
      f.p(0.05, 0.02),
      f.p(1.95, 0.02),
      Paint()
        ..strokeWidth = 0.03 * f.k + 0.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    final bowl = Rect.fromCenter(
      center: f.p(-0.2, 0),
      width: 0.9 * f.k,
      height: (0.6 * f.sp + 0.12 * f.cp) * f.k,
    );
    canvas.drawOval(
      bowl,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [Colors.white, _cMetal, labShade(_cMetal, -0.4)],
        ).createShader(bowl),
    );
    canvas.drawOval(bowl, _edge);
    if (scene.spoonPowder) {
      final mound = Rect.fromCenter(
        center: f.p(-0.2, 0.05),
        width: 0.42 * f.k,
        height: (0.4 * f.sp + 0.2 * f.cp) * f.k,
      );
      canvas.drawOval(
        mound,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.5),
            colors: [labShade(_cTurmeric, 0.3), _cTurmeric, labShade(_cTurmeric, -0.3)],
          ).createShader(mound),
      );
    }
    canvas.restore();
  }

  void _petri(Canvas canvas, _Obj o) {
    final p = o.pos.at(t);
    final f = _frame(_V3(p.x, 0, p.z));
    labGroundShadow(canvas, f.p(0, 0), 3.4 * f.k, 1.2 * f.k * f.sp + 4, opacity: 0.25);
    canvas.drawOval(f.ell(0, 1.6), Paint()..color = _cGlass.withValues(alpha: 0.22));
    if (scene.petri > 0) {
      final c = scene.petri == 1 ? _cTurmeric : _cPaste;
      _solid(canvas, f, 0.05, 1.2, 0.15, 1.2, c, outline: false);
      final top = f.ell(0.15, 1.2);
      if (scene.petri == 2) {
        canvas.drawOval(
          top.deflate(top.height * 0.25),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      } else {
        for (var i = 0; i < 26; i++) {
          final r = math.sqrt(_rnd(i, 31)) * 1.1, th = _rnd(i, 32) * math.pi * 2;
          canvas.drawCircle(
            f.p(r * math.cos(th), 0.16, r * math.sin(th)),
            1.4,
            Paint()..color = labShade(_cTurmeric, -0.25),
          );
        }
      }
    }
    final wall = _frustumPath(f, 0, 1.6, 0.3, 1.6);
    canvas.drawPath(wall, Paint()..color = _cGlass.withValues(alpha: 0.18));
    canvas.drawPath(
      wall,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _cGlass.withValues(alpha: 0.8),
    );
    canvas.drawOval(
      f.ell(0.3, 1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _paper(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final quad = Path()
      ..addPolygon([f.p(-1, 0, -1), f.p(1, 0, -1), f.p(1, 0, 1), f.p(-1, 0, 1)], true);
    if (!o.dragging && o.pos.at(t).y < 0.1) {
      canvas.drawPath(
        quad.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    final c = scene.paper == 0 ? _cPlasticWhite : _cTurmeric;
    final b = quad.getBounds();
    canvas.drawPath(
      quad,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: scene.paper == 1
              ? [labShade(c, -0.15), labShade(c, 0.2), labShade(c, -0.2)]
              : [labShade(c, 0.06), c, labShade(c, -0.08)],
        ).createShader(b),
    );
    if (scene.paper == 1) {
      // Wet sheen.
      canvas.drawLine(
        f.p(-0.6, 0, -0.5),
        f.p(0.4, 0, 0.6),
        Paint()
          ..strokeWidth = 0.18 * f.k
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.28),
      );
    } else if (scene.paper == 2) {
      for (var i = 0; i < 30; i++) {
        canvas.drawCircle(
          f.p((_rnd(i, 41) - 0.5) * 1.9, 0, (_rnd(i, 42) - 0.5) * 1.9),
          1.1,
          Paint()..color = labShade(_cTurmeric, -0.2).withValues(alpha: 0.7),
        );
      }
    }
    canvas.drawPath(quad, _edge);
  }

  void _scissors(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final snip = t - scene.snipT0;
    final open = snip >= 0 && snip < 0.6 ? 15 * (0.5 + 0.5 * math.cos(snip * math.pi * 6)) : 15.0;
    final ang = open * math.pi / 180;
    for (final sgn in [1.0, -1.0]) {
      final tip = f.p(1.25 * math.cos(ang), 0, -sgn * 1.25 * math.sin(ang));
      final base = f.p(0, 0, 0);
      final d = tip - base;
      final n = Offset(-d.dy, d.dx) / d.distance;
      final w = 0.075 * f.k;
      canvas.drawPath(
        Path()..addPolygon([base + n * w, tip, base - n * w], true),
        Paint()
          ..shader = LinearGradient(colors: [Colors.white, _cMetal, labShade(_cMetal, -0.35)])
              .createShader(Rect.fromPoints(base, tip).inflate(w)),
      );
      canvas.drawPath(Path()..addPolygon([base + n * w, tip, base - n * w], true), _edge);
      final ring = Rect.fromCenter(
        center: f.p(-0.3, 0, sgn * 0.22),
        width: 0.42 * f.k,
        height: 0.42 * f.k * f.sp + 2,
      );
      canvas.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.1 * f.k + 1
          ..color = _cPlasticDark,
      );
      canvas.drawLine(base, f.p(-0.15, 0, sgn * 0.15), Paint()
        ..strokeWidth = 0.08 * f.k
        ..color = _cPlasticDark);
    }
    canvas.drawCircle(f.p(0, 0), 0.06 * f.k + 1, Paint()..color = labShade(_cMetal, -0.3));
  }

  void _strip(Canvas canvas, _Obj o) {
    final f = _objFrame(o);
    final quad = Path()
      ..addPolygon([f.p(-0.25, 0, -0.9), f.p(0.25, 0, -0.9), f.p(0.25, 0, 0.9), f.p(-0.25, 0, 0.9)], true);
    canvas.drawPath(
      quad.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(quad, Paint()..color = _cTurmeric);
    canvas.drawPath(quad, _edge);
    final i = int.parse(o.id.substring(2));
    final spot = f.ell(0.01, 0.15);
    if (i == 1 && scene.spot1) {
      canvas.drawOval(spot.inflate(2), Paint()..color = _cSpotRed);
    } else if (i > 1) {
      final t0 = i == 2 ? scene.spot2T0 : scene.spot3T0;
      final age = t - t0;
      if (age >= 0 && age < 2) {
        final fade = age > 1.6 ? (2 - age) / 0.4 : 1.0;
        canvas.drawOval(spot.inflate(2), Paint()..color = _cSpotWet.withValues(alpha: 0.6 * fade));
      }
    }
  }

  // ------------------------------------------------------------ labels

  void _label(Canvas canvas, String text, Offset at, {Color? border, Alignment anchor = Alignment.bottomCenter}) {
    labText(
      canvas,
      text,
      at,
      size: 13,
      weight: FontWeight.w600,
      anchor: anchor,
      color: isDark ? Colors.white : const Color(0xFF1E293B),
      background: isDark ? const Color(0xD9000000) : const Color(0xF2FFFFFF),
      border: border ?? (isDark ? const Color(0x33FFFFFF) : const Color(0x26000000)),
      borderWidth: border == null ? 1 : 2,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    );
  }

  void _paintLabels(Canvas canvas) {
    for (final o in scene.objs.values) {
      if (!o.visible) continue;
      final p = o.pos.at(t);
      if (o.labelKey != null) {
        final dy = o.labelDy * o.scale.at(t);
        _label(canvas, labels[o.labelKey!] ?? o.labelKey!, _v.project(p.x, p.y + dy, p.z).p);
      } else if (o.id.startsWith('st')) {
        final n = o.id.substring(2);
        _label(canvas, (labels['lblStrip'] ?? 'Strip {n}').replaceAll('{n}', n),
            _v.project(p.x, p.y, p.z + 1.05).p,
            anchor: Alignment.topCenter);
      }
    }
    if (scene.acidicLabel) {
      final p = scene.o('ttLemon').pos.at(t);
      _label(canvas, labels['lblAcidic'] ?? '', _v.project(p.x, 0, p.z + 0.85).p,
          border: _cMagenta, anchor: Alignment.topCenter);
    }
    if (scene.basicLabel) {
      final p = scene.o('ttSoap').pos.at(t);
      _label(canvas, labels['lblBasic'] ?? '', _v.project(p.x, 0, p.z + 1.9).p,
          border: _cGreen, anchor: Alignment.topCenter);
    }
  }

  @override
  bool shouldRepaint(covariant _IndicatorPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
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
