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

/// Class 7 Science • Chapter 2 • Activity 1
/// Introduction to Acid-Base Indicators: Litmus.
///
/// Native Flutter port of `Cl7S-Ch2-A1-IntroductiontoAcidBaseIndicatorsLitmus.html`.
/// Scenario 1 (acids) / 2 (bases): drag a beaker from the shelf onto the
/// white tile, fill the dropper, put a drop on each litmus strip, reset the
/// apparatus and repeat with a second substance, then classify both beakers
/// into the ACIDS / BASES tray.
class Ch2A1IntroductionToAcidBaseIndicatorsLitmusPage extends StatefulWidget {
  const Ch2A1IntroductionToAcidBaseIndicatorsLitmusPage({super.key});

  @override
  State<Ch2A1IntroductionToAcidBaseIndicatorsLitmusPage> createState() =>
      _Ch2A1IntroductionToAcidBaseIndicatorsLitmusPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356.
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

/// One litmus test recorded for the sidebar results table.
@immutable
class _Result {
  const _Result(this.sub, this.bluePaper, this.color);
  final _Sub sub;
  final bool bluePaper;
  final Color color;
}

/// Pan recognizer that only joins the gesture arena when the touch starts
/// on a draggable object, so camera pan / pinch still work elsewhere.
class _ObjectPanRecognizer extends PanGestureRecognizer {
  _ObjectPanRecognizer({required this.accepts}) {
    // Small slop: objects can sit close to their targets on screen, and
    // this recognizer only claims touches that start on a draggable object.
    gestureSettings = const DeviceGestureSettings(touchSlop: 4);
  }
  bool Function(Offset local) accepts;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch2A1IntroductionToAcidBaseIndicatorsLitmusPageState
    extends State<Ch2A1IntroductionToAcidBaseIndicatorsLitmusPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// HTML `appState.currentStepIndex` (0-based; 6 = scenario complete).
  int _stepIndex = 0;

  /// HTML `appState.subStepIndex` (Step 5: 0 = reset, 1-4 = repeat).
  int _sub = 0;
  _Sub? _dropperFilledWith;
  _Sub? _substanceOnTile;
  int _itemsClassified = 0;
  final Set<String> _classified = {};
  bool _busy = false;
  bool _successVisible = false;
  final List<_Result> _results = [];
  Offset _grab = Offset.zero;
  Offset _resetCardOffset = Offset.zero;

  int get _scenario => _scene.scenario;
  bool get _s1 => _scenario == 0;
  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  String get _firstId => _s1 ? 'beaker_lemon' : 'beaker_soap';
  String get _secondId => _s1 ? 'beaker_vinegar' : 'beaker_baking_soda';
  _Tray get _goalTray => _s1 ? _scene.acids : _scene.bases;
  _Tray get _otherTray => _s1 ? _scene.bases : _scene.acids;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scene.resetForScenario();
    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
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

  // ------------------------------------------------------------ scenario

  /// HTML `loadScenario()`.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.scenario = index;
    _stepIndex = 0;
    _sub = 0;
    _dropperFilledWith = null;
    _substanceOnTile = null;
    _itemsClassified = 0;
    _classified.clear();
    _busy = false;
    _successVisible = false;
    _results.clear();
    _resetCardOffset = Offset.zero;
    _scene.resetForScenario();
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `advanceStep()`: success chime, next step; after the last step the
  /// observation popup opens 4 s later.
  void _advanceStep() {
    _Audio.play(_Sound.success);
    _stepIndex++;
    _sub = 0;
    if (_stepIndex == _data.steps.length) {
      final scenario = _scenario;
      _lab.showScenarioConclusion(
        scenarioIndex: scenario,
        totalScenarios: 2,
        delay: const Duration(milliseconds: 4000),
        title: () => _t('lab_obs'),
        heading: () => _t('conc_${scenario + 1}_title'),
        body: () => _t('conc_${scenario + 1}_body'),
        extra: () => _conclusionNote(scenario),
      );
    }
  }

  /// HTML `resetApparatus()` (canvas "Reset Apparatus" button in Step 5).
  void _resetApparatus() {
    if (_stepIndex != 4 || _sub != 0 || _busy) return;
    setState(() {
      final now = _scene.time;
      for (final b in _scene.beakers.values) {
        if (!identical(b.world, b.start)) b.moveTo(b.start, now, dur: 0.45);
      }
      final d = _scene.dropper;
      d.moveTo(d.start, now, dur: 0.45, angle: d.restAngle);
      d.liquid = null;
      _scene.blue.reset();
      _scene.red.reset();
      _scene.acids.done = false;
      _scene.bases.done = false;
      _sub = 1;
      _dropperFilledWith = null;
      _substanceOnTile = null;
    });
  }

  // --------------------------------------------------------- interaction

  /// Topmost visible object under [p] (dropper first, then beakers front
  /// to back), like the HTML raycaster on `interactables`.
  _Body? _hitObject(Offset p) {
    final t = _scene.time;
    final d = _scene.dropper.place(t);
    if (_dropperRect(d.p, d.k, d.a).contains(p)) return _scene.dropper;
    final list = _scene.beakers.values.where((b) => b.visible).toList()
      ..sort((a, b) => b.place(t).p.dy.compareTo(a.place(t).p.dy));
    for (final b in list) {
      final pl = b.place(t);
      if (_beakerRect(pl.p, pl.k).inflate(6).contains(p)) return b;
    }
    return null;
  }

  /// HTML `onPointerDown` drag permission rules.
  bool _canDrag(_Body b) {
    if (_busy || _stepIndex >= 6) return false;
    final id = b.id;
    switch (_stepIndex) {
      case 0:
        return id == _firstId;
      case 1:
      case 2:
      case 3:
        return id == 'dropper';
      case 4:
        if (_sub == 1) return id == _secondId;
        return _sub >= 2 && id == 'dropper';
      case 5:
        return (id == _firstId || id == _secondId) && !_classified.contains(id);
    }
    return false;
  }

  bool _acceptsPointer(Offset local) {
    final b = _hitObject(local);
    return b != null && _canDrag(b);
  }

  void _onTapUp(TapUpDetails d) {
    final b = _hitObject(d.localPosition);
    if (b == null || _busy || _stepIndex >= 6) return;
    if (_canDrag(b)) {
      _lab.showToast(labFormat(_t('hint_drag'), {'task': _instruction()}), sound: false);
      _Audio.play(_Sound.click);
    } else {
      _lab.showToast(_t('err_not_now'), isError: true);
    }
  }

  void _onPanStart(DragStartDetails d) {
    final b = _hitObject(d.localPosition);
    if (b == null || !_canDrag(b)) return;
    final pl = b.place(_scene.time);
    if (b is _Dropper) b.angle = 0; // held upright while dragged
    b.dragAt = pl.p;
    b.dragK = pl.k * 1.06;
    _grab = d.localPosition - pl.p;
    _scene.dragging = b;
    _Audio.play(_Sound.pickup);
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final b = _scene.dragging;
    if (b == null) return;
    b.dragAt = d.localPosition - _grab;
    _scene.hover = _hoverTarget(b);
  }

  void _onPanEnd(DragEndDetails _) {
    final b = _scene.dragging;
    if (b == null) return;
    setState(() => _release(b));
  }

  void _onPanCancel() {
    final b = _scene.dragging;
    if (b == null) return;
    setState(() {
      _scene.dragging = null;
      _scene.hover = null;
      b.moveTo(b.start, _scene.time, dur: 0.3, angle: b.restAngle);
    });
  }

  // Drop zones (design space).
  bool _overTile(Offset at, double k) =>
      _tileQuad(grow: 0.5).contains(at) ||
      (at - _projV(_Scene.tileSpot).p).distance < 1.0 * k;

  bool _tipOverBeaker(Offset tip, _Beaker target) {
    final pl = target.place(_scene.time);
    return _beakerRect(pl.p, pl.k).inflate(0.35 * pl.k).contains(tip);
  }

  String? _fillTargetId() {
    if (_stepIndex == 1) return _firstId;
    if (_stepIndex == 4 && _sub == 2) return _secondId;
    return null;
  }

  String? _paperTargetId() {
    final firstBlue = _s1; // acids test blue first, bases test red first
    if (_stepIndex == 2 || (_stepIndex == 4 && _sub == 3)) {
      return firstBlue ? 'litmus_blue' : 'litmus_red';
    }
    if (_stepIndex == 3 || (_stepIndex == 4 && _sub == 4)) {
      return firstBlue ? 'litmus_red' : 'litmus_blue';
    }
    return null;
  }

  /// Which correct drop target the dragged object is over (for glows).
  String? _hoverTarget(_Body b) {
    final pl = b.place(_scene.time);
    if (b is _Dropper) {
      final tip = _dropperTip(pl.p, pl.k, 0);
      final fill = _fillTargetId();
      if (fill != null && _tipOverBeaker(tip, _scene.beakers[fill]!)) return fill;
      final paper = _paperTargetId();
      if (paper != null && _paperRect(_scene.paper(paper), grow: 0.3).contains(tip)) {
        return paper;
      }
      return null;
    }
    if (_stepIndex == 0 || (_stepIndex == 4 && _sub == 1)) {
      return _overTile(pl.p, pl.k) ? 'tile' : null;
    }
    if (_stepIndex == 5 && _trayQuad(_goalTray, grow: 0.4).contains(pl.p)) return _goalTray.id;
    return null;
  }

  /// HTML `onPointerUp`: validates the drop for the current step.
  void _release(_Body b) {
    final now = _scene.time;
    final pl = b.place(now);
    _scene.dragging = null;
    _scene.hover = null;

    if (b is _Dropper) {
      final tip = _dropperTip(pl.p, pl.k, 0);
      final fillId = _fillTargetId();
      if (fillId != null) {
        final beaker = _scene.beakers[fillId]!;
        if (_tipOverBeaker(tip, beaker)) return _fill(beaker);
        return _failDropper(labFormat(_t('err_fill'), {'name': _t(beaker.sub.key)}));
      }
      final paperId = _paperTargetId();
      if (paperId != null) {
        final target = _scene.paper(paperId);
        final other = target.isBlue ? _scene.red : _scene.blue;
        final inTarget = _paperRect(target, grow: 0.3).contains(tip);
        final inOther = _paperRect(other, grow: 0.15).contains(tip);
        if (inTarget && !inOther && _dropperFilledWith != null) return _dropOn(target);
        final msg = inOther ? 'err_wrong_paper' : 'err_paper';
        return _failDropper(labFormat(_t(msg), {'paper': _t(target.labelKey)}));
      }
      return _failDropper(_t('err_not_now'));
    }

    if (b is! _Beaker) return;
    if (_stepIndex == 0 || (_stepIndex == 4 && _sub == 1)) {
      if (_overTile(pl.p, pl.k)) {
        b.moveTo(_Scene.tileSpot, now, dur: 0.18);
        _substanceOnTile = b.sub;
        if (_stepIndex == 0) {
          _advanceStep();
        } else {
          _Audio.play(_Sound.drop);
          _sub = 2;
        }
        return;
      }
      b.moveTo(b.start, now, dur: 0.35);
      _lab.showToast(_t('err_tile'), isError: true);
      return;
    }
    if (_stepIndex == 5) {
      final tray = _goalTray;
      if (_trayQuad(tray, grow: 0.4).contains(pl.p)) {
        final n = _itemsClassified;
        b.moveTo(_V3(tray.pos.x + (n * 0.8 - 0.4), 0.05, tray.pos.z), now, dur: 0.18);
        _itemsClassified++;
        _classified.add(b.id);
        _Audio.play(_Sound.drop);
        if (_itemsClassified == 2) {
          tray.done = true;
          _successVisible = true;
          _advanceStep();
        }
        return;
      }
      b.moveTo(b.start, now, dur: 0.35);
      final box = _t(tray.labelKey);
      if (_trayQuad(_otherTray, grow: 0.2).contains(pl.p)) {
        _lab.showToast(
          labFormat(_t('err_wrong_box'), {'name': _t(b.sub.key), 'box': box}),
          isError: true,
        );
      } else {
        _lab.showToast(labFormat(_t('err_box'), {'box': box}), isError: true);
      }
    }
  }

  void _failDropper(String message) {
    final d = _scene.dropper;
    d.moveTo(d.start, _scene.time, dur: 0.35, angle: d.restAngle);
    _lab.showToast(message, isError: true);
  }

  /// HTML `triggerFillAnimation`: dip, liquid appears after 300 ms, the
  /// dropper rises and returns to the stand after 600 ms.
  void _fill(_Beaker beaker) {
    _busy = true;
    final d = _scene.dropper;
    final now = _scene.time;
    d.moveTo(beaker.world.up(0.95), now, dur: 0.15, angle: 0);
    d.dipT0 = now + 0.12;
    _Audio.play(_Sound.drop);
    _lab.after(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      d.liquid = beaker.sub;
      d.liquidT0 = _scene.time;
    });
    _lab.after(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _dropperFilledWith = beaker.sub;
        d.moveTo(d.start, _scene.time, dur: 0.4, angle: d.restAngle);
        _busy = false;
        if (_stepIndex == 4) {
          _sub = 3;
        } else {
          _advanceStep();
        }
      });
    });
  }

  /// HTML `triggerDropAnimation`: a droplet falls onto the strip, the strip
  /// flashes white for 150 ms and the stain takes the indicator colour.
  void _dropOn(_Paper paper) {
    final sub = _dropperFilledWith!;
    _busy = true;
    final d = _scene.dropper;
    final now = _scene.time;
    final above = _V3(paper.pos.x, 1.15, paper.pos.z);
    d.moveTo(above, now, dur: 0.15, angle: 0);
    _Audio.play(_Sound.drop);
    final rest = _projV(above);
    _scene.drop = _Drop(
      _dropperTip(rest.p, rest.k, 0),
      _projV(paper.pos.up(0.05)).p,
      sub.color,
      now + 0.15,
    );
    _lab.after(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        final t = _scene.time;
        final color = _stainFor(sub, paper.isBlue);
        paper.flashT0 = t;
        paper.stain = color;
        paper.stainT0 = t + 0.15;
        _scene.drop = null;
        _results.add(_Result(sub, paper.isBlue, color));
        d.moveTo(d.start, t, dur: 0.4, angle: d.restAngle);
        _busy = false;
        if (_stepIndex == 4 && _sub == 3) {
          _sub = 4;
        } else {
          _advanceStep();
        }
      });
    });
  }

  // ---------------------------------------------------------------- text

  /// HTML `updateHUD()` text for the current state.
  String _instruction() {
    if (_stepIndex >= _data.steps.length) return _t('scenario_complete');
    if (_stepIndex == 4) {
      switch (_sub) {
        case 0:
          return _t('hud_click_reset');
        case 1:
          return _t(_s1 ? 'hud_drag_second_acid' : 'hud_drag_second_base');
        case 2:
          return _t('hud_drag_fill');
        case 3:
          return _t(_s1 ? 'hud_drag_blue' : 'hud_drag_red');
        default:
          return _t(_s1 ? 'hud_drag_red' : 'hud_drag_blue');
      }
    }
    return _data.steps[_stepIndex].action;
  }

  /// Teacher-board `task_text` (with the Step 5 "Sub-task n/4" variant).
  String _taskText() {
    final i = _stepIndex.clamp(0, 5);
    if (_stepIndex == 4 && _sub > 0) {
      final sub = _t(_s1 ? 'lbl_vinegar' : 'lbl_baking');
      return '${labFormat(_t('sub_task'), {'n': _sub})} '
          '${labFormat(_t('sub_task_text'), {'sub': sub})}';
    }
    return _t('s${_scenario + 1}_task_${i + 1}');
  }

  List<LabAction> _actions() => [
        if (_stepIndex == 4 && _sub == 0)
          LabAction(
            label: _t('reset_app'),
            icon: Icons.restart_alt,
            color: _Colors.indigo600,
            foreground: Colors.white,
            highlight: true,
            onTap: _resetApparatus,
          ),
      ];

  Map<String, String> _labels() => {
        for (final k in const [
          'lbl_lemon',
          'lbl_vinegar',
          'lbl_water',
          'lbl_soap',
          'lbl_baking',
          'lbl_blue',
          'lbl_red',
          'lbl_dropper',
          'lbl_box_acid',
          'lbl_box_base',
        ])
          k: _t(k),
      };

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final complete = _stepIndex >= data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('opt_s1'), _t('opt_s2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _stepIndex + 1,
          instruction: (_stepIndex == 4 || complete) ? _instruction() : null,
          actions: _actions(),
          sidebarExtraTitle: _t('task_inst'),
          sidebarExtra: _sidebarPanel(p, s),
          onReset: _fullReset,
          overlays: [
            if (_stepIndex == 4 && _sub == 0) _resetCard(s, inset),
            if (_successVisible) _successOverlay(s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ObjectPanRecognizer:
                    GestureRecognizerFactoryWithHandlers<_ObjectPanRecognizer>(
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
                painter: _LitmusPainter(
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
        );
      },
    );
  }

  /// Sidebar: task instructions, live lab status and the litmus results.
  Widget _sidebarPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final complete = _stepIndex >= _data.steps.length;
    BoxDecoration card() => BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.cardBorder),
        );
    final filled = _dropperFilledWith;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _taskText(),
                style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45, fontWeight: FontWeight.w500),
              ),
              if (complete) ...[
                SizedBox(height: 8 * s),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: _Colors.green, size: 16 * f),
                    SizedBox(width: 6 * s),
                    Expanded(
                      child: Text(
                        _t('scenario_complete'),
                        style: TextStyle(color: _Colors.green, fontSize: 12.5 * f, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        LabSectionLabel(_t('lab_status'), size: 10.5 * s, icon: Icons.info_outline),
        SizedBox(height: 6 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
          decoration: card(),
          child: Column(
            children: [
              LabInfoRow(
                palette: p,
                scale: f,
                label: _t('on_tile'),
                value: _substanceOnTile == null ? _t('none') : _t(_substanceOnTile!.key),
              ),
              LabInfoRow(
                palette: p,
                scale: f,
                label: _t('dropper_holds'),
                value: filled == null ? _t('empty') : _t(filled.key),
                valueColor: filled == null ? p.textMuted : _Colors.zslYellow,
              ),
              if (_stepIndex >= 5)
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('classified'),
                  value: '$_itemsClassified / 2',
                  valueColor: _itemsClassified == 2 ? _Colors.green : null,
                ),
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        LabSectionLabel(_t('results'), size: 10.5 * s, icon: Icons.fact_check_outlined),
        SizedBox(height: 6 * s),
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: card(),
          child: _resultsTable(p, s, f),
        ),
      ],
    );
  }

  Widget _resultsTable(LabPalette p, double s, double f) {
    if (_results.isEmpty) {
      return Text(_t('no_results'), style: TextStyle(color: p.textMuted, fontSize: 11.5 * f));
    }
    final subs = <_Sub>[];
    for (final r in _results) {
      if (!subs.contains(r.sub)) subs.add(r.sub);
    }
    Widget chip(_Result r) {
      final changed = r.bluePaper ? r.sub.kind == _Kind.acid : r.sub.kind == _Kind.base;
      final text = !changed ? _t('res_no_change') : _t(r.bluePaper ? 'res_red' : 'res_blue');
      return Padding(
        padding: EdgeInsets.only(top: 4 * s),
        child: Row(
          children: [
            Container(
              width: 22 * s,
              height: 9 * s,
              decoration: BoxDecoration(
                color: r.bluePaper ? _blueLitmus : _redLitmus,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: _outline.withValues(alpha: 0.6)),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8 * s,
                height: 8 * s,
                decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
              ),
            ),
            SizedBox(width: 6 * s),
            Expanded(
              child: Text(
                '${_t(r.bluePaper ? 'lbl_blue' : 'lbl_red')} → $text',
                style: TextStyle(
                  color: changed ? p.textStrong : p.textMuted,
                  fontSize: 11 * f,
                  fontWeight: changed ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < subs.length; i++) ...[
          if (i > 0) Divider(height: 14 * s, color: p.cardBorder),
          Row(
            children: [
              Container(
                width: 10 * s,
                height: 10 * s,
                decoration: BoxDecoration(
                  color: subs[i].color,
                  shape: BoxShape.circle,
                  border: Border.all(color: _outline.withValues(alpha: 0.6)),
                ),
              ),
              SizedBox(width: 6 * s),
              Expanded(
                child: Text(
                  _t(subs[i].key),
                  style: TextStyle(color: p.textStrong, fontSize: 12 * f, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          for (final r in _results.where((r) => r.sub == subs[i])) chip(r),
        ],
      ],
    );
  }

  /// HTML `#canvas-action-container`: draggable "Reset Apparatus" card.
  Widget _resetCard(double s, EdgeInsets inset) {
    return Positioned(
      top: inset.top + 54 * s,
      right: inset.right + 6,
      child: Transform.translate(
        offset: _resetCardOffset,
        child: SizedBox(
          width: 200 * s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onPanUpdate: (d) => setState(() => _resetCardOffset += d.delta),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3730A3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    border: Border.all(color: const Color(0xFF818CF8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drag_indicator, color: Colors.white, size: 14 * s),
                      SizedBox(width: 4 * s),
                      Flexible(
                        child: Text(
                          _t('drag_move'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 10.5 * s, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              LabActionButton(
                scale: s,
                action: LabAction(
                  label: _t('reset_app'),
                  icon: Icons.restart_alt,
                  color: _Colors.indigo600,
                  foreground: Colors.white,
                  highlight: true,
                  onTap: _resetApparatus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HTML `#canvas-success-overlay` (green banner after classification).
  Widget _successOverlay(double s, EdgeInsets inset) {
    return Positioned(
      left: inset.left + 12,
      right: inset.right + 12,
      top: inset.top,
      bottom: inset.bottom,
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.5),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480 * s),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
                decoration: BoxDecoration(
                  color: const Color(0xE622C55E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x9922C55E), blurRadius: 40)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 26 * s),
                    SizedBox(height: 4 * s),
                    Text(
                      _t(_s1 ? 'correct_acid' : 'correct_base'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14 * s,
                        height: 1.25,
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

  /// The muted note box at the end of the HTML observation.
  Widget _conclusionNote(int scenario) {
    final dark = _lab.isDark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFF94A3B8)),
      ),
      child: Text(
        _t('conc_${scenario + 1}_note'),
        style: TextStyle(
          color: dark ? _Colors.slate400 : _Colors.slate600,
          fontSize: 12,
          height: 1.45,
        ),
      ),
    );
  }
}

// ============================================================ STRINGS
// Copied from the HTML `TRANSLATIONS` (EN / HI). Telugu dropped. Strings the
// HTML hard-coded (sub-task text) or that are new in this port (status
// panel, results table, hints for wrong drops) are added in both languages.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Introduction to Acid-Base Indicators: Litmus',
    'app_subtitle': 'Class 7 • Exploring Substances: Acidic, Basic, and Neutral',
    'opt_s1': 'Scenario 1: The Acid Test: Blue to Red',
    'opt_s2': 'Scenario 2: The Base Test: Red to Blue',
    'reset_app': 'Reset Apparatus',
    'drag_move': 'Drag to Move',
    'lab_obs': 'Lab Observation',
    'scenario_complete': 'Scenario Complete!',
    'correct_acid': 'Correct! Substances that turn blue litmus paper red are called ACIDS.',
    'correct_base': 'Excellent! Substances that turn red litmus paper blue are called BASES.',
    'hud_click_reset': "CLICK 'Reset Apparatus' on the Canvas.",
    'hud_drag_second_acid': 'DRAG the Vinegar beaker onto the highlighted tile.',
    'hud_drag_second_base': 'DRAG the Baking Soda Sol. beaker onto the highlighted tile.',
    'hud_drag_fill': 'DRAG Dropper to the new beaker to fill it.',
    'hud_drag_blue': 'DRAG filled dropper to the Blue Litmus.',
    'hud_drag_red': 'DRAG filled dropper to the Red Litmus.',
    // 3D labels
    'lbl_lemon': 'Lemon Juice',
    'lbl_vinegar': 'Vinegar',
    'lbl_water': 'Water',
    'lbl_soap': 'Soap Solution',
    'lbl_baking': 'Baking Soda Sol.',
    'lbl_blue': 'Blue Litmus',
    'lbl_red': 'Red Litmus',
    'lbl_dropper': 'Dropper',
    'lbl_box_acid': 'ACIDS',
    'lbl_box_base': 'BASES',
    // Task instructions (teacher board `task_text`, shown in the sidebar).
    'task_inst': 'Task Instructions',
    'sub_task': 'Sub-task {n}/4:',
    'sub_task_text': 'Follow the same rigorous procedure to test {sub}.',
    's1_task_1':
        "The lab bench is set up. DRAG the beaker labeled 'Lemon Juice' from the shelf and DROP it onto the designated spot on the white tile.",
    's1_task_2':
        "DRAG the dropper from the stand, move it over the 'Lemon Juice' beaker, and CLICK to fill the dropper with juice.",
    's1_task_3':
        'DRAG the filled dropper over the first piece of blue litmus paper on the tile and CLICK to release one drop.',
    's1_task_4':
        'Now, DRAG the same dropper over the first piece of red litmus paper and CLICK to release one drop.',
    's1_task_5':
        "A 'Reset' button will appear on the Canvas. CLICK the 'Reset' button. Now, repeat Steps 1-4 using the beaker labeled 'Vinegar'.",
    's1_task_6':
        "A summary screen appears. DRAG the 'Lemon Juice' and 'Vinegar' beakers into the box labeled 'Acids'.",
    's2_task_1':
        "The lab bench is reset. DRAG the beaker labeled 'Soap Solution' from the shelf and DROP it onto the designated spot on the white tile.",
    's2_task_2':
        "DRAG the dropper from the stand, move it over the 'Soap Solution' beaker, and CLICK to fill the dropper with liquid.",
    's2_task_3':
        'DRAG the filled dropper over the first piece of red litmus paper on the tile and CLICK to release one drop.',
    's2_task_4':
        'Now, DRAG the same dropper over the first piece of blue litmus paper and CLICK to release one drop.',
    's2_task_5':
        "A 'Reset' button will appear on the Canvas. CLICK the 'Reset' button. Now, repeat Steps 1-4 using the beaker labeled 'Baking Soda Solution'.",
    's2_task_6':
        "A summary screen appears. DRAG the 'Soap Solution' and 'Baking Soda Solution' beakers into the box labeled 'Bases'.",
    // Conclusion popup (scenario `observation`).
    'conc_1_title': 'Conclusion: Acids Turn Blue Litmus Red',
    'conc_1_body':
        'During our investigation, we observed that both Lemon Juice and Vinegar instantly changed the color of the blue litmus paper to red.\n\nThey had absolutely no effect on the red litmus paper.',
    'conc_1_note':
        'This confirms that they are acidic substances. This is a fundamental property used by chemists to safely identify acids.',
    'conc_2_title': 'Conclusion: Bases Turn Red Litmus Blue',
    'conc_2_body':
        'During our investigation, we observed that both the Soap Solution and Baking Soda Solution instantly changed the color of the red litmus paper to blue.\n\nThey had absolutely no effect on the blue litmus paper.',
    'conc_2_note':
        'This confirms that they are basic (alkaline) substances. Indicators help us safely classify these otherwise clear solutions!',
    // Status panel / results table (new in this port).
    'lab_status': 'Lab Status',
    'on_tile': 'On the tile',
    'dropper_holds': 'Dropper',
    'empty': 'Empty',
    'none': '—',
    'classified': 'Classified',
    'results': 'Litmus Results',
    'col_substance': 'Substance',
    'res_red': 'Turned Red',
    'res_blue': 'Turned Blue',
    'res_no_change': 'No change',
    'no_results': 'No litmus tests yet.',
    // Hints for wrong moves (the HTML silently snapped objects back).
    'err_not_now': "That item isn't needed for this step.",
    'hint_drag': 'Drag it! {task}',
    'err_tile': 'Drop the beaker on the highlighted spot on the white tile.',
    'err_fill': 'Release the dropper over the {name} beaker to fill it.',
    'err_paper': 'Release the dropper over the {paper} paper.',
    'err_wrong_paper': 'Wrong paper! Release the drop on the {paper} paper.',
    'err_box': 'Drop the beaker into the {box} box.',
    'err_wrong_box': 'Wrong box! {name} belongs in the {box} box.',
  },
  'hi': {
    'app_title': 'अम्ल-क्षार सूचकों का परिचय: लिटमस',
    'app_subtitle': 'कक्षा 7 • पदार्थों की खोज: अम्लीय, क्षारीय और उदासीन',
    'opt_s1': 'परिदृश्य 1: अम्ल परीक्षण: नीले से लाल',
    'opt_s2': 'परिदृश्य 2: क्षार परीक्षण: लाल से नीला',
    'reset_app': 'उपकरण रीसेट करें',
    'drag_move': 'ले जाने के लिए खींचें',
    'lab_obs': 'प्रयोगशाला अवलोकन',
    'scenario_complete': 'परिदृश्य पूरा हुआ!',
    'correct_acid': 'सही! नीले लिटमस पेपर को लाल करने वाले पदार्थ अम्ल (ACIDS) कहलाते हैं।',
    'correct_base': 'उत्कृष्ट! लाल लिटमस पेपर को नीला करने वाले पदार्थ क्षार (BASES) कहलाते हैं।',
    'hud_click_reset': "कैनवास पर 'उपकरण रीसेट करें' पर क्लिक करें।",
    'hud_drag_second_acid': 'सिरका बीकर को हाइलाइट की गई जगह पर खींचें।',
    'hud_drag_second_base': 'बेकिंग सोडा बीकर को हाइलाइट की गई जगह पर खींचें।',
    'hud_drag_fill': 'भरने के लिए ड्रॉपर को नए बीकर पर खींचें।',
    'hud_drag_blue': 'भरे हुए ड्रॉपर को नीले लिटमस पर खींचें।',
    'hud_drag_red': 'भरे हुए ड्रॉपर को लाल लिटमस पर खींचें।',
    'lbl_lemon': 'नींबू का रस',
    'lbl_vinegar': 'सिरका',
    'lbl_water': 'पानी',
    'lbl_soap': 'साबुन का घोल',
    'lbl_baking': 'बेकिंग सोडा का घोल',
    'lbl_blue': 'नीला लिटमस',
    'lbl_red': 'लाल लिटमस',
    'lbl_dropper': 'ड्रॉपर',
    'lbl_box_acid': 'अम्ल (ACIDS)',
    'lbl_box_base': 'क्षार (BASES)',
    'task_inst': 'कार्य निर्देश',
    'sub_task': 'उप-कार्य {n}/4:',
    'sub_task_text': '{sub} का परीक्षण करने के लिए उसी कठोर प्रक्रिया का पालन करें।',
    's1_task_1':
        "लैब बेंच तैयार है। 'नींबू का रस' लेबल वाले बीकर को शेल्फ से खींचें और इसे सफेद टाइल पर निर्दिष्ट स्थान पर छोड़ें।",
    's1_task_2':
        "स्टैंड से ड्रॉपर खींचें, इसे 'नींबू के रस' बीकर के ऊपर ले जाएं, और ड्रॉपर को रस से भरने के लिए छोड़ दें।",
    's1_task_3':
        'भरे हुए ड्रॉपर को टाइल पर नीले लिटमस पेपर के पहले टुकड़े के ऊपर खींचें और एक बूंद छोड़ने के लिए क्लिक करें।',
    's1_task_4':
        'अब, उसी ड्रॉपर को लाल लिटमस पेपर के पहले टुकड़े के ऊपर खींचें और एक बूंद छोड़ने के लिए क्लिक करें।',
    's1_task_5':
        "कैनवास पर एक 'उपकरण रीसेट करें' बटन दिखाई देगा। बटन पर क्लिक करें। अब, 'सिरका' लेबल वाले बीकर का उपयोग करके चरण 1-4 दोहराएं।",
    's1_task_6':
        "एक सारांश स्क्रीन दिखाई देती है। 'नींबू का रस' और 'सिरका' बीकर को 'अम्ल' लेबल वाले बॉक्स में खींचें।",
    's2_task_1':
        "लैब बेंच रीसेट कर दी गई है। 'साबुन का घोल' लेबल वाले बीकर को शेल्फ से खींचें और इसे सफेद टाइल पर निर्दिष्ट स्थान पर छोड़ें।",
    's2_task_2':
        "स्टैंड से ड्रॉपर खींचें, इसे 'साबुन के घोल' बीकर के ऊपर ले जाएं, और ड्रॉपर को तरल से भरने के लिए क्लिक करें।",
    's2_task_3':
        'भरे हुए ड्रॉपर को टाइल पर लाल लिटमस पेपर के पहले टुकड़े के ऊपर खींचें और एक बूंद छोड़ने के लिए क्लिक करें।',
    's2_task_4':
        'अब, उसी ड्रॉपर को नीले लिटमस पेपर के पहले टुकड़े के ऊपर खींचें और एक बूंद छोड़ने के लिए क्लिक करें।',
    's2_task_5':
        "कैनवास पर एक 'उपकरण रीसेट करें' बटन दिखाई देगा। बटन पर क्लिक करें। अब, 'बेकिंग सोडा घोल' लेबल वाले बीकर का उपयोग करके चरण 1-4 दोहराएं।",
    's2_task_6':
        "एक सारांश स्क्रीन दिखाई देती है। 'साबुन का घोल' और 'बेकिंग सोडा घोल' बीकर को 'क्षार' लेबल वाले बॉक्स में खींचें।",
    'conc_1_title': 'निष्कर्ष: अम्ल नीले लिटमस को लाल कर देते हैं',
    'conc_1_body':
        'हमारी जांच के दौरान, हमने देखा कि नींबू का रस और सिरका दोनों ने तुरंत नीले लिटमस पेपर का रंग लाल कर दिया।\n\nलाल लिटमस पेपर पर उनका बिल्कुल भी प्रभाव नहीं पड़ा।',
    'conc_1_note':
        'यह पुष्टि करता है कि वे अम्लीय पदार्थ हैं। यह एक मौलिक गुण है जिसका उपयोग रसायनज्ञों द्वारा अम्लों की सुरक्षित रूप से पहचान करने के लिए किया जाता है।',
    'conc_2_title': 'निष्कर्ष: क्षार लाल लिटमस को नीला कर देते हैं',
    'conc_2_body':
        'हमारी जांच के दौरान, हमने देखा कि साबुन का घोल और बेकिंग सोडा का घोल दोनों ने तुरंत लाल लिटमस पेपर का रंग नीला कर दिया।\n\nनीले लिटमस पेपर पर उनका बिल्कुल भी प्रभाव नहीं पड़ा।',
    'conc_2_note':
        'यह पुष्टि करता है कि वे क्षारीय (एल्केलाइन) पदार्थ हैं। सूचक हमें इन अन्यथा स्पष्ट समाधानों को सुरक्षित रूप से वर्गीकृत करने में मदद करते हैं!',
    'lab_status': 'लैब की स्थिति',
    'on_tile': 'टाइल पर',
    'dropper_holds': 'ड्रॉपर',
    'empty': 'खाली',
    'none': '—',
    'classified': 'वर्गीकृत',
    'results': 'लिटमस परिणाम',
    'col_substance': 'पदार्थ',
    'res_red': 'लाल हुआ',
    'res_blue': 'नीला हुआ',
    'res_no_change': 'कोई बदलाव नहीं',
    'no_results': 'अभी तक कोई लिटमस परीक्षण नहीं।',
    'err_not_now': 'इस चरण के लिए इस वस्तु की आवश्यकता नहीं है।',
    'hint_drag': 'इसे खींचें! {task}',
    'err_tile': 'बीकर को सफेद टाइल पर हाइलाइट की गई जगह पर छोड़ें।',
    'err_fill': 'भरने के लिए ड्रॉपर को {name} बीकर के ऊपर छोड़ें।',
    'err_paper': 'ड्रॉपर को {paper} पेपर के ऊपर छोड़ें।',
    'err_wrong_paper': 'गलत पेपर! बूंद {paper} पेपर पर छोड़ें।',
    'err_box': 'बीकर को {box} बॉक्स में छोड़ें।',
    'err_wrong_box': 'गलत बॉक्स! {name} {box} बॉक्स में जाता है।',
  },
};

// Steps: action = the HTML `hud` text, observation = `expected_outcome`.
// The full `task_text` lives in `_i18n` (s{n}_task_{m}) for the sidebar.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'The Acid Test: Blue to Red',
      objective:
          'To test common acidic substances and observe that they turn blue litmus paper red, while having no effect on red litmus paper.',
      steps: [
        LabStep(
          concept: '',
          action: "DRAG 'Lemon Juice' beaker onto the highlighted spot.",
          observation: 'The beaker of lemon juice is correctly placed on the virtual lab bench.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG Dropper to the Lemon Juice beaker and release to fill it.',
          observation: 'The dropper is filled with a yellow-tinted liquid.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG filled dropper to the Blue Litmus paper.',
          observation:
              'A drop of liquid falls onto the blue litmus paper, and the paper instantly changes color.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG filled dropper to the Red Litmus paper.',
          observation:
              'A drop of liquid falls onto the red litmus paper, but its color does not change.',
        ),
        LabStep(
          concept: '',
          action: "CLICK 'Reset Apparatus' on the main canvas.",
          observation:
              'The user successfully tests vinegar, observing that it turns blue litmus red and has no effect on red litmus.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG Lemon Juice & Vinegar beakers to the ACIDS box.',
          observation: 'Both beakers are correctly classified as acids.',
        ),
      ],
    ),
    LabScenarioData(
      title: 'The Base Test: Red to Blue',
      objective:
          'To test common basic substances and observe that they turn red litmus paper blue, while having no effect on blue litmus paper.',
      steps: [
        LabStep(
          concept: '',
          action: "DRAG 'Soap Solution' beaker onto the highlighted spot.",
          observation: 'The beaker of Soap Solution is correctly placed on the virtual lab bench.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG Dropper to the Soap Solution beaker to fill it.',
          observation: 'The dropper is filled with liquid.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG filled dropper to the Red Litmus paper.',
          observation:
              'A drop of liquid falls onto the red litmus paper, and the paper instantly changes color.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG filled dropper to the Blue Litmus paper.',
          observation:
              'A drop of liquid falls onto the blue litmus paper, but its color does not change.',
        ),
        LabStep(
          concept: '',
          action: "CLICK 'Reset Apparatus' on the main canvas.",
          observation:
              'The user successfully tests baking soda, observing that it turns red litmus blue and has no effect on blue litmus.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG Soap & Baking Soda beakers to the BASES box.',
          observation: 'Both beakers are correctly classified as bases.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'अम्ल परीक्षण: नीले से लाल',
      objective:
          'सामान्य अम्लीय पदार्थों का परीक्षण करना और यह देखना कि वे नीले लिटमस पेपर को लाल कर देते हैं, जबकि लाल लिटमस पेपर पर कोई प्रभाव नहीं पड़ता है।',
      steps: [
        LabStep(
          concept: '',
          action: "'नींबू का रस' बीकर को हाइलाइट की गई जगह पर खींचें।",
          observation: 'नींबू के रस का बीकर वर्चुअल लैब बेंच पर सही ढंग से रखा गया है।',
        ),
        LabStep(
          concept: '',
          action: 'भरने के लिए ड्रॉपर को नींबू के रस वाले बीकर पर खींचें और छोड़ें।',
          observation: 'ड्रॉपर पीले रंग के तरल से भर जाता है।',
        ),
        LabStep(
          concept: '',
          action: 'भरे हुए ड्रॉपर को नीले लिटमस पेपर पर खींचें।',
          observation: 'तरल की एक बूंद नीले लिटमस पेपर पर गिरती है, और कागज तुरंत रंग बदलता है।',
        ),
        LabStep(
          concept: '',
          action: 'भरे हुए ड्रॉपर को लाल लिटमस पेपर पर खींचें।',
          observation: 'तरल की एक बूंद लाल लिटमस पेपर पर गिरती है, लेकिन इसका रंग नहीं बदलता है।',
        ),
        LabStep(
          concept: '',
          action: "कैनवास पर 'उपकरण रीसेट करें' पर क्लिक करें।",
          observation:
              'उपयोगकर्ता सफलतापूर्वक सिरके का परीक्षण करता है, यह देखते हुए कि यह नीले लिटमस को लाल कर देता है और लाल लिटमस पर कोई प्रभाव नहीं डालता है।',
        ),
        LabStep(
          concept: '',
          action: 'नींबू का रस और सिरका बीकर को अम्ल बॉक्स में खींचें।',
          observation: 'दोनों बीकरों को अम्ल के रूप में सही ढंग से वर्गीकृत किया गया है।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'क्षार परीक्षण: लाल से नीला',
      objective:
          'सामान्य क्षारीय पदार्थों का परीक्षण करना और यह देखना कि वे लाल लिटमस पेपर को नीला कर देते हैं, जबकि नीले लिटमस पेपर पर कोई प्रभाव नहीं पड़ता है।',
      steps: [
        LabStep(
          concept: '',
          action: "'साबुन का घोल' बीकर को हाइलाइट की गई जगह पर खींचें।",
          observation: 'साबुन के घोल का बीकर वर्चुअल लैब बेंच पर सही ढंग से रखा गया है।',
        ),
        LabStep(
          concept: '',
          action: 'भरने के लिए ड्रॉपर को साबुन के घोल वाले बीकर पर खींचें।',
          observation: 'ड्रॉपर तरल से भर गया है।',
        ),
        LabStep(
          concept: '',
          action: 'भरे हुए ड्रॉपर को लाल लिटमस पेपर पर खींचें।',
          observation: 'तरल की एक बूंद लाल लिटमस पेपर पर गिरती है, और कागज तुरंत रंग बदलता है।',
        ),
        LabStep(
          concept: '',
          action: 'भरे हुए ड्रॉपर को नीले लिटमस पेपर पर खींचें।',
          observation: 'तरल की एक बूंद नीले लिटमस पेपर पर गिरती है, लेकिन इसका रंग नहीं बदलता है।',
        ),
        LabStep(
          concept: '',
          action: "कैनवास पर 'उपकरण रीसेट करें' पर क्लिक करें।",
          observation:
              'उपयोगकर्ता सफलतापूर्वक बेकिंग सोडा का परीक्षण करता है, यह देखते हुए कि यह लाल लिटमस को नीला कर देता है और नीले लिटमस पर कोई प्रभाव नहीं डालता है।',
        ),
        LabStep(
          concept: '',
          action: 'साबुन और बेकिंग सोडा बीकर को क्षार बॉक्स में खींचें।',
          observation: 'दोनों बीकरों को क्षार के रूप में सही ढंग से वर्गीकृत किया गया है।',
        ),
      ],
    ),
  ],
};

// ======================================================== SCENE MODEL
// World coordinates are the Three.js ones of the HTML (x right, y up,
// z towards the viewer). A fixed perspective camera projects them into the
// 1000x560 design space of the LabStage.

const Size _design = Size(1000, 600);
const double _kPitch = 0.5;
final double _cosP = math.cos(_kPitch);
final double _sinP = math.sin(_kPitch);
const LabProjector _projector = LabProjector(
  center: Offset(470, 290),
  scale: 95,
  pitch: _kPitch,
  distance: 1500,
);
const double _lookX = 0.3, _lookY = 1.0, _lookZ = 0.8;

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  _V3 up(double dy) => _V3(x, y + dy, z);
  _V3 shift(double dx, double dy, double dz) => _V3(x + dx, y + dy, z + dz);
}

/// Projects a world point: design position and pixels per world unit.
({Offset p, double k}) _proj(double x, double y, double z) {
  final r = _projector.project(x - _lookX, y - _lookY, z - _lookZ);
  return (p: r.p, k: r.k * _projector.scale);
}

({Offset p, double k}) _projV(_V3 v) => _proj(v.x, v.y, v.z);

Offset _pt(double x, double y, double z) => _proj(x, y, z).p;

double _lerp(double a, double b, double t) => a + (b - a) * t;

enum _Kind { acid, base, neutral }

/// HTML `SUBSTANCES`.
@immutable
class _Sub {
  const _Sub(this.key, this.color, this.kind, this.opacity);
  final String key;
  final Color color;
  final _Kind kind;
  final double opacity;
}

const _Sub _lemon = _Sub('lbl_lemon', Color(0xFFFACC15), _Kind.acid, 1);
const _Sub _vinegar = _Sub('lbl_vinegar', Color(0xFFE2E8F0), _Kind.acid, 1);
const _Sub _water = _Sub('lbl_water', Color(0xFF7DD3FC), _Kind.neutral, 0.8);
const _Sub _soap = _Sub('lbl_soap', Color(0xFF94A3B8), _Kind.base, 1);
const _Sub _baking = _Sub('lbl_baking', Color(0xFFF8FAFC), _Kind.base, 1);

const Color _blueLitmus = Color(0xFF60A5FA);
const Color _redLitmus = Color(0xFFEF4444);

/// Paper colour after a drop (HTML `onPointerUp` colour rules).
Color _stainFor(_Sub s, bool bluePaper) {
  if (bluePaper) {
    if (s.kind == _Kind.acid) return const Color(0xFFEF4444);
    if (s.kind == _Kind.base) return const Color(0xFF1D4ED8);
  } else {
    if (s.kind == _Kind.base) return const Color(0xFF60A5FA);
    if (s.kind == _Kind.acid) return const Color(0xFF991B1B);
  }
  return s.color;
}

/// A movable object: rests at a world position, follows the finger in
/// design space while dragged and eases from wherever it is back to a
/// world position when released.
class _Body {
  _Body(this.id, this.start, {this.restAngle = 0})
      : world = start,
        angle = restAngle;

  final String id;
  final _V3 start;
  final double restAngle;
  _V3 world;

  /// Screen rotation (radians, clockwise). The dropper rests at 30°.
  double angle;
  bool visible = true;
  Offset? dragAt;
  double dragK = 1;

  Offset? _fromAt;
  double _fromK = 1, _fromAngle = 0, _t0 = 0, _dur = 0;

  bool get isDragging => dragAt != null;

  ({Offset p, double k, double a}) place(double time) {
    if (dragAt != null) return (p: dragAt!, k: dragK, a: angle);
    final pr = _projV(world);
    final from = _fromAt;
    if (from != null && _dur > 0) {
      final u = ((time - _t0) / _dur).clamp(0.0, 1.0);
      if (u < 1) {
        final e = Curves.easeOutCubic.transform(u);
        return (
          p: Offset.lerp(from, pr.p, e)!,
          k: _lerp(_fromK, pr.k, e),
          a: _lerp(_fromAngle, angle, e),
        );
      }
    }
    return (p: pr.p, k: pr.k, a: angle);
  }

  /// Eases from the current on-screen pose to [target].
  void moveTo(_V3 target, double time, {double dur = 0.25, double? angle}) {
    final cur = place(time);
    _fromAt = cur.p;
    _fromK = cur.k;
    _fromAngle = cur.a;
    _t0 = time;
    _dur = dur;
    dragAt = null;
    world = target;
    if (angle != null) this.angle = angle;
  }

  void reset() {
    world = start;
    angle = restAngle;
    dragAt = null;
    _fromAt = null;
  }
}

class _Beaker extends _Body {
  _Beaker(super.id, this.sub, super.start);
  final _Sub sub;
}

class _Dropper extends _Body {
  _Dropper() : super('dropper', const _V3(3.5, 0.6, -0.5), restAngle: math.pi / 6);

  /// Liquid drawn inside the glass tube (null = empty).
  _Sub? liquid;
  double liquidT0 = -10;

  /// Start of the squeeze / dip animation while filling.
  double dipT0 = -10;

  @override
  void reset() {
    super.reset();
    liquid = null;
    liquidT0 = -10;
    dipT0 = -10;
  }
}

class _Paper {
  _Paper(this.id, this.labelKey, this.color, this.pos);
  final String id;
  final String labelKey;
  final Color color;
  final _V3 pos;

  /// White flash (150 ms) when the drop lands, then the stain spreads.
  double flashT0 = -10;
  Color? stain;
  double stainT0 = -10;

  bool get isBlue => id == 'litmus_blue';

  void reset() {
    flashT0 = -10;
    stain = null;
    stainT0 = -10;
  }
}

class _Tray {
  _Tray(this.id, this.labelKey, this.pos);
  final String id;
  final String labelKey;
  final _V3 pos;
  static const double w = 2.5, d = 1.8;

  /// Turns green (0x4ade80) once both beakers are classified.
  bool done = false;
}

/// The falling droplet (HTML `triggerDropAnimation`).
class _Drop {
  _Drop(this.from, this.to, this.color, this.t0);
  final Offset from, to;
  final Color color;
  final double t0;
  static const double dur = 0.24;
}

class _Scene {
  double time = 0;
  int scenario = 0;

  final Map<String, _Beaker> beakers = {
    'beaker_lemon': _Beaker('beaker_lemon', _lemon, const _V3(-3.8, 2.3, -1)),
    'beaker_vinegar': _Beaker('beaker_vinegar', _vinegar, const _V3(-2.5, 2.3, -1)),
    'beaker_water': _Beaker('beaker_water', _water, const _V3(-1.2, 2.3, -1)),
    'beaker_soap': _Beaker('beaker_soap', _soap, const _V3(-3.8, 0.05, -1)),
    'beaker_baking_soda': _Beaker('beaker_baking_soda', _baking, const _V3(-2.5, 0.05, -1)),
  };
  final _Dropper dropper = _Dropper();
  final _Paper blue = _Paper('litmus_blue', 'lbl_blue', _blueLitmus, const _V3(1.0, 0.06, 1.2));
  final _Paper red = _Paper('litmus_red', 'lbl_red', _redLitmus, const _V3(3.0, 0.06, 1.2));
  final _Tray acids = _Tray('box_acids', 'lbl_box_acid', const _V3(-1.5, 0.025, 2.5));
  final _Tray bases = _Tray('box_bases', 'lbl_box_base', const _V3(2.5, 0.025, 2.5));
  _Drop? drop;

  /// Object being dragged and the drop target currently under it.
  _Body? dragging;
  String? hover;

  static const _V3 tileSpot = _V3(2.0, 0.05, 0.5);

  _Paper paper(String id) => id == 'litmus_blue' ? blue : red;
  _Tray tray(String id) => id == 'box_acids' ? acids : bases;

  /// HTML `reset3DSceneForScenario()`.
  void resetForScenario() {
    for (final b in beakers.values) {
      b.reset();
    }
    dropper.reset();
    blue.reset();
    red.reset();
    acids.done = false;
    bases.done = false;
    drop = null;
    dragging = null;
    hover = null;
    final s1 = scenario == 0;
    beakers['beaker_lemon']!.visible = s1;
    beakers['beaker_vinegar']!.visible = s1;
    beakers['beaker_water']!.visible = s1;
    beakers['beaker_soap']!.visible = !s1;
    beakers['beaker_baking_soda']!.visible = !s1;
  }
}

// ------------------------------------------------------ geometry helpers

/// Screen bounds of a beaker whose base centre is at [at].
Rect _beakerRect(Offset at, double k) {
  final rx = 0.35 * k;
  final ry = rx * _sinP;
  final h = 0.7 * k * _cosP;
  return Rect.fromLTRB(at.dx - rx, at.dy - h - ry, at.dx + rx, at.dy + ry);
}

/// Dropper drawing unit (pixels per world unit along its own axis).
double _dropperUnit(double k) => k * _cosP;

/// Tip of the dropper glass (origin = bulb neck, tube points down).
Offset _dropperTip(Offset at, double k, double a) {
  final l = 0.6 * _dropperUnit(k);
  return at + Offset(-math.sin(a) * l, math.cos(a) * l);
}

Rect _dropperRect(Offset at, double k, double a) {
  final tip = _dropperTip(at, k, a);
  final u = _dropperUnit(k);
  final top = at.translate(0, -0.3 * u);
  return Rect.fromPoints(top, tip).inflate(0.22 * u);
}

/// Projected quad of a flat rectangle lying on y (centre cx, cz).
Path _flatQuad(double cx, double y, double cz, double w, double d) {
  final a = _pt(cx - w / 2, y, cz - d / 2);
  final b = _pt(cx + w / 2, y, cz - d / 2);
  final c = _pt(cx + w / 2, y, cz + d / 2);
  final e = _pt(cx - w / 2, y, cz + d / 2);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..lineTo(c.dx, c.dy)
    ..lineTo(e.dx, e.dy)
    ..close();
}

Path _tileQuad({double grow = 0}) => _flatQuad(2.0, 0.05, 0.5, 3 + grow, 2 + grow);

Path _trayQuad(_Tray t, {double grow = 0}) =>
    _flatQuad(t.pos.x, 0.05, t.pos.z, _Tray.w + grow, _Tray.d + grow);

/// Screen rect around a litmus strip, used as its drop zone.
Rect _paperRect(_Paper p, {double grow = 0}) {
  final a = _pt(p.pos.x - 0.6 - grow, p.pos.y, p.pos.z - 0.15 - grow);
  final b = _pt(p.pos.x + 0.6 + grow, p.pos.y, p.pos.z + 0.15 + grow);
  return Rect.fromPoints(a, b);
}

// ============================================================ PAINTING

const Color _outline = Color(0xFF1E293B); // HTML addCartoonOutline colour
const Color _shelfColor = Color(0xFF94A3B8);
const Color _wood = Color(0xFF8B5A2B);
const Color _trayGrey = Color(0xFF9CA3AF);
const Color _trayGreen = Color(0xFF4ADE80);
const Color _zslYellow = Color(0xFFEAB308);

class _LitmusPainter extends CustomPainter {
  _LitmusPainter({
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

  /// Translated scene labels by key (lbl_*).
  final Map<String, String> labels;
  final String lang;

  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRoom(canvas, size);
    _paintShelf(canvas);
    _paintBench(canvas);
    final dragged = scene.dragging;
    if (dragged != null) _paintBody(canvas, dragged, lifted: true);
    if (showLabels) _paintLabels(canvas);
  }

  // -------------------------------------------------------------- room

  void _paintRoom(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    final backY = _pt(0, 0, -2.2).dy;
    final wall = Rect.fromLTRB(bleed.left, bleed.top, bleed.right, backY + 1);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, backY)),
    );
    // Faint wall tiles.
    final grid = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var y = backY - 46.0; y > bleed.top; y -= 46) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
    for (var x = 0.0; x < size.width; x += 64) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, backY), grid);
    }
    // Wooden lab bench top (HTML bench 0x8B5A2B), extended across the room.
    final bl = _pt(-40, 0, -2.2), br = _pt(40, 0, -2.2);
    final fl = _pt(-40, 0, 3.7), fr = _pt(40, 0, 3.7);
    final top = Path()
      ..moveTo(bl.dx, bl.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(fr.dx, fr.dy)
      ..lineTo(fl.dx, fl.dy)
      ..close();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_wood, -0.12), labShade(_wood, 0.08)],
        ).createShader(Rect.fromLTRB(0, bl.dy, size.width, fl.dy)),
    );
    // Wood grain lines running towards the viewer.
    final grain = Paint()
      ..color = labShade(_wood, -0.35).withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = -8.0; x <= 9; x += 0.9) {
      canvas.drawLine(_pt(x, 0, -2.2), _pt(x + 0.15, 0, 3.7), grain);
    }
    // Contact shadow where the bench meets the wall.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bl.dy, bleed.right, bl.dy + 14),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0)],
        ).createShader(Rect.fromLTRB(0, bl.dy, 10, bl.dy + 14)),
    );
    // Front face of the bench down to the floor.
    final front = Rect.fromLTRB(bleed.left, fl.dy, bleed.right, bleed.bottom);
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_wood, -0.3), labShade(_wood, -0.6)],
        ).createShader(Rect.fromLTRB(0, fl.dy, 10, fl.dy + 90)),
    );
    canvas.drawLine(
      Offset(bleed.left, fl.dy),
      Offset(bleed.right, fl.dy),
      Paint()
        ..color = labShade(_wood, 0.3)
        ..strokeWidth = 2.5,
    );
    final seam = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    for (var x = -9.0; x <= 11; x += 2.6) {
      final p = _pt(x, 0, 3.7);
      canvas.drawLine(Offset(p.dx, fl.dy + 10), Offset(p.dx, bleed.bottom), seam);
    }
  }

  // ------------------------------------------------------------ cuboid

  /// Box centred at (cx, cy, cz) with size (sx, sy, sz): draws the faces
  /// that face the camera with simple shading and a cartoon outline.
  void _cuboid(
    Canvas canvas,
    double cx,
    double cy,
    double cz,
    double sx,
    double sy,
    double sz,
    Color color, {
    double opacity = 1,
    bool outline = true,
  }) {
    final x0 = cx - sx / 2, x1 = cx + sx / 2;
    final y0 = cy - sy / 2, y1 = cy + sy / 2;
    final z0 = cz - sz / 2, z1 = cz + sz / 2;
    Path quad(Offset a, Offset b, Offset c, Offset d) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
    Color a(Color c) => c.withValues(alpha: c.a * opacity);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..color = a(_outline.withValues(alpha: 0.85));
    const camX = _lookX;
    final faces = <(Path, Color)>[];
    if (camX > x1) {
      faces.add((
        quad(_pt(x1, y0, z0), _pt(x1, y0, z1), _pt(x1, y1, z1), _pt(x1, y1, z0)),
        labShade(color, -0.28),
      ));
    } else if (camX < x0) {
      faces.add((
        quad(_pt(x0, y0, z0), _pt(x0, y0, z1), _pt(x0, y1, z1), _pt(x0, y1, z0)),
        labShade(color, -0.28),
      ));
    }
    faces.add((
      quad(_pt(x0, y1, z0), _pt(x1, y1, z0), _pt(x1, y1, z1), _pt(x0, y1, z1)),
      labShade(color, 0.16),
    ));
    final frontQuad = quad(_pt(x0, y0, z1), _pt(x1, y0, z1), _pt(x1, y1, z1), _pt(x0, y1, z1));
    faces.add((frontQuad, labShade(color, -0.06)));
    for (final f in faces) {
      canvas.drawPath(f.$1, Paint()..color = a(f.$2));
      if (outline) canvas.drawPath(f.$1, edge);
    }
  }

  // ------------------------------------------------------------- shelf

  void _paintShelf(Canvas canvas) {
    // Back panel 4 x 5 x 0.2 (shelfGroup at (-2.5, 0, -1)).
    _cuboid(canvas, -2.5, 2.5, -1.6, 4, 5, 0.2, _shelfColor);
    // Bottom shelf + beakers resting on it.
    _cuboid(canvas, -2.5, -0.05, -1, 4, 0.1, 1.2, _shelfColor);
    for (final b in _shelfBeakers(0.05)) {
      _paintBody(canvas, b);
    }
    // Middle shelf + beakers.
    _cuboid(canvas, -2.5, 2.2, -1, 4, 0.1, 1.2, _shelfColor);
    for (final b in _shelfBeakers(2.3)) {
      _paintBody(canvas, b);
    }
    // Top shelf (above the view, like the HTML camera framing).
    _cuboid(canvas, -2.5, 4.8, -1, 4, 0.1, 1.2, _shelfColor);
    // Side uprights holding the shelves.
    _cuboid(canvas, -4.55, 2.4, -1.05, 0.1, 4.9, 1.3, labShade(_shelfColor, -0.08));
    _cuboid(canvas, -0.45, 2.4, -1.05, 0.1, 4.9, 1.3, labShade(_shelfColor, -0.08));
  }

  /// Visible beakers resting at their shelf start position at height [y].
  Iterable<_Beaker> _shelfBeakers(double y) => scene.beakers.values.where((b) =>
      b.visible &&
      !b.isDragging &&
      b.start.y == y &&
      identical(b.world, b.start) &&
      !_inTransit(b));

  bool _inTransit(_Body b) => b.place(t).p != _projV(b.world).p;

  // ------------------------------------------------------------- bench

  void _paintBench(Canvas canvas) {
    // White tile 3 x 0.05 x 2 at (2, 0.025, 0.5).
    _cuboid(canvas, 2.0, 0.025, 0.5, 3, 0.05, 2, const Color(0xFFFFFFFF));
    final tq = _flatQuad(2.0, 0.051, 0.5, 2.6, 1.6);
    canvas.drawPath(
      tq,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0), const Color(0x1494A3B8)],
        ).createShader(tq.getBounds()),
    );
    _paintSpotRing(canvas);
    _paintPaper(canvas, scene.blue);
    _paintPaper(canvas, scene.red);
    _paintTray(canvas, scene.acids);
    _paintTray(canvas, scene.bases);
    _paintStand(canvas);

    // Beakers away from the shelf (on the tile, in trays or flying back).
    final loose = scene.beakers.values
        .where((b) =>
            b.visible && !b.isDragging && (!identical(b.world, b.start) || _inTransit(b)))
        .toList()
      ..sort((a, b) => a.world.z.compareTo(b.world.z));
    for (final b in loose) {
      _paintBody(canvas, b);
    }
    if (!scene.dropper.isDragging) _paintBody(canvas, scene.dropper);
    _paintDrop(canvas);
  }

  void _paintSpotRing(Canvas canvas) {
    // HTML: opacity = 0.4 + sin(t * 4) * 0.2, brighter while hovered.
    final hover = scene.hover == 'tile';
    final c = _projV(_Scene.tileSpot);
    final op = hover ? 0.95 : 0.4 + math.sin(t * 4) * 0.2;
    final r = 0.425 * c.k;
    final rect = Rect.fromCenter(center: c.p, width: r * 2, height: r * 2 * _sinP);
    if (hover) {
      canvas.drawOval(
        rect.inflate(6),
        Paint()
          ..color = _zslYellow.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3, 0.05 * c.k)
        ..color = _zslYellow.withValues(alpha: op.clamp(0, 1)),
    );
  }

  /// Generic draw for a movable body at its current pose.
  void _paintBody(Canvas canvas, _Body b, {bool lifted = false}) {
    final pl = b.place(t);
    if (b is _Beaker) {
      if (scene.hover == b.id) _hoverGlow(canvas, _beakerRect(pl.p, pl.k));
      _drawBeaker(canvas, pl.p, pl.k, b.sub, lifted: lifted);
    } else if (b is _Dropper) {
      var at = pl.p;
      final dip = _dipAmount();
      if (dip > 0) at = at.translate(0, dip * pl.k * _cosP);
      _drawDropper(canvas, at, pl.k, pl.a, b, lifted: lifted);
    }
  }

  /// HTML `triggerFillAnimation`: the dropper dips 0.2 units for ~0.5 s.
  double _dipAmount() {
    final u = t - scene.dropper.dipT0;
    if (u < 0 || u > 0.48) return 0;
    if (u < 0.12) return 0.2 * (u / 0.12);
    if (u > 0.36) return 0.2 * (1 - (u - 0.36) / 0.12);
    return 0.2;
  }

  void _drawBeaker(Canvas canvas, Offset base, double k, _Sub sub, {bool lifted = false}) {
    final rx = 0.35 * k, ry = rx * _sinP, h = 0.7 * k * _cosP;
    final rl = 0.33 * k, hl = 0.4 * k * _cosP;
    if (lifted) {
      labGroundShadow(canvas, base.translate(0, 18), rx * 2.2, ry * 2.2, opacity: 0.22);
    } else {
      labGroundShadow(canvas, base.translate(0, ry * 0.4), rx * 2.3, ry * 2.4, opacity: 0.3);
    }
    Path body(double r, double top) => Path()
      ..moveTo(base.dx - r, base.dy - top)
      ..lineTo(base.dx - r, base.dy)
      ..arcTo(Rect.fromCenter(center: base, width: r * 2, height: r * 2 * _sinP), math.pi, -math.pi,
          false)
      ..lineTo(base.dx + r, base.dy - top)
      ..close();
    // Back of the glass (white, 15% like the HTML MeshBasicMaterial).
    final glass = body(rx, h);
    canvas.drawPath(glass, Paint()..color = Colors.white.withValues(alpha: 0.15));
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -h), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    // Liquid column.
    final liquidRect = Rect.fromLTRB(base.dx - rl, base.dy - hl, base.dx + rl, base.dy);
    final liq = body(rl, hl);
    final lc = sub.color.withValues(alpha: sub.opacity);
    canvas.drawPath(
      liq,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(lc, -0.22),
          labShade(lc, 0.12),
          lc,
          labShade(lc, -0.3),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(liquidRect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -hl), width: rl * 2, height: rl * 2 * _sinP),
      Paint()..color = labShade(lc, 0.25),
    );
    canvas.drawPath(
      liq,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(lc, -0.45).withValues(alpha: 0.6),
    );
    // Front glass: highlight, graduations, rim and cartoon outline.
    canvas.drawLine(
      base.translate(-rx * 0.55, -h * 0.85),
      base.translate(-rx * 0.55, -h * 0.15),
      Paint()
        ..strokeWidth = math.max(2, rx * 0.14)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    final tick = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.75);
    for (var i = 1; i <= 3; i++) {
      final y = base.dy - h * i / 4.2;
      canvas.drawLine(Offset(base.dx + rx * 0.35, y), Offset(base.dx + rx * 0.8, y), tick);
    }
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..color = _outline;
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - rx, base.dy - h)
        ..lineTo(base.dx - rx, base.dy)
        ..arcTo(Rect.fromCenter(center: base, width: rx * 2, height: ry * 2), math.pi, -math.pi,
            false)
        ..lineTo(base.dx + rx, base.dy - h),
      edge,
    );
    final rim = Rect.fromCenter(center: base.translate(0, -h), width: rx * 2, height: ry * 2);
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawOval(rim, edge);
    // Small pouring spout on the rim.
    final sp = base.translate(-rx, -h);
    canvas.drawPath(
      Path()
        ..moveTo(sp.dx + 2, sp.dy - 1)
        ..lineTo(sp.dx - rx * 0.18, sp.dy - ry * 0.5)
        ..lineTo(sp.dx + 2, sp.dy + ry * 0.5),
      edge,
    );
  }

  void _drawDropper(Canvas canvas, Offset at, double k, double a, _Dropper d,
      {bool lifted = false}) {
    final u = _dropperUnit(k);
    if (lifted) {
      labGroundShadow(canvas, at.translate(0, 0.8 * u), 0.5 * u, 0.12 * u, opacity: 0.2);
    }
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(a);
    // Glass tube (radius 0.04 -> 0.015, 0.6 long, white @ 0.6).
    final tube = Path()
      ..moveTo(-0.04 * u, 0)
      ..lineTo(-0.015 * u, 0.6 * u)
      ..lineTo(0.015 * u, 0.6 * u)
      ..lineTo(0.04 * u, 0)
      ..close();
    canvas.drawPath(tube, Paint()..color = Colors.white.withValues(alpha: 0.6));
    // Liquid drawn up into the tube (0.035 -> 0.01, from 0.2 to 0.6).
    final sub = d.liquid;
    if (sub != null) {
      final level = ((t - d.liquidT0) / 0.2).clamp(0.0, 1.0);
      if (level > 0) {
        final topY = 0.6 * u - 0.4 * u * level;
        double wAt(double y) => _lerp(0.035, 0.01, (y / u - 0.2) / 0.4) * u;
        final liq = Path()
          ..moveTo(-wAt(topY), topY)
          ..lineTo(-0.01 * u, 0.6 * u)
          ..lineTo(0.01 * u, 0.6 * u)
          ..lineTo(wAt(topY), topY)
          ..close();
        canvas.drawPath(liq, Paint()..color = sub.color.withValues(alpha: sub.opacity));
      }
    }
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round
      ..color = _outline;
    canvas.drawPath(tube, edge);
    canvas.drawLine(
      Offset(-0.018 * u, 0.06 * u),
      Offset(-0.008 * u, 0.5 * u),
      Paint()
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.8),
    );
    // Rubber bulb (sphere r 0.12 scaled 1.5 in y, centre +0.08).
    final squeeze = _dipAmount() > 0 ? 0.85 : 1.0;
    final bulb = Rect.fromCenter(
      center: Offset(0, -0.08 * u),
      width: 0.24 * u * squeeze,
      height: 0.36 * u,
    );
    canvas.drawOval(
      bulb,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          colors: [Color(0xFF6B6B6B), Color(0xFF333333), Color(0xFF151515)],
          stops: [0, 0.55, 1],
        ).createShader(bulb),
    );
    canvas.drawOval(bulb, edge);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0.09 * u), width: 0.13 * u, height: 0.05 * u),
        Radius.circular(0.02 * u),
      ),
      Paint()..color = const Color(0xFF262626),
    );
    canvas.restore();
  }

  void _hoverGlow(Canvas canvas, Rect r, {Color color = _zslYellow}) {
    final rr = RRect.fromRectAndRadius(r.inflate(6), const Radius.circular(12));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = color.withValues(alpha: 0.28 + 0.12 * math.sin(t * 8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.9),
    );
  }

  /// Curved litmus strip 1.2 x 0.3 (arched 0.05 up in the middle) with the
  /// circular stain (r 0.3) that appears where the drop lands.
  void _paintPaper(Canvas canvas, _Paper p) {
    final strip = Path();
    const n = 16;
    for (var i = 0; i <= n; i++) {
      final lx = -0.6 + 1.2 * i / n;
      final nx = lx / 0.6;
      final o = _pt(p.pos.x + lx, p.pos.y + (1 - nx * nx) * 0.05, p.pos.z - 0.15);
      i == 0 ? strip.moveTo(o.dx, o.dy) : strip.lineTo(o.dx, o.dy);
    }
    for (var i = n; i >= 0; i--) {
      final lx = -0.6 + 1.2 * i / n;
      final nx = lx / 0.6;
      final o = _pt(p.pos.x + lx, p.pos.y + (1 - nx * nx) * 0.05, p.pos.z + 0.15);
      strip.lineTo(o.dx, o.dy);
    }
    strip.close();
    final bounds = strip.getBounds();
    labGroundShadow(canvas, bounds.bottomCenter.translate(0, 1), bounds.width * 1.02, 8,
        opacity: 0.18);
    final flashing = t >= p.flashT0 && t < p.flashT0 + 0.15;
    final base = flashing ? Colors.white : p.color;
    canvas.drawPath(
      strip,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(base, -0.12),
          labShade(base, 0.12),
          labShade(base, -0.12),
        ]).createShader(bounds),
    );
    final stain = p.stain;
    if (stain != null && t >= p.stainT0) {
      final spread = Curves.easeOutCubic.transform(((t - p.stainT0) / 0.2).clamp(0.0, 1.0));
      final c = _projV(p.pos.up(0.05));
      final r = 0.3 * c.k * (0.35 + 0.65 * spread);
      final oval = Rect.fromCenter(center: c.p, width: r * 2, height: r * 2 * _sinP);
      canvas.save();
      canvas.clipPath(strip);
      canvas.drawOval(oval, Paint()..color = stain);
      canvas.drawOval(
        oval.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = labShade(stain, -0.3).withValues(alpha: 0.6),
      );
      canvas.restore();
    }
    canvas.drawPath(
      strip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = _outline,
    );
    // Splash ripple when the drop lands.
    final rt = t - p.flashT0;
    if (rt >= 0 && rt < 0.45) {
      final c = _projV(p.pos.up(0.05));
      final r = 0.12 * c.k + rt * 0.9 * c.k;
      canvas.drawOval(
        Rect.fromCenter(center: c.p, width: r * 2, height: r * 2 * _sinP),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: (1 - rt / 0.45) * 0.9),
      );
    }
    if (scene.hover == p.id) _hoverGlow(canvas, bounds);
  }

  /// Grey classification tray 2.5 x 1.8 with a low rim; turns green.
  void _paintTray(Canvas canvas, _Tray tr) {
    final color = tr.done ? _trayGreen : _trayGrey;
    final x = tr.pos.x, z = tr.pos.z;
    const w = _Tray.w, d = _Tray.d;
    labGroundShadow(canvas, _pt(x, 0, z + 0.2), w * 95, 26, opacity: 0.25);
    _cuboid(canvas, x, 0.025, z, w, 0.05, d, color);
    const rh = 0.16, rt = 0.07;
    final rim = labShade(color, -0.08);
    _cuboid(canvas, x, 0.05 + rh / 2, z - d / 2 + rt / 2, w, rh, rt, rim);
    _cuboid(canvas, x - w / 2 + rt / 2, 0.05 + rh / 2, z, rt, rh, d, rim);
    _cuboid(canvas, x + w / 2 - rt / 2, 0.05 + rh / 2, z, rt, rh, d, rim);
    _cuboid(canvas, x, 0.05 + rh / 2, z + d / 2 - rt / 2, w, rh, rt, rim);
    if (scene.hover == tr.id || tr.done) {
      final q = _trayQuad(tr);
      canvas.drawPath(
        q,
        Paint()
          ..color = _trayGreen.withValues(alpha: tr.done ? 0.35 : 0.3 + 0.15 * math.sin(t * 8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
  }

  /// Small stand the dropper rests in (the HTML text mentions a stand).
  void _paintStand(Canvas canvas) {
    const steel = Color(0xFF64748B);
    _cuboid(canvas, 3.9, 0.04, -0.5, 0.6, 0.08, 0.45, const Color(0xFF475569));
    final a = _projV(const _V3(3.95, 0.08, -0.5));
    final b = _projV(const _V3(3.95, 0.95, -0.5));
    final rod = Rect.fromLTRB(a.p.dx - 0.035 * a.k, b.p.dy, a.p.dx + 0.035 * a.k, a.p.dy);
    labCylinder(canvas, rod, steel, tilt: 0.3);
    final arm0 = _pt(3.95, 0.62, -0.5), arm1 = _pt(3.62, 0.62, -0.5);
    canvas.drawLine(
      arm0,
      arm1,
      Paint()
        ..strokeWidth = 0.05 * a.k
        ..strokeCap = StrokeCap.round
        ..color = labShade(steel, -0.15),
    );
    canvas.drawOval(
      Rect.fromCenter(center: arm1, width: 0.16 * a.k, height: 0.07 * a.k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = labShade(steel, 0.1),
    );
  }

  void _paintDrop(Canvas canvas) {
    final d = scene.drop;
    if (d == null) return;
    final u = (t - d.t0) / _Drop.dur;
    if (u < 0 || u > 1) return;
    final p = Offset.lerp(d.from, d.to, Curves.easeIn.transform(u))!;
    final r = 5.5;
    final path = Path()
      ..moveTo(p.dx, p.dy - r * 2.1)
      ..quadraticBezierTo(p.dx + r * 1.2, p.dy - r * 0.2, p.dx, p.dy + r)
      ..quadraticBezierTo(p.dx - r * 1.2, p.dy - r * 0.2, p.dx, p.dy - r * 2.1)
      ..close();
    final c = d.color.computeLuminance() > 0.8 ? const Color(0xFFBAE6FD) : d.color;
    canvas.drawPath(path, Paint()..color = c);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _outline.withValues(alpha: 0.7),
    );
    canvas.drawCircle(p.translate(-r * 0.35, -r * 0.3), r * 0.3, Paint()..color = Colors.white70);
  }

  // ------------------------------------------------------------ labels

  void _label(Canvas canvas, String key, Offset at, {Alignment anchor = Alignment.center}) {
    labText(
      canvas,
      labels[key] ?? key,
      at,
      size: 15,
      weight: FontWeight.w700,
      anchor: anchor,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      background: isDark ? const Color(0xFF1E293B) : Colors.white,
      border: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
      borderWidth: 2,
      radius: 4,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    );
  }

  void _paintLabels(Canvas canvas) {
    for (final b in scene.beakers.values) {
      if (!b.visible) continue;
      final pl = b.place(t);
      _label(canvas, b.sub.key, pl.p.translate(0, -0.9 * pl.k * _cosP));
    }
    for (final p in [scene.blue, scene.red]) {
      _label(canvas, p.labelKey, _pt(p.pos.x, p.pos.y, p.pos.z + 0.3),
          anchor: Alignment.topCenter);
    }
    final d = scene.dropper.place(t);
    _label(canvas, 'lbl_dropper', d.p.translate(0, -0.45 * _dropperUnit(d.k)));
    for (final tr in [scene.acids, scene.bases]) {
      _label(canvas, tr.labelKey, _pt(tr.pos.x, 0.12, tr.pos.z + _Tray.d / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LitmusPainter old) =>
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
