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

/// Class 6 Science • Chapter 7 • Activity 2
/// Clinical Thermometers and Human Body Temperature.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A2-Clinical_Thermometers_and_Human_Body_Temperature.html`.
/// The Three.js room is redrawn by a CustomPainter through a perspective
/// projection of the same camera (fov 45°, position (0, 12, 35), looking at
/// (0, 2, 0)).
///
/// Scenario 1 (Checking for a Fever): open the almirah, take out the digital
/// clinical thermometer, wash its tip under the tap with soap, reset it,
/// place the tip under Lambok's tongue, wait for the beep and take it out to
/// read 37.0 °C: a normal temperature, so no fever.
///
/// Scenario 2 (Is Everyone Exactly 37.0 °C?): measure Maya, Rahul and Sara
/// one after another (take the thermometer to the friend, Clean & Reset,
/// place it under the tongue, wait), record 36.8, 37.2 and 36.9 °C and plot
/// them on a 35–42 °C number line: they differ slightly but all lie in the
/// normal band, because normal body temperature is an average.
class Ch7A2ClinicalThermometersAndHumanBodyTemperaturePage
    extends StatefulWidget {
  const Ch7A2ClinicalThermometersAndHumanBodyTemperaturePage({super.key});

  @override
  State<Ch7A2ClinicalThermometersAndHumanBodyTemperaturePage> createState() =>
      _ThermometerLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises five tones with the Web Audio
/// API; each maps to the closest bundled file:
/// 'click' → click.mp3, 'pop' → pop.mp3, 'beep' (two 2500 Hz square beeps)
/// → dropdown.mp3, 'splash' (filtered noise) → drop.mp3, 'success' →
/// success.mp3. correct.mp3 / error.mp3 mark the shell's toasts.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pop → `science/pop.mp3`, beep → `science/dropdown.mp3`,
/// splash → `science/drop.mp3`, success → `math/success.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('click')`: almirah door, reset button, friend chosen,
  /// cleaning finished, Analyse Data and every plotted dot.
  click('audio/class6/science/click.mp3'),

  /// HTML `playSound('pop')`: Enter Lab, scenario change, sidebar, language.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('beep')`: the reading is complete.
  beep('audio/class6/science/dropdown.mp3'),

  /// HTML `playSound('splash')`: tap water, soap, rinse, Clean & Reset.
  splash('audio/class6/science/drop.mp3'),

  /// HTML `playSound('success')`: the conclusion.
  success('audio/class6/math/success.mp3'),

  /// Shell feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// Error toast (an action done out of order).
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
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

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617 (dark theme) / 0xf1f5f9 (light theme).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate100;

  /// Table `BoxGeometry(40, 2, 12)`, 0x475569.
  static const Color table = slate600;

  /// Almirah frame 0xd97706, inside 0x78350f, door 0xf59e0b, handle white.
  static const Color almirahFrame = Color(0xFFD97706);
  static const Color almirahInside = Color(0xFF78350F);
  static const Color almirahDoor = Color(0xFFF59E0B);
  static const Color handle = white;

  /// Sink: white basin, 0x94a3b8 bowl, 0x334155 faucet, 0x93c5fd water.
  static const Color basin = white;
  static const Color basinBowl = slate400;
  static const Color tapMetal = slate700;
  static const Color water = Color(0xFF93C5FD);

  /// Thermometer: body 0x0ea5e9, metal tip 0x94a3b8 (0x60a5fa while wet),
  /// screen 0x94a3b8 with 0x020617 digits, reset button 0xef4444.
  static const Color thermBody = Color(0xFF0EA5E9);
  static const Color tipMetal = slate400;
  static const Color tipWet = Color(0xFF60A5FA);
  static const Color screen = slate400;
  static const Color digits = slate950;
  static const Color resetButton = red500;

  /// buildCharacter(): trousers 0x1e293b, face ink 0x0f172a, open mouth
  /// 0x450a0a, fever flush rgba(239, 68, 68, 0.7). The HTML hair (0x020617)
  /// is the scene background colour and vanished against it; it is drawn
  /// dark brown with a lighter rim.
  static const Color trousers = slate800;
  static const Color hair = Color(0xFF3B2A20);
  static const Color faceInk = slate900;
  static const Color mouthOpen = Color(0xFF450A0A);
  static const Color feverFlush = Color(0xB3EF4444);

  /// The four people (skin, shirt) of buildS1 / buildS2.
  static const Color lambokSkin = Color(0xFFFCD34D);
  static const Color lambokShirt = Color(0xFFF59E0B);
  static const Color mayaSkin = Color(0xFFFCA5A5);
  static const Color mayaShirt = Color(0xFFEC4899);
  static const Color rahulSkin = Color(0xFFD6D3D1);
  static const Color rahulShirt = Color(0xFF3B82F6);
  static const Color saraSkin = Color(0xFFFDE047);
  static const Color saraShirt = Color(0xFF10B981);

  /// Highlight glow (emissive 0xeab308) and the target ring.
  static const Color glow = Color(0xFFEAB308);

  /// Label sprites: rgba(15, 23, 42, 0.9) with a 0x6366f1 border.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = indigo500;

  /// Water droplets of the confetti bursts.
  static const Color dropWhite = white;
  static const Color dropBlue = tipWet;
  static const Color dropPale = Color(0xFFBAE6FD);

  /// Soap dispenser (the HTML SVG): body, band, neck, pump, nozzle.
  static const Color soapBody = indigo500;
  static const Color soapBand = Color(0x804F46E5);
  static const Color soapNeck = slate300;
  static const Color soapPump = slate50;
  static const Color soapNozzle = slate400;

  /// Card / pill fills drawn on the canvas.
  static const Color glassDark = Color(0xF21E293B);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color shadow = Color(0x59000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// accent is the HTML indigo: indigo-400 on dark panels (the HTML's
/// `dark:text-indigo-400`), indigo-600 on light ones, so text stays legible.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950, // #canvas-wrapper bg-[#020617]
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo400,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600, // popup buttons bg-indigo-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // completed steps
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300, // text-indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x99475569),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000),
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo600,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // the shutter is dark in both themes
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.indigo600,
    buttonBorder: Color(0x26000000),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting in px (HTML `--sidebar-font-size`: 15 px, slider
/// 12–22 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays its 'pop' for the curtain, scenario change, sidebar and language.
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.correct,
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
// From the HTML `i18n` / `ScenariosData` tables (Telugu dropped). Changes:
// * "CLICK" is "TAP" (touch screen), in the steps and the HUD lines;
// * S1 step 6 and S2 step 6 end with the HUD's "TAP 'Observe Conclusion'",
//   S2 step 4 spells out the three actions it repeats, S1 step 2 says the
//   second rinse happens by itself, S1 step 3 names the red button;
// * S2 step 5 / HUD 5 lose "on the table" (the button sits in the sidebar /
//   mission card);
// * the graph note speaks of healthy people (three friends), and the final
//   text calls normal temperature an average instead of "an average range";
// * keys marked "added" were missing in the HTML (the English graph title)
//   or are new (hints, units, table texts).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Clinical Thermometers and Human Body Temperature',
    'app_subtitle': 'Class 6 • Temperature and its Measurement',
    'scen_1_title': 'Scenario 1: Checking for a Fever',
    'scen_2_title': 'Scenario 2: Is Everyone Exactly 37.0°C?',
    'scen_1_obj':
        "To correctly use a digital clinical thermometer to measure a person's body temperature.",
    'scen_2_obj':
        'Measure the body temperatures of several friends and record the data to observe that normal temperature varies.',
    // Scenario 1 steps: concept, action, observation.
    's1_c1': 'Accessing the Clinical Thermometer',
    's1_a1':
        'The almirah is highlighted. TAP the almirah door to open it, then DRAG the digital thermometer from the shelf onto the workspace.',
    's1_o1':
        'The almirah opens, and you have successfully retrieved the thermometer to the main interaction area.',
    's1_c2': 'Proper Hygiene and Preparation',
    's1_a2':
        'Lambok says he feels feverish. DRAG the tip of the thermometer under the running water tap. Then DRAG or TAP the soap dispenser to wash the tip; it is rinsed again by itself.',
    's1_o2':
        'The thermometer tip is properly washed and cleaned, ensuring it is hygienic and safe to use.',
    's1_c3': 'Resetting the Thermometer',
    's1_a3':
        'TAP the red reset button on the thermometer to prepare it for a new reading.',
    's1_o3':
        "The thermometer's digital display is reset to show '00.0 °C', indicating it is ready to measure.",
    's1_c4': 'Correct Placement',
    's1_a4':
        "DRAG the tip of the thermometer and DROP it into the highlighted area under Lambok's tongue.",
    's1_o4':
        "The thermometer is correctly placed in Lambok's mouth for an accurate body temperature reading.",
    's1_c5': 'Measurement Duration',
    's1_a5':
        'Wait for the progress bar to fill and for the thermometer to beep.',
    's1_o5':
        'The measurement process takes a few moments. A beep signals that the temperature reading is complete.',
    's1_c6': 'Reading and Conclusion',
    's1_a6':
        "DRAG the thermometer out of Lambok's mouth to read the final temperature on the digital display, then TAP 'Observe Conclusion'.",
    's1_o6':
        'The display shows 37.0 °C. This is considered a normal body temperature, so he does not have a fever.',
    // Scenario 2 steps.
    's2_c1': 'Initiating Data Collection',
    's2_a1':
        'Three friends are waiting. A data table is on the screen. DRAG the thermometer to the first friend to begin.',
    's2_o1':
        "You have initiated the process of measuring the first friend's temperature to gather more data.",
    's2_c2': 'Repeated Hygiene and Setup',
    's2_a2':
        "You know the steps! TAP the 'Clean & Reset' button to wash the thermometer and reset it to '00.0', then DRAG it under the friend's tongue.",
    's2_o2':
        'The thermometer is correctly and hygienically prepared and placed for the next person.',
    's2_c3': 'Automatic Data Recording',
    's2_a3':
        'After the beep, observe the reading on the display. Wait for it to be recorded.',
    's2_o3':
        "The first friend's temperature is measured and automatically added to the corresponding row in the data table.",
    's2_c4': 'Gathering Multiple Data Points',
    's2_a4':
        "Repeat the process for the second and third friends: DRAG the thermometer to the friend, TAP the 'Clean & Reset' button, then DRAG it under the friend's tongue. Make sure to clean and reset it each time before measuring.",
    's2_o4':
        'The temperatures of all three friends are successfully measured and recorded in the data table for comparison.',
    's2_c5': 'Visualizing the Data',
    's2_a5':
        "All temperatures are recorded. TAP the 'Analyse Data' button to plot the readings on a number line.",
    's2_o5':
        'The readings appear as dots on the number line. You can visualize how they fall within a specific green band.',
    's2_c6': 'Concluding Normal Temperature',
    's2_a6':
        "Observe how all the temperatures are slightly different but still fall within the normal range band, then TAP 'Observe Conclusion'.",
    's2_o6':
        'You understand that normal human body temperature is an average (around 37.0°C), and slight variations among individuals are completely healthy and common.',
    // HTML `hud` lines (the canvas "Current Task" chip).
    's1_hud_1':
        'Step 1: TAP the almirah door to open it. DRAG the digital thermometer onto the workspace.',
    's1_hud_2':
        'Step 2: DRAG the thermometer to the sink. DRAG or TAP the soap to wash the tip.',
    's1_hud_3': 'Step 3: TAP the reset button on the thermometer.',
    's1_hud_4': "Step 4: DRAG the thermometer tip to Lambok's mouth.",
    's1_hud_5': 'Step 5: Wait for the beep...',
    's1_hud_6':
        "Step 6: DRAG the thermometer out to read the temperature. Tap 'Observe Conclusion'.",
    's2_hud_1': 'Step 1: DRAG the thermometer to the first friend (Maya).',
    's2_hud_2':
        "Step 2: TAP the 'Clean & Reset' button, then DRAG the thermometer to the friend's mouth.",
    's2_hud_3':
        'Step 3: Wait for the measurement. Data will record automatically.',
    's2_hud_4': 'Step 4: Repeat the process for the remaining friends.',
    's2_hud_5': "Step 5: TAP the 'Analyse Data' button.",
    's2_hud_6': "Step 6: Observe the graph. Tap 'Observe Conclusion'.",
    // Scene labels.
    'lbl_almirah': 'Almirah',
    'lbl_therm': 'Thermometer',
    'lbl_sink': 'Sink',
    'lbl_lambok': 'Lambok',
    'lbl_f1': 'Maya',
    'lbl_f2': 'Rahul',
    'lbl_f3': 'Sara',
    'measuring': 'Measuring...',
    // Data table, buttons and graph.
    'temp_records': 'Temperature Records',
    'name': 'Name',
    'temp_c': 'Temp (°C)',
    'analyse': 'Analyse Data',
    'clean_reset': 'Clean & Reset',
    'btn_conclude': 'Observe Conclusion',
    'graph_title': 'Normal Temperature Range', // added (hard-coded in HTML)
    'normal_range': 'Normal Range',
    'graph_desc':
        'Notice that the temperatures of healthy people vary slightly. Normal temperature is an average.',
    // Sidebar step list (HTML teacher board).
    'concept_exp': 'Observation Steps',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Toasts.
    'toast_drag_soap': 'Drag or tap the soap onto the thermometer tip!',
    // Conclusions.
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1_title': 'Great Job!',
    'sum_s1_desc':
        "You correctly cleaned, reset, and used the thermometer. Lambok's temperature is 37.0 °C. This is considered normal, so he does not have a fever.",
    'sum_s2_title': 'Data Analyzed!',
    'sum_s2_desc':
        'You observed that the friends had slightly different temperatures.\n\nKey takeaway: Normal human body temperature is the average temperature of healthy persons, not exactly 37.0°C for everyone.',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You learned how to properly use a clinical thermometer, and that normal body temperature is an average (about 37.0 °C), not a single fixed number for everyone!',
    // Added.
    'unit_c': '°C',
    'tbl_pending': '—',
    'obs_pending': 'The result appears once you complete this step.',
    'toast_clean_first':
        "First tap 'Clean & Reset' to wash the thermometer and reset it to '00.0'.",
    'toast_reset_btn': 'Tap the red reset button on the thermometer.',
    'scene_s1':
        'Lab table with an almirah, a sink, a digital thermometer and Lambok',
    'scene_s2':
        'Maya, Rahul and Sara behind a table with a digital thermometer',
  },
  'hi': {
    'app_title': 'क्लिनिकल थर्मामीटर और मानव शरीर का तापमान',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'scen_1_title': 'परिदृश्य 1: बुखार की जांच करना',
    'scen_2_title': 'परिदृश्य 2: क्या हर कोई बिल्कुल 37.0°C है?',
    'scen_1_obj':
        'किसी व्यक्ति के शरीर का तापमान मापने के लिए डिजिटल क्लिनिकल थर्मामीटर का सही ढंग से उपयोग करना।',
    'scen_2_obj':
        'कई दोस्तों के शरीर के तापमान को मापें और डेटा रिकॉर्ड करें ताकि यह देखा जा सके कि सामान्य तापमान भिन्न होता है।',
    's1_c1': 'क्लिनिकल थर्मामीटर तक पहुंचना',
    's1_a1':
        'अलमारी को हाइलाइट किया गया है। इसे खोलने के लिए अलमारी के दरवाजे पर टैप करें, फिर डिजिटल थर्मामीटर को शेल्फ से कार्यक्षेत्र पर खींचें।',
    's1_o1':
        'अलमारी खुलती है, और आपने थर्मामीटर को मुख्य इंटरैक्शन क्षेत्र में सफलतापूर्वक प्राप्त कर लिया है।',
    's1_c2': 'उचित स्वच्छता और तैयारी',
    's1_a2':
        'लाम्बोक कहता है कि उसे बुखार महसूस हो रहा है। थर्मामीटर की नोक को बहते पानी के नल के नीचे खींचें। फिर नोक को धोने के लिए साबुन डिस्पेंसर को खींचें या टैप करें; नोक अपने आप फिर से धुल जाती है।',
    's1_o2':
        'थर्मामीटर की नोक को ठीक से धोया और साफ किया जाता है, यह सुनिश्चित करते हुए कि यह स्वच्छ और उपयोग करने के लिए सुरक्षित है।',
    's1_c3': 'थर्मामीटर को रीसेट करना',
    's1_a3':
        'नई रीडिंग के लिए इसे तैयार करने के लिए थर्मामीटर पर लाल रीसेट बटन पर टैप करें।',
    's1_o3':
        "थर्मामीटर का डिजिटल डिस्प्ले '00.0 °C' दिखाने के लिए रीसेट हो गया है, जो दर्शाता है कि यह मापने के लिए तैयार है।",
    's1_c4': 'सही प्लेसमेंट',
    's1_a4':
        'थर्मामीटर की नोक को खींचें और इसे लाम्बोक की जीभ के नीचे हाइलाइट किए गए क्षेत्र में छोड़ दें।',
    's1_o4':
        'सटीक शरीर के तापमान की रीडिंग के लिए थर्मामीटर लाम्बोक के मुंह में सही ढंग से रखा गया है।',
    's1_c5': 'माप की अवधि',
    's1_a5': 'प्रगति पट्टी के भरने और थर्मामीटर के बीप होने की प्रतीक्षा करें।',
    's1_o5':
        'माप प्रक्रिया में कुछ क्षण लगते हैं। एक बीप संकेत देती है कि तापमान रीडिंग पूरी हो गई है।',
    's1_c6': 'रीडिंग और निष्कर्ष',
    's1_a6':
        "डिजिटल डिस्प्ले पर अंतिम तापमान पढ़ने के लिए थर्मामीटर को लाम्बोक के मुंह से बाहर खींचें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's1_o6':
        'डिस्प्ले 37.0 °C दिखाता है। इसे सामान्य शरीर का तापमान माना जाता है, इसलिए उसे बुखार नहीं है।',
    's2_c1': 'डेटा संग्रह शुरू करना',
    's2_a1':
        'तीन दोस्त इंतज़ार कर रहे हैं। स्क्रीन पर एक डेटा टेबल है। शुरू करने के लिए थर्मामीटर को पहले दोस्त तक खींचें।',
    's2_o1':
        'आपने अधिक डेटा एकत्र करने के लिए पहले दोस्त के तापमान को मापने की प्रक्रिया शुरू कर दी है।',
    's2_c2': 'बार-बार स्वच्छता और सेटअप',
    's2_a2':
        "आप कदम जानते हैं! थर्मामीटर को धोने और इसे '00.0' पर रीसेट करने के लिए 'साफ करें और रीसेट करें' बटन पर टैप करें, फिर इसे खींचकर दोस्त की जीभ के नीचे रखें।",
    's2_o2':
        'अगले व्यक्ति के लिए थर्मामीटर सही ढंग से और स्वच्छता से तैयार और रखा गया है।',
    's2_c3': 'स्वचालित डेटा रिकॉर्डिंग',
    's2_a3':
        'बीप के बाद, डिस्प्ले पर रीडिंग देखें। इसे रिकॉर्ड होने की प्रतीक्षा करें।',
    's2_o3':
        'पहले दोस्त का तापमान मापा जाता है और स्वचालित रूप से डेटा टेबल में संबंधित पंक्ति में जोड़ा जाता है।',
    's2_c4': 'कई डेटा पॉइंट एकत्र करना',
    's2_a4':
        "दूसरे और तीसरे दोस्तों के लिए प्रक्रिया को दोहराएं: थर्मामीटर को दोस्त तक खींचें, 'साफ करें और रीसेट करें' बटन पर टैप करें, फिर इसे खींचकर दोस्त की जीभ के नीचे रखें। मापने से पहले हर बार थर्मामीटर को साफ और रीसेट करना सुनिश्चित करें।",
    's2_o4':
        'तुलना के लिए डेटा टेबल में तीनों दोस्तों के तापमान को सफलतापूर्वक मापा और रिकॉर्ड किया गया है।',
    's2_c5': 'डेटा की कल्पना करना',
    's2_a5':
        "सभी तापमान रिकॉर्ड किए गए हैं। रीडिंग को संख्या रेखा पर प्लॉट करने के लिए 'डेटा का विश्लेषण करें' बटन पर टैप करें।",
    's2_o5':
        'रीडिंग संख्या रेखा पर बिंदुओं के रूप में दिखाई देती है। आप देख सकते हैं कि वे एक विशिष्ट हरे बैंड के भीतर कैसे आते हैं।',
    's2_c6': 'सामान्य तापमान का निष्कर्ष निकालना',
    's2_a6':
        "ध्यान दें कि सभी तापमान थोड़े अलग हैं लेकिन फिर भी सामान्य सीमा बैंड के भीतर आते हैं, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's2_o6':
        'आप समझते हैं कि सामान्य मानव शरीर का तापमान एक औसत (लगभग 37.0°C) है, और व्यक्तियों में मामूली भिन्नताएं पूरी तरह से स्वस्थ और आम हैं।',
    's1_hud_1':
        'चरण 1: अलमारी का दरवाजा खोलने के लिए टैप करें। डिजिटल थर्मामीटर को कार्यक्षेत्र पर खींचें।',
    's1_hud_2':
        'चरण 2: थर्मामीटर को सिंक पर खींचें। नोक धोने के लिए साबुन को खींचें या टैप करें।',
    's1_hud_3': 'चरण 3: थर्मामीटर पर रीसेट बटन पर टैप करें।',
    's1_hud_4': 'चरण 4: थर्मामीटर की नोक को लाम्बोक के मुंह तक खींचें।',
    's1_hud_5': 'चरण 5: बीप की प्रतीक्षा करें...',
    's1_hud_6':
        "चरण 6: तापमान पढ़ने के लिए थर्मामीटर को बाहर खींचें। 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_1': 'चरण 1: थर्मामीटर को पहले दोस्त (माया) तक खींचें।',
    's2_hud_2':
        "चरण 2: 'साफ करें और रीसेट करें' बटन पर टैप करें, फिर थर्मामीटर को दोस्त के मुंह तक खींचें।",
    's2_hud_3':
        'चरण 3: माप की प्रतीक्षा करें। डेटा स्वचालित रूप से रिकॉर्ड होगा।',
    's2_hud_4': 'चरण 4: शेष दोस्तों के लिए प्रक्रिया को दोहराएं।',
    's2_hud_5': "चरण 5: 'डेटा का विश्लेषण करें' बटन पर टैप करें।",
    's2_hud_6': "चरण 6: ग्राफ देखें। 'निष्कर्ष देखें' पर टैप करें।",
    'lbl_almirah': 'अलमारी',
    'lbl_therm': 'थर्मामीटर',
    'lbl_sink': 'सिंक',
    'lbl_lambok': 'लाम्बोक',
    'lbl_f1': 'माया',
    'lbl_f2': 'राहुल',
    'lbl_f3': 'सारा',
    'measuring': 'माप रहा है...',
    'temp_records': 'तापमान रिकॉर्ड',
    'name': 'नाम',
    'temp_c': 'तापमान (°C)',
    'analyse': 'डेटा का विश्लेषण करें',
    'clean_reset': 'साफ करें और रीसेट करें',
    'btn_conclude': 'निष्कर्ष देखें',
    'graph_title': 'सामान्य तापमान सीमा',
    'normal_range': 'सामान्य सीमा',
    'graph_desc':
        'ध्यान दें कि स्वस्थ लोगों का तापमान थोड़ा भिन्न होता है। सामान्य तापमान एक औसत है।',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'toast_drag_soap': 'साबुन को थर्मामीटर की नोक पर खींचें या टैप करें!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1_title': 'बहुत बढ़िया!',
    'sum_s1_desc':
        'आपने थर्मामीटर को सही ढंग से साफ किया, रीसेट किया और उपयोग किया। लाम्बोक का तापमान 37.0 °C है। इसे सामान्य माना जाता है, इसलिए उसे बुखार नहीं है।',
    'sum_s2_title': 'डेटा का विश्लेषण किया गया!',
    'sum_s2_desc':
        'आपने देखा कि दोस्तों का तापमान थोड़ा अलग था।\n\nमुख्य निष्कर्ष: सामान्य मानव शरीर का तापमान स्वस्थ व्यक्तियों का औसत तापमान है, न कि हर किसी के लिए बिल्कुल 37.0°C।',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने सीखा कि क्लिनिकल थर्मामीटर का ठीक से उपयोग कैसे किया जाए, और यह कि सामान्य शरीर का तापमान एक औसत (लगभग 37.0 °C) है, हर व्यक्ति के लिए एक निश्चित संख्या नहीं!',
    'unit_c': '°C',
    'tbl_pending': '—',
    'obs_pending': 'यह चरण पूरा करने पर परिणाम दिखाई देगा।',
    'toast_clean_first':
        "पहले 'साफ करें और रीसेट करें' पर टैप करें, ताकि थर्मामीटर धुल जाए और '00.0' पर रीसेट हो जाए।",
    'toast_reset_btn': 'थर्मामीटर पर लाल रीसेट बटन पर टैप करें।',
    'scene_s1':
        'अलमारी, सिंक, डिजिटल थर्मामीटर और लाम्बोक वाली प्रयोगशाला की मेज',
    'scene_s2': 'मेज के पीछे माया, राहुल और सारा, और एक डिजिटल थर्मामीटर',
  },
};

/// Steps per scenario (HTML `steps`).
const int _stepCount = 6;
const int _scenarioCount = 2;

/// Scenarios and steps for [lang] (HTML `ScenariosData`: concept, action and
/// observation per step).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_title'),
        objective: t('scen_${n}_obj'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_c$i'),
              action: t('s${n}_a$i'),
              observation: t('s${n}_o$i'),
            ),
        ],
      ),
  ];
}

final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Where the camera's look-at point lands on the stage. The HTML puts it in
/// the middle (500, 280), which cut Lambok's head off at the top edge; it is
/// drawn 55 px lower so the whole room is in view.
const Offset _lookAtOnStage = Offset(500, 335);

/// HTML `camera.position.set(0, 12, 35)`, `controls.target.set(0, 2, 0)`
/// (init3D and resetCamera).
const _V _camEye = _V(0, 12, 35);
const _V _camTarget = _V(0, 2, 0);

/// Scenario 2 close-up on the friend being measured (HTML checkDrop): the
/// camera glides to (x, headY + 2, 20) looking at (x, headY − 2, 0) in
/// 800 ms (position Quadratic.Out, target linear).
const double _zoomEyeLift = 2;
const double _zoomTargetDrop = 2;
const double _zoomEyeZ = 20;
const double _zoomSeconds = 0.8;

/// HTML key light `DirectionalLight` at (10, 30, 20), normalised.
const _V _light = _V(0.2673, 0.8018, 0.5345);

/// The HTML lights (ambient 0.9 + directional 1.0) saturate most faces to
/// white in a flat drawing; these weights keep the material colours close
/// to the HTML hex values while still shading the faces.
const double _ambient = 0.72;
const double _diffuse = 0.42;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing the thermometer or the soap (short drags count).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable (the canvas cards scale the same way).
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the simulation (s).
const double _maxFrameStep = 0.1;

/// While the sidebar is collapsed the floating mission card covers the top
/// left of the canvas. The view then re-frames (shifts right and, when the
/// room does not fit, zooms out) so everything the learner taps or drags
/// lies between the card and the tool column, [_frameGap] design px clear
/// of both. It shrinks towards [_frameAnchorY]: the HUD is hidden while the
/// sidebar is collapsed, so the bottom of the stage is free.
const double _frameAnchorY = 520;
const double _frameGap = 10;

/// Rate (1/s) at which the framing follows the sidebar (settles in ~0.4 s).
const double _frameRate = 10;

// ---------------------------------------------------------------- the room

/// Table `BoxGeometry(40, 2, 12)` at y = −1: its top is at y = 0.
const double _tableTop = 0;

/// Almirah group at (−14, 5.5, −4): frame `BoxGeometry(8, 15, 6)`. The HTML
/// sank its lower 2 units into the table; only the part above the table top
/// is drawn.
const double _almX = -14;
const double _almZ = -4;
const double _almTop = 13;

/// Door: `BoxGeometry(8, 15, 0.4)` hinged at the frame's front right edge
/// (−10, 5.5, −1); it swings to y = −π/1.8 in 500 ms.
const _V _doorHinge = _V(-10, 5.5, -1);
const double _doorOpenAngle = -math.pi / 1.8;
const double _doorSeconds = 0.5;

/// Thermometer on the shelf: HTML (−14, 4.5, −1), drawn 1 unit deeper so it
/// sits inside the closed doors (at z = −1 it poked through them).
const _V _shelfSpot = _V(-14, 4.5, -2);

/// checkDrop step 1: dropped right of x = −8 the thermometer lands on the
/// table at (x, 0.5, 2); x is kept between the almirah and the sink.
const double _workspaceMinX = -8;
const double _landMinX = -7;
const double _landMaxX = 4;
const double _landY = 0.5;
const double _landZ = 2;

/// Sink group at (10, 0, 0): basin `BoxGeometry(10, 2.5, 7)`.
const double _sinkX = 10;

/// Thermometer under the faucet (12.8, 3.5, −0.2): its tip in the stream.
const _V _atSink = _V(12.8, 3.5, -0.2);

/// Where the stream meets the tip; the dragged tip must reach it.
const _V _streamPoint = _V(10, 3.5, -0.2);

/// After washing it moves to (5, 0.5, 2) in 400 ms.
const _V _afterWash = _V(5, 0.5, 2);
const double _washMoveSeconds = 0.4;

/// Scenario 2 start and rest position (0, 0.5, 5).
const _V _s2Rest = _V(0, 0.5, 5);

/// buildCharacter(): every person stands at (x, −3, −4), scaled.
const double _feetY = -3;
const double _personZ = -4;

/// The face plane floats 2.85 in front of the head centre; the mouth is
/// drawn at texture y 380 of 512 on a 5.6-unit plane (1.356 below centre).
const double _faceFront = 2.85;
const double _mouthDrop = 1.356;

/// Arms hang 18° (π/10) away from the body. The HTML turned them inwards,
/// into the torso.
const double _armSpread = math.pi / 10;

/// Hair hemisphere: radius 2.9, raised 0.2, tilted back 0.15 rad.
const double _hairTilt = 0.15;

// -------------------------------------------------------- the thermometer

/// buildCommon(): body `BoxGeometry(4.5, 0.6, 0.9)`.
const _V _bodyHalf = _V(2.25, 0.3, 0.45);

/// Metal tip `CylinderGeometry(0.25, 0.3, 1.5)` along x, centred at −2.8.
const double _tipStartX = -2.05;
const double _tipEndX = -3.55;
const double _tipRadius = 0.27;

/// Digital screen `PlaneGeometry(2.0, 0.8)` on top, centred at x = −0.5.
const double _screenX0 = -1.5;
const double _screenX1 = 0.5;
const double _screenHalfZ = 0.4;
const double _screenY = 0.31;

/// Reset button `CylinderGeometry(0.3, 0.3, 0.2)` at (1.2, 0.35, 0).
const _V _buttonTop = _V(1.2, 0.45, 0);
const double _buttonRadius = 0.3;

/// Label sprite at (3.5, 1.5, 0) on the thermometer.
const _V _thermLabelAt = _V(3.5, 1.5, 0);

/// snapToMouth(): the HTML turned the thermometer by y −π/8 and z +π/6,
/// which left the tip beside the chin. The tip end now sits on the mouth,
/// the body sloping slightly down and towards the viewer.
const double _mouthRy = -math.pi / 8;
const double _mouthRz = -math.pi / 9;

// ------------------------------------------------------- drop targets

/// Drop targets in design px (scaled with the framing). The HTML used 3D
/// spheres (6 units round the sink, 250 screen px for the soap, |dx| < 8 for
/// a friend, 12 units round a friend's head) that accepted drops without a
/// real move: in Scenario 2 any drop picked Rahul, and once cleaned any drop
/// counted as "in the mouth". These are touch-sized targets instead.
const double _sinkCatch = 70;
const double _soapCatch = 110;
const double _friendCatch = 60;

/// The tip is under the tongue when within one head radius of the mouth;
/// taken out once farther than 1.5 head radii.
const double _outFactor = 1.5;

/// The soap appears left of the tip (HTML: 100 px left of the thermometer)
/// and bobs (HTML `animate-bounce`); its size in design px.
const Offset _soapOffset = Offset(-70, 6);
const double _soapSize = 58;

// ------------------------------------------------------------- timings

/// HTML TWEEN 300 ms back to `originalPos` after a wrong drop.
const double _snapBackSeconds = 0.3;

/// snapToMouth tween (300 ms).
const double _mouthSnapSeconds = 0.3;

/// Soap on the tip → 1 s → second rinse and the move (400 ms) → step 3.
const Duration _washRinseDelay = Duration(milliseconds: 1000);
const Duration _washMoveTime = Duration(milliseconds: 400);

/// The progress bar fills in 3 s (`duration-[3000ms]`), then the beep.
const Duration _measureTime = Duration(milliseconds: 3000);
const double _measureSeconds = 3;

/// The reading flies to the table in 1 s (`.flying-number`).
const Duration _flyTime = Duration(milliseconds: 1000);
const double _flySeconds = 1;

/// Clean & Reset: blue tip for 800 ms, then '00.0'.
const Duration _cleanTime = Duration(milliseconds: 800);

/// Dots pop in every 400 ms; the summary 800 ms after the last one.
const Duration _dotGap = Duration(milliseconds: 400);
const double _dotGapSeconds = 0.4;
const double _dotPopSeconds = 0.4;
const Duration _summaryDelay = Duration(milliseconds: 1600);

/// The conclusion popup opens just after 'Observe Conclusion'.
const Duration _conclusionDelay = Duration(milliseconds: 300);

/// Highlight glow (emissive 0 ↔ 0.6, 500 ms yoyo).
const double _glowMax = 0.6;
const double _glowPeriod = 1;

/// Water droplet bursts (HTML canvas-confetti) last this long.
const double _burstSeconds = 0.8;

/// The flying reading fades through this many alpha steps.
const double _fadeSteps = 10;

/// Clinical thermometer range on the number line (35–42 °C) and the normal
/// band (HTML: left 21.4 %, width 14.2 % → 36.5–37.5 °C).
const double _lineMin = 35;
const double _lineMax = 42;
const double _bandMin = 36.5;
const double _bandMax = 37.5;

/// Room kept above the HUD chip for canvas cards while the sidebar is open,
/// and below the top edge for the toast.
const double _hudClear = 70;
const double _toastClear = 44;

/// Widest graph card (dp, times the UI scale).
const double _graphWidth = 440;

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

  @override
  bool operator ==(Object other) =>
      other is _V && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Position and turn of an object (Three.js Euler XYZ with x = 0: the local
/// vector is turned about z, then about y).
@immutable
class _Pose {
  const _Pose(this.pos, [this.ry = 0, this.rz = 0]);

  final _V pos;
  final double ry;
  final double rz;

  /// [v] turned by this pose (no translation).
  _V dir(_V v) {
    final cz = math.cos(rz), sz = math.sin(rz);
    final x1 = v.x * cz - v.y * sz;
    final y1 = v.x * sz + v.y * cz;
    final cy = math.cos(ry), sy = math.sin(ry);
    return _V(x1 * cy + v.z * sy, y1, -x1 * sy + v.z * cy);
  }

  /// World position of the local point [local].
  _V at(_V local) => pos + dir(local);

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
    _V.lerp(a.pos, b.pos, t),
    a.ry + (b.ry - a.ry) * t,
    a.rz + (b.rz - a.rz) * t,
  );
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, followed by the collapsed-
/// sidebar framing (`x' = dx + k·x`, `y' = dy + k·y`).
@immutable
class _Cam {
  factory _Cam(
    _V eye,
    _V target, {
    double k = 1,
    double dx = 0,
    double dy = 0,
  }) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, target, f, r, r.cross(f), k, dx, dy);
  }

  const _Cam._(
    this.eye,
    this.target,
    this.f,
    this.r,
    this.u,
    this.k,
    this.dx,
    this.dy,
  );

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final _V target;
  final _V f;
  final _V r;
  final _V u;
  final double k;
  final double dx;
  final double dy;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => k * focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final s = focal / math.max(0.1, d.dot(f));
    return Offset(
      dx + k * (_lookAtOnStage.dx + d.dot(r) * s),
      dy + k * (_lookAtOnStage.dy - d.dot(u) * s),
    );
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset at) {
    final x = (at.dx - dx) / k - _lookAtOnStage.dx;
    final y = (at.dy - dy) / k - _lookAtOnStage.dy;
    return (f + r * (x / focal) + u * (-y / focal)).unit;
  }

  /// Where the ray through [at] meets the plane `n · x = d` (HTML
  /// `raycaster.ray.intersectPlane(dragPlane, …)`).
  _V? onPlane(Offset at, _V n, double d) {
    final dir = ray(at);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// buildCharacter(name, skin, x, scale, shirt) of buildS1 / buildS2 and the
/// temperature the thermometer reads for each person (HTML '37.0' for
/// Lambok, `friendsData` for the friends).
enum _Person {
  lambok('lbl_lambok', -2, 1.2, _Colors.lambokSkin, _Colors.lambokShirt, 37.0),
  maya('lbl_f1', -10, 0.9, _Colors.mayaSkin, _Colors.mayaShirt, 36.8),
  rahul('lbl_f2', 0, 0.9, _Colors.rahulSkin, _Colors.rahulShirt, 37.2),
  sara('lbl_f3', 10, 0.9, _Colors.saraSkin, _Colors.saraShirt, 36.9);

  const _Person(
    this.nameKey,
    this.x,
    this.scale,
    this.skin,
    this.shirt,
    this.reading,
  );

  final String nameKey;
  final double x;
  final double scale;
  final Color skin;
  final Color shirt;
  final double reading;

  /// Head group at y 13.5 (scaled), sphere radius 2.8.
  _V get head => _V(x, _feetY + 13.5 * scale, _personZ);
  double get headRadius => 2.8 * scale;
  _V get mouth =>
      _V(x, head.y - _mouthDrop * scale, _personZ + _faceFront * scale);
  _V get chest => _V(x, _feetY + 8.5 * scale, _personZ);

  /// The progress bar is drawn in front of the chest.
  _V get pillAnchor =>
      _V(x - scale, _feetY + 7.8 * scale, _personZ + 1.5 * scale);
}

/// The three friends of Scenario 2, in table order.
const List<_Person> _friends = [_Person.maya, _Person.rahul, _Person.sara];

/// Face textures of createFaceTexture().
enum _Mood { neutral, fever, happy, open }

/// Where the thermometer rests.
enum _Spot { shelf, table, sink, mouth }

/// What the current pointer holds.
enum _Grab { none, thermometer, soap }

/// The digital clinical thermometer (HTML `thermometer` group).
class _Thermo {
  _Pose pose = const _Pose(_V.zero);

  /// HTML `userData.originalPos`: where a wrong drop sends it back.
  _Pose home = const _Pose(_V.zero);
  bool visible = true;
  bool draggable = false;

  /// The tip turns blue (0x60a5fa) while it is washed.
  bool tipWet = false;

  /// Text on the digital screen ('', '00.0', '---' or a reading).
  String display = '';
  _Spot spot = _Spot.table;

  _Pose? _from;
  _Pose? _to;
  double _start = 0;
  double _seconds = 1;

  bool get moving => _to != null;
  bool get atHome => !moving && (pose.pos - home.pos).length < 1e-6;

  /// Linear tween (TWEEN's default easing) to [to].
  void moveTo(_Pose to, double now, double seconds) {
    _from = pose;
    _to = to;
    _start = now;
    _seconds = seconds;
  }

  void place(_Pose p) {
    pose = p;
    _to = null;
  }

  void advance(double now) {
    final to = _to;
    final from = _from;
    if (to == null || from == null) return;
    final t = ((now - _start) / _seconds).clamp(0.0, 1.0);
    pose = _Pose.lerp(from, to, t);
    if (t >= 1) _to = null;
  }
}

/// A camera glide (HTML TWEEN on `camera.position` and `controls.target`).
@immutable
class _CamMove {
  const _CamMove(
    this.eyeFrom,
    this.eyeTo,
    this.targetFrom,
    this.targetTo,
    this.start,
  );

  final _V eyeFrom;
  final _V eyeTo;
  final _V targetFrom;
  final _V targetTo;
  final double start;
}

/// Mutable scene read by the painter every frame, plus named design-space
/// points used by the gestures (and by the QA flows).
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based current step; [_stepCount] + 1 once the conclusion was opened.
  int step = 1;

  // ---------------------------------------------------------------- camera
  _V eye = _camEye;
  _V target = _camTarget;
  _CamMove? camMove;
  double frameK = 1;
  double frameDx = 0;
  double frameDy = 0;
  _Cam cam = _Cam(_camEye, _camTarget);

  /// Changes whenever the projection changes (the backdrop is re-recorded).
  int camVersion = 0;

  // ----------------------------------------------------------- thermometer
  final _Thermo th = _Thermo();

  /// The thermometer is being dragged (drawn on top, no glow).
  bool held = false;

  // ------------------------------------------------------------ scenario 1
  double doorAngle = 0;
  double doorStart = -1;
  bool almirahOpen = false;
  bool washed = false;
  bool washing = false;
  bool isReset = false;
  bool waterOn = false;
  bool soapShown = false;
  bool measuring = false;
  bool takenOut = false;
  double measureStart = 0;
  _Mood lambokMood = _Mood.fever;

  /// The soap while it is dragged (design px), else null.
  Offset? soapDrag;

  // ------------------------------------------------------------ scenario 2
  final List<_Mood> moods = List<_Mood>.filled(3, _Mood.neutral);

  /// Recorded readings in table order (null: not measured yet).
  final List<double?> recorded = List<double?>.filled(3, null);

  /// Friend being measured (−1: none, the camera shows the whole room).
  int friend = -1;
  bool cleaning = false;
  bool cleaned = false;
  bool analysed = false;
  bool summaryShown = false;
  double analyseStart = 0;

  // ------------------------------------------------------------- effects
  double flyStart = -10;
  String flyText = '';
  double burstStart = -10;
  _V burstAt = _V.zero;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    eye = _camEye;
    target = _camTarget;
    camMove = null;
    held = false;
    doorAngle = 0;
    doorStart = -1;
    almirahOpen = false;
    washed = false;
    washing = false;
    isReset = false;
    waterOn = false;
    soapShown = false;
    measuring = false;
    takenOut = false;
    lambokMood = _Mood.fever;
    soapDrag = null;
    moods.fillRange(0, moods.length, _Mood.neutral);
    recorded.fillRange(0, recorded.length, null);
    friend = -1;
    cleaning = false;
    cleaned = false;
    analysed = false;
    summaryShown = false;
    flyStart = -10;
    burstStart = -10;
    th
      ..visible = true
      ..tipWet = false
      ..display = ''
      ..spot = index == 0 ? _Spot.shelf : _Spot.table
      ..draggable = index == 1
      ..place(_Pose(index == 0 ? _shelfSpot : _s2Rest));
    th.home = th.pose;
  }

  /// Tweens: door, thermometer and camera.
  void advance(double now) {
    if (doorStart >= 0) {
      final t = ((now - doorStart) / _doorSeconds).clamp(0.0, 1.0);
      doorAngle = _doorOpenAngle * t;
    }
    th.advance(now);
    final move = camMove;
    if (move != null) {
      final t = ((now - move.start) / _zoomSeconds).clamp(0.0, 1.0);
      eye = _V.lerp(move.eyeFrom, move.eyeTo, Curves.easeOutQuad.transform(t));
      target = _V.lerp(move.targetFrom, move.targetTo, t);
      if (t >= 1) camMove = null;
    }
  }

  /// Highlight intensity this frame (0 … [_glowMax]).
  double get pulse =>
      _glowMax * (0.5 - 0.5 * math.cos(2 * math.pi * time / _glowPeriod));

  /// The person whose temperature is being taken.
  _Person get patient =>
      scenario == 0 ? _Person.lambok : _friends[math.max(friend, 0)];

  // ------------------------------------------------- design-space points

  Offset project(double x, double y, double z) => cam.p(_V(x, y, z));
  Offset get thermPoint => cam.p(th.pose.pos);
  Offset get tipPoint => cam.p(th.pose.at(const _V(_tipEndX, 0, 0)));
  Offset get thermEndPoint => cam.p(th.pose.at(const _V(2.25, 0, 0)));
  Offset get resetPoint => cam.p(th.pose.at(_buttonTop));
  Offset get doorPoint => cam.p(const _V(_almX, 6.5, -0.8));
  Offset get sinkPoint => cam.p(_streamPoint);
  Offset get soapPoint => soapDrag ?? tipPoint + _soapOffset * frameK;
  Offset get mouthPoint => cam.p(patient.mouth);
  double get headRadiusPx => patient.headRadius * cam.scaleAt(patient.head);
  Offset friendPoint(int i) => cam.p(_friends[i].chest);
  Offset friendHeadPoint(int i) => cam.p(_friends[i].head);

  // ------------------------------------------------------ state for QA
  String get display => th.display;
  bool get thermAtHome => th.atHome;
  bool get cameraIdle => camMove == null;
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on something the learner can drag ([canGrab]), so other drags still pan /
/// zoom the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

/// True when [p] lies inside the convex quad [a] [b] [c] [d].
bool _inQuad(Offset p, Offset a, Offset b, Offset c, Offset d) {
  double side(Offset u, Offset v) =>
      (v.dx - u.dx) * (p.dy - u.dy) - (v.dy - u.dy) * (p.dx - u.dx);
  final s = [side(a, b), side(b, c), side(c, d), side(d, a)];
  return s.every((v) => v >= 0) || s.every((v) => v <= 0);
}

/// The thermometer's pose with its tip end on [p]'s mouth.
_Pose _mouthPose(_Person p) {
  const turn = _Pose(_V.zero, _mouthRy, _mouthRz);
  return _Pose(
    p.mouth - turn.dir(const _V(_tipEndX, 0, 0)),
    _mouthRy,
    _mouthRz,
  );
}

class _ThermometerLabState
    extends State<Ch7A2ClinicalThermometersAndHumanBodyTemperaturePage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Steps whose card in the sidebar list was opened / closed by hand.
  final Set<int> _toggled = {};

  /// Touch radius and label size in design px for the current stage scale
  /// (set while laying out the stage).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// Free design-x range between the mission card and the tool column while
  /// the sidebar is collapsed (null while it is open).
  (double, double)? _frameRegion;

  // ----------------------------------------------------------------- drag
  _Grab _grab = _Grab.none;
  bool _moved = false;

  /// Scene generation at grab time; a scenario load ends the drag.
  int _gen = 0;
  int _grabGen = -1;

  /// HTML `dragPlane` (normal = camera direction, through the object) and
  /// the grab offset `drag.offset`.
  _V _planeN = _V.up;
  double _planeD = 0;
  _V _grabOffset = _V.zero;
  Offset _soapGrab = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

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

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: tweens, camera, framing, then one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(now);
    _updateCamera(dt);
    _frame.value = now;
  }

  /// Rebuilds the projection: the HTML camera, then the collapsed-sidebar
  /// framing eased towards its target.
  void _updateCamera(double dt) {
    final s = _scene;
    var tk = 1.0, tdx = 0.0, tdy = 0.0;
    final region = _frameRegion;
    if (region != null) {
      final (l, r) = region;
      final (a, b) = _extent(_Cam(s.eye, s.target));
      if (r > l && b > a) {
        if (b - a > r - l) {
          tk = (r - l) / (b - a);
          tdx = l - a * tk;
        } else {
          tdx = (l - a).clamp(0.0, math.max(0.0, r - b));
        }
        tdy = _frameAnchorY * (1 - tk);
      }
    }
    final ease = 1 - math.exp(-_frameRate * dt);
    double follow(double v, double to) =>
        (to - v).abs() < 1e-3 ? to : v + (to - v) * ease;
    final k = follow(s.frameK, tk);
    final dx = follow(s.frameDx, tdx);
    final dy = follow(s.frameDy, tdy);
    final changed =
        k != s.frameK ||
        dx != s.frameDx ||
        dy != s.frameDy ||
        s.cam.eye != s.eye ||
        s.cam.target != s.target;
    s
      ..frameK = k
      ..frameDx = dx
      ..frameDy = dy;
    if (changed) {
      s.cam = _Cam(s.eye, s.target, k: k, dx: dx, dy: dy);
      s.camVersion++;
    }
  }

  /// Unframed design-x extent of what the learner touches in the current
  /// view: the almirah to the thermometer at the sink (S1), the friends'
  /// shoulders (S2), or the friend's head to the thermometer beside them
  /// (S2 close-up).
  (double, double) _extent(_Cam raw) {
    final s = _scene;
    if (s.scenario == 0) {
      return (
        raw.p(const _V(-18.4, _almTop, -1)).dx,
        raw.p(const _V(15.6, 3.5, -0.2)).dx,
      );
    }
    if (s.friend >= 0) {
      final p = _friends[s.friend];
      return (
        raw.p(_V(p.x - 3.2, p.head.y, _personZ)).dx,
        raw.p(_V(p.x + 7.6, p.head.y - 3, 2)).dx,
      );
    }
    return (
      raw.p(const _V(-13.6, 7.5, _personZ)).dx,
      raw.p(const _V(13.6, 7.5, _personZ)).dx,
    );
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)`: clears timers and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _toggled.clear();
      _grab = _Grab.none;
      _moved = false;
      _gen++;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `progressStep()`.
  void _advance(int step) {
    if (!mounted) return;
    setState(() {
      _scene.step = step;
      _toggled.clear();
    });
  }

  bool get _soapActive => _scene.soapShown && !_scene.washing;

  bool get _thermGrabbable {
    final s = _scene;
    final th = s.th;
    return th.visible &&
        th.draggable &&
        !th.moving &&
        !s.measuring &&
        !s.cleaning &&
        (th.spot != _Spot.shelf || s.doorAngle != 0);
  }

  bool get _cleanAvailable {
    final s = _scene;
    return s.scenario == 1 &&
        s.friend >= 0 &&
        !s.cleaned &&
        !s.cleaning &&
        !s.measuring &&
        (s.step == 2 || s.step == 4);
  }

  bool get _conclusionAvailable {
    final s = _scene;
    if (s.step > _stepCount) return true;
    if (s.step != _stepCount) return false;
    return s.scenario == 0 ? s.takenOut : s.summaryShown;
  }

  // -------------------------------------------------------------- hit tests

  bool _onThermometer(Offset at) {
    final s = _scene;
    final th = s.th;
    if (!th.visible || (th.spot == _Spot.shelf && s.doorAngle == 0)) {
      return false;
    }
    final thick = 0.5 * s.cam.scaleAt(th.pose.pos);
    return _segmentDistance(at, s.tipPoint, s.thermEndPoint) <=
        math.max(thick, _touch);
  }

  bool _onResetButton(Offset at) {
    final s = _scene;
    final r = 2 * _buttonRadius * s.cam.scaleAt(s.th.pose.pos);
    return (at - s.resetPoint).distance <= math.max(r, _touch);
  }

  bool _onSoap(Offset at) =>
      (at - _scene.soapPoint).distance <=
      math.max(_soapSize * _scene.frameK / 2, _touch);

  bool _onDoor(Offset at) {
    final cam = _scene.cam;
    return _inQuad(
      at,
      cam.p(const _V(-18, _tableTop, -0.8)),
      cam.p(const _V(-10, _tableTop, -0.8)),
      cam.p(const _V(-10, _almTop, -0.8)),
      cam.p(const _V(-18, _almTop, -0.8)),
    );
  }

  bool get _tipAtMouth =>
      (_scene.tipPoint - _scene.mouthPoint).distance <= _scene.headRadiusPx;

  /// The pending friend the thermometer was dropped on (−1: none). The
  /// thermometer (centre or tip) must reach the friend's head or chest.
  int _friendUnderThermometer() {
    final s = _scene;
    var best = -1;
    var bestD = _friendCatch * s.frameK;
    for (var i = 0; i < _friends.length; i++) {
      if (s.recorded[i] != null) continue;
      final head = s.friendHeadPoint(i), chest = s.friendPoint(i);
      final d = math.min(
        _segmentDistance(s.thermPoint, head, chest),
        _segmentDistance(s.tipPoint, head, chest),
      );
      if (d <= bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  // -------------------------------------------------------------- gestures

  /// HTML `pointerdown` raycast: only the soap and a draggable thermometer
  /// can be held. In step 3 the reset button is tapped, not dragged.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != _Grab.none) return false;
    final s = _scene;
    final at = event.localPosition;
    if (_soapActive && _onSoap(at)) return true;
    if (!_thermGrabbable) return false;
    if (s.scenario == 0 && s.step == 3 && !s.isReset && _onResetButton(at)) {
      return false;
    }
    return _onThermometer(at);
  }

  void _onDown(DragDownDetails d) {
    final s = _scene;
    final at = d.localPosition;
    _moved = false;
    _grabGen = _gen;
    if (_soapActive && _onSoap(at)) {
      _grab = _Grab.soap;
      _soapGrab = s.soapPoint - at;
      return;
    }
    _grab = _Grab.thermometer;
    // HTML: dragPlane.setFromNormalAndCoplanarPoint(camera direction, pos).
    _planeN = s.cam.f;
    _planeD = _planeN.dot(s.th.pose.pos);
    final hit = s.cam.onPlane(at, _planeN, _planeD);
    _grabOffset = hit == null ? _V.zero : hit - s.th.pose.pos;
  }

  void _onDragStart(DragStartDetails _) {
    if (_grabGen != _gen) return;
    _moved = true;
    if (_grab == _Grab.thermometer) _scene.held = true;
  }

  /// HTML `pointermove`: the held object follows the finger.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (_grabGen != _gen) return;
    if (_grab == _Grab.soap) {
      s.soapDrag = d.localPosition + _soapGrab;
    } else if (_grab == _Grab.thermometer) {
      final hit = s.cam.onPlane(d.localPosition, _planeN, _planeD);
      if (hit == null) return;
      final p = s.th.pose;
      s.th.place(_Pose(hit - _grabOffset, p.ry, p.rz));
    }
  }

  void _onDragEnd(DragEndDetails _) => _release(dropped: true);

  /// HTML `pointerup`: checks the drop. A cancelled drag puts the object
  /// back.
  void _release({required bool dropped}) {
    final grab = _grab;
    final moved = _moved;
    _grab = _Grab.none;
    _moved = false;
    final s = _scene;
    s.held = false;
    if (_grabGen != _gen || grab == _Grab.none || !moved) return;
    if (grab == _Grab.soap) {
      if (dropped) {
        _dropSoap();
      } else {
        s.soapDrag = null;
      }
    } else if (dropped) {
      _dropThermometer();
    } else {
      _snapBack();
    }
  }

  /// Taps: the almirah door, the soap, the reset button.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    final at = d.localPosition;
    if (s.scenario != 0) return;
    if (s.step == 1 && !s.almirahOpen && _onDoor(at)) {
      _openDoor();
    } else if (_soapActive && _onSoap(at)) {
      // HTML: a tap (< 10 px) drops the soap straight onto the tip.
      _wash();
    } else if (s.step == 3 && !s.isReset) {
      if (_onResetButton(at)) {
        _resetThermometer();
      } else if (_onThermometer(at)) {
        _lab.showToast(_t('toast_reset_btn'), isError: true);
      }
    }
  }

  // ------------------------------------------------------------- actions

  /// HTML handleObjectClick, step 1: the door swings open.
  void _openDoor() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..almirahOpen = true
        ..doorStart = s.time;
      s.th.draggable = true;
    });
  }

  /// HTML checkDrop for the thermometer.
  void _dropThermometer() {
    final s = _scene;
    final th = s.th;
    if (s.scenario == 0) {
      switch (s.step) {
        case 1 when th.spot == _Spot.shelf:
          if (th.pose.pos.x > _workspaceMinX) {
            final x = th.pose.pos.x.clamp(_landMinX, _landMaxX);
            th
              ..place(_Pose(_V(x, _landY, _landZ)))
              ..spot = _Spot.table;
            th.home = th.pose;
            _advance(2);
            return;
          }
        case 2 when !s.washed && th.spot == _Spot.table:
          if ((s.tipPoint - s.sinkPoint).distance < _sinkCatch * s.frameK) {
            _toSink();
            return;
          }
        case 4:
          if (_tipAtMouth) {
            _startMeasuring();
            return;
          }
        case 6 when !s.takenOut:
          if ((s.tipPoint - s.mouthPoint).distance >
              _outFactor * s.headRadiusPx) {
            _takeOut();
            return;
          }
        case 6:
          // After the reading it can be put down anywhere.
          th
            ..place(_Pose(th.pose.pos))
            ..home = th.pose;
          return;
      }
    } else if (s.friend < 0) {
      if (!s.cleaned && (s.step == 1 || s.step == 4)) {
        final i = _friendUnderThermometer();
        if (i >= 0) {
          _goToFriend(i);
          return;
        }
      }
    } else if (_tipAtMouth) {
      if (s.cleaned) {
        _startMeasuring();
        return;
      }
      // The HTML ignored this drop and left the thermometer where it was.
      _lab.showToast(_t('toast_clean_first'), isError: true);
    }
    _snapBack();
  }

  /// HTML `new TWEEN.Tween(obj.position).to(originalPos, 300)`.
  void _snapBack() {
    final s = _scene;
    s.th.moveTo(s.th.home, s.time, _snapBackSeconds);
  }

  /// Tip under the tap: water on, the soap appears.
  void _toSink() {
    final s = _scene;
    _Sound.splash.play();
    setState(() {
      s.th
        ..place(const _Pose(_atSink))
        ..spot = _Spot.sink
        ..draggable = false;
      s.th.home = s.th.pose;
      s
        ..waterOn = true
        ..soapShown = true
        ..soapDrag = null;
    });
    _lab.showToast(_t('toast_drag_soap'), sound: false);
  }

  /// HTML checkSoapDrop: close enough to the tip washes it; otherwise the
  /// soap goes back and the hint repeats.
  void _dropSoap() {
    final s = _scene;
    final near = (s.soapPoint - s.tipPoint).distance < _soapCatch * s.frameK;
    if (near) {
      _wash();
      return;
    }
    setState(() => s.soapDrag = null);
    _lab.showToast(_t('toast_drag_soap'), sound: false);
  }

  /// Soap on the tip, then (1 s) the second rinse; the thermometer moves to
  /// the table (400 ms) and step 3 begins.
  void _wash() {
    final s = _scene;
    if (!s.soapShown || s.washing) return;
    _Sound.splash.play();
    setState(() {
      s
        ..soapShown = false
        ..soapDrag = null
        ..washing = true;
      s.th.tipWet = true;
      _burst();
    });
    _lab.after(_washRinseDelay, () {
      if (!mounted) return;
      _Sound.splash.play();
      setState(() {
        s.th
          ..tipWet = false
          ..spot = _Spot.table
          ..moveTo(const _Pose(_afterWash), s.time, _washMoveSeconds);
        s.waterOn = false;
        _burst();
      });
      _lab.after(_washMoveTime, () {
        if (!mounted) return;
        s.th
          ..home = const _Pose(_afterWash)
          ..draggable = true;
        s
          ..washed = true
          ..washing = false;
        _advance(3);
      });
    });
  }

  /// Water droplets at the tip (HTML canvas-confetti).
  void _burst() {
    final s = _scene;
    s
      ..burstStart = s.time
      ..burstAt = s.th.pose.at(const _V(_tipEndX, 0, 0));
  }

  /// HTML handleObjectClick, step 3.
  void _resetThermometer() {
    _Sound.click.play();
    setState(() {
      _scene.th.display = '00.0';
      _scene.isReset = true;
    });
    _advance(4);
  }

  /// HTML snapToMouth + startMeasurementS1 / S2: progress bar for 3 s,
  /// then the beep and the reading.
  void _startMeasuring() {
    final s = _scene;
    final p = s.patient;
    s.th
      ..draggable = false
      ..spot = _Spot.mouth
      ..moveTo(_mouthPose(p), s.time, _mouthSnapSeconds);
    s
      ..measuring = true
      ..measureStart = s.time;
    _setMood(_Mood.open);
    if (s.scenario == 0) {
      _advance(5);
    } else if (s.step == 2) {
      _advance(3);
    } else {
      setState(() {});
    }
    _lab.after(_measureTime, _measureDone);
  }

  void _setMood(_Mood mood) {
    final s = _scene;
    if (s.scenario == 0) {
      s.lambokMood = mood;
    } else if (s.friend >= 0) {
      s.moods[s.friend] = mood;
    }
  }

  void _measureDone() {
    if (!mounted) return;
    final s = _scene;
    final p = s.patient;
    _Sound.beep.play();
    s
      ..measuring = false
      ..th.display = p.reading.toStringAsFixed(1);
    _setMood(_Mood.happy);
    if (s.scenario == 0) {
      s.th
        ..draggable = true
        ..home = _mouthPose(p);
      _advance(6);
      return;
    }
    final friend = s.friend;
    setState(() {
      s
        ..flyStart = s.time
        ..flyText = s.th.display;
    });
    _lab.after(_flyTime, () => _record(friend));
  }

  /// HTML animateValueToTable: the reading lands in the friend's row, the
  /// thermometer goes back to the table and the camera to the room.
  void _record(int friend) {
    if (!mounted || friend < 0) return;
    final s = _scene;
    s.recorded[friend] = _friends[friend].reading;
    s.th
      ..place(const _Pose(_s2Rest))
      ..spot = _Spot.table
      ..draggable = true;
    s.th.home = s.th.pose;
    s
      ..friend = -1
      ..cleaned = false
      ..camMove = null
      ..eye = _camEye
      ..target = _camTarget;
    final n = s.recorded.where((v) => v != null).length;
    if (n == 1) {
      _advance(4);
    } else if (n == _friends.length) {
      s.th.visible = false;
      _advance(5);
    } else {
      setState(() {});
    }
  }

  /// Scenario 1, step 6: the thermometer is out of the mouth and lies flat,
  /// so its display can be read.
  void _takeOut() {
    final s = _scene;
    setState(() {
      s.takenOut = true;
      s.th
        ..place(_Pose(s.th.pose.pos))
        ..spot = _Spot.table;
      s.th.home = s.th.pose;
    });
  }

  /// Scenario 2: the thermometer is taken to friend [i]; the camera glides
  /// to them and the display shows '---'.
  void _goToFriend(int i) {
    final s = _scene;
    final p = _friends[i];
    _Sound.click.play();
    s
      ..friend = i
      ..camMove = _CamMove(
        s.eye,
        _V(p.x, p.head.y + _zoomEyeLift, _zoomEyeZ),
        s.target,
        _V(p.x, p.head.y - _zoomTargetDrop, 0),
        s.time,
      );
    s.th
      ..place(_Pose(_V(p.x + 5, p.head.y - 3, 2)))
      ..display = '---';
    s.th.home = s.th.pose;
    if (s.step == 1) {
      _advance(2);
    } else {
      setState(() {});
    }
  }

  /// HTML cleanAndResetS2: the tip is washed (800 ms), then reset to 00.0.
  void _cleanAndReset() {
    if (!_cleanAvailable) return;
    final s = _scene;
    _Sound.splash.play();
    setState(() {
      s.cleaning = true;
      s.th.tipWet = true;
      _burst();
    });
    _lab.after(_cleanTime, () {
      if (!mounted) return;
      _Sound.click.play();
      setState(() {
        s.th
          ..tipWet = false
          ..display = '00.0';
        s
          ..cleaned = true
          ..cleaning = false;
      });
    });
  }

  /// HTML analyseData: the three readings pop onto the number line 400 ms
  /// apart; 800 ms after the last one the summary shows and step 6 begins.
  /// (The HTML could be pressed again and moved the step past the end.)
  void _analyse() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 5 || s.analysed) return;
    setState(() {
      s
        ..analysed = true
        ..analyseStart = s.time;
    });
    _lab.after(_dotGap, _Sound.click.play);
    _lab.after(_dotGap * 2, _Sound.click.play);
    _lab.after(_summaryDelay, () {
      if (!mounted) return;
      s.summaryShown = true;
      _advance(6);
    });
  }

  /// HTML triggerConclusion ('Observe Conclusion'); it also re-opens the
  /// summary later.
  void _conclude() {
    if (!_conclusionAvailable) return;
    final s = _scene;
    final sc = s.scenario;
    if (s.step <= _stepCount) _advance(_stepCount + 1);
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: _conclusionDelay,
      title: () =>
          sc == 0 ? labFormat(_t('sc_complete'), {'n': 1}) : _t('all_complete'),
      heading: () => _t(sc == 0 ? 'sum_s1_title' : 'sum_s2_title'),
      body: () => sc == 0
          ? _t('sum_s1_desc')
          : '${_t('sum_s2_desc')}\n\n${_t('all_complete_desc')}',
      extra: sc == 1
          ? () => _RecordsTable(
              rows: _rows(),
              t: _t,
              fontScale: _lab.fontScale.clamp(0.9, 1.4),
            )
          : null,
    );
  }

  /// Table rows: friend name and reading (null until measured).
  List<(String, double?)> _rows() => [
    for (var i = 0; i < _friends.length; i++)
      (_t(_friends[i].nameKey), _scene.recorded[i]),
  ];

  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (_cleanAvailable)
        LabAction(
          label: _t('clean_reset'),
          icon: Icons.auto_awesome,
          color: _Colors.emerald700,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _cleanAndReset,
        ),
      if (s.scenario == 1 && s.step == 5 && !s.analysed)
        LabAction(
          label: _t('analyse'),
          icon: Icons.insights,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          highlight: true,
          sound: _Sound.click,
          onTap: _analyse,
        ),
      if (_conclusionAvailable)
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: s.step <= _stepCount,
          silent: true,
          onTap: _conclude,
        ),
    ];
  }

  void _toggleStep(int i) => setState(() {
    if (!_toggled.remove(i)) _toggled.add(i);
  });

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = _scene;
        final sc = s.scenario;
        final data = _data;
        final scale = context.labScale;
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          hud: _t('s${sc + 1}_hud_${s.step.clamp(1, _stepCount)}'),
          // The last task line no longer applies once the conclusion opens.
          showHud: s.step <= _stepCount,
          actions: _actions(),
          sidebarExtraTitle: _t(sc == 1 ? 'temp_records' : 'concept_exp'),
          sidebarExtra: _Notebook(
            steps: data.steps,
            currentStep: s.step,
            toggled: Set.of(_toggled),
            onToggle: _toggleStep,
            t: _t,
            fontScale: _lab.fontScale,
            records: sc == 1 ? _rows() : null,
          ),
          overlays: _overlays(context, scale),
          // HTML enterLab() and resetApp() both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          stage: _stage(),
        );
      },
    );
  }

  /// Canvas cards. While the sidebar is open, the lab's buttons also sit at
  /// the top left of the canvas, like the HTML's canvas buttons (in the
  /// sidebar they are below the fold on a phone). Scenario 2: the number
  /// line once the data is analysed (above the HUD while the sidebar is
  /// open) and, while the sidebar is collapsed, the readings strip at the
  /// bottom (the sidebar has the table otherwise).
  List<Widget> _overlays(BuildContext context, double scale) {
    final s = _scene;
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final p = _lab.palette;
    final actions = _actions();
    return [
      if (open && actions.isNotEmpty && _lab.popup == null)
        Positioned(
          key: const ValueKey('ch7a2-actions'),
          left: inset.left,
          top: inset.top,
          child: _ActionCard(actions: actions, palette: p, scale: scale),
        ),
      if (s.scenario == 1 && s.analysed)
        Positioned(
          key: const ValueKey('ch7a2-graph'),
          left: inset.left,
          right: inset.right,
          top: inset.top + _toastClear * scale,
          bottom: inset.bottom + (open ? _hudClear * scale : 0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: math.min(_graphWidth * scale, box.maxWidth),
                  child: _GraphCard(
                    scene: s,
                    cache: _cache,
                    frame: _frame,
                    palette: p,
                    scale: scale,
                    t: _t,
                    rows: _rows(),
                  ),
                ),
              ),
            ),
          ),
        )
      else if (s.scenario == 1 && !open)
        Positioned(
          key: const ValueKey('ch7a2-records'),
          left: inset.left,
          right: inset.right,
          bottom: inset.bottom,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _RecordsStrip(
                rows: _rows(),
                t: _t,
                palette: p,
                scale: scale,
              ),
            ),
          ),
        ),
    ];
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final inset = labOverlayInsets(context, _lab);
          _labelRight = (box.maxWidth - inset.right - stageLeft) / fit;
          _frameRegion = _lab.isSidebarOpen
              ? null
              : (
                  (inset.left - stageLeft) / fit + _frameGap,
                  _labelRight - _frameGap,
                );
        }
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags and taps on the scene are not screen-reader actions; the
            // scene is announced by its label instead.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              // The tap recognizer joins first, so a touch that does not
              // move is a tap (the HTML soap: < 10 px is a tap).
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
                  ),
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
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
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = () => _release(dropped: false),
                  ),
            },
            child: Semantics(
              image: true,
              label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: _design,
                  painter: _ScenePainter(
                    scene: _scene,
                    cache: _cache,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    labelSize: _labelSize,
                    labelRight: _labelRight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------ canvas cards

/// The HTML's canvas buttons ('Clean & Reset', 'Analyse Data', 'Observe
/// Conclusion') in a small card at the top left of the canvas.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.actions,
    required this.palette,
    required this.scale,
  });

  final List<LabAction> actions;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200 * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.all(6 * s),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) SizedBox(height: 6 * s),
                LabActionButton(action: actions[i], scale: s, dense: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ sidebar extra

/// Sidebar extra: the data table (Scenario 2) and the HTML teacher-board
/// step list (concept, action and, once the step is done, its result).
class _Notebook extends StatelessWidget {
  const _Notebook({
    required this.steps,
    required this.currentStep,
    required this.toggled,
    required this.onToggle,
    required this.t,
    required this.fontScale,
    this.records,
  });

  final List<LabStep> steps;
  final int currentStep;
  final Set<int> toggled;
  final ValueChanged<int> onToggle;
  final String Function(String key) t;
  final double fontScale;
  final List<(String, double?)>? records;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    final rows = records;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rows != null) ...[
          _RecordsTable(rows: rows, t: t, fontScale: fontScale),
          SizedBox(height: 14 * s),
          LabSectionLabel(
            t('concept_exp'),
            size: 10.5 * s,
            icon: Icons.format_list_numbered,
          ),
          SizedBox(height: 8 * s),
        ],
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 6 * s),
          _stepCard(p, s, f, i),
        ],
      ],
    );
  }

  /// One card: past steps green with a check, the current one open, future
  /// ones dimmed and closed (HTML `updateTeacherBoard`).
  Widget _stepCard(LabPalette p, double s, double f, int i) {
    final past = i < currentStep;
    final current = i == currentStep;
    final future = i > currentStep;
    final open = !future && (current != toggled.contains(i));
    final tint = current ? p.accentInk : (past ? p.info : p.textMuted);
    final step = steps[i - 1];
    TextStyle body(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    TextStyle head(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.4,
    );
    return Container(
      decoration: BoxDecoration(
        color: future ? p.card.withValues(alpha: p.card.a * 0.5) : p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? p.accent
              : (past ? p.info.withValues(alpha: 0.5) : p.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: future ? null : () => onToggle(i),
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
                                  ? p.info.withValues(alpha: 0.2)
                                  : p.cardBorder.withValues(alpha: 0.5)),
                        border: Border.all(color: current ? p.accent : tint),
                      ),
                      child: past
                          ? Icon(Icons.check, size: 13 * s, color: p.info)
                          : Text(
                              '$i',
                              style: TextStyle(
                                color: current ? p.onAccent : p.textMuted,
                                fontSize: 10.5 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        '${t('exploration')} $i',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tint,
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
                      color: p.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: EdgeInsets.fromLTRB(10 * s, 0, 10 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${t('concept_focus')}: ',
                          style: head(p.accentInk),
                        ),
                        TextSpan(text: step.concept),
                      ],
                    ),
                    style: body(p.text),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${t('action')}: ',
                          style: head(p.textStrong),
                        ),
                        TextSpan(text: step.action),
                      ],
                    ),
                    style: body(p.text),
                  ),
                  SizedBox(height: 6 * s),
                  // The result is shown once it has been observed (the HTML
                  // showed it before the learner acted).
                  if (past)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${t('observation')}: ',
                            style: head(p.textStrong),
                          ),
                          TextSpan(text: step.observation),
                        ],
                      ),
                      style: body(p.textMuted),
                    )
                  else
                    Text(
                      t('obs_pending'),
                      style: body(
                        p.textMuted,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#ui-data-table`: Name | Temp (°C), one row per friend; a reading
/// appears once it has been measured.
class _RecordsTable extends StatelessWidget {
  const _RecordsTable({
    required this.rows,
    required this.t,
    required this.fontScale,
  });

  final List<(String, double?)> rows;
  final String Function(String key) t;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.3,
    );
    TextStyle body(Color color, FontWeight weight) =>
        TextStyle(color: color, fontSize: 12 * f, fontWeight: weight);
    Widget row(Widget a, Widget b, {Color? fill, bool divider = true}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 7 * s),
        decoration: BoxDecoration(
          color: fill,
          border: divider ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: a),
            SizedBox(width: 6 * s),
            Expanded(flex: 2, child: b),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Text(
              t('name'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: head,
            ),
            Text(
              t('temp_c'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: head,
            ),
            fill: p.cardBorder.withValues(alpha: 0.3),
            divider: false,
          ),
          for (final (name, value) in rows)
            row(
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body(p.text, FontWeight.w600),
              ),
              Text(
                value == null ? t('tbl_pending') : value.toStringAsFixed(1),
                maxLines: 1,
                textAlign: TextAlign.end,
                style: value == null
                    ? body(p.textMuted, FontWeight.w500)
                    : body(p.accentInk, FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

/// The readings on the canvas while the sidebar is collapsed: one cell per
/// friend, name over reading.
class _RecordsStrip extends StatelessWidget {
  const _RecordsStrip({
    required this.rows,
    required this.t,
    required this.palette,
    required this.scale,
  });

  final List<(String, double?)> rows;
  final String Function(String key) t;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      borderColor: p.accent.withValues(alpha: 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment, size: 16 * s, color: p.accentInk),
          for (final (name, value) in rows) ...[
            SizedBox(width: 12 * s),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value == null
                      ? t('tbl_pending')
                      : '${value.toStringAsFixed(1)} ${t('unit_c')}',
                  style: TextStyle(
                    color: value == null ? p.textMuted : p.accentInk,
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// HTML `#ui-graph-container`: the readings as dots on a 35–42 °C number
/// line with the normal band, a legend and (after the dots) the summary.
class _GraphCard extends StatelessWidget {
  const _GraphCard({
    required this.scene,
    required this.cache,
    required this.frame,
    required this.palette,
    required this.scale,
    required this.t,
    required this.rows,
  });

  final _Scene scene;
  final _PaintCache cache;
  final ValueListenable<double> frame;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;
  final List<(String, double?)> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(12 * s),
      borderColor: p.accent.withValues(alpha: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('graph_title'),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 13.5 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            height: 58 * s,
            child: CustomPaint(
              painter: _NumberLinePainter(
                scene: scene,
                cache: cache,
                palette: p,
                scale: s,
                normalLabel: t('normal_range'),
                repaint: frame,
              ),
            ),
          ),
          SizedBox(height: 4 * s),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12 * s,
            runSpacing: 2 * s,
            children: [
              for (final (name, value) in rows)
                Text(
                  value == null
                      ? name
                      : '$name ${value.toStringAsFixed(1)} ${t('unit_c')}',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (scene.summaryShown) ...[
            SizedBox(height: 8 * s),
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.cardBorder),
              ),
              child: Text(
                t('graph_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 11.5 * s,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The number line itself: ticks 35 … 42, the 36.5–37.5 °C band labelled
/// "Normal Range" and the dots, each popping in (HTML `.dot-plot`,
/// cubic-bezier(0.34, 1.56, 0.64, 1) over 0.4 s, 400 ms apart).
class _NumberLinePainter extends CustomPainter {
  _NumberLinePainter({
    required this.scene,
    required this.cache,
    required this.palette,
    required this.scale,
    required this.normalLabel,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final LabPalette palette;
  final double scale;
  final String normalLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final pens = cache.pens;
    final pad = 12 * s;
    double x(double v) =>
        pad + (v - _lineMin) / (_lineMax - _lineMin) * (size.width - 2 * pad);
    final lineY = 30 * s;

    // Normal band (emerald-400 / 40 % with an emerald-500 / 50 % border).
    final band = Rect.fromLTRB(
      x(_bandMin),
      lineY - 10 * s,
      x(_bandMax),
      lineY + 10 * s,
    );
    canvas.drawRect(
      band,
      pens.fill..color = _Colors.emerald400.withValues(alpha: 0.4),
    );
    canvas.drawRect(
      band,
      pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.emerald500.withValues(alpha: 0.5),
    );
    final label = cache.text(
      normalLabel,
      10.5 * s,
      palette.ink(_Colors.emerald500),
      weight: FontWeight.w800,
    );
    label.paint(
      canvas,
      Offset(band.center.dx - label.width / 2, band.top - label.height - 1),
    );

    // The line (h-1.5, slate-300 / slate-600) and the ticks.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(pad, lineY - 3 * s, size.width - pad, lineY + 3 * s),
        Radius.circular(3 * s),
      ),
      pens.fill..color = palette.isDark ? _Colors.slate600 : _Colors.slate300,
    );
    final tick = pens.thin
      ..strokeWidth = 1
      ..color = palette.isDark ? _Colors.slate500 : _Colors.slate400;
    for (var v = _lineMin; v <= _lineMax; v++) {
      final tx = x(v);
      canvas.drawLine(
        Offset(tx, lineY - 6 * s),
        Offset(tx, lineY + 6 * s),
        tick,
      );
      final n = cache.text('${v.round()}', 10 * s, palette.textMuted);
      n.paint(canvas, Offset(tx - n.width / 2, lineY + 8 * s));
    }

    // The dots (blue-500, white border), one every 400 ms.
    final e = scene.time - scene.analyseStart;
    for (var i = 0; i < scene.recorded.length; i++) {
      final v = scene.recorded[i];
      if (v == null) continue;
      final t = ((e - i * _dotGapSeconds) / _dotPopSeconds).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final r = 7 * s * Curves.easeOutBack.transform(t);
      final c = Offset(x(v), lineY);
      canvas.drawCircle(
        c,
        r + 3 * s,
        pens.fill..color = _Colors.blue500.withValues(alpha: 0.35),
      );
      canvas.drawCircle(c, r, pens.fill..color = _Colors.blue500);
      canvas.drawCircle(
        c,
        r,
        pens.stroke
          ..strokeWidth = 2 * s
          ..color = _Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NumberLinePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.palette != palette ||
      old.scale != scale ||
      old.normalLabel != normalLabel;
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Thick butt-ended lines (rods, cylinder shading bands).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// Thin round-ended lines (ticks, rims, face strokes, streaks).
  final Paint thin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();
  final Path clip = Path();
}

/// What the painters make once and reuse: pens, the static backdrop (scene
/// background and table), text painters, the fever flush and the soap
/// dispenser's paths. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _texts = {};

  /// Label chips drawn in the current frame (to keep them apart).
  final List<Rect> labelRects = [];
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  bool _backdropDark = true;
  int _backdropVersion = -1;
  Paint? _fever;
  Offset _feverAt = Offset.zero;
  double _feverRadius = 0;

  /// The HTML soap SVG (viewBox 64 × 64).
  final Path soapBody = Path()
    ..moveTo(16, 28)
    ..cubicTo(16, 22, 48, 22, 48, 28)
    ..lineTo(48, 56)
    ..cubicTo(48, 60, 16, 60, 16, 56)
    ..close();
  final Path soapBand = Path()
    ..moveTo(16, 28)
    ..cubicTo(16, 22, 48, 22, 48, 28)
    ..lineTo(48, 40)
    ..cubicTo(48, 44, 16, 44, 16, 40)
    ..close();
  final Path soapPump = Path()
    ..moveTo(22, 16)
    ..lineTo(42, 16)
    ..lineTo(42, 12)
    ..cubicTo(42, 8, 22, 8, 22, 12)
    ..close();
  final Path soapSpout = Path()
    ..moveTo(18, 14)
    ..cubicTo(12, 14, 12, 18, 18, 18)
    ..close();

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeTexts();
    _lang = lang;
    _labelSize = labelSize;
  }

  /// Scene label (HTML text sprite): white bold text.
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Any other canvas text (pills, readouts, the number line).
  TextPainter text(
    String text,
    double size,
    Color color, {
    FontWeight weight = FontWeight.w700,
  }) {
    final key = '$text|$size|${color.toARGB32()}|${weight.value}';
    return _texts[key] ??= TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// The static part of the scene (background and table) for the current
  /// projection, recorded once per camera change.
  ui.Picture backdrop(_Scene s, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        dark == _backdropDark &&
        s.camVersion == _backdropVersion) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      labBleed(size),
      pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    // `BoxGeometry(40, 2, 12)` table at y = −1, 0x475569.
    _Gfx(
      canvas,
      s.cam,
      pens,
    ).box(const _V(0, -1, 0), const _V(40, 2, 12), _Colors.table, edge: 0.5);
    _backdropDark = dark;
    _backdropVersion = s.camVersion;
    return _backdrop = recorder.endRecording();
  }

  /// createFaceTexture('fever'): red radial flush, made again only when the
  /// head moves on screen.
  Paint fever(Offset at, double radius, double inner) {
    final cached = _fever;
    if (cached != null &&
        (at - _feverAt).distance < 0.5 &&
        (radius - _feverRadius).abs() < 0.5) {
      return cached;
    }
    _feverAt = at;
    _feverRadius = radius;
    return _fever = Paint()
      ..shader = ui.Gradient.radial(
        at,
        radius,
        [_Colors.feverFlush, _Colors.feverFlush.withValues(alpha: 0)],
        [inner, 1],
      );
  }

  void _disposeTexts() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    for (final tp in _texts.values) {
      tp.dispose();
    }
    _labels.clear();
    _texts.clear();
  }

  void dispose() {
    _disposeTexts();
    _backdrop?.dispose();
    _backdrop = null;
  }
}

/// One face of a unit box: outward normal and corners (signs of x, y, z).
@immutable
class _Face {
  const _Face(this.normal, this.corners);

  final _V normal;
  final List<_V> corners;
}

const List<_Face> _boxFaces = [
  _Face(_V(1, 0, 0), [_V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1), _V(1, -1, 1)]),
  _Face(_V(-1, 0, 0), [
    _V(-1, -1, -1),
    _V(-1, -1, 1),
    _V(-1, 1, 1),
    _V(-1, 1, -1),
  ]),
  _Face(_V(0, 1, 0), [_V(-1, 1, -1), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1)]),
  _Face(_V(0, -1, 0), [
    _V(-1, -1, -1),
    _V(1, -1, -1),
    _V(1, -1, 1),
    _V(-1, -1, 1),
  ]),
  _Face(_V(0, 0, 1), [_V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)]),
  _Face(_V(0, 0, -1), [
    _V(-1, -1, -1),
    _V(-1, 1, -1),
    _V(1, 1, -1),
    _V(1, -1, -1),
  ]),
];

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

/// Droplet directions of a burst (design px / s, before the gravity pull).
const List<Offset> _burstVelocity = [
  Offset(-120, -150),
  Offset(-60, -190),
  Offset(0, -210),
  Offset(70, -180),
  Offset(130, -140),
  Offset(-160, -80),
  Offset(160, -90),
  Offset(-90, -120),
  Offset(95, -110),
  Offset(-30, -240),
  Offset(35, -150),
  Offset(-140, -200),
  Offset(145, -205),
  Offset(10, -110),
];
const double _burstGravity = 520;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  /// Yellow highlight (HTML emissive 0xeab308) mixed into what is drawn
  /// while it is set.
  double glow = 0;

  /// Emissive light adds to the colour (clamped), as in Three.js.
  Color tint(Color c) => glow <= 0
      ? c
      : Color.from(
          alpha: c.a,
          red: math.min(1.0, c.r + _Colors.glow.r * glow),
          green: math.min(1.0, c.g + _Colors.glow.g * glow),
          blue: math.min(1.0, c.b + _Colors.glow.b * glow),
        );

  Color shade(Color c, _V n, {double opacity = 1}) =>
      tint(_lit(c, n, opacity: opacity));

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat quad in an already computed [color]; optional rim [edge].
  void quad(_V a, _V b, _V c, _V d, Color color, {Color? edge}) {
    final path = pens.path..reset();
    _to(path, 0, cam.p(a));
    _to(path, 1, cam.p(b));
    _to(path, 2, cam.p(c));
    _to(path, 3, cam.p(d));
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 1
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3}) =>
      obox(c, size * 0.5, const _Pose(_V.zero), color, edge: edge);

  /// A box of half sizes [half] centred at [c], turned like [turn].
  void obox(_V c, _V half, _Pose turn, Color color, {double edge = 0.3}) {
    for (final face in _boxFaces) {
      final n = turn.dir(face.normal);
      final mid =
          c +
          turn.dir(
            _V(
              face.normal.x * half.x,
              face.normal.y * half.y,
              face.normal.z * half.z,
            ),
          );
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(
          path,
          i,
          cam.p(c + turn.dir(_V(k.x * half.x, k.y * half.y, k.z * half.z))),
        );
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = shade(color, n));
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge),
        );
      }
    }
  }

  /// Round rod (CylinderGeometry along [a]–[b]): body, shaded side and
  /// highlight.
  void rod(_V a, _V b, double radius, Color color, {double opacity = 1}) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    final len = d.distance;
    final w = math.max(1.5, 2 * radius * cam.scaleAt((a + b) * 0.5));
    if (len < 0.5) {
      canvas.drawCircle(
        pa,
        w / 2,
        pens.fill..color = tint(color).withValues(alpha: opacity),
      );
      return;
    }
    var n = Offset(-d.dy / len, d.dx / len);
    if (n.dy > 0) n = -n; // towards the top of the screen (lit side)
    canvas.drawLine(
      pa,
      pb,
      pens.bar
        ..strokeWidth = w
        ..color = tint(color).withValues(alpha: opacity),
    );
    canvas.drawLine(
      pa - n * (w * 0.32),
      pb - n * (w * 0.32),
      pens.bar
        ..strokeWidth = w * 0.36
        ..color = tint(labShade(color, -0.3)).withValues(alpha: opacity),
    );
    canvas.drawLine(
      pa + n * (w * 0.26),
      pb + n * (w * 0.26),
      pens.bar
        ..strokeWidth = w * 0.22
        ..color = tint(labShade(color, 0.4)).withValues(alpha: opacity),
    );
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double _ellipseHalf(_V c, double radius) =>
      (cam.p(c + _V(0, 0, radius)).dy - cam.p(c - _V(0, 0, radius)).dy).abs() /
      2;

  /// Upright CylinderGeometry standing on [bottom]: side with shading bands
  /// and the top cap.
  void vCylinder(_V bottom, double radius, double height, Color color) {
    final top = bottom + _V(0, height, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = radius * cam.scaleAt(bottom), wt = radius * cam.scaleAt(top);
    final bottomOval = Rect.fromCenter(
      center: pb,
      width: 2 * wb,
      height: 2 * _ellipseHalf(bottom, radius),
    );
    final topOval = Rect.fromCenter(
      center: pt,
      width: 2 * wt,
      height: 2 * _ellipseHalf(top, radius),
    );
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    canvas.drawPath(path, pens.fill..color = tint(color));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx - wt * 0.45, pt.dy),
      Offset(pb.dx - wb * 0.45, bottomOval.bottom),
      pens.bar
        ..strokeWidth = wb * 0.32
        ..color = tint(labShade(color, 0.22)),
    );
    canvas.drawLine(
      Offset(pt.dx + wt * 0.78, pt.dy),
      Offset(pb.dx + wb * 0.78, bottomOval.bottom),
      pens.bar
        ..strokeWidth = wb * 0.4
        ..color = tint(labShade(color, -0.35)),
    );
    canvas.restore();
    canvas.drawOval(topOval, pens.fill..color = tint(labShade(color, 0.15)));
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = tint(labShade(color, -0.35)),
    );
  }

  /// SphereGeometry: a darker crescent away from the light and a soft
  /// highlight (no gradient shader per frame).
  void ball(_V c, double radius, Color color) {
    final o = cam.p(c);
    final r = radius * cam.scaleAt(c);
    canvas.drawCircle(o, r, pens.fill..color = tint(labShade(color, -0.28)));
    canvas.drawCircle(
      o + Offset(-0.1 * r, -0.1 * r),
      0.86 * r,
      pens.fill..color = tint(color),
    );
    canvas.drawCircle(
      o + Offset(-0.35 * r, -0.4 * r),
      0.22 * r,
      pens.fill..color = _Colors.white.withValues(alpha: 0.3),
    );
  }

  /// A flat disc of [radius] at [c] spanned by the unit axes [a] and [b].
  void disc(_V c, _V a, _V b, double radius, Color color, {int sides = 14}) {
    final path = pens.path..reset();
    for (var i = 0; i < sides; i++) {
      final t = i * 2 * math.pi / sides;
      _to(
        path,
        i,
        cam.p(c + a * (math.cos(t) * radius) + b * (math.sin(t) * radius)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = tint(color));
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.45),
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the room with
/// the almirah, Lambok and the sink; S2 the three friends. The static part
/// comes from [_PaintCache].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Design x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  /// Canvas cards and pills grow with the labels on small stages.
  double get _ui => labelSize / _labelPx;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(s, isDark, size));
    final g = _Gfx(canvas, s.cam, _pens);
    final glow = s.pulse;
    if (s.scenario == 0) {
      _paintRoom(g, glow);
    } else {
      _paintFriends(g, glow);
    }
    if (showLabels) _paintLabels(canvas);
    _paintEffects(canvas);
  }

  /// HTML updateHighlights() for the thermometer.
  double _thermGlow(double glow) {
    final s = scene;
    if (s.held || s.th.moving) return 0;
    if (s.scenario == 0) {
      final on =
          (s.step == 1 && s.almirahOpen) ||
          (s.step == 3 && !s.isReset) ||
          (s.step == 6 && !s.takenOut);
      return on ? glow : 0;
    }
    final pick = (s.step == 1 || s.step == 4) && s.friend < 0 && !s.cleaned;
    final place = (s.step == 2 || s.step == 4) && s.cleaned && !s.measuring;
    return pick || place ? glow : 0;
  }

  // ---------------------------------------------------------- scenario 1

  void _paintRoom(_Gfx g, double glow) {
    final s = scene;
    final th = s.th;
    _paintAlmirah(g, s.step == 1 && !s.almirahOpen ? glow : 0, glow);
    _paintPerson(
      g,
      _Person.lambok,
      s.lambokMood,
      s.step == 4 && !s.measuring && !s.held ? glow : 0,
    );
    if (s.step == 4 && !s.measuring) _paintTarget(g, glow);
    _paintSink(g, s.step == 2 && !s.washed ? glow : 0);
    if (th.visible && th.spot == _Spot.sink) _paintThermo(g, 0);
    if (s.waterOn) _paintStream(g);
    final onShelf = th.spot == _Spot.shelf && !s.held;
    if (th.visible && th.spot != _Spot.sink && !onShelf) {
      _paintThermo(g, _thermGlow(glow));
    }
  }

  /// The almirah: frame, the dark inside and shelf once the door opens, the
  /// thermometer on the shelf, then the door on its hinge.
  void _paintAlmirah(_Gfx g, double doorGlow, double glow) {
    final s = scene;
    // Frame BoxGeometry(8, 15, 6), 0xd97706, from the table top up.
    g.box(
      const _V(_almX, (_tableTop + _almTop) / 2, _almZ),
      const _V(8, _almTop - _tableTop, 6),
      _Colors.almirahFrame,
      edge: 0.45,
    );
    if (s.doorAngle != 0) {
      // Inside (0x78350f) and the shelf's front edge at y = 4.5.
      const front = _V(0, 0, 1);
      g.quad(
        const _V(-17.75, _tableTop, -0.99),
        const _V(-10.25, _tableTop, -0.99),
        const _V(-10.25, 12.75, -0.99),
        const _V(-17.75, 12.75, -0.99),
        g.shade(_Colors.almirahInside, front),
      );
      g.quad(
        const _V(-17.75, 4.4, -0.98),
        const _V(-10.25, 4.4, -0.98),
        const _V(-10.25, 4.6, -0.98),
        const _V(-17.75, 4.6, -0.98),
        g.shade(_Colors.almirahFrame, _V.up),
      );
      if (s.th.spot == _Spot.shelf && !s.held) {
        _paintThermo(g, _thermGlow(glow));
      }
    }
    // Door: BoxGeometry(8, 15, 0.4) (visible part 13 high) centred 4 left
    // of the hinge, with the handle near its free edge.
    final turn = _Pose(_V.zero, s.doorAngle);
    g.glow = doorGlow;
    g.obox(
      _doorHinge + turn.dir(const _V(-4, 1, 0)),
      const _V(4, 6.5, 0.2),
      turn,
      _Colors.almirahDoor,
      edge: 0.5,
    );
    g.rod(
      _doorHinge + turn.dir(const _V(-7, -0.75, 0.4)),
      _doorHinge + turn.dir(const _V(-7, 0.75, 0.4)),
      0.12,
      _Colors.handle,
    );
    g.glow = 0;
  }

  /// The sink: white basin with its grey bowl and the dark faucet.
  void _paintSink(_Gfx g, double glow) {
    g.glow = glow;
    g.box(
      const _V(_sinkX, 1.25, 0),
      const _V(10, 2.5, 7),
      _Colors.basin,
      edge: 0.25,
    );
    g.quad(
      const _V(_sinkX - 4.5, 2.51, -3),
      const _V(_sinkX + 4.5, 2.51, -3),
      const _V(_sinkX + 4.5, 2.51, 3),
      const _V(_sinkX - 4.5, 2.51, 3),
      g.shade(_Colors.basinBowl, _V.up),
    );
    g.disc(
      const _V(_sinkX, 2.52, 0.6),
      const _V(1, 0, 0),
      const _V(0, 0, 1),
      0.35,
      _Colors.slate600,
    );
    g.vCylinder(const _V(_sinkX, 2.5, -2.5), 0.3, 1, _Colors.tapMetal);
    g.rod(
      const _V(_sinkX, 3.4, -2.5),
      const _V(_sinkX, 5.5, -2.5),
      0.2,
      _Colors.tapMetal,
    );
    g.rod(
      const _V(_sinkX, 5.4, -2.6),
      const _V(_sinkX, 5.4, -0.1),
      0.2,
      _Colors.tapMetal,
    );
    g.rod(
      const _V(_sinkX, 5.4, -0.2),
      const _V(_sinkX, 4.6, -0.2),
      0.2,
      _Colors.tapMetal,
    );
    g.glow = 0;
  }

  /// Running water (CylinderGeometry(0.08, 0.12, 3.8), 0x93c5fd at 60 %)
  /// with streaks flowing down.
  void _paintStream(_Gfx g) {
    g.rod(
      const _V(_sinkX, 4.6, -0.2),
      const _V(_sinkX, 1.3, -0.2),
      0.14,
      _Colors.water,
      opacity: 0.6,
    );
    final streak = _pens.thin
      ..strokeWidth = 1.4
      ..color = _Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 4; i++) {
      final y = 4.5 - ((scene.time * 5 + i * 0.85) % 3.2);
      g.canvas.drawLine(
        g.cam.p(_V(_sinkX, y, -0.05)),
        g.cam.p(_V(_sinkX, y - 0.35, -0.05)),
        streak,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintFriends(_Gfx g, double glow) {
    final s = scene;
    final pick =
        (s.step == 1 || s.step == 4) && s.friend < 0 && !s.cleaned && !s.held;
    for (var i = 0; i < _friends.length; i++) {
      _paintPerson(
        g,
        _friends[i],
        s.moods[i],
        pick && s.recorded[i] == null ? glow : 0,
      );
    }
    if (s.friend >= 0 && s.cleaned && !s.measuring) _paintTarget(g, glow);
    if (s.th.visible) _paintThermo(g, _thermGlow(glow));
  }

  // ------------------------------------------------------------ people

  /// buildCharacter(): legs (above the table top), arms, torso, neck, head
  /// with hair and the face texture.
  void _paintPerson(_Gfx g, _Person p, _Mood mood, double glow) {
    final k = p.scale;
    final x = p.x;
    g.glow = glow;
    // Legs CylinderGeometry(0.7, 0.6, 4.5): the table hides their lower
    // part (the HTML stood the characters inside the table).
    final legTop = _feetY + 4.5 * k;
    if (legTop > _tableTop) {
      for (final side in const [-1.0, 1.0]) {
        g.vCylinder(
          _V(x + side * 1.2 * k, _tableTop, _personZ),
          0.65 * k,
          legTop - _tableTop,
          _Colors.trousers,
        );
      }
    }
    // Arms (skin), sleeves (shirt) and hands, behind the torso's sides.
    for (final side in const [-1.0, 1.0]) {
      final shoulder = _V(x + side * 2.8 * k, _feetY + 9.5 * k, _personZ);
      final dir = _V(side * math.sin(_armSpread), -math.cos(_armSpread), 0);
      final hand = shoulder + dir * (4.5 * k);
      g.rod(shoulder, hand, 0.55 * k, p.skin);
      g.rod(shoulder, shoulder + dir * (2.5 * k), 0.75 * k, p.shirt);
      g.ball(hand, 0.65 * k, p.skin);
    }
    // Torso BoxGeometry(4.6, 5.5, 2.8) and neck.
    g.box(
      _V(x, _feetY + 7.25 * k, _personZ),
      _V(4.6 * k, 5.5 * k, 2.8 * k),
      p.shirt,
      edge: 0.25,
    );
    g.vCylinder(_V(x, _feetY + 10 * k, _personZ), 0.75 * k, 1.25 * k, p.skin);
    // Head SphereGeometry(2.8), hair hemisphere and face.
    g.ball(p.head, p.headRadius, p.skin);
    _paintHair(g, p);
    g.glow = 0;
    _paintFace(g, p, mood);
  }

  /// Hair: SphereGeometry(2.9) top half, raised 0.2 and tilted back: its
  /// front rim, then the dome over the top.
  void _paintHair(_Gfx g, _Person p) {
    final k = p.scale;
    final c = p.head + _V(0, 0.2 * k, 0);
    final r = 2.9 * k;
    final path = _pens.path..reset();
    const n = 12;
    final lift = math.sin(_hairTilt), keep = math.cos(_hairTilt);
    for (var i = 0; i <= n; i++) {
      final a = math.pi * i / n; // 0 right, π/2 front, π left
      final lz = r * math.sin(a);
      final o = g.cam.p(c + _V(r * math.cos(a), lz * lift, lz * keep));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    final pc = g.cam.p(c);
    path
      ..arcTo(
        Rect.fromCircle(center: pc, radius: r * g.cam.scaleAt(c)),
        math.pi,
        math.pi,
        false,
      )
      ..close();
    g.canvas.drawPath(path, _pens.fill..color = g.tint(_Colors.hair));
    g.canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = 1
        ..color = g.tint(labShade(_Colors.hair, 0.3)),
    );
  }

  /// createFaceTexture(mood) on the 5.6-unit face plane (512 px texture:
  /// one texture px = 5.6 / 512 units).
  void _paintFace(_Gfx g, _Person p, _Mood mood) {
    final canvas = g.canvas;
    final fc = _V(p.x, p.head.y, _personZ + _faceFront * p.scale);
    final o = g.cam.p(fc);
    final px = 5.6 / 512 * p.scale * g.cam.scaleAt(fc);
    Offset at(double tx, double ty) =>
        Offset(o.dx + (tx - 256) * px, o.dy + (ty - 256) * px);
    final ink = _pens.thin
      ..strokeWidth = 18 * px
      ..color = _Colors.faceInk;
    final dot = _pens.fill..color = _Colors.faceInk;

    if (mood == _Mood.fever) {
      // Red flush over the upper face, kept inside the head.
      final head = g.cam.p(p.head);
      final headR = p.headRadius * g.cam.scaleAt(p.head);
      canvas.save();
      canvas.clipPath(
        _pens.clip
          ..reset()
          ..addOval(Rect.fromCircle(center: head, radius: headR)),
      );
      canvas.drawRect(
        Rect.fromPoints(at(0, 0), at(512, 320)),
        cache.fever(at(256, 160), 220 * px, 40 / 220),
      );
      canvas.restore();
    }

    // Eyes.
    for (final ex in const [170.0, 342.0]) {
      switch (mood) {
        case _Mood.fever:
          canvas.drawArc(
            Rect.fromCircle(center: at(ex, 240), radius: 35 * px),
            math.pi,
            math.pi,
            false,
            ink,
          );
        case _Mood.happy:
          canvas.drawCircle(at(ex, 240), 30 * px, dot);
        case _Mood.neutral || _Mood.open:
          canvas.drawCircle(at(ex, 240), 25 * px, dot);
      }
    }
    // Mouth.
    switch (mood) {
      case _Mood.open:
        canvas.drawOval(
          Rect.fromCenter(
            center: at(256, 380),
            width: 70 * px,
            height: 110 * px,
          ),
          _pens.fill..color = _Colors.mouthOpen,
        );
      case _Mood.fever:
        canvas.drawArc(
          Rect.fromCircle(center: at(256, 410), radius: 60 * px),
          math.pi,
          math.pi,
          false,
          ink,
        );
      case _Mood.happy:
        canvas.drawArc(
          Rect.fromCircle(center: at(256, 330), radius: 70 * px),
          0,
          math.pi,
          false,
          ink,
        );
      case _Mood.neutral:
        canvas.drawArc(
          Rect.fromCircle(center: at(256, 340), radius: 50 * px),
          0,
          math.pi,
          false,
          ink,
        );
    }
  }

  /// The highlighted area under the tongue (pulsing ring at the mouth).
  void _paintTarget(_Gfx g, double glow) {
    final s = scene;
    final c = s.mouthPoint;
    final r = s.headRadiusPx * 0.42;
    // Indigo and white: a yellow ring vanished on Lambok's yellow face.
    final pulse = glow / _glowMax;
    g.canvas.drawCircle(
      c,
      r,
      _pens.fill..color = _Colors.white.withValues(alpha: 0.15 + 0.2 * pulse),
    );
    g.canvas.drawCircle(
      c,
      r,
      _pens.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.indigo500.withValues(alpha: 0.6 + 0.4 * pulse),
    );
  }

  // ------------------------------------------------------- thermometer

  /// The thermometer: metal tip, body, digital screen and reset button.
  void _paintThermo(_Gfx g, double glow) {
    final th = scene.th;
    final pose = th.pose;
    g.glow = glow;
    g.rod(
      pose.at(const _V(_tipEndX, 0, 0)),
      pose.at(const _V(_tipStartX, 0, 0)),
      _tipRadius,
      th.tipWet ? _Colors.tipWet : _Colors.tipMetal,
    );
    g.obox(pose.pos, _bodyHalf, pose, _Colors.thermBody, edge: 0.45);
    final up = pose.dir(_V.up);
    if (up.dot(g.cam.eye - pose.at(const _V(0, 0.3, 0))) > 0) {
      g.quad(
        pose.at(const _V(_screenX0, _screenY, -_screenHalfZ)),
        pose.at(const _V(_screenX1, _screenY, -_screenHalfZ)),
        pose.at(const _V(_screenX1, _screenY, _screenHalfZ)),
        pose.at(const _V(_screenX0, _screenY, _screenHalfZ)),
        _Colors.screen,
        edge: _Colors.slate700,
      );
      if (th.display.isNotEmpty) _paintScreenText(g, pose, th.display);
      g.disc(
        pose.at(_buttonTop),
        pose.dir(const _V(1, 0, 0)),
        pose.dir(const _V(0, 0, 1)),
        _buttonRadius,
        _Colors.resetButton,
      );
    }
    g.glow = 0;
  }

  /// The digits on the screen ('900 60px' on a 256 × 128 canvas), along the
  /// thermometer.
  void _paintScreenText(_Gfx g, _Pose pose, String text) {
    final a = g.cam.p(pose.at(const _V(_screenX0, _screenY, 0)));
    final b = g.cam.p(pose.at(const _V(_screenX1, _screenY, 0)));
    final len = (b - a).distance;
    if (len < 12) return;
    final tp = cache.text(text, 20, _Colors.digits, weight: FontWeight.w900);
    final k = math.min(0.8 * len / tp.width, 0.22 * len / tp.height);
    final c = Offset.lerp(a, b, 0.5)!;
    final canvas = g.canvas;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(math.atan2(b.dy - a.dy, b.dx - a.dx));
    canvas.scale(k);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  // ------------------------------------------------------------ labels

  void _paintLabels(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    cache.labelRects.clear();
    if (s.scenario == 0) {
      _chip(canvas, cam.p(const _V(_almX, _almTop + 1, -1)), _t('lbl_almirah'));
      _chip(canvas, cam.p(const _V(_sinkX, 7.5, 0)), _t('lbl_sink'));
      // Beside the head: above it (HTML y 18) the label was off screen.
      final p = _Person.lambok;
      _chip(
        canvas,
        cam.p(_V(p.x + p.headRadius + 0.5, p.head.y + 1, _personZ)),
        _t(p.nameKey),
        edge: -1,
      );
    } else {
      for (final p in _friends) {
        _chip(
          canvas,
          cam.p(_V(p.x, _feetY + 18 * p.scale, _personZ)),
          _t(p.nameKey),
        );
      }
    }
    final th = s.th;
    final shown =
        th.visible && (th.spot != _Spot.shelf || s.doorAngle != 0 || s.held);
    if (shown) {
      _chip(canvas, cam.p(th.pose.at(_thermLabelAt)), _t('lbl_therm'));
    }
  }

  /// HTML text sprite: dark rounded chip with an indigo border and white
  /// bold text centred on [at]; with [edge] 1 its right edge sits on [at],
  /// with −1 its left edge. A chip anchored under the tool column is not
  /// drawn, one that reaches under it is moved left, and one that would
  /// cover a chip already drawn moves up or down clear of it.
  void _chip(Canvas canvas, Offset at, String text, {double edge = 0}) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    var cx = at.dx - edge * w / 2;
    if (cx - w / 2 > labelRight - 4) return;
    if (cx + w / 2 > labelRight - 4) cx = labelRight - 4 - w / 2;
    final placed = cache.labelRects;
    var rect = Rect.fromCenter(center: Offset(cx, at.dy), width: w, height: h);
    for (final step in const [0.0, -1.0, 1.0, -2.0, 2.0]) {
      final r = rect.shift(Offset(0, step * (h + 3)));
      if (!placed.any((o) => o.overlaps(r))) {
        rect = r;
        break;
      }
    }
    placed.add(rect);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.labelBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.labelBorder,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  // ----------------------------------------------------------- effects

  void _paintEffects(Canvas canvas) {
    final s = scene;
    final th = s.th;
    if (s.measuring) {
      final p = (s.time - s.measureStart) / _measureSeconds;
      _paintMeasuring(canvas, s.cam.p(s.patient.pillAnchor), p.clamp(0, 1));
    }
    // The magnified display: hidden while measuring and, in Scenario 1,
    // while the thermometer is still in the mouth ("DRAG it out to read").
    final readable =
        th.visible &&
        th.display.isNotEmpty &&
        !s.held &&
        !s.measuring &&
        !th.moving &&
        (th.spot != _Spot.mouth || s.scenario == 1);
    if (readable) _paintReadout(canvas, th.display);
    final fly = s.time - s.flyStart;
    if (fly >= 0 && fly < _flySeconds) _paintFlying(canvas, fly / _flySeconds);
    final burst = s.time - s.burstStart;
    if (burst >= 0 && burst < _burstSeconds) {
      _paintBurst(canvas, s.cam.p(s.burstAt), burst);
    }
    if (s.soapShown) _paintSoap(canvas, s.soapPoint);
  }

  /// HTML `#ui-progress-container`: "Measuring..." and a bar filling in 3 s.
  void _paintMeasuring(Canvas canvas, Offset at, double progress) {
    final k = _ui;
    final w = 150 * k, h = 46 * k;
    final rect = Rect.fromCenter(center: at, width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(12 * k));
    canvas.drawRRect(rr.shift(Offset(0, 3 * k)), _pens.shadow);
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.glassDark : _Colors.glassLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = isDark ? _Colors.slate600 : _Colors.slate300,
    );
    final tp = cache.text(
      _t('measuring'),
      12 * k,
      isDark ? _Colors.slate300 : _Colors.slate700,
    );
    tp.paint(canvas, Offset(at.dx - tp.width / 2, rect.top + 7 * k));
    final bar = Rect.fromLTWH(
      rect.left + 12 * k,
      rect.bottom - 15 * k,
      w - 24 * k,
      7 * k,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, Radius.circular(4 * k)),
      _pens.fill..color = isDark ? _Colors.slate700 : _Colors.slate200,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bar.left, bar.top, bar.width * progress, bar.height),
        Radius.circular(4 * k),
      ),
      _pens.fill..color = _Colors.emerald500,
    );
  }

  /// The digital display, magnified below the thermometer (the screen on
  /// the 3D model is only a few px tall on a phone).
  void _paintReadout(Canvas canvas, String display) {
    final s = scene;
    final k = _ui;
    final numeric = double.tryParse(display) != null;
    final text = numeric ? '$display ${_t('unit_c')}' : display;
    final tp = cache.text(
      text,
      17 * k,
      _Colors.digits,
      weight: FontWeight.w900,
    );
    final anchor = s.cam.p(s.th.pose.at(const _V(-0.5, 0, 0)));
    final top = anchor.dy + 20 * k;
    final rect = Rect.fromCenter(
      center: Offset(anchor.dx, top + (tp.height + 8 * k) / 2),
      width: tp.width + 16 * k,
      height: tp.height + 8 * k,
    );
    final pointer = _pens.path
      ..reset()
      ..moveTo(anchor.dx - 6 * k, rect.top + 1)
      ..lineTo(anchor.dx, rect.top - 7 * k)
      ..lineTo(anchor.dx + 6 * k, rect.top + 1)
      ..close();
    final fill = _pens.fill..color = _Colors.screen;
    canvas.drawPath(pointer, fill);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(6 * k));
    canvas.drawRRect(rr, fill);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.slate700,
    );
    tp.paint(canvas, Offset(rect.left + 8 * k, rect.top + 4 * k));
  }

  /// HTML `.flying-number`: the reading rises from the display towards the
  /// table, shrinking and fading (1 s, ease-out).
  void _paintFlying(Canvas canvas, double t) {
    final s = scene;
    final k = _ui;
    final e = Curves.easeOutCubic.transform(t);
    final from = s.cam.p(s.th.pose.at(const _V(-0.5, 0, 0)));
    final at = from + Offset(-150 * k * e, -130 * k * e);
    // The fade runs through ten cached alpha steps (no layer per frame).
    final alpha = ((1 - e) * _fadeSteps).ceil() / _fadeSteps;
    final tp = cache.text(
      s.flyText,
      24 * k,
      _Colors.emerald500.withValues(alpha: alpha),
      weight: FontWeight.w800,
    );
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(1 - 0.5 * e);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  /// Water droplets bursting from the tip (HTML canvas-confetti).
  void _paintBurst(Canvas canvas, Offset at, double t) {
    final fade = 1 - t / _burstSeconds;
    final k = _ui * 0.6;
    for (var i = 0; i < _burstVelocity.length; i++) {
      final v = _burstVelocity[i] * k;
      final p = at + v * t + Offset(0, 0.5 * _burstGravity * k * t * t);
      final color = switch (i % 3) {
        0 => _Colors.dropWhite,
        1 => _Colors.dropBlue,
        _ => _Colors.dropPale,
      };
      canvas.drawCircle(
        p,
        3 * _ui,
        _pens.fill..color = color.withValues(alpha: fade),
      );
    }
  }

  /// The soap dispenser (HTML SVG, `animate-bounce`).
  void _paintSoap(Canvas canvas, Offset at) {
    final s = scene;
    final size = _soapSize * s.frameK.clamp(0.75, 1.0) * _ui.clamp(1.0, 1.3);
    final bob = s.soapDrag == null
        ? -0.16 * size * (math.sin(math.pi * s.time)).abs()
        : 0.0;
    final c = at + Offset(0, bob);
    canvas.drawOval(
      Rect.fromCenter(
        center: at + Offset(0, size * 0.48),
        width: size * 0.55,
        height: size * 0.12,
      ),
      _pens.shadow,
    );
    canvas.save();
    canvas.translate(c.dx - size / 2, c.dy - size / 2);
    canvas.scale(size / 64);
    final fill = _pens.fill;
    canvas.drawPath(cache.soapBody, fill..color = _Colors.soapBody);
    canvas.drawPath(cache.soapBand, fill..color = _Colors.soapBand);
    canvas.drawRect(
      const Rect.fromLTWH(28, 16, 8, 12),
      fill..color = _Colors.soapNeck,
    );
    canvas.drawPath(cache.soapPump, fill..color = _Colors.soapPump);
    canvas.drawRect(
      const Rect.fromLTWH(18, 12, 10, 4),
      fill..color = _Colors.soapNozzle,
    );
    canvas.drawPath(cache.soapSpout, fill..color = _Colors.soapPump);
    canvas.drawCircle(
      const Offset(32, 42),
      5,
      fill..color = _Colors.soapPump.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      const Offset(40, 36),
      3,
      fill..color = _Colors.soapPump.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      const Offset(24, 48),
      2,
      fill..color = _Colors.soapPump.withValues(alpha: 0.5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.labelRight != labelRight;
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
