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

/// Class 6 Science • Chapter 3 • Activity 3
/// Protective Nutrients and Deficiency Disorders ("The Protective Shield:
/// Understanding Vitamins, Minerals, and Deficiency Disorders").
///
/// Native Flutter port of
/// `Cl6S-Ch03-A3-Protective_Nutrients_and_Deficiency_Disorders.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML camera: position (0, 10, 16), look-at
/// (0, 1, 0), 45° field of view, and its close-ups.
///
/// Scenario 1 (The Sailor's Scurvy): on a ship's deck a slouching sailor's
/// Health Meter reads 20%. Tapping the magnifying glass on his mouth zooms
/// in on red, bleeding gums. Salted Beef or a Hardtack Biscuit dragged onto
/// his Meal Tray brings 'No Change' (he shakes his head; the meter only
/// rises to 50%); the Orange (Vitamin C) heals the gums pink, the sailor
/// stands up straight and the meter fills to green.
///
/// Scenario 2 (The Goitre Solution): a villager from a mountain village has
/// a swollen neck (goitre). Tapping the magnifying glass on the neck zooms
/// in on it. Common Salt sprinkled on the Meal Plate brings 'No Change';
/// Iodised Salt (iodine) shrinks the swelling away and the meter fills to
/// green. 'Review Findings' opens each summary.
class Ch3A3ProtectiveNutrientsAndDeficiencyDisordersPage
    extends StatefulWidget {
  const Ch3A3ProtectiveNutrientsAndDeficiencyDisordersPage({super.key});

  @override
  State<Ch3A3ProtectiveNutrientsAndDeficiencyDisordersPage> createState() =>
      _ProtectiveLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'click' (a magnifying glass tapped) and 'pop' (a missed drop going back,
/// `resetCamera()` after a close-up) → click (`science/click.mp3`), 'heal'
/// (the orange or the iodised salt works) → correct, 'error' ('No Change')
/// → wrong (`science/error.mp3`), 'chime' ('Review Findings' appears) and
/// 'success' (the summary opens) → success (both `math/success.mp3`). The
/// shell plays toggle (`science/dropdown.mp3`), scenario
/// (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; a magnifying glass tapped (HTML `click`), a
  /// missed drop and the camera jumping back (HTML `pop`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// The orange or the iodised salt cures the patient (HTML `heal`).
  correct('audio/class6/math/success.mp3'),

  /// 'No Change' after the wrong food or salt, a press out of turn (HTML
  /// `error`).
  wrong('audio/class6/science/error.mp3'),

  /// 'Review Findings' appears (HTML `chime`) and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3');

  const _Sound(this.asset);

  /// Path of the sound inside `assets/`.
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

/// Colours of the HTML page (Tailwind classes), of its Three.js scene
/// (material colours) and of its SVG icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color green500 = Color(0xFF22C55E);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose500 = Color(0xFFF43F5E);
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
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark theme), 0xe0f2fe (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// `Mats.wood` (deck, railing, crate, shelf) and the village ground
  /// (`0x78350f`).
  static const Color wood = Color(0xFF8B4513);
  static const Color soil = Color(0xFF78350F);

  /// `Mats.metal` (meal tray, meal plate) and the food on the plate.
  static const Color metal = slate400;
  static const Color plateFood = Color(0xFFD97706);

  /// `Mats.skin`, `Mats.skinDark`, `Mats.clothesW` / `clothesB` /
  /// `clothesR`, the villager's trousers and the eyes.
  static const Color skin = Color(0xFFEEC1AD);
  static const Color skinDark = Color(0xFF8B5A2B);
  static const Color clothesWhite = Color(0xFFF8FAFC);
  static const Color clothesBlue = Color(0xFF1E3A8A);
  static const Color clothesRed = Color(0xFF991B1B);
  static const Color trousers = Color(0xFF333333);
  static const Color eye = black;

  /// Text sprites: `#1e293b` chip, `#10b981` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = emerald500;
  static const Color chipText = white;

  /// Status bar sprite: `#1e293b` box, `#cbd5e1` border; fill red, yellow
  /// or green; white caption and percentage.
  static const Color barBg = slate800;
  static const Color barBorder = slate300;
  static const Color barLow = red500;
  static const Color barMid = yellow500;
  static const Color barHigh = green500;
  static const Color barText = white;

  /// Soft contact shadows (the HTML scene casts PCF soft shadows) and the
  /// icons' drop shadow (`drop-shadow-md`).
  static const Color shadow = Color(0x52000000);
  static const Color iconShadow = Color(0x59000000);

  // -------------------------------------------------------- icons (SVGs)
  static const Color orange = amber500;
  static const Color shakerGrey = slate400;
  static const Color shakerBlue = blue500;
  static const Color shakerDot = Color(0xFFF8FAFC);
  static const Color beef = Color(0xFF991B1B);
  static const Color biscuit = Color(0xFFD97706);
  static const Color biscuitDot = Color(0xFF78350F);
  static const Color magnify = sky500;

  /// `gumsRed` / `gumsPink`: lips, mouth, gums, teeth and the blood spots.
  static const Color lipsRed = Color(0xFF991B1B);
  static const Color lipsPink = Color(0xFFEC4899);
  static const Color mouth = Color(0xFF450A0A);
  static const Color gumsRed = red500;
  static const Color gumsPink = Color(0xFFFBCFE8);
  static const Color teethYellow = Color(0xFFFEF08A);
  static const Color teeth = white;
  static const Color blood = Color(0xFF991B1B);

  /// Salt grains of the sprinkle (added).
  static const Color salt = Color(0xFFF8FAFC);

  /// HTML `confetti({colors: ['#10b981', '#06b6d4', '#f59e0b']})`.
  static const List<Color> confetti = [emerald500, cyan500, amber500];
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66065F46), // emerald-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
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
    curtainGlow: Color(0x66065F46),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar font-size setting: 15 px, slider 12–22 px.
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
// From the HTML `i18n`, `ScenariosData` and `labelDict` tables (Telugu
// dropped). `sN_step_M` are the HTML step `action` texts, which its `hud`
// arrays repeat word for word ('CLICK' → 'TAP'); `sN_focus_M` / `sN_obs_M`
// the HTML step concept and observation. Keys marked "Added." are new texts
// the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title':
        'The Protective Shield: Understanding Vitamins, Minerals, and Deficiency Disorders',
    'app_subtitle': 'Class 6. Mindful Eating: A path to a Healthy Body',
    'scen_1_opt': "Scenario 1: The Sailor's Scurvy",
    'scen_2_opt': 'Scenario 2: The Goitre Solution',
    's1_desc':
        'To cure a sailor suffering from scurvy by identifying and providing the correct nutrient-rich food.',
    's2_desc':
        'To help a person suffering from goitre by choosing the correct type of salt for their diet.',
    's1_step_1': 'OBSERVE sailor on ship. TAP magnifying glass on mouth.',
    's1_step_2': "DRAG food item onto sailor's Meal Tray.",
    's1_step_3':
        "If incorrect item chosen, 'No Change'. DRAG Orange to Meal Tray.",
    's1_step_4':
        'Success! Vitamin C in citrus fruits like oranges cures scurvy.',
    's2_step_1':
        'OBSERVE person from mountain village. TAP magnifying glass on neck.',
    's2_step_2': "DRAG a salt shaker and DROP onto person's Meal Plate.",
    's2_step_3':
        "If Common Salt used, 'No Change'. DRAG Iodised Salt shaker and DROP to Meal Plate.",
    's2_step_4':
        'Success! Iodine, a mineral added to salt, is essential for preventing goitre.',
    's1_focus_1': 'Inspect Symptoms',
    's1_focus_2': 'Choose Food',
    's1_focus_3': 'Incorrect vs. Correct Choice',
    's1_focus_4': 'Watched Cure',
    's2_focus_1': 'Inspect Goitre',
    's2_focus_2': 'Choose Salt',
    's2_focus_3': 'Incorrect vs. Correct Choice',
    's2_focus_4': 'Watched Cure',
    's1_obs_1': 'Health Meter is 20%. Camera zooms in on red, bleeding gums.',
    's1_obs_2': 'Select from Salted Beef, Hardtack Biscuit, or Orange.',
    's1_obs_3': 'Orange triggers positive feedback.',
    's1_obs_4': 'Gums heal, Health Meter fills to green.',
    's2_obs_1': 'Health Meter is 20%. Camera zooms in on swollen neck.',
    's2_obs_2': 'Select from Common Salt or Iodised Salt.',
    's2_obs_3': 'Iodised salt triggers positive feedback.',
    's2_obs_4': 'Neck swelling shrinks, Health Meter fills to green.',
    's1_summary':
        'Success! Vitamin C in citrus fruits like oranges cures scurvy.',
    's2_summary':
        'Success! Iodine, a mineral added to salt, is essential for preventing goitre.',
    // Summary popup (HTML `success`, `discovery_complete`,
    // `select_next_sc_msg` and the `triggerConclusion` labels).
    'sum_title': 'Discovery Complete!',
    'sum_heading': 'Exploration Complete!',
    'select_next_sc_msg':
        'Scenario 1 completed. Select Scenario 2 from the sidebar!',
    'btn_conclude': 'Review Findings',
    'sum_orange': 'Orange',
    'sum_vit_c': 'Vitamin C',
    'sum_scurvy': 'Prevents Scurvy',
    'sum_iodised': 'Iodised Salt',
    'sum_iodine': 'Iodine',
    'sum_goitre': 'Prevents Goitre',
    // HTML `showFeedback` texts (English only in the HTML).
    'fb_no_change': 'No Change',
    'fb_success': 'Success!',
    // Scene labels (HTML `labelDict`).
    'lbl_sailor': 'Sailor',
    'lbl_health': 'Health Meter',
    'lbl_tray': 'Meal Tray',
    'item_beef': 'Salted Beef',
    'item_biscuit': 'Biscuit',
    'item_orange': 'Orange (Vit C)',
    'lbl_villager': 'Villager',
    'lbl_plate': 'Meal Plate',
    'item_common': 'Common Salt',
    'item_iodised': 'Iodised Salt (Iodine)',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // Added.
    'lbl_magnify': 'Magnifying glass',
    'hint_inspect_1':
        "Not yet! First TAP the magnifying glass on the sailor's mouth.",
    'hint_inspect_2':
        "Not yet! First TAP the magnifying glass on the person's neck.",
    'miss_1': "Missed! Drop the food right onto the sailor's Meal Tray.",
    'miss_2':
        "Missed! Drop the salt shaker right onto the person's Meal Plate.",
    'scene_s1':
        "A ship's deck with a sick, slouching sailor and his Health Meter, a magnifying glass at his mouth, a crate with salted beef, a biscuit and an orange, and the sailor's Meal Tray",
    'scene_s2':
        'A mountain village with a villager whose neck is swollen (goitre) and his Health Meter, a magnifying glass at his neck, a shelf with a common salt and an iodised salt shaker, and his Meal Plate',
  },
  'hi': {
    'app_title': 'सुरक्षा कवच: विटामिन, खनिज, और कमी संबंधी विकारों को समझना',
    'app_subtitle': 'कक्षा 6. सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_opt': 'परिदृश्य 1: नाविक का स्कर्वी',
    'scen_2_opt': 'परिदृश्य 2: घेंघा समाधान',
    's1_desc':
        'स्कर्वी से पीड़ित नाविक की पहचान कर उसे सही पोषक तत्व प्रदान कर ठीक करें।',
    's2_desc': 'सही प्रकार का नमक चुनकर घेंघा से पीड़ित व्यक्ति की मदद करें।',
    's1_step_1':
        'जहाज पर नाविक का निरीक्षण करें। मुंह पर मैग्निफाइंग ग्लास पर टैप करें।',
    's1_step_2': 'भोजन को नाविक की ट्रे पर खींचें।',
    's1_step_3':
        "यदि गलत विकल्प चुना गया, 'कोई बदलाव नहीं'। संतरे को ट्रे पर खींचें।",
    's1_step_4':
        'सफलता! संतरे जैसे खट्टे फलों में मौजूद विटामिन सी स्कर्वी को ठीक करता है।',
    's2_step_1':
        'पहाड़ी गांव के व्यक्ति का निरीक्षण करें। गर्दन पर मैग्निफाइंग ग्लास पर टैप करें।',
    's2_step_2': 'नमकदानी को खींचें और व्यक्ति की भोजन प्लेट पर छोड़ें।',
    's2_step_3':
        "यदि सामान्य नमक का उपयोग किया गया, 'कोई बदलाव नहीं'। आयोडीन युक्त नमकदानी को प्लेट पर खींचें।",
    's2_step_4':
        'सफलता! आयोडीन, जो नमक में मिलाया जाने वाला खनिज है, घेंघा को रोकने के लिए आवश्यक है।',
    's1_focus_1': 'लक्षणों का निरीक्षण करें',
    's1_focus_2': 'भोजन चुनें',
    's1_focus_3': 'गलत बनाम सही विकल्प',
    's1_focus_4': 'ठीक होते हुए देखें',
    's2_focus_1': 'घेंघा का निरीक्षण करें',
    's2_focus_2': 'नमक चुनें',
    's2_focus_3': 'गलत बनाम सही विकल्प',
    's2_focus_4': 'ठीक होते हुए देखें',
    's1_obs_1':
        'स्वास्थ्य मीटर 20% है। कैमरा लाल, खून बहने वाले मसूड़ों पर ज़ूम करता है।',
    's1_obs_2': 'बीफ, बिस्किट या संतरे में से चुनें।',
    's1_obs_3': 'संतरा सकारात्मक प्रतिक्रिया देता है।',
    's1_obs_4': 'मसूड़े ठीक हो जाते हैं, स्वास्थ्य मीटर हरा हो जाता है।',
    's2_obs_1': 'स्वास्थ्य मीटर 20% है। कैमरा सूजी हुई गर्दन पर ज़ूम करता है।',
    's2_obs_2': 'सामान्य नमक या आयोडीन युक्त नमक में से चुनें।',
    's2_obs_3': 'आयोडीन युक्त नमक सकारात्मक प्रतिक्रिया देता है।',
    's2_obs_4': 'गर्दन की सूजन सिकुड़ जाती है, स्वास्थ्य मीटर हरा हो जाता है।',
    's1_summary':
        'सफलता! संतरे जैसे खट्टे फलों में मौजूद विटामिन सी स्कर्वी को ठीक करता है।',
    's2_summary':
        'सफलता! आयोडीन, जो नमक में मिलाया जाने वाला खनिज है, घेंघा को रोकने के लिए आवश्यक है।',
    'sum_title': 'खोज पूर्ण!',
    'sum_heading': 'अन्वेषण पूर्ण!',
    'select_next_sc_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'sum_orange': 'संतरा',
    'sum_vit_c': 'विटामिन सी',
    'sum_scurvy': 'स्कर्वी रोकता है',
    'sum_iodised': 'आयोडीन युक्त नमक',
    'sum_iodine': 'आयोडीन',
    'sum_goitre': 'घेंघा रोकता है',
    // Added: the HTML shows these two feedback texts in English only; the
    // Hindi comes from its own Hindi step texts.
    'fb_no_change': 'कोई बदलाव नहीं',
    'fb_success': 'सफलता!',
    'lbl_sailor': 'नाविक',
    'lbl_health': 'स्वास्थ्य मीटर',
    'lbl_tray': 'भोजन ट्रे',
    'item_beef': 'गोमांस',
    'item_biscuit': 'बिस्किट',
    'item_orange': 'संतरा (विटामिन सी)',
    'lbl_villager': 'ग्रामीण',
    'lbl_plate': 'भोजन प्लेट',
    'item_common': 'सामान्य नमक',
    'item_iodised': 'आयोडीन युक्त नमक',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    // Added.
    'lbl_magnify': 'मैग्निफाइंग ग्लास',
    'hint_inspect_1':
        'अभी नहीं! पहले नाविक के मुंह पर मैग्निफाइंग ग्लास पर टैप करें।',
    'hint_inspect_2':
        'अभी नहीं! पहले व्यक्ति की गर्दन पर मैग्निफाइंग ग्लास पर टैप करें।',
    'miss_1': 'निशाना चूक गया! भोजन को सीधे नाविक की भोजन ट्रे पर छोड़ें।',
    'miss_2':
        'निशाना चूक गया! नमकदानी को सीधे व्यक्ति की भोजन प्लेट पर छोड़ें।',
    'scene_s1':
        'जहाज के डेक पर एक बीमार, झुका हुआ नाविक और उसका स्वास्थ्य मीटर, उसके मुंह पर एक मैग्निफाइंग ग्लास, गोमांस, बिस्किट और संतरे वाला एक टोकरा, और नाविक की भोजन ट्रे',
    'scene_s2':
        'पहाड़ी गांव में सूजी हुई गर्दन (घेंघा) वाला एक ग्रामीण और उसका स्वास्थ्य मीटर, उसकी गर्दन पर एक मैग्निफाइंग ग्लास, सामान्य नमक और आयोडीन युक्त नमक की नमकदानियों वाली एक शेल्फ, और उसकी भोजन प्लेट',
  },
};

/// Number of scenarios and of steps in each (the HTML `steps` arrays).
const int _scenarioCount = 2;
const int _stepCount = 4;

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.result,
  });

  final String focus;
  final String action;
  final String result;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCount; i++)
      _StepInfo(
        focus: t('s${n}_focus_$i'),
        action: t('s${n}_step_$i'),
        result: t('s${n}_obs_$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table (HTML
/// `ScenariosData`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(concept: s.focus, action: s.action, observation: s.result),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 10, 16) looking at `controls.target` (0, 1, 0).
const double _fovDegrees = 45;
const double _near = 0.1;
const _View _homeView = _View(_V(0, 10, 16), _V(0, 1, 0), 0);

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a food or a salt shaker (short drags must pick
/// it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Second line of a two-line chip ("(Vit C)") relative to the first.
const double _subScale = 0.82;

/// Chip padding as a share of the label size, and the gap (design px)
/// between two item chips stacked to stay apart.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;
const double _chipGap = 3;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; x UI scale) and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene (the HTML camera is zoom 1); it is
/// never drawn smaller than [_minZoom].
const double _maxZoom = 1.6;
const double _minZoom = 0.3;

/// Nothing closer to the camera plane than this is drawn (the deck, tray
/// and plate behind a close-up camera).
const double _clipDepth = 0.5;

// ----------------------------------------------------- shared: the patient

/// The sailor (`buildSailor()`) and the villager (`buildHimalayan()`)
/// stand at (-3, 0, 0), facing the camera.
const _V _patientPos = _V(-3, 0, 0);

/// The sick sailor slouches (`rotation.z = 0.1`) and straightens up (→ 0,
/// 1000 ms) once cured.
const double _sickTilt = 0.1;
const double _standSeconds = 1;

/// 'No Change' head shake: `rotation.y` → 0.2 over 150 ms, yoyo, repeat 3.
const double _shakeTurn = 0.2;
const double _shakeLeg = 0.15;
const int _shakeLegs = 4;

/// Head group heights (`headGrp.position.y`): sailor, villager.
const double _sailorHeadY = 2.6;
const double _villagerHeadY = 2.9;

/// Gums sprite `scale(0.6, 0.3)` at (0, -0.1, 0.41) of the sailor's head;
/// it fades in (500 ms) on each close-up and out (1000 ms) once healed.
const _V _gumsAt = _V(0, -0.1, 0.41);
const double _gumsW = 0.6;
const double _gumsH = 0.3;
const double _gumsIn = 0.5;
const double _gumsOut = 1;

/// Goitre `SphereGeometry(0.2)` scaled (1.5, 1, 1.2) at (0, 2.4, 0.2) of
/// the villager; it shrinks to nothing over 1500 ms once cured.
const _V _goitreAt = _V(0, 2.4, 0.2);
const double _goitreR = 0.2;
const _V _goitreScale = _V(1.5, 1, 1.2);
const double _goitreSeconds = 1.5;

// ------------------------------------------------------------ health meter

/// `createStatusBarSprite('Health Meter', 256, 128, 0.2)` at (-3, 4.5, 0);
/// `animateBarFill` tweens it over 1500 ms.
const _V _healthBar = _V(-3, 4.5, 0);
const double _healthStart = 0.2;
const double _healthHalf = 0.5;
const double _fillSeconds = 1.5;

/// HTML `animateBarFill` colours: red up to 0.4, yellow up to 0.8, then
/// green.
const double _barYellowFrom = 0.4;
const double _barGreenFrom = 0.8;

/// Status bar sprite (256 x 128 canvas drawn on a 4 x 2 sprite, so 64
/// canvas px per world unit): box `roundRect(10, 40, 236, 60, 10)`, border
/// 4, fill `roundRect(14, 44, 228 x fill, 52, 6)`, percentage in bold
/// 20 px inside the box; the caption is a label chip above it.
const double _barOuterW = 236 / 64;
const double _barOuterH = 60 / 64;
const double _barDrop = 6 / 64; // box centre below the sprite centre
const double _barRadius = 10 / 64;
const double _barBorder = 4 / 64;
const double _barInset = 4 / 64;
const double _barFillRadius = 6 / 64;
const double _barTextPx = 20;
const double _barPxPerUnit = 64;

/// The caption chip sits just above the bar box.
const double _barCaptionLift = _barOuterH / 2 - _barDrop + 0.08;

// ------------------------------------------------------ magnifying glass

/// Magnifying-glass sprites (`scale 1.5`) over the sailor's mouth and the
/// villager's neck; they shrink away in 300 ms when tapped.
const _V _magS1 = _V(-2.5, 2.8, 1);
const _V _magS2 = _V(-2.5, 2.5, 1);
const double _magSeconds = 0.3;

/// Icon sprites draw their 96 px picture on a 128 px canvas shown 1.5
/// units wide; the food and salt pictures sit 21 px above its centre
/// (`drawImage(img, 16, -5, 96, 96)`).
const double _iconSize = 96 / 128 * 1.5;
const double _iconLift = (64 - 43) / 128 * 1.5;

// --------------------------------------------------------------- close-ups

/// HTML close-up: the camera moves to (-3, y, 2) looking at (-3, y, 0)
/// over 1000 ms (`Cubic.Out`), y = 2.8 (mouth) or 2.4 (neck); 2500 ms
/// later `resetCamera()` jumps back.
const double _closeEyeZ = 2;
const double _closeY1 = 2.8;
const double _closeY2 = 2.4;
const double _zoomSeconds = 1;
const double _holdSeconds = 2.5;

// ------------------------------------------------------------------ scenes

/// Floor `PlaneGeometry(24, 12)`.
const double _floorHalfW = 12;
const double _floorHalfD = 6;

/// Deck railing: posts `CylinderGeometry(0.1, 0.1, 2)` every 2 units from
/// x = -10 to 10 at z = -5, under a `BoxGeometry(24, 0.2, 0.2)` rail.
const double _railZ = -5;
const double _railHalf = 10;
const double _postGap = 2;
const double _postR = 0.1;
const double _postH = 2;
const _V _rail = _V(0, 2, _railZ);
const _V _railSize = _V(24, 0.2, 0.2);

/// Crate `BoxGeometry(3, 1.5, 2)` (scenario 1) and shelf
/// `BoxGeometry(4, 0.2, 1.5)` (scenario 2).
const _V _crate = _V(4, 0.75, -2);
const _V _crateSize = _V(3, 1.5, 2);
const _V _shelf = _V(4, 2, -2);
const _V _shelfSize = _V(4, 0.2, 1.5);

/// Meal Tray `BoxGeometry(2, 0.1, 1.5)` and Meal Plate
/// `CylinderGeometry(1, 1, 0.1)` with its food (r 0.8) at (0, 0.05, 2).
const _V _tray = _V(0, 0.05, 2);
const _V _traySize = _V(2, 0.1, 1.5);
const _V _plate = _V(0, 0.05, 2);
const double _plateR = 1;
const double _plateH = 0.1;
const _V _plateFood = _V(0, 0.1, 2);
const double _plateFoodR = 0.8;

/// Where a served item goes: 0.2 above the tray (eaten there) or 0.6
/// above the plate (sprinkled there).
const _V _trayServe = _V(0, 0.25, 2);
const _V _plateServe = _V(0, 0.65, 2);

/// Item sprites: on the crate at y = 2 (HTML x = 3, 4, 5) and on the shelf
/// at y = 3 (HTML x = 3.2, 4.8), z = -2. Here they are spread a little so
/// their 1.125-unit pictures do not overlap.
const List<double> _crateXs = [2.5, 4, 5.5];
const double _crateItemY = 2;
const List<double> _shelfXs = [3, 5];
const double _shelfItemY = 3;
const double _itemZ = -2;

/// HTML drop test: the item within 2.5 units (x, z) of the tray / plate.
const double _dropRange = 2.5;

/// HTML tweens (300 ms each): to the tray / plate, shrinking when eaten,
/// back to the crate / shelf.
const double _glideSeconds = 0.3;
const double _shrinkSeconds = 0.3;
const double _returnSeconds = 0.3;

/// Sprinkle: `rotation.z` → -π/4 over 200 ms, yoyo, repeat 3.
const double _sprinkleAngle = math.pi / 4;
const double _sprinkleLeg = 0.2;
const int _sprinkleLegs = 4;

/// Common salt: the next step starts 1000 ms after 'No Change'.
const double _wrongPause = 1;

/// HTML `.feedback-text` pop-up animation (1.5 s).
const double _feedbackSeconds = 1.5;

/// A held item stays above the floor (added, so a drag towards the horizon
/// keeps it in view).
const double _dragHalfX = 11;
const double _dragBackZ = -5.5;
const double _dragFrontZ = 8;

// ------------------------------------------------------------------ labels

/// Text sprites: the patient's name just under the feet (`position.y =
/// -0.5`), the tray / plate name in front of it (the HTML puts it on the
/// tray's centre, where it hid the food).
const _V _feetLabelAt = _V(0, -0.15, 0);
const _V _trayLabelAt = _V(0, 0, 2.8);
const _V _plateLabelAt = _V(0, 0, 3.05);
const (double, double) _below = (0, -1);
const (double, double) _above = (0, 1);

// ---------------------------------------------------------------- confetti

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

// ---------------------------------------------------------------- models

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
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// [v] turned by a Three.js `rotation` (Euler order 'XYZ': Rx · Ry · Rz).
_V _rot(_V v, double rx, double ry, double rz) {
  var x = v.x, y = v.y, z = v.z;
  if (rz != 0) {
    final c = math.cos(rz), s = math.sin(rz);
    (x, y) = (x * c - y * s, x * s + y * c);
  }
  if (ry != 0) {
    final c = math.cos(ry), s = math.sin(ry);
    (x, z) = (x * c + z * s, -x * s + z * c);
  }
  if (rx != 0) {
    final c = math.cos(rx), s = math.sin(rx);
    (y, z) = (y * c - z * s, y * s + z * c);
  }
  return _V(x, y, z);
}

/// A Three.js object's world matrix: its origin and its local axes (turned
/// and scaled) in world space.
@immutable
class _Xf {
  const _Xf(this.o, this.x, this.y, this.z);

  /// An unturned, unscaled group at [origin].
  const _Xf.at(_V origin)
    : this(origin, const _V(1, 0, 0), _V.up, const _V(0, 0, 1));

  final _V o;
  final _V x;
  final _V y;
  final _V z;

  /// A local direction in world space.
  _V dir(_V v) => x * v.x + y * v.y + z * v.z;

  /// A local point in world space.
  _V at(_V l) => o + dir(l);

  _V call(double lx, double ly, double lz) => at(_V(lx, ly, lz));

  /// A child's frame (Three.js `position`, `rotation`, `scale`).
  _Xf child(
    _V pos, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
    double sx = 1,
    double sy = 1,
    double sz = 1,
  }) => _Xf(
    at(pos),
    dir(_rot(_V(sx, 0, 0), rx, ry, rz)),
    dir(_rot(_V(0, sy, 0), rx, ry, rz)),
    dir(_rot(_V(0, 0, sz), rx, ry, rz)),
  );
}

/// HTML `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = 1 - t;
  return 1 - k * k * k;
}

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// A camera pose: HTML `camera.position` and `controls.target`.
@immutable
class _View {
  const _View(this.eye, this.target, this.close);

  final _V eye;
  final _V target;

  /// 0: the HTML start view, fitted beside the cards; 1: a close-up,
  /// centred in the free part of the canvas.
  final double close;

  _View lerpTo(_View o, double t) => _View(
    _V.lerp(eye, o.eye, t),
    _V.lerp(target, o.target, t),
    close + (o.close - close) * t,
  );
}

/// Where the start view's look-at point lands on the stage, how much the
/// scene is enlarged (the HTML camera is [base]) and the centre of the
/// free part of the canvas (where close-ups look). The scene is fitted
/// into the part of the canvas no card covers.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom, this.mid);

  final Offset center;
  final double zoom;
  final Offset mid;

  static const _Framing base = _Framing(_designCenter, 1, _designCenter);

  _Framing lerpTo(_Framing o, double t) => _Framing(
    Offset.lerp(center, o.center, t)!,
    zoom + (o.zoom - zoom) * t,
    Offset.lerp(mid, o.mid, t)!,
  );

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 &&
      (mid - o.mid).distance < 0.5 &&
      (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_View view, _Framing framing) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      view.eye,
      f,
      r,
      r.cross(f),
      Offset.lerp(framing.center, framing.mid, view.close)!,
      _focal * framing.zoom,
    );
  }

  const _Cam._(this.eye, this.f, this.r, this.u, this.center, this.scale);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w] (points behind the camera are clamped to the
  /// near plane; callers skip them).
  Offset p(_V w) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  /// The screen offset of a small step [a] taken at [w] (the projection's
  /// derivative): how a mesh's axes look on screen.
  Offset dp(_V w, _V a) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    final az = a.dot(f);
    return Offset(
      scale * (a.dot(r) * z - d.dot(r) * az) / (z * z),
      -scale * (a.dot(u) * z - d.dot(u) * az) / (z * z),
    );
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (the drag plane).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the box [min]–[max].
  Rect boxRect(_V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        _V(
          (i & 1) != 0 ? max.x : min.x,
          (i & 2) != 0 ? max.y : min.y,
          (i & 4) != 0 ? max.z : min.z,
        ),
      );
      l = math.min(l, q.dx);
      t = math.min(t, q.dy);
      r = math.max(r, q.dx);
      b = math.max(b, q.dy);
    }
    return Rect.fromLTRB(l, t, r, b);
  }
}

/// Pictures of the HTML `SVGs` (icon sprites, the gums sprite, the summary).
enum _Art {
  beef,
  biscuit,
  orange,
  shaker,
  shakerBlue,
  magnify,
  gumsRed,
  gumsPink,
}

/// The items on the crate (scenario 1: foods, eaten from the Meal Tray) and
/// on the shelf (scenario 2: salt shakers, sprinkled on the Meal Plate),
/// in HTML order (`createIconSprite` calls and `labelDict`).
enum _Item {
  beef('item_beef', _Art.beef, 0, 0, cures: false),
  biscuit('item_biscuit', _Art.biscuit, 0, 1, cures: false),
  orange('item_orange', _Art.orange, 0, 2, cures: true),
  commonSalt('item_common', _Art.shaker, 1, 0, cures: false),
  iodisedSalt('item_iodised', _Art.shakerBlue, 1, 1, cures: true);

  const _Item(
    this.nameKey,
    this.art,
    this.scenario,
    this.slot, {
    required this.cures,
  });

  final String nameKey;
  final _Art art;
  final int scenario;

  /// Place on the crate / shelf, from the left.
  final int slot;

  /// The orange (Vitamin C) and the iodised salt (iodine).
  final bool cures;

  _V get home => scenario == 0
      ? _V(_crateXs[slot], _crateItemY, _itemZ)
      : _V(_shelfXs[slot], _shelfItemY, _itemZ);

  static List<_Item> of(int scenario) => [
    for (final i in values)
      if (i.scenario == scenario) i,
  ];
}

/// A label split like the HTML icon sprites do: the part before '(' on the
/// first line, the bracket on the second ("Orange" / "(Vit C)").
(String, String?) _splitName(String text) {
  final i = text.indexOf('(');
  if (i <= 0) return (text, null);
  return (text.substring(0, i).trim(), text.substring(i));
}

/// One property tweened like an HTML `TWEEN.Tween`: from its value when
/// the tween starts to a target, eased, optionally played back and forth.
class _Track {
  _Track(double value) : _from = value, _to = value;

  double _from;
  double _to;
  double _start = 0;
  double _seconds = 0;
  int _legs = 1;
  double Function(double) _ease = _linear;

  /// The value the tween ends at.
  double get target => _legs.isEven ? _from : _to;

  /// Value at scene [time].
  double at(double time) {
    if (_seconds <= 0) return target;
    final e = (time - _start) / _seconds;
    if (e >= _legs) return target;
    if (e <= 0) return _from;
    final leg = e.floor();
    final u = _ease(e - leg);
    return leg.isEven ? _from + (_to - _from) * u : _to + (_from - _to) * u;
  }

  void set(double value) {
    _from = value;
    _to = value;
    _seconds = 0;
    _legs = 1;
  }

  /// Tweens from the current value to [to] over [seconds]; [legs] > 1
  /// plays it back and forth (HTML `.yoyo(true).repeat(legs - 1)`).
  void animate(
    double time,
    double to,
    double seconds, {
    int legs = 1,
    double Function(double) ease = _linear,
  }) {
    _from = at(time);
    _to = to;
    _start = time;
    _seconds = seconds;
    _legs = legs;
    _ease = ease;
  }
}

/// One item sprite on the crate or shelf.
class _ItemState {
  _ItemState(this.item) : pos = item.home;

  final _Item item;

  /// Where it is now (held, gliding or resting).
  _V pos;

  _V _from = _V.zero;
  _V _to = _V.zero;
  double _start = -1;
  double _seconds = 0;

  /// Sprite scale (1, shrinking to 0 once eaten) and sprinkle tilt (HTML
  /// `rotation.z`).
  final _Track scale = _Track(1);
  final _Track tilt = _Track(0);

  /// Eaten and gone (scenario 1).
  bool gone = false;

  bool get gliding => _start >= 0;

  /// Glides (linear tween) from where it is to [to].
  void glide(double time, _V to, double seconds) {
    _from = pos;
    _to = to;
    _start = time;
    _seconds = seconds;
  }

  /// Moves along the glide; true when it arrives.
  bool advance(double time) {
    if (_start < 0) return false;
    final t = ((time - _start) / _seconds).clamp(0.0, 1.0);
    pos = _V.lerp(_from, _to, t);
    if (t < 1) return false;
    _start = -1;
    return true;
  }
}

/// One confetti piece.
@immutable
class _Confetto {
  const _Confetto(this.angle, this.velocity, this.color, this.spin);

  final double angle;
  final double velocity;
  final Color color;
  final double spin;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    final rnd = math.Random(23);
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          _Colors.confetti[i % _Colors.confetti.length],
          (rnd.nextDouble() - 0.5) * 0.4,
        ),
      );
    }
  }

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1–4).
  int step = 1;

  /// HTML `State.sN.inspected` and `State.sN.isAnimating`.
  bool inspected = false;
  bool busy = false;

  /// The cure has played out: 'Review Findings' is shown (HTML
  /// `triggerConclusionState`).
  bool cured = false;

  /// 'Review Findings' was tapped.
  bool reviewed = false;

  /// The current scenario's item sprites.
  final List<_ItemState> items = [];

  /// The item the learner is holding (HTML `State.draggingObject`).
  _ItemState? held;

  /// The Health Meter (HTML `userData.currentFill`), the magnifying glass's
  /// scale (1 = the HTML 1.5), the sailor's slouch (`rotation.z`) and head
  /// shake (`rotation.y`), the gums' opacity and the goitre's scale.
  final _Track health = _Track(_healthStart);
  final _Track mag = _Track(1);
  final _Track tilt = _Track(_sickTilt);
  final _Track turn = _Track(0);
  final _Track gums = _Track(0);
  final _Track goitre = _Track(1);

  /// The gums texture was redrawn pink (`SVGs.gumsPink`).
  bool gumsHealed = false;

  /// HTML `showFeedback`: the text, its colour and when it popped up.
  String? feedbackKey;
  bool feedbackError = true;
  double feedbackAt = -1;

  /// Scene time of the summary's confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// Pending events of the running sequence, in scene time (the HTML tween
  /// `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  /// The camera (HTML `camera.position` / `controls.target` tweens).
  _View view = _homeView;
  _View _viewFrom = _homeView;
  _View _viewTo = _homeView;
  double _viewT = 1;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// Something came to rest since the last [takeSettled].
  bool _settled = true;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    inspected = false;
    busy = false;
    cured = false;
    reviewed = false;
    items
      ..clear()
      ..addAll([for (final i in _Item.of(index)) _ItemState(i)]);
    held = null;
    _cues.clear();
    health.set(_healthStart);
    mag.set(1);
    tilt.set(index == 0 ? _sickTilt : 0);
    turn.set(0);
    gums.set(0);
    goitre.set(1);
    gumsHealed = false;
    feedbackKey = null;
    feedbackAt = -1;
    confettiAt = -1;
    view = _viewFrom = _viewTo = _homeView;
    _viewT = 1;
    _settled = true;
  }

  /// Runs [run] at scene time [at].
  void cue(double at, VoidCallback run) => _cues.add((at, run));

  /// Runs the cues that are due.
  void runCues() {
    if (!_cues.any((c) => c.$1 <= time)) return;
    final due = [
      for (final c in _cues)
        if (c.$1 <= time) c,
    ];
    _cues.removeWhere((c) => c.$1 <= time);
    for (final c in due) {
      c.$2();
    }
  }

  /// HTML `animate()` + `TWEEN.update()`: camera, items and framing.
  void advance(double dt) {
    if (_viewT < 1) {
      _viewT = math.min(1, _viewT + dt / _zoomSeconds);
      view = _viewFrom.lerpTo(_viewTo, _cubicOut(_viewT));
      if (_viewT >= 1) _settled = true;
    }
    for (final f in items) {
      if (!identical(f, held) && f.advance(time)) _settled = true;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      if (_framingT >= 1) _settled = true;
    }
  }

  /// True once after something came to rest (the semantics nodes re-read
  /// where things are).
  bool takeSettled() {
    final s = _settled;
    _settled = false;
    return s;
  }

  void markSettled() => _settled = true;

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      _settled = true;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// HTML camera tweens to a close-up (1000 ms, `Cubic.Out`).
  void moveCamera(_View to) {
    _viewFrom = view;
    _viewTo = to;
    _viewT = 0;
  }

  /// HTML `resetCamera()`: back to the start view at once.
  void snapCamera() {
    view = _viewFrom = _viewTo = _homeView;
    _viewT = 1;
    _settled = true;
  }

  /// HTML `showFeedback(text, isError)`.
  void feedback(String key, {required bool error}) {
    feedbackKey = key;
    feedbackError = error;
    feedbackAt = time;
  }

  /// The camera in the current view and framing.
  _Cam camera() => _Cam(view, framing);

  // ------------------------------------------------------------ geometry

  bool get deck => scenario == 0;

  _V get magPos => deck ? _magS1 : _magS2;

  _V get serveAt => deck ? _trayServe : _plateServe;

  /// The close-up on the sailor's mouth or the villager's neck.
  _View get closeView {
    final y = deck ? _closeY1 : _closeY2;
    return _View(_V(_patientPos.x, y, _closeEyeZ), _V(_patientPos.x, y, 0), 1);
  }

  /// World box of the Meal Tray / Meal Plate.
  (_V, _V) get targetBox => deck
      ? (_tray - _traySize * 0.5, _tray + _traySize * 0.5)
      : (
          _plate - const _V(_plateR, _plateH / 2, _plateR),
          _plate + const _V(_plateR, _plateH / 2 + 0.05, _plateR),
        );

  /// The patient's group frame: position, head shake and slouch.
  _Xf patient() => const _Xf.at(
    _patientPos,
  ).child(_V.zero, ry: turn.at(time), rz: deck ? tilt.at(time) : 0);

  /// The patient's head group.
  _Xf head(_Xf body) =>
      body.child(_V(0, deck ? _sailorHeadY : _villagerHeadY, 0));

  /// Screen centre and side of [f]'s picture.
  (Offset, double) picture(_ItemState f, _Cam cam) {
    final k = cam.scaleAt(f.pos) * f.scale.at(time);
    return (cam.p(f.pos) - Offset(0, _iconLift * k), _iconSize * k);
  }

  Rect pictureRect(_ItemState f, _Cam cam) {
    final (c, side) = picture(f, cam);
    return Rect.fromCenter(center: c, width: side, height: side);
  }

  Rect magRect(_Cam cam) {
    final side = _iconSize * cam.scaleAt(magPos) * mag.at(time);
    return Rect.fromCenter(center: cam.p(magPos), width: side, height: side);
  }

  Rect targetRect(_Cam cam) {
    final (min, max) = targetBox;
    return cam.boxRect(min, max);
  }

  /// The item at [p] (HTML raycast on the sprites and their hit boxes): the
  /// picture itself or, on a small screen, within a finger's reach of its
  /// centre; the nearest one wins.
  _ItemState? itemAt(Offset p, double touch) {
    final cam = camera();
    _ItemState? best;
    var bestD = double.infinity;
    for (final f in items) {
      if (f.gone || identical(f, held) || f.scale.at(time) < 0.5) continue;
      final r = pictureRect(f, cam);
      final dist = (p - r.center).distance;
      if ((r.contains(p) || dist <= touch) && dist < bestD) {
        best = f;
        bestD = dist;
      }
    }
    return best;
  }

  /// Is [p] on the magnifying glass (while it is shown)?
  bool magAt(Offset p, double touch) {
    if (mag.at(time) < 0.5) return false;
    final r = magRect(camera());
    return r.contains(p) || (p - r.center).distance <= touch;
  }

  /// Does [f], released with the finger at [pointer], land on the tray /
  /// plate? The HTML tests the item's (x, z) distance from it (< 2.5); a
  /// release with the picture or the finger over it as drawn counts too.
  bool lands(_ItemState f, Offset pointer, double margin) {
    final cam = camera();
    final rect = targetRect(cam).inflate(margin);
    final (c, _) = picture(f, cam);
    if (rect.contains(c) || rect.contains(pointer)) return true;
    final dx = f.pos.x - serveAt.x, dz = f.pos.z - serveAt.z;
    return math.sqrt(dx * dx + dz * dz) < _dropRange;
  }
}

/// What the framing keeps in view: a point of the base projection (the
/// HTML camera at zoom 1) and a rect around it that does not scale with the
/// zoom (a label chip; empty for a point of an object).
typedef _Focus = (Offset, Rect);

/// Best framing for [focus] inside [free], clear of the [hard] obstacles
/// (all in design coordinates), at most [maxZoom]. Objects scale with the
/// zoom, their label chips do not.
_Framing _fitFraming(
  List<_Focus> focus,
  Rect free,
  List<Rect> hard,
  double maxZoom,
) {
  if (free.width <= 1 || free.height <= 1 || focus.isEmpty) {
    return _Framing.base;
  }
  var rects = [free];
  for (final o in hard) {
    final next = <Rect>[];
    for (final r in rects) {
      if (!r.overlaps(o)) {
        next.add(r);
        continue;
      }
      if (o.left > r.left + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, o.left, r.bottom));
      }
      if (o.right < r.right - 1) {
        next.add(Rect.fromLTRB(o.right, r.top, r.right, r.bottom));
      }
      if (o.top > r.top + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, r.right, o.top));
      }
      if (o.bottom < r.bottom - 1) {
        next.add(Rect.fromLTRB(r.left, o.bottom, r.right, r.bottom));
      }
    }
    rects = next;
  }
  // Extent of the focus at zoom [z], relative to where the look-at point
  // lands.
  Rect extent(double z) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final (p, o) in focus) {
      final x = (p.dx - _designCenter.dx) * z;
      final y = (p.dy - _designCenter.dy) * z;
      l = math.min(l, x + o.left);
      t = math.min(t, y + o.top);
      r = math.max(r, x + o.right);
      b = math.max(b, y + o.bottom);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  bool fits(Rect r, double z) {
    final e = extent(z);
    return e.width <= r.width && e.height <= r.height;
  }

  /// Largest zoom at which the focus fits in [r] (0 if it never does).
  double zoomFor(Rect r) {
    if (fits(r, maxZoom)) return maxZoom;
    if (!fits(r, _minZoom)) return 0;
    var lo = _minZoom, hi = maxZoom;
    for (var i = 0; i < 16; i++) {
      final mid = (lo + hi) / 2;
      if (fits(r, mid)) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  (Rect, double)? pick;
  for (final r in rects) {
    final z = zoomFor(r);
    if (pick == null ||
        z > pick.$2 + 1e-6 ||
        ((z - pick.$2).abs() <= 1e-6 &&
            r.width * r.height > pick.$1.width * pick.$1.height)) {
      pick = (r, z);
    }
  }
  if (pick == null) return _Framing.base;
  final (rect, z) = pick;
  // Nothing fits (a tiny canvas): the smallest scene, centred in the
  // largest free part.
  final zoom = z > 0 ? z : _minZoom;
  return _Framing(rect.center - extent(zoom).center, zoom, rect.center);
}

/// Top-left of a chip of [size] relative to its anchor (see [_below] …).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on an item or the magnifying glass ([canGrab]), so other drags still pan
/// / zoom the canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _ProtectiveLabState
    extends State<Ch3A3ProtectiveNutrientsAndDeficiencyDisordersPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped whenever the items, camera or framing come to rest: the
  /// semantics nodes re-read where things are drawn.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch3-a3-canvas');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _missionRect;

  /// The item the current pointer holds, the scenario it was picked up in,
  /// the drag-plane offset of the grab, the drag plane's height and the
  /// last pointer position.
  _ItemState? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  double _grabY = 0;
  Offset _lastPointer = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// 1-based current step for the shell: the HTML `State.step`, then
  /// steps.length + 1 once the findings were reviewed.
  int get _step => _scene.reviewed ? _stepCount + 1 : _scene.step;

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
    _layout.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()` + `TWEEN.update()`; then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
    s.runCues();
    if (s.takeSettled()) _layout.value++;
    _frame.value = now;
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (cards and canvas are laid out by
  /// then). [snap] jumps there instead of sliding (new scenario).
  void _scheduleFraming({bool snap = false}) {
    if (snap) _snapFraming = true;
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the patient, Health Meter, crate / shelf, items, tray / plate and
  /// labels into the part of the canvas no card covers: the tool column,
  /// the HUD (sidebar open) and the floating mission card (sidebar
  /// collapsed). Never while an item is held, so the scene does not move
  /// under the finger.
  void _updateFraming() {
    if (_scene.held != null) return;
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
    final origin = canvas.localToGlobal(Offset.zero);
    final stage = Offset(
      (size.width - _design.width * fit) / 2,
      (size.height - _design.height * fit) / 2,
    );
    Rect toDesign(Rect r) => Rect.fromLTRB(
      (r.left - stage.dx) / fit,
      (r.top - stage.dy) / fit,
      (r.right - stage.dx) / fit,
      (r.bottom - stage.dy) / fit,
    );

    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (open ? _hudBand * context.labScale + 8 : 8) - pad.bottom,
    );
    final hard = <Rect>[];
    if (open) _missionRect = null;
    if (!open && _lab.isLabActive) {
      // The floating mission card as it is laid out; before that, the room
      // the shell gives it.
      final card = _missionCardBox();
      if (card != null) {
        final now = (card.localToGlobal(Offset.zero) - origin) & card.size;
        final kept = _missionRect;
        _missionRect = kept == null
            ? now
            : Rect.fromLTWH(
                now.left,
                now.top,
                math.max(now.width, kept.width),
                math.max(now.height, kept.height),
              );
        hard.add(_missionRect!);
      } else {
        final bottom = screen.height < _compactBelow
            ? _missionTop + pad.top + screen.height * _compactCardMax
            : size.height;
        hard.add(Rect.fromLTRB(0, 0, insets.left, bottom));
      }
    }
    _scene
      ..labelLeft = (4 - stage.dx) / fit
      ..labelRight = (size.width - insets.right - stage.dx) / fit;
    final target = _fitFraming(
      _focusItems(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      _maxZoom,
    );
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
  }

  /// The shell's floating mission card (sidebar collapsed), found in the
  /// lab's element tree.
  RenderBox? _missionCardBox() {
    RenderBox? found;
    void visit(Element e) {
      if (found != null) return;
      if (e.widget is _FloatingMissionCard) {
        final box = e.findRenderObject();
        if (box is RenderBox && box.hasSize && box.attached) found = box;
        return;
      }
      e.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return found;
  }

  /// What the learner must see in the start view: the patient, the Health
  /// Meter, the magnifying glass, the crate / shelf with its items, the
  /// tray / plate (HTML camera, zoom 1) and the label chips at their
  /// painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_homeView, _Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V min, _V max) {
      for (var i = 0; i < 8; i++) {
        items.add((
          cam.p(
            _V(
              (i & 1) != 0 ? max.x : min.x,
              (i & 2) != 0 ? max.y : min.y,
              (i & 4) != 0 ? max.z : min.z,
            ),
          ),
          Rect.zero,
        ));
      }
    }

    void chip(
      _V at,
      (double, double) align,
      String text, {
      String? sub,
      double drop = 0,
    }) {
      final size = _cache.chipSize(text, sub: sub);
      items.add((
        cam.p(at),
        (_chipOffset(size, align) + Offset(0, drop)) & size,
      ));
    }

    final deck = _scene.deck;
    const x = -3.0;
    // The patient (the sailor's slouch leans his head to the left).
    box(const _V(x - 1.25, 0, -0.6), _V(x + 0.95, deck ? 3.15 : 3.4, 0.6));
    chip(
      _patientPos + _feetLabelAt,
      _below,
      _t(deck ? 'lbl_sailor' : 'lbl_villager'),
    );
    // Health Meter and its caption.
    box(
      _healthBar - const _V(_barOuterW / 2, _barOuterH / 2 + _barDrop, 0),
      _healthBar + const _V(_barOuterW / 2, _barOuterH / 2 - _barDrop, 0),
    );
    chip(
      _healthBar + const _V(0, _barCaptionLift, 0),
      _above,
      _t('lbl_health'),
    );
    // Magnifying glass.
    const half = _iconSize / 2;
    final mag = _scene.magPos;
    box(mag - const _V(half, half, 0), mag + const _V(half, half, 0));
    // Crate or shelf, its items and their name chips (the middle chip may
    // be stacked under its neighbours').
    if (deck) {
      box(_crate - _crateSize * 0.5, _crate + _crateSize * 0.5);
    } else {
      box(_shelf - _shelfSize * 0.5, _shelf + _shelfSize * 0.5);
    }
    for (final i in _Item.of(_scene.scenario)) {
      final c = i.home + const _V(0, _iconLift, 0);
      box(c - const _V(half, half, 0), c + const _V(half, half, 0));
      final (name, sub) = _splitName(_t(i.nameKey));
      final at = c - const _V(0, half, 0);
      chip(at, _below, name, sub: sub);
      if (i.slot == 1) {
        final drop = _cache.chipSize(name, sub: sub).height + _chipGap;
        chip(at, _below, name, sub: sub, drop: drop);
      }
    }
    // Meal Tray / Meal Plate and its name.
    final (min, max) = _scene.targetBox;
    box(min, max);
    chip(
      deck ? _trayLabelAt : _plateLabelAt,
      _below,
      _t(deck ? 'lbl_tray' : 'lbl_plate'),
    );
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears tweens
  /// and timers and puts the patient, items, Health Meter and camera back.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _grabScenario = -1;
      _missionRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
    _layout.value++;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `resetCamera()` after a close-up: the camera jumps back to the
  /// start view (with its 'pop').
  void _snapBack() {
    _scene.snapCamera();
    _Sound.click.play();
  }

  /// HTML inspection click: the magnifying glass shrinks away, the camera
  /// zooms in on the mouth (the bleeding gums fade in) or the swollen neck,
  /// and 2500 ms later jumps back; the next step starts.
  void _inspect() {
    final s = _scene;
    if (s.step != 1 || s.inspected || s.busy) return;
    _Sound.click.play();
    final t = s.time;
    s
      ..inspected = true
      ..busy = true;
    s.mag.animate(t, 0, _magSeconds);
    s.moveCamera(s.closeView);
    s.cue(t + _zoomSeconds, () {
      if (s.deck) s.gums.animate(s.time, 1, _gumsIn);
      s.cue(s.time + _holdSeconds, () {
        _snapBack();
        s
          ..busy = false
          ..step = 2;
        _refresh();
      });
    });
    _refresh();
  }

  /// HTML `handleUp` drop on the tray / plate: the food goes onto the tray
  /// and is eaten, or the shaker sprinkles salt over the plate and goes
  /// back to the shelf; then the cure or 'No Change'.
  void _serve(_ItemState f) {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    f.glide(t, s.serveAt, _glideSeconds);
    if (s.deck) {
      s.cue(t + _glideSeconds, () {
        f.scale.animate(s.time, 0, _shrinkSeconds);
        s.cue(s.time + _shrinkSeconds, () {
          f.gone = true;
          s.markSettled();
        });
        f.item.cures ? _cure() : _noChange();
      });
    } else {
      s.cue(t + _glideSeconds, () {
        f.tilt.animate(
          s.time,
          -_sprinkleAngle,
          _sprinkleLeg,
          legs: _sprinkleLegs,
        );
        s.cue(s.time + _sprinkleLeg * _sprinkleLegs, () {
          f.glide(s.time, f.item.home, _returnSeconds);
          f.tilt.animate(s.time, 0, _returnSeconds);
          f.item.cures ? _cure() : _noChange();
        });
      });
    }
    _refresh();
  }

  /// The orange / iodised salt: 'Success!', the magnifying glass pops back
  /// while the camera zooms in, then the gums heal pink and the sailor
  /// stands up straight (or the goitre shrinks away); 2500 ms later the
  /// camera jumps back, the Health Meter fills (1500 ms) and 'Review
  /// Findings' appears.
  void _cure() {
    final s = _scene;
    final t = s.time;
    _Sound.correct.play();
    s
      ..feedback('fb_success', error: false)
      ..step = 4;
    if (s.deck) s.gumsHealed = true;
    s.mag.animate(t, 1, _magSeconds);
    s.moveCamera(s.closeView);
    s.cue(t + _zoomSeconds, () {
      final now = s.time;
      s.mag.animate(now, 0, _magSeconds);
      if (s.deck) {
        s.gums.animate(now, 1, _gumsIn);
      } else {
        s.goitre.animate(now, 0, _goitreSeconds);
      }
      s.cue(now + _holdSeconds, () {
        final end = s.time;
        if (s.deck) {
          s.gums.animate(end, 0, _gumsOut);
          s.tilt.animate(end, 0, _standSeconds);
        }
        _snapBack();
        s.health.animate(end, 1, _fillSeconds);
        s.cue(end + _fillSeconds, _conclude);
      });
    });
    _refresh();
  }

  /// The wrong food / common salt: 'No Change'. The sailor shakes his head
  /// and the meter only rises to 50%; then the next step.
  void _noChange() {
    final s = _scene;
    final t = s.time;
    _Sound.wrong.play();
    s.feedback('fb_no_change', error: true);
    if (s.deck) {
      s.turn.animate(t, _shakeTurn, _shakeLeg, legs: _shakeLegs);
      if (s.health.target < _healthHalf) {
        s.health.animate(t, _healthHalf, _fillSeconds);
      }
      s.cue(t + _shakeLeg * _shakeLegs, _afterNoChange);
    } else {
      s.cue(t + _wrongPause, _afterNoChange);
    }
    _refresh();
  }

  /// HTML `progressStep()` after the first wrong choice.
  void _afterNoChange() {
    final s = _scene;
    s.busy = false;
    if (s.step == 2) s.step = 3;
    _refresh();
  }

  /// HTML `triggerConclusionState()`: 'Review Findings' with a chime.
  void _conclude() {
    _scene
      ..busy = false
      ..cured = true;
    _Sound.success.play();
    _refresh();
  }

  /// HTML `triggerConclusion()`: the summary with its picture and confetti.
  void _review() {
    final s = _scene;
    if (!s.cured) return;
    s
      ..reviewed = true
      ..confettiAt = s.time;
    _refresh();
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('sum_title'),
      heading: () => _t('sum_heading'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _SummaryVisual(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
          // HTML `#next-sc-msg`, shown after Scenario 1 while Scenario 2 is
          // still to do.
          showNext: sc == 0 && !_lab.completedScenarios.contains(1),
        ),
      ),
    );
  }

  /// HTML `#compare-btn-container` ('Review Findings'), once the cure has
  /// played out.
  List<LabAction> _actions() {
    final s = _scene;
    if (!s.cured) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.check_circle,
        color: _Colors.emerald600,
        foreground: _Colors.white,
        highlight: !s.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown`: a press on the magnifying glass (step 1) or on an
  /// item (steps 2–3), not while an animation plays. A press on an item at
  /// step 1 is taken too, to explain what to do first.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grab != null || s.busy || s.step > 3) {
      return false;
    }
    final p = event.localPosition;
    return s.itemAt(p, _touch) != null || (s.step == 1 && s.magAt(p, _touch));
  }

  /// Inspects at step 1 (HTML: on pointer-down), otherwise picks the item
  /// up on a horizontal drag plane at its own height.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (s.busy || s.step > 3) return;
    final p = d.localPosition;
    if (s.step == 1) {
      if (s.magAt(p, _touch)) {
        _inspect();
      } else if (s.itemAt(p, _touch) != null) {
        _lab.showToast(_t('hint_inspect_${s.scenario + 1}'), isError: true);
      }
      return;
    }
    final f = s.itemAt(p, _touch);
    if (f == null) return;
    _grabY = f.pos.y;
    final hit = s.camera().onPlaneY(p, _grabY);
    _grabOffset = hit == null
        ? _V.zero
        : _V(hit.x - f.pos.x, 0, hit.z - f.pos.z);
    s.held = f;
    _grab = f;
    _grabScenario = s.scenario;
    _lastPointer = p;
  }

  /// HTML `handleMove`: the item follows the finger on the drag plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final f = _grab;
    if (f == null || _grabScenario != _scene.scenario) return;
    _lastPointer = d.localPosition;
    final hit = _scene.camera().onPlaneY(d.localPosition, _grabY);
    if (hit == null) return;
    f.pos = _V(
      (hit.x - _grabOffset.x).clamp(-_dragHalfX, _dragHalfX),
      _grabY,
      (hit.z - _grabOffset.z).clamp(_dragBackZ, _dragFrontZ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`: served if it lands on the tray / plate, otherwise it
  /// glides back (`playSound('pop')`) and a hint says where to drop it.
  void _release() {
    final f = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (f == null || scenario != s.scenario) return;
    s.held = null;
    if (s.lands(f, _lastPointer, _touch)) {
      _serve(f);
      return;
    }
    f.glide(s.time, f.item.home, _returnSeconds);
    _Sound.click.play();
    _lab.showToast(_t('miss_${s.scenario + 1}'), isError: true, sound: false);
    _scheduleFraming();
  }

  /// A screen-reader tap on the magnifying glass (added).
  void _activateMag() {
    if (_lab.isLabActive) _inspect();
  }

  /// A screen-reader tap on an item (added): at steps 2–3 it is served as
  /// if dropped on the tray / plate; at step 1 a hint says what to do.
  void _activateItem(_ItemState f) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null || f.gone) return;
    if (s.step == 1) {
      _lab.showToast(_t('hint_inspect_${s.scenario + 1}'), isError: true);
    } else if (s.step <= 3) {
      _serve(f);
    }
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final p = _lab.palette;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.medication,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${sc + 1}_step_${_scene.step.clamp(1, _stepCount)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('steps_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$_step'),
            steps: _stepData,
            current: _step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('step_word'),
            focusLabel: _t('focus_lbl'),
            actionLabel: _t('action_lbl'),
            resultLabel: _t('result_lbl'),
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#feedback-msg` ('No Change' / 'Success!').
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, time, _) => _feedback(context, time),
                ),
              ),
            ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  /// The feedback text while it pops up (1.5 s).
  Widget _feedback(BuildContext context, double time) {
    final s = _scene;
    final key = s.feedbackKey;
    if (key == null || s.feedbackAt < 0) return const SizedBox.shrink();
    final e = (time - s.feedbackAt) / _feedbackSeconds;
    if (e < 0 || e >= 1) return const SizedBox.shrink();
    // Tailwind `text-2xl md:text-4xl`.
    final size = MediaQuery.sizeOf(context).width >= 768 ? 36.0 : 24.0;
    return _FeedbackText(
      text: _t(key),
      isError: s.feedbackError,
      progress: e,
      fontSize: size,
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags on the scene are not screen-reader actions; the
                // scene and its items are announced instead.
                excludeFromSemantics: true,
                gestures: <Type, GestureRecognizerFactory>{
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
                          ..onUpdate = _onDragUpdate
                          ..onEnd = _onDragEnd
                          ..onCancel = _release,
                      ),
                },
                child: Semantics(
                  image: true,
                  label: _t(_scene.deck ? 'scene_s1' : 'scene_s2'),
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
                      ),
                    ),
                  ),
                ),
              ),
              // One semantics node for the tray / plate, the magnifying
              // glass and each item where it is drawn (added), so a screen
              // reader can find and tap them. They take no touches: those
              // reach the scene below.
              ValueListenableBuilder<int>(
                valueListenable: _layout,
                builder: (context, _, _) => _semanticsNodes(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _semanticsNodes() {
    final s = _scene;
    final cam = s.camera();
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fromRect(
          rect: s.targetRect(cam),
          child: Semantics(
            container: true,
            label: _t(s.deck ? 'lbl_tray' : 'lbl_plate'),
            child: const SizedBox.expand(),
          ),
        ),
        if (s.step == 1 && !s.inspected)
          Positioned.fromRect(
            rect: s.magRect(cam),
            child: Semantics(
              container: true,
              button: true,
              label: _t('lbl_magnify'),
              onTap: _activateMag,
              child: const SizedBox.expand(),
            ),
          ),
        for (final f in s.items)
          if (!f.gone)
            Positioned.fromRect(
              rect: s.pictureRect(f, cam),
              child: Semantics(
                container: true,
                button: true,
                label: _t(f.item.nameKey),
                onTap: () => _activateItem(f),
                child: const SizedBox.expand(),
              ),
            ),
      ],
    );
  }
}

/// HTML `.feedback-text` ('No Change' in red, 'Success!' in green): big
/// uppercase text with a hard black shadow that pops up in the middle of
/// the canvas (`@keyframes popUp`, 1.5 s, ease-out per keyframe).
class _FeedbackText extends StatelessWidget {
  const _FeedbackText({
    required this.text,
    required this.isError,
    required this.progress,
    required this.fontSize,
  });

  final String text;
  final bool isError;

  /// 0 … 1 through the animation.
  final double progress;
  final double fontSize;

  /// `popUp` keyframes: time, scale and rise (share of the text height).
  static const List<(double, double, double)> _keys = [
    (0, 0.5, 0),
    (0.2, 1.2, -0.1),
    (0.8, 1, -0.2),
    (1, 0.8, -0.3),
  ];

  @override
  Widget build(BuildContext context) {
    var scale = 0.8, rise = -0.3, opacity = 0.0;
    for (var i = 0; i < _keys.length - 1; i++) {
      final (t0, s0, r0) = _keys[i];
      final (t1, s1, r1) = _keys[i + 1];
      if (progress <= t1) {
        final u = Curves.easeOut.transform(
          ((progress - t0) / (t1 - t0)).clamp(0.0, 1.0),
        );
        scale = s0 + (s1 - s0) * u;
        rise = r0 + (r1 - r0) * u;
        opacity = i == _keys.length - 2 ? 1 - u : 1;
        break;
      }
    }
    final color = isError ? _Colors.red500 : _Colors.emerald500;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: text,
        child: ExcludeSemantics(
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: FractionalTranslation(
              translation: Offset(0, rise),
              child: Transform.scale(
                scale: scale,
                child: Text(
                  text.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: labLetterSpacing(text, fontSize * 0.05),
                    shadows: const [
                      Shadow(color: _Colors.black, offset: Offset(2, 2)),
                      Shadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 4),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed.
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.focusLabel,
    required this.actionLabel,
    required this.resultLabel,
  });

  final List<_StepInfo> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String focusLabel;
  final String actionLabel;
  final String resultLabel;

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

  Widget _body(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 11.5 * widget.fontScale,
      fontWeight: FontWeight.w500,
      height: 1.4,
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
    // Future steps: dimmed, closed.
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  if (step.focus.isNotEmpty) ...[
                    _heading(w.focusLabel, accent),
                    SizedBox(height: 3 * s),
                    _body(step.focus, p.textStrong),
                    SizedBox(height: 8 * s),
                  ],
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  if (step.result.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    _heading(w.resultLabel, p.textStrong),
                    SizedBox(height: 3 * s),
                    _body(step.result, p.textMuted),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#summary-visual-area`: S1 the orange (Vitamin C) above the healed
/// pink gums ('Prevents Scurvy'); S2 the iodised salt (Iodine) above a
/// healthy-breathing badge ('Prevents Goitre'; the HTML's 🫁 emoji). Below,
/// after Scenario 1, the HTML's "select the next scenario" note.
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.t,
    required this.showNext,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final first = scenario == 0;
    final accent = first ? _Colors.emerald500 : _Colors.cyan500;
    final nutrientInk = first ? _Colors.emerald400 : _Colors.cyan400;
    final panel = Container(
      constraints: BoxConstraints(maxWidth: 300 * s),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: p.isDark
            ? _Colors.slate700.withValues(alpha: 0.5)
            : _Colors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.isDark ? _Colors.slate600 : _Colors.slate300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArtBadge(
            art: first ? _Art.orange : _Art.shakerBlue,
            size: 60 * s,
            border: accent,
          ),
          SizedBox(height: 6 * s),
          Text(
            t(first ? 'sum_orange' : 'sum_iodised'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(first ? _Colors.amber400 : _Colors.cyan400),
              fontSize: 16 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Text(
              t(first ? 'sum_vit_c' : 'sum_iodine'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(nutrientInk),
                fontSize: 13 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Icon(Icons.arrow_downward, size: 18 * s, color: _Colors.slate400),
          SizedBox(height: 6 * s),
          if (first)
            Container(
              width: 64 * s,
              height: 32 * s,
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
              decoration: BoxDecoration(
                color: _Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _Colors.emerald500, width: 2),
              ),
              child: const CustomPaint(painter: _ArtPainter(_Art.gumsPink)),
            )
          else
            Container(
              width: 56 * s,
              height: 56 * s,
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: _Colors.emerald500,
                shape: BoxShape.circle,
                border: Border.all(color: _Colors.emerald300, width: 4 * s),
              ),
              child: const CustomPaint(painter: _LungsPainter()),
            ),
          SizedBox(height: 6 * s),
          Text(
            t(first ? 'sum_scurvy' : 'sum_goitre'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(_Colors.emerald400),
              fontSize: 14 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.isDark
                ? _Colors.slate800.withValues(alpha: 0.5)
                : _Colors.slate200.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.isDark ? _Colors.slate700 : _Colors.slate300,
            ),
          ),
          child: Center(child: panel),
        ),
        if (showNext) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.emerald500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.emerald500.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.emerald400),
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A picture on a white rounded card with a coloured border (the HTML
/// summary's `bg-white rounded-2xl p-2 border-2` icons).
class _ArtBadge extends StatelessWidget {
  const _ArtBadge({
    required this.art,
    required this.size,
    required this.border,
  });

  final _Art art;
  final double size;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: _Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: border, width: 2),
      ),
      child: CustomPaint(painter: _ArtPainter(art)),
    );
  }
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// The icons' soft drop shadow, blurred in the icon's 24-unit box.
  final Paint drop = Paint()
    ..color = _Colors.iconShadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9);

  /// Opacity of the fading gums sprite.
  final Paint layer = Paint();
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour, drawn on a unit circle) and the text painters of the
/// labels and the Health Meter's percentages. Owned by the page state and
/// disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<int, TextPainter> _percents = {};
  final Map<int, Paint> _balls = {};
  LabLang? _lang;
  double _labelSize = _labelPx;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text, {bool sub = false}) =>
      _labels['${sub ? 's' : 'm'}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: _Colors.chipText,
            fontSize: _labelSize * (sub ? _subScale : 1),
            fontWeight: sub ? FontWeight.w600 : FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Size of a label chip with [text] (and a second line [sub]).
  Size chipSize(String text, {String? sub}) {
    final a = label(text);
    final b = sub == null ? null : label(sub, sub: true);
    final w = math.max(a.width, b?.width ?? 0);
    final h = a.height + (b?.height ?? 0);
    return Size(w + 2 * _chipPadX * _labelSize, h + 2 * _chipPadY * _labelSize);
  }

  /// The Health Meter's "NN%" (`bold 20px`), drawn scaled to the bar.
  TextPainter percent(int value) => _percents[value] ??= TextPainter(
    text: TextSpan(
      text: '$value%',
      style: TextStyle(
        color: _Colors.barText,
        fontSize: _barTextPx,
        fontWeight: FontWeight.w700,
        height: 1,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle, lit from the upper right like the HTML key light.
  Paint ball(Color c) => _balls[c.toARGB32()] ??= () {
    final lit = _lit(c, _viewNormal);
    return Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.4),
        1.4,
        [labShade(lit, 0.35), lit, labShade(c, -0.3)],
        const [0, 0.45, 1],
      );
  }();

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    for (final tp in _percents.values) {
      tp.dispose();
    }
    _percents.clear();
    _balls.clear();
  }
}

/// The HTML `SVGs`, redrawn as paths in their view boxes (24 x 24 for the
/// icons, 100 x 50 for the gums), made once.
abstract final class _IconArt {
  /// `beef`: a rounded slab with three square holes.
  static final Path _beef = Path()
    ..fillType = PathFillType.evenOdd
    ..addRRect(RRect.fromLTRBR(2, 7, 22, 17, const Radius.circular(3)))
    ..addRect(const Rect.fromLTRB(6, 12, 8, 14))
    ..addRect(const Rect.fromLTRB(10, 12, 12, 14))
    ..addRect(const Rect.fromLTRB(14, 12, 16, 14));

  /// `biscuit`: a rounded square with five dots.
  static final RRect _biscuit = RRect.fromLTRBR(
    4,
    4,
    20,
    20,
    const Radius.circular(2),
  );
  static const List<Offset> _biscuitDots = [
    Offset(8, 8),
    Offset(16, 8),
    Offset(8, 16),
    Offset(16, 16),
    Offset(12, 12),
  ];

  /// `orange`: its last path repaints the whole r = 10 disc over the ring
  /// and the two green leaf marks drawn before it, so the HTML shows a
  /// plain orange disc.
  static final Path _orange = Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10));

  /// `shaker` / `shakerBlue`: cap with a pour hole, body with three holes.
  static final Path _shaker = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(15, 2)
    ..lineTo(9, 2)
    ..cubicTo(7.897, 2, 7, 2.897, 7, 4)
    ..lineTo(7, 6)
    ..lineTo(5, 6)
    ..lineTo(5, 8)
    ..lineTo(19, 8)
    ..lineTo(19, 6)
    ..lineTo(17, 6)
    ..lineTo(17, 4)
    ..cubicTo(17, 2.897, 16.103, 2, 15, 2)
    ..close()
    ..addRect(const Rect.fromLTRB(11, 4, 13, 6))
    ..moveTo(7, 10)
    ..lineTo(7, 20)
    ..cubicTo(7, 21.103, 7.897, 22, 9, 22)
    ..lineTo(15, 22)
    ..cubicTo(16.103, 22, 17, 21.103, 17, 20)
    ..lineTo(17, 10)
    ..close()
    ..addOval(Rect.fromCircle(center: const Offset(9, 17), radius: 1))
    ..addOval(Rect.fromCircle(center: const Offset(13, 17), radius: 1))
    ..addOval(Rect.fromCircle(center: const Offset(11, 13), radius: 1));
  static const List<Offset> _shakerDots = [
    Offset(10, 4),
    Offset(12, 4),
    Offset(14, 4),
  ];

  /// `shakerBlue`'s white plus.
  static final Path _plus = Path()
    ..addPolygon(const [
      Offset(11, 13),
      Offset(11, 11),
      Offset(13, 11),
      Offset(13, 13),
      Offset(15, 13),
      Offset(15, 15),
      Offset(13, 15),
      Offset(13, 17),
      Offset(11, 17),
      Offset(11, 15),
      Offset(9, 15),
      Offset(9, 13),
    ], true);

  /// `magnify`: lens ring and handle.
  static final Path _magnify = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(15.5, 14)
    ..lineTo(14.71, 14)
    ..lineTo(14.43, 13.73)
    ..cubicTo(15.41, 12.59, 16, 11.11, 16, 9.5)
    ..cubicTo(16, 5.91, 13.09, 3, 9.5, 3)
    ..cubicTo(5.91, 3, 3, 5.91, 3, 9.5)
    ..cubicTo(3, 13.09, 5.91, 16, 9.5, 16)
    ..cubicTo(11.11, 16, 12.59, 15.41, 13.73, 14.43)
    ..lineTo(14, 14.71)
    ..lineTo(14, 15.5)
    ..lineTo(19, 20.49)
    ..lineTo(20.49, 19)
    ..close()
    ..moveTo(9.5, 14)
    ..cubicTo(7.01, 14, 5, 11.99, 5, 9.5)
    ..cubicTo(5, 7.01, 7.01, 5, 9.5, 5)
    ..cubicTo(11.99, 5, 14, 7.01, 14, 9.5)
    ..cubicTo(14, 11.99, 11.99, 14, 9.5, 14)
    ..close();

  /// `gumsRed` / `gumsPink` (100 x 50): lips, mouth, gums (three nested
  /// lens shapes), two rows of teeth and, while sick, three blood spots and
  /// a missing upper tooth.
  static Path _lens(double inset, double bulge) => Path()
    ..moveTo(inset, 25)
    ..quadraticBezierTo(50, 25 - bulge, 100 - inset, 25)
    ..quadraticBezierTo(50, 25 + bulge, inset, 25)
    ..close();
  static final Path _lips = _lens(5, 23);
  static final Path _mouth = _lens(10, 18);
  static final Path _gums = _lens(15, 13);
  static const List<Rect> _teethTop = [
    Rect.fromLTWH(25, 18, 6, 10),
    Rect.fromLTWH(33, 18, 7, 10),
    Rect.fromLTWH(42, 18, 8, 11),
    Rect.fromLTWH(62, 18, 7, 10),
    Rect.fromLTWH(71, 18, 6, 9),
  ];
  static const Rect _healedTooth = Rect.fromLTWH(52, 18, 8, 11);
  static const List<Rect> _teethBottom = [
    Rect.fromLTWH(27, 28, 6, 8),
    Rect.fromLTWH(35, 28, 7, 8),
    Rect.fromLTWH(44, 28, 7, 8),
    Rect.fromLTWH(53, 28, 7, 8),
    Rect.fromLTWH(62, 28, 7, 8),
    Rect.fromLTWH(71, 28, 6, 7),
  ];
  static const List<(Offset, double)> _blood = [
    (Offset(37, 27), 1.5),
    (Offset(50, 20), 2),
    (Offset(65, 29), 1.5),
  ];
  static const Radius _toothRadius = Radius.circular(2);

  static bool _isGums(_Art art) => art == _Art.gumsRed || art == _Art.gumsPink;

  /// The outline [drop] shadows are cast from.
  static Path? _silhouette(_Art art) => switch (art) {
    _Art.beef => _beef,
    _Art.orange => _orange,
    _Art.shaker || _Art.shakerBlue => _shaker,
    _Art.magnify => _magnify,
    _Art.biscuit => Path()..addRRect(_biscuit),
    _Art.gumsRed || _Art.gumsPink => null,
  };

  /// Draws [art] into [box] with the reused [fill] paint; [drop] adds the
  /// soft drop shadow.
  static void draw(
    Canvas canvas,
    _Art art,
    Rect box,
    Paint fill, {
    Paint? drop,
  }) {
    final gums = _isGums(art);
    canvas.save();
    canvas.translate(box.left, box.top);
    canvas.scale(box.width / (gums ? 100 : 24), box.height / (gums ? 50 : 24));
    void fillPath(Path path, Color color) =>
        canvas.drawPath(path, fill..color = color);
    final outline = drop == null ? null : _silhouette(art);
    if (outline != null) {
      canvas.save();
      canvas.translate(0, 0.9);
      canvas.drawPath(outline, drop!);
      canvas.restore();
    }
    switch (art) {
      case _Art.beef:
        fillPath(_beef, _Colors.beef);
      case _Art.biscuit:
        canvas.drawRRect(_biscuit, fill..color = _Colors.biscuit);
        for (final c in _biscuitDots) {
          canvas.drawCircle(c, 1, fill..color = _Colors.biscuitDot);
        }
      case _Art.orange:
        fillPath(_orange, _Colors.orange);
      case _Art.shaker:
      case _Art.shakerBlue:
        final blue = art == _Art.shakerBlue;
        fillPath(_shaker, blue ? _Colors.shakerBlue : _Colors.shakerGrey);
        for (final c in _shakerDots) {
          canvas.drawCircle(c, 0.5, fill..color = _Colors.shakerDot);
        }
        if (blue) fillPath(_plus, _Colors.white);
      case _Art.magnify:
        fillPath(_magnify, _Colors.magnify);
      case _Art.gumsRed:
      case _Art.gumsPink:
        final healed = art == _Art.gumsPink;
        fillPath(_lips, healed ? _Colors.lipsPink : _Colors.lipsRed);
        fillPath(_mouth, _Colors.mouth);
        fillPath(_gums, healed ? _Colors.gumsPink : _Colors.gumsRed);
        final tooth = fill
          ..color = healed ? _Colors.teeth : _Colors.teethYellow;
        for (final r in _teethTop) {
          canvas.drawRRect(RRect.fromRectAndRadius(r, _toothRadius), tooth);
        }
        if (healed) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(_healedTooth, _toothRadius),
            tooth,
          );
        }
        for (final r in _teethBottom) {
          canvas.drawRRect(RRect.fromRectAndRadius(r, _toothRadius), tooth);
        }
        if (!healed) {
          for (final (c, r) in _blood) {
            canvas.drawCircle(c, r, fill..color = _Colors.blood);
          }
        }
    }
    canvas.restore();
  }
}

/// A picture for widgets (the summary popup). Static pictures, so the
/// paints are shared.
class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.art);

  final _Art art;

  static final Paint _fill = Paint();
  static final Paint _drop = Paint()
    ..color = _Colors.iconShadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9);

  @override
  void paint(Canvas canvas, Size size) => _IconArt.draw(
    canvas,
    art,
    Offset.zero & size,
    _fill,
    drop: _IconArt._isGums(art) ? null : _drop,
  );

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.art != art;
}

/// The HTML summary's 🫁 (lungs) emoji, drawn so it shows on every device:
/// a windpipe branching into two pink lobes.
class _LungsPainter extends CustomPainter {
  const _LungsPainter();

  static final Path _left = Path()
    ..moveTo(10.6, 9.5)
    ..cubicTo(7.4, 8.4, 3.2, 12, 3, 17.2)
    ..cubicTo(2.9, 20.6, 5.4, 22.2, 8, 21.6)
    ..cubicTo(10, 21.1, 10.8, 19.6, 10.8, 17.6)
    ..close();
  static final Path _right = Path()
    ..moveTo(13.4, 9.5)
    ..cubicTo(16.6, 8.4, 20.8, 12, 21, 17.2)
    ..cubicTo(21.1, 20.6, 18.6, 22.2, 16, 21.6)
    ..cubicTo(14, 21.1, 13.2, 19.6, 13.2, 17.6)
    ..close();
  static final Path _airway = Path()
    ..moveTo(12, 2.5)
    ..lineTo(12, 10.5)
    ..moveTo(12, 10.5)
    ..quadraticBezierTo(10.4, 11.4, 8.2, 14.4)
    ..moveTo(12, 10.5)
    ..quadraticBezierTo(13.6, 11.4, 15.8, 14.4);

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    for (final lobe in [_left, _right]) {
      canvas.drawPath(lobe, _fill..color = _Colors.rose300);
      canvas.drawPath(
        lobe,
        _stroke
          ..strokeWidth = 0.9
          ..color = _Colors.rose500,
      );
    }
    canvas.drawPath(
      _airway,
      _stroke
        ..strokeWidth = 2.2
        ..color = _Colors.white,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungsPainter old) => false;
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

/// HTML lights: `AmbientLight(0xffffff, 0.6)` and the warm key light
/// `DirectionalLight(0xfff5b6, 0.8)` at (10, 20, 10), normalised.
const _V _keyLight = _V(0.4082, 0.8165, 0.4082);
const double _ambient = 0.6;
const double _keyPower = 0.8;
const List<double> _keyTint = [1, 0.961, 0.714];

/// A surface turned to the start camera (round meshes) and the side of an
/// upright mesh turned to the camera and the key light.
const _V _viewNormal = _V(0, 0.49, 0.87);
const _V _sideNormal = _V(0.35, 0.25, 0.9);

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a surface with normal [n].
Color _lit(Color c, _V n) {
  final k = _keyPower * math.max(0.0, n.dot(_keyLight));
  double channel(double v, int i) =>
      math.min(1.0, v * (_ambient + k * _keyTint[i]));
  return Color.from(
    alpha: c.a,
    red: channel(c.r, 0),
    green: channel(c.g, 1),
    blue: channel(c.b, 2),
  );
}

/// Convex hull of [pts] (Andrew's monotone chain): the outline of a convex
/// mesh from its projected vertices.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return List.of(pts);
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Offset>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// The part of the polygon [poly] at least [near] in front of the camera
/// (one Sutherland–Hodgman pass).
List<_V> _clipNear(List<_V> poly, _Cam cam, double near) {
  final out = <_V>[];
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i], b = poly[(i + 1) % poly.length];
    final da = cam.depth(a) - near, db = cam.depth(b) - near;
    if (da >= 0) out.add(a);
    if ((da >= 0) != (db >= 0)) out.add(_V.lerp(a, b, da / (da - db)));
  }
  return out;
}

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;
  final List<(double, int, VoidCallback)> _queue = [];

  _Pens get pens => cache.pens;

  // ------------------------------------------------------------ ordering

  /// Queues [draw] at [depth] (skipped when behind the camera).
  void later(double depth, VoidCallback draw) {
    if (depth < _clipDepth) return;
    _queue.add((depth, _queue.length, draw));
  }

  /// Draws the queue, farthest first.
  void flush() {
    _queue.sort((a, b) {
      final c = b.$1.compareTo(a.$1);
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
    for (final (_, _, draw) in _queue) {
      draw();
    }
    _queue.clear();
  }

  /// The reused path set to the closed polygon [pts].
  Path polygon(List<Offset> pts) {
    final path = pens.path..reset();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  // ---------------------------------------------------------- primitives

  /// A flat plane now (the deck, the village ground), clipped to the part
  /// in front of the camera.
  void ground(List<_V> corners, Color color) {
    final pts = _clipNear(corners, cam, _clipDepth);
    if (pts.length < 3) return;
    canvas.drawPath(
      polygon([for (final p in pts) cam.p(p)]),
      pens.fill..color = color,
    );
  }

  /// A shaded ellipse of radii [rx] x [ry] at [c], turned by [angle].
  void blob(Offset c, double rx, double ry, Color color, {double angle = 0}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(math.max(0.01, rx), math.max(0.01, ry));
    canvas.drawCircle(Offset.zero, 1, cache.ball(color));
    canvas.restore();
  }

  /// An ellipsoid at [c] with semi-axes [a], [b], [d] as the camera sees
  /// it: the projected axes' ellipse (eigen-decomposition of Σ q qᵀ).
  void ellipsoid(_V c, _V a, _V b, _V d, Color color) {
    final pa = cam.dp(c, a), pb = cam.dp(c, b), pd = cam.dp(c, d);
    final m00 = pa.dx * pa.dx + pb.dx * pb.dx + pd.dx * pd.dx;
    final m01 = pa.dx * pa.dy + pb.dx * pb.dy + pd.dx * pd.dy;
    final m11 = pa.dy * pa.dy + pb.dy * pb.dy + pd.dy * pd.dy;
    final mean = (m00 + m11) / 2;
    final spread = math.sqrt(
      math.max(0.0, (m00 - m11) * (m00 - m11) / 4 + m01 * m01),
    );
    blob(
      cam.p(c),
      math.sqrt(mean + spread),
      math.sqrt(math.max(0.0, mean - spread)),
      color,
      angle: 0.5 * math.atan2(2 * m01, m00 - m11),
    );
  }

  /// SphereGeometry of radius [r] in the frame [xf] (its axes carry the
  /// mesh scale).
  void sphere(_Xf xf, double r, Color color) {
    final depth = cam.depth(xf.o);
    if (depth - r < _clipDepth) return;
    later(depth, () => ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color));
  }

  /// A small unlit sphere (`MeshBasicMaterial` eyes).
  void dot(_V c, double r, Color color) => later(
    cam.depth(c),
    () => canvas.drawCircle(
      cam.p(c),
      math.max(0.8, r * cam.scaleAt(c)),
      pens.fill..color = color,
    ),
  );

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf], its axis
  /// along the frame's y; [depth] overrides its place in the draw order.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 12,
    double? depth,
  }) {
    final d = cam.depth(xf.o);
    if (d - math.max(h / 2, math.max(rTop, rBottom)) < _clipDepth) return;
    later(
      depth ?? d,
      () => _drawCylinder(xf, rTop, rBottom, h, color, segments: segments),
    );
  }

  /// Draws a cylinder now: its outline (hull of both rims), shading along
  /// its side and the end cap turned to the camera.
  void _drawCylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    required int segments,
  }) {
    final hh = h / 2;
    final top = <Offset>[];
    final bottom = <Offset>[];
    for (var i = 0; i < segments; i++) {
      final t = 2 * math.pi * i / segments;
      final c = math.cos(t), s = math.sin(t);
      top.add(cam.p(xf(rTop * c, hh, rTop * s)));
      bottom.add(cam.p(xf(rBottom * c, -hh, rBottom * s)));
    }
    final a = xf(0, -hh, 0), b = xf(0, hh, 0);
    final body = _lit(color, _sideNormal);
    canvas.drawPath(
      polygon(_hull([...top, ...bottom])),
      pens.fill..color = body,
    );
    _bands(
      cam.p(a),
      cam.p(b),
      rBottom * cam.scaleAt(a),
      rTop * cam.scaleAt(b),
      body,
    );
    final axis = xf.y.unit;
    final showTop = (cam.eye - b).dot(axis) > 0;
    if ((showTop ? rTop : rBottom) > 0.0005) {
      canvas.drawPath(
        polygon(showTop ? top : bottom),
        pens.fill..color = _lit(color, showTop ? axis : -axis),
      );
    }
  }

  /// Shading bands along a mesh's side from [pa] to [pb] (half widths [wa],
  /// [wb]): shadow away from the key light, highlight towards it.
  void _bands(Offset pa, Offset pb, double wa, double wb, Color body) {
    final d = pb - pa;
    final len = d.distance;
    if (len < 1 || wa + wb < 2) return;
    var n = Offset(-d.dy / len, d.dx / len);
    // The key light comes from the upper right of the screen.
    if (n.dy > 0 || (n.dy == 0 && n.dx < 0)) n = -n;
    void band(double from, double to, Color color) => canvas.drawPath(
      polygon([
        pa + n * (wa * from),
        pb + n * (wb * from),
        pb + n * (wb * to),
        pa + n * (wa * to),
      ]),
      pens.fill..color = color,
    );
    band(-0.92, -0.3, labShade(body, -0.2));
    band(0.28, 0.6, labShade(body, 0.22));
  }

  /// BoxGeometry of [size] centred at [c]: the faces turned to the camera,
  /// lit by the key light, with soft edges.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (var i = 0; i < 8; i++) {
      final k = _V(
        c.x + ((i & 1) != 0 ? hx : -hx),
        c.y + ((i & 2) != 0 ? hy : -hy),
        c.z + ((i & 4) != 0 ? hz : -hz),
      );
      if (cam.depth(k) < _clipDepth) return;
    }
    later(cam.depth(c), () {
      for (final face in _boxFaces) {
        final n = face.normal;
        final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
        if (n.dot(cam.eye - mid) <= 0) continue;
        final path = polygon([
          for (final k in face.corners)
            cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        ]);
        canvas.drawPath(path, pens.fill..color = _lit(color, n));
        if (edge > 0) {
          canvas.drawPath(
            path,
            pens.stroke
              ..strokeWidth = 0.8
              ..color = labShade(color, -0.5).withValues(alpha: edge),
          );
        }
      }
    });
  }

  /// Soft contact shadow now: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz) {
    if (cam.depth(c) - rz < _clipDepth) return;
    final p = cam.p(c);
    final w = rx * cam.scaleAt(c);
    final h =
        (cam.p(c + _V(0, 0, rz)).dy - cam.p(c - _V(0, 0, rz)).dy).abs() / 2;
    canvas.drawOval(
      Rect.fromCenter(center: p, width: 2 * w, height: 2 * math.max(1, h)),
      pens.shadow,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the ship's
/// deck (railing, crate, sailor, Meal Tray), S2 the village (shelf,
/// villager, Meal Plate); both with the Health Meter, the magnifying glass
/// and the items, then the labels, the held item and the confetti on top.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.camera(), cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    // Floor `PlaneGeometry(24, 12)`: the deck (`Mats.wood`) or the ground.
    g.ground(const [
      _V(-_floorHalfW, 0, -_floorHalfD),
      _V(_floorHalfW, 0, -_floorHalfD),
      _V(_floorHalfW, 0, _floorHalfD),
      _V(-_floorHalfW, 0, _floorHalfD),
    ], _lit(s.deck ? _Colors.wood : _Colors.soil, _V.up));
    if (s.deck) {
      _paintDeck(g);
    } else {
      _paintVillage(g);
    }
    g.flush();
    _paintSalt(g);
    _paintBar(g, _healthBar, s.health.at(s.time));
    if (showLabels) _paintLabels(g);
    final held = s.held;
    if (held != null) _paintHeld(g, held);
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: deck, railing, crate with the foods, sailor and his
  /// Meal Tray.
  void _paintDeck(_Gfx g) {
    // Contact shadows (the key light at (10, 20, 10) casts towards -x /
    // -z).
    g.shadow(_patientPos + const _V(-0.3, 0.01, -0.25), 0.85, 0.5);
    g.shadow(const _V(3.6, 0.01, -2.4), 1.9, 1.25);
    g.shadow(_tray + const _V(-0.1, -0.04, -0.1), 1.15, 0.85);
    for (var x = -_railHalf; x <= _railHalf; x += _postGap) {
      g.cylinder(
        _Xf.at(_V(x, _postH / 2, _railZ)),
        _postR,
        _postR,
        _postH,
        _Colors.wood,
        segments: 8,
      );
    }
    g.box(_rail, _railSize, _Colors.wood);
    g.box(_crate, _crateSize, _Colors.wood, edge: 0.45);
    g.box(_tray, _traySize, _Colors.metal, edge: 0.5);
    _paintSailor(g);
    _paintMag(g);
    _paintItems(g);
  }

  /// `buildSailor()`: navy trousers, white shirt with a navy collar, white
  /// sailor hat, skin head and hands; slouching while sick, shaking his
  /// head at a wrong food; the gums sprite on his face.
  void _paintSailor(_Gfx g) {
    final s = scene;
    final body = s.patient();
    for (final x in const [-0.25, 0.25]) {
      g.cylinder(body.child(_V(x, 0.5, 0)), 0.2, 0.2, 1, _Colors.clothesBlue);
    }
    g.cylinder(
      body.child(const _V(0, 1.6, 0)),
      0.5,
      0.5,
      1.2,
      _Colors.clothesWhite,
      segments: 16,
    );
    g.cylinder(
      body.child(const _V(0, 2.1, 0)),
      0.55,
      0.55,
      0.2,
      _Colors.clothesBlue,
      segments: 16,
    );
    _paintArms(g, body, _Colors.clothesWhite, _Colors.skin);
    final head = s.head(body);
    g.sphere(head, 0.4, _Colors.skin);
    for (final x in const [-0.15, 0.15]) {
      g.dot(head(x, 0.1, 0.35), 0.05, _Colors.eye);
    }
    _paintHat(g, head, 0.4, 0.45, 0.1, _Colors.clothesWhite);
    final alpha = s.gums.at(s.time);
    if (alpha > 0.01) {
      final at = head.at(_gumsAt);
      g.later(g.cam.depth(at), () => _paintGums(g, at, alpha));
    }
  }

  /// Arms `CylinderGeometry(0.15, 0.15, 1.2)` at x ±0.65 (`rotation.z`
  /// ∓0.2) and hands `SphereGeometry(0.18)` at (±0.75, 1, 0).
  void _paintArms(_Gfx g, _Xf body, Color sleeve, Color hand) {
    for (final side in const [-1.0, 1.0]) {
      g.cylinder(
        body.child(_V(side * 0.65, 1.6, 0), rz: side * 0.2),
        0.15,
        0.15,
        1.2,
        sleeve,
        segments: 10,
      );
      g.sphere(body.child(_V(side * 0.75, 1, 0)), 0.18, hand);
    }
  }

  /// A hat `CylinderGeometry(r, r, h)` at height [y] on [head], tipped
  /// back (`rotation.x = -0.1`). Seen from below (a close-up), its
  /// underside is drawn before the head, which then covers its middle as
  /// the HTML depth buffer does.
  void _paintHat(_Gfx g, _Xf head, double y, double r, double h, Color c) {
    final hat = head.child(_V(0, y, 0), rx: -0.1);
    final below = g.cam.eye.y < hat.o.y - h / 2;
    g.cylinder(
      hat,
      r,
      r,
      h,
      c,
      segments: 20,
      depth: below ? g.cam.depth(head.o) + 0.01 : null,
    );
  }

  /// The gums sprite (`SVGs.gumsRed`, redrawn `gumsPink` once healed), a
  /// camera-facing 0.6 x 0.3 picture at its opacity.
  void _paintGums(_Gfx g, _V at, double alpha) {
    final k = g.cam.scaleAt(at);
    final rect = Rect.fromCenter(
      center: g.cam.p(at),
      width: _gumsW * k,
      height: _gumsH * k,
    );
    final canvas = g.canvas;
    final fade = alpha < 0.99;
    if (fade) {
      canvas.saveLayer(
        rect.inflate(2),
        _pens.layer..color = _Colors.black.withValues(alpha: alpha),
      );
    }
    _IconArt.draw(
      canvas,
      scene.gumsHealed ? _Art.gumsPink : _Art.gumsRed,
      rect,
      _pens.fill,
    );
    if (fade) canvas.restore();
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the village ground, the shelf with the salt
  /// shakers, the villager and his Meal Plate with food.
  void _paintVillage(_Gfx g) {
    g.shadow(_patientPos + const _V(-0.3, 0.01, -0.25), 0.85, 0.5);
    // The shelf hangs at y = 2: its shadow falls 1 unit towards -x / -z.
    g.shadow(_shelf + const _V(-1, -1.99, -1), 2, 0.8);
    g.shadow(_plate + const _V(-0.08, -0.04, -0.08), 1.08, 1.0);
    g.box(_shelf, _shelfSize, _Colors.wood, edge: 0.45);
    g.cylinder(
      const _Xf.at(_plate),
      _plateR,
      _plateR,
      _plateH,
      _Colors.metal,
      segments: 32,
    );
    g.cylinder(
      const _Xf.at(_plateFood),
      _plateFoodR,
      _plateFoodR,
      _plateH,
      _Colors.plateFood,
      segments: 24,
    );
    _paintVillager(g);
    _paintMag(g);
    _paintItems(g);
  }

  /// `buildHimalayan()`: dark trousers, red tunic, a navy cap, dark skin;
  /// the goitre swelling on the front of the neck.
  void _paintVillager(_Gfx g) {
    final s = scene;
    final body = s.patient();
    for (final x in const [-0.25, 0.25]) {
      g.cylinder(body.child(_V(x, 0.5, 0)), 0.2, 0.2, 1, _Colors.trousers);
    }
    g.cylinder(
      body.child(const _V(0, 1.6, 0)),
      0.5,
      0.5,
      1.2,
      _Colors.clothesRed,
      segments: 16,
    );
    g.cylinder(
      body.child(const _V(0, 2.4, 0)),
      0.25,
      0.25,
      0.4,
      _Colors.skinDark,
    );
    _paintArms(g, body, _Colors.clothesRed, _Colors.skinDark);
    final head = s.head(body);
    g.sphere(head, 0.4, _Colors.skinDark);
    for (final x in const [-0.15, 0.15]) {
      g.dot(head(x, 0.1, 0.35), 0.05, _Colors.eye);
    }
    _paintHat(g, head, 0.35, 0.42, 0.2, _Colors.clothesBlue);
    final k = s.goitre.at(s.time);
    if (k > 0.01) {
      g.sphere(
        body.child(
          _goitreAt,
          sx: _goitreScale.x * k,
          sy: _goitreScale.y * k,
          sz: _goitreScale.z * k,
        ),
        _goitreR,
        _Colors.skinDark,
      );
    }
  }

  /// Salt grains falling from a tilted shaker onto the plate (added: the
  /// HTML tilts the shaker's group, which a camera-facing sprite ignores).
  void _paintSalt(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    for (final f in s.items) {
      final tilt = f.tilt.at(s.time);
      if (tilt.abs() < 0.25 || f.gliding) continue;
      final (c, side) = s.picture(f, cam);
      final a = -tilt;
      final cap = c + Offset(math.sin(a), -math.cos(a)) * (side * 0.4);
      final bottom = cam.p(_plateFood + const _V(0, _plateH / 2, 0)).dy;
      final fall = bottom - cap.dy;
      if (fall <= 0) continue;
      final r = math.max(0.9, 0.025 * cam.scaleAt(f.pos));
      for (var i = 0; i < 9; i++) {
        final u = (s.time * 2.2 + i / 9) % 1;
        final x = cap.dx + (i % 3 - 1) * r * 1.6 + u * side * 0.1;
        g.canvas.drawCircle(
          Offset(x, cap.dy + u * fall),
          r,
          _pens.fill..color = _Colors.salt.withValues(alpha: 0.9 - u * 0.4),
        );
      }
    }
  }

  // ----------------------------------------------------------- shared

  /// The magnifying-glass sprite over the mouth / neck.
  void _paintMag(_Gfx g) {
    final s = scene;
    final k = s.mag.at(s.time);
    if (k <= 0.01) return;
    final at = s.magPos;
    g.later(g.cam.depth(at), () {
      final side = _iconSize * g.cam.scaleAt(at) * k;
      _IconArt.draw(
        g.canvas,
        _Art.magnify,
        Rect.fromCenter(center: g.cam.p(at), width: side, height: side),
        _pens.fill,
        drop: _pens.drop,
      );
    });
  }

  /// The items still on the crate / shelf or gliding.
  void _paintItems(_Gfx g) {
    final s = scene;
    for (final f in s.items) {
      if (f.gone || identical(f, s.held)) continue;
      if (f.scale.at(s.time) <= 0.01) continue;
      g.later(g.cam.depth(f.pos), () => _paintPicture(g, f));
    }
  }

  /// HTML `updateIconSprite`: the item's picture (no card), tilted while it
  /// sprinkles.
  void _paintPicture(_Gfx g, _ItemState f) {
    final s = scene;
    final (c, side) = s.picture(f, g.cam);
    final tilt = f.tilt.at(s.time);
    final canvas = g.canvas;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (tilt != 0) canvas.rotate(-tilt);
    _IconArt.draw(
      canvas,
      f.item.art,
      Rect.fromCenter(center: Offset.zero, width: side, height: side),
      _pens.fill,
      drop: _pens.drop,
    );
    canvas.restore();
  }

  /// The held item on top, with its name.
  void _paintHeld(_Gfx g, _ItemState f) {
    if (g.cam.depth(f.pos) < _clipDepth) return;
    _paintPicture(g, f);
    if (!showLabels) return;
    final (c, side) = scene.picture(f, g.cam);
    final (name, sub) = _splitName(_t(f.item.nameKey));
    final size = cache.chipSize(name, sub: sub);
    _drawChip(
      g,
      _clampChip((c + Offset(0, side / 2) + _chipOffset(size, _below)) & size),
      name,
      sub,
    );
  }

  /// HTML `createStatusBarSprite`: dark box with a light border, filled
  /// red / yellow / green, with the percentage inside; its caption is a
  /// label chip above it.
  void _paintBar(_Gfx g, _V at, double fill) {
    if (g.cam.depth(at) < _clipDepth) return;
    final c = g.cam.p(at);
    final k = g.cam.scaleAt(at);
    final outer = Rect.fromCenter(
      center: c + Offset(0, _barDrop * k),
      width: _barOuterW * k,
      height: _barOuterH * k,
    );
    final rr = RRect.fromRectAndRadius(outer, Radius.circular(_barRadius * k));
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.barBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = math.max(1.5, _barBorder * k)
        ..color = _Colors.barBorder,
    );
    final value = fill.clamp(0.0, 1.0);
    final inset = _barInset * k;
    final width = (outer.width - 2 * inset) * value;
    if (width > 0.5) {
      final color = value > _barGreenFrom
          ? _Colors.barHigh
          : (value > _barYellowFrom ? _Colors.barMid : _Colors.barLow);
      g.canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            outer.left + inset,
            outer.top + inset,
            width,
            outer.height - 2 * inset,
          ),
          Radius.circular(_barFillRadius * k),
        ),
        _pens.fill..color = color,
      );
    }
    final tp = cache.percent((value * 100).round());
    final f = k / _barPxPerUnit;
    g.canvas.save();
    g.canvas.translate(outer.center.dx, outer.center.dy);
    g.canvas.scale(f, f);
    tp.paint(g.canvas, Offset(-tp.width / 2, -tp.height / 2));
    g.canvas.restore();
  }

  /// Every text sprite of the scene as a label chip (HTML `labelDict`).
  void _paintLabels(_Gfx g) {
    final s = scene;
    _chipAt(
      g,
      s.patient().at(_feetLabelAt),
      _t(s.deck ? 'lbl_sailor' : 'lbl_villager'),
      align: _below,
    );
    _chipAt(
      g,
      _healthBar + const _V(0, _barCaptionLift, 0),
      _t('lbl_health'),
      align: _above,
    );
    _chipAt(
      g,
      s.deck ? _trayLabelAt : _plateLabelAt,
      _t(s.deck ? 'lbl_tray' : 'lbl_plate'),
      align: _below,
    );
    _paintItemChips(g);
  }

  /// The items' names under their pictures ("Orange" / "(Vit C)" on two
  /// lines, as the HTML icon sprites split them). A chip that would touch
  /// its left neighbour's is stacked under it.
  void _paintItemChips(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    Rect? previous;
    for (final f in s.items) {
      if (f.gone ||
          identical(f, s.held) ||
          f.scale.at(s.time) < 0.99 ||
          cam.depth(f.pos) < _clipDepth) {
        continue;
      }
      final (c, side) = s.picture(f, cam);
      if (!_onCanvas(c)) continue;
      final (name, sub) = _splitName(_t(f.item.nameKey));
      final size = cache.chipSize(name, sub: sub);
      var rect = (c + Offset(0, side / 2) + _chipOffset(size, _below)) & size;
      if (previous != null && rect.overlaps(previous.inflate(_chipGap))) {
        rect = rect.shift(Offset(0, previous.bottom + _chipGap - rect.top));
      }
      rect = _clampChip(rect);
      _drawChip(g, rect, name, sub);
      previous = rect;
    }
  }

  /// A one-line chip on the world point [at] (skipped when it is behind
  /// the camera or off the canvas, as in a close-up).
  void _chipAt(_Gfx g, _V at, String text, {required (double, double) align}) {
    if (g.cam.depth(at) < _clipDepth) return;
    final p = g.cam.p(at);
    if (!_onCanvas(p)) return;
    final size = cache.chipSize(text);
    _drawChip(g, _clampChip((p + _chipOffset(size, align)) & size), text, null);
  }

  /// Is the design point [p] across the visible canvas? Only then is its
  /// chip drawn (and kept inside the canvas).
  bool _onCanvas(Offset p) =>
      p.dx >= scene.labelLeft && p.dx <= scene.labelRight;

  /// [rect] shifted into the visible canvas (left of the tool column).
  Rect _clampChip(Rect rect) {
    final s = scene;
    var r = rect;
    if (r.right > s.labelRight) r = r.shift(Offset(s.labelRight - r.right, 0));
    if (r.left < s.labelLeft) r = r.shift(Offset(s.labelLeft - r.left, 0));
    return r;
  }

  /// HTML `createTextSprite`: dark chip with an emerald border and white
  /// bold text (a second, smaller line for the bracket).
  void _drawChip(_Gfx g, Rect rect, String text, String? sub) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.45),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.chipBorder,
    );
    final top = cache.label(text);
    final y = rect.top + _chipPadY * cache.labelSize;
    top.paint(g.canvas, Offset(rect.center.dx - top.width / 2, y));
    if (sub != null) {
      final second = cache.label(sub, sub: true);
      second.paint(
        g.canvas,
        Offset(rect.center.dx - second.width / 2, y + top.height),
      );
    }
  }

  /// HTML `confetti(...)` with the summary.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 < 0) return;
    final ticks = (s.time - t0) * 60;
    if (ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      canvas.save();
      canvas.translate(
        _confettiOrigin.dx + math.cos(c.angle) * d,
        _confettiOrigin.dy + math.sin(c.angle) * d + fall,
      );
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        _pens.fill..color = c.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize;
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
