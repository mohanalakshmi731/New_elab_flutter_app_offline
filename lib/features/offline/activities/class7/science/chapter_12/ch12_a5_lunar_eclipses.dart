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

/// Class 7 Science • Chapter 12 • Activity 5
/// Lunar Eclipses.
///
/// Native Flutter port of `Cl7S-Ch12-A5-Lunar_Eclipses.html`.
/// Scenario 1: drag the Earth and the Moon from the Assets Box into their
/// orbits, then drag the Moon into and out of the Earth's shadow.
/// Scenario 2: play the 12 second animation of the Moon crossing the
/// shadow, pausing at the partial, total (blood moon) and partial phases.
class Ch12A5LunarEclipsesPage extends StatefulWidget {
  const Ch12A5LunarEclipsesPage({super.key});

  @override
  State<Ch12A5LunarEclipsesPage> createState() => _Ch12A5LunarEclipsesPageState();
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

class _A5Tween {
  _A5Tween(this.start, this.duration, this.curve, this.apply);
  final double start;
  final double duration;
  final Curve curve;
  final void Function(double v) apply;
}

class _Ch12A5LunarEclipsesPageState extends State<Ch12A5LunarEclipsesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A5Scene _scene = _A5Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_A5Tween> _tweens = [];
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  late final Ticker _ticker;
  double _lastTick = 0;

  // Assets Box drag (HTML State.dragState) and the ghost under the finger.
  String? _assetDrag;
  Offset? _ghost;
  Offset _lastGlobal = Offset.zero;

  // Moon orbit drag (HTML State.isDraggingMoonOrbit).
  bool _orbitDrag = false;

  // Scenario 2 animation (HTML animState: 12 s linear tween 0.6 -> -0.6).
  bool _isPlaying = false;
  bool _animPaused = false;
  double _animElapsed = 0;
  static const double _animDuration = 12;

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
      if (v >= 1) _tweens.remove(tw);
    }

    if (_isPlaying && !_animPaused) {
      _animElapsed = math.min(_animDuration, _animElapsed + dt);
      _scene.moonAngle = 0.6 - 1.2 * (_animElapsed / _animDuration);
      _checkAnimStep();
      if (_animElapsed >= _animDuration && _isPlaying) {
        _isPlaying = false;
        _checkAnimStep();
      }
    }

    // Label fades (CSS opacity transition 0.3 s).
    final targets = _scene.labelTargets();
    for (final e in targets.entries) {
      final target = e.value && _lab.showLabels && _lab.isLabActive ? 1.0 : 0.0;
      final cur = _scene.labelAlpha[e.key] ?? 0;
      _scene.labelAlpha[e.key] = cur + (target - cur).clamp(-dt / 0.3, dt / 0.3);
    }
    _frame.value = now;
  }

  void _camTween(_V3 pos, _V3 target) {
    final p0 = _scene.camPos, t0 = _scene.camTarget;
    _tweens.add(
      _A5Tween(_scene.time, 1, Curves.easeOutCubic, (v) {
        _scene.camPos = _V3.lerp(p0, pos, v);
        _scene.camTarget = _V3.lerp(t0, target, v);
      }),
    );
  }

  // ---------------------------------------------------------- scenario

  /// HTML `resetApp(keepScenario)` scene part.
  void _buildScenario(int index) {
    _lab.cancelPending();
    _tweens.clear();
    _assetDrag = null;
    _ghost = null;
    _orbitDrag = false;
    _isPlaying = false;
    _animPaused = false;
    _animElapsed = 0;
    _scene.reset(index);
    _lab.camLocked = true;
    _lab.showLabels = true;
    _lab.panMode = false;
    if (index == 0) {
      _camTween(_s1CamPos, _s1CamTarget);
    } else {
      _camTween(_s2CamPos, _s2CamTarget);
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
    } else if (_step == n) {
      _scene.step++;
      _lab.after(const Duration(milliseconds: 1000), _showSummary);
    }
  }

  // ------------------------------------------------------ scenario 1

  String? get _assetNeeded {
    if (_scenario != 0) return null;
    if (_step == 1) return 'earth';
    if (_step == 2) return 'moon';
    return null;
  }

  void _assetPanStart(String type, DragStartDetails d) {
    if (_assetNeeded != type) return;
    _lastGlobal = d.globalPosition;
    _Audio.play(_Sound.pickup);
    setState(() {
      _assetDrag = type;
      _ghost = labGlobalToLocal(_canvasKey, d.globalPosition);
    });
  }

  void _assetPanUpdate(DragUpdateDetails d) {
    if (_assetDrag == null) return;
    _lastGlobal = d.globalPosition;
    setState(() => _ghost = labGlobalToLocal(_canvasKey, d.globalPosition));
  }

  /// HTML pointerup with an asset: raycast the drop zone (60 x 60 for the
  /// Earth, 100 x 100 for the Moon) around the Earth's orbital position.
  void _assetPanEnd() {
    final type = _assetDrag;
    if (type == null) return;
    setState(() {
      _assetDrag = null;
      _ghost = null;
    });
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(_lastGlobal);
    if (!(Offset.zero & box.size).contains(local)) return;
    final design = labGlobalToLocal(_stageKey, _lastGlobal);
    final hit = design == null ? null : _scene.cam.rayPlaneY(design);
    final half = type == 'earth' ? 30.0 : 50.0;
    final ok = hit != null && (hit.x - _earthPos.x).abs() <= half && hit.z.abs() <= half;
    if (!ok) {
      _lab.showToast(_t('feedback_wrong_drop'), isError: true);
      return;
    }
    setState(() {
      if (type == 'earth') {
        _scene
          ..earthPlaced = true
          ..targetVisible = false;
        _lab.showToast(_t('feedback_snap_earth'));
      } else {
        _scene
          ..moonVisible = true
          ..moonAngle = math.atan2(hit.z, hit.x - _earthPos.x);
        _lab.showToast(_t('feedback_snap_moon'));
      }
      _advanceStep();
    });
  }

  bool _hitMoon(Offset p) => _scene.moonVisible && _scene.cam.rayDistance(p, _scene.moonPos) < _moonR * 4;

  void _dragMoonTo(Offset p) {
    final hit = _scene.cam.rayPlaneY(p);
    if (hit == null || (hit.x - _earthPos.x).abs() > 50 || hit.z.abs() > 50) return;
    _scene.moonAngle = math.atan2(hit.z, hit.x - _earthPos.x);
  }

  /// HTML `checkMoonDragStepProgress()`.
  void _checkMoonDragStep() {
    if (_scenario != 0) return;
    final ph = _scene.phase;
    if (_step == 3 && ph != _Phase.clear) {
      _Audio.play(_Sound.success);
      _lab.showToast(_t('feedback_moon_shadow'), sound: false);
      _advanceStep();
    } else if (_step == 4 && ph == _Phase.clear) {
      _Audio.play(_Sound.success);
      _advanceStep();
    }
  }

  bool get _orbitStep => _scenario == 0 && (_step == 3 || _step == 4) && !_isPlaying;

  void _onPanStart(DragStartDetails d) {
    if (_orbitStep && _hitMoon(d.localPosition)) {
      _orbitDrag = true;
      _Audio.play(_Sound.pickup);
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_orbitDrag) _dragMoonTo(d.localPosition);
  }

  void _onPanEnd() {
    if (!_orbitDrag) return;
    _orbitDrag = false;
    setState(_checkMoonDragStep);
  }

  void _onTapUp(TapUpDetails d) {
    if (_orbitStep && _hitMoon(d.localPosition)) setState(_checkMoonDragStep);
  }

  // ------------------------------------------------------ scenario 2

  /// HTML `startEclipseAnimation()`.
  void _startAnimation() {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _animPaused = false;
      _animElapsed = 0;
      _scene.moonAngle = 0.6;
      _advanceStep();
    });
  }

  /// HTML `checkAnimStepProgress()`: pauses 2 s on every phase change.
  void _checkAnimStep() {
    if (_scenario != 1 || _step > _data.steps.length) return;
    final ph = _scene.phase;
    final a = _scene.moonAngle;
    final advance = switch (_step) {
      2 => ph == _Phase.partial && a > 0,
      3 => ph == _Phase.total,
      4 => ph == _Phase.partial && a < 0,
      5 => ph == _Phase.clear && a < -0.35,
      _ => false,
    };
    if (!advance) return;
    _animPaused = true;
    _Audio.play(_Sound.success);
    _lab.after(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _advanceStep();
        if (_step <= _data.steps.length) _animPaused = false;
      });
    });
  }

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
    return Column(
      children: [
        if (sc == 0)
          Container(
            width: 60 * s,
            height: 60 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.isDark ? const Color(0x4D14532D) : const Color(0xFFDCFCE7),
            ),
            child: Icon(Icons.check_rounded, size: 32 * s, color: _Colors.green),
          )
        else
          SizedBox(
            width: 136 * s,
            height: 40 * s,
            child: const CustomPaint(painter: _A5PhaseDiscsPainter()),
          ),
        SizedBox(height: 12 * s),
        Text(
          _t(sc == 0 ? 'sum_title_1' : 'sum_title_2').toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textStrong, fontSize: 19 * s, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        SizedBox(height: 8 * s),
        Text(
          _t(sc == 0 ? 'sum_desc_1' : 'sum_desc_2'),
          textAlign: TextAlign.center,
          style: TextStyle(color: p.text, fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.3), height: 1.5),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- UI

  List<LabAction> _actions() {
    if (_scenario == 1 && _step == 1 && !_isPlaying) {
      return [
        LabAction(
          label: _t('start_animation'),
          icon: Icons.play_circle_fill,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _startAnimation,
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
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            if (_scenario == 0) _assetsPanel(context, p, s, inset),
            if (_scenario == 1 && _step == 1 && !_isPlaying && _lab.isSidebarOpen)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(inset.left, inset.top, inset.right, inset.bottom),
                  child: Center(
                    child: FittedBox(fit: BoxFit.scaleDown, child: _playButton(s)),
                  ),
                ),
              ),
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
                  painter: _A5Painter(
                    scene: _scene,
                    repaint: _frame,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    text: _t,
                  ),
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

  /// HTML `#assets-panel` with the draggable Earth and Moon tiles.
  Widget _assetsPanel(BuildContext context, LabPalette p, double s, EdgeInsets inset) {
    final visible = _assetNeeded != null;
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
                padding: EdgeInsets.all(10 * s),
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
                      width: 140 * s,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 7 * s),
                      color: p.cardBorder,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _assetTile('earth', Icons.public, _Colors.blue, _t('asset_earth'), p, s),
                        SizedBox(width: 10 * s),
                        _assetTile(
                          'moon',
                          Icons.dark_mode,
                          p.isDark ? _Colors.slate300 : _Colors.slate400,
                          _t('asset_moon'),
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

  Widget _assetTile(String type, IconData icon, Color iconColor, String label, LabPalette p, double s) {
    final disabled = type == 'earth' ? _scene.earthPlaced : (!_scene.earthPlaced || _scene.moonVisible);
    final dragging = _assetDrag == type;
    return Opacity(
      opacity: disabled ? 0.3 : (dragging ? 0.5 : 1),
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onPanStart: disabled ? null : (d) => _assetPanStart(type, d),
        onPanUpdate: disabled ? null : _assetPanUpdate,
        onPanEnd: disabled ? null : (_) => _assetPanEnd(),
        child: AnimatedScale(
          scale: dragging ? 0.95 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 64 * s,
            height: 64 * s,
            padding: EdgeInsets.all(4 * s),
            decoration: BoxDecoration(
              color: p.isDark ? _Colors.slate700 : _Colors.slate100,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: dragging ? const Color(0xFF818CF8) : (p.isDark ? _Colors.slate600 : _Colors.slate300),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24 * s, color: iconColor),
                SizedBox(height: 3 * s),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: p.isDark ? _Colors.slate300 : _Colors.slate600,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostView(double s) {
    final g = _ghost!;
    final earth = _assetDrag == 'earth';
    final size = 77 * s;
    return Positioned(
      left: g.dx - size / 2,
      top: g.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _Colors.primary.withValues(alpha: 0.2),
            border: Border.all(color: const Color(0xFF818CF8), width: 2),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
          ),
          child: Icon(
            earth ? Icons.public : Icons.dark_mode,
            size: 36 * s,
            color: earth ? _Colors.blue : _Colors.slate300,
          ),
        ),
      ),
    );
  }

  /// HTML `#btn-play-animation`: a big indigo pill with a play icon.
  Widget _playButton(double s) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          _Audio.play(_Sound.click);
          _startAnimation();
        },
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: _Colors.indigo600,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF818CF8), width: 2),
            boxShadow: const [BoxShadow(color: Color(0x806366F1), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_fill, size: 40 * s, color: Colors.white),
              SizedBox(height: 6 * s),
              Text(
                _t('start_animation').toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 13 * s, fontWeight: FontWeight.w800, letterSpacing: 3),
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
    'app_title': 'Lunar Eclipses',
    'app_subtitle': 'Class 7 • Earth, Moon and the Sun',
    'scen_1_opt': 'Scenario 1: Creating the Eclipse Alignment',
    'scen_2_opt': 'Scenario 2: The Stages of a Lunar Eclipse',
    'observation_complete': 'Observation Complete',
    'btn_next': 'Next Scenario',
    'btn_restart': 'Restart Lab',
    'assets_panel_title': 'Assets Box',
    'asset_earth': 'Earth',
    'asset_moon': 'Moon',
    'start_animation': 'Play',
    'lbl_sun': 'Sun',
    'lbl_earth': 'Earth',
    'lbl_moon': 'Moon',
    'lbl_eclipse': 'Lunar Eclipse',
    'lbl_partial': 'Partial Lunar Eclipse',
    'lbl_total': 'Total Lunar Eclipse',
    'feedback_snap_earth': 'Earth aligned in orbit. Shadow cone visible.',
    'feedback_snap_moon': 'Moon placed in orbit. Sunlit side illuminated.',
    'feedback_moon_shadow': 'Moon entered shadow. Eclipse sequence started.',
    'feedback_wrong_drop': 'Drag near the highlighted target rings!',
    'sum_title_1': 'Alignment Complete',
    'sum_title_2': 'Eclipse Cycle Complete',
    'sum_desc_1':
        'You successfully aligned the Sun, Earth, and Moon to create a Lunar Eclipse. This happens when Earth blocks sunlight from reaching the Moon.',
    'sum_desc_2':
        'You observed the stages: Partial, Total (Blood Moon), and Partial again. This predictable cycle helped early astronomers understand our solar system!',
  },
  'hi': {
    'app_title': 'चंद्र ग्रहण',
    'app_subtitle': 'कक्षा 7 • पृथ्वी, चंद्रमा और सूर्य',
    'scen_1_opt': 'परिदृश्य 1: ग्रहण संरेखण बनाना',
    'scen_2_opt': 'परिदृश्य 2: चंद्र ग्रहण के चरण',
    'observation_complete': 'अवलोकन पूर्ण',
    'btn_next': 'अगला परिदृश्य',
    'btn_restart': 'प्रयोगशाला पुनः प्रारंभ करें',
    'assets_panel_title': 'एसेट्स बॉक्स',
    'asset_earth': 'पृथ्वी',
    'asset_moon': 'चंद्रमा',
    'start_animation': 'चलाएं',
    'lbl_sun': 'सूर्य',
    'lbl_earth': 'पृथ्वी',
    'lbl_moon': 'चंद्रमा',
    'lbl_eclipse': 'चंद्र ग्रहण',
    'lbl_partial': 'आंशिक चंद्र ग्रहण',
    'lbl_total': 'पूर्ण चंद्र ग्रहण',
    'feedback_snap_earth': 'पृथ्वी कक्षा में संरेखित। छाया शंकु दिखाई दे रहा है।',
    'feedback_snap_moon': 'चंद्रमा कक्षा में रखा गया। सूर्य के प्रकाश वाला भाग प्रकाशित है।',
    'feedback_moon_shadow': 'चंद्रमा ने छाया में प्रवेश किया। ग्रहण अनुक्रम शुरू हुआ।',
    'feedback_wrong_drop': 'हाइलाइट किए गए लक्ष्य रिंग्स के पास खींचें!',
    'sum_title_1': 'संरेखण पूर्ण',
    'sum_title_2': 'ग्रहण चक्र पूर्ण',
    'sum_desc_1':
        'आपने चंद्र ग्रहण बनाने के लिए सूर्य, पृथ्वी और चंद्रमा को सफलतापूर्वक संरेखित किया है। ऐसा तब होता है जब पृथ्वी सूर्य के प्रकाश को चंद्रमा तक पहुंचने से रोकती है।',
    'sum_desc_2':
        'आपने चरणों का निरीक्षण किया: आंशिक, पूर्ण (ब्लड मून), और फिर से आंशिक। इस अनुमानित चक्र ने प्रारंभिक खगोलविदों को हमारे सौर मंडल को समझने में मदद की!',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'Arrange the Sun, Earth, and Moon in a straight line to demonstrate how a lunar eclipse is formed.',
      steps: [
        LabStep(
          concept: 'Earth Placement',
          action: 'DRAG the Earth from the Asset panel and DROP it onto the glowing orbital path.',
          observation: 'Earth snaps to orbit. A shadow cone appears pointing away from the Sun.',
        ),
        LabStep(
          concept: 'Moon Placement',
          action: 'DRAG the Moon from the Asset panel and DROP it onto the smaller orbit around Earth.',
          observation: 'Moon snaps to orbit. The side facing the Sun is brightly lit.',
        ),
        LabStep(
          concept: 'Entering the Shadow',
          action: "DRAG the Moon along its orbit into the Earth's shadow.",
          observation: "Moon surface darkens. 'Lunar Eclipse' label appears.",
        ),
        LabStep(
          concept: 'Exiting the Shadow',
          action: 'DRAG the Moon out of the shadow on the other side.',
          observation: 'Moon becomes fully illuminated again. Eclipse is a temporary positional event.',
        ),
      ],
    ),
    LabScenarioData(
      objective: "Observe the different phases of a lunar eclipse as the Moon travels through the Earth's shadow.",
      steps: [
        LabStep(
          concept: 'Initiate Motion',
          action: "CLICK the 'Play' button to begin the Moon's motion.",
          observation: 'The Moon begins to move slowly towards the shadow.',
        ),
        LabStep(
          concept: 'Entering Penumbra/Umbra',
          action: 'Observe the Moon as its leading edge enters the shadow.',
          observation: "Edge darkens. 'Partial Lunar Eclipse' begins.",
        ),
        LabStep(
          concept: 'Total Envelopment',
          action: 'Observe as the Moon moves completely into the center of the shadow.',
          observation: "Entire Moon glows reddish-brown. 'Total Lunar Eclipse' phase.",
        ),
        LabStep(
          concept: 'Exiting Umbra',
          action: 'Watch as the Moon begins to exit the shadow.',
          observation: "A sliver becomes brightly lit. Returns to 'Partial Lunar Eclipse'.",
        ),
        LabStep(
          concept: 'Eclipse Completion',
          action: 'The simulation completes when the Moon fully exits.',
          observation: 'Moon is fully illuminated. The eclipse journey is over.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'चंद्र ग्रहण कैसे बनता है, यह दर्शाने के लिए सूर्य, पृथ्वी और चंद्रमा को एक सीधी रेखा में व्यवस्थित करें।',
      steps: [
        LabStep(
          concept: 'पृथ्वी का स्थान निर्धारण',
          action: 'पृथ्वी को खींचकर चमकदार कक्षीय पथ पर छोड़ें।',
          observation: 'पृथ्वी कक्षा में स्थापित हो जाती है। सूर्य से दूर की ओर इंगित करता एक छाया शंकु दिखाई देता है।',
        ),
        LabStep(
          concept: 'चंद्रमा का स्थान निर्धारण',
          action: 'चंद्रमा को खींचकर पृथ्वी के चारों ओर छोटी कक्षा पर छोड़ें।',
          observation: 'चंद्रमा कक्षा में स्थापित हो जाता है। सूर्य की ओर वाला भाग चमकीला रोशन होता है।',
        ),
        LabStep(
          concept: 'छाया में प्रवेश',
          action: 'चंद्रमा को उसकी कक्षा में पृथ्वी की छाया में खींचें।',
          observation: "चंद्रमा की सतह काली पड़ जाती है। 'चंद्र ग्रहण' लेबल दिखाई देता है।",
        ),
        LabStep(
          concept: 'छाया से बाहर निकलना',
          action: 'चंद्रमा को छाया से बाहर दूसरी तरफ खींचें।',
          observation: 'चंद्रमा फिर से पूरी तरह प्रकाशित हो जाता है। ग्रहण एक अस्थायी स्थितिजन्य घटना है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'चंद्रमा के पृथ्वी की छाया से गुजरते समय चंद्र ग्रहण के विभिन्न चरणों का निरीक्षण करें।',
      steps: [
        LabStep(
          concept: 'गति आरंभ करें',
          action: "चंद्रमा की गति शुरू करने के लिए 'प्ले' बटन पर क्लिक करें।",
          observation: 'चंद्रमा धीरे-धीरे छाया की ओर बढ़ना शुरू करता है।',
        ),
        LabStep(
          concept: 'उपछाया/प्रच्छाया में प्रवेश',
          action: 'चंद्रमा के छाया में प्रवेश करते समय उसका निरीक्षण करें।',
          observation: "किनारा काला पड़ता है। 'आंशिक चंद्र ग्रहण' शुरू होता है।",
        ),
        LabStep(
          concept: 'पूर्ण आच्छादन',
          action: 'छाया के केंद्र में पूरी तरह से जाने पर चंद्रमा का निरीक्षण करें।',
          observation: "पूरा चंद्रमा लाल-भूरे रंग में चमकता है। 'पूर्ण चंद्र ग्रहण' चरण।",
        ),
        LabStep(
          concept: 'प्रच्छाया से बाहर निकलना',
          action: 'छाया से बाहर निकलते समय चंद्रमा को देखें।',
          observation: "एक पतला भाग चमकीला हो जाता है। फिर से 'आंशिक चंद्र ग्रहण'।",
        ),
        LabStep(
          concept: 'ग्रहण की समाप्ति',
          action: 'चंद्रमा के पूरी तरह से बाहर निकलने पर सिमुलेशन पूरा हो जाता है।',
          observation: 'चंद्रमा पूरी तरह प्रकाशित है। ग्रहण की यात्रा समाप्त हुई।',
        ),
      ],
    ),
  ],
};

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
}

typedef _Proj = ({Offset p, double z, double k});

/// Look-at perspective camera projecting into design coordinates.
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

  _V3 ray(Offset s) => (fwd + right * ((s.dx - center.dx) / f) + up * ((center.dy - s.dy) / f)).unit;

  double rayDistance(Offset s, _V3 q) {
    final d = ray(s);
    final v = q - pos;
    final t = math.max(0.0, v.dot(d));
    return (v - d * t).length;
  }

  _V3? rayPlaneY(Offset s, [double h = 0]) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (h - pos.y) / d.y;
    if (t <= 0) return null;
    return pos + d * t;
  }
}

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);
const double _f = 850;
const Offset _center = Offset(470, 280);

const _V3 _sunPos = _V3(-45, 0, 0);
const _V3 _earthPos = _V3(15, 0, 0);
const double _earthR = 5;
const double _moonR = 1.5;
const double _orbitM = 16;
const _V3 _s1CamPos = _V3(-15, 40, 75), _s1CamTarget = _V3(-10, 0, 0);
const _V3 _s2CamPos = _V3(5, 30, 50), _s2CamTarget = _V3(15, 0, 0);

enum _Phase { clear, partial, total }

class _A5Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  bool earthPlaced = false;
  bool moonVisible = false;
  bool targetVisible = true;
  double moonAngle = math.pi * 0.8;
  _V3 camPos = _s1CamPos;
  _V3 camTarget = _s1CamTarget;

  /// Fading opacity of each HTML label (CSS `transition: opacity 0.3s`).
  final Map<String, double> labelAlpha = {};

  _Cam get cam => _Cam(camPos, camTarget, f: _f, center: _center);

  _V3 get moonPos => _V3(_earthPos.x + math.cos(moonAngle) * _orbitM, 0, math.sin(moonAngle) * _orbitM);

  /// Moon angle normalised to (-pi, pi]; 0 is directly behind the Earth.
  double get normAngle {
    var a = moonAngle % (math.pi * 2);
    if (a > math.pi) a -= math.pi * 2;
    if (a < -math.pi) a += math.pi * 2;
    return a;
  }

  /// HTML `updateEclipseVisuals` thresholds.
  _Phase get phase {
    final d = normAngle.abs();
    if (d < 0.15) return _Phase.total;
    if (d < 0.35) return _Phase.partial;
    return _Phase.clear;
  }

  /// Moon material colour and emissive glow for the current phase.
  (Color, Color) get moonColors {
    final d = normAngle.abs();
    if (d < 0.15) return (const Color(0xFF331111), const Color(0xFF450000));
    if (d < 0.35) {
      return (Color.lerp(const Color(0xFF333333), const Color(0xFFDDDDDD), (d - 0.15) / 0.2)!, Colors.black);
    }
    return (const Color(0xFFDDDDDD), Colors.black);
  }

  /// Which labels should be shown right now (before the showLabels toggle).
  Map<String, bool> labelTargets() {
    final ph = phase;
    return {
      'sun': true,
      'earth': earthPlaced,
      'moon': moonVisible,
      'eclipse': moonVisible && scenario == 0 && ph != _Phase.clear,
      'partial': moonVisible && scenario == 1 && ph == _Phase.partial,
      'total': moonVisible && scenario == 1 && ph == _Phase.total,
    };
  }

  void reset(int sc) {
    scenario = sc;
    step = 1;
    labelAlpha.clear();
    if (sc == 0) {
      earthPlaced = false;
      moonVisible = false;
      targetVisible = true;
      moonAngle = math.pi * 0.8;
    } else {
      earthPlaced = true;
      moonVisible = true;
      targetVisible = false;
      moonAngle = 0.6;
    }
  }
}

// ============================================================ HELPERS

class _Blob {
  const _Blob(this.normals, this.color, {this.blur = 0});
  final List<_V3> normals;
  final Color color;
  final double blur;
}

/// Three.js SphereGeometry UV mapping of a canvas pixel, with the Earth's
/// `rotation.y = PI / 2` applied.
_V3 _texNormal(double cx, double cy, double w, double h) {
  final phi = cx / w * math.pi * 2;
  final theta = (cy / h * math.pi).clamp(0.001, math.pi - 0.001);
  final x = -math.cos(phi) * math.sin(theta), y = math.cos(theta), z = math.sin(phi) * math.sin(theta);
  return _V3(z, y, -x);
}

List<_V3> _texEllipse(double cx, double cy, double rx, double ry, double rot, {int n = 16}) {
  final c = math.cos(rot), s = math.sin(rot);
  return [
    for (var i = 0; i < n; i++)
      () {
        final a = i / n * math.pi * 2;
        final ex = rx * math.cos(a), ey = ry * math.sin(a);
        return _texNormal(cx + ex * c - ey * s, cy + ex * s + ey * c, 2048, 1024);
      }(),
  ];
}

/// The HTML "High-Fidelity Natural Procedural Earth" (2048 x 1024 canvas):
/// shallows, continents, deserts, islands, jagged ice caps and clouds,
/// generated with a fixed seed.
final List<_Blob> _earthBlobs = () {
  final r = math.Random(42);
  final out = <_Blob>[];
  void land(double cx, double cy, double base, int color, int n, double alpha) {
    for (var i = 0; i < n; i++) {
      final ang = r.nextDouble() * math.pi * 2;
      final dist = r.nextDouble() * base * 0.7;
      final rx = base * 0.4 + r.nextDouble() * base * 0.6;
      final ry = base * 0.3 + r.nextDouble() * base * 0.5;
      final rot = r.nextDouble() * math.pi;
      out.add(
        _Blob(
          _texEllipse(cx + math.cos(ang) * dist, cy + math.sin(ang) * dist, rx, ry, rot),
          Color(color).withValues(alpha: alpha),
        ),
      );
    }
  }

  land(500, 350, 240, 0xFF2B7A78, 12, 0.35);
  land(1100, 320, 260, 0xFF2B7A78, 14, 0.35);
  land(1600, 650, 180, 0xFF2B7A78, 10, 0.35);
  land(700, 700, 160, 0xFF2B7A78, 8, 0.35);
  land(500, 350, 200, 0xFF2D6A4F, 15, 1);
  land(680, 680, 150, 0xFF386641, 12, 1);
  land(1080, 280, 230, 0xFF254441, 16, 1);
  land(1050, 560, 190, 0xFF3A5A40, 14, 1);
  land(1620, 660, 140, 0xFF4A5759, 10, 1);
  land(1050, 450, 140, 0xFFD4A373, 10, 0.75);
  land(1580, 650, 90, 0xFFC38E70, 8, 0.75);
  land(450, 400, 110, 0xFFB5838D, 8, 0.75);
  land(650, 650, 80, 0xFF8D5B4C, 6, 0.75);
  land(1250, 350, 120, 0xFFA98467, 9, 0.75);
  for (var i = 0; i < 40; i++) {
    final ir = r.nextDouble() * 12 + 3;
    out.add(
      _Blob(_texEllipse(r.nextDouble() * 2048, 200 + r.nextDouble() * 624, ir, ir, 0, n: 8), const Color(0xFF386641)),
    );
  }
  for (final north in [true, false]) {
    out.add(
      _Blob([
        for (var x = 0.0; x < 2048; x += 30)
          () {
            final h = 75 + r.nextDouble() * 45;
            return _texNormal(x, north ? h : 1024 - h, 2048, 1024);
          }(),
      ], const Color(0xFFF1F3F5)),
    );
  }
  for (var i = 0; i < 18; i++) {
    out.add(
      _Blob(
        _texEllipse(
          r.nextDouble() * 2048,
          100 + r.nextDouble() * 824,
          100 + r.nextDouble() * 250,
          20 + r.nextDouble() * 50,
          (r.nextDouble() - 0.5) * 0.4,
        ),
        Colors.white.withValues(alpha: 0.28),
        blur: 0.03,
      ),
    );
  }
  return out;
}();

/// 2000 random star positions kept outside the central 150-unit cube.
final List<_V3> _stars = () {
  final r = math.Random(9);
  final out = <_V3>[];
  for (var i = 0; i < 2000; i++) {
    final x = (r.nextDouble() - 0.5) * 1000, y = (r.nextDouble() - 0.5) * 1000, z = (r.nextDouble() - 0.5) * 1000;
    if (x.abs() < 150 && y.abs() < 150 && z.abs() < 150) continue;
    out.add(_V3(x, y, z));
  }
  return out;
}();

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

Path _polyPath(List<Offset> pts, {bool close = true}) {
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

/// Night side of a sphere lit from the screen direction [dir].
Path _nightPath(Offset c, double r, Offset dir, double cosPhi) {
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
  return _polyPath(pts);
}

/// Textured sphere lit by the Sun (MeshStandardMaterial look): base
/// gradient, texture blobs clamped to the visible hemisphere, limb
/// darkening and the night side at [ambient] brightness.
void _drawSphere(
  Canvas canvas,
  _Cam cam,
  _V3 center,
  double r, {
  required List<Color> base,
  List<_Blob> blobs = const [],
  double ambient = 0.1,
}) {
  final pc = cam.project(center);
  if (pc == null) return;
  final rr = r * pc.k;
  final disk = Rect.fromCircle(center: pc.p, radius: rr);
  final toCam = cam.pos - center;
  final v = toCam.unit;
  final limbCos = (r / toCam.length).clamp(0.0, 0.999);
  final limbSin = math.sqrt(1 - limbCos * limbCos);

  canvas.save();
  canvas.clipPath(Path()..addOval(disk));
  canvas.drawRect(
    disk,
    Paint()..shader = RadialGradient(center: const Alignment(-0.2, -0.2), colors: base).createShader(disk),
  );
  for (final b in blobs) {
    final pts = <Offset>[];
    var vis = false;
    for (final n in b.normals) {
      var m = n;
      final c = n.dot(v);
      if (c > limbCos) {
        vis = true;
      } else {
        final perp = n - v * c;
        final pl = perp.length;
        if (pl < 1e-6) continue;
        m = perp * (limbSin / pl) + v * limbCos;
      }
      final pp = cam.project(center + m * r);
      if (pp != null) pts.add(pp.p);
    }
    if (!vis || pts.length < 3) continue;
    final paint = Paint()..color = b.color;
    if (b.blur > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, b.blur * rr + 0.3);
    canvas.drawPath(_polyPath(pts), paint);
  }
  canvas.drawRect(
    disk,
    Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
        stops: const [0.6, 1],
      ).createShader(disk),
  );
  final s = (_sunPos - center).unit;
  final d2 = Offset(s.dot(cam.right), -s.dot(cam.up));
  final cosPhi = s.dot(v);
  canvas.drawPath(
    _nightPath(pc.p, rr * 1.03, d2, cosPhi),
    Paint()
      ..color = Colors.black.withValues(alpha: (1 - ambient) * 0.9)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, rr * 0.05 + 0.5),
  );
  if (d2.distance > 1e-3) {
    final hc = pc.p + d2 / d2.distance * (rr * 0.45);
    canvas.drawCircle(
      hc,
      rr,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: hc, radius: rr)),
    );
  }
  canvas.restore();
}

/// Space scene: starfield, Sun, Earth orbit, target ring, Earth with its
/// shadow cone, the Moon's orbit and the Moon (with eclipse colouring).
class _A5Painter extends CustomPainter {
  _A5Painter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.text,
  }) : super(repaint: repaint);

  final _A5Scene scene;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) text;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.cam;
    canvas.drawRect(labBleed(size), Paint()..color = const Color(0xFF030308));
    _starfield(canvas, cam);
    _sun(canvas, cam);
    _ring(
      canvas,
      cam,
      _sunPos,
      60,
      128,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.4),
    );
    if (scene.targetVisible) _target(canvas, cam);
    if (scene.earthPlaced) _cone(canvas, cam);

    final earthDepth = cam.depth(_earthPos);
    final moonFar = cam.depth(scene.moonPos) > earthDepth;
    if (scene.earthPlaced) _moonOrbit(canvas, cam, earthDepth, far: true);
    if (scene.moonVisible && moonFar) _moon(canvas, cam);
    if (scene.earthPlaced) _earth(canvas, cam);
    if (scene.earthPlaced) _moonOrbit(canvas, cam, earthDepth, far: false);
    if (scene.moonVisible && !moonFar) _moon(canvas, cam);
    _labels(canvas, cam);
  }

  void _starfield(Canvas canvas, _Cam cam) {
    final buckets = <int, List<Offset>>{};
    for (final s in _stars) {
      final p = cam.project(s);
      if (p == null) continue;
      final d = (336 / p.z).clamp(0.6, 3.0);
      buckets.putIfAbsent((d * 2).round(), () => []).add(p.p);
    }
    for (final e in buckets.entries) {
      canvas.drawPoints(
        ui.PointMode.points,
        e.value,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..strokeWidth = e.key / 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _sun(Canvas canvas, _Cam cam) {
    final p = cam.project(_sunPos);
    if (p == null) return;
    canvas.drawCircle(p.p, 9 * p.k, Paint()..color = const Color(0xFFFFFBEA));
    final gr = (70 + math.sin(scene.time * 2) * 2) / 2 * p.k;
    final rect = Rect.fromCircle(center: p.p, radius: gr);
    canvas.drawCircle(
      p.p,
      gr,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = const RadialGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(255, 240, 150, 1),
            Color.fromRGBO(255, 160, 0, 0.6),
            Color.fromRGBO(200, 50, 0, 0.2),
            Color.fromRGBO(0, 0, 0, 0),
          ],
          stops: [0, 0.1, 0.3, 0.6, 1],
        ).createShader(rect),
    );
  }

  /// Flat circle in the y = 0 plane.
  void _ring(Canvas canvas, _Cam cam, _V3 c, double r, int n, Paint paint) {
    final pts = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final a = i / n * math.pi * 2;
      final p = cam.project(c + _V3(r * math.cos(a), 0, r * math.sin(a)));
      if (p != null) pts.add(p.p);
    }
    if (pts.length > 1) canvas.drawPath(_polyPath(pts, close: false), paint);
  }

  /// Indigo target ring (r 7..8) where the Earth should be dropped.
  void _target(Canvas canvas, _Cam cam) {
    final a = scene.scenario == 0 && scene.step == 1 ? 0.8 : 0.2;
    final outer = <Offset>[], inner = <Offset>[];
    for (var i = 0; i < 64; i++) {
      final t = i / 64 * math.pi * 2;
      final po = cam.project(_earthPos + _V3(8 * math.cos(t), 0, 8 * math.sin(t)));
      final pi = cam.project(_earthPos + _V3(7 * math.cos(t), 0, 7 * math.sin(t)));
      if (po != null) outer.add(po.p);
      if (pi != null) inner.add(pi.p);
    }
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(_polyPath(outer), Offset.zero)
      ..addPath(_polyPath(inner), Offset.zero);
    canvas.drawPath(
      ring,
      Paint()
        ..color = const Color(0xFF6366F1).withValues(alpha: a * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(ring, Paint()..color = const Color(0xFF6366F1).withValues(alpha: a));
  }

  /// Open shadow cone (r 5 at the Earth -> 0.1 at 60 units), fading out.
  void _cone(Canvas canvas, _Cam cam) {
    final pts = <Offset>[];
    for (var i = 0; i < 48; i++) {
      final a = i / 48 * math.pi * 2;
      for (final (x, r) in [(_earthPos.x, _earthR), (_earthPos.x + 60, 0.1)]) {
        final p = cam.project(_V3(x, r * math.cos(a), r * math.sin(a)));
        if (p != null) pts.add(p.p);
      }
    }
    final b = cam.project(_earthPos), t = cam.project(_earthPos + const _V3(60, 0, 0));
    if (b == null || t == null || pts.length < 3) return;
    final hull = _polyPath(_hull(pts));
    canvas.drawPath(
      hull,
      Paint()
        ..shader = ui.Gradient.linear(
          b.p,
          t.p,
          const [Color.fromRGBO(5, 5, 15, 0.95), Color.fromRGBO(0, 0, 0, 0.5), Color.fromRGBO(0, 0, 0, 0)],
          const [0, 0.6, 1],
        ),
    );
    // Faint silhouette so the dark cone reads against the black sky.
    canvas.drawPath(
      hull,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = ui.Gradient.linear(
          b.p,
          t.p,
          const [
            Color.fromRGBO(148, 163, 184, 0.35),
            Color.fromRGBO(148, 163, 184, 0.12),
            Color.fromRGBO(148, 163, 184, 0),
          ],
          const [0, 0.55, 1],
        ),
    );
  }

  void _moonOrbit(Canvas canvas, _Cam cam, double earthDepth, {required bool far}) {
    final a = scene.scenario == 0 && scene.step >= 2 ? 0.8 : 0.3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFFFACC15).withValues(alpha: a);
    const n = 96;
    final path = Path();
    var open = false;
    for (var i = 0; i <= n; i++) {
      final t = i / n * math.pi * 2;
      final w = _earthPos + _V3(_orbitM * math.cos(t), 0, _orbitM * math.sin(t));
      final p = cam.project(w);
      final isFar = cam.depth(w) > earthDepth;
      if (p == null || isFar != far) {
        open = false;
        continue;
      }
      if (open) {
        path.lineTo(p.p.dx, p.p.dy);
      } else {
        path.moveTo(p.p.dx, p.p.dy);
        open = true;
      }
    }
    canvas.drawPath(path, paint);
  }

  void _earth(Canvas canvas, _Cam cam) {
    final pc = cam.project(_earthPos);
    if (pc == null) return;
    final rr = _earthR * pc.k;
    _drawSphere(
      canvas,
      cam,
      _earthPos,
      _earthR,
      base: const [Color(0xFF1B4F8A), Color(0xFF134074), Color(0xFF0A192F)],
      blobs: _earthBlobs,
      ambient: 0.1,
    );
    // Additive atmospheric glow (sphere r x 1.04, 0x3b82f6 at 0.3).
    final rect = Rect.fromCircle(center: pc.p, radius: rr * 1.04);
    canvas.drawCircle(
      pc.p,
      rr * 1.04,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = const RadialGradient(
          colors: [
            Color.fromRGBO(59, 130, 246, 0.18),
            Color.fromRGBO(59, 130, 246, 0.3),
            Color.fromRGBO(59, 130, 246, 0.42),
            Color.fromRGBO(59, 130, 246, 0),
          ],
          stops: [0, 0.85, 0.95, 1],
        ).createShader(rect),
    );
  }

  void _moon(Canvas canvas, _Cam cam) {
    final m = scene.moonPos;
    final pc = cam.project(m);
    if (pc == null) return;
    final rr = _moonR * pc.k;
    final (base, emissive) = scene.moonColors;
    int ch(double b, double e) => (b * 255 * 0.1 + e * 255).round().clamp(0, 255);
    final dark = Color.fromARGB(255, ch(base.r, emissive.r), ch(base.g, emissive.g), ch(base.b, emissive.b));
    final blood = scene.phase == _Phase.total;
    if (blood) labGlow(canvas, pc.p, rr * 2.2, const Color(0xFF8B0000), intensity: 0.45);

    final disk = Rect.fromCircle(center: pc.p, radius: rr);
    final s = (_sunPos - m).unit;
    final v = (cam.pos - m).unit;
    final d2 = Offset(s.dot(cam.right), -s.dot(cam.up));
    canvas.save();
    canvas.clipPath(Path()..addOval(disk));
    final lc = d2.distance > 1e-3 ? d2 / d2.distance * 0.45 : Offset.zero;
    canvas.drawRect(
      disk,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(lc.dx, lc.dy),
          radius: 1.1,
          colors: [labShade(base, 0.2), base, labShade(base, -0.25)],
        ).createShader(disk),
    );
    canvas.drawPath(
      _nightPath(pc.p, rr * 1.03, d2, s.dot(v)),
      Paint()
        ..color = dark
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rr * 0.06 + 0.4),
    );
    // The Earth's shadow (a cylinder of radius 5 behind the Earth).
    if (m.x > _earthPos.x) {
      final pts = <Offset>[];
      for (var i = 0; i < 48; i++) {
        final a = i / 48 * math.pi * 2;
        final p = cam.project(_V3(m.x, _earthR * math.cos(a), _earthR * math.sin(a)));
        if (p != null) pts.add(p.p);
      }
      if (pts.length > 2) {
        canvas.drawPath(
          _polyPath(pts),
          Paint()
            ..color = dark
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, rr * 0.12 + 0.5),
        );
      }
    }
    canvas.restore();
  }

  void _labels(Canvas canvas, _Cam cam) {
    double a(String id) => scene.labelAlpha[id] ?? 0;

    void std(String id, String key, _V3 at) {
      final o = a(id);
      final p = cam.project(at);
      if (o <= 0.01 || p == null) return;
      labText(
        canvas,
        text(key),
        p.p,
        size: 14,
        weight: FontWeight.w700,
        color: const Color(0xFFE2E8F0),
        background: const Color(0x800F172A),
        border: const Color(0x4D94A3B8),
        borderWidth: 1,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        opacity: o,
      );
    }

    void eclipse(String id, String key, {bool total = false}) {
      final o = a(id);
      final p = cam.project(scene.moonPos + const _V3(0, -3.5, 0));
      if (o <= 0.01 || p == null) return;
      labText(
        canvas,
        text(key),
        p.p,
        size: 14,
        weight: FontWeight.w800,
        color: total ? const Color(0xFFFCA5A5) : Colors.white,
        background: const Color(0xCC000000),
        border: total ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
        borderWidth: 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        opacity: o,
      );
    }

    final sp = cam.project(_sunPos + const _V3(0, 15, 0));
    final so = a('sun');
    if (sp != null && so > 0.01) {
      labText(
        canvas,
        text('lbl_sun').toUpperCase(),
        sp.p,
        size: 14,
        weight: FontWeight.w800,
        letterSpacing: 2.2,
        color: const Color(0xFFFDE047),
        background: const Color(0x80713F12),
        border: const Color(0x4DFACC15),
        borderWidth: 1,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        opacity: so,
      );
    }
    std('earth', 'lbl_earth', _earthPos + const _V3(0, 8, 0));
    std('moon', 'lbl_moon', scene.moonPos + const _V3(0, 4, 0));
    eclipse('eclipse', 'lbl_eclipse');
    eclipse('partial', 'lbl_partial');
    eclipse('total', 'lbl_total', total: true);
  }

  @override
  bool shouldRepaint(covariant _A5Painter old) =>
      old.showLabels != showLabels || old.lang != lang || old.scene != scene;
}

/// The three moon-phase discs of the "Eclipse Cycle Complete" summary.
class _A5PhaseDiscsPainter extends CustomPainter {
  const _A5PhaseDiscsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final gap = (size.width - 6 * r) / 2;
    for (var i = 0; i < 3; i++) {
      final c = Offset(r + i * (2 * r + gap), r);
      if (i == 1) {
        canvas.drawCircle(
          c,
          r * 1.2,
          Paint()
            ..color = const Color(0x80EF4444)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.3),
        );
        canvas.drawCircle(c, r, Paint()..color = const Color(0xFF7F1D1D));
        canvas.drawCircle(
          c,
          r - 1,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFEF4444),
        );
        continue;
      }
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFF1E293B));
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r - 2)));
      // Lit half on the left (entering) or right (leaving).
      final half = i == 0
          ? Rect.fromLTRB(c.dx - r, c.dy - r * 0.8, c.dx + r * 0.05, c.dy + r * 0.8)
          : Rect.fromLTRB(c.dx - r * 0.05, c.dy - r * 0.8, c.dx + r, c.dy + r * 0.8);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          half,
          topLeft: Radius.circular(i == 0 ? r : 0),
          bottomLeft: Radius.circular(i == 0 ? r : 0),
          topRight: Radius.circular(i == 2 ? r : 0),
          bottomRight: Radius.circular(i == 2 ? r : 0),
        ),
        Paint()..color = const Color(0xFF94A3B8),
      );
      canvas.restore();
      canvas.drawCircle(
        c,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF475569),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _A5PhaseDiscsPainter oldDelegate) => false;
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
