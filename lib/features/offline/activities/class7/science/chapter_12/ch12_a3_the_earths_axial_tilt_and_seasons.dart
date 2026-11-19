// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode, Vertices;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 12 • Activity 3
/// The Earth's Axial Tilt and Seasons.
///
/// Native Flutter port of `Cl7S-Ch12-A3-The_Earth_s_Axial_Tilt_and_Seasons.html`.
/// Drag the tilted Earth along its orbit to the June / December marker,
/// drop the Sunlight Tool on each hemisphere to compare direct and angled
/// sunlight, then spin the Earth and watch India's day / night share in a
/// pie chart. Scenario 1 shows summer in the Northern Hemisphere (June),
/// scenario 2 winter (December).
class Ch12A3TheEarthsAxialTiltAndSeasonsPage extends StatefulWidget {
  const Ch12A3TheEarthsAxialTiltAndSeasonsPage({super.key});

  @override
  State<Ch12A3TheEarthsAxialTiltAndSeasonsPage> createState() =>
      _Ch12A3TheEarthsAxialTiltAndSeasonsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356.
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

/// Pan recognizer that only claims touches starting on the Earth, so other
/// drags still pan the zoomed canvas when the camera is unlocked.
class _A3GrabRecognizer extends PanGestureRecognizer {
  _A3GrabRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch12A3TheEarthsAxialTiltAndSeasonsPageState extends State<Ch12A3TheEarthsAxialTiltAndSeasonsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A3Scene _scene = _A3Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _paintKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();

  late final Ticker _ticker;

  /// Camera moves (HTML TWEEN, 1000 ms Cubic.Out).
  late final AnimationController _camAnim;

  /// Earth snapping onto the marker (400 ms Quadratic.Out).
  late final AnimationController _snapAnim;

  /// Three full spins + pie fill (5000 ms Cubic.InOut).
  late final AnimationController _rotAnim;

  _V3 _camFromEye = _kA3OverviewEye, _camFromTarget = _V3.zero;
  _V3 _camToEye = _kA3OverviewEye, _camToTarget = _V3.zero;
  double _snapFrom = 0, _snapTo = 0;

  /// HTML `State.isRotating`.
  bool _rotating = false;

  /// The Start Rotation button was pressed (it hides, like the HTML).
  bool _rotationStarted = false;

  /// A correct sunlight drop is waiting for its 1 s step advance.
  bool _dropLocked = false;

  bool _pieMounted = false;
  bool _pieShown = false;
  bool _summaryShown = false;

  /// Bumped on every scenario rebuild so stale callbacks are ignored.
  int _gen = 0;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;
  _A3StepType get _type => _kA3StepTypes[(_step - 1).clamp(0, _kA3StepTypes.length - 1)];

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  /// India's day share shown by the pie (HTML 65 % in June, 35 % in December).
  double get _dayPct => (_scenario == 0 ? 65 : 35) * Curves.easeInOutCubic.transform(_rotAnim.value);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1e6;
      final dt = (now - _scene.time).clamp(0.0, 0.1);
      _scene.time = now;
      final k = 1 - math.exp(-dt * 7);
      _scene.viewShift = Offset.lerp(_scene.viewShift, _scene.viewShiftTarget, k)!;
      _frame.value = _scene.time;
    })..start();

    _camAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        final v = Curves.easeOutCubic.transform(_camAnim.value);
        _scene.eye = _V3.lerp(_camFromEye, _camToEye, v);
        _scene.target = _V3.lerp(_camFromTarget, _camToTarget, v);
      });
    _snapAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(() {
        final v = Curves.easeOutQuad.transform(_snapAnim.value);
        _scene.orbitAngle = _snapFrom + (_snapTo - _snapFrom) * v;
      });
    _rotAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))
      ..addListener(() {
        _scene.spin = 6 * math.pi * Curves.easeInOutCubic.transform(_rotAnim.value);
      });

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
    _camAnim.dispose();
    _snapAnim.dispose();
    _rotAnim.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic

  _V3 _earthAt(double angle) => _V3(_kA3OrbitR * math.cos(angle), 0, _kA3OrbitR * math.sin(angle));

  /// HTML camera + controls.target tweens (1000 ms, Cubic.Out).
  void _moveCamera(_V3 eye, _V3 target) {
    _camFromEye = _scene.eye;
    _camFromTarget = _scene.target;
    _camToEye = eye;
    _camToTarget = target;
    _camAnim.forward(from: 0);
  }

  /// HTML `resetApp(true)` scene part: beams cleared, Earth back opposite
  /// its target, camera back to the overview, then step 1.
  void _buildScenario() {
    _gen++;
    _lab.cancelPending();
    _snapAnim.stop();
    _rotAnim.stop();
    _rotAnim.value = 0;
    _scene
      ..step = 1
      ..spin = 0
      ..beamNormal = null
      ..earthGrabbed = false
      ..orbitAngle = _scene.startAngle;
    _rotating = false;
    _rotationStarted = false;
    _dropLocked = false;
    _pieMounted = false;
    _pieShown = false;
    _summaryShown = false;
    _updateStepLogic();
  }

  /// HTML `updateStepLogic()`.
  void _updateStepLogic() {
    _scene.highlightAngle = null;
    switch (_type) {
      case _A3StepType.dragEarth:
        _scene
          ..highlightAngle = _scene.targetAngle
          ..highlightSince = _scene.time
          ..orbitAngle = _scene.startAngle
          ..spin = 0;
        _moveCamera(_kA3OverviewEye, _V3.zero);
      case _A3StepType.dragSunlight:
        final v = _a3SunlightView(_scenario, _earthAt(_scene.targetAngle));
        _moveCamera(v.eye, v.target);
      case _A3StepType.rotate:
        break;
      case _A3StepType.summary:
        final gen = _gen;
        _lab.after(const Duration(milliseconds: 500), () {
          if (mounted && gen == _gen) _showSummary();
        });
    }
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    if (!mounted) return;
    setState(() {
      if (_step < _data.steps.length) {
        _scene.step++;
        _dropLocked = false;
        _updateStepLogic();
      } else if (_step == _data.steps.length) {
        _showSummary();
      }
    });
  }

  void _changeScenario(int index) {
    _lab.hidePopup(sound: false);
    // HTML resetApp(true) also restores the canvas tools.
    _lab
      ..showLabels = true
      ..camLocked = true
      ..panMode = false;
    _lab.resetView(sound: false);
    setState(() {
      _scene.scenario = index;
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _buildScenario();
    });
  }

  // ------------------------------------------------------ Earth drag

  bool _canGrab(Offset p) =>
      _lab.isLabActive &&
      !_rotating &&
      _type == _A3StepType.dragEarth &&
      !_snapAnim.isAnimating &&
      _scene.hitsEarthBox(p);

  void _onGrab(Offset p) {
    if (!_canGrab(p)) return;
    _Audio.play(_Sound.pickup);
    setState(() => _scene.earthGrabbed = true);
  }

  /// HTML pointermove: the Earth follows the pointer's angle on the
  /// orbit plane.
  void _onDrag(Offset p) {
    if (!_scene.earthGrabbed) return;
    final hit = _scene.cam.planeHit(p);
    if (hit == null) return;
    _scene.orbitAngle = math.atan2(hit.z, hit.x);
  }

  void _onRelease() {
    if (!_scene.earthGrabbed) return;
    setState(() => _scene.earthGrabbed = false);
    _checkEarthSnap();
  }

  /// A tap on the Earth is a press + release without a move in the HTML.
  void _onTapUp(TapUpDetails d) {
    if (_canGrab(d.localPosition)) _checkEarthSnap();
  }

  /// HTML `checkEarthSnap()`: within 0.4 rad of the target marker the
  /// Earth snaps onto it (400 ms), otherwise an error toast.
  void _checkEarthSnap() {
    if (_type != _A3StepType.dragEarth) return;
    var cur = _scene.orbitAngle % (2 * math.pi);
    if (cur < 0) cur += 2 * math.pi;
    final target = _scene.targetAngle;
    var diff = (cur - target).abs();
    if (diff > math.pi) diff = 2 * math.pi - diff;
    if (diff < 0.4) {
      var delta = target - cur;
      while (delta > math.pi) {
        delta -= 2 * math.pi;
      }
      while (delta < -math.pi) {
        delta += 2 * math.pi;
      }
      _scene.orbitAngle = cur;
      _snapFrom = cur;
      _snapTo = cur + delta;
      _snapAnim.forward(from: 0);
      _lab.showToast(_t(_scenario == 0 ? 'feedback_snap_june' : 'feedback_snap_dec'));
      _scene.spin = 0;
      _advanceStep();
    } else {
      _lab.showToast(_t('feedback_wrong_marker'), isError: true);
    }
  }

  // --------------------------------------------------- Sunlight tool

  bool get _toolEnabled => _type == _A3StepType.dragSunlight && !_rotating && !_dropLocked;

  /// HTML tool `pointerup`: raycast from the drop point onto the Earth.
  void _onToolDropped(Offset global) {
    if (!mounted || !_toolEnabled) return;
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    if (!(Offset.zero & canvas.size).contains(canvas.globalToLocal(global))) return;
    final p = labGlobalToLocal(_paintKey, global);
    if (p == null) return;
    final n = _scene.surfaceHit(p);
    if (n == null) return;
    _handleSunlightDrop(n);
  }

  /// HTML `handleSunlightDrop()`.
  void _handleSunlightDrop(_V3 normal) {
    final north = normal.dot(_kA3Axis) >= 0;
    if (north != _a3TargetNorth(_step)) {
      _lab.showToast(_t('feedback_wrong_hemi'), isError: true);
      return;
    }
    final direct = _a3ExpectDirect(_scenario, _step);
    final spot = _a3LitSpot(normal, (_V3.zero - _scene.earthPos).unit);
    setState(() {
      _scene
        ..beamNormal = spot
        ..beamDirect = direct
        ..beamSince = _scene.time;
      _dropLocked = true;
    });
    _lab.showToast(_t(direct ? 'feedback_direct' : 'feedback_angled'));
    final gen = _gen;
    _lab.after(const Duration(milliseconds: 1000), () {
      if (mounted && gen == _gen) _advanceStep();
    });
  }

  // -------------------------------------------------------- rotation

  /// HTML `startRotation()`.
  void _startRotation() {
    if (_rotating || _type != _A3StepType.rotate) return;
    final gen = _gen;
    setState(() {
      _rotationStarted = true;
      _rotating = true;
      _scene.beamNormal = null;
      final v = _a3RotationView(_scenario, _scene.earthPos);
      _moveCamera(v.eye, v.target);
      _pieMounted = true;
    });
    _lab.after(const Duration(milliseconds: 20), () {
      if (mounted && gen == _gen) setState(() => _pieShown = true);
    });
    _rotAnim.forward(from: 0).whenComplete(() {
      if (!mounted || gen != _gen) return;
      setState(() => _rotating = false);
      _Audio.play(_Sound.success);
      _lab.after(const Duration(milliseconds: 2000), () {
        if (!mounted || gen != _gen) return;
        setState(() => _pieShown = false);
        _lab.after(const Duration(milliseconds: 300), () {
          if (mounted && gen == _gen) setState(() => _pieMounted = false);
        });
        _advanceStep();
      });
    });
  }

  // --------------------------------------------------------- summary

  /// HTML `showSummary()`: the "Observation Complete" popup with the season
  /// icons, the season name, its explanation and "Next Scenario" (summer)
  /// or "Restart Lab" (winter).
  void _showSummary() {
    if (!mounted) return;
    final sc = _scenario;
    _lab.completedScenarios.add(sc);
    if (!_lab.isSidebarOpen) _lab.openSidebar();
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('observation_complete'),
        icon: Icons.check_circle,
        accent: const Color(0xFF818CF8),
        extra: _summaryBody(sc),
        actions: [_finishAction(sc)],
      ),
    );
    setState(() => _summaryShown = true);
  }

  LabAction _finishAction(int sc) {
    if (sc == 0) {
      return LabAction(
        label: _t('btn_next'),
        icon: Icons.arrow_forward,
        color: _Colors.indigo600,
        foreground: Colors.white,
        sound: _Sound.scenario,
        onTap: () => _changeScenario(1),
      );
    }
    return LabAction(
      label: _t('btn_restart'),
      icon: Icons.restart_alt,
      color: _Colors.indigo600,
      foreground: Colors.white,
      onTap: _lab.requestFullReset,
    );
  }

  Widget _summaryBody(int sc) {
    final dark = _lab.isDark;
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final summer = sc == 0;
    final labelColor = summer
        ? (dark ? const Color(0xFFFACC15) : const Color(0xFFEAB308))
        : (dark ? const Color(0xFF93C5FD) : _Colors.blue);
    final headColor = summer
        ? (dark ? const Color(0xFFFACC15) : const Color(0xFFEAB308))
        : (dark ? const Color(0xFF60A5FA) : _Colors.blue);
    final iconSize = 64 * s;

    Widget item(Widget icon, String label) => Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 8 * s),
              Text(
                _lab.lang == LabLang.en ? label.toUpperCase() : label,
                textAlign: TextAlign.center,
                style: TextStyle(color: labelColor, fontSize: 11.5 * f, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );

    final badge = Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.all(6 * s),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? const Color(0x80334155) : _Colors.slate100,
      ),
      child: CustomPaint(painter: summer ? _A3SunIconPainter() : _A3SnowIconPainter()),
    );
    final pie = SizedBox(
      width: iconSize,
      height: iconSize,
      child: CustomPaint(
        painter: _A3PiePainter(pct: summer ? 65 : 35, border: 4 * 96 / 64, inner: 0),
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            item(badge, _t(summer ? 'intense_sun' : 'spread_sun')),
            SizedBox(width: 32 * s),
            item(pie, _t(summer ? 'long_day' : 'short_day')),
          ],
        ),
        SizedBox(height: 16 * s),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _t(summer ? 'sum_season' : 'win_season'),
            style: TextStyle(
              color: headColor,
              fontSize: 28 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: const [Shadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          _t(summer ? 'sum_desc' : 'win_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? _Colors.slate300 : _Colors.slate600,
            fontSize: 14 * f,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- UI

  List<LabAction> _actions() {
    if (_type == _A3StepType.rotate && !_rotationStarted) {
      return [
        LabAction(
          label: _t('start_rotation'),
          icon: Icons.sync,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _startRotation,
        ),
      ];
    }
    if (_type == _A3StepType.summary && _summaryShown) return [_finishAction(_scenario)];
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
          onReset: _fullReset,
          overlays: [
            // Canvas bounds for the sunlight drop test.
            Positioned.fill(child: IgnorePointer(child: SizedBox.expand(key: _canvasKey))),
            if (_type == _A3StepType.dragSunlight) _sunToolOverlay(s, pad),
            // HTML #btn-start-rotation (bottom centre, above the HUD).
            if (_type == _A3StepType.rotate && !_rotationStarted && actions.isNotEmpty)
              Positioned(
                left: 12,
                right: 60 + pad.right,
                bottom: (_lab.isSidebarOpen ? 12 + 64 * s : 18) + pad.bottom,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(
                      key: const ValueKey('a3-start-rotation'),
                      action: actions.first,
                      scale: s * 1.1,
                      expand: false,
                    ),
                  ),
                ),
              ),
            if (_pieMounted) _pieOverlay(p, s, inset),
          ],
          stage: LayoutBuilder(builder: (context, box) => _stage(box)),
        );
      },
    );
  }

  /// HTML `#sunlight-tool` + its drag ghost (top-left of the canvas like
  /// the HTML; bottom-left while the floating mission card is there).
  Widget _sunToolOverlay(double s, EdgeInsets pad) {
    final ts = s.clamp(0.85, 1.3);
    final enabled = _toolEnabled;
    Widget tool(double pulse) => _A3SunTool(
          title: _t('tool_sunlight'),
          hint: _t('drag_drop'),
          scale: ts,
          pulse: enabled ? pulse : 0,
        );
    final card = ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, time, _) {
        final pulse = 0.5 + 0.5 * math.sin(time * 3.2);
        return Draggable<int>(
          key: const ValueKey('a3-sun-tool'),
          data: 0,
          maxSimultaneousDrags: enabled ? 1 : 0,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: _A3SunGhost(scale: ts),
          ),
          childWhenDragging: Opacity(opacity: 0.5, child: tool(0)),
          onDragStarted: () => _Audio.play(_Sound.pickup),
          onDragEnd: (d) => _onToolDropped(d.offset),
          child: tool(pulse),
        );
      },
    );
    if (_lab.isSidebarOpen) {
      return Positioned(left: 12, top: 12 + pad.top, child: card);
    }
    return Positioned(left: 12 + pad.left, bottom: 16 + pad.bottom, child: card);
  }

  /// HTML `#pie-chart-ui` (top right, fades / scales in over 300 ms).
  Widget _pieOverlay(LabPalette p, double s, EdgeInsets inset) {
    final ps = s.clamp(0.8, 1.25);
    return Positioned(
      top: inset.top + 40 * ps,
      right: inset.right + 4,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _pieShown ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedScale(
            scale: _pieShown ? 1 : 0.95,
            duration: const Duration(milliseconds: 300),
            child: AnimatedBuilder(
              animation: _rotAnim,
              builder: (context, _) => _A3PieCard(
                title: _t('day_night_cycle'),
                day: _t('pie_day'),
                night: _t('pie_night'),
                india: _t('pie_india'),
                pct: _dayPct,
                palette: p,
                scale: ps,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The 3D scene. Labels grow when the stage is drawn small so they keep
  /// roughly the HTML's fixed on-screen size.
  Widget _stage(BoxConstraints box) {
    final fit = math.min(box.maxWidth / _kA3Design.width, box.maxHeight / _kA3Design.height);
    final ls = fit > 0 && fit.isFinite ? (0.84 / fit).clamp(1.0, 2.0) : 1.0;
    _scene.uiScale = ls;
    // Room for the floating mission card (top-left) while the sidebar is
    // collapsed; the tool column leaves free space on the right then.
    _scene.viewShiftTarget = !_lab.isSidebarOpen && _lab.isLabActive ? const Offset(90, 24) : Offset.zero;
    return LabStage(
      designSize: _kA3Design,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _A3GrabRecognizer: GestureRecognizerFactoryWithHandlers<_A3GrabRecognizer>(
            _A3GrabRecognizer.new,
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
          key: _paintKey,
          size: _kA3Design,
          painter: _A3Painter(
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
}

// ============================================================ STRINGS
//
// Copied from the HTML `i18n` table (Telugu dropped). Strings that the
// HTML hard-coded (pie chart "Day" / "Night" / "INDIA") are added at the end.

const LabStringTable _i18n = {
  'en': {
    'app_title': "The Earth's Axial Tilt and Seasons",
    'app_subtitle': 'Class 7 • Earth, Moon and the Sun',
    'scen_1_opt': 'Scenario 1: Summer in NH (June)',
    'scen_2_opt': 'Scenario 2: Winter in NH (December)',
    'tool_sunlight': 'Sunlight Tool',
    'drag_drop': 'Drag & Drop',
    'day_night_cycle': 'Day & Night Cycle',
    'start_rotation': 'Start Rotation',
    'observation_complete': 'Observation Complete',
    'btn_next': 'Next Scenario',
    'btn_restart': 'Restart Lab',
    'lbl_sun': 'Sun',
    'lbl_earth': 'Earth',
    'month_jun': 'June',
    'month_dec': 'December',
    'feedback_snap_june': 'Earth snapped to June position!',
    'feedback_snap_dec': 'Earth snapped to December position!',
    'feedback_direct': 'Direct Sunlight = More Intense Heat!',
    'feedback_angled': 'Angled Sunlight = Less Intense Heat!',
    'feedback_wrong_hemi': 'Try dropping the sunlight on the other hemisphere!',
    'feedback_wrong_marker': 'Drag Earth to the highlighted marker!',
    'sum_season': 'SUMMER',
    'win_season': 'WINTER',
    'sum_desc':
        'When the Northern Hemisphere is tilted TOWARDS the Sun, it gets more intense sunlight and longer days. This causes SUMMER.',
    'win_desc':
        'When the Northern Hemisphere is tilted AWAY from the Sun, it gets less intense sunlight and shorter days. This causes WINTER.',
    'intense_sun': 'Intense Sun',
    'long_day': 'Long Day',
    'spread_sun': 'Spread-out Sun',
    'short_day': 'Short Day',
    // Hard-coded in the HTML pie chart.
    'pie_day': 'Day',
    'pie_night': 'Night',
    'pie_india': 'INDIA',
  },
  'hi': {
    'app_title': 'पृथ्वी का अक्षीय झुकाव और ऋतुएं',
    'app_subtitle': 'कक्षा 7 • पृथ्वी, चंद्रमा और सूर्य',
    'scen_1_opt': 'परिदृश्य 1: उत्तरी गोलार्ध में गर्मी (जून)',
    'scen_2_opt': 'परिदृश्य 2: उत्तरी गोलार्ध में सर्दी (दिसंबर)',
    'tool_sunlight': 'धूप का उपकरण',
    'drag_drop': 'खींचें और छोड़ें',
    'day_night_cycle': 'दिन और रात का चक्र',
    'start_rotation': 'घूर्णन शुरू करें',
    'observation_complete': 'अवलोकन पूर्ण',
    'btn_next': 'अगला परिदृश्य',
    'btn_restart': 'लैब रीस्टार्ट करें',
    'lbl_sun': 'सूर्य',
    'lbl_earth': 'पृथ्वी',
    'month_jun': 'जून',
    'month_dec': 'दिसंबर',
    'feedback_snap_june': 'पृथ्वी जून की स्थिति में आ गई!',
    'feedback_snap_dec': 'पृथ्वी दिसंबर की स्थिति में आ गई!',
    'feedback_direct': 'सीधी धूप = अधिक तीव्र गर्मी!',
    'feedback_angled': 'तिरछी धूप = कम तीव्र गर्मी!',
    'feedback_wrong_hemi': 'धूप को दूसरे गोलार्ध पर छोड़ने का प्रयास करें!',
    'feedback_wrong_marker': 'पृथ्वी को हाइलाइट किए गए मार्कर पर खींचें!',
    'sum_season': 'गर्मी (SUMMER)',
    'win_season': 'सर्दी (WINTER)',
    'sum_desc':
        'जब उत्तरी गोलार्ध सूर्य की ओर झुका होता है, तो इसे अधिक तीव्र धूप और लंबे दिन मिलते हैं। इससे गर्मी होती है।',
    'win_desc':
        'जब उत्तरी गोलार्ध सूर्य से दूर झुका होता है, तो इसे कम तीव्र धूप और छोटे दिन मिलते हैं। इससे सर्दी होती है।',
    'intense_sun': 'तेज़ धूप',
    'long_day': 'लंबा दिन',
    'spread_sun': 'फैली हुई धूप',
    'short_day': 'छोटा दिन',
    'pie_day': 'दिन',
    'pie_night': 'रात',
    'pie_india': 'भारत',
  },
};

// ========================================================== SCENARIOS
//
// HTML `ScenariosData` + the step texts (concept / action / observation).

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually understand why the Northern Hemisphere experiences summer when it is tilted towards the Sun.',
      steps: [
        LabStep(
          concept: 'June Position (Summer in NH)',
          action: "DRAG the 3D model of the Earth and DROP it onto the glowing marker labeled 'June'.",
          observation:
              "The Earth model snaps into the 'June' position. The Northern Hemisphere is visibly tilted towards the Sun.",
        ),
        LabStep(
          concept: 'Direct Sunlight',
          action: 'DRAG the Sunlight Tool and DROP it onto the Northern Hemisphere.',
          observation: 'A concentrated beam of light hits the surface. Direct Sunlight = More Intense Heat.',
        ),
        LabStep(
          concept: 'Angled Sunlight',
          action: 'DRAG the Sunlight Tool and DROP it onto the Southern Hemisphere.',
          observation: 'The light hits at an angle and spreads out. Angled Sunlight = Less Intense Heat.',
        ),
        LabStep(
          concept: 'Day & Night Cycle',
          action: "CLICK the 'Start Rotation' button to observe the day/night cycle for India.",
          observation: 'India spends more time in the illuminated half (Day) than in the dark half (Night).',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the summary panel.',
          observation: 'When the Northern Hemisphere is tilted towards the Sun, it experiences Summer.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually understand why the Northern Hemisphere experiences winter when it is tilted away from the Sun.',
      steps: [
        LabStep(
          concept: 'December Position (Winter in NH)',
          action: "DRAG the 3D model of the Earth and DROP it onto the glowing marker labeled 'December'.",
          observation:
              "The Earth model snaps into the 'December' position. The Northern Hemisphere is tilted away from the Sun.",
        ),
        LabStep(
          concept: 'Angled Sunlight',
          action: 'DRAG the Sunlight Tool and DROP it onto the Northern Hemisphere.',
          observation: 'The light hits at an angle and spreads out. Angled Sunlight = Less Intense Heat.',
        ),
        LabStep(
          concept: 'Direct Sunlight',
          action: 'DRAG the Sunlight Tool and DROP it onto the Southern Hemisphere.',
          observation: 'A concentrated beam of light hits the surface. Direct Sunlight = More Intense Heat.',
        ),
        LabStep(
          concept: 'Day & Night Cycle',
          action: "CLICK the 'Start Rotation' button to observe the day/night cycle for India.",
          observation: 'India spends less time in the illuminated half (Day) than in the dark half (Night).',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the summary panel.',
          observation: 'When the Northern Hemisphere is tilted away from the Sun, it experiences Winter.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'यह समझना कि जब उत्तरी गोलार्ध सूर्य की ओर झुका होता है, तो वहां गर्मी क्यों होती है।',
      steps: [
        LabStep(
          concept: 'जून की स्थिति (उत्तरी गोलार्ध में गर्मी)',
          action: "पृथ्वी के 3D मॉडल को 'जून' मार्कर पर खींचें।",
          observation: "पृथ्वी मॉडल 'जून' की स्थिति में आ जाता है। उत्तरी गोलार्ध स्पष्ट रूप से सूर्य की ओर झुका हुआ है।",
        ),
        LabStep(
          concept: 'सीधी धूप',
          action: 'धूप के उपकरण को उत्तरी गोलार्ध पर खींचें और छोड़ें।',
          observation: 'प्रकाश की एक केंद्रित किरण सतह पर पड़ती है। सीधी धूप = अधिक तीव्र गर्मी।',
        ),
        LabStep(
          concept: 'तिरछी धूप',
          action: 'धूप के उपकरण को दक्षिणी गोलार्ध पर खींचें और छोड़ें।',
          observation: 'प्रकाश एक कोण पर पड़ता है और फैल जाता है। तिरछी धूप = कम तीव्र गर्मी।',
        ),
        LabStep(
          concept: 'दिन और रात का चक्र',
          action: "भारत के लिए दिन/रात चक्र देखने के लिए 'घूर्णन शुरू करें' पर क्लिक करें।",
          observation: 'भारत अंधेरे आधे (रात) की तुलना में प्रकाशित आधे (दिन) में अधिक समय बिताता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश पैनल देखें।',
          observation: 'जब उत्तरी गोलार्ध सूर्य की ओर झुका होता है, तो वहां गर्मी होती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'यह समझना कि जब उत्तरी गोलार्ध सूर्य से दूर झुका होता है, तो वहां सर्दी क्यों होती है।',
      steps: [
        LabStep(
          concept: 'दिसंबर की स्थिति (उत्तरी गोलार्ध में सर्दी)',
          action: "पृथ्वी के 3D मॉडल को 'दिसंबर' मार्कर पर खींचें।",
          observation: "पृथ्वी मॉडल 'दिसंबर' की स्थिति में आ जाता है। उत्तरी गोलार्ध सूर्य से दूर झुका हुआ है।",
        ),
        LabStep(
          concept: 'तिरछी धूप',
          action: 'धूप के उपकरण को उत्तरी गोलार्ध पर खींचें और छोड़ें।',
          observation: 'प्रकाश एक कोण पर पड़ता है और फैल जाता है। तिरछी धूप = कम तीव्र गर्मी।',
        ),
        LabStep(
          concept: 'सीधी धूप',
          action: 'धूप के उपकरण को दक्षिणी गोलार्ध पर खींचें और छोड़ें।',
          observation: 'प्रकाश की एक केंद्रित किरण सतह पर पड़ती है। सीधी धूप = अधिक तीव्र गर्मी।',
        ),
        LabStep(
          concept: 'दिन और रात का चक्र',
          action: "भारत के लिए दिन/रात चक्र देखने के लिए 'घूर्णन शुरू करें' पर क्लिक करें।",
          observation: 'भारत प्रकाशित आधे (दिन) की तुलना में अंधेरे आधे (रात) में अधिक समय बिताता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश पैनल देखें।',
          observation: 'जब उत्तरी गोलार्ध सूर्य से दूर झुका होता है, तो वहां सर्दी होती है।',
        ),
      ],
    ),
  ],
};

/// HTML step `type`s, identical for both scenarios.
enum _A3StepType { dragEarth, dragSunlight, rotate, summary }

const List<_A3StepType> _kA3StepTypes = [
  _A3StepType.dragEarth,
  _A3StepType.dragSunlight,
  _A3StepType.dragSunlight,
  _A3StepType.rotate,
  _A3StepType.summary,
];

/// Step 2 targets the Northern Hemisphere, step 3 the Southern one. Direct
/// sunlight is expected on the NH in June (scenario 1, step 2) and on the
/// SH in December (scenario 2, step 3).
bool _a3TargetNorth(int step) => step == 2;
bool _a3ExpectDirect(int scenario, int step) => scenario == 0 ? step == 2 : step == 3;

// ======================================================== WORLD SETUP
//
// Same units as the Three.js scene: Sun at the origin, orbit radius 45,
// Earth radius 6, camera FOV 45°. June sits at -X (angle π), December at
// +X (angle 0); the Earth's position on the orbit is (45 cos a, 0, 45 sin a).

const Size _kA3Design = Size(1000, 560);
const double _kA3OrbitR = 45;
const double _kA3EarthR = 6;
const double _kA3SunR = 6;
const double _kA3GlowR = 24;
const double _kA3Tilt = -23.5 * math.pi / 180;
const double _kA3June = math.pi;
const double _kA3Dec = 0;
const double _kA3Fov = 45;
const _V3 _kA3OverviewEye = _V3(0, 70, 95);

/// The zoomed cameras look at the Earth from the side (Sun to one side,
/// axis tilt in the picture plane, day half and night half both visible)
/// and aim part of the way towards the Sun so it stays in frame.
const double _kA3SunlightShift = 0.35;
const double _kA3RotationShift = 0.1;

/// Projection centre, a little left of the stage centre so the scene stays
/// clear of the canvas tool column on the right.
const Offset _kA3ScreenCenter = Offset(470, 280);

/// Texture x of the HTML globe that the India pin sits on (Eurasia).
const double _kA3IndiaTexX = 734;

/// The Earth's axis. It keeps the same direction in space all year
/// (tilted 23.5° towards +X), so it leans towards the Sun in June and away
/// from it in December.
final _V3 _kA3Axis = const _V3(0, 1, 0).rotZ(_kA3Tilt);

/// India pin: latitude 20° N on the side facing the camera when spin = 0.
const double _kA3IndiaLat = 20 * math.pi / 180;

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  static const _V3 zero = _V3(0, 0, 0);

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

  /// Three.js `rotation.y = a`.
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  _V3 rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x, y * c - z * s, y * s + z * c);
  }

  /// Three.js `rotation.z = a`.
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

/// Perspective camera (Three.js PerspectiveCamera + lookAt) projecting
/// world points into the 1000 x 560 design space.
class _A3Cam {
  factory _A3Cam.lookAt(_V3 eye, _V3 target, {Offset shift = Offset.zero}) {
    final f = (target - eye).unit;
    var r = f.cross(const _V3(0, 1, 0));
    if (r.length < 1e-6) r = const _V3(1, 0, 0);
    r = r.unit;
    final u = r.cross(f);
    const half = 280.0;
    return _A3Cam._(eye, f, r, u, half / math.tan(_kA3Fov * math.pi / 360), _kA3ScreenCenter + shift);
  }

  _A3Cam._(this.eye, this.fwd, this.right, this.upv, this.focal, this.center);

  final _V3 eye, fwd, right, upv;
  final double focal;

  /// Screen point of the optical axis.
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

  /// Like [project] but never null (points behind are pushed forward).
  Offset projectSafe(_V3 p) {
    final c = toCam(p);
    return camToScreen(c.z <= near ? _V3(c.x, c.y, near) : c);
  }

  double depth(_V3 p) => (p - eye).dot(fwd);

  /// Design pixels per world unit at [p].
  double pxPerUnit(_V3 p) {
    final z = depth(p);
    return z <= near ? 0 : focal / z;
  }

  /// World direction of the ray through screen point [s].
  _V3 ray(Offset s) => (fwd * focal + right * (s.dx - center.dx) - upv * (s.dy - center.dy)).unit;

  /// Intersection of the ray through [s] with the plane y = [y]
  /// (the HTML `dragPlane`).
  _V3? planeHit(Offset s, [double y = 0]) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }
}

/// Earth mesh local direction -> world direction (mesh spin, then tilt).
_V3 _a3Orient(_V3 local, double spin) => local.rotY(spin).rotZ(_kA3Tilt);

/// Unit direction on the Earth mesh for a pixel of the HTML 1024 x 512
/// equirectangular texture (Three.js SphereGeometry UV layout).
_V3 _a3TexDir(double px, double py) {
  final phi = (px - (_kA3IndiaTexX - 256)) / 1024 * 2 * math.pi;
  final theta = (py.clamp(0.0, 512.0)) / 512 * math.pi;
  return _V3(-math.cos(phi) * math.sin(theta), math.cos(theta), math.sin(phi) * math.sin(theta));
}

/// The HTML `createEarthTexture()` continents: (cx, cy, rx, ry, rotation).
const List<(double, double, double, double, double)> _kA3Continents = [
  (200, 150, 120, 90, 0), // North America
  (250, 350, 80, 130, math.pi / 6), // South America
  (650, 150, 180, 110, 0), // Eurasia
  (550, 350, 110, 140, -math.pi / 6), // Africa
  (850, 400, 80, 60, 0), // Australia
];

/// A star of the background field (HTML `starGeo`, 1500 points).
class _A3Star {
  const _A3Star(this.p, this.tw);
  final _V3 p;
  final double tw;
}

/// Mutable scene model read by the painter every frame.
class _A3Scene {
  _A3Scene() {
    final rnd = math.Random(23);
    for (var i = 0; i < 1500; i++) {
      final r = 120 + rnd.nextDouble() * 200;
      final theta = 2 * math.pi * rnd.nextDouble();
      final phi = math.acos(2 * rnd.nextDouble() - 1);
      stars.add(_A3Star(
        _V3(r * math.sin(phi) * math.cos(theta), r * math.sin(phi) * math.sin(theta), r * math.cos(phi)),
        rnd.nextDouble() * 6.28,
      ));
    }
    for (final (cx, cy, rx, ry, rot) in _kA3Continents) {
      final pts = <_V3>[];
      const n = 72;
      for (var i = 0; i < n; i++) {
        final t = i / n * 2 * math.pi;
        final px = cx + rx * math.cos(t) * math.cos(rot) - ry * math.sin(t) * math.sin(rot);
        final py = cy + rx * math.cos(t) * math.sin(rot) + ry * math.sin(t) * math.cos(rot);
        pts.add(_a3TexDir(px, py));
      }
      continents.add(pts);
    }
  }

  final List<_A3Star> stars = [];
  final List<List<_V3>> continents = [];

  int scenario = 0;
  int step = 1;

  /// Seconds since the page opened.
  double time = 0;

  /// Earth's position on the orbit (HTML `-earthPivot.rotation.y`).
  double orbitAngle = _kA3Dec;

  /// Earth mesh spin about its axis (HTML `earthMesh.rotation.y`).
  double spin = 0;

  // Virtual camera (HTML camera.position / controls.target).
  _V3 eye = _kA3OverviewEye;
  _V3 target = _V3.zero;

  /// Orbit angle of the glowing, pulsing marker (step 1), or null.
  double? highlightAngle;
  double highlightSince = 0;

  bool earthGrabbed = false;

  /// Sunlight beam + decal (HTML `State.objects.beams`): world normal of
  /// the surface point that was hit.
  _V3? beamNormal;
  bool beamDirect = true;
  double beamSince = 0;

  /// Label / UI scale so canvas labels stay readable on small screens.
  double uiScale = 1;

  /// Screen shift of the whole view, eased towards [viewShiftTarget]
  /// (moves the scene out from under the floating mission card while the
  /// sidebar is collapsed).
  Offset viewShift = Offset.zero;
  Offset viewShiftTarget = Offset.zero;

  _V3 get earthPos => _V3(_kA3OrbitR * math.cos(orbitAngle), 0, _kA3OrbitR * math.sin(orbitAngle));
  _A3Cam get cam => _A3Cam.lookAt(eye, target, shift: viewShift);
  double get targetAngle => scenario == 0 ? _kA3June : _kA3Dec;
  double get startAngle => scenario == 0 ? _kA3Dec : _kA3June;

  /// Screen centre and radius of the Earth.
  ({Offset c, double r})? earthDisc() {
    final cam = this.cam;
    final e = earthPos;
    final c = cam.project(e);
    if (c == null) return null;
    return (c: c, r: _kA3EarthR * cam.pxPerUnit(e));
  }

  /// HTML raycast against `earthHitbox` (a sphere 1.5x the Earth).
  bool hitsEarthBox(Offset s) {
    final d = earthDisc();
    return d != null && (s - d.c).distance <= d.r * 1.5;
  }

  /// HTML raycast against `earthMesh`: world normal of the visible surface
  /// point under [s], or null when the ray misses the Earth.
  _V3? surfaceHit(Offset s) {
    final cam = this.cam;
    final d = cam.ray(s);
    final oc = cam.eye - earthPos;
    final b = d.dot(oc);
    final c = oc.dot(oc) - _kA3EarthR * _kA3EarthR;
    final disc = b * b - c;
    if (disc < 0) return null;
    final t = -b - math.sqrt(disc);
    if (t <= 0) return null;
    final p = cam.eye + d * t;
    return (p - earthPos).unit;
  }

  /// India pin direction (world) for the current spin.
  _V3 get indiaDir =>
      _a3Orient(_V3(0, math.sin(_kA3IndiaLat), math.cos(_kA3IndiaLat)), spin);
}

/// Camera framing for the sunlight steps (the HTML zooms to the Earth from
/// distance ≈ 43; here from the side so the sunlit half faces the viewer).
({_V3 eye, _V3 target}) _a3SunlightView(int scenario, _V3 earth) => (
      eye: earth + const _V3(0, 4, 40),
      target: earth + (_V3.zero - earth) * _kA3SunlightShift,
    );

/// Camera framing for the rotation (HTML distance ≈ 27, slightly above).
/// The Earth sits left of centre in both scenarios, leaving the top right
/// for the day / night pie chart.
({_V3 eye, _V3 target}) _a3RotationView(int scenario, _V3 earth) => (
      eye: earth + const _V3(0, 6, 26.3),
      target: earth + const _V3(_kA3OrbitR * _kA3RotationShift, 0, 0),
    );

/// Where the sunlight spot lands for a drop at surface normal [n]: the
/// same latitude, turned about the axis onto the sunlit side when the drop
/// was on (or near) the night side, so the beam from the Sun reaches it.
_V3 _a3LitSpot(_V3 n, _V3 toSun) {
  const want = 0.3;
  if (n.dot(toSun) >= want) return n;
  var best = n;
  var bestDot = n.dot(toSun);
  for (var i = 1; i <= 180; i++) {
    final a = i * math.pi / 180;
    for (final m in [n.rotAxis(_kA3Axis, a), n.rotAxis(_kA3Axis, -a)]) {
      final d = m.dot(toSun);
      if (d >= want) return m;
      if (d > bestDot) {
        bestDot = d;
        best = m;
      }
    }
  }
  return best;
}

// ============================================================ PAINTING
//
// Back-to-front rendering of the Three.js scene: star field, then three
// depth layers of thin geometry (orbit line, month markers, sunlight beam)
// interleaved with the two big bodies (Sun and Earth) in depth order, and
// finally the HTML labels on top.

const Color _kA3Ocean = Color(0xFF2550C8); // HTML #1e40af, sunlit
const Color _kA3Land = Color(0xFF1C7A41); // HTML #166534, sunlit
const Color _kA3Marker = Color(0xFF6366F1);
const Color _kA3MarkerOn = Color(0xFFFACC15);
const Color _kA3Orbit = Color(0xFF4F46E5);
const Color _kA3PinRed = Color(0xFFEF4444);

/// Depth classification against the Sun and the Earth.
class _A3Occ {
  _A3Occ(this.cam, this.earth, this.earthDepth, this.sunDepth);

  final _A3Cam cam;
  final _V3 earth;
  final double earthDepth;
  final double sunDepth;

  /// -1 when hidden (behind the camera or inside a body), otherwise the
  /// number of bodies the point is in front of (0, 1 or 2).
  int layer(_V3 p) {
    final d = cam.depth(p);
    if (d <= _A3Cam.near) return -1;
    if ((p - earth).length < _kA3EarthR) return -1;
    if (p.length < _kA3SunR) return -1;
    return (d < sunDepth ? 1 : 0) + (d < earthDepth ? 1 : 0);
  }
}

class _A3Painter extends CustomPainter {
  _A3Painter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.text,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _A3Scene scene;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) text;
  final double labelScale;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = scene;
    final cam = sc.cam;
    final t = sc.time;

    canvas.drawRect(labBleed(size), Paint()..color = const Color(0xFF020617));
    _paintStars(canvas, cam, t);

    final e = sc.earthPos;
    final occ = _A3Occ(cam, e, cam.depth(e), cam.depth(_V3.zero));
    final layers = [<VoidCallback>[], <VoidCallback>[], <VoidCallback>[]];
    _orbit(canvas, occ, layers);
    _markers(canvas, occ, layers, t);
    _beam(canvas, occ, layers, t);

    final sunFar = occ.sunDepth >= occ.earthDepth;
    void run(List<VoidCallback> fs) {
      for (final f in fs) {
        f();
      }
    }

    run(layers[0]);
    sunFar ? _paintSun(canvas, cam) : _paintEarth(canvas, cam, t);
    run(layers[1]);
    sunFar ? _paintEarth(canvas, cam, t) : _paintSun(canvas, cam);
    run(layers[2]);

    if (showLabels) _paintLabels(canvas, cam);
  }

  // ------------------------------------------------------------- stars

  /// HTML star field: 1500 points (size 0.8, opacity 0.6) slowly turning.
  void _paintStars(Canvas canvas, _A3Cam cam, double t) {
    final ry = t * 0.006, rx = t * 0.003;
    final buckets = [<Offset>[], <Offset>[], <Offset>[], <Offset>[]];
    const widths = [0.9, 1.3, 1.8, 2.4];
    for (final s in scene.stars) {
      final c = cam.toCam(s.p.rotY(ry).rotX(rx));
      if (c.z < 2) continue;
      final px = 0.8 * 280 / c.z * 1.4;
      final b = px < 1.0 ? 0 : (px < 1.5 ? 1 : (px < 2.1 ? 2 : 3));
      buckets[b].add(cam.camToScreen(c));
    }
    for (var i = 0; i < 4; i++) {
      if (buckets[i].isEmpty) continue;
      canvas.drawPoints(
        PointMode.points,
        buckets[i],
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = widths[i]
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // --------------------------------------------------------------- sun

  /// HTML "natural sun": white core (r 6) + additive glow sprite (48 wide).
  void _paintSun(Canvas canvas, _A3Cam cam) {
    final c = cam.project(_V3.zero);
    if (c == null) return;
    final k = cam.pxPerUnit(_V3.zero);
    final gr = _kA3GlowR * k;
    canvas.drawCircle(
      c,
      gr,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF096),
            Color(0xD9FFA000),
            Color(0x59FF3C00),
            Color(0x00FF0000),
          ],
          stops: [0, 0.1, 0.25, 0.5, 1],
        ).createShader(Rect.fromCircle(center: c, radius: gr)),
    );
    final cr = _kA3SunR * k;
    canvas.drawCircle(
      c,
      cr,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFDF2), Color(0xFFFFF3C4)],
          stops: [0, 0.75, 1],
        ).createShader(Rect.fromCircle(center: c, radius: cr)),
    );
  }

  // ------------------------------------------------- thin 3D geometry

  /// HTML orbit line (radius 45, #4f46e5 at 50 %).
  void _orbit(Canvas canvas, _A3Occ occ, List<List<VoidCallback>> layers) {
    const n = 160;
    final pts = [
      for (var i = 0; i <= n; i++)
        _V3(_kA3OrbitR * math.cos(i / n * 2 * math.pi), 0, _kA3OrbitR * math.sin(i / n * 2 * math.pi)),
    ];
    final paths = _polylineLayers(occ, pts);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..color = _kA3Orbit.withValues(alpha: 0.6);
    for (var l = 0; l < 3; l++) {
      final p = paths[l];
      if (p != null) layers[l].add(() => canvas.drawPath(p, paint));
    }
  }

  /// Splits a 3D polyline into one screen path per depth layer.
  List<Path?> _polylineLayers(_A3Occ occ, List<_V3> pts) {
    final out = List<Path?>.filled(3, null);
    var prevLayer = -2;
    for (var i = 0; i + 1 < pts.length; i++) {
      final a = pts[i], b = pts[i + 1];
      final l = occ.layer((a + b) * 0.5);
      if (l < 0) {
        prevLayer = -2;
        continue;
      }
      final path = out[l] ??= Path();
      final pb = occ.cam.projectSafe(b);
      if (l != prevLayer) {
        final pa = occ.cam.projectSafe(a);
        path.moveTo(pa.dx, pa.dy);
      }
      path.lineTo(pb.dx, pb.dy);
      prevLayer = l;
    }
    return out;
  }

  /// HTML month markers: flat rings (inner 5, outer 6) at y = -0.2. The
  /// step's target glows yellow and pulses in scale (1 → 1.3, 600 ms yoyo).
  void _markers(Canvas canvas, _A3Occ occ, List<List<VoidCallback>> layers, double t) {
    for (final angle in const [_kA3June, _kA3Dec]) {
      final on = scene.highlightAngle == angle;
      var s = 1.0;
      if (on) {
        final ph = ((t - scene.highlightSince) / 0.6) % 2;
        s = 1 + 0.3 * (ph < 1 ? ph : 2 - ph);
      }
      final m = _V3(_kA3OrbitR * math.cos(angle), -0.2, _kA3OrbitR * math.sin(angle));
      final paths = List<Path?>.filled(3, null);
      const n = 48;
      for (var i = 0; i < n; i++) {
        final a0 = i / n * 2 * math.pi, a1 = (i + 1) / n * 2 * math.pi;
        _V3 ring(double a, double r) => m + _V3(r * math.cos(a), 0, r * math.sin(a));
        final l = occ.layer(ring((a0 + a1) / 2, 5.5 * s));
        if (l < 0) continue;
        final quad = [
          occ.cam.projectSafe(ring(a0, 5 * s)),
          occ.cam.projectSafe(ring(a0, 6 * s)),
          occ.cam.projectSafe(ring(a1, 6 * s)),
          occ.cam.projectSafe(ring(a1, 5 * s)),
        ];
        (paths[l] ??= Path()).addPolygon(quad, true);
      }
      final color = on ? _kA3MarkerOn : _kA3Marker;
      final k = occ.cam.pxPerUnit(m);
      for (var l = 0; l < 3; l++) {
        final p = paths[l];
        if (p == null) continue;
        layers[l].add(() {
          if (on) {
            canvas.drawPath(
              p,
              Paint()
                ..color = color.withValues(alpha: 0.55)
                ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(3, 0.9 * k)),
            );
          }
          canvas.drawPath(p, Paint()..color = color);
        });
      }
    }
  }

  /// HTML sunlight beam: a cylinder (radius 1.5, #facc15, 30 %, additive)
  /// from the Sun's centre to the point that was hit. It grows out of the
  /// Sun in 0.35 s.
  void _beam(Canvas canvas, _A3Occ occ, List<List<VoidCallback>> layers, double t) {
    final n0 = scene.beamNormal;
    if (n0 == null) return;
    final grow = Curves.easeOutCubic.transform(((t - scene.beamSince) / 0.35).clamp(0.0, 1.0));
    final hit = occ.earth + n0 * _kA3EarthR;
    final end = hit * grow;
    const n = 64;
    final outer = List<Path?>.filled(3, null);
    final inner = List<Path?>.filled(3, null);
    for (var i = 0; i < n; i++) {
      final a = end * (i / n), b = end * ((i + 1) / n);
      final l = occ.layer((a + b) * 0.5);
      if (l < 0) continue;
      final pa = occ.cam.projectSafe(a), pb = occ.cam.projectSafe(b);
      var d = pb - pa;
      if (d.distance < 1e-3) d = const Offset(1, 0);
      final nrm = Offset(-d.dy, d.dx) / d.distance;
      final wa = 1.5 * occ.cam.pxPerUnit(a), wb = 1.5 * occ.cam.pxPerUnit(b);
      (outer[l] ??= Path()).addPolygon([pa + nrm * wa, pb + nrm * wb, pb - nrm * wb, pa - nrm * wa], true);
      (inner[l] ??= Path())
          .addPolygon([pa + nrm * wa * 0.4, pb + nrm * wb * 0.4, pb - nrm * wb * 0.4, pa - nrm * wa * 0.4], true);
    }
    for (var l = 0; l < 3; l++) {
      final o = outer[l], c = inner[l];
      if (o == null || c == null) continue;
      layers[l].add(() {
        canvas.drawPath(
          o,
          Paint()
            ..blendMode = BlendMode.plus
            ..color = const Color(0xFFFACC15).withValues(alpha: 0.3),
        );
        canvas.drawPath(
          c,
          Paint()
            ..blendMode = BlendMode.plus
            ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.22),
        );
      });
    }
  }

  // ------------------------------------------------------------- earth

  /// The tilted Earth: ocean + HTML texture continents, lit by the Sun
  /// (day half / night half), equator ring, axis line, India pin and the
  /// sunlight spot ("decal"). Visible-cap geometry keeps everything on the
  /// same perspective projection as the rest of the scene.
  void _paintEarth(Canvas canvas, _A3Cam cam, double t) {
    final sc = scene;
    final e = sc.earthPos;
    final toEye = cam.eye - e;
    final dist = toEye.length;
    if (dist <= _kA3EarthR * 1.05 || cam.depth(e) <= _A3Cam.near) return;
    final v = toEye * (1 / dist);
    final cosA = _kA3EarthR / dist;
    final sinA = math.sqrt(1 - cosA * cosA);
    var e1 = cam.upv.cross(v);
    if (e1.length < 1e-6) e1 = cam.right;
    e1 = e1.unit;
    final e2 = v.cross(e1);
    final k = cam.pxPerUnit(e);
    final light = (_V3.zero - e).unit;

    _V3 capDir(double rho, double phi) {
      final ang = math.asin((rho * sinA).clamp(0.0, 1.0));
      final dir = e1 * math.cos(phi) + e2 * math.sin(phi);
      return v * math.cos(ang) + dir * math.sin(ang);
    }

    Offset surf(_V3 n, [double lift = 0]) => cam.projectSafe(e + n * (_kA3EarthR + lift));

    // Hidden surface points are moved onto the silhouette (same azimuth).
    _V3 clampToCap(_V3 n) {
      final nv = n.dot(v);
      if (nv >= cosA) return n;
      var tang = n - v * nv;
      if (tang.length < 1e-6) tang = e1;
      return v * cosA + tang.unit * sinA;
    }

    bool visible(_V3 n) => n.dot(v) > cosA;

    const ns = 96;
    final rim = Path();
    for (var j = 0; j < ns; j++) {
      final p = surf(capDir(1, j / ns * 2 * math.pi));
      j == 0 ? rim.moveTo(p.dx, p.dy) : rim.lineTo(p.dx, p.dy);
    }
    rim.close();
    final c = cam.projectSafe(e);
    final r = _kA3EarthR * k;

    // Drag affordance (step 1) and "grabbed" highlight.
    if (sc.step == 1 && sc.highlightAngle != null) {
      final pulse = (t * 0.7) % 1;
      canvas.drawCircle(
        c,
        r * (1.15 + 0.35 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sc.earthGrabbed ? 3 : 2
          ..color = (sc.earthGrabbed ? _kA3MarkerOn : const Color(0xFF93C5FD))
              .withValues(alpha: (sc.earthGrabbed ? 0.9 : 0.6) * (1 - pulse)),
      );
    }

    // 1. Parts behind the globe (drawn first so the globe hides them).
    final axis = _kA3Axis;
    if (!visible(axis)) _axisStub(canvas, cam, e, axis, k);
    if (!visible(-axis)) _axisStub(canvas, cam, e, -axis, k);
    final india = sc.indiaDir;
    if (!visible(india)) _pin(canvas, cam, e, india, v);

    // 2. Ocean and continents (HTML canvas texture).
    canvas.drawPath(rim, Paint()..color = _kA3Ocean);
    canvas.save();
    canvas.clipPath(rim);
    final land = Paint()..color = _kA3Land;
    final coast = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, 0.05 * k)
      ..color = const Color(0xFF2E9E5B);
    for (final outline in sc.continents) {
      final world = [for (final p in outline) _a3Orient(p, sc.spin)];
      if (!world.any(visible)) continue;
      final path = Path()..addPolygon([for (final n in world) surf(clampToCap(n))], true);
      canvas.drawPath(path, land);
      canvas.drawPath(path, coast);
    }

    // 3. Sunlight: ambient 0.15 + point light from the Sun (night side).
    _shade(canvas, capDir, surf, light);
    canvas.restore();

    // 4. Thin atmosphere, brighter on the sunlit limb.
    final ls = Offset(light.dot(e1), -light.dot(e2));
    final dir = ls.distance < 1e-3 ? const Offset(1, 0) : ls / ls.distance;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, 0.07 * r)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(1.5, 0.05 * r))
        ..shader = LinearGradient(
          begin: Alignment(-dir.dx, -dir.dy),
          end: Alignment(dir.dx, dir.dy),
          colors: const [Color(0x0038BDF8), Color(0x0038BDF8), Color(0xAA7DD3FC)],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );

    // 5. Equator ring (white, 50 %), front half only.
    final q1 = const _V3(0, 0, 1);
    final q2 = axis.cross(q1);
    final eq = Path();
    var drawing = false;
    const ne = 120;
    for (var i = 0; i <= ne; i++) {
      final a = i / ne * 2 * math.pi;
      final n = q1 * math.cos(a) + q2 * math.sin(a);
      if (!visible(n)) {
        drawing = false;
        continue;
      }
      final p = surf(n, 0.075);
      drawing ? eq.lineTo(p.dx, p.dy) : eq.moveTo(p.dx, p.dy);
      drawing = true;
    }
    canvas.drawPath(
      eq,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.1, 0.06 * k)
        ..color = Colors.white.withValues(alpha: 0.5),
    );

    // 6. Sunlight spot: white circle (direct) or a pale yellow ellipse
    //    stretched 2.5x (angled), fading in when the beam arrives.
    final hn = sc.beamNormal;
    if (hn != null) {
      final a = ((t - sc.beamSince - 0.3) / 0.25).clamp(0.0, 1.0);
      if (a > 0) {
        var bx = const _V3(0, 1, 0).cross(hn);
        if (bx.length < 1e-6) bx = const _V3(1, 0, 0);
        bx = bx.unit;
        final by = hn.cross(bx);
        final sy = sc.beamDirect ? 1.0 : 2.5;
        final col = sc.beamDirect ? Colors.white : const Color(0xFFFEF08A);
        final pts = <Offset>[];
        for (var i = 0; i < 48; i++) {
          final ang = i / 48 * 2 * math.pi;
          final off = bx * (1.8 * math.cos(ang)) + by * (1.8 * sy * math.sin(ang));
          pts.add(surf(clampToCap((hn * _kA3EarthR + off).unit), 0.1));
        }
        final spot = Path()..addPolygon(pts, true);
        canvas.drawPath(
          spot,
          Paint()
            ..color = col.withValues(alpha: 0.6 * a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(3, 0.5 * k)),
        );
        canvas.save();
        canvas.clipPath(rim);
        canvas.drawPath(spot, Paint()..color = col.withValues(alpha: 0.9 * a));
        canvas.restore();
      }
    }

    // 7. Front parts: visible axis halves and the India pin.
    if (visible(axis)) _axisStub(canvas, cam, e, axis, k);
    if (visible(-axis)) _axisStub(canvas, cam, e, -axis, k);
    if (visible(india)) _pin(canvas, cam, e, india, v);
  }

  /// Day / night shading as a vertex-coloured mesh over the visible cap.
  void _shade(
    Canvas canvas,
    _V3 Function(double rho, double phi) capDir,
    Offset Function(_V3 n, [double lift]) surf,
    _V3 light,
  ) {
    const nr = 16, nphi = 56;
    final count = 1 + nr * nphi;
    final pos = Float32List(count * 2);
    final cols = Int32List(count);
    void put(int i, _V3 n) {
      final p = surf(n);
      pos[i * 2] = p.dx;
      pos[i * 2 + 1] = p.dy;
      final b = (0.15 + 1.55 * math.max(0.0, n.dot(light))).clamp(0.0, 1.0);
      final alpha = ((1 - b) * 0.97 * 255).round();
      cols[i] = (alpha << 24) | 0x00020617;
    }

    put(0, capDir(0, 0));
    for (var i = 1; i <= nr; i++) {
      for (var j = 0; j < nphi; j++) {
        put(1 + (i - 1) * nphi + j, capDir(i / nr, j / nphi * 2 * math.pi));
      }
    }
    final idx = <int>[];
    for (var j = 0; j < nphi; j++) {
      idx.addAll([0, 1 + j, 1 + (j + 1) % nphi]);
    }
    for (var i = 1; i < nr; i++) {
      final a = 1 + (i - 1) * nphi, b = 1 + i * nphi;
      for (var j = 0; j < nphi; j++) {
        final j1 = (j + 1) % nphi;
        idx.addAll([a + j, b + j, b + j1, a + j, b + j1, a + j1]);
      }
    }
    canvas.drawVertices(
      Vertices.raw(VertexMode.triangles, pos, colors: cols, indices: Uint16List.fromList(idx)),
      BlendMode.dst,
      Paint(),
    );
  }

  /// HTML axis line (cylinder r 0.1, 18 long): the part outside the globe
  /// on the side of [d].
  void _axisStub(Canvas canvas, _A3Cam cam, _V3 e, _V3 d, double k) {
    final a = cam.projectSafe(e + d * _kA3EarthR);
    final b = cam.projectSafe(e + d * (_kA3EarthR * 1.5));
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = math.max(1.6, 0.2 * k)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  /// HTML India pin: red cone (r 0.5, h 1.2) pointing outwards with a red
  /// ball (r 0.3) on its tip.
  void _pin(Canvas canvas, _A3Cam cam, _V3 e, _V3 n, _V3 v) {
    final base = e + n * _kA3EarthR;
    final apex = e + n * (_kA3EarthR + 1.2);
    final b = cam.projectSafe(base), a = cam.projectSafe(apex);
    final kb = cam.pxPerUnit(base);
    var d = a - b;
    if (d.distance < 0.5) d = const Offset(0, -1);
    final u = d / d.distance;
    final pn = Offset(-u.dy, u.dx);
    final hw = math.max(2.2, 0.5 * kb);
    final squash = math.max(0.25, n.dot(v).abs());
    final cone = Path()
      ..moveTo(b.dx + pn.dx * hw, b.dy + pn.dy * hw)
      ..lineTo(a.dx, a.dy)
      ..lineTo(b.dx - pn.dx * hw, b.dy - pn.dy * hw)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          colors: [labShade(_kA3PinRed, 0.2), _kA3PinRed, labShade(_kA3PinRed, -0.35)],
        ).createShader(Rect.fromPoints(b - pn * hw, b + pn * hw)),
    );
    canvas.save();
    canvas.translate(b.dx, b.dy);
    canvas.rotate(math.atan2(pn.dy, pn.dx));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: hw * 2, height: hw * 2 * squash),
      Paint()..color = labShade(_kA3PinRed, -0.2),
    );
    canvas.restore();
    labSphere(canvas, a, math.max(2.2, 0.3 * cam.pxPerUnit(apex)) * 1.15, _kA3PinRed, highlight: 0.5);
  }

  // ------------------------------------------------------------ labels

  /// HTML `createHtmlLabel` chips: Sun (+8 above), Earth (+8 above) and the
  /// month markers (6 below).
  void _paintLabels(Canvas canvas, _A3Cam cam) {
    final ls = labelScale;
    void chip(_V3 at, String key, double size, Color fg, Color bg, Color border, {bool round = true}) {
      final p = cam.project(at);
      if (p == null) return;
      labText(
        canvas,
        lang == LabLang.en ? text(key).toUpperCase() : text(key),
        p,
        size: size * ls,
        weight: FontWeight.w800,
        color: fg,
        background: bg,
        border: border,
        borderWidth: 1,
        letterSpacing: lang == LabLang.en ? 1.6 * ls : 0,
        radius: round ? 999 : 5 * ls,
        padding: EdgeInsets.symmetric(horizontal: 11 * ls, vertical: 4 * ls),
      );
    }

    for (final (angle, key) in const [(_kA3June, 'month_jun'), (_kA3Dec, 'month_dec')]) {
      chip(
        _V3(_kA3OrbitR * math.cos(angle), -7.6, _kA3OrbitR * math.sin(angle)),
        key,
        12,
        Colors.white,
        const Color(0xE60F172A),
        const Color(0x8094A3B8),
        round: false,
      );
    }
    chip(const _V3(0, 8, 0), 'lbl_sun', 14, const Color(0xFFFDE047), const Color(0xCC713F12),
        const Color(0x80FACC15));
    chip(scene.earthPos + const _V3(0, 8, 0), 'lbl_earth', 12, const Color(0xFFDBEAFE),
        const Color(0xCC1E3A8A), const Color(0x8060A5FA));
  }

  @override
  bool shouldRepaint(covariant _A3Painter old) =>
      old.scene != scene ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

// ========================================================= CANVAS UI

/// HTML `#sunlight-tool`: flashlight card ("Sunlight Tool" / "Drag & Drop")
/// with a gently pulsing border while it waits to be dragged.
class _A3SunTool extends StatelessWidget {
  const _A3SunTool({
    required this.title,
    required this.hint,
    required this.scale,
    required this.pulse,
  });

  final String title;
  final String hint;
  final double scale;

  /// 0..1 glow phase.
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(maxWidth: 112 * s),
      padding: EdgeInsets.fromLTRB(10 * s, 10 * s, 10 * s, 8 * s),
      decoration: BoxDecoration(
        color: const Color(0xE61E293B),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: Color.lerp(const Color(0x806366F1), const Color(0xFFFACC15), pulse)!,
          width: 1.5,
        ),
        boxShadow: [
          const BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
          BoxShadow(color: const Color(0xFFFACC15).withValues(alpha: 0.25 * pulse), blurRadius: 14 * s),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(7 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Icon(Icons.flashlight_on, size: 28 * s, color: const Color(0xFFFACC15)),
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFA5B4FC),
              fontSize: 10 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xCC94A3B8), fontSize: 9.5 * s, height: 1.2),
          ),
        ],
      ),
    );
  }
}

/// HTML `#sunlight-tool-ghost`: the glowing flashlight under the finger.
class _A3SunGhost extends StatelessWidget {
  const _A3SunGhost({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale * 1.1;
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.all(12 * s),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33EAB308),
          border: Border.all(color: const Color(0x80FACC15), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x55FACC15), blurRadius: 18)],
        ),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Icon(
            Icons.flashlight_on,
            size: 36 * s,
            color: const Color(0xFFFACC15),
            shadows: const [Shadow(color: Color(0xCCFACC15), blurRadius: 10)],
          ),
        ),
      ),
    );
  }
}

/// HTML `#pie-chart-ui`: "Day & Night Cycle" with a conic pie for India.
class _A3PieCard extends StatelessWidget {
  const _A3PieCard({
    required this.title,
    required this.day,
    required this.night,
    required this.india,
    required this.pct,
    required this.palette,
    required this.scale,
  });

  final String title, day, night, india;

  /// Day share, 0..100.
  final double pct;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final dark = palette.isDark;
    final size = 86 * s;
    Widget legend(Color sq, String label, Color fg) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8 * s,
              height: 8 * s,
              decoration: BoxDecoration(color: sq, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(width: 4 * s),
            Text(label, style: TextStyle(color: fg, fontSize: 10.5 * s, fontWeight: FontWeight.w800)),
          ],
        );
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: dark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0x4D6366F1)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 130 * s),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dark ? const Color(0xFFA5B4FC) : _Colors.indigo600,
                fontSize: 10.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _A3PiePainter(pct: pct),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: const Color(0xFFEF4444), size: 18 * s),
                    Text(
                      india,
                      style: TextStyle(color: Colors.white, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              legend(const Color(0xFFFACC15), day, dark ? const Color(0xFFFACC15) : const Color(0xFFEAB308)),
              SizedBox(width: 16 * s),
              legend(_Colors.slate700, night, dark ? _Colors.slate400 : _Colors.slate500),
            ],
          ),
        ],
      ),
    );
  }
}

/// Conic pie: yellow day share from 12 o'clock clockwise, slate night,
/// slate-700 border and a slate-900 centre.
class _A3PiePainter extends CustomPainter {
  _A3PiePainter({required this.pct, this.border = 4, this.inner = 40 / 48});

  final double pct;
  final double border;
  final double inner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final bw = border * size.shortestSide / 96;
    canvas.drawCircle(c, r, Paint()..color = _Colors.slate700);
    final pr = r - bw;
    canvas.drawCircle(c, pr, Paint()..color = _Colors.slate800);
    final sweep = (pct / 100).clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: pr), -math.pi / 2, sweep, true,
          Paint()..color = const Color(0xFFFACC15));
    }
    if (inner > 0) {
      canvas.drawCircle(c, r * inner, Paint()..color = _Colors.slate900);
    }
  }

  @override
  bool shouldRepaint(covariant _A3PiePainter old) => old.pct != pct;
}

// ======================================================= SUMMARY ICONS

/// HTML `SVGs.sun` (24 x 24 viewBox).
class _A3SunIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final ray = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const lines = [
      (12.0, 2.0, 12.0, 4.0), (12.0, 20.0, 12.0, 22.0), //
      (4.93, 4.93, 6.34, 6.34), (17.66, 17.66, 19.07, 19.07),
      (2.0, 12.0, 4.0, 12.0), (20.0, 12.0, 22.0, 12.0),
      (4.93, 19.07, 6.34, 17.66), (17.66, 6.34, 19.07, 4.93),
    ];
    for (final (x1, y1, x2, y2) in lines) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), ray);
    }
    canvas.drawCircle(const Offset(12, 12), 5, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(
      const Offset(12, 12),
      5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFEF08A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// HTML `SVGs.snowflake` (24 x 24 viewBox).
class _A3SnowIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF93C5FD)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const segs = [
      (12.0, 3.0, 12.0, 21.0), (12.0, 3.0, 10.5, 4.5), (12.0, 3.0, 13.5, 4.5), //
      (12.0, 21.0, 10.5, 19.5), (12.0, 21.0, 13.5, 19.5),
      (20.4904, 7.5, 3.50962, 16.5), (20.4904, 7.5, 18.9904, 9.0), (20.4904, 7.5, 18.9904, 6.0),
      (3.50962, 16.5, 5.00962, 15.0), (3.50962, 16.5, 5.00962, 18.0),
      (3.50962, 7.5, 20.4904, 16.5), (3.50962, 7.5, 5.00962, 6.0), (3.50962, 7.5, 5.00962, 9.0),
      (20.4904, 16.5, 18.9904, 18.0), (20.4904, 16.5, 18.9904, 15.0),
    ];
    for (final (x1, y1, x2, y2) in segs) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
    canvas.drawCircle(const Offset(12, 12), 2, Paint()..color = const Color(0xFFBFDBFE));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
