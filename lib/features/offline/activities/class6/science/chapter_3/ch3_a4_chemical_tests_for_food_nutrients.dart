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

/// Class 6 Science • Chapter 3 • Activity 4
/// Chemical Tests for Food Nutrients.
///
/// Native Flutter port of
/// `Cl6S-Ch03-A4-Chemical_Tests_for_Food_Nutrients.html` (Three.js r128).
/// The Three.js lab bench is redrawn by a small painter ([_Gfx]) that
/// reproduces the HTML camera: position (0, 12, 16), look-at (0, 0, 0), 45°
/// field of view.
///
/// Scenario 1 (The Starch Detective): test the potato, cucumber, boiled
/// rice and bread one by one with iodine: drag the food onto the petri dish,
/// drag the dropper over it, tap the bulb, then drag the dish to the Results
/// Tray. Foods that turn blue-black contain starch; sort them into the
/// 'Contains Starch' box.
///
/// Scenario 2 (The Oily Patch Mystery): test crushed peanuts, cucumber,
/// butter and oil with the paper test: drag the food onto the paper, tap the
/// paper to press it, hold the paper in front of the lamp, then drag it to
/// the Results Tray. Foods that leave a permanent translucent patch contain
/// fat; sort them into the 'Contains Fats' box.
class Ch3A4ChemicalTestsForFoodNutrientsPage extends StatefulWidget {
  const Ch3A4ChemicalTestsForFoodNutrientsPage({super.key});

  @override
  State<Ch3A4ChemicalTestsForFoodNutrientsPage> createState() =>
      _FoodTestsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, drop → `science/drop.mp3`,
/// pickup → `science/pickup.mp3`.
///
/// The HTML synthesises its tones in `playSound(type)`; each is mapped onto
/// the closest file: `pop` → pop, `click` (bulb squeeze) → click, `drop`
/// (falling iodine drop) → drop, `success` / `chime` (C-E-G arpeggio: a
/// positive result, a dish or paper reaching the Results Tray, a correct
/// sort) → correct, `error` (wrong sort) → wrong, `paper` (white-noise
/// burst of the paper being pressed) → pickup. The summary popup plays
/// success.
enum _Sound implements LabTone {
  /// Generic button click; the dropper bulb being squeezed.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive test result, item into the Results Tray, correct sort.
  correct('audio/class6/science/correct.mp3'),

  /// A food dropped into the wrong box, a missed drop.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// Something snapped into place; a negative test result.
  pop('audio/class6/science/pop.mp3'),

  /// The iodine drop falling.
  drop('audio/class6/science/drop.mp3'),

  /// An object picked up; the paper being wrapped and pressed.
  pickup('audio/class6/science/pickup.mp3');

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

/// Colours of the HTML page (Tailwind classes and its `teal` / `blue`
/// config) and of its Three.js scene (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal500 = Color(0xFF14B8A6); // tailwind config
  static const Color teal600 = Color(0xFF0D9488);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // tailwind config
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color sky400 = Color(0xFF38BDF8);
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
  /// `scene.background`: 0x0f172a (dark theme), 0xe2e8f0 (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate200;

  /// Lab bench planes: S1 0xcbd5e1, S2 0x94a3b8.
  static const Color bench1 = slate300;
  static const Color bench2 = slate400;

  /// `Mats.metal` (trays) and `Mats.wood` (S2 food tray).
  static const Color metal = slate400;
  static const Color wood = Color(0xFF8B4513);

  /// `Mats.glass` (petri dish, dropper tube): white at opacity 0.4.
  static const Color glass = white;

  // Foods (`Mats.*`).
  static const Color potato = Color(0xFFFDE047);
  static const Color potatoSkin = Color(0xFFCA8A04);
  static const Color cucumberOuter = Color(0xFF166534);
  static const Color cucumberInner = Color(0xFFDCFCE3);
  static const Color cucumberSeed = Color(0xFFBBF7D0);
  static const Color rice = Color(0xFFF8FAFC);
  static const Color riceGrain = slate300;
  static const Color bread = Color(0xFFD97706);
  static const Color breadCrust = Color(0xFF78350F);
  static const Color peanut = Color(0xFFB45309);
  static const Color butter = Color(0xFFFEF08A);
  static const Color oil = Color(0xFFEAB308);

  /// `Mats.iodine` and the iodine bottle: 0x78350f (brown).
  static const Color iodine = Color(0xFF78350F);

  /// Dropper bulb 0x111111.
  static const Color bulb = Color(0xFF111111);

  /// Stains: blue-black (starch) 0x0f172a, brown (no starch) 0x78350f.
  static const Color stainStarch = slate900;
  static const Color stainNone = iodine;

  /// `Mats.paper`.
  static const Color paper = white;

  /// Patches: oily `rgba(253, 230, 138, 0.8)` (amber-200), wet
  /// `rgba(186, 230, 253, 0.6)` (sky-200).
  static const Color oilyPatch = Color(0xCCFDE68A);
  static const Color wetPatch = Color(0x99BAE6FD);

  /// Light through the oily patch in front of the lamp.
  static const Color patchGlow = Color(0xFFFFF7D6);

  /// Lamp: base 0x1e293b, arm 0x475569, shade 0x334155, SpotLight 0xfffbeb.
  static const Color lampBase = slate800;
  static const Color lampArm = slate600;
  static const Color lampShade = slate700;
  static const Color lampLight = Color(0xFFFFFBEB);

  /// Sorting boxes: 0x10b981 (starch), 0x0ea5e9 (fats).
  static const Color boxStarch = Color(0xFF10B981);
  static const Color boxFat = Color(0xFF0EA5E9);

  /// Box flashes (`setHex(0x10b981)` / `setHex(0xef4444)`) and the yellow
  /// outline while an item is held over it.
  static const Color flashGreen = boxStarch;
  static const Color flashRed = red500;
  static const Color hover = Color(0xFFEAB308);

  /// Contact shadows on the bench.
  static const Color shadow = Color(0x59000000);

  // -------------------------------------------------------------- labels
  /// `createTextSprite` default: bg #f8fafc, border #475569, text #0f172a.
  static const Color chipBg = slate50;
  static const Color chipBorder = slate600;
  static const Color chipText = slate900;

  /// 'Contains Starch' sprite: bg #064e3b, border #10b981, white text;
  /// 'Contains Fats': bg #0f172a, border #0ea5e9.
  static const Color starchChipBg = Color(0xFF064E3B);
  static const Color fatChipBg = slate900;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// HTML's brand colour is teal (`teal-500`).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // `--bg-primary` #020617
    panel: Color(0xEB0F172A), // `--glass-bg` rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // `--glass-border` white / 15
    card: Color(0xCC1E293B), // slate-800 / 80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.teal500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue500,
    onPrimary: _Colors.white,
    success: _Colors.teal400,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.teal400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66115E59), // teal-800 / 40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC5EEAD4), // teal-300 / 80
    curtainIcon: _Colors.teal400,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.teal400,
    buttonBorder: Color(0x9914B8A6),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // `--bg-primary` #e2e8f0
    panel: Color(0xF2FFFFFF), // `--glass-bg` rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // `--glass-border` black / 15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate50, // `bg-[#f8fafc]`
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.teal500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue500,
    onPrimary: _Colors.white,
    success: _Colors.teal600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.teal600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66115E59),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC5EEAD4),
    curtainIcon: _Colors.teal400,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.teal400,
    buttonBorder: Color(0x9914B8A6),
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
/// are the HTML sidebar text size setting: 15 px, slider 12–22 px.
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
// dropped). The English HTML steps carry the instruction in `concept`, the
// result in `action` and an animation note in `observation`; the Hindi
// steps have the intended shape (concept, action, observation,
// explanation), so both languages use that shape here: concept = the
// Hindi concept title, action = the full instruction, observation = the
// result (shown once the step is done) and explanation = the Hindi note
// (translated for English, where the HTML had none). Changes from the HTML
// (see the report): "click" is "tap"; steps 4 and 5 list every drag and tap
// they need; "two with a blue-black reaction (potato, rice, bread)" is
// "three"; the iodine stain no longer "fizzes"; the HTML's English-only
// feedback texts are translated; Hindi feedback never puts a gendered verb
// after a food's name. Keys marked "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Chemical Tests for Food Nutrients',
    'app_subtitle': 'Class 6 • Mindful Eating: A Path to a Healthy Body',
    'scen_1_opt': 'Scenario 1: The Starch Detective',
    'scen_2_opt': 'Scenario 2: The Oily Patch Mystery',
    's1_desc':
        'Investigate food items and determine which ones contain starch using the iodine test.',
    's2_desc':
        'Test different food items for the presence of fats using the paper test.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Prepare the potato sample',
    'step_1_1_a':
        'Drag the slice of potato from the food tray and drop it onto the empty petri dish on the lab bench.',
    'step_1_1_o':
        'The potato slice is placed in the center of the petri dish, ready to be tested.',
    'step_1_1_e':
        'Preparing the sample on a clean surface is the first step of a chemical test.',
    'step_1_2_c': 'Position the reagent',
    'step_1_2_a':
        "Drag the dropper from the 'Iodine Solution' bottle and let go of it directly over the potato slice in the petri dish.",
    'step_1_2_o':
        'The dropper is positioned above the potato slice, ready to release a drop.',
    'step_1_2_e':
        'Iodine solution is the reagent used to test for the presence of starch.',
    'step_1_3_c': 'Apply and observe',
    'step_1_3_a':
        'Tap the rubber bulb on top of the dropper to add a drop of iodine, then watch the potato slice.',
    'step_1_3_o':
        "A drop of brownish iodine solution falls onto the potato slice, and the spot where it lands turns a deep blue-black: 'Blue-Black (Starch!)'.",
    'step_1_3_e':
        'A blue-black color change with iodine is a positive result for starch.',
    'step_1_4_c': 'Test the cucumber',
    'step_1_4_a':
        "Drag the used petri dish to the 'Results Tray'. Then repeat steps 1-3 for the slice of cucumber: drag it onto the empty petri dish, drag the iodine dropper over it and tap the bulb. Finally drag its petri dish to the 'Results Tray' too.",
    'step_1_4_o':
        "When the iodine drop hits the cucumber, there is no color change: the brownish drop just sits on the surface. 'No Color Change'.",
    'step_1_4_e':
        'If the iodine stays brown, no significant amount of starch is present.',
    'step_1_5_c': 'Test the remaining items',
    'step_1_5_a':
        "Repeat the test for the boiled rice and then the bread: drag each one onto the empty petri dish, drag the iodine dropper over it, tap the bulb, observe the result and drag its petri dish to the 'Results Tray'.",
    'step_1_5_o':
        'The boiled rice and the bread both turn a dramatic blue-black. The Results Tray now shows four petri dishes: three with a blue-black color (potato, rice, bread) and one with no color change (cucumber).',
    'step_1_5_e':
        'Rice and bread both show a positive reaction, confirming that they are starch-rich foods.',
    'step_1_6_c': 'Classify the results',
    'step_1_6_a':
        "Drag each food that turned blue-black from the 'Results Tray' into the box labeled 'Contains Starch'.",
    'step_1_6_o':
        'The box glows green for each correct food and red for a wrong one, which goes back to the tray. Once the potato, rice and bread are in the box, a large checkmark appears.',
    'step_1_6_e':
        'Sorting helps consolidate the findings. Potato, rice and bread are major sources of carbohydrates (starch).',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Prepare the peanut sample',
    'step_2_1_a':
        'Drag the crushed peanuts from the food tray and drop them onto the clean sheet of paper on the lab bench.',
    'step_2_1_o': 'The crushed peanuts are placed in the center of the paper.',
    'step_2_1_e':
        'Crushing the food helps to release any oil or fat hidden inside it.',
    'step_2_2_c': 'Extract the fat',
    'step_2_2_a': 'Tap the paper to wrap and press the peanuts.',
    'step_2_2_o':
        'The paper folds over the peanuts, is pressed down and unfolds. The peanuts are moved to the side, revealing a translucent, oily patch on the paper.',
    'step_2_2_e':
        'Pressing the food against the paper transfers its fat to the paper, leaving a mark.',
    'step_2_3_c': 'Translucency test',
    'step_2_3_a':
        'Drag the paper with the patch and let go of it in front of the lamp to hold it up to the light.',
    'step_2_3_o':
        "Held up to the lamp, the oily patch becomes brighter: light passes through it, unlike the rest of the opaque paper. 'Translucent (Fat!)'.",
    'step_2_3_e':
        'Fat makes paper translucent (it lets some light pass through). This is the test for fat.',
    'step_2_4_c': 'Test the cucumber',
    'step_2_4_a':
        "Drag the used paper to the 'Results Tray'. Then repeat steps 1-3 for the slice of cucumber: drag it onto the new sheet of paper, tap the paper to press it and let go of the paper in front of the lamp. Finally drag the paper to the 'Results Tray' too.",
    'step_2_4_o':
        "The cucumber leaves a wet patch that slowly dries and disappears completely. Held up to the light, the paper is evenly opaque: 'Dries Up (No Fat)'.",
    'step_2_4_e':
        'Water leaves a temporary wet mark that evaporates, unlike fat, which leaves a permanent oily patch.',
    'step_2_5_c': 'Test the remaining items',
    'step_2_5_a':
        "Repeat the test for the butter and then the oil: drag each one onto the paper, tap the paper to press it, let go of the paper in front of the lamp and drag the paper to the 'Results Tray'.",
    'step_2_5_o':
        'The butter and the oil both leave a permanent, translucent oily patch that glows in front of the lamp. The Results Tray now shows four pieces of paper: three with oily patches (peanuts, butter, oil) and one that is clean (cucumber).',
    'step_2_5_e':
        'Butter and oil are mostly fat, so they easily leave an oily, translucent mark.',
    'step_2_6_c': 'Classify the results',
    'step_2_6_a':
        "Drag each food that left a permanent oily patch from the 'Results Tray' into the box labeled 'Contains Fats'.",
    'step_2_6_o':
        'The box glows green for each correct food (peanuts, butter, oil) and red for a wrong one (cucumber), which goes back to the tray. Once all three are in the box, a large checkmark appears.',
    'step_2_6_e':
        'Sorting reinforces the conclusion: peanuts, butter and oil are rich sources of dietary fat.',
    // ------------------------------------------- HUD (HTML `s1_sub` / `hud`)
    's1_sub_0': 'DRAG the {food} from the food tray to the Petri Dish.',
    's1_sub_1': 'DRAG the Iodine Dropper directly over the {food}.',
    's1_sub_2': 'TAP the dropper bulb to add a drop of iodine.',
    's1_sub_3': 'DRAG the used Petri Dish to the Results Tray.',
    's1_hud_6':
        "Sort! DRAG the foods that turned blue-black into the 'Contains Starch' box.",
    's2_sub_0': 'DRAG the {food} onto the center of the paper.',
    's2_sub_1': 'TAP the paper to wrap and press the {food}.',
    's2_sub_2': 'DRAG the paper and let go of it in front of the Lamp.',
    's2_sub_3': 'DRAG the tested paper to the Results Tray.',
    's2_hud_6':
        "Sort! DRAG the foods that left a permanent translucent patch into the 'Contains Fats' box.",
    'hud_done':
        "Excellent! All foods are sorted. Tap 'Review Findings' to see the summary again.",
    // ---------------------------------------------------------- foods
    'food_potato': 'Potato',
    'food_cucumber': 'Cucumber',
    'food_rice': 'Boiled Rice',
    'food_bread': 'Bread',
    'food_peanuts': 'Crushed Peanuts',
    'food_butter': 'Butter',
    'food_oil': 'Oil',
    // --------------------------------------------------- scene labels
    'lbl_potato': 'Potato',
    'lbl_cucumber': 'Cucumber',
    'lbl_rice': 'Boiled Rice',
    'lbl_bread': 'Bread',
    'lbl_peanuts': 'Crushed Peanuts',
    'lbl_butter': 'Butter',
    'lbl_oil': 'Oil Drop',
    'lbl_iodine': 'Iodine Solution',
    'lbl_dish': 'Petri Dish',
    'lbl_tray': 'Results Tray',
    'lbl_box_1': 'Contains Starch',
    'lbl_paper': 'Paper Sheet',
    'lbl_lamp': 'Testing Lamp',
    'lbl_box_2': 'Contains Fats',
    'res_1_pos': 'Blue-Black (Starch!)',
    'res_1_neg': 'No Color Change',
    'res_2_pos': 'Translucent (Fat!)',
    'res_2_neg': 'Dries Up (No Fat)',
    // --------------------------------------------- feedback (HTML showFeedback)
    'toast_1_pos': 'Blue-Black Color (Starch!)',
    'toast_1_neg': '{food}: No Color Change',
    'toast_drying': 'Wet patch drying...',
    'toast_2_pos': 'Translucent Patch: Fat Detected',
    'toast_2_neg': '{food}: Wet Patch Dried Up, No Fat',
    'toast_wrong_1': '{food} does NOT contain Starch!',
    'toast_wrong_2': '{food} does NOT contain Fat!',
    // Added: a correct sort, missed drops and objects touched too early.
    'toast_right_1': 'Correct! {food} contains starch.',
    'toast_right_2': 'Correct! {food} contains fat.',
    'miss_food_1': 'Let go of the {food} right over the petri dish.',
    'miss_dropper':
        'Let go of the dropper right over the {food} in the petri dish.',
    'miss_tray_1': 'Drop the used petri dish onto the Results Tray.',
    'miss_food_2': 'Let go of the {food} right over the sheet of paper.',
    'miss_lamp': 'Let go of the paper right in front of the lamp.',
    'miss_tray_2': 'Drop the tested paper onto the Results Tray.',
    'miss_box_1': "Let go of it right over the 'Contains Starch' box.",
    'miss_box_2': "Let go of it right over the 'Contains Fats' box.",
    'toast_first': 'First: {task}',
    // ------------------------------------------------------------ sidebar
    'obs_table': 'Test Results',
    'tbl_food': 'Food',
    'tbl_test_1': 'Iodine test',
    'tbl_test_2': 'Paper test',
    'res_short_1_pos': 'Blue-black',
    'res_short_1_neg': 'No change (stays brown)',
    'res_short_2_pos': 'Translucent oily patch',
    'res_short_2_neg': 'Wet patch dried up',
    'res_untested': 'Not tested yet',
    'concept_exp': 'Observation Steps',
    'exploration': 'Step',
    'concept_focus': 'Focus',
    'action': 'Action',
    'observation': 'Result',
    'explanation': 'Note',
    'obs_pending': 'Complete this step to see the result.',
    'btn_review': 'Review Findings',
    // --------------------------------------------------------- conclusion
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    's1_summary':
        'You are a Starch Detective! A blue-black color with iodine indicates the presence of starch. You found that potatoes, rice and bread are rich in starch, while cucumber is not.',
    's2_summary':
        'You solved the Oily Patch Mystery! An oily, translucent patch on paper that does not dry up indicates the presence of fat. You found that peanuts, butter and oil are rich in fats.',
    'key_1': 'Blue-Black = Starch!',
    'key_2': 'Translucent Oily Patch = Fat!',
    // Added (screen readers).
    'scene_s1':
        'Lab bench with a food tray (potato, cucumber, boiled rice, bread), a petri dish, a bottle of iodine solution with a dropper and a results tray.',
    'scene_s2':
        'Lab bench with a food tray (crushed peanuts, cucumber, butter, oil), a sheet of paper, a testing lamp and a results tray.',
  },
  'hi': {
    'app_title': 'खाद्य पोषक तत्वों के लिए रासायनिक परीक्षण',
    'app_subtitle': 'कक्षा 6 • सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_opt': 'परिदृश्य 1: स्टार्च जासूस',
    'scen_2_opt': 'परिदृश्य 2: तैलीय धब्बे का रहस्य',
    's1_desc':
        'खाद्य पदार्थों की जांच करें और आयोडीन परीक्षण का उपयोग करके निर्धारित करें कि किनमें स्टार्च है।',
    's2_desc':
        'कागज़ परीक्षण का उपयोग करके विभिन्न खाद्य पदार्थों में वसा की उपस्थिति का परीक्षण करें।',
    'step_1_1_c': 'आलू का नमूना तैयार करें',
    'step_1_1_a':
        'आलू के टुकड़े को खाद्य ट्रे से खींचें और प्रयोगशाला की मेज़ पर रखी खाली पेट्री डिश पर छोड़ दें।',
    'step_1_1_o':
        'आलू का टुकड़ा पेट्री डिश के बीच में रखा जाता है और परीक्षण के लिए तैयार है।',
    'step_1_1_e':
        'साफ सतह पर नमूना तैयार करना रासायनिक विश्लेषण का पहला कदम है।',
    'step_1_2_c': 'अभिकर्मक रखें',
    'step_1_2_a':
        "'आयोडीन विलयन' की बोतल से ड्रॉपर को खींचें और उसे पेट्री डिश में आलू के टुकड़े के ठीक ऊपर छोड़ दें।",
    'step_1_2_o':
        'ड्रॉपर आलू के टुकड़े के ठीक ऊपर रुक जाता है और एक बूँद गिराने के लिए तैयार है।',
    'step_1_2_e':
        'आयोडीन विलयन वह अभिकर्मक है जिसका उपयोग स्टार्च की उपस्थिति का परीक्षण करने के लिए किया जाता है।',
    'step_1_3_c': 'डालें और अवलोकन करें',
    'step_1_3_a':
        'आयोडीन की एक बूँद डालने के लिए ड्रॉपर के ऊपर लगे रबर बल्ब पर टैप करें, फिर आलू के टुकड़े को देखें।',
    'step_1_3_o':
        "भूरे आयोडीन विलयन की एक बूँद आलू के टुकड़े पर गिरती है और जहाँ वह गिरती है, वह जगह गहरी नीली-काली हो जाती है: 'नीला-काला (स्टार्च!)'।",
    'step_1_3_e':
        'आयोडीन के साथ नीला-काला रंग परिवर्तन स्टार्च के लिए सकारात्मक परिणाम है।',
    'step_1_4_c': 'ककड़ी का परीक्षण करें',
    'step_1_4_a':
        "इस्तेमाल की गई पेट्री डिश को 'परिणाम ट्रे' पर खींचें। फिर ककड़ी के टुकड़े के लिए चरण 1-3 दोहराएँ: उसे खाली पेट्री डिश पर खींचें, आयोडीन ड्रॉपर को उसके ऊपर खींचें और बल्ब पर टैप करें। अंत में उसकी पेट्री डिश को भी 'परिणाम ट्रे' पर खींचें।",
    'step_1_4_o':
        "ककड़ी पर आयोडीन की बूँद गिरने पर कोई रंग परिवर्तन नहीं होता: भूरी बूँद सतह पर बस पड़ी रहती है। 'कोई रंग परिवर्तन नहीं'।",
    'step_1_4_e':
        'यदि आयोडीन भूरा रहता है, तो इसका मतलब है कि कोई महत्वपूर्ण मात्रा में स्टार्च मौजूद नहीं है।',
    'step_1_5_c': 'शेष वस्तुओं का परीक्षण करें',
    'step_1_5_a':
        "उबले हुए चावल और फिर ब्रेड के लिए परीक्षण दोहराएँ: हर एक को खाली पेट्री डिश पर खींचें, आयोडीन ड्रॉपर को उसके ऊपर खींचें, बल्ब पर टैप करें, परिणाम देखें और उसकी पेट्री डिश को 'परिणाम ट्रे' पर खींचें।",
    'step_1_5_o':
        'उबले चावल और ब्रेड दोनों गहरे नीले-काले हो जाते हैं। अब परिणाम ट्रे में चार पेट्री डिश हैं: तीन में नीला-काला रंग (आलू, चावल, ब्रेड) और एक में कोई रंग परिवर्तन नहीं (ककड़ी)।',
    'step_1_5_e':
        'चावल और ब्रेड दोनों सकारात्मक प्रतिक्रिया दिखाते हैं, जिससे पुष्टि होती है कि वे स्टार्च युक्त खाद्य पदार्थ हैं।',
    'step_1_6_c': 'परिणामों को वर्गीकृत करें',
    'step_1_6_a':
        "जो खाद्य पदार्थ नीले-काले हो गए थे, उनमें से हर एक को 'परिणाम ट्रे' से 'स्टार्च है' लिखे बॉक्स में खींचें।",
    'step_1_6_o':
        'हर सही खाद्य पदार्थ के लिए बॉक्स हरा चमकता है और गलत के लिए लाल; गलत वाला ट्रे में वापस चला जाता है। आलू, चावल और ब्रेड के बॉक्स में पहुँचते ही सही का एक बड़ा निशान दिखाई देता है।',
    'step_1_6_e':
        'छँटाई निष्कर्षों को पक्का करने में मदद करती है। आलू, चावल और ब्रेड कार्बोहाइड्रेट (स्टार्च) के प्रमुख स्रोत हैं।',
    'step_2_1_c': 'मूंगफली का नमूना तैयार करें',
    'step_2_1_a':
        'कुचली हुई मूंगफली को खाद्य ट्रे से खींचें और प्रयोगशाला की मेज़ पर रखी कागज़ की साफ शीट पर छोड़ दें।',
    'step_2_1_o': 'कुचली हुई मूंगफली कागज़ के बीच में रखी जाती है।',
    'step_2_1_e':
        'भोजन को कुचलने से उसके अंदर छिपा तेल या वसा बाहर निकलने में मदद मिलती है।',
    'step_2_2_c': 'वसा निकालें',
    'step_2_2_a': 'मूंगफली को लपेटने और दबाने के लिए कागज़ पर टैप करें।',
    'step_2_2_o':
        'कागज़ मूंगफली पर मुड़ता है, दबाया जाता है और फिर खुल जाता है। मूंगफली को एक ओर हटाने पर कागज़ पर एक पारभासी, तैलीय धब्बा दिखाई देता है।',
    'step_2_2_e':
        'भोजन को कागज़ पर दबाने से उसकी वसा कागज़ पर आ जाती है और एक निशान रह जाता है।',
    'step_2_3_c': 'पारभासिता परीक्षण',
    'step_2_3_a':
        'धब्बे वाले कागज़ को खींचें और उसे लैंप के सामने छोड़ दें, ताकि वह रोशनी के सामने रहे।',
    'step_2_3_o':
        "लैंप के सामने तैलीय धब्बा अधिक चमकीला हो जाता है: प्रकाश उसमें से होकर गुज़रता है, जबकि बाकी कागज़ अपारदर्शी रहता है। 'पारभासी (वसा!)'।",
    'step_2_3_e':
        'वसा कागज़ को पारभासी बना देती है (उसमें से कुछ प्रकाश गुज़र सकता है)। यही वसा का परीक्षण है।',
    'step_2_4_c': 'ककड़ी का परीक्षण करें',
    'step_2_4_a':
        "इस्तेमाल किए गए कागज़ को 'परिणाम ट्रे' पर खींचें। फिर ककड़ी के टुकड़े के लिए चरण 1-3 दोहराएँ: उसे कागज़ की नई शीट पर खींचें, उसे दबाने के लिए कागज़ पर टैप करें और कागज़ को लैंप के सामने छोड़ें। अंत में कागज़ को भी 'परिणाम ट्रे' पर खींचें।",
    'step_2_4_o':
        "ककड़ी से कागज़ पर एक गीला धब्बा बनता है जो धीरे-धीरे सूखकर पूरी तरह गायब हो जाता है। रोशनी के सामने कागज़ हर जगह एक जैसा अपारदर्शी दिखता है: 'सूख जाता है (वसा नहीं)'।",
    'step_2_4_e':
        'पानी एक अस्थायी गीला निशान छोड़ता है जो वाष्पित हो जाता है, जबकि वसा एक स्थायी तैलीय धब्बा छोड़ती है।',
    'step_2_5_c': 'शेष वस्तुओं का परीक्षण करें',
    'step_2_5_a':
        "मक्खन और फिर तेल के लिए परीक्षण दोहराएँ: हर एक को कागज़ पर खींचें, उसे दबाने के लिए कागज़ पर टैप करें, कागज़ को लैंप के सामने छोड़ें और कागज़ को 'परिणाम ट्रे' पर खींचें।",
    'step_2_5_o':
        'मक्खन और तेल दोनों एक स्थायी, पारभासी तैलीय धब्बा छोड़ते हैं जो लैंप के सामने चमकता है। अब परिणाम ट्रे में कागज़ के चार टुकड़े हैं: तीन पर तैलीय धब्बे (मूंगफली, मक्खन, तेल) और एक साफ (ककड़ी)।',
    'step_2_5_e':
        'मक्खन और तेल मुख्य रूप से वसा हैं, इसलिए वे आसानी से एक तैलीय, पारभासी निशान छोड़ देते हैं।',
    'step_2_6_c': 'परिणामों को वर्गीकृत करें',
    'step_2_6_a':
        "जिन खाद्य पदार्थों ने स्थायी तैलीय धब्बा छोड़ा था, उनमें से हर एक को 'परिणाम ट्रे' से 'वसा है' लिखे बॉक्स में खींचें।",
    'step_2_6_o':
        'हर सही खाद्य पदार्थ (मूंगफली, मक्खन, तेल) के लिए बॉक्स हरा चमकता है और गलत (ककड़ी) के लिए लाल; गलत वाला ट्रे में वापस चला जाता है। तीनों के बॉक्स में पहुँचते ही सही का एक बड़ा निशान दिखाई देता है।',
    'step_2_6_e':
        'छँटाई निष्कर्ष को पक्का करती है: मूंगफली, मक्खन और तेल आहार वसा के समृद्ध स्रोत हैं।',
    's1_sub_0': '{food} को खाद्य ट्रे से खाली पेट्री डिश में खींचें।',
    's1_sub_1': 'आयोडीन ड्रॉपर को {food} के ठीक ऊपर खींचें।',
    's1_sub_2': 'आयोडीन की एक बूँद डालने के लिए ड्रॉपर बल्ब पर टैप करें।',
    's1_sub_3': 'इस्तेमाल की गई पेट्री डिश को परिणाम ट्रे पर खींचें।',
    's1_hud_6':
        "छाँटें! जिन खाद्य पदार्थों का रंग नीला-काला हो गया था, उन्हें 'स्टार्च है' बॉक्स में खींचें।",
    's2_sub_0': '{food} को कागज़ के बीच में खींचें।',
    's2_sub_1': '{food} को लपेटने और दबाने के लिए कागज़ पर टैप करें।',
    's2_sub_2': 'कागज़ को खींचें और उसे लैंप के सामने छोड़ें।',
    's2_sub_3': 'परीक्षण किए गए कागज़ को परिणाम ट्रे पर खींचें।',
    's2_hud_6':
        "छाँटें! जिन खाद्य पदार्थों ने स्थायी पारभासी धब्बा छोड़ा था, उन्हें 'वसा है' बॉक्स में खींचें।",
    'hud_done':
        "बहुत बढ़िया! सभी खाद्य पदार्थ छाँट लिए गए। सारांश फिर से देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    'food_potato': 'आलू',
    'food_cucumber': 'ककड़ी',
    'food_rice': 'उबले हुए चावल',
    'food_bread': 'ब्रेड',
    'food_peanuts': 'कुचली हुई मूंगफली',
    'food_butter': 'मक्खन',
    'food_oil': 'तेल',
    'lbl_potato': 'आलू',
    'lbl_cucumber': 'ककड़ी',
    'lbl_rice': 'उबले चावल',
    'lbl_bread': 'ब्रेड',
    'lbl_peanuts': 'कुचली मूंगफली',
    'lbl_butter': 'मक्खन',
    'lbl_oil': 'तेल',
    'lbl_iodine': 'आयोडीन विलयन',
    'lbl_dish': 'पेट्री डिश',
    'lbl_tray': 'परिणाम ट्रे',
    'lbl_box_1': 'स्टार्च है',
    'lbl_paper': 'कागज़',
    'lbl_lamp': 'परीक्षण लैंप',
    'lbl_box_2': 'वसा है',
    'res_1_pos': 'नीला-काला (स्टार्च!)',
    'res_1_neg': 'कोई रंग परिवर्तन नहीं',
    'res_2_pos': 'पारभासी (वसा!)',
    'res_2_neg': 'सूख जाता है (वसा नहीं)',
    'toast_1_pos': 'नीला-काला रंग (स्टार्च!)',
    'toast_1_neg': '{food}: कोई रंग परिवर्तन नहीं',
    'toast_drying': 'गीला धब्बा सूख रहा है...',
    'toast_2_pos': 'पारभासी धब्बा: वसा का पता चला',
    'toast_2_neg': '{food}: गीला धब्बा सूख गया, वसा नहीं',
    'toast_wrong_1': '{food} में स्टार्च नहीं है!',
    'toast_wrong_2': '{food} में वसा नहीं है!',
    'toast_right_1': 'सही! {food} में स्टार्च है।',
    'toast_right_2': 'सही! {food} में वसा है।',
    'miss_food_1': '{food} को ठीक पेट्री डिश के ऊपर छोड़ें।',
    'miss_dropper': 'ड्रॉपर को पेट्री डिश में {food} के ठीक ऊपर छोड़ें।',
    'miss_tray_1': 'इस्तेमाल की गई पेट्री डिश को परिणाम ट्रे पर छोड़ें।',
    'miss_food_2': '{food} को ठीक कागज़ की शीट के ऊपर छोड़ें।',
    'miss_lamp': 'कागज़ को ठीक लैंप के सामने छोड़ें।',
    'miss_tray_2': 'परीक्षण किए गए कागज़ को परिणाम ट्रे पर छोड़ें।',
    'miss_box_1': "इसे ठीक 'स्टार्च है' बॉक्स के ऊपर छोड़ें।",
    'miss_box_2': "इसे ठीक 'वसा है' बॉक्स के ऊपर छोड़ें।",
    'toast_first': 'पहले: {task}',
    'obs_table': 'परीक्षण के परिणाम',
    'tbl_food': 'खाद्य पदार्थ',
    'tbl_test_1': 'आयोडीन परीक्षण',
    'tbl_test_2': 'कागज़ परीक्षण',
    'res_short_1_pos': 'नीला-काला',
    'res_short_1_neg': 'कोई बदलाव नहीं (भूरा ही रहा)',
    'res_short_2_pos': 'पारभासी तैलीय धब्बा',
    'res_short_2_neg': 'गीला धब्बा सूख गया',
    'res_untested': 'अभी परीक्षण नहीं हुआ',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'ध्यान दें',
    'action': 'कार्य',
    'observation': 'परिणाम',
    'explanation': 'स्पष्टीकरण',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'btn_review': 'निष्कर्ष की समीक्षा करें',
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    's1_summary':
        'आप एक स्टार्च जासूस हैं! आयोडीन के साथ नीला-काला रंग स्टार्च की उपस्थिति का संकेत देता है। आपने पाया कि आलू, चावल और ब्रेड स्टार्च से भरपूर हैं, जबकि ककड़ी नहीं है।',
    's2_summary':
        'आपने तैलीय धब्बे का रहस्य सुलझा लिया है! कागज़ पर एक तैलीय, पारभासी धब्बा जो सूखता नहीं है, वसा की उपस्थिति का संकेत देता है। आपने पाया कि मूंगफली, मक्खन और तेल वसा से भरपूर हैं।',
    'key_1': 'नीला-काला = स्टार्च!',
    'key_2': 'पारभासी तैलीय धब्बा = वसा!',
    'scene_s1':
        'प्रयोगशाला की मेज़ पर खाद्य ट्रे (आलू, ककड़ी, उबले चावल, ब्रेड), पेट्री डिश, ड्रॉपर वाली आयोडीन विलयन की बोतल और परिणाम ट्रे।',
    'scene_s2':
        'प्रयोगशाला की मेज़ पर खाद्य ट्रे (कुचली मूंगफली, ककड़ी, मक्खन, तेल), कागज़ की शीट, परीक्षण लैंप और परिणाम ट्रे।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [6, 6];

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
              concept: t('step_${n}_${i}_c'),
              action: t('step_${n}_${i}_a'),
              observation: t('step_${n}_${i}_o'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// The part of the design box the scene is fitted into (the stage only
/// hit-tests inside its design box).
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// HTML `new THREE.PerspectiveCamera(45, aspect, 0.1, 100)`.
const double _fovDegrees = 45;
const double _near = 0.1;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `resetCamera()`: `camera.position.set(0, 12, 16)`,
/// `controls.target.set(0, 0, 0)`.
const _V _eye = _V(0, 12, 16);
const _V _target = _V.zero;
const _V _up = _V(0, 1, 0);

/// The camera looks down by atan(12 / 16) ≈ 36.9°: sin² and cos² of that
/// pitch (a flat shape's depth shows foreshortened by sin).
const double _sinPitch2 = 0.36;
const double _cosPitch2 = 0.64;

/// HTML lights: `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(
/// 0xfff5b6, 0.8)` at (10, 20, 10). Three.js r128 adds them linearly and
/// clips at white, which washes the lit tops out; both are scaled by
/// [_lightScale].
const double _lightScale = 0.8;
const double _ambient = 0.6 * _lightScale;
const double _diffuse = 0.8 * _lightScale;

/// (10, 20, 10) normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML sprite text stays readable; the food and tray labels are drawn
/// smaller so neighbours stay apart.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _smallLabelScale = 0.85;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

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

/// Largest and smallest zoom of the fitted scene (1 = the HTML camera).
const double _maxZoom = 1.35;
const double _minZoom = 0.3;

/// HTML summary after the last correct sort: shown 1.2 s later, once the
/// checkmark has appeared.
const Duration _conclusionDelay = Duration(milliseconds: 1200);

// ------------------------------------------------------------ the bench

/// `PlaneGeometry(30, 15)` lab bench at y = 0.
const double _benchHalfX = 15;
const double _benchHalfZ = 7.5;

/// HTML `position.y = 1.5`: the fixed height of a dragged object.
const double _dragY = 1.5;

/// Food tray `BoxGeometry(4, 0.2, 8)` at (-6, 0.1, 0) and Results Tray
/// `BoxGeometry(6, 0.2, 8)` at (7, 0.1, 0): their tops are at y = 0.2.
const _V _foodTrayC = _V(-6, 0.1, 0);
const _V _foodTraySize = _V(4, 0.2, 8);
const _V _resultsC = _V(7, 0.1, 0);
const _V _resultsSize = _V(6, 0.2, 8);
const double _trayTop = 0.2;

/// Where food [i] of the menu rests on the food tray (HTML z -3, -1, 1, 3).
_V _homeOf(int i) => _V(-6, _trayTop, -3 + 2.0 * i);

/// Results Tray place [i] (HTML `xOffset = 5.5 + (i % 2) * 3`, `zOffset =
/// -2 + floor(i / 2) * 3`).
_V _slotOf(int i) => _V(5.5 + (i % 2) * 3.0, _trayTop, -2 + (i ~/ 2) * 3.0);

/// Petri dish `CylinderGeometry(1.5, 1.5, 0.2)` at (0, 0.1, 2): bottom
/// centre, radius, height and the height of its inner floor.
const _V _dishAt = _V(0, 0, 2);
const double _dishR = 1.5;
const double _dishH = 0.2;
const double _dishFloor = 0.02;

/// A tested dish sits in the Results Tray at 90 % (the four HTML dishes
/// touch each other at full size).
const double _trayDishScale = 0.9;

/// Iodine bottle at (3, 0, -2): body `CylinderGeometry(0.6, 0.6, 1.5)`, neck
/// `CylinderGeometry(0.3, 0.3, 0.5)`.
const _V _bottleAt = _V(3, 0, -2);
const double _bottleR = 0.6;
const double _bottleH = 1.5;
const double _neckR = 0.3;
const double _neckH = 0.5;

/// The dropper group's origin is the tip of its tube: in the bottle at
/// (3, 1.8, -2), over the dish at (0, 1.8, 2). Tube `CylinderGeometry(0.1,
/// 0.05, 1.2)`, liquid `(0.08, 0.04, 0.8)`, bulb `SphereGeometry(0.25)` at
/// y = 1.3.
const _V _dropperHome = _V(3, 1.8, -2);
const _V _dropperOverDish = _V(0, 1.8, 2);
const double _tubeH = 1.2;
const double _liquidH = 0.8;
const double _bulbY = 1.3;
const double _bulbR = 0.25;

/// Iodine drop `SphereGeometry(0.08)`.
const double _iodineDropR = 0.08;

/// Iodine stain `CircleGeometry(0.25)` on top of the food.
const double _stainR = 0.25;

/// Sheet of paper `PlaneGeometry(3, 4)` at (0, 0.11, 2).
const _V _paperAt = _V(0, 0.11, 2);
const double _paperHalfX = 1.5;
const double _paperHalfZ = 2;

/// A tested paper sits in the Results Tray at half size (HTML
/// `scale.set(0.5, 0.5, 0.5)`).
const double _trayPaperScale = 0.5;

/// The pressed patch `PlaneGeometry(1.5, 1.5)` with a radial gradient: a
/// circle of radius ~0.7.
const double _patchR = 0.72;

/// Where a pressed food is moved aside (HTML x = 1.5, z = 2; here just off
/// the paper so the whole patch shows).
const _V _asideAt = _V(2.3, 0, 2.8);

/// Lamp group at (3, 0, -2): base `CylinderGeometry(0.8, 0.8, 0.2)`, arm and
/// shade. Its shade is aimed at the paper held up in front of it.
const _V _lampAt = _V(3, 0, -2);
const double _lampBaseR = 0.8;
const double _lampBaseH = 0.2;
const _V _shadeAt = _V(2.85, 3.0, -2.05);

/// The paper held up in front of the lamp: its centre, its tilt (turned up
/// about its x axis to face the camera; the HTML's `rotation.x = -π/4`
/// turned it nearly edge-on) and its size while held.
const _V _heldAt = _V(1.1, 2.0, -0.4);
const double _heldTilt = 1.0;
const double _heldScale = 0.8;

/// 'Contains Starch' / 'Contains Fats' box: `BoxGeometry(4, 2, 4)` at
/// (0, 1, -3).
const _V _boxAt = _V(0, 0, -3);
const _V _boxSize = _V(4, 2, 4);

/// Sorted foods sit in the box side by side at this size.
const double _inBoxScale = 0.5;
_V _boxSpotOf(int k) => _V(-1.3 + 1.3 * k, _dishFloor, -3);

/// The large checkmark above the box once every food is sorted.
const _V _checkAt = _V(0, 3.1, -3);
const double _checkR = 0.55;

/// HTML drop tests: the dragged object (held at y = 1.5) is closer than 3
/// (dish, paper), 5 (Results Tray), 4 (lamp) or 3 (box) to the target's
/// position. The same reach measured flat on the bench.
const double _reachDish = 2.65;
const double _reachTray = 4.75;
const double _reachLamp = 3.7;
const double _reachBox = 2.6;

// -------------------------------------------------------------- timings

/// HTML tweens: food onto the dish / paper 300 ms, dropper over the dish
/// 500 ms (Quadratic.InOut), back to its place 300 ms, into the Results
/// Tray 500 ms, the box popping up 500 ms (Elastic.Out), into the box
/// 300 ms (the HTML shrank it to nothing).
const double _snapSeconds = 0.3;
const double _dropperSeconds = 0.5;
const double _returnSeconds = 0.3;
const double _traySeconds = 0.5;
const double _boxPopSeconds = 0.5;
const double _sortSeconds = 0.3;

/// The box flashes green / red for a moment (HTML 300 ms).
const double _flashSeconds = 0.45;

/// Iodine test (`executeS1IodineDrop`): the bulb squeezes (150 ms yoyo); the
/// drop falls from 300 ms for 400 ms (Quadratic.In); the result shows on
/// impact; 1 s later the dish can go to the Results Tray. The dropper goes
/// back to its bottle meanwhile (the HTML left it hanging over the next
/// food).
const double _squeezeEnd = 0.3;
const double _dropLandAt = 0.7;
const double _stainGrowSeconds = 0.15;
const double _dropperBackAt = 1.0;
const double _iodineEnd = 1.7;

/// Paper test (`executeS2Fold`): the far half folds over the food, a press
/// comes down and lifts, the paper unfolds; then the patch shows and the
/// food is moved aside (300 ms). A wet patch dries in 1.5 s.
const double _foldEnd = 0.3;
const double _pressDownEnd = 0.5;
const double _pressUpEnd = 0.7;
const double _unfoldEnd = 1.0;
const double _asideEnd = 1.3;
const double _patchFadeSeconds = 0.3;
const double _drySeconds = 1.5;
const double _foldMax = 0.92;

/// Lamp test: the paper is lifted in front of the lamp (500 ms), the result
/// shows (the oily patch brightens over 500 ms), it is held for 2 s and laid
/// back on the bench (300 ms).
const double _toLampEnd = 0.5;
const double _glowSeconds = 0.5;
const double _holdEnd = 2.5;
const double _lampEnd = 2.8;

/// The box pops up and the checkmark pops in.
const double _checkPopSeconds = 0.4;

// ---------------------------------------------------------------- foods

/// The foods of both scenarios: height above the surface they rest on,
/// footprint radius, and the nutrient the HTML finds in them
/// (`Config.S1_POSITIVE` / `S2_POSITIVE`).
enum _Food {
  /// `CylinderGeometry(0.6, 0.6, 0.1)`, 0xfde047.
  potato(0.1, 0.6, starch: true),

  /// Rind `CylinderGeometry(0.55, …)` 0x166534, flesh r 0.5 0xdcfce3.
  cucumber(0.1, 0.55),

  /// `SphereGeometry(0.4)` scaled y 0.3, 0xf8fafc.
  rice(0.24, 0.42, starch: true),

  /// `BoxGeometry(0.8, 0.1, 0.8)` 0xd97706 in a 0.9 crust 0x78350f.
  bread(0.1, 0.48, starch: true),

  /// Five `SphereGeometry(0.1)` bits, 0xb45309.
  peanuts(0.22, 0.36, fat: true),

  /// `BoxGeometry(0.5, 0.3, 0.5)`, 0xfef08a.
  butter(0.3, 0.36, fat: true),

  /// `CylinderGeometry(0.3, 0.3, 0.05)`, 0xeab308 at opacity 0.8.
  oil(0.05, 0.32, fat: true);

  const _Food(
    this.height,
    this.radius, {
    this.starch = false,
    this.fat = false,
  });

  final double height;
  final double radius;
  final bool starch;
  final bool fat;

  /// Name in sentences (HTML `foods`) and on the scene (HTML `labelDict`).
  String get key => 'food_$name';
  String get labelKey => 'lbl_$name';
}

/// HTML `Config.S1_FOODS` / `S2_FOODS`, in testing order.
const List<List<_Food>> _menus = [
  [_Food.potato, _Food.cucumber, _Food.rice, _Food.bread],
  [_Food.peanuts, _Food.cucumber, _Food.butter, _Food.oil],
];

/// Does [f] pass scenario [sc]'s test (starch / fat)?
bool _positive(int sc, _Food f) => sc == 0 ? f.starch : f.fat;

/// Distance between [a] and [b] measured flat on the bench.
double _flat(_V a, _V b) {
  final dx = a.x - b.x, dz = a.z - b.z;
  return math.sqrt(dx * dx + dz * dz);
}

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Where the scene is drawn: the camera's look-at point lands on [center]
/// and the projection is scaled by [zoom] (1 = the HTML camera). The lab
/// fits the scene beside the cards with it.
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
    final f = (_target - _eye).unit;
    final r = f.cross(_up).unit;
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

  /// The design point of [w] (everything on the bench is in front of the
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
  /// (HTML `raycaster.intersectObject(dragPlane)`).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - _eye.y) / d.y;
    if (t <= 0) return null;
    return _eye + d * t;
  }
}

/// Box corners: bit 0 = +x, bit 1 = +y, bit 2 = +z. Faces as corner indices
/// and their outward normals.
const List<int> _faceCorners = [
  1, 3, 7, 5, // +x
  0, 4, 6, 2, // -x
  2, 6, 7, 3, // +y
  0, 1, 5, 4, // -y
  4, 5, 7, 6, // +z
  0, 2, 3, 1, // -z
];
const List<_V> _faceNormals = [
  _V(1, 0, 0),
  _V(-1, 0, 0),
  _V(0, 1, 0),
  _V(0, -1, 0),
  _V(0, 0, 1),
  _V(0, 0, -1),
];

/// Corner [i] of the box at [c] with half size [h].
_V _corner(_V c, _V h, int i) => _V(
  c.x + ((i & 1) != 0 ? h.x : -h.x),
  c.y + ((i & 2) != 0 ? h.y : -h.y),
  c.z + ((i & 4) != 0 ? h.z : -h.z),
);

/// Is [p] inside the convex quad a-b-c-d (either winding)?
bool _inQuad(Offset p, Offset a, Offset b, Offset c, Offset d) {
  double side(Offset u, Offset v) =>
      (v.dx - u.dx) * (p.dy - u.dy) - (v.dy - u.dy) * (p.dx - u.dx);
  final s1 = side(a, b), s2 = side(b, c), s3 = side(c, d), s4 = side(d, a);
  final neg = s1 < 0 || s2 < 0 || s3 < 0 || s4 < 0;
  final pos = s1 > 0 || s2 > 0 || s3 > 0 || s4 > 0;
  return !(neg && pos);
}

/// Is [p] on the box at [c] (size [size]) as the camera sees it (HTML
/// raycast against a BoxGeometry)?
bool _onBox(Offset p, _Cam cam, _V c, _V size) {
  final h = size * 0.5;
  final pts = [for (var i = 0; i < 8; i++) cam.p(_corner(c, h, i))];
  for (var fi = 0; fi < 6; fi++) {
    final n = _faceNormals[fi];
    final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
    if (n.dot(cam.eye - mid) <= 0) continue;
    final k = fi * 4;
    if (_inQuad(
      p,
      pts[_faceCorners[k]],
      pts[_faceCorners[k + 1]],
      pts[_faceCorners[k + 2]],
      pts[_faceCorners[k + 3]],
    )) {
      return true;
    }
  }
  return false;
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

/// Something that moves on the bench (HTML mesh + TWEEN): where it rests,
/// an optional glide towards there, and where the finger holds it.
class _Body {
  _Body(this.pos);

  /// Resting place (bottom centre), or where the current glide ends.
  _V pos;
  _V _from = _V.zero;
  double _start = 0;
  double _seconds = 0;
  Curve _curve = Curves.linear;

  /// Where the finger holds it (HTML drag at y = 1.5), or null.
  _V? drag;

  /// Where it is at scene time [t].
  _V at(double t) {
    final d = drag;
    if (d != null) return d;
    if (_seconds <= 0) return pos;
    final k = (t - _start) / _seconds;
    if (k >= 1) return pos;
    return _V.lerp(_from, pos, _curve.transform(k.clamp(0.0, 1.0)));
  }

  bool moving(double t) =>
      drag == null && _seconds > 0 && t - _start < _seconds;

  /// HTML `new TWEEN.Tween(position).to(…)`: from where it is now (or where
  /// the finger let go) to [to].
  void glide(
    _V to,
    double t,
    double seconds, {
    Curve curve = Curves.easeOutQuad,
  }) {
    _from = at(t);
    drag = null;
    pos = to;
    _start = t;
    _seconds = seconds;
    _curve = curve;
  }

  /// Puts it at [to] at once.
  void place(_V to) {
    drag = null;
    pos = to;
    _seconds = 0;
  }
}

/// A tested food on its dish (S1) or paper (S2) in the Results Tray (HTML
/// `sortableGrp`), later perhaps in the box.
class _Tested {
  _Tested(this.food, this.positive, this.slot, this.body, this.foodBody);

  final _Food food;

  /// The food passed the test (turned blue-black / left an oily patch).
  final bool positive;

  /// Its Results Tray place.
  final int slot;

  /// The dish or paper (bottom centre).
  final _Body body;

  /// S2: the food gliding from beside the paper onto it in the tray (the
  /// HTML tweened it into the tray group); afterwards it rides on [body].
  final _Body foodBody;

  /// Its place in the box (null: in the Results Tray) and when it went in.
  int? boxSpot;
  double boxStart = -10;

  bool get inBox => boxSpot != null;
}

/// The running animation (HTML `isAnimating`).
enum _Anim { none, iodine, fold, lamp }

/// What a pointer can land on.
enum _Kind { food, dish, dropper, bottle, paper, lamp, tested, box }

/// A scene object under the pointer.
@immutable
class _Hit {
  const _Hit(this.kind, {this.food, this.item});

  final _Kind kind;
  final _Food? food;
  final _Tested? item;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `activeFoodIndex` (4 once every food is tested).
  int index = 0;

  /// HTML `subPhase`: 0 food onto the dish / paper; 1 dropper over the food
  /// (S1) / paper pressed (S2); 2 bulb (S1) / paper to the lamp (S2); 3 dish
  /// or paper to the Results Tray; 4 sorting into the box.
  int phase = 0;

  /// The running animation, its start and how many of its events fired.
  _Anim anim = _Anim.none;
  double animStart = 0;
  int animStage = 0;

  /// The foods of this scenario (resting places and glides).
  final Map<_Food, _Body> foods = {};

  /// S1: the empty petri dish on the bench and the dropper; S2: the sheet
  /// of paper on the bench.
  final _Body dish = _Body(_dishAt);
  final _Body dropper = _Body(_dropperHome);
  final _Body paper = _Body(_paperAt);

  /// S1: the iodine stain on each tested food (true: blue-black) and when
  /// it appeared.
  final Map<_Food, bool> stains = {};
  final Map<_Food, double> stainAt = {};

  /// S2: the patch on the paper on the bench (oily or wet), when it
  /// appeared and when the wet patch started drying.
  bool patchOily = false;
  double patchAt = -1;
  double dryAt = -1;

  /// What the learner observed, in testing order (true: starch / fat).
  final Map<_Food, bool> results = {};

  /// Dishes / papers moved to the Results Tray (HTML `testedFoods` /
  /// `testedPapers`).
  final List<_Tested> tested = [];

  /// HTML `sortedCount` and when the box appeared / the last food went in.
  int boxed = 0;
  double boxShownAt = -1;
  double doneAt = -1;

  /// The box's green / red flash and the outline while an item is held
  /// over it.
  Color flashColor = _Colors.flashGreen;
  double flashUntil = -1;
  bool hoverBox = false;

  /// The object the finger is dragging.
  _Hit? held;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  bool get framingSettled => _framingT >= 1;

  /// HTML `resetScenarioState(sc)`.
  void load(int sc) {
    scenario = sc;
    index = 0;
    phase = 0;
    anim = _Anim.none;
    animStage = 0;
    foods
      ..clear()
      ..addAll({
        for (var i = 0; i < _menus[sc].length; i++)
          _menus[sc][i]: _Body(_homeOf(i)),
      });
    dish.place(_dishAt);
    dropper.place(_dropperHome);
    paper.place(_paperAt);
    stains.clear();
    stainAt.clear();
    _clearPatch();
    results.clear();
    tested.clear();
    boxed = 0;
    boxShownAt = -1;
    doneAt = -1;
    flashUntil = -1;
    hoverBox = false;
    held = null;
  }

  void _clearPatch() {
    patchOily = false;
    patchAt = -1;
    dryAt = -1;
  }

  /// Slides the framing; true while it is still moving.
  void advanceFraming(double dt) {
    if (_framingT >= 1) return;
    _framingT = math.min(1, _framingT + dt / _framingSeconds);
    framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
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

  // ------------------------------------------------------------- queries

  /// The food being tested now.
  _Food get active => _menus[scenario][math.min(index, 3)];

  bool get busy => anim != _Anim.none;
  bool get boxShown => boxShownAt >= 0;
  bool get done => doneAt >= 0;
  double get animTime => time - animStart;

  /// Is [f] in the Results Tray (or the box)?
  _Tested? testedOf(_Food f) {
    for (final t in tested) {
      if (t.food == f) return t;
    }
    return null;
  }

  /// Is the active food sitting on the dish / paper on the bench?
  bool get workingFood =>
      phase >= 1 && phase <= 3 && index < 4 && testedOf(active) == null;

  /// Where food [f] is now (bottom centre): S1's tested food rides on its
  /// dish once it has landed there.
  _V foodAt(_Food f) {
    final b = foods[f]!;
    if (scenario == 0 && f == active && workingFood && !b.moving(time)) {
      return dish.at(time) + const _V(0, _dishFloor, 0);
    }
    return b.at(time);
  }

  /// Where a tested item's food is (bottom centre).
  _V testedFoodAt(_Tested t) {
    if (t.foodBody.moving(time)) return t.foodBody.at(time);
    final k = testedScale(t);
    final top = scenario == 0 ? _dishFloor * k : 0.004;
    return t.body.at(time) + _V(0, top, 0);
  }

  /// Size of a tested item: its tray size, shrinking as it goes into the
  /// box.
  double testedScale(_Tested t) {
    final tray = scenario == 0 ? _trayDishScale : _trayPaperScale;
    if (!t.inBox) return tray;
    final k = ((time - t.boxStart) / _sortSeconds).clamp(0.0, 1.0);
    return tray * (1 + (_inBoxScale - 1) * Curves.easeOut.transform(k));
  }

  /// The dropper is resting in its bottle.
  bool get dropperHome =>
      dropper.drag == null &&
      !dropper.moving(time) &&
      (dropper.pos - _dropperHome).length < 1e-6;

  /// Bulb squeeze (HTML `scale.y` 1 → 0.5 → 1 in 300 ms).
  double get bulbSquash {
    if (anim != _Anim.iodine || animTime >= _squeezeEnd) return 1;
    return 1 - 0.5 * math.sin(math.pi * animTime / _squeezeEnd);
  }

  /// The falling iodine drop, or null.
  _V? get iodineDrop {
    if (anim != _Anim.iodine) return null;
    final e = animTime;
    if (e < _squeezeEnd || e >= _dropLandAt) return null;
    final k = Curves.easeIn.transform(
      (e - _squeezeEnd) / (_dropLandAt - _squeezeEnd),
    );
    final d = dropper.at(time);
    final from = d.y - _iodineDropR;
    final to = _dishFloor + active.height;
    return _V(d.x, from + (to - from) * k, d.z);
  }

  /// Radius of [f]'s iodine stain now.
  double stainRadius(_Food f) {
    final at = stainAt[f];
    if (at == null) return 0;
    return _stainR * ((time - at) / _stainGrowSeconds).clamp(0.0, 1.0);
  }

  /// Fold of the paper's far half over the food (0 … π).
  double get foldAngle {
    if (anim != _Anim.fold) return 0;
    final e = animTime;
    if (e < _foldEnd) {
      return math.pi * _foldMax * Curves.easeInOut.transform(e / _foldEnd);
    }
    if (e < _pressDownEnd) {
      final k = (e - _foldEnd) / (_pressDownEnd - _foldEnd);
      return math.pi * (_foldMax + (1 - _foldMax) * k);
    }
    if (e < _pressUpEnd) return math.pi;
    if (e < _unfoldEnd) {
      final k = (e - _pressUpEnd) / (_unfoldEnd - _pressUpEnd);
      return math.pi * (1 - Curves.easeInOut.transform(k));
    }
    return 0;
  }

  /// Height of the press coming down on the folded paper, or null.
  double? get pressY {
    if (anim != _Anim.fold) return null;
    final e = animTime;
    const top = 1.6, low = 0.2;
    if (e < _foldEnd - 0.1 || e >= _pressUpEnd + 0.1) return null;
    if (e < _foldEnd) return top;
    if (e < _pressDownEnd) {
      final k = (e - _foldEnd) / (_pressDownEnd - _foldEnd);
      return top + (low - top) * Curves.easeIn.transform(k);
    }
    if (e < _pressUpEnd) {
      final k = (e - _pressDownEnd) / (_pressUpEnd - _pressDownEnd);
      return low + (top - low) * Curves.easeOut.transform(k);
    }
    return top;
  }

  /// The patch on the bench paper (0 … 1): fades in, a wet one dries.
  double get patchAlpha {
    if (patchAt < 0) return 0;
    var a = ((time - patchAt) / _patchFadeSeconds).clamp(0.0, 1.0);
    if (!patchOily && dryAt >= 0) {
      a *= 1 - ((time - dryAt) / _drySeconds).clamp(0.0, 1.0);
    }
    return a;
  }

  /// How far the paper is lifted in front of the lamp (0 … 1).
  double get heldT {
    if (anim != _Anim.lamp) return 0;
    final e = animTime;
    if (e < _toLampEnd) return Curves.easeInOut.transform(e / _toLampEnd);
    if (e < _holdEnd) return 1;
    return 1 - ((e - _holdEnd) / (_lampEnd - _holdEnd)).clamp(0.0, 1.0);
  }

  /// The oily patch shining in the lamp light (HTML patch opacity → 0.9
  /// over 500 ms).
  double get patchGlow {
    if (anim != _Anim.lamp || !patchOily) return 0;
    final e = animTime - _toLampEnd;
    if (e < 0) return 0;
    return math.min((e / _glowSeconds).clamp(0.0, 1.0), heldT);
  }

  /// The lamp's result is showing (the paper is held up).
  bool get lampResultShown =>
      anim == _Anim.lamp && animTime >= _toLampEnd && animTime < _holdEnd;

  /// The box's pop-up size (HTML Elastic.Out from 0).
  double get boxScale {
    if (boxShownAt < 0) return 0;
    final k = ((time - boxShownAt) / _boxPopSeconds).clamp(0.0, 1.0);
    return k >= 1 ? 1 : Curves.elasticOut.transform(k);
  }

  /// The checkmark's pop-in size.
  double get checkScale {
    if (doneAt < 0) return 0;
    final k = ((time - doneAt) / _checkPopSeconds).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(k);
  }

  Color? get flash => time < flashUntil ? flashColor : null;

  /// No animation, glide or drag is going on.
  bool get idle {
    if (busy || held != null) return false;
    if (dish.moving(time) || dropper.moving(time) || paper.moving(time)) {
      return false;
    }
    for (final b in foods.values) {
      if (b.moving(time)) return false;
    }
    for (final t in tested) {
      if (t.body.moving(time) || t.foodBody.moving(time)) return false;
    }
    return true;
  }

  // ----------------------------------------------------------- hit tests

  /// The body that a drag of [h] moves.
  _Body bodyOf(_Hit h) => switch (h.kind) {
    _Kind.food => foods[h.food]!,
    _Kind.dish => dish,
    _Kind.dropper || _Kind.bottle => dropper,
    _Kind.paper => paper,
    _Kind.tested => h.item!.body,
    _Kind.lamp || _Kind.box => paper,
  };

  /// Height of [h]'s bottom while it is dragged (its middle at y = 1.5).
  double liftOf(_Hit h) => switch (h.kind) {
    _Kind.food => _dragY - h.food!.height / 2,
    _Kind.dish || _Kind.tested => _dragY - _dishH / 2,
    _ => _dragY,
  };

  /// Can [h] be dragged now (HTML `activeObjects`)?
  bool canDrag(_Hit h) {
    if (busy || done) return false;
    switch (phase) {
      case 0:
        return h.kind == _Kind.food && h.food == active;
      case 1:
        return scenario == 0 &&
            (h.kind == _Kind.dropper || h.kind == _Kind.bottle);
      case 2:
        return scenario == 1 && h.kind == _Kind.paper;
      case 3:
        return h.kind == (scenario == 0 ? _Kind.dish : _Kind.paper);
      case 4:
        return h.kind == _Kind.tested && !h.item!.inBox;
    }
    return false;
  }

  /// Is [h] the tap target now (HTML `clickTargets`): the dropper bulb (S1)
  /// or the paper with the food on it (S2)?
  bool canTap(_Hit h) {
    if (busy || done) return false;
    if (scenario == 0) return phase == 2 && h.kind == _Kind.dropper;
    return phase == 1 && h.kind == _Kind.paper;
  }

  /// The object under the design point [p] (HTML raycast), with [touch]
  /// design px of reach around small objects.
  _Hit? hitAt(Offset p, double touch) {
    final cam = camera();
    // The dropper (in its bottle or over the dish).
    if (scenario == 0) {
      final d = dropper.at(time);
      final a = cam.p(d), b = cam.p(d + const _V(0, _bulbY + _bulbR, 0));
      final w = math.max(_bulbR * cam.scaleAt(d) * 1.6, touch);
      if (_segmentDistance(p, a, b) <= w) return const _Hit(_Kind.dropper);
    }
    // The dish / paper on the bench, with the food on it.
    if (scenario == 0) {
      final c = dish.at(time);
      final g = cam.onPlaneY(p, c.y + _dishH);
      final inside = g != null && _flat(g, c) <= _dishR;
      if (inside || (p - cam.p(c)).distance <= touch) {
        return const _Hit(_Kind.dish);
      }
    } else if (heldT == 0) {
      final c = paper.at(time);
      final g = cam.onPlaneY(p, c.y);
      const m = 0.15;
      final inside =
          g != null &&
          (g.x - c.x).abs() <= _paperHalfX + m &&
          (g.z - c.z).abs() <= _paperHalfZ + m;
      if (inside || (p - cam.p(c)).distance <= touch) {
        return const _Hit(_Kind.paper);
      }
    }
    // Foods on the food tray (or beside the paper), nearest first.
    _Food? best;
    var bestD = double.infinity;
    for (final f in foods.keys) {
      if (testedOf(f) != null) continue;
      if (scenario == 0 && f == active && workingFood) continue;
      if (scenario == 1 && f == active && phase == 1) continue;
      final at = foodAt(f);
      final c = at + _V(0, f.height / 2, 0);
      final reach = math.max(f.radius * cam.scaleAt(c), touch);
      final d = (p - cam.p(c)).distance;
      if (d <= reach && d < bestD) {
        best = f;
        bestD = d;
      }
    }
    if (best != null) return _Hit(_Kind.food, food: best);
    // Dishes / papers in the Results Tray.
    _Tested? item;
    bestD = double.infinity;
    for (final t in tested) {
      if (t.inBox) continue;
      final c = t.body.at(time);
      final k = testedScale(t);
      final g = cam.onPlaneY(p, c.y + 0.1);
      final inside =
          g != null &&
          (scenario == 0
              ? _flat(g, c) <= _dishR * k
              : (g.x - c.x).abs() <= _paperHalfX * k &&
                    (g.z - c.z).abs() <= _paperHalfZ * k);
      final d = (p - cam.p(c)).distance;
      if ((inside || d <= touch) && d < bestD) {
        item = t;
        bestD = d;
      }
    }
    if (item != null) return _Hit(_Kind.tested, item: item);
    // The bottle / lamp, then the box.
    if (scenario == 0) {
      final a = cam.p(_bottleAt + const _V(0, 0.2, 0));
      final b = cam.p(_bottleAt + const _V(0, _bottleH + _neckH, 0));
      final w = math.max(_bottleR * cam.scaleAt(_bottleAt), touch * 0.6);
      if (_segmentDistance(p, a, b) <= w) return const _Hit(_Kind.bottle);
    } else {
      final a = cam.p(_lampAt + const _V(0, 0.2, 0));
      final b = cam.p(_shadeAt);
      final w = math.max(0.5 * cam.scaleAt(_lampAt), touch * 0.6);
      if (_segmentDistance(p, a, b) <= w) return const _Hit(_Kind.lamp);
    }
    if (boxShown &&
        _onBox(p, cam, _boxAt + _V(0, _boxSize.y / 2, 0), _boxSize)) {
      return const _Hit(_Kind.box);
    }
    return null;
  }

  // ------------------------------------- named points for the flow tests

  /// Design point of a named place in the current framing (used by the
  /// instruction-flow tests): 'food' (the food to test now) or
  /// 'food:NAME', 'dropper' (its tube), 'bulb', 'overDish' (the dropper's
  /// place over the dish, at the height of 'dropper'), 'dish', 'dishFront'
  /// (its front rim, away from the dropper), 'paper', 'lamp' (in front of
  /// the lamp), 'bottle', 'tray' (the Results Tray), 'box', 'tested:NAME'
  /// (a dish / paper in the tray) and 'open' (a free spot on the bench).
  Offset anchor(String id) {
    final cam = camera();
    if (id == 'food' || id.startsWith('food:')) {
      final f = id == 'food'
          ? active
          : _Food.values.firstWhere((x) => x.name == id.substring(5));
      return cam.p(foodAt(f) + _V(0, f.height / 2, 0));
    }
    if (id.startsWith('tested:')) {
      final t = testedOf(
        _Food.values.firstWhere((x) => x.name == id.substring(7)),
      );
      if (t != null) return cam.p(t.body.at(time) + const _V(0, 0.15, 0));
    }
    final d = dropper.at(time);
    return switch (id) {
      'dropper' => cam.p(d + const _V(0, 0.55, 0)),
      'bulb' => cam.p(d + const _V(0, _bulbY, 0)),
      'overDish' => cam.p(_dropperOverDish + const _V(0, 0.55, 0)),
      'dish' => cam.p(dish.at(time) + const _V(0, 0.15, 0)),
      'dishFront' => cam.p(dish.at(time) + const _V(0, 0.1, _dishR - 0.2)),
      'paper' => cam.p(paper.at(time)),
      'lamp' => cam.p(const _V(1.5, 0.11, -0.5)),
      'bottle' => cam.p(_bottleAt + const _V(0, 0.8, 0)),
      'tray' => cam.p(_resultsC + const _V(0, 0.1, 0)),
      'box' => cam.p(_boxAt + const _V(0, 0.2, 0)),
      'open' => cam.p(const _V(-2.5, 0.05, 5.5)),
      _ => _designCenter,
    };
  }

  // ---------------------------------------- plain readouts for the tests
  String get activeName => active.name;
  Map<String, bool> get resultNames => {
    for (final e in results.entries) e.key.name: e.value,
  };
  List<String> get trayNames => [
    for (final t in tested)
      if (!t.inBox) t.food.name,
  ];
  List<String> get boxNames => [
    for (final t in tested)
      if (t.inBox) t.food.name,
  ];
  Map<String, bool> get stainNames => {
    for (final e in stains.entries) e.key.name: e.value,
  };
  bool get dropperOverDish =>
      dropper.drag == null &&
      (dropper.pos - _dropperOverDish).length < 1e-6 &&
      !dropper.moving(time);
  bool get foodOnWorkplace =>
      workingFood || (scenario == 1 && phase >= 1 && index < 4);
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

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a scene object ([canGrab]), so other touches still pan / zoom the
/// canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _FoodTestsLabState extends State<Ch3A4ChemicalTestsForFoodNutrientsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay): measured to fit the
  /// scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch3-a4-canvas');

  /// 1-based current step, derived from the scene ([_deriveStep]);
  /// steps.length + 1 once the scenario is done.
  int _step = 1;

  /// The current scenario's conclusion has been scheduled.
  bool _concluded = false;

  /// Touch radius and label size in design px for the current stage scale,
  /// and the canvas's left edge and the tool column's left edge (design px):
  /// labels are kept between them.
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelLeft = 0;
  double _labelRight = _design.width;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// What the current pointer went down on, where, and the drag-plane
  /// offset of the grab (HTML `dragOffset`).
  _Hit? _grab;
  Offset _downAt = Offset.zero;
  _V _grabOffset = _V.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

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
    s.advanceFraming(dt);
    _advanceAnim();
    _frame.value = now;
  }

  /// The timed events of the running test (the HTML `setTimeout` /
  /// `onComplete` chains), fired once each from the frame clock, so a
  /// scenario change or leaving the page stops them with the ticker.
  void _advanceAnim() {
    final s = _scene;
    if (!s.busy) return;
    final e = s.animTime;
    final f = s.active;
    final positive = _positive(s.scenario, f);
    final name = {'food': _t(f.key)};
    switch (s.anim) {
      case _Anim.iodine:
        if (s.animStage == 0 && e >= _squeezeEnd) {
          s.animStage = 1;
          _Sound.drop.play();
        }
        if (s.animStage == 1 && e >= _dropLandAt) {
          // The drop lands: blue-black (starch) or the brown iodine stays.
          s.animStage = 2;
          s.stains[f] = positive;
          s.stainAt[f] = s.time;
          s.results[f] = positive;
          if (positive) {
            _Sound.correct.play();
            _lab.showToast(_t('toast_1_pos'), sound: false);
          } else {
            // A negative result is not a mistake: the HTML's neutral pop
            // (it showed the text in error red).
            _Sound.pop.play();
            _lab.showToast(labFormat(_t('toast_1_neg'), name), sound: false);
          }
          _refresh();
        }
        if (s.animStage == 2 && e >= _dropperBackAt) {
          s.animStage = 3;
          s.dropper.glide(
            _dropperHome,
            s.time,
            _dropperSeconds,
            curve: Curves.easeInOutQuad,
          );
        }
        if (s.animStage == 3 && e >= _iodineEnd) _endAnim(3);
      case _Anim.fold:
        if (s.animStage == 0 && e >= _unfoldEnd) {
          // The paper is open again: the patch shows and the food is moved
          // aside.
          s.animStage = 1;
          s.patchOily = positive;
          s.patchAt = s.time;
          s.foods[f]!.glide(_asideAt, s.time, _asideEnd - _unfoldEnd);
          if (!positive) _lab.showToast(_t('toast_drying'), sound: false);
        }
        if (s.animStage == 1 && e >= _asideEnd) {
          s.animStage = 2;
          if (positive) {
            _endAnim(2);
            return;
          }
          s.dryAt = s.time;
        }
        if (s.animStage == 2 && e >= _asideEnd + _drySeconds) _endAnim(2);
      case _Anim.lamp:
        if (s.animStage == 0 && e >= _toLampEnd) {
          // Held up to the light: the oily patch lets it through.
          s.animStage = 1;
          s.results[f] = positive;
          if (positive) {
            _Sound.correct.play();
            _lab.showToast(_t('toast_2_pos'), sound: false);
          } else {
            _Sound.pop.play();
            _lab.showToast(labFormat(_t('toast_2_neg'), name), sound: false);
          }
          _refresh();
        }
        if (s.animStage == 1 && e >= _holdEnd) {
          s.animStage = 2;
          s.paper.glide(
            _paperAt,
            s.time,
            _lampEnd - _holdEnd,
            curve: Curves.easeInOut,
          );
        }
        if (s.animStage == 2 && e >= _lampEnd) _endAnim(3);
      case _Anim.none:
        break;
    }
  }

  /// The running test is over: on to sub-phase [phase].
  void _endAnim(int phase) {
    _scene
      ..anim = _Anim.none
      ..animStage = 0
      ..phase = phase;
    _refresh();
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

  /// Fits the bench (objects and labels) into the part of the canvas no
  /// card covers: the tool column, the HUD (sidebar open) and the floating
  /// mission card (sidebar collapsed).
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
    _labelLeft = (4 - stage.dx) / fit;
    _labelRight = (size.width - insets.right - stage.dx) / fit;
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

  /// What the learner must see: the trays, the dish or paper, the bottle or
  /// lamp, the box with its checkmark and the paper held up to the lamp
  /// (HTML camera, zoom 1), and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final sc = _scene.scenario;
    final items = <_Focus>[];
    void box(_V min, _V max) {
      final c = (min + max) * 0.5;
      final h = (max - min) * 0.5;
      for (var i = 0; i < 8; i++) {
        items.add((cam.p(_corner(c, h, i)), Rect.zero));
      }
    }

    void label(_V at, (double, double) align, String text, double scale) {
      final size = _cache.chipSize(text, scale: scale);
      items.add((cam.p(at), _chipOffset(size, align) & size));
    }

    box(const _V(-8, 0, -4), const _V(-4, _trayTop, 4));
    box(const _V(4, 0, -4), const _V(10, _trayTop, 4));
    box(const _V(-2, 0, -5), const _V(2, 2, -1));
    items.add((cam.p(_checkAt + const _V(0, _checkR, 0)), Rect.zero));
    if (sc == 0) {
      box(const _V(-1.5, 0, 0.5), const _V(1.5, _dishH, 3.5));
      box(const _V(2.4, 0, -2.6), const _V(3.6, 3.4, -1.4));
      label(_iodineLabelAt, (0, 1), _t('lbl_iodine'), 1);
      final longest = [
        _t('lbl_dish'),
        _t('res_1_pos'),
        _t('res_1_neg'),
      ].reduce((a, b) => a.length >= b.length ? a : b);
      label(_dishLabelAt(_dishAt), (0, -1), longest, 1);
    } else {
      box(const _V(-1.5, 0, 0), const _V(1.5, 0.2, 4));
      box(const _V(2.2, 0, -2.8), const _V(3.8, 3.6, -1.2));
      box(_heldAt - const _V(1.3, 1.6, 0.6), _heldAt + const _V(1.3, 1.6, 0.6));
      label(_lampLabelAt, (0, 1), _t('lbl_lamp'), 1);
      label(_paperLabelAt, (0, -1), _t('lbl_paper'), 1);
    }
    for (var i = 0; i < 4; i++) {
      final f = _menus[sc][i];
      label(
        _trayLabelAt(f, _homeOf(i)),
        (1, 0),
        _t(f.labelKey),
        _smallLabelScale,
      );
      final slot = _slotOf(i);
      label(
        _testedLabelAt(i, slot),
        (0, i < 2 ? 1 : -1),
        _t(f.labelKey),
        _smallLabelScale,
      );
    }
    label(_resultsLabelAt, (0, -1), _t('lbl_tray'), 1);
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and animation and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _step = 1;
      _concluded = false;
      _cardRect = null;
      _grab = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// The HTML step ladder (`progressStep`): the first food's sub-phases are
  /// steps 1–4, the second food (and the first food's trip to the Results
  /// Tray) step 4, the third and fourth step 5, sorting step 6.
  int _deriveStep() {
    final s = _scene;
    if (s.done) return _stepCounts[s.scenario] + 1;
    if (s.phase == 4) return 6;
    if (s.index == 0) return s.phase + 1;
    if (s.index == 1) return 4;
    return 5;
  }

  /// Rebuilds after a scene event and schedules the conclusion once every
  /// food is sorted.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
    if (_concluded || !_scene.done) return;
    _concluded = true;
    _showConclusion(_conclusionDelay);
  }

  /// HTML `triggerConclusion()`: the summary popup (Continue after
  /// Scenario 1, Restart Lab after Scenario 2).
  void _showConclusion(Duration delay) {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: delay,
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _summary(
          _lab.palette,
          context.labScale * _lab.fontScale.clamp(0.9, 1.4),
        ),
      ),
    );
  }

  /// The canvas HUD line: the HTML `s1_sub` / `s2_sub` line of the current
  /// sub-phase (with the food's name), `hud[6]` while sorting, and the
  /// HTML's "Excellent!" line once done.
  String get _hud {
    final s = _scene;
    if (s.done) return _t('hud_done');
    if (s.phase == 4) return _t('s${s.scenario + 1}_hud_6');
    return labFormat(_t('s${s.scenario + 1}_sub_${s.phase}'), {
      'food': _t(s.active.key),
    });
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown` raycast: only objects of the scene can be held, and
  /// nothing while a test is running (HTML `isAnimating`).
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grab != null || s.busy || s.done) return false;
    return s.hitAt(event.localPosition, _touch) != null;
  }

  void _onDown(DragDownDetails d) {
    _grab = _scene.hitAt(d.localPosition, _touch);
    _downAt = d.localPosition;
  }

  /// HTML `startDrag`: the object whose turn it is follows the finger; any
  /// other object stays and the learner is told what to do first.
  void _onDragStart(DragStartDetails d) {
    final s = _scene;
    final h = _grab;
    if (h == null || s.held != null) return;
    if (!s.canDrag(h)) {
      _grab = null;
      _hintFirst();
      return;
    }
    final body = s.bodyOf(h);
    final hit = s.camera().onPlaneY(_downAt, _dragY);
    final at = body.at(s.time);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - at.x, 0, hit.z - at.z);
    s.held = h;
    _Sound.pickup.play();
    _move(d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) => _move(d.localPosition);

  /// HTML `handleMove`: the held object follows the finger on the drag
  /// plane, lifted to y = 1.5.
  void _move(Offset p) {
    final s = _scene;
    final h = s.held;
    if (h == null) return;
    final hit = s.camera().onPlaneY(p, _dragY);
    if (hit == null) return;
    final body = s.bodyOf(h);
    final at = _V(
      (hit.x - _grabOffset.x).clamp(-_benchHalfX + 1, _benchHalfX - 1),
      s.liftOf(h),
      (hit.z - _grabOffset.z).clamp(-_benchHalfZ + 0.5, _benchHalfZ - 0.5),
    );
    body.drag = at;
    s.hoverBox = h.kind == _Kind.tested && _flat(at, _boxAt) < _reachBox;
  }

  void _onDragEnd(DragEndDetails _) => _release();

  void _onDragCancel() => _release(cancel: true);

  /// HTML `handleUp`: the drop is judged where the object was let go.
  void _release({bool cancel = false}) {
    final s = _scene;
    final h = s.held;
    _grab = null;
    s
      ..held = null
      ..hoverBox = false;
    if (h == null) return;
    final body = s.bodyOf(h);
    final at = body.drag ?? body.at(s.time);
    if (cancel) {
      body.glide(_homeFor(h), s.time, _returnSeconds);
      return;
    }
    _drop(h, at);
  }

  /// Where [h] goes back to after a missed drop (HTML `userData.initPos`).
  _V _homeFor(_Hit h) => switch (h.kind) {
    _Kind.food => _homeOf(_menus[_scene.scenario].indexOf(h.food!)),
    _Kind.dropper || _Kind.bottle => _dropperHome,
    _Kind.dish => _dishAt,
    _Kind.tested => _slotOf(h.item!.slot),
    _ => _paperAt,
  };

  /// HTML `handleS1Up` / `handleS2Up`.
  void _drop(_Hit h, _V at) {
    final s = _scene;
    final t = s.time;
    final sc = s.scenario;
    final body = s.bodyOf(h);
    final name = {'food': _t(s.active.key)};
    switch (s.phase) {
      case 0:
        // The food onto the petri dish / the paper.
        final target = sc == 0
            ? _dishAt + const _V(0, _dishFloor, 0)
            : _paperAt + const _V(0, 0.004, 0);
        if (_flat(at, target) < _reachDish) {
          body.glide(target, t, _snapSeconds);
          s.phase = 1;
          _Sound.pop.play();
          _refresh();
        } else {
          body.glide(_homeFor(h), t, _returnSeconds);
          _miss(sc == 0 ? 'miss_food_1' : 'miss_food_2', name);
        }
      case 1:
        // S1: the dropper over the food.
        if (_flat(at, _dishAt) < _reachDish) {
          body.glide(
            _dropperOverDish,
            t,
            _dropperSeconds,
            curve: Curves.easeInOutQuad,
          );
          s.phase = 2;
          _Sound.pop.play();
          _refresh();
        } else {
          body.glide(_homeFor(h), t, _returnSeconds);
          _miss('miss_dropper', name);
        }
      case 2:
        // S2: the paper in front of the lamp.
        if (_flat(at, _lampAt) < _reachLamp) {
          body.glide(_heldAt, t, _toLampEnd, curve: Curves.easeInOut);
          s
            ..anim = _Anim.lamp
            ..animStart = t
            ..animStage = 0;
          _Sound.pop.play();
        } else {
          body.glide(_homeFor(h), t, _returnSeconds);
          _miss('miss_lamp', name);
        }
      case 3:
        // The used dish / paper to the Results Tray.
        if (_flat(at, _resultsC) < _reachTray) {
          _toTray(at);
        } else {
          body.glide(_homeFor(h), t, _returnSeconds);
          _miss('miss_tray_${sc + 1}', name);
        }
      case 4:
        _sort(h.item!, at);
    }
  }

  /// HTML results-tray drop: the dish (with its food) or the paper (and
  /// the food beside it) goes to its tray place; a fresh dish / paper is
  /// put out; the next food's turn, or sorting after the fourth.
  void _toTray(_V at) {
    final s = _scene;
    final t = s.time;
    final sc = s.scenario;
    final f = s.active;
    final slot = _slotOf(s.index);
    final body = _Body(at)..glide(slot, t, _traySeconds);
    final foodBody = _Body(sc == 0 ? slot : s.foodAt(f));
    if (sc == 1) {
      foodBody.glide(slot + const _V(0, 0.004, 0), t, _traySeconds);
    }
    s.tested.add(
      _Tested(f, s.results[f] ?? _positive(sc, f), s.index, body, foodBody),
    );
    if (sc == 0) {
      s.dish.place(_dishAt);
    } else {
      s.paper.place(_paperAt);
      s._clearPatch();
    }
    s
      ..index += 1
      ..phase = 0;
    if (s.index >= _menus[sc].length) {
      s
        ..phase = 4
        ..boxShownAt = t;
    }
    _Sound.correct.play();
    _refresh();
  }

  /// HTML sorting drop on the box: a food that passed goes in (green
  /// flash); one that did not is refused (red flash) and goes back to the
  /// tray.
  void _sort(_Tested item, _V at) {
    final s = _scene;
    final t = s.time;
    final sc = s.scenario;
    final name = {'food': _t(item.food.key)};
    final home = _slotOf(item.slot);
    if (_flat(at, _boxAt) >= _reachBox) {
      item.body.glide(home, t, _returnSeconds);
      _miss('miss_box_${sc + 1}', name);
      return;
    }
    if (!item.positive) {
      item.body.glide(home, t, _returnSeconds);
      s
        ..flashColor = _Colors.flashRed
        ..flashUntil = t + _flashSeconds;
      _lab.showToast(
        labFormat(_t('toast_wrong_${sc + 1}'), name),
        isError: true,
      );
      return;
    }
    final k = s.boxed++;
    item
      ..boxSpot = k
      ..boxStart = t;
    item.body.glide(_boxSpotOf(k), t, _sortSeconds);
    s
      ..flashColor = _Colors.flashGreen
      ..flashUntil = t + _flashSeconds;
    _Sound.correct.play();
    _lab.showToast(labFormat(_t('toast_right_${sc + 1}'), name), sound: false);
    final positives = _menus[sc].where((f) => _positive(sc, f)).length;
    if (s.boxed >= positives) s.doneAt = t;
    _refresh();
  }

  /// A drop that missed its target: the object glides back (HTML `pop`)
  /// and the learner is told where to let go.
  void _miss(String key, Map<String, Object> values) {
    _Sound.pop.play();
    _lab.showToast(labFormat(_t(key), values), isError: true, sound: false);
  }

  /// An object touched before its turn.
  void _hintFirst() {
    final text = _scene.phase == 4
        ? _hud
        : labFormat(_t('toast_first'), {'task': _hud});
    _lab.showToast(text, isError: true);
  }

  /// HTML `clickTargets`: the dropper bulb (S1) or the paper (S2). A tap on
  /// the object whose turn it is shows how to move it; on any other
  /// object, what to do first.
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done || s.held != null) return;
    final h = s.hitAt(d.localPosition, _touch);
    if (h == null) return;
    if (s.canTap(h)) {
      s
        ..anim = s.scenario == 0 ? _Anim.iodine : _Anim.fold
        ..animStart = s.time
        ..animStage = 0;
      // HTML `click` (bulb) / `paper` (the paper pressed).
      (s.scenario == 0 ? _Sound.click : _Sound.pickup).play();
      return;
    }
    if (s.canDrag(h)) {
      _Sound.pop.play();
      _lab.showToast(_hud, sound: false);
      return;
    }
    _hintFirst();
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#compare-btn-container` ("Review Findings"), shown once every
  /// food is sorted: re-opens the summary.
  List<LabAction> _actions() => [
    if (_scene.done)
      LabAction(
        label: _t('btn_review'),
        icon: Icons.fact_check,
        color: _Colors.teal600,
        foreground: _Colors.white,
        silent: true,
        onTap: () => _showConclusion(Duration.zero),
      ),
  ];

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
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_table'),
          sidebarExtra: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _results(p, f),
              SizedBox(height: 14 * s),
              LabSectionLabel(
                _t('concept_exp'),
                size: 10.5 * s,
                icon: Icons.format_list_numbered,
              ),
              SizedBox(height: 8 * s),
              _StepsAccordion(
                key: ValueKey('steps-$sc-$_step'),
                steps: data.steps,
                notes: [
                  for (var i = 1; i <= data.steps.length; i++)
                    _t('step_${sc + 1}_${i}_e'),
                ],
                current: _step,
                palette: p,
                scale: s,
                fontScale: f,
                stepLabel: _t('exploration'),
                conceptLabel: _t('concept_focus'),
                actionLabel: _t('action'),
                observationLabel: _t('observation'),
                noteLabel: _t('explanation'),
                pendingText: _t('obs_pending'),
              ),
            ],
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
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = _onDragCancel,
                  ),
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
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
                    labelLeft: _labelLeft,
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

  /// The test results so far (sidebar, summary popup).
  Widget _results(LabPalette p, double scale) {
    final s = _scene;
    final sc = s.scenario;
    return _ResultsTable(
      rows: [
        for (final f in _menus[sc])
          _ResultRow(
            name: _t(f.key),
            result: switch (s.results[f]) {
              null => null,
              final bool pos => _t(
                'res_short_${sc + 1}_${pos ? 'pos' : 'neg'}',
              ),
            },
            swatch: switch (s.results[f]) {
              null => null,
              final bool pos => _swatchOf(sc, pos),
            },
            inBox: s.testedOf(f)?.inBox ?? false,
          ),
      ],
      foodLabel: _t('tbl_food'),
      testLabel: _t('tbl_test_${sc + 1}'),
      pending: _t('res_untested'),
      palette: p,
      scale: scale,
    );
  }

  /// HTML summary visual: what was found in the box, the key and the test
  /// results.
  Widget _summary(LabPalette p, double scale) {
    final s = _scene;
    final sc = s.scenario;
    final boxColor = sc == 0 ? _Colors.boxStarch : _Colors.boxFat;
    final members = [
      for (final t in s.tested)
        if (t.inBox) _t(t.food.key),
    ].join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 8 * scale,
          ),
          decoration: BoxDecoration(
            color: boxColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: boxColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 18 * scale,
                color: p.ink(boxColor),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  '${_t('lbl_box_${sc + 1}')}: $members',
                  style: TextStyle(
                    color: p.textStrong,
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          _t('key_${sc + 1}'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.accentInk,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8 * scale),
        _results(p, scale),
      ],
    );
  }
}

/// The colour a test result shows: blue-black or the brown iodine (S1), an
/// oily or a dried wet patch (S2).
Color _swatchOf(int sc, bool positive) => sc == 0
    ? (positive ? _Colors.stainStarch : _Colors.stainNone)
    : (positive ? _Colors.oil : _Colors.wetPatch);

/// One row of the results table.
@immutable
class _ResultRow {
  const _ResultRow({
    required this.name,
    required this.result,
    required this.swatch,
    required this.inBox,
  });

  final String name;

  /// What the test showed, or null while untested.
  final String? result;
  final Color? swatch;

  /// Sorted into the box.
  final bool inBox;
}

/// "Test Results": each food and what its test showed (a colour swatch and
/// the observation), with a tick once it is in the box.
class _ResultsTable extends StatelessWidget {
  const _ResultsTable({
    required this.rows,
    required this.foodLabel,
    required this.testLabel,
    required this.pending,
    required this.palette,
    required this.scale,
  });

  final List<_ResultRow> rows;
  final String foodLabel;
  final String testLabel;
  final String pending;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
    );
    final body = TextStyle(
      color: p.text,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    Widget row(Widget a, Widget b, {Color? fill, bool divider = true}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: fill,
          border: divider ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: a),
            SizedBox(width: 6 * f),
            Expanded(flex: 5, child: b),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Text(foodLabel, style: head),
            Text(testLabel, style: head),
            fill: p.cardBorder.withValues(alpha: 0.3),
            divider: false,
          ),
          for (final r in rows)
            row(
              Row(
                children: [
                  Flexible(child: Text(r.name, style: body)),
                  if (r.inBox) ...[
                    SizedBox(width: 4 * f),
                    Icon(Icons.inventory_2, size: 13 * f, color: p.success),
                  ],
                ],
              ),
              r.result == null
                  ? Text(
                      pending,
                      style: body.copyWith(
                        color: p.textMuted,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 11 * f,
                          height: 11 * f,
                          margin: EdgeInsets.only(top: 2 * f, right: 5 * f),
                          decoration: BoxDecoration(
                            color: r.swatch,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.textMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            r.result!,
                            style: body.copyWith(
                              color: p.textStrong,
                              fontWeight: FontWeight.w800,
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

/// HTML teacher-board accordion ("Observation Step"): one card per step
/// with its focus, action, result and note. The current step is open, done
/// steps show a tick and can be re-opened, future steps are dimmed. A
/// step's result and note are shown once the step is done (the HTML showed
/// them before the learner had seen it).
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.notes,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.conceptLabel,
    required this.actionLabel,
    required this.observationLabel,
    required this.noteLabel,
    required this.pendingText,
  });

  final List<LabStep> steps;
  final List<String> notes;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String conceptLabel;
  final String actionLabel;
  final String observationLabel;
  final String noteLabel;
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

  Widget _text(String text, Color color, {bool muted = false}) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 11.5 * widget.fontScale,
      fontWeight: muted ? FontWeight.w500 : FontWeight.w600,
      fontStyle: muted ? FontStyle.italic : FontStyle.normal,
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
    // Future steps: dimmed and closed.
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
                  _text(step.concept, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _text(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  if (past)
                    _text(step.observation, p.text)
                  else
                    _text(w.pendingText, p.textMuted, muted: true),
                  if (past && w.notes[i - 1].isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    _heading(w.noteLabel, p.textStrong),
                    SizedBox(height: 3 * s),
                    _text(w.notes[i - 1], p.textMuted, muted: true),
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

/// Label chips (HTML `createTextSprite`): padding and corner radius as
/// fractions of the label size.
const double _chipPadX = 0.6;
const double _chipPadY = 0.3;
const double _chipRadius = 0.45;

/// Top-left of a chip of [size] relative to its anchor: [align] x -1 puts
/// the anchor on the chip's left edge, 0 at its centre, 1 on its right
/// edge; y 1 on its bottom edge (chip above), 0 at its middle, -1 on its
/// top edge (chip below).
Offset _chipOffset(Size size, (double, double) align) => Offset(
  -(align.$1 + 1) / 2 * size.width,
  align.$2 >= 1 ? -size.height : (align.$2 <= -1 ? 0 : -size.height / 2),
);

/// Label anchors. The HTML sprites float above their objects, where the
/// food names would stack up on a phone; here the food names stand beside
/// their foods, the dish / paper names and the Results Tray's under them,
/// the Iodine Solution / Testing Lamp names above the bottle / lamp, and
/// the box's name on its front, like a label stuck on it.
const _V _iodineLabelAt = _V(3, 3.75, -2);
const _V _lampLabelAt = _V(3, 4.0, -2);
const _V _paperLabelAt = _V(0, 0.11, 4.3);
const _V _resultsLabelAt = _V(7, _trayTop, 4.3);
const _V _boxLabelAt = _V(0, 1.3, -1);
_V _dishLabelAt(_V dish) => dish + const _V(0, 0, _dishR + 0.25);
_V _trayLabelAt(_Food f, _V at) => at + _V(-f.radius - 0.25, f.height / 2, 0);
_V _testedLabelAt(int slot, _V at) => at + _V(0, 0.1, slot < 2 ? -1.45 : 1.45);

/// Peanut bits of the crushed peanuts (HTML: five spheres at random
/// offsets within ±0.25; fixed here), back to front.
const List<(double, double)> _peanutBits = [
  (-0.14, -0.16),
  (0.13, -0.1),
  (-0.02, 0.0),
  (-0.18, 0.12),
  (0.16, 0.14),
];

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Round-ended lines (lamp arm, check mark, rice grains).
  final Paint bar = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();

  /// Projected corners of the box being drawn.
  final List<Offset> corners = List<Offset>.filled(8, Offset.zero);

  /// Affine map of a flat disc (stains, patches) onto its plane.
  final Matrix4 disc = Matrix4.identity();
}

/// What the painter makes once and reuses: pens, label text painters and
/// gradient paints. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<Color, Paint> _spheres = {};
  final Map<int, Paint> _patches = {};
  LabLang? _lang;
  double _labelSize = _labelPx;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeText();
    _lang = lang;
    _labelSize = labelSize;
  }

  /// [text] in [color] at the label size.
  TextPainter label(String text, Color color) =>
      _labels['${color.toARGB32()}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: _labelSize,
            fontWeight: FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Size of a label chip of [text] (see [_ScenePainter._chip]).
  Size chipSize(String text, {double scale = 1}) {
    final tp = label(text, _Colors.chipText);
    final w = tp.width + 2 * _labelSize * _chipPadX;
    final h = tp.height + 2 * _labelSize * _chipPadY;
    return Size(w * scale, h * scale);
  }

  /// MeshStandardMaterial shading of a unit sphere at the origin in
  /// [color] (drawn scaled and moved into place), made once per colour.
  Paint sphere(Color color) =>
      _spheres[color] ??= Paint()
        ..shader = ui.Gradient.radial(
          const Offset(-0.35, -0.4),
          1.35,
          [labShade(color, 0.45), color, labShade(color, -0.5)],
          const [0, 0.5, 1],
        );

  /// A unit disc of [color] fading out at its rim (the HTML canvas
  /// gradients of the patches), with its opacity in 5 % steps.
  Paint patch(Color color) {
    final a = (color.a * 20).round().clamp(0, 20);
    final c = color.withValues(alpha: a / 20);
    return _patches[c.toARGB32()] ??= Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        [c, c, c.withValues(alpha: 0)],
        const [0, 0.35, 1],
      );
  }

  void _disposeText() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeText();
    _spheres.clear();
    _patches.clear();
  }
}

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

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (cam.p(c + _V(0, 0, radius)).dy - cam.p(c - _V(0, 0, radius)).dy).abs() /
      2;

  /// The ellipse a horizontal circle of [radius] at [c] projects to.
  Rect oval(_V c, double radius) => Rect.fromCenter(
    center: cam.p(c),
    width: 2 * radius * cam.scaleAt(c),
    height: 2 * ellipseHalf(c, radius),
  );

  /// BoxGeometry centred at [c]: the faces turned to the camera (a convex
  /// box needs no sorting), lit, with an optional rim.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.3,
  }) {
    final h = size * 0.5;
    final pts = pens.corners;
    for (var i = 0; i < 8; i++) {
      pts[i] = cam.p(_corner(c, h, i));
    }
    for (var fi = 0; fi < 6; fi++) {
      final n = _faceNormals[fi];
      final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var k = 0; k < 4; k++) {
        _to(path, k, pts[_faceCorners[fi * 4 + k]]);
      }
      path.close();
      final fill = _lit(color, n);
      canvas.drawPath(
        path,
        pens.fill..color = fill.withValues(alpha: fill.a * opacity),
      );
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// A flat quad a-b-c-d in [color]; optional rim [edge].
  void quad(_V a, _V b, _V c, _V d, Color color, {Color? edge}) {
    final path = pens.path
      ..reset()
      ..moveTo(cam.p(a).dx, cam.p(a).dy)
      ..lineTo(cam.p(b).dx, cam.p(b).dy)
      ..lineTo(cam.p(c).dx, cam.p(c).dy)
      ..lineTo(cam.p(d).dx, cam.p(d).dy)
      ..close();
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

  /// Upright CylinderGeometry standing on [bottom]: side with a highlight
  /// and a shadow band, then the top cap in [cap] (default: [color]).
  void cylinder(
    _V bottom,
    double radius,
    double height,
    Color color, {
    double topRadius = -1,
    double opacity = 1,
    Color? cap,
  }) {
    final rt = topRadius < 0 ? radius : topRadius;
    final top = bottom + _V(0, height, 0);
    final bottomOval = oval(bottom, radius);
    final topOval = oval(top, rt);
    final pb = bottomOval.center, pt = topOval.center;
    final wb = bottomOval.width / 2, wt = topOval.width / 2;
    final base = _lit(color, const _V(0, 0.3, 0.95));
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = base.withValues(alpha: base.a * opacity),
    );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx - wt * 0.45, pt.dy),
      Offset(pb.dx - wb * 0.45, bottomOval.bottom),
      pens.bar
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = math.max(1.0, wb * 0.32)
        ..color = labShade(base, 0.25).withValues(alpha: opacity),
    );
    canvas.drawLine(
      Offset(pt.dx + wt * 0.75, pt.dy),
      Offset(pb.dx + wb * 0.75, bottomOval.bottom),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.4)
        ..color = labShade(base, -0.4).withValues(alpha: opacity),
    );
    canvas.restore();
    pens.bar.strokeCap = StrokeCap.round;
    final top0 = _lit(cap ?? color, const _V(0, 1, 0));
    canvas.drawOval(
      topOval,
      pens.fill..color = top0.withValues(alpha: top0.a * opacity),
    );
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(base, -0.35).withValues(alpha: opacity),
    );
  }

  /// A SphereGeometry scaled by [rx], [ry], [rz] at [c]: a shaded ellipse of
  /// its outline as the camera sees it.
  void ellipsoid(_V c, double rx, double ry, double rz, Color color) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    final ex = rx * k;
    final ey = math.sqrt(ry * ry * _cosPitch2 + rz * rz * _sinPitch2) * k;
    if (ex < 0.3 || ey < 0.3) return;
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(ex, ey);
    canvas.drawCircle(Offset.zero, 1, cache.sphere(color));
    canvas.restore();
  }

  /// A flat disc of [radius] at [c] on the plane spanned by the unit axes
  /// [u] and [v], filled with [paint] (drawn as a unit circle).
  void disc(_V c, _V u, _V v, double radius, Paint paint) {
    final o = cam.p(c);
    final a = cam.p(c + u * radius) - o;
    final b = cam.p(c + v * radius) - o;
    canvas.save();
    canvas.transform(
      (pens.disc..setValues(
            a.dx,
            a.dy,
            0,
            0,
            b.dx,
            b.dy,
            0,
            0,
            0,
            0,
            1,
            0,
            o.dx,
            o.dy,
            0,
            1,
          ))
          .storage,
    );
    canvas.drawCircle(Offset.zero, 1, paint);
    canvas.restore();
  }

  /// A horizontal disc (stain, oil drop) at [c].
  void flatDisc(_V c, double radius, Paint paint) =>
      disc(c, const _V(1, 0, 0), const _V(0, 0, 1), radius, paint);

  /// Soft shadow on the bench under something at (x, z), wider and fainter
  /// the higher it is lifted.
  void shadow(_V at, double radius, {double lift = 0}) {
    final c = _V(at.x, 0.005, at.z);
    final r = radius * (1 + lift * 0.2);
    canvas.drawOval(
      oval(c, r),
      pens.shadow
        ..color = _Colors.shadow.withValues(
          alpha: _Colors.shadow.a * (1 - lift * 0.3).clamp(0.3, 1.0),
        ),
    );
  }
}

/// Paints the HTML Three.js lab bench of the current scenario: S1 the food
/// tray, petri dish, iodine bottle and dropper, Results Tray and box; S2
/// the food tray, paper, lamp, Results Tray and box.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.labelLeft,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Design x of the canvas's left edge and the tool column's left edge
  /// (scene labels stay between them).
  final double labelLeft;
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  _Kind? get _heldKind => scene.held?.kind;

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    final g = _Gfx(canvas, s.camera(), cache);
    _paintBench(g);
    if (s.boxShown) _paintBox(g);
    if (s.scenario == 0) {
      _paintBottle(g);
    } else {
      _paintLamp(g);
    }
    _paintLooseFoods(g);
    _paintTray(g);
    if (s.scenario == 0) {
      _paintDishArea(g);
    } else {
      _paintPaperArea(g);
    }
    _paintHeld(g);
    if (s.done) _paintCheck(g);
    if (showLabels) _paintLabels(g);
  }

  // ------------------------------------------------------------- bench

  /// `PlaneGeometry(30, 15)` bench, the food tray and the Results Tray.
  void _paintBench(_Gfx g) {
    final sc = scene.scenario;
    final bench = _lit(sc == 0 ? _Colors.bench1 : _Colors.bench2, _up);
    g.quad(
      const _V(-_benchHalfX, 0, -_benchHalfZ),
      const _V(_benchHalfX, 0, -_benchHalfZ),
      const _V(_benchHalfX, 0, _benchHalfZ),
      const _V(-_benchHalfX, 0, _benchHalfZ),
      bench,
    );
    g.box(
      _foodTrayC,
      _foodTraySize,
      sc == 0 ? _Colors.metal : _Colors.wood,
      edge: 0.5,
    );
    g.box(_resultsC, _resultsSize, _Colors.metal, edge: 0.5);
  }

  // --------------------------------------------------------------- box

  /// The 'Contains Starch' / 'Contains Fats' box (open at the top so the
  /// sorted foods show), popping up, flashing green / red after a drop and
  /// outlined while a food is held over it.
  void _paintBox(_Gfx g) {
    final s = scene;
    final k = s.boxScale;
    if (k <= 0.02) return;
    final base = s.scenario == 0 ? _Colors.boxStarch : _Colors.boxFat;
    final flash = s.flash;
    final color = flash == null ? base : Color.lerp(base, flash, 0.75)!;
    final hx = _boxSize.x / 2 * k, hz = _boxSize.z / 2 * k;
    final h = _boxSize.y * k;
    final x0 = _boxAt.x - hx, x1 = _boxAt.x + hx;
    final z0 = _boxAt.z - hz, z1 = _boxAt.z + hz;
    Color face(_V n, double a) {
      final c = _lit(color, n);
      return c.withValues(alpha: a);
    }

    final rim = labShade(color, -0.45).withValues(alpha: 0.8);
    // Floor, back wall and the two side walls (their inner faces).
    g.quad(
      _V(x0, 0.004, z0),
      _V(x1, 0.004, z0),
      _V(x1, 0.004, z1),
      _V(x0, 0.004, z1),
      face(_up, 0.95),
    );
    g.quad(
      _V(x0, 0, z0),
      _V(x1, 0, z0),
      _V(x1, h, z0),
      _V(x0, h, z0),
      face(const _V(0, 0, 1), 0.92),
      edge: rim,
    );
    g.quad(
      _V(x0, 0, z0),
      _V(x0, 0, z1),
      _V(x0, h, z1),
      _V(x0, h, z0),
      face(const _V(1, 0, 0), 0.85),
      edge: rim,
    );
    g.quad(
      _V(x1, 0, z0),
      _V(x1, 0, z1),
      _V(x1, h, z1),
      _V(x1, h, z0),
      face(const _V(-1, 0, 0), 0.85),
      edge: rim,
    );
    // The foods sorted into it.
    for (final t in s.tested) {
      if (t.inBox) _paintTested(g, t);
    }
    // Front wall, see-through.
    g.quad(
      _V(x0, 0, z1),
      _V(x1, 0, z1),
      _V(x1, h, z1),
      _V(x0, h, z1),
      face(const _V(0, 0, 1), 0.38),
      edge: rim,
    );
    final top = _pens.stroke
      ..strokeWidth = s.hoverBox ? 3 : 1.5
      ..color = s.hoverBox ? _Colors.hover : labShade(color, 0.35);
    final path = _pens.path
      ..reset()
      ..moveTo(g.cam.p(_V(x0, h, z0)).dx, g.cam.p(_V(x0, h, z0)).dy)
      ..lineTo(g.cam.p(_V(x1, h, z0)).dx, g.cam.p(_V(x1, h, z0)).dy)
      ..lineTo(g.cam.p(_V(x1, h, z1)).dx, g.cam.p(_V(x1, h, z1)).dy)
      ..lineTo(g.cam.p(_V(x0, h, z1)).dx, g.cam.p(_V(x0, h, z1)).dy)
      ..close();
    g.canvas.drawPath(path, top);
  }

  /// The large checkmark above the box once every food is sorted.
  void _paintCheck(_Gfx g) {
    final k = scene.checkScale;
    if (k <= 0.01) return;
    final c = g.cam.p(_checkAt);
    final r = _checkR * g.cam.scaleAt(_checkAt) * k;
    g.canvas.drawCircle(c, r, _pens.fill..color = _Colors.boxStarch);
    g.canvas.drawCircle(
      c,
      r,
      _pens.stroke
        ..strokeWidth = math.max(1.5, r * 0.08)
        ..color = _Colors.white,
    );
    final path = _pens.path
      ..reset()
      ..moveTo(c.dx - r * 0.45, c.dy + r * 0.02)
      ..lineTo(c.dx - r * 0.12, c.dy + r * 0.35)
      ..lineTo(c.dx + r * 0.48, c.dy - r * 0.3);
    g.canvas.drawPath(
      path,
      _pens.bar
        ..strokeWidth = math.max(2, r * 0.2)
        ..color = _Colors.white,
    );
  }

  // ------------------------------------------------- bottle and dropper

  /// The iodine bottle (the dropper in its neck when it rests there).
  void _paintBottle(_Gfx g) {
    final s = scene;
    g.shadow(_bottleAt + const _V(-0.2, 0, -0.2), _bottleR * 1.1);
    if (s.dropperHome && _heldKind != _Kind.dropper) {
      _paintDropper(g, s.dropper.at(s.time));
    }
    g.cylinder(_bottleAt, _bottleR, _bottleH, _Colors.iodine, opacity: 0.92);
    g.cylinder(
      _bottleAt + const _V(0, _bottleH, 0),
      _neckR,
      _neckH,
      _Colors.iodine,
      opacity: 0.92,
    );
  }

  /// The dropper with its tip at [d]: glass tube, iodine inside, black
  /// rubber bulb (squeezed while the bulb is pressed).
  void _paintDropper(_Gfx g, _V d) {
    final c = g.canvas;
    final tip = g.cam.p(d), top = g.cam.p(d + const _V(0, _tubeH, 0));
    final k = g.cam.scaleAt(d);
    final wb = 0.05 * k, wt = 0.1 * k;
    final tube = _pens.path
      ..reset()
      ..moveTo(top.dx - wt, top.dy)
      ..lineTo(tip.dx - wb, tip.dy)
      ..lineTo(tip.dx + wb, tip.dy)
      ..lineTo(top.dx + wt, top.dy)
      ..close();
    c.drawPath(tube, _pens.fill..color = _Colors.glass.withValues(alpha: 0.4));
    final liq = g.cam.p(d + const _V(0, _liquidH, 0));
    final wl = 0.08 * k * (_liquidH / _tubeH) + 0.04 * k;
    final liquid = _pens.path
      ..reset()
      ..moveTo(liq.dx - wl * 0.8, liq.dy)
      ..lineTo(tip.dx - wb * 0.7, tip.dy)
      ..lineTo(tip.dx + wb * 0.7, tip.dy)
      ..lineTo(liq.dx + wl * 0.8, liq.dy)
      ..close();
    c.drawPath(
      liquid,
      _pens.fill..color = _Colors.iodine.withValues(alpha: 0.9),
    );
    c.drawPath(
      tube,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate600.withValues(alpha: 0.7),
    );
    final b = g.cam.p(d + const _V(0, _bulbY, 0));
    final r = _bulbR * g.cam.scaleAt(d + const _V(0, _bulbY, 0));
    c.save();
    c.translate(b.dx, b.dy + r * (1 - scene.bulbSquash) * 0.5);
    c.scale(r, r * scene.bulbSquash);
    c.drawCircle(Offset.zero, 1, cache.sphere(_Colors.bulb));
    c.restore();
  }

  // ------------------------------------------------------------- lamp

  /// The testing lamp: base, arm and a shade aimed at where the paper is
  /// held up; it glows while the paper is in front of it.
  void _paintLamp(_Gfx g) {
    final s = scene;
    final c = g.canvas;
    final on = s.heldT;
    g.shadow(_lampAt + const _V(-0.2, 0, -0.2), _lampBaseR);
    g.cylinder(_lampAt, _lampBaseR, _lampBaseH, _Colors.lampBase);
    final dir = (_heldAt - _shadeAt).unit;
    final back = _shadeAt - dir * 0.45;
    final mouth = _shadeAt + dir * 0.5;
    c.drawLine(
      g.cam.p(_lampAt + const _V(0.1, _lampBaseH, 0)),
      g.cam.p(back + const _V(0.1, -0.05, 0)),
      _pens.bar
        ..strokeWidth = math.max(2, 0.2 * g.cam.scaleAt(_lampAt))
        ..color = _Colors.lampArm,
    );
    final pb = g.cam.p(back), pm = g.cam.p(mouth);
    final axis = pm - pb;
    final len = axis.distance;
    if (len < 0.5) return;
    final n = Offset(-axis.dy / len, axis.dx / len);
    final rb = 0.18 * g.cam.scaleAt(back), rm = 0.55 * g.cam.scaleAt(mouth);
    final shade = _pens.path
      ..reset()
      ..moveTo(pb.dx + n.dx * rb, pb.dy + n.dy * rb)
      ..lineTo(pm.dx + n.dx * rm, pm.dy + n.dy * rm)
      ..lineTo(pm.dx - n.dx * rm, pm.dy - n.dy * rm)
      ..lineTo(pb.dx - n.dx * rb, pb.dy - n.dy * rb)
      ..close();
    c.drawPath(shade, _pens.fill..color = _lit(_Colors.lampShade, _up));
    c.drawPath(
      shade,
      _pens.stroke
        ..strokeWidth = 1
        ..color = labShade(_Colors.lampShade, -0.4),
    );
    // The shade's opening: dim, or lit while the paper is held up.
    c.save();
    c.translate(pm.dx, pm.dy);
    c.rotate(math.atan2(n.dy, n.dx));
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 2 * rm, height: rm * 0.7),
      _pens.fill
        ..color = Color.lerp(
          labShade(_Colors.lampLight, -0.35),
          _Colors.lampLight,
          on,
        )!,
    );
    c.restore();
    if (on > 0) labGlow(c, pm, rm * 2.6, _Colors.lampLight, intensity: on);
  }

  /// The paper held up in front of the lamp, with the light shining
  /// through it.
  void _paintLampPaper(_Gfx g) {
    final s = scene;
    final t = s.heldT;
    final c = s.paper.at(s.time);
    final k = 1 - t * (1 - _heldScale);
    final tilt = t * _heldTilt;
    // The beam from the shade to the paper.
    if (t > 0) {
      final dir = (_heldAt - _shadeAt).unit;
      final pm = g.cam.p(_shadeAt + dir * 0.5);
      final pc = g.cam.p(c);
      final axis = pc - pm;
      final len = axis.distance;
      if (len > 1) {
        final n = Offset(-axis.dy / len, axis.dx / len);
        final rm = 0.5 * g.cam.scaleAt(_shadeAt);
        final rp = _paperHalfX * k * g.cam.scaleAt(c) * 0.9;
        final beam = _pens.path
          ..reset()
          ..moveTo(pm.dx + n.dx * rm, pm.dy + n.dy * rm)
          ..lineTo(pc.dx + n.dx * rp, pc.dy + n.dy * rp)
          ..lineTo(pc.dx - n.dx * rp, pc.dy - n.dy * rp)
          ..lineTo(pm.dx - n.dx * rm, pm.dy - n.dy * rm)
          ..close();
        g.canvas.drawPath(
          beam,
          _pens.fill..color = _Colors.lampLight.withValues(alpha: 0.22 * t),
        );
      }
    }
    g.shadow(_V(c.x, 0, c.z), _paperHalfX * k, lift: c.y);
    _paintPaper(
      g,
      c,
      k,
      tilt: tilt,
      patch: s.patchAlpha,
      oily: s.patchOily,
      glow: s.patchGlow,
      backlit: t,
    );
  }

  // --------------------------------------------------------------- foods

  /// Foods on the food tray (or gliding back to it), back to front.
  void _paintLooseFoods(_Gfx g) {
    final s = scene;
    for (final f in _menus[s.scenario]) {
      if (s.testedOf(f) != null) continue;
      if (_heldKind == _Kind.food && s.held!.food == f) continue;
      if (f == s.active && s.index < 4) {
        if (s.scenario == 0 && s.workingFood) continue;
        if (s.scenario == 1 && s.phase >= 1) continue;
      }
      _paintFood(g, f, s.foodAt(f), 1);
    }
  }

  /// One food resting with its bottom centre at [at], at size [k]; S1's
  /// tested foods carry their iodine stain.
  void _paintFood(_Gfx g, _Food f, _V at, double k) {
    final c = g.canvas;
    switch (f) {
      case _Food.potato:
        g.cylinder(
          at,
          0.6 * k,
          0.1 * k,
          _Colors.potatoSkin,
          cap: _Colors.potato,
        );
        final ring = g.oval(at + _V(0, 0.1 * k + 0.002, 0), 0.38 * k);
        c.drawOval(
          ring,
          _pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(_Colors.potato, -0.12),
        );
      case _Food.cucumber:
        g.cylinder(
          at,
          0.55 * k,
          0.1 * k,
          _Colors.cucumberOuter,
          cap: _Colors.cucumberOuter,
        );
        final top = at + _V(0, 0.1 * k + 0.002, 0);
        c.drawOval(
          g.oval(top, 0.48 * k),
          _pens.fill..color = _Colors.cucumberInner,
        );
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final p = top + _V(math.cos(a) * 0.2 * k, 0, math.sin(a) * 0.2 * k);
          c.drawOval(
            g.oval(p, 0.05 * k),
            _pens.fill..color = labShade(_Colors.cucumberSeed, -0.15),
          );
        }
      case _Food.rice:
        g.ellipsoid(
          at + _V(0, 0.12 * k, 0),
          0.4 * k,
          0.12 * k,
          0.4 * k,
          _Colors.rice,
        );
        final grain = _pens.bar
          ..strokeWidth = math.max(1, 0.035 * k * g.cam.scaleAt(at))
          ..color = _Colors.riceGrain;
        for (final (dx, dz, a) in const [
          (-0.18, -0.05, 0.4),
          (0.1, -0.12, -0.6),
          (0.16, 0.1, 0.9),
          (-0.05, 0.14, -0.2),
          (-0.02, -0.02, 1.4),
        ]) {
          final p = at + _V(dx * k, 0.2 * k, dz * k);
          final e = _V(math.cos(a), 0, math.sin(a)) * (0.06 * k);
          c.drawLine(g.cam.p(p - e), g.cam.p(p + e), grain);
        }
      case _Food.bread:
        g.box(
          at + _V(0, 0.05 * k, 0),
          _V(0.9 * k, 0.1 * k, 0.9 * k),
          _Colors.breadCrust,
          edge: 0.3,
        );
        final y = at.y + 0.1 * k + 0.002;
        final h = 0.4 * k;
        g.quad(
          _V(at.x - h, y, at.z - h),
          _V(at.x + h, y, at.z - h),
          _V(at.x + h, y, at.z + h),
          _V(at.x - h, y, at.z + h),
          _lit(_Colors.bread, _up),
        );
      case _Food.peanuts:
        for (final (dx, dz) in _peanutBits) {
          g.ellipsoid(
            at + _V(dx * k, 0.1 * k, dz * k),
            0.11 * k,
            0.09 * k,
            0.11 * k,
            _Colors.peanut,
          );
        }
      case _Food.butter:
        g.box(
          at + _V(0, 0.15 * k, 0),
          _V(0.5 * k, 0.3 * k, 0.5 * k),
          _Colors.butter,
          edge: 0.25,
        );
      case _Food.oil:
        g.flatDisc(
          at + const _V(0, 0.01, 0),
          0.3 * k,
          _pens.fill..color = _Colors.oil.withValues(alpha: 0.8),
        );
        g.flatDisc(
          at + _V(-0.08 * k, 0.012, -0.06 * k),
          0.1 * k,
          _pens.fill..color = _Colors.white.withValues(alpha: 0.45),
        );
    }
    final stain = scene.stains[f];
    if (scene.scenario == 0 && stain != null) {
      final r = scene.stainRadius(f);
      if (r > 0) {
        g.flatDisc(
          at + _V(0, f.height * k + 0.004, 0),
          r * k,
          _pens.fill
            ..color = (stain ? _Colors.stainStarch : _Colors.stainNone)
                .withValues(alpha: 0.9),
        );
      }
    }
  }

  // ------------------------------------------------------- dish, paper

  /// A petri dish (bottom centre [at], size [k]) with [food] in it.
  void _paintDish(_Gfx g, _V at, double k, {_Food? food, _V? foodAt}) {
    final c = g.canvas;
    final r = _dishR * k, h = _dishH * k;
    final bottom = g.oval(at, r), top = g.oval(at + _V(0, h, 0), r);
    final pb = bottom.center, pt = top.center;
    final wb = bottom.width / 2, wt = top.width / 2;
    final body = _pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(top, 0, -math.pi, false)
      ..close();
    c.drawPath(body, _pens.fill..color = _Colors.glass.withValues(alpha: 0.28));
    c.drawOval(
      g.oval(at + const _V(0, 0.01, 0), r * 0.97),
      _pens.fill..color = _Colors.glass.withValues(alpha: 0.3),
    );
    if (food != null) _paintFood(g, food, foodAt ?? at, k);
    c.drawArc(
      bottom,
      0,
      math.pi,
      false,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate500.withValues(alpha: 0.55),
    );
    c.drawOval(
      top,
      _pens.stroke
        ..strokeWidth = 1.6
        ..color = _Colors.white.withValues(alpha: 0.95),
    );
    c.drawOval(
      top,
      _pens.stroke
        ..strokeWidth = 0.8
        ..color = _Colors.slate500.withValues(alpha: 0.6),
    );
  }

  /// The sheet of paper centred at [c] at size [k]: turned up by [tilt]
  /// about its x axis (held to the lamp), its far half folded by [fold]
  /// over the near half, with its patch ([patch] opacity, oily or wet),
  /// the patch glowing by [glow] and the paper lit from behind by
  /// [backlit]. [food] (drawn by the caller) goes between the paper and
  /// a fold that has come over it.
  void _paintPaper(
    _Gfx g,
    _V c,
    double k, {
    double tilt = 0,
    double fold = 0,
    double patch = 0,
    bool oily = false,
    double glow = 0,
    double backlit = 0,
    VoidCallback? food,
  }) {
    const u = _V(1, 0, 0);
    final v = _V(0, -math.sin(tilt), math.cos(tilt));
    final n = _V(0, math.cos(tilt), math.sin(tilt));
    final hx = _paperHalfX * k, hz = _paperHalfZ * k;
    final white = labShade(_lit(_Colors.paper, n), -0.12 * backlit);
    final edge = _Colors.slate400.withValues(alpha: 0.8);
    if (fold <= 0) {
      g.quad(
        c - u * hx - v * hz,
        c + u * hx - v * hz,
        c + u * hx + v * hz,
        c - u * hx + v * hz,
        white,
        edge: edge,
      );
      if (patch > 0) {
        final color = oily ? _Colors.oilyPatch : _Colors.wetPatch;
        g.disc(
          c + n * 0.006,
          u,
          v,
          _patchR * k,
          cache.patch(color.withValues(alpha: color.a * patch)),
        );
      }
      if (glow > 0) {
        g.disc(
          c + n * 0.008,
          u,
          v,
          _patchR * k * 1.05,
          cache.patch(_Colors.patchGlow.withValues(alpha: glow)),
        );
        labGlow(
          g.canvas,
          g.cam.p(c),
          _patchR * k * g.cam.scaleAt(c) * 1.2,
          _Colors.patchGlow,
          intensity: 0.6 * glow,
        );
      }
      food?.call();
      return;
    }
    // Near half, then the far half turning over about the middle line.
    g.quad(
      c - u * hx,
      c + u * hx,
      c + u * hx + v * hz,
      c - u * hx + v * hz,
      white,
      edge: edge,
    );
    final over = fold > math.pi / 2;
    if (over) food?.call();
    final flapEdge =
        c - v * (hz * math.cos(fold)) + n * (hz * math.sin(fold) + 0.01);
    g.quad(
      c - u * hx,
      c + u * hx,
      flapEdge + u * hx,
      flapEdge - u * hx,
      labShade(white, -0.08 * math.sin(fold)),
      edge: edge,
    );
    if (!over) food?.call();
  }

  /// S1: the dish on the bench with the food being tested, then the
  /// dropper over it and the falling iodine drop.
  void _paintDishArea(_Gfx g) {
    final s = scene;
    if (_heldKind != _Kind.dish) {
      final f = s.active;
      final withFood = s.workingFood && s.index < 4;
      _paintDish(
        g,
        s.dish.at(s.time),
        1,
        food: withFood ? f : null,
        foodAt: withFood ? s.foodAt(f) : null,
      );
    }
    if (!s.dropperHome && _heldKind != _Kind.dropper) {
      _paintDropper(g, s.dropper.at(s.time));
    }
    final drop = s.iodineDrop;
    if (drop != null) {
      g.ellipsoid(
        drop,
        _iodineDropR,
        _iodineDropR * 1.3,
        _iodineDropR,
        _Colors.iodine,
      );
    }
  }

  /// S2: the paper on the bench (folding, with its patch), the food on it
  /// or beside it, and the press coming down.
  void _paintPaperArea(_Gfx g) {
    final s = scene;
    final f = s.active;
    final hasFood = s.index < 4 && s.phase >= 1 && s.testedOf(f) == null;
    final onPaper = hasFood && s.phase == 1;
    if (_heldKind != _Kind.paper && s.anim != _Anim.lamp) {
      _paintPaper(
        g,
        s.paper.at(s.time),
        1,
        fold: s.foldAngle,
        patch: s.patchAlpha,
        oily: s.patchOily,
        food: onPaper ? () => _paintFood(g, f, s.foodAt(f), 1) : null,
      );
    }
    if (hasFood && !onPaper) _paintFood(g, f, s.foodAt(f), 1);
    final press = s.pressY;
    if (press != null) {
      g.box(
        _paperAt + _V(0, press + 0.15, 0.9),
        const _V(2.6, 0.3, 2.0),
        _Colors.slate400,
        opacity: 0.55,
        edge: 0.6,
      );
    }
  }

  // ---------------------------------------------------- tested items

  /// The dishes / papers in the Results Tray (back row first); the sorted
  /// ones are drawn inside the box.
  void _paintTray(_Gfx g) {
    final s = scene;
    for (final t in s.tested) {
      if (t.inBox || s.held?.item == t) continue;
      _paintTested(g, t);
    }
  }

  /// A tested food on its dish (S1) or paper (S2).
  void _paintTested(_Gfx g, _Tested t) {
    final s = scene;
    final at = t.body.at(s.time);
    final k = s.testedScale(t);
    if (s.scenario == 0) {
      _paintDish(g, at, k, food: t.food, foodAt: s.testedFoodAt(t));
      return;
    }
    final food = s.testedFoodAt(t);
    final foodK = 0.9 * k / _trayPaperScale;
    _paintPaper(
      g,
      at + const _V(0, 0.005, 0),
      k,
      patch: t.positive ? 1 : 0,
      oily: true,
      food: () => _paintFood(g, t.food, food, foodK),
    );
  }

  // ------------------------------------------------------- held object

  /// The object in the finger (lifted, over everything) and the paper held
  /// up to the lamp.
  void _paintHeld(_Gfx g) {
    final s = scene;
    if (s.scenario == 1 && s.anim == _Anim.lamp) _paintLampPaper(g);
    final h = s.held;
    if (h == null) return;
    switch (h.kind) {
      case _Kind.food:
        final f = h.food!;
        final at = s.foodAt(f);
        g.shadow(at, f.radius, lift: at.y);
        _paintFood(g, f, at, 1);
      case _Kind.dropper || _Kind.bottle:
        final d = s.dropper.at(s.time);
        g.shadow(d, 0.15, lift: d.y);
        _paintDropper(g, d);
      case _Kind.dish:
        final at = s.dish.at(s.time);
        g.shadow(at, _dishR, lift: at.y);
        final f = s.active;
        _paintDish(g, at, 1, food: f, foodAt: s.foodAt(f));
      case _Kind.paper:
        final at = s.paper.at(s.time);
        g.shadow(at, _paperHalfX, lift: at.y);
        _paintPaper(g, at, 1, patch: s.patchAlpha, oily: s.patchOily);
      case _Kind.tested:
        final t = h.item!;
        final at = t.body.at(s.time);
        g.shadow(at, 1.2 * s.testedScale(t), lift: at.y);
        _paintTested(g, t);
      case _Kind.lamp || _Kind.box:
        break;
    }
  }

  // ------------------------------------------------------------ labels

  void _paintLabels(_Gfx g) {
    final s = scene;
    final sc = s.scenario;
    final cam = g.cam;
    final c = g.canvas;
    final small = _smallLabelScale;
    // The foods still to be tested (and the one being tested).
    for (final f in _menus[sc]) {
      if (s.testedOf(f) != null) continue;
      final name = _t(f.labelKey);
      final at = s.foodAt(f);
      final held = _heldKind == _Kind.food && s.held!.food == f;
      if (f == s.active && s.index < 4 && !held) {
        if (sc == 0 && s.workingFood) {
          if (_heldKind == _Kind.dish) continue;
          _chip(
            c,
            cam.p(s.dish.at(s.time) + const _V(-_dishR - 0.2, 0.1, 0)),
            name,
            align: (1, 0),
            scale: small,
          );
          continue;
        }
        if (sc == 1 && s.phase >= 1) {
          // On the paper until the press reveals the patch; then moved
          // aside (a wet patch dries meanwhile), its name beside it.
          final onPaper = s.patchAt < 0 && !s.foods[f]!.moving(s.time);
          if (s.phase == 1 && onPaper) {
            _chip(
              c,
              cam.p(_paperAt + const _V(-_paperHalfX - 0.2, 0, 0)),
              name,
              align: (1, 0),
              scale: small,
            );
          } else {
            _chip(
              c,
              cam.p(at + _V(f.radius + 0.25, f.height / 2, 0)),
              name,
              align: (-1, 0),
              scale: small,
            );
          }
          continue;
        }
      }
      _chip(c, cam.p(_trayLabelAt(f, at)), name, align: (1, 0), scale: small);
    }
    // The dish (or its result) / the paper (or its result at the lamp).
    if (sc == 0) {
      if (_heldKind != _Kind.dish) {
        final f = s.active;
        final stain = s.workingFood && s.index < 4 ? s.stains[f] : null;
        final at = cam.p(_dishLabelAt(s.dish.at(s.time)));
        if (stain == null) {
          _chip(c, at, _t('lbl_dish'), align: (0, -1));
        } else {
          _resultChip(c, at, sc, stain);
        }
      }
      _chip(c, cam.p(_iodineLabelAt), _t('lbl_iodine'), align: (0, 1));
    } else {
      if (s.anim == _Anim.lamp) {
        if (s.lampResultShown) {
          final t = s.heldT;
          final tilt = t * _heldTilt;
          final k = 1 - t * (1 - _heldScale);
          final v = _V(0, -math.sin(tilt), math.cos(tilt));
          final bottom = s.paper.at(s.time) + v * (_paperHalfZ * k);
          _resultChip(
            c,
            cam.p(bottom + const _V(0, -0.1, 0.1)),
            sc,
            _positive(sc, s.active),
          );
        }
      } else if (_heldKind != _Kind.paper) {
        _chip(c, cam.p(_paperLabelAt), _t('lbl_paper'), align: (0, -1));
      }
      _chip(c, cam.p(_lampLabelAt), _t('lbl_lamp'), align: (0, 1));
    }
    _chip(c, cam.p(_resultsLabelAt), _t('lbl_tray'), align: (0, -1));
    // The tested foods in the Results Tray.
    for (final t in s.tested) {
      if (t.inBox) continue;
      _chip(
        c,
        cam.p(_testedLabelAt(t.slot, t.body.at(s.time))),
        _t(t.food.labelKey),
        align: (0, t.slot < 2 ? 1 : -1),
        scale: small,
      );
    }
    // The box's name on its front.
    if (s.boxShown && s.boxScale > 0.6) {
      _chip(
        c,
        cam.p(_boxLabelAt),
        _t('lbl_box_${sc + 1}'),
        bg: sc == 0 ? _Colors.starchChipBg : _Colors.fatChipBg,
        border: sc == 0 ? _Colors.boxStarch : _Colors.boxFat,
        fg: _Colors.white,
      );
    }
  }

  /// The result label of a test ('Blue-Black (Starch!)', 'No Color
  /// Change', 'Translucent (Fat!)', 'Dries Up (No Fat)'; HTML `labelDict`).
  void _resultChip(Canvas c, Offset at, int sc, bool positive) {
    final text = _t('res_${sc + 1}_${positive ? 'pos' : 'neg'}');
    if (sc == 0) {
      _chip(
        c,
        at,
        text,
        align: (0, -1),
        bg: positive ? _Colors.slate900 : _Colors.chipBg,
        border: positive ? _Colors.blue400 : _Colors.iodine,
        fg: positive ? _Colors.white : _Colors.chipText,
      );
      return;
    }
    _chip(
      c,
      at,
      text,
      align: (0, -1),
      bg: positive ? _Colors.amber100 : _Colors.chipBg,
      border: positive ? _Colors.oil : _Colors.sky400,
    );
  }

  /// HTML `createTextSprite` chip at [at]: [align] picks which point of the
  /// chip sits there. The chip is kept between the canvas's left edge and
  /// the tool column. Returns the painted rect.
  Rect _chip(
    Canvas canvas,
    Offset at,
    String text, {
    (double, double) align = (0, 0),
    double scale = 1,
    Color bg = _Colors.chipBg,
    Color border = _Colors.chipBorder,
    Color fg = _Colors.chipText,
  }) {
    final tp = cache.label(text, fg);
    final size = cache.labelSize;
    final padY = size * _chipPadY;
    final w = tp.width + 2 * size * _chipPadX;
    final h = tp.height + 2 * padY;
    final chip = Size(w * scale, h * scale);
    final o = at + _chipOffset(chip, align);
    var left = o.dx;
    final top = o.dy;
    if (left + chip.width > labelRight - 2) {
      left = labelRight - 2 - chip.width;
    }
    if (left < labelLeft + 2) left = labelLeft + 2;
    canvas.save();
    canvas.translate(left, top);
    canvas.scale(scale);
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(size * _chipRadius),
    );
    canvas.drawRRect(rr, _pens.fill..color = bg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = border,
    );
    tp.paint(canvas, Offset((w - tp.width) / 2, padY));
    canvas.restore();
    return Offset(left, top) & chip;
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.labelLeft != labelLeft ||
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
