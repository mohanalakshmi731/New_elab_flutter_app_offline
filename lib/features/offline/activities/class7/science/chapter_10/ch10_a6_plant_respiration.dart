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

/// Class 7 Science • Chapter 10 • Activity 6
/// Plant Respiration: The Invisible Breath.
///
/// Native Flutter port of `Cl7S-Ch10-A6-Plant_Respiration.html`.
/// Scenario 1 seals germinating moong seeds in a conical flask piped into
/// lime water; after a 24 h time lapse in the dark Test Tube A turns milky.
/// Scenario 2 puts a snail, a water plant, both and nothing into blue CO₂
/// indicator under a sun lamp and explains each tube's colour.
class Ch10A6PlantRespirationPage extends StatefulWidget {
  const Ch10A6PlantRespirationPage({super.key});

  @override
  State<Ch10A6PlantRespirationPage> createState() => _Ch10A6PlantRespirationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311,
/// bubble 732, magic 871, switchTap 2585, whoosh 1492.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer (HTML `chime`).
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// Object snapped into place / tube analysed (HTML `pop`).
  pop('pop.mp3'),

  /// Water drops from the dropper onto the cotton.
  drop('drop.mp3'),

  /// An object is picked up to be dragged.
  pickup('pickup.mp3'),

  /// Liquid poured into the tubes (HTML `pour`).
  splash('splash.mp3'),

  /// CO₂ bubbles start flowing.
  bubble('bubble.mp3'),

  /// Time lapse starts (HTML `chime`).
  magic('magic.mp3'),

  /// Sun lamp switched on.
  switchTap('switch.mp3'),

  /// Seeds tipped into the flask.
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
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky500 = Color(0xFF0EA5E9); // Mats.water
  static const Color green = Color(0xFF22C55E);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color emerald500 = Color(0xFF10B981); // Mats.greenInd
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706); // Mats.snailBody
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber900 = Color(0xFF78350F); // Mats.snailShell
  static const Color red = Color(0xFFEF4444);
  static const Color red400 = Color(0xFFF87171);
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
  static const Color silver = Color(0xFFC0C0C0); // Mats.silver
  static const Color cork = Color(0xFF8B4513); // Mats.cork
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xEB0F172A),
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
    bg: _Colors.slate100,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sky100,
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

// =================================================================== STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Plant Respiration: The Invisible Breath',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    'scen_1_opt': 'Scenario 1: The Breath of a Seed',
    'scen_2_opt': 'Scenario 2: The Aquarium Balance',
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    'btn_conclude': 'Review Findings',
    'btn_timelapse': 'TIME LAPSE',
    'btn_connect': 'CONNECT TUBE',
    'btn_sunlamp': 'SUN LAMP ON',
    // Floating labels.
    'lbl_flask': 'Conical Flask',
    'lbl_tube_a': 'Test Tube A (Exp.)',
    'lbl_tube_b': 'Test Tube B (Control)',
    'lbl_beaker': 'Moong Seeds',
    'lbl_cotton': 'Cotton',
    'lbl_dropper': 'Dropper',
    'lbl_bottle': 'Lime Water',
    'lbl_cork': 'Cork & Tube',
    'lbl_snail': 'Snail',
    'lbl_plant': 'Water Plant',
    'lbl_snp': 'Snail & Plant',
    'lbl_co2': 'CO₂',
    // Scenario 2 colour key.
    'lbl_indicator_key': 'CO₂ Indicator Key',
    'key_low': 'Low CO₂ (Normal)',
    'key_med': 'Medium CO₂',
    'key_high': 'High CO₂',
    // Scenario 2 tube analysis.
    'lbl_analysis': 'Analysis',
    'tube': 'Tube',
    'lbl_snail_resp': 'Snail (Respiration)',
    'lbl_high_co2_y': 'High CO₂ (Yellow)',
    'lbl_plant_photo': 'Plant (Photosynthesis)',
    'lbl_low_co2_b': 'Low CO₂ (Blue)',
    'lbl_snail_plant_bal': 'Snail + Plant (Balanced)',
    'lbl_snail_prod_plant_use': 'Snail produces CO₂\nPlant uses CO₂',
    'lbl_bal_co2_g': 'Balanced CO₂ (Green)',
    'lbl_control_no_org': 'Control (No Organism)',
    'lbl_no_change': 'No Change',
    'lbl_norm_co2_b': 'Normal CO₂ (Blue)',
    // Conclusions.
    'lbl_chem_eq': 'Chemical Equation',
    'lbl_glucose': 'Glucose',
    'lbl_energy': 'Energy',
    'lbl_s1_conc_desc':
        'The released CO₂ turns the clear lime water milky white, proving respiration occurred.',
    'lbl_animal_snail': 'Animal (Snail)',
    'lbl_resp_only': 'Respiration Only',
    'lbl_high_co2': 'High CO₂',
    'lbl_plant_light': 'Plant (in Light)',
    'lbl_photo_dom': 'Photosynthesis Dominant',
    'lbl_low_co2': 'Low CO₂',
    'lbl_perf_bal': 'The Perfect Balance',
    'lbl_s2_conc_desc': 'Snail produces CO₂ → Plant uses CO₂ to make O₂ → Snail uses O₂',
    'summary_1':
        'Germinating seeds undergo cellular respiration to generate energy for growth. This process takes in oxygen and releases carbon dioxide. The carbon dioxide gas traveled through the tube and reacted with the clear lime water, turning it milky white. This visually proves that plant parts, like seeds, respire just like animals do.',
    'summary_2':
        'In an aquatic environment with light, a balance exists. Animals (snails) perform respiration, releasing CO₂ (turning indicator yellow). Plants perform both respiration and photosynthesis. In light, photosynthesis is dominant, consuming the CO₂ (keeping indicator blue). When both are together, the CO₂ produced by the snail is used by the plant, creating a balanced system.',
    // Time-lapse clock.
    'hours': '{h} h',
    // Feedback toasts (the HTML silently snaps objects back).
    'msg_drop_flask': 'Drop it into the conical flask!',
    'msg_seeds_first': 'Add the moong seeds to the flask first!',
    'msg_cotton_first': 'Put the cotton in the flask before using the dropper!',
    'msg_drop_tubes': 'Drop the bottle over the test tubes!',
    'msg_drop_cork': 'Drop the cork onto the mouth of the flask!',
    'msg_goes_into': '{item} goes into Tube {tube}!',
    'msg_click_milky': 'Click the milky test tube (A)!',
  },
  'hi': {
    'app_title': 'पौधों में श्वसन: अदृश्य श्वास',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: एक बीज की सांस',
    'scen_2_opt': 'परिदृश्य 2: एक्वेरियम संतुलन',
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'btn_timelapse': 'समय व्यतीत',
    'btn_connect': 'ट्यूब कनेक्ट करें',
    'btn_sunlamp': 'सूर्य लैंप चालू करें',
    'lbl_flask': 'शंक्वाकार फ्लास्क',
    'lbl_tube_a': 'परखनली A (प्रयोग)',
    'lbl_tube_b': 'परखनली B (नियंत्रण)',
    'lbl_beaker': 'मूंग के बीज',
    'lbl_cotton': 'रुई',
    'lbl_dropper': 'ड्रॉपर',
    'lbl_bottle': 'चूने का पानी',
    'lbl_cork': 'कॉर्क और ट्यूब',
    'lbl_snail': 'घोंघा',
    'lbl_plant': 'जलीय पौधा',
    'lbl_snp': 'घोंघा और पौधा',
    'lbl_co2': 'CO₂',
    'lbl_indicator_key': 'CO₂ संकेतक कुंजी',
    'key_low': 'कम CO₂ (सामान्य)',
    'key_med': 'मध्यम CO₂',
    'key_high': 'उच्च CO₂',
    'lbl_analysis': 'विश्लेषण',
    'tube': 'परखनली',
    'lbl_snail_resp': 'घोंघा (श्वसन)',
    'lbl_high_co2_y': 'उच्च CO₂ (पीला)',
    'lbl_plant_photo': 'पौधा (प्रकाश संश्लेषण)',
    'lbl_low_co2_b': 'कम CO₂ (नीला)',
    'lbl_snail_plant_bal': 'घोंघा + पौधा (संतुलित)',
    'lbl_snail_prod_plant_use': 'घोंघा CO₂ बनाता है\nपौधा CO₂ का उपयोग करता है',
    'lbl_bal_co2_g': 'संतुलित CO₂ (हरा)',
    'lbl_control_no_org': 'नियंत्रण (कोई जीव नहीं)',
    'lbl_no_change': 'कोई परिवर्तन नहीं',
    'lbl_norm_co2_b': 'सामान्य CO₂ (नीला)',
    'lbl_chem_eq': 'रासायनिक समीकरण',
    'lbl_glucose': 'ग्लूकोज',
    'lbl_energy': 'ऊर्जा',
    'lbl_s1_conc_desc':
        'निकली हुई CO₂ साफ़ चूने के पानी को दूधिया सफेद कर देती है, जिससे सिद्ध होता है कि श्वसन हुआ है।',
    'lbl_animal_snail': 'जंतु (घोंघा)',
    'lbl_resp_only': 'केवल श्वसन',
    'lbl_high_co2': 'उच्च CO₂',
    'lbl_plant_light': 'पौधा (प्रकाश में)',
    'lbl_photo_dom': 'प्रकाश संश्लेषण प्रमुख',
    'lbl_low_co2': 'कम CO₂',
    'lbl_perf_bal': 'उत्तम संतुलन',
    'lbl_s2_conc_desc':
        'घोंघा CO₂ बनाता है → पौधा O₂ बनाने के लिए CO₂ का उपयोग करता है → घोंघा O₂ का उपयोग करता है',
    'summary_1':
        'अंकुरित बीज वृद्धि के लिए ऊर्जा प्राप्त करने हेतु कोशिकीय श्वसन करते हैं। इस प्रक्रिया में ऑक्सीजन ली जाती है और कार्बन डाइऑक्साइड निकलती है। कार्बन डाइऑक्साइड गैस नली से होकर गई और साफ़ चूने के पानी से क्रिया करके उसे दूधिया सफेद बना दिया। यह दिखाता है कि बीज जैसे पौधों के अंग भी जंतुओं की तरह श्वसन करते हैं।',
    'summary_2':
        'प्रकाश वाले जलीय वातावरण में एक संतुलन बना रहता है। जंतु (घोंघे) श्वसन करते हैं और CO₂ छोड़ते हैं (संकेतक पीला हो जाता है)। पौधे श्वसन और प्रकाश संश्लेषण दोनों करते हैं। प्रकाश में प्रकाश संश्लेषण प्रमुख होता है, जो CO₂ का उपयोग कर लेता है (संकेतक नीला रहता है)। जब दोनों साथ होते हैं, तो घोंघे द्वारा बनाई गई CO₂ का उपयोग पौधा करता है, जिससे एक संतुलित तंत्र बनता है।',
    'hours': '{h} घंटे',
    'msg_drop_flask': 'इसे शंक्वाकार फ्लास्क में डालें!',
    'msg_seeds_first': 'पहले मूंग के बीज फ्लास्क में डालें!',
    'msg_cotton_first': 'ड्रॉपर से पहले रुई को फ्लास्क में रखें!',
    'msg_drop_tubes': 'बोतल को परखनलियों के ऊपर छोड़ें!',
    'msg_drop_cork': 'कॉर्क को फ्लास्क के मुँह पर छोड़ें!',
    'msg_goes_into': '{item}: इसे परखनली {tube} में रखें!',
    'msg_click_milky': 'दूधिया परखनली (A) पर क्लिक करें!',
  },
};

/// Mission objective and steps (HTML `ScenariosData`). Each step's action
/// is the HTML "Current Task" HUD line for that step.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually prove that germinating seeds respire by detecting the carbon dioxide they release.',
      steps: [
        LabStep(
          concept: 'Apparatus Setup',
          action:
              'DRAG the beaker of seeds into the flask. Then DRAG the cotton ball into the flask. CLICK the dropper to moisten the cotton.',
          observation: 'The seeds and wet cotton provide the right environment for germination.',
        ),
        LabStep(
          concept: 'Preparing the Indicator',
          action: 'DRAG the lime water bottle onto both test tubes to fill them.',
          observation: 'Both test tubes are filled with clear, colorless lime water.',
        ),
        LabStep(
          concept: 'Sealing the System',
          action: "DRAG the cork assembly onto the flask. Then CLICK the 'CONNECT TUBE' button.",
          observation:
              'The flask is sealed, and a pipe connects the air inside the flask directly to the lime water in Test Tube A.',
        ),
        LabStep(
          concept: 'Time Lapse (Darkness)',
          action: "CLICK the 'TIME LAPSE' button to wait 24 hours in the dark.",
          observation:
              'Tiny bubbles travel from the flask. The lime water in Test Tube A turns milky white, while Test Tube B (control) remains clear.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'CLICK on Test Tube A to analyze the results.',
          observation: 'A summary confirms that the seeds produced CO₂.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To understand the relationship and balance between respiration (produces CO₂) and photosynthesis (consumes CO₂) in an aquatic environment.',
      steps: [
        LabStep(
          concept: 'Experimental Design',
          action: 'The 4 test tubes are arranged in the rack (this step is automatic).',
          observation: 'The workspace is set up for a comparative experiment.',
        ),
        LabStep(
          concept: 'Setting the Variables',
          action: 'DRAG the Snail to Tube A, Plant to Tube B, Snail+Plant to Tube C. Leave D empty.',
          observation: 'Tube A has an animal. Tube B has a plant. Tube C has both. Tube D is empty.',
        ),
        LabStep(
          concept: 'Adding the Indicator',
          action: 'CLICK the dropper to add blue CO₂ indicator to all tubes.',
          observation:
              'All tubes turn blue, indicating a low starting level of carbon dioxide in the water.',
        ),
        LabStep(
          concept: 'Light and Time',
          action: "CLICK 'SUN LAMP ON' then 'TIME LAPSE' to observe changes.",
          observation:
              'In sunlight, Tube A turns yellow. Tube B stays blue. Tube C turns greenish. Tube D stays blue.',
        ),
        LabStep(
          concept: 'Analyzing Results',
          action: 'CLICK on each test tube to analyze the chemical balance.',
          observation: 'You review the specific equations for each tube.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'अंकुरित बीजों द्वारा छोड़ी गई कार्बन डाइऑक्साइड का पता लगाकर यह दृश्य रूप से सिद्ध करना कि अंकुरित बीज श्वसन करते हैं।',
      steps: [
        LabStep(
          concept: 'उपकरण सेटअप',
          action:
              'बीजों के बीकर को फ्लास्क में खींचें। फिर रुई के गोले को फ्लास्क में खींचें। रुई को गीला करने के लिए ड्रॉपर पर क्लिक करें।',
          observation: 'बीज और गीली रुई अंकुरण के लिए सही वातावरण प्रदान करते हैं।',
        ),
        LabStep(
          concept: 'संकेतक तैयार करना',
          action: 'चूने के पानी की बोतल को दोनों परखनलियों पर खींचकर उन्हें भरें।',
          observation: 'दोनों परखनलियां साफ, रंगहीन चूने के पानी से भर गई हैं।',
        ),
        LabStep(
          concept: 'सिस्टम को सील करना',
          action: "कॉर्क असेंबली को फ्लास्क पर खींचें। फिर 'ट्यूब कनेक्ट करें' बटन पर क्लिक करें।",
          observation:
              'फ्लास्क सील हो गया है, और एक पाइप फ्लास्क के अंदर की हवा को सीधे परखनली A के चूने के पानी से जोड़ता है।',
        ),
        LabStep(
          concept: 'समय व्यतीत (अंधेरा)',
          action: "अंधेरे में 24 घंटे प्रतीक्षा करने के लिए 'समय व्यतीत' बटन पर क्लिक करें।",
          observation:
              'फ्लास्क से छोटे बुलबुले निकलते हैं। परखनली A में चूने का पानी दूधिया सफेद हो जाता है, जबकि परखनली B (नियंत्रण) साफ रहती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'परिणामों का विश्लेषण करने के लिए परखनली A पर क्लिक करें।',
          observation: 'एक सारांश पुष्टि करता है कि बीजों ने CO₂ बनाई।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'एक जलीय वातावरण में श्वसन (CO₂ बनाता है) और प्रकाश संश्लेषण (CO₂ का उपयोग करता है) के बीच संबंध और संतुलन को समझना।',
      steps: [
        LabStep(
          concept: 'प्रायोगिक डिज़ाइन',
          action: '4 परखनलियां स्टैंड में व्यवस्थित हैं (यह चरण स्वचालित है)।',
          observation: 'तुलनात्मक प्रयोग के लिए कार्यस्थान तैयार है।',
        ),
        LabStep(
          concept: 'चर सेट करना',
          action:
              'घोंघे को ट्यूब A में, पौधे को ट्यूब B में, घोंघा+पौधा को ट्यूब C में खींचें। D को खाली छोड़ दें।',
          observation: 'ट्यूब A में एक जंतु है। ट्यूब B में एक पौधा है। ट्यूब C में दोनों हैं। ट्यूब D खाली है।',
        ),
        LabStep(
          concept: 'संकेतक जोड़ना',
          action: 'सभी ट्यूबों में नीला CO₂ संकेतक जोड़ने के लिए ड्रॉपर पर क्लिक करें।',
          observation:
              'सभी ट्यूब नीली हो जाती हैं, जो पानी में कार्बन डाइऑक्साइड के कम शुरुआती स्तर को दर्शाता है।',
        ),
        LabStep(
          concept: 'प्रकाश और समय',
          action: "परिवर्तनों को देखने के लिए 'सूर्य लैंप चालू करें' और फिर 'समय व्यतीत' पर क्लिक करें।",
          observation:
              'धूप में, ट्यूब A पीली हो जाती है। ट्यूब B नीली रहती है। ट्यूब C हरी हो जाती है। ट्यूब D नीली रहती है।',
        ),
        LabStep(
          concept: 'परिणामों का विश्लेषण',
          action: 'रासायनिक संतुलन का विश्लेषण करने के लिए प्रत्येक परखनली पर क्लिक करें।',
          observation: 'आप प्रत्येक ट्यूब के विशिष्ट समीकरणों की समीक्षा करते हैं।',
        ),
      ],
    ),
  ],
};

// ===================================================================== STATE

const Size _design = Size(1000, 560);

/// Design px per Three.js unit.
const double _k = 66;

/// Design x of world x = 0 and design y of the table top (y = 0, z = 0).
const double _cx = 470;
const double _gy = 405;

/// How far one unit of depth (towards the camera) drops on screen, in
/// units: the HTML camera looks down at the table at about 14°.
const double _zk = 0.25;

/// World (Three.js units: x right, y up, z towards the camera) to design px.
Offset _w(double x, double y, [double z = 0]) =>
    Offset(_cx + x * _k, _gy - y * _k + z * _k * _zk);

/// Scenario 1 test tubes and rack (HTML x positions).
const double _tubeAX = 2.7;
const double _tubeBX = 4.3;
const double _rackS1X = 3.5;

/// Scenario 2 tubes A–D.
const List<double> _s2TubeX = [-2.5, -0.83, 0.83, 2.5];
const List<String> _tubeLetters = ['A', 'B', 'C', 'D'];

/// Tubes stand 0.2 above the table; a full tube holds liquid up to 2.2.
const double _tubeBase = 0.2;
const double _liquidTop = 2.2;

/// Drop area of the conical flask (HTML: within 2 units of the flask).
const Rect _flaskZone = Rect.fromLTRB(_cx - 1.8 * _k, _gy - 3.9 * _k, _cx + 1.8 * _k, _gy + 1.2 * _k);

/// Dropper tips (HTML `dropper.position`).
final Offset _s1DropperTip = _w(-5.6, 0, 0.6);
final Offset _s2DropperTip = _w(-5.9, 0, 1.0);

/// The cork sits in the flask neck with its bottom at y = 2.95.
final Offset _corkOnFlask = _w(0, 2.95);

/// Liquid colours: lime water (HTML `Mats.water`), milky lime water
/// (`Mats.milk`) and the CO₂ indicator (`blueInd`, `yellowInd`, `greenInd`).
const Color _lime = _Colors.sky500;
const Color _milk = _Colors.slate50;

enum _Item { beaker, cotton, bottle, cork, snail, plant, both }

/// Scenario 2: which tube each organism belongs in (A = 0, B = 1, C = 2).
const Map<_Item, int> _targetTube = {_Item.snail: 0, _Item.plant: 1, _Item.both: 2};

/// A draggable object (HTML `userData.isDraggable`) with its start position.
class _Draggable {
  _Draggable(this.id, this.home) : pos = home;

  final _Item id;

  /// Base point on the table (bottom centre) in design px.
  final Offset home;
  Offset pos;

  /// Dropped into its target (no longer draggable).
  bool placed = false;

  /// Used up (seeds poured, bottle emptied).
  bool hidden = false;

  /// Snap-back animation (HTML TWEEN back to `startPos`, 300 ms).
  Offset snapFrom = Offset.zero;
  double snapStart = -1;

  Offset drawPos(double time) {
    if (snapStart < 0) return pos;
    final v = ((time - snapStart) / 0.3).clamp(0.0, 1.0);
    if (v >= 1) return pos;
    return Offset.lerp(snapFrom, pos, Curves.easeOutQuad.transform(v))!;
  }

  /// Grab area around the object at [at] (default: its position).
  Rect rect([Offset? at]) {
    final p = at ?? pos;
    final (l, t, r, b) = switch (id) {
      _Item.beaker => (-0.62, -1.36, 0.62, 0.16),
      _Item.cotton => (-0.58, -0.68, 0.58, 0.16),
      _Item.bottle => (-0.71, -2.32, 0.71, 0.16),
      _Item.cork => (-0.55, -1.23, 0.68, 0.16),
      _Item.snail => (-0.68, -0.8, 0.74, 0.16),
      _Item.plant => (-0.55, -1.71, 0.55, 0.16),
      _Item.both => (-0.74, -1.71, 0.71, 0.16),
    };
    return Rect.fromLTRB(p.dx + l * _k, p.dy + t * _k, p.dx + r * _k, p.dy + b * _k);
  }
}

/// Nearest Scenario 2 tube (within 1 unit, HTML rule) under [c], if any.
int? _nearestTube(Offset c) {
  if (c.dy < _w(0, 4.4).dy || c.dy > _gy + 1.8 * _k) return null;
  int? best;
  var bestD = 1.0 * _k;
  for (var i = 0; i < _s2TubeX.length; i++) {
    final d = (c.dx - _w(_s2TubeX[i], 0).dx).abs();
    if (d < bestD) {
      bestD = d;
      best = i;
    }
  }
  return best;
}

/// Mutable scene model read by the painter every frame (HTML `State`).
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  final Map<_Item, _Draggable> items = {};
  _Draggable? drag;
  Offset grab = Offset.zero;

  // Scenario 1 (HTML State.s1).
  bool seedsAdded = false;
  bool cottonAdded = false;
  bool wet = false;
  bool filled = false;
  bool sealed = false;
  bool connected = false;
  bool lapsed = false;
  bool dropperUsed = false;
  double dropperStart = -1;
  double wetStart = -1;
  double connectStart = -1;

  // Scenario 2 (HTML State.s2).
  bool setup = false;
  bool s2Filled = false;
  bool lampOn = false;
  double lampStart = -1;
  final Set<int> clickedTubes = {};

  // Both scenarios.
  double fillStart = -1;
  double lapseStart = -1;

  /// HTML `#main-action-btn` type: 'connect', 'timelapse' or 'sunlamp'.
  String? mainAction;

  /// HTML `#compare-btn-container` ("Review Findings").
  bool showReview = false;

  /// True while the time-lapse clock is shown.
  bool lapsing = false;

  /// 0..1 progress of an animation that started at [start] (`-1` = never).
  double ramp(double start, double seconds) =>
      start < 0 ? 0 : ((time - start) / seconds).clamp(0.0, 1.0);

  /// HTML `resetScenarioState(sc)`.
  void reset(int sc) {
    scenario = sc;
    step = 1;
    drag = null;
    seedsAdded = false;
    cottonAdded = false;
    wet = false;
    filled = false;
    sealed = false;
    connected = false;
    lapsed = false;
    dropperUsed = false;
    dropperStart = -1;
    wetStart = -1;
    connectStart = -1;
    setup = false;
    s2Filled = false;
    lampOn = false;
    lampStart = -1;
    clickedTubes.clear();
    fillStart = -1;
    lapseStart = -1;
    mainAction = null;
    showReview = false;
    lapsing = false;
    items.clear();
    if (sc == 0) {
      items.addAll({
        _Item.beaker: _Draggable(_Item.beaker, _w(-3.9, 0, 0.2)),
        _Item.cotton: _Draggable(_Item.cotton, _w(-2.3, 0, 1.4)),
        _Item.bottle: _Draggable(_Item.bottle, _w(5.5, 0, 1.0)),
        _Item.cork: _Draggable(_Item.cork, _w(-2.5, 0, 1.5)),
      });
    } else {
      items.addAll({
        _Item.snail: _Draggable(_Item.snail, _w(-3.3, 0, 3.15)),
        _Item.plant: _Draggable(_Item.plant, _w(0, 0, 3.15)),
        _Item.both: _Draggable(_Item.both, _w(3.3, 0, 3.15)),
      });
    }
  }

  /// True when [it], dropped now, would land in its target.
  bool overTarget(_Draggable it) {
    final c = it.rect().center;
    switch (it.id) {
      case _Item.beaker || _Item.cork:
        return _flaskZone.contains(c);
      case _Item.cotton:
        return seedsAdded && _flaskZone.contains(c);
      case _Item.bottle:
        return c.dx > _w(1.5, 0).dx && c.dx < _w(5, 0).dx && c.dy < _gy + 1.2 * _k;
      case _Item.snail || _Item.plant || _Item.both:
        return _nearestTube(c) == _targetTube[it.id];
    }
  }
}

/// Pan recognizer that only claims touches starting on a draggable object
/// (so empty-canvas drags still pan the zoomed canvas) and starts after a
/// small slop.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch10A6PlantRespirationPageState extends State<Ch10A6PlantRespirationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene()..reset(0);
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;

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

    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
    })..start();
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

  // ------------------------------------------------------------ logic

  /// HTML `resetScenarioState(sc)`: cancels timers and rebuilds the scene.
  void _resetScenario(int sc) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _scene.reset(sc);
    if (sc == 1) {
      // Step 1 only shows the rack, so it advances on its own.
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scene.scenario != 1 || _scene.step != 1) return;
        _progressStep();
      });
    }
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _resetScenario(index));

  void _fullReset() => setState(() => _resetScenario(0));

  void _progressStep() => setState(() => _scene.step++);

  /// HTML `checkStepProgress()`.
  void _checkStepProgress() {
    final sc = _scene;
    if (sc.scenario == 0) {
      if (sc.step == 1 && sc.wet) {
        _progressStep();
      } else if (sc.step == 2 && sc.filled) {
        _progressStep();
      } else if (sc.step == 3 && sc.sealed && !sc.connected) {
        setState(() => sc.mainAction = 'connect');
      }
    } else {
      if (sc.step == 2 && sc.setup) {
        _progressStep();
      } else if (sc.step == 3 && sc.s2Filled) {
        _progressStep();
        setState(() => sc.mainAction = 'sunlamp');
      }
    }
  }

  /// Objects that can be dragged in the current step (HTML `interactables`).
  List<_Draggable> _draggables() {
    final sc = _scene;
    final items = sc.items;
    if (sc.scenario == 0) {
      if (sc.step == 1) {
        return [
          if (!items[_Item.beaker]!.hidden) items[_Item.beaker]!,
          if (!items[_Item.cotton]!.placed) items[_Item.cotton]!,
        ];
      }
      if (sc.step == 2 && !sc.filled) return [items[_Item.bottle]!];
      if (sc.step == 3 && !sc.sealed) return [items[_Item.cork]!];
      return const [];
    }
    if (sc.step == 2) {
      return [
        for (final id in const [_Item.snail, _Item.plant, _Item.both])
          if (!items[id]!.placed) items[id]!,
      ];
    }
    return const [];
  }

  _Draggable? _hitDraggable(Offset local) {
    if (!_lab.isLabActive) return null;
    // Front-most (lowest on screen) first.
    final list = [..._draggables()]..sort((a, b) => b.home.dy.compareTo(a.home.dy));
    for (final it in list) {
      if (it.rect().contains(local)) return it;
    }
    return null;
  }

  void _grab(Offset local) {
    final it = _hitDraggable(local);
    if (it == null) return;
    _Audio.play(_Sound.pickup);
    setState(() {
      _scene.drag = it;
      _scene.grab = local - it.pos;
      it.snapStart = -1;
    });
  }

  void _dragTo(Offset local) {
    final it = _scene.drag;
    if (it == null) return;
    final p = local - _scene.grab;
    it.pos = Offset(
      p.dx.clamp(30.0, _design.width - 30),
      p.dy.clamp(120.0, _design.height - 20),
    );
  }

  void _release() {
    final it = _scene.drag;
    if (it == null) return;
    setState(() => _scene.drag = null);
    _drop(it);
  }

  String _itemName(_Item id) => switch (id) {
        _Item.snail => _t('lbl_snail'),
        _Item.plant => _t('lbl_plant'),
        _ => _t('lbl_snp'),
      };

  /// Hint shown when [it] lands somewhere else.
  String _dropHint(_Draggable it) {
    switch (it.id) {
      case _Item.beaker:
        return _t('msg_drop_flask');
      case _Item.cotton:
        return _scene.seedsAdded || !_flaskZone.contains(it.rect().center)
            ? _t('msg_drop_flask')
            : _t('msg_seeds_first');
      case _Item.bottle:
        return _t('msg_drop_tubes');
      case _Item.cork:
        return _t('msg_drop_cork');
      case _Item.snail || _Item.plant || _Item.both:
        return labFormat(_t('msg_goes_into'), {
          'item': _itemName(it.id),
          'tube': _tubeLetters[_targetTube[it.id]!],
        });
    }
  }

  /// HTML `handleUp()`: snaps the object into place or sends it back.
  void _drop(_Draggable it) {
    final sc = _scene;
    if (!sc.overTarget(it)) {
      final hint = _dropHint(it);
      setState(() {
        it.snapFrom = it.pos;
        it.pos = it.home;
        it.snapStart = sc.time;
      });
      _lab.showToast(hint, isError: true);
      return;
    }
    setState(() {
      switch (it.id) {
        case _Item.beaker:
          _Audio.play(_Sound.whoosh);
          it.hidden = true;
          sc.seedsAdded = true;
        case _Item.cotton:
          _Audio.play(_Sound.pop);
          it.placed = true;
          it.pos = _w(0, 0.2);
          sc.cottonAdded = true;
        case _Item.bottle:
          _Audio.play(_Sound.splash);
          it.hidden = true;
          sc.filled = true;
          sc.fillStart = sc.time;
        case _Item.cork:
          _Audio.play(_Sound.pop);
          it.placed = true;
          it.pos = _corkOnFlask;
          sc.sealed = true;
        case _Item.snail || _Item.plant || _Item.both:
          _Audio.play(_Sound.pop);
          it.placed = true;
          it.pos = _w(_s2TubeX[_targetTube[it.id]!], 0.3);
          sc.setup = sc.items.values.every((o) => o.placed);
      }
    });
    _checkStepProgress();
  }

  Rect _dropperRect(Offset tip) =>
      Rect.fromLTRB(tip.dx - 22, tip.dy - 1.62 * _k, tip.dx + 1.05 * _k, tip.dy + 10);

  Rect _tubeRect(double x) {
    final b = _w(x, 0);
    return Rect.fromLTRB(b.dx - 0.62 * _k, _w(0, 3.7).dy, b.dx + 0.62 * _k, _gy + 14);
  }

  /// HTML `handleDown()` for clickable objects.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    final sc = _scene;
    final it = _hitDraggable(p);
    if (it != null) {
      _Audio.play(_Sound.pickup);
      _lab.showToast(_dropHint(it), sound: false);
      return;
    }
    if (sc.scenario == 0) {
      if (sc.step == 1 && sc.dropperStart < 0 && _dropperRect(_s1DropperTip).contains(p)) {
        if (sc.cottonAdded) {
          _moistenCotton();
        } else {
          _lab.showToast(_t('msg_cotton_first'), isError: true);
        }
      } else if (sc.step == 5) {
        if (_tubeRect(_tubeAX).contains(p)) {
          _triggerConclusionState();
        } else if (_tubeRect(_tubeBX).contains(p)) {
          _lab.showToast(_t('msg_click_milky'), isError: true);
        }
      }
    } else {
      if (sc.step == 3 && sc.fillStart < 0 && _dropperRect(_s2DropperTip).contains(p)) {
        _addIndicator();
      } else if (sc.step == 5) {
        for (var i = 0; i < _s2TubeX.length; i++) {
          if (_tubeRect(_s2TubeX[i]).contains(p)) {
            _showEquation(i);
            break;
          }
        }
      }
    }
  }

  /// Scenario 1: the dropper moves into the flask and wets the cotton.
  void _moistenCotton() {
    final sc = _scene;
    _Audio.play(_Sound.drop);
    setState(() => sc.dropperStart = sc.time);
    _lab.after(const Duration(milliseconds: 850), () {
      if (!mounted || sc.scenario != 0 || sc.step != 1) return;
      setState(() {
        sc.wet = true;
        sc.wetStart = sc.time;
        sc.dropperUsed = true;
      });
      _checkStepProgress();
    });
  }

  /// Scenario 2: the dropper fills every tube with blue CO₂ indicator.
  void _addIndicator() {
    final sc = _scene;
    _Audio.play(_Sound.splash);
    setState(() => sc.fillStart = sc.time);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted || sc.scenario != 1 || sc.step != 3) return;
      setState(() => sc.s2Filled = true);
      _checkStepProgress();
    });
  }

  /// HTML `executeAction()` for the main action button.
  void _executeAction() {
    final sc = _scene;
    final type = sc.mainAction;
    setState(() => sc.mainAction = null);
    if (sc.scenario == 0) {
      if (type == 'connect') {
        _Audio.play(_Sound.success);
        setState(() {
          sc.connected = true;
          sc.connectStart = sc.time;
        });
        _progressStep();
        _lab.after(const Duration(milliseconds: 500), () {
          if (!mounted || sc.scenario != 0 || sc.step != 4) return;
          setState(() => sc.mainAction = 'timelapse');
        });
      } else if (type == 'timelapse') {
        _runTimeLapseS1();
      }
    } else {
      if (type == 'sunlamp') {
        _Audio.play(_Sound.switchTap);
        setState(() {
          sc.lampOn = true;
          sc.lampStart = sc.time;
        });
        _lab.after(const Duration(milliseconds: 500), () {
          if (!mounted || sc.scenario != 1 || sc.step != 4) return;
          setState(() => sc.mainAction = 'timelapse');
        });
      } else if (type == 'timelapse') {
        _runTimeLapseS2();
      }
    }
  }

  /// HTML `runTimeLapseS1()`: darkness, CO₂ bubbles, Tube A turns milky.
  void _runTimeLapseS1() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc.lapsed = true;
      sc.lapsing = true;
      sc.lapseStart = sc.time;
    });
    _lab.after(const Duration(milliseconds: 700), () => _Audio.play(_Sound.bubble));
    _lab.after(const Duration(milliseconds: 2000), () => _Audio.play(_Sound.success));
    _lab.after(const Duration(milliseconds: 5000), () {
      if (!mounted || sc.scenario != 0 || sc.step != 4) return;
      setState(() => sc.lapsing = false);
      _progressStep();
    });
  }

  /// HTML `runTimeLapseS2()`: Tube A turns yellow and Tube C green.
  void _runTimeLapseS2() {
    final sc = _scene;
    _Audio.play(_Sound.magic);
    setState(() {
      sc.lapsed = true;
      sc.lapsing = true;
      sc.lapseStart = sc.time;
    });
    _lab.after(const Duration(milliseconds: 1500), () => _Audio.play(_Sound.success));
    _lab.after(const Duration(milliseconds: 3000), () {
      if (!mounted || sc.scenario != 1 || sc.step != 4) return;
      setState(() => sc.lapsing = false);
      _progressStep();
    });
  }

  /// HTML `triggerConclusionState()`: shows "Review Findings".
  void _triggerConclusionState() {
    _Audio.play(_Sound.correct);
    setState(() => _scene.showReview = true);
  }

  /// HTML `triggerConclusion()`: the summary popup.
  void _triggerConclusion() {
    final idx = _scene.scenario;
    setState(() => _scene.showReview = false);
    _lab.showScenarioConclusion(
      scenarioIndex: idx,
      totalScenarios: 2,
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('summary_${idx + 1}'),
      extra: () => idx == 0 ? _s1Summary() : _s2Summary(),
      delay: const Duration(milliseconds: 150),
    );
  }

  /// HTML `showEquation(tubeId)`.
  void _showEquation(int i) {
    final sc = _scene;
    setState(() => sc.clickedTubes.add(i));
    _lab.showPopup(
      () => LabPopupContent(
        title: '${_t('lbl_analysis')} • ${_t('tube')} ${_tubeLetters[i]}',
        icon: Icons.science,
        accent: _tubeAccent(i),
        extra: _equationCard(i),
      ),
      sound: _Sound.pop,
    );
    if (sc.clickedTubes.length == 4) {
      _lab.after(const Duration(milliseconds: 1000), () {
        if (!mounted || sc.scenario != 1 || sc.step != 5) return;
        _triggerConclusionState();
      });
    }
  }

  List<LabAction> _actions() {
    final sc = _scene;
    return [
      if (sc.mainAction == 'connect')
        LabAction(
          label: _t('btn_connect'),
          icon: Icons.link,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _executeAction,
        ),
      if (sc.mainAction == 'timelapse')
        LabAction(
          label: _t('btn_timelapse'),
          icon: Icons.schedule,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _executeAction,
        ),
      if (sc.mainAction == 'sunlamp')
        LabAction(
          label: _t('btn_sunlamp'),
          icon: Icons.wb_sunny,
          color: _Colors.zslYellow,
          foreground: _Colors.slate900,
          highlight: true,
          onTap: _executeAction,
        ),
      if (sc.showReview)
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.check_circle,
          color: _Colors.purple600,
          foreground: Colors.white,
          highlight: true,
          silent: true, // the conclusion popup plays the success tone
          onTap: _triggerConclusion,
        ),
    ];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final sc = _scene;
        final inset = labOverlayInsets(context, _lab);
        final actions = _actions();
        final keyRoom = sc.scenario == 1 ? 150 * s : 0.0;
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          actions: actions,
          onReset: _fullReset,
          overlays: [
            if (sc.scenario == 1)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _colorKey(s),
              ),
            if (sc.lapsing)
              Positioned(
                top: inset.top,
                left: inset.left,
                right: inset.right + keyRoom,
                child: Center(child: _lapseClock(s)),
              ),
            // HTML #btn-action-container / #compare-btn-container: the
            // current action also floats over the canvas while the sidebar
            // is open (the floating mission card has it when collapsed).
            if (_lab.isSidebarOpen && actions.isNotEmpty)
              Positioned(
                top: inset.top + 4 * s,
                left: inset.left,
                right: inset.right + keyRoom,
                child: Center(
                  child: Wrap(
                    spacing: 8 * s,
                    runSpacing: 6 * s,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final a in actions) LabActionButton(action: a, scale: s, expand: false),
                    ],
                  ),
                ),
              ),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
                  _ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _hitDraggable(local) != null)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _LabPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#s2-color-key`.
  Widget _colorKey(double s) {
    Widget row(Color c, String text) => Padding(
          padding: EdgeInsets.only(top: 5 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 13 * s,
                height: 13 * s,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(4 * s),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
              ),
              SizedBox(width: 7 * s),
              Text(
                text,
                style: TextStyle(color: _Colors.slate200, fontSize: 10.5 * s, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
    return Container(
      padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 12 * s, 9 * s),
      decoration: BoxDecoration(
        color: const Color(0xD90F172A),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _Colors.slate700),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('lbl_indicator_key').toUpperCase(),
            style: TextStyle(
              color: _Colors.slate400,
              fontSize: 9 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          row(_Colors.blue, _t('key_low')),
          row(_Colors.green, _t('key_med')),
          row(_Colors.yellow400, _t('key_high')),
        ],
      ),
    );
  }

  /// Time-lapse clock: 0 → 24 hours while the time lapse runs.
  Widget _lapseClock(double s) {
    final sc = _scene;
    final dark = sc.scenario == 0;
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, time, child) {
        final run = dark ? 4.0 : 2.6;
        final h = ((time - sc.lapseStart) / run * 24).clamp(0.0, 24.0).floor();
        return LabReadout(
          text: labFormat(_t('hours'), {'h': h.toString().padLeft(2, '0')}),
          icon: dark ? Icons.nightlight_round : Icons.wb_sunny,
          color: dark ? _Colors.indigo300 : _Colors.yellow400,
          scale: s,
          fontSize: 18,
        );
      },
    );
  }

  // ------------------------------------------------------ popup content

  Color _tubeAccent(int i) => switch (i) {
        0 => _Colors.zslYellow,
        1 => _Colors.blue,
        2 => _Colors.green,
        _ => _Colors.slate400,
      };

  Widget _organismIcon(_Item kind, double size) => CustomPaint(
        size: Size.square(size),
        painter: _OrganismIconPainter(kind),
      );

  /// HTML `#s2-equation-overlay` content for tube [i].
  Widget _equationCard(int i) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final dark = _lab.isDark;
    final sun = Icon(Icons.wb_sunny, size: 22 * s, color: _Colors.yellow400);
    final snail = _organismIcon(_Item.snail, 46 * s);
    final plant = _organismIcon(_Item.plant, 46 * s);
    late final Widget icons;
    late final String label;
    late final String equation;
    late final String result;
    late final Color eqColor;
    late final Color chip;
    switch (i) {
      case 0:
        icons = snail;
        label = _t('lbl_snail_resp');
        equation = 'O₂ → CO₂';
        result = _t('lbl_high_co2_y');
        eqColor = dark ? _Colors.yellow400 : _Colors.amber700;
        chip = _Colors.zslYellow;
      case 1:
        icons = Column(mainAxisSize: MainAxisSize.min, children: [sun, plant]);
        label = _t('lbl_plant_photo');
        equation = 'CO₂ → O₂';
        result = _t('lbl_low_co2_b');
        eqColor = dark ? _Colors.blue400 : _Colors.blue600;
        chip = _Colors.blue;
      case 2:
        icons = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sun,
            Row(mainAxisSize: MainAxisSize.min, children: [snail, SizedBox(width: 6 * s), plant]),
          ],
        );
        label = _t('lbl_snail_plant_bal');
        equation = _t('lbl_snail_prod_plant_use');
        result = _t('lbl_bal_co2_g');
        eqColor = dark ? _Colors.green400 : _Colors.green700;
        chip = _Colors.green;
      default:
        icons = Icon(Icons.science, size: 40 * s, color: _Colors.slate400);
        label = _t('lbl_control_no_org');
        equation = _t('lbl_no_change');
        result = _t('lbl_norm_co2_b');
        eqColor = _Colors.slate400;
        chip = _Colors.blue;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icons,
        SizedBox(height: 8 * s),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 13 * s),
        ),
        SizedBox(height: 8 * s),
        Text(
          equation,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: eqColor,
            fontWeight: FontWeight.w900,
            fontSize: (i == 2 ? 13.5 : 20) * s,
            letterSpacing: i == 2 ? 0.5 : 3,
            height: 1.35,
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: chip.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6 * s),
            border: Border.all(color: chip.withValues(alpha: 0.55)),
          ),
          child: Text(
            result,
            style: TextStyle(
              color: dark ? labShade(chip, 0.35) : labShade(chip, -0.45),
              fontWeight: FontWeight.w800,
              fontSize: 11.5 * s,
            ),
          ),
        ),
      ],
    );
  }

  /// Scenario 1 summary card: the respiration equation.
  Widget _s1Summary() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final dark = _lab.isDark;
    TextStyle st(Color c) => TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13.5 * s, height: 1.5);
    final plus = TextSpan(text: '  +  ', style: st(p.textMuted));
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate800 : _Colors.slate100,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _Colors.indigo500, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _t('lbl_chem_eq').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? _Colors.indigo400 : _Colors.indigo600,
              fontWeight: FontWeight.w900,
              fontSize: 11 * s,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 8 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 10 * s),
            decoration: BoxDecoration(
              color: dark ? _Colors.slate900 : Colors.white,
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: _t('lbl_glucose'), style: st(p.textStrong)),
                plus,
                TextSpan(text: 'O₂', style: st(dark ? _Colors.blue400 : _Colors.blue600)),
                TextSpan(text: '  →  ', style: st(_Colors.indigo500)),
                TextSpan(text: _t('lbl_energy'), style: st(dark ? _Colors.zslYellow : _Colors.amber700)),
                plus,
                TextSpan(text: 'H₂O', style: st(dark ? _Colors.blue200 : _Colors.blue700)),
                plus,
                TextSpan(
                  text: 'CO₂',
                  style: st(dark ? _Colors.red400 : _Colors.red600).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: _Colors.red,
                    decorationThickness: 2,
                  ),
                ),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            _t('lbl_s1_conc_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textMuted, fontSize: 11.5 * s, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Scenario 2 summary cards: snail, plant and the balance.
  Widget _s2Summary() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final dark = _lab.isDark;
    Widget card(Widget icon, String name, String role, String result, Color roleColor, Color resultColor) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: dark ? _Colors.slate800 : _Colors.slate100,
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate300),
          ),
          child: Column(
            children: [
              icon,
              SizedBox(height: 4 * s),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 11.5 * s),
              ),
              SizedBox(height: 2 * s),
              Text(
                role.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 9.5 * s, letterSpacing: 0.5),
              ),
              SizedBox(height: 4 * s),
              Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(color: resultColor, fontWeight: FontWeight.w900, fontSize: 11.5 * s),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card(
                _organismIcon(_Item.snail, 38 * s),
                _t('lbl_animal_snail'),
                _t('lbl_resp_only'),
                _t('lbl_high_co2'),
                dark ? _Colors.amber500 : _Colors.amber700,
                dark ? _Colors.yellow400 : _Colors.amber700,
              ),
              SizedBox(width: 8 * s),
              card(
                _organismIcon(_Item.plant, 38 * s),
                _t('lbl_plant_light'),
                _t('lbl_photo_dom'),
                _t('lbl_low_co2'),
                dark ? _Colors.green400 : _Colors.green700,
                dark ? _Colors.blue400 : _Colors.blue600,
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: dark ? _Colors.slate900 : Colors.white,
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: _Colors.green, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _organismIcon(_Item.snail, 34 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                    child: Icon(Icons.add, size: 18 * s, color: _Colors.slate500),
                  ),
                  _organismIcon(_Item.plant, 34 * s),
                ],
              ),
              SizedBox(height: 4 * s),
              Text(
                _t('lbl_perf_bal'),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w900, fontSize: 13 * s),
              ),
              SizedBox(height: 4 * s),
              Text(
                _t('lbl_s2_conc_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 11.5 * s, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================== PAINTING

extension _PathAt on Path {
  void moveAt(Offset o) => moveTo(o.dx, o.dy);
  void lineAt(Offset o) => lineTo(o.dx, o.dy);
  void quadAt(Offset c, Offset o) => quadraticBezierTo(c.dx, c.dy, o.dx, o.dy);
  void cubicAt(Offset a, Offset b, Offset o) => cubicTo(a.dx, a.dy, b.dx, b.dy, o.dx, o.dy);
}

/// One moong seed of a heap: position (units), rotation and colour tone.
class _Seed {
  const _Seed(this.x, this.y, this.z, this.rot, this.tone);
  final double x, y, z, rot, tone;
}

/// A heap of [n] seeds inside a circle of [radius] units, back to front.
List<_Seed> _makeSeeds(int n, double radius, int seed) {
  final rnd = math.Random(seed);
  final out = <_Seed>[];
  while (out.length < n) {
    final x = (rnd.nextDouble() * 2 - 1) * radius;
    final z = (rnd.nextDouble() * 2 - 1) * radius;
    final d = (x * x + z * z) / (radius * radius);
    if (d > 1) continue;
    out.add(_Seed(x, 0.05 + rnd.nextDouble() * 0.07 + (1 - d) * 0.1, z, rnd.nextDouble() * math.pi, rnd.nextDouble()));
  }
  out.sort((a, b) => a.z.compareTo(b.z));
  return out;
}

final List<_Seed> _flaskSeeds = _makeSeeds(150, 1.0, 7);
final List<_Seed> _beakerSeeds = _makeSeeds(26, 0.42, 3);

/// Cotton ball puffs (offset and radius in units, back to front).
const List<(double, double, double)> _puffs = [
  (-0.2, -0.15, 0.12),
  (0.0, -0.17, 0.13),
  (0.2, -0.14, 0.12),
  (-0.33, -0.04, 0.12),
  (-0.12, -0.05, 0.14),
  (0.1, -0.06, 0.14),
  (0.32, -0.03, 0.12),
  (-0.27, 0.07, 0.12),
  (-0.06, 0.07, 0.13),
  (0.15, 0.07, 0.13),
  (0.33, 0.08, 0.1),
  (-0.14, 0.14, 0.1),
  (0.07, 0.15, 0.1),
];

/// Moong seed (green oval with a highlight).
void _paintSeed(Canvas canvas, Offset c, double rot, double tone, {double scale = 1}) {
  final base = Color.lerp(const Color(0xFF3F6212), const Color(0xFF65A30D), tone)!;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(rot);
  final r = Rect.fromCenter(center: Offset.zero, width: 8.5 * scale, height: 6 * scale);
  canvas.drawOval(
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: [labShade(base, 0.45), base, labShade(base, -0.5)],
        stops: const [0, 0.55, 1],
      ).createShader(r),
  );
  canvas.restore();
}

/// Side view of the HTML snail (shell, body, head, eye stalks). [b] is the
/// bottom of the foot, [u] the px per unit.
void _paintSnail(Canvas canvas, Offset b, double u) {
  Offset q(double x, double y) => Offset(b.dx + x * u, b.dy - y * u);
  final body = Path()
    ..moveAt(q(-0.46, 0.02))
    ..quadAt(q(-0.2, 0.15), q(0.18, 0.14))
    ..quadAt(q(0.3, 0.15), q(0.34, 0.25))
    ..quadAt(q(0.39, 0.36), q(0.5, 0.31))
    ..quadAt(q(0.6, 0.23), q(0.53, 0.1))
    ..quadAt(q(0.48, 0.0), q(0.36, 0.0))
    ..lineAt(q(-0.3, 0.0))
    ..quadAt(q(-0.42, 0.0), q(-0.46, 0.02))
    ..close();
  final bodyRect = body.getBounds();
  // Eye stalk behind the head.
  final stalk = Paint()
    ..strokeWidth = math.max(1.2, 0.04 * u)
    ..strokeCap = StrokeCap.round
    ..color = _Colors.amber700;
  canvas.drawLine(q(0.41, 0.31), q(0.42, 0.5), stalk);
  canvas.drawCircle(q(0.42, 0.51), math.max(1.2, 0.035 * u), Paint()..color = const Color(0xFF111111));
  canvas.drawPath(
    body,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFBBF24), _Colors.amber600, Color(0xFF92400E)],
      ).createShader(bodyRect),
  );
  canvas.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, 0.015 * u)
      ..color = const Color(0x80451A03),
  );
  // Front eye stalk and tentacle.
  stalk.color = _Colors.amber600;
  canvas.drawLine(q(0.47, 0.3), q(0.55, 0.5), stalk);
  canvas.drawLine(q(0.55, 0.18), q(0.64, 0.2), stalk);
  final eye = q(0.555, 0.51);
  canvas.drawCircle(eye, math.max(1.3, 0.04 * u), Paint()..color = const Color(0xFF111111));
  canvas.drawCircle(eye + Offset(-0.012 * u, -0.012 * u), math.max(0.5, 0.013 * u), Paint()..color = Colors.white);
  // Shell with its spiral.
  final c = q(-0.06, 0.33);
  final shell = Rect.fromCenter(center: c, width: 0.6 * u, height: 0.56 * u);
  canvas.drawOval(
    shell,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.95,
        colors: [Color(0xFFD97706), _Colors.amber900, Color(0xFF451A03)],
        stops: [0, 0.6, 1],
      ).createShader(shell),
  );
  final spiral = Path();
  for (var i = 0; i <= 64; i++) {
    final a = i / 64 * 3.3 * math.pi;
    final r = 0.26 * (1 - a / (3.7 * math.pi));
    final o = c + Offset(math.cos(a + 1.2) * r * u, math.sin(a + 1.2) * r * u * 0.93);
    if (i == 0) {
      spiral.moveAt(o);
    } else {
      spiral.lineAt(o);
    }
  }
  canvas.drawPath(
    spiral,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, 0.03 * u)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x99FDE68A),
  );
  canvas.drawOval(
    shell,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, 0.018 * u)
      ..color = const Color(0x99451A03),
  );
  canvas.drawCircle(
    c + Offset(-0.12 * u, -0.12 * u),
    0.05 * u,
    Paint()..color = Colors.white.withValues(alpha: 0.35),
  );
}

/// Side view of the HTML water plant: a stem with six whorls of four
/// leaves. [b] is the bottom of the stem, [u] the px per unit.
void _paintPlant(Canvas canvas, Offset b, double u) {
  double sway(double y) => 0.04 * math.sin(y * 2.4);
  Offset q(double x, double y) => Offset(b.dx + x * u, b.dy - y * u);
  void leaf(double hy, double a, bool front) {
    final dx = math.cos(a), dz = math.sin(a);
    final base = q(sway(hy) + dx * 0.04, hy) + Offset(0, dz * 0.04 * u * _zk);
    final tip = q(sway(hy) + dx * 0.4, hy + 0.2) + Offset(0, dz * 0.4 * u * _zk);
    final d = tip - base;
    final len = d.distance;
    if (len < 0.5) return;
    final n = Offset(-d.dy, d.dx) / len * (0.065 * u);
    final mid = base + d * 0.45;
    final path = Path()
      ..moveAt(base)
      ..quadAt(mid + n, tip)
      ..quadAt(mid - n, base)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: front
              ? const [_Colors.green400, _Colors.green600]
              : const [_Colors.green700, Color(0xFF14532D)],
        ).createShader(Rect.fromPoints(base, tip).inflate(2)),
    );
    if (front && len > 6) {
      canvas.drawLine(
        base,
        base + d * 0.85,
        Paint()
          ..strokeWidth = 0.6
          ..color = _Colors.green300.withValues(alpha: 0.6),
      );
    }
  }

  final whorls = [
    for (var h = 0; h < 6; h++)
      for (var i = 0; i < 4; i++) (0.3 + h * 0.22, i * math.pi / 2 + h * math.pi / 8),
  ];
  for (final (hy, a) in whorls) {
    if (math.sin(a) < 0) leaf(hy, a, false);
  }
  final stem = Path()..moveAt(q(sway(0), 0));
  for (var y = 0.1; y <= 1.6001; y += 0.1) {
    stem.lineAt(q(sway(y), y));
  }
  canvas.drawPath(
    stem,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, 0.045 * u)
      ..strokeCap = StrokeCap.round
      ..color = _Colors.green700,
  );
  for (final (hy, a) in whorls) {
    if (math.sin(a) >= 0) leaf(hy, a, true);
  }
  // Growing tip.
  for (final a in const [-0.5, 0.5, 0.0]) {
    final base = q(sway(1.6), 1.56);
    final tip = base + Offset(math.sin(a) * 0.12 * u, -0.16 * u);
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..strokeWidth = math.max(1.6, 0.05 * u)
        ..strokeCap = StrokeCap.round
        ..color = _Colors.green400,
    );
  }
}

/// Snail and water plant together (HTML `snPModel`).
void _paintBoth(Canvas canvas, Offset b, double u, {double snailScale = 1.1}) {
  _paintPlant(canvas, b + Offset(0.16 * u, 0), u);
  _paintSnail(canvas, b + Offset(-0.18 * u, 0), u * snailScale);
}

/// Small snail / plant icon for the popups.
class _OrganismIconPainter extends CustomPainter {
  const _OrganismIconPainter(this.kind);

  final _Item kind;

  @override
  void paint(Canvas canvas, Size size) {
    if (kind == _Item.snail) {
      final u = size.width / 1.15;
      _paintSnail(canvas, Offset(size.width * 0.47, size.height * 0.82), u);
    } else {
      final u = size.height / 1.85;
      _paintPlant(canvas, Offset(size.width / 2, size.height * 0.97), u);
    }
  }

  @override
  bool shouldRepaint(covariant _OrganismIconPainter old) => old.kind != kind;
}

class _LabPainter extends CustomPainter {
  _LabPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  double get _t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRoom(canvas, size);
    if (scene.scenario == 0) {
      _paintScenario1(canvas, size);
    } else {
      _paintScenario2(canvas, size);
    }
  }

  // ------------------------------------------------------------ room

  void _paintRoom(Canvas canvas, Size size) {
    final b = labBleed(size);
    final back = _w(0, 0, -3).dy;
    final front = _w(0, 0, 3.6).dy;
    final bottom = front + 0.5 * _k;
    canvas.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, back),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1120), _Colors.slate900, Color(0xFF162036)]
              : const [Color(0xFFF0F9FF), _Colors.sky100, Color(0xFFC9E6F8)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(0, 0, size.width, back)),
    );
    // Soft lab light behind the apparatus.
    final glow = Rect.fromCircle(center: Offset(_cx + 40, 250), radius: 440);
    canvas.drawOval(
      glow,
      Paint()
        ..shader = RadialGradient(colors: [
          isDark ? const Color(0x1F6366F1) : const Color(0x66FFFFFF),
          isDark ? const Color(0x006366F1) : const Color(0x00FFFFFF),
        ]).createShader(glow),
    );
    // Table top (HTML `Mats.darkBase`).
    canvas.drawRect(
      Rect.fromLTRB(b.left, back, b.right, front),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF172133), Color(0xFF253349)]
              : const [Color(0xFF3B4A5F), Color(0xFF4F6077)],
        ).createShader(Rect.fromLTRB(0, back, size.width, front)),
    );
    canvas.drawLine(
      Offset(b.left, back),
      Offset(b.right, back),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawLine(
      Offset(b.left, front),
      Offset(b.right, front),
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.25),
    );
    canvas.drawRect(
      Rect.fromLTRB(b.left, front, b.right, bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF111A2B), Color(0xFF0B1220)]
              : const [Color(0xFF2B3A50), _Colors.slate800],
        ).createShader(Rect.fromLTRB(0, front, size.width, bottom)),
    );
    canvas.drawRect(
      Rect.fromLTRB(b.left, bottom, b.right, b.bottom),
      Paint()..color = isDark ? const Color(0xFF060A13) : const Color(0xFFB9D7EC),
    );
  }

  // ------------------------------------------------------- glass helpers

  Paint _glassFill(Rect bounds) => Paint()
    ..shader = LinearGradient(
      colors: isDark
          ? const [Color(0x2EFFFFFF), Color(0x0DFFFFFF), Color(0x05FFFFFF), Color(0x24FFFFFF)]
          : const [Color(0x66FFFFFF), Color(0x26FFFFFF), Color(0x14FFFFFF), Color(0x52FFFFFF)],
      stops: const [0, 0.3, 0.65, 1],
    ).createShader(bounds);

  /// Glass outline readable on both the dark table and the light wall.
  void _glassStroke(Canvas canvas, Path path, {double width = 1.6}) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = isDark ? const Color(0x59000000) : const Color(0x8C475569),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..color = isDark ? const Color(0xCCE2E8F0) : const Color(0xF2FFFFFF),
    );
  }

  void _highlight(Canvas canvas, List<Offset> pts, {double width = 3, double alpha = 0.4}) {
    final path = Path()..moveAt(pts.first);
    for (final p in pts.skip(1)) {
      path.lineAt(p);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: isDark ? alpha : math.min(1, alpha + 0.25)),
    );
  }

  /// Thin glass tube (cork tubes, delivery tube, dropper barrel).
  void _glassTube(Canvas canvas, Path path, double w) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w + 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = isDark ? const Color(0x80000000) : const Color(0x99475569),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = isDark ? const Color(0x80CBD5E1) : const Color(0xCCF1F5F9),
    );
    canvas.drawPath(
      path.shift(Offset(-w * 0.2, 0)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _bubble(Canvas canvas, Offset c, double r, {double alpha = 1}) {
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.22 * alpha));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: 0.8 * alpha),
    );
    canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.35), r * 0.32, Paint()..color = Colors.white.withValues(alpha: 0.9 * alpha));
  }

  // ------------------------------------------------------------ rack

  void _boxTop(Canvas canvas, double x0, double x1, double y, double z0, double z1, Color c) {
    final r = Rect.fromPoints(_w(x0, y, z0), _w(x1, y, z1));
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(c, -0.05), labShade(c, 0.3)],
        ).createShader(r),
    );
  }

  void _boxFront(Canvas canvas, double x0, double x1, double y0, double y1, double z, Color c) {
    final r = Rect.fromPoints(_w(x0, y1, z), _w(x1, y0, z));
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(c, 0.3), c, labShade(c, -0.35)],
        ).createShader(r),
    );
    canvas.drawLine(r.topLeft, r.topRight, Paint()..color = Colors.white.withValues(alpha: 0.6));
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = labShade(c, -0.55).withValues(alpha: 0.6),
    );
  }

  /// Test tube rack (HTML silver boxes): base, legs and the top face of the
  /// top bar with holes. The bar's front face is drawn after the tubes.
  void _rackBack(Canvas canvas, double cx, double width, double depth, List<double> holes) {
    final x0 = cx - width / 2, x1 = cx + width / 2;
    final z0 = -depth / 2, z1 = depth / 2;
    labGroundShadow(canvas, _w(cx, 0, 0.1), width * _k * 1.04, depth * _k * _zk * 2.4, opacity: 0.35);
    _boxTop(canvas, x0, x1, 0.2, z0, z1, _Colors.silver);
    _boxFront(canvas, x0, x1, 0, 0.2, z1, _Colors.silver);
    _boxFront(canvas, x0, x0 + 0.2, 0.2, 1.4, z1, _Colors.silver);
    _boxFront(canvas, x1 - 0.2, x1, 0.2, 1.4, z1, _Colors.silver);
    _boxTop(canvas, x0, x1, 1.6, z0, z1, _Colors.silver);
    for (final hx in holes) {
      canvas.drawOval(
        Rect.fromCenter(center: _w(hx, 1.6), width: 0.7 * _k, height: 0.7 * _k * _zk),
        Paint()..color = const Color(0x99000000),
      );
    }
  }

  void _rackFront(Canvas canvas, double cx, double width, double depth) {
    _boxFront(canvas, cx - width / 2, cx + width / 2, 1.4, 1.6, depth / 2, _Colors.silver);
  }

  // ------------------------------------------------------------ tubes

  /// Round-bottomed test tube standing at [b] (HTML `createTestTube`).
  void _paintTube(
    Canvas canvas,
    Offset b, {
    double fill = 0,
    Color liquid = _lime,
    double alpha = 0.5,
    double milk = 0,
    void Function(Canvas canvas)? contents,
    void Function(Canvas canvas)? overLiquid,
  }) {
    final outerR = 0.3 * _k, innerR = 0.25 * _k;
    final top = b.dy - 3.0 * _k;
    final cy = b.dy - outerR;
    Path outline(double rad, {bool close = false}) {
      final p = Path()
        ..moveTo(b.dx - rad, top)
        ..lineTo(b.dx - rad, cy)
        ..arcToPoint(Offset(b.dx + rad, cy), radius: Radius.circular(rad), clockwise: false)
        ..lineTo(b.dx + rad, top);
      if (close) p.close();
      return p;
    }

    final outer = outline(outerR, close: true);
    final inner = outline(innerR, close: true);
    canvas.drawPath(outer, _glassFill(Rect.fromLTRB(b.dx - outerR, top, b.dx + outerR, b.dy)));
    canvas.save();
    canvas.clipPath(inner);
    contents?.call(canvas);
    if (fill > 0.001) {
      final level = b.dy - _liquidTop * fill * _k;
      final lr = Rect.fromLTRB(b.dx - innerR, level, b.dx + innerR, b.dy);
      canvas.drawRect(
        lr,
        Paint()
          ..shader = LinearGradient(
            colors: [
              labShade(liquid, -0.25).withValues(alpha: alpha),
              liquid.withValues(alpha: alpha * 0.85),
              labShade(liquid, 0.2).withValues(alpha: alpha * 0.8),
              labShade(liquid, -0.3).withValues(alpha: alpha),
            ],
            stops: const [0, 0.35, 0.6, 1],
          ).createShader(lr),
      );
      if (milk > 0.02) {
        // Suspended chalk (calcium carbonate) specks.
        final rnd = math.Random(5);
        for (var i = 0; i < 26; i++) {
          final p = Offset(
            b.dx + (rnd.nextDouble() * 2 - 1) * innerR * 0.85,
            level + 4 + rnd.nextDouble() * (b.dy - level - 6),
          );
          canvas.drawCircle(p, 0.8 + rnd.nextDouble() * 1.2, Paint()..color = _Colors.slate300.withValues(alpha: 0.7 * milk));
        }
      }
      canvas.drawOval(
        Rect.fromCenter(center: Offset(b.dx, level), width: 2 * innerR, height: 2 * innerR * _zk),
        Paint()..color = labShade(liquid, 0.3).withValues(alpha: math.min(1, alpha + 0.15)),
      );
    }
    overLiquid?.call(canvas);
    canvas.restore();
    _highlight(canvas, [Offset(b.dx - outerR * 0.5, top + 10), Offset(b.dx - outerR * 0.5, cy)], width: 2.5, alpha: 0.35);
    _glassStroke(canvas, outline(outerR));
    final rim = Rect.fromCenter(center: Offset(b.dx, top), width: 0.7 * _k, height: 0.7 * _k * _zk);
    canvas.drawOval(rim, Paint()..color = (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2));
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = isDark ? const Color(0xE6E2E8F0) : _Colors.slate500,
    );
  }

  // ------------------------------------------------------- scenario 1

  /// Outline of the conical flask (HTML LatheGeometry), open at the mouth.
  Path _flaskPath(Offset b) {
    Offset q(double x, double y) => Offset(b.dx + x * _k, b.dy - y * _k);
    return Path()
      ..moveAt(q(-0.5, 3.1))
      ..quadAt(q(-0.4, 3.08), q(-0.4, 3.0))
      ..lineAt(q(-0.4, 2.2))
      ..quadAt(q(-0.4, 2.05), q(-0.5, 1.82))
      ..lineAt(q(-1.1, 0.4))
      ..quadAt(q(-1.2, 0.3), q(-1.2, 0.18))
      ..lineAt(q(-1.2, 0))
      ..arcTo(Rect.fromCenter(center: b, width: 2.4 * _k, height: 2.4 * _k * _zk), math.pi, -math.pi, false)
      ..lineAt(q(1.2, 0.18))
      ..quadAt(q(1.2, 0.3), q(1.1, 0.4))
      ..lineAt(q(0.5, 1.82))
      ..quadAt(q(0.4, 2.05), q(0.4, 2.2))
      ..lineAt(q(0.4, 3.0))
      ..quadAt(q(0.4, 3.08), q(0.5, 3.1));
  }

  void _paintFlask(Canvas canvas) {
    final sc = scene;
    final b = _w(0, 0);
    labGroundShadow(canvas, b.translate(6, 4), 2.7 * _k, 0.8 * _k, opacity: 0.4);
    final outline = _flaskPath(b);
    final body = Path.from(outline)..close();
    final bounds = body.getBounds();
    final baseOval = Rect.fromCenter(center: b, width: 2.4 * _k, height: 2.4 * _k * _zk);
    canvas.drawArc(
      baseOval,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: 0.3),
    );
    canvas.drawPath(body, _glassFill(bounds));

    canvas.save();
    canvas.clipPath(body);
    if (sc.seedsAdded) _paintSeedHeap(canvas, b);
    final cotton = sc.items[_Item.cotton];
    if (cotton != null && cotton.placed) {
      _paintCotton(canvas, _w(0, 0.42), wet: Curves.easeOut.transform(sc.ramp(sc.wetStart, 0.5)));
    }
    canvas.restore();

    _highlight(canvas, [
      b + const Offset(-0.27 * _k, -2.95 * _k),
      b + const Offset(-0.27 * _k, -2.15 * _k),
      b + const Offset(-0.9 * _k, -0.55 * _k),
    ], width: 3.5, alpha: 0.32);
    _highlight(canvas, [b + const Offset(0.85 * _k, -0.6 * _k), b + const Offset(0.62 * _k, -1.2 * _k)], width: 2, alpha: 0.2);
    _glassStroke(canvas, outline, width: 1.8);
    final rim = Rect.fromCenter(center: _w(0, 3.1), width: 1.0 * _k, height: 1.0 * _k * _zk);
    canvas.drawOval(rim, Paint()..color = (isDark ? Colors.black : _Colors.slate600).withValues(alpha: 0.25));
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = isDark ? const Color(0xE6E2E8F0) : _Colors.slate500,
    );
    if (sc.sealed) _paintCork(canvas, _corkOnFlask, inserted: true);
  }

  /// Moong seeds on the flask floor; after the time lapse some sprout.
  void _paintSeedHeap(Canvas canvas, Offset b) {
    final sc = scene;
    final germ = sc.lapsed ? Curves.easeOut.transform(sc.ramp(sc.lapseStart + 1.0, 3.0)) : 0.0;
    for (var i = 0; i < _flaskSeeds.length; i++) {
      final s = _flaskSeeds[i];
      final c = Offset(b.dx + s.x * _k, b.dy - s.y * _k + s.z * _k * _zk);
      _paintSeed(canvas, c, s.rot, s.tone);
      if (germ > 0 && i % 6 == 0) {
        final dir = s.x >= 0 ? 1.0 : -1.0;
        final len = 9 * germ;
        final path = Path()
          ..moveAt(c)
          ..quadAt(c + Offset(dir * len * 0.9, -len * 0.2), c + Offset(dir * len * 0.7, -len));
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFFF7FEE7).withValues(alpha: 0.95),
        );
      }
    }
  }

  /// Cotton ball centred at [c] (HTML ellipsoid 0.8 × 0.4); [wet] tints it.
  void _paintCotton(Canvas canvas, Offset c, {double wet = 0}) {
    final base = Color.lerp(Colors.white, const Color(0xFFCBD5E1), wet)!;
    // Soft fibres binding the puffs together.
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 0.95 * _k, height: 0.5 * _k),
      Paint()
        ..color = base.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    for (final (x, y, r) in _puffs) {
      final pc = c + Offset(x * _k, y * _k);
      final rr = Rect.fromCircle(center: pc, radius: r * _k);
      canvas.drawCircle(
        pc,
        r * _k,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.45),
            colors: [Colors.white, base, labShade(base, -0.28)],
            stops: const [0, 0.55, 1],
          ).createShader(rr),
      );
    }
    if (wet > 0) {
      final glint = Paint()..color = Colors.white.withValues(alpha: 0.95 * wet);
      final drop = Paint()..color = _Colors.blue300.withValues(alpha: 0.7 * wet);
      for (final o in const [Offset(-0.2, -0.08), Offset(0.12, -0.12), Offset(0.26, 0.04), Offset(-0.05, 0.1)]) {
        canvas.drawCircle(c + o * _k, 2.4, drop);
        canvas.drawCircle(c + o * _k + const Offset(-0.7, -0.7), 0.9, glint);
      }
    }
  }

  /// Beaker of moong seeds (HTML `Objects.s1.beaker`), standing at [b].
  void _paintBeaker(Canvas canvas, Offset b) {
    const r = 0.5, h = 1.2;
    final w = r * _k, eh = r * _k * _zk, top = b.dy - h * _k;
    labGroundShadow(canvas, b.translate(4, 3), 2.4 * w, 2.4 * eh, opacity: 0.4);
    final outline = Path()
      ..moveTo(b.dx - w - 4, top - 3)
      ..lineTo(b.dx - w, top + 3)
      ..lineTo(b.dx - w, b.dy)
      ..arcTo(Rect.fromCenter(center: b, width: 2 * w, height: 2 * eh), math.pi, -math.pi, false)
      ..lineTo(b.dx + w, top);
    final body = Path.from(outline)..close();
    final rimRect = Rect.fromCenter(center: Offset(b.dx, top), width: 2 * w, height: 2 * eh);
    canvas.drawArc(
      rimRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: 0.35),
    );
    canvas.drawPath(body, _glassFill(Rect.fromLTRB(b.dx - w, top, b.dx + w, b.dy)));
    canvas.save();
    canvas.clipPath(body);
    final st = b.dy - 0.4 * _k;
    final seeds = Rect.fromLTRB(b.dx - w, st, b.dx + w, b.dy + eh);
    canvas.drawRect(
      seeds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4D7C0F), Color(0xFF365314), Color(0xFF1A2E05)],
        ).createShader(seeds),
    );
    final rnd = math.Random(11);
    for (var row = 0; row < 4; row++) {
      for (var x = -w + 4; x < w; x += 8.5) {
        _paintSeed(
          canvas,
          Offset(b.dx + x + (row.isOdd ? 4 : 0), st + 7 + row * 5.5 + rnd.nextDouble() * 2),
          rnd.nextDouble() * math.pi,
          rnd.nextDouble() * 0.6,
          scale: 0.85,
        );
      }
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(b.dx, st), width: 2 * w - 2, height: 2 * eh),
      Paint()..color = const Color(0xFF4D7C0F),
    );
    for (final s in _beakerSeeds) {
      _paintSeed(canvas, Offset(b.dx + s.x * _k, st + s.z * _k * _zk - 1), s.rot, s.tone, scale: 0.85);
    }
    canvas.restore();
    _highlight(canvas, [Offset(b.dx - w * 0.62, top + 8), Offset(b.dx - w * 0.62, b.dy - 6)], width: 3, alpha: 0.35);
    _glassStroke(canvas, outline);
    canvas.drawOval(
      rimRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = isDark ? const Color(0xCCE2E8F0) : _Colors.slate500,
    );
    final grad = Paint()
      ..strokeWidth = 1.2
      ..color = (isDark ? Colors.white : _Colors.slate600).withValues(alpha: 0.55);
    for (var i = 1; i <= 3; i++) {
      final y = b.dy - h * _k * i / 4;
      canvas.drawLine(Offset(b.dx + w * 0.45, y), Offset(b.dx + w - 3, y), grad);
    }
  }

  /// Lime water bottle (HTML `Objects.s1.bottle`), standing at [b].
  void _paintBottle(Canvas canvas, Offset b) {
    Offset q(double x, double y) => Offset(b.dx + x * _k, b.dy - y * _k);
    final w = 0.6 * _k, eh = w * _zk;
    labGroundShadow(canvas, b.translate(5, 3), 2.5 * w, 2.4 * eh, opacity: 0.4);
    final base = Rect.fromCenter(center: b, width: 2 * w, height: 2 * eh);
    final outline = Path()
      ..moveAt(q(-0.2, 2.02))
      ..lineAt(q(-0.2, 1.95))
      ..cubicAt(q(-0.22, 1.72), q(-0.6, 1.72), q(-0.6, 1.45))
      ..lineAt(q(-0.6, 0))
      ..arcTo(base, math.pi, -math.pi, false)
      ..lineAt(q(0.6, 1.45))
      ..cubicAt(q(0.6, 1.72), q(0.22, 1.72), q(0.2, 1.95))
      ..lineAt(q(0.2, 2.02));
    final body = Path.from(outline)..close();
    final bounds = body.getBounds();
    canvas.drawPath(body, _glassFill(bounds));
    canvas.save();
    canvas.clipPath(body);
    final lt = q(0, 1.25).dy;
    final lr = Rect.fromLTRB(bounds.left, lt, bounds.right, b.dy + eh);
    canvas.drawRect(
      lr,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_lime, -0.2).withValues(alpha: 0.55),
          _lime.withValues(alpha: 0.4),
          labShade(_lime, 0.25).withValues(alpha: 0.38),
          labShade(_lime, -0.25).withValues(alpha: 0.55),
        ], stops: const [0, 0.35, 0.6, 1]).createShader(lr),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(b.dx, lt), width: 2 * w, height: 2 * eh),
      Paint()..color = labShade(_lime, 0.35).withValues(alpha: 0.6),
    );
    canvas.restore();
    // Paper label.
    final label = Rect.fromLTRB(q(-0.5, 0).dx, q(0, 0.98).dy, q(0.5, 0).dx, q(0, 0.42).dy);
    canvas.drawRRect(RRect.fromRectAndRadius(label, const Radius.circular(4)), Paint()..color = const Color(0xF2F8FAFC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(label, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate400,
    );
    labText(canvas, 'Ca(OH)₂', label.center, size: 10.5, color: _Colors.slate900, weight: FontWeight.w800);
    _highlight(canvas, [q(-0.42, 1.35), q(-0.42, 1.05)], width: 3, alpha: 0.4);
    _highlight(canvas, [q(-0.42, 0.35), q(-0.42, 0.12)], width: 3, alpha: 0.4);
    _glassStroke(canvas, outline);
    // Cap.
    labCylinder(
      canvas,
      Rect.fromLTRB(q(-0.22, 0).dx, q(0, 2.22).dy, q(0.22, 0).dx, q(0, 2.0).dy),
      const Color(0xFF3F3F46),
      tilt: _zk,
    );
  }

  /// Cork with its two glass tubes (HTML `Objects.s1.cork`); [b] is the
  /// bottom of the cork. [inserted]: sitting in the flask neck.
  void _paintCork(Canvas canvas, Offset b, {bool inserted = false}) {
    Offset q(double x, double y) => Offset(b.dx + x * _k, b.dy - y * _k);
    if (!inserted) labGroundShadow(canvas, b.translate(4, 2), 1.0 * _k, 0.3 * _k, opacity: 0.45);
    if (inserted) {
      _glassTube(canvas, Path()..moveAt(q(-0.15, -0.25))..lineAt(q(-0.15, 0.05)), 5);
      _glassTube(canvas, Path()..moveAt(q(0.15, -0.25))..lineAt(q(0.15, 0.05)), 5);
    }
    final topOval = Rect.fromCenter(center: q(0, 0.5), width: 0.8 * _k, height: 0.8 * _k * _zk);
    final body = Path()
      ..moveAt(q(-0.4, 0.5))
      ..lineAt(q(-0.35, 0))
      ..arcTo(Rect.fromCenter(center: b, width: 0.7 * _k, height: 0.7 * _k * _zk), math.pi, -math.pi, false)
      ..lineAt(q(0.4, 0.5))
      ..close();
    final bounds = body.getBounds();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_Colors.cork, -0.35),
          labShade(_Colors.cork, 0.25),
          _Colors.cork,
          labShade(_Colors.cork, -0.45),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(bounds),
    );
    canvas.drawOval(topOval, Paint()..color = labShade(_Colors.cork, 0.3));
    final speck = Paint()..color = labShade(_Colors.cork, -0.45).withValues(alpha: 0.7);
    for (final o in const [Offset(-0.22, 0.32), Offset(0.05, 0.18), Offset(0.24, 0.36), Offset(-0.08, 0.4), Offset(0.18, 0.12)]) {
      canvas.drawCircle(q(o.dx, o.dy), 1.3, speck);
    }
    for (final x in const [-0.15, 0.15]) {
      canvas.drawOval(
        Rect.fromCenter(center: q(x, 0.5), width: 8, height: 3),
        Paint()..color = const Color(0xFF2B1505),
      );
    }
    _glassTube(canvas, Path()..moveAt(q(-0.15, 0.5))..lineAt(q(-0.15, 0.85)), 5);
    _glassTube(
      canvas,
      Path()
        ..moveAt(q(0.15, 0.5))
        ..lineAt(q(0.15, 0.85))
        ..quadAt(q(0.15, 1.05), q(0.4, 1.05))
        ..lineAt(q(0.55, 1.05)),
      5,
    );
  }

  /// Rubber pipe from the cork's bent tube to Test Tube A (HTML
  /// CatmullRom pipe), drawn on over 0.6 s.
  Path _pipePath() => Path()
    ..moveAt(_w(0.55, 4.0))
    ..cubicAt(_w(1.55, 4.28), _w(_tubeAX, 4.32), _w(_tubeAX, 3.62));

  void _paintPipe(Canvas canvas) {
    final f = Curves.easeOut.transform(scene.ramp(scene.connectStart, 0.6));
    if (f <= 0) return;
    final metric = _pipePath().computeMetrics().first;
    final part = metric.extractPath(0, metric.length * f);
    canvas.drawPath(
      part,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF431407),
    );
    canvas.drawPath(
      part,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFC2410C),
    );
    canvas.drawPath(
      part.shift(const Offset(-1.2, -1.6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFDBA74).withValues(alpha: 0.6),
    );
    // Collars where the rubber meets the glass.
    final collar = Paint()..color = const Color(0xFF7C2D12);
    canvas.drawCircle(_w(0.55, 4.0), 5.5, collar);
    if (f >= 1) canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: _w(_tubeAX, 3.66), width: 12, height: 7), const Radius.circular(2)), collar);
  }

  /// Route of the CO₂ bubbles: delivery tube in the flask, bent tube, pipe
  /// and the glass tube dipping into Test Tube A.
  Path _bubbleRoute() => Path()
    ..moveAt(_w(0.15, 2.7))
    ..lineAt(_w(0.15, 3.8))
    ..quadAt(_w(0.15, 4.0), _w(0.4, 4.0))
    ..lineAt(_w(0.55, 4.0))
    ..cubicAt(_w(1.55, 4.28), _w(_tubeAX, 4.32), _w(_tubeAX, 3.62))
    ..lineAt(_w(_tubeAX, 0.85));

  /// HTML bubble system: 15 bubbles cycling flask → pipe → Test Tube A.
  void _paintS1Bubbles(Canvas canvas) {
    final sc = scene;
    final dt = _t - sc.lapseStart;
    final route = _bubbleRoute().computeMetrics().first;
    final surface = _tubeBase + _liquidTop;
    for (var i = 0; i < 15; i++) {
      final speed = (0.005 + i * 0.001) * 60 * 0.55;
      final p = ((i * 0.137) % 1 + speed * dt) % 1;
      if (p < 0.4) {
        // Rising off the seeds towards the delivery tube.
        final v = p / 0.4;
        final x = 0.15 + math.sin(v * 7 + i) * 0.25 * (1 - v);
        _bubble(canvas, _w(x, 0.75 + v * 1.95), 3.2, alpha: 0.85);
      } else if (p < 0.8) {
        final v = (p - 0.4) / 0.4;
        final tan = route.getTangentForOffset(route.length * v);
        if (tan != null) _bubble(canvas, tan.position, 2.4);
      } else {
        // Bubbling up through the lime water in Test Tube A.
        final v = (p - 0.8) / 0.2;
        final x = _tubeAX + math.sin(v * 9 + i) * 0.07;
        _bubble(canvas, _w(x, 0.85 + v * (surface - 0.9)), 3.0);
      }
    }
  }

  /// Dropper (HTML `Objects.s1.dropper`): glass barrel and rubber bulb.
  /// [tip] is the nozzle, [angle] the tilt (radians, clockwise).
  void _paintDropper(Canvas canvas, Offset tip, double angle, {Color? liquid, bool shadow = true}) {
    if (shadow) labGroundShadow(canvas, tip.translate(22, 4), 1.4 * _k, 0.28 * _k, opacity: 0.35);
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    const u = _k;
    final barrel = Path()
      ..moveTo(-1.6, 0)
      ..lineTo(-3.6, -0.3 * u)
      ..lineTo(-3.6, -1.0 * u)
      ..lineTo(3.6, -1.0 * u)
      ..lineTo(3.6, -0.3 * u)
      ..lineTo(1.6, 0)
      ..close();
    canvas.drawPath(barrel, Paint()..color = (isDark ? Colors.white : _Colors.slate200).withValues(alpha: isDark ? 0.2 : 0.7));
    if (liquid != null) {
      canvas.drawRect(Rect.fromLTRB(-2.4, -0.92 * u, 2.4, -0.12 * u), Paint()..color = liquid.withValues(alpha: 0.85));
    }
    canvas.drawPath(
      barrel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = isDark ? const Color(0xCCE2E8F0) : _Colors.slate600,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(-5.5, -1.07 * u, 5.5, -0.97 * u), const Radius.circular(2)),
      Paint()..color = const Color(0xFF7F1D1D),
    );
    final bulb = Rect.fromCenter(center: const Offset(0, -1.25 * u), width: 0.4 * u, height: 0.6 * u);
    canvas.drawOval(
      bulb,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Color(0xFFF87171), _Colors.red600, Color(0xFF7F1D1D)],
          stops: [0, 0.55, 1],
        ).createShader(bulb),
    );
    canvas.restore();
  }

  /// Scenario 1 dropper: idle on the table, then moving into the flask and
  /// dripping onto the cotton (HTML `handleObjectClick` for the dropper).
  void _paintS1Dropper(Canvas canvas) {
    final sc = scene;
    if (sc.step != 1 || sc.dropperUsed) return;
    if (sc.dropperStart < 0) {
      _paintDropper(canvas, _s1DropperTip, math.pi / 6);
      return;
    }
    final dt = _t - sc.dropperStart;
    final m = Curves.easeInOut.transform((dt / 0.3).clamp(0.0, 1.0));
    final target = _w(0, 2.05);
    final arc = Offset(0, -math.sin(m * math.pi) * 60);
    final tip = Offset.lerp(_s1DropperTip, target, m)! + arc;
    _paintDropper(canvas, tip, math.pi / 6 * (1 - m), shadow: m < 0.2);
    if (dt > 0.3) {
      // Three drops falling onto the cotton.
      final cotton = _w(0, 0.62).dy;
      for (var j = 0; j < 3; j++) {
        final v = (dt - 0.3 - j * 0.16) / 0.22;
        if (v < 0 || v > 1) continue;
        final y = target.dy + (cotton - target.dy) * v * v;
        final c = Offset(target.dx, y);
        final drop = Path()
          ..moveTo(c.dx, c.dy - 9)
          ..quadraticBezierTo(c.dx + 6, c.dy, c.dx, c.dy + 4.5)
          ..quadraticBezierTo(c.dx - 6, c.dy, c.dx, c.dy - 9)
          ..close();
        canvas.drawPath(drop, Paint()..color = _Colors.blue300.withValues(alpha: 0.95));
        canvas.drawCircle(c + const Offset(-1.5, 0), 1.3, Paint()..color = Colors.white);
      }
    }
  }

  void _paintScenario1(Canvas canvas, Size size) {
    final sc = scene;
    final step = sc.step;
    if (step >= 2) {
      final fill = Curves.easeInOut.transform(sc.ramp(sc.fillStart, 1.0));
      final milk = sc.lapsed ? Curves.easeInOut.transform(sc.ramp(sc.lapseStart + 2.0, 1.2)) : 0.0;
      _rackBack(canvas, _rackS1X, 3.0, 1.0, const [_tubeAX, _tubeBX]);
      _paintTube(
        canvas,
        _w(_tubeAX, _tubeBase),
        fill: fill,
        liquid: Color.lerp(_lime, _milk, milk)!,
        alpha: 0.45 + 0.5 * milk,
        milk: milk,
      );
      _paintTube(canvas, _w(_tubeBX, _tubeBase), fill: fill, alpha: 0.45);
      if (sc.connected && sc.ramp(sc.connectStart, 0.6) >= 1) {
        _glassTube(canvas, Path()..moveAt(_w(_tubeAX, 3.64))..lineAt(_w(_tubeAX, 0.85)), 5);
      }
      _rackFront(canvas, _rackS1X, 3.0, 1.0);
    }
    _paintFlask(canvas);
    if (sc.connected) _paintPipe(canvas);

    // Objects on the table, back to front.
    if (step == 1) _paintS1Dropper(canvas);
    final table = [
      for (final it in sc.items.values)
        if (it != sc.drag && _onTableS1(it)) it,
    ]..sort((a, b) => a.home.dy.compareTo(b.home.dy));
    for (final it in table) {
      _paintItem(canvas, it, it.drawPos(_t));
    }
    _paintDragged(canvas);

    // Things to click.
    if (step == 1 && sc.cottonAdded && sc.dropperStart < 0) {
      _pulse(canvas, Rect.fromCenter(center: _s1DropperTip + const Offset(0.62 * _k, -1.08 * _k), width: 0.9 * _k, height: 1.0 * _k));
    }
    if (step == 5) {
      _pulse(canvas, Rect.fromLTRB(_w(_tubeAX - 0.45, 0).dx, _w(0, 3.4).dy, _w(_tubeAX + 0.45, 0).dx, _w(0, 0.1).dy));
    }

    // 24 h in the dark (HTML #darkness-overlay, black / 60%).
    if (sc.lapsed) {
      final dt = _t - sc.lapseStart;
      final dark = dt < 1 ? dt : (dt < 4 ? 1.0 : (dt < 5 ? 5 - dt : 0.0));
      if (dark > 0) {
        canvas.drawRect(labBleed(size), Paint()..color = Colors.black.withValues(alpha: 0.6 * dark));
      }
      _paintS1Bubbles(canvas);
    }
    _paintS1Labels(canvas);
  }

  bool _onTableS1(_Draggable it) {
    final step = scene.step;
    return switch (it.id) {
      _Item.beaker => step == 1 && !it.hidden,
      _Item.cotton => step == 1 && !it.placed,
      _Item.bottle => step == 2 && !it.hidden,
      _Item.cork => step >= 3 && !it.placed,
      _ => false,
    };
  }

  void _paintS1Labels(Canvas canvas) {
    if (!showLabels) return;
    final sc = scene;
    final step = sc.step;
    _tag(canvas, tr('lbl_flask'), sc.sealed ? _w(-0.55, 2.5) : _w(0, 3.3), anchor: sc.sealed ? Alignment.centerRight : Alignment.bottomCenter);
    final cotton = sc.items[_Item.cotton]!;
    if (cotton.placed) {
      _tag(canvas, tr('lbl_cotton'), _w(0, 0.95));
    } else if (step == 1 && cotton != sc.drag) {
      _tag(canvas, tr('lbl_cotton'), cotton.drawPos(_t) + const Offset(0, -0.72 * _k));
    }
    final beaker = sc.items[_Item.beaker]!;
    if (step == 1 && !beaker.hidden && beaker != sc.drag) {
      _tag(canvas, tr('lbl_beaker'), beaker.drawPos(_t) + const Offset(0, -1.42 * _k));
    }
    if (step == 1 && !sc.dropperUsed && sc.dropperStart < 0) {
      _tag(canvas, tr('lbl_dropper'), _s1DropperTip + const Offset(0.3 * _k, -1.12 * _k), anchor: Alignment.centerRight);
    }
    if (step >= 2) {
      _tag(canvas, tr('lbl_tube_a'), _w(_tubeAX, 4.62));
      _tag(canvas, tr('lbl_tube_b'), _w(_tubeBX, 3.48));
    }
    final bottle = sc.items[_Item.bottle]!;
    if (step == 2 && !bottle.hidden && bottle != sc.drag) {
      _tag(canvas, tr('lbl_bottle'), bottle.drawPos(_t) + const Offset(0, -2.4 * _k));
    }
    final cork = sc.items[_Item.cork]!;
    if (step >= 3) {
      if (cork.placed) {
        _tag(canvas, tr('lbl_cork'), _w(-0.5, 3.35), anchor: Alignment.centerRight);
      } else if (cork != sc.drag) {
        _tag(canvas, tr('lbl_cork'), cork.drawPos(_t) + const Offset(0, -1.3 * _k));
      }
    }
    if (sc.lapsed && sc.connected) {
      _tag(canvas, tr('lbl_co2'), _w(0.85, 4.5), color: _Colors.red400);
    }
  }

  // ------------------------------------------------------- scenario 2

  Color _indicator(int i, double change) => switch (i) {
        0 => Color.lerp(_Colors.blue, _Colors.zslYellow, change)!,
        2 => Color.lerp(_Colors.blue, _Colors.emerald500, change)!,
        _ => _Colors.blue,
      };

  /// Organisms that were dropped into tube [i].
  void _tubeOrganisms(Canvas canvas, int i) {
    final tx = _s2TubeX[i];
    for (final it in scene.items.values) {
      if (!it.placed || _targetTube[it.id] != i) continue;
      switch (it.id) {
        case _Item.snail:
          _paintSnail(canvas, _w(tx - 0.05, 0.27), 0.56 * _k);
        case _Item.plant:
          _paintPlant(canvas, _w(tx, 0.27), 0.85 * _k);
        case _Item.both:
          _paintPlant(canvas, _w(tx + 0.07, 0.27), 0.8 * _k);
          _paintSnail(canvas, _w(tx - 0.07, 0.27), 0.48 * _k);
        default:
          break;
      }
    }
  }

  /// CO₂ (snail) and O₂ (plant) bubbles after the time lapse.
  void _tubeBubbles(Canvas canvas, int i) {
    if (i == 3) return;
    final tx = _s2TubeX[i];
    final dt = _t - scene.lapseStart;
    final surface = _tubeBase + _liquidTop;
    for (var j = 0; j < 5; j++) {
      final v = (j / 5 + dt * (0.32 + i * 0.05)) % 1;
      final x = tx + math.sin(v * 8 + j * 2.1) * 0.08 + (j.isEven ? -0.05 : 0.05);
      _bubble(canvas, _w(x, 0.55 + v * (surface - 0.6)), 2.4, alpha: 0.8);
    }
  }

  void _lightCone(Canvas canvas, double a) {
    final top = _w(0, 5.08);
    final cone = Path()
      ..moveAt(top + const Offset(-0.62 * _k, 0))
      ..lineAt(top + const Offset(0.62 * _k, 0))
      ..lineAt(_w(4.5, 0, 0.8))
      ..lineAt(_w(-4.5, 0, 0.8))
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _Colors.yellow200.withValues(alpha: (isDark ? 0.3 : 0.45) * a),
            _Colors.yellow200.withValues(alpha: (isDark ? 0.07 : 0.12) * a),
          ],
        ).createShader(cone.getBounds()),
    );
    final pool = Rect.fromCenter(center: _w(0, 0, 0.6), width: 9.6 * _k, height: 2.0 * _k);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(colors: [
          _Colors.yellow200.withValues(alpha: 0.25 * a),
          _Colors.yellow200.withValues(alpha: 0),
        ]).createShader(pool),
    );
  }

  /// Sun lamp (HTML `Objects.s2.sunLamp`), hanging above the rack.
  void _paintLamp(Canvas canvas, Size size, double a) {
    final c = _w(0, 5.2);
    canvas.drawLine(
      Offset(c.dx, labBleed(size).top),
      Offset(c.dx, c.dy - 0.6 * _k),
      Paint()
        ..strokeWidth = 3
        ..color = _Colors.slate600.withValues(alpha: a),
    );
    final dome = Rect.fromCenter(center: c, width: 1.7 * _k, height: 1.3 * _k);
    final domePath = Path()
      ..addArc(dome, math.pi, math.pi)
      ..close();
    canvas.drawPath(
      domePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF64748B).withValues(alpha: a), _Colors.slate800.withValues(alpha: a)],
        ).createShader(dome),
    );
    final mouth = Rect.fromCenter(center: c, width: 1.7 * _k, height: 1.7 * _k * _zk);
    canvas.drawOval(mouth, Paint()..color = const Color(0xFFFEF9C3).withValues(alpha: 0.9 * a));
    canvas.drawOval(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.slate500.withValues(alpha: a),
    );
    labGlow(canvas, c + const Offset(0, 0.12 * _k), 2.2 * _k, _Colors.yellow200, intensity: 0.75 * a);
    labSphere(canvas, c + const Offset(0, 0.1 * _k), 0.3 * _k, const Color(0xFFFFFBEB), highlight: 0.8, shade: 0.12, opacity: a);
  }

  void _paintScenario2(Canvas canvas, Size size) {
    final sc = scene;
    final step = sc.step;
    final fill = Curves.easeInOut.transform(sc.ramp(sc.fillStart, 1.0));
    final change = sc.lapsed ? Curves.easeInOut.transform(sc.ramp(sc.lapseStart + 1.5, 1.0)) : 0.0;
    final lamp = sc.lampOn ? Curves.easeOut.transform(sc.ramp(sc.lampStart, 0.45)) : 0.0;
    if (lamp > 0) _lightCone(canvas, lamp);
    _rackBack(canvas, 0, 8, 1.5, _s2TubeX);
    for (var i = 0; i < _s2TubeX.length; i++) {
      _paintTube(
        canvas,
        _w(_s2TubeX[i], _tubeBase),
        fill: fill,
        liquid: _indicator(i, change),
        alpha: 0.62,
        contents: (c) => _tubeOrganisms(c, i),
        overLiquid: sc.lapsed ? (c) => _tubeBubbles(c, i) : null,
      );
    }
    _rackFront(canvas, 0, 8, 1.5);
    if (lamp > 0) _paintLamp(canvas, size, lamp);

    if (step == 3 && sc.fillStart < 0) {
      _paintDropper(canvas, _s2DropperTip, math.pi / 6, liquid: _Colors.blue);
      _pulse(canvas, Rect.fromCenter(center: _s2DropperTip + const Offset(0.5 * _k, -0.9 * _k), width: 1.1 * _k, height: 1.6 * _k));
    }
    if (step >= 2) {
      final table = [
        for (final it in sc.items.values)
          if (!it.placed && it != sc.drag) it,
      ]..sort((a, b) => a.home.dx.compareTo(b.home.dx));
      for (final it in table) {
        _paintItem(canvas, it, it.drawPos(_t));
      }
    }
    _paintDragged(canvas);
    if (step == 5) {
      for (var i = 0; i < _s2TubeX.length; i++) {
        if (sc.clickedTubes.contains(i)) continue;
        final x = _s2TubeX[i];
        _pulse(canvas, Rect.fromLTRB(_w(x - 0.42, 0).dx, _w(0, 3.4).dy, _w(x + 0.42, 0).dx, _w(0, 0.1).dy));
      }
    }
    _paintS2Labels(canvas);
  }

  void _paintS2Labels(Canvas canvas) {
    if (!showLabels) return;
    final sc = scene;
    for (var i = 0; i < _s2TubeX.length; i++) {
      _tag(canvas, _tubeLetters[i], _w(_s2TubeX[i], 3.48));
    }
    if (sc.step == 3 && sc.fillStart < 0) {
      _tag(canvas, tr('lbl_dropper'), _s2DropperTip + const Offset(0.3 * _k, -1.12 * _k), anchor: Alignment.centerRight);
    }
    if (sc.step < 2) return;
    for (final it in sc.items.values) {
      if (it.placed || it == sc.drag) continue;
      final key = switch (it.id) {
        _Item.snail => 'lbl_snail',
        _Item.plant => 'lbl_plant',
        _ => 'lbl_snp',
      };
      // Below the object, clear of the rack behind it.
      _tag(canvas, tr(key), it.drawPos(_t) + const Offset(0, 0.12 * _k), anchor: Alignment.topCenter);
    }
  }

  // ------------------------------------------------------- shared bits

  void _paintItem(Canvas canvas, _Draggable it, Offset p) {
    switch (it.id) {
      case _Item.beaker:
        _paintBeaker(canvas, p);
      case _Item.cotton:
        labGroundShadow(canvas, p.translate(3, 2), 0.95 * _k, 0.28 * _k, opacity: 0.4);
        _paintCotton(canvas, p + const Offset(0, -0.22 * _k));
      case _Item.bottle:
        _paintBottle(canvas, p);
      case _Item.cork:
        _paintCork(canvas, p);
      case _Item.snail:
        labGroundShadow(canvas, p.translate(4, 2), 1.1 * _k, 0.3 * _k, opacity: 0.4);
        _paintSnail(canvas, p, 1.25 * _k);
      case _Item.plant:
        labGroundShadow(canvas, p.translate(4, 2), 0.9 * _k, 0.28 * _k, opacity: 0.4);
        _paintPlant(canvas, p, _k);
      case _Item.both:
        labGroundShadow(canvas, p.translate(4, 2), 1.3 * _k, 0.3 * _k, opacity: 0.4);
        _paintBoth(canvas, p, _k);
    }
  }

  /// The object being dragged, lifted above the table, and its drop zone.
  void _paintDragged(Canvas canvas) {
    final sc = scene;
    final it = sc.drag;
    if (it == null) return;
    final hot = sc.overTarget(it);
    final zone = switch (it.id) {
      _Item.beaker || _Item.cotton || _Item.cork =>
        Rect.fromLTRB(_w(-1.55, 0).dx, _w(0, 3.5).dy, _w(1.55, 0).dx, _gy + 0.55 * _k),
      _Item.bottle => Rect.fromLTRB(_w(1.95, 0).dx, _w(0, 3.65).dy, _w(5.05, 0).dx, _gy + 0.45 * _k),
      _ => Rect.fromLTRB(
          _w(_s2TubeX[_targetTube[it.id]!] - 0.55, 0).dx,
          _w(0, 3.6).dy,
          _w(_s2TubeX[_targetTube[it.id]!] + 0.55, 0).dx,
          _gy + 0.4 * _k,
        ),
    };
    final c = hot ? _Colors.green400 : _Colors.indigo400;
    final rr = RRect.fromRectAndRadius(zone, const Radius.circular(16));
    canvas.drawRRect(rr, Paint()..color = c.withValues(alpha: hot ? 0.16 : 0.07));
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = c.withValues(alpha: 0.9),
      dash: 10,
      gap: 7,
      phase: _t * 30,
    );
    _paintItem(canvas, it, it.pos + const Offset(0, -8));
  }

  /// Pulsing ring around something to click.
  void _pulse(Canvas canvas, Rect r) {
    final v = 0.5 + 0.5 * math.sin(_t * 4);
    final rr = RRect.fromRectAndRadius(r.inflate(3 + 3 * v), const Radius.circular(14));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = _Colors.indigo500.withValues(alpha: 0.12 + 0.14 * v)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.indigo400.withValues(alpha: 0.45 + 0.4 * v),
    );
  }

  /// HTML `.hotspot-label`: glass chip with a blue border and blue text.
  void _tag(Canvas canvas, String text, Offset at, {Alignment anchor = Alignment.bottomCenter, Color? color}) {
    labText(
      canvas,
      text,
      at,
      size: 15,
      weight: FontWeight.w800,
      color: color ?? (isDark ? _Colors.blue400 : _Colors.blue600),
      background: isDark ? const Color(0xEB0F172A) : const Color(0xF2FFFFFF),
      border: color ?? _Colors.blue,
      borderWidth: 2,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      anchor: anchor,
    );
  }

  @override
  bool shouldRepaint(covariant _LabPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
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
