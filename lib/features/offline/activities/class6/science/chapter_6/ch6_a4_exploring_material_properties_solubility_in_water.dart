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

/// Class 6 Science • Chapter 6 • Activity 4
/// Exploring Material Properties: Solubility in Water.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A4-Exploring_Material_Properties__Solubility_in_Water.html`.
///
/// Scenario 1 (The Disappearing Act): put a beaker of water on the lab
/// table, add sugar, sand, salt, chalk powder and sawdust one at a time
/// (drag each bowl from the shelf into the beaker, or tap its button), stir
/// and watch whether the material disappears, then sort the five materials
/// into Soluble and Insoluble columns.
///
/// Scenario 2 (Kitchen Chemistry): make an Oral Rehydration Solution: place
/// a tumbler on the counter, pour water from the jug, add sugar and salt,
/// stir, then add sand to see why an insoluble material spoils a drink.
class Ch6A4ExploringMaterialPropertiesSolubilityInWaterPage
    extends StatefulWidget {
  const Ch6A4ExploringMaterialPropertiesSolubilityInWaterPage({super.key});

  @override
  State<Ch6A4ExploringMaterialPropertiesSolubilityInWaterPage> createState() =>
      _SolubilityLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with the Web Audio
/// API; they map to the closest bundled file: 'pop' (buttons) -> click,
/// 'pour' (placing the beaker / tumbler, pouring a material or water) ->
/// drop, 'measure' (stirring) -> pop, 'success' -> correct (an observation,
/// a right column) or success (conclusion popups), 'error' (wrong column)
/// -> wrong. Picking an object up to drag it plays pickup (the HTML has no
/// drags in the 3D scene).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`,
/// pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action, observation shown.
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action / invalid move.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'pour': beaker / tumbler placed, material or water poured.
  drop('audio/class6/science/drop.mp3'),

  /// An object picked up to be dragged.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML 'measure': stirring.
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

/// Colours of this lab: the HTML's Tailwind UI colours and the Three.js
/// material colours of the two scenes.
abstract final class _Colors {
  // ---- UI (Tailwind classes used by the HTML).
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706); // Sand button
  static const Color amber700 = Color(0xFFB45309); // Sand Bowl chip
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue500 = Color(0xFF3B82F6); // Water Jug chip
  static const Color blue600 = Color(0xFF2563EB); // popups, Tumbler chip
  static const Color blue950 = Color(0xFF172554);
  static const Color indigo600 = Color(0xFF4F46E5); // Sugar button
  static const Color teal600 = Color(0xFF0D9488); // Chalk Powder button
  static const Color yellow700 = Color(0xFFA16207); // Sawdust button
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669); // Reset Water button
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569); // Salt button
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ---- Scenes (Three.js materials).
  static const Color canvasDark = slate950; // scene.background 0x020617
  static const Color canvasLight = slate100; // light theme 0xf1f5f9
  static const Color labTable = Color(0xFF1E293B); // tableMat
  static const Color labShelf = Color(0xFF334155); // shelfMat
  static const Color counter = Color(0xFF0F172A); // kitchen counter
  static const Color kitchenShelf = Color(0xFF475569);
  static const Color tableEdge = slate600;
  static const Color bowl = Color(0xFF64748B);
  static const Color bowlInside = Color(0xFF334155);
  static const Color glass = white; // beaker glassMat
  static const Color tumblerGlass = Color(0xFFA5F3FC);
  static const Color water = Color(0xFF38BDF8);
  static const Color clearWater = Color(0xFF0EA5E9); // after sugar / salt
  static const Color murkyWater = Color(0xFFFEF3C7); // sand swirling
  static const Color chalkStir = Color(0xFFF1F5F9);
  static const Color chalkWater = Color(0xFFE2E8F0); // cloudy suspension
  static const Color beakerRod = Color(0xFF94A3B8); // stirrerMesh
  static const Color tumblerRod = Color(0xFFE2E8F0); // s2Stirrer
  static const Color jug = Color(0xFF60A5FA);
  static const Color spoon = Color(0xFFCBD5E1); // added Stir Spoon

  // ---- Materials (matColors).
  static const Color sugar = Color(0xFFF8FAFC);
  static const Color sand = Color(0xFFD97706);
  static const Color salt = Color(0xFFFFFFFF);
  static const Color chalk = Color(0xFFE2E8F0);
  static const Color sawdust = Color(0xFFB45309);

  // ---- Floating labels (sprite canvas: rgba(15, 23, 42, .9), #38bdf8).
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = sky400;

  // ---- Inline alert (`#inline-alert`: blue-950 -> indigo-950 ->
  // slate-950 at 95 %, amber-400/80 border), the same in both themes.
  static const Color alertStart = Color(0xF2172554);
  static const Color alertMid = Color(0xF21E1B4B);
  static const Color alertEnd = Color(0xF2020617);
  static const Color alertBorder = Color(0xCCFBBF24);

  // ---- Sorting columns (`bg-blue-950/80`, `bg-slate-900/80`).
  static const Color solubleBin = Color(0xCC172554);
  static const Color insolubleBin = Color(0xCC0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). `accent` is the ZSL yellow of "Enter Lab"; `primary` the
/// blue of the HTML popups' buttons. The inline alert and the sorting
/// columns stay dark in both themes, as in the HTML.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A),
    border: Color(0x26FFFFFF),
    card: Color(0xCC1E293B),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvasDark,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.sky400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.blue950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.amber300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvasLight,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.sky600,
    popupBg: _Colors.white,
    popupHeader: _Colors.blue50,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.amber300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px; the
/// HTML slider defaults to 15 px).
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Step
// actions keep the HTML wording and say exactly what to drag or tap
// ("Click" is "Tap"); the HUD lines (`hud`) follow the HTML, with the
// buttons' real names. The emoji in labels and toasts are replaced by
// icons. Changes from the HTML:
// - `obs_sand_desc` was defined twice, so Scenario 1's sand result showed
//   the Scenario 2 drink text; the drink text is now `obs_sand_ors_desc`.
// - Hindi toasts no longer pair a material name with a gendered verb
//   ("{mat} को ... डाल दिया गया" instead of "{mat} ... डाल दिया गया"); a
//   name before a postposition takes its oblique form (`mat_*_obl`:
//   "लकड़ी के बुरादे को").
// - "rigorous stirring" reads "vigorous stirring".
// - The concept titles of S1 steps 2, 4 and 5 ("Adding Soluble Material",
//   "Adding Insoluble Material", "Insolubility of Sand") told the result
//   before the learner stirred; they are neutral now.
// Keys marked "added" are not in the HTML.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Material Properties: Solubility in Water',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1_opt': 'Scenario 1: The Disappearing Act: Soluble vs. Insoluble',
    'scen_2_opt':
        'Scenario 2: Kitchen Chemistry: Making a Rehydration Drink (ORS)',
    's1_desc':
        'To observe and classify different materials as either soluble or '
        'insoluble in water by mixing them and observing the outcome.',
    's2_desc':
        'To apply the concept of solubility to a real-world task by making a '
        'simple Oral Rehydration Solution (ORS).',
    // Scenario 1 steps.
    's1_c1': 'Experimental Setup',
    's1_a1':
        'Place the water beaker on the workspace: drag the beaker from the '
        "shelf onto the lab table (or tap 'Place Beaker on Table').",
    's1_o1': 'Beaker filled 2/3 with clean water is placed on table.',
    's1_c2': 'Adding the First Material',
    's1_a2':
        'Add sugar crystals to the water: drag the Sugar bowl from the shelf '
        "into the beaker (or tap 'Sugar').",
    's1_o2': 'Sugar sinks and settles at the bottom of the beaker.',
    's1_c3': 'Solubility of Sugar',
    's1_a3':
        "Stir the water vigorously: tap 'Stir Beaker' and watch the sugar.",
    's1_o3':
        'Sugar crystals disappear completely. Water is transparent. Sugar is '
        'soluble!',
    's1_c4': 'Adding the Next Material',
    's1_a4':
        "Reset the water and add sand: tap 'Reset Water & Test SAND', then "
        "drag the Sand bowl into the beaker (or tap 'Sand').",
    's1_o4': 'Grainy sand sinks rapidly to form a layer at the bottom.',
    's1_c5': 'Solubility of Sand',
    's1_a5': "Stir the sand in water: tap 'Stir Beaker' and watch the sand.",
    's1_o5':
        'Sand swirls but does not dissolve. Settles back at bottom. Sand is '
        'insoluble!',
    's1_c6': 'Testing Multiple Substances',
    's1_a6':
        'Test Salt, Chalk Powder and Sawdust one by one: for each, tap '
        "'Reset Water & Test …', drag its bowl into the beaker (or tap its "
        "name), then tap 'Stir Beaker'.",
    's1_o6':
        'Salt dissolves; Chalk turns milky and settles; Sawdust floats. '
        'Different solubility behavior!',
    's1_c7': 'Scientific Classification',
    's1_a7':
        'Classify the substances: drag each of the 5 items into the Soluble '
        'or Insoluble column (or tap an item, then a column).',
    's1_o7': 'Sugar & Salt are Soluble; Sand, Chalk & Sawdust are Insoluble!',
    // Scenario 2 steps.
    's2_c1': 'Real-world Preparation',
    's2_a1':
        'Place the clean tumbler: drag the Tumbler from the shelf onto the '
        "kitchen counter (or tap 'Tumbler').",
    's2_o1': 'Empty glass tumbler ready for drink mixing.',
    's2_c2': 'Solvent Addition',
    's2_a2':
        'Pour clean water into the tumbler: drag the Water Jug onto the '
        "tumbler (or tap 'Water Jug').",
    's2_o2': 'Tumbler filled 3/4 with fresh water.',
    's2_c3': 'Energy Component',
    's2_a3':
        'Add sugar to the water: drag the Sugar bowl onto the tumbler (or tap '
        "'Sugar Bowl').",
    's2_o3': 'Sugar crystals settle at bottom.',
    's2_c4': 'Electrolyte Component',
    's2_a4':
        'Add salt to the water: drag the Salt bowl onto the tumbler (or tap '
        "'Salt Bowl').",
    's2_o4': 'Salt crystals rest alongside sugar.',
    's2_c5': 'Creating a Solution',
    's2_a5':
        'Stir the mixture well: drag the Stir Spoon into the tumbler, or tap '
        "the glass (or 'Stir Spoon').",
    's2_o5': 'Both soluble ingredients dissolve into clear life-saving ORS!',
    's2_c6': 'Importance of Solubility',
    's2_a6':
        'Attempt adding sand to the drink: drag the Sand bowl onto the '
        "tumbler (or tap 'Sand Bowl').",
    's2_o6':
        'Insoluble sand sinks and makes the drink unappealing. Soluble items '
        'are essential for drinks!',
    // HUD "Current Task" lines.
    's1_hud_1':
        'Step 1: Drag the beaker from the shelf onto the table (or tap '
        "'Place Beaker on Table') to start.",
    's1_hud_2':
        "Step 2: Drag the Sugar bowl into the beaker (or tap 'Sugar') to add "
        'a spoonful.',
    's1_hud_3':
        "Step 3: Tap 'Stir Beaker' to mix the sugar and observe what happens.",
    's1_hud_4':
        "Step 4: Tap 'Reset Water & Test SAND', then add Sand into the fresh "
        'water.',
    's1_hud_5': "Step 5: Tap 'Stir Beaker' to see if sand dissolves.",
    's1_hud_6':
        'Step 6: Test and stir Salt, Chalk Powder, and Sawdust one by one.',
    's1_hud_7':
        'Step 7: Drag all 5 material items into the correct Soluble or '
        'Insoluble column!',
    's2_hud_1': "Step 1: Drag the 'Tumbler' onto the kitchen counter.",
    's2_hud_2': "Step 2: Drag the 'Water Jug' onto the tumbler to fill it.",
    's2_hud_3': "Step 3: Drag the 'Sugar Bowl' to add a spoonful of sugar.",
    's2_hud_4': "Step 4: Drag the 'Salt Bowl' to add a pinch of salt.",
    's2_hud_5':
        "Step 5: Drag the 'Stir Spoon' (or tap the glass) to dissolve "
        'ingredients.',
    's2_hud_6':
        "Step 6: Drag the 'Sand Bowl' to see why insoluble items ruin drinks!",
    // Conclusions.
    's1_summary':
        'You learned: Soluble substances (Sugar, Salt) dissolve completely in '
        'water. Insoluble substances (Sand, Chalk Powder, Sawdust) do not '
        'dissolve!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You mastered the property of solubility! You observed how soluble '
        'materials like sugar and salt dissolve completely in water, while '
        'insoluble materials like sand and chalk remain separate.',
    // Teacher board ("Conceptual Exploration" accordion).
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration Step',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    'obs_pending': 'Complete this step to see what happens.', // added
    // Buttons, items, columns.
    'btn_place_beaker': 'Place Beaker on Table',
    'btn_stir': 'Stir Beaker',
    'btn_next_mat': 'Reset Water & Test {mat}',
    'sort_prompt': 'Drag items into the correct column:',
    'col_soluble': 'Disappeared in Water (Soluble)',
    'col_insoluble': 'Did Not Disappear (Insoluble)',
    'col_soluble_name': 'Soluble',
    'col_insoluble_name': 'Insoluble',
    'mat_sugar': 'Sugar',
    'mat_sand': 'Sand',
    'mat_salt': 'Salt',
    'mat_chalk': 'Chalk Powder',
    'mat_sawdust': 'Sawdust',
    // Added: the names before a Hindi postposition (oblique case).
    'mat_sugar_obl': 'Sugar',
    'mat_sand_obl': 'Sand',
    'mat_salt_obl': 'Salt',
    'mat_chalk_obl': 'Chalk Powder',
    'mat_sawdust_obl': 'Sawdust',
    'item_tumbler': 'Tumbler',
    'item_jug': 'Water Jug',
    'item_sugar_bowl': 'Sugar Bowl',
    'item_salt_bowl': 'Salt Bowl',
    'item_stir_spoon': 'Stir Spoon',
    'item_sand_bowl': 'Sand Bowl',
    'lbl_beaker': 'Beaker', // added
    // Toasts.
    'toast_beaker_placed': 'Beaker of clear water placed on the lab table!',
    'toast_mat_poured': "{mat} poured into water! Now tap 'Stir Beaker'.",
    'toast_all_tested':
        'All materials tested! Now classify them into the Soluble and '
        'Insoluble columns.',
    'toast_incorrect_col': 'Incorrect! {mat} belongs to the {col} column!',
    'toast_already_classified': 'Already classified!',
    'toast_correct_classified': 'Correctly classified {mat}! ({n}/5)',
    'toast_tumbler_placed': 'Glass Tumbler placed on kitchen counter!',
    'toast_water_poured': 'Water poured into tumbler!',
    'toast_sugar_added': 'Sugar added to tumbler!',
    'toast_salt_added': 'Salt pinch added alongside sugar!',
    // Added: feedback for drags and taps that do not fit the step.
    'toast_not_yet': 'Not yet! {task}',
    'toast_drop_beaker': 'Drop the bowl into the beaker on the table.',
    'toast_drop_tumbler': 'Drop it onto the tumbler on the counter.',
    'toast_drop_table': 'Drop the beaker on the lab table.',
    'toast_drop_counter': 'Drop the tumbler on the kitchen counter.',
    'toast_pick_first':
        'Drag an item onto a column, or tap an item and then a column.',
    // Inline alert (stirring results).
    'obs_sugar_title': 'Sugar Dissolved Completely!',
    'obs_sugar_desc':
        'When stirred, sugar particles separate and mix evenly into the water '
        'until they disappear. Sugar is SOLUBLE in water!',
    'obs_sand_title': 'Sand Did Not Dissolve!',
    'obs_sand_desc':
        'Even after vigorous stirring, heavy sand grains settle at the '
        'bottom. Sand is INSOLUBLE in water!',
    'obs_salt_title': 'Salt Dissolved Completely!',
    'obs_salt_desc':
        'Just like sugar, common salt dissolves readily into clear water. '
        'Salt is SOLUBLE in water!',
    'obs_chalk_title': 'Chalk Powder is Insoluble!',
    'obs_chalk_desc':
        'Chalk turns the water milky white and suspended particles gradually '
        'settle at the bottom. Chalk is INSOLUBLE!',
    'obs_sawdust_title': 'Sawdust Floats and is Insoluble!',
    'obs_sawdust_desc':
        'Sawdust particles float on the surface of water and refuse to '
        'dissolve. Sawdust is INSOLUBLE!',
    'obs_ors_title': 'Rehydration Drink (ORS) Ready!',
    'obs_ors_desc':
        'Both sugar and salt dissolved to form a clear nutrient solution that '
        'helps rehydrate the body!',
    'obs_sand_ors_title': 'Sand Ruined the Drink!',
    'obs_sand_ors_desc':
        'Because sand is insoluble, it sinks to the bottom making the drink '
        'gritty and undrinkable. Always use soluble ingredients for drinks!',
  },
  'hi': {
    'app_title': 'पदार्थों के गुणों की खोज: जल में विलेयता',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर के पदार्थ',
    'scen_1_opt': 'परिदृश्य 1: अदृश्य होने का खेल: विलेय बनाम अविलेय',
    'scen_2_opt': 'परिदृश्य 2: रसोई रसायन: जीवनरक्षक घोल (ORS) बनाना',
    's1_desc':
        'विभिन्न पदार्थों को पानी में मिलाकर यह देखना कि कौन विलेय (घुलनशील) है '
        'और कौन अविलेय।',
    's2_desc':
        'दैनिक जीवन में विलेयता के गुण का उपयोग करके ओआरएस (ORS) घोल तैयार '
        'करना।',
    's1_c1': 'प्रायोगिक तैयारी',
    's1_a1':
        'मेज पर पानी का बीकर रखें: शेल्फ से बीकर को प्रयोगशाला की मेज पर खींचें '
        "(या 'बीकर को मेज पर रखें' पर टैप करें)।",
    's1_o1': 'साफ पानी से 2/3 भरा बीकर मेज पर रखा गया।',
    's1_c2': 'पहला पदार्थ डालना',
    's1_a2':
        'पानी में चीनी के कण डालें: शेल्फ से चीनी के कटोरे को बीकर में खींचें '
        "(या 'चीनी' पर टैप करें)।",
    's1_o2': 'चीनी बीकर के तल पर जाकर बैठ जाती है।',
    's1_c3': 'चीनी की विलेयता',
    's1_a3':
        "पानी को तेजी से हिलाएं: 'बीकर में घोलें' पर टैप करें और चीनी को देखें।",
    's1_o3': 'चीनी पूरी तरह गायब हो जाती है। पानी साफ है। चीनी विलेय है!',
    's1_c4': 'अगला पदार्थ डालना',
    's1_a4':
        "नया पानी लें और रेत डालें: 'पानी बदलें और रेत जाँचें' पर टैप करें, फिर "
        "रेत के कटोरे को बीकर में खींचें (या 'रेत' पर टैप करें)।",
    's1_o4': 'रेत तेजी से नीचे डूबकर परत बना लेती है।',
    's1_c5': 'रेत की विलेयता',
    's1_a5':
        "रेत को पानी में घोलें: 'बीकर में घोलें' पर टैप करें और रेत को देखें।",
    's1_o5': 'रेत घूमती है पर घुलती नहीं। नीचे बैठ जाती है। रेत अविलेय है!',
    's1_c6': 'विभिन्न पदार्थों का परीक्षण',
    's1_a6':
        'नमक, चॉक पाउडर और लकड़ी के बुरादे को एक-एक करके जाँचें: हर एक के लिए '
        "'पानी बदलें और … जाँचें' पर टैप करें, उसके कटोरे को बीकर में खींचें (या "
        "उसके नाम पर टैप करें), फिर 'बीकर में घोलें' पर टैप करें।",
    's1_o6':
        'नमक घुलता है; चॉक दूधिया होकर बैठता है; बुरादा तैरता है। अलग-अलग '
        'विलेयता व्यवहार!',
    's1_c7': 'वैज्ञानिक वर्गीकरण',
    's1_a7':
        'पदार्थों को वर्गीकृत करें: सभी 5 वस्तुओं को विलेय या अविलेय कॉलम में '
        'खींचें (या पहले वस्तु पर, फिर कॉलम पर टैप करें)।',
    's1_o7': 'चीनी और नमक विलेय हैं; रेत, चॉक और बुरादा अविलेय हैं!',
    's2_c1': 'दैनिक जीवन की तैयारी',
    's2_a1':
        'साफ गिलास रखें: शेल्फ से गिलास को खींचकर रसोई के काउंटर पर रखें (या '
        "'गिलास' पर टैप करें)।",
    's2_o1': 'घोल बनाने के लिए खाली गिलास तैयार है।',
    's2_c2': 'विलायक मिलाना',
    's2_a2':
        'गिलास में साफ पानी डालें: पानी के जग को गिलास पर खींचें (या '
        "'पानी का जग' पर टैप करें)।",
    's2_o2': 'गिलास 3/4 पानी से भर गया।',
    's2_c3': 'ऊर्जा घटक',
    's2_a3':
        'पानी में चीनी डालें: चीनी के कटोरे को गिलास पर खींचें (या '
        "'चीनी का कटोरा' पर टैप करें)।",
    's2_o3': 'चीनी तल पर बैठ जाती है।',
    's2_c4': 'इलेक्ट्रोलाइट घटक',
    's2_a4':
        'पानी में नमक डालें: नमक के कटोरे को गिलास पर खींचें (या '
        "'नमक का कटोरा' पर टैप करें)।",
    's2_o4': 'नमक चीनी के साथ तल पर बैठता है।',
    's2_c5': 'घोल तैयार करना',
    's2_a5':
        'मिश्रण को अच्छी तरह हिलाएं: चम्मच को गिलास में खींचें, या गिलास पर टैप '
        "करें (या 'चम्मच' पर टैप करें)।",
    's2_o5': 'दोनों विलेय पदार्थ घुलकर स्वच्छ जीवनरक्षक ओआरएस बनाते हैं!',
    's2_c6': 'विलेयता का महत्व',
    's2_a6':
        'पेय में रेत डालने का प्रयास करें: रेत के कटोरे को गिलास पर खींचें (या '
        "'रेत का कटोरा' पर टैप करें)।",
    's2_o6': 'अविलेय रेत नीचे बैठ जाती है और पेय खराब हो जाता है!',
    's1_hud_1':
        'चरण 1: शुरू करने के लिए शेल्फ से बीकर को मेज पर खींचें (या '
        "'बीकर को मेज पर रखें' पर टैप करें)।",
    's1_hud_2':
        "चरण 2: चीनी डालने के लिए चीनी के कटोरे को बीकर में खींचें (या 'चीनी' "
        'पर टैप करें)।',
    's1_hud_3':
        "चरण 3: चीनी को मिलाने के लिए 'बीकर में घोलें' पर टैप करें और देखें कि "
        'क्या होता है।',
    's1_hud_4':
        "चरण 4: 'पानी बदलें और रेत जाँचें' पर टैप करें, फिर ताजे पानी में रेत "
        'डालें।',
    's1_hud_5':
        "चरण 5: क्या रेत घुलती है, यह देखने के लिए 'बीकर में घोलें' पर टैप करें।",
    's1_hud_6':
        'चरण 6: नमक, चॉक पाउडर और लकड़ी के बुरादे की बारी-बारी से जाँच करें और '
        'घोलें।',
    's1_hud_7': 'चरण 7: सभी 5 पदार्थों को सही विलेय या अविलेय कॉलम में खींचें!',
    's2_hud_1': "चरण 1: 'गिलास' को खींचकर रसोई के काउंटर पर रखें।",
    's2_hud_2': "चरण 2: गिलास भरने के लिए 'पानी का जग' को गिलास पर खींचें।",
    's2_hud_3': "चरण 3: एक चम्मच चीनी डालने के लिए 'चीनी का कटोरा' खींचें।",
    's2_hud_4': "चरण 4: एक चुटकी नमक डालने के लिए 'नमक का कटोरा' खींचें।",
    's2_hud_5':
        "चरण 5: दोनों को घोलने के लिए 'चम्मच' को गिलास में खींचें (या गिलास पर "
        'टैप करें)।',
    's2_hud_6':
        'चरण 6: अविलेय पदार्थ पेय को कैसे खराब करते हैं, यह देखने के लिए '
        "'रेत का कटोरा' खींचें!",
    's1_summary':
        'आपने जाना: विलेय पदार्थ (चीनी, नमक) पानी में पूरी तरह घुल जाते हैं। '
        'अविलेय पदार्थ (रेत, चॉक, बुरादा) नहीं घुलते!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने विलेयता के गुण को सफलतापूर्वक समझा! आपने देखा कि चीनी और नमक जैसे '
        'विलेय पदार्थ पानी में पूरी तरह घुल जाते हैं, जबकि रेत और चॉक जैसे अविलेय '
        'पदार्थ अलग रहते हैं।',
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण चरण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'obs_pending': 'क्या होता है, यह देखने के लिए यह चरण पूरा करें।',
    'btn_place_beaker': 'बीकर को मेज पर रखें',
    'btn_stir': 'बीकर में घोलें',
    'btn_next_mat': 'पानी बदलें और {mat} जाँचें',
    'sort_prompt': 'वस्तुओं को सही कॉलम में खींचें:',
    'col_soluble': 'जल में घुलनशील (विलेय)',
    'col_insoluble': 'जल में अघुलनशील (अविलेय)',
    'col_soluble_name': 'विलेय',
    'col_insoluble_name': 'अविलेय',
    'mat_sugar': 'चीनी',
    'mat_sand': 'रेत',
    'mat_salt': 'नमक',
    'mat_chalk': 'चॉक पाउडर',
    'mat_sawdust': 'लकड़ी का बुरादा',
    'mat_sugar_obl': 'चीनी',
    'mat_sand_obl': 'रेत',
    'mat_salt_obl': 'नमक',
    'mat_chalk_obl': 'चॉक पाउडर',
    'mat_sawdust_obl': 'लकड़ी के बुरादे',
    'item_tumbler': 'गिलास',
    'item_jug': 'पानी का जग',
    'item_sugar_bowl': 'चीनी का कटोरा',
    'item_salt_bowl': 'नमक का कटोरा',
    'item_stir_spoon': 'चम्मच',
    'item_sand_bowl': 'रेत का कटोरा',
    'lbl_beaker': 'बीकर',
    'toast_beaker_placed': 'प्रयोगशाला की मेज पर साफ पानी का बीकर रखा गया!',
    'toast_mat_poured':
        "{mat} को पानी में डाल दिया गया! अब 'बीकर में घोलें' पर टैप करें।",
    'toast_all_tested':
        'सभी पदार्थों की जाँच हो गई! अब उन्हें विलेय और अविलेय कॉलम में बाँटें।',
    'toast_incorrect_col': 'गलत! {mat} का सही स्थान {col} कॉलम है!',
    'toast_already_classified': 'पहले ही वर्गीकृत किया जा चुका है!',
    'toast_correct_classified': '{mat} को सही कॉलम में रखा गया! ({n}/5)',
    'toast_tumbler_placed': 'काँच का गिलास रसोई के काउंटर पर रखा गया!',
    'toast_water_poured': 'गिलास में पानी डाला गया!',
    'toast_sugar_added': 'गिलास में चीनी डाली गई!',
    'toast_salt_added': 'चीनी के साथ नमक डाला गया!',
    'toast_not_yet': 'अभी नहीं! {task}',
    'toast_drop_beaker': 'कटोरे को मेज पर रखे बीकर के ऊपर लाकर छोड़ें।',
    'toast_drop_tumbler': 'इसे काउंटर पर रखे गिलास के ऊपर लाकर छोड़ें।',
    'toast_drop_table': 'बीकर को प्रयोगशाला की मेज पर छोड़ें।',
    'toast_drop_counter': 'गिलास को रसोई के काउंटर पर छोड़ें।',
    'toast_pick_first':
        'किसी वस्तु को कॉलम पर खींचें, या पहले वस्तु पर और फिर कॉलम पर टैप करें।',
    'obs_sugar_title': 'चीनी पूरी तरह घुल गई!',
    'obs_sugar_desc':
        'हिलाने पर, चीनी के कण पानी में समान रूप से मिलकर अदृश्य हो जाते हैं। '
        'चीनी जल में विलेय (घुलनशील) है!',
    'obs_sand_title': 'रेत नहीं घुली!',
    'obs_sand_desc':
        'तेजी से हिलाने के बाद भी भारी रेत तल पर बैठ जाती है। रेत जल में अविलेय '
        '(अघुलनशील) है!',
    'obs_salt_title': 'नमक पूरी तरह घुल गया!',
    'obs_salt_desc':
        'चीनी की तरह नमक भी पानी में आसानी से घुल जाता है। नमक जल में विलेय है!',
    'obs_chalk_title': 'चॉक पाउडर अविलेय है!',
    'obs_chalk_desc':
        'चॉक पानी को दूधिया सफेद बना देता है और कण धीरे-धीरे नीचे बैठ जाते हैं। '
        'चॉक अविलेय है!',
    'obs_sawdust_title': 'लकड़ी का बुरादा तैरता है और अविलेय है!',
    'obs_sawdust_desc':
        'बुरादा पानी की सतह पर तैरता है और घुलता नहीं है। यह अविलेय है!',
    'obs_ors_title': 'पुनर्जलीकरण पेय (ORS) तैयार!',
    'obs_ors_desc':
        'चीनी और नमक दोनों घुल गए और एक स्वच्छ जीवनरक्षक घोल तैयार हो गया!',
    'obs_sand_ors_title': 'रेत ने पेय खराब कर दिया!',
    'obs_sand_ors_desc':
        'चूंकि रेत अविलेय है, यह नीचे बैठ जाती है और पेय को पीने अयोग्य बना देती '
        'है!',
  },
};

/// Steps per scenario (HTML `ScenariosData[...].steps`: 7 and 6).
const List<int> _stepCounts = [7, 6];

/// The two scenarios for [lang] (HTML `ScenariosData`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var sc = 1; sc <= _stepCounts.length; sc++)
      LabScenarioData(
        title: t('scen_${sc}_opt'),
        objective: t('s${sc}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[sc - 1]; i++)
            LabStep(
              concept: t('s${sc}_c$i'),
              action: t('s${sc}_a$i'),
              observation: t('s${sc}_o$i'),
            ),
        ],
      ),
  ];
}

/// Scenario data per language, built once.
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the scene (stage coordinates).
const Size _design = Size(1000, 560);

/// Short drags must pick an object up before the zoom viewer claims them.
const double _touchSlop = 8;

/// Smallest touch target (objects in the scene, chips, columns), in dp.
const double _minTouch = 48;

/// Part of the base projection (design px at zoom 1) holding everything the
/// learner handles: the shelf bowls and their labels, the beaker / tumbler
/// on the shelf and on the table, the jug and the spoon. The scene is
/// framed so that this box fills the free part of the canvas ([_frameFor]).
const Rect _content = Rect.fromLTRB(228, 18, 772, 374);
const double _maxZoom = 1.3;
const double _minZoom = 0.7;

/// Canvas bands kept free of the scene (dp, times the UI scale): the toast
/// row at the top (below its 10 dp margin) and the HUD chip at the bottom.
const double _toastTop = 10;
const double _toastBand = 40;
const double _hudBand = 58;
const double _edge = 8;

/// The shell's floating mission card (sidebar collapsed): 76 dp from the
/// left, 12 dp from the top, at most 55 % of the screen tall on phones.
const double _missionLeft = 76;
const double _missionTop = 12;
const double _missionMaxHeight = 0.55;

/// Room the shell's tool column takes on the right of the canvas.
const double _toolColumn = 72;

/// The view re-frames like the sidebar slides (380 ms).
const double _frameSeconds = 0.38;

/// Scene labels keep a readable on-screen size on small phones.
const double _labelPx = 11.5;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);

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
    return l == 0 ? this : this * (1 / l);
  }

  /// Three.js `rotation.z` by [a].
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Pinhole projection of the HTML `PerspectiveCamera(45°)` at (0, 10, 24)
/// looking at `controls.target` (0, 2, 0), both scenarios
/// (`resetCamera()`). These are the base coordinates; [_Frame] scales and
/// moves them onto the stage.
class _Proj {
  _Proj(this.eye, _V target) : f = (target - eye).unit {
    r = f.cross(_V.up).unit;
    u = r.cross(f);
  }

  /// Focal length for the 45° vertical field of view over the stage height.
  static final double focal = _design.height / 2 / math.tan(math.pi / 8);

  /// Where the look-at point lands at zoom 1.
  static const Offset center = Offset(500, 280);

  final _V eye;
  final _V f;
  late final _V r;
  late final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Base px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a base point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray meets the horizontal plane y = [py], or null.
  _V? onPlaneY(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    return t <= 0 ? null : eye + d * t;
  }

  /// Where that ray meets the upright plane z = [pz] (facing the camera).
  _V? onPlaneZ(Offset s, double pz) {
    final d = ray(s);
    if (d.z.abs() < 1e-6) return null;
    final t = (pz - eye.z) / d.z;
    return t <= 0 ? null : eye + d * t;
  }
}

final _Proj _proj = _Proj(const _V(0, 10, 24), const _V(0, 2, 0));

/// A Three.js group transform: position plus `rotation.z`.
@immutable
class _Xf {
  const _Xf(this.pos, [this.rotZ = 0]);

  final _V pos;
  final double rotZ;

  _V call(_V local) => pos + (rotZ == 0 ? local : local.rotZ(rotZ));

  /// The group's local +y axis in world space.
  _V get up => rotZ == 0 ? _V.up : _V.up.rotZ(rotZ);
}

/// How the base projection sits on the stage: `design = offset + base *
/// zoom`. Painting and hit tests both go through it, so the scene can be
/// re-framed beside the shell's cards without moving any world position.
@immutable
class _Frame {
  const _Frame(this.zoom, this.offset);

  static const _Frame identity = _Frame(1, Offset.zero);

  final double zoom;
  final Offset offset;

  Offset toDesign(Offset base) => offset + base * zoom;
  Offset toBase(Offset design) => (design - offset) / zoom;

  static _Frame lerp(_Frame a, _Frame b, double t) => _Frame(
    a.zoom + (b.zoom - a.zoom) * t,
    Offset.lerp(a.offset, b.offset, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is _Frame && other.zoom == zoom && other.offset == offset;

  @override
  int get hashCode => Object.hash(zoom, offset);
}

// ---- Scene layout (HTML buildS1 / buildS2), world units.

/// Top of the shelf box (BoxGeometry(22 | 20, 0.5, 3) at y 6), where the
/// bowls stand.
const double _shelfTop = 6.25;
const double _shelfZ = -6;

/// Front edge of the shelf: a beaker or tumbler is only on the table once
/// it is in front of this.
const double _shelfFront = -4.5;

/// `resetScenarioState`: the beaker and the tumbler start near the shelf.
const _V _beakerStart = _V(-6, 6.25, -4);
const _V _tumblerStart = _V(-8, 6.25, -4);

/// Tween target of the beaker / tumbler on the table.
const _V _bench = _V.zero;

/// A bowl pours from here (`to({x: -1.2, y: 5.2, z: 0})`), tilted -0.7.
const _V _pourPos = _V(-1.2, 5.2, 0);
const double _pourTilt = -0.7;

/// Pouring stream: CylinderGeometry(0.12, 0.22, 3) at (-0.5, 4.0, 0).
const _V _streamPos = _V(-0.5, 4.0, 0);
const double _streamLength = 3;

/// Water jug on the counter and its pouring pose (rotation.z 0.6).
const _V _jugHome = _V(7, 0, -2);
const _V _jugPour = _V(2.2, 3.5, 0);
const double _jugTilt = 0.6;

/// Added: the HTML's "Stir Spoon" drag chip is a spoon lying on the counter.
const _V _spoonHome = _V(4.8, 0.12, 3.4);

/// Water inside the vessels: CylinderGeometry height 3 at y 1.6.
const double _waterBottom = 0.1;
const double _waterHeight = 3;
const double _waterAlpha = 0.6;

/// Sawdust layer (CylinderGeometry(1.8, 1.8, 0.15)) at rest on the water.
const double _floatRest = 3.05;
const double _floatRadius = 1.8;
const double _floatThickness = 0.15;

/// Touch boxes reach this far past an object's mesh (world units).
const double _hitMargin = 0.1;

/// The vessel's drop zone: [_dropMargin] past the rim, up to [_dropTop]
/// (the pour position is at y 5.2), plus [_dropSlack] base px.
const double _dropMargin = 0.5;
const double _dropTop = 5.8;
const double _dropSlack = 10;

/// Dragged objects stay above the table / counter top.
const double _carryX = 12;
const double _carryBack = -7;
const double _carryFront = 7;
const double _carryTop = 10;

// ---- Timings (s), from the HTML tweens and timeouts.
const double _placeTime = 0.8; // beaker / tumbler, 800 ms Quadratic.Out
const double _bowlMove = 0.5; // bowl to the pour position, 500 ms
const double _tiltTime = 0.3; // tilt, stream growth, tilt back
const double _pourHold = 0.6; // setTimeout 600 ms
const double _returnDelay = 0.2; // bowl return delay(200)
const double _returnTime = 0.5;
const double _stirTime = 1.8; // setTimeout 1800 ms
const double _stirRate = 10; // stirCount += 0.5 every 50 ms
const double _jugMove = 0.6;
const double _jugHold = 1.2;
const double _fillTime = 1.0;
const double _dissolveTime = 0.4; // s2Sediment shrinks in 400 ms
const double _springTime = 0.3; // a refused drop slides back (added)
const Duration _conclusionS1 = Duration(milliseconds: 1000);
const Duration _conclusionS2 = Duration(milliseconds: 3500);

/// One vessel's meshes: glass, water, sediment and stirring rod.
@immutable
class _Vessel {
  const _Vessel({
    required this.rTop,
    required this.rBottom,
    required this.height,
    required this.waterTop,
    required this.waterBase,
    required this.sediment,
    required this.sedimentHeight,
    required this.sedimentY,
    required this.rodY,
    required this.rodLength,
    required this.rodCircle,
    required this.glass,
    required this.glassAlpha,
    required this.rod,
  });

  final double rTop;
  final double rBottom;
  final double height;

  /// Water radii at the top and bottom of a full vessel.
  final double waterTop;
  final double waterBase;
  final double sediment;
  final double sedimentHeight;
  final double sedimentY;

  /// Stirrer: centre height, length and stirring circle radius.
  final double rodY;
  final double rodLength;
  final double rodCircle;
  final Color glass;
  final double glassAlpha;
  final Color rod;
}

/// The beaker of Scenario 1 (glassMesh 2.0 / 1.9 x 4.5, water 1.85, bottom
/// sediment 1.7 x 0.4 at y 0.35, stirrer 5.5 long at y 3.5, circle 0.8).
const _Vessel _beaker = _Vessel(
  rTop: 2.0,
  rBottom: 1.9,
  height: 4.5,
  waterTop: 1.85,
  waterBase: 1.85,
  sediment: 1.7,
  sedimentHeight: 0.4,
  sedimentY: 0.35,
  rodY: 3.5,
  rodLength: 5.5,
  rodCircle: 0.8,
  glass: _Colors.glass,
  glassAlpha: 0.35,
  rod: _Colors.beakerRod,
);

/// The glass tumbler of Scenario 2 (1.8 / 1.5 x 4.2, water 1.7 / 1.45,
/// sediment 1.4 x 0.35 at y 0.3, stirrer 5.2 long at y 3.2, circle 0.7).
const _Vessel _tumbler = _Vessel(
  rTop: 1.8,
  rBottom: 1.5,
  height: 4.2,
  waterTop: 1.7,
  waterBase: 1.45,
  sediment: 1.4,
  sedimentHeight: 0.35,
  sedimentY: 0.3,
  rodY: 3.2,
  rodLength: 5.2,
  rodCircle: 0.7,
  glass: _Colors.tumblerGlass,
  glassAlpha: 0.4,
  rod: _Colors.tumblerRod,
);

/// The tilt of the stirring rods (rotation.z 0.15).
const double _rodTilt = 0.15;
const double _rodRadius = 0.12;

/// Scenario 1's materials, in the order they are tested (HTML `nextOrder`).
enum _Mat {
  sugar('mat_sugar', _Colors.sugar, _Colors.indigo600, true, -8),
  sand('mat_sand', _Colors.sand, _Colors.amber600, false, -4),
  salt('mat_salt', _Colors.salt, _Colors.slate600, true, 0),
  chalk('mat_chalk', _Colors.chalk, _Colors.teal600, false, 4),
  sawdust('mat_sawdust', _Colors.sawdust, _Colors.yellow700, false, 8);

  const _Mat(this.key, this.color, this.fill, this.soluble, this.shelfX);

  /// Name string key.
  final String key;

  /// Pile, pouring stream and sediment colour (HTML `matColors`).
  final Color color;

  /// Button / chip colour (HTML `bg-*-600`).
  final Color fill;

  /// Sugar and salt dissolve (the HTML sort chips' expected column).
  final bool soluble;

  /// Bowl position on the Scenario 1 shelf (x).
  final double shelfX;

  /// Sand and chalk are labelled in a second row above the shelf, so the
  /// five labels never overlap.
  bool get upperLabel => this == sand || this == chalk;
}

/// Scenario 2's shelf (buildS2): sugar, salt and sand bowls.
const Map<_Mat, double> _s2Shelf = {_Mat.sugar: -4, _Mat.salt: 0, _Mat.sand: 4};

/// Things the learner can drag or tap in the scene.
enum _Obj {
  vessel,
  sugar,
  sand,
  salt,
  chalk,
  sawdust,
  jug,
  spoon;

  /// The material of a bowl, null for the other objects.
  _Mat? get mat => switch (this) {
    _Obj.sugar => _Mat.sugar,
    _Obj.sand => _Mat.sand,
    _Obj.salt => _Mat.salt,
    _Obj.chalk => _Mat.chalk,
    _Obj.sawdust => _Mat.sawdust,
    _ => null,
  };

  static _Obj bowl(_Mat m) => switch (m) {
    _Mat.sugar => _Obj.sugar,
    _Mat.sand => _Obj.sand,
    _Mat.salt => _Obj.salt,
    _Mat.chalk => _Obj.chalk,
    _Mat.sawdust => _Obj.sawdust,
  };
}

/// Scenario 1's progress through one material test.
enum _Phase {
  /// Step 1: the beaker is still near the shelf.
  place,

  /// The current material can be added.
  ready,

  /// The bowl is pouring.
  adding,

  /// The material is in the water; 'Stir Beaker' is offered.
  added,
  stirring,

  /// The result is shown; 'Reset Water & Test …' is offered.
  stirred,

  /// Step 7: classification.
  sorting,
  done,
}

/// The HTML inline alert shown after a stir or the last pour.
enum _Alert {
  sugar('obs_sugar', Icons.water_drop),
  sand('obs_sand', Icons.grain),
  salt('obs_salt', Icons.water_drop),
  chalk('obs_chalk', Icons.cloud),
  sawdust('obs_sawdust', Icons.forest),
  ors('obs_ors', Icons.local_drink),
  sandOrs('obs_sand_ors', Icons.sentiment_dissatisfied);

  const _Alert(this.key, this.icon);

  /// String key prefix (`<key>_title`, `<key>_desc`).
  final String key;
  final IconData icon;

  static _Alert of(_Mat m) => switch (m) {
    _Mat.sugar => _Alert.sugar,
    _Mat.sand => _Alert.sand,
    _Mat.salt => _Alert.salt,
    _Mat.chalk => _Alert.chalk,
    _Mat.sawdust => _Alert.sawdust,
  };
}

/// One running animation (HTML TWEEN / setTimeout), on the scene clock.
class _Tween {
  _Tween(this.start, this.duration, this.apply, this.curve, this.onDone);

  final double start;
  final double duration;
  final void Function(double t)? apply;
  final Curve curve;
  final VoidCallback? onDone;
}

/// Mutable simulation state read by the painter every frame.
class _Sim {
  int scenario = 0;
  int step = 1;
  double time = 0;

  /// An action or animation is running; new actions wait.
  bool busy = false;
  final List<_Tween> _tweens = [];

  // ---- Beaker (S1) / tumbler (S2), bowls, pouring stream.
  _V vessel = _beakerStart;
  final Map<_Mat, _V> bowls = {};
  final Map<_Mat, double> tilts = {};
  bool streamOn = false;
  Color streamColor = _Colors.sugar;
  double streamScale = 1;

  // ---- Contents of the vessel.
  bool waterOn = true;
  Color water = _Colors.water;
  double waterAlpha = _waterAlpha;

  /// 0..1 of the full water column (the tumbler fills from the jug).
  double waterLevel = 1;
  bool sediment = false;
  Color sedimentColor = _Colors.sugar;
  double sedimentWidth = 1;
  double sedimentHeight = 1;
  bool floating = false;
  double floatY = _floatRest;
  bool stirring = false;

  /// HTML `stirCount`: the stirrer's angle on its circle.
  double stirAngle = 0;

  // ---- Scenario 1.
  _Phase phase = _Phase.place;
  int matIndex = 0;
  final Set<_Mat> sorted = {};
  _Mat? selected;

  // ---- Scenario 2.
  _V jug = _jugHome;
  double jugTilt = 0;
  _V spoon = _spoonHome;
  bool spoonInUse = false;

  _Alert? alert;

  // ---- Dragging.
  _Obj? held;
  Offset grabDelta = Offset.zero;
  double heldZ = 0;

  /// The held object is over the vessel (drop would be accepted).
  bool overTarget = false;

  // ---- Framing.
  _Frame frame = _Frame.identity;
  _Frame frameTarget = _Frame.identity;
  _Frame _frameFrom = _Frame.identity;
  double _frameStart = -1;
  bool _framed = false;

  // ---- Painting resources, created once and reused every frame.
  final _Pictures pictures = _Pictures();
  final _TextCache text = _TextCache();
  final _Draw draw = _Draw();

  _Mat get mat => _Mat.values[matIndex];
  _Mat? get nextMat =>
      matIndex + 1 < _Mat.values.length ? _Mat.values[matIndex + 1] : null;
  _Vessel get dims => scenario == 0 ? _beaker : _tumbler;
  bool get animating => _tweens.isNotEmpty;

  /// The view has reached its framing (flows read [anchor] only then).
  bool get framingSettled => _framed && _frameStart < 0;

  void tween(
    double seconds,
    void Function(double t)? apply, {
    Curve curve = Curves.linear,
    VoidCallback? onDone,
  }) => _tweens.add(_Tween(time, seconds, apply, curve, onDone));

  /// HTML `setTimeout`, on the scene clock.
  void wait(double seconds, VoidCallback fn) =>
      tween(seconds, null, onDone: fn);

  /// Advances every tween to [time]; finished ones run their callback,
  /// which may start new tweens (they run from the next frame).
  void runTweens() {
    if (_tweens.isEmpty) return;
    for (final tw in List.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final t = tw.duration <= 0
          ? 1.0
          : ((time - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.apply?.call(tw.curve.transform(t));
      if (t >= 1) {
        _tweens.remove(tw);
        tw.onDone?.call();
      }
    }
  }

  /// Sets where the view should be framed; the first one is taken at once,
  /// later ones slide in over [_frameSeconds].
  void setFrameTarget(_Frame f) {
    if (!_framed) {
      frame = frameTarget = f;
      _framed = true;
      return;
    }
    if (f == frameTarget) return;
    _frameFrom = frame;
    frameTarget = f;
    _frameStart = time;
  }

  /// Moves the view towards its target; true while it moves.
  bool stepFrame() {
    if (_frameStart < 0) return false;
    final t = ((time - _frameStart) / _frameSeconds).clamp(0.0, 1.0);
    frame = _Frame.lerp(
      _frameFrom,
      frameTarget,
      Curves.easeInOutCubic.transform(t),
    );
    if (t >= 1) {
      frame = frameTarget;
      _frameStart = -1;
    }
    return true;
  }

  /// HTML `resetScenarioState(sc)`: the bench for [sc] at step 1.
  void reset(int sc) {
    scenario = sc;
    step = 1;
    busy = false;
    _tweens.clear();
    vessel = sc == 0 ? _beakerStart : _tumblerStart;
    bowls.clear();
    tilts.clear();
    if (sc == 0) {
      for (final m in _Mat.values) {
        bowls[m] = _V(m.shelfX, _shelfTop, _shelfZ);
      }
    } else {
      _s2Shelf.forEach((m, x) => bowls[m] = _V(x, _shelfTop, _shelfZ));
    }
    for (final m in bowls.keys) {
      tilts[m] = 0;
    }
    streamOn = false;
    streamScale = 1;
    waterOn = sc == 0;
    water = _Colors.water;
    waterAlpha = _waterAlpha;
    waterLevel = 1;
    sediment = false;
    sedimentWidth = 1;
    sedimentHeight = 1;
    floating = false;
    floatY = _floatRest;
    stirring = false;
    stirAngle = 0;
    phase = _Phase.place;
    matIndex = 0;
    sorted.clear();
    selected = null;
    jug = _jugHome;
    jugTilt = 0;
    spoon = _spoonHome;
    spoonInUse = false;
    alert = null;
    held = null;
    grabDelta = Offset.zero;
    overTarget = false;
  }

  /// Does this scenario have [o]?
  bool has(_Obj o) {
    final m = o.mat;
    if (m != null) return bowls.containsKey(m);
    if (o == _Obj.jug) return scenario == 1;
    if (o == _Obj.spoon) return scenario == 1 && !spoonInUse;
    return true;
  }

  /// Where [o] stands when it is not being used.
  _V home(_Obj o) => switch (o) {
    _Obj.vessel => scenario == 0 ? _beakerStart : _tumblerStart,
    _Obj.jug => _jugHome,
    _Obj.spoon => _spoonHome,
    _ => _V(
      scenario == 0 ? o.mat!.shelfX : _s2Shelf[o.mat]!,
      _shelfTop,
      _shelfZ,
    ),
  };

  _V pos(_Obj o) => switch (o) {
    _Obj.vessel => vessel,
    _Obj.jug => jug,
    _Obj.spoon => spoon,
    _ => bowls[o.mat]!,
  };

  void setPos(_Obj o, _V p) {
    switch (o) {
      case _Obj.vessel:
        vessel = p;
      case _Obj.jug:
        jug = p;
      case _Obj.spoon:
        spoon = p;
      default:
        bowls[o.mat!] = p;
    }
  }

  /// Body centre of [o] (drag handle and label anchor).
  _V centre(_Obj o) =>
      pos(o) +
      switch (o) {
        _Obj.vessel => _V(0, dims.height / 2, 0),
        _Obj.jug => const _V(0, 2.5, 0),
        _Obj.spoon => _V.zero,
        _ => const _V(0, 0.5, 0),
      };

  /// Design point of a named place, for the flow tests: 'vessel', 'jug',
  /// 'spoon', `bowl_<material>`, 'table' (front of the table / counter),
  /// 'table_left' (empty table, away from the vessel) and 'shelf_right'
  /// (along the front of the shelf from the vessel's start: not the table).
  Offset anchor(String id) {
    final _V w;
    if (id.startsWith('bowl_')) {
      w = centre(_Obj.bowl(_Mat.values.byName(id.substring(5))));
    } else {
      w = switch (id) {
        'vessel' => centre(_Obj.vessel),
        'jug' => centre(_Obj.jug),
        'spoon' => centre(_Obj.spoon),
        'table' => const _V(0, 0, 3),
        'table_left' => const _V(-9, 0, 4),
        'shelf_right' => home(_Obj.vessel) + const _V(4, 2.25, 0),
        _ => throw ArgumentError.value(id, 'id'),
      };
    }
    return frame.toDesign(_proj.p(w));
  }

  void dispose() {
    pictures.dispose();
    text.dispose();
  }
}

/// Pan recognizer that only claims pointers that start on something the
/// learner can drag (decided by [canGrab]), so other drags still pan the
/// zoomed canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _SolubilityLabState
    extends State<Ch6A4ExploringMaterialPropertiesSolubilityInWaterPage>
    with SingleTickerProviderStateMixin {
  /// The HTML starts with the camera locked (`isCamLocked: true`).
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Sim _sim = _Sim();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Something changed since the last frame (repaint once).
  bool _dirty = true;

  /// Stage scale (screen px per design px) from the last layout.
  double _fit = 1;

  /// Scene label size in base px.
  double _labelSize = _labelPx;

  /// The object under the finger when a drag may start.
  _Obj? _pendingGrab;

  /// Last finger position of the current drag, in base px.
  Offset _lastFinger = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_sim.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _sim.reset(0);
    _ticker = createTicker(_onTick)..start();
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
    _sim.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()` + `TWEEN.update()`: runs the tweens and the view's
  /// re-framing; repaints only while something moves.
  void _onTick(Duration elapsed) {
    final s = _sim;
    s.time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    var moving = _dirty || s.held != null || s.animating;
    _dirty = false;
    if (s.stepFrame()) moving = true;
    s.runTweens();
    if (moving) _frame.value = s.time;
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(sc)` / Restart: cancels pending timers and
  /// rebuilds the bench for [scenario] at step 1.
  void _loadScenario(int scenario) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _pendingGrab = null;
    setState(() => _sim.reset(scenario));
    _dirty = true;
    _lab.resetView(sound: false);
  }

  void _showConclusion(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      delay: scenario == 0 ? _conclusionS1 : _conclusionS2,
      heading: () => scenario == 0
          ? labFormat(_t('sc_complete'), {'n': 1})
          : _t('all_complete'),
      body: () => _t(scenario == 0 ? 's1_summary' : 'all_complete_desc'),
    );
  }

  /// HUD line of the current step (HTML `hud[step]`).
  String get _hud {
    final n = _stepCounts[_sim.scenario];
    return _t('s${_sim.scenario + 1}_hud_${_sim.step.clamp(1, n)}');
  }

  /// Material name as the HTML shows it in toasts and buttons (upper case);
  /// [oblique] for a toast where Hindi puts a postposition after it.
  String _matName(_Mat m, {bool oblique = false}) =>
      _t(oblique ? '${m.key}_obl' : m.key).toUpperCase();

  void _toastNotYet() => _lab.showToast(
    labFormat(_t('toast_not_yet'), {'task': _hud}),
    isError: true,
  );

  /// Shows the inline alert [a] (HTML `showInlineAlert`): success tone and
  /// its title as a toast.
  void _showAlert(_Alert a) {
    _sim.alert = a;
    _Sound.correct.play();
    _lab.showToast(_t('${a.key}_title'), sound: false);
  }

  /// HTML `s1AnimateBowl` / `s2AnimateBowl`: the bowl moves above the
  /// vessel, tilts, pours a stream of its material and goes back to the
  /// shelf; [onLanded] runs when the material reaches the water.
  void _pourBowl(_Mat m, VoidCallback onLanded) {
    final s = _sim;
    final home = s.home(_Obj.bowl(m));
    final from = s.bowls[m]!;
    s.tween(
      _bowlMove,
      (t) => s.bowls[m] = _V.lerp(from, _pourPos, t),
      curve: Curves.easeOutQuad,
      onDone: () {
        s.tween(_tiltTime, (t) => s.tilts[m] = _pourTilt * t);
        s
          ..streamOn = true
          ..streamColor = m.color
          ..streamScale = 0.1;
        s.tween(_tiltTime, (t) => s.streamScale = 0.1 + 0.9 * t);
        s.wait(_pourHold, () {
          s.streamOn = false;
          onLanded();
          s.tween(_tiltTime, (t) => s.tilts[m] = _pourTilt * (1 - t));
          s.wait(
            _returnDelay,
            () => s.tween(
              _returnTime,
              (t) => s.bowls[m] = _V.lerp(_pourPos, home, t),
            ),
          );
        });
      },
    );
  }

  // ----------------------------------------------------- scenario 1 logic

  /// HTML `s1PlaceBeaker()`: the beaker slides onto the table.
  void _s1Place() {
    final s = _sim;
    if (s.scenario != 0 || s.phase != _Phase.place || s.busy) return;
    s.busy = true;
    _Sound.drop.play();
    _lab.showToast(_t('toast_beaker_placed'), sound: false);
    final from = s.vessel;
    s.tween(
      _placeTime,
      (t) => s.vessel = _V.lerp(from, _bench, t),
      curve: Curves.easeOutQuad,
      onDone: () {
        if (!mounted) return;
        setState(() {
          s
            ..busy = false
            ..phase = _Phase.ready
            ..step = 2;
        });
      },
    );
    setState(() {});
  }

  /// HTML `s1AddMaterial(mat)`: only the material whose turn it is. The
  /// step moves on once it has landed in the water (sugar -> 3, sand -> 5;
  /// salt, chalk and sawdust stay in step 6, where the HTML jumped back to
  /// step 5).
  void _s1Add(_Mat m) {
    final s = _sim;
    if (s.scenario != 0 || s.phase != _Phase.ready || s.busy || m != s.mat) {
      return;
    }
    s
      ..busy = true
      ..phase = _Phase.adding
      ..alert = null;
    _Sound.drop.play();
    _pourBowl(m, () {
      if (!mounted) return;
      setState(() {
        if (m == _Mat.sawdust) {
          s
            ..floating = true
            ..floatY = _floatRest;
        } else {
          s
            ..sediment = true
            ..sedimentColor = m.color
            ..sedimentWidth = 1
            ..sedimentHeight = 1;
        }
        s
          ..phase = _Phase.added
          ..busy = false;
        if (m == _Mat.sugar) s.step = 3;
        if (m == _Mat.sand) s.step = 5;
      });
      _lab.showToast(
        labFormat(_t('toast_mat_poured'), {'mat': _matName(m, oblique: true)}),
        sound: false,
      );
    });
    setState(() {});
  }

  /// HTML `s1Stir()`: 1.8 s of stirring, then the material's result and
  /// its inline alert. The step moves on when the result shows.
  void _s1Stir() {
    final s = _sim;
    if (s.scenario != 0 || s.phase != _Phase.added || s.busy) return;
    final m = s.mat;
    s
      ..busy = true
      ..phase = _Phase.stirring
      ..stirring = true;
    _Sound.pop.play();
    s.tween(
      _stirTime,
      (t) {
        final c = t * _stirTime * _stirRate;
        s.stirAngle = c;
        switch (m) {
          case _Mat.sugar:
          case _Mat.salt:
            final k = math.max(0.05, 1 - c / 25);
            s
              ..sedimentWidth = k
              ..sedimentHeight = k;
          case _Mat.sand:
            s.water = _Colors.murkyWater; // slight murky swirl
          case _Mat.chalk:
            s
              ..water = _Colors.chalkStir
              ..waterAlpha = math.min(0.95, 0.6 + c / 35);
          case _Mat.sawdust:
            s.floatY = 1.6 + math.sin(c) * 0.5;
        }
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          s.stirring = false;
          switch (m) {
            case _Mat.sugar:
            case _Mat.salt:
              s
                ..sediment = false
                ..water = _Colors.clearWater
                ..waterAlpha = 0.5; // crystal clear
            case _Mat.sand:
              s
                ..water = _Colors.water
                ..sedimentWidth = 1.1
                ..sedimentHeight = 1.2; // thick mound at the bottom
            case _Mat.chalk:
              s
                ..water = _Colors.chalkWater
                ..waterAlpha = 0.92; // very cloudy
            case _Mat.sawdust:
              s
                ..floatY = _floatRest
                ..water = _Colors.water;
          }
          _showAlert(_Alert.of(m));
          if (s.nextMat == null) {
            // Step 7. The sorting card takes the alert's place.
            s
              ..alert = null
              ..phase = _Phase.sorting
              ..step = 7;
            _lab.showToast(_t('toast_all_tested'), sound: false);
          } else {
            s
              ..phase = _Phase.stirred
              ..step = m == _Mat.sugar ? 4 : 6;
          }
          s.busy = false;
        });
      },
    );
    setState(() {});
  }

  /// HTML `btnNext.onclick`: fresh water for the next material.
  void _s1Reset() {
    final s = _sim;
    if (s.scenario != 0 || s.phase != _Phase.stirred || s.busy) return;
    setState(() {
      s
        ..alert = null
        ..sediment = false
        ..floating = false
        ..water = _Colors.water
        ..waterAlpha = _waterAlpha
        ..sedimentWidth = 1
        ..sedimentHeight = 1
        ..matIndex += 1
        ..phase = _Phase.ready;
      s.step = s.mat == _Mat.sand ? 4 : 6;
    });
    _dirty = true;
  }

  /// HTML `onDropBin(e, colType)`: only a drop on the right column counts
  /// (the HTML's canvas-wide drop handler also filed a wrong drop, and any
  /// drop outside the columns, as correct).
  void _classify(_Mat m, bool soluble) {
    final s = _sim;
    if (s.phase != _Phase.sorting) return;
    if (s.sorted.contains(m)) {
      _lab.showToast(_t('toast_already_classified'), sound: false);
      return;
    }
    if (m.soluble != soluble) {
      final col = _t(m.soluble ? 'col_soluble_name' : 'col_insoluble_name');
      setState(() => s.selected = null);
      _lab.showToast(
        labFormat(_t('toast_incorrect_col'), {
          'mat': _matName(m, oblique: true),
          'col': col,
        }),
        isError: true,
      );
      return;
    }
    setState(() {
      s
        ..sorted.add(m)
        ..selected = null;
    });
    _lab.showToast(
      labFormat(_t('toast_correct_classified'), {
        'mat': _matName(m, oblique: true),
        'n': s.sorted.length,
      }),
    );
    if (s.sorted.length == _Mat.values.length) {
      setState(() {
        s
          ..phase = _Phase.done
          ..step = _stepCounts[0] + 1;
      });
      _showConclusion(0);
    }
  }

  /// Tap on a sorting chip: selects it for a tap on a column (the touch
  /// version of the HTML's column click).
  void _selectChip(_Mat m) {
    final s = _sim;
    if (s.phase != _Phase.sorting) return;
    if (s.sorted.contains(m)) {
      _lab.showToast(_t('toast_already_classified'), sound: false);
      return;
    }
    _Sound.click.play();
    setState(() => s.selected = s.selected == m ? null : m);
  }

  void _tapColumn(bool soluble) {
    final m = _sim.selected;
    if (_sim.phase != _Phase.sorting) return;
    if (m == null) {
      _lab.showToast(_t('toast_pick_first'), sound: false);
      return;
    }
    _classify(m, soluble);
  }

  // ----------------------------------------------------- scenario 2 logic

  /// HTML `s2PlaceTumbler()`.
  void _s2Place() {
    final s = _sim;
    if (s.scenario != 1 || s.step != 1 || s.busy) return;
    s.busy = true;
    _Sound.drop.play();
    _lab.showToast(_t('toast_tumbler_placed'), sound: false);
    final from = s.vessel;
    s.tween(
      _placeTime,
      (t) => s.vessel = _V.lerp(from, _bench, t),
      curve: Curves.easeOutQuad,
      onDone: () {
        if (!mounted) return;
        setState(() {
          s
            ..busy = false
            ..step = 2;
        });
      },
    );
    setState(() {});
  }

  /// HTML `s2AddWater()`: the jug moves over the tumbler, tilts and fills
  /// it (the water rises from the bottom), then goes back.
  void _s2Water() {
    final s = _sim;
    if (s.scenario != 1 || s.step != 2 || s.busy) return;
    s.busy = true;
    _Sound.drop.play();
    final from = s.jug;
    s.tween(
      _jugMove,
      (t) => s.jug = _V.lerp(from, _jugPour, t),
      curve: Curves.easeOutQuad,
      onDone: () {
        s.tween(_tiltTime, (t) => s.jugTilt = _jugTilt * t);
        s
          ..waterOn = true
          ..waterLevel = 0.1;
        s.tween(_fillTime, (t) => s.waterLevel = 0.1 + 0.9 * t);
        s.wait(_jugHold, () {
          s.tween(_tiltTime, (t) => s.jugTilt = _jugTilt * (1 - t));
          s.tween(_jugMove, (t) => s.jug = _V.lerp(_jugPour, _jugHome, t));
          if (!mounted) return;
          _lab.showToast(_t('toast_water_poured'), sound: false);
          setState(() {
            s
              ..busy = false
              ..step = 3;
          });
        });
      },
    );
    setState(() {});
  }

  /// HTML `s2AddSugar()` / `s2AddSalt()` / `s2TestSand()`.
  void _s2AddBowl(_Mat m) {
    final s = _sim;
    final want = switch (s.step) {
      3 => _Mat.sugar,
      4 => _Mat.salt,
      6 => _Mat.sand,
      _ => null,
    };
    if (s.scenario != 1 || s.busy || m != want) return;
    s
      ..busy = true
      ..alert = null;
    _Sound.drop.play();
    _pourBowl(m, () {
      if (!mounted) return;
      setState(() {
        s
          ..sediment = true
          ..sedimentColor = m.color
          ..sedimentWidth = 1
          ..sedimentHeight = switch (m) {
            _Mat.sugar => 0.5,
            _Mat.salt => 0.8,
            _ => 1.2,
          };
        s.busy = false;
        if (m == _Mat.sand) {
          s.step = _stepCounts[1] + 1;
          _showAlert(_Alert.sandOrs);
          _showConclusion(1);
        } else {
          s.step += 1;
          _lab.showToast(
            _t(m == _Mat.sugar ? 'toast_sugar_added' : 'toast_salt_added'),
            sound: false,
          );
        }
      });
    });
    setState(() {});
  }

  /// HTML `s2Stir()`: the spoon stirs for 1.8 s, then the sugar and salt
  /// dissolve (400 ms) into a clear ORS.
  void _s2Stir() {
    final s = _sim;
    if (s.scenario != 1 || s.step != 5 || s.busy) return;
    s
      ..busy = true
      ..alert = null
      ..stirring = true
      ..spoonInUse = true
      ..spoon = _spoonHome;
    _Sound.pop.play();
    s.tween(
      _stirTime,
      (t) => s.stirAngle = t * _stirTime * _stirRate,
      onDone: () {
        s.stirring = false;
        final w = s.sedimentWidth, h = s.sedimentHeight;
        s.tween(_dissolveTime, (t) {
          s
            ..sedimentWidth = w + (0.1 - w) * t
            ..sedimentHeight = h + (0.1 - h) * t;
        }, onDone: () => s.sediment = false);
        if (!mounted) return;
        setState(() {
          s
            ..spoonInUse = false
            ..busy = false
            ..step = 6;
          _showAlert(_Alert.ors);
        });
      },
    );
    setState(() {});
  }

  // ---------------------------------------------------------- interaction

  /// The object the current step wants dragged (or tapped).
  _Obj? get _target {
    final s = _sim;
    if (s.scenario == 0) {
      return switch (s.phase) {
        _Phase.place => _Obj.vessel,
        _Phase.ready => _Obj.bowl(s.mat),
        _ => null,
      };
    }
    return switch (s.step) {
      1 => _Obj.vessel,
      2 => _Obj.jug,
      3 => _Obj.sugar,
      4 => _Obj.salt,
      5 => _Obj.spoon,
      6 => _Obj.sand,
      _ => null,
    };
  }

  /// Runs the step's action for [o] (a tap on it, or a good drop).
  void _perform(_Obj o) {
    final s = _sim;
    final m = o.mat;
    if (s.scenario == 0) {
      if (o == _Obj.vessel) {
        _s1Place();
      } else if (m != null) {
        _s1Add(m);
      }
      return;
    }
    switch (o) {
      case _Obj.vessel:
        s.step == 1 ? _s2Place() : _s2Stir();
      case _Obj.jug:
        _s2Water();
      case _Obj.spoon:
        _s2Stir();
      default:
        if (m != null) _s2AddBowl(m);
    }
  }

  /// The scenario has ended (classification done / sand tested).
  bool get _finished {
    final s = _sim;
    return s.scenario == 0
        ? s.phase == _Phase.sorting || s.phase == _Phase.done
        : s.step > _stepCounts[1];
  }

  /// Can [o] be picked up now? (Wrong objects can be, and slide back with
  /// a hint.)
  bool _grabbable(_Obj o) {
    final s = _sim;
    if (!s.has(o) || _finished) return false;
    if (o == _Obj.vessel) {
      return s.scenario == 0 ? s.phase == _Phase.place : s.step == 1;
    }
    return true;
  }

  /// Screen dp per base px (stage scale, canvas zoom and framing).
  double get _dpPerBase =>
      _fit * _lab.transform.value.getMaxScaleOnAxis() * _sim.frame.zoom;

  /// Bounding box of the projected box around [c] (half sizes, from the
  /// bottom up).
  static Rect _projBox(_V c, double hx, double h, double hz) {
    var rect = Rect.zero;
    var first = true;
    for (final x in [-hx, hx]) {
      for (final y in [0.0, h]) {
        for (final z in [-hz, hz]) {
          final o = _proj.p(c + _V(x, y, z));
          rect = first
              ? Rect.fromLTWH(o.dx, o.dy, 0, 0)
              : rect.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0));
          first = false;
        }
      }
    }
    return rect;
  }

  /// Touch box of [o] in base px, at least [_minTouch] dp each way.
  Rect _hitRect(_Obj o) {
    final s = _sim;
    final c = s.pos(o);
    // The meshes' extents (HTML geometries): glass, jug body (r 2.2 x 5),
    // spoon (added, 3.6 long), bowl with its heap (r 1.2, 1.0 tall).
    final rect = switch (o) {
      _Obj.vessel => _projBox(
        c,
        s.dims.rTop + _hitMargin,
        s.dims.height + _hitMargin,
        s.dims.rTop + _hitMargin,
      ),
      _Obj.jug => _projBox(c, 2.2, 5, 2.2),
      _Obj.spoon => _projBox(c + const _V(0.1, -0.12, 0), 1.9, 0.4, 0.5),
      _ => _projBox(c, 1.2 + _hitMargin, 1.0 + _hitMargin, 1.2 + _hitMargin),
    };
    final min = _minTouch / math.max(0.01, _dpPerBase);
    final gx = math.max(0.0, min - rect.width) / 2;
    final gy = math.max(0.0, min - rect.height) / 2;
    return Rect.fromLTRB(
      rect.left - gx,
      rect.top - gy,
      rect.right + gx,
      rect.bottom + gy,
    );
  }

  /// Drop zone of the vessel: its glass and the air above it up to just
  /// over the pour position (not as high as the shelf, so a bowl nudged on
  /// the shelf above the beaker does not count as poured).
  Rect _dropRect() {
    final r = _sim.dims.rTop + _dropMargin;
    return _projBox(_sim.vessel, r, _dropTop, r).inflate(_dropSlack);
  }

  bool _overVessel(Offset finger, _Obj o) {
    final zone = _dropRect();
    return zone.contains(finger) || zone.contains(_proj.p(_sim.centre(o)));
  }

  static const List<_Obj> _hitOrder = [
    _Obj.vessel,
    _Obj.spoon,
    _Obj.jug,
    _Obj.sugar,
    _Obj.sand,
    _Obj.salt,
    _Obj.chalk,
    _Obj.sawdust,
  ];

  /// The object at [base] (the step's own object first).
  _Obj? _objectAt(Offset base, {required bool forTap}) {
    final s = _sim;
    if (_finished) return null;
    bool ok(_Obj o) => forTap ? s.has(o) : _grabbable(o);
    final want = _target;
    if (want != null && ok(want) && _hitRect(want).contains(base)) return want;
    for (final o in _hitOrder) {
      if (ok(o) && _hitRect(o).contains(base)) return o;
    }
    return null;
  }

  bool _canGrab(PointerDownEvent event) {
    final s = _sim;
    _pendingGrab = null;
    if (!_lab.isLabActive || s.busy || s.held != null || _lab.popup != null) {
      return false;
    }
    _pendingGrab = _objectAt(
      s.frame.toBase(event.localPosition),
      forTap: false,
    );
    return _pendingGrab != null;
  }

  void _dragStart(DragStartDetails d) {
    final s = _sim;
    final o = _pendingGrab;
    if (o == null || s.busy) return;
    final finger = s.frame.toBase(d.localPosition);
    s
      ..held = o
      ..heldZ = s.pos(o).z
      ..grabDelta = _proj.p(s.pos(o)) - finger
      ..overTarget = false;
    _lastFinger = finger;
    _dirty = true;
    _Audio.play(_Sound.pickup);
  }

  /// The held object follows the finger on the upright plane through its
  /// start (z fixed); once that would put it below the table top it slides
  /// on the table instead (ray-plane intersections, HTML Raycaster).
  void _dragUpdate(DragUpdateDetails d) {
    final s = _sim;
    final o = s.held;
    if (o == null) return;
    final finger = s.frame.toBase(d.localPosition);
    _lastFinger = finger;
    final target = finger + s.grabDelta;
    final floor = o == _Obj.spoon ? _spoonHome.y : 0.0;
    var w = _proj.onPlaneZ(target, s.heldZ);
    if (w == null || w.y < floor) w = _proj.onPlaneY(target, floor);
    w ??= s.pos(o);
    s.setPos(
      o,
      _V(
        w.x.clamp(-_carryX, _carryX),
        w.y.clamp(floor, _carryTop),
        w.z.clamp(_carryBack, _carryFront),
      ),
    );
    s.overTarget = o != _Obj.vessel && o == _target && _overVessel(finger, o);
    _dirty = true;
  }

  void _dragEnd(DragEndDetails _) {
    final s = _sim;
    final o = s.held;
    if (o == null) return;
    s
      ..held = null
      ..overTarget = false;
    _dirty = true;
    _release(o, _lastFinger);
  }

  void _dragCancel() {
    final o = _sim.held;
    if (o == null) return;
    _sim
      ..held = null
      ..overTarget = false;
    _springBack(o);
  }

  /// A drop: the step's object on its target runs the step; anything else
  /// slides back with a hint (the HTML accepted a drop anywhere on the
  /// canvas).
  void _release(_Obj o, Offset finger) {
    final s = _sim;
    if (o != _target) {
      _springBack(o);
      _toastNotYet();
      return;
    }
    if (o == _Obj.vessel) {
      final p = s.vessel;
      if (p.y <= 0.01 && p.z > _shelfFront) {
        _perform(o);
      } else {
        _springBack(o);
        _lab.showToast(
          _t(s.scenario == 0 ? 'toast_drop_table' : 'toast_drop_counter'),
          isError: true,
        );
      }
      return;
    }
    if (_overVessel(finger, o)) {
      _perform(o);
    } else {
      _springBack(o);
      _lab.showToast(
        _t(s.scenario == 0 ? 'toast_drop_beaker' : 'toast_drop_tumbler'),
        isError: true,
      );
    }
  }

  /// A refused drop slides back to where the object stood (the step's
  /// button waits meanwhile, so two tweens never move the same object).
  void _springBack(_Obj o) {
    final s = _sim;
    final from = s.pos(o);
    final home = s.home(o);
    setState(() => s.busy = true);
    s.tween(
      _springTime,
      (t) => s.setPos(o, _V.lerp(from, home, t)),
      curve: Curves.easeOutQuad,
      onDone: () {
        if (mounted) setState(() => s.busy = false);
      },
    );
    _dirty = true;
  }

  /// HTML raycast clicks: the step's object runs the step (the tumbler also
  /// stirs in step 5); another object shows a hint.
  void _onTapUp(TapUpDetails d) {
    final s = _sim;
    if (!_lab.isLabActive || s.busy || s.held != null || _lab.popup != null) {
      return;
    }
    final o = _objectAt(s.frame.toBase(d.localPosition), forTap: true);
    if (o == null) return;
    final stirTap = s.scenario == 1 && s.step == 5 && o == _Obj.vessel;
    if (o == _target || stirTap) {
      _perform(o);
    } else {
      _toastNotYet();
    }
  }

  // ------------------------------------------------------------------- UI

  LabAction _action(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    bool enabled = true,
    bool silent = true,
  }) {
    final on = enabled && !_sim.busy;
    return LabAction(
      label: label,
      icon: icon,
      onTap: onTap,
      color: color,
      foreground: color == null ? null : _Colors.white,
      enabled: on,
      highlight: on,
      silent: silent,
    );
  }

  /// HTML `#controls-banner` buttons for the current state (the drag chips
  /// become objects in the scene; these are their tap versions).
  List<LabAction> _actions() {
    final s = _sim;
    if (s.scenario == 0) {
      switch (s.phase) {
        case _Phase.place:
          return [_action(_t('btn_place_beaker'), Icons.science, _s1Place)];
        case _Phase.ready:
          final m = s.mat;
          return [
            _action(
              _t(m.key),
              Icons.add_circle,
              () => _s1Add(m),
              color: m.fill,
            ),
          ];
        case _Phase.adding:
          return [
            _action(_t('btn_stir'), Icons.autorenew, _s1Stir, enabled: false),
          ];
        case _Phase.added:
          return [_action(_t('btn_stir'), Icons.autorenew, _s1Stir)];
        case _Phase.stirred:
          final next = s.nextMat;
          if (next == null) return const [];
          return [
            _action(
              labFormat(_t('btn_next_mat'), {'mat': _matName(next)}),
              Icons.restart_alt,
              _s1Reset,
              color: _Colors.emerald600,
              silent: false,
            ),
          ];
        case _Phase.stirring:
        case _Phase.sorting:
        case _Phase.done:
          return const [];
      }
    }
    final (String key, IconData icon, Color color, VoidCallback onTap)? a =
        switch (s.step) {
          1 => ('item_tumbler', Icons.local_drink, _Colors.blue600, _s2Place),
          2 => ('item_jug', Icons.water_drop, _Colors.blue500, _s2Water),
          3 => (
            'item_sugar_bowl',
            Icons.add_circle,
            _Colors.indigo600,
            () => _s2AddBowl(_Mat.sugar),
          ),
          4 => (
            'item_salt_bowl',
            Icons.add_circle,
            _Colors.slate600,
            () => _s2AddBowl(_Mat.salt),
          ),
          5 => ('item_stir_spoon', Icons.autorenew, _Colors.amber700, _s2Stir),
          6 => (
            'item_sand_bowl',
            Icons.add_circle,
            _Colors.amber700,
            () => _s2AddBowl(_Mat.sand),
          ),
          _ => null,
        };
    if (a == null) return const [];
    return [_action(_t(a.$1), a.$2, a.$4, color: a.$3)];
  }

  /// Width of the canvas area (screen minus the open sidebar).
  double _canvasWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (!_lab.isSidebarOpen) return w;
    final min = math.max(180.0, w * 0.2);
    final max = math.max(min, w * 0.5);
    return w - (w * _lab.sidebarFraction).clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final sim = _sim;
        final sc = sim.scenario;
        final data = _data;
        final size = MediaQuery.sizeOf(context);
        final inset = labOverlayInsets(context, _lab);
        final room = math.max(
          0.0,
          _canvasWidth(context) - inset.left - inset.right,
        );
        final top = inset.top + _toastBand * s;
        final bottom = inset.bottom + (_lab.isSidebarOpen ? _hudBand * s : 0.0);
        final avail = math.max(96.0, size.height - top - bottom);
        final alert = sim.alert;
        final alertWidth = math.min(room, (room * 0.42).clamp(170.0, 300 * s));
        // Room below the floating mission card (sidebar collapsed).
        final belowMission = math.max(
          72.0,
          size.height -
              inset.bottom -
              _missionTop -
              size.height * _missionMaxHeight -
              2 * _edge,
        );
        return LabShell(
          controller: _lab,
          icon: Icons.water_drop,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sim.step,
          hud: _hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-${sim.step}'),
            steps: data.steps,
            current: sim.step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
            pendingText: _t('obs_pending'),
          ),
          overlays: [
            // HTML `#inline-alert`. Sidebar open: Scenario 1 at the top
            // right (over the shelf's right end, not needed until 'Reset
            // Water' hides it), Scenario 2 at the top left (clear of the
            // sand bowl that step 6 needs). Sidebar collapsed: the scene
            // sits right of the mission card, so the card goes below the
            // mission card, at the bottom left.
            if (alert != null && _lab.isLabActive)
              if (_lab.isSidebarOpen)
                Positioned(
                  key: const ValueKey('ch6a4-alert'),
                  top: top,
                  left: sc == 1 ? inset.left : null,
                  right: sc == 0 ? inset.right : null,
                  child: SizedBox(
                    width: alertWidth,
                    child: _alertCard(alert, s, avail * 0.62),
                  ),
                )
              else
                Positioned(
                  key: const ValueKey('ch6a4-alert'),
                  left: _edge + MediaQuery.paddingOf(context).left,
                  bottom: inset.bottom,
                  child: SizedBox(
                    width: _missionCardWidth(size, s),
                    child: _alertCard(alert, s, belowMission),
                  ),
                ),
            // HTML `#s1-sort-area` (step 7).
            if (sc == 0 && sim.phase == _Phase.sorting && _lab.isLabActive)
              Positioned(
                key: const ValueKey('ch6a4-sort'),
                top: top,
                left: inset.left,
                right: inset.right,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: math.min(room, 540 * s),
                    child: _SortCard(
                      palette: p,
                      scale: s,
                      maxHeight: avail,
                      prompt: _t('sort_prompt'),
                      solubleTitle: _t('col_soluble'),
                      insolubleTitle: _t('col_insoluble'),
                      names: {for (final m in _Mat.values) m: _t(m.key)},
                      sorted: sim.sorted,
                      selected: sim.selected,
                      onSelect: _selectChip,
                      onDrop: _classify,
                      onColumnTap: _tapColumn,
                    ),
                  ),
                ),
              ),
          ],
          stage: _buildStage(),
        );
      },
    );
  }

  Widget _alertCard(_Alert a, double s, double maxHeight) => _AlertCard(
    icon: a.icon,
    title: _t('${a.key}_title'),
    body: _t('${a.key}_desc'),
    scale: s,
    maxHeight: maxHeight,
  );

  /// Where the base projection goes on the stage: [_content] fits into the
  /// part of the canvas left free by the toast row, the HUD chip, the tool
  /// column and (sidebar collapsed) the floating mission card, beside it or
  /// below it, whichever gives the bigger view.
  _Frame _frameFor(BuildContext context, Size canvas, double fit) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final s = context.labScale;
    final stage = Offset(
      (canvas.width - _design.width * fit) / 2,
      (canvas.height - _design.height * fit) / 2,
    );
    final right = canvas.width - _toolColumn - pad.right;
    final top = _toastTop + pad.top + _toastBand * s;
    final bottom =
        canvas.height -
        pad.bottom -
        _edge -
        (_lab.isSidebarOpen ? _hudBand * s : 0);
    final regions = <Rect>[
      if (_lab.isSidebarOpen)
        Rect.fromLTRB(_edge, top, right, bottom)
      else ...[
        Rect.fromLTRB(
          _missionLeft + pad.left + _missionCardWidth(size, s) + _edge,
          top,
          right,
          bottom,
        ),
        Rect.fromLTRB(
          _edge,
          math.max(
            top,
            _missionTop + pad.top + size.height * _missionMaxHeight + _edge,
          ),
          right,
          bottom,
        ),
      ],
    ];
    _Frame? best;
    for (final r in regions) {
      final d = Rect.fromLTRB(
        (r.left - stage.dx) / fit,
        (r.top - stage.dy) / fit,
        (r.right - stage.dx) / fit,
        (r.bottom - stage.dy) / fit,
      ).intersect(Offset.zero & _design);
      if (d.width <= 0 || d.height <= 0) continue;
      final zoom = math
          .min(d.width / _content.width, d.height / _content.height)
          .clamp(_minZoom, _maxZoom);
      if (best == null || zoom > best.zoom) {
        best = _Frame(zoom, d.center - _content.center * zoom);
      }
    }
    return best ?? _Frame.identity;
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _fit = fit;
          _sim.setFrameTarget(_frameFor(context, box.biggest, fit));
          final k = fit * _sim.frameTarget.zoom;
          _labelSize =
              _labelPx * (_labelFullScale / k).clamp(1.0, _labelMaxBoost);
        }
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags and taps on the scene are not screen-reader actions; the
            // sidebar's buttons do the same things.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      // Small slop: a short drag grabs the object before the
                      // zoom viewer claims it (RawGestureDetector ignores
                      // MediaQuery's gesture settings).
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _touchSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _dragStart
                      ..onUpdate = _dragUpdate
                      ..onEnd = _dragEnd
                      ..onCancel = _dragCancel,
                  ),
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
                  ),
            },
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  sim: _sim,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  labelSize: _labelSize,
                  target: _target,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// HTML `#inline-alert`: icon, amber title and the observation, on the
/// HTML's dark blue gradient in both themes.
class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.scale,
    required this.maxHeight,
  });

  final IconData icon;
  final String title;
  final String body;
  final double scale;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_Colors.alertStart, _Colors.alertMid, _Colors.alertEnd],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Colors.alertBorder, width: 2),
        boxShadow: const [BoxShadow(color: LabInk.shadow, blurRadius: 14)],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18 * s, color: _Colors.amber400),
                SizedBox(width: 6 * s),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _Colors.amber400,
                      fontSize: 12.5 * s,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5 * s),
            Text(
              body,
              style: TextStyle(
                color: _Colors.slate100,
                fontSize: 11 * s,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HTML `#s1-sort-area`: the five material chips and the Soluble /
/// Insoluble columns. Chips are dragged onto a column, or tapped and then
/// a column tapped.
class _SortCard extends StatelessWidget {
  const _SortCard({
    required this.palette,
    required this.scale,
    required this.maxHeight,
    required this.prompt,
    required this.solubleTitle,
    required this.insolubleTitle,
    required this.names,
    required this.sorted,
    required this.selected,
    required this.onSelect,
    required this.onDrop,
    required this.onColumnTap,
  });

  final LabPalette palette;
  final double scale;
  final double maxHeight;
  final String prompt;
  final String solubleTitle;
  final String insolubleTitle;
  final Map<_Mat, String> names;
  final Set<_Mat> sorted;
  final _Mat? selected;
  final ValueChanged<_Mat> onSelect;
  final void Function(_Mat m, bool soluble) onDrop;
  final ValueChanged<bool> onColumnTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _Colors.amber500.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: LabInk.shadow, blurRadius: 16)],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.back_hand, size: 14 * s, color: p.accentInk),
                SizedBox(width: 5 * s),
                Expanded(
                  child: Text(
                    prompt.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.accentInk,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(prompt, 0.8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6 * s),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6 * s,
              runSpacing: 6 * s,
              children: [for (final m in _Mat.values) _chip(m)],
            ),
            SizedBox(height: 8 * s),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _column(context, true)),
                  SizedBox(width: 8 * s),
                  Expanded(child: _column(context, false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipBody(_Mat m, {bool lifted = false, bool ghost = false}) {
    final s = scale;
    final done = sorted.contains(m);
    final picked = selected == m;
    final fill = done ? _Colors.emerald600 : m.fill;
    final dim = ghost ? 0.35 : (done ? 0.6 : 1.0);
    return Container(
      constraints: const BoxConstraints(minHeight: _minTouch, minWidth: 64),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: 0.85 * dim),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: picked ? _Colors.white : fill.withValues(alpha: dim),
          width: picked ? 2.5 : 1,
        ),
        boxShadow: [
          if (lifted || picked)
            BoxShadow(color: fill.withValues(alpha: 0.6), blurRadius: 12 * s),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.drag_indicator,
            size: 15 * s,
            color: _Colors.white.withValues(alpha: dim),
          ),
          SizedBox(width: 4 * s),
          Flexible(
            child: Text(
              names[m]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _Colors.white.withValues(alpha: dim),
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(_Mat m) {
    final key = ValueKey('ch6a4-chip-${m.name}');
    final tap = Material(
      color: LabInk.clear,
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * scale),
        onTap: () => onSelect(m),
        child: _chipBody(m),
      ),
    );
    if (sorted.contains(m)) return KeyedSubtree(key: key, child: tap);
    return Draggable<_Mat>(
      key: key,
      data: m,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: _chipBody(m, lifted: true),
        ),
      ),
      childWhenDragging: _chipBody(m, ghost: true),
      child: tap,
    );
  }

  Widget _column(BuildContext context, bool soluble) {
    final s = scale;
    final title = soluble ? solubleTitle : insolubleTitle;
    final edge = soluble ? _Colors.amber400 : _Colors.slate400;
    final items = [
      for (final m in _Mat.values)
        if (sorted.contains(m) && m.soluble == soluble) names[m]!,
    ];
    return DragTarget<_Mat>(
      key: ValueKey('ch6a4-bin-${soluble ? 'soluble' : 'insoluble'}'),
      onWillAcceptWithDetails: (d) => !sorted.contains(d.data),
      onAcceptWithDetails: (d) => onDrop(d.data, soluble),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        return Material(
          color: LabInk.clear,
          child: InkWell(
            borderRadius: BorderRadius.circular(12 * s),
            onTap: () => onColumnTap(soluble),
            child: Container(
              constraints: const BoxConstraints(minHeight: _minTouch + 8),
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: soluble ? _Colors.solubleBin : _Colors.insolubleBin,
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(
                  color: hot ? _Colors.white : edge.withValues(alpha: 0.85),
                  width: hot ? 2.5 : 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        soluble ? Icons.water_drop : Icons.landscape,
                        size: 15 * s,
                        color: edge,
                      ),
                      SizedBox(width: 4 * s),
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _Colors.white,
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (items.isNotEmpty) ...[
                    SizedBox(height: 4 * s),
                    Text(
                      items.join(', '),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _Colors.emerald400,
                        fontSize: 10.5 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// HTML teacher-board "Conceptual Exploration" accordion: one card per
/// step with its concept, action and observation. The current step is
/// open, done steps show a tick and can be re-opened, future steps are
/// dimmed. A step's observation is shown once the step is done (the HTML
/// showed it before the learner had seen it).
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
    // Future steps: dimmed, not openable.
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
                  _body(step.concept, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(past ? step.observation : w.pendingText, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

// Lighting (HTML: AmbientLight 0.75, DirectionalLight 0xfff8e7 0.95 at
// (15, 30, 20)), toned down so lit colours stay recognisable without tone
// mapping.
const _V _keyDir = _V(0.3841, 0.7682, 0.5121); // (15, 30, 20) normalised
const double _ambient = 0.62;
const double _keyGain = 0.5;

/// Segments of a projected cylinder ring.
const int _ringSegments = 28;

/// Label chip geometry, in multiples of the label text size: the gap to the
/// object (and between the two shelf rows), line height, and total
/// vertical / horizontal padding.
const double _labelGap = 0.35;
const double _labelLine = 1.2;
const double _labelPadV = 0.6;
const double _labelPadH = 1.1;

/// Top of a bowl's heap (body 0.8 tall, heap up to 1.0) plus a hair.
const double _bowlTop = 1.05;

/// Amber halo radius around the object the step needs (world units, about
/// the object's size).
const double _bowlHalo = 1.6;
const double _jugHalo = 2.6;
const double _spoonHalo = 1.4;

/// Flat-shaded colour of a face with normal [n].
Color _lit(Color c, _V n) {
  final i = _ambient + _keyGain * math.max(0.0, n.dot(_keyDir));
  return Color.from(
    alpha: c.a,
    red: (c.r * i).clamp(0.0, 1.0),
    green: (c.g * i).clamp(0.0, 1.0),
    blue: (c.b * i).clamp(0.0, 1.0),
  );
}

/// A box face: outward normal and its corners as signs of the half size.
@immutable
class _Face {
  const _Face(this.n, this.corners);
  final _V n;
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

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  final upper = <Offset>[];
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

/// Static layers (table, shelf) recorded once in base coordinates and
/// replayed every frame under the current framing.
class _Pictures {
  final Map<String, ui.Picture> _map = {};

  ui.Picture get(String key, void Function(_Draw d) paint) {
    final cached = _map[key];
    if (cached != null) return cached;
    final recorder = ui.PictureRecorder();
    final d = _Draw()..canvas = Canvas(recorder);
    paint(d);
    return _map[key] = recorder.endRecording();
  }

  void dispose() {
    for (final p in _map.values) {
      p.dispose();
    }
    _map.clear();
  }
}

/// Laid-out label text reused across frames.
class _TextCache {
  final Map<String, TextPainter> _map = {};
  static const int _maxEntries = 48;

  TextPainter get(String text, double size) {
    final key = '$text|${size.toStringAsFixed(1)}';
    final cached = _map[key];
    if (cached != null) return cached;
    if (_map.length >= _maxEntries) dispose();
    return _map[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w700,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void dispose() {
    for (final tp in _map.values) {
      tp.dispose();
    }
    _map.clear();
  }
}

/// Mesh drawing in the base projection with reused Paints, Path and lists.
class _Draw {
  late Canvas canvas;

  final Paint fill = Paint();
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();
  final List<Offset> _ring = [];
  final List<Offset> _all = [];

  Offset p(_V w) => _proj.p(w);

  /// Fills with [shader]; the paint colour stays opaque so its alpha does
  /// not dim the shader.
  void shade(Shader shader) {
    fill
      ..color = _Colors.black
      ..shader = shader;
  }

  void fillPath(Color c, {double opacity = 1}) {
    fill
      ..shader = null
      ..color = c.withValues(alpha: c.a * opacity);
    canvas.drawPath(path, fill);
  }

  void strokePath(Color c, double width, {double opacity = 1}) {
    line
      ..color = c.withValues(alpha: c.a * opacity)
      ..strokeWidth = width;
    canvas.drawPath(path, line);
  }

  /// Sets [path] to the projected ring of radius [r] at [c] (y fixed).
  void ring(_V c, double r) {
    path.reset();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final o = p(_V(c.x + r * math.cos(a), c.y, c.z + r * math.sin(a)));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    path.close();
  }

  /// Soft contact shadow of radius [r] on the surface at [c].
  void shadow(_V c, double r, {double opacity = 0.35}) {
    ring(c + const _V(0, 0.01, 0), r);
    soft.color = _Colors.black.withValues(alpha: opacity);
    canvas.drawPath(path, soft);
  }

  /// Three.js BoxGeometry centred at [c]: visible faces, flat shaded, with
  /// lighter top edges so dark tables read against the dark background.
  void box(_V c, _V size, Color color, {Color? edge}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.n;
      final fc = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(_proj.eye - fc) <= 0) continue;
      path.reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        final o = p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz));
        i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      path.close();
      fillPath(_lit(color, n));
      strokePath(edge ?? labShade(color, 0.25), 1.2, opacity: 0.8);
    }
  }

  /// A Three.js CylinderGeometry (or frustum) at local centre [c] of the
  /// group [xf]: silhouette shaded across, plus the top cap when it faces
  /// the camera.
  void frustum(
    _Xf xf,
    _V c,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    double opacity = 1,
    Color? cap,
    bool drawCap = true,
    bool lit = true,
  }) {
    _ring.clear();
    _all.clear();
    final yTop = c.y + h / 2, yBottom = c.y - h / 2;
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final ca = math.cos(a), sa = math.sin(a);
      final t = p(xf(_V(c.x + rTop * ca, yTop, c.z + rTop * sa)));
      _ring.add(t);
      _all
        ..add(t)
        ..add(p(xf(_V(c.x + rBottom * ca, yBottom, c.z + rBottom * sa))));
    }
    Color side(_V n) => (lit ? _lit(color, n.rotZ(xf.rotZ)) : color).withValues(
      alpha: color.a * opacity,
    );
    final r = math.max(rTop, rBottom);
    final left = p(xf(_V(c.x - r, c.y, c.z)));
    final right = p(xf(_V(c.x + r, c.y, c.z)));
    path
      ..reset()
      ..addPolygon(_hull(_all), true);
    if ((right - left).distance > 0.5) {
      shade(
        ui.Gradient.linear(
          left,
          right,
          [
            side(const _V(-1, 0, 0)),
            side(const _V(-0.7, 0, 0.7)),
            side(const _V(0, 0, 1)),
            side(const _V(0.7, 0, 0.7)),
            side(const _V(1, 0, 0)),
          ],
          const [0, 0.25, 0.5, 0.75, 1],
        ),
      );
      canvas.drawPath(path, fill);
      fill.shader = null;
    } else {
      fillPath(side(const _V(0, 0, 1)));
    }
    if (!drawCap) return;
    final capCentre = xf(_V(c.x, yTop, c.z));
    if (xf.up.dot(_proj.eye - capCentre) <= 0) return;
    path
      ..reset()
      ..addPolygon(_ring, true);
    fillPath(cap ?? (lit ? _lit(color, xf.up) : color), opacity: opacity);
  }

  /// The visible top of a squashed hemisphere (a heap of powder) of radius
  /// [r] on local [base], from latitude 30° up: the part above a bowl rim.
  void heap(_Xf xf, _V base, double r, double yScale, Color color) {
    _all.clear();
    const lats = 4, longs = 20;
    for (var la = 0; la <= lats; la++) {
      final th = math.pi / 6 + la * (math.pi / 3) / lats;
      final rr = r * math.cos(th);
      final y = base.y + r * math.sin(th) * yScale;
      for (var i = 0; i < longs; i++) {
        final a = i * 2 * math.pi / longs;
        _all.add(
          p(xf(_V(base.x + rr * math.cos(a), y, base.z + rr * math.sin(a)))),
        );
      }
    }
    final top = p(xf(_V(base.x, base.y + r * yScale, base.z)));
    final front = p(xf(_V(base.x, base.y, base.z + r)));
    path
      ..reset()
      ..addPolygon(_hull(_all), true);
    shade(
      ui.Gradient.linear(top, front, [
        labShade(color, 0.15),
        _lit(color, const _V(0, 0.7, 0.7)),
      ]),
    );
    canvas.drawPath(path, fill);
    fill.shader = null;
  }

  /// A round rod between [a] and [b] (stirring rods, the spoon handle).
  void rod(_V a, _V b, double radius, Color color) {
    final pa = p(a), pb = p(b);
    final w = 2 * radius * _proj.scaleAt(_V.lerp(a, b, 0.5));
    line
      ..color = _lit(color, const _V(0, 0.5, 0.86))
      ..strokeWidth = math.max(1.5, w);
    canvas.drawLine(pa, pb, line);
    line
      ..color = _Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = math.max(0.8, w * 0.3);
    final n = Offset(-(pb - pa).dy, (pb - pa).dx);
    final k = n.distance == 0 ? Offset.zero : n / n.distance * (w * 0.2);
    canvas.drawLine(pa - k, pb - k, line);
  }

  /// Transparent glass wall: side lines, rim, front of the base and a
  /// highlight stripe (drawn over the vessel's contents).
  void glass(_Xf xf, double rTop, double rBottom, double h, Color color) {
    line
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.6;
    canvas
      ..drawLine(p(xf(_V(-rBottom, 0, 0))), p(xf(_V(-rTop, h, 0))), line)
      ..drawLine(p(xf(_V(rBottom, 0, 0))), p(xf(_V(rTop, h, 0))), line);
    ring(xf(_V(0, h, 0)), rTop);
    strokePath(color, 1.6, opacity: 0.7);
    path.reset();
    for (var i = 0; i <= _ringSegments ~/ 2; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final o = p(xf(_V(rBottom * math.cos(a), 0, rBottom * math.sin(a))));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    strokePath(color, 1.4, opacity: 0.5);
    line
      ..color = _Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 3;
    canvas.drawLine(
      p(xf(_V(-rBottom * 0.62, 0.4, rBottom * 0.78))),
      p(xf(_V(-rTop * 0.62, h - 0.4, rTop * 0.78))),
      line,
    );
  }
}

/// Paints the HTML's two Three.js scenes: the lab table with the shelf of
/// material bowls (Scenario 1) and the kitchen counter (Scenario 2).
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.sim,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.target,
  }) : super(repaint: repaint);

  final _Sim sim;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  /// Label text size in base px.
  final double labelSize;

  /// The object the current step needs: glowing, with an amber label.
  final _Obj? target;

  static final Paint _bg = Paint();
  static final Paint _chipFill = Paint()..color = _Colors.labelBg;
  static final Paint _chipBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  static final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = _Colors.emerald400;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _bg.color = isDark ? _Colors.canvasDark : _Colors.canvasLight;
    canvas.drawRect(labBleed(size), _bg);
    final f = sim.frame;
    canvas
      ..save()
      ..translate(f.offset.dx, f.offset.dy)
      ..scale(f.zoom);
    final d = sim.draw..canvas = canvas;
    canvas.drawPicture(
      sim.pictures.get(
        'bench-${sim.scenario}',
        sim.scenario == 0 ? _labBench : _kitchenBench,
      ),
    );
    _paintScene(d);
    if (showLabels) _paintLabels(d);
    canvas.restore();
  }

  /// HTML buildS1: lab table 26 x 0.8 x 16 and the shelf 22 x 0.5 x 3.
  static void _labBench(_Draw d) {
    d.box(
      const _V(0, -0.4, 0),
      const _V(26, 0.8, 16),
      _Colors.labTable,
      edge: _Colors.tableEdge,
    );
    d.box(const _V(0, 6, _shelfZ), const _V(22, 0.5, 3), _Colors.labShelf);
  }

  /// HTML buildS2: kitchen counter 26 x 0.8 x 16 and the shelf 20 x 0.5 x 3.
  static void _kitchenBench(_Draw d) {
    d.box(
      const _V(0, -0.4, 0),
      const _V(26, 0.8, 16),
      _Colors.counter,
      edge: _Colors.tableEdge,
    );
    d.box(const _V(0, 6, _shelfZ), const _V(20, 0.5, 3), _Colors.kitchenShelf);
  }

  bool _atHome(_Mat m) =>
      (sim.bowls[m]! - sim.home(_Obj.bowl(m))).length < 1e-3 &&
      sim.tilts[m] == 0;

  /// Far to near: shelf bowls, the vessel, the jug and spoon, bowls on the
  /// move with the pouring stream, the held object last.
  void _paintScene(_Draw d) {
    final s = sim;
    final held = s.held;
    for (final m in s.bowls.keys) {
      if (held != _Obj.bowl(m) && _atHome(m)) _bowl(d, m);
    }
    if (held != _Obj.vessel) _vessel(d);
    if (s.scenario == 1) {
      if (held != _Obj.jug) _jug(d);
      if (held != _Obj.spoon && !s.spoonInUse) _spoon(d);
    }
    for (final m in s.bowls.keys) {
      if (held != _Obj.bowl(m) && !_atHome(m)) _bowl(d, m);
    }
    if (s.streamOn) {
      d.frustum(
        const _Xf(_streamPos),
        _V.zero,
        0.12,
        0.22,
        _streamLength * s.streamScale,
        s.streamColor,
        drawCap: false,
      );
    }
    switch (held) {
      case null:
        break;
      case _Obj.vessel:
        _vessel(d);
      case _Obj.jug:
        _jug(d);
      case _Obj.spoon:
        _spoon(d);
      default:
        _bowl(d, held.mat!);
    }
  }

  /// Soft amber halo behind the object the current step needs.
  void _glow(_Draw d, _Obj o, double radius) {
    if (target != o || sim.held == o || sim.busy) return;
    final c = sim.centre(o);
    labGlow(
      d.canvas,
      d.p(c),
      radius * _proj.scaleAt(c),
      _Colors.amber400,
      intensity: 0.45,
    );
  }

  /// HTML beaker / tumbler group: glass, water, sediment, sawdust layer and
  /// the stirring rod.
  void _vessel(_Draw d) {
    final s = sim;
    final v = s.dims;
    final xf = _Xf(s.vessel);
    _glow(d, _Obj.vessel, v.height * 0.6);
    if (s.vessel.y < 0.01) d.shadow(s.vessel, v.rBottom * 1.15);
    // Back of the glass (faint).
    d.frustum(
      xf,
      _V(0, v.height / 2, 0),
      v.rTop,
      v.rBottom,
      v.height,
      v.glass,
      opacity: v.glassAlpha * 0.3,
      drawCap: false,
      lit: false,
    );
    if (s.sediment) {
      final r = v.sediment * s.sedimentWidth;
      d.frustum(
        xf,
        _V(0, v.sedimentY, 0),
        r,
        r,
        v.sedimentHeight * s.sedimentHeight,
        s.sedimentColor,
        cap: labShade(s.sedimentColor, 0.1),
      );
    }
    final waterTop = _waterBottom + _waterHeight * s.waterLevel;
    final under = s.floating && s.floatY < waterTop - 0.2;
    if (under) _float(d, xf);
    if (s.stirring) {
      final c = _V(
        math.sin(s.stirAngle) * v.rodCircle,
        v.rodY,
        math.cos(s.stirAngle) * v.rodCircle,
      );
      final half = const _V(0, 1, 0).rotZ(_rodTilt) * (v.rodLength / 2);
      d.rod(xf(c - half), xf(c + half), _rodRadius, v.rod);
    }
    if (s.waterOn) {
      final h = _waterHeight * s.waterLevel;
      final rTop = v.waterBase + (v.waterTop - v.waterBase) * s.waterLevel;
      d.frustum(
        xf,
        _V(0, _waterBottom + h / 2, 0),
        rTop,
        v.waterBase,
        h,
        s.water,
        opacity: s.waterAlpha,
        cap: labShade(s.water, 0.25),
      );
    }
    if (s.floating && !under) _float(d, xf);
    if (s.overTarget) {
      d.ring(xf(_V(0, v.height, 0)), v.rTop + 0.15);
      d.canvas.drawPath(d.path, _ringPaint);
    }
    d.glass(xf, v.rTop, v.rBottom, v.height, v.glass);
  }

  /// Sawdust layer (surfaceFloat) on, or swirling in, the water.
  void _float(_Draw d, _Xf xf) {
    d.frustum(
      xf,
      _V(0, sim.floatY, 0),
      _floatRadius,
      _floatRadius,
      _floatThickness,
      _Colors.sawdust,
      cap: labShade(_Colors.sawdust, 0.12),
    );
  }

  /// HTML bowl group: CylinderGeometry(1.2, 0.9, 0.8) and a squashed
  /// hemisphere heap of the material, tilted while pouring.
  void _bowl(_Draw d, _Mat m) {
    final s = sim;
    final pos = s.bowls[m]!;
    final xf = _Xf(pos, s.tilts[m]!);
    _glow(d, _Obj.bowl(m), _bowlHalo);
    if ((pos.y - _shelfTop).abs() < 1e-3) d.shadow(pos, 1.0, opacity: 0.3);
    d.frustum(
      xf,
      const _V(0, 0.4, 0),
      1.2,
      0.9,
      0.8,
      _Colors.bowl,
      cap: _Colors.bowlInside,
    );
    d.heap(xf, const _V(0, 0.6, 0), 1.0, 0.4, m.color);
  }

  /// HTML water jug: CylinderGeometry(2.0, 2.2, 5), 50 % opaque blue, with
  /// water inside (added, so it reads as a jug of water).
  void _jug(_Draw d) {
    final s = sim;
    final xf = _Xf(s.jug, s.jugTilt);
    _glow(d, _Obj.jug, _jugHalo);
    if (s.jug.y < 0.01 && s.jugTilt == 0) d.shadow(s.jug, 2.3);
    d.frustum(
      xf,
      const _V(0, 1.9, 0),
      1.9,
      2.05,
      3.6,
      _Colors.water,
      opacity: 0.45,
      cap: labShade(_Colors.water, 0.25),
    );
    d.frustum(
      xf,
      const _V(0, 2.5, 0),
      2.0,
      2.2,
      5,
      _Colors.jug,
      opacity: 0.5,
      cap: labShade(_Colors.jug, 0.3).withValues(alpha: 0.6),
    );
    d.glass(xf, 2.0, 2.2, 5, _Colors.white);
  }

  /// The Stir Spoon (added): a handle and an oval bowl lying on the counter.
  void _spoon(_Draw d) {
    final c = sim.spoon;
    _glow(d, _Obj.spoon, _spoonHalo);
    d.shadow(c + const _V(0.2, -0.11, 0), 0.9, opacity: 0.25);
    d.rod(
      c + const _V(-1.7, 0, 0),
      c + const _V(0.85, 0, 0),
      0.09,
      _Colors.spoon,
    );
    d.path.reset();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final o = d.p(c + _V(1.35 + 0.5 * math.cos(a), 0, 0.32 * math.sin(a)));
      i == 0 ? d.path.moveTo(o.dx, o.dy) : d.path.lineTo(o.dx, o.dy);
    }
    d.path.close();
    d.fillPath(_lit(_Colors.spoon, const _V(0, 1, 0)));
    d.strokePath(_Colors.slate500, 1);
  }

  // -------------------------------------------------------------- labels

  /// HTML sprite labels (bowls) plus labels for the other objects the
  /// learner drags (added). Sand and chalk sit in a second row so the five
  /// shelf labels never overlap.
  void _paintLabels(_Draw d) {
    final s = sim;
    final gap = labelSize * _labelGap;
    final rowHeight = _chipHeight() + gap;
    final onShelf = s.scenario == 0 ? s.phase == _Phase.place : s.step == 1;
    if (onShelf && s.held != _Obj.vessel) {
      _label(
        d,
        _t(s.scenario == 0 ? 'lbl_beaker' : 'item_tumbler'),
        d.p(s.centre(_Obj.vessel)),
        Alignment.center,
        _Obj.vessel,
      );
    }
    for (final m in s.bowls.keys) {
      // The beaker on the shelf stands in front of the sugar and sand bowls.
      if (s.scenario == 0 &&
          s.phase == _Phase.place &&
          (m == _Mat.sugar || m == _Mat.sand)) {
        continue;
      }
      final top = d.p(s.pos(_Obj.bowl(m)) + const _V(0, _bowlTop, 0));
      final row = s.scenario == 0 && m.upperLabel ? 1 : 0;
      _label(
        d,
        _t(m.key),
        top.translate(0, -gap - row * rowHeight),
        Alignment.bottomCenter,
        _Obj.bowl(m),
      );
    }
    if (s.scenario == 1) {
      _label(
        d,
        _t('item_jug'),
        d.p(s.jug + const _V(0, 5.1, 0)).translate(0, -gap),
        Alignment.bottomCenter,
        _Obj.jug,
      );
      if (!s.spoonInUse) {
        _label(
          d,
          _t('item_stir_spoon'),
          d.p(s.spoon + const _V(0, 0.4, 0)).translate(0, -gap),
          Alignment.bottomCenter,
          _Obj.spoon,
        );
      }
    }
  }

  double _chipHeight() => labelSize * (_labelLine + _labelPadV);

  void _label(_Draw d, String text, Offset at, Alignment anchor, _Obj obj) {
    final tp = sim.text.get(text, labelSize);
    final w = tp.width + labelSize * _labelPadH;
    final h = _chipHeight();
    final left = at.dx - (anchor.x + 1) / 2 * w;
    final top = at.dy - (anchor.y + 1) / 2 * h;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      Radius.circular(h / 2),
    );
    final hot = target == obj && !sim.busy;
    _chipBorder.color = hot ? _Colors.amber400 : _Colors.labelBorder;
    _chipBorder.strokeWidth = hot ? 2 : 1.2;
    d.canvas
      ..drawRRect(rr, _chipFill)
      ..drawRRect(rr, _chipBorder);
    tp.paint(
      d.canvas,
      Offset(left + (w - tp.width) / 2, top + (h - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.sim != sim ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.target != target;
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
