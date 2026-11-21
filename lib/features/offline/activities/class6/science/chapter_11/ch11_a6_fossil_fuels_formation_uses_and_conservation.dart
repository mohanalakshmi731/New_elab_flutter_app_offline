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

/// Class 6 Science • Chapter 11 • Activity 6
/// Fossil Fuels: Formation, Uses, and Conservation.
///
/// Native Flutter port of
/// `Cl6S-Ch11-A6-Fossil_Fuels__Formation__Uses__and_Conservation.html`
/// (Three.js r128 + Tween.js). The Three.js scenes are redrawn by
/// [_ScenePainter] through a pinhole projection of the HTML camera (45°
/// field of view, (-0.2, 5.2, 24.5) looking at (-0.2, 0.5, 0) in Scenario 1
/// and (0, 8.5, 24.5) looking at (0, 1.2, 0) in Scenario 2), brought 1.3×
/// closer so the scene fills the stage between the canvas cards. The HTML
/// "Activity Controls" dock (sliders, bucket, gauges, time-lapse counter
/// and trip buttons) and its status badge and pollution jars sit in one
/// card at the top of the canvas.
///
/// Scenario 1 (The Million-Year Cooker): a cross-section of the Earth 300
/// million years ago, a swamp forest, a river and an ancient sea with
/// plankton above the rock basement. Dragging the 'Time Forward' slider
/// topples the trees and sinks the plankton into a thick organic layer;
/// the sediment bucket (tapped, or dragged onto the scene) drops a layer of
/// sand and rock onto it; the Pressure and Heat levers pushed to High press
/// the layers down and make the basement glow red; 'Start Time-lapse' spins
/// the counter through 300 million years while the organic layer turns into
/// Coal, Petroleum and Natural Gas. 'Observe Conclusion' opens the summary.
///
/// Scenario 2 (The Fuel & Pollution Challenge): a small town with a house,
/// a market, a petrol station, a school and a bus stop. The family rides
/// the bicycle to the market (Bicycle jar 0%), drives the car to the petrol
/// pump, fills petrol and drives to school in a trail of exhaust smoke (Car
/// jar 30%), then takes the shared bus to school (Bus jar 10%). 'Observe
/// Conclusion' compares the jars; after both scenarios a 'Mastery Achieved!'
/// popup offers to restart the lab.
class Ch11A6FossilFuelsFormationUsesAndConservationPage extends StatefulWidget {
  const Ch11A6FossilFuelsFormationUsesAndConservationPage({super.key});

  @override
  State<Ch11A6FossilFuelsFormationUsesAndConservationPage> createState() =>
      _FossilFuelsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises four Web Audio tones; they map to the closest files:
/// 'click' → click (`science/click.mp3`), 'success' (every completed step,
/// 'Observe Conclusion', 'Mastery Achieved!') → success
/// (`math/success.mp3`), 'rumble' (the sediment bucket, the time-lapse) →
/// rumble (`science/curtain.mp3`, a long low sweep) and 'drive' (the trip
/// buttons, 'Fill Petrol & Drive') → drive (`science/dropdown.mp3`, a
/// rising swish). The shell plays toggle (`science/dropdown.mp3`), correct
/// (`math/success.mp3`), wrong (`science/error.mp3`: the bucket dropped
/// away from the scene), scenario (`science/page_open.mp3`) and curtain
/// (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toast.
  correct('audio/class6/math/success.mp3'),

  /// The bucket let go away from the scene (added hint).
  wrong('audio/class6/science/error.mp3'),

  /// A step completed, the summary and the mastery popup (HTML `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// The sediment pour and the time-lapse (HTML `rumble`).
  rumble('audio/class6/science/curtain.mp3'),

  /// A trip starts, the car is filled (HTML `drive`).
  drive('audio/class6/science/dropdown.mp3');

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

/// Tailwind colours of the HTML UI and the hex colours of its Three.js
/// materials.
abstract final class _Colors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
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
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316); // the lab's accent
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);

  /// `--glass-bg` (rgba 15 23 42 / 0.92, rgba 255 255 255 / 0.92) and
  /// `--glass-border` (rgba 51 65 85 / 0.85, rgba 203 213 225 / 0.85).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xEBFFFFFF);
  static const Color glassBorderDark = Color(0xD9334155);
  static const Color glassBorderLight = Color(0xD9CBD5E1);

  /// Three.js `scene.background` (dark 0x0f172a, light 0xf8fafc).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// Scene label chips: `bg-white/95 dark:bg-slate-900/90`, `border-slate-300
  /// dark:border-slate-700/70`.
  static const Color chipDark = Color(0xE60F172A);
  static const Color chipLight = Color(0xF2FFFFFF);
  static const Color chipBorderDark = Color(0xB3334155);
  static const Color chipBorderLight = slate300;

  // ------------------------------------------------- Scenario 1 materials
  static const Color basement = Color(0xFF3B2F2F);
  static const Color swampGround = Color(0xFF4A3525);
  static const Color trunk = Color(0xFF5C4033);
  static const Color canopy1 = Color(0xFF15803D);
  static const Color canopy2 = Color(0xFF22C55E);
  static const Color canopy3 = Color(0xFF4ADE80);
  static const Color riverBed = Color(0xFF271C14);
  static const Color riverBank = Color(0xFF14532D);
  static const Color riverWater = Color(0xFF06B6D4);
  static const Color seabed = Color(0xFFD97706);
  static const Color seaWater = Color(0xFF0284C7);
  static const Color plankton = Color(0xFF6EE7B7);
  static const Color organic = Color(0xFF45200C);
  static const Color sediment = Color(0xFF94A3B8);
  static const Color coal = Color(0xFF090D16);
  static const Color petroleum = Color(0xFF1E1B4B);
  static const Color gas = Color(0xFF38BDF8);
  static const Color heatGlow = Color(0xFFFF4500);

  // ------------------------------------------------- Scenario 2 materials
  static const Color lawn = Color(0xFF22C55E);
  static const Color sidewalk = Color(0xFF94A3B8);
  static const Color asphalt = Color(0xFF1E293B);
  static const Color leaves = Color(0xFF15803D);
  static const Color houseWall = Color(0xFFFEF3C7);
  static const Color roof = Color(0xFF991B1B);
  static const Color wood = Color(0xFF78350F);
  static const Color glass = Color(0xFFBAE6FD);
  static const Color marketWall = Color(0xFFFED7AA);
  static const Color crate = Color(0xFF92400E);
  static const Color pillar = Color(0xFF64748B);
  static const Color schoolTower = Color(0xFFD97706);
  static const Color busStopRoof = Color(0xFF2563EB);
  static const Color busStopBoard = Color(0xFF1D4ED8);
  static const Color skin = Color(0xFFFFEDD5);
  static const Color headlight = Color(0xFFFEF08A);
  static const Color carBody = Color(0xFF2563EB);
  static const Color carCabin = Color(0xFF1D4ED8);
  static const Color smoke = Color(0xFF090D16);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): orange accent, glass panels, the dark success popup (light
/// in the light theme so the shell's dark text stays readable).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: _Colors.glassDark,
    border: _Colors.glassBorderDark,
    card: Color(0x991E293B), // dark:bg-slate-800/60 step cards
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.orange500,
    onAccent: _Colors.slate950,
    primary: _Colors.orange600,
    onPrimary: _Colors.slate950,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500, // completed steps (bg-emerald-500)
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // shutter bg-slate-900
    curtainGlow: Color(0x66EA580C), // from-orange-600/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFDBA74), // text-orange-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.orange500,
    buttonBorder: _Colors.glassBorderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: Color(0x80F97316), // border-orange-500/50
    readoutIcon: _Colors.orange400,
    labelBg: _Colors.chipDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100, // --bg-primary
    panel: _Colors.glassLight,
    border: _Colors.glassBorderLight,
    card: _Colors.slate100, // bg-slate-100 step cards
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.orange500,
    onAccent: _Colors.slate950,
    primary: _Colors.orange600,
    onPrimary: _Colors.slate950,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66EA580C),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFDBA74),
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.orange600,
    buttonBorder: _Colors.glassBorderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: Color(0x80F97316),
    readoutIcon: _Colors.orange400,
    labelBg: _Colors.chipLight,
    labelText: _Colors.slate900,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font size slider (15 px default, 12–22 px).
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// shell-generic texts (Enter Lab, Select Scenario, Mission Objective,
// Current Task, Success!, Step, Action, Continue, the canvas tools and the
// footer) come from the shell's `kLabCommonStrings`. `sN_hud_M` are the
// HTML `hud` lines, `sN_concept_M` / `sN_action_M` / `sN_obs_M` its step
// cards and `sN_summary` its summary (the bold heading and the text; the
// heading ends at the first "! "). 'CLICK' / 'click' became 'TAP' / 'tap'
// ('क्लिक' → 'टैप'). Texts the HTML hard-codes in English are marked
// "HTML literal"; keys marked "Added." are new.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Fossil Fuels: Formation, Uses, and Conservation',
    'app_subtitle': "Class 6 . Nature's Treasures",
    's1_title': '1. The Million-Year Cooker: How Fossil Fuels are Made',
    's1_objective':
        'To visually understand and interactively simulate the process of fossil fuel (coal and petroleum) formation from ancient organic matter under heat and pressure over millions of years.',
    's1_hud_1':
        "Step 1: DRAG the 'Time Forward' slider to the right to see plants and sea plankton sink to the bottom.",
    's1_hud_2':
        'Step 2: TAP or DRAG the Sediment Bucket to pour sand and silt over the dead organic matter layer.',
    's1_hud_3':
        "Step 3: DRAG the levers on both 'Pressure' and 'Heat' gauges all the way to 'High'.",
    's1_hud_4':
        "Step 4: TAP 'Start Time-lapse' to spin the counter through 300 million years of transformation.",
    's1_hud_5':
        "Step 5: Observe the final non-renewable deposits (Coal, Petroleum, Natural Gas) and tap 'Observe Conclusion'.",
    's1_concept_1': 'Initial Scene & Sinking Organisms',
    's1_action_1': "DRAG the 'Time Forward' slider to the right.",
    's1_obs_1':
        'Plants in the prehistoric swamp and plankton in the sea die and sink to the bottom, forming a thick organic layer.',
    's1_concept_2': 'Sediment Burial',
    's1_action_2': 'POUR sediment from the bucket over the layer.',
    's1_obs_2':
        'A new heavy layer of sand, silt, and rock buries the dead organic matter completely.',
    's1_concept_3': 'Heat & Pressure',
    's1_action_3': 'DRAG both Pressure and Heat levers to High.',
    's1_obs_3':
        'Sediment layers compress downwards. Immense heat and pressure build deep underground with a glowing red heat haze!',
    's1_concept_4': 'Transformation Time-lapse',
    's1_action_4': "TAP the 'Start Time-lapse' button.",
    's1_obs_4':
        'Over 300 million years, buried plant matter carbonizes into solid Coal, and sea creatures turn into liquid Petroleum and Natural Gas pockets.',
    's1_concept_5': 'Final Non-Renewable Deposits',
    's1_action_5':
        "Observe the geological layers and TAP 'Observe Conclusion'.",
    's1_obs_5':
        'It takes millions of years of heat and pressure to turn dead plants and animals into fossil fuels. They are non-renewable resources!',
    's1_summary':
        'Fossil Fuel Formation Verified! '
        'Over 300 million years, dead plant and marine matter was buried under thick rock and sediment. Subjected to extreme subterranean heat and pressure without oxygen, it slowly transformed into solid Coal, liquid Petroleum, and Natural Gas. Because this takes millions of years, fossil fuels are non-renewable!',
    's2_title': '2. The Fuel & Pollution Challenge',
    's2_objective':
        'To understand that different vehicles use different fossil fuels and that our transportation choices directly impact air pollution, reinforcing the need for conservation.',
    's2_hud_1':
        "Step 1: TAP 'Take Bicycle to Market' to ride the bicycle to the nearby market without pollution.",
    's2_hud_2':
        "Step 2: TAP 'Take Car to Petrol Pump' to pull the family car into the petrol station.",
    's2_hud_3':
        "Step 3: TAP 'Fill Petrol & Drive to School' to fuel up and see exhaust smoke fill the Pollution Meter to 30%.",
    's2_hud_4':
        "Step 4: TAP 'Take Shared Bus to School' to see shared public transport create only 10% pollution.",
    's2_hud_5':
        "Step 5: Compare the 3 pollution jars (Bicycle 0%, Bus 10%, Car 30%) and tap 'Observe Conclusion'.",
    's2_concept_1': 'Bicycle to Market',
    's2_action_1': "TAP 'Take Bicycle to Market' button.",
    's2_obs_1':
        'The family rides the bicycle to the market. The Pollution Meter jar stays crystal clear at 0%!',
    's2_concept_2': 'Petrol Pump Icon & Car Choice',
    's2_action_2': "TAP 'Take Car to Petrol Pump' button.",
    's2_obs_2':
        'The family gets into the car and stops at the Petrol Pump Station (marked with a clean flat-design SVG pump icon).',
    's2_concept_3': 'Fueling & Car Pollution',
    's2_action_3': "TAP 'Fill Petrol & Drive to School' button.",
    's2_obs_3':
        'After filling petrol, the car drives to school leaving a thick trail of exhaust smoke. The Pollution Meter jar fills to 30%!',
    's2_concept_4': 'Reset & Bus to School',
    's2_action_4': "TAP 'Take Shared Bus to School' button.",
    's2_obs_4':
        'Taking the shared bus carries many passengers together. The smoke trail is light and fills the Pollution Meter to only 10%!',
    's2_concept_5': 'Final Comparison',
    's2_action_5':
        "Compare the three pollution jars and TAP 'Observe Conclusion'.",
    's2_obs_5':
        'Bicycle creates 0% pollution, Bus creates 10% per person, while individual Car creates 30%! Walking, cycling, and public transport conserve fuel and clean the air.',
    's2_summary':
        'Transportation & Air Quality! '
        'Using fossil fuels in private vehicles releases heavy carbon exhaust smoke (`30% pollution`). Choosing to walk, cycle (`0% pollution`), or use shared public transport (`10% pollution`) saves precious fuel and keeps our city air clean and healthy!',
    // Sidebar step cards (HTML teacher board).
    'concept_exp': 'Observation Step',
    'lbl_result': 'Result',
    // HTML literal: the step cards' jump button.
    'jump_step': 'Act / Jump to Step {n}',
    // Summary and mastery popups.
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You mastered how fossil fuels (Coal, Petroleum, Natural Gas) form under millions of years of heat and pressure, and how choosing bicycle, walking, or shared public transport reduces air pollution!',
    'btn_conclude': 'Observe Conclusion',
    'sc_completed_msg_1':
        'Scenario 1 completed! Please select the next scenario from the sidebar.',
    'sc_completed_msg_2':
        'Scenario 2 completed! Please select Scenario 1 from the sidebar.',
    'sc_completed_msg_all':
        'All scenarios completed! Please check your mastery trophy or select a scenario from the sidebar.',
    // Status badge.
    'time_initial': 'Prehistoric Era: 300 Million Years Ago',
    'time_burial': 'Epoch: Buried Under Sediment Layer',
    'time_heat': 'Deep Underground: Intense Heat & Pressure',
    'time_done': 'Present Day: Non-Renewable Deposits Formed',
    // HTML literal: the Scenario 2 status badge.
    'time_s2': 'Transportation Challenge: Market & School',
    // Activity controls dock.
    'step1_ctrl': 'Activity Controls',
    'time_forward_lbl': 'Time Forward (Sinking Organisms)',
    'pour_sediment': 'Pour Sediment Bucket',
    'click_or_drag': 'Tap to cover organic layer with sand & rock',
    'pressure': 'Pressure',
    'heat': 'Heat',
    // HTML literal: the gauges before they are moved.
    'val_low': 'Low',
    'years_passed': 'Millions of Years:',
    'start_timelapse': 'Start Time-lapse',
    's1_formed_msg': 'Fossil Fuel Layers Formed (Non-Renewable)!',
    'go_bike_market': 'Take Bicycle to Market',
    'bike_desc': 'Zero Fuel / 0% Pollution',
    'go_car_pump': 'Take Car to Petrol Pump',
    'car_pump_desc': 'Prepare to fuel vehicle with petrol',
    'fill_and_drive': 'Fill Petrol & Drive to School',
    'smoke_warning': 'Generates 30% Air Pollution!',
    'take_bus_school': 'Take Shared Bus to School',
    'bus_desc': 'Shared Fuel / Only 10% Pollution',
    's2_compared_msg':
        'Comparison complete! See jars above: Bicycle (0%), Bus (10%), Car (30%).',
    // Pollution jars.
    'pollution_jars': 'Pollution Jars',
    'lbl_bike': 'Bicycle',
    'lbl_bus': 'Bus',
    'lbl_car': 'Car',
    // HTML literal: the current pollution badge after the car trip.
    'pollution_high': '30% (High Alert!)',
    // Scene labels.
    'lbl_swamp': 'Swamp Forest & Sea',
    'lbl_organic': 'Organic Matter Layer',
    'lbl_sediment': 'Sediment & Rock Layer',
    'lbl_coal': 'Coal Deposit',
    'lbl_petro': 'Petroleum Pool',
    'lbl_gas': 'Natural Gas Pocket',
    'lbl_house': 'House',
    'lbl_market': 'Market',
    'lbl_school': 'School',
    'lbl_pump': 'Petrol Station',
    'lbl_bus_stop': 'Bus Stop',
    // Added.
    'drop_hint': 'Drop the bucket over the organic layer to pour the sediment.',
    'scene_s1':
        'Cross-section of the Earth 300 million years ago: a swamp forest on the left, a river in the middle and an ancient sea with plankton on the right, above the rock basement',
    'scene_s2':
        'A small town with a house, a market, a petrol station, a school and a bus stop joined by two roads; a family stands near the house with a bicycle and a car',
  },
  'hi': {
    'app_title': 'जीवाश्म ईंधन: निर्माण, उपयोग और संरक्षण',
    'app_subtitle': 'कक्षा 6 . प्रकृति का खजाना',
    's1_title': '1. लाखों वर्षों की रसोई: जीवाश्म ईंधन कैसे बनते हैं',
    's1_objective':
        'यह समझना और सिमुलेट करना कि लाखों वर्षों में अत्यधिक ताप और दाब से मृत जीवों और वनस्पतियों से कोयला, पेट्रोलियम और प्राकृतिक गैस कैसे बनते हैं।',
    's1_hud_1':
        "चरण 1: पेड़ और समुद्री जीवों को डूबते देखने के लिए 'समय आगे बढ़ाएं' स्लाइडर को दाईं ओर खींचें।",
    's1_hud_2':
        'चरण 2: मृत जैविक परत को मिट्टी और रेत से ढकने के लिए रेत की बाल्टी पर टैप करें।',
    's1_hud_3':
        "चरण 3: 'दाब' और 'ताप' दोनों लीवरों को खींचकर 'High' (उच्च) पर करें।",
    's1_hud_4':
        "चरण 4: 30 करोड़ वर्षों का परिवर्तन देखने के लिए 'टाइम-लैप्स शुरू करें' पर टैप करें।",
    's1_hud_5':
        "चरण 5: तैयार कोयला, पेट्रोलियम और गैस की परतों को देखें और 'निष्कर्ष देखें' पर टैप करें।",
    's1_concept_1': 'प्रारंभिक दृश्य व जीवों का डूबना',
    's1_action_1': "'समय आगे बढ़ाएं' स्लाइडर को दाईं ओर खींचें।",
    's1_obs_1':
        'दलदली वन के पेड़ और समुद्र के छोटे जीव मरकर तलछट में जमा हो जाते हैं और जैविक परत बनाते हैं।',
    's1_concept_2': 'मिट्टी और रेत का जमाव',
    's1_action_2': 'रेत व मिट्टी की बाल्टी डालें।',
    's1_obs_2':
        'ऊपर से मिट्टी, रेत और चट्टानों की एक भारी परत मृत जैविक पदार्थ को पूरी तरह ढक लेती है।',
    's1_concept_3': 'ताप और दाब का प्रभाव',
    's1_action_3': "दाब और ताप के लीवरों को 'High' तक खींचें।",
    's1_obs_3':
        'परतें नीचे दबती हैं। गहराई में भारी दाब और लाल चमक के साथ अत्यधिक ताप उत्पन्न होता है!',
    's1_concept_4': 'टाइम-लैप्स परिवर्तन',
    's1_action_4': "'टाइम-लैप्स शुरू करें' बटन पर टैप करें।",
    's1_obs_4':
        '30 करोड़ वर्षों में दबी वनस्पति कठोर काले कोयले में और समुद्री जीव पेट्रोलियम व प्राकृतिक गैस में बदल जाते हैं!',
    's1_concept_5': 'अंतिम अनवीकरणीय भंडार',
    's1_action_5': "तैयार भंडारों को देखें और 'निष्कर्ष देखें' पर टैप करें।",
    's1_obs_5':
        'मृत जीवों से जीवाश्म ईंधन बनने में लाखों वर्ष लगते हैं। ये अनवीकरणीय प्राकृतिक संसाधन हैं!',
    's1_summary':
        'जीवाश्म ईंधन निर्माण सत्यापित! '
        '30 करोड़ वर्षों में मृत पेड़ और समुद्री जीव मिट्टी व चट्टानों की गहरी परतों के नीचे दब गए। ऑक्सीजन की अनुपस्थिति और भारी ताप व दाब से ये कोयले, पेट्रोलियम और प्राकृतिक गैस में बदल गए। यह प्रक्रिया लाखों वर्षों में होती है, इसलिए ये अनवीकरणीय हैं!',
    's2_title': '2. ईंधन और प्रदूषण की चुनौती',
    's2_objective':
        'यह समझना कि विभिन्न वाहन जीवाश्म ईंधन का उपयोग करते हैं और हमारे यातायात के विकल्प सीधे वायु प्रदूषण को प्रभावित करते हैं, जिससे संरक्षण की आवश्यकता स्पष्ट होती है।',
    's2_hud_1':
        "चरण 1: बिना प्रदूषण के बाज़ार जाने के लिए 'बाज़ार तक साइकिल से जाएं' पर टैप करें।",
    's2_hud_2':
        "चरण 2: परिवार को कार से पेट्रोल पंप ले जाने के लिए 'कार से पेट्रोल पंप जाएं' पर टैप करें।",
    's2_hud_3':
        'चरण 3: पेट्रोल भरकर स्कूल चलने के लिए टैप करें और 30% प्रदूषण जार भरते हुए देखें।',
    's2_hud_4':
        'चरण 4: शेयरिंग बस से स्कूल जाने के लिए टैप करें जिससे केवल 10% प्रदूषण होता है।',
    's2_hud_5':
        "चरण 5: तीनों प्रदूषण जारों (साइकिल 0%, बस 10%, कार 30%) की तुलना करें और 'निष्कर्ष देखें' पर टैप करें।",
    's2_concept_1': 'बाज़ार तक साइकिल',
    's2_action_1': "'बाज़ार तक साइकिल से जाएं' बटन दबाएं।",
    's2_obs_1':
        'परिवार साइकिल से बाज़ार जाता है। प्रदूषण मीटर जार 0% पर बिल्कुल साफ रहता है!',
    's2_concept_2': 'पेट्रोल पंप और कार का चुनाव',
    's2_action_2': "'कार से पेट्रोल पंप जाएं' बटन दबाएं।",
    's2_obs_2':
        'परिवार कार में बैठकर पेट्रोल पंप स्टेशन पहुंचता है (जहां साफ SVG पेट्रोल पंप आइकन बना है)।',
    's2_concept_3': 'पेट्रोल भरना और कार प्रदूषण',
    's2_action_3': "'पेट्रोल भरें और स्कूल चलाएं' पर टैप करें।",
    's2_obs_3':
        'पेट्रोल भरकर कार स्कूल जाती है और पीछे भारी धुआं छोड़ती है। प्रदूषण मीटर जार 30% तक भर जाता है!',
    's2_concept_4': 'शेयरिंग बस से स्कूल',
    's2_action_4': "'शेयरिंग बस से स्कूल जाएं' पर टैप करें।",
    's2_obs_4':
        'सार्वजनिक बस में कई लोग एक साथ यात्रा करते हैं। धुआं कम होता है और प्रदूषण मीटर केवल 10% भरता है!',
    's2_concept_5': 'अंतिम तुलना',
    's2_action_5': "तीनों जारों की तुलना करें और 'निष्कर्ष देखें' दबाएं।",
    's2_obs_5':
        'साइकिल से 0%, बस से प्रति व्यक्ति 10% और कार से 30% प्रदूषण होता है! पैदल चलना, साइकिल या बस चुनना ईंधन बचाता है और हवा साफ रखता है।',
    's2_summary':
        'यातायात और स्वच्छ हवा! '
        'निजी कारों में जीवाश्म ईंधन जलाने से भारी धुआं और प्रदूषण (`30%`) होता है। कम दूरी के लिए पैदल या साइकिल (`0%`) और स्कूल/दफ्तर के लिए सार्वजनिक बस (`10%`) चुनना ईंधन बचाता है और पर्यावरण की रक्षा करता है!',
    'concept_exp': 'अवलोकन चरण',
    'lbl_result': 'परिणाम',
    // Added: Hindi for the HTML literal.
    'jump_step': 'चरण {n} करें / उस पर जाएं',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने जाना कि लाखों वर्षों में अत्यधिक ताप और दाब से कोयला और पेट्रोलियम कैसे बनते हैं, तथा साइकिल या बस चुनकर प्रदूषण कैसे घटाया जाता है!',
    'btn_conclude': 'निष्कर्ष देखें',
    'sc_completed_msg_1':
        'परिदृश्य 1 पूरा हुआ! कृपया साइडबार से अगला परिदृश्य चुनें।',
    'sc_completed_msg_2':
        'परिदृश्य 2 पूरा हुआ! कृपया साइडबार से परिदृश्य 1 चुनें।',
    'sc_completed_msg_all':
        'सभी परिदृश्य पूरे हुए! कृपया महारत ट्रॉफी देखें या साइडबार से परिदृश्य चुनें।',
    'time_initial': 'प्राचीन काल: 30 करोड़ वर्ष पहले',
    'time_burial': 'काल: मिट्टी और रेत की परत के नीचे दबे',
    'time_heat': 'गहराई में: भारी ताप और अत्यधिक दाब',
    'time_done': 'वर्तमान समय: अनवीकरणीय जीवाश्म ईंधन तैयार',
    // Added: Hindi for the HTML literal.
    'time_s2': 'परिवहन चुनौती: बाज़ार और स्कूल',
    'step1_ctrl': 'गतिविधि नियंत्रण',
    'time_forward_lbl': 'समय आगे बढ़ाएं (जीवों का डूबना)',
    'pour_sediment': 'रेत व मिट्टी की बाल्टी डालें',
    'click_or_drag': 'मृत जीवों को मिट्टी और रेत से ढकें',
    'pressure': 'दाब (Pressure)',
    'heat': 'ताप (Heat)',
    // Added: Hindi for the HTML literal.
    'val_low': 'कम',
    'years_passed': 'लाखों वर्ष (Millions of Years):',
    'start_timelapse': 'टाइम-लैप्स शुरू करें',
    's1_formed_msg': 'जीवाश्म ईंधन की परतें तैयार (अनवीकरणीय)!',
    'go_bike_market': 'बाज़ार तक साइकिल से जाएं',
    'bike_desc': 'शून्य ईंधन / 0% प्रदूषण',
    'go_car_pump': 'कार से पेट्रोल पंप जाएं',
    'car_pump_desc': 'कार में पेट्रोल भरने की तैयारी',
    'fill_and_drive': 'पेट्रोल भरें और स्कूल चलाएं',
    'smoke_warning': '30% वायु प्रदूषण उत्पन्न करता है!',
    'take_bus_school': 'शेयरिंग बस से स्कूल जाएं',
    'bus_desc': 'सांझा ईंधन / केवल 10% प्रदूषण',
    's2_compared_msg':
        'तुलना पूरी! ऊपर जार देखें: साइकिल (0%), बस (10%), कार (30%)।',
    'pollution_jars': 'प्रदूषण मीटर जार',
    'lbl_bike': 'साइकिल',
    'lbl_bus': 'बस',
    'lbl_car': 'कार',
    // Added: Hindi for the HTML literal.
    'pollution_high': '30% (उच्च चेतावनी!)',
    'lbl_swamp': 'दलदली वन और समुद्र (Swamp & Sea)',
    'lbl_organic': 'जैविक परत (Organic Layer)',
    'lbl_sediment': 'रेत व चट्टानों की परत (Sediment Layer)',
    'lbl_coal': 'कोयले का भंडार (Coal)',
    'lbl_petro': 'पेट्रोलियम (Petroleum)',
    'lbl_gas': 'प्राकृतिक गैस (Natural Gas)',
    'lbl_house': 'घर (House)',
    'lbl_market': 'बाज़ार (Market)',
    'lbl_school': 'स्कूल (School)',
    'lbl_pump': 'पेट्रोल पंप (Petrol Station)',
    'lbl_bus_stop': 'बस स्टॉप (Bus Stop)',
    // Added.
    'drop_hint': 'तलछट डालने के लिए बाल्टी को जैविक परत के ऊपर छोड़ें।',
    'scene_s1':
        'पृथ्वी का अनुप्रस्थ काट, 30 करोड़ वर्ष पहले: बाईं ओर दलदली वन, बीच में नदी और दाईं ओर प्लवक वाला प्राचीन समुद्र, नीचे चट्टान की परत',
    'scene_s2':
        'एक छोटा शहर: घर, बाज़ार, पेट्रोल पंप, स्कूल और बस स्टॉप, दो सड़कों से जुड़े; घर के पास साइकिल और कार के साथ एक परिवार',
  },
};

/// Number of scenarios and of steps in each (the HTML `steps` arrays).
const int _scenarioCount = 2;
const int _stepCount = 5;

/// The two scenarios for [lang], built from the string table (HTML
/// `ScenariosData`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('s${n}_title'),
        objective: t('s${n}_objective'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_concept_$i'),
              action: t('s${n}_action_$i'),
              observation: t('s${n}_obs_$i'),
            ),
        ],
      ),
  ];
}

/// The HTML summary `<strong>` heading and the text after its `<br>`: the
/// table keeps them as one string, the heading ending at the first "! ".
(String, String) _summaryParts(String summary) {
  final i = summary.indexOf('! ');
  if (i < 0) return ('', summary);
  return (summary.substring(0, i + 1), summary.substring(i + 2));
}

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Where the camera's look-at point lands on the stage: a little below the
/// middle, as the controls card at the top is taller than the HUD below.
const Offset _lookAt = Offset(500, 292);

/// HTML `PerspectiveCamera(45, …)`, brought [_sceneZoom]× closer.
const double _fovDegrees = 45;
const double _sceneZoom = 1.3;
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360) * _sceneZoom;

/// Nearest depth projected, and the depth below which meshes are skipped.
const double _near = 0.1;
const double _clipDepth = 0.5;

/// HTML `resetCamera()`: the two poses and the 1000 ms Cubic.Out tween.
const _View _s1View = _View(_V(-0.2, 5.2, 24.5), _V(-0.2, 0.5, 0));
const _View _s2View = _View(_V(0, 8.5, 24.5), _V(0, 1.2, 0));
const double _cameraSeconds = 1;

/// Longest frame step fed to the animations (s).
const double _maxFrameStep = 0.1;

/// Scene label chips: HTML `text-xs` (12 px), enlarged on small stages.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Widest the controls card gets (dp, times the UI scale).
const double _dockMaxWidth = 460;

/// The controls card stacks its two gauges / its counter and button when
/// narrower than this (dp, times the UI scale).
const double _dockStackBelow = 330;

/// HTML lights: `AmbientLight(0xffffff, 0.65)` and `DirectionalLight(
/// 0xffffff, 1.1)` at (15, 35, 20), normalised.
const _V _keyLight = _V(0.3487, 0.8137, 0.4650);
const double _ambient = 0.65;
const double _keyPower = 1.1;

/// Seed of the layout the HTML draws with `Math.random()` (tree spacing,
/// plankton, gas bubbles), fixed so the scene is the same every time.
const int _layoutSeed = 6011;

// --------------------------------------------------------------- scenario 1
// HTML buildS1Scene().

/// Earth cross-section basement `BoxGeometry(16, 2.2, 9)`.
const _V _basementAt = _V(0, -1.1, 0);
const _V _basementSize = _V(16, 2.2, 9);

/// Swamp forest ground (left), river channel (centre), seabed (right).
const _V _swampAt = _V(-4.2, 0.25, 0);
const _V _swampSize = _V(7, 0.5, 8.6);
const double _swampTop = 0.5;
const _V _riverBedAt = _V(-0.5, 0.2, 0);
const _V _riverBedSize = _V(2.4, 0.4, 8.6);
const _V _bankLeftAt = _V(-1.7, 0.28, 0);
const _V _bankRightAt = _V(0.7, 0.28, 0);
const _V _bankSize = _V(0.4, 0.55, 8.6);
const _V _riverAt = _V(-0.5, 0.38, 0);
const _V _riverSize = _V(2, 0.45, 8.6);
const double _riverOpacity = 0.8;
const double _riverMetal = 0.1;
const _V _seabedAt = _V(4.2, 0.2, 0);
const _V _seabedSize = _V(6.6, 0.4, 8.6);
const double _seabedTop = 0.4;
const _V _seaAt = _V(4.2, 1.4, 0);
const _V _seaSize = _V(6.6, 2.4, 8.6);
const double _seaOpacity = 0.55;

/// River ripple: z = sin(Date.now() × 0.003) × 0.06.
const double _rippleRate = 3;
const double _rippleAmp = 0.06;

/// Twelve swamp trees on a 3 × 4 grid around x = -4.2: a trunk
/// `CylinderGeometry(0.18, 0.35, 3.2, 8)` and three cones.
const int _treeCount = 12;
const double _treeBaseY = 0.5;
const double _treeColumnGap = 2;
const double _treeRowGap = 2.1;
const double _treeJitter = 0.8;

/// HTML `onTimeSliderInput`: the trees topple (rotation.z up to 1.1 or 1.4,
/// rotation.x 0.4 or -0.3) and sink 1.6; the plankton sink 1.8 (never below
/// 0.4).
const double _treeSink = 1.6;

/// Left wall of the Earth block: nothing of a fallen tree shows beyond it.
const double _treeWall = -8;
const double _treeTip = 1.1;
const double _treeTipExtra = 0.3;
const double _treeLeanFront = 0.4;
const double _treeLeanBack = -0.3;

/// 25 plankton `SphereGeometry(0.16)` in the sea.
const int _planktonCount = 25;
const double _planktonR = 0.16;
const double _planktonSink = 1.8;
const double _planktonFloor = 0.4;

/// Organic layer `BoxGeometry(15.6, 1.2, 8.6)` at y 0.8, scaled in y.
const _V _organicAt = _V(0, 0.8, 0);
const _V _organicSize = _V(15.6, 1.2, 8.6);

/// Sediment `BoxGeometry(15.6, 1.8, 8.6)`: poured from y 7 to 2.3 in
/// 1200 ms (Bounce.Out); the Pressure lever presses it down by 0.5.
const _V _sedimentSize = _V(15.6, 1.8, 8.6);
const double _sedimentStartY = 7;
const double _sedimentRestY = 2.3;
const double _sedimentPress = 0.5;
const double _pourSeconds = 1.2;

/// Pressure flattens the organic layer to 60% (never below 50%).
const double _organicPress = 0.4;
const double _organicMinPressed = 0.5;

/// The formed deposits: coal `BoxGeometry(7.4, 1.1, 8.6)` (metalness 0.4),
/// petroleum `BoxGeometry(7.6, 0.9, 8.6)`, 18 gas bubbles (r 0.28, 80%
/// opacity) rising from 1.35 to 1.65 by 0.015 a frame.
const _V _coalAt = _V(-4.1, 0.75, 0);
const _V _coalSize = _V(7.4, 1.1, 8.6);
const double _coalMetal = 0.4;
const _V _petroAt = _V(4, 0.65, 0);
const _V _petroSize = _V(7.6, 0.9, 8.6);
const int _gasCount = 18;
const double _gasR = 0.28;
const double _gasLow = 1.35;
const double _gasHigh = 1.65;
const double _gasRise = 0.9;
const double _gasOpacity = 0.8;

/// Heat glow `BoxGeometry(16.2, 0.4, 9.2)` round the basement, opacity
/// heat × 0.95, shown above 5% heat.
const _V _glowAt = _V(0, -1.1, 0);
const _V _glowSize = _V(16.2, 0.4, 9.2);
const double _glowMax = 0.95;
const double _glowFrom = 0.05;

/// HTML step rules: the slider moves on at 98% (after 400 ms), the levers
/// at 90% each (after 500 ms).
const double _sliderDone = 0.98;
const double _sliderDelay = 0.4;
const double _gaugeDone = 0.9;
const double _gaugeDelay = 0.5;

/// HTML `startTimeLapse()`: +15 000 000 years every 60 ms up to
/// 300 000 000; the organic layer shrinks (1500 ms) while the coal and the
/// petroleum grow (1800 ms).
const int _yearsStep = 15000000;
const int _yearsTotal = 300000000;
const double _yearsTick = 0.06;
const double _organicShrinkSeconds = 1.5;
const double _depositGrowSeconds = 1.8;
const double _depositStart = 0.1;

/// The sediment is poured when the bucket is let go over the Earth block
/// or the air above it (world box corners).
const _V _pourMin = _V(-8, -2.2, -4.5);
const _V _pourMax = _V(8, 5.5, 4.5);

// --------------------------------------------------------------- scenario 2
// HTML buildS2Scene() and dragToTransport() / fillCarAndDrive().

/// Start positions of the family, the bicycle, the car, the bus and the
/// fuel nozzle.
const _V _familyHome = _V(-6, 0.6, -1.8);
const _V _bikeHome = _V(-6.5, 0.45, 0.6);
const _V _carHome = _V(-5, 0.55, 2.4);
const _V _busHome = _V(-3.5, 0.9, 4.2);
const _V _nozzleHome = _V(3, 1.1, -3.2);

/// The trips (TWEEN Linear.None): the family walks to the vehicle in
/// 600 ms; the bicycle rides to the market (1200 ms), the car to the pump
/// (1300 ms) and on to school (1500 ms), the bus to school (1600 ms); the
/// nozzle reaches the car in 500 ms and fills for 600 ms.
const double _walkSeconds = 0.6;
const _V _familyAtBike = _V(-6.5, 0.6, 0.6);
const _V _familyAtMarket = _V(-1.8, 0.6, -2.2);
const _V _bikeAtMarket = _V(-1.8, 0.45, -2.2);
const double _rideSeconds = 1.2;
const _V _familyAtCar = _V(-5, 0.6, 2.4);
const _V _carAtPump = _V(2.8, 0.55, -2.6);
const double _toPumpSeconds = 1.3;
const _V _nozzleAtCar = _V(2.8, 0.8, -2.6);
const double _nozzleSeconds = 0.5;
const double _fillPause = 0.6;
const _V _carAtSchool = _V(6.5, 0.55, -1.8);
const double _driveSeconds = 1.5;
const _V _familyAtBusStop = _V(-5.8, 0.6, 4.2);
const _V _busAtSchool = _V(6.2, 0.9, 2);
const double _busSeconds = 1.6;

/// 18 exhaust puffs `SphereGeometry(0.35)` (85% opacity) trailing 0.6 +
/// 0.22 × i behind the car, 0.75–1.3 high.
const int _smokeCount = 18;
const double _smokeR = 0.35;
const double _smokeOpacity = 0.85;
const double _smokeBack = 0.6;
const double _smokeGap = 0.22;
const double _smokeLow = 0.75;
const double _smokeRange = 0.55;
const double _smokeSpread = 0.3;

/// Pollution jars: the car fills its jar to 30%, the bus to 10% (CSS
/// `transition: height 1s cubic-bezier(0.4, 0, 0.2, 1)`).
const double _jarCarFill = 0.3;
const double _jarBusFill = 0.1;
const double _jarSeconds = 1;

// ---------------------------------------------------------------- confetti
// canvas-confetti: the summary burst (80 pieces, 70° spread, from 60% of
// the height) and the mastery side cannons (2.5 s, 60° / 120°, 55°
// spread); 200 ticks at 60 a second, velocity × 0.9 and +3 px a tick.

const int _burstCount = 80;
const double _burstSpread = 70 * math.pi / 180;
const double _burstOriginY = 0.6;
const double _cannonSeconds = 2.5;
const double _cannonEvery = 0.05;
const int _cannonPieces = 3;
const double _cannonSpread = 55 * math.pi / 180;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiVelocity = 45;
const List<Color> _confettiColors = [
  Color(0xFF26CCFF),
  Color(0xFFA25AFD),
  Color(0xFFFF5E7E),
  Color(0xFF88FF5A),
  Color(0xFFFCFF42),
  Color(0xFFFFA62D),
  Color(0xFFFF36FF),
];

// ------------------------------------------------------------------ models

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
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  _V withY(double v) => _V(x, v, z);

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

/// A Tween.js easing function on 0…1.
typedef _Ease = double Function(double t);

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// HTML `TWEEN.Easing.Cubic.Out` (the camera).
double _cubicOut(double t) {
  final k = 1 - t;
  return 1 - k * k * k;
}

/// HTML `TWEEN.Easing.Bounce.Out` (the sediment landing).
double _bounceOut(double t) {
  const n = 7.5625, d = 2.75;
  if (t < 1 / d) return n * t * t;
  if (t < 2 / d) {
    final k = t - 1.5 / d;
    return n * k * k + 0.75;
  }
  if (t < 2.5 / d) {
    final k = t - 2.25 / d;
    return n * k * k + 0.9375;
  }
  final k = t - 2.625 / d;
  return n * k * k + 0.984375;
}

/// CSS `cubic-bezier(0.4, 0, 0.2, 1)` (the jars' smoke).
double _cssEase(double t) => Curves.fastOutSlowIn.transform(t);

/// A number tweened on the scene clock (Tween.js on one property).
class _Track {
  _Track(this._to);

  double _to;
  double _from = 0;
  double _start = 0;
  double _seconds = 0;
  _Ease _ease = _linear;

  /// Where the value ends (or rests).
  double get target => _to;

  /// Jumps to [value].
  void set(double value) {
    _to = value;
    _seconds = 0;
  }

  /// Tweens from the value at [now] to [to] in [seconds].
  void animate(double now, double to, double seconds, {_Ease ease = _linear}) {
    _from = at(now);
    _to = to;
    _start = now;
    _seconds = seconds;
    _ease = ease;
  }

  /// The value at [now].
  double at(double now) {
    if (_seconds <= 0) return _to;
    final k = (now - _start) / _seconds;
    if (k >= 1) return _to;
    return _from + (_to - _from) * _ease(math.max(0, k));
  }

  /// Still tweening at [now].
  bool movingAt(double now) => _seconds > 0 && now - _start < _seconds;
}

/// A position tweened on the scene clock (Tween.js on `position`).
class _Mover {
  _Mover(this._to);

  _V _to;
  _V _from = _V.zero;
  double _start = 0;
  double _seconds = 0;

  _V get target => _to;

  void set(_V value) {
    _to = value;
    _seconds = 0;
  }

  void moveTo(double now, _V to, double seconds) {
    _from = at(now);
    _to = to;
    _start = now;
    _seconds = seconds;
  }

  _V at(double now) {
    if (_seconds <= 0) return _to;
    final k = (now - _start) / _seconds;
    if (k >= 1) return _to;
    return _V.lerp(_from, _to, math.max(0, k));
  }
}

/// A camera pose: HTML `camera.position` and `controls.target`.
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;

  _View lerpTo(_View o, double t) =>
      _View(_V.lerp(eye, o.eye, t), _V.lerp(target, o.target, t));
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage.
@immutable
class _Cam {
  factory _Cam(_View view) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(view.eye, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.f, this.r, this.u);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w] (points behind the camera are clamped to the
  /// near plane; callers skip them).
  Offset p(_V w) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      _lookAt.dx + _focal * d.dot(r) / z,
      _lookAt.dy - _focal * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => _focal / math.max(_near, depth(w));

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

/// One swamp tree: where it stands and its index (HTML `i`, which picks
/// how it topples).
@immutable
class _Tree {
  const _Tree(this.x, this.z, this.index);

  final double x;
  final double z;
  final int index;
}

/// One confetti piece: when it leaves (s after the start), from which side
/// (0 the burst, -1 / 1 the left / right cannon), its direction (radians,
/// screen y down), start speed (px a tick), colour and spin.
@immutable
class _Confetto {
  const _Confetto(
    this.delay,
    this.side,
    this.angle,
    this.speed,
    this.color,
    this.spin,
  );

  final double delay;
  final int side;
  final double angle;
  final double speed;
  final Color color;
  final double spin;
}

/// The three trips of Scenario 2 (HTML `dragToTransport(type)`).
enum _Trip { bicycle, car, bus }

/// What the current pollution badge shows (HTML `#s2-curr-pollution`).
enum _Pollution { none, car, bus }

/// Everything the HTML keeps in `State`, the meshes' tweened properties
/// and the scene clock. Pure data: the page state drives it.
class _Scene {
  _Scene() {
    final rnd = math.Random(_layoutSeed);
    double jitter() => (rnd.nextDouble() - 0.5) * _treeJitter;
    trees = [
      for (var i = 0; i < _treeCount; i++)
        _Tree(
          -4.2 + (i % 3 - 1) * _treeColumnGap + jitter(),
          ((i ~/ 3) - 1.5) * _treeRowGap + jitter(),
          i,
        ),
    ];
    plankton = [
      for (var i = 0; i < _planktonCount; i++)
        _V(
          4.2 + (rnd.nextDouble() - 0.5) * 5.5,
          0.6 + rnd.nextDouble() * 1.8,
          (rnd.nextDouble() - 0.5) * 7,
        ),
    ];
    gasHome = [
      for (var i = 0; i < _gasCount; i++)
        _V(
          4 + (rnd.nextDouble() - 0.5) * 6,
          _gasLow + rnd.nextDouble() * 0.3,
          (rnd.nextDouble() - 0.5) * 7,
        ),
    ];
    gasY = [for (final b in gasHome) b.y];
    final burst = [
      for (var i = 0; i < _burstCount; i++)
        _Confetto(
          0,
          0,
          -math.pi / 2 + (0.5 - rnd.nextDouble()) * _burstSpread,
          _confettiVelocity * (0.5 + rnd.nextDouble()),
          _confettiColors[rnd.nextInt(_confettiColors.length)],
          (rnd.nextDouble() - 0.5) * 0.4,
        ),
    ];
    final cannons = <_Confetto>[];
    for (var t = 0.0; t < _cannonSeconds; t += _cannonEvery) {
      for (var side = -1; side <= 1; side += 2) {
        for (var k = 0; k < _cannonPieces; k++) {
          // canvas-confetti angle 60° (left) / 120° (right), measured
          // anticlockwise from +x with y up.
          final aim = side < 0 ? -math.pi / 3 : -2 * math.pi / 3;
          cannons.add(
            _Confetto(
              t,
              side,
              aim + (0.5 - rnd.nextDouble()) * _cannonSpread,
              _confettiVelocity * (0.5 + rnd.nextDouble()),
              _confettiColors[rnd.nextInt(_confettiColors.length)],
              (rnd.nextDouble() - 0.5) * 0.4,
            ),
          );
        }
      }
    }
    burstPieces = burst;
    cannonPieces = cannons;
  }

  // ------------------------------------------------------------- general

  /// 0: The Million-Year Cooker, 1: The Fuel & Pollution Challenge.
  int scenario = 0;

  /// HTML `State.step` (1…5).
  int step = 1;

  /// 'Observe Conclusion' was tapped.
  bool reviewed = false;

  /// Scene clock (s), from the page's ticker.
  double time = 0;

  /// A trip is under way (Scenario 2); its button waits.
  bool busy = false;

  /// The controls card on the stage (design coordinates), which the scene
  /// labels keep out of; null when it is not laid out.
  Rect? labelObstacle;

  /// Timed callbacks on the scene clock (the HTML `setTimeout`s and tween
  /// `onComplete`s).
  final List<(double, VoidCallback)> _cues = [];

  _View _viewFrom = _s1View;
  _View _viewTo = _s1View;
  double _viewStart = -_cameraSeconds;

  // ---------------------------------------------------------- scenario 1

  late final List<_Tree> trees;
  late final List<_V> plankton;
  late final List<_V> gasHome;
  late final List<double> gasY;

  /// HTML `#time-display` (a string table key).
  String badgeKey = 'time_initial';

  /// HTML `State.s1`: slider and levers (0…1), progress guards, flags.
  double timePct = 0;
  bool step1Progressing = false;
  double pressure = 0;
  double heat = 0;
  bool gaugesTouched = false;
  bool step3Progressing = false;
  bool hasSediment = false;
  bool timeLapseDone = false;

  /// When the time-lapse started (scene clock; -1 before).
  double timeLapseAt = -1;

  bool organicVisible = false;
  bool sedimentVisible = false;
  bool coalVisible = false;
  bool petroVisible = false;
  bool gasVisible = false;
  final _Track organicScale = _Track(0.1);
  final _Track sedimentY = _Track(_sedimentStartY);
  final _Track coalScale = _Track(_depositStart);
  final _Track petroScale = _Track(_depositStart);

  // ---------------------------------------------------------- scenario 2

  /// HTML `State.s2`.
  bool bikeDone = false;
  bool atPump = false;
  bool carDone = false;
  bool busDone = false;

  final _Mover family = _Mover(_familyHome);
  final _Mover bike = _Mover(_bikeHome);
  final _Mover car = _Mover(_carHome);
  final _Mover bus = _Mover(_busHome);
  final _Mover nozzle = _Mover(_nozzleHome);
  bool familyVisible = true;

  /// The bus has set off (it also waits at its stop from step 4 on, HTML
  /// `busModel.visible = step >= 4 || busDone`).
  bool busVisible = false;
  bool nozzleVisible = false;
  bool smokeVisible = false;

  /// The puffs follow the driving car (HTML tween `onUpdate`).
  bool smokeFollow = false;
  final List<_V> smoke = List.filled(_smokeCount, _V.zero);

  /// Smoke in the Bicycle, Bus and Car jars (0…1 of the jar).
  final _Track jarBike = _Track(0);
  final _Track jarBus = _Track(0);
  final _Track jarCar = _Track(0);
  _Pollution pollution = _Pollution.none;

  // ------------------------------------------------------------ confetti

  late final List<_Confetto> burstPieces;
  late final List<_Confetto> cannonPieces;

  /// When the confetti started (-1: none) and whether it is the mastery
  /// side cannons.
  double confettiAt = -1;
  bool confettiCannons = false;

  // --------------------------------------------------------------- clock

  /// Runs [run] [delay] seconds from now on the scene clock.
  void cue(double delay, VoidCallback run) => _cues.add((time + delay, run));

  /// Runs the cues that are due, in time order (a cue may add more).
  void runCues() {
    while (true) {
      var best = -1;
      for (var i = 0; i < _cues.length; i++) {
        if (_cues[i].$1 > time + 1e-9) continue;
        if (best < 0 || _cues[i].$1 < _cues[best].$1) best = i;
      }
      if (best < 0) return;
      final (_, run) = _cues.removeAt(best);
      run();
    }
  }

  /// HTML `animate()`: gas bubbles rise and wrap; the exhaust trails the
  /// driving car.
  void advance(double dt) {
    if (scenario == 0 && gasVisible) {
      for (var i = 0; i < gasY.length; i++) {
        var y = gasY[i] + _gasRise * dt;
        if (y > _gasHigh) y = _gasLow;
        gasY[i] = y;
      }
    }
    if (scenario == 1 && smokeFollow) trailSmoke(car.at(time), time);
  }

  /// The exhaust puffs behind a car at [at], jittered each frame like the
  /// HTML's `Math.random()` (a hash of the frame instead).
  void trailSmoke(_V at, double now) {
    final frame = (now * 60).floor();
    for (var i = 0; i < _smokeCount; i++) {
      smoke[i] = _V(
        at.x - _smokeBack - i * _smokeGap,
        _smokeLow + _noise(frame, i * 2) * _smokeRange,
        at.z + (_noise(frame, i * 2 + 1) - 0.5) * _smokeSpread,
      );
    }
  }

  /// A repeatable pseudo-random number in 0…1.
  static double _noise(int a, int b) {
    final v = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  // -------------------------------------------------------------- camera

  /// The camera pose now (HTML `resetCamera()` tween, 1000 ms Cubic.Out).
  _View get view {
    final k = (time - _viewStart) / _cameraSeconds;
    if (k >= 1) return _viewTo;
    return _viewFrom.lerpTo(_viewTo, _cubicOut(math.max(0, k)));
  }

  _Cam camera() => _Cam(view);

  /// Sends the camera to [to], from where it is now.
  void aimCamera(_View to) {
    _viewFrom = view;
    _viewTo = to;
    _viewStart = time;
  }

  // ------------------------------------------------------------- derived

  /// Time-lapse counter (HTML `#odometer-counter`).
  int get years {
    if (timeLapseAt < 0) return timeLapseDone ? _yearsTotal : 0;
    final ticks = ((time - timeLapseAt) / _yearsTick + 1e-6).floor();
    return math.min(_yearsTotal, ticks * _yearsStep);
  }

  /// Top of the organic layer now (it is scaled about its centre).
  double organicTop(double now) =>
      _organicAt.y + _organicSize.y / 2 * organicScale.at(now);

  /// Top of the coal deposit now (0 when not formed).
  double coalTop(double now) => coalVisible
      ? _coalAt.y + _coalSize.y / 2 * coalScale.at(now)
      : double.negativeInfinity;

  /// Top of the petroleum pool now.
  double petroTop(double now) => petroVisible
      ? _petroAt.y + _petroSize.y / 2 * petroScale.at(now)
      : double.negativeInfinity;

  /// Where the bucket pours: the Earth block and the air above it.
  Rect pourRect() => camera().boxRect(_pourMin, _pourMax);

  // -------------------------------------------------------------- resets

  /// HTML `changeScenario(id)` → `resetScenarioState()`: clears tweens and
  /// timers and puts the scene back; the camera flies to the new pose.
  void load(int index) {
    _cues.clear();
    final changed = index != scenario;
    scenario = index;
    step = 1;
    reviewed = false;
    busy = false;
    confettiAt = -1;
    _resetS1();
    _resetS2();
    if (changed) aimCamera(index == 0 ? _s1View : _s2View);
  }

  void _resetS1() {
    badgeKey = 'time_initial';
    timePct = 0;
    step1Progressing = false;
    pressure = 0;
    heat = 0;
    gaugesTouched = false;
    step3Progressing = false;
    hasSediment = false;
    timeLapseDone = false;
    timeLapseAt = -1;
    organicVisible = false;
    sedimentVisible = false;
    coalVisible = false;
    petroVisible = false;
    gasVisible = false;
    organicScale.set(0.1);
    sedimentY.set(_sedimentStartY);
    coalScale.set(_depositStart);
    petroScale.set(_depositStart);
    for (var i = 0; i < gasY.length; i++) {
      gasY[i] = gasHome[i].y;
    }
  }

  void _resetS2() {
    bikeDone = false;
    atPump = false;
    carDone = false;
    busDone = false;
    family.set(_familyHome);
    bike.set(_bikeHome);
    car.set(_carHome);
    bus.set(_busHome);
    nozzle.set(_nozzleHome);
    familyVisible = true;
    busVisible = false;
    nozzleVisible = false;
    smokeVisible = false;
    smokeFollow = false;
    jarBike.set(0);
    jarBus.set(0);
    jarCar.set(0);
    pollution = _Pollution.none;
  }

  /// HTML `jumpToStep(n)` from a step card. The HTML only changed the step
  /// number; here the scene is also put where the earlier steps leave it,
  /// so the jumped-to step can be done (and a jump back can be redone).
  void jumpTo(int target) {
    _cues.clear();
    busy = false;
    reviewed = false;
    confettiAt = -1;
    if (scenario == 0) {
      _resetS1();
      if (target >= 2) {
        timePct = 1;
        step1Progressing = true;
        organicVisible = true;
        organicScale.set(1);
      }
      if (target >= 3) {
        hasSediment = true;
        sedimentVisible = true;
        sedimentY.set(_sedimentRestY);
        badgeKey = 'time_burial';
      }
      if (target >= 4) {
        pressure = 1;
        heat = 1;
        gaugesTouched = true;
        step3Progressing = true;
        sedimentY.set(_sedimentRestY - _sedimentPress);
        organicScale.set(1 - _organicPress);
        badgeKey = 'time_heat';
      }
      if (target >= 5) {
        timeLapseDone = true;
        organicScale.set(_depositStart);
        coalVisible = true;
        petroVisible = true;
        gasVisible = true;
        coalScale.set(1);
        petroScale.set(1);
        badgeKey = 'time_done';
      }
    } else {
      _resetS2();
      if (target >= 2) {
        bikeDone = true;
        bike.set(_bikeAtMarket);
        family.set(_familyAtMarket);
      }
      if (target >= 3) {
        family.set(_familyAtCar);
        familyVisible = false;
        car.set(_carAtPump);
        atPump = true;
        nozzleVisible = true;
      }
      if (target >= 4) {
        nozzleVisible = false;
        nozzle.set(_nozzleAtCar);
        car.set(_carAtSchool);
        smokeVisible = true;
        trailSmoke(_carAtSchool, time);
        carDone = true;
        jarCar.set(_jarCarFill);
        pollution = _Pollution.car;
      }
      if (target >= 5) {
        busVisible = true;
        bus.set(_busAtSchool);
        family.set(_familyAtBusStop);
        familyVisible = false;
        busDone = true;
        jarBus.set(_jarBusFill);
        pollution = _Pollution.bus;
      }
    }
    step = target;
  }
}

class _FossilFuelsLabState
    extends State<Ch11A6FossilFuelsFormationUsesAndConservationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();

  /// Scene clock of the last frame: repaints the scene and the readouts
  /// that move every frame (counter, jars, confetti).
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Where the dragged sediment bucket is drawn (canvas coordinates), or
  /// null when no bucket is being dragged.
  final ValueNotifier<Offset?> _ghost = ValueNotifier(null);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay) and the stage's
  /// design box, to place the dragged bucket and find where it was let go.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch11-a6-canvas');
  final GlobalKey _stageKey = GlobalKey(debugLabel: 'ch11-a6-stage');

  /// The controls card, measured so the scene labels keep out of it.
  final GlobalKey _dockKey = GlobalKey(debugLabel: 'ch11-a6-dock');

  /// Label chip text size in design px for the current stage scale.
  double _labelSize = _labelPx;

  /// The bucket's last global position while it is dragged.
  Offset? _bucketAt;

  /// The scenario summary is open; when it closes after the last scenario
  /// the 'Mastery Achieved!' popup follows (HTML `closeSummary()`).
  bool _summaryOpen = false;
  bool _masteryPending = false;

  String _t(String key) => _lab.tr(_i18n, key);

  List<LabScenarioData> get _scenarios =>
      _data[_lab.lang] ??= _buildScenarios(_lab.lang);

  LabScenarioData get _scenarioData => _scenarios[_scene.scenario];

  /// 1-based current step for the shell: the HTML `State.step`, then
  /// steps.length + 1 once the conclusion was observed.
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
    _lab.addListener(_watchPopup);
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
    _lab.removeListener(_watchPopup);
    _frame.dispose();
    _ghost.dispose();
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
    _measureDock();
    _frame.value = now;
  }

  /// Where the controls card sits on the stage (it can be dragged, the
  /// canvas zoomed): the scene labels are placed clear of it.
  void _measureDock() {
    final box = _dockKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) {
      _scene.labelObstacle = null;
      return;
    }
    final a = labGlobalToLocal(_stageKey, box.localToGlobal(Offset.zero));
    final b = labGlobalToLocal(
      _stageKey,
      box.localToGlobal(box.size.bottomRight(Offset.zero)),
    );
    _scene.labelObstacle = a == null || b == null
        ? null
        : Rect.fromPoints(a, b).inflate(4);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ------------------------------------------------------------ scenarios

  /// HTML `changeScenario(id)`: the scene, the controls and the camera go
  /// back to the scenario's start.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _summaryOpen = false;
    _masteryPending = false;
    _lab.hidePopup(sound: false);
    _bucketAt = null;
    _ghost.value = null;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `progressStep(expected)`: the success tone and the next step
  /// (the controls, HUD and step cards follow).
  void _progressStep(int expected) {
    final s = _scene;
    if (s.step != expected || !mounted) return;
    _Sound.success.play();
    setState(() => s.step = math.min(s.step + 1, _stepCount));
  }

  /// HTML `jumpToStep(n)` ('Act / Jump to Step n' on a step card).
  void _jumpToStep(int step) {
    if (!_lab.isLabActive) return;
    _Sound.click.play();
    _lab.cancelPending();
    _summaryOpen = false;
    _masteryPending = false;
    _lab.hidePopup(sound: false);
    _bucketAt = null;
    _ghost.value = null;
    setState(() => _scene.jumpTo(step));
  }

  // ----------------------------------------------------------- scenario 1

  /// HTML `onTimeSliderInput(val)`: the trees topple and sink, the plankton
  /// sink and the organic layer grows; at 98% the step is done (400 ms).
  void _onTimeSlider(double value) {
    final s = _scene;
    if (s.scenario != 0) return;
    final pct = value.roundToDouble() / 100;
    setState(() {
      s
        ..timePct = pct
        ..organicVisible = true;
      s.organicScale.set(math.max(0.1, pct));
    });
    if (pct >= _sliderDone && s.step == 1 && !s.step1Progressing) {
      s
        ..step1Progressing = true
        ..cue(_sliderDelay, () => _progressStep(1));
    }
  }

  /// The bucket can be poured (step 2, not yet poured).
  bool get _canPour {
    final s = _scene;
    return _lab.isLabActive && s.scenario == 0 && s.step == 2 && !s.hasSediment;
  }

  /// HTML `triggerSedimentPour()`: the sediment layer drops onto the
  /// organic layer (1200 ms, Bounce.Out) with a rumble; then step 3.
  void _pourSediment() {
    final s = _scene;
    if (s.scenario != 0 || s.hasSediment) return;
    _Sound.rumble.play();
    setState(() {
      s
        ..hasSediment = true
        ..badgeKey = 'time_burial'
        ..sedimentVisible = true;
      s.sedimentY
        ..set(_sedimentStartY)
        ..animate(s.time, _sedimentRestY, _pourSeconds, ease: _bounceOut);
    });
    s.cue(_pourSeconds, () => _progressStep(2));
  }

  /// HTML `onGaugeInput()`: Pressure presses the sediment and the organic
  /// layer down, Heat lights the glow round the basement; both at 90% or
  /// more finish the step (500 ms).
  void _onGauges({double? pressure, double? heat}) {
    final s = _scene;
    if (s.scenario != 0) return;
    setState(() {
      if (pressure != null) s.pressure = pressure.roundToDouble() / 100;
      if (heat != null) s.heat = heat.roundToDouble() / 100;
      s.gaugesTouched = true;
      s.sedimentY.set(_sedimentRestY - s.pressure * _sedimentPress);
      s.organicScale.set(
        math.max(_organicMinPressed, 1 - s.pressure * _organicPress),
      );
    });
    if (s.pressure >= _gaugeDone &&
        s.heat >= _gaugeDone &&
        s.step == 3 &&
        !s.step3Progressing) {
      setState(() {
        s
          ..step3Progressing = true
          ..badgeKey = 'time_heat';
      });
      s.cue(_gaugeDelay, () => _progressStep(3));
    }
  }

  /// HTML `startTimeLapse()`: the counter spins to 300 000 000 (60 ms a
  /// tick); the organic layer shrinks while the coal and the petroleum
  /// grow and the gas bubbles appear; at 300 million years, step 5.
  void _startTimeLapse() {
    final s = _scene;
    if (s.scenario != 0 || s.timeLapseDone) return;
    _Sound.rumble.play();
    final now = s.time;
    setState(() {
      s
        ..timeLapseDone = true
        ..timeLapseAt = now
        ..coalVisible = true
        ..petroVisible = true
        ..gasVisible = true
        ..badgeKey = 'time_done';
      s.organicScale.animate(now, _depositStart, _organicShrinkSeconds);
      s.coalScale
        ..set(_depositStart)
        ..animate(now, 1, _depositGrowSeconds);
      s.petroScale
        ..set(_depositStart)
        ..animate(now, 1, _depositGrowSeconds);
    });
    s.cue(_yearsTotal ~/ _yearsStep * _yearsTick, () => _progressStep(4));
  }

  // ------------------------------------------------- the bucket, dragged

  /// The bucket picked up from the controls card (HTML "Click or Drag over
  /// organic layer").
  void _bucketDragStart(DragStartDetails d) {
    if (!_canPour) return;
    _bucketAt = d.globalPosition;
    _ghost.value = _toCanvas(d.globalPosition);
  }

  void _bucketDragUpdate(DragUpdateDetails d) {
    if (_bucketAt == null) return;
    _bucketAt = d.globalPosition;
    _ghost.value = _toCanvas(d.globalPosition);
  }

  /// Let go over the Earth block (or the air above it): the sediment is
  /// poured; elsewhere a hint says where to drop it (added).
  void _bucketDragEnd() {
    final at = _bucketAt;
    _bucketAt = null;
    _ghost.value = null;
    if (at == null || !_canPour) return;
    final local = labGlobalToLocal(_stageKey, at);
    if (local != null && _scene.pourRect().contains(local)) {
      _pourSediment();
    } else {
      _lab.showToast(_t('drop_hint'), isError: true);
    }
  }

  Offset? _toCanvas(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  // ----------------------------------------------------------- scenario 2

  /// HTML `dragToTransport(type)`: the family walks to the bicycle and
  /// rides to the market, gets into the car and drives to the petrol pump,
  /// or walks to the bus stop and rides the shared bus to school. Each trip
  /// runs once (the HTML restarted its tweens on every click).
  void _transport(_Trip trip) {
    final s = _scene;
    if (s.scenario != 1 || s.busy) return;
    final done = switch (trip) {
      _Trip.bicycle => s.bikeDone,
      _Trip.car => s.atPump || s.carDone,
      _Trip.bus => s.busDone,
    };
    if (done) return;
    _Sound.drive.play();
    s.busy = true;
    final now = s.time;
    switch (trip) {
      case _Trip.bicycle:
        s.family.moveTo(now, _familyAtBike, _walkSeconds);
        s.cue(_walkSeconds, () {
          s.bike.moveTo(s.time, _bikeAtMarket, _rideSeconds);
          s.family.moveTo(s.time, _familyAtMarket, _rideSeconds);
          s.cue(_rideSeconds, () {
            s
              ..bikeDone = true
              ..busy = false;
            _progressStep(1);
            _refresh();
          });
        });
      case _Trip.car:
        s.family.moveTo(now, _familyAtCar, _walkSeconds);
        s.cue(_walkSeconds, () {
          s.familyVisible = false;
          s.car.moveTo(s.time, _carAtPump, _toPumpSeconds);
          s.cue(_toPumpSeconds, () {
            s
              ..atPump = true
              ..nozzleVisible = true
              ..busy = false;
            _progressStep(2);
            _refresh();
          });
        });
      case _Trip.bus:
        s
          ..busVisible = true
          ..familyVisible = true;
        s.family.moveTo(now, _familyAtBusStop, _walkSeconds);
        s.cue(_walkSeconds, () {
          s.familyVisible = false;
          s.bus.moveTo(s.time, _busAtSchool, _busSeconds);
          s.cue(_busSeconds, () {
            s
              ..busDone = true
              ..pollution = _Pollution.bus
              ..busy = false;
            s.jarBus.animate(s.time, _jarBusFill, _jarSeconds, ease: _cssEase);
            _progressStep(4);
            _refresh();
          });
        });
    }
    _refresh();
  }

  /// HTML `fillCarAndDrive()`: the nozzle reaches the car's tank, fills for
  /// 600 ms, then the car drives to school in a trail of exhaust smoke and
  /// the Car jar fills to 30%.
  void _fillAndDrive() {
    final s = _scene;
    if (s.scenario != 1 || !s.atPump || s.busy || s.carDone) return;
    _Sound.drive.play();
    s
      ..busy = true
      ..nozzle.moveTo(s.time, _nozzleAtCar, _nozzleSeconds);
    s.cue(_nozzleSeconds + _fillPause, () {
      s
        ..nozzleVisible = false
        ..smokeVisible = true
        ..smokeFollow = true
        ..trailSmoke(s.car.at(s.time), s.time);
      s.car.moveTo(s.time, _carAtSchool, _driveSeconds);
      s.cue(_driveSeconds, () {
        s
          ..smokeFollow = false
          ..trailSmoke(_carAtSchool, s.time)
          ..carDone = true
          ..pollution = _Pollution.car
          ..busy = false;
        s.jarCar.animate(s.time, _jarCarFill, _jarSeconds, ease: _cssEase);
        _progressStep(3);
        _refresh();
      });
    });
    _refresh();
  }

  // ----------------------------------------------------------- conclusion

  /// HTML `triggerConclusion()`: the summary popup (header "Success!", the
  /// scenario title, its summary and what to do next) with confetti.
  void _conclude() {
    final s = _scene;
    if (s.step < _stepCount || s.busy) return;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    final allDone = _lab.completedScenarios.length >= _scenarioCount;
    setState(() {
      s
        ..reviewed = true
        ..confettiAt = s.time
        ..confettiCannons = false;
    });
    _summaryOpen = true;
    _masteryPending = allDone;
    _lab.showPopup(() => _summaryPopup(sc, allDone));
  }

  LabPopupContent _summaryPopup(int sc, bool allDone) {
    final p = _lab.palette;
    final n = sc + 1;
    final (heading, text) = _summaryParts(_t('s${n}_summary'));
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.check_circle,
      extra: Builder(
        builder: (context) => _SummaryCard(
          palette: p,
          scale: context.labScale,
          fontScale: _lab.fontScale.clamp(0.9, 1.4).toDouble(),
          title: _scenarios[sc].title,
          heading: heading,
          text: text,
          next: _t(allDone ? 'sc_completed_msg_all' : 'sc_completed_msg_$n'),
          visual: sc == 0
              ? _DepositsVisual(
                  palette: p,
                  scale: context.labScale,
                  labels: [_t('lbl_coal'), _t('lbl_petro'), _t('lbl_gas')],
                )
              : _PollutionJars(
                  palette: p,
                  scale: context.labScale,
                  jars: _jarData(bike: 0, bus: _jarBusFill, car: _jarCarFill),
                ),
        ),
      ),
      actions: [
        // Added: the HTML only says to pick the next scenario in the
        // sidebar; the button does it.
        if (allDone)
          LabAction(
            label: _lab.t('btn_continue'),
            icon: Icons.emoji_events,
            color: p.primary,
            foreground: p.onPrimary,
            silent: true,
            onTap: () => _lab.hidePopup(),
          )
        else
          LabAction(
            label: _t('next_sc'),
            icon: Icons.arrow_forward,
            color: p.primary,
            foreground: p.onPrimary,
            sound: _Sound.scenario,
            onTap: () => _nextScenario(sc),
          ),
      ],
    );
  }

  /// Opens the other scenario 300 ms after the summary closes.
  void _nextScenario(int from) {
    _summaryOpen = false;
    _lab.hidePopup(sound: false);
    _lab.after(const Duration(milliseconds: 300), () {
      if (mounted && _scene.scenario == from) _loadScenario(1 - from);
    });
  }

  /// HTML `closeSummary()`: once both scenarios are done, the summary
  /// closing (its X or 'Continue') brings 'Mastery Achieved!' 300 ms later.
  void _watchPopup() {
    if (!_summaryOpen || _lab.popup != null) return;
    _summaryOpen = false;
    if (!_masteryPending) return;
    _masteryPending = false;
    _lab.after(const Duration(milliseconds: 300), _showMastery);
  }

  /// HTML `showSuccess()`: the trophy popup with side-cannon confetti and
  /// 'Restart Entire Lab'.
  void _showMastery() {
    if (!mounted) return;
    setState(() {
      _scene
        ..confettiAt = _scene.time
        ..confettiCannons = true;
    });
    _lab.showPopup(() {
      final p = _lab.palette;
      return LabPopupContent(
        title: _lab.t('success'),
        icon: Icons.check_circle,
        extra: Builder(
          builder: (context) => _MasteryCard(
            palette: p,
            scale: context.labScale,
            fontScale: _lab.fontScale.clamp(0.9, 1.4).toDouble(),
            heading: _t('all_complete'),
            text: _t('all_complete_desc'),
          ),
        ),
        actions: [
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.emerald600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
        ],
      );
    });
  }

  /// 'Observe Conclusion' in the sidebar (and the floating mission card
  /// while the sidebar is collapsed) at step 5, besides the controls card.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.step < _stepCount || s.busy) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.orange500,
        foreground: _Colors.slate950,
        highlight: !s.reviewed,
        silent: true,
        onTap: _conclude,
      ),
    ];
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final p = _lab.palette;
        final data = _scenarioData;
        final sc = _scene.scenario;
        return LabShell(
          controller: _lab,
          icon: Icons.local_fire_department,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [for (final d in _scenarios) d.title],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, _stepCount)}'),
          actions: _actions(),
          // HTML `resetApp()` starts again at Scenario 1.
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch11a6-steps-$sc-$_step'),
            steps: data.steps,
            current: _step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            actionLabel: _lab.t('action'),
            resultLabel: _t('lbl_result'),
            jumpLabel: _t('jump_step'),
            onJump: _jumpToStep,
          ),
          overlays: _overlays(context, p, s),
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#activity-controls-panel` (with the status badge and, in
  /// Scenario 2, the pollution jars) at the top of the canvas, the dragged
  /// bucket and the confetti.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    return [
      // Measures the canvas (full size, not movable).
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      Positioned(
        key: const ValueKey('ch11a6-dock'),
        top: inset.top,
        left: inset.left,
        right: inset.right,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _dockMaxWidth * s),
            child: KeyedSubtree(key: _dockKey, child: _dock(p, s)),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: ValueListenableBuilder<Offset?>(
            valueListenable: _ghost,
            builder: (context, at, _) => at == null
                ? const SizedBox.shrink()
                : CustomPaint(
                    painter: _GhostBucketPainter(at: at, size: 52 * s),
                  ),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ConfettiPainter(scene: _scene, repaint: _frame),
            ),
          ),
        ),
      ),
    ];
  }

  /// The controls card: the status line and the current step's control;
  /// in Scenario 2 the pollution jars beside them.
  Widget _dock(LabPalette p, double s) {
    final sc = _scene.scenario;
    final status = _DockStatus(
      palette: p,
      scale: s,
      text: _t(sc == 0 ? _scene.badgeKey : 'time_s2'),
      trailing: sc == 0
          ? null
          : _PollutionBadge(scale: s, text: _currentPollution),
    );
    final control = sc == 0 ? _s1Control(p, s) : _s2Control(p, s);
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        status,
        SizedBox(height: 7 * s),
        control,
      ],
    );
    return LabGlassCard(
      palette: p,
      radius: 16,
      padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 9 * s),
      borderColor: _Colors.orange500.withValues(alpha: 0.6),
      child: sc == 0
          ? column
          : Row(
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, now, _) => _PollutionJars(
                    palette: p,
                    scale: s,
                    title: _t('pollution_jars'),
                    jars: _jarData(
                      bike: _scene.jarBike.at(now),
                      bus: _scene.jarBus.at(now),
                      car: _scene.jarCar.at(now),
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(child: column),
              ],
            ),
    );
  }

  /// HTML `#s2-curr-pollution`.
  String get _currentPollution => switch (_scene.pollution) {
    _Pollution.none => '0%',
    _Pollution.car => _t('pollution_high'),
    _Pollution.bus => '10%',
  };

  /// The three jars (Bicycle, Bus, Car) with smoke [bike], [bus], [car].
  List<_JarData> _jarData({
    required double bike,
    required double bus,
    required double car,
  }) => [
    _JarData(
      label: _t('lbl_bike'),
      icon: Icons.pedal_bike,
      fill: bike,
      tone: _Colors.emerald400,
      border: _Colors.emerald500,
      smoke: const [_Colors.slate900, _Colors.slate600, _Colors.slate400],
    ),
    _JarData(
      label: _t('lbl_bus'),
      icon: Icons.directions_bus,
      fill: bus,
      tone: _Colors.amber400,
      border: _Colors.amber500,
      smoke: const [_Colors.slate800, _Colors.slate600, Color(0x99F59E0B)],
    ),
    _JarData(
      label: _t('lbl_car'),
      icon: Icons.directions_car,
      fill: car,
      tone: _Colors.red400,
      border: _Colors.red500,
      smoke: const [_Colors.slate950, _Colors.slate800, Color(0x99EF4444)],
    ),
  ];

  /// HTML `#ctrl-s1-step1` … `#ctrl-s1-step5`.
  Widget _s1Control(LabPalette p, double s) {
    final sc = _scene;
    final orange = p.isDark ? _Colors.orange500 : _Colors.orange600;
    switch (sc.step) {
      case 1:
        return _SliderBlock(
          palette: p,
          scale: s,
          icon: Icons.tune,
          label: _t('time_forward_lbl'),
          valueText: '${(sc.timePct * 100).round()}%',
          color: orange,
          badge: true,
          value: sc.timePct * 100,
          onChanged: _onTimeSlider,
        );
      case 2:
        return _DockButton(
          palette: p,
          scale: s,
          tone: _Colors.amber500,
          ink: p.isDark ? _Colors.amber400 : _Colors.amber600,
          icon: _BucketIcon(size: 26 * s),
          title: _t('pour_sediment'),
          subtitle: _t('click_or_drag'),
          enabled: !sc.hasSediment,
          onTap: _pourSediment,
          onDragStart: _bucketDragStart,
          onDragUpdate: _bucketDragUpdate,
          onDragEnd: _bucketDragEnd,
        );
      case 3:
        final low = _t('val_low');
        String shown(double v) =>
            sc.gaugesTouched ? '${(v * 100).round()}%' : low;
        final pressure = _SliderBlock(
          palette: p,
          scale: s,
          icon: Icons.speed,
          label: _t('pressure'),
          valueText: shown(sc.pressure),
          color: _Colors.blue500,
          boxed: true,
          value: sc.pressure * 100,
          onChanged: (v) => _onGauges(pressure: v),
        );
        final heat = _SliderBlock(
          palette: p,
          scale: s,
          icon: Icons.thermostat,
          label: _t('heat'),
          valueText: shown(sc.heat),
          color: _Colors.red500,
          boxed: true,
          value: sc.heat * 100,
          onChanged: (v) => _onGauges(heat: v),
        );
        return _Pair(scale: s, first: pressure, second: heat);
      case 4:
        return _Pair(
          scale: s,
          stretchSecond: false,
          first: ValueListenableBuilder<double>(
            valueListenable: _frame,
            builder: (context, _, _) => _Odometer(
              palette: p,
              scale: s,
              label: _t('years_passed'),
              years: sc.years,
            ),
          ),
          second: _GradientButton(
            scale: s,
            icon: Icons.play_circle,
            label: _t('start_timelapse'),
            pulse: !sc.timeLapseDone,
            enabled: !sc.timeLapseDone,
            onTap: _startTimeLapse,
          ),
        );
      default:
        return _ConcludeRow(
          palette: p,
          scale: s,
          message: _t('s1_formed_msg'),
          messageColor: p.isDark ? _Colors.emerald400 : _Colors.emerald600,
          button: _GradientButton(
            scale: s,
            icon: Icons.lightbulb,
            label: _t('btn_conclude'),
            bounce: !sc.reviewed,
            onTap: _conclude,
          ),
        );
    }
  }

  /// HTML `#ctrl-s2-step1` … `#ctrl-s2-step5`.
  Widget _s2Control(LabPalette p, double s) {
    final sc = _scene;
    final dark = p.isDark;
    switch (sc.step) {
      case 1:
        return _DockButton(
          palette: p,
          scale: s,
          tone: _Colors.emerald500,
          ink: dark ? _Colors.emerald400 : _Colors.emerald600,
          icon: Icon(Icons.pedal_bike, size: 26 * s, color: _Colors.emerald500),
          title: _t('go_bike_market'),
          subtitle: _t('bike_desc'),
          enabled: !sc.busy,
          onTap: () => _transport(_Trip.bicycle),
        );
      case 2:
        return _DockButton(
          palette: p,
          scale: s,
          tone: _Colors.indigo500,
          ink: dark ? _Colors.indigo400 : _Colors.indigo600,
          icon: _PumpBadge(size: 30 * s),
          title: _t('go_car_pump'),
          subtitle: _t('car_pump_desc'),
          enabled: !sc.busy,
          onTap: () => _transport(_Trip.car),
        );
      case 3:
        return _DockButton(
          palette: p,
          scale: s,
          tone: _Colors.red500,
          ink: dark ? _Colors.red400 : _Colors.red600,
          icon: Icon(
            Icons.local_gas_station,
            size: 26 * s,
            color: _Colors.red500,
          ),
          title: _t('fill_and_drive'),
          subtitle: _t('smoke_warning'),
          enabled: !sc.busy,
          onTap: _fillAndDrive,
        );
      case 4:
        return _DockButton(
          palette: p,
          scale: s,
          tone: _Colors.amber500,
          ink: dark ? _Colors.amber400 : _Colors.amber600,
          icon: Icon(
            Icons.directions_bus,
            size: 26 * s,
            color: _Colors.amber500,
          ),
          title: _t('take_bus_school'),
          subtitle: _t('bus_desc'),
          enabled: !sc.busy,
          onTap: () => _transport(_Trip.bus),
        );
      default:
        return _ConcludeRow(
          palette: p,
          scale: s,
          message: _t('s2_compared_msg'),
          messageColor: dark ? _Colors.orange400 : _Colors.orange600,
          button: _GradientButton(
            scale: s,
            icon: Icons.lightbulb,
            label: _t('btn_conclude'),
            bounce: !sc.reviewed,
            onTap: _conclude,
          ),
        );
    }
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        return LabStage(
          designSize: _design,
          child: KeyedSubtree(
            key: _stageKey,
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

// ================================================================== WIDGETS

/// HTML `#status-badge`: the clock icon and `#time-display` (in Scenario
/// 2 followed by the current pollution badge, [trailing]).
class _DockStatus extends StatelessWidget {
  const _DockStatus({
    required this.palette,
    required this.scale,
    required this.text,
    this.trailing,
  });

  final LabPalette palette;
  final double scale;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Icon(Icons.history, size: 16 * s, color: _Colors.orange500),
        SizedBox(width: 6 * s),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.textStrong,
              fontSize: 11.5 * s,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 6 * s), trailing!],
      ],
    );
  }
}

/// HTML `#s2-curr-pollution`: the pollution of the last trip.
class _PollutionBadge extends StatelessWidget {
  const _PollutionBadge({required this.scale, required this.text});

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.slate700),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _Colors.emerald400,
          fontSize: 10.5 * s,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// An HTML range input with its caption: the 'Time Forward' slider
/// (orange, value in a pill) or a Pressure / Heat gauge ([boxed], in its
/// grey card).
class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.palette,
    required this.scale,
    required this.icon,
    required this.label,
    required this.valueText,
    required this.color,
    required this.value,
    required this.onChanged,
    this.badge = false,
    this.boxed = false,
  });

  final LabPalette palette;
  final double scale;
  final IconData icon;
  final String label;
  final String valueText;
  final Color color;

  /// 0…100.
  final double value;
  final ValueChanged<double> onChanged;
  final bool badge;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    final valueStyle = TextStyle(
      color: color,
      fontSize: 11.5 * s,
      fontWeight: FontWeight.w900,
    );
    final header = Row(
      children: [
        Icon(icon, size: 15 * s, color: color),
        SizedBox(width: 4 * s),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11.5 * s,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 4 * s),
        if (badge)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 1 * s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(valueText, style: valueStyle),
          )
        else
          Text(valueText, style: valueStyle),
      ],
    );
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8 * s,
        activeTrackColor: color,
        inactiveTrackColor: color.withValues(alpha: 0.2),
        thumbColor: color,
        overlayColor: color.withValues(alpha: 0.2),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10 * s),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
        trackShape: const RoundedRectSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Semantics(
        container: true,
        label: label,
        child: SizedBox(
          height: 30 * s,
          child: Slider(
            value: value.clamp(0, 100).toDouble(),
            max: 100,
            onChanged: onChanged,
          ),
        ),
      ),
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, slider],
    );
    if (!boxed) return body;
    return Container(
      padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 2 * s),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0xCC1E293B) : _Colors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.isDark ? _Colors.slate700 : _Colors.slate300,
        ),
      ),
      child: body,
    );
  }
}

/// Two controls side by side, or one above the other in a narrow card
/// (HTML `flex-col sm:flex-row`).
class _Pair extends StatelessWidget {
  const _Pair({
    required this.scale,
    required this.first,
    required this.second,
    this.stretchSecond = true,
  });

  final double scale;
  final Widget first;
  final Widget second;

  /// In a row, [second] shares the width (otherwise it keeps its own).
  final bool stretchSecond;

  @override
  Widget build(BuildContext context) {
    final gap = 8 * scale;
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < _dockStackBelow * scale) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: gap),
              second,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            SizedBox(width: gap),
            if (stretchSecond)
              Expanded(child: second)
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.5),
                child: second,
              ),
          ],
        );
      },
    );
  }
}

/// HTML `.inv-item.pulse-btn` cards (the sediment bucket and the trip
/// buttons): icon, bold title and a short line, in the item's colour, with
/// the pulsing orange ring. The bucket can also be dragged
/// ([onDragStart] …).
class _DockButton extends StatefulWidget {
  const _DockButton({
    required this.palette,
    required this.scale,
    required this.tone,
    required this.ink,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final LabPalette palette;
  final double scale;

  /// Border and fill colour, and the text colour on it.
  final Color tone;
  final Color ink;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _DockButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.enabled && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!widget.enabled && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final s = w.scale;
    final card = Material(
      color: w.tone.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: w.tone, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: w.enabled ? w.onTap : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              w.icon,
              SizedBox(width: 10 * s),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.title,
                      style: TextStyle(
                        color: w.ink,
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 1 * s),
                    Text(
                      w.subtitle,
                      style: TextStyle(
                        color: w.ink.withValues(alpha: 0.85),
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // `pulse-ring`: scale 0.95 → 1 with a 12 px orange ring fading out
    // (2 s), back to 0.95.
    Widget pulsing = AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        var grow = 1.0, spread = 0.0, alpha = 0.0;
        if (w.enabled) {
          if (t < 0.7) {
            final k = t / 0.7;
            grow = 0.95 + 0.05 * k;
            spread = 12 * k;
            alpha = 0.7 * (1 - k);
          } else {
            grow = 1 - 0.05 * (t - 0.7) / 0.3;
          }
        }
        return Transform.scale(
          scale: grow,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _Colors.orange500.withValues(alpha: alpha),
                  spreadRadius: spread * s,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Opacity(opacity: w.enabled ? 1 : 0.6, child: card),
    );
    if (w.onDragStart != null) {
      pulsing = GestureDetector(
        onPanStart: w.onDragStart,
        onPanUpdate: w.onDragUpdate,
        onPanEnd: (_) => w.onDragEnd?.call(),
        onPanCancel: w.onDragEnd,
        child: pulsing,
      );
    }
    return Semantics(
      container: true,
      button: true,
      enabled: w.enabled,
      label: w.title,
      hint: w.subtitle,
      onTap: w.enabled ? w.onTap : null,
      child: ExcludeSemantics(child: pulsing),
    );
  }
}

/// A gentle up-and-down bob (Tailwind `animate-bounce`, 1 s) while [on].
class _Bouncing extends StatefulWidget {
  const _Bouncing({
    required this.on,
    required this.height,
    required this.child,
  });

  final bool on;

  /// How far it rises (dp).
  final double height;
  final Widget child;

  @override
  State<_Bouncing> createState() => _BouncingState();
}

class _BouncingState extends State<_Bouncing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Bouncing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.on && !_bob.isAnimating) {
      _bob.repeat();
    } else if (!widget.on && _bob.isAnimating) {
      _bob
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        // Up at 0% / 100% (ease-in on the way down), down at 50%.
        final t = _bob.value;
        final down = t < 0.5
            ? Curves.easeIn.transform(t * 2)
            : 1 - Curves.easeOut.transform((t - 0.5) * 2);
        final lift = widget.on ? widget.height * (1 - down) : 0.0;
        return Transform.translate(offset: Offset(0, -lift), child: child);
      },
      child: widget.child,
    );
  }
}

/// Tailwind `animate-pulse`: the opacity dips to 50% and back every 2 s.
class _Blinking extends StatefulWidget {
  const _Blinking({required this.child});

  final Widget child;

  @override
  State<_Blinking> createState() => _BlinkingState();
}

class _BlinkingState extends State<_Blinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _blink, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

/// HTML orange gradient buttons: 'Start Time-lapse' (pulsing) and 'Observe
/// Conclusion' (bouncing).
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.pulse = false,
    this.bounce = false,
  });

  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool pulse;
  final bool bounce;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final button = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_Colors.orange500, _Colors.orange600],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _Colors.orange500.withValues(alpha: pulse ? 0.55 : 0.3),
            blurRadius: pulse ? 14 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18 * s, color: _Colors.slate950),
                  SizedBox(width: 6 * s),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.slate950,
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w900,
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
    return _Bouncing(
      on: bounce,
      height: 5 * s,
      child: Opacity(opacity: enabled ? 1 : 0.6, child: button),
    );
  }
}

/// HTML `#ctrl-sN-step5`: the closing message and 'Observe Conclusion'.
class _ConcludeRow extends StatelessWidget {
  const _ConcludeRow({
    required this.palette,
    required this.scale,
    required this.message,
    required this.messageColor,
    required this.button,
  });

  final LabPalette palette;
  final double scale;
  final String message;
  final Color messageColor;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final text = Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: messageColor,
        fontSize: 11.5 * s,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < _dockStackBelow * s) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              SizedBox(height: 6 * s),
              Center(child: button),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: text),
            SizedBox(width: 8 * s),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 0.55),
              child: button,
            ),
          ],
        );
      },
    );
  }
}

/// HTML `#odometer-counter` box: "Millions of Years:" and nine digits.
class _Odometer extends StatelessWidget {
  const _Odometer({
    required this.palette,
    required this.scale,
    required this.label,
    required this.years,
  });

  final LabPalette palette;
  final double scale;
  final String label;
  final int years;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: palette.readoutBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.readoutBorder),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 2,
              style: TextStyle(
                color: _Colors.orange400,
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: labLetterSpacing(label, 0.6),
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$years'.padLeft(9, '0'),
              style: TextStyle(
                fontFamily: 'monospace',
                color: _Colors.emerald400,
                fontSize: 15 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5 * s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One pollution jar: its name, icon, smoke level and colours.
@immutable
class _JarData {
  const _JarData({
    required this.label,
    required this.icon,
    required this.fill,
    required this.tone,
    required this.border,
    required this.smoke,
  });

  final String label;
  final IconData icon;

  /// 0…1 of the jar.
  final double fill;

  /// Text colour (`text-*-400`) and the percent pill's border.
  final Color tone;
  final Color border;

  /// Smoke gradient from the bottom up (`from-` / `via-` / `to-`).
  final List<Color> smoke;
}

/// HTML `#s2-pollution-panel`: 'Pollution Jars' and the Bicycle, Bus and
/// Car jars (also in the summary, without the heading).
class _PollutionJars extends StatelessWidget {
  const _PollutionJars({
    required this.palette,
    required this.scale,
    required this.jars,
    this.title,
  });

  final LabPalette palette;
  final double scale;
  final List<_JarData> jars;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final jarW = 34 * s, jarH = 48 * s, column = 44 * s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null)
          SizedBox(
            width: column * jars.length + 4 * s * (jars.length - 1),
            child: Row(
              children: [
                Icon(Icons.speed, size: 12 * s, color: _Colors.orange400),
                SizedBox(width: 3 * s),
                Expanded(
                  child: Text(
                    title!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.isDark
                          ? _Colors.orange400
                          : _Colors.orange600,
                      fontSize: 8.5 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title!, 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (title != null) SizedBox(height: 5 * s),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < jars.length; i++) ...[
              if (i > 0) SizedBox(width: 4 * s),
              SizedBox(
                width: column,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label:
                          '${jars[i].label} ${(jars[i].fill * 100).round()}%',
                      child: ExcludeSemantics(
                        child: CustomPaint(
                          size: Size(jarW, jarH),
                          painter: _JarPainter(jar: jars[i], scale: s),
                        ),
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(jars[i].icon, size: 10 * s, color: jars[i].tone),
                          SizedBox(width: 2 * s),
                          Text(
                            jars[i].label,
                            style: TextStyle(
                              color: palette.isDark
                                  ? jars[i].tone
                                  : labShade(jars[i].tone, -0.35),
                              fontSize: 9 * s,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// HTML `.pollution-jar`: a glass jar (orange lid, white rim) with its
/// smoke, the 100 / 50 / 0 scale and the percent pill.
class _JarPainter extends CustomPainter {
  _JarPainter({required this.jar, required this.scale});

  final _JarData jar;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(5 * s),
      topRight: Radius.circular(5 * s),
      bottomLeft: Radius.circular(10 * s),
      bottomRight: Radius.circular(10 * s),
    );
    canvas.drawRRect(shape, Paint()..color = const Color(0xA60F172A));
    canvas.save();
    canvas.clipRRect(shape);
    final h = size.height * jar.fill.clamp(0.0, 1.0);
    if (h > 0.5) {
      final smoke = Rect.fromLTRB(0, size.height - h, size.width, size.height);
      canvas.drawRect(
        smoke,
        Paint()
          ..shader = ui.Gradient.linear(
            smoke.bottomCenter,
            smoke.topCenter,
            [for (final c in jar.smoke) c.withValues(alpha: c.a * 0.92)],
            const [0, 0.6, 1],
          ),
      );
    }
    // Inner shadow.
    canvas.drawRRect(
      shape.deflate(1.5 * s),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * s
        ..color = _Colors.black.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * s),
    );
    canvas.restore();
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s
        ..color = _Colors.white.withValues(alpha: 0.45),
    );
    // The orange lid (`border-top: 6px solid #f97316`).
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, 3.5 * s),
        topLeft: Radius.circular(5 * s),
        topRight: Radius.circular(5 * s),
      ),
      Paint()..color = _Colors.orange500,
    );
    // Scale marks.
    for (final (i, mark) in ['100', '50', '0'].indexed) {
      labText(
        canvas,
        mark,
        Offset(size.width - 2 * s, 6 * s + i * (size.height - 12 * s) / 2),
        size: 5 * s,
        color: _Colors.white.withValues(alpha: 0.45),
        weight: FontWeight.w500,
        anchor: Alignment.centerRight,
        fontFamily: 'monospace',
      );
    }
    labText(
      canvas,
      '${(jar.fill * 100).round()}%',
      rect.center,
      size: 8.5 * s,
      color: jar.tone,
      weight: FontWeight.w900,
      background: const Color(0xF2020617),
      border: jar.border.withValues(alpha: 0.7),
      borderWidth: 1,
      padding: EdgeInsets.symmetric(horizontal: 3.5 * s, vertical: 1 * s),
      radius: 5 * s,
    );
  }

  @override
  bool shouldRepaint(covariant _JarPainter old) =>
      old.jar.fill != jar.fill ||
      old.jar.tone != jar.tone ||
      old.jar.label != jar.label ||
      old.scale != scale;
}

/// HTML `ph-bucket` icon, as the sediment bucket: an amber pail with sand
/// heaped on top and its handle.
class _BucketIcon extends StatelessWidget {
  const _BucketIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _BucketPainter());
}

class _BucketPainter extends CustomPainter {
  const _BucketPainter();

  @override
  void paint(Canvas canvas, Size size) => paintBucket(canvas, size.width);

  /// The bucket in a [w] × [w] box at the canvas origin.
  static void paintBucket(Canvas canvas, double w) {
    final body = Path()
      ..moveTo(w * 0.14, w * 0.36)
      ..lineTo(w * 0.86, w * 0.36)
      ..lineTo(w * 0.74, w * 0.92)
      ..quadraticBezierTo(w * 0.5, w * 0.98, w * 0.26, w * 0.92)
      ..close();
    canvas.drawArc(
      Rect.fromLTRB(w * 0.18, w * 0.06, w * 0.82, w * 0.66),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round
        ..color = _Colors.amber600,
    );
    // Sand heaped above the rim.
    canvas.drawOval(
      Rect.fromLTRB(w * 0.16, w * 0.24, w * 0.84, w * 0.46),
      Paint()..color = const Color(0xFFD6B98C),
    );
    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(w * 0.14, 0),
          Offset(w * 0.86, 0),
          const [_Colors.amber600, _Colors.amber400, _Colors.amber600],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawLine(
      Offset(w * 0.12, w * 0.36),
      Offset(w * 0.88, w * 0.36),
      Paint()
        ..strokeWidth = w * 0.08
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFB45309),
    );
    for (final y in [0.55, 0.72]) {
      canvas.drawLine(
        Offset(w * (0.2 + y * 0.08), w * y),
        Offset(w * (0.8 - y * 0.08), w * y),
        Paint()
          ..strokeWidth = w * 0.035
          ..color = const Color(0x55000000),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BucketPainter old) => false;
}

/// The bucket under the finger while it is dragged, tipped to pour.
class _GhostBucketPainter extends CustomPainter {
  _GhostBucketPainter({required this.at, required this.size});

  final Offset at;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    canvas.save();
    canvas.translate(at.dx, at.dy - size * 0.6);
    canvas.rotate(-0.45);
    canvas.drawCircle(
      Offset.zero,
      size * 0.62,
      Paint()
        ..color = _Colors.amber500.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.15),
    );
    canvas.translate(-size / 2, -size / 2);
    _BucketPainter.paintBucket(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GhostBucketPainter old) =>
      old.at != at || old.size != size;
}

/// The HTML's flat petrol-pump SVG (24 × 24 view box): the pump in indigo
/// with its white nozzle slot.
Path _pumpIconPath() => Path()
  ..moveTo(18, 6)
  ..lineTo(16, 6)
  ..lineTo(16, 4)
  ..arcToPoint(
    const Offset(15, 3),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(10, 3)
  ..arcToPoint(
    const Offset(9, 4),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(9, 13)
  ..lineTo(6, 13)
  ..arcToPoint(
    const Offset(5, 14),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(5, 20)
  ..arcToPoint(const Offset(6, 21), radius: const Radius.circular(1))
  ..lineTo(7, 21)
  ..lineTo(7, 17)
  ..arcToPoint(const Offset(8, 16), radius: const Radius.circular(1))
  ..lineTo(13, 16)
  ..arcToPoint(const Offset(14, 17), radius: const Radius.circular(1))
  ..lineTo(14, 21)
  ..lineTo(15, 21)
  ..arcToPoint(
    const Offset(16, 20),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(16, 11.41)
  ..lineTo(12.71, 8.11)
  ..arcToPoint(
    const Offset(12, 7.82),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(10, 7.82)
  ..lineTo(10, 5)
  ..lineTo(14, 5)
  ..lineTo(14, 6)
  ..lineTo(16, 6)
  ..arcToPoint(const Offset(17, 7), radius: const Radius.circular(1))
  ..lineTo(17, 9)
  ..lineTo(17, 7)
  ..arcToPoint(
    const Offset(16, 6),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(18, 6)
  ..close();

/// The second path of the SVG (the white slot).
Path _pumpSlotPath() => Path()
  ..moveTo(13, 17)
  ..lineTo(9, 17)
  ..arcToPoint(
    const Offset(8, 18),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..lineTo(8, 21)
  ..lineTo(14, 21)
  ..lineTo(14, 18)
  ..arcToPoint(
    const Offset(13, 17),
    radius: const Radius.circular(1),
    clockwise: false,
  )
  ..close();

/// Paints the pump icon in a [box] (its 24-unit view box scaled to fit).
void _paintPumpIcon(Canvas canvas, Rect box) {
  canvas.save();
  canvas.translate(box.left, box.top);
  canvas.scale(box.width / 24, box.height / 24);
  canvas.drawPath(_pumpIconPath(), Paint()..color = _Colors.indigo500);
  canvas.drawPath(_pumpSlotPath(), Paint()..color = _Colors.slate50);
  canvas.restore();
}

/// HTML step-2 button icon: the pump SVG in an indigo square.
class _PumpBadge extends StatelessWidget {
  const _PumpBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.12),
    decoration: BoxDecoration(
      color: _Colors.indigo500.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(size * 0.25),
    ),
    child: CustomPaint(painter: const _PumpIconPainter()),
  );
}

class _PumpIconPainter extends CustomPainter {
  const _PumpIconPainter();

  @override
  void paint(Canvas canvas, Size size) =>
      _paintPumpIcon(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(covariant _PumpIconPainter old) => false;
}

/// HTML teacher-board "Observation Step" cards: a badge ('Step n', orange
/// and pulsing for the current step, green when done), the concept, and
/// when opened the action, the result and 'Act / Jump to Step n' (on the
/// other steps). The current step is open; any card opens on a tap.
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.actionLabel,
    required this.resultLabel,
    required this.jumpLabel,
    required this.onJump,
  });

  final List<LabStep> steps;

  /// 1-based current step (steps.length + 1 once concluded).
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String actionLabel;
  final String resultLabel;

  /// 'Act / Jump to Step {n}'.
  final String jumpLabel;
  final ValueChanged<int> onJump;

  @override
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
  /// Cards opened or closed by the learner (HTML `expandedSteps`).
  final Set<int> _toggled = {};

  bool _isOpen(int i) => (i == widget.current) != _toggled.contains(i);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++) _card(context, i),
      ],
    );
  }

  Widget _card(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final current = i == w.current;
    final done = i < w.current;
    final open = _isOpen(i);
    final step = w.steps[i - 1];
    final orange = p.isDark ? _Colors.orange300 : _Colors.orange800;
    final Color fill, border, badgeFill, badgeText;
    if (current) {
      fill = p.isDark ? _Colors.slate800 : _Colors.white;
      border = _Colors.orange500;
      badgeFill = _Colors.orange500;
      badgeText = _Colors.slate950;
    } else if (done) {
      fill = p.isDark ? const Color(0x4D022C22) : const Color(0xFFECFDF5);
      border = _Colors.emerald500.withValues(alpha: 0.4);
      badgeFill = _Colors.emerald500;
      badgeText = _Colors.white;
    } else {
      fill = p.card;
      border = p.cardBorder;
      badgeFill = p.isDark ? _Colors.slate700 : _Colors.slate200;
      badgeText = p.isDark ? _Colors.slate300 : _Colors.slate700;
    }
    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: badgeFill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${w.stepLabel} $i'.toUpperCase(),
        style: TextStyle(
          color: badgeText,
          fontSize: 9 * f,
          fontWeight: FontWeight.w900,
          letterSpacing: labLetterSpacing(w.stepLabel, 0.6),
        ),
      ),
    );
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: current ? 1.5 : 1),
        boxShadow: current
            ? [
                BoxShadow(
                  color: _Colors.orange500.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: LabInk.clear,
            child: InkWell(
              onTap: () {
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
                      if (current) _Blinking(child: badge) else badge,
                      SizedBox(width: 8 * s),
                      Expanded(
                        child: Text(
                          step.concept,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.textStrong,
                            fontSize: 11.5 * f,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (done)
                        Icon(
                          Icons.check_circle,
                          size: 17 * s,
                          color: _Colors.emerald500,
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
          ),
          if (open)
            Container(
              padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 10 * s),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${w.actionLabel} ',
                          style: TextStyle(
                            color: p.isDark
                                ? _Colors.indigo400
                                : _Colors.indigo600,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: step.action),
                      ],
                    ),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: _Colors.orange500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _Colors.orange500.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${w.resultLabel}: ',
                            style: TextStyle(color: p.textStrong),
                          ),
                          TextSpan(text: step.observation),
                        ],
                      ),
                      style: TextStyle(
                        color: orange,
                        fontSize: 11 * f,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (!current) ...[
                    SizedBox(height: 8 * s),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: _Colors.orange500,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => w.onJump(i),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: kMinInteractiveDimension,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12 * s),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 15 * s,
                                    color: _Colors.slate950,
                                  ),
                                  SizedBox(width: 5 * s),
                                  Flexible(
                                    child: Text(
                                      labFormat(w.jumpLabel, {'n': i}),
                                      style: TextStyle(
                                        color: _Colors.slate950,
                                        fontSize: 11 * f,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

/// HTML `#summary-modal` body: the lightbulb, the scenario title, the
/// summary heading and text (its back-ticked figures highlighted), a
/// picture of the result and what to do next.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.title,
    required this.heading,
    required this.text,
    required this.next,
    required this.visual,
  });

  final LabPalette palette;
  final double scale;
  final double fontScale;
  final String title;
  final String heading;
  final String text;
  final String next;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final orange = p.isDark ? _Colors.orange400 : _Colors.orange600;
    final parts = text.split('`');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _IconDisc(
          icon: Icons.lightbulb,
          size: 54 * s,
          color: _Colors.orange400,
          fill: _Colors.orange500,
        ),
        SizedBox(height: 10 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 17 * s,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: orange,
            fontSize: 15 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6 * s),
        Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < parts.length; i++)
                TextSpan(
                  text: parts[i],
                  style: i.isOdd
                      ? TextStyle(color: orange, fontWeight: FontWeight.w900)
                      : null,
                ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13 * s * fontScale,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        SizedBox(height: 12 * s),
        visual,
        SizedBox(height: 12 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: _Colors.orange500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.orange500.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, size: 18 * s, color: orange),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  next,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: orange,
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A round icon badge (HTML `w-16 h-16 rounded-full bg-*-500/20`).
class _IconDisc extends StatelessWidget {
  const _IconDisc({
    required this.icon,
    required this.size,
    required this.color,
    required this.fill,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: fill.withValues(alpha: 0.2),
      border: Border.all(color: fill.withValues(alpha: 0.3)),
    ),
    child: Icon(icon, size: size * 0.52, color: color),
  );
}

/// Scenario 1 summary picture: the three deposits formed.
class _DepositsVisual extends StatelessWidget {
  const _DepositsVisual({
    required this.palette,
    required this.scale,
    required this.labels,
  });

  final LabPalette palette;
  final double scale;

  /// Coal, Petroleum and Natural Gas.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const swatches = [
      (_Colors.coal, _Colors.slate400, false),
      (_Colors.petroleum, _Colors.indigo400, false),
      (_Colors.gas, _Colors.sky400, true),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8 * s,
      runSpacing: 6 * s,
      children: [
        for (var i = 0; i < labels.length; i++)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
            decoration: BoxDecoration(
              color: palette.isDark ? _Colors.slate800 : _Colors.slate100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14 * s,
                  height: 14 * s,
                  decoration: BoxDecoration(
                    color: swatches[i].$1,
                    shape: swatches[i].$3
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: swatches[i].$3
                        ? null
                        : BorderRadius.circular(3),
                    border: Border.all(color: swatches[i].$2),
                  ),
                ),
                SizedBox(width: 6 * s),
                Text(
                  labels[i],
                  style: TextStyle(
                    color: palette.textStrong,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// HTML `#success-modal` body: the bouncing trophy, 'Mastery Achieved!'
/// and what was mastered.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.heading,
    required this.text,
  });

  final LabPalette palette;
  final double scale;
  final double fontScale;
  final String heading;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        _Bouncing(
          on: true,
          height: 6 * s,
          child: _IconDisc(
            icon: Icons.emoji_events,
            size: 58 * s,
            color: _Colors.yellow400,
            fill: _Colors.yellow500,
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.textStrong,
            fontSize: 20 * s,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.text,
            fontSize: 13 * s * fontScale,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// HTML `confetti(...)`: the summary burst from 60% of the height, or the
/// mastery side cannons for 2.5 s.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.scene, required Listenable repaint})
    : super(repaint: repaint);

  final _Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    if (s.confettiAt < 0 || size.isEmpty) return;
    final cannons = s.confettiCannons;
    final pieces = cannons ? s.cannonPieces : s.burstPieces;
    final k = math.min(1.0, size.shortestSide / 600);
    final paint = Paint();
    for (final c in pieces) {
      final ticks = (s.time - s.confettiAt - c.delay) * 60;
      if (ticks < 0 || ticks >= _confettiTicks) continue;
      final reach =
          c.speed *
          (1 - math.pow(_confettiDecay, ticks).toDouble()) /
          (1 - _confettiDecay);
      final origin = switch (c.side) {
        0 => Offset(size.width / 2, size.height * _burstOriginY),
        -1 => Offset(0, size.height / 2),
        _ => Offset(size.width, size.height / 2),
      };
      final at =
          origin +
          Offset(math.cos(c.angle), math.sin(c.angle)) * (reach * k) +
          Offset(0, _confettiGravity * ticks * k);
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: 9 * k + 3,
          height: 5 * k + 2,
        ),
        paint..color = c.color.withValues(alpha: 1 - ticks / _confettiTicks),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.scene != scene;
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// The heat haze and the label shadows.
  final Paint haze = Paint();
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the label text painters
/// and the shaded-ball paints (one per colour, drawn on a unit circle).
/// Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<int, Paint> _balls = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool _dark = true;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language, size or theme changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _dark) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _dark = dark;
  }

  /// HTML label text (`text-xs font-semibold`, white on the dark chip,
  /// slate-900 on the light one).
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _dark ? _Colors.white : _Colors.slate900,
        fontSize: _labelSize,
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// MeshStandardMaterial look for a sphere of [c] at [opacity]: a radial
  /// gradient on a unit circle, lit from the upper right like the HTML
  /// directional light.
  Paint ball(Color c, double opacity) {
    final key = c.withValues(alpha: c.a * opacity).toARGB32();
    return _balls[key] ??= Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.32, -0.42),
        1.45,
        [
          _lit(c, _highlightNormal).withValues(alpha: opacity),
          _lit(c, _viewNormal).withValues(alpha: opacity),
          labShade(c, -0.25).withValues(alpha: opacity),
        ],
        const [0, 0.5, 1],
      );
  }

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

/// The sphere surface turned to the light (highlight) and to the camera.
const _V _highlightNormal = _V(0.36, 0.56, 0.75);
const _V _viewNormal = _V(0, 0.3, 0.95);

/// MeshStandardMaterial look: the ambient light plus the directional
/// light's Lambert term on a surface with normal [n]; [metal] (the
/// material's metalness) darkens the diffuse colour as in Three.js without
/// an environment map.
Color _lit(Color c, _V n, {double metal = 0}) {
  final k =
      (_ambient + _keyPower * math.max(0.0, n.dot(_keyLight))) *
      (1 - metal * 0.55);
  double channel(double v) => math.min(1.0, v * k);
  return Color.from(
    alpha: c.a,
    red: channel(c.r),
    green: channel(c.g),
    blue: channel(c.b),
  );
}

/// The part of the polygon [poly] where the linear function [side] is not
/// negative (one Sutherland–Hodgman pass): what is left of a tree sinking
/// into the ground or falling against the block's wall.
List<_V> _clipHalf(List<_V> poly, double Function(_V v) side) {
  final out = <_V>[];
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i], b = poly[(i + 1) % poly.length];
    final da = side(a), db = side(b);
    if (da >= 0) out.add(a);
    if ((da >= 0) != (db >= 0)) out.add(_V.lerp(a, b, da / (da - db)));
  }
  return out;
}

/// Rows a label chip tries, in order, when its place is taken: its own,
/// one up, one down, two up …
const List<int> _labelRows = [0, -1, 1, -2, 2, -3, 3, 4, 5];

/// One HTML 2D label (`createHTMLLabel`): its text, dot colour (and the
/// dot's ring), the world point it points at, and whether it carries the
/// petrol-pump icon.
@immutable
class _Label {
  const _Label(this.text, this.dot, this.at, {this.ring, this.pump = false});

  final String text;
  final Color dot;
  final _V at;
  final Color? ring;
  final bool pump;
}

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer; the
/// ground and the Earth's layers are drawn at once, in order.
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

  /// Fills a projected face, with a hairline of its own colour so the
  /// faces of a mesh meet without seams.
  void _fillFace(List<Offset> pts, Color color, {double seam = 0.7}) {
    final path = polygon(pts);
    canvas.drawPath(path, pens.fill..color = color);
    if (seam > 0 && color.a > 0.99) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = seam
          ..color = color,
      );
    }
  }

  // ---------------------------------------------------------- primitives

  /// BoxGeometry of [size] in the frame [xf] (its axes carry the mesh's
  /// rotation and scale), drawn now: the faces turned to the camera, lit,
  /// with soft edges. [only] keeps the faces whose world normal passes.
  void boxNow(
    _Xf xf,
    _V size,
    Color color, {
    double opacity = 1,
    double metal = 0,
    bool basic = false,
    double edge = 0.3,
    bool Function(_V n)? only,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final nl = face.normal;
      final n = xf.dir(nl).unit;
      final mid = xf(nl.x * hx, nl.y * hy, nl.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      if (only != null && !only(n)) continue;
      final pts = [
        for (final k in face.corners) cam.p(xf(k.x * hx, k.y * hy, k.z * hz)),
      ];
      final c = basic ? color : _lit(color, n, metal: metal);
      _fillFace(pts, c.withValues(alpha: c.a * opacity));
      if (edge > 0) {
        canvas.drawPath(
          polygon(pts),
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// Queues a box at its centre's depth (or [depth]).
  void box(
    _Xf xf,
    _V size,
    Color color, {
    double opacity = 1,
    double metal = 0,
    bool basic = false,
    double edge = 0.3,
    double? depth,
  }) => later(
    depth ?? cam.depth(xf.o),
    () => boxNow(
      xf,
      size,
      color,
      opacity: opacity,
      metal: metal,
      basic: basic,
      edge: edge,
    ),
  );

  /// CylinderGeometry([rTop], [rBottom], [h], [segments]) centred on [xf],
  /// its axis along the frame's y (a cone when [rTop] is 0), drawn now with
  /// flat-lit facets. [clipY] keeps only the part above that height and
  /// [clipX] the part right of that x.
  void frustumNow(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 12,
    double opacity = 1,
    double metal = 0,
    bool basic = false,
    double? clipY,
    double? clipX,
  }) {
    final hh = h / 2;
    final top = <_V>[], bottom = <_V>[];
    for (var i = 0; i < segments; i++) {
      // Three.js: x = r sin θ, z = r cos θ.
      final t = 2 * math.pi * i / segments;
      final sn = math.sin(t), cs = math.cos(t);
      top.add(xf(rTop * sn, hh, rTop * cs));
      bottom.add(xf(rBottom * sn, -hh, rBottom * cs));
    }
    final axisTop = xf(0, hh, 0), axisBottom = xf(0, -hh, 0);
    final axis = (axisTop - axisBottom).unit;
    void draw(List<_V> poly, _V n) {
      var pts = poly;
      if (clipY != null) pts = _clipHalf(pts, (v) => v.y - clipY);
      if (clipX != null) pts = _clipHalf(pts, (v) => v.x - clipX);
      if (pts.length < 3) return;
      final c = basic ? color : _lit(color, n, metal: metal);
      _fillFace([
        for (final v in pts) cam.p(v),
      ], c.withValues(alpha: c.a * opacity));
    }

    for (var i = 0; i < segments; i++) {
      final j = (i + 1) % segments;
      final quad = [bottom[i], bottom[j], top[j], top[i]];
      final mid = (bottom[i] + bottom[j] + top[j] + top[i]) * 0.25;
      var n = (bottom[j] - bottom[i]).cross(top[i] - bottom[i]);
      final along = (mid - axisBottom).dot(axis);
      final radial = mid - (axisBottom + axis * along);
      if (n.dot(radial) < 0) n = -n;
      n = n.unit;
      if (n.dot(cam.eye - mid) <= 0) continue;
      draw(quad, n);
    }
    if (rTop > 0 && axis.dot(cam.eye - axisTop) > 0) draw(top, axis);
    if (rBottom > 0 && (-axis).dot(cam.eye - axisBottom) > 0) {
      draw(bottom, -axis);
    }
  }

  /// Queues a cylinder / cone at its centre's depth (or [depth]).
  void frustum(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 12,
    double opacity = 1,
    double metal = 0,
    bool basic = false,
    double? depth,
  }) => later(
    depth ?? cam.depth(xf.o),
    () => frustumNow(
      xf,
      rTop,
      rBottom,
      h,
      color,
      segments: segments,
      opacity: opacity,
      metal: metal,
      basic: basic,
    ),
  );

  /// SphereGeometry of radius [r] at [c], drawn now.
  void sphereNow(_V c, double r, Color color, {double opacity = 1}) {
    final rr = r * cam.scaleAt(c);
    if (rr < 0.3) return;
    final p = cam.p(c);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.scale(rr);
    canvas.drawCircle(Offset.zero, 1, cache.ball(color, opacity));
    canvas.restore();
  }

  /// Queues a sphere at its centre's depth (or [depth]).
  void sphere(
    _V c,
    double r,
    Color color, {
    double opacity = 1,
    double? depth,
  }) => later(
    depth ?? cam.depth(c),
    () => sphereNow(c, r, color, opacity: opacity),
  );

  /// TorusGeometry([radius], [tube]) in the frame's x–y plane (a bicycle
  /// wheel), queued at its centre's depth.
  void ring(_Xf xf, double radius, double tube, Color color) =>
      later(cam.depth(xf.o), () {
        const n = 28;
        final pts = [
          for (var i = 0; i < n; i++)
            cam.p(
              xf(
                radius * math.cos(2 * math.pi * i / n),
                radius * math.sin(2 * math.pi * i / n),
                0,
              ),
            ),
        ];
        canvas.drawPath(
          polygon(pts),
          pens.stroke
            ..strokeWidth = 2 * tube * cam.scaleAt(xf.o)
            ..color = _lit(color, xf.z.unit),
        );
      });
}

/// Paints the HTML Three.js scene of the current scenario: S1 the Earth
/// cross-section (basement, swamp forest, river, sea, organic layer,
/// sediment, deposits, heat glow), S2 the town (roads, buildings, family,
/// bicycle, car, bus, nozzle, exhaust smoke); then the HTML 2D labels.
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
    cache.prepare(lang, labelSize, isDark);
    final s = scene;
    final g = _Gfx(canvas, s.camera(), cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    final labels = <_Label>[];
    if (s.scenario == 0) {
      _paintEarth(g, labels);
    } else {
      _paintTown(g, labels);
    }
    if (showLabels) _paintLabels(g, labels);
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()` with the state of the slider, the bucket, the levers
  /// and the time-lapse. The basement and the layers are drawn bottom up;
  /// the trees after them, cut off where they sink into the ground; the
  /// sea water over the plankton; the sediment on top. Once the sediment
  /// is pressed into the layers below (where the HTML's coplanar front
  /// faces flicker), the organic layer, coal and petroleum fronts and the
  /// gas pockets are drawn in front of it, as a cut-away.
  void _paintEarth(_Gfx g, List<_Label> labels) {
    final s = scene;
    final now = s.time;
    final cam = g.cam;
    g.boxNow(const _Xf.at(_basementAt), _basementSize, _Colors.basement);
    if (s.heat > _glowFrom) _paintHeatGlow(g, s.heat);
    g.boxNow(const _Xf.at(_swampAt), _swampSize, _Colors.swampGround);
    g.boxNow(const _Xf.at(_riverBedAt), _riverBedSize, _Colors.riverBed);
    g.boxNow(const _Xf.at(_bankLeftAt), _bankSize, _Colors.riverBank);
    g.boxNow(const _Xf.at(_bankRightAt), _bankSize, _Colors.riverBank);
    final ripple = math.sin(now * _rippleRate) * _rippleAmp;
    g.boxNow(
      _Xf.at(_riverAt + _V(0, 0, ripple)),
      _riverSize,
      _Colors.riverWater,
      opacity: _riverOpacity,
      metal: _riverMetal,
      edge: 0,
    );
    g.boxNow(const _Xf.at(_seabedAt), _seabedSize, _Colors.seabed);

    final organic = const _Xf.at(
      _organicAt,
    ).child(_V.zero, sy: s.organicScale.at(now));
    final coal = const _Xf.at(_coalAt).child(_V.zero, sy: s.coalScale.at(now));
    final petro = const _Xf.at(
      _petroAt,
    ).child(_V.zero, sy: s.petroScale.at(now));
    if (s.organicVisible) g.boxNow(organic, _organicSize, _Colors.organic);
    if (s.coalVisible) {
      g.boxNow(coal, _coalSize, _Colors.coal, metal: _coalMetal);
    }
    if (s.petroVisible) g.boxNow(petro, _petroSize, _Colors.petroleum);

    // The trees topple and sink into whatever ground is highest.
    final organicTop = s.organicVisible
        ? s.organicTop(now)
        : double.negativeInfinity;
    final ground = [_swampTop, organicTop, s.coalTop(now)].reduce(math.max);
    final trees = [...s.trees]
      ..sort(
        (a, b) =>
            cam.depth(_V(b.x, 0, b.z)).compareTo(cam.depth(_V(a.x, 0, a.z))),
      );
    for (final t in trees) {
      _paintTree(g, t, s.timePct, ground);
    }

    // Plankton sink to the seabed; those under the layers are buried.
    final seaFloor = [_seabedTop, organicTop, s.petroTop(now)].reduce(math.max);
    final drift = [
      for (final p in s.plankton)
        p.withY(math.max(_planktonFloor, p.y - s.timePct * _planktonSink)),
    ]..sort((a, b) => cam.depth(b).compareTo(cam.depth(a)));
    for (final p in drift) {
      if (p.y + _planktonR * 0.4 < seaFloor) continue;
      g.sphereNow(p, _planktonR, _Colors.plankton);
    }
    g.boxNow(
      const _Xf.at(_seaAt),
      _seaSize,
      _Colors.seaWater,
      opacity: _seaOpacity,
      edge: 0,
    );

    var sedimentY = _sedimentRestY;
    if (s.sedimentVisible) {
      sedimentY = s.sedimentY.at(now);
      g.boxNow(_Xf.at(_V(0, sedimentY, 0)), _sedimentSize, _Colors.sediment);
      bool front(_V n) => n.z > 0.5;
      final bottom = sedimentY - _sedimentSize.y / 2;
      if (s.organicVisible && organicTop > bottom) {
        g.boxNow(organic, _organicSize, _Colors.organic, only: front);
      }
      if (s.coalVisible && s.coalTop(now) > bottom) {
        g.boxNow(coal, _coalSize, _Colors.coal, metal: _coalMetal, only: front);
      }
      if (s.petroVisible && s.petroTop(now) > bottom) {
        g.boxNow(petro, _petroSize, _Colors.petroleum, only: front);
      }
    }
    if (s.gasVisible) {
      final bubbles = [
        for (var i = 0; i < s.gasHome.length; i++)
          s.gasHome[i].withY(s.gasY[i]),
      ]..sort((a, b) => cam.depth(b).compareTo(cam.depth(a)));
      for (final b in bubbles) {
        g.sphereNow(b, _gasR, _Colors.gas, opacity: _gasOpacity);
      }
    }

    // HTML createHTMLLabel(): group position + offset.
    labels.addAll([
      _Label(_t('lbl_swamp'), _Colors.emerald500, const _V(0, 5, 0)),
      if (s.organicVisible)
        _Label(
          _t('lbl_organic'),
          _Colors.amber500,
          _organicAt + const _V(0, 1.3, 4.3),
        ),
      if (s.sedimentVisible)
        _Label(
          _t('lbl_sediment'),
          _Colors.slate300,
          _V(0, sedimentY + 1.5, 4.3),
        ),
      if (s.coalVisible)
        _Label(
          _t('lbl_coal'),
          _Colors.slate900,
          _coalAt + const _V(0, 1.1, 4.3),
          ring: _Colors.slate400,
        ),
      if (s.petroVisible)
        _Label(
          _t('lbl_petro'),
          _Colors.indigo900,
          _petroAt + const _V(0, 1, 4.3),
          ring: _Colors.indigo400,
        ),
      if (s.gasVisible)
        _Label(_t('lbl_gas'), _Colors.sky400, const _V(0, 2.2, 4.3)),
    ]);
  }

  /// HTML heat glow (`MeshBasicMaterial`, opacity heat × 0.95): its box is
  /// 0.1 wider than the basement on every side, so a red-orange band shows
  /// round it; a soft haze glows about the band.
  void _paintHeatGlow(_Gfx g, double heat) {
    final a = (heat * _glowMax).clamp(0.0, 1.0);
    final half = _glowSize * 0.5;
    final band = g.cam.boxRect(_glowAt - half, _glowAt + half);
    g.canvas.drawRect(
      band.inflate(10),
      _pens.haze
        ..color = _Colors.heatGlow.withValues(alpha: 0.5 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    g.boxNow(
      const _Xf.at(_glowAt),
      _glowSize,
      _Colors.heatGlow,
      opacity: a,
      basic: true,
      edge: 0,
      only: (n) => n.y.abs() < 0.5,
    );
  }

  /// One swamp tree: the trunk and three cones, toppled and sunk by the
  /// 'Time Forward' slider ([pct] 0…1) and cut off at [ground] and at the
  /// block's left wall (in the HTML the fallen crowns poked out of it).
  void _paintTree(_Gfx g, _Tree t, double pct, double ground) {
    final i = t.index;
    final xf = _Xf.at(_V(t.x, _treeBaseY - pct * _treeSink, t.z)).child(
      _V.zero,
      rx: pct * (i % 3 == 0 ? _treeLeanFront : _treeLeanBack),
      rz: pct * (_treeTip + (i % 2) * _treeTipExtra),
    );
    g
      ..frustumNow(
        xf.child(const _V(0, 1.6, 0)),
        0.18,
        0.35,
        3.2,
        _Colors.trunk,
        segments: 8,
        clipY: ground,
        clipX: _treeWall,
      )
      ..frustumNow(
        xf.child(const _V(0, 3, 0)),
        0,
        1.4,
        1.6,
        _Colors.canopy1,
        segments: 8,
        clipY: ground,
        clipX: _treeWall,
      )
      ..frustumNow(
        xf.child(const _V(0, 3.9, 0)),
        0,
        1.1,
        1.4,
        _Colors.canopy2,
        segments: 8,
        clipY: ground,
        clipX: _treeWall,
      )
      ..frustumNow(
        xf.child(const _V(0, 4.6, 0)),
        0,
        0.7,
        1.2,
        _Colors.canopy3,
        segments: 8,
        clipY: ground,
        clipX: _treeWall,
      );
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the lawn, sidewalk and roads first, then every
  /// building, tree, person and vehicle far to near.
  void _paintTown(_Gfx g, List<_Label> labels) {
    final s = scene;
    final now = s.time;
    g
      ..boxNow(const _Xf.at(_V(0, -0.5, 0)), const _V(18, 1, 12), _Colors.lawn)
      ..boxNow(
        const _Xf.at(_V(0, 0.04, 0)),
        const _V(17.6, 0.12, 11.6),
        _Colors.sidewalk,
      )
      ..boxNow(
        const _Xf.at(_V(0, 0.08, -2.2)),
        const _V(17.6, 0.08, 2.4),
        _Colors.asphalt,
        edge: 0,
      )
      ..boxNow(
        const _Xf.at(_V(0, 0.08, 2.4)),
        const _V(17.6, 0.08, 2.4),
        _Colors.asphalt,
        edge: 0,
      )
      ..boxNow(
        const _Xf.at(_V(2.8, 0.08, 0.1)),
        const _V(2.4, 0.08, 2.8),
        _Colors.asphalt,
        edge: 0,
      );
    // White centre dashes every 2.2 from -7.5.
    for (var x = -7.5; x <= 7.5; x += 2.2) {
      for (final z in const [-2.2, 2.4]) {
        g.boxNow(
          _Xf.at(_V(x, 0.13, z)),
          const _V(1, 0.02, 0.12),
          _Colors.white,
          basic: true,
          edge: 0,
        );
      }
    }
    for (final (x, z) in const [
      (-8.0, -4.5),
      (-4.2, -4.5),
      (-0.2, -4.5),
      (5.0, -4.5),
      (8.0, -1.5),
    ]) {
      _paintCityTree(g, x, z);
    }
    _paintHouse(g);
    _paintMarket(g);
    _paintPump(g);
    _paintSchool(g);
    _paintBusStop(g);
    if (s.familyVisible) _paintFamily(g, s.family.at(now));
    _paintBike(g, s.bike.at(now));
    _paintCar(g, s.car.at(now));
    if (s.busVisible || s.step >= 4) _paintBus(g, s.bus.at(now));
    if (s.nozzleVisible) _paintNozzle(g, s.nozzle.at(now));
    if (s.smokeVisible) {
      for (final p in s.smoke) {
        g.sphere(p, _smokeR, _Colors.smoke, opacity: _smokeOpacity);
      }
    }
    g.flush();
    labels.addAll([
      _Label(_t('lbl_house'), _Colors.orange500, const _V(-6.5, 4.4, -4.5)),
      _Label(_t('lbl_market'), _Colors.sky500, const _V(-1.5, 4.1, -4.5)),
      _Label(
        _t('lbl_pump'),
        _Colors.indigo500,
        const _V(3, 4.2, -4.5),
        pump: true,
      ),
      _Label(_t('lbl_school'), _Colors.yellow500, const _V(6.5, 4.9, -1.5)),
      _Label(_t('lbl_bus_stop'), _Colors.blue600, const _V(-6, 3.3, 4.2)),
    ]);
  }

  /// `addCityTree(x, z)`: trunk and a round crown.
  void _paintCityTree(_Gfx g, double x, double z) {
    final t = _Xf.at(_V(x, 0.1, z));
    g
      ..frustum(t.child(const _V(0, 0.65, 0)), 0.12, 0.18, 1.3, _Colors.wood)
      ..sphere(t(0, 1.6, 0), 0.7, _Colors.leaves);
  }

  /// HOUSE: walls, pitched roof, door, two windows and the chimney.
  void _paintHouse(_Gfx g) {
    final h = const _Xf.at(_V(-6.5, 0.1, -4.5));
    final roof = h.child(const _V(0, 2.9, 0), ry: math.pi / 4);
    g
      ..box(
        h.child(const _V(0, 1.1, 0)),
        const _V(3, 2.2, 2.6),
        _Colors.houseWall,
      )
      ..frustum(roof, 0, 2.6, 1.4, _Colors.roof, segments: 4)
      ..box(
        h.child(const _V(0, 0.7, 1.31)),
        const _V(0.8, 1.4, 0.1),
        _Colors.wood,
      )
      ..box(
        h.child(const _V(-0.85, 1.3, 1.31)),
        const _V(0.6, 0.7, 0.1),
        _Colors.glass,
      )
      ..box(
        h.child(const _V(0.85, 1.3, 1.31)),
        const _V(0.6, 0.7, 0.1),
        _Colors.glass,
      )
      // The chimney pokes out of the roof behind its ridge.
      ..box(
        h.child(const _V(0.8, 3, -0.4)),
        const _V(0.5, 1.1, 0.5),
        _Colors.wood,
        depth: g.cam.depth(roof.o) - 0.01,
      );
  }

  /// MARKET: storefront, glass window, red awning, sign, fruit crate.
  void _paintMarket(_Gfx g) {
    final m = const _Xf.at(_V(-1.5, 0.1, -4.5));
    g
      ..box(
        m.child(const _V(0, 1.25, 0)),
        const _V(3.4, 2.5, 2.6),
        _Colors.marketWall,
      )
      ..box(
        m.child(const _V(0, 1.1, 1.31)),
        const _V(2.4, 1.3, 0.1),
        _Colors.glass,
        opacity: 0.85,
      )
      ..box(
        m.child(const _V(0, 1.9, 1.6), rx: 0.35),
        const _V(2.8, 0.15, 0.8),
        _Colors.red500,
      )
      ..box(
        m.child(const _V(0, 2.3, 1.32)),
        const _V(2.6, 0.5, 0.15),
        _Colors.slate800,
      )
      ..box(
        m.child(const _V(-1, 0.2, 1.6)),
        const _V(0.7, 0.4, 0.6),
        _Colors.crate,
      )
      ..sphere(m(-1, 0.45, 1.6), 0.28, _Colors.orange500);
  }

  /// PETROL PUMP STATION: island, two pillars, blue canopy, red dispenser
  /// with its green screen.
  void _paintPump(_Gfx g) {
    final p = const _Xf.at(_V(3, 0.1, -4.5));
    g
      ..box(
        p.child(const _V(0, 0.1, 0)),
        const _V(3, 0.2, 1.8),
        _Colors.sidewalk,
      )
      ..frustum(
        p.child(const _V(-1.2, 1.4, 0)),
        0.18,
        0.18,
        2.6,
        _Colors.pillar,
        metal: 0.3,
      )
      ..frustum(
        p.child(const _V(1.2, 1.4, 0)),
        0.18,
        0.18,
        2.6,
        _Colors.pillar,
        metal: 0.3,
      )
      ..box(
        p.child(const _V(0, 2.7, 0)),
        const _V(3.6, 0.35, 2.6),
        _Colors.blue500,
      )
      ..box(
        p.child(const _V(0, 0.95, 0.2)),
        const _V(0.9, 1.5, 0.7),
        _Colors.red500,
      )
      ..box(
        p.child(const _V(0, 1.3, 0.57)),
        const _V(0.6, 0.4, 0.05),
        _Colors.emerald500,
        basic: true,
        edge: 0,
      );
  }

  /// SCHOOL: building, clock tower, four windows, flagpole and flag.
  void _paintSchool(_Gfx g) {
    final c = const _Xf.at(_V(6.5, 0.1, -1.5));
    g
      ..box(
        c.child(const _V(0, 1.6, 0)),
        const _V(4.2, 3.2, 2.8),
        _Colors.yellow400,
      )
      ..box(
        c.child(const _V(0, 2, 0)),
        const _V(1.6, 4, 3),
        _Colors.schoolTower,
      )
      ..frustum(
        c.child(const _V(0, 3.3, 1.51), rx: math.pi / 2),
        0.45,
        0.45,
        0.1,
        _Colors.slate50,
        segments: 16,
        basic: true,
      );
    for (final x in const [-1.3, 1.3]) {
      for (final y in const [1.0, 2.2]) {
        g.box(c.child(_V(x, y, 1.41)), const _V(0.8, 0.7, 0.1), _Colors.sky400);
      }
    }
    g
      ..frustum(
        c.child(const _V(-1.6, 1.6, 2)),
        0.04,
        0.05,
        3.2,
        _Colors.slate400,
        segments: 8,
        metal: 0.6,
      )
      ..box(
        c.child(const _V(-1.6, 2.9, 2.36)),
        const _V(0.02, 0.5, 0.7),
        _Colors.red500,
        basic: true,
        edge: 0,
      );
  }

  /// BUS STOP: glass shelter, blue roof, bench, post and its sign board.
  void _paintBusStop(_Gfx g) {
    final b = const _Xf.at(_V(-6, 0.1, 4.2));
    g
      ..box(
        b.child(const _V(0, 1, 0.8)),
        const _V(2.6, 2, 0.1),
        _Colors.glass,
        opacity: 0.55,
        edge: 0.2,
      )
      ..box(
        b.child(const _V(-1.3, 1, 0.2)),
        const _V(0.1, 2, 1.2),
        _Colors.glass,
        opacity: 0.55,
        edge: 0.2,
      )
      ..box(
        b.child(const _V(0, 2.05, 0.1), rx: -0.15),
        const _V(2.8, 0.18, 1.6),
        _Colors.busStopRoof,
      )
      ..box(
        b.child(const _V(0, 0.45, 0.5)),
        const _V(2, 0.35, 0.5),
        _Colors.crate,
      )
      ..frustum(
        b.child(const _V(1.6, 1.4, 0.5)),
        0.06,
        0.06,
        2.8,
        _Colors.slate700,
        segments: 8,
      )
      ..box(
        b.child(const _V(1.6, 2.5, 0.5)),
        const _V(0.6, 0.6, 0.1),
        _Colors.busStopBoard,
        basic: true,
      );
  }

  /// The family: an adult and two children (head, hair, shirt, legs).
  void _paintFamily(_Gfx g, _V at) {
    final f = _Xf.at(at);
    _paintPerson(
      g,
      f,
      1.15,
      _Colors.red500,
      _Colors.slate800,
      _Colors.slate800,
    );
    _paintPerson(
      g,
      f.child(const _V(-0.6, 0, 0.2)),
      0.85,
      _Colors.emerald500,
      _Colors.blue600,
      _Colors.wood,
    );
    _paintPerson(
      g,
      f.child(const _V(0.55, 0, 0.15)),
      0.78,
      _Colors.amber500,
      _Colors.slate700,
      _Colors.slate800,
    );
  }

  /// HTML `buildCharacter(heightScale, shirt, pants, hair)`.
  void _paintPerson(
    _Gfx g,
    _Xf c,
    double k,
    Color shirt,
    Color pants,
    Color hair,
  ) {
    g
      ..sphere(c(0, 1.25 * k, -0.04 * k), 0.24 * k, hair)
      ..sphere(c(0, 1.15 * k, 0), 0.22 * k, _Colors.skin)
      ..box(
        c.child(_V(0, 0.75 * k, 0)),
        _V(0.45 * k, 0.55 * k, 0.26 * k),
        shirt,
        edge: 0.2,
      );
    for (final x in [-0.13 * k, 0.13 * k]) {
      g.frustum(
        c.child(_V(x, 0.24 * k, 0)),
        0.09 * k,
        0.09 * k,
        0.48 * k,
        pants,
        segments: 8,
      );
    }
  }

  /// BICYCLE: two wheels, green frame, seat post, seat, handlebars.
  void _paintBike(_Gfx g, _V at) {
    final b = _Xf.at(at);
    g
      ..ring(b.child(const _V(0.6, 0.35, 0)), 0.35, 0.06, _Colors.slate800)
      ..ring(b.child(const _V(-0.6, 0.35, 0)), 0.35, 0.06, _Colors.slate800)
      ..frustum(
        b.child(const _V(0, 0.55, 0), rz: math.pi / 2.3),
        0.04,
        0.04,
        1.1,
        _Colors.emerald500,
        segments: 8,
      )
      ..frustum(
        b.child(const _V(-0.35, 0.6, 0), rz: -0.3),
        0.04,
        0.04,
        0.6,
        _Colors.slate700,
        segments: 8,
      )
      ..box(
        b.child(const _V(-0.35, 0.85, 0)),
        const _V(0.35, 0.1, 0.2),
        _Colors.slate900,
        edge: 0,
      )
      ..frustum(
        b.child(const _V(0.5, 0.95, 0), rx: math.pi / 2),
        0.04,
        0.04,
        0.6,
        _Colors.slate700,
        segments: 8,
      );
  }

  /// CAR: blue body, cabin, dark glass, head- and taillights, fuel cap,
  /// exhaust pipe and four wheels with rims.
  void _paintCar(_Gfx g, _V at) {
    final c = _Xf.at(at);
    g
      ..box(
        c.child(const _V(0, 0.3, 0)),
        const _V(2.6, 0.6, 1.4),
        _Colors.carBody,
        metal: 0.3,
      )
      ..box(
        c.child(const _V(-0.1, 0.82, 0)),
        const _V(1.6, 0.55, 1.25),
        _Colors.carCabin,
      )
      ..box(
        c.child(const _V(-0.1, 0.84, 0)),
        const _V(1.65, 0.45, 1.28),
        _Colors.slate900,
        metal: 0.5,
      )
      ..box(
        c.child(const _V(1.3, 0.35, 0)),
        const _V(0.1, 0.2, 1.1),
        _Colors.headlight,
        basic: true,
        edge: 0,
      )
      ..box(
        c.child(const _V(-1.3, 0.35, 0)),
        const _V(0.1, 0.2, 1.1),
        _Colors.red500,
        basic: true,
        edge: 0,
      )
      ..frustum(
        c.child(const _V(0, 0.45, -0.71), rx: math.pi / 2),
        0.15,
        0.15,
        0.05,
        _Colors.slate400,
        metal: 0.8,
      )
      ..frustum(
        c.child(const _V(-1.35, 0.12, 0.4), rz: math.pi / 2),
        0.08,
        0.08,
        0.3,
        _Colors.slate600,
        segments: 8,
        metal: 0.7,
      );
    for (final (x, z) in const [
      (-0.8, -0.72),
      (0.8, -0.72),
      (-0.8, 0.72),
      (0.8, 0.72),
    ]) {
      final w = c.child(_V(x, 0.05, z), rx: math.pi / 2);
      g
        ..frustum(w, 0.32, 0.32, 0.22, _Colors.slate800, segments: 16)
        ..frustum(
          w,
          0.18,
          0.18,
          0.24,
          _Colors.slate400,
          segments: 12,
          metal: 0.8,
        );
    }
  }

  /// BUS: amber body, blue stripe, window band with the passengers'
  /// silhouettes, green route sign and six wheels. (The HTML put the
  /// passengers' heads inside its opaque window band, where they never
  /// showed; here they are drawn on the band.)
  void _paintBus(_Gfx g, _V at) {
    final b = _Xf.at(at);
    final windows = b.child(const _V(0, 0.85, 0));
    final windowDepth = g.cam.depth(windows.o);
    g
      ..box(
        b.child(const _V(0, 0.5, 0)),
        const _V(4.8, 1.8, 1.7),
        _Colors.amber500,
      )
      ..box(
        b.child(const _V(0, 0.2, 0)),
        const _V(4.82, 0.35, 1.72),
        _Colors.blue600,
      )
      ..box(windows, const _V(4.6, 0.7, 1.74), _Colors.sky400);
    for (var x = -1.6; x <= 1.6 + 1e-9; x += 0.8) {
      g.sphere(
        b(x, 0.85, 0.66),
        0.2,
        _Colors.slate800,
        depth: windowDepth - 0.001,
      );
    }
    g.box(
      b.child(const _V(1.7, 1.25, 0)),
      const _V(1.2, 0.25, 1.73),
      _Colors.emerald500,
      basic: true,
      edge: 0,
    );
    for (final x in const [-1.6, 0.0, 1.6]) {
      for (final z in const [-0.85, 0.85]) {
        final w = b.child(_V(x, -0.35, z), rx: math.pi / 2);
        g
          ..frustum(w, 0.38, 0.38, 0.26, _Colors.slate900, segments: 16)
          ..frustum(
            w,
            0.2,
            0.2,
            0.28,
            _Colors.slate400,
            segments: 12,
            metal: 0.6,
          );
      }
    }
  }

  /// FUEL NOZZLE: red handle and its spout.
  void _paintNozzle(_Gfx g, _V at) {
    final n = _Xf.at(at);
    g
      ..box(n, const _V(0.3, 0.4, 0.18), _Colors.red500)
      ..frustum(
        n.child(const _V(0, -0.25, 0)),
        0.04,
        0.04,
        0.4,
        _Colors.slate400,
        segments: 8,
        metal: 0.8,
      );
  }

  // -------------------------------------------------------------- labels

  /// HTML `.html-labels-layer` chips (`translate(-50%, -120%)` above the
  /// point): dot, text, rounded pill. A chip that would cover an earlier
  /// one or the controls card moves a row up (or down) until it is free;
  /// every chip stays on the stage.
  void _paintLabels(_Gfx g, List<_Label> labels) {
    final canvas = g.canvas;
    final k = labelSize / _labelPx;
    final placed = <Rect>[];
    final obstacle = scene.labelObstacle;
    final dot = 8 * k, gap = 7 * k, padX = 11 * k, padY = 5 * k;
    for (final l in labels) {
      if (g.cam.depth(l.at) < _clipDepth) continue;
      final p = g.cam.p(l.at);
      final tp = cache.label(l.text);
      final icon = l.pump ? tp.height : 0.0;
      final w =
          2 * padX + dot + gap + tp.width + (l.pump ? icon + gap * 0.6 : 0);
      final h = 2 * padY + tp.height;
      var rect = Rect.fromLTWH(p.dx - w / 2, p.dy - 1.2 * h, w, h);
      if (rect.left < 4) rect = rect.shift(Offset(4 - rect.left, 0));
      if (rect.right > _design.width - 4) {
        rect = rect.shift(Offset(_design.width - 4 - rect.right, 0));
      }
      bool clear(Rect r, {required bool card}) =>
          !placed.any((p) => p.overlaps(r.inflate(2 * k))) &&
          !(card && obstacle != null && obstacle.overlaps(r));
      final row = h + 3 * k;
      final tries = [
        for (final dy in _labelRows) rect.shift(Offset(0, dy * row)),
      ];
      rect =
          tries.where((r) => clear(r, card: true)).firstOrNull ??
          tries.where((r) => clear(r, card: false)).firstOrNull ??
          rect;
      placed.add(rect);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));
      canvas
        ..drawRRect(
          rr.shift(Offset(0, 2 * k)),
          _pens.haze
            ..color = _Colors.black.withValues(alpha: 0.3)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * k),
        )
        ..drawRRect(
          rr,
          _pens.fill..color = isDark ? _Colors.chipDark : _Colors.chipLight,
        )
        ..drawRRect(
          rr,
          _pens.stroke
            ..strokeWidth = 1
            ..color = isDark ? _Colors.chipBorderDark : _Colors.chipBorderLight,
        );
      final dotAt = Offset(rect.left + padX + dot / 2, rect.center.dy);
      canvas.drawCircle(dotAt, dot / 2, _pens.fill..color = l.dot);
      final ring = l.ring;
      if (ring != null) {
        canvas.drawCircle(
          dotAt,
          dot / 2,
          _pens.stroke
            ..strokeWidth = 1
            ..color = ring,
        );
      }
      var x = rect.left + padX + dot + gap;
      if (l.pump) {
        // Added: the HTML's flat petrol-pump icon marks the station.
        _paintPumpIcon(
          canvas,
          Rect.fromLTWH(x, rect.center.dy - icon / 2, icon, icon),
        );
        x += icon + gap * 0.6;
      }
      tp.paint(canvas, Offset(x, rect.center.dy - tp.height / 2));
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
