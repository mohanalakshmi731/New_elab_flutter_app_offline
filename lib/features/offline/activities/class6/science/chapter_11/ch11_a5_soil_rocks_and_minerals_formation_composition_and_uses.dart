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

/// Class 6 Science • Chapter 11 • Activity 5
/// Soil, Rocks, and Minerals: Formation, Composition, and Uses ("Soil,
/// Rocks, and Minerals: Composition and Uses").
///
/// Native Flutter port of
/// `Cl6S-Ch11-A5-Soil__Rocks__and_Minerals__Formation__Composition__and_Uses.html`
/// (Three.js r128 + Tween.js). The Three.js scenes are redrawn by a small
/// painter ([_Gfx]) with the HTML camera: 45° field of view, at (0, 6.2, 11)
/// looking at (0, 0.6, 0.8) (Scenario 1) or at (0, 5.8, 10.5) looking at
/// (0, 0.6, 0.5) (Scenario 2). The HTML pointer handlers become a pan
/// recogniser that only claims touches starting on a scene object; the
/// HTML 'Controls' bar is a row of buttons at the top of the canvas.
///
/// Scenario 1 (The Soil Investigator): on a lab table between a forest edge
/// (dark soil, two pine trees) and a ploughed farm (furrows, sprouts), tap
/// the shovel in each plot: it digs and a burlap soil bag lands on the
/// table. Drag (or tap) each bag onto the sieve tower: it tips its soil in,
/// the sieve shakes and two rows of trays fill. Forest soil gives a tall
/// pile of dark humus, some sand and pebbles and a wriggling earthworm;
/// farm soil a big pile of sand, more pebbles, a thin layer of humus and no
/// earthworm. '5. Inspect Lens' (or a tap on a tray) opens the magnifying
/// glass close-ups of the four trays, then 'Observe Conclusion' sums up.
///
/// Scenario 2 (The Stone Age Toolmaker): drag the hammerstone onto the
/// slate (it splits into thin flat tiles), the sandstone (it crumbles into
/// sand grains) and the speckled granite ('Clink!': a sharp flake, a Stone
/// Age hand axe, breaks off). Drag the flake across the wooden plank: it
/// carves notches and curls up shavings. 'Observe Conclusion' compares the
/// three rocks.
class Ch11A5SoilRocksAndMineralsFormationCompositionAndUsesPage
    extends StatefulWidget {
  const Ch11A5SoilRocksAndMineralsFormationCompositionAndUsesPage({super.key});

  @override
  State<Ch11A5SoilRocksAndMineralsFormationCompositionAndUsesPage>
  createState() => _SoilRocksLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'click' (sidebar, inspection, scenario change) → click
/// (`science/click.mp3`), 'shake' (a shovel digging, a bag tipped into the
/// sieve) → shake (`science/dropdown.mp3`, a rustle), 'strike' (the
/// hammerstone on slate or sandstone, the flake carving) → strike
/// (`science/click.mp3`, a knock), 'clink' (the hammerstone on granite) →
/// clink (`math/success.mp3`, a bright chime) and 'success' (every step
/// done, the summary) → correct / success (`math/success.mp3`). A press out
/// of turn ('Please collect … first') plays wrong (`science/error.mp3`).
/// The shell plays toggle (`science/dropdown.mp3`), scenario
/// (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A step done (HTML `progressStep()` → `success`).
  correct('audio/class6/math/success.mp3'),

  /// 'Please collect Forest Soil first (Step 1)!' and the other refusals.
  wrong('audio/class6/science/error.mp3'),

  /// The summary popup (HTML `triggerConclusion()` → `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A shovel digging, a bag tipped into the shaking sieve (HTML `shake`).
  shake('audio/class6/science/dropdown.mp3'),

  /// The hammerstone on slate or sandstone, the flake carving the plank
  /// (HTML `strike`).
  strike('audio/class6/science/click.mp3'),

  /// The hammerstone on granite (HTML `clink`).
  clink('audio/class6/math/success.mp3');

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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber950 = Color(0xFF451A03);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald950 = Color(0xFF022C22);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo950 = Color(0xFF1E1B4B);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color pink300 = Color(0xFFF9A8D4);
  static const Color pink400 = Color(0xFFF472B6);
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
  /// `scene.background`: 0x1e293b (dark theme), 0xa7f3d0 (light theme).
  static const Color sceneDark = slate800;
  static const Color sceneLight = Color(0xFFA7F3D0);

  /// Lab tables: 0x334155 (Scenario 1), 0x475569 (Scenario 2).
  static const Color labTable = slate700;
  static const Color workshopTable = slate600;

  /// Forest plot 0x3f2e21, pine needles 0x14532d, trunks 0x78350f.
  static const Color forestSoil = Color(0xFF3F2E21);
  static const Color pine = Color(0xFF14532D);
  static const Color trunk = Color(0xFF78350F);

  /// Farm plot 0xa16207, furrows 0x854d0e, crop sprouts 0x22c55e.
  static const Color farmSoil = Color(0xFFA16207);
  static const Color furrow = Color(0xFF854D0E);
  static const Color sprout = Color(0xFF22C55E);

  /// Shovel: blade 0x94a3b8, shaft 0xb45309, grip 0x334155.
  static const Color blade = slate400;
  static const Color shaft = amber700;
  static const Color grip = slate700;

  /// Burlap bag 0xc29b61, its tie 0x451a03; soil 0x78350f (forest) or
  /// 0xb45309 (farm); moss 0x16a34a or crop specks 0xd97706.
  static const Color burlap = Color(0xFFC29B61);
  static const Color tie = amber950;
  static const Color forestHeap = Color(0xFF78350F);
  static const Color farmHeap = amber700;
  static const Color moss = Color(0xFF16A34A);
  static const Color cropSpeck = amber600;

  /// Sieve tower: stand 0x334155, top rim 0x94a3b8 with a 0xd97706 mesh,
  /// brass handles 0xb45309, middle rim 0x64748b with a 0xfbbf24 mesh,
  /// funnel 0x475569.
  static const Color stand = slate700;
  static const Color topRim = slate400;
  static const Color coarseMesh = amber600;
  static const Color brass = amber700;
  static const Color midRim = slate500;
  static const Color fineMesh = amber400;
  static const Color funnel = slate600;

  /// Lab trays: base 0xf1f5f9, rims 0xe2e8f0.
  static const Color trayBase = slate100;
  static const Color trayRim = slate200;

  /// Tray contents: humus 0x3f2e21 (forest) / 0x78350f (farm) with leaves
  /// 0x14532d, sand 0xfacc15, pebbles in five greys, the earthworm 0xf472b6.
  static const Color humusForest = forestSoil;
  static const Color humusFarm = Color(0xFF78350F);
  static const Color leaf = pine;
  static const Color sand = Color(0xFFFACC15);
  static const List<Color> pebbles = [
    slate500,
    slate600,
    slate400,
    slate700,
    Color(0xFF78716C),
  ];
  static const Color earthworm = pink400;

  /// Scenario 2: slate 0x334155, sandstone 0xd97706, granite 0x64748b with
  /// 0x0f172a specks, hammerstone 0x1e293b on a 0x78350f handle, sand
  /// grains 0xfbbf24, the flake 0x94a3b8, the plank 0x854d0e and its
  /// shavings 0xfef08a.
  static const Color slateRock = slate700;
  static const Color sandstone = amber600;
  static const Color granite = slate500;
  static const Color speck = slate900;
  static const Color hammerHead = slate800;
  static const Color hammerHandle = Color(0xFF78350F);
  static const Color sandGrain = amber400;
  static const Color flake = slate400;
  static const Color plank = Color(0xFF854D0E);
  static const Color shaving = Color(0xFFFEF08A);

  /// Text sprites (`createTextSprite`): `rgba(15, 23, 42, 0.9)` box with a
  /// `rgba(255, 255, 255, 0.35)` border and white bold text.
  static const Color chipBg = Color(0xE60F172A);
  static const Color chipBorder = Color(0x59FFFFFF);
  static const Color chipText = white;

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// canvas-confetti's default colours.
  static const List<Color> confetti = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: _Colors.glassDark, // --glass-bg rgba(15, 23, 42, 0.92)
    border: _Colors.borderDark, // --glass-border
    card: Color(0x991E293B), // dark:bg-slate-800/60 step cards
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark, // #canvas-wrapper bg-[#1e293b]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber600,
    onAccent: _Colors.white,
    primary: _Colors.amber700,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500, // done steps (bg-emerald-500)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // shutter bg-slate-900
    curtainGlow: Color(0x6692400E), // from-amber-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber500,
    buttonBorder: Color(0x99D97706),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: _Colors.glassLight, // --glass-bg rgba(255, 255, 255, 0.95)
    border: _Colors.borderLight, // --glass-border
    card: _Colors.slate100, // bg-slate-100 step cards
    cardBorder: _Colors.slate200,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber600,
    onAccent: _Colors.white,
    primary: _Colors.amber700,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6692400E),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.amber700,
    buttonBorder: Color(0x99D97706),
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// shell-generic texts (Enter Lab, Select Scenario, Mission Objective,
// Success!, Step, the settings and canvas-tool names, the footer) come
// from the shell's `kLabCommonStrings`. `sN_title` / `sN_objective` are
// the scenario titles and objectives, `sN_hud_M` the HTML `hud` lines and
// `sN_concept_M` / `sN_action_M` / `sN_obs_M` the step cards; 'CLICK' /
// 'Click' / 'click' became 'TAP' / 'Tap' / 'tap' ('क्लिक' → 'टैप'). The
// summaries are split into their headline, intro and cards. Texts the HTML
// hard-codes in English (toasts, the magnifying-glass panel, the step
// cards' 'Collapse' / 'Switch to Step N', the buttons' tooltips) are
// marked "HTML literal" and get a Hindi translation; keys marked "Added."
// are new. Unused: `s1_popup_btn` (no button shows it) and the HTML
// `concept_focus` ('Task', never drawn).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Soil, Rocks, and Minerals: Composition and Uses',
    'app_subtitle': "Class 6 . Nature's Treasures",
    's1_title': 'Scenario 1: The Soil Investigator',
    's2_title': 'Scenario 2: The Stone Age Toolmaker',
    's1_objective':
        "To virtually collect and analyze two different soil samples (Ajji's forest edge vs ploughed farm) to understand that soil composition varies by location.",
    's2_objective':
        'To discover which type of rock is best for making a sharp tool, based on the examples of ancient tools in the textbook.',
    // HTML `hud` arrays.
    's1_hud_1':
        "Step 1: Tap the Shovel in the Forest Edge on the left (or '1. Forest Soil' button) to dig and place the forest soil bag on the lab table.",
    's1_hud_2':
        "Step 2: Tap the Shovel in the Ploughed Farm on the right (or '2. Farm Soil' button) to collect a farm soil sample bag.",
    's1_hud_3':
        "Step 3: Drag the Forest Soil bag onto the large Sieve (or tap '3. Sieve Forest') and shake to separate into humus, sand, pebbles & earthworm.",
    's1_hud_4':
        "Step 4: Drag the Farm Soil bag onto the Sieve (or tap '4. Sieve Farm') and shake to observe its different composition (high sand, low humus, no earthworm).",
    's1_hud_5':
        "Step 5: Tap '5. Inspect Lens' to inspect the trays with a magnifying glass and see the microscopic textures up close.",
    's1_hud_6':
        "Step 6: Tap 'Observe Conclusion' to summarize how soil differs across locations.",
    's2_hud_1':
        "Step 1: Drag the hard Hammerstone onto the dark Slate rock (or tap '1. Strike Slate') to test its cleavage property.",
    's2_hud_2':
        "Step 2: Drag the Hammerstone onto the yellowish Sandstone rock (or tap '2. Strike Sandstone') to test its strength.",
    's2_hud_3':
        "Step 3: Drag the Hammerstone onto the speckled Granite rock (or tap '3. Strike Granite') to produce a sharp flake tool.",
    's2_hud_4':
        "Step 4: Drag the sharp Granite flake across the wooden stick (or tap '4. Carve Wood') to shape and carve the wood.",
    's2_hud_5':
        "Step 5: Tap 'Observe Conclusion' to review what makes hard rocks ideal for Stone Age tools.",
    // HTML `steps`: concept, action and observation.
    's1_concept_1': 'Collect Forest Soil Sample',
    's1_action_1':
        'TAP on the Shovel in the forest (or button 1) to collect a soil sample and drag to table.',
    's1_obs_1':
        "Shovel digs into dark leaf litter! A bag labeled 'Forest Soil' appears on the lab table.",
    's1_concept_2': 'Collect Ploughed Farm Sample',
    's1_action_2':
        'TAP on the Shovel in the farm (or button 2) to collect a second soil sample.',
    's1_obs_2':
        "Shovel digs into lighter ploughed soil! A bag labeled 'Farm Soil' appears next to the first.",
    's1_concept_3': 'Sieve the Forest Soil',
    's1_action_3': "DRAG the 'Forest Soil' bag onto the sieve and tap SHAKE.",
    's1_obs_3':
        'Soil separates! Trays fill with a large pile of dark Humus, some Sand & Pebbles, and a live wiggling Earthworm!',
    's1_concept_4': 'Sieve the Farm Soil',
    's1_action_4': "DRAG the 'Farm Soil' bag onto the sieve and tap SHAKE.",
    's1_obs_4':
        'Stark difference! Farm soil yields a large pile of Sand, medium Pebbles, very little Humus, and NO earthworm.',
    's1_concept_5': 'Inspect with Magnifying Glass',
    's1_action_5': "TAP '5. Inspect Lens' to examine the trays closely.",
    's1_obs_5':
        'Zoomed-in views reveal rich organic leaf compost in forest humus versus crystalline sand particles in farm soil.',
    's1_concept_6': 'Conclusion & Comparison',
    's1_action_6': "TAP 'Observe Conclusion'.",
    's1_obs_6':
        'Forest soil has high humus & earthworms (fertile), while farm soil has more sand and pebbles. Composition varies by location!',
    's2_concept_1': 'Strike the Slate Rock',
    's2_action_1': 'DRAG Hammerstone onto Slate rock (or button 1).',
    's2_obs_1':
        'Slate splits cleanly along cleavage planes into thin flat tiles! Good for roofing, but too brittle for sharp tools.',
    's2_concept_2': 'Strike the Sandstone Rock',
    's2_action_2': 'DRAG Hammerstone onto Sandstone rock (or button 2).',
    's2_obs_2':
        'Sandstone disintegrates and crumbles easily into loose sand grains! Too weak and soft for cutting tools.',
    's2_concept_3': 'Strike the Granite Rock',
    's2_action_3': 'DRAG Hammerstone onto Granite rock (or button 3).',
    's2_obs_3':
        "'Clink!' Hard speckled Granite chips off cleanly at an angle, producing a sharp-edged flake (Stone Age hand axe)!",
    's2_concept_4': 'Carve Wood with Sharp Flake',
    's2_action_4':
        'DRAG sharp Granite flake across the wooden plank (or button 4).',
    's2_obs_4':
        'Success! The sharp stone edge curls up wood shavings and carves deep notches smoothly without breaking!',
    's2_concept_5': 'Toolmaker Conclusion',
    's2_action_5': "TAP 'Observe Conclusion'.",
    's2_obs_5':
        'Different rocks have unique physical properties: Slate splits, Sandstone crumbles, and Granite flakes sharp and durable.',
    // HTML `summary` blocks.
    's1_sum_head': 'Soil Investigation Verified!',
    's1_sum_intro':
        'You separated soil components using a sieve and discovered:',
    's1_sum_forest_title': "🌲 Forest Soil (Ajji's Edge)",
    's1_sum_forest':
        'High Humus (decaying leaves) & living Earthworms. Extremely fertile and retains water/nutrients naturally!',
    's1_sum_farm_title': '🚜 Ploughed Farm Soil',
    's1_sum_farm':
        'High Sand & Pebbles, low humus, and no earthworms. Needs manure/compost to restore fertility!',
    's2_sum_head': 'Stone Age Toolmaker Mastery!',
    's2_sum_intro':
        'You tested how different rocks react to impact and learned why ancient humans selected specific stones:',
    's2_sum_slate_title': '🪨 Slate',
    's2_sum_slate':
        'Splits into flat layers. Excellent for roofing tiles and slates, not cutting tools.',
    's2_sum_sandstone_title': '🏜️ Sandstone',
    's2_sum_sandstone':
        'Crumbles into sand. Used for carving statues and building pillars.',
    's2_sum_granite_title': '🪓 Granite / Flint',
    's2_sum_granite':
        'Chips into razor-sharp flakes! Ideal for durable Stone Age hand axes and knives.',
    // HTML `i18n`.
    'concept_exp': 'Observation Step',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You successfully explored soil differences between forest and farm soils, and discovered how ancient humans used hard rocks like Granite to craft sharp, durable stone tools!',
    'btn_conclude': 'Observe Conclusion',
    'controls': 'Controls',
    'inspect_title': 'Magnifying Glass Inspection: Sieve Trays Up Close',
    's1_btn_1': '1. Forest Soil',
    's1_btn_2': '2. Farm Soil',
    's1_btn_3': '3. Sieve Forest',
    's1_btn_4': '4. Sieve Farm',
    's1_btn_5': '5. Inspect Lens',
    's2_btn_1': '1. Strike Slate',
    's2_btn_2': '2. Strike Sandstone',
    's2_btn_3': '3. Strike Granite',
    's2_btn_4': '4. Carve Wood',
    'lbl_forest_edge': '🌲 Forest Edge Soil',
    'lbl_ploughed_farm': '🚜 Ploughed Farm Soil',
    'lbl_sieve': '🔬 Lab Separation Sieve',
    'lbl_humus_tray': 'Humus Tray',
    'lbl_sand_tray': 'Sand Tray',
    'lbl_pebbles_tray': 'Pebbles Tray',
    'lbl_earthworm_tray': 'Earthworm Tray',
    'lbl_forest_bag': '🛍️ Forest Soil Bag',
    'lbl_farm_bag': '🛍️ Farm Soil Bag',
    'lbl_granite_flake': '🪓 Sharp Hand Axe',
    'lbl_slate': '🪨 Slate Rock',
    'lbl_sandstone': '🏜️ Sandstone Rock',
    'lbl_granite': '💎 Granite Rock',
    'lbl_hammerstone': '🔨 Hammerstone Tool',
    'lbl_wood_piece': '🪵 Wooden Carving Plank',
    's1_popup_msg':
        'Scenario 1 Complete! Please select the next scenario from the sidebar menu.',
    // HTML `triggerConclusion`: `s1_popup_msg` with 1 → 2.
    's2_popup_msg':
        'Scenario 2 Complete! Please select the next scenario from the sidebar menu.',
    // HTML literal: `showToast` messages.
    'toast_forest_dug': 'Forest Soil collected and placed on lab table!',
    'toast_farm_dug':
        'Ploughed Farm Soil collected and placed next to Forest Soil!',
    'toast_need_forest': 'Please collect Forest Soil first (Step 1)!',
    'toast_forest_sieved':
        'Forest Soil sieved! Notice the high Humus and live Earthworm!',
    'toast_need_farm': 'Please collect Farm Soil first (Step 2)!',
    'toast_farm_sieved':
        'Farm Soil sieved! Notice the high Sand/Pebbles and zero Earthworms!',
    'toast_slate': 'Slate breaks into thin flat pieces along cleavage planes!',
    'toast_sandstone': 'Sandstone crumbles into loose sand grains!',
    'toast_granite':
        'Clink! A sharp, durable wedge flake (Stone Age hand axe) breaks off from Granite!',
    'toast_need_granite':
        'Please strike Granite first to get a sharp flake tool!',
    'toast_carved':
        'Success! The sharp Granite hand axe carves deep grooves and wood shavings!',
    'toast_reset': 'Lab completely reset to new activity state!',
    // HTML literal: the magnifying-glass panel (`#inspect-modal`).
    'insp_done': 'Complete Inspection',
    'insp_text_1': 'Notice the stark difference in composition! ',
    'insp_forest': 'Forest soil',
    'insp_text_2':
        ' is dark, rich in decaying leaves (humus) and earthworms that make it fertile. ',
    'insp_farm': 'Farm soil',
    'insp_text_3':
        ' has lighter particles with much more sand and pebbles, and very little organic matter.',
    'insp_humus_title': '1. Humus Tray',
    'insp_humus':
        'High volume of dark rotted leaves, plant roots, and organic matter in Forest Soil.',
    'insp_sand_title': '2. Sand Tray',
    'insp_sand':
        'Fine crystalline quartz grains. Farm soil contains a much larger pile of loose sand.',
    'insp_pebbles_title': '3. Pebbles Tray',
    'insp_pebbles':
        'Water-worn rock fragments and small gravel. Found in moderate amounts in both soils.',
    'insp_worm_title': '4. Earthworm Tray',
    'insp_worm':
        'Found exclusively in fertile Forest Soil! Earthworms loosen and aerate the earth.',
    'badge_zoom': '10x',
    'badge_live': 'Live',
    // HTML literal: the step cards.
    'collapse': 'Collapse',
    'switch_step': 'Switch to Step {n}',
    // HTML literal: the Controls buttons' `title` tooltips.
    's1_tip_1': 'Dig and collect forest soil sample',
    's1_tip_2': 'Dig and collect farm soil sample',
    's1_tip_3': 'Shake and sieve forest soil into trays',
    's1_tip_4': 'Shake and sieve farm soil into trays',
    's1_tip_5': 'Inspect separated components with magnifying glass',
    's2_tip_1': 'Strike Slate with Hammerstone',
    's2_tip_2': 'Strike Sandstone with Hammerstone',
    's2_tip_3': 'Strike Granite with Hammerstone to flake a tool',
    's2_tip_4': 'Carve wood using the sharp granite flake',
    // Added: screen-reader names of the shovels (the HTML gives them no
    // label) and of the two scenes.
    'sem_forest_shovel': 'Forest shovel',
    'sem_farm_shovel': 'Farm shovel',
    'scene_s1':
        'A lab table between a forest edge plot with two pine trees and a ploughed farm plot with furrows, a shovel in each plot, a sieve tower in the middle and two rows of four trays in front: humus, sand, pebbles and earthworm',
    'scene_s2':
        'A Stone Age workshop table with a dark slate rock, a yellowish sandstone rock and a speckled granite rock, a hammerstone tool and a wooden carving plank',
  },
  'hi': {
    'app_title': 'मिट्टी, चट्टानें और खनिज: संरचना और उपयोग',
    'app_subtitle': 'कक्षा 6 . प्रकृति का खजाना',
    's1_title': 'परिदृश्य 1: मिट्टी अन्वेषक (जंगल बनाम खेत की मिट्टी)',
    's2_title': 'परिदृश्य 2: पाषाण युग का औज़ार निर्माता',
    's1_objective':
        'दो अलग-अलग स्थानों (अज्जी के जंगल का किनारा और जुता हुआ खेत) से मिट्टी एकत्र कर यह जानना कि मिट्टी का संगठन स्थान-स्थान पर बदलता है।',
    's2_objective':
        'पाठ्यपुस्तक के उदाहरणों के आधार पर यह जानना कि कौन सी चट्टान नुकीले औज़ार (जैसे कुल्हाड़ी) बनाने के लिए सर्वोत्तम है।',
    's1_hud_1':
        'चरण 1: जंगल के किनारे फावड़े पर टैप करें (या बटन 1 दबाएं) और मिट्टी का थैला मेज पर लाएं।',
    's1_hud_2':
        'चरण 2: जुते हुए खेत में फावड़े पर टैप करें (या बटन 2 दबाएं) और दूसरा थैला मेज पर लाएं।',
    's1_hud_3':
        "चरण 3: 'जंगल की मिट्टी' के थैले को छलनी पर खींचें और ह्यूमस, रेत, कंकड़ व केंचुए अलग करें।",
    's1_hud_4':
        "चरण 4: 'खेत की मिट्टी' के थैले को छलनी पर खींचें और देखें कि इसमें रेत अधिक व ह्यूमस कम है।",
    's1_hud_5':
        "चरण 5: मैग्निफाइंग ग्लास द्वारा परतों को गहराई से देखने के लिए '5. सूक्ष्म लेंस' पर टैप करें।",
    's1_hud_6': "चरण 6: 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_1':
        "चरण 1: स्लेट चट्टान पर हथोड़ा पत्थर (Hammerstone) मारें (या '1. स्लेट पर चोट' दबाएं)।",
    's2_hud_2':
        "चरण 2: बलुआ पत्थर (Sandstone) पर हथोड़ा पत्थर मारें (या '2. बलुआ पत्थर चोट' दबाएं)।",
    's2_hud_3':
        "चरण 3: ग्रेनाइट चट्टान पर हथोड़ा पत्थर मारें (या '3. ग्रेनाइट पर चोट' दबाएं) और नुकीला टुकड़ा प्राप्त करें।",
    's2_hud_4':
        "चरण 4: नुकीले ग्रेनाइट टुकड़े से लकड़ी के टुकड़े को तराशें (या '4. लकड़ी तराशें' दबाएं)।",
    's2_hud_5': "चरण 5: 'निष्कर्ष देखें' पर टैप करें।",
    's1_concept_1': 'जंगल की मिट्टी एकत्र करना',
    's1_action_1': 'जंगल के किनारे फावड़े पर (या बटन 1) टैप करें।',
    's1_obs_1':
        "फावड़ा गहरी पत्तियों वाली मिट्टी में खुदाई करता है! मेज पर 'जंगल की मिट्टी' का थैला आ जाता है।",
    's1_concept_2': 'खेत की मिट्टी एकत्र करना',
    's1_action_2': 'खेत में फावड़े पर (या बटन 2) टैप करें।',
    's1_obs_2':
        "फावड़ा हल्की भूरी मिट्टी में खुदाई करता है! मेज पर 'खेत की मिट्टी' का दूसरा थैला आ जाता है।",
    's1_concept_3': 'जंगल की मिट्टी छानना',
    's1_action_3': 'जंगल की मिट्टी का थैला छलनी पर डालें और SHAKE दबाएं।',
    's1_obs_3':
        'छलनी हिलती है! ट्रे में अत्यधिक ह्यूमस (सड़ी पत्तियां), कुछ रेत-कंकड़ और जीवित केंचुआ आता है!',
    's1_concept_4': 'खेत की मिट्टी छानना',
    's1_action_4': 'खेत की मिट्टी का थैला छलनी पर डालें और SHAKE दबाएं।',
    's1_obs_4':
        'स्पष्ट अंतर! खेत की मिट्टी में रेत और कंकड़ बहुत अधिक आते हैं, ह्यूमस बहुत कम और केंचुआ नहीं होता।',
    's1_concept_5': 'मैग्निफाइंग ग्लास से निरीक्षण',
    's1_action_5': "'5. सूक्ष्म लेंस' पर टैप कर ट्रे का बारीक निरीक्षण करें।",
    's1_obs_5':
        'लेंस दिखाता है कि जंगल की मिट्टी में जैविक खाद और केंचुए हैं जबकि खेत की मिट्टी में रेत के कण अधिक हैं।',
    's1_concept_6': 'निष्कर्ष एवं तुलना',
    's1_action_6': "'निष्कर्ष देखें' पर टैप करें।",
    's1_obs_6':
        'जंगल की मिट्टी ह्यूमस व जीवों के कारण उपजाऊ है, जबकि खेत की मिट्टी में रेत अधिक है। मिट्टी स्थान के अनुसार बदलती है!',
    's2_concept_1': 'स्लेट चट्टान पर चोट',
    's2_action_1': 'स्लेट पर हथोड़ा पत्थर मारें (या बटन 1)।',
    's2_obs_1':
        'स्लेट पतली, चपटी परतों में टूट जाती है! यह छत बनाने के लिए अच्छी है पर नुकीले औज़ार के लिए नहीं।',
    's2_concept_2': 'बलुआ पत्थर पर चोट',
    's2_action_2': 'बलुआ पत्थर पर हथोड़ा पत्थर मारें (या बटन 2)।',
    's2_obs_2':
        'बलुआ पत्थर टूटकर भुरभुरी रेत में बदल जाता है! यह बहुत कमजोर है और औज़ार के लिए उपयुक्त नहीं है।',
    's2_concept_3': 'ग्रेनाइट चट्टान पर चोट',
    's2_action_3': 'ग्रेनाइट पर हथोड़ा पत्थर मारें (या बटन 3)।',
    's2_obs_3':
        "'क्लिंक!' अत्यधिक कठोर ग्रेनाइट से एक तेज धार वाला मजबूत टुकड़ा (पाषाण युग की कुल्हाड़ी) अलग होता है!",
    's2_concept_4': 'नुकीले टुकड़े से लकड़ी तराशना',
    's2_action_4': 'नुकीले ग्रेनाइट से लकड़ी तराशें (या बटन 4)।',
    's2_obs_4':
        'सफलता! ग्रेनाइट का नुकीला किनारा लकड़ी को आसानी से काटता है और लकड़ी के छिलके उतार देता है!',
    's2_concept_5': 'औज़ार निर्माता निष्कर्ष',
    's2_action_5': "'निष्कर्ष देखें' पर टैप करें।",
    's2_obs_5':
        'विभिन्न चट्टानों के गुण अलग होते हैं: स्लेट परतदार है, बलुआ भुरभुरा है और ग्रेनाइट कठोर व धारदार है।',
    's1_sum_head': 'मिट्टी अन्वेषण पूर्ण!',
    's1_sum_intro': 'छलनी से छानने पर आपको दो प्रकार की मिट्टी के गुण पता चले:',
    's1_sum_forest_title': '🌲 जंगल की मिट्टी',
    's1_sum_forest':
        'अत्यधिक ह्यूमस (सड़ी पत्तियां) और जीवित केंचुए। यह प्राकृतिक रूप से बहुत उपजाऊ और नमी रोकने वाली होती है!',
    's1_sum_farm_title': '🚜 जुते हुए खेत की मिट्टी',
    's1_sum_farm':
        'रेत और कंकड़ अधिक, ह्यूमस कम और केंचुए नहीं। इसे उपजाऊ बनाने के लिए खाद की आवश्यकता होती है!',
    's2_sum_head': 'पाषाण युग औज़ार निर्माता सफल!',
    's2_sum_intro':
        'आपने जाना कि चट्टानों के भौतिक गुण उनके उपयोग को कैसे तय करते हैं:',
    's2_sum_slate_title': '🪨 स्लेट',
    's2_sum_slate':
        'पतली परतों में टूटती है। छत की टाइलें और लिखने की स्लेट बनाने के काम आती है।',
    's2_sum_sandstone_title': '🏜️ बलुआ पत्थर',
    's2_sum_sandstone':
        'रेत में टूटता है। इमारतें और मूर्तियां बनाने के काम आता है।',
    's2_sum_granite_title': '🪓 ग्रेनाइट / फ्लिंट',
    's2_sum_granite':
        'नुकीली धार के साथ टूटता है! पाषाण युग की कुल्हाड़ी और चाकू बनाने के लिए सर्वोत्तम।',
    'concept_exp': 'अवलोकन चरण',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने जाना कि जंगल और खेत की मिट्टी में क्या अंतर होता है और कैसे प्राचीन मानव ने ग्रेनाइट जैसी कठोर चट्टानों से नुकीले औज़ार बनाए!',
    'btn_conclude': 'निष्कर्ष देखें',
    'controls': 'नियंत्रण',
    'inspect_title': 'मैग्निफाइंग ग्लास द्वारा निरीक्षण: छलनी के नीचे की ट्रे',
    's1_btn_1': '1. जंगल की मिट्टी',
    's1_btn_2': '2. खेत की मिट्टी',
    's1_btn_3': '3. जंगल मिट्टी छानें',
    's1_btn_4': '4. खेत मिट्टी छानें',
    's1_btn_5': '5. सूक्ष्म लेंस',
    's2_btn_1': '1. स्लेट पर चोट',
    's2_btn_2': '2. बलुआ पत्थर चोट',
    's2_btn_3': '3. ग्रेनाइट पर चोट',
    's2_btn_4': '4. लकड़ी तराशें',
    'lbl_forest_edge': '🌲 जंगल की मिट्टी क्षेत्र',
    'lbl_ploughed_farm': '🚜 खेत की मिट्टी क्षेत्र',
    'lbl_sieve': '🔬 प्रयोगशाला की छलनी',
    'lbl_humus_tray': 'ह्यूमस ट्रे',
    'lbl_sand_tray': 'रेत ट्रे',
    'lbl_pebbles_tray': 'कंकड़ ट्रे',
    'lbl_earthworm_tray': 'केंचुआ ट्रे',
    'lbl_forest_bag': '🛍️ जंगल की मिट्टी की थैली',
    'lbl_farm_bag': '🛍️ खेत की मिट्टी की थैली',
    'lbl_granite_flake': '🪓 नुकीली कुल्हाड़ी (हैंड एक्स)',
    'lbl_slate': '🪨 स्लेट चट्टान',
    'lbl_sandstone': '🏜️ बलुआ पत्थर',
    'lbl_granite': '💎 ग्रेनाइट चट्टान',
    'lbl_hammerstone': '🔨 हथौड़ा पत्थर',
    'lbl_wood_piece': '🪵 लकड़ी का टुकड़ा',
    's1_popup_msg':
        'परिदृश्य 1 पूर्ण! कृपया साइडबार मेनू से अगला परिदृश्य चुनें।',
    's2_popup_msg':
        'परिदृश्य 2 पूर्ण! कृपया साइडबार मेनू से अगला परिदृश्य चुनें।',
    // Added: Hindi for the HTML literals (English only in the HTML).
    'toast_forest_dug':
        'जंगल की मिट्टी एकत्र कर प्रयोगशाला की मेज पर रख दी गई!',
    'toast_farm_dug':
        'जुते हुए खेत की मिट्टी एकत्र कर जंगल की मिट्टी के पास रख दी गई!',
    'toast_need_forest': 'कृपया पहले जंगल की मिट्टी एकत्र करें (चरण 1)!',
    'toast_forest_sieved':
        'जंगल की मिट्टी छान ली गई! अधिक ह्यूमस और जीवित केंचुए पर ध्यान दें!',
    'toast_need_farm': 'कृपया पहले खेत की मिट्टी एकत्र करें (चरण 2)!',
    'toast_farm_sieved':
        'खेत की मिट्टी छान ली गई! अधिक रेत/कंकड़ और शून्य केंचुओं पर ध्यान दें!',
    'toast_slate':
        'स्लेट अपनी परतों के साथ पतले, चपटे टुकड़ों में टूट जाती है!',
    'toast_sandstone': 'बलुआ पत्थर भुरभुराकर रेत के ढीले कणों में बदल जाता है!',
    'toast_granite':
        'क्लिंक! ग्रेनाइट से एक नुकीला, मजबूत टुकड़ा (पाषाण युग की हाथ-कुल्हाड़ी) अलग हो जाता है!',
    'toast_need_granite':
        'नुकीला टुकड़ा पाने के लिए पहले ग्रेनाइट पर चोट करें!',
    'toast_carved':
        'सफलता! ग्रेनाइट की नुकीली कुल्हाड़ी लकड़ी में गहरी खांचें बनाती है और छिलके उतारती है!',
    'toast_reset': 'प्रयोगशाला पूरी तरह नई गतिविधि अवस्था में रीसेट हो गई!',
    'insp_done': 'निरीक्षण पूरा करें',
    'insp_text_1': 'संरचना में स्पष्ट अंतर पर ध्यान दें! ',
    'insp_forest': 'जंगल की मिट्टी',
    'insp_text_2':
        ' गहरे रंग की होती है, जिसमें सड़ती पत्तियां (ह्यूमस) और केंचुए भरपूर होते हैं जो इसे उपजाऊ बनाते हैं। ',
    'insp_farm': 'खेत की मिट्टी',
    'insp_text_3':
        ' में हल्के कण होते हैं, जिसमें रेत और कंकड़ बहुत अधिक और जैविक पदार्थ बहुत कम होते हैं।',
    'insp_humus_title': '1. ह्यूमस ट्रे',
    'insp_humus':
        'जंगल की मिट्टी में गहरी सड़ी पत्तियों, पौधों की जड़ों और जैविक पदार्थ की अधिक मात्रा।',
    'insp_sand_title': '2. रेत ट्रे',
    'insp_sand':
        'क्वार्ट्ज़ के बारीक क्रिस्टलीय कण। खेत की मिट्टी में ढीली रेत का कहीं बड़ा ढेर होता है।',
    'insp_pebbles_title': '3. कंकड़ ट्रे',
    'insp_pebbles':
        'पानी से घिसे चट्टान के टुकड़े और छोटी बजरी। दोनों मिट्टियों में मध्यम मात्रा में पाए जाते हैं।',
    'insp_worm_title': '4. केंचुआ ट्रे',
    'insp_worm':
        'केवल उपजाऊ जंगल की मिट्टी में पाए गए! केंचुए मिट्टी को भुरभुरा और हवादार बनाते हैं।',
    'badge_zoom': '10x',
    'badge_live': 'जीवित',
    'collapse': 'समेटें',
    'switch_step': 'चरण {n} पर जाएं',
    's1_tip_1': 'जंगल की मिट्टी का नमूना खोदकर एकत्र करें',
    's1_tip_2': 'खेत की मिट्टी का नमूना खोदकर एकत्र करें',
    's1_tip_3': 'जंगल की मिट्टी को हिलाकर ट्रे में छानें',
    's1_tip_4': 'खेत की मिट्टी को हिलाकर ट्रे में छानें',
    's1_tip_5': 'अलग हुए घटकों का मैग्निफाइंग ग्लास से निरीक्षण करें',
    's2_tip_1': 'हथौड़ा पत्थर से स्लेट पर चोट करें',
    's2_tip_2': 'हथौड़ा पत्थर से बलुआ पत्थर पर चोट करें',
    's2_tip_3':
        'औज़ार का टुकड़ा निकालने के लिए हथौड़ा पत्थर से ग्रेनाइट पर चोट करें',
    's2_tip_4': 'नुकीले ग्रेनाइट टुकड़े से लकड़ी तराशें',
    // Added.
    'sem_forest_shovel': 'जंगल का फावड़ा',
    'sem_farm_shovel': 'खेत का फावड़ा',
    'scene_s1':
        'जंगल के किनारे के क्षेत्र (दो चीड़ के पेड़) और जुते हुए खेत (कूंड़ और अंकुर) के बीच एक प्रयोगशाला मेज, हर क्षेत्र में एक फावड़ा, बीच में छलनी का स्टैंड और सामने चार-चार ट्रे की दो पंक्तियां: ह्यूमस, रेत, कंकड़ और केंचुआ',
    'scene_s2':
        'पाषाण युग की कार्यशाला की मेज पर गहरे रंग की स्लेट चट्टान, पीला बलुआ पत्थर, धब्बेदार ग्रेनाइट चट्टान, एक हथौड़ा पत्थर और लकड़ी का एक तख्ता',
  },
};

/// Number of scenarios and the steps of each (the HTML `steps` arrays).
const int _scenarioCount = 2;
const List<int> _stepCounts = [6, 5];

/// One step card's texts (HTML `steps: [{id, concept, action,
/// observation}]`).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.concept,
    required this.action,
    required this.observation,
  });

  final String concept;
  final String action;
  final String observation;
}

/// The step cards of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCounts[index]; i++)
      _StepInfo(
        concept: t('s${n}_concept_$i'),
        action: t('s${n}_action_$i'),
        observation: t('s${n}_obs_$i'),
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
        title: t('s${n}_title'),
        objective: t('s${n}_objective'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(
              concept: s.concept,
              action: s.action,
              observation: s.observation,
            ),
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
/// (0, 6.2, 11) looking at `controls.target` (0, 0.6, 0.8) in Scenario 1
/// and at (0, 5.8, 10.5) looking at (0, 0.6, 0.5) in Scenario 2.
const double _fovDegrees = 45;
const double _near = 0.1;
const _View _viewS1 = _View(_V(0, 6.2, 11), _V(0, 0.6, 0.8));
const _View _viewS2 = _View(_V(0, 5.8, 10.5), _V(0, 0.6, 0.5));

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a bag, the hammerstone or the flake (short
/// drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Chip padding as a share of the label size, and the gap (design px) kept
/// between two tray chips side by side.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;
const double _chipGap = 4;

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

/// Nothing closer to the camera plane than this is drawn.
const double _clipDepth = 0.5;

// ------------------------------------------------- scenario 1: soil table

/// Lab table `BoxGeometry(8, 0.4, 7)` at (0, -0.2, 0.5).
const _V _table1 = _V(0, -0.2, 0.5);
const _V _table1Size = _V(8, 0.4, 7);

/// Forest edge and ploughed farm plots `BoxGeometry(3.5, 0.3, 5)` at
/// (∓6, -0.15, -1); their text sprites 2.2 above.
const _V _forestPlot = _V(-6, -0.15, -1);
const _V _farmPlot = _V(6, -0.15, -1);
const _V _plotSize = _V(3.5, 0.3, 5);
const _V _plotLabelAt = _V(0, 2.2, 0);

/// Pine trunks `CylinderGeometry(0.15, 0.2, 1.2)` at (-0.8 + 1.4 i, 0.6,
/// -1.5) of the forest plot; their cones `ConeGeometry(0.8, 2, 8)` 1.2
/// above the trunks' centres.
const List<double> _pineXs = [-0.8, 0.6];
const double _pineZ = -1.5;
const double _trunkY = 0.6;
const double _trunkTop = 0.15;
const double _trunkBottom = 0.2;
const double _trunkH = 1.2;
const double _coneLift = 1.2;
const double _coneR = 0.8;
const double _coneH = 2;

/// Furrows `CylinderGeometry(0.1, 0.1, 4.5)` lying along z at (-1.2 +
/// 0.8 i, 0.2, 0) of the farm plot, each with a sprout
/// `ConeGeometry(0.08, 0.3, 6)` at (-1.2 + 0.8 i, 0.35, -0.5 + 0.8 (i % 2)).
const int _furrowCount = 4;
const double _furrowR = 0.1;
const double _furrowLen = 4.5;
const double _furrowY = 0.2;
const double _sproutR = 0.08;
const double _sproutH = 0.3;
const double _sproutY = 0.35;

/// Shovels at (∓6, 0.6, 0.5): blade `BoxGeometry(0.5, 0.6, 0.06)` 0.3 up,
/// shaft `CylinderGeometry(0.06, 0.06, 1.4)` 1.1 up, grip
/// `BoxGeometry(0.4, 0.12, 0.12)` 1.8 up. Digging rocks it (`rotation.z`
/// → ±0.3, 250 ms, yoyo, repeat 3).
const _V _forestShovelHome = _V(-6, 0.6, 0.5);
const _V _farmShovelHome = _V(6, 0.6, 0.5);
const double _digTurn = 0.3;
const double _digLeg = 0.25;
const int _digLegs = 4;

/// Soil bags appear at (∓6, 0.4, -2.5), pop from scale 0.1 to 1 (500 ms,
/// `Back.Out`) and, after 300 ms, slide to the table at (∓2.5, 0.5, -0.2)
/// (800 ms, `Cubic.Out`). Their text sprite is 1.95 above.
const _V _forestBagHome = _V(-6, 0.4, -2.5);
const _V _farmBagHome = _V(6, 0.4, -2.5);
const _V _forestBagTable = _V(-2.5, 0.5, -0.2);
const _V _farmBagTable = _V(2.5, 0.5, -0.2);
const double _bagPopSeconds = 0.5;
const double _bagStartScale = 0.1;
const double _bagSlideDelay = 0.3;
const double _bagSlideSeconds = 0.8;
const _V _bagLabelAt = _V(0, 1.95, 0);

/// Sieving: the bag rises over the sieve to (0, 3.5, 0) (500 ms), tips by
/// ±π/3 (400 ms), the sieve shakes (`position.x` → ±0.2, 80 ms, yoyo,
/// repeat 10) and 800 ms later the bag is empty and the trays fill.
const _V _pourAt = _V(0, 3.5, 0);
const double _riseSeconds = 0.5;
const double _tipAngle = math.pi / 3;
const double _tipSeconds = 0.4;
const double _shakeOffset = 0.2;
const double _shakeLeg = 0.08;
const int _shakeLegs = 11;
const double _sieveSettle = 0.8;

/// Sieve tower at (0, 2.4, -0.5): legs `CylinderGeometry(0.06, 0.06, 2.2)`
/// at (±1.8, -1.1, 0), a base ring `TorusGeometry(1.8, 0.06)` at y -0.3,
/// the coarse tier (rim r 1.6, h 0.35, mesh r 1.58 at -0.15, brass
/// handles `TorusGeometry(0.2, 0.04)` at x ±1.65) at y 0.25, the fine tier
/// (rim r 1.56, mesh r 1.54) at y -0.1 and the funnel
/// `ConeGeometry(1.54, 0.6)` upside down at y -0.55. Its text sprite is
/// 1.15 above.
const _V _sieveHome = _V(0, 2.4, -0.5);
const double _legX = 1.8;
const double _legR = 0.06;
const double _legH = 2.2;
const double _baseRingY = -0.3;
const double _baseRingR = 1.8;
const double _thinTube = 0.06;
const double _topTierY = 0.25;
const double _topRimR = 1.6;
const double _midTierY = -0.1;
const double _midRimR = 1.56;
const double _tierH = 0.35;
const double _meshDrop = -0.15;
const double _topMeshR = 1.58;
const double _midMeshR = 1.54;
const double _handleX = 1.65;
const double _handleR = 0.2;
const double _handleTube = 0.04;
const double _funnelY = -0.55;
const double _funnelR = 1.54;
const double _funnelH = 0.6;
const _V _sieveLabelAt = _V(0, 1.15, 0);

/// Trays `BoxGeometry(1.6, 0.08, 1.2)` with 0.18-high rims at x -2.8,
/// -0.9, 0.9, 2.8: forest soil at z 1.2, farm soil at z 2.8, y 0.05. Their
/// contents sit 0.12 up; the text sprites 0.85 up.
const List<double> _trayXs = [-2.8, -0.9, 0.9, 2.8];
const double _trayY = 0.05;
const double _forestRowZ = 1.2;
const double _farmRowZ = 2.8;
const double _trayW = 1.6;
const double _trayD = 1.2;
const _V _traySize = _V(_trayW, 0.08, _trayD);
const double _rimH = 0.18;
const double _rimT = 0.06;
const double _contentY = 0.12;
const double _trayLabelY = 0.85;

/// Sieved heights (`content.scale.y`): humus 1.5, sand 0.5, pebbles 0.6
/// from the forest soil; humus 0.3, sand 1.6, pebbles 1.3 from the farm.
const List<double> _forestFill = [1.5, 0.5, 0.6];
const List<double> _farmFill = [0.3, 1.6, 1.3];

/// Earthworm `TorusGeometry(0.3, 0.08, 8, 16, 1.5π)` lying in tray 4 of
/// the forest row at (2.8, 0.25, 1.2); it bobs (y = 0.25 + 0.08 sin(6 t))
/// and wriggles (`rotation.z` = 0.2 sin(8 t)).
const _V _wormAt = _V(2.8, 0.25, 1.2);
const double _wormR = 0.3;
const double _wormTube = 0.08;
const double _wormBob = 0.08;
const double _wormBobRate = 6;
const double _wormSway = 0.2;
const double _wormSwayRate = 8;

/// HTML drag: the held object rides 0.4 above its height; a release that
/// moved it less than 0.4 is a click.
const double _liftY = 0.4;
const double _clickMove = 0.4;

/// Hit-test ranking (design px): a hand tool under the finger beats what
/// lies under it; a hidden bag loses to anything shown.
const double _toolBonus = 1e4;
const double _hiddenPenalty = 1e3;

/// Shovels dropped somewhere else go back home (added; 250 ms).
const double _homeSeconds = 0.25;

/// Where a held object may go (on and around the table).
const double _s1DragHalfX = 8;
const double _s1DragBack = -3.6;
const double _s1DragFront = 5;

// ------------------------------------------- scenario 2: Stone Age workshop

/// Workshop table `BoxGeometry(12, 0.5, 7)` at (0, -0.25, 0.5).
const _V _table2 = _V(0, -0.25, 0.5);
const _V _table2Size = _V(12, 0.5, 7);

/// Rocks at y 0.8, z -1.2: slate `BoxGeometry(1.8, 1.2, 1.6)` at x -4.5,
/// sandstone and granite `DodecahedronGeometry(0.9, 1)` at x 0 and 4.5.
/// Their text sprites are 1.3 above.
const _V _slateAt = _V(-4.5, 0.8, -1.2);
const _V _sandstoneAt = _V(0, 0.8, -1.2);
const _V _graniteAt = _V(4.5, 0.8, -1.2);
const _V _slateSize = _V(1.8, 1.2, 1.6);
const double _rockR = 0.9;
const _V _rockLabelAt = _V(0, 1.3, 0);

/// Granite specks `BoxGeometry(0.18, 0.18, 0.18)` (12).
const int _speckCount = 12;
const double _speckSize = 0.18;

/// Hammerstone at (-6.5, 0.8, 1): head `SphereGeometry(0.55)` scaled
/// (1.2, 0.8, 1), handle `CylinderGeometry(0.12, 0.12, 1.4)` lying along z,
/// centred 0.8 in front of the head. Text sprite 1.1 above.
const _V _hammerHome = _V(-6.5, 0.8, 1);
const double _headR = 0.55;
const _V _headScale = _V(1.2, 0.8, 1);
const double _handleRadius = 0.12;
const double _handleLen = 1.4;
const double _handleZ = 0.8;
const _V _hammerLabelAt = _V(0, 1.1, 0);

/// A strike: the hammerstone rises over the rock to y 2.2 (350 ms), drops
/// to y 0.9 (1.1 on granite; 150 ms), the rock breaks and the hammerstone
/// rests in front of it at (x, 1.2, 0.8) (400 ms).
const double _raiseY = 2.2;
const double _hitY = 0.9;
const double _graniteHitY = 1.1;
const double _restY = 1.2;
const double _restZ = 0.8;
const double _raiseSeconds = 0.35;
const double _dropSeconds = 0.15;
const double _restSeconds = 0.4;

/// HTML drop test: the hammerstone within 3.2 of a rock, the flake within
/// 4.5 of the plank; otherwise they go back (300 ms).
const double _strikeRange = 3.2;
const double _carveRange = 4.5;
const double _backSeconds = 0.3;

/// Slate splits into four `BoxGeometry(1.8, 0.18, 1.6)` tiles at (-4.5,
/// 0.2 + 0.15 i, -1.2 + 0.3 (i - 1.5)).
const int _tileCount = 4;
const double _tileH = 0.18;

/// Sandstone crumbles into 35 grains `BoxGeometry(0.16, 0.16, 0.16)`
/// within 1.8 x 0.4 x 1.8 around it.
const int _grainCount = 35;
const double _grainSize = 0.16;

/// Granite flake `ConeGeometry(0.5, 1.2, 4)` lying point forward
/// (`rotation.x = π/2`); it breaks off at the granite and slides to (3.2,
/// 0.5, 0.8) (600 ms, `Cubic.Out`). Its text sprite: added above it (the
/// HTML's, a child of the turned flake, sat in front of it).
const double _flakeR = 0.5;
const double _flakeH = 1.2;
const _V _flakeRest = _V(3.2, 0.5, 0.8);
const double _flakeSeconds = 0.6;
const _V _flakeLabelAt = _V(0, 0.75, 0);

/// Wooden plank `BoxGeometry(3, 0.4, 0.8)` at (1.5, 0.25, 1.8), carved
/// down to scale (0.9, 0.85, 0.9); text sprite 0.9 above.
const _V _plankAt = _V(1.5, 0.25, 1.8);
const _V _plankSize = _V(3, 0.4, 0.8);
const _V _carvedScale = _V(0.9, 0.85, 0.9);
const _V _plankLabelAt = _V(0, 0.9, 0);

/// Carving: the flake moves to (0.3, 0.65, 1.8) (350 ms, `Cubic.Out`),
/// saws along x to 2.7 (180 ms, yoyo, repeat 5), then rests at (2.4, 0.55,
/// 1.8); 15 shavings `TorusGeometry(0.12, 0.03, 6, 12, 1.2π)` lie on the
/// plank.
const _V _carveStart = _V(0.3, 0.65, 1.8);
const double _sawX = 2.7;
const double _carveMoveSeconds = 0.35;
const double _sawLeg = 0.18;
const int _sawLegs = 6;
const _V _flakeDone = _V(2.4, 0.55, 1.8);
const int _shavingCount = 15;

/// Where a held object may go in the workshop.
const double _s2DragHalfX = 7.5;
const double _s2DragBack = -3;
const double _s2DragFront = 4.5;

// ---------------------------------------------------------------- the end

/// HTML `progressStep()`: at the last step 'Observe Conclusion' appears and
/// 800 ms later the summary opens.
const Duration _autoConcludeDelay = Duration(milliseconds: 800);

/// canvas-confetti (`particleCount: 80, spread: 70, origin: {y: 0.6}`):
/// 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 80;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 336);

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
  double distanceTo(_V o) => (this - o).length;

  /// Component-wise product (a mesh scale).
  _V times(_V o) => _V(x * o.x, y * o.y, z * o.z);
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

  /// This frame scaled along its own axes.
  _Xf scaled(_V s) => _Xf(o, x * s.x, y * s.y, z * s.z);
}

/// HTML `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = 1 - t;
  return 1 - k * k * k;
}

/// HTML `TWEEN.Easing.Back.Out`.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// A camera pose: HTML `camera.position` and `controls.target`.
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;
}

/// Where the look-at point lands on the stage and how much the scene is
/// enlarged (the HTML camera is [base]). The scene is fitted into the part
/// of the canvas no card covers.
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
  factory _Cam(_View view, _Framing framing) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      view.eye,
      f,
      r,
      r.cross(f),
      framing.center,
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
  /// (the HTML drag plane).
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

  /// Still moving at [time].
  bool busyAt(double time) =>
      _seconds > 0 && (time - _start) / _seconds < _legs;

  void set(double value) {
    _from = value;
    _to = value;
    _seconds = 0;
    _legs = 1;
  }

  /// Tweens from the current value to [to] over [seconds], starting after
  /// [delay]; [legs] > 1 plays it back and forth (HTML
  /// `.yoyo(true).repeat(legs - 1)`).
  void animate(
    double time,
    double to,
    double seconds, {
    int legs = 1,
    double delay = 0,
    double Function(double) ease = _linear,
  }) {
    _from = at(time);
    _to = to;
    _start = time + delay;
    _seconds = seconds;
    _legs = legs;
    _ease = ease;
  }
}

/// A tweened position (an HTML `TWEEN.Tween(obj.position)`).
class _Pos {
  _Pos(_V v) : x = _Track(v.x), y = _Track(v.y), z = _Track(v.z);

  final _Track x;
  final _Track y;
  final _Track z;

  _V at(double time) => _V(x.at(time), y.at(time), z.at(time));

  _V get target => _V(x.target, y.target, z.target);

  bool busyAt(double time) =>
      x.busyAt(time) || y.busyAt(time) || z.busyAt(time);

  void set(_V v) {
    x.set(v.x);
    y.set(v.y);
    z.set(v.z);
  }

  /// Tweens to [to] (every axis) over [seconds].
  void glide(
    double time,
    _V to,
    double seconds, {
    double delay = 0,
    double Function(double) ease = _linear,
  }) {
    x.animate(time, to.x, seconds, delay: delay, ease: ease);
    y.animate(time, to.y, seconds, delay: delay, ease: ease);
    z.animate(time, to.z, seconds, delay: delay, ease: ease);
  }
}

/// A burlap soil bag (HTML `createSoilBagModel`): shown once dug up, its
/// position, tip (`rotation.z`) and pop-in scale.
class _Bag {
  _Bag(this.home) : pos = _Pos(home);

  final _V home;
  final _Pos pos;
  final _Track tilt = _Track(0);
  final _Track scale = _Track(1);
  bool shown = false;

  void reset() {
    shown = false;
    pos.set(home);
    tilt.set(0);
    scale.set(1);
  }
}

/// The scene objects a finger can press (HTML raycast targets) or that
/// have a screen-reader node.
enum _Obj {
  forestShovel('sem_forest_shovel'),
  farmShovel('sem_farm_shovel'),
  forestBag('lbl_forest_bag'),
  farmBag('lbl_farm_bag'),
  sieve('lbl_sieve'),
  humusTray('lbl_humus_tray'),
  sandTray('lbl_sand_tray'),
  pebblesTray('lbl_pebbles_tray'),
  wormTray('lbl_earthworm_tray'),
  slate('lbl_slate'),
  sandstone('lbl_sandstone'),
  granite('lbl_granite'),
  hammer('lbl_hammerstone'),
  flake('lbl_granite_flake'),
  plank('lbl_wood_piece');

  const _Obj(this.nameKey);

  /// Its text sprite (or, for the shovels, its added screen-reader name).
  final String nameKey;

  /// The forest-row trays (HTML: a click on one opens the inspection).
  static const List<_Obj> trays = [humusTray, sandTray, pebblesTray, wormTray];

  /// Objects that follow the finger (HTML `draggedObject`).
  bool get draggable =>
      this == forestShovel ||
      this == farmShovel ||
      this == forestBag ||
      this == farmBag ||
      this == hammer ||
      this == flake;
}

/// One box-shaped bit (leaf, pebble, grain, tile, speck) of a tray content
/// or a rock: its centre, size, turn and colour.
@immutable
class _Bit {
  const _Bit(this.at, this.size, this.turn, this.color, {this.round = false});

  final _V at;
  final _V size;

  /// Euler angles (x, y, z).
  final _V turn;
  final Color color;

  /// Drawn as a small rounded stone (`DodecahedronGeometry`) of radius
  /// `size.x`.
  final bool round;
}

/// The random decorations of the HTML scene (`Math.random()` there), made
/// once with a fixed seed so every visit looks the same.
class _Decor {
  _Decor() {
    final rnd = math.Random(11);
    double r() => rnd.nextDouble();
    for (var row = 0; row < 2; row++) {
      leaves.add([
        for (var i = 0; i < 14; i++)
          _Bit(
            _V((r() - 0.5) * 1.1, 0.25 + r() * 0.12, (r() - 0.5) * 0.8),
            const _V(0.12, 0.02, 0.08),
            _V(r() * math.pi, r() * math.pi, 0),
            _Colors.leaf,
          ),
      ]);
      pebbles.add([
        for (var i = 0; i < 16; i++)
          if (i.isEven)
            _Bit(
              _V((r() - 0.5) * 1.1, 0.08 + (i % 3) * 0.1, (r() - 0.5) * 0.75),
              _V(0.16 + r() * 0.1, 0, 0),
              _V(r() * math.pi, r() * math.pi, r() * math.pi),
              _Colors.pebbles[i % _Colors.pebbles.length],
              round: true,
            )
          else
            _Bit(
              _V((r() - 0.5) * 1.1, 0.08 + (i % 3) * 0.1, (r() - 0.5) * 0.75),
              _V(0.2 + r() * 0.1, 0.15 + r() * 0.1, 0.2 + r() * 0.1),
              _V(r() * math.pi, r() * math.pi, r() * math.pi),
              _Colors.pebbles[i % _Colors.pebbles.length],
            ),
      ]);
      specks.add([
        for (var i = 0; i < 8; i++)
          _V((r() - 0.5) * 0.6, 1.45 + r() * 0.08, (r() - 0.5) * 0.6),
      ]);
    }
    for (var i = 0; i < _grainCount; i++) {
      grains.add(
        _V((r() - 0.5) * 1.8, r() * 0.4, _sandstoneAt.z + (r() - 0.5) * 1.8),
      );
    }
    for (var i = 0; i < _shavingCount; i++) {
      shavings.add((
        _V(
          _plankAt.x + (r() - 0.5) * 2.2,
          0.42 + r() * 0.15,
          _plankAt.z + (r() - 0.5) * 0.5,
        ),
        r() * math.pi * 2,
      ));
    }
    // Granite specks: the HTML scatters them through the rock; the ones on
    // its surface are what shows, so they are placed there.
    for (var i = 0; i < _speckCount; i++) {
      final a = r() * math.pi * 2;
      final b = math.acos(2 * r() - 1);
      specksOnGranite.add(
        _V(math.sin(b) * math.cos(a), math.cos(b), math.sin(b) * math.sin(a)) *
            (_rockR * 0.86),
      );
    }
  }

  /// Per row (forest, farm): humus leaves, pebbles, bag specks.
  final List<List<_Bit>> leaves = [];
  final List<List<_Bit>> pebbles = [];
  final List<List<_V>> specks = [];

  /// Sandstone grains, shavings (centre, turn) and granite specks.
  final List<_V> grains = [];
  final List<(_V, double)> shavings = [];
  final List<_V> specksOnGranite = [];
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

/// Mutable scene read by the painter every frame (HTML `State`, the
/// Three.js meshes and the running tweens).
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

  final _Decor decor = _Decor();

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// An action's animation is playing (added: the HTML let a second one
  /// start over it).
  bool busy = false;

  /// The summary was opened at the last step.
  bool reviewed = false;

  /// HTML `#inspect-modal` is open.
  bool inspecting = false;

  /// The last step was reached by playing (HTML `progressStep`): the
  /// summary opens by itself, after the inspection is closed.
  bool autoPending = false;

  /// Controls buttons not yet `used` (HTML `.inv-item.used`), by number.
  final Set<int> ready = {};

  // ------------------------------------------------------ scenario 1 state

  /// HTML `State.s1`.
  bool hasForest = false;
  bool hasFarm = false;
  bool forestSieved = false;
  bool farmSieved = false;
  bool inspected = false;

  final _Pos forestShovel = _Pos(_forestShovelHome);
  final _Pos farmShovel = _Pos(_farmShovelHome);
  final _Track forestDig = _Track(0);
  final _Track farmDig = _Track(0);
  final _Bag forestBag = _Bag(_forestBagHome);
  final _Bag farmBag = _Bag(_farmBagHome);

  /// The sieve's sideways shake (`sieveMesh.position.x`).
  final _Track sieveX = _Track(0);

  /// Tray contents' heights (`content.scale.y`; 0 = still empty): humus,
  /// sand, pebbles of the forest row, then of the farm row.
  final List<double> fill = List.filled(6, 0);

  /// The earthworm wriggles in the forest row's tray 4.
  bool worm = false;

  // ------------------------------------------------------ scenario 2 state

  /// HTML `State.s2`.
  bool slateStruck = false;
  bool sandstoneStruck = false;
  bool graniteStruck = false;
  bool carved = false;

  /// The slate has split and the sandstone crumbled (at the hammer's hit;
  /// HTML `rock.visible = false`), the plank shows its carving.
  bool slateBroken = false;
  bool sandstoneBroken = false;
  bool shaved = false;

  final _Pos hammer = _Pos(_hammerHome);
  final _Pos flake = _Pos(_graniteAt);
  bool flakeShown = false;

  // ---------------------------------------------------------------- shared

  /// The object the learner is holding (HTML `draggedObject`).
  _Obj? held;

  /// Scene time of the summary's confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// Pending events of the running sequence, in scene time (the HTML tween
  /// `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

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

  bool get soil => scenario == 0;

  int get lastStep => _stepCounts[scenario];

  _View get view => soil ? _viewS1 : _viewS2;

  /// HTML `changeScenario(sc)` → `resetScenarioState()`: every object back
  /// home, trays empty, rocks whole.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    reviewed = false;
    inspecting = false;
    autoPending = false;
    held = null;
    _cues.clear();
    confettiAt = -1;
    ready
      ..clear()
      ..addAll(index == 0 ? const [1, 2] : const [1]);
    hasForest = hasFarm = forestSieved = farmSieved = inspected = false;
    forestShovel.set(_forestShovelHome);
    farmShovel.set(_farmShovelHome);
    forestDig.set(0);
    farmDig.set(0);
    forestBag.reset();
    farmBag.reset();
    sieveX.set(0);
    fill.fillRange(0, fill.length, 0);
    worm = false;
    slateStruck = sandstoneStruck = graniteStruck = carved = false;
    slateBroken = sandstoneBroken = shaved = false;
    hammer.set(_hammerHome);
    flake.set(_graniteAt);
    flakeShown = false;
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

  /// HTML `animate()` + `TWEEN.update()`: the framing slide (the tweens
  /// are read at [time] by the painter).
  void advance(double dt) {
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

  /// The camera in the current framing.
  _Cam camera() => _Cam(view, framing);

  /// Has step [n] of this scenario already been done (out of turn)? The
  /// inspection and the conclusion only count when they are the current
  /// step.
  bool stepDone(int n) => soil
      ? switch (n) {
          1 => hasForest,
          2 => hasFarm,
          3 => forestSieved,
          4 => farmSieved,
          _ => false,
        }
      : switch (n) {
          1 => slateStruck,
          2 => sandstoneStruck,
          3 => graniteStruck,
          4 => carved,
          _ => false,
        };

  // ------------------------------------------------------------ geometry

  _Bag bagOf(_Obj o) => o == _Obj.forestBag ? forestBag : farmBag;

  /// The shovel group's frame: position and digging rock.
  _Xf shovelXf(bool forest) {
    final pos = (forest ? forestShovel : farmShovel).at(time);
    final dig = (forest ? forestDig : farmDig).at(time);
    return const _Xf.at(_V.zero).child(pos, rz: dig);
  }

  /// A bag group's frame: position, tip and pop-in scale.
  _Xf bagXf(_Bag b) {
    final k = b.scale.at(time);
    return const _Xf.at(
      _V.zero,
    ).child(b.pos.at(time), rz: b.tilt.at(time), sx: k, sy: k, sz: k);
  }

  /// The sieve tower's origin (with its shake).
  _V get sieveAt => _sieveHome + _V(sieveX.at(time), 0, 0);

  /// Centre of tray [i] (0–3) of [row] (0 forest, 1 farm).
  static _V trayAt(int row, int i) =>
      _V(_trayXs[i], _trayY, row == 0 ? _forestRowZ : _farmRowZ);

  /// The earthworm's frame: bobbing and wriggling.
  _Xf wormXf() {
    final y = _wormAt.y + math.sin(time * _wormBobRate) * _wormBob;
    final rz = math.sin(time * _wormSwayRate) * _wormSway;
    return const _Xf.at(_V.zero).child(_V(_wormAt.x, y, _wormAt.z), rz: rz);
  }

  /// The plank's scale (carved or not).
  _V get plankScale => shaved ? _carvedScale : const _V(1, 1, 1);

  /// Is [o] in the scene now?
  bool present(_Obj o) => switch (o) {
    _Obj.forestShovel || _Obj.farmShovel || _Obj.sieve => soil,
    _Obj.humusTray ||
    _Obj.sandTray ||
    _Obj.pebblesTray ||
    _Obj.wormTray => soil,
    _Obj.forestBag => soil && forestBag.shown,
    _Obj.farmBag => soil && farmBag.shown,
    _Obj.slate => !soil && !slateBroken,
    _Obj.sandstone => !soil && !sandstoneBroken,
    _Obj.granite || _Obj.hammer || _Obj.plank => !soil,
    _Obj.flake => !soil && flakeShown,
  };

  /// World bounding box of [o] as it is now.
  (_V, _V) boxOf(_Obj o) {
    (_V, _V) around(_V c, _V lo, _V hi) => (c + lo, c + hi);
    switch (o) {
      case _Obj.forestShovel || _Obj.farmShovel:
        final c = (o == _Obj.forestShovel ? forestShovel : farmShovel).at(time);
        return around(c, const _V(-0.3, 0, -0.1), const _V(0.3, 1.9, 0.1));
      case _Obj.forestBag || _Obj.farmBag:
        final b = bagOf(o);
        final k = b.scale.at(time);
        return around(
          b.pos.at(time),
          _V(-0.7 * k, 0, -0.7 * k),
          _V(0.7 * k, 1.55 * k, 0.7 * k),
        );
      case _Obj.sieve:
        return around(
          sieveAt,
          const _V(-1.9, -_legH, -1.7),
          const _V(1.9, 0.45, 1.7),
        );
      case _Obj.humusTray || _Obj.sandTray || _Obj.pebblesTray || _Obj.wormTray:
        final c = trayAt(0, _Obj.trays.indexOf(o));
        return around(
          c,
          const _V(-0.82, -0.04, -0.62),
          const _V(0.82, 0.3, 0.62),
        );
      case _Obj.slate:
        return around(_slateAt, _slateSize * -0.5, _slateSize * 0.5);
      case _Obj.sandstone:
        return around(
          _sandstoneAt,
          const _V(-_rockR, -_rockR, -_rockR),
          const _V(_rockR, _rockR, _rockR),
        );
      case _Obj.granite:
        return around(
          _graniteAt,
          const _V(-_rockR, -_rockR, -_rockR),
          const _V(_rockR, _rockR, _rockR),
        );
      case _Obj.hammer:
        return around(
          hammer.at(time),
          const _V(-0.66, -0.44, -0.55),
          const _V(0.66, 0.44, _handleZ + _handleLen / 2),
        );
      case _Obj.flake:
        return around(
          flake.at(time),
          const _V(-_flakeR, -_flakeR, -_flakeH / 2),
          const _V(_flakeR, _flakeR, _flakeH / 2),
        );
      case _Obj.plank:
        final half = _plankSize.times(plankScale) * 0.5;
        return around(_plankAt, -half, half);
    }
  }

  /// Screen rect of [o].
  Rect rectOf(_Obj o, _Cam cam) {
    final (min, max) = boxOf(o);
    return cam.boxRect(min, max);
  }

  /// The objects a finger can press now (HTML `onPointerDown` targets).
  /// A bag still waiting unseen at the back of its plot can be pressed
  /// too: the HTML raycast hit the hidden mesh and said to dig first.
  List<_Obj> get pressable => soil
      ? [
          _Obj.forestShovel,
          _Obj.farmShovel,
          if (forestBag.shown || !hasForest) _Obj.forestBag,
          if (farmBag.shown || !hasFarm) _Obj.farmBag,
          ..._Obj.trays,
        ]
      : [
          if (!slateBroken) _Obj.slate,
          if (!sandstoneBroken) _Obj.sandstone,
          _Obj.granite,
          _Obj.hammer,
          if (flakeShown) _Obj.flake,
          _Obj.plank,
        ];

  /// The object at [p] (HTML raycast): its drawn box or, on a small
  /// screen, within a finger's reach of its centre; the nearest centre
  /// wins, a hand tool (shovel, bag, hammerstone, flake) wins over what
  /// lies under it and a hidden bag only counts when nothing else is there.
  _Obj? objAt(Offset p, double touch) {
    final cam = camera();
    _Obj? best;
    var bestD = double.infinity;
    for (final o in pressable) {
      final r = rectOf(o, cam);
      final inside = r.contains(p);
      var d = (p - r.center).distance;
      if (!inside && d > touch) continue;
      if (!present(o)) {
        d += _hiddenPenalty;
      } else if (o.draggable && inside) {
        d -= _toolBonus;
      }
      if (d < bestD) {
        best = o;
        bestD = d;
      }
    }
    return best;
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
  return _Framing(rect.center - extent(zoom).center, zoom);
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a scene object ([canGrab]), so other drags still pan / zoom the
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

/// One button of the HTML 'Controls' bar.
@immutable
class _ControlButton {
  const _ControlButton({
    required this.label,
    required this.tip,
    required this.icon,
    required this.color,
    required this.inkDark,
    required this.inkLight,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String tip;
  final IconData icon;

  /// Tailwind colour of its tint and border (`bg-*-500/10`, `border-*-500/30`)
  /// and of its text (`text-*-600 dark:text-*-400`).
  final Color color;
  final Color inkDark;
  final Color inkLight;

  /// Not `used` yet (HTML `.inv-item.used`: dimmed, no clicks).
  final bool enabled;
  final VoidCallback onTap;
}

class _SoilRocksLabState
    extends State<Ch11A5SoilRocksAndMineralsFormationCompositionAndUsesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped whenever objects or the framing come to rest: the semantics
  /// nodes re-read where things are drawn.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay) and the Controls bar,
  /// measured to fit the scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch11-a5-canvas');
  final GlobalKey _barKey = GlobalKey(debugLabel: 'ch11-a5-controls');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _missionRect;

  /// The open step card (HTML `State.openStepId`; -1: none).
  int _openStep = 1;

  /// The object the current pointer holds, the scenario it was picked up
  /// in, its position and drag-plane height at pick-up, where the finger
  /// went down and whether it has moved since.
  _Obj? _grab;
  int _grabScenario = -1;
  _V _grabFrom = _V.zero;
  double _grabY = 0;
  _V _grabOffset = _V.zero;
  Offset _downAt = Offset.zero;
  Offset _lastPointer = Offset.zero;
  bool _moved = false;

  /// The key of the last toast and the language the page was last built in
  /// (a language switch re-shows the toast translated).
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// 1-based current step for the shell: the HTML `State.step`, then
  /// steps.length + 1 once the summary was opened.
  int get _shellStep => _scene.reviewed ? _scene.lastStep + 1 : _scene.step;

  /// The stage takes presses (lab open, no popup, no inspection panel).
  bool get _stageLive =>
      _lab.isLabActive && _lab.popup == null && !_scene.inspecting;

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

  /// Fits the plots, the table, the sieve, the trays (or the rocks, the
  /// tools and the plank) and their labels into the part of the canvas no
  /// card covers: the Controls bar, the tool column, the HUD (sidebar open)
  /// and the floating mission card (sidebar collapsed). Never while an
  /// object is held, so the scene does not move under the finger.
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
    final bar = _barKey.currentContext?.findRenderObject();
    if (bar is RenderBox && bar.hasSize && bar.attached) {
      hard.add((bar.localToGlobal(Offset.zero) - origin) & bar.size);
    }
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

  /// What the learner must see (HTML camera, zoom 1): the scenario's
  /// meshes where they rest and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_scene.view, _Framing.base);
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

    void chip(_V at, String key) {
      final size = _cache.chipSize(_t(key));
      items.add((
        cam.p(at),
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        ),
      ));
    }

    if (_scene.soil) {
      box(_table1 - _table1Size * 0.5, _table1 + _table1Size * 0.5);
      for (final plot in const [_forestPlot, _farmPlot]) {
        box(plot - _plotSize * 0.5, plot + _plotSize * 0.5);
      }
      // Pine tops and the shovels.
      box(const _V(-7.6, 0, -3.3), const _V(-4.6, 2.65, -1.7));
      box(const _V(-6.3, 0.6, 0.4), const _V(-5.7, 2.5, 0.6));
      box(const _V(5.7, 0.6, 0.4), const _V(6.3, 2.5, 0.6));
      box(const _V(-1.9, 0.2, -2.2), const _V(1.9, 2.85, 1.2));
      chip(_forestPlot + _plotLabelAt, 'lbl_forest_edge');
      chip(_farmPlot + _plotLabelAt, 'lbl_ploughed_farm');
      chip(_sieveHome + _sieveLabelAt, 'lbl_sieve');
      chip(_forestBagTable + _bagLabelAt, 'lbl_forest_bag');
      chip(_farmBagTable + _bagLabelAt, 'lbl_farm_bag');
      for (var row = 0; row < 2; row++) {
        for (var i = 0; i < 4; i++) {
          final c = _Scene.trayAt(row, i);
          box(c - const _V(0.82, 0.04, 0.62), c + const _V(0.82, 0.3, 0.62));
          final at = c + const _V(0, _trayLabelY, 0);
          items.add((
            cam.p(at),
            Rect.fromCenter(
              center: Offset.zero,
              width: 1,
              height: _cache.chipSize(_t(_Obj.trays[i].nameKey)).height,
            ),
          ));
        }
      }
    } else {
      box(_table2 - _table2Size * 0.5, _table2 + _table2Size * 0.5);
      box(_slateAt - _slateSize * 0.5, _slateAt + _slateSize * 0.5);
      for (final c in const [_sandstoneAt, _graniteAt]) {
        box(
          c - const _V(_rockR, _rockR, _rockR),
          c + const _V(_rockR, _rockR, _rockR),
        );
      }
      box(
        _hammerHome - const _V(0.66, 0.44, 0.55),
        _hammerHome + const _V(0.66, 0.44, 1.5),
      );
      box(_plankAt - _plankSize * 0.5, _plankAt + _plankSize * 0.5);
      chip(_slateAt + _rockLabelAt, 'lbl_slate');
      chip(_sandstoneAt + _rockLabelAt, 'lbl_sandstone');
      chip(_graniteAt + _rockLabelAt, 'lbl_granite');
      chip(_hammerHome + _hammerLabelAt, 'lbl_hammerstone');
      chip(_plankAt + _plankLabelAt, 'lbl_wood_piece');
      chip(_flakeRest + _flakeLabelAt, 'lbl_granite_flake');
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState()`: clears tweens and
  /// timers and puts every object back.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _openStep = 1;
      _grab = null;
      _grabScenario = -1;
      _missionRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
    _layout.value++;
  }

  /// HTML `resetApp()`: Scenario 1 from the start, with its toast.
  void _resetLab() {
    _loadScenario(0);
    _toast('toast_reset', sound: false);
  }

  /// HTML `showToast(msg)` with the text of [key].
  void _toast(String key, {bool isError = false, bool sound = true}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: isError, sound: sound);
  }

  /// Re-shows the visible toast in the new language after a switch from
  /// [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    final translated = _t(key);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `progressStep()` for an action of step [from]: the next step
  /// (skipping any done out of turn, so the lab never gets stuck), its
  /// card opens; at the last step 'Observe Conclusion' appears and the
  /// summary follows 800 ms later.
  void _progress(int from) {
    final s = _scene;
    if (s.step != from) return;
    _Sound.correct.play();
    var next = from + 1;
    while (next < s.lastStep && s.stepDone(next)) {
      next++;
    }
    s.step = math.min(next, s.lastStep);
    _openStep = s.step;
    if (s.step == s.lastStep) {
      final scenario = s.scenario;
      _lab.after(_autoConcludeDelay, () {
        if (_scene.scenario != scenario || _scene.step != _scene.lastStep) {
          return;
        }
        if (_scene.inspecting) {
          _scene.autoPending = true;
        } else {
          _review();
        }
      });
    }
    _refresh();
  }

  /// HTML `jumpToStep(id)` ('Switch to Step N'): the step changes, the
  /// scene stays as it is.
  void _jumpTo(int step) {
    final s = _scene;
    s
      ..step = step
      ..reviewed = false
      ..autoPending = false;
    _openStep = step;
    _refresh();
  }

  /// HTML `toggleSidebarStep(id)`: one card open at a time.
  void _toggleCard(int step) {
    setState(() => _openStep = _openStep == step ? -1 : step);
  }

  // ---------------------------------------------------- scenario 1 actions

  /// HTML `actionCollectForestSoil()` / `actionCollectFarmSoil()`: the
  /// shovel digs (rocks back and forth), a soil bag pops up at the back of
  /// the plot and slides onto the table.
  void _collect({required bool forest}) {
    final s = _scene;
    if (!s.soil || s.busy || (forest ? s.hasForest : s.hasFarm)) return;
    _Sound.shake.play();
    final t = s.time;
    if (forest) {
      s
        ..hasForest = true
        ..ready.remove(1)
        ..ready.add(3);
    } else {
      s
        ..hasFarm = true
        ..ready.remove(2)
        ..ready.add(4);
    }
    (forest ? s.forestDig : s.farmDig).animate(
      t,
      forest ? _digTurn : -_digTurn,
      _digLeg,
      legs: _digLegs,
    );
    final bag = forest ? s.forestBag : s.farmBag;
    bag
      ..shown = true
      ..pos.set(bag.home);
    bag.scale
      ..set(_bagStartScale)
      ..animate(t, 1, _bagPopSeconds, ease: _backOut);
    bag.pos.glide(
      t,
      forest ? _forestBagTable : _farmBagTable,
      _bagSlideSeconds,
      delay: _bagSlideDelay,
      ease: _cubicOut,
    );
    s.busy = true;
    s.cue(t + _bagSlideDelay + _bagSlideSeconds, () {
      s
        ..busy = false
        ..markSettled();
      _refresh();
    });
    _toast(forest ? 'toast_forest_dug' : 'toast_farm_dug', sound: false);
    _progress(forest ? 1 : 2);
    _refresh();
  }

  /// HTML `actionSieveForestSoil()` / `actionSieveFarmSoil()`: the bag rises
  /// over the sieve, tips its soil in, the sieve shakes and the trays of
  /// that row fill (the forest row with a live earthworm).
  void _sieve({required bool forest}) {
    final s = _scene;
    if (!s.soil || s.busy) return;
    final has = forest ? s.hasForest : s.hasFarm;
    if (!has) {
      _toast(forest ? 'toast_need_forest' : 'toast_need_farm', isError: true);
      return;
    }
    if (forest ? s.forestSieved : s.farmSieved) return;
    _Sound.shake.play();
    final t = s.time;
    if (forest) {
      s
        ..forestSieved = true
        ..ready.remove(3)
        ..ready.add(5);
    } else {
      s
        ..farmSieved = true
        ..ready.remove(4)
        ..ready.add(5);
    }
    final bag = forest ? s.forestBag : s.farmBag;
    s.busy = true;
    bag.pos.glide(t, _pourAt, _riseSeconds);
    s.cue(t + _riseSeconds, () {
      bag.tilt.animate(s.time, forest ? _tipAngle : -_tipAngle, _tipSeconds);
      s.cue(s.time + _tipSeconds, () {
        s.sieveX.animate(
          s.time,
          forest ? _shakeOffset : -_shakeOffset,
          _shakeLeg,
          legs: _shakeLegs,
        );
        s.cue(s.time + _sieveSettle, () {
          bag.shown = false;
          final row = forest ? 0 : 3;
          final heights = forest ? _forestFill : _farmFill;
          for (var i = 0; i < 3; i++) {
            s.fill[row + i] = heights[i];
          }
          if (forest) s.worm = true;
          s
            ..busy = false
            ..markSettled();
          _toast(
            forest ? 'toast_forest_sieved' : 'toast_farm_sieved',
            sound: false,
          );
          _progress(forest ? 3 : 4);
          _refresh();
        });
      });
    });
    _refresh();
  }

  /// HTML `actionInspectTrays()`: the magnifying-glass panel opens.
  void _inspect() {
    final s = _scene;
    if (!s.soil || s.busy || s.inspecting) return;
    _Sound.click.play();
    s
      ..inspected = true
      ..inspecting = true;
    _progress(5);
    _refresh();
  }

  /// HTML `closeInspectModal()` ('Complete Inspection'). A summary that
  /// was due meanwhile opens 800 ms later.
  void _closeInspect() {
    final s = _scene;
    if (!s.inspecting) return;
    _Sound.click.play();
    s.inspecting = false;
    if (s.autoPending) {
      s.autoPending = false;
      final scenario = s.scenario;
      _lab.after(_autoConcludeDelay, () {
        if (_scene.scenario == scenario &&
            _scene.step == _scene.lastStep &&
            !_scene.inspecting) {
          _review();
        }
      });
    }
    _refresh();
  }

  // ---------------------------------------------------- scenario 2 actions

  /// HTML `actionStrikeSlate()` / `…Sandstone()` / `…Granite()`: the
  /// hammerstone rises over the rock and comes down; slate splits into
  /// tiles, sandstone crumbles into grains, granite gives off a sharp
  /// flake ('Clink!'). The hammerstone then rests in front of it.
  void _strike(_Obj rock) {
    final s = _scene;
    if (s.soil || s.busy) return;
    final n = switch (rock) {
      _Obj.slate => 1,
      _Obj.sandstone => 2,
      _ => 3,
    };
    if (s.stepDone(n)) return;
    final granite = rock == _Obj.granite;
    (granite ? _Sound.clink : _Sound.strike).play();
    switch (rock) {
      case _Obj.slate:
        s.slateStruck = true;
      case _Obj.sandstone:
        s.sandstoneStruck = true;
      default:
        s.graniteStruck = true;
    }
    s
      ..ready.remove(n)
      ..ready.add(n + 1)
      ..busy = true;
    final at = switch (rock) {
      _Obj.slate => _slateAt,
      _Obj.sandstone => _sandstoneAt,
      _ => _graniteAt,
    };
    final t = s.time;
    s.hammer.glide(t, _V(at.x, _raiseY, at.z), _raiseSeconds);
    s.cue(t + _raiseSeconds, () {
      s.hammer.y.animate(s.time, granite ? _graniteHitY : _hitY, _dropSeconds);
      s.cue(s.time + _dropSeconds, () {
        final now = s.time;
        var rest = _restSeconds;
        switch (rock) {
          case _Obj.slate:
            s.slateBroken = true;
          case _Obj.sandstone:
            s.sandstoneBroken = true;
          default:
            s
              ..flakeShown = true
              ..flake.set(_graniteAt);
            s.flake.glide(now, _flakeRest, _flakeSeconds, ease: _cubicOut);
            rest = math.max(rest, _flakeSeconds);
        }
        s.hammer.glide(now, _V(at.x, _restY, _restZ), _restSeconds);
        s.cue(now + rest, () {
          s
            ..busy = false
            ..markSettled();
          _refresh();
        });
        _toast(switch (rock) {
          _Obj.slate => 'toast_slate',
          _Obj.sandstone => 'toast_sandstone',
          _ => 'toast_granite',
        }, sound: false);
        _progress(n);
        _refresh();
      });
    });
    _refresh();
  }

  /// HTML hammerstone click: the next rock still whole, in textbook order.
  void _strikeNext() {
    final s = _scene;
    if (!s.slateStruck) {
      _strike(_Obj.slate);
    } else if (!s.sandstoneStruck) {
      _strike(_Obj.sandstone);
    } else if (!s.graniteStruck) {
      _strike(_Obj.granite);
    }
  }

  /// HTML `actionCarveWood()`: the flake saws along the plank, shavings curl
  /// up and the plank is carved down.
  void _carve() {
    final s = _scene;
    if (s.soil || s.busy) return;
    if (!s.graniteStruck) {
      _toast('toast_need_granite', isError: true);
      return;
    }
    if (s.carved) return;
    _Sound.strike.play();
    s
      ..carved = true
      ..ready.remove(4)
      ..busy = true;
    final t = s.time;
    s.flake.glide(t, _carveStart, _carveMoveSeconds, ease: _cubicOut);
    s.cue(t + _carveMoveSeconds, () {
      s.flake.x.animate(s.time, _sawX, _sawLeg, legs: _sawLegs);
      s.cue(s.time + _sawLeg * _sawLegs, () {
        s
          ..shaved = true
          ..busy = false
          ..markSettled();
        s.flake.set(_flakeDone);
        _toast('toast_carved', sound: false);
        _progress(4);
        _refresh();
      });
    });
    _refresh();
  }

  // --------------------------------------------------------------- the end

  /// HTML `triggerConclusion()`: the summary with its cards and confetti.
  void _review() {
    final s = _scene;
    if (s.step != s.lastStep || s.busy) return;
    final sc = s.scenario;
    s
      ..reviewed = true
      ..autoPending = false
      ..confettiAt = s.time;
    _lab.completedScenarios.add(sc);
    _lab.showPopup(() => _summary(sc));
    _refresh();
  }

  /// The summary popup of scenario [sc] (HTML `#summary-modal`): the
  /// scenario title, its summary and the next-step message. Once both
  /// scenarios are done it offers the HTML's 'Restart Entire Lab'.
  LabPopupContent _summary(int sc) {
    final done = _lab.completedScenarios;
    final allDone = done.length >= _scenarioCount;
    final _NextMessage next;
    if (sc == 0) {
      next = _NextMessage.selectNext;
    } else if (!done.contains(0)) {
      next = _NextMessage.selectNextAfter2;
    } else {
      next = _NextMessage.mastery;
    }
    return LabPopupContent(
      title: _lab.t('success'),
      heading: _t('s${sc + 1}_title'),
      icon: Icons.check_circle,
      accent: _Colors.amber600,
      extra: Builder(
        builder: (context) => _SummaryPanel(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale.clamp(0.9, 1.4),
          t: _t,
          next: next,
        ),
      ),
      actions: [
        if (allDone)
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.emerald600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
      ],
    );
  }

  /// HTML `#conclude-btn-container` ('Observe Conclusion') at the last
  /// step; it stays so the summary can be opened again.
  LabAction? _concludeAction({bool canvas = false}) {
    final s = _scene;
    if (s.step != s.lastStep) return null;
    return LabAction(
      label: _t('btn_conclude'),
      icon: Icons.lightbulb,
      color: _Colors.amber600,
      foreground: _Colors.white,
      highlight: canvas || !s.reviewed,
      silent: true,
      enabled: !s.busy,
      onTap: _review,
    );
  }

  /// HTML `#inventory-panel` buttons of the scenario (a tap while an
  /// action plays is ignored by the action itself).
  List<_ControlButton> _controls() {
    final s = _scene;
    final live = _lab.isLabActive;
    _ControlButton button(
      int n,
      IconData icon,
      Color color,
      Color inkDark,
      Color inkLight,
      VoidCallback onTap,
    ) {
      final sc = s.scenario + 1;
      return _ControlButton(
        label: _t('s${sc}_btn_$n'),
        tip: _t('s${sc}_tip_$n'),
        icon: icon,
        color: color,
        inkDark: inkDark,
        inkLight: inkLight,
        enabled: live && s.ready.contains(n),
        onTap: onTap,
      );
    }

    if (s.soil) {
      return [
        button(
          1,
          Icons.park,
          _Colors.emerald500,
          _Colors.emerald400,
          _Colors.emerald600,
          () => _collect(forest: true),
        ),
        button(
          2,
          Icons.eco,
          _Colors.amber500,
          _Colors.amber400,
          _Colors.amber600,
          () => _collect(forest: false),
        ),
        button(
          3,
          Icons.filter_alt,
          _Colors.indigo500,
          _Colors.indigo400,
          _Colors.indigo600,
          () => _sieve(forest: true),
        ),
        button(
          4,
          Icons.filter_alt,
          _Colors.blue500,
          _Colors.blue400,
          _Colors.blue600,
          () => _sieve(forest: false),
        ),
        button(
          5,
          Icons.zoom_in,
          _Colors.purple500,
          _Colors.purple400,
          _Colors.purple600,
          _inspect,
        ),
      ];
    }
    return [
      button(
        1,
        Icons.hardware,
        _Colors.slate500,
        _Colors.slate300,
        _Colors.slate600,
        () => _strike(_Obj.slate),
      ),
      button(
        2,
        Icons.hardware,
        _Colors.amber500,
        _Colors.amber400,
        _Colors.amber600,
        () => _strike(_Obj.sandstone),
      ),
      button(
        3,
        Icons.hardware,
        _Colors.indigo500,
        _Colors.indigo400,
        _Colors.indigo600,
        () => _strike(_Obj.granite),
      ),
      button(
        4,
        Icons.carpenter,
        _Colors.emerald500,
        _Colors.emerald400,
        _Colors.emerald600,
        _carve,
      ),
    ];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `onPointerDown`: a press on a scene object, not while an action
  /// plays.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_stageLive || _grab != null || s.busy) return false;
    return s.objAt(event.localPosition, _touch) != null;
  }

  /// A tray, a rock or the plank acts at once (HTML: on pointer-down); a
  /// shovel, a bag, the hammerstone or the flake is picked up on a
  /// horizontal plane at its own height.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (!_stageLive || s.busy || _grab != null) return;
    final p = d.localPosition;
    final o = s.objAt(p, _touch);
    if (o == null) return;
    if (!o.draggable || !s.present(o)) {
      _press(o);
      return;
    }
    final from = _posOf(o).at(s.time);
    _grabY = from.y;
    final hit = s.camera().onPlaneY(p, _grabY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - from.x, 0, hit.z - from.z);
    _grabFrom = from;
    _grab = o;
    _grabScenario = s.scenario;
    _downAt = p;
    _lastPointer = p;
    _moved = false;
    s.held = o;
  }

  /// The position track of a draggable object.
  _Pos _posOf(_Obj o) {
    final s = _scene;
    return switch (o) {
      _Obj.forestShovel => s.forestShovel,
      _Obj.farmShovel => s.farmShovel,
      _Obj.forestBag => s.forestBag.pos,
      _Obj.farmBag => s.farmBag.pos,
      _Obj.flake => s.flake,
      _ => s.hammer,
    };
  }

  /// The click actions of the non-draggable objects and of a hidden bag
  /// (HTML `onPointerDown`).
  void _press(_Obj o) {
    switch (o) {
      case _Obj.forestBag || _Obj.farmBag:
        _sieve(forest: o == _Obj.forestBag);
      case _Obj.humusTray || _Obj.sandTray || _Obj.pebblesTray || _Obj.wormTray:
        _inspect();
      case _Obj.slate || _Obj.sandstone || _Obj.granite:
        _strike(o);
      case _Obj.plank:
        _carve();
      default:
        break;
    }
  }

  /// HTML `onPointerMove`: the object follows the finger on the drag plane,
  /// 0.4 above it.
  void _onDragUpdate(DragUpdateDetails d) {
    final o = _grab;
    final s = _scene;
    if (o == null || _grabScenario != s.scenario) return;
    _lastPointer = d.localPosition;
    if ((d.localPosition - _downAt).distance > _dragSlop) _moved = true;
    if (!_moved) return;
    final hit = s.camera().onPlaneY(d.localPosition, _grabY);
    if (hit == null) return;
    final halfX = s.soil ? _s1DragHalfX : _s2DragHalfX;
    final back = s.soil ? _s1DragBack : _s2DragBack;
    final front = s.soil ? _s1DragFront : _s2DragFront;
    _posOf(o).set(
      _V(
        (hit.x - _grabOffset.x).clamp(-halfX, halfX),
        _grabY + _liftY,
        (hit.z - _grabOffset.z).clamp(back, front),
      ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `onPointerUp`: a press that hardly moved is a click (a shovel
  /// digs, a bag is sieved, the hammerstone strikes the next rock, the
  /// flake carves); a drop of the hammerstone near a rock strikes it, of
  /// the flake near the plank carves it, otherwise they glide back. A bag
  /// dropped anywhere is sieved; a shovel digs and goes home (added).
  void _release() {
    final o = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (o == null || scenario != s.scenario) return;
    s.held = null;
    final pos = _posOf(o);
    final now = pos.at(s.time);
    final moved = _moved && now.distanceTo(_grabFrom) >= _clickMove;
    switch (o) {
      case _Obj.forestShovel || _Obj.farmShovel:
        if (moved) pos.glide(s.time, _grabFrom, _homeSeconds);
        _collect(forest: o == _Obj.forestShovel);
      case _Obj.forestBag || _Obj.farmBag:
        _sieve(forest: o == _Obj.forestBag);
        if (!s.busy) pos.glide(s.time, _grabFrom, _backSeconds);
      case _Obj.flake:
        if (!moved) {
          _carve();
        } else if (now.distanceTo(_plankAt) < _carveRange ||
            _overObject(_Obj.plank)) {
          _carve();
        }
        if (!s.busy) pos.glide(s.time, _grabFrom, _backSeconds);
      default:
        if (!moved) {
          _strikeNext();
        } else {
          final rock = _rockNear(now);
          if (rock != null) _strike(rock);
        }
        if (!s.busy) pos.glide(s.time, _grabFrom, _backSeconds);
    }
    s
      ..markSettled()
      ..cue(s.time + _backSeconds, s.markSettled);
    _scheduleFraming();
  }

  /// Is the finger over [o] as it is drawn (added: so a drop that looks
  /// right on a small screen counts)?
  bool _overObject(_Obj o) {
    final s = _scene;
    return s.present(o) &&
        s.rectOf(o, s.camera()).inflate(_touch / 2).contains(_lastPointer);
  }

  /// HTML hammerstone drop: a rock within 3.2 that is still whole (in
  /// textbook order), else any rock within 3.2; or the rock under the
  /// finger (added).
  _Obj? _rockNear(_V at) {
    final s = _scene;
    const rocks = [_Obj.slate, _Obj.sandstone, _Obj.granite];
    const centres = [_slateAt, _sandstoneAt, _graniteAt];
    for (var i = 0; i < 3; i++) {
      if (!s.stepDone(i + 1) && at.distanceTo(centres[i]) < _strikeRange) {
        return rocks[i];
      }
    }
    for (var i = 0; i < 3; i++) {
      if (at.distanceTo(centres[i]) < _strikeRange) return rocks[i];
    }
    for (final r in rocks) {
      if (_overObject(r)) return r;
    }
    return null;
  }

  /// A screen-reader tap on a scene object (added): what a click on it
  /// does in the HTML.
  void _activate(_Obj o) {
    if (!_stageLive || _scene.busy || _grab != null) return;
    switch (o) {
      case _Obj.forestShovel || _Obj.farmShovel:
        _collect(forest: o == _Obj.forestShovel);
      case _Obj.forestBag || _Obj.farmBag:
        _sieve(forest: o == _Obj.forestBag);
      case _Obj.hammer:
        _strikeNext();
      case _Obj.flake:
        _carve();
      default:
        _press(o);
    }
  }

  // -------------------------------------------------------------------- UI

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
        final s = context.labScale;
        final p = _lab.palette;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final scene = _scene;
        final sc = scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final popupOpen = _lab.popup != null;
        final conclude = _concludeAction(canvas: true);
        final sideConclude = _concludeAction();
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.landscape,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _shellStep,
          hud: _t('s${sc + 1}_hud_${scene.step.clamp(1, scene.lastStep)}'),
          actions: [?sideConclude],
          onReset: _resetLab,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            steps: _stepData,
            current: scene.step,
            open: _openStep,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _lab.t('step'),
            actionLabel: _t('action_lbl'),
            resultLabel: _t('result_lbl'),
            collapseLabel: _t('collapse'),
            switchLabel: (n) => labFormat(_t('switch_step'), {'n': n}),
            onToggle: _toggleCard,
            onJump: _jumpTo,
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#inventory-panel`: the Controls bar at the top centre
            // of the canvas.
            if (_lab.isLabActive)
              Positioned(
                key: const ValueKey('ch11a5-controls'),
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: _ControlsBar(
                    key: _barKey,
                    title: _t('controls'),
                    buttons: _controls(),
                    palette: p,
                    scale: s,
                  ),
                ),
              ),
            // HTML `#conclude-btn-container`: above the HUD, so it is in
            // reach on phones too.
            if (conclude != null && !popupOpen && !scene.inspecting)
              Positioned(
                key: const ValueKey('ch11a5-conclude'),
                bottom: inset.bottom + (_lab.isSidebarOpen ? 66 * s : 0),
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: conclude,
                    scale: s,
                    expand: false,
                  ),
                ),
              ),
            // HTML `#inspect-modal`: the magnifying-glass panel over the
            // canvas.
            if (scene.inspecting)
              Positioned.fill(
                child: _InspectPanel(
                  t: _t,
                  palette: p,
                  scale: s,
                  fontScale: _lab.fontScale.clamp(0.9, 1.3),
                  bottomClear: _lab.isSidebarOpen
                      ? _hudBand * s + 8
                      : inset.bottom,
                  leftClear: _lab.isSidebarOpen ? 12 * s : inset.left,
                  rightClear: inset.right,
                  time: _frame,
                  onDone: _closeInspect,
                ),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags on the scene are not screen-reader actions; the
                // scene and its objects are announced instead.
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
                  label: _t(_scene.soil ? 'scene_s1' : 'scene_s2'),
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
              // One semantics node per scene object where it is drawn
              // (added), so a screen reader can find and tap them. They
              // take no touches: those reach the scene below.
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
        for (final o in _Obj.values)
          if (s.present(o))
            Positioned.fromRect(
              rect: s.rectOf(o, cam),
              child: Semantics(
                container: true,
                button: o != _Obj.sieve,
                label: _plain(_t(o.nameKey)),
                onTap: o == _Obj.sieve ? null : () => _activate(o),
                child: const SizedBox.expand(),
              ),
            ),
      ],
    );
  }
}

/// [text] without the leading emoji of the HTML labels ('🛍️ Forest Soil
/// Bag' → 'Forest Soil Bag'), for screen readers.
String _plain(String text) =>
    text.replaceFirst(RegExp(r'^[^\p{L}\p{N}]+', unicode: true), '');

/// Which message closes the summary (HTML `#popup-next-msg`).
enum _NextMessage {
  /// `s1_popup_msg`: select the next scenario.
  selectNext,

  /// `s1_popup_msg` with 1 → 2 (Scenario 2 done before Scenario 1).
  selectNextAfter2,

  /// `all_complete_desc` (with the success modal's 'Mastery Achieved!').
  mastery,
}

// =================================================================== WIDGETS

/// HTML `#inventory-panel`: a glass bar with a 'Controls' tag and the
/// scenario's numbered buttons (icon over text on wide screens, beside it
/// on phones). Used buttons are dimmed and ignore taps; the bar scrolls
/// sideways when it is wider than the canvas.
class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    super.key,
    required this.title,
    required this.buttons,
    required this.palette,
    required this.scale,
  });

  final String title;
  final List<_ControlButton> buttons;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    // Tailwind `sm:` (640 px): the buttons stack their icon over the text.
    final stacked = MediaQuery.sizeOf(context).width >= 640;
    final accent = p.ink(_Colors.amber600);
    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
      radius: 12,
      color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
      borderColor: _Colors.amber600.withValues(alpha: 0.4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(right: 6 * s),
              margin: EdgeInsets.only(right: 6 * s),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: p.cardBorder)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.backpack, size: 12 * s, color: accent),
                  SizedBox(width: 3 * s),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontSize: 9.5 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(title, 0.8),
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) SizedBox(width: 6 * s),
              _ControlChip(
                button: buttons[i],
                palette: p,
                scale: s,
                stacked: stacked,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One Controls button (`.inv-item`).
class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.button,
    required this.palette,
    required this.scale,
    required this.stacked,
  });

  final _ControlButton button;
  final LabPalette palette;
  final double scale;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final b = button;
    final s = scale;
    final ink = palette.isDark ? b.inkDark : b.inkLight;
    final icon = Icon(b.icon, size: 17 * s, color: ink);
    final label = Text(
      b.label,
      maxLines: 1,
      style: TextStyle(
        color: ink,
        fontSize: 10.5 * s,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
    return Tooltip(
      message: b.tip,
      child: Opacity(
        opacity: b.enabled ? 1 : 0.4,
        child: Material(
          color: b.color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(color: b.color.withValues(alpha: 0.3)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: b.enabled ? b.onTap : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 72 * s,
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 7 * s,
                  vertical: 3 * s,
                ),
                child: stacked
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          SizedBox(height: 2 * s),
                          label,
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          SizedBox(width: 4 * s),
                          label,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The four close-ups of the HTML inspection panel.
enum _Lens {
  humus(
    'insp_humus_title',
    'insp_humus',
    'badge_zoom',
    _Colors.emerald400,
    _Colors.emerald300,
    Color(0xFF78350F),
    Color(0xFF3F2E21),
  ),
  sand(
    'insp_sand_title',
    'insp_sand',
    'badge_zoom',
    _Colors.amber400,
    _Colors.amber300,
    Color(0xFFEAB308),
    Color(0xFF854D0E),
  ),
  pebbles(
    'insp_pebbles_title',
    'insp_pebbles',
    'badge_zoom',
    _Colors.slate400,
    _Colors.slate300,
    _Colors.slate500,
    _Colors.slate700,
  ),
  worm(
    'insp_worm_title',
    'insp_worm',
    'badge_live',
    _Colors.pink400,
    _Colors.pink300,
    Color(0xFF831843),
    Color(0xFF4C0519),
  );

  const _Lens(
    this.titleKey,
    this.textKey,
    this.badgeKey,
    this.color,
    this.badgeInk,
    this.inner,
    this.outer,
  );

  final String titleKey;
  final String textKey;
  final String badgeKey;

  /// Card border / title colour (`*-400`) and the badge text (`*-300`).
  final Color color;
  final Color badgeInk;

  /// The lens's radial gradient (`radial-gradient(circle, inner 20%, outer
  /// 80%)`).
  final Color inner;
  final Color outer;
}

/// HTML `#inspect-modal`: a dark panel over the canvas with the title,
/// 'Complete Inspection', the comparison text and four magnified trays.
/// It keeps clear of the HUD (or the floating mission card) and the tool
/// column, and scrolls on phones.
class _InspectPanel extends StatelessWidget {
  const _InspectPanel({
    required this.t,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.bottomClear,
    required this.leftClear,
    required this.rightClear,
    required this.time,
    required this.onDone,
  });

  final String Function(String key) t;
  final LabPalette palette;
  final double scale;
  final double fontScale;
  final double bottomClear;
  final double leftClear;
  final double rightClear;

  /// Scene time, for the bouncing leaves and the wriggling worm.
  final ValueListenable<double> time;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final f = s * fontScale;
    return ColoredBox(
      color: _Colors.slate950.withValues(alpha: 0.8),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          leftClear,
          10 * s,
          rightClear,
          bottomClear,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: Container(
              decoration: BoxDecoration(
                color: _Colors.slate900.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _Colors.purple500.withValues(alpha: 0.4),
                ),
                boxShadow: const [
                  BoxShadow(color: LabInk.shadowStrong, blurRadius: 30),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(s, f),
                    SizedBox(height: 10 * s),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: t('insp_text_1')),
                          TextSpan(
                            text: t('insp_forest'),
                            style: const TextStyle(
                              color: _Colors.emerald400,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: t('insp_text_2')),
                          TextSpan(
                            text: t('insp_farm'),
                            style: const TextStyle(
                              color: _Colors.amber400,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: t('insp_text_3')),
                        ],
                      ),
                      style: TextStyle(
                        color: _Colors.slate300,
                        fontSize: 12.5 * f,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    LayoutBuilder(
                      builder: (context, box) {
                        // Tailwind `grid-cols-1 sm:grid-cols-2
                        // md:grid-cols-4`.
                        final cols = box.maxWidth >= 640
                            ? 4
                            : (box.maxWidth >= 330 ? 2 : 1);
                        final gap = 12 * s;
                        final w = (box.maxWidth - gap * (cols - 1)) / cols;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final lens in _Lens.values)
                              SizedBox(width: w, child: _lensCard(lens, s, f)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Title (with the pulsing magnifying glass) and 'Complete Inspection'.
  Widget _header(double s, double f) {
    final title = Row(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: time,
          builder: (context, now, child) => Opacity(
            // Tailwind `animate-pulse`: 2 s, opacity 1 → 0.5 → 1.
            opacity: 0.75 + 0.25 * math.cos(now * math.pi),
            child: child,
          ),
          child: Icon(Icons.zoom_in, size: 24 * s, color: _Colors.purple400),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: Text(
            t('inspect_title'),
            style: TextStyle(
              color: _Colors.purple400,
              fontSize: 16 * f,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
    final done = Material(
      color: _Colors.purple600,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onDone,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * s),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('insp_done'),
                  style: TextStyle(
                    color: _Colors.white,
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 5 * s),
                Icon(Icons.check, size: 15 * s, color: _Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.only(bottom: 10 * s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _Colors.slate800)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8 * s,
        spacing: 12 * s,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 200 * s, maxWidth: 560 * s),
            child: title,
          ),
          done,
        ],
      ),
    );
  }

  /// One magnified tray: the lens, its badge, title and description.
  Widget _lensCard(_Lens lens, double s, double f) {
    final side = 96 * s;
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: _Colors.slate800.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lens.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lens.color.withValues(alpha: 0.8),
                        width: 4 * s,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        painter: _LensPainter(lens: lens, time: time),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8 * s,
                  bottom: 4 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5 * s,
                      vertical: 1.5 * s,
                    ),
                    decoration: BoxDecoration(
                      color: _Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t(lens.badgeKey),
                      style: TextStyle(
                        color: lens.badgeInk,
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            t(lens.titleKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: lens.color,
              fontSize: 13.5 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            t(lens.textKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Colors.slate300,
              fontSize: 11 * f,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML teacher-board "Observation Step" cards: each shows its step badge
/// and concept; the open one (one at a time) adds its action, its result
/// and, unless it is the current step, 'Switch to Step N'. The current
/// card is amber with a pulsing badge, done cards are green with a tick.
class _StepsAccordion extends StatelessWidget {
  const _StepsAccordion({
    required this.steps,
    required this.current,
    required this.open,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.actionLabel,
    required this.resultLabel,
    required this.collapseLabel,
    required this.switchLabel,
    required this.onToggle,
    required this.onJump,
  });

  final List<_StepInfo> steps;

  /// HTML `State.step` and `State.openStepId`.
  final int current;
  final int open;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String actionLabel;
  final String resultLabel;
  final String collapseLabel;
  final String Function(int n) switchLabel;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 8 * scale),
          _card(context, i),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, int id) {
    final p = palette;
    final s = scale;
    final f = fontScale;
    final dark = p.isDark;
    final isCurrent = id == current;
    final isDone = id < current;
    final isOpen = id == open;
    final step = steps[id - 1];

    final Color bg;
    final Color border;
    final Color badgeBg;
    final Color badgeInk;
    if (isCurrent) {
      bg = dark ? _Colors.slate800 : _Colors.white;
      border = _Colors.amber600;
      badgeBg = _Colors.amber600;
      badgeInk = _Colors.white;
    } else if (isDone) {
      bg = dark
          ? _Colors.emerald950.withValues(alpha: 0.2)
          : const Color(0x80ECFDF5);
      border = _Colors.emerald500.withValues(alpha: 0.4);
      badgeBg = _Colors.emerald500;
      badgeInk = _Colors.white;
    } else {
      bg = dark ? _Colors.slate800.withValues(alpha: 0.6) : _Colors.slate100;
      border = dark
          ? _Colors.slate700.withValues(alpha: 0.8)
          : _Colors.slate200;
      badgeBg = dark ? _Colors.slate700 : _Colors.slate200;
      badgeInk = dark ? _Colors.slate300 : _Colors.slate600;
    }
    final strong = dark ? _Colors.slate100 : _Colors.slate800;
    void toggle() {
      LabStyleScope.of(context).style.click.play();
      onToggle(id);
    }

    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${stepLabel.toUpperCase()} $id',
        style: TextStyle(
          color: badgeInk,
          fontSize: 9.5 * f,
          fontWeight: FontWeight.w800,
          letterSpacing: labLetterSpacing(stepLabel, 0.8),
        ),
      ),
    );
    final tick = Icon(
      Icons.check_circle,
      size: 16 * s,
      color: _Colors.emerald500,
    );
    final concept = Text(
      step.concept,
      style: TextStyle(
        color: strong,
        fontSize: 12 * f,
        fontWeight: FontWeight.w900,
        height: 1.3,
      ),
    );

    final Widget body;
    if (!isOpen) {
      body = InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: EdgeInsets.all(10 * s),
            child: Row(
              children: [
                badge,
                SizedBox(width: 8 * s),
                Expanded(child: concept),
                if (isDone) ...[SizedBox(width: 4 * s), tick],
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18 * s,
                  color: _Colors.slate400,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final resultInk = dark ? _Colors.amber300 : _Colors.amber800;
      body = Padding(
        padding: EdgeInsets.all(11 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: toggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Row(
                  children: [
                    badge,
                    if (isDone) ...[SizedBox(width: 6 * s), tick],
                    const Spacer(),
                    Text(
                      collapseLabel,
                      style: TextStyle(
                        color: dark ? _Colors.slate400 : _Colors.slate500,
                        fontSize: 11 * f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 16 * s,
                      color: dark ? _Colors.slate400 : _Colors.slate500,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(onTap: toggle, child: concept),
            SizedBox(height: 8 * s),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$actionLabel: ',
                    style: TextStyle(
                      color: dark ? _Colors.indigo400 : _Colors.indigo500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: step.action),
                ],
              ),
              style: TextStyle(
                color: dark ? _Colors.slate300 : _Colors.slate600,
                fontSize: 11 * f,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            SizedBox(height: 8 * s),
            Container(
              padding: EdgeInsets.all(9 * s),
              decoration: BoxDecoration(
                color: _Colors.amber600.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _Colors.amber600.withValues(alpha: 0.2),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$resultLabel: ',
                      style: TextStyle(
                        color: dark ? _Colors.white : _Colors.slate800,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(text: step.observation),
                  ],
                ),
                style: TextStyle(
                  color: resultInk,
                  fontSize: 11 * f,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
            if (!isCurrent) ...[
              SizedBox(height: 8 * s),
              Material(
                color: dark ? _Colors.slate700 : _Colors.slate200,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    LabStyleScope.of(context).style.click.play();
                    onJump(id);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: kMinInteractiveDimension,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 15 * s,
                          color: dark ? _Colors.slate200 : _Colors.slate700,
                        ),
                        SizedBox(width: 5 * s),
                        Flexible(
                          child: Text(
                            switchLabel(id),
                            style: TextStyle(
                              color: dark ? _Colors.slate200 : _Colors.slate700,
                              fontSize: 12 * f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Material(
      color: LabInk.clear,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: isCurrent ? 1.5 : 1),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: _Colors.amber600.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: body,
      ),
    );
  }
}

/// HTML summary blocks (`ScenariosData[n].summary`) and `#popup-next-msg`.
/// Scenario 1: 'Soil Investigation Verified!' with the forest and farm soil
/// cards; Scenario 2: 'Stone Age Toolmaker Mastery!' with the slate,
/// sandstone and granite cards. Dark like the HTML modal; tinted for the
/// light theme.
class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.t,
    required this.next,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final double fontScale;
  final String Function(String key) t;
  final _NextMessage next;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale;
    final n = scenario + 1;
    final cards = scenario == 0
        ? [
            _card(
              t('s1_sum_forest_title'),
              t('s1_sum_forest'),
              _Colors.emerald400,
              _Colors.emerald950.withValues(alpha: 0.7),
              _Colors.emerald500.withValues(alpha: 0.4),
              center: false,
            ),
            _card(
              t('s1_sum_farm_title'),
              t('s1_sum_farm'),
              _Colors.amber400,
              _Colors.amber950.withValues(alpha: 0.7),
              _Colors.amber500.withValues(alpha: 0.4),
              center: false,
            ),
          ]
        : [
            _card(
              t('s2_sum_slate_title'),
              t('s2_sum_slate'),
              _Colors.slate300,
              _Colors.slate800.withValues(alpha: 0.8),
              _Colors.slate600,
            ),
            _card(
              t('s2_sum_sandstone_title'),
              t('s2_sum_sandstone'),
              _Colors.amber300,
              _Colors.amber950.withValues(alpha: 0.6),
              _Colors.amber600.withValues(alpha: 0.4),
            ),
            _card(
              t('s2_sum_granite_title'),
              t('s2_sum_granite'),
              _Colors.indigo300,
              _Colors.indigo950.withValues(alpha: 0.7),
              _Colors.indigo500,
              glow: true,
            ),
          ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: _Colors.amber500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Colors.amber500.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20 * s,
                    color: p.ink(_Colors.amber400),
                  ),
                  SizedBox(width: 6 * s),
                  Expanded(
                    child: Text(
                      t('s${n}_sum_head'),
                      style: TextStyle(
                        color: p.ink(_Colors.amber400),
                        fontSize: 16 * f,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                t('s${n}_sum_intro'),
                style: TextStyle(
                  color: p.isDark ? _Colors.slate200 : _Colors.slate700,
                  fontSize: 13 * f,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 10 * s),
              LayoutBuilder(
                builder: (context, box) {
                  // Tailwind `grid-cols-1 sm:grid-cols-2` (soil) or
                  // `sm:grid-cols-3` (rocks).
                  final cols = scenario == 0
                      ? (box.maxWidth >= 320 ? 2 : 1)
                      : (box.maxWidth >= 420 ? 3 : 1);
                  final gap = 8 * s;
                  if (cols == 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) SizedBox(height: gap),
                          cards[i],
                        ],
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) SizedBox(width: gap),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        _nextBox(s, f),
      ],
    );
  }

  /// One summary card: its emoji title and text.
  Widget _card(
    String title,
    String text,
    Color ink,
    Color bg,
    Color border, {
    bool center = true,
    bool glow = false,
  }) {
    final p = palette;
    final s = scale;
    final f = s * fontScale;
    final dark = p.isDark;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: dark ? bg : ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          if (glow) const BoxShadow(color: LabInk.shadowSoft, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: p.ink(ink),
              fontSize: 12 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            text,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: dark ? _Colors.slate200 : _Colors.slate700,
              fontSize: 11.5 * f,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#popup-next-msg`: select the next scenario, or (both done) the
  /// success modal's 'Mastery Achieved!' with `all_complete_desc`.
  Widget _nextBox(double s, double f) {
    final p = palette;
    final mastery = next == _NextMessage.mastery;
    final ink = p.ink(mastery ? _Colors.emerald400 : _Colors.amber300);
    final text = switch (next) {
      _NextMessage.selectNext => t('s1_popup_msg'),
      _NextMessage.selectNextAfter2 => t('s2_popup_msg'),
      _NextMessage.mastery => t('all_complete_desc'),
    };
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: _Colors.amber500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Colors.amber500.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            mastery ? Icons.emoji_events : Icons.info,
            size: 18 * s,
            color: p.ink(mastery ? _Colors.emerald400 : _Colors.amber400),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mastery) ...[
                  Text(
                    t('all_complete'),
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 15 * f,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3 * s),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: ink,
                    fontSize: 12.5 * f,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
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

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
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
    final tp = label(text);
    return Size(
      tp.width + 2 * _chipPadX * _labelSize,
      tp.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// MeshStandardMaterial look for a round mesh of [c]: a radial gradient
  /// on a unit circle, lit from the upper right like the HTML key light.
  Paint ball(Color c) => _balls[c.toARGB32()] ??= () {
    final lit = _lit(c, _viewNormal);
    return Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.45),
        1.4,
        [labShade(lit, 0.25), lit, labShade(c, -0.35)],
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

/// The 20 corners (unit radius) and 12 pentagons of a
/// `DodecahedronGeometry`, made once.
final ({List<_V> verts, List<List<int>> faces}) _dodeca = () {
  final phi = (1 + math.sqrt(5)) / 2;
  final inv = 1 / phi;
  final raw = <_V>[
    for (final x in const [-1.0, 1.0])
      for (final y in const [-1.0, 1.0])
        for (final z in const [-1.0, 1.0]) _V(x, y, z),
    for (final a in [-inv, inv])
      for (final b in [-phi, phi]) ...[_V(0, a, b), _V(a, b, 0), _V(b, 0, a)],
  ];
  final verts = [for (final v in raw) v.unit];
  // Face centres: the dual icosahedron's corners (±1, 0, ±φ), (±φ, ±1, 0)
  // and (0, ±φ, ±1).
  final centres = <_V>[
    for (final a in const [-1.0, 1.0])
      for (final b in [-phi, phi]) ...[_V(a, 0, b), _V(b, a, 0), _V(0, b, a)],
  ];
  final faces = <List<int>>[];
  for (final c0 in centres) {
    final c = c0.unit;
    final order = [for (var i = 0; i < verts.length; i++) i]
      ..sort((a, b) => verts[b].dot(c).compareTo(verts[a].dot(c)));
    final five = order.take(5).toList();
    // Sort the five corners around the face centre.
    final e1 = (verts[five.first] - c * verts[five.first].dot(c)).unit;
    final e2 = c.cross(e1);
    five.sort((a, b) {
      final pa = verts[a], pb = verts[b];
      return math
          .atan2(pa.dot(e2), pa.dot(e1))
          .compareTo(math.atan2(pb.dot(e2), pb.dot(e1)));
    });
    faces.add(five);
  }
  return (verts: verts, faces: faces);
}();

/// HTML lights: `AmbientLight(0xffffff, 0.7)`, `DirectionalLight(0xffffff,
/// 1.1)` at (15, 35, 20) and `DirectionalLight(0xffffff, 0.5)` at (-15, 20,
/// -15), normalised.
const _V _keyLight = _V(0.3487, 0.8137, 0.4650);
const _V _fillLight = _V(-0.5145, 0.6860, -0.5145);
const double _ambient = 0.7;
const double _keyPower = 1.1;
const double _fillPower = 0.5;

/// A surface turned to the camera (round meshes) and the side of an
/// upright mesh turned to the camera and the key light.
const _V _viewNormal = _V(0, 0.48, 0.88);
const _V _sideNormal = _V(0.3, 0.2, 0.93);

/// MeshStandardMaterial look: ambient light plus both lights' Lambert
/// terms on a surface with normal [n] (the HTML renders without tone
/// mapping, so lit tops come out bright).
Color _lit(Color c, _V n) {
  final k =
      _ambient +
      _keyPower * math.max(0.0, n.dot(_keyLight)) +
      _fillPower * math.max(0.0, n.dot(_fillLight));
  double channel(double v) => math.min(1.0, v * k);
  return Color.from(
    alpha: c.a,
    red: channel(c.r),
    green: channel(c.g),
    blue: channel(c.b),
  );
}

/// A metal's diffuse colour (`metalness` darkens MeshStandardMaterial
/// without an environment map).
Color _metal(Color c, double metalness) =>
    Color.lerp(c, _Colors.black, metalness * 0.55)!;

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

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer; each
/// queued group draws its own parts back to front.
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

  /// Queues [draw] at the depth of [point].
  void at(_V point, VoidCallback draw) => later(cam.depth(point), draw);

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

  void _fillPath(Path path, Color color) =>
      canvas.drawPath(path, pens.fill..color = color);

  void _edge(Path path, Color color, double alpha, {double width = 0.8}) =>
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = width
          ..color = labShade(color, -0.5).withValues(alpha: alpha),
      );

  // ---------------------------------------------------------- primitives

  /// BoxGeometry of [size] in the frame [xf]: the faces turned to the
  /// camera, lit, with soft edges.
  void box(_Xf xf, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final wn = xf.dir(n);
      if (wn.length < 1e-9) return;
      final mid = xf(n.x * hx, n.y * hy, n.z * hz);
      if (wn.dot(cam.eye - mid) <= 0) continue;
      final path = polygon([
        for (final k in face.corners) cam.p(xf(k.x * hx, k.y * hy, k.z * hz)),
      ]);
      _fillPath(path, _lit(color, wn.unit));
      if (edge > 0) _edge(path, color, edge);
    }
  }

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf], its axis
  /// along the frame's y: its outline (hull of both rims), shading along
  /// its side and, unless [open], the end cap turned to the camera.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 16,
    bool open = false,
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
    _fillPath(polygon(_hull([...top, ...bottom])), body);
    _bands(
      cam.p(a),
      cam.p(b),
      rBottom * xf.x.length * cam.scaleAt(a),
      rTop * xf.x.length * cam.scaleAt(b),
      body,
    );
    if (open) return;
    final axis = xf.y.unit;
    final showTop = (cam.eye - b).dot(axis) > 0;
    if ((showTop ? rTop : rBottom) > 0.0005) {
      _fillPath(
        polygon(showTop ? top : bottom),
        _lit(color, showTop ? axis : -axis),
      );
    }
  }

  /// ConeGeometry([r], [h]) centred on [xf] (tip up its y axis).
  void cone(_Xf xf, double r, double h, Color color, {int segments = 12}) =>
      cylinder(xf, 0, r, h, color, segments: segments);

  /// Shading bands along a mesh's side from [pa] to [pb] (half widths [wa],
  /// [wb]): shadow away from the key light, highlight towards it.
  void _bands(Offset pa, Offset pb, double wa, double wb, Color body) {
    final d = pb - pa;
    final len = d.distance;
    if (len < 1 || wa + wb < 2) return;
    var n = Offset(-d.dy / len, d.dx / len);
    // The key light comes from the upper right of the screen.
    if (n.dx < 0 || (n.dx == 0 && n.dy > 0)) n = -n;
    void band(double from, double to, Color color) => _fillPath(
      polygon([
        pa + n * (wa * from),
        pb + n * (wb * from),
        pb + n * (wb * to),
        pa + n * (wa * to),
      ]),
      color,
    );
    band(-0.92, -0.3, labShade(body, -0.2));
    band(0.28, 0.6, labShade(body, 0.22));
  }

  /// An open-ended tier of the sieve (CylinderGeometry, `openEnded`): its
  /// inside first, then [inside] (what shows through the opening), then the
  /// outside of the wall facing the camera and the lit rim.
  void tier(_Xf xf, double r, double h, Color color, VoidCallback inside) {
    const segments = 32;
    final hh = h / 2;
    final top = <_V>[];
    final bottom = <_V>[];
    for (var i = 0; i < segments; i++) {
      final t = 2 * math.pi * i / segments;
      top.add(xf(r * math.cos(t), hh, r * math.sin(t)));
      bottom.add(xf(r * math.cos(t), -hh, r * math.sin(t)));
    }
    final tops = [for (final v in top) cam.p(v)];
    final bottoms = [for (final v in bottom) cam.p(v)];
    _fillPath(
      polygon(_hull([...tops, ...bottoms])),
      labShade(_lit(color, _sideNormal), -0.45),
    );
    inside();
    // The wall's outside where it faces the camera.
    final front = <int>[];
    final rimCentre = xf(0, hh, 0);
    for (var i = 0; i < segments; i++) {
      if ((top[i] - rimCentre).dot(cam.eye - top[i]) > 0) front.add(i);
    }
    if (front.isNotEmpty) {
      // The facing run, in order around the rim.
      var startAt = 0;
      for (var i = 0; i < front.length; i++) {
        final prev = (front[i] - 1 + segments) % segments;
        if (!front.contains(prev)) startAt = i;
      }
      final run = [
        for (var i = 0; i < front.length; i++)
          front[(startAt + i) % front.length],
      ];
      final pts = [
        for (final i in run) tops[i],
        for (final i in run.reversed) bottoms[i],
      ];
      final wall = _lit(color, _sideNormal);
      _fillPath(polygon(pts), wall);
      final mid = run[run.length ~/ 2];
      _bands(
        Offset.lerp(tops[run.first], bottoms[run.first], 0.5)!,
        Offset.lerp(tops[run.last], bottoms[run.last], 0.5)!,
        (tops[mid] - bottoms[mid]).distance / 2,
        (tops[mid] - bottoms[mid]).distance / 2,
        wall,
      );
    }
    canvas.drawPath(
      polygon(tops),
      pens.stroke
        ..strokeWidth = 1.2
        ..color = labShade(_lit(color, _V.up), 0.15),
    );
  }

  /// A wireframe disc (CylinderGeometry with `wireframe: true`): the rim
  /// and the spokes of its cap triangles.
  void wireDisc(_Xf xf, double r, Color color, {int segments = 32}) {
    final rim = [
      for (var i = 0; i < segments; i++)
        cam.p(
          xf(
            r * math.cos(2 * math.pi * i / segments),
            0,
            r * math.sin(2 * math.pi * i / segments),
          ),
        ),
    ];
    final c = cam.p(xf.o);
    final ink = _lit(color, _V.up);
    final paint = pens.stroke
      ..strokeWidth = 0.9
      ..color = ink;
    canvas.drawPath(polygon(rim), paint);
    for (final q in rim) {
      canvas.drawLine(c, q, paint);
    }
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
  void sphere(_Xf xf, double r, Color color) =>
      ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color);

  /// TorusGeometry([radius], [tube]) in the frame [xf] (its ring in the
  /// frame's xy plane), from angle [start] over [sweep]: a thick stroke
  /// along the ring with a highlight towards the light.
  void torus(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double start = 0,
    double sweep = 2 * math.pi,
    int segments = 28,
  }) {
    final n = math.max(3, (segments * sweep / (2 * math.pi)).ceil());
    final path = pens.path..reset();
    for (var i = 0; i <= n; i++) {
      final a = start + sweep * i / n;
      final q = cam.p(xf(radius * math.cos(a), radius * math.sin(a), 0));
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    final w = math.max(1.0, 2 * tube * xf.x.length * cam.scaleAt(xf.o));
    final body = _lit(color, _sideNormal);
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = w
        ..color = labShade(body, -0.18),
    );
    canvas.save();
    canvas.translate(0, -w * 0.18);
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = w * 0.5
        ..color = labShade(body, 0.15),
    );
    canvas.restore();
  }

  /// `DodecahedronGeometry` of radius [r] in the frame [xf]: its facing
  /// pentagons, each lit flat.
  void dodecahedron(_Xf xf, double r, Color color, {double edge = 0.25}) {
    final d = _dodeca;
    final pts = [for (final v in d.verts) xf(v.x * r, v.y * r, v.z * r)];
    for (final face in d.faces) {
      var c = _V.zero;
      for (final i in face) {
        c = c + pts[i];
      }
      c = c * (1 / face.length);
      final n = c - xf.o;
      if (n.length < 1e-9 || n.dot(cam.eye - c) <= 0) continue;
      final path = polygon([for (final i in face) cam.p(pts[i])]);
      _fillPath(path, _lit(color, n.unit));
      if (edge > 0) _edge(path, color, edge, width: 0.6);
    }
  }

  /// `ConeGeometry(r, h, 4)` in the frame [xf]: a four-sided pyramid, its
  /// facing faces lit flat (the granite flake).
  void pyramid(_Xf xf, double r, double h, Color color) {
    final apex = xf(0, h / 2, 0);
    final base = [
      for (var i = 0; i < 4; i++)
        xf(
          r * math.sin(i * math.pi / 2),
          -h / 2,
          r * math.cos(i * math.pi / 2),
        ),
    ];
    final centre = xf(0, 0, 0);
    void face(List<_V> q) {
      var c = _V.zero;
      for (final v in q) {
        c = c + v;
      }
      c = c * (1 / q.length);
      var n = (q[1] - q[0]).cross(q[2] - q[0]);
      if (n.length < 1e-9) return;
      if (n.dot(c - centre) < 0) n = -n;
      if (n.dot(cam.eye - c) <= 0) return;
      final path = polygon([for (final v in q) cam.p(v)]);
      _fillPath(path, _lit(color, n.unit));
      _edge(path, color, 0.4, width: 0.7);
    }

    face(base);
    for (var i = 0; i < 4; i++) {
      face([apex, base[i], base[(i + 1) % 4]]);
    }
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the soil
/// table between the forest edge and the ploughed farm with the sieve
/// tower and the trays; S2 the Stone Age workshop with the three rocks,
/// the hammerstone, the flake and the plank. Then the labels, the held
/// object on top and the confetti.
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
    if (s.soil) {
      _paintSoilLab(g);
    } else {
      _paintWorkshop(g);
    }
    g.flush();
    final held = s.held;
    if (held != null) _paintObject(g, held);
    if (showLabels) _paintLabels(g);
    _paintConfetti(canvas);
  }

  /// Queues [o] at its depth unless it is held (drawn on top instead).
  void _queue(_Gfx g, _Obj o, _V at) {
    if (scene.held == o) return;
    g.at(at, () => _paintObject(g, o));
  }

  /// Draws a movable object now.
  void _paintObject(_Gfx g, _Obj o) {
    final s = scene;
    switch (o) {
      case _Obj.forestShovel || _Obj.farmShovel:
        _paintShovel(g, s.shovelXf(o == _Obj.forestShovel));
      case _Obj.forestBag || _Obj.farmBag:
        _paintBag(g, o == _Obj.forestBag);
      case _Obj.hammer:
        _paintHammer(g);
      case _Obj.flake:
        _paintFlake(g);
      default:
        break;
    }
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: the two plots and the lab table (drawn first, as the
  /// floor), then the trees, furrows, shovels, bags, sieve, trays and the
  /// earthworm, far to near.
  void _paintSoilLab(_Gfx g) {
    final s = scene;
    g.box(const _Xf.at(_forestPlot), _plotSize, _Colors.forestSoil, edge: 0.4);
    g.box(const _Xf.at(_farmPlot), _plotSize, _Colors.farmSoil, edge: 0.4);
    g.box(const _Xf.at(_table1), _table1Size, _Colors.labTable, edge: 0.45);
    // Pine trees on the forest plot.
    for (final x in _pineXs) {
      final trunk = const _Xf.at(_forestPlot).child(_V(x, _trunkY, _pineZ));
      g.at(trunk.o, () {
        g.cylinder(
          trunk,
          _trunkTop,
          _trunkBottom,
          _trunkH,
          _Colors.trunk,
          segments: 10,
        );
        g.cone(
          trunk.child(const _V(0, _coneLift, 0)),
          _coneR,
          _coneH,
          _Colors.pine,
          segments: 8,
        );
      });
    }
    // Furrows (lying along z) and the crop sprouts on the farm plot.
    for (var i = 0; i < _furrowCount; i++) {
      final x = -1.2 + 0.8 * i;
      final furrow = const _Xf.at(
        _farmPlot,
      ).child(_V(x, _furrowY, 0), rx: math.pi / 2);
      g.at(furrow.o + const _V(0, -0.3, -1), () {
        g.cylinder(
          furrow,
          _furrowR,
          _furrowR,
          _furrowLen,
          _Colors.furrow,
          segments: 10,
        );
      });
      final sprout = const _Xf.at(
        _farmPlot,
      ).child(_V(x, _sproutY, -0.5 + 0.8 * (i % 2)));
      g.at(
        sprout.o,
        () => g.cone(sprout, _sproutR, _sproutH, _Colors.sprout, segments: 6),
      );
    }
    _queue(g, _Obj.forestShovel, s.forestShovel.at(s.time));
    _queue(g, _Obj.farmShovel, s.farmShovel.at(s.time));
    for (final b in [_Obj.forestBag, _Obj.farmBag]) {
      final bag = s.bagOf(b);
      if (bag.shown) _queue(g, b, bag.pos.at(s.time) + const _V(0, 0.6, 0));
    }
    g.at(s.sieveAt, () => _paintSieve(g));
    for (var row = 0; row < 2; row++) {
      for (var i = 0; i < 4; i++) {
        final at = _Scene.trayAt(row, i);
        g.at(at, () => _paintTray(g, row, i));
      }
    }
    if (s.worm) {
      final worm = s.wormXf();
      g.later(g.cam.depth(worm.o) - 0.3, () {
        g.torus(
          worm.child(_V.zero, rx: math.pi / 2),
          _wormR,
          _wormTube,
          _Colors.earthworm,
          sweep: math.pi * 1.5,
        );
      });
    }
  }

  /// `createShovelModel()`: steel blade, wooden shaft, dark grip.
  void _paintShovel(_Gfx g, _Xf xf) {
    g.box(
      xf.child(const _V(0, 0.3, 0)),
      const _V(0.5, 0.6, 0.06),
      _metal(_Colors.blade, 0.5),
      edge: 0.5,
    );
    g.cylinder(
      xf.child(const _V(0, 1.1, 0)),
      0.06,
      0.06,
      1.4,
      _Colors.shaft,
      segments: 8,
    );
    g.box(
      xf.child(const _V(0, 1.8, 0)),
      const _V(0.4, 0.12, 0.12),
      _Colors.grip,
      edge: 0.5,
    );
  }

  /// `createSoilBagModel()`: a burlap sack on a round base, tied below a
  /// flared open mouth, heaped with soil and its moss or crop specks.
  void _paintBag(_Gfx g, bool forest) {
    final s = scene;
    final bag = forest ? s.forestBag : s.farmBag;
    if (bag.scale.at(s.time) < 0.02) return;
    final xf = s.bagXf(bag);
    g.sphere(
      xf.child(const _V(0, 0.35, 0), sx: 1, sy: 0.6, sz: 0.9),
      0.65,
      _Colors.burlap,
    );
    g.cylinder(
      xf.child(const _V(0, 0.55, 0)),
      0.55,
      0.65,
      1.1,
      _Colors.burlap,
      open: true,
    );
    g.torus(
      xf.child(const _V(0, 1.1, 0), rx: math.pi / 2),
      0.4,
      0.08,
      _Colors.tie,
    );
    g.cylinder(
      xf.child(const _V(0, 1.25, 0)),
      0.6,
      0.4,
      0.35,
      _Colors.burlap,
      open: true,
    );
    g.sphere(
      xf.child(const _V(0, 1.28, 0), sy: 0.5),
      0.5,
      forest ? _Colors.forestHeap : _Colors.farmHeap,
    );
    final speck = forest ? _Colors.moss : _Colors.cropSpeck;
    for (final v in s.decor.specks[forest ? 0 : 1]) {
      g.dodecahedron(xf.child(v), 0.06, speck, edge: 0);
    }
  }

  /// The sieve tower: back of the base ring, funnel, legs, front of the
  /// ring, the fine tier (yellow mesh) and the coarse tier (amber mesh)
  /// with its brass handles.
  void _paintSieve(_Gfx g) {
    final xf = _Xf.at(scene.sieveAt);
    final steel = _metal(_Colors.stand, 0.7);
    final ring = xf.child(const _V(0, _baseRingY, 0), rx: math.pi / 2);
    g.torus(ring, _baseRingR, _thinTube, steel, start: math.pi, sweep: math.pi);
    g.cone(
      xf.child(const _V(0, _funnelY, 0), rx: math.pi),
      _funnelR,
      _funnelH,
      _metal(_Colors.funnel, 0.5),
      segments: 32,
    );
    for (final x in const [-_legX, _legX]) {
      g.cylinder(
        xf.child(const _V(0, -_legH / 2, 0) + _V(x, 0, 0)),
        _legR,
        _legR,
        _legH,
        steel,
        segments: 8,
      );
    }
    g.torus(ring, _baseRingR, _thinTube, steel, sweep: math.pi);
    final mid = xf.child(const _V(0, _midTierY, 0));
    g.tier(mid, _midRimR, _tierH, _metal(_Colors.midRim, 0.8), () {
      g.wireDisc(
        mid.child(const _V(0, _meshDrop, 0)),
        _midMeshR,
        _Colors.fineMesh,
      );
    });
    final top = xf.child(const _V(0, _topTierY, 0));
    g.tier(top, _topRimR, _tierH, _metal(_Colors.topRim, 0.8), () {
      g.wireDisc(
        top.child(const _V(0, _meshDrop, 0)),
        _topMeshR,
        _Colors.coarseMesh,
      );
    });
    for (final x in const [-_handleX, _handleX]) {
      g.torus(
        top.child(_V(x, 0, 0), ry: math.pi / 2),
        _handleR,
        _handleTube,
        _metal(_Colors.brass, 0.6),
      );
    }
  }

  /// `createTrayModel()`: the white tray with its rims and, once sieved,
  /// its content (humus mound with leaves, sand dune, pebbles) at its
  /// height. The earthworm trays stay empty (the HTML never shows their
  /// soil bed); the earthworm itself wriggles in the forest row's.
  void _paintTray(_Gfx g, int row, int i) {
    final s = scene;
    final xf = _Xf.at(_Scene.trayAt(row, i));
    final base = _metal(_Colors.trayBase, 0.4);
    final rim = _metal(_Colors.trayRim, 0.5);
    g.box(xf, _traySize, base, edge: 0.35);
    const hx = _trayW / 2, hz = _trayD / 2;
    const ry = _rimH / 2;
    void rimAt(_V at, _V size) => g.box(xf.child(at), size, rim, edge: 0.35);
    rimAt(_V(0, ry, -hz), const _V(_trayW + 0.04, _rimH, _rimT));
    rimAt(_V(-hx, ry, 0), const _V(_rimT, _rimH, _trayD));
    rimAt(_V(hx, ry, 0), const _V(_rimT, _rimH, _trayD));
    if (i < 3) {
      final k = s.fill[row * 3 + i];
      if (k > 0) {
        final content = xf.child(const _V(0, _contentY, 0), sy: k);
        switch (i) {
          case 0:
            _paintHumus(g, content, row);
          case 1:
            _paintSand(g, content);
          default:
            _paintPebbles(g, content, row);
        }
      }
    }
    rimAt(_V(0, ry, hz), const _V(_trayW + 0.04, _rimH, _rimT));
  }

  /// Humus: a dark domed mound strewn with rotted leaves.
  void _paintHumus(_Gfx g, _Xf content, int row) {
    g.sphere(
      content.child(const _V(0, 0.1, 0), sx: 1.1, sy: 0.45, sz: 0.85),
      0.65,
      row == 0 ? _Colors.humusForest : _Colors.humusFarm,
    );
    for (final b in scene.decor.leaves[row]) {
      g.box(
        content.child(b.at, rx: b.turn.x, ry: b.turn.y, rz: b.turn.z),
        b.size,
        b.color,
        edge: 0,
      );
    }
  }

  /// Sand: a golden dune on a flat bed.
  void _paintSand(_Gfx g, _Xf content) {
    g.box(
      content.child(const _V(0, 0.05, 0)),
      const _V(1.35, 0.15, 0.95),
      _Colors.sand,
      edge: 0.2,
    );
    g.cone(
      content.child(const _V(0, 0.15, 0), sx: 1.05, sz: 0.85),
      0.7,
      0.5,
      _Colors.sand,
      segments: 16,
    );
  }

  /// Pebbles: rounded stones and blocky gravel in five greys.
  void _paintPebbles(_Gfx g, _Xf content, int row) {
    final bits = [...scene.decor.pebbles[row]]
      ..sort(
        (a, b) => g.cam
            .depth(content.at(b.at))
            .compareTo(g.cam.depth(content.at(a.at))),
      );
    for (final b in bits) {
      final xf = content.child(b.at, rx: b.turn.x, ry: b.turn.y, rz: b.turn.z);
      if (b.round) {
        g.dodecahedron(xf, b.size.x, b.color, edge: 0.2);
      } else {
        g.box(xf, b.size, b.color, edge: 0.25);
      }
    }
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the workshop table (the floor), the rocks or what
  /// is left of them, the plank with its shavings, the hammerstone and the
  /// flake, far to near.
  void _paintWorkshop(_Gfx g) {
    final s = scene;
    g.box(
      const _Xf.at(_table2),
      _table2Size,
      _Colors.workshopTable,
      edge: 0.45,
    );
    if (!s.slateBroken) {
      g.at(
        _slateAt,
        () => g.box(
          const _Xf.at(_slateAt),
          _slateSize,
          _Colors.slateRock,
          edge: 0.5,
        ),
      );
    } else {
      for (var i = 0; i < _tileCount; i++) {
        final at = _V(_slateAt.x, 0.2 + i * 0.15, _slateAt.z + (i - 1.5) * 0.3);
        g.later(
          g.cam.depth(at) - i * 0.01,
          () => g.box(
            _Xf.at(at),
            _V(_slateSize.x, _tileH, _slateSize.z),
            _Colors.slateRock,
            edge: 0.6,
          ),
        );
      }
    }
    if (!s.sandstoneBroken) {
      g.at(
        _sandstoneAt,
        () => g.dodecahedron(
          const _Xf.at(_sandstoneAt),
          _rockR,
          _Colors.sandstone,
        ),
      );
    } else {
      for (final at in s.decor.grains) {
        g.at(
          at,
          () => g.box(
            _Xf.at(at),
            const _V(_grainSize, _grainSize, _grainSize),
            _Colors.sandGrain,
            edge: 0.3,
          ),
        );
      }
    }
    g.at(_graniteAt, () => _paintGranite(g));
    g.at(_plankAt, () {
      final k = s.plankScale;
      g.box(
        const _Xf.at(_plankAt).scaled(k),
        _plankSize,
        _Colors.plank,
        edge: 0.45,
      );
    });
    if (s.shaved) {
      for (final (at, turn) in s.decor.shavings) {
        g.later(
          g.cam.depth(at) - 0.5,
          () => g.torus(
            _Xf.at(at).child(_V.zero, rx: math.pi / 2, rz: turn),
            0.12,
            0.03,
            _Colors.shaving,
            sweep: math.pi * 1.2,
            segments: 12,
          ),
        );
      }
    }
    _queue(g, _Obj.hammer, s.hammer.at(s.time));
    if (s.flakeShown) _queue(g, _Obj.flake, s.flake.at(s.time));
  }

  /// The speckled granite: a grey dodecahedron with dark specks on the
  /// side facing the camera.
  void _paintGranite(_Gfx g) {
    const xf = _Xf.at(_graniteAt);
    g.dodecahedron(xf, _rockR, _Colors.granite);
    for (final v in scene.decor.specksOnGranite) {
      final at = _graniteAt + v;
      if (v.unit.dot((g.cam.eye - at).unit) < 0.25) continue;
      g.box(
        _Xf.at(at),
        const _V(_speckSize, _speckSize, _speckSize),
        _Colors.speck,
        edge: 0,
      );
    }
  }

  /// The hammerstone: a dark flattened stone head on a wooden handle.
  void _paintHammer(_Gfx g) {
    final s = scene;
    final xf = _Xf.at(s.hammer.at(s.time));
    final handle = xf.child(const _V(0, 0, _handleZ), rx: math.pi / 2);
    g.cylinder(
      handle,
      _handleRadius,
      _handleRadius,
      _handleLen,
      _Colors.hammerHandle,
      segments: 10,
    );
    g.sphere(
      xf.child(_V.zero, sx: _headScale.x, sy: _headScale.y, sz: _headScale.z),
      _headR,
      _Colors.hammerHead,
    );
  }

  /// The granite flake: a four-sided point lying forward.
  void _paintFlake(_Gfx g) {
    final s = scene;
    g.pyramid(
      _Xf.at(s.flake.at(s.time)).child(_V.zero, rx: math.pi / 2),
      _flakeR,
      _flakeH,
      _Colors.flake,
    );
  }

  // -------------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip (HTML
  /// `createTextSprite`), centred on the sprite's place.
  void _paintLabels(_Gfx g) {
    final s = scene;
    if (s.soil) {
      _chipAt(g, _forestPlot + _plotLabelAt, _t('lbl_forest_edge'));
      _chipAt(g, _farmPlot + _plotLabelAt, _t('lbl_ploughed_farm'));
      _chipAt(g, s.sieveAt + _sieveLabelAt, _t('lbl_sieve'));
      for (var row = 0; row < 2; row++) {
        // Tray chips share the room between their trays.
        final room =
            (g.cam.p(_Scene.trayAt(row, 1)) - g.cam.p(_Scene.trayAt(row, 0)))
                .distance -
            _chipGap;
        for (var i = 0; i < 4; i++) {
          _chipAt(
            g,
            _Scene.trayAt(row, i) + const _V(0, _trayLabelY, 0),
            _t(_Obj.trays[i].nameKey),
            maxWidth: room,
          );
        }
      }
      for (final b in [_Obj.forestBag, _Obj.farmBag]) {
        final bag = s.bagOf(b);
        if (!bag.shown || bag.scale.at(s.time) < 0.5) continue;
        _chipAt(g, s.bagXf(bag).at(_bagLabelAt), _t(b.nameKey));
      }
    } else {
      if (!s.slateBroken) {
        _chipAt(g, _slateAt + _rockLabelAt, _t('lbl_slate'));
      }
      if (!s.sandstoneBroken) {
        _chipAt(g, _sandstoneAt + _rockLabelAt, _t('lbl_sandstone'));
      }
      _chipAt(g, _graniteAt + _rockLabelAt, _t('lbl_granite'));
      _chipAt(g, s.hammer.at(s.time) + _hammerLabelAt, _t('lbl_hammerstone'));
      _chipAt(g, _plankAt + _plankLabelAt, _t('lbl_wood_piece'));
      if (s.flakeShown) {
        _chipAt(g, s.flake.at(s.time) + _flakeLabelAt, _t('lbl_granite_flake'));
      }
    }
  }

  /// A chip centred on the world point [at] (skipped when it is behind the
  /// camera or off the canvas), shrunk to [maxWidth] if given.
  void _chipAt(_Gfx g, _V at, String text, {double? maxWidth}) {
    if (g.cam.depth(at) < _clipDepth) return;
    final p = g.cam.p(at);
    if (p.dx < scene.labelLeft || p.dx > scene.labelRight) return;
    final size = cache.chipSize(text);
    final k = maxWidth == null || maxWidth <= 0
        ? 1.0
        : math.min(1.0, maxWidth / size.width);
    var rect = Rect.fromCenter(
      center: p,
      width: size.width * k,
      height: size.height * k,
    );
    if (rect.right > scene.labelRight) {
      rect = rect.shift(Offset(scene.labelRight - rect.right, 0));
    }
    if (rect.left < scene.labelLeft) {
      rect = rect.shift(Offset(scene.labelLeft - rect.left, 0));
    }
    _drawChip(g, rect, text, k);
  }

  /// HTML `updateAllSpriteLabels`: a dark rounded box with a faint white
  /// border and white bold text.
  void _drawChip(_Gfx g, Rect rect, String text, double k) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.55 * k),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text);
    g.canvas.save();
    g.canvas.translate(rect.center.dx, rect.center.dy);
    if (k < 1) g.canvas.scale(k, k);
    tp.paint(g.canvas, Offset(-tp.width / 2, -tp.height / 2));
    g.canvas.restore();
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

/// The magnified tray pictures of the inspection panel (the HTML's 🍂, ⏳,
/// 🪨 and 🪱 on their radial gradients), redrawn: bouncing rotted leaves
/// on dark humus crumbs, crystalline quartz grains, water-worn pebbles and
/// a wriggling earthworm.
class _LensPainter extends CustomPainter {
  _LensPainter({required this.lens, required this.time}) : super(repaint: time);

  final _Lens lens;
  final ValueListenable<double> time;

  static final List<Offset> _crumbs = () {
    final rnd = math.Random(5);
    return [
      for (var i = 0; i < 40; i++) Offset(rnd.nextDouble(), rnd.nextDouble()),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = rect.center;
    final r = size.shortestSide / 2;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * 1.42,
          [lens.inner, lens.inner, lens.outer, lens.outer],
          const [0, 0.2, 0.8, 1],
        ),
    );
    final now = time.value;
    switch (lens) {
      case _Lens.humus:
        _humus(canvas, size, now);
      case _Lens.sand:
        _sand(canvas, size);
      case _Lens.pebbles:
        _pebbles(canvas, size);
      case _Lens.worm:
        _worm(canvas, size, now);
    }
  }

  /// Dark crumbs and three fallen leaves (Tailwind `animate-bounce`).
  void _humus(Canvas canvas, Size size, double now) {
    final paint = Paint();
    for (var i = 0; i < _crumbs.length; i++) {
      final q = _crumbs[i];
      paint.color = i.isEven
          ? const Color(0xFF2A1D13)
          : const Color(0xFF5B3A1E);
      canvas.drawCircle(
        Offset(q.dx * size.width, q.dy * size.height),
        size.width * (0.015 + 0.012 * (i % 3)),
        paint,
      );
    }
    // Up 25% at the start of each second, back down in the middle.
    final bounce = (math.cos(now * math.pi)).abs();
    final lift = -size.height * 0.08 * bounce;
    const leaves = [
      (Offset(0.42, 0.5), 0.6, Color(0xFFEA580C)),
      (Offset(0.58, 0.46), -0.5, Color(0xFFB45309)),
      (Offset(0.5, 0.58), 0.1, Color(0xFFD97706)),
    ];
    for (final (at, turn, color) in leaves) {
      _leaf(
        canvas,
        Offset(at.dx * size.width, at.dy * size.height + lift),
        size.width * 0.2,
        turn,
        color,
      );
    }
  }

  void _leaf(Canvas canvas, Offset c, double len, double turn, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(turn);
    final path = Path()
      ..moveTo(-len / 2, 0)
      ..quadraticBezierTo(0, -len * 0.42, len / 2, 0)
      ..quadraticBezierTo(0, len * 0.42, -len / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawLine(
      Offset(-len * 0.62, 0),
      Offset(len / 2, 0),
      Paint()
        ..color = labShade(color, -0.45)
        ..strokeWidth = math.max(1, len * 0.06)
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  /// Angular quartz grains with bright facets.
  void _sand(Canvas canvas, Size size) {
    final rnd = math.Random(9);
    final paint = Paint();
    for (var i = 0; i < 46; i++) {
      final c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final r = size.width * (0.025 + rnd.nextDouble() * 0.03);
      final turn = rnd.nextDouble() * math.pi;
      final path = Path();
      for (var k = 0; k < 5; k++) {
        final a = turn + k * 2 * math.pi / 5;
        final rr = r * (0.7 + 0.3 * ((k * 7 + i) % 3) / 2);
        final q = c + Offset(math.cos(a), math.sin(a)) * rr;
        k == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
      }
      path.close();
      paint.color = i % 3 == 0
          ? const Color(0xFFFEF9C3)
          : (i % 3 == 1 ? const Color(0xFFFDE047) : const Color(0xFFCA8A04));
      canvas.drawPath(path, paint);
    }
  }

  /// Rounded water-worn pebbles with soft highlights.
  void _pebbles(Canvas canvas, Size size) {
    const stones = [
      (Offset(0.32, 0.38), 0.17, Color(0xFF94A3B8)),
      (Offset(0.64, 0.34), 0.14, Color(0xFF78716C)),
      (Offset(0.5, 0.62), 0.19, Color(0xFF64748B)),
      (Offset(0.25, 0.68), 0.11, Color(0xFFA8A29E)),
      (Offset(0.74, 0.64), 0.12, Color(0xFF475569)),
    ];
    for (final (at, r, color) in stones) {
      final c = Offset(at.dx * size.width, at.dy * size.height);
      final rr = Rect.fromCenter(
        center: c,
        width: r * 2.3 * size.width,
        height: r * 1.7 * size.width,
      );
      canvas.drawOval(
        rr,
        Paint()
          ..shader = ui.Gradient.radial(
            c - Offset(rr.width * 0.18, rr.height * 0.22),
            rr.width * 0.7,
            [labShade(color, 0.35), color, labShade(color, -0.4)],
            const [0, 0.5, 1],
          ),
      );
    }
  }

  /// A pink, ringed earthworm wriggling across the soil.
  void _worm(Canvas canvas, Size size, double now) {
    final w = size.width;
    final path = Path();
    final pts = <Offset>[];
    for (var i = 0; i <= 24; i++) {
      final u = i / 24;
      final p = Offset(
        w * (0.18 + 0.64 * u),
        size.height * 0.52 +
            math.sin(u * math.pi * 2.2 + now * 4) * size.height * 0.09,
      );
      pts.add(p);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.11
        ..color = _Colors.pink400,
    );
    canvas.drawPath(
      path.shift(Offset(0, -w * 0.02)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.035
        ..color = _Colors.pink300.withValues(alpha: 0.8),
    );
    final ring = Paint()
      ..color = const Color(0xFFBE185D)
      ..strokeWidth = math.max(1, w * 0.012);
    for (var i = 3; i < pts.length - 2; i += 3) {
      final d = pts[i + 1] - pts[i - 1];
      final n = Offset(-d.dy, d.dx) / math.max(0.001, d.distance);
      canvas.drawLine(pts[i] + n * (w * 0.05), pts[i] - n * (w * 0.05), ring);
    }
    // The clitellum band and the head.
    canvas.drawCircle(
      pts[17],
      w * 0.06,
      Paint()..color = const Color(0xFFDB2777),
    );
    canvas.drawCircle(pts.last, w * 0.05, Paint()..color = _Colors.pink400);
  }

  @override
  bool shouldRepaint(covariant _LensPainter old) =>
      old.lens != lens || old.time != time;
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
