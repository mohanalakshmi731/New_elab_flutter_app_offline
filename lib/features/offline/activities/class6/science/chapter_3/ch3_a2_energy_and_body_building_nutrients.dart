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

/// Class 6 Science • Chapter 3 • Activity 2
/// Energy and Body-Building Nutrients ("Fueling the Body: Energy vs.
/// Building Blocks").
///
/// Native Flutter port of
/// `Cl6S-Ch03-A2-Energy_and_Body_Building_Nutrients.html`.
///
/// Scenario 1 (The Energy Challenge): a tired runner on a treadmill gets a
/// banana (carbohydrate: the energy bar fills at once and the runner speeds
/// up), then, after 'Reset Runner', butter (fat: the bar fills slowly and a
/// 'Stored Energy' icon appears). A thin polar bear gets walnuts (fat): its
/// body fat layer fills and it becomes plumper.
///
/// Scenario 2 (The Muscle Repair Crew): a sportsperson's damaged arm muscle
/// (red cracks) gets moong dal (protein: the cracks glow blue, seal up and
/// the muscle grows), then, after 'Reset Muscle', a potato (carbohydrate:
/// the energy bar fills but the cracks stay), then paneer (protein: the
/// muscle is repaired again). 'Review Findings' opens each summary.
class Ch3A2EnergyAndBodyBuildingNutrientsPage extends StatefulWidget {
  const Ch3A2EnergyAndBodyBuildingNutrientsPage({super.key});

  @override
  State<Ch3A2EnergyAndBodyBuildingNutrientsPage> createState() =>
      _NutrientsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with Web Audio; they
/// map to the closest files: 'pop' / 'click' → pop, 'power_up' and 'heal'
/// (a food works) → correct, 'error' (missed drop) → wrong, 'success' /
/// 'chime' → success. Picking up a food plays pickup (added).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pickup → `science/pickup.mp3`, pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A food was eaten (HTML `power_up`, `heal`).
  correct('audio/class6/science/correct.mp3'),

  /// Missed drop, food of another step (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// 'Review Findings' appears (HTML `chime`) and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A food card picked up from the tray.
  pickup('audio/class6/science/pickup.mp3'),

  /// 'Reset Runner' / 'Reset Muscle' (HTML `pop`).
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

/// Colours of the HTML page (Tailwind classes), of its Three.js scene
/// (material colours) and of its SVG food icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color green500 = Color(0xFF22C55E);
  static const Color sky500 = Color(0xFF0EA5E9);
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
  /// `scene.background`: 0x0f172a (dark theme), 0xe0f2fe (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// Floor plane and food tray (`0x94a3b8`).
  static const Color floor = slate400;
  static const Color tray = slate400;
  static const Color snow = white;

  /// `Mats.machine` (treadmill) and its belt (added, a shade darker).
  static const Color machine = slate700;
  static const Color belt = slate800;
  static const Color tread = Color(0x40CBD5E1);

  /// `Mats.skin`, `Mats.clothes`, `Mats.bearFur`, hair, eyes and shoes.
  static const Color skin = Color(0xFFEEC1AD);
  static const Color clothes = blue500;
  static const Color fur = Color(0xFFF8FAFC);
  static const Color hair = Color(0xFF111111);
  static const Color mouth = Color(0xFF331111);
  static const Color shoeRunner = white;
  static const Color shoeSport = Color(0xFF333333);

  /// `Mats.crackRed` / `Mats.crackBlue`.
  static const Color crackRed = red500;
  static const Color crackBlue = sky500;

  /// Icon sprites: white card with an indigo border.
  static const Color card = white;
  static const Color cardShadow = Color(0x40000000);

  /// Text sprites: `#1e293b` chip, `#6366f1` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = indigo500;
  static const Color chipText = white;

  /// Status bar sprites: `#1e293b` box, `#cbd5e1` border; fill red, yellow
  /// or green.
  static const Color barBg = slate800;
  static const Color barBorder = slate300;
  static const Color barLow = red500;
  static const Color barMid = yellow500;
  static const Color barHigh = green500;

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x52000000);

  // ------------------------------------------------------- food icons
  static const Color banana = Color(0xFFFACC15);
  static const Color bananaEdge = Color(0xFFCA8A04);
  static const Color bananaStem = Color(0xFF713F12);
  static const Color butterFront = Color(0xFFFDE047);
  static const Color butterTop = Color(0xFFFEF9C3);
  static const Color butterSide = yellow500;
  static const Color butterEdge = Color(0xFFA16207);
  static const Color walnut = Color(0xFFB45309);
  static const Color walnutDark = Color(0xFF78350F);
  static const Color walnutLight = Color(0xFFD97706);
  static const Color bowl = slate500;
  static const Color bowlRim = slate600;
  static const Color dal = yellow500;
  static const Color dalSpeck = Color(0xFFCA8A04);
  static const Color potato = Color(0xFFFCD34D);
  static const Color potatoEdge = Color(0xFFB45309);
  static const Color paneer = Color(0xFFF8FAFC);
  static const Color paneerSide = slate200;
  static const Color paneerEdge = slate400;
  static const Color battery = green500;
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
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.blue500,
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
    curtainGlow: Color(0x663730A3), // indigo-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
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
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.blue500,
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
    curtainGlow: Color(0x663730A3),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
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
// dropped). `sN_step_M` are the step instructions (HTML step `action`,
// spelled out for touch), `sN_hud_M` the HTML "Current Task" lines,
// `sN_focus_M` / `sN_obs_M` / `sN_expl_M` the HTML concept, observation and
// explanation (shown once the step is done). Step 4 of each scenario is the
// HTML's fourth HUD line ('Review Findings'). Keys marked "added" are new
// texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Fueling the Body: Energy vs. Building Blocks',
    'app_subtitle': 'Class 6 • Mindful Eating: A Path to a Healthy Body',
    'scen_1_opt': 'Scenario 1: The Energy Challenge',
    'scen_2_opt': 'Scenario 2: The Muscle Repair Crew',
    // Reworded so the mission does not state the results in advance.
    's1_desc':
        'Feed a tired runner and a thin polar bear, and find out how carbohydrates and fats give the body energy.',
    's2_desc':
        'Feed a sportsperson whose muscles were damaged in a workout, and find out which foods repair the body and help it grow.',
    's1_step_1':
        'Drag the Banana from the food tray and drop it onto the runner.',
    's1_step_2':
        "Tap 'Reset Runner' to make the runner tired again, then drag the Butter onto the runner.",
    's1_step_3': 'Drag the Walnuts onto the thin polar bear.',
    's1_step_4': "Tap 'Review Findings' to summarise the energy-giving foods.",
    's2_step_1':
        "Drag the Moong Dal onto the sportsperson's damaged muscle (the red cracks).",
    's2_step_2':
        "Tap 'Reset Muscle' to damage the muscle again, then drag the Potato onto the sportsperson.",
    's2_step_3': 'Drag the Paneer onto the sportsperson.',
    's2_step_4': "Tap 'Review Findings' to summarise the body-building foods.",
    's1_hud_1':
        'A tired marathon runner is on the treadmill. DRAG the Banana and DROP it onto the runner.',
    's1_hud_2':
        "The runner needs energy again! TAP 'Reset Runner', then DRAG the Butter and DROP it onto the runner.",
    's1_hud_3':
        'Look at the thin polar bear. DRAG the Walnuts and DROP them onto the bear.',
    's1_hud_4':
        "TAP the 'Review Findings' button to summarise energy-giving foods.",
    's2_hud_1':
        'This sportsperson has damaged muscles (red cracks) from a workout. DRAG the Moong Dal onto them.',
    's2_hud_2':
        "TAP 'Reset Muscle' to damage the muscle again. Will carbs help? DRAG the Potato onto the sportsperson.",
    's2_hud_3':
        "Let's try a different protein. DRAG the Paneer onto the sportsperson.",
    's2_hud_4':
        "TAP the 'Review Findings' button to summarise body-building foods.",
    's1_focus_1': 'Carbohydrates = Quick Energy',
    's1_focus_2': 'Fats = Stored Energy',
    's1_focus_3': 'Fats = Insulation',
    's1_obs_1': 'Energy Bar fills instantly. Runner runs fast.',
    's1_obs_2': "Energy Bar fills slowly. 'Stored Energy' icon appears.",
    's1_obs_3': 'Body Fat Layer fills. Bear becomes plumper.',
    's1_expl_1':
        'Carbohydrates provide quick, readily available energy for immediate activities.',
    's1_expl_2':
        'Fats provide energy too, but it takes longer to release and is often stored for later use.',
    's1_expl_3':
        'Fats act as a layer of insulation to keep animals warm in cold climates and serve as stored energy reserves.',
    's2_focus_1': 'Proteins = Repair',
    's2_focus_2': 'Carbohydrates Provide Energy, Not Repair',
    's2_focus_3': 'Different Sources of Protein',
    's2_obs_1': 'Red cracks glow blue and seal up. Muscle grows.',
    's2_obs_2': 'Energy bar fills quickly, but muscle cracks remain.',
    's2_obs_3': 'Muscle cracks seal up and muscle grows again.',
    's2_expl_1':
        "Proteins are essential for repairing 'wear and tear' in the body after physical activity.",
    's2_expl_2':
        'While the potato gave energy, carbohydrates cannot repair tissue. Only proteins can do that.',
    's2_expl_3':
        'Paneer, like dal, is rich in protein and performs the same body-building and repair functions.',
    's1_summary':
        'You discovered the roles of energy-giving foods! Carbohydrates give us quick energy to stay active, while fats provide stored energy and insulation for our bodies.',
    's2_summary':
        'You repaired the muscles! Proteins are known as body-building foods because they are crucial for the growth of our bodies and for repairing damaged tissues.',
    'sum_title': 'Discovery Complete!',
    'sum_heading': 'Exploration Complete!',
    'sum_carb': 'Carbohydrate',
    'sum_fat': 'Fat',
    'sum_protein': 'Protein',
    'sum_quick': 'Quick Energy',
    'sum_stored': 'Stored Energy',
    'sum_repair': 'Body-Building & Repair',
    'sum_why': "(This is why it did not repair the muscle.)",
    // The HTML shows these two button texts in English only.
    'btn_reset_runner': 'Reset Runner',
    'btn_reset_muscle': 'Reset Muscle',
    'btn_review': 'Review Findings',
    'lbl_runner': 'Runner',
    'lbl_bear': 'Polar Bear',
    'lbl_energy': 'Energy Bar',
    'lbl_fat': 'Body Fat Layer',
    'lbl_tray': 'Food Tray',
    'lbl_person': 'Sportsperson',
    'lbl_stored': 'Stored Energy',
    'food_banana': 'Banana',
    'food_butter': 'Butter',
    'food_walnuts': 'Walnuts',
    'food_dal': 'Moong Dal',
    'food_potato': 'Potato',
    'food_paneer': 'Paneer',
    'nut_carb': '(Carb)',
    'nut_fat': '(Fat)',
    'nut_protein': '(Protein)',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Steps',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // Added.
    'pending': 'Do this step to see the result.',
    'miss_banana': 'Missed! Drop the Banana right onto the runner.',
    'miss_butter': 'Missed! Drop the Butter right onto the runner.',
    'miss_walnuts': 'Missed! Drop the Walnuts right onto the polar bear.',
    'miss_dal': 'Missed! Drop the Moong Dal right onto the sportsperson.',
    'miss_potato': 'Missed! Drop the Potato right onto the sportsperson.',
    'miss_paneer': 'Missed! Drop the Paneer right onto the sportsperson.',
    'wrong_s1_1': 'Not yet! In this step, drag the Banana onto the runner.',
    'wrong_s1_2': 'Not yet! In this step, drag the Butter onto the runner.',
    'wrong_s1_3':
        'Not yet! In this step, drag the Walnuts onto the polar bear.',
    'wrong_s2_1':
        'Not yet! In this step, drag the Moong Dal onto the sportsperson.',
    'wrong_s2_2':
        'Not yet! In this step, drag the Potato onto the sportsperson.',
    'wrong_s2_3':
        'Not yet! In this step, drag the Paneer onto the sportsperson.',
    'need_reset_runner':
        "Tap 'Reset Runner' first: the runner must be tired again before you test the Butter.",
    'need_reset_muscle':
        "Tap 'Reset Muscle' first: the muscle must be damaged again before you test the Potato.",
    'scene_s1':
        'A runner on a treadmill with an energy bar, a thin polar bear on snow with a body fat bar, and a food tray with a banana, butter and walnuts',
    'scene_s2':
        'A sportsperson with a cracked, damaged arm muscle and a food tray with moong dal, a potato and paneer',
  },
  'hi': {
    'app_title': 'शरीर को ईंधन देना: ऊर्जा बनाम निर्माण खंड',
    'app_subtitle': 'कक्षा 6 • सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_opt': 'परिदृश्य 1: ऊर्जा चुनौती',
    'scen_2_opt': 'परिदृश्य 2: मांसपेशी मरम्मत दल',
    's1_desc':
        'थके हुए धावक और पतले ध्रुवीय भालू को भोजन खिलाएँ और पता करें कि कार्बोहाइड्रेट और वसा शरीर को ऊर्जा कैसे देते हैं।',
    's2_desc':
        'कसरत से क्षतिग्रस्त मांसपेशियों वाले खिलाड़ी को भोजन खिलाएँ और पता करें कि कौन-से खाद्य पदार्थ शरीर की मरम्मत करते हैं और उसकी वृद्धि में मदद करते हैं।',
    's1_step_1': 'भोजन ट्रे से केले को खींचें और धावक पर छोड़ दें।',
    's1_step_2':
        "धावक को फिर से थका हुआ बनाने के लिए 'धावक रीसेट करें' पर टैप करें, फिर मक्खन को खींचकर धावक पर छोड़ें।",
    's1_step_3': 'अखरोट को खींचकर पतले ध्रुवीय भालू पर छोड़ें।',
    's1_step_4':
        "ऊर्जा देने वाले खाद्य पदार्थों का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    's2_step_1':
        'मूंग दाल को खींचकर खिलाड़ी की क्षतिग्रस्त मांसपेशी (लाल दरारें) पर छोड़ें।',
    's2_step_2':
        "मांसपेशी को फिर से क्षतिग्रस्त करने के लिए 'मांसपेशी रीसेट करें' पर टैप करें, फिर आलू को खींचकर खिलाड़ी पर छोड़ें।",
    's2_step_3': 'पनीर को खींचकर खिलाड़ी पर छोड़ें।',
    's2_step_4':
        "शरीर-वर्धक खाद्य पदार्थों का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    's1_hud_1':
        'एक थका हुआ मैराथन धावक ट्रेडमिल पर है। केला खींचें और उसे धावक पर छोड़ दें।',
    's1_hud_2':
        "धावक को फिर से ऊर्जा चाहिए! 'धावक रीसेट करें' पर टैप करें, फिर मक्खन खींचें और उसे धावक पर छोड़ दें।",
    's1_hud_3':
        'पतले ध्रुवीय भालू को देखें। अखरोट खींचें और उन्हें भालू पर छोड़ दें।',
    's1_hud_4':
        "ऊर्जा देने वाले खाद्य पदार्थों का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        'कसरत से इस खिलाड़ी की मांसपेशियाँ क्षतिग्रस्त हो गई हैं (लाल दरारें)। मूंग दाल को उन पर खींचें।',
    's2_hud_2':
        "मांसपेशी को फिर से क्षतिग्रस्त करने के लिए 'मांसपेशी रीसेट करें' पर टैप करें। क्या कार्ब्स मदद करेंगे? आलू को खिलाड़ी पर खींचें।",
    's2_hud_3': 'आइए एक अलग प्रोटीन आज़माएँ। पनीर को खिलाड़ी पर खींचें।',
    's2_hud_4':
        "शरीर-वर्धक खाद्य पदार्थों का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's1_focus_1': 'कार्बोहाइड्रेट = त्वरित ऊर्जा',
    's1_focus_2': 'वसा = संग्रहीत ऊर्जा',
    's1_focus_3': 'वसा = इन्सुलेशन (गर्मी रोकने वाली परत)',
    's1_obs_1': 'ऊर्जा बार तुरंत भर जाता है। धावक तेज़ दौड़ता है।',
    's1_obs_2':
        "ऊर्जा बार धीरे-धीरे भरता है। 'संग्रहीत ऊर्जा' आइकन दिखाई देता है।",
    's1_obs_3': 'शरीर की वसा परत भर जाती है। भालू मोटा हो जाता है।',
    's1_expl_1':
        'कार्बोहाइड्रेट तत्काल गतिविधियों के लिए त्वरित, आसानी से उपलब्ध ऊर्जा प्रदान करते हैं।',
    's1_expl_2':
        'वसा भी ऊर्जा देती है, लेकिन इससे ऊर्जा मिलने में अधिक समय लगता है और यह अक्सर बाद में उपयोग के लिए संग्रहीत रहती है।',
    's1_expl_3':
        'वसा ठंडी जलवायु में जानवरों को गर्म रखने के लिए इन्सुलेशन की परत का काम करती है और ऊर्जा भंडार के रूप में भी काम आती है।',
    's2_focus_1': 'प्रोटीन = मरम्मत',
    's2_focus_2': 'कार्बोहाइड्रेट ऊर्जा देते हैं, मरम्मत नहीं करते',
    's2_focus_3': 'प्रोटीन के विभिन्न स्रोत',
    's2_obs_1': 'लाल दरारें नीली चमकती हैं और भर जाती हैं। मांसपेशी बढ़ती है।',
    's2_obs_2':
        'ऊर्जा बार जल्दी भर जाता है, लेकिन मांसपेशी की दरारें बनी रहती हैं।',
    's2_obs_3': 'मांसपेशी की दरारें भर जाती हैं और मांसपेशी फिर से बढ़ती है।',
    's2_expl_1':
        "शारीरिक गतिविधि के बाद शरीर में होने वाली 'टूट-फूट' की मरम्मत के लिए प्रोटीन आवश्यक हैं।",
    's2_expl_2':
        'हालाँकि आलू ने ऊर्जा दी, कार्बोहाइड्रेट ऊतकों की मरम्मत नहीं कर सकते। यह काम केवल प्रोटीन कर सकते हैं।',
    's2_expl_3':
        'दाल की तरह पनीर भी प्रोटीन से भरपूर होता है और शरीर-वर्धन तथा मरम्मत का वही काम करता है।',
    's1_summary':
        'आपने ऊर्जा देने वाले खाद्य पदार्थों की भूमिकाओं की खोज की! कार्बोहाइड्रेट हमें सक्रिय रहने के लिए त्वरित ऊर्जा देते हैं, जबकि वसा हमारे शरीर को संग्रहीत ऊर्जा और इन्सुलेशन प्रदान करती है।',
    's2_summary':
        'आपने मांसपेशियों की मरम्मत की! प्रोटीन को शरीर-वर्धक खाद्य पदार्थ कहा जाता है, क्योंकि वे हमारे शरीर की वृद्धि और क्षतिग्रस्त ऊतकों की मरम्मत के लिए बहुत ज़रूरी हैं।',
    'sum_title': 'खोज पूर्ण!',
    'sum_heading': 'अन्वेषण पूर्ण!',
    'sum_carb': 'कार्बोहाइड्रेट',
    'sum_fat': 'वसा',
    'sum_protein': 'प्रोटीन',
    'sum_quick': 'त्वरित ऊर्जा',
    'sum_stored': 'संग्रहीत ऊर्जा',
    'sum_repair': 'शरीर-वर्धन और मरम्मत',
    'sum_why': '(इसीलिए इससे मांसपेशी की मरम्मत नहीं हुई।)',
    'btn_reset_runner': 'धावक रीसेट करें',
    'btn_reset_muscle': 'मांसपेशी रीसेट करें',
    'btn_review': 'निष्कर्ष की समीक्षा करें',
    'lbl_runner': 'धावक',
    'lbl_bear': 'ध्रुवीय भालू',
    'lbl_energy': 'ऊर्जा बार',
    'lbl_fat': 'शरीर की वसा परत',
    'lbl_tray': 'भोजन ट्रे',
    'lbl_person': 'खिलाड़ी',
    'lbl_stored': 'संग्रहीत ऊर्जा',
    'food_banana': 'केला',
    'food_butter': 'मक्खन',
    'food_walnuts': 'अखरोट',
    'food_dal': 'मूंग दाल',
    'food_potato': 'आलू',
    'food_paneer': 'पनीर',
    'nut_carb': '(कार्ब)',
    'nut_fat': '(वसा)',
    'nut_protein': '(प्रोटीन)',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'miss_banana': 'निशाना चूक गया! केले को सीधे धावक पर छोड़ें।',
    'miss_butter': 'निशाना चूक गया! मक्खन को सीधे धावक पर छोड़ें।',
    'miss_walnuts': 'निशाना चूक गया! अखरोट को सीधे ध्रुवीय भालू पर छोड़ें।',
    'miss_dal': 'निशाना चूक गया! मूंग दाल को सीधे खिलाड़ी पर छोड़ें।',
    'miss_potato': 'निशाना चूक गया! आलू को सीधे खिलाड़ी पर छोड़ें।',
    'miss_paneer': 'निशाना चूक गया! पनीर को सीधे खिलाड़ी पर छोड़ें।',
    'wrong_s1_1': 'अभी नहीं! इस चरण में केले को धावक पर खींचें।',
    'wrong_s1_2': 'अभी नहीं! इस चरण में मक्खन को धावक पर खींचें।',
    'wrong_s1_3': 'अभी नहीं! इस चरण में अखरोट को ध्रुवीय भालू पर खींचें।',
    'wrong_s2_1': 'अभी नहीं! इस चरण में मूंग दाल को खिलाड़ी पर खींचें।',
    'wrong_s2_2': 'अभी नहीं! इस चरण में आलू को खिलाड़ी पर खींचें।',
    'wrong_s2_3': 'अभी नहीं! इस चरण में पनीर को खिलाड़ी पर खींचें।',
    'need_reset_runner':
        "पहले 'धावक रीसेट करें' पर टैप करें: मक्खन जाँचने से पहले धावक का फिर से थका होना ज़रूरी है।",
    'need_reset_muscle':
        "पहले 'मांसपेशी रीसेट करें' पर टैप करें: आलू जाँचने से पहले मांसपेशी का फिर से क्षतिग्रस्त होना ज़रूरी है।",
    'scene_s1':
        'ऊर्जा बार के साथ ट्रेडमिल पर एक धावक, शरीर की वसा बार के साथ बर्फ़ पर एक पतला ध्रुवीय भालू, और केला, मक्खन व अखरोट वाली भोजन ट्रे',
    'scene_s2':
        'दरारों वाली क्षतिग्रस्त बाँह की मांसपेशी वाला एक खिलाड़ी, और मूंग दाल, आलू व पनीर वाली भोजन ट्रे',
  },
};

/// Number of steps of each scenario: the HTML's three feeding steps plus
/// its fourth HUD task ('Review Findings').
const List<int> _stepCounts = [4, 4];

/// Feeding steps of each scenario (the HTML `steps` arrays).
const int _feedSteps = 3;

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.result,
    required this.explanation,
  });

  final String focus;
  final String action;
  final String result;
  final String explanation;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCounts[index]; i++)
      _StepInfo(
        focus: i <= _feedSteps ? t('s${n}_focus_$i') : '',
        action: t('s${n}_step_$i'),
        result: i <= _feedSteps ? t('s${n}_obs_$i') : '',
        explanation: i <= _feedSteps ? t('s${n}_expl_$i') : '',
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The step
/// concept stays empty: the HTML concepts ("Carbohydrates = Quick Energy")
/// are the results, shown in the accordion once each step is done.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(concept: '', action: s.action, observation: s.result),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML camera: `PerspectiveCamera(45, …)`, `camera.position.set(0, 10,
/// 16)` looking at `controls.target.set(0, 1, 0)` (`resetCamera`).
const double _fovDegrees = 45;
const _V _eye = _V(0, 10, 16);
const _V _lookAt = _V(0, 1, 0);
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a food card (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Second line of a two-line chip ("(Carb)") relative to the first.
const double _subScale = 0.82;

/// Chip padding as a share of the label size.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

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

/// Largest zoom of the fitted scene in each scenario (the HTML camera is
/// zoom 1); it is never drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.2, 1.3];
const double _minZoom = 0.3;

// ------------------------------------------------------- shared: food tray

/// Food tray `BoxGeometry(8, 0.2, 3)` at (0, 0.1, 4).
const _V _trayCenter = _V(0, 0.1, 4);
const _V _traySize = _V(8, 0.2, 3);

/// Food icon sprites (`scale 1.5`) at y = 0.8 on the tray, at x = -2.5, 0
/// and 2.5 in the HTML; 2.8 apart here so their name chips never touch.
const double _foodY = 0.8;
const double _foodZ = 4;
const double _foodSpacing = 2.8;
const double _cardSize = 1.5;

/// HTML drag: the ray meets `dragPlane` (y = 0.8); a held food is lifted
/// by 0.5 on pointer-down and kept at y = 1.5 while it moves.
const double _dragPlaneY = 0.8;
const double _liftY = _foodY + 0.5;
const double _heldY = 1.5;

/// HTML drop test: `obj.position.distanceTo(target.position) < 3`.
const double _dropRange = 3;

/// HTML tweens: an eaten food shrinks (300 ms); a missed one glides back to
/// its place (300 ms).
const double _shrinkSeconds = 0.3;
const double _returnSeconds = 0.3;

/// HTML `setTimeout(…, 1000)` between the end of an effect and the next
/// step.
const double _settleSeconds = 1;

/// Starting fills of the bars (`createStatusBarSprite(…, 0.1 / 0.2)`).
const double _energyStart = 0.1;
const double _fatStart = 0.2;

/// HTML `animateBarFill` colours: red up to 0.4, yellow up to 0.8, then
/// green.
const double _barYellowFrom = 0.4;
const double _barGreenFrom = 0.8;

/// Status bar sprite (`createStatusBarSprite`: 256 x 128 canvas drawn on a
/// 4 x 2 sprite, so 64 canvas px per world unit): box `roundRect(10, 40,
/// 236, 60, 10)`, border 4, fill `roundRect(14, 44, 228 x fill, 52, 6)`.
const double _barOuterW = 236 / 64;
const double _barOuterH = 60 / 64;
const double _barDrop = 6 / 64; // box centre below the sprite centre
const double _barRadius = 10 / 64;
const double _barBorder = 4 / 64;
const double _barInset = 4 / 64;
const double _barFillRadius = 6 / 64;

/// The caption chip sits just above the bar box.
const double _barCaptionLift = _barOuterH / 2 - _barDrop + 0.08;

// ------------------------------------------------ scenario 1: energy gym

/// Treadmill: base `BoxGeometry(4, 0.4, 2)` at (-5, 0.2, 0) and console
/// `BoxGeometry(0.2, 1.5, 2)` at (-6.9, 1, 0).
const _V _treadBase = _V(-5, 0.2, 0);
const _V _treadSize = _V(4, 0.4, 2);
const _V _console = _V(-6.9, 1, 0);
const _V _consoleSize = _V(0.2, 1.5, 2);
const double _treadTop = 0.4;

/// Tread lines on the belt (added): spacing and speed (units per half bob).
const double _treadGap = 0.45;
const double _treadRate = 0.35;

/// Runner group at (-5, 0.4, 0), `rotation.y = -π/2` (faces -x, towards
/// the console); its y bobs with the running tween.
const _V _runnerPos = _V(-5, _treadTop, 0);

/// Runner figure (built from the HTML meshes, posed for running): hip
/// height, leg segments, spine length and forward lean (`rotation.x 0.1`).
const double _runnerHipY = 0.88;
const double _thighLen = 0.42;
const double _calfLen = 0.42;
const double _runnerSpine = 0.86;
const double _runnerLean = 0.12;
const double _armSwing = 0.9;
const double _elbowBend = 1.3;
const double _kneeBend = 0.3;
const double _kickBend = 0.9;

/// Amplitude changes ease in at this rate (1/s) instead of jumping.
const double _paceEase = 8;

/// Status bars above the runner and the bear (`position.set(±5, 4.5, 0)`).
const _V _energyBarS1 = _V(-5, 4.5, 0);
const _V _fatBar = _V(5, 4.5, 0);

/// Battery 'Stored Energy' icon: `createIconSprite('battery')` at scale
/// 0.8. The HTML puts it at (-3, 4.5, 0), over the bar's right end; here it
/// sits just right of the bar.
const _V _storedIcon = _V(-2.25, 4.5, 0);
const double _storedScale = 0.8;
const double _popSeconds = 0.5; // TWEEN.Easing.Elastic.Out, 500 ms

/// Snow `PlaneGeometry(8, 8)` at (5, 0.01, 0) and the polar bear at (5, 0,
/// 0), facing +x.
const _V _snowCenter = _V(5, 0.01, 0);
const double _snowHalf = 4;
const _V _bearPos = _V(5, 0, 0);

/// `buildPolarBear()`: body `SphereGeometry(1)` scaled (1.3, 0.9, 0.9) at
/// y 1.1; head group at (1.2, 1.3, 0) with a (0.54, 0.405, 0.45) head;
/// tail r 0.2 at (-1.2, 1.2, 0); legs r 0.25–0.3 at (±0.8, 0.4, ±0.4);
/// paws (0.38, 0.19) at x 0.9 / -0.7.
const double _bearBodyY = 1.1;
const _V _bearBodyR = _V(1.3, 0.9, 0.9);
const double _bearHeadX = 1.2;
const double _bearHeadY = 1.3;
const _V _bearHeadR = _V(0.54, 0.405, 0.45);
const double _bearTailX = 1.2;
const double _bearTailY = 1.2;
const double _bearLegZ = 0.4;

/// HTML: `bodyMesh.scale` x, z → 1.4 over 1000 ms. The head and tail move
/// out with the body so the plumper body does not swallow the head.
const double _plumpScale = 1.4;
const double _plumpSeconds = 1;

/// HTML fill tweens: banana 500 ms, butter 3000 ms, walnuts 2000 ms.
const double _bananaFill = 0.5;
const double _butterFill = 3;
const double _walnutFill = 2;

// --------------------------------------------- scenario 2: muscle repair

/// Sportsperson group at (0, 0, -2), `scale.setScalar(1.3)`, facing the
/// camera.
const _V _personPos = _V(0, 0, -2);
const double _personScale = 1.3;

/// Energy bar (shown after the potato). The HTML puts it at (0, 4.5, -2),
/// over the sportsperson's head; here it clears the head.
const _V _energyBarS2 = _V(0, 5, -2);
const double _potatoFill = 1;

/// Cracks: red → blue over 1000 ms, then opacity 0.8 → 0 over 500 ms while
/// the bicep pulses 1 → 1.2 → 1 (500 ms yoyo) and stays 1.1.
const double _glowSeconds = 1;
const double _fadeSeconds = 0.5;
const double _pulseSeconds = 1;
const double _crackOpacity = 0.8;
const double _musclePulse = 1.2;
const double _muscleGrown = 1.1;

/// The crack sprite's zig-zag (`moveTo(10, 32)`, `lineTo(20, 20)`, (30,
/// 40), (45, 25), (55, 35) on a 64 px canvas drawn 0.8 units wide), in
/// the sportsperson's units along and across the bicep (screen y down).
const List<(double, double)> _crackPts = [
  (-0.275, 0),
  (-0.15, -0.15),
  (-0.025, 0.1),
  (0.1625, -0.0875),
  (0.2875, 0.0375),
];

// ------------------------------------------------------------- labels

/// Where each scene label is anchored (world point) and how its chip sits
/// on that point (x, y alignment: -1 left / top edge, 0 centre, 1 right /
/// bottom edge).
const _V _runnerLabelAt = _V(-5, 0, 1.05);
const _V _bearLabelAt = _V(5, 2.2, 0);
const _V _personLabelAt = _V(0, 0, -1.45);
const _V _trayLabelAt = _V(-4.15, 0.1, 5.3);
const (double, double) _below = (0, -1);
const (double, double) _above = (0, 1);
const (double, double) _leftOf = (1, 0);
const (double, double) _rightOf = (-1, 0);

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
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Where the camera's look-at point lands on the stage and how much the
/// scene is enlarged (the HTML camera is [base]). The scene is fitted into
/// the part of the canvas no card covers.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom);

  final Offset center;
  final double zoom;

  static const _Framing base = _Framing(_designCenter, 1);

  _Framing lerpTo(_Framing o, double t) =>
      _Framing(Offset.lerp(center, o.center, t)!, zoom + (o.zoom - zoom) * t);

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_Framing framing) {
    final f = (_lookAt - _eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(f, r, r.cross(f), framing.center, _focal * framing.zoom);
  }

  const _Cam._(this.f, this.r, this.u, this.center, this.scale);

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  _V get eye => _eye;

  double depth(_V w) => (w - _eye).dot(f);

  /// The design point of [w] (everything in the scenes is in front of the
  /// camera).
  Offset p(_V w) {
    final d = w - _eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (HTML `getIntersects(e, [dragPlane])`).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - _eye.y) / d.y;
    if (t <= 0) return null;
    return _eye + d * t;
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

/// Who eats a food.
enum _Target { runner, bear, person }

/// Pictures drawn on the icon sprites (HTML `SVGs`).
enum _Art { banana, butter, walnuts, dal, potato, paneer, battery }

/// The six foods of the two trays, in step order (HTML `createIconSprite`
/// calls and `labelDict`).
enum _Food {
  banana('food_banana', 'nut_carb', _Art.banana, _Target.runner, -1),
  butter('food_butter', 'nut_fat', _Art.butter, _Target.runner, 0),
  walnuts('food_walnuts', 'nut_fat', _Art.walnuts, _Target.bear, 1),
  dal('food_dal', 'nut_protein', _Art.dal, _Target.person, -1),
  potato('food_potato', 'nut_carb', _Art.potato, _Target.person, 0),
  paneer('food_paneer', 'nut_protein', _Art.paneer, _Target.person, 1);

  const _Food(this.nameKey, this.nutrientKey, this.art, this.target, this.slot);

  final String nameKey;
  final String nutrientKey;
  final _Art art;
  final _Target target;

  /// Place on the tray: -1 left, 0 middle, 1 right.
  final int slot;

  _V get home => _V(slot * _foodSpacing, _foodY, _foodZ);

  /// Scenario (0 or 1) whose step [step] (1–3) feeds this food.
  int get scenario => index ~/ _feedSteps;
  int get step => index % _feedSteps + 1;

  static List<_Food> of(int scenario) =>
      values.sublist(scenario * _feedSteps, (scenario + 1) * _feedSteps);
}

/// The runner's tween (HTML `runTween`): bob height above the belt, half
/// period in seconds (yoyo duration) and the leg / arm swing (rad, added so
/// the runner visibly runs). The HTML tweens `runner.position.y` (0.4, the
/// belt top) yoyo to an absolute y, so the heights are the swings they
/// make: tired 0.4 → 0.2 (the HTML runner sinks into the belt; here it
/// rises), fast ≈ 0.3 → 0.8, steady ≈ 0.3 → 0.6.
enum _Pace {
  /// Tired (start, after 'Reset Runner'): `to({y: 0.2}, 400)`.
  tired(0.2, 0.4, 0.45),

  /// After the banana: `to({y: 0.8}, 150)`, runs fast.
  fast(0.5, 0.15, 0.75),

  /// After the butter: `to({y: 0.6}, 600)`, slow and steady.
  steady(0.3, 0.6, 0.6);

  const _Pace(this.bob, this.half, this.swing);

  final double bob;
  final double half;
  final double swing;
}

/// A bar fill animated linearly (HTML `animateBarFill` tween).
class _Fill {
  _Fill(double value) : from = value, to = value;

  double from;
  double to;
  double start = 0;
  double seconds = 0;

  double at(double time) => seconds <= 0
      ? to
      : from + (to - from) * ((time - start) / seconds).clamp(0.0, 1.0);

  void set(double value) {
    from = value;
    to = value;
    seconds = 0;
  }

  void animate(double time, double target, double duration) {
    from = at(time);
    to = target;
    start = time;
    seconds = duration;
  }
}

/// One food card on the tray.
class _FoodState {
  _FoodState(this.food) : pos = food.home;

  final _Food food;

  /// Where it is while held, or where it was eaten.
  _V pos;

  /// Scene time it was eaten (shrinking away), or -1.
  double eatenAt = -1;

  /// Gliding back to the tray after a missed drop (start time, or -1).
  double returnStart = -1;
  _V returnFrom = _V.zero;

  bool get eaten => eatenAt >= 0;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// The current scenario's three food cards.
  final List<_FoodState> foods = [];

  /// The card the learner is holding (HTML `State.draggingObject`).
  _FoodState? held;

  /// Pending events of the running feeding sequence, in scene time (the
  /// HTML tween `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  // ------------------------------------------------------------ scenario 1
  _Pace pace = _Pace.tired;
  double runPhase = 0;
  double bobAmp = _Pace.tired.bob;
  double swingAmp = _Pace.tired.swing;
  double tread = 0;

  /// The energy bar (runner in S1, sportsperson in S2) and the bear's body
  /// fat bar.
  final _Fill energy = _Fill(_energyStart);
  final _Fill fat = _Fill(_fatStart);

  /// Scene time the 'Stored Energy' icon popped in, or -1.
  double storedAt = -1;

  /// Scene time the bear started to grow plumper, or -1.
  double plumpStart = -1;

  // ------------------------------------------------------------ scenario 2
  /// `Objects.s2.energyBar.visible`.
  bool energyShown = false;

  /// The red cracks are on the bicep.
  bool cracks = true;

  /// Scene time the cracks started to heal (glow blue, fade), or -1.
  double healStart = -1;

  /// Scene time the bicep started to pulse, or -1.
  double pulseStart = -1;

  /// Bicep scale at rest (1, or 1.1 once repaired).
  double muscleBase = 1;

  // -------------------------------------------------------------- progress
  /// Feeding steps finished (HTML `progressStep` calls).
  int fed = 0;

  /// A feeding sequence is running (HTML `isAnimating`).
  bool busy = false;

  /// 'Reset Runner' / 'Reset Muscle' was tapped in this step.
  bool resetDone = false;

  /// 'Review Findings' was tapped.
  bool reviewed = false;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  bool get framingSettled => _framingT >= 1;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    foods
      ..clear()
      ..addAll([for (final f in _Food.of(index)) _FoodState(f)]);
    held = null;
    _cues.clear();
    pace = _Pace.tired;
    runPhase = 0;
    bobAmp = pace.bob;
    swingAmp = pace.swing;
    tread = 0;
    energy.set(_energyStart);
    fat.set(_fatStart);
    storedAt = -1;
    plumpStart = -1;
    energyShown = false;
    cracks = true;
    healStart = -1;
    pulseStart = -1;
    muscleBase = 1;
    fed = 0;
    busy = false;
    resetDone = false;
    reviewed = false;
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

  /// HTML `animate()`: the running tween, the tread, cards gliding back and
  /// the framing.
  void advance(double dt) {
    final ease = math.min(1.0, dt * _paceEase);
    bobAmp += (pace.bob - bobAmp) * ease;
    swingAmp += (pace.swing - swingAmp) * ease;
    runPhase = (runPhase + dt * math.pi / pace.half) % (4 * math.pi);
    tread = (tread + dt * _treadRate / pace.half) % _treadGap;
    for (final f in foods) {
      if (f.returnStart >= 0 && time - f.returnStart >= _returnSeconds) {
        f.returnStart = -1;
      }
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
    }
  }

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(framing);

  // ------------------------------------------------------------- figures

  /// Height of the runner's bob (HTML `runner.position.y`).
  double get bob => bobAmp * (0.5 - 0.5 * math.cos(runPhase));

  /// Leg swing: the left leg is forward when positive.
  double get swing => swingAmp * math.sin(runPhase / 2);

  /// The bear's body scale along x and z (1 … 1.4).
  double get plump => plumpStart < 0
      ? 1
      : 1 +
            (_plumpScale - 1) *
                ((time - plumpStart) / _plumpSeconds).clamp(0.0, 1.0);

  /// The bicep's scale (HTML `bicep.scale`).
  double get muscle {
    if (pulseStart < 0) return muscleBase;
    final e = ((time - pulseStart) / _pulseSeconds).clamp(0.0, 1.0);
    final tri = e < 0.5 ? e / 0.5 : (1 - e) / 0.5;
    return muscleBase + (_musclePulse - muscleBase) * tri;
  }

  /// Opacity of the cracks (0.8, fading to 0 once healed).
  double get crackAlpha {
    if (!cracks) return 0;
    if (healStart < 0) return _crackOpacity;
    final e = time - healStart - _glowSeconds;
    if (e <= 0) return _crackOpacity;
    return _crackOpacity * (1 - (e / _fadeSeconds).clamp(0.0, 1.0));
  }

  /// Colour of the cracks (red, glowing to blue while healing).
  Color get crackColor {
    if (healStart < 0) return _Colors.crackRed;
    final t = ((time - healStart) / _glowSeconds).clamp(0.0, 1.0);
    return Color.lerp(_Colors.crackRed, _Colors.crackBlue, t)!;
  }

  /// Scale of the battery icon popping in (elastic, 0 … 1).
  double get storedPop {
    if (storedAt < 0) return 0;
    final t = ((time - storedAt) / _popSeconds).clamp(0.0, 1.0);
    return Curves.elasticOut.transform(t);
  }

  // --------------------------------------------------------------- foods

  /// Where [f] is drawn now.
  _V foodPos(_FoodState f) {
    if (identical(f, held) || f.eaten) return f.pos;
    if (f.returnStart >= 0) {
      final t = ((time - f.returnStart) / _returnSeconds).clamp(0.0, 1.0);
      return _V.lerp(f.returnFrom, f.food.home, t);
    }
    return f.food.home;
  }

  /// Size of [f]'s card (1, shrinking to 0 once eaten).
  double foodScale(_FoodState f) =>
      f.eaten ? 1 - ((time - f.eatenAt) / _shrinkSeconds).clamp(0.0, 1.0) : 1;

  /// The food card at [p] (HTML raycast on the icon sprites): the card
  /// itself or, on a small screen, within a finger's reach of its centre.
  _FoodState? foodAt(Offset p, double touch) {
    final cam = camera();
    _FoodState? best;
    var bestD = double.infinity;
    for (final f in foods) {
      if (f.eaten) continue;
      final pos = foodPos(f);
      final c = cam.p(pos);
      final half = _cardSize / 2 * cam.scaleAt(pos);
      final d = p - c;
      final inside = d.dx.abs() <= half && d.dy.abs() <= half;
      final dist = d.distance;
      if ((inside || dist <= touch) && dist < bestD) {
        best = f;
        bestD = dist;
      }
    }
    return best;
  }

  // ------------------------------------------------------------- targets

  /// The target's `position` for the HTML distance test.
  _V targetPos(_Target t) => switch (t) {
    _Target.runner => _runnerPos + _V(0, bob, 0),
    _Target.bear => _bearPos,
    _Target.person => _personPos,
  };

  /// World box around a target's body as drawn now.
  (_V, _V) targetBox(_Target t) {
    switch (t) {
      case _Target.runner:
        return (
          const _V(-5.65, _treadTop, -0.6),
          _V(-4.3, _treadTop + 3.05 + bob, 0.6),
        );
      case _Target.bear:
        final g = plump - 1;
        return (
          _V(3.55 - _bearBodyR.x * g, 0, -1 - 0.4 * g),
          _V(6.9 + _bearBodyR.x * g, 2.05, 1 + 0.4 * g),
        );
      case _Target.person:
        return (const _V(-0.95, 0, -2.5), const _V(1.55, 4.25, -1.5));
    }
  }

  /// Does a food released at [card] (finger at [pointer]) land on [t]? The
  /// HTML only tests `distanceTo(target.position) < 3` from the lifted
  /// card, which misses a drop on the sportsperson's chest or the runner's
  /// head; a release over the target's body as drawn counts as well.
  bool lands(_Target t, _V card, Offset pointer, double margin) {
    final cam = camera();
    final (min, max) = targetBox(t);
    final body = cam.boxRect(min, max).inflate(margin);
    if (body.contains(cam.p(card)) || body.contains(pointer)) return true;
    return (card - targetPos(t)).length < _dropRange;
  }

  // ------------------------------------------ plain readouts for the tests

  /// Design point of a named place in the current framing (used by the
  /// instruction-flow tests): a food ('banana', …), 'runner', 'bear',
  /// 'person' (where a learner drops food on them) or 'floor' (empty floor).
  Offset anchor(String id) {
    final cam = camera();
    for (final f in foods) {
      if (f.food.name == id) return cam.p(foodPos(f));
    }
    return switch (id) {
      'runner' => cam.p(_runnerPos + _V(0, 1.45 + bob, 0)),
      'bear' => cam.p(_bearPos + const _V(0, _bearBodyY, 0)),
      'person' => cam.p(_personPos + const _V(0, 2.6, 0)),
      'floor' => cam.p(
        scenario == 0 ? const _V(0, 0, 0.5) : const _V(-4.5, 0, 0),
      ),
      _ => _designCenter,
    };
  }

  List<String> get eatenNames => [
    for (final f in foods)
      if (f.eaten) f.food.name,
  ];
  double get energyFill => energy.at(time);
  double get fatFill => fat.at(time);
  String get paceName => pace.name;
  bool get storedShown => storedAt >= 0;
  double get bearPlump => plump;
  bool get cracksVisible => crackAlpha > 0.01;
  double get muscleScale => muscle;
  bool get energyVisible => scenario == 0 || energyShown;
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
  return _Framing(rect.center - extent(zoom).center, zoom);
}

/// Top-left of a chip of [size] relative to its anchor (see [_below] …).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// Anchor of a food's name chip: just under its card.
_V _foodLabelAt(_V cardPos, double cardScale) =>
    cardPos - _V(0, _cardSize / 2 * cardScale + 0.05, 0);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a food card ([canGrab]), so other drags still pan / zoom the canvas
/// when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _NutrientsLabState extends State<Ch3A2EnergyAndBodyBuildingNutrientsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch3-a2-canvas');

  /// 1-based current step, derived from the scene ([_deriveStep]);
  /// steps.length + 1 once the scenario is done.
  int _step = 1;

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// The card the current pointer holds, the scenario it was picked up in,
  /// the drag-plane offset of the grab and the last pointer position.
  _FoodState? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  Offset _lastPointer = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

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

  /// HTML `animate()` + `TWEEN.update()`; then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
    s.runCues();
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

  /// Fits the scenario's figures, bars, tray and labels into the part of
  /// the canvas no card covers: the tool column, the HUD (sidebar open) and
  /// the floating mission card (sidebar collapsed). Never while a card is
  /// held, so the scene does not move under the finger.
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
    if (open) _cardRect = null;
    if (!open && _lab.isLabActive) {
      // The floating mission card as it is laid out; before that, the room
      // the shell gives it.
      final card = _missionCardBox();
      if (card != null) {
        final now = (card.localToGlobal(Offset.zero) - origin) & card.size;
        final kept = _cardRect;
        _cardRect = kept == null
            ? now
            : Rect.fromLTWH(
                now.left,
                now.top,
                math.max(now.width, kept.width),
                math.max(now.height, kept.height),
              );
        hard.add(_cardRect!);
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
      _maxZoom[_scene.scenario],
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

  /// What the learner must see: the figures, bars, tray and cards (HTML
  /// camera, zoom 1) and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
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

    void chip(_V at, (double, double) align, String text, {String? sub}) {
      final size = _cache.chipSize(text, sub: sub);
      items.add((cam.p(at), _chipOffset(size, align) & size));
    }

    void bar(_V at, String caption) {
      box(
        at - const _V(_barOuterW / 2, _barOuterH / 2 + _barDrop, 0),
        at + const _V(_barOuterW / 2, _barOuterH / 2 - _barDrop, 0),
      );
      chip(at + const _V(0, _barCaptionLift, 0), _above, caption);
    }

    if (_scene.scenario == 0) {
      // Treadmill and the runner at the top of its highest bob.
      box(const _V(-7, 0, -1), _V(-3, _treadTop + 3.05 + _Pace.fast.bob, 1));
      // The bear at its plumpest.
      final g = _plumpScale - 1;
      box(
        _V(3.55 - _bearBodyR.x * g, 0, -1.4),
        _V(6.9 + _bearBodyR.x * g, 2.05, 1.4),
      );
      chip(_runnerLabelAt, _below, _t('lbl_runner'));
      chip(_bearLabelAt, _above, _t('lbl_bear'));
      bar(_energyBarS1, _t('lbl_energy'));
      bar(_fatBar, _t('lbl_fat'));
      const half = _cardSize * _storedScale / 2;
      box(
        _storedIcon - const _V(half, half, 0),
        _storedIcon + const _V(half, half, 0),
      );
      chip(
        _storedIcon + const _V(half + 0.1, 0, 0),
        _rightOf,
        _t('lbl_stored'),
      );
    } else {
      box(const _V(-0.95, 0, -2.5), const _V(1.55, 4.25, -1.5));
      chip(_personLabelAt, _below, _t('lbl_person'));
      bar(_energyBarS2, _t('lbl_energy'));
    }
    box(_trayCenter - _traySize * 0.5, _trayCenter + _traySize * 0.5);
    chip(_trayLabelAt, _leftOf, _t('lbl_tray'));
    for (final f in _Food.of(_scene.scenario)) {
      const half = _cardSize / 2;
      box(f.home - const _V(half, half, 0), f.home + const _V(half, half, 0));
      chip(
        _foodLabelAt(f.home, 1),
        _below,
        _t(f.nameKey),
        sub: _t(f.nutrientKey),
      );
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens and rebuilds the scenario's scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _step = 1;
      _grab = null;
      _grabScenario = -1;
      _cardRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// The HTML step ladder: steps 1–3 end when each food's effect has played
  /// out (`progressStep`), step 4 when 'Review Findings' is tapped.
  int _deriveStep() {
    final s = _scene;
    if (s.fed < _feedSteps) return s.fed + 1;
    return s.reviewed ? _feedSteps + 2 : _feedSteps + 1;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
  }

  /// The food the current step asks for, if any.
  _Food? get _wantedFood =>
      _step <= _feedSteps ? _Food.of(_scene.scenario)[_step - 1] : null;

  /// HTML `handleUp` success branches: the food is eaten and its effect
  /// plays out; [_finishStep] moves on (HTML `progressStep`).
  void _feed(_FoodState f) {
    final s = _scene;
    final t = s.time;
    f.eatenAt = t;
    s.busy = true;
    switch (f.food) {
      case _Food.banana:
        // Instant fill (500 ms), then the runner runs fast.
        _Sound.correct.play();
        s.energy.animate(t, 1, _bananaFill);
        s.cue(t + _bananaFill, () => s.pace = _Pace.fast);
        s.cue(t + _bananaFill + _settleSeconds, _finishStep);
      case _Food.butter:
        // Slow fill (3 s), then a slow steady pace and the battery icon.
        _Sound.correct.play();
        s.energy.animate(t, 1, _butterFill);
        s.cue(t + _butterFill, () {
          s
            ..pace = _Pace.steady
            ..storedAt = s.time;
        });
        s.cue(t + _butterFill + _settleSeconds, _finishStep);
      case _Food.walnuts:
        // Body fat fills (2 s), then the bear grows plumper (1 s).
        _Sound.correct.play();
        s.fat.animate(t, 1, _walnutFill);
        s.cue(t + _walnutFill, () => s.plumpStart = s.time);
        s.cue(t + _walnutFill + _settleSeconds, _finishStep);
      case _Food.dal:
      case _Food.paneer:
        // Cracks glow blue (1 s), then fade while the bicep pulses (1 s).
        _Sound.correct.play();
        s.healStart = t;
        s.cue(t + _glowSeconds, () => s.pulseStart = s.time);
        s.cue(t + _glowSeconds + _pulseSeconds, () {
          s
            ..muscleBase = _muscleGrown
            ..pulseStart = -1
            ..cracks = false
            ..healStart = -1;
          _finishStep();
        });
      case _Food.potato:
        // Energy bar appears and fills (1 s); the cracks stay.
        _Sound.correct.play();
        s
          ..energyShown = true
          ..energy.set(_energyStart);
        s.energy.animate(t, 1, _potatoFill);
        s.cue(t + _potatoFill + _settleSeconds, _finishStep);
    }
    _refresh();
  }

  /// HTML `progressStep()`; after the third food, `triggerConclusionState`
  /// shows 'Review Findings' with a chime.
  void _finishStep() {
    final s = _scene;
    s
      ..busy = false
      ..fed += 1
      ..resetDone = false;
    if (s.fed == _feedSteps) _Sound.success.play();
    _refresh();
  }

  /// HTML `executeStepAction` (S1 step 2): the runner is tired again.
  void _resetRunner() {
    final s = _scene;
    s.energy.set(_energyStart);
    s
      ..pace = _Pace.tired
      ..resetDone = true;
    _refresh();
  }

  /// HTML `executeStepAction` (S2): the muscle is damaged again.
  void _resetMuscle() {
    _scene
      ..cracks = true
      ..healStart = -1
      ..pulseStart = -1
      ..muscleBase = 1
      ..energyShown = false
      ..resetDone = true;
    _refresh();
  }

  /// HTML `triggerConclusion()`.
  void _review() {
    final s = _scene;
    if (s.fed < _feedSteps) return;
    s.reviewed = true;
    _refresh();
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
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
        ),
      ),
    );
  }

  /// The HTML's own buttons: 'Reset Runner' / 'Reset Muscle' (HTML
  /// `showActionBtn`) at step 2, 'Review Findings' (HTML
  /// `#compare-btn-container`) once the three foods are done.
  List<LabAction> _actions() {
    final s = _scene;
    if (_step == 2 && !s.resetDone && !s.busy) {
      final runner = s.scenario == 0;
      return [
        LabAction(
          label: _t(runner ? 'btn_reset_runner' : 'btn_reset_muscle'),
          icon: Icons.refresh,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          highlight: true,
          sound: _Sound.pop,
          onTap: runner ? _resetRunner : _resetMuscle,
        ),
      ];
    }
    if (s.fed >= _feedSteps) {
      return [
        LabAction(
          label: _t('btn_review'),
          icon: Icons.check_circle,
          color: _Colors.emerald600,
          foreground: _Colors.white,
          highlight: !s.reviewed,
          silent: true,
          onTap: _review,
        ),
      ];
    }
    return const [];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown`: a press on a food card (not while an effect plays).
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null || _scene.busy) return false;
    return _scene.foodAt(event.localPosition, _touch) != null;
  }

  /// Picks up the step's food. The HTML only lets the step's food move; a
  /// press on another food, or on the butter / potato before the reset,
  /// explains what to do instead.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final f = s.foodAt(d.localPosition, _touch);
    if (f == null || s.busy) return;
    if (f.food != _wantedFood) {
      _lab.showToast(
        _t('wrong_s${s.scenario + 1}_${_step.clamp(1, _feedSteps)}'),
        isError: true,
      );
      return;
    }
    if (_step == 2 && !s.resetDone) {
      _lab.showToast(
        _t(s.scenario == 0 ? 'need_reset_runner' : 'need_reset_muscle'),
        isError: true,
      );
      return;
    }
    final rest = s.foodPos(f);
    final hit = s.camera().onPlaneY(d.localPosition, _dragPlaneY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - rest.x, 0, hit.z - rest.z);
    f
      ..returnStart = -1
      ..pos = _V(rest.x, _liftY, rest.z);
    s.held = f;
    _grab = f;
    _grabScenario = s.scenario;
    _lastPointer = d.localPosition;
    _Sound.pickup.play();
  }

  /// HTML `handleMove`: the card follows the finger on the drag plane,
  /// lifted to y = 1.5.
  void _onDragUpdate(DragUpdateDetails d) {
    final f = _grab;
    if (f == null || _grabScenario != _scene.scenario) return;
    final hit = _scene.camera().onPlaneY(d.localPosition, _dragPlaneY);
    _lastPointer = d.localPosition;
    if (hit == null) return;
    f.pos = _V(hit.x - _grabOffset.x, _heldY, hit.z - _grabOffset.z);
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`: the food is eaten if it lands on its eater, otherwise
  /// it glides back to the tray (`playSound('error')`).
  void _release() {
    final f = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (f == null || scenario != s.scenario) return;
    s.held = null;
    if (s.lands(f.food.target, f.pos, _lastPointer, _touch * 0.5)) {
      _feed(f);
      return;
    }
    f
      ..returnFrom = f.pos
      ..returnStart = s.time;
    _lab.showToast(_t('miss_${f.food.name}'), isError: true);
    _scheduleFraming();
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
          icon: Icons.fitness_center,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${sc + 1}_hud_${_step.clamp(1, _stepCounts[sc])}'),
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
            pendingText: _t('pending'),
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags on the scene are not screen-reader actions; the scene is
            // announced by its label instead.
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

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and result (and the HTML explanation). The current
/// step is open, done steps show a tick and can be re-opened, future steps
/// are dimmed. A step's focus, result and explanation are shown once the
/// step is done (the HTML showed them before the learner had seen them).
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
    required this.pendingText,
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

  Widget _body(String text, Color color, {bool italic = false}) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: (italic ? 11 : 11.5) * widget.fontScale,
      fontWeight: FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
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
                  if (past && step.focus.isNotEmpty) ...[
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
                    if (past)
                      _body(step.result, p.text)
                    else
                      _body(w.pendingText, p.textMuted, italic: true),
                  ],
                  if (past && step.explanation.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    Container(
                      padding: EdgeInsets.only(top: 8 * s),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: p.cardBorder)),
                      ),
                      child: _body(step.explanation, p.textMuted, italic: true),
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

/// HTML `#summary-visual-area`: what each nutrient does, as two panels
/// (S1: carbohydrate → quick energy, fat → stored energy; S2: protein →
/// body-building and repair, and the potato's carbohydrate → quick energy,
/// dimmed).
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.t,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final first = scenario == 0
        ? _panel(
            foods: const [_Art.banana],
            nutrient: t('sum_carb'),
            nutrientColor: _Colors.indigo400,
            result: _resultIcon(Icons.bolt, _Colors.amber400),
            resultText: t('sum_quick'),
            resultColor: _Colors.amber400,
          )
        : _panel(
            foods: const [_Art.dal, _Art.paneer],
            nutrient: t('sum_protein'),
            nutrientColor: _Colors.indigo400,
            result: _resultIcon(
              Icons.fitness_center,
              _Colors.white,
              disc: _Colors.emerald500,
            ),
            resultText: t('sum_repair'),
            resultColor: _Colors.emerald400,
          );
    final second = scenario == 0
        ? _panel(
            foods: const [_Art.butter, _Art.walnuts],
            nutrient: t('sum_fat'),
            nutrientColor: _Colors.amber500,
            result: _resultIcon(Icons.battery_full, _Colors.battery),
            resultText: t('sum_stored'),
            resultColor: _Colors.emerald400,
          )
        : _panel(
            foods: const [_Art.potato],
            nutrient: t('sum_carb'),
            nutrientColor: p.textMuted,
            result: _resultIcon(Icons.bolt, p.textMuted),
            resultText: t('sum_quick'),
            resultColor: p.textMuted,
            note: t('sum_why'),
          );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          SizedBox(width: 8 * scale),
          Expanded(child: second),
        ],
      ),
    );
  }

  Widget _resultIcon(IconData icon, Color color, {Color? disc}) {
    final s = scale;
    final glyph = Icon(icon, size: (disc == null ? 30 : 20) * s, color: color);
    if (disc == null) return glyph;
    return Container(
      width: 32 * s,
      height: 32 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: disc,
        shape: BoxShape.circle,
        border: Border.all(color: _Colors.white, width: 2),
      ),
      child: glyph,
    );
  }

  Widget _panel({
    required List<_Art> foods,
    required String nutrient,
    required Color nutrientColor,
    required Widget result,
    required String resultText,
    required Color resultColor,
    String? note,
  }) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < foods.length; i++) ...[
                if (i > 0) SizedBox(width: 4 * s),
                _FoodBadge(art: foods[i], size: 36 * s),
              ],
            ],
          ),
          SizedBox(height: 4 * s),
          Text(
            nutrient,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.ink(nutrientColor),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(Icons.arrow_downward, size: 16 * s, color: p.textMuted),
          result,
          SizedBox(height: 2 * s),
          Text(
            resultText,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.ink(resultColor),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (note != null) ...[
            SizedBox(height: 2 * s),
            Text(
              note,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * s,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A food picture on a white card with an indigo border (the HTML summary's
/// `bg-white rounded-xl border-2 border-indigo-500` icons).
class _FoodBadge extends StatelessWidget {
  const _FoodBadge({required this.art, required this.size});

  final _Art art;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: _Colors.card,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: _Colors.indigo500, width: 2),
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

  /// Butt-ended shading bands along limbs.
  final Paint band = Paint()..style = PaintingStyle.stroke;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// The cracks' additive glow.
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour, drawn on a unit circle) and the label text painters.
/// Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
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

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle (lit from the upper right, like the HTML key light).
  Paint ball(Color c) => _balls[c.toARGB32()] ??= Paint()
    ..shader = ui.Gradient.radial(
      const Offset(0.3, -0.4),
      1.4,
      [labShade(c, 0.4), c, labShade(c, -0.35)],
      const [0, 0.45, 1],
    );

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    _balls.clear();
  }
}

/// The HTML `SVGs` food icons, redrawn as paths in their 24 x 24 view box
/// (made once). The banana is drawn yellow: the HTML's white-and-indigo
/// banana vanished on the white card.
abstract final class _IconArt {
  static final Path _bananaBody = Path()
    ..moveTo(3.2, 7.6)
    ..cubicTo(3.6, 14.8, 9.6, 20.6, 19.8, 17.6)
    ..cubicTo(21, 17.2, 21, 15.8, 19.8, 15.6)
    ..cubicTo(12.4, 16.6, 7.4, 12.6, 6, 7.4)
    ..close();
  static final Path _bananaStem = Path()
    ..moveTo(2.4, 8.2)
    ..lineTo(3, 5.4)
    ..lineTo(5.6, 5.6)
    ..lineTo(6, 7.6)
    ..close();
  static final Path _bananaRidge = Path()
    ..moveTo(4.9, 9.6)
    ..cubicTo(6.6, 14.2, 11, 17.4, 18, 16.8);

  static final Path _butterFront = Path()
    ..addRect(const Rect.fromLTRB(3.5, 11.5, 16, 18.5));
  static final Path _butterTop = Path()
    ..moveTo(3.5, 11.5)
    ..lineTo(7.5, 7.5)
    ..lineTo(20, 7.5)
    ..lineTo(16, 11.5)
    ..close();
  static final Path _butterSide = Path()
    ..moveTo(16, 11.5)
    ..lineTo(20, 7.5)
    ..lineTo(20, 14.5)
    ..lineTo(16, 18.5)
    ..close();

  static const List<Offset> _walnutCentres = [
    Offset(8, 8.6),
    Offset(15.6, 9.2),
    Offset(11.6, 15.6),
  ];
  static const double _walnutR = 4.4;
  static final Path _walnutCrease = Path()
    ..moveTo(-2.6, -0.6)
    ..cubicTo(-1.2, 1.4, 0.4, -1.8, 2.6, 0.6);

  static final Path _bowl = Path()
    ..moveTo(2.5, 11)
    ..lineTo(21.5, 11)
    ..cubicTo(21.5, 17.5, 17, 21, 12, 21)
    ..cubicTo(7, 21, 2.5, 17.5, 2.5, 11)
    ..close();
  static const Rect _dalTop = Rect.fromLTRB(2.6, 8.6, 21.4, 13.4);
  static const List<Offset> _dalSpecks = [
    Offset(7, 10.8),
    Offset(10.5, 10),
    Offset(14, 11.4),
    Offset(17, 10.4),
    Offset(12, 12.2),
  ];

  static final Path _potato = Path()
    ..addOval(
      Rect.fromCenter(center: const Offset(12, 12), width: 16, height: 12),
    )
    ..transform(
      (Matrix4.identity()
            ..translateByDouble(12, 12, 0, 1)
            ..rotateZ(math.pi / 6)
            ..translateByDouble(-12, -12, 0, 1))
          .storage,
    );
  static const List<Offset> _potatoEyes = [
    Offset(10, 10),
    Offset(14, 13),
    Offset(11, 14),
  ];

  /// Two paneer cubes (front, top and side faces each).
  static final List<(Path, Path, Path)> _paneer = [
    _cube(const Rect.fromLTRB(2.5, 11.5, 11, 20), 2.5),
    _cube(const Rect.fromLTRB(12, 9, 20.5, 17.5), 2.5),
  ];

  static (Path, Path, Path) _cube(Rect front, double d) => (
    Path()..addRect(front),
    Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.left + d, front.top - d)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right, front.top)
      ..close(),
    Path()
      ..moveTo(front.right, front.top)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right + d, front.bottom - d)
      ..lineTo(front.right, front.bottom)
      ..close(),
  );

  static final RRect _batteryBody = RRect.fromRectAndRadius(
    const Rect.fromLTWH(4, 6, 16, 12),
    const Radius.circular(2),
  );
  static const List<Rect> _batteryCells = [
    Rect.fromLTWH(6, 8, 3, 8),
    Rect.fromLTWH(10, 8, 3, 8),
    Rect.fromLTWH(14, 8, 3, 8),
    Rect.fromLTWH(20, 10, 2, 4),
  ];

  /// Draws [art] into [box] with the reused [fill] and [stroke] paints.
  static void draw(
    Canvas canvas,
    _Art art,
    Rect box,
    Paint fill,
    Paint stroke,
  ) {
    canvas.save();
    canvas.translate(box.left, box.top);
    canvas.scale(box.width / 24, box.height / 24);
    void fillPath(Path path, Color color) =>
        canvas.drawPath(path, fill..color = color);
    void line(Path path, Color color, double width) => canvas.drawPath(
      path,
      stroke
        ..strokeWidth = width
        ..color = color,
    );
    switch (art) {
      case _Art.banana:
        fillPath(_bananaBody, _Colors.banana);
        line(_bananaRidge, _Colors.bananaEdge, 0.6);
        line(_bananaBody, _Colors.bananaEdge, 0.7);
        fillPath(_bananaStem, _Colors.bananaStem);
      case _Art.butter:
        fillPath(_butterSide, _Colors.butterSide);
        fillPath(_butterTop, _Colors.butterTop);
        fillPath(_butterFront, _Colors.butterFront);
        for (final p in [_butterSide, _butterTop, _butterFront]) {
          line(p, _Colors.butterEdge, 0.6);
        }
      case _Art.walnuts:
        for (final c in _walnutCentres) {
          canvas.drawCircle(c, _walnutR, fill..color = _Colors.walnut);
          canvas.drawCircle(
            c,
            _walnutR,
            stroke
              ..strokeWidth = 0.7
              ..color = _Colors.walnutDark,
          );
          canvas.drawCircle(
            c + const Offset(-1.3, -1.4),
            1.1,
            fill..color = _Colors.walnutLight,
          );
          canvas.save();
          canvas.translate(c.dx, c.dy);
          line(_walnutCrease, _Colors.walnutDark, 0.7);
          canvas.restore();
        }
      case _Art.dal:
        fillPath(_bowl, _Colors.bowl);
        canvas.drawOval(_dalTop, fill..color = _Colors.dal);
        for (final c in _dalSpecks) {
          canvas.drawCircle(c, 0.6, fill..color = _Colors.dalSpeck);
        }
        canvas.drawOval(
          _dalTop,
          stroke
            ..strokeWidth = 0.7
            ..color = _Colors.bowlRim,
        );
      case _Art.potato:
        fillPath(_potato, _Colors.potato);
        line(_potato, _Colors.potatoEdge, 0.7);
        for (final c in _potatoEyes) {
          canvas.drawCircle(c, 0.7, fill..color = _Colors.potatoEdge);
        }
      case _Art.paneer:
        for (final (front, top, side) in _paneer) {
          fillPath(side, _Colors.paneerSide);
          fillPath(top, _Colors.card);
          fillPath(front, _Colors.paneer);
          for (final p in [side, top, front]) {
            line(p, _Colors.paneerEdge, 0.6);
          }
        }
      case _Art.battery:
        canvas.drawRRect(
          _batteryBody,
          stroke
            ..strokeWidth = 2
            ..color = _Colors.battery,
        );
        for (final r in _batteryCells) {
          canvas.drawRect(r, fill..color = _Colors.battery);
        }
    }
    canvas.restore();
  }
}

/// A food picture for widgets (the summary popup). Static pictures, so the
/// paints are shared.
class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.art);

  final _Art art;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) =>
      _IconArt.draw(canvas, art, Offset.zero & size, _fill, _stroke);

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.art != art;
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

/// HTML key light `DirectionalLight` at (10, 20, 10), normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// HTML `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(…, 0.8)`.
const double _ambient = 0.6;
const double _diffuse = 0.8;

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat quad (already lit [color]).
  void quad(_V a, _V b, _V c, _V d, Color color) {
    final path = pens.path..reset();
    final pts = [a, b, c, d];
    for (var i = 0; i < 4; i++) {
      _move(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _move(
          path,
          i,
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        );
      }
      path.close();
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
  }

  /// A shaded ellipse of radii [rx] x [ry] world units at [c], turned by
  /// [angle] on screen (spheres and ellipsoids).
  void blob(_V c, double rx, double ry, Color color, {double angle = 0}) {
    final p = cam.p(c);
    final k = cam.scaleAt(c);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(math.max(0.01, rx * k), math.max(0.01, ry * k));
    canvas.drawCircle(Offset.zero, 1, cache.ball(color));
    canvas.restore();
  }

  /// SphereGeometry of radius [r].
  void ball(_V c, double r, Color color) => blob(c, r, r, color);

  /// An ellipsoid with radii [rx], [ry], [rz] as the camera sees it (its
  /// x axis is the screen's horizontal).
  void ellipsoid(_V c, double rx, double ry, double rz, Color color) {
    final hy = math.sqrt(math.pow(ry * cam.u.y, 2) + math.pow(rz * cam.u.z, 2));
    blob(c, rx, hy, color);
  }

  /// A small flat dot (eyes, nose tip).
  void dot(_V c, double r, Color color) => canvas.drawCircle(
    cam.p(c),
    math.max(0.8, r * cam.scaleAt(c)),
    pens.fill..color = color,
  );

  /// A limb (tapered CylinderGeometry with rounded ends) from [a] to [b]
  /// with radii [ra] and [rb]: body, shaded side and highlight.
  void limb(_V a, _V b, double ra, double rb, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.8, ra * cam.scaleAt(a));
    final wb = math.max(0.8, rb * cam.scaleAt(b));
    final fill = pens.fill..color = color;
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) {
      canvas.drawCircle(pa, math.max(wa, wb), fill);
      return;
    }
    final n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawCircle(pa, wa, fill);
    canvas.drawCircle(pb, wb, fill);
    // The key light comes from the upper right of the screen.
    var lit = n;
    if (lit.dy > 0 || (lit.dy == 0 && lit.dx < 0)) lit = -lit;
    final w = (wa + wb) / 2;
    canvas.drawLine(
      pa - lit * (wa * 0.55),
      pb - lit * (wb * 0.55),
      pens.band
        ..strokeWidth = w * 0.7
        ..color = labShade(color, -0.2),
    );
    canvas.drawLine(
      pa + lit * (wa * 0.45),
      pb + lit * (wb * 0.45),
      pens.band
        ..strokeWidth = w * 0.3
        ..color = labShade(color, 0.28),
    );
  }

  /// Soft contact shadow: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz) {
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

/// Paints the HTML Three.js scene of the current scenario: S1 the gym and
/// snow field (runner, treadmill, polar bear, bars), S2 the sportsperson;
/// both with the food tray, then the labels and the held card on top.
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
    // Floor `PlaneGeometry(24, 12)`.
    g.quad(
      const _V(-12, 0, -6),
      const _V(12, 0, -6),
      const _V(12, 0, 6),
      const _V(-12, 0, 6),
      _lit(_Colors.floor, _V.up),
    );
    if (s.scenario == 0) {
      _paintGym(g);
    } else {
      _paintRepair(g);
    }
    _paintTray(g);
    if (showLabels) _paintLabels(g);
    final held = s.held;
    if (held != null) _paintHeld(g, held);
  }

  // ---------------------------------------------------------- scenario 1

  void _paintGym(_Gfx g) {
    final s = scene;
    g.quad(
      _snowCenter + const _V(-_snowHalf, 0, -_snowHalf),
      _snowCenter + const _V(_snowHalf, 0, -_snowHalf),
      _snowCenter + const _V(_snowHalf, 0, _snowHalf),
      _snowCenter + const _V(-_snowHalf, 0, _snowHalf),
      _lit(_Colors.snow, _V.up),
    );
    // Shadows (the key light at (10, 20, 10) casts towards -x / -z).
    final grow = s.plump - 1;
    g.shadow(
      _bearPos + const _V(-0.35, 0.02, -0.3),
      1.75 + _bearBodyR.x * grow,
      1.0 + 0.4 * grow,
    );
    g.shadow(_treadBase + const _V(-0.3, -0.19, -0.3), 2.2, 1.15);
    _paintTreadmill(g);
    _paintRunner(g);
    _paintBear(g);
    _paintBar(g, _energyBarS1, s.energyFill);
    _paintBar(g, _fatBar, s.fatFill);
    final pop = s.storedPop;
    if (pop > 0.01) {
      _paintCard(g, _storedIcon, _Art.battery, _storedScale * pop);
    }
  }

  /// `tmBase` and `tmConsole`, with a belt whose tread lines run at the
  /// runner's pace (added).
  void _paintTreadmill(_Gfx g) {
    g.box(_console, _consoleSize, _Colors.machine, edge: 0.5);
    g.box(_treadBase, _treadSize, _Colors.machine, edge: 0.5);
    const y = _treadTop + 0.002;
    const x0 = -6.85, x1 = -3.15, z = 0.85;
    g.quad(
      const _V(x0, y, -z),
      const _V(x1, y, -z),
      const _V(x1, y, z),
      const _V(x0, y, z),
      _lit(_Colors.belt, _V.up),
    );
    final tread = _pens.stroke
      ..strokeWidth = 1
      ..color = _Colors.tread;
    for (var x = x0 + scene.tread; x < x1; x += _treadGap) {
      g.canvas.drawLine(
        g.cam.p(_V(x, y, -z + 0.05)),
        g.cam.p(_V(x, y, z - 0.05)),
        tread,
      );
    }
  }

  /// `buildRunner()`: the runner in profile, facing the console (-x),
  /// bobbing with the run tween; legs and arms swing (added).
  void _paintRunner(_Gfx g) {
    final s = scene;
    final base = _runnerPos + _V(0, s.bob, 0);
    // Local x (the runner's right) → world z, local z (forward) → world -x
    // (HTML `rotation.y = -π/2`).
    _V w(_V l) => _V(base.x - l.z, base.y + l.y, base.z + l.x);
    final a = s.swing;
    final spine = _V(0, math.cos(_runnerLean), math.sin(_runnerLean));
    const hip = _V(0, _runnerHipY, 0);
    final neck = hip + spine * _runnerSpine;
    final head = neck + spine * 0.42;

    void leg(double side, double ang) {
      final h = _V(side * 0.17, hip.y, 0);
      final k = h + _V(0, -math.cos(ang), math.sin(ang)) * _thighLen;
      final c = ang - _kneeBend - _kickBend * math.max(0.0, -ang);
      final an = k + _V(0, -math.cos(c), math.sin(c)) * _calfLen;
      g.limb(w(h), w(k), 0.15, 0.12, _Colors.skin);
      g.limb(w(k), w(an), 0.12, 0.1, _Colors.skin);
      g.limb(
        w(an),
        w(an + const _V(0, -0.03, 0.2)),
        0.08,
        0.07,
        _Colors.shoeRunner,
      );
    }

    void arm(double side, double ang) {
      final sh = neck + _V(side * 0.4, -0.1, 0);
      final el = sh + _V(0, -math.cos(ang), math.sin(ang)) * 0.4;
      final fa = ang + _elbowBend;
      final hand = el + _V(0, -math.cos(fa), math.sin(fa)) * 0.36;
      g.limb(w(sh), w(el), 0.11, 0.1, _Colors.skin);
      g.limb(w(el), w(hand), 0.1, 0.08, _Colors.skin);
      g.ball(w(hand), 0.1, _Colors.skin);
    }

    // Far side (the runner's left, world z < 0) first.
    arm(-1, -a * _armSwing);
    leg(-1, a);
    // Ponytail (`ConeGeometry(0.15, 0.4)` behind the head), swaying.
    final tail = head + const _V(0, 0.02, -0.26);
    g.limb(
      w(tail),
      w(tail + _V(0, -0.22 - 0.06 * math.sin(s.runPhase), -0.3)),
      0.11,
      0.04,
      _Colors.hair,
    );
    // Pelvis and chest (clothes).
    g.limb(
      w(hip - spine * 0.05),
      w(hip + spine * 0.36),
      0.3,
      0.33,
      _Colors.clothes,
    );
    g.limb(
      w(hip + spine * 0.3),
      w(neck - spine * 0.04),
      0.3,
      0.35,
      _Colors.clothes,
    );
    leg(1, -a);
    // Neck, hair and face; the near eye in profile.
    g.limb(
      w(neck - spine * 0.02),
      w(neck + spine * 0.16),
      0.1,
      0.1,
      _Colors.skin,
    );
    g.ball(w(head + const _V(0, 0.04, -0.05)), 0.31, _Colors.hair);
    g.ball(w(head + const _V(0, -0.02, 0.05)), 0.27, _Colors.skin);
    g.dot(w(head + const _V(0.1, 0.05, 0.25)), 0.04, _Colors.hair);
    g.dot(w(head + const _V(0.08, -0.09, 0.27)), 0.025, _Colors.mouth);
    arm(1, a * _armSwing);
  }

  /// `buildPolarBear()`: thin at first; plumper (body x, z 1 → 1.4) once
  /// the walnuts' fat is stored.
  void _paintBear(_Gfx g) {
    final s = scene;
    final p = s.plump;
    final grow = p - 1;
    const b = _bearPos;
    final head = b + _V(_bearHeadX + _bearBodyR.x * grow, _bearHeadY, 0);
    final tail = b + _V(-_bearTailX - _bearBodyR.x * grow, _bearTailY, 0);
    final legZ = _bearLegZ + 0.3 * grow;
    for (final z in [-legZ, legZ]) {
      for (final (lx, px) in const [(0.8, 0.9), (-0.8, -0.7)]) {
        g.limb(b + _V(lx, 0.8, z), b + _V(lx, 0.12, z), 0.25, 0.3, _Colors.fur);
        g.blob(b + _V(px, 0.15, z), 0.38, 0.19, _Colors.fur);
      }
    }
    g.ball(tail, 0.2, _Colors.fur);
    g.ellipsoid(
      b + const _V(0, _bearBodyY, 0),
      _bearBodyR.x * p,
      _bearBodyR.y,
      _bearBodyR.z * p,
      _Colors.fur,
    );
    g.ball(head + const _V(-0.1, 0.35, -0.25), 0.12, _Colors.fur);
    g.ellipsoid(head, _bearHeadR.x, _bearHeadR.y, _bearHeadR.z, _Colors.fur);
    g.ball(head + const _V(-0.1, 0.35, 0.25), 0.12, _Colors.fur);
    // Snout `CylinderGeometry(0.2, 0.25, 0.4)` along x, nose and the near
    // eye on the head's surface.
    g.limb(
      head + const _V(0.22, -0.1, 0),
      head + const _V(0.6, -0.1, 0),
      0.25,
      0.2,
      _Colors.fur,
    );
    g.ball(head + const _V(0.66, -0.06, 0), 0.08, _Colors.hair);
    g.dot(head + const _V(0.3, 0.1, 0.33), 0.05, _Colors.hair);
  }

  // ---------------------------------------------------------- scenario 2

  void _paintRepair(_Gfx g) {
    final s = scene;
    g.shadow(_personPos + const _V(-0.35, 0.01, -0.3), 0.9, 0.45);
    _paintPerson(g);
    if (s.energyShown) _paintBar(g, _energyBarS2, s.energyFill);
  }

  /// `buildSportsperson()` (scale 1.3): facing the camera, left arm
  /// relaxed, right arm flexing with the bicep and its crack sprite.
  void _paintPerson(_Gfx g) {
    final s = scene;
    _V w(double x, double y, [double z = 0]) => _V(
      _personPos.x + x * _personScale,
      _personPos.y + y * _personScale,
      _personPos.z + z * _personScale,
    );
    double r(double v) => v * _personScale;
    // Legs: shorts (clothes) over the thighs, skin calves, dark shoes.
    for (final x in const [-0.2, 0.2]) {
      g.limb(w(x, 1.38), w(x, 0.72), r(0.18), r(0.15), _Colors.clothes);
      g.limb(w(x, 0.74), w(x, 0.12), r(0.14), r(0.1), _Colors.skin);
      g.blob(w(x, 0.07, 0.08), r(0.12), r(0.07), _Colors.shoeSport);
    }
    // V-shaped torso.
    g.limb(w(0, 1.42), w(0, 1.8), r(0.38), r(0.35), _Colors.clothes);
    g.limb(w(0, 1.82), w(0, 2.32), r(0.36), r(0.46), _Colors.clothes);
    // Relaxed arm.
    g.limb(w(-0.56, 2.3), w(-0.64, 1.82, 0.02), r(0.15), r(0.12), _Colors.skin);
    g.limb(
      w(-0.64, 1.82, 0.02),
      w(-0.62, 1.38, 0.08),
      r(0.12),
      r(0.1),
      _Colors.skin,
    );
    g.ball(w(-0.62, 1.3, 0.1), r(0.12), _Colors.skin);
    // Neck, hair, face.
    g.limb(w(0, 2.38), w(0, 2.62), r(0.14), r(0.13), _Colors.skin);
    g.ball(w(0, 2.92, -0.03), r(0.36), _Colors.hair);
    g.ball(w(0, 2.82, 0.04), r(0.33), _Colors.skin);
    g.dot(w(-0.12, 2.88, 0.32), r(0.045), _Colors.hair);
    g.dot(w(0.12, 2.88, 0.32), r(0.045), _Colors.hair);
    g.canvas.drawLine(
      g.cam.p(w(-0.07, 2.72, 0.33)),
      g.cam.p(w(0.07, 2.72, 0.33)),
      _pens.stroke
        ..strokeWidth = math.max(1, r(0.03) * g.cam.scaleAt(w(0, 2.72)))
        ..color = _Colors.hair,
    );
    // Flexing arm: shoulder, upper arm, forearm up, fist.
    final sh = w(0.55, 2.3);
    final el = w(1.08, 2.12, 0.05);
    g.ball(sh, r(0.2), _Colors.skin);
    g.limb(sh, el, r(0.17), r(0.14), _Colors.skin);
    g.limb(el, w(1.03, 2.6, 0.08), r(0.14), r(0.12), _Colors.skin);
    g.ball(w(1.02, 2.72, 0.09), r(0.15), _Colors.skin);
    // Bicep (`SphereGeometry(0.32)` scaled (1.4, 0.9, 0.9)) along the
    // upper arm; it grows once repaired.
    final pa = g.cam.p(sh), pe = g.cam.p(el);
    final angle = math.atan2(pe.dy - pa.dy, pe.dx - pa.dx);
    final m = s.muscle;
    final bicep = w(0.8, 2.29, 0.1);
    g.blob(bicep, r(0.33) * m, r(0.22) * m, _Colors.skin, angle: angle);
    final alpha = s.crackAlpha;
    if (alpha > 0.01) {
      _paintCracks(g, w(0.8, 2.29, 0.32), angle, s.crackColor, alpha);
    }
  }

  /// The crack sprite's zig-zag on the bicep, with its additive glow.
  void _paintCracks(_Gfx g, _V at, double angle, Color color, double alpha) {
    final c = g.cam.p(at);
    final k = g.cam.scaleAt(at) * _personScale;
    final cs = math.cos(angle), sn = math.sin(angle);
    final path = _pens.path..reset();
    for (var i = 0; i < _crackPts.length; i++) {
      final (x, y) = _crackPts[i];
      final o = Offset(
        c.dx + (x * cs - y * sn) * k,
        c.dy + (x * sn + y * cs) * k,
      );
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    final width = math.max(1.6, 0.06 * k);
    g.canvas.drawPath(
      path,
      _pens.glow
        ..strokeWidth = width * 2.6
        ..color = color.withValues(alpha: alpha * 0.6),
    );
    g.canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = width
        ..color = color.withValues(alpha: alpha),
    );
  }

  // ----------------------------------------------------------- shared

  /// The food tray and the cards still on it.
  void _paintTray(_Gfx g) {
    final s = scene;
    g.box(_trayCenter, _traySize, labShade(_Colors.tray, 0.15), edge: 0.6);
    for (final f in s.foods) {
      if (identical(f, s.held)) continue;
      final k = s.foodScale(f);
      if (k <= 0.01) continue;
      final pos = s.foodPos(f);
      g.shadow(
        _V(pos.x - 0.2, _trayCenter.y + _traySize.y / 2 + 0.01, pos.z - 0.15),
        0.6 * k,
        0.35 * k,
      );
      _paintCard(g, pos, f.food.art, k);
    }
  }

  /// The held card, lifted, with its shadow on the floor.
  void _paintHeld(_Gfx g, _FoodState f) {
    final pos = f.pos;
    g.shadow(_V(pos.x - 0.3, 0.01, pos.z - 0.3), 0.6, 0.35);
    _paintCard(g, pos, f.food.art, 1);
    if (showLabels) {
      _chip(
        g,
        g.cam.p(_foodLabelAt(pos, 1)),
        _t(f.food.nameKey),
        sub: _t(f.food.nutrientKey),
        align: _below,
      );
    }
  }

  /// HTML `createIconSprite`: white rounded card with an indigo border and
  /// the food picture, [k] times the 1.5-unit sprite.
  void _paintCard(_Gfx g, _V pos, _Art art, double k) {
    final c = g.cam.p(pos);
    final side = _cardSize * g.cam.scaleAt(pos) * k;
    final rect = Rect.fromCenter(center: c, width: side, height: side);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(side * 0.125));
    g.canvas.drawRRect(
      rr.shift(Offset(0, side * 0.05)),
      _pens.fill..color = _Colors.cardShadow,
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.card);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = math.max(1.2, side * 4 / 128)
        ..color = _Colors.indigo500,
    );
    _IconArt.draw(
      g.canvas,
      art,
      rect.deflate(side * 0.14),
      _pens.fill,
      _pens.stroke,
    );
  }

  /// HTML `createStatusBarSprite`: dark box with a light border, filled
  /// red / yellow / green; its caption is a label chip above it.
  void _paintBar(_Gfx g, _V at, double fill) {
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
    final inset = _barInset * k;
    final width = (outer.width - 2 * inset) * fill.clamp(0.0, 1.0);
    if (width > 0.5) {
      final color = fill > _barGreenFrom
          ? _Colors.barHigh
          : (fill > _barYellowFrom ? _Colors.barMid : _Colors.barLow);
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
  }

  /// Every text sprite of the scene as a label chip (HTML `labelDict`).
  void _paintLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    if (s.scenario == 0) {
      _chip(g, cam.p(_runnerLabelAt), _t('lbl_runner'), align: _below);
      _chip(g, cam.p(_bearLabelAt), _t('lbl_bear'), align: _above);
      _chip(
        g,
        cam.p(_energyBarS1 + const _V(0, _barCaptionLift, 0)),
        _t('lbl_energy'),
        align: _above,
      );
      _chip(
        g,
        cam.p(_fatBar + const _V(0, _barCaptionLift, 0)),
        _t('lbl_fat'),
        align: _above,
      );
      if (s.storedPop > 0.5) {
        const half = _cardSize * _storedScale / 2;
        _chip(
          g,
          cam.p(_storedIcon + const _V(half + 0.1, 0, 0)),
          _t('lbl_stored'),
          align: _rightOf,
        );
      }
    } else {
      _chip(g, cam.p(_personLabelAt), _t('lbl_person'), align: _below);
      if (s.energyShown) {
        _chip(
          g,
          cam.p(_energyBarS2 + const _V(0, _barCaptionLift, 0)),
          _t('lbl_energy'),
          align: _above,
        );
      }
    }
    _chip(g, cam.p(_trayLabelAt), _t('lbl_tray'), align: _leftOf);
    for (final f in s.foods) {
      if (f.eaten || identical(f, s.held)) continue;
      _chip(
        g,
        cam.p(_foodLabelAt(s.foodPos(f), 1)),
        _t(f.food.nameKey),
        sub: _t(f.food.nutrientKey),
        align: _below,
      );
    }
  }

  /// HTML `createTextSprite`: dark chip with an indigo border and white
  /// bold text (a second, smaller line for the nutrient), placed on [at]
  /// by [align] and kept inside the visible canvas.
  void _chip(
    _Gfx g,
    Offset at,
    String text, {
    String? sub,
    (double, double) align = (0, 0),
  }) {
    final size = cache.chipSize(text, sub: sub);
    var rect = (at + _chipOffset(size, align)) & size;
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
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
