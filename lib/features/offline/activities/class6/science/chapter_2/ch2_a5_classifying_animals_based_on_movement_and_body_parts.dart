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

/// Class 6 Science • Chapter 2 • Activity 5
/// Classifying Animals Based on Movement and Body Parts.
///
/// Native Flutter port of
/// `Cl6S-Ch02-A5-Classifying_Animals_Based_on_Movement_and_Body_Parts.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML cameras (45° field of view): Scenario 1
/// from (0, 9, 18) looking at (0, 3, 0), Scenario 2 from (4, 6, 12) looking
/// at (4, 1.5, 0). The procedural animals keep the HTML meshes (spheres,
/// cylinders, cones and planes), poses and animations.
///
/// Scenario 1 (The Movement Zones): a goat, an ant, a pigeon, a housefly and
/// a fish wait on a wooden shelf above a grassy field with a tree and a
/// pond. Step by step the learner drags each animal into the zone where it
/// mainly moves: the goat walks in the Ground Zone, the fish swims circles
/// in the pond (Water Zone), the pigeon circles in the sky (Air Zone), then
/// the ant crawls on the grass and the housefly hovers in the air. A drop
/// in the wrong zone sends the animal back to the shelf. 'Review
/// Connections' sums up the ground, air and water movers.
///
/// Scenario 2 (Connecting Body Parts to Movement): the five animals stand on
/// a round podium beside three body-part cards (Fins, Wings, Legs). The
/// learner taps a card (the animals that use it pulse), then taps those
/// animals, or drags a line from the card onto them: a dotted line joins
/// card and animal, which then swims, flaps or walks in place. Fins go to
/// the fish, wings to the pigeon and the housefly, legs to the goat and the
/// ant. 'Review Connections' sums up fins → swimming, wings → flying and
/// legs → walking / crawling.
class Ch2A5ClassifyingAnimalsBasedOnMovementAndBodyPartsPage
    extends StatefulWidget {
  const Ch2A5ClassifyingAnimalsBasedOnMovementAndBodyPartsPage({super.key});

  @override
  State<Ch2A5ClassifyingAnimalsBasedOnMovementAndBodyPartsPage> createState() =>
      _AnimalMovementLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: the app's own tones in `assets/audio/`. The
/// HTML synthesises its tones with Web Audio (`playSound(type)`); they map
/// to the closest files: 'click' / 'pop' → click (`science/click.mp3`), an
/// animal dropped in its zone or joined to its card ('success') → correct
/// (`math/success.mp3`), 'error' (wrong zone, wrong card) → wrong
/// (`science/error.mp3`), 'chime' ('Review Connections' appears) and the
/// summary → success (`math/success.mp3`). The shell's sidebar, scenario
/// and curtain tones are `science/dropdown.mp3`, `science/page_open.mp3`
/// and `science/curtain.mp3`. Picking up an animal (added) reuses the
/// click.
enum _Sound implements LabTone {
  /// Generic button click; a body-part card selected (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// An animal dropped in its zone or joined to its card (HTML `success`).
  correct('audio/class6/math/success.mp3'),

  /// Wrong zone, wrong card, an animal of another step (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// 'Review Connections' appears (HTML `chime`) and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An animal picked up from the shelf (added).
  pickup('audio/class6/science/click.mp3');

  const _Sound(this.asset);

  /// Path below `assets/` (the [AssetSource] prefix).
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

/// Colours of the HTML page (Tailwind classes), of its Three.js scenes
/// (material colours), its text sprites, connection lines and card icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber900 = Color(0xFF78350F);
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
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
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark theme), 0xe0f2fe (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// `scene.fog` (`FogExp2(0x0f172a, 0.015)`): set once, at start-up in the
  /// dark theme, and never changed by the theme toggle.
  static const Color fog = slate900;

  /// Scenario 1: grass `0x4ade80`, clouds, tree trunk `0x5c4033` and its two
  /// leaf dodecahedra, pond `0x0ea5e9` (opacity 0.8), rocks and the wooden
  /// shelf `0x78350f`.
  static const Color grass = green400;
  static const Color cloud = Color(0xE6FFFFFF);
  static const Color trunk = Color(0xFF5C4033);
  static const Color leaves = green500;
  static const Color leavesDark = green600;
  static const Color pond = sky500;
  static const double pondOpacity = 0.8;
  static const Color rock = slate400;
  static const Color shelf = Color(0xFF78350F);

  /// Scenario 2: floor `0x1e293b` and podium `0x334155`.
  static const Color floor = slate800;
  static const Color podium = slate700;

  /// The animals' materials (HTML `createGoat()` … `createHousefly()`).
  static const Color goat = Color(0xFFF3F4F6);
  static const Color goatDark = Color(0xFF1F2937);
  static const Color fish = Color(0xFF38BDF8);
  static const Color fishFin = Color(0xFF0284C7);
  static const Color pigeon = slate400;
  static const Color pigeonDark = slate600;
  static const Color beak = amber500;
  static const Color ant = Color(0xFF7F1D1D);
  static const Color antDark = Color(0xFF450A0A);
  static const Color fly = Color(0xFF111827);
  static const Color flyEye = Color(0xFF991B1B);
  static const Color flyWing = slate200;
  static const double flyWingOpacity = 0.4;
  static const Color eye = black;
  static const Color eyeWhite = white;

  /// Fill light `DirectionalLight(0x90b0d0, 0.4)`.
  static const Color fillLight = Color(0xFF90B0D0);

  /// Text sprites (`createTextSprite`): `#1e293b` chip, white text and a
  /// border per label: zones green / sky / purple, Scenario 1 animals
  /// `#94a3b8`, Scenario 2 animals `#3b82f6`.
  static const Color chipBg = slate800;
  static const Color chipText = white;
  static const Color chipAnimalS1 = slate400;
  static const Color chipAnimalS2 = blue500;

  /// The dotted line that follows the finger from the selected card.
  static const Color activeLine = green500;

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x52000000);

  /// Selected card (`border-green-500 bg-green-50 dark:bg-green-900/30`).
  static const Color cardSelectedDark = Color(0x4D14532D);

  /// canvas-confetti colours of the summary burst.
  static const List<Color> confetti = [blue500, emerald500, amber500];
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
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.blue500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E40AF), // blue-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.blue300,
    buttonBorder: Color(0xCC3B82F6),
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
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.blue600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E40AF),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.blue300,
    buttonBorder: Color(0xCC3B82F6),
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
// From the HTML `i18n`, `ScenariosData`, `labelDict` and summary tables
// (Telugu dropped). `sN_act_M` are the step actions, `sN_hud_M` the HTML
// "Current Task" lines ("CLICK" reads "TAP" on a touch screen),
// `sN_focus_M` / `sN_obs_M` / `sN_expl_M` the HTML concept, observation and
// explanation (shown once the step is done). The last step of each
// scenario is the HTML's last HUD task ('Review Connections'). Keys marked
// "Added" are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Classifying Animals Based on Movement and Body Parts',
    'app_subtitle': 'Class 6 • Diversity in the Living World',
    'scen_1_opt': 'Scenario 1: The Movement Zones',
    'scen_2_opt': 'Scenario 2: Connecting Body Parts to Movement',
    's1_desc':
        'Group animals into different environmental zones based on their primary method of movement.',
    's2_desc':
        'Identify and connect the specific body parts that enable different types of animal movement.',
    's1_act_1': 'Drag Goat to Ground Zone.',
    's1_act_2': 'Drag Fish to Water Zone.',
    's1_act_3': 'Drag Pigeon to Air Zone.',
    's1_act_4': 'Drag Ant to Ground, Housefly to Air.',
    's1_act_5': "Tap the 'Review Connections' button to see a summary.",
    's2_act_1': "Connect 'Fins' to Fish.",
    's2_act_2': "Connect 'Wings' to Pigeon & Housefly.",
    's2_act_3': "Connect 'Legs' to Goat & Ant.",
    's2_act_4':
        "Tap the 'Review Connections' button to summarize the relationships.",
    's1_hud_1':
        'Observe the animals on the shelf. DRAG the Goat and DROP it into the zone where it primarily moves.',
    's1_hud_2':
        'Now, DRAG the Fish and DROP it into its correct movement zone.',
    's1_hud_3':
        'DRAG the Pigeon and DROP it into the zone it uses for long-distance travel.',
    's1_hud_4':
        'Two animals left! DRAG both the Ant and the Housefly to their correct movement zones.',
    's1_hud_5': "TAP the 'Review Connections' button to see a summary.",
    's2_hud_1':
        "Let's link body parts to movement. TAP the 'Fins' icon card on the left. Then TAP the animal that uses fins.",
    's2_hud_2':
        "TAP the 'Wings' icon card. Then TAP all the animals that use wings to move.",
    's2_hud_3':
        "TAP the 'Legs' icon card. Then TAP the animals that use legs to walk or crawl.",
    's2_hud_4':
        "TAP the 'Review Connections' button to summarize the relationships.",
    's1_focus_1': 'Walking',
    's1_focus_2': 'Swimming',
    's1_focus_3': 'Flying',
    's1_focus_4': 'Crawling & Flying',
    's1_obs_1': 'Goat snaps into place and begins to walk.',
    's1_obs_2': 'Fish snaps into pond and starts swimming.',
    's1_obs_3': 'Pigeon flies in a circle in the sky.',
    's1_obs_4': 'Ant crawls on grass; Housefly buzzes in the air.',
    's1_expl_1': 'Goats use their legs primarily to walk and run on land.',
    's1_expl_2': 'Fish use their fins and tail to swim efficiently in water.',
    's1_expl_3':
        'While birds can walk, their primary method for long travel is flying.',
    's1_expl_4':
        'Insects have varied movement. Ants crawl using legs, while houseflies predominantly fly using wings.',
    's2_focus_1': 'Fins',
    's2_focus_2': 'Wings',
    's2_focus_3': 'Legs',
    's2_obs_1': 'Line connects, Fish swims in place.',
    's2_obs_2': 'Lines connect, both animals flap/buzz in place.',
    's2_obs_3': 'Lines connect, animals walk/crawl in place.',
    's2_expl_1':
        'Fins are specialized structures for propulsion and steering in aquatic environments.',
    's2_expl_2':
        'Wings are adaptations for generating lift to overcome gravity, allowing flight.',
    's2_expl_3':
        'Legs are jointed appendages adapted to support weight and facilitate movement over solid surfaces.',
    // The HTML's "*how*" (markdown emphasis shown as asterisks) reads "how".
    's1_summary':
        'Great! You have grouped animals based on how they move: walking/crawling on the ground, flying in the air, or swimming in the water. This is one fundamental way to classify the diversity of life.',
    's2_summary':
        "Excellent! You've seen that animals have special body parts for movement. Fins are for swimming, wings are for flying, and legs are for walking. Structure determines function!",
    'sum_title': 'Discovery Complete!',
    'sum_heading': 'Classification Complete!',
    'next_msg': 'Scenario 1 completed. Select the next from the sidebar!',
    'btn_conclude': 'Review Connections',
    'select_part': 'Select a part',
    'part_fins': 'Fins',
    'part_wings': 'Wings',
    'part_legs': 'Legs',
    'lbl_ground': 'Ground Zone',
    'lbl_air': 'Air Zone',
    'lbl_water': 'Water Zone',
    'lbl_goat': 'Goat',
    'lbl_fish': 'Fish',
    'lbl_pigeon': 'Pigeon',
    'lbl_ant': 'Ant',
    'lbl_fly': 'Housefly',
    'sum_gm': 'Ground Movers',
    'sum_am': 'Air Movers',
    'sum_wm': 'Water Movers',
    'sum_wc': 'Walking/Crawling',
    'sum_f': 'Flying',
    'sum_s': 'Swimming',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Observation',
    // Added.
    'pending': 'Do this step to see the result.',
    'wrong_s1_1': 'Not yet! In this step, drag the Goat.',
    'wrong_s1_2': 'Not yet! In this step, drag the Fish.',
    'wrong_s1_3': 'Not yet! In this step, drag the Pigeon.',
    'drag_off':
        'Drag the animal off the shelf and drop it into one of the zones.',
    'miss_goat': 'Not there! A goat walks on land: drop it in the Ground Zone.',
    'miss_fish':
        'Not there! A fish swims: drop it in the Water Zone (the pond).',
    'miss_pigeon':
        'Not there! A pigeon flies on long trips: drop it high in the sky, in the Air Zone.',
    'miss_ant': 'Not there! An ant crawls on land: drop it in the Ground Zone.',
    'miss_fly':
        'Not there! A housefly mostly flies: drop it high in the sky, in the Air Zone.',
    'pick_card':
        'First tap a body-part card on the left (Fins, Wings or Legs).',
    'not_yet_s2_1':
        "Not yet! First connect the 'Fins' card to the animal that uses fins.",
    'not_yet_s2_2':
        "Not yet! First connect the 'Wings' card to the animals that use wings.",
    'wrong_goat': 'Not a match! The Goat mainly moves with its legs.',
    'wrong_fish': 'Not a match! The Fish moves with its fins.',
    'wrong_pigeon': 'Not a match! The Pigeon mainly moves with its wings.',
    'wrong_ant': 'Not a match! The Ant moves with its legs.',
    'wrong_fly': 'Not a match! The Housefly mainly moves with its wings.',
    'scene_s1':
        'A grassy field with a tree, a pond and clouds. A wooden shelf holds a goat, an ant, a pigeon, a housefly and a fish. The Ground Zone, Water Zone and Air Zone are labelled.',
    'scene_s2':
        'A round podium with a goat, a fish, a pigeon, an ant and a housefly, and the Fins, Wings and Legs cards on the left.',
  },
  'hi': {
    'app_title': 'आंदोलन और शरीर के अंगों के आधार पर जानवरों का वर्गीकरण',
    'app_subtitle': 'कक्षा 6 • सजीव जगत में विविधता',
    'scen_1_opt': 'परिदृश्य 1: आंदोलन क्षेत्र',
    'scen_2_opt': 'परिदृश्य 2: शरीर के अंगों को गति से जोड़ना',
    's1_desc':
        'जानवरों को उनकी प्राथमिक गति के आधार पर विभिन्न पर्यावरण क्षेत्रों में समूहित करें।',
    's2_desc':
        'उन विशिष्ट शरीर के अंगों को पहचानें और जोड़ें जो विभिन्न प्रकार के पशु आंदोलनों को सक्षम करते हैं।',
    's1_act_1': 'बकरी को ग्राउंड ज़ोन में खींचें।',
    's1_act_2': 'मछली को वाटर ज़ोन में खींचें।',
    's1_act_3': 'कबूतर को एयर ज़ोन में खींचें।',
    's1_act_4': 'चींटी को जमीन पर, मक्खी को हवा में खींचें।',
    's1_act_5':
        "सारांश देखने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's2_act_1': "'पंख(मछली)' को मछली से जोड़ें।",
    's2_act_2': "'पंख' को कबूतर और मक्खी से जोड़ें।",
    's2_act_3': "'पैर' को बकरी और चींटी से जोड़ें।",
    's2_act_4':
        "रिश्तों को संक्षेप में प्रस्तुत करने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's1_hud_1':
        'शेल्फ पर जानवरों का निरीक्षण करें। बकरी को खींचें और उस क्षेत्र में छोड़ें जहाँ वह मुख्य रूप से चलती है।',
    's1_hud_2': 'अब, मछली को खींचें और उसके सही गति क्षेत्र में छोड़ें।',
    's1_hud_3':
        'कबूतर को खींचें और उस क्षेत्र में छोड़ें जिसका उपयोग वह लंबी दूरी की यात्रा के लिए करता है।',
    's1_hud_4':
        'दो जानवर बचे हैं! चींटी और मक्खी दोनों को उनके सही गति क्षेत्रों में खींचें।',
    's1_hud_5':
        "सारांश देखने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        "आइए शरीर के अंगों को गति से जोड़ें। बाईं ओर 'पंख(मछली)' आइकन कार्ड पर टैप करें। फिर पंखों का उपयोग करने वाले जानवर पर टैप करें।",
    's2_hud_2':
        "'पंख' आइकन कार्ड पर टैप करें। फिर उन सभी जानवरों पर टैप करें जो उड़ने के लिए पंखों का उपयोग करते हैं।",
    's2_hud_3':
        "'पैर' आइकन कार्ड पर टैप करें। फिर चलने या रेंगने के लिए पैरों का उपयोग करने वाले जानवरों पर टैप करें।",
    's2_hud_4':
        "रिश्तों को संक्षेप में प्रस्तुत करने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's1_focus_1': 'चलना',
    's1_focus_2': 'तैरना',
    's1_focus_3': 'उड़ना',
    's1_focus_4': 'रेंगना और उड़ना',
    's1_obs_1': 'बकरी अपनी जगह पर आ जाती है और चलने लगती है।',
    's1_obs_2': 'मछली तालाब में आ जाती है और तैरने लगती है।',
    's1_obs_3': 'कबूतर आसमान में चक्कर लगाता है।',
    's1_obs_4': 'चींटी घास पर रेंगती है; मक्खी हवा में भिनभिनाती है।',
    's1_expl_1':
        'बकरियां मुख्य रूप से जमीन पर चलने और दौड़ने के लिए अपने पैरों का उपयोग करती हैं।',
    's1_expl_2':
        'मछलियां पानी में कुशलता से तैरने के लिए अपने पंखों और पूंछ का उपयोग करती हैं।',
    's1_expl_3':
        'यद्यपि पक्षी चल सकते हैं, लंबी यात्रा के लिए उनकी प्राथमिक विधि उड़ना है।',
    's1_expl_4':
        'कीड़ों में अलग-अलग गति होती है। चींटियां पैरों का उपयोग करके रेंगती हैं, जबकि मक्खियां मुख्य रूप से पंखों का उपयोग करके उड़ती हैं।',
    's2_focus_1': 'पंख(मछली)',
    's2_focus_2': 'पंख',
    's2_focus_3': 'पैर',
    's2_obs_1': 'रेखा जुड़ती है, मछली अपनी जगह पर तैरती है।',
    's2_obs_2':
        'रेखाएँ जुड़ती हैं, दोनों जानवर अपनी जगह पर फड़फड़ाते/भिनभिनाते हैं।',
    's2_obs_3': 'रेखाएँ जुड़ती हैं, जानवर अपनी जगह पर चलते/रेंगते हैं।',
    's2_expl_1':
        'पंख(मछली) जलीय वातावरण में प्रणोदन और स्टीयरिंग के लिए विशेष संरचनाएं हैं।',
    's2_expl_2':
        'पंख गुरुत्वाकर्षण को दूर करने के लिए लिफ्ट उत्पन्न करने के लिए अनुकूलन हैं, जिससे उड़ान की अनुमति मिलती है।',
    's2_expl_3':
        'पैर ठोस सतहों पर वजन का समर्थन करने और आंदोलन को सुविधाजनक बनाने के लिए अनुकूलित उपांग हैं।',
    's1_summary':
        'बहुत बढ़िया! आपने जानवरों को वे कैसे चलते हैं, इसके आधार पर समूहित किया है: जमीन पर चलना/रेंगना, हवा में उड़ना, या पानी में तैरना। जीवन की विविधता को वर्गीकृत करने का यह एक मूलभूत तरीका है।',
    's2_summary':
        'बहुत बढ़िया! आपने देखा है कि जानवरों के आंदोलन के लिए शरीर के विशेष अंग होते हैं। पंख(मछली) तैरने के लिए हैं, पंख उड़ने के लिए हैं, और पैर चलने के लिए हैं। संरचना कार्य निर्धारित करती है!',
    'sum_title': 'खोज पूर्ण!',
    'sum_heading': 'वर्गीकरण पूरा हुआ!',
    'next_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'btn_conclude': 'कनेक्शन की समीक्षा करें',
    'select_part': 'भाग चुनें',
    'part_fins': 'पंख(मछली)',
    'part_wings': 'पंख',
    'part_legs': 'पैर',
    'lbl_ground': 'ज़मीन क्षेत्र',
    'lbl_air': 'हवा क्षेत्र',
    'lbl_water': 'पानी क्षेत्र',
    'lbl_goat': 'बकरी',
    'lbl_fish': 'मछली',
    'lbl_pigeon': 'कबूतर',
    'lbl_ant': 'चींटी',
    'lbl_fly': 'मक्खी',
    'sum_gm': 'ज़मीन पर चलने वाले',
    'sum_am': 'हवा में उड़ने वाले',
    'sum_wm': 'पानी में तैरने वाले',
    'sum_wc': 'चलना/रेंगना',
    'sum_f': 'उड़ना',
    'sum_s': 'तैरना',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'अवलोकन',
    // Added.
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'wrong_s1_1': 'अभी नहीं! इस चरण में बकरी को खींचें।',
    'wrong_s1_2': 'अभी नहीं! इस चरण में मछली को खींचें।',
    'wrong_s1_3': 'अभी नहीं! इस चरण में कबूतर को खींचें।',
    'drag_off': 'जानवर को शेल्फ से खींचकर किसी एक क्षेत्र में छोड़ें।',
    'miss_goat':
        'वहाँ नहीं! बकरी ज़मीन पर चलती है: उसे ज़मीन क्षेत्र में छोड़ें।',
    'miss_fish':
        'वहाँ नहीं! मछली तैरती है: उसे पानी क्षेत्र (तालाब) में छोड़ें।',
    'miss_pigeon':
        'वहाँ नहीं! कबूतर लंबी यात्रा के लिए उड़ता है: उसे ऊपर आसमान में, हवा क्षेत्र में छोड़ें।',
    'miss_ant':
        'वहाँ नहीं! चींटी ज़मीन पर रेंगती है: उसे ज़मीन क्षेत्र में छोड़ें।',
    'miss_fly':
        'वहाँ नहीं! मक्खी ज़्यादातर उड़ती है: उसे ऊपर आसमान में, हवा क्षेत्र में छोड़ें।',
    'pick_card':
        'पहले बाईं ओर शरीर के अंग का कोई कार्ड (पंख(मछली), पंख या पैर) टैप करें।',
    'not_yet_s2_1':
        "अभी नहीं! पहले 'पंख(मछली)' कार्ड को पंखों का उपयोग करने वाले जानवर से जोड़ें।",
    'not_yet_s2_2':
        "अभी नहीं! पहले 'पंख' कार्ड को उड़ने के लिए पंखों का उपयोग करने वाले जानवरों से जोड़ें।",
    'wrong_goat': 'मेल नहीं खाता! बकरी मुख्य रूप से अपने पैरों से चलती है।',
    'wrong_fish': 'मेल नहीं खाता! मछली अपने पंख(मछली) से तैरती है।',
    'wrong_pigeon': 'मेल नहीं खाता! कबूतर मुख्य रूप से अपने पंखों से उड़ता है।',
    'wrong_ant': 'मेल नहीं खाता! चींटी अपने पैरों से रेंगती है।',
    'wrong_fly': 'मेल नहीं खाता! मक्खी मुख्य रूप से अपने पंखों से उड़ती है।',
    'scene_s1':
        'पेड़, तालाब और बादलों वाला एक घास का मैदान। लकड़ी की एक शेल्फ पर बकरी, चींटी, कबूतर, मक्खी और मछली हैं। ज़मीन क्षेत्र, पानी क्षेत्र और हवा क्षेत्र पर लेबल लगे हैं।',
    'scene_s2':
        'एक गोल मंच पर बकरी, मछली, कबूतर, चींटी और मक्खी, और बाईं ओर पंख(मछली), पंख और पैर के कार्ड।',
  },
};

/// Number of steps of each scenario: the HTML steps plus its last HUD task
/// ('Review Connections').
const List<int> _stepCounts = [5, 4];

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

/// The steps of scenario [index] (0 or 1) in [lang]. The review step has
/// no focus, observation or explanation.
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  final count = _stepCounts[index];
  return [
    for (var i = 1; i <= count; i++)
      _StepInfo(
        focus: i < count ? t('s${n}_focus_$i') : '',
        action: t('s${n}_act_$i'),
        result: i < count ? t('s${n}_obs_$i') : '',
        explanation: i < count ? t('s${n}_expl_$i') : '',
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The step
/// concept stays empty: the HTML concepts ("Walking", "Fins") are shown in
/// the accordion once each step is done.
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

/// HTML cameras: `PerspectiveCamera(45, …)` placed by `resetCamera()`:
/// Scenario 1 at (0, 9, 18) looking at `controls.target` (0, 3, 0),
/// Scenario 2 at (4, 6, 12) looking at (4, 1.5, 0).
const double _fovDegrees = 45;
const List<_V> _eyes = [_V(0, 9, 18), _V(4, 6, 12)];
const List<_V> _targets = [_V(0, 3, 0), _V(4, 1.5, 0)];
const double _near = 0.1;

/// Polygons are clipped this close to the camera (the Scenario 2 floor
/// reaches behind it).
const double _clipDepth = 0.5;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up an animal (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

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
const List<double> _maxZoom = [1.25, 1.4];
const double _minZoom = 0.3;

/// HTML `animate()` adds 0.05 to its clock every frame (60 fps), so the
/// clock that drives the walking, swimming and flying runs at 3 per second.
const double _clockRate = 3;

// ------------------------------------------------ scenario 1: movement zones

/// Grass (S1) and floor (S2) `PlaneGeometry(40, 30)` at y = 0.
const double _floorHalfX = 20;
const double _floorHalfZ = 15;

/// HTML `FogExp2(…, 0.015)`.
const double _fogDensity = 0.015;

/// Wooden shelf `BoxGeometry(14, 0.4, 2.5)` at (0, 2, -3) on two legs
/// `CylinderGeometry(0.2, 0.2, 2)` at (±6, 1, -3).
const _V _shelfCenter = _V(0, 2, -3);
const _V _shelfSize = _V(14, 0.4, 2.5);
const double _shelfLegX = 6;
const double _shelfLegR = 0.2;
const double _shelfLegH = 2;
const double _shelfTop = 2.2;

/// The animals wait on the shelf at y = 2.25, z = -3 (x -5 … 5), facing
/// right (`rotation.y = π/2`).
const double _shelfY = 2.25;
const double _shelfZ = -3;
const double _faceRight = math.pi / 2;

/// HTML `handleUp` zone test: an animal moved more than 1 unit lands in the
/// Air Zone at y ≥ 3.5, otherwise in the Ground Zone left of x = -0.5 or
/// in the Water Zone right of x = 0.5.
const double _minMove = 1;
const double _airFrom = 3.5;
const double _zoneSplit = 0.5;

/// Where a placed animal goes: the goat to (-6.5, …, 2.5), the ant to
/// (-3.5, 0.2, 4), the fish into the pond (y = 0.2), fliers to y = 4.5
/// where they were dropped (S2 fliers rise to 1.5).
const _V _goatSpot = _V(-6.5, 0, 2.5);
const _V _antSpot = _V(-3.5, 0.2, 4);
const double _fishY = 0.2;
const double _flyHeightS1 = 4.5;
const double _flyHeightS2 = 1.5;

/// HTML hover: `position.y = height + sin(time·4)·0.2`.
const double _hoverAmp = 0.2;

/// HTML walk: `position.y = base + |sin(time·5)|·0.1`, with base 0.5 for
/// the goat (the S2 podium top) and 0.2 for the ant in both scenarios.
/// Here the S1 goat walks on the grass (y = 0) and the S2 ant on the
/// podium (0.5): the HTML goat floats above the grass and its ant sinks
/// into the podium.
const double _walkBob = 0.1;
const double _antWalkS1 = 0.2;

/// Pond `CylinderGeometry(5, 5, 0.2)` at (6, 0.1, 3); the fish swims round
/// its centre (radius 1.5). The pigeon circles (2.5 x 1.5) round
/// (0, 4.5, -2).
const _V _pondCenter = _V(6, 0.1, 3);
const double _pondR = 5;
const double _pondH = 0.2;
const double _swimR = 1.5;
const double _circleRx = 2.5;
const double _circleRz = 1.5;
const double _circleZ = -2;

/// Pick-up: the animal grows to 1.2x in 200 ms (and back on release); a
/// missed drop glides home in 500 ms (`TWEEN.Easing.Elastic.Out`).
const double _liftScale = 1.2;
const double _liftSeconds = 0.2;
const double _returnSeconds = 0.5;

/// Tree: trunk `CylinderGeometry(0.5, 0.7, 4)` and two leaf dodecahedra
/// (r 2.5 at height 4.5; r 2 at (1.5, 3.5, 1)) at (-9, 0, -2).
const _V _treeBase = _V(-9, 0, -2);
const double _trunkTopR = 0.5;
const double _trunkBottomR = 0.7;
const double _trunkH = 4;
const _V _leavesAt = _V(-9, 4.5, -2);
const double _leavesR = 2.5;
const _V _leaves2At = _V(-7.5, 3.5, -1);
const double _leaves2R = 2;

/// Clouds `createCloud(x, y, z, s)`.
const List<(_V, double)> _clouds = [
  (_V(-10, 8, -8), 2),
  (_V(5, 9, -10), 1.5),
  (_V(12, 7, -6), 2.5),
];

/// Each cloud: three unit spheres at (i·1.2 − 1.2, rand·0.5, rand·0.5),
/// scaled rand·0.5 + 0.8, then by the cloud's scale. The HTML's
/// `Math.random()` is a fixed seed here so the clouds keep their shape.
final List<(_V, double)> _cloudPuffs = () {
  final rnd = math.Random(11);
  return [
    for (final (at, s) in _clouds)
      for (var i = 0; i < 3; i++)
        (
          at +
              _V(
                    i * 1.2 - 1.2,
                    rnd.nextDouble() * 0.5,
                    rnd.nextDouble() * 0.5,
                  ) *
                  s,
          (rnd.nextDouble() * 0.5 + 0.8) * s,
        ),
  ];
}();

/// Rocks (`DodecahedronGeometry`) by the pond.
const List<(_V, double)> _rocks = [
  (_V(3, 0.2, 5), 0.6),
  (_V(2.5, 0.1, 4.2), 0.4),
];

// --------------------------------------------- scenario 2: body-part podium

/// Podium `CylinderGeometry(5, 5.5, 0.5)` at (4, 0.25, 0); the animals
/// stand on its top on a half circle of radius 3.5 round x = 4 (HTML
/// `resetScenarioState(2)`).
const _V _podiumCenter = _V(4, 0.25, 0);
const double _podiumTopR = 5;
const double _podiumBottomR = 5.5;
const double _podiumH = 0.5;
const double _podiumTop = 0.5;
const double _arcR = 3.5;

/// The animals that use the selected card pulse: scale 1 ± 0.12
/// (`sin(time·6)`).
const double _pulseAmp = 0.12;

/// Wrong card: the animal shakes, `rotation.z` 0 → 0.2 in 50 ms, yoyo,
/// repeat 5.
const double _shakeAngle = 0.2;
const double _shakeHalf = 0.05;
const int _shakeHalves = 6;

// ------------------------------------------------------------------ shared

/// Text sprites above the animals: local y = 2 (S1) and 2.8 (S2), scaled
/// with the animal.
const List<double> _labelLift = [2, 2.8];

/// HTML hit boxes: S1 `BoxGeometry(2, 2, 2)` at y 0.5; S2
/// `CylinderGeometry(1.2, 1.2, 3)` at y 1.5 (as its bounding box).
const List<(_V, _V)> _hitBoxes = [
  (_V(-1, -0.5, -1), _V(1, 1.5, 1)),
  (_V(-1.2, 0, -1.2), _V(1.2, 3, 1.2)),
];

/// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})` with
/// the summary: canvas-confetti's 200 ticks of 1/60 s, velocity x 0.9 per
/// tick, gravity 3 px per tick and start velocity 45 (scaled by
/// [_confettiSpeed] for the stage), from 30 % down the canvas.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);
const Rect _confettiPiece = Rect.fromLTWH(-5, -3, 10, 6);

/// The S2 body-part cards (HTML `w-20 h-24`, `gap-4`) and their header.
const double _partCardW = 80;
const double _partCardH = 96;
const double _partCardGap = 16;

// ---------------------------------------------------------------- models

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V one = _V(1, 1, 1);
  static const _V up = _V(0, 1, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A 3 x 3 matrix (rows), for Three.js rotations and scales.
@immutable
class _M3 {
  const _M3(
    this.xx,
    this.xy,
    this.xz,
    this.yx,
    this.yy,
    this.yz,
    this.zx,
    this.zy,
    this.zz,
  );

  factory _M3.rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _M3(1, 0, 0, 0, c, -s, 0, s, c);
  }

  factory _M3.rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _M3(c, 0, s, 0, 1, 0, -s, 0, c);
  }

  factory _M3.rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _M3(c, -s, 0, s, c, 0, 0, 0, 1);
  }

  /// Three.js `Euler(x, y, z)` (order XYZ): Rx · Ry · Rz.
  factory _M3.euler(double x, double y, double z) {
    var m = identity;
    if (x != 0) m = m * _M3.rotX(x);
    if (y != 0) m = m * _M3.rotY(y);
    if (z != 0) m = m * _M3.rotZ(z);
    return m;
  }

  factory _M3.scale(_V s) => _M3(s.x, 0, 0, 0, s.y, 0, 0, 0, s.z);

  static const _M3 identity = _M3(1, 0, 0, 0, 1, 0, 0, 0, 1);

  final double xx, xy, xz, yx, yy, yz, zx, zy, zz;

  _M3 operator *(_M3 o) => _M3(
    xx * o.xx + xy * o.yx + xz * o.zx,
    xx * o.xy + xy * o.yy + xz * o.zy,
    xx * o.xz + xy * o.yz + xz * o.zz,
    yx * o.xx + yy * o.yx + yz * o.zx,
    yx * o.xy + yy * o.yy + yz * o.zy,
    yx * o.xz + yy * o.yz + yz * o.zz,
    zx * o.xx + zy * o.yx + zz * o.zx,
    zx * o.xy + zy * o.yy + zz * o.zy,
    zx * o.xz + zy * o.yz + zz * o.zz,
  );

  _V apply(_V v) => _V(
    xx * v.x + xy * v.y + xz * v.z,
    yx * v.x + yy * v.y + yz * v.z,
    zx * v.x + zy * v.y + zz * v.z,
  );
}

/// An object's world transform (Three.js `matrixWorld`): linear part and
/// position.
@immutable
class _Xf {
  const _Xf(this.m, this.t);

  static const _Xf identity = _Xf(_M3.identity, _V.zero);

  final _M3 m;
  final _V t;

  _V apply(_V v) => m.apply(v) + t;
  _V dir(_V v) => m.apply(v);

  /// A child object at [at] (in this frame), turned by the Euler angles
  /// and scaled by [scale] (Three.js T · R · S).
  _Xf child(
    _V at, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
    _V scale = _V.one,
  }) {
    var local = _M3.euler(rx, ry, rz);
    if (scale != _V.one) local = local * _M3.scale(scale);
    return _Xf(m * local, apply(at));
  }
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

/// A PerspectiveCamera (position, target, fov 45) as a pinhole projection
/// onto the design stage.
@immutable
class _Cam {
  /// The HTML camera of [scenario] in a [_Framing].
  factory _Cam(int scenario, _Framing framing) => _Cam.look(
    _eyes[scenario],
    _targets[scenario],
    framing.center,
    _focal * framing.zoom,
  );

  /// A camera at [eye] looking at [target]; [target] lands on [center]
  /// and [scale] is design pixels per world unit at depth 1.
  factory _Cam.look(_V eye, _V target, Offset center, double scale) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, f, r, r.cross(f), center, scale);
  }

  const _Cam._(this.eye, this.f, this.r, this.u, this.center, this.scale);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;
  final double scale;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w].
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

  /// The screen image of the small world vector [a] placed at [w] (the
  /// projection's Jacobian).
  Offset dp(_V w, _V a) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    final az = a.dot(f);
    return Offset(
      scale * (a.dot(r) - d.dot(r) * az / z) / z,
      -scale * (a.dot(u) - d.dot(u) * az / z) / z,
    );
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the plane through [point] with
  /// [normal] (HTML `getIntersects(e, [dragPlane])`).
  _V? onPlane(Offset s, _V point, _V normal) {
    final d = ray(s);
    final denom = d.dot(normal);
    if (denom.abs() < 1e-6) return null;
    final t = (point - eye).dot(normal) / denom;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the local box [min]–[max] placed by [xf].
  Rect boxRect(_Xf xf, _V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        xf.apply(
          _V(
            (i & 1) != 0 ? max.x : min.x,
            (i & 2) != 0 ? max.y : min.y,
            (i & 4) != 0 ? max.z : min.z,
          ),
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

/// The three movement zones of Scenario 1 (HTML `zGround`, `zWater`,
/// `zAir` and their text sprites). The labels sit where the HTML code
/// places them: its `grp.add(sprite).position.set(…)` moved the whole
/// scene group instead (`add` returns the group), stacking the Ground and
/// Water labels.
enum _Zone {
  ground('lbl_ground', _Colors.green500, _V(-5, 0, 3)),
  water('lbl_water', _Colors.sky500, _V(6, 0, 3)),
  air('lbl_air', _Colors.purple500, _V(0, 5, -3));

  const _Zone(this.labelKey, this.color, this.labelAt);

  final String labelKey;

  /// Sprite border colour.
  final Color color;
  final _V labelAt;
}

/// The three body-part cards of Scenario 2 (HTML `#s2-cards-container`).
enum _Part {
  fins('part_fins', _Colors.blue500, _Colors.blue400, _Colors.blue900),
  wings('part_wings', _Colors.indigo500, _Colors.indigo400, _Colors.indigo900),
  legs('part_legs', _Colors.amber500, _Colors.amber400, _Colors.amber900);

  const _Part(this.key, this.color, this.light, this.deep);

  final String key;

  /// Card icon and connection line colour (`text-blue-500`, `#3b82f6` …).
  final Color color;

  /// Summary icon (`text-blue-400` …) and its box (`bg-blue-900/50` …).
  final Color light;
  final Color deep;
}

/// The five animals, in the HTML's Scenario 2 arc order (`['goat', 'fish',
/// 'pigeon', 'ant', 'fly']`).
enum _Kind {
  goat('lbl_goat', _Part.legs, _Zone.ground, 1, -5, 1, 3),
  fish('lbl_fish', _Part.fins, _Zone.water, 1, 5, 2, 1),
  pigeon('lbl_pigeon', _Part.wings, _Zone.air, 1, 0, 3, 2),
  ant('lbl_ant', _Part.legs, _Zone.ground, 1.5, -2.5, 4, 3),
  fly('lbl_fly', _Part.wings, _Zone.air, 1.5, 2.5, 4, 2);

  const _Kind(
    this.labelKey,
    this.part,
    this.zone,
    this.size,
    this.shelfX,
    this.s1Step,
    this.s2Step,
  );

  final String labelKey;

  /// HTML `userData.part` and `userData.type`.
  final _Part part;
  final _Zone zone;

  /// `grp.scale` (the ant and the housefly are built at 1.5x).
  final double size;

  /// Place on the S1 shelf.
  final double shelfX;

  /// The step that moves this animal in each scenario.
  final int s1Step;
  final int s2Step;

  _V get shelfHome => _V(shelfX, _shelfY, _shelfZ);

  /// HTML `resetScenarioState(2)`: angle (i / 4)·π − π/2, position
  /// (4 + cos·3.5, 0.5, sin·3.5), `rotation.y = −angle + π/2`.
  double get _arcAngle => index / 4 * math.pi - math.pi / 2;
  _V get arcHome => _V(
    _podiumCenter.x + math.cos(_arcAngle) * _arcR,
    _podiumTop,
    math.sin(_arcAngle) * _arcR,
  );
  double get arcYaw => -_arcAngle + math.pi / 2;

  /// The model's local bounds (before [size]).
  (_V, _V) get extent => switch (this) {
    _Kind.goat => (const _V(-0.36, 0, -0.72), const _V(0.36, 1.62, 1.05)),
    _Kind.fish => (const _V(-0.45, -0.05, -1.15), const _V(0.45, 1.1, 0.75)),
    _Kind.pigeon => (const _V(-0.65, 0.35, -0.8), const _V(0.65, 1.08, 0.63)),
    _Kind.ant => (const _V(-0.3, -0.06, -0.47), const _V(0.3, 0.45, 0.55)),
    _Kind.fly => (const _V(-0.3, 0, -0.35), const _V(0.3, 0.43, 0.4)),
  };

  /// Half sizes of the contact shadow (sideways, along the body).
  (double, double) get footprint => switch (this) {
    _Kind.goat => (0.3, 0.75),
    _Kind.fish => (0.3, 0.75),
    _Kind.pigeon => (0.55, 0.6),
    _Kind.ant => (0.22, 0.5),
    _Kind.fly => (0.25, 0.32),
  };
}

/// One animal (HTML `Objects.s1[id]` / `Objects.s2[id]`).
class _Body {
  _Body(this.kind);

  final _Kind kind;

  /// HTML `userData.initPos` (S1) or its arc spot (S2), and its rotation.
  _V home = _V.zero;
  double homeYaw = 0;

  /// `position` and `rotation.y`.
  _V pos = _V.zero;
  double yaw = 0;

  /// HTML `userData.isAnimating`: walks, swims or flies.
  bool animating = false;

  /// Placed in its zone (S1) or joined to its card (S2).
  bool done = false;

  /// Pick-up scale tween (S1): from, to and start time (-1: none).
  double liftFrom = 1;
  double liftTo = 1;
  double liftStart = -1;

  /// Gliding home after a missed drop (start time, or -1).
  double returnStart = -1;
  _V returnFrom = _V.zero;

  /// Wrong-card shake (start time, or -1).
  double shakeStart = -1;
}

/// Mutable scene read by the painters every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  final List<_Body> bodies = [for (final k in _Kind.values) _Body(k)];

  /// The animal the learner is dragging (HTML `State.draggingObject`).
  _Body? held;

  /// The zone the held animal is over (its label lights up; added).
  _Zone? hover;

  /// The selected body-part card (HTML `State.s2.activeCard`).
  _Part? card;

  /// 'Review Connections' was tapped.
  bool reviewed = false;

  /// When the summary's confetti burst started, or -1.
  double confettiAt = -1;

  /// The confetti pieces: launch angle, speed, colour and spin.
  final List<({double angle, double velocity, Color color, double spin})>
  confetti = () {
    final rnd = math.Random(6);
    return [
      for (var i = 0; i < _confettiCount; i++)
        (
          angle: -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          velocity:
              (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          color: _Colors.confetti[i % _Colors.confetti.length],
          spin: (rnd.nextDouble() - 0.5) * 0.4,
        ),
    ];
  }();

  /// HTML `Math.random()` for where the fish lands in the pond.
  final math.Random _random = math.Random(5);

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// The HTML clock (`time += 0.05` per frame).
  double get clock => time * _clockRate;

  _Body body(_Kind k) => bodies[k.index];
  bool done(_Kind k) => bodies[k.index].done;

  /// HTML `resetScenarioState(sc)`: every animal back on the shelf (S1) or
  /// on its arc spot (S2), nothing selected.
  void load(int index) {
    scenario = index;
    for (final b in bodies) {
      final k = b.kind;
      b
        ..home = index == 0 ? k.shelfHome : k.arcHome
        ..homeYaw = index == 0 ? _faceRight : k.arcYaw
        ..pos = b.home
        ..yaw = b.homeYaw
        ..animating = false
        ..done = false
        ..liftFrom = 1
        ..liftTo = 1
        ..liftStart = -1
        ..returnStart = -1
        ..shakeStart = -1;
    }
    held = null;
    hover = null;
    card = null;
    reviewed = false;
    confettiAt = -1;
  }

  /// HTML `animate()` + `TWEEN.update()`: glides home, the walking,
  /// swimming and flying, and the framing.
  void advance(double dt) {
    final t = clock;
    for (final b in bodies) {
      if (b.returnStart >= 0) {
        final e = (time - b.returnStart) / _returnSeconds;
        if (e >= 1) {
          b
            ..returnStart = -1
            ..pos = b.home;
        } else {
          b.pos = _V.lerp(b.returnFrom, b.home, Curves.elasticOut.transform(e));
        }
      }
      if (b.animating) _animate(b, t);
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
    }
  }

  /// HTML `animateAnimal(obj)`.
  void _animate(_Body b, double t) {
    switch (b.kind.part) {
      case _Part.legs:
        // Walk / crawl: a little bob.
        b.pos = _V(
          b.pos.x,
          _walkBase(b.kind) + math.sin(t * 5).abs() * _walkBob,
          b.pos.z,
        );
      case _Part.fins:
        // Swim: sway; in S1, circles round the pond centre.
        b.yaw = math.sin(t * 3) * 0.2;
        if (scenario == 0) {
          b.pos = _V(
            _pondCenter.x + math.cos(t) * _swimR,
            b.pos.y,
            _pondCenter.z + math.sin(t) * _swimR,
          );
        }
      case _Part.wings:
        // Fly: hover; the S1 pigeon circles, facing where it goes.
        final y =
            (scenario == 0 ? _flyHeightS1 : _flyHeightS2) +
            math.sin(t * 4) * _hoverAmp;
        if (scenario == 0 && b.kind == _Kind.pigeon) {
          b
            ..pos = _V(
              math.cos(t) * _circleRx,
              y,
              _circleZ + math.sin(t) * _circleRz,
            )
            ..yaw = -t;
        } else {
          b.pos = _V(b.pos.x, y, b.pos.z);
        }
    }
  }

  /// Height a walking animal bobs from (see [_walkBob]).
  double _walkBase(_Kind k) {
    if (scenario == 1) return _podiumTop;
    return k == _Kind.goat ? 0 : _antWalkS1;
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
  _Cam camera() => _Cam(scenario, framing);

  // ------------------------------------------------------------- animals

  /// The animal's scale on top of its build size: the pick-up tween (S1)
  /// or the pulse of the animals that use the selected card (S2).
  double grow(_Body b) {
    if (scenario == 1) {
      final c = card;
      if (c != null && b.kind.part == c && !b.animating) {
        return 1 + math.sin(clock * 6) * _pulseAmp;
      }
      return 1;
    }
    if (b.liftStart < 0) return b.liftTo;
    final e = ((time - b.liftStart) / _liftSeconds).clamp(0.0, 1.0);
    return b.liftFrom + (b.liftTo - b.liftFrom) * e;
  }

  /// Starts the pick-up scale tween of [b] towards [to].
  void lift(_Body b, double to) {
    b
      ..liftFrom = grow(b)
      ..liftTo = to
      ..liftStart = time;
  }

  /// `rotation.z` of the wrong-card shake (0 → 0.2 → 0, three times).
  double roll(_Body b) {
    if (b.shakeStart < 0) return 0;
    final e = (time - b.shakeStart) / _shakeHalf;
    if (e >= _shakeHalves) return 0;
    return _shakeAngle * (1 - ((e % 2) - 1).abs());
  }

  /// The animal's world transform.
  _Xf xf(_Body b) {
    final s = b.kind.size * grow(b);
    return _Xf.identity.child(
      b.pos,
      ry: b.yaw,
      rz: roll(b),
      scale: _V(s, s, s),
    );
  }

  /// Where the animal's text sprite is (a child of the animal).
  _V labelAt(_Body b) => xf(b).apply(_V(0, _labelLift[scenario], 0));

  /// The animal at [p] that passes [test] (HTML raycast on the hit boxes):
  /// its box or, on a small screen, within a finger's reach of its body;
  /// where boxes overlap (the 1.5x ant and housefly boxes are large), the
  /// one whose body is nearest.
  _Body? bodyAt(Offset p, double touch, {bool Function(_Body b)? test}) {
    final cam = camera();
    final (lo, hi) = _hitBoxes[scenario];
    _Body? best;
    var bestD = double.infinity;
    for (final b in bodies) {
      if (identical(b, held) || (test != null && !test(b))) continue;
      final xf = this.xf(b);
      final rect = cam.boxRect(xf, lo, hi);
      final (min, max) = b.kind.extent;
      final c = cam.p(xf.apply((min + max) * 0.5));
      final d = (p - c).distance;
      if ((rect.contains(p) || d <= touch) && d < bestD) {
        best = b;
        bestD = d;
      }
    }
    return best;
  }

  /// HTML `handleUp` zone test for an animal released at [pos] that
  /// started at [home].
  _Zone? zoneOf(_V pos, _V home) {
    if ((pos - home).length <= _minMove) return null;
    if (pos.y >= _airFrom) return _Zone.air;
    if (pos.x < -_zoneSplit) return _Zone.ground;
    if (pos.x > _zoneSplit) return _Zone.water;
    return null;
  }

  /// HTML `handleUp` success: the animal snaps into its zone and starts to
  /// move.
  void place(_Body b) {
    switch (b.kind) {
      case _Kind.goat:
        b.pos = _goatSpot;
      case _Kind.ant:
        b.pos = _antSpot;
      case _Kind.fish:
        b.pos = _V(
          _pondCenter.x + _random.nextDouble() * 4 - 2,
          _fishY,
          _pondCenter.z + _random.nextDouble() * 2 - 1,
        );
      case _Kind.pigeon:
      case _Kind.fly:
        b
          ..pos = _V(b.pos.x, _flyHeightS1, b.pos.z)
          ..yaw = _faceRight;
    }
    b
      ..animating = true
      ..done = true
      ..returnStart = -1;
  }

  /// A body-part card joined to [b] (HTML `lineFish = true` …).
  void connect(_Body b) {
    b
      ..done = true
      ..animating = true
      ..shakeStart = -1;
  }

  // ------------------------------------------ plain readouts for the tests

  /// Design point of a named place in the current framing (used by the
  /// widget tests): an animal (`goat`, `fish`, `pigeon`, `ant`, `fly`, at
  /// its hit box) or a zone label (`ground`, `water`, `air`).
  Offset anchor(String id) {
    final cam = camera();
    for (final b in bodies) {
      if (b.kind.name == id) {
        return cam.p(xf(b).apply(const _V(0, 0.5, 0)));
      }
    }
    for (final z in _Zone.values) {
      if (z.name == id) return cam.p(z.labelAt);
    }
    return _designCenter;
  }

  /// Names of the animals placed (S1) or connected (S2).
  List<String> get doneNames => [
    for (final b in bodies)
      if (b.done) b.kind.name,
  ];
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

/// Top-left of a label chip of [size] centred on its anchor (HTML sprites
/// are centred on their position).
Offset _chipOffset(Size size) => Offset(-size.width / 2, -size.height / 2);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on an animal waiting on the shelf ([canGrab]), so other drags still pan
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

/// One dotted connection line in the lines layer: start, end and colour.
typedef _Link = (Offset, Offset, Color);

class _AnimalMovementLabState
    extends State<Ch2A5ClassifyingAnimalsBasedOnMovementAndBodyPartsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards; the scene in design coordinates; the S2 card
  /// column, its cards and the lines layer.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a5-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch2-a5-design');
  final GlobalKey _cardsKey = GlobalKey(debugLabel: 'ch2-a5-cards');
  final GlobalKey _linksKey = GlobalKey(debugLabel: 'ch2-a5-links');
  final Map<_Part, GlobalKey> _cardKeys = {
    for (final p in _Part.values)
      p: GlobalKey(debugLabel: 'ch2-a5-card-${p.name}'),
  };

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

  /// The animal the current pointer drags, the scenario it was picked up
  /// in, the drag plane's point and the grab's offset on that plane.
  _Body? _grab;
  int _grabScenario = -1;
  _V _planeAt = _V.zero;
  _V _grabOffset = _V.zero;

  /// Where a line dragged from a card is (global), while it is dragged.
  Offset? _linkPointer;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// HTML `#s2-cards-container`: shown in Scenario 2.
  bool get _cardsShown => _lab.isLabActive && _scene.scenario == 1;

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

  /// HTML `animate()` + `TWEEN.update()`; then one repaint of the canvas
  /// and of the lines layer.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
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

  /// Fits the scenario's shelf, zones, podium, animals and labels into the
  /// part of the canvas no card covers: the tool column, the HUD (sidebar
  /// open), the floating mission card (sidebar collapsed) and the S2
  /// body-part cards. Never while an animal is held, so the scene does not
  /// move under the finger.
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
    if (_cardsShown) {
      final box = _cardsKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize && box.attached) {
        hard.add(
          Rect.fromPoints(
            box.localToGlobal(Offset.zero) - origin,
            box.localToGlobal(box.size.bottomRight(Offset.zero)) - origin,
          ),
        );
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

  /// What the learner must see (HTML camera, zoom 1): S1 the shelf with
  /// its animals, most of the tree, the three zones with the spots the
  /// animals go to; S2 the animals on the podium (fliers at their hovering
  /// height); and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final sc = _scene.scenario;
    final cam = _Cam(sc, _Framing.base);
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

    void chip(_V at, String text) {
      final size = _cache.chipSize(text);
      items.add((cam.p(at), _chipOffset(size) & size));
    }

    if (sc == 0) {
      box(const _V(-7, 1.8, -4.25), const _V(7, 4, -1.75));
      for (final k in _Kind.values) {
        chip(
          _V(k.shelfX, _shelfY + _labelLift[0] * k.size, _shelfZ),
          _t(k.labelKey),
        );
      }
      box(const _V(-9.5, 0, -2.5), const _V(-6, 5, 0));
      box(const _V(-7.4, 0, 1.8), const _V(-2.8, 1.7, 4.6));
      box(const _V(2.5, 0, 0), const _V(9.5, 1.2, 5.5));
      box(const _V(-3.3, 4.2, -3.8), const _V(3.3, 6.8, -0.2));
      for (final z in _Zone.values) {
        chip(z.labelAt, _t(z.labelKey));
      }
    } else {
      for (final k in _Kind.values) {
        final at = k.arcHome;
        final rise = k.part == _Part.wings
            ? _flyHeightS2 - _podiumTop + _hoverAmp
            : 0.0;
        box(
          _V(at.x - 0.9, at.y, at.z - 0.9),
          _V(at.x + 0.9, at.y + rise + 1.7 * k.size, at.z + 0.9),
        );
        chip(
          _V(at.x, at.y + rise + _labelLift[1] * k.size, at.z),
          _t(k.labelKey),
        );
      }
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
      _linkPointer = null;
      _cardRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// The HTML step ladder: S1 goat, fish, pigeon, then ant and housefly;
  /// S2 fins, wings, legs; then 'Review Connections'. Only the step's
  /// animals can move, so the placed / connected animals give the step.
  int _deriveStep() {
    final s = _scene;
    bool all(List<_Kind> kinds) => kinds.every(s.done);
    final ladder = s.scenario == 0
        ? const [
            [_Kind.goat],
            [_Kind.fish],
            [_Kind.pigeon],
            [_Kind.ant, _Kind.fly],
          ]
        : const [
            [_Kind.fish],
            [_Kind.pigeon, _Kind.fly],
            [_Kind.goat, _Kind.ant],
          ];
    for (var i = 0; i < ladder.length; i++) {
      if (!all(ladder[i])) return i + 1;
    }
    return s.reviewed ? ladder.length + 2 : ladder.length + 1;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
  }

  /// The scenario's animals are all placed / connected.
  bool get _allDone => _step >= _stepCounts[_scene.scenario];

  /// HTML `triggerConclusion()`: the summary with confetti.
  void _review() {
    final s = _scene;
    if (!_allDone) return;
    s
      ..reviewed = true
      ..confettiAt = s.time;
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
          // HTML `#next-sc-msg` after Scenario 1.
          showNext: sc == 0 && !_lab.completedScenarios.contains(1),
        ),
      ),
    );
  }

  /// HTML `#compare-btn-container` ('Review Connections'), shown once the
  /// scenario's animals are all placed / connected.
  List<LabAction> _actions() {
    if (!_allDone) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.check_circle,
        color: _Colors.blue600,
        foreground: _Colors.white,
        highlight: !_scene.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  /// The correct tone, or the chime once the last animal is done (HTML
  /// `triggerConclusionState`).
  void _doneTone() {
    _step = _deriveStep();
    (_allDone ? _Sound.success : _Sound.correct).play();
  }

  // ------------------------------------------------- scenario 1 gestures

  /// HTML `handleDown` (S1): a press on an animal still on the shelf.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grab != null || s.scenario != 0) return false;
    return _shelfAnimalAt(event.localPosition) != null;
  }

  /// The animal on the shelf at [p]: the HTML raycasts only the step's
  /// animal, so it wins where hit boxes overlap; any other one is found for
  /// the hint.
  _Body? _shelfAnimalAt(Offset p) {
    final s = _scene;
    return s.bodyAt(
          p,
          _touch,
          test: (b) => !b.done && b.kind.s1Step == _step,
        ) ??
        s.bodyAt(p, _touch, test: (b) => !b.done);
  }

  /// Picks up the step's animal on a drag plane through it, facing the
  /// camera, and enlarges it. The HTML only lets the step's animal move; a
  /// press on another one says which animal to drag.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (s.scenario != 0) return;
    final b = _shelfAnimalAt(d.localPosition);
    if (b == null) return;
    if (b.kind.s1Step != _step) {
      _lab.showToast(_t('wrong_s1_${_step.clamp(1, 3)}'), isError: true);
      return;
    }
    final cam = s.camera();
    b.returnStart = -1;
    _planeAt = b.pos;
    final hit = cam.onPlane(d.localPosition, _planeAt, cam.f);
    _grabOffset = hit == null ? _V.zero : hit - b.pos;
    s
      ..held = b
      ..lift(b, _liftScale);
    _grab = b;
    _grabScenario = s.scenario;
    _Sound.pickup.play();
  }

  /// HTML `handleMove`: the animal follows the finger on the drag plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final b = _grab;
    final s = _scene;
    if (b == null || _grabScenario != s.scenario) return;
    final cam = s.camera();
    final hit = cam.onPlane(d.localPosition, _planeAt, cam.f);
    if (hit == null) return;
    b.pos = hit - _grabOffset;
    s.hover = s.zoneOf(b.pos, b.home);
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`: in its zone the animal snaps into place and starts to
  /// move; anywhere else it glides back to the shelf
  /// (`playSound('error')`).
  void _release() {
    final b = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (b == null || scenario != s.scenario) return;
    s
      ..held = null
      ..hover = null
      ..lift(b, 1);
    final zone = s.zoneOf(b.pos, b.home);
    if (zone == b.kind.zone) {
      s.place(b);
      _doneTone();
      _refresh();
      return;
    }
    final moved = (b.pos - b.home).length > _minMove;
    b
      ..animating = false
      ..returnFrom = b.pos
      ..returnStart = s.time;
    _lab.showToast(
      _t(moved ? 'miss_${b.kind.name}' : 'drag_off'),
      isError: true,
    );
    _scheduleFraming();
  }

  // ------------------------------------------------- scenario 2 gestures

  /// HTML `selectCard(type)`: the card turns green and the animals that use
  /// that part pulse.
  void _selectCard(_Part part) {
    if (!_cardsShown) return;
    _Sound.click.play();
    setState(() => _scene.card = part);
  }

  /// A line dragged out of a card (the HTML's line that follows the mouse
  /// from the selected card): the card is selected.
  void _startLink(_Part part) {
    _linkPointer = null;
    _selectCard(part);
  }

  /// A line dropped on the scene at [global]: as a tap there.
  void _onCardDrop(Offset global) {
    _linkPointer = null;
    final local = labGlobalToLocal(_designKey, global);
    if (local != null) _tapAt(local);
  }

  void _onStageTapUp(TapUpDetails d) => _tapAt(d.localPosition);

  /// HTML `handleDown` (S2): the animal under [p]. The HTML raycasts only
  /// the step's animals, so they win where hit boxes overlap (the big
  /// housefly and ant boxes stand in front of the others); any other
  /// animal is found for the feedback.
  void _tapAt(Offset p) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1) return;
    final b =
        s.bodyAt(p, _touch, test: (b) => !b.done && b.kind.s2Step == _step) ??
        s.bodyAt(p, _touch);
    if (b != null) _tapAnimal(b);
  }

  /// HTML connection logic: an animal that moves with the selected card's
  /// part is joined to it (`playSound('success')`) and starts to move; any
  /// other one shakes (`playSound('error')`). The HTML only reacts to the
  /// step's animals; here the others explain what to do instead.
  void _tapAnimal(_Body b) {
    final s = _scene;
    final card = s.card;
    if (card == null) {
      _lab.showToast(_t('pick_card'), isError: true);
      return;
    }
    if (b.done) return;
    if (b.kind.part != card) {
      b.shakeStart = s.time;
      _lab.showToast(_t('wrong_${b.kind.name}'), isError: true);
      return;
    }
    if (b.kind.s2Step != _step) {
      _lab.showToast(_t('not_yet_s2_${_step.clamp(1, 2)}'), isError: true);
      return;
    }
    s.connect(b);
    _doneTone();
    _refresh();
  }

  /// HTML `drawS2Lines()`: a dotted line from each card's right edge to
  /// every animal joined to it, and the green line from the selected card
  /// to the finger while a line is dragged; in the lines layer's
  /// coordinates (read while painting, after layout).
  List<_Link> _linkSegments() {
    final out = <_Link>[];
    final s = _scene;
    if (!_cardsShown) return out;
    final layer = _linksKey.currentContext?.findRenderObject();
    final stage = _designKey.currentContext?.findRenderObject();
    if (layer is! RenderBox ||
        !layer.attached ||
        !layer.hasSize ||
        stage is! RenderBox ||
        !stage.attached) {
      return out;
    }
    Offset? cardEdge(_Part part) {
      final box = _cardKeys[part]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) return null;
      return layer.globalToLocal(
        box.localToGlobal(Offset(box.size.width, box.size.height / 2)),
      );
    }

    final cam = s.camera();
    for (final b in s.bodies) {
      if (!b.done) continue;
      final start = cardEdge(b.kind.part);
      if (start == null) continue;
      final end = layer.globalToLocal(stage.localToGlobal(cam.p(b.pos)));
      out.add((start, end, b.kind.part.color));
    }
    final pointer = _linkPointer;
    final card = s.card;
    if (pointer != null && card != null) {
      final start = cardEdge(card);
      if (start != null) {
        out.add((start, layer.globalToLocal(pointer), _Colors.activeLine));
      }
    }
    return out;
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
        final inset = labOverlayInsets(context, _lab);
        final open = _lab.isSidebarOpen;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.pets,
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
            // HTML `#line-svg` (under the cards, above the scene).
            if (_cardsShown)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: _linksKey,
                    painter: _LinkPainter(
                      links: _linkSegments,
                      scale: s,
                      repaint: _frame,
                    ),
                  ),
                ),
              ),
            // HTML `#s2-cards-container` (left of the canvas, centred).
            if (_cardsShown)
              Positioned(
                key: const ValueKey('ch2a5-cards'),
                left: inset.left + 8 * s,
                top: inset.top,
                bottom: inset.bottom + (open ? _hudBand * s : 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(fit: BoxFit.scaleDown, child: _cards(s, p)),
                ),
              ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  /// HTML "Select a part" header and the Fins, Wings and Legs cards. Each
  /// card can be tapped, or dragged to draw its line onto an animal.
  Widget _cards(double s, LabPalette p) {
    final header = _t('select_part');
    return Column(
      key: _cardsKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _partCardW * s,
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: _Colors.slate800.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: _Colors.slate700),
          ),
          child: Text(
            header.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              color: _Colors.slate300,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: labLetterSpacing(header, 0.8),
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        for (final part in _Part.values) ...[
          SizedBox(height: _partCardGap * s),
          _card(part, s, p),
        ],
      ],
    );
  }

  Widget _card(_Part part, double s, LabPalette p) {
    final label = _t(part.key);
    final selected = _scene.card == part;
    Widget face({Key? key}) => _PartCard(
      part: part,
      label: label,
      selected: selected,
      isDark: p.isDark,
      scale: s,
      boxKey: key,
    );
    return Draggable<_Part>(
      data: part,
      maxSimultaneousDrags: _cardsShown ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _startLink(part),
      onDragUpdate: (d) => _linkPointer = d.globalPosition,
      onDragEnd: (_) => _linkPointer = null,
      feedback: const _LinkTip(),
      childWhenDragging: face(key: _cardKeys[part]),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: LabInk.clear,
          child: InkWell(
            key: ValueKey('ch2a5-card-${part.name}'),
            borderRadius: BorderRadius.circular(16 * s),
            onTap: () => _selectCard(part),
            child: face(key: _cardKeys[part]),
          ),
        ),
      ),
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
          child: DragTarget<_Part>(
            onWillAcceptWithDetails: (_) => _cardsShown,
            onAcceptWithDetails: (d) => _onCardDrop(d.offset),
            builder: (context, candidates, rejected) => RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              // Drags and taps on the scene are not screen-reader actions;
              // the scene is announced by its label instead.
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
                if (_scene.scenario == 1)
                  TapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer
                      >(
                        () => TapGestureRecognizer(debugOwner: this),
                        (r) => r.onTapUp = _onStageTapUp,
                      ),
              },
              child: Semantics(
                image: true,
                label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                child: RepaintBoundary(
                  key: _designKey,
                  child: CustomPaint(
                    key: const ValueKey('ch2a5-scene'),
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
          ),
        );
      },
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and observation (and the HTML explanation). The
/// current step is open, done steps show a tick and can be re-opened,
/// future steps are dimmed. A step's focus, observation and explanation
/// are shown once the step is done (the HTML showed them before the
/// learner had seen them).
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
    final tone = current ? accent : (past ? p.info : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.info.withValues(alpha: 0.5) : p.cardBorder);
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
                                    ? p.info.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
                                : (past
                                      ? p.info.withValues(alpha: 0.5)
                                      : p.cardBorder.withValues(alpha: dim)),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.info)
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

/// One body-part card (HTML `#card-fins` …): white / slate card with the
/// part's icon and name; the selected card turns green and grows to 110 %.
/// [boxKey] marks the card's box, where its connection lines start.
class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.part,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.scale,
    this.boxKey,
  });

  final _Part part;
  final String label;
  final bool selected;
  final bool isDark;
  final double scale;
  final Key? boxKey;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bg = selected
        ? (isDark ? _Colors.cardSelectedDark : _Colors.green50)
        : (isDark ? _Colors.slate800 : _Colors.white);
    final border = selected
        ? _Colors.green500
        : (isDark ? _Colors.slate700 : _Colors.slate300);
    return AnimatedScale(
      scale: selected ? 1.1 : 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        key: boxKey,
        width: _partCardW * s,
        height: _partCardH * s,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40 * s,
              height: 40 * s,
              child: CustomPaint(painter: _PartArtPainter(part, part.color)),
            ),
            SizedBox(height: 8 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * s),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: isDark ? _Colors.slate300 : _Colors.slate700,
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The end of a line dragged from a card: a green glowing dot centred on
/// the finger.
class _LinkTip extends StatelessWidget {
  const _LinkTip();

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: _Colors.activeLine,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: _Colors.activeLine, blurRadius: 8)],
        ),
      ),
    );
  }
}

/// HTML `#summary-visual-area`: S1 the three groups (ground movers →
/// walking / crawling, air movers → flying, water movers → swimming); S2
/// each body-part icon → its movement → its animals. The HTML's emoji
/// animals are drawn with this lab's own models. [showNext] adds the
/// HTML's "select the next scenario" note.
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
    final s = scale;
    final p = palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: scenario == 0 ? _groups() : _parts(),
        ),
        if (showNext) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              t('next_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.amber400),
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _animals(List<_Kind> kinds, double size) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < kinds.length; i++) ...[
        if (i > 0) SizedBox(width: 4 * scale),
        _AnimalIcon(kind: kinds[i], size: size),
      ],
    ],
  );

  /// S1: one bordered box per zone.
  Widget _groups() {
    final s = scale;
    final p = palette;
    Widget group(String title, Color color, List<_Kind> kinds, String move) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: p.isDark ? _Colors.slate900 : _Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.ink(color),
                fontSize: 11 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: labLetterSpacing(title, 0.4),
              ),
            ),
            SizedBox(height: 6 * s),
            _animals(kinds, 40 * s),
            SizedBox(height: 6 * s),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 3 * s),
              decoration: BoxDecoration(
                color: p.isDark ? _Colors.slate800 : _Colors.slate100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                move,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: group(t('sum_gm'), _Colors.green400, const [
              _Kind.goat,
              _Kind.ant,
            ], t('sum_wc')),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: group(t('sum_am'), _Colors.purple400, const [
              _Kind.pigeon,
              _Kind.fly,
            ], t('sum_f')),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: group(t('sum_wm'), _Colors.blue400, const [
              _Kind.fish,
            ], t('sum_s')),
          ),
        ],
      ),
    );
  }

  /// S2: body-part icon → movement → animals, in three columns.
  Widget _parts() {
    final s = scale;
    final p = palette;
    Widget column(_Part part, String move, List<_Kind> kinds) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48 * s,
            height: 48 * s,
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: part.deep.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: part.color, width: 2),
            ),
            child: CustomPaint(painter: _PartArtPainter(part, part.light)),
          ),
          SizedBox(height: 6 * s),
          Text(
            '➔ $move',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4 * s),
          _animals(kinds, 36 * s),
        ],
      );
    }

    Widget divider() => Container(
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 6 * s),
      color: p.cardBorder,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: column(_Part.fins, t('sum_s'), const [_Kind.fish])),
          divider(),
          Expanded(
            child: column(_Part.wings, t('sum_f'), const [
              _Kind.pigeon,
              _Kind.fly,
            ]),
          ),
          divider(),
          Expanded(
            child: column(_Part.legs, t('sum_wc'), const [
              _Kind.goat,
              _Kind.ant,
            ]),
          ),
        ],
      ),
    );
  }
}

/// A still picture of one of the lab's animals (summary popup).
class _AnimalIcon extends StatelessWidget {
  const _AnimalIcon({required this.kind, required this.size});

  final _Kind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AnimalIconPainter(kind)),
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
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// The fogged ground (its shader follows the framing).
  final Paint gradient = Paint();
  final Path path = Path();
}

/// What the painters make once and reuse: pens, the shaded-ball shaders
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

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.chipText,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Size of a label chip with [text].
  Size chipSize(String text) {
    final a = label(text);
    return Size(
      a.width + 2 * _chipPadX * _labelSize,
      a.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle, lit from the upper right like the HTML key light. The
  /// colour's alpha (the clouds) is kept.
  Paint ball(Color c) => _balls[c.toARGB32()] ??= () {
    final solid = c.withValues(alpha: 1);
    final lit = _lit(solid, _viewNormal);
    return Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.4),
        1.4,
        [
          labShade(lit, 0.3).withValues(alpha: c.a),
          lit.withValues(alpha: c.a),
          labShade(solid, -0.35).withValues(alpha: c.a),
        ],
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
    _balls.clear();
  }
}

/// HTML key light `DirectionalLight(0xffffff, 0.8)` at (10, 20, 10) and
/// fill light `DirectionalLight(0x90b0d0, 0.4)` at (-10, 10, -10),
/// normalised, over `AmbientLight(0xffffff, 0.7)`.
const _V _keyLight = _V(0.4082, 0.8165, 0.4082);
const _V _fillLightDir = _V(-0.5774, 0.5774, -0.5774);
const double _ambient = 0.7;
const double _keyPower = 0.8;
const double _fillPower = 0.4;

/// The side of a sphere that faces the cameras (both look down a little).
const _V _viewNormal = _V(0, 0.349, 0.937);

/// MeshStandardMaterial look: ambient light plus the key and fill lights'
/// Lambert terms on a face with normal [n].
Color _lit(Color c, _V n, {double alpha = 1}) {
  final k = _ambient + _keyPower * math.max(0.0, n.dot(_keyLight));
  final f = _fillPower * math.max(0.0, n.dot(_fillLightDir));
  const fl = _Colors.fillLight;
  return Color.from(
    alpha: c.a * alpha,
    red: math.min(1.0, c.r * (k + f * fl.r)),
    green: math.min(1.0, c.g * (k + f * fl.g)),
    blue: math.min(1.0, c.b * (k + f * fl.b)),
  );
}

/// Semi-axes and angle of the ellipse spanned by the screen images [a],
/// [b], [c] of an ellipsoid's three semi-axes.
(double, double, double) _ellipse(Offset a, Offset b, Offset c) {
  final sxx = a.dx * a.dx + b.dx * b.dx + c.dx * c.dx;
  final syy = a.dy * a.dy + b.dy * b.dy + c.dy * c.dy;
  final sxy = a.dx * a.dy + b.dx * b.dy + c.dx * c.dy;
  final mid = (sxx + syy) / 2;
  final half = (sxx - syy) / 2;
  final dev = math.sqrt(half * half + sxy * sxy);
  return (
    math.sqrt(math.max(0.0, mid + dev)),
    math.sqrt(math.max(0.0, mid - dev)),
    0.5 * math.atan2(2 * sxy, sxx - syy),
  );
}

/// Convex hull of [pts] (monotone chain), counter-clockwise.
List<Offset> _convexHull(List<Offset> pts) {
  if (pts.length < 3) return pts;
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

/// Ring segments of a drawn cylinder or cone, and of the pond and podium.
const int _ringSegments = 12;
const int _discSegments = 48;

/// A cylinder thinner than this (design px) is drawn as a line.
const double _thinPx = 0.8;

/// Mesh drawing in one camera's projection. A model's meshes are queued
/// with [later] and painted far to near by [flush] (the HTML depth buffer).
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  final List<(double, int, VoidCallback)> _queue = [];

  _Pens get pens => cache.pens;

  /// The outline of a DodecahedronGeometry seen from the front: a decagon
  /// with the front pentagon's facet edges (unit radius).
  static final Path _decagon = () {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5 - math.pi / 2;
      final o = Offset(math.cos(a), math.sin(a));
      if (i == 0) {
        p.moveTo(o.dx, o.dy);
      } else {
        p.lineTo(o.dx, o.dy);
      }
    }
    return p..close();
  }();
  static final Path _facets = () {
    final p = Path();
    Offset at(double r, int i) {
      final a = i * math.pi / 5 - math.pi / 2;
      return Offset(math.cos(a) * r, math.sin(a) * r);
    }

    for (var i = 0; i < 10; i += 2) {
      final inner = at(0.58, i + 1);
      final next = at(0.58, i + 3);
      p
        ..moveTo(inner.dx, inner.dy)
        ..lineTo(next.dx, next.dy)
        ..moveTo(inner.dx, inner.dy)
        ..lineTo(at(1, i + 1).dx, at(1, i + 1).dy);
    }
    return p;
  }();

  /// Queues [draw] at the depth of [at].
  void later(_V at, VoidCallback draw) =>
      _queue.add((cam.depth(at), _queue.length, draw));

  /// Paints the queued meshes, far to near.
  void flush() {
    _queue.sort((a, b) {
      final c = b.$1.compareTo(a.$1);
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
    for (final d in _queue) {
      d.$3();
    }
    _queue.clear();
  }

  /// [pts] cut where they come closer to the camera than [_clipDepth].
  List<_V> _clipNear(List<_V> pts) {
    double d(_V w) => cam.depth(w) - _clipDepth;
    if (pts.every((w) => d(w) >= 0)) return pts;
    final out = <_V>[];
    for (var i = 0; i < pts.length; i++) {
      final a = pts[i], b = pts[(i + 1) % pts.length];
      final da = d(a), db = d(b);
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) out.add(_V.lerp(a, b, da / (da - db)));
    }
    return out;
  }

  void _trace(Path path, List<Offset> pts) {
    path.reset();
    for (var i = 0; i < pts.length; i++) {
      if (i == 0) {
        path.moveTo(pts[i].dx, pts[i].dy);
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    path.close();
  }

  /// A world polygon filled with [color].
  void poly(List<_V> pts, Color color) {
    final clipped = _clipNear(pts);
    if (clipped.length < 3) return;
    _trace(pens.path, [for (final w in clipped) cam.p(w)]);
    canvas.drawPath(pens.path, pens.fill..color = color);
  }

  /// The convex outline of the screen points [pts], filled with [paint].
  void hull(List<Offset> pts, Paint paint) {
    final h = _convexHull(pts);
    if (h.length < 3) return;
    _trace(pens.path, h);
    canvas.drawPath(pens.path, paint);
  }

  /// A flat face (PlaneGeometry) with [normal], lit on the side the camera
  /// sees (the wings are double-sided).
  void face(List<_V> pts, Color color, _V normal, {double alpha = 1}) {
    var n = normal.unit;
    if (n.dot(cam.eye - pts.first) < 0) n = -n;
    poly(pts, _lit(color, n, alpha: alpha));
  }

  /// HTML `PlaneGeometry(40, 30)` floor: lit, fading into the fog colour
  /// towards its far edge (`FogExp2`).
  void ground(Color color) {
    final lit = _lit(color, _V.up);
    final pts = _clipNear(const [
      _V(-_floorHalfX, 0, -_floorHalfZ),
      _V(_floorHalfX, 0, -_floorHalfZ),
      _V(_floorHalfX, 0, _floorHalfZ),
      _V(-_floorHalfX, 0, _floorHalfZ),
    ]);
    if (pts.length < 3) return;
    _trace(pens.path, [for (final w in pts) cam.p(w)]);
    double fog(_V w) {
      final d = (w - cam.eye).length * _fogDensity;
      return 1 - math.exp(-d * d);
    }

    final far = _V(cam.eye.x, 0, -_floorHalfZ);
    final near = _V(cam.eye.x, 0, cam.eye.z - 12);
    pens.gradient.shader = ui.Gradient.linear(cam.p(far), cam.p(near), [
      Color.lerp(lit, _Colors.fog, fog(far))!,
      Color.lerp(lit, _Colors.fog, fog(near))!,
    ]);
    canvas.drawPath(pens.path, pens.gradient);
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      _trace(pens.path, [
        for (final k in face.corners)
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
      ]);
      canvas.drawPath(pens.path, pens.fill..color = _lit(color, n));
      if (edge > 0) {
        canvas.drawPath(
          pens.path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge),
        );
      }
    }
  }

  /// A SphereGeometry stretched along the world semi-axes [a], [b], [e]
  /// at [c]: shaded, or [flat] (MeshBasicMaterial).
  void ellipsoid(_V c, _V a, _V b, _V e, Color color, {bool flat = false}) {
    final (rx, ry, angle) = _ellipse(cam.dp(c, a), cam.dp(c, b), cam.dp(c, e));
    _oval(
      cam.p(c),
      rx,
      ry,
      angle,
      flat ? (pens.fill..color = color) : cache.ball(color),
    );
  }

  /// A unit circle drawn as an [rx] x [ry] ellipse turned by [angle]; the
  /// axes are flipped so a shaded ball keeps its highlight up and to the
  /// right.
  void _oval(Offset o, double rx, double ry, double angle, Paint paint) {
    if (rx < 0.05) return;
    final ca = math.cos(angle), sa = math.sin(angle);
    var best = -double.infinity;
    var fx = 1.0, fy = 1.0;
    for (final sx in const [1.0, -1.0]) {
      for (final sy in const [1.0, -1.0]) {
        final hx = 0.3 * sx * rx, hy = -0.4 * sy * ry;
        final score = 0.6 * (hx * ca - hy * sa) - 0.8 * (hx * sa + hy * ca);
        if (score > best) {
          best = score;
          fx = sx;
          fy = sy;
        }
      }
    }
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(angle);
    canvas.scale(math.max(0.4, rx) * fx, math.max(0.4, ry) * fy);
    canvas.drawCircle(Offset.zero, 1, paint);
    canvas.restore();
  }

  /// A CylinderGeometry ([rTop] 0: a ConeGeometry) of height [h] along the
  /// local y axis of [mesh], filled with its lit side.
  void cylinder(_Xf mesh, double rTop, double rBottom, double h, Color color) {
    final top = mesh.apply(_V(0, h / 2, 0));
    final bottom = mesh.apply(_V(0, -h / 2, 0));
    final radial =
        (mesh.dir(const _V(1, 0, 0)).length +
            mesh.dir(const _V(0, 0, 1)).length) /
        2;
    final px = math.max(rTop, rBottom) * radial * cam.scaleAt(mesh.t);
    final axis = (top - bottom).unit;
    final toEye = (cam.eye - mesh.t).unit;
    final side = toEye - axis * toEye.dot(axis);
    final paint = pens.fill
      ..color = _lit(color, side.length < 1e-6 ? toEye : side.unit);
    if (px < _thinPx) {
      canvas.drawLine(
        cam.p(bottom),
        cam.p(top),
        pens.stroke
          ..strokeWidth = math.max(_thinPx, 2 * px)
          ..color = paint.color,
      );
      return;
    }
    final pts = <Offset>[];
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final c = math.cos(a), s = math.sin(a);
      if (rTop > 0) pts.add(cam.p(mesh.apply(_V(rTop * c, h / 2, rTop * s))));
      if (rBottom > 0) {
        pts.add(cam.p(mesh.apply(_V(rBottom * c, -h / 2, rBottom * s))));
      }
    }
    if (rTop <= 0) pts.add(cam.p(top));
    if (rBottom <= 0) pts.add(cam.p(bottom));
    hull(pts, paint);
  }

  /// A wide, short upright cylinder (pond, podium): its side, then its top
  /// disc, with the given (already lit) colours.
  void drum(
    _V c,
    double rTop,
    double rBottom,
    double h,
    Color side,
    Color top,
  ) {
    final rim = <Offset>[];
    final pts = <Offset>[];
    for (var i = 0; i < _discSegments; i++) {
      final a = i * 2 * math.pi / _discSegments;
      final cs = math.cos(a), sn = math.sin(a);
      final t = cam.p(_V(c.x + rTop * cs, c.y + h / 2, c.z + rTop * sn));
      rim.add(t);
      pts
        ..add(t)
        ..add(cam.p(_V(c.x + rBottom * cs, c.y - h / 2, c.z + rBottom * sn)));
    }
    hull(pts, pens.fill..color = side);
    hull(rim, pens.fill..color = top);
  }

  /// A DodecahedronGeometry of radius [r] (leaves, rocks): a shaded decagon
  /// with faint facet edges.
  void gem(_V c, double r, Color color) {
    final o = cam.p(c);
    final k = r * cam.scaleAt(c) * 0.95;
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(k, k);
    canvas.drawPath(_decagon, cache.ball(color));
    canvas.drawPath(
      _facets,
      pens.stroke
        ..strokeWidth = 1.2 / k
        ..color = labShade(color, -0.45).withValues(alpha: 0.3),
    );
    canvas.restore();
  }

  /// Soft shadow: an ellipse with the horizontal half axes [a] and [b] on
  /// the plane through [c] (PCF soft shadows).
  void shadow(_V c, _V a, _V b, {double opacity = 1}) {
    final pts = <Offset>[];
    for (var i = 0; i < 24; i++) {
      final t = i * 2 * math.pi / 24;
      pts.add(cam.p(c + a * math.cos(t) + b * math.sin(t)));
    }
    hull(
      pts,
      pens.shadow
        ..color = _Colors.shadow.withValues(
          alpha: _Colors.shadow.a * opacity.clamp(0.0, 1.0),
        ),
    );
  }
}

/// A Three.js object (group) drawn through [xf]: its meshes are queued on
/// [g] at their depth.
class _Model {
  const _Model(this.g, this.xf);

  final _Gfx g;
  final _Xf xf;

  /// A child `THREE.Group` at [at], turned by the Euler angles.
  _Model group(_V at, {double rx = 0, double ry = 0, double rz = 0}) =>
      _Model(g, xf.child(at, rx: rx, ry: ry, rz: rz));

  /// `SphereGeometry(r)` at [at], scaled by [scale].
  void sphere(
    _V at,
    double r,
    Color color, {
    _V scale = _V.one,
    bool flat = false,
  }) {
    final mesh = xf.child(at, scale: scale);
    g.later(
      mesh.t,
      () => g.ellipsoid(
        mesh.t,
        mesh.dir(_V(r, 0, 0)),
        mesh.dir(_V(0, r, 0)),
        mesh.dir(_V(0, 0, r)),
        color,
        flat: flat,
      ),
    );
  }

  /// `CylinderGeometry(rTop, rBottom, h)` at [at].
  void cylinder(
    _V at,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
    _V scale = _V.one,
  }) {
    final mesh = xf.child(at, rx: rx, ry: ry, rz: rz, scale: scale);
    g.later(mesh.t, () => g.cylinder(mesh, rTop, rBottom, h, color));
  }

  /// `ConeGeometry(r, h)` at [at].
  void cone(
    _V at,
    double r,
    double h,
    Color color, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
    _V scale = _V.one,
  }) => cylinder(at, 0, r, h, color, rx: rx, ry: ry, rz: rz, scale: scale);

  /// `PlaneGeometry(w, h)` at [at], turned by [rx].
  void plane(
    _V at,
    double w,
    double h,
    Color color, {
    double rx = 0,
    double alpha = 1,
  }) {
    final mesh = xf.child(at, rx: rx);
    g.later(
      mesh.t,
      () => g.face(
        [
          mesh.apply(_V(-w / 2, -h / 2, 0)),
          mesh.apply(_V(w / 2, -h / 2, 0)),
          mesh.apply(_V(w / 2, h / 2, 0)),
          mesh.apply(_V(-w / 2, h / 2, 0)),
        ],
        color,
        mesh.dir(const _V(0, 0, 1)),
        alpha: alpha,
      ),
    );
  }
}

/// Draws [kind]'s model (HTML `createGoat()` …) through [m], at HTML clock
/// [t]; [anim] is `userData.isAnimating`.
void _drawModel(_Model m, _Kind kind, double t, bool anim) {
  switch (kind) {
    case _Kind.goat:
      _goat(m, t, anim);
    case _Kind.fish:
      _fish(m, t, anim);
    case _Kind.pigeon:
      _pigeon(m, t, anim);
    case _Kind.ant:
      _ant(m, t, anim);
    case _Kind.fly:
      _fly(m, t, anim);
  }
}

/// `createGoat()`: body, neck, head group (head, snout, horns, ears, eyes),
/// tail and four legs. Walking: the legs swing about their middles
/// (`rotation.x = sin(time·10 + i)·0.3`) and the head nods (`rotation.z =
/// sin(time·2)·0.1`).
void _goat(_Model m, double t, bool anim) {
  const white = _Colors.goat;
  const dark = _Colors.goatDark;
  m
    ..sphere(const _V(0, 0.8, 0), 0.35, white, scale: const _V(1, 0.8, 1.8))
    ..cylinder(const _V(0, 1.1, 0.5), 0.15, 0.2, 0.4, white, rx: math.pi / 4);
  m.group(const _V(0, 1.3, 0.7), rz: anim ? math.sin(t * 2) * 0.1 : 0)
    ..sphere(_V.zero, 0.2, white, scale: const _V(1, 0.8, 1.5))
    ..sphere(const _V(0, 0, 0.25), 0.1, dark, scale: const _V(1, 0.8, 1))
    ..cone(const _V(0.1, 0.15, -0.1), 0.03, 0.3, dark, rx: -0.2, rz: -0.2)
    ..cone(const _V(-0.1, 0.15, -0.1), 0.03, 0.3, dark, rx: -0.2, rz: 0.2)
    ..cone(const _V(0.2, 0, -0.1), 0.05, 0.25, white, rz: -math.pi / 2 - 0.2)
    ..cone(const _V(-0.2, 0, -0.1), 0.05, 0.25, white, rz: math.pi / 2 + 0.2)
    ..sphere(const _V(0.15, 0.05, 0.1), 0.04, _Colors.eye, flat: true)
    ..sphere(const _V(-0.15, 0.05, 0.1), 0.04, _Colors.eye, flat: true);
  m.cone(const _V(0, 0.9, -0.6), 0.05, 0.2, white, rx: -math.pi / 4);
  for (var i = 0; i < 4; i++) {
    m.cylinder(
      _V(i.isEven ? -0.15 : 0.15, 0.3, i < 2 ? 0.4 : -0.4),
      0.05,
      0.03,
      0.6,
      white,
      rx: anim ? math.sin(t * 10 + i) * 0.3 : 0,
    );
  }
}

/// `createFish()`: body, flat tail fan, top and side fins, eyes. Swimming:
/// the tail beats (`rotation.z = −π/2 + sin(time·15)·0.3`). The HTML eyes
/// sit just inside the body mesh; here they show.
void _fish(_Model m, double t, bool anim) {
  const fin = _Colors.fishFin;
  m
    ..sphere(
      const _V(0, 0.4, 0),
      0.3,
      _Colors.fish,
      scale: const _V(1, 1.5, 2.5),
    )
    ..cone(
      const _V(0, 0.4, -0.9),
      0.3,
      0.5,
      fin,
      scale: const _V(0.1, 1, 1),
      rx: math.pi / 2,
      rz: anim ? -math.pi / 2 + math.sin(t * 15) * 0.3 : 0,
    )
    ..cone(const _V(0, 0.9, 0), 0.15, 0.4, fin, scale: const _V(0.2, 1, 1.5))
    ..cone(const _V(0.3, 0.2, 0.2), 0.1, 0.3, fin, ry: -0.5, rz: math.pi / 2)
    ..cone(const _V(-0.3, 0.2, 0.2), 0.1, 0.3, fin, ry: 0.5, rz: -math.pi / 2);
  for (final side in const [1.0, -1.0]) {
    m.group(_V(0.15 * side, 0.5, 0.5), ry: math.pi / 4 * side)
      ..sphere(_V.zero, 0.06, _Colors.eyeWhite, flat: true)
      ..sphere(_V(0.04 * side, 0, 0), 0.03, _Colors.eye, flat: true);
  }
}

/// `createPigeon()`: body, head, beak, eyes, tail and two wing planes.
/// Flying: the wings flap (`rotation.z = ±sin(time·20)·0.5`).
void _pigeon(_Model m, double t, bool anim) {
  const dark = _Colors.pigeonDark;
  m
    ..sphere(
      const _V(0, 0.6, 0),
      0.25,
      _Colors.pigeon,
      scale: const _V(1, 1, 1.8),
    )
    ..sphere(const _V(0, 0.9, 0.35), 0.18, dark)
    ..cone(const _V(0, 0.9, 0.55), 0.05, 0.15, _Colors.beak, rx: math.pi / 2)
    ..sphere(const _V(0.15, 0.95, 0.4), 0.03, _Colors.eye, flat: true)
    ..sphere(const _V(-0.15, 0.95, 0.4), 0.03, _Colors.eye, flat: true)
    ..plane(const _V(0, 0.6, -0.6), 0.3, 0.4, dark, rx: -math.pi / 2 - 0.2);
  final flap = anim ? math.sin(t * 20) * 0.5 : 0.0;
  m
      .group(const _V(0.25, 0.6, 0), rz: flap)
      .plane(const _V(0.2, 0, 0), 0.4, 0.8, dark, rx: -math.pi / 2);
  m
      .group(const _V(-0.25, 0.6, 0), rz: -flap)
      .plane(const _V(-0.2, 0, 0), 0.4, 0.8, dark, rx: -math.pi / 2);
}

/// `createAnt()`: head, thorax, abdomen, antennae and six legs. Crawling:
/// the legs swing at the hip (`rotation.x = sin(time·10 + i)·0.3`).
void _ant(_Model m, double t, bool anim) {
  const by = 0.2;
  const dark = _Colors.antDark;
  m
    ..sphere(const _V(0, by + 0.05, 0.35), 0.12, _Colors.ant)
    ..sphere(const _V(0, by, 0.1), 0.1, _Colors.ant, scale: const _V(1, 1, 1.5))
    ..sphere(
      const _V(0, by + 0.05, -0.25),
      0.16,
      dark,
      scale: const _V(1, 1, 1.4),
    )
    ..cylinder(
      const _V(0.05, by + 0.15, 0.45),
      0.01,
      0.01,
      0.2,
      dark,
      rx: math.pi / 4,
      rz: -0.3,
    )
    ..cylinder(
      const _V(-0.05, by + 0.15, 0.45),
      0.01,
      0.01,
      0.2,
      dark,
      rx: math.pi / 4,
      rz: 0.3,
    );
  for (var i = 0; i < 6; i++) {
    final z = i < 2 ? 0.2 : (i < 4 ? 0.1 : 0.0);
    final left = i.isEven;
    final x = left ? 0.1 : -0.1;
    m
        .group(_V(x, by - 0.05, z), rx: anim ? math.sin(t * 10 + i) * 0.3 : 0)
        .cylinder(
          _V(x, -0.1, 0),
          0.015,
          0.01,
          0.25,
          dark,
          rz: left ? -0.5 : 0.5,
        );
  }
}

/// `createHousefly()`: body, head, red eyes, two see-through wings and six
/// legs. Flying: the wings buzz (`rotation.z = ±(sin(time·20)·0.5 − 0.3)`).
void _fly(_Model m, double t, bool anim) {
  const by = 0.25;
  const body = _Colors.fly;
  m
    ..sphere(const _V(0, by, 0), 0.18, body, scale: const _V(1, 1, 1.4))
    ..sphere(const _V(0, by, 0.25), 0.1, body)
    ..sphere(
      const _V(0.08, by + 0.05, 0.28),
      0.06,
      _Colors.flyEye,
      scale: const _V(1, 1.2, 0.8),
    )
    ..sphere(
      const _V(-0.08, by + 0.05, 0.28),
      0.06,
      _Colors.flyEye,
      scale: const _V(1, 1.2, 0.8),
    );
  final flap = anim ? math.sin(t * 20) * 0.5 : 0.0;
  final tilt = anim ? 0.3 : 0.0;
  m
      .group(const _V(0.1, by + 0.15, 0), rz: flap - tilt)
      .plane(
        const _V(0.1, 0, -0.15),
        0.2,
        0.4,
        _Colors.flyWing,
        rx: -math.pi / 2,
        alpha: _Colors.flyWingOpacity,
      );
  m
      .group(const _V(-0.1, by + 0.15, 0), rz: -flap + tilt)
      .plane(
        const _V(-0.1, 0, -0.15),
        0.2,
        0.4,
        _Colors.flyWing,
        rx: -math.pi / 2,
        alpha: _Colors.flyWingOpacity,
      );
  for (var i = 0; i < 6; i++) {
    final z = i < 2 ? 0.1 : (i < 4 ? 0.0 : -0.1);
    final left = i.isEven;
    final x = left ? 0.1 : -0.1;
    m
        .group(_V(x, by - 0.1, z))
        .cylinder(
          _V(x, -0.1, 0),
          0.01,
          0.005,
          0.2,
          body,
          rz: left ? -0.5 : 0.5,
        );
  }
}

/// The HTML card icons (inline SVGs in a 24 x 24 view box, clipped to it
/// like an inline `<svg>`): fins (ring and star), wings, legs (dots).
abstract final class _PartArt {
  static final Path _ring = Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10))
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8));

  static final Path _star = Path()
    ..moveTo(15.7, 15.3)
    ..relativeArcToPoint(
      const Offset(-1.4, 0),
      radius: const Radius.circular(0.99),
    )
    ..lineTo(12, 13.42)
    ..relativeLineTo(-2.3, 1.88)
    ..relativeArcToPoint(
      const Offset(-1.54, -1.28),
      radius: const Radius.circular(1),
    )
    ..relativeLineTo(0.8, -2.75)
    ..lineTo(6.2, 9.39)
    ..relativeArcToPoint(
      const Offset(0.55, -1.71),
      radius: const Radius.circular(1),
    )
    ..lineTo(9.8, 7.68)
    ..relativeLineTo(0.8, -2.75)
    ..relativeArcToPoint(const Offset(1.9, 0), radius: const Radius.circular(1))
    ..relativeLineTo(0.8, 2.75)
    ..relativeLineTo(3.05, 0)
    ..relativeArcToPoint(
      const Offset(0.55, 1.71),
      radius: const Radius.circular(1),
    )
    ..relativeLineTo(-2.76, 1.88)
    ..relativeLineTo(0.8, 2.75)
    ..arcToPoint(const Offset(15.7, 15.3), radius: const Radius.circular(1))
    ..close();

  static final Path _wing = Path()
    ..moveTo(21.9, 12.5)
    ..relativeCubicTo(-0.3, -0.2, -0.7, -0.1, -0.9, 0.2)
    ..relativeLineTo(-2.4, 3.5)
    ..relativeCubicTo(-0.2, 0.3, -0.6, 0.4, -0.9, 0.2)
    ..relativeCubicTo(-0.3, -0.2, -0.4, -0.6, -0.2, -0.9)
    ..relativeLineTo(2.4, -3.5)
    ..relativeCubicTo(0.5, -0.7, -0.1, -1.7, -1, -1.7)
    ..relativeLineTo(-3.2, 0)
    ..relativeCubicTo(-0.4, 0, -0.8, -0.3, -0.8, -0.8)
    ..lineTo(14.9, 8.7)
    ..relativeCubicTo(0, -0.4, -0.3, -0.8, -0.8, -0.8)
    ..lineTo(11, 7.9)
    ..relativeCubicTo(-0.4, 0, -0.8, 0.3, -0.8, 0.8)
    ..relativeLineTo(0, 1.8)
    ..relativeCubicTo(0, 0.4, -0.3, 0.8, -0.8, 0.8)
    ..lineTo(6.3, 11.3)
    ..relativeCubicTo(-0.9, 0, -1.5, 0.9, -1, 1.7)
    ..relativeLineTo(2.4, 3.5)
    ..relativeCubicTo(0.2, 0.3, 0.1, 0.7, -0.2, 0.9)
    ..relativeCubicTo(-0.3, 0.2, -0.7, 0.1, -0.9, -0.2)
    ..lineTo(4.2, 13)
    ..relativeCubicTo(-0.5, -0.7, -1.4, -0.7, -1.9, 0)
    ..relativeCubicTo(-0.5, 0.7, -0.5, 1.8, 0, 2.5)
    ..relativeLineTo(5.8, 8.1)
    ..relativeCubicTo(0.5, 0.7, 1.4, 0.7, 1.9, 0)
    ..relativeLineTo(1.9, -2.7)
    ..relativeCubicTo(0.2, -0.3, 0.6, -0.4, 0.9, -0.2)
    ..relativeCubicTo(0.3, 0.2, 0.4, 0.6, 0.2, 0.9)
    ..relativeLineTo(-1.9, 2.7)
    ..relativeCubicTo(-0.5, 0.7, -0.5, 1.8, 0, 2.5)
    ..relativeCubicTo(0.5, 0.7, 1.4, 0.7, 1.9, 0)
    ..relativeLineTo(5.8, -8.1)
    ..cubicTo(22.4, 14.3, 22.4, 13.2, 21.9, 12.5)
    ..close();

  static const List<(Offset, double)> _legDots = [
    (Offset(12.25, 9), 0.75),
    (Offset(14.25, 9), 0.75),
    (Offset(10.25, 9), 0.75),
    (Offset(11.75, 12.25), 2),
  ];

  /// Draws [part]'s icon into [size] with [fill].
  static void draw(Canvas canvas, _Part part, Size size, Paint fill) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 24, size.height / 24);
    switch (part) {
      case _Part.fins:
        canvas
          ..drawPath(_ring, fill)
          ..drawPath(_star, fill);
      case _Part.wings:
        canvas.drawPath(_wing, fill);
      case _Part.legs:
        for (final (c, r) in _legDots) {
          canvas.drawCircle(c, r, fill);
        }
    }
    canvas.restore();
  }
}

/// A body-part icon for widgets (cards, summary). Static pictures, so the
/// paint is shared.
class _PartArtPainter extends CustomPainter {
  const _PartArtPainter(this.part, this.color);

  final _Part part;
  final Color color;

  static final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) =>
      _PartArt.draw(canvas, part, size, _fill..color = color);

  @override
  bool shouldRepaint(covariant _PartArtPainter old) =>
      old.part != part || old.color != color;
}

/// A still animal model for the summary, seen from the front right and a
/// little above, fitted into the box.
class _AnimalIconPainter extends CustomPainter {
  const _AnimalIconPainter(this.kind);

  final _Kind kind;

  /// Pens and shading shared by every icon (static pictures).
  static final _PaintCache _cache = _PaintCache();

  /// Camera direction from the model, and the model's turn (facing right,
  /// a little towards the viewer).
  static const _V _view = _V(0.25, 0.45, 1);
  static const double _yaw = _faceRight - 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    final xf = _Xf.identity.child(_V.zero, ry: _yaw);
    final (lo, hi) = kind.extent;
    final mid = xf.apply((lo + hi) * 0.5);
    final eye = mid + _view.unit * 12;
    final box = _Cam.look(eye, mid, Offset.zero, 1).boxRect(xf, lo, hi);
    if (box.width <= 0 || box.height <= 0) return;
    final k = math.min(size.width / box.width, size.height / box.height) * 0.92;
    final cam = _Cam.look(
      eye,
      mid,
      size.center(Offset.zero) - box.center * k,
      k,
    );
    final g = _Gfx(canvas, cam, _cache);
    _drawModel(_Model(g, xf), kind, 0, false);
    g.flush();
  }

  @override
  bool shouldRepaint(covariant _AnimalIconPainter old) => old.kind != kind;
}

/// HTML `#line-svg`: the S2 connection lines, cubic curves from a card's
/// right edge to an animal (`M start C midX startY, midX endY, end`),
/// drawn as glowing dots (`stroke-width 6`, `stroke-dasharray 1,15`,
/// `drop-shadow(0 0 6px colour)`).
class _LinkPainter extends CustomPainter {
  _LinkPainter({
    required this.links,
    required this.scale,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Link> Function() links;
  final double scale;

  static final Paint _dot = Paint();
  static final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  @override
  void paint(Canvas canvas, Size size) {
    final r = 3.2 * scale;
    final step = 16 * scale;
    for (final (a, b, color) in links()) {
      final mx = (a.dx + b.dx) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d <= metric.length; d += step) {
          final at = metric.getTangentForOffset(d)?.position;
          if (at == null) continue;
          canvas
            ..drawCircle(
              at,
              r * 1.7,
              _glow..color = color.withValues(alpha: 0.5),
            )
            ..drawCircle(at, r, _dot..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinkPainter old) =>
      old.scale != scale || old.links != links;
}

/// Paints the HTML Three.js scene of the current scenario: S1 the grassy
/// field (clouds, shelf, tree, pond, rocks) with the five animals, S2 the
/// podium with them; then the labels, the held animal on top and the
/// summary's confetti.
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
    if (s.scenario == 0) {
      _paintField(g);
      if (showLabels) _paintZoneLabels(g);
    } else {
      _paintPodium(g);
    }
    _paintAnimals(g);
    if (showLabels) _paintAnimalLabels(g);
    final held = s.held;
    if (held != null) {
      _paintBody(g, held);
      if (showLabels) {
        _drawChip(
          g,
          _chipRect(g.cam.p(s.labelAt(held)), _t(held.kind.labelKey)),
          _t(held.kind.labelKey),
          _Colors.chipAnimalS1,
        );
      }
    }
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: grass, clouds, the shelf (and the shadows of the
  /// shelf and the tree), the tree, the pond and its rocks.
  void _paintField(_Gfx g) {
    g.ground(_Colors.grass);
    for (final (c, r) in _cloudPuffs) {
      g.ellipsoid(c, _V(r, 0, 0), _V(0, r, 0), _V(0, 0, r), _Colors.cloud);
    }
    g
      ..shadow(
        const _V(-11, 0.01, -4),
        const _V(2.6, 0, 0),
        const _V(0, 0, 2.4),
        opacity: 0.7,
      )
      ..shadow(
        const _V(-1, 0.01, -4),
        const _V(7.2, 0, 0),
        const _V(0, 0, 1.4),
        opacity: 0.7,
      );
    for (final x in const [-_shelfLegX, _shelfLegX]) {
      g.cylinder(
        _Xf.identity.child(_V(x, _shelfLegH / 2, _shelfZ)),
        _shelfLegR,
        _shelfLegR,
        _shelfLegH,
        _Colors.shelf,
      );
    }
    g
      ..box(_shelfCenter, _shelfSize, _Colors.shelf, edge: 0.5)
      ..cylinder(
        _Xf.identity.child(_treeBase + const _V(0, _trunkH / 2, 0)),
        _trunkTopR,
        _trunkBottomR,
        _trunkH,
        _Colors.trunk,
      )
      ..gem(_leavesAt, _leavesR, _Colors.leaves)
      ..gem(_leaves2At, _leaves2R, _Colors.leavesDark);
    // The pond (opacity 0.8 over the grass) and its rocks.
    final grass = _lit(_Colors.grass, _V.up);
    Color over(Color c) => Color.lerp(grass, c, _Colors.pondOpacity)!;
    final toEye = _V(
      g.cam.eye.x - _pondCenter.x,
      0,
      g.cam.eye.z - _pondCenter.z,
    ).unit;
    g.drum(
      _pondCenter,
      _pondR,
      _pondR,
      _pondH,
      over(_lit(_Colors.pond, toEye)),
      over(_lit(_Colors.pond, _V.up)),
    );
    for (final (c, r) in _rocks) {
      g.gem(c, r, _Colors.rock);
    }
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: dark floor and the podium.
  void _paintPodium(_Gfx g) {
    g.ground(_Colors.floor);
    final toEye = _V(
      g.cam.eye.x - _podiumCenter.x,
      0,
      g.cam.eye.z - _podiumCenter.z,
    ).unit;
    g
      ..shadow(
        const _V(3.6, 0.01, -0.4),
        const _V(5.6, 0, 0),
        const _V(0, 0, 5.6),
        opacity: 0.6,
      )
      ..drum(
        _podiumCenter,
        _podiumTopR,
        _podiumBottomR,
        _podiumH,
        _lit(_Colors.podium, toEye),
        _lit(_Colors.podium, _V.up),
      );
  }

  // ------------------------------------------------------------- animals

  /// The animals (all but the held one), far to near, over their shadows.
  void _paintAnimals(_Gfx g) {
    final s = scene;
    final order = [
      for (final b in s.bodies)
        if (!identical(b, s.held)) b,
    ]..sort((a, b) => g.cam.depth(b.pos).compareTo(g.cam.depth(a.pos)));
    for (final b in order) {
      _paintShadow(g, b);
    }
    for (final b in order) {
      _paintBody(g, b);
    }
  }

  void _paintBody(_Gfx g, _Body b) {
    final s = scene;
    _drawModel(_Model(g, s.xf(b)), b.kind, s.clock, b.animating);
    g.flush();
  }

  /// Contact shadow under an animal on the shelf, the grass or the podium
  /// (the key light casts towards -x / -z). None for the swimming fish and
  /// the fliers high in the S1 sky.
  void _paintShadow(_Gfx g, _Body b) {
    final s = scene;
    if (b.returnStart >= 0) return;
    final double surface;
    if (s.scenario == 1) {
      surface = _podiumTop;
    } else if (!b.done) {
      surface = _shelfTop;
    } else if (b.kind.part == _Part.legs) {
      surface = 0;
    } else {
      return;
    }
    final h = math.max(0.0, b.pos.y - surface);
    final (side, along) = b.kind.footprint;
    final k = b.kind.size * s.grow(b);
    final fwd = _V(math.sin(b.yaw), 0, math.cos(b.yaw));
    final right = _V(math.cos(b.yaw), 0, -math.sin(b.yaw));
    g.shadow(
      _V(b.pos.x - 0.5 * h - 0.08, surface + 0.01, b.pos.z - 0.5 * h - 0.08),
      fwd * (along * k),
      right * (side * k),
      opacity: 1 / (1 + h),
    );
  }

  // -------------------------------------------------------------- labels

  /// The S1 zone text sprites (HTML `labelDict`). They lie under the
  /// animals, so the crawling ant, the swimming fish and the circling
  /// pigeon stay in sight (the HTML draws every sprite on top, but its
  /// zone labels sat elsewhere, see [_Zone]). A label is moved up clear of
  /// the labels of the animals still on the shelf (on phones the chips are
  /// enlarged); the one the held animal is over lights up (added).
  void _paintZoneLabels(_Gfx g) {
    final s = scene;
    final taken = [
      for (final b in s.bodies)
        if (!b.done && !identical(b, s.held))
          _chipRect(g.cam.p(s.labelAt(b)), _t(b.kind.labelKey)).inflate(2),
    ];
    for (final z in _Zone.values) {
      final text = _t(z.labelKey);
      var rect = _chipRect(g.cam.p(z.labelAt), text);
      for (var i = 0; i < taken.length; i++) {
        final hits = [
          for (final r in taken)
            if (r.overlaps(rect)) r.top,
        ];
        if (hits.isEmpty) break;
        rect = rect.shift(Offset(0, hits.reduce(math.min) - rect.bottom));
      }
      _drawChip(g, rect, text, z.color, lit: s.held != null && s.hover == z);
    }
  }

  /// The animals' text sprites (HTML `labelDict`), above everything.
  void _paintAnimalLabels(_Gfx g) {
    final s = scene;
    final border = s.scenario == 0
        ? _Colors.chipAnimalS1
        : _Colors.chipAnimalS2;
    for (final b in s.bodies) {
      if (identical(b, s.held)) continue;
      final text = _t(b.kind.labelKey);
      _drawChip(g, _chipRect(g.cam.p(s.labelAt(b)), text), text, border);
    }
  }

  /// Where a label chip with [text] centred on [at] goes, kept inside the
  /// visible canvas.
  Rect _chipRect(Offset at, String text) {
    final size = cache.chipSize(text);
    var rect = (at + _chipOffset(size)) & size;
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
    return rect;
  }

  /// HTML `createTextSprite`: dark chip with a coloured border and white
  /// bold text in [rect].
  void _drawChip(
    _Gfx g,
    Rect rect,
    String text,
    Color border, {
    bool lit = false,
  }) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.45),
    );
    g.canvas
      ..drawRRect(
        rr,
        _pens.fill
          ..color = lit
              ? Color.alphaBlend(border.withValues(alpha: 0.4), _Colors.chipBg)
              : _Colors.chipBg,
      )
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = lit ? 2.6 : 1.4
          ..color = border,
      );
    final tp = cache.label(text);
    tp.paint(
      g.canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.top + _chipPadY * cache.labelSize,
      ),
    );
  }

  /// HTML `confetti(...)` with the summary.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 < 0) return;
    final ticks = (s.time - t0) * 60;
    if (ticks < 0 || ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    final pen = _pens.fill;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      canvas.save();
      canvas.translate(
        _confettiOrigin.dx + math.cos(c.angle) * d,
        _confettiOrigin.dy + math.sin(c.angle) * d + fall,
      );
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        _confettiPiece,
        pen..color = c.color.withValues(alpha: fade),
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
