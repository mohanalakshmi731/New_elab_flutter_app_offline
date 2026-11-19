// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 4 • Activity 3
/// Chemical Reactions of Non-metals with Air and Water.
///
/// Native Flutter port of
/// `Cl7S-Ch4-A3-Chemical_Reactions_of_Non_metals_with_Air_and_Water.html`.
/// Scenario 1: burn sulfur on a deflagrating spoon, trap the SO2 in a gas
/// jar, dissolve it in water and turn blue litmus red (acidic).
/// Scenario 2: sulfur in a tumbler of water: no reaction, both litmus
/// papers keep their colour (neutral). The student taps the object named
/// by the current step; tapping another object is an error.
class Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPage extends StatefulWidget {
  const Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPage({super.key});

  @override
  State<Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPage> createState() =>
      _Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, splash 1311, fire 1348.
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
  splash('splash.mp3'),
  fire('fire.mp3');

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
  static const Color orange = Color(0xFFF97316);
  static const Color slate50 = Color(0xFFF8FAFC);
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

class _Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPageState
    extends State<Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _Tweens _tw = _Tweens();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Puff> _puffs = [];
  late final Ticker _ticker;
  double _lastT = 0;

  /// Bumped on every rebuild of the bench; async sequences stop when stale.
  int _gen = 0;

  /// HTML #scenario1-summary / #scenario2-summary is open.
  bool _summaryOpen = false;

  /// HTML #observation-popup is open.
  bool _obsOpen = false;

  _Scene get s => _scene;
  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![s.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_onLabChanged);
    _build();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gen++;
    _ticker.dispose();
    _tw.clear();
    _frame.dispose();
    _lab.removeListener(_onLabChanged);
    _lab.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _lastT).clamp(0.0, 0.1);
    _lastT = t;
    s.time = t;
    _tw.tick(t);
    _updatePuffs(dt);
    _frame.value = t;
  }

  /// Closing a summary (its X or the button) opens the observation popup
  /// 500 ms later, like the HTML closeSummary() / closeS2Summary().
  void _onLabChanged() {
    if (_lab.popup != null) return;
    if (_summaryOpen) {
      _summaryOpen = false;
      final g = _gen;
      _lab.after(const Duration(milliseconds: 500), () {
        if (_alive(g)) _openObservation();
      });
    }
    _obsOpen = false;
  }

  // ------------------------------------------------------------ helpers

  bool _alive(int g) => mounted && g == _gen;

  Future<void> _tween(int ms, void Function(double v) f, {Curve curve = Curves.linear}) {
    final c = Completer<void>();
    _tw.add(ms, f, curve: curve, done: c.complete);
    return c.future;
  }

  Future<void> _wait(int ms) {
    final c = Completer<void>();
    _lab.after(Duration(milliseconds: ms), c.complete);
    return c.future;
  }

  // ------------------------------------------------------------ building

  /// HTML `resetScene()` / `buildSceneObjects()`.
  void _build() {
    _gen++;
    _lab.cancelPending();
    _tw.clear();
    _puffs.clear();
    _summaryOpen = false;
    _obsOpen = false;
    s.reset(s.scenario);
    _focus();
  }

  void _changeScenario(int index) {
    setState(() {
      _summaryOpen = false;
      _obsOpen = false;
      _lab.hidePopup(sound: false);
      s.scenario = index;
      _build();
    });
  }

  void _fullReset() {
    setState(() {
      s.scenario = 0;
      _build();
    });
  }

  /// HTML updateHUD(): the orbit target glides to the current step object.
  void _focus() {
    final id = s.target;
    if (id == null) return;
    final base = s.layout.baseX;
    final goal = base + 0.25 * (s.posOf(id).x - base);
    final from = s.cam.camX;
    _tw.add(1000, (v) => s.cam.camX = from + (goal - from) * v, curve: Curves.easeOutQuad);
  }

  // ------------------------------------------------------------ taps

  /// HTML `onMouseClick`: the right object runs the step, any other
  /// interactive object shows the error feedback.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive || s.animating || s.complete) return;
    final id = s.hit(d.localPosition);
    if (id == null) return;
    if (id == s.target) {
      _Audio.play(_Sound.click);
      s.animating = true;
      setState(() {});
      _run(id, _gen);
    } else {
      _lab.showToast(_t('err_incorrect'), isError: true);
    }
  }

  /// HTML `finishStep()`.
  void _finishStep() {
    if (!mounted) return;
    final n = _data.steps.length;
    setState(() {
      s.animating = false;
      s.step++;
      if (s.step > n) {
        _complete();
      } else {
        _focus();
      }
    });
  }

  /// Scenario finished: "Investigation Complete!", camera rises to
  /// (0, 20, 40), the "View Final Observations" button appears and, in
  /// scenario 1, the reaction summary opens one second later.
  void _complete() {
    s.complete = true;
    _lab.completedScenarios.add(s.scenario);
    final p0 = s.cam.pitch;
    _tw.add(1500, (v) => s.cam.pitch = p0 + (_pitch1 - p0) * v);
    if (s.scenario == 0) {
      final g = _gen;
      _lab.after(const Duration(milliseconds: 1000), () {
        if (_alive(g)) _openSummary();
      });
    }
  }

  void _openSummary() {
    _summaryOpen = true;
    _lab.showPopup(
      () => LabPopupContent(
        title: _t(s.scenario == 0 ? 'summary_1_title' : 'summary_2_title'),
        icon: Icons.auto_awesome,
        extra: s.scenario == 0 ? _summary1() : _summary2(),
        actions: [
          LabAction(
            label: _t('btn_view_obs'),
            icon: Icons.menu_book,
            onTap: () => _lab.hidePopup(sound: false),
          ),
        ],
      ),
      silent: true,
    );
    setState(() {});
  }

  /// HTML `openObservation()`: observations & analysis, sidebar re-opened.
  void _openObservation() {
    if (!mounted) return;
    _obsOpen = true;
    _lab.openSidebar();
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('obs_title'),
        icon: Icons.menu_book,
        extra: _observation(),
        actions: [
          if (_lab.completedScenarios.length >= 2)
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
      ),
      silent: true,
    );
    setState(() {});
  }

  // ------------------------------------------------------------ actions

  /// HTML `executeStepAction(action)`.
  void _run(String id, int g) {
    if (s.scenario == 0) {
      switch (s.step) {
        case 1:
          _pourSulfur(g, const _V3(-1.5, 4.5, 4), intoSpoon: true);
        case 2:
          _spoonToFlame(g);
        case 3:
          _spoonToJar(g);
        case 4:
          _closeLid1(g);
        case 5:
          _waterToJar(g);
        case 6:
          _closeLid2(g);
        case 7:
          _shakeJar(g);
        default:
          _litmusTestS1(g);
      }
    } else {
      switch (s.step) {
        case 1:
          _pourSulfur(g, const _V3(1.5, 6, 0), intoSpoon: false);
        case 2:
          _waterToTumbler(g);
        case 3:
          _litmusTestS2(g, blue: true);
        case 4:
          _litmusTestS2(g, blue: false);
        default:
          // showScenario2Summary
          _openSummary();
          _finishStep();
      }
    }
  }

  /// animateSulfurToSpoon / animateSulfurToTumbler: lid off, jar over the
  /// spoon (tumbler), tipped 120°, stream of sulfur, back home, lid on.
  Future<void> _pourSulfur(int g, _V3 to, {required bool intoSpoon}) async {
    final home = s.layout.sulfur;
    await _tween(300, (v) => s.lidLift = v);
    if (!_alive(g)) return;
    await _tween(800, (v) => s.jarPos = _V3.lerp(home, to, v),
        curve: intoSpoon ? Curves.easeOutQuad : Curves.linear);
    if (!_alive(g)) return;
    await _tween(400, (v) => s.jarRot = v * 2 * math.pi / 3);
    if (!_alive(g)) return;
    s.sulfurStream = true;
    _tween(500, (v) {
      s.jarPowder = 1 - 0.5 * v;
      if (intoSpoon) {
        s.spoonPowder = v;
      } else {
        s.tumblerPowder = v;
      }
    });
    await _wait(600);
    if (!_alive(g)) return;
    s.sulfurStream = false;
    _lab.showToast(_t(intoSpoon ? 'msg_added_spoon' : 'msg_added_tumbler'));
    _tween(400, (v) => s.jarRot = (1 - v) * 2 * math.pi / 3);
    await _tween(800, (v) => s.jarPos = _V3.lerp(to, home, v));
    if (!_alive(g)) return;
    _tween(300, (v) => s.lidLift = 1 - v);
    _finishStep();
  }

  /// animateSpoonToFlame: spoon into the lamp flame, sulfur ignites (blue).
  Future<void> _spoonToFlame(int g) async {
    final from = s.spoonPos;
    await _tween(800, (v) => s.spoonPos = _V3.lerp(from, const _V3(0, 2.8, -2), v),
        curve: Curves.easeInOutQuad);
    if (!_alive(g)) return;
    await _wait(500);
    if (!_alive(g)) return;
    _tween(150, (v) => s.spoonFlame = v);
    _Audio.play(_Sound.fire);
    _lab.showToast(_t('msg_ignites'), sound: false);
    _finishStep();
  }

  /// animateSpoonToJar: over the gas jar, then lowered inside.
  Future<void> _spoonToJar(int g) async {
    final from = s.spoonPos;
    await _tween(800, (v) => s.spoonPos = _V3.lerp(from, const _V3(7, 7.5, 0), v),
        curve: Curves.easeInOutQuad);
    if (!_alive(g)) return;
    await _tween(500, (v) => s.spoonPos = _V3(7, 7.5 - 4 * v, 0));
    if (!_alive(g)) return;
    _finishStep();
  }

  /// animateCloseLid1: lid slides on, flame dies, the jar fills with SO2.
  Future<void> _closeLid1(int g) async {
    await _tween(300, (v) => s.lidX = 2.5 * (1 - v));
    if (!_alive(g)) return;
    _Audio.play(_Sound.correct); // HTML playSuccess
    _tween(1000, (v) => s.spoonFlame = 1 - v);
    await _tween(1000, (v) => s.gas = 0.8 * v);
    if (!_alive(g)) return;
    _lab.showToast(_t('msg_gas_collected'), sound: false);
    _finishStep();
  }

  /// animateWaterToJar: spoon removed, lid off, beaker pours water in.
  Future<void> _waterToJar(int g) async {
    s.spoonVisible = false;
    await _tween(300, (v) => s.lidX = 2.8 * v);
    if (!_alive(g)) return;
    await _pourWater(g, const _V3(9.2, 4.5, 0), Curves.easeInOutQuad, (v) => s.solution = v);
    if (!_alive(g)) return;
    _finishStep();
  }

  /// Beaker tips 45° and pours for 600 ms, then (without waiting for its
  /// return trip) the caller continues.
  Future<void> _pourWater(int g, _V3 to, Curve curve, void Function(double v) fill) async {
    final home = s.layout.beaker;
    await _tween(800, (v) => s.beakerPos = _V3.lerp(home, to, v), curve: curve);
    if (!_alive(g)) return;
    await _tween(400, (v) => s.beakerRot = v * math.pi / 4);
    if (!_alive(g)) return;
    s.waterStream = true;
    _Audio.play(_Sound.splash);
    _tween(600, (v) => s.beakerWater = 1 - 0.7 * v);
    _tween(600, fill);
    await _wait(600);
    if (!_alive(g)) return;
    s.waterStream = false;
    _tween(400, (v) => s.beakerRot = (1 - v) * math.pi / 4);
    _tween(800, (v) => s.beakerPos = _V3.lerp(to, home, v));
  }

  /// animateCloseLid2.
  Future<void> _closeLid2(int g) async {
    await _tween(300, (v) => s.lidX = 2.8 * (1 - v));
    if (!_alive(g)) return;
    _Audio.play(_Sound.pop);
    _finishStep();
  }

  /// animateShakeJar: rocks 0.1 rad, yoyo x 8 (100 ms), gas dissolves.
  Future<void> _shakeJar(int g) async {
    await _tween(800, (v) {
      final legs = v * 8;
      final k = legs.floor().clamp(0, 7);
      final f = legs - k;
      s.gasJarRot = 0.1 * (k.isEven ? f : 1 - f);
    });
    if (!_alive(g)) return;
    s.gasJarRot = 0;
    _tween(500, (v) => s.gas = 0.8 * (1 - v));
    _lab.showToast(_t('msg_gas_dissolved'));
    _finishStep();
  }

  /// animateLitmusTestBlue: blue litmus dipped in the solution turns red.
  Future<void> _litmusTestS1(int g) async {
    final from = s.bluePos;
    await _tween(800, (v) => s.bluePos = _V3.lerp(from, const _V3(7, 7.5, 0), v));
    if (!_alive(g)) return;
    s.lidX = 2.8;
    await _tween(500, (v) => s.bluePos = _V3(7, 7.5 - 4 * v, 0));
    if (!_alive(g)) return;
    _Audio.play(_Sound.splash);
    s.blueTurnedRed = true;
    await _wait(1000);
    if (!_alive(g)) return;
    _tween(500, (v) => s.bluePos = _V3(7, 3.5 + 4.5 * v, 0));
    _lab.showToast(_t('msg_acidic_test'));
    _finishStep();
  }

  /// animateWaterToTumbler.
  Future<void> _waterToTumbler(int g) async {
    await _pourWater(g, const _V3(2.2, 4.5, 0), Curves.linear, (v) => s.tumblerWater = v);
    if (!_alive(g)) return;
    await _wait(800); // the beaker's way back
    if (!_alive(g)) return;
    _lab.showToast(_t('msg_no_rxn'));
    _finishStep();
  }

  /// animateLitmusTestBlueS2 / animateLitmusTestRedS2: no colour change.
  Future<void> _litmusTestS2(int g, {required bool blue}) async {
    final from = blue ? s.bluePos : s.redPos;
    final x = blue ? -0.3 : 0.3;
    void set(_V3 p) {
      if (blue) {
        s.bluePos = p;
      } else {
        s.redPos = p;
      }
    }
    await _tween(800, (v) => set(_V3.lerp(from, _V3(x, 5, 0), v)));
    if (!_alive(g)) return;
    await _tween(500, (v) => set(_V3(x, 5 - 2.5 * v, 0)));
    if (!_alive(g)) return;
    _Audio.play(_Sound.splash);
    await _wait(1000);
    if (!_alive(g)) return;
    if (blue) {
      await _tween(500, (v) => set(_V3(x, 2.5 + 3.5 * v, 0)));
      if (!_alive(g)) return;
      _lab.showToast(_t('msg_blue_blue'));
    } else {
      _tween(500, (v) => set(_V3(x, 2.5 + 3.5 * v, 0)));
      _lab.showToast(_t('msg_red_red'));
      s.tumblerInteractive = true;
    }
    _finishStep();
  }

  // ------------------------------------------------------------ effects

  /// Pale SO2 fumes rising from the burning sulfur (open air only).
  void _updatePuffs(double dt) {
    final r = s.rng;
    if (s.scenario == 0 && s.spoonVisible && s.spoonFlame > 0.3 && s.lidX > 0.5) {
      if (r.nextDouble() < dt * 9) {
        final p = s.spoonPos;
        _puffs.add(_Puff(_V3(p.x + (r.nextDouble() - 0.5) * 0.4, p.y + 1.4, p.z), (r.nextDouble() - 0.5) * 0.5,
            0.8 + r.nextDouble() * 0.5, 1.8 + r.nextDouble()));
      }
    }
    if (_puffs.isEmpty) return;
    for (final f in _puffs) {
      f.age += dt;
      f.pos = _V3(f.pos.x + f.drift * dt, f.pos.y + f.rise * dt, f.pos.z);
    }
    _puffs.removeWhere((f) => f.age >= f.life);
  }

  // ------------------------------------------------------------- UI

  List<LabAction> _actions() {
    // HTML #btn-validate: shown once complete, hidden while a popup is open.
    if (s.complete && !_summaryOpen && !_obsOpen && _lab.popup == null) {
      return [
        LabAction(
          label: _t('btn_view_obs'),
          icon: Icons.menu_book,
          highlight: true,
          onTap: _openObservation,
        ),
      ];
    }
    return const [];
  }

  Map<String, String> _labels() => {
        for (final k in const [
          'lbl_sulfur_powder', 'lbl_spoon', 'lbl_lamp', 'lbl_jar', 'lbl_beaker', 'lbl_litmus', //
          'lbl_tumbler',
        ])
          k: _t(k),
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final sc = context.labScale;
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.complete ? data.steps.length + 1 : s.step,
          instruction: s.complete ? _t('inv_complete') : null,
          actions: actions,
          onReset: _fullReset,
          overlays: [
            // HTML #btn-validate floats on the canvas.
            if (_lab.isSidebarOpen && actions.isNotEmpty)
              Positioned(
                top: inset.top + 46 * sc,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(action: actions.first, scale: sc * 1.1, expand: false),
                  ),
                ),
              ),
          ],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              onTapUp: _onTapUp,
              child: CustomPaint(
                size: _design,
                painter: _A3Painter(
                  scene: s,
                  puffs: _puffs,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  text: _labels(),
                  lang: _lab.lang,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================ STRINGS
// Text copied from `Cl7S-Ch4-A3-Chemical_Reactions_of_Non_metals_with_Air_and_Water.html`
// (I18N.en / I18N.hi). `**text**` marks bold text.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Chemical Reactions of Non-Metals with Air and Water',
    'app_subtitle': 'Class 7 • The World of Metals and Non-metals',
    'scen_1': 'Scenario 1: Fiery Breath of Sulfur',
    'scen_2': 'Scenario 2: The Placid Pool (Reaction with Water)',
    'btn_view_obs': 'View Final Observations',
    'summary_1_title': 'Chemical Reaction Summary',
    'summary_2_title': 'Analysis Summary',
    'lbl_sulfur': 'Sulfur',
    'lbl_oxygen': 'Oxygen',
    'lbl_heat': 'Heat',
    'lbl_so2': 'Sulfur Dioxide Gas',
    'lbl_so2_short': 'Sulfur Dioxide',
    'lbl_water': 'Water',
    'lbl_acid': 'Sulfurous Acid',
    'lbl_acidic_tag': 'ACIDIC',
    'lbl_water_sulfur': 'Neutral Water + Sulfur',
    'lbl_neutral_tag': 'NEUTRAL - NO REACTION',
    'summary_1_desc':
        'Non-metals (like Sulfur) burn in air to form acidic oxides. The acid turns blue litmus red.',
    'summary_2_desc':
        'Sulfur does not react with water directly at room temperature. The water remains neutral.',
    'obs_title': 'Observations & Analysis',
    'inv_complete': 'Investigation Complete!',
    'lbl_sulfur_powder': 'Powdered Sulfur',
    'lbl_spoon': 'Deflagrating Spoon',
    'lbl_lamp': 'Spirit Lamp',
    'lbl_jar': 'Gas Jar',
    'lbl_beaker': 'Beaker of Water',
    'lbl_litmus': 'Litmus Papers',
    'lbl_tumbler': 'Glass Tumbler',
    'err_incorrect': 'Incorrect Object! Follow the HUD instructions.',
    'msg_added_spoon': 'Sulfur added to spoon.',
    'msg_ignites': 'Sulfur ignites! Blue flame produced.',
    'msg_gas_collected': 'Sulfur Dioxide gas collected.',
    'msg_gas_dissolved': 'Gas dissolved to form Sulfurous Acid.',
    'msg_acidic_test': 'Blue Litmus turned Red! Solution is Acidic.',
    'msg_added_tumbler': 'Sulfur added.',
    'msg_no_rxn': 'Sulfur settles. No apparent reaction.',
    'msg_blue_blue': 'Blue Litmus stayed Blue.',
    'msg_red_red': 'Red Litmus stayed Red. Water is neutral.',
    // Observation popups (HTML s1_obs / s2_obs)
    'obs_done': 'Analysis Complete',
    'obs1_observation': '**Observation:** The blue litmus paper turned red when dipped in the solution.',
    'obs1_conclusion':
        '**Conclusion:** The solution formed by dissolving sulfur dioxide in water is acidic in nature.',
    'obs1_eq_caption': 'Sulfur Dioxide + Water → Sulfurous Acid',
    'obs1_rule':
        'General Rule: Non-metals react with oxygen to form non-metallic oxides, which are acidic in nature.',
    'obs1_fact':
        'Real-world impact: This identical reaction is responsible for Acid Rain when fossil fuels containing sulfur are burned.',
    'obs2_obs1':
        '**Observation 1:** When water was added to sulfur, the sulfur powder simply settled at the bottom. No gas evolved, no heat produced.',
    'obs2_obs2':
        '**Observation 2:** Both blue and red litmus papers remained unchanged, indicating the water remained neutral.',
    'obs2_conclusion': '**Conclusion:** Sulfur does not react with water at room temperature.',
    'obs2_rule': 'General Rule: Unlike many metals, non-metals generally do not react with water.',
    'obs2_fact':
        'Interesting Fact: Because non-metals like Phosphorus are highly reactive with air but not water, they are safely stored under water!',
  },
  'hi': {
    'app_title': 'वायु और जल के साथ अधातुओं की रासायनिक अभिक्रियाएं',
    'app_subtitle': 'कक्षा 7 • धातु और अधातु की दुनिया',
    'scen_1': 'परिदृश्य 1: सल्फर की ज्वलंत सांस',
    'scen_2': 'परिदृश्य 2: शांत कुंड (जल के साथ अभिक्रिया)',
    'btn_view_obs': 'अंतिम अवलोकन देखें',
    'summary_1_title': 'रासायनिक अभिक्रिया सारांश',
    'summary_2_title': 'विश्लेषण सारांश',
    'lbl_sulfur': 'सल्फर',
    'lbl_oxygen': 'ऑक्सीजन',
    'lbl_heat': 'ऊष्मा',
    'lbl_so2': 'सल्फर डाइऑक्साइड गैस',
    'lbl_so2_short': 'सल्फर डाइऑक्साइड',
    'lbl_water': 'जल',
    'lbl_acid': 'सल्फ्यूरस अम्ल',
    'lbl_acidic_tag': 'अम्लीय',
    'lbl_water_sulfur': 'उदासीन जल + सल्फर',
    'lbl_neutral_tag': 'उदासीन - कोई अभिक्रिया नहीं',
    'summary_1_desc':
        'अधातुएं (जैसे सल्फर) अम्लीय ऑक्साइड बनाने के लिए हवा में जलती हैं। अम्ल नीले लिटमस को लाल कर देता है।',
    'summary_2_desc': 'कमरे के तापमान पर सल्फर पानी के साथ सीधे प्रतिक्रिया नहीं करता है। पानी उदासीन रहता है।',
    'obs_title': 'अवलोकन एवं विश्लेषण',
    'inv_complete': 'जांच पूर्ण!',
    'lbl_sulfur_powder': 'पाउडर सल्फर',
    'lbl_spoon': 'दहन चम्मच',
    'lbl_lamp': 'स्पिरिट लैंप',
    'lbl_jar': 'गैस जार',
    'lbl_beaker': 'पानी का बीकर',
    'lbl_litmus': 'लिटमस पेपर',
    'lbl_tumbler': 'कांच का गिलास',
    'err_incorrect': 'गलत वस्तु! HUD निर्देशों का पालन करें।',
    'msg_added_spoon': 'सल्फर को चम्मच में जोड़ा गया।',
    'msg_ignites': 'सल्फर जल उठा! नीली लौ उत्पन्न हुई।',
    'msg_gas_collected': 'सल्फर डाइऑक्साइड गैस एकत्र हो गई।',
    'msg_gas_dissolved': 'सल्फ्यूरस अम्ल बनाने के लिए गैस घुल गई।',
    'msg_acidic_test': 'नीला लिटमस लाल हो गया! विलयन अम्लीय है।',
    'msg_added_tumbler': 'सल्फर डाला गया।',
    'msg_no_rxn': 'सल्फर बैठ जाता है। कोई स्पष्ट अभिक्रिया नहीं।',
    'msg_blue_blue': 'नीला लिटमस नीला ही रहा।',
    'msg_red_red': 'लाल लिटमस लाल ही रहा। पानी उदासीन है।',
    'obs_done': 'विश्लेषण पूर्ण',
    'obs1_observation': '**अवलोकन:** विलयन में डुबाने पर नीला लिटमस पेपर लाल हो गया।',
    'obs1_conclusion': '**निष्कर्ष:** पानी में सल्फर डाइऑक्साइड घोलकर बनाया गया विलयन प्रकृति में अम्लीय होता है।',
    'obs1_eq_caption': 'सल्फर डाइऑक्साइड + जल → सल्फ्यूरस अम्ल',
    'obs1_rule':
        'सामान्य नियम: अधातुएं ऑक्सीजन के साथ प्रतिक्रिया करके अधात्विक ऑक्साइड बनाती हैं, जो प्रकृति में अम्लीय होते हैं।',
    'obs1_fact':
        'वास्तविक दुनिया का प्रभाव: सल्फर युक्त जीवाश्म ईंधन के जलने पर यही प्रतिक्रिया अम्लीय वर्षा के लिए जिम्मेदार होती है।',
    'obs2_obs1':
        '**अवलोकन 1:** जब सल्फर में पानी मिलाया गया, तो सल्फर पाउडर बस तल पर बैठ गया। न कोई गैस निकली, न ऊष्मा उत्पन्न हुई।',
    'obs2_obs2': '**अवलोकन 2:** नीले और लाल दोनों लिटमस पेपर अपरिवर्तित रहे, यह दर्शाता है कि पानी उदासीन रहा।',
    'obs2_conclusion': '**निष्कर्ष:** कमरे के तापमान पर सल्फर पानी के साथ प्रतिक्रिया नहीं करता है।',
    'obs2_rule': 'सामान्य नियम: कई धातुओं के विपरीत, अधातुएं आमतौर पर पानी के साथ प्रतिक्रिया नहीं करती हैं।',
    'obs2_fact':
        'रोचक तथ्य: क्योंकि फास्फोरस जैसी अधातुएं हवा के साथ अत्यधिक प्रतिक्रियाशील होती हैं लेकिन पानी के साथ नहीं, इसलिए उन्हें पानी के नीचे सुरक्षित रूप से रखा जाता है!',
  },
};

// Steps: concept = step name, action = HUD instruction, observation = the
// teacher-board theory (kept as data only, the teacher board is removed).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To burn sulfur in the air, dissolve the resulting gas in water, and test the solution to prove it is acidic.',
      steps: [
        LabStep(
          concept: 'Add Sulfur',
          action: 'DRAG Powdered Sulfur to spoon. DROP to fill bowl.',
          observation:
              'We start with a small amount of solid sulfur, a non-metal element. A spoon is used to safely heat substances until they burn.',
        ),
        LabStep(
          concept: 'Ignite Sulfur',
          action: 'DRAG spoon with sulfur to flame. Heat and Ignite (Blue Flame).',
          observation:
              'When heated in the presence of air (oxygen), sulfur ignites. It burns with a characteristic blue flame, forming a colorless gas.',
        ),
        LabStep(
          concept: 'Move to Jar',
          action: 'Quickly DRAG burning spoon to jar.',
          observation: 'We collect the gas in a jar to prevent it from escaping.',
        ),
        LabStep(
          concept: 'Seal Jar',
          action: 'CLICK Lid to seal (Trap Gas).',
          observation:
              'The gas produced is Sulfur Dioxide. It is choking and suffocating if inhaled directly.',
        ),
        LabStep(
          concept: 'Add Water',
          action: 'POUR Beaker of Water to jar.',
          observation: 'Now we introduce water to the jar containing Sulfur Dioxide gas.',
        ),
        LabStep(
          concept: 'Seal Jar Again',
          action: 'CLICK Lid to seal jar again.',
          observation: 'We must seal it before shaking.',
        ),
        LabStep(
          concept: 'Shake Jar',
          action: 'SHAKE jar (Gas dissolves).',
          observation: 'When shaken, the gas dissolves readily in the water, forming a new solution.',
        ),
        LabStep(
          concept: 'Test Solution',
          action: 'DRAG Blue Litmus Paper. DROP tip into solution (Red color change).',
          observation: 'We use Blue Litmus paper, an acid-base indicator, to test the solution.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          "To investigate if sulfur reacts directly with water at room temperature by mixing them and testing the water's properties.",
      steps: [
        LabStep(
          concept: 'Add Sulfur to Tumbler',
          action: 'DRAG Powdered Sulfur container. DROP into empty Tumbler.',
          observation:
              "Let's test if sulfur reacts with water without any heat applied, unlike highly reactive metals.",
        ),
        LabStep(
          concept: 'Add Water',
          action: 'DRAG Beaker of Water. POUR into Tumbler containing sulfur.',
          observation: 'Water is added directly to the elemental sulfur.',
        ),
        LabStep(
          concept: 'Test with Blue Litmus',
          action: 'DRAG Blue Litmus Paper. DROP tip into water. Color stays Blue.',
          observation: "Let's confirm the nature of the water using Blue Litmus.",
        ),
        LabStep(
          concept: 'Test with Red Litmus',
          action: 'DRAG Red Litmus Paper. DROP tip into water. Color stays Red.',
          observation: 'Testing with red litmus paper to be absolutely sure.',
        ),
        LabStep(
          concept: 'Observe Results',
          action: 'Observe the tumbler. CLICK to see final results.',
          observation:
              'We observe that sulfur powder remains unchanged at the bottom. Litmus tests confirmed the water remains neutral.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'सल्फर को हवा में जलाने, परिणामी गैस को पानी में घोलने और यह साबित करने के लिए कि यह अम्लीय है, विलयन का परीक्षण करने के लिए।',
      steps: [
        LabStep(
          concept: 'सल्फर जोड़ें',
          action: 'पाउडर सल्फर को चम्मच तक खींचें। कटोरे को भरने के लिए छोड़ दें।',
          observation:
              'हम थोड़ी मात्रा में ठोस सल्फर (एक अधातु तत्व) से शुरू करते हैं। चम्मच का उपयोग पदार्थों को सुरक्षित रूप से तब तक गर्म करने के लिए किया जाता है जब तक कि वे जल न जाएं।',
        ),
        LabStep(
          concept: 'सल्फर को प्रज्वलित करें',
          action: 'सल्फर वाले चम्मच को लौ तक खींचें। गर्म करें और प्रज्वलित करें (नीली लौ)।',
          observation:
              'हवा (ऑक्सीजन) की उपस्थिति में गर्म करने पर सल्फर प्रज्वलित होता है। यह एक विशिष्ट नीली लौ के साथ जलता है, जिससे रंगहीन गैस बनती है।',
        ),
        LabStep(
          concept: 'जार में ले जाएं',
          action: 'जलते हुए चम्मच को जार तक तेजी से खींचें।',
          observation: 'हम गैस को जार में इकट्ठा करते हैं ताकि वह निकल न जाए।',
        ),
        LabStep(
          concept: 'जार सील करें',
          action: 'जार को सील करने के लिए ढक्कन पर क्लिक करें (गैस को फंसाएं)।',
          observation: 'उत्पन्न गैस सल्फर डाइऑक्साइड है। यदि इसे सीधे सूंघा जाए तो यह दम घोंटने वाली होती है।',
        ),
        LabStep(
          concept: 'पानी डालें',
          action: 'पानी के बीकर को जार में डालें।',
          observation: 'अब हम सल्फर डाइऑक्साइड गैस वाले जार में पानी डालते हैं।',
        ),
        LabStep(
          concept: 'जार को फिर से सील करें',
          action: 'जार को फिर से सील करने के लिए ढक्कन पर क्लिक करें।',
          observation: 'हिलाने से पहले हमें इसे सील करना होगा।',
        ),
        LabStep(
          concept: 'जार हिलाएं',
          action: 'जार को हिलाएं (गैस घुल जाती है)।',
          observation: 'हिलाने पर, गैस पानी में आसानी से घुल जाती है, जिससे एक नया विलयन बनता है।',
        ),
        LabStep(
          concept: 'विलयन का परीक्षण करें',
          action: 'नीले लिटमस पेपर को खींचें। इसके सिरे को विलयन में छोड़ दें (लाल रंग परिवर्तन)।',
          observation: 'हम विलयन का परीक्षण करने के लिए नीले लिटमस पेपर (एक अम्ल-क्षार सूचक) का उपयोग करते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह जांचने के लिए कि क्या सल्फर कमरे के तापमान पर सीधे पानी के साथ प्रतिक्रिया करता है, उन्हें मिलाकर और पानी के गुणों का परीक्षण करके।',
      steps: [
        LabStep(
          concept: 'गिलास में सल्फर डालें',
          action: 'पाउडर सल्फर कंटेनर खींचें। इसे खाली गिलास में छोड़ दें।',
          observation:
              'आइए जांचें कि क्या अत्यधिक प्रतिक्रियाशील धातुओं के विपरीत, बिना किसी ऊष्मा के सल्फर पानी के साथ प्रतिक्रिया करता है।',
        ),
        LabStep(
          concept: 'पानी डालें',
          action: 'पानी का बीकर खींचें। सल्फर वाले गिलास में डालें।',
          observation: 'मौलिक सल्फर में पानी सीधे मिलाया जाता है।',
        ),
        LabStep(
          concept: 'नीले लिटमस के साथ परीक्षण',
          action: 'नीले लिटमस पेपर को खींचें। पानी में टिप छोड़ दें। रंग नीला रहता है।',
          observation: 'आइए नीले लिटमस का उपयोग करके पानी की प्रकृति की पुष्टि करें।',
        ),
        LabStep(
          concept: 'लाल लिटमस के साथ परीक्षण',
          action: 'लाल लिटमस पेपर खींचें। पानी में टिप छोड़ दें। रंग लाल रहता है।',
          observation: 'पूरी तरह सुनिश्चित होने के लिए लाल लिटमस पेपर के साथ परीक्षण।',
        ),
        LabStep(
          concept: 'परिणाम देखें',
          action: 'गिलास का निरीक्षण करें। अंतिम परिणाम देखने के लिए क्लिक करें।',
          observation:
              'हम देखते हैं कि सल्फर पाउडर तल पर अपरिवर्तित रहता है। लिटमस परीक्षणों ने पुष्टि की कि पानी उदासीन रहता है।',
        ),
      ],
    ),
  ],
};

// ============================================================ CAMERA
// The HTML uses a PerspectiveCamera (fov 30°) at (0, 16, 42) whose
// OrbitControls target follows the object of the current step, and moves
// to (0, 20, 40) when the investigation is complete. [_Cam] reproduces
// that view: world units (Three.js) -> 1000 x 560 design pixels.

const Size _design = Size(1000, 560);
const double _pitch0 = 0.3640; // atan2(16, 42)
const double _pitch1 = 0.4636; // atan2(20, 40)

class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  static _V3 lerp(_V3 a, _V3 b, double t) =>
      _V3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);

  _V3 withY(double ny) => _V3(x, ny, z);
}

class _Cam {
  static const double dist = 44.9;
  static const Offset center = Offset(500, 300);

  double camX = 0;
  double pitch = _pitch0;
  double focal = 1150;

  /// Screen point and pixels-per-unit at a world point.
  ({Offset p, double k}) proj(double x, double y, double z) {
    final s = math.sin(pitch), c = math.cos(pitch);
    final vx = x - camX, vy = y - dist * s, vz = z - dist * c;
    final depth = math.max(1.0, -vy * s - vz * c);
    final up = vy * c - vz * s;
    final k = focal / depth;
    return (p: Offset(center.dx + vx * k, center.dy - up * k), k: k);
  }

  Offset p(_V3 v) => proj(v.x, v.y, v.z).p;
  double k(_V3 v) => proj(v.x, v.y, v.z).k;

  /// Ellipse ratio of a horizontal circle at height [y], depth [z].
  double tilt(double y, double z) {
    final dy = dist * math.sin(pitch) - y;
    final dz = dist * math.cos(pitch) - z;
    return math.sin(math.atan2(dy, dz)).clamp(0.06, 0.9).toDouble();
  }
}

// ============================================================ TWEENS

class _Tween {
  _Tween(this.start, this.duration, this.curve, this.update, this.done);
  final double start;
  final double duration;
  final Curve curve;
  final void Function(double v) update;
  final VoidCallback? done;
}

class _Tweens {
  final List<_Tween> _list = [];
  double now = 0;

  void add(int ms, void Function(double v) update, {Curve curve = Curves.linear, VoidCallback? done}) {
    _list.add(_Tween(now, ms / 1000, curve, update, done));
  }

  void tick(double t) {
    now = t;
    if (_list.isEmpty) return;
    for (final tw in List<_Tween>.of(_list)) {
      if (!_list.contains(tw)) continue;
      final p = tw.duration <= 0 ? 1.0 : ((t - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.update(tw.curve.transform(p));
      if (p >= 1) {
        _list.remove(tw);
        tw.done?.call();
      }
    }
  }

  void clear() => _list.clear();
}

// ============================================================ SCENE

/// Object ids (the HTML `userData.name` values used as step targets).
const String _idSulfur = 'sulfurPowder';
const String _idSpoon = 'deflagratingSpoon';
const String _idJar = 'gasJar';
const String _idBeaker = 'beaker';
const String _idBlue = 'blueLitmus';
const String _idRed = 'redLitmus';
const String _idTumbler = 'tumbler';

const List<List<String>> _stepTargets = [
  [_idSulfur, _idSpoon, _idSpoon, _idJar, _idBeaker, _idJar, _idJar, _idBlue],
  [_idSulfur, _idBeaker, _idBlue, _idRed, _idTumbler],
];

/// World positions of the fixed props and the floating labels.
class _Layout {
  const _Layout({
    required this.sulfur,
    required this.beaker,
    required this.litmusJar,
    required this.blue,
    required this.red,
    required this.labels,
    required this.baseX,
    required this.focal,
  });

  final _V3 sulfur;
  final _V3 beaker;
  final _V3 litmusJar;
  final _V3 blue;
  final _V3? red;
  final Map<String, _V3> labels;
  final double baseX;
  final double focal;
}

const List<_Layout> _layouts = [
  _Layout(
    sulfur: _V3(-11, 0, 0),
    beaker: _V3(14, 0, 0),
    litmusJar: _V3(3, 0, 6),
    blue: _V3(2.8, 1.8, 6.1),
    red: null,
    baseX: 1.5,
    focal: 1150,
    labels: {
      'lbl_sulfur_powder': _V3(-11, 4.2, 0),
      'lbl_spoon': _V3(-1, 3.5, 4),
      'lbl_lamp': _V3(0, 4.5, -2),
      'lbl_jar': _V3(7, 8, 0),
      'lbl_beaker': _V3(14, 4.5, 0),
      'lbl_litmus': _V3(3, 4.5, 6),
    },
  ),
  _Layout(
    sulfur: _V3(-8, 0, 0),
    beaker: _V3(8, 0, 0),
    litmusJar: _V3(-4, 0, 6),
    blue: _V3(-4.4, 1.8, 6.1),
    red: _V3(-3.6, 1.8, 6.1),
    baseX: 0,
    focal: 1350,
    labels: {
      'lbl_sulfur_powder': _V3(-8, 4.5, 0),
      'lbl_tumbler': _V3(0, 5.5, 0),
      'lbl_beaker': _V3(8, 4.5, 0),
      'lbl_litmus': _V3(-4, 4.5, 6),
    },
  ),
];

const _V3 _spoonHome = _V3(-3, 0.5, 4);
const _V3 _lampPos = _V3(0, 0, -2);
const _V3 _gasJarPos = _V3(7, 0, 0);
const _V3 _tumblerPos = _V3(0, 0, 0);

class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  bool animating = false;
  bool complete = false;
  final _Cam cam = _Cam();
  final math.Random rng = math.Random();

  _Layout get layout => _layouts[scenario];

  // Sulfur powder jar (both scenarios).
  _V3 jarPos = const _V3(-11, 0, 0);
  double jarRot = 0; // Three.js rotation.z (counter-clockwise)
  double lidLift = 0; // 0 closed -> 1 lifted aside
  double jarPowder = 1;
  bool sulfurStream = false;

  // Scenario 1: spoon, gas jar.
  _V3 spoonPos = _spoonHome;
  bool spoonVisible = true;
  double spoonPowder = 0;
  double spoonFlame = 0;
  double lidX = 2.5;
  double gas = 0; // SO2 fog opacity
  double solution = 0;
  double gasJarRot = 0;

  // Beaker (both scenarios).
  _V3 beakerPos = const _V3(14, 0, 0);
  double beakerRot = 0;
  double beakerWater = 1;
  bool waterStream = false;

  // Scenario 2: tumbler.
  double tumblerPowder = 0;
  double tumblerWater = 0;
  bool tumblerInteractive = false;

  // Active litmus strips.
  _V3 bluePos = const _V3(2.8, 1.8, 6.1);
  _V3 redPos = const _V3(-3.6, 1.8, 6.1);
  bool blueTurnedRed = false;

  String? get target {
    if (complete) return null;
    final list = _stepTargets[scenario];
    return step <= list.length ? list[step - 1] : null;
  }

  /// Current world position of an interactive object (camera focus).
  _V3 posOf(String id) => switch (id) {
        _idSulfur => jarPos,
        _idSpoon => spoonPos,
        _idJar => _gasJarPos,
        _idBeaker => beakerPos,
        _idBlue => bluePos,
        _idRed => redPos,
        _ => _tumblerPos,
      };

  void reset(int s) {
    scenario = s;
    step = 1;
    animating = false;
    complete = false;
    final l = layout;
    jarPos = l.sulfur;
    jarRot = 0;
    lidLift = 0;
    jarPowder = 1;
    sulfurStream = false;
    spoonPos = _spoonHome;
    spoonVisible = true;
    spoonPowder = 0;
    spoonFlame = 0;
    lidX = 2.5;
    gas = 0;
    solution = 0;
    gasJarRot = 0;
    beakerPos = l.beaker;
    beakerRot = 0;
    beakerWater = 1;
    waterStream = false;
    tumblerPowder = 0;
    tumblerWater = 0;
    tumblerInteractive = false;
    bluePos = l.blue;
    redPos = l.red ?? const _V3(-3.6, 1.8, 6.1);
    blueTurnedRed = false;
    cam
      ..focal = l.focal
      ..pitch = _pitch0
      ..camX = l.baseX;
  }
}

/// A wisp of sulfur dioxide smoke (world units).
class _Puff {
  _Puff(this.pos, this.drift, this.rise, this.life);
  _V3 pos;
  final double drift;
  final double rise;
  final double life;
  double age = 0;
}

/// Screen-space hit areas of the interactive objects (same geometry as
/// the painter), front-most first.
extension _SceneHit on _Scene {
  Rect _cylRect(_V3 base, double r, double h) {
    final b = cam.proj(base.x, base.y, base.z);
    final top = cam.p(base.withY(base.y + h));
    return Rect.fromLTRB(b.p.dx - r * b.k, top.dy, b.p.dx + r * b.k, b.p.dy + r * b.k * 0.45).inflate(6);
  }

  Rect? rectOf(String id) {
    switch (id) {
      case _idSulfur:
        return _cylRect(jarPos, 1.3, 3.0);
      case _idSpoon:
        if (!spoonVisible) return null;
        final a = cam.p(_V3(spoonPos.x - 0.7, spoonPos.y - 0.3, spoonPos.z));
        final b = cam.p(_V3(spoonPos.x + 6, spoonPos.y + 0.4, spoonPos.z));
        return Rect.fromPoints(a, b).inflate(12);
      case _idJar:
        return _cylRect(_gasJarPos, 1.8, 6.4);
      case _idBeaker:
        return _cylRect(beakerPos, 1.6, 3.7);
      case _idTumbler:
        return _cylRect(_tumblerPos, 2, 4.5);
      case _idBlue:
      case _idRed:
        final p = id == _idBlue ? bluePos : redPos;
        final a = cam.p(_V3(p.x - 0.3, p.y - 1.75, p.z));
        final b = cam.p(_V3(p.x + 0.3, p.y + 1.75, p.z));
        final r = Rect.fromPoints(a, b);
        return Rect.fromCenter(center: r.center, width: math.max(r.width, 34), height: r.height + 10);
    }
    return null;
  }

  /// Interactive objects of the scenario (HTML userData.interactive).
  List<String> get interactive => scenario == 0
      ? [_idBlue, _idSpoon, _idSulfur, _idJar, _idBeaker]
      : [_idRed, _idBlue, _idSulfur, _idBeaker, if (tumblerInteractive) _idTumbler];

  /// Depth of the surface facing the camera (larger = nearer), so that a
  /// container wins over what is inside it, like the HTML raycast.
  double frontZ(String id) => switch (id) {
        _idSulfur => jarPos.z + 1.3,
        _idSpoon => spoonPos.z + 0.6,
        _idJar => _gasJarPos.z + 1.8,
        _idBeaker => beakerPos.z + 1.6,
        _idTumbler => _tumblerPos.z + 2.0,
        _idBlue => bluePos.z + 0.2,
        _ => redPos.z + 0.2,
      };

  String? hit(Offset p) {
    String? best;
    var bestZ = double.negativeInfinity;
    for (final id in interactive) {
      final r = rectOf(id);
      if (r == null || !r.contains(p)) continue;
      final z = frontZ(id);
      if (z > bestZ) {
        bestZ = z;
        best = id;
      }
    }
    return best;
  }
}

// ============================================================ PAINTING
// Flat "toon" illustration of the Three.js bench (MeshToonMaterial with
// dark 0x334155 edge outlines), projected through [_Cam].

class _A3Painter extends CustomPainter {
  _A3Painter({
    required this.scene,
    required this.puffs,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
    required this.lang,
  }) : super(repaint: repaint);

  final _Scene scene;
  final List<_Puff> puffs;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> text;
  final LabLang lang;

  static const Color _outline = Color(0xFF334155);
  static const Color _glass = Color(0xFFBAE6FD);
  static const Color _sulfur = Color(0xFFFFB300);
  static const Color _metal = Color(0xFFB0BEC5);
  static const Color _water = Color(0xFF1E3A8A);
  static const Color _wood = Color(0xFF8B4513);

  _Cam get cam => scene.cam;
  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    // Scene background (HTML scene.background 0x0f172a / 0xe2e8f0).
    canvas.drawRect(labBleed(size), Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0));
    _table(canvas, size);
    if (scene.scenario == 0) {
      _paintS1(canvas);
    } else {
      _paintS2(canvas);
    }
    _paintPuffs(canvas);
    _hint(canvas);
    _labels(canvas);
  }

  @override
  bool shouldRepaint(covariant _A3Painter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.text != text;

  // ------------------------------------------------------------ bench

  /// Table: BoxGeometry(60, 2, 30) at y = -1, wood 0x8b4513 with outlines.
  void _table(Canvas canvas, Size size) {
    Offset p(double x, double y, double z) => cam.proj(x, y, z).p;
    final top = Path()
      ..moveTo(p(-30, 0, -15).dx, p(-30, 0, -15).dy)
      ..lineTo(p(30, 0, -15).dx, p(30, 0, -15).dy)
      ..lineTo(p(30, 0, 15).dx, p(30, 0, 15).dy)
      ..lineTo(p(-30, 0, 15).dx, p(-30, 0, 15).dy)
      ..close();
    final front = Path()
      ..moveTo(p(-30, 0, 15).dx, p(-30, 0, 15).dy)
      ..lineTo(p(30, 0, 15).dx, p(30, 0, 15).dy)
      ..lineTo(p(30, -2, 15).dx, p(30, -2, 15).dy)
      ..lineTo(p(-30, -2, 15).dx, p(-30, -2, 15).dy)
      ..close();
    final back = p(0, 0, -15).dy, near = p(0, 0, 15).dy;
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_wood, 0.12), labShade(_wood, 0.22)],
        ).createShader(Rect.fromLTRB(0, back, 10, near)),
    );
    // Faint planks receding to the back edge.
    final plank = Paint()
      ..color = Colors.black.withValues(alpha: 0.09)
      ..strokeWidth = 1;
    for (var x = -28.0; x <= 28; x += 4) {
      canvas.drawLine(p(x, 0, -15), p(x, 0, 15), plank);
    }
    canvas.drawPath(front, Paint()..color = labShade(_wood, -0.12));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _outline;
    canvas.drawPath(top, edge);
    canvas.drawPath(front, edge);
  }

  // ---------------------------------------------------------- helpers

  /// Runs [body] in a local frame at world point [o] (x right, y up,
  /// 1 unit = u px), rotated by the Three.js rotation.z [rot].
  void _local(Canvas canvas, _V3 o, double rot, void Function(double u, double tl) body, {double midY = 1.5}) {
    final pr = cam.proj(o.x, o.y, o.z);
    canvas.save();
    canvas.translate(pr.p.dx, pr.p.dy);
    if (rot != 0) canvas.rotate(-rot);
    body(pr.k, cam.tilt(o.y + midY, o.z));
    canvas.restore();
  }

  Path _cylPath(double u, double tl, double cx, double y0, double h, double r, double rt) {
    final x = cx * u, yb = -y0 * u, yt = -(y0 + h) * u;
    final wb = r * u, wt = rt * u;
    return Path()
      ..moveTo(x - wt, yt)
      ..lineTo(x - wb, yb)
      ..arcTo(Rect.fromCenter(center: Offset(x, yb), width: 2 * wb, height: 2 * wb * tl), math.pi, -math.pi, false)
      ..lineTo(x + wt, yt)
      ..close();
  }

  Rect _ell(double u, double tl, double cx, double y, double r) =>
      Rect.fromCenter(center: Offset(cx * u, -y * u), width: 2 * r * u, height: 2 * r * u * tl);

  /// Opaque toon cylinder / cone frustum: two-tone shading + outline.
  void _toon(Canvas canvas, double u, double tl,
      {double cx = 0,
      required double y0,
      required double h,
      required double r,
      double? rTop,
      required Color color,
      double alpha = 1,
      bool outline = true}) {
    if (h <= 0.001 || alpha <= 0) return;
    final rt = rTop ?? r;
    final body = _cylPath(u, tl, cx, y0, h, r, rt);
    Color a(Color c) => c.withValues(alpha: c.a * alpha);
    canvas.drawPath(body, Paint()..color = a(labShade(color, 0.06)));
    canvas.save();
    canvas.clipPath(body);
    final w = math.max(r, rt) * u;
    canvas.drawRect(
      Rect.fromLTRB(cx * u - w - 2, -(y0 + h) * u - 4, cx * u - w * 0.38, -y0 * u + w),
      Paint()..color = a(labShade(color, -0.2)),
    );
    canvas.restore();
    final topE = _ell(u, tl, cx, y0 + h, rt);
    canvas.drawOval(topE, Paint()..color = a(labShade(color, 0.22)));
    if (outline) {
      final o = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = a(_outline);
      canvas.drawPath(body, o);
      canvas.drawOval(topE, o);
    }
  }

  /// Translucent glass (MeshLambert 0xbae6fd, opacity 0.35) with the
  /// faceted edge lines of a 16-segment cylinder.
  void _glassBack(Canvas canvas, double u, double tl, {double cx = 0, required double y0, required double h, required double r, double? rTop}) {
    final body = _cylPath(u, tl, cx, y0, h, r, rTop ?? r);
    canvas.drawPath(body, Paint()..color = _glass.withValues(alpha: isDark ? 0.16 : 0.3));
    canvas.drawOval(_ell(u, tl, cx, y0 + h, rTop ?? r), Paint()..color = _glass.withValues(alpha: 0.12));
  }

  void _glassFront(Canvas canvas, double u, double tl,
      {double cx = 0, required double y0, required double h, required double r, double? rTop, bool topRim = true}) {
    final rt = rTop ?? r;
    final body = _cylPath(u, tl, cx, y0, h, r, rt);
    canvas.drawPath(body, Paint()..color = _glass.withValues(alpha: 0.1));
    final facet = Paint()
      ..strokeWidth = 1
      ..color = _outline.withValues(alpha: 0.45);
    for (var i = 1; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 8;
      final sx = math.cos(a), sy = math.sin(a);
      canvas.drawLine(
        Offset((cx + sx * r) * u, -y0 * u + sy * r * u * tl),
        Offset((cx + sx * rt) * u, -(y0 + h) * u + sy * rt * u * tl),
        facet,
      );
    }
    final o = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _outline.withValues(alpha: 0.85);
    canvas.drawPath(body, o);
    if (topRim) canvas.drawOval(_ell(u, tl, cx, y0 + h, rt), o);
    canvas.drawLine(
      Offset((cx - r * 0.7) * u, -(y0 + h * 0.12) * u),
      Offset((cx - rt * 0.7) * u, -(y0 + h * 0.88) * u),
      Paint()
        ..strokeWidth = math.max(2, 0.12 * u)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  /// HTML sprite labels: white rounded box, slate-400 border, dark text.
  void _labels(Canvas canvas) {
    if (!showLabels) return;
    scene.layout.labels.forEach((key, pos) {
      labText(
        canvas,
        text[key] ?? key,
        cam.p(pos),
        size: 12.5,
        weight: FontWeight.w800,
        color: const Color(0xFF0F172A),
        background: const Color(0xF2FFFFFF),
        border: const Color(0xFF94A3B8),
        borderWidth: 1.5,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    });
  }

  /// Pulsing outline on the object the current step asks for.
  void _hint(Canvas canvas) {
    final id = scene.target;
    if (id == null || scene.animating) return;
    final r = scene.rectOf(id);
    if (r == null) return;
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    final rr = RRect.fromRectAndRadius(r.inflate(4 + 3 * pulse), const Radius.circular(14));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.zslYellow.withValues(alpha: 0.25 + 0.45 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _paintPuffs(Canvas canvas) {
    for (final f in puffs) {
      final k = 1 - f.age / f.life;
      final pr = cam.proj(f.pos.x, f.pos.y, f.pos.z);
      final r = (0.25 + f.age * 0.45) * pr.k;
      canvas.drawCircle(
        pr.p,
        r,
        Paint()
          ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.35 * k)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
  }
}

// ============================================================ OBJECTS

extension _A3Objects on _A3Painter {
  /// Liquid / powder column inside glass (no outline, lit top surface).
  void _liquid(Canvas canvas, double u, double tl,
      {double cx = 0, required double y0, required double h, required double r, required Color color, double alpha = 0.9}) {
    if (h <= 0.001) return;
    final body = _cylPath(u, tl, cx, y0, h, r, r);
    canvas.drawPath(body, Paint()..color = color.withValues(alpha: alpha));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTRB(cx * u - r * u - 2, -(y0 + h) * u - r * u, cx * u - r * u * 0.4, -y0 * u + r * u),
      Paint()..color = labShade(color, -0.25).withValues(alpha: alpha * 0.6),
    );
    canvas.restore();
    canvas.drawOval(_ell(u, tl, cx, y0 + h, r), Paint()..color = labShade(color, 0.28).withValues(alpha: alpha));
  }

  /// Cone-shaped flame (ConeGeometry, additive) with a soft glow.
  void _flameCone(Canvas canvas, Offset base, double w, double h, Color color, {double alpha = 0.9, double seed = 0}) {
    if (h <= 0.5) return;
    final flick = 1 + 0.06 * math.sin(t * 19 + seed) + 0.04 * math.sin(t * 31 + seed * 2);
    final hh = h * flick;
    final path = Path()
      ..moveTo(base.dx, base.dy - hh)
      ..cubicTo(base.dx + w * 0.55, base.dy - hh * 0.55, base.dx + w * 0.62, base.dy - hh * 0.08, base.dx, base.dy)
      ..cubicTo(base.dx - w * 0.62, base.dy - hh * 0.08, base.dx - w * 0.55, base.dy - hh * 0.55, base.dx, base.dy - hh)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
  }

  /// Powdered sulfur jar: glass body + neck + rim, yellow powder, yellow lid.
  void _sulfurJar(Canvas canvas) {
    final s = scene;
    _local(canvas, s.jarPos, s.jarRot, (u, tl) {
      if (s.jarRot == 0) labGroundShadow(canvas, Offset(0, 2), 2.9 * u, 0.9 * u * tl + 4, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 2.2, r: 1.3);
      _toon(canvas, u, tl, y0: 0.05, h: 1.5 * s.jarPowder, r: 1.22, color: _A3Painter._sulfur, outline: false);
      _glassFront(canvas, u, tl, y0: 0, h: 2.2, r: 1.3, topRim: false);
      _glassFront(canvas, u, tl, y0: 2.2, h: 0.4, r: 1.3, rTop: 1.1, topRim: false);
      _glassFront(canvas, u, tl, y0: 2.6, h: 0.2, r: 1.155);
      _toon(canvas, u, tl, cx: 2 * s.lidLift, y0: 2.6 + 1.7 * s.lidLift, h: 0.4, r: 1.2, color: _A3Painter._sulfur);
    });
  }

  /// Deflagrating spoon: long handle to the right, shallow bowl, powder
  /// and the blue sulfur flame (outer 0x3b82f6, inner 0xf59e0b).
  void _spoon(Canvas canvas) {
    final s = scene;
    _local(canvas, s.spoonPos, 0, (u, tl) {
      if (s.spoonPos.y < 1) labGroundShadow(canvas, Offset(3 * u, 0.5 * u), 6.4 * u, 0.5 * u + 4, opacity: 0.25);
      final hw = math.max(2.5, 0.1 * u);
      canvas.drawLine(Offset(0.5 * u, 0), Offset(6 * u, 0),
          Paint()
            ..strokeWidth = hw + 2
            ..strokeCap = StrokeCap.round
            ..color = _A3Painter._outline);
      canvas.drawLine(Offset(0.5 * u, 0), Offset(6 * u, 0),
          Paint()
            ..strokeWidth = hw
            ..strokeCap = StrokeCap.round
            ..color = labShade(_A3Painter._metal, 0.2));
      final rim = Rect.fromCenter(center: Offset.zero, width: 1.2 * u, height: 1.2 * u * tl);
      final bowl = Path()
        ..moveTo(rim.left, 0)
        ..quadraticBezierTo(0, 0.55 * u, rim.right, 0)
        ..close();
      canvas.drawPath(bowl, Paint()..color = _A3Painter._metal);
      canvas.drawOval(rim, Paint()..color = labShade(_A3Painter._metal, -0.25));
      if (s.spoonPowder > 0) {
        final pr = rim.deflate(0.08 * u);
        canvas.drawOval(
          Rect.fromCenter(center: pr.center - Offset(0, 0.05 * u * s.spoonPowder), width: pr.width * (0.6 + 0.4 * s.spoonPowder), height: pr.height),
          Paint()..color = _A3Painter._sulfur.withValues(alpha: s.spoonPowder.clamp(0.0, 1.0)),
        );
      }
      final o = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _A3Painter._outline;
      canvas.drawPath(bowl, o);
      canvas.drawOval(rim, o);
      final f = s.spoonFlame;
      if (f > 0.01) {
        labGlow(canvas, Offset(0, -0.8 * u * f), 1.4 * u * f, const Color(0xFF3B82F6), intensity: 0.7 * f);
        _flameCone(canvas, Offset(0, -0.1 * u * f), 1.0 * u * f, 1.5 * u * f, const Color(0xFF3B82F6), seed: 1);
        _flameCone(canvas, Offset(0, -0.25 * u * f), 0.5 * u * f, 0.8 * u * f, const Color(0xFFF59E0B), seed: 2);
      }
    });
  }

  /// Spirit lamp body (glass base, liquid, metal cap, wick).
  void _lampBody(Canvas canvas) {
    _local(canvas, _lampPos, 0, (u, tl) {
      labGroundShadow(canvas, Offset(0, 2), 4.3 * u, 1.4 * u * tl + 4, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 1.2, r: 2, rTop: 1.8);
      _liquid(canvas, u, tl, y0: 0.05, h: 0.8, r: 1.7, color: Colors.white, alpha: 0.55);
      _glassFront(canvas, u, tl, y0: 0, h: 1.2, r: 2, rTop: 1.8);
      _toon(canvas, u, tl, y0: 1.2, h: 0.4, r: 0.4, color: _A3Painter._metal);
      canvas.drawRect(Rect.fromLTRB(-0.08 * u, -1.75 * u, 0.08 * u, -1.6 * u), Paint()..color = Colors.white);
    });
  }

  /// Lamp flame: amber outer cone (0xf59e0b) with a white core.
  void _lampFlame(Canvas canvas) {
    _local(canvas, _lampPos, 0, (u, tl) {
      labGlow(canvas, Offset(0, -2.4 * u), 2.6 * u, const Color(0xFFF59E0B), intensity: 0.45);
      _flameCone(canvas, Offset(0, -1.6 * u), 1.0 * u, 1.8 * u, const Color(0xFFF59E0B), seed: 3);
      _flameCone(canvas, Offset(0, -1.7 * u), 0.5 * u, 1.0 * u, Colors.white, alpha: 0.95, seed: 4);
    });
  }

  /// Beaker of water with its spout.
  void _beaker(Canvas canvas) {
    final s = scene;
    _local(canvas, s.beakerPos, s.beakerRot, (u, tl) {
      if (s.beakerPos.y < 0.5) labGroundShadow(canvas, Offset(0, 2), 3.6 * u, 1.1 * u * tl + 4, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 3.5, r: 1.6);
      _liquid(canvas, u, tl, y0: 0.1, h: 2.5 * s.beakerWater, r: 1.5, color: _A3Painter._water);
      _glassFront(canvas, u, tl, y0: 0, h: 3.5, r: 1.6);
      final spout = Path()
        ..moveTo(-1.45 * u, -3.25 * u)
        ..lineTo(-2.05 * u, -3.7 * u)
        ..lineTo(-1.3 * u, -3.55 * u)
        ..close();
      canvas.drawPath(spout, Paint()..color = _A3Painter._glass.withValues(alpha: 0.35));
      canvas.drawPath(
        spout,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = _A3Painter._outline.withValues(alpha: 0.85),
      );
    });
  }

  /// Litmus strip: BoxGeometry(0.4, 3.5) centred at [pos], tilted
  /// rotation.x = -PI/8 (foreshortened) and rotation.z [rotZ].
  void _strip(Canvas canvas, _V3 pos, double rotZ, Color color) {
    _local(canvas, pos, rotZ, (u, tl) {
      final r = Rect.fromCenter(center: Offset.zero, width: 0.4 * u, height: 3.5 * 0.92 * u);
      canvas.drawRect(r, Paint()..color = color);
      canvas.drawRect(Rect.fromLTRB(r.left, r.top, r.left + r.width * 0.35, r.bottom), Paint()..color = labShade(color, -0.15));
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _A3Painter._outline,
      );
    }, midY: 0);
  }

  /// Small glass jar holding red and blue litmus strips (not interactive).
  void _litmusJar(Canvas canvas) {
    _local(canvas, scene.layout.litmusJar, 0, (u, tl) {
      labGroundShadow(canvas, Offset(0, 2), 1.9 * u, 0.6 * u * tl + 3, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 1.5, r: 0.8);
      for (var i = 0; i < 2; i++) {
        for (final red in const [true, false]) {
          canvas.save();
          canvas.translate((red ? 0.15 : -0.15) * u + (i - 0.5) * 0.1 * u, 0);
          canvas.rotate(red ? -0.1 : 0.1);
          final r = Rect.fromLTRB(-0.125 * u, -2.0 * u, 0.125 * u, 0);
          canvas.drawRect(r, Paint()..color = red ? _Colors.red : _Colors.blue);
          canvas.restore();
        }
      }
      _glassFront(canvas, u, tl, y0: 0, h: 1.5, r: 0.8, topRim: false);
      _glassFront(canvas, u, tl, y0: 1.5, h: 0.3, r: 0.8, rTop: 0.6);
    }, midY: 1);
  }
}

// ============================================================ SCENES

extension _A3Scenes on _A3Painter {
  bool _inJar(_V3 p) => (p.x - _gasJarPos.x).abs() < 1.0 && p.y < 7.0 && p.z.abs() < 0.5;
  bool _inTumbler(_V3 p) => p.x.abs() < 1.5 && p.y < 5.2 && p.z.abs() < 0.5;

  /// Mouth of the (tilted) sulfur jar and spout of the (tilted) beaker.
  _V3 get _jarMouth {
    final s = scene;
    return _V3(s.jarPos.x - 3.0 * math.sin(s.jarRot), s.jarPos.y + 3.0 * math.cos(s.jarRot), s.jarPos.z);
  }

  _V3 get _spout {
    final s = scene;
    final c = math.cos(s.beakerRot), sn = math.sin(s.beakerRot);
    return _V3(s.beakerPos.x - 1.9 * c - 3.6 * sn, s.beakerPos.y - 1.9 * sn + 3.6 * c, s.beakerPos.z);
  }

  /// Falling stream (sulfur grains or water) from [from] to [to].
  void _stream(Canvas canvas, _V3 from, _V3 to, Color color, double width, {bool grains = false}) {
    final a = cam.p(from), b = cam.p(to);
    final k = cam.k(from);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(a.dx + (b.dx - a.dx) * 0.85, a.dy + (b.dy - a.dy) * 0.1, b.dx, b.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * k
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.9),
    );
    if (grains) {
      for (final m in path.computeMetrics()) {
        for (var i = 0; i < 9; i++) {
          final d = ((i / 9 + t * 1.8) % 1) * m.length;
          final pt = m.getTangentForOffset(d)!.position;
          canvas.drawCircle(pt + Offset(i.isEven ? -2 : 2, 0), width * k * 0.9, Paint()..color = labShade(color, 0.2));
        }
      }
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, width * k * 0.25)
          ..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  /// Gas jar with SO2 fog, the solution, anything lowered inside, the
  /// water stream and the sliding lid.
  void _gasJar(Canvas canvas, List<VoidCallback> inside) {
    final s = scene;
    _local(canvas, _gasJarPos, s.gasJarRot, (u, tl) {
      labGroundShadow(canvas, Offset(0, 2), 4 * u, 1.2 * u * tl + 4, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 5.5, r: 1.8);
    }, midY: 3);
    for (final f in inside) {
      f();
    }
    _local(canvas, _gasJarPos, s.gasJarRot, (u, tl) {
      if (s.solution > 0) {
        final wobble = s.gasJarRot * 3;
        canvas.save();
        canvas.rotate(wobble);
        _liquid(canvas, u, tl, y0: 0.5, h: 1.5 * s.solution, r: 1.7, color: _A3Painter._water);
        canvas.restore();
      }
      if (s.gas > 0.01) {
        final fog = _cylPath(u, tl, 0, 0.35, 5.3, 1.65, 1.65);
        canvas.drawPath(fog, Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.55 * s.gas));
        canvas.save();
        canvas.clipPath(fog);
        final wisp = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.35 * u
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35 * s.gas)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.2 * u);
        for (var i = 0; i < 5; i++) {
          final y = -(1 + i * 1.0) * u;
          final path = Path()..moveTo(-1.8 * u, y);
          for (var x = -1.8; x <= 1.8; x += 0.2) {
            path.lineTo(x * u, y + math.sin(x * 2.2 + t * 1.3 + i) * 0.25 * u);
          }
          canvas.drawPath(path, wisp);
        }
        canvas.restore();
      }
      _glassFront(canvas, u, tl, y0: 0, h: 5.5, r: 1.8, topRim: false);
      _glassFront(canvas, u, tl, y0: 5.5, h: 0.5, r: 1.8, rTop: 1.5, topRim: false);
      _glassFront(canvas, u, tl, y0: 6.0, h: 0.2, r: 1.575);
      _toon(canvas, u, tl, cx: s.lidX, y0: 6.0, h: 0.4, r: 1.6, color: Colors.white);
    }, midY: 3);
  }

  /// Glass tumbler with sulfur powder, water and dipped litmus.
  void _tumbler(Canvas canvas, List<VoidCallback> inside) {
    final s = scene;
    _local(canvas, _tumblerPos, 0, (u, tl) {
      labGroundShadow(canvas, Offset(0, 2), 4.4 * u, 1.3 * u * tl + 4, opacity: 0.3);
      _glassBack(canvas, u, tl, y0: 0, h: 4.5, r: 2);
      _toon(canvas, u, tl, y0: 0.1, h: 0.45 * s.tumblerPowder, r: 1.95, color: _A3Painter._sulfur, outline: false);
    }, midY: 2.5);
    for (final f in inside) {
      f();
    }
    _local(canvas, _tumblerPos, 0, (u, tl) {
      _liquid(canvas, u, tl, y0: 0.55, h: 3.6 * s.tumblerWater, r: 1.95, color: _A3Painter._water, alpha: 0.78);
      _glassFront(canvas, u, tl, y0: 0, h: 4.5, r: 2);
    }, midY: 2.5);
  }

  void _paintS1(Canvas canvas) {
    final s = scene;
    final blueColor = s.blueTurnedRed ? _Colors.red : _Colors.blue;
    final spoonIn = s.spoonVisible && _inJar(s.spoonPos);
    final litIn = _inJar(s.bluePos);
    final atLamp = s.spoonPos.z < -1;
    final items = <(double, VoidCallback)>[
      (-2.0, () => _lampBody(canvas)),
      if (s.spoonVisible && atLamp) (-1.99, () => _spoon(canvas)),
      (-1.98, () => _lampFlame(canvas)),
      (
        0.0,
        () => _gasJar(canvas, [
              if (spoonIn) () => _spoon(canvas),
              if (litIn) () => _strip(canvas, s.bluePos, 0.15, blueColor),
              if (s.waterStream)
                () => _stream(canvas, _spout, _V3(7, 0.5 + 1.5 * s.solution, 0), _A3Painter._water, 0.3),
            ]),
      ),
      (s.beakerPos.z + 0.01, () => _beaker(canvas)),
      (s.jarPos.z + 0.02, () => _sulfurJar(canvas)),
      if (s.spoonVisible && !spoonIn && !atLamp) (s.spoonPos.z + 0.03, () => _spoon(canvas)),
      (6.0, () => _litmusJar(canvas)),
      if (!litIn) (s.bluePos.z + 0.04, () => _strip(canvas, s.bluePos, 0.15, blueColor)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final it in items) {
      it.$2();
    }
    if (s.sulfurStream) {
      _stream(canvas, _jarMouth, s.spoonPos.withY(s.spoonPos.y + 0.05), _A3Painter._sulfur, 0.16, grains: true);
    }
  }

  void _paintS2(Canvas canvas) {
    final s = scene;
    final blueIn = _inTumbler(s.bluePos);
    final redIn = _inTumbler(s.redPos);
    final items = <(double, VoidCallback)>[
      (
        0.0,
        () => _tumbler(canvas, [
              if (blueIn) () => _strip(canvas, s.bluePos, 0, _Colors.blue),
              if (redIn) () => _strip(canvas, s.redPos, 0, _Colors.red),
            ]),
      ),
      (s.beakerPos.z + 0.01, () => _beaker(canvas)),
      (s.jarPos.z + 0.02, () => _sulfurJar(canvas)),
      (6.0, () => _litmusJar(canvas)),
      if (!redIn) (s.redPos.z + 0.03, () => _strip(canvas, s.redPos, 0, _Colors.red)),
      if (!blueIn) (s.bluePos.z + 0.04, () => _strip(canvas, s.bluePos, 0, _Colors.blue)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final it in items) {
      it.$2();
    }
    if (s.sulfurStream) {
      _stream(canvas, _jarMouth, _V3(-0.6, 0.1 + 0.45 * s.tumblerPowder, 0), _A3Painter._sulfur, 0.16, grains: true);
    }
    if (s.waterStream) {
      _stream(canvas, _spout, _V3(-0.9, 0.55 + 3.6 * s.tumblerWater, 0), _A3Painter._water, 0.3);
    }
  }
}

// ======================================================= POPUP CONTENT

/// Text with `**bold**` segments (the HTML `<strong>` parts).
Widget _boldText(String text, TextStyle base, TextStyle bold, {TextAlign align = TextAlign.start}) {
  final parts = text.split('**');
  return Text.rich(
    TextSpan(children: [
      for (var i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty) TextSpan(text: parts[i], style: i.isOdd ? bold : null),
    ]),
    style: base,
    textAlign: align,
  );
}

/// Chemical formula with drawn subscripts (a digit after a letter or `)`),
/// independent of the font's Unicode subscript glyphs.
Widget _formula(String f, TextStyle style) {
  final size = style.fontSize ?? 14;
  final spans = <InlineSpan>[];
  for (var i = 0; i < f.length; i++) {
    final ch = f[i];
    if (ch == '→') {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.2),
          child: Icon(Icons.arrow_forward_rounded, size: size * 1.1, color: style.color),
        ),
      ));
      continue;
    }
    final isSub = RegExp(r'[0-9]').hasMatch(ch) && i > 0 && RegExp(r'[A-Za-z)]').hasMatch(f[i - 1]);
    if (isSub) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Transform.translate(
          offset: Offset(0, size * 0.28),
          child: Text(ch, style: style.copyWith(fontSize: size * 0.7)),
        ),
      ));
    } else {
      spans.add(TextSpan(text: ch));
    }
  }
  return Text.rich(TextSpan(children: spans), style: style, textAlign: TextAlign.center);
}

extension _A3Popups on _Ch4A3ChemicalReactionsOfNonMetalsWithAirAndWaterPageState {
  double get _sc => context.labScale;

  Widget _item(Widget icon, String label) {
    final p = _Theme.of(_lab.isDark);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 50 * _sc, child: Align(widthFactor: 1, child: icon)),
        SizedBox(height: 6 * _sc),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 96 * _sc),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textStrong, fontSize: 11.5 * _sc, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _op(String t) {
    final p = _Theme.of(_lab.isDark);
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * _sc),
      child: Text(t, style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w800, fontSize: 22 * _sc)),
    );
  }

  Widget _arrow() {
    final p = _Theme.of(_lab.isDark);
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * _sc),
      child: Icon(Icons.arrow_forward_rounded, color: p.textMuted, size: 26 * _sc),
    );
  }

  Widget _circle(double d, {Color? fill, Color? border, double bw = 0, double opacity = 1}) => Opacity(
        opacity: opacity,
        child: Container(
          width: d * _sc,
          height: d * _sc,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: border == null ? null : Border.all(color: border, width: bw * _sc),
            boxShadow: fill == null
                ? null
                : const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
      );

  /// Blurred grey cloud (sulfur dioxide gas).
  Widget _gasCloud() => ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          width: 60 * _sc,
          height: 42 * _sc,
          decoration: BoxDecoration(
            color: _Colors.slate300.withValues(alpha: 0.75),
            borderRadius: BorderRadius.all(Radius.elliptical(30 * _sc, 21 * _sc)),
          ),
        ),
      );

  /// Water drop (rounded square with one sharp corner, rotated 45°).
  Widget _drop() => Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 40 * _sc,
          height: 40 * _sc,
          decoration: BoxDecoration(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.85),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20 * _sc),
              bottomLeft: Radius.circular(20 * _sc),
              bottomRight: Radius.circular(20 * _sc),
            ),
          ),
        ),
      );

  Widget _tag(String t, Color bg, Color border, {double angle = 0}) => Transform.rotate(
        angle: angle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * _sc, vertical: 7 * _sc),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Text(
            t,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12 * _sc, letterSpacing: 2),
          ),
        ),
      );

  Widget _panel(List<Widget> children) {
    final p = _Theme.of(_lab.isDark);
    return Container(
      padding: EdgeInsets.all(14 * _sc),
      decoration: BoxDecoration(
        color: (_lab.isDark ? _Colors.slate900 : _Colors.slate50).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _desc(String key) {
    final p = _Theme.of(_lab.isDark);
    return Padding(
      padding: EdgeInsets.only(top: 12 * _sc),
      child: Text(
        _t(key),
        textAlign: TextAlign.center,
        style: TextStyle(color: p.textMuted, fontStyle: FontStyle.italic, fontSize: 12.5 * _sc, height: 1.45),
      ),
    );
  }

  Widget _row(List<Widget> items) => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 12 * _sc,
        runSpacing: 10 * _sc,
        children: items,
      );

  /// HTML #scenario1-summary.
  Widget _summary1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel([
          _row([
            _item(_circle(46, fill: const Color(0xFFFFB300)), _t('lbl_sulfur')),
            _op('+'),
            _item(_circle(46, border: const Color(0xFF93C5FD), bw: 4, opacity: 0.75), _t('lbl_oxygen')),
            _item(Icon(Icons.local_fire_department, color: _Colors.orange, size: 30 * _sc), _t('lbl_heat')),
            _item(_gasCloud(), _t('lbl_so2')),
          ]),
          Divider(height: 22 * _sc, color: _Theme.of(_lab.isDark).border),
          _row([
            _item(_gasCloud(), _t('lbl_so2_short')),
            _op('+'),
            _item(_drop(), _t('lbl_water')),
            _arrow(),
            _item(_circle(46, fill: const Color(0xFF93C5FD), border: const Color(0xFF3B82F6), bw: 6), _t('lbl_acid')),
            Padding(
              padding: EdgeInsets.only(bottom: 26 * _sc),
              child: _tag(_t('lbl_acidic_tag'), _Colors.red, const Color(0xFFF87171), angle: -5 * math.pi / 180),
            ),
          ]),
        ]),
        _desc('summary_1_desc'),
      ],
    );
  }

  /// HTML #scenario2-summary.
  Widget _summary2() {
    final tumbler = Container(
      width: 46 * _sc,
      height: 58 * _sc,
      decoration: BoxDecoration(
        color: const Color(0xFF93C5FD).withValues(alpha: 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        children: [
          const Spacer(),
          Expanded(flex: 2, child: Container(color: const Color(0xFF60A5FA).withValues(alpha: 0.45))),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFB300),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
    Widget strip(Color c) => Container(
          width: 16 * _sc,
          height: 50 * _sc,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel([
          _row([
            _item(tumbler, _t('lbl_water_sulfur')),
            _arrow(),
            _item(
              Row(mainAxisSize: MainAxisSize.min, children: [strip(_Colors.blue), SizedBox(width: 10 * _sc), strip(_Colors.red)]),
              '',
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 26 * _sc),
              child: _tag(_t('lbl_neutral_tag'), _Colors.slate600, _Colors.slate400),
            ),
          ]),
        ]),
        _desc('summary_2_desc'),
      ],
    );
  }

  /// HTML `s1_obs` / `s2_obs` (observation popup).
  Widget _observation() {
    final dark = _lab.isDark;
    final p = _Theme.of(dark);
    final f = _sc * _lab.fontScale.clamp(0.9, 1.4);
    final base = TextStyle(color: p.text, fontSize: 13 * f, height: 1.5, fontWeight: FontWeight.w500);
    final bold = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);
    final s1 = s.scenario == 0;
    Widget gap([double h = 8]) => SizedBox(height: h * _sc);

    final box = Container(
      padding: EdgeInsets.all(12 * _sc),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: s1
          ? Column(
              children: [
                _formula(
                  'SO2(g) + H2O(l) → H2SO3(aq)',
                  TextStyle(
                    color: p.textStrong,
                    fontWeight: FontWeight.w800,
                    fontSize: 15 * f,
                    letterSpacing: 0.5,
                  ),
                ),
                gap(6),
                _formula(
                  _t('obs1_eq_caption'),
                  TextStyle(color: p.textMuted, fontSize: 11.5 * f),
                ),
              ],
            )
          : Text(
              _t('lbl_neutral_tag'),
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFFF87171), fontWeight: FontWeight.w800, fontSize: 13 * f),
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 6 * _sc),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.cardBorder))),
          child: Text(
            _t('obs_done'),
            style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 16 * f),
          ),
        ),
        gap(10),
        if (s1) ...[
          _boldText(_t('obs1_observation'), base, bold),
          gap(),
          _boldText(_t('obs1_conclusion'), base, bold),
        ] else ...[
          _boldText(_t('obs2_obs1'), base, bold),
          gap(),
          _boldText(_t('obs2_obs2'), base, bold),
          gap(),
          _boldText(_t('obs2_conclusion'), base, bold),
        ],
        gap(12),
        box,
        gap(12),
        Text(
          _t(s1 ? 'obs1_rule' : 'obs2_rule'),
          style: TextStyle(
            color: dark ? _Colors.zslYellow : const Color(0xFFA16207),
            fontWeight: FontWeight.w800,
            fontSize: 13 * f,
            height: 1.45,
          ),
        ),
        gap(),
        Text(
          _t(s1 ? 'obs1_fact' : 'obs2_fact'),
          style: TextStyle(color: p.textMuted, fontStyle: FontStyle.italic, fontSize: 11.5 * f, height: 1.45),
        ),
      ],
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
