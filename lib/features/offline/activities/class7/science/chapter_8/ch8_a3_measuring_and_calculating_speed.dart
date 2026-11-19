// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 8 • Activity 3
/// Measuring and Calculating Speed.
///
/// Native Flutter port of `Cl7S-Ch8-A3-Measuring_and_Calculating_Speed.html`.
/// Scenario 1: Swati rides from home to school (3.6 km in 15 min); the
/// distance and time panels are dragged into the Calculation Machine,
/// converted to 3600 m / 900 s and divided (4 m/s). Scenario 2: the Express
/// Train data is extracted from a railway timetable into a journey planner,
/// the time taken is found with a clock slider and the machine gives 90 km/h.
class Ch8A3MeasuringAndCalculatingSpeedPage extends StatefulWidget {
  const Ch8A3MeasuringAndCalculatingSpeedPage({super.key});

  @override
  State<Ch8A3MeasuringAndCalculatingSpeedPage> createState() => _Ch8A3MeasuringAndCalculatingSpeedPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, buzz 2594.
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
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
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

class _Ch8A3MeasuringAndCalculatingSpeedPageState extends State<Ch8A3MeasuringAndCalculatingSpeedPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _SpeedScene _scene = _SpeedScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _distSlotKey = GlobalKey();
  final GlobalKey _timeSlotKey = GlobalKey();

  late final Ticker _ticker;
  late final AnimationController _race;

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

    _scene.reset();
    // HTML: TWEEN 4000 ms, Quadratic.InOut along the path.
    _race = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..addListener(() {
        final v = Curves.easeInOutQuad.transform(_race.value);
        _scene.placeBike(v);
        _scene.pedal = v * math.pi * 16; // 8 full pedal strokes
      });
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _race.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    if (_scene.racing) _scene.wheelAngle -= 0.3 * 60 * dt; // HTML: -0.3 per frame
    _frame.value = t;
  }

  // -------------------------------------------------------------- logic

  /// HTML `resetApp(true)` + `buildScenario3D()`.
  void _buildScenario() {
    _lab.cancelPending();
    _race.stop();
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`: the step never goes past the last one; calling it
  /// on the last step shows the conclusion.
  void _advanceStep() {
    if (!mounted) return;
    final sc = _scene;
    if (sc.step < _data.steps.length) {
      setState(() {
        sc.step++;
        if (sc.scenario == 0 && sc.step == 3) {
          sc.leverVisible = true;
        } else if (sc.scenario == 0 && sc.step == 4) {
          sc.handleVisible = true;
        } else if (sc.scenario == 1 && sc.step == 3) {
          sc.clockVisible = true;
        } else if (sc.scenario == 1 && sc.step == 5) {
          sc.handleVisible = true;
        }
      });
    } else {
      _showConclusion();
    }
  }

  void _showConclusion() {
    setState(() => _scene.done = true); // HUD hidden at the end
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scene.scenario + 1}'),
    );
  }

  /// HTML `triggerMainAction()`: Start Race / View Timetable.
  void _triggerMain() {
    final sc = _scene;
    if (!sc.mainVisible) return;
    setState(() => sc.mainVisible = false);
    if (sc.scenario == 0 && sc.step == 1) {
      setState(() {
        sc.metersVisible = true;
        sc.racing = true;
      });
      _race.forward(from: 0).whenComplete(() {
        if (!mounted || _race.value < 1) return;
        setState(() {
          sc.racing = false;
          sc.placeBike(1);
        });
        _lab.after(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            sc.machineVisible = true;
            sc.pillsVisible = true;
          });
          _advanceStep();
        });
      });
    } else if (sc.scenario == 1 && sc.step == 1) {
      setState(() => sc.timetableOpen = true);
      _advanceStep();
    }
  }

  /// Global rect of a machine slot, grown by the HTML 35 px touch buffer.
  bool _isOver(Offset global, GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return false;
    final rect = MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
    return rect.inflate(35).contains(global);
  }

  /// HTML `checkDrop()`: a panel dropped over its matching slot snaps in.
  void _onPillDropped(String type, Offset global) {
    final sc = _scene;
    var dropped = false;
    final validStep = (sc.scenario == 0 && sc.step == 2) || (sc.scenario == 1 && sc.step == 4);
    if (validStep) {
      if (type == 'distance' && !sc.distDropped && _isOver(global, _distSlotKey)) {
        sc.distDropped = true;
        dropped = true;
      } else if (type == 'time' && !sc.timeDropped && _isOver(global, _timeSlotKey)) {
        sc.timeDropped = true;
        dropped = true;
      }
      if (dropped && sc.distDropped && sc.timeDropped) {
        _lab.after(const Duration(milliseconds: 500), _advanceStep);
      }
    }
    _Audio.play(dropped ? _Sound.drop : _Sound.wrong);
    setState(() {});
  }

  /// HTML `triggerConvert()`: 3.6 km -> 3600 m, 15 min -> 900 s.
  void _convert() {
    final sc = _scene;
    if (!sc.leverVisible || sc.leverPressed) return;
    _Audio.play(_Sound.buzz);
    setState(() => sc.leverPressed = true);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => sc.converted = true);
      _Audio.play(_Sound.success);
      _lab.after(const Duration(milliseconds: 1500), _advanceStep);
    });
  }

  /// HTML `triggerCalculate()`: gears divide, then the result and the
  /// speedometer appear.
  void _calculate() {
    final sc = _scene;
    if (!sc.handleVisible || sc.handlePulled) return;
    _Audio.play(_Sound.buzz);
    setState(() => sc.handlePulled = true);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => sc.resultShown = true);
      _Audio.play(_Sound.success);
      _lab.after(const Duration(milliseconds: 1000), _advanceStep);
    });
  }

  void _closeTimetable() {
    _Audio.play(_Sound.click);
    setState(() => _scene.timetableOpen = false);
  }

  /// Re-opens the timetable if it was closed before extracting the data
  /// (the HTML had no way back once the modal was closed).
  void _reopenTimetable() => setState(() => _scene.timetableOpen = true);

  /// HTML `extractDataFromTimetable()`.
  void _extractData() {
    final sc = _scene;
    if (sc.rowExtracted) return;
    _Audio.play(_Sound.drop);
    setState(() => sc.rowExtracted = true);
    _lab.after(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        sc.timetableOpen = false;
        sc.plannerVisible = true;
      });
      _lab.after(const Duration(milliseconds: 1000), _advanceStep);
    });
  }

  /// HTML `updateClock()`.
  void _updateClock(double v) => setState(() => _scene.clock = v);

  /// HTML `generateTimePill()`.
  void _useThisTime() {
    final sc = _scene;
    if (sc.clockUsed || sc.clock < 12) return;
    _Audio.play(_Sound.drop);
    setState(() {
      sc.clockUsed = true;
      sc.pillsVisible = true;
      sc.machineVisible = true;
    });
    _advanceStep();
  }

  List<LabAction> _actions() {
    final sc = _scene;
    final out = <LabAction>[];
    if (sc.mainVisible && sc.step == 1) out.add(_mainAction());
    if (sc.scenario == 1 && sc.step == 2 && !sc.rowExtracted) {
      out.add(sc.timetableOpen
          ? LabAction(
              label: _t('extract_data'),
              icon: Icons.download_rounded,
              highlight: true,
              silent: true,
              onTap: _extractData,
            )
          : LabAction(
              label: _t('btn_view_timetable'),
              icon: Icons.calendar_month,
              color: _indigo600,
              foreground: Colors.white,
              highlight: true,
              onTap: _reopenTimetable,
            ));
    }
    if (sc.scenario == 1 && sc.step == 3 && sc.clock >= 12 - 1e-6 && !sc.clockUsed) {
      out.add(LabAction(
        label: _t('use_this_time'),
        icon: Icons.check_rounded,
        color: _indigo600,
        foreground: Colors.white,
        highlight: true,
        silent: true,
        onTap: _useThisTime,
      ));
    }
    if (sc.leverVisible && !sc.leverPressed) {
      out.add(LabAction(
        label: _t('convert'),
        icon: Icons.swap_vert_rounded,
        color: _Colors.red600,
        foreground: Colors.white,
        highlight: true,
        silent: true,
        onTap: _convert,
      ));
    }
    if (sc.handleVisible && !sc.handlePulled) {
      out.add(LabAction(
        label: _t('calculate'),
        icon: Icons.play_arrow_rounded,
        highlight: true,
        silent: true,
        onTap: _calculate,
      ));
    }
    return out;
  }

  // ----------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final sc = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.speed,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: sc.done ? '' : null,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) => _uiLayer(context, c.biggest, p, s),
              ),
            ),
          ],
          stage: LabStage(
            designSize: _design,
            child: CustomPaint(
              size: _design,
              painter: _ScenePainter(
                scene: _scene,
                repaint: _frame,
                isDark: _lab.isDark,
                showLabels: _lab.showLabels,
                lang: _lab.lang,
                tr: _t,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Measuring and Calculating Speed',
    'app_subtitle': 'Class 7 • Measurement of Time and Motion',
    'scen_1_opt': "Scenario 1: Swati's Bicycle Ride",
    'scen_2_opt': 'Scenario 2: The Express Train',
    'sci_conclusion': 'Success!',
    'btn_start_race': 'Start Race',
    'btn_view_timetable': 'View Timetable',
    'distance': 'Distance',
    'time': 'Time',
    'convert': 'Convert',
    'calculate': 'Calculate',
    'calc_machine': 'Calculation Machine',
    'drop_dist': 'Drop Distance',
    'drop_time': 'Drop Time',
    'railway_timetable': 'Railway Timetable',
    'train_name': 'Train Name',
    'departure': 'Departure',
    'arrival': 'Arrival',
    'extract_data': 'Extract Data',
    'journey_planner': 'Journey Planner',
    'calc_time_taken': 'Calculate Time Taken',
    'time_taken': 'Time Taken',
    'use_this_time': 'Use This Time',
    'conclusion_1':
        'By dividing the total distance (3600 m) by the total time taken (900 s), we found the speed. Speed = Distance / Time. Swati\'s speed was 4 m/s.',
    'conclusion_2':
        'The train traveled 180 km in 2 hours. Its average speed is calculated directly without conversion: 180 km / 2 h = 90 km/h.',
    // Strings that were hard-coded (English only) in the HTML.
    'u_km': 'km',
    'u_min': 'min',
    'u_m': 'm',
    'u_s': 's',
    'u_h': 'h',
    'u_mps': 'm/s',
    'u_kmph': 'km/h',
    'lbl_home': 'Home',
    'lbl_school': 'School',
    'lbl_station': 'Station',
    'train_local': 'Local Passenger',
    'train_express': 'Express Train',
    'train_night': 'Night Mail',
    't_0800am': '08:00 AM',
    't_1130am': '11:30 AM',
    't_1000am': '10:00 AM',
    't_1200pm': '12:00 PM',
    't_0900pm': '09:00 PM',
    't_0500am': '05:00 AM',
    'close': 'Close',
  },
  'hi': {
    'app_title': 'गति को मापना और उसकी गणना करना',
    'app_subtitle': 'कक्षा 7 • समय और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: स्वाति की साइकिल की सवारी',
    'scen_2_opt': 'परिदृश्य 2: एक्सप्रेस ट्रेन',
    'sci_conclusion': 'सफलता!',
    'btn_start_race': 'दौड़ शुरू करें',
    'btn_view_timetable': 'समय सारिणी देखें',
    'distance': 'दूरी',
    'time': 'समय',
    'convert': 'बदलें',
    'calculate': 'गणना करें',
    'calc_machine': 'गणना मशीन',
    'drop_dist': 'दूरी छोड़ें',
    'drop_time': 'समय छोड़ें',
    'railway_timetable': 'रेलवे समय सारिणी',
    'train_name': 'ट्रेन का नाम',
    'departure': 'प्रस्थान',
    'arrival': 'आगमन',
    'extract_data': 'डेटा निकालें',
    'journey_planner': 'यात्रा योजनाकार',
    'calc_time_taken': 'लिए गए समय की गणना करें',
    'time_taken': 'लिया गया समय',
    'use_this_time': 'इस समय का उपयोग करें',
    'conclusion_1':
        'कुल दूरी (3600 मीटर) को कुल लिए गए समय (900 सेकंड) से विभाजित करके, हमने गति पाई। स्वाति की गति 4 मीटर/सेकंड थी।',
    'conclusion_2': 'ट्रेन ने 2 घंटे में 180 किमी की यात्रा की। इसकी औसत गति 180 किमी / 2 घंटे = 90 किमी/घंटा है।',
    'u_km': 'किमी',
    'u_min': 'मिनट',
    'u_m': 'मीटर',
    'u_s': 'सेकंड',
    'u_h': 'घंटे',
    'u_mps': 'मी/से',
    'u_kmph': 'किमी/घंटा',
    'lbl_home': 'घर',
    'lbl_school': 'स्कूल',
    'lbl_station': 'स्टेशन',
    'train_local': 'लोकल पैसेंजर',
    'train_express': 'एक्सप्रेस ट्रेन',
    'train_night': 'नाइट मेल',
    't_0800am': 'सुबह 08:00',
    't_1130am': 'सुबह 11:30',
    't_1000am': 'सुबह 10:00',
    't_1200pm': 'दोपहर 12:00',
    't_0900pm': 'रात 09:00',
    't_0500am': 'सुबह 05:00',
    'close': 'बंद करें',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "To calculate the speed of Swati's bicycle in m/s by visually interacting with the components of distance and time.",
      steps: [
        LabStep(
          concept: '',
          action:
              "CLICK the 'Start Race' button on the screen. Watch Swati ride her bicycle from her house to the school.",
          observation:
              'The bicycle moves along the path. The distance and time meters track the progress, stopping at 3.6 km and 15 min.',
        ),
        LabStep(
          concept: '',
          action:
              'DRAG the Distance panel (3.6 km) and Time panel (15 min) and DROP them into the Calculation Machine slots.',
          observation: 'The panels snap into the machine, preparing it for calculation.',
        ),
        LabStep(
          concept: '',
          action: "The mission is to find speed in m/s. CLICK the 'Convert' lever.",
          observation: '3.6 km flips to 3600 m (x1000). 15 min flips to 900 s (x60).',
        ),
        LabStep(
          concept: '',
          action: "CLICK or PULL the yellow 'Calculate' handle on the right side of the machine.",
          observation: 'The gears spin, calculating 3600 / 900. The final result is 4 m/s.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To calculate the speed of a train in km/h by extracting information from a timetable.',
      steps: [
        LabStep(
          concept: '',
          action: "CLICK 'View Timetable' to find the journey details for the Express Train.",
          observation: 'The timetable shows Departure: 10:00 AM, Arrival: 12:00 PM, Distance: 180 km.',
        ),
        LabStep(
          concept: '',
          action: "CLICK 'Extract Data' to move the Express Train details to the Journey Planner.",
          observation: 'Distance (180 km), Departure, and Arrival times populate the Journey Planner.',
        ),
        LabStep(
          concept: '',
          action:
              "DRAG the clock slider from 10:00 to 12:00 to calculate the time taken, then CLICK 'Use This Time'.",
          observation: 'The calculated time is 2 hours.',
        ),
        LabStep(
          concept: '',
          action: 'DRAG the Distance (180 km) and Time (2 h) panels to the Calculation Machine.',
          observation: 'The panels load into the machine. No conversion is needed for km/h.',
        ),
        LabStep(
          concept: '',
          action: "CLICK or PULL the yellow 'Calculate' handle.",
          observation: 'The gears spin, calculating 180 / 2. The final result is 90 km/h.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'दूरी और समय के घटकों के साथ नेत्रहीन रूप से बातचीत करके m/s में स्वाति की साइकिल की गति की गणना करना।',
      steps: [
        LabStep(
          concept: '',
          action: "'दौड़ शुरू करें' बटन पर क्लिक करें। स्वाति को घर से स्कूल जाते हुए देखें।",
          observation: 'मीटर प्रगति को ट्रैक करते हैं, 3.6 किमी और 15 मिनट पर रुकते हैं।',
        ),
        LabStep(
          concept: '',
          action: 'दूरी और समय पैनल को गणना मशीन के स्लॉट में खींचें और छोड़ें।',
          observation: 'पैनल मशीन में स्नैप होते हैं।',
        ),
        LabStep(
          concept: '',
          action: "मिशन m/s में गति खोजना है। 'कन्वर्ट' लीवर पर क्लिक करें।",
          observation: 'इकाइयाँ मीटर और सेकंड में बदल जाती हैं।',
        ),
        LabStep(
          concept: '',
          action: "पीले 'कैलकुलेट' हैंडल पर क्लिक करें या खींचें।",
          observation: 'मशीन गणना करती है और अंतिम परिणाम 4 m/s दिखाती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'समय सारिणी से जानकारी निकालकर km/h में ट्रेन की गति की गणना करना।',
      steps: [
        LabStep(
          concept: '',
          action: "एक्सप्रेस ट्रेन के विवरण खोजने के लिए 'समय सारिणी देखें' पर क्लिक करें।",
          observation: 'विवरण प्रदर्शित होते हैं।',
        ),
        LabStep(
          concept: '',
          action: "विवरण को जर्नी प्लानर में ले जाने के लिए 'डेटा निकालें' पर क्लिक करें।",
          observation: 'डेटा योजनाकार को आबाद करता है।',
        ),
        LabStep(
          concept: '',
          action: 'लिए गए समय की गणना करने के लिए क्लॉक स्लाइडर को 10 से 12 तक खींचें।',
          observation: 'परिकलित समय 2 घंटे है।',
        ),
        LabStep(
          concept: '',
          action: 'दूरी और समय पैनल को गणना मशीन में खींचें।',
          observation: 'पैनल मशीन में लोड होते हैं।',
        ),
        LabStep(
          concept: '',
          action: "पीले 'कैलकुलेट' हैंडल पर क्लिक करें या खींचें।",
          observation: 'मशीन 90 किमी/घंटा आउटपुट करती है।',
        ),
      ],
    ),
  ],
};

// ======================================================== 3D HELPERS

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
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }
}

/// Perspective look-at camera reproducing the HTML PerspectiveCamera (fov 45)
/// on the 1000x560 design canvas.
class _Cam {
  _Cam(this.pos, _V3 target) {
    f = (target - pos).unit;
    r = f.cross(const _V3(0, 1, 0)).unit;
    u = r.cross(f);
  }

  final _V3 pos;
  late final _V3 f, r, u;
  static const double focal = 280 / 0.41421356; // (h / 2) / tan(22.5°)
  static const Offset center = Offset(500, 280);

  double depth(_V3 p) => (p - pos).dot(f);
  double scaleAt(_V3 p) => focal / math.max(0.1, depth(p));

  Offset project(_V3 p) {
    final d = p - pos;
    final z = math.max(0.1, d.dot(f));
    return Offset(center.dx + focal * d.dot(r) / z, center.dy - focal * d.dot(u) / z);
  }
}

final _Cam _cam1 = _Cam(const _V3(0, 15, 25), const _V3(0, 0, 0));
final _Cam _cam2 = _Cam(const _V3(0, 10, 30), const _V3(0, 2, 0));

/// Directional light of the HTML scene (position 10, 20, 10).
final _V3 _light = const _V3(10, 20, 10).unit;

Color _lit(Color c, _V3 n, {double opacity = 1}) {
  final d = math.max(0.0, n.dot(_light));
  final f = 0.75 + 0.5 * d;
  final out = f >= 1 ? labShade(c, (f - 1) * 0.9) : labShade(c, -(1 - f));
  return out.withValues(alpha: opacity);
}

/// THREE.CatmullRomCurve3 (centripetal) through the bicycle path points.
class _CatmullRom {
  const _CatmullRom(this.points);
  final List<_V3> points;

  static double _calc(double x0, double x1, double x2, double x3, double dt0, double dt1, double dt2, double t) {
    var t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1;
    var t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2;
    t1 *= dt1;
    t2 *= dt1;
    final c0 = x1, c1 = t1, c2 = -3 * x1 + 3 * x2 - 2 * t1 - t2, c3 = 2 * x1 - 2 * x2 + t1 + t2;
    return c0 + c1 * t + c2 * t * t + c3 * t * t * t;
  }

  _V3 point(double t) {
    final l = points.length;
    final p = (l - 1) * t.clamp(0.0, 1.0);
    var i = p.floor();
    var w = p - i;
    if (i >= l - 1) {
      i = l - 2;
      w = 1;
    }
    final p0 = i > 0 ? points[i - 1] : points[0] * 2 - points[1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < l ? points[i + 2] : points[l - 1] * 2 - points[l - 2];
    double pw(_V3 a, _V3 b) => math.pow((a - b).dot(a - b), 0.25).toDouble();
    var dt0 = pw(p0, p1), dt1 = pw(p1, p2), dt2 = pw(p2, p3);
    if (dt1 < 1e-4) dt1 = 1;
    if (dt0 < 1e-4) dt0 = dt1;
    if (dt2 < 1e-4) dt2 = dt1;
    return _V3(
      _calc(p0.x, p1.x, p2.x, p3.x, dt0, dt1, dt2, w),
      _calc(p0.y, p1.y, p2.y, p3.y, dt0, dt1, dt2, w),
      _calc(p0.z, p1.z, p2.z, p3.z, dt0, dt1, dt2, w),
    );
  }
}

const _CatmullRom _path = _CatmullRom([
  _V3(-10, 0, 8),
  _V3(-5, 0, 0),
  _V3(5, 0, -2),
  _V3(10, 0, -8),
]);

// ============================================================== MODEL

/// Mutable state of both scenarios, read by the painter and overlays.
class _SpeedScene {
  int scenario = 0;
  int step = 1;
  bool done = false;
  double time = 0;

  // Scenario 1: race.
  bool mainVisible = true;
  bool metersVisible = false;
  double raceT = 0; // eased 0..1 along the path
  bool racing = false;
  double wheelAngle = 0;
  double pedal = 0;
  _V3 bikePos = const _V3(-10, 0.12, 8);
  _V3 bikeDir = const _V3(1, 0, -1.6);

  // Calculation machine.
  bool machineVisible = false;
  bool pillsVisible = false;
  bool distDropped = false;
  bool timeDropped = false;
  bool leverVisible = false;
  bool leverPressed = false;
  bool converted = false;
  bool handleVisible = false;
  bool handlePulled = false;
  bool resultShown = false;

  // Scenario 2: timetable + journey planner.
  bool timetableOpen = false;
  bool rowExtracted = false;
  bool plannerVisible = false;
  bool clockVisible = false;
  double clock = 10;
  bool clockUsed = false;

  void reset() {
    step = 1;
    done = false;
    mainVisible = true;
    metersVisible = false;
    raceT = 0;
    racing = false;
    wheelAngle = 0;
    pedal = 0;
    bikePos = _V3(_path.points.first.x, 0.12, _path.points.first.z);
    final look = _path.point(0.01);
    bikeDir = _V3(look.x - bikePos.x, 0, look.z - bikePos.z);
    machineVisible = false;
    pillsVisible = false;
    distDropped = false;
    timeDropped = false;
    leverVisible = false;
    leverPressed = false;
    converted = false;
    handleVisible = false;
    handlePulled = false;
    resultShown = false;
    timetableOpen = false;
    rowExtracted = false;
    plannerVisible = false;
    clockVisible = false;
    clock = 10;
    clockUsed = false;
  }

  /// Bicycle position along the path (HTML tween onUpdate).
  void placeBike(double t) {
    raceT = t;
    final pt = _path.point(t);
    bikePos = _V3(pt.x, 0.12, pt.z);
    if (t < 0.99) {
      final look = _path.point(t + 0.01);
      bikeDir = _V3(look.x - pt.x, 0, look.z - pt.z);
    }
  }
}

// ============================================================ PAINTING

/// The Three.js background: Swati's ride from home to school (scenario 1)
/// or the railway station (scenario 2).
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _SpeedScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintRide(canvas, size);
    } else {
      _paintStation(canvas, size);
    }
  }

  // ------------------------------------------------------- shared

  void _paintSkyAndGround(Canvas canvas, Size size, _Cam cam, Color ground) {
    final bleed = labBleed(size);
    final horizon = cam.project(const _V3(0, 0, -50)).dy;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, horizon + 1),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, horizon + 1)),
    );
    // HTML .grid-overlay over the sky.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = -480.0; x <= size.width + 480; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, horizon), grid);
    }
    for (var y = horizon - 40; y >= bleed.top; y -= 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
    final gRect = Rect.fromLTRB(bleed.left, horizon, bleed.right, bleed.bottom);
    canvas.drawRect(
      gRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(ground, 0.25), ground, labShade(ground, -0.08)],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromLTRB(0, horizon, 10, size.height + 60)),
    );
  }

  void _poly(Canvas canvas, _Cam cam, List<_V3> pts, Color color, _V3 center, {double opacity = 1}) {
    var n = (pts[1] - pts[0]).cross(pts[2] - pts[0]).unit;
    if (n.dot(pts[0] - center) < 0) n = n * -1;
    if (n.dot(cam.pos - pts[0]) <= 0) return;
    final path = Path()..addPolygon(pts.map(cam.project).toList(), true);
    canvas.drawPath(path, Paint()..color = _lit(color, n, opacity: opacity));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.3 * opacity),
    );
  }

  void _box(Canvas canvas, _Cam cam, _V3 c, _V3 s, Color color, {double opacity = 1}) {
    final hx = s.x / 2, hy = s.y / 2, hz = s.z / 2;
    _V3 v(double a, double b, double d) => _V3(c.x + a * hx, c.y + b * hy, c.z + d * hz);
    for (final f in [
      [v(1, -1, -1), v(1, 1, -1), v(1, 1, 1), v(1, -1, 1)],
      [v(-1, -1, -1), v(-1, -1, 1), v(-1, 1, 1), v(-1, 1, -1)],
      [v(-1, 1, -1), v(-1, 1, 1), v(1, 1, 1), v(1, 1, -1)],
      [v(-1, -1, 1), v(1, -1, 1), v(1, 1, 1), v(-1, 1, 1)],
      [v(-1, -1, -1), v(-1, 1, -1), v(1, 1, -1), v(1, -1, -1)],
    ]) {
      _poly(canvas, cam, f, color, c, opacity: opacity);
    }
  }

  /// HTML `create3DLabel`: dark sprite with a coloured border, always on top.
  void _label(Canvas canvas, _Cam cam, String text, _V3 pos, Color border) {
    if (!showLabels) return;
    // Sprite of 6 x 1.5 world units with a 50/128 font (HTML canvas texture).
    final k = cam.scaleAt(pos);
    final c = cam.project(pos);
    // Kept readable on phones (the stage is scaled down to ~0.6x there).
    final font = (0.6 * k).clamp(16.0, 26.0);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: font,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = math.max(6 * k, tp.width + 2 * font);
    final h = math.max(1.5 * k, font * 2.1);
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawRect(
      rect.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xD90F172A));
    canvas.drawRect(
      rect.deflate(0.05 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (0.1 * k).clamp(2.0, 5.0)
        ..color = border,
    );
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  // ------------------------------------------------------ scenario 1

  void _paintRide(Canvas canvas, Size size) {
    final cam = _cam1;
    _paintSkyAndGround(canvas, size, cam, const Color(0xFFA3E635));
    _paintRoad(canvas, cam);

    // Depth-sorted objects (far first).
    final items = <(double, void Function())>[
      (cam.depth(const _V3(-12, 1, 8)), () => _house(canvas, cam, const _V3(-12, 0, 8), 1, const Color(0xFFFEF08A))),
      (cam.depth(const _V3(12, 1.5, -10)), () => _house(canvas, cam, const _V3(12, 0, -10), 1.5, const Color(0xFFBFDBFE))),
      for (final t in const [_V3(-8, 0, 4), _V3(-2, 0, -4), _V3(4, 0, 3), _V3(8, 0, -2)])
        (cam.depth(t), () => _tree(canvas, cam, t)),
      (cam.depth(scene.bikePos), () => _bike(canvas, cam)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final it in items) {
      it.$2();
    }

    _label(canvas, cam, tr('lbl_home'), const _V3(-12, 4, 8), const Color(0xFF3B82F6));
    _label(canvas, cam, tr('lbl_school'), const _V3(12, 5, -10), const Color(0xFFEAB308));
  }

  void _paintRoad(Canvas canvas, _Cam cam) {
    Path ribbon(double halfWidth, double y) {
      final left = <Offset>[], right = <Offset>[];
      const n = 96;
      for (var i = 0; i <= n; i++) {
        final t = i / n;
        final p = _path.point(t);
        final a = _path.point(math.max(0, t - 0.004)), b = _path.point(math.min(1, t + 0.004));
        final tan = _V3(b.x - a.x, 0, b.z - a.z).unit;
        final nrm = _V3(-tan.z, 0, tan.x);
        left.add(cam.project(_V3(p.x + nrm.x * halfWidth, y, p.z + nrm.z * halfWidth)));
        right.add(cam.project(_V3(p.x - nrm.x * halfWidth, y, p.z - nrm.z * halfWidth)));
      }
      return Path()..addPolygon([...left, ...right.reversed], true);
    }

    canvas.drawPath(ribbon(1.5, 0.01), Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawPath(ribbon(1.4, 0.02), Paint()..color = const Color(0xFF475569));
    canvas.drawPath(ribbon(0.06, 0.04), Paint()..color = const Color(0xFFFACC15));
  }

  void _house(Canvas canvas, _Cam cam, _V3 at, double s, Color wall) {
    final shadowAt = cam.project(_V3(at.x + 0.4 * s, 0, at.z - 0.2 * s));
    final k = cam.scaleAt(at);
    labGroundShadow(canvas, shadowAt, 3.2 * s * k, 1.2 * s * k, opacity: 0.22);
    _box(canvas, cam, _V3(at.x, s, at.z), _V3(2 * s, 2 * s, 2 * s), wall);
    // Square pyramid roof (4-sided cone, radius 1.8, height 1.5).
    final h = 1.8 / math.sqrt2 * s, yb = 2 * s, apex = _V3(at.x, 3.5 * s, at.z);
    final a = _V3(at.x - h, yb, at.z - h), b = _V3(at.x + h, yb, at.z - h);
    final c = _V3(at.x + h, yb, at.z + h), d = _V3(at.x - h, yb, at.z + h);
    final center = _V3(at.x, yb + 0.4 * s, at.z);
    const roof = Color(0xFFEF4444);
    for (final f in [
      [d, c, apex],
      [c, b, apex],
      [b, a, apex],
      [a, d, apex],
    ]) {
      _poly(canvas, cam, f, roof, center);
    }
    // Door and window for a friendlier look.
    final door = [
      _V3(at.x - 0.3 * s, 0, at.z + s + 0.01),
      _V3(at.x + 0.3 * s, 0, at.z + s + 0.01),
      _V3(at.x + 0.3 * s, 1.1 * s, at.z + s + 0.01),
      _V3(at.x - 0.3 * s, 1.1 * s, at.z + s + 0.01),
    ];
    canvas.drawPath(Path()..addPolygon(door.map(cam.project).toList(), true), Paint()..color = const Color(0xFF92400E));
  }

  void _tree(Canvas canvas, _Cam cam, _V3 at) {
    final k = cam.scaleAt(at);
    final base = cam.project(at);
    labGroundShadow(canvas, base.translate(0.3 * k, 0), 2.2 * k, 0.8 * k, opacity: 0.22);
    final top = cam.project(_V3(at.x, 1, at.z));
    final trunk = Path()
      ..moveTo(base.dx - 0.3 * k, base.dy)
      ..lineTo(top.dx - 0.2 * k, top.dy)
      ..lineTo(top.dx + 0.2 * k, top.dy)
      ..lineTo(base.dx + 0.3 * k, base.dy)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = LinearGradient(colors: [labShade(const Color(0xFF78350F), -0.3), const Color(0xFF78350F), labShade(const Color(0xFF78350F), 0.2)])
            .createShader(Rect.fromLTRB(base.dx - 0.3 * k, top.dy, base.dx + 0.3 * k, base.dy)),
    );
    final c = cam.project(_V3(at.x, 1.5, at.z));
    labSphere(canvas, c, 1.2 * k, const Color(0xFF22C55E), light: const Offset(0.3, -0.45), highlight: 0.3, shade: 0.45);
    // Low-poly facets of the dodecahedron.
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = labShade(const Color(0xFF22C55E), -0.35).withValues(alpha: 0.35);
    for (var i = 0; i < 5; i++) {
      final ang = i * 2 * math.pi / 5 - math.pi / 2;
      canvas.drawLine(c.translate(math.cos(ang) * 0.45 * k, math.sin(ang) * 0.45 * k),
          c.translate(math.cos(ang) * 1.18 * k, math.sin(ang) * 1.18 * k), facet);
    }
    canvas.drawPath(
      Path()
        ..addPolygon([
          for (var i = 0; i < 5; i++)
            c.translate(math.cos(i * 2 * math.pi / 5 - math.pi / 2) * 0.45 * k, math.sin(i * 2 * math.pi / 5 - math.pi / 2) * 0.45 * k),
        ], true),
      facet,
    );
  }

  /// Swati on her bicycle (HTML `createDetailedBicycleAndRider`), drawn as a
  /// side view mapped onto the road plane: local x runs along the heading,
  /// local y points up.
  void _bike(Canvas canvas, _Cam cam) {
    final p = scene.bikePos;
    final h = scene.bikeDir.unit;
    final o = cam.project(p);
    final v = cam.project(p + h) - o;
    final u = cam.project(p + const _V3(0, 1, 0)) - o;
    labGroundShadow(canvas, cam.project(_V3(p.x, 0, p.z)), v.distance * 2.4, u.distance * 0.45, opacity: 0.28);

    canvas.save();
    canvas.transform(Float64List.fromList([v.dx, v.dy, 0, 0, u.dx, u.dy, 0, 0, 0, 0, 1, 0, o.dx, o.dy, 0, 1]));

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    void line(Offset a, Offset b, Color c, double w) => canvas.drawLine(a, b, stroke(c, w));

    const frame = Color(0xFFF59E0B), silver = Color(0xFFE2E8F0), black = Color(0xFF0F172A);
    const skin = Color(0xFFFFDBAC), shorts = Color(0xFF1E3A8A), shirt = Color(0xFFF43F5E);

    // Leg angles (HTML thigh / calf pivots, rotation.x).
    final moving = scene.racing || scene.raceT > 0;
    final a = scene.pedal;
    final thL = moving ? math.sin(a) * 0.45 + 0.3 : 0.5;
    final thR = moving ? math.sin(a + math.pi) * 0.45 + 0.3 : 0.1;
    final caL = moving ? -math.cos(a).abs() * 0.5 - 0.1 : -0.6;
    final caR = moving ? -math.cos(a + math.pi).abs() * 0.5 - 0.1 : -0.2;

    void leg(double th, double ca, double shade) {
      const hip = Offset(-0.45, 1.55);
      final knee = hip + Offset(0.55 * math.sin(th), -0.55 * math.cos(th));
      final foot = knee + Offset(0.55 * math.sin(th + ca), -0.55 * math.cos(th + ca));
      line(hip, knee, labShade(shorts, shade), 0.15);
      line(knee, foot, labShade(skin, shade), 0.11);
      line(foot.translate(-0.08, -0.02), foot.translate(0.14, -0.02), labShade(Colors.white, shade), 0.1);
    }

    void wheel(Offset c) {
      canvas.drawCircle(c, 0.6, stroke(const Color(0xFF1E293B), 0.14));
      canvas.drawCircle(c, 0.53, stroke(silver, 0.05));
      for (var i = 0; i < 3; i++) {
        final ang = scene.wheelAngle + i * math.pi / 3;
        final d = Offset(math.cos(ang), math.sin(ang)) * 0.53;
        line(c - d, c + d, silver.withValues(alpha: 0.85), 0.025);
      }
      canvas.drawCircle(c, 0.08, Paint()..color = silver);
    }

    // Far leg and arm (darker), then the bicycle, then the near side.
    leg(thL, caL, -0.35);
    line(const Offset(0.2, 2.1), const Offset(0.45, 1.85), labShade(shirt, -0.3), 0.12);
    line(const Offset(0.45, 1.85), const Offset(0.7, 1.65), labShade(skin, -0.3), 0.1);

    const fw = Offset(0.9, 0.6), rw = Offset(-0.9, 0.6), bb = Offset(-0.1, 0.6);
    const seat = Offset(-0.4, 1.3), head = Offset(0.7, 1.4), stem = Offset(0.7, 1.65);
    wheel(rw);
    wheel(fw);
    line(bb, rw, frame, 0.08);
    line(seat, rw, frame, 0.08);
    line(bb, seat, frame, 0.1);
    line(bb, head, frame, 0.12);
    line(seat, head, frame, 0.1);
    line(head, fw, silver, 0.08);
    line(seat, const Offset(-0.45, 1.5), silver, 0.08);
    line(head, stem, silver, 0.08);
    line(stem, const Offset(0.82, 1.62), silver, 0.06);
    canvas.drawCircle(stem, 0.06, Paint()..color = black);
    canvas.drawCircle(bb, 0.18, Paint()..color = labShade(silver, -0.15));
    canvas.drawCircle(bb, 0.18, stroke(labShade(silver, -0.45), 0.03));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-0.45, 1.55), width: 0.45, height: 0.1), const Radius.circular(0.04)),
      Paint()..color = black,
    );

    // Rider: hips, torso, neck, head, bun, helmet, eye.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-0.45, 1.6), width: 0.32, height: 0.22), const Radius.circular(0.06)),
      Paint()..color = shorts,
    );
    leg(thR, caR, 0);
    line(const Offset(-0.45, 1.6), const Offset(0.2, 2.1), shirt, 0.36);
    line(const Offset(0.2, 2.1), const Offset(0.35, 2.45), skin, 0.14);
    canvas.drawCircle(const Offset(0.15, 2.45), 0.14, Paint()..color = const Color(0xFF1E1B18));
    canvas.drawCircle(const Offset(0.35, 2.45), 0.24, Paint()..color = skin);
    final helmet = Rect.fromCenter(center: const Offset(0.35, 2.58), width: 0.57, height: 0.36);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(helmet.left - 0.05, helmet.center.dy - 0.02, helmet.right + 0.05, helmet.bottom + 0.05));
    canvas.drawOval(helmet, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawRect(Rect.fromCenter(center: const Offset(0.35, 2.7), width: 0.5, height: 0.07), Paint()..color = const Color(0xFF3B82F6));
    canvas.restore();
    canvas.drawCircle(const Offset(0.55, 2.47), 0.03, Paint()..color = black);
    // Near arm.
    line(const Offset(0.2, 2.1), const Offset(0.45, 1.85), shirt, 0.12);
    line(const Offset(0.45, 1.85), const Offset(0.7, 1.65), skin, 0.1);
    canvas.drawCircle(const Offset(0.7, 1.65), 0.06, Paint()..color = skin);
    canvas.restore();
  }

  // ------------------------------------------------------ scenario 2

  void _paintStation(Canvas canvas, Size size) {
    final cam = _cam2;
    _paintSkyAndGround(canvas, size, cam, const Color(0xFF94A3B8));
    // Platform, shelter and pillars.
    _box(canvas, cam, const _V3(0, 1, -5), const _V3(40, 2, 8), const Color(0xFF64748B));
    for (final x in const [-8.0, 8.0]) {
      final b = cam.project(_V3(x, 2, -3)), t = cam.project(_V3(x, 5, -3));
      final k = cam.scaleAt(_V3(x, 3, -3));
      labCylinder(canvas, Rect.fromLTRB(t.dx - 0.2 * k, t.dy, t.dx + 0.2 * k, b.dy), const Color(0xFF475569), tilt: 0.3);
    }
    _box(canvas, cam, const _V3(0, 5, -5), const _V3(20, 0.5, 6), const Color(0xFFCBD5E1));
    // Tracks: sleepers and two rails.
    for (var i = -20; i < 20; i += 2) {
      _box(canvas, cam, _V3(i.toDouble(), 0.1, 2), const _V3(0.5, 0.1, 4), const Color(0xFF475569));
    }
    _box(canvas, cam, const _V3(0, 0.2, 1), const _V3(40, 0.2, 0.1), const Color(0xFFCBD5E1));
    _box(canvas, cam, const _V3(0, 0.2, 3), const _V3(40, 0.2, 0.1), const Color(0xFFCBD5E1));
    // Train group (starts off-screen at x = -25, as in the HTML).
    const tx = -25.0;
    _box(canvas, cam, const _V3(tx, 2.5, 2), const _V3(8, 4, 3), const Color(0xFF0284C7));
    _box(canvas, cam, const _V3(tx - 2, 3, 2), const _V3(2, 1.5, 3.1), const Color(0xFF0F172A));
    _box(canvas, cam, const _V3(tx + 2, 3, 2), const _V3(2, 1.5, 3.1), const Color(0xFF0F172A));

    _label(canvas, cam, tr('lbl_station'), const _V3(0, 7, -5), const Color(0xFFEAB308));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
}

/// Decorative gears inside the machine screen (HTML `.gear-spin` /
/// `.gear-spin-reverse`, one turn every 4 s).
class _GearsPainter extends CustomPainter {
  _GearsPainter({required this.time, required Listenable repaint}) : super(repaint: repaint);

  final double Function() time;

  void _gear(Canvas canvas, Offset c, double r, double angle) {
    const teeth = 8;
    final path = Path();
    for (var i = 0; i < teeth * 2; i++) {
      final a0 = angle + i * math.pi / teeth;
      final a1 = a0 + math.pi / teeth;
      final rr = i.isEven ? r : r * 0.78;
      final p0 = c + Offset(math.cos(a0 + 0.08), math.sin(a0 + 0.08)) * rr;
      final p1 = c + Offset(math.cos(a1 - 0.08), math.sin(a1 - 0.08)) * rr;
      if (i == 0) {
        path.moveTo(p0.dx, p0.dy);
      } else {
        path.lineTo(p0.dx, p0.dy);
      }
      path.lineTo(p1.dx, p1.dy);
    }
    path.close();
    path.addOval(Rect.fromCircle(center: c, radius: r * 0.3));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = const Color(0xFF334155));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = time();
    final big = size.height * 0.5;
    _gear(canvas, Offset(big * 0.55, size.height - big * 0.55), big, t * 2 * math.pi / 4);
    final small = size.height * 0.32;
    _gear(canvas, Offset(big * 0.55 + big * 1.25, size.height - small * 1.4), small, -t * 2 * math.pi / 4);
  }

  @override
  bool shouldRepaint(covariant _GearsPainter old) => false;
}

/// HTML `#speedometer-widget` dial: coloured ring, needle and hub.
class _SpeedoPainter extends CustomPainter {
  _SpeedoPainter({required this.needleDeg, required this.isDark});

  final double needleDeg; // -90 = 0, +90 = max
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = isDark ? _Colors.slate800 : Colors.white);
    canvas.drawCircle(
      c,
      r - r * 0.03,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = isDark ? _Colors.slate600 : _Colors.slate300,
    );
    final ring = Rect.fromCircle(center: c, radius: r * 0.8);
    const cols = [Color(0xFFEF4444), Color(0xFFEAB308), Color(0xFF22C55E), Color(0xFF3B82F6)];
    for (var i = 0; i < 4; i++) {
      canvas.drawArc(
        ring,
        -math.pi / 2 + i * math.pi / 2,
        math.pi / 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.07
          ..color = cols[i].withValues(alpha: 0.5),
      );
    }
    final a = needleDeg * math.pi / 180;
    canvas.drawLine(
      c,
      c + Offset(math.sin(a), -math.cos(a)) * (r * 0.75),
      Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = math.max(2, r * 0.07)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, r * 0.09, Paint()..color = isDark ? Colors.white : _Colors.slate900);
  }

  @override
  bool shouldRepaint(covariant _SpeedoPainter old) => old.needleDeg != needleDeg || old.isDark != isDark;
}

/// Dashed rounded border for the empty machine slots.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius, required this.width});

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    labDashedPath(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius((Offset.zero & size).deflate(width / 2), Radius.circular(radius))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 6,
      gap: 4,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius || old.width != width;
}

// ======================================================================== UI

// HTML colours used by the 2D interactive layer.
const Color _blue500 = Color(0xFF3B82F6);
const Color _blue600 = Color(0xFF2563EB);
const Color _blue700 = Color(0xFF1D4ED8);
const Color _green500 = Color(0xFF22C55E);
const Color _green700 = Color(0xFF15803D);
const Color _indigo500 = Color(0xFF6366F1);
const Color _indigo600 = Color(0xFF4F46E5);
const Color _indigo700 = Color(0xFF4338CA);
const Color _machineBodyColor = Color(0xFF94A3B8);
const Color _machineScreen = Color(0xFF1E293B);
const Color _machineSlot = Color(0xFF334155);
const Color _yellow400 = Color(0xFFFACC15);
const Color _yellow700 = Color(0xFFA16207);

/// HTML `font-digital` (monospace). Uses the lab font override when one is
/// set (headless screenshot tests have no "monospace" family).
String get _monoFamily => LabFont.active.family ?? 'monospace';

/// Clock-slider thumb (HTML: 28 px yellow knob with a white ring).
class _RingThumb extends SliderComponentShape {
  const _RingThumb(this.radius);
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
    final c = context.canvas;
    c.drawCircle(
      center.translate(0, 1.5),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    c.drawCircle(center, radius, Paint()..color = _Colors.zslYellow);
    c.drawCircle(
      center,
      radius - radius * 0.11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.22
        ..color = Colors.white,
    );
  }
}

extension _A3Ui on _Ch8A3MeasuringAndCalculatingSpeedPageState {
  /// The HTML `#ui-layer`: meters / journey planner on the left, the
  /// calculation machine (with its panel tray) on the right, the main action
  /// button at the bottom and the railway timetable modal.
  Widget _uiLayer(BuildContext context, Size canvas, LabPalette p, double s) {
    final sc = _scene;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final open = _lab.isSidebarOpen;
    // Room for the HUD while the sidebar is open (kept after the HUD hides at
    // the end so the machine does not jump).
    final bottom = inset.bottom + (open ? 58 * s : 0);
    final right = inset.right;
    var left = open ? 8.0 : inset.left;
    // Too narrow beside the floating mission card: let the card overlap
    // (it can be minimised).
    if (!open && canvas.width - left - right < 360 * s) left = 84 + pad.left;
    final top = inset.top;
    final regionW = math.max(0.0, canvas.width - left - right);
    final regionH = math.max(0.0, canvas.height - top - bottom);
    final hasCol = sc.metersVisible || sc.plannerVisible || sc.resultShown;
    final colW = hasCol ? math.min(regionW * 0.42, (sc.scenario == 0 ? 136 : 206) * s) : 0.0;
    final gap = hasCol ? 10 * s : 0.0;

    return Stack(
      children: [
        if (hasCol)
          Positioned(
            left: left,
            top: top,
            width: colW,
            height: regionH,
            child: Align(
              alignment: Alignment.topLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: colW,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sc.metersVisible) _meters(p, s),
                      if (sc.plannerVisible) _planner(p, s),
                      if (sc.resultShown) ...[
                        SizedBox(height: 10 * s),
                        _speedometer(p, s),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (sc.machineVisible)
          Positioned(
            left: left + colW + gap,
            top: top,
            right: right,
            height: regionH,
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: _machineColumn(p, s)),
            ),
          ),
        if (sc.mainVisible && sc.step == 1)
          Positioned(
            left: left,
            right: right,
            bottom: bottom + 18 * s,
            child: Center(
              child: LabActionButton(
                action: _mainAction(),
                scale: s * 1.15,
                expand: false,
              ),
            ),
          ),
        if (sc.timetableOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: right - 4,
            child: _timetable(p, s, canvas.width - right + 4),
          ),
      ],
    );
  }

  LabAction _mainAction() {
    final s1 = _scene.scenario == 0;
    return LabAction(
      label: s1 ? _t('btn_start_race') : _t('btn_view_timetable'),
      icon: s1 ? Icons.play_arrow_rounded : Icons.calendar_month,
      color: _indigo600,
      foreground: Colors.white,
      highlight: true,
      onTap: _triggerMain,
    );
  }

  // ------------------------------------------------------------ meters

  Widget _meter(LabPalette p, double s, IconData icon, Color accent, String label, String value, String unit) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9 * s),
      child: Container(
        decoration: BoxDecoration(
          color: p.panel,
          border: Border(left: BorderSide(color: accent, width: 4 * s)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20 * s),
            SizedBox(width: 9 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(color: _Colors.slate500, fontSize: 8.5 * s, fontWeight: FontWeight.w800),
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(fontSize: 19 * s, fontWeight: FontWeight.w800, fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback),
                      ),
                      TextSpan(text: ' $unit', style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w700)),
                    ]),
                    style: TextStyle(color: p.textStrong, height: 1.15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `#status-meters` (distance / time, updated during the ride).
  Widget _meters(LabPalette p, double s) {
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, _, _) {
        final t = _scene.raceT;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _meter(p, s, Icons.straighten, _blue500, _t('distance'), (3.6 * t).toStringAsFixed(1), _t('u_km')),
            SizedBox(height: 8 * s),
            _meter(p, s, Icons.schedule, _green500, _t('time'), '${(15 * t + 1e-9).floor()}', _t('u_min')),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------- speedometer

  /// HTML `#speedometer-widget`: scales in, needle sweeps for 1 s.
  Widget _speedometer(LabPalette p, double s) {
    final s1 = _scene.scenario == 0;
    final val = s1 ? 4 : 90;
    final max = s1 ? 10 : 120;
    final target = -90 + val / max * 180;
    final size = 112 * s;
    return Center(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('speedo-${_scene.scenario}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
        builder: (context, v, _) {
          final scale = Curves.easeOutBack.transform((v * 2).clamp(0.0, 1.0));
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: CustomPaint(
                painter: _SpeedoPainter(needleDeg: -90 + (target + 90) * v, isDark: p.isDark),
                // Value sits in the lower half, clear of the sweeping needle.
                child: Align(
                  alignment: const Alignment(0, 0.62),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$val',
                        style: TextStyle(
                          color: p.isDark ? Colors.white : _Colors.slate900,
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w800,
                          fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback,
                          height: 1,
                        ),
                      ),
                      Text(
                        (s1 ? _t('u_mps') : _t('u_kmph')).toUpperCase(),
                        style: TextStyle(color: _Colors.slate500, fontSize: 9 * s, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------- machine

  Widget _pill(String text, Color color, double s, {bool lifted = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: _Colors.slate700, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4D000000),
            blurRadius: lifted ? 14 : 6,
            offset: Offset(0, lifted ? 6 : 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14 * s, fontFamily: LabFont.active.family),
      ),
    );
  }

  /// HTML `.draggable-pill`: follows the finger, snaps into the matching
  /// slot or jumps back with an error sound.
  Widget _draggablePill(String type, String text, Color color, double s) {
    return Draggable<String>(
      data: type,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Transform.scale(scale: 1.05, child: _pill(text, color, s, lifted: true)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _pill(text, color, s)),
      onDragStarted: () => _Audio.play(_Sound.pickup),
      onDragEnd: (d) => _onPillDropped(type, d.offset),
      child: _pill(text, color, s),
    );
  }

  /// Panel tray, machine (with the protruding Calculate handle) and the
  /// result badge below it.
  Widget _machineColumn(LabPalette p, double s) {
    final sc = _scene;
    final s1 = sc.scenario == 0;
    final distText = s1 ? '3.6 ${_t('u_km')}' : '180 ${_t('u_km')}';
    final timeText = s1 ? '15 ${_t('u_min')}' : '2 ${_t('u_h')}';
    return SizedBox(
      width: 344 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 46 * s,
            child: sc.pillsVisible
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!sc.distDropped) _draggablePill('distance', distText, s1 ? _blue500 : _blue600, s),
                      if (!sc.distDropped && !sc.timeDropped) SizedBox(width: 18 * s),
                      if (!sc.timeDropped) _draggablePill('time', timeText, s1 ? _green500 : _indigo600, s),
                    ],
                  )
                : null,
          ),
          TweenAnimationBuilder<double>(
            key: ValueKey('machine-${sc.scenario}'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.95 + 0.05 * v, child: child),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _machineBody(p, s),
                SizedBox(width: 64 * s, child: _handle(s)),
              ],
            ),
          ),
          SizedBox(height: 50 * s, child: Center(child: _resultBadge(s))),
        ],
      ),
    );
  }

  Widget _slotChip(String text, Color color, Color border, double s, {bool glow = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6 * s),
        border: Border.all(color: border, width: 2),
        boxShadow: [if (glow) const BoxShadow(color: Color(0xFFEAB308), blurRadius: 15)],
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14 * s)),
    );
  }

  Widget _slot(GlobalKey key, String placeholder, Widget? chip, bool highlight, double s) {
    return Container(
      key: key,
      height: 50 * s,
      decoration: BoxDecoration(
        color: highlight ? Color.alphaBlend(_Colors.zslYellow.withValues(alpha: 0.2), _machineSlot) : _machineSlot,
        borderRadius: BorderRadius.circular(12 * s),
        border: highlight ? Border.all(color: _Colors.zslYellow, width: 2) : null,
        boxShadow: [if (highlight) BoxShadow(color: _Colors.zslYellow.withValues(alpha: 0.35), blurRadius: 10)],
      ),
      child: CustomPaint(
        foregroundPainter: highlight
            ? null
            : _DashedRRectPainter(color: const Color(0xFF64748B), radius: 12 * s, width: 2),
        child: Center(
          child: chip ??
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * s),
                child: Text(
                  placeholder.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _Colors.slate400, fontSize: 10 * s, fontWeight: FontWeight.w800),
                ),
              ),
        ),
      ),
    );
  }

  Widget _machineBody(LabPalette p, double s) {
    final sc = _scene;
    final s1 = sc.scenario == 0;
    Widget? distChip, timeChip;
    if (sc.distDropped) {
      distChip = s1
          ? _slotChip(sc.converted ? '3600 ${_t('u_m')}' : '3.6 ${_t('u_km')}', _blue500, _blue700, s, glow: sc.converted)
          : _slotChip('180 ${_t('u_km')}', _blue500, _blue700, s);
    }
    if (sc.timeDropped) {
      timeChip = s1
          ? _slotChip(sc.converted ? '900 ${_t('u_s')}' : '15 ${_t('u_min')}', _green500, _green700, s, glow: sc.converted)
          : _slotChip('2 ${_t('u_h')}', _indigo500, _indigo700, s);
    }
    return Container(
      width: 280 * s,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_machineBodyColor, 0.12), _machineBodyColor, labShade(_machineBodyColor, -0.12)],
        ),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: _Colors.slate500, width: 3 * s),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 18))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 7 * s),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _Colors.slate300, width: 2 * s))),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _t('calc_machine').toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13 * s,
                  // Tracking splits Devanagari conjuncts, so English only.
                  letterSpacing: _lab.lang == LabLang.en ? 2.5 : 0,
                  shadows: const [Shadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1))],
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _slot(_distSlotKey, _t('drop_dist'), distChip, s1 && sc.distDropped, s),
                    SizedBox(height: 10 * s),
                    _slot(_timeSlotKey, _t('drop_time'), timeChip, s1 && sc.timeDropped, s),
                  ],
                ),
              ),
              if (sc.leverVisible) SizedBox(width: 60 * s, child: Center(child: _lever(s))),
            ],
          ),
          SizedBox(height: 14 * s),
          _screen(s),
        ],
      ),
    );
  }

  /// HTML `#btn-convert` (scenario 1, step 3).
  Widget _lever(double s) {
    final pressed = _scene.leverPressed;
    return GestureDetector(
      onTap: pressed ? null : _convert,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: pressed ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, pressed ? 16 * s : 0, 0),
          width: 44 * s,
          height: 88 * s,
          decoration: BoxDecoration(
            color: _Colors.red600,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0xFF991B1B), width: 2),
            boxShadow: [if (!pressed) BoxShadow(color: const Color(0xFF991B1B), offset: Offset(0, 5 * s))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20 * s),
              SizedBox(height: 3 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3 * s),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _t('convert').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 8.5 * s, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Machine screen with spinning gears and the fraction display.
  Widget _screen(double s) {
    final sc = _scene;
    final s1 = sc.scenario == 0;
    final mono = TextStyle(color: Colors.white, fontSize: 22 * s, fontWeight: FontWeight.w800, fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback);
    return Container(
      height: 100 * s,
      decoration: BoxDecoration(
        color: _machineScreen,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _machineSlot, width: 4 * s),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * s),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _GearsPainter(time: () => _scene.time, repaint: _frame)),
            ),
            if (sc.handlePulled)
              Center(
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 3 * s),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 4 * s))),
                        child: Text(
                          s1 ? '3600 ${_t('u_m')}' : '180 ${_t('u_km')}',
                          textAlign: TextAlign.center,
                          style: mono,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(s1 ? '900 ${_t('u_s')}' : '2 ${_t('u_h')}', textAlign: TextAlign.center, style: mono),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// HTML `#calculate-handle-container`: grey bar with the yellow ball and
  /// the bouncing "Calculate" badge. Pressing anywhere on it pulls it.
  Widget _handle(double s) {
    final sc = _scene;
    if (!sc.handleVisible) return SizedBox(height: 168 * s);
    final pulled = sc.handlePulled;
    return Listener(
      onPointerDown: (_) => _calculate(),
      child: SizedBox(
        height: 168 * s,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 30 * s,
              bottom: 4 * s,
              width: 18 * s,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_Colors.slate400, _Colors.slate300, _Colors.slate400]),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(8 * s)),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: 2 * s,
              top: (pulled ? 96 : 32) * s,
              child: Container(
                width: 56 * s,
                height: 56 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _Colors.zslYellow,
                  border: Border.all(color: _yellow700, width: 3 * s),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: _Colors.slate900, size: 18 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5 * s),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _t('calculate').toUpperCase(),
                          style: TextStyle(color: _Colors.slate900, fontSize: 7.5 * s, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!pulled)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, t, child) => Transform.translate(
                    offset: Offset(0, -5 * s * (math.sin(t * math.pi)).abs()),
                    child: child,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 3 * s),
                    decoration: BoxDecoration(
                      color: _yellow400,
                      borderRadius: BorderRadius.circular(6 * s),
                      border: Border.all(color: _yellow700, width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8)],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('calculate').toUpperCase(),
                            style: TextStyle(color: _Colors.slate900, fontSize: 9.5 * s, fontWeight: FontWeight.w900),
                          ),
                          Icon(Icons.arrow_downward_rounded, size: 11 * s, color: _Colors.slate900),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// HTML `#result-popup` (green badge below the machine).
  Widget _resultBadge(double s) {
    if (!_scene.resultShown) return const SizedBox.shrink();
    final s1 = _scene.scenario == 0;
    return TweenAnimationBuilder<double>(
      key: ValueKey('result-${_scene.scenario}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: _Colors.green,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: _green700, width: 3 * s),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20 * s),
            SizedBox(width: 8 * s),
            Text(
              s1 ? '4 ${_t('u_mps')}' : '90 ${_t('u_kmph')}',
              style: TextStyle(color: Colors.white, fontSize: 20 * s, fontWeight: FontWeight.w800, fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------- journey planner

  Widget _plannerRow(String label, Widget value, double s, double slotW) {
    return Container(
      margin: EdgeInsets.only(top: 7 * s),
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
      decoration: BoxDecoration(color: _Colors.slate700, borderRadius: BorderRadius.circular(5 * s)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: _Colors.slate300, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            width: slotW,
            height: 26 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _Colors.slate900,
              borderRadius: BorderRadius.circular(4 * s),
              border: Border.all(color: _Colors.slate600),
            ),
            child: FittedBox(fit: BoxFit.scaleDown, child: value),
          ),
        ],
      ),
    );
  }

  /// HTML `#journey-planner` with the clock-slider section (scenario 2).
  Widget _planner(LabPalette p, double s) {
    final sc = _scene;
    final mono = TextStyle(color: Colors.white, fontSize: 11.5 * s, fontWeight: FontWeight.w700, fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback);
    final atEnd = sc.clock >= 12 - 1e-6;
    final taken = sc.clock <= 10 + 1e-6 ? '0' : (atEnd ? '2' : (sc.clock - 10).toStringAsFixed(1));
    return TweenAnimationBuilder<double>(
      key: const ValueKey('planner'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.95 + 0.05 * v, alignment: Alignment.topLeft, child: child),
      ),
      child: Container(
        padding: EdgeInsets.all(10 * s),
        decoration: BoxDecoration(
          color: _Colors.slate800,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: _Colors.slate600, width: 3 * s),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 6 * s),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _Colors.slate600))),
              child: Text(
                _t('journey_planner'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13 * s, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(height: 3 * s),
            _plannerRow(
              _t('distance'),
              Text('180 ${_t('u_km')}', style: TextStyle(color: const Color(0xFF60A5FA), fontSize: 12 * s, fontWeight: FontWeight.w800)),
              s,
              72 * s,
            ),
            _plannerRow(_t('departure'), Text(_t('t_1000am'), style: mono), s, 88 * s),
            _plannerRow(_t('arrival'), Text(_t('t_1200pm'), style: mono), s, 88 * s),
            if (sc.clockVisible)
              IgnorePointer(
                ignoring: sc.clockUsed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: sc.clockUsed ? 0.5 : 1,
                  child: Container(
                    margin: EdgeInsets.only(top: 10 * s),
                    padding: EdgeInsets.only(top: 8 * s),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: _Colors.slate600))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _t('calc_time_taken'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _Colors.zslYellow, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 7 * s,
                            activeTrackColor: _Colors.slate600,
                            inactiveTrackColor: _Colors.slate600,
                            thumbShape: _RingThumb(12 * s),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 18 * s),
                            overlayColor: _Colors.zslYellow.withValues(alpha: 0.2),
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                            showValueIndicator: ShowValueIndicator.never,
                          ),
                          child: Slider(
                            value: sc.clock,
                            min: 10,
                            max: 12,
                            divisions: 20,
                            onChanged: _updateClock,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * s),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final k in const ['t_1000am', 't_1200pm'])
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _t(k),
                                      style: TextStyle(color: _Colors.slate400, fontSize: 9.5 * s, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 5 * s),
                            decoration: BoxDecoration(
                              color: _Colors.slate900,
                              borderRadius: BorderRadius.circular(8 * s),
                              border: Border.all(color: _Colors.slate700),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _t('time_taken').toUpperCase(),
                                  style: TextStyle(color: _Colors.slate500, fontSize: 8.5 * s, fontWeight: FontWeight.w700),
                                ),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text: taken,
                                      style: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.w800, fontFamily: _monoFamily, fontFamilyFallback: LabFont.active.fallback),
                                    ),
                                    TextSpan(text: ' ${_t('u_h')}', style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w700)),
                                  ]),
                                  style: const TextStyle(color: Colors.white, height: 1.15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (atEnd) ...[
                          SizedBox(height: 8 * s),
                          LabActionButton(
                            action: LabAction(
                              label: _t('use_this_time'),
                              color: _indigo600,
                              foreground: Colors.white,
                              silent: true,
                              onTap: _useThisTime,
                            ),
                            scale: s * 0.9,
                            dense: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------- timetable

  /// HTML `#timetable-modal`: railway timetable with the Express Train row.
  Widget _timetable(LabPalette p, double s, double width) {
    final sc = _scene;
    final cardW = math.min(width - 24, 600 * s);
    final cell = TextStyle(color: Colors.white, fontSize: 12 * s, fontWeight: FontWeight.w500);
    final bold = cell.copyWith(fontWeight: FontWeight.w800);
    final head = TextStyle(color: _Colors.slate300, fontSize: 11.5 * s, fontWeight: FontWeight.w800);
    Widget c(String text, TextStyle st) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          child: Text(text, style: st),
        );
    final table = Table(
      border: TableBorder.all(color: _Colors.slate600),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(0.9)},
      children: [
        TableRow(
          decoration: const BoxDecoration(color: _Colors.slate700),
          children: [c(_t('train_name'), head), c(_t('departure'), head), c(_t('arrival'), head), c(_t('distance'), head)],
        ),
        TableRow(children: [c(_t('train_local'), cell), c(_t('t_0800am'), cell), c(_t('t_1130am'), cell), c('120 ${_t('u_km')}', cell)]),
        TableRow(
          decoration: BoxDecoration(
            color: sc.rowExtracted
                ? _Colors.green.withValues(alpha: 0.5)
                : _Colors.zslYellow.withValues(alpha: 0.2),
            border: Border.all(color: _Colors.zslYellow, width: 2),
          ),
          children: [
            c(_t('train_express'), bold.copyWith(color: _Colors.zslYellow)),
            c(_t('t_1000am'), bold),
            c(_t('t_1200pm'), bold),
            c('180 ${_t('u_km')}', bold),
          ],
        ),
        TableRow(children: [c(_t('train_night'), cell), c(_t('t_0900pm'), cell), c(_t('t_0500am'), cell), c('450 ${_t('u_km')}', cell)]),
      ],
    );
    final tableW = math.max(cardW - 32 * s, 430 * s);
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: ColoredBox(color: _Colors.slate900.withValues(alpha: 0.8)),
            ),
          ),
        ),
        Center(
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('timetable'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.95 + 0.05 * v, child: child),
            ),
            child: Container(
              width: cardW,
              margin: EdgeInsets.symmetric(vertical: 12 * s),
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: _Colors.slate800,
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(color: _Colors.slate600, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 30)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 8 * s),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _Colors.slate600))),
                      child: Row(
                        children: [
                          Icon(Icons.train, color: _Colors.zslYellow, size: 20 * s),
                          SizedBox(width: 8 * s),
                          Expanded(
                            child: Text(
                              _t('railway_timetable'),
                              style: TextStyle(color: _Colors.zslYellow, fontSize: 16 * s, fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: _t('close'),
                            visualDensity: VisualDensity.compact,
                            onPressed: _closeTimetable,
                            icon: Icon(Icons.close, color: _Colors.slate400, size: 20 * s),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: tableW, child: table),
                    ),
                    SizedBox(height: 14 * s),
                    Center(
                      child: LabActionButton(
                        action: LabAction(
                          label: _t('extract_data'),
                          color: _Colors.zslYellow,
                          enabled: !sc.rowExtracted,
                          silent: true,
                          onTap: _extractData,
                        ),
                        scale: s,
                        expand: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
