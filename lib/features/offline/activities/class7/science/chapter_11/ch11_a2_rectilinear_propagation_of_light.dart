// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 11 • Activity 2
/// Rectilinear Propagation of Light.
///
/// Native Flutter port of `Cl7S-Ch11-A2-Rectilinear_Propagation_of_Light.html`.
/// Scenario 1: place three matchbox trays with holes between a torch and a
/// screen, switch the torch on, then move the middle tray up and sideways
/// to block the beam. Scenario 2: align a pipe between an eye and a candle
/// and bend it with its handle to see that light cannot go round a bend.
class Ch11A2RectilinearPropagationOfLightPage extends StatefulWidget {
  const Ch11A2RectilinearPropagationOfLightPage({super.key});

  @override
  State<Ch11A2RectilinearPropagationOfLightPage> createState() => _Ch11A2RectilinearPropagationOfLightPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, switchTap 2585.
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

// ============================================================== MODEL

const Size _design = Size(900, 560);

/// Height of the beam axis: the centre of the tray holes, the torch lens
/// and the spot on the screen.
const double _beamY = -2.5;
const double _trayRestY = -2.5; // trays standing on the table (top at -4.5)
const List<double> _trayX = [-10, 0, 10];

typedef _P3 = (double, double, double);

/// Mutable 3D point (a Three.js `position`).
class _V3 {
  _V3(this.x, this.y, this.z);
  double x, y, z;

  void setAll(double nx, double ny, double nz) {
    x = nx;
    y = ny;
    z = nz;
  }
}

/// Perspective "look-at" camera reproducing the HTML PerspectiveCamera.
class _Cam {
  _Cam(_P3 pos, _P3 target, this.focal, this.center)
      : px = pos.$1,
        py = pos.$2,
        pz = pos.$3 {
    final fx0 = target.$1 - px, fy0 = target.$2 - py, fz0 = target.$3 - pz;
    final fl = math.sqrt(fx0 * fx0 + fy0 * fy0 + fz0 * fz0);
    fx = fx0 / fl;
    fy = fy0 / fl;
    fz = fz0 / fl;
    final rl = math.sqrt(fz * fz + fx * fx);
    rx = -fz / rl;
    rz = fx / rl;
    ux = -rz * fy;
    uy = rz * fx - rx * fz;
    uz = rx * fy;
  }

  static const double near = 1.0;
  final double px, py, pz, focal;
  final Offset center;
  late final double fx, fy, fz, rx, rz, ux, uy, uz;

  _P3 toCam(double x, double y, double z) {
    final dx = x - px, dy = y - py, dz = z - pz;
    return (dx * rx + dz * rz, dx * ux + dy * uy + dz * uz, dx * fx + dy * fy + dz * fz);
  }

  Offset _screen(_P3 c) {
    final d = math.max(near, c.$3);
    return Offset(center.dx + c.$1 * focal / d, center.dy - c.$2 * focal / d);
  }

  Offset p(double x, double y, double z) => _screen(toCam(x, y, z));
  Offset q(_P3 w) => p(w.$1, w.$2, w.$3);

  /// Pixels per world unit at this point.
  double k(double x, double y, double z) => focal / math.max(near, toCam(x, y, z).$3);

  /// The point on the plane z = [planeZ] under a design-space position.
  _P3 onPlaneZ(Offset s, double planeZ) {
    final a = (s.dx - center.dx) / focal, b = -(s.dy - center.dy) / focal;
    final dx = fx + rx * a + ux * b, dy = fy + uy * b, dz = fz + rz * a + uz * b;
    final t = dz.abs() < 1e-6 ? 0.0 : (planeZ - pz) / dz;
    return (px + dx * t, py + dy * t, planeZ);
  }

  /// Polygon of world points, clipped against the near plane.
  Path? poly(List<_P3> pts) {
    final cs = [for (final w in pts) toCam(w.$1, w.$2, w.$3)];
    final out = <_P3>[];
    for (var i = 0; i < cs.length; i++) {
      final a = cs[i], b = cs[(i + 1) % cs.length];
      final ain = a.$3 >= near, bin = b.$3 >= near;
      if (ain) out.add(a);
      if (ain != bin) {
        final t = (near - a.$3) / (b.$3 - a.$3);
        out.add((a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t, near));
      }
    }
    if (out.length < 3) return null;
    return Path()..addPolygon([for (final c in out) _screen(c)], true);
  }
}

/// Mutable scene model read by the painter every frame.
class _OpticsScene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // Scenario 1: matchbox trays, torch, screen.
  final List<_V3> trays = [for (final x in _trayX) _V3(x, 10, 0)];
  final List<bool> snapped = [false, false, false];
  bool torchOn = false;
  double torchOnAt = 0;

  // Scenario 2: pipe (group position + joint height), eye, candle.
  final _V3 pipe = _V3(0, 10, 0);
  double jointY = 0;
  bool pipeView = false;

  /// What is held: 'tray0'…'tray2', 'pipe' or 'joint'.
  String? dragging;

  _Cam camera() => scenario == 0
      ? _Cam((-27, 11, 35), (1.5, -3.5, 0), 700, const Offset(470, 300))
      : _Cam((0, 15, 60), (0, -5, 0), 900, const Offset(450, 330));

  /// HTML animate(): the beam is blocked once the middle tray moves more
  /// than 1 unit away from its hole position.
  bool get beamBlocked => (trays[1].y - _trayRestY).abs() > 1.0 || trays[1].z.abs() > 1.0;

  /// HTML `bendFactor = clamp(joint.y / 3, 0, 1)`.
  double get bend => (jointY / 3).clamp(0.0, 1.0);

  bool get pulseMiddle => scenario == 0 && (step == 3 || step == 4) && dragging != 'tray1';
  bool get pulseJoint => scenario == 1 && (step == 2 || step == 3) && dragging != 'joint';
}

/// A TWEEN.js style tween driven by the scene ticker.
class _Tw {
  _Tw({required this.duration, required this.update, this.onStart, this.owner});

  final double duration;
  final VoidCallback? onStart;
  final void Function(double t) update;
  final Object? owner;
  double? start;
}

class _Ch11A2RectilinearPropagationOfLightPageState extends State<Ch11A2RectilinearPropagationOfLightPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  _OpticsScene _s = _OpticsScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tw> _tweens = [];
  late final Ticker _ticker;

  bool _hint = true; // "Follow the instructions to interact!"
  bool _concluded = false;

  // Drag bookkeeping.
  Offset _dragStart = Offset.zero;
  _P3 _objStart = (0, 0, 0);
  _P3 _planeStart = (0, 0, 0);

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_s.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _buildScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _tweens.clear();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    _s.time = now;
    if (_tweens.isNotEmpty) {
      for (final tw in List<_Tw>.of(_tweens)) {
        if (!_tweens.contains(tw)) continue;
        if (tw.start == null) {
          tw.start = now;
          tw.onStart?.call();
        }
        final p = tw.duration <= 0 ? 1.0 : ((now - tw.start!) / tw.duration).clamp(0.0, 1.0);
        tw.update(p); // TWEEN default easing: linear
        if (p >= 1) _tweens.remove(tw);
      }
    }
    _frame.value = now;
  }

  /// `new TWEEN.Tween(v).to({...}, ms)` for one object.
  void _tweenV3(_V3 v, {double? x, double? y, double? z, int ms = 300, Object? owner}) {
    _tweens.removeWhere((t) => t.owner == (owner ?? v));
    var x0 = v.x, y0 = v.y, z0 = v.z;
    _tweens.add(_Tw(
      duration: ms / 1000,
      owner: owner ?? v,
      onStart: () {
        x0 = v.x;
        y0 = v.y;
        z0 = v.z;
      },
      update: (t) {
        if (x != null) v.x = x0 + (x - x0) * t;
        if (y != null) v.y = y0 + (y - y0) * t;
        if (z != null) v.z = z0 + (z - z0) * t;
      },
    ));
  }

  void _tweenJoint(double to, {int ms = 300}) {
    _tweens.removeWhere((t) => t.owner == 'joint');
    var from = _s.jointY;
    final s = _s;
    _tweens.add(_Tw(
      duration: ms / 1000,
      owner: 'joint',
      onStart: () => from = s.jointY,
      update: (t) => s.jointY = from + (to - from) * t,
    ));
  }

  // ------------------------------------------------------------ logic

  /// HTML `buildScenario()`.
  void _buildScenario() {
    _lab.cancelPending();
    _tweens.clear();
    final old = _s;
    _s = _OpticsScene()
      ..scenario = old.scenario
      ..step = old.step
      ..time = old.time;
    _hint = true;
    _concluded = false;
  }

  void _changeScenario(int index) {
    setState(() {
      _s.scenario = index;
      _s.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _s.scenario = 0;
      _s.step = 1;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`: the step counter runs one past the last step,
  /// which shows the conclusion.
  void _advanceStep() {
    if (!mounted) return;
    final n = _data.steps.length;
    setState(() {
      if (_s.step <= n) _s.step++;
      if (_s.step > n && !_concluded) {
        _concluded = true;
        _showConclusion();
      } else if (_s.scenario == 0 && _s.step == 4) {
        // After a moment, re-align the middle tray so the sideways move
        // blocks the beam "again" (the HTML left it raised).
        final tray = _s.trays[1];
        _lab.after(const Duration(milliseconds: 1500), () {
          if (_s.dragging != 'tray1' && tray.y > _trayRestY) _tweenV3(tray, y: _trayRestY, ms: 400);
        });
      }
    });
  }

  /// HTML `showConclusion()`: "Continue" goes straight on to the next
  /// scenario (`nextScenario()`), "Restart Lab" once both are done.
  void _showConclusion() {
    final idx = _s.scenario;
    _lab.completedScenarios.add(idx);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.after(const Duration(milliseconds: 10), () {
      _lab.openSidebar();
      _lab.showPopup(() => LabPopupContent(
            title: _t('sci_conclusion'),
            heading: _lab.t('lbl_observation'),
            body: _t('conclusion_${idx + 1}'),
            actions: [
              if (allDone)
                LabAction(label: _lab.t('btn_restart'), icon: Icons.restart_alt, onTap: _lab.requestFullReset)
              else
                LabAction(
                  label: _lab.t('btn_continue'),
                  icon: Icons.arrow_forward,
                  color: _Colors.indigo600,
                  foreground: Colors.white,
                  onTap: () => _nextScenario(idx),
                ),
            ],
          ));
    });
  }

  void _nextScenario(int from) {
    _lab.hidePopup(sound: false);
    final next = from + 1;
    if (next < 2) {
      _lab.showToast(_lab.t('msg_scenario_complete'), sound: false);
      _Audio.play(_Sound.scenario);
      _changeScenario(next);
    }
  }

  // ------------------------------------------------- interaction

  _P3 _posOf(String id) {
    final s = _s;
    if (id.startsWith('tray')) {
      final t = s.trays[int.parse(id.substring(4))];
      return (t.x, t.y, t.z);
    }
    if (id == 'joint') return (s.pipe.x, s.pipe.y + s.jointY, s.pipe.z);
    return (s.pipe.x, s.pipe.y, s.pipe.z);
  }

  bool _near(_Cam cam, Offset p, _P3 w, double r, {double minPx = 30}) {
    final c = cam.q(w);
    return (p - c).distance <= math.max(r * cam.k(w.$1, w.$2, w.$3), minPx);
  }

  /// Distance check along the two pipe halves (eye end → joint → candle end).
  bool _hitPipe(_Cam cam, Offset p) {
    final s = _s;
    final a = cam.p(s.pipe.x - 15, s.pipe.y, s.pipe.z);
    final j = cam.p(s.pipe.x, s.pipe.y + s.jointY, s.pipe.z);
    final b = cam.p(s.pipe.x + 15, s.pipe.y, s.pipe.z);
    final r = math.max(1.8 * cam.k(s.pipe.x, s.pipe.y, s.pipe.z), 24.0);
    double segDist(Offset u, Offset v) {
      final d = v - u;
      final len2 = d.dx * d.dx + d.dy * d.dy;
      final t = len2 == 0 ? 0.0 : (((p - u).dx * d.dx + (p - u).dy * d.dy) / len2).clamp(0.0, 1.0);
      return (p - (u + d * t)).distance;
    }

    return segDist(a, j) <= r || segDist(j, b) <= r;
  }

  void _onTapUp(TapUpDetails d) {
    final s = _s;
    if (!_lab.isLabActive || _concluded || s.scenario != 0 || s.step != 2 || s.torchOn) return;
    final cam = s.camera();
    if (_near(cam, d.localPosition, (-20, _beamY + 1.2, 0), 1.8, minPx: 36)) _switchOn();
  }

  /// Step 2: the torch switch (HTML pointerdown on `torch_switch`).
  void _switchOn() {
    _Audio.play(_Sound.switchTap);
    setState(() {
      _s
        ..torchOn = true
        ..torchOnAt = _s.time;
    });
    _lab.showToast(_t('msg_step_done'), sound: false);
    _advanceStep();
  }

  void _onPanStart(DragStartDetails d) {
    final s = _s;
    if (!_lab.isLabActive || _concluded || s.dragging != null) return;
    final cam = s.camera();
    final p = d.localPosition;
    String? target;
    if (s.scenario == 0) {
      if (s.step == 1) {
        var best = double.infinity;
        for (var i = 0; i < 3; i++) {
          if (s.snapped[i]) continue;
          final w = _posOf('tray$i');
          final dist = (p - cam.q(w)).distance;
          if (_near(cam, p, w, 2.9) && dist < best) {
            best = dist;
            target = 'tray$i';
          }
        }
      } else if ((s.step == 3 || s.step == 4) && _near(cam, p, _posOf('tray1'), 2.9)) {
        target = 'tray1';
      }
    } else {
      if (s.step == 1 && _hitPipe(cam, p)) {
        target = 'pipe';
      } else if ((s.step == 2 || s.step == 3) && _near(cam, p, _posOf('joint'), 2.2, minPx: 34)) {
        target = 'joint';
      }
    }
    if (target == null) return;
    final id = target;
    _tweens.removeWhere((t) => t.owner == (id == 'joint' ? 'joint' : _objOf(id)));
    _objStart = _posOf(id);
    _dragStart = p;
    _planeStart = cam.onPlaneZ(p, _objStart.$3);
    setState(() {
      _hint = false;
      s.dragging = id;
    });
    if (id == 'tray1' && s.step == 4 && s.trays[1].y > _trayRestY) {
      _tweenV3(s.trays[1], y: _trayRestY, ms: 300);
    }
  }

  Object _objOf(String id) => id.startsWith('tray') ? _s.trays[int.parse(id.substring(4))] : _s.pipe;

  /// Movement along one world axis from the screen drag (the HTML drags on
  /// a camera-facing plane and keeps only that axis).
  double _alongAxis(_Cam cam, Offset delta, _P3 at, _P3 axis) {
    final a = cam.q(at);
    final b = cam.p(at.$1 + axis.$1, at.$2 + axis.$2, at.$3 + axis.$3);
    final v = b - a;
    final len2 = v.dx * v.dx + v.dy * v.dy;
    return len2 < 1e-6 ? 0 : (delta.dx * v.dx + delta.dy * v.dy) / len2;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final s = _s;
    final id = s.dragging;
    if (id == null) return;
    final cam = s.camera();
    final delta = d.localPosition - _dragStart;
    final o = _objStart;
    if (id == 'joint') {
      s.jointY = (o.$2 - s.pipe.y + _alongAxis(cam, delta, o, (0, 1, 0))).clamp(0.0, 7.0);
    } else if (id == 'pipe' || (id.startsWith('tray') && s.step == 1)) {
      final hit = cam.onPlaneZ(d.localPosition, o.$3);
      final nx = (o.$1 + hit.$1 - _planeStart.$1).clamp(-24.0, 24.0);
      final ny = (o.$2 + hit.$2 - _planeStart.$2).clamp(id == 'pipe' ? -1.0 : _trayRestY, 14.0);
      if (id == 'pipe') {
        s.pipe.setAll(nx, ny, o.$3);
      } else {
        s.trays[int.parse(id.substring(4))].setAll(nx, ny, o.$3);
      }
    } else if (id == 'tray1' && s.step == 3) {
      s.trays[1].y = (o.$2 + _alongAxis(cam, delta, o, (0, 1, 0))).clamp(_trayRestY, 6.0);
    } else if (id == 'tray1' && s.step == 4) {
      s.trays[1].z = (o.$3 + _alongAxis(cam, delta, o, (0, 0, 1))).clamp(-5.0, 5.0);
    }
  }

  void _onPanEnd() {
    final id = _s.dragging;
    if (id == null) return;
    setState(() => _s.dragging = null);
    _checkDrop(id);
  }

  void _wrong() => _lab.showToast(_t('msg_wrong_drop'), isError: true);

  /// HTML `checkDrop()`.
  void _checkDrop(String id) {
    final s = _s;
    if (s.scenario == 0) {
      if (s.step == 1 && id.startsWith('tray')) {
        final i = int.parse(id.substring(4));
        final t = s.trays[i];
        final dist = math.sqrt(math.pow(t.x - _trayX[i], 2) + math.pow(t.y - _trayRestY, 2) + t.z * t.z);
        if (dist < 12) {
          setState(() {
            t.setAll(_trayX[i], _trayRestY, 0);
            s.snapped[i] = true;
          });
          if (s.snapped.every((v) => v)) {
            _lab.showToast(_t('msg_step_done'));
            _advanceStep();
          } else {
            _Audio.play(_Sound.correct);
          }
        } else {
          _wrong();
          _tweenV3(t, x: _trayX[i], y: 10, z: 0);
        }
      } else if (s.step == 3 && id == 'tray1') {
        if (s.trays[1].y > -0.5) {
          _lab.showToast(_t('msg_step_done'));
          _advanceStep();
        } else {
          _wrong();
          _tweenV3(s.trays[1], y: _trayRestY);
        }
      } else if (s.step == 4 && id == 'tray1') {
        if (s.trays[1].z.abs() > 1.5) {
          _Audio.play(_Sound.correct);
          _advanceStep();
        } else {
          _wrong();
          _tweenV3(s.trays[1], z: 0);
        }
      }
    } else {
      if (s.step == 1 && id == 'pipe') {
        final p = s.pipe;
        if (math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z) < 10) {
          setState(() {
            p.setAll(0, 0, 0);
            s.pipeView = true;
          });
          _lab.showToast(_t('msg_step_done'));
          _advanceStep();
        } else {
          _wrong();
          _tweenV3(p, x: 0, y: 10, z: 0);
        }
      } else if (s.step == 2 && id == 'joint') {
        if (s.jointY > 3) {
          _lab.showToast(_t('msg_step_done'));
          _advanceStep();
        } else {
          _wrong();
          _tweenJoint(0);
        }
      } else if (s.step == 3 && id == 'joint') {
        if (s.jointY < 1) {
          _Audio.play(_Sound.correct);
          _tweenJoint(0);
          _advanceStep();
        } else {
          _wrong();
        }
      }
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
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final finished = _s.step > data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.flashlight_on,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _s.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _s.step,
          // HTML renderHUD() hides the HUD once every step is done.
          instruction: finished ? '' : null,
          sidebarExtraTitle: _t('status'),
          sidebarExtra: _status(p, s),
          onReset: _fullReset,
          overlays: [
            if (_hint && _lab.isLabActive) _hintOverlay(s),
            if (_s.scenario == 1 && _s.pipeView) _pipeViewWindow(s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            // A small touch slop so short drags on phones still pick objects up.
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
                  painter: _OpticsPainter(
                    scene: _s,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang.code,
                    labels: {
                      for (final k in const ['obj_torch', 'obj_tray', 'obj_screen', 'obj_candle', 'obj_pipe', 'obj_eye'])
                        k: _t(k),
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#drag-instruction`.
  Widget _hintOverlay(double s) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: _Ch11A2Bounce(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 260 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 34 * s, color: Colors.white.withValues(alpha: 0.6)),
                  SizedBox(height: 4 * s),
                  Text(
                    _t('drag_drop_hint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w800,
                      fontSize: 13 * s,
                      shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
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

  /// HTML `#view-pipe-ui`: what the eye sees through the pipe.
  Widget _pipeViewWindow(double s, EdgeInsets inset) {
    final size = 132 * s;
    return Positioned(
      top: inset.top,
      right: inset.right,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 350),
          builder: (context, v, child) => Opacity(opacity: v, child: child),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10 * s),
              border: Border.all(color: _Colors.slate700, width: 4),
              boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 6))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6 * s),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _PipeViewPainter(scene: _s, repaint: _frame))),
                  Positioned(
                    top: 5 * s,
                    left: 5 * s,
                    right: 5 * s,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 3 * s),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4 * s),
                        ),
                        child: Text(
                          _t('view_through_pipe'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 9.5 * s, fontWeight: FontWeight.w800),
                        ),
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

  /// Sidebar readout: tray / beam state or pipe bend / flame view.
  Widget _status(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, _, _) {
        final sc = _s;
        final rows = sc.scenario == 0
            ? [
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('trays_placed'),
                  value: '${sc.snapped.where((v) => v).length}/3',
                  valueColor: sc.snapped.every((v) => v) ? _Colors.green : _Colors.zslYellow,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('obj_torch'),
                  value: sc.torchOn ? _lab.t('on') : _lab.t('off'),
                  valueColor: sc.torchOn ? _Colors.green : null,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('spot'),
                  value: sc.torchOn && !sc.beamBlocked ? _t('visible') : _t('blocked'),
                  valueColor: sc.torchOn && !sc.beamBlocked ? _Colors.green : _Colors.red,
                ),
              ]
            : [
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('pipe_bend'),
                  value: '${(sc.bend * 100).round()}%',
                  valueColor: sc.bend > 0.5 ? _Colors.red : _Colors.green,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('flame_view'),
                  value: sc.pipeView && sc.bend < 0.5 ? _t('visible') : _t('blocked'),
                  valueColor: sc.pipeView && sc.bend < 0.5 ? _Colors.green : _Colors.red,
                ),
              ];
        return Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        );
      },
    );
  }
}

/// Gentle up / down bounce (Tailwind `animate-bounce`).
class _Ch11A2Bounce extends StatefulWidget {
  const _Ch11A2Bounce({required this.child});
  final Widget child;

  @override
  State<_Ch11A2Bounce> createState() => _Ch11A2BounceState();
}

class _Ch11A2BounceState extends State<_Ch11A2Bounce> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = _c.value;
        final up = v < 0.5 ? Curves.easeOut.transform(v * 2) : Curves.easeIn.transform(2 - v * 2);
        return Transform.translate(offset: Offset(0, -12 * up), child: child);
      },
      child: widget.child,
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Rectilinear Propagation of Light',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: Matchbox Alignment Challenge',
    'scen_2_opt': 'Scenario 2: The Bent Pipe Mystery',
    'sci_conclusion': 'Success!',
    'drag_drop_hint': 'Follow the instructions to interact!',
    'view_through_pipe': 'View Through Pipe',
    'msg_wrong_drop': 'Not quite! Check the alignment.',
    'msg_step_done': "Great! Let's proceed.",
    'conclusion_1':
        'You observed that the light spot only appeared on the screen when all three holes were in a perfect straight line. Any small movement that blocked the path stopped the light. This proves that light travels in a straight line.',
    'conclusion_2':
        'You could only see the candle flame when the pipe was straight. As soon as you bent the pipe, the path was blocked. This is because the light from the flame travels in a straight line to your eye and cannot travel around the bend.',
    'obj_torch': 'Torch',
    'obj_tray': 'Matchbox Tray',
    'obj_screen': 'Screen',
    'obj_candle': 'Lit Candle',
    'obj_pipe': 'Flexible Pipe',
    'obj_eye': 'Observer Eye',
    // Sidebar readout (not in the HTML).
    'status': 'Lab Status',
    'trays_placed': 'Trays on outlines',
    'spot': 'Light spot on screen',
    'visible': 'Visible',
    'blocked': 'Blocked',
    'pipe_bend': 'Pipe bend',
    'flame_view': 'Flame through pipe',
  },
  'hi': {
    'app_title': 'प्रकाश का ऋजुरेखीय संचरण',
    'app_subtitle': 'कक्षा 7 • प्रकाश: छाया और परावर्तन',
    'scen_1_opt': 'परिदृश्य 1: माचिस संरेखण चुनौती',
    'scen_2_opt': 'परिदृश्य 2: मुड़े हुए पाइप का रहस्य',
    'sci_conclusion': 'सफलता!',
    'drag_drop_hint': 'बातचीत करने के लिए निर्देशों का पालन करें!',
    'view_through_pipe': 'पाइप के माध्यम से दृश्य',
    'msg_wrong_drop': 'बिल्कुल नहीं! संरेखण की जाँच करें।',
    'msg_step_done': 'बहुत बढ़िया! आगे बढ़ें।',
    'conclusion_1':
        'आपने देखा कि प्रकाश का धब्बा स्क्रीन पर तभी दिखाई देता है जब तीनों छेद एक सीधी रेखा में हों। कोई भी छोटी सी गति जिसने पथ को अवरुद्ध कर दिया, प्रकाश को रोक दिया। इससे सिद्ध होता है कि प्रकाश सीधी रेखा में गमन करता है।',
    'conclusion_2':
        'आप मोमबत्ती की लौ तभी देख सकते थे जब पाइप सीधा था। जैसे ही आपने पाइप मोड़ा, रास्ता बंद हो गया। ऐसा इसलिए है क्योंकि लौ से प्रकाश एक सीधी रेखा में आपकी आँख तक जाता है और मोड़ के चारों ओर यात्रा नहीं कर सकता है।',
    'obj_torch': 'टॉर्च',
    'obj_tray': 'माचिस की ट्रे',
    'obj_screen': 'स्क्रीन',
    'obj_candle': 'जलती हुई मोमबत्ती',
    'obj_pipe': 'लचीला पाइप',
    'obj_eye': 'पर्यवेक्षक आँख',
    'status': 'लैब स्थिति',
    'trays_placed': 'रूपरेखा पर ट्रे',
    'spot': 'स्क्रीन पर प्रकाश का धब्बा',
    'visible': 'दिखाई दे रहा',
    'blocked': 'अवरुद्ध',
    'pipe_bend': 'पाइप का मोड़',
    'flame_view': 'पाइप से लौ',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'To demonstrate that light requires a clear, straight path to travel from a source to a screen.',
      steps: [
        LabStep(
          concept: 'Setting the Path',
          action: 'DRAG the three matchbox trays onto their glowing outlines on the table.',
          observation: 'The holes in the trays are perfectly aligned in a straight line between the torch and screen.',
        ),
        LabStep(
          concept: 'Light travels straight',
          action: 'CLICK the switch on the torch to turn it on.',
          observation: 'A beam of light passes through all three holes, creating a bright spot on the screen.',
        ),
        LabStep(
          concept: 'Blocking the path (Vertical)',
          action: 'DRAG the middle matchbox tray slightly upwards.',
          observation: 'The light beam is blocked by the misaligned tray, and the spot of light disappears.',
        ),
        LabStep(
          concept: 'Blocking the path (Horizontal)',
          action: 'DRAG the middle matchbox tray to the side.',
          observation: 'The light beam is again blocked, confirming any deviation breaks the straight path.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To verify that one cannot see around a bend because light travels in a straight line.',
      steps: [
        LabStep(
          concept: 'Direct Line of Sight',
          action: 'DRAG the straight pipe to align its ends with the eye icon and the candle flame.',
          observation: "The 'View Through Pipe' window shows a clear image of the candle flame.",
        ),
        LabStep(
          concept: 'Bending the Path',
          action: 'DRAG the handle in the middle of the pipe upwards to create a bend.',
          observation: 'The view of the flame is completely blocked; light cannot curve through the pipe.',
        ),
        LabStep(
          concept: 'Restoring the Path',
          action: 'DRAG the handle back down to straighten the pipe.',
          observation: 'The candle flame becomes visible again, proving it needs a straight path to your eye.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'यह प्रदर्शित करने के लिए कि प्रकाश को एक स्रोत से स्क्रीन तक जाने के लिए एक स्पष्ट, सीधे पथ की आवश्यकता होती है।',
      steps: [
        LabStep(
          concept: 'पथ सेट करना',
          action: 'मेज पर चमकती रूपरेखाओं पर तीन माचिस की ट्रे खींचें।',
          observation: 'ट्रे में छेद टॉर्च और स्क्रीन के बीच एक सीधी रेखा में पूरी तरह से संरेखित हैं।',
        ),
        LabStep(
          concept: 'प्रकाश सीधा चलता है',
          action: 'इसे चालू करने के लिए टॉर्च पर स्विच पर क्लिक करें।',
          observation: 'प्रकाश की एक किरण तीनों छिद्रों से होकर गुजरती है, जिससे स्क्रीन पर एक चमकीला धब्बा बनता है।',
        ),
        LabStep(
          concept: 'पथ को अवरुद्ध करना (लंबवत)',
          action: 'बीच की माचिस की ट्रे को थोड़ा ऊपर की ओर खींचें।',
          observation: 'प्रकाश किरण गलत तरीके से रखी गई ट्रे द्वारा अवरुद्ध हो जाती है, और प्रकाश का धब्बा गायब हो जाता है।',
        ),
        LabStep(
          concept: 'पथ को अवरुद्ध करना (क्षैतिज)',
          action: 'बीच की माचिस की ट्रे को एक तरफ खींचें।',
          observation: 'प्रकाश किरण फिर से अवरुद्ध हो जाती है, यह पुष्टि करते हुए कि कोई भी विचलन सीधे पथ को तोड़ देता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'यह सत्यापित करने के लिए कि प्रकाश सीधी रेखा में गमन करने के कारण हम किसी मोड़ के पार नहीं देख सकते हैं।',
      steps: [
        LabStep(
          concept: 'दृष्टि की सीधी रेखा',
          action: 'आंख के आइकन और मोमबत्ती की लौ के साथ इसके सिरों को संरेखित करने के लिए सीधे पाइप को खींचें।',
          observation: "'पाइप के माध्यम से देखें' विंडो मोमबत्ती की लौ की एक स्पष्ट छवि दिखाती है।",
        ),
        LabStep(
          concept: 'पथ को मोड़ना',
          action: 'एक मोड़ बनाने के लिए पाइप के बीच में हैंडल को ऊपर की ओर खींचें।',
          observation: 'लौ का दृश्य पूरी तरह से अवरुद्ध है; प्रकाश पाइप के माध्यम से वक्र नहीं हो सकता है।',
        ),
        LabStep(
          concept: 'पथ को पुनर्स्थापित करना',
          action: 'पाइप को सीधा करने के लिए हैंडल को वापस नीचे खींचें।',
          observation: 'मोमबत्ती की लौ फिर से दिखाई देने लगती है, जिससे साबित होता है कि इसे आपकी आंख तक एक सीधे रास्ते की जरूरत है।',
        ),
      ],
    ),
  ],
};

// ======================================================== PRIMITIVES

Color _a(Color c, double opacity) => c.withValues(alpha: (c.a * opacity).clamp(0.0, 1.0));

/// Lambert-ish brightness (ambient 0.6 + the HTML key light at (20, 30, 20)).
Color _lit(Color c, double b) => b <= 1 ? Color.lerp(Colors.black, c, b)! : labShade(c, (b - 1) * 1.2);

const List<(List<double>, List<List<double>>)> _boxFaces = [
  ([1, 0, 0], [[1, -1, -1], [1, 1, -1], [1, 1, 1], [1, -1, 1]]),
  ([-1, 0, 0], [[-1, -1, -1], [-1, -1, 1], [-1, 1, 1], [-1, 1, -1]]),
  ([0, 1, 0], [[-1, 1, -1], [-1, 1, 1], [1, 1, 1], [1, 1, -1]]),
  ([0, -1, 0], [[-1, -1, -1], [1, -1, -1], [1, -1, 1], [-1, -1, 1]]),
  ([0, 0, 1], [[-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1]]),
  ([0, 0, -1], [[-1, -1, -1], [-1, 1, -1], [1, 1, -1], [1, -1, -1]]),
];

/// Axis-aligned BoxGeometry with back-face culling and simple shading.
void _box(Canvas canvas, _Cam cam, double cx, double cy, double cz, double w, double h, double d, Color color,
    {double opacity = 1}) {
  final hw = w / 2, hh = h / 2, hd = d / 2;
  const lx = 0.485, ly = 0.728, lz = 0.485;
  for (final (n, corners) in _boxFaces) {
    final fc = (cx + n[0] * hw, cy + n[1] * hh, cz + n[2] * hd);
    if (n[0] * (cam.px - fc.$1) + n[1] * (cam.py - fc.$2) + n[2] * (cam.pz - fc.$3) <= 0) continue;
    final path = cam.poly([for (final q in corners) (cx + q[0] * hw, cy + q[1] * hh, cz + q[2] * hd)]);
    if (path == null) continue;
    final b = 0.66 + 0.5 * math.max(0, n[0] * lx + n[1] * ly + n[2] * lz);
    canvas.drawPath(path, Paint()..color = _a(_lit(color, b), opacity));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _a(labShade(color, -0.5), 0.5 * opacity),
    );
  }
}

/// Convex hull (monotone chain) as a closed path.
Path _hull(List<Offset> pts) {
  final ps = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in ps) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in ps.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  return Path()..addPolygon([...lower..removeLast(), ...upper..removeLast()], true);
}

/// Circle of radius [r] around [c] spanned by unit vectors [u] and [v].
List<Offset> _ring(_Cam cam, _P3 c, _P3 u, _P3 v, double r, {int n = 24}) {
  return [
    for (var i = 0; i < n; i++)
      () {
        final a = 2 * math.pi * i / n;
        final ca = math.cos(a) * r, sa = math.sin(a) * r;
        return cam.p(c.$1 + u.$1 * ca + v.$1 * sa, c.$2 + u.$2 * ca + v.$2 * sa, c.$3 + u.$3 * ca + v.$3 * sa);
      }(),
  ];
}

/// Two unit vectors perpendicular to the segment a → b.
(_P3, _P3) _perp(_P3 a, _P3 b) {
  var dx = b.$1 - a.$1, dy = b.$2 - a.$2, dz = b.$3 - a.$3;
  final l = math.sqrt(dx * dx + dy * dy + dz * dz);
  dx /= l;
  dy /= l;
  dz /= l;
  // Pick a helper axis that is not parallel to the segment.
  final _P3 h = dz.abs() < 0.9 ? (0, 0, 1) : (0, 1, 0);
  var ux = dy * h.$3 - dz * h.$2, uy = dz * h.$1 - dx * h.$3, uz = dx * h.$2 - dy * h.$1;
  final ul = math.sqrt(ux * ux + uy * uy + uz * uz);
  ux /= ul;
  uy /= ul;
  uz /= ul;
  final vx = dy * uz - dz * uy, vy = dz * ux - dx * uz, vz = dx * uy - dy * ux;
  return ((ux, uy, uz), (vx, vy, vz));
}

/// Cylinder / cone between a (radius ra) and b (radius rb), shaded across
/// its screen width; the end facing the camera gets a cap.
void _tube(Canvas canvas, _Cam cam, _P3 a, _P3 b, double ra, double rb, Color color,
    {double opacity = 1, Color? capColor, bool caps = true, BlendMode? blend}) {
  final (u, v) = _perp(a, b);
  final ringA = _ring(cam, a, u, v, ra);
  final ringB = _ring(cam, b, u, v, rb);
  final hull = _hull([...ringA, ...ringB]);
  final pa = cam.q(a), pb = cam.q(b);
  var axis = pb - pa;
  if (axis.distance < 0.01) axis = const Offset(1, 0);
  final n = Offset(-axis.dy, axis.dx) / axis.distance;
  final mid = Offset.lerp(pa, pb, 0.5)!;
  var lo = 0.0, hi = 0.0;
  for (final p in [...ringA, ...ringB]) {
    final d = (p - mid).dx * n.dx + (p - mid).dy * n.dy;
    lo = math.min(lo, d);
    hi = math.max(hi, d);
  }
  final paint = Paint()
    ..shader = ui.Gradient.linear(
      mid + n * lo,
      mid + n * hi,
      [
        _a(labShade(color, 0.3), opacity),
        _a(color, opacity),
        _a(labShade(color, -0.4), opacity),
      ],
      const [0.0, 0.4, 1.0],
    );
  if (blend != null) paint.blendMode = blend;
  canvas.drawPath(hull, paint);
  if (!caps) return;
  // Visible end cap: the end whose outward normal faces the camera.
  final dx = b.$1 - a.$1, dy = b.$2 - a.$2, dz = b.$3 - a.$3;
  final facesB = dx * (cam.px - b.$1) + dy * (cam.py - b.$2) + dz * (cam.pz - b.$3) > 0;
  canvas.drawPath(
    Path()..addPolygon(facesB ? ringB : ringA, true),
    Paint()..color = _a(capColor ?? labShade(color, 0.15), opacity),
  );
}

// ============================================================ PAINTER

class _OpticsPainter extends CustomPainter {
  _OpticsPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labels,
  }) : super(repaint: repaint);

  final _OpticsScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> labels;

  String _l(String key) => labels[key] ?? key;

  double _tri(double t, double half) {
    final p = (t / half) % 2;
    return p < 1 ? p : 2 - p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.camera();
    _room(canvas, size, cam);
    _table(canvas, cam);
    if (scene.scenario == 0) {
      _paintMatchboxes(canvas, cam);
    } else {
      _paintPipe(canvas, cam);
    }
  }

  void _room(Canvas canvas, Size size, _Cam cam) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1120), Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFF1E293B), Color(0xFF273449), Color(0xFF334155)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final floor = cam.poly(const [(-120, -15, -60), (120, -15, -60), (120, -15, 50), (-120, -15, 50)]);
    if (floor != null) {
      canvas.drawPath(floor, Paint()..color = isDark ? const Color(0xFF111827) : const Color(0xFF1F2937));
    }
    labGlow(canvas, cam.p(0, -4.5, 0), 420, const Color(0xFF6366F1), intensity: 0.12);
  }

  /// HTML `createTable()`: 50 × 1 × 20 top on four legs.
  void _table(Canvas canvas, _Cam cam) {
    for (final (x, z) in const [(-23.0, -8.0), (23.0, -8.0), (-23.0, 8.0), (23.0, 8.0)]) {
      _tube(canvas, cam, (x, -15, z), (x, -5.5, z), 0.5, 0.5, const Color(0xFF475569), caps: false);
    }
    _box(canvas, cam, 0, -5, 0, 50, 1, 20, const Color(0xFF94A3B8));
  }

  void _label(Canvas canvas, String text, Offset at, {double opacity = 1}) {
    if (!showLabels) return;
    labText(
      canvas,
      text,
      at,
      size: 13,
      color: Colors.white,
      weight: FontWeight.w700,
      background: const Color(0xCC0F172A),
      border: const Color(0x80334155),
      borderWidth: 1,
      radius: 5,
      opacity: opacity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }

  void _hintGlow(Canvas canvas, Offset c, double r) {
    final p = _tri(scene.time, 0.75);
    labGlow(canvas, c, r * (1 + 0.08 * p), _Colors.zslYellow, intensity: 0.2 + 0.18 * p);
  }

  // ===================================================== SCENARIO 1

  void _paintMatchboxes(Canvas canvas, _Cam cam) {
    final s = scene;
    final t = s.time;
    // Glowing outlines on the table (HTML wireframe boxes).
    for (var i = 0; i < 3; i++) {
      final x = _trayX[i];
      final path = cam.poly([(x - 0.7, -4.48, -2.2), (x + 0.7, -4.48, -2.2), (x + 0.7, -4.48, 2.2), (x - 0.7, -4.48, 2.2)]);
      if (path == null) continue;
      final glow = s.snapped[i] ? 0.25 : 0.55 + 0.35 * _tri(t, 0.8);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.white.withValues(alpha: 0.18 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      labDashedPath(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: glow),
        dash: 6,
        gap: 4,
        phase: t * 12,
      );
    }

    // Everything along the beam, drawn far → near (the camera is at x < -20).
    final items = <(double, VoidCallback)>[];
    double depth(double x, double y, double z) => cam.toCam(x, y, z).$3;
    items.add((depth(20, -0.5, 0), () => _screen(canvas, cam)));
    for (var i = 0; i < 3; i++) {
      final tr = s.trays[i];
      items.add((depth(tr.x, tr.y, tr.z), () => _tray(canvas, cam, i)));
    }
    items.add((depth(-20, _beamY, 0), () => _torch(canvas, cam)));
    if (s.torchOn) {
      final end = s.beamBlocked ? s.trays[1].x - 0.45 : 19.45;
      final stops = [-15.55, ..._trayX.where((x) => x < end), end];
      for (var i = 0; i + 1 < stops.length; i++) {
        final a = stops[i], b = stops[i + 1];
        items.add((depth((a + b) / 2, _beamY, 0), () => _beam(canvas, cam, a, b)));
      }
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final it in items) {
      it.$2();
    }

    if (showLabels) {
      _label(canvas, _l('obj_screen'), cam.p(20, 5.5, 0));
      _label(canvas, _l('obj_torch'), cam.p(-20, _beamY + 4, 0));
      for (final tr in s.trays) {
        _label(canvas, _l('obj_tray'), cam.p(tr.x, tr.y + 3.5, tr.z));
      }
    }
  }

  /// Cardboard screen (1 × 8 × 8) with the light spot when the path is clear.
  void _screen(Canvas canvas, _Cam cam) {
    final s = scene;
    _box(canvas, cam, 20, -0.5, 0, 1, 8, 8, const Color(0xFFDEB887));
    if (s.torchOn && !s.beamBlocked) {
      final fade = ((s.time - s.torchOnAt) / 0.25).clamp(0.0, 1.0);
      final c = cam.p(19.45, _beamY, 0);
      final k = cam.k(19.45, _beamY, 0);
      labGlow(canvas, c, 3.2 * k, const Color(0xFFFFFBEB), intensity: 0.8 * fade);
      canvas.drawPath(
        Path()..addPolygon(_ring(cam, (19.45, _beamY, 0), (0, 1, 0), (0, 0, 1), 1.2), true),
        Paint()..color = Colors.white.withValues(alpha: 0.9 * fade),
      );
    }
  }

  /// Matchbox tray standing across the beam: a 4 × 4 card (thickness 0.8)
  /// with a 1.5 × 1.5 hole at its centre.
  void _tray(Canvas canvas, _Cam cam, int i) {
    final s = scene;
    final tr = s.trays[i];
    var sc = 1.0;
    if (i == 1 && s.pulseMiddle) sc = 1 + 0.1 * _tri(s.time, 0.5);
    if (s.dragging == 'tray$i') sc = 1.05;
    final cx = tr.x, cy = tr.y, cz = tr.z;
    final k = cam.k(cx, cy, cz);
    final c = cam.p(cx, cy, cz);
    if ((s.step == 1 && !s.snapped[i]) || (i == 1 && s.pulseMiddle)) _hintGlow(canvas, c, 3.6 * k);
    if (cy > -2.4) {
      // Floating above the table: soft shadow on the table top.
      labGroundShadow(canvas, cam.p(cx, -4.5, cz), 2.6 * k, 1.2 * k, opacity: 0.3);
    }
    const color = Color(0xFFCA8A04);
    final o = 1.375 * sc, b = 1.25 * sc, w = 4 * sc, t = 0.8 * sc;
    _box(canvas, cam, cx, cy, cz - o, t, 1.5 * sc, b, color);
    _box(canvas, cam, cx, cy - o, cz, t, b, w, color);
    _box(canvas, cam, cx, cy + o, cz, t, b, w, color);
    _box(canvas, cam, cx, cy, cz + o, t, 1.5 * sc, b, color);
    // Where a blocked beam hits the middle tray.
    if (i == 1 && s.torchOn && s.beamBlocked) {
      final hit = cam.p(cx - 0.45, _beamY, 0);
      labGlow(canvas, hit, 2.2 * k, const Color(0xFFFFFBEB), intensity: 0.75);
      canvas.drawCircle(hit, 0.45 * k, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  /// Torch (body, flared head, lens, switch) on a small stand.
  void _torch(Canvas canvas, _Cam cam) {
    final s = scene;
    const y = _beamY;
    _box(canvas, cam, -20, -4, 0, 3, 1, 2, const Color(0xFF334155));
    _tube(canvas, cam, (-22.5, y, 0), (-17.5, y, 0), 1, 1, const Color(0xFF4F46E5));
    _tube(canvas, cam, (-17.5, y, 0), (-15.6, y, 0), 1, 1.5, const Color(0xFF6366F1), caps: false);
    final lens = Path()..addPolygon(_ring(cam, (-15.55, y, 0), (0, 1, 0), (0, 0, 1), 1.4), true);
    canvas.drawPath(lens, Paint()..color = s.torchOn ? Colors.white : const Color(0xFFE2E8F0));
    final sw = cam.p(-20, y + 1.2, 0);
    final k = cam.k(-20, y + 1.2, 0);
    if (s.step == 2 && !s.torchOn) _hintGlow(canvas, sw, 2.2 * k);
    _box(canvas, cam, -20, y + 1.2, 0, 1, 0.5, 0.5, s.torchOn ? const Color(0xFF22C55E) : const Color(0xFFF8FAFC));
    if (s.torchOn) {
      labGlow(canvas, cam.p(-15.4, y, 0), 3.2 * cam.k(-15.4, y, 0), const Color(0xFFFFFBEB), intensity: 0.7);
    }
  }

  /// Volumetric beam segment from x = a to x = b (additive, opacity 0.5).
  void _beam(Canvas canvas, _Cam cam, double a, double b) {
    final grow = ((scene.time - scene.torchOnAt) / 0.25).clamp(0.0, 1.0);
    final start = -15.55;
    final end = start + (b - start) * grow;
    if (end <= a) return;
    _tube(canvas, cam, (a, _beamY, 0), (end, _beamY, 0), 0.5, 0.5, const Color(0x99FFF7C2),
        caps: false, blend: BlendMode.plus);
    _tube(canvas, cam, (a, _beamY, 0), (end, _beamY, 0), 0.22, 0.22, const Color(0xCCFFFFEE),
        caps: false, blend: BlendMode.plus);
  }

  // ===================================================== SCENARIO 2

  void _paintPipe(Canvas canvas, _Cam cam) {
    final s = scene;
    final t = s.time;
    final pp = s.pipe;
    final j = (pp.x, pp.y + s.jointY, pp.z);
    final e1 = (pp.x - 15, pp.y, pp.z), e2 = (pp.x + 15, pp.y, pp.z);
    final kp = cam.k(pp.x, pp.y, pp.z);
    if (s.step == 1) _hintGlow(canvas, cam.q(j), 6 * kp);
    if (pp.y > 1) labGroundShadow(canvas, cam.p(pp.x, -4.5, pp.z), 26 * kp, 2.5 * kp, opacity: 0.22);
    const grey = Color(0xFF94A3B8);
    _tube(canvas, cam, e1, j, 1, 1, grey, capColor: const Color(0xFF1E293B));
    _tube(canvas, cam, e2, j, 1, 1, grey, capColor: const Color(0xFF1E293B));
    // Open ends (dark bore).
    for (final e in [e1, e2]) {
      canvas.drawPath(
        Path()..addPolygon(_ring(cam, e, (0, 1, 0), (0, 0, 1), 0.75), true),
        Paint()..color = const Color(0xFF0F172A),
      );
    }
    // Blue joint / handle (pulses while it can be dragged).
    var jr = 1.2;
    if (s.pulseJoint) jr *= 1 + 0.2 * _tri(t, 0.5);
    if (s.dragging == 'joint' || s.dragging == 'pipe') jr *= 1.05;
    final jc = cam.q(j);
    if (s.pulseJoint) _hintGlow(canvas, jc, 3 * jr * kp);
    labSphere(canvas, jc, jr * cam.k(j.$1, j.$2, j.$3), _Colors.blue, highlight: 0.5);
    if (s.pulseJoint) {
      final up = s.step == 2;
      final a = jc.translate(-2.6 * kp, up ? 1.2 * kp : -1.2 * kp);
      labArrow(canvas, a, a.translate(0, up ? -2.4 * kp : 2.4 * kp), color: _Colors.zslYellow, width: 3, head: 10);
    }
    // The eye and the candle sit at the pipe ends; draw them on top.
    _candle(canvas, cam, t);
    _eye(canvas, cam);
    if (showLabels) {
      _label(canvas, _l('obj_eye'), cam.p(-15, 3, 0));
      _label(canvas, _l('obj_candle'), cam.p(15, 2.5, 0));
      _label(canvas, _l('obj_pipe'), cam.p(j.$1, j.$2 + 2.5, j.$3));
    }
  }

  /// Candle on a holder; the flame flickers (HTML noise sin·cos).
  void _candle(Canvas canvas, _Cam cam, double t) {
    _tube(canvas, cam, (15, -4.5, 0), (15, -4.0, 0), 2, 2, const Color(0xFF78350F));
    _tube(canvas, cam, (15, -4.0, 0), (15, 0, 0), 0.6, 0.6, const Color(0xFFFFFDD0));
    final ms = t * 1000;
    final noise = math.sin(ms * 0.01) * math.cos(ms * 0.008);
    final base = cam.p(15, 0.05, 0);
    final k = cam.k(15, 0, 0);
    canvas.drawLine(base, base.translate(0, -0.25 * k), Paint()
      ..strokeWidth = 1.5
      ..color = const Color(0xFF292524));
    labGlow(canvas, base.translate(0, -0.6 * k), 6 * k * (1 + 0.2 * noise), const Color(0xFFFFAA00), intensity: 0.5);
    labFlame(canvas, base, 1.25 * k * (1 + 0.1 * noise), t);
  }

  /// Observer eye looking along the pipe (+x).
  void _eye(Canvas canvas, _Cam cam) {
    final c = cam.p(-15, 0, 0);
    final r = 1.5 * cam.k(-15, 0, 0);
    labSphere(canvas, c, r, Colors.white, highlight: 0.3, shade: 0.25, light: const Offset(-0.3, -0.5));
    final iris = Rect.fromCenter(center: c.translate(r * 0.62, 0), width: r * 0.42, height: r * 0.95);
    canvas.drawOval(
      iris,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF1D4ED8)])
            .createShader(iris),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(r * 0.7, 0), width: r * 0.2, height: r * 0.42),
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(c.translate(r * 0.6, -r * 0.18), r * 0.07, Paint()..color = Colors.white);
    // Upper eyelid line.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 1.06),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF334155),
    );
  }

  @override
  bool shouldRepaint(covariant _OpticsPainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// The "View Through Pipe" window: the flame fades and a dark blocker
/// slides up as the pipe bends (HTML `#pipe-flame` / `#pipe-blocker`).
class _PipeViewPainter extends CustomPainter {
  _PipeViewPainter({required this.scene, required Listenable repaint}) : super(repaint: repaint);

  final _OpticsScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide * 0.42;
    final ring = outer * 0.2;
    final inner = outer - ring;
    final bend = scene.bend;
    canvas.drawCircle(c, outer, Paint()..color = const Color(0xFF1E293B));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: inner)));
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final pulse = 0.75 + 0.25 * math.cos(scene.time * math.pi);
    final opacity = (1 - bend) * pulse;
    if (opacity > 0.01) {
      canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: opacity));
      labFlame(canvas, c.translate(0, inner * 0.5), inner * 1.2, scene.time);
      canvas.restore();
    }
    // Blocker: translateY((1 - bend) * 100%).
    final top = c.dy - inner + (1 - bend) * inner * 2;
    canvas.drawRect(Rect.fromLTRB(c.dx - inner, top, c.dx + inner, c.dy + inner), Paint()..color = const Color(0xFF0F172A));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PipeViewPainter old) => old.scene != scene;
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
