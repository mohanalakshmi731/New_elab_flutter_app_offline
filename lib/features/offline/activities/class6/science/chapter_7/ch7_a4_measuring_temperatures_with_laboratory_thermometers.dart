// Imported from new-elab-app-6; Class 6 local activity.
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

/// Class 6 Science • Chapter 7 • Activity 4
/// Measuring Temperatures with Laboratory Thermometers.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A4-Measuring_Temperatures_with_Laboratory_Thermometers.html`.
///
/// Scenario 1 (Measuring Warm Water): drag the beaker onto the lab table and
/// the kettle over it to pour warm water, drop the laboratory thermometer in
/// the middle of the water, watch the red column rise and stop, read 60 °C
/// through the magnifying glass while the bulb is still in the water, then
/// pull the thermometer up and out and watch the column fall.
///
/// Scenario 2 (Melting Ice & Boiling Water): put the beaker of crushed ice
/// on the table, drop the thermometer into the ice and watch it stay at
/// 0 °C while the ice melts; move the beaker onto the tripod stand, light
/// the Bunsen burner, drop the thermometer into the boiling water and watch
/// it stay at 100 °C.
class Ch7A4MeasuringTemperaturesWithLaboratoryThermometersPage
    extends StatefulWidget {
  const Ch7A4MeasuringTemperaturesWithLaboratoryThermometersPage({super.key});

  @override
  State<Ch7A4MeasuringTemperaturesWithLaboratoryThermometersPage>
  createState() => _ThermometerLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesised four tones with WebAudio; they
/// map to: `pop` → pop.mp3, `success` (water poured, thermometer placed) →
/// correct.mp3, `error` (thermometer placed wrongly) → error.mp3; the
/// conclusion plays success.mp3.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML `playSound('success')`: water poured, thermometer placed.
  correct('audio/class6/science/correct.mp3'),

  /// HTML `playSound('error')`: thermometer dropped at the side.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed (conclusion popup).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `playSound('pop')`: beaker placed, magnifier, burner, buttons.
  pop('audio/class6/science/pop.mp3');

  const _Sound(this.asset);
  final String asset;

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
        AssetSource(sound.asset),
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
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // HTML accent
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color orange500 = Color(0xFFF97316);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `scene.background` (0x020617).
  static const Color sceneBg = slate950;

  /// Back wall `MeshStandardMaterial({color: 0x0f172a})`.
  static const Color wall = slate900;

  /// Lab table `0x1e293b` (dark slate 800).
  static const Color table = slate800;

  /// Beaker glass `0xe0f2fe` and its rim highlight.
  static const Color glass = Color(0xFFE0F2FE);

  /// Water `0x3b82f6`.
  static const Color water = blue500;

  /// Thermometer bulb / alcohol column `0xef4444` and the white glass tube
  /// (the HTML drag icon's `#f8fafc` tube with `#64748b` scale marks).
  static const Color alcohol = red500;
  static const Color tube = Color(0xFFF8FAFC);
  static const Color tubeMark = slate500;

  /// Tripod `0x475569`, burner base (brass) `0xd97706`, burner tube
  /// `0x94a3b8`, wire gauze.
  static const Color tripod = slate600;
  static const Color brass = Color(0xFFD97706);
  static const Color burnerTube = slate400;
  static const Color gauze = slate500;

  /// Flame: outer cone `0xf97316`, inner cone `0x3b82f6`.
  static const Color flameOuter = orange500;
  static const Color flameInner = blue500;

  /// Kettle (HTML drag icon SVG): body `#94a3b8`, handle `#334155`, lid
  /// `#475569`, base `#1e293b`, knob `#0f172a`.
  static const Color kettleBody = slate400;
  static const Color kettleHandle = slate700;
  static const Color kettleLid = slate600;
  static const Color kettleBase = slate800;
  static const Color kettleKnob = slate900;

  /// Soft contact shadows on the table.
  static const Color shadow = Color(0x80000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // glass-border white / 15
    card: Color(0xCC1E293B), // slate-800 / 80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // blue-900 / 40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // blue-300 / 80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x993B82F6),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xEB0F172A),
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x993B82F6),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xF2FFFFFF),
    labelText: _Colors.slate800,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar font-size slider: 15 px, 12–22 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
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

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Each
// step keeps the HTML concept (c) and observation (o); its action (a) is
// the HTML action spelt out so it says exactly what to tap or drag (the
// HTML put that only in the HUD lines, which are kept as `sN_hud_M`). Keys
// marked "added" are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Measuring Temperatures with Laboratory Thermometers',
    'app_subtitle': 'Class 6 • Temperature and its Measurement',
    'sc1_title': 'Scenario 1: Measuring Warm Water',
    'sc2_title': 'Scenario 2: Melting Ice & Boiling Water',
    'sc1_obj':
        'To correctly use a laboratory thermometer to measure the temperature of warm water.',
    'sc2_obj':
        'To measure and observe the constant temperatures at which ice melts and water boils.',
    // Scenario 1 steps.
    's1_c1': 'Setup',
    's1_a1':
        'Drag the beaker onto the lab table, then drag the kettle over the beaker to pour warm water.',
    's1_o1': 'A beaker containing warm water (with steam) is ready.',
    's1_c2': 'Correct Placement',
    's1_a2':
        'Drag the thermometer into the beaker and drop it in the middle: it must hang vertically with its bulb in the water, not touching the sides or the bottom.',
    's1_o2':
        'Green checkmark confirms correct positioning. Bulb is surrounded by water.',
    's1_c3': 'Observation',
    's1_a3': "Watch the red liquid column rise and stop, then tap 'Next Step'.",
    's1_o3':
        'The alcohol column rises as it gains heat and stops at a specific point.',
    's1_c4': 'Reading',
    's1_a4':
        "Tap the magnifying glass to read the temperature while the bulb is still in the water, then tap 'Close'.",
    's1_o4': 'Temperature reads 60°C while still in the water.',
    's1_c5': 'Removal',
    's1_a5':
        'Drag the thermometer up and out of the beaker, and watch the liquid column.',
    's1_o5': 'The column instantly begins to fall.',
    // Scenario 2 steps.
    's2_c1': 'Ice Setup',
    's2_a1': 'Drag the beaker of crushed ice onto the lab table.',
    's2_o1': 'Crushed ice is ready for measurement.',
    's2_c2': 'Ice Measurement',
    's2_a2':
        'Drag the thermometer into the ice and drop it in the middle: it must be vertical with its bulb in the ice, not touching the sides or the bottom.',
    's2_o2': 'Temperature drops rapidly.',
    's2_c3': 'Constant Temp (Melting)',
    's2_a3': "Watch the reading while the ice melts, then tap 'Next Setup'.",
    's2_o3': 'Temperature remains perfectly steady at 0°C.',
    's2_c4': 'Boiling Setup',
    's2_a4':
        'Drag the beaker onto the tripod stand, then tap the flame icon to light the burner.',
    's2_o4': 'Water begins to heat and vigorously boil.',
    's2_c5': 'Boiling Measurement',
    's2_a5':
        'Drag the thermometer into the boiling water and drop it in the middle: it must be vertical with its bulb in the water, not touching the sides or the bottom.',
    's2_o5': 'Temperature rises rapidly.',
    's2_c6': 'Constant Temp (Boiling)',
    's2_a6':
        "Watch the reading while the water boils, then tap 'Observe Conclusion'.",
    's2_o6': 'Temperature remains perfectly steady at 100°C.',
    // HUD "Current Task" lines (HTML `hud`).
    's1_hud_1':
        'Step 1: DRAG the Beaker to the table. Then DRAG the Kettle over it to pour warm water.',
    's1_hud_2':
        'Step 2: DRAG the Thermometer into the beaker. Ensure it is vertical and NOT touching the bottom.',
    's1_hud_3':
        "Step 3: OBSERVE the red liquid column rise and stabilize. Tap 'Next Step'.",
    's1_hud_4':
        'Step 4: TAP the Magnifying Glass to read the temperature WHILE immersed.',
    's1_hud_5':
        'Step 5: DRAG the thermometer UP and OUT of the beaker. Observe the fall.',
    's2_hud_1': 'Step 1: DRAG the Beaker of Crushed Ice to the table.',
    's2_hud_2': 'Step 2: DRAG the Thermometer into the ice correctly.',
    's2_hud_3':
        "Step 3: OBSERVE the temperature as ice melts. Tap 'Next Setup'.",
    's2_hud_4': 'Step 4: DRAG Beaker to Stand. TAP Flame icon to heat.',
    's2_hud_5': 'Step 5: DRAG Thermometer into boiling water correctly.',
    's2_hud_6':
        "Step 6: OBSERVE the temperature during boiling. Tap 'Observe Conclusion'.",
    // Conclusions (HTML `summary`).
    'sc_complete': 'Scenario {n} Complete!',
    's1_sum_title': 'Procedure Learned!',
    's1_sum':
        'You observed that the liquid column falls as soon as you remove the thermometer. This is why a laboratory thermometer must be read while its bulb is still immersed in the substance.',
    's2_sum_title': 'Fixed Points Discovered!',
    's2_sum':
        'You found that ice melts at a constant 0°C and water boils at a constant 100°C. The temperature does not change during these changes of state!',
    // Buttons.
    'btn_next': 'Next Step',
    'btn_next_setup': 'Next Setup',
    'btn_conclude': 'Observe Conclusion',
    'close': 'Close',
    // Toasts.
    'toast_drag_table': 'Drag object to the Lab Table',
    'toast_drag_beaker': 'Drag into the Beaker correctly',
    'toast_click_icon': 'Tap the highlighted icon',
    'toast_drag_stand': 'Drag Beaker to the Stand',
    'toast_error_vertical':
        'Thermometer must be vertical and NOT touch sides/bottom!',
    'toast_drag_out': 'Drag the Thermometer UP and OUT of the beaker',
    // Added: the bulb was dropped above the water / ice.
    'toast_dip_bulb': 'Lower the thermometer: its bulb must be fully dipped!',
    // 3D labels.
    'lbl_beaker': 'Beaker',
    'lbl_thermo': 'Thermometer',
    'lbl_tripod': 'Tripod Stand',
    'lbl_burner': 'Bunsen Burner',
    'lbl_kettle': 'Kettle',
    // Teacher-board accordion.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'The result appears once you complete this step.',
    'zoom_title': 'Magnified Reading',
    'tip_magnifier': 'Magnifying Glass',
    'tip_flame': 'Light the Burner',
    'unit_c': '°C',
    'scene_s1':
        'Lab table with a beaker, a kettle of warm water and a laboratory thermometer',
    'scene_s2':
        'Lab table with a beaker of crushed ice, a laboratory thermometer, a tripod stand and a Bunsen burner',
  },
  'hi': {
    'app_title': 'प्रयोगशाला थर्मामीटर से तापमान मापना',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'sc1_title': 'परिदृश्य 1: गर्म पानी मापना',
    'sc2_title': 'परिदृश्य 2: पिघलती बर्फ और उबलता पानी',
    'sc1_obj':
        'गर्म पानी का तापमान मापने के लिए प्रयोगशाला थर्मामीटर का सही उपयोग करना।',
    'sc2_obj': 'बर्फ पिघलने और पानी उबलने के स्थिर तापमान को मापना और देखना।',
    's1_c1': 'सेटअप',
    's1_a1':
        'बीकर को खींचकर प्रयोगशाला की मेज़ पर रखें, फिर गर्म पानी डालने के लिए केतली को बीकर के ऊपर खींचें।',
    's1_o1': 'गर्म पानी (भाप के साथ) वाला एक बीकर तैयार है।',
    's1_c2': 'सही स्थान',
    's1_a2':
        'थर्मामीटर को खींचकर बीकर के बीच में छोड़ें: वह सीधा लटका रहे, उसका बल्ब पानी में डूबा रहे और किनारों या तल को न छुए।',
    's1_o2':
        'हरा चेकमार्क सही स्थिति की पुष्टि करता है। बल्ब पानी से घिरा हुआ है।',
    's1_c3': 'अवलोकन',
    's1_a3':
        "लाल तरल के कॉलम को ऊपर उठते और रुकते हुए देखें, फिर 'अगला चरण' पर टैप करें।",
    's1_o3':
        'अल्कोहल कॉलम गर्मी पाकर ऊपर उठता है और एक विशिष्ट बिंदु पर रुक जाता है।',
    's1_c4': 'रीडिंग',
    's1_a4':
        "बल्ब के पानी में रहते हुए ही तापमान पढ़ने के लिए आवर्धक कांच पर टैप करें, फिर 'बंद करें' पर टैप करें।",
    's1_o4': 'पानी में रहते हुए तापमान 60°C पढ़ता है।',
    's1_c5': 'निकालना',
    's1_a5':
        'थर्मामीटर को ऊपर खींचकर बीकर से बाहर निकालें और तरल के कॉलम को देखें।',
    's1_o5': 'कॉलम तुरंत नीचे गिरने लगता है।',
    's2_c1': 'बर्फ सेटअप',
    's2_a1': 'कुचली हुई बर्फ वाले बीकर को खींचकर प्रयोगशाला की मेज़ पर रखें।',
    's2_o1': 'कुचली हुई बर्फ माप के लिए तैयार है।',
    's2_c2': 'बर्फ का मापन',
    's2_a2':
        'थर्मामीटर को खींचकर बर्फ के बीच में छोड़ें: वह सीधा रहे, उसका बल्ब बर्फ में रहे और किनारों या तल को न छुए।',
    's2_o2': 'तापमान तेजी से गिरता है।',
    's2_c3': 'स्थिर तापमान (पिघलना)',
    's2_a3': "बर्फ पिघलते समय रीडिंग देखें, फिर 'अगला सेटअप' पर टैप करें।",
    's2_o3': 'तापमान 0°C पर बिल्कुल स्थिर रहता है।',
    's2_c4': 'उबलने का सेटअप',
    's2_a4':
        'बीकर को खींचकर तिपाई स्टैंड पर रखें, फिर बर्नर जलाने के लिए लौ वाले आइकन पर टैप करें।',
    's2_o4': 'पानी गर्म होने लगता है और तेजी से उबलता है।',
    's2_c5': 'उबलने का मापन',
    's2_a5':
        'थर्मामीटर को खींचकर उबलते पानी के बीच में छोड़ें: वह सीधा रहे, उसका बल्ब पानी में डूबा रहे और किनारों या तल को न छुए।',
    's2_o5': 'तापमान तेजी से बढ़ता है।',
    's2_c6': 'स्थिर तापमान (उबलना)',
    's2_a6': "पानी उबलते समय रीडिंग देखें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's2_o6': 'तापमान 100°C पर बिल्कुल स्थिर रहता है।',
    's1_hud_1':
        'चरण 1: बीकर को टेबल पर खींचें। फिर गर्म पानी डालने के लिए केतली को उसके ऊपर खींचें।',
    's1_hud_2':
        'चरण 2: थर्मामीटर को बीकर में खींचें। सुनिश्चित करें कि यह सीधा है और तल को नहीं छू रहा है।',
    's1_hud_3':
        "चरण 3: लाल तरल को ऊपर उठते और स्थिर होते हुए देखें। 'अगला चरण' पर टैप करें।",
    's1_hud_4':
        'चरण 4: डूबे रहने के दौरान तापमान पढ़ने के लिए आवर्धक कांच पर टैप करें।',
    's1_hud_5':
        'चरण 5: थर्मामीटर को ऊपर खींचकर बीकर से बाहर निकालें। तरल के गिरने का निरीक्षण करें।',
    's2_hud_1': 'चरण 1: कुचली हुई बर्फ के बीकर को टेबल पर खींचें।',
    's2_hud_2': 'चरण 2: थर्मामीटर को बर्फ में सही ढंग से खींचें।',
    's2_hud_3':
        "चरण 3: बर्फ पिघलते समय तापमान का निरीक्षण करें। 'अगला सेटअप' पर टैप करें।",
    's2_hud_4':
        'चरण 4: बीकर को स्टैंड पर खींचें। गर्म करने के लिए फ्लेम आइकन पर टैप करें।',
    's2_hud_5': 'चरण 5: थर्मामीटर को उबलते पानी में सही ढंग से खींचें।',
    's2_hud_6':
        "चरण 6: उबलने के दौरान तापमान का निरीक्षण करें। 'निष्कर्ष देखें' पर टैप करें।",
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_sum_title': 'प्रक्रिया सीखी!',
    's1_sum':
        'आपने देखा कि थर्मामीटर निकालते ही तरल नीचे गिरता है। इसलिए प्रयोगशाला थर्मामीटर की रीडिंग उसका बल्ब पदार्थ में डूबे रहने पर ही लेनी चाहिए।',
    's2_sum_title': 'निश्चित बिंदु खोजे गए!',
    's2_sum':
        'आपने पाया कि बर्फ 0°C के स्थिर तापमान पर पिघलती है और पानी 100°C के स्थिर तापमान पर उबलता है। अवस्था परिवर्तन के दौरान तापमान नहीं बदलता!',
    'btn_next': 'अगला चरण',
    'btn_next_setup': 'अगला सेटअप',
    'btn_conclude': 'निष्कर्ष देखें',
    'close': 'बंद करें',
    'toast_drag_table': 'वस्तु को लैब टेबल पर खींचें',
    'toast_drag_beaker': 'बीकर में सही ढंग से खींचें',
    'toast_click_icon': 'हाइलाइट किए गए आइकन पर टैप करें',
    'toast_drag_stand': 'बीकर को स्टैंड पर खींचें',
    'toast_error_vertical':
        'थर्मामीटर लंबवत होना चाहिए और किनारों/तल को नहीं छूना चाहिए!',
    'toast_drag_out': 'थर्मामीटर को ऊपर खींचकर बीकर से बाहर निकालें',
    'toast_dip_bulb':
        'थर्मामीटर को और नीचे करें: उसका बल्ब पूरी तरह डूबा होना चाहिए!',
    'lbl_beaker': 'बीकर',
    'lbl_thermo': 'थर्मामीटर',
    'lbl_tripod': 'तिपाई स्टैंड',
    'lbl_burner': 'बुनसेन बर्नर',
    'lbl_kettle': 'केतली',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'यह चरण पूरा करने पर परिणाम दिखेगा।',
    'zoom_title': 'आवर्धित रीडिंग',
    'tip_magnifier': 'आवर्धक कांच',
    'tip_flame': 'बर्नर जलाएं',
    'unit_c': '°C',
    'scene_s1': 'बीकर, गर्म पानी की केतली और प्रयोगशाला थर्मामीटर वाली मेज़',
    'scene_s2':
        'कुचली हुई बर्फ वाला बीकर, प्रयोगशाला थर्मामीटर, तिपाई स्टैंड और बुनसेन बर्नर वाली मेज़',
  },
};

/// Number of steps of each scenario (HTML `ScenariosData[n].steps`).
const List<int> _stepCounts = [5, 6];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('sc${n}_title'),
        objective: t('sc${n}_obj'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
            LabStep(
              concept: t('s${n}_c$i'),
              action: t('s${n}_a$i'),
              observation: t('s${n}_o$i'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// HTML `camera.position.set(0, 15, 45)` and `controls.target.set(0, 5,
/// 0)`. The look-at point is drawn 110 px below the stage centre (a lens
/// shift): the HTML view cut off the thermometer above the beaker on the
/// tripod, here everything from the table to the top of that thermometer
/// fits between the toasts and the HUD.
const Offset _lookAtOnStage = Offset(500, 390);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing an object (short drags must pick it up).
const double _dragSlop = 8;

/// Object labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10 px chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage. [center] is where the look-at
/// point lands on the stage.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, Offset center) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, center, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the plane `n · x = d`.
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

final _Cam _cam = _Cam(const _V(0, 15, 45), const _V(0, 5, 0), _lookAtOnStage);

/// Objects are dragged in the vertical plane z = 0 through the beaker's
/// axis (the HTML dragged flat screen icons; this keeps them in the scene's
/// perspective).
const _V _dragNormal = _V(0, 0, 1);

/// Key light `DirectionalLight` at (10, 20, 15), normalised, and the HTML
/// `AmbientLight(0xffffff, 0.4)` + `DirectionalLight(0xffffff, 0.8)`.
const _V _light = _V(0.3714, 0.7428, 0.5571);
const double _ambient = 0.4;
const double _diffuse = 0.8;

// ------------------------------------------------------------- the beaker

/// `CylinderGeometry(3, 3, 8)`: glass radius and height.
const double _beakerR = 3;
const double _beakerH = 8;

/// `CylinderGeometry(2.8, 2.8, 7)`: water radius and full height.
const double _waterR = 2.8;
const double _waterFull = 7;

/// `TorusGeometry(3, 0.15)` rim.
const double _rimTube = 0.15;

/// Water opacity (HTML 0.8–0.9) and after the ice has melted (HTML 0.5).
const double _waterAlpha = 0.72;
const double _meltAlpha = 0.5;

/// Level of the melted ice (HTML `waterLiquid.scale.y` 0.5 about the
/// middle of the beaker, i.e. floating; here it rises from the bottom and
/// covers the bulb) and of the water heated on the stand (HTML 0.8).
const double _meltLevel = 0.6;
const double _boilLevel = 0.8;

/// Top of the crushed ice (`DodecahedronGeometry` up to 1.2 at y ≤ 5.5).
const double _iceTop = 6;

/// `tableDropTarget` (0, 1, 0) marks where the beaker stands: the table
/// centre.
const _V _tableSpot = _V.zero;

/// HTML drag icons start at 20 % / 80 % of the canvas width; here they
/// stand on the table, left (beaker) and right (kettle) of the centre.
const _V _beakerHome = _V(-13, 0, 0);

/// S2 step 4: the beaker of melted ice moves aside so that the tripod
/// stand can take the table centre (the HTML put both in the same place).
const _V _sideSpot = _V(11, 0, 0);

/// `tripod.position (0, 0, 0)`, ring at y = 6 (`tripodDropTarget`).
const double _standTop = 6;

/// `TorusGeometry(3.5, 0.3)` ring and three legs `CylinderGeometry(0.2,
/// 0.2, 6)` at radius 3. The ring is wider than the beaker (r 3), so a wire
/// gauze (added) carries it.
const double _ringR = 3.5;
const double _ringTube = 0.3;
const double _legR = 0.2;
const double _legSpread = 3;
const double _gauzeHalf = 3.6;

// ------------------------------------------------------------ the burner

/// Bunsen burner: brass base `CylinderGeometry(1.5, 2, 1.5)` and tube
/// `CylinderGeometry(0.5, 0.5, 2)` at y 1.5–3.5.
const double _burnerBaseTop = 1.5;
const double _burnerBaseR = 2;
const double _burnerBaseRTop = 1.5;
const double _burnerTubeR = 0.5;
const double _burnerTubeTop = 3.5;

/// Flame: outer `ConeGeometry(0.8, 2.5)` and inner `ConeGeometry(0.4, 1.2)`
/// (centres at y 4.5 and 4.0).
const double _flameOuterR = 0.8;
const double _flameOuterBase = 3.25;
const double _flameOuterTip = 5.75;
const double _flameInnerR = 0.4;
const double _flameInnerBase = 3.4;
const double _flameInnerTip = 4.6;

// -------------------------------------------------------- the thermometer

/// Glass tube `CylinderGeometry(0.4, 0.4, 18)` from the bulb up, bulb
/// `SphereGeometry(0.6)`, alcohol `CylinderGeometry(0.15, 0.15, 16)`.
const double _tubeLen = 18;
const double _tubeR = 0.4;
const double _bulbR = 0.6;
const double _fluidR = 0.15;

/// Height of the alcohol column above the bulb centre for a temperature:
/// 0 °C at 1.6 and 100 °C at 14.4 (the HTML's first and ninth marks), so
/// the HTML column scales 0.05 / 0.25 / 0.6 / 0.95 read about 0 / 20 / 60 /
/// 100 °C. A laboratory thermometer reads −10 to 110 °C.
const double _fluidAt0 = 1.6;
const double _fluidPerDegree = 0.128;
const double _scaleMin = -10;
const double _scaleMax = 110;

/// Temperatures shown: room (HTML scale 0.25), warm water (zoom card
/// 60 °C), melting ice (0 °C), boiling water (100 °C).
const double _roomTemp = 25;
const int _warmTemp = 60;
const int _iceTemp = 0;
const int _boilTemp = 100;

/// `placeThermometerCorrectly`: the bulb hangs 3 above the beaker floor.
const double _bulbHang = 3;

/// The drag icon's home (HTML 80 % of the canvas width), bulb position.
const _V _thermoHome = _V(19, 3, 0);

/// Where the thermometer lies after it was taken out (HTML (8, 1, 0) laid
/// flat, which ran through the beaker): on the table in front of it.
const _V _lyingBulb = _V(9, _bulbR, 5.5);

/// The thermometer is out once its bulb is this far above the beaker floor
/// (clear of the rim; the HTML wanted a 60 px drag).
const double _outAbove = _beakerH + 0.6;

// ------------------------------------------------------------- the kettle

/// The kettle is the HTML drag icon (SVG 120 × 120 px) drawn 7 units wide;
/// it is placed by the SVG point (50, 65), the body centre.
const double _kettleUnit = 7 / 120;
const Offset _kettleSvgCenter = Offset(50, 65);

/// SVG base (y 111) below the body centre, in world units.
const double _kettleBaseDrop = (111 - 65) * _kettleUnit;
const _V _kettleHome = _V(13, _kettleBaseDrop, 0);

/// Pouring pose: tipped 40° so the spout (SVG (5, 40)) is over the beaker.
const _V _pourCenter = _V(3.95, 11.07, 0);
const double _pourTilt = -0.698;
const _V _spoutLocal = _V(-2.95, -0.57, 0);

// ------------------------------------------------------------ drop zones
//
// The HTML zones are fixed CSS boxes around projected points (table
// 192 × 128 px, beaker centre 64 × 128, beaker edge 160 × 192, stand
// 96 × 96). Here they are the same sizes in world units at the HTML's
// desktop scale (about 20 px per unit).

/// Beaker on the table: its base within 4.9 sideways and 4 above the spot.
const double _tableCatchX = 4.9;
const double _tableCatchY = 4;

/// Beaker on the stand: base within 3.5 of the axis, 2.5–10 high.
const double _standCatchX = 3.5;
const double _standCatchLow = 2.5;
const double _standCatchHigh = 10;

/// Kettle: its centre within 6.5 of the beaker axis and its base at most
/// 12 above the table ("over the beaker").
const double _kettleCatchX = 6.5;
const double _kettleCatchY = 12;

/// Thermometer bulb relative to the beaker floor: centre zone (correct)
/// and edge zone (feedback). The bulb must also be at least 0.8 above the
/// floor and 0.5 below the water / ice surface.
const double _centreHalf = 1.6;
const double _edgeHalf = 4;
const double _edgeLow = -1.5;
const double _edgeHigh = 10.5;
const double _floorGap = 0.8;
const double _surfaceGap = 0.5;

// ---------------------------------------------------------------- timing

/// HTML `TWEEN(waterLiquid.scale).to({y: 1}, 2000)` + `setTimeout(2000)`.
const Duration _pourTime = Duration(milliseconds: 2000);
const double _pourSeconds = 2;

/// The kettle moves into its pouring pose.
const double _tipSeconds = 0.3;

/// `setTimeout(progressScenario…, 1500)` after a correct placement and
/// `setTimeout(progressScenario2, 1000)` after the ice beaker is placed.
const Duration _placedDelay = Duration(milliseconds: 1500);
const Duration _iceBeakerDelay = Duration(milliseconds: 1000);

/// S1 step 3: `TWEEN(thermoFluid.scale).to({y: 0.6}, 2500)` and
/// `showNextButton` after 3000 ms.
const double _riseSeconds = 2.5;
const Duration _nextDelay = Duration(milliseconds: 3000);

/// S2: the column falls into the ice / rises in the boiling water while
/// the placed thermometer settles (HTML 1500 / 2000 ms, one step later).
const double _settleSeconds = 1.5;

/// S2 step 3: ice and water `TWEEN(…, 4000)`, zoom card after 4000 ms,
/// shown for 3000 ms.
const double _meltSeconds = 4;
const Duration _meltZoomDelay = Duration(milliseconds: 4000);
const Duration _zoomShown = Duration(milliseconds: 3000);

/// S2 step 4: bubbles 1500 ms after the flame, step 5 1000 ms later.
const Duration _boilDelay = Duration(milliseconds: 1500);
const Duration _boilStepDelay = Duration(milliseconds: 1000);

/// S2 step 6: zoom card 2500 ms after the step starts.
const Duration _boilZoomDelay = Duration(milliseconds: 2500);

/// S1 step 5: the column falls back to room temperature (HTML 1000 ms;
/// slower here so the learner sees it fall) and the conclusion follows.
const double _fallSeconds = 2.5;
const Duration _removedConclusionDelay = Duration(milliseconds: 2500);
const double _layDownSeconds = 0.7;

/// S2: HTML `triggerConclusion()` opens at once; a short beat here.
const Duration _conclusionDelay = Duration(milliseconds: 300);

/// Glides: a dropped object snaps into place / slides back home; the
/// beaker moves aside for the stand.
const double _snapSeconds = 0.18;
const double _returnSeconds = 0.35;
const double _asideSeconds = 0.6;

/// Feedback icon (HTML `#feedback-icon`): tick for 1.5 s, cross for 1 s.
const double _tickSeconds = 1.5;
const double _crossSeconds = 1;

/// Scene icon buttons (magnifying glass, flame), in design px at least
/// 48 dp on screen.
const double _sceneButtonDp = 48;

/// The magnifying glass sits right of the column at the 60 °C mark; the
/// flame button right of the burner.
const _V _magnifierOffset = _V(4.8, 0, 0);
const _V _flameButtonAt = _V(7, 2.5, 0);

/// The objects a learner drags.
enum _Item { beaker, kettle, thermometer }

/// Alcohol column height above the bulb centre for [celsius].
double _fluidHeight(double celsius) =>
    _fluidAt0 + _fluidPerDegree * celsius.clamp(_scaleMin, _scaleMax);

/// A value animated from one number to another (HTML TWEEN).
class _Anim {
  _Anim(double value) : _from = value, _to = value;

  double _from;
  double _to;
  double _start = 0;
  double _duration = 0;
  Curve _curve = Curves.linear;

  double get target => _to;

  /// Jumps to [value] at once.
  void set(double value) {
    _from = _to = value;
    _duration = 0;
  }

  /// Animates from the current value to [value] over [seconds].
  void animate(
    double value,
    double now,
    double seconds, {
    Curve curve = Curves.easeOutQuad,
  }) {
    _from = at(now);
    _to = value;
    _start = now;
    _duration = seconds;
    _curve = curve;
  }

  double at(double now) {
    if (_duration <= 0) return _to;
    final t = ((now - _start) / _duration).clamp(0.0, 1.0);
    return _from + (_to - _from) * _curve.transform(t);
  }
}

/// A world position that jumps (while dragged) or glides (snaps, returns).
class _Mover {
  _Mover(_V p) : _from = p, _to = p;

  _V _from;
  _V _to;
  double _start = 0;
  double _duration = 0;

  _V get target => _to;

  void jump(_V p) {
    _from = _to = p;
    _duration = 0;
  }

  void glide(_V p, double now, double seconds) {
    _from = at(now);
    _to = p;
    _start = now;
    _duration = seconds;
  }

  bool moving(double now) => _duration > 0 && now < _start + _duration;

  _V at(double now) {
    if (_duration <= 0) return _to;
    final t = ((now - _start) / _duration).clamp(0.0, 1.0);
    return _V.lerp(_from, _to, Curves.easeInOutCubic.transform(t));
  }
}

/// Mutable scene read by the painter every frame (public fields so the
/// flow tests can read it through the painter).
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based step (HTML `State.step`); one past the last once concluded.
  int step = 1;

  /// Counts scenario loads: a drag or timer from an earlier load is
  /// ignored.
  int epoch = 0;

  // ------------------------------------------------------------- beaker
  final _Mover beaker = _Mover(_beakerHome);
  _V beakerHome = _beakerHome;

  /// On the table centre (HTML `State.s1.beakerPlaced`).
  bool beakerPlaced = false;
  bool beakerOnStand = false;

  /// Water level 0–1 of the full 7 units and its opacity.
  final _Anim water = _Anim(0);
  final _Anim waterAlpha = _Anim(_waterAlpha);
  bool ice = false;
  final _Anim iceScale = _Anim(1);
  bool steam = false;
  double steamSince = 0;
  bool bubbles = false;

  // ------------------------------------------------------- stand, burner
  bool tripod = false;
  bool flame = false;

  // ------------------------------------------------------------- kettle
  bool kettleShown = false;
  bool pouring = false;
  double pourStart = 0;
  final _Mover kettle = _Mover(_kettleHome);

  // -------------------------------------------------------- thermometer
  bool thermoShown = false;

  /// In the beaker (HTML `thermoPlaced` / `iceThermoPlaced` /
  /// `boilThermoPlaced`).
  bool thermoPlaced = false;

  /// S1 step 5: taken out of the water.
  bool thermoOut = false;

  /// Bulb position (upright thermometer).
  final _Mover thermo = _Mover(_thermoHome);

  /// 0 upright … 1 lying on the table, and where the lay-down started.
  final _Anim thermoLay = _Anim(0);
  _V layFrom = _thermoHome;

  /// Temperature the alcohol column shows (°C).
  final _Anim temp = _Anim(_roomTemp);

  // ------------------------------------------------------------ gestures
  _Item? held;

  /// S1 step 5: the held thermometer is being pulled out of the beaker.
  bool liftingOut = false;

  /// Thermometer drop feedback (HTML `#feedback-icon`): design point, tick
  /// or cross, start time.
  Offset? feedbackAt;
  bool feedbackOk = true;
  double feedbackStart = -10;

  // ------------------------------------------------------ buttons, cards
  bool magnifier = false;
  bool flameButton = false;

  /// Value on the magnified-reading card (HTML `#zoom-overlay-N`), or null.
  int? reading;
  bool readingClosable = false;

  /// The step's own button (Next Step / Next Setup / Observe Conclusion)
  /// is offered.
  bool ready = false;
  bool concluded = false;

  double get temperature => temp.at(time);
  _V get beakerPos => beaker.at(time);
  _V get kettlePos => kettle.at(time);

  /// The beaker's floor: where it stands now.
  _V get beakerBase => beaker.target;

  /// Height of the water / ice surface above the beaker floor.
  double get liquidTop => ice ? _iceTop : water.target * _waterFull;

  bool get canDragBeaker {
    if (held != null && held != _Item.beaker) return false;
    if (step == 1 && !beakerPlaced) return true;
    return scenario == 1 &&
        step == 4 &&
        tripod &&
        !beakerOnStand &&
        !beaker.moving(time);
  }

  bool get canDragKettle =>
      scenario == 0 &&
      step == 1 &&
      beakerPlaced &&
      kettleShown &&
      !pouring &&
      (held == null || held == _Item.kettle);

  bool get canDragThermometer =>
      thermoShown &&
      !thermoPlaced &&
      !thermoOut &&
      (step == 2 || (scenario == 1 && step == 5)) &&
      (held == null || held == _Item.thermometer);

  bool get canLiftOut =>
      scenario == 0 &&
      step == 5 &&
      thermoPlaced &&
      !thermoOut &&
      (held == null || held == _Item.thermometer);

  /// The thermometer's bulb and tilt (0 upright, π/2 lying with the tube
  /// pointing to −x).
  (_V, double) thermoPose() {
    final e = thermoLay.at(time);
    if (e <= 0) return (thermo.at(time), 0);
    return (_V.lerp(layFrom, _lyingBulb, e), e * math.pi / 2);
  }

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    epoch++;
    beaker.jump(_beakerHome);
    beakerHome = _beakerHome;
    beakerPlaced = false;
    beakerOnStand = false;
    water.set(0);
    waterAlpha.set(_waterAlpha);
    // S2 starts with the beaker of crushed ice (HTML `iceMesh.visible`).
    ice = index == 1;
    iceScale.set(1);
    steam = false;
    bubbles = false;
    tripod = false;
    flame = false;
    kettleShown = false;
    pouring = false;
    kettle.jump(_kettleHome);
    thermoShown = false;
    thermoPlaced = false;
    thermoOut = false;
    thermo.jump(_thermoHome);
    thermoLay.set(0);
    layFrom = _thermoHome;
    temp.set(_roomTemp);
    held = null;
    liftingOut = false;
    feedbackAt = null;
    magnifier = false;
    flameButton = false;
    reading = null;
    readingClosable = false;
    ready = false;
    concluded = false;
  }
}

// ---------------------------------------------------------------- geometry

/// Bounds of the projections of [points].
Rect _bounds(Iterable<_V> points) {
  var l = double.infinity, t = double.infinity;
  var r = -double.infinity, b = -double.infinity;
  for (final w in points) {
    final p = _cam.p(w);
    l = math.min(l, p.dx);
    t = math.min(t, p.dy);
    r = math.max(r, p.dx);
    b = math.max(b, p.dy);
  }
  return Rect.fromLTRB(l, t, r, b);
}

/// Screen box of the beaker standing at [base].
Rect _beakerBox(_V base) => _bounds([
  base + const _V(-_beakerR, 0, _beakerR),
  base + const _V(_beakerR, 0, _beakerR),
  base + const _V(-_beakerR, _beakerH, -_beakerR),
  base + const _V(_beakerR, _beakerH, -_beakerR),
]);

/// Screen box of the kettle with its body centre at [c] (SVG x 5–100,
/// y 18–111).
Rect _kettleBox(_V c) => _bounds([
  c + const _V(-45 * _kettleUnit, 47 * _kettleUnit, 0),
  c + const _V(50 * _kettleUnit, -46 * _kettleUnit, 0),
]);

/// Screen box of the upright thermometer with its bulb at [bulb].
Rect _thermoBox(_V bulb) => _bounds([
  bulb + const _V(-_bulbR, -_bulbR, 0),
  bulb + const _V(_bulbR, _tubeLen, 0),
]);

/// [r] grown to at least [touch] × 2 each way (48 dp tap targets).
Rect _touchRect(Rect r, double touch) => Rect.fromCenter(
  center: r.center,
  width: math.max(r.width, 2 * touch),
  height: math.max(r.height, 2 * touch),
);

/// Design point of the magnifying glass (right of the 60 °C mark).
Offset _magnifierAt(_Scene s) => _cam.p(
  s.beakerBase +
      _V(0, _bulbHang + _fluidHeight(_warmTemp.toDouble()), 0) +
      _magnifierOffset,
);

/// Design point of the flame button (right of the burner).
final Offset _flameAt = _cam.p(_flameButtonAt);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on an object the learner may drag now ([canGrab]), so other drags still
/// pan / zoom the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _ThermometerLabState
    extends State<Ch7A4MeasuringTemperaturesWithLaboratoryThermometersPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius, label size and scene-button size in design pixels for
  /// the current stage scale (set while laying out the stage).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _button = _sceneButtonDp;

  /// The drag in progress: the load it started in, the grab offset (plane
  /// hit minus the object's position) and the plane height at the grab
  /// (pulling the thermometer out).
  int _grabEpoch = -1;
  _V _grabOffset = _V.zero;
  double _liftFrom = 0;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive));
    _scene.load(0);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    _ticker.dispose();
    _frame.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  /// HTML `animate()`: every animation is a function of the scene time, so
  /// a frame only advances the clock and repaints the canvas.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _scene.time = now;
    _frame.value = now;
  }

  /// HTML `setTimeout`, dropped when the scenario is reloaded meanwhile.
  void _after(Duration delay, VoidCallback fn) {
    final epoch = _scene.epoch;
    _lab.after(delay, () {
      if (!mounted || epoch != _scene.epoch) return;
      fn();
    });
  }

  /// An informational toast (the HTML toasts make no sound).
  void _info(String key) => _lab.showToast(_t(key), sound: false);

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)`: clears timers and resets the scenario.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grabEpoch = -1;
    });
    _lab.resetView(sound: false);
    // HTML `showToast` stays silent while the curtain is down.
    if (_lab.isLabActive) _info('toast_drag_table');
  }

  void _setStep(int step) => setState(() => _scene.step = step);

  /// HTML `triggerConclusion()` (whose summary modal never actually opened)
  /// through the shell's conclusion popup.
  void _conclude(int scenario, Duration delay) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      delay: delay,
      title: () => labFormat(_t('sc_complete'), {'n': scenario + 1}),
      heading: () => _t('s${scenario + 1}_sum_title'),
      body: () => _t('s${scenario + 1}_sum'),
    );
  }

  // ------------------------------------------------------ scenario 1 flow

  /// Kettle dropped over the beaker: it tips and pours warm water (HTML
  /// `TWEEN(waterLiquid.scale)` 2000 ms, then steam and step 2).
  void _pour() {
    final s = _scene;
    s
      ..pouring = true
      ..pourStart = s.time;
    s.kettle.glide(_pourCenter, s.time, _tipSeconds);
    s.water.animate(1, s.time, _pourSeconds, curve: Curves.easeOutCubic);
    _Sound.correct.play();
    _after(_pourTime, () {
      setState(() {
        s
          ..pouring = false
          ..kettleShown = false
          ..steam = true
          ..steamSince = s.time;
      });
      _showThermometer(2);
    });
  }

  /// HTML `progressScenario…` step 2 / 5: the thermometer icon appears.
  void _showThermometer(int step) {
    final s = _scene;
    setState(() {
      s
        ..step = step
        ..thermoShown = true
        ..thermoPlaced = false;
      s.thermo.jump(_thermoHome);
      s.temp.set(_roomTemp);
    });
  }

  /// HTML step 3 (S1): the column rises to 60 °C; "Next Step" after 3 s.
  void _s1Observe() {
    final s = _scene;
    _setStep(3);
    s.temp.animate(_warmTemp.toDouble(), s.time, _riseSeconds);
    _after(_nextDelay, () => setState(() => s.ready = true));
  }

  /// "Next Step": HTML step 4, the magnifying glass appears.
  void _onNextStep() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 3 || !s.ready) return;
    _Sound.pop.play();
    setState(() {
      s
        ..ready = false
        ..step = 4
        ..magnifier = true;
    });
    _info('toast_click_icon');
  }

  /// HTML `triggerMagGlass()`: the 60 °C close-up.
  void _onMagnifier() {
    final s = _scene;
    if (!s.magnifier) return;
    _Sound.pop.play();
    setState(() {
      s
        ..magnifier = false
        ..reading = _warmTemp
        ..readingClosable = true;
    });
  }

  /// HTML `closeZoom()`: step 5, pull the thermometer out.
  void _onCloseReading() {
    final s = _scene;
    if (s.reading == null || !s.readingClosable) return;
    _Sound.pop.play();
    setState(() {
      s
        ..reading = null
        ..readingClosable = false;
      if (s.scenario == 0 && s.step == 4) s.step = 5;
    });
    if (s.scenario == 0 && s.step == 5) _info('toast_drag_out');
  }

  /// The bulb has cleared the rim: the thermometer is laid on the table and
  /// its column falls back (HTML: moved to the table side, fluid → 0.25).
  void _removeThermometer() {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      s
        ..layFrom = s.thermo.at(s.time)
        ..held = null
        ..liftingOut = false
        ..thermoPlaced = false
        ..thermoOut = true
        ..step = _stepCounts[0] + 1
        ..concluded = true;
      s.thermoLay.animate(1, s.time, _layDownSeconds);
      s.temp.animate(_roomTemp, s.time, _fallSeconds);
    });
    _grabEpoch = -1;
    _conclude(0, _removedConclusionDelay);
  }

  // ------------------------------------------------------ scenario 2 flow

  /// HTML step 3 (S2): the ice melts, the water rises, the 0 °C close-up
  /// shows for 3 s, then "Next Setup".
  void _s2Melt() {
    final s = _scene;
    _setStep(3);
    s.iceScale.animate(0.1, s.time, _meltSeconds, curve: Curves.linear);
    s.water.animate(_meltLevel, s.time, _meltSeconds, curve: Curves.linear);
    s.waterAlpha.animate(
      _meltAlpha,
      s.time,
      _meltSeconds,
      curve: Curves.linear,
    );
    _after(_meltZoomDelay, () {
      setState(() => s.reading = _iceTemp);
      _after(_zoomShown, () {
        _Sound.pop.play();
        setState(() {
          s
            ..reading = null
            ..ready = true;
        });
      });
    });
  }

  /// "Next Setup": HTML step 4, the tripod and burner appear; the beaker
  /// of melted ice moves aside to be put on the stand.
  void _onNextSetup() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || !s.ready) return;
    _Sound.pop.play();
    setState(() {
      s
        ..ready = false
        ..step = 4
        ..thermoShown = false
        ..thermoPlaced = false
        ..ice = false
        ..tripod = true
        ..beakerPlaced = false
        ..beakerHome = _sideSpot;
      s.water.set(_boilLevel);
      s.waterAlpha.set(_waterAlpha);
      s.beaker.glide(_sideSpot, s.time, _asideSeconds);
    });
    _info('toast_drag_stand');
  }

  /// HTML `triggerFlame()`: the burner is lit; the water boils 1.5 s
  /// later and step 5 follows 1 s after that.
  void _onFlame() {
    final s = _scene;
    if (!s.flameButton) return;
    _Sound.pop.play();
    setState(() {
      s
        ..flameButton = false
        ..flame = true;
    });
    _after(_boilDelay, () {
      setState(() {
        s
          ..bubbles = true
          ..steam = true
          ..steamSince = s.time;
      });
      _after(_boilStepDelay, () => _showThermometer(5));
    });
  }

  /// HTML step 6: the 100 °C close-up 2.5 s in, for 3 s; then "Observe
  /// Conclusion".
  void _s2Boil() {
    final s = _scene;
    _setStep(6);
    _after(_boilZoomDelay, () {
      setState(() => s.reading = _boilTemp);
      _after(_zoomShown, () {
        _Sound.pop.play();
        setState(() {
          s
            ..reading = null
            ..ready = true;
        });
      });
    });
  }

  /// "Observe Conclusion": the summary (again, once concluded).
  void _onConclude() {
    final s = _scene;
    if (s.scenario != 1 || !s.ready) return;
    _Sound.pop.play();
    if (s.concluded) {
      _conclude(1, Duration.zero);
      return;
    }
    setState(() {
      s
        ..concluded = true
        ..step = _stepCounts[1] + 1;
    });
    _conclude(1, _conclusionDelay);
  }

  // -------------------------------------------------------------- drops

  /// Beaker released (HTML `checkDrop('drop-table' | 'drop-stand-top')`).
  void _dropBeaker() {
    final s = _scene;
    final p = s.beaker.at(s.time);
    if (s.tripod) {
      if (p.x.abs() <= _standCatchX &&
          p.y >= _standCatchLow &&
          p.y <= _standCatchHigh) {
        _Sound.pop.play();
        setState(() {
          s
            ..beakerOnStand = true
            ..flameButton = true;
          s.beaker.glide(const _V(0, _standTop, 0), s.time, _snapSeconds);
        });
        _info('toast_click_icon');
        return;
      }
    } else if (p.x.abs() <= _tableCatchX && p.y <= _tableCatchY) {
      _Sound.pop.play();
      setState(() {
        s.beakerPlaced = true;
        s.beaker.glide(_tableSpot, s.time, _snapSeconds);
        if (s.scenario == 0) s.kettleShown = true;
      });
      if (s.scenario == 0) {
        _info('toast_drag_beaker');
      } else {
        _after(_iceBeakerDelay, () => _showThermometer(2));
      }
      return;
    }
    // Anywhere else: back to where it was (the HTML snapped it back).
    s.beaker.glide(s.beakerHome, s.time, _returnSeconds);
  }

  /// Kettle released: pours when it is over the beaker.
  void _dropKettle() {
    final s = _scene;
    final c = s.kettle.at(s.time);
    if (s.beakerPlaced &&
        c.x.abs() <= _kettleCatchX &&
        c.y - _kettleBaseDrop <= _kettleCatchY) {
      _pour();
      return;
    }
    s.kettle.glide(_kettleHome, s.time, _returnSeconds);
  }

  /// Thermometer released (HTML `checkDropRect('drop-beaker-center' |
  /// 'drop-beaker-edge')`), judged by where its bulb is.
  void _dropThermometer() {
    final s = _scene;
    final bulb = s.thermo.at(s.time);
    final rel = bulb - s.beakerBase;
    final inEdgeZone =
        rel.x.abs() <= _edgeHalf && rel.y >= _edgeLow && rel.y <= _edgeHigh;
    if (!inEdgeZone || !(s.beakerPlaced || s.beakerOnStand)) {
      s.thermo.glide(_thermoHome, s.time, _returnSeconds);
      return;
    }
    final centred = rel.x.abs() <= _centreHalf;
    final top = s.liquidTop - _surfaceGap;
    if (centred && rel.y >= _floorGap && rel.y <= top) {
      _placeThermometer();
      return;
    }
    // HTML `showFeedbackError`: red cross, error tone and toast.
    setState(() {
      s
        ..feedbackAt = _cam.p(bulb)
        ..feedbackOk = false
        ..feedbackStart = s.time;
    });
    s.thermo.glide(_thermoHome, s.time, _returnSeconds);
    _lab.showToast(
      _t(centred && rel.y > top ? 'toast_dip_bulb' : 'toast_error_vertical'),
      isError: true,
    );
  }

  /// HTML `placeThermometerCorrectly()`: green tick, the thermometer hangs
  /// in the middle with its bulb 3 above the floor; the next step follows
  /// 1.5 s later.
  void _placeThermometer() {
    final s = _scene;
    final base = s.beakerBase;
    _Sound.correct.play();
    setState(() {
      s
        ..thermoPlaced = true
        ..feedbackAt = _cam.p(base + const _V(0, 6, 0))
        ..feedbackOk = true
        ..feedbackStart = s.time;
      s.thermo.glide(base + const _V(0, _bulbHang, 0), s.time, _snapSeconds);
    });
    if (s.scenario == 0) {
      _after(_placedDelay, _s1Observe);
    } else if (s.step == 2) {
      // The column falls in the ice as the step is completed ("Temperature
      // drops rapidly"); the HTML let it fall only in step 3.
      s.temp.animate(_iceTemp.toDouble(), s.time, _settleSeconds);
      _after(_placedDelay, _s2Melt);
    } else {
      // Likewise it rises in the boiling water now (HTML: in step 6).
      s.temp.animate(_boilTemp.toDouble(), s.time, _settleSeconds);
      _after(_placedDelay, _s2Boil);
    }
  }

  // -------------------------------------------------------------- gestures

  /// The object under [at] that may be dragged now.
  _Item? _grabbable(Offset at) {
    final s = _scene;
    if (s.canLiftOut || s.canDragThermometer) {
      if (_touchRect(_thermoBox(s.thermo.at(s.time)), _touch).contains(at)) {
        return _Item.thermometer;
      }
    }
    if (s.canDragKettle &&
        _touchRect(_kettleBox(s.kettlePos), _touch).contains(at)) {
      return _Item.kettle;
    }
    if (s.canDragBeaker &&
        _touchRect(_beakerBox(s.beakerPos), _touch).contains(at)) {
      return _Item.beaker;
    }
    return null;
  }

  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _scene.held != null) return false;
    return _grabbable(event.localPosition) != null;
  }

  _V? _planeHit(Offset at) => _cam.onPlane(at, _dragNormal, 0);

  void _onDown(DragDownDetails d) {
    final s = _scene;
    final item = _grabbable(d.localPosition);
    final hit = _planeHit(d.localPosition);
    if (item == null || hit == null) return;
    _grabEpoch = s.epoch;
    final pos = switch (item) {
      _Item.beaker => s.beakerPos,
      _Item.kettle => s.kettlePos,
      _Item.thermometer => s.thermo.at(s.time),
    };
    _grabOffset = hit - pos;
    _liftFrom = hit.y;
    setState(() {
      s
        ..held = item
        ..liftingOut = item == _Item.thermometer && s.canLiftOut;
    });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final item = s.held;
    if (item == null || _grabEpoch != s.epoch) return;
    final hit = _planeHit(d.localPosition);
    if (hit == null) return;
    final p = hit - _grabOffset;
    switch (item) {
      case _Item.beaker:
        // Kept on or above the table top.
        s.beaker.jump(_V(p.x.clamp(-19.0, 19.0), p.y.clamp(0.0, 18.0), 0));
      case _Item.kettle:
        s.kettle.jump(
          _V(p.x.clamp(-19.0, 19.0), p.y.clamp(_kettleBaseDrop, 20.0), 0),
        );
      case _Item.thermometer:
        if (s.liftingOut) {
          // Straight up out of the beaker (HTML `thermo-drag-out`).
          final placed = s.beakerBase + const _V(0, _bulbHang, 0);
          final lift = (hit.y - _liftFrom).clamp(0.0, _tubeLen);
          s.thermo.jump(placed + _V(0, lift, 0));
          if (_bulbHang + lift >= _outAbove) _removeThermometer();
        } else {
          s.thermo.jump(_V(p.x.clamp(-19.0, 21.0), p.y.clamp(_bulbR, 16.0), 0));
        }
    }
  }

  void _onDragEnd(DragEndDetails _) => _release();

  void _release() {
    final s = _scene;
    final item = s.held;
    final current = _grabEpoch == s.epoch;
    _grabEpoch = -1;
    if (item == null || !current) return;
    final lifting = s.liftingOut;
    setState(() {
      s
        ..held = null
        ..liftingOut = false;
    });
    switch (item) {
      case _Item.beaker:
        _dropBeaker();
      case _Item.kettle:
        _dropKettle();
      case _Item.thermometer:
        if (lifting) {
          // Not out yet: it slides back into the water.
          s.thermo.glide(
            s.beakerBase + const _V(0, _bulbHang, 0),
            s.time,
            _returnSeconds,
          );
          _info('toast_drag_out');
        } else {
          _dropThermometer();
        }
    }
  }

  // -------------------------------------------------------------------- UI

  /// The step's own button (HTML `#btn-next-action`), in the sidebar and
  /// the floating mission card.
  List<LabAction> _actions() {
    final s = _scene;
    final p = _lab.palette;
    LabAction action(String key, IconData icon, VoidCallback onTap) =>
        LabAction(
          label: _t(key),
          icon: icon,
          color: p.primary,
          foreground: p.onPrimary,
          highlight: !s.concluded,
          silent: true,
          onTap: onTap,
        );
    if (!s.ready) return const [];
    if (s.scenario == 0 && s.step == 3) {
      return [action('btn_next', Icons.arrow_forward, _onNextStep)];
    }
    if (s.scenario == 1 && s.step == 3) {
      return [action('btn_next_setup', Icons.arrow_forward, _onNextSetup)];
    }
    if (s.scenario == 1 && s.step >= 6) {
      return [action('btn_conclude', Icons.lightbulb, _onConclude)];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final reading = _scene.reading;
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, data.steps.length)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch7a4-steps-$sc-${_scene.step}'),
            steps: data.steps,
            current: _scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
            pendingText: _t('obs_pending'),
          ),
          overlays: [
            // HTML `#zoom-overlay-N` (centre of the canvas): here below the
            // toasts, beside the beaker and its labels: top left of the
            // canvas, or top right while the floating mission card is there.
            if (_lab.isLabActive && reading != null)
              Positioned(
                key: const ValueKey('ch7a4-reading'),
                top: inset.top + 44 * s,
                left: _lab.isSidebarOpen ? inset.left : null,
                right: _lab.isSidebarOpen ? null : inset.right,
                child: _ReadingCard(
                  value: reading,
                  title: _t('zoom_title'),
                  unit: _t('unit_c'),
                  closeLabel: _t('close'),
                  onClose: _scene.readingClosable ? _onCloseReading : null,
                  scale: s,
                ),
              ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / fit;
          _button = math.max(_sceneButtonDp, _sceneButtonDp / fit);
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        final s = _scene;
        return LabStage(
          designSize: _design,
          child: Stack(
            children: [
              Positioned.fill(
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags on the scene are not screen-reader actions; the
                  // scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
                          () => _GrabPanRecognizer(debugOwner: this),
                          (r) => r
                            // RawGestureDetector does not apply MediaQuery's
                            // gesture settings; short drags must pick up.
                            ..gestureSettings = const DeviceGestureSettings(
                              touchSlop: _dragSlop,
                            )
                            ..canGrab = _canGrab
                            ..dragStartBehavior = DragStartBehavior.down
                            ..onDown = _onDown
                            ..onUpdate = _onDragUpdate
                            ..onEnd = _onDragEnd
                            ..onCancel = _release,
                        ),
                  },
                  child: Semantics(
                    image: true,
                    label: _t(s.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: _design,
                        painter: _ScenePainter(
                          scene: s,
                          cache: _cache,
                          repaint: _frame,
                          isDark: _lab.isDark,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelSize: _labelSize,
                          button: _button,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // HTML `#btn-mag-glass` and `#btn-flame`, next to what they
              // act on.
              if (s.magnifier)
                _sceneButton(
                  key: const ValueKey('ch7a4-magnifier'),
                  at: _magnifierAt(s),
                  icon: Icons.search,
                  color: _Colors.blue500,
                  tooltip: _t('tip_magnifier'),
                  onPressed: _onMagnifier,
                ),
              if (s.flameButton)
                _sceneButton(
                  key: const ValueKey('ch7a4-flame'),
                  at: _flameAt,
                  icon: Icons.local_fire_department,
                  color: _Colors.orange500,
                  tooltip: _t('tip_flame'),
                  onPressed: _onFlame,
                ),
            ],
          ),
        );
      },
    );
  }

  /// A round icon button centred on a design point, at least 48 dp on
  /// screen (its pulsing ring is painted by the scene).
  Widget _sceneButton({
    required Key key,
    required Offset at,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final size = _button;
    return Positioned(
      key: key,
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      width: size,
      height: size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: size * 0.5,
        constraints: BoxConstraints.tight(Size.square(size)),
        icon: Icon(icon, color: color),
        style: IconButton.styleFrom(
          backgroundColor: _Colors.slate800.withValues(alpha: 0.92),
          shape: CircleBorder(
            side: BorderSide(color: color, width: size * 0.05),
          ),
        ),
      ),
    );
  }
}

/// HTML `#zoom-overlay-N`: a close-up of the thermometer scale around the
/// reading (white glass panel with a coloured border), with Close in
/// Scenario 1.
class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.value,
    required this.title,
    required this.unit,
    required this.closeLabel,
    required this.onClose,
    required this.scale,
  });

  final int value;
  final String title;
  final String unit;
  final String closeLabel;
  final VoidCallback? onClose;
  final double scale;

  /// HTML border colours: blue (60), emerald (0), red (100).
  Color get _tone => switch (value) {
    _iceTemp => _Colors.emerald500,
    _boilTemp => _Colors.red500,
    _ => _Colors.blue500,
  };

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final close = onClose;
    return Container(
      width: 150 * s,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: _Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: _tone, width: 3 * s),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 14 * s, color: _tone),
              SizedBox(width: 4 * s),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _Colors.slate800,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            height: _readingHeight * s,
            child: _ReadingScale(value: value, unit: unit, tone: _tone, s: s),
          ),
          if (close != null) ...[
            SizedBox(height: 8 * s),
            LabActionButton(
              key: const ValueKey('ch7a4-close-reading'),
              action: LabAction(
                label: closeLabel,
                icon: Icons.close,
                color: _Colors.blue500,
                foreground: _Colors.white,
                silent: true,
                onTap: close,
              ),
              scale: s,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// The close-up shows the reading ± 12 °C.
const double _readingSpan = 12;
const double _readingHeight = 120;
const double _readingTubeWidth = 24;

/// Height in the close-up of [celsius] around [value], for a scale [h]
/// high.
double _readingY(double celsius, int value, double h) =>
    h * (1 - (celsius - (value - _readingSpan)) / (2 * _readingSpan));

/// The tube of the close-up (painted) and its numbers (text widgets).
class _ReadingScale extends StatelessWidget {
  const _ReadingScale({
    required this.value,
    required this.unit,
    required this.tone,
    required this.s,
  });

  final int value;
  final String unit;
  final Color tone;
  final double s;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final tube = _readingTubeWidth * s;
        final labelH = 18 * s;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 4 * s,
              top: 0,
              bottom: 0,
              width: tube,
              child: CustomPaint(
                painter: _ReadingTubePainter(value: value, tone: tone),
              ),
            ),
            for (
              var c = (value - _readingSpan).ceil();
              c <= value + _readingSpan;
              c++
            )
              if (c % 10 == 0)
                Positioned(
                  left: tube + 10 * s,
                  right: 0,
                  top: _readingY(c.toDouble(), value, h) - labelH / 2,
                  height: labelH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: c == value
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5 * s,
                                vertical: 1 * s,
                              ),
                              decoration: BoxDecoration(
                                color: tone.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(5 * s),
                              ),
                              child: Text(
                                '$c$unit',
                                style: TextStyle(
                                  color: labShade(tone, -0.25),
                                  fontSize: 14 * s,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            )
                          : Text(
                              '$c',
                              style: TextStyle(
                                color: _Colors.slate700,
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// The close-up tube: grey glass, red column up to the reading, scale
/// marks every 2 °C (long ones every 10 °C) and the reading's mark.
class _ReadingTubePainter extends CustomPainter {
  _ReadingTubePainter({required this.value, required this.tone});

  final int value;
  final Color tone;
  final Paint _fill = Paint();
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(w / 2),
    );
    canvas.drawRRect(rr, _fill..color = _Colors.slate100);
    final top = _readingY(value.toDouble(), value, h);
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.25, top, w * 0.75, h),
      _fill..color = _Colors.alcohol,
    );
    canvas.restore();
    for (
      var c = (value - _readingSpan).ceil();
      c <= value + _readingSpan;
      c += 2
    ) {
      final y = _readingY(c.toDouble(), value, h);
      final major = c % 10 == 0;
      canvas.drawLine(
        Offset(w * (major ? 0.45 : 0.68), y),
        Offset(w, y),
        _line
          ..strokeWidth = major ? 2 : 1
          ..color = c == value ? tone : _Colors.slate900,
      );
    }
    canvas.drawRRect(
      rr,
      _line
        ..strokeWidth = 2
        ..color = _Colors.slate300,
    );
  }

  @override
  bool shouldRepaint(covariant _ReadingTubePainter old) =>
      old.value != value || old.tone != tone;
}

/// HTML teacher-board accordion ("Observation Step"): one card per step
/// with its task, action and result. The current step is open, done steps
/// show a tick and can be re-opened, future steps are dimmed. A step's
/// result is shown once the step is done (the HTML showed it before the
/// learner had seen it).
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.conceptLabel,
    required this.actionLabel,
    required this.observationLabel,
    required this.pendingText,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String conceptLabel;
  final String actionLabel;
  final String observationLabel;
  final String pendingText;

  @override
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
  final Set<int> _toggled = {};

  bool _isOpen(int i) => (i == widget.current) != _toggled.contains(i);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++) _tile(context, i),
      ],
    );
  }

  Widget _heading(String text, Color color) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 9.5 * widget.fontScale,
      fontWeight: FontWeight.w800,
      letterSpacing: labLetterSpacing(text, 0.8),
    ),
  );

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    // Future steps: HTML `text-slate-500`, dimmed and closed.
    final dim = future ? 0.5 : 1.0;
    final accent = p.accentInk;
    final tone = current ? accent : (past ? p.success : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    return Container(
      margin: EdgeInsets.only(bottom: 6 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: border.a * dim)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: LabInk.clear,
            child: InkWell(
              onTap: future
                  ? null
                  : () {
                      LabStyleScope.of(context).style.click.play();
                      setState(() {
                        if (!_toggled.remove(i)) _toggled.add(i);
                      });
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Row(
                    children: [
                      Container(
                        width: 22 * s,
                        height: 22 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: current
                              ? p.accent
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
                                : (past
                                      ? p.success.withValues(alpha: 0.5)
                                      : p.cardBorder.withValues(alpha: dim)),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.success)
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: current
                                      ? p.onAccent
                                      : p.textMuted.withValues(alpha: dim),
                                  fontSize: 11 * s,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: Text(
                          '${w.stepLabel} $i',
                          style: TextStyle(
                            color: tone.withValues(alpha: tone.a * dim),
                            fontSize: 12.5 * f,
                            fontWeight: current
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        open ? Icons.expand_less : Icons.expand_more,
                        size: 18 * s,
                        color: tone.withValues(alpha: 0.7 * dim),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heading(w.conceptLabel, accent),
                  SizedBox(height: 3 * s),
                  Text(
                    step.concept,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    step.action,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    past ? step.observation : w.pendingText,
                    style: TextStyle(
                      color: past ? p.text : p.textMuted,
                      fontSize: 11.5 * f,
                      fontWeight: past ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: past ? FontStyle.normal : FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Points per projected circle (beaker, water, ring ellipses).
const int _ringN = 28;

/// One ice cube of the crushed ice (HTML `DodecahedronGeometry(0.7 …
/// 1.2)` at random places): position in the beaker, radius, turn and the
/// jitter of its six corners.
@immutable
class _Cube {
  const _Cube(this.pos, this.r, this.turn, this.jitter);

  final _V pos;
  final double r;
  final double turn;
  final List<double> jitter;
}

/// Eighteen cubes (HTML loop of 18), seeded so the ice looks the same each
/// time, sorted far to near.
final List<_Cube> _cubes = () {
  final rnd = math.Random(7);
  final list = [
    for (var i = 0; i < 18; i++)
      _Cube(
        _V(
          (rnd.nextDouble() - 0.5) * 3.5,
          0.5 + rnd.nextDouble() * 5,
          (rnd.nextDouble() - 0.5) * 3.5,
        ),
        0.7 + rnd.nextDouble() * 0.5,
        rnd.nextDouble() * math.pi,
        [for (var k = 0; k < 6; k++) 0.8 + rnd.nextDouble() * 0.35],
      ),
  ];
  return list..sort((a, b) => a.pos.z.compareTo(b.pos.z));
}();

/// Rising bubbles of boiling water (HTML 20 spheres r 0.2): x, z, speed
/// (units / s) and phase.
final List<(double, double, double, double)> _bubbleSeeds = () {
  final rnd = math.Random(11);
  return [
    for (var i = 0; i < 20; i++)
      (
        (rnd.nextDouble() - 0.5) * 4,
        (rnd.nextDouble() - 0.5) * 4,
        3 + rnd.nextDouble() * 3,
        rnd.nextDouble(),
      ),
  ];
}();

/// Steam puffs above the beaker (HTML 5 planes rising from y 8 to 12 at
/// 0.02–0.04 per frame): x, z, speed (units / s) and phase.
final List<(double, double, double, double)> _steamSeeds = () {
  final rnd = math.Random(5);
  return [
    for (var i = 0; i < 5; i++)
      (
        (rnd.nextDouble() - 0.5) * 2,
        (rnd.nextDouble() - 0.5) * 2,
        1.2 + rnd.nextDouble() * 1.2,
        rnd.nextDouble(),
      ),
  ];
}();

/// Rise of a steam puff (HTML: from 8 to 12, then back to 8).
const double _steamRise = 4;

/// Beaker graduations (HTML decal: 50–250 mL of 300 mL over the 8 units).
const List<int> _gradMl = [50, 100, 150, 200, 250];
const double _gradFullMl = 300;
const double _gradFont = 8;

/// Angle (about the beaker axis, from +x towards +z) of the graduations:
/// front left, as the HTML decal's `rotation.y` intended.
const double _gradAngle = math.pi / 2 + 0.55;

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Thick butt-ended lines (tubes, legs).
  final Paint bar = Paint()..style = PaintingStyle.stroke;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Pulsing glow round draggable objects and scene buttons.
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

  /// Soft fills: steam, flame glow.
  final Paint soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Path path = Path();
  final Path path2 = Path();
  final List<Offset> ringA = List.filled(_ringN, Offset.zero);
  final List<Offset> ringB = List.filled(_ringN, Offset.zero);
}

/// The kettle drag icon's SVG paths (HTML `#drag-kettle`, viewBox 120).
class _KettlePaths {
  final Path body = Path()
    ..moveTo(30, 40)
    ..cubicTo(30, 20, 70, 20, 70, 40)
    ..lineTo(80, 100)
    ..cubicTo(80, 110, 20, 110, 20, 100)
    ..close();
  final Path handle = Path()
    ..moveTo(75, 50)
    ..cubicTo(100, 50, 100, 90, 75, 90);
  final Path spout = Path()
    ..moveTo(25, 50)
    ..lineTo(5, 40)
    ..lineTo(20, 60)
    ..close();
  final RRect base = RRect.fromLTRBR(
    15,
    105,
    85,
    111,
    const Radius.circular(3),
  );
  final Path lid = Path()
    ..moveTo(35, 35)
    ..cubicTo(45, 20, 55, 20, 65, 35)
    ..close();
  final Path shine = Path()
    ..moveTo(35, 50)
    ..cubicTo(35, 30, 45, 30, 45, 50)
    ..lineTo(50, 90)
    ..cubicTo(50, 100, 40, 100, 35, 90)
    ..close();
}

/// What the painter makes once and reuses: pens, kettle paths, the static
/// backdrop (wall and table) and the text painters. Owned by the page state
/// and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final _KettlePaths kettle = _KettlePaths();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _grads = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool _dark = true;
  ui.Picture? _backdrop;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language, label size or theme
  /// changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _dark) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _dark = dark;
  }

  TextPainter label(String text, Color color) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Beaker graduation numbers ("50" … "250", "mL").
  TextPainter grad(String text) => _grads[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white.withValues(alpha: 0.85),
        fontSize: _gradFont,
        fontWeight: FontWeight.w700,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// The wall and the lab table (HTML `buildEnvironment()`), recorded once.
  ui.Picture backdrop(Size size) {
    final cached = _backdrop;
    if (cached != null) return cached;
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), size, pens);
    return _backdrop = recorder.endRecording();
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    for (final tp in _grads.values) {
      tp.dispose();
    }
    _grads.clear();
    _backdrop?.dispose();
    _backdrop = null;
  }
}

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Fills the quad [a]–[b]–[c]–[d] (world points) with [color].
void _quad(Canvas canvas, _Pens pens, List<_V> pts, Color color) {
  final path = pens.path..reset();
  for (var i = 0; i < pts.length; i++) {
    final o = _cam.p(pts[i]);
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }
  path.close();
  canvas.drawPath(path, pens.fill..color = color);
}

/// Scene background, back wall `PlaneGeometry(100, 50)` at z = −15 and the
/// table `BoxGeometry(40, 2, 20)` with its top at y = 0.
void _paintBackdrop(Canvas canvas, Size size, _Pens pens) {
  canvas.drawRect(labBleed(size), pens.fill..color = _Colors.sceneBg);
  _quad(canvas, pens, const [
    _V(-50, -5, -15),
    _V(50, -5, -15),
    _V(50, 45, -15),
    _V(-50, 45, -15),
  ], _lit(_Colors.wall, const _V(0, 0, 1)));
  _quad(canvas, pens, const [
    _V(-20, 0, -10),
    _V(20, 0, -10),
    _V(20, 0, 10),
    _V(-20, 0, 10),
  ], _lit(_Colors.table, _V.up));
  _quad(canvas, pens, const [
    _V(-20, 0, 10),
    _V(20, 0, 10),
    _V(20, -2, 10),
    _V(-20, -2, 10),
  ], _lit(_Colors.table, const _V(0, 0, 1)));
  // Front edge highlight of the table top.
  canvas.drawLine(
    _cam.p(const _V(-20, 0, 10)),
    _cam.p(const _V(20, 0, 10)),
    pens.stroke
      ..strokeWidth = 1.5
      ..color = labShade(_Colors.table, 0.25),
  );
}

/// Paints the HTML Three.js scene: table, beaker (water, ice, bubbles,
/// steam), thermometer, kettle, tripod stand, Bunsen burner and flame, the
/// 3D labels, drop guides and the drop feedback. Static parts come from
/// [_PaintCache].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.button,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Size of the scene icon buttons (design px), for their pulsing rings.
  final double button;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    canvas.drawPicture(cache.backdrop(size));
    final s = scene;
    final t = s.time;
    final held = s.held;

    _paintShadows(canvas);
    if (s.tripod) _paintStand(canvas);
    if (held != _Item.beaker) _paintBeaker(canvas, s.beakerPos);
    if (s.kettleShown && held != _Item.kettle) _paintKettle(canvas);
    if (s.steam) _paintSteam(canvas, s.beakerPos);
    if (s.thermoShown && !s.thermoPlaced && held != _Item.thermometer) {
      final (bulb, angle) = s.thermoPose();
      _paintThermometer(canvas, bulb, angle);
    }
    _paintDragGlow(canvas, t);
    if (showLabels) _paintLabels(canvas);
    if (held != null) _paintGuide(canvas, held);
    switch (held) {
      case _Item.beaker:
        _paintBeaker(canvas, s.beakerPos);
      case _Item.kettle:
        _paintKettle(canvas);
      case _Item.thermometer:
        if (!s.thermoPlaced) {
          _paintThermometer(canvas, s.thermo.at(t), 0);
        }
      case null:
        break;
    }
    _paintButtonRings(canvas, t);
    _paintFeedback(canvas, t);
  }

  // ------------------------------------------------------------ helpers

  /// Projected circle of radius [r] at height [y] above [c] into [out]
  /// (index i at angle i · 2π / N from +x towards +z).
  List<Offset> _ring(_V c, double y, double r, List<Offset> out) {
    for (var i = 0; i < _ringN; i++) {
      final a = i * 2 * math.pi / _ringN;
      out[i] = _cam.p(
        _V(c.x + r * math.cos(a), c.y + y, c.z + r * math.sin(a)),
      );
    }
    return out;
  }

  static int _minX(List<Offset> pts) {
    var k = 0;
    for (var i = 1; i < pts.length; i++) {
      if (pts[i].dx < pts[k].dx) k = i;
    }
    return k;
  }

  static int _maxX(List<Offset> pts) {
    var k = 0;
    for (var i = 1; i < pts.length; i++) {
      if (pts[i].dx > pts[k].dx) k = i;
    }
    return k;
  }

  /// Outline of a vertical cylinder seen from above: the far half of the
  /// [top] circle, the sides and the near half of the [bottom] circle.
  void _hull(Path path, List<Offset> top, List<Offset> bottom) {
    path.reset();
    final tl = _minX(top), tr = _maxX(top);
    final bl = _minX(bottom), br = _maxX(bottom);
    path.moveTo(top[tl].dx, top[tl].dy);
    // Far half: left → back (index N · 3/4) → right.
    for (var i = tl; i != tr; i = (i + 1) % _ringN) {
      final o = top[(i + 1) % _ringN];
      path.lineTo(o.dx, o.dy);
    }
    path.lineTo(bottom[br].dx, bottom[br].dy);
    // Near half: right → front (index N / 4) → left.
    for (var i = br; i != bl; i = (i + 1) % _ringN) {
      final o = bottom[(i + 1) % _ringN];
      path.lineTo(o.dx, o.dy);
    }
    path.close();
  }

  /// The closed polygon of a projected circle.
  void _ellipse(Path path, List<Offset> pts) {
    path
      ..reset()
      ..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < _ringN; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
  }

  /// The near half (front, index 0 → N / 2) of a projected circle.
  void _frontArc(Path path, List<Offset> pts) {
    path
      ..reset()
      ..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i <= _ringN ~/ 2; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
  }

  /// The far half (back, index N / 2 → N) of a projected circle.
  void _backArc(Path path, List<Offset> pts) {
    path
      ..reset()
      ..moveTo(pts[_ringN ~/ 2].dx, pts[_ringN ~/ 2].dy);
    for (var i = _ringN ~/ 2 + 1; i <= _ringN; i++) {
      final o = pts[i % _ringN];
      path.lineTo(o.dx, o.dy);
    }
  }

  /// A vertical rod (leg, tube) from [a] up to [b], [r] thick.
  void _rod(Canvas canvas, _V a, _V b, double r, Color color) {
    final w = 2 * r * _cam.scaleAt(_V.lerp(a, b, 0.5));
    canvas.drawLine(
      _cam.p(a),
      _cam.p(b),
      _pens.bar
        ..strokeWidth = w
        ..color = color,
    );
    // Lit edge (the key light comes from +x).
    final edge = Offset(w * 0.25, 0);
    canvas.drawLine(
      _cam.p(a) + edge,
      _cam.p(b) + edge,
      _pens.bar
        ..strokeWidth = w * 0.25
        ..color = labShade(color, 0.3),
    );
  }

  // ----------------------------------------------------------- shadows

  void _paintShadows(Canvas canvas) {
    final s = scene;
    void blob(_V at, double rx, double rz) {
      final c = _cam.p(at);
      final w = 2 * rx * _cam.scaleAt(at);
      final h = (_cam.p(at + _V(0, 0, rz)).dy - _cam.p(at - _V(0, 0, rz)).dy)
          .abs();
      canvas.drawOval(
        Rect.fromCenter(center: c, width: w, height: math.max(4, h)),
        _pens.shadow,
      );
    }

    final b = s.beakerPos;
    if (b.y < 0.5 && s.held != _Item.beaker) {
      blob(_V(b.x - 0.4, 0.01, b.z - 0.3), _beakerR + 0.3, _beakerR + 0.3);
    }
    if (s.tripod) blob(const _V(-0.3, 0.01, -0.2), _legSpread + 0.6, 3.4);
    if (s.kettleShown && !s.pouring && s.held != _Item.kettle) {
      final k = s.kettlePos;
      if (k.y - _kettleBaseDrop < 0.5) blob(_V(k.x, 0.01, 0), 2.4, 2.2);
    }
  }

  // ------------------------------------------------- stand and burner

  /// Tripod stand, Bunsen burner and flame (HTML `tripod`, `burner`),
  /// drawn below the beaker it carries.
  void _paintStand(Canvas canvas) {
    final s = scene;
    final legs = [
      for (var i = 0; i < 3; i++)
        _V(
          _legSpread * math.cos(i * 2 * math.pi / 3),
          0,
          _legSpread * math.sin(i * 2 * math.pi / 3),
        ),
    ];
    final leg = _lit(_Colors.tripod, const _V(0.6, 0, 0.8));
    // Legs behind the burner first.
    for (final l in legs) {
      if (l.z <= 0.01) {
        _rod(canvas, l, l + const _V(0, _standTop, 0), _legR, leg);
      }
    }
    _paintBurner(canvas);
    if (s.flame) _paintFlame(canvas);
    for (final l in legs) {
      if (l.z > 0.01) {
        _rod(canvas, l, l + const _V(0, _standTop, 0), _legR, leg);
      }
    }
    // Ring (TorusGeometry 3.5) and the wire gauze it carries.
    final ring = _ring(_V.zero, _standTop, _ringR, _pens.ringA);
    _ellipse(_pens.path, ring);
    canvas.drawPath(
      _pens.path,
      _pens.stroke
        ..strokeWidth = 2 * _ringTube * _cam.scaleAt(const _V(0, _standTop, 0))
        ..color = _lit(_Colors.tripod, _V.up),
    );
    const g = _gauzeHalf;
    const y = _standTop + 0.05;
    _quad(canvas, _pens, const [
      _V(-g, y, -g),
      _V(g, y, -g),
      _V(g, y, g),
      _V(-g, y, g),
    ], _Colors.gauze.withValues(alpha: 0.9));
    final mesh = _pens.stroke
      ..strokeWidth = 0.8
      ..color = _Colors.slate300.withValues(alpha: 0.45);
    for (var i = 1; i < 8; i++) {
      final v = -g + i * 2 * g / 8;
      canvas.drawLine(_cam.p(_V(v, y, -g)), _cam.p(_V(v, y, g)), mesh);
      canvas.drawLine(_cam.p(_V(-g, y, v)), _cam.p(_V(g, y, v)), mesh);
    }
    // Ceramic centre of the gauze.
    _ellipse(_pens.path, _ring(_V.zero, y + 0.01, 1.8, _pens.ringB));
    canvas.drawPath(
      _pens.path,
      _pens.fill..color = _Colors.slate300.withValues(alpha: 0.75),
    );
  }

  /// Brass base and grey tube of the Bunsen burner.
  void _paintBurner(Canvas canvas) {
    // Base: a frustum from r 2 (floor) to 1.5 (top).
    final bottom = _ring(_V.zero, 0, _burnerBaseR, _pens.ringA);
    final top = _ring(_V.zero, _burnerBaseTop, _burnerBaseRTop, _pens.ringB);
    _hull(_pens.path, top, bottom);
    canvas.drawPath(
      _pens.path,
      _pens.fill..color = _lit(_Colors.brass, const _V(0, 0, 1)),
    );
    _ellipse(_pens.path, top);
    canvas.drawPath(
      _pens.path,
      _pens.fill..color = labShade(_Colors.brass, 0.25),
    );
    // Tube.
    final tBottom = _ring(_V.zero, _burnerBaseTop, _burnerTubeR, _pens.ringA);
    final tTop = _ring(_V.zero, _burnerTubeTop, _burnerTubeR, _pens.ringB);
    _hull(_pens.path, tTop, tBottom);
    canvas.drawPath(
      _pens.path,
      _pens.fill..color = _lit(_Colors.burnerTube, const _V(0, 0, 1)),
    );
    _ellipse(_pens.path, tTop);
    canvas.drawPath(_pens.path, _pens.fill..color = _Colors.slate800);
  }

  /// Dual-colour flame (orange outer cone, blue inner cone) that flickers
  /// (HTML random `scale` 1–1.2 high, 1–1.1 wide per frame).
  void _paintFlame(Canvas canvas) {
    final t = scene.time;
    final sy = 1.1 + 0.1 * math.sin(t * 37) * math.cos(t * 23);
    final sx = 1.05 + 0.05 * math.sin(t * 29 + 1);
    final glowAt = _cam.p(const _V(0, 4.6, 0));
    final k = _cam.scaleAt(const _V(0, 4.6, 0));
    canvas.drawCircle(
      glowAt,
      2.2 * k,
      _pens.soft..color = _Colors.flameOuter.withValues(alpha: 0.3),
    );
    void cone(double base, double tip, double r, Color color) {
      final b = _cam.p(_V(0, base, 0));
      final top = _cam.p(_V(0, base + (tip - base) * sy, 0));
      final w = r * sx * _cam.scaleAt(_V(0, base, 0));
      final path = _pens.path
        ..reset()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(b.dx + w * 1.1, b.dy - w * 0.6, b.dx + w, b.dy)
        ..arcToPoint(
          Offset(b.dx - w, b.dy),
          radius: Radius.elliptical(w, w * 0.3),
        )
        ..quadraticBezierTo(b.dx - w * 1.1, b.dy - w * 0.6, top.dx, top.dy)
        ..close();
      canvas.drawPath(path, _pens.fill..color = color);
    }

    cone(
      _flameOuterBase,
      _flameOuterTip,
      _flameOuterR,
      _Colors.flameOuter.withValues(alpha: 0.75),
    );
    cone(
      _flameInnerBase,
      _flameInnerTip,
      _flameInnerR,
      _Colors.flameInner.withValues(alpha: 0.9),
    );
  }

  // ------------------------------------------------------------- beaker

  /// The beaker standing at [b] with its water, ice, bubbles and (when
  /// placed) the thermometer, behind its front glass and rim.
  void _paintBeaker(Canvas canvas, _V b) {
    final s = scene;
    final t = s.time;
    final pens = _pens;
    final top = _ring(b, _beakerH, _beakerR, pens.ringA);
    final bottom = _ring(b, 0, _beakerR, pens.ringB);
    // Inner glass (seen through the front).
    _hull(pens.path, top, bottom);
    canvas.drawPath(
      pens.path,
      pens.fill..color = _Colors.glass.withValues(alpha: 0.1),
    );
    // Back rim.
    _backArc(pens.path2, top);
    canvas.drawPath(
      pens.path2,
      pens.stroke
        ..strokeWidth = math.max(1.2, 2 * _rimTube * _cam.scaleAt(b))
        ..color = _Colors.glass.withValues(alpha: 0.45),
    );

    // Water, from the floor up (the HTML scaled it about the middle).
    final level = s.water.at(t) * _waterFull;
    final alpha = s.waterAlpha.at(t);
    if (level > 0.03) {
      final wTop = _ring(b, level, _waterR, pens.ringA);
      final wBottom = _ring(b, 0.05, _waterR, pens.ringB);
      _hull(pens.path, wTop, wBottom);
      canvas.drawPath(
        pens.path,
        pens.fill..color = _Colors.water.withValues(alpha: alpha),
      );
      _ellipse(pens.path, wTop);
      canvas.drawPath(
        pens.path,
        pens.fill
          ..color = labShade(_Colors.water, 0.3).withValues(alpha: alpha),
      );
    }

    if (s.ice) _paintIce(canvas, b);
    if (s.bubbles && level > 0.5) _paintBubbles(canvas, b, level);
    if (s.thermoPlaced && s.held != _Item.thermometer) {
      final (bulb, angle) = s.thermoPose();
      _paintThermometer(canvas, bulb, angle);
    }
    if (s.thermoPlaced && s.held == _Item.thermometer) {
      _paintThermometer(canvas, s.thermo.at(t), 0);
    }

    // Front glass: tint, highlight streaks, graduations and rim.
    final frontTop = _ring(b, _beakerH, _beakerR, pens.ringA);
    final frontBottom = _ring(b, 0, _beakerR, pens.ringB);
    _hull(pens.path, frontTop, frontBottom);
    canvas.drawPath(
      pens.path,
      pens.fill..color = _Colors.glass.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      pens.path,
      pens.stroke
        ..strokeWidth = 1.4
        ..color = _Colors.glass.withValues(alpha: 0.55),
    );
    final k = _cam.scaleAt(b + const _V(0, 4, 0));
    for (final (dx, w) in const [(-2.2, 0.35), (2.3, 0.18)]) {
      canvas.drawLine(
        _cam.p(b + _V(dx, 0.6, 1.8)),
        _cam.p(b + _V(dx, _beakerH - 0.6, 1.8)),
        pens.stroke
          ..strokeWidth = w * k
          ..color = _Colors.white.withValues(alpha: 0.18),
      );
    }
    _paintGraduations(canvas, b);
    _frontArc(pens.path2, frontTop);
    canvas.drawPath(
      pens.path2,
      pens.stroke
        ..strokeWidth = math.max(1.5, 2 * _rimTube * _cam.scaleAt(b))
        ..color = _Colors.glass.withValues(alpha: 0.85),
    );
    // Spout on the right of the rim (HTML sphere 0.5 at (3, 8, 0)).
    final spout = _cam.p(b + const _V(_beakerR + 0.25, _beakerH, 0));
    canvas.drawOval(
      Rect.fromCenter(center: spout, width: 0.9 * k, height: 0.45 * k),
      pens.stroke
        ..strokeWidth = 1.4
        ..color = _Colors.glass.withValues(alpha: 0.8),
    );
  }

  /// Graduations 50–250 mL on the front left of the glass.
  void _paintGraduations(Canvas canvas, _V b) {
    final mark = _pens.stroke
      ..strokeWidth = 1.2
      ..color = _Colors.white.withValues(alpha: 0.75);
    _V onGlass(double angle, double y) =>
        b +
        _V(
          (_beakerR + 0.02) * math.cos(angle),
          y,
          (_beakerR + 0.02) * math.sin(angle),
        );
    for (final ml in _gradMl) {
      final y = _beakerH * ml / _gradFullMl;
      canvas.drawLine(
        _cam.p(onGlass(_gradAngle, y)),
        _cam.p(onGlass(_gradAngle - 0.32, y)),
        mark,
      );
      if (ml < _gradMl.last) {
        final yMinor = _beakerH * (ml + 25) / _gradFullMl;
        canvas.drawLine(
          _cam.p(onGlass(_gradAngle, yMinor)),
          _cam.p(onGlass(_gradAngle - 0.18, yMinor)),
          mark,
        );
      }
      final tp = cache.grad('$ml');
      final at = _cam.p(onGlass(_gradAngle + 0.08, y));
      tp.paint(canvas, Offset(at.dx - tp.width, at.dy - tp.height / 2));
    }
    final ml = cache.grad('mL');
    final at = _cam.p(onGlass(_gradAngle - 0.12, _beakerH * 0.86));
    ml.paint(canvas, Offset(at.dx - ml.width / 2, at.dy - ml.height / 2));
  }

  /// Crushed ice (HTML `iceMesh`), shrinking as it melts.
  void _paintIce(Canvas canvas, _V b) {
    final k = scene.iceScale.at(scene.time);
    final path = _pens.path;
    for (final c in _cubes) {
      final centre = b + _V(c.pos.x, c.pos.y * (0.4 + 0.6 * k), c.pos.z);
      final p = _cam.p(centre);
      final r = c.r * k * _cam.scaleAt(centre);
      if (r < 0.6) continue;
      path.reset();
      for (var i = 0; i < 6; i++) {
        final a = c.turn + i * math.pi / 3;
        final q = p + Offset(math.cos(a), math.sin(a)) * (r * c.jitter[i]);
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        _pens.fill..color = const Color(0xFFE0F2FE).withValues(alpha: 0.62),
      );
      canvas.drawPath(
        path,
        _pens.stroke
          ..strokeWidth = 1
          ..color = _Colors.white.withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        p + Offset(-0.3 * r, -0.3 * r),
        0.22 * r,
        _pens.fill..color = _Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  /// Bubbles rising through boiling water (HTML `bubbles`).
  void _paintBubbles(Canvas canvas, _V b, double level) {
    final t = scene.time;
    final span = level - 0.4;
    for (final (x, z, speed, phase) in _bubbleSeeds) {
      final y = 0.4 + (phase * span + t * speed) % span;
      final c = b + _V(x * 0.6, y, z * 0.6);
      final p = _cam.p(c);
      final r = 0.2 * _cam.scaleAt(c);
      canvas.drawCircle(
        p,
        r,
        _pens.fill..color = _Colors.white.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        p,
        r,
        _pens.stroke
          ..strokeWidth = 1
          ..color = _Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  /// Steam rising from the beaker (HTML `steamParticles`).
  void _paintSteam(Canvas canvas, _V b) {
    final s = scene;
    final fadeIn = ((s.time - s.steamSince) / 1.0).clamp(0.0, 1.0);
    final warm = s.scenario == 0;
    for (final (x, z, speed, phase) in _steamSeeds) {
      final rise = (phase * _steamRise + s.time * speed) % _steamRise;
      final f = rise / _steamRise;
      final c = b + _V(x, _beakerH + rise, z);
      final r = (0.8 + 0.6 * f) * _cam.scaleAt(c);
      final a = (warm ? 0.22 : 0.32) * (1 - f) * fadeIn;
      canvas.drawCircle(
        _cam.p(c),
        r,
        _pens.soft..color = _Colors.white.withValues(alpha: a),
      );
    }
  }

  // -------------------------------------------------------- thermometer

  /// The laboratory thermometer with its bulb at [bulb], tilted by [angle]
  /// (0 upright): white glass tube with scale marks every 10 °C, red bulb
  /// and the alcohol column for the current temperature.
  void _paintThermometer(Canvas canvas, _V bulb, double angle) {
    final dir = _V(-math.sin(angle), math.cos(angle), 0);
    final pb = _cam.p(bulb);
    final pt = _cam.p(bulb + dir * _tubeLen);
    final k = _cam.scaleAt(bulb + dir * (_tubeLen / 2));
    final axis = pt - pb;
    final len = axis.distance;
    if (len < 1) return;
    final n = Offset(-axis.dy, axis.dx) / len;
    // Tube.
    canvas.drawLine(
      pb + axis * (0.3 / _tubeLen),
      pt,
      _pens.stroke
        ..strokeWidth = 2 * _tubeR * k
        ..color = _Colors.tube.withValues(alpha: 0.88),
    );
    // Alcohol column.
    final h = _fluidHeight(scene.temperature);
    canvas.drawLine(
      pb,
      _cam.p(bulb + dir * h),
      _pens.bar
        ..strokeWidth = math.max(2.5, 2 * _fluidR * k * 1.3)
        ..color = _Colors.alcohol,
    );
    // Scale marks, 0–110 °C every 10 °C (longer at 0, 50, 100).
    final mark = _pens.bar
      ..strokeWidth = 1
      ..color = _Colors.tubeMark;
    for (var c = 0; c <= _scaleMax; c += 10) {
      final at = _cam.p(bulb + dir * _fluidHeight(c.toDouble()));
      final long = c % 50 == 0 ? 0.36 : 0.22;
      final side = n * (_tubeR * k * 0.95);
      canvas.drawLine(at - side, at - side + n * (long * k), mark);
    }
    // Bulb (red, slightly glowing like the HTML emissive material).
    final r = _bulbR * _cam.scaleAt(bulb);
    canvas.drawCircle(pb, r, _pens.fill..color = _Colors.alcohol);
    canvas.drawCircle(
      pb + Offset(-0.35 * r, -0.35 * r),
      0.3 * r,
      _pens.fill..color = _Colors.white.withValues(alpha: 0.55),
    );
    // Glass highlight along the tube.
    canvas.drawLine(
      pb + axis * 0.08 + n * (_tubeR * k * 0.45),
      pt - axis * 0.03 + n * (_tubeR * k * 0.45),
      _pens.stroke
        ..strokeWidth = math.max(1, 0.12 * k)
        ..color = _Colors.white.withValues(alpha: 0.7),
    );
  }

  // -------------------------------------------------------------- kettle

  /// The kettle at its place, held, or tipped over the beaker pouring warm
  /// water.
  void _paintKettle(Canvas canvas) {
    final s = scene;
    final t = s.time;
    final centre = s.kettlePos;
    var tilt = 0.0;
    var alpha = 1.0;
    if (s.pouring) {
      final e = ((t - s.pourStart) / _tipSeconds).clamp(0.0, 1.0);
      tilt = _pourTilt * Curves.easeOut.transform(e);
      // Fades out over the pour's last 0.25 s.
      alpha = ((s.pourStart + _pourSeconds - t) / 0.25).clamp(0.0, 1.0);
      if (e >= 1) _paintStream(canvas, alpha);
    }
    final c = _cam.p(centre);
    final k = _cam.scaleAt(centre) * _kettleUnit;
    final paths = cache.kettle;
    Color a(Color color) => color.withValues(alpha: color.a * alpha);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    canvas.scale(k);
    canvas.translate(-_kettleSvgCenter.dx, -_kettleSvgCenter.dy);
    canvas.drawPath(paths.body, _pens.fill..color = a(_Colors.kettleBody));
    canvas.drawPath(
      paths.handle,
      _pens.stroke
        ..strokeWidth = 8
        ..color = a(_Colors.kettleHandle),
    );
    canvas.drawPath(paths.spout, _pens.fill..color = a(_Colors.kettleBody));
    canvas.drawRRect(paths.base, _pens.fill..color = a(_Colors.kettleBase));
    canvas.drawPath(paths.lid, _pens.fill..color = a(_Colors.kettleLid));
    canvas.drawCircle(
      const Offset(50, 24),
      5,
      _pens.fill..color = a(_Colors.kettleKnob),
    );
    canvas.drawPath(
      paths.shine,
      _pens.fill..color = _Colors.white.withValues(alpha: 0.2 * alpha),
    );
    canvas.restore();
  }

  /// Warm water running from the spout into the beaker.
  void _paintStream(Canvas canvas, double alpha) {
    final s = scene;
    final b = s.beakerBase;
    final spout = _cam.p(_pourCenter + _spoutLocal);
    final level = s.water.at(s.time) * _waterFull;
    final end = _cam.p(b + _V(0.6, level, 0));
    final k = _cam.scaleAt(b + const _V(0, 8, 0));
    final path = _pens.path
      ..reset()
      ..moveTo(spout.dx, spout.dy)
      ..quadraticBezierTo(
        spout.dx - 0.4 * k,
        spout.dy + 0.6 * k,
        end.dx,
        end.dy,
      );
    canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = 0.45 * k
        ..color = _Colors.water.withValues(alpha: 0.8 * alpha),
    );
    canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = 0.12 * k
        ..color = _Colors.blue300.withValues(alpha: 0.8 * alpha),
    );
  }

  // ----------------------------------------------------- guides, glows

  /// Pulsing glow round each object the learner may drag now (HTML
  /// `drag-pulse` blue, `drag-pulse-red` for the thermometer).
  void _paintDragGlow(Canvas canvas, double t) {
    final s = scene;
    if (s.held != null) return;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi);
    void glow(Rect r, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.inflate(6), const Radius.circular(12)),
        _pens.glow
          ..strokeWidth = 3 + 5 * pulse
          ..color = color.withValues(alpha: 0.35 + 0.45 * pulse),
      );
    }

    if (s.canDragBeaker) glow(_beakerBox(s.beakerPos), _Colors.blue500);
    if (s.canDragKettle) glow(_kettleBox(s.kettlePos), _Colors.blue500);
    if (s.canDragThermometer || s.canLiftOut) {
      glow(_thermoBox(s.thermo.at(t)), _Colors.red500);
    }
  }

  /// Drop guide while an object is held (HTML `.drop-target.active` /
  /// `.error`): green where it would be accepted, red where the
  /// thermometer would be refused.
  void _paintGuide(Canvas canvas, _Item held) {
    final s = scene;
    final idle = _Colors.white.withValues(alpha: 0.45);
    final ok = _Colors.emerald400;
    final bad = _Colors.red500;
    final dash = _pens.stroke..strokeWidth = 2;
    void ring(_V centre, double r, Color color) {
      _ellipse(_pens.path, _ring(centre, 0, r, _pens.ringB));
      labDashedPath(canvas, _pens.path, dash..color = color, dash: 7, gap: 5);
    }

    switch (held) {
      case _Item.beaker:
        final p = s.beakerPos;
        if (s.tripod) {
          final hit =
              p.x.abs() <= _standCatchX &&
              p.y >= _standCatchLow &&
              p.y <= _standCatchHigh;
          ring(
            const _V(0, _standTop + 0.07, 0),
            _beakerR + 0.2,
            hit ? ok : idle,
          );
        } else {
          final hit = p.x.abs() <= _tableCatchX && p.y <= _tableCatchY;
          ring(const _V(0, 0.02, 0), _beakerR + 0.2, hit ? ok : idle);
        }
      case _Item.kettle:
        final c = s.kettlePos;
        final hit =
            c.x.abs() <= _kettleCatchX &&
            c.y - _kettleBaseDrop <= _kettleCatchY;
        ring(
          s.beakerBase + const _V(0, _beakerH, 0),
          _beakerR + 0.3,
          hit ? ok : idle,
        );
      case _Item.thermometer:
        if (s.liftingOut) return;
        final base = s.beakerBase;
        final rel = s.thermo.at(s.time) - base;
        final edge =
            rel.x.abs() <= _edgeHalf && rel.y >= _edgeLow && rel.y <= _edgeHigh;
        final top = s.liquidTop - _surfaceGap;
        final good =
            rel.x.abs() <= _centreHalf && rel.y >= _floorGap && rel.y <= top;
        final zone = _bounds([
          base + const _V(-_centreHalf, _floorGap, 0),
          base + _V(_centreHalf, top, 0),
        ]);
        final path = _pens.path
          ..reset()
          ..addRRect(RRect.fromRectAndRadius(zone, const Radius.circular(6)));
        canvas.drawPath(
          path,
          _pens.fill
            ..color = (good ? ok : (edge ? bad : _Colors.white)).withValues(
              alpha: 0.14,
            ),
        );
        labDashedPath(
          canvas,
          path,
          dash..color = good ? ok : (edge ? bad : idle),
          dash: 7,
          gap: 5,
        );
    }
  }

  /// Pulsing rings round the magnifying glass and flame buttons (HTML
  /// `pulse-highlight`, 1.5 s).
  void _paintButtonRings(Canvas canvas, double t) {
    final s = scene;
    final e = (t % 1.5) / 1.5;
    void ring(Offset c, Color color) {
      canvas.drawCircle(
        c,
        button / 2 + 4 + 14 * e,
        _pens.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.7 * (1 - e)),
      );
    }

    if (s.magnifier) ring(_magnifierAt(s), _Colors.blue500);
    if (s.flameButton) ring(_flameAt, _Colors.orange500);
  }

  /// HTML `#feedback-icon`: green tick or red cross popping up where the
  /// thermometer was dropped.
  void _paintFeedback(Canvas canvas, double t) {
    final s = scene;
    final at = s.feedbackAt;
    if (at == null) return;
    final shown = s.feedbackOk ? _tickSeconds : _crossSeconds;
    final e = t - s.feedbackStart;
    if (e < 0 || e > shown + 0.3) return;
    final grow = Curves.easeOutBack.transform((e / 0.3).clamp(0.0, 1.0));
    final shrink = 1 - ((e - shown) / 0.3).clamp(0.0, 1.0);
    final r = 22 * grow * shrink;
    if (r <= 0.5) return;
    canvas.drawCircle(
      at,
      r,
      _pens.fill..color = s.feedbackOk ? _Colors.emerald500 : _Colors.red500,
    );
    final mark = _pens.stroke
      ..strokeWidth = r * 0.2
      ..color = _Colors.white;
    final path = _pens.path..reset();
    if (s.feedbackOk) {
      path
        ..moveTo(at.dx - r * 0.45, at.dy + r * 0.02)
        ..lineTo(at.dx - r * 0.1, at.dy + r * 0.38)
        ..lineTo(at.dx + r * 0.48, at.dy - r * 0.32);
    } else {
      path
        ..moveTo(at.dx - r * 0.38, at.dy - r * 0.38)
        ..lineTo(at.dx + r * 0.38, at.dy + r * 0.38)
        ..moveTo(at.dx + r * 0.38, at.dy - r * 0.38)
        ..lineTo(at.dx - r * 0.38, at.dy + r * 0.38);
    }
    canvas.drawPath(path, mark);
  }

  // -------------------------------------------------------------- labels

  /// HTML 3D labels (`initLabels`): Beaker, Thermometer, Tripod Stand,
  /// Bunsen Burner (and Kettle). Each sits beside its object, not over it.
  void _paintLabels(Canvas canvas) {
    final s = scene;
    final held = s.held;
    if (held != _Item.beaker) {
      _chip(
        canvas,
        _cam.p(s.beakerPos + const _V(_beakerR + 0.6, 2, 0)),
        _t('lbl_beaker'),
        edge: -1,
      );
    }
    if (s.kettleShown && !s.pouring && held != _Item.kettle) {
      _chip(
        canvas,
        _cam.p(s.kettlePos + const _V(0, 3.6, 0)),
        _t('lbl_kettle'),
      );
    }
    if (s.thermoShown && held != _Item.thermometer) {
      final (bulb, angle) = s.thermoPose();
      if (angle > 0.01) {
        // Lying on the table: beside its left end.
        final tip = bulb + _V(-math.sin(angle), math.cos(angle), 0) * _tubeLen;
        _chip(
          canvas,
          _cam.p(tip + const _V(-0.6, 0, 0)),
          _t('lbl_thermo'),
          edge: 1,
        );
      } else if (s.thermoPlaced) {
        _chip(
          canvas,
          _cam.p(bulb + const _V(0.9, _tubeLen - 2.5, 0)),
          _t('lbl_thermo'),
          edge: -1,
        );
      } else {
        _chip(
          canvas,
          _cam.p(bulb + const _V(-0.9, _tubeLen - 2.5, 0)),
          _t('lbl_thermo'),
          edge: 1,
        );
      }
    }
    if (s.tripod) {
      _chip(
        canvas,
        _cam.p(const _V(-_legSpread - 0.9, 4.5, 0)),
        _t('lbl_tripod'),
        edge: 1,
      );
      _chip(
        canvas,
        _cam.p(const _V(-_burnerBaseR - 0.6, 1, 0)),
        _t('lbl_burner'),
        edge: 1,
      );
    }
  }

  /// A label chip centred on [at]; with [edge] −1 its left edge sits on
  /// [at], with 1 its right edge.
  void _chip(Canvas canvas, Offset at, String text, {double edge = 0}) {
    final p = isDark ? _Theme.dark : _Theme.light;
    final tp = cache.label(text, p.labelText);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final rect = Rect.fromCenter(
      center: at.translate(-edge * w / 2, 0),
      width: w,
      height: tp.height + 2 * padY,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.4));
    canvas.drawRRect(rr, _pens.fill..color = p.labelBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = isDark ? _Colors.slate600 : _Colors.slate300,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.button != button;
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups), controller, widgets, painting helpers and shell
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

  /// Success popup body and header.
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

  /// [color] used as text or a small icon on this palette's panels and
  /// cards: unchanged in the dark theme; in the light theme a colour too
  /// bright to read on white (ZSL yellow is about 2:1) is darkened to about
  /// 5:1.
  Color ink(Color color) =>
      isDark || color.computeLuminance() < _inkMaxLuminance
      ? color
      : Color.lerp(color, LabInk.black, _inkDarken)!;

  /// The accent as a text colour (see [ink]).
  Color get accentInk => ink(accent);

  /// Brighter colours than this are darkened by [_inkDarken] for light-theme
  /// text.
  static const double _inkMaxLuminance = 0.3;
  static const double _inkDarken = 0.42;

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
    sliderTheme: SliderThemeData(activeTrackColor: accent, thumbColor: accent),
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
    assert(
      scope != null,
      'No LabStyleScope: build lab widgets inside a LabShell.',
    );
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

/// Neutral colours the shell itself uses (shadows, scrims, clear fills,
/// pure white / black for shading). Activity colours come from the
/// activity's own palette.
abstract final class LabInk {
  static const Color clear = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Card shadows, from light to heavy (HTML `shadow-lg` / `shadow-2xl`).
  static const Color shadowSoft = Color(0x40000000);
  static const Color shadow = Color(0x55000000);
  static const Color shadowStrong = Color(0x66000000);

  /// Dimmed backdrop behind dialogs and the popup's drop shadow.
  static const Color scrim = Color(0x80000000);
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

/// Strings used by the shared lab shell (header, sidebar, tools,
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
    'msg_scenario_complete':
        'Scenario Complete! Please select the next scenario.',
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

  // ------------------------------------------------- language, theme, font

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
  void showPopup(
    LabPopupBuilder builder, {
    LabTone? sound,
    bool silent = false,
  }) {
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
  /// conclusion popup. After the last scenario (or once every scenario is
  /// done) the popup offers "Restart Lab"; otherwise "Continue" closes it
  /// and shows the "Scenario Complete" toast.
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
    final allDone =
        scenarioIndex >= totalScenarios - 1 ||
        completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(
        () => LabPopupContent(
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
        ),
      );
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
Rect labBleed(Size size) => Rect.fromLTRB(
  -size.width * 1.5,
  -size.height * 1.5,
  size.width * 2.5,
  size.height * 2.5,
);

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
  const LabZoomViewer({
    super.key,
    required this.controller,
    required this.child,
  });

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
    widget.controller.transform.value = tween.transform(
      Curves.easeOutCubic.transform(_anim.value),
    );
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
    final target = (scale * factor).clamp(
      LabController.minZoom,
      LabController.maxZoom,
    );
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
  if (amount >= 0) return Color.lerp(c, LabInk.white, amount.clamp(0, 1))!;
  return Color.lerp(c, LabInk.black, (-amount).clamp(0, 1))!;
}

/// Letter spacing is inserted between glyph clusters, which splits Devanagari
/// conjuncts and vowel signs apart ('वर्तमान उद्दे श्य'). Text that contains
/// Devanagari is therefore always drawn with normal spacing.
double labLetterSpacing(String text, double spacing) =>
    _labDevanagari.hasMatch(text) ? 0 : spacing;

final RegExp _labDevanagari = RegExp('[\u0900-\u097F]');

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = LabInk.white,
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
        letterSpacing: labLetterSpacing(text, letterSpacing),
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
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(radius, h / 2)),
    );
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = LabInk.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        rr,
        Paint()..color = background.withValues(alpha: background.a * opacity),
      );
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
  Color color = LabInk.white,
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
  Color color = LabInk.white,
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
void labDashedPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dash = 8,
  double gap = 6,
  double phase = 0,
}) {
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
void labGlow(
  Canvas canvas,
  Offset c,
  double r,
  Color color, {
  double intensity = 1,
}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
          color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.35, 1],
      ).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(
  Canvas canvas,
  Offset c,
  double w,
  double h, {
  double opacity = 0.3,
}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = LabInk.black.withValues(alpha: opacity)
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(front, Radius.circular(radius)),
      frontPaint,
    );
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
    ..arcTo(
      Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh),
      math.pi,
      -math.pi,
      false,
    )
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(
        colors: [
          a(labShade(color, -0.35)),
          a(labShade(color, 0.25)),
          a(color),
          a(labShade(color, -0.45)),
        ],
        stops: const [0, 0.3, 0.6, 1],
      ).createShader(rect),
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
    final lr = Rect.fromLTRB(
      inner.left,
      inner.bottom - h,
      inner.right,
      inner.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        lr,
        bottomLeft: Radius.circular(r),
        bottomRight: Radius.circular(r),
      ),
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
      Rect.fromCenter(
        center: Offset(lr.center.dx, lr.top),
        width: lr.width,
        height: lr.width * 0.12,
      ),
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
      ..color = LabInk.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(
        Offset(rect.right - rect.width * 0.25, y),
        Offset(rect.right - 3, y),
        g,
      );
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
    ..arcToPoint(
      Offset(rect.right, rect.bottom - r),
      radius: Radius.circular(r),
      clockwise: false,
    )
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(
      Path()
        ..addPath(path, Offset.zero)
        ..close(),
    );
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
void labFlame(
  Canvas canvas,
  Offset base,
  double height,
  double t, {
  double intensity = 1,
}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(
    canvas,
    base.translate(0, -h * 0.45),
    h * 1.1,
    const Color(0xFFF97316),
    intensity: 0.55 * intensity,
  );
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(
      base.dx + w * sx,
      base.dy - h * sy * 0.55,
      base.dx + w * sx * 0.9,
      base.dy,
      base.dx,
      base.dy,
    )
    ..cubicTo(
      base.dx - w * sx * 0.9,
      base.dy,
      base.dx - w * sx,
      base.dy - h * sy * 0.55,
      base.dx,
      base.dy - h * sy,
    )
    ..close();
  canvas.drawPath(
    flame(1, 1),
    Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9),
  );
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(
    flame(0.35, 0.4),
    Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9),
  );
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(
  Canvas canvas,
  Offset from,
  Offset to,
  double t, {
  Color color = const Color(0xFFF97316),
  double amp = 6,
  double width = 3,
}) {
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
  labArrow(
    canvas,
    from + u * (len - 14),
    to,
    color: color,
    width: width,
    head: 11,
  );
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
    fill.computeLuminance() > 0.45 ? palette.onAccent : LabInk.white;

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
        child: ConstrainedBox(
          // 48 dp tap target however small the scale.
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (a.icon != null) ...[
                  Icon(
                    a.icon,
                    size: 16 * s,
                    color: fg.withValues(alpha: enabled ? 1 : 0.6),
                  ),
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

/// Lays out a list of actions as full-width buttons, [columns] per row (a
/// last odd button spans its row; buttons in a row share its height).
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
    this.columns = 1,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final gap = 8 * scale;
    final rows = <Widget>[
      for (var i = 0; i < actions.length; i += columns)
        if (columns <= 1)
          LabActionButton(action: actions[i], scale: scale, dense: dense)
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var j = i;
                  j < math.min(i + columns, actions.length);
                  j++
                ) ...[
                  if (j > i) SizedBox(width: gap),
                  Expanded(
                    child: LabActionButton(
                      action: actions[j],
                      scale: scale,
                      dense: dense,
                    ),
                  ),
                ],
              ],
            ),
          ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
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
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) &
              card.size
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
        _keepInside(
          offset.dx,
          home.left,
          home.right,
          bounds.left,
          bounds.right,
        ),
        _keepInside(
          offset.dy,
          home.top,
          home.bottom,
          bounds.top,
          bounds.bottom,
        ),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(
    double shift,
    double start,
    double end,
    double lo,
    double hi,
  ) {
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

    if (w.left == null &&
        w.top == null &&
        w.right == null &&
        w.bottom == null) {
      // Centred card: the whole layer is shifted by the drag offset, so the
      // card is laid out (and therefore hit-tested) exactly where it is drawn.
      return Stack(
        children: [
          Positioned(
            left: o.dx,
            top: o.dy,
            right: -o.dx,
            bottom: -o.dy,
            child: Center(child: placed),
          ),
        ],
      );
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
            ? const [
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 11,
    this.icon,
  });

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = LabStyleScope.of(context).palette;
    final c = palette.ink(color ?? palette.accent);
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
              letterSpacing: labLetterSpacing(text, 1.1),
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
            materialTapTargetSize: MaterialTapTargetSize.padded,
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
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
              ),
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
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 16),
        ],
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
              letterSpacing: labLetterSpacing(text, 2),
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
///   header (title, language, reset), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup.
///
/// Every floating card (popup, mission card, HUD objective and the
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
    this.hud,
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

  /// Short task line for the canvas HUD only (the HTML `sN_hud_M` texts);
  /// defaults to the current objective. The sidebar keeps the step text.
  final String? hud;

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
  EdgeInsets _canvasMargin(EdgeInsets pad) => EdgeInsets.fromLTRB(
    4,
    4,
    widget.showTools ? _kToolColumnClearance + pad.right : 4,
    4,
  );

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 &&
        overlay.top == 0 &&
        overlay.right == 0 &&
        overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        // Keyed overlays keep their dragged offset even when an earlier
        // overlay appears or disappears (the index would shift).
        id: overlay.key != null
            ? 'overlay-${overlay.key}'
            : 'overlay-$index-${overlay.child.runtimeType}',
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
        final font = c.style.font.orAmbient(
          Theme.of(context).textTheme.bodyMedium,
        );
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        // Any tap re-hides the system bars; not a control, so it stays out
        // of the semantics tree.
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
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
                          duration: _resizing
                              ? Duration.zero
                              : const Duration(milliseconds: 380),
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
                                    child: _Sidebar(
                                      shell: widget,
                                      palette: p,
                                      scale: s,
                                    ),
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
                          child: _FloatingMissionCard(
                            shell: widget,
                            palette: p,
                            scale: s,
                          ),
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
                    if (c.popup != null)
                      _PopupLayer(controller: c, palette: p, scale: s),
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

  Widget _buildCanvas(
    BuildContext context,
    LabPalette p,
    double s,
    EdgeInsets pad,
  ) {
    final c = widget.controller;
    final w = widget;
    final instruction = w.hud ?? _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++)
            _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: _kToolColumnClearance + 4 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(
                    text: instruction,
                    palette: p,
                    scale: s,
                    label: c.t('curr_obj'),
                  ),
                ),
              ),
            ),
          // Below the Back button; scrolls on screens too short for all
          // six 48 dp tools.
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: _kToolColumnTop + pad.top,
              bottom: 8 + pad.bottom,
              child: Center(
                child: SingleChildScrollView(
                  child: _ToolsPanel(controller: c, palette: p, scale: s),
                ),
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

  Widget _buildCurtain(
    BuildContext context,
    LabPalette p,
    double s,
    EdgeInsets pad,
  ) {
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
                gradient: RadialGradient(
                  colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)],
                  radius: 0.9,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32 * s,
                        vertical: 24 * s,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(
                              begin: 0.55,
                              end: 1.0,
                            ).animate(_iconPulse),
                            child: Icon(
                              widget.icon,
                              size: 56 * s,
                              color: p.accent,
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: labLetterSpacing(
                                widget.title,
                                -0.5,
                              ),
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainMuted,
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30 * s,
                                vertical: 14 * s,
                              ),
                              textStyle: TextStyle(
                                fontSize: 17 * s,
                                fontWeight: FontWeight.w800,
                              ),
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
                label: Text(
                  c.lang.badge,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top of the canvas tool column: just below the Back button (16 + 48 dp).
const double _kToolColumnTop = 72;

/// Room kept free of canvas cards on the right for the tool column (8 dp
/// margin + 48 dp tools + card padding + a small gap).
const double _kToolColumnClearance = 72;

/// Screens shorter than this (phones in landscape) get the compact floating
/// mission card.
const double _kCompactMissionCardBelow = 480;

/// Tallest the compact mission card gets, as a fraction of the screen height
/// (its text scrolls beyond that).
const double _kCompactMissionCardMaxHeight = 0.55;

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) =>
    (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen
      ? 8.0
      : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(
    left,
    8 + pad.top,
    _kToolColumnClearance + pad.right,
    8 + pad.bottom,
  );
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.shell,
    required this.palette,
    required this.scale,
  });

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
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 18, offset: Offset(4, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The title row is pinned above the scroll view. The fixed menu
          // button sits over its left end, so nothing that scrolls passes
          // under the button (the band ends below the button's 64 px).
          Padding(
            padding: EdgeInsets.fromLTRB(
              12 * s + pad.left,
              12 + pad.top,
              12 * s,
              8,
            ),
            child: _titleRow(p, s),
          ),
          Expanded(child: _scrollBody(context, p, s, f, pad)),
        ],
      ),
    );
  }

  Widget _scrollBody(
    BuildContext context,
    LabPalette p,
    double s,
    double f,
    EdgeInsets pad,
  ) {
    final c = shell.controller;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12 * s + pad.left, 2 * s, 12 * s, 8 * s),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _header(context, p, s),
              SizedBox(height: 12 * s),
              if (shell.scenarioNames.length > 1) ...[
                _scenarioSelector(p, s, f),
                SizedBox(height: 12 * s),
              ],
              _targetOutput(p, s, f),
              if (shell.actions.isNotEmpty) ...[
                SizedBox(height: 14 * s),
                LabSectionLabel(
                  c.t('actions'),
                  size: 10.5 * s,
                  icon: Icons.touch_app,
                ),
                SizedBox(height: 8 * s),
                LabActionList(actions: shell.actions, scale: s),
              ],
              if (shell.sidebarExtra != null) ...[
                SizedBox(height: 14 * s),
                LabSectionLabel(
                  shell.sidebarExtraTitle ?? c.t('controls'),
                  size: 10.5 * s,
                  icon: Icons.tune,
                ),
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
              padding: EdgeInsets.fromLTRB(
                10 * s + pad.left,
                10 * s,
                10 * s,
                10 * s + pad.bottom,
              ),
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
                  letterSpacing: labLetterSpacing(c.t('footer'), 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Activity icon, title and subtitle. Leaves room for the fixed menu
  /// button at top-left.
  Widget _titleRow(LabPalette p, double s) {
    return Padding(
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
              child: Icon(shell.icon, color: p.accentInk, size: 20 * s),
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
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 10 * s,
                      height: 1.2,
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

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(
      IconData icon,
      String tip,
      VoidCallback onTap, {
      String? text,
    }) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            // Scales down instead of overflowing while the page is still
            // portrait and the sidebar is very narrow.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17 * s, color: p.textStrong),
                  if (text != null) ...[
                    SizedBox(width: 4 * s),
                    Text(
                      text,
                      style: TextStyle(
                        color: p.textStrong,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * s,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Language and Reset share one row and split the sidebar width, so they
    // stay side by side at every sidebar width (20% to 50%). The row is
    // indented like the title row above it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: Row(
            children: [
              Expanded(
                child: headerBtn(
                  Icons.translate,
                  c.t('toggle_language'),
                  c.toggleLanguage,
                  text: c.lang.badge,
                ),
              ),
              SizedBox(width: 6 * s),
              Expanded(
                child: headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
                  c.style.click.play();
                  c.requestFullReset();
                }),
              ),
            ],
          ),
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
            style: TextStyle(
              color: p.textMuted,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: labLetterSpacing(c.t('select_scenario'), 1),
            ),
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
      color: selected ? p.accent.withValues(alpha: 0.16) : LabInk.clear,
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
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : (selected
                          ? Icons.menu_book
                          : Icons.radio_button_unchecked),
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
          LabSectionLabel(
            c.t('target_output'),
            size: 10.5 * s,
            icon: Icons.track_changes,
          ),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(
                color: p.text,
                fontSize: 12.5 * f,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                // Flexible: "चरण 1 में से 3" at the largest font is wider than a
                // narrow sidebar; it wraps instead of overflowing.
                Flexible(
                  child: Text(
                    '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11 * f,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                                : (i == cur
                                      ? p.accent
                                      : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(
                              color: i < cur
                                  ? p.info
                                  : (i == cur ? p.accent : p.cardBorder),
                            ),
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
                      Icon(Icons.info, size: 14 * s, color: p.accentInk),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accentInk,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: labLetterSpacing(c.t('curr_obj'), 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null &&
                      step.concept.isNotEmpty &&
                      shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 10.5 * f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 12.5 * f,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
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
  const _FloatingMissionCard({
    required this.shell,
    required this.palette,
    required this.scale,
  });

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
    // Phones in landscape: a compact card (step + instruction beside the
    // minimize button, no objective) of at most 55% of the screen height, so
    // it leaves the scene free.
    final compact = size.height < _kCompactMissionCardBelow;

    final stepSpan = steps.isEmpty
        ? null
        : TextSpan(
            text:
                '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
            style: TextStyle(color: p.accentInk, fontWeight: FontWeight.w800),
          );
    final instructionStyle = TextStyle(
      color: p.textStrong,
      fontSize: 11.5 * s,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
    final toggle = InkWell(
      onTap: () {
        c.style.click.play();
        setState(() => _minimized = !_minimized);
      },
      child: Tooltip(
        message: _minimized ? c.t('expand') : c.t('minimize'),
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Icon(
            _minimized ? Icons.expand_more : Icons.expand_less,
            size: 20 * s,
            color: p.textMuted,
          ),
        ),
      ),
    );
    final actions = [
      if (!_minimized && shell.actions.isNotEmpty) ...[
        SizedBox(height: 6 * s),
        LabActionList(
          actions: shell.actions,
          scale: s,
          dense: true,
          // Two per row in the compact card, so they stay in view.
          columns: compact && shell.actions.length >= 3 ? 2 : 1,
        ),
      ],
    ];

    final List<Widget> children;
    if (compact) {
      children = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4 * s),
                child: Text.rich(
                  TextSpan(
                    children: [
                      ?stepSpan,
                      TextSpan(
                        text: instruction.isEmpty
                            ? c.t('mission_obj')
                            : instruction,
                      ),
                    ],
                  ),
                  maxLines: _minimized ? 1 : null,
                  overflow: _minimized ? TextOverflow.ellipsis : null,
                  style: instructionStyle,
                ),
              ),
            ),
            toggle,
          ],
        ),
        ...actions,
      ];
    } else {
      children = [
        Row(
          children: [
            Icon(Icons.flag_rounded, size: 15 * s, color: p.accentInk),
            SizedBox(width: 5 * s),
            Expanded(
              child: Text(
                c.t('mission_obj').toUpperCase(),
                style: TextStyle(
                  color: p.accentInk,
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: labLetterSpacing(c.t('mission_obj'), 1),
                ),
              ),
            ),
            toggle,
          ],
        ),
        if (!_minimized) ...[
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 6 * s),
            Text(
              shell.objective,
              style: TextStyle(
                color: p.text,
                fontSize: 11.5 * s,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
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
                    ?stepSpan,
                    TextSpan(text: instruction),
                  ],
                ),
                style: instructionStyle,
              ),
            ),
          ],
          ...actions,
        ],
      ];
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: compact
            ? size.height * _kCompactMissionCardMaxHeight
            : size.height - 24,
      ),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all((compact ? 7 : 10) * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.text,
    required this.palette,
    required this.scale,
    required this.label,
  });

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
                Icon(Icons.info, size: 12 * s, color: palette.accentInk),
                SizedBox(width: 4 * s),
                // Flexible: while the page is still rotating to landscape
                // the chip can be narrower than the label.
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.accentInk,
                      fontWeight: FontWeight.w800,
                      fontSize: 9 * s,
                      letterSpacing: labLetterSpacing(label, 1),
                    ),
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
              style: TextStyle(
                color: palette.textStrong,
                fontWeight: FontWeight.w700,
                fontSize: 11 * s,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({
    required this.controller,
    required this.palette,
    required this.scale,
  });

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    // Visible highlight inside each 48 dp tap target.
    final highlight = (34 * s).clamp(30.0, 42.0);
    Widget tool(
      IconData icon,
      String tip,
      VoidCallback onTap, {
      bool active = false,
    }) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox.square(
            dimension: kMinInteractiveDimension,
            child: Center(
              child: Container(
                width: highlight,
                height: highlight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? p.accent.withValues(alpha: 0.18)
                      : LabInk.clear,
                ),
                child: Icon(
                  icon,
                  size: 19 * s,
                  color: active ? p.accentInk : p.textMuted,
                ),
              ),
            ),
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
          tool(
            c.showLabels ? Icons.label : Icons.label_off,
            c.t('tool_labels'),
            c.toggleLabels,
            active: c.showLabels,
          ),
          divider,
          tool(
            c.camLocked ? Icons.lock : Icons.lock_open,
            c.t('tool_lock'),
            c.toggleCamLock,
            active: c.camLocked,
          ),
          tool(
            Icons.pan_tool_alt,
            c.t('tool_pan'),
            c.togglePanMode,
            active: c.panMode,
          ),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({
    required this.toast,
    required this.palette,
    required this.scale,
  });

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
            position: Tween(
              begin: const Offset(0, -0.4),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: LabInk.shadow, blurRadius: 12),
                  ],
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
                          color: t.isError
                              ? palette.onDanger
                              : palette.toastText,
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
  const _PopupLayer({
    required this.controller,
    required this.palette,
    required this.scale,
  });

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
    final accentInk = p.ink(accent);
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Material(
            color: LabInk.clear,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [
                  BoxShadow(
                    color: LabInk.scrim,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * s,
                      vertical: 8 * s,
                    ),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accentInk, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(
                              color: accentInk,
                              fontWeight: FontWeight.w800,
                              fontSize: 14 * s,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.drag_indicator,
                          size: 18 * s,
                          color: p.textMuted,
                        ),
                        IconButton(
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
                                border: Border(
                                  bottom: BorderSide(color: p.cardBorder),
                                ),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accentInk,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: labLetterSpacing(
                                    content.heading!,
                                    1,
                                  ),
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
                          if (content.extra != null) ...[
                            SizedBox(height: 10 * s),
                            content.extra!,
                          ],
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
