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

/// Class 6 Science • Chapter 8 • Activity 5
/// Evaporation's Cooling Effect.
///
/// Native Flutter port of `Cl6S-Ch8-A5-Evaporation_s_Cooling_Effect.html`.
///
/// Scenario 1 (The Magical Cooling Pot): the learner pours a jug of water
/// into an earthen pot (matka) and into a stainless steel pot, fast-forwards
/// one hour and reads the two thermometers: water seeping through the
/// porous earthen pot evaporates and cools the water inside (30 °C → 22 °C);
/// the steel pot stays at 30 °C.
///
/// Scenario 2 (The Pot-in-Pot Cooler): the learner builds a pot-in-pot
/// cooler (sand layer, small pot inside the large one, sand in the gap,
/// water on the sand, vegetables inside, wet jute sack on top),
/// fast-forwards and lifts the sack: the vegetables inside stay fresh while
/// those left on the plate wilt.
///
/// The Three.js table scene is redrawn by a CustomPainter through a
/// perspective projection of the same camera (fov 45°, position
/// (0, 20, 35), looking at (0, 4, 0)). Scenario 2 shows the large pot cut
/// away at the front, so every layer of the cooler can be seen.
class Ch8A5EvaporationsCoolingEffectPage extends StatefulWidget {
  const Ch8A5EvaporationsCoolingEffectPage({super.key});

  @override
  State<Ch8A5EvaporationsCoolingEffectPage> createState() => _CoolingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three Web Audio tones: `click`
/// (buttons, the sidebar, Enter Lab, picking up an object, an object
/// sliding back or into place), `pour` (a falling triangle tone while the
/// jug or the sand bag pours), mapped to drop.mp3, and `ding` (the summary),
/// mapped to success.mp3. correct.mp3 / error.mp3 are the shell's feedback
/// tones for the toasts this port adds.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pickup → `science/pickup.mp3`, drop → `science/drop.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `click` when an object is picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML `pour`.
  drop('audio/class6/science/drop.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// An object let go in the wrong place (added feedback).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `ding`: the summary popup.
  success('audio/class6/math/success.mp3');

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
  static const Color white = Color(0xFFFFFFFF);
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
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFF8FAFC);

  /// Table `materials.wood` 0x8b5a2b.
  static const Color wood = Color(0xFF8B5A2B);

  /// `materials.earthen` 0xc26c42; darker where seeping water wets it
  /// (added: the HTML observation "water seeps through the pot").
  static const Color earthen = Color(0xFFC26C42);
  static const Color earthenWet = Color(0xFF8A4628);

  /// `materials.steel` 0x9ca3af (metalness 0.8).
  static const Color steel = Color(0xFF9CA3AF);

  /// `materials.water` 0x38bdf8 (opacity 0.8); the jug's stream 0x0ea5e9.
  static const Color water = Color(0xFF38BDF8);
  static const Color stream = Color(0xFF0EA5E9);

  /// `materials.sandDry` 0xd2b48c and `materials.sandWet` 0x8b4513.
  static const Color sandDry = Color(0xFFD2B48C);
  static const Color sandWet = Color(0xFF8B4513);

  /// `materials.sack` 0xa08060 (bag of sand, jute sack).
  static const Color sack = Color(0xFFA08060);

  /// `createJug()` 0x1e3a8a.
  static const Color jug = Color(0xFF1E3A8A);

  /// `materials.carrot` 0xf97316, `tomato` 0xef4444, `leaf` 0x22c55e and
  /// the wilted colour 0x555555.
  static const Color carrot = Color(0xFFF97316);
  static const Color tomato = Color(0xFFEF4444);
  static const Color leaf = Color(0xFF22C55E);
  static const Color wilted = Color(0xFF555555);

  /// The plate (`MeshStandardMaterial({color: 0xffffff})`).
  static const Color plate = white;

  /// `update3DHighlight()` pulse colour 0x38bdf8.
  static const Color pulse = Color(0xFF38BDF8);

  /// Evaporation particles: water 0x60a5fa, heat 0xef4444.
  static const Color vapour = blue400;
  static const Color heat = red500;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// `createStdLabel`: glass chip (slate-900/92) with a blue-400 border.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBorder = blue400;

  /// `.thermometer-label`: white / slate-300 / slate-800 (light) and
  /// slate-800 / slate-600 / white (dark); icon red-500 or blue-500.
  static const Color chipLight = white;
  static const Color chipLightBorder = slate300;
  static const Color chipLightText = slate800;
  static const Color chipDark = slate800;
  static const Color chipDarkBorder = slate600;
  static const Color chipDarkText = white;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500, // text-blue-500 headings, blue buttons
    onAccent: _Colors.white,
    primary: _Colors.blue600, // summary button from-blue-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary bg-slate-900
    popupHeader: _Colors.blue600, // summary header bg-blue-600
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // subtitle text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // tools panel dark:bg-slate-900/90
    buttonIcon: _Colors.blue400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg white/95
    border: Color(0x26000000), // --glass-border black/15
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
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.blue600,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar text size setting: 15 px, slider 12–22 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays its `click` tone for buttons, the sidebar, scenario changes and the
/// curtain.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.click,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.click,
  curtain: _Sound.click,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// say exactly what to do on a touch screen (drag over the pot and let go,
// "tap" instead of "click", and the 'Finish Observation' button the HTML
// showed without naming it). The HTML wrote that evaporating water pulls
// "heat particles" away; heat is not made of particles, so the texts say
// it takes heat away. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': "Evaporation's Cooling Effect",
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt': 'Scenario 1: The Magical Cooling Pot',
    'scen_2_opt': 'Scenario 2: The Pot-in-Pot Cooler',
    's1_desc':
        'To visually compare the temperature of water in an earthen pot (matka) and a stainless steel pot to understand why the earthen pot keeps water cooler.',
    's2_desc':
        'To construct a pot-in-pot cooler and observe how it keeps vegetables fresh by using the principle of evaporative cooling.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Fill Earthen Pot',
    's1_a1':
        'DRAG the jug of water over the earthen pot and let go to POUR the water in.',
    's1_o1': 'The earthen pot is filled with water.',
    's1_c2': 'Fill Steel Pot',
    's1_a2':
        'DRAG the same jug of water over the stainless steel pot and let go to POUR the water in.',
    's1_o2':
        'Both pots now have water and start at the same temperature (30°C).',
    's1_c3': 'Evaporation Process',
    's1_a3': "TAP the 'Fast Forward' button to observe what happens over time.",
    's1_o3':
        'Water seeps out through the tiny pores of the earthen pot and evaporates from its surface, taking heat away from the pot and the water inside. The steel pot has no pores and stays dry.',
    's1_c4': 'Final Observation',
    's1_a4':
        "Observe the final temperatures on both thermometers, then TAP 'Finish Observation'.",
    's1_o4': "The earthen pot's water is significantly cooler.",
    // Scenario 2 steps.
    's2_c1': 'Base Layer',
    's2_a1':
        'DRAG the bag of sand over the large earthen pot and let go to POUR a layer of sand into its bottom.',
    's2_o1': 'A layer of sand is placed at the bottom.',
    's2_c2': 'Inner Chamber',
    's2_a2':
        'DRAG the smaller earthen pot over the larger pot and let go to PLACE it inside.',
    's2_o2': 'The smaller pot is nested inside.',
    's2_c3': 'Insulation Gap',
    's2_a3':
        'DRAG the bag of sand over the large pot again and let go to POUR sand into the gap between the two pots.',
    's2_o3': 'The space between the pots is filled with sand.',
    's2_c4': 'Moistening Sand',
    's2_a4':
        'DRAG the jug of water over the large pot and let go to POUR water onto the sand.',
    's2_o4': 'The sand in the gap becomes visibly dark and wet.',
    's2_c5': 'Add Contents',
    's2_a5':
        'DRAG the vegetables over the small inner pot and let go to DROP them in.',
    's2_o5': 'Vegetables are placed inside the cooler.',
    's2_c6': 'Cover and Wait',
    's2_a6':
        "DRAG the wet jute sack over the cooler and let go to COVER it. Then TAP 'Fast Forward'.",
    's2_o6':
        'Water from the wet sand evaporates from the outer pot, cooling the inside. The vegetables left outside wilt.',
    's2_c7': 'Compare Freshness',
    's2_a7':
        "LIFT the jute sack: drag it off the cooler and compare the vegetables. Then TAP 'Finish Observation'.",
    's2_o7':
        'The vegetables inside remain crisp and fresh, unlike those outside.',
    // HTML `hud-instruction` lines ("click" → "tap").
    's1_hud_1':
        'Step 1: DRAG the jug of water over the earthen pot and let go to POUR it in.',
    's1_hud_2':
        'Step 2: DRAG the jug of water over the stainless steel pot and let go to POUR it in.',
    's1_hud_3':
        "Step 3: TAP 'Fast Forward' to observe what happens over one hour.",
    's1_hud_4':
        "Step 4: Observe the final temperatures on both thermometers. TAP 'Finish Observation'.",
    's2_hud_1':
        'Step 1: DRAG the bag of sand over the large earthen pot and let go to POUR a layer into its bottom.',
    's2_hud_2':
        'Step 2: DRAG the smaller earthen pot over the larger pot and let go to PLACE it inside.',
    's2_hud_3':
        'Step 3: DRAG the bag of sand over the large pot again to POUR sand into the gap between the two pots.',
    's2_hud_4':
        'Step 4: DRAG the jug of water over the large pot and let go to POUR it onto the sand until moist.',
    's2_hud_5':
        'Step 5: DRAG the vegetables over the small inner pot and let go to DROP them in.',
    's2_hud_6':
        "Step 6: DRAG the wet jute sack over the cooler to COVER it. Then TAP 'Fast Forward'.",
    's2_hud_7':
        "Step 7: LIFT the jute sack off the cooler to compare the vegetables. TAP 'Finish Observation'.",
    // HTML buttons.
    'btn_timelapse': 'Fast Forward',
    'btn_finish': 'Finish Observation',
    // HTML canvas labels; the two pots of Scenario 2 are told apart
    // (added: the HTML labelled both 'Earthen Pot (Matka)').
    'lbl_earthen_pot': 'Earthen Pot (Matka)',
    'lbl_steel_pot': 'Steel Pot',
    'lbl_jug': 'Water Jug',
    'lbl_bag': 'Bag of Sand',
    'lbl_veggies': 'Vegetables',
    'lbl_plate': 'Plate (Control)',
    'lbl_sack': 'Jute Sack',
    'lbl_large_pot': 'Large Earthen Pot',
    'lbl_small_pot': 'Small Earthen Pot',
    'unit_c': '{v}°C',
    // HTML summary popup.
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1_title': 'Evaporation Causes Cooling!',
    'sum_s1':
        'Water evaporating from the porous surface of the earthen pot absorbed and removed heat, making the water inside cooler. The steel pot has no pores, so no evaporation occurred on its surface.',
    'sum_s2_title': 'Natural Refrigeration!',
    'sum_s2':
        'The constant evaporation of water from the wet sand through the outer porous pot created a cool, humid environment inside, preserving the vegetables much like a refrigerator.',
    // Added: the two thermometer readings in the Scenario 1 summary.
    'res_title': 'Thermometer readings',
    'res_row': '{a} → {b}',
    // Added: feedback where the HTML silently sent the object back.
    'e_jug_matka': 'Drop the jug over the earthen pot to pour the water in.',
    'e_matka_first': 'Fill the earthen pot first: drop the jug over it.',
    'e_jug_steel':
        'Drop the jug over the stainless steel pot to pour the water in.',
    'e_matka_full':
        'The earthen pot is already full. Pour the water into the steel pot.',
    'e_bag_pot': 'Drop the bag of sand over the large earthen pot.',
    'e_small_pot': 'Drop the small pot over the large pot to place it inside.',
    'e_jug_sand': 'Drop the jug over the large pot to wet the sand.',
    'e_veg_pot': 'Drop the vegetables over the small inner pot.',
    'e_sack_cover': 'Drop the jute sack over the cooler to cover it.',
    'e_sack_lift':
        'Lift the sack clear of the cooler to see the vegetables inside.',
    // Added: the sidebar's observation list.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Table with an earthen pot, a stainless steel pot and a jug of water',
    'scene_s2':
        'Table with a large earthen pot cut open at the front, a small earthen pot, a bag of sand, a jug of water, vegetables, a plate of vegetables and a jute sack',
  },
  'hi': {
    'app_title': 'वाष्पीकरण का शीतलन प्रभाव',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: जादुई कूलिंग पॉट',
    'scen_2_opt': 'परिदृश्य 2: पॉट-इन-पॉट कूलर',
    's1_desc':
        'मिट्टी के घड़े और स्टेनलेस स्टील के बर्तन में पानी के तापमान की तुलना करना ताकि यह समझा जा सके कि मिट्टी का घड़ा पानी को ठंडा क्यों रखता है।',
    's2_desc':
        'एक पॉट-इन-पॉट कूलर का निर्माण करना और यह देखना कि वाष्पीकरणीय शीतलन के सिद्धांत का उपयोग करके यह सब्जियों को कैसे ताज़ा रखता है।',
    's1_c1': 'मिट्टी का घड़ा भरें',
    's1_a1':
        'पानी के जग को मिट्टी के घड़े के ऊपर खींचें और छोड़ दें, ताकि पानी घड़े में डल जाए।',
    's1_o1': 'मिट्टी का घड़ा पानी से भर जाता है।',
    's1_c2': 'स्टील का बर्तन भरें',
    's1_a2':
        'उसी जग को स्टेनलेस स्टील के बर्तन के ऊपर खींचें और छोड़ दें, ताकि पानी बर्तन में डल जाए।',
    's1_o2':
        'दोनों बर्तनों में पानी है और दोनों का तापमान शुरू में एक जैसा (30°C) है।',
    's1_c3': 'वाष्पीकरण प्रक्रिया',
    's1_a3':
        "समय के साथ क्या होता है यह देखने के लिए 'फास्ट फॉरवर्ड' बटन पर टैप करें।",
    's1_o3':
        'पानी मिट्टी के घड़े के बारीक छिद्रों से रिसकर बाहर आता है और उसकी सतह से वाष्पित होता है, जिससे घड़े और उसके अंदर के पानी की ऊष्मा दूर चली जाती है। स्टील के बर्तन में छिद्र नहीं होते, इसलिए वह सूखा रहता है।',
    's1_c4': 'अंतिम अवलोकन',
    's1_a4':
        "दोनों थर्मामीटर पर अंतिम तापमान देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o4': 'मिट्टी के घड़े का पानी काफी ठंडा होता है।',
    's2_c1': 'आधार परत',
    's2_a1':
        'रेत की बोरी को बड़े मिट्टी के घड़े के ऊपर खींचें और छोड़ दें, ताकि उसके तल में रेत की एक परत बिछ जाए।',
    's2_o1': 'नीचे रेत की एक परत बिछ जाती है।',
    's2_c2': 'आंतरिक कक्ष',
    's2_a2':
        'छोटे मिट्टी के घड़े को बड़े घड़े के ऊपर खींचें और छोड़ दें, ताकि वह उसके अंदर रख दिया जाए।',
    's2_o2': 'छोटा घड़ा बड़े घड़े के अंदर रखा गया है।',
    's2_c3': 'इन्सुलेशन गैप',
    's2_a3':
        'रेत की बोरी को फिर से बड़े घड़े के ऊपर खींचें और छोड़ दें, ताकि दोनों घड़ों के बीच की जगह में रेत भर जाए।',
    's2_o3': 'घड़ों के बीच की जगह रेत से भर जाती है।',
    's2_c4': 'रेत को गीला करना',
    's2_a4':
        'पानी के जग को बड़े घड़े के ऊपर खींचें और छोड़ दें, ताकि पानी रेत पर डल जाए।',
    's2_o4': 'बीच की जगह की रेत साफ़ तौर पर गहरी और गीली हो जाती है।',
    's2_c5': 'सामग्री जोड़ें',
    's2_a5':
        'सब्जियों को छोटे अंदर वाले घड़े के ऊपर खींचें और छोड़ दें, ताकि वे उसमें गिर जाएँ।',
    's2_o5': 'सब्जियाँ कूलर के अंदर रख दी जाती हैं।',
    's2_c6': 'ढकें और प्रतीक्षा करें',
    's2_a6':
        "गीली जूट की बोरी को कूलर के ऊपर खींचें और छोड़ दें, ताकि कूलर ढक जाए। फिर 'फास्ट फॉरवर्ड' पर टैप करें।",
    's2_o6':
        'गीली रेत का पानी बाहरी घड़े की सतह से वाष्पित होता है, जिससे अंदर ठंडक रहती है। बाहर रखी सब्जियाँ मुरझा जाती हैं।',
    's2_c7': 'ताजगी की तुलना करें',
    's2_a7':
        "जूट की बोरी उठाएँ: उसे कूलर से हटाकर दूर खींचें और सब्जियों की तुलना करें। फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o7':
        'अंदर की सब्जियाँ बाहर की सब्जियों के विपरीत कुरकुरी और ताज़ी रहती हैं।',
    's1_hud_1':
        'चरण 1: पानी के जग को मिट्टी के घड़े के ऊपर खींचें और छोड़ दें, ताकि पानी उसमें डल जाए।',
    's1_hud_2':
        'चरण 2: पानी के जग को स्टील के बर्तन के ऊपर खींचें और छोड़ दें, ताकि पानी उसमें डल जाए।',
    's1_hud_3':
        "चरण 3: एक घंटे में क्या होता है यह देखने के लिए 'फास्ट फॉरवर्ड' पर टैप करें।",
    's1_hud_4':
        "चरण 4: दोनों थर्मामीटर पर अंतिम तापमान देखें। 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1':
        'चरण 1: रेत की बोरी को बड़े मिट्टी के घड़े के ऊपर खींचें और छोड़ दें, ताकि उसके तल में रेत की परत बिछ जाए।',
    's2_hud_2':
        'चरण 2: छोटे मिट्टी के घड़े को बड़े घड़े के ऊपर खींचें और छोड़ दें, ताकि वह उसके अंदर रखा जाए।',
    's2_hud_3':
        'चरण 3: रेत की बोरी को फिर से बड़े घड़े के ऊपर छोड़ें, ताकि दोनों घड़ों के बीच की जगह में रेत भर जाए।',
    's2_hud_4':
        'चरण 4: पानी के जग को बड़े घड़े के ऊपर छोड़ें, ताकि पानी रेत पर डले और रेत गीली हो जाए।',
    's2_hud_5':
        'चरण 5: सब्जियों को छोटे अंदर वाले घड़े के ऊपर खींचें और छोड़ दें।',
    's2_hud_6':
        "चरण 6: कूलर को ढकने के लिए गीली जूट की बोरी को उसके ऊपर छोड़ें। फिर 'फास्ट फॉरवर्ड' पर टैप करें।",
    's2_hud_7':
        "चरण 7: सब्जियों की तुलना करने के लिए जूट की बोरी को कूलर से हटाएँ। 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_timelapse': 'फास्ट फॉरवर्ड',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_earthen_pot': 'मिट्टी का घड़ा (मटका)',
    'lbl_steel_pot': 'स्टील का बर्तन',
    'lbl_jug': 'पानी का जग',
    'lbl_bag': 'रेत की बोरी',
    'lbl_veggies': 'सब्जियाँ',
    'lbl_plate': 'प्लेट (तुलना के लिए)',
    'lbl_sack': 'जूट की बोरी',
    'lbl_large_pot': 'बड़ा मिट्टी का घड़ा',
    'lbl_small_pot': 'छोटा मिट्टी का घड़ा',
    'unit_c': '{v}°C',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1_title': 'वाष्पीकरण से शीतलन होता है!',
    'sum_s1':
        'मिट्टी के घड़े की छिद्रपूर्ण सतह से वाष्पित होने वाले पानी ने ऊष्मा को अवशोषित करके दूर कर दिया, जिससे अंदर का पानी ठंडा हो गया। स्टील के बर्तन में कोई छिद्र नहीं होते हैं, इसलिए उसकी सतह पर कोई वाष्पीकरण नहीं हुआ।',
    'sum_s2_title': 'प्राकृतिक प्रशीतन!',
    'sum_s2':
        'बाहरी छिद्रपूर्ण घड़े के माध्यम से गीली रेत से पानी के लगातार वाष्पीकरण ने अंदर एक ठंडा, आर्द्र वातावरण बनाया, जिससे सब्जियां रेफ्रिजरेटर की तरह संरक्षित रहीं।',
    'res_title': 'थर्मामीटर की रीडिंग',
    'res_row': '{a} → {b}',
    'e_jug_matka': 'पानी डालने के लिए जग को मिट्टी के घड़े के ऊपर छोड़ें।',
    'e_matka_first': 'पहले मिट्टी का घड़ा भरें: जग को उसके ऊपर छोड़ें।',
    'e_jug_steel':
        'पानी डालने के लिए जग को स्टेनलेस स्टील के बर्तन के ऊपर छोड़ें।',
    'e_matka_full':
        'मिट्टी का घड़ा पहले से भरा है। पानी स्टील के बर्तन में डालें।',
    'e_bag_pot': 'रेत की बोरी को बड़े मिट्टी के घड़े के ऊपर छोड़ें।',
    'e_small_pot':
        'छोटे घड़े को बड़े घड़े के ऊपर छोड़ें, ताकि वह उसके अंदर चला जाए।',
    'e_jug_sand': 'रेत गीली करने के लिए जग को बड़े घड़े के ऊपर छोड़ें।',
    'e_veg_pot': 'सब्जियों को छोटे अंदर वाले घड़े के ऊपर छोड़ें।',
    'e_sack_cover': 'जूट की बोरी को कूलर के ऊपर छोड़ें, ताकि वह ढक जाए।',
    'e_sack_lift':
        'अंदर की सब्जियाँ देखने के लिए बोरी को कूलर से पूरी तरह हटा दें।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'मिट्टी के घड़े, स्टेनलेस स्टील के बर्तन और पानी के जग वाली मेज',
    'scene_s2':
        'मेज जिस पर आगे से कटा हुआ बड़ा मिट्टी का घड़ा, छोटा मिट्टी का घड़ा, रेत की बोरी, पानी का जग, सब्जियाँ, सब्जियों वाली प्लेट और जूट की बोरी रखी है',
  },
};

/// Scenarios and their step counts (HTML `ScenariosData`).
const List<int> _stepCounts = [4, 7];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
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
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// HTML `resetCamera()`: `camera.position.set(0, 20, 35)` looking at
/// `controls.target` (0, 4, 0), in both scenarios. (The HTML moves the
/// camera back to (0, 30, 45) only in portrait windows narrower than
/// 640 px; the lab always runs in landscape.)
const _V _eye = _V(0, 20, 35);
const _V _lookAt = _V(0, 4, 0);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// A release counts as "over" a pot within this many design px of the
/// pot's outline on screen.
const double _dropMargin = 12;

/// Scene labels: 12 design px, enlarged up to 1.7x on small stages so the
/// HTML's 10–12 px label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.7;

/// The scene slides and shrinks with the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the framed scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the framing.
const ValueKey<String> _sceneKey = ValueKey('ch8-a5-scene');

/// LAB FRAMEWORK geometry the framing keeps clear of (dp): the floating
/// mission card's top-left corner, the tool column, the HUD chip's height
/// (two text lines at UI scale 1), and the gap kept from each.
const double _missionCardLeft = 76;
const double _missionCardTop = 12;
const double _toolClearance = 72;
const double _hudHeight = 56;
const double _frameGap = 8;

/// Smallest scale the framing may use for the scene (on the smallest
/// phones with the sidebar collapsed) and its search steps (design px).
const double _minFrameScale = 0.6;

/// How much smaller the scene may get so the tools pouring above the pots
/// also stay clear of the floating mission card.
const double _seenSlack = 0.1;
const double _frameScaleStep = 0.02;
const double _frameShiftStep = 4;
const int _frameShiftSteps = 200;

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// The same point at height [h].
  _V atY(double h) => _V(x, h, z);

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

  /// Forward, right and up directions of the camera.
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

  /// Where the ray through [s] meets the plane `n · x = d` (HTML
  /// `raycaster.ray.intersectPlane(dragPlane, …)`).
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// The lab's camera; the look-at point is drawn at the stage centre.
final _Cam _cam = _Cam(_eye, _lookAt, const Offset(500, 280));

/// HTML `DirectionalLight(0xffffff, 0.8)` at (10, 20, 15), normalised.
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// HTML `AmbientLight(0xffffff, 0.7)` plus the key light; both are toned
/// down so the lit faces do not all clip to white.
const double _ambient = 0.55;
const double _diffuse = 0.6;

/// Inside surfaces (seen through a pot's mouth or the cut-away) are in
/// shade.
const double _innerShade = 0.62;

/// HTML pulse of the object to drag: emissive 0x38bdf8 at up to 40 %,
/// `(sin(Date.now() * 0.005) + 1) / 2`.
const double _pulseMax = 0.4;
const double _pulseRate = 5;

/// Orientation of a lathe or box: its axis [ey] and the two directions
/// [ex], [ez] across it.
@immutable
class _Frame {
  const _Frame(this.ex, this.ey, this.ez);

  /// Turned by [a] radians about z (Three.js `rotation.z`).
  factory _Frame.rollZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _Frame(_V(c, s, 0), _V(-s, c, 0), _V.front);
  }

  static const upright = _Frame(_V.right, _V.up, _V.front);

  final _V ex;
  final _V ey;
  final _V ez;

  /// The point (x, y, z) of this frame placed at [o].
  _V at(_V o, double x, double y, double z) => o + ex * x + ey * y + ez * z;

  /// Direction across the axis at angle [a] (0 = +x, π/2 = +z, the front).
  _V across(double a) => ex * math.cos(a) + ez * math.sin(a);
}

// ------------------------------------------------------- earthen pots

/// HTML `createPot()` for an earthen pot of radius R: a sphere sliced
/// between polar angles 0.18π and 0.82π, a 0.2-high bottom disc of the
/// slice's lower radius, a neck 0.35R high and a rim torus (tube 0.08R).
const double _potTheta0 = math.pi * 0.18;
const double _potTheta1 = math.pi * 0.82;
const double _potFloor = 0.2;
const int _potBands = 8;

/// One earthen pot's shape (profile from its base upwards).
@immutable
class _PotShape {
  factory _PotShape(double radius) {
    final bottomR = radius * math.sin(_potTheta1);
    final centreY = _potFloor - radius * math.cos(_potTheta1);
    final neckR = radius * math.sin(_potTheta0);
    final neckBase = centreY + radius * math.cos(_potTheta0);
    final top = neckBase + 0.35 * radius;
    final profile = <(double, double)>[(bottomR, 0.0)];
    for (var i = 0; i <= _potBands; i++) {
      final a = _potTheta1 + (_potTheta0 - _potTheta1) * i / _potBands;
      profile.add((radius * math.sin(a), centreY + radius * math.cos(a)));
    }
    profile.add((neckR, top));
    return _PotShape._(radius, bottomR, centreY, neckR, neckBase, top, profile);
  }

  const _PotShape._(
    this.radius,
    this.bottomR,
    this.centreY,
    this.neckR,
    this.neckBase,
    this.top,
    this.profile,
  );

  final double radius;
  final double bottomR;
  final double centreY;
  final double neckR;
  final double neckBase;

  /// Height of the rim above the pot's base.
  final double top;

  /// (radius, height) points of the outer surface, bottom to rim.
  final List<(double, double)> profile;

  /// Rim torus tube (HTML `radius * 0.08`).
  double get tube => 0.08 * radius;

  /// Wall thickness drawn where the cut-away opens the pot (the HTML's
  /// double-sided material has none).
  double get wall => 0.05 * radius;

  /// Outer radius at height [y] above the base.
  double radiusAt(double y) {
    if (y <= _potFloor) return bottomR;
    if (y >= neckBase) return neckR;
    final d = y - centreY;
    return math.sqrt(math.max(0.0, radius * radius - d * d));
  }

  /// Inner radius at height [y] above the base.
  double innerAt(double y) => math.max(0.0, radiusAt(y) - wall);
}

final _PotShape _matkaShape = _PotShape(4);
final _PotShape _bigShape = _PotShape(5);
final _PotShape _smallShape = _PotShape(2.4);

// ------------------------------------------------------ scenario 1

/// `matkaS1.position.set(-8, 0, 0)`, `steelS1.position.set(8, 0, 0)`.
const _V _matkaAt = _V(-8, 0, 0);
const _V _steelAt = _V(8, 0, 0);

/// `createPot(steel, 3.5, 5.5, true)`: an open cylinder of radius 3.5 and
/// height 5.5 with a bottom disc, a rim torus (tube 0.21) and two handle
/// rings (radius 1.225, tube 0.28) at 0.65 of its height.
const double _steelR = 3.5;
const double _steelH = 5.5;
const double _steelTube = 0.21;
const double _handleR = 1.225;
const double _handleTube = 0.28;
const double _handleY = 3.575;
const List<(double, double)> _steelProfile = [(_steelR, 0), (_steelR, _steelH)];

/// Specular strength of the steel (HTML roughness 0.2, metalness 0.8).
const double _steelShine = 0.65;

/// `jugS1.position.set(-16, 0, 5)`.
const _V _jug1Home = _V(-16, 0, 5);

/// HTML pour positions `(-11, 10, 0)` and `(5, 10, 0)`: the tilted jug's
/// spout is over the pot's mouth. Raised by 0.3 so the tilted jug clears
/// the matka's rim (the HTML jug dipped into it).
const _V _jugPourMatka = _V(-11, 10.3, 0);
const _V _jugPourSteel = _V(5, 10.3, 0);

/// Water surfaces: `CylinderGeometry(2.9 …)` rising from y 0.5 in the
/// matka and `CylinderGeometry(3.4 …)` from 0.5 to 4.8 in the steel pot.
/// The HTML filled the matka to y 6.2, below its neck (6.95 … 8.35), where
/// the camera cannot see it; here it rises into the neck (7.6) so the
/// learner sees the pot filled.
const double _matkaWaterR = 2.9;
const double _steelWaterR = 3.4;
const double _waterLow = 0.5;
const double _matkaWaterHigh = 7.6;
const double _steelWaterHigh = 4.8;

/// Thermometer labels: the HTML put them 9 / 7.5 above the pots' bases
/// (`createThermometerLabel(…, matkaS1, 9)`), on top of the matka's mouth;
/// here each one sits just above the back of its pot's rim ([_thermoGap]
/// design px between them) so the water stays in view. The matka cools
/// from 30 °C to 22 °C during the fast-forward (`TWEEN obj.t 30 → 22,
/// 4500 ms`).
final _V _matkaThermoAt =
    _matkaAt + _V(0, _matkaShape.top + _matkaShape.tube, -_matkaShape.neckR);
const _V _steelThermoAt = _V(8, _steelH + _steelTube, -_steelR);
const double _thermoGap = 3;
const double _startTemp = 30;
const double _matkaEndTemp = 22;

// ------------------------------------------------------ scenario 2

/// `largePotS2.position.set(-5, 0, 0)`; the small pot starts at
/// `(-18, 0, 0)` and sits at `(-5, 0.5, 0)` inside the large one.
const _V _bigAt = _V(-5, 0, 0);
const _V _smallHome = _V(-18, 0, 0);
const _V _smallIn = _V(-5, 0.5, 0);

/// `bagS2` at (-14, 0, -5), `jugS2` at (-14, 0, 5).
const _V _bagHome = _V(-14, 0, -5);
const _V _jug2Home = _V(-14, 0, 5);

/// Pour positions over the large pot. The HTML's (-8, 12, 0) and
/// (-8, 10, 0) put the water stream into the small inner pot and the bag
/// inside the rim; here the sand and the water fall through the neck onto
/// the gap between the pots (stream at x -2.65) and clear the rim.
const _V _bagPour = _V(-3.71, 12.3, 0);
const _V _jug2Pour = _V(-6.19, 12.5, 0);

/// `veggiesIn` at (0, 0, 5), dropped to (-5, 1.2, 0) in the small pot;
/// the control vegetables `veggiesOut` on the plate at (10, 0.2, 0).
const _V _vegHome = _V(0, 0, 5);
const _V _vegIn = _V(-5, 1.2, 0);
const _V _plateAt = _V(10, 0, 0);
const _V _vegOut = _V(10, 0.2, 0);

/// The jute sack: home (15, 0, 5) in the HTML, raised 0.9 so its skirt
/// rests on the table instead of sinking into it. On the cooler it drapes
/// over the large pot's neck (the HTML's (-5, 5, 0) was inside the pot's
/// body), drawn at 2/3 of its size so it fits the mouth.
const _V _sackHome = _V(15, 0.9, 5);
const double _sackOnK = 0.667;

/// Sack sizes (HTML): top disc radius 4.8, skirt 4.8 → 5.2 over 1 unit
/// (from y -0.9 to 0.1), tie torus radius 5.0 at y -0.2.
const double _sackTopR = 4.8;
const double _sackSkirtR = 5.2;
const double _sackTieR = 5.0;

/// Sand: the base layer (`sandBase` 0.5 thick) grows from the large pot's
/// floor to [_gapFloor]; the sand in the gap (`sandGap`) rises from there
/// to 4.0.
const double _baseThick = 0.55;
const double _gapFloor = _potFloor + _baseThick;
const double _gapTop = 4;

/// `veggiesOut` wilts during the fast-forward: scale (0.7, 0.5, 0.7).
const double _wiltX = 0.7;
const double _wiltY = 0.5;

// ------------------------------------------------------- timings

/// HTML `animatePour()` (ms): move to the pour position 500 (Quadratic.Out),
/// tilt 300, stream grows 200 while the fill rises for 1000, stream and
/// tilt go back 1200 later, return home 500.
const int _pourMoveMs = 500;
const int _tiltMs = 300;
const int _streamOnMs = _pourMoveMs + _tiltMs;
const int _streamOffMs = _streamOnMs + 1200;
const int _returnMs = _streamOffMs + _tiltMs;
const int _pourDoneMs = _returnMs + 500;
const double _streamGrow = 0.2;
const double _fillSeconds = 1;

/// The tilted jug / bag: `rotation.z` → -π / 4.
const double _pourTilt = math.pi / 4;

/// Stream length (`CylinderGeometry(…, 12, …)`) and radii (jug 0.35, sand
/// 0.3).
const double _streamLength = 12;
const double _waterStreamR = 0.35;
const double _sandStreamR = 0.3;

/// Object placed (small pot, vegetables, sack): 600 ms, Quadratic.Out; an
/// object let go elsewhere slides home in 500 ms.
const int _placeMs = 600;
const int _homeMs = 500;

/// HTML fast-forward: 4500 ms.
const int _ffMs = 4500;

/// HTML `createEvaporationParticles`: 30 pairs, one every 150 ms, each
/// rising 4–6 units in 2 s while fading. Drawn larger than the HTML's
/// 0.15-unit spheres so they can be seen on a phone; heat is drawn as a
/// wavy line, not a particle.
const int _puffCount = 30;
const double _puffGap = 0.15;
const double _puffSeconds = 2;
const double _puffR = 0.3;
const double _heatLen = 1.1;

/// Every object the scene draws.
enum _Item { jug, matka, steel, bag, smallPot, bigPot, veggies, plate, sack }

/// A straight move between two points over [seconds] from [start] (scene
/// time), eased by [curve] (a TWEEN.js tween on `position`).
@immutable
class _Move {
  const _Move(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Move.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, curve.transform((t - start) / seconds));
  }

  /// 0 … 1 through the move.
  double progress(double t) =>
      seconds <= 0 ? 1 : ((t - start) / seconds).clamp(0.0, 1.0);
}

/// A number eased linearly from [from] to [to] (a TWEEN.js tween on a
/// scalar, default Linear easing).
@immutable
class _Ramp {
  const _Ramp(this.from, this.to, this.start, this.seconds);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0;

  final double from;
  final double to;
  final double start;
  final double seconds;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * (t - start) / seconds;
  }
}

/// One evaporation particle pair: a water drop and a wisp of heat.
class _Puff {
  _V at = _V.zero;
  double rise = 0;
  double heatDy = 0;
  double heatRise = 0;
  double start = 0;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based). Scenario 2 reaches 8 once the sack is
  /// lifted (the HTML then shows the 'Finish Observation' button).
  int step = 1;

  /// HTML `State.isAnimating`: something moves and touches are ignored.
  bool busy = false;

  /// The summary has been opened.
  bool done = false;

  /// The object the learner is dragging.
  _Item? held;

  // ---------------------------------------------------------- movers
  _Move jug = const _Move.still(_jug1Home);
  _Move bag = const _Move.still(_bagHome);
  _Move smallPot = const _Move.still(_smallHome);
  _Move veggies = const _Move.still(_vegHome);
  _Move sack = const _Move.still(_sackHome);

  /// The pour under way: tool, target, step, tilt and stream times.
  _Item? pourTool;
  _Item? pourInto;
  int pourStep = 0;
  _Ramp tilt = const _Ramp.still(0);
  double streamOn = -10;
  double streamOff = -10;

  // ------------------------------------------------------ scenario 1
  bool matkaWater = false;
  bool steelWater = false;
  _Ramp matkaLevel = const _Ramp.still(_waterLow);
  _Ramp steelLevel = const _Ramp.still(_waterLow);

  /// The thermometer labels are shown (after both pots are filled).
  bool thermo = false;

  /// The fast-forward started (-10: not yet).
  double ffAt = -10;

  // ------------------------------------------------------ scenario 2
  _Ramp sandBase = const _Ramp.still(0);
  _Ramp gap = const _Ramp.still(_gapFloor);
  _Ramp wet = const _Ramp.still(0);
  _Ramp sackK = const _Ramp.still(1);
  bool smallIn = false;
  bool vegIn = false;
  bool sackOn = false;
  bool lifted = false;

  final List<_Puff> puffs = [for (var i = 0; i < _puffCount; i++) _Puff()];

  /// 0 … 1 through the fast-forward.
  double get ffProgress =>
      ffAt < 0 ? 0 : ((time - ffAt) * 1000 / _ffMs).clamp(0.0, 1.0);

  /// HTML `State.tempMatka` (shown rounded) and `tempSteel`.
  int get matkaTemp =>
      (_startTemp + (_matkaEndTemp - _startTemp) * ffProgress).round();
  int get steelTemp => _startTemp.round();

  /// HTML `activeDragTarget`: what the current step lets the learner drag.
  _Item? get dragItem {
    if (done || busy) return null;
    if (scenario == 0) return step <= 2 ? _Item.jug : null;
    return switch (step) {
      1 || 3 => _Item.bag,
      2 => _Item.smallPot,
      4 => _Item.jug,
      5 => _Item.veggies,
      6 => sackOn ? null : _Item.sack,
      7 => _Item.sack,
      _ => null,
    };
  }

  /// The 'Fast Forward' button is shown (HTML `btn-action-timelapse`).
  bool get canFastForward =>
      !done &&
      ffAt < 0 &&
      ((scenario == 0 && step == 3) || (scenario == 1 && step == 6 && sackOn));

  /// The 'Finish Observation' button is shown (HTML `btn-action-main`).
  bool get canFinish =>
      done || (scenario == 0 && step == 4) || (scenario == 1 && step == 8);

  _V posOf(_Item item) => switch (item) {
    _Item.jug => jug.at(time),
    _Item.bag => bag.at(time),
    _Item.smallPot => smallPot.at(time),
    _Item.veggies => veggies.at(time),
    _Item.sack => sack.at(time),
    _Item.matka => _matkaAt,
    _Item.steel => _steelAt,
    _Item.bigPot => _bigAt,
    _Item.plate => _plateAt,
  };

  /// HTML `userData.homePos`.
  _V homeOf(_Item item) => switch (item) {
    _Item.jug => scenario == 0 ? _jug1Home : _jug2Home,
    _Item.bag => _bagHome,
    _Item.smallPot => _smallHome,
    _Item.veggies => _vegHome,
    _Item.sack => _sackHome,
    _ => posOf(item),
  };

  void setMove(_Item item, _Move move) {
    switch (item) {
      case _Item.jug:
        jug = move;
      case _Item.bag:
        bag = move;
      case _Item.smallPot:
        smallPot = move;
      case _Item.veggies:
        veggies = move;
      case _Item.sack:
        sack = move;
      default:
        break;
    }
  }

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = null;
    jug = _Move.still(index == 0 ? _jug1Home : _jug2Home);
    bag = const _Move.still(_bagHome);
    smallPot = const _Move.still(_smallHome);
    veggies = const _Move.still(_vegHome);
    sack = const _Move.still(_sackHome);
    pourTool = null;
    pourInto = null;
    pourStep = 0;
    tilt = const _Ramp.still(0);
    streamOn = -10;
    streamOff = -10;
    matkaWater = false;
    steelWater = false;
    matkaLevel = const _Ramp.still(_waterLow);
    steelLevel = const _Ramp.still(_waterLow);
    thermo = false;
    ffAt = -10;
    sandBase = const _Ramp.still(0);
    gap = const _Ramp.still(_gapFloor);
    wet = const _Ramp.still(0);
    sackK = const _Ramp.still(1);
    smallIn = false;
    vegIn = false;
    sackOn = false;
    lifted = false;
  }
}

// --------------------------------------------------- picking and framing

/// Screen rectangle of a box seen through the camera: centre [c],
/// half-widths [hx] / [hz], from height [y0] to [y1] above [c].
Rect _boxRect(_V c, double hx, double y0, double y1, double hz) {
  var rect = Rect.zero;
  var first = true;
  for (final x in [-hx, hx]) {
    for (final y in [y0, y1]) {
      for (final z in [-hz, hz]) {
        final o = _cam.p(c + _V(x, y, z));
        final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
        rect = first ? r : rect.expandToInclude(r);
        first = false;
      }
    }
  }
  return rect;
}

/// The pots on screen (drop targets).
final Rect _matkaRect = _boxRect(_matkaAt, 4, 0, 8.7, 4);
final Rect _steelRect = _boxRect(_steelAt, 4.7, 0, 5.7, _steelR);
final Rect _bigRect = _boxRect(_bigAt, 5, 0, 10.8, 5);
final Rect _smallInRect = _boxRect(_smallIn, 2.4, 0, 5.6, 2.4);

/// Room kept for a thermometer label above [at] (its widest, at the
/// largest label size).
Rect _thermoRect(_V at) {
  final o = _cam.p(at);
  return Rect.fromLTRB(o.dx - 65, o.dy - 44, o.dx + 65, o.dy);
}

/// Rectangles (design px, scene unframed) the framing keeps clear of the
/// floating mission card and inside the free canvas: every object the
/// learner drags at its home, every drop target and the thermometer
/// labels.
final List<List<Rect>> _keepRects = [
  [
    _boxRect(_jug1Home, 3, 0, 4.6, 2),
    _matkaRect,
    _steelRect,
    _thermoRect(_matkaThermoAt),
    _thermoRect(_steelThermoAt),
  ],
  [
    _boxRect(_smallHome, 2.4, 0, 5.6, 2.4),
    _boxRect(_bagHome, 1.5, 0, 4, 1),
    _boxRect(_jug2Home, 3, 0, 4.6, 2),
    _bigRect,
    _boxRect(_vegHome, 1.6, 0, 1.4, 1.6),
    _boxRect(_plateAt, 4, 0, 1.6, 4),
    _boxRect(_sackHome, _sackSkirtR, -0.9, 0.2, _sackSkirtR),
    _boxRect(_bigAt.atY(_bigShape.top), 3.6, -0.9, 0.6, 3.6),
  ],
];

/// Rectangles that only have to stay on the canvas (the tools while they
/// pour above the pots).
final List<List<Rect>> _seenRects = [
  [
    _boxRect(_jugPourMatka, 4, -1.5, 5, 2),
    _boxRect(_jugPourSteel, 4, -1.5, 5, 2),
  ],
  [_boxRect(_bagPour, 3, -1.2, 4.2, 1.5), _boxRect(_jug2Pour, 4, -1.5, 5, 2)],
];

/// How the scene layer is scaled and shifted on the stage (design px) so
/// what the learner works with stays clear of the shell's tool column,
/// HUD chip and floating mission card; and where scene labels may go
/// (scene coordinates).
@immutable
class _Framing {
  const _Framing(
    this.k,
    this.dx,
    this.dy, {
    this.labelLeft = 0,
    this.labelRight = 1000,
    this.labelBottom = 560,
  });

  static const identity = _Framing(1, 0, 0);

  final double k;
  final double dx;
  final double dy;
  final double labelLeft;
  final double labelRight;
  final double labelBottom;

  Matrix4 get matrix =>
      Matrix4(k, 0, 0, 0, 0, k, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
}

/// Finds the largest scale (1 down to [_minFrameScale]) and the smallest
/// shift that keep every [keep] and [seen] rectangle inside [free] and
/// every [keep] rectangle off [card] (right of it or below it).
(double, double, double)? _solveFraming(
  List<Rect> keep,
  List<Rect> seen,
  Rect free,
  Rect? card,
) {
  final all = [...keep, ...seen];
  for (var k = 1.0; k >= _minFrameScale - 1e-9; k -= _frameScaleStep) {
    (double, double, double)? best;
    var bestCost = double.infinity;
    for (var i = 0; i <= _frameShiftSteps; i++) {
      final dx = (i.isOdd ? -1 : 1) * ((i + 1) ~/ 2) * _frameShiftStep;
      if (dx.abs() >= bestCost) break;
      var lo = -double.infinity;
      var hi = double.infinity;
      var fits = true;
      for (final r in all) {
        final l = r.left * k + dx;
        final rt = r.right * k + dx;
        if (l < free.left || rt > free.right) {
          fits = false;
          break;
        }
        lo = math.max(lo, free.top - r.top * k);
        hi = math.min(hi, free.bottom - r.bottom * k);
      }
      if (!fits) continue;
      if (card != null) {
        for (final r in keep) {
          final l = r.left * k + dx;
          final rt = r.right * k + dx;
          if (l < card.right && rt > card.left) {
            lo = math.max(lo, card.bottom - r.top * k);
          }
        }
      }
      if (lo > hi) continue;
      final dy = 0.0.clamp(lo, hi);
      final cost = dx.abs() + dy.abs();
      if (cost < bestCost) {
        bestCost = cost;
        best = (k, dx, dy);
      }
    }
    if (best != null) return best;
  }
  return null;
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the object the current step lets the learner drag ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _CoolingLabState extends State<Ch8A5EvaporationsCoolingEffectPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in scene design pixels for the current
  /// stage scale and framing.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  /// HTML `dragPlane` (facing the camera through the object) and
  /// `dragOffset`.
  double _planeD = 0;
  _V _grabOffset = _V.zero;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// Measured height of the shell's floating mission card (dp), and a
  /// pending measurement.
  double? _cardHeight;
  bool _cardCheck = false;

  /// The last framing and what it was computed for.
  Object? _framingKey;
  _Framing _framing = _Framing.identity;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  int get _stepCount => _stepCounts[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]` (Scenario 2 keeps the step 7 line
  /// after the sack is lifted, as the HTML did).
  String get _hudKey =>
      's${_scene.scenario + 1}_hud_${math.min(_scene.step, _stepCount)}';

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

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame only advances the clock and repaints the canvas.
  void _onTick(Duration elapsed) {
    _scene.time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _frame.value = _scene.time;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _moved = false;
    });
    _lab.resetView(sound: false);
  }

  void _setBusy(bool busy) {
    if (!mounted || _scene.busy == busy) return;
    setState(() => _scene.busy = busy);
  }

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone.
  void _toast(String key, {bool error = false, bool sound = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: sound);
    _toastId = _lab.toast?.id;
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null || shown.id != _toastId) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(_t(key), isError: shown.isError, sound: false);
      _toastId = _lab.toast?.id;
    });
  }

  /// HTML `triggerMainAction()`: the summary popup ('Observation Complete!',
  /// 'Scenario n Complete!', the summary), with the ding.
  void _conclude() {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () => '${_t('sum_s${sc + 1}_title')}\n\n${_t('sum_s${sc + 1}')}',
      extra: sc == 0 ? _readings : null,
    );
  }

  /// The two thermometers before and after the fast-forward (added to the
  /// Scenario 1 summary).
  Widget _readings() {
    String c(int v) => labFormat(_t('unit_c'), {'v': v});
    String row(int b) =>
        labFormat(_t('res_row'), {'a': c(_startTemp.round()), 'b': c(b)});
    return _ReadingTable(
      palette: _lab.palette,
      title: _t('res_title'),
      rows: [
        (_t('lbl_earthen_pot'), row(_scene.matkaTemp)),
        (_t('lbl_steel_pot'), row(_scene.steelTemp)),
      ],
    );
  }

  // ------------------------------------------------------- the actions

  /// HTML `animatePour(tool, pourPos, fillTarget)`: the tool glides to its
  /// pour position, tilts, the stream runs while the water / sand rises,
  /// then the tool tilts back and returns home and the step advances.
  void _pour(_Item tool, _V from) {
    final s = _scene;
    final step = s.step;
    final _V at;
    if (s.scenario == 0) {
      at = step == 1 ? _jugPourMatka : _jugPourSteel;
    } else {
      at = tool == _Item.bag ? _bagPour : _jug2Pour;
    }
    final home = s.homeOf(tool);
    setState(() {
      s
        ..busy = true
        ..pourTool = tool
        ..pourInto = s.scenario == 0
            ? (step == 1 ? _Item.matka : _Item.steel)
            : _Item.bigPot
        ..pourStep = step
        ..streamOn = -10
        ..streamOff = -10
        ..setMove(
          tool,
          _Move(from, at, s.time, _pourMoveMs / 1000, Curves.easeOutQuad),
        );
    });
    _lab.after(const Duration(milliseconds: _pourMoveMs), () {
      if (!mounted) return;
      _Sound.drop.play();
      s.tilt = _Ramp(0, _pourTilt, s.time, _tiltMs / 1000);
    });
    _lab.after(const Duration(milliseconds: _streamOnMs), () {
      if (!mounted) return;
      s.streamOn = s.time;
      _startFill(step);
    });
    _lab.after(const Duration(milliseconds: _streamOffMs), () {
      if (!mounted) return;
      s
        ..streamOff = s.time
        ..tilt = _Ramp(s.tilt.at(s.time), 0, s.time, _tiltMs / 1000);
    });
    _lab.after(const Duration(milliseconds: _returnMs), () {
      if (!mounted) return;
      s.setMove(tool, _Move(at, home, s.time, _homeMs / 1000));
    });
    _lab.after(const Duration(milliseconds: _pourDoneMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..pourTool = null
          ..pourInto = null
          ..step = step + 1;
        // HTML: the thermometer labels appear once both pots are filled.
        if (s.scenario == 0 && s.step == 3) s.thermo = true;
      });
    });
  }

  /// What the pour fills: the matka / the steel pot (S1); the sand layer,
  /// the sand in the gap or the wet sand (S2).
  void _startFill(int step) {
    final s = _scene;
    final t = s.time;
    if (s.scenario == 0) {
      if (step == 1) {
        s
          ..matkaWater = true
          ..matkaLevel = _Ramp(_waterLow, _matkaWaterHigh, t, _fillSeconds);
      } else {
        s
          ..steelWater = true
          ..steelLevel = _Ramp(_waterLow, _steelWaterHigh, t, _fillSeconds);
      }
      return;
    }
    switch (step) {
      case 1:
        s.sandBase = _Ramp(0, 1, t, _fillSeconds);
      case 3:
        s.gap = _Ramp(_gapFloor, _gapTop, t, _fillSeconds);
      default:
        s.wet = _Ramp(0, 1, t, _fillSeconds);
    }
  }

  /// HTML place tweens (600 ms, Quadratic.Out) with the `click` at the end.
  void _place(
    _Item item,
    _V from,
    _V to,
    VoidCallback then, {
    int ms = _placeMs,
  }) {
    final s = _scene;
    setState(() {
      s
        ..busy = true
        ..setMove(item, _Move(from, to, s.time, ms / 1000, Curves.easeOutQuad));
    });
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _Sound.click.play();
      setState(() {
        s.busy = false;
        then();
      });
    });
  }

  /// HTML `checkDrop()` miss: the object slides home (500 ms,
  /// Quadratic.Out). The HTML said nothing; the toast [key] says where it
  /// belongs.
  void _sendHome(_Item item, _V from, String key) {
    final s = _scene;
    _toast(key, error: true, sound: true);
    setState(() {
      s
        ..busy = true
        ..setMove(
          item,
          _Move(
            from,
            s.homeOf(item),
            s.time,
            _homeMs / 1000,
            Curves.easeOutQuad,
          ),
        );
    });
    _lab.after(const Duration(milliseconds: _homeMs), () => _setBusy(false));
  }

  /// HTML `triggerTimeLapse()`: 4.5 s of evaporation; S1 the matka cools
  /// from 30 °C to 22 °C, S2 the vegetables on the plate wilt.
  void _fastForward() {
    final s = _scene;
    if (s.busy || !s.canFastForward) return;
    setState(() {
      s
        ..busy = true
        ..ffAt = s.time;
    });
    _spawnPuffs();
    _lab.after(const Duration(milliseconds: _ffMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = s.step + 1;
      });
    });
  }

  /// HTML `createEvaporationParticles`. The HTML only created them once the
  /// step had moved on (`State.step > 3` / `> 6` while the fast-forward ran
  /// on step 3 / 6), so none ever showed; here they rise during the
  /// fast-forward, from the pot's outer surface (S1 its front, S2 beside
  /// the cut).
  void _spawnPuffs() {
    final s = _scene;
    final sc = s.scenario;
    final shape = sc == 0 ? _matkaShape : _bigShape;
    final at = sc == 0 ? _matkaAt : _bigAt;
    for (var i = 0; i < s.puffs.length; i++) {
      final double a;
      if (sc == 0) {
        a = -0.2 + _rnd.nextDouble() * (math.pi + 0.4);
      } else {
        final side = _rnd.nextBool() ? math.pi : 0.0;
        a = side + (_rnd.nextDouble() - 0.5) * 0.9;
      }
      final y = 1.2 + _rnd.nextDouble() * (shape.neckBase - 1.6);
      final r = shape.radiusAt(y) + 0.25;
      s.puffs[i]
        ..at = at + _V(math.cos(a) * r, y, math.sin(a) * r)
        ..rise = 4 + _rnd.nextDouble() * 2
        ..heatDy = _rnd.nextDouble() * 1.5
        ..heatRise = 4 + _rnd.nextDouble() * 2
        ..start = s.time + i * _puffGap;
    }
  }

  /// HTML 'Finish Observation': opens the summary; afterwards it opens it
  /// again.
  void _finish() {
    final s = _scene;
    if (!s.canFinish || s.busy) return;
    if (!s.done) setState(() => s.done = true);
    _conclude();
  }

  // -------------------------------------------------------------- gestures

  /// Where an object is carried from (its body's centre).
  _V _carryPoint(_Item item, _V pos) => switch (item) {
    _Item.jug || _Item.bag => pos + const _V(0, 2, 0),
    _Item.smallPot => pos + const _V(0, 2.7, 0),
    _Item.veggies => pos + const _V(0, 0.6, 0),
    _ => pos,
  };

  /// The object's outline on screen, at least a 48 dp target around its
  /// centre.
  Rect _hitRect(_Item item) {
    final s = _scene;
    final p = s.posOf(item);
    final rect = switch (item) {
      _Item.jug => _boxRect(p + const _V(-0.25, 0, 0), 2.75, 0, 4.6, 2),
      _Item.bag => _boxRect(p, 1.5, 0, 4, 1),
      _Item.smallPot => _boxRect(p, 2.4, 0, 5.6, 2.4),
      _Item.veggies => _boxRect(p, 1.6, 0, 1.4, 1.6),
      _Item.sack => _boxRect(
        p,
        _sackSkirtR * s.sackK.at(s.time),
        -0.9,
        0.2,
        _sackSkirtR * s.sackK.at(s.time),
      ),
      _Item.matka => _matkaRect,
      _Item.steel => _steelRect,
      _Item.bigPot => _bigRect,
      _Item.plate => _boxRect(_plateAt, 4, 0, 1.6, 4),
    };
    return rect.expandToInclude(
      Rect.fromCircle(center: _cam.p(_carryPoint(item, p)), radius: _touch),
    );
  }

  /// The object under [at]: the one the step is about first.
  _Item? _itemAt(Offset at) {
    final s = _scene;
    final drag = s.dragItem;
    if (drag != null && _hitRect(drag).contains(at)) return drag;
    final items = s.scenario == 0
        ? const [_Item.jug, _Item.matka, _Item.steel]
        : [
            _Item.sack,
            _Item.veggies,
            _Item.jug,
            _Item.bag,
            if (!s.smallIn) _Item.smallPot,
            _Item.bigPot,
            _Item.plate,
          ];
    for (final item in items) {
      if (_hitRect(item).contains(at)) return item;
    }
    return null;
  }

  /// HTML `pointerdown`: only the step's object can be picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null) return false;
    final item = s.dragItem;
    return item != null && _hitRect(item).contains(event.localPosition);
  }

  /// HTML `startDrag`: the drag plane faces the camera through the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final item = s.dragItem;
    if (item == null || !_hitRect(item).contains(d.localPosition)) return;
    final pos = s.posOf(item);
    _planeD = _cam.f.dot(pos);
    final hit = _cam.onPlane(d.localPosition, _cam.f, _planeD);
    _grabOffset = hit == null ? _V.zero : hit - pos;
    _moved = false;
    setState(() => s.held = item);
  }

  void _onDragStart(DragStartDetails _) {
    if (_scene.held == null) return;
    _moved = true;
    _Sound.pickup.play();
  }

  /// HTML `pointermove`: the object follows the finger on its plane and
  /// never goes below the table (`position.y < 0` → 0).
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    final hit = _cam.onPlane(d.localPosition, _cam.f, _planeD);
    if (hit == null) return;
    final p = hit - _grabOffset;
    final floor = item == _Item.sack ? _sackHome.y : 0.0;
    s.setMove(item, _Move.still(p.y < floor ? p.atY(floor) : p));
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup`: a dragged object is checked against the step's
  /// target; a mere tap leaves it where it was.
  void _release() {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    setState(() => s.held = null);
    if (!_moved) return;
    _moved = false;
    _checkDrop(item);
  }

  /// HTML `checkDrop()`. The HTML accepted a release anywhere within 8
  /// units of the target (the vegetables were within reach of the small
  /// pot without being moved at all); here the object's body must be let
  /// go over the target pot on screen.
  void _checkDrop(_Item item) {
    final s = _scene;
    final from = s.posOf(item);
    final at = _cam.p(_carryPoint(item, from));
    bool over(Rect r) => r.inflate(_dropMargin).contains(at);
    if (s.scenario == 0) {
      final matka = over(_matkaRect);
      final steel = over(_steelRect);
      if (s.step == 1) {
        if (matka) {
          _pour(item, from);
        } else {
          _sendHome(item, from, steel ? 'e_matka_first' : 'e_jug_matka');
        }
      } else if (steel) {
        _pour(item, from);
      } else {
        _sendHome(item, from, matka ? 'e_matka_full' : 'e_jug_steel');
      }
      return;
    }
    final big = over(_bigRect);
    switch (s.step) {
      case 1 || 3:
        big ? _pour(item, from) : _sendHome(item, from, 'e_bag_pot');
      case 2:
        if (big) {
          _place(item, from, _smallIn, () {
            s
              ..smallIn = true
              ..step = 3;
          });
        } else {
          _sendHome(item, from, 'e_small_pot');
        }
      case 4:
        big ? _pour(item, from) : _sendHome(item, from, 'e_jug_sand');
      case 5:
        if (over(_smallInRect)) {
          _place(item, from, _vegIn, () {
            s
              ..vegIn = true
              ..step = 6;
          });
        } else {
          _sendHome(item, from, 'e_veg_pot');
        }
      case 6:
        if (big) {
          s.sackK = _Ramp(1, _sackOnK, s.time, _placeMs / 1000);
          _place(item, from, _sackOnAt, () => s.sackOn = true);
        } else {
          _sendHome(item, from, 'e_sack_cover');
        }
      default:
        // Step 7: lift the sack off the cooler; it goes back home (HTML
        // tween to `homePos`). Let go over the cooler, it settles back.
        if (big) {
          _toast('e_sack_lift', error: true, sound: true);
          _place(item, from, _sackOnAt, () {}, ms: _homeMs);
        } else {
          s.sackK = _Ramp(s.sackK.at(s.time), 1, s.time, _placeMs / 1000);
          _place(item, from, _sackHome, () {
            s
              ..sackOn = false
              ..lifted = true
              ..step = 8;
          });
        }
    }
  }

  /// Where the sack rests on the cooler: over the large pot's neck.
  static final _V _sackOnAt = _bigAt.atY(_bigShape.top + _bigShape.tube);

  /// Taps: the step's object repeats what to do with it; another object
  /// gives the same hint as an error (the HTML ignored taps).
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done || s.held != null) return;
    final item = _itemAt(d.localPosition);
    if (item == null) return;
    if (item == s.dragItem) {
      _toast(_hudKey);
    } else {
      _toast(_hudKey, error: true, sound: true);
    }
  }

  // -------------------------------------------------------------- framing

  /// The framing for the screen as it will be once the sidebar has settled:
  /// the scene shifts (and on small phones shrinks) so the objects stay
  /// left of the tool column, above the HUD chip and, with the sidebar
  /// collapsed, off the floating mission card at the top left.
  _Framing _framingFor(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final uiScale = context.labScale;
    final open = _lab.isSidebarOpen;
    final cardOn = !open && _lab.isLabActive;
    final cardH = cardOn
        ? (_cardHeight ?? size.height * (size.height < 480 ? 0.55 : 0.45))
        : 0.0;
    final key = (
      _scene.scenario,
      open,
      size,
      pad,
      _lab.sidebarFraction,
      cardH.round(),
      cardOn,
    );
    if (key == _framingKey) return _framing;
    _framingKey = key;

    // The shell's sidebar rule: 20 % … 50 % of the screen, at least 180 dp.
    final sideMin = math.max(180.0, size.width * 0.2);
    final sideMax = math.max(sideMin, size.width * 0.5);
    final canvasW = open
        ? size.width -
              (size.width * _lab.sidebarFraction).clamp(sideMin, sideMax)
        : size.width;
    final fit = math.min(canvasW / _design.width, size.height / _design.height);
    if (!(fit > 0 && fit.isFinite)) return _framing = _Framing.identity;
    final stageLeft = (canvasW - _design.width * fit) / 2;
    final stageTop = (size.height - _design.height * fit) / 2;
    double dx(double x) => (x - stageLeft) / fit;
    double dy(double y) => (y - stageTop) / fit;
    final gap = _frameGap / fit;
    // Touches only reach the design box, so the scene stays inside it.
    final free = Rect.fromLTRB(
      math.max(0.0, dx(open ? 0 : pad.left)) + gap,
      math.max(0.0, dy(pad.top)) + gap,
      math.min(_design.width, dx(canvasW - _toolClearance - pad.right)) - gap,
      math.min(
            _design.height,
            dy(
              size.height - pad.bottom - (open ? 8 + _hudHeight * uiScale : 0),
            ),
          ) -
          gap,
    );
    Rect? card;
    if (cardOn) {
      final left = _missionCardLeft + pad.left;
      final top = _missionCardTop + pad.top;
      card = Rect.fromLTRB(
        dx(left) - gap,
        dy(top) - gap,
        dx(left + _missionCardWidth(size, uiScale)) + gap,
        dy(top + cardH) + gap,
      );
    }
    final sc = _scene.scenario;
    final keep = _keepRects[sc];
    final seen = _seenRects[sc];
    // Best: the tools pouring above the pots also stay clear of the card,
    // unless that would shrink the scene much more than keeping only what
    // the learner touches clear of it.
    final clearKeep = _solveFraming(keep, seen, free, card);
    final clearAll = card == null || clearKeep == null
        ? null
        : _solveFraming([...keep, ...seen], const [], free, card);
    final solved = clearAll != null && clearAll.$1 >= clearKeep!.$1 - _seenSlack
        ? clearAll
        : clearKeep ?? _solveFraming(keep, seen, free, null);
    if (solved == null) return _framing = _Framing.identity;
    final (k, ox, oy) = solved;
    return _framing = _Framing(
      k,
      ox,
      oy,
      labelLeft: (free.left - ox) / k,
      labelRight: (free.right - ox) / k,
      labelBottom: (free.bottom - oy) / k,
    );
  }

  /// Measures the shell's floating mission card after the frame, so the
  /// framing keeps the scene clear of the card as it really is.
  void _scheduleCardCheck() {
    if (_cardCheck) return;
    _cardCheck = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardCheck = false;
      if (!mounted || _lab.isSidebarOpen) return;
      final h = _missionCardHeight();
      if (h == null) return;
      if (_cardHeight == null || (h - _cardHeight!).abs() > 1) {
        setState(() => _cardHeight = h);
      }
    });
  }

  /// Height of the LAB FRAMEWORK's floating mission card as laid out.
  double? _missionCardHeight() {
    double? height;
    void visit(Element e) {
      if (height != null) return;
      if (e.widget is _FloatingMissionCard) {
        final box = e.renderObject;
        if (box is RenderBox && box.hasSize) height = box.size.height;
        return;
      }
      e.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return height;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-action-timelapse` ('Fast Forward') and `#btn-action-main`
  /// ('Finish Observation'); the second one stays to re-open the summary.
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.canFastForward)
        LabAction(
          label: _t('btn_timelapse'),
          icon: Icons.fast_forward_rounded,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          enabled: !s.busy,
          onTap: _fastForward,
        ),
      if (s.canFinish)
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.check_circle_rounded,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: !s.done,
          enabled: !s.busy,
          // The summary plays the HTML `ding`.
          silent: true,
          onTap: _finish,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        if (_lab.lang != _builtLang) {
          final previous = _builtLang;
          _builtLang = _lab.lang;
          _retranslateToast(previous);
        }
        if (!_lab.isSidebarOpen && _lab.isLabActive) _scheduleCardCheck();
        final p = _lab.palette;
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        final n = data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          // The last step ('… then TAP Finish Observation') stays current
          // until the summary opens (Scenario 2 lifts the sack first).
          currentStep: s.done ? n + 1 : math.min(s.step, n),
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the summary
          // has been opened.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          stage: _stage(),
        );
      },
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final framing = _framingFor(context);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / (fit * framing.k);
          _labelSize =
              _labelPx *
              (_labelFullScale / fit).clamp(1.0, _labelMaxBoost) /
              framing.k;
        }
        return LabStage(
          designSize: _design,
          // The framing moves the whole scene layer (painting and hit
          // tests), so gestures arrive in the scene's own coordinates.
          child: AnimatedContainer(
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            transform: framing.matrix,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags and taps on the scene are not screen-reader
                // actions; the scene is announced by its label instead.
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
                          ..onStart = _onDragStart
                          ..onUpdate = _onDragUpdate
                          ..onEnd = _onDragEnd
                          ..onCancel = _release,
                      ),
                  TapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer
                      >(
                        () => TapGestureRecognizer(debugOwner: this),
                        (r) => r.onTapUp = _onTap,
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
                        framing: framing,
                      ),
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

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
    return _ObservationList(
      palette: p,
      scale: f,
      empty: _t('obs_empty'),
      entries: [
        for (var i = 1; i <= done; i++)
          (labFormat(_t('obs_step'), {'n': i}), steps[i - 1].observation),
      ],
    );
  }
}

/// The sidebar's observation list: one line per step done.
class _ObservationList extends StatelessWidget {
  const _ObservationList({
    required this.palette,
    required this.scale,
    required this.empty,
    required this.entries,
  });

  final LabPalette palette;
  final double scale;
  final String empty;

  /// (step heading, observation text), in step order.
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Container(
      padding: EdgeInsets.all(10 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: entries.isEmpty
          ? Text(
              empty,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 11.5 * f,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 8 * f),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1 * f),
                          child: Icon(
                            Icons.check_circle,
                            size: 13 * f,
                            color: p.success,
                          ),
                        ),
                        SizedBox(width: 6 * f),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${entries[i].$1}: ',
                                  style: TextStyle(
                                    color: p.textStrong,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(text: entries[i].$2),
                              ],
                            ),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 11.5 * f,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
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

/// The thermometer readings shown in the Scenario 1 summary.
class _ReadingTable extends StatelessWidget {
  const _ReadingTable({
    required this.palette,
    required this.title,
    required this.rows,
  });

  final LabPalette palette;
  final String title;

  /// (pot, "start → end") per row.
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.accentInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          for (final (pot, value) in rows)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.thermostat, size: 16, color: p.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pot,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
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

/// Segments around lathes (pots, jug, sack) and rings.
const int _sides = 20;
const int _ringSides = 28;

/// One quad of a lathe, reused from frame to frame.
class _Facet {
  final List<Offset> pts = List.filled(4, Offset.zero);
  double depth = 0;
  Color color = const Color(0x00000000);
}

int _farFirst(_Facet a, _Facet b) => b.depth.compareTo(a.depth);

/// Paints, paths and facets reused by every frame (no allocation per
/// frame beyond the projected points).
class _Pens {
  final Paint fill = Paint();

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Round-ended thick lines (rims, handles, streams).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// Even-odd path for rings (the sand between the pots).
  final Path ringPath = Path()..fillType = PathFillType.evenOdd;

  final List<_Facet> _pool = [];
  int _used = 0;
  final List<_Facet> facets = [];

  /// Starts a new list of facets (the previous list has been drawn).
  void beginFacets() {
    _used = 0;
    facets.clear();
  }

  _Facet takeFacet() {
    if (_used == _pool.length) _pool.add(_Facet());
    final f = _pool[_used++];
    facets.add(f);
    return f;
  }
}

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background and table) and the label text painters. Owned by the page
/// state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _readings = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  bool _backdropDark = true;
  bool? _readingsDark;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang != _lang || labelSize != _labelSize) {
      _disposeAll(_labels);
      _disposeAll(_readings);
      _lang = lang;
      _labelSize = labelSize;
    }
    if (dark != _readingsDark) {
      _disposeAll(_readings);
      _readingsDark = dark;
    }
  }

  TextPainter label(String text) =>
      _labels[text] ??= _painter(text, _Colors.white, _labelSize);

  /// Thermometer label text ("30°C"), in the theme's chip text colour.
  TextPainter reading(String text) => _readings[text] ??= _painter(
    text,
    (_readingsDark ?? true) ? _Colors.chipDarkText : _Colors.chipLightText,
    _labelSize * 1.15,
  );

  TextPainter _painter(String text, Color color, double size) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: labLetterSpacing(text, 0.3),
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// The static part of the scene (background and table), recorded once.
  ui.Picture backdrop(bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null && dark == _backdropDark) return cached;
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), dark, size, pens);
    _backdropDark = dark;
    return _backdrop = recorder.endRecording();
  }

  static void _disposeAll(Map<String, TextPainter> map) {
    for (final tp in map.values) {
      tp.dispose();
    }
    map.clear();
  }

  void dispose() {
    _disposeAll(_labels);
    _disposeAll(_readings);
    _backdrop?.dispose();
    _backdrop = null;
  }
}

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n]; [shine] adds a specular highlight
/// towards the camera from [at] (metal).
Color _lit(Color c, _V n, {double shine = 0, _V? at}) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  var out = Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
  if (shine > 0 && at != null) {
    final h = (_light + (_eye - at).unit).unit;
    final spec = math.pow(math.max(0.0, n.dot(h)), 24).toDouble() * shine;
    out = Color.lerp(out, _Colors.white, spec.clamp(0.0, 1.0))!;
  }
  return out;
}

/// The inside of a surface with outward normal [n]: lit from the other
/// side and in shade.
Color _litInside(Color c, _V n) {
  final i =
      (_ambient + _diffuse * 0.5 * math.max(0.0, -n.dot(_light))) * _innerShade;
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// HTML highlight: [c] pulled towards the pulse colour by [glow].
Color _glowing(Color c, double glow) =>
    glow <= 0 ? c : Color.lerp(c, _Colors.pulse, glow)!;

/// Which part of a rim torus to draw.
enum _RimPart { near, far, back }

/// One face of an oriented box: its axis and the two axes across it.
enum _BoxFace { x, y, z }

/// Mesh drawing in the lab's camera.
class _Gfx {
  _Gfx(this.canvas, this.pens);

  final Canvas canvas;
  final _Pens pens;

  _Cam get cam => _cam;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// A surface of revolution (Three.js Sphere / Cylinder / Cone geometry):
  /// the [prof] (radius, height) points turned about the frame's axis at
  /// [base]. Drawn in two passes so contents sit inside it: first the
  /// inside of the far wall (and a floor disc, the far half of a rim),
  /// then [inside], then the outside facing the camera, a cap and the near
  /// half of the rim. With [cut] only the back half (z ≤ 0) is drawn (the
  /// HTML `frontClipPlane`), with the cut faces of a [wall] thick wall.
  void lathe(
    _V base,
    List<(double, double)> prof,
    Color color, {
    _Frame frame = _Frame.upright,
    bool cut = false,
    double shine = 0,
    double glow = 0,
    double? floorR,
    double floorY = 0,
    double? capR,
    double capY = 0,
    double? rimR,
    double rimY = 0,
    double rimTube = 0,
    double wall = 0,
    VoidCallback? inside,
    int sides = _sides,
  }) {
    if (floorR != null) {
      // The floor is seen from inside the pot, in its shade.
      disc(
        frame.at(base, 0, floorY, 0),
        floorR,
        _glowing(_litInside(color, frame.ey * -1), glow),
        frame,
        cut,
      );
    }
    _facets(base, prof, color, frame, cut, shine, glow, sides, front: false);
    if (rimR != null) {
      rim(
        frame.at(base, 0, rimY, 0),
        rimR,
        rimTube,
        _glowing(color, glow),
        frame,
        cut ? _RimPart.back : _RimPart.far,
      );
    }
    inside?.call();
    if (cut) {
      _cutFaces(base, prof, color, frame, wall);
      if (rimR != null) {
        for (final side in const [-1.0, 1.0]) {
          final c = frame.at(base, side * rimR, rimY, 0);
          canvas.drawCircle(
            cam.p(c),
            math.max(1.0, rimTube * cam.scaleAt(c)),
            pens.fill..color = _lit(labShade(color, -0.18), frame.ez),
          );
        }
      }
      return;
    }
    _facets(base, prof, color, frame, cut, shine, glow, sides, front: true);
    if (capR != null) {
      final c = frame.at(base, 0, capY, 0);
      if (frame.ey.dot(cam.eye - c) > 0) {
        disc(c, capR, _glowing(_lit(color, frame.ey), glow), frame);
      }
    }
    if (rimR != null) {
      rim(
        frame.at(base, 0, rimY, 0),
        rimR,
        rimTube,
        _glowing(color, glow),
        frame,
        _RimPart.near,
      );
    }
  }

  /// One pass of [lathe]: the facets turned away from the camera (seen
  /// from inside) or towards it, far ones first. With [cut] the back
  /// half's facets are all drawn in the first pass.
  void _facets(
    _V base,
    List<(double, double)> prof,
    Color color,
    _Frame fr,
    bool cut,
    double shine,
    double glow,
    int sides, {
    required bool front,
  }) {
    pens.beginFacets();
    final step = 2 * math.pi / sides;
    for (var i = 0; i < prof.length - 1; i++) {
      final (r0, y0) = prof[i];
      final (r1, y1) = prof[i + 1];
      final dr = r1 - r0, dy = y1 - y0;
      final len = math.sqrt(dr * dr + dy * dy);
      if (len < 1e-9) continue;
      final nr = dy / len, ny = -dr / len;
      for (var j = 0; j < sides; j++) {
        final a0 = j * step, a1 = (j + 1) * step, am = (a0 + a1) / 2;
        if (cut && math.sin(am) > 1e-9) continue;
        final dm = fr.across(am);
        final n = dm * nr + fr.ey * ny;
        final mid = base + dm * ((r0 + r1) / 2) + fr.ey * ((y0 + y1) / 2);
        final facing = n.dot(cam.eye - mid) > 0;
        if (!cut && facing != front) continue;
        final d0 = fr.across(a0), d1 = fr.across(a1);
        final f = pens.takeFacet()
          ..depth = cam.depth(mid)
          ..color = _glowing(
            facing
                ? _lit(color, n, shine: shine, at: mid)
                : _litInside(color, n),
            glow,
          );
        f.pts[0] = cam.p(base + d0 * r0 + fr.ey * y0);
        f.pts[1] = cam.p(base + d1 * r0 + fr.ey * y0);
        f.pts[2] = cam.p(base + d1 * r1 + fr.ey * y1);
        f.pts[3] = cam.p(base + d0 * r1 + fr.ey * y1);
      }
    }
    pens.facets.sort(_farFirst);
    for (final f in pens.facets) {
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        _to(path, i, f.pts[i]);
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = f.color);
      canvas.drawPath(path, pens.seam..color = f.color);
    }
  }

  /// The cut faces of a [_PotShape] wall where the clipping plane z = 0
  /// opens it: both sides of the wall and the floor slab.
  void _cutFaces(
    _V base,
    List<(double, double)> prof,
    Color color,
    _Frame fr,
    double wall,
  ) {
    if (wall <= 0) return;
    final c = _lit(labShade(color, -0.18), fr.ez);
    for (final side in const [-1.0, 1.0]) {
      final path = pens.path..reset();
      for (var i = 0; i < prof.length; i++) {
        final (r, y) = prof[i];
        _to(path, i, cam.p(fr.at(base, side * r, y, 0)));
      }
      for (var i = prof.length - 1; i >= 0; i--) {
        final (r, y) = prof[i];
        final o = cam.p(fr.at(base, side * math.max(0.0, r - wall), y, 0));
        path.lineTo(o.dx, o.dy);
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = c);
    }
    final (bottomR, _) = prof.first;
    poly([
      fr.at(base, -bottomR, 0, 0),
      fr.at(base, bottomR, 0, 0),
      fr.at(base, bottomR, _potFloor, 0),
      fr.at(base, -bottomR, _potFloor, 0),
    ], c);
  }

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A flat disc of radius [r] at [c] across the frame's axis; [half]
  /// keeps the back half (z ≤ 0).
  void disc(
    _V c,
    double r,
    Color color, [
    _Frame fr = _Frame.upright,
    bool half = false,
  ]) {
    final path = pens.path..reset();
    final n = half ? _ringSides ~/ 2 : _ringSides;
    for (var i = 0; i <= n; i++) {
      final a = half ? math.pi + i * math.pi / n : i * 2 * math.pi / n;
      _to(path, i, cam.p(c + fr.across(a) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// The back half (z ≤ 0) of a flat ring between [rIn] and [rOut] at [c].
  void halfRing(_V c, double rIn, double rOut, Color color) {
    final path = pens.path..reset();
    const n = _ringSides ~/ 2;
    for (var i = 0; i <= n; i++) {
      _to(
        path,
        i,
        cam.p(c + _Frame.upright.across(math.pi + i * math.pi / n) * rOut),
      );
    }
    for (var i = n; i >= 0; i--) {
      final o = cam.p(
        c + _Frame.upright.across(math.pi + i * math.pi / n) * rIn,
      );
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// TorusGeometry rim of radius [r] and tube [tube] at [c] across the
  /// frame's axis: the [part] nearer to / farther from the camera, or the
  /// back half left by the cut.
  void rim(_V c, double r, double tube, Color color, _Frame fr, _RimPart part) {
    final path = pens.path..reset();
    final toEye = cam.eye - c;
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      final d = fr.across(a);
      final keep = switch (part) {
        _RimPart.near => d.dot(toEye) > 0,
        _RimPart.far => d.dot(toEye) <= 0,
        _RimPart.back => math.sin(a) <= 1e-9,
      };
      if (!keep) {
        open = false;
        continue;
      }
      final o = cam.p(c + d * r);
      if (open) {
        path.lineTo(o.dx, o.dy);
      } else {
        path.moveTo(o.dx, o.dy);
        open = true;
      }
    }
    _tube(path, tube * cam.scaleAt(c), color, fr.ey);
  }

  /// Strokes [path] as a lit round tube of radius [r] (design px).
  void _tube(Path path, double r, Color color, _V n) {
    final w = math.max(1.2, 2 * r);
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w
        ..color = _lit(labShade(color, -0.1), n),
    );
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w * 0.35
        ..color = _lit(labShade(color, 0.3), n),
    );
  }

  /// A torus arc of radius [r] (tube [tube]) about [c] in the plane of
  /// [u], [v], from angle [a0] to [a1].
  void arc(
    _V c,
    double r,
    double tube,
    Color color,
    _V u,
    _V v,
    double a0,
    double a1,
  ) {
    final path = pens.path..reset();
    const n = 14;
    for (var i = 0; i <= n; i++) {
      final a = a0 + (a1 - a0) * i / n;
      _to(path, i, cam.p(c + u * (math.cos(a) * r) + v * (math.sin(a) * r)));
    }
    _tube(path, tube * cam.scaleAt(c), color, u.cross(v));
  }

  /// BoxGeometry at [c] with half sizes [hx], [hy], [hz] along the frame's
  /// axes: the faces seen by the camera, lit.
  void box(
    _V c,
    _Frame fr,
    double hx,
    double hy,
    double hz,
    Color color, {
    double glow = 0,
    double edge = 0.35,
  }) {
    for (final face in _BoxFace.values) {
      final (axis, h, u, hu, v, hv) = switch (face) {
        _BoxFace.x => (fr.ex, hx, fr.ey, hy, fr.ez, hz),
        _BoxFace.y => (fr.ey, hy, fr.ex, hx, fr.ez, hz),
        _BoxFace.z => (fr.ez, hz, fr.ex, hx, fr.ey, hy),
      };
      for (final sign in const [-1.0, 1.0]) {
        final n = axis * sign;
        final mid = c + n * h;
        if (n.dot(cam.eye - mid) <= 0) continue;
        final path = pens.path..reset();
        _to(path, 0, cam.p(mid - u * hu - v * hv));
        _to(path, 1, cam.p(mid + u * hu - v * hv));
        _to(path, 2, cam.p(mid + u * hu + v * hv));
        _to(path, 3, cam.p(mid - u * hu + v * hv));
        path.close();
        canvas.drawPath(
          path,
          pens.fill..color = _glowing(_lit(color, n), glow),
        );
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
  }

  /// A squashed sphere (the tomatoes): a lit oval of radii [rx] / [ry]
  /// with its shaded side away from the key light and a highlight.
  void blob(_V c, double rx, double ry, Color color) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    final w = rx * k, h = ry * k;
    canvas.drawOval(
      Rect.fromCenter(center: o, width: 2 * w, height: 2 * h),
      pens.fill..color = labShade(color, -0.3),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(w * 0.12, -h * 0.14),
        width: 2 * w * 0.84,
        height: 2 * h * 0.84,
      ),
      pens.fill..color = color,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(w * 0.34, -h * 0.38),
        width: 2 * w * 0.22,
        height: 2 * h * 0.22,
      ),
      pens.fill..color = labShade(color, 0.45),
    );
  }

  /// A round dot of radius [r] (world units) at [c].
  void dot(_V c, double r, Color color) {
    canvas.drawCircle(
      cam.p(c),
      math.max(1.2, r * cam.scaleAt(c)),
      pens.fill..color = color,
    );
  }

  /// A falling stream (the HTML `waterStream` / `sandStream` cylinders)
  /// from [top] straight down to [bottomY].
  void stream(_V top, double bottomY, double r, Color color) {
    if (bottomY >= top.y) return;
    final a = cam.p(top);
    final b = cam.p(top.atY(bottomY));
    final w = math.max(1.5, 2 * r * cam.scaleAt(top));
    canvas.drawLine(
      a,
      b,
      pens.limb
        ..strokeWidth = w
        ..color = color.withValues(alpha: 0.85),
    );
    canvas.drawLine(
      a + Offset(w * 0.18, 0),
      b + Offset(w * 0.18, 0),
      pens.limb
        ..strokeWidth = w * 0.25
        ..color = _Colors.white.withValues(alpha: 0.3),
    );
  }

  /// A wisp of heat: a short wavy vertical line [len] long from [c].
  void heat(_V c, double len, Color color) {
    final k = cam.scaleAt(c);
    final a = cam.p(c);
    final h = len * k;
    final amp = 0.12 * h;
    final path = pens.path
      ..reset()
      ..moveTo(a.dx, a.dy);
    const n = 8;
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      path.lineTo(a.dx + amp * math.sin(t * 3 * math.pi), a.dy - h * t);
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(1.2, 0.09 * k)
        ..color = color,
    );
  }

  /// Soft blurred shadow of an elliptic footprint on the table.
  void shadow(double x, double z, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, 0.003, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// A water surface (MeshPhong 0x38bdf8, opacity 0.8) of radius [r] at
  /// [c], with a soft reflection.
  void water(_V c, double r) {
    disc(c, r, _Colors.water.withValues(alpha: 0.8));
    disc(
      c + const _V(0.2, 0.001, -0.2) * r,
      r * 0.45,
      _Colors.white.withValues(alpha: 0.18),
    );
  }
}

/// The scene's static layer: background and the table
/// (`BoxGeometry(40, 2, 20)` at y -1, `materials.wood`).
void _paintBackdrop(Canvas canvas, bool dark, Size size, _Pens pens) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final g = _Gfx(canvas, pens);
  g.box(const _V(0, -1, 0), _Frame.upright, 20, 1, 10, _Colors.wood, edge: 0.4);
  // Wood grain along the table top.
  final grain = pens.stroke
    ..strokeWidth = 1
    ..color = labShade(_Colors.wood, -0.25).withValues(alpha: 0.35);
  for (var z = -8.5; z < 10; z += 2.2) {
    canvas.drawLine(_cam.p(_V(-19.5, 0, z)), _cam.p(_V(19.5, 0, z)), grain);
  }
}

/// `createVeggies()`: three tomatoes (radius 0.6, centre 0.6 up, a leaf on
/// top) and two carrots (cones of radius 0.4 and length 2 lying towards
/// the front, a leaf at the wide end). The HTML scattered them at random;
/// here they sit at fixed spots, drawn back to front: (offset, carrot?,
/// turn about y).
const List<(_V, bool, double)> _veggieLayout = [
  (_V(-0.45, 0.6, -0.4), false, 0),
  (_V(0.5, 0.6, -0.15), false, 0),
  (_V(0.3, 0.4, -1.1), true, 0.25),
  (_V(-0.55, 0.4, -0.9), true, -0.2),
  (_V(-0.05, 0.6, 0.4), false, 0),
];

/// `createJug()` body `CylinderGeometry(1.5, 2, 4)` (bottom radius 2, top
/// 1.5, from the base up) and spout `CylinderGeometry(0, 0.5, 1.5)` (a
/// cone 1.5 long, base radius 0.5).
const List<(double, double)> _jugProfile = [(2, 0), (1.5, 4)];
const List<(double, double)> _spoutProfile = [(0.5, 0), (0, 1.5)];

/// The plate: `CylinderGeometry(4, 4, 0.2)`.
const List<(double, double)> _plateProfile = [(4, 0), (4, 0.2)];

/// The matka's surface darkens where water seeps through, over the first
/// 1.5 s of the fast-forward (added; see `_Colors.earthenWet`).
const double _seepSeconds = 1.5;

/// HTML stand-in labels (`createStdLabel` offsets below each object).
const double _labelDropPot = 5;
const double _labelDropTool = 4;
const double _labelDropVeg = 2;
const double _labelDropSack = 3;

/// The bag of sand stands behind the jug, so a label below it (HTML -4)
/// would sit on the jug: its label goes just above the bag instead.
const double _labelRiseBag = 5.4;

/// Paints the HTML Three.js scene of the current scenario: S1 the matka,
/// the steel pot and the jug; S2 the pot-in-pot cooler (cut away at the
/// front), the small pot, the sand bag, the jug, the vegetables, the plate
/// and the jute sack.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.framing,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Where labels may go (scene coordinates).
  final _Framing framing;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  /// HTML `update3DHighlight()` on the object to drag (none while
  /// something moves).
  double _glowOf(_Item item) {
    final s = scene;
    if (s.busy || s.dragItem != item) return 0;
    return _pulseMax * (math.sin(s.time * _pulseRate) + 1) / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    canvas.drawPicture(cache.backdrop(isDark, size));
    final g = _Gfx(canvas, _pens);
    if (scene.scenario == 0) {
      _paintScenario1(g);
    } else {
      _paintScenario2(g);
    }
    _paintPuffs(g);
    _paintLabels(canvas);
  }

  /// Depth of [item] for painting far to near; the held object in front.
  double _depthOf(_Item item, _V pos) {
    if (scene.held == item) return double.negativeInfinity;
    final lift = switch (item) {
      _Item.matka || _Item.bigPot => 4.0,
      _Item.steel => 3.0,
      _Item.jug || _Item.bag || _Item.smallPot => 2.0,
      _ => 0.5,
    };
    return _cam.depth(pos + _V(0, lift, 0));
  }

  void _paintInOrder(_Gfx g, List<_Item> items) {
    final s = scene;
    final order = [
      for (final item in items) (item, _depthOf(item, s.posOf(item))),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final (item, _) in order) {
      switch (item) {
        case _Item.matka:
          _paintMatka(g);
        case _Item.steel:
          _paintSteel(g);
        case _Item.jug:
          _paintJug(g, s.jug.at(s.time));
        case _Item.bag:
          _paintBag(g, s.bag.at(s.time));
        case _Item.smallPot:
          _paintSmallPot(g, s.smallPot.at(s.time));
        case _Item.bigPot:
          _paintCooler(g);
        case _Item.veggies:
          _paintVeggies(g, s.veggies.at(s.time), 0, _glowOf(_Item.veggies));
        case _Item.plate:
          _paintPlate(g);
        case _Item.sack:
          _paintSack(g, s.sack.at(s.time));
      }
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _paintScenario1(_Gfx g) {
    final s = scene;
    final jug = s.jug.at(s.time);
    // Contact shadows; the key light at (10, 20, 15) casts them towards
    // -x / -z.
    g.shadow(_matkaAt.x - 0.7, _matkaAt.z - 0.6, 3.4, 3.0);
    g.shadow(_steelAt.x - 0.7, _steelAt.z - 0.6, 3.9, 3.3);
    if (jug.y < 0.5) g.shadow(jug.x - 0.5, jug.z - 0.4, 2.1, 1.8);
    _paintInOrder(g, const [_Item.matka, _Item.steel, _Item.jug]);
  }

  /// `matkaS1`: the earthen pot; the water rises inside it, and during the
  /// fast-forward its surface darkens where water seeps through.
  void _paintMatka(_Gfx g) {
    final s = scene;
    final sh = _matkaShape;
    final wet = s.ffAt < 0
        ? 0.0
        : ((s.time - s.ffAt) / _seepSeconds).clamp(0.0, 1.0);
    final color = Color.lerp(_Colors.earthen, _Colors.earthenWet, wet)!;
    g.lathe(
      _matkaAt,
      sh.profile,
      color,
      floorR: sh.bottomR - sh.wall,
      floorY: _potFloor,
      rimR: sh.neckR,
      rimY: sh.top,
      rimTube: sh.tube,
      inside: () {
        if (s.matkaWater) {
          final y = s.matkaLevel.at(s.time);
          final r = math.min(_matkaWaterR, sh.innerAt(y));
          g.water(_matkaAt.atY(y), r);
        }
        _paintStream(g, _Item.matka);
      },
    );
  }

  /// `steelS1`: the open steel pot with its rim and two handle rings.
  void _paintSteel(_Gfx g) {
    final s = scene;
    g.lathe(
      _steelAt,
      _steelProfile,
      _Colors.steel,
      shine: _steelShine,
      floorR: _steelR,
      floorY: _potFloor,
      rimR: _steelR,
      rimY: _steelH,
      rimTube: _steelTube,
      inside: () {
        if (s.steelWater) {
          g.water(_steelAt.atY(s.steelLevel.at(s.time)), _steelWaterR);
        }
        _paintStream(g, _Item.steel);
      },
    );
    for (final side in const [-1.0, 1.0]) {
      final c = _steelAt + _V(side * _steelR, _handleY, 0);
      final a0 = side > 0 ? -math.pi / 2 : math.pi / 2;
      g.arc(
        c,
        _handleR,
        _handleTube,
        _Colors.steel,
        _V.right,
        _V.up,
        a0,
        a0 + math.pi,
      );
    }
  }

  /// `createJug()`: body `CylinderGeometry(1.5, 2, 4)`, half-torus handle
  /// (radius 1.5) on its -x side and a cone spout up to the right; the
  /// whole jug tilts about its base while pouring.
  void _paintJug(_Gfx g, _V pos) {
    final s = scene;
    final tilt = s.pourTool == _Item.jug ? s.tilt.at(s.time) : 0.0;
    final fr = _Frame.rollZ(-tilt);
    final glow = _glowOf(_Item.jug);
    final color = _glowing(_Colors.jug, glow);
    g.arc(
      fr.at(pos, -1.5, 2, 0),
      1.5,
      0.2,
      color,
      fr.ex,
      fr.ey,
      math.pi / 2,
      3 * math.pi / 2,
    );
    g.lathe(
      pos,
      _jugProfile,
      _Colors.jug,
      frame: fr,
      shine: 0.3,
      glow: glow,
      capR: 1.5,
      capY: 4,
    );
    // `spout.rotation.z = -π/4`: its axis points up and to the right.
    const c45 = math.sqrt1_2;
    final axis = fr.ex * c45 + fr.ey * c45;
    final across = fr.ex * c45 - fr.ey * c45;
    g.lathe(
      fr.at(pos, 1.5, 3.5, 0) - axis * 0.75,
      _spoutProfile,
      _Colors.jug,
      frame: _Frame(across, axis, fr.ez),
      glow: glow,
      sides: 12,
    );
  }

  /// The stream of the pour going into [into], from the jug's spout or
  /// the bag's corner straight down to the water / sand surface. It grows
  /// down from the spout in 0.2 s and is drawn back up in 0.2 s (HTML
  /// `stream.scale.y`).
  void _paintStream(_Gfx g, _Item into) {
    final s = scene;
    final tool = s.pourTool;
    if (tool == null || s.pourInto != into || s.streamOn < 0) return;
    final t = s.time;
    double scale;
    if (s.streamOff >= 0) {
      scale = 1 - (t - s.streamOff) / _streamGrow;
    } else {
      scale = (t - s.streamOn) / _streamGrow;
    }
    scale = scale.clamp(0.0, 1.0);
    if (scale <= 0.01) return;
    final pos = s.posOf(tool);
    final fr = _Frame.rollZ(-s.tilt.at(t));
    final water = tool == _Item.jug;
    final top = water ? fr.at(pos, 1.5, 3.5, 0) : fr.at(pos, 1.5, 0, 0);
    final double surface;
    if (into == _Item.matka) {
      surface = s.matkaLevel.at(t);
    } else if (into == _Item.steel) {
      surface = s.steelLevel.at(t);
    } else if (s.pourStep == 1) {
      surface = _potFloor + _baseThick * s.sandBase.at(t);
    } else {
      surface = s.gap.at(t);
    }
    final bottom = math.max(surface, top.y - _streamLength * scale);
    g.stream(
      top,
      bottom,
      water ? _waterStreamR : _sandStreamR,
      water ? _Colors.stream : _sandColor(),
    );
  }

  /// HTML `materials.sandDry`, tweened to `sandWet` in step 4.
  Color _sandColor() =>
      Color.lerp(_Colors.sandDry, _Colors.sandWet, scene.wet.at(scene.time))!;

  // ---------------------------------------------------------- scenario 2

  void _paintScenario2(_Gfx g) {
    final s = scene;
    g.shadow(_bigAt.x - 0.8, _bigAt.z - 0.7, 4.2, 3.7);
    g.shadow(_plateAt.x - 0.4, _plateAt.z - 0.3, 4.2, 4);
    final small = s.smallPot.at(s.time);
    if (!s.smallIn && small.y < 0.5) {
      g.shadow(small.x - 0.4, small.z - 0.3, 1.6, 1.4);
    }
    final bag = s.bag.at(s.time);
    if (bag.y < 0.5) g.shadow(bag.x - 0.4, bag.z - 0.3, 1.8, 1.3);
    final jug = s.jug.at(s.time);
    if (jug.y < 0.5) g.shadow(jug.x - 0.5, jug.z - 0.4, 2.1, 1.8);
    final veg = s.veggies.at(s.time);
    if (!s.vegIn && veg.y < 0.5) g.shadow(veg.x - 0.3, veg.z, 1.6, 1.5);
    final sack = s.sack.at(s.time);
    if (sack.y < 1.5) g.shadow(sack.x - 0.6, sack.z - 0.5, 5, 4.6);
    _paintInOrder(g, [
      _Item.bigPot,
      if (!s.smallIn) _Item.smallPot,
      _Item.bag,
      _Item.jug,
      if (!s.vegIn) _Item.veggies,
      _Item.plate,
      _Item.sack,
    ]);
  }

  /// The pot-in-pot cooler: the large earthen pot cut away at the front
  /// (the HTML switched its clipping plane on once the sack covered the
  /// cooler; here it is open from the start so every layer can be seen),
  /// with the sand, the small pot, the vegetables and the pours inside.
  void _paintCooler(_Gfx g) {
    final sh = _bigShape;
    g.lathe(
      _bigAt,
      sh.profile,
      _Colors.earthen,
      cut: true,
      wall: sh.wall,
      floorR: sh.bottomR - sh.wall,
      floorY: _potFloor,
      rimR: sh.neckR,
      rimY: sh.top,
      rimTube: sh.tube,
      inside: () => _paintCoolerInside(g),
    );
  }

  void _paintCoolerInside(_Gfx g) {
    final s = scene;
    final t = s.time;
    final sand = _sandColor();
    final topSand = _lit(labShade(sand, 0.08), _V.up);
    final cutSand = _lit(labShade(sand, -0.1), _V.front);
    final base = s.sandBase.at(t);
    final baseTop = _potFloor + _baseThick * base;
    final gapTop = s.gap.at(t);
    final hasGap = gapTop > _gapFloor + 0.01;
    double smallR(double y) => _smallShape.radiusAt(y - _smallIn.y);
    // The sand's upper surfaces (back halves), then the small pot, then the
    // faces cut by the clipping plane.
    if (base > 0.001 && !hasGap) {
      g.disc(
        _bigAt.atY(baseTop),
        _bigShape.innerAt(baseTop),
        topSand,
        _Frame.upright,
        true,
      );
    }
    if (hasGap) {
      g.halfRing(
        _bigAt.atY(gapTop),
        smallR(gapTop),
        _bigShape.innerAt(gapTop),
        topSand,
      );
    }
    if (s.smallIn) {
      final ss = _smallShape;
      g.lathe(
        _smallIn,
        ss.profile,
        _Colors.earthen,
        cut: true,
        wall: ss.wall,
        floorR: ss.bottomR - ss.wall,
        floorY: _potFloor,
        rimR: ss.neckR,
        rimY: ss.top,
        rimTube: ss.tube,
      );
    }
    if (base > 0.001) {
      final pts = <_V>[];
      const n = 3;
      for (var i = 0; i <= n; i++) {
        final y = _potFloor + (baseTop - _potFloor) * i / n;
        pts.add(_bigAt + _V(-_bigShape.innerAt(y), y, 0));
      }
      for (var i = n; i >= 0; i--) {
        final y = _potFloor + (baseTop - _potFloor) * i / n;
        pts.add(_bigAt + _V(_bigShape.innerAt(y), y, 0));
      }
      g.poly(pts, cutSand);
    }
    if (hasGap) {
      const n = 8;
      for (final side in const [-1.0, 1.0]) {
        final pts = <_V>[];
        for (var i = 0; i <= n; i++) {
          final y = _gapFloor + (gapTop - _gapFloor) * i / n;
          pts.add(_bigAt + _V(side * _bigShape.innerAt(y), y, 0));
        }
        for (var i = n; i >= 0; i--) {
          final y = _gapFloor + (gapTop - _gapFloor) * i / n;
          pts.add(_bigAt + _V(side * smallR(y), y, 0));
        }
        g.poly(pts, cutSand);
      }
    }
    if (s.vegIn) _paintVeggies(g, s.veggies.at(t), 0, 0);
    _paintStream(g, _Item.bigPot);
  }

  /// `smallPotS2` outside the cooler: a whole earthen pot.
  void _paintSmallPot(_Gfx g, _V pos) {
    final ss = _smallShape;
    g.lathe(
      pos,
      ss.profile,
      _Colors.earthen,
      glow: _glowOf(_Item.smallPot),
      floorR: ss.bottomR - ss.wall,
      floorY: _potFloor,
      rimR: ss.neckR,
      rimY: ss.top,
      rimTube: ss.tube,
    );
  }

  /// `createBag()`: a 3 x 4 x 2 sack of sand tilting about its base.
  void _paintBag(_Gfx g, _V pos) {
    final s = scene;
    final tilt = s.pourTool == _Item.bag ? s.tilt.at(s.time) : 0.0;
    final fr = _Frame.rollZ(-tilt);
    final glow = _glowOf(_Item.bag);
    g.box(fr.at(pos, 0, 2, 0), fr, 1.5, 2, 1, _Colors.sack, glow: glow);
    // The tied neck of the sack.
    g.box(
      fr.at(pos, 0, 4.15, 0),
      fr,
      0.7,
      0.15,
      0.5,
      labShade(_Colors.sack, -0.2),
      glow: glow,
    );
  }

  /// The vegetables at [pos]; [wilt] 0 … 1 shrinks them to (0.7, 0.5, 0.7)
  /// and greys them (HTML fast-forward on `veggiesOut`).
  void _paintVeggies(_Gfx g, _V pos, double wilt, double glow) {
    final sx = 1 + (_wiltX - 1) * wilt;
    final sy = 1 + (_wiltY - 1) * wilt;
    Color tint(Color c) => _glowing(Color.lerp(c, _Colors.wilted, wilt)!, glow);
    for (final (offset, carrot, yaw) in _veggieLayout) {
      final c = pos + offset;
      if (carrot) {
        final axis = _V(math.sin(yaw), 0, math.cos(yaw));
        final fr = _Frame(_V(math.cos(yaw), 0, -math.sin(yaw)), axis, _V.up);
        final len = 2 * sy;
        final r = 0.4 * sx;
        g.lathe(
          c,
          [(0.0, 0.0), (r, len)],
          tint(_Colors.carrot),
          frame: fr,
          capR: r,
          capY: len,
          sides: 10,
        );
        g.lathe(
          c + axis * len,
          [(0.2 * sx, 0.0), (0.0, 0.5 * sy)],
          tint(_Colors.leaf),
          frame: fr,
          sides: 8,
        );
      } else {
        g.blob(c, 0.6 * sx, 0.6 * sy, tint(_Colors.tomato));
        g.blob(c + _V(0, 0.6 * sy, 0), 0.26 * sx, 0.1, tint(_Colors.leaf));
      }
    }
  }

  /// The plate (`CylinderGeometry(4, 4, 0.2)`) with the control
  /// vegetables, which wilt during the fast-forward.
  void _paintPlate(_Gfx g) {
    final s = scene;
    g.lathe(
      _plateAt,
      _plateProfile,
      _Colors.plate,
      capR: 4,
      capY: 0.2,
      sides: 28,
    );
    final wilt = s.scenario == 1 ? s.ffProgress : 0.0;
    _paintVeggies(g, _vegOut, wilt, 0);
  }

  /// `sackCover`: top disc, flared skirt and tie; at [k] of its size (2/3
  /// on the cooler).
  void _paintSack(_Gfx g, _V pos) {
    final s = scene;
    final k = s.sackK.at(s.time);
    g.lathe(
      pos,
      [(_sackSkirtR * k, -0.9), (_sackTopR * k, 0.1)],
      _Colors.sack,
      glow: _glowOf(_Item.sack),
      capR: _sackTopR * k,
      capY: 0.2,
      rimR: _sackTieR * k,
      rimY: -0.2,
      rimTube: 0.12,
      sides: 28,
    );
  }

  // ------------------------------------------------------------ overlays

  /// HTML evaporation particles: water drops and wisps of heat rising and
  /// fading for 2 s.
  void _paintPuffs(_Gfx g) {
    final s = scene;
    if (s.ffAt < 0) return;
    for (final p in s.puffs) {
      final u = (s.time - p.start) / _puffSeconds;
      if (u < 0 || u > 1) continue;
      final alpha = 0.8 * (1 - u);
      g.dot(
        p.at + _V(0, p.rise * u, 0),
        _puffR,
        _Colors.vapour.withValues(alpha: alpha),
      );
      g.heat(
        p.at + _V(0.3, p.heatDy + p.heatRise * u, 0),
        _heatLen,
        _Colors.heat.withValues(alpha: alpha),
      );
    }
  }

  /// HTML `createStdLabel` chips below the objects and the thermometer
  /// labels above the pots (S1), kept inside the free canvas and clear of
  /// each other.
  void _paintLabels(Canvas canvas) {
    final s = scene;
    final placed = <Rect>[];
    if (s.scenario == 0 && s.thermo) {
      final cool = s.ffAt >= 0;
      _thermo(canvas, _matkaThermoAt, s.matkaTemp, cool, placed);
      _thermo(canvas, _steelThermoAt, s.steelTemp, false, placed);
    }
    if (!showLabels) return;
    final labels = <(String, _V)>[];
    _V below(_Item item, double drop) => s.posOf(item) - _V(0, drop, 0);
    bool pouring(_Item item) => s.pourTool == item;
    if (s.scenario == 0) {
      labels
        ..add(('lbl_earthen_pot', below(_Item.matka, _labelDropPot)))
        ..add(('lbl_steel_pot', below(_Item.steel, _labelDropPot)));
      if (!pouring(_Item.jug)) {
        labels.add(('lbl_jug', below(_Item.jug, _labelDropTool)));
      }
    } else {
      labels.add(('lbl_large_pot', below(_Item.bigPot, _labelDropPot)));
      if (!s.smallIn) {
        labels.add(('lbl_small_pot', below(_Item.smallPot, _labelDropTool)));
      }
      if (!pouring(_Item.bag)) {
        labels.add(('lbl_bag', s.posOf(_Item.bag).atY(_labelRiseBag)));
      }
      if (!pouring(_Item.jug)) {
        labels.add(('lbl_jug', below(_Item.jug, _labelDropTool)));
      }
      if (!s.vegIn) {
        labels.add(('lbl_veggies', below(_Item.veggies, _labelDropVeg)));
      }
      labels.add(('lbl_plate', _vegOut - const _V(0, _labelDropVeg, 0)));
      if (!s.sackOn) {
        labels.add(('lbl_sack', below(_Item.sack, _labelDropSack)));
      }
    }
    for (final (key, at) in labels) {
      _chip(canvas, _cam.p(at), _t(key), placed);
    }
  }

  /// Places a [w] x [h] box centred near [at]: inside the free canvas and
  /// pushed down below any box already [placed].
  Rect _place(Offset at, double w, double h, List<Rect> placed) {
    final minX = framing.labelLeft + w / 2 + 2;
    final maxX = math.max(minX, framing.labelRight - w / 2 - 2);
    var rect = Rect.fromCenter(
      center: Offset(at.dx.clamp(minX, maxX), at.dy),
      width: w,
      height: h,
    );
    for (var guard = 0; guard < placed.length + 1; guard++) {
      final hit = placed.where((r) => r.overlaps(rect)).toList();
      if (hit.isEmpty) break;
      final down = hit.map((r) => r.bottom).reduce(math.max) + 2;
      rect = rect.translate(0, down - rect.top);
    }
    final maxBottom = framing.labelBottom - 2;
    if (rect.bottom > maxBottom) {
      rect = rect.translate(0, maxBottom - rect.bottom);
    }
    placed.add(rect);
    return rect;
  }

  /// HTML label chip: glass background, blue border, white bold text.
  void _chip(Canvas canvas, Offset at, String text, List<Rect> placed) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final rect = _place(at, tp.width + 2 * padX, tp.height + 2 * padY, placed);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.45));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.labelBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.labelBorder.withValues(alpha: 0.8),
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  /// HTML `.thermometer-label`: a chip with a thermometer icon (red, blue
  /// once the matka cools) and the temperature.
  void _thermo(
    Canvas canvas,
    _V at,
    int celsius,
    bool cool,
    List<Rect> placed,
  ) {
    final tp = cache.reading(labFormat(_t('unit_c'), {'v': celsius}));
    final size = cache.labelSize * 1.15;
    final icon = size * 0.7;
    final padX = size * 0.5, padY = size * 0.3;
    final h = tp.height + 2 * padY;
    // The chip's bottom edge sits [_thermoGap] above the rim point [at].
    final rect = _place(
      _cam.p(at) - Offset(0, h / 2 + _thermoGap),
      icon + padX * 3 + tp.width,
      h,
      placed,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.4));
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.chipDark : _Colors.chipLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 2
        ..color = isDark ? _Colors.chipDarkBorder : _Colors.chipLightBorder,
    );
    // Thermometer: a stem and a bulb.
    final ink = cool ? _Colors.blue500 : _Colors.red500;
    final cx = rect.left + padX + icon / 2;
    final top = rect.top + padY;
    final bottom = rect.bottom - padY;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          cx - icon * 0.16,
          top,
          cx + icon * 0.16,
          bottom - icon * 0.3,
        ),
        Radius.circular(icon * 0.16),
      ),
      _pens.fill..color = ink,
    );
    canvas.drawCircle(
      Offset(cx, bottom - icon * 0.3),
      icon * 0.3,
      _pens.fill..color = ink,
    );
    tp.paint(canvas, Offset(rect.left + padX * 2 + icon, rect.top + padY));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.framing != framing;
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
