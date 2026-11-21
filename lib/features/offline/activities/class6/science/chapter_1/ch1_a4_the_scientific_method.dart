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

/// Class 6 Science • Chapter 1 • Activity 4
/// The Scientific Method ("Unravelling Mysteries").
///
/// Native Flutter port of `Cl6S-Ch1-A4-TheScientificMethod.html` (Three.js
/// r128). The Three.js mystery desk is redrawn by a small painter ([_Gfx])
/// that reproduces the HTML camera: position (0, 10, 12), look-at (0, 0, 0),
/// 45° field of view. The HTML's drag-and-drop cards (DOM elements laid over
/// the canvas) are Flutter [Draggable]s dropped on [DragTarget] zones.
///
/// Scenario 1 (Order the Method): five cards (Analyse, Observe, Test, Guess,
/// Wonder & Question) are dragged into the five numbered drop zones in the
/// order scientists use; each zone's '?' shows a hint and 'VERIFY' checks
/// the order once every zone holds a card.
///
/// Scenario 2 (Match the Step): eleven shuffled chips from everyday puzzles
/// (the pen that stopped writing, spoilt dal, a flat tyre, a bulb that will
/// not turn on) are sorted into the same five zones, several per zone: every
/// question goes to zone 2, every guess to zone 3, and the pen's
/// observation, test and analysis to zones 1, 4 and 5. 'VERIFY' checks them.
///
/// Scenario 3 (Run an Investigation): on the mystery desk the learner taps
/// the props in the order of the method. The Magnifying Glass glides forward
/// ("My pen is not writing."), the Question sign and the Guess light bulb
/// each offer three choices (the right question makes the sign pulse, the
/// right guess lights the bulb), the Pen's cap comes off to check the
/// refill, and choosing the right analysis on the Notepad makes the pencil
/// scribble. 'View Final Results' then sums up the scientific method.
class Ch1A4TheScientificMethodPage extends StatefulWidget {
  const Ch1A4TheScientificMethodPage({super.key});

  @override
  State<Ch1A4TheScientificMethodPage> createState() =>
      _ScientificMethodLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises four tones with Web Audio; they map to the closest files:
/// 'click' (a card picked up, a prop tapped) → click (`science/click.mp3`),
/// 'drop' (a card dropped into a zone, the right choice in a menu) → drop
/// (`science/click.mp3` too, the closest short knock), 'success' (a correct
/// VERIFY, the solved pen mystery) → success (`math/success.mp3`), 'error'
/// (a wrong VERIFY or choice) → wrong (`science/error.mp3`). The shell plays
/// toggle (`science/dropdown.mp3`), scenario (`science/page_open.mp3`),
/// curtain (`science/curtain.mp3`) and correct (`math/success.mp3`, its
/// positive toasts; this lab's own observation toasts are silent, as in the
/// HTML).
enum _Sound implements LabTone {
  /// Generic button click; a card picked up or a prop tapped (HTML
  /// `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive shell toasts.
  correct('audio/class6/math/success.mp3'),

  /// Wrong VERIFY, wrong menu choice, a prop out of turn (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// A correct VERIFY or the solved mystery: the success popup opens (HTML
  /// `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A card dropped into a zone, the right menu choice (HTML `drop`).
  drop('audio/class6/science/click.mp3');

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
/// (material colours, sprite canvases).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color purple400 = Color(0xFFC084FC);
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

  /// `bg-slate-800/50` (sidebar cards) and `bg-slate-900/90` (toast).
  static const Color slate800Half = Color(0x801E293B);
  static const Color slate900Toast = Color(0xE60F172A);

  // ---------------------------------------------------- drop zones / cards
  /// `.dropzone-box`: dashed `rgba(234, 179, 8, 0.5)` border on
  /// `rgba(255, 255, 255, 0.6)` (light) or `rgba(15, 23, 42, 0.7)` (dark).
  static const Color zoneDash = Color(0x80EAB308);
  static const Color zoneLight = Color(0x99FFFFFF);
  static const Color zoneDark = Color(0xB30F172A);

  /// `.highlight`: solid `#eab308` border, `rgba(234, 179, 8, 0.2)` fill and
  /// a `rgba(234, 179, 8, 0.3)` glow.
  static const Color zoneHotFill = Color(0x33EAB308);
  static const Color zoneHotGlow = Color(0x4DEAB308);

  /// `.filled`: `rgba(255, 255, 255, 0.8)` / `rgba(0, 0, 0, 0.4)` with a
  /// `rgba(0, 0, 0, 0.1)` / `rgba(255, 255, 255, 0.2)` border.
  static const Color zoneFilledLight = Color(0xCCFFFFFF);
  static const Color zoneFilledDark = Color(0x66000000);
  static const Color zoneFilledEdgeLight = Color(0x1A000000);
  static const Color zoneFilledEdgeDark = Color(0x33FFFFFF);

  /// Zone number: `text-slate-400/50`.
  static const Color zoneNumber = Color(0x8094A3B8);

  /// Step cards (`border-blue-400 dark:border-blue-500/50`, `bg-white
  /// dark:bg-slate-800/80`).
  static const Color cardDark = Color(0xCC1E293B);
  static const Color cardEdgeDark = Color(0x803B82F6);

  /// Everyday chips (`border-slate-300 dark:border-slate-500/50`).
  static const Color chipEdgeDark = Color(0x8064748B);

  /// Card shadow while lifted (`0 10px 25px -5px rgba(0, 0, 0, 0.3)`).
  static const Color liftShadow = Color(0x4D000000);

  /// VERIFY: `from-blue-600 to-indigo-600`, `border-white/20`,
  /// `shadow-blue-500/30`.
  static const Color verifyEdge = Color(0x33FFFFFF);
  static const Color verifyGlow = Color(0x4D3B82F6);

  /// Hint overlay: `bg-slate-800/95`, `border-slate-600`.
  static const Color hintBg = Color(0xF21E293B);

  /// Success modal trophy: `bg-yellow-500/20`, `border-yellow-500/30`.
  static const Color trophyBg = Color(0x33EAB308);
  static const Color trophyEdge = Color(0x4DEAB308);

  /// Final modal star: `from-yellow-400 to-orange-500`, `border-white/20`,
  /// `shadow rgba(250, 204, 21, 0.4)`; stat tiles `bg-slate-800/80`.
  static const Color starGlow = Color(0x66FACC15);
  static const Color statBg = Color(0xCC1E293B);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617 (dark theme), 0xe2e8f0 (light theme).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate200;

  /// Wooden desk `0x5c3a21`.
  static const Color desk = Color(0xFF5C3A21);

  /// Magnifying glass: ring `0x333333` (metalness 0.8), handle `0x8b4513`,
  /// clear glass lens.
  static const Color ring = Color(0xFF333333);
  static const Color ringSheen = Color(0xFFB8BEC8);
  static const Color handle = Color(0xFF8B4513);
  static const Color lens = Color(0x33BFDBFE);
  static const Color lensGlint = Color(0xB3FFFFFF);

  /// Question sign: white board, `0xaaaaaa` pole, `#1d4ed8` question mark.
  static const Color sign = white;
  static const Color pole = Color(0xFFAAAAAA);
  static const Color signMark = Color(0xFF1D4ED8);

  /// Light bulb: clear glass, `0x888888` base, `PointLight(0xffaa00)`.
  static const Color bulbGlass = Color(0x59F8FAFC);
  static const Color bulbBase = Color(0xFF888888);
  static const Color bulbLight = Color(0xFFFFAA00);
  static const Color filament = Color(0xFF78716C);
  static const Color filamentHot = Color(0xFFFFF7D6);

  /// Pen station: pen `0x1d4ed8`, cap `0x1e3a8a`, stand `0x333333`.
  static const Color pen = Color(0xFF1D4ED8);
  static const Color cap = Color(0xFF1E3A8A);
  static const Color stand = Color(0xFF333333);

  /// Notepad: white pad, `0xf59e0b` pencil (its wood tip and lead added).
  static const Color notepad = white;
  static const Color ruling = Color(0x5593C5FD);
  static const Color pencil = Color(0xFFF59E0B);
  static const Color pencilWood = Color(0xFFF3D7A6);
  static const Color pencilLead = Color(0xFF374151);

  /// Number slots: `0x1e293b` boxes with `#94a3b8` numbers.
  static const Color slot = slate800;
  static const Color slotNumber = slate400;

  /// Text sprites: `#1e293b` chip, `#3b82f6` border, white bold text.
  static const Color chipBg = slate800;
  static const Color chipBorder = blue500;
  static const Color chipText = white;

  /// HTML lights: `SpotLight(0xffddaa, 1.2)` and `DirectionalLight(0xabcdef,
  /// 0.5)`.
  static const Color spotTint = Color(0xFFFFDDAA);
  static const Color fillTint = Color(0xFFABCDEF);

  /// Soft contact shadows (the HTML spotlight casts PCF soft shadows).
  static const Color shadow = Color(0x73000000);

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
    card: _Colors.slate800Half,
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // success modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate900Toast,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // text-blue-300/80
    curtainIcon: _Colors.blue400,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.blue300,
    buttonBorder: Color(0xCC3B82F6),
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
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate900Toast,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.blue400,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.blue300,
    buttonBorder: Color(0xCC3B82F6),
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
/// are the HTML sidebar font-size setting: 18 px, slider 18–32 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 18,
  minSize: 18,
  maxSize: 32,
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
// From the HTML `i18n` table (Telugu dropped). The HTML instructions
// (`sN_desc`, HTML with `<br>` lines) are split into one key per line;
// `sN_step_M` are the sidebar step actions, `hud_sN` / `s3_hud_step` the
// HTML "Current Task" lines. 'CLICK' is 'TAP' on touch screens. Shell
// strings (Enter Lab, Reset, settings, tool tips) come from the shared
// shell. Keys marked "Added." are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Scientific Method',
    'app_subtitle': 'Class 6 • The Wonderful World',
    // The HTML curtain's lines; the shared curtain shows the title above
    // and 'Enter Lab' instead.
    't_main': 'UNRAVELLING MYSTERIES',
    't_sub': 'THE SCIENTIFIC METHOD',
    'sc1_title': '1. Order the Method',
    'sc2_title': '2. Match the Step',
    'sc3_title': '3. Run an Investigation',
    's1_obj':
        'Uncover the five steps scientists (and everyone else) use to find answers — Observe, Wonder & Question, Guess, Test, Analyse.',
    's2_obj':
        'Identify which step of the scientific method is being used in these everyday scenarios.',
    's3_obj':
        "Act out the scientific method to solve the mystery of the pen that won't write on the desk.",
    'task_instr': 'Instructions:',
    // HTML `s1_desc`.
    's1_desc_1':
        '1. First, we observe something that we find interesting or we do not understand.',
    's1_desc_2':
        '2. This makes us wonder and perhaps think of a question about it.',
    's1_desc_3': '3. Then, we guess a possible answer to that question.',
    's1_desc_4':
        '4. We test this guess through experiments or more observations.',
    's1_desc_5':
        '5. We then try to analyse the results to see if it actually answers our question.',
    's1_desc_drag': 'Drag the cards into the correct order (1 to 5).',
    // HTML `s2_desc`; `s2_desc_q` / `s2_desc_g` are its highlighted words.
    's2_desc_intro':
        'In real life, we use the scientific method all the time without realizing it!',
    's2_desc_read':
        'Read each card and decide if the person is asking a Question (Slot 2) or making a Guess (Slot 3).',
    's2_desc_q': 'Question (Slot 2)',
    's2_desc_g': 'Guess (Slot 3)',
    's2_desc_drag':
        'Drag all the chips into the correct drop zones. Multiple chips can be placed in the same zone.',
    // HTML `s3_desc`.
    's3_desc_intro': 'Look at the 3D Mystery Desk! We have a broken pen.',
    's3_desc_tap':
        'Tap the objects on the desk in the correct order to follow the Scientific Method:',
    's3_item_1': '1. Magnifying Glass',
    's3_item_2': '2. Question Sign',
    's3_item_3': '3. Guess Lightbulb',
    's3_item_4': '4. Pen Test Station',
    's3_item_5': '5. Notepad Analysis',
    // The five steps (scenario 1 cards, scenario 3 concepts).
    'step_obs': 'Observe',
    'step_q': 'Wonder & Question',
    'step_g': 'Guess',
    'step_t': 'Test',
    'step_a': 'Analyse',
    // HTML "Current Task" lines.
    'hud_s1': '1. Order the Method - Drag cards to order.',
    'hud_s2': '2. Match the Step - Classify scenarios into steps.',
    's3_hud_step':
        'Step {step}/5: Tap the matching prop to solve the pen mystery!',
    'btn_verify': 'VERIFY',
    'hint_title': 'Hint',
    'hint_1':
        'This is the step where you first notice something interesting or puzzling.',
    'hint_2':
        "This is the step where you ask 'why' or 'how' about what you noticed.",
    'hint_3':
        'This is the step where you offer a possible answer to your question.',
    'hint_4':
        'This is the step where you check if your possible answer is actually correct.',
    'hint_5':
        'This is the step where you look at your results and decide if they answer your question.',
    // Scenario 2 chips and the pen mystery.
    'pen_o': 'My pen is not writing.',
    'pen_q': 'Why did my pen stop writing?',
    'pen_g': 'Maybe the ink finished.',
    'pen_t': 'I open the pen and check the refill.',
    'pen_a': 'The guess was correct - the ink had finished.',
    'dal_q': 'Why did the dal get spoilt?',
    'dal_g': 'Was there too much water?',
    'tyre_q': 'Why did the tyre go flat?',
    'tyre_g': 'Did a thorn puncture it?',
    'bulb_q': "Why won't the bulb turn on?",
    'bulb_g': 'Is the filament broken?',
    'fb_s1_ok':
        'Excellent! You have arranged the five steps exactly as they appear in the book.',
    'fb_s1_bad':
        'Not quite right. First we notice something, then we ask why...',
    'fb_s2_ok':
        'Brilliant! You correctly identified which step each everyday action represents.',
    'fb_s2_bad':
        'Some chips are wrong. Remember: questions go to slot 2, guesses to slot 3.',
    'err_empty': 'Please place all items in the slots before verifying.',
    'p_done': 'Mission Accomplished!',
    // The HTML defines this text but only shows `p_summary2`, which
    // begins with it.
    'p_summary':
        'Science is not just about memorising facts and figures or doing experiments. It is about following a step by step process that helps us find answers to our questions.',
    'p_summary2':
        'Science is not just about memorising facts and figures or doing experiments. It is about following a step by step process that helps us find answers to our questions. The way you solved the pen mystery — observe, wonder and question, guess, test, analyse — is exactly how science works. Anyone who follows the scientific method is working like a scientist.',
    'btn_close_cont': 'Close & Continue',
    'btn_view_final': 'View Final Results',
    'mastery_achieved': 'Mastery Achieved!',
    'restart_lab': 'Finish / Restart Lab',
    // Scenario 3 choice menus.
    's3_menu_title': 'Select Action',
    'pen_q_opt2': 'Is it sunny today?',
    'pen_q_opt3': 'Who makes pens?',
    'pen_g_opt1': 'Maybe it is broken.',
    'pen_g_opt3': 'Maybe I forgot how to write.',
    'pen_a_opt2': "I still don't know.",
    'pen_a_opt3': 'Magic happened.',
    // The desk's text sprites (English only in the HTML; Hindi added).
    'lbl_magnifier': 'Magnifying Glass',
    'lbl_question': 'Question',
    'lbl_guess': 'Guess',
    'lbl_pen': 'Pen',
    'lbl_notepad': 'Notepad',
    // Final results tiles (English only in the HTML; Hindi added).
    'stat_concept': 'Conceptual Understanding',
    'stat_observe': 'Observation & Identification',
    'stat_reason': 'Scientific Reasoning',
    'stat_model': 'Classification & Modeling',
    // Added.
    's1_step_2': 'Tap VERIFY to check your order.',
    's2_step_2': 'Tap VERIFY to check your answers.',
    's3_step_1': 'Tap the Magnifying Glass to observe the pen.',
    's3_step_2': 'Tap the Question Sign and choose the right question.',
    's3_step_3': 'Tap the Guess Lightbulb and choose a possible answer.',
    's3_step_4': 'Tap the Pen Test Station to test your guess.',
    's3_step_5': 'Tap the Notepad and analyse the result.',
    'hud_s1_verify':
        'All five cards are placed. TAP VERIFY to check the order.',
    'hud_s2_verify': 'All the chips are placed. TAP VERIFY to check them.',
    'wrong_prop': 'Not that one yet! Step {step} needs the {prop}.',
    'menu_wrong':
        'Not quite. Pick the answer that fits this step of the method.',
    'slot_lbl': 'Slot {n}',
    'hint_btn': 'Hint for slot {n}',
    'cards_lbl': 'Cards',
    'scene_desc':
        'A wooden mystery desk with a magnifying glass, a question sign, a light bulb, a pen on a stand and a notepad, above five numbered slots',
  },
  'hi': {
    'app_title': 'वैज्ञानिक विधि',
    'app_subtitle': 'कक्षा 6 • विज्ञान की अद्भुत दुनिया',
    't_main': 'रहस्यों को सुलझाना',
    't_sub': 'वैज्ञानिक विधि',
    'sc1_title': '1. विधि को क्रम में लगाएं',
    'sc2_title': '2. चरण का मिलान करें',
    'sc3_title': '3. एक जांच चलाएं',
    's1_obj':
        'उन पांच चरणों को उजागर करें जिनका उपयोग वैज्ञानिक (और बाकी सभी) उत्तर खोजने के लिए करते हैं - अवलोकन करें, आश्चर्य करें और प्रश्न पूछें, अनुमान लगाएं, परीक्षण करें, विश्लेषण करें।',
    's2_obj':
        'पहचानें कि इन रोजमर्रा के परिदृश्यों में वैज्ञानिक पद्धति के किस चरण का उपयोग किया जा रहा है।',
    's3_obj':
        'डेस्क पर न लिखने वाले पेन के रहस्य को सुलझाने के लिए वैज्ञानिक विधि का प्रयोग करें।',
    'task_instr': 'निर्देश:',
    's1_desc_1':
        '1. सबसे पहले, हम कुछ ऐसा देखते हैं जो हमें दिलचस्प लगता है या हम नहीं समझते हैं।',
    's1_desc_2':
        '2. इससे हमें आश्चर्य होता है और शायद हम इसके बारे में कोई प्रश्न सोचते हैं।',
    's1_desc_3': '3. फिर, हम उस प्रश्न का संभावित उत्तर अनुमान लगाते हैं।',
    's1_desc_4':
        '4. हम प्रयोगों या अधिक अवलोकनों के माध्यम से इस अनुमान का परीक्षण करते हैं।',
    's1_desc_5':
        '5. फिर हम परिणामों का विश्लेषण करने का प्रयास करते हैं यह देखने के लिए कि क्या यह वास्तव में हमारे प्रश्न का उत्तर देता है।',
    's1_desc_drag': 'कार्डों को सही क्रम (1 से 5) में खींचें।',
    's2_desc_intro':
        'वास्तविक जीवन में, हम बिना एहसास किए हर समय वैज्ञानिक पद्धति का उपयोग करते हैं!',
    's2_desc_read':
        'प्रत्येक कार्ड को पढ़ें और तय करें कि क्या व्यक्ति प्रश्न (स्लॉट 2) पूछ रहा है या अनुमान (स्लॉट 3) लगा रहा है।',
    's2_desc_q': 'प्रश्न (स्लॉट 2)',
    's2_desc_g': 'अनुमान (स्लॉट 3)',
    's2_desc_drag':
        'सभी चिप्स को सही ड्रॉप ज़ोन में खींचें। एक ही ज़ोन में कई चिप्स रखे जा सकते हैं।',
    's3_desc_intro': '3D रहस्य डेस्क को देखें! हमारे पास एक टूटा हुआ पेन है।',
    's3_desc_tap':
        'वैज्ञानिक पद्धति का पालन करने के लिए डेस्क पर मौजूद वस्तुओं को सही क्रम में टैप करें:',
    's3_item_1': '1. मैग्निफाइंग ग्लास',
    's3_item_2': '2. प्रश्न चिह्न',
    's3_item_3': '3. गेस लाइटबल्ब',
    's3_item_4': '4. पेन टेस्ट स्टेशन',
    's3_item_5': '5. नोटपैड विश्लेषण',
    'step_obs': 'अवलोकन करें',
    'step_q': 'आश्चर्य करें और प्रश्न पूछें',
    'step_g': 'अनुमान लगाएं',
    'step_t': 'परीक्षण करें',
    'step_a': 'विश्लेषण करें',
    'hud_s1': '1. विधि को क्रम में लगाएं - कार्ड खींचें।',
    'hud_s2': '2. चरण का मिलान करें - परिदृश्यों को चरणों में वर्गीकृत करें।',
    's3_hud_step':
        'चरण {step}/5: पेन के रहस्य को सुलझाने के लिए सही वस्तु पर टैप करें!',
    'btn_verify': 'सत्यापित करें',
    'hint_title': 'संकेत',
    'hint_1':
        'यह वह चरण है जहां आप पहली बार कुछ दिलचस्प या हैरान करने वाला देखते हैं।',
    'hint_2': "यह वह चरण है जहां आप 'क्यों' या 'कैसे' पूछते हैं।",
    'hint_3': 'यह वह चरण है जहां आप एक संभावित उत्तर देते हैं।',
    'hint_4': 'यह वह चरण है जहां आप जांचते हैं कि क्या आपका उत्तर सही है।',
    'hint_5':
        'यह वह चरण है जहां आप तय करते हैं कि क्या परिणाम आपके प्रश्न का उत्तर देते हैं।',
    'pen_o': 'मेरा पेन नहीं लिख रहा है।',
    'pen_q': 'मेरे पेन ने लिखना क्यों बंद कर दिया?',
    'pen_g': 'शायद स्याही खत्म हो गई है।',
    'pen_t': 'मैं पेन खोलता हूं और रिफिल चेक करता हूं।',
    'pen_a': 'अनुमान सही था - स्याही खत्म हो गई थी।',
    'dal_q': 'दाल क्यों खराब हो गई?',
    'dal_g': 'क्या पानी बहुत ज्यादा था?',
    'tyre_q': 'टायर पंचर क्यों हो गया?',
    'tyre_g': 'क्या किसी कांटे ने इसे पंक्चर कर दिया?',
    'bulb_q': 'बल्ब क्यों नहीं चालू होगा?',
    'bulb_g': 'क्या फिलामेंट टूट गया है?',
    'fb_s1_ok':
        'बहुत बढ़िया! आपने पांच चरणों को बिल्कुल वैसे ही व्यवस्थित किया है जैसे वे पुस्तक में दिखाई देते हैं।',
    'fb_s1_bad':
        'बिल्कुल सही नहीं। पहले हम कुछ नोटिस करते हैं, फिर हम पूछते हैं क्यों...',
    'fb_s2_ok':
        'शानदार! आपने सही पहचान की कि प्रत्येक रोजमर्रा की कार्रवाई किस चरण का प्रतिनिधित्व करती है।',
    'fb_s2_bad':
        'कुछ चिप्स गलत हैं। याद रखें: प्रश्न स्लॉट 2 में जाते हैं, अनुमान स्लॉट 3 में।',
    'err_empty': 'कृपया सत्यापित करने से पहले सभी आइटम स्लॉट में रखें।',
    'p_done': 'मिशन पूरा हुआ!',
    'p_summary':
        'विज्ञान केवल तथ्यों और आंकड़ों को याद रखने या प्रयोग करने के बारे में नहीं है। यह एक चरण-दर-चरण प्रक्रिया का पालन करने के बारे में है जो हमें हमारे सवालों के जवाब खोजने में मदद करता है।',
    'p_summary2':
        'विज्ञान केवल तथ्यों और आंकड़ों को याद रखने या प्रयोग करने के बारे में नहीं है। यह एक चरण-दर-चरण प्रक्रिया का पालन करने के बारे में है जो हमें हमारे सवालों के जवाब खोजने में मदद करता है। जिस तरह से आपने पेन के रहस्य को सुलझाया - निरीक्षण करें, आश्चर्य करें और प्रश्न करें, अनुमान लगाएं, परीक्षण करें, विश्लेषण करें - ठीक वैसे ही विज्ञान काम करता है। कोई भी व्यक्ति जो वैज्ञानिक पद्धति का पालन करता है वह वैज्ञानिक की तरह काम कर रहा है।',
    'btn_close_cont': 'बंद करें और जारी रखें',
    'btn_view_final': 'अंतिम परिणाम देखें',
    'mastery_achieved': 'महारत हासिल की!',
    'restart_lab': 'प्रयोगशाला समाप्त/पुनः प्रारंभ करें',
    's3_menu_title': 'क्रिया चुनें',
    'pen_q_opt2': 'क्या आज धूप है?',
    'pen_q_opt3': 'पेन कौन बनाता है?',
    'pen_g_opt1': 'शायद यह टूट गया है।',
    'pen_g_opt3': 'शायद मैं लिखना भूल गया हूँ।',
    'pen_a_opt2': 'मुझे अभी भी नहीं पता।',
    'pen_a_opt3': 'जादू हो गया।',
    'lbl_magnifier': 'मैग्निफाइंग ग्लास',
    'lbl_question': 'प्रश्न',
    'lbl_guess': 'अनुमान',
    'lbl_pen': 'पेन',
    'lbl_notepad': 'नोटपैड',
    'stat_concept': 'वैचारिक समझ',
    'stat_observe': 'अवलोकन और पहचान',
    'stat_reason': 'वैज्ञानिक तर्क',
    'stat_model': 'वर्गीकरण और मॉडलिंग',
    's1_step_2': 'अपने क्रम की जाँच के लिए सत्यापित करें पर टैप करें।',
    's2_step_2': 'अपने उत्तरों की जाँच के लिए सत्यापित करें पर टैप करें।',
    's3_step_1': 'पेन का अवलोकन करने के लिए मैग्निफाइंग ग्लास पर टैप करें।',
    's3_step_2': 'प्रश्न चिह्न पर टैप करें और सही प्रश्न चुनें।',
    's3_step_3': 'गेस लाइटबल्ब पर टैप करें और एक संभावित उत्तर चुनें।',
    's3_step_4':
        'अपने अनुमान का परीक्षण करने के लिए पेन टेस्ट स्टेशन पर टैप करें।',
    's3_step_5': 'नोटपैड पर टैप करें और परिणाम का विश्लेषण करें।',
    'hud_s1_verify':
        'पांचों कार्ड रख दिए गए हैं। क्रम जाँचने के लिए सत्यापित करें पर टैप करें।',
    'hud_s2_verify':
        'सभी चिप्स रख दिए गए हैं। उन्हें जाँचने के लिए सत्यापित करें पर टैप करें।',
    'wrong_prop': 'अभी वह नहीं! चरण {step} के लिए {prop} चाहिए।',
    'menu_wrong': 'बिल्कुल सही नहीं। विधि के इस चरण के लिए सही उत्तर चुनें।',
    'slot_lbl': 'स्लॉट {n}',
    'hint_btn': 'स्लॉट {n} के लिए संकेत',
    'cards_lbl': 'कार्ड',
    'scene_desc':
        'पाँच क्रमांकित स्लॉट के ऊपर मैग्निफाइंग ग्लास, प्रश्न चिह्न, बल्ब, स्टैंड पर रखा पेन और नोटपैड वाली लकड़ी की रहस्य डेस्क',
  },
};

/// Number of steps of each scenario: scenarios 1 and 2 place their cards,
/// then VERIFY; scenario 3 has the five props of the method.
const List<int> _stepCounts = [2, 2, 5];

/// Index of the investigation scenario (HTML scenario 3).
const int _investigation = 2;

/// The scenarios for [lang], built from the string table. Scenario 3's
/// steps carry the method step as their concept and the pen mystery's
/// line as their observation (HTML `pen_o` … `pen_a`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    LabScenarioData(
      title: t('sc1_title'),
      objective: t('s1_obj'),
      steps: [
        LabStep(concept: '', action: t('s1_desc_drag')),
        LabStep(
          concept: '',
          action: t('s1_step_2'),
          observation: t('fb_s1_ok'),
        ),
      ],
    ),
    LabScenarioData(
      title: t('sc2_title'),
      objective: t('s2_obj'),
      steps: [
        LabStep(concept: '', action: t('s2_desc_drag')),
        LabStep(
          concept: '',
          action: t('s2_step_2'),
          observation: t('fb_s2_ok'),
        ),
      ],
    ),
    LabScenarioData(
      title: t('sc3_title'),
      objective: t('s3_obj'),
      steps: [
        for (final m in _Method.values)
          LabStep(
            concept: t(m.key),
            action: t('s3_step_${m.slot}'),
            observation: t(m.penKey),
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

/// HTML camera: `PerspectiveCamera(45, …)` tweened by `resetCamera()` to
/// (0, 10, 12), looking at `controls.target` (0, 0, 0).
const double _fovDegrees = 45;
const _V _eye = _V(0, 10, 12);
const _V _lookAt = _V(0, 0, 0);
const double _near = 0.1;

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

/// Chip padding as a share of the label size.
const double _chipPadX = 0.6;
const double _chipPadY = 0.32;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the desk beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the desk is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing and the canvas cards keep clear of: the HUD
/// chip at the bottom of the canvas (two lines, label row, padding; x UI
/// scale) and the compact floating mission card (phones in landscape:
/// screens shorter than [_compactBelow], at most [_compactCardMax] of the
/// height, 12 px from the top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted desk (the HTML camera is zoom 1); it is never
/// drawn smaller than [_minZoom].
const double _maxZoom = 1.3;
const double _minZoom = 0.3;

// ------------------------------------------------------------------ lights

/// `AmbientLight(0xffffff, 0.4)`, `SpotLight(0xffddaa, 1.2)` at (0, 15, 5)
/// aimed at the origin (angle π/4, penumbra 0.5) and `DirectionalLight(
/// 0xabcdef, 0.5)` from (-10, 5, -5).
const double _ambient = 0.4;
const double _spotPower = 1.2;
const double _fillPower = 0.5;
const _V _spotPos = _V(0, 15, 5);
const _V _fillDir = _V(-0.8165, 0.4082, -0.4082);
const double _spotOuter = math.pi / 4;
const double _spotInner = _spotOuter * 0.5;

/// `PointLight(0xffaa00, 2, 5)` inside the bulb (intensity 0 until the
/// right guess).
const double _bulbPower = 2;
const double _bulbReach = 5;

// -------------------------------------------------------------------- desk

/// Wooden desk `BoxGeometry(24, 0.5, 12)` at y = -0.25 (its top at y = 0).
const double _deskHalfX = 12;
const double _deskHalfZ = 6;
const double _deskThick = 0.5;

/// The five slots: `BoxGeometry(2, 0.05, 2)` at (-8 + 4i, 0.025, 2) with a
/// 1.8 x 1.8 number plane on top.
const double _slotX0 = -8;
const double _slotSpacing = 4;
const double _slotZ = 2;
const double _slotHalf = 1;
const double _slotTop = 0.05;
const double _slotNumberHalf = 0.9;

// ---------------------------------------------------------- magnifying glass

/// Group at (-8, 1, -1), `rotation.x = -π/4`; `TorusGeometry(0.8, 0.1)`,
/// lens `CylinderGeometry(0.75, 0.75, 0.05)`, handle `CylinderGeometry(0.15,
/// 0.15, 1.5)` at y = -1.5 (local y -2.25 … -0.75).
const _V _magHome = _V(-8, 1, -1);
const double _magTilt = -math.pi / 4;
const double _ringR = 0.8;
const double _ringTube = 0.1;
const double _lensR = 0.75;
const double _handleR = 0.15;
const double _handleTop = -0.75;
const double _handleEnd = -2.25;

/// `animate()`: `position.y = 1 + Math.sin(Date.now() * 0.002) * 0.05`.
const double _bobAmp = 0.05;
const double _bobRate = 2;

/// Step 1: `Tween(position).to({x: 0, y: 2, z: 2}, 800)` (Quadratic.Out),
/// `setTimeout(…, 2000)`, then back to (-8, 1, -1) in 500 ms.
const _V _magForward = _V(0, 2, 2);
const double _magOutSeconds = 0.8;
const double _magHoldSeconds = 2;
const double _magBackSeconds = 0.5;

// ------------------------------------------------------------ question sign

/// Group at (-4, 1.5, -1): `BoxGeometry(1.5, 1.2, 0.1)` board, '?' face
/// `PlaneGeometry(1, 1)` at z = 0.06, pole `CylinderGeometry(0.05, 0.05, 1)`
/// at y = -1; `rotation.y = Math.sin(t * 0.5) * 0.1` (t = ms x 0.002).
const _V _signPos = _V(-4, 1.5, -1);
const _V _signSize = _V(1.5, 1.2, 0.1);
const double _signFace = 0.5;
const double _signFaceZ = 0.06;
const double _poleR = 0.05;
const double _signSway = 0.1;

/// Step 2: `Tween(scale).to(1.5, 300).yoyo(true).repeat(1)`.
const double _signPulse = 1.5;
const double _signPulseLeg = 0.3;

// --------------------------------------------------------------- light bulb

/// Group at (0, 1.5, -1): `SphereGeometry(0.7)` glass, base
/// `CylinderGeometry(0.3, 0.3, 0.5)` at y = -0.9.
const _V _bulbPos = _V(0, 1.5, -1);
const double _bulbR = 0.7;
const double _bulbBaseR = 0.3;
const double _bulbBaseTop = -0.65;
const double _bulbBaseBottom = -1.15;

// ---------------------------------------------------------- pen test station

/// Group at (4, 1, -1), `rotation.x = π/12`: pen `CylinderGeometry(0.15,
/// 0.15, 2)`, cap `CylinderGeometry(0.16, 0.16, 0.5)` at y = 1.25, stand
/// `CylinderGeometry(0.6, 0.8, 0.2)` at y = -0.9.
const _V _penPos = _V(4, 1, -1);
const double _penTilt = math.pi / 12;
const double _penR = 0.15;
const double _penHalf = 1;
const double _capR = 0.16;
const double _capHalf = 0.25;
const double _capRest = 1.25;
const double _standTopR = 0.6;
const double _standBottomR = 0.8;
const double _standTop = -0.8;
const double _standBottom = -1;

/// Step 4: `Tween(cap.position).to({y: 3}, 500)` and
/// `Tween(cap.rotation).to({y: 4π}, 500)`.
const double _capLifted = 3;
const double _capSeconds = 0.5;
const double _capTurns = 4 * math.pi;

// ------------------------------------------------------------------ notepad

/// Group at (8, 0.05, -1): pad `BoxGeometry(1.6, 0.1, 2.2)`, pencil
/// `CylinderGeometry(0.05, 0.05, 1.2)` at (0.3, 0.1, 0) with `rotation.z =
/// π/2`, `rotation.y = π/4`.
const _V _padPos = _V(8, 0.05, -1);
const _V _padSize = _V(1.6, 0.1, 2.2);
const _V _pencilAt = _V(0.3, 0.1, 0);
const double _pencilR = 0.05;
const double _pencilHalf = 0.6;
const double _pencilYaw = math.pi / 4;
const double _pencilRest = math.pi / 2;

/// Step 5: `Tween(pencil.rotation).to({z: π/1.5}, 200).yoyo(true)
/// .repeat(3)`: four 200 ms legs.
const double _pencilWrite = math.pi / 1.5;
const double _pencilLeg = 0.2;
const int _pencilLegs = 4;

/// Text sprites sit 1.5 above each group's origin (2 above the pen's).
const double _labelLift = 1.5;
const double _penLabelLift = 2;

// ----------------------------------------------------------------- confetti

/// canvas-confetti: ticks of 1/60 s, 200 ticks, velocity x 0.9 per tick,
/// gravity 3 px per tick, start velocity 45 px per tick.
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;

// ---------------------------------------------------------------- models

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V up = _V(0, 1, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A Three.js group's placement: origin and its (scaled) local axes, so
/// `at(x, y, z)` is the world point of a local one.
@immutable
class _Frame3 {
  const _Frame3(this.o, this.x, this.y, this.z);

  /// A group turned by [angle] about the world x axis (`rotation.x`).
  factory _Frame3.tiltX(_V o, double angle) {
    final c = math.cos(angle), s = math.sin(angle);
    return _Frame3(o, const _V(1, 0, 0), _V(0, c, s), _V(0, -s, c));
  }

  /// A group turned by [angle] about the world y axis (`rotation.y`) and
  /// scaled by [scale].
  factory _Frame3.turnY(_V o, double angle, double scale) {
    final c = math.cos(angle), s = math.sin(angle);
    return _Frame3(o, _V(c, 0, -s) * scale, _V.up * scale, _V(s, 0, c) * scale);
  }

  final _V o;
  final _V x;
  final _V y;
  final _V z;

  _V at(double lx, double ly, double lz) => o + x * lx + y * ly + z * lz;
}

/// Where the camera's look-at point lands on the stage and how much the
/// scene is enlarged (the HTML camera is [base]). The desk is fitted into
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

  /// The design point of [w] (everything on the desk is in front of the
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

  /// Screen bounds of [points].
  Rect bounds(Iterable<_V> points) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final w in points) {
      final q = p(w);
      l = math.min(l, q.dx);
      t = math.min(t, q.dy);
      r = math.max(r, q.dx);
      b = math.max(b, q.dy);
    }
    return Rect.fromLTRB(l, t, r, b);
  }
}

/// Where the ray from the spotlight through [w] meets the desk (y = 0): the
/// centre of [w]'s soft shadow.
_V _shadowOf(_V w) {
  final h = math.min(w.y, _spotPos.y - 0.5);
  final t = _spotPos.y / (_spotPos.y - h);
  final s = _spotPos + (w - _spotPos) * t;
  return _V(s.x, 0, s.z);
}

/// The five steps of the method, in order (HTML `State.s1Correct`): the
/// card text, and the pen mystery's line for that step.
enum _Method {
  observe('step_obs', 'pen_o'),
  question('step_q', 'pen_q'),
  guess('step_g', 'pen_g'),
  test('step_t', 'pen_t'),
  analyse('step_a', 'pen_a');

  const _Method(this.key, this.penKey);

  final String key;
  final String penKey;

  /// Its drop zone (1–5).
  int get slot => index + 1;

  /// The zone's '?' hint (HTML `hint_N`).
  String get hintKey => 'hint_$slot';

  /// Scenario 3's sidebar item ("1. Magnifying Glass").
  String get itemKey => 's3_item_$slot';
}

/// The cards of scenarios 1 and 2 with the zone they belong in (HTML
/// `getCardsForS1()`, in its order, and `getCardsForS2()`).
enum _Card {
  analyse('step_a', 5),
  observe('step_obs', 1),
  test('step_t', 4),
  guess('step_g', 3),
  question('step_q', 2),
  penObserve('pen_o', 1),
  penQuestion('pen_q', 2),
  penGuess('pen_g', 3),
  penTest('pen_t', 4),
  penAnalyse('pen_a', 5),
  dalQuestion('dal_q', 2),
  dalGuess('dal_g', 3),
  tyreQuestion('tyre_q', 2),
  tyreGuess('tyre_g', 3),
  bulbQuestion('bulb_q', 2),
  bulbGuess('bulb_g', 3);

  const _Card(this.key, this.slot);

  final String key;

  /// The zone (1–5) it belongs in.
  final int slot;

  /// One of scenario 1's step cards (the others are scenario 2's chips).
  bool get isStep => index < _Method.values.length;

  static List<_Card> of(int scenario) => scenario == 0
      ? values.sublist(0, _Method.values.length)
      : values.sublist(_Method.values.length);
}

/// The props on the mystery desk, in the order of the method (HTML
/// `props`), with their text sprites.
enum _Prop {
  magnifier('lbl_magnifier'),
  sign('lbl_question'),
  bulb('lbl_guess'),
  pen('lbl_pen'),
  notepad('lbl_notepad');

  const _Prop(this.labelKey);

  final String labelKey;

  _Method get method => _Method.values[index];
}

/// Scenario 3's "Select Action" menus (HTML `showS3Menu`): the prop that
/// opens it, its three options in the HTML's order and the right one.
enum _Menu {
  question(_Prop.sign, ['pen_q', 'pen_q_opt2', 'pen_q_opt3'], 0),
  guess(_Prop.bulb, ['pen_g_opt1', 'pen_g', 'pen_g_opt3'], 1),
  analysis(_Prop.notepad, ['pen_a', 'pen_a_opt2', 'pen_a_opt3'], 0);

  const _Menu(this.prop, this.options, this.answer);

  final _Prop prop;
  final List<String> options;
  final int answer;
}

/// The two canvas-confetti bursts.
enum _Burst {
  /// `celebrate()`: `confetti({particleCount: 100, spread: 70, origin:
  /// {y: 0.6}})`.
  celebrate(100, 70, 0.6),

  /// `showFinal()`: `confetti({particleCount: 150, spread: 100, origin:
  /// {y: 0.3}})`.
  finale(150, 100, 0.3);

  const _Burst(this.count, this.spreadDegrees, this.originY);

  final int count;
  final double spreadDegrees;

  /// Height of the burst's origin as a share of the canvas.
  final double originY;
}

/// One confetti piece (canvas-confetti `randomPhysics`).
@immutable
class _Confetto {
  const _Confetto({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.tilt,
    required this.wobble,
    required this.round,
  });

  final double angle;
  final double velocity;
  final Color color;
  final double tilt;
  final double wobble;
  final bool round;
}

/// Scenarios 1 and 2: the cards still to place (HTML `#cards-container`)
/// and the five drop zones (HTML `State.placements`).
class _Board {
  int scenario = 0;
  final List<_Card> tray = [];
  final List<List<_Card>> zones = [
    for (var i = 0; i < _Method.values.length; i++) <_Card>[],
  ];

  /// VERIFY found every card in its zone.
  bool solved = false;

  /// HTML `loadScenario`: scenario 1's cards in their fixed order,
  /// scenario 2's chips shuffled.
  void load(int index, math.Random random) {
    scenario = index;
    tray
      ..clear()
      ..addAll(_Card.of(index));
    if (index == 1) tray.shuffle(random);
    for (final zone in zones) {
      zone.clear();
    }
    solved = false;
  }

  /// Scenario 1 keeps one card per zone; scenario 2 stacks chips.
  bool get single => scenario == 0;

  /// The zone (0–4) holding [card], or null while it is in the tray.
  int? zoneOf(_Card card) {
    for (var i = 0; i < zones.length; i++) {
      if (zones[i].contains(card)) return i;
    }
    return null;
  }

  /// Every card is in a zone (HTML: all five placements set / the cards
  /// container is empty).
  bool get complete => tray.isEmpty;

  /// Every card sits in its own zone (HTML `verifyScenario`).
  bool get correct {
    if (!complete) return false;
    for (var i = 0; i < zones.length; i++) {
      for (final card in zones[i]) {
        if (card.slot != i + 1) return false;
      }
    }
    return true;
  }

  /// HTML `handleDragEnd` over a drop zone. In scenario 1 a card dropped
  /// on a filled zone swaps places with the card there (the HTML stacked
  /// both and kept only the new one).
  void place(_Card card, int zone) {
    final from = zoneOf(card);
    if (from == zone) return;
    final target = zones[zone];
    if (single && target.isNotEmpty) {
      final other = target.removeAt(0);
      if (from == null) {
        tray[tray.indexOf(card)] = other;
      } else {
        zones[from]
          ..remove(card)
          ..add(other);
      }
      target.add(card);
      return;
    }
    if (from == null) {
      tray.remove(card);
    } else {
      zones[from].remove(card);
    }
    target.add(card);
  }

  /// HTML `handleDragEnd` away from the zones: the card goes back to the
  /// end of the tray.
  void unplace(_Card card) {
    final from = zoneOf(card);
    if (from == null) return;
    zones[from].remove(card);
    tray.add(card);
  }
}

/// Mutable scene read by the painters every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// Scenarios 1 and 2.
  final _Board board = _Board();
  final math.Random _random = math.Random();

  // ------------------------------------------------------------ scenario 3
  /// HTML `State.s3Step` (1–5).
  int s3Step = 1;

  /// The pen mystery is solved (the pencil has scribbled).
  bool s3Done = false;

  /// A prop's animation is playing; taps wait for it.
  bool busy = false;

  /// The open "Select Action" menu (HTML `#s3-menu`).
  _Menu? menu;

  /// The magnifying glass's position tween.
  _V _magFrom = _magHome;
  _V _magTo = _magHome;
  double _magStart = -1;
  double _magSeconds = 0;
  bool _magEaseOut = false;

  /// Scene times the sign pulsed, the cap came off and the pencil started
  /// to scribble (-1: not yet).
  double signPulseAt = -1;
  double capAt = -1;
  double pencilAt = -1;

  /// The bulb's point light is on (HTML `light.intensity = 2`).
  bool bulbOn = false;

  // -------------------------------------------------------------- confetti
  _Burst? burst;
  double burstAt = -1;
  final List<_Confetto> confetti = [];

  /// Pending events of the running animation, in scene time (the HTML
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

  /// HTML `loadScenario(num)` (and `setupS3Interaction`, which puts the
  /// props back).
  void load(int index) {
    scenario = index;
    board.load(index, _random);
    s3Step = 1;
    s3Done = false;
    busy = false;
    menu = null;
    _magFrom = _magHome;
    _magTo = _magHome;
    _magStart = -1;
    signPulseAt = -1;
    capAt = -1;
    pencilAt = -1;
    bulbOn = false;
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

  /// HTML `animate()`: the framing slide (the props move with the time).
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

  /// canvas-confetti: a new burst of [kind].
  void fireConfetti(_Burst kind) {
    burst = kind;
    burstAt = time;
    confetti.clear();
    final spread = kind.spreadDegrees * math.pi / 180;
    for (var i = 0; i < kind.count; i++) {
      confetti.add(
        _Confetto(
          angle: -math.pi / 2 + spread * (0.5 - _random.nextDouble()),
          velocity:
              _confettiStart * 0.5 + _random.nextDouble() * _confettiStart,
          color: _Colors.confetti[_random.nextInt(_Colors.confetti.length)],
          tilt: _random.nextDouble() * math.pi,
          wobble: _random.nextDouble() * 10,
          round: _random.nextBool(),
        ),
      );
    }
  }

  // --------------------------------------------------------------- props

  /// The magnifying glass's tweened position, without the bob.
  _V get _magBase {
    if (_magStart < 0 || _magSeconds <= 0) return _magTo;
    final k = ((time - _magStart) / _magSeconds).clamp(0.0, 1.0);
    // TWEEN.Easing.Quadratic.Out, or the default Linear.
    final e = _magEaseOut ? k * (2 - k) : k;
    return _V.lerp(_magFrom, _magTo, e);
  }

  /// HTML step 1 tweens: glide the glass to [to] in [seconds].
  void glideMagnifier(_V to, double seconds, {required bool easeOut}) {
    _magFrom = _magBase;
    _magTo = to;
    _magStart = time;
    _magSeconds = seconds;
    _magEaseOut = easeOut;
  }

  /// The magnifying glass group: its tween plus the `animate()` bob,
  /// tilted back by π/4. The HTML bob overwrote the tween's y, so its
  /// glass never rose; here it rises to y = 2 as the tween intends.
  _Frame3 get magnifier => _Frame3.tiltX(
    _magBase + _V(0, _bobAmp * math.sin(time * _bobRate), 0),
    _magTilt,
  );

  /// The magnifying glass is in front of the other props (gliding).
  bool get magnifierForward => _magBase.z > _magHome.z + 0.05;

  /// The sign's pulse: 1 → 1.5 → 1 (two 300 ms legs).
  double get signScale {
    if (signPulseAt < 0) return 1;
    final e = (time - signPulseAt) / _signPulseLeg;
    if (e >= 2) return 1;
    final tri = e < 1 ? e : 2 - e;
    return 1 + (_signPulse - 1) * tri;
  }

  /// The question sign group, swaying (`rotation.y`) and pulsing.
  _Frame3 get sign => _Frame3.turnY(
    _signPos,
    _signSway * math.sin(time * _bobRate * 0.5),
    signScale,
  );

  /// The pen station group (tilted by π/12).
  _Frame3 get penStation => _Frame3.tiltX(_penPos, _penTilt);

  /// Progress of the cap's lift and spin (0 … 1).
  double get capProgress =>
      capAt < 0 ? 0 : ((time - capAt) / _capSeconds).clamp(0.0, 1.0);

  /// The cap's centre on the pen's axis (local y 1.25 → 3).
  double get capY => _capRest + (_capLifted - _capRest) * capProgress;

  /// The cap's turn about the pen's axis (0 → 4π).
  double get capTurn => _capTurns * capProgress;

  /// The pencil's `rotation.z`: π/2, rocking to π/1.5 and back twice.
  double get pencilRoll {
    if (pencilAt < 0) return _pencilRest;
    final e = (time - pencilAt) / _pencilLeg;
    if (e >= _pencilLegs) return _pencilRest;
    final leg = e.floor();
    final f = e - leg;
    final tri = leg.isEven ? f : 1 - f;
    return _pencilRest + (_pencilWrite - _pencilRest) * tri;
  }

  /// The pencil's ends on the notepad: (tip, back). Its axis is local y
  /// turned by `rotation.z` then `rotation.y` (Euler XYZ).
  (_V, _V) get pencil {
    final roll = pencilRoll;
    final s = math.sin(roll), c = math.cos(roll);
    final cy = math.cos(_pencilYaw), sy = math.sin(_pencilYaw);
    final axis = _V(-s * cy, c, s * sy);
    final mid = _padPos + _pencilAt;
    return (mid + axis * _pencilHalf, mid - axis * _pencilHalf);
  }

  /// Where a prop's text sprite is anchored.
  _V labelAt(_Prop p) => switch (p) {
    _Prop.magnifier => magnifier.at(0, _labelLift, 0),
    _Prop.sign => sign.at(0, _labelLift, 0),
    _Prop.bulb => _bulbPos + const _V(0, _labelLift, 0),
    _Prop.pen => penStation.at(0, _penLabelLift, 0),
    _Prop.notepad => _padPos + const _V(0, _labelLift, 0),
  };

  /// The world points that bound a prop as drawn now.
  List<_V> outline(_Prop p) {
    switch (p) {
      case _Prop.magnifier:
        final m = magnifier;
        final end = _handleClip(m);
        return [
          m.at(-_ringR - _ringTube, 0, 0),
          m.at(_ringR + _ringTube, 0, 0),
          m.at(0, _ringR + _ringTube, 0),
          m.at(0, -_ringR - _ringTube, 0),
          m.at(0, end, 0),
        ];
      case _Prop.sign:
        final g = sign;
        return [
          g.at(-_signSize.x / 2, _signSize.y / 2, 0),
          g.at(_signSize.x / 2, _signSize.y / 2, 0),
          g.at(-_signSize.x / 2, -_signSize.y / 2, 0),
          g.at(_signSize.x / 2, -_signSize.y / 2, 0),
          _V(_signPos.x, 0, _signPos.z),
        ];
      case _Prop.bulb:
        return [
          _bulbPos + const _V(-_bulbR, 0, 0),
          _bulbPos + const _V(_bulbR, 0, 0),
          _bulbPos + const _V(0, _bulbR, 0),
          _bulbPos + const _V(0, _bulbBaseBottom, 0),
        ];
      case _Prop.pen:
        final g = penStation;
        return [
          g.at(-_standBottomR, _standBottom, 0),
          g.at(_standBottomR, _standBottom, 0),
          g.at(0, _standBottom, _standBottomR),
          g.at(0, capY + _capHalf, 0),
          g.at(-_capR * 2, _penHalf, 0),
          g.at(_capR * 2, _penHalf, 0),
        ];
      case _Prop.notepad:
        final (tip, back) = pencil;
        final hx = _padSize.x / 2, hz = _padSize.z / 2;
        return [
          _padPos + _V(-hx, 0.05, -hz),
          _padPos + _V(hx, 0.05, -hz),
          _padPos + _V(-hx, 0.05, hz),
          _padPos + _V(hx, -0.05, hz),
          tip,
          back,
        ];
    }
  }

  /// A prop's screen box in [cam].
  Rect propRect(_Prop p, _Cam cam) => cam.bounds(outline(p));

  /// The prop at [pos] (HTML raycast on `props`): its box or, on a small
  /// screen, within a finger's reach of it.
  _Prop? propAt(Offset pos, double touch) {
    final cam = camera();
    _Prop? best;
    var bestD = double.infinity;
    for (final p in _Prop.values) {
      final r = propRect(p, cam);
      if (!r.inflate(touch * 0.5).contains(pos)) continue;
      final d = (r.center - pos).distance;
      if (d < bestD) {
        best = p;
        bestD = d;
      }
    }
    return best;
  }

  /// The prop the current step asks for.
  _Prop get wantedProp => _Prop.values[(s3Step - 1).clamp(0, 4)];
}

/// How far down the magnifying glass's handle shows: it ends at local y
/// -2.25, or where it meets the desk top.
double _handleClip(_Frame3 m) {
  // m.y.y < 0 never happens for the tilted glass (the handle points down).
  final reach = m.o.y / math.max(1e-6, m.y.y);
  return math.max(_handleEnd, -reach);
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
  // Nothing fits (a tiny canvas): the smallest desk, centred in the largest
  // free part.
  final zoom = z > 0 ? z : _minZoom;
  return _Framing(rect.center - extent(zoom).center, zoom);
}

/// Top-left of a chip of [size] centred on its anchor (the HTML sprites
/// are centred on their position).
Offset _chipOffset(Size size) => Offset(-size.width / 2, -size.height / 2);

class _ScientificMethodLabState extends State<Ch1A4TheScientificMethodPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();

  /// The props at rest (time 0), for the framing.
  final _Scene _rest = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// desk beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch1-a4-canvas');

  /// 1-based current step, derived from the scene ([_deriveStep]);
  /// steps.length + 1 once the scenario is done.
  int _step = 1;

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the desk keeps clear of that, so it does not
  /// move each time the card shrinks again.
  Rect? _cardRect;

  /// The zone (1–5) whose hint is on show (HTML `#hint-overlay`), and
  /// whether it is showing (it fades out after 4 s).
  int _hintZone = 0;
  bool _hintShown = false;
  Timer? _hintTimer;

  /// A wrong menu option flashing red (HTML `bg-red-600` for 500 ms).
  int? _flashOption;

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
    s.advance(dt);
    s.runCues();
    _frame.value = now;
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the desk after this frame (cards and canvas are laid out by
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

  /// Fits the desk's props, slots and labels into the part of the canvas
  /// no card covers: the tool column, the HUD (sidebar open) and the
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

  /// What the learner must see (HTML camera, zoom 1): the five props at
  /// rest, the magnifying glass at its closest, the lifted cap, the slots
  /// and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void point(_V w) => items.add((cam.p(w), Rect.zero));
    for (final prop in _Prop.values) {
      _rest.outline(prop).forEach(point);
      final size = _cache.chipSize(_t(prop.labelKey));
      items.add((cam.p(_rest.labelAt(prop)), _chipOffset(size) & size));
    }
    final forward = _Frame3.tiltX(_magForward, _magTilt);
    point(forward.at(-_ringR - _ringTube, 0, 0));
    point(forward.at(_ringR + _ringTube, 0, 0));
    point(forward.at(0, _handleEnd, 0));
    final lifted = forward.at(0, _labelLift, 0);
    final magChip = _cache.chipSize(_t(_Prop.magnifier.labelKey));
    items.add((cam.p(lifted), _chipOffset(magChip) & magChip));
    point(_rest.penStation.at(0, _capLifted + _capHalf, 0));
    for (var i = 0; i < _Method.values.length; i++) {
      final x = _slotX0 + i * _slotSpacing;
      for (final dx in const [-_slotHalf, _slotHalf]) {
        for (final dz in const [-_slotHalf, _slotHalf]) {
          point(_V(x + dx, 0, _slotZ + dz));
        }
      }
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `loadScenario(num)`: clears the zones, the cards, the menu and
  /// the props' animations.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _hintTimer = null;
    setState(() {
      _scene.load(index);
      _step = 1;
      _hintShown = false;
      _flashOption = null;
      _cardRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Scenarios 1 and 2: placing the cards, then VERIFY. Scenario 3: the
  /// five props, one per step.
  int _deriveStep() {
    final s = _scene;
    if (s.scenario != _investigation) {
      final b = s.board;
      if (b.solved) return 3;
      return b.complete ? 2 : 1;
    }
    return s.s3Done ? _stepCounts[_investigation] + 1 : s.s3Step;
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
  }

  /// The current scenario is finished.
  bool get _done => _step > _stepCounts[_scene.scenario];

  /// The HTML "Current Task" line (and, added, what to do once the cards
  /// are placed or the scenario is done).
  String _hud() {
    final s = _scene;
    if (_done) {
      final all = _lab.completedScenarios.length >= _stepCounts.length;
      return _lab.t(all ? 'msg_all_complete' : 'msg_scenario_complete');
    }
    return switch (s.scenario) {
      0 => _t(_step == 2 ? 'hud_s1_verify' : 'hud_s1'),
      1 => _t(_step == 2 ? 'hud_s2_verify' : 'hud_s2'),
      _ => labFormat(_t('s3_hud_step'), {'step': s.s3Step}),
    };
  }

  // ------------------------------------------------- scenarios 1 and 2

  /// HTML `handleDragStart` (`playSound('click')`).
  void _onDragStarted() => _Sound.click.play();

  /// A zone takes a card of this scenario until VERIFY has passed.
  bool _canDrop(_Card card) {
    final b = _scene.board;
    return _lab.isLabActive &&
        !b.solved &&
        _Card.of(_scene.scenario).contains(card);
  }

  /// HTML `handleDragEnd` over a zone (`playSound('drop')`).
  void _dropCard(_Card card, int zone) {
    final b = _scene.board;
    if (b.solved) return;
    b.place(card, zone);
    _Sound.drop.play();
    _refresh();
  }

  /// HTML `handleDragEnd` elsewhere: back to the cards.
  void _returnCard(_Card card) {
    if (!_Card.of(_scene.scenario).contains(card)) return;
    _scene.board.unplace(card);
    _refresh();
  }

  /// HTML `showHint(slotId)`: the hint shows for 4 s, then fades.
  void _showHint(int zone) {
    _Sound.click.play();
    _hintTimer?.cancel();
    setState(() {
      _hintZone = zone;
      _hintShown = true;
    });
    _hintTimer = _lab.after(const Duration(seconds: 4), () {
      if (mounted) setState(() => _hintShown = false);
    });
  }

  /// HTML `verifyScenario()`.
  void _verify() {
    final s = _scene;
    final b = s.board;
    if (b.solved || !_lab.isLabActive) return;
    if (!b.complete) {
      _lab.showToast(_t('err_empty'), isError: true, sound: false);
      return;
    }
    if (b.correct) {
      b.solved = true;
      _celebrate();
      return;
    }
    _lab.showToast(
      _t(s.scenario == 0 ? 'fb_s1_bad' : 'fb_s2_bad'),
      isError: true,
    );
  }

  // ---------------------------------------------------------- scenario 3

  /// HTML `s3PointerDownHandler`: the raycast picks a prop.
  void _onSceneTap(TapUpDetails d) {
    final s = _scene;
    if (s.scenario != _investigation || !_lab.isLabActive) return;
    final prop = s.propAt(d.localPosition, _touch);
    if (prop != null) _tapProp(prop);
  }

  /// The name of a prop's sidebar item without its number.
  String _itemName(_Prop p) =>
      _t(p.method.itemKey).replaceFirst(RegExp(r'^\d+\.\s*'), '');

  /// HTML `s3PointerDownHandler` branches: the step's prop plays its part.
  /// The HTML ignored other props; here a hint names the right one. Taps
  /// wait while a prop is moving or a menu is open.
  void _tapProp(_Prop prop) {
    final s = _scene;
    if (s.scenario != _investigation || !_lab.isLabActive) return;
    if (s.s3Done || s.busy || s.menu != null) return;
    if (prop != s.wantedProp) {
      _lab.showToast(
        labFormat(_t('wrong_prop'), {
          'step': s.s3Step,
          'prop': _itemName(s.wantedProp),
        }),
        isError: true,
      );
      return;
    }
    _Sound.click.play();
    final t = s.time;
    switch (prop) {
      case _Prop.magnifier:
        // Glides forward (800 ms), "My pen is not writing.", 2 s later back
        // (500 ms) and step 2.
        s
          ..busy = true
          ..glideMagnifier(_magForward, _magOutSeconds, easeOut: true);
        s.cue(t + _magOutSeconds, () {
          _lab.showToast(_t('pen_o'), sound: false);
        });
        s.cue(t + _magOutSeconds + _magHoldSeconds, () {
          s
            ..glideMagnifier(_magHome, _magBackSeconds, easeOut: false)
            ..s3Step = 2
            ..busy = false;
          _refresh();
        });
      case _Prop.sign:
        s.menu = _Menu.question;
      case _Prop.bulb:
        s.menu = _Menu.guess;
      case _Prop.pen:
        // The cap lifts and spins off (500 ms), then "I open the pen and
        // check the refill." and step 5.
        s
          ..busy = true
          ..capAt = t;
        s.cue(t + _capSeconds, () {
          _lab.showToast(_t('pen_t'), sound: false);
          s
            ..s3Step = 5
            ..busy = false;
          _refresh();
        });
      case _Prop.notepad:
        s.menu = _Menu.analysis;
    }
    _refresh();
  }

  /// HTML `showS3Menu` option buttons.
  void _choose(_Menu menu, int option) {
    final s = _scene;
    if (s.menu != menu || !_lab.isLabActive) return;
    if (option != menu.answer) {
      // HTML: the error tone and the option flashes red for 500 ms; the
      // hint toast is added.
      setState(() => _flashOption = option);
      _lab.after(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _flashOption = null);
      });
      _lab.showToast(_t('menu_wrong'), isError: true);
      return;
    }
    _Sound.drop.play();
    final t = s.time;
    _flashOption = null;
    s.menu = null;
    switch (menu) {
      case _Menu.question:
        // The sign pulses (scale 1.5, yoyo).
        s
          ..signPulseAt = t
          ..s3Step = 3;
      case _Menu.guess:
        // The bulb's light comes on.
        s
          ..bulbOn = true
          ..s3Step = 4;
      case _Menu.analysis:
        // The pencil scribbles (four 200 ms legs), then the success popup.
        s
          ..busy = true
          ..pencilAt = t;
        s.cue(t + _pencilLeg * _pencilLegs, () {
          s
            ..busy = false
            ..s3Done = true;
          _celebrate();
        });
    }
    _refresh();
  }

  // ------------------------------------------------------------ popups

  /// HTML `celebrate(msgKey)`: confetti and the success modal.
  void _celebrate() {
    final s = _scene;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    s.fireConfetti(_Burst.celebrate);
    _refresh();
    _lab.showPopup(() => _successPopup(sc));
  }

  /// HTML `#success-modal`: 'Mastery Achieved!' with the scenario's
  /// message. The HTML shows scenario 1's message for the solved pen
  /// mystery too.
  LabPopupContent _successPopup(int sc) {
    final last = sc == _investigation;
    return LabPopupContent(
      title: _t('p_done'),
      icon: Icons.check_circle,
      accent: _Colors.blue500,
      extra: Builder(
        builder: (context) => _MasteryCard(
          title: _t('mastery_achieved'),
          message: _t(sc == 1 ? 'fb_s2_ok' : 'fb_s1_ok'),
          palette: _lab.palette,
          scale: context.labScale,
        ),
      ),
      actions: [
        if (last)
          LabAction(
            label: _t('btn_view_final'),
            icon: Icons.arrow_forward,
            color: _Colors.blue600,
            foreground: _Colors.white,
            onTap: _showFinal,
          )
        else
          LabAction(
            label: _t('btn_close_cont'),
            icon: Icons.arrow_forward,
            color: _Colors.blue600,
            foreground: _Colors.white,
            onTap: _closeSuccess,
          ),
      ],
    );
  }

  /// HTML `closeSuccess()`; the shell's "select the next scenario" toast is
  /// added.
  void _closeSuccess() {
    _lab.hidePopup(sound: false);
    final all = _lab.completedScenarios.length >= _stepCounts.length;
    _lab.showToast(
      _lab.t(all ? 'msg_all_complete' : 'msg_scenario_complete'),
      sound: false,
    );
  }

  /// HTML `showFinal()`: the final conclusion with its confetti.
  void _showFinal() {
    _lab.hidePopup(sound: false);
    _scene.fireConfetti(_Burst.finale);
    _lab.showPopup(_finalPopup, silent: true);
    _refresh();
  }

  /// HTML `#final-modal`: the summary, the four score tiles and 'Finish /
  /// Restart Lab' (HTML `hardResetApp()`).
  LabPopupContent _finalPopup() {
    return LabPopupContent(
      title: _t('p_done'),
      icon: Icons.star,
      accent: _Colors.orange500,
      extra: Builder(
        builder: (context) => _FinalResults(
          summary: _t('p_summary2'),
          stats: [
            (_t('stat_concept'), _Colors.blue400),
            (_t('stat_observe'), _Colors.orange400),
            (_t('stat_reason'), _Colors.emerald400),
            (_t('stat_model'), _Colors.purple400),
          ],
          palette: _lab.palette,
          scale: context.labScale,
        ),
      ),
      actions: [
        LabAction(
          label: _t('restart_lab'),
          icon: Icons.check_circle,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          onTap: _lab.requestFullReset,
        ),
      ],
    );
  }

  /// Once the mystery is solved, 'View Final Results' stays reachable
  /// after the success popup is closed (added).
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == _investigation && s.s3Done) {
      return [
        LabAction(
          label: _t('btn_view_final'),
          icon: Icons.emoji_events,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: _lab.popup == null,
          silent: true,
          onTap: () {
            _Sound.click.play();
            _showFinal();
          },
        ),
      ];
    }
    return const [];
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
        final actions = _actions();
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title'), _t('sc3_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _hud(),
          actions: actions,
          // HTML `enterLab()` and `hardResetApp()` start at scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('task_instr'),
          sidebarExtra: _Instructions(
            scenario: sc,
            s3Step: _scene.s3Step,
            s3Done: _scene.s3Done,
            palette: p,
            scale: s,
            fontScale: f,
            t: _t,
          ),
          overlays: _overlays(context, p, s, actions),
          stage: _stage(),
        );
      },
    );
  }

  /// The canvas layers: the drop zones, cards and VERIFY of scenarios 1
  /// and 2 (HTML `#interactive-ui-layer`, `#action-btn-container`), their
  /// hint card, scenario 3's "Select Action" menu, 'View Final Results'
  /// above the HUD once the mystery is solved, and the confetti.
  List<Widget> _overlays(
    BuildContext context,
    LabPalette p,
    double s,
    List<LabAction> actions,
  ) {
    final sc = _scene;
    final active = _lab.isLabActive;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final bottom = (_lab.isSidebarOpen ? _hudBand * s + 8 : 8.0) + pad.bottom;
    final area = EdgeInsets.fromLTRB(
      inset.left,
      inset.top,
      inset.right,
      bottom,
    );
    final menu = sc.menu;
    final cards = sc.scenario != _investigation;
    return [
      // Measures the canvas area for the framing.
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      if (active && cards)
        Positioned.fill(
          child: Padding(padding: area, child: _board(p, s)),
        ),
      if (active && cards && _hintZone > 0)
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: area,
              child: Align(
                // HTML `top-[40%]`.
                alignment: const Alignment(0, -0.2),
                child: AnimatedOpacity(
                  opacity: _hintShown ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: _HintCard(
                    title: _t('hint_title'),
                    text: _t(_Method.values[_hintZone - 1].hintKey),
                    scale: s,
                  ),
                ),
              ),
            ),
          ),
        ),
      if (active && menu != null)
        Positioned.fill(
          child: Padding(
            padding: area,
            child: Center(
              child: _ChoiceMenu(
                key: ValueKey('ch1a4-menu-${menu.name}'),
                title: _t('s3_menu_title'),
                options: [for (final o in menu.options) _t(o)],
                flash: _flashOption,
                onChoose: (i) => _choose(menu, i),
                palette: p,
                scale: s,
              ),
            ),
          ),
        ),
      if (active &&
          sc.s3Done &&
          _lab.popup == null &&
          _lab.isSidebarOpen &&
          actions.isNotEmpty)
        Positioned(
          key: const ValueKey('ch1a4-final'),
          left: inset.left,
          right: inset.right,
          bottom: inset.bottom + _hudBand * s,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LabActionButton(
                action: actions.first,
                scale: s,
                expand: false,
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

  /// HTML `#slots-container` (the five drop zones near the top), the cards
  /// (HTML `#cards-container`, above VERIFY) and VERIFY.
  Widget _board(LabPalette p, double s) {
    final b = _scene.board;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        if (w < 60 || h < 60) return const SizedBox.shrink();
        final gap = (w * 0.025).clamp(6.0, 24.0 * s);
        final zone = math.min(math.min((w - 4 * gap) / 5, 120 * s), h * 0.34);
        // Scenario 2 stacks several chips per zone: taller zones where the
        // canvas has room (the HTML zones are square).
        final zoneHeight = b.single
            ? zone
            : math.max(zone, math.min(zone * 1.3, h * 0.4));
        return Column(
          children: [
            SizedBox(height: math.min(h * 0.06, 32 * s)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < b.zones.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  _zone(i, zone, zoneHeight, w, p, s),
                ],
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _tray(w, p, s),
              ),
            ),
            if (!b.solved) ...[
              SizedBox(height: 10 * s),
              // Scales down while the sidebar slides (the board is briefly
              // narrow).
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _VerifyButton(
                  label: _t('btn_verify'),
                  scale: s,
                  onTap: _verify,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Width of a card in the tray (scenario 1: `w-28`, five in a row while
  /// they fit; scenario 2: up to `max-w-[150px]`, at least three per
  /// row).
  double _trayCardWidth(double boardWidth, double s) {
    final gap = 6 * s;
    final five = (boardWidth - 4 * gap) / 5;
    final three = (boardWidth - 2 * gap) / 3;
    return _scene.board.single
        ? math.min(112 * s, five >= 72 ? five : three)
        : math.min(150 * s, three);
  }

  /// One drop zone (HTML `.dropzone-box`): its faint number, its cards and
  /// the '?' hint.
  Widget _zone(
    int i,
    double size,
    double height,
    double boardWidth,
    LabPalette p,
    double s,
  ) {
    final b = _scene.board;
    final cards = b.zones[i];
    final n = i + 1;
    final trayWidth = _trayCardWidth(boardWidth, s);
    return Semantics(
      container: true,
      label: labFormat(_t('slot_lbl'), {'n': n}),
      child: DragTarget<_Card>(
        onWillAcceptWithDetails: (d) => _canDrop(d.data),
        onAcceptWithDetails: (d) => _dropCard(d.data, i),
        builder: (context, candidates, _) {
          final hot = candidates.isNotEmpty;
          final inner = size - 8;
          Widget content;
          if (cards.isEmpty) {
            content = const SizedBox.shrink();
          } else if (b.single) {
            content = Padding(
              padding: const EdgeInsets.all(3),
              child: _cardDraggable(
                cards.first,
                p,
                s,
                width: size - 6,
                height: height - 6,
                trayWidth: trayWidth,
                inZone: true,
              ),
            );
          } else {
            content = Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
              // HTML `flex-col items-center justify-center`.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in cards)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _cardDraggable(
                          c,
                          p,
                          s,
                          width: inner,
                          trayWidth: trayWidth,
                          inZone: true,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          return _ZoneBox(
            width: size,
            height: height,
            number: n,
            hot: hot,
            filled: cards.isNotEmpty,
            solved: b.solved,
            dark: p.isDark,
            scale: s,
            hintLabel: labFormat(_t('hint_btn'), {'n': n}),
            onHint: () => _showHint(n),
            child: content,
          );
        },
      ),
    );
  }

  /// HTML `#cards-container`: the cards still to place. On a short canvas
  /// the cards shrink to fit instead of scrolling (a scroll would take the
  /// upward drags meant for the cards).
  Widget _tray(double boardWidth, LabPalette p, double s) {
    final b = _scene.board;
    if (b.tray.isEmpty) return const SizedBox.shrink();
    final width = _trayCardWidth(boardWidth, s);
    return Semantics(
      container: true,
      label: _t('cards_lbl'),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: boardWidth,
          padding: EdgeInsets.symmetric(vertical: 4 * s),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6 * s,
            runSpacing: 6 * s,
            children: [
              for (final c in b.tray)
                _cardDraggable(
                  c,
                  p,
                  s,
                  width: width,
                  height: b.single ? 48 * s : null,
                  trayWidth: width,
                  inZone: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// One card (HTML `.draggable-card`): dragged by the finger, centred on
  /// it, into a zone or back to the cards.
  Widget _cardDraggable(
    _Card card,
    LabPalette p,
    double s, {
    required double width,
    required double trayWidth,
    required bool inZone,
    double? height,
  }) {
    final text = _t(card.key);
    final enabled = _lab.isLabActive && !_scene.board.solved;
    Widget tile({
      required double w,
      double? h,
      bool small = false,
      bool lifted = false,
      bool ghost = false,
    }) => _CardTile(
      text: text,
      step: card.isStep,
      width: w,
      height: h,
      small: small,
      lifted: lifted,
      ghost: ghost,
      solved: _scene.board.solved,
      dark: p.isDark,
      scale: s,
    );
    final small = inZone && !card.isStep;
    return Draggable<_Card>(
      data: card,
      maxSimultaneousDrags: enabled ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: _onDragStarted,
      onDraggableCanceled: (_, _) => _returnCard(card),
      // Centred on the finger, at its size in the tray.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: tile(
            w: trayWidth,
            h: card.isStep ? 48 * s : null,
            lifted: true,
          ),
        ),
      ),
      childWhenDragging: tile(w: width, h: height, small: small, ghost: true),
      child: Semantics(
        container: true,
        label: text,
        excludeSemantics: true,
        child: KeyedSubtree(
          key: ValueKey('ch1a4-card-${card.name}'),
          child: tile(w: width, h: height, small: small),
        ),
      ),
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Taps on the desk are not screen-reader actions; the props
            // have their own nodes ([_targets]).
            excludeFromSemantics: true,
            onTapUp: _onSceneTap,
            child: Stack(
              children: [
                Semantics(
                  image: true,
                  label: _t('scene_desc'),
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
                Positioned.fill(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, _, _) => _targets(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Screen-reader buttons over the props of scenario 3, where they are
  /// drawn. They follow the props every frame and take no touches
  /// themselves (taps reach the desk below).
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive ||
        s.scenario != _investigation ||
        s.s3Done ||
        s.busy ||
        s.menu != null) {
      return const SizedBox.shrink();
    }
    final cam = s.camera();
    return Stack(
      children: [
        for (final prop in _Prop.values)
          Positioned.fromRect(
            rect: s.propRect(prop, cam),
            child: Semantics(
              key: ValueKey('ch1a4-prop-${prop.name}'),
              container: true,
              label: _t(prop.labelKey),
              button: true,
              onTap: () => _tapProp(prop),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

/// HTML `#sb-instructions`: the scenario's instructions. Scenario 1 lists
/// the five steps, scenario 2 highlights 'Question (Slot 2)' and 'Guess
/// (Slot 3)', scenario 3 lists the props to tap; there each prop ticks off
/// once done, with its step of the method and what it showed (added).
class _Instructions extends StatelessWidget {
  const _Instructions({
    required this.scenario,
    required this.s3Step,
    required this.s3Done,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.t,
  });

  final int scenario;
  final int s3Step;
  final bool s3Done;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String Function(String key) t;

  TextStyle get _body => TextStyle(
    color: palette.text,
    fontSize: 12 * fontScale,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  /// `text-blue-500 dark:text-blue-400`.
  Color get _blue =>
      palette.isDark ? _Colors.blue400 : palette.ink(_Colors.blue500);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final List<Widget> children;
    switch (scenario) {
      case 0:
        children = [
          for (var i = 1; i <= _Method.values.length; i++) ...[
            if (i > 1) SizedBox(height: 3 * s),
            Text(t('s1_desc_$i'), style: _body),
          ],
          SizedBox(height: 10 * s),
          Text(
            t('s1_desc_drag'),
            style: _body.copyWith(color: _blue, fontWeight: FontWeight.w700),
          ),
        ];
      case 1:
        children = [
          Text(t('s2_desc_intro'), style: _body),
          SizedBox(height: 10 * s),
          Text.rich(_highlighted(), style: _body),
          SizedBox(height: 10 * s),
          Text(
            t('s2_desc_drag'),
            style: _body.copyWith(color: _blue, fontWeight: FontWeight.w700),
          ),
        ];
      default:
        children = [
          Text(t('s3_desc_intro'), style: _body),
          SizedBox(height: 10 * s),
          Text(t('s3_desc_tap'), style: _body),
          SizedBox(height: 8 * s),
          for (final m in _Method.values) _propRow(m),
        ];
    }
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// HTML `s2_desc` with its `<strong>` words: 'Question (Slot 2)' in
  /// `text-orange-500 dark:text-yellow-400`, 'Guess (Slot 3)' in
  /// `text-emerald-600 dark:text-emerald-400`.
  TextSpan _highlighted() {
    final dark = palette.isDark;
    final text = t('s2_desc_read');
    final marks = <(String, Color)>[
      (t('s2_desc_q'), dark ? _Colors.yellow400 : _Colors.orange500),
      (t('s2_desc_g'), dark ? _Colors.emerald400 : _Colors.emerald600),
    ];
    final spans = <InlineSpan>[];
    var at = 0;
    while (at < text.length) {
      var next = -1;
      (String, Color)? hit;
      for (final m in marks) {
        final i = text.indexOf(m.$1, at);
        if (i >= 0 && (next < 0 || i < next)) {
          next = i;
          hit = m;
        }
      }
      if (hit == null) {
        spans.add(TextSpan(text: text.substring(at)));
        break;
      }
      if (next > at) spans.add(TextSpan(text: text.substring(at, next)));
      spans.add(
        TextSpan(
          text: hit.$1,
          style: TextStyle(
            color: palette.ink(hit.$2),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      at = next + hit.$1.length;
    }
    return TextSpan(children: spans);
  }

  /// One of scenario 3's props: ticked once done, highlighted while it is
  /// the step to do.
  Widget _propRow(_Method m) {
    final p = palette;
    final s = scale;
    final done = s3Done || m.slot < s3Step;
    final current = !s3Done && m.slot == s3Step;
    final tone = done
        ? p.success
        : (current ? p.accentInk : p.textMuted.withValues(alpha: 0.8));
    return Padding(
      padding: EdgeInsets.only(top: 6 * s),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: current ? p.accent.withValues(alpha: 0.1) : LabInk.clear,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: current
                ? p.accent.withValues(alpha: 0.6)
                : (done ? p.success.withValues(alpha: 0.4) : p.cardBorder),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20 * s,
              height: 20 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? p.success.withValues(alpha: 0.18)
                    : (current ? p.accent : LabInk.clear),
                border: Border.all(
                  color: done ? p.success : (current ? p.accent : p.cardBorder),
                ),
              ),
              child: done
                  ? Icon(Icons.check, size: 12 * s, color: p.success)
                  : Text(
                      '${m.slot}',
                      style: TextStyle(
                        color: current ? p.onAccent : p.textMuted,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            SizedBox(width: 8 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(m.itemKey),
                    style: _body.copyWith(
                      color: current || done ? p.textStrong : p.text,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  if (done) ...[
                    SizedBox(height: 2 * s),
                    Text(
                      t(m.key).toUpperCase(),
                      style: TextStyle(
                        color: tone,
                        fontSize: 9.5 * fontScale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: labLetterSpacing(t(m.key), 0.8),
                      ),
                    ),
                    Text(
                      t(m.penKey),
                      style: _body.copyWith(
                        color: p.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 11.5 * fontScale,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A drop zone (HTML `.dropzone-box`): dashed yellow while empty, glowing
/// yellow while a card is over it (`.highlight`), solid once filled
/// (`.filled`), green once VERIFY has passed (added). Its number shows
/// faintly behind the cards, its '?' (top right) shows the hint.
class _ZoneBox extends StatelessWidget {
  const _ZoneBox({
    required this.width,
    required this.height,
    required this.number,
    required this.hot,
    required this.filled,
    required this.solved,
    required this.dark,
    required this.scale,
    required this.hintLabel,
    required this.onHint,
    required this.child,
  });

  final double width;
  final double height;
  final int number;
  final bool hot;
  final bool filled;
  final bool solved;
  final bool dark;
  final double scale;
  final String hintLabel;
  final VoidCallback onHint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color edge;
    if (hot) {
      fill = _Colors.zoneHotFill;
      edge = _Colors.yellow500;
    } else if (filled) {
      fill = dark ? _Colors.zoneFilledDark : _Colors.zoneFilledLight;
      edge = solved
          ? _Colors.emerald500
          : (dark ? _Colors.zoneFilledEdgeDark : _Colors.zoneFilledEdgeLight);
    } else {
      fill = dark ? _Colors.zoneDark : _Colors.zoneLight;
      edge = _Colors.zoneDash;
    }
    final hint = math.max(16.0, 16 * scale);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DashPainter(
          color: edge,
          fill: fill,
          dashed: !hot && !filled,
          radius: 12,
          width: 2,
          glow: hot ? _Colors.zoneHotGlow : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The zone's own label already names its number.
            Center(
              child: ExcludeSemantics(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: _Colors.zoneNumber,
                    fontSize: math.min(width, height) * 0.4,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
            child,
            Positioned(
              top: 0,
              right: 0,
              child: Semantics(
                container: true,
                button: true,
                label: hintLabel,
                onTap: onHint,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onHint,
                  child: Padding(
                    padding: EdgeInsets.all(4 * scale),
                    child: Icon(
                      Icons.help,
                      size: hint,
                      color: _Colors.slate400.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card (HTML `.draggable-card`): scenario 1's step cards (`w-28 h-12`,
/// bold, blue border) and scenario 2's chips (`text-[10px]`, slate
/// border). In a zone a step card fills it and a chip shrinks
/// ([small]); lifted cards grow 5% with a shadow (HTML `:active`).
class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.text,
    required this.step,
    required this.width,
    required this.small,
    required this.lifted,
    required this.ghost,
    required this.solved,
    required this.dark,
    required this.scale,
    this.height,
  });

  final String text;
  final bool step;
  final double width;
  final double? height;
  final bool small;
  final bool lifted;
  final bool ghost;
  final bool solved;
  final bool dark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final Color bg;
    final Color edge;
    final Color ink;
    if (step) {
      bg = dark ? _Colors.cardDark : _Colors.white;
      edge = solved
          ? _Colors.emerald500
          : (dark ? _Colors.cardEdgeDark : _Colors.blue400);
      ink = dark ? _Colors.blue100 : _Colors.blue900;
    } else {
      bg = dark ? _Colors.slate800 : _Colors.white;
      edge = solved
          ? _Colors.emerald500
          : (dark ? _Colors.chipEdgeDark : _Colors.slate300);
      ink = dark ? _Colors.slate200 : _Colors.slate800;
    }
    final fontSize = step
        ? 12 * s
        : (small ? math.max(7.5, 8 * s) : math.max(9.0, 10 * s));
    final pad = small ? 2.0 : (step ? 4 * s : 7 * s);
    final style = TextStyle(
      color: ink,
      fontSize: fontSize,
      fontWeight: step ? FontWeight.w700 : FontWeight.w600,
      height: 1.2,
      fontFamily: LabFont.active.family,
      fontFamilyFallback: LabFont.active.fallback,
      decoration: TextDecoration.none,
    );
    final fixed = step || small;
    final inner = width - 2 * pad - 2;
    Widget label = Text(
      text,
      textAlign: TextAlign.center,
      maxLines: small ? 2 : 4,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (fixed) {
      // Scales down instead of overflowing a small zone.
      label = FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(width: math.max(1, inner), child: label),
      );
    }
    // Chips in the tray are as wide as their text (`w-auto`, up to
    // [width]).
    Widget card = Container(
      width: fixed ? width : null,
      height: height,
      constraints: fixed ? null : BoxConstraints(maxWidth: width),
      padding: EdgeInsets.all(pad),
      alignment: height != null ? Alignment.center : null,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(step ? 12 : (small ? 4 : 8)),
        border: Border.all(color: edge),
        boxShadow: [
          BoxShadow(
            color: lifted ? _Colors.liftShadow : LabInk.shadowSoft,
            blurRadius: lifted ? 25 : (small ? 1 : 4),
            spreadRadius: lifted ? -5 : 0,
            offset: Offset(0, lifted ? 10 : 1),
          ),
        ],
      ),
      child: label,
    );
    if (lifted) card = Transform.scale(scale: 1.05, child: card);
    if (ghost) card = Opacity(opacity: 0.3, child: card);
    return card;
  }
}

/// HTML `#btn-verify`: a blue-to-indigo gradient pill with a check.
class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_Colors.blue600, _Colors.indigo600],
            ),
            borderRadius: radius,
            border: Border.all(color: _Colors.verifyEdge, width: 2),
            boxShadow: const [
              BoxShadow(
                color: _Colors.verifyGlow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 26 * s,
                  vertical: 8 * s,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 19 * s,
                      color: _Colors.white,
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      label,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w900,
                        letterSpacing: labLetterSpacing(label, 0.5),
                      ),
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
}

/// HTML `#hint-overlay`: a dark card with the lit 'Hint' title.
class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.title,
    required this.text,
    required this.scale,
  });

  final String title;
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 384 * s),
      child: Container(
        padding: EdgeInsets.all(14 * s),
        decoration: BoxDecoration(
          color: _Colors.hintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Colors.slate600),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowStrong,
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb, size: 16 * s, color: _Colors.yellow400),
                SizedBox(width: 6 * s),
                Text(
                  title,
                  style: TextStyle(
                    color: _Colors.yellow400,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * s),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Colors.white,
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HTML `#s3-menu`: 'Select Action' and three options (`w-64`). A wrong
/// option flashes red.
class _ChoiceMenu extends StatelessWidget {
  const _ChoiceMenu({
    super.key,
    required this.title,
    required this.options,
    required this.flash,
    required this.onChoose,
    required this.palette,
    required this.scale,
  });

  final String title;
  final List<String> options;
  final int? flash;
  final ValueChanged<int> onChoose;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final dark = p.isDark;
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(256 * s, box.maxWidth);
        return Material(
          type: MaterialType.transparency,
          child: Container(
            width: width,
            constraints: BoxConstraints(maxHeight: box.maxHeight),
            padding: EdgeInsets.all(14 * s),
            decoration: BoxDecoration(
              color: dark ? _Colors.slate900 : _Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dark ? _Colors.slate600 : _Colors.slate300,
              ),
              boxShadow: const [
                BoxShadow(
                  color: LabInk.shadowStrong,
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 4 * s),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: dark ? _Colors.slate700 : _Colors.slate200,
                        ),
                      ),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark ? _Colors.blue400 : _Colors.blue600,
                        fontSize: 13.5 * s,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) SizedBox(height: 7 * s),
                    _option(i, s, dark),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _option(int i, double s, bool dark) {
    final red = flash == i;
    final radius = BorderRadius.circular(8);
    return Material(
      color: red
          ? _Colors.red600
          : (dark ? _Colors.slate800 : _Colors.slate100),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        hoverColor: dark ? _Colors.blue600 : _Colors.blue100,
        onTap: () => onChoose(i),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 7 * s),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                options[i],
                style: TextStyle(
                  color: red
                      ? _Colors.white
                      : (dark ? _Colors.white : _Colors.slate900),
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HTML `#success-modal` body: the bouncing trophy, 'Mastery Achieved!'
/// and the message.
class _MasteryCard extends StatefulWidget {
  const _MasteryCard({
    required this.title,
    required this.message,
    required this.palette,
    required this.scale,
  });

  final String title;
  final String message;
  final LabPalette palette;
  final double scale;

  @override
  State<_MasteryCard> createState() => _MasteryCardState();
}

class _MasteryCardState extends State<_MasteryCard>
    with SingleTickerProviderStateMixin {
  /// Tailwind `animate-bounce`: up 25% and down every second.
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final s = widget.scale;
    final disc = 64 * s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4 * s),
        Container(
          width: disc,
          height: disc,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _Colors.trophyBg,
            shape: BoxShape.circle,
            border: Border.all(color: _Colors.trophyEdge),
          ),
          child: AnimatedBuilder(
            animation: _bounce,
            builder: (context, child) {
              final v = _bounce.value;
              // Up on the first half (ease out), down on the second (ease
              // in), as `@keyframes bounce`.
              final up = v < 0.5
                  ? Curves.easeOut.transform(v * 2)
                  : 1 - Curves.easeIn.transform((v - 0.5) * 2);
              return Transform.translate(
                offset: Offset(0, -0.25 * 32 * s * up),
                child: child,
              );
            },
            child: Icon(
              Icons.emoji_events,
              size: 32 * s,
              color: _Colors.yellow400,
            ),
          ),
        ),
        SizedBox(height: 14 * s),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 21 * s,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13.5 * s,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// HTML `#final-modal` body: the glowing star, the summary and the four
/// score tiles (each "10").
class _FinalResults extends StatelessWidget {
  const _FinalResults({
    required this.summary,
    required this.stats,
    required this.palette,
    required this.scale,
  });

  final String summary;
  final List<(String, Color)> stats;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final disc = 72 * s;
    Widget tile((String, Color) stat) {
      final (label, color) = stat;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: p.isDark ? _Colors.statBg : _Colors.slate100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.isDark ? _Colors.slate700 : _Colors.slate300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '10',
              style: TextStyle(
                color: p.ink(color),
                fontSize: 24 * s,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 9 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: labLetterSpacing(label, 0.8),
                height: 1.25,
              ),
            ),
          ],
        ),
      );
    }

    Widget row(int a) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tile(stats[a])),
          SizedBox(width: 10 * s),
          Expanded(child: tile(stats[a + 1])),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: disc,
          height: disc,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_Colors.yellow400, _Colors.orange500],
            ),
            border: Border.all(color: _Colors.verifyEdge, width: 4),
            boxShadow: const [
              BoxShadow(color: _Colors.starGlow, blurRadius: 50),
            ],
          ),
          child: Icon(Icons.star, size: 36 * s, color: _Colors.white),
        ),
        SizedBox(height: 14 * s),
        Text(
          summary,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13.5 * s,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
        SizedBox(height: 14 * s),
        row(0),
        SizedBox(height: 10 * s),
        row(2),
      ],
    );
  }
}

/// A rounded box with a solid or dashed border (HTML `border-dashed`) and
/// an optional glow.
class _DashPainter extends CustomPainter {
  const _DashPainter({
    required this.color,
    required this.dashed,
    required this.radius,
    this.fill,
    this.width = 1.5,
    this.glow,
  });

  final Color color;
  final Color? fill;
  final bool dashed;
  final double radius;
  final double width;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    final g = glow;
    if (g != null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = g
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15),
      );
    }
    final f = fill;
    if (f != null) canvas.drawRRect(rr, Paint()..color = f);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    if (!dashed) {
      canvas.drawRRect(rr, stroke);
      return;
    }
    final path = Path()..addRRect(rr);
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 6, metric.length)),
          stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.dashed != dashed ||
      old.radius != radius ||
      old.width != width ||
      old.glow != glow;
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Mesh triangles coloured per vertex (the desk top).
  final Paint vertices = Paint();
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  /// Additive light (the bulb's glow).
  final Paint glow = Paint()..blendMode = BlendMode.plus;
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the label and glyph text
/// painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _glyphs = {};
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
    final a = label(text);
    return Size(
      a.width + 2 * _chipPadX * _labelSize,
      a.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// A glyph of the HTML sprite canvases (64 px canvases: the slot numbers
  /// in `bold 40px Arial`, the sign's '?' in `bold 50px Arial`).
  TextPainter glyph(String text, double size, Color color) {
    final font = LabFont.active;
    return _glyphs['$text|$size|${color.toARGB32()}|${font.family}'] ??=
        TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w800,
              height: 1,
              fontFamily: font.family,
              fontFamilyFallback: font.fallback,
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
    for (final tp in _glyphs.values) {
      tp.dispose();
    }
    _glyphs.clear();
  }
}

/// The spotlight's cone (Three.js `spotEffect`): full inside half its
/// angle (penumbra 0.5), fading to nothing at π/4.
double _spotCone(_V at) {
  final axis = (_lookAt - _spotPos).unit;
  final cosA = (at - _spotPos).unit.dot(axis);
  final lo = math.cos(_spotOuter);
  final hi = math.cos(_spotInner);
  final t = ((cosA - lo) / (hi - lo)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

/// MeshStandardMaterial look under the HTML lights for a surface at [at]
/// with normal [n]: ambient, the warm spotlight (Lambert term inside its
/// cone), the cool fill light and, once lit, the bulb's orange point light
/// (linear fall-off to 5 units).
Color _lit(Color c, _V n, _V at, {bool bulbOn = false}) {
  final toSpot = (_spotPos - at).unit;
  final spot = _spotPower * _spotCone(at) * math.max(0.0, n.dot(toSpot));
  final fill = _fillPower * math.max(0.0, n.dot(_fillDir));
  const warm = _Colors.spotTint;
  const cool = _Colors.fillTint;
  var r = _ambient + spot * warm.r + fill * cool.r;
  var g = _ambient + spot * warm.g + fill * cool.g;
  var b = _ambient + spot * warm.b + fill * cool.b;
  if (bulbOn) {
    final d = _bulbPos - at;
    final dist = d.length;
    final fade = dist <= 0 ? 0.0 : math.max(0.0, 1 - dist / _bulbReach);
    if (fade > 0) {
      final k = _bulbPower * fade * math.max(0.0, n.dot(d * (1 / dist)));
      const orange = _Colors.bulbLight;
      r += k * orange.r;
      g += k * orange.g;
      b += k * orange.b;
    }
  }
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * r),
    green: math.min(1.0, c.g * g),
    blue: math.min(1.0, c.b * b),
  );
}

/// Convex hull of [points] (monotone chain), counter-clockwise.
List<Offset> _hull(List<Offset> points) {
  if (points.length < 3) return points;
  final pts = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in pts) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in pts.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Mesh drawing in one camera's projection, under the HTML lights.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache, {required this.bulbOn});

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  /// The bulb's point light is on.
  final bool bulbOn;

  _Pens get pens => cache.pens;

  Offset p(_V w) => cam.p(w);

  Color lit(Color c, _V n, _V at) => _lit(c, n, at, bulbOn: bulbOn);

  /// A closed polygon through [pts] (screen points).
  Path _poly(List<Offset> pts) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      if (i == 0) {
        path.moveTo(pts[i].dx, pts[i].dy);
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    return path..close();
  }

  /// Flat quad (already lit [color]).
  void quad(_V a, _V b, _V c, _V d, Color color) {
    canvas.drawPath(_poly([p(a), p(b), p(c), p(d)]), pens.fill..color = color);
  }

  /// BoxGeometry with half sizes [hx], [hy], [hz] along the axes of [g]
  /// (centred on its origin): the faces turned to the camera, lit.
  void box(
    _Frame3 g,
    double hx,
    double hy,
    double hz,
    Color color, {
    double edge = 0.25,
  }) {
    final axes = [g.x * hx, g.y * hy, g.z * hz];
    for (var k = 0; k < 3; k++) {
      for (final side in const [1.0, -1.0]) {
        final a = axes[k] * side;
        final u = axes[(k + 1) % 3];
        final v = axes[(k + 2) % 3];
        final mid = g.o + a;
        final n = a.unit;
        if (n.dot(cam.eye - mid) <= 0) continue;
        final path = _poly([
          p(mid - u - v),
          p(mid + u - v),
          p(mid + u + v),
          p(mid - u + v),
        ]);
        canvas.drawPath(path, pens.fill..color = lit(color, n, mid));
        if (edge > 0) {
          canvas.drawPath(
            path,
            pens.stroke
              ..strokeWidth = 0.8
              ..color = labShade(color, -0.55).withValues(alpha: edge),
          );
        }
      }
    }
  }

  /// Points of a circle of radius [r] about the axis [d] (unit) at [c].
  List<_V> _ring(_V c, _V d, double r, int n) {
    final helper = d.y.abs() < 0.9 ? _V.up : const _V(1, 0, 0);
    final u1 = d.cross(helper).unit;
    final u2 = d.cross(u1);
    return [
      for (var i = 0; i < n; i++)
        c +
            (u1 * math.cos(2 * math.pi * i / n) +
                    u2 * math.sin(2 * math.pi * i / n)) *
                r,
    ];
  }

  /// CylinderGeometry from [a] (radius [ra]) to [b] (radius [rb]): its
  /// outline shaded across like a lit cylinder (with a [shine] streak for
  /// metal or plastic) and the end turned to the camera.
  void cylinder(
    _V a,
    _V b,
    double ra,
    double rb,
    Color color, {
    double shine = 0,
    Color? endColor,
  }) {
    final axis = b - a;
    if (axis.length < 1e-6) return;
    final d = axis.unit;
    const n = 18;
    final ringA = _ring(a, d, ra, n);
    final ringB = _ring(b, d, rb, n);
    final outline = _hull([
      for (final w in ringA) p(w),
      for (final w in ringB) p(w),
    ]);
    if (outline.length < 3) return;
    // Silhouette normals (±side) and the normal facing the camera.
    final mid = _V.lerp(a, b, 0.5);
    final view = (cam.eye - mid).unit;
    var side = d.cross(view);
    if (side.length < 1e-6) side = d.cross(const _V(1, 0, 0));
    side = side.unit;
    var front = view - d * view.dot(d);
    front = front.length < 1e-6 ? side.cross(d) : front.unit;
    final r = (ra + rb) / 2;
    final left = p(mid - side * r);
    final right = p(mid + side * r);
    final colors = [
      for (final k in const [-1.0, -0.6, 0.0, 0.6, 1.0])
        lit(
          color,
          (front * (1 - k.abs()) + side * k).unit,
          mid + (front * (1 - k.abs()) + side * k).unit * r,
        ),
    ];
    final shader = ui.Gradient.linear(left, right, colors, const [
      0,
      0.2,
      0.5,
      0.8,
      1,
    ]);
    canvas.drawPath(_poly(outline), pens.fill..shader = shader);
    pens.fill.shader = null;
    if (shine > 0 && (right - left).distance > 1.5) {
      // Specular streak where the spotlight reflects towards the camera.
      final h = ((_spotPos - mid).unit + view).unit;
      final k = h.dot(side).clamp(-0.85, 0.85);
      final s0 = Offset.lerp(left, right, (k + 1) / 2)!;
      final dir = p(b) - p(a);
      final len = dir.distance;
      if (len > 1) {
        final unitDir = dir / len;
        canvas.drawLine(
          s0 - unitDir * (len * 0.42),
          s0 + unitDir * (len * 0.42),
          pens.stroke
            ..strokeWidth = math.max(0.8, (right - left).distance * 0.12)
            ..color = LabInk.white.withValues(alpha: shine),
        );
      }
    }
    // The end turned to the camera.
    final topB = d.dot(cam.eye - b) > 0;
    final end = topB ? ringB : ringA;
    final endAt = topB ? b : a;
    final endN = topB ? d : d * -1;
    canvas.drawPath(
      _poly([for (final w in end) p(w)]),
      pens.fill..color = lit(endColor ?? color, endN, endAt),
    );
  }

  /// A soft contact shadow of half sizes [rx] x [rz] world units around
  /// the desk point under [w] (cast by the spotlight).
  void shadow(_V w, double rx, double rz, {double strength = 1}) {
    final c = _shadowOf(w);
    final pc = p(c);
    final hx = (p(c + _V(rx, 0, 0)) - pc).distance;
    final hz = (p(c + _V(0, 0, rz)).dy - p(c - _V(0, 0, rz)).dy).abs() / 2;
    if (hx < 0.5) return;
    canvas.drawOval(
      Rect.fromCenter(center: pc, width: 2 * hx, height: 2 * math.max(1, hz)),
      pens.shadow..color = _Colors.shadow.withValues(alpha: 0.45 * strength),
    );
  }

  /// Draws [paint] (in a [units] x [units] canvas, like the HTML sprite
  /// canvases) onto the plane whose corners are [tl], [tr] and [bl].
  void onPlane(
    _V tl,
    _V tr,
    _V bl,
    double units,
    void Function(Canvas canvas) paint,
  ) {
    final o = p(tl);
    final x = (p(tr) - o) / units;
    final y = (p(bl) - o) / units;
    canvas.save();
    canvas.transform(
      Matrix4(
        x.dx,
        x.dy,
        0,
        0,
        y.dx,
        y.dy,
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
      ).storage,
    );
    paint(canvas);
    canvas.restore();
  }
}

/// Paints the HTML Three.js mystery desk (every scenario shows it): the
/// spot-lit wooden desk, the five number slots, the five props and their
/// text sprites.
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
    final g = _Gfx(canvas, s.camera(), cache, bulbOn: s.bulbOn);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    _paintDesk(g);
    _paintSlots(g);
    _paintShadows(g);
    // The props stand in a row at z = -1; the gliding magnifying glass
    // comes in front of them.
    final forward = s.magnifierForward;
    if (!forward) _paintMagnifier(g);
    _paintSign(g);
    _paintBulb(g);
    _paintPen(g);
    _paintNotepad(g);
    if (forward) _paintMagnifier(g);
    if (showLabels) _paintLabels(g);
  }

  // ------------------------------------------------------------------ desk

  /// `BoxGeometry(24, 0.5, 12)`, roughness 0.8: the top lit per vertex
  /// (the spotlight's pool and, once on, the bulb's orange light) and the
  /// front edge.
  void _paintDesk(_Gfx g) {
    const cols = 24, rows = 12;
    final positions = <Offset>[];
    final colors = <Color>[];
    for (var j = 0; j <= rows; j++) {
      for (var i = 0; i <= cols; i++) {
        final w = _V(
          -_deskHalfX + 2 * _deskHalfX * i / cols,
          0,
          -_deskHalfZ + 2 * _deskHalfZ * j / rows,
        );
        positions.add(g.p(w));
        colors.add(g.lit(_Colors.desk, _V.up, w));
      }
    }
    final indices = <int>[];
    for (var j = 0; j < rows; j++) {
      for (var i = 0; i < cols; i++) {
        final a = j * (cols + 1) + i;
        final b = a + 1;
        final c = a + cols + 1;
        final d = c + 1;
        indices.addAll([a, b, c, b, d, c]);
      }
    }
    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );
    g.canvas.drawVertices(vertices, BlendMode.dst, _pens.vertices);
    vertices.dispose();
    const front = _V(0, 0, 1);
    g.quad(
      const _V(-_deskHalfX, 0, _deskHalfZ),
      const _V(_deskHalfX, 0, _deskHalfZ),
      const _V(_deskHalfX, -_deskThick, _deskHalfZ),
      const _V(-_deskHalfX, -_deskThick, _deskHalfZ),
      g.lit(_Colors.desk, front, const _V(0, -0.25, _deskHalfZ)),
    );
  }

  /// The five `0x1e293b` slots with their numbers lying on the desk.
  void _paintSlots(_Gfx g) {
    for (var i = 0; i < _Method.values.length; i++) {
      final x = _slotX0 + i * _slotSpacing;
      g.box(
        _Frame3.tiltX(_V(x, _slotTop / 2, _slotZ), 0),
        _slotHalf,
        _slotTop / 2,
        _slotHalf,
        _Colors.slot,
        edge: 0.4,
      );
      const h = _slotNumberHalf;
      const y = _slotTop + 0.001;
      g.onPlane(
        _V(x - h, y, _slotZ - h),
        _V(x + h, y, _slotZ - h),
        _V(x - h, y, _slotZ + h),
        64,
        (canvas) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, 64, 64),
            _pens.fill..color = _Colors.slot,
          );
          final tp = cache.glyph('${i + 1}', 40, _Colors.slotNumber);
          tp.paint(canvas, Offset(32 - tp.width / 2, 36 - tp.height / 2));
        },
      );
    }
  }

  /// The props' soft shadows (the HTML spotlight casts them).
  void _paintShadows(_Gfx g) {
    final s = scene;
    final m = s.magnifier;
    g.shadow(m.o, 0.85, 0.5, strength: 1.1 - m.o.y * 0.3);
    final k = s.signScale;
    g.shadow(_signPos, 0.8 * k, 0.3 * k);
    g.shadow(_bulbPos, 0.7, 0.55);
    g.shadow(s.penStation.at(0, _standBottom, 0), 0.85, 0.7);
    g.shadow(_padPos + const _V(0, 0.4, 0), 0.9, 1.15, strength: 0.8);
  }

  // ----------------------------------------------------------------- props

  /// Magnifying glass: the brown handle (down to the desk top), the clear
  /// lens and the dark metal ring.
  void _paintMagnifier(_Gfx g) {
    final m = scene.magnifier;
    final c = g.canvas;
    final end = _handleClip(m);
    if (end < _handleTop) {
      g.cylinder(
        m.at(0, _handleTop, 0),
        m.at(0, end, 0),
        _handleR,
        _handleR,
        _Colors.handle,
        shine: 0.18,
      );
    }
    const n = 40;
    final lens = [
      for (var i = 0; i < n; i++)
        g.p(
          m.at(
            _lensR * math.cos(2 * math.pi * i / n),
            _lensR * math.sin(2 * math.pi * i / n),
            0,
          ),
        ),
    ];
    final lensPath = g._poly(lens);
    c.drawPath(lensPath, _pens.fill..color = _Colors.lens);
    // A glint on the glass.
    final glint = Path();
    for (var i = 0; i <= 10; i++) {
      final a = math.pi * (0.55 + 0.35 * i / 10);
      final q = g.p(m.at(0.55 * math.cos(a), 0.55 * math.sin(a), 0));
      if (i == 0) {
        glint.moveTo(q.dx, q.dy);
      } else {
        glint.lineTo(q.dx, q.dy);
      }
    }
    final k = g.cam.scaleAt(m.o);
    c.drawPath(
      glint,
      _pens.stroke
        ..strokeWidth = math.max(1, 0.07 * k)
        ..color = _Colors.lensGlint,
    );
    final ring = Path();
    for (var i = 0; i <= n; i++) {
      final q = g.p(
        m.at(
          _ringR * math.cos(2 * math.pi * i / n),
          _ringR * math.sin(2 * math.pi * i / n),
          0,
        ),
      );
      if (i == 0) {
        ring.moveTo(q.dx, q.dy);
      } else {
        ring.lineTo(q.dx, q.dy);
      }
    }
    c.drawPath(
      ring,
      _pens.stroke
        ..strokeWidth = math.max(1.5, 2 * _ringTube * k)
        ..color = g.lit(labShade(_Colors.ring, 0.08), m.z.unit, m.o),
    );
    // The metal's sheen on the upper right of the ring.
    final sheen = Path();
    for (var i = 0; i <= 12; i++) {
      final a = math.pi * (0.05 + 0.4 * i / 12);
      final q = g.p(m.at(_ringR * math.cos(a), _ringR * math.sin(a), 0));
      if (i == 0) {
        sheen.moveTo(q.dx, q.dy);
      } else {
        sheen.lineTo(q.dx, q.dy);
      }
    }
    c.drawPath(
      sheen,
      _pens.stroke
        ..strokeWidth = math.max(0.8, 0.07 * k)
        ..color = _Colors.ringSheen.withValues(alpha: 0.7),
    );
  }

  /// Question sign: the grey pole, the white board and its '?' face,
  /// swaying and (step 2) pulsing.
  void _paintSign(_Gfx g) {
    final sign = scene.sign;
    final k = scene.signScale;
    // The pole stops at the desk top when the sign swells.
    final bottom = math.max(-1.5, -_signPos.y / k);
    g.cylinder(
      sign.at(0, bottom, 0),
      sign.at(0, -0.5, 0),
      _poleR * k,
      _poleR * k,
      _Colors.pole,
      shine: 0.25,
    );
    g.box(
      sign,
      _signSize.x / 2,
      _signSize.y / 2,
      _signSize.z / 2,
      _Colors.sign,
      edge: 0.35,
    );
    // `MeshBasicMaterial` face: a white canvas with a blue '?'.
    if (sign.z.dot(g.cam.eye - sign.o) > 0) {
      const h = _signFace;
      g.onPlane(
        sign.at(-h, h, _signFaceZ),
        sign.at(h, h, _signFaceZ),
        sign.at(-h, -h, _signFaceZ),
        64,
        (canvas) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, 64, 64),
            _pens.fill..color = _Colors.white,
          );
          final tp = cache.glyph('?', 50, _Colors.signMark);
          tp.paint(canvas, Offset(32 - tp.width / 2, 35 - tp.height / 2));
        },
      );
    }
  }

  /// Light bulb: the metal base, the clear glass sphere (with a filament,
  /// added) and, once the guess is right, its orange light. The HTML's
  /// point light only lit the desk around it (see [_lit]); the warm glow
  /// around the glass is added so the bulb reads as switched on.
  void _paintBulb(_Gfx g) {
    final c = g.canvas;
    final on = scene.bulbOn;
    g.cylinder(
      _bulbPos + const _V(0, _bulbBaseBottom, 0),
      _bulbPos + const _V(0, _bulbBaseTop, 0),
      _bulbBaseR,
      _bulbBaseR,
      _Colors.bulbBase,
      shine: 0.45,
    );
    // Thread rings on the base (added).
    for (final y in const [-1.02, -0.9, -0.78]) {
      final a = g.p(_bulbPos + _V(-_bulbBaseR, y, 0));
      final b = g.p(_bulbPos + _V(_bulbBaseR, y, 0));
      c.drawLine(
        a,
        b,
        _pens.stroke
          ..strokeWidth = 1
          ..color = labShade(_Colors.bulbBase, -0.45).withValues(alpha: 0.6),
      );
    }
    final centre = g.p(_bulbPos);
    final r = _bulbR * g.cam.scaleAt(_bulbPos);
    if (on) {
      // The point light's warm glow around the bulb.
      c.drawCircle(
        centre,
        r * 3,
        _pens.glow
          ..shader = ui.Gradient.radial(
            centre,
            r * 3,
            [
              _Colors.bulbLight.withValues(alpha: 0.55),
              _Colors.bulbLight.withValues(alpha: 0.18),
              _Colors.bulbLight.withValues(alpha: 0),
            ],
            const [0, 0.45, 1],
          ),
      );
      _pens.glow.shader = null;
    }
    // Filament on two support wires (added).
    final wireL = g.p(_bulbPos + const _V(-0.12, -0.62, 0));
    final wireR = g.p(_bulbPos + const _V(0.12, -0.62, 0));
    final topL = g.p(_bulbPos + const _V(-0.16, 0.02, 0));
    final topR = g.p(_bulbPos + const _V(0.16, 0.02, 0));
    final hot = on ? _Colors.filamentHot : _Colors.filament;
    final wire = _pens.stroke
      ..strokeWidth = math.max(0.8, r * 0.035)
      ..color = on ? _Colors.bulbLight : _Colors.filament;
    c
      ..drawLine(wireL, topL, wire)
      ..drawLine(wireR, topR, wire);
    final coil = Path()..moveTo(topL.dx, topL.dy);
    for (var i = 1; i <= 8; i++) {
      final q = Offset.lerp(topL, topR, i / 8)!;
      coil.lineTo(q.dx, q.dy + (i.isOdd ? -r * 0.07 : r * 0.07));
    }
    c.drawPath(
      coil,
      _pens.stroke
        ..strokeWidth = math.max(0.8, r * (on ? 0.07 : 0.045))
        ..color = hot,
    );
    // The glass: clear, brighter at the rim, with the spot's highlight.
    c.drawCircle(
      centre,
      r,
      _pens.fill
        ..shader = ui.Gradient.radial(
          centre,
          r,
          [
            (on ? _Colors.bulbLight : _Colors.bulbGlass).withValues(
              alpha: on ? 0.32 : 0.12,
            ),
            _Colors.bulbGlass.withValues(alpha: on ? 0.4 : 0.28),
            _Colors.bulbGlass.withValues(alpha: 0.55),
          ],
          const [0, 0.75, 1],
        ),
    );
    _pens.fill.shader = null;
    c.drawCircle(
      centre,
      r,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.white.withValues(alpha: 0.35),
    );
    c.drawOval(
      Rect.fromCenter(
        center: centre + Offset(-r * 0.32, -r * 0.42),
        width: r * 0.42,
        height: r * 0.26,
      ),
      _pens.fill..color = _Colors.white.withValues(alpha: 0.75),
    );
  }

  /// Pen test station: the stand, the blue pen and its cap (lifting and
  /// spinning off in step 4; the clip, added, shows the spin).
  void _paintPen(_Gfx g) {
    final s = scene;
    final st = s.penStation;
    g.cylinder(
      st.at(0, _standBottom, 0),
      st.at(0, _standTop, 0),
      _standBottomR,
      _standTopR,
      _Colors.stand,
      shine: 0.12,
    );
    g.cylinder(
      st.at(0, _standTop, 0),
      st.at(0, _penHalf, 0),
      _penR,
      _penR,
      _Colors.pen,
      shine: 0.35,
    );
    final y = s.capY;
    g.cylinder(
      st.at(0, y - _capHalf, 0),
      st.at(0, y + _capHalf, 0),
      _capR,
      _capR,
      _Colors.cap,
      shine: 0.3,
    );
    // The clip on the cap's side, turning with it.
    final turn = s.capTurn;
    final out = st.x * math.sin(turn) + st.z * math.cos(turn);
    final top = st.at(0, y + _capHalf * 0.8, 0) + out * (_capR + 0.03);
    if (out.dot(g.cam.eye - top) > 0) {
      g.cylinder(
        top,
        st.at(0, y - _capHalf * 0.5, 0) + out * (_capR + 0.03),
        0.03,
        0.03,
        _Colors.slate300,
        shine: 0.5,
      );
    }
  }

  /// Notepad: the white pad (ruled, added) and the orange pencil, which
  /// rocks to scribble in step 5.
  void _paintNotepad(_Gfx g) {
    g.box(
      _Frame3.tiltX(_padPos, 0),
      _padSize.x / 2,
      _padSize.y / 2,
      _padSize.z / 2,
      _Colors.notepad,
      edge: 0.3,
    );
    const top = 0.0501;
    final line = _pens.stroke
      ..strokeWidth = 1
      ..color = _Colors.ruling;
    for (var z = -0.8; z <= 0.95; z += 0.25) {
      g.canvas.drawLine(
        g.p(_padPos + _V(-0.66, top, z)),
        g.p(_padPos + _V(0.66, top, z)),
        line,
      );
    }
    final (tip, back) = scene.pencil;
    final dir = (tip - back).unit;
    final woodStart = tip - dir * 0.16;
    g.cylinder(back, woodStart, _pencilR, _pencilR, _Colors.pencil, shine: 0.3);
    g.cylinder(woodStart, tip - dir * 0.05, _pencilR, 0.02, _Colors.pencilWood);
    g.cylinder(tip - dir * 0.05, tip, 0.02, 0.004, _Colors.pencilLead);
  }

  // ---------------------------------------------------------------- labels

  /// The HTML text sprites ("Magnifying Glass", "Question", "Guess",
  /// "Pen", "Notepad").
  void _paintLabels(_Gfx g) {
    for (final p in _Prop.values) {
      _chip(g, g.p(scene.labelAt(p)), _t(p.labelKey));
    }
  }

  /// HTML `createTextSprite`: a `#1e293b` chip with a `#3b82f6` border and
  /// white bold text, centred on [at] and kept inside the visible canvas.
  void _chip(_Gfx g, Offset at, String text) {
    final size = cache.chipSize(text);
    var rect = (at + _chipOffset(size)) & size;
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.5),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text);
    tp.paint(
      g.canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
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

/// canvas-confetti over the canvas (HTML `confetti(...)`): the pieces fly
/// out from the burst's origin, slow down, fall and fade over 200 ticks.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.scene, required Listenable repaint})
    : super(repaint: repaint);

  final _Scene scene;

  static final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final kind = s.burst;
    if (kind == null) return;
    final ticks = (s.time - s.burstAt) * 60;
    if (ticks < 0 || ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    final origin = Offset(size.width / 2, size.height * kind.originY);
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      final wobble = c.wobble + ticks * 0.1;
      canvas.save();
      canvas.translate(
        origin.dx + math.cos(c.angle) * d + 6 * math.cos(wobble),
        origin.dy + math.sin(c.angle) * d + fall,
      );
      canvas.rotate(c.tilt + ticks * 0.1);
      canvas.scale(1, math.cos(wobble).abs() * 0.8 + 0.2);
      _paint.color = c.color.withValues(alpha: fade);
      if (c.round) {
        canvas.drawCircle(Offset.zero, 4.5, _paint);
      } else {
        canvas.drawRect(const Rect.fromLTWH(-5, -4, 10, 8), _paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.scene != scene;
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
