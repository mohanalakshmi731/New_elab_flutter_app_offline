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

/// Class 6 Science • Chapter 7 • Activity 3
/// Laboratory Thermometers: Structure and Calibration.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A3-Laboratory_Thermometers__Structure_and_Calibration.html`.
///
/// Scenario 1 (Finding the Thermometer's Range): drag a magnifying glass over
/// the lowest and then the highest number of a laboratory thermometer's
/// scale, drag each glowing number into the 'Find Range' panel and watch the
/// whole range light up.
///
/// Scenario 2 (Calculating the Least Count): drag the Zoom Tool onto the
/// 0–10 °C section, subtract the two numbered marks in the Difference
/// Calculator, tap the lines to count the divisions, drop the difference
/// onto the division count (10 °C / 10 divisions = 1 °C) and watch one
/// division glow.
class Ch7A3LaboratoryThermometersStructureAndCalibrationPage
    extends StatefulWidget {
  const Ch7A3LaboratoryThermometersStructureAndCalibrationPage({super.key});

  @override
  State<Ch7A3LaboratoryThermometersStructureAndCalibrationPage> createState() =>
      _ThermometerLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with WebAudio; it
/// also asks for 'beep' and 'measure', which its synthesiser has no branch
/// for (so they are silent there): they get the closest bundled tones.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// success → `math/success.mp3`, click → `science/click.mp3`,
/// beep → `science/dropdown.mp3`, measure → `science/page_open.mp3`,
/// wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`: Enter Lab, scenario change, every drop, every
  /// button and the one-division highlight.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('success')`: a number found, the zoom, the division
  /// count and the least count, the conclusion.
  success('audio/class6/math/success.mp3'),

  /// HTML `playSound('click')`: one division line counted.
  click('audio/class6/science/click.mp3'),

  /// HTML `playSound('beep')`: a calculator result (silent in the HTML).
  beep('audio/class6/science/dropdown.mp3'),

  /// HTML `playSound('measure')`: the range bar rises (silent in the HTML).
  measure('audio/class6/science/page_open.mp3'),

  /// Error toasts (wrong box, wrong line). The HTML has no error tone.
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

/// Tailwind colours used by the HTML (UI, Three.js materials, badges).
abstract final class _Colors {
  /// Brand blue of this lab (HUD border, Enter Lab, the range bar 0x3b82f6).
  static const Color blue500 = Color(0xFF3B82F6);

  /// '-10 °C' badge, 'Observe Conclusion', the least-count result.
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue300 = Color(0xFF93C5FD);

  /// Curtain glow (`from-blue-900/40`) and subtitle (`text-blue-300/80`).
  static const Color blue900Glow = Color(0x661E3A8A);
  static const Color blue300Muted = Color(0xCC93C5FD);

  /// Tool pulse (`pulse-highlight`, rgba(99,102,241)).
  static const Color indigo500 = Color(0xFF6366F1);

  /// Zoom tool, drop boxes once filled, results (`emerald-500`).
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald600 = Color(0xFF059669);

  /// Glow boxes and counted lines (MeshBasicMaterial 0x4ade80).
  static const Color green400 = Color(0xFF4ADE80);

  /// The highlighted division (0x22c55e).
  static const Color green500 = Color(0xFF22C55E);

  /// Bulb and liquid (0xef4444) and the '110 °C' badge.
  static const Color red500 = Color(0xFFEF4444);

  /// Magnifying-glass lens tint (#e0f2fe).
  static const Color sky100 = Color(0xFFE0F2FE);

  /// Scale texture background (#f8fafc) and marks (#0f172a).
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);

  /// Top ring (0x94a3b8) and the lens frame.
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);

  /// '0' / '10' badges and the lens grip.
  static const Color slate700 = Color(0xFF334155);

  /// Lens handle.
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  /// Canvas background (scene.background 0x020617).
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Inset rows of the panels (`bg-slate-800/80`).
  static const Color insetDark = Color(0xCC1E293B);

  /// Badge border (`border-white/50`).
  static const Color chipBorder = Color(0x80FFFFFF);

  /// Scene label chips (`bg-slate-900/90`) and toasts.
  static const Color labelBg = Color(0xE60F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The canvas follows the theme like the HTML `setTheme()`:
/// #020617 in dark mode, #f1f5f9 in light mode.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: _Colors.insetDark,
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950,
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
    toastBg: _Colors.labelBg, // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: _Colors.blue900Glow,
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300Muted,
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
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // completed steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.labelBg,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: _Colors.blue900Glow,
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300Muted,
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
// Copied from the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// Changes:
// - "CLICK" became "TAP" (touch screens); "Click 'Observe Conclusion'" is
//   now part of each step 5 action, which also needs that tap.
// - The HUD lines no longer name the answers ("the lowest number (-10)").
// - S2 step 2 says which box each number goes into (10 − 0, not 0 − 10).
// - S2 step 3: there are 9 small lines strictly between 0 and 10; the
//   counter needs the line at the 10 °C mark too, so the step says so.
// - S2 step 5: "each small line represents 1 °C" became "each small
//   division" (a division is the space between two lines).
// - The subtitle follows the NCERT chapter title ("Temperature and its
//   Measurement"); English glosses in the Hindi text ("(Range)") are gone.
// - New: the error toasts for the checks this port adds, the panel's
//   division count, the scene labels and the canvas units.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Laboratory Thermometers: Structure and Calibration',
    'app_subtitle': 'Class 6 • Temperature and its Measurement',
    'scen_1_opt': "Scenario 1: Finding the Thermometer's Range",
    'scen_2_opt': 'Scenario 2: Calculating the Least Count',
    's1_desc':
        'To visually identify and record the lowest and highest temperatures a laboratory thermometer can measure.',
    's2_desc':
        "To visually determine the value of one small division on the thermometer's scale.",
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Identifying Minimum Range',
    's1_a1':
        "A virtual magnifying glass is provided. DRAG it and HOVER over the lowest number marked on the thermometer's scale.",
    's1_o1':
        "The area around '-10 °C' zooms in and glows, revealing the lowest measurable point.",
    's1_c2': 'Recording Minimum Range',
    's1_a2':
        "The glowing number '-10 °C' has become a draggable object. DRAG this number and DROP it into the box labeled 'Lowest Temperature'.",
    's1_o2': "The number '-10 °C' is correctly placed and locked into the box.",
    's1_c3': 'Identifying Maximum Range',
    's1_a3':
        "Now, DRAG the magnifying glass and HOVER it over the highest number marked on the thermometer's scale.",
    's1_o3':
        "The area around '110 °C' zooms in and glows, revealing the highest measurable point.",
    's1_c4': 'Recording Maximum Range',
    's1_a4':
        "The glowing number '110 °C' is now a draggable object. DRAG this number and DROP it into the box labeled 'Highest Temperature'.",
    's1_o4': "The number '110 °C' is correctly placed and locked into the box.",
    's1_c5': 'Understanding Full Range',
    's1_a5':
        "Observe the thermometer as its full measurement range is highlighted, then tap 'Observe Conclusion'.",
    's1_o5':
        "A transparent colored bar animates up the entire length, showing the full span. You understand the 'Range' is from -10 °C to 110 °C.",
    's1_hud_1':
        'Step 1: DRAG the magnifying glass and HOVER it over the lowest number on the scale.',
    's1_hud_2':
        "Step 2: DRAG the glowing '-10 °C' number into the 'Lowest Temperature' box.",
    's1_hud_3':
        'Step 3: DRAG the magnifying glass and HOVER it over the highest number on the scale.',
    's1_hud_4':
        "Step 4: DRAG the glowing '110 °C' number into the 'Highest Temperature' box.",
    's1_hud_5':
        "Step 5: Observe the full range highlighted. Tap 'Observe Conclusion'.",
    's1_summary':
        'Range Identified! Every measuring tool has limits. You successfully found that this standard laboratory thermometer can measure temperatures ranging from -10 °C to 110 °C.',
    // Scenario 2 steps.
    's2_c1': 'Magnifying the Scale',
    's2_a1':
        "A 'Zoom Tool' is provided. DRAG it and DROP it onto the section between 0 °C and 10 °C.",
    's2_o1':
        'The selected section is greatly magnified, clearly showing the large marks and smaller divisions between them.',
    's2_c2': 'Finding the Difference',
    's2_a2':
        "A 'Difference Calculator' appears. DRAG the larger number (10 °C) into its first box and the smaller number (0 °C) into its second box.",
    's2_o2':
        'The tool automatically calculates the difference between the major marks: 10 - 0 = 10 °C.',
    's2_c3': 'Counting Divisions',
    's2_a3':
        "A 'Division Counter' is active. TAP each line after the 0 °C mark, up to and including the 10 °C mark, to count the small divisions (each line closes one division).",
    's2_o3':
        "As you tap, the counter increments until it shows '10 Divisions'. You now know there are 10 gaps between the numbers.",
    's2_c4': 'Calculating Least Count',
    's2_a4':
        "DRAG the '10 °C' result and DROP it onto the '10 Divisions' result to divide them.",
    's2_o4':
        "An animation shows the calculation (10 °C / 10 Divisions). The result is '1 °C'.",
    's2_c5': 'Understanding Precision',
    's2_a5':
        "Observe the animation to understand the result, then tap 'Observe Conclusion'.",
    's2_o5':
        'One small division glows. You understand that each small division represents 1 °C. This is the smallest value (Least Count) the thermometer can accurately read.',
    's2_hud_1':
        'Step 1: DRAG the Zoom Tool over the section between 0 °C and 10 °C.',
    's2_hud_2':
        "Step 2: DRAG '10' into the first box and '0' into the second box of the Difference Calculator.",
    's2_hud_3':
        'Step 3: TAP each line after 0 °C, up to the 10 °C mark, to count the divisions.',
    's2_hud_4':
        "Step 4: DRAG '10 °C' and drop it onto '10 Divisions' to calculate the Least Count.",
    's2_hud_5':
        "Step 5: Observe the final explanation. Tap 'Observe Conclusion'.",
    's2_summary':
        'Least Count Calculated! You found the difference between major marks (10 °C) and divided it by the number of divisions (10). Key takeaway: The Least Count is 1 °C. This is the precision of this thermometer.',
    // Panels (HTML `#s1-panel`, `#s2-panel`).
    'find_range': 'Find Range',
    'lowest_temp': 'Lowest Temperature',
    'highest_temp': 'Highest Temperature',
    'diff_calc': 'Difference Calculator',
    'div_counter': 'Division Counter',
    'n_divisions': '{n} Divisions',
    'least_count_calc': 'Least Count',
    'deg_c': '{v} °C',
    'btn_conclude': 'Observe Conclusion',
    // Toasts (HTML `showToast`) and this port's error toasts.
    'toast_drag_target': 'Drag to the correct target box!',
    'toast_click_divs': 'Tap the small division lines on the thermometer!',
    'err_calc_order':
        'The larger number (10 °C) goes in the first box and the smaller number (0 °C) in the second.',
    'err_count_range': 'Count only the lines after 0 °C, up to the 10 °C mark.',
    'err_divide': "Drop '10 °C' onto the '10 Divisions' result to divide them.",
    // Summary popups.
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You learned how to find the Range and Least Count of a Laboratory Thermometer. Essential skills for any scientist!',
    // Teacher board step list.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Scene labels and descriptions.
    'lbl_bulb': 'Bulb',
    'lbl_scale': 'Scale (°C)',
    'scene_desc':
        'A laboratory thermometer with a red bulb and a numbered scale',
  },
  'hi': {
    'app_title': 'प्रयोगशाला थर्मामीटर: संरचना और अंशांकन',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'scen_1_opt': 'परिदृश्य 1: थर्मामीटर की सीमा खोजना',
    'scen_2_opt': 'परिदृश्य 2: अल्पतमांक की गणना',
    's1_desc':
        'प्रयोगशाला थर्मामीटर द्वारा मापे जा सकने वाले न्यूनतम और अधिकतम तापमान को देखना और रिकॉर्ड करना।',
    's2_desc': 'थर्मामीटर के पैमाने पर एक छोटे विभाजन का मान ज्ञात करना।',
    's1_c1': 'न्यूनतम सीमा की पहचान',
    's1_a1':
        'एक आभासी आवर्धक कांच दिया गया है। इसे खींचें और थर्मामीटर के पैमाने पर अंकित सबसे कम संख्या के ऊपर रखें।',
    's1_o1':
        "'-10 °C' के आसपास का क्षेत्र ज़ूम इन होता है और चमकता है, जो न्यूनतम मापने योग्य बिंदु को प्रकट करता है।",
    's1_c2': 'न्यूनतम सीमा रिकॉर्ड करना',
    's1_a2':
        "चमकते हुए नंबर '-10 °C' को अब खींचा जा सकता है। इसे खींचें और 'न्यूनतम तापमान' वाले बॉक्स में छोड़ दें।",
    's1_o2': "नंबर '-10 °C' सही ढंग से रखा गया है और बॉक्स में लॉक हो गया है।",
    's1_c3': 'अधिकतम सीमा की पहचान',
    's1_a3':
        'अब आवर्धक कांच को खींचें और थर्मामीटर के पैमाने पर अंकित सबसे बड़ी संख्या के ऊपर रखें।',
    's1_o3':
        "'110 °C' के आसपास का क्षेत्र ज़ूम इन होता है और चमकता है, जो अधिकतम मापने योग्य बिंदु को प्रकट करता है।",
    's1_c4': 'अधिकतम सीमा रिकॉर्ड करना',
    's1_a4':
        "चमकते हुए नंबर '110 °C' को अब खींचा जा सकता है। इसे खींचें और 'अधिकतम तापमान' वाले बॉक्स में छोड़ दें।",
    's1_o4': "नंबर '110 °C' सही ढंग से रखा गया है और बॉक्स में लॉक हो गया है।",
    's1_c5': 'पूरी सीमा को समझना',
    's1_a5':
        "थर्मामीटर को देखें, जिसकी पूरी माप सीमा हाइलाइट की जा रही है, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's1_o5':
        "एक पारदर्शी रंगीन पट्टी पूरी लंबाई में ऊपर बढ़ती है और पूरा फैलाव दिखाती है। आप समझते हैं कि 'सीमा' -10 °C से 110 °C तक है।",
    's1_hud_1':
        'चरण 1: आवर्धक कांच को खींचें और पैमाने पर सबसे छोटी संख्या के ऊपर रखें।',
    's1_hud_2':
        "चरण 2: चमकते हुए नंबर '-10 °C' को 'न्यूनतम तापमान' बॉक्स में खींचें।",
    's1_hud_3':
        'चरण 3: आवर्धक कांच को खींचें और पैमाने पर सबसे बड़ी संख्या के ऊपर रखें।',
    's1_hud_4':
        "चरण 4: चमकते हुए नंबर '110 °C' को 'अधिकतम तापमान' बॉक्स में खींचें।",
    's1_hud_5':
        "चरण 5: हाइलाइट की गई पूरी सीमा देखें। 'निष्कर्ष देखें' पर टैप करें।",
    's1_summary':
        'सीमा पहचानी गई! हर मापने वाले उपकरण की सीमाएं होती हैं। आपने पाया कि यह प्रयोगशाला थर्मामीटर -10 °C से 110 °C तक का तापमान माप सकता है।',
    's2_c1': 'पैमाने को बड़ा करना',
    's2_a1':
        "एक 'ज़ूम टूल' दिया गया है। इसे खींचें और 0 °C और 10 °C के बीच के भाग पर छोड़ दें।",
    's2_o1':
        'चयनित भाग बहुत बड़ा हो जाता है, जिससे बड़े निशान और उनके बीच छोटे विभाजन स्पष्ट रूप से दिखाई देते हैं।',
    's2_c2': 'अंतर खोजना',
    's2_a2':
        "एक 'अंतर कैलकुलेटर' दिखाई देता है। बड़ी संख्या (10 °C) को उसके पहले बॉक्स में और छोटी संख्या (0 °C) को उसके दूसरे बॉक्स में खींचें।",
    's2_o2':
        'उपकरण स्वचालित रूप से प्रमुख निशानों के बीच अंतर की गणना करता है: 10 - 0 = 10 °C।',
    's2_c3': 'विभाजनों की गिनती',
    's2_a3':
        "एक 'विभाजन काउंटर' सक्रिय है। छोटे विभाजनों को गिनने के लिए 0 °C के निशान के बाद की हर रेखा पर, 10 °C के निशान तक (उसे भी मिलाकर), टैप करें। हर रेखा एक विभाजन को पूरा करती है।",
    's2_o3':
        "जैसे-जैसे आप टैप करते हैं, काउंटर '10 विभाजन' दिखाने तक बढ़ता है। अब आप जानते हैं कि संख्याओं के बीच 10 अंतराल हैं।",
    's2_c4': 'अल्पतमांक की गणना',
    's2_a4':
        "'10 °C' परिणाम को खींचें और भाग देने के लिए उसे '10 विभाजन' परिणाम पर छोड़ दें।",
    's2_o4': "एक एनीमेशन गणना (10 °C / 10 विभाजन) दिखाता है। परिणाम '1 °C' है।",
    's2_c5': 'सटीकता को समझना',
    's2_a5':
        "परिणाम समझने के लिए एनीमेशन देखें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's2_o5':
        'एक छोटा विभाजन चमकता है। आप समझते हैं कि प्रत्येक छोटा विभाजन 1 °C दर्शाता है। यह वह सबसे छोटा मान (अल्पतमांक) है जिसे थर्मामीटर सटीक रूप से पढ़ सकता है।',
    's2_hud_1': 'चरण 1: ज़ूम टूल को 0 °C और 10 °C के बीच के भाग पर खींचें।',
    's2_hud_2':
        "चरण 2: अंतर कैलकुलेटर में '10' को पहले बॉक्स में और '0' को दूसरे बॉक्स में खींचें।",
    's2_hud_3':
        'चरण 3: विभाजन गिनने के लिए 0 °C के बाद की हर रेखा पर, 10 °C के निशान तक, टैप करें।',
    's2_hud_4':
        "चरण 4: अल्पतमांक की गणना करने के लिए '10 °C' खींचें और इसे '10 विभाजन' पर छोड़ दें।",
    's2_hud_5': "चरण 5: अंतिम स्पष्टीकरण देखें। 'निष्कर्ष देखें' पर टैप करें।",
    's2_summary':
        'अल्पतमांक की गणना हो गई! आपने प्रमुख निशानों के बीच का अंतर (10 °C) पाया और इसे विभाजनों की संख्या (10) से भाग दिया। मुख्य निष्कर्ष: अल्पतमांक 1 °C है। यह इस थर्मामीटर की सटीकता है।',
    'find_range': 'सीमा खोजें',
    'lowest_temp': 'न्यूनतम तापमान',
    'highest_temp': 'अधिकतम तापमान',
    'diff_calc': 'अंतर कैलकुलेटर',
    'div_counter': 'विभाजन काउंटर',
    'n_divisions': '{n} विभाजन',
    'least_count_calc': 'अल्पतमांक',
    'deg_c': '{v} °C',
    'btn_conclude': 'निष्कर्ष देखें',
    'toast_drag_target': 'सही लक्ष्य बॉक्स पर खींचें!',
    'toast_click_divs': 'थर्मामीटर पर छोटी विभाजन रेखाओं पर टैप करें!',
    'err_calc_order':
        'बड़ी संख्या (10 °C) पहले बॉक्स में और छोटी संख्या (0 °C) दूसरे बॉक्स में जाती है।',
    'err_count_range': 'केवल 0 °C के बाद की रेखाएँ, 10 °C के निशान तक, गिनें।',
    'err_divide': "भाग देने के लिए '10 °C' को '10 विभाजन' परिणाम पर छोड़ें।",
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने प्रयोगशाला थर्मामीटर की सीमा और अल्पतमांक ज्ञात करना सीखा। किसी भी वैज्ञानिक के लिए आवश्यक कौशल!',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'lbl_bulb': 'बल्ब',
    'lbl_scale': 'पैमाना (°C)',
    'scene_desc': 'लाल बल्ब और अंकित पैमाने वाला एक प्रयोगशाला थर्मामीटर',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML `ScenariosData`:
/// five steps of concept / action / observation per scenario).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      LabScenarioData scenario(int n) => LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_c$i'),
              action: t('s${n}_a$i'),
              observation: t('s${n}_o$i'),
            ),
        ],
      );
      return [scenario(1), scenario(2)];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);
const Offset _stageCentre = Offset(500, 280);

/// Interactive things stay this far inside the stage box (only the box is
/// hit-tested).
const double _stageEdge = 6;
final Rect _stageSafe = Rect.fromLTWH(
  _stageEdge,
  _stageEdge,
  _design.width - 2 * _stageEdge,
  _design.height - 2 * _stageEdge,
);

/// Steps per scenario (HTML `steps`), and the value of `step` once the
/// conclusion has been opened.
const int _stepCount = 5;
const int _doneStep = _stepCount + 1;
const int _scenarioCount = 2;

/// Smallest touch target (logical px) and the tool drag's touch slop
/// (Flutter's default is 18 px; short drags must pick the tool up).
const double _minTouch = 48;
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

// ------------------------------------------------------------------ camera
// HTML `init3D()`: PerspectiveCamera(45°) at (-2, 0, 45) looking at
// (-2, 0, 0). That view shows only y ±18.6 at the thermometer, so the scale
// above about 78 °C (and the 110 mark the learner must find) was off the
// top of the canvas. The camera keeps the HTML lens and viewing direction
// but is placed to fit the thermometer into the part of the canvas no card
// covers.

/// 280 / tan(22.5°): the 45° vertical field of view over the 560 px stage.
const double _focal = 675.98;

// --------------------------------------------------------------- thermometer
// HTML `buildLaboratoryThermometer()`: a group at (-2, -5, 0).

const double _axisX = -2;
const double _groupY = -5;

/// Outer glass: CylinderGeometry(1.2, 1.2, 34) centred 17 above the group.
const double _glassRadius = 1.2;
const double _glassBottom = _groupY;
const double _glassTop = _groupY + 34;

/// Top ring: TorusGeometry(0.8, 0.2) at group y 34.5, facing the camera.
const double _ringY = _groupY + 34.5;
const double _ringRadius = 0.8;
const double _ringTube = 0.2;

/// Red bulb: SphereGeometry(1.4) at group y -0.5.
const double _bulbY = _groupY - 0.5;
const double _bulbRadius = 1.4;

/// When the glass is drawn wider than its HTML size (phones), the bulb is
/// kept just wider than the glass instead of 1.4 / 1.2 times it.
const double _bulbOverTube = 1.05;

/// Capillary: CylinderGeometry(0.2) above the bulb; the opaque scale plane
/// in front hides all of it but the stub below the scale.
const double _capillaryRadius = 0.2;

/// Scale plane: PlaneGeometry(1.8, 30) at group (0, 17, 0.5). Everything is
/// projected at its depth, so the highlights (the HTML puts them 0.05–0.6
/// in front) stay on their marks when the camera zooms in.
const double _scaleWidth = 1.8;
const double _scaleBottom = _groupY + 2;
const double _scaleTop = _groupY + 32;
const double _scaleZ = 0.5;

/// HTML `createThermometerScaleTexture()`: a 2048 px tall canvas, -10 °C
/// 200 px above its bottom, 1748 px for the 120 °C to 110 °C.
const double _texHeight = 2048;
const double _texPad = 200;
const double _texUsable = 1748;
const double _minC = -10;
const double _maxC = 110;
const double _unitsPerC = _texUsable / 120 * _scaleHeightUnits / _texHeight;
const double _scaleHeightUnits = 30;

/// World y of temperature [c] (HTML `calcY` plus the plane and group).
double _yOf(double c) =>
    _groupY +
    17 +
    (_texPad + (c - _minC) * _texUsable / 120) *
        _scaleHeightUnits /
        _texHeight -
    _scaleHeightUnits / 2;

/// Temperature at world y.
double _cOf(double y) => _minC + (y - _yOf(_minC)) / _unitsPerC;

/// Mark lines on the texture: 6 / 4 / 2 px thick (10 °C, 5 °C, 1 °C).
const double _majorLine = 6 * _scaleHeightUnits / _texHeight;
const double _fiveLine = 4 * _scaleHeightUnits / _texHeight;
const double _minorLine = 2 * _scaleHeightUnits / _texHeight;
const double _majorMinPx = 1.4, _fiveMinPx = 1.1, _minorMinPx = 0.8;

/// Strip layout, as fractions of the drawn strip width from its left edge
/// (the HTML texture's marks start at 90 / 110 / 130 px and end at 160 px
/// of 256; its numbers start at 170 px). The marks move left a little so
/// that the numbers fit on narrow phone strips.
const double _majorFrom = 0.12;
const double _fiveFrom = 0.24;
const double _minorFrom = 0.34;
const double _tickTo = 0.52;
const double _numberFrom = 0.57;
const double _numberRoom = 0.38;

/// Scale numbers: about the HTML size on the plane (0.28 of the world
/// unit), at least 9 dp on screen (the strip widens to hold them), at most
/// 56 px. [_numberEm] is the width of "110" in em; [_digitEm] one digit.
const double _numberWorld = 0.28;
const double _numberMinDp = 9;
const double _numberMaxPx = 56;
const double _numberEm = 1.75;
const double _digitEm = 0.6;

/// Number text is laid out once at this size and drawn scaled.
const double _numberRefPx = 40;

/// HTML glow boxes: PlaneGeometry(2, 1) over the -10 / 110 marks; counted
/// lines BoxGeometry(2, 0.15); range bar and highlight 1.6 wide.
const double _glowWidth = 2 / _scaleWidth;
const double _glowHeight = 1;
const double _countedHeight = 0.15;
const double _countedFrom = 0.04, _countedTo = 0.555;
const double _barWidth = 1.6 / _scaleWidth;

// --------------------------------------------------------------- framing

/// Canvas cards (dp at labScale 1): the toast (one line) under its 10 dp
/// top margin, the two-line HUD chip above its 8 dp bottom margin, the gap
/// kept from cards.
const double _toastTop = 10;
const double _toastBand = 34;
const double _hudBottom = 8;
const double _hudBand = 58;
const double _hudGap = 6;
const double _cardGap = 12;

/// LAB FRAMEWORK: the floating mission card's left edge (beside the menu
/// button).
const double _missionCardLeft = 76;

/// Panels (dp at labScale 1): 'Find Range' and the calculator card, or the
/// calculator as a strip along the bottom when the zoomed scale would have
/// less than [_zoomRoomMin] dp beside it (small phones, sidebar collapsed).
const double _s1PanelWidth = 150;
const double _s2PanelWidth = 240;
const double _s2StripHeight = 110;

/// Calculator card sizes (dp at labScale 1; rows that take a drop or are
/// dragged stay at least [_calcRowMin] tall).
const double _calcPad = 8;
const double _calcGap = 4;
const double _insetPad = 5;
const double _sectionFont = 10.5;
const double _calcRowH = 36;
const double _calcRowMin = 40;
const double _fractionH = 26;
const double _fractionMin = 26;
const double _tickBoxH = 14;
const double _dividerGap = 6;

/// Strip sections are laid out at least this wide, then scaled to fit.
const double _stripSectionMin = 160;
const double _zoomRoomMin = 160;

/// A free area smaller than this (design px) falls back to the whole stage.
const double _minFrame = 60;

/// Room above the top mark and below the bulb (design px), and the zoomed
/// view: 0 °C to 10 °C plus this margin, with a little padding.
const double _homePadBottom = 6;
const double _zoomMarginC = 0.6;
const double _zoomPad = 8;

/// Canvas UI (badges, tools, labels) grows when the stage is scaled down
/// (the Chapter 4 / 5 rule).
const double _uiFullScale = 0.85;
const double _uiMaxBoost = 1.8;

// ----------------------------------------------------------- tools, badges

/// Magnifying glass (HTML `#ui-mag-glass`): lens radius and zoom; the
/// handle reaches to 1.95 radii at 45°, so the tool is 2.4 radii wide.
const double _lensRadius = 30;
const double _lensZoom = 2.2;
const double _lensWidth = 2.4;

/// Zoom tool (HTML `#ui-zoom-tool`): a 52 px rounded square.
const double _zoomToolSize = 52;

/// Gap between the thermometer and the tool's home.
const double _toolGap = 16;

/// The tools start beside the scale at these temperatures (the HTML put
/// them at 10% / 30% of the canvas, which the collapsed sidebar's mission
/// card covers).
const double _magnifierHomeC = 50;
const double _zoomHomeC = 60;

/// Grab reach around the lens centre (lens radii) and a finger's reach.
const double _grabRadii = 1.45;
const double _fingerDp = 24;

/// A hover counts within 6 °C of the target number (the HTML: 60 screen px,
/// about 10 °C) or a finger's reach, over the thermometer. The zoom tool
/// counts over 0–10 °C give or take 2 °C (the HTML: within 80 px of its
/// middle, about 14 °C).
const double _hoverC = 6;
const double _zoomSlackC = 2;

/// Badges (HTML `.drag-badge`: font-black text-lg px-4 py-2 border-2).
const double _badgeFont = 18;
const double _badgePadX = 14;
const double _badgePadY = 7;
const double _badgeHeight = _badgeFont * 1.15 + 2 * _badgePadY + 4;
const double _badgeEm = 0.62;

/// Number of divisions between 0 °C and 10 °C.
const int _divisions = 10;

// ----------------------------------------------------------------- timings
// HTML setTimeouts and TWEEN durations.

const Duration _foundDelay = Duration(milliseconds: 500);
const double _zoomSeconds = 1.0; // camera tween, Cubic.InOut
const Duration _zoomStepDelay = Duration(milliseconds: 1200);
const double _rangeSeconds = 1.5; // highlight bar, linear
const Duration _rangeButtonDelay = Duration(milliseconds: 1500);
const Duration _calcDelay = Duration(milliseconds: 500);
const Duration _calcStepDelay = Duration(milliseconds: 1000);
const Duration _countDelay = Duration(milliseconds: 500);
const Duration _countStepDelay = Duration(milliseconds: 1000);
const Duration _divideResultDelay = Duration(milliseconds: 1000);
const Duration _divideStepDelay = Duration(milliseconds: 1500);
const Duration _precisionButtonDelay = Duration(milliseconds: 1000);

/// HTML highlightTick: scale to (1.2, 1.5) in 500 ms, yoyo, repeat 5.
const double _pulseLeg = 0.5;
const int _pulseLegs = 6;
const double _pulseGrowX = 0.2, _pulseGrowY = 0.5;

/// HTML `pulse-highlight`: a 1.5 s glow ring on the tool.
const double _toolPulse = 1.5;

/// TWEEN.Easing.Cubic.InOut.
double _cubicInOut(double t) {
  if (t < 0.5) return 4 * t * t * t;
  final u = 2 * t - 2;
  return 0.5 * u * u * u + 1;
}

// ------------------------------------------------------------- scene model

/// The HTML camera, always looking down −z (OrbitControls stay locked):
/// position (x, y, z); [k] is design px per world unit at the scale plane.
@immutable
class _Camera {
  const _Camera(this.x, this.y, this.z);

  /// The camera that shows world point (wx, wy) at stage point [at] with
  /// [k] px per unit.
  factory _Camera.place(double wx, double wy, Offset at, double k) => _Camera(
    wx - (at.dx - _stageCentre.dx) / k,
    wy + (at.dy - _stageCentre.dy) / k,
    _scaleZ + _focal / k,
  );

  /// HTML default: (-2, 0, 45).
  static const _Camera html = _Camera(_axisX, 0, 45);

  final double x;
  final double y;
  final double z;

  double get k => _focal / math.max(0.05, z - _scaleZ);

  Offset p(double wx, double wy) =>
      Offset(_stageCentre.dx + (wx - x) * k, _stageCentre.dy - (wy - y) * k);

  double worldY(double sy) => y + (_stageCentre.dy - sy) / k;

  /// TWEEN of camera.position.
  static _Camera lerp(_Camera a, _Camera b, double t) => _Camera(
    a.x + (b.x - a.x) * t,
    a.y + (b.y - a.y) * t,
    a.z + (b.z - a.z) * t,
  );
}

/// Where the thermometer is drawn for a camera: the HTML proportions, with
/// the scale strip (and the glass round it) widened when its numbers would
/// not fit at the stage's size, so they stay readable on phones.
@immutable
class _Geo {
  factory _Geo(_Camera cam, double fit) {
    final k = cam.k;
    final minFont = _numberMinDp / fit;
    var font = (k * _numberWorld)
        .clamp(minFont, math.max(minFont, _numberMaxPx))
        .toDouble();
    // Never taller than the gap between two numbered marks.
    font = math.min(font, 0.9 * 10 * _unitsPerC * k);
    final strip = math.max(_scaleWidth * k, font * _numberEm / _numberRoom);
    return _Geo._(cam, k, font, strip, cam.p(_axisX, 0).dx);
  }

  const _Geo._(this.cam, this.k, this.font, this.strip, this.axis);

  final _Camera cam;
  final double k;

  /// Scale-number font size (design px).
  final double font;

  /// Drawn width of the scale strip and the stage x of the axis.
  final double strip;
  final double axis;

  double get tubeHalf => strip * _glassRadius / _scaleWidth;
  double get bulbR => math.max(_bulbRadius * k, tubeHalf * _bulbOverTube);

  /// Half-width of the widest part (glass or bulb).
  double get body => math.max(tubeHalf, bulbR);

  double y(double c) => cam.p(_axisX, _yOf(c)).dy;
  double worldToY(double wy) => cam.p(_axisX, wy).dy;
  double valueAt(double sy) => _cOf(cam.worldY(sy));
  double get stripLeft => axis - strip / 2;
  double xAt(double fraction) => stripLeft + strip * fraction;

  /// Middle of the mark line for [c].
  Offset line(double c) => Offset(xAt((_minorFrom + _tickTo) / 2), y(c));

  /// Middle of the printed number for [c].
  Offset number(double c) => Offset(
    xAt(_numberFrom) + c.toStringAsFixed(0).length * font * _digitEm / 2,
    y(c),
  );
}

/// The two draggable tools.
enum _Tool { magnifier, zoom }

/// Draggable numbers: the glowing '-10 °C' / '110 °C', the '10' / '0' of
/// the zoomed scale and the '10 °C' difference.
enum _Chip { minus10, plus110, ten, zero, diff }

/// Drop boxes of the panels.
enum _Slot { low, high, val1, val2, divisions, eqTop }

/// All mutable simulation state; the painter reads it every frame.
class _Scene {
  int scenario = 0;

  /// 1–5 (HTML `State.step`); [_doneStep] once the conclusion is open.
  int step = 1;

  /// Ticker time in seconds.
  double time = 0;

  /// Stage scale (design px → dp) and the canvas UI boost.
  double fit = 1;
  double ui = 1;

  /// Free part of the stage (design px), the full-thermometer camera, the
  /// zoomed camera and the tool's home (set from the layout).
  Rect frame = _stageSafe;
  _Camera home = _Camera.html;
  _Camera zoom = _Camera.html;
  Offset toolHome = Offset.zero;

  /// Time the zoom tween started, or −1 (HTML TWEEN on camera.position).
  double zoomStart = -1;

  /// The dragged tool's position (null at home), drag state, grab offset,
  /// the moment it found its target (frozen there), hidden once used.
  Offset? toolAt;
  bool toolDragging = false;
  Offset grabOffset = Offset.zero;
  double foundAt = -1;
  bool toolHidden = false;

  // Scenario 1 (HTML State.s1).
  bool lowFound = false;
  bool lowPlaced = false;
  bool highFound = false;
  bool highPlaced = false;
  double rangeStart = -1;

  // Scenario 2 (HTML State.s2).
  bool tenPlaced = false;
  bool zeroPlaced = false;
  bool diffShown = false;
  final Set<int> counted = {};
  bool countDone = false;
  bool divided = false;
  bool leastShown = false;
  double precisionStart = -1;

  /// Step 5's 'Observe Conclusion' is enabled (HTML `#compare-btn`).
  bool conclusionReady = false;

  double get zoomT =>
      zoomStart < 0 ? 0 : ((time - zoomStart) / _zoomSeconds).clamp(0.0, 1.0);

  _Camera get camera {
    final t = zoomT;
    if (t <= 0) return home;
    if (t >= 1) return zoom;
    return _Camera.lerp(home, zoom, _cubicInOut(t));
  }

  _Geo get geo => _Geo(camera, fit);

  /// The tool on the stage right now.
  _Tool? get tool {
    if (toolHidden) return null;
    if (scenario == 0 && (step == 1 || step == 3)) return _Tool.magnifier;
    if (scenario == 1 && step == 1) return _Tool.zoom;
    return null;
  }

  Offset get toolPos => toolAt ?? toolHome;

  /// The lens shows the magnified scale while it is moved or holds a find.
  bool get lensLive => toolDragging || foundAt >= 0;

  // Read by the QA flow (integration_test/qa/flows) through the painter:
  // design-space positions with the current camera.

  Offset get toolPoint => toolPos;
  Offset numberPoint(double c) => geo.number(c);
  Offset linePoint(int c) => geo.line(c.toDouble());
  Offset get sectionPoint => Offset(geo.axis, geo.y(5));
  bool get zoomSettled => zoomStart >= 0 && time - zoomStart >= _zoomSeconds;
  int get countedLines => counted.length;
  double get rangeProgress =>
      rangeStart < 0 ? 0 : ((time - rangeStart) / _rangeSeconds).clamp(0, 1);

  /// HTML `resetScenarioState(sc)`: everything back to step 1.
  void load(int index) {
    scenario = index;
    step = 1;
    zoomStart = -1;
    toolAt = null;
    toolDragging = false;
    grabOffset = Offset.zero;
    foundAt = -1;
    toolHidden = false;
    lowFound = false;
    lowPlaced = false;
    highFound = false;
    highPlaced = false;
    rangeStart = -1;
    tenPlaced = false;
    zeroPlaced = false;
    diffShown = false;
    counted.clear();
    countDone = false;
    divided = false;
    leastShown = false;
    precisionStart = -1;
    conclusionReady = false;
  }
}

/// Where the scenario's panel sits on the canvas (dp): a card at the top
/// right, or (Scenario 2 on small screens with the sidebar collapsed) a
/// strip along the bottom.
@immutable
class _PanelLayout {
  const _PanelLayout.card({
    required this.width,
    required this.top,
    required this.right,
    required this.maxHeight,
  }) : strip = false,
       left = 0,
       bottom = 0,
       height = 0;

  const _PanelLayout.strip({
    required this.left,
    required this.right,
    required this.bottom,
    required this.height,
  }) : strip = true,
       width = 0,
       top = 0,
       maxHeight = height;

  final bool strip;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;
  final double maxHeight;
}

/// Pan recogniser that only joins the gesture arena when [canGrab] picks up
/// the tool at pointer-down (HTML `pointerdown` on `.drag-badge`), so every
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
    extends State<Ch7A3LaboratoryThermometersStructureAndCalibrationPage>
    with SingleTickerProviderStateMixin {
  // HTML `State.isCamLocked = true`: drags interact with the scene.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();
  late final Ticker _ticker;

  /// The panel layout of the last build (the stage frames the scene round
  /// it).
  _PanelLayout? _panel;

  /// Scrolls the panel card (when it is taller than the canvas allows) to
  /// 'Observe Conclusion' as it appears.
  final ScrollController _panelScroll = ScrollController();

  /// The last toast this lab showed (key and shown text), so it can be
  /// re-translated when the language changes while it is visible.
  String? _toastKey;
  String? _toastText;

  String _t(String key) => _lab.tr(_i18n, key);
  String _deg(int v) => labFormat(_t('deg_c'), {'v': v});
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
    _panelScroll.dispose();
    _cache.dispose();
    _lab
      ..removeListener(_onLabChanged)
      ..dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- animation

  /// HTML `animate()`: the tweens run off the ticker time; then a repaint of
  /// the canvas only.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _scene.time = now;
    _frame.value = now;
  }

  // ---------------------------------------------------------------- toasts

  /// HTML `showToast(msg)`. Error toasts play the shell's error tone; the
  /// others go with the HTML's own step sounds.
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

  /// HTML `changeScenario(sc)` (scenario selector), `enterLab()` and
  /// `resetApp()`: stops every timer and tween and rebuilds the scenario at
  /// step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// Runs [fn] after [delay] if the lab is still on [step] of the same
  /// scenario (HTML `setTimeout`; cancelled on scenario change or reset).
  void _later(Duration delay, int step, VoidCallback fn) {
    final s = _scene;
    final scenario = s.scenario;
    _lab.after(delay, () {
      if (!mounted || s.scenario != scenario || s.step != step) return;
      fn();
    });
  }

  /// HTML `checkMagGlassHover()` found the number: it glows, and 500 ms
  /// later the magnifier goes and the number becomes a draggable badge.
  void _found({required bool low}) {
    final s = _scene;
    _Sound.success.play();
    s
      ..toolDragging = false
      ..foundAt = s.time;
    if (low) {
      s.lowFound = true;
    } else {
      s.highFound = true;
    }
    final step = s.step;
    _later(_foundDelay, step, () {
      setState(() {
        s
          ..toolHidden = true
          ..toolAt = null
          ..foundAt = -1
          ..step = step + 1;
      });
      _toast('toast_drag_target');
    });
    setState(() {});
  }

  /// S1 step 2 done: '-10 °C' locked into 'Lowest Temperature'; the
  /// magnifier comes back for step 3.
  void _placeLow() {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      s
        ..lowPlaced = true
        ..step = 3
        ..toolHidden = false
        ..toolAt = null
        ..foundAt = -1;
    });
  }

  /// S1 step 4 done: '110 °C' locked in; the range bar rises (1.5 s) and
  /// then 'Observe Conclusion' is enabled (HTML `triggerS1HighlightRange`).
  void _placeHigh() {
    final s = _scene;
    _Sound.pop.play();
    _Sound.measure.play();
    setState(() {
      s
        ..highPlaced = true
        ..step = 5
        ..rangeStart = s.time;
    });
    _later(_rangeButtonDelay, 5, _enableConclusion);
  }

  /// The step 5 animation has played: 'Observe Conclusion' is enabled
  /// (and scrolled into view in the panel card).
  void _enableConclusion() {
    setState(() => _scene.conclusionReady = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A jump, not an animation: a scroll view ignores taps while it
      // animates.
      if (!mounted || !_panelScroll.hasClients) return;
      _panelScroll.jumpTo(_panelScroll.position.maxScrollExtent);
    });
  }

  /// HTML `checkZoomToolHover()`: the camera zooms onto 0–10 °C (1 s) and
  /// step 2 starts 1.2 s later with the '10' and '0' badges.
  void _startZoom() {
    final s = _scene;
    _Sound.success.play();
    s
      ..toolDragging = false
      ..toolHidden = true
      ..zoomStart = s.time;
    _later(_zoomStepDelay, 1, () {
      setState(() => s.step = 2);
      _toast('toast_drag_target');
    });
    setState(() {});
  }

  /// S2 step 2: a number in its box; with both placed the difference shows
  /// (HTML `checkS2CalcReady`: 500 ms, then step 3 after 1 s).
  void _placeNumber(_Chip chip) {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      if (chip == _Chip.ten) {
        s.tenPlaced = true;
      } else {
        s.zeroPlaced = true;
      }
    });
    if (!s.tenPlaced || !s.zeroPlaced) return;
    _later(_calcDelay, 2, () {
      _Sound.beep.play();
      setState(() => s.diffShown = true);
      _later(_calcStepDelay, 2, () {
        setState(() => s.step = 3);
        _toast('toast_click_divs');
      });
    });
  }

  /// S2 step 3: one line counted; the tenth completes the count (HTML:
  /// 500 ms, then step 4 after 1 s).
  void _countLine(int c) {
    final s = _scene;
    _Sound.click.play();
    setState(() => s.counted.add(c));
    if (s.counted.length < _divisions) return;
    _later(_countDelay, 3, () {
      _Sound.success.play();
      setState(() => s.countDone = true);
      _later(_countStepDelay, 3, () => setState(() => s.step = 4));
    });
  }

  /// S2 step 4: 10 °C / 10 divisions (HTML `runFinalCalculation`: the result
  /// after 1 s, step 5 after 1.5 s more, then the glowing division and,
  /// 1 s later, 'Observe Conclusion').
  void _divide() {
    final s = _scene;
    _Sound.beep.play();
    setState(() => s.divided = true);
    _later(_divideResultDelay, 4, () {
      _Sound.success.play();
      setState(() => s.leastShown = true);
      _later(_divideStepDelay, 4, () {
        _Sound.pop.play();
        setState(() {
          s
            ..step = 5
            ..precisionStart = s.time;
        });
        _later(_precisionButtonDelay, 5, _enableConclusion);
      });
    });
  }

  /// HTML `triggerConclusion()` ('Observe Conclusion').
  void _observeConclusion() {
    final s = _scene;
    if (!_lab.isLabActive || s.step != _stepCount || !s.conclusionReady) {
      return;
    }
    final index = s.scenario;
    setState(() {
      s
        ..step = _doneStep
        ..conclusionReady = false;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => index == 1 && _allDone
          ? _t('all_complete')
          : labFormat(_t('sc_complete'), {'n': index + 1}),
      body: () => index == 1 && _allDone
          ? '${_t('s2_summary')}\n\n${_t('all_complete_desc')}'
          : _t('s${index + 1}_summary'),
    );
  }

  /// The HTML's success modal ("Mastery Achieved!") once both scenarios are
  /// done; it also keeps Scenario 2's summary, which the HTML dropped.
  bool get _allDone => _lab.completedScenarios.length >= _scenarioCount;

  // ------------------------------------------------------- drag and drop

  /// The HTML `pointerdown` gate of each badge.
  bool _canDrag(_Chip chip) {
    final s = _scene;
    if (!_lab.isLabActive) return false;
    return switch (chip) {
      _Chip.minus10 => s.scenario == 0 && s.step == 2 && !s.lowPlaced,
      _Chip.plus110 => s.scenario == 0 && s.step == 4 && !s.highPlaced,
      _Chip.ten => s.scenario == 1 && s.step == 2 && !s.tenPlaced,
      _Chip.zero => s.scenario == 1 && s.step == 2 && !s.zeroPlaced,
      _Chip.diff => s.scenario == 1 && s.step == 4 && !s.divided,
    };
  }

  /// Boxes that take a drop now (a full box takes none).
  bool _accepts(_Slot slot) {
    final s = _scene;
    if (!_lab.isLabActive) return false;
    return switch (slot) {
      _Slot.low =>
        s.scenario == 0 && (s.step == 2 || s.step == 4) && !s.lowPlaced,
      _Slot.high =>
        s.scenario == 0 && (s.step == 2 || s.step == 4) && !s.highPlaced,
      _Slot.val1 => s.scenario == 1 && s.step == 2 && !s.tenPlaced,
      _Slot.val2 => s.scenario == 1 && s.step == 2 && !s.zeroPlaced,
      _Slot.divisions ||
      _Slot.eqTop => s.scenario == 1 && s.step == 4 && !s.divided,
    };
  }

  /// HTML `handleHTMLDrop`: each number has its own box. The HTML took the
  /// '0' in the first box ("0 − 10 = 10 °C"); a number in the wrong box is
  /// now refused with a toast.
  void _onDrop(_Slot slot, _Chip chip) {
    if (!_canDrag(chip)) return;
    switch (chip) {
      case _Chip.minus10:
        slot == _Slot.low
            ? _placeLow()
            : _toast('toast_drag_target', isError: true);
      case _Chip.plus110:
        slot == _Slot.high
            ? _placeHigh()
            : _toast('toast_drag_target', isError: true);
      case _Chip.ten:
        if (slot == _Slot.val1) {
          _placeNumber(chip);
        } else {
          _toast(
            slot == _Slot.val2 ? 'err_calc_order' : 'toast_drag_target',
            isError: true,
          );
        }
      case _Chip.zero:
        if (slot == _Slot.val2) {
          _placeNumber(chip);
        } else {
          _toast(
            slot == _Slot.val1 ? 'err_calc_order' : 'toast_drag_target',
            isError: true,
          );
        }
      case _Chip.diff:
        slot == _Slot.divisions || slot == _Slot.eqTop
            ? _divide()
            : _toast('err_divide', isError: true);
    }
  }

  /// A badge released away from every box goes back (HTML: revert
  /// position), now with the HTML's own hint as an error toast.
  void _onMissedDrop(_Chip chip) {
    if (!_canDrag(chip)) return;
    _toast(
      chip == _Chip.diff ? 'err_divide' : 'toast_drag_target',
      isError: true,
    );
  }

  // -------------------------------------------------------- tool gestures

  /// HTML `pointerdown` on the magnifier / zoom tool.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    final tool = s.tool;
    if (!_lab.isLabActive || tool == null || s.toolDragging) return false;
    if (s.foundAt >= 0 || s.zoomStart >= 0) return false;
    final at = s.toolPos;
    final size = tool == _Tool.magnifier
        ? _lensRadius * s.ui * _grabRadii
        : _zoomToolSize * s.ui * 0.6;
    final reach = math.max(size, _fingerDp / s.fit);
    if ((event.localPosition - at).distance > reach) return false;
    s
      ..toolDragging = true
      ..grabOffset = at - event.localPosition
      ..toolAt = at;
    return true;
  }

  /// HTML `pointermove`: the tool follows the finger; hover checks run.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (!s.toolDragging) return;
    final p = d.localPosition + s.grabOffset;
    final at = Offset(
      p.dx.clamp(0.0, _design.width),
      p.dy.clamp(0.0, _design.height),
    );
    s.toolAt = at;
    _checkHover(at);
  }

  /// HTML `pointerup`: an unused tool goes back home.
  void _release() {
    final s = _scene;
    if (!s.toolDragging) return;
    s.toolDragging = false;
    if (s.foundAt < 0 && s.zoomStart < 0) s.toolAt = null;
  }

  /// HTML `checkMagGlassHover()` / `checkZoomToolHover()`.
  void _checkHover(Offset at) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    final g = s.geo;
    final finger = _fingerDp / s.fit;
    if ((at.dx - g.axis).abs() > g.body + finger) return;
    final perC = _unitsPerC * g.k;
    if (s.scenario == 0) {
      final target = s.step == 1 && !s.lowFound
          ? _minC
          : (s.step == 3 && !s.highFound ? _maxC : null);
      if (target == null) return;
      final tolerance = math.max(_hoverC * perC, finger);
      if ((at.dy - g.y(target)).abs() <= tolerance) {
        _found(low: target == _minC);
      }
    } else if (s.step == 1 && s.zoomStart < 0) {
      final slack = math.max(_zoomSlackC * perC, finger);
      if (at.dy >= g.y(10) - slack && at.dy <= g.y(0) + slack) _startZoom();
    }
  }

  /// HTML `setup3DClickInteraction()`: S2 step 3 counts the line nearest
  /// the tap, once each, from 1 °C to the 10 °C mark.
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.step != 3) return;
    if (s.counted.length >= _divisions) return;
    final g = s.geo;
    final p = d.localPosition;
    if ((p.dx - g.axis).abs() > g.strip / 2 + _fingerDp / s.fit) return;
    final c = g.valueAt(p.dy).round();
    if (c < 1 || c > _divisions) {
      _toast('err_count_range', isError: true);
      return;
    }
    if (!s.counted.contains(c)) _countLine(c);
  }

  // --------------------------------------------------------------- framing

  /// Width of the canvas once the sidebar has finished moving.
  double _canvasWidth(double screenWidth) {
    if (!_lab.isSidebarOpen) return screenWidth;
    final min = math.max(180.0, screenWidth * 0.2);
    final max = math.max(min, screenWidth * 0.5);
    return screenWidth - (screenWidth * _lab.sidebarFraction).clamp(min, max);
  }

  /// Bottom of the free canvas: above the HUD chip while the sidebar is
  /// open (it is drawn over the overlays), else the bottom margin.
  double _floor(double height, EdgeInsets pad, double ls) => _lab.isSidebarOpen
      ? height - (_hudBottom + pad.bottom + _hudBand * ls) - _hudGap
      : height - 8 - pad.bottom;

  _PanelLayout _panelLayout(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final ls = context.labScale;
    final open = _lab.isSidebarOpen;
    final right = labOverlayInsets(context, _lab).right;
    final floor = _floor(screen.height, pad, ls);
    if (_scene.scenario == 0) {
      // HTML `#s1-panel`: top right, below the toast.
      final top = _toastTop + pad.top + _toastBand * ls + 4;
      return _PanelLayout.card(
        width: _s1PanelWidth * ls,
        top: top,
        right: right,
        maxHeight: math.max(_minTouch * 2, floor - top),
      );
    }
    // HTML `#s2-panel`: top right; a strip at the bottom when the zoomed
    // scale would be too narrow beside it.
    final width = _s2PanelWidth * ls;
    final sceneLeft = open
        ? 8.0
        : _missionCardLeft +
              pad.left +
              _missionCardWidth(screen, ls) +
              _cardGap;
    final room =
        _canvasWidth(screen.width) - right - width - _cardGap - sceneLeft;
    if (room >= _zoomRoomMin) {
      // Below the toast when the card fits there, else as low as it fits.
      final below = _toastTop + pad.top + _toastBand * ls + 4;
      final tall = _calcCardHeight(ls);
      final top = floor - tall >= below
          ? below
          : math.max(8 + pad.top, floor - tall);
      return _PanelLayout.card(
        width: width,
        top: top,
        right: right,
        maxHeight: math.max(_minTouch * 2, floor - top),
      );
    }
    return _PanelLayout.strip(
      left: 8 + (open ? 0 : pad.left),
      right: right,
      bottom: screen.height - floor,
      height: _s2StripHeight * ls,
    );
  }

  /// Height of the calculator card (dp) at UI scale [s], without the step 5
  /// button (see [_calcPanel]).
  double _calcCardHeight(double s) {
    final title = _sectionFont * s * 1.4 + _calcGap * s;
    final inset = 2 * _insetPad * s + 2;
    final row = math.max(_calcRowH * s, _calcRowMin);
    final fraction = math.max(_fractionH * s, _fractionMin);
    final diff = title + inset + row;
    final counter = title + inset + _tickBoxH * s + _calcGap * s + row;
    final least = title + inset + 2 * fraction + 2 + 6 * s;
    return 2 * _calcPad * s +
        2 +
        diff +
        counter +
        least +
        2 * (2 * _dividerGap * s + 1);
  }

  /// Fits the scene into the part of the canvas no card covers: the toast
  /// band, the HUD chip (sidebar open), the floating mission card (sidebar
  /// collapsed), the panel and the tool column.
  void _frameScene(BuildContext context, Size canvas) {
    final s = _scene;
    final screen = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final ls = context.labScale;
    final panel = _panel ?? _panelLayout(context);
    final toolLeft = canvas.width - labOverlayInsets(context, _lab).right;
    var left = 8.0;
    if (!_lab.isSidebarOpen && _lab.isLabActive) {
      final sidebarNow = math.max(0.0, screen.width - canvas.width);
      final cardRight =
          _missionCardLeft +
          pad.left +
          _missionCardWidth(screen, ls) -
          sidebarNow;
      left = math.max(left + pad.left, cardRight + _cardGap);
    }
    final top = _toastTop + pad.top + _toastBand * ls;
    var bottom = _floor(canvas.height, pad, ls);
    double right;
    if (panel.strip) {
      right = toolLeft - 8;
      bottom = math.min(
        bottom,
        canvas.height - panel.bottom - panel.height - _cardGap,
      );
    } else {
      right = canvas.width - panel.right - panel.width - _cardGap;
    }
    final fit = s.fit;
    final ox = (canvas.width - _design.width * fit) / 2;
    final oy = (canvas.height - _design.height * fit) / 2;
    var r = Rect.fromLTRB(
      (left - ox) / fit,
      (top - oy) / fit,
      (right - ox) / fit,
      (bottom - oy) / fit,
    ).intersect(_stageSafe);
    if (r.width < _minFrame || r.height < _minFrame) r = _stageSafe;
    s.frame = r;
    _fitHome(r);
    s.zoom = _fitZoom(r);
  }

  /// The full thermometer (bulb to the 110 mark) as tall as the free area
  /// allows, with the tool's home beside it.
  void _fitHome(Rect r) {
    final s = _scene;
    final yTop = _yOf(_maxC);
    // The '110 °C' badge sits on the top mark; the bulb (drawn at least as
    // wide as the glass) hangs below its centre.
    final padTop = _badgeHeight * s.ui / 2 + 4;
    var k = math.max(1.0, r.height / (yTop - _bulbY + _bulbRadius));
    var g = _Geo(_Camera.place(_axisX, yTop, Offset.zero, k), s.fit);
    for (var i = 0; i < 3; i++) {
      k = math.max(
        1.0,
        (r.height - padTop - _homePadBottom - g.bulbR) / (yTop - _bulbY),
      );
      g = _Geo(_Camera.place(_axisX, yTop, Offset.zero, k), s.fit);
    }
    final magnifier = s.scenario == 0;
    final toolWidth = magnifier
        ? _lensRadius * s.ui * _lensWidth
        : _zoomToolSize * s.ui;
    final toolLead = magnifier ? _lensRadius * s.ui : toolWidth / 2;
    final group = 2 * g.body + _toolGap * s.ui + toolWidth;
    final axis = r.width >= group
        ? r.left + (r.width - group) / 2 + g.body
        : r.left + g.body;
    final cam = _Camera.place(_axisX, yTop, Offset(axis, r.top + padTop), k);
    final toolX = math.min(
      axis + g.body + _toolGap * s.ui + toolLead,
      r.right - (toolWidth - toolLead),
    );
    final toolY = cam
        .p(_axisX, _yOf(magnifier ? _magnifierHomeC : _zoomHomeC))
        .dy;
    s
      ..home = cam
      ..toolHome = Offset(
        toolX.clamp(_stageSafe.left, _stageSafe.right),
        toolY.clamp(_stageSafe.top, _stageSafe.bottom),
      );
  }

  /// HTML zoom: the camera moves in front of the 0–10 °C section (the HTML
  /// went to z 8, which shows −8 °C to 18 °C; this view keeps the ten
  /// divisions as large as the free area allows, for fingers).
  _Camera _fitZoom(Rect r) {
    final yTop = _yOf(_divisions + _zoomMarginC);
    final yBottom = _yOf(-_zoomMarginC);
    final kH = (r.height - 2 * _zoomPad) / (yTop - yBottom);
    final kW = (r.width - 2 * _zoomPad) / _scaleWidth;
    final k = math.max(1.0, math.min(kH, kW));
    return _Camera.place(_axisX, (yTop + yBottom) / 2, r.center, k);
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final sc = _scene.scenario;
        final step = _scene.step;
        final panel = _panelLayout(context);
        _panel = panel;
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          // HTML `#hud-instruction` (the sN hud lines); gone once the
          // conclusion is open.
          hud: step <= _stepCount ? _t('s${sc + 1}_hud_$step') : null,
          showHud: step <= _stepCount,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$step'),
            steps: data.steps,
            current: step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
          overlays: _overlays(panel, s),
          stage: _buildStage(),
        );
      },
    );
  }

  /// HTML `#compare-btn-container` ('Observe Conclusion'): shown on step 5,
  /// enabled once the animation has played.
  List<LabAction> _actions() {
    final s = _scene;
    if (!_lab.isLabActive || s.step != _stepCount) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.blue600,
        foreground: _Colors.white,
        enabled: s.conclusionReady,
        highlight: true,
        // The popup plays the HTML's success tone.
        silent: true,
        onTap: _observeConclusion,
      ),
    ];
  }

  List<Widget> _overlays(_PanelLayout panel, double s) {
    if (!_lab.isLabActive) return const [];
    if (_scene.scenario == 0) {
      return [
        Positioned(
          key: const ValueKey('ch7a3-panel-range'),
          top: panel.top,
          right: panel.right,
          width: panel.width,
          child: _rangePanel(s, panel.maxHeight),
        ),
      ];
    }
    if (!panel.strip) {
      return [
        Positioned(
          key: const ValueKey('ch7a3-panel-calc'),
          top: panel.top,
          right: panel.right,
          width: panel.width,
          child: _calcPanel(s, strip: false, maxHeight: panel.maxHeight),
        ),
      ];
    }
    return [
      Positioned(
        key: const ValueKey('ch7a3-panel-calc-strip'),
        left: panel.left,
        right: panel.right,
        bottom: panel.bottom,
        height: panel.height,
        child: _calcPanel(s, strip: true, maxHeight: panel.height),
      ),
    ];
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final s = _scene;
        final canvas = box.biggest;
        final fit = math.min(
          canvas.width / _design.width,
          canvas.height / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          s
            ..fit = fit
            ..ui = (_uiFullScale / fit).clamp(1.0, _uiMaxBoost);
          _frameScene(context, canvas);
        }
        return LabStage(
          designSize: _design,
          child: Stack(
            children: [
              Positioned.fill(
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags and taps on the scene are not screen-reader
                  // actions; the scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TapGestureRecognizer
                        >(
                          () => TapGestureRecognizer(debugOwner: this),
                          (r) => r.onTapUp = _onTapUp,
                        ),
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
                            ..onUpdate = _onDragUpdate
                            ..onEnd = ((_) => _release())
                            ..onCancel = _release,
                        ),
                  },
                  child: Semantics(
                    image: true,
                    label: _t('scene_desc'),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: _design,
                        painter: _ScenePainter(
                          scene: s,
                          cache: _cache,
                          repaint: _frame,
                          palette: _lab.palette,
                          showLabels: _lab.showLabels,
                          bulbLabel: _t('lbl_bulb'),
                          scaleLabel: _t('lbl_scale'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ..._stageBadges(),
            ],
          ),
        );
      },
    );
  }

  /// The glowing numbers on the scale (HTML `#badge-minus10`, `#badge-110`,
  /// `#badge-10`, `#badge-0`), each on its printed number.
  List<Widget> _stageBadges() {
    final s = _scene;
    if (!_lab.isLabActive) return const [];
    final g = s.geo;
    return [
      if (s.scenario == 0 && s.step == 2 && !s.lowPlaced)
        _stageBadge(_Chip.minus10, g.number(_minC), _deg(-10), _Colors.blue600),
      if (s.scenario == 0 && s.step == 4 && !s.highPlaced)
        _stageBadge(_Chip.plus110, g.number(_maxC), _deg(110), _Colors.red500),
      if (s.scenario == 1 && s.step == 2 && !s.tenPlaced)
        _stageBadge(_Chip.ten, g.number(10), _deg(10), _Colors.slate700),
      if (s.scenario == 1 && s.step == 2 && !s.zeroPlaced)
        _stageBadge(_Chip.zero, g.number(0), _deg(0), _Colors.slate700),
    ];
  }

  /// A badge beside the glass at its mark when the free area has room
  /// (so the glowing mark stays visible), else on its printed number.
  Widget _stageBadge(_Chip chip, Offset number, String text, Color color) {
    final s = _scene;
    final ui = s.ui;
    final w = math.max(
      text.length * _badgeEm * _badgeFont * ui + 2 * _badgePadX * ui + 8,
      _minTouch / s.fit,
    );
    final h = math.max(_badgeHeight * ui, _minTouch / s.fit);
    final g = s.geo;
    final beside = g.axis + g.body + _toolGap * ui + w / 2;
    final centre = beside + w / 2 <= s.frame.right
        ? Offset(beside, number.dy)
        : number;
    final c = Offset(
      centre.dx.clamp(w / 2, _design.width - w / 2),
      centre.dy.clamp(h / 2, _design.height - h / 2),
    );
    final view = _ChipView(text: text, color: color, scale: ui);
    return Positioned(
      left: c.dx - w / 2,
      top: c.dy - h / 2,
      width: w,
      height: h,
      child: Draggable<_Chip>(
        key: ValueKey('ch7a3-badge-${chip.name}'),
        data: chip,
        maxSimultaneousDrags: _canDrag(chip) ? 1 : 0,
        hitTestBehavior: HitTestBehavior.opaque,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDraggableCanceled: (_, _) => _onMissedDrop(chip),
        // Drawn at the stage's scale (and zoom), centred on the finger.
        feedback: Builder(
          builder: (_) => _feedback(
            view,
            scale: s.fit * _lab.transform.value.getMaxScaleOnAxis(),
          ),
        ),
        childWhenDragging: const SizedBox.expand(),
        child: Center(child: view),
      ),
    );
  }

  /// A badge under the finger while it is dragged.
  Widget _feedback(Widget chip, {double scale = 1}) => FractionalTranslation(
    translation: const Offset(-0.5, -0.5),
    child: Material(
      type: MaterialType.transparency,
      child: Transform.scale(scale: scale, child: chip),
    ),
  );

  // ---------------------------------------------------------------- panels

  /// HTML `#s1-panel` ('Find Range': the two drop boxes).
  Widget _rangePanel(double s, double maxHeight) {
    final p = _lab.palette;
    final sc = _scene;
    final boxH = math.max(46 * s, 44.0);
    final pad = 12 * s;
    Widget label(String text) => Text(
      text.toUpperCase(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: p.textMuted,
        fontSize: 10 * s,
        fontWeight: FontWeight.w800,
        letterSpacing: labLetterSpacing(text, 0.6),
      ),
    );
    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(pad),
      radius: 16,
      borderColor: _Colors.blue500.withValues(alpha: 0.35),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, maxHeight - 2 * pad - 2),
        ),
        child: SingleChildScrollView(
          controller: _panelScroll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _panelTitle(p, s, Icons.straighten, _t('find_range')),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 8 * s),
                color: p.cardBorder,
              ),
              label(_t('lowest_temp')),
              SizedBox(height: 5 * s),
              _DropBox(
                slot: _Slot.low,
                palette: p,
                scale: s,
                height: boxH,
                accepting: _accepts(_Slot.low),
                onDrop: _onDrop,
                content: sc.lowPlaced
                    ? _ChipView(
                        text: _deg(-10),
                        color: _Colors.blue600,
                        scale: s * 0.85,
                      )
                    : null,
              ),
              SizedBox(height: 10 * s),
              label(_t('highest_temp')),
              SizedBox(height: 5 * s),
              _DropBox(
                slot: _Slot.high,
                palette: p,
                scale: s,
                height: boxH,
                accepting: _accepts(_Slot.high),
                onDrop: _onDrop,
                content: sc.highPlaced
                    ? _ChipView(
                        text: _deg(110),
                        color: _Colors.red500,
                        scale: s * 0.85,
                      )
                    : null,
              ),
              ..._panelButton(s),
            ],
          ),
        ),
      ),
    );
  }

  /// 'Observe Conclusion' in the panel card as well, where the HTML showed
  /// it on the canvas (the sidebar's copy can be below the fold on phones).
  List<Widget> _panelButton(double s) {
    final actions = _actions();
    if (actions.isEmpty) return const [];
    return [
      SizedBox(height: 10 * s),
      LabActionButton(action: actions.first, scale: s, dense: true),
    ];
  }

  Widget _panelTitle(LabPalette p, double s, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15 * s, color: p.ink(_Colors.blue500)),
        SizedBox(width: 6 * s),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  /// HTML `#s2-panel`: Difference Calculator, Division Counter and Least
  /// Count, stacked (card) or side by side ([strip]).
  Widget _calcPanel(
    double s, {
    required bool strip,
    required double maxHeight,
  }) {
    final p = _lab.palette;
    final sc = _scene;
    final step = sc.scenario == 1 ? sc.step : 0;
    final boxH = math.max(_calcRowH * s, _calcRowMin);
    final fractionH = math.max(_fractionH * s, _fractionMin);
    final pad = _calcPad * s;

    final diff = _section(
      p,
      s,
      Icons.calculate,
      _t('diff_calc'),
      active: step >= 2,
      child: Row(
        children: [
          Expanded(
            child: _DropBox(
              slot: _Slot.val1,
              palette: p,
              scale: s,
              height: boxH,
              accepting: _accepts(_Slot.val1),
              onDrop: _onDrop,
              content: sc.tenPlaced
                  ? _ChipView(text: _deg(10), color: _Colors.slate700, scale: s)
                  : null,
            ),
          ),
          _operator(p, s, '−'),
          Expanded(
            child: _DropBox(
              slot: _Slot.val2,
              palette: p,
              scale: s,
              height: boxH,
              accepting: _accepts(_Slot.val2),
              onDrop: _onDrop,
              content: sc.zeroPlaced
                  ? _ChipView(text: _deg(0), color: _Colors.slate700, scale: s)
                  : null,
            ),
          ),
          _operator(p, s, '='),
          SizedBox(width: 62 * s, child: _diffResult(p, s, boxH)),
        ],
      ),
    );

    final counter = _section(
      p,
      s,
      Icons.format_list_numbered,
      _t('div_counter'),
      active: step >= 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scales down in a narrow strip section (e.g. while the sidebar
          // is still closing).
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _divisions; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 11 * s,
                    height: _tickBoxH * s,
                    margin: EdgeInsets.symmetric(horizontal: 1.5 * s),
                    decoration: BoxDecoration(
                      color: i < sc.counted.length
                          ? _Colors.emerald500
                          : (p.isDark ? _Colors.slate700 : _Colors.slate300),
                      borderRadius: BorderRadius.circular(3 * s),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: _calcGap * s),
          _divisionsSlot(p, s, boxH),
        ],
      ),
    );

    final least = _section(
      p,
      s,
      Icons.drag_handle,
      _t('least_count_calc'),
      active: step >= 4,
      iconColor: _Colors.blue500,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DropBox(
                  slot: _Slot.eqTop,
                  palette: p,
                  scale: s,
                  height: fractionH,
                  accepting: _accepts(_Slot.eqTop),
                  onDrop: _onDrop,
                  content: sc.divided
                      ? _PopIn(
                          child: _ChipView(
                            text: _deg(10),
                            color: _Colors.emerald500,
                            scale: s * 0.8,
                          ),
                        )
                      : null,
                ),
                Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(vertical: 3 * s),
                  color: p.isDark ? _Colors.slate500 : _Colors.slate400,
                ),
                _DropBox(
                  palette: p,
                  scale: s,
                  height: fractionH,
                  accepting: false,
                  onDrop: _onDrop,
                  content: sc.divided
                      ? _PopIn(
                          child: _ChipView(
                            text: labFormat(_t('n_divisions'), {
                              'n': _divisions,
                            }),
                            color: _Colors.emerald500,
                            scale: s * 0.8,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          _operator(p, s, '='),
          _ResultBox(
            key: const ValueKey('ch7a3-res-eq'),
            text: sc.leastShown ? _deg(1) : '?',
            filled: sc.leastShown,
            fill: _Colors.blue600,
            accent: _Colors.blue500,
            palette: p,
            scale: s,
            width: 50 * s,
            height: 50 * s,
            boost: 1.2,
          ),
        ],
      ),
    );

    Widget divider({required bool vertical}) => Container(
      width: vertical ? 1 : null,
      height: vertical ? null : 1,
      margin: vertical
          ? EdgeInsets.symmetric(horizontal: _dividerGap * s)
          : EdgeInsets.symmetric(vertical: _dividerGap * s),
      color: p.cardBorder,
    );

    final Widget body;
    if (strip) {
      // Side by side; each section scales down rather than overflow.
      Widget fitted(Widget section) => Expanded(
        child: LayoutBuilder(
          builder: (context, c) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: math.max(c.maxWidth, _stripSectionMin * s),
              child: section,
            ),
          ),
        ),
      );
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fitted(diff),
          divider(vertical: true),
          fitted(counter),
          divider(vertical: true),
          fitted(least),
        ],
      );
    } else {
      body = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, maxHeight - 2 * pad - 2),
        ),
        child: SingleChildScrollView(
          controller: _panelScroll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              diff,
              divider(vertical: false),
              counter,
              divider(vertical: false),
              least,
              ..._panelButton(s),
            ],
          ),
        ),
      );
    }
    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(pad),
      radius: 16,
      borderColor: _Colors.emerald500.withValues(alpha: 0.35),
      child: body,
    );
  }

  /// One calculator section: a title and an inset row, dimmed until its
  /// step (HTML `opacity-30`, 300 ms).
  Widget _section(
    LabPalette p,
    double s,
    IconData icon,
    String title, {
    required bool active,
    required Widget child,
    Color iconColor = _Colors.emerald500,
  }) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 13 * s, color: p.ink(iconColor)),
              SizedBox(width: 5 * s),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.textStrong,
                    fontSize: _sectionFont * s,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _calcGap * s),
          Container(
            padding: EdgeInsets.all(_insetPad * s),
            decoration: BoxDecoration(
              color: p.isDark ? _Colors.insetDark : _Colors.slate100,
              borderRadius: BorderRadius.circular(10 * s),
              border: Border.all(color: p.cardBorder),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _operator(LabPalette p, double s, String symbol) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 4 * s),
    child: Text(
      symbol,
      style: TextStyle(
        color: _Colors.slate400,
        fontSize: 16 * s,
        fontWeight: FontWeight.w900,
      ),
    ),
  );

  /// HTML `#res-diff-slot`; in step 4 it is the '10 °C' badge to drag.
  Widget _diffResult(LabPalette p, double s, double height) {
    final sc = _scene;
    final draggable = _canDrag(_Chip.diff);
    final box = _ResultBox(
      key: const ValueKey('ch7a3-res-diff'),
      text: sc.diffShown ? _deg(10) : '?',
      filled: sc.diffShown,
      fill: _Colors.emerald500,
      accent: _Colors.emerald500,
      palette: p,
      scale: s,
      height: height,
      boost: 1.08,
      glow: draggable,
    );
    if (!draggable) return box;
    return Draggable<_Chip>(
      key: const ValueKey('ch7a3-badge-diff'),
      data: _Chip.diff,
      hitTestBehavior: HitTestBehavior.opaque,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDraggableCanceled: (_, _) => _onMissedDrop(_Chip.diff),
      feedback: _feedback(
        _ChipView(text: _deg(10), color: _Colors.emerald500, scale: s),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: box),
      child: box,
    );
  }

  /// HTML `#res-div-slot` ("n Divisions"); in step 4 the drop target for
  /// the '10 °C' badge.
  Widget _divisionsSlot(LabPalette p, double s, double height) {
    final sc = _scene;
    final accepting = _accepts(_Slot.divisions);
    return DragTarget<_Chip>(
      key: const ValueKey('ch7a3-drop-divisions'),
      onWillAcceptWithDetails: (_) => accepting,
      onAcceptWithDetails: (d) => _onDrop(_Slot.divisions, d.data),
      builder: (context, candidates, _) => _ResultBox(
        text: labFormat(_t('n_divisions'), {'n': sc.counted.length}),
        filled: sc.countDone,
        fill: _Colors.emerald500,
        accent: _Colors.emerald500,
        palette: p,
        scale: s,
        height: height,
        boost: 1.04,
        glow: accepting && candidates.isNotEmpty,
      ),
    );
  }
}

/// A badge (HTML `.drag-badge`: white bold number, white border). Needs no
/// lab theme, so it also serves as drag feedback.
class _ChipView extends StatelessWidget {
  const _ChipView({
    required this.text,
    required this.color,
    required this.scale,
  });

  final String text;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _badgePadX * scale,
        vertical: _badgePadY * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: _Colors.chipBorder, width: 2 * scale),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: _Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: _badgeFont * scale,
          height: 1.15,
        ),
      ),
    );
  }
}

/// HTML `.drop-target`: a dashed box, green on hover, solid emerald with a
/// glow once it holds its badge. Without a [slot] it only shows [content].
class _DropBox extends StatelessWidget {
  const _DropBox({
    this.slot,
    required this.palette,
    required this.scale,
    required this.height,
    required this.accepting,
    required this.onDrop,
    this.content,
  });

  final _Slot? slot;
  final LabPalette palette;
  final double scale;
  final double height;
  final bool accepting;
  final void Function(_Slot slot, _Chip chip) onDrop;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final slot = this.slot;
    if (slot == null) return _box(hover: false);
    return DragTarget<_Chip>(
      key: ValueKey('ch7a3-drop-${slot.name}'),
      onWillAcceptWithDetails: (_) => accepting,
      onAcceptWithDetails: (d) => onDrop(slot, d.data),
      builder: (context, candidates, _) =>
          _box(hover: accepting && candidates.isNotEmpty),
    );
  }

  Widget _box({required bool hover}) {
    final p = palette;
    final filled = content != null;
    final radius = 10 * scale;
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      alignment: Alignment.center,
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: filled || hover
            ? _Colors.emerald500.withValues(alpha: 0.2)
            : (p.isDark ? _Colors.slate800 : _Colors.slate100).withValues(
                alpha: 0.5,
              ),
        borderRadius: BorderRadius.circular(radius),
        border: filled || hover
            ? Border.all(color: _Colors.emerald500, width: 2)
            : null,
        boxShadow: filled
            ? [
                BoxShadow(
                  color: _Colors.emerald500.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: filled ? FittedBox(fit: BoxFit.scaleDown, child: content) : null,
    );
    if (filled || hover) return box;
    return CustomPaint(
      foregroundPainter: _DashedBorder(
        color: p.isDark ? _Colors.slate600 : _Colors.slate400,
        radius: radius,
      ),
      child: box,
    );
  }
}

/// The dashed outline of an empty drop box (HTML `border-dashed`).
class _DashedBorder extends CustomPainter {
  _DashedBorder({required this.color, required this.radius});

  final Color color;
  final double radius;
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          Radius.circular(radius),
        ),
      );
    labDashedPath(canvas, path, _paint..color = color, dash: 6, gap: 4);
  }

  @override
  bool shouldRepaint(covariant _DashedBorder old) =>
      old.color != color || old.radius != radius;
}

/// A calculator result: '?' until it is known, then filled and enlarged
/// (HTML `scale-110` / `scale-125`).
class _ResultBox extends StatelessWidget {
  const _ResultBox({
    super.key,
    required this.text,
    required this.filled,
    required this.fill,
    required this.accent,
    required this.palette,
    required this.scale,
    required this.height,
    this.width,
    this.boost = 1.1,
    this.glow = false,
  });

  final String text;
  final bool filled;
  final Color fill;
  final Color accent;
  final LabPalette palette;
  final double scale;
  final double height;
  final double? width;
  final double boost;

  /// Pulses as the badge to drag (or a box under a dragged badge).
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return AnimatedScale(
      scale: filled ? boost : 1,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 4 * scale),
        decoration: BoxDecoration(
          color: filled
              ? fill
              : (p.isDark ? _Colors.slate900 : _Colors.slate200),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(
            color: glow
                ? _Colors.white
                : (filled ? fill : accent.withValues(alpha: 0.6)),
            width: glow ? 2.5 : 1.5,
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.7),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              color: filled ? _Colors.white : p.ink(accent),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// The badges entering the Least Count fraction ("an animation shows the
/// calculation").
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: child,
    );
  }
}

/// HTML teacher board "Observation Step": one card per step; the current
/// step is open with its task and action, done steps show a tick and open
/// to show their result too, future steps stay closed. (The HTML let every
/// step open, which gave the results away before the learner found them.)
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
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
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
    final tone = current
        ? p.ink(_Colors.blue500)
        : (past ? p.info : p.textMuted);
    final border = current
        ? _Colors.blue500
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
                              ? _Colors.blue500
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? _Colors.blue300
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
                                      ? _Colors.white
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

/// Scene label chips (design px at the canvas UI scale).
const double _labelPx = 12;
const double _labelPadX = 8, _labelPadY = 3;
const double _labelGap = 10;

/// Paints the HTML Three.js scene: the laboratory thermometer (glass tube,
/// top ring, red bulb, the scale strip with its marks and numbers), the
/// glow boxes, the range bar, the counted lines, the glowing division, the
/// scene labels and the magnifying glass (with its magnified view) or the
/// zoom tool.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.bulbLabel,
    required this.scaleLabel,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final LabPalette palette;
  final bool showLabels;
  final String bulbLabel;
  final String scaleLabel;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Path _path = Path();

  late Canvas _c;

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    final s = scene;
    final g = s.geo;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(labBleed(size), _fill);
    if (showLabels && s.zoomT <= 0) _labels(g);
    _thermometer(g);
    switch (s.tool) {
      case _Tool.magnifier:
        _magnifier(g, s.toolPos);
      case _Tool.zoom:
        _zoomTool(s.toolPos);
      case null:
        break;
    }
  }

  // ------------------------------------------------------------ thermometer

  void _thermometer(_Geo g) {
    final s = scene;
    final axis = g.axis;
    final th = g.tubeHalf;
    final top = g.worldToY(_glassTop);
    final bottom = g.worldToY(_glassBottom);
    final glass = RRect.fromRectAndCorners(
      Rect.fromLTRB(axis - th, top, axis + th, bottom),
      topLeft: Radius.circular(th),
      topRight: Radius.circular(th),
    );
    // Glass (MeshPhysicalMaterial, transmission 0.9): faintly visible.
    _fill
      ..shader = null
      ..color = (palette.isDark ? _Colors.white : _Colors.slate400).withValues(
        alpha: 0.1,
      );
    _c.drawRRect(glass, _fill);

    // The liquid stub between the bulb and the scale.
    final scaleBottom = g.worldToY(_scaleBottom);
    final bulb = g.cam.p(_axisX, _bulbY);
    final cap = math.max(
      _capillaryRadius * g.k,
      th * _capillaryRadius / _glassRadius,
    );
    _fill.color = _Colors.red500;
    _c.drawRect(
      Rect.fromLTRB(axis - cap, scaleBottom - 2, axis + cap, bulb.dy),
      _fill,
    );

    // The scale strip (HTML texture: #f8fafc, marks #0f172a).
    final strip = Rect.fromLTRB(
      g.stripLeft,
      g.worldToY(_scaleTop),
      g.stripLeft + g.strip,
      scaleBottom,
    );
    _fill.color = _Colors.slate50;
    _c.drawRect(strip, _fill);
    _marks(g, strip);

    // Highlights.
    if (s.scenario == 0) {
      if (s.lowFound && s.step <= 2) _glow(g, _minC);
      if (s.highFound && s.step <= 4) _glow(g, _maxC);
      final range = s.rangeProgress;
      if (s.rangeStart >= 0 && range > 0) {
        // HTML highlightBar: grows up from -10 °C (1.5 s, linear).
        final w = g.strip * _barWidth;
        _fill.color = _Colors.blue500.withValues(alpha: 0.4);
        _c.drawRect(
          Rect.fromLTRB(
            axis - w / 2,
            g.y(_minC + (_maxC - _minC) * range),
            axis + w / 2,
            g.y(_minC),
          ),
          _fill,
        );
      }
    } else {
      if (s.step >= 3 && s.step <= 4) {
        // Over the marks only, so the numbers stay readable.
        final left = g.xAt(_countedFrom), right = g.xAt(_countedTo);
        final h = math.max(_countedHeight * g.k, 3.0);
        _fill.color = _Colors.green400.withValues(alpha: 0.8);
        for (final c in s.counted) {
          final y = g.y(c.toDouble());
          _c.drawRect(Rect.fromLTRB(left, y - h / 2, right, y + h / 2), _fill);
        }
      }
      if (s.precisionStart >= 0) _division(g);
    }

    // Glass front: outline and a highlight down the left side.
    _stroke
      ..strokeWidth = 1.2
      ..color = (palette.isDark ? _Colors.white : _Colors.slate500).withValues(
        alpha: 0.45,
      );
    _c.drawRRect(glass, _stroke);
    _stroke
      ..strokeWidth = math.max(1.5, th * 0.12)
      ..color = _Colors.white.withValues(alpha: 0.22);
    _c.drawLine(
      Offset(axis - th * 0.78, top + th),
      Offset(axis - th * 0.78, bottom - th * 0.3),
      _stroke,
    );

    // Red bulb (MeshStandardMaterial 0xef4444).
    labSphere(_c, bulb, g.bulbR, _Colors.red500);

    // Top ring (TorusGeometry, 0x94a3b8).
    final ringScale = th / _glassRadius;
    _stroke
      ..strokeWidth = math.max(1.5, 2 * _ringTube * ringScale)
      ..color = _Colors.slate400;
    _c.drawCircle(g.cam.p(_axisX, _ringY), _ringRadius * ringScale, _stroke);
  }

  /// HTML texture marks: every degree, longer every 5 °C, longest with a
  /// number every 10 °C. Only the marks inside the clip are drawn.
  void _marks(_Geo g, Rect strip) {
    final clip = _c.getLocalClipBounds();
    final lo = math.max(_minC, g.valueAt(clip.bottom).floorToDouble() - 1);
    final hi = math.min(_maxC, g.valueAt(clip.top).ceilToDouble() + 1);
    final xTo = g.xAt(_tickTo);
    _stroke.color = _Colors.slate900;
    for (var c = lo.toInt(); c <= hi.toInt(); c++) {
      final y = g.y(c.toDouble());
      final double from;
      if (c % 10 == 0) {
        from = _majorFrom;
        _stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = math.max(_majorLine * g.k, _majorMinPx);
      } else if (c % 5 == 0) {
        from = _fiveFrom;
        _stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = math.max(_fiveLine * g.k, _fiveMinPx);
      } else {
        from = _minorFrom;
        _stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = math.max(_minorLine * g.k, _minorMinPx);
      }
      _c.drawLine(Offset(g.xAt(from), y), Offset(xTo, y), _stroke);
      if (c % 10 == 0) {
        final tp = cache.number(c);
        final k = g.font / _numberRefPx;
        _c
          ..save()
          ..translate(g.xAt(_numberFrom), y - tp.height * k / 2)
          ..scale(k);
        tp.paint(_c, Offset.zero);
        _c.restore();
      }
    }
    _stroke.strokeCap = StrokeCap.round;
  }

  /// HTML glow boxes over -10 °C / 110 °C (0x4ade80, opacity 0.6).
  void _glow(_Geo g, double c) {
    final h = math.max(_glowHeight * g.k, g.font * 1.3);
    _fill.color = _Colors.green400.withValues(alpha: 0.6);
    _c.drawRect(
      Rect.fromCenter(
        center: Offset(g.axis, g.y(c)),
        width: g.strip * _glowWidth,
        height: h,
      ),
      _fill,
    );
  }

  /// HTML highlightTick: one division (0 °C to 1 °C) glows and pulses
  /// (scale to 1.2 × 1.5 and back, 500 ms legs, three times).
  void _division(_Geo g) {
    final t = scene.time - scene.precisionStart;
    var grow = 0.0;
    if (t < _pulseLeg * _pulseLegs) {
      final leg = (t / _pulseLeg).floor();
      final f = (t - leg * _pulseLeg) / _pulseLeg;
      grow = leg.isEven ? f : 1 - f;
    }
    final w = g.strip * _barWidth * (1 + _pulseGrowX * grow);
    final h = (g.y(0) - g.y(1)) * (1 + _pulseGrowY * grow);
    _fill.color = _Colors.green500.withValues(alpha: 0.8);
    _c.drawRect(
      Rect.fromCenter(
        center: Offset(g.axis, (g.y(0) + g.y(1)) / 2),
        width: w,
        height: h,
      ),
      _fill,
    );
  }

  // ----------------------------------------------------------------- labels

  /// "Bulb" and "Scale (°C)" to the left of the thermometer, where there is
  /// room in the free part of the stage (the HTML's Toggle Labels tool had
  /// nothing to show).
  void _labels(_Geo g) {
    final ui = scene.ui;
    _label(
      bulbLabel,
      Offset(g.axis - g.bulbR - _labelGap * ui, g.worldToY(_bulbY)),
      ui,
    );
    _label(
      scaleLabel,
      Offset(g.axis - g.tubeHalf - _labelGap * ui, g.y(50)),
      ui,
    );
  }

  /// A dark chip whose right edge is at [right]; skipped where it would
  /// leave the free part of the stage.
  void _label(String text, Offset right, double ui) {
    final tp = cache.label(text, _labelPx * ui);
    final w = tp.width + 2 * _labelPadX * ui;
    final h = tp.height + 2 * _labelPadY * ui;
    final rect = Rect.fromLTWH(right.dx - w, right.dy - h / 2, w, h);
    if (rect.left < scene.frame.left) return;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.slate600;
    _c.drawRRect(rr, _stroke);
    tp.paint(
      _c,
      Offset(rect.left + _labelPadX * ui, rect.top + _labelPadY * ui),
    );
  }

  // ------------------------------------------------------------------ tools

  /// HTML `pulse-highlight`: a ring that grows and fades every 1.5 s.
  void _pulseRing(Offset c, double r, Color color) {
    final ph = (scene.time % _toolPulse) / _toolPulse;
    if (ph > 0.7) return;
    final f = ph / 0.7;
    _stroke
      ..strokeWidth = 3
      ..color = color.withValues(alpha: 0.7 * (1 - f));
    _c.drawCircle(c, r * (1 + 0.35 * f), _stroke);
  }

  /// HTML `#ui-mag-glass` (its SVG: dark handle, #94a3b8 frame, pale lens,
  /// white shine). While it is moved the lens shows the scale magnified.
  void _magnifier(_Geo g, Offset c) {
    final s = scene;
    final r = _lensRadius * s.ui;
    if (!s.lensLive) _pulseRing(c, r * 1.05, _Colors.indigo500);
    const d = Offset(math.sqrt1_2, math.sqrt1_2);
    _stroke
      ..strokeWidth = 0.32 * r
      ..color = _Colors.slate800;
    _c.drawLine(c + d * (r * 0.95), c + d * (r * 1.95), _stroke);
    _stroke
      ..strokeWidth = 0.16 * r
      ..color = _Colors.slate700;
    _c.drawLine(c + d * (r * 1.2), c + d * (r * 1.8), _stroke);
    final lens = Rect.fromCircle(center: c, radius: r);
    if (s.lensLive) {
      _c
        ..save()
        ..clipPath(
          _path
            ..reset()
            ..addOval(lens),
        );
      _fill
        ..shader = null
        ..color = palette.canvasBg;
      _c
        ..drawRect(lens, _fill)
        ..translate(c.dx, c.dy)
        ..scale(_lensZoom)
        ..translate(-c.dx, -c.dy);
      _thermometer(g);
      _c.restore();
      _fill.color = _Colors.sky100.withValues(alpha: 0.12);
    } else {
      _fill
        ..shader = null
        ..color = _Colors.sky100.withValues(alpha: 0.8);
    }
    _c.drawCircle(c, r, _fill);
    _stroke
      ..strokeWidth = 0.16 * r
      ..color = _Colors.slate400;
    _c.drawCircle(c, r, _stroke);
    _stroke
      ..strokeWidth = 0.06 * r
      ..color = _Colors.slate300;
    _c.drawCircle(c, r * 0.87, _stroke);
    _path
      ..reset()
      ..moveTo(c.dx - 0.75 * r, c.dy - 0.5 * r)
      ..quadraticBezierTo(
        c.dx - 0.375 * r,
        c.dy - r,
        c.dx + 0.375 * r,
        c.dy - 0.625 * r,
      );
    _stroke
      ..strokeWidth = 0.12 * r
      ..color = _Colors.white.withValues(alpha: 0.9);
    _c.drawPath(_path, _stroke);
  }

  /// HTML `#ui-zoom-tool` (its SVG: an emerald magnifier with a plus, in a
  /// rounded box with an emerald border).
  void _zoomTool(Offset c) {
    final s = scene;
    final size = _zoomToolSize * s.ui;
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: size, height: size),
      Radius.circular(size * 0.22),
    );
    if (!s.toolDragging) _pulseRing(c, size * 0.62, _Colors.indigo500);
    _fill
      ..shader = null
      ..color = (palette.isDark ? _Colors.slate800 : _Colors.white).withValues(
        alpha: 0.9,
      );
    _c.drawRRect(box, _fill);
    _stroke
      ..strokeWidth = 2 * s.ui
      ..color = _Colors.emerald500;
    _c.drawRRect(box, _stroke);
    // 24-unit SVG view box, the icon 62% of the box.
    final u = size * 0.62 / 24;
    final o = c - Offset(12 * u, 12 * u);
    Offset at(double x, double y) => o + Offset(x * u, y * u);
    _stroke
      ..strokeWidth = 2 * u
      ..color = _Colors.emerald500;
    _c
      ..drawCircle(at(10, 10), 7 * u, _stroke)
      ..drawLine(
        at(15.2, 15.2),
        at(20.4, 20.4),
        _stroke..strokeWidth = 2.4 * u,
      );
    _fill.color = _Colors.slate50;
    _c
      ..drawRect(
        Rect.fromLTRB(at(9, 6).dx, at(9, 6).dy, at(11, 14).dx, at(11, 14).dy),
        _fill,
      )
      ..drawRect(
        Rect.fromLTRB(at(6, 9).dx, at(6, 9).dy, at(14, 11).dx, at(14, 11).dy),
        _fill,
      );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.bulbLabel != bulbLabel ||
      old.scaleLabel != scaleLabel;
}

/// Canvas text made once and reused every frame: the scale numbers (laid
/// out at one size and drawn scaled) and the scene labels. Owned (and
/// disposed) by the page State.
class _PaintCache {
  final Map<int, TextPainter> _numbers = {};
  final Map<String, TextPainter> _labels = {};

  /// A scale number at [_numberRefPx] (HTML: bold, #0f172a).
  TextPainter number(int c) => _numbers[c] ??= _layout(
    '$c',
    _numberRefPx,
    _Colors.slate900,
    FontWeight.w800,
  );

  /// A scene label in white.
  TextPainter label(String text, double size) {
    final key = '$text|${size.toStringAsFixed(1)}';
    final hit = _labels[key];
    if (hit != null) return hit;
    if (_labels.length > 24) _clearLabels();
    return _labels[key] = _layout(text, size, _Colors.white, FontWeight.w700);
  }

  TextPainter _layout(String s, double size, Color color, FontWeight weight) =>
      TextPainter(
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
        textDirection: TextDirection.ltr,
      )..layout();

  void _clearLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _clearLabels();
    for (final tp in _numbers.values) {
      tp.dispose();
    }
    _numbers.clear();
  }
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
