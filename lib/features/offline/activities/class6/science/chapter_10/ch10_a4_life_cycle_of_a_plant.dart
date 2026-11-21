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

/// Class 6 Science • Chapter 10 • Activity 4
/// Life Cycle of a Plant.
///
/// Native Flutter port of `Cl6S-Ch10-A4-Life_Cycle_of_a_Plant.html`.
///
/// Scenario 1 (The Germination Experiment): four pots with garden soil and a
/// bean seed each are given different conditions (A: sunlight, no water;
/// B: sunlight, excess water; C: dark, moist soil; D: sunlight, moist soil)
/// and fast-forwarded 15 days: A stays unchanged, B rots, C comes up pale
/// and weak, D grows into a healthy green seedling.
///
/// Scenario 2 (The Life Cycle of a Bean Plant): one seed is sown in a
/// cut-away pot and followed through germination, the seedling, flowering
/// and pollination by a bee, the pod and finally the death of the plant,
/// which leaves new seeds.
///
/// Every step is a button, as in the HTML. The Three.js scenes are redrawn
/// by a CustomPainter through a perspective projection of the HTML camera
/// (fov 45°, from (0, 16, 45) in Scenario 1 and (0, 16, 35) in Scenario 2,
/// looking at the origin), zoomed and re-centred so that the whole plant
/// fits the stage and the floating cards stay clear of it.
class Ch10A4LifeCycleOfAPlantPage extends StatefulWidget {
  const Ch10A4LifeCycleOfAPlantPage({super.key});

  @override
  State<Ch10A4LifeCycleOfAPlantPage> createState() => _PlantLifeLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises `click` (every step button,
/// the sidebar, scenario change, Enter Lab) and `success` (the summary);
/// its `pop` and `grow` tones are never played. correct.mp3 / error.mp3 are
/// the shell's feedback tones ("Scenario Complete" after Continue).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// Shell feedback: "Scenario Complete! Please select the next scenario."
  correct('audio/class6/science/correct.mp3'),

  /// Shell feedback for a refused action (this lab has none of its own).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the summary popup.
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
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background: #1e293b (dark), #e2e8f0 (`setTheme`
  /// light).
  static const Color canvasDark = slate800;
  static const Color canvasLight = slate200;

  /// The bench (`BoxGeometry(36, 1.5, 18)`, 0x334155) and the pots
  /// (0xc2410c). The cut faces of the Scenario 2 pot are lighter clay.
  static const Color bench = slate700;
  static const Color pot = Color(0xFFC2410C);
  static const Color potCut = Color(0xFFEA580C);

  /// Dry garden soil 0x854d0e, moist soil 0x451a03 and the excess water
  /// (0x3b82f6, opacity 0.7) of Scenario 1.
  static const Color soilDry = Color(0xFF854D0E);
  static const Color soilMoist = Color(0xFF451A03);
  static const Color water = Color(0xFF3B82F6);

  /// Light specks in the cut soil of Scenario 2 (added).
  static const Color soilSpeck = Color(0x40FDE68A);

  /// Bean seed 0xd97706; a rotten seed turns 0x1e293b.
  static const Color seed = Color(0xFFD97706);
  static const Color seedRotten = slate800;

  /// Sun `MeshBasicMaterial(0xfacc15)` and its ray cone (0xfef08a,
  /// opacity 0.3).
  static const Color sun = Color(0xFFFACC15);
  static const Color sunRays = Color(0x4DFEF08A);

  /// The dark box over Pot C (0x92400e).
  static const Color box = Color(0xFF92400E);

  /// The pale sprout of Pot C and the radicle (0xfef08a).
  static const Color pale = Color(0xFFFEF08A);

  /// `buildPlantStructure()`: stem 0x16a34a, leaves 0x15803d; the young
  /// shoot 0x22c55e with its cotyledon 0x16a34a.
  static const Color stem = Color(0xFF16A34A);
  static const Color leaf = Color(0xFF15803D);
  static const Color shoot = Color(0xFF22C55E);
  static const Color leafVein = Color(0x8014532D);

  /// The flower: centre 0xeab308, petals 0xec4899.
  static const Color flowerCentre = Color(0xFFEAB308);
  static const Color petal = Color(0xFFEC4899);

  /// The bee: body 0xfacc15, wings white (opacity 0.7); its stripes and
  /// head are added.
  static const Color bee = Color(0xFFFACC15);
  static const Color beeDark = Color(0xFF1C1917);
  static const Color wing = Color(0xFFFFFFFF);

  /// The green pod (0x16a34a), the dead stem (0x854d0e) and the dried pod
  /// (0xa16207).
  static const Color pod = Color(0xFF16A34A);
  static const Color deadStem = Color(0xFF854D0E);
  static const Color deadPod = Color(0xFFA16207);
  static const Color podSeam = Color(0x99052E16);
  static const Color deadSeam = Color(0xB3422006);

  /// Pot letters: a white disc with `#0f172a` bold text (HTML sprite).
  static const Color letterDisc = white;
  static const Color letterText = slate900;

  /// Canvas label chips (added) and their pointer lines.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = Color(0xB310B981);
  static const Color leader = Color(0xB3FFFFFF);

  /// The cut-away outline of the front half of the Scenario 2 pot.
  static const Color ghost = Color(0x99EA580C);

  /// Soft contact shadows (the HTML enables shadow maps).
  static const Color shadow = Color(0x59000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvasDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500, // text-emerald-500, border-emerald-500
    onAccent: _Colors.slate950, // Enter Lab: text-slate-950
    primary: _Colors.teal600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66064E3B), // from-emerald-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // subtitle text-emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.emerald500,
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
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvasLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald600, // text-emerald-600 (light)
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
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66064E3B),
    curtainText: _Colors.white,
    curtainMuted: _Colors.emerald300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald500,
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
/// curtain, and `success` for the summary.
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// scenario selector uses the scenarios' own titles (the HTML options named
// two other, older scenarios). Steps say exactly which button to tap
// ("Tap" instead of "Click"); observations are shown only once their step
// is done. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Life Cycle of a Plant',
    'app_subtitle':
        'Class 6 • Living Creatures: Exploring their Characteristics',
    'sc_1_title': 'Scenario 1: The Germination Experiment',
    'sc_2_title': 'Scenario 2: The Life Cycle of a Bean Plant',
    's1_obj':
        'To investigate which of the conditions air, water and sunlight a bean seed needs in order to germinate.',
    's2_obj':
        'To observe, identify, and sequence the major stages in the life cycle of a bean plant, from a seed to a mature, fruit-bearing plant.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Setup',
    's1_a1':
        "Tap 'Setup Pots' to place 4 pots of garden soil with a bean seed in each.",
    's1_o1': 'Four pots are lined up, each with soil and a seed.',
    's1_c2': 'Pot A Condition',
    's1_a2': "Tap 'Set Pot A' to give Pot A direct sunlight but no water.",
    's1_o2': 'Sunlight is provided, but no water is added.',
    's1_c3': 'Pot B Condition',
    's1_a3': "Tap 'Set Pot B' to give Pot B direct sunlight and excess water.",
    's1_o3': 'Sunlight is provided, and excess water is added (flooding).',
    's1_c4': 'Pot C Condition',
    's1_a4':
        "Tap 'Set Pot C' to keep Pot C in complete darkness with moist soil.",
    's1_o4': 'The pot is placed under a dark box with moist soil.',
    's1_c5': 'Pot D Condition',
    's1_a5':
        "Tap 'Set Pot D' to give Pot D direct sunlight and moist soil (the control).",
    's1_o5': 'Ideal control conditions: sunlight and appropriate moisture.',
    's1_c6': 'Results (15 Days)',
    's1_a6': "Tap 'Fast Forward (15 Days)' and compare the four pots.",
    's1_o6':
        'Pot A: unchanged (no germination). Pot B: the seed rots. Pot C: a pale, weak seedling. Pot D: a healthy green seedling.',
    // Scenario 2 steps.
    's2_c1': 'Setup Ideal Conditions',
    's2_a1':
        "Tap 'Begin Life Cycle' to sow a bean seed in a pot with moist soil and sunlight.",
    's2_o1':
        'A pot with moist soil and sunlight is ready, and the seed is sown in the soil.',
    's2_c2': 'Stage II: Seed Germination',
    's2_a2': "Tap 'Germination' and watch the seed sprout.",
    's2_o2':
        'The seed coat splits, the radicle grows down and the shoot grows up.',
    's2_c3': 'Stage III: Seedling',
    's2_a3':
        "Tap 'Appearance of Leaves' and watch the seedling grow its leaves.",
    's2_o3': 'The first leaves unfold, followed by the true leaves.',
    's2_c4': 'Stage IV: Flowers',
    's2_a4': "Tap 'Appearance of Flowers' to observe blooming and pollination.",
    's2_o4': 'Small flowers bud and bloom. Pollination occurs.',
    's2_c5': 'Stage V: Fruits (Pods)',
    's2_a5': "Tap 'Appearance of Fruits' and watch the flower turn into a pod.",
    's2_o5': 'The flower petals fall, and a green bean pod grows.',
    's2_c6': 'Stage VI: Death & Seeds',
    's2_a6':
        "Tap 'Death & New Seeds' to see the plant complete its life cycle.",
    's2_o6':
        'The pod matures, the plant dies, and new bean seeds are revealed.',
    // HTML `hud-instruction` lines ("Click" → "Tap").
    's1_hud_1': "Step 1: Tap 'Setup Pots' to place 4 pots with soil and seeds.",
    's1_hud_2': "Step 2: Tap 'Set Pot A' (Sunlight, no water).",
    's1_hud_3': "Step 3: Tap 'Set Pot B' (Sunlight, excess water).",
    's1_hud_4': "Step 4: Tap 'Set Pot C' (Complete dark, moist soil).",
    's1_hud_5': "Step 5: Tap 'Set Pot D' (Control: Sunlight, moist soil).",
    's1_hud_6': "Step 6: Tap 'Fast Forward (15 Days)' to observe the results.",
    's2_hud_1':
        "Step 1: Tap 'Begin Life Cycle' to plant the seed in ideal conditions.",
    's2_hud_2': "Step 2: Tap 'Germination' to see the seed sprout.",
    's2_hud_3': "Step 3: Tap 'Appearance of Leaves' to see true leaves grow.",
    's2_hud_4':
        "Step 4: Tap 'Appearance of Flowers' to observe blooming and pollination.",
    's2_hud_5':
        "Step 5: Tap 'Appearance of Fruits' to watch the flower turn into a pod.",
    's2_hud_6':
        "Step 6: Tap 'Death & New Seeds' to see the plant complete its cycle.",
    // HTML `btnText`.
    's1_btn_1': 'Setup Pots',
    's1_btn_2': 'Set Pot A',
    's1_btn_3': 'Set Pot B',
    's1_btn_4': 'Set Pot C',
    's1_btn_5': 'Set Pot D',
    's1_btn_6': 'Fast Forward (15 Days)',
    's2_btn_1': 'Begin Life Cycle',
    's2_btn_2': 'Germination',
    's2_btn_3': 'Appearance of Leaves',
    's2_btn_4': 'Appearance of Flowers',
    's2_btn_5': 'Appearance of Fruits',
    's2_btn_6': 'Death & New Seeds',
    // HTML `btn_conclude`: re-opens the summary once a scenario is done.
    'btn_conclude': 'Observe Summary & Conclusion',
    // HTML `summary-next-msg`, shown as the current objective once done.
    'done_s1':
        'Scenario 1 Complete! Please select Scenario 2 from the sidebar to continue.',
    'done_s2':
        'Scenario 2 Complete! You have explored both scenarios in this activity.',
    // Summary popup (HTML `triggerConclusion()`); Scenario 1 also names
    // the pot that shows each point.
    'sum_s1':
        'Experiment Complete!\nA combination of water and air (not too much water) is needed for germination: the seed in dry soil (Pot A) did not germinate, and the flooded seed (Pot B) got no air and rotted. Sunlight is needed for healthy growth after germination: the seedling in the dark (Pot C) came up pale and weak, while the one in sunlight (Pot D) is healthy and green.',
    'sum_s2':
        'Life Cycle Completed!\nThe bean plant completes its journey from a single seed, through growth and reproduction, to producing the next generation of seeds!',
    // HTML `#stage-overlay` ("Current Phase"), now following the steps.
    'curr_phase': 'Current Phase',
    'phase_dormancy': 'Seed Dormancy',
    'phase_s1_done': 'After 15 Days',
    'phase_s2_1': 'Stage I: Seed Sown',
    'phase_s2_2': 'Stage II: Germination',
    'phase_s2_3': 'Stage III: Seedling',
    'phase_s2_4': 'Stage IV: Mature Flowering Plant',
    'phase_s2_5': 'Stage V: Fruits (Pods)',
    'phase_s2_6': 'Stage VI: Death & New Seeds',
    // Added: canvas captions (each pot's conditions) and part labels.
    'cap_sun': 'Sunlight',
    'cap_dark': 'Dark',
    'cap_no_water': 'No water',
    'cap_excess': 'Excess water',
    'cap_moist': 'Moist soil',
    'lbl_seed': 'Seed',
    'lbl_radicle': 'Radicle',
    'lbl_shoot': 'Shoot',
    'lbl_leaves': 'Leaves',
    'lbl_root': 'Root',
    'lbl_flower': 'Flower',
    'lbl_pod': 'Pod (fruit)',
    'lbl_new_seeds': 'New seeds',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1': 'Lab bench with four flower pots labelled A, B, C and D',
    'scene_s2': 'A cut-away flower pot on a lab bench, showing the soil inside',
  },
  'hi': {
    'app_title': 'पौधे का जीवन चक्र',
    'app_subtitle': 'कक्षा 6 • सजीव प्राणी: उनकी विशेषताओं की खोज',
    'sc_1_title': 'परिदृश्य 1: अंकुरण प्रयोग',
    'sc_2_title': 'परिदृश्य 2: सेम के पौधे का जीवन चक्र',
    's1_obj':
        'यह पता लगाना कि सेम के बीज को अंकुरित होने के लिए हवा, पानी और धूप में से किन स्थितियों की आवश्यकता होती है।',
    's2_obj':
        'सेम के पौधे के जीवन चक्र की प्रमुख अवस्थाओं को देखना, पहचानना और क्रम से लगाना, बीज से लेकर फल देने वाले परिपक्व पौधे तक।',
    's1_c1': 'सेटअप',
    's1_a1':
        "हर गमले में सेम का एक बीज रखकर बगीचे की मिट्टी वाले 4 गमले लगाने के लिए 'गमले सेट करें' पर टैप करें।",
    's1_o1': 'चार गमले एक पंक्ति में रखे हैं, हर गमले में मिट्टी और एक बीज है।',
    's1_c2': 'गमला A की स्थिति',
    's1_a2':
        "गमला A को सीधी धूप देने और पानी न देने के लिए 'गमला A सेट करें' पर टैप करें।",
    's1_o2': 'धूप दी गई है, लेकिन पानी नहीं डाला गया है।',
    's1_c3': 'गमला B की स्थिति',
    's1_a3':
        "गमला B को सीधी धूप और बहुत अधिक पानी देने के लिए 'गमला B सेट करें' पर टैप करें।",
    's1_o3': 'धूप दी गई है, और बहुत अधिक पानी डाला गया है (पानी भर गया है)।',
    's1_c4': 'गमला C की स्थिति',
    's1_a4':
        "गमला C को नम मिट्टी के साथ पूरे अंधेरे में रखने के लिए 'गमला C सेट करें' पर टैप करें।",
    's1_o4': 'नम मिट्टी वाले गमले को एक अंधेरे बॉक्स के नीचे रखा गया है।',
    's1_c5': 'गमला D की स्थिति',
    's1_a5':
        "गमला D को सीधी धूप और नम मिट्टी (नियंत्रण) देने के लिए 'गमला D सेट करें' पर टैप करें।",
    's1_o5': 'आदर्श नियंत्रण स्थिति: धूप और उचित नमी।',
    's1_c6': 'परिणाम (15 दिन)',
    's1_a6': "'तेजी से आगे (15 दिन)' पर टैप करें और चारों गमलों की तुलना करें।",
    's1_o6':
        'गमला A: कोई बदलाव नहीं (अंकुरण नहीं हुआ)। गमला B: बीज सड़ गया। गमला C: पीला और कमज़ोर नन्हा पौधा। गमला D: स्वस्थ हरा नन्हा पौधा।',
    's2_c1': 'आदर्श स्थितियाँ तैयार करना',
    's2_a1':
        "नम मिट्टी और धूप वाले गमले में सेम का बीज बोने के लिए 'जीवन चक्र शुरू करें' पर टैप करें।",
    's2_o1':
        'नम मिट्टी और धूप वाला गमला तैयार है, और बीज मिट्टी में बो दिया गया है।',
    's2_c2': 'अवस्था II: बीज का अंकुरण',
    's2_a2': "'अंकुरण' पर टैप करें और बीज को अंकुरित होते देखें।",
    's2_o2':
        'बीज का आवरण फटता है, मूलांकुर (जड़) नीचे की ओर और प्ररोह (तना) ऊपर की ओर बढ़ता है।',
    's2_c3': 'अवस्था III: नवोद्भिद (नन्हा पौधा)',
    's2_a3':
        "'पत्तियों का दिखना' पर टैप करें और नन्हे पौधे पर पत्तियाँ उगते देखें।",
    's2_o3': 'पहली पत्तियाँ खुलती हैं, उसके बाद असली पत्तियाँ आती हैं।',
    's2_c4': 'अवस्था IV: फूल',
    's2_a4':
        "फूलों का खिलना और परागण देखने के लिए 'फूलों का दिखना' पर टैप करें।",
    's2_o4': 'छोटे फूल कली से खिलते हैं। परागण होता है।',
    's2_c5': 'अवस्था V: फल (फलियाँ)',
    's2_a5': "'फलों का दिखना' पर टैप करें और फूल को फली में बदलते देखें।",
    's2_o5': 'फूल की पंखुड़ियाँ गिर जाती हैं, और सेम की एक हरी फली बढ़ती है।',
    's2_c6': 'अवस्था VI: मृत्यु और बीज',
    's2_a6':
        "पौधे को अपना जीवन चक्र पूरा करते देखने के लिए 'मृत्यु और नए बीज' पर टैप करें।",
    's2_o6':
        'फली पक जाती है, पौधा मर जाता है, और सेम के नए बीज दिखाई देते हैं।',
    's1_hud_1':
        "चरण 1: 4 गमले मिट्टी और बीजों के साथ रखने के लिए 'गमले सेट करें' पर टैप करें।",
    's1_hud_2': "चरण 2: 'गमला A सेट करें' पर टैप करें (धूप, पानी नहीं)।",
    's1_hud_3': "चरण 3: 'गमला B सेट करें' पर टैप करें (धूप, अधिक पानी)।",
    's1_hud_4': "चरण 4: 'गमला C सेट करें' पर टैप करें (अंधेरा, नम मिट्टी)।",
    's1_hud_5':
        "चरण 5: 'गमला D सेट करें' पर टैप करें (नियंत्रण: धूप, नम मिट्टी)।",
    's1_hud_6':
        "चरण 6: परिणाम देखने के लिए 'तेजी से आगे (15 दिन)' पर टैप करें।",
    's2_hud_1':
        "चरण 1: बीज को आदर्श स्थिति में बोने के लिए 'जीवन चक्र शुरू करें' पर टैप करें।",
    's2_hud_2': "चरण 2: अंकुरण देखने के लिए 'अंकुरण' पर टैप करें।",
    's2_hud_3':
        "चरण 3: असली पत्तियों को बढ़ते हुए देखने के लिए 'पत्तियों का दिखना' पर टैप करें।",
    's2_hud_4':
        "चरण 4: फूल खिलने और परागण देखने के लिए 'फूलों का दिखना' पर टैप करें।",
    's2_hud_5':
        "चरण 5: फूल को फली में बदलते हुए देखने के लिए 'फलों का दिखना' पर टैप करें।",
    's2_hud_6':
        "चरण 6: पौधे को अपना चक्र पूरा करते हुए देखने के लिए 'मृत्यु और नए बीज' पर टैप करें।",
    's1_btn_1': 'गमले सेट करें',
    's1_btn_2': 'गमला A सेट करें',
    's1_btn_3': 'गमला B सेट करें',
    's1_btn_4': 'गमला C सेट करें',
    's1_btn_5': 'गमला D सेट करें',
    's1_btn_6': 'तेजी से आगे (15 दिन)',
    's2_btn_1': 'जीवन चक्र शुरू करें',
    's2_btn_2': 'अंकुरण',
    's2_btn_3': 'पत्तियों का दिखना',
    's2_btn_4': 'फूलों का दिखना',
    's2_btn_5': 'फलों का दिखना',
    's2_btn_6': 'मृत्यु और नए बीज',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'done_s1':
        'परिदृश्य 1 पूर्ण! कृपया आगे बढ़ने के लिए साइडबार से परिदृश्य 2 चुनें।',
    'done_s2':
        'परिदृश्य 2 पूर्ण! आपने इस गतिविधि के सभी परिदृश्यों का सफलतापूर्वक अवलोकन कर लिया है।',
    'sum_s1':
        'प्रयोग पूरा हुआ!\nअंकुरण के लिए पानी और हवा (बहुत अधिक पानी नहीं) दोनों की आवश्यकता होती है: सूखी मिट्टी वाले गमले A का बीज अंकुरित नहीं हुआ, और पानी से भरे गमले B के बीज को हवा नहीं मिली, इसलिए वह सड़ गया। अंकुरण के बाद स्वस्थ वृद्धि के लिए धूप की आवश्यकता होती है: अंधेरे में रखे गमले C का नन्हा पौधा पीला और कमज़ोर निकला, जबकि धूप वाले गमले D का पौधा स्वस्थ और हरा है।',
    'sum_s2':
        'जीवन चक्र पूर्ण!\nसेम का पौधा एक बीज से लेकर वृद्धि और प्रजनन के माध्यम से, अगली पीढ़ी के बीज पैदा करने तक की अपनी यात्रा पूरी करता है!',
    'curr_phase': 'वर्तमान अवस्था',
    'phase_dormancy': 'बीज सुप्त अवस्था',
    'phase_s1_done': '15 दिन बाद',
    'phase_s2_1': 'अवस्था I: बीज बोया गया',
    'phase_s2_2': 'अवस्था II: अंकुरण',
    'phase_s2_3': 'अवस्था III: नवोद्भिद (नन्हा पौधा)',
    'phase_s2_4': 'अवस्था IV: परिपक्व फूल वाला पौधा',
    'phase_s2_5': 'अवस्था V: फल (फलियाँ)',
    'phase_s2_6': 'अवस्था VI: मृत्यु और नए बीज',
    'cap_sun': 'धूप',
    'cap_dark': 'अंधेरा',
    'cap_no_water': 'पानी नहीं',
    'cap_excess': 'बहुत अधिक पानी',
    'cap_moist': 'नम मिट्टी',
    'lbl_seed': 'बीज',
    'lbl_radicle': 'मूलांकुर',
    'lbl_shoot': 'प्ररोह',
    'lbl_leaves': 'पत्तियाँ',
    'lbl_root': 'जड़',
    'lbl_flower': 'फूल',
    'lbl_pod': 'फली (फल)',
    'lbl_new_seeds': 'नए बीज',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1': 'प्रयोगशाला की मेज़ पर A, B, C और D नाम के चार गमले',
    'scene_s2':
        'प्रयोगशाला की मेज़ पर आधा कटा गमला, जिसमें अंदर की मिट्टी दिखती है',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 6;

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('sc_${n}_title'),
        objective: t('s${n}_obj'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
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

/// HTML `camera.position.set(0, 16, 45)` (Scenario 1) and `(0, 16, 35)`
/// (Scenario 2), both looking at `controls.target` (0, 0, 0).
const _V _eyeS1 = _V(0, 16, 45);
const _V _eyeS2 = _V(0, 16, 35);
const _V _target = _V.zero;

/// How each scenario is framed on the stage: a zoom of the HTML camera
/// (like its zoom buttons) and where the look-at point lands. With the
/// sidebar collapsed the floating mission card covers the top left of the
/// stage, so Scenario 1 moves down and right (the suns stay below the card)
/// and Scenario 2 moves right; the bottom band, where the HUD sits while
/// the sidebar is open, is then free. In Scenario 2 the HTML camera left
/// the flower, the pod and the bee above the picture.
@immutable
class _Frame {
  const _Frame(this.zoom, this.center);

  final double zoom;
  final Offset center;

  static _Frame lerp(_Frame a, _Frame b, double k) => _Frame(
    a.zoom + (b.zoom - a.zoom) * k,
    Offset.lerp(a.center, b.center, k)!,
  );
}

const _Frame _s1Open = _Frame(1.2, Offset(440, 320));
const _Frame _s1Collapsed = _Frame(0.95, Offset(680, 395));
const _Frame _s2Open = _Frame(0.85, Offset(470, 390));
const _Frame _s2Collapsed = _Frame(0.85, Offset(600, 420));

/// Scenario 2 starts close to the pot, so that the sown seed, the radicle
/// and the shoot can be seen; it zooms out to the whole plant when the
/// leaves step starts (1 s).
const _Frame _s2CloseOpen = _Frame(1.5, Offset(470, 345));
const _Frame _s2CloseCollapsed = _Frame(1.45, Offset(600, 360));
const double _zoomOutSeconds = 1;

/// The scene re-frames with the sidebar (380 ms, like the sidebar).
const double _reframeSeconds = 0.38;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on a phone.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Widest pot caption (design px) before it wraps.
const double _captionMaxWidth = 120;

/// A start time that has not come (the animation has not been started).
const double _never = double.infinity;

/// HTML `DirectionalLight(0xffffff, 0.9)` at (20, 40, 20), normalised, and
/// `AmbientLight(0xffffff, 0.65)`, toned down so lit faces do not clip.
const _V _light = _V(0.4082, 0.8165, 0.4082);
const double _ambient = 0.7;
const double _diffuse = 0.4;

/// Where the key light comes from on the screen (upper right), for the
/// highlights of stems.
const Offset _screenLight = Offset(0.6, -0.8);

// ---------------------------------------------- scenario 1: four pots

/// `potObj.position.x = -12 + i * 8`.
const int _potCount = 4;
const double _potFirstX = -12;
const double _potSpacing = 8;

/// Pot `CylinderGeometry(3.0, 2.2, 5.0)` standing on the bench; soil
/// `CylinderGeometry(2.8, 2.8, 0.5)` at y 4.8 (its top at 5.05).
const double _potHeight = 5;
const double _potTopR = 3;
const double _potBottomR = 2.2;
const double _soilR = 2.8;
const double _soilTopY = 5.05;

/// Seed `SphereGeometry(0.6)` scaled (1.4, 0.8, 1.0); it drops from y 10
/// onto the soil at y 5 (1000 ms, Bounce.Out).
const _V _seedS1 = _V(0.84, 0.48, 0.6);
const double _seedDropFrom = 10;
const double _seedRestY = 5;

/// Sun `SphereGeometry(1.5)` at y 12 and its ray `ConeGeometry(3, 4)` at
/// y 9 (apex at 11, base at 7); it pops up from 0.1 (500 ms, Back.Out).
const double _sunY = 12;
const double _sunR = 1.5;
const double _raysApexY = 11;
const double _raysBaseY = 7;
const double _raysR = 3;
const double _sunMinScale = 0.1;

/// Pot C's dark box `BoxGeometry(6.5, 6.5, 6.5)` drops from y 15 to 5
/// (1000 ms, Bounce.Out).
const double _boxSize = 6.5;
const double _boxFromY = 15;
const double _boxToY = 5;

/// Pot letter sprites (scale 2, at (0, 0, 3.5)): a disc of radius 0.94.
const _V _letterAt = _V(0, 0, 3.5);
const double _letterR = 0.94;
const double _letterFont = 1.1;
const double _letterBasePx = 20;
const List<String> _potLetters = ['A', 'B', 'C', 'D'];

/// Results group at y 5: Pot C's weak sprout (`CylinderGeometry(0.1, 0.1,
/// 3)`, drawn a little thicker so it shows on a phone, with two small pale
/// seed leaves), Pot D's `buildPlantStructure(false)`; both grow in
/// 1500 ms (Quadratic.Out).
const double _sproutHeight = 3;
const double _sproutR = 0.15;

// ------------------------------------------ scenario 2: one bean plant

/// `pot2` `CylinderGeometry(4.0, 3.0, 6.0)`; the soil reaches its rim at
/// y 6. The front half of the pot is cut away (added) so the seed and the
/// radicle in the soil can be seen; wall and base 0.3 thick.
const double _pot2Height = 6;
const double _pot2TopR = 4;
const double _pot2BottomR = 3;
const double _pot2Wall = 0.3;
const double _soil2Y = 6;

/// Seed `SphereGeometry(0.8)` scaled (1.4, 0.8, 1.0). The HTML dropped it
/// from y 6 to 5, inside the opaque pot; it now falls onto the soil from
/// above (600 ms, Bounce.Out) and sinks to y 5 (500 ms).
const _V _seedS2 = _V(1.12, 0.64, 0.8);
const double _seed2From = 10.5;
const double _seed2Rest = 5;

/// Radicle: `CylinderGeometry(0.2, 0.05, 4)` growing down from the seed;
/// side roots (added) grow with the seedling.
const double _radicleLength = 4;
const double _radicleTopR = 0.2;
const double _radicleTipR = 0.05;

/// Shoot: stem `CylinderGeometry(0.2, 0.25, 3.5)` and its cotyledon
/// (`SphereGeometry(0.9)` scaled (1.4, 0.2, 0.8), 2.5 wide) at 3.5, drawn
/// as the pair of seed leaves it stands for.
const double _shootLength = 3.45;
const double _cotyledonSize = 1.0;

/// `buildPlantStructure(isMature)`: stem 5 (seedling) or 9 (mature) long,
/// radius 0.4 → 0.3; 4 or 8 leaves `SphereGeometry(1.6)` scaled (1.5,
/// 0.15, 0.8), 1.1 or 1.0 apart, 1.6 from the stem, tilted 0.2 rad. Each
/// leaf reaches from the stem (0.4) to 4.0 and is 2.56 wide; it is drawn
/// as a pointed blade there, turned 0.6 rad towards the viewer (the HTML's
/// flat ellipsoids were seen almost edge-on).
const double _seedlingLength = 5;
const double _matureLength = 9;
const double _leafCentre = 2.2;
const double _leafHalf = 1.8;
const double _leafHalfWidth = 1.28;
const double _leafTilt = 0.2;
const double _leafTurn = 0.6;

/// Flower at (0, 15, 0): centre `SphereGeometry(0.8)`, 6 petals
/// `SphereGeometry(1.2)` scaled (1.5, 0.1, 0.8) on a 1.5 ring.
const _V _flowerAt = _V(0, 15, 0);
const double _flowerCentreR = 0.8;
const _V _petalAxes = _V(1.8, 0.12, 0.96);
const double _petalRing = 1.5;
const int _petalCount = 6;

/// The flower faces up and towards the viewer (1 rad from the vertical),
/// its petals cupped up 0.35 rad: its normal and two directions across it.
const double _flowerFacing = 1;
const double _petalCup = 0.35;
final _V _flowerNormal = _V(
  0,
  math.cos(_flowerFacing),
  math.sin(_flowerFacing),
);
final _V _flowerDown = _V(0, -math.sin(_flowerFacing), math.cos(_flowerFacing));
const _V _flowerAcross = _V(1, 0, 0);

/// Petals fall 10 (1500 ms, Quadratic.In); they fade out over the last
/// 500 ms (the HTML hid them after 1 s, in mid-air).
const double _petalDrop = 8;

/// Bee: body `SphereGeometry(0.5)` scaled (1.4, 0.8, 0.8), wings (1.2, 0.1,
/// 0.6) at (0, 0.5, ±0.5). It flies from (-15, 20, 10) to the flower at
/// (0, 17, 0) (1500 ms, Quadratic.InOut) and away to (15, 25, 10)
/// (1500 ms, Quadratic.In). While it waits it bobs (HTML `animate()`:
/// `y += sin(Date.now() * 0.01) * 0.05` per frame ≈ 0.3 · sin(10 t)).
const _V _beeFrom = _V(-15, 20, 10);
const _V _beeAtFlower = _V(0, 17, 0);
const _V _beeTo = _V(15, 25, 10);
const _V _beeBody = _V(0.7, 0.4, 0.4);
const _V _beeWing = _V(0.6, 0.05, 0.3);
const double _beeBob = 0.3;
const double _beeBobRate = 10;

/// Pod `SphereGeometry(1.8)` scaled (1.2, 2.2, 1.2) at (0, 15, 0), and the
/// dead plant: stem `CylinderGeometry(0.2, 0.4, 8)` and the dried pod.
const _V _podAxes = _V(2.16, 3.96, 2.16);
const double _deadStemLength = 8;

/// New seeds `SphereGeometry(0.5)` scaled (1.4, 0.8, 1.0). The HTML moved
/// them up to y 21; they now fall out of the dried pod onto the soil behind
/// the cut (1500 ms, Bounce.Out).
const int _newSeedCount = 5;
const _V _newSeedAxes = _V(0.7, 0.4, 0.5);

/// The sun of the "ideal conditions" (added: the HTML text says the pot has
/// sunlight, but the scene had no sun), in the sky of the stage at the top
/// right (sidebar open / collapsed), clear of the labels and the cards.
const Offset _sun2Open = Offset(790, 110);
const Offset _sun2Collapsed = Offset(880, 140);
const double _sun2R = 22;

/// HTML step timings (ms): the step ends when the HTML `setTimeout`
/// calls `finishAction()`.
const List<int> _s1StepMs = [1200, 800, 800, 1200, 800, 2000];
const List<int> _s2StepMs = [1200, 2200, 1800, 3200, 3000, 2000];

/// Animation lengths (s) from the HTML tweens.
const double _dropS = 1.0;
const double _popS = 0.5;
const double _growS = 1.5;
const double _seed2FallS = 0.6;
const double _seed2SinkS = 0.5;
const double _shootDelayS = 0.5;
const double _flowerDelayS = 1.0;
const double _flowerS = 1.0;
const double _beeDelayS = 1.5;
const double _beeFlyS = 1.5;
const double _podDelayS = 1.0;
const double _podS = 1.5;
const double _petalFadeS = 0.5;
const double _beeFadeS = 0.3;

/// HTML `TWEEN.Easing.Elastic.Out(1, 0.5)`: amplitude 1, period 0.5. (The
/// HTML called the easing instead of passing it, which threw in its render
/// loop and froze the scene.)
const Curve _elastic = ElasticOutCurve(0.5);

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, zoomed by [_Frame.zoom] with
/// the look-at point at [_Frame.center].
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, _Frame frame) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, frame.center, _focal * frame.zoom, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.focal, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double _focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final double focal;

  /// Forward (`camera.getWorldDirection`), right and up.
  final _V f;
  final _V r;
  final _V u;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, (w - eye).dot(f));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }
}

/// A number eased from [from] to [to] (a TWEEN.js tween on a scalar).
@immutable
class _Ramp {
  const _Ramp(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final double from;
  final double to;
  final double start;
  final double seconds;
  final Curve curve;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * curve.transform((t - start) / seconds);
  }

  bool runningAt(double t) => seconds > 0 && t < start + seconds;
}

/// Soil of a Scenario 1 pot.
enum _Soil { dry, flooded, moist }

/// Mutable scene read by the painter every frame. Every animation is a
/// start time (scene seconds) plus the HTML tween, so a frame only has to
/// advance [time].
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; 7 once the scenario is done).
  int step = 1;

  /// HTML `isAnimating`: a step's animation is running; the step button
  /// does nothing meanwhile.
  bool busy = false;

  /// Frames are painted until this time (or while the bee bobs or the
  /// scene re-frames); a still scene is not repainted.
  double liveUntil = 0;

  /// 0 sidebar open … 1 sidebar collapsed.
  _Ramp frame = const _Ramp.still(0);

  // ------------------------------------------------------------ scenario 1
  final List<double> seedAt = List.filled(_potCount, _never);
  final List<double> sunAt = List.filled(_potCount, _never);
  final List<_Soil> soil = List.filled(_potCount, _Soil.dry);

  /// The pot's conditions are set (its caption shows).
  final List<bool> conditioned = List.filled(_potCount, false);
  double boxAt = _never;
  double resultsAt = _never;

  // ------------------------------------------------------------ scenario 2
  double sowAt = _never;
  double germAt = _never;
  double leavesAt = _never;
  double flowersAt = _never;
  double fruitAt = _never;
  double deathAt = _never;

  /// Where each new seed starts inside the pod (HTML `-1 + Math.random() *
  /// 2`).
  final List<double> newSeedLift = List.filled(_newSeedCount, 0);

  bool get done => step > _stepCount;

  /// Steps done (the stage reached in Scenario 2).
  int get completed => (step - 1).clamp(0, _stepCount);

  /// 0 … 1 progress of a tween that starts at [start] and lasts [seconds].
  double progress(double start, double seconds) =>
      ((time - start) / seconds).clamp(0.0, 1.0).toDouble();

  bool started(double start) => time >= start;

  /// The camera of the current scenario for the sidebar state (and, in
  /// Scenario 2, the zoom-out at the leaves step).
  _Cam get cam {
    final k = frameValue;
    if (scenario == 0) {
      return _Cam(_eyeS1, _target, _Frame.lerp(_s1Open, _s1Collapsed, k));
    }
    return _Cam(
      _eyeS2,
      _target,
      _Frame.lerp(
        _Frame.lerp(_s2CloseOpen, _s2CloseCollapsed, k),
        _Frame.lerp(_s2Open, _s2Collapsed, k),
        zoomOut,
      ),
    );
  }

  /// The sidebar re-framing value (0 open … 1 collapsed).
  double get frameValue => frame.at(time);

  /// Scenario 2: 0 close to the pot … 1 the whole plant.
  double get zoomOut => scenario == 0
      ? 0
      : Curves.easeInOutCubic.transform(progress(leavesAt, _zoomOutSeconds));

  /// Where the Scenario 2 sun is on the stage.
  Offset get sun2Point => Offset.lerp(_sun2Open, _sun2Collapsed, frameValue)!;

  /// The scene must be repainted this frame.
  bool get isLive =>
      time < liveUntil || frame.runningAt(time) || (scenario == 1 && beeShown);

  // ------------------------------------------------- scenario 1 readings
  // The QA flows read these through the painter.

  /// Seeds lying on the soil.
  int get seedsOnSoil => [
    for (var i = 0; i < _potCount; i++)
      if (progress(seedAt[i], _dropS) >= 1) i,
  ].length;

  bool sunShown(int i) => started(sunAt[i]);
  String soilOf(int i) => soil[i].name;

  /// Pot C's box sits over the pot.
  bool get boxDown => progress(boxAt, _dropS) >= 1 && !started(resultsAt);

  /// The 15-day results have grown in.
  bool get resultsShown => progress(resultsAt, _growS) >= 1;
  bool get seedRotten => started(resultsAt);

  // ------------------------------------------------- scenario 2 readings

  /// The seed has fallen and sunk into the soil.
  bool get seedSown => progress(sowAt + _seed2FallS, _seed2SinkS) >= 1;
  double get radicleGrowth => progress(germAt, _growS);
  double get shootGrowth =>
      started(leavesAt) ? 0 : progress(germAt + _shootDelayS, _growS);
  double get seedlingGrowth =>
      started(flowersAt) ? 0 : progress(leavesAt, _growS);
  double get matureGrowth => started(deathAt) ? 0 : progress(flowersAt, _growS);
  double get flowerOpen => started(fruitAt + _podDelayS)
      ? 0
      : progress(flowersAt + _flowerDelayS, _flowerS);
  double get podGrowth =>
      started(deathAt) ? 0 : progress(fruitAt + _podDelayS, _podS);
  bool get beeShown =>
      started(flowersAt + _beeDelayS) && !started(fruitAt + _beeFlyS);
  bool get beeAtFlower =>
      started(flowersAt + _beeDelayS + _beeFlyS) && !started(fruitAt);
  bool get plantDead => started(deathAt);
  bool get newSeedsOnSoil => progress(deathAt, _growS) >= 1;
  bool get sun2Shown => started(sowAt);

  // ------------------------------------------------- design points
  // The QA flows check that these stay on screen and under no card.

  /// Each pot's soil, where its seed lies.
  List<Offset> get potPoints => [
    for (var i = 0; i < _potCount; i++)
      cam.p(_V(_potFirstX + i * _potSpacing, _soilTopY, 0)),
  ];

  /// The top of each pot's sun.
  List<Offset> get sunTopPoints => [
    for (var i = 0; i < _potCount; i++)
      cam.p(_V(_potFirstX + i * _potSpacing, _sunY + _sunR, 0)),
  ];

  /// Pot D's seedling at its full height.
  Offset get seedlingTopPoint =>
      cam.p(_V(_potFirstX + 3 * _potSpacing, _seedRestY + _seedlingLength, 0));

  /// Scenario 2: the sown seed, the radicle's tip, the flower and the top
  /// of the pod.
  Offset get seedPoint => cam.p(const _V(0, _seed2Rest, 0));
  Offset get radicleTipPoint =>
      cam.p(const _V(0, _seed2Rest - 0.3 - _radicleLength, 0));
  Offset get flowerPoint => cam.p(_flowerAt);
  Offset get podTopPoint => cam.p(_flowerAt + _V(0, _podAxes.y, 0));

  /// HTML `#stage-text` ("Current Phase"), now following the stages.
  String get phaseKey {
    if (scenario == 0) return done ? 'phase_s1_done' : 'phase_dormancy';
    final c = completed;
    return c == 0 ? 'phase_dormancy' : 'phase_s2_$c';
  }

  /// HTML `changeScenario(sc)` (and the scene reset of `resetApp()`).
  void load(int index, math.Random rnd) {
    scenario = index;
    step = 1;
    busy = false;
    liveUntil = time + 0.3;
    seedAt.fillRange(0, _potCount, _never);
    sunAt.fillRange(0, _potCount, _never);
    soil.fillRange(0, _potCount, _Soil.dry);
    conditioned.fillRange(0, _potCount, false);
    boxAt = _never;
    resultsAt = _never;
    sowAt = _never;
    germAt = _never;
    leavesAt = _never;
    flowersAt = _never;
    fruitAt = _never;
    deathAt = _never;
    for (var k = 0; k < _newSeedCount; k++) {
      newSeedLift[k] = -1 + rnd.nextDouble() * 2;
    }
  }

  /// Starts the animations of the current step (HTML `advanceS1()` /
  /// `advanceS2()`) and returns how long the step takes (ms).
  int startStep() {
    final t = time;
    final n = step;
    if (scenario == 0) {
      switch (n) {
        case 1:
          seedAt.fillRange(0, _potCount, t);
        case 2:
          sunAt[0] = t;
          conditioned[0] = true;
        case 3:
          sunAt[1] = t;
          soil[1] = _Soil.flooded;
          conditioned[1] = true;
        case 4:
          soil[2] = _Soil.moist;
          boxAt = t;
          conditioned[2] = true;
        case 5:
          sunAt[3] = t;
          soil[3] = _Soil.moist;
          conditioned[3] = true;
        case 6:
          resultsAt = t;
      }
    } else {
      switch (n) {
        case 1:
          sowAt = t;
        case 2:
          germAt = t;
        case 3:
          leavesAt = t;
        case 4:
          flowersAt = t;
        case 5:
          fruitAt = t;
        case 6:
          deathAt = t;
      }
    }
    final ms = (scenario == 0 ? _s1StepMs : _s2StepMs)[n - 1];
    liveUntil = math.max(liveUntil, t + ms / 1000 + 0.3);
    return ms;
  }
}

class _PlantLifeLabState extends State<Ch10A4LifeCycleOfAPlantPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Label size in design pixels for the current stage scale.
  double _labelSize = _labelPx;

  /// The sidebar state the scene is framed for.
  bool _framedOpen = true;

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
    _scene.load(0, _rnd);
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
  /// frame only advances the clock and repaints while something moves.
  void _onTick(Duration elapsed) {
    final s = _scene;
    s.time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (s.isLive) _frame.value = s.time;
  }

  /// Re-frames the scene when the sidebar opens or closes.
  void _syncFrame() {
    final open = _lab.isSidebarOpen;
    if (open == _framedOpen) return;
    _framedOpen = open;
    final s = _scene;
    s.frame = _Ramp(
      s.frame.at(s.time),
      open ? 0 : 1,
      s.time,
      _reframeSeconds,
      Curves.easeInOutCubic,
    );
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)`: cancels every timer and animation and
  /// rebuilds the scene (the HTML kept the old scene, so a finished
  /// Scenario 1 showed its results again at step 1).
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index, _rnd));
    _lab.resetView(sound: false);
  }

  /// The step button (HTML `advanceS1()` / `advanceS2()`): runs the step's
  /// animation; the step ends when the HTML timeout fires, and the last one
  /// opens the summary.
  void _advance() {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done) return;
    setState(() => s.busy = true);
    final ms = s.startStep();
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step += 1;
      });
      if (s.done) _conclude(s.scenario);
    });
  }

  /// The summary popup (HTML `triggerConclusion()`: header "Success!", the
  /// scenario title and its summary).
  void _conclude(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('sc_${scenario + 1}_title'),
      body: () => _t('sum_s${scenario + 1}'),
    );
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#s1-btn-next` / `#s2-btn-next` (its label follows the step and
  /// it does nothing while the step animates); once the scenario is done,
  /// HTML `btn_conclude` re-opens the summary.
  List<LabAction> _actions() {
    final s = _scene;
    final n = s.scenario + 1;
    if (s.done) {
      return [
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.emerald600,
          foreground: _Colors.white,
          // The summary plays the HTML `success` tone.
          silent: true,
          onTap: () => _conclude(s.scenario),
        ),
      ];
    }
    return [
      LabAction(
        label: _t('s${n}_btn_${s.step}'),
        icon: Icons.play_arrow,
        color: n == 1 ? _Colors.emerald600 : _Colors.pink600,
        foreground: _Colors.white,
        enabled: !s.busy,
        highlight: !s.busy,
        onTap: _advance,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        _syncFrame();
        final p = _lab.palette;
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        final n = s.scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.local_florist,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc_1_title'), _t('sc_2_title')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          // HTML `summary-next-msg` once the scenario is done.
          instruction: s.done ? _t('done_s$n') : null,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once done.
          showHud: !s.done,
          hud: _t('s${n}_hud_${s.step.clamp(1, _stepCount)}'),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          overlays: _overlays(context, p),
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#stage-overlay` ("Current Phase"): at the top centre of the
  /// canvas, between the shell's cards (below a toast, which shows over
  /// it).
  List<Widget> _overlays(BuildContext context, LabPalette p) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    return [
      Positioned(
        key: const ValueKey('ch10a4-phase'),
        top: 10 + pad.top,
        left: inset.left,
        right: inset.right,
        child: Center(
          child: _PhaseCard(
            palette: p,
            scale: context.labScale,
            label: _t('curr_phase'),
            phase: _t(_scene.phaseKey),
          ),
        ),
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
        if (fit > 0 && fit.isFinite) {
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        return LabStage(
          designSize: _design,
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
        );
      },
    );
  }

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final done = _scene.completed;
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

/// HTML `#stage-overlay`: a clock icon, "CURRENT PHASE" and the phase.
class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.palette,
    required this.scale,
    required this.label,
    required this.phase,
  });

  final LabPalette palette;
  final double scale;
  final String label;
  final String phase;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300 * s),
      child: LabGlassCard(
        palette: p,
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        borderColor: p.accent.withValues(alpha: 0.4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.update, size: 20 * s, color: p.accentInk),
            SizedBox(width: 8 * s),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 9 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(label, 0.8),
                    ),
                  ),
                  Text(
                    phase,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 13.5 * s,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
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
  final Path path = Path();

  /// Affine transform of a leaf (column-major 4 × 4, identity elsewhere).
  final Float64List matrix = Float64List(16)
    ..[10] = 1
    ..[15] = 1;

  /// A leaf blade in unit coordinates: pointed at x = ±1, ±1 wide.
  final Path unitLeaf = Path()
    ..moveTo(-1, 0)
    ..cubicTo(-0.55, -1.2, 0.5, -1.0, 1, 0)
    ..cubicTo(0.5, 1.0, -0.55, 1.2, -1, 0)
    ..close();
}

/// What the painter makes once and reuses: pens, ellipsoid shaders, the
/// static part of each scene and the label text painters. Owned by the page
/// state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<int, Shader> _shaders = {};
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _letters = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  double _backdropFrame = -1;
  double _backdropZoom = -1;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  /// Lit-sphere gradient on the unit circle for [c] (MeshStandardMaterial
  /// look: highlight towards the key light at the upper right).
  Shader shader(Color c) => _shaders[c.toARGB32()] ??= ui.Gradient.radial(
    const Offset(0.32, -0.38),
    1.3,
    [labShade(c, 0.32), c, labShade(c, -0.48)],
    const [0, 0.42, 1],
  );

  /// Label text at the label size; [maxWidth] wraps long captions.
  TextPainter label(String text, {double scale = 1, double? maxWidth}) =>
      _labels['$text|$scale|$maxWidth'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: _Colors.white,
            fontSize: _labelSize * scale,
            fontWeight: FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth ?? double.infinity);

  /// A pot letter at [_letterBasePx] (scaled when painted).
  TextPainter letter(String text) => _letters[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.letterText,
        fontSize: _letterBasePx,
        fontWeight: FontWeight.w900,
        height: 1,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// What lies behind everything that moves: the bench and the pots
  /// (Scenario 2: the cut-away pot with its soil). Recorded again only
  /// while the scene re-frames.
  ui.Picture backdrop(_Scene scene) {
    final cached = _backdrop;
    final k = scene.frameValue;
    final zoom = scene.zoomOut;
    if (cached != null &&
        scene.scenario == _backdropScenario &&
        k == _backdropFrame &&
        zoom == _backdropZoom) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    final g = _Gfx(Canvas(recorder), scene.cam, pens, this);
    if (scene.scenario == 0) {
      _paintPotsBackdrop(g);
    } else {
      _paintCutPotBackdrop(g);
    }
    _backdropScenario = scene.scenario;
    _backdropFrame = k;
    _backdropZoom = zoom;
    return _backdrop = recorder.endRecording();
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    for (final tp in _letters.values) {
      tp.dispose();
    }
    _letters.clear();
    _shaders.clear();
    _backdrop?.dispose();
    _backdrop = null;
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

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Segments of rims and discs (smooth enough at this size).
const int _ringSides = 28;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;
  final _PaintCache cache;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
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

  /// BoxGeometry centred at [c]: the faces seen by the camera, lit, with a
  /// darker rim.
  void box(_V c, _V size, Color color, {double opacity = 1}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = c + _V(n.x * hx, n.y * hy, n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _V(k.x * hx, k.y * hy, k.z * hz)));
      }
      path.close();
      canvas.drawPath(
        path,
        pens.fill..color = _lit(color, n, opacity: opacity),
      );
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: 0.35 * opacity),
      );
    }
  }

  /// Cross-section direction at [a] radians in the x-z plane.
  static _V _dir(double a) => _V(math.cos(a), 0, math.sin(a));

  /// Upright CylinderGeometry: radius [r0] at [base], [r1] at the top, [h]
  /// high. The facets turned to the camera are lit one by one; the top is
  /// closed when it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    int sides = 28,
  }) {
    final top = base + _V.up * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir((a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final d0 = _dir(a0);
      final d1 = _dir(a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = _lit(color, n);
      canvas.drawPath(path, pens.fill..color = c);
      canvas.drawPath(path, pens.seam..color = c);
    }
    if (_V.up.dot(cam.eye - top) > 0) disc(top, r1, _lit(color, _V.up));
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

  /// A flat leaf blade centred at [c]: [ax] runs to its tip, [az] across
  /// it (both semi-axis vectors). Drawn as the unit leaf mapped by the
  /// projected axes, with a midrib when [vein].
  void leaf(_V c, _V ax, _V az, Color color, {bool vein = true}) {
    final o = cam.p(c);
    final a = cam.p(c + ax) - o;
    final d = cam.p(c + az) - o;
    if (a.distance < 0.5) return;
    final m = pens.matrix
      ..[0] = a.dx
      ..[1] = a.dy
      ..[4] = d.dx
      ..[5] = d.dy
      ..[12] = o.dx
      ..[13] = o.dy;
    canvas
      ..save()
      ..transform(m)
      ..drawPath(
        pens.unitLeaf,
        pens.blob
          ..shader = cache.shader(color)
          ..color = LabInk.black,
      )
      ..restore();
    if (!vein) return;
    canvas.drawLine(
      o - a * 0.85,
      o + a * 0.85,
      pens.stroke
        ..strokeWidth = math.max(0.6, a.distance * 0.04)
        ..color = _Colors.leafVein,
    );
  }

  /// Axis-aligned ellipsoid with semi-axes [s] at [c].
  void ellipsoid(_V c, _V s, Color color, {double opacity = 1}) => blob(
    c,
    _V(s.x, 0, 0),
    _V(0, s.y, 0),
    _V(0, 0, s.z),
    color,
    opacity: opacity,
  );

  /// Thin cylinder from [a] (radius [ra]) to [b] (radius [rb]), drawn as a
  /// tapered band with a highlight on the lit side and a shaded edge.
  void rod(
    _V a,
    _V b,
    double ra,
    double rb,
    Color color, {
    double opacity = 1,
  }) {
    if (opacity <= 0.01) return;
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.6, ra * cam.scaleAt(a));
    final wb = math.max(0.6, rb * cam.scaleAt(b));
    final paint = pens.fill..color = color.withValues(alpha: color.a * opacity);
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
          ..color = labShade(color, 0.4).withValues(alpha: 0.55 * opacity),
      )
      ..drawLine(
        pa - n * (wa * 0.72 * side),
        pb - n * (wb * 0.72 * side),
        pens.stroke
          ..strokeWidth = math.max(0.6, w * 0.3)
          ..color = labShade(color, -0.4).withValues(alpha: 0.6 * opacity),
      );
  }

  /// A dark label chip with white text; [anchor] picks the point of the
  /// chip that sits on [at].
  Rect chip(TextPainter tp, Offset at, {Alignment anchor = Alignment.center}) {
    final padX = 0.5 * tp.preferredLineHeight;
    final padY = 0.2 * tp.preferredLineHeight;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final rect = Rect.fromLTWH(
      at.dx - (anchor.x + 1) / 2 * w,
      at.dy - (anchor.y + 1) / 2 * h,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(h / 2, tp.preferredLineHeight * 0.6)),
    );
    canvas
      ..drawRRect(rr, pens.fill..color = _Colors.labelBg)
      ..drawRRect(
        rr,
        pens.stroke
          ..strokeWidth = 1
          ..color = _Colors.labelBorder,
      );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
    return rect;
  }
}

// ------------------------------------------------- static scene parts

/// Scenario 1's bench (`BoxGeometry(36, 1.5, 18)`) and the four pots with
/// their contact shadows.
void _paintPotsBackdrop(_Gfx g) {
  g.box(const _V(0, -0.75, 0), const _V(36, 1.5, 18), _Colors.bench);
  for (var i = 0; i < _potCount; i++) {
    final x = _potFirstX + i * _potSpacing;
    g
      ..shadow(x - 0.5, 0.4, _potBottomR + 0.6, _potBottomR + 0.4)
      ..cylinder(_V(x, 0, 0), _potBottomR, _potTopR, _potHeight, _Colors.pot);
  }
}

/// Outer radius of the Scenario 2 pot at height [y].
double _pot2R(double y) =>
    _pot2BottomR + (_pot2TopR - _pot2BottomR) * (y / _pot2Height);

/// Fixed pseudo-random soil specks in the cut (x across −1 … 1 of the
/// inner width, y up the soil), so the cut reads as soil.
final List<(double, double)> _specks = () {
  final rnd = math.Random(10);
  return [
    for (var i = 0; i < 46; i++)
      (rnd.nextDouble() * 2 - 1, _pot2Wall + rnd.nextDouble() * 5.4),
  ];
}();

/// Scenario 2's bench and the pot cut in half through its axis (added): the
/// back half of the soil's top, the back half of the rim, the cut face (the
/// pot wall and the soil, with specks) and a dashed outline of the front
/// half that was cut away.
void _paintCutPotBackdrop(_Gfx g) {
  final canvas = g.canvas;
  final cam = g.cam;
  g
    ..box(const _V(0, -0.75, 0), const _V(36, 1.5, 18), _Colors.bench)
    ..shadow(-0.5, -0.6, _pot2BottomR + 0.7, _pot2BottomR * 0.5);

  // Back half of the soil's top (z ≤ 0) and of the rim.
  const inner = _pot2TopR - _pot2Wall;
  final soilTop = <_V>[
    for (var i = 0; i <= _ringSides ~/ 2; i++)
      _V(
        inner * math.cos(math.pi + i * 2 * math.pi / _ringSides),
        _soil2Y,
        inner * math.sin(math.pi + i * 2 * math.pi / _ringSides),
      ),
  ];
  final rim = <_V>[
    for (var i = 0; i <= _ringSides ~/ 2; i++)
      _V(
        _pot2TopR * math.cos(math.pi + i * 2 * math.pi / _ringSides),
        _pot2Height,
        _pot2TopR * math.sin(math.pi + i * 2 * math.pi / _ringSides),
      ),
  ];
  g
    ..poly([...rim, ...soilTop.reversed], _lit(_Colors.pot, _V.up))
    ..poly(soilTop, _lit(_Colors.soilMoist, _V.up));

  // The cut face (z = 0): the clay wall and base, then the soil.
  g
    ..poly(const [
      _V(-_pot2BottomR, 0, 0),
      _V(_pot2BottomR, 0, 0),
      _V(_pot2TopR, _pot2Height, 0),
      _V(-_pot2TopR, _pot2Height, 0),
    ], _lit(_Colors.potCut, _V.front))
    ..poly([
      _V(-_pot2R(_pot2Wall) + _pot2Wall, _pot2Wall, 0),
      _V(_pot2R(_pot2Wall) - _pot2Wall, _pot2Wall, 0),
      const _V(inner, _soil2Y, 0),
      const _V(-inner, _soil2Y, 0),
    ], labShade(_Colors.soilMoist, 0.12));
  for (final (u, y) in _specks) {
    final half = _pot2R(y) - _pot2Wall - 0.2;
    final at = cam.p(_V(u * half, y, 0));
    canvas.drawCircle(
      at,
      math.max(0.8, 0.07 * cam.scaleAt(const _V(0, 3, 0))),
      g.pens.fill..color = _Colors.soilSpeck,
    );
  }
  // Edges of the cut.
  final edge = g.pens.stroke
    ..strokeWidth = 1.2
    ..color = labShade(_Colors.pot, -0.35);
  canvas
    ..drawLine(
      cam.p(const _V(-_pot2BottomR, 0, 0)),
      cam.p(const _V(-_pot2TopR, _pot2Height, 0)),
      edge,
    )
    ..drawLine(
      cam.p(const _V(_pot2BottomR, 0, 0)),
      cam.p(const _V(_pot2TopR, _pot2Height, 0)),
      edge,
    );

  // Dashed outline of the front half (rim and base), cut away.
  final ghost = g.pens.stroke
    ..strokeWidth = 1.4
    ..color = _Colors.ghost;
  for (final (r, y) in const [(_pot2TopR, _pot2Height), (_pot2BottomR, 0.0)]) {
    final path = Path();
    for (var i = 0; i <= _ringSides ~/ 2; i++) {
      final a = i * 2 * math.pi / _ringSides;
      final o = cam.p(_V(r * math.cos(a), y, r * math.sin(a)));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    labDashedPath(canvas, path, ghost, dash: 6, gap: 5);
  }
}

// ------------------------------------------------------------- painter

/// Paints the HTML Three.js scene of the current scenario: Scenario 1 the
/// four pots with their seeds, suns, water, box and results; Scenario 2 the
/// cut-away pot with the bean plant at its current stage and the bee.
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
    canvas.drawPicture(cache.backdrop(scene));
    final g = _Gfx(canvas, scene.cam, _pens, cache);
    if (scene.scenario == 0) {
      for (var i = 0; i < _potCount; i++) {
        _paintPot(g, i);
      }
    } else {
      _paintPlant(g);
    }
  }

  // ---------------------------------------------------------- scenario 1

  /// One pot's soil, sun, seed, result, box, letter and caption.
  void _paintPot(_Gfx g, int i) {
    final s = scene;
    final x = _potFirstX + i * _potSpacing;
    final soilTop = _V(x, _soilTopY, 0);

    // Soil: dry, moist, or flooded (moist soil under the water).
    switch (s.soil[i]) {
      case _Soil.dry:
        g.disc(soilTop, _soilR, _lit(_Colors.soilDry, _V.up));
      case _Soil.moist:
        g.disc(soilTop, _soilR, _lit(_Colors.soilMoist, _V.up));
      case _Soil.flooded:
        g
          ..disc(soilTop, _soilR, _lit(_Colors.soilMoist, _V.up))
          ..disc(
            soilTop + const _V(0, 0.02, 0),
            _soilR,
            _Colors.water.withValues(alpha: 0.7),
          )
          ..blob(
            soilTop + const _V(0.8, 0.05, -0.6),
            const _V(1.1, 0, 0),
            const _V(0, 0.01, 0),
            const _V(0, 0, 0.5),
            _Colors.white,
            opacity: 0.22,
          );
    }

    // The sun's rays shine down behind the seed and the seedling.
    final sun = s.sunShown(i)
        ? _sunMinScale +
              (1 - _sunMinScale) *
                  Curves.easeOutBack.transform(s.progress(s.sunAt[i], _popS))
        : 0.0;
    if (sun > 0) _paintRays(g, x, sun);

    // Seed (it falls onto the soil; at the results it rots in Pot B and
    // is replaced by the seedling in Pots C and D).
    final grown = i >= 2 && s.started(s.resultsAt);
    if (s.started(s.seedAt[i]) && !grown) {
      final y =
          _seedDropFrom +
          (_seedRestY - _seedDropFrom) *
              Curves.bounceOut.transform(s.progress(s.seedAt[i], _dropS));
      g.ellipsoid(
        _V(x, y, 0),
        _seedS1,
        i == 1 && s.seedRotten ? _Colors.seedRotten : _Colors.seed,
      );
    }
    if (grown) {
      final k =
          0.01 +
          0.99 * Curves.easeOutQuad.transform(s.progress(s.resultsAt, _growS));
      if (i == 2) {
        _paintWeakSprout(g, _V(x, _seedRestY, 0), k);
      } else {
        _paintPlantStructure(
          g,
          _V(x, _seedRestY, 0),
          k,
          length: _seedlingLength,
          leaves: 4,
          spacing: 1.1,
        );
      }
    }

    // Pot C's dark box drops over the pot; it is lifted for the results.
    if (i == 2 && s.started(s.boxAt) && !s.started(s.resultsAt)) {
      final y =
          _boxFromY +
          (_boxToY - _boxFromY) *
              Curves.bounceOut.transform(s.progress(s.boxAt, _dropS));
      g.box(_V(x, y, 0), const _V(_boxSize, _boxSize, _boxSize), _Colors.box);
    }

    if (sun > 0) _paintSun(g, _V(x, _sunY, 0), sun);
    _paintLetter(g, i, _V(x, 0, 0) + _letterAt);
    if (showLabels && s.conditioned[i]) _paintCaption(g, i, x);
  }

  /// The sun's ray cone (apex 11, base r 3 at 7), scaled about the sun.
  void _paintRays(_Gfx g, double x, double k) {
    final apex = _V(x, _sunY + (_raysApexY - _sunY) * k, 0);
    final base = _V(x, _sunY + (_raysBaseY - _sunY) * k, 0);
    final r = _raysR * k;
    final path = _pens.path..reset();
    final a = g.cam.p(apex);
    path.moveTo(a.dx, a.dy);
    for (var i = 0; i <= _ringSides ~/ 2; i++) {
      final ang = i * 2 * math.pi / _ringSides;
      final o = g.cam.p(base + _V(r * math.cos(ang), 0, r * math.sin(ang)));
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    g.canvas.drawPath(path, _pens.fill..color = _Colors.sunRays);
  }

  /// The sun (`MeshBasicMaterial`, not lit) at [at], [k] of its size.
  void _paintSun(_Gfx g, _V at, double k) =>
      _paintSunDisc(g.canvas, g.cam.p(at), _sunR * k * g.cam.scaleAt(at));

  /// A sun disc of radius [r] at [c] with a soft halo.
  void _paintSunDisc(Canvas canvas, Offset c, double r) {
    for (final (f, a) in const [(1.8, 0.08), (1.5, 0.12), (1.25, 0.2)]) {
      canvas.drawCircle(
        c,
        r * f,
        _pens.fill..color = _Colors.sun.withValues(alpha: a),
      );
    }
    canvas.drawCircle(c, r, _pens.fill..color = _Colors.sun);
  }

  /// HTML pot sprite: a white disc with the pot's letter.
  void _paintLetter(_Gfx g, int i, _V at) {
    final c = g.cam.p(at);
    final k = g.cam.scaleAt(at);
    g.canvas.drawCircle(
      c,
      _letterR * k,
      _pens.fill..color = _Colors.letterDisc,
    );
    final tp = cache.letter(_potLetters[i]);
    final f = _letterFont * k / _letterBasePx;
    g.canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(f)
      ..translate(-tp.width / 2, -tp.height / 2);
    tp.paint(g.canvas, Offset.zero);
    g.canvas.restore();
  }

  /// Added: the pot's conditions under the bench's front edge.
  void _paintCaption(_Gfx g, int i, double x) {
    final light = i == 2 ? 'cap_dark' : 'cap_sun';
    final water = switch (i) {
      0 => 'cap_no_water',
      1 => 'cap_excess',
      _ => 'cap_moist',
    };
    final tp = cache.label(
      '${_t(light)}\n${_t(water)}',
      scale: 0.92,
      maxWidth: _captionMaxWidth,
    );
    g.chip(
      tp,
      g.cam.p(_V(x, -1.5, 9)) + const Offset(0, 6),
      anchor: Alignment.topCenter,
    );
  }

  /// Pot C's result: a thin pale sprout with two small pale seed leaves.
  void _paintWeakSprout(_Gfx g, _V base, double k) {
    final top = base + _V(0, _sproutHeight * k, 0);
    g.rod(base, top, _sproutR * k, _sproutR * 0.8 * k, _Colors.pale);
    _paintSeedLeaves(g, top, k * 0.7, _Colors.pale);
  }

  /// A pair of seed leaves (cotyledons) opening in a V at [top].
  void _paintSeedLeaves(_Gfx g, _V top, double k, Color color) {
    for (final side in const [-1.0, 1.0]) {
      final ax = _V(side * math.cos(0.45), math.sin(0.45), 0) * (0.75 * k);
      g.leaf(top + ax, ax, _bladeWidth(0.45 * k), color, vein: false);
    }
  }

  /// The across-the-blade axis of a leaf, turned [_leafTurn] towards the
  /// viewer (a flat blade would be seen edge-on from the HTML camera).
  static _V _bladeWidth(double width) =>
      _V(0, -math.sin(_leafTurn), math.cos(_leafTurn)) * width;

  /// HTML `buildPlantStructure()` grown to [k] about [origin]: the stem
  /// and alternating leaves (even ones on the right tipped down 0.2 rad,
  /// odd ones on the left tipped up), each with a midrib.
  void _paintPlantStructure(
    _Gfx g,
    _V origin,
    double k, {
    required double length,
    required int leaves,
    required double spacing,
  }) {
    if (k <= 0.011) return;
    g.rod(
      origin,
      origin + _V(0, length * k, 0),
      0.4 * k,
      0.3 * k,
      _Colors.stem,
    );
    final cs = math.cos(_leafTilt), sn = math.sin(_leafTilt);
    for (var i = 0; i < leaves; i++) {
      final side = i.isEven ? 1.0 : -1.0;
      final dir = _V(side * cs, -side * sn, 0);
      g.leaf(
        origin + _V(0, (i + 1) * spacing * k, 0) + dir * (_leafCentre * k),
        dir * (_leafHalf * k),
        _bladeWidth(_leafHalfWidth * k),
        _Colors.leaf,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintPlant(_Gfx g) {
    final s = scene;
    const origin = _V(0, _soil2Y, 0);

    // The sun of the ideal conditions (added), in the sky of the stage.
    if (s.sun2Shown) {
      final k =
          _sunMinScale +
          (1 - _sunMinScale) *
              Curves.easeOutBack.transform(s.progress(s.sowAt, _popS));
      _paintSunDisc(g.canvas, s.sun2Point, _sun2R * k);
    }

    // In the cut: roots, the stem below the soil and the sown seed.
    _paintRoots(g);

    // New seeds lie on the soil behind the cut (drawn behind the stem).
    if (s.plantDead) _paintNewSeeds(g);

    // The plant above the soil.
    if (s.started(s.germAt) && !s.started(s.leavesAt)) {
      final k = Curves.easeOutQuad.transform(s.shootGrowth);
      if (k > 0) {
        final top = origin + _V(0, _shootLength * k, 0);
        g.rod(origin, top, 0.25 * k, 0.2 * k, _Colors.shoot);
        _paintSeedLeaves(g, top, _cotyledonSize * k, _Colors.stem);
      }
    }
    if (s.started(s.leavesAt) && !s.started(s.flowersAt)) {
      _paintPlantStructure(
        g,
        origin,
        0.01 + 0.99 * Curves.easeOutBack.transform(s.seedlingGrowth),
        length: _seedlingLength,
        leaves: 4,
        spacing: 1.1,
      );
    }
    if (s.started(s.flowersAt) && !s.started(s.deathAt)) {
      _paintPlantStructure(
        g,
        origin,
        0.01 + 0.99 * Curves.easeOutQuad.transform(s.matureGrowth),
        length: _matureLength,
        leaves: 8,
        spacing: 1,
      );
    }
    if (s.plantDead) {
      g
        ..rod(
          origin,
          origin + const _V(0, _deadStemLength, 0),
          0.4,
          0.2,
          _Colors.deadStem,
        )
        ..ellipsoid(_flowerAt, _podAxes, _Colors.deadPod);
      // The dried pod has split open.
      g.canvas.drawLine(
        g.cam.p(_flowerAt + const _V(0.4, 3.2, 1.8)),
        g.cam.p(_flowerAt + const _V(0.9, -3.0, 1.6)),
        _pens.stroke
          ..strokeWidth = math.max(1.0, 0.18 * g.cam.scaleAt(_flowerAt))
          ..color = _Colors.deadSeam,
      );
    }

    // The seed falling onto the soil and sinking in.
    if (s.started(s.sowAt) && !s.started(s.germAt)) {
      g.ellipsoid(_V(0, _sowY(s), 0), _seedS2, _Colors.seed);
    }

    _paintFlower(g);
    _paintPod(g);
    _paintFallingPetals(g);
    _paintBee(g);
    if (showLabels && !s.busy) _paintPartLabels(g);
  }

  /// Height of the sown seed: it falls onto the soil (Bounce.Out) and
  /// sinks to its resting depth.
  double _sowY(_Scene s) {
    final onSoil = _soil2Y + _seedS2.y;
    final fall = Curves.bounceOut.transform(s.progress(s.sowAt, _seed2FallS));
    final sink = Curves.easeInOut.transform(
      s.progress(s.sowAt + _seed2FallS, _seed2SinkS),
    );
    return _seed2From +
        (onSoil - _seed2From) * fall +
        (_seed2Rest - onSoil) * sink;
  }

  /// The radicle growing down from the seed, the side roots (added) of the
  /// seedling, the stem below the soil and the seed, whose coat splits and
  /// falls away during germination.
  void _paintRoots(_Gfx g) {
    final s = scene;
    const seed = _V(0, _seed2Rest, 0);
    final dead = s.plantDead;
    final rootColor = dead ? labShade(_Colors.deadStem, 0.25) : _Colors.pale;
    if (s.started(s.germAt)) {
      final k = 0.01 + 0.99 * Curves.easeOutQuad.transform(s.radicleGrowth);
      final from = seed - const _V(0, 0.3, 0);
      g.rod(
        from,
        from - _V(0, _radicleLength * k, 0),
        math.max(0.08, _radicleTopR * k),
        math.max(0.04, _radicleTipR * k),
        rootColor,
      );
      if (s.started(s.leavesAt)) {
        final l = Curves.easeOutQuad.transform(s.progress(s.leavesAt, _growS));
        for (final (y, side, len) in const [
          (4.0, 1.0, 1.7),
          (3.4, -1.0, 1.6),
          (2.7, 1.0, 1.3),
          (2.1, -1.0, 1.0),
        ]) {
          final a = _V(0, y, 0);
          g.rod(
            a,
            a + _V(side * 0.8, -0.6, 0) * (len * l),
            0.07,
            0.035,
            rootColor,
          );
        }
      }
      // The stem below the soil, from the seed to the surface.
      final shoot = s.started(s.leavesAt)
          ? 1.0
          : Curves.easeOutQuad.transform(s.shootGrowth);
      if (shoot > 0) {
        g.rod(
          seed + const _V(0, 0.3, 0),
          seed + _V(0, 0.3 + (_soil2Y - _seed2Rest - 0.3) * shoot, 0),
          0.22,
          0.24,
          dead ? _Colors.deadStem : _Colors.shoot,
        );
      }
    }
    // The sown seed; its coat splits and fades as it germinates.
    if (s.started(s.sowAt + _seed2FallS + _seed2SinkS)) {
      final fade = 1 - s.progress(s.germAt + 0.4, 0.8);
      if (fade > 0) {
        g.ellipsoid(seed, _seedS2, _Colors.seed, opacity: fade);
        if (s.started(s.germAt)) {
          final open = s.progress(s.germAt, 0.4);
          g.canvas.drawLine(
            g.cam.p(seed + const _V(-0.9, 0.05, 0.8)),
            g.cam.p(seed + _V(-0.9 + 1.8 * open, 0.05, 0.8)),
            _pens.stroke
              ..strokeWidth = 1.2
              ..color = _Colors.deadSeam.withValues(alpha: fade),
          );
        }
      }
    }
  }

  /// The flower at the top of the mature plant: petals behind the centre,
  /// the centre, then the petals in front. Its petals fall at the fruit
  /// step ([_paintFallingPetals]).
  void _paintFlower(_Gfx g) {
    final s = scene;
    if (!s.started(s.flowersAt + _flowerDelayS) || s.started(s.fruitAt)) {
      if (s.started(s.fruitAt) && !s.started(s.fruitAt + _podDelayS)) {
        // The centre stays until the pod appears.
        g.ellipsoid(
          _flowerAt,
          const _V(_flowerCentreR, _flowerCentreR, _flowerCentreR),
          _Colors.flowerCentre,
        );
      }
      return;
    }
    final k = 0.01 + 0.99 * Curves.easeOutBack.transform(s.flowerOpen);
    for (final front in const [false, true]) {
      for (var p = 0; p < _petalCount; p++) {
        final a = p * 2 * math.pi / _petalCount;
        if ((math.sin(a) > 0.01) != front) continue;
        _paintPetal(g, a, k, 0, 1);
      }
      if (!front) {
        g.ellipsoid(
          _flowerAt,
          const _V(_flowerCentreR, _flowerCentreR, _flowerCentreR) * k,
          _Colors.flowerCentre,
        );
      }
    }
  }

  /// One petal at angle [a] around the centre, grown to [k], [drop] below
  /// its place. The flower faces the viewer ([_flowerFacing]) and its
  /// petals cup up by [_petalCup]; the HTML's flat, upward-facing flower
  /// was seen edge-on, as a thin pink line.
  void _paintPetal(_Gfx g, double a, double k, double drop, double opacity) {
    final dir = _flowerAcross * math.cos(a) + _flowerDown * math.sin(a);
    final cs = math.cos(_petalCup), sn = math.sin(_petalCup);
    g.blob(
      _flowerAt +
          dir * (_petalRing * k) +
          _flowerNormal * (sn * _petalRing * 0.6 * k) -
          _V(0, drop, 0),
      (dir * cs + _flowerNormal * sn) * (_petalAxes.x * k),
      (_flowerNormal * cs - dir * sn) * (_petalAxes.y * k),
      _flowerNormal.cross(dir) * (_petalAxes.z * k),
      _Colors.petal,
      opacity: opacity,
    );
  }

  /// Fruit step: the petals fall (Quadratic.In) and fade out.
  void _paintFallingPetals(_Gfx g) {
    final s = scene;
    if (!s.started(s.fruitAt) || s.started(s.fruitAt + _growS)) return;
    final drop =
        _petalDrop * Curves.easeInQuad.transform(s.progress(s.fruitAt, _growS));
    final opacity =
        1 - s.progress(s.fruitAt + _growS - _petalFadeS, _petalFadeS);
    for (var p = 0; p < _petalCount; p++) {
      _paintPetal(g, p * 2 * math.pi / _petalCount, 1, drop, opacity);
    }
  }

  /// The green pod, with a seam and the bumps of the seeds inside.
  void _paintPod(_Gfx g) {
    final s = scene;
    if (!s.started(s.fruitAt + _podDelayS) || s.plantDead) return;
    final k = 0.01 + 0.99 * _elastic.transform(s.podGrowth);
    g.ellipsoid(_flowerAt, _podAxes * k, _Colors.pod);
    if (k < 0.2) return;
    g.canvas.drawLine(
      g.cam.p(_flowerAt + _V(0.3, 3.4, 1.9) * k),
      g.cam.p(_flowerAt + _V(0.8, -3.2, 1.7) * k),
      _pens.stroke
        ..strokeWidth = math.max(0.8, 0.12 * k * g.cam.scaleAt(_flowerAt))
        ..color = _Colors.podSeam,
    );
    for (final y in const [-1.9, 0.0, 1.9]) {
      g.ellipsoid(
        _flowerAt + _V(-0.45, y, 1.55) * k,
        const _V(0.75, 0.85, 0.5) * k,
        labShade(_Colors.pod, 0.12),
      );
    }
  }

  /// The pollinating bee: flies in, bobs at the flower, flies away.
  void _paintBee(_Gfx g) {
    final s = scene;
    if (!s.beeShown) return;
    final arrive = s.flowersAt + _beeDelayS + _beeFlyS;
    double bob(double t) =>
        t > arrive ? _beeBob * math.sin(_beeBobRate * (t - arrive)) : 0.0;
    final _V at;
    if (!s.started(s.fruitAt)) {
      final q = Curves.easeInOutQuad.transform(
        s.progress(s.flowersAt + _beeDelayS, _beeFlyS),
      );
      at = _V.lerp(_beeFrom, _beeAtFlower, q) + _V(0, bob(s.time), 0);
    } else {
      final from = _beeAtFlower + _V(0, bob(s.fruitAt), 0);
      final q = Curves.easeInQuad.transform(s.progress(s.fruitAt, _beeFlyS));
      at = _V.lerp(from, _beeTo, q);
    }
    final opacity = 1 - s.progress(s.fruitAt + _beeFlyS - _beeFadeS, _beeFadeS);
    // Back wing, body with stripes and head, front wing.
    g
      ..ellipsoid(
        at + const _V(0, 0.5, -0.5),
        _beeWing,
        _Colors.wing,
        opacity: 0.7 * opacity,
      )
      ..ellipsoid(at, _beeBody, _Colors.bee, opacity: opacity);
    final stripe = _pens.stroke
      ..strokeWidth = math.max(1.0, 0.16 * g.cam.scaleAt(at))
      ..color = _Colors.beeDark.withValues(alpha: 0.85 * opacity);
    for (final x in const [-0.25, 0.12]) {
      g.canvas.drawLine(
        g.cam.p(at + _V(x, 0.34, 0.15)),
        g.cam.p(at + _V(x, -0.34, 0.15)),
        stripe,
      );
    }
    g
      ..ellipsoid(
        at + const _V(0.72, 0.05, 0),
        const _V(0.28, 0.28, 0.28),
        _Colors.beeDark,
        opacity: opacity,
      )
      ..ellipsoid(
        at + const _V(0, 0.5, 0.5),
        _beeWing,
        _Colors.wing,
        opacity: 0.7 * opacity,
      );
  }

  /// New seeds fall out of the dried pod onto the soil (behind the cut).
  void _paintNewSeeds(_Gfx g) {
    final s = scene;
    final q = Curves.bounceOut.transform(s.progress(s.deathAt, _growS));
    for (var k = 0; k < _newSeedCount; k++) {
      final a = k * 0.4 * math.pi;
      final x = math.cos(a) * 2.2;
      final z = -(math.sin(a).abs() * 1.4 + 0.5);
      final fromY = _flowerAt.y + s.newSeedLift[k];
      final toY = _soil2Y + _newSeedAxes.y;
      g.ellipsoid(
        _V(x, fromY + (toY - fromY) * q, z),
        _newSeedAxes,
        _Colors.seed,
      );
    }
  }

  /// Added: names the parts that the last observation talks about.
  void _paintPartLabels(_Gfx g) {
    final s = scene;
    final labels = switch (s.completed) {
      1 => const [('lbl_seed', _V(0.8, 5, 0), _V(6.2, 4.6, 0))],
      2 => const [
        ('lbl_shoot', _V(0.3, 8.2, 0), _V(6.2, 8.8, 0)),
        ('lbl_radicle', _V(0.15, 2.6, 0), _V(6.2, 2.4, 0)),
      ],
      3 => const [
        ('lbl_leaves', _V(3.2, 6.8, 0), _V(6.6, 8.6, 0)),
        ('lbl_root', _V(0.15, 2.6, 0), _V(6.2, 2.4, 0)),
      ],
      4 => const [('lbl_flower', _V(1.4, 15, 0), _V(6.6, 15.4, 0))],
      5 => const [('lbl_pod', _V(2.0, 15.5, 0), _V(6.6, 15.4, 0))],
      6 => const [('lbl_new_seeds', _V(2.2, 6.4, -0.5), _V(6.6, 7.6, 0))],
      _ => const <(String, _V, _V)>[],
    };
    for (final (key, part, at) in labels) {
      final p = g.cam.p(part);
      final l = g.cam.p(at);
      g.canvas
        ..drawLine(
          p,
          l,
          _pens.stroke
            ..strokeWidth = 1.2
            ..color = _Colors.leader,
        )
        ..drawCircle(p, 2.2, _pens.fill..color = _Colors.leader);
      g.chip(cache.label(_t(key)), l, anchor: Alignment.centerLeft);
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
