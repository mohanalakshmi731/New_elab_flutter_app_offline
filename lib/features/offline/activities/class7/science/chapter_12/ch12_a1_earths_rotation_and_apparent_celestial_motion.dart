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

/// Class 7 Science • Chapter 12 • Activity 1
/// Earth's Rotation and Apparent Celestial Motion.
///
/// Native Flutter port of
/// `Cl7S-Ch12-A1-Earth_s_Rotation_and_Apparent_Celestial_Motion.html`.
/// Scenario 1: drag the observer onto a merry-go-round seat, switch to the
/// first-person view, spin the platform and watch the stationary trees
/// appear to move the other way. Scenario 2: drop a location pin on India,
/// dive into the night sky, identify the Big Dipper and the Pole Star and
/// run a time-lapse showing the sky turning around the Pole Star.
class Ch12A1EarthsRotationAndApparentCelestialMotionPage extends StatefulWidget {
  const Ch12A1EarthsRotationAndApparentCelestialMotionPage({super.key});

  @override
  State<Ch12A1EarthsRotationAndApparentCelestialMotionPage> createState() =>
      _Ch12A1EarthsRotationAndApparentCelestialMotionPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, pickup 2356.
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
  static const Color blue600 = Color(0xFF2563EB);
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

/// Pan recognizer that only claims touches starting on a draggable object
/// (the observer / the location pin), so empty-canvas drags still pan the
/// zoomed canvas.
class _A1GrabRecognizer extends PanGestureRecognizer {
  _A1GrabRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch12A1EarthsRotationAndApparentCelestialMotionPageState
    extends State<Ch12A1EarthsRotationAndApparentCelestialMotionPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A1Scene _scene = _A1Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;

  /// Elastic return of the observer after a wrong drop (500 ms).
  late final AnimationController _charBack;

  /// Arms reaching for the handle bar after seating (500 ms).
  late final AnimationController _arms;

  /// Location pin snapping home after a wrong drop.
  late final AnimationController _pinBack;

  /// Camera diving into the globe (1000 ms, Cubic.In).
  late final AnimationController _dive;

  _V3 _charFrom = _kA1CharInit;
  _V3 _dragOffset = _V3.zero;
  Offset _pinFrom = _kA1PinHome;
  Offset _pinGrab = Offset.zero;
  bool _conclusionQueued = false;

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

    _scene.reset();
    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
    })..start();

    _charBack = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        final v = Curves.elasticOut.transform(_charBack.value);
        _scene.charPos = _V3.lerp(_charFrom, _kA1CharInit, v);
      });
    _arms = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() => _scene.armPose = _arms.value);
    _pinBack = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
      ..addListener(() {
        final v = Curves.easeOutBack.transform(_pinBack.value);
        _scene.pinPos = Offset.lerp(_pinFrom, _kA1PinHome, v)!;
      });
    _dive = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        _scene.globeDist = 50 + (16 - 50) * Curves.easeInCubic.transform(_dive.value);
        _scene.diveT = Curves.easeInOutCubic.transform(_dive.value);
      });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _charBack.dispose();
    _arms.dispose();
    _pinBack.dispose();
    _dive.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ============================================================ LOGIC

  /// HTML `buildScenario()` (via `clearScene()`).
  void _buildScenario() {
    _lab.cancelPending();
    _charBack.stop();
    _arms.stop();
    _pinBack.stop();
    _dive.stop();
    _conclusionQueued = false;
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _scene.step = 1;
      _lab.hidePopup(sound: false);
      // HTML resetApp(true): labels on, camera locked, pan mode off.
      _lab.showLabels = true;
      _lab.camLocked = true;
      _lab.panMode = false;
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _scene.step = 1;
      _lab.camLocked = true;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    final steps = _data.steps;
    setState(() {
      if (_step < steps.length) {
        _scene.step++;
      } else if (_step == steps.length) {
        _showConclusion();
      }
    });
  }

  void _showConclusion() {
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      heading: () => _t('lbl_observation'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  // ------------------------------------------------------- scenario 1

  /// Generous touch target around the observer (HTML: raycast or < 85 px).
  bool _hitCharacter(Offset p) {
    final cam = _scene.cam1;
    final feet = cam.project(_scene.charPos);
    if (feet == null) return false;
    final k = cam.pxPerUnit(_scene.charPos + const _V3(0, 3, 0));
    final body = Rect.fromLTRB(feet.dx - 1.8 * k, feet.dy - 6.8 * k, feet.dx + 1.8 * k, feet.dy + 0.6 * k);
    return body.contains(p) || (p - feet).distance < 95;
  }

  void _grabCharacter(Offset p) {
    final hit = _scene.cam1.groundHit(p);
    if (hit == null) return;
    _charBack.stop();
    _dragOffset = hit - _scene.charPos;
    _scene.dragging = true;
    _Audio.play(_Sound.pickup);
  }

  void _dragCharacter(Offset p) {
    final hit = _scene.cam1.groundHit(p);
    if (hit == null) return;
    final pos = hit - _dragOffset;
    // Keep the observer on the visible part of the ground plane.
    _scene.charPos = _V3(pos.x.clamp(-60.0, 60.0), 0, pos.z.clamp(-60.0, 40.0));
  }

  /// HTML `checkCharacterDrop()`.
  void _dropCharacter() {
    _scene.dragging = false;
    if ((_scene.charPos - _scene.dropTargetWorld).length < 15) {
      _lab.showToast(_t('msg_seated'));
      setState(() {
        _scene.targetVisible = false;
        _scene.seated = true;
      });
      _arms.forward(from: 0);
      _advanceStep();
    } else {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
      _charFrom = _scene.charPos;
      _charBack.forward(from: 0);
    }
  }

  /// HTML `enterFPView()`.
  void _enterFPView() {
    if (_scenario != 0 || _step != 2 || _scene.fpView) return;
    setState(() {
      _scene.fpView = true;
      _scene.fpSince = _scene.time;
    });
    _lab.resetView(sound: false);
    _advanceStep();
  }

  /// HTML `handleMGRRotation()` (slider input).
  void _rotateMgr(double v) {
    setState(() {
      _scene.mgrDeg = v;
      if (_step == 5) _scene.pathVisible = true;
    });
  }

  /// HTML `checkMGRRotation()` (slider change).
  void _checkMgr(double v) {
    if (_step == 3 && (v <= -90 || v >= 90)) {
      _advanceStep();
      _lab.showToast(_t('msg_click_tree'));
    } else if (_step == 5 && v.abs() > 10 && !_conclusionQueued) {
      _conclusionQueued = true;
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scenario != 0) return;
        _showConclusion();
      });
    }
  }

  /// Index of the tree under [p] in the first-person view (nearest first).
  int? _treeAt(Offset p) {
    final cam = _scene.cam1;
    int? best;
    var bestDepth = double.infinity;
    for (var i = 0; i < _scene.trees.length; i++) {
      final t = _scene.trees[i];
      final d = cam.depth(t.pos);
      if (d <= 1) continue;
      final top = cam.project(t.pos + const _V3(0, 11, 0));
      final base = cam.project(t.pos);
      if (top == null || base == null) continue;
      final half = 4 * cam.pxPerUnit(t.pos + const _V3(0, 1, 0));
      final rect = Rect.fromLTRB(base.dx - half, top.dy, base.dx + half, base.dy).inflate(8);
      if (rect.contains(p) && d < bestDepth) {
        best = i;
        bestDepth = d;
      }
    }
    return best;
  }

  /// HTML `highlightTree()` + `advanceStep()`.
  void _selectTree(int i) {
    _Audio.play(_Sound.correct);
    setState(() => _scene.selectedTree = i);
    _advanceStep();
  }

  // ------------------------------------------------------- scenario 2

  bool _hitPin(Offset p) => (p - _scene.pinGrabCenter).distance < _scene.pinGrabRadius;

  void _grabPin(Offset p) {
    _pinBack.stop();
    _pinGrab = p - _scene.pinPos;
    _scene.pinDragging = true;
    _Audio.play(_Sound.pickup);
  }

  void _dragPin(Offset p) => _scene.pinPos = p - _pinGrab;

  /// HTML pin `pointerup`: dropping over the globe succeeds, anywhere else
  /// shows the error and sends the pin home.
  void _dropPin() {
    _scene.pinDragging = false;
    final disk = _scene.globeDisk();
    if ((_scene.pinPos - disk.c).distance <= disk.r + 8) {
      _pinDropSuccess();
    } else {
      _lab.showToast(_t('msg_wrong_pin'), isError: true);
      _pinFrom = _scene.pinPos;
      _pinBack.forward(from: 0);
    }
  }

  /// HTML `handlePinDropSuccess()`: dive into the globe, then the night sky.
  void _pinDropSuccess() {
    _Audio.play(_Sound.success);
    setState(() {
      _scene.pinVisible = false;
      _scene.pinOnIndia = true;
    });
    _dive.forward(from: 0).whenComplete(() {
      if (!mounted || _scenario != 1 || _dive.value < 1) return;
      setState(() {
        _scene.skyVisible = true;
        _scene.skySince = _scene.time;
        _scene.pinOnIndia = false;
      });
      _advanceStep();
      _lab.showToast(_t('msg_click_stars'));
    });
  }

  /// Taps near the Big Dipper or the Pole Star (HTML raycast on the sky).
  bool _hitConstellation(Offset p) {
    final cam = _A1Scene.skyCam;
    for (final s in [_kA1PoleStar, ..._kA1Dipper]) {
      final sp = cam.project(_scene.skyXf(s));
      if (sp != null && (sp - p).distance < 46) return true;
    }
    return false;
  }

  /// HTML `highlightConstellations()` + `advanceStep()`.
  void _highlightConstellations() {
    _Audio.play(_Sound.correct);
    setState(() => _scene.highlighted = true);
    _advanceStep();
  }

  /// HTML `handleTimeSlider()`.
  void _setTime(double v) {
    setState(() => _scene.timeVal = v);
    if (v >= 100 && _step == 3) {
      _Audio.play(_Sound.pop);
      _advanceStep();
    }
  }

  /// HTML `showSnapshots()` (the snapshots modal).
  void _showSnapshots() {
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('compare_title'),
        icon: Icons.photo_library,
        accent: const Color(0xFF818CF8),
        extra: _snapshotsRow(),
        actions: [
          LabAction(
            label: _t('btn_understood'),
            icon: Icons.check,
            color: _Colors.indigo600,
            foreground: Colors.white,
            onTap: _finishCompare,
          ),
        ],
      ),
      silent: true,
    );
  }

  /// HTML `finishCompare()`.
  void _finishCompare() {
    _lab.hidePopup(sound: false);
    _showConclusion();
  }

  // ------------------------------------------------------- gestures

  bool _canGrab(Offset p) {
    if (!_lab.isLabActive || _lab.popup != null) return false;
    if (_scenario == 0) return _step == 1 && !_scene.seated && _hitCharacter(p);
    return _step == 1 && _scene.pinVisible && !_dive.isAnimating && _hitPin(p);
  }

  void _onGrab(Offset p) {
    if (_scenario == 0) {
      _grabCharacter(p);
    } else {
      _grabPin(p);
    }
  }

  void _onDrag(Offset p) {
    if (_scenario == 0 && _scene.dragging) {
      _dragCharacter(p);
    } else if (_scenario == 1 && _scene.pinDragging) {
      _dragPin(p);
    }
  }

  void _onRelease() {
    if (_scenario == 0 && _scene.dragging) {
      _dropCharacter();
    } else if (_scenario == 1 && _scene.pinDragging) {
      _dropPin();
    }
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    if (_scenario == 0 && _step == 4 && _scene.fpView) {
      final i = _treeAt(p);
      if (i != null) _selectTree(i);
    } else if (_scenario == 1 && _step == 2 && _scene.skyVisible) {
      if (_hitConstellation(p)) _highlightConstellations();
    }
  }
  // ============================================================== UI

  /// Clock time for the time-lapse slider (9 PM .. 5 AM).
  String _clock(double val) {
    final mins = (21 * 60 + val / 100 * 8 * 60).round();
    final h24 = (mins ~/ 60) % 24;
    final m = mins % 60;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final key = h24 >= 12 ? 'time_pm' : (h24 < 4 ? 'time_am_night' : 'time_am_morning');
    return labFormat(_t(key), {'t': '$h12:${m.toString().padLeft(2, '0')}'});
  }

  List<LabAction> _actions() {
    if (_scenario == 0 && _step == 2 && _scene.seated && !_scene.fpView) {
      return [
        LabAction(
          label: _t('btn_fp_view'),
          icon: Icons.visibility,
          color: _Colors.blue600,
          foreground: Colors.white,
          highlight: true,
          onTap: _enterFPView,
        ),
      ];
    }
    if (_scenario == 1 && _step == 4) {
      return [
        LabAction(
          label: _t('btn_compare'),
          icon: Icons.photo_library,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _showSnapshots,
        ),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final pad = MediaQuery.paddingOf(context);
        final actions = _actions();
        return LabShell(
          controller: _lab,
          icon: Icons.public,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: actions,
          sidebarExtraTitle: _t('readouts'),
          sidebarExtra: _readouts(p, s),
          onReset: _fullReset,
          overlays: [
            // HTML #btn-fp-view (top centre of the canvas).
            if (_scenario == 0 && actions.isNotEmpty)
              Positioned(
                top: inset.top + 46 * s,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(action: actions.first, scale: s * 1.1, expand: false),
                  ),
                ),
              ),
            if (_scenario == 0 && _scene.fpView) _mgrSliderOverlay(p, s, inset),
            // HTML #s1-arrows "YOUR MOTION" (bottom centre, above the HUD).
            if (_scenario == 0 && _scene.fpView)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: (_lab.isSidebarOpen ? 14 + 58 * s : 12) + pad.bottom,
                child: IgnorePointer(
                  child: Center(
                    child: _motionHint(s, _t('your_motion'), const Color(0xFF60A5FA), up: false),
                  ),
                ),
              ),
            // HTML #btn-compare (top right of the canvas, clear of the toast).
            if (_scenario == 1 && actions.isNotEmpty)
              Positioned(
                top: inset.top + 42 * s,
                right: inset.right + 4,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 240 * s),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(action: actions.first, scale: s, expand: false),
                  ),
                ),
              ),
            if (_scenario == 1 && _scene.skyVisible)
              Positioned(
                left: 12,
                right: 60 + pad.right,
                bottom: (_lab.isSidebarOpen ? 8 + 60 * s : 10) + pad.bottom,
                child: _nightUi(p, s),
              ),
          ],
          stage: LayoutBuilder(builder: (context, box) => _stage(box)),
        );
      },
    );
  }

  /// The scene. Labels and the location pin grow when the stage is drawn
  /// small, so they keep roughly the HTML's fixed on-screen size.
  Widget _stage(BoxConstraints box) {
    final fit = math.min(box.maxWidth / _kA1Design.width, box.maxHeight / _kA1Design.height);
    final ls = fit > 0 && fit.isFinite ? (0.84 / fit).clamp(1.0, 2.0) : 1.0;
    _scene.uiScale = ls;
    return LabStage(
      designSize: _kA1Design,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _A1GrabRecognizer: GestureRecognizerFactoryWithHandlers<_A1GrabRecognizer>(
            _A1GrabRecognizer.new,
            (r) => r
              ..accepts = _canGrab
              ..dragStartBehavior = DragStartBehavior.down
              ..gestureSettings = const DeviceGestureSettings(touchSlop: 6)
              ..onStart = ((d) => _onGrab(d.localPosition))
              ..onUpdate = ((d) => _onDrag(d.localPosition))
              ..onEnd = ((_) => _onRelease())
              ..onCancel = _onRelease,
          ),
          TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            TapGestureRecognizer.new,
            (r) => r.onTapUp = _onTapUp,
          ),
        },
        child: CustomPaint(
          size: _kA1Design,
          painter: _A1Painter(
            scene: _scene,
            repaint: _frame,
            showLabels: _lab.showLabels,
            lang: _lab.lang,
            text: _t,
            labelScale: ls,
          ),
        ),
      ),
    );
  }

  Widget _readouts(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    String yn(bool v) => v ? _t('yes') : _t('no');
    final rows = _scenario == 0
        ? [
            (_t('lbl_view'), sc.fpView ? _t('view_fp') : _t('view_third'), null),
            (
              _t('lbl_rotation'),
              sc.mgrDeg.round() == 0 ? '0°' : '${sc.mgrDeg.abs().round()}° ${sc.mgrDeg < 0 ? _t('acw') : _t('cw')}',
              _Colors.blue,
            ),
            (_t('lbl_seated'), yn(sc.seated), sc.seated ? _Colors.green : null),
            (_t('lbl_ref_tree'), yn(sc.selectedTree != null), sc.selectedTree != null ? _Colors.zslYellow : null),
          ]
        : [
            (_t('lbl_location'), sc.skyVisible ? _t('loc_india') : _t('loc_space'), null),
            (_t('lbl_time'), _clock(sc.timeVal), const Color(0xFFFBBF24)),
            (_t('lbl_sky_rotation'), '${(sc.timeVal * 0.9).round()}°', const Color(0xFF818CF8)),
          ];
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
          for (final r in rows) LabInfoRow(palette: p, scale: f, label: r.$1, value: r.$2, valueColor: r.$3),
        ],
      ),
    );
  }

  SliderThemeData _sliderTheme(BuildContext context, LabPalette p, double s, Color accent) {
    return SliderTheme.of(context).copyWith(
      trackHeight: 7 * s,
      activeTrackColor: accent.withValues(alpha: 0.85),
      inactiveTrackColor: p.isDark ? const Color(0x33FFFFFF) : const Color(0x33000000),
      thumbColor: _Colors.zslYellow,
      overlayColor: _Colors.zslYellow.withValues(alpha: 0.2),
      thumbShape: _A1ThumbShape(radius: 11 * s),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 18 * s),
      showValueIndicator: ShowValueIndicator.never,
    );
  }

  /// HTML `#s1-arrows` group: a curved arrow and a dark caption pill.
  /// [up]: arrow above the caption (apparent motion of the trees),
  /// otherwise below it (your motion).
  Widget _motionHint(double s, String label, Color color, {required bool up}) {
    final arrow = SizedBox(
      width: 60 * s,
      height: 26 * s,
      child: CustomPaint(painter: _A1UArrowPainter(up: up, color: color.withValues(alpha: 0.9))),
    );
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12 * s,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: up
            ? [arrow, SizedBox(height: 2 * s), pill]
            : [pill, SizedBox(height: 2 * s), arrow],
      ),
    );
  }

  /// HTML `#s1-slider-container`: Rotate Left • Merry-Go-Round • Rotate Right,
  /// with the "apparent motion of trees" arrow below it.
  Widget _mgrSliderOverlay(LabPalette p, double s, EdgeInsets inset) {
    final f = 10.5 * s;
    TextStyle style(Color c) => TextStyle(color: c, fontSize: f, fontWeight: FontWeight.w800, letterSpacing: 0.8);
    return Positioned(
      top: inset.top + 40 * s,
      left: inset.left,
      right: inset.right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _mgrSliderCard(p, s, style),
          SizedBox(height: 4 * s),
          IgnorePointer(child: _motionHint(s, _t('apparent_motion'), _kA1Amber, up: true)),
        ],
      ),
    );
  }

  Widget _mgrSliderCard(LabPalette p, double s, TextStyle Function(Color) style) {
    return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 460 * s),
          child: LabGlassCard(
            palette: p,
            padding: EdgeInsets.fromLTRB(14 * s, 8 * s, 14 * s, 0),
            borderColor: _Colors.blue.withValues(alpha: 0.35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_t('rotate_left').toUpperCase(), style: style(p.textStrong))),
                    Expanded(
                      child: Text(
                        _t('merry_go_round').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style(_Colors.blue),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _t('rotate_right').toUpperCase(),
                        textAlign: TextAlign.right,
                        style: style(p.textStrong),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 34 * s,
                  child: SliderTheme(
                    data: _sliderTheme(context, p, s, _Colors.blue),
                    child: Slider(
                      value: _scene.mgrDeg,
                      min: -180,
                      max: 180,
                      onChanged: _rotateMgr,
                      onChangeEnd: _checkMgr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  /// HTML `#s2-night-ui`: compass "N" and, once the constellations are
  /// highlighted, the time-lapse panel with the picture-in-picture Earth.
  Widget _nightUi(LabPalette p, double s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: Text(
            _t('compass_n'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w800,
              fontSize: 18 * s,
              letterSpacing: 6 * s,
              shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
            ),
          ),
        ),
        if (_scene.highlighted) ...[
          SizedBox(height: 4 * s),
          _timePanel(p, s),
        ],
      ],
    );
  }

  /// HTML `#s2-time-container`.
  Widget _timePanel(LabPalette p, double s) {
    const indigo = Color(0xFF6366F1);
    final labelStyle = TextStyle(color: p.text, fontSize: 10 * s, fontWeight: FontWeight.w800);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 540 * s),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 12 * s, 4 * s),
        borderColor: indigo.withValues(alpha: 0.45),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54 * s,
                  height: 54 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: indigo, width: 2),
                    boxShadow: [BoxShadow(color: indigo.withValues(alpha: 0.5), blurRadius: 12)],
                  ),
                  child: ClipOval(
                    child: CustomPaint(painter: _A1PipPainter(angle: -_scene.timeVal * 3.6 * math.pi / 180)),
                  ),
                ),
                SizedBox(height: 4 * s),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 92 * s),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        _t('earth_rotation'),
                        style: TextStyle(color: const Color(0xFFA5B4FC), fontSize: 9.5 * s, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rotate_left, size: 18 * s, color: const Color(0xFFFCD34D)),
                          SizedBox(width: 4 * s),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              _t('star_motion'),
                              style: TextStyle(color: const Color(0xFFFCD34D), fontSize: 10 * s, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final k in ['t_9pm', 't_12am', 't_3am', 't_5am'])
                          Flexible(child: Text(_t(k), style: labelStyle, maxLines: 1, overflow: TextOverflow.fade, softWrap: false)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32 * s,
                    child: SliderTheme(
                      data: _sliderTheme(context, p, s, indigo),
                      child: Slider(
                        value: _scene.timeVal,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: _setTime,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Three night-sky snapshots (9 PM, 1 AM, 5 AM) for the compare popup,
  /// followed by the HTML description text.
  Widget _snapshotsRow() {
    final s = context.labScale;
    final p = _Theme.of(_lab.isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final v in const [0.0, 50.0, 100.0])
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3 * s),
                  child: Container(
                    padding: EdgeInsets.all(5 * s),
                    decoration: BoxDecoration(
                      color: _Colors.slate800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _Colors.slate700),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          // Flatter frames on short screens so the popup fits.
                          aspectRatio: MediaQuery.sizeOf(context).height < 420 ? 1.4 : 1.15,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CustomPaint(
                              painter: _A1SnapshotPainter(
                                angle: -(v / 100) * math.pi / 2,
                                north: _t('compass_n'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5 * s),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _clock(v),
                            style: TextStyle(
                              color: const Color(0xFFFBBF24),
                              fontWeight: FontWeight.w800,
                              fontSize: 12 * s,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12 * s),
        Text(
          _t('snapshot_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.4),
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': "Earth's Rotation & Apparent Motion",
    'app_subtitle': 'Class 7 • Earth, Moon and the Sun',
    'scen_1_opt': 'Scenario 1: Merry-Go-Round Perspective',
    'scen_2_opt': 'Scenario 2: Watching the Stars Go By',
    'sci_conclusion': 'Success!',
    'lbl_observation': 'Observation',
    'btn_fp_view': 'First-Person View',
    'rotate_left': 'Rotate Left',
    'rotate_right': 'Rotate Right',
    'merry_go_round': 'Merry-Go-Round',
    'your_motion': 'YOUR MOTION',
    'apparent_motion': 'APPARENT MOTION OF TREES',
    'drag_pin': 'Drag pin to India',
    'earth_rotation': "Earth's Actual Rotation",
    'star_motion': "Stars' Apparent Motion",
    'btn_compare': 'Compare Snapshots',
    'compare_title': 'Compare Snapshots',
    'snapshot_desc':
        'Notice how the Big Dipper constellation appears to rotate in an arc around the stationary Pole Star as the night progresses.',
    'btn_understood': 'I Understand',
    'msg_wrong_drop': 'Drop the character on the Merry-Go-Round seat!',
    'msg_wrong_pin': 'Drop the pin on India (the front side of the globe).',
    'msg_seated': 'Character Seated!',
    'msg_click_tree': 'Great! Now click a tree.',
    'msg_click_stars': 'Click the constellations!',
    'conclusion_1':
        'When you rotate anti-clockwise on the merry-go-round, the stationary trees in the background appear to move clockwise. This is called relative or apparent motion. The same principle applies to Earth!',
    'conclusion_2':
        "The Earth spins West to East (anti-clockwise from above). This makes the stationary stars appear to move across the sky from East to West. The Pole Star seems stationary because it's located directly above Earth's axis of rotation.",
    'lbl_big_dipper': 'Big Dipper (Saptarishi)',
    'lbl_pole_star': 'Pole Star (Dhruva Tara)',
    'lbl_character': 'Observer',
    'lbl_target_tree': 'Reference Tree',
    'lbl_mgr': 'Merry-Go-Round',
    'lbl_india': 'India',
    // Strings that were hard-coded in the HTML.
    'compass_n': 'N',
    't_9pm': '9 PM',
    't_12am': '12 AM',
    't_3am': '3 AM',
    't_5am': '5 AM',
    'time_pm': '{t} PM',
    'time_am_night': '{t} AM',
    'time_am_morning': '{t} AM',
    'readouts': 'Live Readings',
    'lbl_view': 'View',
    'view_third': 'Third-Person',
    'view_fp': 'First-Person',
    'lbl_rotation': 'Platform Rotation',
    'lbl_seated': 'Observer Seated',
    'lbl_ref_tree': 'Reference Tree Selected',
    'lbl_location': 'Observer Location',
    'loc_space': 'In Space (Globe)',
    'loc_india': 'India (Night Sky)',
    'lbl_time': 'Time',
    'lbl_sky_rotation': 'Sky Rotation',
    'yes': 'Yes',
    'no': 'No',
    'acw': 'anti-clockwise',
    'cw': 'clockwise',
  },
  'hi': {
    'app_title': 'पृथ्वी का घूर्णन और आभासी गति',
    'app_subtitle': 'कक्षा 7 • पृथ्वी, चंद्रमा और सूर्य',
    'scen_1_opt': 'परिदृश्य 1: मेरी-गो-राउंड परिप्रेक्ष्य',
    'scen_2_opt': 'परिदृश्य 2: सितारों को देखना',
    'sci_conclusion': 'सफलता!',
    'lbl_observation': 'निष्कर्ष',
    'btn_fp_view': 'प्रथम-व्यक्ति दृश्य (First-Person)',
    'rotate_left': 'बाएं घुमाएं',
    'rotate_right': 'दाएं घुमाएं',
    'merry_go_round': 'मेरी-गो-राउंड',
    'your_motion': 'आपकी गति',
    'apparent_motion': 'पेड़ों की आभासी गति',
    'drag_pin': 'पिन को भारत पर खींचें',
    'earth_rotation': 'पृथ्वी का वास्तविक घूर्णन',
    'star_motion': 'सितारों की आभासी गति',
    'btn_compare': 'तुलना करें',
    'compare_title': 'तुलना करें',
    'snapshot_desc':
        'ध्यान दें कि रात बढ़ने पर बिग डिपर तारामंडल कैसे स्थिर ध्रुव तारे के चारों ओर घूमता हुआ प्रतीत होता है।',
    'btn_understood': 'मैं समझ गया',
    'msg_wrong_drop': 'चरित्र को मेरी-गो-राउंड सीट पर छोड़ें!',
    'msg_wrong_pin': 'पिन को भारत (ग्लोब के सामने) पर छोड़ें।',
    'msg_seated': 'पर्यवेक्षक सीट पर बैठ गया!',
    'msg_click_tree': 'बहुत बढ़िया! अब किसी पेड़ पर क्लिक करें।',
    'msg_click_stars': 'तारामंडलों पर क्लिक करें!',
    'conclusion_1':
        'जब आप मेरी-गो-राउंड पर वामावर्त (anti-clockwise) घूमते हैं, तो पृष्ठभूमि में स्थिर पेड़ दक्षिणावर्त (clockwise) चलते हुए प्रतीत होते हैं। इसे आभासी गति कहा जाता है। यही सिद्धांत पृथ्वी पर लागू होता है!',
    'conclusion_2':
        'पृथ्वी पश्चिम से पूर्व की ओर घूमती है। इससे स्थिर तारे आकाश में पूर्व से पश्चिम की ओर चलते हुए प्रतीत होते हैं। ध्रुव तारा स्थिर प्रतीत होता है क्योंकि यह पृथ्वी के घूर्णन अक्ष के ठीक ऊपर स्थित है।',
    'lbl_big_dipper': 'सप्तर्षि',
    'lbl_pole_star': 'ध्रुव तारा',
    'lbl_character': 'पर्यवेक्षक',
    'lbl_target_tree': 'संदर्भ पेड़',
    'lbl_mgr': 'मेरी-गो-राउंड',
    'lbl_india': 'भारत',
    'compass_n': 'उ',
    't_9pm': 'रात 9 बजे',
    't_12am': 'रात 12 बजे',
    't_3am': 'रात 3 बजे',
    't_5am': 'सुबह 5 बजे',
    'time_pm': 'रात {t}',
    'time_am_night': 'रात {t}',
    'time_am_morning': 'सुबह {t}',
    'readouts': 'लाइव रीडिंग',
    'lbl_view': 'दृश्य',
    'view_third': 'तृतीय-व्यक्ति',
    'view_fp': 'प्रथम-व्यक्ति',
    'lbl_rotation': 'मंच का घूर्णन',
    'lbl_seated': 'पर्यवेक्षक बैठा',
    'lbl_ref_tree': 'संदर्भ पेड़ चुना गया',
    'lbl_location': 'पर्यवेक्षक का स्थान',
    'loc_space': 'अंतरिक्ष में (ग्लोब)',
    'loc_india': 'भारत (रात का आकाश)',
    'lbl_time': 'समय',
    'lbl_sky_rotation': 'आकाश का घूर्णन',
    'yes': 'हाँ',
    'no': 'नहीं',
    'acw': 'वामावर्त',
    'cw': 'दक्षिणावर्त',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually understand that when an observer rotates, stationary objects in the background appear to move in the opposite direction.',
      steps: [
        LabStep(
          concept: 'Observer Setup',
          action: 'DRAG the 3D character from the corner and DROP them onto the merry-go-round seat.',
          observation: 'The observer is now positioned on the rotating platform.',
        ),
        LabStep(
          concept: 'Perspective Shift',
          action: "CLICK the 'First-Person View' button on the screen.",
          observation: 'You are now looking through the eyes of the observer on the merry-go-round.',
        ),
        LabStep(
          concept: 'Relative Motion',
          action: 'DRAG the slider to spin the merry-go-round anti-clockwise (left).',
          observation: 'As you rotate left, the stationary trees appear to slide across your view to the right.',
        ),
        LabStep(
          concept: 'Focus Point',
          action: 'CLICK on any highlighted tree in the distance.',
          observation: 'The tree is selected as a reference point.',
        ),
        LabStep(
          concept: 'Apparent Path',
          action: 'DRAG the rotation slider again. Observe the dotted line.',
          observation:
              'The stationary tree draws an apparent curved path across your vision, opposite to your rotation.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          "To apply the principle of apparent motion to understand why stars seem to move across the night sky due to Earth's rotation.",
      steps: [
        LabStep(
          concept: 'Observer Location',
          action: 'DRAG the location pin icon and DROP it onto India on the 3D Globe.',
          observation: 'We transition to a view of the clear night sky from that location.',
        ),
        LabStep(
          concept: 'Identifying Stars',
          action: 'CLICK on the Big Dipper and the Pole Star constellations in the sky.',
          observation: 'The constellations are highlighted, showing the Big Dipper pointing to the Pole Star.',
        ),
        LabStep(
          concept: "Earth's Rotation",
          action: 'DRAG the time-lapse slider slowly from 9 PM to 5 AM.',
          observation:
              'As Earth rotates West to East (PiP), the stars appear to move East to West around the fixed Pole Star.',
        ),
        LabStep(
          concept: 'Analysis',
          action: "CLICK the 'Compare Snapshots' button in the top right.",
          observation:
              'Comparing the positions at different times proves the entire sky appears to rotate together.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह समझना कि जब कोई पर्यवेक्षक घूमता है, तो पृष्ठभूमि में स्थित स्थिर वस्तुएं विपरीत दिशा में चलती हुई प्रतीत होती हैं।',
      steps: [
        LabStep(
          concept: 'पर्यवेक्षक सेटअप',
          action: '3D चरित्र को खींचें और उसे मेरी-गो-राउंड सीट पर छोड़ दें।',
          observation: 'पर्यवेक्षक अब घूर्णन मंच पर स्थित है।',
        ),
        LabStep(
          concept: 'परिप्रेक्ष्य में बदलाव',
          action: "स्क्रीन पर 'प्रथम-व्यक्ति दृश्य' (First-Person View) बटन पर क्लिक करें।",
          observation: 'अब आप मेरी-गो-राउंड पर पर्यवेक्षक की आँखों से देख रहे हैं।',
        ),
        LabStep(
          concept: 'आभासी गति',
          action: 'मेरी-गो-राउंड को वामावर्त (बाईं ओर) घुमाने के लिए स्लाइडर को खींचें।',
          observation: 'जैसे-जैसे आप बाईं ओर घूमते हैं, स्थिर पेड़ आपके दृश्य में दाईं ओर सरकते हुए प्रतीत होते हैं।',
        ),
        LabStep(
          concept: 'फोकस बिंदु',
          action: 'दूरी में किसी भी हाइलाइट किए गए पेड़ पर क्लिक करें।',
          observation: 'पेड़ को एक संदर्भ बिंदु के रूप में चुना गया है।',
        ),
        LabStep(
          concept: 'आभासी पथ',
          action: 'घूर्णन स्लाइडर को फिर से खींचें। बिंदीदार रेखा का निरीक्षण करें।',
          observation: 'स्थिर पेड़ आपकी दृष्टि में एक आभासी घुमावदार पथ बनाता है, जो आपके घूर्णन के विपरीत है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह समझने के लिए आभासी गति के सिद्धांत को लागू करना कि पृथ्वी के घूर्णन के कारण तारे रात के आकाश में क्यों चलते हुए प्रतीत होते हैं।',
      steps: [
        LabStep(
          concept: 'पर्यवेक्षक स्थान',
          action: 'लोकेशन पिन आइकन को खींचें और इसे 3D ग्लोब पर भारत पर छोड़ दें।',
          observation: 'हम उस स्थान से साफ रात के आकाश के दृश्य में संक्रमण करते हैं।',
        ),
        LabStep(
          concept: 'तारों की पहचान',
          action: 'आकाश में बिग डिपर (सप्तर्षि) और ध्रुव तारे पर क्लिक करें।',
          observation: 'तारामंडल हाइलाइट किए गए हैं।',
        ),
        LabStep(
          concept: 'पृथ्वी का घूर्णन',
          action: 'टाइम-लैप्स स्लाइडर को रात 9 बजे से सुबह 5 बजे तक धीरे-धीरे खींचें।',
          observation:
              'चूँकि पृथ्वी पश्चिम से पूर्व की ओर घूमती है, तारे पूर्व से पश्चिम की ओर ध्रुव तारे के चारों ओर घूमते हुए प्रतीत होते हैं।',
        ),
        LabStep(
          concept: 'विश्लेषण',
          action: "शीर्ष दाईं ओर 'तुलना करें' बटन पर क्लिक करें।",
          observation:
              'विभिन्न समयों पर स्थितियों की तुलना करने से साबित होता है कि पूरा आकाश एक साथ घूमता हुआ प्रतीत होता है।',
        ),
      ],
    ),
  ],
};

// ====================================================== MINI 3D ENGINE
//
// A tiny perspective renderer standing in for the Three.js scene: vectors,
// a look-at camera with the same field of view as the HTML cameras, flat
// shaded convex meshes (boxes, cylinders, cones, disks) with back-face
// culling, near-plane clipping and the HTML's ambient + key + fill lights.

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  static const _V3 zero = _V3(0, 0, 0);
  static const _V3 up = _V3(0, 1, 0);

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  _V3 operator -() => _V3(-x, -y, -z);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  /// Three.js rotation about Y (`object.rotation.y = a`).
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  _V3 rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x, y * c - z * s, y * s + z * c);
  }

  _V3 rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c - y * s, x * s + y * c, z);
  }

  /// Rodrigues rotation about the unit axis [k] by [a] radians.
  _V3 rotAxis(_V3 k, double a) {
    final c = math.cos(a), s = math.sin(a);
    return this * c + k.cross(this) * s + k * (k.dot(this) * (1 - c));
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective camera projecting world points to design coordinates.
class _A1Cam {
  _A1Cam(this.eye, this.fwd, this.right, this.upv, this.focal, this.center);

  /// Camera at [eye] looking at [target] with a vertical [fovDeg] (like a
  /// Three.js PerspectiveCamera + lookAt), centred on [center] with the
  /// design half height [halfHeight].
  factory _A1Cam.lookAt(
    _V3 eye,
    _V3 target,
    double fovDeg, {
    Offset center = const Offset(500, 280),
    double halfHeight = 280,
  }) {
    final f = (target - eye).unit;
    var r = f.cross(_V3.up);
    if (r.length < 1e-6) r = const _V3(1, 0, 0);
    r = r.unit;
    final u = r.cross(f);
    return _A1Cam(eye, f, r, u, halfHeight / math.tan(fovDeg * math.pi / 360), center);
  }

  final _V3 eye, fwd, right, upv;
  final double focal;
  final Offset center;

  static const double near = 0.5;

  _V3 toCam(_V3 p) {
    final d = p - eye;
    return _V3(d.dot(right), d.dot(upv), d.dot(fwd));
  }

  Offset camToScreen(_V3 c) => Offset(center.dx + c.x * focal / c.z, center.dy - c.y * focal / c.z);

  /// Screen position, or null when the point is behind the camera.
  Offset? project(_V3 p) {
    final c = toCam(p);
    return c.z <= near ? null : camToScreen(c);
  }

  double depth(_V3 p) => (p - eye).dot(fwd);

  /// Design pixels per world unit at [p].
  double pxPerUnit(_V3 p) {
    final z = depth(p);
    return z <= near ? 0 : focal / z;
  }

  /// World-space direction of the ray through screen point [s].
  _V3 ray(Offset s) => (fwd * focal + right * (s.dx - center.dx) - upv * (s.dy - center.dy)).unit;

  /// Intersection of the ray through [s] with the horizontal plane y = [y].
  _V3? groundHit(Offset s, [double y = 0]) {
    final d = ray(s);
    if (d.y.abs() < 1e-5) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen y of the horizon (cameras here never roll).
  double get horizonY {
    final h = _V3(fwd.x, 0, fwd.z).unit;
    return center.dy - focal * upv.dot(h) / fwd.dot(h);
  }
}

/// A flat polygon of a mesh (world coordinates).
class _A1Face {
  _A1Face(this.pts);
  final List<_V3> pts;
}

/// Convex flat-shaded mesh.
class _A1Mesh {
  _A1Mesh(this.faces, this.center, this.color);
  final List<_A1Face> faces;
  final _V3 center;
  final Color color;
}

typedef _A1Xf = _V3 Function(_V3);

_V3 _a1Identity(_V3 p) => p;

const _V3 _kA1Key = _V3(0.3244, 0.8111, 0.4867); // DirectionalLight (20, 50, 30)
const _V3 _kA1Fill = _V3(-0.5298, 0.6623, -0.5298); // fill light (-20, 25, -20)

/// Ambient 0.65 + key 0.85 + bluish fill 0.45, tone-mapped to stay readable.
double _a1Light(_V3 n) =>
    0.58 + 0.5 * math.max(0.0, n.dot(_kA1Key)) + 0.2 * math.max(0.0, n.dot(_kA1Fill));

Color _a1Lit(Color c, double k) {
  if (k <= 1) return Color.lerp(Colors.black, c, k)!;
  return Color.lerp(c, Colors.white, ((k - 1) * 0.55).clamp(0.0, 1.0))!;
}

/// Projects a polygon (near-plane clipped). Returns null when fully hidden.
Path? _a1ProjectPoly(_A1Cam cam, List<_V3> pts) {
  final cs = [for (final p in pts) cam.toCam(p)];
  final clipped = <_V3>[];
  const near = _A1Cam.near;
  for (var i = 0; i < cs.length; i++) {
    final a = cs[i], b = cs[(i + 1) % cs.length];
    final ain = a.z > near, bin = b.z > near;
    if (ain) clipped.add(a);
    if (ain != bin) clipped.add(_V3.lerp(a, b, (near - a.z) / (b.z - a.z)));
  }
  if (clipped.length < 3) return null;
  final path = Path();
  for (var i = 0; i < clipped.length; i++) {
    final s = cam.camToScreen(clipped[i]);
    if (i == 0) {
      path.moveTo(s.dx, s.dy);
    } else {
      path.lineTo(s.dx, s.dy);
    }
  }
  return path..close();
}

void _a1DrawMesh(Canvas canvas, _A1Cam cam, _A1Mesh m) {
  final fill = Paint()..isAntiAlias = true;
  final seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7;
  for (final f in m.faces) {
    final pts = f.pts;
    var c = _V3.zero;
    for (final p in pts) {
      c = c + p;
    }
    c = c * (1 / pts.length);
    var n = (pts[1] - pts[0]).cross(pts[2] - pts[0]).unit;
    if (n.dot(c - m.center) < 0) n = -n;
    if (n.dot(c - cam.eye) >= 0) continue;
    final path = _a1ProjectPoly(cam, pts);
    if (path == null) continue;
    final col = _a1Lit(m.color, _a1Light(n));
    canvas.drawPath(path, fill..color = col);
    canvas.drawPath(path, seam..color = col);
  }
}

// ------------------------------------------------------------ primitives

_A1Mesh _a1Box(_V3 c, double sx, double sy, double sz, Color color, _A1Xf xf) {
  final hx = sx / 2, hy = sy / 2, hz = sz / 2;
  _V3 p(double x, double y, double z) => xf(_V3(c.x + x, c.y + y, c.z + z));
  final v = [
    p(-hx, -hy, -hz), p(hx, -hy, -hz), p(hx, hy, -hz), p(-hx, hy, -hz), //
    p(-hx, -hy, hz), p(hx, -hy, hz), p(hx, hy, hz), p(-hx, hy, hz),
  ];
  List<_V3> q(int a, int b, int cc, int d) => [v[a], v[b], v[cc], v[d]];
  return _A1Mesh(
    [
      _A1Face(q(0, 1, 2, 3)),
      _A1Face(q(4, 5, 6, 7)),
      _A1Face(q(0, 4, 7, 3)),
      _A1Face(q(1, 5, 6, 2)),
      _A1Face(q(3, 2, 6, 7)),
      _A1Face(q(0, 1, 5, 4)),
    ],
    xf(c),
    color,
  );
}

/// Cylinder along local Y (or X when [axisX]) centred at [c].
_A1Mesh _a1Cylinder(
  _V3 c,
  double rTop,
  double rBot,
  double h,
  int segs,
  Color color,
  _A1Xf xf, {
  bool axisX = false,
  bool caps = true,
}) {
  _V3 p(double a, double y, double r) {
    final local = _V3(r * math.cos(a), y, r * math.sin(a));
    final q = axisX ? _V3(-local.y, local.x, local.z) : local;
    return xf(c + q);
  }

  final faces = <_A1Face>[];
  final top = <_V3>[], bot = <_V3>[];
  for (var i = 0; i < segs; i++) {
    final a = i * 2 * math.pi / segs;
    top.add(p(a, h / 2, rTop));
    bot.add(p(a, -h / 2, rBot));
  }
  for (var i = 0; i < segs; i++) {
    final j = (i + 1) % segs;
    faces.add(_A1Face([bot[i], bot[j], top[j], top[i]]));
  }
  if (caps) {
    faces.add(_A1Face(top));
    faces.add(_A1Face(bot));
  }
  return _A1Mesh(faces, xf(c), color);
}

/// Cone along +Y centred at [c] (base at c.y - h/2, apex at c.y + h/2).
_A1Mesh _a1Cone(_V3 c, double r, double h, int segs, Color color, _A1Xf xf, {double scale = 1}) {
  final apex = xf(_V3(c.x, c.y - h / 2 + h * scale, c.z));
  final base = <_V3>[];
  for (var i = 0; i < segs; i++) {
    final a = i * 2 * math.pi / segs;
    base.add(xf(_V3(c.x + r * scale * math.cos(a), c.y - h / 2, c.z + r * scale * math.sin(a))));
  }
  final faces = <_A1Face>[
    for (var i = 0; i < segs; i++) _A1Face([base[i], base[(i + 1) % segs], apex]),
    _A1Face(base),
  ];
  return _A1Mesh(faces, xf(_V3(c.x, c.y - h / 2 + h * scale / 3, c.z)), color);
}

/// Points of a horizontal circle (world space after [xf]).
List<_V3> _a1Circle(_V3 c, double r, int segs, [_A1Xf xf = _a1Identity]) => [
      for (var i = 0; i < segs; i++)
        xf(_V3(c.x + r * math.cos(i * 2 * math.pi / segs), c.y, c.z + r * math.sin(i * 2 * math.pi / segs))),
    ];

/// Draws a projected circle outline (torus look) with optional glow / fill.
void _a1Ring(
  Canvas canvas,
  _A1Cam cam,
  _V3 c,
  double r,
  Color color, {
  double tube = 0.3,
  double fillAlpha = 0,
  double glow = 0,
  _A1Xf xf = _a1Identity,
}) {
  final path = _a1ProjectPoly(cam, _a1Circle(c, r, 48, xf));
  if (path == null) return;
  final k = cam.pxPerUnit(xf(c));
  if (fillAlpha > 0) canvas.drawPath(path, Paint()..color = color.withValues(alpha: fillAlpha));
  if (glow > 0) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = tube * 2 * k * 2.4
        ..color = color.withValues(alpha: 0.35 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, tube * k * 1.6 + 2),
    );
  }
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, tube * 2 * k)
      ..color = color,
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, tube * 0.6 * k)
      ..color = Colors.white.withValues(alpha: 0.45),
  );
}

// ======================================================== SCENE MODEL

const Size _kA1Design = Size(1000, 560);

/// Character start position (HTML `charGroup.position.set(-4.5, 0, 18)`).
const _V3 _kA1CharInit = _V3(-4.5, 0, 18);

/// Drop target ring on seat 0, in merry-go-round coordinates.
const _V3 _kA1DropTarget = _V3(7, 2.5, 0);

/// Home of the draggable location pin (design px, clear of the globe and
/// of the canvas tool column).
const Offset _kA1PinHome = Offset(790, 250);

/// Night sky (HTML scenario 2 sky group).
const _V3 _kA1PoleStar = _V3(0, 300, -200);
const List<_V3> _kA1Dipper = [
  _V3(-100, 200, -200),
  _V3(-80, 190, -200),
  _V3(-60, 185, -200),
  _V3(-40, 195, -200),
  _V3(-20, 220, -200),
  _V3(-35, 240, -200),
  _V3(-60, 230, -200),
];

/// Rough outline of India (longitude, latitude) for the globe.
const List<Offset> _kA1IndiaLonLat = [
  Offset(68.2, 23.5), Offset(70.0, 20.8), Offset(72.8, 19.0), Offset(73.5, 15.5), //
  Offset(74.8, 12.8), Offset(76.3, 9.5), Offset(77.5, 8.1), Offset(78.2, 8.9),
  Offset(79.9, 10.3), Offset(80.3, 13.3), Offset(80.1, 15.8), Offset(82.3, 17.0),
  Offset(84.8, 19.2), Offset(86.9, 21.5), Offset(88.6, 22.0), Offset(89.8, 22.1),
  Offset(89.0, 26.3), Offset(92.0, 26.8), Offset(95.5, 28.0), Offset(97.0, 28.3),
  Offset(95.0, 29.5), Offset(91.6, 27.8), Offset(88.8, 27.3), Offset(88.0, 27.9),
  Offset(85.0, 27.4), Offset(81.0, 30.0), Offset(79.0, 31.0), Offset(78.6, 32.5),
  Offset(76.0, 34.5), Offset(77.8, 35.5), Offset(74.6, 37.0), Offset(73.8, 34.3),
  Offset(71.3, 30.2), Offset(70.5, 28.2), Offset(69.5, 27.0), Offset(71.0, 24.5),
];

/// Unit direction on the globe for a longitude / latitude, oriented so that
/// India faces the camera (slightly up and to the right).
_V3 _a1GlobeDir(double lon, double lat) {
  const d = math.pi / 180;
  final v = _V3(
    math.cos(lat * d) * math.sin((lon - 80) * d),
    math.sin(lat * d),
    math.cos(lat * d) * math.cos((lon - 80) * d),
  );
  return v.rotX(22 * d).rotX(-0.32).rotY(0.28);
}

class _A1Tree {
  _A1Tree(this.pos, {this.isTarget = false});
  final _V3 pos;
  final bool isTarget;
}

class _A1Patch {
  _A1Patch(this.outline);

  /// Unit directions of the patch outline on the globe.
  final List<_V3> outline;
}

/// Mutable scene read by the painters every frame.
class _A1Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  /// >= 1 when the stage is drawn small (labels / pin grow to stay usable).
  double uiScale = 1;

  /// Draw scale of the draggable location pin.
  double get pinScale => 1.4 * (1 + (uiScale - 1) * 0.5);

  /// Centre of the pin's touch target (its head) and its radius.
  Offset get pinGrabCenter => pinPos.translate(0, -24 * pinScale);
  double get pinGrabRadius => 36 * pinScale;

  // ------------------------------------------------------- scenario 1
  _V3 charPos = _kA1CharInit;
  bool dragging = false;
  bool seated = false;

  /// 0 = arms down, 1 = holding the bar (500 ms tween after seating).
  double armPose = 0;
  bool targetVisible = true;
  bool fpView = false;
  double fpSince = -10;

  /// Merry-go-round slider value (-180..180 degrees).
  double mgrDeg = 0;
  int? selectedTree;
  bool pathVisible = false;
  final List<_A1Tree> trees = [];

  // ------------------------------------------------------- scenario 2
  Offset pinPos = _kA1PinHome;
  bool pinDragging = false;

  /// HTML `#s2-pin-container` visible.
  bool pinVisible = true;

  /// The pin sits on India while the camera dives into the globe.
  bool pinOnIndia = false;
  double globeDist = 50;

  /// Dive progress 0..1 (the camera also swings round to face India).
  double diveT = 0;
  bool skyVisible = false;
  double skySince = -10;
  bool highlighted = false;

  /// Time-lapse slider value (0 = 9 PM .. 100 = 5 AM).
  double timeVal = 0;
  final List<_V3> stars = [];
  final List<double> starSize = [];
  final List<double> starPhase = [];
  final List<_A1Patch> patches = [];
  late final List<_V3> india = [for (final p in _kA1IndiaLonLat) _a1GlobeDir(p.dx, p.dy)];
  late final _V3 indiaCenter = _a1GlobeDir(80, 22);

  void reset() {
    charPos = _kA1CharInit;
    dragging = false;
    seated = false;
    armPose = 0;
    targetVisible = true;
    fpView = false;
    fpSince = -10;
    mgrDeg = 0;
    selectedTree = null;
    pathVisible = false;
    pinPos = _kA1PinHome;
    pinDragging = false;
    pinVisible = true;
    pinOnIndia = false;
    globeDist = 50;
    diveT = 0;
    skyVisible = false;
    skySince = -10;
    highlighted = false;
    timeVal = 0;
    _buildTrees();
    _buildSky();
  }

  /// HTML: target tree opposite the starting seat (angle PI, r 35) plus 11
  /// trees at random angles 35..55 away. A fixed seed keeps the layout tidy
  /// and keeps trees out of the default camera's face.
  void _buildTrees() {
    trees
      ..clear()
      ..add(_A1Tree(const _V3(-35, 0, 0), isTarget: true));
    final rng = math.Random(12);
    while (trees.length < 12) {
      final a = rng.nextDouble() * math.pi * 2;
      final dist = 35 + rng.nextDouble() * 20;
      // Skip the sector right in front of the overview camera (z > 0, x ~ 0).
      if ((a - math.pi / 2).abs() < 0.55) continue;
      final p = _V3(math.cos(a) * dist, 0, math.sin(a) * dist);
      if (trees.any((t) => (t.pos - p).length < 9)) continue;
      trees.add(_A1Tree(p));
    }
  }

  void _buildSky() {
    stars.clear();
    starSize.clear();
    starPhase.clear();
    final rng = math.Random(2024);
    for (var i = 0; i < 1000; i++) {
      final v = _V3(rng.nextDouble() - 0.5, rng.nextDouble(), rng.nextDouble() - 0.5).unit;
      stars.add(v * 400);
      starSize.add(0.5 + rng.nextDouble() * rng.nextDouble() * 1.6);
      starPhase.add(rng.nextDouble() * math.pi * 2);
    }
    patches.clear();
    final prng = math.Random(77);
    for (var i = 0; i < 10; i++) {
      final c = _V3(prng.nextDouble() - 0.5, prng.nextDouble() - 0.5, prng.nextDouble() - 0.5).unit;
      final r = (4 + prng.nextDouble() * 2) / 15;
      // Tangent frame around the patch centre.
      final t1 = c.cross(c.y.abs() > 0.9 ? const _V3(1, 0, 0) : _V3.up).unit;
      final t2 = c.cross(t1);
      // Organic blob outline: a few low-frequency wobbles instead of
      // per-point noise (the HTML uses lumpy icosahedron patches).
      final ph1 = prng.nextDouble() * math.pi * 2;
      final ph2 = prng.nextDouble() * math.pi * 2;
      final ph3 = prng.nextDouble() * math.pi * 2;
      final outline = <_V3>[];
      for (var k = 0; k < 28; k++) {
        final a = k * 2 * math.pi / 28;
        final rr = r *
            (0.82 + 0.16 * math.sin(2 * a + ph1) + 0.1 * math.sin(3 * a + ph2) + 0.06 * math.sin(5 * a + ph3));
        outline.add((c + t1 * (rr * math.cos(a)) + t2 * (rr * math.sin(a) * 0.8)).unit);
      }
      patches.add(_A1Patch(outline));
    }
  }

  // ---------------------------------------------------- transforms

  /// Platform rotation (rotation.y). Dragging the slider towards "Rotate
  /// Left" (negative values) turns the observer anti-clockwise, i.e. left.
  double get mgrRot => -mgrDeg * math.pi / 180;

  _V3 mgrXf(_V3 p) => p.rotY(mgrRot);

  /// Seat-group local -> world (seat i at angle i*PI/2, radius 7).
  _V3 seatXf(int i, _V3 p) {
    final a = i * math.pi / 2;
    return (p.rotY(-a) + _V3(math.cos(a) * 7, 0, math.sin(a) * 7)).rotY(mgrRot);
  }

  /// Character-local -> world once seated on seat 0 (rotation.y = PI).
  _V3 seatedXf(_V3 q) => seatXf(0, q.rotY(math.pi) + const _V3(0, 0.5, 0));

  _V3 get charOrigin => seated ? seatedXf(_V3.zero) : charPos;

  _V3 get dropTargetWorld => mgrXf(_kA1DropTarget);

  /// Overview camera (0, 15, 50) -> (0, 5, 0), or the first-person camera
  /// attached to the observer's head (fov 60).
  _A1Cam get cam1 {
    if (!fpView) return _A1Cam.lookAt(const _V3(0, 15, 50), const _V3(0, 5, 0), 45);
    final eye = seatedXf(const _V3(0, 5.4, 1.4));
    final dir = const _V3(0, 0, -1).rotY(mgrRot);
    return _A1Cam.lookAt(eye, eye + dir, 60);
  }

  /// Direction of the globe camera: (0, 0, 1) at rest, turning towards
  /// India while diving in so the pin stays in view.
  _V3 get globeEyeDir => _V3.lerp(const _V3(0, 0, 1), indiaCenter, diveT).unit;

  /// Globe camera at distance [globeDist] (HTML (0, 0, 50) -> z 16).
  _A1Cam get globeCam => _A1Cam.lookAt(globeEyeDir * globeDist, _V3.zero, 45);

  /// Night-sky camera inside the dome looking up towards the north (34°
  /// elevation, slightly wider than the HTML's 45° lens) so the Pole Star
  /// and the Big Dipper's whole 9 PM - 5 AM arc stay clear of the toast
  /// and of the time-lapse panel on landscape phones.
  static final _A1Cam skyCam = _A1Cam.lookAt(_V3.zero, const _V3(0, 55.92, -82.9), 60);

  static final _V3 poleAxis = _kA1PoleStar.unit;

  /// Sky rotation: 0..90 degrees for the slider, anti-clockwise on screen
  /// about the Pole Star (Earth spins west to east).
  double get skyAngle => -(timeVal / 100) * math.pi / 2;

  _V3 skyXf(_V3 p, [double? angle]) => p.rotAxis(poleAxis, angle ?? skyAngle);

  /// Apparent radius (design px) and centre of the globe on screen.
  ({Offset c, double r}) globeDisk() {
    final cam = globeCam;
    final d = globeDist;
    return (c: cam.center, r: cam.focal * 15 / math.sqrt(math.max(1, d * d - 225)));
  }
}

// ============================================================ PAINTING

const Color _kA1Shirt = Color(0xFFFF6B00);
const Color _kA1Trim = Color(0xFFFEF08A);
const Color _kA1Pants = Color(0xFF1D4ED8);
const Color _kA1Skin = Color(0xFFFFC8B4);
const Color _kA1Hair = Color(0xFF381804);
const Color _kA1Stripe = Color(0xFFEF4444);
const Color _kA1Sole = Color(0xFF334155);
const Color _kA1Belt = Color(0xFF1E293B);
const Color _kA1Gold = Color(0xFFFACC15);
const Color _kA1Pupil = Color(0xFF090D16);
const Color _kA1Cheek = Color(0xB3F43F5E);
const Color _kA1TreeGreen = Color(0xFF15803D);
const Color _kA1Amber = Color(0xFFFBBF24);

/// HTML `createLabel()` chips: black/80 background, amber-400 bold text.
/// [scale] keeps the chip readable when the stage is shrunk on small
/// screens (HTML labels have a fixed on-screen size).
void _a1Label(
  Canvas canvas,
  String text,
  Offset at, {
  Alignment anchor = Alignment.bottomCenter,
  double scale = 1,
}) {
  // Objects far outside the view have no visible label (like the HTML,
  // where off-screen labels simply fall outside the canvas).
  if (at.dx < -40 || at.dx > _kA1Design.width + 40 || at.dy < -40 || at.dy > _kA1Design.height + 40) return;
  final size = 12.5 * scale;
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final w = tp.width + 16 * scale;
  tp.dispose();
  // Keep the chip inside the design area (the stage shows all of it).
  final before = (anchor.x + 1) / 2 * w; // chip width left of the anchor
  final x = at.dx.clamp(before + 4, math.max(before + 4, _kA1Design.width - (w - before) - 4)).toDouble();
  labText(
    canvas,
    text,
    Offset(x, at.dy.clamp(24.0 * scale, _kA1Design.height - 4)),
    size: size,
    color: _kA1Amber,
    weight: FontWeight.w800,
    anchor: anchor,
    background: const Color(0xCC000000),
    border: const Color(0x80334155),
    borderWidth: 1,
    radius: 5 * scale,
    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
  );
}

/// TWEEN `.to({scale: 1.1}, 500).yoyo(true).repeat(Infinity)` (linear).
double _a1Yoyo(double t) {
  final ph = (t / 0.5) % 2;
  return 1 + 0.1 * (ph < 1 ? ph : 2 - ph);
}

class _A1Painter extends CustomPainter {
  _A1Painter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.text,
    this.labelScale = 1,
  }) : super(repaint: repaint);

  final _A1Scene scene;
  final bool showLabels;
  final LabLang lang;
  final String Function(String) text;

  /// Label size multiplier (>= 1 when the stage is scaled down).
  final double labelScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintPlayground(canvas, size);
    } else if (!scene.skyVisible) {
      _paintGlobe(canvas, size);
    } else {
      _paintSky(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _A1Painter old) =>
      old.showLabels != showLabels || old.lang != lang || old.scene != scene || old.labelScale != labelScale;

  // ------------------------------------------------ scenario 1: playground

  void _paintPlayground(Canvas canvas, Size size) {
    final sc = scene;
    final cam = sc.cam1;
    final t = sc.time;
    final bleed = labBleed(size);
    final hy = cam.horizonY;

    // Sky (scene.background 0x87CEEB) with a soft horizon haze.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, hy + 2),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5AAEE0), Color(0xFF87CEEB), Color(0xFFD3EEF9)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromLTRB(0, hy - 420, 1, hy)),
    );
    _paintClouds(canvas, cam);

    // Ground plane (0x4ade80), hazier towards the horizon.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, hy, bleed.right, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9EDDB4), Color(0xFF55E08A), Color(0xFF3FCF74)],
          stops: [0, 0.12, 1],
        ).createShader(Rect.fromLTRB(0, hy, 1, hy + 420)),
    );

    // Stone path around the merry-go-round (CircleGeometry 25).
    final pathPoly = _a1ProjectPoly(cam, _a1Circle(const _V3(0, 0.1, 0), 25, 72));
    if (pathPoly != null) {
      canvas.drawPath(pathPoly, Paint()..color = _a1Lit(const Color(0xFFD6D3D1), _a1Light(_V3.up)));
      canvas.drawPath(
        pathPoly,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFA8A29E),
      );
    }

    // Soft shadows (the HTML scene casts PCF soft shadows).
    void shadow(_V3 c, double r, double alpha) {
      final poly = _a1ProjectPoly(cam, _a1Circle(c, r, 28));
      if (poly == null) return;
      canvas.drawPath(
        poly,
        Paint()
          ..color = Colors.black.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    shadow(const _V3(-2.4, 0.12, -3.6), 11.5, 0.2);
    for (final tr in sc.trees) {
      shadow(tr.pos + const _V3(-2.2, 0.05, -3.3), 3.6, 0.18);
    }
    if (!sc.fpView && !sc.seated) shadow(sc.charPos + const _V3(-0.6, 0.12, -0.9), 1.4, 0.25);

    // Merry-go-round base (drawn first: everything else stands on it).
    final mx = sc.mgrXf;
    _a1DrawMesh(canvas, cam, _a1Cylinder(const _V3(0, 0.5, 0), 10, 10, 1, 40, const Color(0xFF94A3B8), mx));
    final rim = _a1ProjectPoly(cam, _a1Circle(const _V3(0, 1.01, 0), 9.3, 48, mx));
    if (rim != null) {
      canvas.drawPath(
        rim,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x55FFFFFF),
      );
    }

    // Depth-sorted objects (painter's algorithm on convex parts).
    final items = <({double depth, VoidCallback draw})>[];
    void add(_V3 c, VoidCallback draw, {double bias = 0}) => items.add((depth: cam.depth(c) + bias, draw: draw));

    add(mx(const _V3(0, 5, 0)), () {
      _a1DrawMesh(canvas, cam, _a1Cylinder(const _V3(0, 5.5, 0), 0.5, 0.5, 9, 16, const Color(0xFFFACC15), mx));
    });
    add(mx(const _V3(0, 12, 0)), () {
      _a1DrawMesh(canvas, cam, _a1Cone(const _V3(0, 12, 0), 11, 4, 16, const Color(0xFFEF4444), mx));
    });
    for (var i = 0; i < 4; i++) {
      _V3 xf(_V3 q) => sc.seatXf(i, q);
      add(xf(const _V3(0, 1.5, 0)), () {
        _a1DrawMesh(canvas, cam, _a1Box(const _V3(0, 1.5, 0), 3, 1, 2, const Color(0xFF3B82F6), xf));
      });
      add(xf(const _V3(0, 3.5, 2)), () {
        _a1DrawMesh(canvas, cam, _a1Cylinder(const _V3(0, 3.5, 2), 0.15, 0.15, 4, 8, const Color(0xFF111111), xf, axisX: true));
      });
      for (final sx in [-1.8, 1.8]) {
        add(xf(_V3(sx, 2.25, 2)), () {
          _a1DrawMesh(canvas, cam, _a1Cylinder(_V3(sx, 2.25, 2), 0.1, 0.1, 2.5, 8, const Color(0xFF111111), xf));
        });
      }
    }
    if (sc.targetVisible) {
      final c = sc.dropTargetWorld;
      add(c, () {
        final pulse = 1 + math.sin(t * 5) * 0.2;
        _a1Ring(canvas, cam, _kA1DropTarget, 3 * pulse, const Color(0xFFEAB308),
            tube: 0.3 * pulse, glow: 1, fillAlpha: 0.12, xf: mx);
      }, bias: -0.3);
    }
    for (var i = 0; i < sc.trees.length; i++) {
      final tree = sc.trees[i];
      add(tree.pos + const _V3(0, 5, 0), () => _paintTree(canvas, cam, i, t));
    }
    if (!sc.fpView) {
      final o = sc.charOrigin;
      add(o + const _V3(0, 3, 0), () => _paintCharacter(canvas, cam, t), bias: sc.seated ? -0.6 : 0);
    }

    items.sort((a, b) => b.depth.compareTo(a.depth));
    for (final it in items) {
      if (it.depth > _A1Cam.near) it.draw();
    }

    // Floating labels (HTML createLabel; hidden when behind the camera).
    if (showLabels) {
      final ls = labelScale;
      if (!sc.fpView) {
        final o = cam.project(sc.charOrigin + const _V3(0, 6.5, 0));
        if (o != null) _a1Label(canvas, text('lbl_character'), o.translate(0, -4), scale: ls);
      }
      // Anchored by its left edge so it never covers the observer, who
      // starts just left of the platform's centre.
      final m = cam.project(mx(const _V3(0, -1, 0)));
      if (m != null) {
        _a1Label(canvas, text('lbl_mgr'), m.translate(-24 * ls, 0), anchor: Alignment.centerLeft, scale: ls);
      }
      final target = sc.trees.first;
      final tp = cam.project(target.pos + const _V3(0, 11, 0));
      if (tp != null && cam.depth(target.pos) > 2) {
        _a1Label(canvas, text('lbl_target_tree'), tp.translate(0, -4), scale: ls);
      }
    }

    if (sc.fpView) _paintFpOverlays(canvas, size, t);
  }
  /// Distant clouds placed in the world so they also drift past in the
  /// first-person view.
  void _paintClouds(Canvas canvas, _A1Cam cam) {
    const clouds = [
      (0.35, 36.0), (1.25, 44.0), (2.15, 32.0), (2.95, 40.0), (3.9, 46.0), (4.75, 34.0), (5.6, 42.0), //
    ];
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (final (a, h) in clouds) {
      final c = _V3(math.cos(a) * 260, h, math.sin(a) * 260);
      final sp = cam.project(c);
      if (sp == null) continue;
      final k = cam.pxPerUnit(c);
      for (final (dx, dy, r) in const [(-14.0, 0.0, 9.0), (-3.0, 4.0, 12.0), (9.0, 1.0, 10.0), (18.0, -2.0, 7.0)]) {
        canvas.drawCircle(sp + Offset(dx * k, -dy * k), r * k, paint);
      }
    }
  }

  void _paintTree(Canvas canvas, _A1Cam cam, int i, double t) {
    final sc = scene;
    final tree = sc.trees[i];
    final pulsing = sc.step == 4 && tree.isTarget && sc.selectedTree == null;
    final scale = pulsing ? _a1Yoyo(t) : 1.0;
    final selected = sc.selectedTree == i;
    _V3 xf(_V3 q) => tree.pos + q * scale;

    if (selected || pulsing) {
      final glowAt = cam.project(xf(const _V3(0, 6, 0)));
      if (glowAt != null) {
        final k = cam.pxPerUnit(tree.pos);
        labGlow(canvas, glowAt, 9 * k, const Color(0xFFEAB308), intensity: selected ? 0.9 : 0.35 + 0.25 * math.sin(t * 6));
      }
    }
    _a1DrawMesh(canvas, cam, _a1Cylinder(const _V3(0, 2, 0), 0.8, 0.8, 4, 8, const Color(0xFF78350F), xf));
    final leaf = selected
        ? const Color(0xFFF5C518)
        : (pulsing ? const Color(0xFF37A23D) : _kA1TreeGreen);
    _a1DrawMesh(canvas, cam, _a1Cone(const _V3(0, 6, 0), 4, 10, 8, leaf, xf));
  }

  void _paintCharacter(Canvas canvas, _A1Cam cam, double t) {
    final sc = scene;
    if (sc.seated) {
      _a1DrawBoySeated(canvas, cam, sc);
      return;
    }
    final pulse = sc.step == 1 ? _a1Yoyo(t) : 1.0;
    final origin = sc.charPos;
    final feet = cam.project(origin);
    if (feet == null) return;
    // Glowing "drag me" pedestal ring (part of the character group).
    _a1Ring(canvas, cam, origin + const _V3(0, 0.15, 0), 2.5 * pulse, const Color(0xFF38BDF8),
        tube: 0.18 * pulse, fillAlpha: 0.25, glow: sc.dragging ? 1 : 0.6);
    final k = cam.pxPerUnit(origin + const _V3(0, 3, 0)) * pulse;
    _a1DrawBoyFront(canvas, feet, k, lift: sc.dragging ? 0.25 : 0);
  }

  /// HTML first-person overlays drawn in the scene: the dotted apparent
  /// path (step 5) and a short fade-in. The "your motion" / "apparent
  /// motion" arrows are canvas widgets placed around the slider card.
  void _paintFpOverlays(Canvas canvas, Size size, double t) {
    final sc = scene;
    if (sc.pathVisible) {
      final p = Path()
        ..moveTo(130, 330)
        ..quadraticBezierTo(500, 150, 870, 330);
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = const Color(0xFFEAB308).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      labDashedPath(
        canvas,
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFEAB308),
        dash: 15,
        gap: 15,
        phase: -t * 50,
      );
    }

    final fade = 1 - ((t - sc.fpSince) / 0.5).clamp(0.0, 1.0);
    if (fade > 0) {
      canvas.drawRect(labBleed(size), Paint()..color = Colors.black.withValues(alpha: fade));
    }
  }
}

/// U-shaped arrow (HTML `ph-arrow-u-up-right` / `ph-arrow-u-down-left`):
/// [up] arcs over the top and points right (apparent motion of the trees),
/// otherwise it arcs underneath and points left (your motion).
class _A1UArrowPainter extends CustomPainter {
  _A1UArrowPainter({required this.up, required this.color});

  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final sw = h * 0.16;
    final head = h * 0.42;
    final from = up ? Offset(w * 0.12, h * 0.92) : Offset(w * 0.88, h * 0.08);
    final to = up ? Offset(w * 0.8, h * 0.78) : Offset(w * 0.2, h * 0.22);
    final ctrl = up ? Offset(w * 0.46, -h * 0.55) : Offset(w * 0.54, h * 1.55);
    final dir = (to - ctrl) / (to - ctrl).distance;
    final end = to - dir * head * 0.6;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sw * 0.5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    labArrow(canvas, end - dir * 1, to + dir * head * 0.45, color: color, width: sw, head: head);
  }

  @override
  bool shouldRepaint(covariant _A1UArrowPainter old) => old.up != up || old.color != color;
}

// ------------------------------------------------------------ the observer

void _a1Limb(Canvas canvas, Offset shoulder, Offset hand, double k, double sgn) {
  final elbow = Offset.lerp(shoulder, hand, 0.7 / 1.8)!;
  final dir = hand - shoulder;
  final u = dir.distance < 0.01 ? const Offset(0, 1) : dir / dir.distance;
  canvas.drawLine(
    shoulder,
    elbow,
    Paint()
      ..strokeWidth = 0.8 * k
      ..strokeCap = StrokeCap.round
      ..color = _kA1Shirt,
  );
  canvas.drawLine(
    elbow + u * (-0.06 * k),
    elbow + u * (0.06 * k),
    Paint()
      ..strokeWidth = 0.84 * k
      ..color = _kA1Trim,
  );
  canvas.drawLine(
    elbow + u * (0.06 * k),
    hand,
    Paint()
      ..strokeWidth = 0.56 * k
      ..strokeCap = StrokeCap.round
      ..color = labShade(_kA1Skin, -0.04),
  );
  canvas.drawCircle(hand, 0.32 * k, Paint()..color = _kA1Skin);
  canvas.drawCircle(hand + Offset(-sgn * 0.22 * k, -0.08 * k), 0.14 * k, Paint()..color = labShade(_kA1Skin, -0.06));
}

Paint _a1Grad(Rect r, Color c) => Paint()
  ..shader = LinearGradient(
    colors: [labShade(c, -0.2), labShade(c, 0.1), c, labShade(c, -0.12)],
    stops: const [0, 0.45, 0.7, 1],
  ).createShader(r);

Path _a1Torso(Offset Function(double, double) p) {
  Offset a(double x, double y) => p(x, y);
  return Path()
    ..moveTo(a(-0.8, 2.2).dx, a(-0.8, 2.2).dy)
    ..lineTo(a(0.8, 2.2).dx, a(0.8, 2.2).dy)
    ..lineTo(a(0.95, 4.05).dx, a(0.95, 4.05).dy)
    ..quadraticBezierTo(a(0.95, 4.44).dx, a(0.95, 4.44).dy, a(0.55, 4.44).dx, a(0.55, 4.44).dy)
    ..lineTo(a(-0.55, 4.44).dx, a(-0.55, 4.44).dy)
    ..quadraticBezierTo(a(-0.95, 4.44).dx, a(-0.95, 4.44).dy, a(-0.95, 4.05).dx, a(-0.95, 4.05).dy)
    ..close();
}

/// The HTML's explorer character (orange shirt, blue jeans, white sneakers,
/// brown hair) seen from the front, feet at [feet], [k] px per unit.
void _a1DrawBoyFront(Canvas canvas, Offset feet, double k, {double lift = 0}) {
  Offset p(double x, double y) => Offset(feet.dx + x * k, feet.dy - (y + lift) * k);
  Rect r(double l, double b, double rr, double t) => Rect.fromPoints(p(l, b), p(rr, t));
  RRect rr(Rect rect, double rad) => RRect.fromRectAndRadius(rect, Radius.circular(rad * k));
  Paint fill(Color c) => Paint()..color = c;

  canvas.drawOval(Rect.fromCenter(center: p(0, 5.34), width: 2.5 * k, height: 2.44 * k), fill(_kA1Hair));
  for (final sgn in const [-1.0, 1.0]) {
    final leg = r(sgn * 0.55 - 0.4, 0.3, sgn * 0.55 + 0.4, 2.25);
    canvas.drawRRect(rr(leg, 0.16), _a1Grad(leg, _kA1Pants));
  }
  for (final sgn in const [-1.0, 1.0]) {
    final x = sgn * 0.55;
    canvas.drawRRect(rr(r(x - 0.38, 0.02, x + 0.38, 0.52), 0.18), fill(Colors.white));
    canvas.drawRect(r(x - 0.38, 0.25, x + 0.38, 0.37), fill(_kA1Stripe));
    canvas.drawRRect(rr(r(x - 0.41, -0.03, x + 0.41, 0.12), 0.06), fill(_kA1Sole));
  }
  canvas.drawRect(r(-0.34, 4.1, 0.34, 4.85), fill(labShade(_kA1Skin, -0.1)));
  final torso = _a1Torso(p);
  canvas.drawPath(torso, _a1Grad(torso.getBounds(), _kA1Shirt));
  canvas.drawRect(r(-0.82, 2.12, 0.82, 2.47), fill(_kA1Belt));
  canvas.drawRRect(rr(r(-0.2, 2.17, 0.2, 2.42), 0.04), fill(_kA1Gold));
  canvas.drawOval(
    Rect.fromCenter(center: p(0, 4.42), width: 0.92 * k, height: 0.3 * k),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.14 * k
      ..color = _kA1Trim,
  );
  canvas.drawCircle(p(-0.42, 3.55), 0.22 * k, fill(_kA1Gold));
  canvas.drawCircle(p(-0.42, 3.55), 0.09 * k, fill(_kA1Trim));
  for (final sgn in const [-1.0, 1.0]) {
    _a1Limb(canvas, p(sgn * 1.12, 4.12), p(sgn * 1.43, 2.35), k, sgn);
  }
  _a1Head(canvas, p, k, front: true);
}

void _a1Head(Canvas canvas, Offset Function(double, double) p, double k, {required bool front}) {
  Paint fill(Color c) => Paint()..color = c;
  for (final sgn in const [-1.0, 1.0]) {
    canvas.drawOval(Rect.fromCenter(center: p(sgn * 1.17, 5.28), width: 0.32 * k, height: 0.58 * k),
        fill(labShade(_kA1Skin, -0.08)));
  }
  final headRect = Rect.fromCircle(center: p(0, 5.2), radius: 1.2 * k);
  canvas.drawOval(
    headRect,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.35),
        colors: [labShade(_kA1Skin, 0.25), _kA1Skin, labShade(_kA1Skin, -0.16)],
        stops: const [0, 0.55, 1],
      ).createShader(headRect),
  );
  final hairPaint = Paint()
    ..shader = RadialGradient(
      center: const Alignment(0.25, -0.6),
      radius: 0.9,
      colors: [labShade(_kA1Hair, 0.3), _kA1Hair],
    ).createShader(headRect.inflate(0.2 * k));
  if (!front) {
    canvas.drawOval(Rect.fromCenter(center: p(0, 5.36), width: 2.48 * k, height: 2.5 * k), hairPaint);
    canvas.drawArc(
      Rect.fromCircle(center: p(0.15, 5.9), radius: 0.35 * k),
      0.4,
      4.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.08 * k
        ..color = labShade(_kA1Hair, 0.35),
    );
    return;
  }
  Offset q(double x, double y) => p(x, y);
  final cap = Path()
    ..moveTo(q(-1.24, 5.3).dx, q(-1.24, 5.3).dy)
    ..cubicTo(q(-1.32, 7.0).dx, q(-1.32, 7.0).dy, q(1.32, 7.0).dx, q(1.32, 7.0).dy, q(1.24, 5.3).dx, q(1.24, 5.3).dy)
    ..lineTo(q(1.12, 5.62).dx, q(1.12, 5.62).dy)
    ..quadraticBezierTo(q(0.88, 5.9).dx, q(0.88, 5.9).dy, q(0.62, 5.7).dx, q(0.62, 5.7).dy)
    ..quadraticBezierTo(q(0.38, 5.98).dx, q(0.38, 5.98).dy, q(0.05, 5.8).dx, q(0.05, 5.8).dy)
    ..quadraticBezierTo(q(-0.25, 6.0).dx, q(-0.25, 6.0).dy, q(-0.55, 5.69).dx, q(-0.55, 5.69).dy)
    ..quadraticBezierTo(q(-0.85, 5.92).dx, q(-0.85, 5.92).dy, q(-1.12, 5.62).dx, q(-1.12, 5.62).dy)
    ..close();
  canvas.drawPath(cap, hairPaint);
  for (final sgn in const [-1.0, 1.0]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromPoints(p(sgn * 1.0, 5.0), p(sgn * 1.14, 5.6)), Radius.circular(0.05 * k)),
      fill(_kA1Hair),
    );
    canvas.drawLine(
      p(sgn * 0.2, 5.62),
      p(sgn * 0.62, 5.66),
      Paint()
        ..strokeWidth = 0.1 * k
        ..strokeCap = StrokeCap.round
        ..color = _kA1Hair,
    );
    canvas.drawOval(Rect.fromCenter(center: p(sgn * 0.42, 5.32), width: 0.48 * k, height: 0.56 * k), fill(Colors.white));
    canvas.drawOval(Rect.fromCenter(center: p(sgn * 0.42, 5.29), width: 0.3 * k, height: 0.34 * k), fill(_kA1Pupil));
    canvas.drawCircle(p(sgn * 0.42 + 0.06, 5.37), 0.055 * k, fill(Colors.white));
    canvas.drawCircle(p(sgn * 0.7, 4.98), 0.19 * k, fill(_kA1Cheek));
  }
  canvas.drawOval(Rect.fromCenter(center: p(0, 5.1), width: 0.26 * k, height: 0.2 * k), fill(labShade(_kA1Skin, -0.14)));
  canvas.drawArc(
    Rect.fromCircle(center: p(0, 5.05), radius: 0.27 * k),
    0.35,
    math.pi - 0.7,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1 * k
      ..strokeCap = StrokeCap.round
      ..color = _kA1Pupil,
  );
}

/// The observer sitting on seat 0, seen from behind, arms reaching for
/// the handle bar (HTML arm tween after seating).
void _a1DrawBoySeated(Canvas canvas, _A1Cam cam, _A1Scene sc) {
  final origin = cam.project(sc.seatedXf(_V3.zero));
  if (origin == null) return;
  final k = cam.pxPerUnit(sc.seatedXf(const _V3(0, 3, 0)));
  Offset p(double x, double y) => Offset(origin.dx + x * k, origin.dy - y * k);
  Rect r(double l, double b, double rr, double t) => Rect.fromPoints(p(l, b), p(rr, t));

  final hips = r(-0.88, 1.5, 0.88, 2.35);
  canvas.drawRRect(RRect.fromRectAndRadius(hips, Radius.circular(0.25 * k)), _a1Grad(hips, _kA1Pants));
  canvas.drawRect(r(-0.34, 4.1, 0.34, 4.85), Paint()..color = labShade(_kA1Skin, -0.1));
  final torso = _a1Torso(p);
  canvas.drawPath(torso, _a1Grad(torso.getBounds(), _kA1Shirt));
  canvas.drawRect(r(-0.82, 2.12, 0.82, 2.47), Paint()..color = _kA1Belt);
  _a1Head(canvas, p, k, front: false);

  final pose = sc.armPose;
  for (final sgn in const [-1.0, 1.0]) {
    final shoulder = _V3(sgn * 1.15, 4.1 - 0.5 * pose, 0.2 * pose);
    final hand = _V3.lerp(_V3(sgn * 1.46, 2.35, 0), _V3(sgn * 1.15, 3.6, -1.6), pose);
    final s0 = cam.project(sc.seatedXf(shoulder));
    final h0 = cam.project(sc.seatedXf(hand));
    if (s0 == null || h0 == null) continue;
    _a1Limb(canvas, s0, h0, k, sgn);
  }
}

// ================================================= SCENARIO 2: GLOBE & SKY

const Color _kA1Land = Color(0xFF22C55E);
const Color _kA1Orange = Color(0xFFFFAA00);

/// Closed curve through the midpoints of [pts] (corners become smooth
/// quadratic bends), used for the land outlines on the globe.
Path _a1SmoothClosed(List<Offset> pts) {
  final n = pts.length;
  Offset mid(int i) => Offset.lerp(pts[i % n], pts[(i + 1) % n], 0.5)!;
  final start = mid(0);
  final path = Path()..moveTo(start.dx, start.dy);
  for (var i = 1; i <= n; i++) {
    final c = pts[i % n];
    final m = mid(i);
    path.quadraticBezierTo(c.dx, c.dy, m.dx, m.dy);
  }
  return path..close();
}

/// Red map pin (HTML `ph-fill ph-map-pin`); [tip] is the point.
void _a1DrawPin(Canvas canvas, Offset tip, {double scale = 1, double lift = 0}) {
  final s = scale;
  labGroundShadow(canvas, tip.translate(0, 2), 22 * s, 7 * s, opacity: 0.45);
  final top = tip.translate(0, -lift);
  final head = top.translate(0, -30 * s);
  final r = 15 * s;
  final pin = Path()
    ..moveTo(top.dx, top.dy)
    ..cubicTo(top.dx - r * 0.25, top.dy - 10 * s, head.dx - r, head.dy + r * 0.9, head.dx - r, head.dy)
    ..arcToPoint(Offset(head.dx + r, head.dy), radius: Radius.circular(r))
    ..cubicTo(head.dx + r, head.dy + r * 0.9, top.dx + r * 0.25, top.dy - 10 * s, top.dx, top.dy)
    ..close();
  canvas.drawPath(
    pin.shift(const Offset(0, 3)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.drawPath(
    pin,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.6),
        colors: [Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFB91C1C)],
        stops: [0, 0.5, 1],
      ).createShader(pin.getBounds()),
  );
  canvas.drawCircle(head, r * 0.4, Paint()..color = Colors.white);
}

extension _A1SkyPaint on _A1Painter {
  /// Faint distant stars behind the globe.
  void _spaceDust(Canvas canvas, Size size) {
    final rng = math.Random(5);
    final b = labBleed(size);
    final paint = Paint();
    for (var i = 0; i < 260; i++) {
      final p = Offset(b.left + rng.nextDouble() * b.width, b.top + rng.nextDouble() * b.height);
      paint.color = Colors.white.withValues(alpha: 0.15 + rng.nextDouble() * 0.35);
      canvas.drawCircle(p, 0.5 + rng.nextDouble() * 0.9, paint);
    }
  }

  /// Projects a land outline on the globe. Points behind the visible limb
  /// are moved onto it and pushed outwards on screen, so the clip to the
  /// globe disk gives a clean curved edge.
  Path? _landPath(_A1Cam cam, List<_V3> outline, Offset c) {
    final sc = scene;
    final e = sc.globeEyeDir;
    final th = 15.0 / sc.globeDist;
    var anyVisible = false;
    final pts = <Offset>[];
    for (final u in outline) {
      final a = u.dot(e);
      if (a >= th) {
        anyVisible = true;
        final sp = cam.project(u * 15.02);
        if (sp != null) pts.add(sp);
        continue;
      }
      final b = u - e * a;
      final bl = b.length;
      if (bl < 1e-6) continue;
      final limb = e * th + b * (math.sqrt(1 - th * th) / bl);
      final sp = cam.project(limb * 15.0);
      if (sp != null) pts.add(c + (sp - c) * 1.35);
    }
    if (!anyVisible || pts.length < 3) return null;
    return _a1SmoothClosed(pts);
  }

  void _paintGlobe(Canvas canvas, Size size) {
    final sc = scene;
    final t = sc.time;
    canvas.drawRect(labBleed(size), Paint()..color = const Color(0xFF020617));
    _spaceDust(canvas, size);

    final cam = sc.globeCam;
    final disk = sc.globeDisk();
    final c = disk.c, r = disk.r;
    labGlow(canvas, c, r * 1.22, const Color(0xFF3B82F6), intensity: 0.5);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.32, -0.45),
          radius: 1.05,
          colors: [Color(0xFF6A9BF4), Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF0B1E5C)],
          stops: [0, 0.35, 0.72, 1],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final land = Paint()..color = _kA1Land;
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF15803D);
    for (final patch in sc.patches) {
      final path = _landPath(cam, patch.outline, c);
      if (path == null) continue;
      canvas.drawPath(path, land);
      canvas.drawPath(path, coast);
    }
    final india = _landPath(cam, sc.india, c);
    if (india != null) {
      canvas.drawPath(india, Paint()..color = const Color(0xFF34D27A));
      canvas.drawPath(
        india,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFFBBF7D0),
      );
    }
    // Day / night shading on top of the land.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.35, -0.45),
          radius: 1.2,
          colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent, Colors.black.withValues(alpha: 0.55)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x6693C5FD),
    );

    final ic = cam.project(sc.indiaCenter * 15.02);
    if (ic != null) {
      if (sc.pinVisible && sc.step == 1) {
        final pulse = (t * 0.8) % 1;
        canvas.drawCircle(
          ic,
          10 + 26 * pulse,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = const Color(0xFFFDE047).withValues(alpha: 0.9 * (1 - pulse)),
        );
      }
      if (showLabels && sc.diveT < 0.05) {
        _a1Label(
          canvas,
          text('lbl_india'),
          ic.translate(0, sc.pinOnIndia ? -52 * sc.pinScale / 1.4 : -16),
          scale: labelScale,
        );
      }
      if (sc.pinOnIndia) _a1DrawPin(canvas, ic, scale: sc.pinScale / 1.4 * (1 + sc.diveT * 0.6));
    }

    // HTML #s2-pin-container: the draggable pin and its caption (wrapped,
    // and kept left of the canvas tool column).
    if (sc.pinVisible) {
      final ls = labelScale;
      final double maxW = 150 * math.max(1.0, ls * 0.8);
      final measure = TextPainter(
        text: TextSpan(
          text: text('drag_pin'),
          style: TextStyle(
            fontSize: 14 * ls,
            fontWeight: FontWeight.w800,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxW);
      final double half = measure.width / 2 + 12 * ls;
      measure.dispose();
      final double cx = math.min(_kA1PinHome.dx, 868 - half);
      labText(
        canvas,
        text('drag_pin'),
        Offset(cx, _kA1PinHome.dy + 16 * ls),
        anchor: Alignment.topCenter,
        size: 14 * ls,
        weight: FontWeight.w800,
        color: Colors.white,
        maxWidth: maxW,
        background: const Color(0x99000000),
        border: const Color(0x33FFFFFF),
        radius: 12 * ls,
        padding: EdgeInsets.symmetric(horizontal: 12 * ls, vertical: 5 * ls),
      );
      final bob = sc.pinDragging ? 0.0 : 4 * math.sin(t * 3).abs();
      _a1DrawPin(canvas, sc.pinPos, scale: sc.pinScale * (sc.pinDragging ? 1.15 : 1), lift: bob);
    }
  }

  void _paintSky(Canvas canvas, Size size) {
    final sc = scene;
    final t = sc.time;
    final cam = _A1Scene.skyCam;
    final b = labBleed(size);
    canvas.drawRect(
      b,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020617), Color(0xFF050B24), Color(0xFF0E1A40)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromLTRB(0, 0, 1, 560)),
    );
    final fadeIn = ((t - sc.skySince) / 0.6).clamp(0.0, 1.0);

    final star = Paint();
    for (var i = 0; i < sc.stars.length; i++) {
      final sp = cam.project(sc.skyXf(sc.stars[i]));
      if (sp == null || sp.dx < b.left || sp.dx > b.right || sp.dy < b.top || sp.dy > b.bottom) continue;
      final tw = 0.7 + 0.3 * math.sin(t * 2.2 + sc.starPhase[i]);
      star.color = Colors.white.withValues(alpha: 0.8 * tw);
      canvas.drawCircle(sp, sc.starSize[i], star);
    }

    final dipper = [for (final s in _kA1Dipper) cam.project(sc.skyXf(s))];
    if (sc.highlighted && dipper.every((p) => p != null)) {
      final line = Path()..addPolygon([for (final p in dipper) p!], false);
      canvas.drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = _kA1Orange.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..color = _kA1Orange,
      );
    }
    final hint = sc.step == 2 ? 0.5 + 0.5 * math.sin(t * 4) : 0.0;
    for (var i = 0; i < _kA1Dipper.length; i++) {
      final p = dipper[i];
      if (p == null) continue;
      final k = cam.pxPerUnit(sc.skyXf(_kA1Dipper[i]));
      labGlow(canvas, p, 2.5 * k * (3 + 1.5 * hint), const Color(0xFFE0E7FF), intensity: 0.45 + 0.35 * hint);
      labSphere(canvas, p, 2.5 * k, Colors.white, highlight: 0.2, shade: 0.15);
    }
    final pole = cam.project(_kA1PoleStar);
    if (pole != null) {
      final k = cam.pxPerUnit(_kA1PoleStar) * (sc.highlighted ? 1.5 : 1);
      final col = sc.highlighted ? _kA1Orange : const Color(0xFFFFEAB0);
      labGlow(canvas, pole, 3 * k * (3.2 + 1.5 * hint), col, intensity: 0.55 + 0.3 * hint);
      labSphere(canvas, pole, 3 * k, col, highlight: 0.35, shade: 0.15);
    }

    if (sc.highlighted && showLabels) {
      final bd = cam.project(sc.skyXf(_kA1Dipper.first) + const _V3(0, 5, 0));
      if (bd != null) _a1Label(canvas, text('lbl_big_dipper'), bd.translate(0, -6), scale: labelScale);
      final ps = cam.project(_kA1PoleStar + const _V3(0, 5, 0));
      if (ps != null) _a1Label(canvas, text('lbl_pole_star'), ps.translate(0, -10), scale: labelScale);
    }

    if (fadeIn < 1) {
      canvas.drawRect(b, Paint()..color = const Color(0xFF020617).withValues(alpha: 1 - fadeIn));
    }
  }
}

/// HTML picture-in-picture Earth (CSS globe rotating anti-clockwise).
class _A1PipPainter extends CustomPainter {
  _A1PipPainter({required this.angle});
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = _Colors.slate900);
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2563EB));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final k = size.shortestSide / 96;
    final blob = Paint()
      ..color = const Color(0xFF22C55E)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 * k);
    for (final rect in const [
      Rect.fromLTWH(8, 8, 16, 24),
      Rect.fromLTWH(52, 60, 32, 20),
      Rect.fromLTWH(32, 32, 40, 32),
    ]) {
      canvas.drawOval(
        Rect.fromLTWH(rect.left * k - r, rect.top * k - r, rect.width * k, rect.height * k),
        blob,
      );
    }
    canvas.restore();
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 1.1,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
          stops: const [0.45, 1],
        ).createShader(rect),
    );
    // Anti-clockwise arrow over the PiP.
    final ar = r * 0.42;
    final arc = Rect.fromCircle(center: c, radius: ar);
    final white = Colors.white.withValues(alpha: 0.85);
    canvas.drawArc(
      arc,
      -math.pi * 0.35,
      -math.pi * 1.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..strokeCap = StrokeCap.round
        ..color = white,
    );
    final end = c + Offset(math.cos(-math.pi * 0.35), math.sin(-math.pi * 0.35)) * ar;
    final tangent = Offset(math.sin(-math.pi * 0.35), -math.cos(-math.pi * 0.35));
    labArrow(canvas, end - tangent * (r * 0.05), end - tangent * (r * 0.3), color: white, width: r * 0.12, head: r * 0.3);
  }

  @override
  bool shouldRepaint(covariant _A1PipPainter old) => old.angle != angle;
}

/// One frame of the "Compare Snapshots" modal: the sky around the Pole
/// Star at a given rotation.
class _A1SnapshotPainter extends CustomPainter {
  _A1SnapshotPainter({required this.angle, required this.north});
  final double angle;
  final String north;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final cam = _A1Cam.lookAt(
      _V3.zero,
      _kA1PoleStar,
      54,
      center: size.center(Offset.zero),
      halfHeight: size.height / 2,
    );
    _V3 rot(_V3 p) => p.rotAxis(_A1Scene.poleAxis, angle);
    final rng = math.Random(9);
    final dim = Paint();
    for (var i = 0; i < 60; i++) {
      final v = _V3(rng.nextDouble() - 0.5, rng.nextDouble(), rng.nextDouble() - 0.5).unit * 400;
      final sp = cam.project(rot(v));
      if (sp == null) continue;
      dim.color = Colors.white.withValues(alpha: 0.25 + rng.nextDouble() * 0.3);
      canvas.drawCircle(sp, 0.5 + rng.nextDouble() * 0.6, dim);
    }
    final pts = [for (final s in _kA1Dipper) cam.project(rot(s))];
    final unit = size.width / 100;
    if (pts.every((p) => p != null)) {
      canvas.drawPath(
        Path()..addPolygon([for (final p in pts) p!], false),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, unit * 0.8)
          ..color = Colors.white.withValues(alpha: 0.4),
      );
      for (final p in pts) {
        canvas.drawCircle(p!, unit * 1.7, Paint()..color = Colors.white);
      }
    }
    final pole = cam.project(_kA1PoleStar);
    if (pole != null) {
      labGlow(canvas, pole, unit * 7, const Color(0xFFFFEAB0), intensity: 0.5);
      canvas.drawCircle(pole, unit * 2.2, Paint()..color = Colors.white);
    }
    labText(
      canvas,
      north,
      Offset(size.width - unit * 5, size.height - unit * 4),
      anchor: Alignment.bottomRight,
      size: math.max(9, unit * 7),
      weight: FontWeight.w800,
      color: Colors.white.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _A1SnapshotPainter old) => old.angle != angle || old.north != north;
}

/// Big yellow slider thumb with a white ring (HTML `.slider-custom`).
class _A1ThumbShape extends SliderComponentShape {
  const _A1ThumbShape({required this.radius});
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius + 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, radius, Paint()..color = _Colors.zslYellow);
    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white,
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
