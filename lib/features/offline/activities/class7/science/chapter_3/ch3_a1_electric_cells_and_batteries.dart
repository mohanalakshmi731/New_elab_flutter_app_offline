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

/// Class 7 Science • Chapter 3 • Activity 1
/// Electric Cells & Batteries.
///
/// Native Flutter port of `Cl7S-Ch3-A1-Electric_Cells_and_Batteries.html`.
/// Mission 1: put two cells into a cutaway torch, first + to + (the lamp
/// stays dark), then rotate one so both point to the bulb and it glows.
/// Mission 2: load a toy car's side-by-side compartment, first the same way
/// (the car does not start), then opposite so the metal strip joins + to -
/// and the wheels spin.
class Ch3A1ElectricCellsAndBatteriesPage extends StatefulWidget {
  const Ch3A1ElectricCellsAndBatteriesPage({super.key});

  @override
  State<Ch3A1ElectricCellsAndBatteriesPage> createState() => _Ch3A1ElectricCellsAndBatteriesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, switchTap 2585, whoosh 1492.
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
  switchTap('switch.mp3'),
  whoosh('whoosh.mp3');

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

/// One running animation (stands in for a TWEEN.js tween).
class _Tween {
  _Tween(this.ms, this.apply, this.curve, this.done);
  final double ms;
  final void Function(double v) apply;
  final Curve curve;
  final VoidCallback? done;
  double t = 0;
}

/// Pan recognizer that only claims touches starting on a draggable object,
/// so drags on the empty canvas still reach the zoom / pan viewer.
class _GrabRecognizer extends PanGestureRecognizer {
  _GrabRecognizer();
  bool Function(Offset local)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && (canGrab?.call(event.localPosition) ?? false);
}

class _Ch3A1ElectricCellsAndBatteriesPageState extends State<Ch3A1ElectricCellsAndBatteriesPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tween> _tweens = [];
  late final Ticker _ticker;

  /// Bumped on every rebuild of the scenario so stale callbacks stop.
  int _gen = 0;

  /// HTML `State.step` (1-based).
  int _step = 1;

  /// Mission complete (HUD "Mission Complete!", observation popup).
  bool _done = false;

  /// Cover / cap animations in progress (blocks double toggles).
  bool _coverBusy = false;

  // Drag state.
  _Cell? _dragCell;
  bool _dragDevice = false;
  Offset _grab = Offset.zero;
  Offset _finger = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  _Torch get _torch => _scene.torch;
  _Car get _car => _scene.car;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _buildScenario(0);
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

  // -------------------------------------------------------- animation

  void _tick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    _stepTweens(dt * 1000);
    // HTML: the shelf device trails the pointer (lerp 0.1).
    if (_dragDevice) {
      final d = _scene.scenario == 0 ? _torch : null;
      final target = _finger - _grab;
      if (d != null) {
        d.ground += (target - d.ground) * 0.2;
      } else {
        _car.ground += (target - _car.ground) * 0.2;
      }
    }
    // HTML animate(): spinning wheels drive the car back and forth.
    if (_car.spinning) {
      _car.wheel -= 24 * dt;
      _car.run += 3 * dt;
      _car.ground = Offset(_Scene.carDesk.dx + math.sin(_car.run) * 6 * _car.k, _Scene.carDesk.dy);
    }
    _frame.value = t;
  }

  void _stepTweens(double dtMs) {
    if (_tweens.isEmpty) return;
    final finished = <_Tween>[];
    for (final tw in List.of(_tweens)) {
      tw.t += dtMs;
      final f = (tw.t / tw.ms).clamp(0.0, 1.0);
      tw.apply(tw.curve.transform(f));
      if (f >= 1) finished.add(tw);
    }
    finished.forEach(_tweens.remove);
    final g = _gen;
    for (final tw in finished) {
      if (g != _gen || !mounted) return;
      tw.done?.call();
    }
  }

  void _tween(int ms, void Function(double v) apply, {Curve curve = Curves.linear, VoidCallback? done}) {
    _tweens.add(_Tween(ms.toDouble(), apply, curve, done));
  }

  double _lerp(double a, double b, double v) => a + (b - a) * v;

  /// Virtual camera tween (HTML camera position / controls.target).
  void _camTo(Offset focus, double zoom, double el, {int ms = 1000, Curve curve = Curves.easeInOutCubic}) {
    final f0 = _scene.focus, z0 = _scene.zoom, e0 = _scene.el;
    _tween(ms, (v) {
      _scene.focus = Offset.lerp(f0, focus, v)!;
      _scene.zoom = _lerp(z0, zoom, v);
      _scene.el = _lerp(e0, el, v);
    }, curve: curve);
  }

  void _zoomOnDevice() {
    final x = _scene.scenario == 0 ? 585.0 : _car.ground.dx + 20;
    _camTo(Offset(x, 398), 1.25, _elZoom);
  }

  // -------------------------------------------------------- scenarios

  /// HTML `loadScenario` + `resetScene` + `resetScenePositions`.
  void _buildScenario(int s) {
    _gen++;
    _tweens.clear();
    _lab.cancelPending();
    _step = 1;
    _done = false;
    _coverBusy = false;
    _dragCell = null;
    _dragDevice = false;
    _scene.reset(s);
    // HTML camera settles from (0, 14, 20) to (0, 12, 18).
    _camTo(_viewCenter, 1, _elBase, curve: Curves.easeOutCubic);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _buildScenario(index);
    });
  }

  /// Full "Reset Lab" (HTML `fullReset`): back to mission 1.
  void _fullReset() {
    setState(() => _buildScenario(0));
    // Workaround: the shell builds "Enter Lab" disabled while the curtain
    // is closing and nothing rebuilds it afterwards. A no-op notification
    // after the 1.5 s curtain animation re-enables the button.
    for (final ms in const [1700, 2300]) {
      _lab.after(Duration(milliseconds: ms), () {
        if (!_lab.isLabActive) _lab.markLabActive(false);
      });
    }
  }

  // ------------------------------------------------------- validation

  void _error(String key) => _lab.showToast(_t(key), isError: true);

  /// HTML `showValidationOverlay`.
  void _badge(bool ok) {
    final at = _scene.scenario == 0
        ? _scene.torchPoint(0)
        : _scene.view(_car.ground, _car.k).proj(_car.xf(const _V3(1.0, 0.29, 0)));
    _scene.badge = _Badge(ok, at, _scene.time);
    _Audio.play(ok ? _Sound.correct : _Sound.wrong);
  }

  /// HTML `checkCurrentStepValidation(fromAction)`.
  void _check([String? from]) {
    if (!mounted) return;
    if (_scene.scenario == 0) {
      final t = _torch;
      final c0 = t.slots[0], c1 = t.slots[1];
      switch (_step) {
        case 1:
          if (t.open && !t.onShelf) {
            _zoomOnDevice();
            _advance('toastTorchOpened');
          }
        case 2:
          if (c0 != null && c1 != null) {
            if (c0.orientation == -1 && c1.orientation == 1) {
              _badge(false);
              _advance('toastIncorrectPlus');
            } else if (from == 'drop') {
              _error('toastErrorPlus');
            }
          }
        case 3:
          if (!t.open && t.on && !t.light) {
            _toggleTorchSwitch();
            _advance('toastLampNoGlow');
          }
        case 4:
          if (t.open && c0 != null && c1 != null) {
            if (c0.orientation == 1 && c1.orientation == 1) {
              _badge(true);
              _advance('toastProperConn');
            } else if (from == 'drop') {
              _error('toastErrorAlign');
            }
          }
        case 5:
          if (!t.open && t.on && t.light) _advance('toastComplete');
        case 6:
          _complete();
      }
      return;
    }
    final car = _car;
    final c0 = car.slots[0], c1 = car.slots[1];
    switch (_step) {
      case 1:
        if (car.open && !car.onShelf) {
          _zoomOnDevice();
          _advance('toastCarOpened');
        }
      case 2:
        if (c0 != null && c1 != null) {
          if (c0.orientation == c1.orientation) {
            _badge(false);
            _advance('toastIncorrectPlus');
          } else if (from == 'drop') {
            _error('toastErrorSameDir');
          }
        }
      case 3:
        if (!car.open && car.on && !car.spinning) {
          _toggleCarSwitch();
          _advance('toastCarNoStart');
        }
      case 4:
        if (car.open && c0 != null && c1 != null) {
          if (c0.orientation != c1.orientation) {
            // Green current path flashes along the metal strip.
            car.green = 0.8;
            _lab.after(const Duration(milliseconds: 500), () {
              if (mounted) _tween(1500, (v) => car.green = 0.8 * (1 - v));
            });
            _badge(true);
            _advance('toastPerfectPol');
          } else if (from == 'drop') {
            _error('toastErrorFlip');
          }
        }
      case 5:
        if (!car.open && car.on && car.spinning) _advance('toastWheelsSpin');
      case 6:
        _complete();
    }
  }

  /// HTML `advanceStep(msg)`.
  void _advance(String key) {
    _lab.showToast(_t(key));
    setState(() => _step++);
    if (_step == 6) {
      final ready = _scene.scenario == 0
          ? (!_torch.open && _torch.on && _torch.light)
          : (!_car.open && _car.on && _car.spinning);
      if (ready) _check();
    }
  }

  /// Step 6: "Mission Complete!", sidebar opens, observation popup after 2.5 s.
  void _complete() {
    if (_done) return;
    setState(() => _done = true);
    _lab.openSidebar();
    _Audio.play(_Sound.success);
    final g = _gen, s = _scene.scenario;
    _lab.after(const Duration(milliseconds: 2500), () {
      if (!mounted || g != _gen) return;
      _showObservation(s);
    });
  }

  // ---------------------------------------------------------- devices

  /// HTML `toggleTorchCap`.
  void _toggleTorchCap() {
    if (_scene.scenario != 0 || _coverBusy) return;
    final t = _torch;
    if (t.onShelf) {
      _error('bringTorchFirst');
      return;
    }
    setState(() => t.open = !t.open);
    _Audio.play(_Sound.whoosh);
    _coverBusy = true;
    final x0 = t.capX, x1 = t.open ? 4.5 : 2.8;
    _tween(400, (v) => t.capX = _lerp(x0, x1, v), curve: Curves.easeOutBack, done: () {
      _coverBusy = false;
      _check('cap');
    });
  }

  /// HTML `toggleTorchSwitch`: the lamp glows only with both cells
  /// pointing to the bulb.
  void _toggleTorchSwitch() {
    if (_scene.scenario != 0) return;
    final t = _torch;
    if (t.open) {
      _error('cannotSwitchCap');
      return;
    }
    _Audio.play(_Sound.switchTap);
    final c0 = t.slots[0], c1 = t.slots[1];
    setState(() {
      t.on = !t.on;
      t.light = t.on && c0 != null && c1 != null && c0.orientation == 1 && c1.orientation == 1;
    });
    final x0 = t.switchX, x1 = t.on ? -0.35 : -0.65;
    _tween(100, (v) => t.switchX = _lerp(x0, x1, v));
    final g = _gen;
    _lab.after(const Duration(milliseconds: 150), () {
      if (g == _gen) _check('switch');
    });
  }

  /// HTML `toggleCarCover`: the car flips over and the bottom cover swings
  /// open (or closes, then the car flips back upright).
  void _toggleCarCover() {
    if (_scene.scenario != 1 || _coverBusy) return;
    final car = _car;
    if (car.onShelf) {
      _error('bringCarFirst');
      return;
    }
    setState(() => car.open = !car.open);
    _Audio.play(_Sound.whoosh);
    _coverBusy = true;
    final f0 = car.flip, c0 = car.cover;
    if (car.open) {
      _tween(500, (v) => car.flip = _lerp(f0, math.pi, v), curve: Curves.easeInOutQuad);
      _tween(400, (v) => car.cover = _lerp(c0, -math.pi / 2, v), curve: Curves.easeOutBack, done: () {
        _coverBusy = false;
        _check('cover');
      });
      if (car.on) {
        car
          ..on = false
          ..switchX = -0.3
          ..spinning = false;
      }
      _zoomOnDevice();
    } else {
      _tween(400, (v) => car.cover = _lerp(c0, 0, v), curve: Curves.easeOutBack, done: () {
        _tween(500, (v) => car.flip = _lerp(f0, 0, v), curve: Curves.easeInOutQuad, done: () {
          _coverBusy = false;
          _check('cover');
        });
      });
    }
  }

  /// HTML `toggleCarSwitch`: wheels spin only with opposite cells.
  void _toggleCarSwitch() {
    if (_scene.scenario != 1) return;
    final car = _car;
    if (car.open) {
      _error('cannotSwitchCover');
      return;
    }
    _Audio.play(_Sound.switchTap);
    final c0 = car.slots[0], c1 = car.slots[1];
    setState(() {
      car.on = !car.on;
      car.spinning = car.on && c0 != null && c1 != null && c0.orientation != c1.orientation;
    });
    final x0 = car.switchX, x1 = car.on ? -0.1 : -0.3;
    _tween(100, (v) => car.switchX = _lerp(x0, x1, v));
    final g = _gen;
    _lab.after(const Duration(milliseconds: 150), () {
      if (g == _gen) _check('switch');
    });
  }

  /// HTML `flipSelectedBattery`.
  void _rotateCell() {
    final id = _scene.selected;
    if (id == null) return;
    final cell = _scene.cells[id];
    _Audio.play(_Sound.whoosh);
    setState(() => cell.orientation *= -1);
    final r0 = cell.rotY, r1 = cell.orientation == 1 ? 0.0 : math.pi;
    _tween(300, (v) => cell.rotY = _lerp(r0, r1, v), curve: Curves.easeInOutQuad, done: () => _check('drop'));
  }

  // ------------------------------------------------------------ cells

  /// HTML `removeFromSlot` + extraction to world space.
  void _lift(_Cell c) {
    final ctr = _scene.cellCenter(c);
    if (c.device != null) {
      final fromCar = c.device == 'car';
      (fromCar ? _car.slots : _torch.slots)[c.slot] = null;
      c
        ..device = null
        ..slot = -1;
      if (fromCar) {
        c.rotX = _car.flip;
        final r0 = c.rotX;
        _tween(200, (v) => c.rotX = _lerp(r0, 0, v));
      }
    }
    c
      ..box = null
      ..free = ctr;
  }

  /// HTML `checkSnap`: first free slot within 2.5 units. In mission 1,
  /// step 2 the torch forces the + to + arrangement.
  bool _snap(_Cell c) {
    final ctr = c.free!;
    final String dev;
    final List<_Cell?> slots;
    final double k;
    if (_scene.scenario == 0) {
      if (!_torch.open || _torch.onShelf) return false;
      dev = 'torch';
      slots = _torch.slots;
      k = _torch.k;
    } else {
      if (!_car.open || _car.onShelf) return false;
      dev = 'car';
      slots = _car.slots;
      k = _car.k;
    }
    for (var i = 0; i < 2; i++) {
      if (slots[i] != null) continue;
      final target = _scene.slotCenter(dev, i);
      if ((ctr - target).distance >= 2.5 * k) continue;
      if (dev == 'torch' && _step == 2) c.orientation = i == 0 ? -1 : 1;
      slots[i] = c;
      c
        ..device = dev
        ..slot = i;
      final r0 = c.rotY, r1 = c.orientation == 1 ? 0.0 : math.pi;
      final x0 = c.rotX, x1 = dev == 'car' ? _car.flip : 0.0;
      _tween(300, (v) {
        c.free = Offset.lerp(ctr, _scene.slotCenter(dev, i), v);
        c.rotY = _lerp(r0, r1, v.clamp(0.0, 1.0));
        c.rotX = _lerp(x0, x1, v.clamp(0.0, 1.0));
      }, curve: Curves.easeOutBack, done: () {
        c
          ..free = null
          ..rotX = 0;
      });
      _Audio.play(_Sound.pop);
      return true;
    }
    return false;
  }

  /// Not snapped: the cell rests on the desk (back in the box if dropped
  /// over it).
  void _land(_Cell c) {
    final ctr = c.free!;
    c.free = null;
    final boxArea = Rect.fromCenter(center: _boxGround - const Offset(0, 14), width: 4.2 * _kDesk, height: 3.0 * _kDesk);
    final used = _scene.cells.where((o) => o != c && o.box != null).map((o) => o.box).toSet();
    if (boxArea.contains(ctr) && used.length < 2) {
      final a = _scene.view(_boxGround, _kDesk).proj(_V3(0, 0.65, _Scene.boxZ(0)));
      final b = _scene.view(_boxGround, _kDesk).proj(_V3(0, 0.65, _Scene.boxZ(1)));
      var slot = (ctr - a).distance <= (ctr - b).distance ? 0 : 1;
      if (used.contains(slot)) slot = 1 - slot;
      c.box = slot;
      return;
    }
    final g = ctr + Offset(0, 0.45 * math.cos(_scene.el) * _kDesk);
    c.ground = Offset(g.dx.clamp(40.0, 930.0), g.dy.clamp(_deskBack + 14, 540.0));
  }

  /// Topmost cell under [w] (design coordinates).
  _Cell? _cellAt(Offset w) {
    final open = _scene.scenario == 0 ? true : _car.flip > math.pi / 2;
    _Cell? best;
    var bestY = -1e9;
    for (final c in _scene.cells) {
      if (c.free != null && !c.dragging) continue;
      if (c.device == 'car' && !open) continue;
      final r = _scene.cellBounds(c);
      if (r.inflate(4).contains(w) && r.center.dy > bestY) {
        best = c;
        bestY = r.center.dy;
      }
    }
    return best;
  }

  // --------------------------------------------------------- gestures

  bool _canGrab(Offset local) {
    if (!_lab.isLabActive || _lab.panMode || _dragCell != null || _dragDevice) return false;
    final w = _scene.toWorld(local);
    if (_scene.scenario == 0 && !_torch.onShelf && (_scene.torchCapRect.contains(w) || _scene.torchSwitchRect.contains(w))) {
      return false;
    }
    if (_cellAt(w) != null) return true;
    if (_scene.scenario == 0) return _torch.onShelf && _scene.torchBody.contains(w);
    return _car.onShelf && _scene.carBody.contains(w);
  }

  void _onPanStart(DragStartDetails d) {
    final w = _scene.toWorld(d.localPosition);
    _finger = w;
    final cell = _cellAt(w);
    _Audio.play(_Sound.pop);
    if (cell != null) {
      setState(() {
        _scene.selected = cell.id;
        _lift(cell);
        cell.dragging = true;
        _dragCell = cell;
        _grab = w - cell.free!;
      });
      return;
    }
    setState(() {
      _scene.selected = null;
      _dragDevice = true;
      final g = _scene.scenario == 0 ? _torch.ground : _car.ground;
      _grab = w - g;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _finger = _scene.toWorld(d.localPosition);
    final c = _dragCell;
    if (c != null) c.free = _finger - _grab;
  }

  void _onPanEnd([DragEndDetails? d]) {
    final c = _dragCell;
    if (c != null) {
      c.dragging = false;
      _dragCell = null;
      if (!_snap(c)) {
        _land(c);
        _Audio.play(_Sound.pop);
      }
      setState(() {});
      _check('drop');
      return;
    }
    if (_dragDevice) {
      _dragDevice = false;
      _deviceToDesk();
      _check('drop');
    }
  }

  /// HTML onPointerUp for the torch / car: bounces onto the workbench.
  void _deviceToDesk() {
    final s1 = _scene.scenario == 0;
    if (s1 ? !_torch.onShelf : !_car.onShelf) return;
    final g0 = s1 ? _torch.ground : _car.ground;
    final k0 = s1 ? _torch.k : _car.k;
    final g1 = s1 ? _Scene.torchDesk : _Scene.carDesk;
    setState(() {
      if (s1) {
        _torch.onShelf = false;
      } else {
        _car.onShelf = false;
      }
    });
    _Audio.play(_Sound.whoosh);
    _tween(400, (v) {
      final g = Offset.lerp(g0, g1, v)!;
      final k = _lerp(k0, _kDesk, v.clamp(0.0, 1.0));
      if (s1) {
        _torch
          ..ground = g
          ..k = k;
      } else {
        _car
          ..ground = g
          ..k = k;
      }
    }, curve: Curves.bounceOut);
  }

  /// Taps: clickable parts first (HTML raycast on cap / switch / cover),
  /// then cells, then the device body; empty space clears the selection.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final w = _scene.toWorld(d.localPosition);
    if (_scene.scenario == 0 && !_torch.onShelf) {
      if (_scene.torchCapRect.contains(w)) return _toggleTorchCap();
      if (_scene.torchSwitchRect.contains(w)) return _toggleTorchSwitch();
    }
    if (_scene.scenario == 0 && _torch.onShelf && _scene.torchCapRect.contains(w)) return _toggleTorchCap();
    if (_scene.scenario == 1) {
      if (_car.flip < math.pi / 2 && _scene.carSwitchRect.contains(w)) return _toggleCarSwitch();
      final open = _car.flip > math.pi / 2;
      if (!open && _scene.carCoverRect.contains(w)) return _toggleCarCover();
      if (open && _cellAt(w) == null && _scene.carCoverRect.contains(w)) return _toggleCarCover();
    }
    final cell = _cellAt(w);
    if (cell != null) {
      _Audio.play(_Sound.pop);
      setState(() {
        _scene.selected = cell.id;
        _lift(cell);
      });
      if (!_snap(cell)) _land(cell);
      setState(() {});
      _check('drop');
      return;
    }
    final onDevice = _scene.scenario == 0 ? _scene.torchBody.contains(w) : _scene.carBody.contains(w);
    if (onDevice) {
      _Audio.play(_Sound.pop);
      setState(() => _scene.selected = null);
      _deviceToDesk();
      _check('drop');
      return;
    }
    if (_scene.selected != null) setState(() => _scene.selected = null);
  }

  // ---------------------------------------------------------------- UI

  /// HTML `#action-buttons` for the current state.
  List<LabAction> _actions() {
    const slate = Color(0xFF334155);
    final out = <LabAction>[];
    if (_scene.selected != null) {
      out.add(LabAction(
        label: _t('btnRotate'),
        icon: Icons.sync,
        color: _Colors.indigo600,
        foreground: Colors.white,
        silent: true,
        onTap: _rotateCell,
      ));
    }
    if (_scene.scenario == 0 && !_torch.onShelf) {
      out.add(LabAction(
        label: _t(_torch.open ? 'btnCloseCap' : 'btnOpenCap'),
        icon: _torch.open ? Icons.compress : Icons.open_in_full,
        color: slate,
        foreground: Colors.white,
        silent: true,
        onTap: _toggleTorchCap,
      ));
      if (!_torch.open) {
        out.add(LabAction(
          label: _t(_torch.on ? 'btnSwitchOff' : 'btnSwitchOn'),
          icon: Icons.power_settings_new,
          silent: true,
          highlight: !_torch.on && (_step == 3 || _step == 5),
          onTap: _toggleTorchSwitch,
        ));
      }
    } else if (_scene.scenario == 1 && !_car.onShelf) {
      out.add(LabAction(
        label: _t(_car.open ? 'btnCloseCover' : 'btnOpenLatch'),
        icon: _car.open ? Icons.check_box_outline_blank : Icons.web_asset,
        color: slate,
        foreground: Colors.white,
        silent: true,
        onTap: _toggleCarCover,
      ));
      if (!_car.open) {
        out.add(LabAction(
          label: _t(_car.on ? 'btnSwitchOff' : 'btnSwitchOn'),
          icon: Icons.power_settings_new,
          silent: true,
          highlight: !_car.on && (_step == 3 || _step == 5),
          onTap: _toggleCarSwitch,
        ));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _scenarios[_lab.lang.code]![_scene.scenario];
        final actions = _actions();
        return LabShell(
          controller: _lab,
          icon: Icons.battery_charging_full,
          title: _t('title'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('m1'), _t('m2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          instruction: _done ? _t('missionComplete') : null,
          actions: actions,
          onReset: _fullReset,
          showHud: false,
          overlays: [if (_lab.isSidebarOpen && _lab.isLabActive) _hud(context, data, actions)],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _GrabRecognizer: GestureRecognizerFactoryWithHandlers<_GrabRecognizer>(
                  _GrabRecognizer.new,
                  (r) => r
                    ..canGrab = _canGrab
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 8)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..onStart = _onPanStart
                    ..onUpdate = _onPanUpdate
                    ..onEnd = _onPanEnd
                    ..onCancel = _onPanEnd,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r..onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _BenchPainter(
                  scene: _scene,
                  repaint: _frame,
                  boxText: _t('supplyBoxText'),
                  showLabels: _lab.showLabels,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML bottom HUD: "Action Guide", the current step's action (green
  /// "Mission Complete!" at the end) and the context buttons (Rotate Cell,
  /// cap / cover, switch) right under it, so they stay in reach while the
  /// sidebar is open. With the sidebar collapsed the shell's floating
  /// mission card shows the same instruction and buttons.
  Widget _hud(BuildContext context, LabScenarioData data, List<LabAction> actions) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final inset = labOverlayInsets(context, _lab);
    final text = _done ? _t('missionComplete') : data.steps[(_step - 1).clamp(0, data.steps.length - 1)].action;
    return Positioned(
      left: inset.left + 4,
      right: inset.right,
      bottom: inset.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560 * s),
          child: LabGlassCard(
            palette: p,
            radius: 16,
            padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 8 * s),
            borderColor: _Colors.zslYellow.withValues(alpha: 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, size: 13 * s, color: _Colors.zslYellow),
                    SizedBox(width: 5 * s),
                    Flexible(
                      child: Text(
                        _t('actionGuide').toUpperCase(),
                        style: TextStyle(
                          color: _Colors.zslYellow,
                          fontWeight: FontWeight.w900,
                          fontSize: 9 * s,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3 * s),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _done ? _Colors.green : p.textStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5 * f,
                    height: 1.3,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6 * s,
                    runSpacing: 6 * s,
                    children: [
                      for (final a in actions) LabActionButton(action: a, scale: s * 0.9, expand: false, dense: true),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML observation popup ("Key Findings" + circuit diagram) with the
  /// shell's Continue / Restart Lab handling.
  void _showObservation(int idx) {
    _lab.completedScenarios.add(idx);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.openSidebar();
    _lab.showPopup(() {
      final dark = _lab.isDark;
      return LabPopupContent(
        title: _t('observation'),
        icon: Icons.lightbulb,
        heading: _t('keyFindings'),
        body: _t(idx == 0 ? 's1con' : 's2con'),
        extra: Container(
          height: 104,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF111111) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dark ? const Color(0xFF333333) : const Color(0xFFCBD5E1), width: 2),
          ),
          child: CustomPaint(painter: _DiagramPainter(scenario: idx, dark: dark, time: _frame)),
        ),
        actions: [
          if (allDone)
            LabAction(label: _lab.t('btn_restart'), icon: Icons.restart_alt, onTap: _lab.requestFullReset)
          else
            LabAction(
              label: _lab.t('btn_continue'),
              icon: Icons.arrow_forward,
              color: _Colors.indigo600,
              foreground: Colors.white,
              onTap: () {
                _lab.hidePopup(sound: false);
                _lab.showToast(_lab.t('msg_scenario_complete'));
              },
            ),
        ],
      );
    }, sound: _Sound.whoosh);
  }
}

// ============================================================ STRINGS
//
// From the HTML `Translations` table (Telugu dropped). KaTeX `$+$` / `$-$`
// in the conclusions are written as plain (+) / (−).

const LabStringTable _i18n = {
  'en': {
    'title': 'Electric Cells & Batteries',
    'subtitle': 'Class 7 • Electricity: Circuits and their Components',
    'm1': '1. The Torchlight Challenge',
    'm2': '2. The Side-by-Side Mystery',
    'actionGuide': 'Action Guide',
    'missionAcc': 'Mission Accomplished',
    'observation': 'Observation',
    'keyFindings': 'Key Findings:',
    'circuitBuilt': 'Circuit correctly built! Check popup for details.',
    'btnRotate': 'Rotate Cell',
    'btnOpenCap': 'Open Cap',
    'btnCloseCap': 'Close Cap',
    'btnSwitchOn': 'Switch ON',
    'btnSwitchOff': 'Switch OFF',
    'btnOpenLatch': 'Open Compartment',
    'btnCloseLatch': 'Close Compartment',
    'btnOpenCover': 'Open Cover',
    'btnCloseCover': 'Close Cover',
    'supplyBoxText': 'BATTERIES',
    'toastTorchOpened': 'Torch opened.',
    'toastCarOpened': 'Compartment opened.',
    'toastIncorrectPlus': "Incorrect (+ to +). Let's verify.",
    'toastErrorPlus': 'Place them so positive (+) caps touch.',
    'toastErrorSameDir': 'Make sure cells face SAME direction.',
    'toastLampNoGlow': 'Lamp does not glow.',
    'toastCarNoStart': "Car doesn't start.",
    'toastProperConn': 'Cells properly connected (+ to -).',
    'toastErrorAlign': 'Make sure BOTH cells point RIGHT towards the bulb! (+ touching -).',
    'toastPerfectPol': 'Perfect! Polarity corrected.',
    'toastErrorFlip': 'Flip one cell to complete series.',
    'toastComplete': 'Circuit is complete!',
    'toastWheelsSpin': 'Wheels are spinning!',
    'missionComplete': 'Mission Complete!',
    'bringTorchFirst': 'Bring the torch to the workbench first.',
    'cannotSwitchCap': 'Cannot switch on while cap is open.',
    'bringCarFirst': 'Bring the car to the workbench first.',
    'cannotSwitchCover': 'Cannot switch on while cover is open.',
    's1con':
        'Success! A battery works when cells are connected from positive (+) to negative (−). This creates a continuous path for the electrical energy to flow, completing the circuit and powering the lamp.',
    's2con':
        'Well done! The metal strip connects the cells from positive (+) to negative (−) to complete the circuit, ensuring energy flows properly to the motor.',
  },
  'hi': {
    'title': 'विद्युत सेल और बैटरी',
    'subtitle': 'कक्षा 7 • विद्युत: परिपथ और उनके घटक',
    'm1': '1. टॉर्चलाइट चुनौती',
    'm2': '2. अगल-बगल का रहस्य',
    'actionGuide': 'कार्य निर्देशिका',
    'missionAcc': 'मिशन संपन्न',
    'observation': 'अवलोकन',
    'keyFindings': 'मुख्य निष्कर्ष:',
    'circuitBuilt': 'परिपथ सही ढंग से बनाया गया! विवरण के लिए पॉपअप देखें।',
    'btnRotate': 'सेल घुमाएँ',
    'btnOpenCap': 'कैप खोलें',
    'btnCloseCap': 'कैप बंद करें',
    'btnSwitchOn': 'स्विच चालू करें',
    'btnSwitchOff': 'स्विच बंद करें',
    'btnOpenLatch': 'कम्पार्टमेंट खोलें',
    'btnCloseLatch': 'कम्पार्टमेंट बंद करें',
    'btnOpenCover': 'कवर खोलें',
    'btnCloseCover': 'कवर बंद करें',
    'supplyBoxText': 'बैटरी',
    'toastTorchOpened': 'टॉर्च खुल गई।',
    'toastCarOpened': 'कम्पार्टमेंट खुल गया।',
    'toastIncorrectPlus': 'गलत (+ से +)। आइए सत्यापित करें।',
    'toastErrorPlus': 'उन्हें ऐसे रखें कि धनात्मक (+) सिरे एक दूसरे को छुएं।',
    'toastErrorSameDir': 'सुनिश्चित करें कि सेल एक ही दिशा में हों।',
    'toastLampNoGlow': 'लैंप नहीं जलता।',
    'toastCarNoStart': 'कार स्टार्ट नहीं होती।',
    'toastProperConn': 'सेल ठीक से जुड़े हैं (+ से -)।',
    'toastErrorAlign': 'सुनिश्चित करें कि दोनों सेल दाईं ओर बल्ब की तरफ हैं! (+ को - छूते हुए)।',
    'toastPerfectPol': 'उत्तम! ध्रुवीयता ठीक हो गई।',
    'toastErrorFlip': 'श्रृंखला पूरी करने के लिए एक सेल को पलटें।',
    'toastComplete': 'परिपथ पूरा हो गया!',
    'toastWheelsSpin': 'पहिए घूम रहे हैं!',
    'missionComplete': 'मिशन पूरा हुआ!',
    'bringTorchFirst': 'पहले टॉर्च को वर्कबेंच पर लाएं।',
    'cannotSwitchCap': 'कैप खुले होने पर स्विच चालू नहीं कर सकते।',
    'bringCarFirst': 'पहले कार को वर्कबेंच पर लाएं।',
    'cannotSwitchCover': 'कवर खुले होने पर स्विच चालू नहीं कर सकते।',
    's1con':
        'सफलता! बैटरी तब काम करती है जब सेल धनात्मक (+) से ऋणात्मक (−) तक जुड़े होते हैं। यह विद्युत ऊर्जा के प्रवाह के लिए एक निरंतर मार्ग बनाता है, परिपथ को पूरा करता है और लैंप को शक्ति प्रदान करता है।',
    's2con':
        'शाबाश! धातु की पट्टी परिपथ को पूरा करने के लिए सेलों को धनात्मक (+) से ऋणात्मक (−) तक जोड़ती है, यह सुनिश्चित करते हुए कि ऊर्जा मोटर तक ठीक से प्रवाहित हो।',
  },
};

/// HTML `getScenarios()`: each step's theory becomes the concept and its
/// action the instruction (`<br>` -> new line).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To understand how to correctly arrange two electric cells in series within a torchlight to make the lamp glow.',
      steps: [
        LabStep(
          concept: "A torchlight needs a power source to work. Let's start by bringing the torch from the shelf and opening it.",
          action: 'DRAG torch to desk. CLICK cap to open.',
        ),
        LabStep(
          concept:
              "Electric cells have a positive (+) and a negative (-) terminal. Let's see what happens if we place them incorrectly.",
          action: 'DRAG both cells into torch. Place them + to + (incorrectly).',
        ),
        LabStep(
          concept: 'An electric circuit needs to be completely connected with proper polarity to allow current to flow.',
          action: 'CLICK cap to close. CLICK switch ON.',
        ),
        LabStep(
          concept:
              'For the lamp to glow, both cells must face RIGHT towards the bulb! In series, the (+) terminal of the back cell touches the (-) base of the front cell.',
          action:
              "1. CLICK 'Open Cap'.\n2. CLICK the back/left battery cell inside the torch.\n3. CLICK 'Rotate Cell' so both (+) caps point RIGHT towards the bulb!",
        ),
        LabStep(
          concept: 'With cells arranged correctly in series, the circuit can now provide the necessary energy.',
          action: 'CLICK cap to close. CLICK switch ON.',
        ),
        LabStep(concept: 'Observe the working torch.', action: 'Observe the glowing torch.'),
      ],
    ),
    LabScenarioData(
      objective:
          'To correctly install cells in a device where they are placed side-by-side, understanding how a metal connector completes the series circuit.',
      steps: [
        LabStep(
          concept: "Many toys place cells side-by-side to save space. Let's open the compartment.",
          action: 'DRAG the toy car from the shelf to the workbench. CLICK on the battery compartment latch to open it.',
        ),
        LabStep(
          concept: "Following the molded - and + symbols, let's place them incorrectly first.",
          action: 'DRAG both cells from the supply box into the compartment so they are facing the SAME direction.',
        ),
        LabStep(
          concept: 'If cells face the same way, the metal strip connects identical terminals, cancelling the voltage.',
          action: "CLICK the battery cover to close it. CLICK the 'ON' switch.",
        ),
        LabStep(
          concept: 'Observe the molded symbols. The metal strip acts as a wire connecting opposite terminals.',
          action: 'CLICK compartment to open again. DRAG one cell out, ROTATE it, and DROP it back in correctly.',
        ),
        LabStep(
          concept: 'The circuit is correctly polarized. Electrical energy can flow to the motor.',
          action: "CLICK battery cover to close it. CLICK the 'ON' switch.",
        ),
        LabStep(concept: 'Observe the working car.', action: 'Observe the running car.'),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह समझने के लिए कि लैंप को जलाने के लिए टॉर्चलाइट के भीतर श्रृंखला में दो विद्युत सेलों को सही ढंग से कैसे व्यवस्थित किया जाए।',
      steps: [
        LabStep(
          concept: 'टॉर्चलाइट को काम करने के लिए एक शक्ति स्रोत की आवश्यकता होती है। आइए टॉर्च को शेल्फ से लाकर और खोलकर शुरू करें।',
          action: 'टॉर्च को डेस्क पर खींचें। खोलने के लिए कैप पर क्लिक करें।',
        ),
        LabStep(
          concept:
              'विद्युत सेलों में एक धनात्मक (+) और एक ऋणात्मक (-) टर्मिनल होता है। आइए देखें कि यदि हम उन्हें गलत तरीके से रखते हैं तो क्या होता है।',
          action: 'दोनों सेलों को टॉर्च में खींचें। उन्हें + से + (गलत तरीके से) रखें।',
        ),
        LabStep(
          concept: 'धारा प्रवाहित होने के लिए एक विद्युत परिपथ को उचित ध्रुवीयता के साथ पूरी तरह से जुड़ा होना चाहिए।',
          action: 'बंद करने के लिए कैप पर क्लिक करें। स्विच ऑन पर क्लिक करें।',
        ),
        LabStep(
          concept:
              'लैंप के जलने के लिए, दोनों सेलों को बल्ब की ओर दाईं तरफ होना चाहिए! श्रृंखला में, पीछे वाले सेल का (+) सिरा आगे वाले सेल के (-) आधार को छूता है।',
          action:
              "1. 'कैप खोलें' पर क्लिक करें।\n2. टॉर्च के अंदर पीछे (बाएं) वाले सेल पर क्लिक करें।\n3. 'सेल घुमाएँ' पर क्लिक करें ताकि दोनों (+) सिरे दाईं ओर बल्ब की तरफ हों!",
        ),
        LabStep(
          concept: 'सेलों को श्रृंखला में सही ढंग से व्यवस्थित करने के साथ, परिपथ अब आवश्यक ऊर्जा प्रदान कर सकता है।',
          action: 'बंद करने के लिए कैप पर क्लिक करें। स्विच ऑन पर क्लिक करें।',
        ),
        LabStep(concept: 'काम कर रही टॉर्च का निरीक्षण करें।', action: 'जलती हुई टॉर्च का निरीक्षण करें।'),
      ],
    ),
    LabScenarioData(
      objective:
          'एक उपकरण में सेलों को सही ढंग से स्थापित करने के लिए जहां वे अगल-बगल (side-by-side) रखे जाते हैं, यह समझना कि धातु कनेक्टर श्रृंखला परिपथ को कैसे पूरा करता है।',
      steps: [
        LabStep(
          concept: 'जगह बचाने के लिए कई खिलौने सेलों को अगल-बगल रखते हैं। आइए कम्पार्टमेंट खोलें।',
          action: 'खिलौना कार को शेल्फ से वर्कबेंच पर खींचें। इसे खोलने के लिए बैटरी कम्पार्टमेंट कुंडी पर क्लिक करें।',
        ),
        LabStep(
          concept: 'ढाले गए - और + प्रतीकों का पालन करते हुए, आइए पहले उन्हें गलत तरीके से रखें।',
          action: 'सप्लाई बॉक्स से दोनों सेलों को कम्पार्टमेंट में खींचें ताकि वे एक ही दिशा का सामना कर रहे हों।',
        ),
        LabStep(
          concept: 'यदि सेल एक ही दिशा का सामना करते हैं, तो धातु की पट्टी समान टर्मिनलों को जोड़ती है, जिससे वोल्टेज रद्द हो जाता है।',
          action: "बैटरी कवर को बंद करने के लिए उस पर क्लिक करें। 'ON' स्विच पर क्लिक करें।",
        ),
        LabStep(
          concept: 'ढाले गए प्रतीकों का निरीक्षण करें। धातु की पट्टी विपरीत टर्मिनलों को जोड़ने वाले तार के रूप में कार्य करती है।',
          action: 'फिर से खोलने के लिए कम्पार्टमेंट पर क्लिक करें। एक सेल बाहर खींचें, घुमाएँ, और वापस सही ढंग से डालें।',
        ),
        LabStep(
          concept: 'परिपथ सही ढंग से ध्रुवीकृत है। विद्युत ऊर्जा मोटर तक प्रवाहित हो सकती है।',
          action: "बैटरी कवर को बंद करने के लिए उस पर क्लिक करें। 'ON' स्विच पर क्लिक करें।",
        ),
        LabStep(concept: 'काम कर रही कार का निरीक्षण करें।', action: 'चलती हुई कार का निरीक्षण करें।'),
      ],
    ),
  ],
};

// ============================================================ PAINTER

class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.boxText,
    required this.showLabels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final String boxText;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(_viewCenter.dx, _viewCenter.dy);
    canvas.scale(scene.zoom);
    canvas.translate(-scene.focus.dx, -scene.focus.dy);
    _room(canvas, size);

    final t = scene.torch, car = scene.car;
    final s1 = scene.scenario == 0;
    if (s1 && t.onShelf && !_moving(t.ground, t.k)) _torch(canvas);
    if (!s1 && car.onShelf && !_moving(car.ground, car.k)) _car(canvas);

    // Desk objects, back to front.
    final items = <(double, VoidCallback)>[
      (_boxGround.dy, () => _supplyBox(canvas)),
      for (final c in scene.cells)
        if (c.free == null && c.device == null && c.box == null) (c.ground.dy, () => _freeCell(canvas, c)),
    ];
    if (s1 && !t.onShelf) items.add((t.ground.dy, () => _torch(canvas)));
    if (!s1 && !car.onShelf) items.add((car.ground.dy, () => _car(canvas)));
    items.sort((a, b) => a.$1.compareTo(b.$1));
    for (final it in items) {
      it.$2();
    }
    // Objects being carried (device lifted off the shelf, dragged cells).
    if (s1 && t.onShelf && _moving(t.ground, t.k)) _torch(canvas);
    if (!s1 && car.onShelf && _moving(car.ground, car.k)) _car(canvas);
    for (final c in scene.cells) {
      if (c.free != null) _floatingCell(canvas, c);
    }
    _badge(canvas);
    canvas.restore();
  }

  /// A device is "moving" while it is between the shelf and the desk.
  bool _moving(Offset g, double k) => g.dy > 140 || k > _kShelf + 0.5;

  // -------------------------------------------------------------- room

  void _room(Canvas c, Size size) {
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _deskBack),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3A3A), _cWall],
        ).createShader(const Rect.fromLTRB(0, 0, 10, _deskBack)),
    );
    labGlow(c, const Offset(640, 60), 380, Colors.white, intensity: 0.06);
    c.drawRect(
      Rect.fromLTRB(b.left, _deskBack - 16, b.right, _deskBack),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.3)],
        ).createShader(const Rect.fromLTRB(0, _deskBack - 16, 10, _deskBack)),
    );
    // Wooden desk with grain.
    final desk = Rect.fromLTRB(b.left, _deskBack, b.right, b.bottom);
    c.drawRect(
      desk,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cDesk, -0.12), _cDesk, labShade(_cDesk, 0.06)],
          stops: const [0, 0.45, 1],
        ).createShader(const Rect.fromLTRB(0, _deskBack, 10, 560)),
    );
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(_cDesk, -0.25).withValues(alpha: 0.35);
    for (var i = 0; i < 16; i++) {
      final y = _deskBack + 10 + i * i * 1.45 + i * 6;
      final path = Path()..moveTo(b.left, y);
      for (double x = -200; x <= 1200; x += 40) {
        path.lineTo(x, y + 2.5 * math.sin(x / 90 + i * 1.7) + 1.2 * math.sin(x / 23 + i));
      }
      c.drawPath(path, grain);
    }
    c.drawLine(
      Offset(b.left, _deskBack),
      Offset(b.right, _deskBack),
      Paint()
        ..color = labShade(_cDesk, 0.3)
        ..strokeWidth = 2,
    );
    _shelf(c);
  }

  void _shelf(Canvas c) {
    const top = 108.0, front = 131.0, thick = 12.0, l = 70.0, r = 812.0;
    for (final x in [104.0, 778.0]) {
      final leg = Rect.fromLTRB(x - 6, front + thick - 2, x + 6, _deskBack + 12);
      labGroundShadow(c, Offset(x, _deskBack + 12), 34, 8, opacity: 0.35);
      c.drawRect(
        leg,
        Paint()
          ..shader = LinearGradient(colors: [labShade(_cShelf, -0.3), labShade(_cShelf, 0.1), labShade(_cShelf, -0.35)])
              .createShader(leg),
      );
      c.drawRect(Rect.fromLTRB(x + 6, front + thick - 2, x + 10, _deskBack + 8), Paint()..color = labShade(_cShelf, -0.5));
    }
    c.drawRect(
      const Rect.fromLTRB(l, front + thick, r, front + thick + 12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0)],
        ).createShader(const Rect.fromLTRB(0, front + thick, 10, front + thick + 12)),
    );
    final topFace = Path()
      ..moveTo(l + 8, top)
      ..lineTo(r - 8, top)
      ..lineTo(r, front)
      ..lineTo(l, front)
      ..close();
    c.drawPath(
      topFace,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cShelf, 0.05), labShade(_cShelf, 0.22)],
        ).createShader(const Rect.fromLTRB(0, top, 10, front)),
    );
    c.drawRect(
      const Rect.fromLTRB(l, front, r, front + thick),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cShelf, -0.05), labShade(_cShelf, -0.3)],
        ).createShader(const Rect.fromLTRB(0, front, 10, front + thick)),
    );
    c.drawLine(const Offset(l, front), const Offset(r, front), Paint()..color = labShade(_cShelf, 0.4)..strokeWidth = 1);
  }

  // ------------------------------------------------------------- torch

  /// Screen point on the torch: local x along the axis, [up] in units.
  Offset _tp(double x, double up) {
    final t = scene.torch;
    return scene.torchPoint(0) + Offset(x * t.k, -up * t.k);
  }

  double _up(double y, double z) => y * math.cos(scene.el) - z * math.sin(scene.el);

  Rect _band(double x0, double x1, double top, double bottom) {
    final a = _tp(x0, top), b = _tp(x1, bottom);
    return Rect.fromLTRB(a.dx, a.dy, b.dx, b.dy);
  }

  Paint _cyl(Rect r, Color col, {double hi = 0.28, double lo = -0.45}) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [labShade(col, lo * 0.5), labShade(col, hi), col, labShade(col, lo)],
      stops: const [0, 0.25, 0.55, 1],
    ).createShader(r);

  /// Cutaway torch (HTML `createTorch`): open-topped green tube, head with
  /// reflector, screw cap, slide switch, beam when lit.
  void _torch(Canvas c) {
    final t = scene.torch, k = t.k;
    final ctr = scene.torchPoint(0);
    labGroundShadow(c, t.ground + Offset(-0.3 * k, 2), 7.6 * k, 0.9 * k, opacity: 0.4);
    if (t.light) _beam(c);

    // Inner back wall seen through the slot, back lip on top.
    final backOuter = _up(0.34, -0.668), backInner = _up(0.295, -0.579);
    final frontOuter = _up(0.34, 0.668), frontInner = _up(0.295, 0.579);
    final inner = _band(-2.4, 2.4, backInner, -0.6);
    c.drawRect(
      inner,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3A3A), Color(0xFF222222), Color(0xFF111111)],
        ).createShader(inner),
    );
    c.drawRect(_band(-2.4, 2.4, backOuter, backInner), Paint()..color = labShade(_cTorch, 0.25));

    // Cells inside the torch.
    for (final cell in t.slots) {
      if (cell != null && cell.free == null) _cellAt(c, cell, scene.slotCenter('torch', cell.slot), k);
    }

    // Front wall of the tube (covers the lower half of the cells).
    final front = _band(-2.4, 2.4, frontOuter, -0.75);
    c.drawRect(front, _cyl(_band(-2.4, 2.4, 0.75, -0.75), _cTorch));
    c.drawRect(_band(-2.4, 2.4, frontOuter, frontInner - 0.02), Paint()..color = labShade(_cTorch, 0.35));

    // Open end + brass threads when the cap is unscrewed.
    if (t.capX > 2.95) {
      final th = _band(2.4, 2.9, 0.68, -0.68);
      c.drawRect(th, _cyl(th, const Color(0xFFDAA520), hi: 0.4));
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(const Color(0xFFDAA520), -0.45);
      for (var i = 1; i < 5; i++) {
        final x = 2.4 + i * 0.1;
        c.drawLine(_tp(x, 0.66), _tp(x - 0.04, -0.66), ringPaint);
      }
      final endC = _tp(2.9, 0);
      c.drawOval(Rect.fromCenter(center: endC, width: 0.32 * k, height: 1.36 * k), Paint()..color = const Color(0xFFB8860B));
      c.drawOval(Rect.fromCenter(center: endC, width: 0.26 * k, height: 1.1 * k), Paint()..color = const Color(0xFF151515));
    }

    // Head: frustum 0.9 -> 0.75 with the reflector bezel.
    final head = Path()
      ..moveTo(_tp(-3.6, 0.9).dx, _tp(-3.6, 0.9).dy)
      ..lineTo(_tp(-2.4, 0.75).dx, _tp(-2.4, 0.75).dy)
      ..lineTo(_tp(-2.4, -0.75).dx, _tp(-2.4, -0.75).dy)
      ..lineTo(_tp(-3.6, -0.9).dx, _tp(-3.6, -0.9).dy)
      ..close();
    c.drawPath(head, _cyl(_band(-3.6, -2.4, 0.9, -0.9), _cTorch));
    c.drawLine(_tp(-2.4, 0.75), _tp(-2.4, -0.75), Paint()..color = labShade(_cTorch, -0.5)..strokeWidth = 1.5);
    final lens = Rect.fromCenter(center: _tp(-3.62, 0), width: 0.22 * k, height: 1.78 * k);
    c.drawOval(lens, Paint()..color = t.light ? const Color(0xFFFFF7CC) : const Color(0xFFDDDDDD));
    c.drawOval(
      lens,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(_cTorch, 0.2),
    );
    if (t.light) labGlow(c, _tp(-3.65, 0), 1.6 * k, const Color(0xFFFFAA00), intensity: 0.9);

    // Screw cap.
    final cap = _band(t.capX - 0.4, t.capX + 0.4, 0.75, -0.75);
    c.drawRRect(RRect.fromRectAndRadius(cap, Radius.circular(0.1 * k)), _cyl(cap, _cTorch));
    final grip = Paint()
      ..strokeWidth = 1
      ..color = labShade(_cTorch, -0.45);
    for (var i = 1; i < 6; i++) {
      final x = t.capX - 0.4 + i * 0.8 / 6;
      c.drawLine(_tp(x, 0.7), _tp(x, -0.7), grip);
    }
    c.drawOval(
      Rect.fromCenter(center: _tp(t.capX + 0.4, 0), width: 0.3 * k, height: 1.5 * k),
      Paint()..color = labShade(_cTorch, -0.15),
    );

    // Slide switch on top (box meshes).
    final m = _Mesh(scene.view(ctr, k, yaw: 0));
    m.box(const _V3(-0.5, 0.7, 0), const _V3(0.8, 0.1, 0.5), const Color(0xFF555555));
    m.box(_V3(t.switchX, 0.8, 0), const _V3(0.3, 0.2, 0.3), t.on ? const Color(0xFF4B5563) : const Color(0xFF333333), shine: 0.3);
    m.paint(c);
  }

  /// Additive light cone (HTML `torchLight`, 16 long, radius 0.8 -> 6).
  void _beam(Canvas c) {
    final k = scene.torch.k;
    final a = _tp(-3.5, 0);
    final path = Path()
      ..moveTo(a.dx, a.dy - 0.8 * k)
      ..lineTo(a.dx - 16 * k, a.dy - 6 * k)
      ..lineTo(a.dx - 16 * k, a.dy + 6 * k)
      ..lineTo(a.dx, a.dy + 0.8 * k)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_cBeam.withValues(alpha: 0.42), _cBeam.withValues(alpha: 0.12), _cBeam.withValues(alpha: 0)],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromLTRB(a.dx - 16 * k, a.dy - 6 * k, a.dx, a.dy + 6 * k)),
    );
    // Warm pool of light on the desk (HTML point light).
    c.drawOval(
      Rect.fromCenter(center: scene.torch.ground + Offset(-6 * k, 0.4 * k), width: 9 * k, height: 2.6 * k),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE9A0).withValues(alpha: 0.32),
          const Color(0xFFFFE9A0).withValues(alpha: 0),
        ]).createShader(Rect.fromCenter(center: scene.torch.ground + Offset(-6 * k, 0.4 * k), width: 9 * k, height: 2.6 * k)),
    );
  }

  // ------------------------------------------------------------- cells

  /// Cell parts in its own frame: red body, (+) nub, (-) base, marks.
  void _cellParts(_Mesh m, _Cell cell) {
    m.tint = scene.selected == cell.id ? const Color(0xFFFFE066) : null;
    m.cylX(-1.1, 1.1, 0.45, _cCell, shine: 0.25);
    m.cylX(-1.25, -1.05, 0.15, _cMetal, shine: 0.7, n: 12);
    m.cylX(1.05, 1.15, 0.45, _cMetal, shine: 0.6);
    if (showLabels) {
      // Biased past the cell's own front-top faces so the marks stay whole.
      m.label('+', const _V3(-0.6, 0.46, 0), const _V3(0, 1, 0), 0.62, Colors.white, bias: 0.6);
      m.label('−', const _V3(0.6, 0.46, 0), const _V3(0, 1, 0), 0.62, Colors.white, bias: 0.6);
    }
    m.tint = null;
  }

  void _cellAt(Canvas c, _Cell cell, Offset center, double k) {
    if (scene.selected == cell.id) labGlow(c, center, 1.9 * k, const Color(0xFFFACC15), intensity: 0.55);
    final m = _Mesh(scene.view(center, k, yaw: cell.device == 'torch' ? 0 : _View.defaultYaw));
    m.xf = (p) => p.rotY(cell.rotY).rotX(cell.rotX);
    m.nf = (n) => n.rotY(cell.rotY).rotX(cell.rotX);
    _cellParts(m, cell);
    m.paint(c);
  }

  void _freeCell(Canvas c, _Cell cell) {
    labGroundShadow(c, cell.ground + const Offset(0, 2), 2.6 * _kDesk, 0.5 * _kDesk, opacity: 0.35);
    _cellAt(c, cell, scene.cellCenter(cell), _kDesk);
  }

  void _floatingCell(Canvas c, _Cell cell) {
    final ctr = cell.free!;
    if (cell.dragging) {
      labGroundShadow(c, ctr + Offset(0, 0.9 * _kDesk * math.cos(scene.el)), 2.4 * _kDesk, 0.45 * _kDesk, opacity: 0.25);
    }
    _cellAt(c, cell, ctr, _kDesk);
  }

  // ------------------------------------------------------- supply box

  void _supplyBox(Canvas c) {
    labGroundShadow(c, _boxGround + const Offset(0, 6), 4.6 * _kDesk, 1.4 * _kDesk, opacity: 0.35);
    final m = _Mesh(scene.view(_boxGround, _kDesk));
    m.layer = 0;
    m.box(const _V3(0, 0.1, 0), const _V3(4, 0.2, 3), _cBox);
    m.layer = 1;
    m.box(const _V3(0, 0.6, -1.4), const _V3(4, 1.0, 0.2), _cBox);
    m.box(const _V3(-1.9, 0.6, 0), const _V3(0.2, 1.0, 3), _cBox);
    m.box(const _V3(1.9, 0.6, 0), const _V3(0.2, 1.0, 3), _cBox);
    m.box(const _V3(0, 0.3, 1.4), const _V3(4, 0.4, 0.2), _cBox);
    m.label(boxText, const _V3(0, 0.3, 1.52), const _V3(0, 0, 1), 0.34, const Color(0xFFF8FAFC), bias: 0.3);
    for (final cell in scene.cells) {
      if (cell.box == null || cell.free != null || cell.device != null) continue;
      final z = _Scene.boxZ(cell.box!);
      m.xf = (p) => p.rotY(cell.rotY) + _V3(0, 0.65, z);
      m.nf = (n) => n.rotY(cell.rotY);
      _cellParts(m, cell);
    }
    m.paint(c);
  }

  // --------------------------------------------------------------- car

  /// Toy car (HTML `createCar`): hollow chassis, cabin, roof switch, four
  /// wheels, hinged bottom cover, metal strip and molded +/- symbols.
  void _car(Canvas c) {
    final car = scene.car, k = car.k;
    labGroundShadow(c, car.ground + const Offset(0, 3), 4.8 * k, 1.3 * k, opacity: 0.42);
    final m = _Mesh(scene.view(car.ground, k));
    final open = car.flip > math.pi / 2;
    _V3 nf(_V3 n) => n.rotX(car.flip);
    m.xf = car.xf;
    m.nf = nf;
    m.layer = open ? 0 : 2;
    m.box(const _V3(0, 0.4, 0), const _V3(4.0, 0.2, 2.2), _cCar, shine: 0.35);
    m.box(const _V3(-0.2, 0.75, 0), const _V3(2.0, 0.5, 1.8), _cCabin, shine: 0.6);
    m.box(const _V3(-0.2, 1.05, 0), const _V3(2.0, 0.1, 1.8), _cCar, shine: 0.35);
    m.box(const _V3(-0.2, 1.15, 0), const _V3(0.5, 0.1, 0.4), const Color(0xFF111111));
    m.box(_V3(car.switchX, 1.2, 0), const _V3(0.3, 0.2, 0.3), const Color(0xFFEF4444), shine: 0.4);
    m.layer = 2;
    m.box(const _V3(1.65, -0.1, 0), const _V3(0.7, 0.8, 2.2), _cCar, shine: 0.35);
    m.box(const _V3(-1.65, -0.1, 0), const _V3(0.7, 0.8, 2.2), _cCar, shine: 0.35);
    m.box(const _V3(0, -0.1, 1.0), const _V3(2.6, 0.8, 0.2), _cCar, shine: 0.35);
    m.box(const _V3(0, -0.1, -1.0), const _V3(2.6, 0.8, 0.2), _cCar, shine: 0.35);
    for (final w in const [_V3(-1.2, -0.3, 1.15), _V3(1.2, -0.3, 1.15), _V3(-1.2, -0.3, -1.15), _V3(1.2, -0.3, -1.15)]) {
      m.xf = car.xf;
      m.nf = nf;
      m.cylZ(w, 0.4, 0.2, _cTire, spin: car.wheel);
      m.cylZ(w, 0.25, 0.22, _cRim, spin: car.wheel);
      m.xf = (p) => car.xf((p - w).rotZ(car.wheel) + w);
      m.nf = (n) => nf(n.rotZ(car.wheel));
      m.box(w, const _V3(0.05, 0.45, 0.24), _cTire, bias: 0.01);
      m.box(w, const _V3(0.45, 0.05, 0.24), _cTire, bias: 0.01);
    }
    m.xf = car.xf;
    m.nf = nf;
    if (open) {
      m.layer = 1;
      _underFace(m, 0, 0.29, 0, 2.6, 1.8, const Color(0xFF1F2937));
      _underFace(m, 1.0, 0.28, 0, 0.4, 1.4, const Color(0xFFD1D5DB), shine: 0.6, bias: 0.01);
      if (car.green > 0) {
        _underFace(m, 1.0, 0.27, 0, 0.5, 1.5, const Color(0xFF22C55E).withValues(alpha: car.green), bias: 0.02);
      }
      // Molded symbols sit on the ceiling: biased above it (same layer), the
      // walls in the next layer still hide the ones behind the front wall.
      const sym = Color(0xFFAAAAAA);
      m.label('+', const _V3(-0.8, 0.27, 0.5), const _V3(0, -1, 0), 0.4, sym, bias: 1.2);
      m.label('−', const _V3(0.6, 0.27, 0.5), const _V3(0, -1, 0), 0.4, sym, bias: 1.2);
      m.label('−', const _V3(-0.8, 0.27, -0.5), const _V3(0, -1, 0), 0.4, sym, bias: 1.2);
      m.label('+', const _V3(0.6, 0.27, -0.5), const _V3(0, -1, 0), 0.4, sym, bias: 1.2);
      m.layer = 2;
      for (final cell in car.slots) {
        if (cell == null || cell.free != null) continue;
        final at = _V3(-0.1, -0.15, cell.slot == 0 ? 0.45 : -0.45);
        m.xf = (p) => car.xf(p.rotY(cell.rotY) + at);
        m.nf = (n) => nf(n.rotY(cell.rotY));
        _cellParts(m, cell);
      }
    }
    m.xf = (p) => car.xf(p.rotZ(car.cover) + const _V3(-1.3, -0.5, 0));
    m.nf = (n) => nf(n.rotZ(car.cover));
    m.box(const _V3(1.3, 0, 0), const _V3(2.6, 0.05, 1.8), _cCar, shine: 0.35);
    for (final cell in scene.cells) {
      if (cell.device == 'car' && cell.free == null && open && scene.selected == cell.id) {
        labGlow(c, scene.slotCenter('car', cell.slot), 1.6 * k, const Color(0xFFFACC15), intensity: 0.45);
      }
    }
    m.paint(c);
  }

  /// Flat face on the compartment ceiling (normal -y in car space).
  void _underFace(_Mesh m, double x, double y, double z, double sx, double sz, Color col, {double shine = 0, double bias = 0}) {
    m.face([
      _V3(x - sx / 2, y, z - sz / 2),
      _V3(x + sx / 2, y, z - sz / 2),
      _V3(x + sx / 2, y, z + sz / 2),
      _V3(x - sx / 2, y, z + sz / 2),
    ], const _V3(0, -1, 0), col, shine: shine, bias: bias);
  }

  // ------------------------------------------------- validation badge

  void _badge(Canvas c) {
    final b = scene.badge;
    if (b == null) return;
    final age = scene.time - b.start;
    if (age < 0 || age > 1.5) return;
    final pop = Curves.easeOutBack.transform((age / 0.5).clamp(0.0, 1.0));
    final fade = age > 1.3 ? (1.5 - age) / 0.2 : 1.0;
    final col = b.ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final ctr = b.at - const Offset(0, 40);
    final r = 24 * pop;
    labGlow(c, ctr, r * 1.9, col, intensity: 0.8 * fade);
    c.drawCircle(ctr, r, Paint()..color = col.withValues(alpha: fade));
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * pop
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: fade);
    final s = r * 0.42;
    if (b.ok) {
      c.drawPath(
        Path()
          ..moveTo(ctr.dx - s, ctr.dy + 0.05 * s)
          ..lineTo(ctr.dx - 0.25 * s, ctr.dy + 0.75 * s)
          ..lineTo(ctr.dx + s, ctr.dy - 0.7 * s),
        ink,
      );
    } else {
      c.drawLine(ctr + Offset(-s, -s), ctr + Offset(s, s), ink);
      c.drawLine(ctr + Offset(s, -s), ctr + Offset(-s, s), ink);
    }
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.boxText != boxText || old.showLabels != showLabels || old.scene != scene;
}

// ================================================ CIRCUIT DIAGRAMS

/// HTML `buildCircuitDiagram`: series cells + lamp (torch) or side-by-side
/// cells joined by the metal strip with the motor (car). Drawn in a
/// 400 x 100 box like the HTML SVG, with marching current arrows.
class _DiagramPainter extends CustomPainter {
  _DiagramPainter({required this.scenario, required this.dark, required ValueNotifier<double> time})
      : _time = time,
        super(repaint: time);

  final int scenario;
  final bool dark;
  final ValueNotifier<double> _time;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 400, size.height / 100);
    canvas.save();
    canvas.translate((size.width - 400 * s) / 2, (size.height - 100 * s) / 2);
    canvas.scale(s);
    final t = _time.value;
    if (scenario == 0) {
      _path(canvas, const [Offset(126, 62), Offset(126, 84), Offset(286, 84), Offset(286, 66)], const Color(0xFFEAB308), 2, t);
      _arrow(canvas, const Offset(286, 64), up: true, color: const Color(0xFFEAB308));
      _cell(canvas, const Offset(120, 40), 40, 12, 20);
      _cell(canvas, const Offset(164, 40), 40, 12, 20);
      _bulb(canvas, const Offset(286, 50), t);
    } else {
      final bob = -3 * (0.5 + 0.5 * math.sin(t * math.pi * 2)).abs();
      _path(canvas, const [Offset(140, 38), Offset(140, 16), Offset(268, 16), Offset(268, 34)], const Color(0xFF22C55E), 3, t);
      _arrow(canvas, const Offset(268, 38), up: false, color: const Color(0xFF22C55E));
      _path(canvas, const [Offset(268, 64), Offset(268, 88), Offset(140, 88), Offset(140, 66)], const Color(0xFF22C55E), 3, t);
      _arrow(canvas, const Offset(140, 62), up: true, color: const Color(0xFF22C55E));
      final bar = RRect.fromRectAndRadius(const Rect.fromLTRB(150, 68, 270, 75), const Radius.circular(3));
      canvas.drawRRect(bar, Paint()..color = const Color(0xFFD1D5DB));
      canvas.drawRRect(
        bar,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black.withValues(alpha: 0.2),
      );
      _cell(canvas, const Offset(100, 39), 64, 16, 24);
      _cell(canvas, const Offset(228, 39), 64, 16, 24);
      _gear(canvas, Offset(204, 30 + bob), t);
    }
    canvas.restore();
  }

  void _path(Canvas c, List<Offset> pts, Color color, double w, double t) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final q in pts.skip(1)) {
      p.lineTo(q.dx, q.dy);
    }
    labDashedPath(
      c,
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = color,
      dash: 8,
      gap: 8,
      phase: -t * 16,
    );
  }

  void _arrow(Canvas c, Offset tip, {required bool up, required Color color}) {
    final d = up ? 10.0 : -10.0;
    c.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 5, tip.dy + d)
        ..lineTo(tip.dx + 5, tip.dy + d)
        ..close(),
      Paint()..color = color,
    );
  }

  /// Red body with "-" and grey (+) cap, like the HTML flex boxes.
  void _cell(Canvas c, Offset at, double body, double cap, double h) {
    final red = Rect.fromLTWH(at.dx, at.dy, body, h);
    final grey = Rect.fromLTWH(at.dx + body, at.dy, cap, h);
    c.drawRRect(
      RRect.fromRectAndCorners(red.shift(const Offset(0, 2)), topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(2)),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    c.drawRRect(RRect.fromRectAndCorners(red, topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(2)), Paint()..color = const Color(0xFFE20000));
    c.drawRect(grey, Paint()..color = const Color(0xFFD1D5DB));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.3);
    c.drawRect(red, edge);
    c.drawRect(grey, edge);
    labText(c, '−', red.center, size: 11, color: Colors.white, weight: FontWeight.w900);
    labText(c, '+', grey.center, size: 10, color: Colors.black, weight: FontWeight.w900);
  }

  void _bulb(Canvas c, Offset ctr, double t) {
    labGlow(c, ctr, 22, const Color(0xFFFACC15), intensity: 0.8 + 0.2 * math.sin(t * 6));
    c.drawCircle(ctr, 12, Paint()..color = const Color(0xFFFEF9C3));
    c.drawCircle(
      ctr,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFACC15),
    );
    c.drawCircle(ctr + const Offset(0, -1.5), 4.2, Paint()..color = const Color(0xFFEAB308));
    c.drawRect(Rect.fromCenter(center: ctr + const Offset(0, 4.5), width: 4.5, height: 3.5), Paint()..color = const Color(0xFFCA8A04));
  }

  void _gear(Canvas c, Offset ctr, double t) {
    final teeth = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + t * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final n = Offset(-dir.dy, dir.dx);
      teeth.addPolygon([
        ctr + dir * 7 + n * 2.6,
        ctr + dir * 12 + n * 2.2,
        ctr + dir * 12 - n * 2.2,
        ctr + dir * 7 - n * 2.6,
      ], true);
    }
    const g = Color(0xFF22C55E);
    c.drawCircle(ctr + const Offset(0, 2), 10, Paint()..color = Colors.black.withValues(alpha: 0.3));
    c.drawPath(teeth, Paint()..color = g);
    c.drawCircle(ctr, 8.5, Paint()..color = g);
    c.drawCircle(ctr, 3.2, Paint()..color = dark ? const Color(0xFF111111) : const Color(0xFFF8FAFC));
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter old) => old.scenario != scenario || old.dark != dark;
}

// ======================================================= MINI 3D
//
// The cells, toy car and supply box are tiny Three.js meshes that spin and
// flip, so they are drawn with a small face renderer: transformed vertices,
// back-face culling, flat Lambert shading and a painter's sort. Units are
// the HTML world units; `k` converts them to design pixels.

const Size _design = Size(1000, 560);
const Offset _viewCenter = Offset(500, 280);
const _V3 _light = _V3(0.37, 0.8, 0.47); // HTML directional light (5, 12, 8)

class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x, y * c - z * s, y * s + z * c);
  }

  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  _V3 rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c - y * s, x * s + y * c, z);
  }
}

/// Orthographic camera: slight yaw, then elevation [el] (radians). Parts
/// of the straight cutaway torch use [yaw] 0 so they line up with its body.
class _View {
  _View(this.origin, this.k, this.el, {this.yaw = defaultYaw});
  final Offset origin;
  final double k, el, yaw;
  static const double defaultYaw = -0.2;

  Offset proj(_V3 p) {
    final q = p.rotY(yaw);
    return origin + Offset(q.x * k, -(q.y * math.cos(el) - q.z * math.sin(el)) * k);
  }

  double depth(_V3 p) {
    final q = p.rotY(yaw);
    return q.y * math.sin(el) + q.z * math.cos(el);
  }
}

/// One projected polygon (or a text decal when [text] is set).
class _Poly {
  _Poly(this.pts, this.depth, this.color, this.layer, {this.text, this.textSize = 0, this.squash = 1});
  final List<Offset> pts;
  final double depth;
  final Color color;
  final int layer;
  final String? text;
  final double textSize;
  final double squash;
}

/// Collects faces of several parts, then paints them back to front.
class _Mesh {
  _Mesh(this.view);
  final _View view;
  final List<_Poly> polys = [];

  /// Object -> view-local transform for points and for normals.
  _V3 Function(_V3) xf = (p) => p;
  _V3 Function(_V3) nf = (n) => n;
  int layer = 0;
  Color? tint;

  Color _shade(Color c, _V3 n, double shine) {
    final l = n.dot(_light).clamp(0.0, 1.0);
    var f = 0.52 + 0.6 * l;
    var col = Color.from(
      alpha: c.a,
      red: (c.r * f).clamp(0.0, 1.0),
      green: (c.g * f).clamp(0.0, 1.0),
      blue: (c.b * f).clamp(0.0, 1.0),
    );
    if (shine > 0) col = Color.lerp(col, Colors.white, shine * math.pow(l, 6).toDouble())!;
    if (tint != null) col = Color.lerp(col, tint, 0.32)!;
    return col;
  }

  /// Adds a planar face; culled when it faces away from the viewer.
  void face(List<_V3> local, _V3 normal, Color c, {double shine = 0, double bias = 0, bool cull = true}) {
    final n = nf(normal);
    final nv = n.rotY(view.yaw);
    final facing = nv.y * math.sin(view.el) + nv.z * math.cos(view.el);
    if (cull && facing <= 0.001) return;
    final w = local.map(xf).toList();
    var d = 0.0;
    for (final p in w) {
      d += view.depth(p);
    }
    polys.add(_Poly(w.map(view.proj).toList(), d / w.length + bias, _shade(c, n, shine), layer));
  }

  /// Text lying on a face with normal [normal] (cell +/- marks, symbols).
  void label(String text, _V3 at, _V3 normal, double size, Color c, {double bias = 0.02}) {
    final n = nf(normal).rotY(view.yaw);
    final facing = n.y * math.sin(view.el) + n.z * math.cos(view.el);
    if (facing <= 0.05) return;
    final p = xf(at);
    polys.add(_Poly([view.proj(p)], view.depth(p) + bias, c, layer, text: text, textSize: size * view.k, squash: facing.clamp(0.3, 1.0)));
  }

  /// Box centred at [c] with size [s].
  void box(_V3 c, _V3 s, Color col, {double shine = 0, double bias = 0}) {
    final x0 = c.x - s.x / 2, x1 = c.x + s.x / 2;
    final y0 = c.y - s.y / 2, y1 = c.y + s.y / 2;
    final z0 = c.z - s.z / 2, z1 = c.z + s.z / 2;
    face([_V3(x0, y1, z0), _V3(x1, y1, z0), _V3(x1, y1, z1), _V3(x0, y1, z1)], const _V3(0, 1, 0), col, shine: shine, bias: bias);
    face([_V3(x0, y0, z0), _V3(x1, y0, z0), _V3(x1, y0, z1), _V3(x0, y0, z1)], const _V3(0, -1, 0), col, shine: shine, bias: bias);
    face([_V3(x0, y0, z1), _V3(x1, y0, z1), _V3(x1, y1, z1), _V3(x0, y1, z1)], const _V3(0, 0, 1), col, shine: shine, bias: bias);
    face([_V3(x0, y0, z0), _V3(x1, y0, z0), _V3(x1, y1, z0), _V3(x0, y1, z0)], const _V3(0, 0, -1), col, shine: shine, bias: bias);
    face([_V3(x1, y0, z0), _V3(x1, y1, z0), _V3(x1, y1, z1), _V3(x1, y0, z1)], const _V3(1, 0, 0), col, shine: shine, bias: bias);
    face([_V3(x0, y0, z0), _V3(x0, y1, z0), _V3(x0, y1, z1), _V3(x0, y0, z1)], const _V3(-1, 0, 0), col, shine: shine, bias: bias);
  }

  /// Cylinder along x from [x0] to [x1] around the axis (y, z) = [at].
  void cylX(double x0, double x1, double r, Color col, {_V3 at = const _V3(0, 0, 0), int n = 22, double shine = 0, Color? capColor}) {
    final ring = [for (var i = 0; i < n; i++) i * 2 * math.pi / n];
    _V3 pt(double x, double a) => _V3(x, at.y + r * math.cos(a), at.z + r * math.sin(a));
    for (var i = 0; i < n; i++) {
      final a0 = ring[i], a1 = ring[(i + 1) % n] + (i == n - 1 ? 2 * math.pi : 0);
      final am = (a0 + a1) / 2;
      face([pt(x0, a0), pt(x1, a0), pt(x1, a1), pt(x0, a1)], _V3(0, math.cos(am), math.sin(am)), col, shine: shine);
    }
    face([for (final a in ring) pt(x1, a)], const _V3(1, 0, 0), capColor ?? col, shine: shine);
    face([for (final a in ring.reversed) pt(x0, a)], const _V3(-1, 0, 0), capColor ?? col, shine: shine);
  }

  /// Cylinder along z (wheels) spun by [spin] about its axis.
  void cylZ(_V3 c, double r, double w, Color col, {double spin = 0, int n = 18}) {
    _V3 pt(double z, double a) => _V3(c.x + r * math.cos(a + spin), c.y + r * math.sin(a + spin), z);
    final z0 = c.z - w / 2, z1 = c.z + w / 2;
    for (var i = 0; i < n; i++) {
      final a0 = i * 2 * math.pi / n, a1 = (i + 1) * 2 * math.pi / n, am = (a0 + a1) / 2 + spin;
      face([pt(z0, a0), pt(z1, a0), pt(z1, a1), pt(z0, a1)], _V3(math.cos(am), math.sin(am), 0), col);
    }
    face([for (var i = 0; i < n; i++) pt(z1, i * 2 * math.pi / n)], const _V3(0, 0, 1), col);
    face([for (var i = 0; i < n; i++) pt(z0, i * 2 * math.pi / n)], const _V3(0, 0, -1), col);
  }

  void paint(Canvas canvas, {bool showText = true}) {
    polys.sort((a, b) => a.layer != b.layer ? a.layer.compareTo(b.layer) : a.depth.compareTo(b.depth));
    for (final p in polys) {
      if (p.text != null) {
        if (!showText) continue;
        canvas.save();
        canvas.translate(p.pts.first.dx, p.pts.first.dy);
        canvas.scale(1, p.squash);
        labText(canvas, p.text!, Offset.zero, size: p.textSize, color: p.color, weight: FontWeight.w900);
        canvas.restore();
        continue;
      }
      final path = Path()..addPolygon(p.pts, true);
      canvas.drawPath(path, Paint()..color = p.color);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = p.color,
      );
    }
  }
}

// ======================================================= SCENE MODEL

const double _kDesk = 38;
const double _kShelf = 27;
const double _elBase = 22 * math.pi / 180; // HTML camera (0, 12, 18) -> (0, 4, -2)
const double _elZoom = 37 * math.pi / 180; // HTML close-up (x, 10, 12) -> (x, 1, 0)
const double _deskBack = 252;
const Offset _boxGround = Offset(792, 458);

const Color _cCell = Color(0xFFCC181E);
const Color _cMetal = Color(0xFFCCCCCC);
const Color _cTorch = Color(0xFF29482F);
const Color _cCar = Color(0xFF0EA5E9);
const Color _cCabin = Color(0xFF1E293B);
const Color _cTire = Color(0xFF0F172A);
const Color _cRim = Color(0xFFE2E8F0);
const Color _cBox = Color(0xFF475569);
const Color _cDesk = Color(0xFFC48B59);
const Color _cWall = Color(0xFF4A4A4A);
const Color _cShelf = Color(0xFF8C5A35);
const Color _cBeam = Color(0xFFFFF5B0);

/// An AA cell (HTML `createBattery`). Orientation 1 = (+) cap pointing left.
class _Cell {
  _Cell(this.id);
  final int id;
  int orientation = 1;
  double rotY = 0;

  /// Tilt about x while travelling into / out of the upside-down car.
  double rotX = 0;

  /// 'torch' / 'car' while sitting in a slot.
  String? device;
  int slot = -1;

  /// Home position in the supply box (0 / 1), or null once moved.
  int? box;

  /// Desk point under the cell when it lies on the desk.
  Offset ground = Offset.zero;

  /// Screen centre while dragged or flying into a slot.
  Offset? free;
  bool dragging = false;
}

class _Torch {
  bool onShelf = true;
  Offset ground = const Offset(330, 121);
  double k = _kShelf;
  bool open = false, on = false, light = false;
  double capX = 2.8, switchX = -0.65;
  final List<_Cell?> slots = [null, null];
}

class _Car {
  bool onShelf = true;
  Offset ground = const Offset(578, 121);
  double k = _kShelf;
  bool open = false, on = false, spinning = false;
  double flip = 0, cover = 0, switchX = -0.3, wheel = 0, run = 0, green = 0;
  final List<_Cell?> slots = [null, null];

  double get lift => 0.4 * (1 - math.cos(flip)) / 2;

  /// Car-local point -> mesh space (ground point at the origin).
  _V3 xf(_V3 p) => p.rotX(flip) + _V3(0, 0.7 + lift, 0);
}

/// HTML `showValidationOverlay`: green tick / red cross that pops in.
class _Badge {
  _Badge(this.ok, this.at, this.start);
  final bool ok;
  final Offset at;
  final double start;
}

class _Scene {
  int scenario = 0;
  double time = 0;
  final List<_Cell> cells = [_Cell(0), _Cell(1)];
  _Torch torch = _Torch();
  _Car car = _Car();
  _Badge? badge;
  int? selected;

  // Virtual camera.
  Offset focus = _viewCenter;
  double zoom = 1;
  double el = _elBase;

  static const Offset torchDesk = Offset(432, 372);
  static const Offset carDesk = Offset(566, 380);

  void reset(int s) {
    scenario = s;
    torch = _Torch();
    car = _Car();
    badge = null;
    selected = null;
    focus = _viewCenter;
    zoom = 0.93;
    el = _elBase;
    for (final c in cells) {
      c
        ..orientation = 1
        ..rotY = 0
        ..rotX = 0
        ..device = null
        ..slot = -1
        ..box = c.id
        ..free = null
        ..dragging = false;
    }
  }

  Offset toView(Offset world) => (world - focus) * zoom + _viewCenter;
  Offset toWorld(Offset view) => (view - _viewCenter) / zoom + focus;

  _View view(Offset origin, double k, {double yaw = _View.defaultYaw}) => _View(origin, k, el, yaw: yaw);

  /// Torch axis point at local x (the torch group origin is on its axis).
  Offset torchPoint(double x, [double up = 0]) =>
      torch.ground + Offset(x * torch.k, -(0.75 + up) * math.cos(el) * torch.k);

  Offset slotCenter(String device, int i) {
    if (device == 'torch') return torchPoint(i == 0 ? -1.1 : 1.1);
    return view(car.ground, car.k).proj(car.xf(_V3(-0.1, -0.15, i == 0 ? 0.45 : -0.45)));
  }

  /// Box-relative z of the two home slots.
  static double boxZ(int i) => i == 0 ? -0.6 : 0.6;

  /// Screen centre of a cell (not dragged / flying).
  Offset cellCenter(_Cell c) {
    if (c.free != null) return c.free!;
    if (c.device != null) return slotCenter(c.device!, c.slot);
    if (c.box != null) return view(_boxGround, _kDesk).proj(_V3(0, 0.65, boxZ(c.box!)));
    return c.ground + Offset(0, -0.45 * math.cos(el) * _kDesk);
  }

  double cellK(_Cell c) => c.device == 'torch' ? torch.k : (c.device == 'car' ? car.k : _kDesk);

  /// Screen bounds of a cell for hit-testing.
  Rect cellBounds(_Cell c) {
    final ctr = cellCenter(c);
    final k = cellK(c);
    final w = (1.25 * math.cos(c.rotY).abs() + 0.45 * math.sin(c.rotY).abs() + 0.15) * k;
    final h = 0.62 * k;
    return Rect.fromLTRB(ctr.dx - w, ctr.dy - h, ctr.dx + w, ctr.dy + h);
  }

  Rect get torchBody {
    final a = torchPoint(-3.6), b = torchPoint(torch.capX + 0.4);
    return Rect.fromLTRB(a.dx, a.dy - 0.95 * torch.k, b.dx, b.dy + 0.9 * torch.k);
  }

  Rect get torchCapRect {
    final a = torchPoint(torch.capX - 0.42), b = torchPoint(torch.capX + 0.5);
    return Rect.fromLTRB(a.dx, a.dy - 0.85 * torch.k, b.dx, b.dy + 0.85 * torch.k).inflate(6);
  }

  Rect get torchSwitchRect {
    final a = torchPoint(-0.95, 0.55), b = torchPoint(-0.05, 1.0);
    return Rect.fromLTRB(a.dx, b.dy, b.dx, a.dy).inflate(7);
  }

  Rect _carRect(_V3 lo, _V3 hi) {
    final v = view(car.ground, car.k);
    final pts = [
      for (final x in [lo.x, hi.x])
        for (final y in [lo.y, hi.y])
          for (final z in [lo.z, hi.z]) v.proj(car.xf(_V3(x, y, z))),
    ];
    var r = Rect.fromPoints(pts.first, pts.first);
    for (final p in pts) {
      r = r.expandToInclude(Rect.fromPoints(p, p));
    }
    return r;
  }

  Rect get carBody => _carRect(const _V3(-2.0, -0.7, -1.25), const _V3(2.0, 1.3, 1.25));

  /// "Latch" (closed) or the raised cover (open).
  Rect get carCoverRect {
    if (!car.open || car.flip < math.pi / 2) {
      return _carRect(const _V3(-2.0, -0.7, -1.1), const _V3(2.0, 0.25, 1.1));
    }
    final v = view(car.ground, car.k);
    final pts = [
      for (final p in const [_V3(0, 0, -0.9), _V3(2.6, 0, -0.9), _V3(0, 0, 0.9), _V3(2.6, 0, 0.9)])
        v.proj(car.xf(p.rotZ(car.cover) + const _V3(-1.3, -0.5, 0))),
    ];
    var r = Rect.fromPoints(pts.first, pts.first);
    for (final p in pts) {
      r = r.expandToInclude(Rect.fromPoints(p, p));
    }
    return r.inflate(8);
  }

  Rect get carSwitchRect => _carRect(const _V3(-0.5, 1.1, -0.3), const _V3(0.1, 1.35, 0.3)).inflate(9);
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
