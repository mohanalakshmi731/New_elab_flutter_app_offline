// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 12 • Activity 6
/// Safe Eclipse Viewing.
///
/// Native Flutter port of `Cl7S-Ch12-A6-Safe_Eclipse_Viewing.html`.
/// Scenario 1: build a mirror projector (sand + mirror + stand), aim the
/// reflected beam at the wall, then compare looking at the projection with
/// looking at the Sun. Scenario 2: open the toolbox and test sunglasses,
/// binoculars and certified solar filters on the observer.
class Ch12A6SafeEclipseViewingPage extends StatefulWidget {
  const Ch12A6SafeEclipseViewingPage({super.key});

  @override
  State<Ch12A6SafeEclipseViewingPage> createState() => _Ch12A6SafeEclipseViewingPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, buzz 2594.
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
  pickup('pickup.mp3'),
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

class _A6Tween {
  _A6Tween(this.start, this.duration, this.curve, this.apply, this.onDone);
  final double start;
  final double duration;
  final Curve curve;
  final void Function(double v) apply;
  final VoidCallback? onDone;
}

class _Ch12A6SafeEclipseViewingPageState extends State<Ch12A6SafeEclipseViewingPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A6Scene _scene = _A6Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_A6Tween> _tweens = [];
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  late final Ticker _ticker;
  double _lastTick = 0;

  // Equipment panel (scenario 1).
  bool _sandEnabled = true, _mirrorEnabled = false, _eyeEnabled = false;
  String? _assetDrag;
  int? _itemDrag;
  Offset? _ghost;
  Offset _lastGlobal = Offset.zero;

  // Projector aiming.
  bool _aiming = false;
  double? _lastAimX;
  bool _projectorLocked = false;
  bool _reticle = false;
  bool _busy = false;

  // First-person vision overlay.
  String? _vision;
  bool _visionShown = false;
  int _visionToken = 0;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scene.reset(0);
    _ticker = createTicker(_onTick)..start();
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

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _lastTick).clamp(0.0, 0.1);
    _lastTick = now;
    _scene.time = now;
    for (final tw in List.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final v = ((now - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.apply(tw.curve.transform(v));
      if (v >= 1) {
        _tweens.remove(tw);
        tw.onDone?.call();
      }
    }
    for (final e in _scene.labelTargets().entries) {
      final target = e.value && _lab.showLabels && _lab.isLabActive ? 1.0 : 0.0;
      final cur = _scene.labelAlpha[e.key] ?? 0;
      _scene.labelAlpha[e.key] = cur + (target - cur).clamp(-dt / 0.3, dt / 0.3);
    }
    _frame.value = now;
  }

  void _tween(int ms, Curve curve, void Function(double v) apply, {VoidCallback? onDone, int delayMs = 0}) {
    _tweens.add(_A6Tween(_scene.time + delayMs / 1000, ms / 1000, curve, apply, onDone));
  }

  void _camTween(_V3 pos, _V3 target, int ms, {double focal = _f}) {
    final p0 = _scene.camPos, t0 = _scene.camTarget, f0 = _scene.focal;
    _tween(ms, Curves.easeOutCubic, (v) {
      _scene.camPos = _V3.lerp(p0, pos, v);
      _scene.camTarget = _V3.lerp(t0, target, v);
      _scene.focal = f0 + (focal - f0) * v;
    });
  }

  // ---------------------------------------------------------- scenario

  /// HTML `resetApp(keepScenario)` scene part.
  void _buildScenario(int index) {
    _lab.cancelPending();
    _tweens.clear();
    _scene.reset(index);
    _sandEnabled = index == 0;
    _mirrorEnabled = false;
    _eyeEnabled = false;
    _assetDrag = null;
    _itemDrag = null;
    _ghost = null;
    _aiming = false;
    _lastAimX = null;
    _projectorLocked = false;
    _reticle = false;
    _busy = false;
    _vision = null;
    _visionShown = false;
    _lab.camLocked = true;
    _lab.showLabels = true;
    _lab.panMode = false;
    if (index == 0) {
      _camTween(_s1CamPos, _s1CamTarget, 1000);
    } else {
      _camTween(_s2CamPos, _s2CamTarget, 1000, focal: _s2F);
    }
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _buildScenario(index);
    });
    _lab.resetView(sound: false);
  }

  void _fullReset() => setState(() => _buildScenario(0));

  void _advanceStep() {
    final n = _data.steps.length;
    if (_step < n) {
      _scene.step++;
      _onStepEnter();
    } else if (_step == n) {
      _scene.step++;
      _lab.after(const Duration(milliseconds: 1000), _showSummary);
    }
  }

  /// HTML `updateStepLogic()` side effects.
  void _onStepEnter() {
    if (_scenario != 0) return;
    if (_step == 4) {
      _reticle = true;
      _scene.beamVisible = true;
      _updateSpot();
    } else if (_step == 5) {
      _eyeEnabled = true;
      _camTween(_testCamPos, _testCamTarget, 1500);
    }
  }

  bool get _panelVisible => _scenario == 0 && _step != 4;

  // ------------------------------------------------------ scenario 1

  void _assetPanStart(String type, DragStartDetails d) {
    final ok = switch (_step) {
      1 => type == 'sand',
      2 => type == 'mirror',
      5 => type == 'eye',
      _ => false,
    };
    if (!ok || _scenario != 0) return;
    _lastGlobal = d.globalPosition;
    _Audio.play(_Sound.pickup);
    setState(() {
      _assetDrag = type;
      _ghost = labGlobalToLocal(_canvasKey, d.globalPosition);
    });
  }

  void _dragUpdateGlobal(Offset global) {
    _lastGlobal = global;
    setState(() => _ghost = labGlobalToLocal(_canvasKey, global));
  }

  /// Design-space drop point, or null when released outside the canvas.
  Offset? _dropPoint() {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    if (!(Offset.zero & box.size).contains(box.globalToLocal(_lastGlobal))) return null;
    return labGlobalToLocal(_stageKey, _lastGlobal);
  }

  bool _hitsBall(Offset p) => _scene.cam.rayDistance(p, _scene.ballPos) < 1.8;

  void _assetPanEnd() {
    final type = _assetDrag;
    if (type == null) return;
    setState(() {
      _assetDrag = null;
      _ghost = null;
    });
    final p = _dropPoint();
    if (p == null) return;
    setState(() {
      if (type == 'sand') {
        if (_hitsBall(p)) {
          _scene.sandVisible = true;
          _sandEnabled = false;
          _mirrorEnabled = true;
          _lab.showToast(_t('feed_sand'));
          _advanceStep();
        } else {
          _Audio.play(_Sound.wrong);
        }
      } else if (type == 'mirror') {
        if (_hitsBall(p)) {
          _scene.mirrorVisible = true;
          _mirrorEnabled = false;
          _lab.showToast(_t('feed_mirror'));
          _advanceStep();
        } else {
          _Audio.play(_Sound.wrong);
        }
      } else if (type == 'eye') {
        final cam = _scene.cam;
        final hitWall =
            cam.rayHitsBox(p, const _V3(14.9, 0, -15), const _V3(15.1, 15, 15)) ||
            cam.rayHitsBox(p, const _V3(-3, -4.5, -7.5), const _V3(33, 19.5, 7.5));
        final hitSun = cam.rayDistance(p, _sunPos) < 25;
        if (hitWall) {
          _triggerVision('safe_wall');
          _scene.testsWall = true;
        } else if (hitSun) {
          _triggerVision('danger_sun');
          _scene.testsSun = true;
        } else {
          _Audio.play(_Sound.wrong);
        }
        if (_scene.testsWall && _scene.testsSun && _step == 5) {
          _eyeEnabled = false;
          _advanceStep();
        }
      }
    });
  }

  /// HTML click on the ball in step 3: it glides onto the ring stand.
  void _mountBall() {
    if (_busy) return;
    _busy = true;
    final from = _scene.ballPos;
    _scene.ballRotY = _scene.projectorAngle;
    _tween(
      800,
      Curves.easeOutCubic,
      (v) => _scene.ballPos = _V3.lerp(from, _ballOnStand, v),
      onDone: () {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _lab.showToast(_t('feed_stand'));
          _advanceStep();
        });
      },
    );
  }

  /// HTML `updateProjectionSpot()`.
  void _updateSpot() {
    final i = _scene.intensity;
    _scene.spotOpacity = i * 0.9;
    _scene.beamOpacity = 0.2 + i * 0.4;
    if (_scene.projectorAngle.abs() < 0.15 && !_projectorLocked && _step == 4) {
      _projectorLocked = true;
      final a0 = _scene.projectorAngle;
      _tween(
        300,
        Curves.linear,
        (v) {
          _scene.projectorAngle = a0 * (1 - v);
          _scene.ballRotY = _scene.projectorAngle;
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _scene.spotOpacity = 0.9;
            _reticle = false;
          });
          _lab.showToast(_t('feed_aim'));
          _lab.after(const Duration(milliseconds: 1000), () {
            if (mounted) setState(_advanceStep);
          });
        },
      );
    }
  }

  void _aimEnd() {
    if (!_aiming) return;
    _aiming = false;
    _lastAimX = null;
    if (!_projectorLocked && _step == 4 && _scene.projectorAngle.abs() > 0.15) {
      _lab.showToast(_t('drag_horizontally'), sound: false);
    }
  }

  // ------------------------------------------------------ scenario 2

  bool _hitsToolbox(Offset p) => _scene.cam.rayHitsBox(p, const _V3(-2, 5.25, -1.5), const _V3(2, 7.65, 1.5));

  /// HTML toolbox click: the lid bounces open and the items jump out.
  void _openToolbox() {
    if (_busy) return;
    _busy = true;
    _tween(
      800,
      Curves.bounceOut,
      (v) => _scene.lidAngle = -math.pi * 0.6 * v,
      onDone: () {
        if (!mounted) return;
        _lab.showToast(_t('feed_box'));
        setState(() {
          _busy = false;
          for (var i = 0; i < 3; i++) {
            _scene.itemPos[i] = const _V3(0, 5, 0);
            _scene.itemVisible[i] = true;
            final to = _V3(-3.0 + i * 3, 5.5, 2);
            _tween(
              600,
              Curves.easeOutQuad,
              (v) => _scene.itemPos[i] = _V3.lerp(const _V3(0, 5, 0), to, v),
              delayMs: i * 150,
            );
          }
          _advanceStep();
        });
      },
    );
  }

  bool _hitsItem(int i, Offset p) => _scene.cam.rayDistance(p, _scene.itemPos[i]) < 1.7;

  bool _hitsHead(Offset p) => _scene.cam.rayDistance(p, _scene.headCenter) < 1.7;

  void _itemDropped() {
    final i = _itemDrag;
    if (i == null) return;
    setState(() {
      _itemDrag = null;
      _ghost = null;
    });
    final p = _dropPoint();
    if (p == null || !_hitsHead(p)) {
      setState(() => _scene.itemVisible[i] = true);
      _Audio.play(_Sound.wrong);
      return;
    }
    // The observer raises both hands to the face and tilts the head up.
    final a0 = _scene.armRot, h0 = _scene.headTilt;
    _tween(400, Curves.linear, (v) {
      _scene.armRot = a0 + (-math.pi / 1.5 - a0) * v;
      _scene.headTilt = h0 + (-0.2 - h0) * v;
    });
    _lab.after(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _triggerVision(const ['danger_sunglasses', 'danger_binos', 'safe_glasses'][i]);
        _advanceStep();
      });
      _lab.after(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        final a1 = _scene.armRot, h1 = _scene.headTilt;
        _tween(600, Curves.linear, (v) {
          _scene.armRot = a1 * (1 - v);
          _scene.headTilt = h1 * (1 - v);
        });
      });
    });
  }

  // ---------------------------------------------------------- vision

  /// HTML `triggerVisionOverlay(type)` (+ the matching feedback toast).
  void _triggerVision(String type) {
    final token = ++_visionToken;
    _vision = type;
    _visionShown = true;
    switch (type) {
      case 'safe_wall':
        _lab.showToast(_t('feed_safe'));
      case 'danger_sun':
        _lab.showToast(_t('feed_danger'), isError: true);
      case 'danger_sunglasses':
        _lab.showToast(_t('feed_sunglasses'), isError: true);
      case 'danger_binos':
        _Audio.play(_Sound.buzz);
        _lab.showToast(_t('feed_binos'), isError: true, sound: false);
      case 'safe_glasses':
        _lab.showToast(_t('feed_cert'));
    }
    final ms = type.contains('safe') ? 3000 : 2500;
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted || token != _visionToken) return;
      setState(() => _visionShown = false);
      _lab.after(const Duration(milliseconds: 300), () {
        if (mounted && token == _visionToken) setState(() => _vision = null);
      });
    });
  }

  // ---------------------------------------------------------- gestures

  void _onPanStart(DragStartDetails d) {
    final p = d.localPosition;
    if (_scenario == 0 && _step == 4) {
      _aiming = true;
      _lastAimX = d.globalPosition.dx;
      return;
    }
    final i = _scene.activeItem;
    if (i != null && _scene.itemVisible[i] && _hitsItem(i, p)) {
      _Audio.play(_Sound.pickup);
      _lastGlobal = d.globalPosition;
      setState(() {
        _itemDrag = i;
        _scene.itemVisible[i] = false;
        _ghost = labGlobalToLocal(_canvasKey, d.globalPosition);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_aiming && _scenario == 0 && _step == 4) {
      final last = _lastAimX;
      if (last != null) {
        final dx = d.globalPosition.dx - last;
        _scene.projectorAngle = (_scene.projectorAngle - dx * 0.005).clamp(-0.8, 0.8);
        _scene.ballRotY = _scene.projectorAngle;
        _updateSpot();
      }
      _lastAimX = d.globalPosition.dx;
    } else if (_itemDrag != null) {
      _dragUpdateGlobal(d.globalPosition);
    }
  }

  void _onPanEnd() {
    if (_aiming) {
      setState(_aimEnd);
    } else if (_itemDrag != null) {
      _itemDropped();
    }
  }

  void _onTapUp(TapUpDetails d) {
    final p = d.localPosition;
    if (_scenario == 0) {
      if (_step == 3 && _hitsBall(p)) {
        _mountBall();
      } else if (_step == 4) {
        _aiming = true;
        setState(_aimEnd);
      }
    } else if (_step == 1 && _hitsToolbox(p)) {
      _openToolbox();
    } else {
      // Press and release on the item without moving: it falls back.
      final i = _scene.activeItem;
      if (i != null && _scene.itemVisible[i] && _hitsItem(i, p)) _Audio.play(_Sound.wrong);
    }
  }

  // ---------------------------------------------------------- summary

  /// HTML `showSummary()`.
  void _showSummary() {
    if (!mounted) return;
    final sc = _scenario;
    _lab.completedScenarios.add(sc);
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('observation_complete'),
        accent: _Colors.primary,
        extra: _summaryBody(sc),
        actions: [
          if (sc == 0)
            LabAction(
              label: _t('btn_next'),
              icon: Icons.arrow_forward,
              color: _Colors.indigo600,
              foreground: Colors.white,
              sound: _Sound.scenario,
              onTap: () => _changeScenario(1),
            )
          else
            LabAction(
              label: _t('btn_restart'),
              icon: Icons.restart_alt,
              color: _Colors.indigo600,
              foreground: Colors.white,
              onTap: _lab.requestFullReset,
            ),
        ],
      ),
    );
    setState(() {});
  }

  Widget _summaryBody(int sc) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final green = sc == 0;
    return Column(
      children: [
        Container(
          width: 60 * s,
          height: 60 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: green
                ? (p.isDark ? const Color(0x4D14532D) : const Color(0xFFDCFCE7))
                : (p.isDark ? const Color(0x4D312E81) : const Color(0xFFE0E7FF)),
          ),
          child: Icon(
            green ? Icons.present_to_all : Icons.verified_user,
            size: 30 * s,
            color: green ? _Colors.green : _Colors.primary,
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          _t(green ? 'sum_title_1' : 'sum_title_2').toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textStrong, fontSize: 19 * s, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        SizedBox(height: 8 * s),
        Text(
          _t(green ? 'sum_desc_1' : 'sum_desc_2'),
          textAlign: TextAlign.center,
          style: TextStyle(color: p.text, fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.3), height: 1.5),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- UI

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
          icon: Icons.verified_user,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          onReset: _fullReset,
          overlays: [
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            if (_reticle && _scenario == 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(width: 60, height: 60, child: CustomPaint(painter: const _A6ReticlePainter())),
                  ),
                ),
              ),
            if (_scenario == 0) _equipmentPanel(context, p, s, inset),
            if (_vision != null) _visionOverlay(s),
            if (_ghost != null) _ghostView(s),
          ],
          stage: LabStage(
            designSize: _design,
            child: _lowSlop(
              context,
              GestureDetector(
                key: _stageKey,
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: _onTapUp,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: _A6Painter(scene: _scene, repaint: _frame, lang: _lab.lang, text: _t),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Small touch slop so short drags on phones aren't swallowed by the
  /// default 36 px pan slop.
  Widget _lowSlop(BuildContext context, Widget child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
    child: child,
  );

  /// HTML `#assets-panel`: Sand, Mirror and Test Eye.
  Widget _equipmentPanel(BuildContext context, LabPalette p, double s, EdgeInsets inset) {
    final visible = _panelVisible;
    return Positioned(
      top: inset.top + 6 * s,
      right: inset.right + 6 * s,
      child: _lowSlop(
        context,
        IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(1.2, 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: LabGlassCard(
                palette: p,
                padding: EdgeInsets.all(9 * s),
                borderColor: _Colors.primary.withValues(alpha: 0.3),
                color: p.isDark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _t('assets_panel_title').toUpperCase(),
                      style: TextStyle(
                        color: p.isDark ? const Color(0xFF818CF8) : _Colors.indigo600,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Container(
                      width: 170 * s,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 6 * s),
                      color: p.cardBorder,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tile(
                          'sand',
                          Icons.shopping_bag,
                          const Color(0xFFD97706),
                          const Color(0xFFFFFBEB),
                          const Color(0x4D78350F),
                          _sandEnabled,
                          p,
                          s,
                        ),
                        SizedBox(width: 7 * s),
                        _tile(
                          'mirror',
                          Icons.search,
                          const Color(0xFF0EA5E9),
                          const Color(0xFFF0F9FF),
                          const Color(0x4D0C4A6E),
                          _mirrorEnabled,
                          p,
                          s,
                        ),
                        SizedBox(width: 7 * s),
                        _tile(
                          'eye',
                          Icons.visibility,
                          const Color(0xFF6366F1),
                          const Color(0xFFEEF2FF),
                          const Color(0x4D312E81),
                          _eyeEnabled,
                          p,
                          s,
                        ),
                      ],
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

  Widget _tile(
    String type,
    IconData icon,
    Color iconColor,
    Color bgLight,
    Color bgDark,
    bool enabled,
    LabPalette p,
    double s,
  ) {
    final dragging = _assetDrag == type;
    final key = type == 'eye' ? 'test_eye' : type;
    Widget tile = Container(
      width: 56 * s,
      height: 56 * s,
      padding: EdgeInsets.all(3 * s),
      decoration: BoxDecoration(
        color: p.isDark ? bgDark : bgLight,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: dragging ? iconColor : (p.isDark ? _Colors.slate600 : _Colors.slate300),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22 * s, color: iconColor),
          SizedBox(height: 2 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _t(key),
              style: TextStyle(
                color: p.isDark ? _Colors.slate300 : _Colors.slate600,
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (!enabled) {
      tile = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: tile,
      );
    }
    return Opacity(
      opacity: !enabled ? 0.3 : (dragging ? 0.5 : 1),
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onPanStart: enabled ? (d) => _assetPanStart(type, d) : null,
        onPanUpdate: enabled ? (d) => _assetDrag == null ? null : _dragUpdateGlobal(d.globalPosition) : null,
        onPanEnd: enabled ? (_) => _assetPanEnd() : null,
        child: AnimatedScale(scale: dragging ? 0.95 : 1, duration: const Duration(milliseconds: 200), child: tile),
      ),
    );
  }

  Widget _ghostView(double s) {
    final g = _ghost!;
    final size = 77 * s;
    final item = _itemDrag;
    final Widget icon = item != null
        ? SizedBox(
            width: size * 0.62,
            height: size * 0.62,
            child: CustomPaint(painter: _A6ItemIconPainter(item)),
          )
        : Icon(
            switch (_assetDrag) {
              'sand' => Icons.shopping_bag,
              'mirror' => Icons.search,
              _ => Icons.visibility,
            },
            size: 34 * s,
            color: switch (_assetDrag) {
              'sand' => const Color(0xFFD97706),
              'mirror' => const Color(0xFF0EA5E9),
              _ => const Color(0xFFA5B4FC),
            },
          );
    return Positioned(
      left: g.dx - size / 2,
      top: g.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _Colors.primary.withValues(alpha: 0.2),
            border: Border.all(color: const Color(0xFF818CF8), width: 2),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
          ),
          child: icon,
        ),
      ),
    );
  }

  /// HTML `#vision-overlay`: what the eye sees (safe view or danger flash).
  Widget _visionOverlay(double s) {
    final type = _vision!;
    final safe = type.startsWith('safe');
    final base = type == 'danger_sunglasses' ? 0.9 : 1.0;
    final titleColor = switch (type) {
      'danger_binos' => const Color(0xFFB91C1C),
      'danger_sun' || 'danger_sunglasses' => const Color(0xFFDC2626),
      _ => const Color(0xFF4ADE80),
    };
    final big = type == 'danger_sun' || type == 'danger_binos';
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_visionToken),
          tween: Tween(begin: 0, end: _visionShown ? base : 0),
          duration: const Duration(milliseconds: 300),
          builder: (context, o, child) => Opacity(opacity: o.clamp(0.0, 1.0), child: child),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (safe)
                const ColoredBox(color: Colors.black)
              else
                CustomPaint(
                  painter: _A6DangerPainter(scene: _scene, repaint: _frame, contrast: type == 'danger_binos'),
                ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16 * s),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 560 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (safe) ...[
                            SizedBox(
                              width: 120 * s,
                              height: 120 * s,
                              child: CustomPaint(painter: _A6EclipseIconPainter(orange: type == 'safe_glasses')),
                            ),
                            SizedBox(height: 14 * s),
                          ],
                          Text(
                            _t('v_$type'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: (big ? 44 : 34) * s,
                              fontWeight: FontWeight.w900,
                              letterSpacing: safe ? 1 : 3,
                              shadows: [
                                Shadow(
                                  color: safe ? Colors.black54 : Colors.white,
                                  blurRadius: type == 'danger_binos' ? 20 : 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            _t('v_${type}_sub'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: safe ? _Colors.slate200 : _Colors.slate900,
                              fontSize: 17 * s,
                              fontWeight: FontWeight.w800,
                              shadows: [Shadow(color: safe ? Colors.black : Colors.white70, blurRadius: 6)],
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Safe Eclipse Viewing',
    'app_subtitle': 'Class 7 • Earth, Moon and the Sun',
    'scen_1_opt': 'Scenario 1: Mirror Projection Method',
    'scen_2_opt': 'Scenario 2: Direct Eye Protection',
    'observation_complete': 'Observation Complete',
    'btn_next': 'Next Scenario',
    'btn_restart': 'Restart Lab',
    'assets_panel_title': 'Equipment',
    'lbl_sun': 'Sun',
    'lbl_screen': 'Projection Screen',
    'lbl_projector': 'Mirror Projector',
    'lbl_toolbox': 'Equipment Toolbox',
    'drag_eye_here': 'Drag Eye Here',
    'sand': 'Sand',
    'mirror': 'Mirror',
    'test_eye': 'Test Eye',
    'sunglasses': 'Sunglasses',
    'binoculars': 'Binoculars',
    'solar_filters': 'Solar Filters',
    'observer': 'Observer',
    'sum_title_1': 'Projection Successful',
    'sum_title_2': 'Safety First!',
    'sum_desc_1':
        "You learned that projecting the Sun's image using a simple mirror allows for safe, indirect viewing of an eclipse without risking eye damage.",
    'sum_desc_2':
        'Only specially certified solar filters are safe. Sunglasses and unfiltered binoculars/telescopes are extremely dangerous for viewing the Sun.',
    'feed_sand': 'Ball filled with sand.',
    'feed_mirror': 'Mirror attached.',
    'feed_stand': 'Mounted on stand.',
    'feed_aim': 'Projection aimed perfectly!',
    'feed_safe': 'Safe projection view.',
    'feed_danger': 'DANGER! Never look directly at the sun!',
    'feed_box': 'Toolbox opened.',
    'feed_sunglasses': 'Unsafe! Standard sunglasses are not enough.',
    'feed_binos': 'Danger! Binoculars multiply the risk!',
    'feed_cert': 'Safe! Certified filters protect your eyes.',
    'drag_horizontally': 'Keep dragging horizontally to aim closer to the center!',
    // Vision overlay texts (hard-coded in the HTML script).
    'v_safe_wall': 'Safe View',
    'v_safe_wall_sub': 'Indirect projection protects your eyes.',
    'v_danger_sun': 'DANGER!',
    'v_danger_sun_sub': 'Permanent Eye Damage! Never look directly at the Sun.',
    'v_danger_sunglasses': 'UNSAFE!',
    'v_danger_sunglasses_sub': 'Standard sunglasses do NOT block harmful solar radiation!',
    'v_danger_binos': 'EXTREME DANGER!',
    'v_danger_binos_sub': 'Lenses magnify the burn! Instant severe damage.',
    'v_safe_glasses': 'SAFE VIEWING',
    'v_safe_glasses_sub': 'Certified solar filters block harmful rays.',
  },
  'hi': {
    'app_title': 'सुरक्षित सूर्य ग्रहण दर्शन',
    'app_subtitle': 'कक्षा 7 • पृथ्वी, चंद्रमा और सूर्य',
    'scen_1_opt': 'परिदृश्य 1: दर्पण प्रक्षेपण विधि',
    'scen_2_opt': 'परिदृश्य 2: सीधे आंखों की सुरक्षा',
    'observation_complete': 'अवलोकन पूर्ण',
    'btn_next': 'अगला परिदृश्य',
    'btn_restart': 'प्रयोगशाला पुनः प्रारंभ करें',
    'assets_panel_title': 'उपकरण',
    'lbl_sun': 'सूर्य',
    'lbl_screen': 'प्रक्षेपण स्क्रीन',
    'lbl_projector': 'दर्पण प्रोजेक्टर',
    'lbl_toolbox': 'उपकरण बॉक्स',
    'drag_eye_here': 'आंख को यहां खींचें',
    'sand': 'रेत',
    'mirror': 'दर्पण',
    'test_eye': 'परीक्षण आंख',
    'sunglasses': 'धूप का चश्मा',
    'binoculars': 'दूरबीन',
    'solar_filters': 'सौर फिल्टर',
    'observer': 'पर्यवेक्षक',
    'sum_title_1': 'प्रक्षेपण सफल',
    'sum_title_2': 'सुरक्षा पहले!',
    'sum_desc_1':
        'आपने सीखा कि एक साधारण दर्पण का उपयोग करके सूर्य की छवि को प्रक्षेपित करने से आंखों की क्षति के जोखिम के बिना ग्रहण को सुरक्षित, अप्रत्यक्ष रूप से देखा जा सकता है।',
    'sum_desc_2':
        'केवल विशेष रूप से प्रमाणित सौर फिल्टर सुरक्षित हैं। धूप का चश्मा और बिना फिल्टर वाले दूरबीन सूर्य को देखने के लिए बेहद खतरनाक हैं।',
    'feed_sand': 'गेंद रेत से भर गई।',
    'feed_mirror': 'दर्पण जुड़ गया।',
    'feed_stand': 'स्टैंड पर स्थापित।',
    'feed_aim': 'प्रक्षेपण पूरी तरह से लक्षित!',
    'feed_safe': 'सुरक्षित प्रक्षेपण दृश्य।',
    'feed_danger': 'खतरा! कभी भी सीधे सूर्य की ओर न देखें!',
    'feed_box': 'टूलबॉक्स खुल गया।',
    'feed_sunglasses': 'असुरक्षित! मानक धूप का चश्मा पर्याप्त नहीं हैं।',
    'feed_binos': 'खतरा! दूरबीन जोखिम को बढ़ाती है!',
    'feed_cert': 'सुरक्षित! प्रमाणित फिल्टर आपकी आंखों की रक्षा करते हैं।',
    'drag_horizontally': 'केंद्र के करीब लक्ष्य करने के लिए क्षैतिज रूप से खींचते रहें!',
    'v_safe_wall': 'सुरक्षित दृश्य',
    'v_safe_wall_sub': 'अप्रत्यक्ष प्रक्षेपण आपकी आंखों की रक्षा करता है।',
    'v_danger_sun': 'खतरा!',
    'v_danger_sun_sub': 'आंखों को स्थायी क्षति! कभी भी सीधे सूर्य की ओर न देखें।',
    'v_danger_sunglasses': 'असुरक्षित!',
    'v_danger_sunglasses_sub': 'साधारण धूप का चश्मा हानिकारक सौर विकिरण को नहीं रोकता!',
    'v_danger_binos': 'अत्यधिक खतरा!',
    'v_danger_binos_sub': 'लेंस जलन को कई गुना बढ़ा देते हैं! तुरंत गंभीर क्षति।',
    'v_safe_glasses': 'सुरक्षित दर्शन',
    'v_safe_glasses_sub': 'प्रमाणित सौर फिल्टर हानिकारक किरणों को रोकते हैं।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'Construct and use a mirror-based projection system to safely view a solar eclipse, as described in the textbook.',
      steps: [
        LabStep(
          concept: 'Stabilizing the Base',
          action: 'DRAG the bag of sand and DROP it onto the hollow ball.',
          observation: 'The ball is half-filled with sand and becomes stable.',
        ),
        LabStep(
          concept: 'Adding the Reflector',
          action: 'DRAG the small mirror and DROP it onto the sand-filled ball.',
          observation: 'The mirror is attached, creating a movable projector head.',
        ),
        LabStep(
          concept: 'Mounting the Projector',
          action: 'CLICK the assembled ball-mirror to place it onto the circular ring stand.',
          observation: 'The projector is mounted and ready to be aimed.',
        ),
        LabStep(
          concept: 'Aiming the Projection',
          action:
              'CLICK AND DRAG HORIZONTALLY on the screen to rotate the mirror and aim the reflected light beam at the wall.',
          observation: 'A clear, safe image of the eclipsed Sun appears on the wall.',
        ),
        LabStep(
          concept: 'Safety Verification',
          action: 'DRAG the Eye icon to the wall projection, then drag it to the Sun in the sky to compare.',
          observation:
              'Looking at the projection is safe. Looking directly at the Sun causes blinding, dangerous glare.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'Identify and use the correct safety equipment for directly viewing a solar eclipse.',
      steps: [
        LabStep(
          concept: 'Accessing Equipment',
          action: 'CLICK the toolbox on the table to open it.',
          observation: 'The toolbox opens, revealing various viewing items that jump onto the table.',
        ),
        LabStep(
          concept: 'Testing Sunglasses',
          action: "DRAG the Regular Sunglasses from the table onto the Observer's face.",
          observation: 'UNSAFE! The Sun remains blindingly bright. Harmful radiation is not blocked.',
        ),
        LabStep(
          concept: 'Testing Binoculars',
          action: "DRAG the Binoculars from the table onto the Observer's face.",
          observation: 'EXTREME DANGER! The lenses magnify the intense rays, causing immediate damage.',
        ),
        LabStep(
          concept: 'Testing Solar Filters',
          action: "DRAG the Certified Solar Filters from the table onto the Observer's face.",
          observation: 'SAFE! The bright glare is blocked, leaving a clear, orange image of the eclipse.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'पाठ्यपुस्तक में बताए अनुसार सूर्य ग्रहण को सुरक्षित रूप से देखने के लिए दर्पण-आधारित प्रक्षेपण प्रणाली का निर्माण और उपयोग करें।',
      steps: [
        LabStep(
          concept: 'आधार को स्थिर करना',
          action: 'रेत की थैली को खींचें और खोखली गेंद पर छोड़ें।',
          observation: 'गेंद रेत से आधी भर जाती है और स्थिर हो जाती है।',
        ),
        LabStep(
          concept: 'परावर्तक जोड़ना',
          action: 'छोटे दर्पण को खींचें और रेत से भरी गेंद पर छोड़ें।',
          observation: 'दर्पण जुड़ जाता है, जिससे एक चल प्रोजेक्टर सिर बनता है।',
        ),
        LabStep(
          concept: 'प्रोजेक्टर को स्थापित करना',
          action: 'एकत्रित गेंद-दर्पण को गोलाकार रिंग स्टैंड पर रखने के लिए क्लिक करें।',
          observation: 'प्रोजेक्टर स्थापित हो गया है और लक्ष्य करने के लिए तैयार है।',
        ),
        LabStep(
          concept: 'प्रक्षेपण को लक्ष्य करना',
          action:
              'दर्पण को घुमाने के लिए स्क्रीन पर क्षैतिज रूप से क्लिक करें और खींचें, तथा दीवार पर प्रकाश की किरण को लक्षित करें।',
          observation: 'दीवार पर ग्रहण वाले सूर्य की एक स्पष्ट, सुरक्षित छवि दिखाई देती है।',
        ),
        LabStep(
          concept: 'सुरक्षा सत्यापन',
          action: 'आंख के आइकन को दीवार के प्रक्षेपण पर खींचें, फिर तुलना करने के लिए इसे आकाश में सूर्य पर खींचें।',
          observation:
              'प्रक्षेपण को देखना सुरक्षित है। सीधे सूर्य को देखने से अंधा करने वाली, खतरनाक चमक पैदा होती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'सूर्य ग्रहण को सीधे देखने के लिए सही सुरक्षा उपकरणों की पहचान करें और उनका उपयोग करें।',
      steps: [
        LabStep(
          concept: 'उपकरणों तक पहुंच',
          action: 'मेज पर रखे टूलबॉक्स को खोलने के लिए उस पर क्लिक करें।',
          observation: 'टूलबॉक्स खुलता है, जिससे देखने के विभिन्न आइटम सामने आते हैं।',
        ),
        LabStep(
          concept: 'धूप के चश्मे का परीक्षण',
          action: 'नियमित धूप के चश्मे को मेज से पर्यवेक्षक के चेहरे पर खींचें।',
          observation: 'असुरक्षित! सूर्य अंधा करने वाला चमकीला बना रहता है। हानिकारक विकिरण अवरुद्ध नहीं होता है।',
        ),
        LabStep(
          concept: 'दूरबीन का परीक्षण',
          action: 'दूरबीन को मेज से पर्यवेक्षक के चेहरे पर खींचें।',
          observation: 'अत्यधिक खतरा! लेंस तीव्र किरणों को बढ़ाते हैं, जिससे तत्काल क्षति होती है।',
        ),
        LabStep(
          concept: 'सौर फिल्टर का परीक्षण',
          action: 'प्रमाणित सौर ग्रहण चश्मे को मेज से पर्यवेक्षक के चेहरे पर खींचें।',
          observation: 'सुरक्षित! तेज चमक अवरुद्ध हो जाती है, ग्रहण की स्पष्ट, नारंगी छवि बचती है।',
        ),
      ],
    ),
  ],
};

// =================================================================== PAINTER

/// Where a point's shadow falls on the plane y = [planeY].
_V3 _shadowOn(_V3 p, double planeY) {
  final t = (p.y - planeY) / _lightDir.y;
  return _V3(p.x - _lightDir.x * t, planeY, p.z - _lightDir.z * t);
}

/// Classroom scene: ground, Sun, table and either the mirror projector
/// (scenario 1) or the toolbox, viewing items and observer (scenario 2).
class _A6Painter extends CustomPainter {
  _A6Painter({required this.scene, required Listenable repaint, required this.lang, required this.text})
    : super(repaint: repaint);

  final _A6Scene scene;
  final LabLang lang;
  final String Function(String key) text;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.cam;
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = _fogColor);
    _ground(canvas, cam, bleed);
    _sun(canvas, cam);
    _groundShadows(canvas, cam);
    if (scene.scenario == 0) _wall(canvas, cam);
    _table(canvas, cam);
    if (scene.scenario == 0) {
      _s1Objects(canvas, cam);
    } else {
      _s2Objects(canvas, cam);
    }
    _labels(canvas, cam);
    if (scene.scenario == 0 && scene.step == 5) _indicators(canvas, cam);
  }

  // ---------------------------------------------------------- environment

  void _ground(Canvas canvas, _Cam cam, Rect bleed) {
    final flat = _V3(cam.fwd.x, 0, cam.fwd.z).unit;
    final foot = _V3(cam.pos.x, 0, cam.pos.z);
    double yAt(double dist) {
      final h = math.sqrt(math.max(1.0, dist * dist - cam.pos.y * cam.pos.y));
      return cam.pt(foot + flat * h).dy;
    }

    final yFar = yAt(100), y30 = yAt(30);
    final ground = _lit(const Color(0xFF1E293B), const _V3(0, 1, 0));
    final rect = Rect.fromLTRB(bleed.left, yFar, bleed.right, bleed.bottom);
    final span = math.max(1.0, y30 - yFar);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_fogColor, ground, labShade(ground, 0.06)],
          stops: [0, (span / rect.height).clamp(0.01, 0.98), 1],
        ).createShader(rect),
    );
  }

  /// Additive glowing Sun sprite (white core inside a golden halo).
  void _sun(Canvas canvas, _Cam cam) {
    final p = cam.project(_sunPos);
    if (p == null) return;
    final r = 22.5 * p.k;
    final dim = 1 - ((p.z - 30) / 70).clamp(0.0, 1.0) * 0.5;
    final rect = Rect.fromCircle(center: p.p, radius: r);
    canvas.drawCircle(
      p.p,
      r,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: dim),
            Colors.white.withValues(alpha: dim),
            Color.fromRGBO(255, 230, 100, 0.9 * dim),
            Color.fromRGBO(255, 150, 0, 0.4 * dim),
            const Color.fromRGBO(255, 100, 0, 0),
          ],
          stops: const [0, 0.35, 0.48, 0.675, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(p.p, r * 0.43, Paint()..color = Colors.white.withValues(alpha: dim));
  }

  void _groundShadows(Canvas canvas, _Cam cam) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    // Table top.
    final top = <Offset>[];
    for (final x in [-8.0, 8.0]) {
      for (final z in [-5.0, 5.0]) {
        for (final y in [4.75, 5.25]) {
          final p = cam.project(_shadowOn(_V3(x, y, z), 0));
          if (p != null) top.add(p.p);
        }
      }
    }
    if (top.length > 2) canvas.drawPath(_poly(_hull(top)), paint);
    // Legs.
    for (final x in [-7.0, 7.0]) {
      for (final z in [-4.0, 4.0]) {
        final a = cam.project(_V3(x, 0, z)), b = cam.project(_shadowOn(_V3(x, 4.75, z), 0));
        if (a == null || b == null) continue;
        canvas.drawLine(
          a.p,
          b.p,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.3)
            ..strokeWidth = 0.5 * a.k
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
    // Observer (scenario 2).
    if (scene.scenario == 1) {
      final pts = <Offset>[];
      for (final (x, y, z) in [
        (-1.2, 0.0, -0.4),
        (1.2, 0.0, -0.4),
        (-1.2, 0.0, 1.2),
        (1.2, 0.0, 1.2),
        (-1.6, 6.8, 0.0),
        (1.6, 6.8, 0.0),
        (0.0, 9.2, 0.0),
      ]) {
        final p = cam.project(_shadowOn(scene.human(x, y, z), 0));
        if (p != null) pts.add(p.p);
      }
      if (pts.length > 2) canvas.drawPath(_poly(_hull(pts)), paint);
    }
  }

  /// Projection screen wall (x = 15) with the crescent spot.
  void _wall(Canvas canvas, _Cam cam) {
    final corners = [
      const _V3(15, 0, -15), const _V3(15, 15, -15), const _V3(15, 15, 15), const _V3(15, 0, 15), //
    ];
    final pts = <Offset>[];
    for (final c in corners) {
      final p = cam.project(c);
      if (p == null) return;
      pts.add(p.p);
    }
    final base = _fog(_lit(const Color(0xFF475569), const _V3(-1, 0, 0)), (const _V3(15, 7.5, 0) - cam.pos).length);
    final path = _poly(pts);
    final b = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(base, 0.08), base, labShade(base, -0.18)],
        ).createShader(b),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.25),
    );
    if (scene.spotOpacity > 0.005) _spot(canvas, cam);
  }

  /// The 5 x 5 projection plane with its glow + crescent canvas texture,
  /// mapped onto the wall with an affine approximation.
  void _spot(Canvas canvas, _Cam cam) {
    final c = scene.spotPos;
    final o = cam.project(c), pu = cam.project(c + const _V3(0, 0, 1)), pv = cam.project(c + const _V3(0, -1, 0));
    if (o == null || pu == null || pv == null) return;
    const s = 5 / 256;
    final ex = (pu.p - o.p) * s, ey = (pv.p - o.p) * s;
    final m = Float64List.fromList([
      ex.dx, ex.dy, 0, 0, //
      ey.dx, ey.dy, 0, 0,
      0, 0, 1, 0,
      o.p.dx - (ex.dx + ey.dx) * 128, o.p.dy - (ex.dy + ey.dy) * 128, 0, 1,
    ]);
    final a = scene.spotOpacity;
    canvas.save();
    canvas.transform(m);
    const tex = Rect.fromLTWH(0, 0, 256, 256);
    // The HTML 'destination-out' circle erases both the glow and the disc,
    // leaving the Moon's dark bite in the projected image.
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(tex),
        Path()..addOval(Rect.fromCircle(center: const Offset(98, 158), radius: 72)),
      ),
    );
    canvas.drawRect(
      tex,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(255, 255, 200, 0.8 * a),
            Color.fromRGBO(255, 255, 200, 0.8 * a),
            Color.fromRGBO(255, 220, 50, 0.5 * a),
            const Color.fromRGBO(0, 0, 0, 0),
          ],
          stops: const [0, 0.3125, 0.52, 1],
        ).createShader(tex),
    );
    canvas.drawPath(
      Path()..addOval(Rect.fromCircle(center: const Offset(128, 128), radius: 70)),
      Paint()
        ..blendMode = BlendMode.plus
        ..color = const Color(0xFFFFFAE6).withValues(alpha: a),
    );
    canvas.restore();
  }

  void _table(Canvas canvas, _Cam cam) {
    const wood = Color(0xFF8B5A2B);
    final legs = [
      for (final x in [-7.0, 7.0])
        for (final z in [-4.0, 4.0]) _V3(x, 0, z),
    ]..sort((a, b) => cam.depth(b).compareTo(cam.depth(a)));
    for (final l in legs) {
      _vcyl(canvas, cam, l, 5, 0.2, 0.3, wood, cap: false);
    }
    _box(canvas, cam, const _V3(0, 5, 0), const _V3(8, 0, 0), const _V3(0, 0.25, 0), const _V3(0, 0, 5), wood);
    // Subtle wood grain on the table top.
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var z = -4.0; z <= 4.0; z += 1.6) {
      final a = cam.project(_V3(-8, 5.26, z)), b = cam.project(_V3(8, 5.26, z));
      if (a != null && b != null) canvas.drawLine(a.p, b.p, grain);
    }
  }

  void _tableShadow(Canvas canvas, _Cam cam, List<_V3> pts) {
    final out = <Offset>[];
    for (final p in pts) {
      final s = cam.project(_shadowOn(p, 5.26));
      if (s != null) out.add(s.p);
    }
    if (out.length < 3) return;
    canvas.drawPath(
      _poly(_hull(out)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // ---------------------------------------------------------- scenario 1

  void _ring(Canvas canvas, _Cam cam, {required bool far}) {
    final cd = cam.depth(_standPos);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _lit(const Color(0xFF555555), const _V3(0, 1, 0));
    final hi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 40; i++) {
      final a0 = i / 40 * math.pi * 2, a1 = (i + 1) / 40 * math.pi * 2;
      final p0 = _standPos + _V3(1.2 * math.cos(a0), 0, 1.2 * math.sin(a0));
      final p1 = _standPos + _V3(1.2 * math.cos(a1), 0, 1.2 * math.sin(a1));
      if ((cam.depth((p0 + p1) * 0.5) > cd) != far) continue;
      final q0 = cam.project(p0), q1 = cam.project(p1);
      if (q0 == null || q1 == null) continue;
      paint.strokeWidth = 0.3 * q0.k;
      hi.strokeWidth = 0.08 * q0.k;
      canvas.drawLine(q0.p, q1.p, paint);
      canvas.drawLine(q0.p.translate(0, -0.06 * q0.k), q1.p.translate(0, -0.06 * q1.k), hi);
    }
  }

  List<Offset> _circle(_Cam cam, _V3 c, double r, {int n = 32}) => [
    for (var i = 0; i < n; i++)
      cam.pt(c + _V3(r * math.cos(i / n * math.pi * 2), 0, r * math.sin(i / n * math.pi * 2))),
  ];

  void _s1Objects(Canvas canvas, _Cam cam) {
    final b = scene.ballPos;
    _tableShadow(canvas, cam, [
      for (var i = 0; i < 12; i++) b + _V3(1.5 * math.cos(i * math.pi / 6), 0, 1.5 * math.sin(i * math.pi / 6)),
    ]);
    _ring(canvas, cam, far: true);

    final pb = cam.project(b);
    if (pb != null) {
      final r = 1.5 * pb.k;
      final disk = Rect.fromCircle(center: pb.p, radius: r);
      // Sand (lower hemisphere, flat top at the equator).
      if (scene.sandVisible) {
        final eq = _circle(cam, b, 1.45);
        final lower = Path()
          ..addArc(Rect.fromCircle(center: pb.p, radius: r * 0.97), 0, math.pi)
          ..addPath(_poly(eq), Offset.zero);
        canvas.save();
        canvas.clipPath(Path()..addOval(disk));
        canvas.drawPath(lower, Paint()..color = _lit(const Color(0xFFD2B48C), const _V3(0, 0.3, 1).unit));
        canvas.drawPath(_poly(eq), Paint()..color = _lit(const Color(0xFFD2B48C), const _V3(0, 1, 0)));
        canvas.restore();
      }
      // Glassy hollow ball (transmission 0.5, opacity 0.8).
      final lightLeft = _lightDir.dot(cam.right) < 0;
      canvas.drawCircle(
        pb.p,
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(lightLeft ? -0.35 : 0.35, -0.45),
            colors: [
              Colors.white.withValues(alpha: 0.55),
              const Color(0xFFCCCCCC).withValues(alpha: scene.sandVisible ? 0.28 : 0.5),
              const Color(0xFF8A94A6).withValues(alpha: 0.6),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(disk),
      );
      canvas.drawCircle(
        pb.p,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.45),
      );
      canvas.drawCircle(
        pb.p + Offset(lightLeft ? -r * 0.4 : r * 0.4, -r * 0.45),
        r * 0.16,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06 + 0.5),
      );
    }
    if (scene.mirrorVisible) _mirror(canvas, cam);
    _ring(canvas, cam, far: false);
    if (scene.beamVisible && scene.beamOpacity > 0) _beam(canvas, cam);
  }

  void _mirror(Canvas canvas, _Cam cam) {
    final c = scene.ballPos + const _V3(0, 1.1, 0);
    final rot = scene.ballRotY;
    final handle = c + const _V3(0, 0, 1.6).rotY(rot);
    void drawHandle() => _box(
      canvas,
      cam,
      handle,
      const _V3(0.1, 0, 0).rotY(rot),
      const _V3(0, 0.05, 0),
      const _V3(0, 0, 0.4).rotY(rot),
      const Color(0xFF475569),
    );
    final handleFar = cam.depth(handle) > cam.depth(c);
    if (handleFar) drawHandle();
    _vcyl(canvas, cam, c - const _V3(0, 0.075, 0), 0.15, 1.45, 1.45, const Color(0xFF475569));
    final disc = _circle(cam, c + const _V3(0, 0.08, 0), 1.4, n: 40);
    final path = _poly(disc);
    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8), Color(0xFFE2E8F0), Color(0xFF64748B)],
          stops: [0, 0.4, 0.6, 1],
        ).createShader(bounds),
    );
    canvas.drawLine(
      Offset(bounds.left + bounds.width * 0.3, bounds.top + bounds.height * 0.3),
      Offset(bounds.left + bounds.width * 0.55, bounds.top + bounds.height * 0.18),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    if (!handleFar) drawHandle();
  }

  /// Reflected light beam from the mirror to the wall (additive, brighter
  /// towards the wall like the HTML canvas gradient).
  void _beam(Canvas canvas, _Cam cam) {
    final a = scene.projectorAngle;
    final o = const _V3(2, 7.9, 0);
    final d = _V3(math.cos(a), 0, -math.sin(a));
    final len = _distToWall / math.cos(a);
    final n1 = const _V3(0, 1, 0), n2 = d.cross(n1).unit;
    final pts = <Offset>[];
    for (final t in [0.4, len]) {
      final r = 3 - 1.6 * (t / 20);
      for (var i = 0; i < 24; i++) {
        final th = i / 24 * math.pi * 2;
        final p = cam.project(o + d * t + n1 * (r * math.cos(th)) + n2 * (r * math.sin(th)));
        if (p != null) pts.add(p.p);
      }
    }
    final ps = cam.project(o), pe = cam.project(o + d * len);
    if (ps == null || pe == null || pts.length < 3) return;
    final op = scene.beamOpacity;
    canvas.drawPath(
      _poly(_hull(pts)),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.linear(ps.p, pe.p, [
          const Color.fromRGBO(255, 255, 255, 0),
          Color.fromRGBO(255, 255, 255, 0.8 * (len / 20) * op),
        ]),
    );
  }

  // ---------------------------------------------------------- scenario 2

  void _s2Objects(Canvas canvas, _Cam cam) {
    // Toolbox (base + hinged lid), with its shadow on the table.
    _tableShadow(canvas, cam, [
      for (final x in [-2.0, 2.0])
        for (final z in [-1.5, 1.5]) _V3(x, 7.65, z),
      for (final x in [-2.0, 2.0])
        for (final z in [-1.5, 1.5]) _V3(x, 5.25, z),
    ]);
    const red = Color(0xFFCC3333);
    final open = scene.lidAngle.abs() > 0.05;
    _box(
      canvas,
      cam,
      const _V3(0, 6.25, 0),
      const _V3(2, 0, 0),
      const _V3(0, 1, 0),
      const _V3(0, 0, 1.5),
      red,
      topColor: open ? const Color(0xFF3A0E0E) : null,
    );
    // Latch on the front.
    _box(
      canvas,
      cam,
      const _V3(0, 6.9, 1.52),
      const _V3(0.35, 0, 0),
      const _V3(0, 0.22, 0),
      const _V3(0, 0, 0.03),
      const Color(0xFF94A3B8),
      edges: false,
    );
    const hinge = _V3(0, 7.25, -1.5);
    final th = scene.lidAngle;
    _box(
      canvas,
      cam,
      hinge + const _V3(0, 0.2, 1.5).rotX(th),
      const _V3(2, 0, 0),
      const _V3(0, 0.2, 0).rotX(th),
      const _V3(0, 0, 1.5).rotX(th),
      red,
    );

    // Viewing items on the table.
    for (var i = 0; i < 3; i++) {
      if (!scene.itemVisible[i]) continue;
      var pos = scene.itemPos[i];
      if (scene.activeItem == i) pos = _V3(pos.x, 5.5 + math.sin(scene.time * 5) * 0.2, pos.z);
      final p = cam.project(pos);
      if (p == null) continue;
      final sh = cam.project(_V3(pos.x, 5.27, pos.z));
      if (sh != null) labGroundShadow(canvas, sh.p, 1.3 * sh.k, 0.35 * sh.k, opacity: 0.35);
      _drawItem(canvas, i, p.p, p.k);
    }
    _observer(canvas, cam);
  }

  void _observer(Canvas canvas, _Cam cam) {
    const skin = Color(0xFF8D5524), shirt = Color(0xFF3B2C63), pants = Color(0xFF1E293B), dark = Color(0xFF111111);
    final h = scene.human;
    final parts = <(double, VoidCallback)>[];
    void add(_V3 at, VoidCallback draw) => parts.add((cam.depth(at), draw));

    for (final sx in [0.7, -0.7]) {
      add(h(sx, 1.9, 0), () => _limb(canvas, cam, h(sx, 3.4, 0), h(sx, 0.6, 0), 0.5, pants));
      add(h(sx, 0.3, 0.4), () {
        _box(
          canvas,
          cam,
          h(sx, 0.3, 0.4),
          const _V3(0.6, 0, 0).rotY(_humanRot),
          const _V3(0, 0.4, 0),
          const _V3(0, 0, 1).rotY(_humanRot),
          dark,
        );
      });
    }
    add(h(0, 5, 0), () => _vcyl(canvas, cam, h(0, 3, 0), h(0, 7, 0).y - h(0, 3, 0).y, 1.4, 1.4, shirt));
    for (final side in [1.0, -1.0]) {
      final down = const _V3(0, -1, 0).rotX(scene.armRot);
      final sh = _V3(1.8 * side, 6.5, 0);
      _V3 at(double t) => h(sh.x + down.x * t, sh.y + down.y * t, sh.z + down.z * t);
      add(at(1.75), () {
        _limb(canvas, cam, at(0.2), at(3.5), 0.35, skin);
        final hp = cam.project(at(3.9));
        if (hp != null) labSphere(canvas, hp.p, 0.38 * hp.k, _lit(skin, (cam.pos - at(3.9)).unit), highlight: 0.25);
      });
    }
    add(h(0, 8, 0), () {
      final hp = cam.project(scene.headCenter);
      if (hp == null) return;
      final lightLeft = _lightDir.dot(cam.right) < 0;
      labSphere(
        canvas,
        hp.p,
        1.2 * hp.k,
        _lit(skin, const _V3(0, 0.6, 0.8).unit),
        light: Offset(lightLeft ? -0.35 : 0.35, -0.45),
        highlight: 0.3,
        shade: 0.5,
      );
      // Face features only when the face turns towards the camera.
      final face = const _V3(0, 0, 1).rotX(scene.headTilt).rotY(_humanRot);
      if (face.dot((cam.pos - scene.headCenter).unit) > 0.15) {
        for (final ex in [-0.4, 0.4]) {
          final e = cam.project(scene.headCenter + _V3(ex, 0.2, 1.15).rotX(scene.headTilt).rotY(_humanRot));
          if (e != null) canvas.drawCircle(e.p, 0.15 * e.k, Paint()..color = dark);
        }
      }
    });
    parts.sort((a, b) => b.$1.compareTo(a.$1));
    for (final p in parts) {
      p.$2();
    }
  }

  // ---------------------------------------------------------- labels

  void _labels(Canvas canvas, _Cam cam) {
    void label(String id, String key, _V3 at, {bool sun = false}) {
      final o = scene.labelAlpha[id] ?? 0;
      final p = cam.project(at);
      if (o <= 0.01 || p == null) return;
      labText(
        canvas,
        sun ? text(key).toUpperCase() : text(key),
        p.p,
        size: 14,
        weight: FontWeight.w700,
        letterSpacing: sun ? 2.2 : 0,
        color: sun ? const Color(0xFFFDE047) : const Color(0xFFE2E8F0),
        background: sun ? const Color(0x80713F12) : const Color(0x800F172A),
        border: sun ? const Color(0x4DFACC15) : const Color(0x4D94A3B8),
        borderWidth: 1,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        opacity: o,
      );
    }

    label('sun', 'lbl_sun', _sunPos + const _V3(0, 8, 0), sun: true);
    if (scene.scenario == 0) {
      label('screen', 'lbl_screen', const _V3(15, 16.5, 0));
      label('projector', 'lbl_projector', scene.ballPos + const _V3(0, 4, 0));
    } else {
      label('toolbox', 'lbl_toolbox', const _V3(0, 9.25, 0));
      label('observer', 'observer', scene.headCenter + const _V3(0, 2, 0));
      const keys = ['sunglasses', 'binoculars', 'solar_filters'];
      for (var i = 0; i < 3; i++) {
        // The middle label sits higher so the three names don't overlap.
        label('item$i', keys[i], scene.itemPos[i] + _V3(0, i == 1 ? 2.7 : 1.5, 0));
      }
    }
  }

  /// "Drag Eye Here" ping rings at the Sun (red) and the projection (green).
  void _indicators(Canvas canvas, _Cam cam) {
    void ind(_V3 at, Color ring, Color pill) {
      final p = cam.project(at);
      if (p == null) return;
      final t = scene.time % 1;
      final prog = Curves.easeOut.transform((t / 0.75).clamp(0.0, 1.0));
      final c = p.p.translate(0, -12);
      canvas.drawCircle(
        c,
        32 * (1 + prog),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = ring.withValues(alpha: 1 - prog),
      );
      canvas.drawCircle(
        c,
        32,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ring.withValues(alpha: 0.6),
      );
      labText(
        canvas,
        text('drag_eye_here').toUpperCase(),
        p.p.translate(0, 34),
        size: 13,
        weight: FontWeight.w800,
        letterSpacing: 1,
        color: Colors.white,
        background: pill,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      );
    }

    if (!scene.testsSun) ind(_sunPos, const Color(0xFFEF4444), const Color(0xFFDC2626));
    if (!scene.testsWall) ind(scene.spotPos, const Color(0xFF22C55E), const Color(0xFF16A34A));
  }

  @override
  bool shouldRepaint(covariant _A6Painter old) => old.lang != lang || old.scene != scene;
}

/// The three viewing items (drawn facing the viewer): regular sunglasses,
/// binoculars and certified solar-filter glasses.
void _drawItem(Canvas canvas, int type, Offset c, double k) {
  switch (type) {
    case 0:
      final frame = Paint()..color = const Color(0xFF111111);
      final lens = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF475569), Color(0xFF0B0F19)],
        ).createShader(Rect.fromCenter(center: c, width: 1.2 * k, height: 0.4 * k));
      for (final s in [-1.0, 1.0]) {
        final r = Rect.fromCenter(center: c + Offset(0.3 * s * k, 0), width: 0.52 * k, height: 0.36 * k);
        canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(0.04 * k), Radius.circular(0.14 * k)), frame);
        canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(0.12 * k)), lens);
      }
      canvas.drawLine(c + Offset(-0.06 * k, -0.08 * k), c + Offset(0.06 * k, -0.08 * k), frame..strokeWidth = 0.06 * k);
      canvas.drawLine(
        c + Offset(-0.24 * k, -0.06 * k),
        c + Offset(-0.18 * k, -0.08 * k),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = 0.04 * k
          ..strokeCap = StrokeCap.round,
      );
    case 1:
      for (final s in [-1.0, 1.0]) {
        final r = Rect.fromCenter(center: c + Offset(0.24 * s * k, 0), width: 0.42 * k, height: 0.62 * k);
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(0.12 * k)),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF1F1F1F), Color(0xFF4B4B4B), Color(0xFF262626)],
            ).createShader(r),
        );
        canvas.drawOval(
          Rect.fromCenter(center: r.topCenter + Offset(0, 0.06 * k), width: 0.34 * k, height: 0.12 * k),
          Paint()..color = const Color(0xFF0A0A0A),
        );
        canvas.drawOval(
          Rect.fromCenter(center: r.bottomCenter - Offset(0, 0.06 * k), width: 0.36 * k, height: 0.12 * k),
          Paint()..color = const Color(0xFF64748B),
        );
      }
      canvas.drawRect(
        Rect.fromCenter(center: c, width: 0.14 * k, height: 0.3 * k),
        Paint()..color = const Color(0xFF333333),
      );
    default:
      final r = Rect.fromCenter(center: c, width: 1.4 * k, height: 0.5 * k);
      final frame = RRect.fromRectAndRadius(r, Radius.circular(0.12 * k));
      canvas.drawRRect(frame, Paint()..color = const Color(0xFF6366F1));
      for (final s in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: c + Offset(0.32 * s * k, 0.02 * k), width: 0.46 * k, height: 0.3 * k),
          Paint()..shader = const LinearGradient(colors: [Color(0xFF0B0B0B), Color(0xFF3F3F46)]).createShader(r),
        );
      }
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.04 * k
          ..color = const Color(0xFFA5B4FC),
      );
  }
}

/// Icon painter for the drag ghost of a viewing item.
class _A6ItemIconPainter extends CustomPainter {
  const _A6ItemIconPainter(this.type);
  final int type;

  @override
  void paint(Canvas canvas, Size size) => _drawItem(canvas, type, size.center(Offset.zero), size.width * 0.62);

  @override
  bool shouldRepaint(covariant _A6ItemIconPainter old) => old.type != type;
}

/// The SVG eclipse discs of the vision overlay: a yellow (projection) or
/// orange (solar filter) Sun partly covered by a black Moon.
class _A6EclipseIconPainter extends CustomPainter {
  const _A6EclipseIconPainter({required this.orange});
  final bool orange;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    canvas.drawCircle(
      Offset(50 * u, 50 * u),
      40 * u,
      Paint()..color = orange ? const Color(0xFFF97316) : const Color(0xFFFACC15),
    );
    canvas.drawCircle(Offset((orange ? 65 : 35) * u, 65 * u), 38 * u, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _A6EclipseIconPainter old) => old.orange != orange;
}

/// HTML `.danger-flash`: radial white -> yellow -> red, flickering.
class _A6DangerPainter extends CustomPainter {
  _A6DangerPainter({required this.scene, required Listenable repaint, required this.contrast})
    : super(repaint: repaint);
  final _A6Scene scene;
  final bool contrast;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final flick = (scene.time * 10).floor().isEven ? 0.0 : 1.0;
    final colors = contrast
        ? const [Color(0xFFFFFFFF), Color(0xFFFFF200), Color(0xFFFF0000)]
        : const [Color(0xFFFFFFFF), Color(0xFFFFFF00), Color(0xFFFF0000)];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.75,
          colors: colors,
          stops: contrast ? const [0.06, 0.32, 0.72] : const [0.1, 0.4, 0.8],
        ).createShader(rect),
    );
    canvas.drawRect(rect, Paint()..color = Colors.white.withValues(alpha: 0.18 * flick));
  }

  @override
  bool shouldRepaint(covariant _A6DangerPainter old) => old.contrast != contrast || old.scene != scene;
}

/// Aim reticle shown while aiming the projector.
class _A6ReticlePainter extends CustomPainter {
  const _A6ReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(c, size.width * 0.3, p);
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), p);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), p);
  }

  @override
  bool shouldRepaint(covariant _A6ReticlePainter oldDelegate) => false;
}

// ============================================================ 3D MATH

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;

  /// Rotation about the y axis (Three.js rotation.y).
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  /// Rotation about the x axis (Three.js rotation.x).
  _V3 rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x, y * c - z * s, y * s + z * c);
  }
}

typedef _Proj = ({Offset p, double z, double k});

class _Cam {
  _Cam(this.pos, _V3 target, {required this.f, required this.center}) {
    fwd = (target - pos).unit;
    var r = fwd.cross(const _V3(0, 1, 0));
    if (r.length < 1e-6) r = const _V3(1, 0, 0);
    right = r.unit;
    up = right.cross(fwd);
  }

  final _V3 pos;
  final double f;
  final Offset center;
  late final _V3 fwd;
  late final _V3 right;
  late final _V3 up;
  static const double near = 0.15;

  double depth(_V3 w) => (w - pos).dot(fwd);

  _Proj? project(_V3 w) {
    final d = w - pos;
    final z = d.dot(fwd);
    if (z < near) return null;
    final k = f / z;
    return (p: Offset(center.dx + d.dot(right) * k, center.dy - d.dot(up) * k), z: z, k: k);
  }

  Offset pt(_V3 w) => project(w)?.p ?? center;

  _V3 ray(Offset s) => (fwd + right * ((s.dx - center.dx) / f) + up * ((center.dy - s.dy) / f)).unit;

  double rayDistance(Offset s, _V3 q) {
    final d = ray(s);
    final v = q - pos;
    final t = math.max(0.0, v.dot(d));
    return (v - d * t).length;
  }

  /// Slab test: does the ray through [s] hit the axis-aligned box?
  bool rayHitsBox(Offset s, _V3 min, _V3 max) {
    final d = ray(s);
    var t0 = 0.0, t1 = 1e9;
    for (final (o, dir, lo, hi) in [
      (pos.x, d.x, min.x, max.x),
      (pos.y, d.y, min.y, max.y),
      (pos.z, d.z, min.z, max.z),
    ]) {
      if (dir.abs() < 1e-9) {
        if (o < lo || o > hi) return false;
        continue;
      }
      var a = (lo - o) / dir, b = (hi - o) / dir;
      if (a > b) (a, b) = (b, a);
      t0 = math.max(t0, a);
      t1 = math.min(t1, b);
      if (t0 > t1) return false;
    }
    return true;
  }
}

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);
const double _f = 640;
const double _s2F = 760;
const Offset _center = Offset(490, 280);
const Color _fogColor = Color(0xFF0F172A);

final _V3 _lightDir = const _V3(-15, 18, -25).unit;
const _V3 _sunPos = _V3(-15, 18, -25);
const double _distToWall = 13;

const _V3 _s1CamPos = _V3(-15, 12, 20), _s1CamTarget = _V3(0, 5, 0);
const _V3 _testCamPos = _V3(-5, 20, 35), _testCamTarget = _V3(-5, 15, -10);
const _V3 _s2CamPos = _V3(8, 15, 32), _s2CamTarget = _V3(-2, 6, -5);

const _V3 _ballStart = _V3(-4, 6.5, 0);
const _V3 _ballOnStand = _V3(2, 6.8, 0);
const _V3 _standPos = _V3(2, 5.25, 0);
const _V3 _humanPos = _V3(-3, 0, 9.5);
const double _humanRot = math.pi - 0.2;

class _A6Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  _V3 camPos = _s1CamPos;
  _V3 camTarget = _s1CamTarget;
  double focal = _f;

  // Scenario 1: projector build.
  bool sandVisible = false;
  bool mirrorVisible = false;
  _V3 ballPos = _ballStart;
  double ballRotY = 0;
  double projectorAngle = 0.6;
  bool beamVisible = false;
  double spotOpacity = 0;
  double beamOpacity = 0;
  bool testsWall = false;
  bool testsSun = false;

  // Scenario 2: toolbox and observer.
  double lidAngle = 0;
  final List<_V3> itemPos = [for (var i = 0; i < 3; i++) const _V3(0, 5, 0)];
  final List<bool> itemVisible = [false, false, false];
  int? draggingItem;
  double armRot = 0;
  double headTilt = 0;

  final Map<String, double> labelAlpha = {};

  _Cam get cam => _Cam(camPos, camTarget, f: focal, center: _center);

  double get intensity => math.max(0, 1 - projectorAngle.abs() * 1.5);

  _V3 get spotPos => _V3(14.9, 8, -math.tan(projectorAngle) * _distToWall);

  /// Observer local -> world (rotation.y = PI - 0.2, breathing scale.y).
  _V3 human(double x, double y, double z) {
    final breathe = 1 + math.sin(time * 2) * 0.01;
    return _humanPos + _V3(x, y * breathe, z).rotY(_humanRot);
  }

  _V3 get headCenter => human(0, 8, 0);

  /// Index of the item the current step asks for (scenario 2).
  int? get activeItem => scenario == 1 && step >= 2 && step <= 4 ? step - 2 : null;

  Map<String, bool> labelTargets() => {
    'sun': true,
    'screen': scenario == 0,
    'projector': scenario == 0,
    'toolbox': scenario == 1,
    'observer': scenario == 1,
    for (var i = 0; i < 3; i++) 'item$i': scenario == 1 && itemVisible[i],
  };

  void reset(int sc) {
    scenario = sc;
    step = 1;
    sandVisible = false;
    mirrorVisible = false;
    ballPos = _ballStart;
    ballRotY = 0;
    projectorAngle = 0.6;
    beamVisible = false;
    spotOpacity = 0;
    beamOpacity = 0;
    testsWall = false;
    testsSun = false;
    lidAngle = 0;
    for (var i = 0; i < 3; i++) {
      itemPos[i] = _V3(0, 5.5, 0);
      itemVisible[i] = false;
    }
    draggingItem = null;
    armRot = 0;
    headTilt = 0;
    labelAlpha.clear();
  }
}

// ============================================================ SHADING

/// Lambert shading for the directional "sun" light plus ambient.
Color _lit(Color c, _V3 n, {double amb = 0.55, double dif = 1.6}) {
  final f = amb + dif * math.max(0.0, n.dot(_lightDir));
  int ch(double v) => (v * 255 * f).round().clamp(0, 255);
  return Color.fromARGB(255, ch(c.r), ch(c.g), ch(c.b));
}

/// Scene fog (THREE.Fog 0x0f172a, 30 .. 100).
Color _fog(Color c, double dist) => Color.lerp(c, _fogColor, ((dist - 30) / 70).clamp(0.0, 1.0))!;

Path _poly(List<Offset> pts, {bool close = true}) {
  final p = Path();
  for (var i = 0; i < pts.length; i++) {
    if (i == 0) {
      p.moveTo(pts[i].dx, pts[i].dy);
    } else {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
  }
  if (close) p.close();
  return p;
}

List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final s = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in s) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in s.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Oriented box: centre, three half-axis vectors. Draws the faces that
/// face the camera with Lambert shading.
void _box(Canvas canvas, _Cam cam, _V3 c, _V3 ax, _V3 ay, _V3 az, Color color, {bool edges = true, Color? topColor}) {
  final faces = <(_V3, List<_V3>)>[
    for (final s in [1.0, -1.0]) ...[
      (ax * s, [c + ax * s + ay + az, c + ax * s + ay - az, c + ax * s - ay - az, c + ax * s - ay + az]),
      (ay * s, [c + ay * s + ax + az, c + ay * s + ax - az, c + ay * s - ax - az, c + ay * s - ax + az]),
      (az * s, [c + az * s + ax + ay, c + az * s + ax - ay, c + az * s - ax - ay, c + az * s - ax + ay]),
    ],
  ];
  final dist = (c - cam.pos).length;
  for (final (n, quad) in faces) {
    final center = (quad[0] + quad[2]) * 0.5;
    if (n.dot(cam.pos - center) <= 0) continue;
    final pts = <Offset>[];
    for (final q in quad) {
      final p = cam.project(q);
      if (p == null) return;
      pts.add(p.p);
    }
    final base = (topColor != null && n.unit.y > 0.7) ? topColor : color;
    final path = _poly(pts);
    canvas.drawPath(path, Paint()..color = _fog(_lit(base, n.unit), dist));
    if (edges) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.black.withValues(alpha: 0.18),
      );
    }
  }
}

/// Upright cylinder / frustum between [base] and [base] + [h] (y up).
void _vcyl(Canvas canvas, _Cam cam, _V3 base, double h, double rBottom, double rTop, Color color, {bool cap = true}) {
  final pts = <Offset>[];
  final top = <Offset>[];
  for (var i = 0; i < 24; i++) {
    final a = i / 24 * math.pi * 2;
    final pb = cam.project(base + _V3(rBottom * math.cos(a), 0, rBottom * math.sin(a)));
    final pt = cam.project(base + _V3(rTop * math.cos(a), h, rTop * math.sin(a)));
    if (pb == null || pt == null) return;
    pts
      ..add(pb.p)
      ..add(pt.p);
    top.add(pt.p);
  }
  final hull = _hull(pts);
  final bounds = _poly(hull).getBounds();
  final dist = (base - cam.pos).length;
  final side = _fog(_lit(color, (cam.pos - base).unit), dist);
  final lightLeft = _lightDir.dot(cam.right) < 0;
  final cols = [labShade(side, -0.35), side, labShade(side, 0.18), labShade(side, -0.3)];
  canvas.drawPath(
    _poly(hull),
    Paint()
      ..shader = LinearGradient(
        colors: lightLeft ? cols.reversed.toList() : cols,
        stops: const [0, 0.35, 0.65, 1],
      ).createShader(bounds),
  );
  if (cap && cam.pos.y > base.y + h) {
    canvas.drawPath(_poly(top), Paint()..color = _fog(_lit(color, const _V3(0, 1, 0)), dist));
  }
}

/// Thick limb (arm) between two points, drawn as a round-capped stroke.
void _limb(Canvas canvas, _Cam cam, _V3 a, _V3 b, double r, Color color) {
  final pa = cam.project(a), pb = cam.project(b);
  if (pa == null || pb == null) return;
  final w = r * (pa.k + pb.k);
  final shade = _lit(color, (cam.pos - a).unit);
  canvas.drawLine(
    pa.p,
    pb.p,
    Paint()
      ..color = labShade(shade, -0.25)
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawLine(
    pa.p,
    pb.p,
    Paint()
      ..color = shade
      ..strokeWidth = w * 0.6
      ..strokeCap = StrokeCap.round,
  );
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
