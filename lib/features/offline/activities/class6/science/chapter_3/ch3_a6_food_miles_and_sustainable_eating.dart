// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 3 • Activity 6
/// Food Miles and Sustainable Eating.
///
/// Native Flutter port of
/// `Cl6S-Ch03-A6-Food_Miles_and_Sustainable_Eating.html` ("Food Miles: The
/// Journey of Our Food", Three.js r128). The two Three.js scenes are redrawn
/// by a CustomPainter through a perspective projection of the same camera
/// (45° field of view, the HTML positions and look-at points and its camera
/// tweens), fitted beside the floating cards.
///
/// Scenario 1 (The Story of a Chapati): drag the six journey tiles (Farmer,
/// Threshing, Storage, Grinding, Transport, Plate) into the timeline in
/// order. Each stop pops up on the map, the route to it is drawn (a truck
/// drives the storage, mill and supermarket legs) and the Food Miles and
/// Pollution meters climb to 380 km.
///
/// Scenario 2 (Local Roti vs. Imported Bread): tap the amber Local Wheat pin
/// in Punjab on the globe and confirm (a short truck ride: 50 km, fresh,
/// little pollution); then try the other option: spin the globe, tap the
/// red Imported Flour pin in North America and confirm (truck to the Gulf
/// of Mexico, cargo ship through the Atlantic, the Mediterranean, the Suez
/// Canal and the Arabian Sea, truck to the kitchen: 12,000 km, less fresh,
/// much more pollution).
class Ch3A6FoodMilesAndSustainableEatingPage extends StatefulWidget {
  const Ch3A6FoodMilesAndSustainableEatingPage({super.key});

  @override
  State<Ch3A6FoodMilesAndSustainableEatingPage> createState() =>
      _Ch3A6PageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises five Web Audio tones: 'pop'
/// (buttons, picking up a tile, curtain, scenario change), 'click' (a pin
/// chosen, the local transport), 'success' (a tile dropped into its slot,
/// the conclusion), 'error' (wrong tile or pin) and 'truck' (a 1 s engine
/// hum on the truck legs and the import shipment). They map to pop.mp3,
/// click.mp3, correct.mp3 / success.mp3, error.mp3 and drop.mp3 (the
/// closest length to the 1 s hum).
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// click → `science/click.mp3`, correct → `science/correct.mp3`,
/// success → `math/success.mp3`, wrong → `science/error.mp3`,
/// truck → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('click')`.
  click('audio/class6/science/click.mp3'),

  /// HTML `playSound('success')` for a tile dropped into its slot; also the
  /// shell's "Scenario Complete" toast.
  correct('audio/class6/science/correct.mp3'),

  /// HTML `playSound('success')` for the conclusion.
  success('audio/class6/math/success.mp3'),

  /// HTML `playSound('error')`.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `playSound('truck')`.
  truck('audio/class6/science/drop.mp3');

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

/// Tailwind colours of the HTML page and the Three.js material colours.
abstract final class _Colors {
  // ------------------------------------------------------------ page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
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
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color orange500 = Color(0xFFF97316);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);

  /// `--glass-bg` and `--glass-border` (dark / light).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Summary cards: `bg-emerald-900/30` and `bg-red-900/30`.
  static const Color emeraldTint = Color(0x4D064E3B);
  static const Color redTint = Color(0x4D7F1D1D);

  /// `.scene-label`: `rgba(15, 23, 42, 0.8)` with a white/20 border.
  static const Color labelBg = Color(0xCC0F172A);
  static const Color labelBorder = Color(0x33FFFFFF);

  // ----------------------------------------------------------- tiles
  /// `createTileSVG(emoji, '#efe5d5')`: beige face, `#c0a080` border.
  static const Color tileFace = Color(0xFFEFE5D5);
  static const Color tileEdge = Color(0xFFC0A080);
  static const Color tileInk = Color(0xFF6B4423);

  // ------------------------------------------------------ S1 map scene
  /// `createIndiaMapTexture()` land gradient and outline.
  static const Color lime300 = Color(0xFFBEF264);
  static const Color lime400 = Color(0xFFA3E635);
  static const Color lime500 = Color(0xFF84CC16);
  static const Color river = sky400;
  static const Color dirtRoad = Color(0xFFD6C29A);
  static const Color field = Color(0xFFFACC15);
  static const Color cityGround = Color(0xFFCBD5E1);
  static const Color stone = Color(0xFF78716C);
  static const Color tree = Color(0xFF15803D);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  /// Farm, farmer, door, table, head (0x8b4513) and the wheat (0xfacc15).
  static const Color brown = Color(0xFF8B4513);
  static const Color tan = Color(0xFFD2B48C);
  static const Color sack = Color(0xFF9A6324);
  static const Color flourSack = Color(0xFFDDB17B);
  static const Color houseWall = Color(0xFFFEF08A);

  /// Path tubes (0xf59e0b, opacity 0.8).
  static const Color path = Color(0xCCF59E0B);

  // ------------------------------------------------------ S2 globe scene
  /// `createWorldMapTexture()`: ocean blue-400, land green-400, coast
  /// green-500 (the HTML's photo texture was loaded from the web).
  static const Color ocean = blue400;
  static const Color land = green400;
  static const Color coast = green500;
  static const Color atmosphere = Color(0x5993C5FD);
  static const Color routeLocal = Color(0xCC22C55E);
  static const Color routeImport = Color(0xCCF59E0B);

  /// canvas-confetti colours from the HTML.
  static const List<Color> confetti = [emerald500, blue500, amber500];
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900, // scene.background 0x0f172a
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.teal600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900, // #summary-modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66065F46), // from-emerald-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // text-emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0x9910B981),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sky100, // scene.background 0xe0f2fe
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.teal600,
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
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0x9910B981),
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
/// are the HTML sidebar font slider: 15 px, 12–22 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. Every
/// HTML button, the curtain, the sidebar toggle and the scenario selector
/// play 'pop'.
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
// From the HTML `i18n`, `ScenariosData`, `labels` and `timelineData` tables
// (Telugu dropped). Changes:
// * S2 actions and HUD lines say "tap" and name the buttons as they are
//   labelled in each language (the HTML Hindi quoted the English 'Confirm
//   Choice' / 'Try the other option'), and step 3 says how to spin the
//   globe (drag it sideways);
// * the S2 pins are labelled 'Local Wheat (Punjab)' / 'Imported Flour
//   (North America)', the names the instructions use (HTML 'Punjab
//   (Local)' / 'North America (Imported)');
// * Hindi uses 'फ़ूड माइल्स' throughout (the HTML mixed in 'खाद्य मील');
// * strings marked "added" were not in the HTML (the wrong-tile / wrong-slot
//   hints, the pending result line) or were hard-coded English there (the
//   summary cards: 'High' / 'Low', the button labels, the units).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Food Miles: The Journey of Our Food',
    'app_subtitle': 'Class 6 • Mindful Eating: A Path to a Healthy Body',
    'scen_1_title': 'Scenario 1: The Story of a Chapati',
    'scen_2_title': 'Scenario 2: Local Roti vs. Imported Bread',
    'scen_1_obj':
        'Assemble the journey of a chapati from the farm to the plate and observe how each step contributes to the total food miles.',
    'scen_2_obj':
        'Compare the food miles and environmental impact of making a meal using a locally grown crop versus an imported one.',
    // Scenario 1 steps.
    's1_c1': 'Source',
    's1_a1':
        "Identify the 'Farmer' tile from the options. Drag and drop this tile into the very first slot on the timeline to mark the origin of our food.",
    's1_o1':
        "A 3D farmer appears on the map. The Food Miles meter reads 0 km, as the wheat is still at its source and hasn't traveled anywhere yet.",
    's1_e1': 'The journey begins at the farm where crops are grown.',
    's1_c2': 'Processing (On-farm)',
    's1_a2':
        "Select the 'Threshing' tile. Drag and drop it into the second slot to show the separation of wheat grains from the stalks.",
    's1_o2':
        'A 3D threshing machine appears. The Food Miles meter slightly increases to 5 km, and the Pollution meter rises marginally, reflecting the short trip around the farm.',
    's1_e2':
        'Initial processing often happens close to or on the farm, adding minimal miles.',
    's1_c3': 'Storage',
    's1_a3':
        "Grab the 'Storage' tile. Drag and drop it into the third slot to simulate the transportation of grains to a local storage facility.",
    's1_o3':
        "A 3D silo appears, and a small truck drives towards it. Food Miles jump to 25 km, and pollution increases due to the truck's exhaust emissions.",
    's1_e3':
        'Transporting to local storage adds some distance and pollution from trucks.',
    's1_c4': 'Processing (Industrial)',
    's1_a4':
        "Pick up the 'Grinding' tile. Drag it to the fourth slot to represent the grains being processed into flour at a distant industrial mill.",
    's1_o4':
        'A 3D flour mill is built on the map. A truck travels further, pushing Food Miles to 75 km. Industrial processing and transport add more pollution.',
    's1_e4':
        'Moving to factories for further processing increases the distance traveled.',
    's1_c5': 'Distribution',
    's1_a5':
        "Drag the 'Transport' tile into the fifth slot to simulate the long-haul distribution of packaged flour to city supermarkets.",
    's1_o5':
        'A large truck travels a long highway route to the city shop. Food Miles drastically spike to 375 km, and the Pollution meter jumps significantly into the red zone.',
    's1_e5':
        'Long-haul transport to supermarkets adds significantly to the food miles and pollution.',
    's1_c6': 'Consumption',
    's1_a6':
        "Finally, drag the 'Plate' tile into the sixth slot to show the consumer buying the flour and cooking a chapati at home.",
    's1_o6':
        'A 3D house appears, completing the map. Total Food Miles reach 380 km. The final pollution level is extremely high due to the accumulated travel and processing.',
    's1_e6':
        'The final short trip home completes the journey. Total distance = Food Miles.',
    // Scenario 2 steps.
    's2_c1': 'Choosing Local Sourcing',
    's2_a1':
        "Find the amber 'Local Wheat' pin in Punjab, India, on the 3D globe and tap it to select it as your ingredient source.",
    's2_o1':
        "A visual marker highlights your selection in Punjab, setting the starting point for your food's journey very close to your kitchen.",
    's2_e1':
        'Sourcing food from nearby farms keeps the initial travel distance very short.',
    's2_c2': 'Impact of Local Food',
    's2_a2':
        "Tap the 'Confirm Choice' button to start the transport, then observe the resulting environmental meters.",
    's2_o2':
        "The transport animation completes quickly. The 'Food Miles' meter shows only 50 km. Because the transit time is short, the 'Freshness' meter remains high (green), and the 'Pollution' meter stays very low due to minimal fuel consumption.",
    's2_e2':
        'Low food miles result in fresher food and significantly lower carbon emissions from transport.',
    's2_c3': 'Choosing Imported Sourcing',
    's2_a3':
        "Tap 'Try the other option' to reset. Then spin the globe (drag it sideways) and tap the red 'Imported Flour' pin located in North America to see the alternative.",
    's2_o3':
        'The selection marker now highlights a distant location across the globe, indicating that the food will need to travel across oceans to reach you.',
    's2_e3':
        'Imported foods travel thousands of kilometers using ships, planes, and trucks.',
    's2_c4': 'Impact of Imported Food',
    's2_a4':
        "Tap the 'Confirm Choice' button to simulate the long-distance shipping process, then observe the updated meters.",
    's2_o4':
        "A cargo ship and truck trace a massive path across the world. The 'Food Miles' skyrocket to 12,000 km. Consequently, 'Freshness' drops significantly due to long transit times, and the 'Pollution' meter fills up rapidly (red) reflecting the massive carbon emissions from long-haul transport.",
    's2_e4':
        'The massive distance requires heavy fuel use, contributing heavily to global pollution, and transit time affects freshness.',
    // HUD (HTML `hud`).
    's1_hud_1': "Drag the 'Farmer' tile into the 1st slot to begin.",
    's1_hud_2': "Drag the 'Threshing' tile into the 2nd slot to process.",
    's1_hud_3': "Drag the 'Storage' tile into the 3rd slot to store grains.",
    's1_hud_4': "Drag the 'Grinding' tile into the 4th slot to make flour.",
    's1_hud_5': "Drag the 'Transport' tile into the 5th slot for delivery.",
    's1_hud_6':
        "Drag the 'Plate' tile into the 6th slot to complete the journey.",
    's2_hud_1':
        "Find and tap the amber pin in Punjab (India) to source 'Local Wheat'.",
    's2_hud_2': "Great! Now tap 'Confirm Choice' to transport the local wheat.",
    's2_hud_3':
        "Tap 'Try the other option', then spin the globe to find the red pin in North America and select 'Imported Flour'.",
    's2_hud_4':
        "Tap 'Confirm Choice' to transport the imported flour across the globe.",
    // Timeline tiles and map labels.
    'tile_1': 'Farmer',
    'tile_2': 'Threshing',
    'tile_3': 'Storage',
    'tile_4': 'Grinding',
    'tile_5': 'Transport',
    'tile_6': 'Plate',
    'stop_1': 'Farm',
    'stop_2': 'Threshing',
    'stop_3': 'Silo',
    'stop_4': 'Flour Mill',
    'stop_5': 'Supermarket',
    'stop_6': 'Home',
    'pin_local': 'Local Wheat (Punjab)',
    'pin_imported': 'Imported Flour (North America)',
    // Meters.
    'lbl_food_miles': 'Food Miles',
    'lbl_pollution': 'Pollution',
    'lbl_freshness': 'Freshness',
    'unit_km': 'km', // added (HTML: hard-coded)
    // Buttons (HTML: hard-coded English).
    'btn_confirm': 'Confirm Choice',
    'btn_try_other': 'Try the other option',
    // Toasts.
    'err_tile': "Not this tile. Drag the '{name}' tile into slot {n}.", // added
    'err_slot': 'Fill the timeline in order: slot {n} is next.', // added
    'err_local_first':
        "Please select the 'Local Wheat' (India) first to compare!",
    'err_import_now': "Please select the 'Imported Flour' (North America) now!",
    // Sidebar accordion.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Focus',
    'action': 'Action',
    'observation': 'Result',
    'obs_pending': 'The result appears once you complete this step.', // added
    // Conclusion popups.
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    's1_summary':
        "This is the journey of your food. The total distance it travels is called 'Food Miles'. Longer journeys mean more fuel is used, creating more pollution.",
    's2_summary':
        'Choosing local food drastically reduces food miles. This means your food is fresher, and it creates much less pollution, which is better for our planet. This is sustainable eating.',
    'sum_total_miles': 'Total Food Miles',
    'sum_pollution_level': 'Pollution Level',
    'sum_local': 'Local Chapati',
    'sum_import': 'Imported Bread',
    'sum_miles': 'Miles',
    'sum_fresh': 'Freshness',
    'sum_pol': 'Pollution',
    'lvl_high': 'High',
    'lvl_low': 'Low',
    'vs': 'VS',
  },
  'hi': {
    'app_title': 'फ़ूड माइल्स: हमारे भोजन की यात्रा',
    'app_subtitle': 'कक्षा 6 • सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_title': 'परिदृश्य 1: एक चपाती की कहानी',
    'scen_2_title': 'परिदृश्य 2: स्थानीय रोटी बनाम आयातित ब्रेड',
    'scen_1_obj':
        "खेत से प्लेट तक चपाती की यात्रा को क्रम से जोड़ें और देखें कि प्रत्येक चरण कुल 'फ़ूड माइल्स' (भोजन द्वारा तय की गई दूरी) में कैसे योगदान देता है।",
    'scen_2_obj':
        "स्थानीय रूप से उगाई गई फसल बनाम आयातित फसल से भोजन बनाने के 'फ़ूड माइल्स' और पर्यावरणीय प्रभाव की तुलना करें।",
    's1_c1': 'स्रोत',
    's1_a1':
        "उपलब्ध विकल्पों में से 'किसान' टाइल को पहचानें। हमारे भोजन की उत्पत्ति को चिह्नित करने के लिए इस टाइल को टाइमलाइन के पहले स्लॉट में खींचें और छोड़ें।",
    's1_o1':
        'नक्शे पर एक 3D किसान दिखाई देता है। फ़ूड माइल्स मीटर 0 किमी पढ़ता है, क्योंकि गेहूं अभी भी अपने स्रोत पर है और उसने कहीं भी यात्रा नहीं की है।',
    's1_e1': 'यात्रा खेत से शुरू होती है जहां फसलें उगाई जाती हैं।',
    's1_c2': 'प्रसंस्करण (खेत पर)',
    's1_a2':
        "'थ्रेशिंग' टाइल का चयन करें। डंठल से गेहूं के दानों को अलग करने को दिखाने के लिए इसे दूसरे स्लॉट में खींचें और छोड़ें।",
    's1_o2':
        'एक 3D थ्रेशिंग मशीन दिखाई देती है। खेत के आसपास की छोटी यात्रा को दर्शाते हुए फ़ूड माइल्स 5 किमी तक बढ़ जाता है, और प्रदूषण मीटर थोड़ा बढ़ जाता है।',
    's1_e2':
        'प्रारंभिक प्रसंस्करण अक्सर खेत के करीब या खेत पर ही होता है, जिससे बहुत कम दूरी जुड़ती है।',
    's1_c3': 'भंडारण',
    's1_a3':
        "'भंडारण' टाइल को पकड़ें। अनाज को स्थानीय भंडारण सुविधा तक ले जाने का अनुकरण करने के लिए इसे तीसरे स्लॉट में खींचें और छोड़ें।",
    's1_o3':
        'एक 3D साइलो दिखाई देता है, और एक छोटा ट्रक उसकी ओर जाता है। फ़ूड माइल्स 25 किमी तक पहुँच जाता है, और ट्रक के धुएँ के कारण प्रदूषण बढ़ जाता है।',
    's1_e3':
        'स्थानीय भंडारण तक परिवहन से कुछ दूरी और ट्रकों से प्रदूषण जुड़ता है।',
    's1_c4': 'प्रसंस्करण (औद्योगिक)',
    's1_a4':
        "'पिसाई' टाइल उठाएं। एक दूर की औद्योगिक मिल में अनाज से आटा बनने को दर्शाने के लिए इसे चौथे स्लॉट में खींचें।",
    's1_o4':
        'नक्शे पर 3D आटा मिल बनती है। एक ट्रक आगे की यात्रा करता है, जिससे फ़ूड माइल्स 75 किमी हो जाता है। औद्योगिक प्रसंस्करण और परिवहन अधिक प्रदूषण जोड़ते हैं।',
    's1_e4':
        'आगे की प्रक्रिया के लिए कारखानों में जाने से तय की गई दूरी बढ़ जाती है।',
    's1_c5': 'वितरण',
    's1_a5':
        "पैक किए गए आटे के शहर के सुपरमार्केट तक लंबी दूरी के वितरण का अनुकरण करने के लिए 'परिवहन' टाइल को पांचवें स्लॉट में खींचें।",
    's1_o5':
        'एक बड़ा ट्रक शहर की दुकान के लिए लंबा राजमार्ग मार्ग तय करता है। फ़ूड माइल्स 375 किमी तक बढ़ जाता है, और प्रदूषण मीटर लाल क्षेत्र में काफी उछल जाता है।',
    's1_e5':
        'सुपरमार्केट तक लंबी दूरी के परिवहन से फ़ूड माइल्स और प्रदूषण में काफी वृद्धि होती है।',
    's1_c6': 'खपत',
    's1_a6':
        "अंत में, उपभोक्ता को आटा खरीदते हुए और घर पर चपाती पकाते हुए दिखाने के लिए 'प्लेट' टाइल को छठे स्लॉट में खींचें।",
    's1_o6':
        'एक 3D घर दिखाई देता है, जिससे नक्शा पूरा होता है। कुल फ़ूड माइल्स 380 किमी तक पहुँच जाता है। पूरी यात्रा और प्रसंस्करण के कारण अंतिम प्रदूषण स्तर बहुत अधिक है।',
    's1_e6':
        'घर तक की अंतिम छोटी यात्रा से सफर पूरा होता है। कुल दूरी = फ़ूड माइल्स।',
    's2_c1': 'स्थानीय स्रोत चुनना',
    's2_a1':
        "3D ग्लोब पर पंजाब (भारत) में स्थित एम्बर रंग का 'स्थानीय गेहूं' पिन ढूंढें और उसे अपनी सामग्री के स्रोत के रूप में चुनने के लिए उस पर टैप करें।",
    's2_o1':
        'एक दृश्य मार्कर पंजाब में आपके चयन को उजागर करता है, जो आपके रसोई घर के बहुत करीब भोजन की यात्रा का प्रारंभिक बिंदु निर्धारित करता है।',
    's2_e1':
        'आस-पास के खेतों से भोजन प्राप्त करने से प्रारंभिक यात्रा की दूरी बहुत कम रहती है।',
    's2_c2': 'स्थानीय भोजन का प्रभाव',
    's2_a2':
        "परिवहन शुरू करने के लिए 'चुनाव की पुष्टि करें' बटन पर टैप करें, फिर पर्यावरण पर पड़ने वाले प्रभाव के मीटर देखें।",
    's2_o2':
        "परिवहन एनीमेशन जल्दी पूरा हो जाता है। 'फ़ूड माइल्स' मीटर केवल 50 किमी दिखाता है। यात्रा का समय कम होने के कारण, 'ताज़गी' मीटर उच्च (हरा) रहता है, और न्यूनतम ईंधन खपत के कारण 'प्रदूषण' मीटर बहुत कम रहता है।",
    's2_e2':
        'कम फ़ूड माइल्स के परिणामस्वरूप ताजा भोजन मिलता है और परिवहन से कार्बन उत्सर्जन काफी कम होता है।',
    's2_c3': 'आयातित स्रोत चुनना',
    's2_a3':
        "रीसेट करने के लिए 'दूसरा विकल्प आज़माएँ' पर टैप करें। फिर ग्लोब को घुमाएँ (उसे बगल की ओर खींचें) और उत्तरी अमेरिका में स्थित लाल 'आयातित आटा' पिन पर टैप करें।",
    's2_o3':
        'चयन मार्कर अब दुनिया के दूसरी ओर एक दूर के स्थान को उजागर करता है, यह दर्शाता है कि भोजन को आप तक पहुंचने के लिए महासागरों को पार करना होगा।',
    's2_e3':
        'आयातित खाद्य पदार्थ जहाजों, विमानों और ट्रकों का उपयोग करके हजारों किलोमीटर की यात्रा करते हैं।',
    's2_c4': 'आयातित भोजन का प्रभाव',
    's2_a4':
        "लंबी दूरी की शिपिंग प्रक्रिया का अनुकरण करने के लिए 'चुनाव की पुष्टि करें' बटन पर टैप करें, फिर बदले हुए मीटर देखें।",
    's2_o4':
        "एक मालवाहक जहाज और ट्रक दुनिया भर में एक लंबा रास्ता तय करते हैं। 'फ़ूड माइल्स' 12,000 किमी तक पहुँच जाता है। नतीजतन, लंबे पारगमन समय के कारण 'ताज़गी' काफी कम हो जाती है, और लंबी दूरी के परिवहन से भारी कार्बन उत्सर्जन को दर्शाते हुए 'प्रदूषण' मीटर तेजी से (लाल) भर जाता है।",
    's2_e4':
        'बड़ी दूरी के लिए भारी ईंधन के उपयोग की आवश्यकता होती है, जो वैश्विक प्रदूषण में भारी योगदान देता है, और पारगमन समय ताज़गी को प्रभावित करता है।',
    's1_hud_1':
        "यात्रा शुरू करने के लिए 'किसान' टाइल को पहले स्लॉट में खींचें।",
    's1_hud_2':
        "संसाधित करने के लिए 'थ्रेशिंग' टाइल को दूसरे स्लॉट में खींचें।",
    's1_hud_3':
        "अनाज को स्टोर करने के लिए 'भंडारण' टाइल को तीसरे स्लॉट में खींचें।",
    's1_hud_4': "आटा बनाने के लिए 'पिसाई' टाइल को चौथे स्लॉट में खींचें।",
    's1_hud_5': "वितरण के लिए 'परिवहन' टाइल को पांचवें स्लॉट में खींचें।",
    's1_hud_6':
        "यात्रा को पूरा करने के लिए 'प्लेट' टाइल को छठे स्लॉट में खींचें।",
    's2_hud_1':
        "'स्थानीय गेहूं' प्राप्त करने के लिए पंजाब (भारत) में एम्बर पिन खोजें और उस पर टैप करें।",
    's2_hud_2':
        "बहुत बढ़िया! अब स्थानीय गेहूं के परिवहन के लिए 'चुनाव की पुष्टि करें' पर टैप करें।",
    's2_hud_3':
        "'दूसरा विकल्प आज़माएँ' पर टैप करें, फिर ग्लोब घुमाकर उत्तरी अमेरिका में लाल पिन खोजें और 'आयातित आटा' चुनें।",
    's2_hud_4':
        "आयातित आटे को दुनिया भर में ले जाने के लिए 'चुनाव की पुष्टि करें' पर टैप करें।",
    'tile_1': 'किसान',
    'tile_2': 'थ्रेशिंग',
    'tile_3': 'भंडारण',
    'tile_4': 'पिसाई',
    'tile_5': 'परिवहन',
    'tile_6': 'प्लेट',
    'stop_1': 'खेत',
    'stop_2': 'थ्रेशिंग',
    'stop_3': 'भंडार',
    'stop_4': 'आटा मिल',
    'stop_5': 'सुपरमार्केट',
    'stop_6': 'घर',
    'pin_local': 'स्थानीय गेहूं (पंजाब)',
    'pin_imported': 'आयातित आटा (उत्तरी अमेरिका)',
    'lbl_food_miles': 'फ़ूड माइल्स',
    'lbl_pollution': 'प्रदूषण',
    'lbl_freshness': 'ताज़गी',
    'unit_km': 'किमी',
    'btn_confirm': 'चुनाव की पुष्टि करें',
    'btn_try_other': 'दूसरा विकल्प आज़माएँ',
    'err_tile': "यह टाइल नहीं। '{name}' टाइल को स्लॉट {n} में खींचें।",
    'err_slot': 'टाइमलाइन को क्रम से भरें: अगला स्लॉट {n} है।',
    'err_local_first':
        "कृपया तुलना करने के लिए पहले 'स्थानीय गेहूं' (भारत) चुनें!",
    'err_import_now': "कृपया अब 'आयातित आटा' (उत्तरी अमेरिका) चुनें!",
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'ध्यान दें',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'यह चरण पूरा करने पर परिणाम दिखेगा।',
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    's1_summary':
        "यह आपके भोजन की यात्रा है। इसके द्वारा तय की गई कुल दूरी को 'फ़ूड माइल्स' कहा जाता है। लंबी यात्रा का मतलब है अधिक ईंधन का उपयोग, जिससे अधिक प्रदूषण होता है।",
    's2_summary':
        'स्थानीय भोजन चुनने से फ़ूड माइल्स काफी कम हो जाते हैं। इसका मतलब है कि आपका भोजन ताज़ा है, और यह बहुत कम प्रदूषण पैदा करता है, जो हमारे ग्रह के लिए बेहतर है। यही टिकाऊ भोजन है।',
    'sum_total_miles': 'कुल फ़ूड माइल्स',
    'sum_pollution_level': 'प्रदूषण स्तर',
    'sum_local': 'स्थानीय चपाती',
    'sum_import': 'आयातित ब्रेड',
    'sum_miles': 'फ़ूड माइल्स',
    'sum_fresh': 'ताज़गी',
    'sum_pol': 'प्रदूषण',
    'lvl_high': 'अधिक',
    'lvl_low': 'कम',
    'vs': 'बनाम',
  },
};

/// Steps per scenario (HTML `ScenariosData[...].steps`).
const List<int> _stepCounts = [6, 4];
const int _scenarioCount = 2;

/// Scenarios and steps for [lang] (HTML `ScenariosData`: concept, action,
/// observation per step; the explanation is read by the accordion).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_title'),
        objective: t('scen_${n}_obj'),
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

final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// The part of the design box the scene's touch targets are kept in (the
/// stage only hit-tests inside its design box).
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// Design px per world unit at depth 1: 280 / tan(22.5°), the HTML
/// PerspectiveCamera(45°) over the 560 px stage height.
const double _focal = 675.96;
const double _near = 0.1;
const _V _up = _V(0, 1, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(0xffffff,
/// 0.8)` at (10, 20, 10), toned down by [_exposure] so lit faces keep their
/// colour.
const double _ambient = 0.6;
const double _sunLight = 0.8;
const double _exposure = 0.8;

/// (10, 20, 10) normalised.
const _V _lightDir = _V(0.4082, 0.8165, 0.4082);

/// The scene is never drawn larger than the HTML camera shows it.
const double _maxZoom = 1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; × UI scale) and the compact
/// floating mission card (screens shorter than [_compactBelow], at most
/// [_compactCardMax] of the height, 12 px from the top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Scene focus (base projection, design px): what the framing keeps in
/// view. S1: the stop the camera looks at, its label and its neighbours.
/// S2: the globe with its pins and labels.
final Rect _focusS1 = Rect.fromCenter(
  center: const Offset(500, 290),
  width: 640,
  height: 440,
);
final Rect _focusS2 = Rect.fromCenter(
  center: _designCenter,
  width: 560,
  height: 500,
);

/// Scene labels (HTML `.scene-label`, 12 px bold): 12 design px at the HTML
/// camera, never below [_labelMinDp] on screen.
const double _labelPx = 12;
const double _labelMinDp = 9.5;

/// Smallest on-screen radius (logical px) of a pin's touch area (48 dp).
const double _touchDp = 24;

// ------------------------------------------------------- scenario 1 data

/// HTML `resetCamera()` for S1: `camera.position.set(0, 18, 22)`,
/// `controls.target.set(0, 0, 0)`.
const _V _s1Eye = _V(0, 18, 22);

/// HTML `animateS1Step`: the camera flies to (x, 10, z + 10) looking at the
/// stop, 1 s Quadratic.InOut; the model pops up 0.8 s Elastic.Out; the
/// route is drawn in 1.5 s.
const double _flyHeight = 10;
const double _flyBack = 10;
const double _flySeconds = 1;
const double _popSeconds = 0.8;
const double _pathSeconds = 1.5;

/// The route arcs: `mid.y += 2` on a QuadraticBezierCurve3 (apex 1 above
/// the map).
const double _pathLift = 2;

/// The six stops on the 24 × 24 map board. The HTML spread them over an
/// outline of all of India (Punjab to Kerala, about 2,500 km by road) while
/// its meters add up to 380 km, so the board is a regional map here
/// (fields, river, highway, city) with the same six stops.
const List<_V> _stops = [
  _V(-8, 0, -6.5), // Farm
  _V(-2.5, 0, -8.5), // Threshing
  _V(-4, 0, -2), // Silo
  _V(3, 0, -3.5), // Flour mill
  _V(2, 0, 6), // Supermarket
  _V(8, 0, 8), // Home
];

/// The long-haul leg (mill → supermarket) bends east along the highway.
const List<_V> _legBend = [
  _V.zero,
  _V.zero,
  _V.zero,
  _V.zero,
  _V(4, 0, 0),
  _V.zero,
];

/// Each model's footprint (radius, height): the route is hidden inside it.
const List<(double, double)> _modelSize = [
  (2.2, 2.4),
  (2.0, 2.3),
  (1.5, 4.3),
  (1.6, 4.2),
  (1.8, 2.2),
  (1.7, 3.1),
];

/// HTML step data: Food Miles (km) and Pollution (%) after each stop.
const List<int> _s1Miles = [0, 5, 25, 75, 375, 380];
const List<int> _s1Pollution = [0, 5, 15, 30, 70, 75];

/// HTML `updateS1Meters`: bar width `miles / 380`.
const int _s1MilesMax = 380;

/// HTML `animateS1Step`: the truck sound (and here a truck) on steps 3–5.
const Set<int> _truckLegs = {2, 3, 4};

/// HTML: the timeline fades out (0.5 s), the summary opens 1.5 s after the
/// last tile.
const Duration _timelineFade = Duration(milliseconds: 500);
const Duration _s1ConclusionDelay = Duration(milliseconds: 1500);

// ------------------------------------------------------- scenario 2 data

/// HTML `const R = 8`.
const double _globeR = 8;

/// HTML `resetCamera()` for S2: `camera.position.set(0, 8, 28)`.
const _V _s2Eye = _V(0, 8, 28);

/// HTML `s2Earth.rotation.y += 0.001` per frame while choosing (60 fps).
const double _spinPerSecond = 0.06;

/// Start turn of the globe: India faces the camera, North America is on
/// the far side (the HTML: 'spin the globe').
const double _startYaw = -math.pi / 2;

/// A finger drag across one globe radius turns it this many radians.
const double _dragTurn = 1;

/// HTML pin: cone 1.2 long with a 0.6 head at 1.2 above the ground.
const double _pinHeight = 1.2;
const double _pinHeadR = 0.6;

/// HTML: the camera moves to `pin × 1.8` looking at `pin × 0.8` in 0.8 s
/// (Quadratic.Out); during a shipment it follows the vehicle from 10 units
/// above the globe.
const double _focusOut = 1.8;
const double _focusIn = 0.8;
const double _focusSeconds = 0.8;
const double _followHeight = 10;

/// HTML `animateS2Choice`: 1 s (local) / 4 s (imported), Quadratic.InOut.
const double _localSeconds = 1;
const double _importSeconds = 4;

/// The routes run just above the globe's surface (the HTML drew one bezier
/// arc through space, R + 0.5 / R + 2 at its middle, so the "cargo ship"
/// flew over the continents).
const double _routeLift = 0.08;

/// Points each route is resampled to, evenly spaced along it (the HTML
/// `curve.getPoints(100)`; the long imported route gets more).
const int _localSegments = 100;
const int _importSegments = 200;

/// Great-circle pieces are at most this long before resampling (radians).
const double _routeStep = 2 * math.pi / 180;

/// HTML: the conclusion 2 s after the imported shipment arrives; the Food
/// Miles counter runs for 2 s (Quadratic.Out).
const Duration _s2ConclusionDelay = Duration(milliseconds: 2000);
const Duration _counterTime = Duration(milliseconds: 2000);

/// Places (latitude, longitude in degrees). The HTML put the pins at rough
/// spherical angles (the "local" one on the Gujarat coast); here the wheat
/// farm is in Punjab, the kitchen nearby and the imported flour comes from
/// the North American wheat belt.
const (double, double) _punjab = (31.0, 75.5);
const (double, double) _kitchen = (29.8, 77.3);
const (double, double) _wheatBelt = (38.5, -98.5);
const (double, double) _gulfPort = (29.4, -94.9); // Houston / Galveston
const (double, double) _kandla = (22.8, 69.9); // Kandla port, Gujarat

/// The imported flour's journey, leg by leg: by truck to the Gulf of
/// Mexico, by cargo ship across the Atlantic, the Mediterranean, the Suez
/// Canal, the Red Sea and the Arabian Sea to Kandla, by truck to the
/// kitchen. The HTML observation: "A cargo ship and truck trace a massive
/// path across the world."
const List<(double, double)> _importByTruck = [_wheatBelt, _gulfPort];
const List<(double, double)> _importByShip = [
  _gulfPort,
  (27.0, -91.0), // Gulf of Mexico
  (24.6, -84.0),
  (24.2, -81.0), // Straits of Florida
  (26.0, -78.5),
  (31.0, -62.0), // Atlantic Ocean
  (35.0, -30.0),
  (36.0, -12.0),
  (35.95, -5.6), // Strait of Gibraltar
  (37.2, 1.0), // Mediterranean Sea
  (37.7, 11.3),
  (34.5, 20.0),
  (32.6, 28.0),
  (31.3, 32.3), // Port Said, Suez Canal
  (29.9, 32.6),
  (27.0, 34.8), // Red Sea
  (20.0, 38.3),
  (12.6, 43.3), // Bab-el-Mandeb
  (13.0, 48.0), // Gulf of Aden
  (14.0, 54.0),
  (18.5, 62.0), // Arabian Sea
  _kandla,
];
const List<(double, double)> _importByRoad = [
  _kandla,
  (26.9, 75.8), // Jaipur
  _kitchen,
];

/// HTML `animateS2Choice(type, miles, freshness, pollution)`.
const Map<_Pin, (int, int, int)> _s2Results = {
  _Pin.local: (50, 90, 10),
  _Pin.imported: (12000, 20, 85),
};

// ------------------------------------------------------------- canvas cards

/// Meters card (HTML `#meters-panel`, `w-48` on phones), × UI scale.
const double _metersWidth = 170;

/// Smallest meter label (logical px).
const double _meterLabelMin = 9.5;

/// Canvas action card (the HTML `#btn-s2-action` at the bottom centre).
const double _actionCardWidth = 230;
const double _actionCardHeight = 64;

/// Timeline card: tiles are at least 48 dp (a finger) and at most
/// [_tileMax] × UI scale.
const double _tileMin = 48;
const double _tileMax = 60;
const double _journeyPad = 6;
const double _journeyGap = 8;

/// Arrow between two timeline slots (HTML `ph-arrow-right`, text-sm).
const double _arrowMin = 12;

// ------------------------------------------------------------- models

enum _Pin { local, imported }

/// HTML `State.s2.mode` ('select' / 'confirmed') plus the shipment running.
enum _S2Mode { select, moving, confirmed }

// tween.js easing functions (exact, not Flutter's bezier approximations).
typedef _Ease = double Function(double t);

double _linear(double t) => t;

double _quadOut(double t) => t * (2 - t);

double _quadInOut(double t) {
  final k = t * 2;
  if (k < 1) return 0.5 * k * k;
  final m = k - 1;
  return -0.5 * (m * (m - 2) - 1);
}

double _elasticOut(double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return math.pow(2, -10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1;
}

/// TWEEN Quadratic.Out as a Flutter curve (the Food Miles counter).
class _QuadOutCurve extends Curve {
  const _QuadOutCurve();

  @override
  double transformInternal(double t) => _quadOut(t);
}

/// A TWEEN.js tween of one value.
@immutable
class _Anim<T> {
  const _Anim(
    this.from,
    this.to,
    this.start,
    this.seconds,
    this.lerp, [
    this.ease = _linear,
  ]);

  final T from;
  final T to;
  final double start;
  final double seconds;
  final T Function(T a, T b, double t) lerp;
  final _Ease ease;

  double progress(double now) =>
      seconds <= 0 ? 1 : ((now - start) / seconds).clamp(0.0, 1.0);

  T at(double now) => lerp(from, to, ease(progress(now)));

  bool isDone(double now) => progress(now) >= 1;
}

_V _lerpV(_V a, _V b, double t) => a + (b - a) * t;

/// One canvas-confetti piece (design px).
class _Confetto {
  _Confetto(this.x, this.y, this.angle, this.speed, this.color, this.wobble);

  double x;
  double y;
  final double angle;
  double speed;
  final Color color;
  double wobble;
}

/// canvas-confetti `{particleCount: 150, spread: 70, origin: {y: 0.3}}`:
/// start speed 45 px / frame, decay 0.9 / frame, gravity 3 px / frame,
/// 200 frames.
const int _confettiCount = 150;
const double _confettiSpread = 70 * math.pi / 180;
const double _confettiSpeed = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiSeconds = 200 / 60;
const Offset _confettiOrigin = Offset(500, 168);

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  _Scene() {
    load(0, math.Random(1));
  }

  double time = 0;
  int scenario = 0;

  /// 1-based step; the step count + 1 once the scenario is done.
  int step = 1;

  /// Bumped by every [load]: callbacks of an earlier scenario are dropped.
  int token = 0;

  // --------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// True once the scene has finished re-fitting itself (tests wait for it
  /// before tapping).
  bool get framingSettled => _framingT >= 1;

  // ---------------------------------------------------------- camera
  _V eye = _s1Eye;
  _V target = _V.zero;
  _Anim<_V>? eyeAnim;
  _Anim<_V>? targetAnim;

  // ------------------------------------------------------ scenario 1
  /// Tiles in the tray (HTML: shuffled).
  final List<int> order = [1, 2, 3, 4, 5, 6];

  /// Tiles dropped into their slots (1–6, in order).
  int placed = 0;

  /// When each model popped up / each route leg started (null: not yet).
  final List<double?> popStart = List<double?>.filled(6, null);
  final List<double?> legStart = List<double?>.filled(6, null);

  /// Meters (HTML `updateS1Meters`).
  int miles = 0;
  int pollution = 0;

  /// The timeline fades out after the last tile, then is hidden.
  bool timelineFading = false;
  bool timelineHidden = false;

  // ------------------------------------------------------ scenario 2
  double yaw = _startYaw;
  _S2Mode mode = _S2Mode.select;
  _Pin? selected;
  double selectedAt = 0;

  /// A finger is spinning the globe (the slow spin pauses).
  bool spinning = false;

  _Pin? route;
  double routeStart = 0;
  double routeSeconds = _localSeconds;
  final List<_V> routePts = [];

  /// Part of the route (fractions of its length) travelled by ship.
  double shipFrom = 1;
  double shipTo = 0;

  /// Set by [advance] when the shipment has arrived; the page handles it.
  bool routeArrived = false;

  /// Meters (HTML `updateS2Meters`): km, bar fraction, colours, freshness.
  int s2Miles = 0;
  double s2MilesBar = 0;
  bool s2MilesRed = false;
  int s2Pollution = 0;
  int? freshness;

  /// Restarts the Food Miles counter (its key).
  int counterRun = 0;

  final List<_Confetto> confetti = [];
  double confettiStart = 0;

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index, math.Random random) {
    token++;
    scenario = index;
    step = 1;
    eye = index == 0 ? _s1Eye : _s2Eye;
    target = _V.zero;
    eyeAnim = targetAnim = null;
    order
      ..clear()
      ..addAll([1, 2, 3, 4, 5, 6])
      ..shuffle(random);
    placed = 0;
    popStart.fillRange(0, 6, null);
    legStart.fillRange(0, 6, null);
    miles = pollution = 0;
    timelineFading = timelineHidden = false;
    yaw = _startYaw;
    mode = _S2Mode.select;
    selected = null;
    spinning = false;
    route = null;
    routePts.clear();
    routeArrived = false;
    resetS2Meters();
    confetti.clear();
  }

  /// HTML `updateS2Meters(0, 100, 0)`.
  void resetS2Meters() {
    s2Miles = 0;
    s2MilesBar = 0;
    s2MilesRed = false;
    s2Pollution = 0;
    freshness = null;
    counterRun++;
  }

  _Proj get proj => _Proj(eye, target, framing);

  void flyTo(_V toEye, _V toTarget, double seconds, _Ease ease) {
    eyeAnim = _Anim(eye, toEye, time, seconds, _lerpV, ease);
    targetAnim = _Anim(target, toTarget, time, seconds, _lerpV, ease);
  }

  // -------------------------------------------------------- scenario 1

  /// Pop-up scale of stop [i]'s model (0 before it appears).
  double modelScale(int i) {
    final t = popStart[i];
    if (t == null) return 0;
    return _elasticOut(((time - t) / _popSeconds).clamp(0.0, 1.0));
  }

  /// Drawn part (0–1) of the route into stop [i].
  double legProgress(int i) {
    final t = legStart[i];
    if (t == null) return 0;
    return ((time - t) / _pathSeconds).clamp(0.0, 1.0);
  }

  /// HTML `animateS1Step(step)`: the model pops up, the camera flies to it,
  /// the route from the previous stop is drawn, the meters update.
  void placeTile() {
    final i = placed;
    placed++;
    popStart[i] = time;
    if (i > 0) legStart[i] = time;
    final stop = _stops[i];
    flyTo(
      _V(stop.x, _flyHeight, stop.z + _flyBack),
      stop,
      _flySeconds,
      _quadInOut,
    );
    miles = _s1Miles[i];
    pollution = _s1Pollution[i];
    step = placed + 1;
  }

  // -------------------------------------------------------- scenario 2

  /// Unit direction of [place] on the globe as it is turned now.
  _V pinDir(_Pin pin) {
    final (lat, lon) = pin == _Pin.local ? _punjab : _wheatBelt;
    return _globeDir(lat, lon, yaw);
  }

  /// HTML pin click: highlight, stop the spin, camera to the pin.
  void selectPin(_Pin pin) {
    selected = pin;
    selectedAt = time;
    final base = pinDir(pin) * _globeR;
    flyTo(base * _focusOut, base * _focusIn, _focusSeconds, _quadOut);
  }

  /// HTML `animateS2Choice`: the route is drawn and the vehicle follows it.
  void startRoute(_Pin pin) {
    mode = _S2Mode.moving;
    route = pin;
    routeStart = time;
    routeSeconds = pin == _Pin.local ? _localSeconds : _importSeconds;
    routeArrived = false;
    eyeAnim = targetAnim = null;
    final local = pin == _Pin.local;
    final (points, legEnds) = _buildRoute(
      local
          ? const [
              [_punjab, _kitchen],
            ]
          : const [_importByTruck, _importByShip, _importByRoad],
      local ? _localSegments : _importSegments,
      yaw,
    );
    routePts
      ..clear()
      ..addAll(points);
    shipFrom = local ? 1 : legEnds[0];
    shipTo = local ? 0 : legEnds[1];
  }

  /// Eased progress of the shipment (0–1).
  double get routeProgress {
    if (route == null) return 0;
    final raw = ((time - routeStart) / routeSeconds).clamp(0.0, 1.0);
    return _quadInOut(raw);
  }

  /// Route point index of the vehicle (HTML `Math.floor(t * 99)` of 100).
  int get vehicleIndex {
    final last = routePts.length - 2;
    if (last < 0) return 0;
    return (routeProgress * last).floor().clamp(0, last);
  }

  /// The vehicle is on the sea leg (a cargo ship; a truck on land).
  bool get onShip {
    final n = routePts.length - 1;
    if (n <= 0) return false;
    final f = vehicleIndex / n;
    return f >= shipFrom && f <= shipTo;
  }

  /// HTML `updateS2Meters(miles, freshness, pollution, type)`.
  void showResult(_Pin pin) {
    final (km, fresh, pol) = _s2Results[pin]!;
    s2Miles = km;
    s2MilesBar = pin == _Pin.local ? 0.05 : 1;
    s2MilesRed = pin == _Pin.imported;
    s2Pollution = pol;
    freshness = fresh;
    counterRun++;
  }

  /// HTML 'Try the other option': back to choosing, meters and camera reset.
  void tryOther() {
    mode = _S2Mode.select;
    selected = null;
    route = null;
    routePts.clear();
    routeArrived = false;
    resetS2Meters();
    eyeAnim = targetAnim = null;
    eye = _s2Eye;
    target = _V.zero;
  }

  // -------------------------------------------------------- test hooks

  /// Design point of pin [id] ('local' / 'imported') if it can be tapped
  /// now (its head is in view), else null.
  Offset? pinPoint(String id) {
    final pin = _Pin.values.byName(id);
    final head = pinDir(pin) * (_globeR + _pinHeight);
    if (!_inView(eye, head)) return null;
    final p = proj.p(head);
    return _stageRect.contains(p) ? p : null;
  }

  /// Where pin [id] faces (degrees, 0 = towards the start camera; negative
  /// = left of it).
  double pinFacing(String id) {
    final d = pinDir(_Pin.values.byName(id));
    return math.atan2(d.x, d.z) * 180 / math.pi;
  }

  /// Centre and radius (design px) of the globe on the stage.
  Offset get globeCenter => proj.p(_V.zero);
  double get globeRadius => _globeR * proj.scaleAt(_V.zero);

  String get modeName => mode.name;
  String? get selectedName => selected?.name;

  // --------------------------------------------------------- framing etc.

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

  void burstConfetti() {
    confetti.clear();
    confettiStart = time;
    final random = math.Random(7);
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          _confettiOrigin.dx,
          _confettiOrigin.dy,
          -math.pi / 2 + (random.nextDouble() - 0.5) * _confettiSpread,
          _confettiSpeed * (0.5 + random.nextDouble() * 0.5),
          _Colors.confetti[i % _Colors.confetti.length],
          random.nextDouble() * 10,
        ),
      );
    }
  }

  /// TWEEN.update() plus the globe's spin, the shipment, the framing and
  /// the confetti. True while anything on the canvas moves.
  bool advance(double dt) {
    final now = time;
    var moving = false;
    if (eyeAnim case final a?) {
      eye = a.at(now);
      if (a.isDone(now)) eyeAnim = null;
      moving = true;
    }
    if (targetAnim case final a?) {
      target = a.at(now);
      if (a.isDone(now)) targetAnim = null;
      moving = true;
    }
    if (scenario == 0) {
      for (var i = 0; i < 6; i++) {
        final p = popStart[i];
        final l = legStart[i];
        if (p != null && now < p + _popSeconds) moving = true;
        if (l != null && now < l + _pathSeconds) moving = true;
      }
    } else {
      if (mode == _S2Mode.select && selected == null && !spinning) {
        yaw += _spinPerSecond * dt;
        moving = true;
      }
      // The selection marker pulses.
      if (selected != null && mode != _S2Mode.confirmed) moving = true;
      if (mode == _S2Mode.moving && routePts.isNotEmpty) {
        final v = routePts[vehicleIndex];
        eye = v.unit * (_globeR + _followHeight);
        target = v;
        moving = true;
        if (now >= routeStart + routeSeconds) routeArrived = true;
      }
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      moving = true;
    }
    if (confetti.isNotEmpty) {
      if (now - confettiStart > _confettiSeconds) {
        confetti.clear();
      } else {
        final frames = dt * 60;
        final decay = math.pow(_confettiDecay, frames).toDouble();
        for (final c in confetti) {
          c
            ..x += math.cos(c.angle) * c.speed * frames
            ..y +=
                math.sin(c.angle) * c.speed * frames + _confettiGravity * frames
            ..speed *= decay
            ..wobble += 0.1 * frames;
        }
      }
      moving = true;
    }
    return moving;
  }
}

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
  _V get unit {
    final l = length;
    return l < 1e-9 ? const _V(0, 1, 0) : this * (1 / l);
  }
}

/// Direction of latitude [lat] / longitude [lon] (degrees) on a globe turned
/// by [yaw]: the HTML `setFromSphericalCoords(r, π/2 − lat, lon)` with the
/// Earth texture's mapping (`s2Earth.rotation.y = −π/2`).
_V _globeDir(double lat, double lon, double yaw) {
  final phi = lat * math.pi / 180;
  final th = lon * math.pi / 180 + yaw;
  return _V(
    math.cos(phi) * math.sin(th),
    math.sin(phi),
    math.cos(phi) * math.cos(th),
  );
}

/// Point [t] (0–1) of the great circle from unit vector [a] to [b].
_V _slerp(_V a, _V b, double t) {
  final angle = math.acos(a.dot(b).clamp(-1.0, 1.0));
  if (angle < 1e-6) return a;
  final s = math.sin(angle);
  return a * (math.sin((1 - t) * angle) / s) + b * (math.sin(t * angle) / s);
}

/// A route on the globe (turned by [yaw]) through [legs] of places
/// (latitude, longitude; each leg starts where the previous one ended),
/// along great circles, resampled to [segments] + 1 evenly spaced points
/// just above the surface. Also returns where each leg ends (fraction of
/// the route's length).
(List<_V>, List<double>) _buildRoute(
  List<List<(double, double)>> legs,
  int segments,
  double yaw,
) {
  final dense = <_V>[];
  final along = <double>[];
  final legEnds = <double>[];
  var total = 0.0;
  for (final leg in legs) {
    for (var i = 0; i + 1 < leg.length; i++) {
      final a = _globeDir(leg[i].$1, leg[i].$2, yaw);
      final b = _globeDir(leg[i + 1].$1, leg[i + 1].$2, yaw);
      final angle = math.acos(a.dot(b).clamp(-1.0, 1.0));
      final n = math.max(1, (angle / _routeStep).ceil());
      for (var j = dense.isEmpty ? 0 : 1; j <= n; j++) {
        final p = _slerp(a, b, j / n);
        if (dense.isNotEmpty) total += (p - dense.last).length;
        dense.add(p);
        along.add(total);
      }
    }
    legEnds.add(total);
  }
  final points = <_V>[];
  var k = 0;
  for (var i = 0; i <= segments; i++) {
    final want = total * i / segments;
    while (k + 2 < dense.length && along[k + 1] < want) {
      k++;
    }
    final span = along[k + 1] - along[k];
    final t = span <= 0 ? 0.0 : ((want - along[k]) / span).clamp(0.0, 1.0);
    final dir = _lerpV(dense[k], dense[k + 1], t).unit;
    points.add(dir * (_globeR + _routeLift));
  }
  return (points, [for (final end in legEnds) total <= 0 ? 1.0 : end / total]);
}

/// Is [p] (just above or on the globe) in view of a camera at [eye]: the
/// line of sight does not pass through the globe.
bool _inView(_V eye, _V p) {
  final d = p - eye;
  final dd = d.dot(d);
  if (dd < 1e-9) return true;
  final t = -eye.dot(d) / dd;
  if (t <= 0 || t >= 1) return true;
  return (eye + d * t).length >= _globeR - 1e-3;
}

/// Where the scene sits on the stage: the base (HTML) projection moved to
/// [center] and scaled by [zoom], so it fits beside the floating cards.
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

/// The HTML PerspectiveCamera (45°, up = +y) at [eye] looking at [target],
/// as a pinhole projection onto the design stage in a [_Framing].
class _Proj {
  _Proj(this.eye, _V target, this.framing) : f = (target - eye).unit {
    var right = f.cross(_up);
    if (right.length < 1e-4) right = f.cross(const _V(0, 0, -1));
    r = right.unit;
    u = r.cross(f);
  }

  final _V eye;
  final _V f;
  late final _V r;
  late final _V u;
  final _Framing framing;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => _focal * framing.zoom / math.max(_near, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = _focal * framing.zoom / math.max(_near, d.dot(f));
    return Offset(
      framing.center.dx + d.dot(r) * k,
      framing.center.dy - d.dot(u) * k,
    );
  }
}

/// Best framing for [focus] (base projection) inside [free], clear of the
/// [obstacles] (all in design coordinates): the largest zoom (at most
/// [_maxZoom]) of the free rectangles left once the obstacles are cut out.
_Framing _fitFraming(Rect focus, Rect free, List<Rect> obstacles) {
  if (free.width <= 1 || free.height <= 1) return _Framing.base;
  var rects = [free];
  for (final o in obstacles) {
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
  (Rect, double)? pick;
  for (final r in rects) {
    final z = math.min(
      _maxZoom,
      math.min(r.width / focus.width, r.height / focus.height),
    );
    if (pick == null ||
        z > pick.$2 + 1e-6 ||
        ((z - pick.$2).abs() <= 1e-6 &&
            r.width * r.height > pick.$1.width * pick.$1.height)) {
      pick = (r, z);
    }
  }
  if (pick == null || pick.$2 <= 0) return _Framing.base;
  final (rect, zoom) = pick;
  return _Framing(rect.center - (focus.center - _designCenter) * zoom, zoom);
}

// ------------------------------------------------------------- page state

class _Ch3A6PageState extends State<Ch3A6FoodMilesAndSustainableEatingPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final _TextCache _text = _TextCache();
  final math.Random _random = math.Random();
  late final Ticker _ticker;

  /// The canvas area (a full-size overlay) and the cards: measured to fit
  /// the scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch3a6-canvas');
  final GlobalKey _metersKey = GlobalKey(debugLabel: 'ch3a6-meters');
  final GlobalKey _timelineKey = GlobalKey(debugLabel: 'ch3a6-timeline');

  /// Stage scale (design px → logical px).
  double _fit = 1;

  /// Accordion cards the learner opened or closed by hand (step numbers).
  final Set<int> _toggledSteps = {};

  /// The scene changed outside a running tween: repaint on the next tick.
  bool _dirty = true;
  bool _framingQueued = false;
  bool _snapFraming = true;

  /// Last pan position on the stage (globe spin).
  Offset? _panLast;

  /// Key, parameters, style and language of the lab's last toast: a
  /// language switch re-shows it translated.
  String? _toastKey;
  Map<String, Object> _toastParams = const {};
  String _toastText = '';
  bool _toastError = false;
  LabLang _toastLang = LabLang.en;

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
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_retranslateToast);
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
    _lab.removeListener(_retranslateToast);
    _ticker.dispose();
    _frame.dispose();
    _text.dispose();
    _lab.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- frames

  /// HTML `animate()` + `TWEEN.update()`. Repaints only the canvas, and only
  /// while something moves.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    final moving = s.advance(dt);
    if (s.routeArrived && s.mode == _S2Mode.moving) _arrived();
    if (moving || _dirty) {
      _dirty = false;
      _frame.value++;
    }
  }

  /// Every state change also redraws the canvas: the painter reads the
  /// mutable scene, so `shouldRepaint` cannot see it change.
  @override
  void setState(VoidCallback fn) {
    _dirty = true;
    super.setState(fn);
  }

  /// Runs [fn] after [delay] unless the scenario was changed meanwhile.
  void _after(Duration delay, VoidCallback fn) {
    final token = _scene.token;
    _lab.after(delay, () {
      if (!mounted || _scene.token != token) return;
      fn();
    });
  }

  void _goToStep(int step) {
    _scene.step = step;
    _toggledSteps.clear();
  }

  // ------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (cards and canvas are laid out by
  /// then).
  void _scheduleFraming() {
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the scenario's focus into the part of the canvas no card covers:
  /// the tool column, the HUD (sidebar open), the floating mission card
  /// (sidebar collapsed), the meters, the timeline (S1) and the action card
  /// (S2).
  void _updateFraming() {
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
    Rect? measured(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return null;
      return (box.localToGlobal(Offset.zero) - origin) & box.size;
    }

    final s = context.labScale;
    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final hud = open && _scene.step <= _stepCounts[_scene.scenario];
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (hud ? _hudBand * s + 8 : 8) - pad.bottom,
    );
    final obstacles = <Rect>[];
    if (_lab.isLabActive) {
      if (!open) {
        final bottom = screen.height < _compactBelow
            ? _missionTop + pad.top + screen.height * _compactCardMax
            : size.height;
        obstacles.add(Rect.fromLTRB(0, 0, insets.left, bottom));
      }
      // The meters never hide the stop that has just been built (S1) or a
      // pin (S2).
      final meters = measured(_metersKey);
      if (meters != null) obstacles.add(meters);
      if (_scene.scenario == 0) {
        final timeline = measured(_timelineKey);
        if (timeline != null && !_scene.timelineFading) {
          obstacles.add(timeline);
        }
      } else {
        final slot = _actionSlot(context, size);
        if (slot != null) obstacles.add(slot);
      }
    }
    final target = _fitFraming(
      _scene.scenario == 0 ? _focusS1 : _focusS2,
      toDesign(free).intersect(_stageRect),
      [for (final r in obstacles) toDesign(r.inflate(_cardGap))],
    );
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
    _dirty = true;
  }

  // ------------------------------------------------------------------ toasts

  /// Shows the toast [key] in the current language ([params] that are
  /// strings are string keys, translated too). Normal toasts are silent
  /// (the HTML has none); errors play the wrong tone.
  void _toast(
    String key, {
    bool error = false,
    Map<String, Object> params = const {},
  }) {
    _toastKey = key;
    _toastParams = params;
    _toastError = error;
    _toastLang = _lab.lang;
    _toastText = _format(key, params);
    _lab.showToast(_toastText, isError: error, sound: error);
  }

  String _format(String key, Map<String, Object> params) => labFormat(_t(key), {
    for (final e in params.entries)
      e.key: e.value is String ? _t(e.value as String) : e.value,
  });

  /// After a language switch, the toast still on screen is shown again in
  /// the new language (silently, after the current frame).
  void _retranslateToast() {
    final key = _toastKey;
    if (key == null || _lab.lang == _toastLang) return;
    _toastLang = _lab.lang;
    final shown = _lab.toast;
    if (shown == null || shown.text != _toastText) return;
    final error = _toastError;
    final params = _toastParams;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _toastKey = key;
      _toastText = _format(key, params);
      _lab.showToast(_toastText, isError: error, sound: false);
    });
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` (also Enter Lab, Restart Lab and Reset Lab):
  /// cancels every pending timer and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _toastKey = null;
    _panLast = null;
    setState(() {
      _scene.load(index, _random);
      _toggledSteps.clear();
    });
    _lab.resetView(sound: false);
    _snapFraming = true;
    _scheduleFraming();
  }

  /// HTML drag start on a `.draggable-icon`.
  void _onTileLifted() => _Sound.pop.play();

  /// HTML pointerup over the timeline: the right tile on the highlighted
  /// slot is placed; the wrong tile there buzzes (here with a hint), as
  /// does a tile dropped on another slot (the HTML sent it back silently).
  void _onTileDropped(int slot, int tile) {
    final s = _scene;
    if (s.scenario != 0 || s.step > _stepCounts[0] || tile <= s.placed) {
      return;
    }
    if (slot != s.step) {
      _toast('err_slot', error: true, params: {'n': s.step});
      return;
    }
    if (tile != s.step) {
      _toast(
        'err_tile',
        error: true,
        params: {'name': 'tile_${s.step}', 'n': s.step},
      );
      return;
    }
    _Sound.correct.play();
    if (_truckLegs.contains(s.placed)) _Sound.truck.play();
    final last = s.placed + 1 == _stepCounts[0];
    setState(() {
      s.placeTile();
      _toggledSteps.clear();
      // HTML: the timeline fades out (0.5 s) and is hidden.
      if (last) s.timelineFading = true;
    });
    if (last) {
      _after(_timelineFade, () => setState(() => s.timelineHidden = true));
      _after(_s1ConclusionDelay, _showConclusion);
    }
  }

  /// HTML pin click (raycast on the two pins).
  void _onStageTap(Offset at) {
    final s = _scene;
    if (s.scenario != 1 || s.mode != _S2Mode.select || s.step > 4) return;
    final pin = _pinAt(at);
    if (pin == null) return;
    final wanted = s.step <= 2 ? _Pin.local : _Pin.imported;
    if (pin != wanted) {
      _toast(
        wanted == _Pin.local ? 'err_local_first' : 'err_import_now',
        error: true,
      );
      return;
    }
    _Sound.click.play();
    setState(() {
      s.selectPin(pin);
      if (s.step == 1) _goToStep(2);
      if (s.step == 3) _goToStep(4);
    });
  }

  /// The pin under [at] (design px) whose head is in view.
  _Pin? _pinAt(Offset at) {
    final s = _scene;
    final p = s.proj;
    _Pin? best;
    var bestD = double.infinity;
    for (final pin in _Pin.values) {
      final dir = s.pinDir(pin);
      final head = dir * (_globeR + _pinHeight);
      if (!_inView(s.eye, head)) continue;
      final radius = math.max(
        (_pinHeadR + 0.5) * p.scaleAt(head),
        _touchDp / math.max(_fit, 0.01),
      );
      final d = _segmentDistance(at, p.p(dir * _globeR), p.p(head));
      if (d <= radius && d < bestD) {
        best = pin;
        bestD = d;
      }
    }
    return best;
  }

  /// HTML 'Confirm Choice'.
  void _confirm() {
    final s = _scene;
    final pin = s.selected;
    if (s.mode != _S2Mode.select || pin == null) return;
    if (!(s.step == 2 && pin == _Pin.local) &&
        !(s.step == 4 && pin == _Pin.imported)) {
      return;
    }
    (pin == _Pin.imported ? _Sound.truck : _Sound.click).play();
    setState(() => s.startRoute(pin));
  }

  /// HTML `animateS2Choice(...).onComplete`: the meters show the result and
  /// the lab moves on; after the imported flour, the summary 2 s later.
  void _arrived() {
    final s = _scene;
    final pin = s.route;
    if (pin == null) return;
    setState(() {
      s
        ..mode = _S2Mode.confirmed
        ..routeArrived = false
        ..showResult(pin);
      _goToStep(s.step + 1);
    });
    if (pin == _Pin.imported) _after(_s2ConclusionDelay, _showConclusion);
  }

  /// HTML 'Try the other option'.
  void _tryOther() {
    final s = _scene;
    if (s.step != 3 || s.mode != _S2Mode.confirmed) return;
    setState(s.tryOther);
  }

  /// HTML `triggerConclusion()`.
  void _showConclusion() {
    final sc = _scene.scenario;
    _scene.burstConfetti();
    _dirty = true;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => sc == 0 ? _S1Summary(t: _t) : _S2Summary(t: _t),
    );
  }

  void _toggleStep(int i) {
    _Sound.pop.play();
    setState(() {
      if (!_toggledSteps.remove(i)) _toggledSteps.add(i);
    });
  }

  // ------------------------------------------------------- globe spin

  bool get _canSpin =>
      _scene.scenario == 1 &&
      _scene.mode == _S2Mode.select &&
      _scene.selected == null;

  void _onPanStart(DragStartDetails d) {
    if (!_canSpin) return;
    _panLast = d.localPosition;
    _scene.spinning = true;
  }

  /// Dragging sideways turns the globe (the HTML's OrbitControls, which
  /// needed the camera unlocked).
  void _onPanUpdate(DragUpdateDetails d) {
    final last = _panLast;
    if (last == null || !_canSpin) return;
    _panLast = d.localPosition;
    final radius = math.max(_scene.globeRadius, 40.0);
    _scene.yaw += (d.localPosition.dx - last.dx) / radius * _dragTurn;
    _dirty = true;
  }

  void _onPanEnd() {
    _panLast = null;
    _scene.spinning = false;
  }

  // -------------------------------------------------------------------- UI

  /// The HTML `#btn-s2-action` for the current state.
  LabAction? _action() {
    final s = _scene;
    if (s.scenario != 1) return null;
    if (s.mode == _S2Mode.select &&
        s.selected != null &&
        (s.step == 2 || s.step == 4)) {
      return LabAction(
        label: _t('btn_confirm'),
        icon: Icons.check_circle,
        color: _Colors.emerald600,
        foreground: _Colors.white,
        highlight: true,
        onTap: _confirm,
      );
    }
    if (s.mode == _S2Mode.confirmed && s.step == 3) {
      return LabAction(
        label: _t('btn_try_other'),
        icon: Icons.restart_alt,
        color: _Colors.slate700,
        foreground: _Colors.white,
        onTap: _tryOther,
      );
    }
    return null;
  }

  /// Bottom of the cards above the HUD chip (canvas px).
  double _cardBottom(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final hud =
        _lab.isSidebarOpen && _scene.step <= _stepCounts[_scene.scenario];
    return 8 + pad.bottom + (hud ? _hudBand * context.labScale + 6 : 0);
  }

  /// Where the S2 canvas action card goes (canvas px) while the sidebar is
  /// open; reserved even while no action is shown, so the globe does not
  /// jump.
  Rect? _actionSlot(BuildContext context, Size canvas) {
    if (!_lab.isSidebarOpen || !_lab.isLabActive || _scene.scenario != 1) {
      return null;
    }
    final s = context.labScale;
    final width = _actionCardWidth * s;
    final height = _actionCardHeight * s;
    final insets = labOverlayInsets(context, _lab);
    final mid = (insets.left + canvas.width - insets.right) / 2;
    final bottom = canvas.height - _cardBottom(context);
    return Rect.fromLTWH(mid - width / 2, bottom - height, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        final s = _scene;
        final sc = s.scenario;
        final steps = _stepCounts[sc];
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.local_shipping,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          hud: _t('s${sc + 1}_hud_${s.step.clamp(1, steps)}'),
          // The last task line no longer applies once the scenario is done.
          showHud: s.step <= steps,
          actions: [?_action()],
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            scenario: sc,
            steps: data.steps,
            currentStep: s.step,
            toggled: Set.of(_toggledSteps),
            onToggle: _toggleStep,
            t: _t,
            fontScale: _lab.fontScale,
          ),
          overlays: _overlays(context),
          // HTML enterLab() and resetApp() start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          stage: _stage(),
        );
      },
    );
  }

  /// The HTML meters panel (top right), the S1 timeline and tile tray
  /// (bottom), the S2 action button (bottom centre, sidebar open) and the
  /// layer used to measure the canvas.
  List<Widget> _overlays(BuildContext context) {
    final s = _scene;
    final scale = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final pad = MediaQuery.paddingOf(context);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final active = _lab.isLabActive;
    final bottom = _cardBottom(context);
    final action = _action();
    // Below the compact mission card on phones; beside it on tablets.
    final double timelineLeft = open || compact
        ? 8.0 + (open ? 0.0 : pad.left)
        : insets.left;
    return [
      if (active)
        Positioned(
          key: const ValueKey('ch3a6-meters-card'),
          top: insets.top,
          right: insets.right,
          child: _MetersCard(key: _metersKey, scene: s, scale: scale, t: _t),
        ),
      if (active && s.scenario == 0 && !s.timelineHidden)
        Positioned(
          key: const ValueKey('ch3a6-timeline-card'),
          left: timelineLeft,
          right: insets.right,
          bottom: bottom,
          // The room the canvas really has: it changes while the sidebar
          // slides open or closed.
          child: LayoutBuilder(
            builder: (context, box) => Align(
              alignment: Alignment.bottomCenter,
              child: _TimelineCard(
                key: _timelineKey,
                scene: s,
                width: box.maxWidth,
                scale: scale,
                t: _t,
                onLifted: _onTileLifted,
                onDropped: _onTileDropped,
              ),
            ),
          ),
        ),
      if (active &&
          open &&
          s.scenario == 1 &&
          action != null &&
          _lab.popup == null)
        Positioned(
          key: const ValueKey('ch3a6-action-card'),
          left: insets.left,
          right: insets.right,
          bottom: bottom,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: _actionCardWidth * scale,
              child: LabGlassCard(
                palette: _lab.palette,
                padding: EdgeInsets.all(6 * scale),
                child: LabActionButton(
                  action: action,
                  scale: scale,
                  dense: true,
                ),
              ),
            ),
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
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
        if (fit > 0 && fit.isFinite) _fit = fit;
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The scene is described by its labels and the sidebar steps.
            excludeFromSemantics: true,
            onTapUp: (d) => _onStageTap(d.localPosition),
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(),
            onPanCancel: _onPanEnd,
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  text: _text,
                  repaint: _frame,
                  palette: _lab.palette,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  stageFit: _fit,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// '12000' → '12,000' (HTML `toLocaleString()`).
String _grouped(int v) {
  final digits = '$v';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

// ------------------------------------------------------------ meters card

/// HTML `#meters-panel`: Food Miles (km and bar), Pollution and, in S2 once
/// a choice has arrived, Freshness. Bars glide to their new width (HTML CSS
/// transitions: 1 s for Food Miles, 0.8 s cubic-bezier(0.4, 0, 0.2, 1) for
/// the meters); in S2 the km count up for 2 s.
class _MetersCard extends StatelessWidget {
  const _MetersCard({
    super.key,
    required this.scene,
    required this.scale,
    required this.t,
  });

  final _Scene scene;
  final double scale;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = scale;
    final sc = scene.scenario;
    final miles = sc == 0 ? scene.miles : scene.s2Miles;
    final bar = sc == 0 ? scene.miles / _s1MilesMax : scene.s2MilesBar;
    final barColor = sc == 1 && scene.s2MilesRed
        ? _Colors.red500
        : _Colors.emerald500;
    final pol = sc == 0 ? scene.pollution : scene.s2Pollution;
    final polColor = sc == 0
        ? (pol < 30
              ? _Colors.green500
              : (pol < 60 ? _Colors.yellow500 : _Colors.red500))
        : (pol < 30 ? _Colors.green500 : _Colors.red600);
    final fresh = scene.freshness;
    final valueColor = p.ink(_Colors.emerald400);
    final valueStyle = TextStyle(
      color: valueColor,
      fontSize: 14 * s,
      fontWeight: FontWeight.w900,
    );
    String km(int v) => '${_grouped(v)} ${t('unit_km')}';
    final value = sc == 0
        ? Text(km(miles), key: const ValueKey('ch3a6-miles'), style: valueStyle)
        : TweenAnimationBuilder<double>(
            key: ValueKey('ch3a6-counter-${scene.counterRun}'),
            tween: Tween(begin: 0, end: miles.toDouble()),
            duration: _counterTime,
            curve: const _QuadOutCurve(),
            builder: (context, v, _) => Text(
              km(v.floor()),
              key: const ValueKey('ch3a6-miles'),
              style: valueStyle,
            ),
          );
    return Material(
      color: LabInk.clear,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 9 * s),
        radius: 14,
        child: SizedBox(
          width: (_metersWidth * s).clamp(140.0, 240.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _label(p, t('lbl_food_miles'))),
                  SizedBox(width: 6 * s),
                  Flexible(
                    child: FittedBox(fit: BoxFit.scaleDown, child: value),
                  ),
                ],
              ),
              SizedBox(height: 4 * s),
              _Bar(
                value: bar.clamp(0.0, 1.0),
                color: barColor,
                height: 6 * s,
                duration: const Duration(milliseconds: 1000),
                palette: p,
              ),
              SizedBox(height: 8 * s),
              Row(
                children: [
                  Icon(Icons.cloud, size: 13 * s, color: _Colors.red500),
                  SizedBox(width: 4 * s),
                  Expanded(child: _label(p, t('lbl_pollution'))),
                ],
              ),
              SizedBox(height: 4 * s),
              _Bar(
                value: pol / 100,
                color: polColor,
                height: 12 * s,
                duration: const Duration(milliseconds: 800),
                palette: p,
                framed: true,
              ),
              if (sc == 1) ...[
                SizedBox(height: 8 * s),
                // Space kept so the card does not grow when it appears.
                Visibility(
                  visible: fresh != null,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            size: 13 * s,
                            color: _Colors.green500,
                          ),
                          SizedBox(width: 4 * s),
                          Expanded(child: _label(p, t('lbl_freshness'))),
                        ],
                      ),
                      SizedBox(height: 4 * s),
                      _Bar(
                        value: (fresh ?? 100) / 100,
                        color: (fresh ?? 100) > 50
                            ? _Colors.green500
                            : _Colors.yellow600,
                        height: 12 * s,
                        duration: const Duration(milliseconds: 800),
                        palette: p,
                        framed: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// HTML meter label: `text-xs font-bold uppercase tracking-wider`, never
  /// below [_meterLabelMin] (Devanagari a little larger) on small phones.
  Widget _label(LabPalette p, String text) {
    final english = !_hasDevanagari(text);
    return Text(
      english ? text.toUpperCase() : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: p.textMuted,
        fontSize: math.max(_meterLabelMin + (english ? 0 : 1), 10 * scale),
        fontWeight: FontWeight.w800,
        letterSpacing: labLetterSpacing(text, 0.6),
      ),
    );
  }
}

/// A meter bar that glides to [value] (0–1) and [color].
class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.color,
    required this.height,
    required this.duration,
    required this.palette,
    this.framed = false,
  });

  final double value;
  final Color color;
  final double height;
  final Duration duration;
  final LabPalette palette;

  /// HTML `.meter-bar-container`: a bordered track.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate700 : _Colors.slate200,
        borderRadius: BorderRadius.circular(height),
        border: framed
            ? Border.all(color: p.isDark ? _Colors.slate600 : _Colors.slate300)
            : null,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value),
          duration: duration,
          curve: Curves.fastOutSlowIn,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v.clamp(0.0, 1.0),
            heightFactor: 1,
            child: AnimatedContainer(duration: duration, color: color),
          ),
        ),
      ),
    );
  }
}

bool _hasDevanagari(String s) => RegExp('[ऀ-ॿ]').hasMatch(s);

// ---------------------------------------------------------- timeline card

/// HTML `#s1-ui-container`: the six timeline slots (the next one
/// highlighted amber, filled ones green) above the tray of shuffled tiles.
/// On a narrow canvas the slots and the tray wrap into rows of three.
class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    super.key,
    required this.scene,
    required this.width,
    required this.scale,
    required this.t,
    required this.onLifted,
    required this.onDropped,
  });

  final _Scene scene;

  /// Room on the canvas for the card (logical px).
  final double width;
  final double scale;
  final String Function(String key) t;
  final VoidCallback onLifted;
  final void Function(int slot, int tile) onDropped;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = scale;
    final pad = _journeyPad * s;
    final gap = math.max(6.0, _journeyGap * s);
    // The arrows between slots get their own width, so the icon never
    // overlaps a slot.
    final arrow = math.max(gap, _arrowMin * s);
    final maxTile = math.max(_tileMin, _tileMax * s);
    final inner = width - 2 * pad - 8;
    final oneRow = (inner - 5 * arrow) / 6;
    final columns = oneRow >= _tileMin ? 6 : 3;
    final tile = columns == 6
        ? oneRow.clamp(_tileMin, maxTile)
        : ((inner - 2 * arrow) / 3).clamp(_tileMin, maxTile);
    Widget slotRow(int from, int to) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = from; i <= to; i++) ...[
          if (i > from)
            SizedBox(
              width: arrow,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: arrow,
                color: _Colors.slate400,
              ),
            ),
          _slot(p, i, tile),
        ],
      ],
    );
    final tray = [
      for (final id in scene.order)
        if (id > scene.placed) _tile(id, tile),
    ];
    Widget trayRow(List<Widget> tiles) => SizedBox(
      height: tile,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            tiles[i],
          ],
        ],
      ),
    );
    final children = columns == 6
        ? [slotRow(1, 6), SizedBox(height: gap), trayRow(tray)]
        : [
            slotRow(1, 3),
            SizedBox(height: gap * 0.6),
            slotRow(4, 6),
            SizedBox(height: gap),
            trayRow(tray.take(3).toList()),
            SizedBox(height: gap * 0.6),
            trayRow(tray.skip(3).toList()),
          ];
    return AnimatedOpacity(
      opacity: scene.timelineFading ? 0 : 1,
      duration: _timelineFade,
      child: Material(
        color: LabInk.clear,
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.all(pad),
          radius: 16,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }

  /// HTML `.timeline-slot`: dashed slate border; `.active` amber; `.filled`
  /// solid emerald with the tile inside.
  Widget _slot(LabPalette p, int i, double size) {
    final filled = i <= scene.placed;
    final active = i == scene.placed + 1;
    return DragTarget<int>(
      key: ValueKey('ch3a6-slot-$i'),
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => onDropped(i, d.data),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        final edge = filled
            ? _Colors.emerald500
            : (active || hot ? _Colors.amber500 : _Colors.slate400);
        final fill = filled
            ? _Colors.emerald500.withValues(alpha: 0.12)
            : (active
                  ? _Colors.amber500.withValues(alpha: hot ? 0.25 : 0.12)
                  : (p.isDark
                        ? _Colors.slate800.withValues(alpha: 0.5)
                        : _Colors.white.withValues(alpha: 0.5)));
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _SlotPainter(edge: edge, fill: fill, dashed: !filled),
            child: filled
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: _TileFace(id: i, name: t('tile_$i'), size: size - 6),
                  )
                : Center(
                    child: Text(
                      '$i',
                      style: TextStyle(
                        color: edge.withValues(alpha: active ? 0.9 : 0.6),
                        fontSize: size * 0.3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// HTML `.draggable-icon`: picked up with a finger and carried to a slot.
  Widget _tile(int id, double size) {
    final face = _TileFace(id: id, name: t('tile_$id'), size: size);
    return Draggable<int>(
      key: ValueKey('ch3a6-tile-$id'),
      data: id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onLifted,
      // HTML `.dragging`: 1.1× with a shadow, centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: Transform.scale(
            scale: 1.1,
            child: _TileFace(
              id: id,
              name: t('tile_$id'),
              size: size,
              lifted: true,
            ),
          ),
        ),
      ),
      childWhenDragging: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: const _SlotPainter(
            edge: _Colors.slate400,
            fill: LabInk.clear,
            dashed: true,
          ),
        ),
      ),
      child: face,
    );
  }
}

/// Icons for the six journey tiles (HTML emoji 🧑‍🌾 🚜 📦 🏭 🚚 🫓).
const List<IconData> _tileIcons = [
  Icons.nature_people,
  Icons.agriculture,
  Icons.warehouse,
  Icons.factory,
  Icons.local_shipping,
  Icons.restaurant,
];

/// One journey tile: white card, beige icon face, name below. Built without
/// the lab's style scope, because the dragged copy lives in the app overlay.
class _TileFace extends StatelessWidget {
  const _TileFace({
    required this.id,
    required this.name,
    required this.size,
    this.lifted = false,
  });

  final int id;
  final String name;
  final double size;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final icon = size * 0.46;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: _Colors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: _Colors.slate200),
        boxShadow: [
          BoxShadow(
            color: LabInk.black.withValues(alpha: lifted ? 0.3 : 0.15),
            blurRadius: lifted ? 18 : 4,
            offset: Offset(0, lifted ? 8 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: _Colors.tileFace,
                  borderRadius: BorderRadius.circular(size * 0.1),
                  border: Border.all(color: _Colors.tileEdge, width: 2),
                ),
                child: Icon(
                  _tileIcons[id - 1],
                  size: icon * 0.75,
                  color: _Colors.tileInk,
                ),
              ),
            ),
          ),
          SizedBox(height: size * 0.03),
          SizedBox(
            height: size * 0.2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                maxLines: 1,
                style: TextStyle(
                  color: _Colors.slate700,
                  fontSize: size * 0.17,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A slot's rounded box: dashed (empty) or solid (filled) border.
class _SlotPainter extends CustomPainter {
  const _SlotPainter({
    required this.edge,
    required this.fill,
    required this.dashed,
  });

  final Color edge;
  final Color fill;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.2));
    canvas.drawRRect(rr, Paint()..color = fill);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = edge;
    if (dashed) {
      labDashedPath(canvas, Path()..addRRect(rr), stroke, dash: 6, gap: 4);
    } else {
      canvas.drawRRect(rr, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SlotPainter old) =>
      old.edge != edge || old.fill != fill || old.dashed != dashed;
}

// ------------------------------------------------------- conclusion visuals

/// HTML S1 summary: wheat → plate, total Food Miles and the pollution bar.
class _S1Summary extends StatelessWidget {
  const _S1Summary({required this.t});

  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    Widget icon(int id) => Container(
      width: 40 * s,
      height: 40 * s,
      decoration: BoxDecoration(
        color: _Colors.tileFace,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.tileEdge, width: 2),
      ),
      child: Icon(_tileIcons[id - 1], color: _Colors.tileInk, size: 24 * s),
    );
    final caption = TextStyle(
      color: p.textMuted,
      fontSize: 10 * s,
      fontWeight: FontWeight.w800,
    );
    String upper(String text) =>
        _hasDevanagari(text) ? text : text.toUpperCase();
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              icon(1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 3, color: p.cardBorder),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16 * s,
                        color: p.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              icon(6),
            ],
          ),
          SizedBox(height: 12 * s),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        upper(t('sum_total_miles')),
                        textAlign: TextAlign.center,
                        style: caption,
                      ),
                      SizedBox(height: 4 * s),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_s1MilesMax ${t('unit_km')}',
                          style: TextStyle(
                            color: p.ink(_Colors.emerald400),
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: p.cardBorder),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        upper(t('sum_pollution_level')),
                        textAlign: TextAlign.center,
                        style: caption,
                      ),
                      SizedBox(height: 10 * s),
                      SizedBox(
                        width: 90 * s,
                        child: _Bar(
                          value: _s1Pollution.last / 100,
                          color: _Colors.red500,
                          height: 14 * s,
                          duration: const Duration(milliseconds: 800),
                          palette: p,
                          framed: true,
                        ),
                      ),
                    ],
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

/// HTML S2 summary: Local Chapati vs Imported Bread, side by side (one
/// above the other in a narrow popup).
class _S2Summary extends StatelessWidget {
  const _S2Summary({required this.t});

  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final local = _card(p, s, _Pin.local);
    final imported = _card(p, s, _Pin.imported);
    final vs = Container(
      width: 30 * s,
      height: 30 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.card,
        border: Border.all(color: p.cardBorder, width: 2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            t('vs'),
            style: TextStyle(
              color: p.textMuted,
              fontSize: 10 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= 360) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: local),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4 * s),
                  child: Center(child: vs),
                ),
                Expanded(child: imported),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            local,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * s),
              child: Center(child: vs),
            ),
            imported,
          ],
        );
      },
    );
  }

  Widget _card(LabPalette p, double s, _Pin pin) {
    final isLocal = pin == _Pin.local;
    final (km, fresh, pol) = _s2Results[pin]!;
    final accent = isLocal ? _Colors.emerald500 : _Colors.red500;
    Widget row(String label, String value, Color valueColor) => Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 11 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
    Widget bar(double v, Color c) => Padding(
      padding: EdgeInsets.only(top: 3 * s, bottom: 6 * s),
      child: _Bar(
        value: v,
        color: c,
        height: 6 * s,
        duration: const Duration(milliseconds: 800),
        palette: p,
      ),
    );
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: isLocal ? _Colors.emeraldTint : _Colors.redTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t(isLocal ? 'sum_local' : 'sum_import'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(isLocal ? _Colors.emerald400 : _Colors.red400),
              fontSize: 14 * s,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4 * s),
          Icon(
            isLocal ? Icons.restaurant : Icons.bakery_dining,
            size: 30 * s,
            color: p.ink(isLocal ? _Colors.emerald400 : _Colors.red400),
          ),
          SizedBox(height: 6 * s),
          row(t('sum_miles'), '${_grouped(km)} ${t('unit_km')}', p.textStrong),
          bar(
            isLocal ? 0.05 : 1,
            isLocal ? _Colors.emerald500 : _Colors.red500,
          ),
          row(
            t('sum_fresh'),
            t(fresh > 50 ? 'lvl_high' : 'lvl_low'),
            p.ink(fresh > 50 ? _Colors.green400 : _Colors.yellow400),
          ),
          bar(fresh / 100, fresh > 50 ? _Colors.green500 : _Colors.yellow500),
          row(
            t('sum_pol'),
            t(pol < 30 ? 'lvl_low' : 'lvl_high'),
            pol < 30 ? p.textStrong : p.ink(_Colors.red400),
          ),
          bar(pol / 100, pol < 30 ? _Colors.emerald500 : _Colors.red500),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ sidebar extra

/// Sidebar extra: the HTML "Observation Step" accordion (focus, action and,
/// once the step is done, its result and explanation).
class _StepsAccordion extends StatelessWidget {
  const _StepsAccordion({
    required this.scenario,
    required this.steps,
    required this.currentStep,
    required this.toggled,
    required this.onToggle,
    required this.t,
    required this.fontScale,
  });

  final int scenario;
  final List<LabStep> steps;
  final int currentStep;
  final Set<int> toggled;
  final ValueChanged<int> onToggle;
  final String Function(String key) t;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 6 * s),
          _stepCard(p, s, f, i),
        ],
      ],
    );
  }

  /// One accordion card: past steps green with a check, the current one
  /// open, future ones greyed out and closed (HTML `updateTeacherBoard`).
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
    Widget line(String label, String text, Color labelColor, Color color) =>
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$label: ', style: head(labelColor)),
              TextSpan(text: text),
            ],
          ),
          style: body(color),
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
                  line(t('concept_focus'), step.concept, p.accentInk, p.text),
                  SizedBox(height: 6 * s),
                  line(t('action'), step.action, p.textStrong, p.text),
                  SizedBox(height: 6 * s),
                  // The result is shown once it has been observed (the
                  // HTML showed it before the learner acted).
                  if (past) ...[
                    line(
                      t('observation'),
                      step.observation,
                      p.textStrong,
                      p.textMuted,
                    ),
                    SizedBox(height: 6 * s),
                    Container(
                      padding: EdgeInsets.only(top: 6 * s),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: p.cardBorder)),
                      ),
                      child: Text(
                        t('s${scenario + 1}_e$i'),
                        style: body(
                          p.textMuted,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ] else
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

// ================================================================== PAINTING

/// Box faces: outward normal and four corners (in units of the half size).
const List<(_V, _V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(1, -1, 1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(-1, 1, -1), _V(1, 1, -1)),
];

/// Points on a circle (unit radius), shared by every round shape.
const int _roundSegments = 20;
final List<(double, double)> _unitCircle = [
  for (var i = 0; i < _roundSegments; i++)
    (
      math.cos(2 * math.pi * i / _roundSegments),
      math.sin(2 * math.pi * i / _roundSegments),
    ),
];

/// Axes of a part rotated about one world axis (Three.js `rotation.x/y/z`).
(_V, _V, _V) _axes({double rx = 0, double ry = 0, double rz = 0}) {
  if (rx != 0) {
    final c = math.cos(rx), s = math.sin(rx);
    return (const _V(1, 0, 0), _V(0, c, s), _V(0, -s, c));
  }
  if (ry != 0) {
    final c = math.cos(ry), s = math.sin(ry);
    return (_V(c, 0, -s), const _V(0, 1, 0), _V(s, 0, c));
  }
  if (rz != 0) {
    final c = math.cos(rz), s = math.sin(rz);
    return (_V(c, s, 0), _V(-s, c, 0), const _V(0, 0, 1));
  }
  return (const _V(1, 0, 0), const _V(0, 1, 0), const _V(0, 0, 1));
}

/// One decoration on the S1 map: a box building, a tree or a mountain.
enum _Prop { building, tree, mountain }

/// Map decorations: (kind, x, z, width, height).
const List<(_Prop, double, double, double, double)> _props = [
  (_Prop.building, 5.8, 3.9, 1.3, 2.2),
  (_Prop.building, 7.6, 3.6, 1.2, 3.0),
  (_Prop.building, 9.6, 4.2, 1.4, 1.8),
  (_Prop.building, 11.1, 3.6, 1.2, 2.6),
  (_Prop.tree, -10.5, -1.0, 1.0, 1.6),
  (_Prop.tree, -6.0, 4.5, 1.0, 1.5),
  (_Prop.tree, -1.2, -5.8, 0.9, 1.4),
  (_Prop.tree, 7.0, -7.4, 1.0, 1.6),
  (_Prop.tree, 10.4, -2.4, 1.0, 1.5),
  (_Prop.tree, -9.4, 9.0, 1.1, 1.7),
  (_Prop.mountain, -10.6, -10.9, 2.4, 2.0),
  (_Prop.mountain, -6.8, -11.1, 2.0, 1.6),
  (_Prop.mountain, 2.8, -11.0, 2.2, 1.8),
  (_Prop.mountain, 9.2, -11.0, 2.6, 2.2),
];

/// Building colours (slate tones of the HTML city).
const List<Color> _buildingColors = [
  _Colors.slate300,
  _Colors.slate400,
  _Colors.slate200,
  _Colors.slate400,
];

/// River and field patches on the map (x, z).
const List<(double, double)> _river = [
  (-12, 1.6),
  (-8, 2.6),
  (-4, 1.9),
  (0, 2.6),
  (4, 1.7),
  (8, 2.4),
  (12, 1.5),
];

/// Fields: (x0, z0, x1, z1).
const List<(double, double, double, double)> _fields = [
  (-11.5, -3.6, -9.2, -1.4),
  (-8.6, -3.4, -6.4, -0.8),
  (-0.6, -11.6, 1.8, -10.0),
  (5.0, -9.6, 8.0, -8.2),
  (7.0, -6.0, 10.0, -4.0),
  (-11.5, 4.2, -8.5, 7.0),
  (-6.5, 5.4, -3.5, 8.2),
];

/// City ground behind the supermarket and the house.
const (double, double, double, double) _city = (4.6, 2.9, 12, 5.3);

/// Paints the HTML Three.js scenes: S1 the map board with the six stops,
/// the routes and the truck; S2 the globe with its pins, the route and the
/// vehicle; the floating labels and the confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.text,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.stageFit,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache text;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;

  /// Stage scale (design px → logical px): labels stay legible on small
  /// stages.
  final double stageFit;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path _path = Path();

  /// The globe's outline (S2), kept apart from [_path] for clipping.
  final Path _rim = Path();
  final List<Offset> _pts = [];

  late Canvas _c;
  late _Proj _p;

  /// Current model origin and pop-up scale (S1 models).
  _V _o = _V.zero;
  double _k = 1;

  String _s(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(labBleed(size), _fill);
    if (scene.scenario == 0) {
      _paintScenario1();
    } else {
      _paintScenario2();
    }
    if (scene.confetti.isNotEmpty) _paintConfetti();
  }

  // ------------------------------------------------------------ scenario 1

  void _paintScenario1() {
    final s = scene;
    _board();
    // Pads (CylinderGeometry(1.5, 1.5, 0.1), lime) and contact shadows.
    for (var i = 0; i < 6; i++) {
      _discFlat(_stops[i] + const _V(0, 0.05, 0), 1.5);
      _fill
        ..shader = null
        ..color = _lit(_Colors.lime500, _up);
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 1
        ..color = labShade(_Colors.lime500, -0.35).withValues(alpha: 0.7);
      _c.drawPath(_path, _stroke);
      final k = s.modelScale(i);
      if (k > 0) {
        _discFlat(_stops[i] + const _V(0.3, 0.06, 0.3), _modelSize[i].$1 * k);
        _shadow.color = _Colors.black.withValues(alpha: 0.22);
        _c.drawPath(_path, _shadow);
      }
    }
    // Everything standing on the map, far to near.
    final items = <(double, int, int)>[];
    for (var i = 0; i < 6; i++) {
      if (s.modelScale(i) > 0) items.add((_p.depth(_stops[i]), 0, i));
    }
    for (var i = 0; i < _props.length; i++) {
      final (_, x, z, _, _) = _props[i];
      items.add((_p.depth(_V(x, 0, z)), 1, i));
    }
    for (var leg = 1; leg < 6; leg++) {
      final progress = s.legProgress(leg);
      if (progress <= 0) continue;
      for (var j = 0; j < _legSegments; j++) {
        final t0 = j / _legSegments;
        if (t0 >= progress) break;
        final t1 = math.min((j + 1) / _legSegments, progress);
        final mid = _legPoint(leg, (t0 + t1) / 2);
        if (_insideModel(leg, mid)) continue;
        items.add((_p.depth(mid), 2, leg * 100 + j));
      }
      if (_truckLegs.contains(leg) && progress < 1) {
        final at = _legGround(leg, progress);
        if (!_insideModel(leg, at)) items.add((_p.depth(at), 3, leg));
      }
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, kind, i) in items) {
      switch (kind) {
        case 0:
          _model(i);
        case 1:
          _prop(i);
        case 2:
          _legSegment(i ~/ 100, i % 100);
        default:
          _truck(i);
      }
    }
    if (showLabels) {
      _labels([
        for (var i = 0; i < 6; i++)
          (_s('stop_${i + 1}'), _p.p(_stops[i] + const _V(0, 3, 0)), 0.0),
      ]);
    }
  }

  /// The map board (HTML `PlaneGeometry(24, 24)` with its canvas texture):
  /// land gradient, fields, river, roads and the city ground.
  void _board() {
    const e = 12.0;
    final a = _p.p(const _V(-e, 0, -e));
    final b = _p.p(const _V(e, 0, -e));
    final c = _p.p(const _V(e, 0, e));
    final d = _p.p(const _V(-e, 0, e));
    _path
      ..reset()
      ..addPolygon([a, b, c, d], true);
    // HTML `ctx.shadowBlur = 15` under the land.
    _shadow.color = _Colors.black.withValues(alpha: 0.45);
    _c
      ..save()
      ..translate(6, 8)
      ..drawPath(_path, _shadow)
      ..restore();
    _fill.shader = ui.Gradient.linear(
      a,
      c,
      const [_Colors.lime400, _Colors.green400, _Colors.emerald500],
      const [0, 0.5, 1],
    );
    _c.drawPath(_path, _fill);
    _fill.shader = null;
    _stroke
      ..strokeWidth = math.max(1.5, 0.12 * _p.scaleAt(_V.zero))
      ..color = _Colors.lime300;
    _c.drawPath(_path, _stroke);
    // Fields: yellow wheat with furrows.
    for (final (x0, z0, x1, z1) in _fields) {
      _flatQuad(x0, z0, x1, z1, _Colors.field.withValues(alpha: 0.55));
      _stroke
        ..strokeWidth = 1
        ..color = labShade(_Colors.field, -0.3).withValues(alpha: 0.45);
      for (var x = x0 + 0.4; x < x1; x += 0.5) {
        _c.drawLine(_p.p(_V(x, 0.01, z0)), _p.p(_V(x, 0.01, z1)), _stroke);
      }
    }
    // City ground.
    final (cx0, cz0, cx1, cz1) = _city;
    _flatQuad(cx0, cz0, cx1, cz1, _Colors.cityGround.withValues(alpha: 0.85));
    // River.
    _polyline(
      [for (final (x, z) in _river) _V(x, 0.01, z)],
      0.55,
      _Colors.river,
    );
    // Local roads (dirt) and the street to the house.
    for (final (from, to) in const [(0, 1), (1, 2), (2, 3)]) {
      _polyline(
        [
          _stops[from] + const _V(0, 0.015, 0),
          _stops[to] + const _V(0, 0.015, 0),
        ],
        0.28,
        _Colors.dirtRoad,
      );
    }
    _polyline(
      [_stops[4] + const _V(0, 0.015, 0), _stops[5] + const _V(0, 0.015, 0)],
      0.3,
      _Colors.slate500,
    );
    // The highway of the long-haul leg (mill → supermarket).
    final highway = [
      for (var i = 0; i <= 16; i++)
        _legGround(4, i / 16) + const _V(0, 0.02, 0),
    ];
    _polyline(highway, 0.5, _Colors.slate600);
    _path.reset();
    for (var i = 0; i < highway.length; i++) {
      final o = _p.p(highway[i] + const _V(0, 0.01, 0));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.white.withValues(alpha: 0.7);
    labDashedPath(_c, _path, _stroke, dash: 6, gap: 6);
  }

  /// A flat rectangle on the map.
  void _flatQuad(double x0, double z0, double x1, double z1, Color color) {
    _path
      ..reset()
      ..addPolygon([
        _p.p(_V(x0, 0.01, z0)),
        _p.p(_V(x1, 0.01, z0)),
        _p.p(_V(x1, 0.01, z1)),
        _p.p(_V(x0, 0.01, z1)),
      ], true);
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  /// A smooth line on the map [width] world units wide.
  void _polyline(List<_V> pts, double width, Color color) {
    if (pts.length < 2) return;
    final mid = pts[pts.length ~/ 2];
    _path.reset();
    final first = _p.p(pts.first);
    _path.moveTo(first.dx, first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final a = _p.p(pts[i]);
      final b = _p.p(pts[i + 1]);
      _path.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    }
    final last = _p.p(pts.last);
    _path.lineTo(last.dx, last.dy);
    _stroke
      ..strokeWidth = math.max(1.5, width * _p.scaleAt(mid))
      ..color = color;
    _c.drawPath(_path, _stroke);
  }

  /// Route segments per leg.
  static const int _legSegments = 24;

  /// Point [t] of the route into stop [leg] (HTML QuadraticBezierCurve3
  /// from the previous stop, control point lifted 2).
  static _V _legPoint(int leg, double t) {
    final a = _stops[leg - 1];
    final b = _stops[leg];
    final c = (a + b) * 0.5 + _legBend[leg] + const _V(0, _pathLift, 0);
    final u = 1 - t;
    return a * (u * u) + c * (2 * u * t) + b * (t * t);
  }

  /// The route's track on the ground (the truck drives on it).
  static _V _legGround(int leg, double t) {
    final p = _legPoint(leg, t);
    return _V(p.x, 0, p.z);
  }

  /// Is [w] inside the model at either end of [leg] (the route is hidden
  /// there, as the HTML's depth test hid it)?
  bool _insideModel(int leg, _V w) {
    for (final i in [leg - 1, leg]) {
      final k = scene.modelScale(i);
      if (k <= 0) continue;
      final (r, h) = _modelSize[i];
      final dx = w.x - _stops[i].x, dz = w.z - _stops[i].z;
      if (dx * dx + dz * dz < r * r * k * k && w.y < h * k) return true;
    }
    return false;
  }

  /// One drawn piece of a route (HTML TubeGeometry radius 0.15, amber,
  /// opacity 0.8).
  void _legSegment(int leg, int j) {
    final progress = scene.legProgress(leg);
    final t0 = j / _legSegments;
    final t1 = math.min((j + 1) / _legSegments, progress);
    final a = _legPoint(leg, t0), b = _legPoint(leg, t1);
    _stroke
      ..strokeWidth = math.max(1.5, 0.3 * _p.scaleAt((a + b) * 0.5))
      ..color = _Colors.path;
    _c.drawLine(_p.p(a), _p.p(b), _stroke);
  }

  /// The truck on legs 3–5 (larger on the long haul to the city).
  void _truck(int leg) {
    final t = scene.legProgress(leg);
    final at = _legGround(leg, t);
    final ahead = _legGround(leg, math.min(1, t + 0.02));
    final behind = _legGround(leg, math.max(0, t - 0.02));
    final fwd = (ahead - behind).unit;
    final right = fwd.cross(_up).unit;
    final k = leg == 4 ? 1.35 : 1.0;
    _obox(
      at + _up * (0.18 * k),
      right,
      _up,
      fwd,
      0.36 * k,
      0.1 * k,
      0.8 * k,
      _Colors.slate700,
    );
    _obox(
      at + fwd * (0.5 * k) + _up * (0.5 * k),
      right,
      _up,
      fwd,
      0.32 * k,
      0.3 * k,
      0.26 * k,
      _Colors.blue500,
    );
    _obox(
      at - fwd * (0.25 * k) + _up * (0.6 * k),
      right,
      _up,
      fwd,
      0.36 * k,
      0.36 * k,
      0.5 * k,
      leg == 4 ? _Colors.slate100 : _Colors.yellow400,
    );
  }

  /// A map decoration (building, tree or mountain).
  void _prop(int i) {
    final (kind, x, z, w, h) = _props[i];
    final base = _V(x, 0, z);
    switch (kind) {
      case _Prop.building:
        _obox(
          base + _V(0, h / 2, 0),
          const _V(1, 0, 0),
          _up,
          const _V(0, 0, 1),
          w / 2,
          h / 2,
          w / 2,
          _buildingColors[i % _buildingColors.length],
        );
      case _Prop.tree:
        _cylY(base, 0.12, h * 0.35, _Colors.brown);
        _cone(base + _V(0, h * 0.3, 0), w / 2, h * 0.7, _Colors.tree);
      case _Prop.mountain:
        _pyramid(base, w / 2, h, _Colors.stone);
        _pyramid(
          base + _V(0, h * 0.62, 0),
          w / 2 * 0.38,
          h * 0.38,
          _Colors.white,
        );
    }
  }

  // ------------------------------------------------------------- models

  /// HTML `createSimpleModel(type)` at stop [i], scaled by its pop-up.
  void _model(int i) {
    _o = _stops[i];
    _k = scene.modelScale(i);
    switch (i) {
      case 0:
        _farm();
      case 1:
        _thresher();
      case 2:
        _silo();
      case 3:
        _mill();
      case 4:
        _shop();
      default:
        _house();
    }
  }

  /// Model point (local x, y, z) in the world.
  _V _w(double x, double y, double z) =>
      _V(_o.x + x * _k, _o.y + y * _k, _o.z + z * _k);

  /// Model box: centre, size (Three.js BoxGeometry) and one rotation.
  void _mBox(
    double x,
    double y,
    double z,
    double w,
    double h,
    double d,
    Color color, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
  }) {
    final (ax, ay, az) = _axes(rx: rx, ry: ry, rz: rz);
    _obox(_w(x, y, z), ax, ay, az, w / 2 * _k, h / 2 * _k, d / 2 * _k, color);
  }

  /// Model cylinder standing up (Three.js CylinderGeometry, centred).
  void _mCyl(double x, double y, double z, double r, double h, Color color) =>
      _cylY(_w(x, y - h / 2, z), r * _k, h * _k, color);

  /// Model wheel: a cylinder along z (`rotation.x = π/2`).
  void _mWheel(double x, double y, double z, double r, double len) {
    final half = len / 2 * _k;
    final c = _w(x, y, z);
    _pts.clear();
    for (final (cx, cy) in _unitCircle) {
      _pts
        ..add(_p.p(c + _V(cx * r * _k, cy * r * _k, half)))
        ..add(_p.p(c + _V(cx * r * _k, cy * r * _k, -half)));
    }
    _hullPath(_pts);
    _fill
      ..shader = null
      ..color = _Colors.gray900;
    _c.drawPath(_path, _fill);
    if (_p.eye.z > c.z + half) {
      _discZ(c + _V(0, 0, half), r * _k);
      _fill.color = _lit(_Colors.gray800, const _V(0, 0, 1));
      _c.drawPath(_path, _fill);
      _discZ(c + _V(0, 0, half + 0.01), r * 0.4 * _k);
      _fill.color = _Colors.slate400;
      _c.drawPath(_path, _fill);
    }
  }

  void _farm() {
    _mBox(0, 0.1, 0, 4, 0.2, 4, _Colors.lime500);
    _mBox(1, 0.8, -1, 1.5, 1.2, 1.5, _Colors.red500);
    _pyramid(
      _w(1, 1.4, -1),
      1.2 * math.sqrt1_2 * _k,
      0.8 * _k,
      _Colors.slate600,
    );
    _mQuadZ(1, 0.55, -0.24, 0.5, 0.7, _Colors.white);
    _mBox(-0.5, 0.4, 0.5, 2.5, 0.4, 2.5, _Colors.yellow400);
    // Farmer: legs, shirt, head, hat.
    _mBox(-1, 0.5, 1.5, 0.3, 0.4, 0.2, _Colors.brown);
    _mBox(-1, 0.95, 1.5, 0.4, 0.5, 0.3, _Colors.blue500);
    _mBox(-1, 1.3, 1.5, 0.25, 0.25, 0.25, _Colors.tan);
    _mCyl(-1, 1.45, 1.5, 0.3, 0.05, _Colors.amber600);
  }

  void _thresher() {
    _cone(_w(2.5, 0, 0), 1 * _k, 0.8 * _k, _Colors.yellow400);
    _mBox(0, 0.8, 0, 2.5, 1.2, 1.5, _Colors.orange500);
    _mBox(1.5, 0.6, 0, 1.2, 0.8, 1.5, _Colors.orange500, rz: -math.pi / 6);
    _mBox(-0.5, 1.8, 0, 0.4, 1.5, 0.4, _Colors.orange500, rz: math.pi / 8);
    _mWheel(-0.8, 0.4, 0, 0.4, 1.6);
    _mWheel(1.0, 0.3, 0, 0.3, 1.6);
  }

  void _silo() {
    _mCyl(0, 1.5, -0.5, 1.2, 3, _Colors.slate400);
    _dome(_w(0, 3, -0.5), 1.2 * _k, _Colors.slate500);
    _mCyl(1.25, 1.25, -0.5, 0.1, 2.5, _Colors.gray300);
    // Sacks (HTML: a random turn each; fixed here).
    const turns = [0.12, 0.37, 0.25, 0.05];
    for (var i = 0; i < 4; i++) {
      _mBox(
        -1.8 + (i % 2) * 0.4,
        0.4 + (i ~/ 2) * 0.3,
        0.5 + (i % 2) * 0.2,
        0.6,
        0.8,
        0.4,
        _Colors.sack,
        ry: turns[i],
      );
    }
    // Parked truck.
    _mBox(2.5, 0.3, 1.5, 1.2, 0.2, 0.8, _Colors.slate600);
    _mBox(2.5, 0.7, 1.5, 1.0, 0.6, 0.6, _Colors.yellow400);
    _mBox(1.5, 0.6, 1.5, 0.8, 0.8, 0.8, _Colors.blue500);
    _mWheel(1.5, 0.2, 1.5, 0.2, 0.9);
    _mWheel(2.5, 0.2, 1.5, 0.2, 0.9);
  }

  void _mill() {
    _mBox(0, 1, -0.5, 2.5, 2, 2.5, _Colors.slate300);
    _mBox(0, 2.1, -0.5, 2.7, 0.2, 2.7, _Colors.slate500);
    _mCyl(-0.6, 3, -1, 0.3, 2, _Colors.slate400);
    _mCyl(0.6, 3, -1, 0.3, 2, _Colors.slate400);
    _mCyl(-0.6, 4, -1, 0.35, 0.2, _Colors.slate600);
    _mCyl(0.6, 4, -1, 0.35, 0.2, _Colors.slate600);
    _mBox(-1.8, 0.5, 1, 0.8, 1, 0.5, _Colors.flourSack);
  }

  void _shop() {
    _mQuadY(0, 0.05, 0, 6, 2, _Colors.slate700);
    _mQuadY(0, 0.06, 0, 4, 0.1, _Colors.white);
    _mBox(0, 1, -1.5, 2.5, 2, 2, _Colors.white);
    _mQuadZ(0, 0.8, -0.49, 2.2, 1.2, _Colors.sky400);
    for (var i = 0; i < 5; i++) {
      _mBox(
        -1 + i * 0.5,
        1.8,
        -0.5,
        0.5,
        0.1,
        1,
        i.isEven ? _Colors.red500 : _Colors.white,
        rx: math.pi / 6,
      );
    }
    // Delivery truck on the road.
    _mBox(0.25, 0.25, 0, 2.5, 0.3, 1, _Colors.slate600);
    _mBox(-0.2, 0.9, 0, 1, 1, 0.8, _Colors.slate100);
    _mBox(0.9, 0.9, 0, 1, 1, 0.8, _Colors.slate100);
    _mBox(-1.5, 0.65, 0, 1, 1.2, 1, _Colors.blue500);
    _mWheel(-1.5, 0.25, 0, 0.25, 1.1);
    _mWheel(0.5, 0.25, 0, 0.25, 1.1);
  }

  void _house() {
    _mBox(-0.5, 0.9, -1, 2.5, 1.8, 2.5, _Colors.houseWall);
    _pyramid(
      _w(-0.5, 1.8, -1),
      2 * math.sqrt1_2 * _k,
      1.2 * _k,
      _Colors.blue500,
    );
    _mQuadZ(-0.5, 0.6, 0.26, 0.6, 1.2, _Colors.brown);
    // Person at the table, plate and chapati.
    _mBox(1.5, 0.7, -0.2, 0.5, 0.7, 0.4, _Colors.sky500);
    _mBox(1.5, 1.2, -0.2, 0.3, 0.3, 0.3, _Colors.brown);
    _mBox(1.5, 0.4, 0.5, 1.2, 0.8, 0.8, _Colors.brown);
    _mCyl(1.5, 0.82, 0.5, 0.4, 0.05, _Colors.white);
    _mCyl(1.5, 0.85, 0.5, 0.3, 0.04, _Colors.amber600);
  }

  /// Model plane facing +z (door, shop window).
  void _mQuadZ(double x, double y, double z, double w, double h, Color color) {
    final c = _w(x, y, z);
    if (_p.eye.z <= c.z) return;
    final hw = w / 2 * _k, hh = h / 2 * _k;
    _path
      ..reset()
      ..addPolygon([
        _p.p(c + _V(-hw, -hh, 0)),
        _p.p(c + _V(hw, -hh, 0)),
        _p.p(c + _V(hw, hh, 0)),
        _p.p(c + _V(-hw, hh, 0)),
      ], true);
    _fill
      ..shader = null
      ..color = _lit(color, const _V(0, 0, 1));
    _c.drawPath(_path, _fill);
  }

  /// Model plane lying flat (road, road line).
  void _mQuadY(double x, double y, double z, double w, double d, Color color) {
    final c = _w(x, y, z);
    final hw = w / 2 * _k, hd = d / 2 * _k;
    _path
      ..reset()
      ..addPolygon([
        _p.p(c + _V(-hw, 0, -hd)),
        _p.p(c + _V(hw, 0, -hd)),
        _p.p(c + _V(hw, 0, hd)),
        _p.p(c + _V(-hw, 0, hd)),
      ], true);
    _fill
      ..shader = null
      ..color = _lit(color, _up);
    _c.drawPath(_path, _fill);
  }

  // ------------------------------------------------------------ scenario 2

  void _paintScenario2() {
    final s = scene;
    final eye = s.eye;
    final c0 = _globeR / eye.length;
    final eh = eye.unit;
    // Pins on the far side are drawn first: the globe hides their stems
    // and only a head peeking over the edge shows.
    final pins = [..._Pin.values]
      ..sort(
        (a, b) => _p
            .depth(s.pinDir(b) * _globeR)
            .compareTo(_p.depth(s.pinDir(a) * _globeR)),
      );
    for (final pin in pins) {
      if (s.pinDir(pin).dot(eh) <= c0) _pin(pin);
    }
    _globe();
    _route();
    for (final pin in pins) {
      if (s.pinDir(pin).dot(eh) > c0) _pin(pin);
    }
    _selectionRing();
    _vehicle();
    if (showLabels) {
      _labels([
        for (final pin in _Pin.values)
          if (_inView(eye, s.pinDir(pin) * (_globeR + _pinHeight)))
            (
              _s(pin == _Pin.local ? 'pin_local' : 'pin_imported'),
              _p.p(s.pinDir(pin) * (_globeR + _pinHeight)),
              (_pinHeadR + 0.2) *
                  _p.scaleAt(s.pinDir(pin) * (_globeR + _pinHeight)),
            ),
      ]);
    }
  }

  /// The globe (HTML SphereGeometry(8) with an Earth map): ocean, the
  /// continents, light and shade, a thin atmosphere.
  void _globe() {
    final eye = scene.eye;
    final dist = eye.length;
    final eh = eye.unit;
    final c0 = _globeR / dist;
    final s0 = math.sqrt(math.max(0, 1 - c0 * c0));
    var b1 = eh.cross(_up);
    if (b1.length < 1e-4) b1 = eh.cross(const _V(1, 0, 0));
    b1 = b1.unit;
    final b2 = b1.cross(eh);
    // Silhouette: the horizon circle seen from the camera.
    final rim = _rim..reset();
    for (var i = 0; i < 72; i++) {
      final a = 2 * math.pi * i / 72;
      final n = eh * c0 + (b1 * math.cos(a) + b2 * math.sin(a)) * s0;
      final o = _p.p(n * _globeR);
      if (i == 0) {
        rim.moveTo(o.dx, o.dy);
      } else {
        rim.lineTo(o.dx, o.dy);
      }
    }
    rim.close();
    final bounds = rim.getBounds();
    final center = bounds.center;
    final radius = bounds.longestSide / 2;
    // Lit side: between the camera and the HTML sun.
    final lit = _p.p((eh + _lightDir).unit * _globeR);
    _fill.shader = ui.Gradient.radial(
      lit,
      radius * 1.6,
      [
        labShade(_Colors.ocean, 0.25),
        _Colors.ocean,
        labShade(_Colors.ocean, -0.5),
      ],
      const [0, 0.45, 1],
    );
    _c.drawPath(rim, _fill);
    _fill.shader = null;
    _c
      ..save()
      ..clipPath(rim);
    final yaw = scene.yaw;
    final cy = math.cos(yaw), sy = math.sin(yaw);
    for (final land in _landMasses) {
      _path.reset();
      for (var i = 0; i < land.length; i += 4) {
        final cp = land[i],
            sp = land[i + 1],
            sl = land[i + 2],
            cl = land[i + 3];
        // sin / cos of (longitude + yaw).
        final st = sl * cy + cl * sy;
        final ct = cl * cy - sl * sy;
        var n = _V(cp * st, sp, cp * ct);
        final along = n.dot(eh);
        if (along < c0) {
          // Behind the horizon: pushed onto the rim.
          final side = (n - eh * along).unit;
          n = eh * c0 + side * s0;
        }
        final o = _p.p(n * _globeR);
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _path.close();
      _fill.color = _Colors.land;
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 1.2
        ..color = _Colors.coast;
      _c.drawPath(_path, _stroke);
    }
    // Shade over land and sea alike.
    _fill.shader = ui.Gradient.radial(
      lit,
      radius * 1.7,
      [
        _Colors.white.withValues(alpha: 0.18),
        _Colors.white.withValues(alpha: 0),
        _Colors.black.withValues(alpha: 0.45),
      ],
      const [0, 0.4, 1],
    );
    _c.drawRect(Rect.fromCircle(center: center, radius: radius * 1.2), _fill);
    _fill.shader = null;
    _c.restore();
    _stroke
      ..strokeWidth = 2.5
      ..color = _Colors.atmosphere;
    _c.drawPath(rim, _stroke);
  }

  /// HTML `createMapPin(color)`: a cone from the ground to a round head with
  /// a white dot; emissive (brighter) once chosen.
  void _pin(_Pin pin) {
    final s = scene;
    final n = s.pinDir(pin);
    final base = n * _globeR;
    final headC = n * (_globeR + _pinHeight);
    final chosen = s.selected == pin;
    final color = labShade(
      pin == _Pin.local ? _Colors.amber500 : _Colors.red500,
      chosen ? 0.27 : 0,
    );
    var t1 = n.cross(_up);
    if (t1.length < 1e-4) t1 = n.cross(const _V(1, 0, 0));
    t1 = t1.unit;
    final t2 = n.cross(t1);
    _pts
      ..clear()
      ..add(_p.p(base));
    for (final (cx, cy) in _unitCircle) {
      _pts.add(_p.p(headC + (t1 * cx + t2 * cy) * _pinHeadR));
    }
    _hullPath(_pts);
    _fill
      ..shader = null
      ..color = labShade(color, -0.2);
    _c.drawPath(_path, _fill);
    _sphere(headC, _pinHeadR, color);
    final dot = headC + (s.eye - headC).unit * (_pinHeadR * 0.9);
    _fill
      ..shader = null
      ..color = _Colors.white;
    _c.drawCircle(_p.p(dot), 0.25 * _p.scaleAt(dot), _fill);
  }

  /// "A visual marker highlights your selection": a pulsing ring on the
  /// ground round the chosen pin.
  void _selectionRing() {
    final s = scene;
    final pin = s.selected;
    if (pin == null || s.mode == _S2Mode.moving) return;
    final n = s.pinDir(pin);
    if (n.dot(s.eye.unit) <= _globeR / s.eye.length) return;
    final base = n * (_globeR + 0.02);
    var t1 = n.cross(_up);
    if (t1.length < 1e-4) t1 = n.cross(const _V(1, 0, 0));
    t1 = t1.unit;
    final t2 = n.cross(t1);
    final phase = ((s.time - s.selectedAt) % 1.2) / 1.2;
    final color = pin == _Pin.local ? _Colors.amber500 : _Colors.red500;
    for (final (r, alpha) in [(0.9, 0.9), (0.9 + 0.9 * phase, 1 - phase)]) {
      _path.reset();
      for (var i = 0; i <= _roundSegments; i++) {
        final (cx, cy) = _unitCircle[i % _roundSegments];
        final o = _p.p(base + (t1 * cx + t2 * cy) * r);
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      _c.drawPath(_path, _stroke);
    }
  }

  /// HTML TubeGeometry route (radius 0.1, green for local, amber for
  /// imported, opacity 0.8), drawn as far as the vehicle has gone.
  void _route() {
    final s = scene;
    final pin = s.route;
    if (pin == null || s.routePts.length < 2) return;
    final n = s.routePts.length - 1;
    final upTo = (s.routeProgress * n).floor();
    _stroke.color = pin == _Pin.local
        ? _Colors.routeLocal
        : _Colors.routeImport;
    for (var i = 0; i < upTo && i < n; i++) {
      final a = s.routePts[i], b = s.routePts[i + 1];
      final mid = (a + b) * 0.5;
      if (!_inView(s.eye, mid)) continue;
      _stroke.strokeWidth = math.max(1.5, 0.2 * _p.scaleAt(mid));
      _c.drawLine(_p.p(a), _p.p(b), _stroke);
    }
  }

  /// HTML `s2Vehicle` (a 0.6 × 0.4 × 0.8 box): drawn as a cargo ship on the
  /// sea part of the imported route and as a truck on land.
  void _vehicle() {
    final s = scene;
    final pin = s.route;
    if (pin == null || s.mode != _S2Mode.moving || s.routePts.length < 2) {
      return;
    }
    final i = s.vehicleIndex;
    final at = s.routePts[i];
    final next = s.routePts[i + 1];
    final up = at.unit;
    var fwd = next - at;
    fwd = (fwd - up * fwd.dot(up)).unit;
    final right = fwd.cross(up).unit;
    if (s.onShip) {
      _obox(at + up * 0.12, right, up, fwd, 0.3, 0.12, 0.55, _Colors.slate800);
      _obox(
        at + up * 0.36 - fwd * 0.08,
        right,
        up,
        fwd,
        0.22,
        0.12,
        0.32,
        _Colors.orange500,
      );
      _obox(
        at + up * 0.42 - fwd * 0.45,
        right,
        up,
        fwd,
        0.16,
        0.18,
        0.08,
        _Colors.white,
      );
    } else {
      _obox(
        at + up * 0.24 - fwd * 0.1,
        right,
        up,
        fwd,
        0.24,
        0.22,
        0.3,
        _Colors.slate100,
      );
      _obox(
        at + up * 0.2 + fwd * 0.32,
        right,
        up,
        fwd,
        0.22,
        0.18,
        0.13,
        _Colors.blue500,
      );
    }
  }

  // ------------------------------------------------------------ labels

  /// HTML `.scene-label` chips (dark glass, white bold text), centred on
  /// their point, lifted by the given gap (design px). A chip that would
  /// overlap one already placed moves up (phones show the scene small and
  /// the labels large).
  void _labels(List<(String, Offset, double)> labels) {
    final k = math.max(
      scene.framing.zoom,
      _labelMinDp / (_labelPx * math.max(stageFit, 0.01)),
    );
    const padX = 8.0, padY = 4.0;
    final sorted = [...labels]..sort((a, b) => b.$2.dy.compareTo(a.$2.dy));
    final placed = <Rect>[];
    for (final (label, at, lift) in sorted) {
      final tp = text.get(
        label,
        size: _labelPx,
        color: palette.labelText,
        weight: FontWeight.w700,
      );
      final w = (tp.width + 2 * padX) * k;
      final h = (tp.height + 2 * padY) * k;
      var rect = Rect.fromCenter(
        center: at - Offset(0, lift > 0 ? lift + h / 2 + 2 : 0),
        width: w,
        height: h,
      );
      for (var round = 0; round < 6; round++) {
        Rect? hit;
        for (final r in placed) {
          if (r.inflate(2).overlaps(rect)) {
            hit = r;
            break;
          }
        }
        if (hit == null) break;
        rect = rect.shift(Offset(0, hit.top - 3 - rect.bottom));
      }
      placed.add(rect);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(6 * k));
      _shadow.color = _Colors.black.withValues(alpha: 0.3);
      _c.drawRRect(rr.shift(const Offset(0, 2)), _shadow);
      _fill
        ..shader = null
        ..color = palette.labelBg;
      _c.drawRRect(rr, _fill);
      _stroke
        ..strokeWidth = 1
        ..color = _Colors.labelBorder;
      _c.drawRRect(rr, _stroke);
      _c
        ..save()
        ..translate(rect.left + padX * k, rect.top + padY * k)
        ..scale(k);
      tp.paint(_c, Offset.zero);
      _c.restore();
    }
  }

  // ------------------------------------------------------------ confetti

  void _paintConfetti() {
    final s = scene;
    final fade = 1 - ((s.time - s.confettiStart) / _confettiSeconds);
    if (fade <= 0) return;
    for (final c in s.confetti) {
      _fill
        ..shader = null
        ..color = c.color.withValues(alpha: fade.clamp(0.0, 1.0));
      _c
        ..save()
        ..translate(c.x, c.y)
        ..rotate(c.wobble)
        ..scale(1, 0.5 + 0.5 * math.cos(c.wobble * 1.3).abs());
      _c.drawRect(const Rect.fromLTWH(-5, -3.5, 10, 7), _fill);
      _c.restore();
    }
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.6 + directional 0.8).
  Color _lit(Color c, _V n) {
    final i =
        (_ambient + _sunLight * math.max(0.0, n.dot(_lightDir))) * _exposure;
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Box centred at [c] with axes [ax], [ay], [az] and half sizes.
  void _obox(
    _V c,
    _V ax,
    _V ay,
    _V az,
    double hx,
    double hy,
    double hz,
    Color color,
  ) {
    _V corner(_V s) => c + ax * (s.x * hx) + ay * (s.y * hy) + az * (s.z * hz);
    for (final (n, a, b, cc, d) in _boxFaces) {
      final normal = ax * n.x + ay * n.y + az * n.z;
      if (normal.dot(_p.eye - corner(n)) <= 0) continue;
      _path
        ..reset()
        ..addPolygon([
          _p.p(corner(a)),
          _p.p(corner(b)),
          _p.p(corner(cc)),
          _p.p(corner(d)),
        ], true);
      final lit = _lit(color, normal);
      _fill
        ..shader = null
        ..color = lit;
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(lit, -0.5).withValues(alpha: 0.3);
      _c.drawPath(_path, _stroke);
    }
  }

  /// Upright cylinder standing on [base] (radius [r], height [h]).
  void _cylY(_V base, double r, double h, Color color) {
    final top = base + _V(0, h, 0);
    _pts.clear();
    for (final (cx, cz) in _unitCircle) {
      _pts
        ..add(_p.p(base + _V(cx * r, 0, cz * r)))
        ..add(_p.p(top + _V(cx * r, 0, cz * r)));
    }
    _hullPath(_pts);
    final side = _lit(color, const _V(0, 0, 1));
    final bounds = _path.getBounds();
    _fill.shader = ui.Gradient.linear(
      bounds.centerLeft,
      bounds.centerRight,
      [labShade(side, -0.3), labShade(side, 0.12), side, labShade(side, -0.4)],
      const [0, 0.3, 0.6, 1],
    );
    _c.drawPath(_path, _fill);
    _fill.shader = null;
    if (_p.eye.y > top.y) {
      _discFlat(top, r);
      _fill.color = _lit(color, _up);
      _c.drawPath(_path, _fill);
    }
  }

  /// Round cone standing on [base] (HTML grain heap, tree crown).
  void _cone(_V base, double r, double h, Color color) {
    _pts
      ..clear()
      ..add(_p.p(base + _V(0, h, 0)));
    for (final (cx, cz) in _unitCircle) {
      _pts.add(_p.p(base + _V(cx * r, 0, cz * r)));
    }
    _hullPath(_pts);
    final bounds = _path.getBounds();
    final side = _lit(color, const _V(0, 0.6, 0.8));
    _fill.shader = ui.Gradient.linear(
      bounds.centerLeft,
      bounds.centerRight,
      [labShade(side, -0.25), labShade(side, 0.15), labShade(side, -0.35)],
      const [0, 0.4, 1],
    );
    _c.drawPath(_path, _fill);
    _fill.shader = null;
  }

  /// Four-sided cone turned 45° (HTML roofs, mountains): base half-side
  /// [half] on [base], apex [h] above.
  void _pyramid(_V base, double half, double h, Color color) {
    final apex = base + _V(0, h, 0);
    final corners = [
      base + _V(-half, 0, half),
      base + _V(half, 0, half),
      base + _V(half, 0, -half),
      base + _V(-half, 0, -half),
    ];
    for (var i = 0; i < 4; i++) {
      final a = corners[i], b = corners[(i + 1) % 4];
      final normal = (b - a).cross(apex - a).unit;
      if (normal.dot(_p.eye - a) <= 0) continue;
      _path
        ..reset()
        ..addPolygon([_p.p(a), _p.p(b), _p.p(apex)], true);
      _fill
        ..shader = null
        ..color = _lit(color, normal);
      _c.drawPath(_path, _fill);
    }
  }

  /// Hemisphere above [c] (HTML silo roof, SphereGeometry 0–π/2).
  void _dome(_V c, double r, Color color) {
    _pts.clear();
    for (final lat in const [0.0, 0.5, 1.0, 1.35]) {
      final rr = r * math.cos(lat), y = r * math.sin(lat);
      for (final (cx, cz) in _unitCircle) {
        _pts.add(_p.p(c + _V(cx * rr, y, cz * rr)));
      }
    }
    _pts.add(_p.p(c + _V(0, r, 0)));
    _hullPath(_pts);
    final top = _p.p(c + _V(-r * 0.3, r * 0.8, r * 0.3));
    _fill.shader = ui.Gradient.radial(
      top,
      r * _p.scaleAt(c) * 1.6,
      [labShade(color, 0.35), color, labShade(color, -0.35)],
      const [0, 0.5, 1],
    );
    _c.drawPath(_path, _fill);
    _fill.shader = null;
  }

  /// Lit sphere (MeshStandardMaterial look).
  void _sphere(_V c, double r, Color color) {
    final o = _p.p(c);
    final radius = r * _p.scaleAt(c);
    _fill.shader = ui.Gradient.radial(
      o + Offset(-radius * 0.35, -radius * 0.4),
      radius * 1.3,
      [labShade(color, 0.45), color, labShade(color, -0.35)],
      const [0, 0.45, 1],
    );
    _c.drawCircle(o, radius, _fill);
    _fill.shader = null;
  }

  /// Circle of radius [r] lying flat (y constant) into [_path].
  void _discFlat(_V c, double r) {
    _path.reset();
    for (var i = 0; i < _roundSegments; i++) {
      final (cx, cz) = _unitCircle[i];
      final o = _p.p(c + _V(cx * r, 0, cz * r));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
  }

  /// Circle of radius [r] facing +z into [_path].
  void _discZ(_V c, double r) {
    _path.reset();
    for (var i = 0; i < _roundSegments; i++) {
      final (cx, cy) = _unitCircle[i];
      final o = _p.p(c + _V(cx * r, cy * r, 0));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
  }

  /// Convex hull of [pts] into [_path].
  void _hullPath(List<Offset> pts) {
    _path.reset();
    final hull = _hull(pts);
    if (hull.length >= 3) _path.addPolygon(hull, true);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.stageFit != stageFit;
}

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

// ------------------------------------------------------------ world map

/// Simplified coastlines (longitude, latitude in degrees) for the globe, in
/// place of the HTML's Earth photo texture: the Americas, Eurasia with
/// India, Africa, Australia, Greenland and a few large islands.
const List<List<(double, double)>> _coastlines = [
  // North America.
  [
    (-165, 68),
    (-156, 71),
    (-140, 70),
    (-128, 70),
    (-115, 68),
    (-100, 68),
    (-95, 72),
    (-85, 70),
    (-80, 63),
    (-90, 58),
    (-85, 55),
    (-79, 52),
    (-77, 60),
    (-65, 60),
    (-60, 55),
    (-56, 52),
    (-60, 47),
    (-66, 44),
    (-70, 42),
    (-74, 40),
    (-76, 35),
    (-81, 31),
    (-80, 26),
    (-82, 27),
    (-85, 30),
    (-90, 30),
    (-94, 29.5),
    (-97, 26),
    (-97.5, 22),
    (-96, 19),
    (-91, 18.5),
    (-90, 21),
    (-87, 21),
    (-88, 16),
    (-84, 15),
    (-83, 11),
    (-79.5, 9),
    (-77.5, 8),
    (-80, 7.5),
    (-83, 8.5),
    (-86, 11),
    (-88, 13),
    (-92, 14.5),
    (-96, 16),
    (-105, 20),
    (-110, 23.5),
    (-112, 26),
    (-115, 30),
    (-117, 32.5),
    (-120.5, 34.5),
    (-124, 40),
    (-124, 46),
    (-125, 49),
    (-130, 54),
    (-135, 57.5),
    (-140, 60),
    (-147, 61),
    (-152, 59),
    (-158, 57),
    (-165, 55),
    (-162, 58),
    (-165, 61),
    (-167, 65),
  ],
  // South America.
  [
    (-80, 9),
    (-75, 11),
    (-72, 12),
    (-63, 11),
    (-60, 8.5),
    (-52, 5),
    (-50, 0),
    (-44, -2.5),
    (-35, -5),
    (-35, -9),
    (-39, -15),
    (-40, -22),
    (-48, -26),
    (-53, -34),
    (-58, -38.5),
    (-62.5, -39),
    (-65, -42),
    (-67, -46),
    (-66, -48),
    (-69, -51),
    (-68.5, -55),
    (-71.5, -53.5),
    (-75, -48),
    (-73.5, -42),
    (-71.5, -30),
    (-70.5, -18),
    (-76, -14),
    (-81, -6),
    (-80, -1),
    (-78, 2),
    (-77.5, 7),
  ],
  // Africa.
  [
    (-17, 21),
    (-16, 28),
    (-9.5, 32),
    (-6, 35.8),
    (10, 37),
    (11, 33),
    (19, 30.5),
    (25, 32),
    (32, 31.2),
    (32.5, 30),
    (35.5, 24),
    (37.2, 18.5),
    (39.5, 15.5),
    (43.2, 11.5),
    (51, 11.8),
    (51, 10.4),
    (48, 5),
    (46, 2),
    (42, -1),
    (40, -3),
    (39.5, -10),
    (40.5, -15),
    (35, -22),
    (32.5, -28.5),
    (26, -34),
    (20, -35),
    (18, -31),
    (14.5, -22),
    (12, -15),
    (13, -6),
    (9, 0),
    (9.5, 4),
    (5, 6),
    (-2, 5),
    (-8, 4.5),
    (-13, 8),
    (-17, 14.5),
  ],
  // Eurasia, with Arabia, India and South-East Asia.
  [
    (-9.5, 37),
    (-9, 43),
    (-1.5, 43.5),
    (-4.5, 48.5),
    (2, 51),
    (8, 54),
    (9, 57),
    (12, 56),
    (10.5, 59),
    (5, 58.5),
    (5, 62),
    (14, 67),
    (25, 71),
    (40, 68),
    (55, 69),
    (70, 73),
    (80, 73),
    (100, 77),
    (110, 74),
    (130, 72),
    (150, 71.5),
    (170, 70),
    (180, 66),
    (178, 62),
    (170, 60),
    (162, 56),
    (156, 51),
    (155, 58),
    (142, 59),
    (138, 54),
    (141, 48),
    (135, 43),
    (129, 41),
    (129, 35),
    (126.5, 37.5),
    (125, 39.5),
    (121, 40.5),
    (122, 37),
    (119, 34.5),
    (122, 31),
    (121.5, 28),
    (119, 25),
    (114, 22.3),
    (110, 21),
    (106, 20.5),
    (107, 16),
    (109, 12),
    (105, 8.5),
    (103, 10.5),
    (100.5, 13.5),
    (100, 9),
    (103.5, 1.5),
    (101, 3),
    (98.5, 8),
    (98, 15),
    (94.5, 16),
    (94, 20),
    (92, 22),
    (90, 22),
    (87, 21.5),
    (86, 20),
    (82.5, 17),
    (80.3, 15.5),
    (80, 13),
    (79.8, 10.3),
    (78, 8.1),
    (76.5, 9),
    (74.8, 13),
    (73, 17.5),
    (72.7, 21),
    (70, 22.5),
    (68.5, 23.5),
    (66.5, 25.5),
    (61.5, 25),
    (57, 25.7),
    (56.3, 27),
    (51.5, 27.9),
    (48.5, 30),
    (50, 26.5),
    (51.5, 24.5),
    (56, 26),
    (57.5, 23.5),
    (59.8, 22.5),
    (57, 18.5),
    (52, 16),
    (43.5, 12.7),
    (42.7, 15.5),
    (39, 21.5),
    (35, 28),
    (34.5, 29.5),
    (34.2, 31.3),
    (35, 33),
    (35.9, 35.5),
    (36, 36.8),
    (30, 36.3),
    (27, 37.5),
    (26.2, 40),
    (23, 37),
    (21, 40),
    (19.5, 42),
    (13.5, 45.5),
    (12.5, 44),
    (16, 40.5),
    (15.7, 38),
    (12, 41.5),
    (8.5, 44.2),
    (3, 43.3),
    (3.2, 41.8),
    (0, 39.5),
    (-0.5, 38),
    (-2, 36.7),
    (-5.6, 36),
    (-6.5, 37),
  ],
  // Australia.
  [
    (114, -22),
    (114, -34),
    (116, -35),
    (124, -34),
    (129, -31.5),
    (135, -34.5),
    (138, -35.5),
    (140.5, -38),
    (146, -39),
    (150, -37.5),
    (153, -32),
    (153.5, -28),
    (153, -25),
    (150, -22),
    (146, -19),
    (145.5, -15),
    (143.5, -14),
    (142.5, -10.7),
    (141.5, -13),
    (141.5, -17),
    (139.5, -17.5),
    (136, -15),
    (137, -12),
    (132.5, -11.5),
    (130, -13),
    (129, -15),
    (125.5, -14),
    (122, -18),
    (121, -19.5),
    (117, -20.5),
  ],
  // Greenland.
  [
    (-73, 78),
    (-60, 82),
    (-35, 83.5),
    (-20, 81.5),
    (-18, 76),
    (-21, 70),
    (-25, 68),
    (-35, 65.5),
    (-43, 60),
    (-48, 61),
    (-52, 64.5),
    (-54, 67.5),
    (-56, 72),
    (-66, 76),
  ],
  // Great Britain.
  [
    (-5.7, 50),
    (1.5, 51),
    (1.7, 52.7),
    (0, 53.5),
    (-2, 55.8),
    (-3, 58.6),
    (-5, 58.6),
    (-6, 56.5),
    (-4.8, 54.8),
    (-3, 53.5),
    (-4.5, 52),
    (-5.3, 51.6),
  ],
  // Japan.
  [
    (130, 31.5),
    (131.8, 33.5),
    (135, 34),
    (140, 35.5),
    (141, 38.5),
    (142, 41.5),
    (141.5, 45.4),
    (145.5, 43.3),
    (143.5, 42),
    (140, 41.4),
    (139.8, 38.5),
    (137, 37),
    (133, 35.5),
    (130.5, 34),
  ],
  // Madagascar.
  [
    (49.3, -12),
    (50.5, -15.5),
    (47.5, -25),
    (44, -24.5),
    (43.5, -21.5),
    (44.5, -16),
    (47, -14),
  ],
  // Sri Lanka.
  [(80, 6), (81.8, 7.5), (81, 9.8), (79.8, 8.5)],
  // Sumatra.
  [
    (95.3, 5.5),
    (98, 4),
    (104.5, -2),
    (106, -6),
    (102, -4.5),
    (100, -1),
    (97, 2.5),
  ],
  // Borneo.
  [
    (109, 1.5),
    (111, 2.5),
    (114, 4.5),
    (117, 7),
    (119, 5),
    (117.5, 1),
    (116, -3.5),
    (111, -3),
    (109.5, -1),
  ],
  // New Guinea.
  [
    (131, -1),
    (138, -1.5),
    (145, -4.5),
    (150.5, -10.5),
    (147, -10),
    (142, -9.2),
    (138, -8.3),
    (134, -4),
  ],
];

/// The coastlines densified (every ≤ 4°) and stored as
/// [cos lat, sin lat, sin lon, cos lon] per point, so turning the globe
/// costs no trigonometry per frame.
final List<List<double>> _landMasses = [
  for (final coast in _coastlines) _densify(coast),
];

List<double> _densify(List<(double, double)> coast) {
  const step = 4.0;
  final out = <double>[];
  for (var i = 0; i < coast.length; i++) {
    final (lon0, lat0) = coast[i];
    final (lon1, lat1) = coast[(i + 1) % coast.length];
    final n = math.max(
      1,
      (math.max((lon1 - lon0).abs(), (lat1 - lat0).abs()) / step).ceil(),
    );
    for (var j = 0; j < n; j++) {
      final t = j / n;
      final lat = (lat0 + (lat1 - lat0) * t) * math.pi / 180;
      final lon = (lon0 + (lon1 - lon0) * t) * math.pi / 180;
      out.addAll([math.cos(lat), math.sin(lat), math.sin(lon), math.cos(lon)]);
    }
  }
  return out;
}

/// Laid-out text, cached: canvas labels are laid out once per string and
/// colour, not on every frame.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  /// Painters evicted at the last overflow. They are disposed one overflow
  /// later, never while a paint call may still hold them.
  List<TextPainter> _retired = const [];

  /// Painters kept before the cache starts over (a fixed set of labels in
  /// two languages).
  static const int _maxEntries = 120;

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
  }) {
    final key =
        '$text|${size.toStringAsFixed(2)}|${color.toARGB32()}|${weight.value}';
    final hit = _painters[key];
    if (hit != null) return hit;
    if (_painters.length >= _maxEntries) {
      for (final painter in _retired) {
        painter.dispose();
      }
      _retired = _painters.values.toList();
      _painters.clear();
    }
    return _painters[key] = TextPainter(
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
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  void dispose() {
    for (final painter in [..._retired, ..._painters.values]) {
      painter.dispose();
    }
    _retired = const [];
    _painters.clear();
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
