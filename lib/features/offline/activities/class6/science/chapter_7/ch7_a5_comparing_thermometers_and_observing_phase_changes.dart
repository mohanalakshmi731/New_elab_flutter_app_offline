// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 7 • Activity 5
/// Comparing Thermometers and Observing Phase Changes.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A5-Comparing_Thermometers_and_Observing_Phase_Changes.html`.
///
/// Scenario 1 (The Unreliable Hand): put the left hand into ice-cold water
/// and the right hand into warm water, then both into the same tap water:
/// it feels warm to one hand and cold to the other. A laboratory
/// thermometer gives the water's one true temperature (25 °C).
///
/// Scenario 2 (The Constant Temperature of Change): a thermometer in crushed
/// ice reads 0 °C; heated by a Bunsen burner, the ice melts while the
/// reading stays at 0 °C, then the water warms up and boils while the
/// reading stays at 98 °C.
class Ch7A5ComparingThermometersAndObservingPhaseChangesPage
    extends StatefulWidget {
  const Ch7A5ComparingThermometersAndObservingPhaseChangesPage({super.key});

  @override
  State<Ch7A5ComparingThermometersAndObservingPhaseChangesPage> createState() =>
      _ThermometerLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises two tones with WebAudio:
/// 'pop' (snaps, buttons, toggles) and 'success' (thermometer / burner
/// placed, both hands in the tap water, conclusion).
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// success → `math/success.mp3`, pickup → `science/pickup.mp3`,
/// drop → `science/drop.mp3`, wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`: a hand snapping into a beaker, the flame
  /// button, Fast Forward, every UI button.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('success')`.
  success('audio/class6/math/success.mp3'),

  /// An object picked up (the HTML is silent here).
  pickup('audio/class6/science/pickup.mp3'),

  /// An object put back after a missed drop (the HTML is silent here).
  drop('audio/class6/science/drop.mp3'),

  /// The shell's error tone, with the error toast of a missed drop.
  wrong('audio/class6/science/error.mp3');

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

/// Tailwind colours of the HTML page and the materials of its Three.js
/// scene.
abstract final class _Colors {
  // ------------------------------------------------------------- page / UI
  static const Color blue400 = Color(0xFF60A5FA);

  /// The page's accent (`text-blue-500`, buttons, HUD border) and the
  /// thermometer's inner flame cone (0x3b82f6).
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  /// The right hand after warm water (`#fca5a5`).
  static const Color red300 = Color(0xFFFCA5A5);

  /// Thermometer bulb and thread (0xef4444), "Warm!" bubble.
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  /// Outer flame cone (0xf97316) and the flame button.
  static const Color orange500 = Color(0xFFF97316);

  /// The left hand after ice-cold water (`#bae6fd`).
  static const Color sky200 = Color(0xFFBAE6FD);

  /// Burner icon (`#6366f1`).
  static const Color indigo500 = Color(0xFF6366F1);
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
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  // ----------------------------------------------------------------- scene
  /// Back wall (PlaneGeometry, 0x0f172a) and lab table (BoxGeometry,
  /// 0x1e293b).
  static const Color wall = slate900;
  static const Color table = slate800;

  /// Hand icon: skin `#ffcb9a`, outline `#c0865c`.
  static const Color skin = Color(0xFFFFCB9A);
  static const Color skinEdge = Color(0xFFC0865C);

  /// Glass (MeshPhysicalMaterial 0xf8fafc, transmission 0.95).
  static const Color glass = slate50;

  /// Liquids: warm 0xffcccc, tap 0xeeeeff, ice-cold / melt water 0xccffff.
  static const Color warmWater = Color(0xFFFFCCCC);
  static const Color tapWater = Color(0xFFEEEEFF);
  static const Color coldWater = Color(0xFFCCFFFF);

  /// Ice cubes (0xeff6ff).
  static const Color ice = Color(0xFFEFF6FF);

  /// Tripod (0x475569), burner base (0xd97706) and tube (0x94a3b8).
  static const Color tripod = slate600;
  static const Color burnerBase = Color(0xFFD97706);
  static const Color burnerTube = slate400;

  /// Scene labels: `.glass-panel` (rgba(15, 23, 42, 0.92)) with a
  /// slate-600 border.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBorder = slate600;

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML's accent is blue (Enter Lab, buttons, HUD).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950, // scene.background 0x020617
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
    info: _Colors.emerald400, // completed steps (dark:text-emerald-400)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.blue500,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100, // setTheme(): scene.background 0xf1f5f9
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // completed steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.blue600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font slider (12–22 px, default 15 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The
/// HTML plays its 'pop' for every UI action (buttons, toggles, scenario
/// change, Enter Lab).
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.pop,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.pop,
  curtain: _Sound.pop,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Changes
// (see the report): each step's action says exactly what to do on a touch
// screen (the drags, the flame button, 'Fast Forward', 'Observe
// Conclusion'); the S2 step 3 HUD named a 'Next Setup' button that does not
// exist and stated the result before it was observed; the ice beaker has
// its own label (the HTML reused "Beaker B (Tap)"); the literal *asterisks*
// are gone; the Hindi S1 summary gained its missing "relative change"
// clause; the S2 summary says where 98 °C comes from. Keys marked "added"
// are new texts: error toasts for a missed drop, the flame button's label.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Comparing Thermometers and Observing Phase Changes',
    'app_subtitle': 'Class 6 • Temperature and its Measurements',
    'scen_1_opt': 'Scenario 1: The Unreliable Hand',
    'scen_2_opt': 'Scenario 2: The Constant Temperature of Change',
    's1_desc':
        'To demonstrate that our sense of touch is a relative and unreliable way to judge temperature.',
    's2_desc':
        'To measure and observe the constant temperatures at which ice melts and water boils.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Sensation Setup',
    's1_a1':
        'Drag the Left Hand into Beaker C (Ice-Cold) and the Right Hand into Beaker A (Warm).',
    's1_o1': 'Left hand feels cold, right hand feels warm.',
    's1_c2': 'Conflicting Feelings',
    's1_a2':
        'Wait 3 seconds while the hands adjust, then drag both hands into the beaker of tap water (Beaker B).',
    's1_o2':
        'Left hand feels warm, while the right hand feels cold in the SAME water.',
    's1_c3': 'Reliable Measurement',
    's1_a3': 'Drag the laboratory thermometer into the tap water (Beaker B).',
    's1_o3': 'The thermometer provides a single, objective measurement.',
    's1_c4': 'Conclusion',
    's1_a4':
        "Observe the final, stable reading on the thermometer, then tap 'Observe Conclusion'.",
    's1_o4':
        'The water has one objective temperature, proving touch is unreliable.',
    // Scenario 2 steps.
    's2_c1': 'Thermometer in Ice',
    's2_a1': 'Drag the thermometer into the beaker of crushed ice.',
    's2_o1': 'Temperature drops and stabilizes at 0 °C.',
    's2_c2': 'Heating Begins',
    's2_a2':
        'Drag the Bunsen burner under the beaker (below the tripod stand), then tap the flame button to light it.',
    's2_o2': 'Flame appears and begins heating the beaker.',
    's2_c3': 'Melting Point',
    's2_a3':
        "Tap 'Fast Forward' and observe the temperature as the ice melts completely.",
    's2_o3': 'The temperature only starts rising after all the ice has melted.',
    's2_c4': 'Boiling Point',
    's2_a4':
        "Tap 'Fast Forward' and observe the temperature as the water heats and boils.",
    's2_o4': 'Temperature rises steadily, then stops and holds constant.',
    's2_c5': 'Phase Change Rule',
    's2_a5': "Note the final temperature, then tap 'Observe Conclusion'.",
    's2_o5': 'Temperature stays at 98 °C while vigorously boiling.',
    // HUD lines ("Current Task").
    's1_hud_1':
        'Step 1: DRAG Left Hand into Beaker C and Right Hand into Beaker A.',
    's1_hud_2': 'Step 2: WAIT, then DRAG both hands into Beaker B (Tap Water).',
    's1_hud_3': 'Step 3: DRAG the Thermometer into Beaker B.',
    's1_hud_4':
        "Step 4: OBSERVE the reliable reading. Tap 'Observe Conclusion'.",
    's2_hud_1': 'Step 1: DRAG the Thermometer into the beaker of crushed ice.',
    's2_hud_2':
        'Step 2: OBSERVE the temperature (0 °C). DRAG the Bunsen burner under the beaker and TAP the flame button to heat.',
    's2_hud_3':
        "Step 3: Tap 'Fast Forward' and OBSERVE the ice melting. What does the temperature do?",
    's2_hud_4':
        "Step 4: Tap 'Fast Forward', then watch the water heat up and begin to boil vigorously.",
    's2_hud_5':
        "Step 5: OBSERVE the stable temperature (98 °C) during boiling. Tap 'Observe Conclusion'.",
    // Toasts.
    'toast_waiting_hands': 'Waiting 3s for hands to adjust...',
    'toast_ff': 'Fast Forward...',
    'toast_melting_notice':
        'Notice: The temperature only starts rising after all ice melts.',
    // Added: a missed drop (the HTML put the object back silently).
    'err_left_hand': 'Put the Left Hand into Beaker C (Ice-Cold).',
    'err_right_hand': 'Put the Right Hand into Beaker A (Warm).',
    'err_hands_b': 'Put both hands into Beaker B (Tap Water).',
    'err_thermo_b': 'Put the thermometer into Beaker B (Tap Water).',
    'err_thermo_ice': 'Put the thermometer into the beaker of crushed ice.',
    'err_burner':
        'Put the Bunsen burner under the beaker, below the tripod stand.',
    // Buttons (the flame button's label is added: the HTML's has an icon
    // only).
    'btn_fast_forward': 'Fast Forward',
    'btn_conclude': 'Observe Conclusion',
    'btn_light': 'Light the Burner',
    // Scene.
    'warm_exclaim': 'Warm!',
    'cold_exclaim': 'Cold!',
    'lbl_beaker_a': 'Beaker A (Warm)',
    'lbl_beaker_b': 'Beaker B (Tap)',
    'lbl_beaker_c': 'Beaker C (Ice-Cold)',
    'lbl_beaker_ice': 'Beaker (Crushed Ice)',
    'lbl_thermo': 'Thermometer',
    'lbl_tripod': 'Tripod Stand',
    'lbl_burner': 'Bunsen Burner',
    'lbl_left_hand': 'Left Hand',
    'lbl_right_hand': 'Right Hand',
    'scene_s1':
        'Beakers of warm, tap and ice-cold water on a lab table, two hands and a thermometer',
    'scene_s2':
        'A beaker of crushed ice on a tripod stand, a thermometer and a Bunsen burner',
    // Summary popups.
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1_title': 'Objective Truth!',
    'sum_s1_desc':
        'Our sense of touch can be misleading because it measures relative change, not absolute temperature. The water in Beaker B has exactly one temperature (25 °C), proving that a thermometer provides a reliable measurement.',
    'sum_s2_title': 'Phase Change Rule!',
    'sum_s2_desc':
        'The temperature of melting ice is constant at 0 °C. The temperature of boiling water is constant at its boiling point (about 98 °C in this example; at sea level pure water boils at 100 °C). Temperature does not change during a phase change!',
    // Teacher board accordion.
    'concept_exp': 'Observation Steps',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
  },
  'hi': {
    'app_title': 'थर्मामीटर की तुलना और अवस्था परिवर्तन',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'scen_1_opt': 'परिदृश्य 1: अविश्वसनीय हाथ',
    'scen_2_opt': 'परिदृश्य 2: परिवर्तन का स्थिर तापमान',
    's1_desc':
        'यह प्रदर्शित करना कि स्पर्श की हमारी भावना तापमान को मापने का एक सापेक्ष और अविश्वसनीय तरीका है।',
    's2_desc': 'बर्फ पिघलने और पानी उबलने के स्थिर तापमान को मापना और देखना।',
    's1_c1': 'संवेदना सेटअप',
    's1_a1':
        'बाएं हाथ को बीकर C (बर्फ जैसा ठंडा) में और दाएं हाथ को बीकर A (गर्म) में खींचें।',
    's1_o1': 'बायां हाथ ठंडा महसूस करता है, दायां हाथ गर्म महसूस करता है।',
    's1_c2': 'विरोधाभासी भावनाएं',
    's1_a2':
        'हाथों के अनुकूल होने तक 3 सेकंड प्रतीक्षा करें, फिर दोनों हाथों को नल के पानी वाले बीकर (बीकर B) में खींचें।',
    's1_o2': 'एक ही पानी में बाएं हाथ को गर्म और दाएं हाथ को ठंडा लगता है।',
    's1_c3': 'विश्वसनीय मापन',
    's1_a3': 'प्रयोगशाला थर्मामीटर को नल के पानी (बीकर B) में खींचें।',
    's1_o3': 'थर्मामीटर एक एकल, वस्तुनिष्ठ माप प्रदान करता है।',
    's1_c4': 'निष्कर्ष',
    's1_a4':
        "थर्मामीटर पर अंतिम, स्थिर रीडिंग देखें, फिर 'निष्कर्ष देखें' दबाएं।",
    's1_o4':
        'पानी का एक वस्तुनिष्ठ तापमान है, जो साबित करता है कि स्पर्श अविश्वसनीय है।',
    's2_c1': 'बर्फ में थर्मामीटर',
    's2_a1': 'थर्मामीटर को कुचली हुई बर्फ वाले बीकर में खींचें।',
    's2_o1': 'तापमान गिरकर 0 °C पर स्थिर हो जाता है।',
    's2_c2': 'गर्म करना शुरू',
    's2_a2':
        'बुनसेन बर्नर को बीकर के नीचे (तिपाई स्टैंड के नीचे) खींचें, फिर उसे जलाने के लिए लौ वाला बटन दबाएं।',
    's2_o2': 'लौ दिखाई देती है और बीकर को गर्म करना शुरू कर देती है।',
    's2_c3': 'गलनांक',
    's2_a3': "'फास्ट फॉरवर्ड' दबाएं और बर्फ पूरी तरह पिघलने तक तापमान देखें।",
    's2_o3': 'सारी बर्फ पिघलने के बाद ही तापमान बढ़ना शुरू होता है।',
    's2_c4': 'क्वथनांक',
    's2_a4':
        "'फास्ट फॉरवर्ड' दबाएं और पानी गर्म होने और उबलने पर तापमान देखें।",
    's2_o4': 'तापमान लगातार बढ़ता है, फिर रुक जाता है और स्थिर रहता है।',
    's2_c5': 'अवस्था परिवर्तन नियम',
    's2_a5': "अंतिम तापमान पर ध्यान दें, फिर 'निष्कर्ष देखें' दबाएं।",
    's2_o5': 'तेजी से उबलते समय तापमान 98 °C पर रहता है।',
    's1_hud_1':
        'चरण 1: बाएं हाथ को बीकर C में और दाएं हाथ को बीकर A में खींचें।',
    's1_hud_2':
        'चरण 2: प्रतीक्षा करें, फिर दोनों हाथों को बीकर B (नल का पानी) में खींचें।',
    's1_hud_3': 'चरण 3: थर्मामीटर को बीकर B में खींचें।',
    's1_hud_4': "चरण 4: विश्वसनीय रीडिंग देखें। 'निष्कर्ष देखें' दबाएं।",
    's2_hud_1': 'चरण 1: थर्मामीटर को कुचली हुई बर्फ के बीकर में खींचें।',
    's2_hud_2':
        'चरण 2: तापमान (0 °C) देखें। बुनसेन बर्नर को बीकर के नीचे खींचें और गर्म करने के लिए लौ वाला बटन दबाएं।',
    's2_hud_3':
        "चरण 3: 'फास्ट फॉरवर्ड' दबाएं और बर्फ को पिघलते हुए देखें। तापमान का क्या होता है?",
    's2_hud_4':
        "चरण 4: 'फास्ट फॉरवर्ड' दबाएं, फिर पानी को गर्म होते और तेजी से उबलते हुए देखें।",
    's2_hud_5':
        "चरण 5: उबलने के दौरान स्थिर तापमान (98 °C) देखें। 'निष्कर्ष देखें' दबाएं।",
    'toast_waiting_hands':
        'हाथों के अनुकूल होने के लिए 3 सेकंड प्रतीक्षा करें...',
    'toast_ff': 'फास्ट फॉरवर्ड...',
    'toast_melting_notice':
        'ध्यान दें: सारी बर्फ पिघलने के बाद ही तापमान बढ़ना शुरू होता है।',
    'err_left_hand': 'बाएं हाथ को बीकर C (बर्फ जैसा ठंडा) में रखें।',
    'err_right_hand': 'दाएं हाथ को बीकर A (गर्म) में रखें।',
    'err_hands_b': 'दोनों हाथों को बीकर B (नल का पानी) में रखें।',
    'err_thermo_b': 'थर्मामीटर को बीकर B (नल का पानी) में रखें।',
    'err_thermo_ice': 'थर्मामीटर को कुचली हुई बर्फ वाले बीकर में रखें।',
    'err_burner': 'बुनसेन बर्नर को बीकर के नीचे, तिपाई स्टैंड के नीचे रखें।',
    'btn_fast_forward': 'फास्ट फॉरवर्ड',
    'btn_conclude': 'निष्कर्ष देखें',
    'btn_light': 'बर्नर जलाएं',
    'warm_exclaim': 'गर्म!',
    'cold_exclaim': 'ठंडा!',
    'lbl_beaker_a': 'बीकर A (गर्म)',
    'lbl_beaker_b': 'बीकर B (नल का पानी)',
    'lbl_beaker_c': 'बीकर C (बर्फ जैसा ठंडा)',
    'lbl_beaker_ice': 'बीकर (कुचली हुई बर्फ)',
    'lbl_thermo': 'थर्मामीटर',
    'lbl_tripod': 'तिपाई स्टैंड',
    'lbl_burner': 'बुनसेन बर्नर',
    'lbl_left_hand': 'बायां हाथ',
    'lbl_right_hand': 'दायां हाथ',
    'scene_s1':
        'प्रयोगशाला की मेज पर गर्म, नल के और बर्फ जैसे ठंडे पानी के बीकर, दो हाथ और एक थर्मामीटर',
    'scene_s2':
        'तिपाई स्टैंड पर कुचली हुई बर्फ का बीकर, एक थर्मामीटर और एक बुनसेन बर्नर',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1_title': 'वस्तुनिष्ठ सत्य!',
    'sum_s1_desc':
        'हमारी स्पर्श की भावना भ्रामक हो सकती है, क्योंकि वह तापमान का सापेक्ष अंतर महसूस करती है, वास्तविक तापमान नहीं। बीकर B में पानी का ठीक एक तापमान (25 °C) है, जो यह साबित करता है कि थर्मामीटर एक विश्वसनीय मापन प्रदान करता है।',
    'sum_s2_title': 'अवस्था परिवर्तन नियम!',
    'sum_s2_desc':
        'पिघलती बर्फ का तापमान 0 °C पर स्थिर रहता है। उबलते पानी का तापमान उसके क्वथनांक पर स्थिर रहता है (यहाँ लगभग 98 °C; समुद्र तल पर शुद्ध पानी 100 °C पर उबलता है)। अवस्था परिवर्तन के दौरान तापमान नहीं बदलता है!',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
  },
};

/// Steps per scenario (HTML `steps`).
const List<int> _stepCounts = [4, 5];

/// Scenarios and steps for [lang], built from [_i18n] (HTML `ScenariosData`:
/// concept / action / observation per step).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      return [
        for (var n = 1; n <= _stepCounts.length; n++)
          LabScenarioData(
            title: t('scen_${n}_opt'),
            objective: t('s${n}_desc'),
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
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target (logical px) and the scene drags' touch slop
/// (Flutter's default is 18 px; short drags must pick objects up).
const double _minTouch = 48;
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

// ------------------------------------------------------------------ camera
// HTML `init3D()`: PerspectiveCamera(45°) at (0, 18, 50), OrbitControls
// target (0, 5, 0); the camera stays locked.

const _V _eye = _V(0, 18, 50);
const _V _target = _V(0, 5, 0);

/// 280 / tan(22.5°): the 45° vertical field of view over the 560 px stage.
const double _focal = 675.98;
const Offset _stageCentre = Offset(500, 280);

/// Per scenario: how far below the stage centre the look-at point is drawn
/// and the zoom. Scenario 2's thermometer stands in a beaker raised on the
/// tripod and reached past the top of the HTML view, under the toasts; its
/// view is a little smaller and lower.
const List<double> _viewDrop = [20, 38];
const List<double> _viewZoom = [1.0, 0.9];

/// Horizontal extent (design px, sidebar-open view) of each scenario's
/// objects and labels. While the sidebar is collapsed the floating mission
/// card covers the top-left of the canvas, so the scene slides (and if
/// needed shrinks) into the room between the card and the tool column,
/// easing over 380 ms like the sidebar.
const List<(double, double)> _extents = [(205, 800), (262, 760)];
const double _framingSeconds = 0.38;

/// LAB FRAMEWORK: the floating mission card's left edge (beside the menu
/// button) and the gap kept from it and from the tool column.
const double _missionCardLeft = 76;
const double _cardGap = 12;

/// Canvas text stays readable when the stage is scaled down (same rule as
/// the Chapter 4 and 5 labs); the draggable icons grow less.
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _iconMaxBoost = 1.25;

double _iconBoost(double labelScale) =>
    labelScale.clamp(1.0, _iconMaxBoost).toDouble();

// ------------------------------------------------------------------ scene
// HTML `init3D()` / `createBeakerSetup()`.

/// Lab table: BoxGeometry(40, 2, 20), top at y = 0.
const double _tableHalfX = 20;
const double _tableHalfZ = 10;
const double _tableDepth = 2;

/// Beakers: glass CylinderGeometry(3, 3, 8), liquid CylinderGeometry(2.8,
/// 2.8, 7). Scenario 1: A (warm) at x −12, B (tap) at 0, C (ice-cold) at
/// 12. Scenario 2: the ice beaker raised to y = 6 on the tripod.
const double _beakerRadius = 3;
const double _beakerHeight = 8;
const double _liquidRadius = 2.8;
const double _liquidHeight = 7;
const List<double> _beakerX = [-12, 0, 12];
const double _iceBeakerY = 6;

/// Scenario 2's beaker starts with a film of water (`water.scale.y =
/// 0.05`) that the melting ice fills to the top (`scale.y → 1`).
const double _iceWaterStart = 0.05;

/// Ice: 25 DodecahedronGeometry(0.6 … 1.1) within x, z ±1.75, y 0.5 … 5.5;
/// melting scales the group to 0.01.
const int _iceCount = 25;
const double _iceMinScale = 0.01;

/// HTML drop target (`userData.target`, y = 6 in each beaker): a hand snaps
/// there; in Beaker B the left hand sits 25 px left and the right hand 25 px
/// right of it (about 1.9 units).
const double _snapY = 6;
const double _handInBOffset = 1.9;

// -------------------------------------------------------------- thermometer
// HTML thermometer group: glass CylinderGeometry(0.4, 0.4, 18) from the
// bulb up, bulb SphereGeometry(0.6) at the group origin, thread
// CylinderGeometry(0.15) from the bulb up.

const double _thermoLength = 18;
const double _thermoRadius = 0.4;
const double _bulbRadius = 0.6;
const double _threadRadius = 0.15;

/// A laboratory thermometer reads −10 °C … 110 °C (NCERT). The HTML scaled
/// the thread non-linearly (25 °C at 25 % of the tube, 0 °C at 5 %, 98 °C at
/// 98 %); here the thread's height is linear in temperature, from 1 unit
/// above the bulb (−10 °C) to 17 units (110 °C).
const double _scaleMinC = -10;
const double _scaleMaxC = 110;
const double _scaleBottomY = 1;
const double _scaleTopY = 17;

/// Scenario 1: `thermometer.position.set(0, 4, 0)` in Beaker B. Scenario 2:
/// the HTML used the same (0, 4, 0), below the raised beaker; here the bulb
/// is in the crushed ice.
const _V _thermoInB = _V(0, 4, 0);
const _V _thermoInIce = _V(0, 7.2, 0);

/// Readings (°C): the room (thermometer at rest), the tap water, melting
/// ice and boiling water (HTML `updateZoomUI(25 / 0 / 98)`).
const double _roomC = 25;
const double _tapC = 25;
const double _iceC = 0;
const double _boilC = 98;

/// Lens colours follow the HTML zoom box: emerald at 0 °C, red at 98 °C,
/// blue otherwise.
const double _coldMarkC = 2;
const double _hotMarkC = 90;

// -------------------------------------------------------- tripod and burner

/// Tripod: TorusGeometry(3.5, 0.3) ring at y = 6 on three
/// CylinderGeometry(0.2) legs, 3 units from the centre (angles 0°, 120°,
/// 240°).
const double _tripodHeight = 6;
const double _ringRadius = 3.5;
const double _ringTube = 0.3;
const double _legRadius = 0.2;
const _V _legRight = _V(3, 0, 0);
const _V _legFront = _V(-1.5, 0, 2.598);
const _V _legBack = _V(-1.5, 0, -2.598);

/// Burner at the origin: base CylinderGeometry(1.5, 2, 1.5), tube
/// CylinderGeometry(0.5, 0.5, 2) above it, flame cones centred at y = 4.5.
const double _burnerBaseBottomR = 2;
const double _burnerBaseTopR = 1.5;
const double _burnerBaseH = 1.5;
const double _burnerTubeR = 0.5;
const double _burnerTubeH = 2;
const double _flameY = 4.5;

// ------------------------------------------------------------ drag items
// HTML `.drag-item` icons, positioned in % of the canvas; here anchored to
// world points beside the beakers so they follow the view.

/// Scenario 1 hands: the left hand starts on the left (HTML 20 %, 30 %),
/// the right hand on the right (80 %, 30 %); after the 3 s adaptation they
/// are lifted out above their beakers (HTML 70 % / 30 %).
const _V _leftHome = _V(-18, 13, 0);
const _V _rightHome = _V(18, 13, 0);
const _V _leftLift = _V(13.5, 13.5, 0);
const _V _rightLift = _V(-13.5, 13.5, 0);

/// Thermometer icon (HTML 80 %, 40 % in S1; 80 %, 30 % in S2) and burner
/// icon (20 %, 70 %).
const List<_V> _thermoIconHomes = [_V(18, 10, 0), _V(17, 15, 0)];
const _V _burnerIconHome = _V(-16, 2, 0);

/// The HTML flame button sat at 70 % of the canvas height below the
/// tripod; here in front of the placed burner.
const _V _flameButtonAt = _V(0, -1.2, 6);

/// Icon sizes (design px at the HTML scale): hand SVG 75 × 75, thermometer
/// SVG 40 × 160, burner SVG 60 × 60, flame button 56 (p-3 + 32 px icon).
const double _handPx = 75;
const double _thermoIconW = 40;
const double _thermoIconH = 160;
const double _burnerIconPx = 60;
const double _flameButtonPx = 56;

/// Space below a hand for its name chip (hit area).
const double _handLabelPx = 20;

/// Where a dragged icon may go (keeps it on the stage).
const double _dragMaxX = 24;
const double _dragMinY = -6;
const double _dragMaxY = 26;

/// A press that moves the icon less than this (units) is a tap, not a drop.
const double _dragMinMove = 0.3;

/// The thought bubbles float above the hands (HTML: projected (0, 10, 0)).
const double _bubbleY = 11.5;

/// Magnified scale beside the thermometer: 84 × 150 design px, showing
/// 10 °C around the reading with 1 °C marks.
const double _lensW = 84;
const double _lensH = 150;
const double _lensGap = 3.4;
const double _lensWindowC = 10;

/// Beaker labels sit under beakers 12 units apart; wider labels shrink.
const double _beakerLabelMax = 150;

/// The thermometer's label: left of its stem, 9.5 units above the bulb
/// (below the canvas's next-action button; the magnifier is on the right).
const _V _thermoLabelAt = _V(-0.8, 9.5, 0);

/// The canvas copy of the next-action button sits this far (logical px)
/// below the canvas's top inset, under the toasts.
const double _nextButtonTop = 48;

// ------------------------------------------------------------------ timings
// HTML setTimeouts and TWEEN durations.

const Duration _adaptDelay = Duration(seconds: 3); // 'Waiting 3s …'
const Duration _bubbleHold = Duration(milliseconds: 2500);
const double _settleS1 = 2; // tween to 25 °C, then the reading (2000 ms)
const double _settleS2 = 1.5; // tween to 0 °C, then the reading (1500 ms)
const Duration _flameDelay = Duration(milliseconds: 1500);
const double _meltSeconds = 5; // ice scale → 0.01, water scale → 1 (5000)
const Duration _afterMelt = Duration(milliseconds: 2500);
const double _heatSeconds = 4; // thread → 98 °C, Quadratic.InOut (4000)

/// Added: boiling goes on for 2 s with the reading held at 98 °C before
/// step 5 ("rises steadily, then stops and holds constant"); the HTML went
/// on as soon as 98 °C was reached.
const Duration _boilHold = Duration(seconds: 2);
const double _snapSeconds = 0.15;
const double _returnSeconds = 0.25;
const double _liftSeconds = 0.35;
const double _tintSeconds = 0.8; // `.hand-svg { transition: fill 0.8s }`
const double _bubblePopSeconds = 0.4;

/// HTML `.drag-pulse` (2 s) and `.pulse-highlight` (1.5 s) animations.
const double _pulseSeconds = 2;
const double _ringPulseSeconds = 1.5;

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);

  final double x;
  final double y;
  final double z;

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML camera projected onto the design stage: [focal] and [centre]
/// carry the scenario view and the collapsed-sidebar framing.
@immutable
class _Proj {
  const _Proj(this.centre, this.focal);

  /// Camera axes: forward (to the look-at point), right and up.
  static final _V f = (_target - _eye).unit;
  static final _V r = f.cross(const _V(0, 1, 0)).unit;
  static final _V u = r.cross(f);

  final Offset centre;
  final double focal;

  double depth(_V w) => (w - _eye).dot(f);

  /// Design px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - _eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(centre.dx + d.dot(r) * k, centre.dy - d.dot(u) * k);
  }

  /// World ray through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - centre.dx) / focal) + u * (-(s.dy - centre.dy) / focal))
          .unit;

  /// Where that ray meets the plane z = [z], or null.
  _V? onPlaneZ(Offset s, double z) {
    final d = ray(s);
    if (d.z.abs() < 1e-9) return null;
    final t = (z - _eye.z) / d.z;
    if (t <= 0) return null;
    return _eye + d * t;
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (p(c + _V(0, 0, radius)).dy - p(c - _V(0, 0, radius)).dy).abs() / 2;

  /// The ellipse a horizontal circle of [radius] at [c] projects to.
  Rect ellipse(_V c, double radius) => Rect.fromCenter(
    center: p(c),
    width: 2 * radius * scaleAt(c),
    height: 2 * ellipseHalf(c, radius),
  );

  /// Screen bounds of a drop zone (its rectangle on the plane z = 0).
  Rect zone(_Zone z) {
    final a = p(_V(z.x - z.halfW, z.y + z.halfH, 0));
    final b = p(_V(z.x + z.halfW, z.y + z.halfH, 0));
    final c = p(_V(z.x - z.halfW, z.y - z.halfH, 0));
    final d = p(_V(z.x + z.halfW, z.y - z.halfH, 0));
    return Rect.fromLTRB(
      math.min(a.dx, c.dx),
      math.min(a.dy, b.dy),
      math.max(b.dx, d.dx),
      math.max(c.dy, d.dy),
    );
  }
}

// ------------------------------------------------------------------ tweens

/// TWEEN.Easing.Linear.None.
double _linear(double t) => t;

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => t * (2 - t);

/// TWEEN.Easing.Quadratic.InOut.
double _quadInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2).toDouble() / 2;

/// One tween.js tween: [apply] receives the eased progress 0..1.
class _Tween {
  _Tween({
    required this.start,
    required this.duration,
    required this.apply,
    required this.ease,
    this.owner,
  });

  final double start;
  final double duration;
  final void Function(double k) apply;
  final double Function(double t) ease;

  /// The icon it moves (cancelled when the learner grabs it again).
  final _Item? owner;

  /// Applies the tween at [now] (seconds); true once it has finished.
  bool update(double now) {
    final t = ((now - start) / duration).clamp(0.0, 1.0);
    apply(ease(t));
    return t >= 1;
  }
}

// ------------------------------------------------------------- scene model

/// What the learner drags (HTML `.drag-item`).
enum _Item { leftHand, rightHand, thermo, burner }

/// Grab order when icons overlap: the one drawn on top first.
const List<_Item> _grabOrder = [
  _Item.burner,
  _Item.thermo,
  _Item.rightHand,
  _Item.leftHand,
];

/// HTML drop targets (`#drop-beaker-a/b/c`, 112 × 144 px around each
/// beaker's target; `#drop-burner`, 160 × 128 px around the tripod's foot),
/// as rectangles on the plane z = 0: centre and half sizes in units.
enum _Zone {
  beakerA(-12, 6, 4.3, 5.5),
  beakerB(0, 6, 4.3, 5.5),
  beakerC(12, 6, 4.3, 5.5),
  ice(0, 12, 4.3, 5.5),
  tripod(0, 0, 6.1, 4.9);

  const _Zone(this.x, this.y, this.halfW, this.halfH);

  final double x;
  final double y;
  final double halfW;
  final double halfH;

  _V get centre => _V(x, y, 0);

  bool contains(_V p) => (p.x - x).abs() < halfW && (p.y - y).abs() < halfH;
}

/// Beaker contents (HTML `createBeakerSetup(type)`).
enum _Liquid {
  warm(_Colors.warmWater),
  tap(_Colors.tapWater),
  cold(_Colors.coldWater);

  const _Liquid(this.color);
  final Color color;
}

/// One ice cube: position in the beaker, radius and turn.
@immutable
class _Cube {
  const _Cube(this.pos, this.radius, this.turn);
  final _V pos;
  final double radius;
  final double turn;
}

/// HTML ice: 25 random cubes, seeded so every run looks the same; drawn
/// back to front.
List<_Cube> _makeIce(int seed) {
  final rnd = math.Random(seed);
  final cubes = [
    for (var i = 0; i < _iceCount; i++)
      _Cube(
        _V(
          (rnd.nextDouble() - 0.5) * 3.5,
          0.5 + rnd.nextDouble() * 5,
          (rnd.nextDouble() - 0.5) * 3.5,
        ),
        0.6 + rnd.nextDouble() * 0.5,
        rnd.nextDouble() * math.pi,
      ),
  ];
  cubes.sort((a, b) => a.pos.z.compareTo(b.pos.z));
  return cubes;
}

final List<_Cube> _iceBeakerC = _makeIce(7);
final List<_Cube> _iceBeakerS2 = _makeIce(11);

/// Steam puffs (HTML: 5 planes rising 0.02–0.04 units per frame from 8 to
/// 12 above the beaker's foot, i.e. 0 … 4 above its rim) and boiling
/// bubbles (30 spheres rising 0.1–0.2 units per frame from 0.5 to 6.5):
/// x, z, phase, speed (units / s).
typedef _Mote = (double x, double z, double phase, double speed);

List<_Mote> _makeMotes(int seed, int n, double spread, double lo, double hi) {
  final rnd = math.Random(seed);
  return [
    for (var i = 0; i < n; i++)
      (
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
        rnd.nextDouble(),
        lo + rnd.nextDouble() * (hi - lo),
      ),
  ];
}

final List<_Mote> _steamMotes = _makeMotes(3, 5, 2, 1.2, 2.4);
final List<_Mote> _bubbleMotes = _makeMotes(5, 30, 3.5, 6, 12);
const double _steamRise = 4;
const double _bubbleFloor = 0.5;
const double _bubbleRise = 6;

/// A repeatable pseudo-random value in 0..1 for bubble [i] on its lap
/// [lap] (the HTML re-rolled x / z each time a bubble reached the top).
double _hash01(int i, int lap) {
  var h = (i * 73856093) ^ (lap * 19349663);
  h = (h ^ (h >> 13)) * 1274126177;
  return ((h ^ (h >> 16)) & 0xffff) / 0xffff;
}

/// Thread height above the bulb for a reading of [c] °C.
double _threadY(double c) =>
    _scaleBottomY +
    (c - _scaleMinC) / (_scaleMaxC - _scaleMinC) * (_scaleTopY - _scaleBottomY);

/// All mutable simulation state; the painter reads it every frame.
class _Scene {
  _Scene() {
    load(0, collapsed: false);
  }

  int scenario = 0;

  /// 1-based step (HTML `State.step`); one past the last step once the
  /// conclusion was opened.
  int step = 1;

  /// Ticker time in seconds.
  double time = 0;
  final List<_Tween> tweens = [];

  /// 0 = sidebar open, 1 = collapsed (linear; eased in [framing]).
  double framingT = 0;

  /// Collapsed-sidebar framing: zoom and horizontal shift (design px).
  double collapsedZoom = 1;
  double collapsedShift = 0;

  // ------------------------------------------------------------- the icons
  _V left = _leftHome;
  _V right = _rightHome;
  _V thermoIcon = _thermoIconHomes[0];
  _V burnerIcon = _burnerIconHome;
  bool handsShown = true;
  bool thermoIconShown = false;
  bool burnerIconShown = false;

  /// The beaker each hand is in (HTML `attachedItems`), or null.
  _Zone? leftIn;
  _Zone? rightIn;

  /// The hands are adjusting (3 s) or showing what they feel (2.5 s).
  bool handsLocked = false;

  /// Hand colour: 0 = skin, 1 = cold blue (left) / warm red (right).
  double leftTint = 0;
  double rightTint = 0;

  /// Thought bubbles: 0 none, 1 after the cold / warm water (left "Cold!",
  /// right "Warm!"), 2 in the tap water (left "Warm!", right "Cold!").
  int bubbles = 0;
  double bubblesAt = -10;

  // --------------------------------------------------------------- drag
  _Item? held;
  _V grabOffset = _V.zero;
  bool dragMoved = false;

  // -------------------------------------------------------- thermometer
  bool thermoPlaced = false;
  _V thermoAt = _thermoInB;

  /// The thermometer's reading (°C).
  double reading = _roomC;

  // --------------------------------------------------------- scenario 2
  bool burnerPlaced = false;
  bool flameOn = false;

  /// A Fast Forward is under way.
  bool running = false;

  /// Ice group scale (1 … 0.01) and water fill (0.05 … 1).
  double iceScale = 1;
  bool iceGone = false;
  double waterLevel = _iceWaterStart;
  bool boiling = false;
  double boilAt = -10;

  double get framing => Curves.easeInOutCubic.transform(framingT);

  int get stepCount => _stepCounts[scenario];
  bool get done => step > stepCount;

  /// The camera with the current framing.
  _Proj get proj => projAt(framing);

  /// The camera at framing [e] (0 = sidebar open, 1 = collapsed).
  _Proj projAt(double e) {
    final z = 1 + (collapsedZoom - 1) * e;
    return _Proj(
      Offset(
        _stageCentre.dx + collapsedShift * e,
        _stageCentre.dy + z * _viewDrop[scenario],
      ),
      _focal * _viewZoom[scenario] * z,
    );
  }

  _V itemPos(_Item i) => switch (i) {
    _Item.leftHand => left,
    _Item.rightHand => right,
    _Item.thermo => thermoIcon,
    _Item.burner => burnerIcon,
  };

  void setItem(_Item i, _V v) {
    switch (i) {
      case _Item.leftHand:
        left = v;
      case _Item.rightHand:
        right = v;
      case _Item.thermo:
        thermoIcon = v;
      case _Item.burner:
        burnerIcon = v;
    }
  }

  bool shown(_Item i) => switch (i) {
    _Item.leftHand || _Item.rightHand => handsShown,
    _Item.thermo => thermoIconShown,
    _Item.burner => burnerIconShown,
  };

  /// Where an icon goes back to after a missed drop.
  _V homeOf(_Item i) => switch (i) {
    _Item.leftHand => step >= 2 ? _leftLift : _leftHome,
    _Item.rightHand => step >= 2 ? _rightLift : _rightHome,
    _Item.thermo => _thermoIconHomes[scenario],
    _Item.burner => _burnerIconHome,
  };

  /// The beaker or stand that [i] must be dropped on now (HTML: only that
  /// drop target is shown), or null.
  _Zone? validZone(_Item i) {
    if (scenario == 0) {
      return switch ((i, step)) {
        (_Item.leftHand, 1) => _Zone.beakerC,
        (_Item.rightHand, 1) => _Zone.beakerA,
        (_Item.leftHand || _Item.rightHand, 2) => _Zone.beakerB,
        (_Item.thermo, 3) => _Zone.beakerB,
        _ => null,
      };
    }
    return switch ((i, step)) {
      (_Item.thermo, 1) => _Zone.ice,
      (_Item.burner, 2) => _Zone.tripod,
      _ => null,
    };
  }

  /// Can [i] be picked up now?
  bool active(_Item i) {
    if (!shown(i) || validZone(i) == null) return false;
    return switch (i) {
      _Item.leftHand => !handsLocked && leftIn == null,
      _Item.rightHand => !handsLocked && rightIn == null,
      _Item.thermo => !thermoPlaced,
      _Item.burner => !burnerPlaced,
    };
  }

  // Read by the QA flow (integration_test/qa/flows) through the painter:
  // design-space positions with the current framing, and outcomes.

  /// Design position of world point (x, y, z).
  Offset designPoint(double x, double y, double z) => proj.p(_V(x, y, z));

  /// Design position of an icon: 'leftHand', 'rightHand', 'thermo',
  /// 'burner'.
  Offset itemPoint(String id) => proj.p(itemPos(_Item.values.byName(id)));

  /// Design position of a drop zone's centre: 'beakerA', 'beakerB',
  /// 'beakerC', 'ice', 'tripod'.
  Offset zonePoint(String id) => proj.p(_Zone.values.byName(id).centre);

  /// The flame button's design position.
  Offset get flameButtonPoint => proj.p(_flameButtonAt);
  bool get framingSettled => framingT == 0 || framingT == 1;
  bool get handsReady =>
      scenario == 0 && step == 2 && !handsLocked && leftIn == null;
  String? get leftZone => leftIn?.name;
  String? get rightZone => rightIn?.name;
  bool get lensShown => thermoPlaced;

  /// HTML `resetScenarioState(sc)`: every object back home, step 1.
  void load(int index, {required bool collapsed}) {
    scenario = index;
    step = 1;
    tweens.clear();
    left = _leftHome;
    right = _rightHome;
    thermoIcon = _thermoIconHomes[index];
    burnerIcon = _burnerIconHome;
    handsShown = index == 0;
    thermoIconShown = index == 1;
    burnerIconShown = false;
    leftIn = null;
    rightIn = null;
    handsLocked = false;
    leftTint = 0;
    rightTint = 0;
    bubbles = 0;
    bubblesAt = -10;
    held = null;
    grabOffset = _V.zero;
    dragMoved = false;
    thermoPlaced = false;
    thermoAt = index == 0 ? _thermoInB : _thermoInIce;
    reading = _roomC;
    burnerPlaced = false;
    flameOn = false;
    running = false;
    iceScale = 1;
    iceGone = false;
    waterLevel = _iceWaterStart;
    boiling = false;
    boilAt = -10;
    framingT = collapsed ? 1 : 0;
  }

  void tween(
    double seconds,
    void Function(double k) apply, {
    double Function(double t) ease = _linear,
    _Item? owner,
  }) {
    tweens.add(
      _Tween(
        start: time,
        duration: seconds,
        apply: apply,
        ease: ease,
        owner: owner,
      ),
    );
  }

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    if (tweens.isEmpty) return;
    tweens.removeWhere((tw) => tw.update(time));
  }
}

/// Pan recogniser that only joins the gesture arena when [canGrab] picks up
/// an icon at pointer-down (HTML `pointerdown` on a `.drag-item`), so every
/// other drag still reaches the zoom viewer.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _ThermometerLabState
    extends State<Ch7A5ComparingThermometersAndObservingPhaseChangesPage>
    with SingleTickerProviderStateMixin {
  // HTML `State.isCamLocked = true`: drags interact with the scene.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) and canvas-text boost.
  double _fit = 1;
  double _labelScale = 1;

  /// Bumped on every scenario load: delayed steps of an older load do
  /// nothing (the HTML's setTimeouts ran on into the next scenario).
  int _generation = 0;

  /// The last toast this lab showed (key and shown text), so it can be
  /// re-translated when the language changes while it is visible.
  String? _toastKey;
  String? _toastText;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

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
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_onLabChanged);
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
    _lab
      ..removeListener(_onLabChanged)
      ..dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- animation

  /// HTML `animate()`: TWEEN.update() and the collapsed-sidebar framing,
  /// then a repaint of the canvas only (steam, bubbles and the flame are
  /// drawn from the time).
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    final target = _lab.isSidebarOpen ? 0.0 : 1.0;
    if (s.framingT != target) {
      final step = dt / _framingSeconds;
      s.framingT = target > s.framingT
          ? math.min(target, s.framingT + step)
          : math.max(target, s.framingT - step);
    }
    s.updateTweens();
    _frame.value = now;
  }

  // ---------------------------------------------------------------- toasts

  /// HTML `showToast(msg)`. Error toasts play the shell's error tone.
  void _toast(String key, {bool isError = false}) {
    _toastKey = key;
    _toastText = _t(key);
    _lab.showToast(_toastText!, isError: isError, sound: isError);
  }

  /// Language switched while a toast is up: show it in the new language
  /// (this lab's toasts and the shell's "Scenario Complete" toast).
  void _onLabChanged() {
    final shown = _lab.toast;
    if (shown == null) return;
    String? text;
    if (_toastKey != null && shown.text == _toastText) {
      text = _t(_toastKey!);
      if (text == _toastText) return;
      _toastText = text;
    } else {
      for (final key in const ['msg_scenario_complete', 'msg_all_complete']) {
        final other = labTr(kLabCommonStrings, _lab.lang.next, key);
        if (shown.text == other && _lab.t(key) != other) text = _lab.t(key);
      }
    }
    if (text != null) {
      _lab.showToast(text, isError: shown.isError, sound: false);
    }
  }

  // ----------------------------------------------------------------- logic

  /// Runs [fn] after [delay] unless the scenario was reloaded meanwhile.
  void _later(Duration delay, VoidCallback fn) {
    final generation = _generation;
    _lab.after(delay, () {
      if (!mounted || generation != _generation) return;
      fn();
    });
  }

  static Duration _seconds(double s) =>
      Duration(milliseconds: (s * 1000).round());

  /// HTML `changeScenario(sc)` (scenario selector) and `resetApp()`: stops
  /// every timer and tween and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _generation++;
    setState(() => _scene.load(index, collapsed: !_lab.isSidebarOpen));
    _lab.resetView(sound: false);
  }

  /// Step 1 done: both hands are in their beakers. Step 2 starts with the
  /// 3 s the hands need to adjust (HTML: toast, then `progressScenario1()`);
  /// meanwhile each hand shows what it feels.
  void _startAdaptation() {
    final s = _scene;
    setState(() {
      s
        ..step = 2
        ..handsLocked = true
        ..bubbles = 1
        ..bubblesAt = s.time;
    });
    _toast('toast_waiting_hands');
    _later(_adaptDelay, () {
      final s = _scene;
      final l0 = s.left, r0 = s.right;
      setState(() {
        s
          ..handsLocked = false
          ..bubbles = 0
          ..leftIn = null
          ..rightIn = null;
      });
      // Lifted out above their beakers (HTML: 70 % / 30 % of the canvas).
      s
        ..tween(
          _liftSeconds,
          (k) => s.left = _V.lerp(l0, _leftLift, k),
          ease: _quadOut,
          owner: _Item.leftHand,
        )
        ..tween(
          _liftSeconds,
          (k) => s.right = _V.lerp(r0, _rightLift, k),
          ease: _quadOut,
          owner: _Item.rightHand,
        );
    });
  }

  /// Step 2: both hands in the tap water. "Warm!" / "Cold!" in the same
  /// water; 2.5 s later the hands go and the thermometer appears (step 3).
  void _bothInTapWater() {
    final s = _scene;
    setState(() {
      s
        ..handsLocked = true
        ..bubbles = 2
        ..bubblesAt = s.time;
    });
    _Sound.success.play();
    _later(_bubbleHold, () {
      setState(() {
        _scene
          ..step = 3
          ..handsShown = false
          ..thermoIconShown = true
          ..thermoIcon = _thermoIconHomes[0];
      });
    });
  }

  /// A hand dropped on its beaker snaps to the beaker's target.
  void _dropHand(_Item item, _Zone zone) {
    final s = _scene;
    final isLeft = item == _Item.leftHand;
    final at = zone == _Zone.beakerB
        ? _V(isLeft ? -_handInBOffset : _handInBOffset, _snapY, 0)
        : _V(zone.x, _snapY, 0);
    final from = s.itemPos(item);
    s.tween(
      _snapSeconds,
      (k) => s.setItem(item, _V.lerp(from, at, k)),
      ease: _quadOut,
      owner: item,
    );
    _Sound.pop.play();
    setState(() {
      if (isLeft) {
        s.leftIn = zone;
      } else {
        s.rightIn = zone;
      }
    });
    if (s.step == 1) {
      // HTML: the hand turns blue in the ice-cold water, red in the warm.
      s.tween(_tintSeconds, (k) {
        if (isLeft) {
          s.leftTint = k;
        } else {
          s.rightTint = k;
        }
      });
      if (s.leftIn != null && s.rightIn != null) _startAdaptation();
    } else if (s.leftIn == _Zone.beakerB && s.rightIn == _Zone.beakerB) {
      _bothInTapWater();
    }
  }

  /// The thermometer goes into the water (S1) or the crushed ice (S2): its
  /// thread settles at the liquid's temperature, then the next step starts.
  void _dropThermometer() {
    final s = _scene;
    final first = s.scenario == 0;
    setState(() {
      s
        ..thermoIconShown = false
        ..thermoPlaced = true
        ..thermoAt = first ? _thermoInB : _thermoInIce
        ..bubbles = 0;
    });
    _Sound.success.play();
    final target = first ? _tapC : _iceC;
    final seconds = first ? _settleS1 : _settleS2;
    final from = s.reading;
    s.tween(
      seconds,
      (k) => s.reading = from + (target - from) * k,
      ease: _quadOut,
    );
    _later(_seconds(seconds), () {
      setState(() {
        final s = _scene..reading = target;
        if (first) {
          s.step = 4;
        } else {
          s
            ..step = 2
            ..burnerIconShown = true
            ..burnerIcon = _burnerIconHome;
        }
      });
    });
  }

  /// The burner goes under the tripod; the flame button appears.
  void _dropBurner() {
    setState(() {
      _scene
        ..burnerIconShown = false
        ..burnerPlaced = true;
    });
    _Sound.success.play();
  }

  /// HTML `triggerFlame()`: the flame lights; step 3 1.5 s later.
  void _lightBurner() {
    final s = _scene;
    if (!_lab.isLabActive ||
        s.scenario != 1 ||
        s.step != 2 ||
        !s.burnerPlaced ||
        s.flameOn) {
      return;
    }
    _Sound.pop.play();
    setState(() => s.flameOn = true);
    _later(_flameDelay, () => setState(() => _scene.step = 3));
  }

  /// HTML `triggerNextAction()` with 'melt' (step 3) or 'boil' (step 4).
  void _fastForward() {
    final s = _scene;
    if (s.scenario != 1 || s.running) return;
    if (s.step == 3) {
      _melt();
    } else if (s.step == 4) {
      _boil();
    }
  }

  /// The ice melts over 5 s while the water fills the beaker; the reading
  /// stays at 0 °C.
  void _melt() {
    final s = _scene;
    _Sound.pop.play();
    setState(() => s.running = true);
    _toast('toast_ff');
    final w0 = s.waterLevel;
    s.tween(_meltSeconds, (k) {
      s
        ..iceScale = 1 + (_iceMinScale - 1) * k
        ..waterLevel = w0 + (1 - w0) * k;
    });
    _later(_seconds(_meltSeconds), () {
      setState(() => _scene.iceGone = true);
      _toast('toast_melting_notice');
      _later(_afterMelt, () {
        setState(() {
          _scene
            ..running = false
            ..step = 4;
        });
      });
    });
  }

  /// The water heats from 0 °C to 98 °C over 4 s, then boils with the
  /// reading held at 98 °C.
  void _boil() {
    final s = _scene;
    _Sound.pop.play();
    setState(() => s.running = true);
    _toast('toast_ff');
    final from = s.reading;
    s.tween(
      _heatSeconds,
      (k) => s.reading = from + (_boilC - from) * k,
      ease: _quadInOut,
    );
    _later(_seconds(_heatSeconds), () {
      setState(() {
        _scene
          ..reading = _boilC
          ..boiling = true
          ..boilAt = _scene.time;
      });
      _later(_boilHold, () {
        setState(() {
          _scene
            ..running = false
            ..step = 5;
        });
      });
    });
  }

  /// HTML 'Observe Conclusion' (`triggerConclusion()`): the summary. The
  /// button stays afterwards and opens the summary again.
  void _conclude() {
    final s = _scene;
    if (s.step < s.stepCount) return;
    final index = s.scenario;
    if (!s.done) setState(() => s.step = s.stepCount + 1);
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => labFormat(_t('sc_complete'), {'n': index + 1}),
      heading: () => _t('sum_s${index + 1}_title'),
      body: () => _t('sum_s${index + 1}_desc'),
    );
  }

  // ------------------------------------------------------------ hit tests

  /// Screen box of an icon (with its name chip), at least a finger wide.
  Rect _itemRect(_Item item) {
    final s = _scene;
    final proj = s.proj;
    final k = _iconBoost(_labelScale) * proj.focal / _focal;
    final c = proj.p(s.itemPos(item));
    final (w, h, dy) = switch (item) {
      _Item.leftHand ||
      _Item.rightHand => (_handPx, _handPx + _handLabelPx, _handLabelPx / 2),
      _Item.thermo => (_thermoIconW, _thermoIconH, 0.0),
      _Item.burner => (_burnerIconPx, _burnerIconPx, 0.0),
    };
    final min = _minTouch / _fit;
    return Rect.fromCenter(
      center: c.translate(0, dy * k),
      width: math.max(w * k, min),
      height: math.max(h * k, min),
    );
  }

  bool get _flameButtonShown {
    final s = _scene;
    return _lab.isLabActive &&
        s.scenario == 1 &&
        s.step == 2 &&
        s.burnerPlaced &&
        !s.flameOn;
  }

  // -------------------------------------------------------------- gestures

  /// HTML `pointerdown` on a `.drag-item`: picks the icon up; it then moves
  /// on the plane z = 0 through the beakers' centres.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null) return false;
    final p = event.localPosition;
    for (final item in _grabOrder) {
      if (!s.active(item) || !_itemRect(item).contains(p)) continue;
      final pos = s.itemPos(item);
      final hit = s.proj.onPlaneZ(p, 0);
      s.tweens.removeWhere((t) => t.owner == item);
      s
        ..held = item
        ..dragMoved = false
        ..grabOffset = hit == null ? _V.zero : pos - hit;
      return true;
    }
    return false;
  }

  void _onDragStart(DragStartDetails _) {
    if (_scene.held != null) _Sound.pickup.play();
  }

  /// HTML `pointermove`: the icon follows the finger.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    final hit = s.proj.onPlaneZ(d.localPosition, 0);
    if (hit == null) return;
    final q = hit + s.grabOffset;
    final pos = _V(
      q.x.clamp(-_dragMaxX, _dragMaxX),
      q.y.clamp(_dragMinY, _dragMaxY),
      0,
    );
    if ((pos - s.homeOf(item)).length > _dragMinMove) s.dragMoved = true;
    s.setItem(item, pos);
  }

  /// HTML `pointerup`: dropped on its target the icon snaps there;
  /// anywhere else it goes back (with an error toast after a real drag).
  void _release() {
    final s = _scene;
    final item = s.held;
    s.held = null;
    if (item == null) return;
    final zone = s.validZone(item);
    if (zone != null && s.dragMoved && zone.contains(s.itemPos(item))) {
      switch (item) {
        case _Item.leftHand || _Item.rightHand:
          _dropHand(item, zone);
        case _Item.thermo:
          _dropThermometer();
        case _Item.burner:
          _dropBurner();
      }
      return;
    }
    final from = s.itemPos(item);
    final home = s.homeOf(item);
    s.tween(
      _returnSeconds,
      (k) => s.setItem(item, _V.lerp(from, home, k)),
      ease: _quadOut,
      owner: item,
    );
    if (s.dragMoved) {
      _Sound.drop.play();
      _toast(_missKey(item), isError: true);
    }
  }

  /// The error toast for a missed drop of [item].
  String _missKey(_Item item) {
    final s = _scene;
    if (s.scenario == 1) {
      return item == _Item.burner ? 'err_burner' : 'err_thermo_ice';
    }
    return switch ((item, s.step)) {
      (_Item.leftHand, 1) => 'err_left_hand',
      (_Item.rightHand, 1) => 'err_right_hand',
      (_Item.thermo, _) => 'err_thermo_b',
      _ => 'err_hands_b',
    };
  }

  // --------------------------------------------------------------- framing

  /// Collapsed-sidebar framing for the current scenario: slides (and if
  /// needed shrinks) the scene into the room right of the floating mission
  /// card. Uses the shell's own card width ([_missionCardWidth]).
  void _syncCollapsedFraming(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0 && fit.isFinite)) return;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final cardRight =
        _missionCardLeft + pad.left + _missionCardWidth(size, context.labScale);
    final freeLeft = (cardRight + _cardGap - stageLeft) / fit;
    final freeRight =
        (size.width -
            labOverlayInsets(context, _lab).right -
            _cardGap -
            stageLeft) /
        fit;
    final (left, right) = _extents[_scene.scenario];
    var zoom = 1.0, shift = 0.0;
    if (freeLeft > left || freeRight < right) {
      zoom = math.min(1.0, (freeRight - freeLeft) / (right - left));
      final slack = (freeRight - freeLeft) - (right - left) * zoom;
      shift =
          freeLeft +
          slack / 2 -
          _stageCentre.dx -
          zoom * (left - _stageCentre.dx);
    }
    _scene
      ..collapsedZoom = zoom
      ..collapsedShift = shift;
  }

  // -------------------------------------------------------------------- UI

  /// The step's buttons in the sidebar / mission card: the flame button
  /// (HTML `#btn-flame`) and the next-action button.
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.scenario == 1 && s.step == 2 && s.burnerPlaced && !s.flameOn)
        LabAction(
          label: _t('btn_light'),
          icon: Icons.local_fire_department,
          color: _Colors.orange500,
          highlight: true,
          silent: true,
          onTap: _lightBurner,
        ),
      ?_nextAction(),
    ];
  }

  /// HTML `#action-btn-container`: 'Fast Forward' (S2 steps 3 and 4) or
  /// 'Observe Conclusion' (last step, and afterwards to re-open it).
  LabAction? _nextAction() {
    final s = _scene;
    if (s.scenario == 1 && (s.step == 3 || s.step == 4) && !s.running) {
      return LabAction(
        label: _t('btn_fast_forward'),
        icon: Icons.fast_forward,
        highlight: true,
        silent: true,
        onTap: _fastForward,
      );
    }
    if (s.step >= s.stepCount) {
      return LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        highlight: !s.done,
        onTap: _conclude,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final scene = _scene;
        final next = _nextAction();
        final inset = labOverlayInsets(context, _lab);
        _syncCollapsedFraming(context);
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // HTML "Current Task" lines; gone once the conclusion is open.
          hud: scene.done
              ? null
              : _t('s${scene.scenario + 1}_hud_${scene.step}'),
          showHud: !scene.done,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          overlays: [
            // The HTML shows its next-action button on the canvas. With the
            // sidebar open its copy there can be below the fold on a phone,
            // so it is also shown at the canvas's top left, under the toast
            // band (while collapsed, the mission card carries it).
            if (next != null && _lab.isLabActive && _lab.isSidebarOpen)
              Positioned(
                key: const ValueKey('ch7a5-next'),
                top: inset.top + _nextButtonTop,
                left: inset.left + 4,
                child: LabActionButton(action: next, scale: s, expand: false),
              ),
          ],
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepList(
            key: ValueKey('steps-${scene.scenario}-${scene.step}'),
            steps: data.steps,
            current: scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
          stage: _buildStage(),
        );
      },
    );
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        _labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
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
                            // A RawGestureDetector does not take
                            // MediaQuery's gesture settings.
                            ..gestureSettings = _dragSettings
                            ..canGrab = _canGrab
                            ..dragStartBehavior = DragStartBehavior.down
                            ..onStart = _onDragStart
                            ..onUpdate = _onDragUpdate
                            ..onEnd = ((_) => _release())
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
                          palette: _lab.palette,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelScale: _labelScale,
                          flameButton: _flameButtonShown,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_flameButtonShown) _flameButton(),
            ],
          ),
        );
      },
    );
  }

  /// HTML `#btn-flame`: the button the learner taps to light the burner
  /// (the painter draws the pulsing button under it). Placed for the
  /// framing the scene is easing to.
  Widget _flameButton() {
    final s = _scene;
    final proj = s.projAt(_lab.isSidebarOpen ? 0 : 1);
    final at = proj.p(_flameButtonAt);
    final k = _iconBoost(_labelScale) * proj.focal / _focal;
    final size = math.max(_flameButtonPx * k, _minTouch / _fit);
    return Positioned(
      key: const ValueKey('ch7a5-flame'),
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      width: size,
      height: size,
      child: Tooltip(
        message: _t('btn_light'),
        child: Semantics(
          button: true,
          label: _t('btn_light'),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _lightBurner,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// HTML teacher board "Observation Step" accordion: one card per step; the
/// current step is open with its task and action, done steps show a tick
/// and open to show their result too, future steps stay closed. (The HTML
/// showed the current step's result before the learner had done it.)
class _StepList extends StatefulWidget {
  const _StepList({
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

  @override
  State<_StepList> createState() => _StepListState();
}

class _StepListState extends State<_StepList> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
  final Set<int> _toggled = {};

  /// The current step is open; once the scenario is done, the last one.
  bool _isOpen(int i) =>
      (i == math.min(widget.current, widget.steps.length)) !=
      _toggled.contains(i);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++) _tile(context, i),
      ],
    );
  }

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    final dim = future ? 0.55 : 1.0;
    final tone = current ? p.accentInk : (past ? p.info : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    TextSpan labelled(String label, String text, Color labelColor) => TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: TextStyle(color: labelColor, fontWeight: FontWeight.w800),
        ),
        TextSpan(text: text),
      ],
    );

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
                constraints: const BoxConstraints(minHeight: _minTouch),
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
                                ? _Colors.blue400
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
                  Text.rich(
                    labelled(w.conceptLabel, step.concept, p.accentInk),
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    labelled(w.actionLabel, step.action, p.textStrong),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  // The result once the learner has seen it.
                  if (past) ...[
                    SizedBox(height: 6 * s),
                    Text.rich(
                      labelled(
                        w.observationLabel,
                        step.observation,
                        p.textStrong,
                      ),
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11.5 * f,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (10, 20, 15)).
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// The HTML hand icon (`<path d="M416,224c0-26.5…">`, 512-unit viewBox,
/// stroke 16), a right hand; the left hand is drawn mirrored (HTML
/// `scaleX(-1)`). [_handPivot] is the middle of the drawn hand.
final Path _handPath = Path()
  ..moveTo(416, 224)
  ..cubicTo(416, 197.5, 394.5, 176, 368, 176)
  ..cubicTo(341.5, 176, 320, 197.5, 320, 224)
  ..lineTo(320, 144)
  ..cubicTo(320, 117.5, 298.5, 96, 272, 96)
  ..cubicTo(245.5, 96, 224, 117.5, 224, 144)
  ..lineTo(224, 128)
  ..cubicTo(224, 101.5, 202.5, 80, 176, 80)
  ..cubicTo(149.5, 80, 128, 101.5, 128, 128)
  ..lineTo(128, 288)
  ..cubicTo(119.5, 274.4, 106.1, 264.7, 90.6, 261.6)
  ..cubicTo(71.3, 256.3, 50, 268, 43, 288.5)
  ..cubicTo(36.5, 307.7, 42.5, 329, 57.8, 341.7)
  ..lineTo(152.8, 420.5)
  ..cubicTo(178.2, 441.6, 211.2, 453, 245.3, 453.9)
  ..lineTo(288, 453.9)
  ..cubicTo(349.8, 453.9, 400, 403.7, 400, 341.9)
  ..lineTo(400, 224)
  ..close();
const double _handViewBox = 512;
const double _handStroke = 16;
const Offset _handPivot = Offset(229.5, 267);

/// The HTML burner icon (24-unit viewBox): the stand and the flame drop.
final Path _burnerStand = Path()
  ..moveTo(15.5, 22)
  ..lineTo(8.5, 22)
  ..arcToPoint(const Offset(8.5, 20), radius: const Radius.circular(1))
  ..lineTo(15.5, 20)
  ..arcToPoint(const Offset(15.5, 22), radius: const Radius.circular(1))
  ..close()
  ..moveTo(12.5, 19)
  ..lineTo(11.5, 19)
  ..arcToPoint(const Offset(10.5, 18), radius: const Radius.circular(1))
  ..lineTo(10.5, 12.62)
  ..lineTo(7.79, 9.91)
  ..arcToPoint(const Offset(7.79, 8.5), radius: const Radius.circular(1))
  ..lineTo(8.5, 7.79)
  ..arcToPoint(const Offset(9.91, 7.79), radius: const Radius.circular(1))
  ..lineTo(12, 9.59)
  ..lineTo(14.79, 6.79)
  ..arcToPoint(const Offset(16.2, 6.79), radius: const Radius.circular(1))
  ..lineTo(16.91, 7.5)
  ..arcToPoint(const Offset(16.91, 8.91), radius: const Radius.circular(1))
  ..lineTo(14.2, 12.62)
  ..lineTo(14.2, 18)
  ..arcToPoint(const Offset(13.2, 19), radius: const Radius.circular(1))
  ..lineTo(12.5, 19)
  ..close();
final Path _burnerFlame = Path()
  ..moveTo(12, 2)
  ..arcToPoint(
    const Offset(8.54, 8.03),
    radius: const Radius.circular(4),
    clockwise: false,
  )
  ..lineTo(12, 11.59)
  ..lineTo(15.46, 8.03)
  ..arcToPoint(
    const Offset(12, 2),
    radius: const Radius.circular(4),
    clockwise: false,
  )
  ..close();
const double _burnerViewBox = 24;

/// Label chip padding (HTML `px-2 py-1.5`, at the 12 px label size).
const double _labelPadX = 8;
const double _labelPadY = 4;

/// Paints the HTML Three.js scene: the lab table with Beakers A, B and C
/// (S1) or the ice beaker on the tripod with the burner (S2), the
/// thermometer and its magnified scale, the labels, the thought bubbles,
/// the draggable icons and the flame button.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
    required this.flameButton,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;
  final bool flameButton;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Paint _haze = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path _path = Path();

  late Canvas _c;
  late _Proj _p;

  /// The view's zoom against the HTML scale, and the icons' size factor.
  late double _view;
  late double _ik;

  String _t(String key) => labTr(_i18n, lang, key);

  /// HTML `.drag-pulse`: 0 → 1 → 0 every 2 s.
  double get _pulse =>
      0.5 - 0.5 * math.cos(scene.time * 2 * math.pi / _pulseSeconds);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _view = _p.focal / _focal;
    _ik = _iconBoost(labelScale) * _view;
    _paintRoom(size);
    if (scene.scenario == 0) {
      _paintBeakers();
    } else {
      _paintStand();
    }
    if (scene.thermoPlaced) _paintLens();
    if (showLabels) _paintLabels();
    _paintZoneHint();
    _paintBubbles();
    _paintItems();
    if (flameButton) _paintFlameButton();
  }

  // ------------------------------------------------------------- the room

  /// The back wall (it fills the HTML view behind the table) and the lab
  /// table (BoxGeometry(40, 2, 20), 0x1e293b).
  void _paintRoom(Size size) {
    _fill
      ..shader = null
      ..color = _Colors.wall;
    _c.drawRect(labBleed(size), _fill);
    const hx = _tableHalfX, hz = _tableHalfZ, d = _tableDepth;
    _quad(
      const _V(-hx, 0, -hz),
      const _V(hx, 0, -hz),
      const _V(hx, 0, hz),
      const _V(-hx, 0, hz),
      _lit(_Colors.table, const _V(0, 1, 0)),
    );
    _quad(
      const _V(-hx, 0, hz),
      const _V(hx, 0, hz),
      const _V(hx, -d, hz),
      const _V(-hx, -d, hz),
      _lit(_Colors.table, const _V(0, 0, 1)),
    );
    _stroke
      ..strokeWidth = 1.2
      ..color = labShade(_Colors.table, 0.3);
    _c
      ..drawLine(_p.p(const _V(-hx, 0, hz)), _p.p(const _V(hx, 0, hz)), _stroke)
      ..drawLine(
        _p.p(const _V(-hx, 0, -hz)),
        _p.p(const _V(hx, 0, -hz)),
        _stroke,
      );
  }

  // ----------------------------------------------------------- scenario 1

  void _paintBeakers() {
    for (var i = 0; i < _beakerX.length; i++) {
      _beaker(
        _V(_beakerX[i], 0, 0),
        _Liquid.values[i],
        level: 1,
        iceScale: 1,
        ice: i == 2 ? _iceBeakerC : null,
        steam: i == 0,
        bubbles: false,
        thermometer: i == 1 && scene.thermoPlaced,
      );
    }
  }

  // ----------------------------------------------------------- scenario 2

  void _paintStand() {
    final s = scene;
    _tripodLeg(_legBack);
    _ringArc(back: true);
    if (s.burnerPlaced) _burner();
    _beaker(
      const _V(0, _iceBeakerY, 0),
      _Liquid.cold,
      level: s.waterLevel,
      iceScale: s.iceScale,
      ice: s.iceGone ? null : _iceBeakerS2,
      steam: s.boiling,
      bubbles: s.boiling,
      thermometer: s.thermoPlaced,
    );
    _ringArc(back: false);
    _tripodLeg(_legRight);
    _tripodLeg(_legFront);
  }

  // -------------------------------------------------------------- beakers

  /// HTML `createBeakerSetup()`: glass, liquid (filled to [level]), ice
  /// cubes, boiling bubbles, the thermometer standing in it, steam.
  void _beaker(
    _V base,
    _Liquid kind, {
    required double level,
    required double iceScale,
    required List<_Cube>? ice,
    required bool steam,
    required bool bubbles,
    required bool thermometer,
  }) {
    final top = base + const _V(0, _beakerHeight, 0);
    final bottomOval = _p.ellipse(base, _beakerRadius);
    final topOval = _p.ellipse(top, _beakerRadius);
    // Glass, the part behind the contents.
    _silhouette(bottomOval, topOval);
    _fill
      ..shader = null
      ..color = _Colors.glass.withValues(alpha: 0.08);
    _c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = math.max(1.5, 0.3 * _p.scaleAt(top))
      ..color = _Colors.glass.withValues(alpha: 0.3);
    _c.drawArc(topOval, math.pi, math.pi, false, _stroke);
    // Liquid.
    final height = _liquidHeight * level;
    if (height > 0.02) {
      final liquidTop = base + _V(0, height, 0);
      final surface = _p.ellipse(liquidTop, _liquidRadius);
      _silhouette(_p.ellipse(base, _liquidRadius), surface);
      _fill.color = kind.color.withValues(alpha: 0.4);
      _c.drawPath(_path, _fill);
      _fill.color = labShade(kind.color, 0.25).withValues(alpha: 0.55);
      _c.drawOval(surface, _fill);
    }
    if (ice != null) _iceCubes(base, iceScale, ice);
    if (bubbles) _boilingBubbles(base, height);
    if (thermometer) _thermometer(scene.thermoAt);
    // Glass, the front: sides, bottom, rim, spout, shine, mL marks.
    _stroke
      ..strokeWidth = 1.6
      ..color = _Colors.glass.withValues(alpha: 0.55);
    _c
      ..drawLine(topOval.centerLeft, bottomOval.centerLeft, _stroke)
      ..drawLine(topOval.centerRight, bottomOval.centerRight, _stroke)
      ..drawArc(bottomOval, 0, math.pi, false, _stroke);
    _stroke
      ..strokeWidth = math.max(2, 0.3 * _p.scaleAt(top))
      ..color = _Colors.glass.withValues(alpha: 0.7);
    _c.drawArc(topOval, 0, math.pi, false, _stroke);
    // Spout: SphereGeometry(0.5) squashed, at the rim's +x side.
    final spout = _p.p(top + const _V(_beakerRadius, 0, 0));
    final k = _p.scaleAt(top);
    _c.drawOval(
      Rect.fromCenter(center: spout, width: 1.5 * k, height: 0.6 * k),
      _stroke,
    );
    _stroke
      ..strokeWidth = math.max(2, 0.25 * k)
      ..color = _Colors.white.withValues(alpha: 0.22);
    final shineTop = _p.p(top + const _V(-2.2, -0.6, 2));
    final shineBottom = _p.p(base + const _V(-2.2, 0.6, 2));
    _c.drawLine(shineTop, shineBottom, _stroke);
    // HTML decal: a mark every 25 mL up to 250 mL of 300 mL (8 units).
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.white.withValues(alpha: 0.7);
    for (var ml = 25; ml <= 250; ml += 25) {
      final y = ml / 300 * _beakerHeight;
      final a = _p.p(base + _V(1.2, y, 2.75));
      final long = ml % 50 == 0;
      _c.drawLine(a, a.translate((long ? 0.7 : 0.4) * k, 0), _stroke);
    }
    if (steam) _steam(top);
  }

  /// HTML ice: DodecahedronGeometry cubes, the group scaled by [k] while it
  /// melts.
  void _iceCubes(_V base, double k, List<_Cube> cubes) {
    if (k <= _iceMinScale * 2) return;
    for (final cube in cubes) {
      final at = base + cube.pos * k;
      final o = _p.p(at);
      final r = cube.radius * k * _p.scaleAt(at);
      _path.reset();
      for (var i = 0; i < 6; i++) {
        final a = cube.turn + i * math.pi / 3;
        final x = o.dx + math.cos(a) * r, y = o.dy + math.sin(a) * r * 0.9;
        if (i == 0) {
          _path.moveTo(x, y);
        } else {
          _path.lineTo(x, y);
        }
      }
      _path.close();
      _fill
        ..shader = null
        ..color = _Colors.ice.withValues(alpha: 0.6);
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = _Colors.white.withValues(alpha: 0.75);
      _c.drawPath(_path, _stroke);
      _fill.color = _Colors.white.withValues(alpha: 0.35);
      _c.drawCircle(o.translate(-r * 0.3, -r * 0.3), r * 0.28, _fill);
    }
  }

  /// HTML boiling bubbles: 30 spheres rising through the water and
  /// starting again at the bottom.
  void _boilingBubbles(_V base, double water) {
    final t = scene.time - scene.boilAt;
    _fill
      ..shader = null
      ..color = _Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i < _bubbleMotes.length; i++) {
      final (x0, z0, phase, speed) = _bubbleMotes[i];
      final travel = phase * _bubbleRise + speed * t;
      final lap = (travel / _bubbleRise).floor();
      final y = _bubbleFloor + travel % _bubbleRise;
      if (y > water - 0.2) continue;
      final x = lap == 0 ? x0 : (_hash01(i, lap) - 0.5) * 3.5;
      final z = lap == 0 ? z0 : (_hash01(i + 97, lap) - 0.5) * 3.5;
      final at = base + _V(x, y, z);
      _c.drawCircle(_p.p(at), math.max(1.0, 0.2 * _p.scaleAt(at)), _fill);
    }
  }

  /// HTML steam: soft puffs rising from the rim and fading.
  void _steam(_V rim) {
    for (final (x, z, phase, speed) in _steamMotes) {
      final y = (phase * _steamRise + speed * scene.time) % _steamRise;
      final at = rim + _V(x, y, z);
      _haze.color = _Colors.white.withValues(
        alpha: 0.32 * (1 - y / _steamRise),
      );
      _c.drawCircle(_p.p(at), 0.9 * _p.scaleAt(at), _haze);
    }
  }

  // ---------------------------------------------------------- thermometer

  /// HTML thermometer: glass tube, scale marks every 10 °C (−10 … 110 °C),
  /// the red thread up to the reading and the bulb at [b].
  void _thermometer(_V b) {
    final top = b + const _V(0, _thermoLength, 0);
    final pb = _p.p(b), pt = _p.p(top);
    final w = math.max(
      2.0,
      _thermoRadius * _p.scaleAt(b + const _V(0, _thermoLength / 2, 0)),
    );
    final tube = RRect.fromLTRBR(
      pt.dx - w,
      pt.dy - w,
      pb.dx + w,
      pb.dy,
      Radius.circular(w),
    );
    _fill
      ..shader = null
      ..color = _Colors.white.withValues(alpha: 0.3);
    _c.drawRRect(tube, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.white.withValues(alpha: 0.7);
    _c.drawRRect(tube, _stroke);
    _stroke.color = _Colors.slate900.withValues(alpha: 0.85);
    for (var c = _scaleMinC; c <= _scaleMaxC; c += 10) {
      final y = _p.p(b + _V(0, _threadY(c), 0)).dy;
      final long = c % 50 == 0;
      _c.drawLine(
        Offset(pb.dx - w * (long ? 0.9 : 0.1), y),
        Offset(pb.dx + w * 0.9, y),
        _stroke,
      );
    }
    final thread = _p.p(b + _V(0, _threadY(scene.reading), 0));
    _stroke
      ..strokeWidth = math.max(1.6, 2 * _threadRadius * _p.scaleAt(b))
      ..color = _Colors.red500;
    _c.drawLine(pb, thread, _stroke);
    final r = math.max(3.0, _bulbRadius * _p.scaleAt(b));
    _fill.color = _Colors.red500;
    _c.drawCircle(pb, r, _fill);
    _fill.color = _Colors.white.withValues(alpha: 0.45);
    _c.drawCircle(pb.translate(-r * 0.35, -r * 0.35), r * 0.3, _fill);
  }

  /// The HTML zoom overlay as a magnifier beside the thermometer: the tube
  /// around the top of the thread, 1 °C marks, numbers every 5 °C and the
  /// reading, updating as the temperature changes.
  void _paintLens() {
    final s = scene;
    final b = s.thermoAt;
    final k = _ik;
    final topY = _p.p(b + const _V(0, _thermoLength, 0)).dy;
    final left = _p.p(b + const _V(_lensGap, _thermoLength, 0)).dx;
    final panel = Rect.fromLTWH(left, topY, _lensW * k, _lensH * k);
    final reading = s.reading;
    final accent = reading <= _coldMarkC
        ? _Colors.emerald500
        : (reading >= _hotMarkC ? _Colors.red500 : _Colors.blue500);
    final tube = Rect.fromLTWH(
      panel.left + 12 * k,
      panel.top + 30 * k,
      16 * k,
      panel.height - 40 * k,
    );
    final lo = (reading - _lensWindowC / 2).clamp(
      _scaleMinC,
      _scaleMaxC - _lensWindowC,
    );
    double yAt(double c) => tube.bottom - (c - lo) / _lensWindowC * tube.height;
    final level = yAt(reading);

    // Pointer from the magnifier to the top of the thread.
    final threadTop = _p.p(b + _V(0, _threadY(reading), 0));
    _stroke
      ..strokeWidth = 1.5
      ..color = accent.withValues(alpha: 0.85);
    _c.drawLine(Offset(panel.left, level), threadTop, _stroke);
    _fill
      ..shader = null
      ..color = accent;
    _c.drawCircle(threadTop, 2.5 * k, _fill);

    // Panel (HTML `#zoom-box`: white, rounded, coloured border).
    final rr = RRect.fromRectAndRadius(panel, Radius.circular(12 * k));
    _glow.color = accent.withValues(alpha: 0.35);
    _c.drawRRect(rr, _glow);
    _fill.color = _Colors.white.withValues(alpha: 0.95);
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 2.5 * k
      ..color = accent;
    _c.drawRRect(rr, _stroke);

    // Tube and thread.
    final tubeShape = RRect.fromRectAndRadius(tube, Radius.circular(4 * k));
    _fill.color = _Colors.slate100;
    _c.drawRRect(tubeShape, _fill);
    _fill.color = _Colors.red500;
    _c.drawRect(
      Rect.fromLTRB(tube.left + 4 * k, level, tube.right - 4 * k, tube.bottom),
      _fill,
    );
    _stroke
      ..strokeWidth = 1.5 * k
      ..color = _Colors.slate300;
    _c.drawRRect(tubeShape, _stroke);

    // Marks: every 1 °C, longer and numbered every 5 °C.
    _stroke
      ..strokeCap = StrokeCap.butt
      ..color = _Colors.slate900;
    for (var c = lo.ceil(); c <= lo + _lensWindowC; c++) {
      final y = yAt(c.toDouble());
      final major = c % 5 == 0;
      _stroke.strokeWidth = (major ? 1.6 : 1) * k;
      _c.drawLine(
        Offset(tube.right, y),
        Offset(tube.right + (major ? 9 : 5) * k, y),
        _stroke,
      );
      if (major) {
        final tp = cache.text('$c', 11 * k, _Colors.slate800, FontWeight.w700);
        tp.paint(_c, Offset(tube.right + 12 * k, y - tp.height / 2));
      }
    }
    _stroke.strokeCap = StrokeCap.round;

    // The reading (HTML `#zoom-tick-mid`, bold, in the box's colour).
    final value = cache.text(
      '${reading.round()} °C',
      14 * k,
      accent,
      FontWeight.w900,
    );
    value.paint(
      _c,
      Offset(panel.center.dx - value.width / 2, panel.top + 7 * k),
    );
  }

  // --------------------------------------------------- tripod and burner

  /// A tripod leg (CylinderGeometry(0.2, 0.2, 6)) from [foot] up.
  void _tripodLeg(_V foot) {
    _stroke
      ..strokeWidth = math.max(1.5, 2 * _legRadius * _p.scaleAt(foot))
      ..color = _lit(_Colors.tripod, const _V(0, 0, 1));
    _c.drawLine(
      _p.p(foot),
      _p.p(foot + const _V(0, _tripodHeight, 0)),
      _stroke,
    );
  }

  /// Half of the tripod's ring (TorusGeometry(3.5, 0.3)): the back half
  /// before the beaker, the front half after it.
  void _ringArc({required bool back}) {
    const c = _V(0, _tripodHeight, 0);
    _stroke
      ..strokeWidth = math.max(2, 2 * _ringTube * _p.scaleAt(c))
      ..color = labShade(_Colors.tripod, back ? -0.15 : 0.2);
    _c.drawArc(
      _p.ellipse(c, _ringRadius),
      back ? math.pi : 0,
      math.pi,
      false,
      _stroke,
    );
  }

  /// HTML burner: amber base, grey tube and, once lit, the flame.
  void _burner() {
    _cylinder(
      _V.zero,
      _burnerBaseBottomR,
      _burnerBaseTopR,
      _burnerBaseH,
      _Colors.burnerBase,
    );
    _cylinder(
      const _V(0, _burnerBaseH, 0),
      _burnerTubeR,
      _burnerTubeR,
      _burnerTubeH,
      _Colors.burnerTube,
    );
    if (scene.flameOn) _flame(const _V(0, _flameY, 0));
  }

  /// Upright (truncated) cylinder from [bottom]: side with a light and a
  /// dark band, then the top.
  void _cylinder(_V bottom, double rb, double rt, double h, Color color) {
    final top = bottom + _V(0, h, 0);
    final bo = _p.ellipse(bottom, rb);
    final to = _p.ellipse(top, rt);
    _silhouette(bo, to);
    _fill
      ..shader = null
      ..color = color;
    _c
      ..drawPath(_path, _fill)
      ..save()
      ..clipPath(_path);
    _stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = bo.width * 0.16
      ..color = labShade(color, 0.3);
    _c.drawLine(
      Offset(to.left + to.width * 0.28, to.center.dy),
      Offset(bo.left + bo.width * 0.28, bo.bottom),
      _stroke,
    );
    _stroke
      ..strokeWidth = bo.width * 0.2
      ..color = labShade(color, -0.4);
    _c
      ..drawLine(
        Offset(to.left + to.width * 0.88, to.center.dy),
        Offset(bo.left + bo.width * 0.88, bo.bottom),
        _stroke,
      )
      ..restore();
    _stroke.strokeCap = StrokeCap.round;
    _fill.color = labShade(color, 0.2);
    _c.drawOval(to, _fill);
  }

  /// HTML flame: an orange cone (0.8 × 2.5) round a blue one (0.4 × 1.2),
  /// flickering in height (× 1 … 1.2) and width (× 1 … 1.1).
  void _flame(_V c) {
    final t = scene.time;
    final sy = 1 + 0.2 * (0.5 + 0.5 * math.sin(t * 29 + 1.7 * math.sin(t * 7)));
    final sx = 1 + 0.1 * (0.5 + 0.5 * math.sin(t * 23 + 0.6));
    final k = _p.scaleAt(c);
    _glow.color = _Colors.orange500.withValues(alpha: 0.4);
    _c.drawCircle(_p.p(c), 1.6 * k, _glow);
    _cone(c, 0.8 * sx, 2.5 * sy, _Colors.orange500.withValues(alpha: 0.8));
    _cone(
      c + _V(0, -0.5 * sy, 0),
      0.4 * sx,
      1.2 * sy,
      _Colors.blue500.withValues(alpha: 0.9),
    );
  }

  /// A flame-shaped cone of [r] × [h] centred at [centre].
  void _cone(_V centre, double r, double h, Color color) {
    final base = centre + _V(0, -h / 2, 0);
    final pb = _p.p(base), pt = _p.p(centre + _V(0, h / 2, 0));
    final w = r * _p.scaleAt(base);
    final midY = (pb.dy + pt.dy) / 2;
    _path
      ..reset()
      ..moveTo(pb.dx - w, pb.dy)
      ..quadraticBezierTo(pb.dx - w * 0.9, midY, pt.dx, pt.dy)
      ..quadraticBezierTo(pb.dx + w * 0.9, midY, pb.dx + w, pb.dy)
      ..arcTo(_p.ellipse(base, r), 0, math.pi, false)
      ..close();
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  // --------------------------------------------------------------- labels

  /// HTML `#labels-container` chips. The beaker labels sit under their
  /// beakers on two lines; the thermometer's sits left of its stem (its
  /// magnifier is on the right); the ice beaker gets its own label.
  void _paintLabels() {
    final s = scene;
    if (s.scenario == 0) {
      const keys = ['lbl_beaker_a', 'lbl_beaker_b', 'lbl_beaker_c'];
      for (var i = 0; i < keys.length; i++) {
        _chip(
          _t(keys[i]),
          _p.p(_V(_beakerX[i], -1, 4)),
          Alignment.topCenter,
          twoLines: true,
          maxWidth: _beakerLabelMax * _view,
        );
      }
    } else {
      _chip(
        _t('lbl_beaker_ice'),
        _p.p(const _V(-_beakerRadius - 0.6, _iceBeakerY + 4.5, 0)),
        Alignment.centerRight,
        twoLines: true,
      );
      _chip(
        _t('lbl_tripod'),
        _p.p(const _V(_ringRadius + 1.2, 3, 0)),
        Alignment.centerLeft,
      );
      if (s.burnerPlaced) {
        _chip(
          _t('lbl_burner'),
          _p.p(const _V(-_burnerBaseBottomR - 1.2, 2.2, 0)),
          Alignment.centerRight,
        );
      }
    }
    if (s.thermoPlaced) {
      _chip(
        _t('lbl_thermo'),
        _p.p(s.thermoAt + _thermoLabelAt),
        Alignment.centerRight,
      );
    }
  }

  /// A label chip whose [anchor] point sits on [at]. With [twoLines] the
  /// text breaks before its bracket ("Beaker A" / "(Warm)"); a chip wider
  /// than [maxWidth] is drawn smaller.
  void _chip(
    String text,
    Offset at,
    Alignment anchor, {
    bool twoLines = false,
    double? maxWidth,
  }) {
    final k = labelScale;
    final shown = twoLines ? text.replaceFirst(' (', '\n(') : text;
    final tp = cache.text(shown, 12 * k, _Colors.white, FontWeight.w700);
    final w = tp.width + 2 * _labelPadX * k, h = tp.height + 2 * _labelPadY * k;
    final shrink = maxWidth != null && w > maxWidth ? maxWidth / w : 1.0;
    _c
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(shrink);
    final rect = Rect.fromLTWH(
      -(anchor.x + 1) / 2 * w,
      -(anchor.y + 1) / 2 * h,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * k));
    _fill
      ..shader = null
      ..color = _Colors.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.labelBorder;
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k));
    _c.restore();
  }

  /// The small name chip under a draggable icon (HTML: under each hand).
  /// [align] −1 puts the chip's left edge at [top], 1 its right edge.
  void _itemChip(String text, Offset top, {double align = 0}) {
    final k = labelScale;
    final tp = cache.text(text, 10.5 * k, _Colors.white, FontWeight.w700);
    final w = tp.width + 10 * k;
    final rect = Rect.fromCenter(
      center: top.translate(-align * w / 2, tp.height / 2 + 2 * k),
      width: w,
      height: tp.height + 4 * k,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(6 * k));
    _fill
      ..shader = null
      ..color = _Colors.slate800.withValues(alpha: 0.9);
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.slate600;
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + 5 * k, rect.top + 2 * k));
  }

  // ------------------------------------------------------ thought bubbles

  /// HTML `.thought-bubble`: "Warm!" (red) and "Cold!" (blue) above the
  /// hands, popping in.
  void _paintBubbles() {
    final s = scene;
    if (s.bubbles == 0) return;
    final t = ((s.time - s.bubblesAt) / _bubblePopSeconds).clamp(0.0, 1.0);
    final pop = Curves.easeOutBack.transform(t);
    if (s.bubbles == 1) {
      // Left hand in Beaker C, right hand in Beaker A.
      _bubble(
        _t('cold_exclaim'),
        _p.p(_V(_Zone.beakerC.x, _bubbleY, 0)),
        _Colors.blue500,
        Alignment.bottomCenter,
        pop,
      );
      _bubble(
        _t('warm_exclaim'),
        _p.p(_V(_Zone.beakerA.x, _bubbleY, 0)),
        _Colors.red500,
        Alignment.bottomCenter,
        pop,
      );
      return;
    }
    final c = _p.p(const _V(0, _bubbleY, 0));
    final gap = 4 * labelScale;
    _bubble(
      _t('warm_exclaim'),
      c.translate(-gap, 0),
      _Colors.red500,
      Alignment.bottomRight,
      pop,
    );
    _bubble(
      _t('cold_exclaim'),
      c.translate(gap, 0),
      _Colors.blue500,
      Alignment.bottomLeft,
      pop,
    );
  }

  void _bubble(
    String text,
    Offset at,
    Color color,
    Alignment anchor,
    double pop,
  ) {
    final k = labelScale;
    final tp = cache.text(text, 14 * k, color, FontWeight.w900);
    final w = tp.width + 28 * k, h = tp.height + 12 * k;
    _c
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(0.8 + 0.2 * pop);
    final rect = Rect.fromLTWH(
      -(anchor.x + 1) / 2 * w,
      -(anchor.y + 1) / 2 * h - 8 * k,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(16 * k));
    _glow.color = LabInk.black.withValues(alpha: 0.3);
    _c.drawRRect(rr.shift(Offset(0, 6 * k)), _glow);
    _fill
      ..shader = null
      ..color = _Colors.white;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 3 * k
      ..color = color;
    _c.drawRRect(rr, _stroke);
    // The bubble's tail, towards its hand.
    final tail = Offset(
      rect.left + rect.width * (anchor.x > 0 ? 0.75 : 0.25),
      rect.bottom + 4 * k,
    );
    _c
      ..drawCircle(tail, 5 * k, _fill)
      ..drawCircle(tail, 5 * k, _stroke);
    tp.paint(
      _c,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
    _c.restore();
  }

  // ---------------------------------------------------------------- icons

  /// The draggable icons; the one being dragged on top.
  void _paintItems() {
    final s = scene;
    for (final item in _Item.values) {
      if (item != s.held && s.shown(item)) _paintItem(item);
    }
    final held = s.held;
    if (held != null && s.shown(held)) _paintItem(held);
  }

  void _paintItem(_Item item) {
    switch (item) {
      case _Item.leftHand || _Item.rightHand:
        _hand(item);
      case _Item.thermo:
        _thermoIcon();
      case _Item.burner:
        _burnerIcon();
    }
  }

  /// The HTML `.drag-pulse` glow behind an icon that can be picked up
  /// (blue for the left hand and the burner, red for the right hand and the
  /// thermometer).
  double _pulseGlow(_Item item, Offset c, double radius, Color color) {
    final s = scene;
    if (!s.active(item) || s.held == item) return 0;
    final pulse = _pulse;
    _glow.color = color.withValues(alpha: 0.25 + 0.4 * pulse);
    _c.drawCircle(c, radius * (1 + 0.05 * pulse), _glow);
    return pulse;
  }

  /// Size factor of [item]: grows while held (HTML `:active` scale 1.1) and
  /// pulses (× 1 … 1.05) while it waits to be picked up.
  double _grow(_Item item, double pulse) =>
      scene.held == item ? 1.1 : 1 + 0.05 * pulse;

  void _hand(_Item item) {
    final s = scene;
    final isLeft = item == _Item.leftHand;
    final c = _p.p(s.itemPos(item));
    final size = _handPx * _ik;
    final pulse = _pulseGlow(
      item,
      c,
      size * 0.48,
      isLeft ? _Colors.blue500 : _Colors.red500,
    );
    final grow = _grow(item, pulse);
    final tint = isLeft ? s.leftTint : s.rightTint;
    final unit = size * grow / _handViewBox;
    _c
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(isLeft ? -unit : unit, unit)
      ..translate(-_handPivot.dx, -_handPivot.dy);
    _fill
      ..shader = null
      ..color = Color.lerp(
        _Colors.skin,
        isLeft ? _Colors.sky200 : _Colors.red300,
        tint,
      )!;
    _c.drawPath(_handPath, _fill);
    _stroke
      ..strokeWidth = _handStroke
      ..color = _Colors.skinEdge;
    _c
      ..drawPath(_handPath, _stroke)
      ..restore();
    // In Beaker B the hands overlap: their chips go outwards, side by side.
    final inB = (isLeft ? s.leftIn : s.rightIn) == _Zone.beakerB;
    _itemChip(
      _t(isLeft ? 'lbl_left_hand' : 'lbl_right_hand'),
      c.translate(inB ? (isLeft ? 0.25 : -0.25) * size : 0, size * grow / 2),
      align: inB ? (isLeft ? 1 : -1) : 0,
    );
  }

  /// HTML `#drag-thermo` SVG (40 × 160): tube, bulb, red thread, marks.
  void _thermoIcon() {
    final s = scene;
    final c = _p.p(s.thermoIcon);
    final pulse = _pulseGlow(
      _Item.thermo,
      c,
      _thermoIconH * 0.3 * _ik,
      _Colors.red500,
    );
    final k = _ik * _grow(_Item.thermo, pulse);
    _c
      ..save()
      ..translate(c.dx - _thermoIconW * k / 2, c.dy - _thermoIconH * k / 2)
      ..scale(k);
    final tube = RRect.fromLTRBR(12, 10, 28, 140, const Radius.circular(8));
    _fill
      ..shader = null
      ..color = _Colors.slate50;
    _c.drawRRect(tube, _fill);
    _stroke
      ..strokeWidth = 2
      ..color = _Colors.slate300;
    _c.drawRRect(tube, _stroke);
    _fill.color = _Colors.red500;
    _c
      ..drawCircle(const Offset(20, 140), 12, _fill)
      ..drawRect(const Rect.fromLTWH(18, 60, 4, 80), _fill);
    _stroke
      ..strokeCap = StrokeCap.butt
      ..color = _Colors.slate500;
    for (var i = 0; i < 7; i++) {
      final y = 30.0 + i * 15;
      _c.drawLine(Offset(12, y), Offset(i.isEven ? 20 : 16, y), _stroke);
    }
    _stroke.strokeCap = StrokeCap.round;
    _c.restore();
    _itemChip(_t('lbl_thermo'), c.translate(0, _thermoIconH * k / 2));
  }

  /// HTML `#drag-burner` SVG (24-unit viewBox at 60 px): the indigo stand
  /// and the white flame.
  void _burnerIcon() {
    final s = scene;
    final c = _p.p(s.burnerIcon);
    final pulse = _pulseGlow(
      _Item.burner,
      c,
      _burnerIconPx * 0.5 * _ik,
      _Colors.blue500,
    );
    final size = _burnerIconPx * _ik * _grow(_Item.burner, pulse);
    _drawBurnerGlyph(c, size, _Colors.indigo500);
    _itemChip(_t('lbl_burner'), c.translate(0, size / 2));
  }

  /// The burner glyph (stand in [color], white flame) centred at [c].
  void _drawBurnerGlyph(Offset c, double size, Color color) {
    final unit = size / _burnerViewBox;
    _c
      ..save()
      ..translate(c.dx - size / 2, c.dy - size / 2)
      ..scale(unit);
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_burnerStand, _fill);
    _fill.color = _Colors.slate50;
    _c.drawPath(_burnerFlame, _fill);
    _stroke
      ..strokeWidth = 0.5
      ..color = _Colors.slate300;
    _c
      ..drawPath(_burnerFlame, _stroke)
      ..restore();
  }

  /// HTML `#btn-flame`: a round button with an orange border and the
  /// burner glyph, its blue ring pulsing outwards every 1.5 s.
  void _paintFlameButton() {
    final c = _p.p(_flameButtonAt);
    final r = _flameButtonPx / 2 * _ik;
    final phase = (scene.time % _ringPulseSeconds) / _ringPulseSeconds;
    _stroke
      ..strokeWidth = 3 * _ik
      ..color = _Colors.blue500.withValues(alpha: 0.7 * (1 - phase));
    _c.drawCircle(c, r + 10 * _ik * phase, _stroke);
    _fill
      ..shader = null
      ..color = (palette.isDark ? _Colors.slate800 : _Colors.white).withValues(
        alpha: 0.92,
      );
    _c.drawCircle(c, r, _fill);
    _stroke
      ..strokeWidth = 2.5 * _ik
      ..color = _Colors.orange500;
    _c.drawCircle(c, r, _stroke);
    _drawBurnerGlyph(c, r * 1.15, _Colors.orange500);
  }

  /// While an icon is held over the place it belongs, that place lights up
  /// (the HTML drop targets were invisible).
  void _paintZoneHint() {
    final s = scene;
    final item = s.held;
    if (item == null || !s.dragMoved) return;
    final zone = s.validZone(item);
    if (zone == null || !zone.contains(s.itemPos(item))) return;
    final rr = RRect.fromRectAndRadius(
      _p.zone(zone),
      Radius.circular(12 * _view),
    );
    _fill
      ..shader = null
      ..color = _Colors.blue500.withValues(alpha: 0.12);
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 2
      ..color = _Colors.blue400.withValues(alpha: 0.8);
    _c.drawRRect(rr, _stroke);
  }

  // ------------------------------------------------------------ primitives

  /// HTML lights: ambient + key light, toned down so lit faces keep their
  /// colour.
  Color _lit(Color c, _V n) {
    final i = 0.58 + 0.55 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  void _quad(_V a, _V b, _V c, _V d, Color color) {
    final pa = _p.p(a), pb = _p.p(b), pc = _p.p(c), pd = _p.p(d);
    _path
      ..reset()
      ..moveTo(pa.dx, pa.dy)
      ..lineTo(pb.dx, pb.dy)
      ..lineTo(pc.dx, pc.dy)
      ..lineTo(pd.dx, pd.dy)
      ..close();
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  /// [_path] := the outline of an upright cylinder seen from above: its
  /// sides, the front half of the [bottom] ellipse and the back half of the
  /// [top] ellipse.
  void _silhouette(Rect bottom, Rect top) {
    _path
      ..reset()
      ..moveTo(top.left, top.center.dy)
      ..lineTo(bottom.left, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(top.right, top.center.dy)
      ..arcTo(top, 0, -math.pi, false)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale ||
      old.flameButton != flameButton;
}

/// Canvas text, laid out once and reused every frame. Owned (and disposed)
/// by the page State.
class _PaintCache {
  final Map<String, TextPainter> _texts = {};

  /// Laid-out text (labels, bubbles, the magnifier's numbers).
  TextPainter text(String s, double size, Color color, FontWeight weight) {
    final key =
        '$s|${size.toStringAsFixed(2)}|${color.toARGB32()}|${weight.value}';
    final hit = _texts[key];
    if (hit != null) return hit;
    if (_texts.length > 240) _clear();
    return _texts[key] = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _clear() {
    for (final tp in _texts.values) {
      tp.dispose();
    }
    _texts.clear();
  }

  void dispose() => _clear();
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
