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

/// Class 6 Science • Chapter 10 • Activity 2
/// Essential Conditions for Seed Germination.
///
/// Native Flutter port of
/// `Cl6S-Ch10-A2-Essential_Conditions_for_Seed_Germination.html` (Three.js
/// r128 + Tween.js + canvas-confetti). The Three.js lab bench is redrawn in
/// 2D by [_ScenePainter] through the HTML camera (45° field of view, from
/// (0, 18, 40) looking at the origin), re-framed for each phase so that the
/// pots, the Sunlight Zone and the grown seedlings fill the canvas; in steps
/// 5 and 6 it rises with the raised pots to look into them (the HTML camera
/// saw their rims edge-on and left the seedlings above the picture). The
/// clay pots are open at the top (the HTML's closed cylinders hid the soil
/// and the seed). The HTML's bottom dock of drag tools is a column on the
/// right of the canvas: tap a tool to use it on both pots (the HTML click),
/// or drag it and drop it on one pot.
///
/// Scenario 1 (The Thirsty Seed, water): fill Pot A and Pot D with soil from
/// the Soil Bag, sow a bean seed in each from the seed packet, water only
/// Pot D with the Watering Can (drops fall into it and its soil darkens),
/// drag both pots up into the Sunlight Zone and drag the time-lapse slider
/// from Day 1 to Day 15: the seed in the moist Pot D swells and a green
/// seedling with two leaves grows out of it, while the seed in the dry Pot A
/// does not change.
///
/// Scenario 2 (The Drowning Seed, air): Pot B is a glass beaker. Soil and
/// seeds go into Pot B and Pot D; Pot D is watered once, and holding the
/// Watering Can over Pot B for a second floods it (the water rises to the
/// brim). In the Sunlight Zone the time-lapse shows Pot D germinate while the
/// waterlogged seed in Pot B swells and turns dark: it rots without air.
///
/// Each scenario ends with 'Observe Summary & Conclusion' (the summary popup
/// with confetti). Once both scenarios are done the summary also shows the
/// HTML's 'Mastery Achieved!' text, which the HTML defined but never showed.
class Ch10A2EssentialConditionsForSeedGerminationPage extends StatefulWidget {
  const Ch10A2EssentialConditionsForSeedGerminationPage({super.key});

  @override
  State<Ch10A2EssentialConditionsForSeedGerminationPage> createState() =>
      _SeedGerminationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises four Web Audio tones in `playSound(type)`; each maps to the
/// closest bundled file: `click` (Enter Lab, a scenario change, the canvas
/// tools) → click (`science/click.mp3`); `pop` (a seed sown, a pot set down
/// in the Sunlight Zone) → pop (`science/click.mp3`); `water` (soil poured,
/// a pot watered or flooded) → water (`science/dropdown.mp3`); `success`
/// (the summary popup) → success (`math/success.mp3`). The shell plays
/// toggle (`science/dropdown.mp3`: sidebar), correct (`math/success.mp3`:
/// the shell's own positive toasts; this lab's toasts are silent, as the
/// HTML plays the action's tone instead), wrong (`science/error.mp3`: the
/// shell's error toasts, the HTML has none), scenario
/// (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML `click`: buttons, the canvas tools, a scenario change.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast ('Scenario Complete!').
  correct('audio/class6/math/success.mp3'),

  /// Shell feedback for an error toast (this lab shows none of its own).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: a seed sown, a pot set down in the Sunlight Zone.
  pop('audio/class6/science/click.mp3'),

  /// HTML `water`: soil poured into a pot, a pot watered or flooded.
  water('audio/class6/science/dropdown.mp3');

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
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color red500 = Color(0xFFEF4444);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background: #1e293b, and #e2e8f0 after `setTheme()`
  /// switches to light (the renderer itself is transparent).
  static const Color canvasDark = slate800;
  static const Color canvasLight = slate200;

  /// The bench `BoxGeometry(40, 1.5, 20)` (0x475569).
  static const Color bench = slate600;

  /// Terracotta pots (0xb45309).
  static const Color terracotta = amber700;

  /// Pot B's glass beaker (0x94a3b8, opacity 0.3, transmission 0.9).
  static const Color glass = slate400;

  /// Dry soil 0x78350f; watered or flooded soil 0x451a03.
  static const Color soilDry = Color(0xFF78350F);
  static const Color soilWet = Color(0xFF451A03);

  /// The bean seed (0xd97706); the rotting seed of Pot B turns 0x1e293b.
  static const Color seed = amber600;
  static const Color seedRotten = slate800;

  /// The seedling: stem 0x22c55e, leaves 0x16a34a.
  static const Color stem = Color(0xFF22C55E);
  static const Color leaf = Color(0xFF16A34A);

  /// A leaf's midrib (added, a little lighter than the leaf).
  static const Color leafVein = Color(0x8086EFAC);

  /// Pot B's flood water (0x3b82f6, opacity 0.7, drawn at 0.5 so that the
  /// rotting seed under it can be seen; its surface a lighter blue) and the
  /// watering-can drops (0x60a5fa, opacity 0.8).
  static const Color water = Color(0x803B82F6);
  static const Color waterTop = Color(0x7360A5FA);
  static const Color drop = Color(0xCC60A5FA);

  /// Scene label sprites (`updateSpriteText`): `rgba(15, 23, 42, 0.95)` with
  /// a #eab308 border and white text in the dark theme; white (0.95) with a
  /// #ca8a04 border and #0f172a text in the light theme.
  static const Color labelBgDark = Color(0xF20F172A);
  static const Color labelBgLight = Color(0xF2FFFFFF);
  static const Color labelBorderDark = yellow500;
  static const Color labelBorderLight = yellow600;

  /// `.sunlight-zone`: dashed #eab308 border on `rgba(234, 179, 8, 0.1)`,
  /// 0.3 while a pot is over it (`.highlight`); text-amber-400 caption.
  static const Color zoneBorder = yellow500;
  static const Color zoneFill = Color(0x1AEAB308);
  static const Color zoneHot = Color(0x4DEAB308);
  static const Color zoneText = amber400;

  /// The drag tools: soil bag (text-amber-700), seed packet (#6366f1 with a
  /// #f8fafc mark) and watering can (#3b82f6).
  static const Color bagIcon = amber700;
  static const Color seedIcon = indigo500;
  static const Color seedMark = Color(0xFFF8FAFC);
  static const Color canIcon = blue500;

  /// `.drag-tool:hover` / the tool to use now: indigo border, indigo/20.
  static const Color toolActive = Color(0x336366F1);

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
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: _Colors.slate800, // step cards dark:bg-slate-800
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvasDark, // #canvas-wrapper bg-[#1e293b]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500, // amber-500 accents
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.slate950,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.amber400,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // subtitle text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.amber500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.white,
    cardBorder: _Colors.slate200,
    canvasBg: _Colors.canvasLight, // setTheme(): #e2e8f0
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.slate950,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.amber600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.amber600,
    buttonBorder: _Colors.slate300,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
    labelText: _Colors.slate900,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font size (`--sidebar-font-size: 15px`), adjustable 12–22 px.
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
// Copied from the HTML `i18n` table and `ScenariosData` (Telugu dropped).
// The shell-generic texts (Enter Lab, Select Scenario, Mission Objective,
// Current Task, Step, Success!, the settings and canvas-tool names and the
// footer) come from the shell's `kLabCommonStrings`. The HTML's texts say
// DRAG / DROP and have no "click" to change. The HTML's summary messages
// (`summary-next-msg`) and its 'Flooded Pot B.' toast are literals in its
// script; they are marked "HTML literal". Keys marked "Added." are new
// texts (scene descriptions for screen readers).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Essential Conditions for Seed Germination',
    'app_subtitle':
        'Class 6- Living Creatures: Exploring their characteristics',
    // Sidebar accordion, popups and the dock.
    'concept_exp': 'Observation Step',
    'concept_focus': 'Task',
    'observation': 'Result',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You proved that both moisture (water) and oxygen (air) are absolutely essential conditions for healthy seed germination!',
    'btn_conclude': 'Observe Summary & Conclusion',
    'sc1_title': 'Scenario 1: The Thirsty Seed (Water)',
    'sc2_title': 'Scenario 2: The Drowning Seed (Air)',
    'tool_soil': 'Soil Bag',
    'tool_seeds': 'Bean Seeds',
    'tool_water': 'Watering Can',
    'tool_time': 'Time Lapse (Drag)',
    'sunlight_zone': 'Sunlight Zone',
    'sim_time': 'Simulation Time',
    'day_label': 'Day',
    // Scene label sprites.
    'lbl_pot_a': 'Pot A (Dry)',
    'lbl_pot_b': 'Pot B (Flooded)',
    'lbl_pot_d': 'Pot D (Moist)',
    // ScenariosData[en][1]: objective, HUD lines and summary.
    's1_obj':
        'To visually determine if water is an essential condition for a bean seed to germinate by comparing a seed in moist soil with a seed in dry soil.',
    's1_h1': 'DRAG the bag of soil and DROP it onto Pot A and Pot D.',
    's1_h2': 'DRAG the packet of bean seeds and DROP it onto Pot A and Pot D.',
    's1_h3':
        'DRAG the watering can and DROP it onto Pot D to moisten the soil.',
    's1_h4': 'DRAG both Pot A and Pot D into the Sunlight Zone at the top.',
    's1_h5':
        'DRAG the time-lapse slider from Day 1 to Day 15 to observe the changes.',
    's1_h6': 'Observe the final result and check the conclusion.',
    's1_c1':
        'Conclusion: Water is essential for germination. The seed in the moist soil grew, while the seed in the dry soil did not.',
    // ScenariosData[en][2].
    's2_obj':
        'To visually determine if air is an essential condition for a bean seed to germinate by comparing a seed in moist soil with a seed in waterlogged soil.',
    's2_h1': 'DRAG the bag of soil and DROP it onto Pot B and Pot D.',
    's2_h2': 'DRAG the packet of bean seeds and DROP it onto Pot B and Pot D.',
    's2_h3':
        'DRAG the watering can and DROP once on Pot D. Then, DROP and HOLD on Pot B until it is flooded.',
    's2_h4': 'DRAG both Pot B and Pot D into the Sunlight Zone at the top.',
    's2_h5':
        'DRAG the time-lapse slider from Day 1 to Day 15 to observe the changes.',
    's2_h6': 'Observe the final result and check the conclusion.',
    's2_c1':
        'Conclusion: Air is essential for germination. The seed in the flooded pot could not get air and rotted. Seeds need the right amount of water, not too much.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_t1_c': 'Add Soil',
    's1_t1_a': 'DRAG the bag of soil and DROP it onto Pot A and Pot D.',
    's1_t1_o': 'Both Pot A and Pot D are filled with brown soil.',
    's1_t2_c': 'Sow Seeds',
    's1_t2_a':
        'DRAG the packet of bean seeds and DROP it onto Pot A and Pot D.',
    's1_t2_o': 'A bean seed is placed in both pots.',
    's1_t3_c': 'Add Water',
    's1_t3_a': 'DRAG the watering can and DROP it onto Pot D.',
    's1_t3_o': "Pot D's soil becomes moist.",
    's1_t4_c': 'Sunlight',
    's1_t4_a': 'DRAG both Pot A and Pot D into the Sunlight Zone.',
    's1_t4_o': 'Both pots are placed under the sun.',
    's1_t5_c': 'Time-Lapse',
    's1_t5_a': 'DRAG the time-lapse slider from Day 1 to Day 15.',
    's1_t5_o': "The seed in Pot D germinates. Pot A's seed does not change.",
    's1_t6_c': 'Conclusion',
    's1_t6_a': 'Observe the final result.',
    's1_t6_o': 'Water is essential for germination.',
    // Scenario 2 steps.
    's2_t1_c': 'Add Soil',
    's2_t1_a': 'DRAG the bag of soil and DROP it onto Pot B and Pot D.',
    's2_t1_o': 'Both Pot B and Pot D are filled with brown soil.',
    's2_t2_c': 'Sow Seeds',
    's2_t2_a':
        'DRAG the packet of bean seeds and DROP it onto Pot B and Pot D.',
    's2_t2_o': 'A bean seed is placed in both pots.',
    's2_t3_c': 'Water & Flood',
    's2_t3_a': 'Water Pot D. Flood Pot B.',
    's2_t3_o': 'Pot D is moist. Pot B is waterlogged.',
    's2_t4_c': 'Sunlight',
    's2_t4_a': 'DRAG both Pot B and Pot D into the Sunlight Zone.',
    's2_t4_o': 'Both pots are placed under the sun.',
    's2_t5_c': 'Time-Lapse',
    's2_t5_a': 'DRAG the time-lapse slider from Day 1 to Day 15.',
    's2_t5_o': "Pot D germinates. Pot B's seed rots.",
    's2_t6_c': 'Conclusion',
    's2_t6_a': 'Observe the final result.',
    's2_t6_o': 'Air is essential for germination.',
    // Toasts.
    'toast_step_complete': 'Step Complete!',
    'toast_filled_soil': 'Filled pot with soil.',
    'toast_sowed_seed': 'Sowed seed in pot.',
    'toast_watered': 'Watered pot.',
    'toast_flooded': 'Flooded pot.',
    'toast_sunlight': 'Moved pot to Sunlight Zone.',
    'toast_15_days': '15 days have passed!',
    // HTML literal: the toast after holding the can over Pot B.
    'toast_flooded_b': 'Flooded Pot B.',
    // HTML literal: `summary-next-msg` of triggerConclusion().
    'next_msg_s1':
        'Scenario 1 Complete! Please select Scenario 2 from the sidebar to continue...',
    'next_msg_s2':
        'Scenario 2 Complete! You have explored both scenarios in this activity.',
    // Added: scene descriptions for screen readers.
    'scene_s1': 'A lab bench with two clay flower pots, Pot A and Pot D',
    'scene_s2':
        'A lab bench with a glass beaker, Pot B, and a clay flower pot, Pot D',
  },
  'hi': {
    'app_title': 'बीज अंकुरण के लिए आवश्यक परिस्थितियाँ',
    'app_subtitle': 'कक्षा 6- सजीव प्राणी: उनकी विशेषताओं की खोज',
    'concept_exp': 'अवलोकन चरण',
    'concept_focus': 'कार्य',
    'observation': 'परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने सिद्ध कर दिया कि बीज के स्वस्थ अंकुरण के लिए नमी (जल) और ऑक्सीजन (वायु) दोनों अत्यंत आवश्यक हैं!',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'sc1_title': 'परिदृश्य 1: प्यासा बीज (पानी)',
    'sc2_title': 'परिदृश्य 2: डूबता बीज (हवा)',
    'tool_soil': 'मिट्टी का बैग',
    'tool_seeds': 'बीज का पैकेट',
    'tool_water': 'झरना',
    'tool_time': 'समय (खींचें)',
    'sunlight_zone': 'धूप का क्षेत्र',
    'sim_time': 'सिमुलेशन समय',
    'day_label': 'दिन',
    'lbl_pot_a': 'गमला A (सूखा)',
    'lbl_pot_b': 'गमला B (डूबा हुआ)',
    'lbl_pot_d': 'गमला D (नम)',
    's1_obj':
        'सूखी मिट्टी वाले बीज और नम मिट्टी वाले बीज की तुलना करके यह देखना कि क्या पानी बीज अंकुरण के लिए आवश्यक है।',
    's1_h1': 'मिट्टी के बैग को खींचें और गमला A तथा गमला D पर छोड़ें।',
    's1_h2': 'बीज के पैकेट को खींचें और गमला A तथा गमला D पर छोड़ें।',
    's1_h3': 'झरने को खींचें और गमला D पर छोड़ें ताकि मिट्टी नम हो जाए।',
    's1_h4': "गमला A और गमला D दोनों को ऊपर 'धूप के क्षेत्र' में खींचें।",
    's1_h5': 'बदलाव देखने के लिए टाइम-लैप्स स्लाइडर को दिन 1 से 15 तक खींचें।',
    's1_h6': 'अंतिम परिणाम देखें और निष्कर्ष की जाँच करें।',
    's1_c1':
        'निष्कर्ष: पानी अंकुरण के लिए आवश्यक है। नम मिट्टी में बीज उग गया, जबकि सूखी मिट्टी में नहीं उगा।',
    's2_obj':
        'पानी में डूबे हुए बीज और नम मिट्टी वाले बीज की तुलना करके यह देखना कि क्या हवा (ऑक्सीजन) बीज अंकुरण के लिए आवश्यक है।',
    's2_h1': 'मिट्टी के बैग को खींचें और गमला B तथा गमला D पर छोड़ें।',
    's2_h2': 'बीज के पैकेट को खींचें और गमला B तथा गमला D पर छोड़ें।',
    's2_h3':
        'झरने को गमला D पर एक बार छोड़ें। फिर गमला B पर तब तक छोड़ कर रखें जब तक वह भर न जाए।',
    's2_h4': "गमला B और गमला D दोनों को ऊपर 'धूप के क्षेत्र' में खींचें।",
    's2_h5': 'बदलाव देखने के लिए टाइम-लैप्स स्लाइडर को दिन 1 से 15 तक खींचें।',
    's2_h6': 'अंतिम परिणाम देखें और निष्कर्ष की जाँच करें।',
    's2_c1':
        'निष्कर्ष: हवा अंकुरण के लिए आवश्यक है। डूबे हुए गमले के बीज को हवा नहीं मिली और वह सड़ गया। बीजों को सही मात्रा में पानी चाहिए, बहुत अधिक नहीं।',
    's1_t1_c': 'मिट्टी डालें',
    's1_t1_a': 'मिट्टी के बैग को खींचें और गमला A तथा D पर छोड़ें।',
    's1_t1_o': 'दोनों गमले मिट्टी से भर गए हैं।',
    's1_t2_c': 'बीज बोएं',
    's1_t2_a': 'बीज के पैकेट को खींचें और गमला A तथा D पर छोड़ें।',
    's1_t2_o': 'दोनों गमलों में बीज रखे गए हैं।',
    's1_t3_c': 'पानी डालें',
    's1_t3_a': 'झरने को खींचें और गमला D पर छोड़ें।',
    's1_t3_o': 'गमला D की मिट्टी नम हो गई है।',
    's1_t4_c': 'धूप',
    's1_t4_a': 'दोनों गमलों को धूप के क्षेत्र में खींचें।',
    's1_t4_o': 'दोनों गमले धूप में रखे गए हैं।',
    's1_t5_c': 'टाइम-लैप्स',
    's1_t5_a': 'स्लाइडर को दिन 1 से 15 तक खींचें।',
    's1_t5_o': 'गमला D का बीज उगता है। गमला A का बीज नहीं बदलता।',
    's1_t6_c': 'निष्कर्ष',
    's1_t6_a': 'अंतिम परिणाम देखें।',
    's1_t6_o': 'अंकुरण के लिए पानी आवश्यक है।',
    's2_t1_c': 'मिट्टी डालें',
    's2_t1_a': 'मिट्टी के बैग को खींचें और गमला B तथा D पर छोड़ें।',
    's2_t1_o': 'दोनों गमले मिट्टी से भर गए हैं।',
    's2_t2_c': 'बीज बोएं',
    's2_t2_a': 'बीज के पैकेट को खींचें और गमला B तथा D पर छोड़ें।',
    's2_t2_o': 'दोनों गमलों में बीज रखे गए हैं।',
    's2_t3_c': 'पानी और बाढ़',
    's2_t3_a': 'गमला D को पानी दें। गमला B को पानी से भरें।',
    's2_t3_o': 'गमला D नम है। गमला B पानी में डूबा है।',
    's2_t4_c': 'धूप',
    's2_t4_a': 'दोनों गमलों को धूप के क्षेत्र में खींचें।',
    's2_t4_o': 'दोनों गमले धूप में रखे गए हैं।',
    's2_t5_c': 'टाइम-लैप्स',
    's2_t5_a': 'स्लाइडर को दिन 1 से 15 तक खींचें।',
    's2_t5_o': 'गमला D उगता है। गमला B का बीज सड़ जाता है।',
    's2_t6_c': 'निष्कर्ष',
    's2_t6_a': 'अंतिम परिणाम देखें।',
    's2_t6_o': 'अंकुरण के लिए हवा आवश्यक है।',
    'toast_step_complete': 'चरण पूरा हुआ!',
    'toast_filled_soil': 'गमले में मिट्टी भर दी।',
    'toast_sowed_seed': 'गमले में बीज बो दिया।',
    'toast_watered': 'गमले में पानी डाल दिया।',
    'toast_flooded': 'गमले को पानी से भर दिया।',
    'toast_sunlight': 'गमले को धूप के क्षेत्र में रख दिया।',
    'toast_15_days': '15 दिन बीत चुके हैं!',
    // Added: Hindi for the HTML literal toast.
    'toast_flooded_b': 'गमला B पानी से भर गया।',
    'next_msg_s1':
        'परिदृश्य 1 पूर्ण! कृपया आगे बढ़ने के लिए साइडबार से परिदृश्य 2 चुनें...',
    'next_msg_s2':
        'परिदृश्य 2 पूर्ण! आपने इस गतिविधि के सभी परिदृश्यों का सफलतापूर्वक अवलोकन कर लिया है।',
    // Added.
    'scene_s1': 'प्रयोगशाला की मेज़ पर मिट्टी के दो गमले, गमला A और गमला D',
    'scene_s2':
        'प्रयोगशाला की मेज़ पर काँच का एक बीकर, गमला B, और मिट्टी का एक गमला, गमला D',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 6;

/// Scenario [index] in [lang], built from the string table.
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('sc${n}_title'),
    objective: t('s${n}_obj'),
    steps: [
      for (var i = 1; i <= _stepCount; i++)
        LabStep(
          concept: t('s${n}_t${i}_c'),
          action: t('s${n}_t${i}_a'),
          observation: t('s${n}_t${i}_o'),
        ),
    ],
  );
}

/// The two scenarios in both languages, built once from [_i18n].
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values)
    lang: [for (var i = 0; i < _scenarioCount; i++) _buildScenario(lang, i)],
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Screens shorter than this (phones in landscape) keep the dock and the
/// bottom cards clear of the HUD and get the compact mission card.
const double _compactBelow = 480;

/// Room added around a pot for a finger (logical px) and the movement that
/// turns a press into a drag (logical px).
const double _touchDp = 24;
const double _dragSlop = 8;

/// HTML `isClick`: a press shorter than 300 ms counts as a click.
const double _clickSeconds = 0.3;

/// Longest step (s) of one frame, so a stalled frame does not make the
/// confetti jump.
const double _maxFrameStep = 0.05;

// ------------------------------------------------------------------ camera
// HTML init3D(): PerspectiveCamera(45°) at (0, 18, 40), OrbitControls
// target (0, 0, 0).

const double _fovDegrees = 45;
const _V _eye = _V(0, 18, 40);
const _V _target = _V.zero;

/// Largest zoom of the HTML picture used to frame a phase.
const double _maxZoom = 2.4;

/// Steps 5 and 6: the camera rises with the pots (by the 12 they were
/// lifted), so it looks into them as it did on the bench. The HTML camera
/// stayed at y 18, where it saw the raised pots' rims edge-on (and their
/// seedlings above the picture).
const double _sunLift = _sunY;

/// Width of the day counter (logical px x UI scale), kept free of the
/// scene in steps 5 and 6.
const double _dayCardWidth = 168;

/// The scene glides to a new framing in these times (s): a new phase, or
/// the canvas changing size (the sidebar opening or closing).
const double _phaseSeconds = 1.0;
const double _reframeSeconds = 0.38;

/// Room kept around the framed objects (design px).
const double _framePad = 14;

/// Room kept free on the canvas (logical px × UI scale): the gap to the
/// cards, the dock column, the HUD band (sidebar open) and the time-lapse /
/// conclusion card.
const double _cardGap = 8;
const double _dockWidth = 92;
const double _hudBand = 76;
const double _hudBandCompact = 64;
const double _bottomCard = 74;
const double _dayCard = 58;

/// The floating mission card (sidebar collapsed): its top and, on a
/// compact screen, its tallest height as a fraction of the screen.
const double _missionTop = 12;
const double _compactCardMax = 0.55;

/// Canvas label size (design px); enlarged up to [_labelMaxBoost] when the
/// stage is drawn smaller than [_labelFullScale].
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

// ---------------------------------------------------------------- lighting
// HemisphereLight(0xffffff, 0x444444, 0.6) and DirectionalLight(0xffffff,
// 0.8) at (10, 30, 20), toned down a little so lit tops do not clip.

const _V _lightDir = _V(0.26726, 0.80178, 0.53452);
const double _hemi = 0.6;
const double _hemiGround = 0.267;
const double _direct = 0.8;
const double _lightScale = 0.85;

// ------------------------------------------------------------------- bench
// BoxGeometry(40, 1.5, 20) at y −0.75.

const double _benchHalfW = 20;
const double _benchH = 1.5;
const double _benchHalfD = 10;

// -------------------------------------------------------------------- pots
// buildPot(false): CylinderGeometry(3.4, 2.4, 6) at y 3 and the rim
// CylinderGeometry(3.7, 3.7, 0.8) at y 6. The HTML pot is a closed solid
// whose top hides the soil and the seed; here it is open at the top, with
// an opening of 3.25.

const double _potH = 6;
const double _potTopR = 3.4;
const double _potBottomR = 2.4;
const double _rimR = 3.7;
const double _rimBottom = 5.6;
const double _rimTop = 6.4;
const double _openingR = 3.25;

// buildPot(true): an open CylinderGeometry(3.6, 3.2, 7) at y 3.5 and a
// 0.4 thick base, MeshPhysicalMaterial(0x94a3b8, opacity 0.3,
// transmission 0.9).
const double _beakerH = 7;
const double _beakerTopR = 3.6;
const double _beakerBottomR = 3.2;
const double _beakerBaseH = 0.4;

/// Pots stand at x ±9 on the bench; in the Sunlight Zone at x ±5, y 12.
const double _homeX = 9;
const double _sunX = 5;
const double _sunY = 12;

/// HTML pot tweens: into the Sunlight Zone 500 ms Back.Out, back home
/// 500 ms Quadratic.Out. A tool held over a pot scales it to 1.1 (150 ms).
const double _moveSeconds = 0.5;
const double _hoverScale = 1.1;
const double _hoverSeconds = 0.15;

/// How far (world units) a pot can be dragged on the z = 0 plane.
const double _reachX = 17;
const double _reachY = 22;

// -------------------------------------------------------------------- soil
// CylinderGeometry(3.2, 2.4, 5) at y 3.2; it pours in by scale.y 0.1 → 1
// (500 ms).

const double _soilY = 3.2;
const double _soilHalfH = 2.5;
const double _soilTopR = 3.2;
const double _soilBottomR = 2.4;
const double _soilFrom = 0.1;
const double _soilSeconds = 0.5;

// -------------------------------------------------------------------- seed
// SphereGeometry(0.8) scaled (1.2, 0.8, 1.0) at y 5.8; it drops from y 8
// (500 ms Bounce.Out).

const double _seedR = 0.8;
const _V _seedShape = _V(1.2, 0.8, 1.0);
const double _seedY = 5.8;
const double _seedFrom = 8;
const double _seedSeconds = 0.5;

/// updatePlantGrowth(): Pot D's seed swells by 0.3 × progress, Pot B's by
/// 0.5 × progress and turns dark past 30 %.
const double _swellMoist = 0.3;
const double _swellFlooded = 0.5;
const double _rotFrom = 0.3;

// ------------------------------------------------------------------ sprout
// buildSeedAndSprout(): the sprout group at y 6 scales 0.01 → progress: a
// TubeGeometry (radius 0.2) along x = 0.5 sin(πt), y = 4.5 t and two leaves
// SphereGeometry(1) scaled (1.5, 0.05, 0.8). The roots (from y 5.4) grow
// inside the soil, out of sight, as in the HTML.

const double _sproutY = 6;
const double _stemLength = 4.5;
const double _stemBend = 0.5;
const double _stemR = 0.2;
const int _stemSamples = 14;
const _V _leafAxes = _V(1.5, 0.05, 0.8);
const List<_Leaf> _leaves = [
  _Leaf(_V(0.8, 4.4, 0), 0, -0.4),
  _Leaf(_V(-0.8, 4.6, 0.2), 0.2, 0.5),
];

/// Highest point of the full-grown seedling above the sprout origin.
const double _sproutTop = 5.4;

// ------------------------------------------------------------------ labels
// createTextSprite() at (0, 8, 0) in each pot group. Pot D's label rises
// above its seedling as it grows (the HTML label covered the stem).

const double _labelY = 8;
const double _labelClear = 1;

// ------------------------------------------------------------------- water
// Pot B: CylinderGeometry(3.5, 3.5, 6) at y 3.5, scale.y 0.01 → 1 (2000 ms
// when the can is held over it, 1000 ms after a click); drawn inside the
// beaker wall.

const double _waterY = 3.5;
const double _waterHalfH = 3;
const double _waterFrom = 0.01;
const double _floodHoldSeconds = 2;
const double _floodClickSeconds = 1;

/// Holding the watering can over Pot B this long (s) floods it.
const double _holdToFlood = 1;

/// animateWaterDrops(): 30 SphereGeometry(0.2) drops from y 12–15 within
/// ±2 of the pot fall to y 5.5 in 500 + 30 × i ms.
const int _dropCount = 30;
const double _dropR = 0.2;
const double _dropTop = 12;
const double _dropSpanY = 3;
const double _dropSpread = 2;
const double _dropTo = 5.5;

// ----------------------------------------------------------- sunlight zone
// HTML `.sunlight-zone` (a 450 × 160 px box at the top of the canvas, with
// ±50 px of slack for the drop): here a world box around the pots' places
// in the sun.

const double _zoneHalfW = 9.6;
const double _zoneBottom = 9.9;
const double _zoneTop = 21.2;
const double _zoneSlack = 40;
const double _zoneRadius = 20;

// -------------------------------------------------------------- time-lapse
// `#time-slider` (1 … 15): growth progress = (day − 1) / 14, eased over a
// quarter second here.

const int _days = 15;
const double _growSeconds = 0.25;

// ----------------------------------------------------------------- timings

/// autoApplyTool(): the second pot follows 300 ms later; Pot B floods
/// 500 ms after Pot D is watered.
const Duration _secondPotDelay = Duration(milliseconds: 300);
const Duration _floodDelay = Duration(milliseconds: 500);

// ---------------------------------------------------------------- confetti
// confetti({particleCount: 80, spread: 70, origin: {y: 0.6}}): start
// velocity 45, decay 0.9 per tick, gravity 3 px per tick, 200 ticks of
// 1/60 s.

const double _fps = 60;
const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;
const int _burstCount = 80;
const double _burstSpread = 70;
const double _burstOriginY = 0.6;

// ------------------------------------------------------------------ 3D math

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
  _V operator *(double k) => _V(x * k, y * k, z * k);
  _V operator -() => _V(-x, -y, -z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }
}

/// A leaf of the seedling: its centre in the sprout group and its Euler
/// turns about x and z (radians).
@immutable
class _Leaf {
  const _Leaf(this.center, this.rx, this.rz);

  final _V center;
  final double rx;
  final double rz;

  /// [v] (leaf coordinates) turned like the leaf (Three.js order 'XYZ':
  /// the z turn first, then the x turn).
  _V turn(_V v) {
    final cz = math.cos(rz), sz = math.sin(rz);
    final x1 = v.x * cz - v.y * sz;
    final y1 = v.x * sz + v.y * cz;
    final cx = math.cos(rx), sx = math.sin(rx);
    return _V(x1, y1 * cx - v.z * sx, y1 * sx + v.z * cx);
  }
}

/// A framing of the stage: the HTML camera raised by [lift] world units
/// (camera and look-at point together), its picture scaled by [k] about the
/// stage origin and moved by ([dx], [dy]) design px.
@immutable
class _View {
  const _View(this.dx, this.dy, this.k, [this.lift = 0]);

  static const _View identity = _View(0, 0, 1);

  final double dx;
  final double dy;
  final double k;
  final double lift;

  static _View lerp(_View a, _View b, double t) => _View(
    a.dx + (b.dx - a.dx) * t,
    a.dy + (b.dy - a.dy) * t,
    a.k + (b.k - a.k) * t,
    a.lift + (b.lift - a.lift) * t,
  );

  bool closeTo(_View o) =>
      (dx - o.dx).abs() < 0.5 &&
      (dy - o.dy).abs() < 0.5 &&
      (k - o.k).abs() < 0.002 &&
      (lift - o.lift).abs() < 0.01;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45°) as a
/// pinhole projection onto the design stage, framed by a [_View].
@immutable
class _Cam {
  _Cam(_View v)
    : center = Offset(
        _design.width / 2 * v.k + v.dx,
        _design.height / 2 * v.k + v.dy,
      ),
      focal = _focal * v.k,
      eye = _eye + _V(0, v.lift, 0);

  /// Forward, right and up of the camera.
  static final _V _f = (_target - _eye).unit;
  static final _V _r = _f.cross(_V.up).unit;
  static final _V _u = _r.cross(_f);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double _focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  /// Where the look-at point is drawn, the framed focal length and the
  /// camera position.
  final Offset center;
  final double focal;
  final _V eye;

  _V get forward => _f;
  _V get right => _r;
  _V get up => _u;

  /// Distance of [w] in front of the camera.
  double depth(_V w) => (w - eye).dot(_f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  /// Where [w] is drawn on the stage.
  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(_f));
    return Offset(center.dx + d.dot(_r) * k, center.dy - d.dot(_u) * k);
  }

  /// Faces with normal [n] at [at] turned towards the camera.
  bool facing(_V n, _V at) => n.dot(eye - at) > 0;

  /// The point of the plane z = [z] under the stage point [s] (HTML
  /// `raycaster.ray.intersectPlane`), or null when the ray misses it.
  _V? onPlaneZ(Offset s, [double z = 0]) {
    final a = (s.dx - center.dx) / focal;
    final b = -(s.dy - center.dy) / focal;
    final dir = _f + _r * a + _u * b;
    if (dir.z.abs() < 1e-9) return null;
    final t = (z - eye.z) / dir.z;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Stage bounds of the world box from [min] to [max].
  Rect boxRect(_V min, _V max) {
    Rect? r;
    for (final x in [min.x, max.x]) {
      for (final y in [min.y, max.y]) {
        for (final z in [min.z, max.z]) {
          final q = p(_V(x, y, z));
          final dot = Rect.fromLTWH(q.dx, q.dy, 0, 0);
          r = r == null ? dot : r.expandToInclude(dot);
        }
      }
    }
    return r!;
  }
}

/// MeshStandardMaterial look of [c] on a face with normal [n] under the
/// HTML lights: the hemisphere light (white sky, 0x444444 ground) plus the
/// directional light's Lambert term.
Color _lit(Color c, _V n, {double opacity = 1}) {
  final sky = (n.y + 1) / 2;
  final hemi = _hemi * (_hemiGround + (1 - _hemiGround) * sky);
  final k = (hemi + _direct * math.max(0.0, n.dot(_lightDir))) * _lightScale;
  return Color.from(
    alpha: c.a * opacity,
    red: (c.r * k).clamp(0.0, 1.0),
    green: (c.g * k).clamp(0.0, 1.0),
    blue: (c.b * k).clamp(0.0, 1.0),
  );
}

// ------------------------------------------------------------------ easing
// Tween.js easing functions used by the HTML.

typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => t * (2 - t);

/// `TWEEN.Easing.Back.Out`.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// `TWEEN.Easing.Bounce.Out`.
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

/// Ease in and out, for the camera glides (added).
double _inOut(double t) => Curves.easeInOutCubic.transform(t);

/// A number eased from [from] to [to] (a Tween.js tween on a scalar), read
/// at the scene time.
@immutable
class _Ramp {
  const _Ramp(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.ease = _linear,
  ]);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0,
      ease = _linear;

  final double from;
  final double to;
  final double start;
  final double seconds;
  final _Ease ease;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * ease((t - start) / seconds);
  }

  /// A new tween from the value at [now] to [target] (`new TWEEN.Tween(o)
  /// .to(…)` starts from the current value).
  _Ramp toward(double target, double now, double secs, [_Ease e = _linear]) =>
      _Ramp(at(now), target, now, secs, e);
}

// -------------------------------------------------------------- scene model

/// The HTML `.drag-tool`s of the dock; each is enabled in its own step.
enum _Tool {
  soil('tool_soil'),
  seed('tool_seeds'),
  water('tool_water');

  const _Tool(this.labelKey);

  final String labelKey;

  /// The step that uses the tool (HTML `updateUI()` disables it in others).
  int get step => index + 1;
}

/// The pots: HTML `userData.id`, the label sprite, the side of the bench
/// and whether it is the glass beaker (Pot B).
enum _PotId {
  a('POTA', 'lbl_pot_a', -1, false),
  b('POTB', 'lbl_pot_b', -1, true),
  d('POTD', 'lbl_pot_d', 1, false);

  const _PotId(this.tag, this.labelKey, this.side, this.glass);

  /// HTML `pid.toUpperCase()`, the toasts' prefix.
  final String tag;
  final String labelKey;

  /// −1 left, 1 right.
  final double side;
  final bool glass;

  double get homeX => side * _homeX;
  double get sunX => side * _sunX;
}

/// What the scene is framed on: the pots on the bench (steps 1–3), the
/// bench with the Sunlight Zone (step 4) or the pots in the sun with their
/// seedlings (steps 5–6).
enum _Phase { bench, zone, sun }

/// One pot (HTML `potAGrp` / `potBGrp` / `potDGrp` / `potD2Grp` and its
/// soil, seed, sprout and water) and the HTML `State` flags about it.
class _Pot {
  _Pot(this.id) : x = _Ramp.still(id.homeX);

  final _PotId id;

  /// HTML `State.filledSoil`, `sownSeeds`, `watered`, `flooded` and
  /// `inSunlight`. [wet] is the darkened soil colour.
  bool soil = false;
  bool seed = false;
  bool watered = false;
  bool flooded = false;
  bool inSun = false;
  bool wet = false;

  /// Pot B's water is rising.
  bool flooding = false;

  /// soil.scale.y (0 while the soil is hidden).
  _Ramp fill = const _Ramp.still(0);

  /// seed.position.y.
  _Ramp seedY = const _Ramp.still(_seedY);

  /// The group's scale while a tool hovers over it.
  _Ramp hover = const _Ramp.still(1);

  /// The group's position on the z = 0 plane.
  _Ramp x;
  _Ramp y = const _Ramp.still(0);

  /// Pot B's water level (scale.y, 0 while hidden).
  _Ramp water = const _Ramp.still(0);

  /// Where the finger holds the pot (z = 0 plane), while it is dragged.
  Offset? held;

  bool get glass => id.glass;

  /// The group's position at [t].
  _V at(double t) {
    final h = held;
    return h != null ? _V(h.dx, h.dy, 0) : _V(x.at(t), y.at(t), 0);
  }

  /// HTML `new TWEEN.Tween(pot.position).to({x, y}, 500)`.
  void moveTo(double tx, double ty, double now, _Ease ease) {
    final p = at(now);
    held = null;
    x = _Ramp(p.x, tx, now, _moveSeconds, ease);
    y = _Ramp(p.y, ty, now, _moveSeconds, ease);
  }

  /// Hover scale towards [target] (150 ms).
  void hoverTo(double target, double now) {
    if (hover.to == target) return;
    hover = hover.toward(target, now, _hoverSeconds);
  }
}

/// One watering-can drop (HTML `waterDrops` child): falls straight down.
@immutable
class _Drop {
  const _Drop(this.from, this.start, this.seconds);

  final _V from;
  final double start;
  final double seconds;

  /// Where the drop is at [t], or null before or after its fall.
  _V? at(double t) {
    final k = (t - start) / seconds;
    if (k < 0 || k >= 1) return null;
    return _V(from.x, from.y + (_dropTo - from.y) * k, from.z);
  }
}

/// One confetti piece (canvas-confetti `fetti`), in canvas pixels.
class _Confetto {
  _Confetto({
    required this.x,
    required this.y,
    required this.angle,
    required this.velocity,
    required this.color,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tilt,
  });

  double x;
  double y;
  final double angle;
  double velocity;
  final Color color;
  double wobble;
  final double wobbleSpeed;
  double tilt;
  double tick = 0;
}

/// canvas-confetti for the summary popup: pieces fly, slow down, fall and
/// fade over 200 ticks.
class _Confetti {
  final List<_Confetto> pieces = [];
  final math.Random _rnd = math.Random(5);

  /// Canvas size the pieces are placed in (logical px).
  Size size = _design;
  double _ticks = 0;

  /// `confetti({particleCount, spread, origin})`, fired upwards.
  void burst() {
    const a = math.pi / 2;
    const s = _burstSpread * math.pi / 180;
    for (var k = 0; k < _burstCount; k++) {
      pieces.add(
        _Confetto(
          x: 0.5 * size.width,
          y: _burstOriginY * size.height,
          angle: -a + 0.5 * s - _rnd.nextDouble() * s,
          velocity: _confettiStart * 0.5 + _rnd.nextDouble() * _confettiStart,
          color: _Colors.confetti[_rnd.nextInt(_Colors.confetti.length)],
          wobble: _rnd.nextDouble() * 10,
          wobbleSpeed: math.min(0.11, _rnd.nextDouble() * 0.1 + 0.05),
          tilt: (_rnd.nextDouble() * 0.5 + 0.25) * math.pi,
        ),
      );
    }
  }

  /// Advances the pieces by [dt] seconds (60 ticks a second).
  void update(double dt) {
    if (pieces.isEmpty) return;
    _ticks += dt * _fps;
    while (_ticks >= 1) {
      _ticks -= 1;
      for (final c in pieces) {
        c
          ..x += math.cos(c.angle) * c.velocity
          ..y += math.sin(c.angle) * c.velocity + _confettiGravity
          ..velocity *= _confettiDecay
          ..wobble += c.wobbleSpeed
          ..tilt += 0.1
          ..tick += 1;
      }
      pieces.removeWhere((c) => c.tick >= _confettiTicks);
    }
  }

  void clear() {
    pieces.clear();
    _ticks = 0;
  }
}

/// Mutable scene read by the painter every frame (HTML `State` plus the
/// Three.js objects' animated values). Every tween is a [_Ramp] read at
/// [time].
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1 … 6).
  int step = 1;

  /// The time-lapse day (`#time-slider`, 1 … 15) and the eased growth
  /// progress it gives (0 … 1).
  int day = 1;
  _Ramp growth = const _Ramp.still(0);

  /// Pot A (Scenario 1) or Pot B (Scenario 2), and Pot D.
  _Pot left = _Pot(_PotId.a);
  _Pot right = _Pot(_PotId.d);

  /// HTML `waterDrops` falling into Pot D.
  final List<_Drop> drops = [];
  final math.Random _rnd = math.Random(4);

  /// HTML `hoveredPot`: the pot a dragged tool is over, and since when the
  /// can has been held over Pot B (HTML `toolDragStartTime`).
  _PotId? hovered;
  double? holdSince;

  /// HTML `.sunlight-zone.highlight`: a dragged pot is over the zone.
  bool zoneHot = false;

  final _Confetti confetti = _Confetti();

  // ------------------------------------------------------------- framing
  _View _viewFrom = _View.identity;
  _View _viewTo = _View.identity;
  double _viewStart = 0;
  double _viewSeconds = 0;

  /// The next framing is taken at once (first layout, Enter Lab).
  bool snapView = true;

  /// The framing at this moment.
  _View get view {
    if (_viewSeconds <= 0) return _viewTo;
    final k = ((time - _viewStart) / _viewSeconds).clamp(0.0, 1.0);
    return _View.lerp(_viewFrom, _viewTo, _inOut(k));
  }

  /// Glides to [target] in [seconds] (at once while [snapView]).
  void aimView(_View target, double seconds) {
    if (snapView) {
      _viewFrom = target;
      _viewTo = target;
      _viewSeconds = 0;
      snapView = false;
      return;
    }
    if (_viewTo.closeTo(target)) return;
    _viewFrom = view;
    _viewTo = target;
    _viewStart = time;
    _viewSeconds = seconds;
  }

  /// The camera at this moment.
  _Cam get cam => _Cam(view);

  List<_Pot> get pots => [left, right];

  /// The pot with [id] in this scenario, or null.
  _Pot? pot(_PotId id) =>
      id == right.id ? right : (id == left.id ? left : null);

  _Phase get phase =>
      step <= 3 ? _Phase.bench : (step == 4 ? _Phase.zone : _Phase.sun);

  /// Growth progress of the seedlings at this moment.
  double get progress => growth.at(time);

  /// HTML `changeScenario(id)` → `resetApp()`.
  void load(int index) {
    scenario = index;
    step = 1;
    day = 1;
    growth = const _Ramp.still(0);
    left = _Pot(index == 0 ? _PotId.a : _PotId.b);
    right = _Pot(_PotId.d);
    drops.clear();
    hovered = null;
    holdSince = null;
    zoneHot = false;
  }

  /// HTML `animateWaterDrops(pos)`.
  void rain(_V at) {
    drops
      ..clear()
      ..addAll([
        for (var i = 0; i < _dropCount; i++)
          _Drop(
            _V(
              at.x + _rnd.nextDouble() * 2 * _dropSpread - _dropSpread,
              _dropTop + _rnd.nextDouble() * _dropSpanY,
              at.z + _rnd.nextDouble() * 2 * _dropSpread - _dropSpread,
            ),
            time,
            0.5 + 0.03 * i,
          ),
      ]);
  }
}

/// A tool being dragged (HTML `#drag-ghost`) and where it is drawn, in
/// canvas coordinates.
@immutable
class _Ghost {
  const _Ghost(this.tool, this.at);

  final _Tool tool;
  final Offset at;
}

/// Pan recogniser that only joins the gesture arena for pointers that land
/// on a pot that can be moved ([canGrab]), so other drags still pan / zoom
/// the canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _SeedGerminationLabState
    extends State<Ch10A2EssentialConditionsForSeedGerminationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final ValueNotifier<_Ghost?> _ghost = ValueNotifier(null);
  final _TextCache _texts = _TextCache();

  /// The design-size scene inside the stage (finger positions in design
  /// px), the full-canvas overlay layer (drag ghost, confetti) and the dock
  /// (drops back on it are cancelled).
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _dockKey = GlobalKey();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout and the
  /// canvas label size for it.
  double _fit = 1;
  double _labelSize = _labelPx;

  /// The phase the scene was last framed for.
  _Phase? _framedPhase;

  /// HTML `draggedPot` (step 4): the pot under the finger, the scenario it
  /// belongs to, the finger's offset from the pot's base on the z = 0
  /// plane, where and when the press started and whether it moved.
  _Pot? _grab;
  _Pot? _grabCandidate;
  int _grabScenario = -1;
  Offset _grabOffset = Offset.zero;
  Offset _downAt = Offset.zero;
  double _downTime = 0;
  bool _moved = false;

  /// HTML `activeTool` (steps 1–3): the tool being dragged, the scenario it
  /// belongs to and whether holding it over Pot B flooded it (HTML
  /// `isToolFlooding`: the drop is then skipped).
  _Tool? _dragTool;
  int _dragScenario = -1;
  bool _dragFlooded = false;

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
    _ghost.dispose();
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update() (the ramps read the scene time), the
  /// hold-to-flood check of `pointermove` and the confetti, then a repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    _checkFloodHold();
    s.confetti.update(dt);
    _frame.value = now;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(msg)`. Silent: the HTML plays the action's own tone.
  void _toast(String text) => _lab.showToast(text, sound: false);

  /// HTML `changeScenario(id)` → `resetApp()`: empty pots on the bench,
  /// step 1, Day 1 and the camera reset.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _cancelDrags();
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `enterLab()` → `changeScenario(1)`; the shell's full reset does
  /// the same behind the curtain.
  void _startLab() {
    _scene
      ..confetti.clear()
      ..snapView = true;
    _loadScenario(0);
  }

  /// HTML `window.setStep(id)`.
  void _setStep(int step) {
    _scene.step = step;
    _refresh();
  }

  /// HTML `checkStepProgress()`: 'Step Complete!' and the next step once
  /// both pots of the step are done.
  void _checkStepProgress() {
    final s = _scene;
    final l = s.left, d = s.right;
    final done = switch (s.step) {
      1 => l.soil && d.soil,
      2 => l.seed && d.seed,
      3 => d.watered && (s.scenario == 0 || l.flooded),
      4 => l.inSun && d.inSun,
      _ => false,
    };
    if (!done) return;
    _toast(_t('toast_step_complete'));
    _setStep(s.step + 1);
  }

  /// HTML `handleToolDropRaw(pid, tool)`: [tool] dropped on the pot [id].
  void _dropTool(_PotId id, _Tool tool) {
    final s = _scene;
    final pot = s.pot(id);
    if (!_lab.isLabActive || pot == null || s.step != tool.step) return;
    final t = s.time;
    switch (tool) {
      case _Tool.soil:
        if (pot.soil) return;
        // The HTML plays its water sound for the pouring soil too.
        _Sound.water.play();
        pot
          ..soil = true
          ..fill = _Ramp(_soilFrom, 1, t, _soilSeconds);
        _toast('${id.tag} - ${_t('toast_filled_soil')}');
      case _Tool.seed:
        if (pot.seed) return;
        _Sound.pop.play();
        pot
          ..seed = true
          ..seedY = _Ramp(_seedFrom, _seedY, t, _seedSeconds, _bounceOut);
        _toast('${id.tag} - ${_t('toast_sowed_seed')}');
      case _Tool.water:
        if (id != _PotId.d || pot.watered) return;
        _Sound.water.play();
        pot
          ..watered = true
          ..wet = true;
        s.rain(pot.at(t));
        _toast('${id.tag} - ${_t('toast_watered')}');
    }
    _checkStepProgress();
    _refresh();
  }

  /// HTML `autoApplyTool(tool)` (a click on the tool): the soil and the
  /// seeds go into both pots, the second 300 ms later; the can waters
  /// Pot D and, in Scenario 2, floods Pot B 500 ms later (1000 ms).
  void _autoApply(_Tool tool) {
    final s = _scene;
    if (!_lab.isLabActive || s.step != tool.step) return;
    switch (tool) {
      case _Tool.soil || _Tool.seed:
        _dropTool(s.left.id, tool);
        _lab.after(_secondPotDelay, () => _dropTool(_PotId.d, tool));
      case _Tool.water:
        _dropTool(_PotId.d, tool);
        if (s.scenario == 1) {
          _lab.after(
            _floodDelay,
            () => _flood(
              _floodClickSeconds,
              () => '${_PotId.b.tag} - ${_t('toast_flooded')}',
            ),
          );
        }
    }
  }

  /// Pot B floods: the water rises to the brim in [seconds]; then its soil
  /// darkens and [toast] is shown.
  void _flood(double seconds, String Function() toast) {
    final s = _scene;
    final b = s.left;
    if (s.scenario != 1 || s.step != 3 || b.flooded || b.flooding) return;
    _Sound.water.play();
    b
      ..flooding = true
      ..water = _Ramp(_waterFrom, 1, s.time, seconds);
    _lab.after(Duration(milliseconds: (seconds * 1000).round()), () {
      b
        ..flooding = false
        ..flooded = true
        ..wet = true;
      _toast(toast());
      _checkStepProgress();
      _refresh();
    });
    _refresh();
  }

  /// HTML `pointermove` while the can is dragged in Scenario 2, step 3:
  /// held over Pot B for a second, it floods Pot B (2000 ms).
  void _checkFloodHold() {
    final s = _scene;
    final b = s.left;
    if (_dragTool != _Tool.water ||
        _dragScenario != s.scenario ||
        s.scenario != 1 ||
        s.step != 3 ||
        b.flooded ||
        b.flooding ||
        s.hovered != _PotId.b) {
      s.holdSince = null;
      return;
    }
    final since = s.holdSince ??= s.time;
    if (s.time - since < _holdToFlood) return;
    s.holdSince = null;
    _dragFlooded = true;
    _flood(_floodHoldSeconds, () => _t('toast_flooded_b'));
  }

  /// HTML `handlePotDroppedInSunlight(pot)`: the pot flies to its place in
  /// the Sunlight Zone (500 ms Back.Out) and counts once.
  void _intoSunlight(_Pot pot) {
    final s = _scene;
    _Sound.pop.play();
    pot.moveTo(pot.id.sunX, _sunY, s.time, _backOut);
    if (!pot.inSun) {
      pot.inSun = true;
      _toast('${pot.id.tag} - ${_t('toast_sunlight')}');
      _checkStepProgress();
    }
    _refresh();
  }

  /// A pot dropped outside the zone goes back to the bench (500 ms
  /// Quadratic.Out). A pot taken out of the sun no longer counts (the HTML
  /// kept counting it, on the bench).
  void _sendHome(_Pot pot) {
    pot
      ..inSun = false
      ..moveTo(pot.id.homeX, 0, _scene.time, _quadOut);
    _refresh();
  }

  /// A screen-reader tap on a pot (added): the step's tool dropped on it,
  /// Pot B flooded (as when the can is held over it) or the pot moved into
  /// the Sunlight Zone.
  void _activatePot(_Pot pot) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    switch (s.step) {
      case 1:
        _dropTool(pot.id, _Tool.soil);
      case 2:
        _dropTool(pot.id, _Tool.seed);
      case 3:
        if (pot.id == _PotId.b) {
          _flood(_floodHoldSeconds, () => _t('toast_flooded_b'));
        } else {
          _dropTool(pot.id, _Tool.water);
        }
      case 4:
        _intoSunlight(pot);
    }
  }

  /// Whether the current step can still do something with [pot].
  bool _potActionable(_Pot pot) => switch (_scene.step) {
    1 => !pot.soil,
    2 => !pot.seed,
    3 =>
      pot.id == _PotId.d
          ? !pot.watered
          : (pot.id == _PotId.b && !pot.flooded && !pot.flooding),
    4 => true,
    _ => false,
  };

  /// HTML `#time-slider` input (step 5 only): the day counter and the
  /// growth follow the slider; Day 15 ends the time-lapse.
  void _onDay(double value) {
    final s = _scene;
    if (s.step != 5) return;
    final day = value.round().clamp(1, _days);
    if (day == s.day) return;
    s
      ..day = day
      ..growth = s.growth.toward((day - 1) / (_days - 1), s.time, _growSeconds);
    if (day == _days) {
      _toast(_t('toast_15_days'));
      _setStep(6);
    }
    _refresh();
  }

  // ---------------------------------------------------------------- popups

  /// HTML `triggerConclusion()`: the summary popup with confetti.
  void _triggerConclusion() {
    if (!mounted) return;
    final s = _scene;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    s.confetti
      ..size = _canvasSize
      ..burst();
    _lab.showPopup(() => _summaryPopup(sc));
    _refresh();
  }

  /// HTML `#summary-modal`: 'Success!', the scenario title, its result and
  /// the next-scenario message; Scenario 2 offers 'Restart Entire Lab'.
  /// Added: 'Next Scenario' (HTML `next_sc`) in Scenario 1, and the HTML's
  /// never-shown `#success-modal` text once both scenarios are done.
  LabPopupContent _summaryPopup(int sc) {
    final n = sc + 1;
    final allDone = _lab.completedScenarios.length >= _scenarioCount;
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.check_circle,
      accent: _Colors.amber600,
      extra: Builder(
        builder: (context) => _SummaryCard(
          title: _t('sc${n}_title'),
          heading: _t('observation'),
          body: _t('s${n}_c1'),
          next: _t('next_msg_s$n'),
          masteryTitle: allDone ? _t('all_complete') : null,
          masteryText: allDone ? _t('all_complete_desc') : null,
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        if (sc == 0)
          LabAction(
            label: _t('next_sc'),
            icon: Icons.arrow_forward,
            color: _Colors.amber500,
            foreground: _Colors.slate950,
            onTap: _nextScenario,
          ),
        if (sc == 1 || allDone)
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.amber600,
            foreground: _Colors.slate950,
            onTap: _restartLab,
          ),
      ],
    );
  }

  /// 'Next Scenario' (added): Scenario 2, as the HTML message asks.
  void _nextScenario() {
    _Sound.scenario.play();
    _loadScenario(1);
  }

  /// HTML `restartApp()`: closes the summary and starts Scenario 1 again
  /// (the curtain stays up); the scenarios count as not done again.
  void _restartLab() {
    _lab.completedScenarios.clear();
    _loadScenario(0);
  }

  /// HTML `#compare-btn-container`: 'Observe Summary & Conclusion'.
  LabAction _concludeAction() => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.amber600,
    foreground: _Colors.white,
    highlight: true,
    // The summary plays the HTML `success` tone.
    silent: true,
    onTap: _triggerConclusion,
  );

  // ------------------------------------------------------------- gestures

  /// Size of the canvas (for the confetti).
  Size get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : _design;
  }

  /// [global] in canvas coordinates, or null before layout.
  Offset? _canvasLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  bool _overDock(Offset global) {
    final dock = _dockKey.currentContext?.findRenderObject();
    if (dock is! RenderBox || !dock.hasSize) return false;
    final rect = MatrixUtils.transformRect(
      dock.getTransformTo(null),
      Offset.zero & dock.size,
    );
    return rect.contains(global);
  }

  /// HTML `getTargetPot(x, y)`: the pot on the finger's side of the scene
  /// (left: Pot A / Pot B, right: Pot D). Nothing over the dock or off the
  /// canvas.
  _PotId? _targetAt(Offset global) {
    final local = _canvasLocal(global);
    if (local == null || !(Offset.zero & _canvasSize).contains(local)) {
      return null;
    }
    if (_overDock(global)) return null;
    final at = labGlobalToLocal(_stageKey, global);
    if (at == null) return null;
    final s = _scene;
    final mid = s.cam.p(const _V(0, _potH / 2, 0)).dx;
    return at.dx < mid ? s.left.id : _PotId.d;
  }

  /// HTML `pointerdown` on a `.drag-tool`: the ghost appears under the
  /// finger.
  void _toolDragStart(_Tool tool, DragStartDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.step != tool.step || _grab != null) return;
    _dragTool = tool;
    _dragScenario = s.scenario;
    _dragFlooded = false;
    _toolDragMove(d.globalPosition);
  }

  void _toolDragUpdate(DragUpdateDetails d) => _toolDragMove(d.globalPosition);

  /// HTML `pointermove`: the ghost follows the finger and the pot under it
  /// grows a little.
  void _toolDragMove(Offset global) {
    final tool = _dragTool;
    if (tool == null) return;
    final at = _canvasLocal(global);
    if (at != null) _ghost.value = _Ghost(tool, at);
    _hoverPot(_targetAt(global));
  }

  /// HTML `pointerup`: the tool is dropped on the pot under the finger
  /// (unless holding it flooded Pot B).
  void _toolDragEnd() {
    final tool = _dragTool;
    final s = _scene;
    final target = s.hovered;
    final flooded = _dragFlooded;
    final scenario = _dragScenario;
    _endToolDrag();
    if (tool == null || scenario != s.scenario || flooded || target == null) {
      return;
    }
    _dropTool(target, tool);
  }

  void _endToolDrag() {
    _dragTool = null;
    _dragScenario = -1;
    _dragFlooded = false;
    _ghost.value = null;
    _hoverPot(null);
    _scene.holdSince = null;
  }

  /// HTML `hoveredPot`: the pot under a dragged tool scales to 1.1.
  void _hoverPot(_PotId? id) {
    final s = _scene;
    if (s.hovered == id) return;
    s.hovered = id;
    for (final pot in s.pots) {
      pot.hoverTo(pot.id == id ? _hoverScale : 1, s.time);
    }
  }

  void _cancelDrags() {
    _endToolDrag();
    _grab = null;
    _grabCandidate = null;
    _grabScenario = -1;
    _scene.zoneHot = false;
  }

  /// Where [pot] is drawn (pot and rim), in design px.
  Rect _potRect(_Cam cam, _Pot pot) {
    final t = _scene.time;
    final p = pot.at(t);
    final k = pot.hover.at(t);
    final r = (pot.glass ? _beakerTopR : _rimR) * k;
    final h = (pot.glass ? _beakerH : _rimTop) * k;
    return cam.boxRect(_V(p.x - r, p.y, -r), _V(p.x + r, p.y + h, r));
  }

  /// The Sunlight Zone on the stage.
  Rect _zoneRect(_Cam cam) => cam.boxRect(
    const _V(-_zoneHalfW, _zoneBottom, 0),
    const _V(_zoneHalfW, _zoneTop, 0),
  );

  /// HTML `pointerdown` on the canvas in step 4: the pot nearest to the
  /// finger, within a finger's reach of where it is drawn.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    _grabCandidate = null;
    if (!_lab.isLabActive || s.step != 4 || _grab != null) return false;
    if (_dragTool != null) return false;
    final cam = s.cam;
    final at = event.localPosition;
    final reach = _touchDp / _fit;
    var best = double.infinity;
    for (final pot in s.pots) {
      final rect = _potRect(cam, pot).inflate(reach);
      if (!rect.contains(at)) continue;
      final d = (rect.center - at).distance;
      if (d < best) {
        best = d;
        _grabCandidate = pot;
      }
    }
    return _grabCandidate != null;
  }

  /// The pot is picked up where the finger holds it.
  void _onDown(DragDownDetails d) {
    final pot = _grabCandidate;
    final s = _scene;
    if (pot == null || _grab != null) return;
    final p = pot.at(s.time);
    final hit = s.cam.onPlaneZ(d.localPosition);
    _grabOffset = hit == null ? Offset.zero : Offset(p.x - hit.x, p.y - hit.y);
    _grab = pot;
    _grabScenario = s.scenario;
    _downAt = d.localPosition;
    _downTime = s.time;
    _moved = false;
    pot.held = Offset(p.x, p.y);
  }

  /// HTML `pointermove` with a pot: it follows the finger on the z = 0
  /// plane and the zone lights up under it.
  void _onDragUpdate(DragUpdateDetails d) {
    final pot = _grab;
    final s = _scene;
    if (pot == null || _grabScenario != s.scenario) return;
    if ((d.localPosition - _downAt).distance > _dragSlop / _fit) _moved = true;
    final hit = s.cam.onPlaneZ(d.localPosition);
    if (hit == null) return;
    pot.held = Offset(
      (hit.x + _grabOffset.dx).clamp(-_reachX, _reachX),
      (hit.y + _grabOffset.dy).clamp(0.0, _reachY),
    );
    s.zoneHot = _zoneRect(s.cam).inflate(_zoneSlack).contains(d.localPosition);
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` with a pot: a click, or a drop over the zone, puts it
  /// in the sun; elsewhere it goes back to the bench.
  void _release() {
    final pot = _grab;
    final s = _scene;
    final hot = s.zoneHot;
    _grab = null;
    _grabCandidate = null;
    s.zoneHot = false;
    if (pot == null || _grabScenario != s.scenario || s.step != 4) return;
    final click = !_moved || s.time - _downTime < _clickSeconds;
    if (click || hot) {
      _intoSunlight(pot);
    } else {
      _sendHome(pot);
    }
  }

  // -------------------------------------------------------------- framing

  /// Aims the camera at the current phase in the free part of the canvas.
  void _frameScene(BuildContext context, Size canvas, double fit) {
    final s = _scene;
    final phase = s.phase;
    final target = _framing(context, canvas, fit);
    final newPhase = _framedPhase != null && _framedPhase != phase;
    _framedPhase = phase;
    s.aimView(target, newPhase ? _phaseSeconds : _reframeSeconds);
  }

  /// The framing that shows the phase's objects as large as possible in
  /// the canvas left free by the dock, the HUD, the bottom card, the day
  /// counter and (sidebar collapsed) the floating mission card.
  _View _framing(BuildContext context, Size canvas, double fit) {
    final stage = Offset(
      (canvas.width - _design.width * fit) / 2,
      (canvas.height - _design.height * fit) / 2,
    );
    Rect toDesign(Rect r) => Rect.fromLTRB(
      (r.left - stage.dx) / fit,
      (r.top - stage.dy) / fit,
      (r.right - stage.dx) / fit,
      (r.bottom - stage.dy) / fit,
    );
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final sc = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final compact = size.height < _compactBelow;
    final phase = _scene.phase;
    var bottom = _cardGap + pad.bottom;
    if (open) bottom += (compact ? _hudBandCompact : _hudBand) * sc;
    if (phase == _Phase.sun) bottom += _bottomCard * sc;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _cardGap + pad.top,
      canvas.width - insets.right - _dockWidth * sc,
      canvas.height - bottom,
    );
    final frees = <Rect>[
      if (open || !_lab.isLabActive)
        base
      else ...[
        Rect.fromLTRB(insets.left, base.top, base.right, base.bottom),
        if (compact)
          Rect.fromLTRB(
            base.left,
            math.max(
              base.top,
              _missionTop + pad.top + size.height * _compactCardMax + _cardGap,
            ),
            base.right,
            base.bottom,
          ),
      ],
    ];
    // The day counter (steps 5 and 6) takes the top-right corner: the scene
    // goes below it or to its left, whichever is larger.
    final day = Rect.fromLTWH(
      canvas.width - insets.right - _dayCardWidth * sc - _cardGap,
      0,
      _dayCardWidth * sc + _cardGap,
      insets.top + _dayCard * sc,
    );
    final lift = phase == _Phase.sun ? _sunLift : 0.0;
    final stageRect = Offset.zero & _design;
    final view = _fitView(
      _focusRect(phase, lift).inflate(_framePad),
      [
        for (final r in frees)
          if (phase == _Phase.sun && r.overlaps(day)) ...[
            Rect.fromLTRB(r.left, day.bottom, r.right, r.bottom),
            Rect.fromLTRB(r.left, r.top, math.min(r.right, day.left), r.bottom),
          ] else
            r,
      ].map((r) => toDesign(r).intersect(stageRect)).toList(),
    );
    return _View(view.dx, view.dy, view.k, lift);
  }

  /// Bounds (unframed design px, camera raised by [lift]) of what the
  /// learner works with in [phase]: the pots and their labels on the bench,
  /// the Sunlight Zone, or the pots in the sun with the grown seedling.
  Rect _focusRect(_Phase phase, double lift) {
    final cam = _Cam(_View(0, 0, 1, lift));
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    void box(_V min, _V max) => add(cam.boxRect(min, max));
    void label(double x, double y, String key) {
      final size = _texts.chip(_t(key), _labelSize);
      add(
        Rect.fromCenter(
          center: cam.p(_V(x, y, 0)),
          width: size.width,
          height: size.height,
        ),
      );
    }

    final leftKey = _scene.left.id.labelKey;
    const reach = _rimR;
    if (phase != _Phase.sun) {
      for (final side in const [-1.0, 1.0]) {
        box(
          _V(side * _homeX - reach, 0, -reach),
          _V(side * _homeX + reach, _beakerH, reach),
        );
      }
      label(-_homeX, _labelY, leftKey);
      label(_homeX, _labelY, 'lbl_pot_d');
    }
    if (phase == _Phase.zone) {
      box(
        const _V(-_zoneHalfW, _zoneBottom, 0),
        const _V(_zoneHalfW, _zoneTop, 0),
      );
    }
    if (phase == _Phase.sun) {
      for (final side in const [-1.0, 1.0]) {
        box(
          _V(side * _sunX - reach, _sunY, -reach),
          _V(side * _sunX + reach, _sunY + _beakerH, reach),
        );
      }
      box(
        const _V(_sunX - 2.4, _sunY + _sproutY, -1),
        const _V(_sunX + 2.4, _sunY + _sproutY + _sproutTop, 1),
      );
      label(-_sunX, _sunY + _labelY, leftKey);
      label(_sunX, _sunY + _sproutY + _sproutTop + _labelClear, 'lbl_pot_d');
    }
    return r!;
  }

  /// The framing that shows [focus] as large as possible (up to
  /// [_maxZoom]) centred in the largest of [frees].
  static _View _fitView(Rect focus, List<Rect> frees) {
    _View? best;
    var bestK = -1.0;
    for (final free in frees) {
      if (free.width <= 0 || free.height <= 0) continue;
      final k = math.min(
        _maxZoom,
        math.min(free.width / focus.width, free.height / focus.height),
      );
      if (k > bestK + 1e-6) {
        best = _View(
          free.center.dx - focus.center.dx * k,
          free.center.dy - focus.center.dy * k,
          k,
        );
        bestK = k;
      }
    }
    return best ?? _View.identity;
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final scene = _scene;
        final data = _data;
        final n = scene.scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.local_florist,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // HTML `updateUI()`: `hud[State.step]`.
          hud: _t('s${n}_h${scene.step}'),
          actions: [if (scene.step == _stepCount) _concludeAction()],
          onEnterLab: _startLab,
          onReset: _startLab,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepAccordion(
            key: ValueKey('ch10a2-steps-${scene.scenario}-${scene.step}'),
            steps: data.steps,
            current: scene.step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            taskLabel: _t('concept_focus'),
            resultLabel: _t('observation'),
          ),
          overlays: _overlays(context, p, s),
          stage: _buildStage(),
        );
      },
    );
  }

  /// Canvas cards: the day counter (steps 5–6), the dock of tools (right),
  /// the time-lapse slider (step 5) or 'Observe Summary & Conclusion'
  /// (step 6) above the HUD, the confetti and the drag ghost.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final scene = _scene;
    final hudRoom = _lab.isSidebarOpen
        ? (compact ? _hudBandCompact : _hudBand) * s
        : 0.0;
    final showDay = scene.step >= 5;
    return [
      if (showDay)
        Positioned(
          key: const ValueKey('ch10a2-day'),
          top: inset.top,
          right: inset.right,
          child: _DayCounter(
            label: _t('sim_time'),
            text: '${_t('day_label')} ${scene.day} / $_days',
            palette: p,
            scale: s,
          ),
        ),
      Positioned(
        key: const ValueKey('ch10a2-dock'),
        right: inset.right,
        top: inset.top + (showDay ? _dayCard * s : 0),
        bottom: inset.bottom + hudRoom,
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: _ToolDock(
              key: _dockKey,
              palette: p,
              scale: s,
              tools: [
                for (final tool in _Tool.values)
                  _ToolData(
                    tool: tool,
                    label: _t(tool.labelKey),
                    enabled: scene.step == tool.step,
                    onTap: () => _autoApply(tool),
                    onDragStart: (d) => _toolDragStart(tool, d),
                    onDragUpdate: _toolDragUpdate,
                    onDragEnd: _toolDragEnd,
                  ),
              ],
            ),
          ),
        ),
      ),
      // On the canvas above the HUD (in reach on phones too), as the HTML
      // dock's slider and its compare button.
      if (scene.step == 5)
        Positioned(
          key: const ValueKey('ch10a2-time'),
          left: inset.left,
          right: inset.right + _dockWidth * s,
          bottom: inset.bottom + hudRoom,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _TimeLapseCard(
                label: _t('tool_time'),
                dayLabel: _t('day_label'),
                day: scene.day,
                palette: p,
                scale: s,
                onChanged: _onDay,
              ),
            ),
          ),
        ),
      if (scene.step == _stepCount && _lab.popup == null)
        Positioned(
          key: const ValueKey('ch10a2-conclude'),
          left: inset.left,
          right: inset.right + _dockWidth * s,
          bottom: inset.bottom + hudRoom,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _ConcludeButton(
                label: _t('btn_conclude'),
                scale: s,
                clock: _frame,
                onTap: _triggerConclusion,
              ),
            ),
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(scene.confetti, repaint: _frame),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: SizedBox.expand(
            key: _canvasKey,
            child: ValueListenableBuilder<_Ghost?>(
              valueListenable: _ghost,
              builder: (context, ghost, _) {
                if (ghost == null) return const SizedBox.shrink();
                return Stack(
                  children: [
                    Positioned(
                      left: ghost.at.dx,
                      top: ghost.at.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: _DragGhost(tool: ghost.tool, scale: s),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ];
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
          // Canvas labels stay readable when the stage is drawn small.
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          _frameScene(context, box.biggest, fit);
        }
        return LabStage(
          designSize: _design,
          child: Stack(
            key: _stageKey,
            fit: StackFit.expand,
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // The pots have their own semantics nodes ([_potNodes]).
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
                        texts: _texts,
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
              Positioned.fill(
                child: ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, _, _) => _potNodes(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// One screen-reader node per pot where it is drawn and one for the
  /// Sunlight Zone in step 4 (added), so a screen reader can find them and
  /// use the step's tool on a pot. They take no touches: those reach the
  /// scene below.
  Widget _potNodes() {
    final s = _scene;
    if (!_lab.isLabActive) return const SizedBox.shrink();
    final cam = s.cam;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (s.step == 4)
          Positioned.fromRect(
            rect: _zoneRect(cam),
            child: Semantics(
              container: true,
              label: _t('sunlight_zone'),
              child: const SizedBox.expand(),
            ),
          ),
        for (final pot in s.pots)
          Positioned.fromRect(
            rect: _potRect(cam, pot),
            child: Semantics(
              container: true,
              button: _potActionable(pot),
              label: _t(pot.id.labelKey),
              onTap: _potActionable(pot) ? () => _activatePot(pot) : null,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------- dock

/// One dock tool: its name, whether its step is on, and its gestures.
@immutable
class _ToolData {
  const _ToolData({
    required this.tool,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final _Tool tool;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;
}

/// CSS `grayscale(100%)` for disabled tools.
const ColorFilter _grayscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// HTML `#interactive-dock`: the Soil Bag, the Bean Seeds and the Watering
/// Can, one above the other (the HTML row at the bottom of the canvas).
class _ToolDock extends StatelessWidget {
  const _ToolDock({
    super.key,
    required this.tools,
    required this.palette,
    required this.scale,
  });

  final List<_ToolData> tools;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Container(
      width: 84 * s,
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        // glass-panel bg-white/95 dark:bg-slate-900/95, border-slate-500/40.
        color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0x6664748B)),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tools.length; i++) ...[
            if (i > 0) SizedBox(height: 10 * s),
            _ToolTile(data: tools[i], palette: p, scale: s),
          ],
        ],
      ),
    );
  }
}

/// HTML `.drag-tool` and its caption: tap it to use it on both pots, or
/// drag it onto one. Disabled tools are faded and grey (`.disabled`); the
/// tool of the current step shows the HTML hover look (indigo border).
class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.data,
    required this.palette,
    required this.scale,
  });

  final _ToolData data;
  final LabPalette palette;
  final double scale;

  /// Caption colour of the enabled tool (HTML `group-hover:text-*`).
  static Color _hoverText(_Tool tool) => switch (tool) {
    _Tool.soil => _Colors.amber500,
    _Tool.seed => _Colors.indigo500,
    _Tool.water => _Colors.blue500,
  };

  @override
  Widget build(BuildContext context) {
    final d = data;
    final s = scale;
    final dark = palette.isDark;
    final on = d.enabled;
    Widget tile = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60 * s,
          height: 60 * s,
          decoration: BoxDecoration(
            color: on
                ? _Colors.toolActive
                : (dark ? const Color(0x1AFFFFFF) : _Colors.slate100),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: on ? _Colors.indigo500 : LabInk.clear,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: _ToolIcon(tool: d.tool, size: 40 * s),
        ),
        SizedBox(height: 4 * s),
        Text(
          d.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: on
                ? _hoverText(d.tool)
                : (dark ? _Colors.slate400 : _Colors.slate500),
            fontSize: 10 * s,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
    if (!on) {
      tile = Opacity(
        opacity: 0.4,
        child: ColorFiltered(colorFilter: _grayscale, child: tile),
      );
    }
    return Semantics(
      button: true,
      enabled: on,
      label: d.label,
      excludeSemantics: true,
      onTap: on ? d.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: on ? d.onTap : null,
        onPanStart: on ? d.onDragStart : null,
        onPanUpdate: on ? d.onDragUpdate : null,
        onPanEnd: on ? (_) => d.onDragEnd() : null,
        onPanCancel: on ? d.onDragEnd : null,
        child: tile,
      ),
    );
  }
}

/// A tool's icon: the Phosphor bag (soil), the HTML's indigo seed and its
/// blue watering can.
class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.tool, required this.size});

  final _Tool tool;
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (tool) {
      _Tool.soil => Icon(
        Icons.shopping_bag,
        size: size * 0.78,
        color: _Colors.bagIcon,
      ),
      _Tool.seed => CustomPaint(
        size: Size.square(size),
        painter: const _SeedIconPainter(),
      ),
      _Tool.water => CustomPaint(
        size: Size.square(size),
        painter: const _CanIconPainter(),
      ),
    };
  }
}

/// The seed packet's icon: an indigo bean seed with its white hilum.
class _SeedIconPainter extends CustomPainter {
  const _SeedIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;
    canvas
      ..save()
      ..translate(12.2 * u, 12.2 * u)
      ..rotate(-0.7)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: 16.4 * u, height: 13 * u),
        Paint()..color = _Colors.seedIcon,
      )
      ..drawLine(
        Offset(-1.3 * u, 1.6 * u),
        Offset(1.3 * u, 1.6 * u),
        Paint()
          ..color = _Colors.seedMark
          ..strokeWidth = 1.5 * u
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _SeedIconPainter oldDelegate) => false;
}

/// The watering can's icon: a blue can with a long spout, a rose and a
/// handle.
class _CanIconPainter extends CustomPainter {
  const _CanIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;
    final fill = Paint()..color = _Colors.canIcon;
    final stroke = Paint()
      ..color = _Colors.canIcon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Body.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(9 * u, 9 * u, 19 * u, 20 * u),
          Radius.circular(2 * u),
        ),
        fill,
      )
      // Handle over the back of the can.
      ..drawPath(
        Path()
          ..moveTo(11 * u, 9 * u)
          ..quadraticBezierTo(14 * u, 3.5 * u, 19.5 * u, 6 * u)
          ..quadraticBezierTo(22 * u, 8 * u, 19 * u, 12.5 * u),
        stroke,
      )
      // Spout and rose.
      ..drawLine(Offset(9.5 * u, 15 * u), Offset(3.5 * u, 8.5 * u), stroke)
      ..drawPath(
        Path()
          ..moveTo(1.2 * u, 8.6 * u)
          ..lineTo(4.4 * u, 5.4 * u)
          ..lineTo(5.6 * u, 9.6 * u)
          ..close(),
        fill,
      )
      // The light band of the HTML icon.
      ..drawLine(
        Offset(11.5 * u, 12 * u),
        Offset(16.5 * u, 12 * u),
        Paint()
          ..color = _Colors.seedMark
          ..strokeWidth = 1.4 * u
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(covariant _CanIconPainter oldDelegate) => false;
}

/// HTML `#drag-ghost`: the tool's icon under the finger.
class _DragGhost extends StatelessWidget {
  const _DragGhost({required this.tool, required this.scale});

  final _Tool tool;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 60 * s,
      height: 60 * s,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
        ),
      ),
      child: _ToolIcon(tool: tool, size: 44 * s),
    );
  }
}

// ------------------------------------------------------------- canvas cards

/// HTML `#day-counter-overlay`: a calendar, "SIMULATION TIME" and the day.
class _DayCounter extends StatelessWidget {
  const _DayCounter({
    required this.label,
    required this.text,
    required this.palette,
    required this.scale,
  });

  final String label;
  final String text;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Semantics(
      liveRegion: true,
      label: '$label: $text',
      child: ExcludeSemantics(
        child: LabGlassCard(
          palette: p,
          radius: 16 * s,
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
          borderColor: const Color(0x66F59E0B),
          color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available, size: 24 * s, color: p.accentInk),
              SizedBox(width: 8 * s),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: _Colors.slate400,
                      fontSize: 9.5 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(label, 0.6),
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HTML `#tool-slider-container`: the time-lapse slider (Day 1 … 15) and
/// its caption.
class _TimeLapseCard extends StatelessWidget {
  const _TimeLapseCard({
    required this.label,
    required this.dayLabel,
    required this.day,
    required this.palette,
    required this.scale,
    required this.onChanged,
  });

  final String label;
  final String dayLabel;
  final int day;
  final LabPalette palette;
  final double scale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return LabGlassCard(
      palette: p,
      radius: 16 * s,
      padding: EdgeInsets.fromLTRB(12 * s, 4 * s, 12 * s, 8 * s),
      borderColor: const Color(0x6664748B),
      color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
      child: SizedBox(
        width: 280 * s,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8 * s,
                // The HTML track is indigo along its whole length.
                activeTrackColor: _Colors.indigo500,
                inactiveTrackColor: _Colors.indigo500,
                activeTickMarkColor: const Color(0x80FFFFFF),
                inactiveTickMarkColor: const Color(0x80FFFFFF),
                thumbShape: _RingThumb(12 * s),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 22 * s),
                overlayColor: const Color(0x336366F1),
              ),
              child: Slider(
                value: day.toDouble(),
                min: 1,
                max: _days.toDouble(),
                divisions: _days - 1,
                onChanged: onChanged,
                semanticFormatterCallback: (v) => '$dayLabel ${v.round()}',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: p.isDark ? _Colors.slate400 : _Colors.slate500,
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The HTML range thumb: white, 24 px, with a 2 px indigo ring.
class _RingThumb extends SliderComponentShape {
  const _RingThumb(this.radius);

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    context.canvas
      ..drawCircle(
        center + const Offset(0, 2),
        radius,
        Paint()
          ..color = const Color(0x4D000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(center, radius, Paint()..color = _Colors.white)
      ..drawCircle(
        center,
        radius - 1,
        Paint()
          ..color = _Colors.indigo500
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }
}

/// HTML `#compare-btn-container`: 'Observe Summary & Conclusion' on an
/// amber-to-emerald gradient, gently pulsing.
class _ConcludeButton extends StatelessWidget {
  const _ConcludeButton({
    required this.label,
    required this.scale,
    required this.clock,
    required this.onTap,
  });

  final String label;
  final double scale;

  /// Scene time, for the pulse.
  final ValueListenable<double> clock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 10 * s),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb, size: 20 * s, color: _Colors.white),
            SizedBox(width: 8 * s),
            Text(
              label,
              style: TextStyle(
                color: _Colors.white,
                fontSize: 14 * s,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, t, child) {
            final pulse = 0.5 - 0.5 * math.cos(t * math.pi);
            return Transform.scale(
              scale: 1 + 0.03 * pulse,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_Colors.amber600, _Colors.emerald600],
                  ),
                  borderRadius: BorderRadius.circular(16 * s),
                  border: Border.all(color: const Color(0x33FFFFFF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _Colors.amber500.withValues(
                        alpha: 0.3 + 0.25 * pulse,
                      ),
                      blurRadius: (14 + 10 * pulse) * s,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: content,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ sidebar

/// HTML `#teacher-content` steps: an accordion card per step, "STEP N:
/// CONCEPT", with its task and result when open. The current step is amber
/// and open; done steps are faded with a tick. Only one step is open at a
/// time; a tap opens or closes it (HTML `toggleStepAccordion`).
class _StepAccordion extends StatefulWidget {
  const _StepAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.taskLabel,
    required this.resultLabel,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String taskLabel;
  final String resultLabel;

  @override
  State<_StepAccordion> createState() => _StepAccordionState();
}

class _StepAccordionState extends State<_StepAccordion> {
  /// HTML `State.openedStep` (−1: all closed). The widget is keyed by the
  /// step, so a new step opens again (HTML `setStep`).
  late int _opened = widget.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * widget.scale),
            child: _card(i),
          ),
      ],
    );
  }

  Widget _card(int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final dark = p.isDark;
    final active = i == w.current;
    final done = i < w.current;
    final open = _opened == i;
    final step = w.steps[i - 1];
    final Color fill, border;
    if (active) {
      fill = const Color(0x1AF59E0B);
      border = _Colors.amber500;
    } else if (done) {
      fill = dark ? const Color(0x661E293B) : const Color(0x80E2E8F0);
      border = dark ? _Colors.slate700 : _Colors.slate300;
    } else {
      fill = dark ? _Colors.slate800 : _Colors.white;
      border = dark ? _Colors.slate700 : _Colors.slate200;
    }
    final headColor = active
        ? p.accentInk
        : (dark ? _Colors.slate400 : _Colors.slate500);
    final heading = '${w.stepLabel} $i: ${step.concept}';
    final card = Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: LabInk.clear,
            child: InkWell(
              onTap: () => setState(() => _opened = open ? -1 : i),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * s,
                    vertical: 8 * s,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        open
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 16 * s,
                        color: headColor,
                      ),
                      SizedBox(width: 6 * s),
                      Expanded(
                        child: Text(
                          heading.toUpperCase(),
                          style: TextStyle(
                            color: headColor,
                            fontSize: 11 * f,
                            fontWeight: FontWeight.w900,
                            letterSpacing: labLetterSpacing(heading, 0.8),
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (done)
                        Container(
                          width: 20 * s,
                          height: 20 * s,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0x33F59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12 * s,
                            color: p.accentInk,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Container(
              padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 12 * s),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: dark
                        ? const Color(0x80334155)
                        : const Color(0x80E2E8F0),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${w.taskLabel}: ',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: step.action),
                      ],
                    ),
                    style: TextStyle(
                      color: dark ? _Colors.slate200 : _Colors.slate800,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${w.resultLabel}: ',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: step.observation),
                      ],
                    ),
                    style: TextStyle(
                      color: dark ? _Colors.slate400 : _Colors.slate600,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    return done ? Opacity(opacity: 0.75, child: card) : card;
  }
}

// ------------------------------------------------------------------- popups

/// HTML `#summary-modal` body: the lightbulb, the scenario title, the
/// result and its conclusion, and the next-scenario message; once both
/// scenarios are done, the HTML `#success-modal` trophy and text.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.heading,
    required this.body,
    required this.next,
    required this.masteryTitle,
    required this.masteryText,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String title;
  final String heading;
  final String body;
  final String next;
  final String? masteryTitle;
  final String? masteryText;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  Widget _badge(IconData icon, Color color, double s) => Center(
    child: Container(
      width: 60 * s,
      height: 60 * s,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 30 * s, color: palette.ink(color)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final amber = p.ink(_Colors.amber400);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _badge(Icons.lightbulb, _Colors.amber500, s),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 19 * s,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: amber,
            fontSize: 16 * f,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13 * f,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        SizedBox(height: 14 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0xE61E293B) : _Colors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.isDark ? _Colors.slate700 : _Colors.slate200,
            ),
          ),
          child: Text(
            next,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: amber,
              fontSize: 12 * f,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
        ),
        if (masteryTitle != null) ...[
          SizedBox(height: 18 * s),
          _badge(Icons.emoji_events, _Colors.yellow400, s),
          SizedBox(height: 10 * s),
          Text(
            masteryTitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 19 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (masteryText != null) ...[
            SizedBox(height: 6 * s),
            Text(
              masteryText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 13 * f,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// canvas-confetti pieces: each a small wobbling quad (its `square`
/// shape), fading over its 200 ticks; drawn as one vertex batch.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.confetti, {required Listenable repaint})
    : super(repaint: repaint);

  final _Confetti confetti;

  /// canvas-confetti's `fetti.random` (2 … 3), fixed here.
  static const double _skew = 2.5;

  /// Wobble radius (10 × `scalar`).
  static const double _wobbleR = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final pieces = confetti.pieces;
    if (pieces.isEmpty) return;
    final positions = <Offset>[];
    final colors = <Color>[];
    for (final c in pieces) {
      final color = c.color.withValues(
        alpha: (1 - c.tick / _confettiTicks).clamp(0.0, 1.0),
      );
      final wx = c.x + _wobbleR * math.cos(c.wobble);
      final wy = c.y + _wobbleR * math.sin(c.wobble);
      final tc = _skew * math.cos(c.tilt);
      final ts = _skew * math.sin(c.tilt);
      final a = Offset(c.x, c.y);
      final b = Offset(wx, c.y + ts);
      final d = Offset(wx + tc, wy + ts);
      final e = Offset(c.x + tc, wy);
      positions.addAll([a, b, d, a, d, e]);
      for (var k = 0; k < 6; k++) {
        colors.add(color);
      }
    }
    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
    );
    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.confetti != confetti;
}

// ================================================================== PAINTING

/// TextPainters for the canvas labels, laid out once and reused every
/// frame. Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  /// Painters kept before the cache starts over (language, theme or size
  /// changes add new ones).
  static const int _limit = 48;

  /// Padding of a label chip around its text, for a [size] px font.
  static double padX(double size) => size * 0.8;
  static double padY(double size) => size * 0.32;

  /// Bold [text] at [size] design px in [color].
  TextPainter get(String text, double size, Color color) {
    final key = '$size|${color.toARGB32()}|$text';
    final cached = _painters[key];
    if (cached != null) return cached;
    if (_painters.length >= _limit) dispose();
    return _painters[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Size of the label chip of [text] at [size] px.
  Size chip(String text, double size) {
    final tp = get(text, size, _Colors.white);
    return Size(tp.width + 2 * padX(size), tp.height + 2 * padY(size));
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
  }
}

/// A scene label sprite: where it is drawn and its text.
typedef _Label = (Offset at, String text);

/// Crumbs on the soil (added texture): angle, radius (fraction of the soil
/// radius) and whether the crumb is light or dark. Fixed, so the soil looks
/// the same every time.
final List<(double, double, bool)> _crumbs = () {
  final rnd = math.Random(9);
  return [
    for (var k = 0; k < 22; k++)
      (
        rnd.nextDouble() * 2 * math.pi,
        math.sqrt(rnd.nextDouble()) * 0.88,
        rnd.nextBool(),
      ),
  ];
}();

/// Mesh drawing through the camera under the HTML lights.
class _Gfx {
  _Gfx(this.canvas, this.cam);

  final Canvas canvas;
  final _Cam cam;

  final Paint _fill = Paint();
  final Paint _seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..strokeJoin = StrokeJoin.round;
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Where the key light's highlight sits on a round object, in radii from
  /// its centre on screen.
  Offset get _highlight =>
      Offset(_lightDir.dot(cam.right), -_lightDir.dot(cam.up)) * 0.42;

  static Path _polygon(List<Offset> pts) => Path()..addPolygon(pts, true);

  /// Fills the polygon through [pts] with [color], with a same-colour
  /// hairline that hides anti-aliasing seams between neighbouring faces.
  void fill(List<Offset> pts, Color color, {bool seam = true}) {
    final path = _polygon(pts);
    canvas.drawPath(path, _fill..color = color);
    if (seam) canvas.drawPath(path, _seam..color = color);
  }

  /// Horizontal direction at [a] radians.
  static _V _dir(double a) => _V(math.cos(a), 0, math.sin(a));

  /// A horizontal circle of radius [r] around [c], projected.
  List<Offset> ring(_V c, double r, {int sides = 36}) => [
    for (var i = 0; i < sides; i++)
      cam.p(c + _dir(i * 2 * math.pi / sides) * r),
  ];

  /// A flat horizontal disc of radius [r] at [c], already lit.
  void disc(_V c, double r, Color color, {int sides = 36}) =>
      fill(ring(c, r, sides: sides), color);

  /// The side of an upright frustum standing on [base] and scaled by [k]
  /// about it: radius [r0] at height [y0], [r1] at [y1]. The facets turned
  /// to the camera are lit one by one; with [far], the facets turned away
  /// are drawn instead (the inside of the far wall, seen over the rim or
  /// through glass).
  void frustum(
    _V base,
    double k,
    double y0,
    double y1,
    double r0,
    double r1,
    Color color, {
    bool far = false,
    int sides = 32,
  }) {
    if (y1 <= y0) return;
    final slope = (r0 - r1) / (y1 - y0);
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir((a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + (_V.up * ((y0 + y1) / 2) + m * ((r0 + r1) / 2)) * k;
      if (cam.facing(n, mid) == far) continue;
      final d0 = _dir(a0), d1 = _dir(a1);
      fill([
        cam.p(base + (d0 * r0 + _V.up * y0) * k),
        cam.p(base + (d1 * r0 + _V.up * y0) * k),
        cam.p(base + (d1 * r1 + _V.up * y1) * k),
        cam.p(base + (d0 * r1 + _V.up * y1) * k),
      ], _lit(color, far ? -n : n));
    }
  }

  /// The same frustum side as one shape, for see-through materials (glass,
  /// water): filled once, so the facets' edges do not show.
  Path frustumShape(
    _V base,
    double k,
    double y0,
    double y1,
    double r0,
    double r1, {
    bool far = false,
    int sides = 32,
  }) {
    final path = Path();
    if (y1 <= y0) return path;
    final slope = (r0 - r1) / (y1 - y0);
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir((a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + (_V.up * ((y0 + y1) / 2) + m * ((r0 + r1) / 2)) * k;
      if (cam.facing(n, mid) == far) continue;
      final d0 = _dir(a0), d1 = _dir(a1);
      path.addPolygon([
        cam.p(base + (d0 * r0 + _V.up * y0) * k),
        cam.p(base + (d1 * r0 + _V.up * y0) * k),
        cam.p(base + (d1 * r1 + _V.up * y1) * k),
        cam.p(base + (d0 * r1 + _V.up * y1) * k),
      ], true);
    }
    return path;
  }

  /// A SphereGeometry of radius 1 scaled by [axes] at [c]: a shaded
  /// ellipse with the key light's highlight towards the upper right.
  void ellipsoid(_V c, _V axes, Color color) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    final view = (c - cam.eye).unit;
    final sinE = -view.y;
    final cosE = math.sqrt(math.max(0.0, 1 - sinE * sinE));
    final rx = axes.x * k;
    final ry =
        math.sqrt(
          math.pow(axes.y * cosE, 2).toDouble() +
              math.pow(axes.z * sinE, 2).toDouble(),
        ) *
        k;
    if (rx < 0.3 || ry < 0.3) return;
    final hi = _lit(color, _lightDir);
    final mid = _lit(color, -cam.forward);
    final lo = _lit(color, (-cam.forward - _lightDir).unit);
    final r = math.max(rx, ry);
    canvas.drawOval(
      Rect.fromCenter(center: o, width: 2 * rx, height: 2 * ry),
      _fill
        ..shader = ui.Gradient.radial(
          o + Offset(_highlight.dx * rx, _highlight.dy * ry),
          r * 1.35,
          [hi, mid, lo],
          const [0, 0.5, 1],
        ),
    );
    _fill.shader = null;
  }

  /// A sphere of radius [r] at [c].
  void ball(_V c, double r, Color color) => ellipsoid(c, _V(r, r, r), color);

  /// A tube of radius [r] along [pts] (the stem): a lit band with a
  /// highlight on its lit side.
  void tube(List<_V> pts, double r, Color color) {
    if (pts.length < 2) return;
    final mid = pts[pts.length ~/ 2];
    final width = math.max(0.8, 2 * r * cam.scaleAt(mid));
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = cam.p(pts[i]);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    canvas
      ..drawPath(
        path,
        _line
          ..strokeWidth = width
          ..color = _lit(color, -cam.forward),
      )
      ..drawPath(
        path.shift(Offset(_highlight.dx, 0) * (width * 0.6)),
        _line
          ..strokeWidth = width * 0.35
          ..color = labShade(_lit(color, _lightDir), 0.25),
      );
  }

  /// A seedling leaf: the SphereGeometry(1) scaled (1.5, 0.05, 0.8), drawn
  /// as its flat outline turned like the leaf, lit on the side the camera
  /// sees, with a midrib (added).
  void leaf(_V origin, double k, _Leaf leaf, Color color) {
    final centre = origin + leaf.center * k;
    final pts = <Offset>[
      for (var i = 0; i < 28; i++)
        () {
          final a = i * 2 * math.pi / 28;
          final local = _V(
            _leafAxes.x * math.cos(a),
            0,
            _leafAxes.z * math.sin(a),
          );
          return cam.p(centre + leaf.turn(local) * k);
        }(),
    ];
    final up = leaf.turn(_V.up).unit;
    final n = cam.facing(up, centre) ? up : -up;
    fill(pts, _lit(color, n));
    final tip = leaf.turn(const _V(1, 0, 0)) * (_leafAxes.x * 0.85 * k);
    canvas.drawLine(
      cam.p(centre - tip),
      cam.p(centre + tip),
      _line
        ..strokeWidth = math.max(0.6, 0.08 * cam.scaleAt(centre) * k)
        ..color = _Colors.leafVein,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: the bench, the
/// pots with their soil, seeds, seedling and water, the label sprites and,
/// in step 4, the Sunlight Zone.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  /// Label text size in design px.
  final double labelSize;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final t = s.time;
    final g = _Gfx(canvas, s.cam);
    _paintBench(g);
    for (final pot in s.pots) {
      _paintShadow(g, pot);
    }
    final pots = [...s.pots]
      ..sort((a, b) => g.cam.depth(b.at(t)).compareTo(g.cam.depth(a.at(t))));
    final labels = <_Label>[];
    for (final pot in pots) {
      if (pot.glass) {
        _paintBeaker(g, pot);
      } else {
        _paintClayPot(g, pot);
      }
      labels.add((g.cam.p(_labelAt(pot)), _t(pot.id.labelKey)));
    }
    if (showLabels) {
      for (final (at, text) in labels) {
        _label(canvas, at, text);
      }
    }
    // The HTML zone is a page element over the canvas.
    if (s.step == 4) _paintZone(canvas, g.cam);
  }

  // ------------------------------------------------------------- bench

  /// The bench: its top and its front face (the sides are out of view).
  void _paintBench(_Gfx g) {
    const w = _benchHalfW, d = _benchHalfD, h = _benchH;
    final cam = g.cam;
    g
      ..fill([
        cam.p(const _V(-w, 0, -d)),
        cam.p(const _V(w, 0, -d)),
        cam.p(const _V(w, 0, d)),
        cam.p(const _V(-w, 0, d)),
      ], _lit(_Colors.bench, _V.up))
      ..fill([
        cam.p(const _V(-w, -h, d)),
        cam.p(const _V(w, -h, d)),
        cam.p(const _V(w, 0, d)),
        cam.p(const _V(-w, 0, d)),
      ], _lit(_Colors.bench, const _V(0, 0, 1)));
    // The lit front edge of the top.
    g.canvas.drawLine(
      cam.p(const _V(-w, 0, d)),
      cam.p(const _V(w, 0, d)),
      Paint()
        ..color = labShade(_lit(_Colors.bench, _V.up), 0.18)
        ..strokeWidth = 1.2,
    );
  }

  /// A soft shadow on the bench, cast away from the light (the HTML's PCF
  /// shadow map); fainter and wider the higher the pot is.
  void _paintShadow(_Gfx g, _Pot pot) {
    final t = scene.time;
    final p = pot.at(t);
    final k = pot.hover.at(t);
    final lift = p.y + _potH / 2 * k;
    final c = _V(p.x - lift / 3, 0, math.max(-_benchHalfD + 1, -lift * 2 / 3));
    final r = (pot.glass ? _beakerBottomR : _potBottomR + 0.4) * k;
    final spread = 1 + p.y * 0.03;
    final o = g.cam.p(c);
    final w = (g.cam.p(c + _V(r * spread, 0, 0)) - o).distance * 2.3;
    final h = (g.cam.p(c + _V(0, 0, r * spread)) - o).distance * 2.3;
    labGroundShadow(g.canvas, o, w, h, opacity: 0.38 / (1 + p.y / 6));
  }

  // -------------------------------------------------------------- pots

  /// Pot D's label rises above its seedling; the others stay 8 above the
  /// pot's base.
  _V _labelAt(_Pot pot) {
    final t = scene.time;
    final k = pot.hover.at(t);
    var y = _labelY;
    if (pot.id == _PotId.d) {
      y = math.max(y, _sproutY + _sproutTop * scene.progress + _labelClear);
    }
    return pot.at(t) + _V(0, y * k, 0);
  }

  /// buildPot(false), open at the top: the clay wall and rim, the inside
  /// of the far wall, the soil, the seed, the seedling and the drops seen
  /// through the opening.
  void _paintClayPot(_Gfx g, _Pot pot) {
    final s = scene;
    final t = s.time;
    final cam = g.cam;
    final canvas = g.canvas;
    final base = pot.at(t);
    final k = pot.hover.at(t);
    _V w(double y) => base + _V(0, y * k, 0);
    final rimBody =
        _potBottomR + (_potTopR - _potBottomR) * (_rimBottom / _potH);
    g
      ..frustum(
        base,
        k,
        0,
        _rimBottom,
        _potBottomR,
        rimBody,
        _Colors.terracotta,
      )
      ..frustum(base, k, _rimBottom, _rimTop, _rimR, _rimR, _Colors.terracotta)
      ..disc(w(_rimTop), _rimR * k, _lit(_Colors.terracotta, _V.up));
    // The opening, showing the inside of the far wall.
    final opening = g.ring(w(_rimTop), _openingR * k);
    final bounds = _Gfx._polygon(opening).getBounds();
    canvas.drawPath(
      _Gfx._polygon(opening),
      Paint()
        ..shader = ui.Gradient.linear(bounds.topCenter, bounds.bottomCenter, [
          _lit(_Colors.terracotta, const _V(0, 0, 1)),
          labShade(_lit(_Colors.terracotta, const _V(0, 0, 1)), -0.55),
        ]),
    );
    // What is inside shows through the opening; what rises above the rim
    // shows over it.
    canvas
      ..save()
      ..clipPath(
        Path.combine(
          PathOperation.union,
          _Gfx._polygon(opening),
          Path()..addRect(Rect.fromLTRB(-1e4, -1e4, 1e4, cam.p(w(_rimTop)).dy)),
        ),
      );
    _paintSoilTop(g, pot, base, k);
    _paintSeed(g, pot, base, k);
    if (pot.id == _PotId.d) {
      _paintSprout(g, base, k);
      for (final drop in s.drops) {
        final at = drop.at(t);
        if (at != null) g.ball(at, _dropR, _Colors.drop);
      }
    }
    canvas.restore();
  }

  /// buildPot(true): Pot B's glass beaker with the soil, the seed and the
  /// flood water seen through it.
  void _paintBeaker(_Gfx g, _Pot pot) {
    final s = scene;
    final t = s.time;
    final cam = g.cam;
    final canvas = g.canvas;
    final base = pot.at(t);
    final k = pot.hover.at(t);
    _V w(double y) => base + _V(0, y * k, 0);
    double wallR(double y) =>
        _beakerBottomR + (_beakerTopR - _beakerBottomR) * (y / _beakerH);
    final glass = Paint()..color = _Colors.glass.withValues(alpha: 0.16);
    // The far wall and the base, through the glass.
    canvas.drawPath(
      g.frustumShape(
        base,
        k,
        0,
        _beakerH,
        _beakerBottomR,
        _beakerTopR,
        far: true,
      ),
      glass,
    );
    g.disc(
      w(_beakerBaseH),
      _beakerBottomR * k,
      _Colors.glass.withValues(alpha: 0.3),
    );
    // The flood water is one see-through layer (the HTML draws its front
    // faces): its side, and its surface.
    final f = pot.fill.at(t);
    final soilTop = pot.soil && f > 0 ? _soilY + _soilHalfH * f : 0.0;
    final level = pot.water.at(t);
    final wet = level > _waterFrom;
    final y0 = _waterY - _waterHalfH * level;
    final y1 = _waterY + _waterHalfH * level;
    void surface() {
      final r = (wallR(y1) - 0.06) * k;
      g.disc(w(y1), r, _Colors.waterTop);
      canvas.drawPath(
        _Gfx._polygon(g.ring(w(y1), r)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x99BFDBFE),
      );
    }

    // Water still below the top of the soil shows only around the soil.
    final under = wet && y1 < soilTop;
    if (under) surface();
    // The soil (opaque) inside.
    if (soilTop > 0) {
      final color = pot.wet ? _Colors.soilWet : _Colors.soilDry;
      g.frustum(
        base,
        k,
        _soilY - _soilHalfH * f,
        soilTop,
        _soilBottomR,
        _soilTopR,
        color,
      );
      _paintSoilTop(g, pot, base, k);
    }
    _paintSeed(g, pot, base, k);
    if (wet) {
      canvas.drawPath(
        g.frustumShape(base, k, y0, y1, wallR(y0) - 0.06, wallR(y1) - 0.06),
        Paint()..color = _Colors.water,
      );
      if (!under) surface();
    }
    // The near wall: a faint tint, the rim and two highlights.
    canvas.drawPath(
      g.frustumShape(base, k, 0, _beakerH, _beakerBottomR, _beakerTopR),
      glass,
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x8CE2E8F0);
    canvas
      ..drawPath(_Gfx._polygon(g.ring(w(_beakerH), _beakerTopR * k)), edge)
      ..drawPath(
        _Gfx._polygon(g.ring(w(0), _beakerBottomR * k)),
        edge..color = const Color(0x4DE2E8F0),
      );
    for (final (angle, width, alpha) in const [
      (2.45, 3.0, 0.32),
      (2.0, 1.5, 0.22),
      (0.75, 1.6, 0.18),
    ]) {
      final d = _V(math.cos(angle), 0, math.sin(angle));
      canvas.drawLine(
        cam.p(base + (d * (_beakerBottomR * 1.01) + const _V(0, 0.7, 0)) * k),
        cam.p(base + (d * (_beakerTopR * 1.01) + const _V(0, 6.5, 0)) * k),
        Paint()
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..color = _Colors.white.withValues(alpha: alpha),
      );
    }
  }

  /// The top of the soil (scale.y grows it up from y 3.2) with a few
  /// crumbs; dark once watered or flooded.
  void _paintSoilTop(_Gfx g, _Pot pot, _V base, double k) {
    final f = pot.fill.at(scene.time);
    if (!pot.soil || f <= 0) return;
    final color = pot.wet ? _Colors.soilWet : _Colors.soilDry;
    final top = base + _V(0, (_soilY + _soilHalfH * f) * k, 0);
    g.disc(top, _soilTopR * k, _lit(color, _V.up));
    final dot = math.max(0.6, 0.12 * g.cam.scaleAt(top) * k);
    final light = Paint()..color = labShade(_lit(color, _V.up), 0.22);
    final dark = Paint()..color = labShade(_lit(color, _V.up), -0.35);
    for (final (a, r, isLight) in _crumbs) {
      final at = g.cam.p(
        top + _V(math.cos(a), 0, math.sin(a)) * (r * _soilTopR * k),
      );
      g.canvas.drawCircle(at, dot, isLight ? light : dark);
    }
  }

  /// The bean seed: it bounces in, then (time-lapse) swells in Pot D and
  /// Pot B; Pot B's turns dark (rots).
  void _paintSeed(_Gfx g, _Pot pot, _V base, double k) {
    if (!pot.seed) return;
    final p = scene.progress;
    final swell = switch (pot.id) {
      _PotId.d => _swellMoist * p,
      _PotId.b => _swellFlooded * p,
      _PotId.a => 0.0,
    };
    final rotten = pot.id == _PotId.b && p > _rotFrom;
    final axes = _V(
      (_seedShape.x + swell) * _seedR * k,
      (_seedShape.y + swell) * _seedR * k,
      (_seedShape.z + swell) * _seedR * k,
    );
    g.ellipsoid(
      base + _V(0, pot.seedY.at(scene.time) * k, 0),
      axes,
      rotten ? _Colors.seedRotten : _Colors.seed,
    );
  }

  /// Pot D's seedling: the curved stem and its two leaves, scaled by the
  /// growth progress from the sprout origin (y 6).
  void _paintSprout(_Gfx g, _V base, double k) {
    final p = scene.progress;
    if (p <= 0.001) return;
    final origin = base + _V(0, _sproutY * k, 0);
    final sk = k * p;
    g.tube(
      [
        for (var i = 0; i <= _stemSamples; i++)
          origin +
              _V(
                    math.sin(i / _stemSamples * math.pi) * _stemBend,
                    _stemLength * i / _stemSamples,
                    0,
                  ) *
                  sk,
      ],
      _stemR * sk,
      _Colors.stem,
    );
    final leaves = [..._leaves]
      ..sort(
        (a, b) => g.cam
            .depth(origin + b.center * sk)
            .compareTo(g.cam.depth(origin + a.center * sk)),
      );
    for (final leaf in leaves) {
      g.leaf(origin, sk, leaf, _Colors.leaf);
    }
  }

  // ------------------------------------------------------------- labels

  /// A label sprite (HTML `updateSpriteText`): a rounded chip with bold
  /// text, dark with an amber border (light: white with a darker amber
  /// border), centred on [at].
  void _label(Canvas canvas, Offset at, String text) {
    final tp = texts.get(
      text,
      labelSize,
      isDark ? _Colors.white : _Colors.slate900,
    );
    final padX = _TextCache.padX(labelSize);
    final padY = _TextCache.padY(labelSize);
    final rect = Rect.fromCenter(
      center: at,
      width: tp.width + 2 * padX,
      height: tp.height + 2 * padY,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 3));
    canvas
      ..drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = const Color(0x40000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawRRect(
        rr,
        Paint()..color = isDark ? _Colors.labelBgDark : _Colors.labelBgLight,
      )
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = isDark ? _Colors.labelBorderDark : _Colors.labelBorderLight,
      );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  /// HTML `.sunlight-zone`: a dashed amber box around the pots' places in
  /// the sun (brighter while a pot is over it) with a sun and its caption.
  void _paintZone(Canvas canvas, _Cam cam) {
    final rect = cam.boxRect(
      const _V(-_zoneHalfW, _zoneBottom, 0),
      const _V(_zoneHalfW, _zoneTop, 0),
    );
    final rr = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_zoneRadius),
    );
    canvas.drawRRect(
      rr,
      Paint()..color = scene.zoneHot ? _Colors.zoneHot : _Colors.zoneFill,
    );
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.zoneBorder,
    );
    final size = labelSize * 1.2;
    final tp = texts.get(_t('sunlight_zone'), size, _Colors.zoneText);
    final sun = size * 0.75;
    final width = sun * 2 + size * 0.4 + tp.width;
    final mid = Offset(rect.center.dx, rect.bottom - size * 0.95);
    final left = mid.dx - width / 2;
    final c = Offset(left + sun, mid.dy);
    final ray = Paint()
      ..color = _Colors.zoneText
      ..strokeWidth = math.max(1.2, sun * 0.16)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, sun * 0.42, Paint()..color = _Colors.zoneText);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * (sun * 0.62), c + d * (sun * 0.95), ray);
    }
    tp.paint(
      canvas,
      Offset(left + sun * 2 + size * 0.4, mid.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
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
