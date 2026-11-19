// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show DeviceGestureSettings, DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 3 • Activity 4
/// The Electric Switch.
///
/// Native Flutter port of `Cl7S-Ch3-A4-The_Electric_Switch.html`.
/// Scenario 1: build a safety-pin switch on cardboard (drag drawing pins,
/// the safety pin and the wire clips), rotate it to light the lamp and watch
/// the current flow. Scenario 2: drag circuit symbols onto the board, wire
/// the diagram and toggle the switch symbol.
class Ch3A4TheElectricSwitchPage extends StatefulWidget {
  const Ch3A4TheElectricSwitchPage({super.key});

  @override
  State<Ch3A4TheElectricSwitchPage> createState() => _Ch3A4TheElectricSwitchPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, spark 2365, switchTap 2585.
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
  spark('spark.mp3'),
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

class _Ch3A4TheElectricSwitchPageState extends State<Ch3A4TheElectricSwitchPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _SwitchScene _scene = _SwitchScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// HUD instruction turns red for 1 s after touching a locked object.
  bool _hudFlash = false;

  /// Time the placed safety pin started swinging open (-1 = idle).
  double _settleStart = -1;

  // Drag state (HTML dragStartPos / offset / intersectPlane).
  _V3 _dragStart3 = const _V3(0, 0, 0);
  _V3 _offset3 = const _V3(0, 0, 0);
  double _planeY = 0;
  Offset _dragStart2 = Offset.zero;
  Offset _offset2 = Offset.zero;

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
    _ticker = createTicker(_tick)..start();
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

  /// HTML `animate()`: particle flow, lever / safety-pin easing.
  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    final s = _scene;
    s.time = elapsed.inMicroseconds / 1e6;
    if (s.isOn) {
      // progress += 0.005 per frame at 60 fps.
      for (var i = 0; i < s.particles.length; i++) {
        var p = s.particles[i] + 0.3 * dt;
        if (p > 1) p = 0;
        s.particles[i] = p;
      }
    }
    final lever = s.s2On ? 1.0 : 0.0;
    s.lever += (lever - s.lever) * math.min(1, dt * 22);
    if (_settleStart >= 0) {
      final k = ((s.time - _settleStart) / 0.3).clamp(0.0, 1.0);
      s.safetyAngle = _safetyOpenAngle * Curves.easeOutCubic.transform(k);
      if (k >= 1) _settleStart = -1;
    }
    _frame.value = s.time;
  }

  // ------------------------------------------------------------ logic

  void _resetScene(int scenario) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.reset(scenario);
    _settleStart = -1;
    _hudFlash = false;
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _resetScene(index));

  void _fullReset() => setState(() => _resetScene(0));

  /// HTML `canInteractWith(objId)`: enforces the strict step order.
  bool _canInteract(String id) {
    final s = _scene;
    final step = s.step;
    if (s.scenario == 0) {
      if (step == 0) {
        if (id == 'pin1' && !s.pin1Placed) return true;
        if (id == 'safety' && s.pin1Placed && !s.safetyPlaced) return true;
      }
      if (step == 1 && id == 'pin2') return true;
      if (step == 2 && (id == 'redClip' || id == 'blackClip')) return true;
      if (step >= 3 && id == 'safety') return true;
    } else {
      if (step == 0 && id == 'symCell') return true;
      if (step == 1 && id == 'symLamp') return true;
      if (step == 2 && id == 'symSwitch') return true;
      if (step == 3 && id == 'conn_pt') return true;
      if (step >= 4 && id == 'symSwitch') return true;
    }
    return false;
  }

  /// Objects that react to a click instead of a drag (Scenario 2).
  bool _isClickable(String id) =>
      _scene.scenario == 1 && (id == 'conn_pt' || (id == 'symSwitch' && _scene.wiresConnected));

  /// Scenario 1 hit test using the same geometry as the painter (hit boxes
  /// from the HTML: pin r 1.8, safety-pin box 6.5 x 2.5, clip sphere r 2).
  List<String> _hits1(Offset sp) {
    final s = _scene;
    final out = <({String id, double d})>[];
    void pin(String id, _V3 p) {
      final w = _cam1.onPlane(sp, p.y + 0.45);
      if (w == null) return;
      if (math.sqrt(math.pow(w.x - p.x, 2) + math.pow(w.z - p.z, 2)) < 1.8) {
        out.add((id: id, d: _cam1.depth(p)));
      }
    }

    pin('pin1', s.pin1);
    pin('pin2', s.pin2);
    final o = s.safety + const _V3(0, 0.65, 0);
    final wo = _cam1.onPlane(sp, o.y);
    if (wo != null) {
      final ax = _V3(math.cos(s.safetyAngle), 0, -math.sin(s.safetyAngle));
      final az = ax.cross(_up);
      final lx = (wo - o).dot(ax);
      final lz = (wo - o).dot(az);
      if ((lx - 3).abs() < 3.25 && lz.abs() < 1.25) out.add((id: 'safety', d: _cam1.depth(o) - 1));
    }
    if (s.step >= 2) {
      for (final (id, c) in [('redClip', s.redClip), ('blackClip', s.blackClip)]) {
        final w = _cam1.onPlane(sp, c.y);
        if (w != null && w.dist(c) < 2.0) out.add((id: id, d: _cam1.depth(c) - 2));
      }
    }
    out.sort((a, b) => a.d.compareTo(b.d));
    return [for (final h in out) h.id];
  }

  /// Scenario 2 hit test (symbol hit planes 6x6 / 8x6, connection points).
  List<String> _hits2(Offset sp) {
    final s = _scene;
    final w = _w2(sp);
    final out = <String>[];
    if (s.showConnPoints && _connPoints.any((c) => (c - w).distance < 1.6)) out.add('conn_pt');
    bool inBox(Offset c, double hw, double hh) => (w.dx - c.dx).abs() < hw && (w.dy - c.dy).abs() < hh;
    if (inBox(s.cell, 3, 3)) out.add('symCell');
    if (s.lampPlaced ? inBox(s.lamp, 3, 4) : inBox(s.lamp, 4, 3)) out.add('symLamp');
    if (inBox(s.sw, 4, 3)) out.add('symSwitch');
    return out;
  }

  List<String> _hits(Offset sp) => _scene.scenario == 0 ? _hits1(sp) : _hits2(sp);

  /// First interactive object under the pointer; flashes the HUD red when
  /// only locked objects were touched (HTML `onPointerDown`).
  String? _pick(Offset sp) {
    final hits = _hits(sp);
    for (final id in hits) {
      if (_canInteract(id)) return id;
    }
    if (hits.isNotEmpty) _flashHud();
    return null;
  }

  void _flashHud() {
    _Audio.play(_Sound.wrong);
    setState(() => _hudFlash = true);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _hudFlash = false);
    });
  }

  // -------------------------------------------------------- gestures

  void _onTap(Offset sp) {
    if (_scene.dragging != null) return;
    final id = _pick(sp);
    if (id != null && _isClickable(id)) _handleClick(id);
  }

  void _onPanStart(Offset sp) {
    if (_scene.dragging != null) return;
    final id = _pick(sp);
    if (id == null) return;
    if (_isClickable(id)) {
      _handleClick(id);
      return;
    }
    final s = _scene;
    if (s.scenario == 0) {
      final pos = _pos3(id);
      _planeY = pos.y;
      _dragStart3 = pos;
      final w = _cam1.onPlane(sp, _planeY);
      _offset3 = w == null ? const _V3(0, 0, 0) : w - pos;
    } else {
      final pos = _pos2(id);
      _dragStart2 = pos;
      _offset2 = _w2(sp) - pos;
    }
    setState(() => s.dragging = id);
  }

  void _onPanUpdate(Offset sp) {
    final s = _scene;
    final id = s.dragging;
    if (id == null) return;
    if (s.scenario == 1) {
      _setPos2(id, _w2(sp) - _offset2);
      return;
    }
    final w = _cam1.onPlane(sp, _planeY);
    if (w == null) return;
    if (id == 'safety' && s.safetyPlaced) {
      // Rotate about pin 1; snaps closed within 0.35 rad of the contact pin.
      _settleStart = -1;
      final d = w - _pivot;
      var angle = math.atan2(-d.z, d.x);
      if (angle.abs() < 0.35) {
        angle = 0;
        if (!s.s1On) {
          s.s1On = true;
          _toggleCircuit(true);
        }
      } else if (s.s1On) {
        s.s1On = false;
        _toggleCircuit(false);
      }
      s.safetyAngle = angle;
      return;
    }
    final p = w - _offset3;
    if (id == 'redClip' || id == 'blackClip') {
      final c = p.withY(0.6);
      final target = id == 'redClip' ? _target1 : _target2;
      final dir = math.atan2(target.z - c.z, target.x - c.x);
      if (id == 'redClip') {
        s.redClip = c;
        s.redDir = dir;
      } else {
        s.blackClip = c;
        s.blackDir = dir;
      }
    } else {
      _setPos3(id, p.withY(0.5));
    }
  }

  /// HTML `onPointerUp`: snapping, validation and the drop error.
  void _onPanEnd() {
    final s = _scene;
    final id = s.dragging;
    if (id == null) return;
    var snapped = false;
    var rotatable = false;
    if (s.scenario == 0) {
      if (id == 'safety' && s.safetyPlaced) {
        rotatable = true;
        if (s.s1On && s.step == 3) {
          _checkStepCompletion();
        } else if (!s.s1On && s.step == 4) {
          _checkStepCompletion();
        }
      } else if (id == 'redClip') {
        if (s.redClip.dist(const _V3(-3, 0.5, 2)) < 4) {
          s.redClip = const _V3(-3.8, 0.6, 2);
          s.redDir = 0;
          s.redConnected = true;
          snapped = true;
          _Audio.play(_Sound.drop);
          _checkStepCompletion();
        }
      } else if (id == 'blackClip') {
        if (s.blackClip.dist(const _V3(3, 0.5, 2)) < 4) {
          s.blackClip = const _V3(3.8, 0.6, 2);
          s.blackDir = math.pi;
          s.blackConnected = true;
          snapped = true;
          _Audio.play(_Sound.drop);
          _checkStepCompletion();
        }
      } else {
        // Target zone 1 is for pin 1, then for the safety pin; zone 2 for pin 2.
        final zone = id == 'pin2' ? _target2 : _target1;
        final forThis = id == 'pin2' || (id == 'pin1' && !s.pin1Placed) || (id == 'safety' && s.pin1Placed);
        final pos = _pos3(id);
        if (forThis && pos.dist(zone) < 3.5) {
          snapped = true;
          _Audio.play(_Sound.drop);
          _setPos3(id, _V3(zone.x, 0.45, zone.z));
          if (id == 'pin1') s.pin1Placed = true;
          if (id == 'pin2') s.pin2Placed = true;
          if (id == 'safety') {
            s.safetyPlaced = true;
            s.safety = const _V3(-2.5, 0.65, 2);
            _settleStart = s.time;
          }
          _checkStepCompletion();
        }
      }
      if (!snapped && !rotatable) {
        final moved = _pos3(id).dist(_dragStart3) > 0.5;
        _setPos3(id, _dragStart3);
        if (moved) _lab.showToast(_t('drop_error'), isError: true);
      }
    } else {
      final zone = switch (id) {
        'symCell' => _cellTarget,
        'symLamp' => _lampTarget,
        _ => _switchTarget,
      };
      final pos = _pos2(id);
      // 3D distance in the HTML (object at y 0.5, zone at y 0.12).
      if (math.sqrt(math.pow((pos - zone).distance, 2) + 0.38 * 0.38) < 3.5) {
        snapped = true;
        _Audio.play(_Sound.drop);
        _setPos2(id, zone);
        if (id == 'symCell') s.cellPlaced = true;
        if (id == 'symLamp') s.lampPlaced = true;
        if (id == 'symSwitch') s.switchPlaced = true;
        _checkStepCompletion();
      } else {
        final moved = math.sqrt(math.pow((pos - _dragStart2).distance, 2) + 0.45 * 0.45) > 0.5;
        _setPos2(id, _dragStart2);
        if (moved) _lab.showToast(_t('drop_error'), isError: true);
      }
    }
    setState(() => s.dragging = null);
  }

  _V3 _pos3(String id) => switch (id) {
        'pin1' => _scene.pin1,
        'pin2' => _scene.pin2,
        'safety' => _scene.safety,
        'redClip' => _scene.redClip,
        _ => _scene.blackClip,
      };

  void _setPos3(String id, _V3 p) {
    switch (id) {
      case 'pin1':
        _scene.pin1 = p;
      case 'pin2':
        _scene.pin2 = p;
      case 'safety':
        _scene.safety = p;
      case 'redClip':
        _scene.redClip = p;
      case 'blackClip':
        _scene.blackClip = p;
    }
  }

  Offset _pos2(String id) => switch (id) {
        'symCell' => _scene.cell,
        'symLamp' => _scene.lamp,
        _ => _scene.sw,
      };

  void _setPos2(String id, Offset p) {
    switch (id) {
      case 'symCell':
        _scene.cell = p;
      case 'symLamp':
        _scene.lamp = p;
      case 'symSwitch':
        _scene.sw = p;
    }
  }

  /// HTML `handleObjectClick` (Scenario 2 switch symbol and connection points).
  void _handleClick(String id) {
    final s = _scene;
    if (id == 'symSwitch' && s.wiresConnected) {
      s.s2On = !s.s2On;
      _Audio.play(s.s2On ? _Sound.spark : _Sound.switchTap);
      if (s.step == 4 && s.s2On) {
        _checkStepCompletion();
      } else if (s.step == 5 && !s.s2On) {
        _checkStepCompletion();
      }
    }
    if (id == 'conn_pt' && s.step == 3) {
      s.wiresConnected = true;
      s.buildParticles(30);
      _checkStepCompletion();
    }
    setState(() {});
  }

  /// HTML `toggleCircuitState` (Scenario 1): bulb, spark and particle flow.
  void _toggleCircuit(bool on) {
    if (on) {
      _Audio.play(_Sound.spark);
      _scene.sparkUntil = _scene.time + 0.3;
    } else {
      _Audio.play(_Sound.switchTap);
    }
    setState(() {});
  }

  /// HTML `checkStepCompletion`.
  void _checkStepCompletion() {
    final s = _scene;
    if (s.step >= 6) return;
    final id = s.step + 1;
    final done = s.scenario == 0
        ? switch (id) {
            1 => s.pin1Placed && s.safetyPlaced,
            2 => s.pin2Placed,
            3 => s.redConnected && s.blackConnected,
            4 => s.s1On,
            5 => !s.s1On,
            _ => false,
          }
        : switch (id) {
            1 => s.cellPlaced,
            2 => s.lampPlaced,
            3 => s.switchPlaced,
            4 => s.wiresConnected,
            5 => s.s2On,
            _ => !s.s2On,
          };
    if (!done) return;
    _lab.showToast(_t('s${s.scenario + 1}_ok_$id'));
    if (s.scenario == 0 && id == 3) s.buildParticles(40);
    setState(() => s.step++);
    if (s.step == 6) _completeModule();
  }

  /// HTML `validateInvestigation` ("Observe Flow", Scenario 1 step 6).
  void _observeFlow() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 5) return;
    _settleStart = -1;
    s.safetyAngle = 0;
    _toggleCircuit(true);
    s.s1On = true;
    _lab.showToast(_t('s1_ok_6'));
    setState(() => s.step++);
    _completeModule();
  }

  /// HTML `triggerModuleCompletion`: observation popup after 1 s.
  void _completeModule() {
    final n = _scene.scenario + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      title: () => _t('observation'),
      heading: () => _t('obs_heading_$n'),
      body: () => _t('obs_body_$n'),
      delay: const Duration(milliseconds: 1000),
    );
  }

  List<LabAction> _actions() {
    if (_scene.scenario == 0 && _scene.step == 5) {
      return [
        LabAction(
          label: _t('observe_flow'),
          icon: Icons.visibility,
          highlight: true,
          silent: true, // plays the spark + success sounds itself
          onTap: _observeFlow,
        ),
      ];
    }
    return const [];
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
        final inset = labOverlayInsets(context, _lab);
        final scene = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.electrical_services,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step + 1,
          instruction: scene.complete ? _t('module_completed') : null,
          actions: _actions(),
          onReset: _fullReset,
          showHud: false,
          overlays: [_hud(p, s, inset)],
          stage: LabStage(
            designSize: _design,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                gestureSettings: const DeviceGestureSettings(touchSlop: 8),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Grab at the touch-down point (not where the slop was crossed).
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: (d) => _onTap(d.localPosition),
                onPanStart: (d) => _onPanStart(d.localPosition),
                onPanUpdate: (d) => _onPanUpdate(d.localPosition),
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: scene.scenario == 0
                      ? _Scene1Painter(
                          scene: scene,
                          repaint: _frame,
                          isDark: _lab.isDark,
                          showLabels: _lab.showLabels,
                          batteryLabel: _t('battery'),
                          lampLabel: _t('lamp'),
                        )
                      : _Scene2Painter(
                          scene: scene,
                          repaint: _frame,
                          isDark: _lab.isDark,
                          showLabels: _lab.showLabels,
                          libraryLabel: _t('symbol_library'),
                          cellLabel: _t('electric_cell'),
                          lampLabel: _t('lamp'),
                          switchLabel: _t('switch'),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML mini HUD (bottom centre): step number + `hudText`, a check mark
  /// and "Module Completed!" at the end; turns red for 1 s after touching a
  /// locked object. Always visible, like the HTML.
  Widget _hud(LabPalette p, double s, EdgeInsets inset) {
    final scene = _scene;
    final done = scene.complete;
    final id = scene.step + 1;
    final text = done ? _t('module_completed') : _t('s${scene.scenario + 1}_hud_$id');
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: inset.bottom,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560 * s),
            child: LabGlassCard(
              palette: p,
              radius: 16,
              padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
              borderColor: (_hudFlash ? _Colors.red : _Colors.zslYellow).withValues(alpha: 0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28 * s,
                    height: 28 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (done ? _Colors.green : _Colors.zslYellow).withValues(alpha: 0.2),
                    ),
                    child: done
                        ? Icon(Icons.check, size: 17 * s, color: _Colors.green)
                        : Text(
                            '$id',
                            style: TextStyle(
                              color: _Colors.zslYellow,
                              fontWeight: FontWeight.w800,
                              fontSize: 14 * s,
                            ),
                          ),
                  ),
                  SizedBox(width: 10 * s),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _hudFlash ? (p.isDark ? const Color(0xFFF87171) : _Colors.red) : p.textStrong,
                        fontWeight: FontWeight.w600,
                        fontSize: 12 * f,
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
    );
  }
}

// ============================================================ STRINGS
//
// Copied verbatim from `Cl7S-Ch3-A4-The_Electric_Switch.html` (EN + HI).
// Per-step HUD texts (`hudText`) and validation messages (`validateMsg`)
// live here as `s<scenario>_hud_<id>` / `s<scenario>_ok_<id>`.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Electric Switch',
    'app_subtitle': 'Class 7 • Electricity:Circuits and their Components',
    'scen_1': 'Scenario 1: Building a Simple Switch',
    'scen_2': 'Scenario 2: Using Circuit Diagram Symbols',
    'observation': 'Observation',
    'observe_flow': 'Observe Flow',
    'module_completed': 'Module Completed! You can continuously interact with the switch.',
    'drop_error': 'Drop it directly on the glowing target!',
    'obs_heading_1': 'Analysis & Outcomes',
    'obs_body_1':
        'The safety pin switch physically controls the gap in the circuit. Closing the switch connects the brass pins, completing the loop and allowing current to illuminate the lamp. Opening it breaks the path.',
    'obs_heading_2': 'Conclusion',
    'obs_body_2':
        "Standard symbols abstract real components to make schematic drawing universal. The circuit diagram behaves logically like the physical circuit. The switch symbol visually demonstrates the concept of 'making' or 'breaking' the connection.",
    // Canvas labels.
    'battery': 'Battery',
    'lamp': 'Lamp',
    'symbol_library': 'Symbol Library',
    'electric_cell': 'Electric Cell',
    'switch': 'Switch',
    // Scenario 1 HUD texts / validation messages.
    's1_hud_1': 'Drag the 1st pin to the left circle. Then drop the safety pin on it.',
    's1_hud_2': 'Drag the 2nd pin to the right circle.',
    's1_hud_3': 'Drag the red wire clip to the left pin, and the black clip to the right pin.',
    's1_hud_4': 'Rotate the safety pin to touch the right pin to close the circuit.',
    's1_hud_5': 'Rotate the safety pin away to break the circuit.',
    's1_hud_6': "Click 'Observe Flow'. You can continuously toggle the switch to see changes.",
    's1_ok_1': 'Pivot point constructed!',
    's1_ok_2': 'Contact point placed.',
    's1_ok_3': 'Wired correctly! Circuit is currently open.',
    's1_ok_4': 'Circuit Closed! The lamp glows.',
    's1_ok_5': 'Circuit Open! The lamp turns off.',
    's1_ok_6': 'Path of current visualized.',
    // Scenario 2 HUD texts / validation messages.
    's2_hud_1': 'Drag the Electric Cell symbol from the library to the left target.',
    's2_hud_2': 'Drag the Electric Lamp symbol to the right target.',
    's2_hud_3': 'Drag the OFF Switch symbol to the top middle target.',
    's2_hud_4': 'Click ANY of the blinking red connection points to draw the wires.',
    's2_hud_5': 'Click the switch symbol to close the circuit.',
    's2_hud_6': 'Click the switch symbol to open the circuit.',
    's2_ok_1': 'Cell symbol placed.',
    's2_ok_2': 'Lamp symbol placed.',
    's2_ok_3': 'Switch placed. Circuit is open.',
    's2_ok_4': 'Diagram wired!',
    's2_ok_5': 'Switch ON! Current flows.',
    's2_ok_6': 'Switch OFF! Simulation Complete.',
  },
  'hi': {
    'app_title': 'विद्युत स्विच',
    'app_subtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'scen_1': 'परिदृश्य 1: सरल स्विच बनाना',
    'scen_2': 'परिदृश्य 2: सर्किट आरेख प्रतीकों का उपयोग करना',
    'observation': 'अवलोकन',
    'observe_flow': 'प्रवाह देखें',
    'module_completed': 'मॉड्यूल पूरा हुआ! आप स्विच के साथ लगातार बातचीत कर सकते हैं।',
    'drop_error': 'इसे सीधे चमकते लक्ष्य पर छोड़ें!',
    'obs_heading_1': 'विश्लेषण और परिणाम',
    'obs_body_1':
        'सेफ्टी पिन स्विच सर्किट में गैप को भौतिक रूप से नियंत्रित करता है। स्विच बंद करने से पीतल के पिन जुड़ जाते हैं, लूप पूरा होता है और करंट लैंप को रोशन करने देता है। इसे खोलने से रास्ता टूट जाता है।',
    'obs_heading_2': 'निष्कर्ष',
    'obs_body_2':
        "मानक प्रतीक वास्तविक घटकों को सार करते हैं ताकि योजनाबद्ध आरेखण सार्वभौमिक हो सके। सर्किट आरेख भौतिक सर्किट की तरह तार्किक रूप से व्यवहार करता है। स्विच प्रतीक 'बनाने' या 'तोड़ने' की अवधारणा को प्रदर्शित करता है।",
    'battery': 'बैटरी',
    'lamp': 'लैंप',
    'symbol_library': 'प्रतीक पुस्तकालय',
    'electric_cell': 'विद्युत सेल',
    'switch': 'स्विच',
    's1_hud_1': 'पहले पिन को बाएं सर्कल में खींचें। फिर सेफ्टी पिन को उस पर छोड़ दें।',
    's1_hud_2': 'दूसरे पिन को दाएं सर्कल में खींचें।',
    's1_hud_3': 'लाल तार क्लिप को बाएं पिन पर, और काले क्लिप को दाएं पिन पर खींचें।',
    's1_hud_4': 'सर्किट को बंद करने के लिए सेफ्टी पिन को दाएं पिन से छूने के लिए घुमाएं।',
    's1_hud_5': 'सर्किट को तोड़ने के लिए सेफ्टी पिन को दूर घुमाएं।',
    's1_hud_6': "'प्रवाह देखें' पर क्लिक करें। परिवर्तन देखने के लिए आप स्विच को लगातार टॉगल कर सकते हैं।",
    's1_ok_1': 'धुरी बिंदु निर्मित!',
    's1_ok_2': 'संपर्क बिंदु रखा गया।',
    's1_ok_3': 'सही ढंग से तार! सर्किट अभी खुला है।',
    's1_ok_4': 'सर्किट बंद! लैंप चमकता है।',
    's1_ok_5': 'सर्किट खुला! लैंप बंद हो जाता है।',
    's1_ok_6': 'वर्तमान का पथ देखा गया।',
    's2_hud_1': 'इलेक्ट्रिक सेल प्रतीक को पुस्तकालय से बाएं लक्ष्य पर खींचें।',
    's2_hud_2': 'इलेक्ट्रिक लैंप प्रतीक को दाएं लक्ष्य पर खींचें।',
    's2_hud_3': 'बंद स्विच प्रतीक को शीर्ष मध्य लक्ष्य पर खींचें।',
    's2_hud_4': 'तार खींचने के लिए किसी भी टिमटिमाते लाल कनेक्शन बिंदु पर क्लिक करें।',
    's2_hud_5': 'सर्किट बंद करने के लिए स्विच प्रतीक पर क्लिक करें।',
    's2_hud_6': 'सर्किट खोलने के लिए स्विच प्रतीक पर क्लिक करें।',
    's2_ok_1': 'सेल प्रतीक रखा गया।',
    's2_ok_2': 'लैंप प्रतीक रखा गया।',
    's2_ok_3': 'स्विच रखा गया। सर्किट खुला है।',
    's2_ok_4': 'आरेख तार!',
    's2_ok_5': 'स्विच चालू! धारा बहती है।',
    's2_ok_6': 'स्विच बंद! सिमुलेशन पूर्ण।',
  },
};

/// Mission objective + steps. `concept` = step title, `action` = the task,
/// `observation` = the expected outcome (kept as data; the teacher accordion
/// with theory / outcomes is not shown, per the conversion rules).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To construct a functional switch using a safety pin and use it to control a lamp in a simple circuit.',
      steps: [
        LabStep(
          concept: 'Construct the Pivot',
          action:
              'DRAG the first drawing pin from the component tray and DROP it onto the marked circle on the left side of the cardboard. DRAG the safety pin and DROP its circular end over the drawing pin.',
          observation:
              'The drawing pin and safety pin are fixed onto the cardboard. The safety pin is now a movable object capable of rotating around the pin.',
        ),
        LabStep(
          concept: 'Place the Contact Point',
          action:
              'DRAG the second drawing pin from the tray and DROP it onto the marked circle on the right, positioned where the free end of the safety pin can touch it.',
          observation:
              'The second drawing pin is fixed to the cardboard, creating a contact point for the switch.',
        ),
        LabStep(
          concept: 'Wire the Components',
          action:
              "DRAG the red wire from the battery's positive terminal and CONNECT it to the first drawing pin. DRAG the black wire from the lamp and CONNECT it to the second drawing pin.",
          observation:
              'The switch is now wired into the circuit, but the circuit is still open. The lamp remains off.',
        ),
        LabStep(
          concept: 'Close the Circuit',
          action:
              'CLICK and DRAG the free end of the safety pin to ROTATE it until it touches the second drawing pin.',
          observation:
              'The safety pin touches the second drawing pin, closing the circuit, and the lamp glows.',
        ),
        LabStep(
          concept: 'Open the Circuit',
          action: 'CLICK and DRAG the safety pin away from the second drawing pin.',
          observation: 'The connection is broken, the circuit becomes open, and the lamp turns off.',
        ),
        LabStep(
          concept: 'Observe Flow Path',
          action:
              'The simulation will now highlight the path of the current. Observe the differences between the ON and OFF states.',
          observation:
              'The complete loop is visualized when ON, and the broken path is shown when OFF.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To build a circuit diagram using standard symbols and operate the symbolic switch to understand its function.',
      steps: [
        LabStep(
          concept: 'Place the Cell Symbol',
          action:
              "DRAG the symbol for the 'Electric Cell' from the symbol library and DROP it onto the workspace.",
          observation: 'The electric cell symbol is placed on the canvas.',
        ),
        LabStep(
          concept: 'Place the Lamp Symbol',
          action:
              "DRAG the symbol for the 'Electric Lamp' and DROP it onto the workspace, opposite the cell.",
          observation: 'The electric lamp symbol is placed on the canvas.',
        ),
        LabStep(
          concept: 'Place the Switch Symbol',
          action:
              "DRAG the symbol for the 'Switch in OFF position' and DROP it between the cell and the lamp.",
          observation:
              "The 'OFF' switch symbol is placed on the canvas, showing a clear break in the circuit path.",
        ),
        LabStep(
          concept: 'Connect the Diagram',
          action:
              "CLICK the blinking connection points on the symbols to automatically draw the 'Wires' and complete the circuit diagram.",
          observation:
              'Lines representing wires connect all the symbols, forming a complete circuit diagram with an open switch. The lamp symbol remains unlit.',
        ),
        LabStep(
          concept: 'Turn Switch ON',
          action: "CLICK on the 'Switch in OFF position' symbol.",
          observation:
              "The switch symbol changes to the 'ON' position, the lamp symbol glows, and current flow is visualized.",
        ),
        LabStep(
          concept: 'Turn Switch OFF',
          action: "CLICK on the 'Switch in ON position' symbol again.",
          observation:
              "The switch reverts to the 'OFF' position, the lamp stops glowing, and the current flow animation ceases.",
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'सेफ्टी पिन का उपयोग करके एक कार्यात्मक स्विच का निर्माण करना और एक साधारण सर्किट में लैंप को नियंत्रित करने के लिए इसका उपयोग करना।',
      steps: [
        LabStep(
          concept: 'धुरी का निर्माण करें',
          action:
              'घटक ट्रे से पहले ड्राइंग पिन को खींचें और कार्डबोर्ड के बाईं ओर चिह्नित सर्कल पर छोड़ दें। सेफ्टी पिन खींचें और उसके गोलाकार सिरे को ड्राइंग पिन के ऊपर छोड़ दें।',
          observation:
              'ड्राइंग पिन और सेफ्टी पिन कार्डबोर्ड पर तय हो गए हैं। सेफ्टी पिन अब पिन के चारों ओर घूमने में सक्षम एक चल वस्तु है।',
        ),
        LabStep(
          concept: 'संपर्क बिंदु रखें',
          action:
              'ट्रे से दूसरे ड्राइंग पिन को खींचें और दाईं ओर चिह्नित सर्कल पर छोड़ दें, जहां सेफ्टी पिन का मुक्त सिरा इसे छू सके।',
          observation:
              'दूसरा ड्राइंग पिन कार्डबोर्ड पर तय हो गया है, जिससे स्विच के लिए संपर्क बिंदु बन गया है।',
        ),
        LabStep(
          concept: 'घटकों को तार से जोड़ें',
          action:
              'लाल तार को बैटरी के सकारात्मक टर्मिनल से खींचें और पहले ड्राइंग पिन से कनेक्ट करें। काले तार को लैंप से खींचें और दूसरे ड्राइंग पिन से कनेक्ट करें।',
          observation: 'स्विच अब सर्किट में तार से जुड़ गया है, लेकिन सर्किट अभी भी खुला है। लैंप बंद रहता है।',
        ),
        LabStep(
          concept: 'सर्किट बंद करें',
          action: 'सेफ्टी पिन के मुक्त सिरे को क्लिक करें और खींचें ताकि यह दूसरे ड्राइंग पिन को छू सके।',
          observation: 'सेफ्टी पिन दूसरे ड्राइंग पिन को छूता है, सर्किट को बंद करता है, और लैंप चमकता है।',
        ),
        LabStep(
          concept: 'सर्किट खोलें',
          action: 'सेफ्टी पिन को दूसरे ड्राइंग पिन से दूर क्लिक करें और खींचें।',
          observation: 'कनेक्शन टूट गया है, सर्किट खुला हो गया है, और लैंप बंद हो गया है।',
        ),
        LabStep(
          concept: 'प्रवाह पथ देखें',
          action:
              'सिमुलेशन अब करंट के पथ को उजागर करेगा। चालू और बंद अवस्थाओं के बीच अंतर का निरीक्षण करें।',
          observation:
              'चालू होने पर पूर्ण लूप की कल्पना की जाती है, और बंद होने पर टूटा हुआ रास्ता दिखाया जाता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'मानक प्रतीकों का उपयोग करके एक सर्किट आरेख बनाने और इसके कार्य को समझने के लिए प्रतीकात्मक स्विच को संचालित करने के लिए।',
      steps: [
        LabStep(
          concept: 'सेल प्रतीक रखें',
          action: "प्रतीक पुस्तकालय से 'इलेक्ट्रिक सेल' के प्रतीक को खींचें और कार्यक्षेत्र पर छोड़ दें।",
          observation: 'इलेक्ट्रिक सेल का प्रतीक कैनवास पर रखा गया है।',
        ),
        LabStep(
          concept: 'लैंप प्रतीक रखें',
          action: "'इलेक्ट्रिक लैंप' के प्रतीक को खींचें और सेल के विपरीत कार्यक्षेत्र पर छोड़ दें।",
          observation: 'इलेक्ट्रिक लैंप प्रतीक कैनवास पर रखा गया है।',
        ),
        LabStep(
          concept: 'स्विच प्रतीक रखें',
          action: "'बंद स्थिति में स्विच' के प्रतीक को खींचें और सेल और लैंप के बीच छोड़ दें।",
          observation: "'बंद' स्विच प्रतीक कैनवास पर रखा गया है, जो सर्किट पथ में एक स्पष्ट ब्रेक दिखा रहा है।",
        ),
        LabStep(
          concept: 'आरेख कनेक्ट करें',
          action: 'तारों को खींचने और सर्किट आरेख को पूरा करने के लिए प्रतीकों पर टिमटिमाते कनेक्शन बिंदुओं पर क्लिक करें।',
          observation: 'तारों का प्रतिनिधित्व करने वाली रेखाएं सभी प्रतीकों को जोड़ती हैं। लैंप प्रतीक बुझा रहता है।',
        ),
        LabStep(
          concept: 'स्विच चालू करें',
          action: "'बंद स्थिति में स्विच' प्रतीक पर क्लिक करें।",
          observation: "स्विच प्रतीक 'चालू' स्थिति में बदल जाता है, लैंप चमकता है, और वर्तमान प्रवाह देखा जाता है।",
        ),
        LabStep(
          concept: 'स्विच बंद करें',
          action: "'चालू स्थिति में स्विच' प्रतीक पर फिर से क्लिक करें।",
          observation: "स्विच 'बंद' स्थिति में वापस आ जाता है, लैंप चमकना बंद कर देता है, और एनीमेशन बंद हो जाता है।",
        ),
      ],
    ),
  ],
};

// ======================================================== 3D HELPERS
//
// Scenario 1 is a perspective Three.js scene (camera at (0, 28, 22), FOV 35,
// looking at the origin). It is reproduced with a tiny pinhole camera that
// projects world points into the 1000x560 design space, so every object
// keeps the HTML position, size and colour. Scenario 2 is the HTML top-down
// view (camera straight above), drawn as a flat 2D board.

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

  double dist(_V3 o) => (this - o).length;
  _V3 withY(double v) => _V3(x, v, z);
}

const _V3 _up = _V3(0, 1, 0);

/// Directional light of the HTML scene: position (10, 25, 10).
final _V3 _light = const _V3(10, 25, 10).unit;

/// Pinhole camera (Three.js PerspectiveCamera + lookAt).
class _Cam {
  _Cam({
    required this.eye,
    required _V3 target,
    required double fovDeg,
    required this.principal,
    required double viewHeight,
  }) {
    f = (target - eye).unit;
    r = f.cross(_up).unit;
    u = r.cross(f);
    focal = (viewHeight / 2) / math.tan(fovDeg * math.pi / 360);
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

  /// Design pixels per world unit at [p].
  double scaleAt(_V3 p) => focal / depth(p);

  /// Intersects the view ray through design point [s] with the plane y = [planeY].
  _V3? onPlane(Offset s, double planeY) {
    final dir = (f + r * ((s.dx - principal.dx) / focal) + u * (-(s.dy - principal.dy) / focal)).unit;
    if (dir.y.abs() < 1e-6) return null;
    final t = (planeY - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// Scenario 1 camera (HTML `camera.position.set(0, 28, 22)`).
final _Cam _cam1 = _Cam(
  eye: const _V3(0, 28, 22),
  target: const _V3(0, 0, 0),
  fovDeg: 35,
  principal: const Offset(470, 272),
  viewHeight: 560,
);

/// Scenario 2 top-down mapping (HTML camera at (0, 35, 0)), framed so the
/// symbol library and the lamp target both stay on screen (the HTML view
/// cuts them off on narrow canvases).
const double _k2 = 17;
const double _cx2 = 4.6;
Offset _p2(double x, double z) => Offset(500 + (x - _cx2) * _k2, 280 + z * _k2);
Offset _w2(Offset design) => Offset((design.dx - 500) / _k2 + _cx2, (design.dy - 280) / _k2);

/// Three.js `CatmullRomCurve3` (centripetal) sampled like `getPoints(n)`.
List<_V3> _catmullRom(List<_V3> pts, int divisions) {
  _V3 point(double t) {
    final l = pts.length;
    final p = (l - 1) * t;
    var i = p.floor();
    var w = p - i;
    if (w == 0 && i == l - 1) {
      i = l - 2;
      w = 1;
    }
    final p0 = i > 0 ? pts[i - 1] : pts[0] + (pts[0] - pts[1]);
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = i + 2 < l ? pts[i + 2] : pts[l - 1] + (pts[l - 1] - pts[l - 2]);
    double d(_V3 a, _V3 b) => math.pow((a - b).dot(a - b), 0.25).toDouble();
    var dt0 = d(p0, p1), dt1 = d(p1, p2), dt2 = d(p2, p3);
    if (dt1 < 1e-4) dt1 = 1;
    if (dt0 < 1e-4) dt0 = dt1;
    if (dt2 < 1e-4) dt2 = dt1;
    double c(double x0, double x1, double x2, double x3) {
      var t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1;
      var t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2;
      t1 *= dt1;
      t2 *= dt1;
      final c2 = -3 * x1 + 3 * x2 - 2 * t1 - t2;
      final c3 = 2 * x1 - 2 * x2 + t1 + t2;
      return x1 + t1 * w + c2 * w * w + c3 * w * w * w;
    }

    return _V3(c(p0.x, p1.x, p2.x, p3.x), c(p0.y, p1.y, p2.y, p3.y), c(p0.z, p1.z, p2.z, p3.z));
  }

  return [for (var i = 0; i <= divisions; i++) point(i / divisions)];
}

/// Three.js `QuadraticBezierCurve3` sampled into [n] segments.
List<_V3> _bezier(_V3 a, _V3 m, _V3 b, int n) => [
      for (var i = 0; i <= n; i++)
        a * ((1 - i / n) * (1 - i / n)) + m * (2 * (1 - i / n) * (i / n)) + b * ((i / n) * (i / n)),
    ];

/// Point at [progress] (0..1) along a sampled path, like the HTML particle
/// update (lerp between neighbouring samples).
_V3 _alongPath(List<_V3> path, double progress) {
  final f = progress * (path.length - 1);
  final i1 = f.floor().clamp(0, path.length - 1);
  final i2 = math.min(i1 + 1, path.length - 1);
  final t = f - i1;
  return path[i1] + (path[i2] - path[i1]) * t;
}

// ------------------------------------------------------------ geometry data

// Scenario 1 (world units, from `buildScenario1Objects`).
const _V3 _pin1Home = _V3(9.2, 0.4, -4.5);
const _V3 _pin2Home = _V3(9.2, 0.4, -3.5);
const _V3 _safetyHome = _V3(6.6, 0.6, -4);
const _V3 _redHome = _V3(-8.5, 0.6, 4);
const _V3 _blackHome = _V3(8.5, 0.6, 4);
const _V3 _batteryPos = _V3(-12, 0, 1);
const _V3 _lampPos = _V3(12, 0, 1);
const _V3 _pivot = _V3(-2.5, 0, 2);
const _V3 _target1 = _V3(-3, 0.12, 2);
const _V3 _target2 = _V3(3, 0.12, 2);
const _V3 _clipTarget1 = _V3(-4, 0.12, 2);
const _V3 _clipTarget2 = _V3(4, 0.12, 2);
const _V3 _batteryPlus = _V3(-12, 6.7, 1);
const _V3 _lampWireStart = _V3(10.5, 0.5, -0.5);
const _V3 _sparkPos = _V3(3, 0.8, 2);

/// Angle the placed safety pin opens to (radians). The HTML leaves it at 0,
/// which looks closed while the circuit is logically open.
const double _safetyOpenAngle = 0.6;

final List<_V3> _permWire = _catmullRom(const [
  _V3(-12, 0.2, 2.8),
  _V3(-10, 0.1, 7),
  _V3(10, 0.1, 7),
  _V3(12, 0.2, 3.2),
], 64);

final List<_V3> _flowPath1 = _catmullRom(const [
  _V3(-12, 6.7, 1),
  _V3(-7, 2, 2),
  _V3(-3, 0.6, 2),
  _V3(3, 0.6, 2),
  _V3(7, 1, 1),
  _V3(10.5, 0.5, -0.5),
  _V3(12, 0.2, 3.2),
  _V3(10, 0.1, 7),
  _V3(-10, 0.1, 7),
  _V3(-12, 0.2, 2.8),
], 120);

// Scenario 2 (x, z on the board).
const Offset _cellHome = Offset(-18, -8);
const Offset _lampHome = Offset(-18, 1);
const Offset _switchHome = Offset(-18, 10);
const Offset _cellTarget = Offset(-4, 0);
const Offset _lampTarget = Offset(20, 0);
const Offset _switchTarget = Offset(8, -10);
const List<Offset> _connPoints = [
  Offset(-4, -2.5),
  Offset(-4, 2.5),
  Offset(20, -2.5),
  Offset(20, 2.5),
  Offset(4, -10),
  Offset(12, -10),
];
const List<List<Offset>> _s2Wires = [
  [Offset(-4, -2.5), Offset(-4, -10), Offset(4, -10)],
  [Offset(12, -10), Offset(20, -10), Offset(20, -2.5)],
  [Offset(20, 2.5), Offset(20, 10), Offset(-4, 10), Offset(-4, 2.5)],
];

/// Scenario 2 flow path. The HTML samples a Catmull-Rom curve, which
/// overshoots the square wire corners; the particles follow the drawn wires
/// exactly here (evenly spaced polyline samples).
final List<_V3> _flowPath2 = _polyline(const [
  _V3(-4, 0.1, -2.5),
  _V3(-4, 0.1, -10),
  _V3(4, 0.1, -10),
  _V3(12, 0.1, -10),
  _V3(20, 0.1, -10),
  _V3(20, 0.1, -2.5),
  _V3(20, 0.1, 2.5),
  _V3(20, 0.1, 10),
  _V3(-4, 0.1, 10),
  _V3(-4, 0.1, 2.5),
], 160);

/// Evenly spaced samples along a straight-segment polyline.
List<_V3> _polyline(List<_V3> pts, int n) {
  final lens = [for (var i = 1; i < pts.length; i++) pts[i].dist(pts[i - 1])];
  final total = lens.fold(0.0, (a, b) => a + b);
  final out = <_V3>[];
  for (var k = 0; k <= n; k++) {
    var d = total * k / n;
    var i = 0;
    while (i < lens.length - 1 && d > lens[i]) {
      d -= lens[i];
      i++;
    }
    out.add(pts[i] + (pts[i + 1] - pts[i]) * (d / lens[i]).clamp(0.0, 1.0));
  }
  return out;
}

// ============================================================ SCENE MODEL

/// Mutable scene state read by the painters every frame (the HTML
/// `zslState` flags + Three.js object transforms).
class _SwitchScene {
  int scenario = 0;

  /// 0-based step like the HTML (`steps.length` = module complete).
  int step = 0;
  double time = 0;

  /// Id of the object being dragged ('pin1', 'safety', 'redClip', 'symCell'...).
  String? dragging;

  // ----- Scenario 1 -----
  _V3 pin1 = _pin1Home;
  _V3 pin2 = _pin2Home;
  _V3 safety = _safetyHome;
  double safetyAngle = 0;
  _V3 redClip = _redHome;
  _V3 blackClip = _blackHome;

  /// Direction the clip jaws point to (angle in the x/z plane).
  double redDir = 3 * math.pi / 4;
  double blackDir = math.pi / 4;
  bool pin1Placed = false;
  bool safetyPlaced = false;
  bool pin2Placed = false;
  bool redConnected = false;
  bool blackConnected = false;
  bool s1On = false;
  double sparkUntil = -1;

  // ----- Scenario 2 -----
  Offset cell = _cellHome;
  Offset lamp = _lampHome;
  Offset sw = _switchHome;
  bool cellPlaced = false;
  bool lampPlaced = false;
  bool switchPlaced = false;
  bool wiresConnected = false;
  bool s2On = false;

  /// 0 = OFF lever, 1 = ON lever (eased towards the switch state).
  double lever = 0;

  /// Current-flow particles (progress 0..1 along the flow path); empty until
  /// the flow is built (HTML `buildParticleFlow` / `drawS2Wires`).
  final List<double> particles = [];

  bool get isOn => scenario == 0 ? s1On : s2On;
  bool get complete => step >= 6;

  void reset(int scen) {
    scenario = scen;
    step = 0;
    dragging = null;
    pin1 = _pin1Home;
    pin2 = _pin2Home;
    safety = _safetyHome;
    safetyAngle = 0;
    redClip = _redHome;
    blackClip = _blackHome;
    redDir = 3 * math.pi / 4;
    blackDir = math.pi / 4;
    pin1Placed = safetyPlaced = pin2Placed = false;
    redConnected = blackConnected = s1On = false;
    sparkUntil = -1;
    cell = _cellHome;
    lamp = _lampHome;
    sw = _switchHome;
    cellPlaced = lampPlaced = switchPlaced = wiresConnected = s2On = false;
    lever = 0;
    particles.clear();
  }

  void buildParticles(int count) {
    particles
      ..clear()
      ..addAll([for (var i = 0; i < count; i++) i / count]);
  }

  // Visibility rules from the HTML `updateUI()`.
  bool get showTarget1 => scenario == 0 && step == 0 && (!pin1Placed || !safetyPlaced);
  bool get showTarget2 => scenario == 0 && step == 1 && !pin2Placed;
  bool get showClipTarget1 => scenario == 0 && step == 2 && !redConnected;
  bool get showClipTarget2 => scenario == 0 && step == 2 && !blackConnected;
  bool get showWires => scenario == 0 && step >= 2;
  bool get showCellTarget => scenario == 1 && step == 0 && !cellPlaced;
  bool get showLampTarget => scenario == 1 && step == 1 && !lampPlaced;
  bool get showSwitchTarget => scenario == 1 && step == 2 && !switchPlaced;
  bool get showConnPoints => scenario == 1 && step == 3;
}

// ======================================================== DRAW HELPERS

/// Lambert-ish shading factor for a face normal (ambient 0.9 + directional
/// 0.4 in the HTML, normalised so the top face is ~1).
double _shadeK(_V3 n) => 0.62 + 0.42 * math.max(0, n.dot(_light));

Color _lit(Color c, double k) => k >= 1
    ? Color.lerp(c, Colors.white, (k - 1).clamp(0.0, 1.0))!
    : Color.lerp(c, Colors.black, (1 - k).clamp(0.0, 1.0))!;

Color _a(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

/// Oriented box (Three.js BoxGeometry). [ax] is the box's local x axis in
/// the x/z plane; local z = ax × up (same handedness as Three.js).
void _box(
  Canvas canvas,
  _Cam cam,
  _V3 c,
  _V3 half,
  Color color, {
  _V3 ax = const _V3(1, 0, 0),
  double opacity = 1,
  bool edges = true,
  double spec = 0,
}) {
  final az = ax.cross(_up);
  final axes = [ax, _up, az];
  final h = [half.x, half.y, half.z];
  final faces = <({double depth, List<Offset> pts, Color col})>[];
  for (var a = 0; a < 3; a++) {
    for (final sgn in const [-1.0, 1.0]) {
      final n = axes[a] * sgn;
      final fc = c + n * h[a];
      if (n.dot(cam.eye - fc) <= 0) continue;
      final o1 = axes[(a + 1) % 3] * h[(a + 1) % 3];
      final o2 = axes[(a + 2) % 3] * h[(a + 2) % 3];
      final pts = [
        cam.project(fc + o1 + o2),
        cam.project(fc + o1 - o2),
        cam.project(fc - o1 - o2),
        cam.project(fc - o1 + o2),
      ];
      var col = _lit(color, _shadeK(n));
      if (spec > 0) {
        final hv = (_light + (cam.eye - fc).unit).unit;
        col = Color.lerp(col, Colors.white, spec * math.pow(math.max(0, n.dot(hv)), 16).toDouble())!;
      }
      faces.add((depth: cam.depth(fc), pts: pts, col: col));
    }
  }
  faces.sort((p, q) => q.depth.compareTo(p.depth));
  for (final f in faces) {
    final path = _poly(f.pts);
    canvas.drawPath(path, Paint()..color = _a(f.col, opacity));
    if (edges) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..strokeJoin = StrokeJoin.round
          ..color = _a(labShade(color, -0.45), 0.45 * opacity),
      );
    }
  }
}

/// Upright cylinder from [base] (bottom centre) with radius [r] and height [h],
/// shaded per facet (CylinderGeometry with MeshStandardMaterial look).
void _cylinder(
  Canvas canvas,
  _Cam cam,
  _V3 base,
  double r,
  double h,
  Color color, {
  double opacity = 1,
  double spec = 0.25,
  bool top = true,
  int seg = 40,
}) {
  final step = 2 * math.pi / seg;
  for (var i = 0; i < seg; i++) {
    final a0 = i * step - step * 0.18;
    final a1 = (i + 1) * step + step * 0.18;
    final am = (i + 0.5) * step;
    final n = _V3(math.cos(am), 0, math.sin(am));
    final pm = base + n * r + _V3(0, h / 2, 0);
    if (n.dot(cam.eye - pm) <= 0) continue;
    final b0 = base + _V3(math.cos(a0) * r, 0, math.sin(a0) * r);
    final b1 = base + _V3(math.cos(a1) * r, 0, math.sin(a1) * r);
    final t0 = b0.withY(base.y + h);
    final t1 = b1.withY(base.y + h);
    final hv = (_light + (cam.eye - pm).unit).unit;
    final s = spec * math.pow(math.max(0, n.dot(hv)), 18).toDouble();
    final col = Color.lerp(_lit(color, 0.5 + 0.55 * math.max(0, n.dot(_light)) + 0.12), Colors.white, s)!;
    canvas.drawPath(
      _poly([cam.project(b0), cam.project(b1), cam.project(t1), cam.project(t0)]),
      Paint()..color = _a(col, opacity),
    );
  }
  if (top) {
    final pts = [
      for (var i = 0; i < seg; i++)
        cam.project(base + _V3(math.cos(i * step) * r, h, math.sin(i * step) * r)),
    ];
    canvas.drawPath(_poly(pts), Paint()..color = _a(_lit(color, _shadeK(_up) + 0.04), opacity));
  }
}

/// Projected horizontal circle (ellipse on screen) at height [y].
List<Offset> _ring(_Cam cam, _V3 c, double r, {int seg = 48}) => [
      for (var i = 0; i < seg; i++)
        cam.project(c + _V3(math.cos(i * 2 * math.pi / seg) * r, 0, math.sin(i * 2 * math.pi / seg) * r)),
    ];

/// Tube along [pts] (TubeGeometry): outline, body and a specular streak.
void _tube(Canvas canvas, _Cam cam, List<_V3> pts, double radius, Color color, {double opacity = 1}) {
  if (pts.length < 2) return;
  final w = 2 * radius * cam.scaleAt(pts[pts.length ~/ 2]);
  final path = Path();
  final first = cam.project(pts.first);
  path.moveTo(first.dx, first.dy);
  for (var i = 1; i < pts.length; i++) {
    final p = cam.project(pts[i]);
    path.lineTo(p.dx, p.dy);
  }
  Paint stroke(double width, Color c) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = _a(c, opacity);
  canvas.drawPath(path, stroke(w + 1.4, labShade(color, -0.5)));
  canvas.drawPath(path, stroke(w, color));
  canvas.drawPath(path.shift(Offset(0, -w * 0.18)), stroke(w * 0.28, labShade(color, 0.45).withValues(alpha: 0.7)));
}

/// Soft cast shadow of a vertical object (light from +x, +y, +z).
void _castShadow(Canvas canvas, _Cam cam, _V3 base, double r, double h, {double opacity = 0.28}) {
  final tip = base + _V3(-_light.x / _light.y * h, 0, -_light.z / _light.y * h);
  final a = cam.project(base);
  final b = cam.project(tip);
  final w = 2 * r * cam.scaleAt(base);
  canvas.drawLine(
    a,
    b,
    Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.18 + 2),
  );
}

/// HTML `.canvas-label`: white chip (light theme) / slate chip (dark theme).
void _canvasLabel(Canvas canvas, String text, Offset at, bool isDark, {double size = 19}) {
  labText(
    canvas,
    text,
    at,
    size: size,
    weight: FontWeight.w700,
    color: isDark ? Colors.white : Colors.black,
    background: isDark ? const Color(0xF21E293B) : const Color(0xF2FFFFFF),
    border: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
    borderWidth: 1,
    radius: 6,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  );
}

/// The comic spark texture (three 16-point stars: orange, yellow, white).
void _spark(Canvas canvas, Offset c, double radius, double rot, double opacity) {
  void star(Color col, double outer, double inner, double phase) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final rr = (i.isEven ? outer : inner) / 128 * radius;
      final a = i * math.pi / 8 + phase + rot;
      final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _a(col, opacity));
  }

  labGlow(canvas, c, radius * 1.2, const Color(0xFFFDE047), intensity: 0.8 * opacity);
  star(const Color(0xFFF97316), 110, 40, 0);
  star(const Color(0xFFEAB308), 80, 25, 0.1);
  star(Colors.white, 40, 15, 0.2);
}

/// Pulsing blue drop-target ring (HTML `createTargetZone`, opacity 0.3,
/// scale 1 ± 0.05) drawn with a soft glow so it reads as "glowing".
void _targetRing(Canvas canvas, List<Offset> ring, double t, {double pulse = 0.05}) {
  final c = ring.fold(Offset.zero, (s, p) => s + p) / ring.length.toDouble();
  final k = 1 + math.sin(t * 5) * pulse;
  final pts = [for (final p in ring) c + (p - c) * k];
  final path = _poly(pts);
  const blue = Color(0xFF3B82F6);
  canvas.drawPath(path, Paint()..color = blue.withValues(alpha: 0.14 + 0.06 * math.sin(t * 5)));
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = blue.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = blue.withValues(alpha: 0.85),
  );
}

// ================================================== SCENARIO 1 PAINTER

const Color _wood = Color(0xFFDEB887);
const Color _cardboard = Color(0xFFD2B48C);
const Color _trayCol = Color(0xFFA3B8CC);
const Color _indentCol = Color(0xFF8295A8);
const Color _brass = Color(0xFFD4AF37);
const Color _metal = Color(0xFFB9C0C8);
const Color _batBlack = Color(0xFF111111);
const Color _batOrange = Color(0xFFEA580C);
const Color _batSilver = Color(0xFFE0E0E0);
const Color _wireRed = Color(0xFFE11D48);
const Color _wireBlack = Color(0xFF111111);
const Color _glowYellow = Color(0xFFFFE600);

/// Height of the surface under (x, z): cardboard 0.2, tray 0.4, table 0.
double _groundAt(double x, double z) {
  if (x >= -5.5 && x <= 5.5 && z >= -1.5 && z <= 5.5) return 0.2;
  if (x >= 5 && x <= 11 && z >= -6.25 && z <= -1.75) return 0.4;
  return 0;
}

class _Scene1Painter extends CustomPainter {
  _Scene1Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.batteryLabel,
    required this.lampLabel,
  }) : super(repaint: repaint);

  final _SwitchScene scene;
  final bool isDark;
  final bool showLabels;
  final String batteryLabel;
  final String lampLabel;

  _Cam get cam => _cam1;

  @override
  void paint(Canvas canvas, Size size) {
    final t = scene.time;
    _paintRoom(canvas, size);
    if (scene.s1On) {
      // Point light (0xffffaa) at the bulb lighting the table.
      final c = cam.project(_lampPos.withY(0));
      canvas.drawCircle(
        c,
        420,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFFFAA).withValues(alpha: 0.42),
            const Color(0xFFFFFFAA).withValues(alpha: 0.12),
            const Color(0x00FFFFAA),
          ], stops: const [0, 0.45, 1]).createShader(Rect.fromCircle(center: c, radius: 420)),
      );
    }

    // Permanent black wire (lamp -> battery, along the front of the table).
    _tube(canvas, cam, _permWire, 0.15, _wireBlack);

    // Cardboard base and component tray.
    _castShadowBox(canvas, const _V3(0, 0, 2), 5.5, 3.5, 0.2);
    _box(canvas, cam, const _V3(0, 0.1, 2), const _V3(5.5, 0.1, 3.5), _cardboard);
    _cardboardTexture(canvas);
    _castShadowBox(canvas, const _V3(8, 0, -4), 3, 2.25, 0.4);
    _box(canvas, cam, const _V3(8, 0.2, -4), const _V3(3, 0.2, 2.25), _trayCol, spec: 0.2);
    _indent(canvas, 8.15, 10.65, -5.75, -2.25);
    _indent(canvas, 5.35, 7.85, -5.75, -4.25);
    _indent(canvas, 5.35, 7.85, -3.75, -2.25);

    // Glowing drop targets.
    if (scene.showTarget1) _targetRing(canvas, _ring(cam, _target1.withY(0.21), 0.8), t);
    if (scene.showTarget2) _targetRing(canvas, _ring(cam, _target2.withY(0.21), 0.8), t);
    if (scene.showClipTarget1) _targetRing(canvas, _ring(cam, _clipTarget1.withY(0.21), 1.5), t);
    if (scene.showClipTarget2) _targetRing(canvas, _ring(cam, _clipTarget2.withY(0.21), 1.5), t);

    // Objects, back to front (sorted by world z; the dragged one last).
    final items = <({double key, void Function() draw})>[
      (key: 1.0, draw: () => _battery(canvas)),
      (key: 1.01, draw: () => _lamp(canvas, t)),
      (key: _key('pin1', scene.pin1.z), draw: () => _pin(canvas, scene.pin1)),
      (key: _key('pin2', scene.pin2.z), draw: () => _pin(canvas, scene.pin2)),
      (key: _key('safety', scene.safety.z + 0.6), draw: () => _safetyPin(canvas)),
      (key: _key('redClip', scene.redClip.z + 0.05), draw: () => _clip(canvas, scene.redClip, scene.redDir, _wireRed)),
      (
        key: _key('blackClip', scene.blackClip.z + 0.05),
        draw: () => _clip(canvas, scene.blackClip, scene.blackDir, _wireBlack),
      ),
      if (scene.showWires) (key: 0.99, draw: () => _blackWire(canvas)),
      if (scene.showWires) (key: 1.005, draw: () => _redWire(canvas)),
    ]..sort((a, b) => a.key.compareTo(b.key));
    for (final it in items) {
      it.draw();
    }

    // Current flow (yellow particles) while the switch is closed.
    if (scene.s1On && scene.particles.isNotEmpty) {
      for (final p in scene.particles) {
        final w = _alongPath(_flowPath1, p);
        final c = cam.project(w);
        final r = 0.25 * cam.scaleAt(w);
        labGlow(canvas, c, r * 3, _glowYellow, intensity: 0.5);
        labSphere(canvas, c, r, _glowYellow, highlight: 0.6, shade: 0.25);
      }
    }

    // Spark at the contact point for 300 ms after closing the circuit.
    if (t < scene.sparkUntil) {
      final c = cam.project(_sparkPos);
      _spark(canvas, c, 2.625 * cam.scaleAt(_sparkPos), t * 18, 1);
    }

    if (showLabels) {
      _canvasLabel(canvas, batteryLabel, cam.project(_batteryPos + const _V3(0, 7.5, 0)), isDark);
      _canvasLabel(canvas, lampLabel, cam.project(_lampPos + const _V3(0, 5, 0)), isDark);
    }
  }

  double _key(String id, double z) => scene.dragging == id ? 1000 : z;

  void _paintRoom(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    // Cream background (scene.background 0xfff8cc).
    canvas.drawRect(bleed, Paint()..color = const Color(0xFFFFF8CC));
    // Wooden table (top at y = 0). The HTML table is 60 x 40; it is widened
    // here so its side edges never show in the letterbox area.
    final top = [
      cam.project(const _V3(-70, 0, -20)),
      cam.project(const _V3(70, 0, -20)),
      cam.project(const _V3(70, 0, 20)),
      cam.project(const _V3(-70, 0, 20)),
    ];
    final front = [
      top[3],
      top[2],
      cam.project(const _V3(70, -1, 20)),
      cam.project(const _V3(-70, -1, 20)),
    ];
    canvas.drawPath(_poly(front), Paint()..color = _lit(_wood, _shadeK(const _V3(0, 0, 1))));
    final topPath = _poly(top);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_wood, -0.06), labShade(_wood, 0.04), labShade(_wood, -0.04)],
        ).createShader(Rect.fromLTRB(0, top[0].dy, size.width, size.height)),
    );
    // Wood grain.
    canvas.save();
    canvas.clipPath(topPath);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF8B5A2B).withValues(alpha: 0.10);
    for (var i = 0; i < 44; i++) {
      final z0 = -20 + i * 0.92;
      final path = Path();
      for (var x = -70.0; x <= 70; x += 1.5) {
        final p = cam.project(_V3(x, 0, z0 + 0.18 * math.sin(x * 0.27 + i * 1.7) + 0.08 * math.sin(x * 0.9 + i)));
        x == -70 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, grain);
    }
    canvas.restore();
    // Table edge highlight.
    canvas.drawLine(
      top[0],
      top[1],
      Paint()
        ..strokeWidth = 2
        ..color = labShade(_wood, 0.3),
    );
  }

  void _castShadowBox(Canvas canvas, _V3 c, double hx, double hz, double h) {
    final off = _V3(-_light.x / _light.y * h, 0, -_light.z / _light.y * h);
    final pts = [
      cam.project(c + _V3(-hx, 0, -hz) + off),
      cam.project(c + _V3(hx, 0, -hz) + off),
      cam.project(c + _V3(hx, 0, hz)),
      cam.project(c + _V3(-hx, 0, hz)),
    ];
    canvas.drawPath(
      _poly(pts),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _cardboardTexture(Canvas canvas) {
    // Faint corrugation lines on the cardboard top.
    final p = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF8B6B3E).withValues(alpha: 0.12);
    for (var x = -5.0; x <= 5.0; x += 0.7) {
      canvas.drawLine(cam.project(_V3(x, 0.2, -1.4)), cam.project(_V3(x, 0.2, 5.4)), p);
    }
  }

  void _indent(Canvas canvas, double x0, double x1, double z0, double z1) {
    const y = 0.405;
    final pts = [
      cam.project(_V3(x0, y, z0)),
      cam.project(_V3(x1, y, z0)),
      cam.project(_V3(x1, y, z1)),
      cam.project(_V3(x0, y, z1)),
    ];
    canvas.drawPath(_poly(pts), Paint()..color = _indentCol);
    // Inner shadow along the far and left walls of the recess.
    canvas.drawLine(
      pts[0],
      pts[1],
      Paint()
        ..strokeWidth = 2.5
        ..color = labShade(_indentCol, -0.35),
    );
    canvas.drawLine(
      pts[0],
      pts[3],
      Paint()
        ..strokeWidth = 1.5
        ..color = labShade(_indentCol, -0.25),
    );
  }

  /// Dual-shade D-cell battery (silver rims, black lower body, orange top).
  void _battery(Canvas canvas) {
    const b = _batteryPos;
    _castShadow(canvas, cam, b, 1.8, 6.7);
    _cylinder(canvas, cam, b, 1.81, 0.3, _batSilver, spec: 0.6);
    _cylinder(canvas, cam, b + const _V3(0, 0.3, 0), 1.8, 3, _batBlack, spec: 0.25);
    _cylinder(canvas, cam, b + const _V3(0, 3.3, 0), 1.8, 2.7, _batOrange, spec: 0.35);
    _cylinder(canvas, cam, b + const _V3(0, 6.0, 0), 1.81, 0.3, _batSilver, spec: 0.6);
    _cylinder(canvas, cam, b + const _V3(0, 6.2, 0), 0.6, 0.5, _batSilver, spec: 0.7);
    // "+" and "-" marks on the front (planes at z = +1.82).
    void quad(double cx, double cy, double hw, double hh) {
      canvas.drawPath(
        _poly([
          cam.project(_V3(b.x + cx - hw, cy - hh, b.z + 1.82)),
          cam.project(_V3(b.x + cx + hw, cy - hh, b.z + 1.82)),
          cam.project(_V3(b.x + cx + hw, cy + hh, b.z + 1.82)),
          cam.project(_V3(b.x + cx - hw, cy + hh, b.z + 1.82)),
        ]),
        Paint()..color = Colors.white,
      );
    }

    quad(0, 5, 0.4, 0.1);
    quad(0, 5, 0.1, 0.4);
    quad(0, 1.5, 0.4, 0.1);
  }

  /// Lamp: black base, metal holder, filament and the glass bulb.
  void _lamp(Canvas canvas, double t) {
    const l = _lampPos;
    final on = scene.s1On;
    _castShadow(canvas, cam, l, 2.0, 4.4, opacity: on ? 0.12 : 0.26);
    _cylinder(canvas, cam, l, 2.2, 0.5, _batBlack, spec: 0.3);
    _cylinder(canvas, cam, l + const _V3(0, 0.5, 0), 1.2, 1.2, _metal, spec: 0.7);
    _cylinder(canvas, cam, l + const _V3(0, 2.0, 0), 0.1, 0.8, on ? const Color(0xFFFFF7B0) : _metal, spec: 0.5);
    const bc = _V3(12, 2.8, 1);
    final c = cam.project(bc);
    final r = 1.6 * cam.scaleAt(bc);
    if (on) {
      final flick = 1 + 0.03 * math.sin(t * 23);
      labGlow(canvas, c, r * 4.2 * flick, const Color(0xFFFFFFAA), intensity: 0.85);
      labGlow(canvas, c, r * 2.2, _glowYellow, intensity: 1);
      labSphere(canvas, c, r, _glowYellow, highlight: 0.7, shade: 0.12, opacity: 0.95);
      canvas.drawCircle(c, r * 0.45, Paint()..color = Colors.white.withValues(alpha: 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25));
    } else {
      labSphere(canvas, c, r, const Color(0xFFAAAAAA), opacity: 0.32, highlight: 0.6, shade: 0.3);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: 0.45),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(-r * 0.38, -r * 0.42), width: r * 0.5, height: r * 0.32),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  /// Brass drawing pin (flat head + dome + sharp stem).
  void _pin(Canvas canvas, _V3 p) {
    final g = _groundAt(p.x, p.z);
    final lifted = p.y - g > 0.3;
    labGroundShadow(
      canvas,
      cam.project(_V3(p.x - (p.y - g) * 0.4, g, p.z - (p.y - g) * 0.4)),
      2.0 * cam.scaleAt(p),
      1.4 * cam.scaleAt(p),
      opacity: lifted ? 0.22 : 0.32,
    );
    // Stem (cone pointing down).
    canvas.drawPath(
      _poly([
        cam.project(_V3(p.x - 0.1, p.y + 0.4, p.z)),
        cam.project(_V3(p.x + 0.1, p.y + 0.4, p.z)),
        cam.project(_V3(p.x, p.y, p.z)),
      ]),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    _cylinder(canvas, cam, p + const _V3(0, 0.375, 0), 0.9, 0.15, _brass, spec: 0.8, seg: 32);
    // Dome highlight on the head.
    final top = p + const _V3(0, 0.53, 0);
    final c = cam.project(top);
    final s = cam.scaleAt(top);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 1.5 * s, height: 1.15 * s),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [const Color(0xFFFFF3B0), _brass.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCenter(center: c, width: 1.5 * s, height: 1.15 * s)),
    );
  }

  /// Steel safety pin: coil loop, two arms and the clasp head. Rotates about
  /// the loop (rotation.y in the HTML).
  void _safetyPin(Canvas canvas) {
    final a = scene.safetyAngle;
    final ax = _V3(math.cos(a), 0, -math.sin(a));
    final az = ax.cross(_up);
    final o = scene.safety + const _V3(0, 0.65, 0);
    _V3 l(double lx, double lz) => o + ax * lx + az * lz;
    final g = _groundAt(o.x, o.z);
    final h = o.y - g;
    final off = _V3(-_light.x / _light.y * h, 0, -_light.z / _light.y * h);
    final shadow = Paint()
      ..strokeWidth = 0.5 * cam.scaleAt(o)
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(cam.project(l(0, 0).withY(g) + off), cam.project(l(5.9, 0.2).withY(g) + off), shadow);

    _tube(canvas, cam, [l(0, -0.3), l(5.8, -0.3)], 0.08, _metal);
    _tube(canvas, cam, [l(-0.085, 0), l(5.885, 0.6)], 0.08, _metal);
    // Coil loop (torus r = 0.3).
    canvas.drawPath(
      _poly(_ring(cam, o, 0.3, seg: 24)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.16 * cam.scaleAt(o)
        ..color = labShade(_metal, -0.1),
    );
    _box(canvas, cam, l(5.8, 0), const _V3(0.4, 0.15, 0.6), _metal, ax: ax, spec: 0.6);
  }

  /// Alligator clip: coloured body + two metal jaws pointing along [dir].
  void _clip(Canvas canvas, _V3 c, double dir, Color body) {
    final d = _V3(math.cos(dir), 0, math.sin(dir));
    labGroundShadow(
      canvas,
      cam.project(_V3(c.x - 0.25, _groundAt(c.x, c.z), c.z - 0.25)),
      1.6 * cam.scaleAt(c),
      0.9 * cam.scaleAt(c),
      opacity: 0.28,
    );
    _box(canvas, cam, c, const _V3(0.4, 0.15, 0.2), body, ax: d, spec: 0.3);
    _box(canvas, cam, c + d * 0.65 + const _V3(0, -0.1, 0), const _V3(0.25, 0.05, 0.15), _metal, ax: d, spec: 0.6);
    _box(canvas, cam, c + d * 0.65 + const _V3(0, 0.1, 0), const _V3(0.25, 0.05, 0.15), _metal, ax: d, spec: 0.6);
  }

  /// Keeps sagging wire samples resting on the surface below them.
  List<_V3> _rest(List<_V3> pts) => [
        for (final p in pts) p.withY(math.max(p.y, _groundAt(p.x, p.z) + 0.15)),
      ];

  void _redWire(Canvas canvas) {
    final d = _V3(math.cos(scene.redDir), 0, math.sin(scene.redDir));
    final p2 = scene.redClip - d * 0.4;
    const p1 = _batteryPlus;
    final mid = ((p1 + p2) * 0.5).withY(math.min(p1.y, p2.y) - 2);
    _tube(canvas, cam, _rest(_bezier(p1, mid, p2, 32)), 0.15, _wireRed);
  }

  void _blackWire(Canvas canvas) {
    final d = _V3(math.cos(scene.blackDir), 0, math.sin(scene.blackDir));
    final p4 = scene.blackClip - d * 0.4;
    const p3 = _lampWireStart;
    final mid = ((p3 + p4) * 0.5).withY(math.min(p3.y, p4.y) - 1.5);
    _tube(canvas, cam, _rest(_bezier(p3, mid, p4, 32)), 0.15, _wireBlack);
  }

  @override
  bool shouldRepaint(covariant _Scene1Painter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.batteryLabel != batteryLabel ||
      old.lampLabel != lampLabel ||
      old.scene != scene;
}

// ================================================== SCENARIO 2 PAINTER

const Color _symDark = Color(0xFF1E293B);

class _Scene2Painter extends CustomPainter {
  _Scene2Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.libraryLabel,
    required this.cellLabel,
    required this.lampLabel,
    required this.switchLabel,
  }) : super(repaint: repaint);

  final _SwitchScene scene;
  final bool isDark;
  final bool showLabels;
  final String libraryLabel;
  final String cellLabel;
  final String lampLabel;
  final String switchLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final t = scene.time;
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = const Color(0xFFF8FAFC));

    // Green workspace board (40 x 40 centred at x = 10) with a faint grid.
    final board = Rect.fromPoints(_p2(-10, -20), _p2(30, 20));
    canvas.drawRect(board, Paint()..color = const Color(0xFFDCFCE7));
    final grid = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF16A34A).withValues(alpha: 0.08);
    for (var x = -10.0; x <= 30; x += 2) {
      canvas.drawLine(_p2(x, -20), _p2(x, 20), grid);
    }
    for (var z = -20.0; z <= 20; z += 2) {
      canvas.drawLine(_p2(-10, z), _p2(30, z), grid);
    }

    // Symbol library panel (HTML: 24 x 40 centred at x = -18). It ends at
    // x = -7.5 so the cell target ring sits fully on the green board, and it
    // runs into the letterbox area on the left.
    final lib = Rect.fromPoints(_p2(-30, -20), _p2(-7.5, 20)).expandToInclude(
      Rect.fromLTRB(bleed.left, _p2(0, -20).dy, bleed.left + 1, _p2(0, 20).dy),
    );
    canvas.drawRect(
      lib.shift(const Offset(3, 0)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRect(lib, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawLine(
      lib.topRight,
      lib.bottomRight,
      Paint()
        ..strokeWidth = 1.5
        ..color = _Colors.slate300,
    );

    // Drop targets (radius 3).
    void target(Offset w) => _targetRing(
          canvas,
          [
            for (var i = 0; i < 48; i++)
              _p2(w.dx + 3 * math.cos(i * math.pi / 24), w.dy + 3 * math.sin(i * math.pi / 24)),
          ],
          t,
        );
    if (scene.showCellTarget) target(_cellTarget);
    if (scene.showLampTarget) target(_lampTarget);
    if (scene.showSwitchTarget) target(_switchTarget);

    // Wires drawn after "Connect the Diagram".
    if (scene.wiresConnected) {
      final wire = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3 * _k2
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter
        ..color = _symDark;
      for (final line in _s2Wires) {
        final path = Path();
        for (var i = 0; i < line.length; i++) {
          final p = _p2(line[i].dx, line[i].dy);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, wire);
      }
    }

    // Symbols (the dragged one on top).
    final order = ['symCell', 'symLamp', 'symSwitch']
      ..sort((a, b) => (a == scene.dragging ? 1 : 0).compareTo(b == scene.dragging ? 1 : 0));
    for (final id in order) {
      switch (id) {
        case 'symCell':
          _local(canvas, scene.cell, scene.cellPlaced ? math.pi / 2 : 0, id, () => _cellSymbol(canvas, scene.cellPlaced));
        case 'symLamp':
          _local(canvas, scene.lamp, scene.lampPlaced ? math.pi / 2 : 0, id, () => _lampSymbol(canvas, t));
        case 'symSwitch':
          _local(canvas, scene.sw, 0, id, () => _switchSymbol(canvas));
      }
    }

    // Current flow along the diagram while the switch is ON.
    if (scene.s2On && scene.particles.isNotEmpty) {
      for (final p in scene.particles) {
        final w = _alongPath(_flowPath2, p);
        final c = _p2(w.x, w.z);
        final r = 0.4 * _k2;
        labGlow(canvas, c, r * 2.6, const Color(0xFFFACC15), intensity: 0.55);
        labSphere(canvas, c, r, _glowYellow, highlight: 0.5, shade: 0.3);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFFCA8A04),
        );
      }
    }

    // Blinking red connection points (step 4).
    if (scene.showConnPoints) {
      final k = 1 + math.sin(t * 5) * 0.1;
      for (final cp in _connPoints) {
        final c = _p2(cp.dx, cp.dy);
        labGlow(canvas, c, 2.2 * _k2 * k, const Color(0xFFEF4444), intensity: 0.45);
        labSphere(canvas, c, 1.2 * _k2 * k, const Color(0xFFEF4444), opacity: 0.85, highlight: 0.5);
      }
    }

    if (showLabels) {
      // HTML offset (0, 0.5, 14) collides with the "Switch" label; shown as
      // the library header instead.
      _canvasLabel(canvas, libraryLabel, _p2(-18, -15), isDark);
      _canvasLabel(canvas, cellLabel, _p2(scene.cell.dx, scene.cell.dy - 4), isDark);
      _canvasLabel(canvas, lampLabel, _p2(scene.lamp.dx, scene.lamp.dy + 3.5), isDark);
      _canvasLabel(canvas, switchLabel, _p2(scene.sw.dx, scene.sw.dy + 3), isDark);
    }
  }

  /// Draws [draw] in the symbol's local units (x right, z down) at [w].
  void _local(Canvas canvas, Offset w, double rot, String id, VoidCallback draw) {
    final c = _p2(w.dx, w.dy);
    final lifted = scene.dragging == id;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(_k2);
    canvas.rotate(rot);
    if (lifted) {
      // Soft "picked up" shadow + slight lift.
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0.35, 0.45), width: 7, height: 6), const Radius.circular(0.8)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
      );
      canvas.scale(1.06);
    }
    draw();
    canvas.restore();
  }

  Paint get _ink => Paint()..color = _symDark;

  void _bar(Canvas canvas, double cx, double cz, double w, double h) =>
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cz), width: w, height: h), _ink);

  /// Electric cell: long thin (+) plate, short thick (-) plate, wire stubs.
  void _cellSymbol(Canvas canvas, bool rotated) {
    _bar(canvas, -1, 0, 0.4, 4.5);
    _bar(canvas, 1, 0, 1, 2.5);
    _bar(canvas, -1.95, 0, 1.5, 0.3);
    _bar(canvas, 1.95, 0, 1.5, 0.3);
    _bar(canvas, -2, -1.5, 0.8, 0.15);
    _bar(canvas, -2, -1.5, 0.15, 0.8);
    // The "-" sign stays horizontal on screen after the cell is turned upright.
    rotated ? _bar(canvas, 2, -1.5, 0.15, 0.8) : _bar(canvas, 2, -1.5, 0.8, 0.15);
  }

  void _lampSymbol(Canvas canvas, double t) {
    if (scene.s2On) {
      labGlow(canvas, Offset.zero, 5.2, const Color(0xFFFDE047), intensity: 0.75 + 0.1 * math.sin(t * 9));
      canvas.drawCircle(Offset.zero, 2.2, Paint()..color = _glowYellow);
    }
    canvas.drawCircle(
      Offset.zero,
      2.35,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3
        ..color = _symDark,
    );
    for (final a in const [math.pi / 4, -math.pi / 4]) {
      canvas.save();
      canvas.rotate(a);
      _bar(canvas, 0, 0, 0.3, 4.4);
      canvas.restore();
    }
    _bar(canvas, -2.8, 0, 1, 0.3);
    _bar(canvas, 2.8, 0, 1, 0.3);
  }

  void _switchSymbol(Canvas canvas) {
    canvas.drawCircle(const Offset(-2, 0), 0.6, _ink);
    canvas.drawCircle(const Offset(2, 0), 0.6, _ink);
    _bar(canvas, -3.1, 0, 1.5, 0.3);
    _bar(canvas, 3.1, 0, 1.5, 0.3);
    // Lever: OFF = centre (-0.3, -1.1) tilted 30°, ON = flat between the dots.
    final k = scene.lever;
    canvas.save();
    canvas.translate(-0.3 * (1 - k), -1.1 * (1 - k));
    canvas.rotate(math.pi / 6 * (1 - k));
    _bar(canvas, 0, 0, 4, 0.4);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Scene2Painter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.libraryLabel != libraryLabel ||
      old.cellLabel != cellLabel ||
      old.lampLabel != lampLabel ||
      old.switchLabel != switchLabel ||
      old.scene != scene;
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
