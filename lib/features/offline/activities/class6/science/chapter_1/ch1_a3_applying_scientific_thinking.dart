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

/// Class 6 Science • Chapter 1 • Activity 3
/// Applying Scientific Thinking.
///
/// Native Flutter port of `Cl6S-Ch1-A3-ApplyingScientificThinking.html`
/// (Three.js r128 + GSAP). The HTML's 'Case Desk' (a round wooden desk with
/// a faint grid, seen by a 45° PerspectiveCamera from (0, 8, 20)) is redrawn
/// by a painter through the same projection; its photo markers (a pen, a
/// pressure cooker, a bicycle tyre, a light bulb and a notepad), which the
/// HTML loaded from files that are not part of the page, are painted
/// procedurally. The HTML's workspace panel (step header, task, VERIFY and
/// the phase arrows) is a panel on the canvas; its teacher board (mission
/// objective and 'The Five Steps') is the sidebar.
///
/// Scenario 1 (Crack the Case): the learner picks one of four everyday
/// cases (a pen that stopped writing, dal that spilled from a cooker, a flat
/// tyre, a bulb that will not light); its prop lights up on the desk and the
/// camera glides towards it. The case's five statements, shuffled in a
/// tray, are dragged into five slots ('1. What did you notice?' …
/// '5. What did the check tell you?'). VERIFY checks the order Observe →
/// Wonder / Question → Guess → Test → Analyse, with a special hint when a
/// guess is not tested before the analysis; when it is right the prop
/// bounces and Scenario 2 opens.
///
/// Scenario 2 (Spot the Missing Step): four case files (Cooker, Tyre, Bulb,
/// Pen), browsed with arrows, each miss one step (Test, Guess, Analyse,
/// Observe). The learner drags the missing step from a tray of five into
/// each blank slot; VERIFY counts the wrong ones.
///
/// Scenario 3 (Your Own "Why?"): the camera closes in on a notepad and the
/// learner writes an observation, a question, a guess and a test plan of
/// their own. VERIFY needs at least three words in each box and a '?' in
/// the question, then the Conclusion closes the lab.
class Ch1A3ApplyingScientificThinkingPage extends StatefulWidget {
  const Ch1A3ApplyingScientificThinkingPage({super.key});

  @override
  State<Ch1A3ApplyingScientificThinkingPage> createState() =>
      _ScientificThinkingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises five Web Audio tones; each maps to the closest file:
/// 'click' (buttons, a case or an arrow tapped, a placed step removed) →
/// click (`science/click.mp3`); 'drag' (a card picked up) → pickup, also
/// `science/click.mp3`; 'drop' (a card released on a slot) → drop
/// (`science/dropdown.mp3`); 'success' (a correct VERIFY) → correct and
/// 'success' (the Conclusion) → success (both `math/success.mp3`); 'error'
/// (a wrong VERIFY) → wrong (`science/error.mp3`). The shell plays toggle
/// (`science/dropdown.mp3`), scenario (`science/page_open.mp3`) and curtain
/// (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A correct VERIFY (HTML `success`).
  correct('audio/class6/math/success.mp3'),

  /// A wrong VERIFY (HTML `error`); the added hints.
  wrong('audio/class6/science/error.mp3'),

  /// The Conclusion opens (HTML `showFinal` → `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A card or step token picked up (HTML `drag`).
  pickup('audio/class6/science/click.mp3'),

  /// A card or step token released on a slot (HTML `drop`).
  drop('audio/class6/science/dropdown.mp3');

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

/// Colours of the HTML page (Tailwind classes), of its Three.js desk
/// (material colours) and of the props painted in place of its photos.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color orange500 = Color(0xFFF97316);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red900 = Color(0xFF7F1D1D);
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
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper`: `bg-[#f1f5f9] dark:bg-[#0f172a]` (the renderer is
  /// transparent).
  static const Color sceneLight = slate100;
  static const Color sceneDark = slate900;

  /// Desk `MeshStandardMaterial({color: 0x8b5a2b})`.
  static const Color wood = Color(0xFF8B5A2B);

  /// `GridHelper(30, 30, 0xffffff, 0xffffff)` at opacity 0.1.
  static const Color grid = Color(0x1AFFFFFF);

  /// Marker label chips: `bg-slate-900/90 text-white` (light theme),
  /// `bg-slate-100/90 text-slate-900` (dark theme).
  static const Color chipLight = Color(0xE60F172A);
  static const Color chipDark = Color(0xE6F1F5F9);

  /// Marker cards: `bg-white/80 dark:bg-slate-800/80`, border `white/50`
  /// (`dark:slate-600`).
  static const Color cardLight = Color(0xCCFFFFFF);
  static const Color cardDark = Color(0xCC1E293B);
  static const Color cardEdgeLight = Color(0x80FFFFFF);
  static const Color cardEdgeDark = slate600;

  // ------------------------------------------------------- painted props
  static const Color paper = Color(0xFFF8FAFC);
  static const Color paperYellow = Color(0xFFFEFCE8);
  static const Color rule = Color(0xFFBFDBFE);
  static const Color margin = Color(0xFFFCA5A5);
  static const Color ink = Color(0xFF1E3A8A);
  static const Color penBody = Color(0xFF2563EB);
  static const Color penGrip = Color(0xFF1E293B);
  static const Color steel = Color(0xFFCBD5E1);
  static const Color steelDark = Color(0xFF64748B);
  static const Color steelLight = Color(0xFFF1F5F9);
  static const Color bakelite = Color(0xFF1C1917);
  static const Color tile = Color(0xFFE7E5E4);
  static const Color tileLine = Color(0xFFD6D3D1);
  static const Color stove = Color(0xFF334155);
  static const Color flame = Color(0xFF60A5FA);
  static const Color dal = Color(0xFFFACC15);
  static const Color dalDark = Color(0xFFCA8A04);
  static const Color steam = Color(0xB3FFFFFF);
  static const Color sky = Color(0xFFBAE6FD);
  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color road = Color(0xFF57534E);
  static const Color roadLine = Color(0xFFFDE68A);
  static const Color rubber = Color(0xFF1F2937);
  static const Color rubberLight = Color(0xFF4B5563);
  static const Color frame = blue500;
  static const Color nail = Color(0xFF9CA3AF);
  static const Color room = Color(0xFF334155);
  static const Color roomDark = Color(0xFF1E293B);
  static const Color filament = Color(0xFF78716C);
  static const Color switchPlate = Color(0xFFF1F5F9);
  static const Color desk = Color(0xFFA16207);
  static const Color deskDark = Color(0xFF92400E);
  static const Color pencil = Color(0xFFFACC15);
  static const Color pencilWood = Color(0xFFFDE68A);
  static const Color eraser = Color(0xFFF9A8D4);
  static const Color graphite = Color(0xFF374151);
  static const Color shadow = Color(0x40000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xF20F172A), // --glass-bg rgba(15, 23, 42, 0.95)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0x801E293B), // teacher board cards dark:bg-slate-800/50
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
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
    popupBg: _Colors.slate900, // success modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate900, // toast bg-slate-900/95
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
    labelBg: _Colors.slate900,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border
    card: _Colors.slate100,
    cardBorder: _Colors.slate200,
    canvasBg: _Colors.sceneLight,
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
    labelBg: _Colors.slate900,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar font-size setting: 18 px, slider 16–32 px, scaled
/// to the shell's 15 px body text.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 13,
  maxSize: 24,
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
// From the HTML `i18n`, `caseFiles`, `s2Tokens`, `s1SlotHints` and
// `stepNames` tables and its English-only messages (Telugu dropped). The
// HTML's three phases are the scenarios; their steps (`sN_step_M`, shown
// as the current task) follow the slots, cases and boxes of each phase and
// are new texts, as the HTML had no step list. `sb_step_N` are the five
// paragraphs of the HTML `sb_steps` (split at its `<br><br>`). Keys marked
// "Added." are new texts the HTML did not have; "Hindi added." marks
// English-only HTML texts that got a Hindi translation here.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Applying Scientific Thinking',
    'app_subtitle': 'Class 6 • The Wonderful world of science',
    'sc1_title': '1. Crack the Case',
    'sc2_title': '2. Spot the Missing Step',
    'sc3_title': "3. Your Own 'Why?'",
    'mission_obj_text':
        "Use the five-step scientific method on a real everyday problem, spot a step that's been skipped, and then ask — and plan to test — a 'Why?' question of your own.",
    'taskInstr': 'The Five Steps',
    'sb_step_1':
        '1. First, we observe something that we find interesting or we do not understand.',
    'sb_step_2':
        '2. This makes us wonder and perhaps think of a question about it.',
    'sb_step_3': '3. Then, we guess a possible answer to that question.',
    'sb_step_4':
        '4. We test this guess through experiments or more observations.',
    'sb_step_5':
        '5. We then try to analyse the results to see if it actually answers our question.',
    's1_title': 'Crack the Case',
    's1_desc':
        'Drag the five steps of the scientific method into the correct order for this case.',
    's2_title': 'Spot the Missing Step',
    's2_desc':
        'This case file is missing one step. Figure out which step is skipped and drag it into the blank slot.',
    's3_title': 'Your Own "Why?"',
    's3_desc':
        'If you have to ask Why? about something, what would you ask about? Try to write down how you would find an answer.',
    'case_A_lbl': 'Pen',
    'case_B_lbl': 'Cooker',
    'case_C_lbl': 'Tyre',
    'case_D_lbl': 'Bulb',
    's3_l1': '1. Observation',
    's3_h1':
        "What did you see that made you curious? e.g., 'My chalk squeaks on some boards.'",
    's3_l2': '2. Wonder / Question',
    's3_h2': "Ask a question about it. Must contain a question mark '?'.",
    's3_l3': '3. Guess',
    's3_h3': 'What is a possible answer?',
    's3_l4': '4. Test Plan',
    's3_h4': 'How will you check if your guess is right?',
    'conclusion_text':
        "Whether it's a pen that stopped writing, dal that spilled from a cooker, a flat tyre, or a bulb that won't light — anyone who observes, questions, guesses, tests, and analyses is working like a scientist. Being curious and observant is the first step, and learning to do this well helps us solve bigger problems and mysteries in the future.",
    'conclusion_title': 'Conclusion',
    'step_prefix': 'STEP',
    'verify': 'VERIFY',
    'drop_hint': 'Drop the matching step here...',
    'missing_step': 'Which step is missing?',
    'missing_hint':
        'Look at the other steps. What happens at this point in the process?',
    'case_indicator': 'Case',
    // HTML `curr_obj`, the label of the task line in the workspace panel.
    'curr_task': 'Current Task',
    // HTML `caseFiles`: the five statements of each case, in step order.
    'card_A1': 'My pen stopped writing.',
    'card_A2': 'Why did my pen stop writing?',
    'card_A3': 'I guess the ink has finished.',
    'card_A4': 'I open the pen and check the ink refill.',
    'card_A5':
        'If the refill is empty, my guess was correct. If it is not empty, I make another guess — perhaps the ink dried up — and test that too.',
    'card_B1': 'The dal spilled out of the cooker.',
    'card_B2': 'Why did the dal spill out of the cooker?',
    'card_B3': 'Was there too much water?',
    'card_B4': 'Check how much water was used, through more observation.',
    'card_B5':
        'Decide whether the amount of water explains why the dal spilled.',
    'card_C1': 'The tyre is flat.',
    'card_C2': 'From where did the air leak out?',
    'card_C3': 'Guess a possible place where the air might have leaked out.',
    'card_C4': 'Test that part of the tyre through experiment or observation.',
    'card_C5':
        'Decide whether the test result explains where the air leaked out.',
    'card_D1': 'The light bulb is not working.',
    'card_D2': 'Is there some problem with the bulb or the switch?',
    'card_D3': 'Guess whether the problem is with the bulb or with the switch.',
    'card_D4': 'Check the bulb and the switch to test the guess.',
    'card_D5': 'Decide whether the bulb or the switch was the actual problem.',
    // HTML `s2Tokens`.
    'token_observe': 'Observe',
    'token_question': 'Wonder / Question',
    'token_guess': 'Guess',
    'token_test': 'Test',
    'token_analyse': 'Analyse',
    // HTML `s1SlotHints`.
    'slot_hint_1': '1. What did you notice?',
    'slot_hint_2': '2. What do you want to ask about it?',
    'slot_hint_3': '3. What might be the answer?',
    'slot_hint_4': '4. How will you check if you are right?',
    'slot_hint_5': '5. What did the check tell you?',
    // HTML `stepNames` (English only; Hindi added from `s2Tokens`).
    'step_name_1': 'Observe',
    'step_name_2': 'Wonder/Question',
    'step_name_3': 'Guess',
    'step_name_4': 'Test',
    'step_name_5': 'Analyse',
    // English-only HTML messages (Hindi added).
    'slot_taken': 'Slot already taken!',
    'complete_first': 'Please complete the task first!',
    'err_guess_order':
        'Remember: A guess must be tested before you analyse and conclude!',
    'err_order':
        'Two or more steps are out of order. Check the sequence on the Teacher Board!',
    'err_s2':
        '{n} missing step(s) are incorrect. Use the arrows to check all cases again!',
    'err_expand': 'Please expand on your answers. {error}',
    'err_obs_short': 'Observation is too short.',
    'err_q_short': 'Question is too short.',
    'err_q_mark': "Question must contain a '?'.",
    'err_guess_short': 'Guess is too short.',
    'err_test_short': 'Test plan is too short.',
    'correct_btn': 'CORRECT!',
    'ph_1': 'I noticed that...',
    'ph_2': 'Why does... ?',
    'ph_3': 'I guess that...',
    'ph_4': 'I will test this by...',
    // Added. The steps of each phase (shown as the current task).
    's1_step_1':
        "Pick a case: Pen, Cooker, Tyre or Bulb. Then drag the card that answers '1. What did you notice?' into slot 1.",
    's1_step_2':
        "Drag the card that answers '2. What do you want to ask about it?' into slot 2.",
    's1_step_3':
        "Drag the card that answers '3. What might be the answer?' into slot 3.",
    's1_step_4':
        "Drag the card that answers '4. How will you check if you are right?' into slot 4.",
    's1_step_5':
        "Drag the card that answers '5. What did the check tell you?' into slot 5.",
    's1_step_6': 'Tap VERIFY to check the order of the five steps.',
    's2_step_1':
        'Case 1/4 (Cooker): which step is missing? Drag it from the tray into the blank slot.',
    's2_step_2':
        'Tap the › arrow to open Case 2/4 (Tyre), then drag its missing step into the blank slot.',
    's2_step_3':
        'Tap the › arrow to open Case 3/4 (Bulb), then drag its missing step into the blank slot.',
    's2_step_4':
        'Tap the › arrow to open Case 4/4 (Pen), then drag its missing step into the blank slot.',
    's2_step_5': 'Tap VERIFY to check the missing steps of all four cases.',
    's3_step_1':
        'Type what you noticed in box 1 (Observation), in at least three words.',
    's3_step_2':
        "Type your question in box 2 (Wonder / Question): at least three words, with a question mark '?'.",
    's3_step_3':
        'Type your guess, a possible answer, in box 3 (Guess), in at least three words.',
    's3_step_4':
        'Type in box 4 (Test Plan) how you will check your guess, in at least three words.',
    's3_step_5': "Tap VERIFY to check your own 'Why?' plan.",
    // Added. The step types on the read-only rows of Scenario 2 (the HTML
    // printed its type ids 'observe' … 'analyse').
    'type_observe': 'Observe',
    'type_question': 'Question',
    'type_guess': 'Guess',
    'type_test': 'Test',
    'type_analyse': 'Analyse',
    // Added. Touch hints, labels and the scene description.
    'tray_hint_s1':
        'Drag a card into a slot, or tap a card and then tap a slot. Tap a placed card to send it back.',
    'tray_hint_s2':
        'Drag a step into the blank slot, or tap a step and then tap the blank slot. Tap a placed step to remove it.',
    'pick_first_s1':
        'First pick a card from the tray: drag it here, or tap it and then tap this slot.',
    'pick_first_s2':
        'First pick a step from the tray: drag it here, or tap it and then tap the blank slot.',
    'slot_label': 'Slot {n}',
    'blank_label': 'Blank slot',
    'prev_phase': 'Previous phase',
    'next_phase': 'Next phase',
    'prev_case': 'Previous case',
    'next_case': 'Next case',
    'hint_lbl': 'Hint',
    'scene_desk':
        'A round wooden desk with four case files: a pen, a pressure cooker, a bicycle tyre and a light bulb',
    'scene_notepad': 'A notepad on the desk for your own "Why?" question',
  },
  'hi': {
    // The HTML's Hindi title ('हर रोज़ के वैज्ञानिक') and subtitle were those
    // of Activity 2; this activity's title is the HTML's Hindi subtitle.
    'app_title': 'वैज्ञानिक सोच लागू करना',
    'app_subtitle': 'कक्षा 6 • विज्ञान की अद्भुत दुनिया',
    'sc1_title': '1. केस क्रैक करें',
    'sc2_title': '2. छूटा हुआ चरण खोजें',
    'sc3_title': "3. आपका अपना 'क्यों?'",
    'mission_obj_text':
        "एक वास्तविक रोजमर्रा की समस्या पर पांच-चरणीय वैज्ञानिक पद्धति का उपयोग करें, उस चरण को खोजें जिसे छोड़ दिया गया है, और फिर अपना खुद का 'क्यों?' प्रश्न पूछें — और परीक्षण की योजना बनाएं।",
    'taskInstr': 'पाँच चरण',
    'sb_step_1':
        '1. सबसे पहले, हम कुछ ऐसा देखते हैं जो हमें दिलचस्प लगता है या जिसे हम नहीं समझते हैं।',
    'sb_step_2':
        '2. यह हमें आश्चर्यचकित करता है और शायद इसके बारे में एक प्रश्न सोचने पर मजबूर करता है।',
    'sb_step_3': '3. फिर, हम उस प्रश्न के संभावित उत्तर का अनुमान लगाते हैं।',
    'sb_step_4':
        '4. हम प्रयोगों या अधिक अवलोकनों के माध्यम से इस अनुमान का परीक्षण करते हैं।',
    'sb_step_5':
        '5. हम तब यह देखने के लिए परिणामों का विश्लेषण करने का प्रयास करते हैं कि क्या यह वास्तव में हमारे प्रश्न का उत्तर देता है।',
    's1_title': 'केस क्रैक करें',
    's1_desc':
        'इस मामले के लिए वैज्ञानिक पद्धति के पांच चरणों को सही क्रम में खींचें।',
    's2_title': 'छूटा हुआ चरण खोजें',
    's2_desc':
        'इस केस फ़ाइल में एक चरण गायब है। पता लगाएं कि कौन सा चरण छोड़ दिया गया है और उसे खाली स्लॉट में खींचें।',
    's3_title': 'आपका अपना "क्यों?"',
    's3_desc':
        'अगर आपको किसी चीज के बारे में क्यों? पूछना हो, तो आप किसके बारे में पूछेंगे? यह लिखने का प्रयास करें कि आप उत्तर कैसे खोजेंगे।',
    'case_A_lbl': 'कलम',
    'case_B_lbl': 'कुकर',
    'case_C_lbl': 'टायर',
    'case_D_lbl': 'बल्ब',
    's3_l1': '1. अवलोकन',
    's3_h1': 'आपने ऐसा क्या देखा जिसने आपको उत्सुक किया?',
    's3_l2': '2. आश्चर्य / प्रश्न',
    's3_h2':
        "इसके बारे में एक प्रश्न पूछें। इसमें प्रश्न चिह्न '?' होना चाहिए।",
    's3_l3': '3. अनुमान',
    's3_h3': 'संभावित उत्तर क्या है?',
    's3_l4': '4. परीक्षण योजना',
    's3_h4': 'आप कैसे जांचेंगे कि आपका अनुमान सही है?',
    'conclusion_text':
        'चाहे वह कलम हो जिसने लिखना बंद कर दिया हो, कुकर से दाल छलक गई हो, टायर पंक्चर हो गया हो, या बल्ब जल नहीं रहा हो — जो कोई भी देखता है, प्रश्न करता है, अनुमान लगाता है, परीक्षण करता है और विश्लेषण करता है, वह एक वैज्ञानिक की तरह काम कर रहा है।',
    'conclusion_title': 'निष्कर्ष',
    'step_prefix': 'चरण',
    'verify': 'सत्यापित करें',
    'drop_hint': 'सही चरण को यहां खींचें...',
    'missing_step': 'कौन सा चरण गायब है?',
    'missing_hint': 'अन्य चरणों को देखें। इस बिंदु पर क्या होता है?',
    'case_indicator': 'केस',
    'curr_task': 'वर्तमान कार्य',
    'card_A1': 'मेरी कलम ने लिखना बंद कर दिया।',
    'card_A2': 'मेरी कलम ने लिखना क्यों बंद कर दिया?',
    'card_A3': 'मुझे लगता है कि स्याही खत्म हो गई है।',
    'card_A4': 'मैं कलम खोलता हूं और स्याही रिफिल की जांच करता हूं।',
    'card_A5':
        'यदि रिफिल खाली है, तो मेरा अनुमान सही था। यदि यह खाली नहीं है, तो मैं एक और अनुमान लगाता हूं — शायद स्याही सूख गई — और उसका भी परीक्षण करता हूं।',
    'card_B1': 'दाल कुकर से बाहर गिर गई।',
    'card_B2': 'दाल कुकर से बाहर क्यों गिर गई?',
    'card_B3': 'क्या पानी बहुत अधिक था?',
    'card_B4':
        'और अधिक अवलोकन के माध्यम से जांचें कि कितना पानी उपयोग किया गया था।',
    'card_B5':
        'तय करें कि क्या पानी की मात्रा यह स्पष्ट करती है कि दाल क्यों गिर गई।',
    'card_C1': 'टायर फ्लैट है।',
    'card_C2': 'हवा कहाँ से निकली?',
    'card_C3': 'उस संभावित स्थान का अनुमान लगाएं जहां से हवा लीक हुई होगी।',
    'card_C4':
        'प्रयोग या अवलोकन के माध्यम से टायर के उस हिस्से का परीक्षण करें।',
    'card_C5':
        'तय करें कि क्या परीक्षण का परिणाम यह स्पष्ट करता है कि हवा कहाँ से निकली।',
    'card_D1': 'बल्ब काम नहीं कर रहा है।',
    'card_D2': 'क्या बल्ब या स्विच में कोई समस्या है?',
    'card_D3': 'अनुमान लगाएं कि समस्या बल्ब के साथ है या स्विच के साथ।',
    'card_D4': 'अनुमान का परीक्षण करने के लिए बल्ब और स्विच की जांच करें।',
    'card_D5': 'तय करें कि बल्ब या स्विच वास्तविक समस्या थी या नहीं।',
    'token_observe': 'अवलोकन करें',
    'token_question': 'आश्चर्य / प्रश्न',
    'token_guess': 'अनुमान',
    'token_test': 'परीक्षण',
    'token_analyse': 'विश्लेषण',
    'slot_hint_1': '1. आपने क्या देखा?',
    'slot_hint_2': '2. आप इसके बारे में क्या पूछना चाहते हैं?',
    'slot_hint_3': '3. उत्तर क्या हो सकता है?',
    'slot_hint_4': '4. आप कैसे जांचेंगे कि आप सही हैं?',
    'slot_hint_5': '5. जांच ने आपको क्या बताया?',
    // Hindi added.
    'step_name_1': 'अवलोकन करें',
    'step_name_2': 'आश्चर्य / प्रश्न',
    'step_name_3': 'अनुमान',
    'step_name_4': 'परीक्षण',
    'step_name_5': 'विश्लेषण',
    // Hindi added.
    'slot_taken': 'यह स्लॉट पहले से भरा हुआ है!',
    'complete_first': 'कृपया पहले कार्य पूरा करें!',
    'err_guess_order':
        'याद रखें: विश्लेषण करने और निष्कर्ष निकालने से पहले अनुमान का परीक्षण करना ज़रूरी है!',
    'err_order':
        'दो या अधिक चरण गलत क्रम में हैं। शिक्षक बोर्ड पर क्रम जाँचें!',
    'err_s2':
        '{n} छूटे हुए चरण गलत हैं। सभी केस फिर से जाँचने के लिए तीरों का उपयोग करें!',
    'err_expand': 'कृपया अपने उत्तर थोड़ा विस्तार से लिखें। {error}',
    'err_obs_short': 'अवलोकन बहुत छोटा है।',
    'err_q_short': 'प्रश्न बहुत छोटा है।',
    'err_q_mark': "प्रश्न में '?' होना चाहिए।",
    'err_guess_short': 'अनुमान बहुत छोटा है।',
    'err_test_short': 'परीक्षण योजना बहुत छोटी है।',
    'correct_btn': 'सही!',
    'ph_1': 'मैंने देखा कि...',
    'ph_2': 'ऐसा क्यों होता है कि... ?',
    'ph_3': 'मेरा अनुमान है कि...',
    'ph_4': 'मैं इसका परीक्षण ऐसे करूँगा...',
    // Added.
    's1_step_1':
        "एक केस चुनें: कलम, कुकर, टायर या बल्ब। फिर वह कार्ड स्लॉट 1 में खींचें जो '1. आपने क्या देखा?' का उत्तर देता है।",
    's1_step_2':
        "वह कार्ड स्लॉट 2 में खींचें जो '2. आप इसके बारे में क्या पूछना चाहते हैं?' का उत्तर देता है।",
    's1_step_3':
        "वह कार्ड स्लॉट 3 में खींचें जो '3. उत्तर क्या हो सकता है?' का उत्तर देता है।",
    's1_step_4':
        "वह कार्ड स्लॉट 4 में खींचें जो '4. आप कैसे जांचेंगे कि आप सही हैं?' का उत्तर देता है।",
    's1_step_5':
        "वह कार्ड स्लॉट 5 में खींचें जो '5. जांच ने आपको क्या बताया?' का उत्तर देता है।",
    's1_step_6':
        "पाँचों चरणों का क्रम जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's2_step_1':
        'केस 1/4 (कुकर): कौन सा चरण गायब है? उसे ट्रे से खाली स्लॉट में खींचें।',
    's2_step_2':
        'केस 2/4 (टायर) खोलने के लिए › तीर पर टैप करें, फिर उसका गायब चरण खाली स्लॉट में खींचें।',
    's2_step_3':
        'केस 3/4 (बल्ब) खोलने के लिए › तीर पर टैप करें, फिर उसका गायब चरण खाली स्लॉट में खींचें।',
    's2_step_4':
        'केस 4/4 (कलम) खोलने के लिए › तीर पर टैप करें, फिर उसका गायब चरण खाली स्लॉट में खींचें।',
    's2_step_5':
        "चारों केस के गायब चरण जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's3_step_1':
        'बॉक्स 1 (अवलोकन) में लिखें कि आपने क्या देखा, कम से कम तीन शब्दों में।',
    's3_step_2':
        "बॉक्स 2 (आश्चर्य / प्रश्न) में अपना प्रश्न लिखें: कम से कम तीन शब्द, प्रश्न चिह्न '?' के साथ।",
    's3_step_3':
        'बॉक्स 3 (अनुमान) में अपना अनुमान, यानी संभावित उत्तर, कम से कम तीन शब्दों में लिखें।',
    's3_step_4':
        'बॉक्स 4 (परीक्षण योजना) में लिखें कि आप अपने अनुमान की जाँच कैसे करेंगे, कम से कम तीन शब्दों में।',
    's3_step_5':
        "अपनी 'क्यों?' योजना जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    // Added.
    'type_observe': 'अवलोकन',
    'type_question': 'प्रश्न',
    'type_guess': 'अनुमान',
    'type_test': 'परीक्षण',
    'type_analyse': 'विश्लेषण',
    // Added.
    'tray_hint_s1':
        'किसी कार्ड को स्लॉट में खींचें, या कार्ड पर टैप करके फिर स्लॉट पर टैप करें। रखे हुए कार्ड पर टैप करने से वह ट्रे में लौट जाता है।',
    'tray_hint_s2':
        'किसी चरण को खाली स्लॉट में खींचें, या चरण पर टैप करके फिर खाली स्लॉट पर टैप करें। रखे हुए चरण पर टैप करने से वह हट जाता है।',
    'pick_first_s1':
        'पहले ट्रे से एक कार्ड चुनें: उसे यहाँ खींचें, या उस पर टैप करके फिर इस स्लॉट पर टैप करें।',
    'pick_first_s2':
        'पहले ट्रे से एक चरण चुनें: उसे यहाँ खींचें, या उस पर टैप करके फिर खाली स्लॉट पर टैप करें।',
    'slot_label': 'स्लॉट {n}',
    'blank_label': 'खाली स्लॉट',
    'prev_phase': 'पिछला चरण',
    'next_phase': 'अगला चरण',
    'prev_case': 'पिछला केस',
    'next_case': 'अगला केस',
    'hint_lbl': 'संकेत',
    'scene_desk':
        'एक गोल लकड़ी की मेज़ पर चार केस फ़ाइलें: एक कलम, एक प्रेशर कुकर, एक साइकिल का टायर और एक बल्ब',
    'scene_notepad': 'आपके अपने "क्यों?" प्रश्न के लिए मेज़ पर एक नोटपैड',
  },
};

/// Number of steps of each scenario: the five slots and VERIFY (S1), the
/// four case files and VERIFY (S2), the four boxes and VERIFY (S3).
const List<int> _stepCounts = [6, 5, 5];

/// The 'Concept Focus' of step [i] of scenario [n] (both 1-based): the
/// HTML `stepNames` for the slots of S1 and the box labels of S3. S2 has
/// none (it would give the missing steps away).
String _conceptKey(int n, int i) {
  if (n == 1 && i <= _slotCount) return 'step_name_$i';
  if (n == 3 && i <= _fieldCount) return 's3_l$i';
  return '';
}

/// The three scenarios (HTML phases) for [lang], built from the string
/// table. The HTML teacher board shows the same mission objective in every
/// phase.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('sc${n}_title'),
        objective: t('mission_obj_text'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
            LabStep(
              concept: _conceptKey(n, i).isEmpty ? '' : t(_conceptKey(n, i)),
              action: t('s${n}_step_$i'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Slots of Scenario 1 (the five steps), case files of Scenario 2 and
/// boxes of Scenario 3.
const int _slotCount = 5;
const int _s2CaseCount = 4;
const int _fieldCount = 4;

/// Scenario 3: words each box needs (HTML `getWordCount(…) < 3` fails).
const int _minWords = 3;

/// HTML `setTimeout(…, 1500)`: 'CORRECT!' shows this long before the next
/// phase (or the Conclusion) opens.
const Duration _correctHold = Duration(milliseconds: 1500);

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// HTML camera: `PerspectiveCamera(45, …)` at (0, 8, 20) looking at the
/// origin; Scenario 3 glides it to (0, 6, 10).
const double _fovDegrees = 45;
const _V _eyeDesk = _V(0, 8, 20);
const _V _eyeNotepad = _V(0, 6, 10);
const double _near = 0.1;

/// The desk and grid are clipped this far in front of the camera (the
/// close-up camera of Scenario 3 is above the desk's near edge).
const double _clipNear = 0.5;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// GSAP durations: the camera moves of `loadPhase` (1 s) and the camera
/// target of `selectCase` (0.8 s). GSAP's default ease is `power1.out`.
const double _cameraSeconds = 1;
const double _caseSeconds = 0.8;

/// Desk `CylinderGeometry(15, 15, 0.5, 32)` at y = -0.25 (its top at
/// y = 0) and the `GridHelper(30, 30)` on it.
const double _deskRadius = 15;
const double _deskHeight = 0.5;
const int _deskSegments = 32;
const double _gridHalf = 15;
const int _gridDivisions = 30;

/// `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(0xffffff, 0.6)` at
/// (10, 20, 10).
const double _ambient = 0.6;
const double _diffuse = 0.6;
final _V _lightDir = const _V(10, 20, 10).unit;

/// Height of the markers on the desk (`markerConfigs`, y = 0.5).
const double _markerY = 0.5;

/// Marker cards: CSS `w-56 h-40` (224 x 160, `rounded-2xl`, `ring-4`,
/// a 30 px coloured glow) with a `mt-3` label chip (`text-sm`, line 20 px,
/// `px-4 py-1.5`, `rounded-xl`, `tracking-widest`), scaled by
/// `15 / distance` within 0.4–1.5. The 560 px stage stands for the HTML
/// canvas at 1280 x 720 (632 px between its header and footer).
const double _cssToDesign = 560 / 632;
const double _cardCssW = 224;
const double _cardCssH = 160;
const double _cardCssRadius = 16;
const double _ringCss = 4;
const double _glowCss = 30;
const double _labelGapCss = 12;
const double _labelFontCss = 14;
const double _labelLineCss = 20;
const double _labelPadXCss = 16;
const double _labelPadYCss = 6;
const double _labelRadiusCss = 12;
const double _labelTracking = 0.1;
const double _markerDistance = 15;
const double _markerMinScale = 0.4;
const double _markerMaxScale = 1.5;

/// Dimmed props: CSS `grayscale(0.8) brightness(0.6)`.
const double _dimGray = 0.8;
const double _dimBright = 0.6;

/// The notepad photo: `opacity-80`.
const double _notepadOpacity = 0.8;

/// A correct VERIFY in Scenario 1: `gsap.to(prop, {scale: 1.1, yoyo: true,
/// repeat: 3, duration: 0.3})`.
const double _bounceScale = 1.1;
const double _bounceHalf = 0.3;
const int _bounceRuns = 4;

/// Scene labels never get smaller than this (design px); enlarged up to
/// 1.8x on small stages so they stay readable on phones.
const double _labelPx = 11;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the animations (s), so a stalled frame does
/// not make them jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the panel) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the compact floating mission
/// card (phones in landscape: screens shorter than [_compactBelow], at most
/// [_compactCardMax] of the height, 12 px from the top).
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene in each scenario (the HTML camera is
/// zoom 1); it is never drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.25, 1.25, 1.2];
const double _minZoom = 0.3;

/// Workspace panel: 46% of the canvas, 260–460 px wide, on the right of the
/// canvas next to the tool column. Its contents are scaled with its width
/// ([_panelRef] px wide at scale 1).
const double _panelShare = 0.46;
const double _panelMin = 260;
const double _panelMax = 460;
const double _panelRef = 380;
const double _panelScaleMin = 0.78;
const double _panelScaleMax = 1.1;

/// While a card is dragged near the top or bottom edge of the panel, the
/// panel scrolls (px from the edge, px/s at the edge).
const double _scrollEdge = 48;
const double _scrollSpeed = 560;

/// Panels shorter than this (phones in landscape) scroll their step header
/// and current task away with the content; only the footer stays.
const double _compactPanelBelow = 460;

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
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// GSAP's default ease, `power1.out`.
double _power1Out(double t) => 1 - (1 - t) * (1 - t);

/// A GSAP `to()` tween of a vector (camera position or target). A new
/// tween starts from wherever the running one has got to.
class _Tween3 {
  _Tween3(_V value) : from = value, to = value;

  _V from;
  _V to;
  double start = 0;
  double seconds = 0;

  _V at(double time) => seconds <= 0
      ? to
      : _V.lerp(
          from,
          to,
          _power1Out(((time - start) / seconds).clamp(0.0, 1.0)),
        );

  bool done(double time) => seconds <= 0 || time - start >= seconds;

  void animate(double time, _V target, double duration) {
    from = at(time);
    to = target;
    start = time;
    seconds = duration;
  }

  void snap(_V value) {
    from = value;
    to = value;
    seconds = 0;
  }
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
  factory _Cam(_V eye, _V target, _Framing framing) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      eye,
      f,
      r,
      r.cross(f),
      framing.center,
      _focal * framing.zoom,
      framing.zoom,
    );
  }

  const _Cam._(
    this.eye,
    this.f,
    this.r,
    this.u,
    this.center,
    this.scale,
    this.zoom,
  );

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  /// The framing's zoom (HTML-sized markers grow with it).
  final double zoom;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w].
  Offset p(_V w) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// [poly] clipped to the part at least [_clipNear] in front of the
  /// camera (Sutherland–Hodgman against the near plane).
  List<_V> clip(List<_V> poly) {
    final out = <_V>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      final da = depth(a) - _clipNear;
      final db = depth(b) - _clipNear;
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) out.add(_V.lerp(a, b, da / (da - db)));
    }
    return out;
  }

  /// The segment [a]–[b] clipped like [clip], or null when it is behind.
  (_V, _V)? clipSegment(_V a, _V b) {
    final da = depth(a) - _clipNear;
    final db = depth(b) - _clipNear;
    if (da < 0 && db < 0) return null;
    if (da >= 0 && db >= 0) return (a, b);
    final c = _V.lerp(a, b, da / (da - db));
    return da >= 0 ? (a, c) : (c, b);
  }
}

/// The HTML's markers: the four case props and the notepad of Scenario 3,
/// in DOM order (later ones are drawn on top).
enum _Prop {
  /// `#marker-pen`, `ring-indigo-500/50`; case A.
  pen(
    'A',
    Icons.edit,
    _Colors.indigo500,
    _V(-2.95, _markerY, -7.5),
    _V(-3.5, _markerY, -2),
  ),

  /// `#marker-cooker`, `ring-orange-500/50`; case B.
  cooker(
    'B',
    Icons.soup_kitchen,
    _Colors.orange500,
    _V(2.95, _markerY, -7.5),
    _V(3.5, _markerY, -2),
  ),

  /// `#marker-tyre`, `ring-blue-500/50`; case C.
  tyre(
    'C',
    Icons.pedal_bike,
    _Colors.blue500,
    _V(-2.8, _markerY, 5),
    _V(-2.5, _markerY, 2.5),
  ),

  /// `#marker-bulb`, `ring-yellow-500/50`; case D.
  bulb(
    'D',
    Icons.lightbulb,
    _Colors.yellow500,
    _V(2.8, _markerY, 5),
    _V(2.5, _markerY, 2.5),
  ),

  /// `#marker-notepad`, `ring-indigo-500/30`, no label.
  notepad(
    '',
    Icons.edit_note,
    _Colors.indigo500,
    _V(0, _markerY, 0),
    _V(0, _markerY, 0),
  );

  const _Prop(this.id, this.icon, this.color, this.pos, this.htmlPos);

  /// HTML case id ('A' … 'D').
  final String id;

  /// Case selector icon (HTML Phosphor `pen-nib`, `cooking-pot`, `bicycle`,
  /// `lightbulb`).
  final IconData icon;

  /// Ring and glow colour of the marker card and its case button.
  final Color color;

  /// Where the marker stands on the desk. The HTML's places (in [htmlPos])
  /// put the front cards over most of the back ones; the rows are moved
  /// apart in depth so all four cards and labels show.
  final _V pos;

  /// The HTML `markerConfigs` position, used for the camera target.
  final _V htmlPos;

  static const List<_Prop> cases = [pen, cooker, tyre, bulb];

  bool get isCase => this != notepad;

  String get labelKey => 'case_${id}_lbl';

  /// Text key of this case's statement for [kind] (HTML `caseFiles`).
  String cardKey(_Kind kind) => 'card_$id${kind.index + 1}';

  /// `selectCase`: the camera target glides to (x / 2, y, z / 2).
  _V get look => _V(htmlPos.x * 0.5, htmlPos.y, htmlPos.z * 0.5);

  double get ringAlpha => isCase ? 0.5 : 0.3;
  double get glowAlpha => isCase ? 0.3 : 0.2;
}

/// The five steps of the scientific method (HTML `type`), in order.
enum _Kind {
  observe(Icons.visibility),
  question(Icons.help_outline),
  guess(Icons.lightbulb_outline),
  test(Icons.science),
  analyse(Icons.analytics);

  const _Kind(this.icon);

  /// Icon of the step in the Conclusion.
  final IconData icon;

  /// HTML `s2Tokens` text.
  String get tokenKey => 'token_$name';

  /// The type shown on a read-only row of Scenario 2.
  String get typeKey => 'type_$name';
}

/// HTML `s2Cases`: each case file of Scenario 2 and the step it misses.
const List<(_Prop, _Kind)> _s2Cases = [
  (_Prop.cooker, _Kind.test),
  (_Prop.tyre, _Kind.guess),
  (_Prop.bulb, _Kind.analyse),
  (_Prop.pen, _Kind.observe),
];

/// The four boxes of Scenario 3 (HTML `#s3-input-obs`, `-q`, `-guess`,
/// `-test`) and the message each gives when it is too short.
enum _Field {
  observation('err_obs_short'),
  question('err_q_short'),
  guess('err_guess_short'),
  test('err_test_short');

  const _Field(this.shortKey);

  final String shortKey;

  int get number => index + 1;
  String get labelKey => 's3_l$number';
  String get hintKey => 's3_h$number';
  String get placeholderKey => 'ph_$number';
}

/// HTML `getWordCount`: words separated by white space.
int _wordCount(String text) =>
    text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

/// Does [text] pass the HTML check of box [field]?
bool _fieldOk(_Field field, String text) =>
    _wordCount(text) >= _minWords &&
    (field != _Field.question || text.contains('?'));

/// A marker as laid out on the stage (HTML `.icon-marker`: the card with
/// its label chip below, centred on the projected point).
@immutable
class _MarkerBox {
  const _MarkerBox({
    required this.card,
    required this.k,
    required this.labelFont,
    required this.labelCenter,
  });

  /// The card (the photo fills it).
  final Rect card;

  /// Design px per CSS px of this marker.
  final double k;

  /// Label chip font size (design px) and the chip's centre.
  final double labelFont;
  final Offset labelCenter;

  /// The label chip for a label [textWidth] wide at the CSS font size.
  Rect chip(double textWidth) {
    final f = labelFont / _labelFontCss;
    final w = textWidth * f + 2 * _labelPadXCss * f;
    final h = (_labelLineCss + 2 * _labelPadYCss) * f;
    return Rect.fromCenter(center: labelCenter, width: w, height: h);
  }
}

/// Lays out [prop]'s marker for [cam]: HTML `scale = clamp(15 / distance,
/// 0.4, 1.5)`, grown with the framing zoom and [bounce]. Labels never get
/// smaller than [labelMin].
_MarkerBox _markerBox(
  _Cam cam,
  _Prop prop, {
  required double labelMin,
  double bounce = 1,
}) {
  final anchor = cam.p(prop.pos);
  final distance = (cam.eye - prop.pos).length;
  final scale = (_markerDistance / distance).clamp(
    _markerMinScale,
    _markerMaxScale,
  );
  final k = scale * _cssToDesign * cam.zoom * bounce;
  final w = _cardCssW * k;
  final h = _cardCssH * k;
  if (!prop.isCase) {
    return _MarkerBox(
      card: Rect.fromCenter(center: anchor, width: w, height: h),
      k: k,
      labelFont: 0,
      labelCenter: anchor,
    );
  }
  final font = math.max(_labelFontCss * k, labelMin * bounce);
  final chipH = (_labelLineCss + 2 * _labelPadYCss) * font / _labelFontCss;
  final gap = _labelGapCss * k;
  final top = anchor.dy - (h + gap + chipH) / 2;
  return _MarkerBox(
    card: Rect.fromLTWH(anchor.dx - w / 2, top, w, h),
    k: k,
    labelFont: font,
    labelCenter: Offset(anchor.dx, top + h + gap + chipH / 2),
  );
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;

  /// HTML `currentPhase` (0-based).
  int phase = 0;

  /// The prop of the case being worked on (HTML `selectCase` / `renderS2`
  /// highlight); the others are dimmed.
  _Prop active = _Prop.pen;

  /// HTML `camera.position` and `controls.target`.
  final _Tween3 eye = _Tween3(_eyeDesk);
  final _Tween3 target = _Tween3(_V.zero);

  /// The prop bouncing after a correct VERIFY, and since when.
  _Prop? bounceProp;
  double bounceStart = -1;

  /// Smallest label font (design px) for the current stage scale.
  double labelMin = _labelPx;

  /// Something changed since the last paint. The desk is still most of the
  /// time, so the canvas repaints only then and while [animating].
  bool dirty = true;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// A camera tween, the bounce or a re-framing is running.
  bool get animating =>
      !eye.done(time) ||
      !target.done(time) ||
      _framingT < 1 ||
      (bounceStart >= 0 && time - bounceStart < _bounceHalf * _bounceRuns);

  /// HTML `loadPhase`: markers shown in each phase (the notepad only in
  /// Scenario 3).
  bool shows(_Prop p) => phase == 2 ? p == _Prop.notepad : p.isCase;

  /// Full colour (HTML `grayscale(0) brightness(1)`) or dimmed.
  bool lit(_Prop p) => phase == 2 || p == active;

  /// HTML GSAP scale tween on the solved case's marker.
  double bounce(_Prop p) {
    if (p != bounceProp || bounceStart < 0) return 1;
    final t = time - bounceStart;
    if (t >= _bounceHalf * _bounceRuns) return 1;
    final run = (t / _bounceHalf).floor();
    final local = (t - run * _bounceHalf) / _bounceHalf;
    // Yoyo runs play the tween backwards.
    final e = run.isEven ? _power1Out(local) : _power1Out(1 - local);
    return 1 + (_bounceScale - 1) * e;
  }

  void startBounce(_Prop p) {
    bounceProp = p;
    bounceStart = time;
  }

  /// Glides the camera ([eyeTo] / [targetTo]) like the HTML `gsap.to`.
  void moveCamera({_V? eyeTo, _V? targetTo, double seconds = _cameraSeconds}) {
    if (eyeTo != null) eye.animate(time, eyeTo, seconds);
    if (targetTo != null) target.animate(time, targetTo, seconds);
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(eye.at(time), target.at(time), framing);

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
      dirty = true;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// Full reset: HTML camera at (0, 8, 20) looking at the origin.
  void reset() {
    phase = 0;
    active = _Prop.pen;
    eye.snap(_eyeDesk);
    target.snap(_V.zero);
    bounceProp = null;
    bounceStart = -1;
  }

  // ------------------------------------------ plain readouts for the tests

  /// Design rect of [p]'s card now (empty when the marker is hidden).
  Rect cardRect(_Prop p) => shows(p)
      ? _markerBox(camera(), p, labelMin: labelMin, bounce: bounce(p)).card
      : Rect.zero;
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

/// The panel's scale for a panel [width] px wide.
double _panelScale(double width) =>
    (width / _panelRef).clamp(_panelScaleMin, _panelScaleMax);

/// A card of Scenario 1 being dragged, and the slot it was taken from.
typedef _CardDrag = ({_Kind card, int? from});

class _ScientificThinkingLabState
    extends State<Ch1A3ApplyingScientificThinkingPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final math.Random _random = math.Random();
  final ScrollController _scroll = ScrollController();
  final List<TextEditingController> _fields = [
    for (final _ in _Field.values) TextEditingController(),
  ];
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), the workspace panel
  /// and its scrolling part, measured to fit the scene beside the panel and
  /// to scroll the panel while a card is dragged.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch1-a3-canvas');
  final GlobalKey _panelKey = GlobalKey(debugLabel: 'ch1-a3-panel');
  final GlobalKey _scrollKey = GlobalKey(debugLabel: 'ch1-a3-scroll');

  // ---------------------------------------------------------------- phases

  /// HTML `currentPhase` (0-based) and `passedPhases`.
  int _phase = 0;
  final List<bool> _passed = [false, false, false];

  /// VERIFY shows 'CORRECT!' (HTML: 1.5 s before the next phase).
  bool _correct = false;

  // ------------------------------------------------- Scenario 1: s1State

  /// HTML `s1State.case`, its shuffled tray and `s1State.placements`.
  _Prop _case = _Prop.pen;
  List<_Kind> _tray = List.of(_Kind.values);
  final List<_Kind?> _slots = List.filled(_slotCount, null);

  /// The card tapped in the tray, waiting for a slot to be tapped (added:
  /// tap-to-place besides dragging).
  _Kind? _pickedCard;

  /// The slot a card is being dragged out of (it looks empty meanwhile).
  int? _draggingFrom;

  // ------------------------------------------------- Scenario 2: s2State

  /// HTML `s2State.caseIndex` and `s2State.placements`.
  int _s2Index = 0;
  final List<_Kind?> _s2Placed = List.filled(_s2CaseCount, null);

  /// The step token tapped in the tray (added, as [_pickedCard]).
  _Kind? _pickedToken;

  // ------------------------------------------------------------ Scenario 3

  /// Boxes marked red by the last VERIFY (HTML `.s3-input.error`).
  final Set<_Field> _s3Errors = {};

  // -------------------------------------------------------------- framing

  /// Where the pointer of a running drag is (global), for auto-scrolling.
  Offset? _dragPointer;

  /// The scene was animating at the last frame.
  bool _wasMoving = true;
  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_phase];

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
    for (final field in _fields) {
      field.addListener(_onTyping);
    }
    _tray.shuffle(_random);
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
    _scroll.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()` + GSAP's ticker: camera tweens, the bounce, the
  /// framing, auto-scroll while dragging; then one repaint of the canvas
  /// while anything moves (and one more for its final state).
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
    _autoScroll(dt);
    final moving = s.animating;
    if (moving || _wasMoving || s.dirty) {
      s.dirty = false;
      _frame.value = now;
    }
    _wasMoving = moving;
  }

  /// Scrolls the workspace while a dragged card is held near its top or
  /// bottom edge, so every slot can be reached on a short screen.
  void _autoScroll(double dt) {
    final pointer = _dragPointer;
    if (pointer == null || !_scroll.hasClients) return;
    final box = _scrollKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    final local = box.globalToLocal(pointer);
    if (local.dx < 0 || local.dx > box.size.width) return;
    final h = box.size.height;
    var speed = 0.0;
    if (local.dy < _scrollEdge) {
      speed = -_scrollSpeed * (1 - (local.dy / _scrollEdge).clamp(0.0, 1.0));
    } else if (local.dy > h - _scrollEdge) {
      speed =
          _scrollSpeed * (1 - ((h - local.dy) / _scrollEdge).clamp(0.0, 1.0));
    }
    if (speed == 0) return;
    final position = _scroll.position;
    final next = (position.pixels + speed * dt).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (next != position.pixels) _scroll.jumpTo(next);
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (panel and canvas are laid out by
  /// then). [snap] jumps there instead of sliding.
  void _scheduleFraming({bool snap = false}) {
    if (snap) _snapFraming = true;
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the props (or the notepad) into the part of the canvas left of
  /// the workspace panel, clear of the floating mission card while the
  /// sidebar is collapsed.
  void _updateFraming() {
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
    final labelMin =
        _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
    if (labelMin != _scene.labelMin) {
      _scene
        ..labelMin = labelMin
        ..dirty = true;
    }
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
    final panel = _panelKey.currentContext?.findRenderObject();
    final panelLeft = panel is RenderBox && panel.hasSize && panel.attached
        ? panel.localToGlobal(Offset.zero).dx - origin.dx
        : size.width - insets.right - _panelWidth(size.width, insets.right);
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      panelLeft - _cardGap,
      size.height - 8 - pad.bottom,
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
    final target = _fitFraming(_focusItems(), toDesign(free), [
      for (final r in hard) toDesign(r.inflate(_cardGap)),
    ], _maxZoom[_scene.phase]);
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

  /// What the learner must see: the cards and label chips of the props
  /// (HTML camera, zoom 1) for every camera target `selectCase` can glide
  /// to, so the solved case never pushes another card under the panel; in
  /// Scenario 3 the notepad seen from the close-up camera.
  List<_Focus> _focusItems() {
    final items = <_Focus>[];
    void marker(_Cam cam, _Prop prop) {
      final box = _markerBox(cam, prop, labelMin: _scene.labelMin);
      final card = box.card;
      items
        ..add((card.topLeft, Rect.zero))
        ..add((card.bottomRight, Rect.zero));
      if (prop.isCase) {
        final chip = box.chip(
          _cache.width(_t(prop.labelKey).toUpperCase(), _lab.isDark),
        );
        items
          ..add((chip.topLeft, Rect.zero))
          ..add((chip.bottomRight, Rect.zero));
      }
    }

    if (_scene.phase == 2) {
      marker(_Cam(_eyeNotepad, _V.zero, _Framing.base), _Prop.notepad);
    } else {
      for (final look in [_V.zero, for (final c in _Prop.cases) c.look]) {
        final cam = _Cam(_eyeDesk, look, _Framing.base);
        for (final c in _Prop.cases) {
          marker(cam, c);
        }
      }
    }
    return items;
  }

  /// Width of the workspace panel on a canvas [canvasWidth] wide, left of
  /// the tool column ([right]).
  double _panelWidth(double canvasWidth, double right) {
    final room = math.max(0.0, canvasWidth - right - 12);
    return (canvasWidth * _panelShare).clamp(
      math.min(_panelMin, room),
      math.min(_panelMax, room),
    );
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `loadPhase(phase)`: Scenario 1 re-selects its case (clearing
  /// the slots) and glides the camera back over the desk; Scenario 2 keeps
  /// its placements; Scenario 3 closes in on the notepad.
  void _loadScenario(int index, {bool snap = false}) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _phase = index;
      _scene.phase = index;
      _correct = false;
      _pickedCard = null;
      _pickedToken = null;
      _draggingFrom = null;
      _dragPointer = null;
      _cardRect = null;
      switch (index) {
        case 0:
          _applyCase(_case);
          // GSAP: the 1 s tween to the origin outlives `selectCase`'s.
          _scene.moveCamera(eyeTo: _eyeDesk, targetTo: _V.zero);
        case 1:
          _scene.active = _s2Cases[_s2Index].$1;
        default:
          _scene.moveCamera(eyeTo: _eyeNotepad, targetTo: _V.zero);
      }
    });
    _lab.resetView(sound: false);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _scheduleFraming(snap: snap);
  }

  /// HTML `enterLab()`: Scenario 1 with the scene in place.
  void _enterLab() => _loadScenario(0, snap: true);

  /// HTML `location.reload()` (the reset button and 'RESTART LAB'): every
  /// phase back to its start.
  void _fullReset() {
    _passed.fillRange(0, _passed.length, false);
    _case = _Prop.pen;
    _s2Index = 0;
    _s2Placed.fillRange(0, _s2CaseCount, null);
    for (final field in _fields) {
      field.clear();
    }
    _s3Errors.clear();
    _scene.reset();
    _loadScenario(0, snap: true);
  }

  /// The step ladder of each phase: the first empty slot / case file / box
  /// that does not pass its check, then VERIFY; steps.length + 1 once the
  /// phase is passed.
  int _deriveStep() {
    final total = _stepCounts[_phase];
    final done = _passed[_phase] ? total + 1 : total;
    switch (_phase) {
      case 0:
        final empty = _slots.indexOf(null);
        return empty >= 0 ? empty + 1 : done;
      case 1:
        final open = _s2Placed.indexOf(null);
        return open >= 0 ? open + 1 : done;
      default:
        for (final f in _Field.values) {
          if (!_fieldOk(f, _fields[f.index].text)) return f.number;
        }
        return done;
    }
  }

  /// The teacher-board paragraph the current step is about (S1 slots, S3
  /// boxes).
  int? _fiveStepsFocus(int step) => switch (_phase) {
    0 when step <= _slotCount => step,
    2 when step <= _fieldCount => step,
    _ => null,
  };

  void _onTyping() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------- Scenario 1 logic

  /// HTML `selectCase(cId)`.
  void _onCaseTap(_Prop c) {
    if (_correct) return;
    _Sound.click.play();
    setState(() => _applyCase(c));
  }

  /// Picks case [c]: empty slots, a freshly shuffled tray, its prop lit
  /// and the camera target gliding towards it.
  void _applyCase(_Prop c) {
    _case = c;
    _slots.fillRange(0, _slotCount, null);
    _pickedCard = null;
    _tray = List.of(_Kind.values)..shuffle(_random);
    _scene
      ..active = c
      ..moveCamera(targetTo: c.look, seconds: _caseSeconds);
  }

  /// HTML `pointerup` over a dropzone: a full slot sends the card back to
  /// the tray ('Slot already taken!'). A card taken from a slot left it
  /// when it was picked up.
  void _onCardDrop(_CardDrag drag, int slot) {
    if (_correct) return;
    _Sound.drop.play();
    setState(() {
      final from = drag.from;
      if (from != null) _slots[from] = null;
      if (_slots[slot] != null) {
        _lab.showToast(_t('slot_taken'), isError: true, sound: false);
      } else {
        _slots[slot] = drag.card;
      }
      _pickedCard = null;
    });
  }

  /// A card released away from the slots goes back to the tray.
  void _onCardMissed(_CardDrag drag) {
    final from = drag.from;
    if (from == null) return;
    setState(() => _slots[from] = null);
  }

  /// HTML `pointerdown` on a card (`drag` tone).
  void _onCardPickup(int? from) {
    _Sound.pickup.play();
    setState(() {
      _draggingFrom = from;
      _pickedCard = null;
    });
  }

  void _endDrag() {
    _dragPointer = null;
    if (_draggingFrom != null && mounted) {
      setState(() => _draggingFrom = null);
    }
  }

  /// Tap on a tray card: picks it (or puts it down again).
  void _onCardTap(_Kind card) {
    if (_correct) return;
    _Sound.pickup.play();
    setState(() => _pickedCard = _pickedCard == card ? null : card);
  }

  /// Tap on a slot: places the picked card; on a full slot without a
  /// picked card, sends its card back to the tray (HTML: a press on a
  /// placed card picks it up).
  void _onSlotTap(int slot) {
    if (_correct) return;
    final picked = _pickedCard;
    if (picked != null) {
      _onCardDrop((card: picked, from: null), slot);
    } else if (_slots[slot] != null) {
      _Sound.pickup.play();
      setState(() => _slots[slot] = null);
    } else {
      _lab.showToast(_t('pick_first_s1'), sound: false);
    }
  }

  // ---------------------------------------------------- Scenario 2 logic

  /// HTML `prevS2Case()` / `nextS2Case()`.
  void _onS2Nav(int delta) {
    _Sound.click.play();
    setState(() {
      _s2Index = (_s2Index + delta + _s2CaseCount) % _s2CaseCount;
      _scene.active = _s2Cases[_s2Index].$1;
    });
  }

  /// HTML `pointerup` over `#s2-blank`.
  void _onTokenDrop(_Kind token) {
    if (_correct) return;
    _Sound.drop.play();
    setState(() {
      if (_s2Placed[_s2Index] != null) {
        _lab.showToast(_t('slot_taken'), isError: true, sound: false);
      } else {
        _s2Placed[_s2Index] = token;
      }
      _pickedToken = null;
    });
  }

  void _onTokenPickup() {
    _Sound.pickup.play();
    setState(() => _pickedToken = null);
  }

  void _onTokenTap(_Kind token) {
    if (_correct) return;
    _Sound.pickup.play();
    setState(() => _pickedToken = _pickedToken == token ? null : token);
  }

  /// Tap on the blank slot: places the picked token, or removes the
  /// placed one (HTML `placed.onpointerdown`).
  void _onBlankTap() {
    if (_correct) return;
    final picked = _pickedToken;
    if (picked != null) {
      _onTokenDrop(picked);
    } else if (_s2Placed[_s2Index] != null) {
      _Sound.click.play();
      setState(() => _s2Placed[_s2Index] = null);
    } else {
      _lab.showToast(_t('pick_first_s2'), sound: false);
    }
  }

  // --------------------------------------------------------------- VERIFY

  /// HTML `checkVerifyState()`: all five slots, all four blanks, or any
  /// writing at all.
  bool get _canVerify => switch (_phase) {
    0 => !_slots.contains(null),
    1 => !_s2Placed.contains(null),
    _ => _fields.any((f) => f.text.trim().isNotEmpty),
  };

  /// HTML `verifyStep()`.
  void _verify() {
    if (_correct) return;
    _Sound.click.play();
    if (!_canVerify) {
      _lab.showToast(_t('complete_first'), isError: true, sound: false);
      return;
    }
    final error = switch (_phase) {
      0 => _checkOrder(),
      1 => _checkMissing(),
      _ => _checkWhy(),
    };
    if (error != null) {
      // HTML `playSound('error')` + `showToast`.
      _lab.showToast(error, isError: true);
      return;
    }
    _onCorrect();
  }

  /// HTML VR `crack-the-case-step-order` with the sub-check
  /// `guess-tested-before-concluding`.
  String? _checkOrder() {
    var inOrder = true;
    for (var i = 0; i < _slotCount; i++) {
      if (_slots[i] != _Kind.values[i]) inOrder = false;
    }
    if (inOrder) return null;
    final g = _slots.indexOf(_Kind.guess);
    final t = _slots.indexOf(_Kind.test);
    final a = _slots.indexOf(_Kind.analyse);
    return _t(g > t || t > a ? 'err_guess_order' : 'err_order');
  }

  /// HTML VR `spot-the-missing-step`.
  String? _checkMissing() {
    var wrong = 0;
    for (var i = 0; i < _s2CaseCount; i++) {
      if (_s2Placed[i] != _s2Cases[i].$2) wrong++;
    }
    return wrong == 0 ? null : labFormat(_t('err_s2'), {'n': wrong});
  }

  /// HTML VR `your-own-why-structural-predicate`: at least three words in
  /// each box and a '?' in the question; the first problem is reported.
  String? _checkWhy() {
    final errors = <String>[];
    setState(() {
      _s3Errors.clear();
      for (final f in _Field.values) {
        final text = _fields[f.index].text;
        if (_wordCount(text) < _minWords) {
          _s3Errors.add(f);
          errors.add(_t(f.shortKey));
        }
        if (f == _Field.question && !text.contains('?')) {
          _s3Errors.add(f);
          errors.add(_t('err_q_mark'));
        }
      }
    });
    if (errors.isEmpty) return null;
    return labFormat(_t('err_expand'), {'error': errors.first});
  }

  /// HTML `isCorrect`: 'CORRECT!' for 1.5 s (Scenario 1 also bounces the
  /// case's prop), then the next phase, or the Conclusion after Scenario 3.
  void _onCorrect() {
    final phase = _phase;
    _Sound.correct.play();
    setState(() {
      _passed[phase] = true;
      _correct = true;
      _pickedCard = null;
      _pickedToken = null;
      if (phase < 2) _lab.completedScenarios.add(phase);
      if (phase == 0) _scene.startBounce(_case);
    });
    _lab.after(_correctHold, () {
      if (!mounted || _phase != phase) return;
      setState(() => _correct = false);
      if (phase < 2) {
        _loadScenario(phase + 1);
      } else {
        _showFinal();
      }
    });
  }

  /// HTML `showFinal()`: the Conclusion with 'RESTART LAB'.
  void _showFinal() {
    _lab.showScenarioConclusion(
      scenarioIndex: 2,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _t('conclusion_title'),
      heading: () => _t('app_title'),
      body: () => _t('conclusion_text'),
      extra: () => Builder(
        builder: (context) => _ConclusionVisual(
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
        ),
      ),
    );
  }

  /// HTML `prevPhase()` / `nextPhase()` (next only once passed).
  void _prevPhase() {
    if (_phase == 0) return;
    _Sound.click.play();
    _loadScenario(_phase - 1);
  }

  void _nextPhase() {
    if (_phase >= 2 || !_passed[_phase]) return;
    _Sound.click.play();
    _loadScenario(_phase + 1);
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
        final step = _deriveStep();
        // Any state change (case, phase, language, theme…) repaints the desk
        // once.
        _scene.dirty = true;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [
            for (var n = 1; n <= _stepCounts.length; n++) _t('sc${n}_title'),
          ],
          scenarioIndex: _phase,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          // The workspace panel shows the current task (HTML `curr_obj`).
          showHud: false,
          onEnterLab: _enterLab,
          onReset: _fullReset,
          sidebarExtraTitle: _t('taskInstr'),
          sidebarExtra: _FiveSteps(
            lines: [for (var i = 1; i <= _slotCount; i++) _t('sb_step_$i')],
            focus: _fiveStepsFocus(step),
            palette: p,
            scale: s,
            fontScale: f,
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#workspace-panel`; full size so the shell keeps it in
            // place, only the panel itself takes touches.
            Positioned.fill(child: _workspace(context, p, step, data)),
          ],
          stage: _stage(),
        );
      },
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: Semantics(
            image: true,
            label: _t(_phase == 2 ? 'scene_notepad' : 'scene_desk'),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------- workspace

  /// HTML `#workspace-panel` on the right of the canvas, next to the tool
  /// column (the shell's sidebar and mission card take the left).
  Widget _workspace(
    BuildContext context,
    LabPalette p,
    int step,
    LabScenarioData data,
  ) {
    final insets = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final width = _panelWidth(box.maxWidth, insets.right);
        final ps = _panelScale(width);
        final height = box.maxHeight - 16 - pad.vertical;
        return Padding(
          padding: EdgeInsets.only(
            top: 8 + pad.top,
            bottom: 8 + pad.bottom,
            right: insets.right,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              key: _panelKey,
              width: width,
              height: double.infinity,
              child: _panel(
                p,
                ps,
                step,
                data,
                compact: height < _compactPanelBelow,
              ),
            ),
          ),
        );
      },
    );
  }

  /// The panel: step header and current task (scrolling with the phase's
  /// content on a [compact] panel, so a phone keeps room for the slots),
  /// the phase's content, and the footer, always in view.
  Widget _panel(
    LabPalette p,
    double ps,
    int step,
    LabScenarioData data, {
    required bool compact,
  }) {
    final dark = p.isDark;
    final content = switch (_phase) {
      0 => _s1(p, ps),
      1 => _s2(p, ps),
      _ => _s3(p, ps),
    };
    final inset = EdgeInsets.fromLTRB(14 * ps, 12 * ps, 14 * ps, 16 * ps);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // bg-white/90 dark:bg-slate-900/90 glass-panel.
        color: dark ? const Color(0xE60F172A) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(16 * ps),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate300),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[_panelHeader(p, ps), _taskLine(p, ps, step, data)],
          Expanded(
            child: SingleChildScrollView(
              key: _scrollKey,
              controller: _scroll,
              padding: compact ? EdgeInsets.only(bottom: inset.bottom) : inset,
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _panelHeader(p, ps),
                        _taskLine(p, ps, step, data),
                        Padding(
                          padding: inset.copyWith(bottom: 0),
                          child: content,
                        ),
                      ],
                    )
                  : content,
            ),
          ),
          _footer(p, ps),
        ],
      ),
    );
  }

  /// HTML HUD: 'STEP n/3' and the milestone ribbon.
  Widget _panelHeader(LabPalette p, double ps) {
    final dark = p.isDark;
    final label = '${_t('step_prefix')} ${_phase + 1}/${_stepCounts.length}';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * ps, vertical: 7 * ps),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dark ? _Colors.slate800 : _Colors.slate200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * ps, vertical: 4 * ps),
            decoration: BoxDecoration(
              color: dark
                  ? _Colors.indigo900.withValues(alpha: 0.4)
                  : _Colors.indigo100,
              borderRadius: BorderRadius.circular(6 * ps),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: _Colors.indigo500,
                fontSize: 11 * ps,
                fontWeight: FontWeight.w900,
                letterSpacing: labLetterSpacing(label, 1.5),
              ),
            ),
          ),
          const Spacer(),
          for (var i = 0; i < _stepCounts.length; i++)
            Container(
              width: 26 * ps,
              height: 5 * ps,
              margin: EdgeInsets.only(left: 4 * ps),
              decoration: BoxDecoration(
                color: i <= _phase
                    ? _Colors.indigo500
                    : (dark ? _Colors.slate700 : _Colors.slate300),
                borderRadius: BorderRadius.circular(5 * ps),
              ),
            ),
        ],
      ),
    );
  }

  /// The current step (added; labelled with the HTML's 'Current Task').
  Widget _taskLine(LabPalette p, double ps, int step, LabScenarioData data) {
    final steps = data.steps;
    final i = (step - 1).clamp(0, steps.length - 1);
    final label = _t('curr_task').toUpperCase();
    final count = '${_lab.t('step')} ${i + 1}/${steps.length}';
    return Container(
      margin: EdgeInsets.fromLTRB(12 * ps, 10 * ps, 12 * ps, 0),
      padding: EdgeInsets.fromLTRB(10 * ps, 8 * ps, 10 * ps, 9 * ps),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12 * ps),
        border: Border.all(color: p.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 13 * ps, color: p.accentInk),
              SizedBox(width: 4 * ps),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.accentInk,
                    fontSize: 9.5 * ps,
                    fontWeight: FontWeight.w800,
                    letterSpacing: labLetterSpacing(label, 1),
                  ),
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 9.5 * ps,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 3 * ps),
          Text(
            steps[i].action,
            key: const ValueKey('ch1a3-task'),
            style: TextStyle(
              color: p.textStrong,
              fontSize: 11.5 * ps,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// HTML workspace footer: previous phase, VERIFY, next phase.
  Widget _footer(LabPalette p, double ps) {
    final dark = p.isDark;
    final canNext = _phase < 2 && _passed[_phase];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * ps, vertical: 6 * ps),
      decoration: BoxDecoration(
        color: dark ? const Color(0xF20F172A) : const Color(0xF2F8FAFC),
        border: Border(
          top: BorderSide(color: dark ? _Colors.slate800 : _Colors.slate200),
        ),
      ),
      child: Row(
        children: [
          _navButton(
            p,
            ps,
            key: 'ch1a3-prev',
            icon: Icons.chevron_left,
            tooltip: _t('prev_phase'),
            onTap: _phase > 0 ? _prevPhase : null,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 220 * ps),
                child: _verifyButton(ps),
              ),
            ),
          ),
          _navButton(
            p,
            ps,
            key: 'ch1a3-next',
            icon: Icons.chevron_right,
            tooltip: _t('next_phase'),
            onTap: canNext ? _nextPhase : null,
          ),
        ],
      ),
    );
  }

  /// A round grey arrow button (HTML `#btn-prev`, `#btn-next` and the
  /// Scenario 2 case arrows); dimmed while it does nothing.
  Widget _navButton(
    LabPalette p,
    double ps, {
    required String key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    bool round = false,
  }) {
    final dark = p.isDark;
    final radius = round ? 999.0 : 12 * ps;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: dark ? _Colors.slate700 : _Colors.slate200,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            key: ValueKey(key),
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: SizedBox.square(
              dimension: math.max(kMinInteractiveDimension, 44 * ps),
              child: Icon(
                icon,
                size: 22 * ps,
                color: dark ? _Colors.slate300 : _Colors.slate700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#btn-submit`: indigo gradient, dimmed until the task is done
  /// (still tappable: 'Please complete the task first!'), emerald with
  /// 'CORRECT!' after a right answer.
  Widget _verifyButton(double ps) {
    final correct = _correct;
    final ready = _canVerify || correct;
    final radius = BorderRadius.circular(12 * ps);
    final label = correct ? _t('correct_btn') : _t('verify');
    return Opacity(
      opacity: ready ? 1 : 0.5,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            color: correct ? _Colors.emerald500 : null,
            gradient: correct
                ? null
                : const LinearGradient(
                    colors: [_Colors.indigo600, _Colors.indigo500],
                  ),
            borderRadius: radius,
            border: Border.all(
              color: correct ? _Colors.emerald400 : LabInk.clear,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (correct ? _Colors.emerald500 : _Colors.indigo500)
                    .withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            key: const ValueKey('ch1a3-verify'),
            borderRadius: radius,
            onTap: _verify,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * ps,
                  vertical: 10 * ps,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (correct) ...[
                      Icon(
                        Icons.check_circle,
                        size: 20 * ps,
                        color: _Colors.white,
                      ),
                      SizedBox(width: 6 * ps),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _Colors.white,
                          fontSize: 14 * ps,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(label, 0.6),
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
    );
  }

  /// A phase's heading and description (HTML `sN_title`, `sN_desc`).
  Widget _heading(LabPalette p, double ps, int n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('s${n}_title'),
          style: TextStyle(
            color: p.textStrong,
            fontSize: 16 * ps,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4 * ps),
        Text(
          _t('s${n}_desc'),
          style: TextStyle(
            color: p.isDark ? _Colors.slate400 : _Colors.slate600,
            fontSize: 12 * ps,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Small italic hint under a tray (added).
  Widget _trayHint(LabPalette p, double ps, String key) => Text(
    _t(key),
    textAlign: TextAlign.center,
    style: TextStyle(
      color: p.textMuted,
      fontSize: 10 * ps,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
  );

  /// The lifted copy of a card or token that follows the finger (HTML
  /// clone: `scale-105 shadow-2xl opacity-90`).
  Widget _feedback(Widget face, {double? width}) => Material(
    type: MaterialType.transparency,
    child: SizedBox(
      width: width,
      child: Transform.scale(
        scale: 1.05,
        child: Opacity(opacity: 0.9, child: face),
      ),
    ),
  );

  // ----------------------------------------------- Scenario 1: Crack the Case

  Widget _s1(LabPalette p, double ps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(p, ps, 1),
        SizedBox(height: 12 * ps),
        _caseSelector(p, ps),
        SizedBox(height: 12 * ps),
        for (var i = 0; i < _slotCount; i++) ...[
          if (i > 0) SizedBox(height: 6 * ps),
          _slotRow(p, ps, i),
        ],
        SizedBox(height: 14 * ps),
        _cardTray(p, ps),
      ],
    );
  }

  /// HTML case selector: the active case in colour, raised, with an
  /// indigo glow; the others grey and faded.
  Widget _caseSelector(LabPalette p, double ps) {
    final dark = p.isDark;
    return Container(
      padding: EdgeInsets.all(6 * ps),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate800 : _Colors.slate100,
        borderRadius: BorderRadius.circular(12 * ps),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
      ),
      child: Row(
        children: [
          for (final c in _Prop.cases) ...[
            if (c.index > 0) SizedBox(width: 6 * ps),
            Expanded(child: _caseButton(p, ps, c)),
          ],
        ],
      ),
    );
  }

  Widget _caseButton(LabPalette p, double ps, _Prop c) {
    final dark = p.isDark;
    final active = c == _case;
    final label = _t(c.labelKey);
    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 4 * ps, horizontal: 2 * ps),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate700 : _Colors.white,
        borderRadius: BorderRadius.circular(8 * ps),
        border: Border.all(
          color: active ? _Colors.indigo500 : LabInk.clear,
          width: 2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _Colors.indigo500.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 18 * ps, color: c.color),
          SizedBox(height: 2 * ps),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 10 * ps,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      onTap: () => _onCaseTap(c),
      child: GestureDetector(
        key: ValueKey('ch1a3-case-${c.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _onCaseTap(c),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: AnimatedScale(
            scale: active ? 1.08 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: active ? 1 : 0.6,
              duration: const Duration(milliseconds: 200),
              child: active
                  ? face
                  : ColorFiltered(colorFilter: _grayFilter, child: face),
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-slot-N`: a square dropzone with a dashed target circle and
  /// the slot's hint ('1. What did you notice?', shown here as the HTML
  /// hover tooltip cannot show on touch) above 'Drop the matching step
  /// here...'. A placed card fills the row and can be dragged on again.
  Widget _slotRow(LabPalette p, double ps, int slot) {
    final card = _slots[slot];
    final filled = card != null && _draggingFrom != slot;
    return DragTarget<_CardDrag>(
      onWillAcceptWithDetails: (_) => !_correct,
      onAcceptWithDetails: (d) => _onCardDrop(d.data, slot),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        return Semantics(
          label: labFormat(_t('slot_label'), {'n': slot + 1}),
          hint: _t('slot_hint_${slot + 1}'),
          value: card != null && filled ? _t(_case.cardKey(card)) : '',
          button: true,
          excludeSemantics: true,
          onTap: () => _onSlotTap(slot),
          child: GestureDetector(
            key: ValueKey('ch1a3-slot-${slot + 1}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _onSlotTap(slot),
            child: Row(
              children: [
                _SlotSquare(
                  number: slot + 1,
                  filled: filled,
                  hover: hover,
                  waiting: _pickedCard != null && !filled,
                  dark: p.isDark,
                  scale: ps,
                ),
                SizedBox(width: 10 * ps),
                Expanded(
                  child: card == null
                      ? _slotHint(p, ps, slot, hover: hover)
                      : _placedCard(p, ps, slot, card),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slotHint(LabPalette p, double ps, int slot, {bool hover = false}) {
    final dark = p.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: BoxConstraints(minHeight: 46 * ps),
      padding: EdgeInsets.symmetric(horizontal: 10 * ps, vertical: 6 * ps),
      decoration: BoxDecoration(
        color: dark
            ? _Colors.slate800.withValues(alpha: 0.6)
            : _Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12 * ps),
        border: Border.all(
          color: hover
              ? _Colors.indigo400
              : (dark
                    ? _Colors.slate700.withValues(alpha: 0.8)
                    : _Colors.slate200.withValues(alpha: 0.8)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('slot_hint_${slot + 1}'),
            style: TextStyle(
              color: dark ? _Colors.slate300 : _Colors.slate600,
              fontSize: 11 * ps,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          SizedBox(height: 1 * ps),
          Text(
            _t('drop_hint'),
            style: TextStyle(
              color: _Colors.slate400,
              fontSize: 10.5 * ps,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  /// A card in a slot (HTML `placeCardVisual`): dragging it lifts it out
  /// again, a tap sends it back to the tray.
  Widget _placedCard(LabPalette p, double ps, int slot, _Kind card) {
    final face = _PlacedFace(
      text: _t(_case.cardKey(card)),
      dark: p.isDark,
      scale: ps,
    );
    return LayoutBuilder(
      builder: (context, box) => Draggable<_CardDrag>(
        key: ValueKey('ch1a3-placed-${slot + 1}'),
        data: (card: card, from: slot),
        maxSimultaneousDrags: _correct ? 0 : 1,
        onDragStarted: () => _onCardPickup(slot),
        onDragUpdate: (d) => _dragPointer = d.globalPosition,
        onDragEnd: (_) => _endDrag(),
        onDraggableCanceled: (_, _) => _onCardMissed((card: card, from: slot)),
        feedback: _feedback(
          _CardFace(
            text: _t(_case.cardKey(card)),
            dark: p.isDark,
            scale: ps,
            lifted: true,
          ),
          width: box.maxWidth,
        ),
        childWhenDragging: _slotHint(p, ps, slot),
        child: face,
      ),
    );
  }

  /// HTML `#s1-tray`: the case's statements, shuffled, two to a row.
  Widget _cardTray(LabPalette p, double ps) {
    final dark = p.isDark;
    final cards = [
      for (final k in _tray)
        if (!_slots.contains(k)) k,
    ];
    final gap = 8 * ps;
    return Container(
      constraints: BoxConstraints(minHeight: 100 * ps),
      padding: EdgeInsets.all(10 * ps),
      decoration: BoxDecoration(
        color: dark
            ? _Colors.slate800.withValues(alpha: 0.8)
            : _Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12 * ps),
        border: Border.all(color: dark ? _Colors.slate600 : _Colors.slate300),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final half = (box.maxWidth - gap) / 2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i += 2) ...[
                if (i > 0) SizedBox(height: gap),
                if (i + 1 < cards.length)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _trayCard(p, ps, cards[i], half)),
                        SizedBox(width: gap),
                        Expanded(child: _trayCard(p, ps, cards[i + 1], half)),
                      ],
                    ),
                  )
                else
                  _trayCard(p, ps, cards[i], box.maxWidth),
              ],
              if (cards.isNotEmpty) SizedBox(height: 8 * ps),
              _trayHint(p, ps, 'tray_hint_s1'),
            ],
          );
        },
      ),
    );
  }

  Widget _trayCard(LabPalette p, double ps, _Kind card, double width) {
    final text = _t(_case.cardKey(card));
    final face = _CardFace(
      text: text,
      dark: p.isDark,
      scale: ps,
      picked: _pickedCard == card,
    );
    return Draggable<_CardDrag>(
      key: ValueKey('ch1a3-card-${_case.id}${card.index + 1}'),
      data: (card: card, from: null),
      maxSimultaneousDrags: _correct ? 0 : 1,
      onDragStarted: () => _onCardPickup(null),
      onDragUpdate: (d) => _dragPointer = d.globalPosition,
      onDragEnd: (_) => _endDrag(),
      feedback: _feedback(
        _CardFace(text: text, dark: p.isDark, scale: ps, lifted: true),
        width: width,
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: face),
      child: Semantics(
        button: true,
        selected: _pickedCard == card,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onCardTap(card),
          child: face,
        ),
      ),
    );
  }

  // ---------------------------------------- Scenario 2: Spot the Missing Step

  Widget _s2(LabPalette p, double ps) {
    final (prop, missing) = _s2Cases[_s2Index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(p, ps, 2),
        SizedBox(height: 10 * ps),
        _caseNav(p, ps, prop),
        SizedBox(height: 8 * ps),
        for (final kind in _Kind.values) ...[
          if (kind.index > 0) SizedBox(height: 6 * ps),
          if (kind == missing)
            _blankRow(p, ps)
          else
            _readRow(p, ps, prop, kind),
        ],
        SizedBox(height: 14 * ps),
        _tokenTray(p, ps),
      ],
    );
  }

  /// HTML case arrows and 'Case n/4' (with the case's icon and name,
  /// added).
  Widget _caseNav(LabPalette p, double ps, _Prop prop) {
    final caseText = '${_t('case_indicator')} ${_s2Index + 1}/$_s2CaseCount';
    return Row(
      children: [
        _navButton(
          p,
          ps,
          key: 'ch1a3-case-prev',
          icon: Icons.chevron_left,
          tooltip: _t('prev_case'),
          onTap: () => _onS2Nav(-1),
          round: true,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                caseText,
                key: const ValueKey('ch1a3-case-num'),
                style: TextStyle(
                  color: _Colors.indigo500,
                  fontSize: 13 * ps,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8 * ps),
              Icon(prop.icon, size: 16 * ps, color: prop.color),
              SizedBox(width: 3 * ps),
              Flexible(
                child: Text(
                  _t(prop.labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12 * ps,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        _navButton(
          p,
          ps,
          key: 'ch1a3-case-next',
          icon: Icons.chevron_right,
          tooltip: _t('next_case'),
          onTap: () => _onS2Nav(1),
          round: true,
        ),
      ],
    );
  }

  /// A read-only step of the case file: its type and the case's text.
  Widget _readRow(LabPalette p, double ps, _Prop prop, _Kind kind) {
    final dark = p.isDark;
    final type = _t(kind.typeKey).toUpperCase();
    return Opacity(
      opacity: 0.9,
      child: Container(
        padding: EdgeInsets.all(9 * ps),
        decoration: BoxDecoration(
          color: dark
              ? _Colors.slate800.withValues(alpha: 0.6)
              : _Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12 * ps),
          border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
        ),
        child: Row(
          children: [
            Container(
              width: 84 * ps,
              height: 36 * ps,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4 * ps),
              decoration: BoxDecoration(
                color: dark
                    ? _Colors.slate700.withValues(alpha: 0.5)
                    : _Colors.slate200.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8 * ps),
                border: Border.all(
                  color: dark
                      ? _Colors.slate600.withValues(alpha: 0.5)
                      : _Colors.slate300.withValues(alpha: 0.5),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  type,
                  style: TextStyle(
                    color: dark ? _Colors.slate400 : _Colors.slate500,
                    fontSize: 10.5 * ps,
                    fontWeight: FontWeight.w900,
                    letterSpacing: labLetterSpacing(type, 1),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * ps),
            Expanded(
              child: Text(
                _t(prop.cardKey(kind)),
                style: TextStyle(
                  color: dark ? _Colors.slate300 : _Colors.slate700,
                  fontSize: 12 * ps,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `#s2-blank` row: a dashed indigo row with the dropzone, 'Which
  /// step is missing?' and its hint (shown, not hovered).
  Widget _blankRow(LabPalette p, double ps) {
    final dark = p.isDark;
    final placed = _s2Placed[_s2Index];
    return DragTarget<_Kind>(
      onWillAcceptWithDetails: (_) => !_correct,
      onAcceptWithDetails: (d) => _onTokenDrop(d.data),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        final waiting = _pickedToken != null && placed == null;
        final zoneBorder = hover || waiting
            ? _Colors.indigo500
            : (dark ? _Colors.indigo800 : _Colors.indigo200);
        return Semantics(
          label: _t('blank_label'),
          hint: _t('missing_step'),
          value: placed == null ? '' : _t(placed.tokenKey),
          button: true,
          excludeSemantics: true,
          onTap: _onBlankTap,
          child: GestureDetector(
            key: const ValueKey('ch1a3-blank'),
            behavior: HitTestBehavior.opaque,
            onTap: _onBlankTap,
            child: CustomPaint(
              foregroundPainter: _DashedBorder(
                color: dark ? _Colors.indigo700 : _Colors.indigo300,
                radius: 12 * ps,
                width: 2,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(9 * ps),
                decoration: BoxDecoration(
                  color: dark
                      ? _Colors.indigo900.withValues(alpha: hover ? 0.25 : 0.1)
                      : _Colors.indigo50.withValues(alpha: hover ? 1 : 0.5),
                  borderRadius: BorderRadius.circular(12 * ps),
                ),
                child: Row(
                  children: [
                    AnimatedScale(
                      scale: hover ? 1.1 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 84 * ps,
                        height: 36 * ps,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: dark
                              ? _Colors.slate800.withValues(alpha: 0.5)
                              : _Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8 * ps),
                          border: Border.all(color: zoneBorder),
                          boxShadow: hover
                              ? [
                                  BoxShadow(
                                    color: _Colors.indigo500.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 15,
                                  ),
                                ]
                              : null,
                        ),
                        child: placed == null
                            ? null
                            : _TokenFace(
                                text: _t(placed.tokenKey),
                                dark: dark,
                                scale: ps,
                                placed: true,
                              ),
                      ),
                    ),
                    SizedBox(width: 10 * ps),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 16 * ps,
                                color: _Colors.indigo500,
                              ),
                              SizedBox(width: 4 * ps),
                              Flexible(
                                child: Text(
                                  _t('missing_step'),
                                  style: TextStyle(
                                    color: _Colors.slate500,
                                    fontSize: 12 * ps,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2 * ps),
                          Text(
                            _t('missing_hint'),
                            style: TextStyle(
                              color: p.textMuted,
                              fontSize: 10 * ps,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ],
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

  /// HTML `#s2-tray`: the five steps, without the one placed in this case.
  Widget _tokenTray(LabPalette p, double ps) {
    final dark = p.isDark;
    final placed = _s2Placed[_s2Index];
    return Container(
      constraints: BoxConstraints(minHeight: 80 * ps),
      padding: EdgeInsets.all(10 * ps),
      decoration: BoxDecoration(
        color: dark
            ? _Colors.slate800.withValues(alpha: 0.8)
            : _Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12 * ps),
        border: Border.all(color: dark ? _Colors.slate600 : _Colors.slate300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8 * ps,
            runSpacing: 8 * ps,
            children: [
              for (final k in _Kind.values)
                if (k != placed) _token(p, ps, k),
            ],
          ),
          SizedBox(height: 8 * ps),
          _trayHint(p, ps, 'tray_hint_s2'),
        ],
      ),
    );
  }

  Widget _token(LabPalette p, double ps, _Kind token) {
    final text = _t(token.tokenKey);
    final face = _TokenFace(
      text: text,
      dark: p.isDark,
      scale: ps,
      picked: _pickedToken == token,
    );
    return Draggable<_Kind>(
      key: ValueKey('ch1a3-token-${token.name}'),
      data: token,
      maxSimultaneousDrags: _correct ? 0 : 1,
      onDragStarted: _onTokenPickup,
      onDragUpdate: (d) => _dragPointer = d.globalPosition,
      onDragEnd: (_) => _endDrag(),
      feedback: _feedback(
        _TokenFace(text: text, dark: p.isDark, scale: ps, lifted: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: face),
      child: Semantics(
        button: true,
        selected: _pickedToken == token,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onTokenTap(token),
          child: face,
        ),
      ),
    );
  }

  // --------------------------------------------- Scenario 3: Your Own "Why?"

  Widget _s3(LabPalette p, double ps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(p, ps, 3),
        SizedBox(height: 12 * ps),
        for (final f in _Field.values) ...[
          if (f.index > 0) SizedBox(height: 12 * ps),
          _fieldBox(p, ps, f),
        ],
      ],
    );
  }

  /// HTML `.s3-input` with its label and '?' hint (a tap shows the hint
  /// that the HTML showed on hover).
  Widget _fieldBox(LabPalette p, double ps, _Field f) {
    final dark = p.isDark;
    final error = _s3Errors.contains(f);
    final label = _t(f.labelKey).toUpperCase();
    final radius = BorderRadius.circular(14 * ps);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: 2),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: _Colors.slate500,
                  fontSize: 11 * ps,
                  fontWeight: FontWeight.w800,
                  letterSpacing: labLetterSpacing(label, 0.6),
                ),
              ),
            ),
            Tooltip(
              message: _t(f.hintKey),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 5),
              child: Semantics(
                button: true,
                label: _t('hint_lbl'),
                child: SizedBox.square(
                  dimension: math.max(32.0, 32 * ps),
                  child: Icon(
                    Icons.help_outline,
                    size: 17 * ps,
                    color: _Colors.indigo500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2 * ps),
        TextField(
          key: ValueKey('ch1a3-field-${f.number}'),
          controller: _fields[f.index],
          minLines: 2,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            color: dark ? _Colors.slate50 : _Colors.slate800,
            fontSize: 13 * ps,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: _t(f.placeholderKey),
            hintStyle: TextStyle(
              color: _Colors.slate400,
              fontSize: 13 * ps,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: error
                ? (dark
                      ? _Colors.red900.withValues(alpha: 0.2)
                      : _Colors.red100.withValues(alpha: 0.5))
                : (dark
                      ? _Colors.slate900.withValues(alpha: 0.8)
                      : _Colors.white.withValues(alpha: 0.9)),
            isDense: true,
            contentPadding: EdgeInsets.all(12 * ps),
            enabledBorder: border(
              error
                  ? _Colors.red500
                  : (dark ? _Colors.slate700 : _Colors.slate300),
            ),
            focusedBorder: border(error ? _Colors.red500 : _Colors.indigo500),
          ),
        ),
      ],
    );
  }
}

// =================================================================== WIDGETS

/// CSS `grayscale(gray) brightness(bright)` as a colour matrix (Filter
/// Effects spec).
List<double> _colorMatrix(double gray, double bright) {
  final s = 1 - gray;
  final m = [
    0.2126 + 0.7874 * s,
    0.7152 - 0.7152 * s,
    0.0722 - 0.0722 * s,
    0.2126 - 0.2126 * s,
    0.7152 + 0.2848 * s,
    0.0722 - 0.0722 * s,
    0.2126 - 0.2126 * s,
    0.7152 - 0.7152 * s,
    0.0722 + 0.9278 * s,
  ];
  return [
    for (var row = 0; row < 3; row++) ...[
      m[row * 3] * bright,
      m[row * 3 + 1] * bright,
      m[row * 3 + 2] * bright,
      0,
      0,
    ],
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Dimmed props (`grayscale(0.8) brightness(0.6)`) and the inactive case
/// buttons (`.case-btn`: `grayscale(1)`).
final ColorFilter _dimFilter = ColorFilter.matrix(
  _colorMatrix(_dimGray, _dimBright),
);
final ColorFilter _grayFilter = ColorFilter.matrix(_colorMatrix(1, 1));

/// HTML `.s1-target-btn` in its square dropzone: a dashed circle that turns
/// solid indigo with a glow under a card (`.dropzone.highlight`). It shows
/// the slot's number (added), filled indigo once a card is placed, and
/// dashed indigo while a tapped card waits for a slot.
class _SlotSquare extends StatelessWidget {
  const _SlotSquare({
    required this.number,
    required this.filled,
    required this.hover,
    required this.waiting,
    required this.dark,
    required this.scale,
  });

  final int number;
  final bool filled;
  final bool hover;
  final bool waiting;
  final bool dark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final ring = hover || waiting || filled
        ? _Colors.indigo500
        : (dark ? _Colors.slate600 : _Colors.slate400);
    final digit = filled
        ? _Colors.white
        : (hover || waiting
              ? _Colors.indigo500
              : (dark ? _Colors.slate300 : _Colors.slate500));
    final circle = Container(
      width: 32 * s,
      height: 32 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? _Colors.indigo500
            : (dark ? _Colors.slate800 : _Colors.slate100),
        border: hover || filled ? Border.all(color: ring, width: 2) : null,
        boxShadow: hover
            ? [
                BoxShadow(
                  color: _Colors.indigo500.withValues(alpha: 0.5),
                  blurRadius: 15,
                ),
              ]
            : null,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: digit,
          fontSize: 15 * s,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    return AnimatedScale(
      scale: hover ? 1.1 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        width: 46 * s,
        height: 46 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark
              ? _Colors.slate800.withValues(alpha: 0.5)
              : _Colors.slate200.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(
            color: dark
                ? _Colors.slate700.withValues(alpha: 0.5)
                : _Colors.slate300.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: hover || filled
            ? circle
            : CustomPaint(
                foregroundPainter: _DashedCircle(color: ring, width: 2),
                child: circle,
              ),
      ),
    );
  }
}

/// A statement card in the tray (HTML `.draggable-card`): white with an
/// indigo-200 border; indigo and lifted while held ([lifted]) or tapped
/// ([picked]).
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.text,
    required this.dark,
    required this.scale,
    this.picked = false,
    this.lifted = false,
  });

  final String text;
  final bool dark;
  final double scale;
  final bool picked;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final strong = picked || lifted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: BoxConstraints(minHeight: 44 * s),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 8 * s),
      transform: picked
          ? Matrix4.translationValues(0, -2 * s, 0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate700 : _Colors.white,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: strong
              ? _Colors.indigo500
              : (dark ? _Colors.indigo900 : _Colors.indigo200),
          width: strong ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: strong
                ? _Colors.indigo500.withValues(alpha: lifted ? 0.45 : 0.35)
                : LabInk.shadowSoft,
            blurRadius: lifted ? 24 : (picked ? 14 : 6),
            offset: Offset(0, lifted ? 10 : 3),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: dark ? _Colors.white : _Colors.slate800,
          fontSize: 11 * s,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

/// A statement placed in a slot (HTML `placeCardVisual`: indigo-400
/// border, bold indigo text; kept in sentence case so it stays readable).
class _PlacedFace extends StatelessWidget {
  const _PlacedFace({
    required this.text,
    required this.dark,
    required this.scale,
  });

  final String text;
  final bool dark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minHeight: 48 * s),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: dark
            ? _Colors.slate700.withValues(alpha: 0.8)
            : _Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _Colors.indigo400, width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowSoft,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: dark ? _Colors.indigo300 : _Colors.indigo700,
          fontSize: 11 * s,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    );
  }
}

/// A step token of Scenario 2 (HTML `#s2-tray .draggable-card`): uppercase
/// indigo on white. [placed] fills the blank slot (indigo-400 border).
class _TokenFace extends StatelessWidget {
  const _TokenFace({
    required this.text,
    required this.dark,
    required this.scale,
    this.picked = false,
    this.lifted = false,
    this.placed = false,
  });

  final String text;
  final bool dark;
  final double scale;
  final bool picked;
  final bool lifted;
  final bool placed;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final label = text.toUpperCase();
    final strong = picked || lifted;
    final style = TextStyle(
      color: dark ? _Colors.indigo300 : _Colors.indigo700,
      fontSize: (placed ? 10 : 11) * s,
      fontWeight: FontWeight.w900,
      letterSpacing: labLetterSpacing(label, 0.5),
    );
    if (placed) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 4 * s),
        decoration: BoxDecoration(
          color: dark ? _Colors.slate700 : _Colors.white,
          borderRadius: BorderRadius.circular(8 * s),
          border: Border.all(color: _Colors.indigo400, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: style),
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(
        minHeight: kMinInteractiveDimension - 8,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 9 * s),
      transform: picked
          ? Matrix4.translationValues(0, -2 * s, 0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: dark ? _Colors.slate700 : _Colors.white,
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(
          color: strong
              ? _Colors.indigo500
              : (dark ? _Colors.indigo900 : _Colors.indigo200),
          width: strong ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: strong
                ? _Colors.indigo500.withValues(alpha: 0.4)
                : LabInk.shadowSoft,
            blurRadius: lifted ? 22 : (picked ? 12 : 6),
            offset: Offset(0, lifted ? 8 : 3),
          ),
        ],
      ),
      child: Text(label, textAlign: TextAlign.center, style: style),
    );
  }
}

/// HTML teacher-board "The Five Steps" (`sb_steps`). The paragraph the
/// current slot or box is about is highlighted (added).
class _FiveSteps extends StatelessWidget {
  const _FiveSteps({
    required this.lines,
    required this.focus,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final List<String> lines;

  /// 1-based paragraph to highlight, or null.
  final int? focus;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
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
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) SizedBox(height: 6 * s),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
              decoration: BoxDecoration(
                color: focus == i + 1
                    ? p.accent.withValues(alpha: 0.12)
                    : LabInk.clear,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: focus == i + 1 ? p.accent : LabInk.clear,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                lines[i],
                style: TextStyle(
                  color: focus == i + 1 ? p.textStrong : p.text,
                  fontSize: 12.5 * fontScale,
                  fontWeight: focus == i + 1
                      ? FontWeight.w700
                      : FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Below the Conclusion text (added): the five steps in order and the four
/// everyday cases they solved.
class _ConclusionVisual extends StatelessWidget {
  const _ConclusionVisual({
    required this.palette,
    required this.scale,
    required this.t,
  });

  final LabPalette palette;
  final double scale;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4 * s,
            runSpacing: 6 * s,
            children: [
              for (final kind in _Kind.values) ...[
                if (kind.index > 0)
                  Icon(Icons.arrow_forward, size: 14 * s, color: p.textMuted),
                _stepChip(kind),
              ],
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        Row(
          children: [
            for (final c in _Prop.cases)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38 * s,
                      height: 38 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.color.withValues(alpha: 0.15),
                        border: Border.all(
                          color: c.color.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Icon(c.icon, size: 20 * s, color: c.color),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      t(c.labelKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepChip(_Kind kind) {
    final p = palette;
    final s = scale;
    final label = t(kind.tokenKey);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: _Colors.indigo500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _Colors.indigo500.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(kind.icon, size: 14 * s, color: p.ink(_Colors.indigo400)),
          SizedBox(width: 4 * s),
          Text(
            label,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed rounded outline (HTML `border-dashed`).
class _DashedBorder extends CustomPainter {
  _DashedBorder({
    required this.color,
    required this.radius,
    required this.width,
  });

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    labDashedPath(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 6,
      gap: 4,
    );
  }

  @override
  bool shouldRepaint(_DashedBorder old) =>
      old.color != color || old.radius != radius || old.width != width;
}

/// A dashed circle inscribed in the painted box (HTML `.s1-target-btn`).
class _DashedCircle extends CustomPainter {
  _DashedCircle({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 - width / 2;
    labDashedPath(
      canvas,
      Path()
        ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: r)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 4,
      gap: 3,
    );
  }

  @override
  bool shouldRepaint(_DashedCircle old) =>
      old.color != color || old.width != width;
}

// ================================================================== PAINTING

/// What the painter makes once and reuses: the label text painters (laid
/// out at the CSS size and scaled when drawn) and the pictures of the props
/// (static drawings, replayed at any size). Owned by the page state and
/// disposed with it.
class _PaintCache {
  final Map<String, TextPainter> _labels = {};
  final Map<_Prop, ui.Picture> _art = {};

  /// A marker label (`text-sm font-bold tracking-widest uppercase`):
  /// slate-900 on the light chip of the dark theme, white on the dark chip
  /// of the light theme.
  TextPainter label(String text, bool dark) =>
      _labels['${dark ? 'd' : 'l'}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: dark ? _Colors.slate900 : _Colors.white,
            fontSize: _labelFontCss,
            fontWeight: FontWeight.w700,
            letterSpacing: labLetterSpacing(
              text,
              _labelFontCss * _labelTracking,
            ),
            height: _labelLineCss / _labelFontCss,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Width of [text]'s label at the CSS font size.
  double width(String text, bool dark) => label(text, dark).width;

  /// The prop's photo, painted in a 224 x 160 box.
  ui.Picture art(_Prop prop) => _art[prop] ??= _record(prop);

  static ui.Picture _record(_Prop prop) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & _PropArt.box);
    _PropArt.draw(canvas, prop);
    return recorder.endRecording();
  }

  void dispose() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
    for (final picture in _art.values) {
      picture.dispose();
    }
    _art.clear();
  }
}

/// Paints the HTML 'Case Desk': the wooden desk and its grid through the
/// HTML camera, then the markers (HTML DOM overlays, so always on top) in
/// DOM order.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final cam = s.camera();
    canvas.drawRect(
      labBleed(size),
      Paint()..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    _paintDesk(canvas, cam);
    _paintGrid(canvas, cam);
    final chips = <(_MarkerBox, _Prop)>[];
    for (final prop in _Prop.values) {
      if (!s.shows(prop)) continue;
      final box = _paintMarker(canvas, cam, prop);
      if (prop.isCase) chips.add((box, prop));
    }
    // The uppercase name chips go over every card, so a front card never
    // hides the name of the one behind it on a small stage.
    if (!showLabels) return;
    for (final (box, prop) in chips) {
      _paintChip(canvas, box, labTr(_i18n, lang, prop.labelKey).toUpperCase());
    }
  }

  /// [c] lit by the ambient light and the directional light at (10, 20,
  /// 10) on a face with normal [n] (Lambert, like a rough
  /// MeshStandardMaterial).
  Color _lit(Color c, _V n) {
    final k = _ambient + _diffuse * math.max(0.0, n.dot(_lightDir));
    return Color.from(
      alpha: c.a,
      red: (c.r * k).clamp(0.0, 1.0),
      green: (c.g * k).clamp(0.0, 1.0),
      blue: (c.b * k).clamp(0.0, 1.0),
    );
  }

  Path _poly(_Cam cam, List<_V> points) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final q = cam.p(points[i]);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    return path..close();
  }

  /// `CylinderGeometry(15, 15, 0.5, 32)`: the faces of its rim that face
  /// the camera, then its top.
  void _paintDesk(Canvas canvas, _Cam cam) {
    const n = _deskSegments;
    final top = <_V>[];
    final bottom = <_V>[];
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n;
      final x = _deskRadius * math.cos(a);
      final z = _deskRadius * math.sin(a);
      top.add(_V(x, 0, z));
      bottom.add(_V(x, -_deskHeight, z));
    }
    final side = Paint();
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final mid = 2 * math.pi * (i + 0.5) / n;
      final normal = _V(math.cos(mid), 0, math.sin(mid));
      final centre = (top[i] + top[j]) * 0.5 - const _V(0, _deskHeight / 2, 0);
      if ((cam.eye - centre).dot(normal) <= 0) continue;
      final face = cam.clip([top[i], top[j], bottom[j], bottom[i]]);
      if (face.length < 3) continue;
      canvas.drawPath(
        _poly(cam, face),
        side..color = _lit(labShade(_Colors.wood, -0.12), normal),
      );
    }
    final rim = cam.clip(top);
    if (rim.length < 3) return;
    final path = _poly(cam, rim);
    final wood = _lit(_Colors.wood, _V.up);
    final glowAt = cam.p(const _V(3, 0, 3));
    final reach =
        (cam.p(const _V(_deskRadius, 0, 0)) -
                cam.p(const _V(-_deskRadius, 0, 0)))
            .distance;
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.radial(
          glowAt,
          math.max(1.0, reach * 0.75),
          [labShade(wood, 0.1), wood, labShade(wood, -0.18)],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(_Colors.wood, -0.35).withValues(alpha: 0.6),
    );
  }

  /// `GridHelper(30, 30, 0xffffff, 0xffffff)` at opacity 0.1, on the desk
  /// top (and past its edge at the corners).
  void _paintGrid(Canvas canvas, _Cam cam) {
    final paint = Paint()
      ..color = _Colors.grid
      ..strokeWidth = 1;
    const step = 2 * _gridHalf / _gridDivisions;
    for (var i = 0; i <= _gridDivisions; i++) {
      final v = -_gridHalf + i * step;
      _line(canvas, cam, _V(v, 0, -_gridHalf), _V(v, 0, _gridHalf), paint);
      _line(canvas, cam, _V(-_gridHalf, 0, v), _V(_gridHalf, 0, v), paint);
    }
  }

  void _line(Canvas canvas, _Cam cam, _V a, _V b, Paint paint) {
    final segment = cam.clipSegment(a, b);
    if (segment == null) return;
    canvas.drawLine(cam.p(segment.$1), cam.p(segment.$2), paint);
  }

  /// HTML `.icon-marker`: a rounded card with a coloured ring and glow and
  /// the prop's photo (dimmed unless it is the case being worked on).
  /// Returns its layout for the label chip below it.
  _MarkerBox _paintMarker(Canvas canvas, _Cam cam, _Prop prop) {
    final s = scene;
    final box = _markerBox(
      cam,
      prop,
      labelMin: s.labelMin,
      bounce: s.bounce(prop),
    );
    final k = box.k;
    final card = box.card;
    final rr = RRect.fromRectAndRadius(
      card,
      Radius.circular(_cardCssRadius * k),
    );
    // shadow-[0_0_30px_rgba(colour, 0.3)].
    canvas.drawRRect(
      rr,
      Paint()
        ..color = prop.color.withValues(alpha: prop.glowAlpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(0.5, _glowCss * k / 2),
        ),
    );
    // ring-4 (colour / 50%, the notepad / 30%).
    canvas.drawRRect(
      rr.inflate(_ringCss * k / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringCss * k
        ..color = prop.color.withValues(alpha: prop.ringAlpha),
    );
    canvas.drawRRect(
      rr,
      Paint()..color = isDark ? _Colors.cardDark : _Colors.cardLight,
    );
    // The photo, `object-cover` inside the card's rounded corners.
    canvas.save();
    canvas.clipRRect(rr);
    final layer = Paint();
    if (!s.lit(prop)) layer.colorFilter = _dimFilter;
    if (!prop.isCase) {
      layer.color = _Colors.black.withValues(alpha: _notepadOpacity);
    }
    canvas.saveLayer(card, layer);
    canvas.translate(card.left, card.top);
    canvas.scale(
      card.width / _PropArt.box.width,
      card.height / _PropArt.box.height,
    );
    canvas.drawPicture(cache.art(prop));
    canvas.restore();
    canvas.restore();
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.75, k)
        ..color = isDark ? _Colors.cardEdgeDark : _Colors.cardEdgeLight,
    );
    return box;
  }

  /// The marker's name chip (`bg-slate-900/90 dark:bg-slate-100/90`,
  /// `rounded-xl`, `shadow-lg`).
  void _paintChip(Canvas canvas, _MarkerBox box, String text) {
    final tp = cache.label(text, isDark);
    final f = box.labelFont / _labelFontCss;
    final chip = box.chip(tp.width);
    final rr = RRect.fromRectAndRadius(
      chip,
      Radius.circular(_labelRadiusCss * f),
    );
    canvas.drawRRect(
      rr.shift(Offset(0, 4 * f)),
      Paint()
        ..color = _Colors.shadow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.5, 5 * f)),
    );
    canvas.drawRRect(
      rr,
      Paint()..color = isDark ? _Colors.chipDark : _Colors.chipLight,
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, f)
        ..color = isDark ? _Colors.slate300 : _Colors.slate700,
    );
    canvas.save();
    canvas.translate(
      chip.center.dx - tp.width * f / 2,
      chip.center.dy - tp.height * f / 2,
    );
    canvas.scale(f);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang;
}

/// The props the HTML showed as photos (`pen_prop`, `cooker_prop`,
/// `tyre_prop`, `bulb_prop`, `notepad_prop` JPEGs that were not part of the
/// page), painted in the photos' 224 x 160 box: a pen whose writing fades
/// out, a pressure cooker with dal spilling down its side, a flat bicycle
/// tyre with a nail in it, an unlit bulb with a broken filament beside its
/// switch, and a spiral notepad with a question mark and a pencil.
abstract final class _PropArt {
  static const Size box = Size(_cardCssW, _cardCssH);

  static void draw(Canvas c, _Prop prop) {
    switch (prop) {
      case _Prop.pen:
        _pen(c);
      case _Prop.cooker:
        _cooker(c);
      case _Prop.tyre:
        _tyre(c);
      case _Prop.bulb:
        _bulb(c);
      case _Prop.notepad:
        _notepad(c);
    }
  }

  static Paint _fill(Color color) => Paint()..color = color;

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  static Paint _blur(Color color, double sigma) => Paint()
    ..color = color
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  static Paint _vertical(double top, double bottom, List<Color> colors) =>
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, bottom),
          colors,
          _stops(colors.length),
        );

  static Paint _horizontal(double left, double right, List<Color> colors) =>
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(left, 0),
          Offset(right, 0),
          colors,
          _stops(colors.length),
        );

  static List<double> _stops(int n) => [
    for (var i = 0; i < n; i++) n == 1 ? 0 : i / (n - 1),
  ];

  static Offset _dir(double angle) => Offset(math.cos(angle), math.sin(angle));

  /// Joined-up handwriting: loops along [base] from [from] to [to], word
  /// by word. From [fadeFrom] on the ink runs out.
  static void _scribble(
    Canvas c, {
    required double from,
    required double to,
    required double base,
    required Color ink,
    double fadeFrom = double.infinity,
    double size = 1,
  }) {
    const words = [3, 5, 2, 4, 3, 5, 4, 2];
    final paint = _stroke(ink, 1.5 * size);
    final r = 1.9 * size;
    final d = 2.9 * size;
    final h = 3.6 * size;
    var start = from;
    var w = 0;
    while (start < to - 4 * size) {
      final end = math.min(
        to,
        start + words[w % words.length] * 2 * math.pi * r,
      );
      final tEnd = (end - start) / r;
      Offset? last;
      for (var t = 0.0; t <= tEnd; t += 0.3) {
        final x = start + r * t - d * math.sin(t);
        final q = Offset(x, base - h - h * math.cos(t));
        if (last != null) {
          final fade = x <= fadeFrom
              ? 1.0
              : (1 - (x - fadeFrom) / math.max(1, to - fadeFrom)).clamp(
                  0.06,
                  1.0,
                );
          c.drawLine(last, q, paint..color = ink.withValues(alpha: fade));
        }
        last = q;
      }
      start = end + 8 * size;
      w++;
    }
  }

  // ------------------------------------------------------------------- pen

  static void _pen(Canvas c) {
    final full = Offset.zero & box;
    c.drawRect(full, _fill(_Colors.paper));
    c.drawRect(
      full,
      _vertical(0, box.height, const [Color(0x00000000), Color(0x1A000000)]),
    );
    final rule = _stroke(_Colors.rule, 1.2);
    for (var y = 30.0; y < box.height; y += 22) {
      c.drawLine(Offset(0, y), Offset(box.width, y), rule);
    }
    c.drawLine(
      const Offset(28, 0),
      Offset(28, box.height),
      _stroke(_Colors.margin, 1.4),
    );
    // An earlier line in full ink, then the line where the ink ran out.
    _scribble(c, from: 36, to: 204, base: 27, ink: _Colors.ink);
    _scribble(c, from: 36, to: 150, base: 49, ink: _Colors.ink, fadeFrom: 86);
    // Past that, the dry nib only scratched the paper.
    final dry = _stroke(_Colors.slate300, 0.9);
    for (var i = 0; i < 5; i++) {
      final x = 150.0 + i * 7;
      c.drawLine(Offset(x, 46 + (i % 2) * 2), Offset(x + 4, 44), dry);
    }
    _penBody(c, tip: const Offset(152, 54), angle: 0.62);
  }

  /// A ball-point pen lying on the paper, its tip at [tip].
  static void _penBody(Canvas c, {required Offset tip, required double angle}) {
    c.save();
    c.translate(tip.dx, tip.dy);
    c.rotate(angle);
    c.drawRRect(
      RRect.fromLTRBR(14, 3, 124, 17, const Radius.circular(7)),
      _blur(const Color(0x38000000), 4),
    );
    // Metal cone and its ball.
    final cone = Path()
      ..moveTo(0, 0)
      ..lineTo(13, -4.2)
      ..lineTo(13, 4.2)
      ..close();
    c.drawPath(
      cone,
      _vertical(-4.2, 4.2, const [_Colors.steelLight, _Colors.steelDark]),
    );
    c.drawCircle(Offset.zero, 1.3, _fill(_Colors.slate800));
    // Rubber grip with ribs.
    c.drawRRect(
      RRect.fromLTRBR(12, -5, 36, 5, const Radius.circular(2.5)),
      _vertical(-5, 5, [
        labShade(_Colors.penGrip, 0.3),
        _Colors.penGrip,
        labShade(_Colors.penGrip, -0.4),
      ]),
    );
    final rib = _stroke(labShade(_Colors.penGrip, 0.25), 0.8);
    for (var x = 15.0; x < 35; x += 3) {
      c.drawLine(Offset(x, -4.2), Offset(x, 4.2), rib);
    }
    // Barrel, end cap and clip.
    c.drawRRect(
      RRect.fromLTRBR(35, -5.6, 116, 5.6, const Radius.circular(5.6)),
      _vertical(-5.6, 5.6, [
        labShade(_Colors.penBody, 0.45),
        _Colors.penBody,
        labShade(_Colors.penBody, -0.45),
      ]),
    );
    c.drawRRect(
      RRect.fromLTRBR(108, -5.8, 121, 5.8, const Radius.circular(5.8)),
      _fill(labShade(_Colors.penBody, -0.3)),
    );
    c.drawRRect(
      RRect.fromLTRBR(80, -8.4, 112, -6, const Radius.circular(1.2)),
      _vertical(-8.4, -6, const [_Colors.steelLight, _Colors.steelDark]),
    );
    c.drawCircle(const Offset(82, -7.2), 1.6, _fill(_Colors.steel));
    c.drawLine(
      const Offset(40, -3),
      const Offset(108, -3),
      _stroke(const Color(0x66FFFFFF), 1.2),
    );
    c.restore();
  }

  // ---------------------------------------------------------------- cooker

  static void _cooker(Canvas c) {
    // Tiled kitchen wall above the stove top.
    c.drawRect(const Rect.fromLTWH(0, 0, 224, 104), _fill(_Colors.tile));
    final grout = _stroke(_Colors.tileLine, 1.2);
    for (var x = 0.0; x <= 224; x += 28) {
      c.drawLine(Offset(x, 0), Offset(x, 104), grout);
    }
    for (var y = 0.0; y <= 104; y += 26) {
      c.drawLine(Offset(0, y), Offset(224, y), grout);
    }
    c.drawRect(
      const Rect.fromLTWH(0, 104, 224, 56),
      _vertical(104, 160, [
        labShade(_Colors.stove, 0.15),
        labShade(_Colors.stove, -0.3),
      ]),
    );
    c.drawLine(
      const Offset(0, 104),
      const Offset(224, 104),
      _stroke(labShade(_Colors.stove, 0.4), 2),
    );
    // The gas flame under the cooker.
    c.drawOval(
      Rect.fromCenter(center: const Offset(100, 131), width: 112, height: 18),
      _blur(_Colors.flame.withValues(alpha: 0.45), 6),
    );
    // Steam from the whistle.
    for (final (o, r) in const [
      (Offset(74, 30), 7.0),
      (Offset(83, 18), 9.0),
      (Offset(71, 7), 8.0),
    ]) {
      c.drawCircle(o, r, _blur(_Colors.steam, 3));
    }
    // Brushed steel pot with a rounded bottom and its side handle.
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        52,
        62,
        148,
        128,
        bottomLeft: const Radius.circular(14),
        bottomRight: const Radius.circular(14),
      ),
      _horizontal(52, 148, const [
        _Colors.steelDark,
        _Colors.steelLight,
        _Colors.steel,
        _Colors.steelDark,
      ]),
    );
    c.drawLine(
      const Offset(84, 72),
      const Offset(84, 120),
      _stroke(const Color(0x8CFFFFFF), 3),
    );
    c.drawRRect(
      RRect.fromLTRBR(144, 80, 196, 90, const Radius.circular(5)),
      _fill(_Colors.bakelite),
    );
    // Lid, its long handle and the whistle weight.
    c.drawOval(
      Rect.fromCenter(center: const Offset(100, 62), width: 104, height: 20),
      _horizontal(48, 152, const [
        _Colors.steelDark,
        _Colors.steelLight,
        _Colors.steelDark,
      ]),
    );
    final lid = Rect.fromCenter(
      center: const Offset(100, 60),
      width: 88,
      height: 14,
    );
    c.drawOval(lid, _fill(_Colors.steel));
    c.drawOval(lid, _stroke(_Colors.steelDark, 1));
    c.drawRRect(
      RRect.fromLTRBR(94, 50, 114, 60, const Radius.circular(3)),
      _fill(_Colors.slate600),
    );
    c.drawRRect(
      RRect.fromLTRBR(104, 48, 202, 58, const Radius.circular(5)),
      _fill(_Colors.bakelite),
    );
    c.drawLine(
      const Offset(110, 50.5),
      const Offset(196, 50.5),
      _stroke(const Color(0x40FFFFFF), 1.2),
    );
    c.drawRRect(
      RRect.fromLTRBR(72, 42, 84, 56, const Radius.circular(3)),
      _fill(_Colors.bakelite),
    );
    c.drawCircle(const Offset(78, 41), 4, _fill(_Colors.slate600));
    // Dal oozing from under the lid and down the side onto the stove.
    final spill = Path()
      ..moveTo(50, 58)
      ..cubicTo(60, 52, 76, 54, 82, 62)
      ..cubicTo(78, 70, 68, 70, 62, 74)
      ..cubicTo(60, 86, 66, 94, 60, 104)
      ..cubicTo(58, 112, 54, 116, 56, 126)
      ..lineTo(47, 128)
      ..cubicTo(46, 112, 50, 98, 47, 86)
      ..cubicTo(45, 74, 44, 64, 50, 58)
      ..close();
    c.drawPath(
      spill,
      _horizontal(44, 84, [
        _Colors.dalDark,
        _Colors.dal,
        labShade(_Colors.dal, 0.3),
      ]),
    );
    final drip = Path()
      ..moveTo(64, 74)
      ..quadraticBezierTo(71, 84, 68, 89)
      ..quadraticBezierTo(63, 91, 63, 84)
      ..close();
    c.drawPath(drip, _fill(_Colors.dal));
    c.drawOval(
      Rect.fromCenter(center: const Offset(44, 134), width: 56, height: 14),
      _fill(_Colors.dal),
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(46, 132), width: 30, height: 5),
      _fill(labShade(_Colors.dal, 0.4)),
    );
    final speck = _fill(_Colors.dalDark);
    for (final o in const [
      Offset(56, 62),
      Offset(66, 60),
      Offset(74, 64),
      Offset(52, 80),
      Offset(55, 98),
      Offset(36, 134),
      Offset(50, 137),
      Offset(58, 132),
    ]) {
      c.drawCircle(o, 1.4, speck);
    }
  }

  // ------------------------------------------------------------------ tyre

  static void _tyre(Canvas c) {
    const ground = 106.0;
    c.drawRect(
      const Rect.fromLTWH(0, 0, 224, ground),
      _vertical(0, ground, const [_Colors.sky, _Colors.skyLight]),
    );
    c.drawRect(
      const Rect.fromLTWH(0, ground, 224, 160 - ground),
      _vertical(ground, 160, [
        labShade(_Colors.road, 0.15),
        labShade(_Colors.road, -0.2),
      ]),
    );
    final dash = _stroke(_Colors.roadLine, 3);
    for (var x = 4.0; x < 224; x += 34) {
      c.drawLine(Offset(x, 144), Offset(x + 18, 144), dash);
    }
    const centre = Offset(112, 62);
    const outer = 50.0;
    const inner = 39.0;
    // The rubber squashed flat on the road (a flat tyre bulges sideways).
    Path ring(double r, double floor) {
      final path = Path();
      for (var i = 0; i <= 90; i++) {
        final a = i / 90 * 2 * math.pi;
        var p = centre + _dir(a) * r;
        if (p.dy > floor) {
          p = Offset(centre.dx + (p.dx - centre.dx) * 1.12, floor);
        }
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path..close();
    }

    c.drawOval(
      Rect.fromCenter(
        center: const Offset(112, ground + 2),
        width: 124,
        height: 10,
      ),
      _blur(const Color(0x59000000), 3),
    );
    c.drawPath(
      Path.combine(
        PathOperation.difference,
        ring(outer, ground),
        ring(inner, ground - 7),
      ),
      _fill(_Colors.rubber),
    );
    final tread = _stroke(_Colors.rubberLight, 2);
    for (var i = 0; i < 36; i++) {
      final a = i / 36 * 2 * math.pi;
      final from = centre + _dir(a) * (outer - 5);
      if (from.dy > ground - 6) continue;
      c.drawLine(from, centre + _dir(a) * (outer - 1.5), tread);
    }
    // Rim, spokes and hub.
    c.drawCircle(centre, inner, _stroke(_Colors.steel, 3.2));
    c.drawCircle(centre, inner - 3, _stroke(_Colors.steelDark, 1.2));
    final spoke = _stroke(_Colors.steel, 0.9);
    for (var i = 0; i < 18; i++) {
      final a = i / 18 * 2 * math.pi;
      final hub = a + (i.isEven ? 0.35 : -0.35);
      c.drawLine(centre + _dir(hub) * 5, centre + _dir(a) * (inner - 3), spoke);
    }
    c.drawCircle(centre, 6.5, _fill(_Colors.steel));
    c.drawCircle(centre, 2.6, _fill(_Colors.steelDark));
    // Valve.
    c.drawLine(
      centre + _dir(-1.1) * (inner - 2),
      centre + _dir(-1.1) * (inner - 9),
      _stroke(_Colors.steelDark, 2.4),
    );
    // A nail in the tread and the air hissing out.
    const nailAt = 2.45;
    final out = _dir(nailAt);
    final hole = centre + out * outer;
    final head = hole + out * 8;
    c.drawLine(hole - out * 4, head, _stroke(_Colors.nail, 2.2));
    final across = Offset(-out.dy, out.dx);
    c.drawLine(
      head - across * 3.5,
      head + across * 3.5,
      _stroke(_Colors.nail, 2.4),
    );
    final hiss = _stroke(_Colors.slate500, 1.5);
    for (var k = 1; k <= 3; k++) {
      c.drawArc(
        Rect.fromCircle(center: hole + out * 4, radius: 5.0 * k + 4),
        nailAt + 0.35,
        0.8,
        false,
        hiss,
      );
    }
    // Bicycle frame: the fork blade up from the hub and the down tube.
    c.drawLine(centre, const Offset(148, -6), _stroke(_Colors.frame, 6));
    c.drawLine(
      const Offset(142, 8),
      const Offset(230, 34),
      _stroke(_Colors.frame, 6),
    );
    c.drawLine(
      centre + const Offset(3, -6),
      const Offset(149, -4),
      _stroke(const Color(0x59FFFFFF), 1.4),
    );
  }

  // ------------------------------------------------------------------ bulb

  static void _bulb(Canvas c) {
    c.drawRect(
      Offset.zero & box,
      _vertical(0, box.height, const [_Colors.room, _Colors.roomDark]),
    );
    // Cord from the ceiling, holder and screw base.
    c.drawLine(
      const Offset(96, 0),
      const Offset(96, 34),
      _stroke(_Colors.slate900, 2.6),
    );
    c.drawRRect(
      RRect.fromLTRBR(85, 32, 107, 50, const Radius.circular(3)),
      _fill(const Color(0xFF111827)),
    );
    c.drawRect(
      const Rect.fromLTRB(87, 50, 105, 66),
      _horizontal(87, 105, const [
        _Colors.steelDark,
        _Colors.steelLight,
        _Colors.steelDark,
      ]),
    );
    final thread = _stroke(_Colors.steelDark, 1);
    for (var y = 53.0; y < 65; y += 4) {
      c.drawLine(Offset(87, y), Offset(105, y + 1.5), thread);
    }
    // Cold grey glass: the bulb does not light.
    final glass = Path()
      ..moveTo(88, 66)
      ..cubicTo(88, 74, 70, 80, 70, 98)
      ..cubicTo(70, 116, 82, 126, 96, 126)
      ..cubicTo(110, 126, 122, 116, 122, 98)
      ..cubicTo(122, 80, 104, 74, 104, 66)
      ..close();
    c.drawPath(
      glass,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(88, 92),
          40,
          const [Color(0x99F8FAFC), Color(0x66CBD5E1), Color(0x4D64748B)],
          const [0, 0.6, 1],
        ),
    );
    c.drawPath(glass, _stroke(const Color(0x99F1F5F9), 1.3));
    // Filament: its two wires and a coil broken in the middle.
    final wire = _stroke(_Colors.filament, 1.2);
    c.drawLine(const Offset(92, 66), const Offset(87, 96), wire);
    c.drawLine(const Offset(100, 66), const Offset(105, 96), wire);
    final left = Path()..moveTo(87, 96);
    final right = Path()..moveTo(105, 96);
    for (var i = 1; i <= 4; i++) {
      final dy = i.isOdd ? -3.0 : 3.0;
      left.lineTo(87 + i * 1.8, 96 + dy);
      right.lineTo(105 - i * 1.8, 96 + dy);
    }
    left.lineTo(94.6, 101);
    right.lineTo(97.4, 102);
    c.drawPath(left, wire);
    c.drawPath(right, wire);
    c.drawArc(
      Rect.fromCircle(center: const Offset(96, 99), radius: 20),
      3.5,
      0.9,
      false,
      _stroke(const Color(0xB3FFFFFF), 3),
    );
    // The wall switch, pressed on.
    c.drawLine(
      const Offset(178, 0),
      const Offset(178, 62),
      _stroke(_Colors.slate500, 2),
    );
    final plate = RRect.fromLTRBR(158, 62, 198, 116, const Radius.circular(5));
    c.drawRRect(
      plate.shift(const Offset(2, 3)),
      _blur(const Color(0x66000000), 3),
    );
    c.drawRRect(plate, _fill(_Colors.switchPlate));
    c.drawCircle(const Offset(178, 67), 1.6, _fill(_Colors.steelDark));
    c.drawCircle(const Offset(178, 111), 1.6, _fill(_Colors.steelDark));
    c.drawRRect(
      RRect.fromLTRBR(169, 76, 187, 102, const Radius.circular(3)),
      _fill(_Colors.slate300),
    );
    c.drawRRect(
      RRect.fromLTRBR(169, 76, 187, 89, const Radius.circular(3)),
      _fill(_Colors.slate400),
    );
    c.drawCircle(
      const Offset(178, 96),
      1.8,
      _fill(_Colors.red500.withValues(alpha: 0.8)),
    );
  }

  // --------------------------------------------------------------- notepad

  static void _notepad(Canvas c) {
    c.drawRect(
      Offset.zero & box,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(box.width, box.height),
          const [_Colors.desk, _Colors.deskDark],
        ),
    );
    final grain = _stroke(const Color(0x22000000), 1.2);
    for (var y = 8.0; y < box.height; y += 13) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < box.width; x += 16) {
        final bend = (x ~/ 16).isEven ? 2.5 : -2.5;
        path.quadraticBezierTo(x + 8, y + bend, x + 16, y);
      }
      c.drawPath(path, grain);
    }
    c.save();
    c.translate(100, 82);
    c.rotate(-0.07);
    const page = Rect.fromLTRB(-70, -64, 70, 70);
    c.drawRect(
      page.shift(const Offset(4, 6)),
      _blur(const Color(0x55000000), 6),
    );
    c.drawRect(page, _fill(_Colors.paperYellow));
    final rule = _stroke(_Colors.rule, 1);
    for (var y = -34.0; y < 70; y += 13) {
      c.drawLine(Offset(page.left, y), Offset(page.right, y), rule);
    }
    c.drawLine(
      Offset(-50, page.top),
      Offset(-50, page.bottom),
      _stroke(_Colors.margin, 1.2),
    );
    // Spiral binding.
    final coil = _stroke(_Colors.steelDark, 2);
    for (var i = 0; i < 9; i++) {
      final x = -60 + i * 15.0;
      c.drawCircle(Offset(x, -56), 2.4, _fill(_Colors.slate700));
      c.drawOval(
        Rect.fromCenter(center: Offset(x, -64), width: 6, height: 16),
        coil,
      );
    }
    // A line of writing and a big question mark.
    _scribble(
      c,
      from: -44,
      to: 20,
      base: -38,
      ink: _Colors.indigo700,
      size: 0.9,
    );
    _scribble(
      c,
      from: -44,
      to: 6,
      base: -25,
      ink: _Colors.indigo700,
      size: 0.9,
    );
    final mark = Path()
      ..moveTo(18, -4)
      ..cubicTo(18, -26, 52, -26, 50, -8)
      ..cubicTo(48, 4, 34, 4, 34, 18);
    c.drawPath(mark, _stroke(_Colors.indigo500, 5));
    c.drawCircle(const Offset(34, 30), 3.4, _fill(_Colors.indigo500));
    c.restore();
    _pencil(c, tip: const Offset(150, 132), angle: -0.42);
  }

  /// A yellow pencil lying on the desk, its point at [tip].
  static void _pencil(Canvas c, {required Offset tip, required double angle}) {
    c.save();
    c.translate(tip.dx, tip.dy);
    c.rotate(angle);
    c.drawRRect(
      RRect.fromLTRBR(8, 1, 114, 11, const Radius.circular(5)),
      _blur(const Color(0x4D000000), 3),
    );
    final point = Path()
      ..moveTo(0, 0)
      ..lineTo(6, -1.6)
      ..lineTo(6, 1.6)
      ..close();
    c.drawPath(point, _fill(_Colors.graphite));
    final wood = Path()
      ..moveTo(6, -1.6)
      ..lineTo(18, -5)
      ..lineTo(18, 5)
      ..lineTo(6, 1.6)
      ..close();
    c.drawPath(wood, _fill(_Colors.pencilWood));
    c.drawRect(
      const Rect.fromLTRB(18, -5, 92, 5),
      _vertical(-5, 5, [
        labShade(_Colors.pencil, 0.35),
        _Colors.pencil,
        labShade(_Colors.pencil, -0.3),
      ]),
    );
    final facet = _stroke(labShade(_Colors.pencil, -0.25), 0.8);
    c.drawLine(const Offset(18, -1.6), const Offset(92, -1.6), facet);
    c.drawLine(const Offset(18, 1.6), const Offset(92, 1.6), facet);
    c.drawRect(
      const Rect.fromLTRB(92, -5.2, 100, 5.2),
      _vertical(-5.2, 5.2, const [
        _Colors.steelLight,
        _Colors.steel,
        _Colors.steelDark,
      ]),
    );
    final band = _stroke(_Colors.steelDark, 0.8);
    c.drawLine(const Offset(94.5, -5.2), const Offset(94.5, 5.2), band);
    c.drawLine(const Offset(97.5, -5.2), const Offset(97.5, 5.2), band);
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        100,
        -5,
        111,
        5,
        topRight: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      _fill(_Colors.eraser),
    );
    c.restore();
  }
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
