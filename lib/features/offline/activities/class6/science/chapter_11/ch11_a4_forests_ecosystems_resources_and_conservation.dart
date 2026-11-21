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

/// Class 6 Science • Chapter 11 • Activity 4
/// Forests: Ecosystems, Resources, and Conservation.
///
/// Native Flutter port of
/// `Cl6S-Ch11-A4-Forests__Ecosystems__Resources__and_Conservation.html`
/// (Three.js r128 + Tween.js). The Three.js scenes are redrawn by a small
/// painter ([_Gfx]) that reproduces the HTML camera: position (0, 7.5, 23),
/// look-at (0, 1.8, 0), 45° field of view, with its ambient, warm key and
/// sky-blue fill lights. The HTML "Controls" inventory (drag or tap the
/// items) becomes a card on the canvas.
///
/// Scenario 1 (The Hugging Trees Movement (Chipko)): a forest island with
/// five tall trees, a spotted deer, a langur monkey, a forest bird and the
/// village leader with her staff. Tapping an animal makes it hop and opens
/// step 2. 'Hug Trees' (dragged onto the forest or tapped) sends three
/// village women, one by one, to wrap their arms round three trunks. 'Start
/// Cutting' brings two loggers with chainsaws: red X badges appear over
/// them at the hugged trees, the two unprotected trees crash down, the deer
/// and the bird flee, and the conserved and barren sides are compared before
/// the Chipko summary opens.
///
/// Scenario 2 (The Forest's Soil Blanket): two hillsides, a forested one
/// with leaf litter and roots and a deforested one with stumps, each above
/// a clear stream. Tapping the hills observes them; the rain cloud (dragged
/// over the hills, tapped, or a tap on the canvas) brings a thunderstorm:
/// rain and ripples on both hills, gullies carved and soil washing down the
/// bare hill, whose stream turns muddy brown while the forest stream stays
/// clear. The soil-blanket summary closes the lab.
class Ch11A4ForestsEcosystemsResourcesAndConservationPage
    extends StatefulWidget {
  const Ch11A4ForestsEcosystemsResourcesAndConservationPage({super.key});

  @override
  State<Ch11A4ForestsEcosystemsResourcesAndConservationPage> createState() =>
      _ForestsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises three Web Audio tones; they map to the closest files:
/// 'click' (Hug Trees, the rain cloud) → click (`science/click.mp3`),
/// 'success' (an animal tapped, a hill observed, the summary) → success
/// (`math/success.mp3`) and 'cut' (the chainsaws' sawtooth buzz) → cut
/// (`science/error.mp3`, the closest harsh buzz). The shell plays toggle
/// (`science/dropdown.mp3`), correct (`math/success.mp3`), wrong
/// (`science/error.mp3`, its error toasts), scenario
/// (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; a village woman sent to a tree, the rain cloud
  /// started or stopped (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toasts of the shell.
  correct('audio/class6/math/success.mp3'),

  /// The shell's error toasts (the HTML has no error tone).
  wrong('audio/class6/science/error.mp3'),

  /// An animal tapped, a hill observed and the summary popup (HTML
  /// `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// The chainsaws start and the unprotected trees are cut (HTML `cut`).
  cut('audio/class6/science/error.mp3');

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

/// Colours of the HTML page (Tailwind classes), of its Three.js scenes
/// (material colours) and of its SVG icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color amber600 = Color(0xFFD97706);
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
  /// `scene.background`: 0x1e293b (dark theme), 0xa7f3d0 (light theme) and
  /// the thunder sky 0x0f172a of `setStormAtmosphere(true)`.
  static const Color sceneDark = slate800;
  static const Color sceneLight = Color(0xFFA7F3D0);
  static const Color sceneStorm = slate900;

  /// Scenario 1 forest island: `CylinderGeometry(14.5, 15.5, 1.6)` and its
  /// lawn `CircleGeometry(14.3)`.
  static const Color island = Color(0xFF14532D);
  static const Color lawn = Color(0xFF166534);

  /// `buildNaturalTreeMesh`: bark and the three foliage crowns.
  static const Color bark = Color(0xFF5C4033);
  static const Color crown1 = Color(0xFF14532D);
  static const Color crown2 = Color(0xFF16A34A);
  static const Color crown3 = Color(0xFF22C55E);

  /// `buildWomanMesh`: hair, gold jewellery, eyes, lips, bindi, sandals,
  /// the gajra and the two glass bangles.
  static const Color hair = slate900;
  static const Color gold = Color(0xFFF59E0B);
  static const Color eye = slate900;
  static const Color lips = Color(0xFFE11D48);
  static const Color bindi = red600;
  static const Color sandal = Color(0xFF78350F);
  static const Color gajra = Color(0xFFFEF08A);
  static const Color bangleRight = emerald500;
  static const Color bangleLeft = Color(0xFFF43F5E);

  /// The leader's staff.
  static const Color staff = Color(0xFF78350F);

  /// `buildLoggerMesh`: flannel, denim, skin, hard hat, boots, gloves,
  /// beard; `buildChainsawMesh`: engine, grips, chain teeth.
  static const Color flannel = red600;
  static const Color denim = slate700;
  static const Color loggerSkin = Color(0xFFFECCA2);
  static const Color hardHat = yellow400;
  static const Color boots = slate900;
  static const Color gloves = amber600;
  static const Color beard = slate800;
  static const Color engine = Color(0xFFEA580C);
  static const Color grip = Color(0xFF18181B);
  static const Color chainTeeth = slate700;

  /// The red X badge canvas (`#ef4444`, white strokes).
  static const Color badge = red500;

  /// `buildDeerMesh`.
  static const Color coat = amber600;
  static const Color deerBelly = Color(0xFFFEF08A);
  static const Color hoof = slate800;
  static const Color antler = Color(0xFFFDE047);
  static const Color nose = Color(0xFF09090B);

  /// `buildMonkeyMesh`.
  static const Color fur = Color(0xFF92400E);
  static const Color monkeyFace = Color(0xFFFEF3C7);
  static const Color monkeyNose = Color(0xFF451A03);

  /// `buildBirdMesh`.
  static const Color feather = Color(0xFF0EA5E9);
  static const Color birdChest = yellow400;
  static const Color wing = Color(0xFF0284C7);
  static const Color beak = Color(0xFFF97316);

  /// Scenario 2: the two hills, leaf litter, roots, the streams (clear and
  /// muddy), stumps and their cut rings.
  static const Color forestHill = Color(0xFF15803D);
  static const Color leafLitter = Color(0xFF451A03);
  static const Color root = amber600;
  static const Color stream = Color(0xFF0284C7);
  static const Color muddy = Color(0xFF713F12);
  static const Color bareHill = Color(0xFFA16207);
  static const Color stump = Color(0xFF4A2E18);
  static const Color stumpRing = amber600;

  /// `buildCloudMesh`: puffs, the dark bases and the storm puffs.
  static const Color cloud = slate300;
  static const Color cloudBase = slate500;
  static const Color cloudStorm = slate600;

  /// Gullies, washed soil and the mud bubbles in the right stream.
  static const Color gully = muddy;
  static const Color soil = Color(0xFF854D0E);

  /// Rain streaks (`0x38bdf8` / `0xbae6fd`, 95%) and splash rings.
  static const Color rainA = sky400;
  static const Color rainB = Color(0xFFBAE6FD);
  static const Color ripple = Color(0xFFBAE6FD);

  /// Text sprites (`updateAllSpriteLabels`): `rgba(30, 41, 59, 0.92)` chip,
  /// `#475569` border, white bold text.
  static const Color chipBg = Color(0xEB1E293B);
  static const Color chipBorder = slate600;
  static const Color chipText = white;

  /// Soft contact shadows (the HTML scene casts shadows) and the highlight
  /// ring of the next tree while a woman is dragged (added).
  static const Color shadow = Color(0x47000000);
  static const Color hint = emerald400;

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
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66047857), // from-emerald-700/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // text-emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
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
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
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
    curtainGlow: Color(0x66047857),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
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
// Current Task, Success!, the settings and canvas-tool names, the footer
// and the summary's "Scenario Complete! Please select next scenario"
// banner) come from the shell's `kLabCommonStrings`. `sN_hud_M` are the
// HTML `hud` lines, `sN_focus_M` / `sN_step_M` / `sN_obs_M` the step
// concept, action and observation, `sN_sum_title` / `sN_summary` the bold
// heading and the text of the HTML `summary`. 'CLICK' (and a toast's
// 'click') became 'TAP' ('क्लिक' → 'टैप'). Keys marked "HTML literal"
// are texts the HTML hard-codes in English; their Hindi is added. Keys
// marked "Added." are new texts the HTML did not have. The HTML's unused
// `next_sc` and `sc_complete`, and its success modal's `restart_lab` (the
// shell's 'Restart Lab' button), are not kept.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Forests: Ecosystems, Resources, and Conservation',
    'app_subtitle': "Class 6 . Nature's Treasures",
    'scen_1_opt': 'Scenario 1: The Hugging Trees Movement (Chipko)',
    'scen_2_opt': "Scenario 2: The Forest's Soil Blanket",
    's1_desc':
        'To understand the impact of deforestation on wildlife and learn how community action can protect forests.',
    's2_desc':
        'To investigate how forests prevent soil erosion and act as a natural protective blanket for the land.',
    // HTML `hud` lines.
    's1_hud_1':
        'Step 1: You are in a vibrant forest. OBSERVE the scene. TAP on the different animals (deer, monkey, bird) to see them in their habitat.',
    's1_hud_2':
        'Step 2: A team of loggers has arrived to cut down the trees. DRAG the villagers from the corner and DROP them onto the trees to protect them. Protect at least three trees.',
    's1_hud_3':
        "Step 3: Now, TAP the 'Start Cutting' button to see how the loggers react to the protected trees vs unprotected trees.",
    's1_hud_4':
        'Step 4: The loggers have left. OBSERVE the result. Compare the conserved forest area where trees were hugged with the barren deforested area.',
    's1_hud_5':
        'Step 5: CHIPKO: RESPONSIBLE CONSERVATION. Review how local women led the community to preserve their natural ecosystem.',
    's2_hud_1':
        'Step 1: Here are two hillsides. Left Hill is a healthy forest; Right Hill has been deforested. OBSERVE the ground differences.',
    's2_hud_2':
        'Step 2: DRAG the rain cloud from the top and POSITION it over both hills to make it rain evenly.',
    's2_hud_3':
        'Step 3: WATCH the water run down the hills. OBSERVE the color of the water in the streams at the bottom.',
    's2_hud_4':
        'Step 4: FORESTS AS NATURAL BLANKET. Review how roots anchor soil and leaf litter acts like a protective sponge against erosion.',
    // HTML `steps`.
    's1_focus_1': 'Observe Forest Ecosystem',
    's1_step_1':
        'You are in a vibrant forest. OBSERVE the scene. TAP on the different animals (deer, monkey, bird) to see them in their habitat.',
    's1_obs_1':
        'The user familiarizes themselves with the forest environment and sees it as a living, interconnected ecosystem.',
    's1_focus_2': 'Protect the Trees',
    's1_step_2':
        'A team of loggers has arrived to cut down the trees. DRAG the villagers from the corner and DROP them onto the trees to protect them. You must protect at least three trees.',
    's1_obs_2':
        'The user places brave local women on three different trees where they wrap their arms around the trunks in protection.',
    's1_focus_3': 'Start Cutting',
    's1_step_3':
        "Now, TAP the 'Start Cutting' button to see what the loggers do.",
    's1_obs_3':
        'Loggers respect the hugged trees (red X badge appears over chainsaws) but cut down unprotected trees, causing birds and monkeys to flee.',
    's1_focus_4': 'Observe the Result',
    's1_step_4':
        'The loggers have left. OBSERVE the result. Compare the conserved forest area with the deforested area.',
    's1_obs_4':
        'A stark contrast appears: the forest with hugged trees is lush, green, and full of wildlife, while the cut side is barren with stumps.',
    's1_focus_5': 'Chipko: Responsible Conservation',
    's1_step_5':
        'Observe the conclusion of the Chipko movement and understand its lasting impact.',
    's1_obs_5':
        'The Chipko movement, led by local women, showed that communities can prevent destruction, save animal habitats, and preserve vital natural resources.',
    's2_focus_1': 'Observe Ground Differences',
    's2_step_1':
        'Compare healthy forest vs. deforested hillsides. Look closely at the ground surface and root cross-sections.',
    's2_obs_1':
        'Left hill has dense trees, leaf litter & root network holding dark soil. Right hill is barren with exposed loose soil.',
    's2_focus_2': 'Make It Rain',
    's2_step_2':
        'DRAG the rain cloud from the top of the screen and POSITION it over both hills to make it rain simultaneously.',
    's2_obs_2': 'Volumetric rain falls evenly across both hillsides.',
    's2_focus_3': 'Observe Water Runoff',
    's2_step_3':
        'WATCH the water run down the hills. Check the stream colors at the bottom.',
    's2_obs_3':
        'Forest stream remains crystal clear as leaf litter absorbs impact; deforested hill runoff erodes gully channels and turns the stream thick muddy brown!',
    's2_focus_4': 'Forests as Natural Blanket',
    's2_step_4':
        'Observe the scientific conclusion of how forest ecosystems protect land and water quality.',
    's2_obs_4':
        'Roots hold the soil and fallen leaves protect it like a natural blanket, preventing soil erosion, water pollution, and loss of fertility.',
    // HTML `summary` (its bold heading and its text).
    's1_sum_title': 'The Hugging Trees Movement (Chipko)',
    's1_summary':
        'The Chipko movement, led by local women, showed that communities can prevent the destruction of their natural resources. By protecting the trees, you saved the homes of many animals and preserved a vital part of the ecosystem. This is an example of responsible conservation.',
    's2_sum_title': "The Forest's Soil Blanket",
    's2_summary':
        'As Ajji explained in the story, the roots of trees hold the soil, and the fallen leaves protect it. This experiment shows how forests act like a natural blanket, preventing precious soil from being washed away by rain. Without forests, soil erosion increases, which pollutes our water and makes the land less fertile.',
    // Teacher-board accordion (HTML `concept_exp`, `exploration`,
    // `concept_focus`, `action`, `observation`).
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Focus Area',
    'action': 'Task Action',
    'observation': 'Expected Outcome',
    // HTML success modal.
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You mastered the concepts of community forest preservation (Chipko Movement) and how forests act as a protective soil blanket against erosion!',
    'btn_conclude': 'Observe Conclusion',
    // Inventory panel.
    'controls': 'Controls',
    'item_villagers': 'Hug Trees ({c}/3)',
    'item_cut': 'Start Cutting',
    'item_rain': 'Start Rain',
    'stop_rain': 'Stop Rain',
    // Scene labels (text sprites).
    'lbl_deer': 'Spotted Deer (Forest Herbivore)',
    'lbl_monkey': 'Langur Monkey (Canopy Dweller)',
    'lbl_bird': 'Forest Bird (Nests in Trees)',
    'lbl_forest_hill': 'Left Hill: Healthy Forest (Roots grip soil)',
    'lbl_bare_hill': 'Right Hill: Deforested (Exposed loose soil)',
    'lbl_clear_stream': 'Clear Stream Water',
    'lbl_muddy_stream': 'Muddy Eroded Water',
    // HTML literal: `showToast` messages.
    'toast_animal': "Great observation! Now let's protect the trees (Step 2)",
    'toast_hugged': "All 3 trees hugged! Now tap 'Start Cutting' (Step 3)",
    'toast_loggers':
        'Loggers left! Observe the contrast: protected vs deforested forest (Step 4)',
    'toast_ground':
        'Observed healthy forest vs deforested ground! Now drag the rain cloud over the hills (Step 2)',
    'toast_runoff':
        'Observe Step 3: Left hill stream stays clear blue, right hill stream turns muddy brown from soil runoff!',
    'toast_roots':
        "Roots hold the soil like a blanket! Let's view the conclusion (Step 4)",
    // Added.
    'scene_s1':
        'A forest island with five tall trees, a spotted deer, a langur monkey on a trunk, a forest bird in a crown and the village leader with her staff',
    'scene_s2':
        'Two hillsides above two streams: on the left a forest with leaf litter and roots, on the right a deforested hill with stumps',
  },
  'hi': {
    'app_title': 'वन: पारिस्थितिकी तंत्र, संसाधन और संरक्षण',
    'app_subtitle': 'कक्षा 6 . प्रकृति का खजाना',
    'scen_1_opt': 'परिदृश्य 1: पेड़ों को गले लगाने का आंदोलन (चिपको)',
    'scen_2_opt': 'परिदृश्य 2: वन की मिट्टी का कंबल',
    's1_desc':
        'यह समझना कि वनों की कटाई वन्यजीवों को कैसे प्रभावित करती है और सामुदायिक प्रयास कैसे वनों की रक्षा कर सकते हैं।',
    's2_desc':
        'यह देखना कि वनों की जड़ें और पत्तियां मिट्टी के कटाव को कैसे रोकती हैं और प्राकृतिक कंबल का काम करती हैं।',
    's1_hud_1':
        'चरण 1: आप एक घने जंगल में हैं। दृश्य का अवलोकन करें। हिरण, बंदर और पक्षी पर टैप करके उनके आवास को देखें।',
    's1_hud_2':
        'चरण 2: लकड़हारे पेड़ काटने आए हैं। कम से कम तीन पेड़ों को बचाने के लिए स्थानीय महिलाओं (ग्रामीणों) को खींचकर पेड़ों से लिपटाएं।',
    's1_hud_3':
        "चरण 3: अब लकड़हारों की प्रतिक्रिया देखने के लिए 'कटाई शुरू करें' बटन पर टैप करें।",
    's1_hud_4':
        'चरण 4: लकड़हारे चले गए हैं। परिणाम देखें। सुरक्षित बचे हरे-भरे वनों और कटे हुए ठूंठों वाले वीरान भाग की तुलना करें।',
    's1_hud_5':
        'चरण 5: चिपको: जिम्मेदार संरक्षण। समझें कि स्थानीय महिलाओं के नेतृत्व में समाज ने कैसे पर्यावरण की रक्षा की।',
    's2_hud_1':
        'चरण 1: यहां दो पहाड़ियां हैं। बाईं पहाड़ी घना वन है और दाईं पहाड़ी कटी हुई है। दोनों की मिट्टी देखें।',
    's2_hud_2':
        'चरण 2: दोनों पहाड़ियों पर बारिश करने के लिए बारिश के बादल को खींचकर (या टैप करके) रखें।',
    's2_hud_3':
        'चरण 3: पहाड़ियों से बहते पानी को देखें। नीचे बहने वाली धाराओं के रंग का अवलोकन करें (साफ जल vs मटमैला जल)।',
    's2_hud_4':
        'चरण 4: वन प्राकृतिक कंबल के रूप में। समझें कि जड़ें मिट्टी को कैसे बांधती हैं और पत्तियां कैसे रक्षा करती हैं।',
    's1_focus_1': 'वन पारिस्थितिकी तंत्र का अवलोकन',
    's1_step_1':
        'आप एक घने जंगल में हैं। दृश्य का अवलोकन करें। हिरण, बंदर और पक्षी पर टैप करें।',
    's1_obs_1':
        'उपयोगकर्ता वन को एक जीवंत पारिस्थितिकी तंत्र और जानवरों के घर के रूप में देखता है।',
    's1_focus_2': 'पेड़ों की रक्षा (चिपको)',
    's1_step_2':
        'कम से कम तीन पेड़ों को बचाने के लिए महिलाओं को खींचकर पेड़ों पर रखें (या टैप करें)।',
    's1_obs_2':
        'स्थानीय महिलाएं पेड़ों के तनों से अपनी बाहें लपेटकर रक्षा कवच बना लेती हैं।',
    's1_focus_3': 'कटाई शुरू करें',
    's1_step_3':
        "अब लकड़हारों की प्रतिक्रिया देखने के लिए 'कटाई शुरू करें' बटन पर टैप करें।",
    's1_obs_3':
        'लकड़हारे लिपटे पेड़ों का सम्मान करते हैं (लाल X चिन्ह), लेकिन खुले पेड़ों को काट देते हैं जिससे जानवर भागते हैं।',
    's1_focus_4': 'परिणामों की तुलना',
    's1_step_4':
        'लकड़हारे चले गए हैं। परिणाम देखें। सुरक्षित बचे पेड़ों और कटे हुए ठूंठों का अंतर देखें।',
    's1_obs_4':
        'सुरक्षित पेड़ हरे-भरे हैं और वन्यजीव सुरक्षित हैं, जबकि कटा हुआ भाग वीरान हो गया है।',
    's1_focus_5': 'चिपको: जिम्मेदार संरक्षण',
    's1_step_5': 'सामुदायिक वन संरक्षण के महत्व और सारांश का अवलोकन करें।',
    's1_obs_5':
        'स्थानीय महिलाओं के नेतृत्व में चिपको आंदोलन ने दिखाया कि समाज प्राकृतिक संसाधनों के विनाश को रोक सकता है।',
    's2_focus_1': 'पहाड़ियों का अवलोकन',
    's2_step_1':
        'यहां दो पहाड़ियां हैं। बाईं पहाड़ी (घना वन) और दाईं पहाड़ी (कटी हुई) की सतह का अंतर देखें।',
    's2_obs_1':
        'वन वाली पहाड़ी पर जड़ों का जाल और पत्तियों की परत है; कटी पहाड़ी पर खुली मिट्टी है।',
    's2_focus_2': 'वर्षा का अनुकरण',
    's2_step_2':
        'दोनों पहाड़ियों पर एक साथ बारिश करने के लिए बारिश के बादल को खींचकर रखें।',
    's2_obs_2': 'दोनों पहाड़ियों पर समान रूप से वर्षा होने लगती है।',
    's2_focus_3': 'मिट्टी के कटाव की तुलना',
    's2_step_3':
        'पहाड़ियों से बहते पानी और नीचे की धाराओं के रंग का अवलोकन करें।',
    's2_obs_3':
        'वन वाली धारा बिल्कुल साफ रहती है; कटी पहाड़ी की धारा में मिट्टी बहने से पानी मटमैला और कीचड़ भरा हो जाता है!',
    's2_focus_4': 'वन प्राकृतिक कंबल के रूप में',
    's2_step_4': 'मिट्टी की सुरक्षा में वनों की भूमिका का सारांश।',
    's2_obs_4':
        'पेड़ों की जड़ें मिट्टी को मजबूती से जकड़े रखती हैं और गिरी हुई पत्तियां प्राकृतिक कंबल की तरह काम करती हैं।',
    's1_sum_title': 'पेड़ों को गले लगाने का आंदोलन (चिपको)',
    's1_summary':
        'स्थानीय महिलाओं के नेतृत्व में चिपको आंदोलन ने दिखाया कि समुदाय अपने प्राकृतिक संसाधनों के विनाश को रोक सकते हैं। पेड़ों की रक्षा करके, आपने कई जानवरों के घरों को बचाया और पारिस्थितिकी तंत्र के एक महत्वपूर्ण हिस्से को संरक्षित किया।',
    's2_sum_title': 'वन की मिट्टी का कंबल',
    's2_summary':
        'पेड़ों की जड़ें मिट्टी को मजबूती से जकड़े रखती हैं और गिरी हुई पत्तियां पानी को सोख लेती हैं। यह प्रयोग दिखाता है कि वन प्राकृतिक कंबल की तरह काम करते हैं और कीमती मिट्टी को बारिश के पानी में बहने से रोकते हैं।',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'मुख्य बिंदु',
    'action': 'कार्य निर्देश',
    'observation': 'अपेक्षित परिणाम',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने चिपको आंदोलन द्वारा सामुदायिक वन संरक्षण और मिट्टी के कटाव को रोकने में वनों की भूमिका को अच्छी तरह समझ लिया है!',
    'btn_conclude': 'निष्कर्ष देखें',
    'controls': 'नियंत्रण',
    'item_villagers': 'पेड़ से लिपटें ({c}/3)',
    'item_cut': 'कटाई शुरू करें',
    'item_rain': 'बारिश शुरू करें',
    'stop_rain': 'बारिश रोकें',
    'lbl_deer': 'चीतल हिरण (शाकाहारी)',
    'lbl_monkey': 'लंगूर बंदर (पेड़ पर रहने वाला)',
    'lbl_bird': 'वन पक्षी (घोंसला)',
    'lbl_forest_hill': 'बाईं पहाड़ी: घना वन (जड़ें मिट्टी को बांधती हैं)',
    'lbl_bare_hill': 'दाईं पहाड़ी: कटा हुआ वन (खुली मिट्टी)',
    'lbl_clear_stream': 'साफ जल की धारा',
    'lbl_muddy_stream': 'मटमैला और कीचड़ भरा जल',
    // Added: Hindi for the HTML literal toasts.
    'toast_animal': 'शानदार अवलोकन! अब पेड़ों की रक्षा करें (चरण 2)',
    'toast_hugged':
        "तीनों पेड़ों से लिपट गए! अब 'कटाई शुरू करें' पर टैप करें (चरण 3)",
    'toast_loggers':
        'लकड़हारे चले गए! अंतर देखें: सुरक्षित बनाम कटा हुआ वन (चरण 4)',
    'toast_ground':
        'घने वन और कटी हुई ज़मीन का अवलोकन हो गया! अब बारिश के बादल को पहाड़ियों पर खींचें (चरण 2)',
    'toast_runoff':
        'चरण 3 देखें: बाईं पहाड़ी की धारा साफ नीली रहती है, जबकि दाईं पहाड़ी की धारा बहती मिट्टी से मटमैली भूरी हो जाती है!',
    'toast_roots':
        'जड़ें मिट्टी को कंबल की तरह थामे रखती हैं! आइए निष्कर्ष देखें (चरण 4)',
    // Added.
    'scene_s1':
        'पांच ऊंचे पेड़ों वाला एक वन द्वीप, एक चीतल हिरण, तने पर एक लंगूर बंदर, एक पेड़ के शिखर में एक वन पक्षी और अपनी लाठी के साथ गांव की मुखिया',
    'scene_s2':
        'दो धाराओं के ऊपर दो पहाड़ियां: बाईं ओर पत्तियों की परत और जड़ों वाला वन, दाईं ओर ठूंठों वाली कटी हुई पहाड़ी',
  },
};

/// Number of scenarios and the steps of each (the HTML `steps` arrays).
const int _scenarioCount = 2;
const List<int> _stepCounts = [5, 4];

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.result,
  });

  final String focus;
  final String action;
  final String result;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCounts[index]; i++)
      _StepInfo(
        focus: t('s${n}_focus_$i'),
        action: t('s${n}_step_$i'),
        result: t('s${n}_obs_$i'),
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

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 7.5, 23) looking at `controls.target` (0, 1.8, 0).
const double _fovDegrees = 45;
const double _near = 0.1;
const _V _eye = _V(0, 7.5, 23);
const _V _target = _V(0, 1.8, 0);

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Chip padding as a share of the label size, and the gap (design px)
/// between two chips stacked to stay apart.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;
const double _chipGap = 3;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

/// The HTML particles move a fixed amount per animation frame (60 fps).
const double _frameRate = 60;

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

/// How often (s) the semantics nodes re-read where things are drawn and
/// the framing checks the cards (a card may have been dragged).
const double _layoutEvery = 0.25;

/// Both scene groups stand at `position.y = 2.0`.
const double _groupY = 2;

// ------------------------------------------------- scenario 1: the forest

/// The island `CylinderGeometry(14.5, 15.5, 1.6, 32)` at y -0.8 and its
/// lawn `CircleGeometry(14.3, 32)` at y 0.02.
const double _islandTopR = 14.5;
const double _islandBottomR = 15.5;
const double _islandH = 1.6;
const double _islandY = -0.8;
const double _lawnR = 14.3;
const double _lawnY = 0.02;

/// The framing keeps this much of the island round its centre in view; its
/// rim may be cropped, as the HTML camera crops it on most screens.
const double _islandFocusR = 10;

/// Where a tree stands on the island and its `buildNaturalTreeMesh` scale.
@immutable
class _TreeSpot {
  const _TreeSpot(this.x, this.z, this.scale);

  final double x;
  final double z;
  final double scale;
}

/// `treeGroup1`–`3` (hugged by the village women) and `unprotectedTree1`
/// / `2` (cut by the loggers: `rotation.z` → π/2 and -π/2 over 1300 ms,
/// `Bounce.Out`).
const List<_TreeSpot> _huggedTrees = [
  _TreeSpot(-5.4, -2.2, 1.25),
  _TreeSpot(0, -4.3, 1.35),
  _TreeSpot(-2.4, 3.2, 1.2),
];
const List<_TreeSpot> _openTrees = [
  _TreeSpot(6.2, -2.2, 1.3),
  _TreeSpot(5.3, 3.3, 1.2),
];
const List<double> _fallAngles = [math.pi / 2, -math.pi / 2];
const double _fallSeconds = 1.3;

/// `buildNaturalTreeMesh(1)`: the trunk `CylinderGeometry(0.48, 0.75,
/// 5.2)` at y 2.6 and three crowns `ConeGeometry(radius, height)` at y.
const double _trunkTopR = 0.48;
const double _trunkBottomR = 0.75;
const double _trunkH = 5.2;
const List<(double, double, double)> _crowns = [
  (2.4, 2.8, 5.0),
  (1.9, 2.5, 6.2),
  (1.3, 2.0, 7.4),
];

/// The village women (`buildWomanMesh`, scale 1.15) stand at (0, 0, 0.85)
/// of their tree, turned to the trunk (`rotation.y = π`). Each pops in
/// from scale 0.1 over 650 ms (`Back.Out`); step 3 opens 800 ms after the
/// third.
const double _womanScale = 1.15;
const double _hugOffset = 0.85;
const double _popFrom = 0.1;
const double _popSeconds = 0.65;
const double _huggedDelay = 0.8;

/// The village leader (`buildLeaderMesh`) in the clearing.
const _V _leaderPos = _V(-3.2, 0, 1.4);
const double _leaderTurn = 0.35;

/// The loggers (`buildLoggerMesh`, scale 1.18) facing the forest
/// (`rotation.y = -π/2`); their red X badges float at y 3.4, 1.1 wide.
const List<_V> _loggerPos = [_V(7.0, 0, -1.8), _V(6.0, 0, 3.4)];
const double _loggerTurn = -math.pi / 2;
const double _loggerScale = 1.18;
const double _badgeY = 3.4;
const double _badgeSize = 1.1;

/// `startCuttingAction()`: the X badges after 800 ms, the cut 1200 ms
/// later (the animals flee over 1600 ms), step 4 when they are gone and
/// the summary 3800 ms after that.
const double _badgeDelay = 0.8;
const double _cutDelay = 1.2;
const double _fleeSeconds = 1.6;
const double _summaryDelay = 3.8;

/// Chainsaw arms while cutting: `rotation.x = sin(Date.now() * 0.016 +
/// i) * 0.55 - 0.15`.
const double _sawRate = 16;
const double _sawSwing = 0.55;
const double _sawTilt = -0.15;

/// The animals (`buildDeerMesh`, `buildMonkeyMesh`, `buildBirdMesh`):
/// where they stand, their scales and the heights of their labels. The
/// deer flees to (-16, -8) and the bird to (14, 16) (`Quadratic.Out`).
const _V _deerHome = _V(-6.5, 0.1, 2.5);
const _V _deerFlee = _V(-16, 0.1, -8);
const _V _monkeyHome = _V(-0.5, 4.6, -3.5);
const _V _birdHome = _V(-4.5, 5.6, -2.2);
const _V _birdFlee = _V(14, 16, -2.2);
const List<double> _animalScale = [1.2, 1.25, 1.4];
const List<double> _animalLabelY = [3.4, 2.2, 1.6];
const List<String> _animalKeys = ['lbl_deer', 'lbl_monkey', 'lbl_bird'];

/// A tapped animal hops 0.65 up and back (280 ms, `.yoyo(true)
/// .repeat(1)`); step 2 opens 500 ms after the first tap.
const double _hopHeight = 0.65;
const double _hopSeconds = 0.28;
const double _stepTwoDelay = 0.5;

/// Pick boxes of the deer, monkey and bird meshes (local, unscaled).
const List<(_V, _V)> _animalBoxes = [
  (_V(-1.15, 0, -0.55), _V(1.8, 3.2, 0.55)),
  (_V(-1.2, -1.0, -0.6), _V(1.0, 1.45, 0.6)),
  (_V(-1.15, -0.5, -0.65), _V(1.3, 1.0, 0.65)),
];

/// The HTML bird sits inside the crown of the tree it nests in, behind the
/// crown of the tree in front (the raycaster still finds it there); it is
/// drawn in front of those crowns so it can be seen and tapped.
const double _birdLift = 9;

// ------------------------------------------------ scenario 2: the hillsides

/// The hills `ConeGeometry(7.2, 6.2, 24)` at x ∓6.6 and the leaf litter
/// `ConeGeometry(7.25, 1.8)` on the forest hill.
const double _hillX = 6.6;
const double _hillR = 7.2;
const double _hillH = 6.2;
const double _leafR = 7.25;
const double _leafH = 1.8;

/// Streams `BoxGeometry(13.5, 0.25, 2.8)` at (∓6.6, 0.12, 6.2).
const _V _streamSize = _V(13.5, 0.25, 2.8);
const double _streamY = 0.12;
const double _streamZ = 6.2;

/// `buildCloudMesh()` at (0, 10.5, 0): a centre puff (r 2.8), ten storm
/// puffs (r 2.2 / 2.7; the last two in the storm grey) and two dark bases.
const _V _cloudAt = _V(0, 10.5, 0);
const double _cloudCoreR = 2.8;
const List<_V> _puffs = [
  _V(-6.6, 0.2, 0),
  _V(-4.5, 0.5, 1.2),
  _V(-4.5, 0.5, -1.2),
  _V(-2.5, -0.2, 0),
  _V(2.5, -0.2, 0),
  _V(4.5, 0.5, 1.2),
  _V(4.5, 0.5, -1.2),
  _V(6.6, 0.2, 0),
  _V(-6.6, -0.6, 0),
  _V(6.6, -0.6, 0),
];

/// How many of each thing `buildS2Scene()` makes.
const int _hillTreeCount = 9;
const int _stumpCount = 7;
const int _rootCount = 6;
const int _gullyCount = 6;
const int _grainCount = 45;
const int _mudCount = 24;
const int _dropCount = 350;
const int _rippleCount = 60;

/// Trees on the forest hill (`buildNaturalTreeMesh(0.55)`).
const double _hillTreeScale = 0.55;

/// Gullies `BoxGeometry(0.5, 3.8, 0.15)` 2.6 from the bare hill's axis;
/// they grow (`scale.y` 0.05 → 1) over 1400 + i x 200 ms (`Quadratic
/// .Out`).
const double _gullyR = 2.6;
const double _gullyW = 0.5;
const double _gullyL = 3.8;
const double _gullyFrom = 0.05;
const double _gullySeconds = 1.4;
const double _gullyStagger = 0.2;

/// `triggerRainCloud()`: the right stream turns muddy 1600 ms after the
/// rain starts, the summary follows 3600 ms later.
const double _runoffDelay = 1.6;
const double _rainSummaryDelay = 3.6;

/// Lightning: a 0.8% chance each frame, an 80 ms flash.
const double _flashChance = 0.008;
const double _flashSeconds = 0.08;

// ---------------------------------------------------------------- confetti

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
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

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

  /// A local direction turned (not scaled) into world space: for normals.
  _V normal(_V v) => (x.unit * v.x + y.unit * v.y + z.unit * v.z).unit;

  /// World size of one local unit (the mean of the axes' lengths).
  double get size => (x.length + y.length + z.length) / 3;

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

  /// A child with one uniform scale [k].
  _Xf scaled(_V pos, double k, {double rx = 0, double ry = 0, double rz = 0}) =>
      child(pos, rx: rx, ry: ry, rz: rz, sx: k, sy: k, sz: k);
}

/// The scene groups (`s1Group`, `s2Group`) at y 2.
const _Xf _root = _Xf.at(_V(0, _groupY, 0));

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// HTML `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => t * (2 - t);

/// HTML `TWEEN.Easing.Back.Out`.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// HTML `TWEEN.Easing.Bounce.Out`.
double _bounceOut(double t) {
  if (t < 1 / 2.75) return 7.5625 * t * t;
  if (t < 2 / 2.75) {
    final k = t - 1.5 / 2.75;
    return 7.5625 * k * k + 0.75;
  }
  if (t < 2.5 / 2.75) {
    final k = t - 2.25 / 2.75;
    return 7.5625 * k * k + 0.9375;
  }
  final k = t - 2.625 / 2.75;
  return 7.5625 * k * k + 0.984375;
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
    final f = (_target - _eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(f, r, r.cross(f), framing.center, _focal * framing.zoom);
  }

  const _Cam._(this.f, this.r, this.u, this.center, this.scale);

  _V get eye => _eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  double depth(_V w) => (w - _eye).dot(f);

  /// The design point of [w] (points behind the camera are clamped to the
  /// near plane; callers skip them).
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

  /// The screen offset of a small step [a] taken at [w] (the projection's
  /// derivative): how a mesh's axes look on screen.
  Offset dp(_V w, _V a) {
    final d = w - _eye;
    final z = math.max(_near, d.dot(f));
    final az = a.dot(f);
    return Offset(
      scale * (a.dot(r) * z - d.dot(r) * az) / (z * z),
      -scale * (a.dot(u) * z - d.dot(u) * az) / (z * z),
    );
  }

  /// Screen bounds of the box [min]–[max] in the frame [xf].
  Rect frameBox(_Xf xf, _V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        xf(
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

  /// Is the tween still running at [time]?
  bool running(double time) =>
      _seconds > 0 && time - _start < _seconds * _legs && time >= _start;

  void set(double value) {
    _from = value;
    _to = value;
    _seconds = 0;
    _legs = 1;
  }

  /// Tweens from the current value to [to] over [seconds]; [legs] > 1
  /// plays it back and forth (HTML `.yoyo(true).repeat(legs - 1)`).
  void animate(
    double time,
    double to,
    double seconds, {
    int legs = 1,
    double Function(double) ease = _linear,
  }) {
    _from = at(time);
    _to = to;
    _start = time;
    _seconds = seconds;
    _legs = legs;
    _ease = ease;
  }
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

/// A rain streak (`CylinderGeometry(0.08, 0.04, 2.2)`): it falls 0.55–1.0
/// units a frame and starts again at y 15 over a new x.
class _Drop {
  _Drop(this.x, this.y, this.z, this.speed, {required this.pale});

  double x;
  double y;
  final double z;
  final double speed;

  /// `0xbae6fd` (odd streaks) instead of `0x38bdf8`.
  final bool pale;
}

/// A splash ring (`RingGeometry(0.08, 0.38)`) where the rain strikes: its
/// place, its phase (0–π: the ring grows from 0.3x to 1.9x and fades) and
/// how fast it runs.
class _Ripple {
  _Ripple(this.at, this.phase, this.speed, this.hill, this.angle);

  final _V at;
  double phase;
  final double speed;

  /// -1 on a stream, 0 the forest hill, 1 the bare hill.
  final int hill;

  /// Where it lies round its hill's axis.
  final double angle;
}

/// A soil grain (`SphereGeometry(0.18)`) washing down the bare hill.
class _Grain {
  double angle = 0;
  double y = 0;
  double drift = 0;
  double vx = 0;
  double vy = 0;

  /// HTML respawn: a new place 0.8–4.3 from the axis, at y 2.8, with new
  /// speeds.
  void respawn(math.Random rnd) {
    angle = rnd.nextDouble() * math.pi * 2;
    y = 2.8;
    drift = 0;
    vx = (rnd.nextDouble() - 0.5) * 0.04;
    vy = rnd.nextDouble() * 0.06 + 0.04;
  }
}

/// A thing on a hillside: its angle round the hill's axis and its distance
/// from it (the HTML `Math.random()` layout, made once).
typedef _Spot = (double angle, double r);

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    final rnd = _rnd;
    double next() => rnd.nextDouble();
    for (var i = 0; i < _hillTreeCount; i++) {
      hillTrees.add((next() * math.pi * 2, next() * 4.2 + 1.1));
    }
    for (var i = 0; i < _rootCount; i++) {
      roots.add(((next() - 0.5) * 5, 5.2 + (next() - 0.5) * 1.2, next() - 0.5));
    }
    for (var i = 0; i < _stumpCount; i++) {
      stumps.add((next() * math.pi * 2, next() * 4.2 + 1.1));
    }
    for (var i = 0; i < _grainCount; i++) {
      grains.add(_Grain()..respawn(rnd));
    }
    for (var i = 0; i < _mudCount; i++) {
      mud.add((_hillX + (next() - 0.5) * 11, _streamZ + (next() - 0.5) * 1.8));
    }
    for (var i = 0; i < _dropCount; i++) {
      drops.add(
        _Drop(
          (next() - 0.5) * 24,
          next() * 15 + 1.5,
          (next() - 0.5) * 12,
          next() * 0.45 + 0.55,
          pale: i.isOdd,
        ),
      );
    }
    for (var i = 0; i < _rippleCount; i++) {
      final hill = i < 25 ? 0 : (i < 50 ? 1 : -1);
      final _V at;
      var angle = 0.0;
      if (hill < 0) {
        at = _V((next() - 0.5) * 22, 0.28, _streamZ + (next() - 0.5) * 2);
      } else {
        // On the slope (the HTML rings hang inside the cones, out of view).
        angle = next() * math.pi * 2;
        final r = next() * 5.0;
        final cx = hill == 0 ? -_hillX : _hillX;
        at = _V(
          cx + math.cos(angle) * r,
          slopeY(r) + 0.02,
          math.sin(angle) * r,
        );
      }
      ripples.add(
        _Ripple(at, next() * math.pi * 2, next() * 0.08 + 0.05, hill, angle),
      );
    }
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          -math.pi / 2 + _confettiSpread * (0.5 - next()),
          (_confettiStart * 0.5 + next() * _confettiStart) * _confettiSpeed,
          _Colors.confetti[i % _Colors.confetti.length],
          (next() - 0.5) * 0.4,
        ),
      );
    }
  }

  final math.Random _rnd = math.Random(11);

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  // ------------------------------------------------ HTML `State.s1`

  /// `animalsClicked`, and step 2 already on its way.
  int animalsClicked = 0;
  bool stepTwoQueued = false;

  /// `treesHugged`, `isCutStarted`, `cutAnimationDone`, and the loggers'
  /// X badges shown.
  int treesHugged = 0;
  bool cutStarted = false;
  bool cutDone = false;
  bool badges = false;

  /// The women's scales, the unprotected trees' `rotation.z`, the deer's
  /// and the bird's flight and the animals' hops (deer, monkey, bird).
  final List<_Track> womanScale = [_Track(0), _Track(0), _Track(0)];
  final List<_Track> fall = [_Track(0), _Track(0)];
  final _Track deerX = _Track(_deerHome.x);
  final _Track deerZ = _Track(_deerHome.z);
  final _Track birdX = _Track(_birdHome.x);
  final _Track birdY = _Track(_birdHome.y);
  final List<_Track> hop = [_Track(0), _Track(0), _Track(0)];

  /// The loggers' arms (`armsGroup.rotation.x`).
  final List<double> arms = [0, 0];

  // ------------------------------------------------ HTML `State.s2`

  /// `isRainActive`, `rainAnimationDone`; the right stream is muddy, the
  /// cloud, the gullies and the mud bubbles have been shown.
  bool rainActive = false;
  bool rainDone = false;
  bool muddy = false;
  bool cloudShown = false;
  bool gulliesShown = false;
  bool mudShown = false;
  final List<_Track> gully = [
    for (var i = 0; i < _gullyCount; i++) _Track(0.01),
  ];

  /// The mud bubbles bob only while it rains: their own clock.
  double mudTime = 0;

  /// Scene time a lightning flash ends.
  double flashUntil = -1;

  /// The made-once layout of the hillsides and the particles.
  final List<_Spot> hillTrees = [];
  final List<(double, double, double)> roots = [];
  final List<_Spot> stumps = [];
  final List<_Grain> grains = [];
  final List<(double, double)> mud = [];
  final List<_Drop> drops = [];
  final List<_Ripple> ripples = [];

  // ------------------------------------------------------------- shared

  /// The tool being dragged from the Controls card (added: the next tree
  /// to hug glows while a woman is dragged).
  _Tool? dragging;

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

  bool get forest => scenario == 0;

  /// HTML `resetScenarioState()` for scenario [index].
  void load(int index) {
    scenario = index;
    step = 1;
    animalsClicked = 0;
    stepTwoQueued = false;
    treesHugged = 0;
    cutStarted = false;
    cutDone = false;
    badges = false;
    for (final w in womanScale) {
      w.set(0);
    }
    for (final f in fall) {
      f.set(0);
    }
    deerX.set(_deerHome.x);
    deerZ.set(_deerHome.z);
    birdX.set(_birdHome.x);
    birdY.set(_birdHome.y);
    for (final h in hop) {
      h.set(0);
    }
    arms
      ..[0] = 0
      ..[1] = 0;
    rainActive = false;
    rainDone = false;
    muddy = false;
    cloudShown = false;
    gulliesShown = false;
    mudShown = false;
    for (final g in gully) {
      g.set(0.01);
    }
    mudTime = 0;
    flashUntil = -1;
    dragging = null;
    confettiAt = -1;
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

  /// HTML `animate()`: the chainsaw arms, the rain, the ripples, the
  /// washing soil, the lightning; then the framing.
  void advance(double dt) {
    if (cutStarted && !cutDone) {
      for (var i = 0; i < arms.length; i++) {
        arms[i] = math.sin(time * _sawRate + i) * _sawSwing + _sawTilt;
      }
    }
    if (!forest && rainActive) {
      final frames = dt * _frameRate;
      for (final d in drops) {
        d.y -= d.speed * frames;
        if (d.y < 0.2) {
          d.y = 15;
          d.x = (_rnd.nextDouble() - 0.5) * 24;
        }
      }
      for (final r in ripples) {
        r.phase += r.speed * frames;
        if (r.phase > math.pi) r.phase = 0;
      }
      for (final g in grains) {
        g
          ..drift += g.vx * frames
          ..y -= g.vy * frames;
        if (g.y < 0.3) g.respawn(_rnd);
      }
      if (_rnd.nextDouble() <
          1 - math.pow(1 - _flashChance, frames).toDouble()) {
        flashUntil = time + _flashSeconds;
      }
      if (muddy) mudTime += dt;
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

  /// The thunderstorm light and sky (`setStormAtmosphere(true)`) and a
  /// lightning flash.
  bool get storm => !forest && rainActive;
  bool get flashing => storm && time < flashUntil;

  // ------------------------------------------------------------ geometry

  /// Height of a hill's slope [r] from its axis (local, 0 at the foot).
  static double slopeY(double r) => _hillH * (1 - r / _hillR);

  /// Distance from the axis of the slope at height [y].
  static double slopeR(double y) => _hillR * (1 - y / _hillH);

  /// Height of the hills' surface over (x, z) (local; 0 off the hills).
  static double hillTop(double x, double z) {
    var h = 0.0;
    for (final cx in const [-_hillX, _hillX]) {
      final dx = x - cx;
      final r = math.sqrt(dx * dx + z * z);
      if (r < _hillR) h = math.max(h, slopeY(r));
    }
    return h;
  }

  /// Is the slope [point] at [angle] round its hill's axis turned to the
  /// camera? (Its outward normal ∝ (H cos a, R, H sin a).)
  static bool facesCamera(double angle, _V point) {
    final n = _V(_hillH * math.cos(angle), _hillR, _hillH * math.sin(angle));
    return n.dot(_eye - point) > 0;
  }

  /// A thing [r] from the axis of the hill at [cx], at [angle], standing
  /// on the slope (world).
  static _V onSlope(double cx, double angle, double r, {double lift = 0}) =>
      _root(cx + math.cos(angle) * r, slopeY(r) + lift, math.sin(angle) * r);

  /// The animal [i] (deer, monkey, bird) group frame, with its hop and its
  /// flight.
  _Xf animal(int i) {
    final h = hop[i].at(time);
    final pos = switch (i) {
      0 => _V(deerX.at(time), _deerHome.y + h, deerZ.at(time)),
      1 => _V(_monkeyHome.x, _monkeyHome.y + h, _monkeyHome.z),
      _ => _V(birdX.at(time), birdY.at(time) + h, _birdHome.z),
    };
    return _root.scaled(pos, _animalScale[i]);
  }

  Rect animalRect(int i, _Cam cam) {
    final (min, max) = _animalBoxes[i];
    return cam.frameBox(animal(i), min, max);
  }

  /// The animal at [p] (HTML raycast on the deer, monkey and bird): its
  /// picture or, on a small screen, within a finger's reach of it; the
  /// nearest one wins.
  int? animalAt(Offset p, double touch) {
    final cam = camera();
    int? best;
    var bestD = double.infinity;
    for (var i = 0; i < 3; i++) {
      final r = animalRect(i, cam);
      final d = (p - r.center).distance;
      if (r.inflate(touch).contains(p) && d < bestD) {
        best = i;
        bestD = d;
      }
    }
    return best;
  }

  /// A hugged tree's group frame.
  _Xf huggedTree(int i) {
    final t = _huggedTrees[i];
    return _root.child(_V(t.x, 0, t.z));
  }

  /// An unprotected tree's group frame, falling once cut.
  _Xf openTree(int i) {
    final t = _openTrees[i];
    return _root.child(_V(t.x, 0, t.z), rz: fall[i].at(time));
  }

  /// The screen box of a hill (cone) and a stream.
  Rect hillRect(int side, _Cam cam) {
    final cx = side == 0 ? -_hillX : _hillX;
    return cam.frameBox(
      _root,
      _V(cx - _hillR, 0, -_hillR),
      _V(cx + _hillR, _hillH, _hillR),
    );
  }

  Rect streamRect(int side, _Cam cam) {
    final cx = side == 0 ? -_hillX : _hillX;
    final h = _streamSize * 0.5;
    return cam.frameBox(
      _root,
      _V(cx - h.x, _streamY - h.y, _streamZ - h.z),
      _V(cx + h.x, _streamY + h.y, _streamZ + h.z),
    );
  }
}

/// The items of the HTML "Controls" inventory.
enum _Tool { villagers, cut, cloud }

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

class _ForestsLabState
    extends State<Ch11A4ForestsEcosystemsResourcesAndConservationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped a few times a second: the semantics nodes re-read where things
  /// are drawn.
  final ValueNotifier<int> _layout = ValueNotifier(0);

  /// Where the dragged item's ghost is (canvas coordinates), or null (HTML
  /// `#drag-ghost`).
  final ValueNotifier<Offset?> _ghost = ValueNotifier(null);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards and to place the drag ghost.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch11-a4-canvas');

  /// The Controls card, kept clear by the framing.
  final GlobalKey _panelKey = GlobalKey(debugLabel: 'ch11-a4-controls');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _missionRect;

  /// Scene time of the last semantics refresh, and the cards' places then
  /// (a card the learner drags re-fits the scene).
  double _lastLayout = 0;
  Rect? _lastPanel;
  Offset? _lastMission;

  /// The last toast's string key, and the language the lab was last built
  /// in (a switch re-translates the visible toast).
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  /// The Controls item being dragged and where the finger is (global).
  _Tool? _dragTool;
  Offset _dragGlobal = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// The current step, within the scenario's steps.
  int get _step => _scene.step.clamp(1, _stepCounts[_scene.scenario]);

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
    if (now - _lastLayout >= _layoutEvery) {
      _lastLayout = now;
      _layout.value++;
      if (_cardsMoved()) _scheduleFraming();
    }
    _frame.value = now;
  }

  /// Did the Controls card or the floating mission card move (dragged by
  /// the learner) since the last check?
  bool _cardsMoved() {
    final panel = _panelKey.currentContext?.findRenderObject();
    final rect = panel is RenderBox && panel.hasSize && panel.attached
        ? panel.localToGlobal(Offset.zero) & panel.size
        : null;
    final mission = _lab.cardOffsets['mission'];
    final moved = rect != _lastPanel || mission != _lastMission;
    _lastPanel = rect;
    _lastMission = mission;
    return moved;
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

  /// Fits the forest island (trees, animals, people) or the two hillsides
  /// (streams and labels) into the part of the canvas no card covers: the
  /// tool column, the HUD (sidebar open), the Controls card and the
  /// floating mission card (sidebar collapsed).
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
    final panel = _panelKey.currentContext?.findRenderObject();
    if (panel is RenderBox && panel.hasSize && panel.attached) {
      hard.add((panel.localToGlobal(Offset.zero) - origin) & panel.size);
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

  /// What the learner must see (HTML camera, zoom 1): Scenario 1 the whole
  /// island with the trees' crowns, the animals with their labels, the
  /// leader and the loggers; Scenario 2 both hills, the middle of the
  /// streams, the cloud's centre and the four labels.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void point(_V w) => items.add((cam.p(w), Rect.zero));
    void ring(_V c, double r, int n) {
      for (var i = 0; i < n; i++) {
        final a = 2 * math.pi * i / n;
        point(c + _V(r * math.cos(a), 0, r * math.sin(a)));
      }
    }

    void box(_Xf xf, _V min, _V max) {
      for (var i = 0; i < 8; i++) {
        point(
          xf(
            (i & 1) != 0 ? max.x : min.x,
            (i & 2) != 0 ? max.y : min.y,
            (i & 4) != 0 ? max.z : min.z,
          ),
        );
      }
    }

    void chip(_V at, String text) {
      final size = _cache.chipSize(text);
      items.add((
        cam.p(at),
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        ),
      ));
    }

    if (_scene.forest) {
      ring(_root(0, _lawnY, 0), _islandFocusR, 16);
      for (final t in [..._huggedTrees, ..._openTrees]) {
        final k = t.scale;
        final tree = _root.child(_V(t.x, 0, t.z));
        point(tree(0, 8.4 * k, 0));
        ring(tree(0, 3.6 * k, 0), 2.4 * k, 8);
      }
      for (var i = 0; i < 3; i++) {
        final home = switch (i) {
          0 => _deerHome,
          1 => _monkeyHome,
          _ => _birdHome,
        };
        final frame = _root.scaled(home, _animalScale[i]);
        final (min, max) = _animalBoxes[i];
        box(frame, min, max);
        chip(frame(0, _animalLabelY[i], 0), _t(_animalKeys[i]));
      }
      box(
        _root.child(_leaderPos),
        const _V(-0.7, 0, -0.7),
        const _V(0.7, 3.1, 0.7),
      );
      for (final at in _loggerPos) {
        box(
          _root.child(at),
          const _V(-0.7, 0, -0.7),
          const _V(0.7, (_badgeY + _badgeSize / 2) * _loggerScale, 0.7),
        );
      }
    } else {
      for (final cx in const [-_hillX, _hillX]) {
        ring(_root(cx, 0, 0), _hillR, 16);
        point(_root(cx, _hillH, 0));
        box(
          _root,
          _V(cx - 3, _streamY - 0.125, _streamZ - 1.4),
          _V(cx + 3, _streamY + 0.125, _streamZ + 1.4),
        );
      }
      point(_root.at(_cloudAt));
      chip(_root(-_hillX, 7.6, 0), _t('lbl_forest_hill'));
      chip(_root(_hillX, 7.6, 0), _t('lbl_bare_hill'));
      chip(_root(-_hillX, 1.3, _streamZ), _t('lbl_clear_stream'));
      chip(_root(_hillX, 1.3, _streamZ), _t('lbl_muddy_stream'));
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState()`: clears the tweens
  /// and timers and puts the forest or the hillsides back.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _endDrag();
    setState(() {
      _scene.load(index);
      _missionRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
    _layout.value++;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `showToast(msg)` (no tone of its own).
  void _toast(String key) {
    _toastKey = key;
    _lab.showToast(_t(key), sound: false);
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

  // ---------------------------------------------------------- scenario 1

  /// HTML `onCanvasClick` on an animal at step 1: it hops, and 500 ms after
  /// the first one step 2 opens ("Great observation!").
  void _tapAnimal(int i) {
    final s = _scene;
    if (!s.forest || s.step != 1) return;
    _Sound.success.play();
    s.hop[i].animate(s.time, _hopHeight, _hopSeconds, legs: 2);
    s.animalsClicked++;
    if (!s.stepTwoQueued) {
      s.stepTwoQueued = true;
      s.cue(s.time + _stepTwoDelay, () {
        if (s.step <= 2) s.step = 2;
        _toast('toast_animal');
        _refresh();
      });
    }
    _refresh();
  }

  /// HTML `deployVillagers()`: the next village woman pops up hugging her
  /// tree; after the third, 'Start Cutting' unlocks and step 3 opens.
  void _deployVillager() {
    final s = _scene;
    if (!s.forest) return;
    _Sound.click.play();
    if (s.treesHugged >= 3) return;
    if (s.step == 1) s.step = 2;
    final i = s.treesHugged++;
    s.womanScale[i]
      ..set(_popFrom)
      ..animate(s.time, _womanScale, _popSeconds, ease: _backOut);
    if (s.treesHugged >= 3 && s.step <= 2) {
      s.cue(s.time + _huggedDelay, () {
        s.step = 3;
        _toast('toast_hugged');
        _refresh();
      });
    }
    _refresh();
  }

  /// HTML `startCuttingAction()`: the loggers come with their chainsaws;
  /// red X badges over them at the hugged trees, then the two unprotected
  /// trees fall and the deer and the bird flee; step 4, and the summary
  /// 3.8 s later.
  void _startCutting() {
    final s = _scene;
    if (!s.forest || s.treesHugged < 3 || s.cutStarted) return;
    s.cutStarted = true;
    if (s.step <= 2) s.step = 3;
    _Sound.cut.play();
    s.cue(s.time + _badgeDelay, () {
      s.badges = true;
      s.cue(s.time + _cutDelay, () {
        final t = s.time;
        _Sound.cut.play();
        for (var i = 0; i < 2; i++) {
          s.fall[i].animate(t, _fallAngles[i], _fallSeconds, ease: _bounceOut);
        }
        s.deerX.animate(t, _deerFlee.x, _fleeSeconds, ease: _quadOut);
        s.deerZ.animate(t, _deerFlee.z, _fleeSeconds, ease: _quadOut);
        s.birdX.animate(t, _birdFlee.x, _fleeSeconds, ease: _quadOut);
        s.birdY.animate(t, _birdFlee.y, _fleeSeconds, ease: _quadOut);
        s.cue(t + _fleeSeconds, () {
          s
            ..cutDone = true
            ..step = 4;
          _toast('toast_loggers');
          s.cue(s.time + _summaryDelay, () {
            if (s.forest && s.step == 4) {
              s.step = 5;
              _conclude();
            }
          });
          _refresh();
        });
        _refresh();
      });
      _refresh();
    });
    _refresh();
  }

  // ---------------------------------------------------------- scenario 2

  /// HTML `onCanvasClick` in Scenario 2: step 1 observes the hills, step 2
  /// starts the rain, step 3 goes to the conclusion.
  void _tapHills() {
    final s = _scene;
    if (s.forest) return;
    switch (s.step) {
      case 1:
        _Sound.success.play();
        _toast('toast_ground');
        s.step = 2;
      case 2:
        _triggerRain();
      case 3:
        _toast('toast_roots');
        s.step = 4;
        _conclude();
    }
    _refresh();
  }

  /// HTML `activateS2RainAndErosion()`: the storm, the cloud, the rain and
  /// its ripples, the gullies (growing, or at once) and the washing soil.
  void _startStorm({required bool erosionNow}) {
    final s = _scene;
    s
      ..rainActive = true
      ..cloudShown = true
      ..gulliesShown = true;
    for (var i = 0; i < _gullyCount; i++) {
      if (erosionNow) {
        s.gully[i].set(1);
      } else {
        s.gully[i]
          ..set(_gullyFrom)
          ..animate(
            s.time,
            1,
            _gullySeconds + i * _gullyStagger,
            ease: _quadOut,
          );
      }
    }
    if (erosionNow) {
      s
        ..muddy = true
        ..mudShown = true;
    }
  }

  /// HTML `triggerRainCloud()`: starts the rain (step 3; 1.6 s later the
  /// right stream turns muddy, and 3.6 s after that the summary opens), or
  /// stops it once it has done its work.
  void _triggerRain() {
    final s = _scene;
    if (s.forest) return;
    _Sound.click.play();
    if (!s.rainActive || s.step <= 2) {
      _startStorm(erosionNow: false);
      if (s.step <= 2) s.step = 3;
      s.cue(s.time + _runoffDelay, () {
        if (s.forest || !s.rainActive) return;
        s
          ..muddy = true
          ..mudShown = true
          ..rainDone = true;
        _toast('toast_runoff');
        s.cue(s.time + _rainSummaryDelay, () {
          if (!s.forest && s.step == 3) {
            s.step = 4;
            _conclude();
          }
        });
        _refresh();
      });
    } else {
      s.rainActive = false;
    }
    _refresh();
  }

  // ------------------------------------------------------------- summary

  /// HTML `triggerConclusion()`: the summary popup (scenario title, the
  /// bold heading and text, the "Scenario Complete" banner) with confetti.
  /// Once both scenarios are done it also shows the HTML success modal's
  /// "Mastery Achieved!".
  void _conclude() {
    final s = _scene;
    s.confettiAt = s.time;
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('scen_${sc + 1}_opt'),
      heading: () => _t('s${sc + 1}_sum_title'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _SummaryExtra(
          palette: _lab.palette,
          scale: context.labScale,
          banner: _lab.t('msg_scenario_complete'),
          mastery: _lab.completedScenarios.length >= _scenarioCount
              ? (_t('all_complete'), _t('all_complete_desc'))
              : null,
        ),
      ),
    );
    _refresh();
  }

  /// 'Observe Conclusion' (HTML `btn_conclude`): reopens the summary at the
  /// last step.
  LabAction _concludeAction({bool highlight = false}) => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.emerald600,
    foreground: _Colors.white,
    highlight: highlight,
    silent: true,
    onTap: _conclude,
  );

  bool get _atLastStep => _scene.step >= _stepCounts[_scene.scenario];

  List<LabAction> _actions() =>
      _atLastStep ? [_concludeAction()] : const <LabAction>[];

  // ------------------------------------------------------- controls card

  /// HTML `#inventory-panel`: Scenario 1 'Hug Trees (n/3)' (drag or tap)
  /// and 'Start Cutting' (tap, locked until three trees are hugged);
  /// Scenario 2 the rain cloud 'Start Rain' / 'Stop Rain' (drag or tap).
  List<_ControlItem> _controlItems() {
    final s = _scene;
    if (s.forest) {
      return [
        _ControlItem(
          tool: _Tool.villagers,
          label: labFormat(_t('item_villagers'), {'c': s.treesHugged}),
          used: s.treesHugged >= 3,
          draggable: true,
        ),
        _ControlItem(
          tool: _Tool.cut,
          label: _t('item_cut'),
          used: s.treesHugged < 3 || s.cutStarted,
          draggable: false,
        ),
      ];
    }
    return [
      _ControlItem(
        tool: _Tool.cloud,
        label: _t(s.rainActive ? 'stop_rain' : 'item_rain'),
        used: false,
        draggable: true,
      ),
    ];
  }

  /// HTML item `onclick`.
  void _useTool(_Tool tool) {
    if (!_lab.isLabActive) return;
    switch (tool) {
      case _Tool.villagers:
        _deployVillager();
      case _Tool.cut:
        _startCutting();
      case _Tool.cloud:
        _triggerRain();
    }
  }

  /// HTML `startDrag()`: a ghost of the item follows the finger.
  void _dragStart(_Tool tool, Offset global) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    if (tool == _Tool.villagers && (!s.forest || s.treesHugged >= 3)) return;
    if (tool == _Tool.cloud && s.forest) return;
    _dragTool = tool;
    s.dragging = tool;
    _moveGhost(global);
  }

  void _dragMove(Offset global) {
    if (_dragTool == null) return;
    _moveGhost(global);
  }

  void _moveGhost(Offset global) {
    _dragGlobal = global;
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    _ghost.value = box.globalToLocal(global);
  }

  /// HTML `onMouseUp`: let go over the scene, the item is used (a woman
  /// goes to the next tree, the rain starts).
  void _dragEnd() {
    final tool = _dragTool;
    _endDrag();
    if (tool != null && _dropsOnScene(_dragGlobal)) _useTool(tool);
  }

  void _endDrag() {
    _dragTool = null;
    _scene.dragging = null;
    _ghost.value = null;
  }

  /// Is [global] over the canvas, away from the Controls card?
  bool _dropsOnScene(Offset global) {
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return false;
    if (!(Offset.zero & canvas.size).contains(canvas.globalToLocal(global))) {
      return false;
    }
    final panel = _panelKey.currentContext?.findRenderObject();
    if (panel is RenderBox && panel.hasSize && panel.attached) {
      final rect = panel.localToGlobal(Offset.zero) & panel.size;
      if (rect.contains(global)) return false;
    }
    return true;
  }

  // -------------------------------------------------------------- gestures

  /// HTML `onCanvasClick`: Scenario 1 raycasts the animals at step 1;
  /// Scenario 2 reacts to any tap.
  void _onSceneTap(Offset p) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    if (s.forest) {
      if (s.step != 1) return;
      final i = s.animalAt(p, _touch);
      if (i != null) _tapAnimal(i);
    } else {
      _tapHills();
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
        final sc = _scene.scenario;
        final step = _step;
        final inset = labOverlayInsets(context, _lab);
        final popupOpen = _lab.popup != null;
        final open = _lab.isSidebarOpen;
        final pad = MediaQuery.paddingOf(context);
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.forest,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _t('s${sc + 1}_hud_$step'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch11a4-steps-$sc-$step'),
            steps: _stepData,
            current: step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('exploration'),
            focusLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            resultLabel: _t('observation'),
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#inventory-panel`: beside the scene while the sidebar
            // is open, along the bottom edge while it is collapsed (the
            // floating mission card is then on the left).
            if (open)
              Positioned(
                key: const ValueKey('ch11a4-controls-side'),
                left: inset.left,
                top: inset.top,
                bottom: inset.bottom + _hudBand * s,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _controlsCard(p, s, vertical: true),
                ),
              )
            else
              Positioned(
                key: const ValueKey('ch11a4-controls-dock'),
                left: 16 + pad.left,
                bottom: 8 + pad.bottom,
                child: _controlsCard(p, s, vertical: false),
              ),
            // 'Observe Conclusion' on the canvas (above the HUD) at the
            // last step, so the summary is in reach on phones too.
            if (_atLastStep && !popupOpen)
              Positioned(
                key: const ValueKey('ch11a4-conclude'),
                bottom: inset.bottom + (open ? 66 * s : 0),
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: _concludeAction(highlight: true),
                    scale: s,
                    expand: false,
                  ),
                ),
              ),
            // HTML `#drag-ghost`.
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<Offset?>(
                  valueListenable: _ghost,
                  builder: (context, at, _) {
                    final tool = _dragTool;
                    if (at == null || tool == null) {
                      return const SizedBox.shrink();
                    }
                    final label = _controlItems()
                        .firstWhere((i) => i.tool == tool)
                        .label;
                    return Stack(
                      children: [
                        Positioned(
                          left: at.dx,
                          top: at.dy,
                          child: FractionalTranslation(
                            translation: const Offset(-0.5, -0.5),
                            child: _DragGhost(
                              tool: tool,
                              label: label,
                              scale: s,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  /// The Controls card with this scenario's items.
  Widget _controlsCard(LabPalette p, double s, {required bool vertical}) {
    return _ControlsCard(
      key: _panelKey,
      title: _t('controls'),
      items: _controlItems(),
      vertical: vertical,
      palette: p,
      scale: s,
      frame: _frame,
      onTap: _useTool,
      onDragStart: _dragStart,
      onDragMove: _dragMove,
      onDragEnd: _dragEnd,
      onDragCancel: _endDrag,
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Taps on the scene are not screen-reader actions; the
                // animals and hills are announced instead.
                excludeFromSemantics: true,
                onTapUp: (d) => _onSceneTap(d.localPosition),
                child: Semantics(
                  image: true,
                  label: _t(_scene.forest ? 'scene_s1' : 'scene_s2'),
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
              // One semantics node for each animal, hill and stream where
              // it is drawn (added), so a screen reader can find and tap
              // them. They take no touches: those reach the scene below.
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
    Widget node(Rect rect, String label, VoidCallback? onTap) =>
        Positioned.fromRect(
          rect: rect,
          child: Semantics(
            container: true,
            button: onTap != null,
            label: label,
            onTap: onTap,
            child: const SizedBox.expand(),
          ),
        );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (s.forest)
          for (var i = 0; i < 3; i++)
            node(
              s.animalRect(i, cam),
              _t(_animalKeys[i]),
              s.step == 1 ? () => _tapAnimal(i) : null,
            )
        else ...[
          for (var side = 0; side < 2; side++) ...[
            node(
              s.hillRect(side, cam),
              _t(side == 0 ? 'lbl_forest_hill' : 'lbl_bare_hill'),
              s.step <= 3 ? _tapHills : null,
            ),
            node(
              s.streamRect(side, cam),
              _t(side == 0 ? 'lbl_clear_stream' : 'lbl_muddy_stream'),
              s.step <= 3 ? _tapHills : null,
            ),
          ],
        ],
      ],
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus area, task action and expected outcome. The current step is
/// open, done steps show a tick and can be re-opened, future steps are
/// dimmed.
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
        color: current ? p.accent.withValues(alpha: 0.1) : p.card,
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
                  _heading(w.focusLabel, accent),
                  SizedBox(height: 3 * s),
                  _body(step.focus, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.resultLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.result, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One item of the Controls card.
@immutable
class _ControlItem {
  const _ControlItem({
    required this.tool,
    required this.label,
    required this.used,
    required this.draggable,
  });

  final _Tool tool;
  final String label;

  /// HTML `.inv-item.used`: faded, greyed and locked.
  final bool used;

  /// HTML `onmousedown="startDrag(...)"`: the item can be dragged onto the
  /// scene as well as tapped.
  final bool draggable;
}

/// HTML `.inv-item.used`: `filter: grayscale(0.65)`.
const ColorFilter _greyed = ColorFilter.matrix(<double>[
  0.4882, 0.4649, 0.0469, 0, 0, //
  0.1382, 0.8149, 0.0469, 0, 0, //
  0.1382, 0.4649, 0.3969, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Tailwind `animate-bounce` (1 s): how far up (0–1 of 25% of the height)
/// the rain cloud icon is at [time].
double _bounce(double time) {
  final u = time % 1.0;
  if (u < 0.5) return 1 - const Cubic(0.8, 0, 1, 1).transform(u / 0.5);
  return const Cubic(0, 0, 0.2, 1).transform((u - 0.5) / 0.5);
}

/// HTML `#inventory-panel`: a glass card with the "Controls" heading and
/// the scenario's items, in a column beside the scene or in a row along
/// the bottom of the canvas. Items are tapped (HTML `onclick`) or dragged
/// onto the scene (HTML `startDrag`).
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    super.key,
    required this.title,
    required this.items,
    required this.vertical,
    required this.palette,
    required this.scale,
    required this.frame,
    required this.onTap,
    required this.onDragStart,
    required this.onDragMove,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final String title;
  final List<_ControlItem> items;
  final bool vertical;
  final LabPalette palette;
  final double scale;

  /// Scene time, for the bouncing rain cloud.
  final ValueListenable<double> frame;
  final ValueChanged<_Tool> onTap;
  final void Function(_Tool tool, Offset global) onDragStart;
  final ValueChanged<Offset> onDragMove;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final dark = p.isDark;
    final ink = dark ? _Colors.emerald400 : _Colors.emerald600;
    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.backpack, size: 13 * s, color: ink),
        SizedBox(width: 5 * s),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: ink,
            fontSize: 10.5 * s,
            fontWeight: FontWeight.w800,
            letterSpacing: labLetterSpacing(title, 1),
          ),
        ),
      ],
    );
    final divider = dark ? _Colors.slate700 : _Colors.slate300;
    final tiles = [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) SizedBox(width: 8 * s, height: 8 * s),
        _tile(items[i]),
      ],
    ];
    return Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: dark ? const Color(0xF20F172A) : _Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _Colors.emerald500.withValues(alpha: dark ? 0.4 : 0.8),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowSoft,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header,
                Container(
                  width: 104 * s,
                  height: 1,
                  margin: EdgeInsets.symmetric(vertical: 7 * s),
                  color: divider,
                ),
                ...tiles,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                header,
                Container(
                  width: 1,
                  height: 40 * s,
                  margin: EdgeInsets.symmetric(horizontal: 8 * s),
                  color: divider,
                ),
                ...tiles,
              ],
            ),
    );
  }

  Widget _tile(_ControlItem item) {
    final s = scale;
    final dark = palette.isDark;
    final (Color bg, Color border, Color text) = switch (item.tool) {
      _Tool.villagers => (
        dark
            ? _Colors.emerald500.withValues(alpha: 0.1)
            : _Colors.emerald100.withValues(alpha: 0.9),
        dark
            ? _Colors.emerald500.withValues(alpha: 0.3)
            : _Colors.emerald600.withValues(alpha: 0.7),
        dark ? _Colors.emerald400 : _Colors.slate900,
      ),
      _Tool.cut => (
        dark
            ? _Colors.red500.withValues(alpha: 0.1)
            : _Colors.red100.withValues(alpha: 0.9),
        dark
            ? _Colors.red500.withValues(alpha: 0.3)
            : _Colors.red600.withValues(alpha: 0.7),
        dark ? _Colors.red400 : _Colors.slate900,
      ),
      _Tool.cloud => (
        dark
            ? _Colors.blue400.withValues(alpha: 0.1)
            : _Colors.blue100.withValues(alpha: 0.9),
        dark
            ? _Colors.blue400.withValues(alpha: 0.3)
            : _Colors.blue600.withValues(alpha: 0.7),
        dark ? _Colors.blue400 : _Colors.slate900,
      ),
    };
    final iconSize = 26 * s;
    final Widget icon = switch (item.tool) {
      _Tool.villagers => CustomPaint(
        size: Size.square(iconSize),
        painter: const _ControlIconPainter(_Tool.villagers),
      ),
      _Tool.cut => Icon(
        Icons.hardware,
        size: iconSize,
        color: dark ? _Colors.red400 : _Colors.red600,
      ),
      _Tool.cloud => ValueListenableBuilder<double>(
        valueListenable: frame,
        builder: (context, time, child) => Transform.translate(
          offset: Offset(0, -0.25 * iconSize * _bounce(time)),
          child: child,
        ),
        child: CustomPaint(
          size: Size.square(iconSize),
          painter: const _ControlIconPainter(_Tool.cloud),
        ),
      ),
    };
    Widget tile = Container(
      width: 104 * s,
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowSoft,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30 * s,
            child: Center(child: icon),
          ),
          SizedBox(height: 2 * s),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
    if (item.used) {
      tile = Opacity(
        opacity: 0.55,
        child: ColorFiltered(colorFilter: _greyed, child: tile),
      );
    }
    final live = !item.used;
    final drags = live && item.draggable;
    return Semantics(
      button: true,
      enabled: live,
      label: item.label,
      excludeSemantics: true,
      onTap: live ? () => onTap(item.tool) : null,
      child: MouseRegion(
        cursor: live ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: live ? () => onTap(item.tool) : null,
          onPanStart: drags
              ? (d) => onDragStart(item.tool, d.globalPosition)
              : null,
          onPanUpdate: drags ? (d) => onDragMove(d.globalPosition) : null,
          onPanEnd: drags ? (_) => onDragEnd() : null,
          onPanCancel: drags ? onDragCancel : null,
          child: tile,
        ),
      ),
    );
  }
}

/// The HTML inventory SVGs (24 x 24): a village woman beside a trunk, and
/// the rain cloud with its two arrows.
abstract final class _IconPaths {
  /// `M10 10c-3.31 0-6 2.69-6 6v2h12v-2c0-3.31-2.69-6-6-6z`.
  static final Path body = Path()
    ..moveTo(10, 10)
    ..cubicTo(6.69, 10, 4, 12.69, 4, 16)
    ..lineTo(4, 18)
    ..lineTo(16, 18)
    ..lineTo(16, 16)
    ..cubicTo(16, 12.69, 13.31, 10, 10, 10)
    ..close();

  /// The cloud.
  static final Path cloud = Path()
    ..moveTo(19.35, 10.04)
    ..cubicTo(18.67, 6.59, 15.64, 4, 12, 4)
    ..cubicTo(9.11, 4, 6.6, 5.64, 5.35, 8.04)
    ..cubicTo(2.34, 8.36, 0, 10.91, 0, 14)
    ..cubicTo(0, 17.31, 2.69, 20, 6, 20)
    ..lineTo(19, 20)
    ..cubicTo(21.76, 20, 24, 17.76, 24, 15)
    ..cubicTo(24, 12.36, 21.95, 10.22, 19.35, 10.04)
    ..close();

  /// The two white arrows on the cloud.
  static final Path arrows = () {
    final path = Path();
    for (final dx in const [0.0, 8.0]) {
      path
        ..moveTo(8 + dx, 17)
        ..lineTo(8 + dx, 14.42)
        ..lineTo(6.29 + dx, 16.12)
        ..lineTo(4.87 + dx, 14.71)
        ..lineTo(8 + dx, 11.59)
        ..lineTo(11.13 + dx, 14.71)
        ..lineTo(9.71 + dx, 16.12)
        ..lineTo(8 + dx, 14.41)
        ..close();
    }
    return path;
  }();
}

/// Paints an inventory SVG in its 24 x 24 box.
class _ControlIconPainter extends CustomPainter {
  const _ControlIconPainter(this.tool);

  final _Tool tool;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    if (tool == _Tool.villagers) {
      paint.color = _Colors.emerald500;
      canvas.drawCircle(const Offset(10, 6), 2, paint);
      canvas.drawPath(_IconPaths.body, paint);
      for (final x in const [18.0, 20.0]) {
        canvas.drawRRect(
          RRect.fromLTRBR(x, 12, x + 1, 20, const Radius.circular(0.5)),
          paint,
        );
      }
      canvas.drawCircle(const Offset(11, 5), 1, paint..color = _Colors.slate50);
    } else {
      canvas.drawPath(_IconPaths.cloud, paint..color = _Colors.sky400);
      canvas.drawPath(_IconPaths.arrows, paint..color = _Colors.slate50);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ControlIconPainter old) => old.tool != tool;
}

/// HTML `#drag-ghost`: an emerald card (white border, people or rain-cloud
/// icon and the item's name) under the finger, 1.15x.
class _DragGhost extends StatelessWidget {
  const _DragGhost({
    required this.tool,
    required this.label,
    required this.scale,
  });

  final _Tool tool;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Transform.scale(
      scale: 1.15,
      child: Container(
        padding: EdgeInsets.all(14 * s),
        decoration: BoxDecoration(
          color: _Colors.emerald500.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: LabInk.shadowStrong, blurRadius: 24),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tool == _Tool.cloud ? Icons.thunderstorm : Icons.groups,
              size: 28 * s,
              color: _Colors.slate950,
            ),
            SizedBox(width: 8 * s),
            Text(
              label,
              style: TextStyle(
                color: _Colors.slate950,
                fontSize: 13 * s,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Below the summary text: the HTML `#summary-completion-banner` ("Scenario
/// Complete! Please select next scenario") and, once both scenarios are
/// done, the HTML success modal's trophy, "Mastery Achieved!" and its text.
class _SummaryExtra extends StatelessWidget {
  const _SummaryExtra({
    required this.palette,
    required this.scale,
    required this.banner,
    required this.mastery,
  });

  final LabPalette palette;
  final double scale;
  final String banner;
  final (String, String)? mastery;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final green = p.isDark ? _Colors.emerald300 : _Colors.emerald600;
    final mastered = mastery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
          decoration: BoxDecoration(
            color: _Colors.emerald500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _Colors.emerald500.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 20 * s, color: green),
              SizedBox(width: 10 * s),
              Flexible(
                child: Text(
                  banner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: green,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mastered != null) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: _Colors.yellow500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _Colors.yellow500.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _Colors.yellow500.withValues(alpha: 0.2),
                    border: Border.all(
                      color: _Colors.yellow500.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 24 * s,
                    color: p.ink(_Colors.yellow400),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mastered.$1,
                        style: TextStyle(
                          color: p.textStrong,
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        mastered.$2,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
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
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();
}

/// One lighting of the HTML scene: `AmbientLight(0xffffff, a)` and the
/// key `DirectionalLight` (intensity and colour); the sky-blue fill light
/// never changes.
@immutable
class _Light {
  const _Light(this.ambient, this.key, this.keyTint);

  final double ambient;
  final double key;
  final (double, double, double) keyTint;
}

/// The day (ambient 0.7, key 0xfffbeb 1.15), the thunderstorm (ambient
/// 0.35, key 0x94a3b8 0.55) and a lightning flash (key 0xe0f2fe 2.4).
const List<_Light> _lights = [
  _Light(0.7, 1.15, (1, 0.984, 0.922)),
  _Light(0.35, 0.55, (0.58, 0.639, 0.722)),
  _Light(0.35, 2.4, (0.878, 0.949, 0.996)),
];

/// Key light from (16, 38, 22) and fill light `DirectionalLight(0x38bdf8,
/// 0.4)` from (-15, 20, -15), normalised.
const _V _keyDir = _V(0.3424, 0.8132, 0.4708);
const _V _fillDir = _V(-0.5145, 0.686, -0.5145);
const double _fillPower = 0.4;
const (double, double, double) _fillTint = (0.22, 0.741, 0.973);

/// A surface turned to the camera (round meshes) and the side of an
/// upright mesh turned to the camera and the key light.
const _V _viewNormal = _V(0, 0.2405, 0.9706);
const _V _sideNormal = _V(0.35, 0.25, 0.9);

/// MeshStandardMaterial look: ambient light plus the key and fill lights'
/// Lambert terms on a surface with normal [n] (no tone mapping, as r128).
Color _lit(Color c, _V n, _Light l) {
  final k = l.key * math.max(0.0, n.dot(_keyDir));
  final f = _fillPower * math.max(0.0, n.dot(_fillDir));
  double channel(double v, double keyTint, double fillTint) =>
      math.min(1.0, v * (l.ambient + k * keyTint + f * fillTint));
  return Color.from(
    alpha: c.a,
    red: channel(c.r, l.keyTint.$1, _fillTint.$1),
    green: channel(c.g, l.keyTint.$2, _fillTint.$2),
    blue: channel(c.b, l.keyTint.$3, _fillTint.$3),
  );
}

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour and lighting, drawn on a unit circle) and the label text
/// painters. Owned by the page state and disposed with it.
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

  /// MeshStandardMaterial look for a sphere of [c] in lighting [light]: a
  /// radial gradient on a unit circle, lit from the upper right like the
  /// HTML key light.
  Paint ball(Color c, int light) => _balls[c.toARGB32() * 4 + light] ??= () {
    final lit = _lit(c, _viewNormal, _lights[light]);
    return Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.4),
        1.4,
        [labShade(lit, 0.3), lit, labShade(lit, -0.35)],
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

/// The part of the polygon [poly] at least [near] in front of the camera
/// (one Sutherland–Hodgman pass).
List<_V> _clipNear(List<_V> poly, _Cam cam, double near) {
  final out = <_V>[];
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i], b = poly[(i + 1) % poly.length];
    final da = cam.depth(a) - near, db = cam.depth(b) - near;
    if (da >= 0) out.add(a);
    if ((da >= 0) != (db >= 0)) out.add(_V.lerp(a, b, da / (da - db)));
  }
  return out;
}

/// Lathes (cylinders, cones) drawn at least this tall or wide (design px)
/// are shaded facet by facet; smaller ones get shading bands.
const double _facetPx = 16;

/// Mesh drawing in one camera's projection and lighting. Meshes are queued
/// with a layer and their depth and drawn layer by layer, far to near
/// ([flush]), like the HTML depth buffer.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache, this.lightIndex);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  /// Index into [_lights].
  final int lightIndex;

  /// Layer of the next queued meshes: 0 behind the hills, 1 the hills, 2
  /// everything else (Scenario 1 uses 1 only).
  int layer = 1;

  final List<(int, double, int, VoidCallback)> _queue = [];

  _Pens get pens => cache.pens;

  _Light get light => _lights[lightIndex];

  Color lit(Color c, _V n) => _lit(c, n, light);

  // ------------------------------------------------------------ ordering

  /// Queues [draw] at [depth] (skipped when behind the camera).
  void later(double depth, VoidCallback draw) {
    if (depth < _clipDepth) return;
    _queue.add((layer, depth, _queue.length, draw));
  }

  /// Draws the queue, layer by layer, farthest first.
  void flush() {
    _queue.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      final c = b.$2.compareTo(a.$2);
      return c != 0 ? c : a.$3.compareTo(b.$3);
    });
    for (final (_, _, _, draw) in _queue) {
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

  // ---------------------------------------------------------- primitives

  /// A shaded ellipse of radii [rx] x [ry] at [c], turned by [angle].
  void blob(Offset c, double rx, double ry, Color color, {double angle = 0}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(math.max(0.01, rx), math.max(0.01, ry));
    canvas.drawCircle(Offset.zero, 1, cache.ball(color, lightIndex));
    canvas.restore();
  }

  /// An ellipsoid at [c] with semi-axes [a], [b], [d] as the camera sees
  /// it now: the projected axes' ellipse (eigen-decomposition of Σ q qᵀ).
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

  /// A SphereGeometry of radius [r] drawn now in the frame [xf].
  void ball(_Xf xf, double r, Color color) =>
      ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color);

  /// SphereGeometry of radius [r] in the frame [xf] (its axes carry the
  /// mesh scale); [bias] moves it in the draw order (+ farther).
  void sphere(_Xf xf, double r, Color color, {double bias = 0}) {
    final depth = cam.depth(xf.o);
    if (depth - r * xf.size < _clipDepth) return;
    later(depth + bias, () => ball(xf, r, color));
  }

  /// A small unlit sphere (`MeshBasicMaterial` eyes) of world radius [r].
  void dot(_V c, double r, Color color, {double bias = 0}) => later(
    cam.depth(c) + bias,
    () => canvas.drawCircle(
      cam.p(c),
      math.max(0.6, r * cam.scaleAt(c)),
      pens.fill..color = color,
    ),
  );

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf], its axis
  /// along the frame's y; a cone when [rTop] is 0.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 12,
    double bias = 0,
  }) {
    final d = cam.depth(xf.o);
    if (d - math.max(h / 2, math.max(rTop, rBottom)) * xf.size < _clipDepth) {
      return;
    }
    later(d + bias, () => lathe(xf, rTop, rBottom, h, color, segments));
  }

  /// ConeGeometry([r], [h]).
  void cone(
    _Xf xf,
    double r,
    double h,
    Color color, {
    int segments = 12,
    double bias = 0,
  }) => cylinder(xf, 0, r, h, color, segments: segments, bias: bias);

  /// Draws a cylinder or cone now: its outline (hull of both rims), its
  /// side shaded facet by facet (or with bands when small) and the end cap
  /// turned to the camera.
  void lathe(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color,
    int segments,
  ) {
    final hh = h / 2;
    final n = segments;
    final topW = <_V>[];
    final bottomW = <_V>[];
    for (var i = 0; i < n; i++) {
      final t = 2 * math.pi * i / n;
      final c = math.cos(t), s = math.sin(t);
      topW.add(xf(rTop * c, hh, rTop * s));
      bottomW.add(xf(rBottom * c, -hh, rBottom * s));
    }
    final top = [for (final w in topW) cam.p(w)];
    final bottom = [for (final w in bottomW) cam.p(w)];
    final a = xf(0, -hh, 0), b = xf(0, hh, 0);
    final pa = cam.p(a), pb = cam.p(b);
    final body = lit(color, _sideNormal);
    canvas.drawPath(
      polygon(_hull([...top, ...bottom])),
      pens.fill..color = body,
    );
    final width = math.max(
      (bottom[0] - bottom[n ~/ 2]).distance,
      (top[0] - top[n ~/ 2]).distance,
    );
    final axis = xf.y.unit;
    if (math.max(width, (pa - pb).distance) >= _facetPx) {
      final slope = (rBottom - rTop) / h;
      final ux = xf.x.unit, uz = xf.z.unit;
      for (var i = 0; i < n; i++) {
        final j = (i + 1) % n;
        final t = 2 * math.pi * (i + 0.5) / n;
        final normal =
            (ux * math.cos(t) + axis * slope + uz * math.sin(t)).unit;
        final mid = (topW[i] + topW[j] + bottomW[i] + bottomW[j]) * 0.25;
        if (normal.dot(cam.eye - mid) <= 0) continue;
        final shade = lit(color, normal);
        final path = polygon([bottom[i], bottom[j], top[j], top[i]]);
        canvas.drawPath(path, pens.fill..color = shade);
        // Hides the hairline seams between facets.
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.7
            ..color = shade,
        );
      }
    } else {
      final k = xf.x.length;
      _bands(
        pa,
        pb,
        rBottom * k * cam.scaleAt(a),
        rTop * k * cam.scaleAt(b),
        body,
      );
    }
    if (rTop > 1e-4 && axis.dot(cam.eye - b) > 0) {
      canvas.drawPath(polygon(top), pens.fill..color = lit(color, axis));
    }
    if (rBottom > 1e-4 && axis.dot(cam.eye - a) < 0) {
      canvas.drawPath(polygon(bottom), pens.fill..color = lit(color, -axis));
    }
  }

  /// Shading bands along a small mesh's side from [pa] to [pb] (half
  /// widths [wa], [wb]): shadow away from the key light, highlight towards
  /// it.
  void _bands(Offset pa, Offset pb, double wa, double wb, Color body) {
    final d = pb - pa;
    final len = d.distance;
    if (len < 1 || wa + wb < 2) return;
    var n = Offset(-d.dy / len, d.dx / len);
    // The key light comes from the upper right of the screen.
    if (n.dy > 0 || (n.dy == 0 && n.dx < 0)) n = -n;
    void band(double from, double to, Color color) => canvas.drawPath(
      polygon([
        pa + n * (wa * from),
        pb + n * (wb * from),
        pb + n * (wb * to),
        pa + n * (wa * to),
      ]),
      pens.fill..color = color,
    );
    band(-0.92, -0.3, labShade(body, -0.2));
    band(0.28, 0.6, labShade(body, 0.22));
  }

  /// BoxGeometry of [size] centred on the frame [xf]: the faces turned to
  /// the camera, lit, with soft edges.
  void box(_Xf xf, _V size, Color color, {double bias = 0, double edge = 0.3}) {
    final d = cam.depth(xf.o);
    if (d - size.length * xf.size / 2 < _clipDepth) return;
    later(d + bias, () {
      final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
      for (final face in _boxFaces) {
        final n = face.normal;
        final normal = xf.normal(n);
        final mid = xf(n.x * hx, n.y * hy, n.z * hz);
        if (normal.dot(cam.eye - mid) <= 0) continue;
        final path = polygon([
          for (final k in face.corners) cam.p(xf(k.x * hx, k.y * hy, k.z * hz)),
        ]);
        canvas.drawPath(path, pens.fill..color = lit(color, normal));
        if (edge > 0) {
          canvas.drawPath(
            path,
            pens.stroke
              ..strokeWidth = 0.6
              ..color = labShade(color, -0.5).withValues(alpha: edge),
          );
        }
      }
    });
  }

  /// TorusGeometry([radius], [tube]) in the frame's xy plane, up to [arc];
  /// [frontOnly] skips the half behind its centre (a necklace round a
  /// neck).
  void ring(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double arc = 2 * math.pi,
    bool frontOnly = false,
    double bias = 0,
  }) {
    final d = cam.depth(xf.o);
    if (d < _clipDepth) return;
    later(
      d + bias,
      () => drawRing(xf, radius, tube, color, arc: arc, frontOnly: frontOnly),
    );
  }

  /// Draws a torus now (see [ring]).
  void drawRing(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double arc = 2 * math.pi,
    bool frontOnly = false,
  }) {
    final centre = cam.depth(xf.o);
    final steps = (24 * arc / (2 * math.pi)).ceil().clamp(4, 24);
    final path = pens.path..reset();
    var drawing = false;
    for (var i = 0; i <= steps; i++) {
      final t = arc * i / steps;
      final w = xf(radius * math.cos(t), radius * math.sin(t), 0);
      if (frontOnly && cam.depth(w) > centre) {
        drawing = false;
        continue;
      }
      final p = cam.p(w);
      if (drawing) {
        path.lineTo(p.dx, p.dy);
      } else {
        path.moveTo(p.dx, p.dy);
        drawing = true;
      }
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(0.6, 2 * tube * xf.size * cam.scaleAt(xf.o))
        ..color = lit(color, _viewNormal),
    );
  }

  /// A flat CircleGeometry of [radius] in the frame's xz plane (a stump's
  /// cut rings).
  void disk(_Xf xf, double radius, Color color, {double bias = 0}) {
    final d = cam.depth(xf.o);
    if (d < _clipDepth) return;
    later(d + bias, () => drawDisk(xf, radius, color, 16));
  }

  /// Draws a flat disk now (see [disk]).
  void drawDisk(_Xf xf, double radius, Color color, int segments) {
    final pts = <_V>[
      for (var i = 0; i < segments; i++)
        xf(
          radius * math.cos(2 * math.pi * i / segments),
          0,
          radius * math.sin(2 * math.pi * i / segments),
        ),
    ];
    final front = _clipNear(pts, cam, _clipDepth);
    if (front.length < 3) return;
    canvas.drawPath(
      polygon([for (final p in front) cam.p(p)]),
      pens.fill..color = lit(color, xf.normal(_V.up)),
    );
  }

  /// A flat quad on a surface with [normal] (a gully on the slope).
  void quad(List<_V> corners, Color color, _V normal, {double bias = 0}) {
    var c = _V.zero;
    for (final p in corners) {
      c = c + p;
    }
    c = c * (1 / corners.length);
    later(
      cam.depth(c) + bias,
      () => canvas.drawPath(
        polygon([for (final p in corners) cam.p(p)]),
        pens.fill..color = lit(color, normal),
      ),
    );
  }

  /// The loggers' red X badge sprite (a 128 px canvas: red disc r 58,
  /// white strokes 14 px from (38, 38) to (90, 90)), [size] wide, facing
  /// the camera.
  void badge(_V c, double size, {double bias = 0}) =>
      later(cam.depth(c) + bias, () {
        final p = cam.p(c);
        final half = size / 2 * cam.scaleAt(c);
        canvas.drawCircle(p, half * 58 / 64, pens.fill..color = _Colors.badge);
        final k = half * 26 / 64;
        final st = pens.stroke
          ..strokeWidth = half * 14 / 64
          ..color = _Colors.white;
        canvas.drawLine(p + Offset(-k, -k), p + Offset(k, k), st);
        canvas.drawLine(p + Offset(k, -k), p + Offset(-k, k), st);
      });

  /// Soft contact shadow now: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz, {double alpha = 1}) {
    if (alpha <= 0.01 || cam.depth(c) - rz < _clipDepth) return;
    final p = cam.p(c);
    final w = rx * cam.scaleAt(c);
    final h =
        (cam.p(c + _V(0, 0, rz)).dy - cam.p(c - _V(0, 0, rz)).dy).abs() / 2;
    canvas.drawOval(
      Rect.fromCenter(center: p, width: 2 * w, height: 2 * math.max(1, h)),
      pens.shadow..color = _Colors.shadow.withValues(alpha: 0.28 * alpha),
    );
  }
}

/// How a village woman is dressed (`buildWomanMesh(saree, dupatta, skin)`).
typedef _Look = (Color saree, Color dupatta, Color skin);

/// The three women who hug the trees and the leader (emerald saree with a
/// saffron-gold pallu).
const List<_Look> _villagerLooks = [
  (Color(0xFFF43F5E), Color(0xFFFBBF24), Color(0xFFFECCA2)),
  (Color(0xFF10B981), Color(0xFF38BDF8), Color(0xFFFDCEAA)),
  (Color(0xFFF97316), Color(0xFFFEF08A), Color(0xFFFECCA2)),
];
const _Look _leaderLook = (
  Color(0xFF059669),
  Color(0xFFF59E0B),
  Color(0xFFFDCEAA),
);

/// Paints the HTML Three.js scene of the current scenario: S1 the forest
/// island (trees, village women, leader, loggers, animals), S2 the two
/// hillsides (streams, rain cloud, storm); then the labels and the
/// confetti on top.
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
    final light = s.flashing ? 2 : (s.storm ? 1 : 0);
    final g = _Gfx(canvas, s.camera(), cache, light);
    canvas.drawRect(
      labBleed(size),
      _pens.fill
        ..color = s.storm
            ? _Colors.sceneStorm
            : (isDark ? _Colors.sceneDark : _Colors.sceneLight),
    );
    if (s.forest) {
      _paintForest(g);
    } else {
      _paintHillsides(g);
    }
    if (showLabels) _paintLabels(g);
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: the island, the five trees, the village women on
  /// the hugged trees, the leader, the loggers and the animals.
  void _paintForest(_Gfx g) {
    final s = scene;
    final t = s.time;
    // The island's side and its lawn, under everything.
    g.lathe(
      _root.child(const _V(0, _islandY, 0)),
      _islandTopR,
      _islandBottomR,
      _islandH,
      _Colors.island,
      48,
    );
    g.drawDisk(_root.child(const _V(0, _lawnY, 0)), _lawnR, _Colors.lawn, 48);
    _paintShadows(g);
    _paintHint(g);

    for (var i = 0; i < _huggedTrees.length; i++) {
      final tree = s.huggedTree(i);
      _paintTree(g, tree, _huggedTrees[i].scale);
      final k = s.womanScale[i].at(t);
      if (i < s.treesHugged && k > 0.01) {
        _paintWoman(
          g,
          tree.scaled(const _V(0, 0, _hugOffset), k, ry: math.pi),
          _villagerLooks[i],
        );
      }
    }
    for (var i = 0; i < _openTrees.length; i++) {
      _paintTree(g, s.openTree(i), _openTrees[i].scale);
    }
    final leader = _root.scaled(_leaderPos, _womanScale, ry: _leaderTurn);
    _paintWoman(g, leader, _leaderLook);
    g.cylinder(
      leader.child(const _V(0.48, 1.45, 0.32)),
      0.045,
      0.045,
      2.9,
      _Colors.staff,
      segments: 8,
    );
    if (s.cutStarted) {
      for (var i = 0; i < _loggerPos.length; i++) {
        _paintLogger(
          g,
          _root.scaled(_loggerPos[i], _loggerScale, ry: _loggerTurn),
          s.arms[i],
        );
      }
    }
    _paintDeer(g, s.animal(0));
    _paintMonkey(g, s.animal(1));
    _paintBird(g, s.animal(2));
    g.flush();
  }

  /// Soft shadows on the lawn (the key light is high in front, to the
  /// right): under the trees (fading as the cut ones fall), the people and
  /// the deer while it is on the island.
  void _paintShadows(_Gfx g) {
    final s = scene;
    for (final tr in _huggedTrees) {
      final k = tr.scale;
      g.shadow(_root(tr.x - 0.5 * k, _lawnY, tr.z - 0.6 * k), 1.7 * k, 1.3 * k);
    }
    for (var i = 0; i < _openTrees.length; i++) {
      final tr = _openTrees[i];
      final k = tr.scale;
      g.shadow(
        _root(tr.x - 0.5 * k, _lawnY, tr.z - 0.6 * k),
        1.7 * k,
        1.3 * k,
        alpha: math.cos(s.fall[i].at(s.time).abs().clamp(0, math.pi / 2)),
      );
    }
    g.shadow(_root(_leaderPos.x - 0.2, _lawnY, _leaderPos.z - 0.25), 0.6, 0.45);
    for (var i = 0; i < s.treesHugged; i++) {
      final tr = _huggedTrees[i];
      g.shadow(_root(tr.x - 0.2, _lawnY, tr.z + _hugOffset - 0.2), 0.55, 0.4);
    }
    if (s.cutStarted) {
      for (final at in _loggerPos) {
        g.shadow(_root(at.x - 0.2, _lawnY, at.z - 0.25), 0.6, 0.45);
      }
    }
    final dx = s.deerX.at(s.time), dz = s.deerZ.at(s.time);
    if (dx * dx + dz * dz < _lawnR * _lawnR) {
      g.shadow(_root(dx - 0.3, _lawnY, dz - 0.3), 1.4, 0.7);
    }
  }

  /// Added: while a woman is dragged from the Controls card, a pulsing
  /// ring round the foot of the next tree she will hug.
  void _paintHint(_Gfx g) {
    final s = scene;
    if (s.dragging != _Tool.villagers || s.treesHugged >= 3) return;
    final tr = _huggedTrees[s.treesHugged];
    final c = _root(tr.x, _lawnY, tr.z);
    if (g.cam.depth(c) < _clipDepth) return;
    final pulse = 0.5 + 0.5 * math.sin(s.time * 6);
    final r = (1.25 + 0.2 * pulse) * tr.scale;
    final p = g.cam.p(c);
    final w = r * g.cam.scaleAt(c);
    final h = (g.cam.p(c + _V(0, 0, r)).dy - g.cam.p(c - _V(0, 0, r)).dy).abs();
    final oval = Rect.fromCenter(center: p, width: 2 * w, height: h);
    g.canvas.drawOval(
      oval,
      _pens.glow
        ..strokeWidth = 6
        ..color = _Colors.hint.withValues(alpha: 0.5 + 0.3 * pulse),
    );
    g.canvas.drawOval(
      oval,
      _pens.stroke
        ..strokeWidth = 2
        ..color = _Colors.hint,
    );
  }

  /// `buildNaturalTreeMesh(k)` in the group frame [tree]: the bark trunk
  /// and the three foliage crowns.
  void _paintTree(_Gfx g, _Xf tree, double k) {
    g.cylinder(
      tree.child(_V(0, _trunkH / 2 * k, 0)),
      _trunkTopR * k,
      _trunkBottomR * k,
      _trunkH * k,
      _Colors.bark,
      segments: 16,
    );
    const colors = [_Colors.crown1, _Colors.crown2, _Colors.crown3];
    for (var i = 0; i < _crowns.length; i++) {
      final (r, h, y) = _crowns[i];
      g.cone(
        tree.child(_V(0, y * k, 0)),
        r * k,
        h * k,
        colors[i],
        segments: 20,
      );
    }
  }

  /// `buildWomanMesh()` in the group frame [w] (scale and turn included):
  /// sandals, the saree skirt with its gold hem, the pallu over the blouse
  /// (which it hides), the sash, neck and necklace, the head and the
  /// hugging arms with bangles.
  void _paintWoman(_Gfx g, _Xf w, _Look look) {
    final (saree, dupatta, skin) = look;
    for (final x in const [-0.18, 0.18]) {
      g.box(
        w.child(_V(x, 0.05, 0.04)),
        const _V(0.2, 0.1, 0.32),
        _Colors.sandal,
      );
      g.box(
        w.child(_V(x, 0.12, 0.04)),
        const _V(0.16, 0.12, 0.28),
        skin,
        bias: -0.01,
      );
    }
    g.cylinder(
      w.child(const _V(0, 0.72, 0)),
      0.38,
      0.55,
      1.1,
      saree,
      segments: 16,
    );
    // The hem ring stands a little proud of the skirt's foot.
    g.cylinder(
      w.child(const _V(0, 0.2, 0)),
      0.56,
      0.56,
      0.08,
      _Colors.gold,
      segments: 16,
      bias: -0.3,
    );
    g.cylinder(
      w.child(const _V(0, 1.58, 0.02), sx: 1.05, sz: 0.95),
      0.38,
      0.42,
      0.78,
      dupatta,
      segments: 16,
    );
    g.box(
      w.child(const _V(-0.22, 1.75, -0.15), rz: 0.3),
      const _V(0.24, 0.65, 0.12),
      dupatta,
    );
    g.cylinder(w.child(const _V(0, 1.98, 0)), 0.14, 0.15, 0.25, skin);
    g.ring(
      w.child(const _V(0, 1.92, 0.02), rx: math.pi / 2 + 0.3),
      0.16,
      0.02,
      _Colors.gold,
      frontOnly: true,
      bias: -0.05,
    );
    _paintWomanHead(g, w.child(const _V(0, 2.26, 0)), skin);
    for (final x in const [-0.32, 0.32]) {
      final right = x > 0;
      final arm = w.child(_V(x, 1.76, 0), ry: right ? -0.55 : 0.55);
      g.cylinder(
        arm.child(const _V(0, 0, 0.26), rx: math.pi / 2),
        0.09,
        0.08,
        0.55,
        saree,
        segments: 8,
      );
      g.cylinder(
        arm.child(
          _V(right ? -0.22 : 0.22, 0, 0.52),
          rz: right ? math.pi / 2 : -math.pi / 2,
        ),
        0.08,
        0.07,
        0.52,
        skin,
        segments: 8,
      );
      g.ring(
        arm.child(_V(right ? -0.06 : 0.06, 0, 0.52), ry: math.pi / 2),
        0.085,
        0.015,
        right ? _Colors.bangleRight : _Colors.bangleLeft,
      );
      g.sphere(
        arm.child(_V(right ? -0.46 : 0.46, 0, 0.52), sx: 1.3, sy: 0.8, sz: 1.2),
        0.09,
        skin,
      );
    }
  }

  /// The woman's head group: the head under her hair (parted, with a bun
  /// and its gajra), and, when she faces the camera, her face with eyes,
  /// brows, bindi and smile; gold earrings.
  void _paintWomanHead(_Gfx g, _Xf head, Color skin) {
    final cam = g.cam;
    final depth = cam.depth(head.o);
    final facing = head.z.unit.dot((cam.eye - head.o).unit);
    g.later(depth, () {
      void bun() {
        g.ball(head.child(const _V(0, 0.1, -0.35)), 0.19, _Colors.hair);
        g.drawRing(
          head.child(const _V(0, 0.1, -0.34), rx: math.pi / 2),
          0.16,
          0.04,
          _Colors.gajra,
          frontOnly: true,
        );
      }

      if (facing > 0) bun();
      g.ball(head.child(_V.zero, sx: 0.96, sy: 1.06, sz: 0.98), 0.35, skin);
      g.ball(head.child(const _V(0, 0.06, -0.04)), 0.365, _Colors.hair);
      if (facing <= 0) bun();
      if (facing > 0.05) {
        // The face below the hairline.
        g.ball(
          head.child(const _V(0, -0.07, 0.08), sx: 0.83, sy: 0.84, sz: 0.85),
          0.35,
          skin,
        );
      }
      if (facing > 0.3) _paintFace(g, head);
      for (final x in const [-0.34, 0.34]) {
        final ear = head.child(_V(x, -0.05, 0), ry: math.pi / 2);
        if (cam.depth(ear.o) < depth + 0.05) {
          g.drawRing(ear, 0.05, 0.012, _Colors.gold);
        }
      }
    });
  }

  /// Eyes (white, dark pupils), brows, bindi and the smile.
  void _paintFace(_Gfx g, _Xf head) {
    final cam = g.cam;
    final canvas = g.canvas;
    final k = head.size * cam.scaleAt(head.o);
    for (final x in const [-0.11, 0.11]) {
      final eye = cam.p(head(x, 0.05, 0.31));
      canvas.drawOval(
        Rect.fromCenter(
          center: eye,
          width: math.max(1.2, 0.144 * k),
          height: math.max(0.8, 0.096 * k),
        ),
        _pens.fill..color = _Colors.white,
      );
      canvas.drawCircle(
        cam.p(head(x, 0.05, 0.33)),
        math.max(0.5, 0.035 * k),
        _pens.fill..color = _Colors.eye,
      );
      final tilt = x > 0 ? -0.005 : 0.005;
      canvas.drawLine(
        cam.p(head(x - 0.05, 0.13 + tilt, 0.32)),
        cam.p(head(x + 0.05, 0.13 - tilt, 0.32)),
        _pens.stroke
          ..strokeWidth = math.max(0.5, 0.025 * k)
          ..color = _Colors.hair,
      );
    }
    canvas.drawCircle(
      cam.p(head(0, 0.11, 0.34)),
      math.max(0.5, 0.025 * k),
      _pens.fill..color = _Colors.bindi,
    );
    g.drawRing(
      head.child(const _V(0, -0.08, 0.33), rx: math.pi),
      0.06,
      0.015,
      _Colors.lips,
      arc: math.pi,
    );
  }

  /// `buildLoggerMesh()` in [l]: boots, denim legs, the red flannel torso
  /// and belt, the head under the yellow hard hat, the arms swinging the
  /// chainsaw ([arms] = `armsGroup.rotation.x`) and, once they meet the
  /// hugged trees, the red X badge.
  void _paintLogger(_Gfx g, _Xf l, double arms) {
    for (final x in const [-0.2, 0.2]) {
      g.box(
        l.child(_V(x, 0.1, 0.05)),
        const _V(0.24, 0.2, 0.38),
        _Colors.boots,
      );
      g.cylinder(
        l.child(_V(x, 0.62, 0)),
        0.15,
        0.14,
        0.88,
        _Colors.denim,
        segments: 10,
      );
    }
    g.cylinder(
      l.child(const _V(0, 1.54, 0)),
      0.42,
      0.46,
      1.05,
      _Colors.flannel,
      segments: 16,
    );
    g.cylinder(
      l.child(const _V(0, 1.06, 0)),
      0.47,
      0.47,
      0.14,
      _Colors.boots,
      segments: 16,
      bias: -0.15,
    );
    final head = l.child(const _V(0, 2.34, 0));
    g.later(g.cam.depth(head.o), () {
      g.ball(head, 0.36, _Colors.loggerSkin);
      g.ball(head.child(const _V(0, -0.06, 0.02)), 0.365, _Colors.beard);
      g.ball(head.child(const _V(0, 0.09, 0)), 0.39, _Colors.hardHat);
      g.lathe(
        head.child(const _V(0, 0, 0.08)),
        0.48,
        0.48,
        0.06,
        _Colors.hardHat,
        20,
      );
    });
    final hands = l.child(const _V(0, 1.7, 0.35), rx: arms);
    for (final x in const [-0.26, 0.26]) {
      g.cylinder(
        hands.child(_V(x, -0.2, 0.2), rx: math.pi / 3),
        0.11,
        0.1,
        0.75,
        _Colors.flannel,
        segments: 8,
      );
      g.sphere(hands.child(_V(x, -0.42, 0.55)), 0.12, _Colors.gloves);
    }
    _paintChainsaw(g, hands.scaled(const _V(0, -0.4, 0.8), 0.9));
    if (scene.badges) g.badge(l(0, _badgeY, 0), _badgeSize * l.size);
  }

  /// `buildChainsawMesh()`: the orange engine, the handle loop, the rear
  /// grip and the chain round the guide bar (the steel bar sits inside the
  /// chain's box).
  void _paintChainsaw(_Gfx g, _Xf saw) {
    g.box(saw, const _V(0.45, 0.38, 0.65), _Colors.engine);
    g.ring(
      saw.child(const _V(0, 0.2, 0.1), rz: -math.pi / 2),
      0.24,
      0.035,
      _Colors.grip,
      arc: math.pi,
    );
    g.box(
      saw.child(const _V(0, -0.05, -0.45)),
      const _V(0.12, 0.28, 0.35),
      _Colors.grip,
    );
    g.box(
      saw.child(const _V(0, -0.02, 0.85)),
      const _V(0.08, 0.32, 1.12),
      _Colors.chainTeeth,
    );
  }

  /// `buildDeerMesh()`: legs and hooves, body and pale belly, neck, head
  /// with muzzle, nose, eyes, ears and antlers, and the tail.
  void _paintDeer(_Gfx g, _Xf d) {
    for (final (x, z) in const [
      (-0.6, -0.3),
      (0.6, -0.3),
      (-0.6, 0.3),
      (0.6, 0.3),
    ]) {
      g.cylinder(
        d.child(_V(x, 0.6, z)),
        0.12,
        0.09,
        1.2,
        _Colors.coat,
        segments: 8,
      );
      g.cylinder(
        d.child(_V(x, 0.07, z)),
        0.1,
        0.11,
        0.15,
        _Colors.hoof,
        segments: 8,
      );
    }
    g.box(
      d.child(const _V(0, 1.08, 0)),
      const _V(1.7, 0.3, 0.88),
      _Colors.deerBelly,
    );
    g.box(d.child(const _V(0, 1.5, 0)), const _V(1.8, 1.0, 0.98), _Colors.coat);
    g.cylinder(
      d.child(const _V(0.7, 2.1, 0), rz: -math.pi / 6),
      0.25,
      0.35,
      0.8,
      _Colors.coat,
      segments: 10,
    );
    final head = d.child(const _V(1.05, 2.5, 0));
    g.box(
      head.child(const _V(0.45, -0.1, 0)),
      const _V(0.4, 0.35, 0.48),
      _Colors.deerBelly,
      bias: 0.05,
    );
    g.box(head, const _V(0.75, 0.65, 0.6), _Colors.coat);
    g.sphere(head.child(const _V(0.66, -0.05, 0)), 0.1, _Colors.nose);
    for (final z in const [0.31, -0.31]) {
      g.dot(head(0.2, 0.12, z), 0.08 * head.size, _Colors.eye);
    }
    for (final side in const [1.0, -1.0]) {
      g.cone(
        head.child(_V(-0.15, 0.4, 0.3 * side), rx: 0.3 * side, rz: -0.3),
        0.14,
        0.45,
        _Colors.coat,
        segments: 6,
      );
      g.cylinder(
        head.child(_V(0.05, 0.55, 0.2 * side), rx: 0.3 * side, rz: 0.3),
        0.06,
        0.08,
        0.8,
        _Colors.antler,
        segments: 6,
      );
      g.cylinder(
        head.child(_V(0.15, 0.65, 0.26 * side), rz: -0.5),
        0.04,
        0.05,
        0.45,
        _Colors.antler,
        segments: 6,
      );
    }
    g.cone(
      d.child(const _V(-0.95, 1.7, 0), rz: math.pi / 3),
      0.15,
      0.4,
      _Colors.deerBelly,
      segments: 6,
    );
  }

  /// `buildMonkeyMesh()`: furry body and head with the pale belly and face
  /// showing on its front (they sit inside the fur), eyes, nose, round
  /// ears, arms and the curled tail.
  void _paintMonkey(_Gfx g, _Xf m) {
    g.sphere(
      m.child(const _V(0.25, -0.05, 0)),
      0.48,
      _Colors.monkeyFace,
      bias: 0.1,
    );
    g.sphere(m, 0.65, _Colors.fur);
    final head = m.child(const _V(0.2, 0.85, 0));
    g.sphere(
      head.child(const _V(0.24, -0.05, 0)),
      0.38,
      _Colors.monkeyFace,
      bias: 0.1,
    );
    g.sphere(head, 0.52, _Colors.fur);
    for (final z in const [0.18, -0.18]) {
      g.dot(head(0.5, 0.05, z), 0.08 * head.size, _Colors.eye);
    }
    g.dot(head(0.6, -0.08, 0), 0.06 * head.size, _Colors.monkeyNose);
    for (final z in const [-0.45, 0.45]) {
      g.cylinder(
        head.child(_V(0, 0.1, z), rx: math.pi / 2),
        0.18,
        0.18,
        0.12,
        _Colors.monkeyFace,
      );
    }
    for (final z in const [-0.35, 0.35]) {
      g.cylinder(
        m.child(_V(0.3, -0.5, z), rz: -0.5),
        0.12,
        0.1,
        0.9,
        _Colors.fur,
        segments: 8,
      );
    }
    g.cylinder(
      m.child(const _V(-0.6, -0.2, 0), rz: 1.0),
      0.08,
      0.05,
      1.4,
      _Colors.fur,
      segments: 8,
    );
    g.sphere(m.child(const _V(-1.05, 0.4, 0)), 0.1, _Colors.fur);
  }

  /// `buildBirdMesh()`: blue body with its yellow chest, head with crest,
  /// orange beak and eyes, wings and tail; drawn in front of its crown.
  void _paintBird(_Gfx g, _Xf b) {
    const lift = -_birdLift;
    g.sphere(
      b.child(const _V(0.18, -0.1, 0), sx: 1.1, sy: 0.9, sz: 0.85),
      0.42,
      _Colors.birdChest,
      bias: lift + 0.1,
    );
    g.sphere(
      b.child(_V.zero, sx: 1.35, sy: 1, sz: 0.95),
      0.48,
      _Colors.feather,
      bias: lift,
    );
    final head = b.child(const _V(0.45, 0.42, 0));
    g.sphere(head, 0.35, _Colors.feather, bias: lift);
    g.cone(
      head.child(const _V(-0.15, 0.35, 0), rz: -0.5),
      0.15,
      0.4,
      _Colors.wing,
      segments: 8,
      bias: lift,
    );
    g.cone(
      head.child(const _V(0.48, -0.05, 0), rz: -math.pi / 2),
      0.12,
      0.6,
      _Colors.beak,
      segments: 8,
      bias: lift,
    );
    for (final z in const [0.28, -0.28]) {
      g.dot(head(0.2, 0.08, z), 0.06 * head.size, _Colors.eye, bias: lift);
    }
    for (final z in const [-0.45, 0.45]) {
      g.box(
        b.child(_V(-0.1, 0.1, z), ry: z > 0 ? -0.2 : 0.2, rz: 0.2),
        const _V(0.8, 0.35, 0.14),
        _Colors.wing,
        bias: lift,
      );
    }
    g.box(
      b.child(const _V(-0.75, -0.1, 0), rz: -0.3),
      const _V(0.7, 0.08, 0.45),
      _Colors.wing,
      bias: lift,
    );
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the rain behind the hills, the hills with leaf
  /// litter, roots, trees and stumps, the gullies and washing soil, the
  /// streams with their ripples and mud, the cloud; then the rain in front.
  void _paintHillsides(_Gfx g) {
    final s = scene;
    _paintRain(g, front: false);

    // The hills (layer 1); what stands on their far side is queued before
    // them (layer 0), the rest after (layer 2).
    g.layer = 1;
    g.cone(
      _root.child(const _V(-_hillX, _leafH / 2, 0)),
      _leafR,
      _leafH,
      _Colors.leafLitter,
      segments: 48,
      bias: 0.5,
    );
    g.cone(
      _root.child(const _V(-_hillX, _hillH / 2, 0)),
      _hillR,
      _hillH,
      _Colors.forestHill,
      segments: 48,
    );
    g.cone(
      _root.child(const _V(_hillX, _hillH / 2, 0)),
      _hillR,
      _hillH,
      _Colors.bareHill,
      segments: 48,
    );

    // Trees standing on the forest hill (the HTML drops them at a fixed
    // height; here they stand on the slope).
    for (final (a, r) in s.hillTrees) {
      final base = _Scene.onSlope(-_hillX, a, r, lift: -0.05);
      g.layer = _Scene.facesCamera(a, base) ? 2 : 0;
      _paintTree(g, _Xf.at(base), _hillTreeScale);
    }
    // Roots poking out of the forest hill's front slope.
    g.layer = 2;
    for (final (dx, z, turn) in s.roots) {
      g.cylinder(
        _root.child(_V(-_hillX + dx, 1.2, z), rx: 0.5, rz: turn * 0.8),
        0.06,
        0.03,
        1.8,
        _Colors.root,
        segments: 6,
      );
    }
    // Stumps on the bare hill, their cut rings up.
    for (final (a, r) in s.stumps) {
      final base = _Scene.onSlope(_hillX, a, r);
      g.layer = _Scene.facesCamera(a, base) ? 2 : 0;
      final stump = _Xf.at(base + const _V(0, 0.2, 0));
      g.cylinder(stump, 0.35, 0.45, 0.65, _Colors.stump);
      g.disk(
        stump.child(const _V(0, 0.33, 0)),
        0.34,
        _Colors.stumpRing,
        bias: -0.01,
      );
    }
    g.layer = 2;
    if (s.gulliesShown) _paintGullies(g);
    if (s.rainActive) _paintSoil(g);
    _paintStreams(g);
    if (s.rainActive) _paintRipples(g);
    if (s.cloudShown) _paintCloud(g);
    g.flush();
    _paintRain(g, front: true);
  }

  /// Gullies carved down the bare hill's front slope (the HTML boxes stand
  /// mostly inside the cone; here they lie on the slope), growing from
  /// their middle.
  void _paintGullies(_Gfx g) {
    final s = scene;
    for (var i = 0; i < _gullyCount; i++) {
      final length = _gullyL * s.gully[i].at(s.time);
      if (length < 0.02) continue;
      final a = -math.pi / 3 + i / (_gullyCount - 1) * (2 * math.pi / 3);
      final out = _V(math.sin(a), 0, math.cos(a));
      final down = _V(out.x * _hillR, -_hillH, out.z * _hillR).unit;
      final side = _V(math.cos(a), 0, -math.sin(a));
      final normal = _V(out.x * _hillH, _hillR, out.z * _hillH).unit;
      final c =
          _root(
            _hillX + out.x * _gullyR,
            _Scene.slopeY(_gullyR),
            out.z * _gullyR,
          ) +
          normal * 0.03;
      final top = c - down * (length / 2);
      final bottom = c + down * (length / 2);
      const w = _gullyW / 2;
      g.quad(
        [
          top - side * w * 0.7,
          top + side * w * 0.7,
          bottom + side * w,
          bottom - side * w,
        ],
        _Colors.gully,
        normal,
      );
    }
  }

  /// Soil grains washing down the bare hill's slope (the ones on its far
  /// side are hidden).
  void _paintSoil(_Gfx g) {
    final s = scene;
    for (final grain in s.grains) {
      final r = _Scene.slopeR(grain.y) + 0.15;
      final p = _root(
        _hillX + math.cos(grain.angle) * r + grain.drift,
        grain.y + 0.1,
        math.sin(grain.angle) * r,
      );
      if (!_Scene.facesCamera(grain.angle, p)) continue;
      g.sphere(_Xf.at(p), 0.18, _Colors.soil);
    }
  }

  /// The two streams: the right one turns muddy brown with its mud
  /// bubbles bobbing while it rains.
  void _paintStreams(_Gfx g) {
    final s = scene;
    for (final side in const [0, 1]) {
      final cx = side == 0 ? -_hillX : _hillX;
      g.box(
        _root.child(_V(cx, _streamY, _streamZ)),
        _streamSize,
        side == 1 && s.muddy ? _Colors.muddy : _Colors.stream,
        edge: 0.15,
      );
    }
    if (!s.mudShown) return;
    for (var i = 0; i < s.mud.length; i++) {
      final (x, z) = s.mud[i];
      final bob = math.sin(s.mudTime * 8 + i * 1.3) * 0.15;
      final k = 0.8 + math.cos(s.mudTime * 10 + i) * 0.3;
      g.sphere(
        _root.scaled(_V(x, 0.25 + bob, z), k),
        0.22,
        _Colors.muddy,
        bias: -3,
      );
    }
  }

  /// Splash rings growing and fading where the rain strikes the slopes and
  /// the streams.
  void _paintRipples(_Gfx g) {
    final s = scene;
    for (final rp in s.ripples) {
      final p = _root.at(rp.at);
      if (rp.hill >= 0 && !_Scene.facesCamera(rp.angle, p)) {
        continue;
      }
      final grow = 0.3 + rp.phase / math.pi * 1.6;
      final alpha = math.max(0.0, 0.85 * (1 - rp.phase / math.pi));
      if (alpha < 0.02) continue;
      g.later(g.cam.depth(p) + (rp.hill < 0 ? -3 : -0.05), () {
        final cam = g.cam;
        final path = g.pens.path..reset();
        for (final radius in [0.38 * grow, 0.08 * grow]) {
          for (var i = 0; i <= 12; i++) {
            final t = 2 * math.pi * i / 12;
            final q = cam.p(
              p + _V(radius * math.cos(t), 0, radius * math.sin(t)),
            );
            if (i == 0) {
              path.moveTo(q.dx, q.dy);
            } else {
              path.lineTo(q.dx, q.dy);
            }
          }
          path.close();
        }
        path.fillType = PathFillType.evenOdd;
        g.canvas.drawPath(
          path,
          _pens.fill..color = _Colors.ripple.withValues(alpha: alpha),
        );
        path.fillType = PathFillType.nonZero;
      });
    }
  }

  /// `buildCloudMesh()`: the wide storm cloud over both hills.
  void _paintCloud(_Gfx g) {
    final cloud = _root.child(_cloudAt);
    g.sphere(cloud, _cloudCoreR, _Colors.cloud);
    for (var i = 0; i < _puffs.length; i++) {
      g.sphere(
        cloud.child(_puffs[i]),
        2.2 + (i % 2) * 0.5,
        i > 7 ? _Colors.cloudStorm : _Colors.cloud,
      );
    }
    for (final x in const [-5.5, 5.5]) {
      g.cylinder(
        cloud.child(_V(x, -1.2, 0)),
        4.2,
        4.5,
        0.9,
        _Colors.cloudBase,
        segments: 24,
        bias: 0.5,
      );
    }
  }

  /// Rain streaks, the ones behind the hills ([front] false: drawn before
  /// them) or in front; a streak inside a hill has landed and is hidden.
  void _paintRain(_Gfx g, {required bool front}) {
    final s = scene;
    if (!s.rainActive) return;
    final cam = g.cam;
    final paint = _pens.stroke;
    for (final d in s.drops) {
      if ((d.z >= 0) != front) continue;
      if (d.y < _Scene.hillTop(d.x, d.z)) continue;
      final top = _root(d.x, d.y + 1.1, d.z);
      final bottom = _root(d.x, d.y - 1.1, d.z);
      if (cam.depth(bottom) < _clipDepth) continue;
      paint
        ..strokeWidth = math.max(0.8, 0.12 * cam.scaleAt(bottom))
        ..color = (d.pale ? _Colors.rainB : _Colors.rainA).withValues(
          alpha: 0.95,
        );
      g.canvas.drawLine(cam.p(top), cam.p(bottom), paint);
    }
  }

  // ----------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip: the animals' names
  /// above them (they travel with them), or the hills' and streams'.
  void _paintLabels(_Gfx g) {
    final s = scene;
    final placed = <Rect>[];
    if (s.forest) {
      for (var i = 0; i < 3; i++) {
        _chipAt(
          g,
          s.animal(i)(0, _animalLabelY[i], 0),
          _t(_animalKeys[i]),
          placed,
        );
      }
    } else {
      _chipAt(g, _root(-_hillX, 7.6, 0), _t('lbl_forest_hill'), placed);
      _chipAt(g, _root(_hillX, 7.6, 0), _t('lbl_bare_hill'), placed);
      _chipAt(g, _root(-_hillX, 1.3, _streamZ), _t('lbl_clear_stream'), placed);
      _chipAt(g, _root(_hillX, 1.3, _streamZ), _t('lbl_muddy_stream'), placed);
    }
  }

  /// A chip centred on the world point [at] (skipped when it is behind the
  /// camera or off the canvas). A chip that would cover one already in
  /// [placed] (the sprites overlap on narrow screens) is lifted above it.
  void _chipAt(_Gfx g, _V at, String text, List<Rect> placed) {
    if (g.cam.depth(at) < _clipDepth) return;
    final p = g.cam.p(at);
    if (!_onCanvas(p)) return;
    final size = cache.chipSize(text);
    var rect = _clampChip(
      Rect.fromCenter(center: p, width: size.width, height: size.height),
    );
    for (var tries = 0; tries < placed.length; tries++) {
      final hit = placed.where((r) => r.overlaps(rect.inflate(1))).toList();
      if (hit.isEmpty) break;
      final top = hit.map((r) => r.top).reduce(math.min);
      rect = rect.shift(Offset(0, top - _chipGap - rect.bottom));
    }
    placed.add(rect);
    _drawChip(g, rect, text);
  }

  /// Is the design point [p] across the visible canvas? Only then is its
  /// chip drawn (and kept inside the canvas).
  bool _onCanvas(Offset p) =>
      p.dx >= scene.labelLeft && p.dx <= scene.labelRight;

  /// [rect] shifted into the visible canvas (left of the tool column).
  Rect _clampChip(Rect rect) {
    final s = scene;
    var r = rect;
    if (r.right > s.labelRight) r = r.shift(Offset(s.labelRight - r.right, 0));
    if (r.left < s.labelLeft) r = r.shift(Offset(s.labelLeft - r.left, 0));
    return r;
  }

  /// HTML `createTextSprite`: a dark slate chip with a slate border and
  /// white bold text.
  void _drawChip(_Gfx g, Rect rect, String text) {
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.27),
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
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
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
