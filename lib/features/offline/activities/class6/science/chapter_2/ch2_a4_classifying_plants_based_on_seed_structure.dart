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

/// Class 6 Science • Chapter 2 • Activity 4
/// Classifying Plants Based on Seed Structure.
///
/// Native Flutter port of
/// `Cl6S-Ch02-A4-Classifying_Plants_Based_on_Seed_Structure.html`
/// (Three.js r128). The lab bench is redrawn by a small painter ([_Gfx])
/// through a perspective projection of the HTML camera: position (0, 10,
/// 15), look-at (0, 0, 0), 45° field of view; the scene is fitted into the
/// part of the canvas that no card covers.
///
/// Scenario 1 (The Dicot Detective): the learner drags a dry chickpea seed
/// into a beaker of water, where it swells and then moves to the dissection
/// tray; drops the scalpel on it to peel off the brown seed coat; taps it,
/// and it splits into two cotyledons (a dicot). Dropped into the Plant
/// Grower's funnel, it grows into a chickpea plant: the magnifying glass
/// shows the net-like (reticulate) venation of its leaves, and pulling the
/// plant up out of its pot shows a taproot.
///
/// Scenario 2 (The Monocot Mystery): the same steps with a maize kernel,
/// which does not split (one cotyledon, a monocot) and grows into a tall
/// maize plant with parallel venation and fibrous roots. Each finding opens
/// an observation card; 'Review Connections' opens the scenario's summary
/// (seed → leaf → root).
class Ch2A4ClassifyingPlantsBasedOnSeedStructurePage extends StatefulWidget {
  const Ch2A4ClassifyingPlantsBasedOnSeedStructurePage({super.key});

  @override
  State<Ch2A4ClassifyingPlantsBasedOnSeedStructurePage> createState() =>
      _SeedStructureLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, played from the app's bundled assets (paths
/// relative to `assets/`). The HTML synthesises its tones with Web Audio;
/// they map to the closest files: 'click' (the seed split, the magnifying
/// glass) and 'pop' (an observation card closed, the camera re-centred) →
/// science/click.mp3; 'success' (the coat peeled, the plant grown, the roots
/// out) and 'chime' (the seed swells, 'Review Connections' appears) →
/// math/success.mp3; 'error' (a missed drop) → science/error.mp3; 'machine'
/// (the Plant Grower takes the seed) → science/dropdown.mp3. The shell's
/// tones: sidebar → dropdown.mp3, scenario change → page_open.mp3, intro
/// curtain → curtain.mp3. Picking up the seed, the scalpel or the plant
/// plays a click (added).
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// The shell's positive feedback (a "Scenario Complete" toast).
  correct('audio/class6/math/success.mp3'),

  /// Missed drop (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// A step's effect is done, 'Review Connections' appears, the summary
  /// opens (HTML `success`, `chime`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An observation card closed, the camera re-centred (HTML `pop`).
  pop('audio/class6/science/click.mp3'),

  /// The Plant Grower swallows the seed (HTML `machine`).
  machine('audio/class6/science/dropdown.mp3'),

  /// The seed, the scalpel or the plant picked up (added).
  pickup('audio/class6/science/click.mp3');

  const _Sound(this.asset);

  /// Asset path relative to `assets/` (the [AssetSource] prefix).
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
  static const Color teal300 = Color(0xFF5EEAD4);
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow300 = Color(0xFFFDE047);
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
  /// `scene.background`: 0x0f172a (dark theme), 0x94a3b8 (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate400;

  /// Lab bench (`0x64748b`).
  static const Color bench = slate500;

  /// `Mats.glass` (beaker, pot) and `Mats.water` (water, magnifier lens).
  static const Color glass = Color(0xFFE0F2FE);
  static const Color water = Color(0xFF38BDF8);

  /// `Mats.tray`, `Mats.machineBody` and `Mats.soil`.
  static const Color tray = slate400;
  static const Color machine = slate600;
  static const Color soil = Color(0xFF3E2723);

  /// Status lights: off `0x111111`, on `0x22c55e`.
  static const Color lightOff = Color(0xFF111111);
  static const Color lightOn = Color(0xFF22C55E);

  /// `Mats.seedBrown` (coats), `Mats.seedYellow` (peeled chickpea) and
  /// `Mats.seedMaize` (peeled maize). The cut faces of the cotyledons are
  /// a paler yellow (added).
  static const Color seedCoat = Color(0xFFA16207);
  static const Color chickpea = yellow300;
  static const Color cotyledonFace = Color(0xFFFEF3A0);
  static const Color maize = Color(0xFFFEF08A);

  /// `Mats.scalpelHandle` (also the magnifier ring) and `Mats.scalpelBlade`.
  static const Color handle = slate900;
  static const Color blade = slate200;

  /// `Mats.stemGreen`, `Mats.leafGreen` and the pale `Mats.rootBrown`.
  static const Color stem = Color(0xFF4ADE80);
  static const Color leaf = Color(0xFF16A34A);
  static const Color root = Color(0xFFD4D4D8);

  /// Text sprites: `#1e293b` chip, `#14b8a6` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = teal500;
  static const Color chipText = white;

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x52000000);

  /// canvas-confetti colours from the HTML.
  static const List<Color> confetti = [teal500, emerald500, yellow300];

  // ----------------------------------------------------------- SVG icons
  static const Color svgSeedDicot = yellow300;
  static const Color svgSeam = Color(0xFFCA8A04);
  static const Color svgSeedMonocot = maize;
  static const Color svgLeafNet = Color(0xFF4ADE80);
  static const Color svgLeafNetVein = Color(0xFF166534);
  static const Color svgLeafParallel = Color(0xFFA3E635);
  static const Color svgLeafParallelVein = Color(0xFF4D7C0F);
  static const Color svgTaproot = Color(0xFF78350F);
  static const Color svgFibrous = Color(0xFF92400E);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables and its teal Tailwind classes): sidebar, canvas, popups,
/// curtain, buttons and readouts.
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
    accent: _Colors.teal500,
    onAccent: _Colors.slate950,
    primary: _Colors.teal600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.teal500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66115E59), // teal-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC5EEAD4), // teal-300/80
    curtainIcon: _Colors.teal400,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.teal300,
    buttonBorder: Color(0xCC14B8A6),
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
    accent: _Colors.teal500,
    onAccent: _Colors.slate950,
    primary: _Colors.teal600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
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
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.teal300,
    buttonBorder: Color(0xCC14B8A6),
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
// From the HTML `i18n`, `ScenariosData`, `labelDict`, `showPopup` (`tTitles`
// / `tDesc`) and `triggerConclusion` tables (Telugu dropped). `sN_hud_M` are
// the HTML "Current Task" lines ("CLICK" reads "TAP", "CLICK and HOLD" reads
// "PRESS and HOLD" for touch); `sN_focus_M`, `sN_act_M`, `sN_obs_M` and
// `sN_expl_M` the HTML step concept, action, observation and explanation
// (the observation and explanation are shown once the step is done). Step 7
// of each scenario is the HTML's seventh HUD task ('Review Connections').
// Shell texts ("Observation", "Enter Lab", tools...) come from
// `kLabCommonStrings`. Keys marked "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Classifying Plants Based on Seed Structure',
    'app_subtitle': 'Class 6 • Diversity in the Living World',
    'scen_1_opt': 'Scenario 1: The Dicot Detective (Chickpea)',
    'scen_2_opt': 'Scenario 2: The Monocot Mystery (Maize)',
    's1_desc':
        'Dissect a chickpea seed and observe the characteristics of the plant it produces to establish the dicot classification.',
    's2_desc':
        'Dissect a maize seed and observe the characteristics of the plant it produces to establish the monocot classification.',
    // ------------------------------------------------ scenario 1 (HUD)
    's1_hud_1':
        'Welcome to the lab! DRAG the dry Chickpea seed and DROP it into the beaker of water to soak it.',
    's1_hud_2':
        'The seed has swollen! DRAG the Scalpel tool and DROP it onto the soaked seed to peel off its coat.',
    's1_hud_3':
        'The seed coat is removed. TAP on the peeled seed to split it open.',
    's1_hud_4':
        "Observe the two halves. Now, DRAG the split seed and DROP it into the Plant Grower machine's funnel.",
    's1_hud_5':
        'A plant has grown! TAP the Magnifying Glass icon near the leaf to observe its vein pattern.',
    's1_hud_6':
        "Finally, PRESS and HOLD the plant's stem, then DRAG UPWARDS to pull it out and observe the roots.",
    's1_hud_7':
        "TAP the 'Review Connections' button to summarize your findings.",
    // ----------------------------------------------- scenario 1 (steps)
    's1_focus_1': 'Seed Preparation',
    's1_focus_2': 'Dissection',
    's1_focus_3': 'Seed Structure',
    's1_focus_4': 'Germination',
    's1_focus_5': 'Leaf Venation',
    's1_focus_6': 'Root System',
    's1_act_1': 'Soak the chickpea seed.',
    's1_act_2': 'Peel the seed coat.',
    's1_act_3': 'Split the peeled seed.',
    's1_act_4': 'Grow the seed in the machine.',
    's1_act_5': 'Examine the leaf.',
    's1_act_6': 'Pull the plant to see roots.',
    // Added: the review step.
    's1_act_7': 'Review the connections between the seed, leaf and root.',
    's1_obs_1': 'The seed absorbs water and swells.',
    's1_obs_2': 'Outer brown layer is removed.',
    's1_obs_3': 'It splits perfectly into two halves.',
    's1_obs_4': 'A chickpea plant grows rapidly.',
    's1_obs_5': 'Veins form a net-like pattern.',
    's1_obs_6': 'One main thick root with smaller side roots.',
    's1_expl_1':
        'Seeds need water to soften their outer coat and begin the germination process.',
    's1_expl_2': 'The seed coat protects the inner parts of the seed.',
    's1_expl_3':
        'These two halves are called cotyledons. Seeds with two cotyledons are Dicots.',
    's1_expl_4': 'The machine simulates the growth of the specific seed type.',
    's1_expl_5':
        'This net-like pattern is called Reticulate Venation, common in dicots.',
    's1_expl_6':
        'This is a Taproot system, characteristic of plants grown from dicot seeds.',
    // ------------------------------------------------ scenario 2 (HUD)
    's2_hud_1':
        "Let's test another seed. DRAG the dry Maize seed and DROP it into the beaker to soak it.",
    's2_hud_2':
        'DRAG the Scalpel tool and DROP it onto the soaked seed to remove its outer layer.',
    's2_hud_3':
        'The outer layer is off. TAP on the maize seed to try and split it.',
    's2_hud_4':
        "It doesn't split! DRAG the whole maize seed and DROP it into the Plant Grower machine's funnel.",
    's2_hud_5':
        'A tall plant has grown! TAP the Magnifying Glass icon near the long leaf to observe its veins.',
    's2_hud_6':
        "Now, PRESS and HOLD the plant's stem, then DRAG UPWARDS to pull it out and observe the roots.",
    's2_hud_7':
        "TAP the 'Review Connections' button to summarize the monocot traits.",
    // ----------------------------------------------- scenario 2 (steps)
    's2_focus_1': 'Seed Preparation',
    's2_focus_2': 'Dissection',
    's2_focus_3': 'Seed Structure',
    's2_focus_4': 'Germination',
    's2_focus_5': 'Leaf Venation',
    's2_focus_6': 'Root System',
    's2_act_1': 'Soak the maize seed.',
    's2_act_2': 'Peel the outer layer.',
    's2_act_3': 'Try to split the seed.',
    's2_act_4': 'Grow the seed in the machine.',
    's2_act_5': 'Examine the leaf.',
    's2_act_6': 'Pull the plant to see roots.',
    // Added: the review step.
    's2_act_7': 'Review the connections between the seed, leaf and root.',
    's2_obs_1': 'The seed absorbs water and softens.',
    's2_obs_2': 'Thin outer layer is removed.',
    's2_obs_3': 'The seed does not split.',
    's2_obs_4': 'A tall maize plant grows rapidly.',
    's2_obs_5': 'Veins run in straight, parallel lines.',
    's2_obs_6': 'A cluster of thin, similar-sized roots.',
    's2_expl_1': 'Soaking prepares the seed for examination.',
    's2_expl_2': 'Unlike the chickpea, the maize kernel is solid inside.',
    's2_expl_3':
        'It remains a single, solid unit. Seeds with one cotyledon are Monocots.',
    's2_expl_4': 'The machine shows the adult form of this specific monocot.',
    's2_expl_5':
        'This is called Parallel Venation, characteristic of monocots.',
    's2_expl_6':
        'This is a Fibrous Root system, typically found in plants grown from monocot seeds.',
    // ---------------------------------------------------- conclusion
    's1_summary':
        "You've uncovered the Dicot pattern! Seeds that split into two (Dicots) grow into plants that have Reticulate Venation (net-like veins) on their leaves and a strong Taproot system underground.",
    's2_summary':
        "You've solved the Monocot mystery! Seeds that do not split (Monocots) grow into plants with Parallel Venation (straight veins) on their leaves and a bushy Fibrous Root system.",
    'success': 'Discovery Complete!',
    'classification_complete': 'Plant Profile Assembled!',
    'select_next_sc_msg':
        'Scenario 1 completed. Select the next from the sidebar!',
    'btn_conclude': 'Review Connections',
    'sum_dicot': 'Dicot Plant',
    'sum_mono': 'Monocot Plant',
    'sum_connections': '{plant} Connections',
    'sum_seed': 'Seed',
    'sum_leaf': 'Leaf',
    'sum_root': 'Root',
    'sum_2cot': '2 Cotyledons',
    'sum_ret': 'Reticulate Venation',
    'sum_tap': 'Taproot System',
    'sum_1cot': '1 Cotyledon',
    'sum_par': 'Parallel Venation',
    'sum_fib': 'Fibrous Root System',
    // ------------------------------------------------ observation cards
    'got_it': 'Got it!',
    'pop_dicot': 'Dicot Seed (2 Cotyledons)',
    'pop_monocot': 'Monocot Seed (1 Cotyledon)',
    'pop_leaf': 'Leaf Venation',
    'pop_root': 'Root System',
    'desc_dicot': 'Two Cotyledons identified.',
    'desc_monocot': 'Solid unit, One Cotyledon identified.',
    'desc_reticulate': 'Net-like pattern (Reticulate Venation).',
    'desc_parallel': 'Parallel lines (Parallel Venation).',
    'desc_tap': 'One main root with side branches (Taproot).',
    'desc_fibrous': 'Cluster of similar thin roots (Fibrous Roots).',
    // ------------------------------------------------------ scene labels
    'lbl_chickpea': 'Chickpea Seed',
    'lbl_maize': 'Maize Seed',
    'lbl_beaker': 'Water Beaker',
    'lbl_scalpel': 'Scalpel Tool',
    'lbl_grower': 'Plant Grower',
    // ------------------------------- steps accordion (HTML teacher board)
    'acc_title': 'Observation Step',
    'acc_step': 'Step',
    'acc_focus': 'Focus',
    'acc_action': 'Action',
    // Added.
    'pending': 'Do this step to see the result.',
    'not_yet': 'Not yet! First: {task}',
    'miss_beaker': 'Missed! Drop the seed right into the beaker of water.',
    'miss_seed': 'Missed! Drop the scalpel right onto the soaked seed.',
    'miss_machine':
        "Missed! Drop the seed right into the Plant Grower's funnel.",
    'pull_higher':
        'Pull higher! Drag the stem further up until the roots come out.',
    'scene_s1':
        'Lab bench with a beaker of water, a chickpea seed, a dissection tray, a scalpel and the Plant Grower machine with a pot beside it',
    'scene_s2':
        'Lab bench with a beaker of water, a maize seed, a dissection tray, a scalpel and the Plant Grower machine with a pot beside it',
  },
  'hi': {
    'app_title': 'बीज संरचना के आधार पर पौधों का वर्गीकरण',
    'app_subtitle': 'कक्षा 6 • सजीव जगत में विविधता',
    'scen_1_opt': 'परिदृश्य 1: द्विबीजपत्री की जांच (चना)',
    'scen_2_opt': 'परिदृश्य 2: एकबीजपत्री का रहस्य (मक्का)',
    's1_desc':
        'चने के बीज को काटें और द्विबीजपत्री वर्गीकरण स्थापित करने के लिए इसके द्वारा उत्पादित पौधे की विशेषताओं का निरीक्षण करें।',
    's2_desc':
        'मक्के के बीज को काटें और एकबीजपत्री वर्गीकरण स्थापित करने के लिए इसके द्वारा उत्पादित पौधे की विशेषताओं का निरीक्षण करें।',
    's1_hud_1':
        'प्रयोगशाला में आपका स्वागत है! सूखे चने के बीज को खींचें (DRAG) और इसे भिगोने के लिए पानी के बीकर में छोड़ें (DROP)।',
    's1_hud_2':
        'बीज फूल गया है! स्कैल्पेल (Scalpel) उपकरण को खींचें और इसका आवरण छीलने के लिए इसे भीगे हुए बीज पर छोड़ें।',
    's1_hud_3':
        'बीज का आवरण हट गया है। छिले हुए बीज को खोलने के लिए उस पर टैप करें।',
    's1_hud_4':
        'दो हिस्सों को ध्यान से देखें। अब, विभाजित बीज को खींचें और प्लांट ग्रोअर (Plant Grower) मशीन कीप में छोड़ें।',
    's1_hud_5':
        'एक पौधा उग आया है! पत्ती की शिराओं के पैटर्न का निरीक्षण करने के लिए पत्ती के पास मैग्निफाइंग ग्लास (Magnifying Glass) आइकन पर टैप करें।',
    's1_hud_6':
        'अंत में, पौधे के तने को दबाकर रखें, फिर इसे बाहर निकालने और जड़ों का निरीक्षण करने के लिए ऊपर की ओर खींचें (DRAG UPWARDS)।',
    's1_hud_7':
        "अपने निष्कर्षों को सारांशित करने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's1_focus_1': 'बीज की तैयारी',
    's1_focus_2': 'विच्छेदन',
    's1_focus_3': 'बीज संरचना',
    's1_focus_4': 'अंकुरण',
    's1_focus_5': 'पत्ती शिराविन्यास',
    's1_focus_6': 'जड़ प्रणाली',
    's1_act_1': 'चने के बीज को भिगोएँ।',
    's1_act_2': 'बीज का आवरण छीलें।',
    's1_act_3': 'छिले हुए बीज को विभाजित करें।',
    's1_act_4': 'मशीन में बीज उगाएँ।',
    's1_act_5': 'पत्ती की जांच करें।',
    's1_act_6': 'जड़ें देखने के लिए पौधे को खींचें।',
    's1_act_7': 'बीज, पत्ती और जड़ के बीच के कनेक्शन की समीक्षा करें।',
    's1_obs_1': 'बीज पानी सोखता है और फूल जाता है।',
    's1_obs_2': 'बाहरी भूरी परत हटा दी जाती है।',
    's1_obs_3': 'यह पूरी तरह से दो हिस्सों में बँट जाता है।',
    's1_obs_4': 'चने का पौधा तेजी से बढ़ता है।',
    's1_obs_5': 'शिराएँ जाल जैसा पैटर्न बनाती हैं।',
    's1_obs_6': 'छोटी साइड जड़ों के साथ एक मुख्य मोटी जड़।',
    's1_expl_1':
        'बीजों को अपने बाहरी आवरण को नरम करने और अंकुरण प्रक्रिया शुरू करने के लिए पानी की आवश्यकता होती है।',
    's1_expl_2': 'बीज का आवरण बीज के भीतरी भागों की रक्षा करता है।',
    's1_expl_3':
        'इन दो हिस्सों को बीजपत्र (Cotyledons) कहा जाता है। दो बीजपत्र वाले बीज द्विबीजपत्री (Dicots) होते हैं।',
    's1_expl_4': 'मशीन विशिष्ट बीज प्रकार के विकास का अनुकरण करती है।',
    's1_expl_5':
        'इस जाल जैसे पैटर्न को जालिका रूपी शिराविन्यास (Reticulate Venation) कहा जाता है, जो द्विबीजपत्री में आम है।',
    's1_expl_6':
        'यह एक मूसला जड़ (Taproot) प्रणाली है, जो द्विबीजपत्री बीजों से उगे पौधों की विशेषता है।',
    's2_hud_1':
        'आइए एक और बीज का परीक्षण करें। सूखे मक्के के बीज को खींचें (DRAG) और इसे भिगोने के लिए बीकर में छोड़ें (DROP)।',
    's2_hud_2':
        'स्कैल्पेल उपकरण को खींचें और इसकी बाहरी परत को हटाने के लिए इसे भीगे हुए बीज पर छोड़ें।',
    's2_hud_3':
        'बाहरी परत हट गई है। मक्के के बीज को विभाजित करने का प्रयास करने के लिए उस पर टैप करें।',
    's2_hud_4':
        'यह विभाजित नहीं होता है! पूरे मक्के के बीज को खींचें और प्लांट ग्रोअर मशीन कीप में छोड़ें।',
    's2_hud_5':
        'एक लंबा पौधा उग आया है! इसकी शिराओं का निरीक्षण करने के लिए लंबी पत्ती के पास मैग्निफाइंग ग्लास आइकन पर टैप करें।',
    's2_hud_6':
        'अब, पौधे के तने को दबाकर रखें, फिर इसे बाहर निकालने और जड़ों का निरीक्षण करने के लिए ऊपर की ओर खींचें।',
    's2_hud_7':
        "एकबीजपत्री लक्षणों को सारांशित करने के लिए 'कनेक्शन की समीक्षा करें' बटन पर टैप करें।",
    's2_focus_1': 'बीज की तैयारी',
    's2_focus_2': 'विच्छेदन',
    's2_focus_3': 'बीज संरचना',
    's2_focus_4': 'अंकुरण',
    's2_focus_5': 'पत्ती शिराविन्यास',
    's2_focus_6': 'जड़ प्रणाली',
    's2_act_1': 'मक्के के बीज को भिगोएँ।',
    's2_act_2': 'बाहरी परत छीलें।',
    's2_act_3': 'बीज को विभाजित करने का प्रयास करें।',
    's2_act_4': 'मशीन में बीज उगाएँ।',
    's2_act_5': 'पत्ती की जांच करें।',
    's2_act_6': 'जड़ें देखने के लिए पौधे को खींचें।',
    's2_act_7': 'बीज, पत्ती और जड़ के बीच के कनेक्शन की समीक्षा करें।',
    's2_obs_1': 'बीज पानी सोखता है और नरम हो जाता है।',
    's2_obs_2': 'पतली बाहरी परत हटा दी जाती है।',
    's2_obs_3': 'बीज विभाजित नहीं होता है।',
    's2_obs_4': 'मक्के का एक लंबा पौधा तेजी से बढ़ता है।',
    's2_obs_5': 'शिराएँ सीधी, समानांतर रेखाओं में चलती हैं।',
    's2_obs_6': 'समान आकार की पतली जड़ों का गुच्छा।',
    's2_expl_1': 'भिगोने से बीज परीक्षण के लिए तैयार हो जाता है।',
    's2_expl_2': 'चने के विपरीत, मक्के का दाना अंदर से ठोस होता है।',
    's2_expl_3':
        'यह एक एकल, ठोस इकाई बना रहता है। एक बीजपत्र वाले बीज एकबीजपत्री (Monocots) होते हैं।',
    's2_expl_4': 'मशीन इस विशिष्ट एकबीजपत्री के वयस्क रूप को दर्शाती है।',
    's2_expl_5':
        'इसे समानांतर शिराविन्यास (Parallel Venation) कहा जाता है, जो एकबीजपत्री की विशेषता है।',
    's2_expl_6':
        'यह एक झकड़ा जड़ (Fibrous Root) प्रणाली है, जो आमतौर पर एकबीजपत्री बीजों से उगे पौधों में पाई जाती है।',
    's1_summary':
        'आपने द्विबीजपत्री (Dicot) पैटर्न को उजागर किया है! जो बीज दो भागों में विभाजित होते हैं (द्विबीजपत्री) वे ऐसे पौधों में विकसित होते हैं जिनकी पत्तियों पर जालिका रूपी शिराविन्यास (जाल जैसी शिराएँ) और भूमिगत एक मजबूत मूसला जड़ प्रणाली होती है।',
    's2_summary':
        'आपने एकबीजपत्री (Monocot) रहस्य सुलझा लिया है! जो बीज विभाजित नहीं होते हैं (एकबीजपत्री) वे पत्तियों पर समानांतर शिराविन्यास (सीधी शिराएँ) और एक जंगली झकड़ा जड़ प्रणाली वाले पौधों में विकसित होते हैं।',
    'success': 'खोज पूर्ण!',
    'classification_complete': 'प्लांट प्रोफाइल तैयार!',
    'select_next_sc_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'btn_conclude': 'कनेक्शन की समीक्षा करें',
    'sum_dicot': 'द्विबीजपत्री',
    'sum_mono': 'एकबीजपत्री',
    // The HTML kept "Connections" in English here.
    'sum_connections': '{plant} के कनेक्शन',
    'sum_seed': 'बीज',
    'sum_leaf': 'पत्ती',
    'sum_root': 'जड़',
    'sum_2cot': '2 बीजपत्र',
    'sum_ret': 'जालिका रूपी शिराविन्यास',
    'sum_tap': 'मूसला जड़',
    'sum_1cot': '1 बीजपत्र',
    'sum_par': 'समानांतर शिराविन्यास',
    'sum_fib': 'झकड़ा जड़',
    'got_it': 'समझ गया!',
    'pop_dicot': 'द्विबीजपत्री (2 बीजपत्र)',
    'pop_monocot': 'एकबीजपत्री (1 बीजपत्र)',
    'pop_leaf': 'पत्ती शिराविन्यास',
    'pop_root': 'जड़ प्रणाली',
    'desc_dicot': 'दो बीजपत्र पहचाने गए।',
    'desc_monocot': 'ठोस इकाई, एक बीजपत्र पहचाना गया।',
    'desc_reticulate': 'जाल जैसा पैटर्न (जालिका रूपी शिराविन्यास)।',
    'desc_parallel': 'समानांतर रेखाएं (समानांतर शिराविन्यास)।',
    'desc_tap': 'साइड शाखाओं के साथ एक मुख्य जड़ (मूसला जड़)।',
    'desc_fibrous': 'समान पतली जड़ों का गुच्छा (झकड़ा जड़)।',
    'lbl_chickpea': 'चने का बीज',
    'lbl_maize': 'मक्के का बीज',
    'lbl_beaker': 'पानी का बीकर',
    'lbl_scalpel': 'स्कैल्पेल',
    'lbl_grower': 'प्लांट ग्रोअर',
    'acc_title': 'अवलोकन चरण',
    'acc_step': 'चरण',
    'acc_focus': 'ध्यान दें',
    'acc_action': 'क्रिया',
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'not_yet': 'अभी नहीं! पहले: {task}',
    'miss_beaker': 'निशाना चूक गया! बीज को सीधे पानी के बीकर में छोड़ें।',
    'miss_seed': 'निशाना चूक गया! स्कैल्पेल को सीधे भीगे हुए बीज पर छोड़ें।',
    'miss_machine':
        'निशाना चूक गया! बीज को सीधे प्लांट ग्रोअर की कीप में छोड़ें।',
    'pull_higher':
        'और ऊपर खींचें! तने को तब तक ऊपर खींचें जब तक जड़ें बाहर न आ जाएँ।',
    'scene_s1':
        'प्रयोगशाला की मेज़ पर पानी का बीकर, चने का बीज, विच्छेदन ट्रे, स्कैल्पेल और प्लांट ग्रोअर मशीन, जिसके पास एक गमला है',
    'scene_s2':
        'प्रयोगशाला की मेज़ पर पानी का बीकर, मक्के का बीज, विच्छेदन ट्रे, स्कैल्पेल और प्लांट ग्रोअर मशीन, जिसके पास एक गमला है',
  },
};

/// Steps of each scenario: the HTML's six `steps` plus its seventh HUD task
/// ('Review Connections').
const int _stepCount = 7;

/// The HTML `steps` (soak, peel, split, grow, leaf, roots).
const int _labSteps = 6;

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
    for (var i = 1; i <= _stepCount; i++)
      _StepInfo(
        focus: i <= _labSteps ? t('s${n}_focus_$i') : '',
        action: t('s${n}_act_$i'),
        result: i <= _labSteps ? t('s${n}_obs_$i') : '',
        explanation: i <= _labSteps ? t('s${n}_expl_$i') : '',
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The shell's
/// mission card shows each step's concept and action; the observation is
/// in the accordion, once the step is done.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= 2; n++)
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

/// HTML camera: `PerspectiveCamera(45, …)`, `camera.position.set(0, 10,
/// 15)` looking at `controls.target.set(0, 0, 0)` (`resetCamera`).
const double _fovDegrees = 45;
const _V _eye = _V(0, 10, 15);
const _V _lookAt = _V(0, 0, 0);
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up the seed or the scalpel (short drags must pick
/// them up).
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

/// The fitted scene is never drawn smaller than this.
const double _minZoom = 0.3;

/// The HTML camera's two poses: the whole bench (`resetCamera`) and, for
/// steps 4 and 5, the tween towards the Plant Grower (`camera.position` →
/// (6, 6, 10), `controls.target` (6, 2, 0), 800 ms). The port keeps the
/// HTML camera and re-frames the scene instead: [machine] fits the tray,
/// the machine and the pot, enlarged up to its [maxZoom] (the HTML pose is
/// about 1.7x closer).
enum _View {
  overview(1.6, _framingSeconds),
  machine(2.0, 0.8);

  const _View(this.maxZoom, this.seconds);

  /// Largest zoom of the fitted scene (the HTML camera is zoom 1).
  final double maxZoom;

  /// How long the scene slides into this view.
  final double seconds;
}

/// HTML lights: `AmbientLight(0xffffff, 0.7)`, a key `DirectionalLight`
/// 0.8 at (15, 25, 15) and a fill 0.3 at (-15, 10, -15) (normalised); the
/// sum is scaled by [_exposure] so lit tops do not wash out.
const _V _keyLight = _V(0.4575, 0.7625, 0.4575);
const _V _fillLight = _V(-0.6396, 0.4264, -0.6396);
const double _ambient = 0.7;
const double _keyDiffuse = 0.8;
const double _fillDiffuse = 0.3;
const double _exposure = 0.72;

/// The key light seen on screen (upper right): highlights on rods.
const Offset _screenLight = Offset(0.6, -0.8);

// -------------------------------------------------------- bench and props

/// Lab bench `BoxGeometry(30, 1, 15)` at (0, -0.5, 0): its top is y = 0.
const _V _benchCenter = _V(0, -0.5, 0);
const _V _benchSize = _V(30, 1, 15);

/// Beaker group at (-6, 0, -2): open glass `CylinderGeometry(1.2, 1.2,
/// 2.5)`, a 0.1 glass base and water `CylinderGeometry(1.15, 1.15, 1.8)`;
/// its 'Water Beaker' sprite at y = 3.
const _V _beakerAt = _V(-6, 0, -2);
const double _beakerR = 1.2;
const double _beakerH = 2.5;
const double _waterR = 1.15;
const double _waterH = 1.8;
const _V _beakerLabelAt = _V(-6, 3, -2);

/// `Mats.glass` opacity 0.4, `Mats.water` opacity 0.7.
const double _glassOpacity = 0.4;
const double _waterOpacity = 0.7;

/// Dissection tray at (0, 0, 2): base `BoxGeometry(5, 0.1, 3)` and rims
/// (5, 0.3, 0.2) at z ±1.4, (0.2, 0.3, 2.6) at x ±2.4.
const _V _trayAt = _V(0, 0, 2);
const double _trayHalfX = 2.5;
const double _trayHalfZ = 1.5;

/// Where a soaked seed is put on the tray (`tray.position`, y 0.2).
const _V _seedOnTray = _V(0, 0.2, 2);

/// Plant Grower at (6, 0, -2): body `BoxGeometry(4, 2, 3)` at y 1, open
/// funnel `CylinderGeometry(1, 0.2, 1)` at y 2.5, status lights r 0.1 at
/// (-1.2 / -0.8 / -0.4, 1.5, 1.5); its 'Plant Grower' sprite at y = 3.5.
const _V _machineAt = _V(6, 0, -2);
const _V _machineSize = _V(4, 2, 3);
const double _funnelTopR = 1;
const double _funnelBottomR = 0.2;
const double _funnelBottomY = 2;
const double _funnelTopY = 3;
const List<double> _lightXs = [-1.2, -0.8, -0.4];
const double _lightY = 1.5;
const double _lightR = 0.1;
const _V _machineLabelAt = _V(6, 3.5, -2);

/// The seed rises to the funnel (y 3) before it vanishes into the machine.
const _V _seedInFunnel = _V(6, 3, -2);

// --------------------------------------------------------------- the seed

/// Seed group at (-3, 0.2, 0). Chickpea: two half spheres r 0.3 inside a
/// coat r 0.32, group scale (1, 0.9, 1.1). Maize: a core `BoxGeometry(0.4,
/// 0.5, 0.2)` inside a coat (0.42, 0.52, 0.22). Hit boxes: a sphere r 0.5
/// (chickpea), a 0.6 cube (maize), both scaled with the seed.
const _V _seedHome = _V(-3, 0.2, 0);
const _V _chickpeaScale = _V(1, 0.9, 1.1);
const _V _maizeScale = _V(1, 1, 1);
const double _halfR = 0.3;
const double _coatR = 0.32;
const _V _maizeCore = _V(0.4, 0.5, 0.2);
const _V _maizeCoat = _V(0.42, 0.52, 0.22);
const double _chickpeaHitR = 0.5;
const double _maizeHitR = 0.4;

/// HTML: a soaked seed swells to 1.6 (Elastic.Out, 1000 ms).
const double _swollen = 1.6;

/// The seed's label sits this far above its top (the HTML sprite is 1
/// unit above its centre, scaled with the seed).
const double _seedLabelGap = 0.3;

/// HTML drag plane y = 0.2; the scalpel is held at y = 0.5.
const double _dragY = 0.2;
const double _scalpelHeldY = 0.5;

/// Scalpel group at (2, 0.2, 3): handle r 0.05, 1 long, from x -1 to 0;
/// blade `PlaneGeometry(0.4, 0.15)` at (0.1, -0.05, 0). Hit box (1.5, 0.5,
/// 0.5) centred at x -0.3.
const _V _scalpelHome = _V(2, 0.2, 3);
const double _handleR = 0.05;
const double _bladeHalfW = 0.2;
const double _bladeHalfH = 0.075;
const _V _bladeOffset = _V(0.1, -0.05, 0);
const _V _scalpelHitMin = _V(-1.05, -0.25, -0.25);
const _V _scalpelHitMax = _V(0.45, 0.25, 0.25);

/// The scalpel's label (HTML sprite 0.5 above the group).
const _V _scalpelLabelOffset = _V(-0.4, 0.3, 0);

// --------------------------------------------------- pot, plant, magnifier

/// Plant group at (6, 0, 2): glass pot `CylinderGeometry(1.2, 1.0, 1.5)`,
/// a glass base r 1, soil `CylinderGeometry(1.15, 1.05, 1.3)` centred at
/// y 0.7; the plant stands on the soil (`plantStruct.position.y = 1.35`).
const _V _potAt = _V(6, 0, 2);
const double _potTopR = 1.2;
const double _potBottomR = 1;
const double _potH = 1.5;
const double _soilTopR = 1.15;
const double _soilBottomR = 1.05;
const double _soilH = 1.3;
const double _soilMidY = 0.7;
const double _plantY = 1.35;

/// Chickpea stem `CylinderGeometry(0.04, 0.05, 2)`, maize stem (0.06, 0.08,
/// 3), both standing on the soil line.
const double _dicotStemH = 2;
const double _monocotStemH = 3;

/// The plant as the learner grabs it (HTML `pStemHit`, r 0.4, plus every
/// leaf): its extent above the soil line in plant units.
const _V _dicotGripMin = _V(-1.1, 0, -1.1);
const _V _dicotGripMax = _V(1.1, 2.05, 1.1);
const _V _monocotGripMin = _V(-0.95, 0, -0.25);
const _V _monocotGripMax = _V(0.95, 4.05, 0.25);

/// Magnifying glass at (6, 3, 2.5) (S1) / (5.5, 3.5, 2.5) (S2): ring
/// `TorusGeometry(0.5, 0.05)`, lens r 0.48, handle r 0.08, 0.8 long; it
/// bobs 0.2 up and down (1000 ms yoyo, Sinusoidal.InOut). Hit sphere r 0.8.
const List<_V> _magHome = [_V(6, 3, 2.5), _V(5.5, 3.5, 2.5)];
const double _magR = 0.5;
const double _magTube = 0.05;
const double _lensR = 0.48;
const double _magHandleR = 0.08;
const double _magHandleLen = 0.8;
const double _magBob = 0.2;
const double _magBobSeconds = 1;
const double _magHitR = 0.8;

// ------------------------------------------------------ HTML interactions

/// Drop tests: `distanceTo(…) < 2` to the beaker and the machine, `< 1.5`
/// from the scalpel to the seed.
const double _beakerReach = 2;
const double _seedReach = 1.5;
const double _machineReach = 2;

/// Pulling the plant: at most 2.5 up; above 1.5 the roots are out. The
/// soil sinks 0.3 per unit once the plant is 0.5 up (never below 0.1); a
/// short pull drops back in 300 ms.
const double _pullMax = 2.5;
const double _pullNeeded = 1.5;
const double _soilBreakFrom = 0.5;
const double _soilPerUnit = 0.3;
const double _soilMin = 0.1;
const double _pullBackSeconds = 0.3;

/// HTML tweens and timeouts (s): the seed goes into the water (300 ms),
/// swells after 400 ms (1000 ms), moves to the tray after 2000 ms (800 ms);
/// the coat fades (800 ms) while the scalpel returns (500 ms); the halves
/// part (500 ms); the maize jiggles (6 x 50 ms) and its card follows after
/// 400 ms; the seed rises into the funnel (300 ms) and the plant appears
/// 1500 ms later; a card fades out in 400 ms; a missed drop springs back
/// (500 ms, Elastic.Out).
const double _intoBeakerSeconds = 0.3;
const double _swellAt = 0.4;
const double _swellSeconds = 1;
const double _toTrayAt = 2;
const double _toTraySeconds = 0.8;
const double _peelSeconds = 0.8;
const double _scalpelBackSeconds = 0.5;
const double _splitSeconds = 0.5;
const double _halfGapStart = 0.01;
const double _halfGap = 0.2;
const double _jiggleLeg = 0.05;
const int _jiggleLegs = 6;
const double _jiggleAngle = 0.2;
const double _monocotCardDelay = 0.4;
const double _intoFunnelSeconds = 0.3;
const double _growSeconds = 1.5;
const double _cardCloseSeconds = 0.4;
const double _returnSeconds = 0.5;

/// The seed's y in the beaker (`to({y: 1.5})`).
const double _soakY = 1.5;

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

// ------------------------------------------------------------- labels

/// How a chip sits on its anchor (x, y alignment: -1 left / top edge, 0
/// centre, 1 right / bottom edge).
const (double, double) _centred = (0, 0);
const (double, double) _above = (0, 1);

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

  /// Component-wise product (an object's `scale`).
  _V times(_V o) => _V(x * o.x, y * o.y, z * o.z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);
  double get maxComponent => math.max(x, math.max(y, z));

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Three.js rotations about x, y and z (an Euler 'XYZ' rotation applies z,
/// then y, then x).
_V _rotX(_V v, double a) => _V(
  v.x,
  v.y * math.cos(a) - v.z * math.sin(a),
  v.y * math.sin(a) + v.z * math.cos(a),
);
_V _rotY(_V v, double a) => _V(
  v.x * math.cos(a) + v.z * math.sin(a),
  v.y,
  -v.x * math.sin(a) + v.z * math.cos(a),
);
_V _rotZ(_V v, double a) => _V(
  v.x * math.cos(a) - v.y * math.sin(a),
  v.x * math.sin(a) + v.y * math.cos(a),
  v.z,
);

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

  /// The design point of [w] (everything in the scene is in front of the
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

/// A number animated from [from] to [to] (HTML `TWEEN.Tween`).
class _Move {
  _Move(double value) : from = value, to = value;

  double from;
  double to;
  double start = 0;
  double seconds = 0;
  Curve curve = Curves.linear;

  double at(double time) {
    if (seconds <= 0) return to;
    final k = ((time - start) / seconds).clamp(0.0, 1.0);
    return from + (to - from) * curve.transform(k);
  }

  void set(double value) {
    from = value;
    to = value;
    seconds = 0;
  }

  void animate(
    double time,
    double target,
    double duration, [
    Curve easing = Curves.linear,
  ]) {
    from = at(time);
    to = target;
    start = time;
    seconds = duration;
    curve = easing;
  }
}

/// A point or a scale animated from [from] to [to] (HTML `TWEEN.Tween` on
/// a `position` / `scale`).
class _MoveV {
  _MoveV(_V value) : from = value, to = value;

  _V from;
  _V to;
  double start = 0;
  double seconds = 0;
  Curve curve = Curves.linear;

  _V at(double time) {
    if (seconds <= 0) return to;
    final k = ((time - start) / seconds).clamp(0.0, 1.0);
    return _V.lerp(from, to, curve.transform(k));
  }

  void set(_V value) {
    from = value;
    to = value;
    seconds = 0;
  }

  void animate(
    double time,
    _V target,
    double duration, [
    Curve easing = Curves.linear,
  ]) {
    from = at(time);
    to = target;
    start = time;
    seconds = duration;
    curve = easing;
  }
}

/// What the learner can touch on the bench.
enum _Item { seed, scalpel, magnifier, plant }

/// The HTML `SVGs` icons; each is also an observation card (HTML
/// `showPopup(title, svg, desc)`), with its title and description keys.
enum _Art {
  seedDicot('pop_dicot', 'desc_dicot'),
  seedMonocot('pop_monocot', 'desc_monocot'),
  leafReticulate('pop_leaf', 'desc_reticulate'),
  leafParallel('pop_leaf', 'desc_parallel'),
  rootTap('pop_root', 'desc_tap'),
  rootFibrous('pop_root', 'desc_fibrous');

  const _Art(this.titleKey, this.descKey);

  final String titleKey;
  final String descKey;
}

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

/// A root (`CylinderGeometry`, radius top → tip) from its [top] end to its
/// [tip], in plant units (y = 0 is the soil line).
@immutable
class _Root {
  const _Root(this.top, this.tip, this.topR, this.tipR);

  final _V top;
  final _V tip;
  final double topR;
  final double tipR;
}

/// A root of [length] centred at [c], turned `rotation.x` [ax] and
/// `rotation.z` [az] (its axis is the cylinder's y).
_Root _rootAt(_V c, double ax, double az, double length, double r0, double r1) {
  final axis = _rotX(_rotZ(_V.up, az), ax) * (length / 2);
  return _Root(c + axis, c - axis, r0, r1);
}

/// Taproot: the main root `CylinderGeometry(0.05, 0.01, 1.5)` hanging from
/// the soil line and six side roots `CylinderGeometry(0.01, 0.005, 0.5)` at
/// (±0.1, -0.3 - 0.2 i, 0), `rotation.z` ∓1.
final List<_Root> _taproot = [
  const _Root(_V.zero, _V(0, -1.5, 0), 0.05, 0.01),
  for (var i = 0; i < 6; i++)
    _rootAt(
      _V(i.isEven ? 0.1 : -0.1, -0.3 - i * 0.2, 0),
      0,
      i.isEven ? -1 : 1,
      0.5,
      0.01,
      0.005,
    ),
];

/// Fibrous roots: 15 `CylinderGeometry(0.01, 0.005, 1)` centred 0.4 below
/// the soil line, each turned at random up to ±0.4 rad about x and z (a
/// fixed seed here, so the roots look the same every time).
final List<_Root> _fibrousRoots = () {
  final random = math.Random(5);
  final roots = <_Root>[];
  for (var i = 0; i < 15; i++) {
    final ax = (random.nextDouble() - 0.5) * 0.8;
    final az = (random.nextDouble() - 0.5) * 0.8;
    roots.add(_rootAt(const _V(0, -0.4, 0), ax, az, 1, 0.01, 0.005));
  }
  return roots;
}();

/// A flat leaf in plant units: centre, semi-axis to its tip ([along]),
/// semi-axis across it and its (thin) semi-axis along the normal.
@immutable
class _LeafShape {
  const _LeafShape(this.center, this.along, this.across, this.normal);

  final _V center;
  final _V along;
  final _V across;
  final _V normal;
}

/// Chickpea leaves: `SphereGeometry(0.4)` scaled (1, 0.1, 1.5), 0.5 out
/// along its group's z; groups at y 0.5 + 0.4 i, `rotation.y` i·π/2,
/// `rotation.x` 0.3.
final List<_LeafShape> _dicotLeaves = [
  for (var i = 0; i < 4; i++)
    _LeafShape(
      _V(0, 0.5 + i * 0.4, 0) + _leafTurn(const _V(0, 0, 0.5), i),
      _leafTurn(const _V(0, 0, 0.6), i),
      _leafTurn(const _V(0.4, 0, 0), i),
      _leafTurn(const _V(0, 0.04, 0), i),
    ),
];

/// Chickpea leaf group `i`'s rotation (x 0.3, y i·π/2).
_V _leafTurn(_V v, int i) => _rotX(_rotY(v, i * math.pi / 2), 0.3);

/// A long monocot leaf blade: from its [base] to its [tip], [_Blade.baseHalf]
/// / [_Blade.tipHalf] wide either side along [across], facing [normal].
@immutable
class _Blade {
  const _Blade(this.base, this.tip, this.across, this.normal);

  final _V base;
  final _V tip;
  final _V across;
  final _V normal;

  static const double baseHalf = 0.2;
  static const double tipHalf = 0.05;
}

/// Maize leaves: `CylinderGeometry(0.05, 0.2, 1.8)` flattened (scale z
/// 0.1) at y 0.8 in groups at y 0.5 + 0.5 i, `rotation.y` i·π (they
/// alternate sides) and `rotation.z` -0.5 (they lean out).
final List<_Blade> _monocotBlades = [
  for (var i = 0; i < 5; i++)
    _Blade(
      _V(0, 0.5 + i * 0.5, 0) + _bladeTurn(const _V(0, -0.1, 0), i),
      _V(0, 0.5 + i * 0.5, 0) + _bladeTurn(const _V(0, 1.7, 0), i),
      _bladeTurn(const _V(1, 0, 0), i),
      _bladeTurn(const _V(0, 0, 1), i),
    ),
];

/// Maize leaf group `i`'s rotation (y i·π, z -0.5).
_V _bladeTurn(_V v, int i) => _rotY(_rotZ(v, -0.5), i * math.pi);

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based HTML `State.step`; [_stepCount] + 1 once reviewed.
  int step = 1;

  // HTML `State.s1` / `State.s2` flags.
  bool soaked = false;
  bool peeled = false;

  /// Split (S1) or split attempted (S2).
  bool split = false;
  bool grown = false;
  bool leafInspected = false;
  bool rootInspected = false;
  bool reviewed = false;

  /// The camera pose of the current step.
  _View view = _View.overview;

  // ------------------------------------------------------------- seed
  final _MoveV seedPos = _MoveV(_seedHome);
  final _MoveV seedScale = _MoveV(_chickpeaScale);

  /// Coat opacity (1, fading to 0 once peeled).
  final _Move coat = _Move(1);

  /// How far each chickpea half sits from the centre (0.01 → 0.2).
  final _Move halves = _Move(_halfGapStart);

  /// Scene time the maize kernel started to jiggle, or -1.
  double jiggleStart = -1;
  bool seedVisible = true;

  /// The seed is in the water (drawn inside the beaker).
  bool seedInBeaker = false;

  // ---------------------------------------------------- scalpel, machine
  final _MoveV scalpelPos = _MoveV(_scalpelHome);
  bool lightsOn = false;

  // --------------------------------------------------- plant, magnifier
  bool plantVisible = false;

  /// How far the plant is pulled up (HTML `plantStruct.position.y - initY`).
  final _Move pull = _Move(0);

  /// The soil's height scale (it sinks while the plant comes out).
  final _Move soil = _Move(1);
  bool magVisible = false;

  // ------------------------------------------------------------ input
  /// What the learner holds (HTML `State.draggingObject`) and where.
  _Item? held;
  _V heldAt = _V.zero;

  /// The observation card on screen (HTML `#inspection-panel`), if any.
  _Art? inspecting;

  final List<_Confetto> confetti = [];
  double confettiStart = 0;

  /// Pending events of the running sequence, in scene time (the HTML
  /// tween `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;
  double _framingSpan = _framingSeconds;

  bool get framingSettled => _framingT >= 1;

  bool get isDicot => scenario == 0;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    soaked = false;
    peeled = false;
    split = false;
    grown = false;
    leafInspected = false;
    rootInspected = false;
    reviewed = false;
    view = _View.overview;
    seedPos.set(_seedHome);
    seedScale.set(index == 0 ? _chickpeaScale : _maizeScale);
    coat.set(1);
    halves.set(_halfGapStart);
    jiggleStart = -1;
    seedVisible = true;
    seedInBeaker = false;
    scalpelPos.set(_scalpelHome);
    lightsOn = false;
    plantVisible = false;
    pull.set(0);
    soil.set(1);
    magVisible = false;
    held = null;
    inspecting = null;
    confetti.clear();
    _cues.clear();
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

  /// HTML `animate()`: the framing slide and the confetti (the tweens are
  /// evaluated from the scene time when drawn).
  void advance(double dt) {
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSpan);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
    }
    if (confetti.isEmpty) return;
    if (time - confettiStart > _confettiSeconds) {
      confetti.clear();
      return;
    }
    final frames = dt * 60;
    final decay = math.pow(_confettiDecay, frames).toDouble();
    for (final c in confetti) {
      c
        ..x += math.cos(c.angle) * c.speed * frames
        ..y += math.sin(c.angle) * c.speed * frames + _confettiGravity * frames
        ..speed *= decay
        ..wobble += 0.1 * frames;
    }
  }

  /// Slides (or, with [snap], jumps) to [target] in [seconds].
  void setFraming(
    _Framing target, {
    required bool snap,
    double seconds = _framingSeconds,
  }) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
    _framingSpan = seconds;
  }

  /// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})`.
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

  /// The camera in the current framing.
  _Cam camera() => _Cam(framing);

  // ------------------------------------------------------------ the step

  /// What the current step works with (HTML `handleDown`'s
  /// `activeObjects`), or null while its effect plays out.
  _Item? get active => switch (step) {
    1 => soaked ? null : _Item.seed,
    2 => peeled ? null : _Item.scalpel,
    3 => split ? null : _Item.seed,
    4 => grown ? null : _Item.seed,
    5 => leafInspected ? null : _Item.magnifier,
    6 => rootInspected ? null : _Item.plant,
    _ => null,
  };

  /// Steps 3 and 5 are taps (HTML click actions); 1, 2, 4 and 6 drags.
  bool get stepIsTap => step == 3 || step == 5;

  // ------------------------------------------------------------- objects

  /// Where the seed is drawn now.
  _V get seedAt => held == _Item.seed ? heldAt : seedPos.at(time);

  /// The seed's scale now.
  _V get seedScaleNow => seedScale.at(time);

  /// Where the scalpel is drawn now.
  _V get scalpelAt => held == _Item.scalpel ? heldAt : scalpelPos.at(time);

  double get coatAlpha => coat.at(time).clamp(0.0, 1.0);

  double get halfGap => halves.at(time);

  /// The maize kernel's `rotation.z` while it jiggles (to 0.2 and back, 50
  /// ms each way, six times).
  double get jiggle {
    if (jiggleStart < 0) return 0;
    final legs = (time - jiggleStart) / _jiggleLeg;
    if (legs >= _jiggleLegs) return 0;
    final f = legs - legs.floor();
    return _jiggleAngle * (legs.floor().isEven ? f : 1 - f);
  }

  double get pullNow => pull.at(time);
  double get soilScale => soil.at(time);

  /// Where the plant meets the soil line (HTML `plantStruct.position`).
  _V get plantBase => _potAt + _V(0, _plantY + pullNow, 0);

  /// The top of the soil (the soil is scaled about its centre).
  double get soilTop => _soilMidY + _soilH / 2 * soilScale;

  /// The magnifying glass, bobbing.
  _V get magAt =>
      _magHome[scenario] +
      _V(0, _magBob * 0.5 * (1 - math.cos(math.pi * time / _magBobSeconds)), 0);

  /// The seed's hit radius (HTML hit sphere / box) in world units.
  double get seedHitR =>
      (isDicot ? _chickpeaHitR : _maizeHitR) * seedScaleNow.maxComponent;

  /// The seed's drawn radius (its coat), for labels and drop targets.
  double get seedRadius =>
      (isDicot ? _coatR : _maizeCoat.y / 2) * seedScaleNow.maxComponent;

  /// The plant's grip box (stem and leaves) in world units.
  (_V, _V) get plantGrip {
    final b = plantBase;
    return isDicot
        ? (b + _dicotGripMin, b + _dicotGripMax)
        : (b + _monocotGripMin, b + _monocotGripMax);
  }

  // ------------------------------------------------------------- hits

  bool _hits(_Item item, Offset p, double touch, _Cam cam) {
    switch (item) {
      case _Item.seed:
        if (!seedVisible) return false;
        final at = seedAt;
        final r = math.max(seedHitR * cam.scaleAt(at), touch);
        return (p - cam.p(at)).distance <= r;
      case _Item.scalpel:
        final at = scalpelAt;
        final rect = cam.boxRect(at + _scalpelHitMin, at + _scalpelHitMax);
        return rect.inflate(touch * 0.5).contains(p);
      case _Item.magnifier:
        if (!magVisible) return false;
        final at = magAt;
        final r = math.max(_magHitR * cam.scaleAt(at), touch);
        return (p - cam.p(at)).distance <= r;
      case _Item.plant:
        if (!plantVisible) return false;
        final (min, max) = plantGrip;
        return cam.boxRect(min, max).inflate(touch * 0.5).contains(p);
    }
  }

  /// The object at [p] (HTML raycast on the hit boxes): the step's object
  /// first, then the others (the magnifier floats in front of the leaves).
  _Item? hitAt(Offset p, double touch) {
    final cam = camera();
    final first = active;
    if (first != null && _hits(first, p, touch, cam)) return first;
    for (final item in const [
      _Item.magnifier,
      _Item.seed,
      _Item.scalpel,
      _Item.plant,
    ]) {
      if (item != first && _hits(item, p, touch, cam)) return item;
    }
    return null;
  }

  // ------------------------------------------------------------ drops

  /// HTML `handleUp`, step 1: `distanceTo(beaker.position) < 2`; a release
  /// over the beaker as drawn counts as well.
  bool landsInBeaker(_V at, Offset pointer, double margin) {
    if ((at - _beakerAt).length < _beakerReach) return true;
    final cam = camera();
    final body = cam
        .boxRect(
          _beakerAt - const _V(_beakerR, 0, _beakerR),
          _beakerAt + const _V(_beakerR, _beakerH, _beakerR),
        )
        .inflate(margin);
    return body.contains(pointer) || body.contains(cam.p(at));
  }

  /// HTML `handleUp`, step 2: the scalpel `distanceTo(seed.position) <
  /// 1.5`; a release with the blade or the finger on the seed counts too.
  bool landsOnSeed(_V at, Offset pointer, double margin) {
    final seed = seedAt;
    if ((at - seed).length < _seedReach) return true;
    final cam = camera();
    final c = cam.p(seed);
    final r = seedRadius * cam.scaleAt(seed) + margin;
    return (pointer - c).distance <= r ||
        (cam.p(at + _bladeOffset) - c).distance <= r;
  }

  /// HTML `handleUp`, step 4: `distanceTo(machine.position) < 2`; a release
  /// over the machine or its funnel counts as well.
  bool landsInMachine(_V at, Offset pointer, double margin) {
    if ((at - _machineAt).length < _machineReach) return true;
    final cam = camera();
    final body = cam
        .boxRect(
          _machineAt - _V(_machineSize.x / 2, 0, _machineSize.z / 2),
          _machineAt + _V(_machineSize.x / 2, _funnelTopY, _machineSize.z / 2),
        )
        .inflate(margin);
    return body.contains(pointer) || body.contains(cam.p(at));
  }

  // ------------------------------------------ plain readouts for the tests

  /// Design point of a named place in the current framing: 'seed',
  /// 'scalpel', 'beaker', 'machine', 'magnifier' or 'plant'.
  Offset anchor(String id) {
    final cam = camera();
    return switch (id) {
      'seed' => cam.p(seedAt),
      'scalpel' => cam.p(scalpelAt + const _V(-0.4, 0, 0)),
      'beaker' => cam.p(_beakerAt + const _V(0, _beakerH / 2, 0)),
      'machine' => cam.p(_machineAt + const _V(0, _funnelBottomY, 0)),
      'magnifier' => cam.p(magAt),
      'plant' => cam.p(plantBase + const _V(0, 0.8, 0)),
      _ => _designCenter,
    };
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

/// Top-left of a chip of [size] relative to its anchor (see [_above] …).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a bench object ([canGrab]), so other drags still pan / zoom the
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

class _SeedStructureLabState
    extends State<Ch2A4ClassifyingPlantsBasedOnSeedStructurePage>
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
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a4-canvas');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The view the scene was last framed for: a new view slides in at its
  /// own pace (the HTML camera tween).
  _View? _framedView;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// What the current pointer went down on and where; the scenario the
  /// held object was picked up in, the drag-plane offset of the grab (HTML
  /// `dragOffset`), where it came from (a missed drop springs back there)
  /// and the finger's last position; for the plant, the finger's height
  /// that means "not pulled".
  _Item? _downItem;
  Offset _downAt = Offset.zero;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  _V _grabFrom = _V.zero;
  Offset _lastPointer = Offset.zero;
  double _pullZeroY = 0;

  /// An observation card closed with the popup's own close button is
  /// handled once, after the event that closed it.
  bool _closeQueued = false;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// The HTML "Current Task" line of the current step.
  String get _hud =>
      _t('s${_scene.scenario + 1}_hud_${_scene.step.clamp(1, _stepCount)}');

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
    _lab.addListener(_onLabChanged);
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
    _lab.removeListener(_onLabChanged);
    _ticker.dispose();
    _frame.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  /// Design point of a named bench object (see [_Scene.anchor]), for the
  /// widget tests that drive the lab with real gestures.
  @visibleForTesting
  Offset debugDesignPoint(String id) => _scene.anchor(id);

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

  /// Fits the step's view (the whole bench, or the tray, machine and pot)
  /// into the part of the canvas no card covers: the tool column, the HUD
  /// (sidebar open) and the floating mission card (sidebar collapsed).
  /// Never while something is held, so the scene does not move under the
  /// finger.
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
    final view = _scene.view;
    final target = _fitFraming(
      _focusItems(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      view.maxZoom,
    );
    _scene.setFraming(
      target,
      snap: _snapFraming,
      seconds: view == _framedView ? _framingSeconds : view.seconds,
    );
    _framedView = view;
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

  /// What the learner must see in the step's view (HTML camera, zoom 1)
  /// and the label chips at their painted size. The overview keeps the
  /// whole bench (with the plant pulled right up once it is time to pull
  /// it); the machine view the tray, the Plant Grower and the pot.
  List<_Focus> _focusItems() {
    final s = _scene;
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

    final seedName = _t(s.isDicot ? 'lbl_chickpea' : 'lbl_maize');
    const swollenR = _coatR * _swollen;
    void seed(_V at) {
      box(
        at - const _V(swollenR, swollenR, swollenR),
        at + const _V(swollenR, swollenR, swollenR),
      );
      chip(at + const _V(0, swollenR + _seedLabelGap, 0), _above, seedName);
    }

    final plantTop = s.isDicot ? _dicotGripMax.y : _monocotGripMax.y;
    void pot(double lift) => box(
      _potAt - const _V(_potTopR, 0, _potTopR),
      _potAt + _V(_potTopR, _plantY + plantTop + lift, _potTopR),
    );

    // Both views: the tray with the seed on it and the Plant Grower.
    box(
      _trayAt - const _V(_trayHalfX, 0, _trayHalfZ),
      _trayAt + const _V(_trayHalfX, 0.3, _trayHalfZ),
    );
    seed(_seedOnTray);
    box(
      _machineAt - _V(_machineSize.x / 2, 0, _machineSize.z / 2),
      _machineAt + _V(_machineSize.x / 2, _funnelTopY, _machineSize.z / 2),
    );
    chip(_machineLabelAt, _centred, _t('lbl_grower'));
    if (s.view == _View.machine) {
      pot(0);
      final m = _magHome[s.scenario];
      box(m - const _V(0.6, 0.6, 0.1), m + const _V(1.1, 0.8 + _magBob, 0.1));
      return items;
    }
    box(
      _beakerAt - const _V(_beakerR, 0, _beakerR),
      _beakerAt + const _V(_beakerR, _beakerH, _beakerR),
    );
    chip(_beakerLabelAt, _centred, _t('lbl_beaker'));
    seed(_seedHome);
    box(_scalpelHome + _scalpelHitMin, _scalpelHome + _scalpelHitMax);
    chip(_scalpelHome + _scalpelLabelOffset, _above, _t('lbl_scalpel'));
    if (s.plantVisible) {
      pot(s.step >= _labSteps ? _pullMax : 0);
    } else {
      box(
        _potAt - const _V(_potTopR, 0, _potTopR),
        _potAt + const _V(_potTopR, _potH, _potTopR),
      );
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens, closes the observation card and rebuilds the scenario's
  /// bench.
  void _loadScenario(int index) {
    _lab.cancelPending();
    setState(() {
      _scene.load(index);
      _downItem = null;
      _grabScenario = -1;
      _cardRect = null;
    });
    _lab.hidePopup(sound: false);
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `handleUp`, step 1: the seed drops into the water, swells after
  /// 400 ms (`chime`) and, 2 s after the drop, moves to the dissection tray
  /// (`progressStep`).
  void _soak(_V from) {
    final s = _scene;
    final t = s.time;
    s
      ..soaked = true
      ..seedInBeaker = true;
    s.seedPos
      ..set(from)
      ..animate(t, const _V(-6, _soakY, -2), _intoBeakerSeconds);
    s.cue(t + _swellAt, () {
      _Sound.success.play();
      s.seedScale.animate(
        s.time,
        const _V(_swollen, _swollen, _swollen),
        _swellSeconds,
        Curves.elasticOut,
      );
    });
    s.cue(t + _toTrayAt, () {
      s
        ..seedInBeaker = false
        ..step = 2;
      s.seedPos.animate(
        s.time,
        _seedOnTray,
        _toTraySeconds,
        Curves.easeInOutCubic,
      );
      _refresh();
    });
    _refresh();
  }

  /// HTML `handleUp`, step 2: the coat fades away and the scalpel goes back
  /// to its place (`success`, `progressStep`).
  void _peel(_V from) {
    final s = _scene;
    final t = s.time;
    _Sound.success.play();
    s
      ..peeled = true
      ..step = 3;
    s.coat.animate(t, 0, _peelSeconds);
    s.scalpelPos
      ..set(from)
      ..animate(t, _scalpelHome, _scalpelBackSeconds);
    _refresh();
  }

  /// HTML `handleSeedSplit`: the chickpea opens into two cotyledons; the
  /// maize kernel only jiggles. Each opens its observation card.
  void _split() {
    final s = _scene;
    final t = s.time;
    _Sound.click.play();
    s.split = true;
    if (s.isDicot) {
      s.halves.animate(t, _halfGap, _splitSeconds, Curves.easeOutCubic);
      _showCard(_Art.seedDicot);
    } else {
      s.jiggleStart = t;
      s.cue(t + _monocotCardDelay, () => _showCard(_Art.seedMonocot));
    }
    _refresh();
  }

  /// HTML `handleUp`, step 4: the seed rises into the funnel and vanishes,
  /// the status lights glow for 1.5 s, then the plant and the magnifying
  /// glass appear (`machine`, `success`, `progressStep`).
  void _grow(_V from) {
    final s = _scene;
    final t = s.time;
    _Sound.machine.play();
    s.grown = true;
    s.seedPos
      ..set(from)
      ..animate(t, _seedInFunnel, _intoFunnelSeconds);
    s.cue(t + _intoFunnelSeconds, () {
      s
        ..seedVisible = false
        ..lightsOn = true;
    });
    s.cue(t + _intoFunnelSeconds + _growSeconds, () {
      _Sound.success.play();
      s
        ..lightsOn = false
        ..plantVisible = true
        ..magVisible = true
        ..step = 5;
      _refresh();
    });
    _refresh();
  }

  /// HTML `handleLeafInspection`: the magnifying glass goes and the leaf's
  /// venation card opens.
  void _inspectLeaf() {
    final s = _scene;
    _Sound.click.play();
    s
      ..leafInspected = true
      ..magVisible = false;
    _showCard(s.isDicot ? _Art.leafReticulate : _Art.leafParallel);
    _refresh();
  }

  /// HTML `handleUp`, step 6: pulled more than 1.5 up, the roots are out
  /// (`handleRootInspection`); otherwise the plant drops back into the soil
  /// (300 ms) and the learner is told to pull higher (added).
  void _releasePlant({bool cancel = false}) {
    final s = _scene;
    if (!cancel && s.pullNow > _pullNeeded) {
      _Sound.success.play();
      s.rootInspected = true;
      _showCard(s.isDicot ? _Art.rootTap : _Art.rootFibrous);
      _refresh();
      return;
    }
    s.pull.animate(s.time, 0, _pullBackSeconds);
    s.soil.animate(s.time, 1, _pullBackSeconds);
    if (!cancel) _lab.showToast(_t('pull_higher'), isError: true, sound: false);
    _refresh();
  }

  /// HTML `showPopup(title, svg, desc)`: the observation card with its
  /// self-drawing picture and 'Got it!'.
  void _showCard(_Art art) {
    if (!mounted) return;
    _scene.inspecting = art;
    _lab.showPopup(
      () => LabPopupContent(
        title: _t(art.titleKey),
        heading: _lab.t('lbl_observation'),
        body: _t(art.descKey),
        icon: Icons.search,
        accent: _Colors.teal500,
        extra: Builder(
          builder: (context) => Center(
            child: _InspectVisual(
              key: ValueKey(art),
              art: art,
              palette: _lab.palette,
              scale: context.labScale,
            ),
          ),
        ),
        actions: [
          LabAction(
            label: _t('got_it'),
            icon: Icons.check,
            color: _Colors.teal600,
            foreground: _Colors.white,
            silent: true,
            onTap: _closeCard,
          ),
        ],
      ),
      silent: true,
    );
    _refresh();
  }

  /// HTML `closeInspection()` ('Got it!'; also the popup's close button):
  /// 400 ms later the step moves on. Step 4 turns the camera to the Plant
  /// Grower, step 7 shows 'Review Connections' with a chime, any other
  /// step re-centres the camera (`resetCamera`, `pop`).
  void _closeCard({bool sound = true}) {
    final s = _scene;
    if (s.inspecting == null) return;
    s.inspecting = null;
    if (sound) _Sound.pop.play();
    _lab.hidePopup(sound: false);
    s.cue(s.time + _cardCloseSeconds, () {
      s.step += 1;
      if (s.step == 4) {
        s.view = _View.machine;
        _lab.resetView(sound: false);
      } else if (s.step > _labSteps) {
        _Sound.success.play();
      } else {
        s.view = _View.overview;
        _lab.resetView(sound: false);
        _Sound.pop.play();
      }
      _refresh();
    });
    _refresh();
  }

  /// The card was closed by the popup's own close button (or the lab was
  /// reset): handled after the event, so a reset or a scenario change that
  /// cleared the card first is left alone.
  void _onLabChanged() {
    if (_scene.inspecting == null || _lab.popup != null || _closeQueued) {
      return;
    }
    _closeQueued = true;
    scheduleMicrotask(() {
      _closeQueued = false;
      if (!mounted || !_lab.isLabActive) return;
      if (_scene.inspecting != null && _lab.popup == null) {
        _closeCard(sound: false);
      }
    });
  }

  /// HTML `triggerConclusion()`: the summary with the seed → leaf → root
  /// connections, and confetti.
  void _review() {
    final s = _scene;
    if (s.step <= _labSteps) return;
    final sc = s.scenario;
    // HTML `#next-sc-msg`: shown after Scenario 1 unless Scenario 2 is
    // already done (then the popup offers 'Restart Lab' instead).
    final showNext = sc == 0 && !_lab.completedScenarios.contains(1);
    s
      ..reviewed = true
      ..step = _stepCount + 1
      ..burstConfetti();
    _refresh();
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => _t('classification_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _SummaryVisual(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
          showNext: showNext,
        ),
      ),
    );
  }

  /// HTML `#compare-btn-container` ('Review Connections'), shown once the
  /// roots have been seen; it stays to re-open the summary.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.step <= _labSteps) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.check_circle,
        color: _Colors.teal600,
        foreground: _Colors.white,
        highlight: !s.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown`: a press on a bench object while a step waits for
  /// the learner (otherwise the canvas pans when unlocked).
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null || s.active == null) return false;
    return s.hitAt(event.localPosition, _touch) != null;
  }

  void _onDown(DragDownDetails d) {
    _downItem = _scene.hitAt(d.localPosition, _touch);
    _downAt = d.localPosition;
  }

  /// The step's object follows the finger: the seed and the scalpel on the
  /// drag plane, the plant straight up. A press on the seed in step 3 or
  /// on the magnifier in step 5 acts at once (HTML `pointerdown`); a press
  /// on any other object says what to do first (added).
  void _onDragStart(DragStartDetails d) {
    final s = _scene;
    final item = _downItem;
    _downItem = null;
    final active = s.active;
    if (item == null || active == null || s.held != null) return;
    if (item != active) {
      _hintFirst(item);
      return;
    }
    if (s.stepIsTap) {
      _tapAction();
      return;
    }
    _grabScenario = s.scenario;
    _lastPointer = _downAt;
    _Sound.pickup.play();
    if (item == _Item.plant) {
      final now = s.pullNow;
      s.pull.set(now);
      s.soil.set(s.soilScale);
      _pullZeroY = _downAt.dy + now * _pullPixels();
      s.held = _Item.plant;
      _move(d.localPosition);
      return;
    }
    final at = item == _Item.seed ? s.seedAt : s.scalpelAt;
    final hit = s.camera().onPlaneY(_downAt, _dragY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - at.x, 0, hit.z - at.z);
    _grabFrom = at;
    s
      ..held = item
      ..heldAt = at;
    _move(d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) => _move(d.localPosition);

  /// Design px the finger moves for one unit of pull: the plant follows the
  /// finger (the HTML maps the pointer's screen height, 6 units per half
  /// screen, which is about the same).
  double _pullPixels() {
    final cam = _scene.camera();
    final rest = _potAt + const _V(0, _plantY, 0);
    return math.max(1, cam.p(rest).dy - cam.p(rest + _V.up).dy);
  }

  /// HTML `handleMove`: the seed / scalpel slide on the drag plane (the
  /// scalpel lifted to y 0.5), kept on the bench; the plant rises with the
  /// finger (0 – 2.5) and the soil sinks once it is 0.5 up.
  void _move(Offset p) {
    final s = _scene;
    final item = s.held;
    if (item == null || _grabScenario != s.scenario) return;
    _lastPointer = p;
    if (item == _Item.plant) {
      final pulled = ((_pullZeroY - p.dy) / _pullPixels()).clamp(0.0, _pullMax);
      s.pull.set(pulled);
      if (pulled > _soilBreakFrom) {
        s.soil.set(math.max(_soilMin, 1 - pulled * _soilPerUnit));
      }
      return;
    }
    final hit = s.camera().onPlaneY(p, _dragY);
    if (hit == null) return;
    s.heldAt = _V(
      (hit.x - _grabOffset.x).clamp(
        -_benchSize.x / 2 + 0.5,
        _benchSize.x / 2 - 0.5,
      ),
      item == _Item.scalpel ? _scalpelHeldY : _dragY,
      (hit.z - _grabOffset.z).clamp(
        -_benchSize.z / 2 + 0.5,
        _benchSize.z / 2 - 0.5,
      ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  void _onDragCancel() {
    _downItem = null;
    _release(cancel: true);
  }

  /// HTML `handleUp`: the drop is judged where the object was let go. A
  /// miss (`playSound('error')`) springs the object back to where it was
  /// picked up (Elastic.Out, 500 ms) and says where to drop it (added).
  void _release({bool cancel = false}) {
    final s = _scene;
    final item = s.held;
    final scenario = _grabScenario;
    _grabScenario = -1;
    if (item == null) return;
    s.held = null;
    if (scenario != s.scenario) return;
    if (item == _Item.plant) {
      _releasePlant(cancel: cancel);
      return;
    }
    final at = s.heldAt;
    final margin = _touch * 0.5;
    if (!cancel) {
      if (s.step == 1 && s.landsInBeaker(at, _lastPointer, margin)) {
        _soak(at);
        return;
      }
      if (s.step == 2 && s.landsOnSeed(at, _lastPointer, margin)) {
        _peel(at);
        return;
      }
      if (s.step == 4 && s.landsInMachine(at, _lastPointer, margin)) {
        _grow(at);
        return;
      }
    }
    final move = item == _Item.seed ? s.seedPos : s.scalpelPos;
    move
      ..set(at)
      ..animate(s.time, _grabFrom, _returnSeconds, Curves.elasticOut);
    if (!cancel) {
      final miss = switch (s.step) {
        1 => 'miss_beaker',
        2 => 'miss_seed',
        _ => 'miss_machine',
      };
      _lab.showToast(_t(miss), isError: true);
    }
    _scheduleFraming();
    _refresh();
  }

  /// Steps 3 and 5: split the seed, or look through the magnifying glass.
  void _tapAction() {
    if (_scene.step == 3) {
      _split();
    } else {
      _inspectLeaf();
    }
  }

  /// An object touched before its turn (added): what to do first. A touch
  /// on the leaves while the magnifying glass waits repeats the task.
  void _hintFirst(_Item item) {
    final s = _scene;
    if (item == _Item.plant && s.active == _Item.magnifier) {
      _Sound.pop.play();
      _lab.showToast(_hud, sound: false);
      return;
    }
    final step = s.step.clamp(1, _stepCount);
    _lab.showToast(
      labFormat(_t('not_yet'), {'task': _t('s${s.scenario + 1}_act_$step')}),
      isError: true,
    );
  }

  /// HTML click actions (steps 3 and 5). A tap on an object that must be
  /// dragged repeats how to move it; on another object, what to do first.
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    final active = s.active;
    if (!_lab.isLabActive || active == null || s.held != null) return;
    final item = s.hitAt(d.localPosition, _touch);
    if (item == null) return;
    if (item != active) {
      _hintFirst(item);
      return;
    }
    if (s.stepIsTap) {
      _tapAction();
      return;
    }
    _Sound.pop.play();
    _lab.showToast(_hud, sound: false);
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
        final step = _scene.step;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('acc_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$step'),
            steps: _stepData,
            current: step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('acc_step'),
            focusLabel: _t('acc_focus'),
            actionLabel: _t('acc_action'),
            resultLabel: _lab.t('lbl_observation'),
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
              label: _t(_scene.isDicot ? 'scene_s1' : 'scene_s2'),
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
/// its focus, action and observation (and the HTML explanation). The
/// current step is open, done steps show a tick and can be re-opened,
/// future steps are dimmed. A step's observation and explanation are shown
/// once the step is done (the HTML showed them before the learner had seen
/// them).
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

/// HTML `#inspect-visual`: the card's picture in a rounded slate box. Its
/// lines draw themselves in (HTML `.svg-animate-dash`: `stroke-dasharray`
/// 200 eased to 0 over 1.5 s); the filled shapes are there at once.
class _InspectVisual extends StatefulWidget {
  const _InspectVisual({
    super.key,
    required this.art,
    required this.palette,
    required this.scale,
  });

  final _Art art;
  final LabPalette palette;
  final double scale;

  @override
  State<_InspectVisual> createState() => _InspectVisualState();
}

class _InspectVisualState extends State<_InspectVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final s = widget.scale;
    return Container(
      width: 120 * s,
      height: 120 * s,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate800 : _Colors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.isDark ? _Colors.slate700 : _Colors.slate300,
        ),
      ),
      child: CustomPaint(painter: _ArtPainter(widget.art, progress: _draw)),
    );
  }
}

/// HTML `#summary-visual-area`: "Dicot / Monocot Plant Connections" – the
/// seed, the leaf and the root, each with its trait, joined by teal (S1)
/// or emerald (S2) bars; after Scenario 1, the HTML's "select the next
/// scenario" note.
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
    final dicot = scenario == 0;
    final line = dicot ? _Colors.teal500 : _Colors.emerald500;
    final glow = dicot ? _Colors.teal400 : _Colors.emerald400;
    final ink = p.ink(glow);
    final heading = labFormat(t('sum_connections'), {
      'plant': t(dicot ? 'sum_dicot' : 'sum_mono'),
    });
    final nodes = dicot
        ? const [
            (_Art.seedDicot, 'sum_seed', 'sum_2cot'),
            (_Art.leafReticulate, 'sum_leaf', 'sum_ret'),
            (_Art.rootTap, 'sum_root', 'sum_tap'),
          ]
        : const [
            (_Art.seedMonocot, 'sum_seed', 'sum_1cot'),
            (_Art.leafParallel, 'sum_leaf', 'sum_par'),
            (_Art.rootFibrous, 'sum_root', 'sum_fib'),
          ];
    final icon = 52 * s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            children: [
              Text(
                heading.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ink,
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: labLetterSpacing(heading, 1.5),
                ),
              ),
              SizedBox(height: 12 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < nodes.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 14 * s,
                        height: 4 * s,
                        margin: EdgeInsets.only(top: icon / 2 - 2 * s),
                        decoration: BoxDecoration(
                          color: line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    Expanded(
                      child: _node(
                        nodes[i].$1,
                        t(nodes[i].$2),
                        t(nodes[i].$3),
                        icon,
                        line,
                        glow,
                        ink,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showNext) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.amber400),
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _node(
    _Art art,
    String part,
    String trait,
    double icon,
    Color line,
    Color glow,
    Color ink,
  ) {
    final p = palette;
    final s = scale;
    return Column(
      children: [
        Container(
          width: icon,
          height: icon,
          padding: EdgeInsets.all(icon * 0.12),
          decoration: BoxDecoration(
            color: p.isDark ? _Colors.slate800 : _Colors.slate100,
            borderRadius: BorderRadius.circular(icon * 0.2),
            border: Border.all(color: line),
            boxShadow: [
              BoxShadow(color: glow.withValues(alpha: 0.6), blurRadius: 12),
            ],
          ),
          child: CustomPaint(painter: _ArtPainter(art)),
        ),
        SizedBox(height: 6 * s),
        Text(
          part.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: p.text,
            fontSize: 10 * s,
            fontWeight: FontWeight.w700,
            letterSpacing: labLetterSpacing(part, 0.5),
          ),
        ),
        Text(
          trait.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ink,
            fontSize: 10 * s,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: labLetterSpacing(trait, 0.5),
          ),
        ),
      ],
    );
  }
}

// ================================================================== PAINTING

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();

  /// Ellipsoids: a cached radial gradient (see [_PaintCache.shader]).
  final Paint blob = Paint();

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// The status lights' glow.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();

  /// Clip of a chickpea half (its side of the cut face).
  final Path clip = Path();

  /// Affine transform of a flat oval (column-major 4 x 4, identity
  /// elsewhere).
  final Float64List matrix = Float64List(16)
    ..[10] = 1
    ..[15] = 1;
}

/// What the painter makes once and reuses: pens, the ellipsoid shaders
/// (one per colour, drawn on a unit circle) and the label text painters.
/// Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<int, Shader> _shaders = {};
  final Map<String, TextPainter> _labels = {};
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

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle (lit from the upper right, like the HTML key light).
  Shader shader(Color c) => _shaders[c.toARGB32()] ??= ui.Gradient.radial(
    const Offset(0.32, -0.38),
    1.3,
    [labShade(c, 0.32), c, labShade(c, -0.48)],
    const [0, 0.42, 1],
  );

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    _shaders.clear();
  }
}

/// The HTML `SVGs` icons, redrawn as paths in their 24 x 24 view box (made
/// once): a seed (with the dicot's split line), a leaf with net-like or
/// parallel veins, a taproot and fibrous roots.
abstract final class _IconArt {
  static final Path _seam = Path()
    ..moveTo(12, 2)
    ..lineTo(12, 22);

  /// `M12 4v16 m-4-8h8 m-6-6l4 4 m-4 0l4-4 m-4 8l4 4 m-4 0l4-4`.
  static final Path _netVeins = Path()
    ..moveTo(12, 4)
    ..lineTo(12, 20)
    ..moveTo(8, 12)
    ..lineTo(16, 12)
    ..moveTo(10, 6)
    ..lineTo(14, 10)
    ..moveTo(10, 10)
    ..lineTo(14, 6)
    ..moveTo(10, 14)
    ..lineTo(14, 18)
    ..moveTo(10, 18)
    ..lineTo(14, 14);

  /// `M8 4v16 m8-16v16 m-4-16v16`.
  static final Path _parallelVeins = Path()
    ..moveTo(8, 4)
    ..lineTo(8, 20)
    ..moveTo(16, 4)
    ..lineTo(16, 20)
    ..moveTo(12, 4)
    ..lineTo(12, 20);

  /// `M12 2v18` (3 wide) and `M12 6l-3 3 m3-1l4 4 m-4 2l-2 2 m2-1l3 3`.
  static final Path _tapMain = Path()
    ..moveTo(12, 2)
    ..lineTo(12, 20);
  static final Path _tapSide = Path()
    ..moveTo(12, 6)
    ..lineTo(9, 9)
    ..moveTo(12, 8)
    ..lineTo(16, 12)
    ..moveTo(12, 14)
    ..lineTo(10, 16)
    ..moveTo(12, 15)
    ..lineTo(15, 18);

  /// Seven roots fanning out from (12, 2).
  static final Path _fibrous = () {
    final path = Path();
    for (final (x, y) in const [
      (8.0, 20.0),
      (10.0, 19.0),
      (12.0, 20.0),
      (14.0, 19.0),
      (16.0, 20.0),
      (6.0, 17.0),
      (18.0, 17.0),
    ]) {
      path
        ..moveTo(12, 2)
        ..lineTo(x, y);
    }
    return path;
  }();

  /// Draws [art] into [box] with the reused [fill] and [stroke] paints.
  /// [drawn] (0 – 1) is how far the lines have drawn themselves in: the
  /// HTML's `stroke-dasharray: 200` shows 200 view-box units at 1.
  static void draw(
    Canvas canvas,
    _Art art,
    Rect box,
    Paint fill,
    Paint stroke, {
    double drawn = 1,
  }) {
    canvas.save();
    canvas.translate(box.left, box.top);
    canvas.scale(box.width / 24, box.height / 24);
    void disc(Color color) =>
        canvas.drawCircle(const Offset(12, 12), 10, fill..color = color);
    void lines(Path path, Color color, double width) {
      stroke
        ..strokeWidth = width
        ..color = color;
      if (drawn >= 1) {
        canvas.drawPath(path, stroke);
        return;
      }
      final visible = 200 * drawn;
      if (visible <= 0) return;
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(
          metric.extractPath(0, math.min(metric.length, visible)),
          stroke,
        );
      }
    }

    switch (art) {
      case _Art.seedDicot:
        disc(_Colors.svgSeedDicot);
        lines(_seam, _Colors.svgSeam, 1.5);
      case _Art.seedMonocot:
        disc(_Colors.svgSeedMonocot);
      case _Art.leafReticulate:
        disc(_Colors.svgLeafNet);
        lines(_netVeins, _Colors.svgLeafNetVein, 1.5);
      case _Art.leafParallel:
        disc(_Colors.svgLeafParallel);
        lines(_parallelVeins, _Colors.svgLeafParallelVein, 1.5);
      case _Art.rootTap:
        lines(_tapMain, _Colors.svgTaproot, 3);
        lines(_tapSide, _Colors.svgTaproot, 1.5);
      case _Art.rootFibrous:
        lines(_fibrous, _Colors.svgFibrous, 1.5);
    }
    canvas.restore();
  }
}

/// An icon for widgets (observation cards, the summary). [progress] draws
/// its lines in (eased, as the HTML `ease-in-out` animation); without it
/// the icon is complete. The paints are shared.
class _ArtPainter extends CustomPainter {
  _ArtPainter(this.art, {this.progress}) : super(repaint: progress);

  final _Art art;
  final Animation<double>? progress;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress;
    _IconArt.draw(
      canvas,
      art,
      Offset.zero & size,
      _fill,
      _stroke,
      drawn: p == null ? 1 : Curves.easeInOut.transform(p.value),
    );
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.art != art || old.progress != progress;
}

/// MeshStandardMaterial look: ambient light plus the key and fill lights'
/// Lambert terms on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final i =
      (_ambient +
          _keyDiffuse * math.max(0.0, n.dot(_keyLight)) +
          _fillDiffuse * math.max(0.0, n.dot(_fillLight))) *
      _exposure;
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Segments of rims, discs and cylinders (smooth enough at this size).
const int _ringSides = 28;

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

  /// Cross-section direction at [a] radians in the x-z plane.
  static _V _dir(double a) => _V(math.cos(a), 0, math.sin(a));

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// BoxGeometry of [size] centred at [c].
  void box(_V c, _V size, Color color, {double edge = 0.35}) => obox(
    c,
    _V(size.x / 2, 0, 0),
    _V(0, size.y / 2, 0),
    _V(0, 0, size.z / 2),
    color,
    edge: edge,
  );

  /// A box centred at [c] with half-axis vectors [ax], [ay], [az] (a
  /// turned or scaled BoxGeometry): the faces turned to the camera, lit,
  /// with a darker rim.
  void obox(
    _V c,
    _V ax,
    _V ay,
    _V az,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
  }) {
    if (opacity <= 0.01) return;
    final axes = [ax, ay, az];
    for (var i = 0; i < 3; i++) {
      final a = axes[(i + 1) % 3];
      final b = axes[(i + 2) % 3];
      for (final sign in const [1.0, -1.0]) {
        final n = axes[i] * sign;
        final mid = c + n;
        final unit = n.unit;
        if (unit.dot(cam.eye - mid) <= 0) continue;
        final path = pens.path..reset();
        _to(path, 0, cam.p(mid + a + b));
        _to(path, 1, cam.p(mid + a - b));
        _to(path, 2, cam.p(mid - a - b));
        _to(path, 3, cam.p(mid - a + b));
        path.close();
        canvas.drawPath(
          path,
          pens.fill..color = _lit(color, unit, opacity: opacity),
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
  }

  /// Upright opaque CylinderGeometry: radius [r0] at [base], [r1] at the
  /// top, [h] high. The facets turned to the camera are lit one by one; the
  /// top is closed ([top]) when it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    bool top = true,
  }) {
    final topC = base + _V.up * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < _ringSides; i++) {
      final a0 = i * 2 * math.pi / _ringSides;
      final a1 = (i + 1) * 2 * math.pi / _ringSides;
      final m = _dir((a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final d0 = _dir(a0);
      final d1 = _dir(a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(topC + d1 * r1));
      _to(path, 3, cam.p(topC + d0 * r1));
      path.close();
      final c = _lit(color, n);
      canvas.drawPath(path, pens.fill..color = c);
      canvas.drawPath(path, pens.seam..color = c);
    }
    if (top && _V.up.dot(cam.eye - topC) > 0) {
      disc(topC, r1, _lit(color, _V.up));
    }
  }

  /// A see-through CylinderGeometry (glass, water) at [opacity]: the side
  /// turned to the camera as one shape (no seams between facets), closed
  /// by its lit top when [top]; [highlight] adds the glass's sheen.
  void glass(
    _V base,
    double r0,
    double r1,
    double h,
    Color color,
    double opacity, {
    bool top = false,
    bool highlight = false,
  }) {
    final topC = base + _V.up * h;
    final slope = (r0 - r1) / h;
    const step = 2 * math.pi / _ringSides;
    bool facing(int i) {
      final m = _dir(i * step);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((r0 + r1) / 2);
      return n.dot(cam.eye - mid) > 0;
    }

    var start = 0;
    for (var i = 0; i < _ringSides; i++) {
      if (facing(i) && !facing((i - 1 + _ringSides) % _ringSides)) {
        start = i;
        break;
      }
    }
    // The facing arc with one vertex past each end (the silhouette lies
    // between them).
    final arc = <int>[(start - 1 + _ringSides) % _ringSides];
    var i = start;
    while (facing(i) && arc.length <= _ringSides) {
      arc.add(i);
      i = (i + 1) % _ringSides;
    }
    arc.add(i);
    final path = pens.path..reset();
    for (var k = 0; k < arc.length; k++) {
      _to(path, k, cam.p(base + _dir(arc[k] * step) * r0));
    }
    for (var k = arc.length - 1; k >= 0; k--) {
      final o = cam.p(topC + _dir(arc[k] * step) * r1);
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(0, 0, 1), opacity: opacity),
    );
    if (highlight) {
      final d = _dir(math.pi / 3);
      final a = base + d * r0 + _V.up * (h * 0.1);
      final b = topC + d * r1 - _V.up * (h * 0.1);
      canvas.drawLine(
        cam.p(a),
        cam.p(b),
        pens.stroke
          ..strokeWidth = math.max(1, 0.1 * cam.scaleAt(a))
          ..color = LabInk.white.withValues(alpha: 0.3),
      );
    }
    if (top && _V.up.dot(cam.eye - topC) > 0) {
      disc(topC, r1, _lit(color, _V.up, opacity: opacity));
    }
  }

  /// A flat horizontal disc of radius [r] centred at [c].
  void disc(_V c, double r, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// The outline of a horizontal circle (a rim).
  void ring(_V c, double r, Color color, double width) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  /// Soft blurred shadow of a round footprint on a surface at height [y].
  void shadow(double x, double z, double rx, double rz, {double y = 0}) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, y + 0.01, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// Ellipsoid (a scaled SphereGeometry) centred at [c] with semi-axis
  /// vectors [ax], [ay], [az]: the projected outline is the ellipse whose
  /// shape matrix is the sum of the projected axes' outer products, filled
  /// with a cached lit-sphere gradient.
  void blob(_V c, _V ax, _V ay, _V az, Color color, {double opacity = 1}) {
    if (opacity <= 0.01) return;
    final o = cam.p(c);
    final a = cam.p(c + ax) - o;
    final b = cam.p(c + ay) - o;
    final d = cam.p(c + az) - o;
    final sxx = a.dx * a.dx + b.dx * b.dx + d.dx * d.dx;
    final syy = a.dy * a.dy + b.dy * b.dy + d.dy * d.dy;
    final sxy = a.dx * a.dy + b.dx * b.dy + d.dx * d.dy;
    final half = (sxx + syy) / 2;
    final root = math.sqrt((sxx - syy) * (sxx - syy) / 4 + sxy * sxy);
    final rx = math.sqrt(half + root);
    final ry = math.sqrt(math.max(0.0, half - root));
    if (rx < 0.4) return;
    final angle = 0.5 * math.atan2(2 * sxy, sxx - syy);
    canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..rotate(angle)
      ..scale(rx, math.max(ry, 0.5))
      ..rotate(-angle)
      ..drawCircle(
        Offset.zero,
        1,
        pens.blob
          ..shader = cache.shader(color)
          ..color = LabInk.black.withValues(alpha: opacity),
      )
      ..restore();
  }

  /// Axis-aligned ellipsoid with semi-axes [r] at [c].
  void ellipsoid(_V c, _V r, Color color, {double opacity = 1}) => blob(
    c,
    _V(r.x, 0, 0),
    _V(0, r.y, 0),
    _V(0, 0, r.z),
    color,
    opacity: opacity,
  );

  /// A flat oval centred at [c] with semi-axis vectors [a] and [b] (a
  /// leaf, a lens), filled with one lit colour.
  void flatOval(_V c, _V a, _V b, Color color) {
    final o = cam.p(c);
    final pa = cam.p(c + a) - o;
    final pb = cam.p(c + b) - o;
    final m = pens.matrix
      ..[0] = pa.dx
      ..[1] = pa.dy
      ..[4] = pb.dx
      ..[5] = pb.dy
      ..[12] = o.dx
      ..[13] = o.dy;
    canvas
      ..save()
      ..transform(m)
      ..drawCircle(Offset.zero, 1, pens.fill..color = color)
      ..restore();
  }

  /// Thin cylinder from [a] (radius [ra]) to [b] (radius [rb]), drawn as a
  /// tapered band with a highlight on the lit side and a shaded edge.
  void rod(_V a, _V b, double ra, double rb, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.6, ra * cam.scaleAt(a));
    final wb = math.max(0.6, rb * cam.scaleAt(b));
    final paint = pens.fill..color = color;
    final dir = pb - pa;
    final len = dir.distance;
    if (len < 0.01) {
      canvas.drawCircle(pa, wa, paint);
      return;
    }
    final n = Offset(-dir.dy, dir.dx) / len;
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas
      ..drawPath(path, paint)
      ..drawCircle(pa, wa, paint)
      ..drawCircle(pb, wb, paint);
    final side = n.dx * _screenLight.dx + n.dy * _screenLight.dy > 0
        ? 1.0
        : -1.0;
    final w = (wa + wb) / 2;
    canvas
      ..drawLine(
        pa + n * (wa * 0.45 * side),
        pb + n * (wb * 0.45 * side),
        pens.stroke
          ..strokeWidth = math.max(0.7, w * 0.35)
          ..color = labShade(color, 0.4).withValues(alpha: 0.55),
      )
      ..drawLine(
        pa - n * (wa * 0.72 * side),
        pb - n * (wb * 0.72 * side),
        pens.stroke
          ..strokeWidth = math.max(0.6, w * 0.3)
          ..color = labShade(color, -0.4).withValues(alpha: 0.6),
      );
  }
}

/// Paints the HTML Three.js lab bench of the current scenario: the beaker,
/// the dissection tray, the scalpel, the Plant Grower, the seed through
/// all its stages and, once grown, the potted plant and the magnifying
/// glass; then the labels, the held object and the confetti on top.
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

  /// The seed lies on the bench / tray (or rises into the funnel): not in
  /// the beaker, not in the learner's hand.
  bool get _seedOnBench =>
      scene.seedVisible && !scene.seedInBeaker && scene.held != _Item.seed;

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.camera(), cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    // Lab bench `BoxGeometry(30, 1, 15)`.
    g.box(_benchCenter, _benchSize, _Colors.bench, edge: 0.25);
    _paintShadows(g);
    _paintBeaker(g);
    _paintMachine(g);
    _paintTray(g);
    if (_seedOnBench) {
      _seedShadow(g, s.seedAt);
      _paintSeed(g, s.seedAt);
    }
    if (s.held != _Item.scalpel) {
      _scalpelShadow(g, s.scalpelAt);
      _paintScalpel(g, s.scalpelAt);
    }
    if (s.plantVisible) _paintPlant(g);
    if (s.magVisible) _paintMagnifier(g);
    if (showLabels) _paintLabels(g);
    _paintHeld(g);
    if (s.confetti.isNotEmpty) _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- shadows

  /// Contact shadows of the beaker, machine, tray and pot (the key light at
  /// (15, 25, 15) casts towards -x / -z).
  void _paintShadows(_Gfx g) {
    g.shadow(
      _beakerAt.x - 0.35,
      _beakerAt.z - 0.3,
      _beakerR + 0.2,
      _beakerR + 0.05,
    );
    g.shadow(
      _machineAt.x - 0.4,
      _machineAt.z - 0.35,
      _machineSize.x / 2 + 0.3,
      _machineSize.z / 2 + 0.2,
    );
    g.shadow(
      _trayAt.x - 0.15,
      _trayAt.z - 0.15,
      _trayHalfX + 0.1,
      _trayHalfZ + 0.05,
    );
    if (scene.plantVisible) {
      g.shadow(_potAt.x - 0.3, _potAt.z - 0.25, _potTopR + 0.1, _potTopR);
    }
  }

  /// The tray's floor (0.1) or the bench (0) under [at].
  double _surfaceY(_V at) =>
      (at.x - _trayAt.x).abs() < _trayHalfX &&
          (at.z - _trayAt.z).abs() < _trayHalfZ
      ? 0.1
      : 0;

  void _seedShadow(_Gfx g, _V at) {
    if (at.y > 1) return; // On its way into the funnel.
    final r = scene.seedRadius;
    g.shadow(at.x - 0.12, at.z - 0.08, r * 1.1, r * 0.9, y: _surfaceY(at));
  }

  void _scalpelShadow(_Gfx g, _V at) =>
      g.shadow(at.x - 0.55, at.z - 0.1, 0.7, 0.14, y: _surfaceY(at));

  // ------------------------------------------------------------ props

  /// The beaker: glass base, the soaking seed (seen through the water),
  /// the water and the glass wall with its rim.
  void _paintBeaker(_Gfx g) {
    final s = scene;
    g.glass(
      _beakerAt,
      _beakerR,
      _beakerR,
      0.1,
      _Colors.glass,
      _glassOpacity,
      top: true,
    );
    if (s.seedInBeaker && s.seedVisible && s.held != _Item.seed) {
      _paintSeed(g, s.seedAt);
    }
    g.glass(
      _beakerAt,
      _waterR,
      _waterR,
      _waterH,
      _Colors.water,
      _waterOpacity,
      top: true,
    );
    g.glass(
      _beakerAt,
      _beakerR,
      _beakerR,
      _beakerH,
      _Colors.glass,
      _glassOpacity,
      highlight: true,
    );
    g.ring(
      _beakerAt + const _V(0, _beakerH, 0),
      _beakerR,
      _Colors.glass.withValues(alpha: 0.55),
      1.2,
    );
  }

  /// The Plant Grower: its body, the three status lights on the front
  /// (black, green while it works) and the open funnel on top.
  void _paintMachine(_Gfx g) {
    final s = scene;
    g.box(
      _machineAt + _V(0, _machineSize.y / 2, 0),
      _machineSize,
      _Colors.machine,
    );
    for (final x in _lightXs) {
      final c = _machineAt + _V(x, _lightY, _machineSize.z / 2);
      final p = g.cam.p(c);
      final r = math.max(1.5, _lightR * g.cam.scaleAt(c));
      if (s.lightsOn) {
        g.canvas.drawCircle(
          p,
          r * 2.6,
          _pens.glow..color = _Colors.lightOn.withValues(alpha: 0.7),
        );
      }
      g.canvas.drawCircle(
        p,
        r,
        _pens.fill..color = s.lightsOn ? _Colors.lightOn : _Colors.lightOff,
      );
    }
    const mouth = _V(6, _funnelTopY, -2);
    g.disc(mouth, _funnelTopR, labShade(_Colors.machine, -0.45));
    g.cylinder(
      _machineAt + const _V(0, _funnelBottomY, 0),
      _funnelBottomR,
      _funnelTopR,
      _funnelTopY - _funnelBottomY,
      _Colors.machine,
      top: false,
    );
    g.ring(mouth, _funnelTopR, labShade(_Colors.machine, 0.3), 1.2);
  }

  /// The dissection tray: base and four rims, back to front.
  void _paintTray(_Gfx g) {
    const c = _trayAt;
    g.box(c + const _V(0, 0.05, 0), const _V(5, 0.1, 3), _Colors.tray);
    g.box(c + const _V(0, 0.15, -1.4), const _V(5, 0.3, 0.2), _Colors.tray);
    g.box(c + const _V(-2.4, 0.15, 0), const _V(0.2, 0.3, 2.6), _Colors.tray);
    g.box(c + const _V(2.4, 0.15, 0), const _V(0.2, 0.3, 2.6), _Colors.tray);
    g.box(c + const _V(0, 0.15, 1.4), const _V(5, 0.3, 0.2), _Colors.tray);
  }

  /// The scalpel: dark handle and the metal blade at its end.
  void _paintScalpel(_Gfx g, _V at) {
    g.rod(at + const _V(-1, 0, 0), at, _handleR, _handleR, _Colors.handle);
    final c = at + _bladeOffset;
    const w = _bladeHalfW, h = _bladeHalfH;
    g.poly([
      c + const _V(-w, -h, 0),
      c + const _V(w, -h, 0),
      c + const _V(w, h, 0),
      c + const _V(-w, h, 0),
    ], _lit(_Colors.blade, const _V(0, 0, 1)));
    // The bright cutting edge (`metalness 0.8`).
    g.canvas.drawLine(
      g.cam.p(c + const _V(-w, -h, 0)),
      g.cam.p(c + const _V(w, -h, 0)),
      _pens.stroke
        ..strokeWidth = math.max(1, 0.03 * g.cam.scaleAt(c))
        ..color = _Colors.white.withValues(alpha: 0.85),
    );
  }

  // ------------------------------------------------------------- seed

  /// The seed at [at]: the chickpea's coat over its two halves (they part
  /// when split), the maize kernel's coat over its solid core (it jiggles
  /// when the learner tries to split it). The coat fades once peeled.
  void _paintSeed(_Gfx g, _V at) {
    final s = scene;
    final k = s.seedScaleNow;
    final coat = s.coatAlpha;
    if (s.isDicot) {
      if (coat < 0.99) {
        final gap = s.halfGap * k.x;
        _paintHalf(g, at + _V(-gap, 0, 0), k, -1);
        _paintHalf(g, at + _V(gap, 0, 0), k, 1);
      }
      if (coat > 0.01) {
        g.ellipsoid(at, k * _coatR, _Colors.seedCoat, opacity: coat);
      }
      return;
    }
    final a = s.jiggle;
    if (coat < 0.99) {
      final h = _maizeCore.times(k) * 0.5;
      g.obox(
        at,
        _rotZ(_V(h.x, 0, 0), a),
        _rotZ(_V(0, h.y, 0), a),
        _V(0, 0, h.z),
        _Colors.maize,
      );
    }
    if (coat > 0.01) {
      final h = _maizeCoat.times(k) * 0.5;
      g.obox(
        at,
        _rotZ(_V(h.x, 0, 0), a),
        _rotZ(_V(0, h.y, 0), a),
        _V(0, 0, h.z),
        _Colors.seedCoat,
        opacity: coat,
      );
    }
  }

  /// One chickpea half (cotyledon) centred at [c]: a half sphere whose
  /// flat face looks towards the other half ([side] -1 is the left half),
  /// and that face where it turns to the camera. (The HTML turns both half
  /// spheres the other way round, so its halves overlap instead of
  /// parting.)
  void _paintHalf(_Gfx g, _V c, _V k, double side) {
    final cam = g.cam;
    final ax = _V(_halfR * k.x, 0, 0);
    final ay = _V(0, _halfR * k.y, 0);
    final az = _V(0, 0, _halfR * k.z);
    final pc = cam.p(c);
    var d = cam.p(c + ay) - pc;
    final len = d.distance;
    d = len < 0.01 ? const Offset(0, -1) : d / len;
    var n = Offset(-d.dy, d.dx);
    final out = cam.p(c + ax * side) - pc;
    if (n.dx * out.dx + n.dy * out.dy < 0) n = -n;
    final r = (ax.length + ay.length + az.length) * cam.scaleAt(c) * 2 + 4;
    final clip = _pens.clip
      ..reset()
      ..moveTo(pc.dx + d.dx * r, pc.dy + d.dy * r)
      ..lineTo(pc.dx - d.dx * r, pc.dy - d.dy * r)
      ..lineTo(pc.dx - d.dx * r + n.dx * r, pc.dy - d.dy * r + n.dy * r)
      ..lineTo(pc.dx + d.dx * r + n.dx * r, pc.dy + d.dy * r + n.dy * r)
      ..close();
    g.canvas
      ..save()
      ..clipPath(clip);
    g.blob(c, ax, ay, az, _Colors.chickpea);
    g.canvas.restore();
    if (_V(-side, 0, 0).dot(cam.eye - c) > 0) {
      g.blob(c, ax * 0.02, ay, az, _Colors.cotyledonFace);
    }
  }

  // ------------------------------------------------------------ plant

  /// The pot (glass base, soil, glass wall) and the plant standing in it:
  /// the roots that are out of the soil, the stem and the leaves.
  void _paintPlant(_Gfx g) {
    final s = scene;
    g.glass(
      _potAt,
      _potBottomR,
      _potBottomR,
      0.1,
      _Colors.glass,
      _glassOpacity,
      top: true,
    );
    final soilH = _soilH * s.soilScale;
    g.cylinder(
      _potAt + _V(0, _soilMidY - soilH / 2, 0),
      _soilBottomR,
      _soilTopR,
      soilH,
      _Colors.soil,
    );
    g.glass(
      _potAt,
      _potBottomR,
      _potTopR,
      _potH,
      _Colors.glass,
      _glassOpacity,
      highlight: true,
    );
    g.ring(
      _potAt + const _V(0, _potH, 0),
      _potTopR,
      _Colors.glass.withValues(alpha: 0.55),
      1.2,
    );
    final base = s.plantBase;
    // The HTML's fibrous root tips stop 0.1 above the soil line: hairs
    // there, specks here. The roots show once the plant is lifted.
    if (s.pullNow > 0.01) _paintRoots(g, base, _potAt.y + s.soilTop);
    if (s.isDicot) {
      // Leaves behind the stem first.
      for (final l in _dicotLeaves) {
        if (l.center.z < 0) _paintLeaf(g, base, l);
      }
      g.rod(base, base + const _V(0, _dicotStemH, 0), 0.05, 0.04, _Colors.stem);
      for (final l in _dicotLeaves) {
        if (l.center.z >= 0) _paintLeaf(g, base, l);
      }
    } else {
      g.rod(
        base,
        base + const _V(0, _monocotStemH, 0),
        0.08,
        0.06,
        _Colors.stem,
      );
      for (final b in _monocotBlades) {
        _paintBlade(g, base, b);
      }
    }
  }

  /// The roots above the soil (the soil hides the rest, as in the HTML):
  /// each root is cut where it enters the soil.
  void _paintRoots(_Gfx g, _V base, double soilTop) {
    final roots = scene.isDicot ? _taproot : _fibrousRoots;
    for (final root in roots) {
      final a = base + root.top;
      final b = base + root.tip;
      if (a.y <= soilTop && b.y <= soilTop) continue;
      var from = a, to = b;
      var ra = root.topR, rb = root.tipR;
      if (a.y < soilTop) {
        final t = (soilTop - a.y) / (b.y - a.y);
        from = _V.lerp(a, b, t);
        ra = root.topR + (root.tipR - root.topR) * t;
      } else if (b.y < soilTop) {
        final t = (soilTop - a.y) / (b.y - a.y);
        to = _V.lerp(a, b, t);
        rb = root.topR + (root.tipR - root.topR) * t;
      }
      g.rod(from, to, ra, rb, _Colors.root);
    }
  }

  /// A chickpea leaf: a flat oval, lit on the side facing the camera
  /// (`side: DoubleSide`).
  void _paintLeaf(_Gfx g, _V base, _LeafShape l) {
    final c = base + l.center;
    var n = l.across.cross(l.along).unit;
    if (n.dot(g.cam.eye - c) < 0) n = -n;
    g.flatOval(c, l.along, l.across, _lit(_Colors.leaf, n));
  }

  /// A maize leaf: a long blade tapering to its tip.
  void _paintBlade(_Gfx g, _V base, _Blade b) {
    final p0 = base + b.base;
    final p1 = base + b.tip;
    var n = b.normal;
    if (n.dot(g.cam.eye - (p0 + p1) * 0.5) < 0) n = -n;
    g.poly([
      p0 + b.across * _Blade.baseHalf,
      p1 + b.across * _Blade.tipHalf,
      p1 - b.across * _Blade.tipHalf,
      p0 - b.across * _Blade.baseHalf,
    ], _lit(_Colors.leaf, n));
  }

  /// The magnifying glass, bobbing near the leaves: handle, lens and ring.
  void _paintMagnifier(_Gfx g) {
    final c = scene.magAt;
    final cam = g.cam;
    const dir = _V(0.7071, -0.7071, 0);
    final grip = c + dir * (_magR + _magTube);
    g.rod(
      grip,
      grip + dir * _magHandleLen,
      _magHandleR,
      _magHandleR,
      _Colors.handle,
    );
    g.flatOval(
      c,
      const _V(_lensR, 0, 0),
      const _V(0, _lensR, 0),
      _lit(_Colors.water, const _V(0, 0, 1), opacity: _waterOpacity),
    );
    final k = cam.scaleAt(c);
    // A glint on the glass.
    final glint = _pens.path..reset();
    for (var i = 0; i <= 8; i++) {
      final a = math.pi * (0.55 + i * 0.05);
      final o = cam.p(c + _V(math.cos(a) * 0.32, math.sin(a) * 0.32, 0));
      if (i == 0) {
        glint.moveTo(o.dx, o.dy);
      } else {
        glint.lineTo(o.dx, o.dy);
      }
    }
    g.canvas.drawPath(
      glint,
      _pens.stroke
        ..strokeWidth = math.max(1, 0.05 * k)
        ..color = _Colors.white.withValues(alpha: 0.7),
    );
    // The ring (`TorusGeometry(0.5, 0.05)`), with a light edge so it shows
    // on the dark scene.
    final ring = _pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      final o = cam.p(c + _V(math.cos(a) * _magR, math.sin(a) * _magR, 0));
      if (i == 0) {
        ring.moveTo(o.dx, o.dy);
      } else {
        ring.lineTo(o.dx, o.dy);
      }
    }
    ring.close();
    g.canvas
      ..drawPath(
        ring,
        _pens.stroke
          ..strokeWidth = math.max(1.5, 2 * _magTube * k)
          ..color = _Colors.handle,
      )
      ..drawPath(
        ring,
        _pens.stroke
          ..strokeWidth = math.max(0.6, 0.5 * _magTube * k)
          ..color = labShade(_Colors.handle, 0.5),
      );
  }

  // ----------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip (HTML `labelDict`).
  void _paintLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    _chip(g, cam.p(_beakerLabelAt), _t('lbl_beaker'), _centred);
    _chip(g, cam.p(_machineLabelAt), _t('lbl_grower'), _centred);
    if (s.held != _Item.scalpel) {
      _chip(
        g,
        cam.p(s.scalpelAt + _scalpelLabelOffset),
        _t('lbl_scalpel'),
        _above,
      );
    }
    if (s.seedVisible && s.held != _Item.seed) _seedChip(g, s.seedAt);
  }

  /// The seed's label just above it; while it soaks, beside the beaker
  /// (clear of the beaker's own label).
  void _seedChip(_Gfx g, _V at) {
    final name = _t(scene.isDicot ? 'lbl_chickpea' : 'lbl_maize');
    if (scene.seedInBeaker) {
      _chip(
        g,
        g.cam.p(_V(_beakerAt.x + _beakerR + 0.2, _soakY, _beakerAt.z)),
        name,
        (-1, 0),
      );
      return;
    }
    _chip(
      g,
      g.cam.p(at + _V(0, scene.seedRadius + _seedLabelGap, 0)),
      name,
      _above,
    );
  }

  /// The object in the learner's hand, on top of everything, with its
  /// shadow and label.
  void _paintHeld(_Gfx g) {
    final s = scene;
    final at = s.heldAt;
    if (s.held == _Item.seed) {
      _seedShadow(g, at);
      _paintSeed(g, at);
      if (showLabels) _seedChip(g, at);
    } else if (s.held == _Item.scalpel) {
      _scalpelShadow(g, at - const _V(0, 0, 0.15));
      _paintScalpel(g, at);
      if (showLabels) {
        _chip(g, g.cam.p(at + _scalpelLabelOffset), _t('lbl_scalpel'), _above);
      }
    }
  }

  /// HTML `createTextSprite`: dark chip with a teal border and white bold
  /// text, placed on [at] by [align] and kept inside the visible canvas.
  /// The label of an object outside the canvas (the beaker while the
  /// camera is at the Plant Grower) is not drawn.
  void _chip(_Gfx g, Offset at, String text, (double, double) align) {
    final s = scene;
    if (at.dx < s.labelLeft || at.dx > s.labelRight) return;
    final size = cache.chipSize(text);
    var rect = (at + _chipOffset(size, align)) & size;
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
    final tp = cache.label(text);
    tp.paint(
      g.canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.top + _chipPadY * cache.labelSize,
      ),
    );
  }

  // --------------------------------------------------------- confetti

  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final fade = 1 - ((s.time - s.confettiStart) / _confettiSeconds);
    if (fade <= 0) return;
    final paint = _pens.fill;
    for (final c in s.confetti) {
      paint.color = c.color.withValues(alpha: fade.clamp(0.0, 1.0));
      canvas
        ..save()
        ..translate(c.x, c.y)
        ..rotate(c.wobble)
        ..scale(1, 0.5 + 0.5 * math.cos(c.wobble * 1.3).abs())
        ..drawRect(const Rect.fromLTWH(-5, -3.5, 10, 7), paint)
        ..restore();
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
