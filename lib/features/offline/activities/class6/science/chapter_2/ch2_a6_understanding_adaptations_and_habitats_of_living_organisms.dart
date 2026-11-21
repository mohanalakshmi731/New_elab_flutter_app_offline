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

/// Class 6 Science • Chapter 2 • Activity 6
/// Understanding Adaptations and Habitats of Living Organisms ("Habitat
/// Challenge: Survival of the Fittest").
///
/// Native Flutter port of
/// `Cl6S-Ch02-A6-Understanding_Adaptations_and_Habitats_of_Living_Organisms.html`.
///
/// Scenario 1 (The Plant Placement Problem): a split world, a hot desert
/// on the left and a snowy mountain on the right. A deodar tree dragged
/// from the inventory tray into the desert wilts and turns brown in the
/// sun; back in the mountain, snow slides off its conical crown. A cactus
/// dragged into the mountain collects snow on its flat pads and its arms
/// snap; back in the desert, its fleshy stem swells as it stores water.
///
/// Scenario 2 (The Camel Conundrum): a one-humped, long-legged hot desert
/// camel stumbles on the rocky cold desert and shivers in the cold wind; a
/// two-humped, woolly cold desert camel sinks into the sand and overheats
/// in the hot desert. Matched to their own habitats, both walk easily.
/// 'Review Findings' opens each summary.
///
/// The Three.js scene is redrawn by a CustomPainter through a perspective
/// projection of the same camera (fov 45°, from (0, 20, 32) looking at the
/// origin), fitted beside the shell's cards.
class Ch2A6UnderstandingAdaptationsAndHabitatsOfLivingOrganismsPage
    extends StatefulWidget {
  const Ch2A6UnderstandingAdaptationsAndHabitatsOfLivingOrganismsPage({
    super.key,
  });

  @override
  State<Ch2A6UnderstandingAdaptationsAndHabitatsOfLivingOrganismsPage>
  createState() => _HabitatLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: the app's bundled tones in `assets/audio/`
/// (the HTML synthesises its tones with Web Audio). They map to the closest
/// files: `click` / `pop` (buttons, tools, scenario change, the curtain) →
/// click, dropdown, page open and curtain; `success` (a plant or camel
/// dropped in the right habitat, a plant thriving) → correct (math
/// success); `error` (wilting, breaking, stumbling, sinking, overheating, a
/// missed drop) and `wind` (the cold wind) → wrong (science error); `chime`
/// ('Review Findings' appears, both camels adapted) and the summary →
/// success (math success). Picking up a plant or camel plays pickup
/// (added; the HTML is silent), which reuses the click.
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`, `pop`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Dropped in the right habitat, a plant thrives (HTML `success`).
  correct('audio/class6/math/success.mp3'),

  /// Wilting, breaking, stumbling, shivering, sinking, overheating and a
  /// missed drop (HTML `error`, `wind`).
  wrong('audio/class6/science/error.mp3'),

  /// 'Review Findings' appears, both camels adapted, the summary opens
  /// (HTML `chime`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A plant or camel picked up from the tray (added; reuses the click).
  pickup('audio/class6/science/click.mp3');

  const _Sound(this.asset);

  /// Asset path below `assets/` (the audioplayers asset prefix).
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
/// (material colours, sprite and overlay colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color orange500 = Color(0xFFF97316);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky800 = Color(0xFF075985);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color green500 = Color(0xFF22C55E);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `#webgl-container`: `linear-gradient(to right, #fef08a 50%, #e0f2fe
  /// 50%)`; dark: `#78350f` / `#0f172a`.
  static const Color skyHotLight = yellow200;
  static const Color skyColdLight = sky100;
  static const Color skyHotDark = amber900;
  static const Color skyColdDark = slate900;

  /// Viewport behind the canvas (`bg-[#f8fafc] dark:bg-[#0f172a]`).
  static const Color canvasLight = Color(0xFFF8FAFC);
  static const Color canvasDark = slate900;

  /// `Mats.sand`, `Mats.snow`, `Mats.rock`.
  static const Color sand = Color(0xFFFCB900);
  static const Color snow = Color(0xFFF8FAFC);
  static const Color rock = slate500;

  /// `Mats.pine`, `Mats.trunk`, `Mats.cactus` and the wilt / break colour
  /// (`0x8b4513`).
  static const Color pine = Color(0xFF166534);
  static const Color trunk = Color(0xFF451A03);
  static const Color cactus = green500;
  static const Color wilt = Color(0xFF8B4513);

  /// `Mats.hotCamel`, `Mats.coldCamel` and the hooves (`0x3e2723`); eyes
  /// and the cold camel's fur fringe (added).
  static const Color hotCamel = amber600;
  static const Color coldCamel = amber900;
  static const Color hoof = Color(0xFF3E2723);
  static const Color camelEye = Color(0xFF1C1917);

  /// Inventory tray (`MeshPhysicalMaterial` white, opacity 0.8) and its
  /// ring (`0x38bdf8`).
  static const Color tray = Color(0xCCFFFFFF);
  static const Color trayRing = sky400;

  /// `createDropZone('#f59e0b', -10)` / `createDropZone('#38bdf8', 10)`.
  static const Color zoneHot = amber500;
  static const Color zoneCold = sky400;

  /// Snow on the plants and the falling flakes (`.snowflake` white; a pale
  /// blue rim, added, keeps them visible over the snow).
  static const Color snowCap = white;
  static const Color flakeRim = Color(0x9993C5FD);

  /// Wind streaks (added) and the sand pushed aside by a sinking camel
  /// (added).
  static const Color wind = Color(0xFF94A3B8);
  static const Color sandDip = Color(0xFFB45309);

  /// Text sprites: `createTextSprite` default `#1e293b` chip, `#f59e0b`
  /// border, white text; the zone, tray and 'Drop Here' sprites.
  static const Color chipBg = slate800;
  static const Color chipBorder = amber500;
  static const Color chipText = white;

  /// `#label-text` status label: white / slate-800 at 90 %, a red or green
  /// border and text; `#label-emoji` disc.
  static const Color statusLight = Color(0xE6FFFFFF);
  static const Color statusDark = Color(0xE61E293B);
  static const Color discLight = white;
  static const Color discDark = slate800;
  static const Color discBorderLight = slate200;
  static const Color discBorderDark = slate700;

  /// The faces drawn for the HTML emoji (☹️ 😄 🥶 🥵).
  static const Color faceYellow = amber400;
  static const Color faceCold = sky300;
  static const Color faceHot = orange500;
  static const Color faceInk = Color(0xFF422006);
  static const Color tongue = rose500;
  static const Color sweat = sky400;

  /// `#icon-sun`: amber-500/20 disc, amber-400 border, glow
  /// rgba(251, 191, 36, 0.6), amber-500 sun. `#icon-freeze`: the same in
  /// sky.
  static const Color sunDisc = Color(0x33F59E0B);
  static const Color sunGlow = Color(0x99FBBF24);
  static const Color frostDisc = Color(0x330EA5E9);
  static const Color frostGlow = Color(0x9938BDF8);

  /// Added: the icons blaze while their weather plays.
  static const Color heatGlow = Color(0xFFEA580C);
  static const Color coldGlow = Color(0xFF0EA5E9);

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x52000000);
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
    canvasBg: _Colors.canvasDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // conclusion modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66D97706), // amber-600/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.amber300,
    buttonBorder: Color(0xCCF59E0B),
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
    canvasBg: _Colors.canvasLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
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
    curtainGlow: Color(0x66D97706),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.amber300,
    buttonBorder: Color(0xCCF59E0B),
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
// (Telugu dropped). `sN_step_M` are the step instructions (HTML step
// `action`, spelled out for touch), `sN_hud_M` the HTML "Current Task"
// lines ("CLICK" → "TAP"; the 'Reset …' buttons are named as they read),
// `sN_focus_M` / `sN_obs_M` / `sN_expl_M` the HTML concept, observation and
// explanation (shown once the step is done). Step 8 of each scenario is the
// HTML's eighth HUD line ('Review Findings'). The action buttons, status
// labels, 'Drop Here' and 'Inventory Tray' were English only in the HTML;
// their Hindi is added. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Habitat Challenge: Survival of the Fittest',
    'app_subtitle': 'Class 6 • Diversity in the Living World',
    'scen_1_opt': 'Scenario 1: The Plant Placement Problem',
    'scen_2_opt': 'Scenario 2: The Camel Conundrum',
    's1_desc':
        'Understand how the physical structures of a cactus and a deodar tree are adaptations to their respective desert and mountain habitats.',
    's2_desc':
        'Compare the adaptations of a hot desert camel and a cold desert camel by placing them in the correct habitats.',
    's1_step_1':
        'Drag the Deodar Tree from the inventory tray and drop it into the Hot Desert (left side).',
    's1_step_2':
        "Tap 'Simulate Day' to see how the tree handles the extreme heat and sun.",
    's1_step_3':
        "Tap 'Reset & Try Mountain', then drag the Deodar Tree into the Snowy Mountain (right side).",
    's1_step_4':
        "Tap 'Simulate Snowfall' to see how the tree's conical shape helps it survive.",
    's1_step_5':
        "Tap 'Reset & Try Cactus', then drag the Cactus into the Snowy Mountain (right side).",
    's1_step_6':
        "Tap 'Simulate Snowfall' to see what happens to the flat cactus pads.",
    's1_step_7':
        "Tap 'Reset & Try Desert', drag the Cactus to its home in the Hot Desert (left side), then tap 'Simulate Day'.",
    's1_step_8': "Tap 'Review Findings' to summarise plant adaptations.",
    's2_step_1':
        'Drag the Hot Desert Camel (one hump, long legs) from the inventory tray into the Cold Desert (right side).',
    's2_step_2': "Tap 'Walk' to see how it moves on rocky terrain.",
    's2_step_3': "Tap 'Simulate Cold Wind' to test its temperature tolerance.",
    's2_step_4':
        "Tap 'Reset', then drag the Cold Desert Camel (two humps, thick fur) into the Hot Desert (left side).",
    's2_step_5': "Tap 'Walk' to see how it moves on deep sand.",
    's2_step_6': "Tap 'Simulate Hot Day' to see how it handles the heat.",
    's2_step_7':
        "Tap 'Reset & Match Both', drag the Hot Desert Camel into the Hot Desert and the Cold Desert Camel into the Cold Desert, then tap 'Simulate Environment'.",
    's2_step_8': "Tap 'Review Findings' to summarise animal adaptations.",
    's1_hud_1':
        'Observe the two habitats. DRAG the Deodar Tree from the inventory platform and DROP it into the Hot Desert (left side).',
    's1_hud_2':
        "TAP 'Simulate Day' to see how the tree handles the extreme heat and sun.",
    's1_hud_3':
        "The tree wilted! TAP 'Reset & Try Mountain'. Then DRAG the Deodar Tree to the Snowy Mountain (right side).",
    's1_hud_4':
        "TAP 'Simulate Snowfall' to see how its conical shape helps it survive.",
    's1_hud_5':
        "Now, let's test the Cactus. TAP 'Reset & Try Cactus', then DRAG the Cactus and DROP it into the Snowy Mountain.",
    's1_hud_6':
        "TAP 'Simulate Snowfall' to see what happens to the flat cactus pads.",
    's1_hud_7':
        "The cactus broke! TAP 'Reset & Try Desert'. Then DRAG the Cactus to its home in the Hot Desert. TAP 'Simulate Day'.",
    's1_hud_8':
        "TAP the 'Review Findings' button to summarise plant adaptations.",
    's2_hud_1':
        "Let's test animal adaptations. DRAG the Hot Desert Camel (one hump, long legs) to the Cold Desert (right side).",
    's2_hud_2': "TAP 'Walk' to see how it moves on rocky terrain.",
    's2_hud_3':
        "It's stumbling! TAP 'Simulate Cold Wind' to test its temperature tolerance.",
    's2_hud_4':
        "It's shivering! TAP 'Reset'. Now, DRAG the Cold Desert Camel (two humps, thick fur) to the Hot Desert (left side).",
    's2_hud_5': "TAP 'Walk' to see how it moves on deep sand.",
    's2_hud_6':
        "It's sinking! TAP 'Simulate Hot Day' to see how it handles the heat.",
    's2_hud_7':
        "It's overheating! TAP 'Reset & Match Both'. Now match both correctly: Hot Camel to Hot Desert, Cold Camel to Cold Desert. TAP 'Simulate Environment'.",
    's2_hud_8':
        "TAP the 'Review Findings' button to summarise animal adaptations.",
    's1_focus_1': 'Wrong Habitat',
    's1_focus_2': 'No Adaptation for Heat',
    's1_focus_3': 'Correct Habitat',
    's1_focus_4': 'Adaptation for Snow',
    's1_focus_5': 'Wrong Habitat',
    's1_focus_6': 'No Adaptation for Snow',
    's1_focus_7': 'Adaptation for Heat/Dryness',
    's1_obs_1': 'Placed in desert.',
    's1_obs_2': 'Tree wilts and turns brown.',
    's1_obs_3': 'Placed in mountain.',
    's1_obs_4': 'Snow slides off; tree thrives.',
    's1_obs_5': 'Placed in mountain.',
    's1_obs_6': 'Snow accumulates; cactus breaks.',
    's1_obs_7': 'Cactus thrives and swells slightly.',
    's1_expl_1':
        'The Deodar tree naturally grows in cold mountains. Placing it in a hot desert tests its survival fitness.',
    's1_expl_2':
        'The Deodar tree lacks adaptations like fleshy stems to store water or thick cuticles to reflect extreme heat, causing it to wilt rapidly under the desert sun.',
    's1_expl_3':
        'We return the tree to its native habitat to observe its natural adaptations.',
    's1_expl_4':
        'Its conical shape and sloping branches are specific adaptations that allow heavy snow to slide off easily, preventing the branches from breaking.',
    's1_expl_5':
        'The cactus is adapted to hot, dry climates. Placing it in the snow tests its limits.',
    's1_expl_6':
        'The wide, flat surfaces of the cactus catch heavy snow. It lacks the conical shape of the Deodar, causing it to snap under the weight.',
    's1_expl_7':
        'In the desert, its fleshy green stem stores water and carries out photosynthesis, which are perfect adaptations for surviving hot, dry conditions.',
    's2_focus_1': 'Wrong Habitat',
    's2_focus_2': 'Locomotion Mismatch',
    's2_focus_3': 'Temperature Mismatch',
    's2_focus_4': 'Wrong Habitat',
    's2_focus_5': 'Locomotion Mismatch',
    's2_focus_6': 'Temperature Mismatch',
    's2_focus_7': 'Correct Habitats',
    's2_obs_1': 'Placed in cold environment.',
    's2_obs_2': 'Camel stumbles and slips.',
    's2_obs_3': 'Camel shivers.',
    's2_obs_4': 'Placed in hot environment.',
    's2_obs_5': 'Camel sinks into sand.',
    's2_obs_6': 'Camel overheats and pants.',
    's2_obs_7': 'Both camels thrive and walk easily.',
    's2_expl_1':
        'This camel has long legs and short fur, adapted for hot sand.',
    's2_expl_2':
        'Its long legs and wide hooves are specifically meant for walking on soft sand. They are unstable and slippery on steep, rocky mountain slopes.',
    's2_expl_3':
        'With its short fur, the hot desert camel has no insulation to protect its body heat against the freezing mountain winds.',
    's2_expl_4':
        'This camel has thick fur and shorter legs, adapted for cold mountains.',
    's2_expl_5':
        'Its shorter legs and smaller hooves do not distribute its weight well on soft sand, causing it to sink and making walking exhausting.',
    's2_expl_6':
        'Its thick, woolly fur traps body heat. In the hot desert sun, this adaptation becomes a disadvantage, causing severe overheating.',
    's2_expl_7':
        "Organisms survive best in habitats they are adapted to. The Hot Camel's wide hooves and short fur suit the sand and heat, while the Cold Camel's thick fur and short legs suit the cold and rocks.",
    's1_summary':
        "You've successfully matched plants to their habitats! The Deodar tree's conical shape helps it shed snow in mountains. The Cactus's fleshy stem stores water to survive the hot, dry desert.",
    's2_summary':
        'You solved the Camel Conundrum! Organisms are specifically adapted to their environments. A Hot Desert camel has wide hooves for sand and short fur. A Cold Desert camel (Bactrian) has thick fur for warmth and shorter legs for rocky terrain.',
    // Conclusion modal (HTML `classification_complete`, `explanation` and
    // the `triggerConclusion` summary texts).
    'sum_title': 'Habitat Solved!',
    'sum_heading': 'Explanation',
    'sum_vs': 'VS',
    'sum_deodar_feat': 'Conical shape sheds snow!',
    'sum_cactus_feat': 'Fleshy stem stores water!',
    'sum_hot_camel_feat': 'Long legs & wide hooves for sand',
    'sum_cold_camel_feat': 'Thick fur, short legs for mountains',
    // Action buttons (HTML `updateActionButton`, English only there).
    'btn_simulate_day': 'Simulate Day',
    'btn_reset_mountain': 'Reset & Try Mountain',
    'btn_simulate_snow': 'Simulate Snowfall',
    'btn_reset_cactus': 'Reset & Try Cactus',
    'btn_reset_desert': 'Reset & Try Desert',
    'btn_walk': 'Walk',
    'btn_cold_wind': 'Simulate Cold Wind',
    'btn_reset': 'Reset',
    'btn_hot_day': 'Simulate Hot Day',
    'btn_reset_match': 'Reset & Match Both',
    // The HTML button read 'Simulate'; named as the HUD line names it.
    'btn_simulate_env': 'Simulate Environment',
    'btn_review': 'Review Findings',
    // Scene labels (HTML `labelDict`; 'Inventory Tray' and 'Drop Here'
    // were English only).
    'lbl_hot_desert': 'Hot Desert',
    'lbl_cold_mountains': 'Cold Mountains',
    'lbl_cold_desert': 'Cold Desert',
    'lbl_deodar': 'Deodar Tree',
    'lbl_cactus': 'Cactus',
    'lbl_hot_camel': 'Hot Desert Camel',
    'lbl_cold_camel': 'Cold Desert Camel',
    'lbl_tray': 'Inventory Tray',
    'lbl_drop': 'Drop Here',
    // Status labels (HTML `showSyncLabel`, English only there).
    'sync_wilting': 'Wilting in Heat',
    'sync_shedding': 'Shedding Snow!',
    'sync_storing': 'Storing Water!',
    'sync_broken': 'Broken by Snow',
    'sync_struggling': 'Struggling!',
    'sync_sinking': 'Sinking!',
    'sync_cold': 'Too Cold!',
    'sync_hot': 'Overheating!',
    'sync_adapted': 'Adapted!',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Steps',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // Added.
    'pending': 'Do this step to see the result.',
    'not_yet': 'Not yet!',
    'missed': 'Missed!',
    'wrong_zone': 'Not that habitat!',
    'tap_first': "Tap '{btn}' first.",
    'go_s1_1':
        'In this step, drag the Deodar Tree into the Hot Desert (left side).',
    'go_s1_3':
        'In this step, drag the Deodar Tree into the Snowy Mountain (right side).',
    'go_s1_5':
        'In this step, drag the Cactus into the Snowy Mountain (right side).',
    'go_s1_7': 'In this step, drag the Cactus into the Hot Desert (left side).',
    'go_s2_1':
        'In this step, drag the Hot Desert Camel into the Cold Desert (right side).',
    'go_s2_4':
        'In this step, drag the Cold Desert Camel into the Hot Desert (left side).',
    'go_s2_7_hot': 'Drag the Hot Desert Camel into the Hot Desert (left side).',
    'go_s2_7_cold':
        'Drag the Cold Desert Camel into the Cold Desert (right side).',
    'scene_s1':
        'A hot desert with sand dunes on the left and a snowy mountain with rocks on the right, each with a drop zone, and an inventory tray holding a deodar tree and a cactus',
    'scene_s2':
        'A hot desert with sand dunes on the left and a cold, rocky desert on the right, each with a drop zone, and an inventory tray holding a one-humped hot desert camel and a two-humped cold desert camel',
  },
  'hi': {
    'app_title': 'आवास चुनौती: योग्यतम की उत्तरजीविता',
    'app_subtitle': 'कक्षा 6 • सजीव जगत में विविधता',
    'scen_1_opt': 'परिदृश्य 1: पौधों के स्थान की समस्या',
    'scen_2_opt': 'परिदृश्य 2: ऊंट की पहेली',
    's1_desc':
        'समझें कि कैक्टस और देवदार के पेड़ की शारीरिक संरचनाएं उनके रेगिस्तानी और पहाड़ी आवासों के अनुकूल कैसे हैं।',
    's2_desc':
        'गर्म रेगिस्तान के ऊंट और ठंडे रेगिस्तान के ऊंट को सही आवासों में रखकर उनके अनुकूलन की तुलना करें।',
    's1_step_1':
        'देवदार के पेड़ को इन्वेंट्री ट्रे से खींचें और गर्म रेगिस्तान (बाईं ओर) में छोड़ें।',
    's1_step_2':
        "पेड़ अत्यधिक गर्मी और धूप को कैसे संभालता है, यह देखने के लिए 'दिन का अनुकरण करें' पर टैप करें।",
    's1_step_3':
        "'रीसेट करें और पहाड़ आज़माएं' पर टैप करें, फिर देवदार के पेड़ को बर्फीले पहाड़ (दाईं ओर) में खींचें।",
    's1_step_4':
        "पेड़ का शंक्वाकार आकार उसे जीवित रहने में कैसे मदद करता है, यह देखने के लिए 'बर्फबारी का अनुकरण करें' पर टैप करें।",
    's1_step_5':
        "'रीसेट करें और कैक्टस आज़माएं' पर टैप करें, फिर कैक्टस को बर्फीले पहाड़ (दाईं ओर) में खींचें।",
    's1_step_6':
        "चपटे कैक्टस पैड का क्या होता है, यह देखने के लिए 'बर्फबारी का अनुकरण करें' पर टैप करें।",
    's1_step_7':
        "'रीसेट करें और रेगिस्तान आज़माएं' पर टैप करें, कैक्टस को गर्म रेगिस्तान (बाईं ओर) में उसके घर में खींचें, फिर 'दिन का अनुकरण करें' पर टैप करें।",
    's1_step_8':
        "पौधों के अनुकूलन का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    's2_step_1':
        'गर्म रेगिस्तान के ऊंट (एक कूबड़, लंबे पैर) को इन्वेंट्री ट्रे से ठंडे रेगिस्तान (दाईं ओर) में खींचें।',
    's2_step_2':
        "यह पथरीले इलाके में कैसे चलता है, यह देखने के लिए 'चलें' पर टैप करें।",
    's2_step_3':
        "इसकी तापमान सहनशीलता जाँचने के लिए 'ठंडी हवा का अनुकरण करें' पर टैप करें।",
    's2_step_4':
        "'रीसेट करें' पर टैप करें, फिर ठंडे रेगिस्तान के ऊंट (दो कूबड़, घने बाल) को गर्म रेगिस्तान (बाईं ओर) में खींचें।",
    's2_step_5':
        "यह गहरी रेत पर कैसे चलता है, यह देखने के लिए 'चलें' पर टैप करें।",
    's2_step_6':
        "यह गर्मी को कैसे संभालता है, यह देखने के लिए 'गर्म दिन का अनुकरण करें' पर टैप करें।",
    's2_step_7':
        "'रीसेट करें और दोनों का मिलान करें' पर टैप करें, गर्म रेगिस्तान के ऊंट को गर्म रेगिस्तान में और ठंडे रेगिस्तान के ऊंट को ठंडे रेगिस्तान में खींचें, फिर 'पर्यावरण का अनुकरण करें' पर टैप करें।",
    's2_step_8':
        "जानवरों के अनुकूलन का सारांश देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    's1_hud_1':
        'दोनों आवासों का निरीक्षण करें। देवदार के पेड़ को इन्वेंट्री से खींचें (DRAG) और गर्म रेगिस्तान (बाईं ओर) में छोड़ें (DROP)।',
    's1_hud_2':
        "यह देखने के लिए कि पेड़ अत्यधिक गर्मी और धूप को कैसे संभालता है, 'दिन का अनुकरण करें' पर टैप करें।",
    's1_hud_3':
        "पेड़ मुरझा गया! 'रीसेट करें और पहाड़ आज़माएं' पर टैप करें। फिर देवदार के पेड़ को बर्फीले पहाड़ (दाईं ओर) में खींचें।",
    's1_hud_4':
        "'बर्फबारी का अनुकरण करें' पर टैप करके देखें कि इसका शंक्वाकार आकार इसे कैसे जीवित रहने में मदद करता है।",
    's1_hud_5':
        "अब, कैक्टस का परीक्षण करते हैं। 'रीसेट करें और कैक्टस आज़माएं' पर टैप करें, फिर कैक्टस को खींचें और बर्फीले पहाड़ में छोड़ें।",
    's1_hud_6':
        "चपटे कैक्टस पैड का क्या होता है, यह देखने के लिए 'बर्फबारी का अनुकरण करें' पर टैप करें।",
    's1_hud_7':
        "कैक्टस टूट गया! 'रीसेट करें और रेगिस्तान आज़माएं' पर टैप करें। फिर कैक्टस को गर्म रेगिस्तान में उसके घर में खींचें। 'दिन का अनुकरण करें' पर टैप करें।",
    's1_hud_8':
        "पौधों के अनुकूलन को संक्षेप में प्रस्तुत करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        'आइए जानवरों के अनुकूलन का परीक्षण करें। गर्म रेगिस्तान के ऊंट (एक कूबड़, लंबे पैर) को ठंडे रेगिस्तान (दाईं ओर) में खींचें।',
    's2_hud_2':
        "यह देखने के लिए कि यह पथरीले इलाके में कैसे चलता है, 'चलें' पर टैप करें।",
    's2_hud_3':
        "यह लड़खड़ा रहा है! इसके तापमान सहनशीलता का परीक्षण करने के लिए 'ठंडी हवा का अनुकरण करें' पर टैप करें।",
    's2_hud_4':
        "यह कांप रहा है! 'रीसेट करें' पर टैप करें। अब, ठंडे रेगिस्तान के ऊंट (दो कूबड़, घने बाल) को गर्म रेगिस्तान (बाईं ओर) में खींचें।",
    's2_hud_5':
        "यह देखने के लिए कि यह गहरी रेत पर कैसे चलता है, 'चलें' पर टैप करें।",
    's2_hud_6':
        "यह डूब रहा है! यह देखने के लिए कि यह गर्मी को कैसे संभालता है, 'गर्म दिन का अनुकरण करें' पर टैप करें।",
    's2_hud_7':
        "यह बहुत अधिक गर्म हो रहा है! 'रीसेट करें और दोनों का मिलान करें' पर टैप करें। अब दोनों का सही मिलान करें: गर्म ऊंट गर्म रेगिस्तान में, ठंडा ऊंट ठंडे रेगिस्तान में। 'पर्यावरण का अनुकरण करें' पर टैप करें।",
    's2_hud_8':
        "जानवरों के अनुकूलन को संक्षेप में प्रस्तुत करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's1_focus_1': 'गलत आवास',
    's1_focus_2': 'गर्मी के लिए कोई अनुकूलन नहीं',
    's1_focus_3': 'सही आवास',
    's1_focus_4': 'बर्फ के लिए अनुकूलन',
    's1_focus_5': 'गलत आवास',
    's1_focus_6': 'बर्फ के लिए कोई अनुकूलन नहीं',
    's1_focus_7': 'गर्मी/सूखे के लिए अनुकूलन',
    's1_obs_1': 'रेगिस्तान में रखा गया।',
    's1_obs_2': 'पेड़ मुरझा जाता है और भूरा हो जाता है।',
    's1_obs_3': 'पहाड़ में रखा गया।',
    's1_obs_4': 'बर्फ फिसल जाती है; पेड़ पनपता है।',
    's1_obs_5': 'पहाड़ में रखा गया।',
    's1_obs_6': 'बर्फ जमा हो जाती है; कैक्टस टूट जाता है।',
    's1_obs_7': 'कैक्टस पनपता है और थोड़ा फूल जाता है।',
    's1_expl_1':
        'देवदार का पेड़ स्वाभाविक रूप से ठंडे पहाड़ों में उगता है। इसे गर्म रेगिस्तान में रखने से इसके जीवित रहने की क्षमता का परीक्षण होता है।',
    's1_expl_2':
        'देवदार के पेड़ में पानी जमा करने के लिए मांसल तने या अत्यधिक गर्मी को प्रतिबिंबित करने के लिए मोटे क्यूटिकल्स जैसे अनुकूलन का अभाव होता है, जिससे यह रेगिस्तान की धूप में तेजी से मुरझा जाता है।',
    's1_expl_3':
        'हम पेड़ को उसके प्राकृतिक आवास में वापस लाते हैं ताकि उसके प्राकृतिक अनुकूलन का निरीक्षण किया जा सके।',
    's1_expl_4':
        'इसका शंक्वाकार आकार और ढलान वाली शाखाएं विशिष्ट अनुकूलन हैं जो भारी बर्फ को आसानी से फिसलने देती हैं, जिससे शाखाएं टूटने से बचती हैं।',
    's1_expl_5':
        'कैक्टस गर्म, शुष्क जलवायु के अनुकूल है। इसे बर्फ में रखने से इसकी सीमाओं का परीक्षण होता है।',
    's1_expl_6':
        'कैक्टस की चौड़ी, चपटी सतहों पर भारी बर्फ जम जाती है। इसमें देवदार जैसे शंक्वाकार आकार का अभाव होता है, जिससे यह वजन के कारण टूट जाता है।',
    's1_expl_7':
        'रेगिस्तान में, इसका मांसल हरा तना पानी जमा करता है और प्रकाश संश्लेषण करता है, जो गर्म, शुष्क परिस्थितियों में जीवित रहने के लिए एकदम सही अनुकूलन हैं।',
    's2_focus_1': 'गलत आवास',
    's2_focus_2': 'गति बेमेल',
    's2_focus_3': 'तापमान बेमेल',
    's2_focus_4': 'गलत आवास',
    's2_focus_5': 'गति बेमेल',
    's2_focus_6': 'तापमान बेमेल',
    's2_focus_7': 'सही आवास',
    's2_obs_1': 'ठंडे वातावरण में रखा गया।',
    's2_obs_2': 'ऊंट लड़खड़ाता है और फिसलता है।',
    's2_obs_3': 'ऊंट कांपता है।',
    's2_obs_4': 'गर्म वातावरण में रखा गया।',
    's2_obs_5': 'ऊंट रेत में डूब जाता है।',
    's2_obs_6': 'ऊंट अधिक गर्म हो जाता है और हांफता है।',
    's2_obs_7': 'दोनों ऊंट पनपते हैं और आसानी से चलते हैं।',
    's2_expl_1':
        'इस ऊंट के लंबे पैर और छोटे बाल होते हैं, जो गर्म रेत के लिए अनुकूलित होते हैं।',
    's2_expl_2':
        'इसके लंबे पैर और चौड़े खुर विशेष रूप से नरम रेत पर चलने के लिए होते हैं। वे खड़ी, पथरीली पहाड़ी ढलानों पर अस्थिर और फिसलन भरे होते हैं।',
    's2_expl_3':
        'छोटे बालों के साथ, गर्म रेगिस्तान के ऊंट के पास ठंडी पहाड़ी हवाओं से अपने शरीर की गर्मी को बचाने के लिए कोई इन्सुलेशन नहीं होता है।',
    's2_expl_4':
        'इस ऊंट के घने बाल और छोटे पैर होते हैं, जो ठंडे पहाड़ों के लिए अनुकूलित होते हैं।',
    's2_expl_5':
        'इसके छोटे पैर और छोटे खुर नरम रेत पर इसका वजन अच्छी तरह से वितरित नहीं करते हैं, जिससे यह डूब जाता है और चलना थका देने वाला हो जाता है।',
    's2_expl_6':
        'इसके घने, ऊनी बाल शरीर की गर्मी को फँसाते हैं। गर्म रेगिस्तान की धूप में, यह अनुकूलन एक नुकसान बन जाता है, जिससे अत्यधिक गर्मी होती है।',
    's2_expl_7':
        'जीव उन आवासों में सबसे अच्छी तरह जीवित रहते हैं जिनके वे अनुकूल होते हैं। गर्म ऊंट के चौड़े खुर और छोटे बाल रेत और गर्मी के अनुकूल होते हैं, जबकि ठंडे ऊंट के घने बाल और छोटे पैर ठंड और चट्टानों के अनुकूल होते हैं।',
    's1_summary':
        'आपने पौधों को उनके आवासों से सफलतापूर्वक मिला दिया है! देवदार के पेड़ का शंक्वाकार आकार इसे पहाड़ों में बर्फ गिराने में मदद करता है। कैक्टस का मांसल तना गर्म, सूखे रेगिस्तान में जीवित रहने के लिए पानी जमा करता है।',
    's2_summary':
        'आपने ऊंट की पहेली सुलझा ली! जीव विशेष रूप से अपने वातावरण के अनुकूल होते हैं। एक गर्म रेगिस्तान के ऊंट के रेत के लिए चौड़े खुर और छोटे बाल होते हैं। ठंडे रेगिस्तान के ऊंट (बैक्ट्रियन) के पास गर्मी के लिए घने बाल और पथरीले इलाके के लिए छोटे पैर होते हैं।',
    'sum_title': 'आवास सुलझ गया!',
    'sum_heading': 'स्पष्टीकरण',
    'sum_vs': 'VS',
    'sum_deodar_feat': 'शंक्वाकार आकार बर्फ गिराता है!',
    'sum_cactus_feat': 'मांसल तना पानी जमा करता है!',
    'sum_hot_camel_feat': 'रेत के लिए लंबे पैर, एक कूबड़',
    'sum_cold_camel_feat': 'घने बाल, चट्टानों के लिए छोटे पैर',
    // Added: the HTML buttons were English only.
    'btn_simulate_day': 'दिन का अनुकरण करें',
    'btn_reset_mountain': 'रीसेट करें और पहाड़ आज़माएं',
    'btn_simulate_snow': 'बर्फबारी का अनुकरण करें',
    'btn_reset_cactus': 'रीसेट करें और कैक्टस आज़माएं',
    'btn_reset_desert': 'रीसेट करें और रेगिस्तान आज़माएं',
    'btn_walk': 'चलें',
    'btn_cold_wind': 'ठंडी हवा का अनुकरण करें',
    'btn_reset': 'रीसेट करें',
    'btn_hot_day': 'गर्म दिन का अनुकरण करें',
    'btn_reset_match': 'रीसेट करें और दोनों का मिलान करें',
    'btn_simulate_env': 'पर्यावरण का अनुकरण करें',
    'btn_review': 'निष्कर्ष की समीक्षा करें',
    'lbl_hot_desert': 'गर्म रेगिस्तान',
    'lbl_cold_mountains': 'ठंडे पहाड़',
    'lbl_cold_desert': 'ठंडा रेगिस्तान',
    'lbl_deodar': 'देवदार का पेड़',
    'lbl_cactus': 'कैक्टस',
    'lbl_hot_camel': 'गर्म रेगिस्तान का ऊंट',
    'lbl_cold_camel': 'ठंडे रेगिस्तान का ऊंट',
    // Added: English only in the HTML.
    'lbl_tray': 'इन्वेंट्री ट्रे',
    'lbl_drop': 'यहाँ छोड़ें',
    'sync_wilting': 'गर्मी में मुरझा रहा है',
    'sync_shedding': 'बर्फ गिरा रहा है!',
    'sync_storing': 'पानी जमा कर रहा है!',
    'sync_broken': 'बर्फ से टूट गया',
    'sync_struggling': 'संघर्ष कर रहा है!',
    'sync_sinking': 'डूब रहा है!',
    'sync_cold': 'बहुत ठंड!',
    'sync_hot': 'बहुत गर्म हो रहा है!',
    'sync_adapted': 'अनुकूलित!',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    // Added.
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'not_yet': 'अभी नहीं!',
    'missed': 'निशाना चूक गया!',
    'wrong_zone': 'यह वह आवास नहीं है!',
    'tap_first': "पहले '{btn}' पर टैप करें।",
    'go_s1_1':
        'इस चरण में देवदार के पेड़ को गर्म रेगिस्तान (बाईं ओर) में खींचें।',
    'go_s1_3':
        'इस चरण में देवदार के पेड़ को बर्फीले पहाड़ (दाईं ओर) में खींचें।',
    'go_s1_5': 'इस चरण में कैक्टस को बर्फीले पहाड़ (दाईं ओर) में खींचें।',
    'go_s1_7': 'इस चरण में कैक्टस को गर्म रेगिस्तान (बाईं ओर) में खींचें।',
    'go_s2_1':
        'इस चरण में गर्म रेगिस्तान के ऊंट को ठंडे रेगिस्तान (दाईं ओर) में खींचें।',
    'go_s2_4':
        'इस चरण में ठंडे रेगिस्तान के ऊंट को गर्म रेगिस्तान (बाईं ओर) में खींचें।',
    'go_s2_7_hot':
        'गर्म रेगिस्तान के ऊंट को गर्म रेगिस्तान (बाईं ओर) में खींचें।',
    'go_s2_7_cold':
        'ठंडे रेगिस्तान के ऊंट को ठंडे रेगिस्तान (दाईं ओर) में खींचें।',
    'scene_s1':
        'बाईं ओर रेत के टीलों वाला गर्म रेगिस्तान और दाईं ओर चट्टानों वाला बर्फीला पहाड़, दोनों में छोड़ने का स्थान, और देवदार के पेड़ व कैक्टस वाली इन्वेंट्री ट्रे',
    'scene_s2':
        'बाईं ओर रेत के टीलों वाला गर्म रेगिस्तान और दाईं ओर ठंडा, पथरीला रेगिस्तान, दोनों में छोड़ने का स्थान, और एक कूबड़ वाले गर्म रेगिस्तान के ऊंट व दो कूबड़ वाले ठंडे रेगिस्तान के ऊंट वाली इन्वेंट्री ट्रे',
  },
};

/// Number of steps of each scenario: the HTML's seven steps plus its eighth
/// HUD task ('Review Findings').
const List<int> _stepCounts = [8, 8];

/// Steps of each scenario with an HTML step card (the `steps` arrays).
const int _labSteps = 7;

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
        focus: i <= _labSteps ? t('s${n}_focus_$i') : '',
        action: t('s${n}_step_$i'),
        result: i <= _labSteps ? t('s${n}_obs_$i') : '',
        explanation: i <= _labSteps ? t('s${n}_expl_$i') : '',
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The step
/// concept stays empty: the HTML concepts ("No Adaptation for Heat") are
/// results, shown in the accordion once each step is done.
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

/// HTML camera: `PerspectiveCamera(45, …)`, `camera.position.set(0, 20,
/// 32)` looking at `controls.target.set(0, 0, 0)` (`resetCamera`).
const double _fovDegrees = 45;
const _V _eye = _V(0, 20, 32);
const _V _lookAt = _V.zero;
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a plant or camel (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Chip padding as a share of the label size.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

/// Sun / frost icons (HTML `#icon-sun`, `#icon-freeze`, 80 px) and the
/// status face disc (`#label-emoji`, 48 px), in label sizes.
const double _iconScale = 2.2;
const double _discScale = 1.45;

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
const List<double> _maxZoom = [1.2, 1.2];
const double _minZoom = 0.3;

// ------------------------------------------------------------- the world

/// Ground planes: sand (x < 0) and snow (x > 0), `PlaneGeometry(1000,
/// 1000)` each; drawn out to the horizon.
const double _groundWide = 10000;
const double _groundFar = 3000;
const double _groundNear = 26;

/// `createDropZone`: `RingGeometry(3.5, 4)` at (±10, 0.15, 0), with a
/// dashed circle (dash 0.5, gap 0.5) and a 'Drop Here' sprite in front.
const double _zoneX = 10;
const double _ringInner = 3.5;
const double _ringOuter = 4;
const double _ringY = 0.15;
const double _dashLength = 0.5;
const double _dropChipZ = 4.4;

/// HTML `handleUp`: `isLeft = x < -3`, `isRight = x > 3`.
const double _sideLimit = 3;

/// Zone sprites 'Hot Desert' at (-8, 3, -8), 'Cold Mountains' / 'Cold
/// Desert' at (8, 3, -8).
const _V _zoneLabelHot = _V(-8, 3, -8);
const _V _zoneLabelCold = _V(8, 3, -8);

/// Dunes (`SphereGeometry(15)` scaled (1, 0.2, 0.8) at (-25, -0.5, -20),
/// `SphereGeometry(10)` scaled (0.8, 0.3, 1) at (-15, -0.2, -5)) and rocks
/// (`DodecahedronGeometry(8)` at (25, 2, -20), `(6)` at (15, 1, -15)).
const List<(_V, _V)> _dunes = [
  (_V(-25, -0.5, -20), _V(15, 3, 12)),
  (_V(-15, -0.2, -5), _V(8, 3, 10)),
];
const List<(_V, double)> _rocks = [(_V(25, 2, -20), 8), (_V(15, 1, -15), 6)];
const int _duneSlices = 8;

/// Inventory tray `CylinderGeometry(4.5, 4.5, 0.3)` at (0, 0.15, 12) and
/// its `TorusGeometry(4.6, 0.05)` ring at y 0.3. Its sprite sits at the
/// tray's left edge here (the HTML put it across the tray, over the
/// plants).
const double _trayZ = 12;
const double _trayRadius = 4.5;
const double _trayTop = 0.3;
const double _trayRingRadius = 4.6;
const double _trayRingTube = 0.05;
const _V _trayLabelAt = _V(-4.7, 0.15, _trayZ);

/// `userData.initPos`: (-2, ·, 12) and (2, ·, 12) on the tray.
const double _homeX = 2;

/// HTML drag: the ray meets `dragPlane` (y = 0.5); here the held figure
/// floats above the tray, and it can be dragged over the visible ground.
const double _dragPlaneY = 0.5;
const double _heldY = 0.9;
const double _dragLimitX = 40;
const double _dragMinZ = -30;
const double _dragMaxZ = 20;

/// HTML `new TWEEN.Tween(obj.position).to(initPos, 300)`: a drop between
/// the habitats glides back to the tray.
const double _returnSeconds = 0.3;

/// HTML `setTimeout`s before the next step: 2000 ms (Scenario 1), 1500 ms
/// (Scenario 2), 2500 ms (both camels adapted).
const double _settleS1 = 2;
const double _settleS2 = 1.5;
const double _settleBoth = 2.5;

/// HTML tweens: wilt, colour, thrive, break and overheat run 1000 ms.
const double _tweenSeconds = 1;

/// `showSyncLabel`: shown for 3000 ms, `transition: opacity 0.3s`.
const double _syncSeconds = 3;
const double _syncFade = 0.3;

/// `animWalkSlip`: z → 8 (400 ms), a stumble (rotation.z → 0.3, yoyo,
/// 2 × 200 ms), z → 6 (400 ms).
const double _slipZ1 = 8;
const double _slipZ2 = 6;
const double _stepSeconds = 0.4;
const double _stumbleTilt = 0.3;

/// `animShiver`: rotation.y → 0.2 in 50 ms, yoyo, repeated 20 times.
const double _shiverYaw = 0.2;
const double _shiverHalf = 0.05;
const int _shiverSwings = 21;

/// `animWalkSink`: y 0.5 → -0.2 (0.7 into the sand) and z → 8 over 1 s.
const double _sinkDepth = 0.7;
const double _sinkZ = 8;

/// Both camels adapted: z → 5 over 2000 ms.
const double _finalZ = 5;
const double _finalWalk = 2;

/// Walking (HTML `animate()`): legs swing `sin(time * 10 + i) * 0.4`, the
/// head nods `sin(time * 5) * 0.1`; HTML `time` grows 0.05 a frame (3 / s
/// at 60 fps).
const double _htmlTimeRate = 3;
const double _legSwing = 0.4;
const double _headNod = 0.1;

/// `animBreakCactus`: the arms swing to π/2 (Bounce.Out) as the cactus
/// turns brown. Added: the snow settles on its pads first.
const double _capSeconds = 0.5;
const double _breakDelay = 0.5;
const double _armFloor = 0.08;

/// `animThrive` (cactus): scale (1.1, 1.05, 1.1), Elastic.Out. `animWilt`:
/// scale (0.9, 0.7, 0.9), Cubic.InOut; cones rotate to (0.2, ·, 0.1).
/// `animOverheat`: scale (1.05, 0.9, 1.05).
const _V _thriveScale = _V(1.1, 1.05, 1.1);
const _V _wiltScale = _V(0.9, 0.7, 0.9);
const _V _overheatScale = _V(1.05, 0.9, 1.05);
const double _wiltTiltX = 0.2;
const double _wiltTiltZ = 0.1;

/// Added: snow slides off the deodar's cones.
const double _shedSeconds = 1.8;

/// `createSnowEffect`: 50 flakes over the snowy half, falls of 1–3 s after
/// up to 1 s; hidden after 3 s.
const int _flakeCount = 50;
const double _snowSeconds = 3;

/// Added: wind streaks for the cold wind; the sun and frost icons glow
/// while their weather plays.
const double _windSeconds = 1.4;
const int _windStreaks = 7;
const double _glowSeconds = 2;

/// `#icon-sun` spins once in 10 s; `#icon-freeze` pulses (2 s).
const double _sunSpinSeconds = 10;
const double _pulseSeconds = 2;

/// The sun and frost icons (HTML 2D overlays at the top corners), anchored
/// above each habitat so they move with the fitted scene.
const _V _sunAt = _V(-18, 4, -10);
const _V _frostAt = _V(18, 4, -10);

/// Samples per circle (rims, rings): one every 2.5 screen px, 12–96.
const double _pxPerStep = 2.5;
const int _minSteps = 12;
const int _maxSteps = 96;

// ------------------------------------------------------------- labels

/// How a chip sits on its anchor (x, y alignment: -1 left / top edge, 0
/// centre, 1 right / bottom edge).
const (double, double) _below = (0, -1);
const (double, double) _above = (0, 1);
const (double, double) _leftOf = (1, 0);
const (double, double) _centered = (0, 0);

// -------------------------------------------------------------- lighting

/// HTML `AmbientLight(0xffffff, 0.4)` plus the scenario's
/// `DirectionalLight(…, 0.8)`.
const double _ambient = 0.4;
const double _diffuse = 0.8;

/// A directional light: unit direction towards it and its colour.
@immutable
class _Lamp {
  const _Lamp(this.dir, this.r, this.g, this.b);

  final _V dir;
  final double r;
  final double g;
  final double b;
}

/// S1 `DirectionalLight(0xfff5b6)` at (-15, 20, 10); S2
/// `DirectionalLight(0xffeedd)` at (0, 20, 10).
const _Lamp _lampS1 = _Lamp(_V(-0.5571, 0.7428, 0.3714), 1, 0.961, 0.714);
const _Lamp _lampS2 = _Lamp(_V(0, 0.8944, 0.4472), 1, 0.933, 0.867);

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
  static const _V right = _V(1, 0, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// Component-wise product (Three.js `scale`).
  _V scaled(_V k) => _V(x * k.x, y * k.y, z * k.z);

  /// Rotations about the x, y and z axes (Three.js Euler XYZ applies z,
  /// then y, then x).
  _V rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x, y * c - z * s, y * s + z * c);
  }

  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

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

/// The four organisms (HTML `createDeodarTree`, `createCactus`,
/// `createCamel('hot' | 'cold')`): label key and local bounds (x range,
/// height, half depth) around the group origin on the ground.
enum _Kind {
  deodar('lbl_deodar', -1, 1, 3.6, 1),
  cactus('lbl_cactus', -0.95, 0.95, 2.05, 0.4),
  hotCamel('lbl_hot_camel', -0.95, 1.7, 2.85, 0.6),
  coldCamel('lbl_cold_camel', -0.95, 1.7, 2.5, 0.66);

  const _Kind(this.labelKey, this.minX, this.maxX, this.height, this.halfZ);

  final String labelKey;
  final double minX;
  final double maxX;
  final double height;
  final double halfZ;

  _V get boxMin => _V(minX, 0, -halfZ);
  _V get boxMax => _V(maxX, height, halfZ);
  bool get isCamel => this == hotCamel || this == coldCamel;

  /// Summary feature line (HTML `triggerConclusion` texts).
  String get featureKey => switch (this) {
    deodar => 'sum_deodar_feat',
    cactus => 'sum_cactus_feat',
    hotCamel => 'sum_hot_camel_feat',
    coldCamel => 'sum_cold_camel_feat',
  };
}

/// The organisms of scenario [index], in tray order (left, right).
List<_Kind> _kindsOf(int index) => index == 0
    ? const [_Kind.deodar, _Kind.cactus]
    : const [_Kind.hotCamel, _Kind.coldCamel];

/// Where an organism was dropped (HTML `placedLoc`): the hot desert on the
/// left or the snowy mountain / cold desert on the right.
enum _Side { desert, mountain }

/// The face on a status label (HTML `showSyncLabel` emoji ☹️ 😄 🥶 🥵).
enum _Mood { sad, happy, cold, hot }

/// Linear 0 → 1 ramp of an effect that started at [start] (or 0 if it has
/// not started).
double _ramp(double time, double start, double seconds) =>
    start < 0 ? 0 : ((time - start) / seconds).clamp(0.0, 1.0);

/// One plant or camel (HTML scene group with its tweens).
class _Organism {
  _Organism(this.kind, this.home) : pos = home;

  final _Kind kind;

  /// `userData.initPos` on the tray (a ground point).
  final _V home;

  /// Where it rests or is heading: a ground point whose y is how far it
  /// sank into the sand. While it moves it glides from [_moveFrom].
  _V pos;
  _V _moveFrom = _V.zero;
  double _moveStart = -1;
  double _moveSeconds = 0;

  /// `visible` (the deodar is hidden after 'Reset & Try Cactus').
  bool visible = true;

  /// HTML `placedLoc`.
  _Side? side;

  _V _scaleFrom = _V.one;
  _V _scaleTo = _V.one;
  double _scaleStart = -1;
  double _scaleSeconds = 1;
  Curve _scaleCurve = Curves.linear;

  /// Start times of the effects (-1: not running).
  double brownStart = -1;
  double armsStart = -1;
  double capsStart = -1;
  double shedStart = -1;
  double rollStart = -1;
  double shiverStart = -1;
  double walkStart = -1;
  double walkEnd = -1;

  /// Status label (HTML `showSyncLabel`).
  String? syncKey;
  _Mood syncMood = _Mood.sad;
  double syncStart = -1;

  /// Puts it at [p] at once (dragging, a reset).
  void place(_V p) {
    pos = p;
    _moveStart = -1;
  }

  /// Glides it to [to] over [seconds] (HTML position tweens).
  void moveTo(double time, _V to, double seconds) {
    _moveFrom = posAt(time);
    pos = to;
    _moveStart = time;
    _moveSeconds = seconds;
  }

  /// Where it is at [time].
  _V posAt(double time) {
    if (_moveStart < 0) return pos;
    final e = _ramp(time, _moveStart, _moveSeconds);
    return e >= 1 ? pos : _V.lerp(_moveFrom, pos, e);
  }

  /// Tweens `scale` to [to] (HTML `animWilt`, `animThrive`, `animOverheat`).
  void scaleTo(double time, _V to, double seconds, Curve curve) {
    _scaleFrom = scaleAt(time);
    _scaleTo = to;
    _scaleStart = time;
    _scaleSeconds = seconds;
    _scaleCurve = curve;
  }

  _V scaleAt(double time) {
    if (_scaleStart < 0) return _scaleTo;
    final e = _ramp(time, _scaleStart, _scaleSeconds);
    return _V.lerp(_scaleFrom, _scaleTo, _scaleCurve.transform(e));
  }

  /// Green → brown (`0x8b4513`) over 1 s.
  double brownAt(double time) => _ramp(time, brownStart, _tweenSeconds);

  /// The cactus arms' rotation.z (0 → π/2, Bounce.Out).
  double armsAt(double time) =>
      math.pi /
      2 *
      Curves.bounceOut.transform(_ramp(time, armsStart, _tweenSeconds));

  /// Snow on the cactus pads (0 → 1).
  double capsAt(double time) => _ramp(time, capsStart, _capSeconds);

  /// Snow sliding off the deodar (0 → 1), or -1 when not running.
  double shedAt(double time) =>
      shedStart < 0 ? -1 : _ramp(time, shedStart, _shedSeconds);

  /// Stumble tilt (rotation.z, 0 → 0.3 → 0).
  double rollAt(double time) {
    if (rollStart < 0) return 0;
    final e = (time - rollStart) / _stepSeconds;
    if (e <= 0 || e >= 1) return 0;
    return _stumbleTilt * (e < 0.5 ? 2 * e : 2 * (1 - e));
  }

  /// Shiver (rotation.y): 0 → 0.2 and back every 50 ms, 21 legs; it ends
  /// turned (0.2) like the HTML yoyo with an even repeat count.
  double yawAt(double time) {
    if (shiverStart < 0) return 0;
    final local = time - shiverStart;
    if (local <= 0) return 0;
    if (local >= _shiverHalf * _shiverSwings) return _shiverYaw;
    final phase = local / _shiverHalf;
    final leg = phase.floor();
    final frac = phase - leg;
    return _shiverYaw * (leg.isEven ? frac : 1 - frac);
  }

  /// HTML `userData.isWalking`.
  bool walkingAt(double time) =>
      walkStart >= 0 && time >= walkStart && time < walkEnd;

  void walk(double time, double seconds) {
    walkStart = time;
    walkEnd = time + seconds;
  }

  /// Shows a status label (HTML `showSyncLabel(obj, emoji, text, type)`).
  void sync(double time, String key, _Mood mood) {
    syncKey = key;
    syncMood = mood;
    syncStart = time;
  }

  /// Opacity of the status label (shown 3 s, fading 0.3 s).
  double syncAlpha(double time) {
    if (syncStart < 0 || syncKey == null) return 0;
    final local = time - syncStart;
    if (local < 0 || local >= _syncSeconds) return 0;
    return math.min(local, _syncSeconds - local).clamp(0.0, _syncFade) /
        _syncFade;
  }

  /// Back on the tray, unharmed (HTML `resetScenarioState` and the
  /// 'Reset …' buttons).
  void reset() {
    place(home);
    visible = true;
    side = null;
    _scaleFrom = _V.one;
    _scaleTo = _V.one;
    _scaleStart = -1;
    brownStart = -1;
    armsStart = -1;
    capsStart = -1;
    shedStart = -1;
    rollStart = -1;
    shiverStart = -1;
    walkStart = -1;
    walkEnd = -1;
    syncKey = null;
    syncStart = -1;
  }
}

/// One snowflake of `createSnowEffect`.
@immutable
class _Flake {
  const _Flake(this.x, this.delay, this.seconds);

  /// Across the snowy half, 0 … 1 (`50 + Math.random() * 50` vw).
  final double x;

  /// `animationDelay` (`Math.random() * 1` s).
  final double delay;

  /// `animationDuration` (`1 + Math.random() * 2` s).
  final double seconds;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// The scenario's two organisms, in tray order.
  final List<_Organism> organisms = [];

  /// The organism the learner is holding (HTML `State.draggingObject`).
  _Organism? held;

  /// Pending events of the running simulation, in scene time (the HTML
  /// tween `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  final math.Random _random = math.Random();

  // -------------------------------------------------------------- progress
  /// Steps finished (HTML `progressStep` calls), 0 … 7.
  int done = 0;

  /// A simulation is running (the HTML hides the action button).
  bool busy = false;

  /// The step's 'Reset …' button was tapped.
  bool resetDone = false;

  /// Step 7: the cactus / both camels are home, so 'Simulate Day' /
  /// 'Simulate Environment' shows.
  bool simulateReady = false;

  /// 'Review Findings' was tapped.
  bool reviewed = false;

  // --------------------------------------------------------------- weather
  /// `createSnowEffect` start, or -1.
  double snowStart = -1;
  final List<_Flake> flakes = [];

  /// Cold wind (added streaks) and hot sun (added glow) starts, or -1.
  double windStart = -1;
  double heatStart = -1;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column) and the visible canvas in design coordinates.
  double labelLeft = 0;
  double labelRight = _design.width;
  Rect view = _stageRect;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// The scenario's light.
  _Lamp get lamp => scenario == 0 ? _lampS1 : _lampS2;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    final kinds = _kindsOf(index);
    organisms
      ..clear()
      ..addAll([
        for (var i = 0; i < kinds.length; i++)
          _Organism(kinds[i], _V(i == 0 ? -_homeX : _homeX, 0, _trayZ)),
      ]);
    held = null;
    _cues.clear();
    done = 0;
    busy = false;
    resetDone = false;
    simulateReady = false;
    reviewed = false;
    snowStart = -1;
    flakes.clear();
    windStart = -1;
    heatStart = -1;
  }

  _Organism of(_Kind kind) => organisms.firstWhere((o) => o.kind == kind);

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

  /// HTML `createSnowEffect()`.
  void startSnow() {
    snowStart = time;
    flakes
      ..clear()
      ..addAll([
        for (var i = 0; i < _flakeCount; i++)
          _Flake(
            _random.nextDouble(),
            _random.nextDouble(),
            1 + _random.nextDouble() * 2,
          ),
      ]);
  }

  /// HTML `animate()`: the tweens are read from the clock; only the framing
  /// slides here.
  void advance(double dt) {
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

  /// Height of the ground at [p]: the tray top (blended over its rim so a
  /// gliding figure does not jump) or the ground.
  double surfaceAt(_V p) {
    final dx = p.x, dz = p.z - _trayZ;
    final d = math.sqrt(dx * dx + dz * dz);
    return _trayTop * ((_trayRadius + 0.3 - d) / 0.6).clamp(0.0, 1.0);
  }

  /// Where [o]'s group origin is drawn: on the ground or tray, sunk into
  /// the sand, or lifted while held.
  _V baseOf(_Organism o) {
    final p = o.posAt(time);
    if (identical(o, held)) return _V(p.x, _heldY, p.z);
    return _V(p.x, surfaceAt(p) + p.y, p.z);
  }

  /// The ground under [o] (its contact shadow; the sand it sinks into).
  double groundOf(_Organism o) => surfaceAt(o.posAt(time));

  /// The organism at [p] (HTML raycast on the groups' hit boxes): its box
  /// as drawn or, on a small screen, within a finger's reach of it.
  _Organism? organismAt(Offset p, double touch) {
    final cam = camera();
    _Organism? best;
    var bestRank = double.infinity;
    for (final o in organisms) {
      if (!o.visible) continue;
      final b = baseOf(o);
      final sc = o.scaleAt(time);
      final r = cam.boxRect(
        b + o.kind.boxMin.scaled(sc),
        b + o.kind.boxMax.scaled(sc),
      );
      final dx = math.max(0.0, math.max(r.left - p.dx, p.dx - r.right));
      final dy = math.max(0.0, math.max(r.top - p.dy, p.dy - r.bottom));
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > touch) continue;
      final rank = d + (p - r.center).distance * 0.01;
      if (rank < bestRank) {
        best = o;
        bestRank = rank;
      }
    }
    return best;
  }
}

/// What the framing keeps in view: a point of the base projection (the
/// HTML camera at zoom 1) and a rect around it that does not scale with the
/// zoom (a label chip or icon; empty for a point of an object).
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

/// Anchor of an organism's name chip: just above its top.
_V _nameAt(_Organism o, _V base, _V scale) =>
    base + _V(0, (o.kind.height + 0.15) * scale.y, 0);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a plant or camel ([canGrab]), so other drags still pan / zoom the
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

class _HabitatLabState
    extends State<Ch2A6UnderstandingAdaptationsAndHabitatsOfLivingOrganismsPage>
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
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a6-canvas');

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

  /// The organism the current pointer holds, the scenario it was picked up
  /// in and the drag-plane offset of the grab.
  _Organism? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;

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

  /// Fits the habitats, tray, organisms, icons and labels into the part of
  /// the canvas no card covers: the tool column, the HUD (sidebar open) and
  /// the floating mission card (sidebar collapsed). Never while a plant or
  /// camel is held, so the scene does not move under the finger.
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
      ..labelRight = (size.width - insets.right - stage.dx) / fit
      ..view = toDesign(Offset.zero & size);
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

  /// What the learner must see: both habitats with their rings and
  /// sprites, the tray with its organisms, a tall organism standing in each
  /// habitat, the sun and frost icons (HTML camera, zoom 1) and the label
  /// chips at their painted size.
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

    void chip(_V at, (double, double) align, String text) {
      final size = _cache.chipSize(text);
      items.add((cam.p(at), _chipOffset(size, align) & size));
    }

    final sc = _scene.scenario;
    for (final x in const [-_zoneX, _zoneX]) {
      box(
        _V(x - _ringOuter, 0, -_ringOuter),
        _V(x + _ringOuter, _ringY, _ringOuter),
      );
      box(_V(x - 1, 0, -1), _V(x + 1, _Kind.deodar.height + 0.5, 1));
      chip(_V(x, 0, _dropChipZ), _below, _t('lbl_drop'));
    }
    chip(_zoneLabelHot, _centered, _t('lbl_hot_desert'));
    chip(
      _zoneLabelCold,
      _centered,
      _t(sc == 0 ? 'lbl_cold_mountains' : 'lbl_cold_desert'),
    );
    box(
      const _V(-_trayRingRadius, 0, _trayZ - _trayRingRadius),
      const _V(_trayRingRadius, _trayTop, _trayZ + _trayRingRadius),
    );
    chip(_trayLabelAt, _leftOf, _t('lbl_tray'));
    final kinds = _kindsOf(sc);
    for (var i = 0; i < kinds.length; i++) {
      final k = kinds[i];
      final home = _V(i == 0 ? -_homeX : _homeX, _trayTop, _trayZ);
      box(home + k.boxMin, home + k.boxMax);
      chip(home + _V(0, k.height + 0.15, 0), _above, _t(k.labelKey));
    }
    final icon = _iconScale * _labelSize;
    for (final at in const [_sunAt, _frostAt]) {
      items.add((
        cam.p(at),
        Rect.fromCircle(center: Offset.zero, radius: icon),
      ));
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

  /// The HTML step ladder: steps 1–7 end with each `progressStep` call,
  /// step 8 when 'Review Findings' is tapped.
  int _deriveStep() {
    final s = _scene;
    if (s.reviewed) return _stepCounts[s.scenario] + 1;
    return s.done + 1;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
  }

  /// Where the current step lets [o] go (HTML `handleDown` active objects
  /// and the `handleUp` tests), or null if it may not move now.
  _Side? _targetFor(_Organism o) => switch ((_scene.scenario, _step, o.kind)) {
    (0, 1, _Kind.deodar) => _Side.desert,
    (0, 3, _Kind.deodar) => _Side.mountain,
    (0, 5, _Kind.cactus) => _Side.mountain,
    (0, 7, _Kind.cactus) => _Side.desert,
    (1, 1, _Kind.hotCamel) => _Side.mountain,
    (1, 4, _Kind.coldCamel) => _Side.desert,
    (1, 7, _Kind.hotCamel) => _Side.desert,
    (1, 7, _Kind.coldCamel) => _Side.mountain,
    _ => null,
  };

  /// The step's 'Reset …' button (HTML `updateActionButton` after each
  /// mismatch), tapped before the next drag.
  String? get _resetKey => switch ((_scene.scenario, _step)) {
    (0, 3) => 'btn_reset_mountain',
    (0, 5) => 'btn_reset_cactus',
    (0, 7) => 'btn_reset_desert',
    (1, 4) => 'btn_reset',
    (1, 7) => 'btn_reset_match',
    _ => null,
  };

  /// The step's simulation button (HTML `executeStepAction`).
  String? get _runKey => switch ((_scene.scenario, _step)) {
    (0, 2) || (0, 7) => 'btn_simulate_day',
    (0, 4) || (0, 6) => 'btn_simulate_snow',
    (1, 2) || (1, 5) => 'btn_walk',
    (1, 3) => 'btn_cold_wind',
    (1, 6) => 'btn_hot_day',
    (1, 7) => 'btn_simulate_env',
    _ => null,
  };

  IconData _runIcon(String key) => switch (key) {
    'btn_simulate_snow' => Icons.ac_unit,
    'btn_walk' => Icons.directions_walk,
    'btn_cold_wind' => Icons.air,
    'btn_simulate_env' => Icons.play_arrow,
    _ => Icons.wb_sunny,
  };

  /// What the current drag step asks for (added hint texts); in step 7 of
  /// Scenario 2, for [o] or the camel still on the tray.
  String _goKey(_Organism? o) {
    final s = _scene;
    if (s.scenario == 1 && _step == _labSteps) {
      final camel =
          o ??
          s.organisms.firstWhere(
            (c) => c.side != _targetFor(c),
            orElse: () => s.organisms.first,
          );
      return camel.kind == _Kind.hotCamel ? 'go_s2_7_hot' : 'go_s2_7_cold';
    }
    return 'go_s${s.scenario + 1}_$_step';
  }

  String _tapFirst(String buttonKey) =>
      labFormat(_t('tap_first'), {'btn': _t(buttonKey)});

  /// Why [o] cannot be picked up now (added: the HTML ignored the press),
  /// or null if it can.
  String? _blockedHint(_Organism o) {
    final s = _scene;
    if (s.done >= _labSteps) return _tapFirst('btn_review');
    final reset = _resetKey;
    if (reset != null && !s.resetDone) return _tapFirst(reset);
    final target = _targetFor(o);
    if (target != null && o.side != target) return null;
    final run = _runKey;
    if (run != null && (_step != _labSteps || s.simulateReady)) {
      return _tapFirst(run);
    }
    return '${_t('not_yet')} ${_t(_goKey(null))}';
  }

  /// HTML `handleUp` success branches: the organism stays where it was
  /// dropped and the step moves on (in step 7, the simulation button shows
  /// once everything is home).
  void _place(_Organism o, _Side side) {
    final s = _scene;
    o.side = side;
    _Sound.correct.play();
    if (_step == _labSteps) {
      s.simulateReady = s.organisms.every((x) => x.side == _targetFor(x));
    } else {
      s
        ..done += 1
        ..resetDone = false;
    }
    _refresh();
    _scheduleFraming();
  }

  /// HTML `progressStep()`; after the seventh step,
  /// `triggerConclusionState` shows 'Review Findings' with a chime.
  void _finishStep() {
    final s = _scene;
    s
      ..busy = false
      ..done += 1
      ..resetDone = false
      ..simulateReady = false;
    if (s.done == _labSteps) _Sound.success.play();
    _refresh();
  }

  /// The step's 'Reset …' button. The HTML returned the organism to the
  /// tray by itself when the simulation ended and the button only moved on;
  /// here the wilted, broken or tired organism stays in view until the
  /// learner resets it.
  void _reset() {
    final s = _scene;
    switch ((s.scenario, _step)) {
      case (0, 3):
        s.of(_Kind.deodar).reset();
      case (0, 5):
        // HTML: the deodar goes back to the shelf and is hidden.
        s.of(_Kind.deodar)
          ..reset()
          ..visible = false;
      case (0, 7):
        s.of(_Kind.cactus).reset();
      case (1, 4):
        s.of(_Kind.hotCamel).reset();
      case (1, 7):
        s.of(_Kind.coldCamel).reset();
    }
    s.resetDone = true;
    _refresh();
    _scheduleFraming();
  }

  /// HTML `executeStepAction()`.
  void _run() {
    final s = _scene;
    if (s.busy) return;
    final t = s.time;
    s.busy = true;
    switch ((s.scenario, _step)) {
      case (0, 2):
        _wilt(t);
      case (0, 4):
        _shedSnow(t);
      case (0, 6):
        _breakCactus(t);
      case (0, 7):
        _thrive(t);
      case (1, 2):
        _stumble(t);
      case (1, 3):
        _shiver(t);
      case (1, 5):
        _sink(t);
      case (1, 6):
        _overheat(t);
      case (1, 7):
        _adapted(t);
      default:
        s.busy = false;
    }
    _refresh();
  }

  /// 'Simulate Day' on the deodar in the desert (`animWilt`): it sags,
  /// browns and droops.
  void _wilt(double t) {
    final s = _scene;
    s.of(_Kind.deodar)
      ..scaleTo(t, _wiltScale, _tweenSeconds, Curves.easeInOutCubic)
      ..brownStart = t
      ..sync(t, 'sync_wilting', _Mood.sad);
    s.heatStart = t;
    _Sound.wrong.play();
    s.cue(t + _settleS1, _finishStep);
  }

  /// 'Simulate Snowfall' on the deodar in the mountain (`animThrive`);
  /// added: the snow slides off its cones.
  void _shedSnow(double t) {
    final s = _scene;
    s.of(_Kind.deodar)
      ..shedStart = t
      ..sync(t, 'sync_shedding', _Mood.happy);
    s.startSnow();
    _Sound.correct.play();
    s.cue(t + _settleS1, _finishStep);
  }

  /// 'Simulate Snowfall' on the cactus in the mountain
  /// (`animBreakCactus`): snow settles on its pads, its arms snap down and
  /// it browns.
  void _breakCactus(double t) {
    final s = _scene;
    final c = s.of(_Kind.cactus)..capsStart = t;
    s.startSnow();
    s.cue(t + _breakDelay, () {
      final now = s.time;
      c
        ..armsStart = now
        ..brownStart = now
        ..sync(now, 'sync_broken', _Mood.sad);
      _Sound.wrong.play();
    });
    s.cue(t + _settleS1, _finishStep);
  }

  /// 'Simulate Day' on the cactus at home in the desert (`animThrive`): it
  /// swells as it stores water.
  void _thrive(double t) {
    final s = _scene;
    s.of(_Kind.cactus)
      ..scaleTo(t, _thriveScale, _tweenSeconds, Curves.elasticOut)
      ..sync(t, 'sync_storing', _Mood.happy);
    s.heatStart = t;
    _Sound.correct.play();
    s.cue(t + _settleS1, _finishStep);
  }

  /// 'Walk' with the hot desert camel on the rocks (`animWalkSlip`): a
  /// step, a stumble, another step. (The HTML's tween chain dropped the
  /// stumble; it is played here.)
  void _stumble(double t) {
    final s = _scene;
    final c = s.of(_Kind.hotCamel);
    final p = c.posAt(t);
    c
      ..moveTo(t, _V(p.x, p.y, _slipZ1), _stepSeconds)
      ..walk(t, _stepSeconds * 3)
      ..sync(t, 'sync_struggling', _Mood.sad);
    s.cue(t + _stepSeconds, () => c.rollStart = s.time);
    s.cue(
      t + _stepSeconds * 2,
      () => c.moveTo(s.time, _V(p.x, p.y, _slipZ2), _stepSeconds),
    );
    _Sound.wrong.play();
    s.cue(t + _settleS2, _finishStep);
  }

  /// 'Simulate Cold Wind' (`animShiver`); added wind streaks.
  void _shiver(double t) {
    final s = _scene;
    s.of(_Kind.hotCamel)
      ..shiverStart = t
      ..sync(t, 'sync_cold', _Mood.cold);
    s.windStart = t;
    _Sound.wrong.play();
    s.cue(t + _settleS2, _finishStep);
  }

  /// 'Walk' with the cold desert camel on the sand (`animWalkSink`).
  void _sink(double t) {
    final s = _scene;
    final c = s.of(_Kind.coldCamel);
    final p = c.posAt(t);
    c
      ..moveTo(t, _V(p.x, -_sinkDepth, _sinkZ), _tweenSeconds)
      ..walk(t, _tweenSeconds)
      ..sync(t, 'sync_sinking', _Mood.sad);
    _Sound.wrong.play();
    s.cue(t + _settleS2, _finishStep);
  }

  /// 'Simulate Hot Day' (`animOverheat`): the woolly camel squashes as it
  /// pants.
  void _overheat(double t) {
    final s = _scene;
    s.of(_Kind.coldCamel)
      ..scaleTo(t, _overheatScale, _tweenSeconds, Curves.linear)
      ..sync(t, 'sync_hot', _Mood.hot);
    s.heatStart = t;
    _Sound.wrong.play();
    s.cue(t + _settleS2, _finishStep);
  }

  /// 'Simulate Environment' with both camels at home: they walk easily.
  /// (The HTML shares one label element, so only the second 'Adapted!'
  /// showed; each camel gets its own here.)
  void _adapted(double t) {
    final s = _scene;
    _Sound.success.play();
    for (final c in s.organisms) {
      final p = c.posAt(t);
      c
        ..moveTo(t, _V(p.x, p.y, _finalZ), _finalWalk)
        ..walk(t, _finalWalk)
        ..sync(t, 'sync_adapted', _Mood.happy);
    }
    s.cue(t + _settleBoth, _finishStep);
  }

  /// HTML `triggerConclusion()`: the split summary ("Habitat Solved!").
  void _review() {
    final s = _scene;
    if (s.done < _labSteps) return;
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
          cache: _cache,
          t: _t,
        ),
      ),
    );
  }

  /// The HTML's central action button (simulate / walk / 'Reset …', hidden
  /// while a simulation plays) and 'Review Findings'
  /// (`#compare-btn-container`) once the seven steps are done.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.busy) return const [];
    if (s.done >= _labSteps) {
      return [
        LabAction(
          label: _t('btn_review'),
          icon: Icons.check_circle,
          color: _Colors.amber600,
          foreground: _Colors.white,
          highlight: !s.reviewed,
          silent: true,
          onTap: _review,
        ),
      ];
    }
    final reset = _resetKey;
    if (reset != null && !s.resetDone) {
      return [
        LabAction(
          label: _t(reset),
          icon: Icons.replay,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _reset,
        ),
      ];
    }
    final run = _runKey;
    if (run != null && (_step != _labSteps || s.simulateReady)) {
      return [
        LabAction(
          label: _t(run),
          icon: _runIcon(run),
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _run,
        ),
      ];
    }
    return const [];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown`: a press on a plant or camel (not while a simulation
  /// plays, nor once the summary was opened).
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grab != null || s.busy || s.reviewed) {
      return false;
    }
    return s.organismAt(event.localPosition, _touch) != null;
  }

  /// Picks up the organism the step lets move; a press on another one, or
  /// before the step's 'Reset …', explains what to do instead.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final o = s.organismAt(d.localPosition, _touch);
    if (o == null || s.busy) return;
    final hint = _blockedHint(o);
    if (hint != null) {
      _lab.showToast(hint, isError: true);
      return;
    }
    final rest = o.posAt(s.time);
    final hit = s.camera().onPlaneY(d.localPosition, _dragPlaneY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - rest.x, 0, hit.z - rest.z);
    o.place(_V(rest.x, 0, rest.z));
    s.held = o;
    _grab = o;
    _grabScenario = s.scenario;
    _Sound.pickup.play();
  }

  /// HTML `handleMove`: the organism follows the finger on the drag plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final o = _grab;
    if (o == null || _grabScenario != _scene.scenario) return;
    final hit = _scene.camera().onPlaneY(d.localPosition, _dragPlaneY);
    if (hit == null) return;
    o.place(
      _V(
        (hit.x - _grabOffset.x).clamp(-_dragLimitX, _dragLimitX),
        0,
        (hit.z - _grabOffset.z).clamp(_dragMinZ, _dragMaxZ),
      ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`: dropped in the step's habitat it stays there;
  /// between the habitats it glides back to the tray (`playSound('pop')`).
  /// Added: a drop in the other habitat glides back too (the HTML left it
  /// there), and both explain what to do.
  void _release() {
    final o = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (o == null || scenario != s.scenario) return;
    s.held = null;
    final x = o.pos.x;
    final side = x < -_sideLimit
        ? _Side.desert
        : (x > _sideLimit ? _Side.mountain : null);
    if (side != null && side == _targetFor(o)) {
      _place(o, side);
      return;
    }
    o.moveTo(s.time, o.home, _returnSeconds);
    final lead = _t(side == null ? 'missed' : 'wrong_zone');
    _lab.showToast('$lead ${_t(_goKey(o))}', isError: true);
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
          icon: Icons.landscape,
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

/// HTML `#split-conclusion-modal`: the hot habitat's organism (cactus or
/// hot desert camel) on an amber panel, the cold habitat's (deodar or cold
/// desert camel) on a sky panel, each with its name and adaptation, and the
/// "VS" badge between them. The organisms are drawn as in the scene (the
/// HTML used flat SVG icons).
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.cache,
    required this.t,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final _PaintCache cache;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final dark = p.isDark;
    final lamp = scenario == 0 ? _lampS1 : _lampS2;
    final hot = scenario == 0 ? _Kind.cactus : _Kind.hotCamel;
    final cold = scenario == 0 ? _Kind.deodar : _Kind.coldCamel;
    return Stack(
      alignment: Alignment.center,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _panel(
                  kind: hot,
                  lamp: lamp,
                  fill: dark ? const Color(0x6678350F) : _Colors.amber100,
                  border: _Colors.amber500,
                  corner: Icons.wb_twilight,
                  cornerColor: _Colors.amber500,
                  alignCorner: Alignment.topLeft,
                  name: dark ? _Colors.amber300 : _Colors.amber800,
                  feature: dark ? _Colors.amber400 : _Colors.amber700,
                  radius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: _panel(
                  kind: cold,
                  lamp: lamp,
                  fill: dark ? _Colors.slate800 : _Colors.sky100,
                  border: _Colors.sky500,
                  corner: Icons.ac_unit,
                  cornerColor: _Colors.sky500,
                  alignCorner: Alignment.topRight,
                  name: dark ? _Colors.sky300 : _Colors.sky800,
                  feature: dark ? _Colors.sky400 : _Colors.sky600,
                  radius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Centre "VS" badge.
        Container(
          width: 38 * s,
          height: 38 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _Colors.slate900,
            shape: BoxShape.circle,
            border: Border.all(
              color: dark ? _Colors.slate700 : _Colors.white,
              width: 3,
            ),
            boxShadow: const [BoxShadow(color: LabInk.shadow, blurRadius: 10)],
          ),
          child: Text(
            t('sum_vs'),
            style: TextStyle(
              color: _Colors.amber500,
              fontSize: 13 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel({
    required _Kind kind,
    required _Lamp lamp,
    required Color fill,
    required Color border,
    required IconData corner,
    required Color cornerColor,
    required Alignment alignCorner,
    required Color name,
    required Color feature,
    required BorderRadius radius,
  }) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.fromLTRB(8 * s, 10 * s, 8 * s, 10 * s),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: alignCorner,
            child: Icon(
              corner,
              size: 26 * s,
              color: cornerColor.withValues(alpha: 0.3),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 96 * s,
                height: 84 * s,
                child: CustomPaint(
                  painter: _FigurePainter(kind: kind, cache: cache, lamp: lamp),
                ),
              ),
              SizedBox(height: 8 * s),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 6 * s,
                ),
                decoration: BoxDecoration(
                  color: p.isDark
                      ? const Color(0xE60F172A)
                      : const Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      t(kind.labelKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: name,
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      t(kind.featureKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: feature,
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One organism drawn into a box (the summary panels), as the scene draws
/// it.
class _FigurePainter extends CustomPainter {
  const _FigurePainter({
    required this.kind,
    required this.cache,
    required this.lamp,
  });

  final _Kind kind;
  final _PaintCache cache;
  final _Lamp lamp;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _Cam(_Framing.base);
    final box = cam.boxRect(kind.boxMin, kind.boxMax);
    if (box.width <= 0 || box.height <= 0) return;
    final k = math.min(size.width / box.width, size.height / box.height) * 0.9;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(k);
    canvas.translate(-box.center.dx, -box.center.dy);
    _Figure(
      _Gfx(canvas, cam, cache, lamp),
      0,
    ).paint(_Organism(kind, _V.zero), _V.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FigurePainter old) =>
      old.kind != kind || old.cache != cache || old.lamp != lamp;
}

// ================================================================== PAINTING

/// Paints, paths and point buffers reused by every frame (no allocation
/// per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// The icons' soft glow (`shadow-[0_0_30px_…]`).
  final Paint halo = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  /// Fades a status label in and out.
  final Paint layer = Paint();
  final Path path = Path();
  final Path path2 = Path();
  final List<Offset> pts = [];
  final List<Offset> rimA = [];
  final List<Offset> rimB = [];
  final List<Offset> hull = [];
}

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour and light, drawn on a unit circle) and the label text
/// painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<(int, Offset), Paint> _balls = {};
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

  TextPainter label(String text, [Color color = _Colors.chipText]) =>
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

  /// Size of a label chip with [text].
  Size chipSize(String text) {
    final a = label(text);
    return Size(
      a.width + 2 * _chipPadX * _labelSize,
      a.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle, lit from [light] (the highlight's place on the circle).
  Paint ball(Color c, Offset light) => _balls[(c.toARGB32(), light)] ??= Paint()
    ..shader = ui.Gradient.radial(
      light,
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

/// MeshStandardMaterial look: the ambient light plus the [lamp]'s Lambert
/// term on a surface with normal [n] (legacy, linear Three.js lighting).
Color _lit(Color c, _V n, _Lamp lamp) {
  final d = math.max(0.0, n.dot(lamp.dir)) * _diffuse;
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * (_ambient + d * lamp.r)),
    green: math.min(1.0, c.g * (_ambient + d * lamp.g)),
    blue: math.min(1.0, c.b * (_ambient + d * lamp.b)),
  );
}

/// Convex hull of [pts] (sorted in place) into [out], counter-clockwise on
/// screen (monotone chain).
void _convexHull(List<Offset> pts, List<Offset> out) {
  out.clear();
  if (pts.length < 3) {
    out.addAll(pts);
    return;
  }
  pts.sort(
    (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
  );
  double turn(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  for (final p in pts) {
    while (out.length >= 2 && turn(out[out.length - 2], out.last, p) <= 0) {
      out.removeLast();
    }
    out.add(p);
  }
  final lower = out.length + 1;
  for (var i = pts.length - 2; i >= 0; i--) {
    final p = pts[i];
    while (out.length >= lower && turn(out[out.length - 2], out.last, p) <= 0) {
      out.removeLast();
    }
    out.add(p);
  }
  out.removeLast();
}

/// Mesh drawing in one camera's projection and light.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache, this.lamp);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;
  final _Lamp lamp;

  _Pens get pens => cache.pens;

  Color lit(Color c, _V n) => _lit(c, n, lamp);

  /// Where a ball's highlight sits (the light comes from the upper left in
  /// Scenario 1, from above in Scenario 2).
  Offset get _highlight => Offset(lamp.dir.x * 0.6, -0.45);

  void _fillPoints(List<Offset> pts, Color color) => canvas.drawPath(
    pens.path
      ..reset()
      ..addPolygon(pts, true),
    pens.fill..color = color,
  );

  /// Flat quad (already lit [color]).
  void quad(_V a, _V b, _V c, _V d, Color color) {
    final pts = pens.pts
      ..clear()
      ..add(cam.p(a))
      ..add(cam.p(b))
      ..add(cam.p(c))
      ..add(cam.p(d));
    _fillPoints(pts, color);
  }

  /// The horizontal ellipse of radii [rx] x [rz] around [c], projected into
  /// the point buffer.
  List<Offset> _ellipse(_V c, double rx, double rz) {
    final pts = pens.pts..clear();
    final steps = _steps(math.max(rx, rz) * cam.scaleAt(c));
    for (var i = 0; i < steps; i++) {
      final a = 2 * math.pi * i / steps;
      pts.add(cam.p(_V(c.x + rx * math.cos(a), c.y, c.z + rz * math.sin(a))));
    }
    return pts;
  }

  /// Samples for a circle of [radius] screen px: enough that its outline
  /// stays round.
  int _steps(double radius) =>
      (radius / _pxPerStep).round().clamp(_minSteps, _maxSteps);

  /// A filled horizontal ellipse (flat ground decals).
  void flatEllipse(_V c, double rx, double rz, Color color) =>
      _fillPoints(_ellipse(c, rx, rz), color);

  /// A horizontal circle outline.
  void flatCircle(_V c, double r, Color color, double width) => canvas.drawPath(
    pens.path
      ..reset()
      ..addPolygon(_ellipse(c, r, r), true),
    pens.stroke
      ..strokeWidth = width
      ..color = color,
  );

  /// A flat ring between [inner] and [outer] (HTML `RingGeometry`).
  void annulus(_V c, double inner, double outer, Color color) {
    final path = pens.path
      ..reset()
      ..fillType = PathFillType.evenOdd
      ..addPolygon(_ellipse(c, outer, outer), true)
      ..addPolygon(_ellipse(c, inner, inner), true);
    canvas.drawPath(path, pens.fill..color = color);
    path.fillType = PathFillType.nonZero;
  }

  /// A CylinderGeometry / ConeGeometry ([rb] 0) from [a] (radius [ra]) to
  /// [b] (radius [rb]): its silhouette lit on the side facing the camera,
  /// shaded towards its edges ([shade]), and the end caps that face the
  /// camera.
  void frustum(
    _V a,
    _V b,
    double ra,
    double rb,
    Color color, {
    bool shade = true,
  }) {
    final axis = b - a;
    final len = axis.length;
    if (len < 1e-6) return;
    final k = axis * (1 / len);
    final e1 = k.cross(k.y.abs() < 0.9 ? _V.up : _V.right).unit;
    final e2 = k.cross(e1);
    final rimA = pens.rimA..clear();
    final rimB = pens.rimB..clear();
    final steps = _steps(math.max(ra * cam.scaleAt(a), rb * cam.scaleAt(b)));
    for (var i = 0; i < steps; i++) {
      final th = 2 * math.pi * i / steps;
      final d = e1 * math.cos(th) + e2 * math.sin(th);
      rimA.add(cam.p(a + d * ra));
      if (rb > 0) rimB.add(cam.p(b + d * rb));
    }
    final pts = pens.pts
      ..clear()
      ..addAll(rimA);
    if (rb > 0) {
      pts.addAll(rimB);
    } else {
      pts.add(cam.p(b));
    }
    _convexHull(pts, pens.hull);
    if (pens.hull.length < 3) return;
    final hull = pens.path
      ..reset()
      ..addPolygon(pens.hull, true);
    // The side towards the camera; a cone's surface leans towards its tip.
    final mid = (a + b) * 0.5;
    final view = cam.eye - mid;
    var front = view - k * view.dot(k);
    front = front.length < 1e-6 ? e1 : front.unit;
    final side = k.cross(front);
    final lean = (ra - rb) / len;
    _V surface(_V radial) => (radial + k * lean).unit;
    canvas.drawPath(hull, pens.fill..color = lit(color, surface(front)));
    if (shade) {
      final pa = cam.p(a), pb = cam.p(b);
      final d = pb - pa;
      final dl = d.distance;
      if (dl > 1.5) {
        final u = d / dl;
        var n = Offset(-u.dy, u.dx);
        final probe = cam.p(mid + side) - cam.p(mid);
        if (n.dx * probe.dx + n.dy * probe.dy < 0) n = -n;
        final wa = ra * cam.scaleAt(a), wb = rb * cam.scaleAt(b);
        canvas.save();
        canvas.clipPath(hull);
        for (final sign in const [1.0, -1.0]) {
          final o = n * sign;
          final a0 = pa - u * wa, b0 = pb + u * wb;
          final band = pens.path2
            ..reset()
            ..moveTo(a0.dx + o.dx * wa * 0.62, a0.dy + o.dy * wa * 0.62)
            ..lineTo(a0.dx + o.dx * wa * 1.3, a0.dy + o.dy * wa * 1.3)
            ..lineTo(b0.dx + o.dx * wb * 1.3, b0.dy + o.dy * wb * 1.3)
            ..lineTo(b0.dx + o.dx * wb * 0.62, b0.dy + o.dy * wb * 0.62)
            ..close();
          final normal = surface(front * 0.38 + side * (0.92 * sign));
          canvas.drawPath(band, pens.fill..color = lit(color, normal));
        }
        canvas.restore();
      }
    }
    // End caps facing the camera.
    if (rb > 0 && (cam.eye - b).dot(k) > 0) _fillPoints(rimB, lit(color, k));
    if (ra > 0 && (cam.eye - a).dot(k) < 0) {
      _fillPoints(rimA, lit(color, k * -1));
    }
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final pts = pens.pts..clear();
      for (final k in face.corners) {
        pts.add(cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)));
      }
      final path = pens.path
        ..reset()
        ..addPolygon(pts, true);
      canvas.drawPath(path, pens.fill..color = lit(color, n));
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
    canvas.drawCircle(Offset.zero, 1, cache.ball(color, _highlight));
    canvas.restore();
  }

  /// An ellipsoid with radii [rx], [ry], [rz] as the camera sees it (its
  /// x axis is the screen's horizontal).
  void ellipsoid(
    _V c,
    double rx,
    double ry,
    double rz,
    Color color, {
    double angle = 0,
  }) {
    final hy = math.sqrt(math.pow(ry * cam.u.y, 2) + math.pow(rz * cam.u.z, 2));
    blob(c, rx, hy, color, angle: angle);
  }

  /// A flat ellipse of radii [rx] x [ry] world units at [c] (snow).
  void oval(_V c, double rx, double ry, Color color) {
    final k = cam.scaleAt(c);
    canvas.drawOval(
      Rect.fromCenter(
        center: cam.p(c),
        width: math.max(0.5, 2 * rx * k),
        height: math.max(0.5, 2 * ry * k),
      ),
      pens.fill..color = color,
    );
  }

  /// A small flat dot (eyes).
  void dot(_V c, double r, Color color) => canvas.drawCircle(
    cam.p(c),
    math.max(0.8, r * cam.scaleAt(c)),
    pens.fill..color = color,
  );

  /// A line between two world points, [width] world units wide (at least
  /// 1 px).
  void line(_V a, _V b, double width, Color color) => canvas.drawLine(
    cam.p(a),
    cam.p(b),
    pens.stroke
      ..strokeWidth = math.max(1, width * cam.scaleAt(a))
      ..color = color,
  );

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

/// Draws one organism at [base] (its group origin), as the HTML model
/// creators build it, with its tweens at [time].
class _Figure {
  _Figure(this.g, this.time);

  final _Gfx g;
  final double time;

  /// The cactus arms (`arm1Geom` cylinders, radius 0.25, length 1):
  /// end points in the cactus' frame. The upright parts are drawn first so
  /// the slanted parts show the elbows.
  static const List<(_V, _V)> _arms = [
    (_V(0.7, 1, 0), _V(0.7, 2, 0)),
    (_V(-0.7, 0.6, 0), _V(-0.7, 1.6, 0)),
    (_V(0.0464, 0.8464, 0), _V(0.7536, 1.5536, 0)),
    (_V(-0.0464, 0.4464, 0), _V(-0.7536, 1.1536, 0)),
  ];

  /// Snow caps on the cactus (added): the stem top and the upright arms'
  /// tops, with their radius.
  static const List<(_V, double, bool)> _caps = [
    (_V(0, 2, 0), 0.4, false),
    (_V(0.7, 2, 0), 0.25, true),
    (_V(-0.7, 1.6, 0), 0.25, true),
  ];

  /// Where the snow sits on each deodar cone (azimuth from the front).
  static const List<double> _snowSpots = [-0.8, 0, 0.8];

  /// Paints [o]; [ground] puts its contact shadow on the ground or tray.
  void paint(_Organism o, _V base, {double? ground}) {
    if (ground != null) {
      final l = g.lamp.dir;
      final k = o.kind;
      final cx = (k.minX + k.maxX) / 2;
      g.shadow(
        _V(base.x + cx - l.x * 0.5, ground + 0.01, base.z - l.z * 0.5),
        (k.maxX - k.minX) / 2 + 0.2,
        k.halfZ + 0.35,
      );
    }
    switch (o.kind) {
      case _Kind.deodar:
        _deodar(o, base);
      case _Kind.cactus:
        _cactus(o, base);
      case _Kind.hotCamel:
        _camel(o, base, hot: true);
      case _Kind.coldCamel:
        _camel(o, base, hot: false);
    }
  }

  /// `createDeodarTree()`: a trunk and four stacked cones; wilting sags,
  /// browns and tilts them; snow (added) slides off the slopes.
  void _deodar(_Organism o, _V base) {
    final sc = o.scaleAt(time);
    _V w(_V l) => base + l.scaled(sc);
    g.frustum(
      w(_V.zero),
      w(const _V(0, 1.5, 0)),
      0.3 * sc.x,
      0.2 * sc.x,
      _Colors.trunk,
    );
    final brown = o.brownAt(time);
    final pine = Color.lerp(_Colors.pine, _Colors.wilt, brown)!;
    final ax = _wiltTiltX * brown, az = _wiltTiltZ * brown;
    for (var i = 0; i < 4; i++) {
      final h = 1.2 - 0.2 * i;
      final r = 1.0 - 0.2 * i;
      final c = _V(0, 1.2 + 0.7 * i, 0);
      g.frustum(
        w(c + _V(0, -h / 2, 0).rotZ(az).rotX(ax)),
        w(c + _V(0, h / 2, 0).rotZ(az).rotX(ax)),
        r * sc.x,
        0,
        pine,
      );
    }
    final shed = o.shedAt(time);
    if (shed < 0 || shed >= 1) return;
    // Snow lands on the slopes, slides down to the branch tips and drops
    // off.
    final grow = (shed / 0.3).clamp(0.0, 1.0);
    final q = ((shed - 0.3) / 0.7).clamp(0.0, 1.0);
    final slide = (q / 0.6).clamp(0.0, 1.0);
    final fall = ((q - 0.6) / 0.4).clamp(0.0, 1.0);
    for (var i = 0; i < 4; i++) {
      final h = 1.2 - 0.2 * i;
      final r = 1.0 - 0.2 * i;
      final cy = 1.2 + 0.7 * i;
      final apex = _V(0, cy + h / 2, 0);
      for (final phi in _snowSpots) {
        final out = _V(math.sin(phi), 0, math.cos(phi));
        final rim = _V(r * out.x, cy - h / 2, r * out.z);
        var p = _V.lerp(apex, rim, 0.35 + 0.65 * slide);
        if (fall > 0) p = p + out * (0.35 * fall) - _V(0, 1.4 * fall * fall, 0);
        g.oval(
          w(p),
          0.17 * grow,
          0.09 * grow,
          _Colors.snowCap.withValues(alpha: 1 - fall),
        );
      }
    }
  }

  /// `createCactus()`: a fleshy stem with two bent arms; snow (added)
  /// settles on its flat tops, the arms snap down to the ground and the
  /// cactus browns; at home it swells (`animThrive`).
  void _cactus(_Organism o, _V base) {
    final sc = o.scaleAt(time);
    final arms = o.armsAt(time);
    final color = Color.lerp(_Colors.cactus, _Colors.wilt, o.brownAt(time))!;
    _V w(_V l) => base + l.scaled(sc);
    _V arm(_V l) {
      final r = l.rotZ(arms);
      return _V(r.x, math.max(_armFloor, r.y), r.z);
    }

    final rx = sc.x;
    for (final (a, b) in _arms) {
      g.frustum(w(arm(a)), w(arm(b)), 0.25 * rx, 0.25 * rx, color);
    }
    g.frustum(w(_V.zero), w(const _V(0, 2, 0)), 0.4 * rx, 0.4 * rx, color);
    // Ribs on the stem (added).
    final rib = labShade(g.lit(color, const _V(0, 0, 1)), -0.25);
    for (final phi in const [-0.6, 0.0, 0.6]) {
      final x = 0.4 * math.sin(phi), z = 0.4 * math.cos(phi);
      g.line(
        w(_V(x, 0.12, z)),
        w(_V(x, 1.9, z)),
        0.03,
        rib.withValues(alpha: 0.7),
      );
    }
    final caps = o.capsAt(time);
    if (caps <= 0) return;
    for (final (at, r, onArm) in _caps) {
      final c = onArm ? arm(at) : at;
      g.ellipsoid(
        w(c + _V(0, 0.05 * caps, 0)),
        (r + 0.03) * rx * caps,
        0.1 * caps,
        (r + 0.03) * rx * caps,
        _Colors.snowCap,
      );
    }
  }

  /// `createCamel(type)`: legs pivoting at the hooves, the body, one or two
  /// humps, the neck and head; walking swings the legs and nods the head.
  /// The cold camel's fur fringe, the eyes and the sand pushed aside while
  /// sinking are added.
  void _camel(_Organism o, _V base, {required bool hot}) {
    final t = time;
    final sc = o.scaleAt(t);
    final roll = o.rollAt(t);
    final yaw = o.yawAt(t);
    final walking = o.walkingAt(t);
    final ht = t * _htmlTimeRate;
    final color = hot ? _Colors.hotCamel : _Colors.coldCamel;
    final bodyY = hot ? 1.6 : 1.4;
    final legLen = hot ? 1.2 : 0.8;
    final hoofW = hot ? 0.3 : 0.2;
    final bodyR = hot ? 0.6 : 0.66; // cold: `body.scale.set(1.1, 1, 1.1)`
    final k = (sc.x + sc.z) / 2;
    _V w(_V l) => base + l.scaled(sc).rotZ(roll).rotY(yaw);
    // How far it sank into the sand, and the sand's surface.
    final sunk = -o.posAt(t).y;
    final surface = base.y + sunk;
    if (sunk > 0.01) {
      g.flatEllipse(
        _V(base.x + 0.35, surface + 0.01, base.z),
        1.5,
        0.75,
        _Colors.sandDip.withValues(
          alpha: 0.45 * (sunk / _sinkDepth).clamp(0.0, 1.0),
        ),
      );
    }
    // Legs, far pair first.
    for (var i = 0; i < 4; i++) {
      final lx = i.isEven ? -0.7 : 0.7;
      final lz = i < 2 ? -0.35 : 0.35;
      final a = walking ? math.sin(ht * 10 + i) * _legSwing : 0.0;
      var foot = w(_V(lx, 0, lz));
      final top = w(_V(lx, legLen * math.cos(a), lz + legLen * math.sin(a)));
      if (top.y <= surface) continue;
      final buried = foot.y < surface - 1e-3;
      if (buried) {
        foot = _V.lerp(foot, top, (surface - foot.y) / (top.y - foot.y));
      }
      g.frustum(foot, top, 0.08 * k, 0.1 * k, color);
      if (!buried) {
        g.box(
          w(_V(lx + 0.05, 0.05, lz)),
          _V(hoofW * sc.x, 0.1 * sc.y, 0.25 * sc.z),
          _Colors.hoof,
          edge: 0.4,
        );
      }
    }
    // Body (`CylinderGeometry(0.6, 0.6, 1.8)` along x).
    g.frustum(
      w(_V(-0.9, bodyY, 0)),
      w(_V(0.9, bodyY, 0)),
      bodyR * k,
      bodyR * k,
      color,
    );
    if (!hot) {
      final fur = labShade(color, -0.35);
      for (var j = 0; j < 9; j++) {
        final x = -0.8 + 0.2 * j;
        g.line(
          w(_V(x, bodyY - bodyR * 0.8, bodyR * 0.55)),
          w(_V(x + 0.06, bodyY - bodyR * 1.12, bodyR * 0.6)),
          0.05,
          fur,
        );
      }
    }
    // Hump(s).
    if (hot) {
      g.ellipsoid(
        w(const _V(0, 2.2, 0)),
        0.5 * sc.x,
        0.65 * sc.y,
        0.4 * sc.z,
        color,
        angle: -roll,
      );
    } else {
      for (final hx in const [-0.4, 0.4]) {
        g.ellipsoid(
          w(_V(hx, 2, 0)),
          0.4 * sc.x,
          0.48 * sc.y,
          0.32 * sc.z,
          color,
          angle: -roll,
        );
      }
    }
    // Neck and head (`headGrp` at the body's height), nodding while walking.
    final nod = walking ? math.sin(ht * 5) * _headNod : 0.0;
    _V nk(double x, double y, [double z = 0]) =>
        w(_V(0, bodyY, 0) + _V(x, y, z).rotX(nod));
    g.frustum(nk(0.66, -0.139), nk(1.14, 0.739), 0.3 * k, 0.2 * k, color);
    g.frustum(nk(0.906, 0.86), nk(1.494, 0.74), 0.18 * k, 0.18 * k, color);
    if (!hot) {
      final fur = labShade(color, -0.35);
      for (var j = 0; j < 4; j++) {
        final f = 0.15 + 0.2 * j;
        final y = -0.139 + 0.878 * f;
        final x = 0.66 + 0.48 * f;
        g.line(nk(x - 0.22, y, 0.12), nk(x - 0.34, y - 0.08, 0.14), 0.05, fur);
      }
    }
    g.dot(nk(1.3, 0.94, 0.15), 0.045, _Colors.camelEye);
  }
}

/// A label chip's colours (HTML `createTextSprite` bgColor, bColor,
/// textColor).
@immutable
class _ChipStyle {
  const _ChipStyle(this.fill, this.border, this.text, {this.width = 1.2});

  final Color fill;
  final Color border;
  final Color text;
  final double width;
}

/// The organisms' names (default sprite colours).
const _ChipStyle _chipName = _ChipStyle(
  _Colors.chipBg,
  _Colors.chipBorder,
  _Colors.chipText,
);

/// 'Hot Desert' (`#b45309` / `#f59e0b`) and 'Cold Mountains' / 'Cold
/// Desert' and the tray (`#0f172a` / `#38bdf8`).
const _ChipStyle _chipHot = _ChipStyle(
  _Colors.amber700,
  _Colors.amber500,
  _Colors.white,
);
const _ChipStyle _chipCold = _ChipStyle(
  _Colors.slate900,
  _Colors.sky400,
  _Colors.white,
);

/// 'Drop Here': the zone colour with a white border.
const _ChipStyle _chipDropHot = _ChipStyle(
  _Colors.zoneHot,
  _Colors.white,
  _Colors.white,
);
const _ChipStyle _chipDropCold = _ChipStyle(
  _Colors.zoneCold,
  _Colors.white,
  _Colors.white,
);

/// Paints the HTML Three.js scene: the split background, sand and snow
/// with dunes and rocks, the two drop zones, the inventory tray and the
/// organisms; then the sun and frost icons, wind and snow, the labels, the
/// held organism and the status labels on top.
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
    final g = _Gfx(canvas, s.camera(), cache, s.lamp);
    _paintSky(g, size);
    _paintGround(g);
    for (final (c, r) in _dunes) {
      _paintDune(g, c, r);
    }
    for (final (c, r) in _rocks) {
      _paintRock(g, c, r);
    }
    _paintZones(g);
    _paintTray(g);
    final figure = _Figure(g, s.time);
    final order =
        [
          for (final o in s.organisms)
            if (o.visible && !identical(o, s.held)) o,
        ]..sort(
          (a, b) =>
              g.cam.depth(s.baseOf(b)).compareTo(g.cam.depth(s.baseOf(a))),
        );
    for (final o in order) {
      figure.paint(o, s.baseOf(o), ground: s.groundOf(o));
    }
    _paintIcons(g);
    _paintWind(g);
    _paintSnow(g);
    final names = showLabels ? _paintLabels(g) : const <_Organism, Rect>{};
    final held = s.held;
    if (held != null) {
      final base = s.baseOf(held);
      figure.paint(held, base, ground: s.groundOf(held));
      if (showLabels) {
        _drawChip(g, _nameRect(g, held), _t(held.kind.labelKey), _chipName);
      }
    }
    _paintStatus(g, names);
  }

  // ------------------------------------------------------------ the world

  /// `#webgl-container` background, split where the sand meets the snow.
  void _paintSky(_Gfx g, Size size) {
    final bleed = labBleed(size);
    final seam = g.cam.center.dx;
    g.canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, seam, bleed.bottom),
      _pens.fill..color = isDark ? _Colors.skyHotDark : _Colors.skyHotLight,
    );
    g.canvas.drawRect(
      Rect.fromLTRB(seam, bleed.top, bleed.right, bleed.bottom),
      _pens.fill..color = isDark ? _Colors.skyColdDark : _Colors.skyColdLight,
    );
  }

  /// The sand (x < 0) and snow (x > 0) planes, out to the horizon.
  void _paintGround(_Gfx g) {
    g.quad(
      const _V(-_groundWide, 0, -_groundFar),
      const _V(0, 0, -_groundFar),
      const _V(0, 0, _groundNear),
      const _V(-_groundWide, 0, _groundNear),
      g.lit(_Colors.sand, _V.up),
    );
    g.quad(
      const _V(0, 0, -_groundFar),
      const _V(_groundWide, 0, -_groundFar),
      const _V(_groundWide, 0, _groundNear),
      const _V(0, 0, _groundNear),
      g.lit(_Colors.snow, _V.up),
    );
  }

  /// A dune: the part of a squashed sand sphere above the ground, drawn as
  /// stacked slices from the rim (darker) to the crest (lighter).
  void _paintDune(_Gfx g, _V c, _V r) {
    final top = c.y + r.y;
    final sand = g.lit(_Colors.sand, _V.up);
    for (var j = 0; j < _duneSlices; j++) {
      final y = top * j / _duneSlices;
      final e = (y - c.y) / r.y;
      final k = math.sqrt(math.max(0.0, 1 - e * e));
      if (k <= 0) continue;
      final shade = -0.1 + 0.22 * j / (_duneSlices - 1);
      g.flatEllipse(_V(c.x, y, c.z), r.x * k, r.z * k, labShade(sand, shade));
    }
  }

  /// A rock (`DodecahedronGeometry`, flat-shaded faces), partly buried:
  /// low-poly facets clipped above the ground.
  void _paintRock(_Gfx g, _V c, double r) {
    final cam = g.cam;
    final contact = math.sqrt(math.max(0.0, r * r - c.y * c.y));
    // Clip: everything above the front arc of the ground contact circle.
    final clip = _pens.pts..clear();
    final right = cam.p(_V(c.x + contact, 0, c.z));
    final left = cam.p(_V(c.x - contact, 0, c.z));
    clip.add(Offset(left.dx, -1e5));
    clip.add(Offset(right.dx, -1e5));
    for (var i = 0; i <= 20; i++) {
      final a = math.pi * i / 20;
      clip.add(
        cam.p(_V(c.x + contact * math.cos(a), 0, c.z + contact * math.sin(a))),
      );
    }
    g.canvas.save();
    g.canvas.clipPath(Path()..addPolygon(clip, true));
    final p = cam.p(c);
    final rad = r * cam.scaleAt(c);
    final inner = p + Offset(g.lamp.dir.x * 0.25 * rad, -0.3 * rad);
    const facets = 8;
    const jitter = [0.96, 1.0, 0.92, 0.98, 1.0, 0.94, 0.99, 0.93];
    for (var i = 0; i < facets; i++) {
      final a0 = 2 * math.pi * i / facets;
      final a1 = 2 * math.pi * (i + 1) / facets;
      final q0 = p + Offset(math.cos(a0), math.sin(a0)) * (rad * jitter[i]);
      final q1 =
          p +
          Offset(math.cos(a1), math.sin(a1)) * (rad * jitter[(i + 1) % facets]);
      final am = (a0 + a1) / 2;
      final n = _V(math.cos(am) * 0.8, -math.sin(am) * 0.8, 0.6).unit;
      final tri = _pens.path2
        ..reset()
        ..moveTo(inner.dx, inner.dy)
        ..lineTo(q0.dx, q0.dy)
        ..lineTo(q1.dx, q1.dy)
        ..close();
      g.canvas.drawPath(tri, _pens.fill..color = g.lit(_Colors.rock, n));
      g.canvas.drawPath(
        tri,
        _pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(_Colors.rock, -0.3).withValues(alpha: 0.5),
      );
    }
    g.canvas.restore();
  }

  /// The two drop zones (`createDropZone`): a translucent ring and a dashed
  /// circle. Added: the ring under a held organism brightens.
  void _paintZones(_Gfx g) {
    final held = scene.held;
    final x = held?.pos.x ?? 0;
    for (final hot in const [true, false]) {
      final cx = hot ? -_zoneX : _zoneX;
      final color = hot ? _Colors.zoneHot : _Colors.zoneCold;
      final over = held != null && (hot ? x < -_sideLimit : x > _sideLimit);
      final c = _V(cx, _ringY, 0);
      g.annulus(
        c,
        _ringInner,
        _ringOuter,
        color.withValues(alpha: over ? 0.85 : 0.5),
      );
      final dashes = (2 * math.pi * _ringInner / (2 * _dashLength)).round();
      final stroke = _pens.stroke
        ..strokeWidth = over ? 2.2 : 1.5
        ..color = color;
      for (var i = 0; i < dashes; i++) {
        final a0 = 2 * math.pi * i / dashes;
        final a1 = a0 + math.pi / dashes;
        g.canvas.drawLine(
          g.cam.p(
            _V(
              cx + _ringInner * math.cos(a0),
              _ringY,
              _ringInner * math.sin(a0),
            ),
          ),
          g.cam.p(
            _V(
              cx + _ringInner * math.cos(a1),
              _ringY,
              _ringInner * math.sin(a1),
            ),
          ),
          stroke,
        );
      }
    }
  }

  /// The inventory tray and its glowing ring.
  void _paintTray(_Gfx g) {
    g.frustum(
      const _V(0, 0, _trayZ),
      const _V(0, _trayTop, _trayZ),
      _trayRadius,
      _trayRadius,
      _Colors.tray,
      shade: false,
    );
    final ring = const _V(0, _trayTop, _trayZ);
    g.flatCircle(
      ring,
      _trayRingRadius,
      _Colors.trayRing,
      math.max(1.5, 2 * _trayRingTube * g.cam.scaleAt(ring)),
    );
  }

  // ----------------------------------------------------------- overlays

  /// HTML `#icon-sun` (spinning) and `#icon-freeze` (pulsing). Added: each
  /// glows brighter while its weather plays.
  void _paintIcons(_Gfx g) {
    final s = scene;
    final r = _iconScale * cache.labelSize;
    double glow(double start) {
      if (start < 0) return 0;
      final e = (s.time - start) / _glowSeconds;
      return e <= 0 || e >= 1 ? 0 : math.sin(math.pi * e);
    }

    _paintSun(g.canvas, g.cam.p(_sunAt), r, glow(s.heatStart));
    _paintFrost(
      g.canvas,
      g.cam.p(_frostAt),
      r,
      math.max(glow(s.snowStart), glow(s.windStart)),
    );
  }

  void _paintSun(Canvas canvas, Offset c, double r, double glow) {
    final pens = _pens;
    if (glow > 0) {
      // The day's heat (added): an orange blaze around the sun.
      canvas.drawCircle(
        c,
        r * (1.3 + 0.9 * glow),
        pens.halo..color = _Colors.heatGlow.withValues(alpha: 0.7 * glow),
      );
    }
    canvas.drawCircle(
      c,
      r * (1.1 + 0.45 * glow),
      pens.halo..color = _Colors.sunGlow.withValues(alpha: 0.45 + 0.45 * glow),
    );
    canvas.drawCircle(c, r, pens.fill..color = _Colors.sunDisc);
    canvas.drawCircle(
      c,
      r,
      pens.stroke
        ..strokeWidth = 2
        ..color = _Colors.amber400,
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(2 * math.pi * scene.time / _sunSpinSeconds);
    final ray = pens.stroke
      ..strokeWidth = 0.09 * r
      ..color = _Colors.amber500;
    for (var i = 0; i < 8; i++) {
      final a = math.pi * i / 4;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(d * (0.44 * r), d * ((0.66 + 0.2 * glow) * r), ray);
    }
    canvas.drawCircle(
      Offset.zero,
      0.3 * r,
      pens.fill..color = _Colors.amber500,
    );
    canvas.restore();
  }

  void _paintFrost(Canvas canvas, Offset c, double r, double glow) {
    final pens = _pens;
    // Tailwind animate-pulse: opacity 1 → 0.5 → 1 every 2 s.
    final pulse =
        0.75 + 0.25 * math.cos(2 * math.pi * scene.time / _pulseSeconds);
    if (glow > 0) {
      // Snow or cold wind (added): an icy blaze around the snowflake.
      canvas.drawCircle(
        c,
        r * (1.3 + 0.9 * glow),
        pens.halo..color = _Colors.coldGlow.withValues(alpha: 0.7 * glow),
      );
    }
    canvas.drawCircle(
      c,
      r * (1.1 + 0.45 * glow),
      pens.halo
        ..color = _Colors.frostGlow.withValues(alpha: 0.45 + 0.45 * glow),
    );
    canvas.drawCircle(c, r, pens.fill..color = _Colors.frostDisc);
    canvas.drawCircle(
      c,
      r,
      pens.stroke
        ..strokeWidth = 2
        ..color = _Colors.sky400,
    );
    final arm = pens.stroke
      ..strokeWidth = 0.09 * r
      ..color = _Colors.sky500.withValues(alpha: pulse);
    for (var i = 0; i < 6; i++) {
      final a = math.pi * i / 3 - math.pi / 2;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c, c + d * (0.62 * r), arm);
      final mid = c + d * (0.4 * r);
      for (final turn in const [-0.75, 0.75]) {
        final b = Offset(math.cos(a + turn), math.sin(a + turn));
        canvas.drawLine(mid, mid + b * (0.18 * r), arm);
      }
    }
  }

  /// Added: wind streaks blowing across the cold side.
  void _paintWind(_Gfx g) {
    final s = scene;
    if (s.windStart < 0) return;
    final e = (s.time - s.windStart) / _windSeconds;
    if (e <= 0 || e >= 1) return;
    final v = s.view;
    final left = math.max(v.left, g.cam.center.dx);
    final right = v.right;
    final len = 70 * cache.labelSize / _labelPx;
    final stroke = _pens.stroke
      ..strokeWidth = 2
      ..color = _Colors.wind.withValues(alpha: 0.75 * math.sin(math.pi * e));
    g.canvas.save();
    g.canvas.clipRect(Rect.fromLTRB(left, v.top, right, v.bottom));
    for (var i = 0; i < _windStreaks; i++) {
      final y = v.top + v.height * (0.3 + 0.075 * i);
      final head = right - ((e * 1.7 + i * 0.37) % 1.0) * (right - left + len);
      final path = _pens.path2
        ..reset()
        ..moveTo(head, y)
        ..quadraticBezierTo(head + len / 2, y - 6, head + len, y);
      g.canvas.drawPath(path, stroke);
    }
    g.canvas.restore();
  }

  /// HTML `createSnowEffect`: 50 flakes falling over the snowy half for
  /// 3 s.
  void _paintSnow(_Gfx g) {
    final s = scene;
    if (s.snowStart < 0) return;
    final e = s.time - s.snowStart;
    if (e >= _snowSeconds) return;
    final v = s.view;
    final left = math.max(v.left, g.cam.center.dx);
    final r = 2.2 * cache.labelSize / _labelPx;
    final fill = _pens.fill..color = _Colors.snowCap;
    for (final f in s.flakes) {
      final local = e - f.delay;
      if (local < 0) continue;
      final y = v.top - r + (v.height + 2 * r) * (local / f.seconds);
      if (y > v.bottom + r) continue;
      final c = Offset(left + (v.right - left) * f.x, y);
      g.canvas.drawCircle(c, r, fill);
      g.canvas.drawCircle(
        c,
        r,
        _pens.stroke
          ..strokeWidth = 0.8
          ..color = _Colors.flakeRim,
      );
    }
  }

  // ------------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip (HTML `labelDict`);
  /// returns the organisms' name chips so the status labels stack above.
  Map<_Organism, Rect> _paintLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    _chipAt(g, cam.p(_zoneLabelHot), _t('lbl_hot_desert'), _centered, _chipHot);
    _chipAt(
      g,
      cam.p(_zoneLabelCold),
      _t(s.scenario == 0 ? 'lbl_cold_mountains' : 'lbl_cold_desert'),
      _centered,
      _chipCold,
    );
    _chipAt(
      g,
      cam.p(const _V(-_zoneX, 0, _dropChipZ)),
      _t('lbl_drop'),
      _below,
      _chipDropHot,
    );
    _chipAt(
      g,
      cam.p(const _V(_zoneX, 0, _dropChipZ)),
      _t('lbl_drop'),
      _below,
      _chipDropCold,
    );
    _chipAt(g, cam.p(_trayLabelAt), _t('lbl_tray'), _leftOf, _chipCold);
    final names = <_Organism, Rect>{};
    for (final o in s.organisms) {
      if (!o.visible || identical(o, s.held)) continue;
      names[o] = _nameRect(g, o);
    }
    _separate(names);
    names.forEach((o, r) => _drawChip(g, r, _t(o.kind.labelKey), _chipName));
    return names;
  }

  /// The name chip of [o], just above it, inside the visible canvas.
  Rect _nameRect(_Gfx g, _Organism o) {
    final text = _t(o.kind.labelKey);
    final size = cache.chipSize(text);
    final at = g.cam.p(_nameAt(o, scene.baseOf(o), o.scaleAt(scene.time)));
    return _clampX((at + _chipOffset(size, _above)) & size);
  }

  /// Pushes two overlapping name chips (the camels on the tray) apart.
  void _separate(Map<_Organism, Rect> names) {
    if (names.length < 2) return;
    final keys = names.keys.toList();
    final a = names[keys[0]]!, b = names[keys[1]]!;
    if (!a.overlaps(b)) return;
    final aLeft = a.center.dx <= b.center.dx;
    final l = aLeft ? a : b, r = aLeft ? b : a;
    final push = (l.right - r.left) / 2 + 2;
    names[aLeft ? keys[0] : keys[1]] = l.shift(Offset(-push, 0));
    names[aLeft ? keys[1] : keys[0]] = r.shift(Offset(push, 0));
  }

  Rect _clampX(Rect rect) {
    final s = scene;
    var r = rect;
    if (r.right > s.labelRight) r = r.shift(Offset(s.labelRight - r.right, 0));
    if (r.left < s.labelLeft) r = r.shift(Offset(s.labelLeft - r.left, 0));
    return r;
  }

  void _chipAt(
    _Gfx g,
    Offset at,
    String text,
    (double, double) align,
    _ChipStyle style,
  ) {
    final size = cache.chipSize(text);
    _drawChip(g, _clampX((at + _chipOffset(size, align)) & size), text, style);
  }

  /// HTML `createTextSprite`: a rounded chip with a border and bold text.
  void _drawChip(_Gfx g, Rect rect, String text, _ChipStyle style) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.45),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = style.fill);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = style.width
        ..color = style.border,
    );
    final tp = cache.label(text, style.text);
    tp.paint(
      g.canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.top + _chipPadY * cache.labelSize,
      ),
    );
  }

  /// HTML `showSyncLabel`: a face disc and a red (sad) or green (happy)
  /// text label floating above the organism for 3 s.
  void _paintStatus(_Gfx g, Map<_Organism, Rect> names) {
    final s = scene;
    for (final o in s.organisms) {
      if (!o.visible) continue;
      final alpha = o.syncAlpha(s.time);
      final key = o.syncKey;
      if (alpha <= 0.01 || key == null) continue;
      final top =
          names[o]?.topCenter ??
          g.cam.p(_nameAt(o, s.baseOf(o), o.scaleAt(s.time)));
      final happy = o.syncMood == _Mood.happy;
      final tone = happy ? _Colors.green500 : _Colors.red500;
      final style = _ChipStyle(
        isDark ? _Colors.statusDark : _Colors.statusLight,
        tone,
        tone,
        width: 2,
      );
      final text = _t(key);
      final size = cache.chipSize(text);
      final rect = _clampX(
        Rect.fromLTWH(
          top.dx - size.width / 2,
          top.dy - 4 - size.height,
          size.width,
          size.height,
        ),
      );
      final fade = alpha < 0.99;
      if (fade) {
        g.canvas.saveLayer(
          null,
          _pens.layer..color = Color.fromRGBO(0, 0, 0, alpha),
        );
      }
      _drawChip(g, rect, text, style);
      final disc = _discScale * cache.labelSize;
      final c = Offset(rect.center.dx, rect.top - 3 - disc);
      g.canvas.drawCircle(c + const Offset(0, 2), disc, _pens.shadow);
      g.canvas.drawCircle(
        c,
        disc,
        _pens.fill..color = isDark ? _Colors.discDark : _Colors.discLight,
      );
      g.canvas.drawCircle(
        c,
        disc,
        _pens.stroke
          ..strokeWidth = 1.2
          ..color = isDark ? _Colors.discBorderDark : _Colors.discBorderLight,
      );
      _paintFace(g.canvas, c, disc * 0.68, o.syncMood);
      if (fade) g.canvas.restore();
    }
  }

  /// The HTML emoji, drawn: ☹️ (sad), 😄 (happy), 🥶 (too cold), 🥵 (too
  /// hot).
  void _paintFace(Canvas canvas, Offset c, double r, _Mood mood) {
    final fill = _pens.fill;
    final stroke = _pens.stroke;
    final face = switch (mood) {
      _Mood.cold => _Colors.faceCold,
      _Mood.hot => _Colors.faceHot,
      _ => _Colors.faceYellow,
    };
    canvas.drawCircle(c, r, fill..color = face);
    canvas.drawCircle(
      c,
      r,
      stroke
        ..strokeWidth = math.max(1, 0.08 * r)
        ..color = labShade(face, -0.35),
    );
    for (final sx in const [-1.0, 1.0]) {
      canvas.drawCircle(
        c + Offset(sx * 0.34 * r, -0.2 * r),
        0.11 * r,
        fill..color = _Colors.faceInk,
      );
    }
    final mouth = _pens.path2..reset();
    switch (mood) {
      case _Mood.sad:
        mouth
          ..moveTo(c.dx - 0.38 * r, c.dy + 0.52 * r)
          ..quadraticBezierTo(
            c.dx,
            c.dy + 0.12 * r,
            c.dx + 0.38 * r,
            c.dy + 0.52 * r,
          );
        canvas.drawPath(
          mouth,
          stroke
            ..strokeWidth = 0.11 * r
            ..color = _Colors.faceInk,
        );
      case _Mood.happy:
        mouth
          ..moveTo(c.dx - 0.46 * r, c.dy + 0.12 * r)
          ..quadraticBezierTo(
            c.dx,
            c.dy + 0.9 * r,
            c.dx + 0.46 * r,
            c.dy + 0.12 * r,
          )
          ..close();
        canvas.drawPath(mouth, fill..color = _Colors.faceInk);
      case _Mood.cold:
        final teeth = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            c.dx - 0.42 * r,
            c.dy + 0.2 * r,
            c.dx + 0.42 * r,
            c.dy + 0.54 * r,
          ),
          Radius.circular(0.1 * r),
        );
        canvas.drawRRect(teeth, fill..color = _Colors.white);
        final ink = stroke
          ..strokeWidth = math.max(0.8, 0.06 * r)
          ..color = _Colors.faceInk;
        canvas.drawRRect(teeth, ink);
        canvas.drawLine(
          Offset(teeth.left, teeth.center.dy),
          Offset(teeth.right, teeth.center.dy),
          ink,
        );
        for (final x in const [-0.14, 0.14]) {
          canvas.drawLine(
            Offset(c.dx + x * r, teeth.top),
            Offset(c.dx + x * r, teeth.bottom),
            ink,
          );
        }
      case _Mood.hot:
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(0, 0.38 * r),
            width: 0.52 * r,
            height: 0.4 * r,
          ),
          fill..color = _Colors.faceInk,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(0, 0.5 * r),
            width: 0.3 * r,
            height: 0.18 * r,
          ),
          fill..color = _Colors.tongue,
        );
        final drop = c + Offset(0.68 * r, -0.42 * r);
        mouth
          ..moveTo(drop.dx, drop.dy - 0.24 * r)
          ..quadraticBezierTo(
            drop.dx + 0.16 * r,
            drop.dy,
            drop.dx,
            drop.dy + 0.1 * r,
          )
          ..quadraticBezierTo(
            drop.dx - 0.16 * r,
            drop.dy,
            drop.dx,
            drop.dy - 0.24 * r,
          );
        canvas.drawPath(mouth, fill..color = _Colors.sweat);
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
