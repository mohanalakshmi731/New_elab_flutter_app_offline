// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 1 • Activity 1
/// The Essence of Science: Curiosity and Observation.
///
/// Native Flutter port of
/// `Cl6S-Ch1-A1-The_Essence_of_Science__Curiosity_and_Observation.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML camera: position (0, 8, 18), look-at
/// (0, 0, 0), 45° field of view, and its close-ups of the water bucket.
/// The HTML's 2D "interactive UI layer" (the Test Area and the hypothesis
/// cards) is a widget over the canvas ([_HypothesisBoard]).
///
/// Scenario 1 (The Mystery of the Pen): a pen on a desk has stopped
/// writing. Tapping the notebook makes it scratch the page (observation);
/// the 'Ink is Finished' card dragged into the Test Area is the first
/// hypothesis. Tapping the pen unscrews it and tapping the refill pulls it
/// out: it is full, so the guess fails (red cross). The 'Ink has Dried'
/// card brings a cup of warm water; the refill dragged into it dissolves
/// the dried ink, the pen screws back together and, tapped again, writes a
/// blue line (green tick). 'Observe Conclusion' opens the summary.
///
/// Scenario 2 (The Flat Bicycle Tyre): tapping the flat rear tyre makes it
/// squish and hiss; the 'The tyre has a leak' card brings a pump, a tyre
/// lever and a bucket of water. The pump nozzle dragged onto the valve and
/// three taps on the pump handle inflate the tyre, which goes flat again.
/// The lever dragged onto the rim pries the tyre off; the inner tube is
/// dragged out and into the bucket, where bubbles rise from one spot.
/// Tapping them rings the leak in red, and 'Observe Conclusion' ends the
/// lab with confetti.
class Ch1A1TheEssenceOfSciencePage extends StatefulWidget {
  const Ch1A1TheEssenceOfSciencePage({super.key});

  @override
  State<Ch1A1TheEssenceOfSciencePage> createState() => _EssenceLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'pop' (a card dropped, the refill or the inner tube pulled out),
/// 'snap' (the pen unscrewed, a pump stroke, a tool snapping into place)
/// and 'scratch' (the pen on the paper) → click (`science/click.mp3`);
/// 'hiss' (air escaping the tyre) → hiss (`science/dropdown.mp3`, the
/// sidebar's whoosh reused); 'chime' / 'success' (the conclusion button
/// appears, the leak found, the summary) → success (`math/success.mp3`).
/// A missed drop (added) plays wrong (`science/error.mp3`). The shell plays
/// toggle (`science/dropdown.mp3`), scenario (`science/page_open.mp3`) and
/// curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; HTML `pop`, `snap` and `scratch`.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A friendly toast (shell).
  correct('audio/class6/math/success.mp3'),

  /// A missed drop or a press out of turn (added).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `chime` / `success`: 'Observe Conclusion' appears, the leak is
  /// found and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `hiss`: air escaping the flat tyre.
  hiss('audio/class6/science/dropdown.mp3');

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
/// (material colours) and of its canvas textures and sprites.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
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
  /// `scene.background`: 0xf1f5f9 (the desk), 0xe2e8f0 (the bicycle). The
  /// HTML keeps them in both themes.
  static const Color sceneS1 = slate100;
  static const Color sceneS2 = slate200;

  /// Desk `0x8b5a2b` and the notebook texture: white paper, `#93c5fd`
  /// ruled lines, `#fca5a5` margin, `0x94a3b8` spiral rings.
  static const Color desk = Color(0xFF8B5A2B);
  static const Color paper = white;
  static const Color paperEdge = Color(0xFFE5E7EB);
  static const Color ruled = blue300;
  static const Color margin = Color(0xFFFCA5A5);
  static const Color spiral = slate400;

  /// `createScratchTexture`: grey scratches `rgba(0, 0, 0, 0.2)` and the
  /// `#2563eb` written line.
  static const Color scratch = Color(0x33000000);
  static const Color writtenLine = blue600;

  /// The pen: body `0x1d4ed8`, clip `0xcbd5e1`, tip `0x94a3b8`, refill
  /// tube white at 0.45, ink `0x2563eb`.
  static const Color penBody = Color(0xFF1D4ED8);
  static const Color penClip = slate300;
  static const Color penTip = slate400;
  static const Color refillTube = white;
  static const Color ink = blue600;

  /// Cup: white glass at 0.3, warm water `0x38bdf8` at 0.6 and the
  /// dissolving ink `0x1d4ed8`.
  static const Color cupGlass = white;
  static const Color warmWater = Color(0xFF38BDF8);
  static const Color dissolved = penBody;

  /// Ground `0x64748b`, frame `0xef4444`, tyres, seat and handlebar
  /// `0x1e293b`, rims and spokes `0xcbd5e1`, valve white.
  static const Color ground = slate500;
  static const Color frame = red500;
  static const Color rubber = slate800;
  static const Color rim = slate300;
  static const Color valve = white;

  /// Pump `0x94a3b8` with a `0x1e293b` base, handle and hose and a
  /// `0x334155` nozzle; tyre lever `0x94a3b8`.
  static const Color pump = slate400;
  static const Color pumpDark = slate800;
  static const Color nozzle = slate700;
  static const Color lever = slate400;

  /// Bucket `0x94a3b8` (its inside a shade darker, added), water
  /// `0x7dd3fc` at 0.8, inner tube `0x0f172a`, white bubbles at 0.5 and
  /// the red leak ring `0xef4444`.
  static const Color bucket = slate400;
  static const Color bucketInside = slate600;
  static const Color bucketWater = Color(0xFF7DD3FC);
  static const Color tube = slate900;
  static const Color bubble = white;
  static const Color leakRing = red500;

  /// Text sprites: `#1e293b` chip, `#6366f1` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = indigo500;
  static const Color chipText = white;

  /// The '?' icon sprite: white disc, `#1e293b` mark.
  static const Color questionDisc = white;
  static const Color questionMark = slate800;

  // ------------------------------------------- HTML interactive UI layer
  /// `#test-area`: `bg-[#1e3a8a]/95`, `border-[#3b82f6]`; `#drop-target`:
  /// `bg-[#1e40af]/80`, `border-[#60a5fa]` dashed, hint `#93c5fd`.
  static const Color testArea = Color(0xF21E3A8A);
  static const Color testBorder = blue500;
  static const Color dropBg = Color(0xCC1E40AF);
  static const Color dropBorder = blue400;
  static const Color dropHint = blue300;

  /// canvas-confetti's default colours (the HTML passes none).
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
    canvasBg: _Colors.slate900, // dark:bg-[#0f172a]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
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
    canvasBg: _Colors.slate100, // bg-[#f1f5f9]
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// `sN_hud_M` are the HTML "Current Task" lines and `sN_focus_M` /
// `sN_act_M` / `sN_obs_M` the HTML step concept, action and observation
// ('Click' → 'Tap'). The sidebar's current instruction is the HUD line
// without its "Step N:" prefix. The summaries keep the HTML's bold words
// between `**` marks. Keys marked "Added." are new texts the HTML did not
// have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Essence of Science: Curiosity and Observation',
    'app_subtitle': 'Class 6. The Wonderful World of Science',
    'scen_1_opt': 'Scenario 1: The Mystery of the Pen',
    'scen_2_opt': 'Scenario 2: The Flat Bicycle Tyre',
    's1_desc':
        'To use the scientific method to diagnose and solve the problem of a pen that has stopped writing.',
    's2_desc':
        'To use the scientific method to find the exact source of a leak in a bicycle tyre.',
    's1_hud_1': 'Step 1: Tap on the notebook to try and write with the pen.',
    's1_hud_2': "Step 2: Drag the 'Ink is Finished' card to the Test Area.",
    's1_hud_3': 'Step 3: Tap the pen to unscrew it and look inside.',
    's1_hud_4': 'Step 4: Tap on the ink refill to pull it out and inspect it.',
    's1_hud_5':
        "Step 5: The first guess was wrong. Drag the 'Ink has Dried' card to the Test Area.",
    's1_hud_6': 'Step 6: Drag the ink refill tip into the cup of warm water.',
    's1_hud_7':
        'Step 7: Tap the reassembled pen to try writing on the notebook again.',
    's1_hud_8': "Step 8: Tap 'Observe Conclusion' to understand the process.",
    's2_hud_1': 'Step 1: Tap on the flat rear tyre to observe the problem.',
    's2_hud_2': "Step 2: Drag the 'The tyre has a leak' card to the Test Area.",
    's2_hud_3': "Step 3: Drag the pump nozzle to the tyre's valve.",
    's2_hud_4': 'Step 4: Tap the pump handle to inflate the tyre.',
    's2_hud_5': 'Step 5: Drag the tyre lever to the rim to pry the tyre off.',
    's2_hud_6': 'Step 6: Drag the inner tube completely out of the tyre.',
    's2_hud_7': 'Step 7: Drag the inner tube into the bucket of water.',
    's2_hud_8': 'Step 8: Tap on the bubbles to identify the leak.',
    's2_hud_9': "Step 9: Tap 'Observe Conclusion'.",
    's1_focus_1': 'Observation',
    's1_act_1': 'Tap on the notebook.',
    's1_obs_1': "The pen doesn't write, only a scratch mark appears.",
    's1_focus_2': 'Hypothesis 1',
    's1_act_2': "Drag 'Ink is Finished' card.",
    's1_obs_2': 'We guess the ink might be over.',
    's1_focus_3': 'Experimentation (Setup)',
    's1_act_3': 'Tap pen to open.',
    's1_obs_3': 'Pen unscrews to reveal the refill.',
    's1_focus_4': 'Experimentation (Test)',
    's1_act_4': 'Tap on the refill.',
    's1_obs_4': 'The refill is full! Guess 1 is wrong (FAILED).',
    's1_focus_5': 'Hypothesis 2',
    's1_act_5': "Drag 'Ink has Dried' card.",
    's1_obs_5': 'We form a new guess based on the new information.',
    's1_focus_6': 'Experimentation (Test)',
    's1_act_6': 'Drag refill to water.',
    's1_obs_6': 'Dried ink dissolves in warm water.',
    's1_focus_7': 'Analysis',
    's1_act_7': 'Tap pen to write.',
    's1_obs_7': 'The pen writes! Our solution worked (SUCCESS).',
    's1_focus_8': 'Conclusion',
    's1_act_8': "Tap 'Observe Conclusion'.",
    's1_obs_8': 'The scientific method helps solve problems step-by-step.',
    's2_focus_1': 'Observation',
    's2_act_1': 'Tap the flat tyre.',
    's2_obs_1': 'It squishes and makes a hissing sound.',
    's2_focus_2': 'Hypothesis',
    's2_act_2': "Drag 'Leak' card.",
    's2_obs_2': 'We guess there is a hole in the tyre.',
    's2_focus_3': 'Experimentation (Setup)',
    's2_act_3': 'Connect pump.',
    's2_obs_3': 'Preparing to test if it holds air.',
    's2_focus_4': 'Experimentation (Test 1)',
    's2_act_4': 'Tap pump handle.',
    's2_obs_4': 'Tyre inflates but deflates again. Leak confirmed!',
    's2_focus_5': 'Experimentation (Setup)',
    's2_act_5': 'Use tyre lever.',
    's2_obs_5': 'Opening the tyre to find the exact leak.',
    's2_focus_6': 'Experimentation (Extract)',
    's2_act_6': 'Drag out inner tube.',
    's2_obs_6': 'The inner tube is ready for testing.',
    's2_focus_7': 'Experimentation (Test 2)',
    's2_act_7': 'Submerge tube in water.',
    's2_obs_7': 'Bubbles escape from a specific spot.',
    's2_focus_8': 'Analysis',
    's2_act_8': 'Tap the bubbles.',
    's2_obs_8': 'The exact location of the hole is found (SUCCESS).',
    's2_focus_9': 'Conclusion',
    's2_act_9': "Tap 'Observe Conclusion'.",
    's2_obs_9': 'Systematic testing finds precise answers.',
    's1_summary':
        '**Mystery Solved!** You used the scientific method! You **Observed** a problem, asked a **Question**, made a **Guess (Hypothesis)**, **Tested** it, and when it failed, you tried a new guess until you **Analyzed** a successful result.',
    's2_summary':
        "**Leak Found!** By following the steps: **Observe** (flat tyre), **Guess** (leak), **Test** (pump it up, then use water), you were able to **Analyze** the results (bubbles) to pinpoint the exact problem. That's science in action!",
    // Summary and success modals.
    'sc_complete': 'Scenario {n} Complete!',
    'select_next_sc_msg':
        'Scenario 1 completed. Please select the next scenario from the sidebar!',
    'close_btn': 'Close',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You learned how to apply the scientific method by making observations, forming hypotheses, testing them, and analyzing results!',
    'restart_lab': 'Restart Entire Lab',
    'btn_conclude': 'Observe Conclusion',
    // Interactive UI layer (Test Area and hypothesis cards).
    'test_area': 'Test Area',
    'drag_card_here': 'Drag Hypothesis Here',
    'card_ink_fin': 'Ink is Finished',
    'card_ink_dry': 'Ink has Dried',
    'card_leak': 'The tyre has a leak',
    // Scene labels (text sprites).
    'lbl_notebook': 'Notebook',
    'lbl_pen': 'Pen',
    'lbl_water': 'Warm Water',
    'lbl_tyre': 'Flat Tyre',
    'lbl_pump': 'Pump',
    'lbl_bucket': 'Water Bucket',
    'lbl_lever': 'Tyre Lever',
    // Steps accordion (HTML teacher board).
    'concept_exp': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Task',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // HTML toasts (English only in the HTML).
    'drag_lever_hint': 'Drag the tyre lever to pry the tyre off!',
    'drag_tube_hint': 'Drag the inner tube OUT of the tyre!',
    // Added.
    'pending': 'Do this step to see the result.',
    'not_yet': 'Not yet! {task}',
    'lbl_refill': 'Ink Refill',
    'lbl_nozzle': 'Pump Nozzle',
    'lbl_handle': 'Pump Handle',
    'lbl_tube': 'Inner Tube',
    'lbl_bubbles': 'Bubbles',
    'miss_card': 'Missed! Drop the card inside the Test Area.',
    'miss_refill': 'Missed! Drop the ink refill into the cup of warm water.',
    'miss_pen': 'Bring the pen onto the notebook to write.',
    'miss_nozzle': "Missed! Drop the pump nozzle on the tyre's valve.",
    'miss_lever': 'Missed! Drop the tyre lever on the rim of the flat tyre.',
    'miss_tube_out': 'Pull the inner tube further away from the tyre.',
    'miss_bucket': 'Missed! Drop the inner tube into the bucket of water.',
    'scene_s1':
        'A desk with a ruled notebook and a blue pen that has stopped writing',
    'scene_s2': 'A bicycle with a flat rear tyre standing on the ground',
  },
  'hi': {
    'app_title': 'विज्ञान का सार: जिज्ञासा और अवलोकन',
    'app_subtitle': 'कक्षा 6. विज्ञान की अद्भुत दुनिया',
    'scen_1_opt': 'परिदृश्य 1: पेन का रहस्य',
    'scen_2_opt': 'परिदृश्य 2: फ्लैट साइकिल टायर',
    's1_desc':
        'वैज्ञानिक पद्धति का उपयोग करके उस पेन की समस्या का निदान और समाधान करना जिसने लिखना बंद कर दिया है।',
    's2_desc':
        'वैज्ञानिक पद्धति का उपयोग करके साइकिल के टायर में रिसाव के सटीक स्रोत का पता लगाना।',
    's1_hud_1': 'चरण 1: पेन से लिखने का प्रयास करने के लिए नोटबुक पर टैप करें।',
    's1_hud_2':
        "चरण 2: 'स्याही खत्म हो गई है' कार्ड को परीक्षण क्षेत्र में खींचें।",
    's1_hud_3': 'चरण 3: पेन को खोलने और अंदर देखने के लिए उस पर टैप करें।',
    's1_hud_4':
        'चरण 4: जांच करने के लिए स्याही रिफिल पर टैप करके उसे बाहर निकालें।',
    's1_hud_5':
        "चरण 5: पहला अनुमान गलत था। 'स्याही सूख गई है' कार्ड को परीक्षण क्षेत्र में खींचें।",
    's1_hud_6': 'चरण 6: स्याही रिफिल टिप को गर्म पानी के कप में खींचें।',
    's1_hud_7':
        'चरण 7: फिर से नोटबुक पर लिखने का प्रयास करने के लिए जुड़े हुए पेन पर टैप करें।',
    's1_hud_8':
        "चरण 8: प्रक्रिया को समझने के लिए 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_1': 'चरण 1: समस्या का निरीक्षण करने के लिए फ्लैट टायर पर टैप करें।',
    's2_hud_2':
        "चरण 2: 'टायर में रिसाव है' कार्ड को परीक्षण क्षेत्र में खींचें।",
    's2_hud_3': 'चरण 3: पंप नोजल को टायर के वाल्व तक खींचें।',
    's2_hud_4': 'चरण 4: टायर में हवा भरने के लिए पंप हैंडल पर टैप करें।',
    's2_hud_5': 'चरण 5: टायर को निकालने के लिए टायर लीवर को रिम तक खींचें।',
    's2_hud_6': 'चरण 6: भीतरी ट्यूब को पूरी तरह से टायर से बाहर खींचें।',
    's2_hud_7': 'चरण 7: भीतरी ट्यूब को पानी की बाल्टी में खींचें।',
    's2_hud_8': 'चरण 8: रिसाव की पहचान करने के लिए बुलबुले पर टैप करें।',
    's2_hud_9': "चरण 9: 'निष्कर्ष देखें' पर टैप करें।",
    's1_focus_1': 'अवलोकन',
    's1_act_1': 'नोटबुक पर टैप करें।',
    's1_obs_1': 'पेन नहीं लिखता, केवल एक खरोंच का निशान दिखाई देता है।',
    's1_focus_2': 'परिकल्पना 1',
    's1_act_2': "'स्याही खत्म' कार्ड खींचें।",
    's1_obs_2': 'हम अनुमान लगाते हैं कि स्याही खत्म हो सकती है।',
    's1_focus_3': 'प्रयोग (सेटअप)',
    's1_act_3': 'खोलने के लिए पेन पर टैप करें।',
    's1_obs_3': 'रिफिल दिखाने के लिए पेन खुलता है।',
    's1_focus_4': 'प्रयोग (परीक्षण)',
    's1_act_4': 'रिफिल पर टैप करें।',
    's1_obs_4': 'रिफिल भरा हुआ है! अनुमान 1 गलत है (विफल)।',
    's1_focus_5': 'परिकल्पना 2',
    's1_act_5': "'स्याही सूखी' कार्ड खींचें।",
    's1_obs_5': 'हम नई जानकारी के आधार पर एक नया अनुमान लगाते हैं।',
    's1_focus_6': 'प्रयोग (परीक्षण)',
    's1_act_6': 'रिफिल को पानी में ले जाएं।',
    's1_obs_6': 'सूखी स्याही गर्म पानी में घुल जाती है।',
    's1_focus_7': 'विश्लेषण',
    's1_act_7': 'लिखने के लिए पेन पर टैप करें।',
    's1_obs_7': 'पेन लिखता है! हमारा समाधान काम कर गया (सफल)।',
    's1_focus_8': 'निष्कर्ष',
    's1_act_8': "'निष्कर्ष देखें' पर टैप करें।",
    's1_obs_8':
        'वैज्ञानिक पद्धति समस्याओं को चरण-दर-चरण हल करने में मदद करती है।',
    's2_focus_1': 'अवलोकन',
    's2_act_1': 'फ्लैट टायर पर टैप करें।',
    's2_obs_1': 'यह दबता है और फुफकारने की आवाज करता है।',
    's2_focus_2': 'परिकल्पना',
    's2_act_2': "'रिसाव' कार्ड खींचें।",
    's2_obs_2': 'हम अनुमान लगाते हैं कि टायर में छेद है।',
    's2_focus_3': 'प्रयोग (सेटअप)',
    's2_act_3': 'पंप कनेक्ट करें।',
    's2_obs_3': 'यह जांचने की तैयारी कि क्या यह हवा रोकता है।',
    's2_focus_4': 'प्रयोग (परीक्षण 1)',
    's2_act_4': 'पंप हैंडल पर टैप करें।',
    's2_obs_4': 'टायर फूलता है लेकिन फिर से हवा निकल जाती है। रिसाव की पुष्टि!',
    's2_focus_5': 'प्रयोग (सेटअप)',
    's2_act_5': 'टायर लीवर का प्रयोग करें।',
    's2_obs_5': 'सटीक रिसाव खोजने के लिए टायर खोलना।',
    's2_focus_6': 'प्रयोग (निकालें)',
    's2_act_6': 'भीतरी ट्यूब बाहर निकालें।',
    's2_obs_6': 'भीतरी ट्यूब परीक्षण के लिए तैयार है।',
    's2_focus_7': 'प्रयोग (परीक्षण 2)',
    's2_act_7': 'ट्यूब को पानी में डुबोएं।',
    's2_obs_7': 'एक विशिष्ट स्थान से बुलबुले निकलते हैं।',
    's2_focus_8': 'विश्लेषण',
    's2_act_8': 'बुलबुले पर टैप करें।',
    's2_obs_8': 'छेद का सटीक स्थान मिल गया है (सफल)।',
    's2_focus_9': 'निष्कर्ष',
    's2_act_9': "'निष्कर्ष देखें' पर टैप करें।",
    's2_obs_9': 'व्यवस्थित परीक्षण सटीक उत्तर ढूँढता है।',
    's1_summary':
        '**रहस्य सुलझ गया!** आपने वैज्ञानिक पद्धति का उपयोग किया! आपने एक समस्या का **अवलोकन** किया, एक **प्रश्न** पूछा, एक **अनुमान (परिकल्पना)** लगाया, उसका **परीक्षण** किया, और जब वह विफल हो गया, तो आपने तब तक एक नया अनुमान लगाया जब तक कि आपने एक सफल परिणाम का **विश्लेषण** नहीं किया।',
    's2_summary':
        '**रिसाव मिल गया!** चरणों का पालन करके: **अवलोकन** (फ्लैट टायर), **अनुमान** (रिसाव), **परीक्षण** (हवा भरना, फिर पानी का उपयोग करना), आप सटीक समस्या का पता लगाने के लिए परिणामों (बुलबुले) का **विश्लेषण** करने में सक्षम थे। यह क्रिया में विज्ञान है!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'select_next_sc_msg':
        'परिदृश्य 1 पूरा हुआ। कृपया साइडबार से अगला परिदृश्य चुनें!',
    'close_btn': 'बंद करें',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने अवलोकन करके, परिकल्पनाएं बनाकर, उनका परीक्षण करके और परिणामों का विश्लेषण करके वैज्ञानिक पद्धति को लागू करना सीखा!',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'btn_conclude': 'निष्कर्ष देखें',
    'test_area': 'परीक्षण क्षेत्र',
    'drag_card_here': 'परिकल्पना यहाँ खींचें',
    'card_ink_fin': 'स्याही खत्म हो गई है',
    'card_ink_dry': 'स्याही सूख गई है',
    'card_leak': 'टायर में रिसाव है',
    'lbl_notebook': 'नोटबुक',
    'lbl_pen': 'पेन',
    'lbl_water': 'गर्म पानी',
    'lbl_tyre': 'फ्लैट टायर',
    'lbl_pump': 'पंप',
    'lbl_bucket': 'पानी की बाल्टी',
    'lbl_lever': 'टायर लीवर',
    'concept_exp': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'कार्य',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    // Added (the HTML shows these two toasts in English only).
    'drag_lever_hint': 'टायर निकालने के लिए टायर लीवर को खींचें!',
    'drag_tube_hint': 'भीतरी ट्यूब को टायर से बाहर खींचें!',
    // Added.
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'not_yet': 'अभी नहीं! {task}',
    'lbl_refill': 'स्याही रिफिल',
    'lbl_nozzle': 'पंप नोजल',
    'lbl_handle': 'पंप हैंडल',
    'lbl_tube': 'भीतरी ट्यूब',
    'lbl_bubbles': 'बुलबुले',
    'miss_card': 'निशाना चूक गया! कार्ड को परीक्षण क्षेत्र के अंदर छोड़ें।',
    'miss_refill':
        'निशाना चूक गया! स्याही रिफिल को गर्म पानी के कप में छोड़ें।',
    'miss_pen': 'लिखने के लिए पेन को नोटबुक पर लाएँ।',
    'miss_nozzle': 'निशाना चूक गया! पंप नोजल को टायर के वाल्व पर छोड़ें।',
    'miss_lever': 'निशाना चूक गया! टायर लीवर को फ्लैट टायर के रिम पर छोड़ें।',
    'miss_tube_out': 'भीतरी ट्यूब को टायर से और दूर खींचें।',
    'miss_bucket': 'निशाना चूक गया! भीतरी ट्यूब को पानी की बाल्टी में छोड़ें।',
    'scene_s1':
        'एक मेज़ पर रेखांकित नोटबुक और एक नीला पेन जिसने लिखना बंद कर दिया है',
    'scene_s2': 'ज़मीन पर खड़ी एक साइकिल जिसका पिछला टायर फ्लैट है',
  },
};

/// Number of steps of each scenario (the HTML `steps` arrays; the last one
/// is 'Observe Conclusion').
const List<int> _stepCounts = [8, 9];

/// Number of scenarios (the HTML scenario selector).
const int _scenarioCount = 2;

/// The HUD line [hud] without its "Step N:" / "चरण N:" prefix: the
/// instruction the sidebar shows next to its own step counter.
String _withoutStepPrefix(String hud) =>
    hud.replaceFirst(RegExp(r'^[^:]{1,14}:\s*'), '');

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.done,
    required this.result,
  });

  /// HTML `concept` ("Observation", "Hypothesis 1", …).
  final String focus;

  /// What to do now (the HUD line without its prefix).
  final String action;

  /// The HTML `action`, shown in the accordion.
  final String done;

  /// HTML `observation`, shown once the step is done.
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
        action: _withoutStepPrefix(t('s${n}_hud_$i')),
        done: t('s${n}_act_$i'),
        result: t('s${n}_obs_$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The concept
/// ("Observation", "Hypothesis 1", …) is shown with the current step, as
/// in the HTML.
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

/// Splits [text] at its `**` marks into runs (text, bold): the HTML
/// summary's `<strong>` / `<b>` words.
List<(String, bool)> _boldRuns(String text) {
  final parts = text.split('**');
  return [
    for (var i = 0; i < parts.length; i++)
      if (parts[i].isNotEmpty) (parts[i], i.isOdd),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 8, 18) looking at `controls.target` (0, 0, 0).
const double _fovDegrees = 45;
const double _near = 0.1;
const _View _homeView = _View(_V(0, 8, 18), _V.zero, 0);

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a part (short drags must pick it up).
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
/// top). The canvas 'Observe Conclusion' button sits [_hudReserve] (x UI
/// scale) above the bottom while the HUD is shown.
const double _hudBand = 54;
const double _hudReserve = 66;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene in each scenario (the HTML camera is
/// zoom 1); it is never drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.3, 1.2];
const double _minZoom = 0.3;

/// Nothing closer to the camera plane than this is drawn (the parts of the
/// bicycle scene behind a close-up camera).
const double _clipDepth = 0.5;

/// HTML `setTimeout`s and tweens shared by both scenarios: a missed drop
/// glides back (added, 300 ms) and the Test Area fades out (300 ms).
const double _returnSeconds = 0.3;
const double _boardFadeSeconds = 0.3;

// ------------------------------------------------- scenario 1: the desk

/// Desk `PlaneGeometry(30, 20)` at y = -2.
const double _deskY = -2;
const double _deskHalfX = 15;
const double _deskHalfZ = 10;

/// Notebook `BoxGeometry(8, 0.4, 10)` at (-3, -1.8, 0); its paper texture
/// (512 px for 8 x 10 units): ruled lines every 40 px from y = 50, the
/// margin at x = 60. Spiral rings `TorusGeometry(0.2, 0.06)` every 0.5
/// along its left edge.
const _V _notebookPos = _V(-3, -1.8, 0);
const _V _notebookSize = _V(8, 0.4, 10);
const double _paperTop = -1.6;
const double _texturePx = 512;
const double _ruleFirst = 50;
const double _ruleGap = 40;
const double _marginPx = 60;
const double _spiralR = 0.2;
const double _spiralTube = 0.06;
const _V _notebookLabelAt = _V(-3, 1, -6);

/// The scratch and the written line: `PlaneGeometry(4, 1)` patches on the
/// paper at notebook (0, 0.22, 0) and (0, 0.23, 2) (256 x 64 px textures).
const _V _scratchAt = _V(-3, -1.58, 0);
const _V _lineAt = _V(-3, -1.57, 2);

/// Pen group at (2, -1.5, 4), `rotation.z = -π/8`: body
/// `CylinderGeometry(0.2, 0.2, 3)` at y 1.5, clip `BoxGeometry(0.1, 1.2,
/// 0.15)` at (0.22, 2.3, 0), tip group at y -0.3 with a
/// `ConeGeometry(0.2, 0.6)`, refill `CylinderGeometry(0.1, 0.1, 3.2)` (ink
/// 0.06 x 2.8) at tip y 1.6; label at (0, 4, 0).
const _V _penHome = _V(2, -1.5, 4);
const double _penTiltHome = -math.pi / 8;
const double _penR = 0.2;
const double _penLength = 3;
const double _coneH = 0.6;
const double _refillR = 0.1;
const double _refillLength = 3.2;
const double _inkR = 0.06;
const double _inkLength = 2.8;
const double _penLabelY = 4;

/// Step 1: the pen moves to (-1, -1, 2) (500 ms, Quadratic.Out) and wiggles
/// (`rotation.z` to π/8, 100 ms, yoyo, 3 repeats); the '?' sprite shows
/// for 1500 ms at (-1, 2, 2).
const _V _penTry = _V(-1, -1, 2);
const double _penMoveSeconds = 0.5;
const double _wiggleSeconds = 0.1;
const double _wiggleTilt = math.pi / 8;
const _V _questionS1 = _V(-1, 2, 2);
const double _questionS1Seconds = 1.5;

/// Step 3: the tip unscrews to y -1.5 and spins 4π (500 ms); 800 ms later
/// the step moves on.
const double _tipRest = -0.3;
const double _tipOpen = -1.5;
const double _tipTurns = 4 * math.pi;
const double _unscrewSeconds = 0.5;
const double _unscrewWait = 0.8;

/// Step 4: the refill slides up to tip y 4.5 (400 ms, Quadratic.Out); the
/// failed card is shown 1500 ms.
const double _refillRest = 1.6;
const double _refillPulled = 4.5;
const double _pullSeconds = 0.4;
const double _verdictSeconds = 1.5;

/// Cup group at (3, -0.8, 1): `CylinderGeometry(1.2, 1, 2)` glass and
/// `CylinderGeometry(1.15, 0.95, 1.6)` water at y -0.1; it pops in from
/// scale 0.1 (600 ms, Elastic.Out). Label at (0, 2.5, 0).
const _V _cupPos = _V(3, -0.8, 1);
const double _cupTopR = 1.2;
const double _cupBottomR = 1;
const double _cupH = 2;
const double _waterTopR = 1.15;
const double _waterBottomR = 0.95;
const double _waterH = 1.6;
const double _waterY = -0.1;
const double _cupPopSeconds = 0.6;
const double _popFrom = 0.1;
const double _cupLabelY = 2.5;

/// Step 6: a refill dropped within 3 of the cup goes in (300 ms), the ink
/// dissolves for 2000 ms, then the pen screws back together (500 ms). The
/// refill stands tip down on the cup's bottom here (the HTML turns it
/// upside down, tip up out of the water) and glides back into the pen
/// (added, 400 ms; the HTML puts it back at once).
const double _cupRange = 3;
const _V _refillInCup = _V(3, -0.2, 1);
const double _dunkSeconds = 0.3;
const double _soakSeconds = 2;
const double _refillBackSeconds = 0.4;
const double _screwSeconds = 0.5;

/// HTML `createDissolveParticles`: 20 spheres (r 0.08) from cup (±0.25,
/// -1, ±0.25), rising 0.01–0.03 per frame, life -0.01 per frame.
const int _inkMotes = 20;
const double _inkMoteR = 0.08;

/// Step 7: the pen, released within 4 of the notebook, moves to the
/// notebook + (1, 1, 2) (500 ms) and wiggles (100 ms, yoyo, 4 repeats).
const double _notebookRange = 4;
const _V _penWrite = _V(-2, -0.8, 2);

// ------------------------------------------- scenario 2: the bicycle

/// Ground `PlaneGeometry(30, 20)` at y = -3.
const double _groundY = -3;
const double _groundHalfX = 15;
const double _groundHalfZ = 10;

/// Bicycle group at (0, -0.3, 0): wheels `TorusGeometry(2.5, 0.2)` at x
/// ±4 with rims `TorusGeometry(2.3, 0.1)`, eight spokes 4.6 long and a
/// valve `CylinderGeometry(0.05, 0.05, 0.4)` at the rear wheel's top
/// (0, 2.4, 0). The rear tyre starts flat (`scale.y = 0.7`).
const _V _bikePos = _V(0, -0.3, 0);
const double _wheelX = 4;
const double _wheelR = 2.5;
const double _wheelTube = 0.2;
const double _rimR = 2.3;
const double _rimTube = 0.1;
const double _spokeLength = 4.6;
const double _valveY = 2.4;
const double _valveH = 0.4;
const double _flat = 0.7;
const _V _tyreLabelAt = _V(-4, 3.7, 0);

/// Step 1: the tyre squishes to 0.55 (200 ms, yoyo); the '?' sprite shows
/// for 2000 ms at (-4, 3, 0).
const double _squished = 0.55;
const double _squishSeconds = 0.2;
const _V _questionS2 = _V(-4, 3, 0);
const double _questionS2Seconds = 2;

/// Step 2: pump, lever and bucket pop in from scale 0.1 (500 ms,
/// Elastic.Out, 100 ms apart).
const double _toolPopSeconds = 0.5;
const double _toolStagger = 0.1;

/// Pump group at (5, -3, 3): body `CylinderGeometry(0.3, 0.3, 5)`, base
/// `BoxGeometry(2, 0.2, 1)`, handle rod (0.1 x 4) at y 4 with a
/// `BoxGeometry(1.5, 0.2, 0.4)` grip on top, nozzle `CylinderGeometry(0.15,
/// 0.15, 0.6)` lying at (-2, 0.5, 0) and a hose `TubeGeometry` (r 0.08)
/// from (0, 0.5, 0). The HTML adds its label at (5, 4, 3) inside the
/// group; it is meant for that world point, (0, 7, 0) in the group.
const _V _pumpPos = _V(5, -3, 3);
const _V _nozzleHome = _V(-2, 0.5, 0);
const _V _hoseStart = _V(0, 0.5, 0);
const double _nozzleR = 0.15;
const double _nozzleLength = 0.6;
const double _hoseR = 0.08;
const double _handleRest = 4;
const double _handlePushed = 2;
const _V _pumpLabelAt = _V(0, 7, 0);

/// Step 3: a nozzle dropped within 6 of the valve connects (the HTML puts
/// it at (-3, 0, 3), near the tyre; here it sits on the valve).
const double _nozzleRange = 6;

/// Step 4: each stroke pushes the handle to y 2 (200 ms, yoyo) and pumps
/// the tyre 0.1 rounder (300 ms); once it is round, 500 ms later it hisses
/// flat again (2000 ms).
const double _strokeSeconds = 0.2;
const double _inflateSeconds = 0.3;
const double _inflateStep = 0.1;
const double _deflateWait = 0.5;
const double _deflateSeconds = 2;

/// Tyre lever: `BoxGeometry(0.6, 2.5, 0.6)` at y 1 in a group at (2, -3,
/// 4), `rotation.x = π/4` (label at (0, 3, 0)). Released within 4 of the
/// tyre it turns to π/2 (300 ms), then the tyre moves back to z -0.5
/// (300 ms) and the inner tube shows.
const _V _leverHome = _V(2, -3, 4);
const double _leverTiltHome = math.pi / 4;
const double _leverTiltPry = math.pi / 2;
const _V _leverSize = _V(0.6, 2.5, 0.6);
const double _leverRange = 4;
const double _prySeconds = 0.3;
const double _tyreBack = -0.5;

/// Inner tube `TorusGeometry(2.4, 0.15)` at the rear tyre + (0, 0.3, 0)
/// (not squashed with the flat tyre, so it shows above and below it). It
/// is out once more than 3 from the tyre, and in the water once dropped
/// within 4 of the bucket (500 ms).
const _V _tubeHome = _V(-4, 0, 0);
const double _tubeR = 2.4;
const double _tubeTube = 0.15;
const double _tubeOutRange = 3;
const double _bucketRange = 4;
const double _dunkTubeSeconds = 0.5;

/// Where a screen-reader tap puts the inner tube when it pulls it out
/// (added): in front of the bicycle.
const _V _tubeAside = _V(-3, 0, 4);

/// Bucket group at (7, -1.5, -2): open `CylinderGeometry(1.8, 1.4, 3)`
/// and water `CylinderGeometry(1.7, 1.45, 2.5)` at y -0.2. Its label is
/// meant for (7, 1.5, -2) like the pump's, where the pump's grip hides
/// it; it sits beside the bucket here.
const _V _bucketPos = _V(7, -1.5, -2);
const double _bucketTopR = 1.8;
const double _bucketBottomR = 1.4;
const double _bucketH = 3;
const double _bucketWaterTopR = 1.7;
const double _bucketWaterH = 2.5;
const double _bucketWaterY = -0.2;
const _V _bucketLabelAt = _V(2.9, 1.2, 0);

/// In the water the tube stands upright in the bucket with its lowest part
/// under the water (the HTML centres it in the bucket, wider than the
/// bucket). The leak is on that part, a little right of the bottom.
const _V _tubeInWater = _V(7, 1.6, -2);
const double _leakAngle = -80 * math.pi / 180;

/// HTML `createBubbleParticles`: 15 bubbles (r 0.1) around the leak,
/// life -0.01 per frame. They rise 0.006–0.015 per frame here (the HTML's
/// 0.02–0.07 carries them metres above the bucket).
const int _bubbleCount = 15;
const double _bubbleR = 0.1;
const double _bubbleSpeedMin = 0.006;
const double _bubbleSpeedRange = 0.009;

/// The red ring around the leak (HTML `RingGeometry(1.2, 1.5)`, drawn
/// smaller here so it rings the bubbles on the water).
const double _leakRingInner = 0.35;
const double _leakRingOuter = 0.48;

/// Camera close-ups: after the tube goes in (1000 ms, Cubic.Out; HTML eye
/// (7, 0, 8), target (7, -1.5, -2)) and on the leak (800 ms; HTML eye (7,
/// -0.5, 3)). The eyes sit higher here, so the water is seen from above,
/// and a little to the right, so the pump does not stand in front of the
/// bucket.
const _View _bucketView = _View(_V(8.6, 2.6, 8), _V(7.2, -0.4, -2), 1);
const _View _leakView = _View(_V(8.4, 1.7, 3.6), _V(7.4, -0.5, -2), 1);
const double _bucketViewSeconds = 1;
const double _leakViewSeconds = 0.8;

// ------------------------------------------------------------- confetti

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

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

  /// HTML `distanceTo`.
  double distanceTo(_V o) => (this - o).length;

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Linear interpolation of numbers (for [_Tween]).
double _lerpD(double a, double b, double t) => a + (b - a) * t;

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

  /// The same frame scaled by [k] about its origin (HTML `scale.set`).
  _Xf scaled(double k) => _Xf(o, x * k, y * k, z * k);
}

/// An unturned group at the world origin.
const _Xf _world = _Xf.at(_V.zero);

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// HTML `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => t * (2 - t);

/// HTML `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = 1 - t;
  return 1 - k * k * k;
}

/// HTML `TWEEN.Easing.Elastic.Out`.
double _elasticOut(double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return math.pow(2, -10 * t).toDouble() * math.sin((t - 0.1) * 5 * math.pi) +
      1;
}

/// One animated property of a Three.js object (HTML `new TWEEN.Tween(…)
/// .to(…, ms).easing(…).yoyo(…).repeat(…).delay(…)`): its value at any
/// scene time, worked out from the tween instead of stepped each frame.
class _Tween<T> {
  _Tween(T value, this._lerp) : _from = value, _to = value, _end = value;

  final T Function(T a, T b, double t) _lerp;
  T _from;
  T _to;
  T _end;
  double _start = 0;
  double _seconds = 0;
  int _legs = 1;
  bool _yoyo = false;
  double Function(double) _ease = _linear;

  /// Value at scene [time].
  T at(double time) {
    if (_seconds <= 0) return _end;
    final e = (time - _start) / _seconds;
    if (e <= 0) return _from;
    if (e >= _legs) return _end;
    final leg = e.floor();
    final t = _ease(e - leg);
    return _yoyo && leg.isOdd ? _lerp(_to, _from, t) : _lerp(_from, _to, t);
  }

  /// The value once the running tween is over.
  T get end => _end;

  /// Jumps to [value] (stops the tween).
  void set(T value) {
    _from = value;
    _to = value;
    _end = value;
    _seconds = 0;
  }

  /// Tweens from the value at [time] to [target] in [seconds] per leg;
  /// [repeat] more legs, coming back on every other one when [yoyo].
  void to(
    double time,
    T target,
    double seconds, {
    double Function(double) ease = _linear,
    int repeat = 0,
    bool yoyo = false,
    double delay = 0,
  }) {
    _from = at(time);
    _to = target;
    _start = time + delay;
    _seconds = seconds;
    _legs = repeat + 1;
    _yoyo = yoyo;
    _ease = ease;
    _end = yoyo && _legs.isEven ? _from : _to;
  }

  /// When the running tween ends (scene time).
  double get endsAt => _start + _seconds * _legs;
}

/// A camera pose: HTML `camera.position` and `controls.target`.
@immutable
class _View {
  const _View(this.eye, this.target, this.close);

  final _V eye;
  final _V target;

  /// 0: the HTML start view, fitted beside the cards; 1: a close-up,
  /// centred in the free part of the canvas.
  final double close;

  _View lerpTo(_View o, double t) => _View(
    _V.lerp(eye, o.eye, t),
    _V.lerp(target, o.target, t),
    close + (o.close - close) * t,
  );
}

/// Where the start view's look-at point lands on the stage, how much the
/// scene is enlarged (the HTML camera is [base]) and the centre of the
/// free part of the canvas (where close-ups look). The scene is fitted
/// into the part of the canvas no card covers.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom, this.mid);

  final Offset center;
  final double zoom;
  final Offset mid;

  static const _Framing base = _Framing(_designCenter, 1, _designCenter);

  _Framing lerpTo(_Framing o, double t) => _Framing(
    Offset.lerp(center, o.center, t)!,
    zoom + (o.zoom - zoom) * t,
    Offset.lerp(mid, o.mid, t)!,
  );

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 &&
      (mid - o.mid).distance < 0.5 &&
      (zoom - o.zoom).abs() < 0.002;
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
      Offset.lerp(framing.center, framing.mid, view.close)!,
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

  /// The design point of [w] (points behind the camera are pushed to the
  /// near plane; callers skip such meshes).
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

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the plane facing the camera through
  /// [point] (HTML `dragPlane.setFromNormalAndCoplanarPoint(
  /// camera.getWorldDirection(…), worldPos)`).
  _V? onFacingPlane(Offset s, _V point) {
    final d = ray(s);
    final dn = d.dot(f);
    if (dn.abs() < 1e-6) return null;
    final t = (point - eye).dot(f) / dn;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the corners [pts].
  Rect bounds(Iterable<_V> pts) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final w in pts) {
      final q = p(w);
      l = math.min(l, q.dx);
      t = math.min(t, q.dy);
      r = math.max(r, q.dx);
      b = math.max(b, q.dy);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  /// Screen bounds of the box [min]–[max] in the frame [xf].
  Rect boxRect(_Xf xf, _V min, _V max) => bounds(_corners(xf, min, max));

  /// True when the whole box [min]–[max] of [xf] is in front of the
  /// camera (meshes straddling the camera plane are not drawn).
  bool sees(_Xf xf, _V min, _V max) =>
      _corners(xf, min, max).every((w) => depth(w) >= _clipDepth);
}

/// The eight corners of the box [min]–[max] in the frame [xf].
List<_V> _corners(_Xf xf, _V min, _V max) => [
  for (var i = 0; i < 8; i++)
    xf(
      (i & 1) != 0 ? max.x : min.x,
      (i & 2) != 0 ? max.y : min.y,
      (i & 4) != 0 ? max.z : min.z,
    ),
];

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.distanceSquared;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

/// What a press on the scene can land on (the HTML raycast targets), with
/// the label its semantics node reads.
enum _Part {
  notebook('lbl_notebook'),
  pen('lbl_pen'),
  refill('lbl_refill'),
  cup('lbl_water'),
  tyre('lbl_tyre'),
  nozzle('lbl_nozzle'),
  handle('lbl_handle'),
  lever('lbl_lever'),
  tube('lbl_tube'),
  bucket('lbl_bucket'),
  bubbles('lbl_bubbles');

  const _Part(this.labelKey);

  final String labelKey;
}

/// The hypothesis cards of the HTML interactive UI layer (`buildCards
/// ForStep`).
enum _Card {
  inkFinished('card_ink_fin'),
  inkDried('card_ink_dry'),
  leak('card_leak');

  const _Card(this.labelKey);

  final String labelKey;
}

/// What the HTML interactive UI layer shows.
enum _Board {
  /// Hidden.
  none,

  /// The Test Area and the cards to drag into it.
  cards,

  /// The Test Area holding the tested hypothesis, marked with the HTML's
  /// red cross (it failed) or green tick (it was right).
  verdict,
}

/// Where the ink refill is.
enum _RefillAt {
  /// In the pen's tip (HTML `penTip.add(inkRefill)`).
  pen,

  /// Held by the finger or gliding back to the pen.
  loose,

  /// Standing in the cup of warm water.
  cup,
}

/// Where the inner tube is.
enum _TubeAt {
  /// Hidden in the tyre (before the lever).
  hidden,

  /// In the opened tyre.
  tyre,

  /// Held, or lying where it was dropped.
  loose,

  /// In the bucket of water.
  water,
}

/// One ink mote or bubble (HTML particle meshes with `userData.life`,
/// `speed` and `origin`), in its group's local units.
class _Mote {
  _Mote(this.pos, this.speed) : origin = pos;

  _V pos;
  _V origin;
  double speed;
  double life = 1;
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

/// Pump body height (`CylinderGeometry(0.3, 0.3, 5)` standing on y 0).
const double _pumpBodyH = 5;
const double _pumpBodyR = 0.3;

/// Mutable scene read by the painter every frame.
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

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based); the last step is 'Observe Conclusion'.
  int step = 1;

  /// 'Observe Conclusion' was tapped.
  bool reviewed = false;

  /// A sequence (HTML tweens and `setTimeout`s) is playing: presses wait.
  bool busy = false;

  /// The part the learner is dragging (HTML `State.dragTarget`).
  _Part? held;

  /// Pending events of the running sequence, in scene time (the HTML tween
  /// `onComplete` callbacks and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  /// Something came to rest this frame (camera, framing, a cue).
  bool _settled = false;

  final math.Random _rnd = math.Random(11);

  // ---------------------------------------------------------------- camera
  _View view = _homeView;
  _View _viewFrom = _homeView;
  _View _viewTo = _homeView;
  double _viewT = 1;
  double _viewSeconds = 1;
  double Function(double) _viewEase = _linear;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  /// The part of the stage the learner can see and reach (design
  /// coordinates): a dragged part is kept in it, so it is never left out
  /// of sight.
  Rect reach = _stageRect;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  // -------------------------------------------- HTML interactive UI layer
  _Board board = _Board.none;

  /// False while the layer fades out (HTML `opacity: 0`, then `hidden`).
  bool boardShown = false;

  /// Cards offered beside the Test Area; [dimmed] is shown but cannot be
  /// dragged yet (HTML `opacity-50 pointer-events-none`).
  List<_Card> offered = const [];
  _Card? dimmed;

  /// The card in the Test Area and, in a verdict, whether it was right.
  _Card? placed;
  bool verdictOk = false;

  // ----------------------------------------------------- the '?' sprite
  double questionAt = -1;
  double questionSeconds = 0;
  _V questionPos = _V.zero;

  // ------------------------------------------------------------ scenario 1
  final penPos = _Tween<_V>(_penHome, _V.lerp);
  final penTilt = _Tween<double>(_penTiltHome, _lerpD);
  final tipY = _Tween<double>(_tipRest, _lerpD);
  final tipSpin = _Tween<double>(0, _lerpD);
  final refillY = _Tween<double>(_refillRest, _lerpD);
  _RefillAt refillAt = _RefillAt.pen;

  /// The refill's centre and tilt while it is out of the pen (world).
  final refillPos = _Tween<_V>(_V.zero, _V.lerp);
  final refillTilt = _Tween<double>(0, _lerpD);

  /// Scene time the cup popped in, or -1 (HTML `waterCup.visible`).
  double cupAt = -1;

  /// HTML `scratchMark.visible` / `blueLine.visible`.
  bool scratched = false;
  bool written = false;

  /// HTML `inkParticles` (cup units).
  final List<_Mote> ink = [];

  // ------------------------------------------------------------ scenario 2
  /// Rear tyre `scale.y` (0.7 flat … 1 round) and `position.z`.
  final squash = _Tween<double>(_flat, _lerpD);
  final tyreZ = _Tween<double>(0, _lerpD);

  /// Scene time the pump, lever and bucket popped in, or -1.
  double toolsAt = -1;

  /// HTML `State.s2.pumpConnected`; the nozzle off the pump (held or
  /// gliding back) and where it is then (world).
  bool nozzleConnected = false;
  bool nozzleLoose = false;
  final nozzlePos = _Tween<_V>(_V.zero, _V.lerp);

  /// Pump handle `position.y`, strokes so far (HTML `pumpClicks`) and the
  /// tyre going flat again (HTML `tyreDeflating`).
  final handleY = _Tween<double>(_handleRest, _lerpD);
  int strokes = 0;
  bool deflating = false;

  /// Tyre lever group (world) and `rotation.x`; gone once it has pried
  /// the tyre open.
  final leverPos = _Tween<_V>(_leverHome, _V.lerp);
  final leverTilt = _Tween<double>(_leverTiltHome, _lerpD);
  bool leverGone = false;

  /// Inner tube: where it is and its centre (world).
  _TubeAt tubeAt = _TubeAt.hidden;
  final tubePos = _Tween<_V>(_tubeHome, _V.lerp);

  /// HTML `airBubbles` (world) and the red ring (`redTarget.visible`).
  final List<_Mote> bubbles = [];
  bool ringShown = false;

  /// Scene time of the final confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// HTML `resetScenarioState(sc)`: every object back in place, flags
  /// cleared, step 1, camera reset.
  void load(int index) {
    scenario = index;
    step = 1;
    reviewed = false;
    busy = false;
    held = null;
    _cues.clear();
    view = _viewFrom = _viewTo = _homeView;
    _viewT = 1;
    board = _Board.none;
    boardShown = false;
    offered = const [];
    dimmed = null;
    placed = null;
    verdictOk = false;
    questionAt = -1;
    penPos.set(_penHome);
    penTilt.set(_penTiltHome);
    tipY.set(_tipRest);
    tipSpin.set(0);
    refillY.set(_refillRest);
    refillAt = _RefillAt.pen;
    cupAt = -1;
    scratched = false;
    written = false;
    ink.clear();
    squash.set(_flat);
    tyreZ.set(0);
    toolsAt = -1;
    nozzleConnected = false;
    nozzleLoose = false;
    handleY.set(_handleRest);
    strokes = 0;
    deflating = false;
    leverPos.set(_leverHome);
    leverTilt.set(_leverTiltHome);
    leverGone = false;
    tubeAt = _TubeAt.hidden;
    tubePos.set(_tubeHome);
    bubbles.clear();
    ringShown = false;
    confettiAt = -1;
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
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    _cues.removeWhere((c) => c.$1 <= time);
    for (final c in due) {
      c.$2();
    }
    _settled = true;
  }

  /// HTML camera tweens (`camera.position` and `controls.target`).
  void moveCamera(_View to, double seconds, double Function(double) ease) {
    _viewFrom = view;
    _viewTo = to;
    _viewT = 0;
    _viewSeconds = seconds;
    _viewEase = ease;
  }

  /// HTML `animate()` + `TWEEN.update()`: camera, framing and the ink and
  /// bubble particles (stepped per 1/60 s frame like the HTML).
  void advance(double dt) {
    if (_viewT < 1) {
      _viewT = math.min(1, _viewT + dt / _viewSeconds);
      view = _viewFrom.lerpTo(_viewTo, _viewEase(_viewT));
      if (_viewT >= 1) _settled = true;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      if (_framingT >= 1) _settled = true;
    }
    final frames = dt * 60;
    for (final m in ink) {
      m
        ..pos = _V(
          m.pos.x + (_rnd.nextDouble() - 0.5) * 0.01 * frames,
          m.pos.y + m.speed * frames,
          m.pos.z,
        )
        ..life -= 0.01 * frames;
      if (m.life <= 0) {
        m
          ..pos = _inkStart()
          ..life = 1;
      }
    }
    for (final b in bubbles) {
      b
        ..pos = b.pos + _V(0, b.speed * frames, 0)
        ..life -= 0.01 * frames;
      if (b.life <= 0) {
        b
          ..pos = b.origin
          ..life = 1;
      }
    }
  }

  /// True once after something came to rest.
  bool takeSettled() {
    final s = _settled;
    _settled = false;
    return s;
  }

  /// Marks the scene as moved (semantics nodes re-read their places).
  void touch() => _settled = true;

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

  // ------------------------------------------------------------ particles

  /// An ink mote's start (HTML: cup (±0.25, -1, ±0.25)).
  _V _inkStart() =>
      _V((_rnd.nextDouble() - 0.5) * 0.5, -1, (_rnd.nextDouble() - 0.5) * 0.5);

  /// HTML `createDissolveParticles()`. The motes start at staggered ages
  /// so the ink rises as a steady stream.
  void startInk() {
    ink.clear();
    for (var i = 0; i < _inkMotes; i++) {
      ink.add(
        _Mote(_inkStart(), _rnd.nextDouble() * 0.02 + 0.01)
          ..life = 1 - i / _inkMotes,
      );
    }
  }

  /// HTML `createBubbleParticles()`: bubbles around the leak, staggered
  /// like the ink.
  void startBubbles() {
    bubbles.clear();
    final at = leak;
    for (var i = 0; i < _bubbleCount; i++) {
      final origin =
          at +
          _V(
            (_rnd.nextDouble() - 0.5) * 0.2,
            (_rnd.nextDouble() - 0.5) * 0.2,
            (_rnd.nextDouble() - 0.5) * 0.2,
          );
      bubbles.add(
        _Mote(origin, _bubbleSpeedMin + _rnd.nextDouble() * _bubbleSpeedRange)
          ..life = 1 - i / _bubbleCount,
      );
    }
  }

  // ------------------------------------------------------------- frames

  /// HTML `penGrp`, its `penTip` group and the refill.
  _Xf get penXf => _world.child(penPos.at(time), rz: penTilt.at(time));
  _Xf get tipXf => penXf.child(_V(0, tipY.at(time), 0), ry: tipSpin.at(time));
  _Xf get refillXf => refillAt == _RefillAt.pen
      ? tipXf.child(_V(0, refillY.at(time), 0))
      : _world.child(refillPos.at(time), rz: refillTilt.at(time));

  /// The refill's centre when it is in the pen (world).
  _V get refillInPen => tipXf.at(_V(0, refillY.at(time), 0));

  /// The refill can be seen and touched: the pen is unscrewed, or the
  /// refill is out of it.
  bool get refillExposed =>
      refillAt != _RefillAt.pen || tipY.end < _tipRest - 0.1;

  bool get cupShown => cupAt >= 0;

  /// Cup `scale` (0.1 → 1, Elastic.Out).
  double get cupScale => cupAt < 0
      ? 0
      : _popFrom +
            (1 - _popFrom) *
                _elasticOut(((time - cupAt) / _cupPopSeconds).clamp(0.0, 1.0));
  _Xf get cupXf => _world.child(_cupPos).scaled(cupScale);

  _Xf get bikeXf => _world.child(_bikePos);

  /// HTML `rearTyre` group: squashed by `scale.y`, moved back by the lever.
  _Xf get rearXf =>
      bikeXf.child(_V(-_wheelX, 0, tyreZ.at(time)), sy: squash.at(time));

  /// The valve's top (world).
  _V get valveTop => rearXf(0, _valveY + _valveH / 2, 0);

  bool get toolsShown => toolsAt >= 0;

  /// Pop-in scale of the pump (0), lever (1) and bucket (2).
  double toolScale(int i) {
    if (toolsAt < 0) return 0;
    final t = (time - toolsAt - i * _toolStagger) / _toolPopSeconds;
    if (t <= 0) return _popFrom;
    return _popFrom + (1 - _popFrom) * _elasticOut(t.clamp(0.0, 1.0));
  }

  _Xf get pumpXf => _world.child(_pumpPos).scaled(toolScale(0));
  _Xf get leverXf => _world
      .child(leverPos.at(time), rx: leverTilt.at(time))
      .scaled(toolScale(1));
  _Xf get bucketXf => _world.child(_bucketPos).scaled(toolScale(2));

  /// The nozzle's centre (world): on the pump, held, or lying on the valve.
  _V get nozzleAt {
    if (nozzleConnected) {
      return valveTop + const _V(_nozzleLength / 2, _nozzleR * 0.6, 0);
    }
    if (nozzleLoose) return nozzlePos.at(time);
    return pumpXf.at(_nozzleHome);
  }

  /// HTML `updateHose()`: from the pump's outlet to the nozzle, sagging by
  /// min(2, 0.3 x its span) in the middle (a curve through the three
  /// points).
  List<_V> hose() {
    final a = pumpXf.at(_hoseStart);
    final b = nozzleAt;
    final mid =
        _V.lerp(a, b, 0.5) - _V(0, math.min(2.0, a.distanceTo(b) * 0.3), 0);
    final c = mid * 2 - (a + b) * 0.5;
    return [
      for (var i = 0; i <= 20; i++)
        () {
          final t = i / 20;
          return a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);
        }(),
    ];
  }

  _Xf get tubeXf => _world.child(tubePos.at(time));

  /// The hole in the tube (world), once it stands in the water.
  _V get leak =>
      _tubeInWater +
      _V(_tubeR * math.cos(_leakAngle), _tubeR * math.sin(_leakAngle), 0);

  // ------------------------------------------------------------- the step

  /// The part the current step acts on (HTML `State.step` branches).
  _Part? get target => switch ((scenario, step)) {
    (0, 1) => _Part.notebook,
    (0, 3) || (0, 7) => _Part.pen,
    (0, 4) || (0, 6) => _Part.refill,
    (1, 1) => _Part.tyre,
    (1, 3) => _Part.nozzle,
    (1, 4) => _Part.handle,
    (1, 5) => _Part.lever,
    (1, 6) || (1, 7) => _Part.tube,
    (1, 8) => _Part.bubbles,
    _ => null,
  };

  /// The current step is moved by dragging (HTML `start3DDrag`).
  bool get dragStep => switch ((scenario, step)) {
    (0, 6) || (0, 7) || (1, 3) || (1, 5) || (1, 6) || (1, 7) => true,
    _ => false,
  };

  /// The current step is 'Observe Conclusion'.
  bool get atConclusion => step == _stepCounts[scenario];

  // ----------------------------------------------------------- hit tests

  /// The parts on show (HTML meshes that are visible).
  List<_Part> get parts => scenario == 0
      ? [
          _Part.notebook,
          _Part.pen,
          if (refillExposed) _Part.refill,
          if (cupShown) _Part.cup,
        ]
      : [
          if (toolsShown) _Part.bucket,
          _Part.tyre,
          if (tubeAt != _TubeAt.hidden) _Part.tube,
          if (toolsShown) ...[
            _Part.handle,
            _Part.nozzle,
            if (!leverGone) _Part.lever,
          ],
          if (bubbles.isNotEmpty) _Part.bubbles,
        ];

  /// A part's reference point (world), for its depth.
  _V centerOf(_Part part) => switch (part) {
    _Part.notebook => _notebookPos,
    _Part.pen => penXf(0, _penLength / 2, 0),
    _Part.refill => refillXf.o,
    _Part.cup => _cupPos,
    _Part.tyre => rearXf.o,
    _Part.nozzle => nozzleAt,
    _Part.handle => pumpXf(0, handleY.at(time) + 2, 0),
    _Part.lever => leverXf(0, 1, 0),
    _Part.tube => tubePos.at(time),
    _Part.bucket => _bucketPos,
    _Part.bubbles => leak,
  };

  /// The long, thin parts as capsules on screen (axis ends and radius).
  ({Offset a, Offset b, double r})? _capsule(_Part part, _Cam cam) {
    switch (part) {
      case _Part.pen:
        final xf = penXf;
        return (
          a: cam.p(xf(0, tipY.at(time) - _coneH, 0)),
          b: cam.p(xf(0, _penLength, 0)),
          r: _penR * 1.4 * cam.scaleAt(xf.o),
        );
      case _Part.refill:
        final xf = refillXf;
        return (
          a: cam.p(xf(0, -_refillLength / 2, 0)),
          b: cam.p(xf(0, _refillLength / 2, 0)),
          r: _refillR * 1.6 * cam.scaleAt(xf.o),
        );
      case _Part.nozzle:
        final c = nozzleAt;
        const half = _V(_nozzleLength / 2, 0, 0);
        return (
          a: cam.p(c - half),
          b: cam.p(c + half),
          r: _nozzleR * 1.4 * cam.scaleAt(c),
        );
      case _Part.lever:
        final xf = leverXf;
        return (
          a: cam.p(xf(0, 1 - _leverSize.y / 2, 0)),
          b: cam.p(xf(0, 1 + _leverSize.y / 2, 0)),
          r: _leverSize.x * 0.7 * cam.scaleAt(xf.o),
        );
      case _Part.notebook ||
          _Part.cup ||
          _Part.tyre ||
          _Part.handle ||
          _Part.tube ||
          _Part.bucket ||
          _Part.bubbles:
        return null;
    }
  }

  /// Screen bounds of [part] as drawn now (semantics nodes, hit tests).
  Rect partRect(_Part part, _Cam cam) {
    final cap = _capsule(part, cam);
    if (cap != null) return Rect.fromPoints(cap.a, cap.b).inflate(cap.r);
    switch (part) {
      case _Part.notebook:
        return cam.boxRect(
          _world.child(_notebookPos),
          _notebookSize * -0.5,
          _notebookSize * 0.5,
        );
      case _Part.cup:
        return cam.boxRect(
          cupXf,
          const _V(-_cupTopR, -_cupH / 2, -_cupTopR),
          const _V(_cupTopR, _cupH / 2, _cupTopR),
        );
      case _Part.tyre:
        const r = _wheelR + _wheelTube;
        return cam.boxRect(
          rearXf,
          const _V(-r, -r, -_wheelTube),
          const _V(r, r, _wheelTube),
        );
      case _Part.handle:
        final h = handleY.at(time);
        return cam.boxRect(
          pumpXf,
          _V(-0.75, math.min(_pumpBodyH, h + 1), -0.2),
          _V(0.75, h + 2.1, 0.2),
        );
      case _Part.tube:
        const r = _tubeR + _tubeTube;
        return cam.boxRect(
          tubeXf,
          const _V(-r, -r, -_tubeTube),
          const _V(r, r, _tubeTube),
        );
      case _Part.bucket:
        return cam.boxRect(
          bucketXf,
          const _V(-_bucketTopR, -_bucketH / 2, -_bucketTopR),
          const _V(_bucketTopR, _bucketH / 2, _bucketTopR),
        );
      case _Part.bubbles:
        final l = leak;
        return cam.bounds([
          l + const _V(-0.45, -0.2, 0),
          l + const _V(0.45, 1.4, 0),
        ]);
      case _Part.pen || _Part.refill || _Part.nozzle || _Part.lever:
        return Rect.zero;
    }
  }

  /// Does a press at [p] (half a finger: [touch] / 2) land on [part]?
  bool hits(_Part part, Offset p, double touch, _Cam cam) {
    final cap = _capsule(part, cam);
    if (cap != null) {
      return _segmentDistance(p, cap.a, cap.b) <= cap.r + touch / 2;
    }
    if (part == _Part.tube) {
      // The tube is a ring: its hole is not the tube.
      final xf = tubeXf;
      final width = (_tubeTube + 0.25) * cam.scaleAt(xf.o) + touch / 2;
      Offset ring(int i) {
        final a = i * math.pi / 16;
        return cam.p(xf(_tubeR * math.cos(a), _tubeR * math.sin(a), 0));
      }

      for (var i = 0; i < 32; i++) {
        if (_segmentDistance(p, ring(i), ring(i + 1)) <= width) return true;
      }
      return false;
    }
    return partRect(part, cam).inflate(touch / 2).contains(p);
  }

  /// The part under [p] (HTML raycast): the step's own part when the press
  /// is on it, otherwise the front-most part there.
  _Part? partAt(Offset p, double touch) {
    final cam = camera();
    final want = target;
    final shown = parts;
    if (want != null && shown.contains(want) && hits(want, p, touch, cam)) {
      return want;
    }
    _Part? best;
    var bestDepth = double.infinity;
    for (final part in shown) {
      if (!hits(part, p, touch, cam)) continue;
      final d = cam.depth(centerOf(part));
      if (d < bestDepth) {
        best = part;
        bestDepth = d;
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
  return _Framing(rect.center - extent(zoom).center, zoom, rect.center);
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a part of the scene ([canGrab]), so other drags still pan / zoom the
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

class _EssenceLabState extends State<Ch1A1TheEssenceOfSciencePage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped whenever the scene comes to rest: the parts' semantics nodes
  /// re-read where they are.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards; the Test Area and the canvas 'Observe
  /// Conclusion' button, which the scene keeps clear of.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch1-a1-canvas');
  final GlobalKey _boardKey = GlobalKey(debugLabel: 'ch1-a1-board');
  final GlobalKey _actionKey = GlobalKey(debugLabel: 'ch1-a1-action');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _missionRect;

  /// The part the current pointer holds, the scenario it was picked up in,
  /// the point of its drag plane and the grab offset on it, whether it
  /// moved and the last pointer position.
  _Part? _grab;
  int _grabScenario = -1;
  _V _grabPlane = _V.zero;
  _V _grabOffset = _V.zero;
  bool _moved = false;
  Offset _lastPointer = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// 1-based current step for the shell; steps + 1 once reviewed.
  int get _step =>
      _scene.reviewed ? _stepCounts[_scene.scenario] + 1 : _scene.step;

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

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// card covers: the tool column, the HUD (sidebar open), the floating
  /// mission card (sidebar collapsed), the Test Area and the canvas
  /// 'Observe Conclusion' button. Never while a part is held, so the scene
  /// does not move under the finger.
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
    Rect? measured(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return null;
      return (box.localToGlobal(Offset.zero) - origin) & box.size;
    }

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
    if (_scene.boardShown) {
      final board = measured(_boardKey);
      if (board != null) hard.add(board);
    }
    final action = measured(_actionKey);
    if (action != null) hard.add(action);
    _scene
      ..labelLeft = (4 - stage.dx) / fit
      ..labelRight = (size.width - insets.right - stage.dx) / fit
      ..reach = toDesign(free).deflate(_cardGap);
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

  /// What the learner must see in the start view: the scenario's objects
  /// wherever the steps take them (HTML camera, zoom 1), and the label
  /// chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_homeView, _Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V min, _V max) {
      for (final c in _corners(_world, min, max)) {
        items.add((cam.p(c), Rect.zero));
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

    if (_scene.scenario == 0) {
      // The notebook with its spiral, the pen at home and on the notebook
      // (with the refill pulled out) and the cup.
      box(const _V(-7.3, _deskY, -5), const _V(1, _paperTop + 0.2, 5));
      box(const _V(-2.6, _deskY, 1.4), const _V(4.4, 3.6, 4.6));
      box(const _V(1.8, _deskY, -0.2), const _V(4.2, 0.4, 2.2));
      chip(_notebookLabelAt, _t('lbl_notebook'));
      chip(
        _world.child(_penHome, rz: _penTiltHome)(0, _penLabelY, 0),
        _t('lbl_pen'),
      );
      chip(_cupPos + const _V(0, _cupLabelY, 0), _t('lbl_water'));
    } else {
      // The bicycle, the pump, the lever and the bucket.
      box(const _V(-6.8, _groundY, -1), const _V(6.8, 5.6, 1));
      box(const _V(3.9, _groundY, 2.4), const _V(6.1, 3.2, 3.6));
      box(const _V(1.4, _groundY, 3.2), const _V(2.6, -0.6, 5.6));
      box(const _V(5.1, _groundY, -3.9), const _V(8.9, 0, -0.1));
      chip(_tyreLabelAt, _t('lbl_tyre'));
      chip(_pumpPos + _pumpLabelAt, _t('lbl_pump'));
      chip(
        _world.child(_leverHome, rx: _leverTiltHome)(0, 3, 0),
        _t('lbl_lever'),
      );
      chip(_bucketPos + _bucketLabelAt, _t('lbl_bucket'));
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens and puts every object back.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _grabScenario = -1;
      _moved = false;
      _missionRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (!mounted) return;
    setState(() {});
    _scene.touch();
  }

  /// The current step's instruction (the HUD line without its prefix).
  String get _task {
    final sc = _scene.scenario;
    final step = _scene.step.clamp(1, _stepCounts[sc]);
    return _withoutStepPrefix(_t('s${sc + 1}_hud_$step'));
  }

  /// Says what to do now (added): a press on a part out of turn.
  void _hint() =>
      _lab.showToast(labFormat(_t('not_yet'), {'task': _task}), sound: false);

  /// HTML `progressStep()`: the next step. The interactive UI layer shows
  /// the cards at the hypothesis steps and fades out after them.
  void _nextStep() {
    final s = _scene;
    s
      ..step += 1
      ..busy = false;
    final cards = switch ((s.scenario, s.step)) {
      (0, 2) => const [_Card.inkFinished, _Card.inkDried],
      (0, 5) => const [_Card.inkDried],
      (1, 2) => const [_Card.leak],
      _ => null,
    };
    if (cards != null) {
      s
        ..board = _Board.cards
        ..boardShown = true
        ..offered = cards
        ..dimmed = s.scenario == 0 && s.step == 2 ? _Card.inkDried : null
        ..placed = null;
    } else if (s.board == _Board.cards) {
      _hideBoard();
    }
    _refresh();
  }

  /// Fades the interactive UI layer out (HTML `opacity 0`, then `hidden`
  /// 300 ms later).
  void _hideBoard() {
    final s = _scene;
    if (!s.boardShown) return;
    s.boardShown = false;
    s.cue(s.time + _boardFadeSeconds, () {
      if (!s.boardShown) s.board = _Board.none;
      _refresh();
    });
  }

  /// The Test Area with the tested card and its mark (the HTML adds a red
  /// cross or a green tick to the card).
  void _showVerdict(_Card card, {required bool ok}) {
    _scene
      ..board = _Board.verdict
      ..boardShown = true
      ..offered = const []
      ..dimmed = null
      ..placed = card
      ..verdictOk = ok;
  }

  // ------------------------------------------------------- scenario 1

  /// S1 step 1 (HTML: the notebook pressed): the pen moves onto the
  /// notebook and wiggles; it only scratches the paper, and a '?' shows
  /// for 1.5 s.
  void _tryWriting() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'scratch'
    s.penPos.to(t, _penTry, _penMoveSeconds, ease: _quadOut);
    s.penTilt.to(
      t,
      _wiggleTilt,
      _wiggleSeconds,
      repeat: 3,
      yoyo: true,
      delay: _penMoveSeconds,
    );
    s.cue(t + _penMoveSeconds + 4 * _wiggleSeconds, () {
      s
        ..scratched = true
        ..questionAt = s.time
        ..questionSeconds = _questionS1Seconds
        ..questionPos = _questionS1;
      s.cue(s.time + _questionS1Seconds, () {
        s.questionAt = -1;
        _nextStep();
      });
      _refresh();
    });
    _refresh();
  }

  /// S1 step 3 (HTML: the pen pressed): the tip unscrews (it drops and
  /// spins); 800 ms later the refill can be inspected.
  void _unscrew() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'snap'
    s.tipY.to(t, _tipOpen, _unscrewSeconds);
    s.tipSpin.to(t, _tipTurns, _unscrewSeconds);
    s.cue(t + _unscrewWait, _nextStep);
    _refresh();
  }

  /// S1 step 4 (HTML: the refill pressed): it slides out, full of ink, so
  /// the 'Ink is Finished' card gets its red cross; 1.5 s later the second
  /// hypothesis is offered.
  void _pullRefill() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'pop'
    s.refillY.to(t, _refillPulled, _pullSeconds, ease: _quadOut);
    _showVerdict(_Card.inkFinished, ok: false);
    s.cue(t + _verdictSeconds, _nextStep);
    _refresh();
  }

  /// S1 step 6 (HTML: the refill released within 3 of the cup): it goes
  /// into the warm water tip first and the dried ink dissolves; 2 s later
  /// it goes back into the pen and the tip screws on.
  void _dunkRefill() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'snap'
    if (s.refillAt == _RefillAt.pen) {
      // A screen-reader tap on the cup: the refill leaves the pen now.
      s.refillPos.set(s.refillXf.o);
      s.refillTilt.set(s.penTilt.at(t));
    }
    s.refillAt = _RefillAt.cup;
    s.refillPos.to(t, _refillInCup, _dunkSeconds);
    s.refillTilt.to(t, 0, _dunkSeconds);
    s.cue(t + _dunkSeconds, () {
      s.startInk();
      s.cue(s.time + _soakSeconds, () {
        final now = s.time;
        s
          ..refillAt = _RefillAt.loose
          ..refillY.set(_refillRest);
        s.refillPos.to(
          now,
          s.tipXf.at(const _V(0, _refillRest, 0)),
          _refillBackSeconds,
        );
        s.refillTilt.to(now, s.penTilt.at(now), _refillBackSeconds);
        s.cue(now + _refillBackSeconds, () {
          s.refillAt = _RefillAt.pen;
          s.tipY.to(s.time, _tipRest, _screwSeconds);
          s.tipSpin.to(s.time, 0, _screwSeconds);
          s.cue(s.time + _screwSeconds, _nextStep);
        });
      });
    });
    _refresh();
  }

  /// S1 step 7 (HTML: the pen released within 4 of the notebook): it
  /// moves onto the paper and writes a blue line; the 'Ink has Dried' card
  /// gets its green tick and 'Observe Conclusion' appears.
  void _writeAgain() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'scratch'
    s.penPos.to(t, _penWrite, _penMoveSeconds);
    s.penTilt.to(
      t,
      _wiggleTilt,
      _wiggleSeconds,
      repeat: 4,
      yoyo: true,
      delay: _penMoveSeconds,
    );
    s.cue(t + _penMoveSeconds + 5 * _wiggleSeconds, () {
      s.written = true;
      _showVerdict(_Card.inkDried, ok: true);
      _conclusionReady();
    });
    _refresh();
  }

  // ------------------------------------------------------- scenario 2

  /// S2 step 1 (HTML: the tyre pressed): it squishes and hisses; a '?'
  /// shows for 2 s.
  void _squishTyre() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.hiss.play();
    s.squash.to(t, _squished, _squishSeconds, repeat: 1, yoyo: true);
    s
      ..questionAt = t
      ..questionSeconds = _questionS2Seconds
      ..questionPos = _questionS2;
    s.cue(t + _questionS2Seconds, () {
      s.questionAt = -1;
      _nextStep();
    });
    _refresh();
  }

  /// S2 step 3 (HTML: the nozzle released within 6 of the valve): the pump
  /// is connected.
  void _connectPump() {
    _Sound.click.play(); // HTML 'snap'
    _scene
      ..nozzleConnected = true
      ..nozzleLoose = false;
    _nextStep();
  }

  /// S2 step 4 (HTML: the handle pressed): a stroke pumps the tyre 0.1
  /// rounder; once it is round it hisses flat again and the step ends.
  void _pumpStroke() {
    final s = _scene;
    final t = s.time;
    s.strokes += 1;
    _Sound.click.play(); // HTML 'snap'
    s.handleY.to(t, _handlePushed, _strokeSeconds, repeat: 1, yoyo: true);
    var round = _flat + s.strokes * _inflateStep;
    if (round >= 1 - 1e-9) {
      round = 1;
      s
        ..deflating = true
        ..busy = true;
    }
    s.squash.to(t, round, _inflateSeconds);
    if (s.deflating) {
      s.cue(t + _inflateSeconds + _deflateWait, () {
        _Sound.hiss.play();
        s.squash.to(s.time, _flat, _deflateSeconds);
        s.cue(s.time + _deflateSeconds, _nextStep);
      });
    }
    _refresh();
  }

  /// S2 step 5 (HTML: the lever released within 4 of the tyre): it turns
  /// to pry the tyre off; the tyre moves back, the inner tube shows and
  /// the lever is put away.
  void _pryTyre() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'snap'
    s.leverTilt.to(t, _leverTiltPry, _prySeconds);
    s.cue(t + _prySeconds, () {
      s
        ..tubeAt = _TubeAt.tyre
        ..leverGone = true;
      s.tyreZ.to(s.time, _tyreBack, _prySeconds);
      s.cue(s.time + _prySeconds, s.touch);
      _nextStep();
    });
    _refresh();
  }

  /// S2 step 6 (HTML: the tube released more than 3 from the tyre): it is
  /// out. A screen-reader tap moves it [to] a free spot.
  void _tubeOut({_V? to}) {
    final s = _scene;
    _Sound.click.play(); // HTML 'pop'
    s.tubeAt = _TubeAt.loose;
    if (to != null) {
      s.tubePos.to(s.time, to, _returnSeconds);
      s.cue(s.time + _returnSeconds, s.touch);
    }
    _nextStep();
  }

  /// S2 step 7 (HTML: the tube released within 4 of the bucket): it goes
  /// into the water, bubbles rise from one spot and the camera closes in.
  void _dunkTube() {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    _Sound.click.play(); // HTML 'snap'
    s.tubeAt = _TubeAt.water;
    s.tubePos.to(t, _tubeInWater, _dunkTubeSeconds);
    s.cue(t + _dunkTubeSeconds, () {
      s.startBubbles();
      s.moveCamera(_bucketView, _bucketViewSeconds, _cubicOut);
      _nextStep();
    });
    _refresh();
  }

  /// S2 step 8 (HTML: a press on the bubbles): the leak is ringed in red
  /// and the camera closes in on it; the leak card gets its green tick and
  /// 'Observe Conclusion' appears.
  void _findLeak() {
    final s = _scene;
    s.ringShown = true;
    s.moveCamera(_leakView, _leakViewSeconds, _cubicOut);
    _showVerdict(_Card.leak, ok: true);
    _conclusionReady();
  }

  // ---------------------------------------------------------- the end

  /// HTML `triggerConclusionState()`: 'Observe Conclusion' appears with a
  /// chime and the last step begins.
  void _conclusionReady() {
    _Sound.success.play();
    _nextStep();
  }

  /// HTML `triggerConclusion()`: Scenario 1 opens its summary, Scenario 2
  /// the 'Mastery Achieved!' card with confetti (with its summary above it,
  /// which the HTML never showed).
  void _review() {
    final s = _scene;
    if (!s.atConclusion || s.busy) return;
    final sc = s.scenario;
    setState(() {
      s.reviewed = true;
      if (sc == _scenarioCount - 1) s.confettiAt = s.time;
      _hideBoard();
    });
    _lab.completedScenarios.add(sc);
    _lab.showPopup(() => _summary(sc));
  }

  /// The summary popup of scenario [sc] (HTML `#summary-modal` /
  /// `#success-modal`).
  LabPopupContent _summary(int sc) {
    final last = sc == _scenarioCount - 1;
    return LabPopupContent(
      title: _lab.t('success'),
      heading: labFormat(_t('sc_complete'), {'n': sc + 1}),
      icon: Icons.check_circle,
      accent: _Colors.indigo500,
      extra: Builder(
        builder: (context) => _SummaryPanel(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale.clamp(0.9, 1.4),
          t: _t,
          // HTML `#next-sc-msg`, shown after Scenario 1 while Scenario 2 is
          // still to do.
          showNext: sc == 0 && !_lab.completedScenarios.contains(1),
        ),
      ),
      actions: [
        if (last)
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.emerald600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          )
        else
          LabAction(
            label: _t('close_btn'),
            icon: Icons.close,
            color: _Colors.slate700,
            foreground: _Colors.white,
            onTap: () => _lab.hidePopup(sound: false),
          ),
      ],
    );
  }

  /// HTML `#compare-btn-container` ('Observe Conclusion') at the last step.
  /// It stays in the sidebar after the summary so it can be opened again.
  List<LabAction> _actions() {
    final s = _scene;
    if (!s.atConclusion || s.busy) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        highlight: !s.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  // ------------------------------------------------------ hypothesis cards

  /// HTML `handleDragEnd` over the Test Area: the card is the new
  /// hypothesis (HTML `playSound('pop')`). The second one brings the cup of
  /// warm water, the tyre's one the pump, lever and bucket (popping in).
  void _dropCard(_Card card) {
    final s = _scene;
    if (s.board != _Board.cards ||
        !s.boardShown ||
        !s.offered.contains(card) ||
        card == s.dimmed ||
        s.busy) {
      return;
    }
    _Sound.click.play();
    s.placed = card;
    final t = s.time;
    switch (card) {
      case _Card.inkFinished:
        break;
      case _Card.inkDried:
        s.cupAt = t;
        s.cue(t + _cupPopSeconds, s.touch);
      case _Card.leak:
        s.toolsAt = t;
        s.cue(t + _toolPopSeconds + 2 * _toolStagger, s.touch);
    }
    _nextStep();
  }

  /// A card released outside the Test Area snaps back (HTML); a toast says
  /// where it goes (added).
  void _missCard() => _lab.showToast(_t('miss_card'), isError: true);

  // -------------------------------------------------------------- gestures

  /// The stage takes presses (lab open, no popup).
  bool get _stageLive => _lab.isLabActive && _lab.popup == null;

  /// HTML `pointerdown` on the renderer: a press on a part of the scene.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_stageLive || _grab != null || s.busy) return false;
    return s.partAt(event.localPosition, _touch) != null;
  }

  /// Runs a tap step on the part pressed, picks up the part of a drag
  /// step, or says what to do (the HTML's two toasts for the tyre, a hint
  /// otherwise).
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (!_stageLive || s.busy || _grab != null) return;
    final part = s.partAt(d.localPosition, _touch);
    if (part == null) return;
    if (part != s.target) {
      if (s.scenario == 1 && part == _Part.tyre && s.step == 5) {
        _lab.showToast(_t('drag_lever_hint'), sound: false);
      } else if (s.scenario == 1 && part == _Part.tyre && s.step == 6) {
        _lab.showToast(_t('drag_tube_hint'), sound: false);
      } else {
        _hint();
      }
      return;
    }
    if (!s.dragStep) {
      _tap();
      return;
    }
    _pickUp(part, d.localPosition);
  }

  /// The tap steps (HTML `pointerdown` branches).
  void _tap() {
    switch ((_scene.scenario, _scene.step)) {
      case (0, 1):
        _tryWriting();
      case (0, 3):
        _unscrew();
      case (0, 4):
        _pullRefill();
      case (1, 1):
        _squishTyre();
      case (1, 4):
        _pumpStroke();
      case (1, 8):
        _findLeak();
      default:
        _hint();
    }
  }

  /// HTML `start3DDrag(e, obj)`: the part follows the finger on the plane
  /// facing the camera through it.
  void _pickUp(_Part part, Offset pointer) {
    final s = _scene;
    final t = s.time;
    final _V at;
    switch (part) {
      case _Part.refill:
        at = s.refillXf.o;
        s
          ..refillAt = _RefillAt.loose
          ..refillPos.set(at)
          ..refillTilt.set(s.penTilt.at(t));
      case _Part.pen:
        at = s.penPos.at(t);
        s.penPos.set(at);
      case _Part.nozzle:
        at = s.nozzleAt;
        s
          ..nozzleLoose = true
          ..nozzlePos.set(at);
      case _Part.lever:
        at = s.leverPos.at(t);
        s.leverPos.set(at);
      case _Part.tube:
        at = s.tubePos.at(t);
        s
          ..tubeAt = _TubeAt.loose
          ..tubePos.set(at);
      case _Part.notebook ||
          _Part.cup ||
          _Part.tyre ||
          _Part.handle ||
          _Part.bucket ||
          _Part.bubbles:
        return;
    }
    final hit = s.camera().onFacingPlane(pointer, at);
    _grabPlane = at;
    _grabOffset = hit == null ? _V.zero : hit - at;
    _grab = part;
    _grabScenario = s.scenario;
    _moved = false;
    _lastPointer = pointer;
    s.held = part;
  }

  /// Lowest a held part may go (its centre), so it stays above the desk
  /// or the ground.
  static double _floorOf(_Part part) => switch (part) {
    _Part.refill => _deskY + _refillLength / 2,
    _Part.pen => _deskY + _coneH + 0.4,
    _Part.nozzle => _groundY + _nozzleR,
    _Part.lever => _groundY,
    _Part.tube => _groundY + _tubeR,
    _ => -double.infinity,
  };

  /// HTML `pointermove` while dragging.
  void _onDragUpdate(DragUpdateDetails d) {
    final part = _grab;
    final s = _scene;
    if (part == null || _grabScenario != s.scenario || s.held != part) return;
    _moved = true;
    // The finger is followed inside the visible canvas only.
    final reach = s.reach;
    final pointer = Offset(
      d.localPosition.dx.clamp(reach.left, math.max(reach.left, reach.right)),
      d.localPosition.dy.clamp(reach.top, math.max(reach.top, reach.bottom)),
    );
    _lastPointer = pointer;
    final hit = s.camera().onFacingPlane(pointer, _grabPlane);
    if (hit == null) return;
    final raw = hit - _grabOffset;
    final to = _V(
      raw.x.clamp(-14.0, 14.0),
      math.max(raw.y, _floorOf(part)),
      raw.z.clamp(-9.0, 9.0),
    );
    switch (part) {
      case _Part.refill:
        s.refillPos.set(to);
      case _Part.pen:
        s.penPos.set(to);
      case _Part.nozzle:
        s.nozzlePos.set(to);
      case _Part.lever:
        s.leverPos.set(to);
      case _Part.tube:
        s.tubePos.set(to);
      case _Part.notebook ||
          _Part.cup ||
          _Part.tyre ||
          _Part.handle ||
          _Part.bucket ||
          _Part.bubbles:
        break;
    }
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` → `end3DDrag()`: is the part where the step wants
  /// it? A press without a drag says what to do instead (added), except
  /// the pen, which the HTML lets a tap bring onto the nearby notebook.
  void _release() {
    final part = _grab;
    final scenario = _grabScenario;
    final moved = _moved;
    _grab = null;
    _grabScenario = -1;
    _moved = false;
    final s = _scene;
    if (part == null || scenario != s.scenario || s.held != part) return;
    s.held = null;
    final p = _lastPointer;
    if (!moved && part != _Part.pen) {
      _putBack(part, quiet: true);
      _lab.showToast(_task, sound: false);
      _refresh();
      return;
    }
    switch (part) {
      case _Part.refill:
        if (s.refillPos.at(s.time).distanceTo(_cupPos) < _cupRange ||
            s.partRect(_Part.cup, s.camera()).contains(p)) {
          _dunkRefill();
        } else {
          _putBack(part);
        }
      case _Part.pen:
        if (s.penPos.at(s.time).distanceTo(_notebookPos) < _notebookRange ||
            s.partRect(_Part.notebook, s.camera()).contains(p)) {
          _writeAgain();
        } else {
          _putBack(part);
        }
      case _Part.nozzle:
        if (s.nozzlePos.at(s.time).distanceTo(s.valveTop) < _nozzleRange ||
            s.partRect(_Part.tyre, s.camera()).contains(p)) {
          _connectPump();
        } else {
          _putBack(part);
        }
      case _Part.lever:
        if (s.leverPos.at(s.time).distanceTo(s.rearXf.o) < _leverRange ||
            s.partRect(_Part.tyre, s.camera()).contains(p)) {
          _pryTyre();
        } else {
          _putBack(part);
        }
      case _Part.tube:
        if (s.step == 6) {
          if (s.tubePos.at(s.time).distanceTo(s.rearXf.o) > _tubeOutRange) {
            _tubeOut();
          } else {
            _putBack(part);
          }
        } else if (s.tubePos.at(s.time).distanceTo(_bucketPos) < _bucketRange ||
            s.partRect(_Part.bucket, s.camera()).contains(p)) {
          _dunkTube();
        } else {
          // HTML: the tube stays where it was dropped.
          _lab.showToast(_t('miss_bucket'), isError: true);
        }
      case _Part.notebook ||
          _Part.cup ||
          _Part.tyre ||
          _Part.handle ||
          _Part.bucket ||
          _Part.bubbles:
        break;
    }
    _refresh();
  }

  /// A missed drop: the part glides back to where it was picked up (the
  /// HTML leaves the refill, pen and nozzle where they were dropped and
  /// snaps the lever and the tube back at once) with a toast (added).
  void _putBack(_Part part, {bool quiet = false}) {
    final s = _scene;
    final t = s.time;
    s.busy = true;
    final String miss;
    switch (part) {
      case _Part.refill:
        miss = 'miss_refill';
        s.refillPos.to(t, s.refillInPen, _returnSeconds);
        s.refillTilt.to(t, s.penTilt.at(t), _returnSeconds);
        s.cue(t + _returnSeconds, () => s.refillAt = _RefillAt.pen);
      case _Part.pen:
        miss = 'miss_pen';
        s.penPos.to(t, _penTry, _returnSeconds);
      case _Part.nozzle:
        miss = 'miss_nozzle';
        s.nozzlePos.to(t, s.pumpXf.at(_nozzleHome), _returnSeconds);
        s.cue(t + _returnSeconds, () => s.nozzleLoose = false);
      case _Part.lever:
        miss = 'miss_lever';
        s.leverPos.to(t, _leverHome, _returnSeconds);
      case _Part.tube:
        miss = s.step == 6 ? 'miss_tube_out' : 'miss_bucket';
        if (s.step == 6) {
          s.tubePos.to(t, _tubeHome, _returnSeconds);
          s.cue(t + _returnSeconds, () => s.tubeAt = _TubeAt.tyre);
        } else {
          s.tubeAt = _TubeAt.loose;
        }
      case _Part.notebook ||
          _Part.cup ||
          _Part.tyre ||
          _Part.handle ||
          _Part.bucket ||
          _Part.bubbles:
        miss = '';
    }
    s.cue(t + _returnSeconds, () {
      s.busy = false;
      _refresh();
    });
    if (!quiet && miss.isNotEmpty) {
      _lab.showToast(_t(miss), isError: true);
    }
  }

  /// A screen-reader tap on a part (added): runs the step it belongs to
  /// (a drag step is done by tapping where the part goes), otherwise says
  /// what to do.
  void _activate(_Part part) {
    final s = _scene;
    if (!_stageLive || s.busy || s.held != null) return;
    switch ((s.scenario, s.step, part)) {
      case (0, 1, _Part.notebook):
        _tryWriting();
      case (0, 3, _Part.pen):
        _unscrew();
      case (0, 4, _Part.refill):
        _pullRefill();
      case (0, 6, _Part.cup):
        _dunkRefill();
      case (0, 7, _Part.pen || _Part.notebook):
        _writeAgain();
      case (1, 1, _Part.tyre):
        _squishTyre();
      case (1, 3, _Part.tyre):
        _connectPump();
      case (1, 4, _Part.handle):
        _pumpStroke();
      case (1, 5, _Part.tyre):
        _pryTyre();
      case (1, 6, _Part.tube):
        _tubeOut(to: _tubeAside);
      case (1, 7, _Part.bucket):
        _dunkTube();
      case (1, 8, _Part.bubbles):
        _findLeak();
      default:
        _hint();
    }
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
        final scene = _scene;
        final sc = scene.scenario;
        final step = _step;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final open = _lab.isSidebarOpen;
        final live = _stageLive;
        final above = inset.bottom + (open ? _hudReserve * s : 0);
        final compact = MediaQuery.sizeOf(context).height < _compactBelow;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.search,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _t('s${sc + 1}_hud_${scene.step.clamp(1, _stepCounts[sc])}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$step'),
            steps: _stepData,
            current: step,
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
            // HTML `#interactive-ui-layer`: the Test Area and the cards, at
            // the top of the canvas (fixed, like the HTML layer).
            if (scene.board != _Board.none && _lab.isLabActive)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      inset.left,
                      inset.top + 4 * s,
                      inset.right,
                      0,
                    ),
                    child: IgnorePointer(
                      ignoring: !scene.boardShown || !live,
                      child: AnimatedOpacity(
                        opacity: scene.boardShown ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: _HypothesisBoard(
                          key: _boardKey,
                          offered: scene.offered,
                          dimmed: scene.dimmed,
                          placed: scene.placed,
                          verdict: scene.board == _Board.verdict
                              ? scene.verdictOk
                              : null,
                          labelOf: (c) => _t(c.labelKey),
                          title: _t('test_area'),
                          hint: _t('drag_card_here'),
                          compact: compact,
                          scale: s,
                          isDark: _lab.isDark,
                          onDrop: _dropCard,
                          onMiss: _missCard,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // HTML `#compare-btn-container`, above the HUD. While the
            // sidebar is collapsed the mission card carries it.
            if (actions.isNotEmpty && live && open && !scene.reviewed)
              Positioned(
                key: const ValueKey('ch1a1-conclude'),
                left: inset.left,
                right: inset.right,
                bottom: above,
                child: Center(
                  child: FittedBox(
                    key: _actionKey,
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(
                      action: actions.first,
                      scale: s,
                      expand: false,
                    ),
                  ),
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
                // scene and its parts are announced instead.
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
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        labelSize: _labelSize,
                      ),
                    ),
                  ),
                ),
              ),
              // One semantics node per part where it is drawn (added), so a
              // screen reader can find and tap them. They take no touches:
              // those reach the scene below.
              ValueListenableBuilder<int>(
                valueListenable: _layout,
                builder: (context, _, _) {
                  final cam = _scene.camera();
                  const room = Rect.fromLTRB(-500, -500, 1500, 1060);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      for (final part in _scene.parts)
                        if (cam.depth(_scene.centerOf(part)) >= _clipDepth)
                          if (_scene.partRect(part, cam).intersect(room)
                              case final rect
                              when rect.width > 0 && rect.height > 0)
                            Positioned.fromRect(
                              rect: rect,
                              child: Semantics(
                                container: true,
                                button: true,
                                label: _t(part.labelKey),
                                onTap: () => _activate(part),
                                child: const SizedBox.expand(),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// =================================================================== WIDGETS

/// HTML `#interactive-ui-layer`: the Test Area (`#test-area` with its
/// dashed `#drop-target`) and the hypothesis cards below it (beside it on
/// short screens). A card dragged so that it overlaps the Test Area is
/// dropped there (the HTML's rectangle-overlap test); anywhere else it
/// snaps back. While a card is held the Test Area lights up (HTML
/// `.dropzone.highlight`). In a verdict the tested card sits in the Test
/// Area under a bouncing red cross or green tick.
class _HypothesisBoard extends StatefulWidget {
  const _HypothesisBoard({
    super.key,
    required this.offered,
    required this.dimmed,
    required this.placed,
    required this.verdict,
    required this.labelOf,
    required this.title,
    required this.hint,
    required this.compact,
    required this.scale,
    required this.isDark,
    required this.onDrop,
    required this.onMiss,
  });

  /// Cards beside the Test Area; [dimmed] cannot be dragged yet.
  final List<_Card> offered;
  final _Card? dimmed;

  /// The card in the Test Area.
  final _Card? placed;

  /// `null` while cards are dragged; then the tested card's tick (true)
  /// or cross (false).
  final bool? verdict;
  final String Function(_Card card) labelOf;
  final String title;
  final String hint;

  /// Short screens: the cards beside the Test Area, which is smaller.
  final bool compact;
  final double scale;
  final bool isDark;
  final ValueChanged<_Card> onDrop;
  final VoidCallback onMiss;

  @override
  State<_HypothesisBoard> createState() => _HypothesisBoardState();
}

class _HypothesisBoardState extends State<_HypothesisBoard>
    with SingleTickerProviderStateMixin {
  /// HTML `pulse-ring` (1.5 s) and `animate-bounce` timing.
  late final AnimationController _pulse;

  final GlobalKey _zoneKey = GlobalKey(debugLabel: 'ch1-a1-test-area');
  final Map<_Card, GlobalKey> _cardKeys = {
    for (final c in _Card.values) c: GlobalKey(debugLabel: 'ch1-a1-${c.name}'),
  };

  /// The card being dragged and how far it moved (HTML `draggedCard`).
  _Card? _dragging;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  double get _k => widget.scale.clamp(0.75, 1.15);

  /// HTML `handleDragEnd`: does the card's box overlap the Test Area's?
  bool _overlapsZone(_Card card) {
    final cardBox = _cardKeys[card]?.currentContext?.findRenderObject();
    final zoneBox = _zoneKey.currentContext?.findRenderObject();
    if (cardBox is! RenderBox ||
        zoneBox is! RenderBox ||
        !cardBox.hasSize ||
        !zoneBox.hasSize) {
      return false;
    }
    final a = cardBox.localToGlobal(Offset.zero) & cardBox.size;
    final b = zoneBox.localToGlobal(Offset.zero) & zoneBox.size;
    return a.overlaps(b);
  }

  void _start(_Card card) => setState(() {
    _dragging = card;
    _offset = Offset.zero;
  });

  void _update(DragUpdateDetails d) => setState(() => _offset += d.delta);

  void _end(_Card card) {
    final over = _overlapsZone(card);
    setState(() {
      _dragging = null;
      _offset = Offset.zero;
    });
    if (over) {
      widget.onDrop(card);
    } else {
      widget.onMiss();
    }
  }

  void _cancel() => setState(() {
    _dragging = null;
    _offset = Offset.zero;
  });

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final k = _k;
    final zone = _zone(k);
    final tray = [
      for (final c in w.offered)
        if (c != w.placed) _draggable(c, k),
    ];
    if (w.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          zone,
          if (tray.isNotEmpty) ...[
            SizedBox(width: 12 * k),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < tray.length; i++) ...[
                  if (i > 0) SizedBox(height: 8 * k),
                  tray[i],
                ],
              ],
            ),
          ],
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        zone,
        if (tray.isNotEmpty) ...[
          SizedBox(height: 16 * k),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 512 * k),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14 * k,
              runSpacing: 10 * k,
              children: tray,
            ),
          ),
        ],
      ],
    );
  }

  /// HTML `#test-area` (320 x 180 px): "Test Area" over the dashed drop
  /// target with its hint or the dropped card.
  Widget _zone(double k) {
    final w = widget;
    final active = _dragging != null;
    final placed = w.placed;
    return Semantics(
      container: true,
      label: w.title,
      child: CustomPaint(
        key: _zoneKey,
        painter: _DashedBoxPainter(
          fill: active
              ? Color.alphaBlend(
                  _Colors.indigo500.withValues(alpha: 0.3),
                  _Colors.testArea,
                )
              : _Colors.testArea,
          border: active ? _Colors.indigo500 : _Colors.testBorder,
          strokeWidth: 3,
          radius: 12 * k,
          dashed: !active,
          shadow: true,
        ),
        child: SizedBox(
          width: (w.compact ? 230 : 300) * k,
          height: (w.compact ? 112 : 150) * k,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10 * k, 7 * k, 10 * k, 10 * k),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4 * k),
                  child: Text(
                    w.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _Colors.white,
                      fontSize: 13 * k,
                      fontWeight: FontWeight.w700,
                      letterSpacing: labLetterSpacing(w.title, 0.4),
                    ),
                  ),
                ),
                SizedBox(height: 4 * k),
                Expanded(
                  child: CustomPaint(
                    painter: _DashedBoxPainter(
                      fill: _Colors.dropBg,
                      border: _Colors.dropBorder,
                      strokeWidth: 2,
                      radius: 8 * k,
                      dashed: true,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8 * k),
                        child: placed == null
                            ? Text(
                                w.hint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _Colors.dropHint,
                                  fontSize: 14 * k,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _face(placed, k, mark: w.verdict),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A hypothesis card (HTML `.draggable-card`): white (dark: slate-800)
  /// with bold text; [pulse] adds the HTML `pulse-ring`, [mark] the tick
  /// (true) or cross (false) overlay.
  Widget _face(_Card card, double k, {bool? mark, bool pulse = false}) {
    final dark = widget.isDark;
    final face = Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * k, vertical: 13 * k),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate800 : _Colors.white,
        borderRadius: BorderRadius.circular(12 * k),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowSoft,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        widget.labelOf(card),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: dark ? _Colors.white : _Colors.slate800,
          fontSize: 14.5 * k,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    if (mark != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12 * k),
              ),
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Transform.translate(
                  // HTML `animate-bounce`: up a quarter and back each second.
                  offset: Offset(
                    0,
                    -10 *
                        k *
                        math.sin(math.pi * (_pulse.value * 1.5 % 1)).abs(),
                  ),
                  child: child,
                ),
                child: Icon(
                  mark ? Icons.check_rounded : Icons.close_rounded,
                  size: 44 * k,
                  color: mark ? _Colors.emerald500 : _Colors.red500,
                  shadows: const [
                    Shadow(color: LabInk.shadowSoft, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (!pulse) return face;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => CustomPaint(
        foregroundPainter: _PulseRingPainter(
          t: _pulse.value,
          radius: 12 * k,
          color: _Colors.indigo500,
        ),
        child: child,
      ),
      child: face,
    );
  }

  /// A card in the tray: dragged with the finger (the HTML's mouse and
  /// touch handlers), or dropped with one screen-reader tap.
  Widget _draggable(_Card card, double k) {
    final w = widget;
    final enabled = card != w.dimmed && w.verdict == null;
    final dragging = _dragging == card;
    final face = _face(card, k, pulse: enabled && w.offered.length == 1);
    return Semantics(
      button: true,
      enabled: enabled,
      label: w.labelOf(card),
      onTap: enabled ? () => w.onDrop(card) : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onPanStart: enabled ? (_) => _start(card) : null,
          onPanUpdate: enabled ? _update : null,
          onPanEnd: enabled ? (_) => _end(card) : null,
          onPanCancel: enabled ? _cancel : null,
          child: MouseRegion(
            cursor: !enabled
                ? SystemMouseCursors.basic
                : (dragging
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.grab),
            child: Transform.translate(
              offset: dragging ? _offset : Offset.zero,
              child: AnimatedScale(
                // HTML `.draggable-card:active { transform: scale(1.05) }`.
                scale: dragging ? 1.05 : 1,
                duration: const Duration(milliseconds: 100),
                child: KeyedSubtree(key: _cardKeys[card], child: face),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded box with a solid or dashed border (the HTML `#test-area` and
/// `#drop-target` with `border-dashed`).
class _DashedBoxPainter extends CustomPainter {
  const _DashedBoxPainter({
    required this.fill,
    required this.border,
    required this.strokeWidth,
    required this.radius,
    required this.dashed,
    this.shadow = false,
  });

  final Color fill;
  final Color border;
  final double strokeWidth;
  final double radius;
  final bool dashed;

  /// HTML `shadow-[0_0_25px_rgba(0,0,0,0.4)]`.
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    if (shadow) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
    canvas.drawRRect(rr, Paint()..color = fill);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = border;
    final edge = rr.deflate(strokeWidth / 2);
    if (dashed) {
      labDashedPath(canvas, Path()..addRRect(edge), pen, dash: 7, gap: 5);
    } else {
      canvas.drawRRect(edge, pen);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBoxPainter old) =>
      old.fill != fill ||
      old.border != border ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dashed != dashed ||
      old.shadow != shadow;
}

/// HTML `.pulse-ring::before`: a ring 4 px around the card that grows from
/// 0.8 to 1.3 times its size while fading from 0.5 to 0 (1.5 s).
class _PulseRingPainter extends CustomPainter {
  const _PulseRingPainter({
    required this.t,
    required this.radius,
    required this.color,
  });

  final double t;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final e = Curves.easeOutCubic.transform(t);
    final scale = 0.8 + 0.5 * e;
    final rect = (Offset.zero & size).inflate(4);
    final scaled = Rect.fromCenter(
      center: rect.center,
      width: rect.width * scale,
      height: rect.height * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scaled, Radius.circular(radius + 4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.5 * (1 - e)),
    );
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter old) =>
      old.t != t || old.radius != radius || old.color != color;
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task (concept), action and result. The current step is open, done
/// steps show a tick and can be re-opened, future steps are dimmed. A
/// step's result is shown once the step is done (the HTML showed it
/// before the learner had seen it).
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
                  _heading('${w.focusLabel}:', accent),
                  SizedBox(height: 3 * s),
                  _body(step.focus, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading('${w.actionLabel}:', p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.done, p.text),
                  SizedBox(height: 8 * s),
                  _heading('${w.resultLabel}:', p.textStrong),
                  SizedBox(height: 3 * s),
                  if (past)
                    _body(step.result, p.text)
                  else
                    _body(w.pendingText, p.textMuted, italic: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#summary-modal` body: the lightbulb, the summary with its bold
/// words (its `<strong>` headline on a line of its own) and, after
/// Scenario 1, `#next-sc-msg`. After Scenario 2 the HTML `#success-modal`
/// body follows: the trophy, 'Mastery Achieved!' and its text.
class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.t,
    required this.showNext,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;

  /// The sidebar font-size setting (clamped for the popup).
  final double fontScale;
  final String Function(String key) t;
  final bool showNext;

  /// A round icon badge (HTML `w-16 h-16 rounded-full bg-…/20`).
  Widget _badge(IconData icon, Color ink, Color tint) {
    final s = scale;
    return Container(
      width: 60 * s,
      height: 60 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint.withValues(alpha: 0.2),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 30 * s, color: palette.ink(ink)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale;
    final runs = _boldRuns(t('s${scenario + 1}_summary'));
    final headline = runs.isNotEmpty && runs.first.$2 ? runs.first.$1 : null;
    final body = headline == null ? runs : runs.sublist(1);
    final lead = scenario == 0 ? _Colors.emerald400 : _Colors.indigo400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _badge(Icons.lightbulb, _Colors.indigo400, _Colors.indigo500),
        ),
        SizedBox(height: 12 * s),
        if (headline != null) ...[
          Text(
            headline.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(lead),
              fontSize: 18 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
        ],
        Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < body.length; i++)
                TextSpan(
                  text: i == 0 ? body[i].$1.trimLeft() : body[i].$1,
                  style: body[i].$2
                      ? TextStyle(
                          color: p.textStrong,
                          fontWeight: FontWeight.w800,
                        )
                      : null,
                ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13 * f,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
        if (showNext) ...[
          SizedBox(height: 14 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: _Colors.emerald500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.emerald500.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.emerald400),
                fontSize: 12.5 * f,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (scenario == _scenarioCount - 1) ...[
          SizedBox(height: 16 * s),
          Divider(height: 1, color: p.cardBorder),
          SizedBox(height: 16 * s),
          Center(
            child: _badge(
              Icons.emoji_events,
              _Colors.yellow400,
              _Colors.yellow500,
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            t('all_complete'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 21 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            t('all_complete_desc'),
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

  /// Opacity of a translucent mesh (glass, water, the refill tube).
  final Paint layer = Paint();
  final Path path = Path();
}

/// What the painter makes once and reuses: pens and the text painters of
/// the label chips and the '?' sprite. Owned by the page state and
/// disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<int, TextPainter> _marks = {};
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

  /// The '?' of the icon sprite (`bold 80px Arial` on a 128 px canvas), at
  /// [size] design px (rounded to whole pixels).
  TextPainter mark(double size) {
    final px = math.max(4, size.round());
    return _marks[px] ??= TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: _Colors.questionMark,
          fontSize: px.toDouble(),
          fontWeight: FontWeight.w900,
          height: 1,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    for (final tp in _marks.values) {
      tp.dispose();
    }
    _marks.clear();
  }
}

/// HTML lights: `AmbientLight(0xffffff, 0.7)` and `DirectionalLight(
/// 0xffffff, 0.8)` at (5, 10, 5), normalised.
const _V _keyLight = _V(0.4082, 0.8165, 0.4082);
const double _ambient = 0.7;
const double _keyPower = 0.8;

/// A surface turned to the start camera and the side of an upright mesh
/// turned to the camera and the key light.
const _V _viewNormal = _V(0, 0.41, 0.91);
const _V _sideNormal = _V(0.3, 0.2, 0.93);

/// MeshStandardMaterial look: ambient light plus the directional light's
/// Lambert term on a surface with normal [n]. [metal] (HTML `metalness`)
/// darkens the diffuse colour, as Three.js does without an environment
/// map.
Color _lit(Color c, _V n, [double metal = 0]) {
  final k =
      (_ambient + _keyPower * math.max(0.0, n.dot(_keyLight))) *
      (1 - 0.45 * metal);
  double channel(double v) => math.min(1.0, v * k);
  return Color.from(
    alpha: c.a,
    red: channel(c.r),
    green: channel(c.g),
    blue: channel(c.b),
  );
}

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

/// `createScratchTexture('scratch')`: ten random lines on the 256 x 64 px
/// patch (u, v from 0 to 1), drawn once from a seeded generator so the
/// scratch looks the same every time.
final List<(double, double, double, double)> _scratchLines = () {
  final rng = math.Random(5);
  return [
    for (var i = 0; i < 10; i++)
      (rng.nextDouble(), rng.nextDouble(), rng.nextDouble(), rng.nextDouble()),
  ];
}();

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer.
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

  /// A new closed polygon path (kept, e.g. as a clip).
  Path freshPolygon(List<Offset> pts) => Path()..addPolygon(pts, true);

  /// The ellipse of a horizontal circle of [radius] at [c] in [xf]'s
  /// x / z plane.
  List<Offset> circle(_Xf xf, _V c, double radius, {int segments = 48}) => [
    for (var i = 0; i < segments; i++)
      cam.p(
        xf.at(
          c +
              _V(
                radius * math.cos(2 * math.pi * i / segments),
                0,
                radius * math.sin(2 * math.pi * i / segments),
              ),
        ),
      ),
  ];

  // ---------------------------------------------------------- primitives

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf], its axis
  /// along the frame's y: its outline (hull of both rims), shading bands
  /// along its side and the end cap turned to the camera ([cap] false for
  /// the HTML's open-ended cup and bucket).
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 16,
    double opacity = 1,
    double metal = 0,
    bool cap = true,
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
    final body = _lit(color, _sideNormal, metal);
    final translucent = opacity < 1;
    if (translucent) {
      canvas.saveLayer(
        null,
        pens.layer..color = _Colors.black.withValues(alpha: opacity),
      );
    }
    canvas.drawPath(
      polygon(_hull([...top, ...bottom])),
      pens.fill..color = body,
    );
    if (!translucent) {
      final k = xf.x.length;
      _bands(
        cam.p(a),
        cam.p(b),
        rBottom * k * cam.scaleAt(a),
        rTop * k * cam.scaleAt(b),
        body,
      );
    }
    final axis = xf.y.unit;
    final showTop = (cam.eye - b).dot(axis) > 0;
    if (cap && (showTop ? rTop : rBottom) > 0.0005) {
      canvas.drawPath(
        polygon(showTop ? top : bottom),
        pens.fill..color = _lit(color, showTop ? axis : -axis, metal),
      );
    }
    if (translucent) canvas.restore();
  }

  /// Shading bands along a mesh's side from [pa] to [pb] (half widths [wa],
  /// [wb]): shadow away from the key light, highlight towards it.
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

  /// ConeGeometry([r], [h]) centred on [xf], apex along the frame's y.
  void cone(_Xf xf, double r, double h, Color color, {double metal = 0}) {
    final hh = h / 2;
    final pts = <Offset>[cam.p(xf(0, hh, 0))];
    for (var i = 0; i < 16; i++) {
      final t = 2 * math.pi * i / 16;
      pts.add(cam.p(xf(r * math.cos(t), -hh, r * math.sin(t))));
    }
    final axis = xf.y.unit;
    final toCam = (cam.eye - xf.o).unit;
    final side = toCam - axis * toCam.dot(axis);
    final n = side.length < 1e-6 ? toCam : side.unit;
    final lit = _lit(color, n, metal);
    final path = polygon(_hull(pts));
    canvas.drawPath(path, pens.fill..color = lit);
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 0.6
        ..color = labShade(lit, -0.35).withValues(alpha: 0.6),
    );
  }

  /// BoxGeometry of [size] centred on [xf]: the faces turned to the
  /// camera, each lit by its own normal; [edge] outlines them.
  void box(
    _Xf xf,
    _V size,
    Color color, {
    double metal = 0,
    Color? edge,
    double opacity = 1,
  }) {
    final h = size * 0.5;
    const axes = [_V(1, 0, 0), _V(0, 1, 0), _V(0, 0, 1)];
    for (var a = 0; a < 3; a++) {
      final u = axes[(a + 1) % 3];
      final v = axes[(a + 2) % 3];
      for (final sign in const [-1.0, 1.0]) {
        final n = axes[a] * sign;
        final face = _V(n.x * h.x, n.y * h.y, n.z * h.z);
        final world = xf.dir(n);
        if (world.length < 1e-9) continue;
        final normal = world.unit;
        if ((cam.eye - xf.at(face)).dot(normal) <= 0) continue;
        Offset corner(double su, double sv) => cam.p(
          xf.at(
            face +
                _V(u.x * h.x, u.y * h.y, u.z * h.z) * su +
                _V(v.x * h.x, v.y * h.y, v.z * h.z) * sv,
          ),
        );
        final path = polygon([
          corner(-1, -1),
          corner(1, -1),
          corner(1, 1),
          corner(-1, 1),
        ]);
        final lit = _lit(color, normal, metal);
        canvas.drawPath(
          path,
          pens.fill..color = lit.withValues(alpha: lit.a * opacity),
        );
        if (edge != null) {
          canvas.drawPath(
            path,
            pens.stroke
              ..strokeWidth = 0.8
              ..color = edge.withValues(alpha: edge.a * opacity),
          );
        }
      }
    }
  }

  /// TorusGeometry([radius], [tube]) in the plane of [xf]'s x and y axes,
  /// stroked along its centre line: a dark rim, the lit tube and a thin
  /// highlight.
  void ring(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double metal = 0,
    int segments = 48,
  }) {
    final path = pens.path..reset();
    for (var i = 0; i <= segments; i++) {
      final a = 2 * math.pi * i / segments;
      final q = cam.p(xf(radius * math.cos(a), radius * math.sin(a), 0));
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    _tubeStroke(path, 2 * tube * xf.x.length * cam.scaleAt(xf.o), color, metal);
  }

  /// Strokes [path] as a round tube of screen width [w].
  void _tubeStroke(Path path, double w, Color color, double metal) {
    final lit = _lit(color, _viewNormal, metal);
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(1.2, w)
        ..color = labShade(lit, -0.3),
    );
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(0.9, w * 0.62)
        ..color = lit,
    );
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(0.5, w * 0.2)
        ..color = labShade(lit, 0.3),
    );
  }

  /// A round tube of radius [r] through the world points [pts] (HTML
  /// `TubeGeometry`).
  void tube(List<_V> pts, double r, Color color) {
    if (pts.length < 2) return;
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      final q = cam.p(pts[i]);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    _tubeStroke(path, 2 * r * cam.scaleAt(pts[pts.length ~/ 2]), color, 0);
  }

  /// A thin rod from [a] to [b] (spokes), [width] world units wide.
  void rod(_V a, _V b, double width, Color color) {
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      pens.stroke
        ..strokeWidth = math.max(0.8, width * cam.scaleAt(_V.lerp(a, b, 0.5)))
        ..color = color,
    );
  }

  /// A small sphere (particles) of radius [r] at [w].
  void dot(_V w, double r, Color color) {
    final rr = r * cam.scaleAt(w);
    if (rr < 0.2 || color.a <= 0) return;
    canvas.drawCircle(cam.p(w), math.max(0.8, rr), pens.fill..color = color);
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the desk
/// (notebook, pen, cup of warm water), S2 the bicycle on the ground (pump,
/// tyre lever, bucket of water); then the labels, the '?' sprite and the
/// confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
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
      _pens.fill..color = s.scenario == 0 ? _Colors.sceneS1 : _Colors.sceneS2,
    );
    if (s.scenario == 0) {
      _paintDesk(g);
    } else {
      _paintYard(g);
    }
    g.flush();
    if (showLabels) _paintLabels(g);
    _paintQuestion(g);
    _paintConfetti(canvas);
  }

  /// A `PlaneGeometry(2 hx, 2 hz)` floor at height [y] (the desk, the
  /// ground).
  void _plane(_Gfx g, double y, double hx, double hz, Color color) {
    final cam = g.cam;
    final poly = _clipNear(
      [_V(-hx, y, -hz), _V(hx, y, -hz), _V(hx, y, hz), _V(-hx, y, hz)],
      cam,
      _clipDepth,
    );
    if (poly.length < 3) return;
    g.canvas.drawPath(
      g.polygon([for (final v in poly) cam.p(v)]),
      _pens.fill..color = _lit(color, _V.up),
    );
  }

  // ---------------------------------------------------------- scenario 1

  /// HTML `buildS1Scene()`.
  void _paintDesk(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    _plane(g, _deskY, _deskHalfX, _deskHalfZ, _Colors.desk);
    g.later(cam.depth(_notebookPos), () => _paintNotebook(g));
    if (s.cupShown) g.later(cam.depth(_cupPos), () => _paintCup(g));
    if (s.refillAt == _RefillAt.loose) {
      final xf = s.refillXf;
      g.later(cam.depth(xf.o), () => _paintRefill(g, xf));
    }
    g.later(cam.depth(s.penXf(0, _penLength / 2, 0)), () => _paintPen(g));
  }

  /// The notebook: white box with its ruled-paper texture on top, the
  /// spiral rings along its left edge and, after the steps, the scratch
  /// and the blue line.
  void _paintNotebook(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final canvas = g.canvas;
    final xf = _world.child(_notebookPos);
    g.box(xf, _notebookSize, _Colors.paper, edge: _Colors.paperEdge);
    final halfX = _notebookSize.x / 2;
    final halfZ = _notebookSize.z / 2;
    final left = _notebookPos.x - halfX;
    final right = _notebookPos.x + halfX;
    // Ruled lines (canvas y 50, 90 … 490 of 512 → z) and the margin.
    final rule = _pens.stroke..color = _Colors.ruled;
    for (var y = _ruleFirst; y < _texturePx; y += _ruleGap) {
      final z = -halfZ + _notebookSize.z * y / _texturePx;
      final a = _V(left, _paperTop, z), b = _V(right, _paperTop, z);
      rule.strokeWidth = math.max(0.7, 0.03 * cam.scaleAt(a));
      canvas.drawLine(cam.p(a), cam.p(b), rule);
    }
    final mx = left + _notebookSize.x * _marginPx / _texturePx;
    final m0 = _V(mx, _paperTop, -halfZ), m1 = _V(mx, _paperTop, halfZ);
    canvas.drawLine(
      cam.p(m0),
      cam.p(m1),
      _pens.stroke
        ..strokeWidth = math.max(1, 0.045 * cam.scaleAt(m1))
        ..color = _Colors.margin,
    );
    // Spiral binding: rings in the y / z plane along the left edge.
    for (var z = -4.5; z <= 4.5 + 1e-9; z += 0.5) {
      g.ring(
        xf.child(_V(-halfX, 0, z), ry: math.pi / 2),
        _spiralR,
        _spiralTube,
        _Colors.spiral,
        metal: 0.8,
        segments: 16,
      );
    }
    if (s.scratched) {
      // `createScratchTexture('scratch')` on the 4 x 1 patch.
      final pen = _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.scratch.withValues(alpha: 0.4);
      _V at(double u, double v) => _scratchAt + _V(-2 + 4 * u, 0, -0.5 + v);
      for (final (u0, v0, u1, v1) in _scratchLines) {
        canvas.drawLine(cam.p(at(u0, v0)), cam.p(at(u1, v1)), pen);
      }
    }
    if (s.written) {
      // `createScratchTexture('line')`: quadraticCurveTo from (10, 32) over
      // (128, 10) to (246, 32) on the 256 x 64 px patch, 4 px wide.
      _V at(double px, double py) =>
          _lineAt + _V(-2 + 4 * px / 256, 0, -0.5 + py / 64);
      final p0 = at(10, 32), c = at(128, 10), p1 = at(246, 32);
      final path = _pens.path..reset();
      for (var i = 0; i <= 24; i++) {
        final t = i / 24;
        final q = cam.p(
          p0 * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + p1 * (t * t),
        );
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      canvas.drawPath(
        path,
        _pens.stroke
          ..strokeWidth = math.max(1.8, 0.0625 * cam.scaleAt(c))
          ..color = _Colors.writtenLine,
      );
    }
  }

  /// The pen: the refill inside it (seen in the gap above the tip and once
  /// unscrewed), the blue body with its clip, and the tip cone (its point
  /// down; the HTML cone points up) with a thread mark that turns as it
  /// unscrews.
  void _paintPen(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final pen = s.penXf;
    final tip = s.tipXf;
    if (s.refillAt == _RefillAt.pen) _paintRefill(g, s.refillXf);
    g.cylinder(
      pen.child(const _V(0, _penLength / 2, 0)),
      _penR,
      _penR,
      _penLength,
      _Colors.penBody,
      metal: 0.3,
    );
    g.box(
      pen.child(const _V(0.22, 2.3, 0)),
      const _V(0.1, 1.2, 0.15),
      _Colors.penClip,
      metal: 0.8,
    );
    g.cone(
      tip.child(const _V(0, -_coneH / 2, 0), rz: math.pi),
      _penR,
      _coneH,
      _Colors.penTip,
      metal: 0.8,
    );
    // The thread mark on the cone's rim, while it faces the camera.
    final spin = s.tipSpin.at(s.time);
    final rim = tip(_penR * math.cos(spin), 0, _penR * math.sin(spin));
    if ((cam.eye - rim).dot(tip.dir(_V(math.cos(spin), 0, math.sin(spin)))) >
        0) {
      g.canvas.drawLine(
        cam.p(rim),
        cam.p(
          tip(
            _penR * 0.45 * math.cos(spin),
            -_coneH * 0.55,
            _penR * 0.45 * math.sin(spin),
          ),
        ),
        _pens.stroke
          ..strokeWidth = math.max(0.8, 0.03 * cam.scaleAt(rim))
          ..color = _Colors.slate600,
      );
    }
  }

  /// The ink refill in the frame [xf]: its small metal ball-point at the
  /// foot (added), the clear tube and the blue ink column seen through it.
  void _paintRefill(_Gfx g, _Xf xf) {
    g.cone(
      xf.child(const _V(0, -_refillLength / 2 - 0.1, 0), rz: math.pi),
      _refillR * 0.75,
      0.2,
      _Colors.penTip,
      metal: 0.8,
    );
    g.cylinder(
      xf,
      _refillR,
      _refillR,
      _refillLength,
      _Colors.refillTube,
      segments: 10,
      opacity: 0.45,
    );
    g.cylinder(
      xf.child(const _V(0, -0.15, 0)),
      _inkR,
      _inkR,
      _inkLength,
      _Colors.ink,
      segments: 10,
    );
  }

  /// The cup of warm water: the refill standing in it, the water, the
  /// dissolving ink and the clear glass with its rim.
  void _paintCup(_Gfx g) {
    final s = scene;
    final xf = s.cupXf;
    final k = s.cupScale;
    if (s.refillAt == _RefillAt.cup) _paintRefill(g, s.refillXf);
    g.cylinder(
      xf.child(const _V(0, _waterY, 0)),
      _waterTopR,
      _waterBottomR,
      _waterH,
      _Colors.warmWater,
      segments: 32,
      opacity: 0.6,
    );
    for (final m in s.ink) {
      g.dot(
        xf.at(m.pos),
        _inkMoteR * k,
        _Colors.dissolved.withValues(alpha: 0.8 * m.life.clamp(0.0, 1.0)),
      );
    }
    g.cylinder(
      xf,
      _cupTopR,
      _cupBottomR,
      _cupH,
      _Colors.cupGlass,
      segments: 32,
      opacity: 0.3,
      cap: false,
    );
    g.canvas.drawPath(
      g.polygon(g.circle(xf, const _V(0, _cupH / 2, 0), _cupTopR)),
      _pens.stroke
        ..strokeWidth = 1.4
        ..color = _Colors.white.withValues(alpha: 0.8),
    );
  }

  // ---------------------------------------------------------- scenario 2

  /// HTML `buildS2Scene()`: the bicycle on the ground and, after the
  /// hypothesis, the bucket, the pump and the tyre lever. Meshes reaching
  /// behind a close-up camera are left out.
  void _paintYard(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    _plane(g, _groundY, _groundHalfX, _groundHalfZ, _Colors.ground);
    if (s.toolsShown &&
        cam.sees(
          s.bucketXf,
          const _V(-_bucketTopR, -_bucketH / 2, -_bucketTopR),
          const _V(_bucketTopR, _bucketH / 2, _bucketTopR),
        )) {
      g.later(cam.depth(_bucketPos), () => _paintBucket(g));
    }
    if (cam.sees(s.bikeXf, const _V(-6.8, -2.7, -1), const _V(6.8, 5.9, 1))) {
      g.later(cam.depth(s.bikeXf(0, 1.5, 0)), () => _paintBike(g));
    }
    if (s.tubeAt == _TubeAt.loose) {
      final xf = s.tubeXf;
      const r = _tubeR + _tubeTube;
      if (cam.sees(xf, const _V(-r, -r, -r), const _V(r, r, r))) {
        g.later(
          cam.depth(xf.o),
          () => g.ring(xf, _tubeR, _tubeTube, _Colors.tube),
        );
      }
    }
    if (s.toolsShown) {
      final pump = s.pumpXf;
      if (cam.sees(pump, const _V(-1, 0, -1), const _V(1, 6.2, 1)) &&
          cam.depth(s.nozzleAt) >= _clipDepth) {
        g.later(cam.depth(pump(0, 1, 0)), () => _paintPump(g));
      }
      final lever = s.leverXf;
      if (!s.leverGone &&
          cam.sees(
            lever,
            const _V(-0.4, -0.4, -0.4),
            const _V(0.4, 2.4, 0.4),
          )) {
        g.later(
          cam.depth(lever(0, 1, 0)),
          () => g.box(
            lever.child(const _V(0, 1, 0)),
            _leverSize,
            _Colors.lever,
            edge: _Colors.slate500,
          ),
        );
      }
    }
  }

  /// The bicycle: rear wheel (with its valve, squashed while flat), the
  /// inner tube once the tyre is open, front wheel, red frame, seat and
  /// handlebar.
  void _paintBike(_Gfx g) {
    final s = scene;
    final bike = s.bikeXf;
    _paintWheel(g, s.rearXf, valve: true);
    if (s.tubeAt == _TubeAt.tyre) {
      g.ring(s.tubeXf, _tubeR, _tubeTube, _Colors.tube);
    }
    _paintWheel(g, bike.child(const _V(_wheelX, 0, 0)), valve: false);
    const tubes = [
      (_V(0, 2, 0), math.pi / 4, 6.0),
      (_V(-1.5, 3.5, 0), -math.pi / 6, 6.0),
      (_V(0.8, 4.2, 0), math.pi / 2, 5.0),
    ];
    for (final (pos, rz, length) in tubes) {
      g.cylinder(
        bike.child(pos, rz: rz),
        0.12,
        0.12,
        length,
        _Colors.frame,
        segments: 10,
        metal: 0.4,
      );
    }
    g.box(
      bike.child(const _V(-2, 5.2, 0)),
      const _V(1.5, 0.5, 0.8),
      _Colors.rubber,
    );
    g.cylinder(
      bike.child(const _V(3, 4.8, 0), rx: math.pi / 2),
      0.1,
      0.1,
      2.5,
      _Colors.rubber,
      segments: 10,
    );
  }

  /// One wheel in the frame [xf]: eight spokes across the hub, the rim
  /// and the tyre ([valve]: the rear one's valve on top).
  void _paintWheel(_Gfx g, _Xf xf, {required bool valve}) {
    final spoke = _lit(_Colors.rim, _viewNormal, 0.8);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 8;
      final d = _V(-math.sin(a), math.cos(a), 0) * (_spokeLength / 2);
      g.rod(xf.at(d), xf.at(-d), 0.04, spoke);
    }
    g.ring(xf, _rimR, _rimTube, _Colors.rim, metal: 0.8);
    g.ring(xf, _wheelR, _wheelTube, _Colors.rubber);
    if (valve) {
      g.cylinder(
        xf.child(const _V(0, _valveY, 0)),
        0.05,
        0.05,
        _valveH,
        _Colors.valve,
        segments: 8,
      );
    }
  }

  /// The pump: hose to the nozzle, base, handle rod (pushed down by a
  /// stroke), body, grip and the nozzle (on the pump, held, or on the
  /// valve).
  void _paintPump(_Gfx g) {
    final s = scene;
    final xf = s.pumpXf;
    final k = s.toolScale(0);
    final h = s.handleY.at(s.time);
    g.tube(s.hose(), _hoseR * k, _Colors.pumpDark);
    g.box(xf, const _V(2, 0.2, 1), _Colors.pumpDark);
    g.cylinder(
      xf.child(_V(0, h, 0)),
      0.1,
      0.1,
      4,
      _Colors.pumpDark,
      segments: 10,
    );
    g.cylinder(
      xf.child(const _V(0, _pumpBodyH / 2, 0)),
      _pumpBodyR,
      _pumpBodyR,
      _pumpBodyH,
      _Colors.pump,
      metal: 0.6,
    );
    g.box(xf.child(_V(0, h + 2, 0)), const _V(1.5, 0.2, 0.4), _Colors.pumpDark);
    final onPump = !s.nozzleConnected && !s.nozzleLoose;
    g.cylinder(
      _world.child(s.nozzleAt, rz: math.pi / 2).scaled(onPump ? k : 1),
      _nozzleR,
      _nozzleR,
      _nozzleLength,
      _Colors.nozzle,
      segments: 10,
    );
  }

  /// The bucket of water. Seen through its opening: the inside wall, the
  /// part of the tube under the water, the water, the bubbles and the red
  /// leak ring; then the rim, and the tube and bubbles above it.
  void _paintBucket(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final canvas = g.canvas;
    final xf = s.bucketXf;
    const rimY = _bucketH / 2;
    const waterTopY = _bucketWaterY + _bucketWaterH / 2;
    g.cylinder(
      xf,
      _bucketTopR,
      _bucketBottomR,
      _bucketH,
      _Colors.bucket,
      segments: 32,
      metal: 0.5,
      cap: false,
    );
    final opening = g.freshPolygon(
      g.circle(xf, const _V(0, rimY, 0), _bucketTopR),
    );
    final water = g.freshPolygon(
      g.circle(xf, const _V(0, waterTopY, 0), _bucketWaterTopR),
    );
    canvas.drawPath(
      opening,
      _pens.fill..color = _lit(_Colors.bucketInside, _viewNormal, 0.5),
    );
    // The tube's centre line, split where it crosses the water and the rim
    // (world heights).
    final inWater = s.tubeAt == _TubeAt.water;
    final tube = s.tubeXf;
    final waterWorld = xf(0, waterTopY, 0).y;
    final rimWorld = xf(0, rimY, 0).y;
    void tubePart(bool Function(double y) keep) {
      if (!inWater) return;
      final w = 2 * _tubeTube * cam.scaleAt(tube.o);
      final path = Path();
      var open = false;
      for (var i = 0; i <= 96; i++) {
        final a = 2 * math.pi * i / 96;
        final p = tube(_tubeR * math.cos(a), _tubeR * math.sin(a), 0);
        if (keep(p.y)) {
          final q = cam.p(p);
          if (open) {
            path.lineTo(q.dx, q.dy);
          } else {
            path.moveTo(q.dx, q.dy);
            open = true;
          }
        } else {
          open = false;
        }
      }
      g._tubeStroke(path, w, _Colors.tube, 0);
    }

    canvas.save();
    canvas.clipPath(opening);
    canvas.save();
    canvas.clipPath(water);
    tubePart((y) => y < waterWorld);
    canvas.restore();
    final waterLit = _lit(_Colors.bucketWater, _V.up);
    canvas.drawPath(water, _pens.fill..color = waterLit.withValues(alpha: 0.8));
    if (s.ringShown) _paintLeakRing(g, waterWorld);
    tubePart((y) => y >= waterWorld && y < rimWorld);
    for (final b in s.bubbles) {
      if (b.pos.y < rimWorld) _bubble(g, b);
    }
    canvas.restore();
    canvas.drawPath(
      opening,
      _pens.stroke
        ..strokeWidth = math.max(1.5, 0.08 * cam.scaleAt(xf.o))
        ..color = labShade(_lit(_Colors.bucket, _viewNormal, 0.5), 0.25),
    );
    tubePart((y) => y >= rimWorld);
    for (final b in s.bubbles) {
      if (b.pos.y >= rimWorld) _bubble(g, b);
    }
  }

  /// One bubble (HTML white sphere, r 0.1, opacity 0.5 x life), with a
  /// thin outline so it shows on the light water (added).
  void _bubble(_Gfx g, _Mote b) {
    final a = 0.5 * b.life.clamp(0.0, 1.0);
    g.dot(b.pos, _bubbleR, _Colors.bubble.withValues(alpha: a));
    final c = g.cam.p(b.pos);
    final r = _bubbleR * g.cam.scaleAt(b.pos);
    if (r > 1.5) {
      g.canvas.drawCircle(
        c,
        r,
        _pens.stroke
          ..strokeWidth = 1
          ..color = _Colors.slate500.withValues(alpha: math.min(1, a * 1.4)),
      );
    }
  }

  /// HTML `redTarget`: a red ring (`RingGeometry`) lying on the water
  /// around the bubbles.
  void _paintLeakRing(_Gfx g, double y) {
    final l = scene.leak;
    final at = _world.child(_V(l.x, y, l.z));
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addPolygon(g.circle(at, _V.zero, _leakRingOuter), true)
      ..addPolygon(g.circle(at, _V.zero, _leakRingInner), true);
    g.canvas.drawPath(path, _pens.fill..color = _Colors.leakRing);
  }

  // -------------------------------------------------------------- labels

  /// HTML `createTextSprite` labels of the objects on show.
  void _paintLabels(_Gfx g) {
    final s = scene;
    if (s.scenario == 0) {
      _chip(g, _notebookLabelAt, _t('lbl_notebook'));
      _chip(g, s.penXf(0, _penLabelY, 0), _t('lbl_pen'));
      if (s.cupShown && s.cupScale > 0.6) {
        _chip(g, s.cupXf(0, _cupLabelY, 0), _t('lbl_water'));
      }
      return;
    }
    _chip(g, _tyreLabelAt, _t('lbl_tyre'));
    if (!s.toolsShown) return;
    if (s.toolScale(0) > 0.6) {
      _chip(g, s.pumpXf.at(_pumpLabelAt), _t('lbl_pump'));
    }
    if (!s.leverGone && s.toolScale(1) > 0.6) {
      _chip(g, s.leverXf(0, 3, 0), _t('lbl_lever'));
    }
    if (s.toolScale(2) > 0.6) {
      _chip(g, s.bucketXf.at(_bucketLabelAt), _t('lbl_bucket'));
    }
  }

  /// HTML `createTextSprite`: dark chip with an indigo border and white
  /// bold text, centred on [at] and kept inside the visible canvas.
  void _chip(_Gfx g, _V at, String text) {
    if (g.cam.depth(at) < _clipDepth) return;
    final size = cache.chipSize(text);
    var rect = Rect.fromCenter(
      center: g.cam.p(at),
      width: size.width,
      height: size.height,
    );
    final s = scene;
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
    g.canvas.drawRRect(
      rr.shift(const Offset(0, 2)),
      _pens.fill..color = _Colors.black.withValues(alpha: 0.2),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.4
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

  /// HTML `createIconSprite('question')` (2 x 2 units, drawn over
  /// everything): a white disc with a dark '?'. It pops in (added).
  void _paintQuestion(_Gfx g) {
    final s = scene;
    if (s.questionAt < 0) return;
    final at = s.questionPos;
    if (g.cam.depth(at) < _clipDepth) return;
    final grow = Curves.easeOutBack.transform(
      ((s.time - s.questionAt) / 0.25).clamp(0.0, 1.0),
    );
    final unit = g.cam.scaleAt(at) * grow;
    if (unit <= 0.5) return;
    final c = g.cam.p(at);
    g.canvas.drawCircle(
      c + Offset(0, 0.06 * unit),
      60 / 64 * unit,
      _pens.fill..color = _Colors.black.withValues(alpha: 0.18),
    );
    g.canvas.drawCircle(
      c,
      60 / 64 * unit,
      _pens.fill..color = _Colors.questionDisc,
    );
    final tp = cache.mark(80 / 64 * unit);
    tp.paint(
      g.canvas,
      c + Offset(-tp.width / 2, -tp.height / 2 + 6 / 64 * unit),
    );
  }

  /// HTML `confetti(...)` with the final card.
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
