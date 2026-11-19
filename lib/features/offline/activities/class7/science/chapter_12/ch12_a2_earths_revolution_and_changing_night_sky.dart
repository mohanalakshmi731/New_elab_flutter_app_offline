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

/// Class 7 Science • Chapter 12 • Activity 2
/// Earth's Revolution and Changing Night Sky.
///
/// Native Flutter port of
/// `Cl7S-Ch12-A2-Earth_s_Revolution_and_Changing_Night_Sky.html`.
/// Scenario 1 (Orbit View): drag the Earth around its orbit to the March,
/// June, September and December markers; the Night Sky View shows Leo,
/// Scorpius, Pegasus and Orion, then "Play" runs a full revolution.
/// Scenario 2 (Ground View): pick months on the calendar and watch the 9 PM
/// sky drift from one constellation to the next above a fixed landscape.
class Ch12A2EarthsRevolutionAndChangingNightSkyPage extends StatefulWidget {
  const Ch12A2EarthsRevolutionAndChangingNightSkyPage({super.key});

  @override
  State<Ch12A2EarthsRevolutionAndChangingNightSkyPage> createState() =>
      _Ch12A2EarthsRevolutionAndChangingNightSkyPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, whoosh 1492.
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
  static const Color amber = Color(0xFFF59E0B);
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

/// Pan recognizer that only claims touches starting on the Earth, so
/// empty-canvas drags still pan the zoomed canvas.
class _A2GrabRecognizer extends PanGestureRecognizer {
  _A2GrabRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

const Color _kIndigo600 = Color(0xFF4F46E5);
const Color _kIndigo400 = Color(0xFF818CF8);
const Color _kAmber400 = Color(0xFFFBBF24);

class _Ch12A2EarthsRevolutionAndChangingNightSkyPageState
    extends State<Ch12A2EarthsRevolutionAndChangingNightSkyPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A2Scene _scene = _A2Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;

  /// Earth snapping onto a month marker (300 ms, Quadratic.Out).
  late final AnimationController _snap;

  /// Full counter-clockwise revolution (6000 ms, linear).
  late final AnimationController _play;

  /// Ground-view camera pan to a month (1500 ms, Cubic.InOut).
  late final AnimationController _pan;

  /// Ground-view camera pulling back from z 0 to 50 (1000 ms, Cubic.Out).
  late final AnimationController _dolly;

  /// Constellation line drawing in the Night Sky View (2 s, ease).
  late final AnimationController _draw;

  double _snapFrom = 0, _snapTo = 0, _playFrom = 0, _panFrom = 0, _panTo = 0;

  /// Night Sky View (HTML `#s1-night-sky-popup`).
  int? _pipMonth;
  bool _pipShown = false;

  /// Marker the Earth was on in the last frame (sidebar readout).
  int? _lastNear;

  bool _concluded = false;
  bool _played = false;

  /// Calendar widget drag offset (HTML: draggable on phones).
  Offset _calDrag = Offset.zero;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);

  /// Letter spacing for Latin text only (it breaks the Devanagari headline).
  double _track(double v) => _lab.lang == LabLang.en ? v : 0;
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scene.reset(0);
    _lastNear = _scene.nearMonth;
    _ticker = createTicker(_onTick)..start();

    _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        final v = Curves.easeOutQuad.transform(_snap.value);
        _scene.earthAngle = _snapFrom + (_snapTo - _snapFrom) * v;
      });
    _play = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))
      ..addListener(() => _scene.earthAngle = _playFrom + math.pi * 2 * _play.value);
    _pan = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..addListener(() {
        final v = Curves.easeInOutCubic.transform(_pan.value);
        _scene.camX = _panFrom + (_panTo - _panFrom) * v;
      });
    _dolly = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() => _scene.camZ = 50 * Curves.easeOutCubic.transform(_dolly.value));
    _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _snap.dispose();
    _play.dispose();
    _pan.dispose();
    _dolly.dispose();
    _draw.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _scene.time).clamp(0.0, 0.1);
    _scene.time = now;
    _scene.shiftX += (_scene.shiftTarget - _scene.shiftX) * (1 - math.exp(-dt * 7));
    _frame.value = _scene.time;
    if (_scenario != 0) return;
    final near = _scene.nearMonth;
    if (near == _lastNear) return;
    _lastNear = near;
    // During the full revolution the Night Sky View follows the Earth.
    if (_scene.playing && near != null) _showPip(near);
    if (mounted) setState(() {});
  }

  // ============================================================ LOGIC

  /// HTML `buildScenario()` (via `clearScene()`).
  void _buildScenario() {
    _lab.cancelPending();
    _snap.stop();
    _play.stop();
    _pan.stop();
    _dolly.stop();
    _draw.value = 0;
    _scene.reset(_scenario);
    _pipShown = false;
    _pipMonth = null;
    _lastNear = _scene.nearMonth;
    _concluded = false;
    _played = false;
    _scene.shiftTarget = _shiftFor(_scenario);
    _scene.shiftX = _scene.shiftTarget;
    _lab.resetView(sound: false);
  }

  /// Scene offset while the sidebar is collapsed (see [_A2Scene.shiftX]).
  double _shiftFor(int scenario) => _lab.isSidebarOpen ? 0 : (scenario == 0 ? 90 : 160);

  /// HTML `changeScenario()` -> `resetApp(true)`: labels on, camera
  /// locked, pan mode off, scene rebuilt. The ground view's camera then
  /// pulls back to z = 50 (HTML `setCameraView('reset')`).
  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _lab.showLabels = true;
      _lab.camLocked = true;
      _lab.panMode = false;
      _buildScenario();
      if (index == 1) {
        _scene.camZ = 0;
        _dolly.forward(from: 0);
      }
    });
  }

  /// HTML `resetApp(false)` (after the shell's own reset).
  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _lab.camLocked = true;
      _calDrag = Offset.zero;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    final steps = _data.steps;
    setState(() {
      if (_step < steps.length) {
        _scene.step++;
        _scene.pulseSince = _scene.time;
      } else if (_step == steps.length) {
        _showConclusion();
      }
    });
  }

  void _showConclusion() {
    if (_concluded) return;
    _concluded = true;
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      heading: () => _t('lbl_observation'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  // ------------------------------------------------------- scenario 1

  /// HTML `showNightSkyPopup(month)`: new constellation, lines redrawn.
  void _showPip(int month) {
    setState(() {
      _pipMonth = month;
      _pipShown = true;
      _scene.observed.add(month);
    });
    _draw.forward(from: 0);
  }

  /// HTML `hideNightSkyPopup()` (fade + scale out over 300 ms).
  void _hidePip() {
    if (!_pipShown) return;
    setState(() => _pipShown = false);
  }

  /// HTML pointerdown: the Earth's hitbox (r 4) or within 60 px of it.
  bool _canGrab(Offset p) {
    if (!_lab.isLabActive || _lab.popup != null) return false;
    if (_scenario != 0 || _step > 3 || _scene.playing) return false;
    final pc = _scene.orbitCam.project(_scene.earthPos);
    if (pc == null) return false;
    final touch = math.min(60 / _scene.fit, 130.0);
    return (p - pc.p).distance < math.max(4 * pc.k, touch);
  }

  void _onGrab(Offset p) {
    _snap.stop();
    _scene.dragging = true;
    _Audio.play(_Sound.pickup);
  }

  /// HTML pointermove: the Earth follows the pointer along the ellipse.
  void _onDrag(Offset p) {
    if (!_scene.dragging) return;
    final hit = _scene.orbitCam.rayPlaneY(p);
    if (hit == null) return;
    var a = math.atan2(hit.z / _kOrbitRz, hit.x / _kOrbitRx);
    if (a < 0) a += math.pi * 2;
    _scene.earthAngle = a;
  }

  void _onRelease() {
    if (!_scene.dragging) return;
    _scene.dragging = false;
    _checkEarthPosition();
  }

  /// HTML `checkEarthPosition()`: snap to a marker within 0.3 rad, show
  /// that month's sky and check it against the step's target month.
  void _checkEarthPosition() {
    final a = _normAngle(_scene.earthAngle);
    int? snapped;
    for (var m = 0; m < 4; m++) {
      final d = _angleDiff(a, _monthAngle(m));
      if (d.abs() < _kSnapTol) {
        snapped = m;
        _scene.earthAngle = a;
        _snapFrom = a;
        _snapTo = a + d;
        _snap.forward(from: 0);
        break;
      }
    }
    if (snapped == null) {
      _hidePip();
      return;
    }
    _showPip(snapped);
    if (snapped == _scene.targetMonth) {
      _lab.showToast(_t('msg_great'));
      if (_step == 3) {
        if (snapped == _kSept) _scene.sepFound = true;
        if (snapped == _kDec) _scene.decFound = true;
        if (_scene.sepFound && _scene.decFound) {
          _advanceStep();
        } else {
          setState(() => _scene.pulseSince = _scene.time);
        }
      } else {
        _advanceStep();
      }
    } else {
      _lab.showToast(_t('msg_wrong_month'), isError: true);
    }
  }

  /// HTML `playOrbitAnimation()`: one full revolution in 6 s, then the
  /// conclusion. The Night Sky View starts hidden and then follows the
  /// Earth past each month marker.
  void _playOrbit() {
    if (_scenario != 0 || _step != 4 || _scene.playing || _played) return;
    _hidePip();
    setState(() {
      _played = true;
      _scene.playing = true;
      _lastNear = _scene.nearMonth;
    });
    _playFrom = _scene.earthAngle;
    _play.forward(from: 0).whenComplete(() {
      if (!mounted || _scenario != 0 || _play.value < 1) return;
      setState(() => _scene.playing = false);
      _advanceStep();
    });
  }

  // ------------------------------------------------------- scenario 2

  /// HTML `updateObjectAvailability()` for the calendar buttons.
  bool _monthEnabled(int m) {
    if (_step == 1) return m == _kMarch;
    if (_step == 2) return m == _kJune;
    if (_step == 3) return m == _kSept || m == _kDec;
    return false;
  }

  /// HTML `selectMonth(month)`: validate, advance, then highlight the
  /// month and pan the camera to its constellation.
  void _selectMonth(int m) {
    if (!_lab.isLabActive || !_monthEnabled(m)) return;
    _Audio.play(_Sound.click);
    if (!_concluded) {
      if (m != _scene.targetMonth && !_scene.found(m)) {
        _lab.showToast(_t('msg_select_month'), isError: true);
        return;
      }
      if (_step == 3) {
        if (m == _kSept) _scene.sepFound = true;
        if (m == _kDec) _scene.decFound = true;
        if (_scene.sepFound && _scene.decFound) {
          _advanceStep();
        } else {
          setState(() => _scene.pulseSince = _scene.time);
        }
      } else {
        _advanceStep();
      }
    }
    if (_scene.activeMonth != m) _Audio.play(_Sound.whoosh);
    setState(() {
      _scene.activeMonth = m;
      _scene.observed.add(m);
    });
    _panFrom = _scene.camX;
    _panTo = _kConstSpacing * m;
    _pan.forward(from: 0);
  }

  // ------------------------------------------------------- actions

  List<LabAction> _actions() {
    if (_scenario == 0 && _step == 4 && !_played) {
      return [
        LabAction(
          label: _t('btn_play'),
          icon: Icons.play_arrow_rounded,
          color: _kIndigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _playOrbit,
        ),
      ];
    }
    return const [];
  }

  // ============================================================== UI

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
        // Room kept free for the "Current Objective" HUD at the bottom.
        final hudSpace = (_lab.isSidebarOpen ? 8 + 62 * s : 12) + pad.bottom;
        final actions = _actions();
        _scene.shiftTarget = _shiftFor(_scenario);
        return LabShell(
          controller: _lab,
          icon: Icons.nights_stay,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: actions,
          sidebarExtraTitle: _t('sky_log'),
          sidebarExtra: _skyLog(p, s),
          onReset: _fullReset,
          overlays: [
            if (_scenario == 0 && _pipMonth != null) _pipOverlay(s, inset),
            if (_scenario == 0 && actions.isNotEmpty) _playButton(s, inset, hudSpace),
            if (_scenario == 1) _clockOverlay(s, hudSpace, pad),
            if (_scenario == 1) _calendarOverlay(context, p, s, inset, hudSpace),
          ],
          stage: LayoutBuilder(builder: (context, box) => _stage(box)),
        );
      },
    );
  }

  Widget _stage(BoxConstraints box) {
    final fit = math.min(box.maxWidth / _kA2Design.width, box.maxHeight / _kA2Design.height);
    if (fit > 0 && fit.isFinite) _scene.fit = fit;
    return LabStage(
      designSize: _kA2Design,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _A2GrabRecognizer: GestureRecognizerFactoryWithHandlers<_A2GrabRecognizer>(
            _A2GrabRecognizer.new,
            (r) => r
              ..accepts = _canGrab
              ..dragStartBehavior = DragStartBehavior.down
              ..gestureSettings = const DeviceGestureSettings(touchSlop: 6)
              ..onStart = ((d) => _onGrab(d.localPosition))
              ..onUpdate = ((d) => _onDrag(d.localPosition))
              ..onEnd = ((_) => _onRelease())
              ..onCancel = _onRelease,
          ),
        },
        child: CustomPaint(
          size: _kA2Design,
          painter: _A2Painter(
            scene: _scene,
            repaint: _frame,
            showLabels: _lab.showLabels,
            lang: _lab.lang,
            text: _t,
          ),
        ),
      ),
    );
  }

  /// Sidebar readouts: where the Earth is (or the time and calendar month)
  /// and a log of the constellation seen at night in each month.
  Widget _skyLog(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    final near = sc.nearMonth;
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
          if (_scenario == 0)
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('lbl_earth_pos'),
              value: near == null ? _t('between_months') : _t('month_$near'),
              valueColor: _Colors.blue,
            )
          else ...[
            LabInfoRow(palette: p, scale: f, label: _t('lbl_time'), value: _t('time_9pm'), valueColor: _kIndigo400),
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('lbl_month'),
              value: _t('month_${sc.activeMonth}'),
              valueColor: _Colors.zslYellow,
            ),
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('lbl_in_view'),
              value: _t('const_${sc.activeMonth}'),
              valueColor: _kAmber400,
            ),
          ],
          Divider(color: p.cardBorder, height: 14 * s),
          Text(
            _t('log_head'),
            style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2 * s),
          for (var m = 0; m < 4; m++)
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('month_$m'),
              value: sc.observed.contains(m) ? _t('const_$m') : _t('not_seen'),
              valueColor: sc.observed.contains(m) ? (p.isDark ? _kAmber400 : const Color(0xFFB45309)) : p.textMuted,
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- overlays

  /// HTML `#s1-night-sky-popup`: top right (below the toast line), indigo
  /// frame, constellation drawing and the amber name chip.
  Widget _pipOverlay(double s, EdgeInsets inset) {
    final m = _pipMonth!;
    final w = (150 * s).clamp(112.0, 230.0);
    final h = w * 0.78;
    const dur = Duration(milliseconds: 300);
    return Positioned(
      top: inset.top + 36 * s,
      right: inset.right + 4,
      child: IgnorePointer(
        ignoring: !_pipShown,
        child: AnimatedOpacity(
          opacity: _pipShown ? 1 : 0,
          duration: dur,
          child: AnimatedScale(
            scale: _pipShown ? 1 : 0.95,
            duration: dur,
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1), width: 2),
                boxShadow: const [BoxShadow(color: Color(0x666366F1), blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(8 * s, 2 * s, 3 * s, 2 * s),
                      decoration: const BoxDecoration(
                        color: Color(0x80312E81),
                        border: Border(bottom: BorderSide(color: Color(0x806366F1))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _t('night_sky_view'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFFC7D2FE),
                                fontSize: 10 * s,
                                fontWeight: FontWeight.w800,
                                letterSpacing: _track(0.6),
                              ),
                            ),
                          ),
                          Tooltip(
                            message: _t('close'),
                            child: InkWell(
                              onTap: () {
                                _Audio.play(_Sound.click);
                                _hidePip();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(3 * s),
                                child: Icon(Icons.close, size: 14 * s, color: _Colors.slate400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: Colors.black),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4 * s, 2 * s, 4 * s, 20 * s),
                            child: AnimatedBuilder(
                              animation: _draw,
                              builder: (context, _) => CustomPaint(
                                painter: _A2PipPainter(month: m, progress: Curves.ease.transform(_draw.value)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 4 * s,
                            right: 4 * s,
                            bottom: 4 * s,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 2 * s),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
                                  ),
                                  child: Text(
                                    _t('const_$m').toUpperCase(),
                                    style: TextStyle(
                                      color: _kAmber400,
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: _track(1.6 * s),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  /// HTML `#btn-play-orbit`: round indigo play button with a white ring,
  /// bottom right above the HUD.
  Widget _playButton(double s, EdgeInsets inset, double hudSpace) {
    final d = 56 * s;
    return Positioned(
      right: inset.right + 10 * s,
      bottom: hudSpace + 8 * s,
      child: ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, t, child) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.45 + 0.25 * math.sin(t * math.pi)),
                blurRadius: 20 + 6 * math.sin(t * math.pi),
              ),
            ],
          ),
          child: child,
        ),
        child: Tooltip(
          message: _t('btn_play'),
          child: Material(
            color: _kIndigo600,
            shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                _Audio.play(_Sound.click);
                _playOrbit();
              },
              child: SizedBox(
                width: d,
                height: d,
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32 * s),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// HTML ground-view clock (9:00 PM), bottom left above the HUD.
  Widget _clockOverlay(double s, double hudSpace, EdgeInsets pad) {
    final d = 50 * s;
    return Positioned(
      left: 12 * s + pad.left,
      bottom: hudSpace + 4 * s,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: d,
              height: d,
              padding: EdgeInsets.all(d * 0.17),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xCC1E293B),
                border: Border.all(color: _kIndigo400, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x806366F1), blurRadius: 15)],
              ),
              child: const CustomPaint(painter: _A2ClockPainter()),
            ),
            SizedBox(height: 5 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _Colors.slate700),
              ),
              child: Text(
                _t('time_9pm'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: _track(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `#calendar-widget` (bottom right, above the HUD). The whole
  /// widget can be dragged around the canvas.
  Widget _calendarOverlay(BuildContext context, LabPalette p, double s, EdgeInsets inset, double hudSpace) {
    final size = MediaQuery.sizeOf(context);
    final canvasW = size.width * (_lab.isSidebarOpen ? 0.7 : 1);
    final w = (164 * s).clamp(128.0, 240.0);
    final h = w * 1.22;
    final maxH = math.max(90.0, size.height - hudSpace - inset.top - 40 * s);
    double clampD(double v, double lo, double hi) => lo > hi ? hi : v.clamp(lo, hi);
    final dx = clampD(_calDrag.dx, -(canvasW - w - inset.right - 18), 0);
    final dy = clampD(_calDrag.dy, -(size.height - hudSpace - h - 16), hudSpace - 12);
    return Positioned(
      right: inset.right + 6 * s,
      bottom: hudSpace + 4 * s,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() => _calDrag = Offset(dx, dy) + d.delta),
              child: _calendar(p, s, w),
            ),
          ),
        ),
      ),
    );
  }

  Widget _calendar(LabPalette p, double s, double w) {
    final dark = p.isDark;
    final m = _scene.activeMonth;
    final days = _kMonthDays[m];
    final muted = dark ? _Colors.slate400 : _Colors.slate500;
    final dayColor = dark ? _Colors.slate200 : _Colors.slate800;
    final white50 = Colors.white.withValues(alpha: 0.5);
    Widget pair(int a, int b) => Row(
          children: [
            Expanded(child: _monthBtn(p, s, a)),
            SizedBox(width: 4 * s),
            Expanded(child: _monthBtn(p, s, b)),
          ],
        );
    return Container(
      width: w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? _Colors.slate800 : _Colors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? _Colors.slate600 : _Colors.slate300),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _kIndigo600,
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
            child: Row(
              children: [
                Icon(Icons.chevron_left, size: 15 * s, color: white50),
                Expanded(
                  child: Tooltip(
                    message: _t('drag_calendar'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.drag_indicator, size: 12 * s, color: const Color(0xFFA5B4FC)),
                        SizedBox(width: 2 * s),
                        Flexible(
                          child: Text(
                            _t('month_$m').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: _track(1.6 * s),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 15 * s, color: white50),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(6 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Text(
                          _t('wd_$i'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(color: muted, fontSize: 7.5 * s, fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3 * s),
                for (var r = 0; r < 5; r++)
                  Row(
                    children: [
                      for (var c = 0; c < 7; c++)
                        Expanded(
                          child: SizedBox(
                            height: 12 * s,
                            child: Center(
                              child: r * 7 + c < days
                                  ? Text(
                                      '${r * 7 + c + 1}',
                                      style: TextStyle(color: dayColor, fontSize: 8 * s, fontWeight: FontWeight.w600),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4 * s),
                  child: Divider(height: 1, color: dark ? _Colors.slate700 : _Colors.slate300),
                ),
                pair(_kMarch, _kJune),
                SizedBox(height: 4 * s),
                pair(_kSept, _kDec),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// MAR / JUN / SEP / DEC buttons: the active month is filled indigo,
  /// buttons not allowed in this step are dimmed and the step's target
  /// has a pulsing amber ring (HTML `ring-2 ring-amber-500 animate-pulse`).
  Widget _monthBtn(LabPalette p, double s, int m) {
    final dark = p.isDark;
    final enabled = _monthEnabled(m);
    final active = _scene.activeMonth == m;
    final highlight = enabled && !_concluded && _scene.targetMonth == m;
    final fg = active ? Colors.white : (dark ? _Colors.slate300 : _Colors.slate600);
    final btn = Material(
      key: ValueKey('a2-month-$m'),
      color: active ? _kIndigo600 : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: enabled ? () => _selectMonth(m) : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.5 * s),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? _kIndigo600 : (dark ? _Colors.slate600 : _Colors.slate300)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _t('mon_$m'),
              style: TextStyle(
                color: fg,
                fontSize: 10 * s,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: _track(0.5),
              ),
            ),
          ),
        ),
      ),
    );
    Widget ring(Color c, Widget child) => Container(
          padding: EdgeInsets.all(1.5 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c, width: 2 * s),
          ),
          child: child,
        );
    if (!highlight) {
      return ring(Colors.transparent, Opacity(opacity: enabled ? 1 : 0.5, child: btn));
    }
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, child) => Opacity(
        // Tailwind animate-pulse: opacity 1 -> 0.5 -> 1 every 2 s.
        opacity: 0.75 + 0.25 * math.cos(t * math.pi),
        child: child,
      ),
      child: ring(_Colors.amber, btn),
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': "Earth's Revolution & Changing Night Sky",
    'app_subtitle': 'Class 7 • Earth, Moon and the Sun',
    'scen_1_opt': 'Scenario 1: The Orbit View',
    'scen_2_opt': 'Scenario 2: The Ground View',
    'sci_conclusion': 'Success!',
    'lbl_observation': 'Conclusion',
    'night_sky_view': 'Night Sky View',
    'time_9pm': '9:00 PM',
    'lbl_sun': 'Sun',
    'lbl_earth': 'Earth',
    'month_0': 'March',
    'month_1': 'June',
    'month_2': 'September',
    'month_3': 'December',
    'const_0': 'LEO',
    'const_1': 'SCORPIUS',
    'const_2': 'PEGASUS',
    'const_3': 'ORION',
    'msg_wrong_month': 'Drag Earth to the highlighted month marker!',
    'msg_select_month': 'Click the highlighted month on the calendar.',
    'conclusion_1':
        'As the Earth revolves around the Sun, its night side faces different directions in space. This is why we see different constellations like Leo, Scorpius, Pegasus, and Orion at different times of the year.',
    'conclusion_2':
        'From the ground, if we look at the sky at the same time (e.g., 9 PM) across different months, the stars appear to drift. This annual change serves as a natural calendar used by ancestors for farming and navigation.',
    // Strings that were hard-coded in the HTML (or are new readouts).
    'msg_great': 'Great!',
    'btn_play': 'Play Full Revolution',
    'mon_0': 'MAR',
    'mon_1': 'JUN',
    'mon_2': 'SEP',
    'mon_3': 'DEC',
    'wd_0': 'S',
    'wd_1': 'M',
    'wd_2': 'T',
    'wd_3': 'W',
    'wd_4': 'T',
    'wd_5': 'F',
    'wd_6': 'S',
    'close': 'Close',
    'drag_calendar': 'Drag Calendar',
    'sky_log': 'Night Sky Log',
    'lbl_earth_pos': "Earth's position",
    'between_months': 'Between months',
    'lbl_time': 'Time',
    'lbl_month': 'Calendar month',
    'lbl_in_view': 'Constellation in view',
    'log_head': 'Constellation seen at night, month by month',
    'not_seen': '—',
  },
  'hi': {
    'app_title': 'पृथ्वी की परिक्रमा और बदलता रात का आकाश',
    'app_subtitle': 'कक्षा 7 • पृथ्वी, चंद्रमा और सूर्य',
    'scen_1_opt': 'परिदृश्य 1: कक्षा का दृश्य (Orbit View)',
    'scen_2_opt': 'परिदृश्य 2: जमीन का दृश्य (Ground View)',
    'sci_conclusion': 'सफलता!',
    'lbl_observation': 'निष्कर्ष',
    'night_sky_view': 'रात का आकाश दृश्य',
    'time_9pm': 'रात 9:00 बजे',
    'lbl_sun': 'सूर्य',
    'lbl_earth': 'पृथ्वी',
    'month_0': 'मार्च',
    'month_1': 'जून',
    'month_2': 'सितंबर',
    'month_3': 'दिसंबर',
    'const_0': 'सिंह (LEO)',
    'const_1': 'वृश्चिक (SCORPIUS)',
    'const_2': 'पेगासस (PEGASUS)',
    'const_3': 'मृगशिरा (ORION)',
    'msg_wrong_month': 'पृथ्वी को हाइलाइट किए गए महीने के मार्कर पर खींचें!',
    'msg_select_month': 'कैलेंडर पर हाइलाइट किए गए महीने पर क्लिक करें।',
    'conclusion_1':
        'जैसे-जैसे पृथ्वी सूर्य की परिक्रमा करती है, उसका रात का हिस्सा अंतरिक्ष में अलग-अलग दिशाओं का सामना करता है। यही कारण है कि हम वर्ष के अलग-अलग समय में अलग-अलग तारामंडल देखते हैं।',
    'conclusion_2':
        'जमीन से, यदि हम अलग-अलग महीनों में एक ही समय (जैसे, रात 9 बजे) आकाश को देखते हैं, तो तारे खिसकते हुए प्रतीत होते हैं। यह वार्षिक परिवर्तन कृषि और नेविगेशन के लिए एक प्राकृतिक कैलेंडर के रूप में कार्य करता है।',
    'msg_great': 'बहुत बढ़िया!',
    'btn_play': 'पूर्ण परिक्रमा चलाएँ (Play)',
    'mon_0': 'मार्च',
    'mon_1': 'जून',
    'mon_2': 'सितं',
    'mon_3': 'दिसं',
    'wd_0': 'र',
    'wd_1': 'सो',
    'wd_2': 'मं',
    'wd_3': 'बु',
    'wd_4': 'गु',
    'wd_5': 'शु',
    'wd_6': 'श',
    'close': 'बंद करें',
    'drag_calendar': 'कैलेंडर खींचें',
    'sky_log': 'रात्रि आकाश लॉग',
    'lbl_earth_pos': 'पृथ्वी की स्थिति',
    'between_months': 'महीनों के बीच',
    'lbl_time': 'समय',
    'lbl_month': 'कैलेंडर का महीना',
    'lbl_in_view': 'दिख रहा तारामंडल',
    'log_head': 'हर महीने रात में दिखा तारामंडल',
    'not_seen': '—',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "To understand how the Earth's position in its orbit around the Sun determines which constellations are visible at night.",
      steps: [
        LabStep(
          concept: 'March Position',
          action: "DRAG the Earth model to the 'March' marker on its orbit.",
          observation: "Earth snaps to March. The popup shows 'Leo' is visible in the night sky.",
        ),
        LabStep(
          concept: 'June Position',
          action: "DRAG the Earth model to the 'June' marker.",
          observation:
              "Night Sky View updates to show 'Scorpius'. The direction of deep space at night has changed.",
        ),
        LabStep(
          concept: 'September & December',
          action: "DRAG the Earth to the 'September' and then 'December' markers.",
          observation: 'The constellations change predictably (Pegasus, Orion) as Earth moves.',
        ),
        LabStep(
          concept: 'Full Cycle',
          action: "CLICK the 'Play' button to watch a full revolution.",
          observation: 'The dynamic movie shows the continuous cycle of changing skies over a year.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To observe the changing night sky from a fixed location on Earth at the same time of night across different months.',
      steps: [
        LabStep(
          concept: 'March Sky',
          action: "CLICK on the month of 'March' on the calendar widget.",
          observation: "At 9 PM in March, the constellation 'Leo' is seen rising.",
        ),
        LabStep(
          concept: 'June Sky',
          action: "CLICK on the month of 'June'. Keep your eyes on the sky.",
          observation: "Stars drift. 'Scorpius' rises, and 'Leo' is no longer in that position.",
        ),
        LabStep(
          concept: 'Annual Cycle',
          action: "CLICK through 'September' and 'December'.",
          observation: 'New prominent constellations appear, proving the sky acts as a natural calendar.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह समझना कि सूर्य के चारों ओर अपनी कक्षा में पृथ्वी की स्थिति कैसे निर्धारित करती है कि रात में कौन से तारामंडल दिखाई देते हैं।',
      steps: [
        LabStep(
          concept: 'मार्च की स्थिति',
          action: "पृथ्वी मॉडल को उसकी कक्षा पर 'मार्च' मार्कर पर खींचें।",
          observation: "पॉपअप दिखाता है कि रात के आकाश में 'सिंह (Leo)' दिखाई दे रहा है।",
        ),
        LabStep(
          concept: 'जून की स्थिति',
          action: "पृथ्वी मॉडल को 'जून' मार्कर पर खींचें।",
          observation: "रात का आकाश दृश्य 'वृश्चिक (Scorpius)' दिखाने के लिए अपडेट होता है।",
        ),
        LabStep(
          concept: 'सितंबर और दिसंबर',
          action: "पृथ्वी को 'सितंबर' और फिर 'दिसंबर' मार्कर पर खींचें।",
          observation: 'जैसे-जैसे पृथ्वी चलती है तारामंडल (पेगासस, ओरायन) बदलते हैं।',
        ),
        LabStep(
          concept: 'पूर्ण चक्र',
          action: "पूर्ण परिक्रमा देखने के लिए 'Play' बटन पर क्लिक करें।",
          observation: 'निरंतर चक्र दिखाता है कि साल भर आकाश कैसे बदलता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'विभिन्न महीनों में एक ही समय पर पृथ्वी पर एक निश्चित स्थान से बदलते रात के आकाश का निरीक्षण करना।',
      steps: [
        LabStep(
          concept: 'मार्च का आकाश',
          action: "कैलेंडर विजेट पर 'मार्च' महीने पर क्लिक करें।",
          observation: "मार्च में रात 9 बजे 'सिंह (Leo)' तारामंडल दिखाई देता है।",
        ),
        LabStep(
          concept: 'जून का आकाश',
          action: "महीने 'जून' पर क्लिक करें। अपनी आँखें आकाश पर रखें।",
          observation: "तारे खिसकते हैं। 'वृश्चिक' उगता है, और 'सिंह' अब उस स्थिति में नहीं है।",
        ),
        LabStep(
          concept: 'वार्षिक चक्र',
          action: "'सितंबर' और 'दिसंबर' पर क्लिक करें।",
          observation: 'नए प्रमुख तारामंडल दिखाई देते हैं।',
        ),
      ],
    ),
  ],
};

// ====================================================== CONSTELLATIONS

/// Months used by the lab, in orbit / calendar order:
/// 0 March, 1 June, 2 September, 3 December.
const int _kMarch = 0, _kJune = 1, _kSept = 2, _kDec = 3;

/// HTML `MONTH_ANGLES`: March 0, June PI/2, September PI, December 3PI/2.
double _monthAngle(int m) => m * math.pi / 2;

/// Days shown on the calendar widget for each month.
const List<int> _kMonthDays = [31, 30, 30, 31];

/// A star of an HTML `SVGMaps` constellation (viewBox 0..100).
@immutable
class _A2Star {
  const _A2Star(this.x, this.y, {this.r = 2, this.color = Colors.white});
  final double x, y, r;
  final Color color;
}

/// One HTML constellation SVG: the line path (sub-paths, each optionally
/// closed with `Z`) and its star circles.
@immutable
class _A2Constellation {
  const _A2Constellation(this.lines, this.stars);
  final List<({List<Offset> pts, bool closed})> lines;
  final List<_A2Star> stars;
}

const Color _kStarRed = Color(0xFFEF4444);
const Color _kStarBlue = Color(0xFF60A5FA);

/// HTML `SVGMaps` for March (Leo), June (Scorpius), September (Pegasus) and
/// December (Orion).
const List<_A2Constellation> _kConstellations = [
  // Leo: M15,60 L35,45 L55,45 L65,25 L85,35 L90,65 L70,75 L35,65 Z
  _A2Constellation(
    [
      (
        pts: [
          Offset(15, 60), Offset(35, 45), Offset(55, 45), Offset(65, 25), //
          Offset(85, 35), Offset(90, 65), Offset(70, 75), Offset(35, 65),
        ],
        closed: true,
      ),
    ],
    [
      _A2Star(15, 60), _A2Star(35, 45), _A2Star(55, 45), _A2Star(65, 25), //
      _A2Star(85, 35), _A2Star(90, 65), _A2Star(70, 75), _A2Star(35, 65),
    ],
  ),
  // Scorpius: M20,20 L35,35 L45,55 L55,75 L75,85 L85,65 L75,45 (Antares red).
  _A2Constellation(
    [
      (
        pts: [
          Offset(20, 20), Offset(35, 35), Offset(45, 55), Offset(55, 75), //
          Offset(75, 85), Offset(85, 65), Offset(75, 45),
        ],
        closed: false,
      ),
    ],
    [
      _A2Star(20, 20), _A2Star(35, 35), _A2Star(45, 55, r: 3, color: _kStarRed), //
      _A2Star(55, 75), _A2Star(75, 85), _A2Star(85, 65), _A2Star(75, 45),
    ],
  ),
  // Pegasus: M30,30 L70,30 L60,70 L20,70 Z M70,30 L90,10
  _A2Constellation(
    [
      (pts: [Offset(30, 30), Offset(70, 30), Offset(60, 70), Offset(20, 70)], closed: true),
      (pts: [Offset(70, 30), Offset(90, 10)], closed: false),
    ],
    [_A2Star(30, 30), _A2Star(70, 30), _A2Star(60, 70), _A2Star(20, 70), _A2Star(90, 10)],
  ),
  // Orion: M30,20 L70,20 L60,50 L40,50 Z M60,50 L75,85 L25,85 L40,50
  //        M30,50 L70,50 (Betelgeuse red, Rigel blue).
  _A2Constellation(
    [
      (pts: [Offset(30, 20), Offset(70, 20), Offset(60, 50), Offset(40, 50)], closed: true),
      (pts: [Offset(60, 50), Offset(75, 85), Offset(25, 85), Offset(40, 50)], closed: false),
      (pts: [Offset(30, 50), Offset(70, 50)], closed: false),
    ],
    [
      _A2Star(30, 20, color: _kStarRed), _A2Star(70, 20), _A2Star(60, 50), //
      _A2Star(50, 50), _A2Star(40, 50), _A2Star(75, 85, color: _kStarBlue), _A2Star(25, 85),
    ],
  ),
];

/// The constellation's line figure as one path in viewBox (0..100) units.
Path _constellationPath(_A2Constellation c) {
  final path = Path();
  for (final l in c.lines) {
    for (var i = 0; i < l.pts.length; i++) {
      final p = l.pts[i];
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    if (l.closed) path.close();
  }
  return path;
}

// ============================================================ 3D MATH

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  static const _V3 zero = _V3(0, 0, 0);

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

  /// Three.js rotation about Y (`object.rotation.y = a`).
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }
}

typedef _Proj = ({Offset p, double z, double k});

/// Look-at perspective camera (Three.js PerspectiveCamera, fov 45°)
/// projecting world points into design coordinates.
class _A2Cam {
  _A2Cam(this.pos, _V3 target, {required this.center}) {
    fwd = (target - pos).unit;
    var r = fwd.cross(const _V3(0, 1, 0));
    if (r.length < 1e-6) r = const _V3(1, 0, 0);
    right = r.unit;
    up = right.cross(fwd);
  }

  final _V3 pos;
  final double f = _kA2Focal;
  final Offset center;
  late final _V3 fwd;
  late final _V3 right;
  late final _V3 up;
  static const double near = 0.5;

  double depth(_V3 w) => (w - pos).dot(fwd);

  _Proj? project(_V3 w) {
    final d = w - pos;
    final z = d.dot(fwd);
    if (z < near) return null;
    final k = f / z;
    return (p: Offset(center.dx + d.dot(right) * k, center.dy - d.dot(up) * k), z: z, k: k);
  }

  _V3 ray(Offset s) => (fwd + right * ((s.dx - center.dx) / f) + up * ((center.dy - s.dy) / f)).unit;

  /// HTML `raycaster.ray.intersectPlane(dragPlane)` with the plane y = [h].
  _V3? rayPlaneY(Offset s, [double h = 0]) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (h - pos.y) / d.y;
    if (t <= 0) return null;
    return pos + d * t;
  }
}

// ============================================================ SCENE MODEL

const Size _kA2Design = Size(1000, 560);

/// Focal length for a 45° vertical field of view at the design half height.
const double _kA2Focal = 676;

/// HTML `State.orbitRadiusX` / `orbitRadiusZ`.
const double _kOrbitRx = 45, _kOrbitRz = 30;

/// Orbit-view camera: the HTML camera direction (0, 105, 105) looking at
/// the Sun, moved a little closer so the orbit fills the phone stage. The
/// scene is centred left of the middle, leaving the top-right corner for
/// the Night Sky View and the bottom-right for the Play button.
const _V3 _kS1Eye = _V3(0, 85, 85);
const Offset _kS1Center = Offset(430, 292);

/// Ground-view camera centre (constellations at design x 440, clear of the
/// calendar at the bottom right).
const Offset _kS2Center = Offset(440, 280);

/// Earth / Moon radii (HTML 2.5 / 0.7, drawn 1.3x for small screens) and the
/// Moon's distance from the Earth (HTML 6.5).
const double _kEarthR = 3.25, _kMoonR = 0.92, _kMoonDist = 6.5;

/// HTML `checkEarthPosition` snap tolerance (radians).
const double _kSnapTol = 0.3;

/// HTML constellation spacing in the ground view.
const double _kConstSpacing = 100;

class _A2Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // ---------------------------------------------------- scenario 1
  /// Angle of the Earth on its orbit (HTML `-earthPivot.rotation.y`).
  double earthAngle = math.pi / 6;
  bool dragging = false;
  bool playing = false;

  /// HTML `State.monthsFound` (September / December, step 3).
  bool sepFound = false, decFound = false;

  /// Moment the current target marker started pulsing.
  double pulseSince = 0;

  // ---------------------------------------------------- scenario 2
  double camX = 0;
  double camZ = 50;
  int activeMonth = _kMarch;

  /// Months whose night sky has been observed (sidebar log).
  final Set<int> observed = {};

  /// Stage scale (design -> screen), updated on layout.
  double fit = 1;

  /// Horizontal scene offset (design px). While the sidebar is collapsed
  /// the scene slides right, clear of the floating mission card.
  double shiftX = 0;
  double shiftTarget = 0;

  /// Labels grow when the stage is drawn small (HTML labels are fixed-size
  /// DOM elements), so they stay about 11 px on screen.
  double get labelScale => fit > 0 && fit.isFinite ? (0.9 / fit).clamp(1.0, 1.7) : 1.0;

  bool found(int m) => m == _kSept ? sepFound : (m == _kDec ? decFound : false);

  /// HTML `targetMonth` for the current step.
  int? get targetMonth {
    if (step == 1) return _kMarch;
    if (step == 2) return _kJune;
    if (step == 3) return sepFound ? _kDec : _kSept;
    return null;
  }

  _V3 get earthPos => _V3(_kOrbitRx * math.cos(earthAngle), 0, _kOrbitRz * math.sin(earthAngle));

  /// The Earth group looks at the Sun (HTML `earth.lookAt(0, 0, 0)`).
  double get earthYaw {
    final e = earthPos;
    return math.atan2(-e.x, -e.z);
  }

  /// HTML `moonPivot.rotation.y += 0.02` per frame (about 1.2 rad/s).
  _V3 get moonPos => earthPos + const _V3(_kMoonDist, 0, 0).rotY(earthYaw + time * 1.2);

  /// HTML `earth.children[0].rotation.y += 0.05` per frame (about 3 rad/s).
  double get earthSpin => earthYaw + time * 3;

  _A2Cam get orbitCam => _A2Cam(_kS1Eye, _V3.zero, center: _kS1Center.translate(shiftX, 0));

  _A2Cam get groundCam =>
      _A2Cam(_V3(camX, 0, camZ), _V3(camX, 0, -50), center: _kS2Center.translate(shiftX, 0));

  /// Marker the Earth is on (within the HTML snap tolerance), if any.
  int? get nearMonth {
    final a = _normAngle(earthAngle);
    for (var m = 0; m < 4; m++) {
      if (_angleDiff(a, _monthAngle(m)).abs() < _kSnapTol) return m;
    }
    return null;
  }

  void reset(int sc) {
    scenario = sc;
    step = 1;
    earthAngle = math.pi / 6;
    dragging = false;
    playing = false;
    sepFound = false;
    decFound = false;
    pulseSince = time;
    camX = 0;
    camZ = 50;
    activeMonth = _kMarch;
    observed.clear();
  }
}

double _normAngle(double a) {
  var r = a % (math.pi * 2);
  if (r < 0) r += math.pi * 2;
  return r;
}

/// Signed shortest difference `b - a` in (-pi, pi].
double _angleDiff(double a, double b) {
  var d = (b - a) % (math.pi * 2);
  if (d > math.pi) d -= math.pi * 2;
  if (d <= -math.pi) d += math.pi * 2;
  return d;
}

// ============================================================ STATIC DATA

/// HTML `addBackgroundStars()`: 800 stars on a shell of radius 150..200.
final List<_V3> _kOrbitStars = () {
  final r = math.Random(7);
  return [
    for (var i = 0; i < 800; i++)
      () {
        final rad = 150 + r.nextDouble() * 50;
        final theta = 2 * math.pi * r.nextDouble();
        final phi = math.acos(2 * r.nextDouble() - 1);
        return _V3(
          rad * math.sin(phi) * math.cos(theta),
          rad * math.sin(phi) * math.sin(theta),
          rad * math.cos(phi),
        );
      }(),
  ];
}();

/// Ground-view sky stars on the plane z = -50 (HTML 1500 stars over
/// 400 x 200 units). Extended to cover every month the camera pans to.
final List<({double x, double y, double size, int phase})> _kSkyStars = () {
  final r = math.Random(11);
  return [
    for (var i = 0; i < 2300; i++)
      (
        x: -170 + r.nextDouble() * 640,
        y: (r.nextDouble() - 0.5) * 170,
        size: 0.8 + r.nextDouble() * r.nextDouble() * 1.4,
        phase: r.nextInt(3),
      ),
  ];
}();

/// Land cells of the stylised Earth in its body frame. HTML: an icosahedron
/// pushed out where `sin(2x) cos(3y) sin(2z) > 0` (at radius 2.51).
final List<({List<_V3> corners, _V3 n})> _kLandCells = () {
  const nLat = 18, nLon = 36;
  _V3 sph(double lat, double lon) =>
      _V3(math.cos(lat) * math.cos(lon), math.sin(lat), math.cos(lat) * math.sin(lon));
  final out = <({List<_V3> corners, _V3 n})>[];
  for (var i = 0; i < nLat; i++) {
    final la0 = -math.pi / 2 + math.pi * i / nLat, la1 = -math.pi / 2 + math.pi * (i + 1) / nLat;
    for (var j = 0; j < nLon; j++) {
      final lo0 = 2 * math.pi * j / nLon, lo1 = 2 * math.pi * (j + 1) / nLon;
      final n = sph((la0 + la1) / 2, (lo0 + lo1) / 2);
      final v = n * 2.51;
      final noise = math.sin(v.x * 2) * math.cos(v.y * 3) * math.sin(v.z * 2);
      if (noise <= 0.04) continue;
      out.add((corners: [sph(la0, lo0), sph(la0, lo1), sph(la1, lo1), sph(la1, lo0)], n: n));
    }
  }
  return out;
}();

Path _a2Poly(List<Offset> pts, {bool close = true}) {
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

/// Night side of a sphere of screen radius [r] at [c], lit from the
/// on-screen direction [dir]; [cosPhi] is cos(angle between light and view).
Path _a2NightPath(Offset c, double r, Offset dir, double cosPhi) {
  final len = dir.distance;
  if (len < 1e-4) {
    return cosPhi < 0 ? (Path()..addOval(Rect.fromCircle(center: c, radius: r))) : Path();
  }
  final ux = dir.dx / len, uy = dir.dy / len;
  Offset tr(double x, double y) => Offset(c.dx + x * ux - y * uy, c.dy + x * uy + y * ux);
  final pts = <Offset>[];
  const n = 28;
  for (var i = 0; i <= n; i++) {
    final a = math.pi / 2 + math.pi * i / n;
    pts.add(tr(math.cos(a) * r, math.sin(a) * r));
  }
  for (var i = 0; i <= n; i++) {
    final t = -math.pi / 2 + math.pi * i / n;
    pts.add(tr(-r * cosPhi * math.cos(t), r * math.sin(t)));
  }
  return _a2Poly(pts);
}

/// HTML ground silhouette SVG (viewBox 1000 x 200): hills with smooth
/// quadratic (`T`) segments, three trees and two houses.
final Path _kHillsPath = () {
  final p = Path()
    ..moveTo(0, 200)
    ..lineTo(1000, 200)
    ..lineTo(1000, 100)
    ..quadraticBezierTo(950, 110, 900, 90);
  var cur = const Offset(900, 90);
  var ctrl = const Offset(950, 110);
  for (final t in const [
    Offset(800, 80), Offset(700, 120), Offset(600, 90), Offset(500, 100), Offset(400, 70), //
    Offset(300, 110), Offset(200, 80), Offset(100, 100), Offset(0, 90),
  ]) {
    ctrl = cur * 2 - ctrl;
    p.quadraticBezierTo(ctrl.dx, ctrl.dy, t.dx, t.dy);
    cur = t;
  }
  return p
    ..close()
    // Trees.
    ..addPath(_a2Poly(const [Offset(50, 100), Offset(60, 70), Offset(70, 100)]), Offset.zero)
    ..addPath(_a2Poly(const [Offset(150, 90), Offset(165, 50), Offset(180, 90)]), Offset.zero)
    ..addPath(_a2Poly(const [Offset(850, 100), Offset(870, 40), Offset(890, 100)]), Offset.zero);
}();

final Path _kHousesPath = Path()
  ..addPath(
    _a2Poly(const [Offset(250, 110), Offset(250, 80), Offset(270, 60), Offset(290, 80), Offset(290, 110)]),
    Offset.zero,
  )
  ..addPath(
    _a2Poly(const [Offset(750, 120), Offset(750, 90), Offset(770, 70), Offset(790, 90), Offset(790, 120)]),
    Offset.zero,
  );

/// Top of the ground silhouette band in design coordinates (25% of the
/// height, like the HTML `h-[25vh]` SVG).
const double _kGroundTop = 420;
const double _kGroundScaleY = 140 / 200;

// ============================================================ PAINTER

/// The scene: the orbit view (scenario 1) or the ground view (scenario 2).
/// Everything is drawn back to front; labels last (HTML DOM labels sit on
/// top of the WebGL canvas).
class _A2Painter extends CustomPainter {
  _A2Painter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.text,
  }) : super(repaint: repaint);

  final _A2Scene scene;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) text;

  double get _ls => scene.labelScale;

  @override
  void paint(Canvas canvas, Size size) {
    // HTML scene.background 0x020617 (fills the letterbox too).
    canvas.drawRect(labBleed(size), Paint()..color = const Color(0xFF020617));
    if (scene.scenario == 0) {
      _paintOrbitView(canvas);
    } else {
      _paintGroundView(canvas, size);
    }
  }

  /// HTML-style floating label (bold, wide tracking, 2 px border).
  void _tag(
    Canvas canvas,
    String label,
    Offset at, {
    required double size,
    required Color color,
    required Color bg,
    required Color border,
    double radius = 999,
    Alignment anchor = Alignment.center,
    double opacity = 1,
  }) {
    final ls = _ls;
    labText(
      canvas,
      label,
      at,
      size: size * ls,
      color: color,
      weight: FontWeight.w800,
      anchor: anchor,
      background: bg,
      border: border,
      borderWidth: 1.6 * ls,
      radius: radius * ls,
      // Tracking breaks the Devanagari headline, so only Latin text gets it.
      letterSpacing: lang == LabLang.en ? 1.1 * ls : 0,
      padding: EdgeInsets.symmetric(horizontal: 9 * ls, vertical: 3 * ls),
      opacity: opacity,
    );
  }

  /// The rect [_tag] would paint (used to fade labels under the Earth's).
  Rect _tagRect(String label, Offset at, double size, Alignment anchor) {
    final ls = _ls;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: size * ls,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          letterSpacing: lang == LabLang.en ? 1.1 * ls : 0,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + 18 * ls, h = tp.height + 6 * ls;
    return Rect.fromLTWH(at.dx - (anchor.x + 1) / 2 * w, at.dy - (anchor.y + 1) / 2 * h, w, h);
  }

  // ------------------------------------------------------- orbit view

  void _paintOrbitView(Canvas canvas) {
    final cam = scene.orbitCam;
    _orbitStars(canvas, cam);
    _orbitPath(canvas, cam);
    for (var m = 0; m < 4; m++) {
      _marker(canvas, cam, m);
    }
    final e = scene.earthPos, mo = scene.moonPos;
    final items = <(double, VoidCallback)>[
      (cam.depth(_V3.zero), () => _sun(canvas, cam)),
      (cam.depth(e), () => _earth(canvas, cam, e)),
      (cam.depth(mo), () => _moon(canvas, cam, mo)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final it in items) {
      it.$2();
    }
    if (showLabels) _orbitLabels(canvas, cam);
  }

  /// HTML PointsMaterial (size 0.8, opacity 0.6) background stars.
  void _orbitStars(Canvas canvas, _A2Cam cam) {
    final small = <Offset>[], big = <Offset>[];
    for (final s in _kOrbitStars) {
      final p = cam.project(s);
      if (p == null) continue;
      (0.8 * 280 / p.z > 1.15 ? big : small).add(p.p);
    }
    for (final (pts, w) in [(small, 1.3), (big, 2.0)]) {
      canvas.drawPoints(
        ui.PointMode.points,
        pts,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// HTML EllipseCurve orbit (0x4f46e5, opacity 0.5).
  void _orbitPath(Canvas canvas, _A2Cam cam) {
    final pts = <Offset>[];
    for (var i = 0; i <= 128; i++) {
      final a = i / 128 * math.pi * 2;
      final p = cam.project(_V3(_kOrbitRx * math.cos(a), 0, _kOrbitRz * math.sin(a)));
      if (p != null) pts.add(p.p);
    }
    final path = _a2Poly(pts, close: false);
    const indigo = Color(0xFF4F46E5);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = indigo.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = indigo.withValues(alpha: 0.8),
    );
  }

  /// Ring marker (RingGeometry 2..3) at each month. The step's target is
  /// yellow (0xeab308) and pulses between scale 1 and 1.3 (500 ms yoyo).
  void _marker(Canvas canvas, _A2Cam cam, int m) {
    final a = _monthAngle(m);
    final c = _V3(_kOrbitRx * math.cos(a), -0.1, _kOrbitRz * math.sin(a));
    final isTarget = scene.targetMonth == m;
    var sc = 1.0;
    if (isTarget) {
      final t = (scene.time - scene.pulseSince) / 0.5;
      final tri = t % 2 < 1 ? t % 1 : 1 - t % 1;
      sc = 1 + 0.3 * tri;
    }
    List<Offset> ring(double r) {
      final out = <Offset>[];
      for (var i = 0; i < 48; i++) {
        final t = i / 48 * math.pi * 2;
        final p = cam.project(c + _V3(r * math.cos(t), 0, r * math.sin(t)));
        if (p != null) out.add(p.p);
      }
      return out;
    }

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(_a2Poly(ring(3 * sc)), Offset.zero)
      ..addPath(_a2Poly(ring(2 * sc)), Offset.zero);
    final color = isTarget ? const Color(0xFFEAB308) : const Color(0xFF818CF8);
    if (isTarget) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: isTarget ? 0.95 : 0.55));
  }

  /// White core (r 4) inside the pulsing additive glow sprite (38 ± 1.5).
  void _sun(Canvas canvas, _A2Cam cam) {
    final p = cam.project(_V3.zero);
    if (p == null) return;
    canvas.drawCircle(p.p, 4 * p.k, Paint()..color = Colors.white);
    final gr = (38 + math.sin(scene.time * 2) * 1.5) / 2 * p.k;
    canvas.drawCircle(
      p.p,
      gr,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = const RadialGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(255, 240, 150, 1),
            Color.fromRGBO(255, 160, 0, 0.8),
            Color.fromRGBO(255, 50, 0, 0.3),
            Color.fromRGBO(255, 0, 0, 0),
          ],
          stops: [0, 0.1, 0.25, 0.5, 1],
        ).createShader(Rect.fromCircle(center: p.p, radius: gr)),
    );
  }

  /// Ocean sphere (0x0ea5e9) with spinning green land (0x22c55e), lit by
  /// the Sun's point light (dark night side facing away from the Sun) and
  /// the additive atmosphere (0x93c5fd).
  void _earth(Canvas canvas, _A2Cam cam, _V3 e) {
    final pc = cam.project(e);
    if (pc == null) return;
    final rr = _kEarthR * pc.k;
    final disk = Rect.fromCircle(center: pc.p, radius: rr);
    final v = (cam.pos - e).unit;
    final s = (_V3.zero - e).unit;
    final d2 = Offset(s.dot(cam.right), -s.dot(cam.up));
    final lc = d2.distance > 1e-3 ? d2 / d2.distance : Offset.zero;

    canvas.save();
    canvas.clipPath(Path()..addOval(disk));
    canvas.drawRect(
      disk,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(lc.dx * 0.45, lc.dy * 0.45),
          radius: 1.1,
          colors: const [Color(0xFF7DD3FC), Color(0xFF0EA5E9), Color(0xFF075985)],
          stops: const [0, 0.45, 1],
        ).createShader(disk),
    );
    final rot = scene.earthSpin;
    final land = Path();
    for (final c in _kLandCells) {
      if (c.n.rotY(rot).dot(v) <= 0) continue;
      final pts = <Offset>[];
      for (final k in c.corners) {
        final q = cam.project(e + k.rotY(rot) * _kEarthR);
        if (q != null) pts.add(q.p);
      }
      if (pts.length == 4) land.addPath(_a2Poly(pts), Offset.zero);
    }
    canvas.drawPath(land, Paint()..color = const Color(0xFF22C55E));
    canvas.drawPath(
      land,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = const Color(0xFF15803D).withValues(alpha: 0.7),
    );
    canvas.drawRect(
      disk,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          stops: const [0.55, 1],
        ).createShader(disk),
    );
    canvas.drawPath(
      _a2NightPath(pc.p, rr * 1.03, d2, s.dot(v)),
      Paint()
        ..color = const Color(0xFF020617).withValues(alpha: 0.84)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rr * 0.08 + 0.4),
    );
    if (lc != Offset.zero) {
      final hc = pc.p + lc * (rr * 0.5);
      canvas.drawCircle(
        hc,
        rr * 0.9,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: hc, radius: rr * 0.9)),
      );
    }
    canvas.restore();
    final atm = rr * 1.09;
    canvas.drawCircle(
      pc.p,
      atm,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = const RadialGradient(
          colors: [
            Color.fromRGBO(147, 197, 253, 0.08),
            Color.fromRGBO(147, 197, 253, 0.14),
            Color.fromRGBO(147, 197, 253, 0.42),
            Color.fromRGBO(147, 197, 253, 0),
          ],
          stops: [0, 0.8, 0.91, 1],
        ).createShader(Rect.fromCircle(center: pc.p, radius: atm)),
    );
  }

  /// Cratered grey Moon (0xe2e8f0) circling the Earth, lit by the Sun.
  void _moon(Canvas canvas, _A2Cam cam, _V3 m) {
    final pc = cam.project(m);
    if (pc == null) return;
    final rr = _kMoonR * pc.k;
    final disk = Rect.fromCircle(center: pc.p, radius: rr);
    final v = (cam.pos - m).unit;
    final s = (_V3.zero - m).unit;
    final d2 = Offset(s.dot(cam.right), -s.dot(cam.up));
    final lc = d2.distance > 1e-3 ? d2 / d2.distance : Offset.zero;
    canvas.save();
    canvas.clipPath(Path()..addOval(disk));
    canvas.drawRect(
      disk,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(lc.dx * 0.45, lc.dy * 0.45),
          radius: 1.1,
          colors: const [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        ).createShader(disk),
    );
    final crater = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.55);
    for (final (dx, dy, r) in const [(-0.3, -0.2, 0.22), (0.35, 0.25, 0.16), (0.05, 0.45, 0.12)]) {
      canvas.drawCircle(pc.p + Offset(dx * rr, dy * rr), r * rr, crater);
    }
    canvas.drawPath(
      _a2NightPath(pc.p, rr * 1.03, d2, s.dot(v)),
      Paint()
        ..color = const Color(0xFF020617).withValues(alpha: 0.86)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rr * 0.08 + 0.3),
    );
    canvas.restore();
  }

  /// HTML `createLabel`: month names under the markers, SUN and EARTH.
  void _orbitLabels(Canvas canvas, _A2Cam cam) {
    final e = cam.project(scene.earthPos);
    final earthLabel = text('lbl_earth').toUpperCase();
    final earthAt = e == null ? null : e.p - Offset(0, _kEarthR * 1.1 * e.k + 4 * _ls);
    final earthRect = earthAt == null ? null : _tagRect(earthLabel, earthAt, 13.5, Alignment.bottomCenter);
    for (var m = 0; m < 4; m++) {
      final a = _monthAngle(m);
      final p = cam.project(_V3(_kOrbitRx * math.cos(a), -0.1, _kOrbitRz * math.sin(a)));
      if (p == null) continue;
      final at = p.p + Offset(0, _kEarthR * 1.05 * p.k + 3 * _ls);
      final label = text('month_$m');
      final hidden = earthRect != null && _tagRect(label, at, 12, Alignment.topCenter).overlaps(earthRect);
      _tag(
        canvas,
        label,
        at,
        size: 12,
        color: Colors.white,
        bg: const Color(0xE60F172A),
        border: const Color(0xCC94A3B8),
        radius: 4,
        anchor: Alignment.topCenter,
        opacity: hidden ? 0.3 : 1,
      );
    }
    // Under the Sun's core (above it the label would collide with the
    // December marker's label).
    final sun = cam.project(_V3.zero);
    if (sun != null) {
      _tag(
        canvas,
        text('lbl_sun').toUpperCase(),
        sun.p + Offset(0, 4 * sun.k + 5 * _ls),
        size: 13.5,
        anchor: Alignment.topCenter,
        color: const Color(0xFFFDE047),
        bg: const Color(0xCC713F12),
        border: const Color(0xFFFACC15),
      );
    }
    if (earthAt != null) {
      _tag(
        canvas,
        earthLabel,
        earthAt,
        size: 13.5,
        color: const Color(0xFFDBEAFE),
        bg: const Color(0xCC1E3A8A),
        border: const Color(0xFF60A5FA),
        anchor: Alignment.bottomCenter,
      );
    }
  }

  // ------------------------------------------------------- ground view

  void _paintGroundView(Canvas canvas, Size size) {
    final cam = scene.groundCam;
    final bleed = labBleed(size);
    // Faint glow above the horizon so the dark silhouette reads.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, 300, bleed.right, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00312E81), Color(0x47312E81), Color(0x2E1E1B4B)],
          stops: [0, 0.72, 1],
        ).createShader(const Rect.fromLTRB(0, 300, 1000, 560)),
    );
    _skyStars(canvas, cam);
    for (var m = 0; m < 4; m++) {
      _constellation3D(canvas, cam, m);
    }
    _ground(canvas, bleed);
    if (showLabels) {
      for (var m = 0; m < 4; m++) {
        final p = cam.project(_V3(_kConstSpacing * m, 1.5, -50));
        if (p == null || p.p.dx < -600 || p.p.dx > 1600) continue;
        _tag(
          canvas,
          text('const_$m'),
          p.p,
          size: 12,
          color: const Color(0xFFC7D2FE),
          bg: const Color(0xE60F172A),
          border: const Color(0xCC6366F1),
          radius: 4,
        );
      }
    }
  }

  /// HTML sky Points (1500 stars, size 0.5, opacity 0.8) on the plane
  /// z = -50, with a gentle twinkle.
  void _skyStars(Canvas canvas, _A2Cam cam) {
    final depth = scene.camZ + 50;
    final k = cam.f / depth;
    final px = 0.5 * 280 / depth;
    final buckets = <int, List<Offset>>{};
    for (final s in _kSkyStars) {
      final x = cam.center.dx + (s.x - scene.camX) * k;
      if (x < -1600 || x > 2600) continue;
      final y = cam.center.dy - s.y * k;
      final sb = (s.size * px * 2).round().clamp(1, 8);
      buckets.putIfAbsent(sb * 10 + s.phase, () => []).add(Offset(x, y));
    }
    for (final e in buckets.entries) {
      final phase = e.key % 10;
      final tw = 0.72 + 0.28 * math.sin(scene.time * 1.7 + phase * 2.1);
      canvas.drawPoints(
        ui.PointMode.points,
        e.value,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8 * tw)
          ..strokeWidth = (e.key ~/ 10) / 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// One HTML constellation group at x = 100 * month, y = 20 on the sky
  /// plane: indigo (0x818cf8) figure lines and star spheres (r 0.5).
  void _constellation3D(Canvas canvas, _A2Cam cam, int m) {
    final c = _kConstellations[m];
    final cx = _kConstSpacing * m;
    final centre = cam.project(_V3(cx, 20, -50));
    if (centre == null || centre.p.dx < -900 || centre.p.dx > 1900) return;
    Offset? w(double x, double y) => cam.project(_V3(cx + (x - 50) * 0.4, 20 - (y - 50) * 0.4, -50))?.p;
    final path = Path();
    for (final l in c.lines) {
      final pts = [for (final p in l.pts) w(p.dx, p.dy)].whereType<Offset>().toList();
      if (pts.length < 2) continue;
      path.addPath(_a2Poly(pts, close: l.closed), Offset.zero);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF818CF8),
    );
    for (final s in c.stars) {
      final p = w(s.x, s.y);
      if (p == null) continue;
      final r = 0.5 * (s.r / 2) * centre.k;
      labGlow(canvas, p, r * 3.4, s.color, intensity: 0.55);
      canvas.drawCircle(p, r, Paint()..color = s.color);
    }
  }

  /// HTML ground silhouette (hills and trees #020617, houses #0f172a),
  /// fixed to the screen bottom, extended into the letterbox.
  void _ground(Canvas canvas, Rect bleed) {
    final fill = Paint()..color = const Color(0xFF020617);
    canvas.save();
    canvas.translate(0, _kGroundTop);
    canvas.scale(1, _kGroundScaleY);
    canvas.drawPath(_kHillsPath, fill);
    canvas.drawPath(_kHousesPath, Paint()..color = const Color(0xFF0F172A));
    canvas.restore();
    canvas.drawRect(Rect.fromLTRB(bleed.left, _kGroundTop + 90 * _kGroundScaleY, 1, bleed.bottom), fill);
    canvas.drawRect(Rect.fromLTRB(999, _kGroundTop + 100 * _kGroundScaleY, bleed.right, bleed.bottom), fill);
    canvas.drawRect(Rect.fromLTRB(bleed.left, _kA2Design.height - 1, bleed.right, bleed.bottom), fill);
  }

  @override
  bool shouldRepaint(covariant _A2Painter old) =>
      old.scene != scene || old.showLabels != showLabels || old.lang != lang;
}

// ============================================================ SMALL PAINTERS

/// Night Sky View picture-in-picture: the HTML constellation SVG
/// (viewBox 100 x 100, indigo-300 lines, star circles) with the line
/// drawing animation ([progress] 0..1 over 2 s).
class _A2PipPainter extends CustomPainter {
  _A2PipPainter({required this.month, required this.progress});

  final int month;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final rnd = math.Random(month * 31 + 5);
    canvas.drawPoints(
      ui.PointMode.points,
      [for (var i = 0; i < 46; i++) Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height)],
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
    final sc = math.min(size.width, size.height) / 100;
    canvas.save();
    canvas.translate((size.width - 100 * sc) / 2, (size.height - 100 * sc) / 2);
    canvas.scale(sc);
    final c = _kConstellations[month];
    var remain = progress.clamp(0.0, 1.0);
    final metrics = _constellationPath(c).computeMetrics().toList();
    final total = metrics.fold<double>(0, (a, m) => a + m.length);
    remain *= total;
    final partial = Path();
    for (final m in metrics) {
      if (remain <= 0) break;
      final l = math.min(remain, m.length);
      partial.addPath(m.extractPath(0, l), Offset.zero);
      remain -= l;
    }
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFA5B4FC),
    );
    for (final s in c.stars) {
      final p = Offset(s.x, s.y);
      labGlow(canvas, p, s.r * 2.6, s.color, intensity: 0.45);
      canvas.drawCircle(p, s.r, Paint()..color = s.color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _A2PipPainter old) => old.month != month || old.progress != progress;
}

/// The HTML clock SVG (viewBox 24): indigo face, white hands at 9 o'clock
/// position style "M12 6v6l4 2".
class _A2ClockPainter extends CustomPainter {
  const _A2ClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(const Offset(12, 12), 10, stroke..color = const Color(0xFF6366F1));
    canvas.drawPath(
      Path()
        ..moveTo(12, 6)
        ..lineTo(12, 12)
        ..lineTo(16, 14),
      stroke..color = const Color(0xFFF8FAFC),
    );
  }

  @override
  bool shouldRepaint(covariant _A2ClockPainter old) => false;
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
