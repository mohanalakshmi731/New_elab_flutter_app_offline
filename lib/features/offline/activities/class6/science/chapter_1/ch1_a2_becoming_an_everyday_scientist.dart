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

/// Class 6 Science • Chapter 1 • Activity 2
/// Becoming an Everyday Scientist ("Everyday Scientist Lab").
///
/// Native Flutter port of `Cl6S-Ch1-A2-BecomingAnEverydayScientist.html`
/// (Three.js r128 + GSAP). The HTML's 3D layer is a faint floor grid seen
/// by a PerspectiveCamera (fov 45) with three picture markers projected
/// from 3D points; [_ScenePainter] redraws it with the same camera and its
/// GSAP camera moves (ticker-driven tweens here). The drag-and-drop layers
/// the HTML lays over the canvas are Flutter widgets over the canvas, and
/// its photos (cooker, bicycle, room, people talking) are painted.
///
/// Scenario 1 (Everyday Scientists): three pictures float over the grid: a
/// kitchen where dal has spilled out of a pressure cooker (Cooker), a
/// bicycle with a flat tyre (Bicycle) and a dark room whose bulb does not
/// light (Light Bulb). The learner drags the three question cards from the
/// tray onto the numbered circles 1–3 below them (one card per circle; each
/// circle's 'Hint' tells who is wondering) and taps VERIFY.
///
/// Scenario 2 (Are You a Scientist?): six habit cards (Being curious, Keen
/// observation, Asking why, Guessing answer, Testing guess, Just memorising
/// facts) are sorted into two buckets: "Anyone who follows the scientific
/// method..." and "Science is not just about memorizing facts...". VERIFY
/// checks both buckets.
///
/// Scenario 3 (Better Together): under a picture of people talking, the
/// message "Science is rarely done ___ …" is completed by dragging the
/// words alone, large teams, friends and together into its four blanks.
/// VERIFY opens the Lab Conclusion.
///
/// A correct VERIFY turns the button green ('CORRECT!') and, 1.5 s later,
/// opens the next scenario (the Lab Conclusion after Scenario 3); with
/// cards missing or misplaced a toast says what to do.
class Ch1A2BecomingAnEverydayScientistPage extends StatefulWidget {
  const Ch1A2BecomingAnEverydayScientistPage({super.key});

  @override
  State<Ch1A2BecomingAnEverydayScientistPage> createState() =>
      _EverydayScientistLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'click' (VERIFY and the other buttons) and 'drag' (a card picked up) →
/// click (`science/click.mp3`), 'drop' (a card let go over a circle, bucket
/// or blank) → drop (`science/dropdown.mp3`), 'error' (VERIFY with cards
/// missing or misplaced) → wrong (`science/error.mp3`), 'success' (VERIFY
/// correct, the Lab Conclusion) → success (`math/success.mp3`). The shell
/// plays toggle (`science/dropdown.mp3`), scenario
/// (`science/page_open.mp3`), curtain (`science/curtain.mp3`) and correct
/// (`math/success.mp3`, a toast that is not an error).
enum _Sound implements LabTone {
  /// Generic button click; VERIFY (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A toast that is not an error.
  correct('audio/class6/math/success.mp3'),

  /// VERIFY with cards missing or misplaced (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// VERIFY correct and the Lab Conclusion (HTML `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A card picked up (HTML `drag`).
  pickup('audio/class6/science/click.mp3'),

  /// A card let go over a circle, bucket or blank (HTML `drop`).
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

/// Colours of the HTML page (Tailwind classes and its `<style>` rules) and
/// of the painted pictures.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color yellow400 = Color(0xFFFACC15);
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

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper`: `bg-[#f1f5f9] dark:bg-[#0f172a]` behind the
  /// transparent WebGL canvas.
  static const Color sceneLight = slate100;
  static const Color sceneDark = slate900;

  /// `GridHelper(30, 30, 0x000000, 0x000000)` at opacity 0.05.
  static const Color grid = Color(0x0D000000);

  /// Picture rings (`ring-emerald-500/50`, `ring-blue-500/50`,
  /// `ring-amber-500/50`) and their glows (`rgba(…, 0.3)`).
  static const Color ringKitchen = emerald500;
  static const Color ringBicycle = blue500;
  static const Color ringRoom = amber500;

  /// Marker label chip: `bg-slate-900/90`, `border-slate-700`, white text.
  static const Color chipBg = Color(0xE60F172A);
  static const Color chipBorder = slate700;
  static const Color chipText = white;

  /// Hint tooltips: `bg-slate-800`, `border-slate-700`, white text.
  static const Color tipBg = slate800;
  static const Color tipBorder = slate700;

  // ---------------------------------------------------- kitchen picture
  static const Color kitchenWall = Color(0xFFFDF6E3);
  static const Color kitchenTile = Color(0xFFEDE0C4);
  static const Color windowSky = Color(0xFFBAE6FD);
  static const Color windowFrame = Color(0xFFFFFFFF);
  static const Color counterTop = Color(0xFF78716C);
  static const Color cabinet = Color(0xFFB45309);
  static const Color cabinetDark = Color(0xFF92400E);
  static const Color handle = Color(0xFFFDE68A);
  static const Color stove = Color(0xFF27272A);
  static const Color stoveTop = Color(0xFF3F3F46);
  static const Color knob = Color(0xFFA1A1AA);
  static const Color flame = Color(0xFF38BDF8);
  static const Color flameCore = Color(0xFF1D4ED8);
  static const Color steel = Color(0xFFCBD5E1);
  static const Color steelLight = Color(0xFFF1F5F9);
  static const Color steelDark = Color(0xFF64748B);
  static const Color cookerHandle = Color(0xFF1C1917);
  static const Color dal = Color(0xFFEAB308);
  static const Color dalLight = Color(0xFFFDE047);
  static const Color dalDark = Color(0xFFCA8A04);
  static const Color steam = Color(0xCCFFFFFF);

  // ---------------------------------------------------- bicycle picture
  static const Color skyLow = Color(0xFFF0F9FF);
  static const Color cloud = Color(0xFFFFFFFF);
  static const Color wallBrick = Color(0xFFFED7AA);
  static const Color brickLine = Color(0xFFFDBA74);
  static const Color ground = Color(0xFFA8A29E);
  static const Color groundLine = Color(0xFF78716C);
  static const Color bush = Color(0xFF22C55E);
  static const Color bushDark = Color(0xFF15803D);
  static const Color frame = Color(0xFF2563EB);
  static const Color frameDark = Color(0xFF1E40AF);
  static const Color tyre = Color(0xFF1F2937);
  static const Color rim = Color(0xFF9CA3AF);
  static const Color spoke = Color(0xFFD1D5DB);
  static const Color saddle = Color(0xFF111827);
  static const Color chain = Color(0xFF4B5563);
  static const Color pump = Color(0xFFDC2626);

  // ------------------------------------------------------- room picture
  static const Color roomWall = Color(0xFFE7E5E4);
  static const Color roomWallShade = Color(0xFFD6D3D1);
  static const Color ceiling = Color(0xFFF5F5F4);
  static const Color night = Color(0xFF1E3A8A);
  static const Color nightLow = Color(0xFF312E81);
  static const Color moon = Color(0xFFFEF9C3);
  static const Color floorWood = Color(0xFFA16207);
  static const Color floorLine = Color(0xFF854D0E);
  static const Color cord = Color(0xFF292524);
  static const Color socket = Color(0xFF57534E);
  static const Color bulbGlass = Color(0xFFE5E7EB);
  static const Color bulbShade = Color(0xFF9CA3AF);
  static const Color filament = Color(0xFF52525B);
  static const Color switchPlate = Color(0xFFFAFAF9);
  static const Color ladder = Color(0xFFF59E0B);
  static const Color ladderDark = Color(0xFFB45309);
  static const Color toolbox = Color(0xFFDC2626);
  static const Color toolboxDark = Color(0xFF991B1B);
  static const Color sofa = Color(0xFF0D9488);
  static const Color sofaDark = Color(0xFF115E59);

  // ------------------------------------------- people talking picture
  static const Color skinLight = Color(0xFFF1C27D);
  static const Color skinMid = Color(0xFFE0AC69);
  static const Color skinDark = Color(0xFF8D5524);
  static const Color skinTan = Color(0xFFC68642);
  static const Color hair = Color(0xFF1C1917);
  static const Color hairBrown = Color(0xFF78350F);
  static const Color shirtIndigo = indigo500;
  static const Color shirtEmerald = emerald500;
  static const Color shirtAmber = amber500;
  static const Color shirtRose = Color(0xFFF43F5E);
  static const Color table = Color(0xFFD6D3D1);
  static const Color tableEdge = Color(0xFFA8A29E);
  static const Color bubble = Color(0xFFF8FAFC);
  static const Color bubbleEdge = Color(0xFFCBD5E1);
  static const Color mouth = Color(0xFF7F1D1D);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xF20F172A), // --glass-bg rgba(15, 23, 42, 0.95)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0x801E293B), // bg-slate-800/50
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
    toastBg: Color(0xF20F172A), // toast bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // text-indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
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
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
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
/// are the HTML sidebar font-size setting: 18 px, slider 16–32 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 18,
  minSize: 16,
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
// From the HTML `i18n`, `tokensS1`, `tokensS2` and `tokensS3` tables
// (Telugu dropped). The HTML has no step list: its teacher board shows the
// scenario's `sN_desc` block (kept line by line in [_descLines]) and the
// learner may fill the drop zones in any order before VERIFY. Here each
// scenario is split into steps, one per drop zone (S1 circles, S3 blanks)
// or group of habit cards (S2, following the sentences of `s2_desc`), then
// VERIFY. `sN_step_M` are those steps (sidebar), `sN_hud_M` their short
// canvas lines and `s2_focus_M` the concepts of S2's steps (S1 and S3 take
// theirs from the `sN_desc` lines). Keys under "Added." are texts the HTML
// did not have or showed in English only.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Everyday Scientist Lab',
    'app_subtitle': 'Class 6 • The Wonderful world of science',
    'sc1_title': '1. Everyday Scientists',
    'sc2_title': '2. Are You a Scientist?',
    'sc3_title': '3. Better Together',
    'taskInstr': 'Steps',
    's1_obj': 'See how everyday people are, in a way, scientists.',
    's2_obj': 'Spot the scientist-like habits in yourself.',
    's3_obj': 'Discover why science is rarely done alone.',
    'c_cook': 'Cook wondering about the dal',
    'c_mech': 'Mechanic wondering about flat tyre',
    'c_elec': 'Electrician wondering about bulb',
    'lbl_cooker': 'Cooker',
    'lbl_bike': 'Bicycle',
    'lbl_bulb': 'Light Bulb',
    's2_habits_title': 'Scientist Habits',
    's2_buckets_title': 'Are You a Scientist?',
    's3_t1': 'Science is rarely done ',
    's3_t2': '. Scientists across the world work together, often in ',
    's3_t3': '. So, if you cannot find an answer yourself, ask your ',
    's3_t4': ' to help you out! It is always more fun to discover things ',
    's3_t5': '.',
    'hint_b1': 'By yourself',
    'hint_b2': 'Groups of people',
    'hint_b3': 'People you know',
    'hint_b4': 'As a team',
    'conclusion_title': 'Lab Conclusion',
    'conclusion_text':
        "Anyone who follows the scientific method is working like a scientist. And science is rarely done alone — it's always more fun to discover things together.",
    'btn_verify': 'VERIFY',
    // Cards (HTML `tokensS1`, `tokensS2`, `tokensS3`).
    'tok_cook': 'Why has the dal spilled out of the cooker?',
    'tok_bike': 'Why is the tyre flat?',
    'tok_bulb': 'Why is the light bulb not working?',
    'tok_curious': 'Being curious',
    'tok_observe': 'Keen observation',
    'tok_ask': 'Asking why',
    'tok_guess': 'Guessing answer',
    'tok_test': 'Testing guess',
    'tok_memorise': 'Just memorising facts',
    'tok_alone': 'alone',
    'tok_teams': 'large teams',
    'tok_friends': 'friends',
    'tok_together': 'together',
    // The HTML shows these in English only (its markup and `showToast`
    // calls); the Hindi is added.
    'hint': 'Hint',
    'hint_bucket_1': '"Anyone who follows the scientific method..."',
    'hint_bucket_2': '"Science is not just about memorizing facts..."',
    'toast_place_all': 'Place all items first!',
    'toast_not_quite':
        'Not quite right. Check the Teacher Board and try again!',
    'toast_already': 'Already placed here! Move the other one first.',
    'btn_correct': 'CORRECT!',
    'alt_kitchen': 'Kitchen Scene',
    'alt_bike': 'Bicycle Scene',
    'alt_room': 'Room Scene',
    'alt_people': 'People Talking',
    // Added.
    's1_step_1':
        'Drag the question the cook is asking from the tray and drop it onto circle 1 (Cooker).',
    's1_step_2':
        'Drag the question the bicycle repair person is asking and drop it onto circle 2 (Bicycle).',
    's1_step_3':
        'Drag the question the electrician is asking and drop it onto circle 3 (Light Bulb).',
    's1_step_4': 'Tap VERIFY to check your answers.',
    's1_hud_1': "DRAG the cook's question onto circle 1 (Cooker).",
    's1_hud_2':
        "DRAG the bicycle repair person's question onto circle 2 (Bicycle).",
    's1_hud_3': "DRAG the electrician's question onto circle 3 (Light Bulb).",
    's1_hud_4': 'TAP VERIFY to check your answers.',
    's2_focus_1':
        'To learn science well, be curious and observe your surroundings keenly.',
    's2_focus_2': 'Start posing questions, asking how and why.',
    's2_focus_3': 'Guess a possible answer and test it.',
    's2_step_1':
        "Drag the 'Being curious' and 'Keen observation' cards into the bucket where they belong. Tap a bucket's ? for a hint.",
    's2_step_2': "Drag the 'Asking why' card into the bucket where it belongs.",
    's2_step_3':
        "Drag the 'Guessing answer' and 'Testing guess' cards into the bucket where they belong.",
    's2_step_4':
        "Drag the 'Just memorising facts' card into the bucket where it belongs.",
    's2_step_5': 'Tap VERIFY to check both buckets.',
    's2_hud_1':
        "DRAG 'Being curious' and 'Keen observation' into the right bucket.",
    's2_hud_2': "DRAG 'Asking why' into the right bucket.",
    's2_hud_3':
        "DRAG 'Guessing answer' and 'Testing guess' into the right bucket.",
    's2_hud_4': "DRAG 'Just memorising facts' into the right bucket.",
    's2_hud_5': 'TAP VERIFY to check both buckets.',
    's3_step_1':
        "Drag the word that means 'By yourself' from the tray into the first blank.",
    's3_step_2':
        "Drag the word that means 'Groups of people' into the second blank.",
    's3_step_3':
        "Drag the word that means 'People you know' into the third blank.",
    's3_step_4': "Drag the word that means 'As a team' into the fourth blank.",
    's3_step_5': 'Tap VERIFY to check the message.',
    's3_hud_1': "DRAG the word for 'By yourself' into blank 1.",
    's3_hud_2': "DRAG the word for 'Groups of people' into blank 2.",
    's3_hud_3': "DRAG the word for 'People you know' into blank 3.",
    's3_hud_4': "DRAG the word for 'As a team' into blank 4.",
    's3_hud_5': 'TAP VERIFY to check the message.',
    'sem_circle': 'Circle {n}: {name}',
    'sem_bucket': 'Bucket {n}',
    'sem_blank': 'Blank {n}',
    'sem_hint': 'Hint: {text}',
    'scene_s1':
        'Three pictures over a floor grid: a kitchen where dal has spilled out of a pressure cooker, a bicycle with a flat tyre and a dark room whose light bulb is not working',
    'scene_grid': 'A faint floor grid',
  },
  'hi': {
    'app_title': 'हर रोज़ के वैज्ञानिक लैब',
    'app_subtitle': 'कक्षा 6 • विज्ञान की अद्भुत दुनिया',
    'sc1_title': '1. हर रोज़ के वैज्ञानिक',
    'sc2_title': '2. क्या आप एक वैज्ञानिक हैं?',
    'sc3_title': '3. एक साथ बेहतर',
    'taskInstr': 'चरण',
    's1_obj': 'देखें कि रोज़मर्रा के लोग किस तरह वैज्ञानिक हैं।',
    's2_obj': 'अपने अंदर वैज्ञानिक जैसी आदतें खोजें।',
    's3_obj': 'पता लगाएँ कि विज्ञान शायद ही कभी अकेले क्यों किया जाता है।',
    'c_cook': 'दाल के बारे में सोचता रसोइया',
    'c_mech': 'फ्लैट टायर के बारे में सोचता मैकेनिक',
    'c_elec': 'बल्ब के बारे में सोचता इलेक्ट्रीशियन',
    'lbl_cooker': 'कुकर',
    'lbl_bike': 'साइकिल',
    'lbl_bulb': 'बल्ब',
    's2_habits_title': 'वैज्ञानिक की आदतें',
    's2_buckets_title': 'क्या आप एक वैज्ञानिक हैं?',
    's3_t1': 'विज्ञान शायद ही कभी ',
    's3_t2':
        ' किया जाता है। दुनिया भर के वैज्ञानिक एक साथ काम करते हैं, अक्सर ',
    's3_t3': ' में। इसलिए, यदि आप उत्तर नहीं खोज सकते हैं, तो अपने ',
    's3_t4': ' से पूछें! चीजों को ',
    's3_t5': ' खोजना हमेशा अधिक मजेदार होता है।',
    'hint_b1': 'अकेले',
    'hint_b2': 'बड़े समूहों',
    'hint_b3': 'दोस्तों',
    'hint_b4': 'एक साथ',
    'conclusion_title': 'लैब निष्कर्ष',
    'conclusion_text':
        'जो कोई भी वैज्ञानिक पद्धति का पालन करता है वह एक वैज्ञानिक की तरह काम कर रहा है। और विज्ञान शायद ही कभी अकेले किया जाता है - चीजों को एक साथ खोजना हमेशा अधिक मजेदार होता है।',
    'btn_verify': 'सत्यापित करें',
    'tok_cook': 'कुकर से दाल बाहर क्यों गिर गई है?',
    'tok_bike': 'टायर फ्लैट क्यों है?',
    'tok_bulb': 'बल्ब काम क्यों नहीं कर रहा है?',
    'tok_curious': 'जिज्ञासु होना',
    'tok_observe': 'गहरा अवलोकन',
    'tok_ask': 'क्यों पूछना',
    'tok_guess': 'उत्तर का अनुमान लगाना',
    'tok_test': 'अनुमान का परीक्षण',
    'tok_memorise': 'बस तथ्यों को याद रखना',
    'tok_alone': 'अकेले',
    'tok_teams': 'बड़े समूहों',
    'tok_friends': 'दोस्तों',
    'tok_together': 'एक साथ',
    'hint': 'संकेत',
    'hint_bucket_1': '"जो कोई भी वैज्ञानिक पद्धति का पालन करता है..."',
    'hint_bucket_2': '"विज्ञान केवल तथ्यों को याद करने के बारे में नहीं है..."',
    'toast_place_all': 'पहले सभी कार्ड रखें!',
    'toast_not_quite':
        'पूरी तरह सही नहीं। टीचर बोर्ड देखें और फिर से प्रयास करें!',
    'toast_already': 'यहाँ पहले से एक कार्ड रखा है! पहले उसे हटाएँ।',
    'btn_correct': 'सही!',
    'alt_kitchen': 'रसोई का दृश्य',
    'alt_bike': 'साइकिल का दृश्य',
    'alt_room': 'कमरे का दृश्य',
    'alt_people': 'बातें करते लोग',
    's1_step_1':
        'रसोइया जो प्रश्न पूछ रहा है, उसे ट्रे से खींचकर गोले 1 (कुकर) पर छोड़ें।',
    's1_step_2':
        'मैकेनिक जो प्रश्न पूछ रहा है, उसे खींचकर गोले 2 (साइकिल) पर छोड़ें।',
    's1_step_3':
        'इलेक्ट्रीशियन जो प्रश्न पूछ रहा है, उसे खींचकर गोले 3 (बल्ब) पर छोड़ें।',
    's1_step_4': "अपने उत्तर जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's1_hud_1': 'रसोइए का प्रश्न खींचकर गोले 1 (कुकर) पर छोड़ें।',
    's1_hud_2': 'मैकेनिक का प्रश्न खींचकर गोले 2 (साइकिल) पर छोड़ें।',
    's1_hud_3': 'इलेक्ट्रीशियन का प्रश्न खींचकर गोले 3 (बल्ब) पर छोड़ें।',
    's1_hud_4': "अपने उत्तर जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's2_focus_1':
        'विज्ञान को अच्छी तरह से सीखने के लिए, जिज्ञासु बनें और अपने आस-पास का निरीक्षण करें।',
    's2_focus_2': 'प्रश्न पूछना शुरू करें: कैसे और क्यों?',
    's2_focus_3': 'संभावित उत्तर का अनुमान लगाएँ और उसका परीक्षण करें।',
    's2_step_1':
        "'जिज्ञासु होना' और 'गहरा अवलोकन' कार्डों को उस बाल्टी में खींचें जिसमें वे आते हैं। संकेत के लिए बाल्टी के ? पर टैप करें।",
    's2_step_2':
        "'क्यों पूछना' कार्ड को उस बाल्टी में खींचें जिसमें वह आता है।",
    's2_step_3':
        "'उत्तर का अनुमान लगाना' और 'अनुमान का परीक्षण' कार्डों को उस बाल्टी में खींचें जिसमें वे आते हैं।",
    's2_step_4':
        "'बस तथ्यों को याद रखना' कार्ड को उस बाल्टी में खींचें जिसमें वह आता है।",
    's2_step_5': "दोनों बाल्टियाँ जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's2_hud_1': "'जिज्ञासु होना' और 'गहरा अवलोकन' को सही बाल्टी में खींचें।",
    's2_hud_2': "'क्यों पूछना' को सही बाल्टी में खींचें।",
    's2_hud_3':
        "'उत्तर का अनुमान लगाना' और 'अनुमान का परीक्षण' को सही बाल्टी में खींचें।",
    's2_hud_4': "'बस तथ्यों को याद रखना' को सही बाल्टी में खींचें।",
    's2_hud_5': "दोनों बाल्टियाँ जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's3_step_1':
        'ट्रे से सही शब्द खींचकर पहले रिक्त स्थान में छोड़ें। संकेत के लिए उसके ? पर टैप करें।',
    's3_step_2': 'सही शब्द खींचकर दूसरे रिक्त स्थान में छोड़ें।',
    's3_step_3': 'सही शब्द खींचकर तीसरे रिक्त स्थान में छोड़ें।',
    's3_step_4': 'सही शब्द खींचकर चौथे रिक्त स्थान में छोड़ें।',
    's3_step_5': "संदेश जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    's3_hud_1': 'सही शब्द को रिक्त स्थान 1 में खींचें।',
    's3_hud_2': 'सही शब्द को रिक्त स्थान 2 में खींचें।',
    's3_hud_3': 'सही शब्द को रिक्त स्थान 3 में खींचें।',
    's3_hud_4': 'सही शब्द को रिक्त स्थान 4 में खींचें।',
    's3_hud_5': "संदेश जाँचने के लिए 'सत्यापित करें' पर टैप करें।",
    'sem_circle': 'गोला {n}: {name}',
    'sem_bucket': 'बाल्टी {n}',
    'sem_blank': 'रिक्त स्थान {n}',
    'sem_hint': 'संकेत: {text}',
    'scene_s1':
        'फ़र्श की ग्रिड पर तीन चित्र: रसोई जहाँ कुकर से दाल बाहर गिर गई है, फ्लैट टायर वाली साइकिल और अँधेरा कमरा जिसका बल्ब नहीं जल रहा',
    'scene_grid': 'फ़र्श की हल्की ग्रिड',
  },
};

/// The HTML `sN_desc` blocks (teacher board "Steps"), one entry per line
/// of its `<br>` breaks ('' is the empty line before the task).
const Map<String, List<List<String>>> _descLines = {
  'en': [
    [
      '1. Anyone who follows the scientific method is working like a scientist.',
      '2. The cook wonders why the dal spilled.',
      '3. The bicycle repair person wonders why the tyre is flat.',
      "4. The electrician wonders why the bulb isn't working.",
      '',
      'Drag the questions to the correct neutral scene markers.',
    ],
    [
      'To learn science well, be curious and observe your surroundings keenly. Start posing questions, asking how and why. Guess a possible answer and test it.',
      '',
      'Drag the habit cards into the correct bucket.',
    ],
    [
      'Science is rarely done alone. Scientists across the world work together, often in large teams.',
      '',
      'Fill in the blanks to complete the message.',
    ],
  ],
  'hi': [
    [
      '1. जो कोई भी वैज्ञानिक पद्धति का पालन करता है वह एक वैज्ञानिक की तरह काम कर रहा है।',
      '2. रसोइया सोचता है कि दाल क्यों गिर गई।',
      '3. मैकेनिक सोचता है कि टायर फ्लैट क्यों है।',
      '4. इलेक्ट्रीशियन सोचता है कि बल्ब काम क्यों नहीं कर रहा है।',
      '',
      'प्रश्नों को सही दृश्यों तक खींचें।',
    ],
    [
      'विज्ञान को अच्छी तरह से सीखने के लिए, जिज्ञासु बनें और अपने आस-पास का निरीक्षण करें।',
      '',
      'आदत कार्ड को सही बाल्टी में खींचें।',
    ],
    [
      'विज्ञान शायद ही कभी अकेले किया जाता है। दुनिया भर के वैज्ञानिक एक साथ काम करते हैं।',
      '',
      'संदेश को पूरा करने के लिए रिक्त स्थान भरें।',
    ],
  ],
};

/// The `sN_desc` lines of scenario [index] in [lang].
List<String> _desc(LabLang lang, int index) =>
    (_descLines[lang.code] ?? _descLines['en']!)[index];

/// A numbered `sN_desc` line without its number ("2. The cook …" → "The
/// cook …").
String _unnumbered(String line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '');

// ===================================================================== MODEL

/// Number of steps of each scenario: one per drop zone (S1 circles, S3
/// blanks) or group of habit cards (S2), then VERIFY.
const List<int> _stepCounts = [4, 5, 5];

/// The drop zones (HTML `data-target-id`): S1's numbered circles under the
/// pictures, S2's buckets and S3's blanks.
enum _Zone {
  /// HTML `kitchen-scene-target` (circle 1, under the Cooker picture).
  kitchen(0, 1, 'c_cook', 'lbl_cooker'),

  /// HTML `bicycle-scene-target` (circle 2, under the Bicycle picture).
  bicycle(0, 2, 'c_mech', 'lbl_bike'),

  /// HTML `bulb-scene-target` (circle 3, under the Light Bulb picture).
  bulb(0, 3, 'c_elec', 'lbl_bulb'),

  /// HTML `scientific-thinking` (the first bucket).
  scientist(1, 1, 'hint_bucket_1', ''),

  /// HTML `not-enough-alone` (the second bucket).
  notEnough(1, 2, 'hint_bucket_2', ''),

  /// HTML `blank-1` … `blank-4`.
  blank1(2, 1, 'hint_b1', ''),
  blank2(2, 2, 'hint_b2', ''),
  blank3(2, 3, 'hint_b3', ''),
  blank4(2, 4, 'hint_b4', '');

  const _Zone(this.scenario, this.number, this.hintKey, this.nameKey);

  /// Scenario (0–2) the zone belongs to.
  final int scenario;

  /// 1-based number in its scenario.
  final int number;

  /// The zone's hint tooltip.
  final String hintKey;

  /// The picture above an S1 circle.
  final String nameKey;

  /// Circles and blanks take one card, buckets any number (HTML
  /// `pointerup`: the "Already placed here!" check skips Scenario 2).
  bool get single => scenario != 1;

  static List<_Zone> of(int scenario) => [
    for (final z in values)
      if (z.scenario == scenario) z,
  ];
}

/// How a card is drawn (HTML `renderTokens` style types).
enum _CardStyle {
  /// `card-wide`: icon over the question (S1).
  wide,

  /// `card-square`: icon over the habit, square (S2).
  square,

  /// `card-small`: the word alone (S3).
  small,
}

/// The cards (HTML `tokensS1`, `tokensS2`, `tokensS3`), with the zone
/// each belongs in and its Phosphor icon (as the closest Material icon).
enum _Token {
  /// `cook-question-token` (`ph-cooking-pot`).
  cook('tok_cook', _Zone.kitchen, Icons.soup_kitchen_outlined),

  /// `bicycle-question-token` (`ph-bicycle`).
  bicycle('tok_bike', _Zone.bicycle, Icons.pedal_bike),

  /// `electrician-question-token` (`ph-lightbulb`).
  electrician('tok_bulb', _Zone.bulb, Icons.lightbulb_outline),

  /// `being-curious` (`ph-magnifying-glass`).
  curious('tok_curious', _Zone.scientist, Icons.search),

  /// `observing-keenly` (`ph-eye`).
  observing('tok_observe', _Zone.scientist, Icons.visibility_outlined),

  /// `asking-how-why` (`ph-question`).
  asking('tok_ask', _Zone.scientist, Icons.question_mark),

  /// `guessing-an-answer` (`ph-lightbulb`).
  guessing('tok_guess', _Zone.scientist, Icons.lightbulb_outline),

  /// `testing-the-guess` (`ph-flask`).
  testing('tok_test', _Zone.scientist, Icons.science_outlined),

  /// `just-memorising-facts` (`ph-brain`).
  memorising('tok_memorise', _Zone.notEnough, Icons.psychology_outlined),

  /// `alone-token`.
  alone('tok_alone', _Zone.blank1, null),

  /// `large-teams-token`.
  largeTeams('tok_teams', _Zone.blank2, null),

  /// `friends-token`.
  friends('tok_friends', _Zone.blank3, null),

  /// `together-token`.
  together('tok_together', _Zone.blank4, null);

  const _Token(this.textKey, this.target, this.icon);

  final String textKey;

  /// The zone the card belongs in (HTML `target`).
  final _Zone target;
  final IconData? icon;

  int get scenario => target.scenario;

  _CardStyle get style => switch (scenario) {
    0 => _CardStyle.wide,
    1 => _CardStyle.square,
    _ => _CardStyle.small,
  };

  static List<_Token> of(int scenario) => [
    for (final t in values)
      if (t.scenario == scenario) t,
  ];
}

/// Scenario 2's steps: the habit cards in the order the sentences of
/// `s2_desc` name them (curious and observing; asking; guessing and
/// testing), then the card that is not enough alone.
const List<List<_Token>> _habitSteps = [
  [_Token.curious, _Token.observing],
  [_Token.asking],
  [_Token.guessing, _Token.testing],
  [_Token.memorising],
];

/// The three scenarios for [lang], built from the string tables.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  List<LabStep> steps(int n, List<String> concepts) => [
    for (var i = 1; i <= _stepCounts[n - 1]; i++)
      LabStep(concept: concepts[i - 1], action: t('s${n}_step_$i')),
  ];
  final d1 = _desc(lang, 0).map(_unnumbered).toList();
  final d3 = _desc(lang, 2);
  return [
    // S1: each circle's step takes the desc line of who is wondering; the
    // VERIFY step the first line ("Anyone who follows …").
    LabScenarioData(
      title: t('sc1_title'),
      objective: t('s1_obj'),
      steps: steps(1, [d1[1], d1[2], d1[3], d1[0]]),
    ),
    LabScenarioData(
      title: t('sc2_title'),
      objective: t('s2_obj'),
      steps: steps(2, [
        t('s2_focus_1'),
        t('s2_focus_2'),
        t('s2_focus_3'),
        t('hint_bucket_2'),
        '',
      ]),
    ),
    // S3: the blanks' steps keep the message hidden; VERIFY takes the desc
    // line that states it.
    LabScenarioData(
      title: t('sc3_title'),
      objective: t('s3_obj'),
      steps: steps(3, ['', '', '', '', d3.first]),
    ),
  ];
}

// ===================================================================== SCENE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// HTML camera: `PerspectiveCamera(45, …)`.
const double _fovDegrees = 45;
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `GridHelper(30, 30, 0x000000, 0x000000)`: lines 1 unit apart from
/// -15 to 15 on the floor. Lines are cut where they pass closer than
/// [_gridClip] to the camera plane (Scenario 3's camera stands over the
/// grid).
const int _gridHalf = 15;
const double _gridClip = 0.3;

/// HTML `loadScenario`: Scenario 2 dims the WebGL canvas to `opacity: 0.1`.
const double _dimOpacity = 0.1;

/// GSAP camera tweens (`duration: 1`, default ease `power1.out`).
const double _camSeconds = 1;

/// HTML camera poses: `camera.position.set(0, 5, 20)` looking at the
/// origin (Scenario 1, `resetCamera`), and `{x: 8, y: 5, z: 10}` looking at
/// (8, 0, 0) (Scenario 3).
const _Pose _poseS1 = _Pose(_V(0, 5, 20), _V.zero);
const _Pose _poseS3 = _Pose(_V(8, 5, 10), _V(8, 0, 0));

/// HTML `markers`: the three pictures at (-8, 3, 0), (0, 3, 0) and (8, 3,
/// 0). Each is a `w-56 h-40` card (224 x 160 css px on a canvas about 640
/// px tall, so 196 x 140 on this 560 px stage) with its label `mt-3`
/// below, scaled by `clamp(20 / distance, 0.5, 2.5)` and centred on its
/// point (`translate(-50%, -50%)`).
const List<_V> _markerPos = [_V(-8, 3, 0), _V(0, 3, 0), _V(8, 3, 0)];
const Size _markerCard = Size(196, 140);
const double _markerGap = 12;
const double _markerRef = 20;
const double _markerMinScale = 0.5;
const double _markerMaxScale = 2.5;

/// `rounded-xl`, `ring-4` and the `shadow-[0_0_30px_…]` glow.
const double _markerRadius = 12;
const double _markerRing = 4;
const double _markerGlow = 30;

/// Room kept around a picture for its ring and glow when it is fitted.
const double _markerMargin = 10;

/// Marker labels: `text-sm` bold, `tracking-widest`, `px-4 py-1.5`; 12.5
/// design px, enlarged up to 1.8x on small stages so they stay readable on
/// phones.
const double _labelPx = 12.5;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _chipPadX = 1.1;
const double _chipPadY = 0.45;
const double _labelTracking = 0.1;

/// `.marker-label` `transition-opacity duration-300`.
const double _labelFadeSeconds = 0.3;

/// Longest frame step used by the tweens (s), so a stalled frame does not
/// make an animation jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the pictures above the Scenario 1 board) slides like
/// the sidebar.
const double _framingSeconds = 0.38;

/// Largest and smallest zoom of the fitted pictures (the HTML camera is
/// zoom 1).
const double _maxZoom = 1.1;
const double _minZoom = 0.3;

/// HTML: VERIFY shows 'CORRECT!' for 1.5 s before the next scenario.
const int _correctMs = 1500;

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

/// The camera's position and `controls.target`.
@immutable
class _Pose {
  const _Pose(this.position, this.target);

  final _V position;
  final _V target;

  _Pose lerpTo(_Pose o, double t) =>
      _Pose(_V.lerp(position, o.position, t), _V.lerp(target, o.target, t));
}

/// Where the camera's look-at point lands on the stage and how much the
/// scene is enlarged (the HTML camera is [base]).
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

/// The HTML PerspectiveCamera (fov 45) at [_Pose] as a pinhole projection
/// onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_Pose pose, _Framing framing) {
    final f = (pose.target - pose.position).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      pose.position,
      f,
      r,
      r.cross(f),
      framing.center,
      framing.zoom,
      _focal * framing.zoom,
    );
  }

  const _Cam._(
    this.eye,
    this.f,
    this.r,
    this.u,
    this.center,
    this.zoom,
    this.scale,
  );

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;
  final double zoom;

  /// Design pixels per world unit at depth 1.
  final double scale;

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

  /// The part of the segment [a]–[b] at least [clip] in front of the
  /// camera, projected; null when it is all behind.
  (Offset, Offset)? segment(_V a, _V b, double clip) {
    final da = depth(a), db = depth(b);
    if (da < clip && db < clip) return null;
    var pa = a, pb = b;
    if (da < clip) pa = _V.lerp(a, b, (clip - da) / (db - da));
    if (db < clip) pb = _V.lerp(b, a, (clip - db) / (da - db));
    return (p(pa), p(pb));
  }

  /// HTML marker scale: `Math.max(0.5, Math.min(2.5, 20 / distance))`.
  double markerScale(_V w) =>
      (_markerRef / (eye - w).length).clamp(_markerMinScale, _markerMaxScale);

  /// The card of picture [i] and the anchor (top centre) of its label, for
  /// a label chip [labelH] tall: the card, gap and label are centred on
  /// the projected point, as in the HTML.
  (Rect, Offset) marker(int i, double labelH) {
    final pos = _markerPos[i];
    final c = p(pos);
    final k = markerScale(pos) * zoom;
    final w = _markerCard.width * k;
    final h = _markerCard.height * k;
    final gap = _markerGap * k;
    final top = c.dy - (h + gap + labelH) / 2;
    return (
      Rect.fromLTWH(c.dx - w / 2, top, w, h),
      Offset(c.dx, top + h + gap),
    );
  }
}

/// What the framing keeps in view: a point of the base projection (the
/// HTML camera at zoom 1) and a rect around it that does not scale with the
/// zoom (a label chip; empty for a point of a picture).
typedef _Focus = (Offset, Rect);

/// Best framing for [focus] inside [free], clear of the [hard] obstacles
/// (all in design coordinates), at most [maxZoom]. Pictures scale with the
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

/// Mutable scene read by the painter every frame, and the cards'
/// placements read by the boards.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// Where each placed card is (HTML `placements`), in the order they were
  /// placed.
  final Map<_Token, _Zone> placed = {};

  /// Tilt of a card dropped in a bucket (HTML `rotate(±10deg)`), in rad.
  final Map<_Token, double> tilt = {};

  /// The scenario's cards in their (shuffled) tray order (HTML
  /// `renderTokens`).
  final List<_Token> tray = [];

  /// VERIFY found every card in place; cleared when a card moves again.
  bool solved = false;

  /// VERIFY shows 'CORRECT!' (1.5 s, until the next scenario opens or the
  /// conclusion shows); cards cannot be moved meanwhile.
  bool celebrating = false;

  // ---------------------------------------------------------------- camera
  _Pose _camFrom = _poseS1;
  _Pose _camTo = _poseS1;
  double _camStart = -1;

  /// Opacity of the marker labels (the 'Toggle Labels' tool fades them).
  double labelAlpha = 1;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// HTML `loadScenario(step)`: clears the placements, shuffles the tray
  /// and moves the camera (Scenario 2 keeps it where it is).
  void load(int index, math.Random random) {
    scenario = index;
    placed.clear();
    tilt.clear();
    tray
      ..clear()
      ..addAll(_Token.of(index)..shuffle(random));
    solved = false;
    celebrating = false;
    if (index == 0) moveCamera(_poseS1);
    if (index == 2) moveCamera(_poseS3);
  }

  /// GSAP `gsap.to(camera.position, …)` and `gsap.to(controls.target, …)`.
  void moveCamera(_Pose to) {
    _camFrom = pose;
    _camTo = to;
    _camStart = time;
  }

  /// The camera now (`power1.out` between the tween's ends).
  _Pose get pose {
    if (_camStart < 0) return _camTo;
    final t = ((time - _camStart) / _camSeconds).clamp(0.0, 1.0);
    final e = 1 - (1 - t) * (1 - t);
    return _camFrom.lerpTo(_camTo, e);
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(pose, framing);

  /// Label fade and framing slide.
  void advance(double dt, {required bool labels}) {
    final target = labels ? 1.0 : 0.0;
    final step = dt / _labelFadeSeconds;
    labelAlpha = labelAlpha < target
        ? math.min(target, labelAlpha + step)
        : math.max(target, labelAlpha - step);
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

  // ------------------------------------------------------------ placements

  /// The card in [zone] (circles and blanks hold one).
  _Token? occupant(_Zone zone) {
    for (final e in placed.entries) {
      if (e.value == zone) return e.key;
    }
    return null;
  }

  /// The cards in [zone], in the order they were dropped.
  List<_Token> inZone(_Zone zone) => [
    for (final e in placed.entries)
      if (e.value == zone) e.key,
  ];

  /// HTML `placeToken`: a card dropped in a bucket gets a random tilt of
  /// up to 10°.
  void place(_Token token, _Zone zone, math.Random random) {
    placed
      ..remove(token)
      ..[token] = zone;
    if (zone.scenario == 1) {
      tilt[token] = (random.nextDouble() * 20 - 10) * math.pi / 180;
    }
    solved = false;
  }

  /// The card goes back to the tray.
  void unplace(_Token token) {
    placed.remove(token);
    tilt.remove(token);
    solved = false;
  }

  /// HTML `updateVerifyBtn`: every card of the scenario is placed.
  bool get allPlaced => _Token.of(scenario).every(placed.containsKey);

  /// HTML VERIFY check: every placed card is in its own zone.
  bool get allCorrect => placed.entries.every((e) => e.key.target == e.value);

  /// The pictures are shown (HTML `.icon-marker` displayed in Scenario 1).
  bool get markersShown => scenario == 0;

  /// The WebGL canvas opacity.
  double get sceneOpacity => scenario == 1 ? _dimOpacity : 1;
}

/// Top-left of a chip of [size] relative to its anchor (x, y alignment: -1
/// left / top edge, 0 centre, 1 right / bottom edge).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// A marker label hangs from its anchor (top centre).
const (double, double) _hang = (0, -1);

// ===================================================================== STATE

/// Shell layout the boards keep clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; x UI scale) and, on screens
/// shorter than [_compactBelow] (phones in landscape), the compact layouts.
const double _hudBand = 56;
const double _compactBelow = 480;

/// The fixed menu button at the canvas' top-left while the sidebar is
/// collapsed (16 dp from the corner, 48 dp).
const double _menuInset = 16;
const double _menuSize = 48;

/// Canvas px kept free around the shell's cards.
const double _cardGap = 8;

/// The S1 marker labels, left to right.
const List<String> _markerKeys = ['lbl_cooker', 'lbl_bike', 'lbl_bulb'];

/// A board: its natural size, its widget, where it sits in its area
/// (Scenario 1 at the bottom, under the pictures; the others centred) and
/// how much it may be enlarged to use the room it has (Scenario 1 leaves
/// the room above it to the pictures).
@immutable
class _Board {
  const _Board(this.size, this.child, this.alignment, {this.maxScale = 1});

  final Size size;
  final Widget child;
  final Alignment alignment;
  final double maxScale;
}

/// Boards are drawn at the shell's UI scale up to this, then enlarged
/// (Scenarios 2 and 3) to fill their room up to [_boardGrow].
const double _boardMaxUi = 1.2;
const double _boardGrow = 1.25;

/// Habit cards in a bucket show their text from this size (px) up.
const double _miniTextMin = 6.5;

/// Text measuring for the boards: the canvas' text style and scaler, so a
/// board's size is known before it is laid out.
class _Type {
  _Type(this.base, this.scaler);

  final TextStyle base;
  final TextScaler scaler;

  /// Size of [text] in [style], wrapped at [maxWidth].
  Size measure(
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
    int? maxLines,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: base.merge(style)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    final size = tp.size;
    tp.dispose();
    return size;
  }

  /// Height of the Scenario 3 message: [parts] with a [blank] between each
  /// two, wrapped at [maxWidth].
  double sentence(
    List<String> parts,
    TextStyle style,
    double maxWidth,
    Size blank,
  ) {
    final spans = <InlineSpan>[
      for (var i = 0; i < parts.length; i++) ...[
        TextSpan(text: parts[i]),
        if (i < parts.length - 1)
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox.shrink(),
          ),
      ],
    ];
    final tp = TextPainter(
      text: TextSpan(style: base.merge(style), children: spans),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textScaler: scaler,
    );
    tp.setPlaceholderDimensions([
      for (var i = 0; i < parts.length - 1; i++)
        PlaceholderDimensions(
          size: blank,
          alignment: PlaceholderAlignment.middle,
        ),
    ]);
    tp.layout(maxWidth: maxWidth);
    final height = tp.height;
    tp.dispose();
    return height;
  }
}

/// What every board is built with: UI scale, phone layout, theme and text
/// measuring.
class _Ui {
  _Ui({
    required this.s,
    required this.compact,
    required this.dark,
    required this.type,
  });

  final double s;
  final bool compact;
  final bool dark;
  final _Type type;

  /// Card and sentence text: bold, `text-slate-800 dark:text-white`.
  TextStyle text(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.25,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color ?? (dark ? _Colors.white : _Colors.slate800),
  );

  /// Board titles: `font-black text-slate-800 dark:text-white`.
  TextStyle title(double size) => text(size, weight: FontWeight.w900);

  /// Text never shrinks below 10 px on phones.
  double font(double size) => math.max(size * s, 10);
}

/// How a card face is laid out at its size.
@immutable
class _FaceSpec {
  const _FaceSpec({
    required this.size,
    required this.text,
    this.icon = 0,
    this.padding = EdgeInsets.zero,
    this.horizontal = false,
    this.maxLines = 3,
  });

  final Size size;
  final TextStyle text;

  /// Icon size (0: no icon).
  final double icon;
  final EdgeInsets padding;

  /// Icon beside the text (phones) instead of above it.
  final bool horizontal;
  final int maxLines;
}

/// Largest scale (at most [max]) at which [size] fits in [r].
double _fitScale(Size size, Rect r, [double max = 1]) {
  if (r.width <= 0 || r.height <= 0) return 0;
  return math.min(max, math.min(r.width / size.width, r.height / size.height));
}

/// [size] fitted into [r] (enlarged up to [max]), placed by [alignment].
Rect _fitRect(Size size, Rect r, Alignment alignment, [double max = 1]) {
  final k = math.max(0.05, _fitScale(size, r, max));
  final w = size.width * k;
  final h = size.height * k;
  return Rect.fromLTWH(
    r.left + (r.width - w) * (alignment.x + 1) / 2,
    r.top + (r.height - h) * (alignment.y + 1) / 2,
    w,
    h,
  );
}

/// [padding] less a [border] drawn inside the same box, so the content
/// keeps the room it was measured for.
EdgeInsets _inside(EdgeInsets padding, double border) => EdgeInsets.fromLTRB(
  math.max(0, padding.left - border),
  math.max(0, padding.top - border),
  math.max(0, padding.right - border),
  math.max(0, padding.bottom - border),
);

class _EverydayScientistLabState
    extends State<Ch1A2BecomingAnEverydayScientistPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final math.Random _random = math.Random();
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// pictures above the board and to find the floating mission card.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch1-a2-canvas');

  /// 1-based current step, derived from the placements ([_deriveStep]);
  /// steps.length + 1 once VERIFY found them right.
  int _step = 1;

  /// Label size in design px and a screen pixel in design px for the
  /// current stage scale.
  double _labelSize = _labelPx;
  double _pixel = 1;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// How much the board is scaled to fit its room (the lifted cards follow
  /// it); in Scenario 1 the pictures are fitted into [_pictureArea] above
  /// the board (canvas px).
  double _boardScale = 1;
  Rect? _pictureArea;

  /// The fixed menu button and the floating mission card (sidebar
  /// collapsed), in canvas px: the boards and pictures keep clear of it.
  Rect? _missionRect;
  Rect? _obstacle;
  double _missionCheckAt = 0;

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
    _scene.load(0, _random);
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

  /// HTML `animate()` + the GSAP ticker; then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt, labels: _lab.showLabels);
    if (now >= _missionCheckAt) {
      _missionCheckAt = now + 0.25;
      _measureMissionCard();
    }
    _frame.value = now;
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the pictures after this frame (the board and canvas are laid
  /// out by then). [snap] jumps there instead of sliding.
  void _scheduleFraming({bool snap = false}) {
    if (snap) _snapFraming = true;
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the three pictures and their labels into the canvas above the
  /// Scenario 1 board, clear of the tool column and the floating mission
  /// card. The other scenarios use the HTML camera as it is.
  void _updateFraming() {
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
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
    var target = _Framing.base;
    final area = _pictureArea;
    if (_scene.scenario == 0 && area != null) {
      final obstacle = _obstacle;
      target = _fitFraming(_focusItems(), toDesign(area), [
        if (obstacle != null) toDesign(obstacle),
      ], _maxZoom);
    }
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
  }

  /// What the learner must see: the three pictures (HTML camera, zoom 1)
  /// with their rings, and their label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_poseS1, _Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    for (var i = 0; i < _markerPos.length; i++) {
      final pos = _markerPos[i];
      final c = cam.p(pos);
      final k = cam.markerScale(pos);
      final w = _markerCard.width * k / 2 + _markerMargin;
      final h = _markerCard.height * k;
      final gap = _markerGap * k;
      final chip = _cache.chipSize(_t(_markerKeys[i]));
      // The card is centred with its label: it sits half a label higher.
      final up = Rect.fromLTWH(0, -chip.height / 2, 0, 0);
      final top = -(h + gap) / 2 - _markerMargin;
      final bottom = (h - gap) / 2 + _markerMargin;
      items
        ..add((c + Offset(-w, top), up))
        ..add((c + Offset(w, top), up))
        ..add((c + Offset(-w, bottom), up))
        ..add((c + Offset(w, bottom), up))
        ..add((
          c + Offset(0, (h + gap) / 2),
          Rect.fromLTWH(
            -chip.width / 2,
            -chip.height / 2,
            chip.width,
            chip.height,
          ),
        ));
    }
    return items;
  }

  /// Measures the shell's floating mission card (sidebar collapsed) in
  /// canvas px; the board and pictures move when it moves or changes size.
  void _measureMissionCard() {
    Rect? rect;
    if (!_lab.isSidebarOpen && _lab.isLabActive) {
      final canvas = _canvasKey.currentContext?.findRenderObject();
      final card = _missionCardBox();
      if (canvas is RenderBox && canvas.hasSize && card != null) {
        final origin = canvas.localToGlobal(Offset.zero);
        rect = (card.localToGlobal(Offset.zero) - origin) & card.size;
      }
    }
    final old = _missionRect;
    final same = rect == null || old == null
        ? rect == old
        : (rect.topLeft - old.topLeft).distance < 0.5 &&
              (rect.bottomRight - old.bottomRight).distance < 0.5;
    if (same) return;
    setState(() => _missionRect = rect);
    _scheduleFraming();
  }

  /// The shell's floating mission card, found in the lab's element tree.
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

  // ----------------------------------------------------------- scenarios

  /// HTML `loadScenario(step)`: clears the placements, re-deals the cards
  /// and moves the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index, _random);
      _step = _deriveStep();
    });
    _lab.resetView(sound: false);
    _scheduleFraming();
  }

  /// The step ladder: in Scenarios 1 and 3 the first empty circle / blank,
  /// in Scenario 2 the first group of habit cards not yet in a bucket;
  /// then VERIFY, and past it once VERIFY found everything right.
  int _deriveStep() {
    final s = _scene;
    final n = s.scenario;
    final count = _stepCounts[n];
    if (s.solved) return count + 1;
    if (n == 1) {
      for (var i = 0; i < _habitSteps.length; i++) {
        if (_habitSteps[i].any((t) => !s.placed.containsKey(t))) return i + 1;
      }
      return count;
    }
    final zones = _Zone.of(n);
    for (var i = 0; i < zones.length; i++) {
      if (s.occupant(zones[i]) == null) return i + 1;
    }
    return count;
  }

  /// Cards can be moved once the lab is open, except while 'CORRECT!'
  /// shows.
  bool get _canDrag => _lab.isLabActive && !_scene.celebrating;

  /// A drop zone lights up under a card of its scenario (HTML
  /// `.dropzone.highlight`).
  bool _accepts(_Token token, _Zone zone) =>
      _canDrag &&
      token.scenario == _scene.scenario &&
      zone.scenario == _scene.scenario;

  /// HTML `pointerup` over a drop zone: the 'drop' tone, then the card is
  /// placed (`placeToken`), unless a circle or blank already holds another
  /// card: then it goes back to the tray with "Already placed here!".
  void _drop(_Token token, _Zone zone) {
    if (!_accepts(token, zone)) return;
    final s = _scene;
    _Sound.drop.play();
    final other = s.occupant(zone);
    final blocked = zone.single && other != null && other != token;
    setState(() {
      if (blocked) {
        s.unplace(token);
      } else {
        s.place(token, zone, _random);
      }
      _step = _deriveStep();
    });
    if (blocked) _lab.showToast(_t('toast_already'), sound: false);
  }

  /// HTML `pointerup` away from every drop zone: the card is back in the
  /// tray (a placed card picked up and let go is taken off its zone).
  void _returnToTray(_Token token) {
    if (!_scene.placed.containsKey(token)) return;
    setState(() {
      _scene.unplace(token);
      _step = _deriveStep();
    });
  }

  /// HTML `#btn-verify` click: 'Place all items first!' while cards are
  /// missing, 'Not quite right…' when one is misplaced; otherwise
  /// 'CORRECT!' and, 1.5 s later, the next scenario or the Lab Conclusion.
  void _verify() {
    final s = _scene;
    if (!_lab.isLabActive || s.celebrating) return;
    _Sound.click.play();
    if (!s.allPlaced) {
      _lab.showToast(_t('toast_place_all'), isError: true);
      return;
    }
    if (!s.allCorrect) {
      _lab.showToast(_t('toast_not_quite'), isError: true);
      return;
    }
    _Sound.success.play();
    setState(() {
      s
        ..solved = true
        ..celebrating = true;
      _step = _deriveStep();
    });
    final sc = s.scenario;
    _lab.after(const Duration(milliseconds: _correctMs), () {
      if (!mounted || _scene.scenario != sc) return;
      if (sc < _stepCounts.length - 1) {
        _lab.completedScenarios.add(sc);
        _loadScenario(sc + 1);
      } else {
        _showFinal();
      }
    });
  }

  /// HTML `showFinal()`: 'success' and the Lab Conclusion (the shell adds
  /// 'Restart Lab').
  void _showFinal() {
    setState(() => _scene.celebrating = false);
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _t('conclusion_title'),
      heading: () => _lab.t('sci_conclusion'),
      body: () => _t('conclusion_text'),
      extra: () => const _Stars(),
    );
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
        final n = _scene.scenario;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title'), _t('sc3_title')],
          scenarioIndex: n,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${n + 1}_hud_${_step.clamp(1, _stepCounts[n])}'),
          // HTML `enterLab()` opens Scenario 1; 'Restart Lab' and the
          // header reset reload the page.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('taskInstr'),
          sidebarExtra: _StepsCard(
            lines: _desc(_lab.lang, n),
            palette: p,
            scale: s,
            fontScale: f,
          ),
          overlays: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, box) => _boardLayer(context, box.biggest),
              ),
            ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  /// The scenario's board (HTML `#sN-ui-layer` and `#verify-container`),
  /// fitted into the part of the canvas no shell card covers: clear of the
  /// tool column, the HUD (sidebar open) and the menu button and floating
  /// mission card (sidebar collapsed).
  Widget _boardLayer(BuildContext context, Size canvas) {
    final s = context.labScale;
    final pad = MediaQuery.paddingOf(context);
    final open = _lab.isSidebarOpen;
    final insets = labOverlayInsets(context, _lab);
    final free = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _cardGap + pad.top,
      canvas.width - insets.right,
      canvas.height -
          _cardGap -
          pad.bottom -
          (open ? _hudBand * s + _cardGap : 0),
    );
    final ui = _Ui(
      s: math.min(s, _boardMaxUi),
      compact: MediaQuery.sizeOf(context).height < _compactBelow,
      dark: _lab.isDark,
      type: _Type(
        DefaultTextStyle.of(context).style,
        MediaQuery.textScalerOf(context),
      ),
    );
    final n = _scene.scenario;
    final board = switch (n) {
      0 => _boardS1(ui),
      1 => _boardS2(ui, free),
      _ => _boardS3(ui),
    };

    // The menu button and the mission card, while the sidebar is collapsed.
    Rect? obstacle;
    final mission = _missionRect;
    if (!open && _lab.isLabActive) {
      obstacle = Rect.fromLTWH(
        _menuInset + pad.left,
        _menuInset + pad.top,
        _menuSize,
        _menuSize,
      );
      if (mission != null) obstacle = obstacle.expandToInclude(mission);
      obstacle = obstacle.inflate(_cardGap);
    }
    _obstacle = obstacle;

    var area = free;
    final grow = board.maxScale;
    if (obstacle != null &&
        _fitRect(board.size, free, board.alignment, grow).overlaps(obstacle)) {
      final below = Rect.fromLTRB(
        free.left,
        math.max(free.top, obstacle.bottom),
        free.right,
        free.bottom,
      );
      final right = Rect.fromLTRB(
        math.max(free.left, obstacle.right),
        free.top,
        free.right,
        free.bottom,
      );
      area =
          n != 0 &&
              _fitScale(board.size, below, grow) >=
                  _fitScale(board.size, right, grow)
          ? below
          : right;
    }
    final rect = _fitRect(board.size, area, board.alignment, grow);
    _boardScale = rect.width / board.size.width;
    _pictureArea = n == 0
        ? Rect.fromLTRB(free.left, free.top, free.right, rect.top - _cardGap)
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
        Positioned.fromRect(
          rect: rect,
          child: FittedBox(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(size: board.size, child: board.child),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------- scenario 1 board

  /// HTML `#s1-ui-layer`: the three numbered circles with their hints (the
  /// placed question hangs under its circle), the tray of question cards
  /// and VERIFY (beside the tray on phones).
  _Board _boardS1(_Ui ui) {
    final s = ui.s;
    final c = ui.compact;
    final textStyle = ui.text(ui.font(c ? 10.5 : 11.5), height: 1.2);
    final icon = (c ? 20 : 26) * s;
    final padding = EdgeInsets.symmetric(
      horizontal: (c ? 8 : 10) * s,
      vertical: (c ? 6 : 8) * s,
    );
    final cardW = (c ? 130 : 160) * s;
    final textW = c
        ? cardW - padding.horizontal - icon - 6 * s
        : cardW - padding.horizontal;
    var textH = 0.0;
    for (final t in _Token.of(0)) {
      textH = math.max(
        textH,
        ui.type
            .measure(_t(t.textKey), textStyle, maxWidth: textW, maxLines: 4)
            .height,
      );
    }
    final cardH = c
        ? padding.vertical + math.max(icon, textH)
        : padding.vertical + icon + 3 * s + textH;
    final face = _FaceSpec(
      size: Size(cardW, cardH),
      text: textStyle,
      icon: icon,
      padding: padding,
      horizontal: c,
      maxLines: 4,
    );

    final circle = (c ? 38 : 56) * s;
    final hintH = c ? 0.0 : 24 * s;
    final hintSide = 28 * s;
    final colGap = (c ? 10 : 24) * s;
    final slotGap = (c ? 4 : 8) * s;
    final colW = math.max(cardW, circle + 2 * hintSide);
    final colH = (c ? 0 : hintH + 6 * s) + circle + slotGap + cardH;
    final trayPad = (c ? 6 : 12) * s;
    final trayGap = (c ? 6 : 12) * s;
    final trayW = 3 * cardW + 2 * trayGap + 2 * trayPad;
    final trayH = cardH + 2 * trayPad;
    final verify = Size((c ? 104 : 150) * s, math.max((c ? 40 : 48) * s, 48));
    final gap = (c ? 8 : 12) * s;
    final rowW = 3 * colW + 2 * colGap;
    final width = c
        ? math.max(rowW, trayW + gap + verify.width)
        : math.max(rowW, math.max(trayW, verify.width));
    final height =
        colH +
        gap +
        (c ? math.max(trayH, verify.height) : trayH + gap + verify.height);

    final zones = _Zone.of(0);
    Widget column(_Zone zone) {
      final hint = _HintButton(
        label: c ? null : _t('hint'),
        message: _t(zone.hintKey),
        semantics: labFormat(_t('sem_hint'), {'text': _t(zone.hintKey)}),
        scale: s,
        dark: ui.dark,
      );
      final occupant = _scene.occupant(zone);
      return SizedBox(
        width: colW,
        height: colH,
        child: Column(
          children: [
            if (!c) ...[
              SizedBox(height: hintH, child: hint),
              SizedBox(height: 6 * s),
            ],
            DragTarget<_Token>(
              onWillAcceptWithDetails: (d) => _accepts(d.data, zone),
              onAcceptWithDetails: (d) => _drop(d.data, zone),
              builder: (context, candidates, _) => Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (c) SizedBox(width: hintSide, child: hint),
                      _TargetCircle(
                        number: zone.number,
                        diameter: circle,
                        hot: candidates.isNotEmpty,
                        dark: ui.dark,
                        semantics: labFormat(_t('sem_circle'), {
                          'n': zone.number,
                          'name': _t(zone.nameKey),
                        }),
                      ),
                      if (c) SizedBox(width: hintSide),
                    ],
                  ),
                  SizedBox(height: slotGap),
                  SizedBox(
                    width: cardW,
                    height: cardH,
                    child: occupant == null
                        ? null
                        : _draggable(occupant, face, ui, placed: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final tray = _Tray(
      width: trayW,
      height: trayH,
      padding: trayPad,
      dark: ui.dark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _scene.tray.length; i++) ...[
            if (i > 0) SizedBox(width: trayGap),
            _traySlot(_scene.tray[i], face, ui),
          ],
        ],
      ),
    );
    final button = _verifyButton(ui, verify);

    return _Board(
      Size(width, height),
      Column(
        children: [
          SizedBox(
            height: colH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < zones.length; i++) ...[
                  if (i > 0) SizedBox(width: colGap),
                  column(zones[i]),
                ],
              ],
            ),
          ),
          SizedBox(height: gap),
          if (c)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tray,
                SizedBox(width: gap),
                button,
              ],
            )
          else ...[
            tray,
            SizedBox(height: gap),
            button,
          ],
        ],
      ),
      Alignment.bottomCenter,
    );
  }

  // ------------------------------------------------------- scenario 2 board

  /// HTML `#s2-ui-layer`: 'Scientist Habits' (the grid of habit cards) and
  /// 'Are You a Scientist?' (the two buckets), VERIFY below them (under
  /// the buckets on phones). The grid has 2 columns as in the HTML, or 3
  /// when that fits the canvas better.
  _Board _boardS2(_Ui ui, Rect area) {
    final s = ui.s;
    final c = ui.compact;
    final textStyle = ui.text(ui.font(c ? 10 : 11.5), height: 1.15);
    final icon = (c ? 20 : 30) * s;
    final pad = (c ? 5 : 8) * s;
    var cell = (c ? 74 : 104) * s;
    var textH = 0.0;
    for (final t in _Token.of(1)) {
      textH = math.max(
        textH,
        ui.type
            .measure(
              _t(t.textKey),
              textStyle,
              maxWidth: cell - 2 * pad,
              maxLines: 3,
            )
            .height,
      );
    }
    cell = math.max(cell, 2 * pad + icon + 4 * s + textH);
    final face = _FaceSpec(
      size: Size.square(cell),
      text: textStyle,
      icon: icon,
      padding: EdgeInsets.all(pad),
    );

    final gridGap = (c ? 6 : 12) * s;
    final panelPad = (c ? 8 : 16) * s;
    final titleStyle = ui.title(c ? 13 * s : 20 * s);
    final habits = _t('s2_habits_title');
    final buckets = _t('s2_buckets_title');
    final habitsSize = ui.type.measure(habits, titleStyle);
    final bucketsSize = ui.type.measure(buckets, titleStyle);
    final titleGap = (c ? 6 : 12) * s;

    // Buckets: `.bucket-shape` 160 x 180 with its rim 10 px wider on each
    // side and 40 px tall, centred on the top edge.
    final bucketW = (c ? 80 : 128) * s;
    final rimOut = bucketW * 10 / 160;
    final rimH = bucketW * 40 / 160;
    final bucketH = bucketW * 180 / 160;
    final hintH = (c ? 24 : 32) * s;
    final hintGap = (c ? 4 : 8) * s;
    final bucketColW = bucketW + 2 * rimOut;
    final bucketColH = hintH + hintGap + rimH / 2 + bucketH;
    final bucketGap = (c ? 18 : 40) * s;
    final verify = Size((c ? 104 : 150) * s, math.max((c ? 40 : 48) * s, 48));
    final rightGap = (c ? 8 : 20) * s;
    final rightW = math.max(
      2 * bucketColW + bucketGap,
      math.max(bucketsSize.width, c ? verify.width : 0),
    );
    final rightH =
        bucketsSize.height +
        rightGap +
        bucketColH +
        (c ? (8 * s + verify.height) : 0);
    final columnGap = (c ? 16 : 32) * s;
    final bottomGap = 14 * s;

    Size sizeFor(int cols) {
      final rows = (6 / cols).ceil();
      final gridW = cols * cell + (cols - 1) * gridGap + 2 * panelPad;
      final leftW = math.max(gridW, habitsSize.width);
      final leftH =
          habitsSize.height +
          titleGap +
          rows * cell +
          (rows - 1) * gridGap +
          2 * panelPad;
      final w = leftW + columnGap + rightW;
      final h = math.max(leftH, rightH);
      return c
          ? Size(w, h)
          : Size(math.max(w, verify.width), h + bottomGap + verify.height);
    }

    final two = sizeFor(2);
    final three = sizeFor(3);
    final cols =
        _fitScale(three, area, _boardGrow) >
            _fitScale(two, area, _boardGrow) + 0.02
        ? 3
        : 2;
    final size = cols == 3 ? three : two;
    final rows = (6 / cols).ceil();

    final grid = Container(
      padding: EdgeInsets.all(panelPad - 1),
      decoration: BoxDecoration(
        color: ui.dark ? const Color(0x801E293B) : const Color(0x80FFFFFF),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(
          color: ui.dark ? _Colors.slate700 : _Colors.slate300,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows; r++) ...[
            if (r > 0) SizedBox(height: gridGap),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (
                  var i = r * cols;
                  i < math.min(6, (r + 1) * cols);
                  i++
                ) ...[
                  if (i > r * cols) SizedBox(width: gridGap),
                  _traySlot(_scene.tray[i], face, ui),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    Widget bucket(_Zone zone) => DragTarget<_Token>(
      onWillAcceptWithDetails: (d) => _accepts(d.data, zone),
      onAcceptWithDetails: (d) => _drop(d.data, zone),
      builder: (context, candidates, _) => _BucketColumn(
        width: bucketColW,
        height: bucketColH,
        bucketWidth: bucketW,
        hintHeight: hintH,
        hintGap: hintGap,
        hot: candidates.isNotEmpty,
        dark: ui.dark,
        hint: _HintButton(
          message: _t(zone.hintKey),
          semantics: labFormat(_t('sem_hint'), {'text': _t(zone.hintKey)}),
          scale: s,
          dark: ui.dark,
          round: true,
        ),
        semantics: labFormat(_t('sem_bucket'), {'n': zone.number}),
        cards: [
          for (final t in _scene.inZone(zone))
            (
              t,
              _scene.tilt[t] ?? 0,
              (double side) =>
                  _draggable(t, _miniSpec(face, side, ui), ui, liftedAs: face),
            ),
        ],
      ),
    );

    final left = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(habits, style: titleStyle, maxLines: 1),
        SizedBox(height: titleGap),
        grid,
      ],
    );
    final button = _verifyButton(ui, verify);
    final right = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(buckets, style: titleStyle, maxLines: 1),
        SizedBox(height: rightGap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            bucket(_Zone.scientist),
            SizedBox(width: bucketGap),
            bucket(_Zone.notEnough),
          ],
        ),
        if (c) ...[SizedBox(height: 8 * s), button],
      ],
    );
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        left,
        SizedBox(width: columnGap),
        right,
      ],
    );
    return _Board(
      size,
      c
          ? row
          : Column(
              children: [
                Expanded(child: row),
                SizedBox(height: bottomGap),
                button,
              ],
            ),
      Alignment.center,
      maxScale: _boardGrow,
    );
  }

  /// A habit card in a bucket (HTML: 60 x 60, `text-[8px]`, `p-1`): the
  /// square face at [side], its text left out when too small to read (the
  /// card is then announced by its text).
  _FaceSpec _miniSpec(_FaceSpec face, double side, _Ui ui) {
    final text = side * 8 / 60;
    final showText = text >= _miniTextMin;
    return _FaceSpec(
      size: Size.square(side),
      text: face.text.copyWith(fontSize: text, height: 1.1),
      icon: side * (showText ? 0.4 : 0.55),
      padding: EdgeInsets.all(side * 4 / 60),
      maxLines: showText ? 2 : 0,
    );
  }

  // ------------------------------------------------------- scenario 3 board

  /// HTML `#s3-ui-layer`: a card with the people-talking picture over the
  /// message and its four blanks (beside it on phones), the tray of words
  /// and VERIFY (beside the tray on phones).
  _Board _boardS3(_Ui ui) {
    final s = ui.s;
    final c = ui.compact;
    final cardPad = (c ? 10 : 20) * s;
    final imageSize = c ? Size(118 * s, 84 * s) : Size(240 * s, 112 * s);
    final imageGap = (c ? 10 : 14) * s;
    final textW = (c ? 320 : 500) * s;
    final sentenceStyle = ui.text(
      ui.font(c ? 12 : 16),
      color: ui.dark ? _Colors.slate200 : _Colors.slate800,
      height: c ? 1.9 : 2,
    );
    final wordStyle = ui.text(ui.font(c ? 11 : 13));
    final wordPadH = (c ? 10 : 16) * s;
    final wordPadV = (c ? 5 : 7) * s;
    final words = _Token.of(2);
    final wordSizes = {
      for (final t in words) t: ui.type.measure(_t(t.textKey), wordStyle),
    };
    final wordH =
        wordSizes.values.map((v) => v.height).reduce(math.max) + 2 * wordPadV;
    final widest = wordSizes.values.map((v) => v.width).reduce(math.max);
    final blankMargin = (c ? 4 : 6) * s;
    final blank = Size(
      math.max((c ? 70 : 104) * s, widest + 2 * wordPadH),
      math.max((c ? 26 : 34) * s, wordH),
    );
    final parts = [for (var i = 1; i <= 5; i++) _t('s3_t$i')];
    final textH = ui.type.sentence(
      parts,
      sentenceStyle,
      textW,
      Size(blank.width + 2 * blankMargin, blank.height),
    );
    final cardW = c
        ? imageSize.width + imageGap + textW + 2 * cardPad
        : math.max(textW, imageSize.width) + 2 * cardPad;
    final cardH = c
        ? math.max(imageSize.height, textH) + 2 * cardPad
        : imageSize.height + imageGap + textH + 2 * cardPad;

    final trayPad = (c ? 6 : 12) * s;
    final trayGap = (c ? 6 : 12) * s;
    final chip = {
      for (final t in words)
        t: Size(wordSizes[t]!.width + 2 * wordPadH + 4, wordH),
    };
    final trayW =
        chip.values.fold(0.0, (a, b) => a + b.width) +
        (words.length - 1) * trayGap +
        2 * trayPad;
    final trayH = wordH + 2 * trayPad;
    final verify = Size((c ? 104 : 150) * s, math.max((c ? 40 : 48) * s, 48));
    final gap = (c ? 8 : 12) * s;
    final width = c
        ? math.max(cardW, trayW + gap + verify.width)
        : math.max(cardW, math.max(trayW, verify.width));
    final height =
        cardH +
        gap +
        (c ? math.max(trayH, verify.height) : trayH + gap + verify.height);

    _FaceSpec face(_Token t) => _FaceSpec(
      size: chip[t]!,
      text: wordStyle,
      padding: EdgeInsets.symmetric(horizontal: wordPadH),
      maxLines: 1,
    );

    Widget blankAt(_Zone zone) {
      final occupant = _scene.occupant(zone);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: blankMargin),
        child: DragTarget<_Token>(
          onWillAcceptWithDetails: (d) => _accepts(d.data, zone),
          onAcceptWithDetails: (d) => _drop(d.data, zone),
          builder: (context, candidates, _) => _Blank(
            size: blank,
            hot: candidates.isNotEmpty,
            dark: ui.dark,
            semantics: labFormat(_t('sem_blank'), {'n': zone.number}),
            hint: _HintButton(
              message: _t(zone.hintKey),
              semantics: labFormat(_t('sem_hint'), {'text': _t(zone.hintKey)}),
              scale: s,
              dark: ui.dark,
              muted: true,
            ),
            card: occupant == null
                ? null
                : _draggable(occupant, face(occupant), ui, inBlank: blank),
          ),
        ),
      );
    }

    final zones = _Zone.of(2);
    final sentence = SizedBox(
      width: textW,
      child: Text.rich(
        TextSpan(
          style: sentenceStyle,
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              TextSpan(text: parts[i]),
              if (i < zones.length)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: blankAt(zones[i]),
                ),
            ],
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
    final picture = _PeoplePicture(
      size: imageSize,
      dark: ui.dark,
      semantics: _t('alt_people'),
    );
    final card = Container(
      width: cardW,
      height: cardH,
      padding: EdgeInsets.all(cardPad - 1),
      decoration: BoxDecoration(
        color: ui.dark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular((c ? 16 : 24) * s),
        border: Border.all(
          color: ui.dark ? _Colors.slate600 : _Colors.slate300,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            spreadRadius: -12,
            offset: Offset(0, 25),
          ),
        ],
      ),
      child: c
          ? Row(
              children: [
                picture,
                SizedBox(width: imageGap),
                sentence,
              ],
            )
          : Column(
              children: [
                picture,
                SizedBox(height: imageGap),
                sentence,
              ],
            ),
    );
    final tray = _Tray(
      width: trayW,
      height: trayH,
      padding: trayPad,
      dark: ui.dark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _scene.tray.length; i++) ...[
            if (i > 0) SizedBox(width: trayGap),
            _traySlot(_scene.tray[i], face(_scene.tray[i]), ui),
          ],
        ],
      ),
    );
    final button = _verifyButton(ui, verify);
    return _Board(
      Size(width, height),
      Column(
        children: [
          card,
          SizedBox(height: gap),
          if (c)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tray,
                SizedBox(width: gap),
                button,
              ],
            )
          else ...[
            tray,
            SizedBox(height: gap),
            button,
          ],
        ],
      ),
      Alignment.center,
      maxScale: _boardGrow,
    );
  }

  // ------------------------------------------------------------ shared UI

  /// A card's place in the tray (or grid): the card, or a faint outline
  /// once it is placed.
  Widget _traySlot(_Token token, _FaceSpec face, _Ui ui) {
    final placed = _scene.placed.containsKey(token);
    return SizedBox.fromSize(
      size: face.size,
      child: placed
          ? _EmptySlot(dark: ui.dark, radius: 12 * ui.s)
          : _draggable(token, face, ui),
    );
  }

  /// HTML `.draggable-card` and its `pointerdown` / `pointermove`
  /// handlers: the card lifts (a slightly larger, see-through copy follows
  /// the finger, keeping where it was grabbed) and leaves a faded card
  /// behind. A placed card can be picked up again in the same way.
  /// [placed] cards hang under a circle (`shadow-xl`); [inBlank] cards
  /// fill a blank of that size; a card in a bucket lifts at its full size
  /// ([liftedAs]), as the HTML lifted the grid's card.
  Widget _draggable(
    _Token token,
    _FaceSpec face,
    _Ui ui, {
    bool placed = false,
    Size? inBlank,
    _FaceSpec? liftedAs,
  }) {
    final text = _t(token.textKey);
    final lift = liftedAs ?? face;
    Widget faceOf({bool lifted = false, bool blank = false}) => _CardFace(
      text: text,
      icon: token.icon,
      spec: lifted
          ? lift
          : blank && inBlank != null
          ? _FaceSpec(
              size: inBlank,
              text: face.text,
              padding: face.padding,
              maxLines: 1,
            )
          : face,
      dark: ui.dark,
      lifted: lifted,
      placed: placed,
      inBlank: blank,
    );
    final k = _boardScale;
    final child = faceOf(blank: inBlank != null);
    return Draggable<_Token>(
      data: token,
      maxSimultaneousDrags: _canDrag ? 1 : 0,
      // The copy keeps the point the finger grabbed (HTML `startOffset`),
      // at the board's scale.
      dragAnchorStrategy: (draggable, context, position) {
        final box = context.findRenderObject()! as RenderBox;
        return box.globalToLocal(position) * k;
      },
      // HTML `pointerdown`: the 'drag' tone.
      onDragStarted: _Sound.pickup.play,
      onDraggableCanceled: (_, _) => _returnToTray(token),
      feedback: _LiftedCard(
        scale: k,
        size: lift.size,
        child: faceOf(lifted: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }

  /// HTML `#btn-verify`.
  Widget _verifyButton(_Ui ui, Size size) => _VerifyButton(
    size: size,
    scale: ui.s,
    label: _t('btn_verify'),
    correctLabel: _t('btn_correct'),
    ready: _scene.allPlaced,
    correct: _scene.celebrating,
    onTap: _verify,
  );

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _pixel = 1 / fit;
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        final pictures = _scene.markersShown;
        return LabStage(
          designSize: _design,
          child: Semantics(
            image: true,
            label: _t(pictures ? 'scene_s1' : 'scene_grid'),
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  cache: _cache,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  lang: _lab.lang,
                  labelSize: _labelSize,
                  pixel: _pixel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================================================================== WIDGETS

/// HTML teacher-board "Steps" (`#sb-instructions`): the scenario's
/// `sN_desc` lines, at the sidebar text size.
class _StepsCard extends StatelessWidget {
  const _StepsCard({
    required this.lines,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final List<String> lines;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in lines)
            if (line.isEmpty)
              SizedBox(height: 8 * s)
            else
              Padding(
                padding: EdgeInsets.only(bottom: 4 * s),
                child: Text(
                  line,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12.5 * fontScale,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// HTML success modal: three `ph-fill ph-star` in yellow-400, the middle
/// one larger and raised.
class _Stars extends StatelessWidget {
  const _Stars();

  @override
  Widget build(BuildContext context) {
    final s = context.labScale;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.star_rounded, size: 44 * s, color: _Colors.yellow400),
          SizedBox(width: 6 * s),
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: Icon(
              Icons.star_rounded,
              size: 56 * s,
              color: _Colors.yellow400,
            ),
          ),
          SizedBox(width: 6 * s),
          Icon(Icons.star_rounded, size: 44 * s, color: _Colors.yellow400),
        ],
      ),
    );
  }
}

/// HTML `.draggable-card`: a white (dark: slate-700) rounded card with a
/// 2 px indigo-200 (dark: indigo-900) border and `shadow-md`, the Phosphor
/// icon in indigo-500 and the bold text. Lifted (being dragged): an
/// indigo-500 border and `shadow-2xl`; hanging under a circle:
/// `shadow-xl`; in a blank: no border, `shadow-inner`.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.text,
    required this.icon,
    required this.spec,
    required this.dark,
    this.lifted = false,
    this.placed = false,
    this.inBlank = false,
  });

  final String text;
  final IconData? icon;
  final _FaceSpec spec;
  final bool dark;
  final bool lifted;
  final bool placed;
  final bool inBlank;

  @override
  Widget build(BuildContext context) {
    final sp = spec;
    final glyph = icon == null || sp.icon <= 0
        ? null
        : Icon(icon, size: sp.icon, color: _Colors.indigo500);
    final label = sp.maxLines <= 0
        ? null
        : Text(
            text,
            textAlign: TextAlign.center,
            maxLines: sp.maxLines,
            overflow: TextOverflow.ellipsis,
            style: sp.text,
          );
    final Widget content;
    if (sp.horizontal && glyph != null && label != null) {
      content = Row(
        children: [
          glyph,
          SizedBox(width: sp.icon * 0.3),
          Expanded(child: label),
        ],
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ?glyph,
          if (glyph != null && label != null) SizedBox(height: sp.icon * 0.12),
          if (label != null) Flexible(child: label),
        ],
      );
    }
    final shadow = lifted
        ? const BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            spreadRadius: -12,
            offset: Offset(0, 25),
          )
        : placed
        ? const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          )
        : const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          );
    return Container(
      width: sp.size.width,
      height: sp.size.height,
      padding: inBlank ? sp.padding : _inside(sp.padding, 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: inBlank
            ? (dark ? _Colors.slate600 : _Colors.slate100)
            : (dark ? _Colors.slate700 : _Colors.white),
        borderRadius: BorderRadius.circular(
          math.min(12, sp.size.shortestSide * 0.22),
        ),
        border: inBlank
            ? null
            : Border.all(
                color: lifted
                    ? _Colors.indigo500
                    : (dark ? _Colors.indigo900 : _Colors.indigo200),
                width: 2,
              ),
        boxShadow: inBlank ? null : [shadow],
      ),
      // A card too small for its text is still announced by it.
      child: label == null
          ? Semantics(
              label: text,
              child: ExcludeSemantics(child: content),
            )
          : content,
    );
  }
}

/// The see-through copy that follows the finger (HTML drag clone:
/// `scale-105 shadow-2xl opacity-90 border-indigo-500`), drawn at the
/// board's [scale].
class _LiftedCard extends StatelessWidget {
  const _LiftedCard({
    required this.scale,
    required this.size,
    required this.child,
  });

  final double scale;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.fromSize(
        size: size * scale,
        child: FittedBox(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: Transform.scale(
              scale: 1.05,
              child: Opacity(opacity: 0.9, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where a card was in the tray before it was placed: a faint dashed
/// outline (the HTML hid the card and let the others close up).
class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.dark, required this.radius});

  final bool dark;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: (dark ? _Colors.slate500 : _Colors.slate400).withValues(
          alpha: 0.45,
        ),
        radius: radius,
        width: 1.5,
      ),
    );
  }
}

/// HTML `#s1-tray` / `#s3-tray`: `bg-white/90 dark:bg-slate-800/90`,
/// `border-slate-300 dark:border-slate-700`, `rounded-xl`, `shadow-2xl`.
class _Tray extends StatelessWidget {
  const _Tray({
    required this.width,
    required this.height,
    required this.padding,
    required this.dark,
    required this.child,
  });

  final double width;
  final double height;
  final double padding;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(math.max(0, padding - 1)),
      decoration: BoxDecoration(
        color: dark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate300),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            spreadRadius: -12,
            offset: Offset(0, 25),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// HTML hint: a `ph-question` icon in indigo-500 (after the word "Hint" in
/// Scenario 1, on a round chip over the buckets, in slate-400 inside the
/// blanks) whose `.hint-tooltip` shows on hover; here a tap (or a long
/// press) shows it for 3 s.
class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.message,
    required this.semantics,
    required this.scale,
    required this.dark,
    this.label,
    this.round = false,
    this.muted = false,
  });

  final String message;
  final String semantics;
  final double scale;
  final bool dark;

  /// "Hint" before the icon (Scenario 1 on larger screens).
  final String? label;

  /// On a round chip (the buckets).
  final bool round;

  /// Slate instead of indigo (inside the blanks).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final iconSize = (round ? 24 : 18) * s;
    Widget glyph = Icon(
      Icons.help_outline,
      size: iconSize,
      color: muted ? _Colors.slate400 : _Colors.indigo500,
    );
    if (round) {
      glyph = DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? _Colors.slate800 : _Colors.slate100,
          shape: BoxShape.circle,
        ),
        child: glyph,
      );
    }
    final hint = label;
    final content = hint == null
        ? glyph
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hint,
                style: TextStyle(
                  color: dark ? _Colors.slate400 : _Colors.slate600,
                  fontSize: math.max(11 * s, 10),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 3 * s),
              glyph,
            ],
          );
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      preferBelow: false,
      excludeFromSemantics: true,
      constraints: BoxConstraints(minHeight: 24, maxWidth: 170 * s),
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: _Colors.tipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Colors.tipBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: _Colors.white,
        fontSize: math.max(11 * s, 10),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
      child: Semantics(
        button: true,
        label: semantics,
        child: ExcludeSemantics(
          child: ColoredBox(
            color: LabInk.clear,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

/// HTML `.s1-target-btn`: a numbered circle (`bg-white dark:bg-slate-800`,
/// 3 px border and number in slate-500, dark slate-300); its drop zone
/// grows 10% while a card is over it (`.dropzone.highlight`).
class _TargetCircle extends StatelessWidget {
  const _TargetCircle({
    required this.number,
    required this.diameter,
    required this.hot,
    required this.dark,
    required this.semantics,
  });

  final int number;
  final double diameter;
  final bool hot;
  final bool dark;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? _Colors.slate300 : _Colors.slate500;
    return AnimatedScale(
      scale: hot ? 1.1 : 1,
      duration: const Duration(milliseconds: 300),
      curve: const Cubic(0.4, 0, 0.2, 1),
      child: Semantics(
        container: true,
        label: semantics,
        child: ExcludeSemantics(
          child: Container(
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? _Colors.slate800 : _Colors.white,
              border: Border.all(color: ink, width: 3),
              boxShadow: [
                BoxShadow(
                  color: dark
                      ? const Color(0x66000000)
                      : const Color(0x26000000),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // The HTML's `font-weight: black` is not a CSS weight, so the
            // number is drawn at normal weight.
            child: Text(
              '$number',
              style: TextStyle(
                color: ink,
                fontSize: diameter * 0.35,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HTML bucket drop zone: the round "?" hint over a `.bucket-shape` with
/// its elliptical rim (`.bucket-top`, `.bucket-inner`). The zone grows 10%
/// and the rim's inside turns indigo while a card is over it; dropped
/// habit cards (HTML 60 x 60, tilted) pile up in it, smaller when many.
class _BucketColumn extends StatelessWidget {
  const _BucketColumn({
    required this.width,
    required this.height,
    required this.bucketWidth,
    required this.hintHeight,
    required this.hintGap,
    required this.hot,
    required this.dark,
    required this.hint,
    required this.semantics,
    required this.cards,
  });

  final double width;
  final double height;
  final double bucketWidth;
  final double hintHeight;
  final double hintGap;
  final bool hot;
  final bool dark;
  final Widget hint;
  final String semantics;

  /// The cards in the bucket: token, tilt (rad) and the card at a side.
  final List<(_Token, double, Widget Function(double side))> cards;

  @override
  Widget build(BuildContext context) {
    final bw = bucketWidth;
    final rimH = bw * 40 / 160;
    final bucketH = bw * 180 / 160;
    final rimOut = bw * 10 / 160;
    final top = hintHeight + hintGap;
    // HTML drop container: `top-16`, `p-2`, `gap-1`.
    final area = Rect.fromLTRB(
      rimOut + bw * 0.05,
      top + rimH * 0.85,
      rimOut + bw * 0.95,
      top + rimH / 2 + bucketH - bw * 0.06,
    );
    final pile = _pile(cards.length, area, bw * 60 / 160, bw * 4 / 160);
    return AnimatedScale(
      scale: hot ? 1.1 : 1,
      duration: const Duration(milliseconds: 300),
      curve: const Cubic(0.4, 0, 0.2, 1),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: hintHeight,
              child: hint,
            ),
            Positioned(
              left: 0,
              top: top,
              width: width,
              height: rimH / 2 + bucketH,
              child: Semantics(
                container: true,
                label: semantics,
                child: CustomPaint(
                  painter: _BucketPainter(
                    dark: dark,
                    hot: hot,
                    bucketWidth: bw,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < cards.length; i++)
              Positioned.fromRect(
                rect: pile[i],
                child: Transform.rotate(
                  angle: cards[i].$2,
                  child: cards[i].$3(pile[i].width),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// [n] squares of at most [maxSide], [gap] apart, in centred rows filling
  /// [area] as well as they can (HTML `flex-wrap justify-center
  /// items-center`).
  static List<Rect> _pile(int n, Rect area, double maxSide, double gap) {
    if (n == 0) return const [];
    var cols = 1;
    var side = 0.0;
    for (var c = 1; c <= n; c++) {
      final rows = (n / c).ceil();
      final fit = math.min(
        maxSide,
        math.min(
          (area.width - (c - 1) * gap) / c,
          (area.height - (rows - 1) * gap) / rows,
        ),
      );
      if (fit > side) {
        side = fit;
        cols = c;
      }
    }
    final rows = (n / cols).ceil();
    final blockH = rows * side + (rows - 1) * gap;
    final y0 = area.top + (area.height - blockH) / 2;
    return [
      for (var i = 0; i < n; i++)
        () {
          final row = i ~/ cols;
          final inRow = math.min(cols, n - row * cols);
          final rowW = inRow * side + (inRow - 1) * gap;
          final x0 = area.left + (area.width - rowW) / 2;
          return Rect.fromLTWH(
            x0 + (i % cols) * (side + gap),
            y0 + row * (side + gap),
            side,
            side,
          );
        }(),
    ];
  }
}

/// HTML `.bucket-shape`: a slate pail (light: slate-300 → slate-400, dark:
/// slate-600 → slate-700) with a 4 px border (slate-600 / slate-800) but
/// none on top, rounded 10 / 30 px, a drop shadow; `.bucket-top`, an
/// elliptical rim 10 px wider on each side, and `.bucket-inner` (slate-500
/// / slate-800, indigo while a card is over it). Sizes scale with the
/// bucket's width (160 px in the HTML).
class _BucketPainter extends CustomPainter {
  const _BucketPainter({
    required this.dark,
    required this.hot,
    required this.bucketWidth,
  });

  final bool dark;
  final bool hot;
  final double bucketWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final k = bucketWidth / 160;
    final rimOut = 10 * k;
    final rimH = 40 * k;
    final border = 4 * k;
    final body = Rect.fromLTWH(rimOut, rimH / 2, bucketWidth, 180 * k);
    final shape = RRect.fromRectAndCorners(
      body,
      topLeft: Radius.circular(10 * k),
      topRight: Radius.circular(10 * k),
      bottomLeft: Radius.circular(30 * k),
      bottomRight: Radius.circular(30 * k),
    );
    final edge = dark ? _Colors.slate800 : _Colors.slate600;
    // `box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3)`.
    canvas.drawRRect(
      shape.shift(Offset(0, 10 * k)),
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * k),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(
          body.topCenter,
          body.bottomCenter,
          dark
              ? const [_Colors.slate600, _Colors.slate700]
              : const [_Colors.slate300, _Colors.slate400],
        ),
    );
    // `inset 0 -20px 30px rgba(0, 0, 0, 0.1)`: darker towards the bottom.
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(
      Rect.fromLTRB(body.left, body.bottom - 40 * k, body.right, body.bottom),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, body.bottom - 40 * k),
          body.bottomLeft,
          const [Color(0x00000000), Color(0x26000000)],
        ),
    );
    canvas.restore();
    // Border on the sides and bottom only (`border-top: none`).
    final open = Path()
      ..moveTo(body.left + border / 2, body.top)
      ..lineTo(body.left + border / 2, body.bottom - 30 * k)
      ..arcToPoint(
        Offset(body.left + 30 * k, body.bottom - border / 2),
        radius: Radius.circular(30 * k - border / 2),
        clockwise: false,
      )
      ..lineTo(body.right - 30 * k, body.bottom - border / 2)
      ..arcToPoint(
        Offset(body.right - border / 2, body.bottom - 30 * k),
        radius: Radius.circular(30 * k - border / 2),
        clockwise: false,
      )
      ..lineTo(body.right - border / 2, body.top);
    canvas.drawPath(
      open,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = border
        ..color = edge,
    );
    // The rim and its inside.
    final rim = Rect.fromLTWH(0, 0, bucketWidth + 2 * rimOut, rimH);
    canvas.drawOval(
      rim,
      Paint()..color = dark ? _Colors.slate700 : _Colors.slate400,
    );
    canvas.drawOval(
      rim.deflate(border / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = border
        ..color = edge,
    );
    canvas.drawOval(
      rim.deflate(border * 2),
      Paint()
        ..color = hot
            ? const Color(0x996366F1)
            : (dark ? _Colors.slate800 : _Colors.slate500),
    );
  }

  @override
  bool shouldRepaint(covariant _BucketPainter old) =>
      old.dark != dark || old.hot != hot || old.bucketWidth != bucketWidth;
}

/// HTML `.s3-blank`: a dashed slot (`bg-slate-200/50`,
/// `border-slate-400/80`; dark `bg-slate-800/50`, `border-slate-600/80`)
/// with a "?" hint, solid indigo while a word is over it (`.highlight`,
/// grown 10%), filled by the word once placed.
class _Blank extends StatelessWidget {
  const _Blank({
    required this.size,
    required this.hot,
    required this.dark,
    required this.semantics,
    required this.hint,
    required this.card,
  });

  final Size size;
  final bool hot;
  final bool dark;
  final String semantics;
  final Widget hint;
  final Widget? card;

  @override
  Widget build(BuildContext context) {
    final placed = card;
    final radius = math.min(8.0, size.height * 0.25);
    final Widget background = hot
        ? Container(
            decoration: BoxDecoration(
              color: const Color(0x33818CF8),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: _Colors.indigo400, width: 2),
            ),
          )
        : CustomPaint(
            painter: _DashedRRectPainter(
              color: dark ? const Color(0xCC475569) : const Color(0xCC94A3B8),
              radius: radius,
              width: 2,
              fill: dark ? const Color(0x801E293B) : const Color(0x80E2E8F0),
            ),
          );
    return AnimatedScale(
      scale: hot ? 1.1 : 1,
      duration: const Duration(milliseconds: 300),
      curve: const Cubic(0.4, 0, 0.2, 1),
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(container: true, label: semantics, child: background),
            ?placed,
            if (placed == null) hint,
          ],
        ),
      ),
    );
  }
}

/// HTML `#btn-verify`: an indigo gradient (`from-indigo-600
/// to-indigo-500`), white `font-black` text, `rounded-2xl`, `border-2
/// border-white/20`, `shadow-2xl shadow-indigo-500/40`; half transparent
/// until every card is placed (it still answers a tap); emerald with a tick
/// and 'CORRECT!' after a right answer.
class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.size,
    required this.scale,
    required this.label,
    required this.correctLabel,
    required this.ready,
    required this.correct,
    required this.onTap,
  });

  final Size size;
  final double scale;
  final String label;
  final String correctLabel;
  final bool ready;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(16);
    final text = correct ? correctLabel : label;
    return Semantics(
      button: true,
      label: text,
      onTap: onTap,
      child: ExcludeSemantics(
        child: AnimatedOpacity(
          opacity: ready || correct ? 1 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: correct ? _Colors.emerald500 : null,
                gradient: correct
                    ? null
                    : const LinearGradient(
                        colors: [_Colors.indigo600, _Colors.indigo500],
                      ),
                borderRadius: radius,
                border: Border.all(
                  color: correct ? _Colors.emerald400 : const Color(0x33FFFFFF),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x666366F1),
                    blurRadius: 40,
                    spreadRadius: -12,
                    offset: Offset(0, 25),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * s),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (correct) ...[
                            Icon(
                              Icons.check_circle,
                              size: 22 * s,
                              color: _Colors.white,
                            ),
                            SizedBox(width: 6 * s),
                          ],
                          Text(
                            text,
                            maxLines: 1,
                            style: TextStyle(
                              color: _Colors.white,
                              fontSize: math.max(16 * s, 13),
                              fontWeight: FontWeight.w900,
                              letterSpacing: labLetterSpacing(text, 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The HTML's people-talking photo in its frame (`bg-white rounded-xl
/// shadow-md border-4 border-indigo-200 dark:border-indigo-900`), painted
/// by [_PeoplePainter].
class _PeoplePicture extends StatelessWidget {
  const _PeoplePicture({
    required this.size,
    required this.dark,
    required this.semantics,
  });

  final Size size;
  final bool dark;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark ? _Colors.indigo900 : _Colors.indigo200,
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Semantics(
        image: true,
        label: semantics,
        child: const CustomPaint(painter: _PeoplePainter()),
      ),
    );
  }
}

/// A rounded rect with a dashed border (and an optional fill).
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    this.width = 2,
    this.fill,
  });

  final Color color;
  final double radius;
  final double width;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    final f = fill;
    if (f != null) canvas.drawRRect(rr, Paint()..color = f);
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 6,
      gap: 4,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.width != width ||
      old.fill != fill;
}

// ================================================================== PAINTING

/// What the scene painter makes once and reuses: pens, the label text
/// painters and the three pictures (recorded once, drawn at any size).
/// Owned by the page state and disposed with it.
class _PaintCache {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint glow = Paint();
  final Path path = Path();
  final Map<String, TextPainter> _labels = {};
  final List<ui.Picture?> _art = List.filled(_markerPos.length, null);
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

  /// HTML `.marker-label`: white bold `uppercase tracking-widest` text.
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text.toUpperCase(),
      style: TextStyle(
        color: _Colors.chipText,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        letterSpacing: labLetterSpacing(text, _labelSize * _labelTracking),
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Size of the label chip with [text] (`px-4 py-1.5`).
  Size chipSize(String text) {
    final tp = label(text);
    return Size(
      tp.width + 2 * _chipPadX * _labelSize,
      tp.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// Picture [i] in its [_Art.box].
  ui.Picture art(int i) => _art[i] ??= _Art.record(i);

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    for (var i = 0; i < _art.length; i++) {
      _art[i]?.dispose();
      _art[i] = null;
    }
  }
}

/// Paints the HTML Three.js layer: the canvas colour, the faint floor grid
/// seen by the (tweened) camera and, in Scenario 1, the three picture
/// markers with their labels. Scenario 2 dims it all to 10%.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.lang,
    required this.labelSize,
    required this.pixel,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final LabLang lang;
  final double labelSize;

  /// One screen pixel in design px (the WebGL lines are 1 px wide).
  final double pixel;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final cam = s.camera();
    canvas.drawRect(
      labBleed(size),
      cache.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    final opacity = s.sceneOpacity;
    _paintGrid(canvas, cam, opacity);
    if (s.markersShown) _paintMarkers(canvas, cam);
  }

  /// `GridHelper(30, 30, 0x000000, 0x000000)` at opacity 0.05.
  void _paintGrid(Canvas canvas, _Cam cam, double opacity) {
    final path = cache.path..reset();
    const h = _gridHalf * 1.0;
    for (var i = -_gridHalf; i <= _gridHalf; i++) {
      final v = i.toDouble();
      for (final (a, b) in [
        (_V(v, 0, -h), _V(v, 0, h)),
        (_V(-h, 0, v), _V(h, 0, v)),
      ]) {
        final seg = cam.segment(a, b, _gridClip);
        if (seg == null) continue;
        path
          ..moveTo(seg.$1.dx, seg.$1.dy)
          ..lineTo(seg.$2.dx, seg.$2.dy);
      }
    }
    canvas.drawPath(
      path,
      cache.stroke
        ..strokeWidth = pixel
        ..color = _Colors.grid.withValues(alpha: _Colors.grid.a * opacity),
    );
  }

  /// HTML `.icon-marker`s: each picture card centred with its label on its
  /// projected point, sized by the camera distance.
  void _paintMarkers(Canvas canvas, _Cam cam) {
    final labelH = cache.chipSize(_t(_markerKeys.first)).height;
    for (var i = 0; i < _markerPos.length; i++) {
      // HTML: hidden when the point is behind the camera.
      if (cam.depth(_markerPos[i]) <= _near) continue;
      final (card, anchor) = cam.marker(i, labelH);
      _paintPicture(canvas, i, card);
      if (scene.labelAlpha > 0.01) {
        _chip(canvas, anchor, _t(_markerKeys[i]), scene.labelAlpha);
      }
    }
  }

  /// A picture card: `rounded-xl`, the coloured glow
  /// (`shadow-[0_0_30px_rgba(…,0.3)]`) and `ring-4` ring (emerald, blue,
  /// amber at 50%), the picture (`object-cover`) and its 1 px border
  /// (`border-white/50 dark:border-slate-600`).
  void _paintPicture(Canvas canvas, int i, Rect rect) {
    final k = rect.width / _markerCard.width;
    final ring = const [
      _Colors.ringKitchen,
      _Colors.ringBicycle,
      _Colors.ringRoom,
    ][i];
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(_markerRadius * k),
    );
    canvas.drawRRect(
      rr,
      cache.glow
        ..color = ring.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(1, _markerGlow * k / 2),
        ),
    );
    canvas.drawRRect(
      rr.inflate(_markerRing * k / 2),
      cache.stroke
        ..strokeWidth = _markerRing * k
        ..color = ring.withValues(alpha: 0.5),
    );
    canvas.save();
    canvas.clipRRect(rr);
    canvas.translate(rect.left, rect.top);
    canvas.scale(rect.width / _Art.box.width, rect.height / _Art.box.height);
    canvas.drawPicture(cache.art(i));
    canvas.restore();
    canvas.drawRRect(
      rr.deflate(0.5 * k),
      cache.stroke
        ..strokeWidth = math.max(pixel, k)
        ..color = isDark ? _Colors.slate600 : const Color(0x80FFFFFF),
    );
  }

  /// HTML `.marker-label`: `bg-slate-900/90`, `border-slate-700`,
  /// `rounded-xl`, `shadow-lg`, hanging from [anchor]; it fades with the
  /// 'Toggle Labels' tool.
  void _chip(Canvas canvas, Offset anchor, String text, double alpha) {
    final size = cache.chipSize(text);
    final rect = (anchor + _chipOffset(size, _hang)) & size;
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(12, size.height * 0.4)),
    );
    final fade = alpha < 0.99;
    if (fade) {
      canvas.saveLayer(
        rect.inflate(12),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
    canvas.drawRRect(
      rr.shift(const Offset(0, 4)),
      cache.glow
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(rr, cache.fill..color = _Colors.chipBg);
    canvas.drawRRect(
      rr,
      cache.stroke
        ..strokeWidth = math.max(pixel, 1)
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text);
    tp.paint(
      canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
    if (fade) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.pixel != pixel;
}

/// The HTML's people-talking photo, painted (`object-contain` in its
/// frame).
class _PeoplePainter extends CustomPainter {
  const _PeoplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const box = _Art.peopleBox;
    final k = math.min(size.width / box.width, size.height / box.height);
    canvas.save();
    canvas.translate(
      (size.width - box.width * k) / 2,
      (size.height - box.height * k) / 2,
    );
    canvas.scale(k);
    _Art.people(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PeoplePainter old) => false;
}

/// The HTML's photos (`cooker_scene`, `bicycle_scene`, `room_scene`,
/// `people_talking` JPGs, which the page loaded from its author's disk),
/// redrawn as flat illustrations of the same scenes: dal boiled over from
/// a pressure cooker on a stove, a bicycle with a flat rear tyre, a dark
/// room whose bulb does not light (with the electrician's ladder and
/// toolbox), and four people talking around a table.
abstract final class _Art {
  /// Box of the marker pictures (the 224 x 160 photo cards).
  static const Size box = Size(140, 100);

  /// Box of the people-talking picture.
  static const Size peopleBox = Size(160, 90);

  static final Paint _fill = Paint();
  static final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Records marker picture [i] (0 kitchen, 1 bicycle, 2 room).
  static ui.Picture record(int i) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & box);
    switch (i) {
      case 0:
        kitchen(canvas);
      case 1:
        bicycle(canvas);
      default:
        room(canvas);
    }
    return recorder.endRecording();
  }

  // ------------------------------------------------------------- helpers

  static void _rect(Canvas c, Rect r, Color color) =>
      c.drawRect(r, _fill..color = color);

  static void _rrect(Canvas c, Rect r, double radius, Color color) =>
      c.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(radius)),
        _fill..color = color,
      );

  static void _oval(Canvas c, Rect r, Color color) =>
      c.drawOval(r, _fill..color = color);

  static void _circle(Canvas c, Offset o, double r, Color color) =>
      c.drawCircle(o, r, _fill..color = color);

  static void _seg(Canvas c, Offset a, Offset b, Color color, double width) =>
      c.drawLine(
        a,
        b,
        _line
          ..color = color
          ..strokeWidth = width,
      );

  static void _stroke(Canvas c, Path p, Color color, double width) =>
      c.drawPath(
        p,
        _line
          ..color = color
          ..strokeWidth = width,
      );

  static void _path(Canvas c, Path p, Color color) =>
      c.drawPath(p, _fill..color = color);

  static Paint _linear(
    Offset a,
    Offset b,
    List<Color> colors, [
    List<double>? stops,
  ]) => Paint()..shader = ui.Gradient.linear(a, b, colors, stops);

  // ------------------------------------------------------------- kitchen

  /// `cooker_scene`: a tiled kitchen with a window; on the stove a
  /// pressure cooker whose dal has foamed out from under the lid, run down
  /// its sides and pooled on the stove top; steam from the whistle.
  static void kitchen(Canvas c) {
    // Wall and tiled backsplash.
    _rect(c, const Rect.fromLTWH(0, 0, 140, 68), _Colors.kitchenWall);
    for (var row = 0; row < 4; row++) {
      final y = 34.0 + row * 8;
      _seg(c, Offset(0, y), Offset(140, y), _Colors.kitchenTile, 0.6);
      for (var x = row.isEven ? 0.0 : 5.0; x <= 140; x += 10) {
        _seg(c, Offset(x, y), Offset(x, y + 8), _Colors.kitchenTile, 0.6);
      }
    }
    // Window with a sky and a cloud.
    const win = Rect.fromLTWH(10, 6, 30, 21);
    c.drawRect(
      win,
      _linear(win.topCenter, win.bottomCenter, const [
        Color(0xFF7DD3FC),
        _Colors.windowSky,
      ]),
    );
    _oval(c, const Rect.fromLTWH(14, 15, 13, 4), _Colors.white);
    _oval(c, const Rect.fromLTWH(17, 12.5, 7, 4.5), _Colors.white);
    c.drawRect(
      win,
      _line
        ..color = _Colors.windowFrame
        ..strokeWidth = 2,
    );
    _seg(c, win.topCenter, win.bottomCenter, _Colors.windowFrame, 1.3);
    _seg(c, win.centerLeft, win.centerRight, _Colors.windowFrame, 1.3);
    _rect(c, const Rect.fromLTWH(8, 27, 34, 2.4), const Color(0xFFE7E5E4));
    // Utensil rail with a ladle and a spatula.
    _seg(c, const Offset(110, 8), const Offset(134, 8), _Colors.steelDark, 1.2);
    _seg(c, const Offset(117, 8), const Offset(117, 21), _Colors.steelDark, 1);
    _oval(c, const Rect.fromLTWH(113.5, 20, 7, 5), _Colors.steel);
    _seg(c, const Offset(127, 8), const Offset(127, 19), _Colors.steelDark, 1);
    _rrect(c, const Rect.fromLTWH(124.5, 19, 5, 7), 1, _Colors.steel);
    // Counter and cabinet doors.
    _rect(c, const Rect.fromLTWH(0, 66, 140, 6), _Colors.counterTop);
    _rect(c, const Rect.fromLTWH(0, 72, 140, 28), _Colors.cabinet);
    for (var i = 0; i < 4; i++) {
      final x = 4.0 + i * 34;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 75, 31, 22),
          const Radius.circular(1.5),
        ),
        _line
          ..color = _Colors.cabinetDark
          ..strokeWidth = 0.9,
      );
      _circle(c, Offset(x + (i.isEven ? 27 : 4), 86), 1.3, _Colors.handle);
    }
    // Stove with its knobs.
    _rrect(c, const Rect.fromLTWH(44, 57, 74, 10), 1.5, _Colors.stove);
    _rect(c, const Rect.fromLTWH(42, 55.5, 78, 2.5), _Colors.stoveTop);
    for (final x in const [52.0, 60.0, 102.0, 110.0]) {
      _circle(c, Offset(x, 62.5), 1.9, _Colors.knob);
      _circle(c, Offset(x, 62.5), 0.6, _Colors.stove);
    }
    // Blue flame under the cooker.
    for (var x = 66.0; x < 94; x += 3.5) {
      _path(
        c,
        Path()
          ..moveTo(x, 55.5)
          ..lineTo(x + 1.6, 51.2)
          ..lineTo(x + 3.2, 55.5)
          ..close(),
        _Colors.flame,
      );
      _path(
        c,
        Path()
          ..moveTo(x + 0.8, 55.5)
          ..lineTo(x + 1.6, 53.4)
          ..lineTo(x + 2.4, 55.5)
          ..close(),
        _Colors.flameCore,
      );
    }
    _seg(
      c,
      const Offset(62, 55.4),
      const Offset(98, 55.4),
      const Color(0xFF52525B),
      1.2,
    );
    // Dal pooled on the stove top and splashed beside it.
    _oval(c, const Rect.fromLTWH(55, 52.6, 52, 6), _Colors.dal);
    c.drawOval(
      const Rect.fromLTWH(55, 52.6, 52, 6),
      _line
        ..color = _Colors.dalDark
        ..strokeWidth = 0.6,
    );
    _oval(c, const Rect.fromLTWH(59, 53.4, 24, 2.6), _Colors.dalLight);
    _oval(c, const Rect.fromLTWH(108, 54.2, 7, 2.6), _Colors.dal);
    _oval(c, const Rect.fromLTWH(46, 54.6, 5, 2), _Colors.dal);
    // Cooker body, side handle.
    final body = RRect.fromLTRBAndCorners(
      64,
      33,
      96,
      54,
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    c.drawRRect(
      body,
      _linear(
        const Offset(64, 0),
        const Offset(96, 0),
        const [_Colors.steelLight, _Colors.steel, _Colors.steelDark],
        const [0, 0.45, 1],
      ),
    );
    _rrect(c, const Rect.fromLTWH(58.5, 38, 6.5, 3), 1.2, _Colors.cookerHandle);
    // Dal running down the sides.
    for (final (x, len) in const [
      (67.0, 9.0),
      (74.0, 14.0),
      (88.0, 6.0),
      (92.5, 11.0),
    ]) {
      final drip = Path()
        ..moveTo(x - 1.7, 34)
        ..lineTo(x - 1.7, 34 + len)
        ..arcToPoint(
          Offset(x + 1.7, 34 + len),
          radius: const Radius.circular(1.7),
          clockwise: false,
        )
        ..lineTo(x + 1.7, 34)
        ..close();
      _path(c, drip, _Colors.dal);
      _seg(
        c,
        Offset(x - 0.6, 35),
        Offset(x - 0.6, 33 + len),
        _Colors.dalLight,
        0.7,
      );
    }
    // Lid, long handle and the foam pushing out under the lid.
    const lid = Rect.fromLTWH(61.5, 29.5, 37, 7);
    c.drawOval(
      lid,
      _linear(lid.centerLeft, lid.centerRight, const [
        _Colors.steelLight,
        _Colors.steel,
      ]),
    );
    c.drawOval(
      lid,
      _line
        ..color = _Colors.steelDark
        ..strokeWidth = 0.7,
    );
    _seg(
      c,
      const Offset(96, 31.6),
      const Offset(127, 27),
      _Colors.cookerHandle,
      3.6,
    );
    for (final (x, y, r) in const [
      (64.5, 34.2, 3.2),
      (70.0, 35.6, 2.6),
      (77.0, 36.2, 2.4),
      (84.0, 36.4, 2.3),
      (90.0, 35.9, 2.6),
      (95.6, 34.0, 2.6),
    ]) {
      _circle(c, Offset(x, y), r, _Colors.dal);
      _circle(c, Offset(x - r * 0.3, y - r * 0.3), r * 0.45, _Colors.dalLight);
    }
    // Whistle (weight) and its steam.
    _rrect(c, const Rect.fromLTWH(77.5, 23, 5, 8), 1, _Colors.cookerHandle);
    _circle(c, const Offset(80, 22.4), 2.4, _Colors.cookerHandle);
    for (final (x, y, r) in const [
      (83.0, 15.0, 4.0),
      (87.0, 9.0, 3.2),
      (82.0, 4.5, 2.6),
    ]) {
      _circle(c, Offset(x, y), r, _Colors.steam);
      c.drawCircle(
        Offset(x, y),
        r,
        _line
          ..color = const Color(0x40A8A29E)
          ..strokeWidth = 0.5,
      );
    }
  }

  // ------------------------------------------------------------- bicycle

  /// `bicycle_scene`: a blue bicycle by a brick wall, its rear tyre flat
  /// (squashed on the ground, the rim nearly on the road), a pump lying
  /// beside it.
  static void bicycle(Canvas c) {
    // Sky, clouds and sun.
    const sky = Rect.fromLTWH(0, 0, 140, 56);
    c.drawRect(
      sky,
      _linear(sky.topCenter, sky.bottomCenter, const [
        Color(0xFFBAE6FD),
        _Colors.skyLow,
      ]),
    );
    _circle(c, const Offset(126, 9), 5, const Color(0xFFFDE047));
    _oval(c, const Rect.fromLTWH(12, 10, 22, 7), _Colors.cloud);
    _oval(c, const Rect.fromLTWH(18, 6.5, 12, 7), _Colors.cloud);
    _oval(c, const Rect.fromLTWH(84, 15, 26, 8), _Colors.cloud);
    _oval(c, const Rect.fromLTWH(91, 11, 13, 8), _Colors.cloud);
    // Low brick wall.
    _rect(c, const Rect.fromLTWH(0, 46, 140, 40), _Colors.wallBrick);
    for (var row = 0; row < 8; row++) {
      final y = 46.0 + row * 5;
      _seg(c, Offset(0, y), Offset(140, y), _Colors.brickLine, 0.6);
      for (var x = row.isEven ? 0.0 : 6.0; x < 140; x += 12) {
        _seg(c, Offset(x, y), Offset(x, y + 5), _Colors.brickLine, 0.6);
      }
    }
    _rect(c, const Rect.fromLTWH(0, 43.5, 140, 3), const Color(0xFFFB923C));
    // A bush.
    _circle(c, const Offset(8, 80), 10, _Colors.bushDark);
    _circle(c, const Offset(18, 79), 8.5, _Colors.bush);
    _circle(c, const Offset(6, 73), 7, _Colors.bush);
    // Road.
    _rect(c, const Rect.fromLTWH(0, 86, 140, 14), _Colors.ground);
    _seg(
      c,
      const Offset(0, 86),
      const Offset(140, 86),
      _Colors.groundLine,
      0.8,
    );
    for (var x = 12.0; x < 140; x += 28) {
      _seg(c, Offset(x, 86), Offset(x - 6, 100), _Colors.groundLine, 0.5);
    }
    _oval(c, const Rect.fromLTWH(22, 90.5, 98, 4.5), const Color(0x33000000));

    const rear = Offset(40, 77.5);
    const front = Offset(102, 76.5);
    const bb = Offset(66, 79);
    void spokes(Offset hub, double r) {
      for (var k = 0; k < 12; k++) {
        final a = k * math.pi / 6 + 0.2;
        _seg(
          c,
          hub,
          hub + Offset(math.cos(a), math.sin(a)) * r,
          _Colors.spoke,
          0.45,
        );
      }
    }

    // Wheels: the front one round, the rear tyre flat.
    spokes(front, 13.5);
    c.drawCircle(
      front,
      13.5,
      _line
        ..color = _Colors.rim
        ..strokeWidth = 1.2,
    );
    c.drawCircle(
      front,
      16,
      _line
        ..color = _Colors.tyre
        ..strokeWidth = 3.4,
    );
    spokes(rear, 12.5);
    c.drawCircle(
      rear,
      12.5,
      _line
        ..color = _Colors.rim
        ..strokeWidth = 1.2,
    );
    final flat = Path()
      ..moveTo(24.2, 82)
      ..arcToPoint(
        const Offset(55.8, 82),
        radius: const Radius.circular(16.4),
        largeArc: true,
      )
      ..quadraticBezierTo(58.5, 90.8, 50, 91.6)
      ..lineTo(30, 91.6)
      ..quadraticBezierTo(21.5, 90.8, 24.2, 82);
    _stroke(c, flat, _Colors.tyre, 3.4);
    _circle(c, rear, 1.8, _Colors.steelDark);
    _circle(c, front, 1.8, _Colors.steelDark);
    // Chain and chainring.
    c.drawCircle(
      bb,
      5.5,
      _line
        ..color = _Colors.chain
        ..strokeWidth = 1.4,
    );
    c.drawCircle(
      rear,
      2.6,
      _line
        ..color = _Colors.chain
        ..strokeWidth = 1,
    );
    _seg(
      c,
      bb + const Offset(0, -5.5),
      rear + const Offset(0, -2.6),
      _Colors.chain,
      0.9,
    );
    _seg(
      c,
      bb + const Offset(0, 5.5),
      rear + const Offset(0, 2.6),
      _Colors.chain,
      0.9,
    );
    // Frame and fork.
    const seat = Offset(60, 52);
    const headTop = Offset(93, 50);
    const headBottom = Offset(95.5, 57);
    for (final (a, b) in const [
      (rear, bb),
      (rear, seat),
      (bb, seat),
      (seat, headTop),
      (bb, headBottom),
    ]) {
      _seg(c, a, b, _Colors.frame, 3);
    }
    _seg(c, headTop, headBottom, _Colors.frameDark, 3.8);
    _seg(c, headBottom, front, _Colors.frameDark, 2.6);
    // Seat post and saddle.
    _seg(c, seat, const Offset(58.5, 45), _Colors.steelDark, 2);
    _path(
      c,
      Path()
        ..moveTo(51, 44.4)
        ..quadraticBezierTo(58, 41.4, 66, 43.4)
        ..lineTo(66, 45.4)
        ..quadraticBezierTo(58, 46.6, 51, 46)
        ..close(),
      _Colors.saddle,
    );
    // Handlebar.
    _seg(c, headTop, const Offset(91.5, 43.5), _Colors.steelDark, 2);
    _seg(
      c,
      const Offset(91.5, 43.5),
      const Offset(98.5, 42),
      _Colors.saddle,
      2.4,
    );
    _seg(
      c,
      const Offset(98.5, 42),
      const Offset(101.5, 43.2),
      _Colors.saddle,
      3,
    );
    // Crank and pedal.
    _seg(c, bb, const Offset(70, 87), _Colors.steelDark, 1.8);
    _rrect(c, const Rect.fromLTWH(67, 86.2, 7, 1.8), 0.6, _Colors.saddle);
    _circle(c, bb, 1.8, _Colors.steelDark);
    // A pump on the ground.
    c.save();
    c.translate(124, 93);
    c.rotate(-0.22);
    _rrect(c, const Rect.fromLTWH(-9, -2, 16, 4), 1, _Colors.pump);
    _seg(c, const Offset(7, 0), const Offset(11, 0), _Colors.steelDark, 1);
    _seg(c, const Offset(11, -3), const Offset(11, 3), _Colors.saddle, 1.8);
    _stroke(
      c,
      Path()
        ..moveTo(-9, 0)
        ..quadraticBezierTo(-15, 1, -14, 5),
      _Colors.saddle,
      0.9,
    );
    c.restore();
  }

  // ---------------------------------------------------------------- room

  /// `room_scene`: a dim room at night: a bulb hanging from the ceiling
  /// that does not light (dark glass, broken filament), a wall switch, a
  /// sofa, a night window, a step ladder and a toolbox.
  static void room(Canvas c) {
    const wall = Rect.fromLTWH(0, 0, 140, 84);
    c.drawRect(
      wall,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(72, 40),
          90,
          const [_Colors.roomWall, _Colors.roomWallShade, Color(0xFFA8A29E)],
          const [0, 0.7, 1],
        ),
    );
    _rect(c, const Rect.fromLTWH(0, 0, 140, 6), _Colors.ceiling);
    _seg(
      c,
      const Offset(0, 6),
      const Offset(140, 6),
      _Colors.roomWallShade,
      0.8,
    );
    // Night window with the moon and stars.
    const win = Rect.fromLTWH(8, 20, 30, 30);
    c.drawRect(
      win,
      _linear(win.topCenter, win.bottomCenter, const [
        _Colors.night,
        _Colors.nightLow,
      ]),
    );
    _circle(c, const Offset(30, 28), 4, _Colors.moon);
    _circle(c, const Offset(32, 26.8), 3.4, _Colors.night);
    for (final o in const [
      Offset(13, 25),
      Offset(20, 33),
      Offset(14, 42),
      Offset(25, 45),
      Offset(34, 40),
    ]) {
      _circle(c, o, 0.6, _Colors.white);
    }
    c.drawRect(
      win,
      _line
        ..color = const Color(0xFFF5F5F4)
        ..strokeWidth = 2,
    );
    _seg(c, win.topCenter, win.bottomCenter, const Color(0xFFF5F5F4), 1.3);
    _seg(c, win.centerLeft, win.centerRight, const Color(0xFFF5F5F4), 1.3);
    _rect(c, const Rect.fromLTWH(6, 50, 34, 2.2), const Color(0xFFF5F5F4));
    // Floor and skirting.
    _rect(c, const Rect.fromLTWH(0, 84, 140, 16), _Colors.floorWood);
    for (final y in const [89.0, 94.5]) {
      _seg(c, Offset(0, y), Offset(140, y), _Colors.floorLine, 0.6);
    }
    for (var x = 18.0; x < 140; x += 36) {
      _seg(c, Offset(x, 84), Offset(x, 89), _Colors.floorLine, 0.5);
      _seg(c, Offset(x + 18, 89), Offset(x + 18, 94.5), _Colors.floorLine, 0.5);
    }
    _rect(c, const Rect.fromLTWH(0, 82.5, 140, 1.8), const Color(0xFF78716C));
    // Sofa.
    _rrect(c, const Rect.fromLTWH(5, 61, 42, 14), 3, _Colors.sofaDark);
    _rrect(c, const Rect.fromLTWH(7, 70, 38, 9), 2.5, _Colors.sofa);
    _rrect(c, const Rect.fromLTWH(2, 65, 7, 15), 2.5, _Colors.sofaDark);
    _rrect(c, const Rect.fromLTWH(43, 65, 7, 15), 2.5, _Colors.sofaDark);
    _rect(c, const Rect.fromLTWH(5, 80, 2, 3), _Colors.cord);
    _rect(c, const Rect.fromLTWH(45, 80, 2, 3), _Colors.cord);
    // The bulb on its cord: dark glass, a broken filament, no light.
    _seg(c, const Offset(72, 6), const Offset(72, 30), _Colors.cord, 1);
    _rrect(c, const Rect.fromLTWH(69, 29, 6, 7.4), 1, _Colors.socket);
    for (final y in const [31.0, 33.0, 35.0]) {
      _seg(c, Offset(69.4, y), Offset(74.6, y), const Color(0xFF78716C), 0.5);
    }
    final glass = Path()
      ..moveTo(69.6, 36)
      ..lineTo(74.4, 36)
      ..cubicTo(74.4, 38.6, 80, 40.6, 80, 45.6)
      ..arcToPoint(const Offset(64, 45.6), radius: const Radius.circular(8))
      ..cubicTo(64, 40.6, 69.6, 38.6, 69.6, 36)
      ..close();
    c.drawPath(
      glass,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(68.5, 42),
          10,
          const [Color(0xFFF9FAFB), _Colors.bulbGlass, _Colors.bulbShade],
          const [0, 0.55, 1],
        ),
    );
    _stroke(c, glass, _Colors.bulbShade, 0.7);
    _stroke(
      c,
      Path()
        ..moveTo(70.2, 37.4)
        ..lineTo(70.6, 42)
        ..lineTo(71.5, 40.4),
      _Colors.filament,
      0.7,
    );
    _stroke(
      c,
      Path()
        ..moveTo(72.7, 41.2)
        ..lineTo(73.4, 42.4)
        ..lineTo(73.8, 37.4),
      _Colors.filament,
      0.7,
    );
    // Wall switch.
    _rrect(c, const Rect.fromLTWH(114, 44, 9, 13), 1.5, _Colors.switchPlate);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(114, 44, 9, 13),
        const Radius.circular(1.5),
      ),
      _line
        ..color = _Colors.roomWallShade
        ..strokeWidth = 0.6,
    );
    _rrect(
      c,
      const Rect.fromLTWH(117.3, 47.6, 2.4, 5),
      0.8,
      const Color(0xFF57534E),
    );
    // The electrician's step ladder.
    const legL = (Offset(85, 92), Offset(92, 48));
    const legR = (Offset(101, 92), Offset(98, 48));
    for (var i = 1; i <= 4; i++) {
      final t = i / 5;
      _seg(
        c,
        Offset.lerp(legL.$1, legL.$2, t)!,
        Offset.lerp(legR.$1, legR.$2, t)!,
        _Colors.ladderDark,
        1.6,
      );
    }
    _seg(c, legL.$1, legL.$2, _Colors.ladder, 2.4);
    _seg(c, legR.$1, legR.$2, _Colors.ladder, 2.4);
    _rrect(c, const Rect.fromLTWH(89.5, 45.5, 11, 3), 1, _Colors.ladderDark);
    // Toolbox.
    _rrect(c, const Rect.fromLTWH(108, 80, 22, 10), 1.5, _Colors.toolbox);
    _rect(c, const Rect.fromLTWH(108, 80, 22, 3), _Colors.toolboxDark);
    _stroke(
      c,
      Path()..addArc(const Rect.fromLTWH(114, 75.5, 10, 9), math.pi, math.pi),
      const Color(0xFF57534E),
      1.4,
    );
    // No light: the whole room is dim.
    _rect(c, Offset.zero & box, const Color(0x24000000));
  }

  // -------------------------------------------------------------- people

  /// `people_talking`: four people talking around a table, with speech
  /// bubbles (a question, an idea, '…' and '!').
  static void people(Canvas c) {
    _oval(c, const Rect.fromLTWH(8, 80, 144, 8), const Color(0x14000000));
    _person(
      c,
      x: 24,
      skin: _Colors.skinMid,
      shirt: _Colors.shirtIndigo,
      hair: _Colors.hair,
      facing: 1,
      armUp: true,
    );
    _person(
      c,
      x: 60,
      skin: _Colors.skinLight,
      shirt: _Colors.shirtRose,
      hair: _Colors.hairBrown,
      facing: 1,
      longHair: true,
    );
    _person(
      c,
      x: 100,
      skin: _Colors.skinDark,
      shirt: _Colors.shirtEmerald,
      hair: _Colors.hair,
      facing: -1,
    );
    _person(
      c,
      x: 136,
      skin: _Colors.skinTan,
      shirt: _Colors.shirtAmber,
      hair: _Colors.hair,
      facing: -1,
      notebook: true,
    );
    // The table between them, a book and a cup on it.
    _rect(c, const Rect.fromLTWH(78, 68, 4, 18), _Colors.tableEdge);
    _oval(c, const Rect.fromLTWH(54, 63, 52, 10), _Colors.table);
    c.drawOval(
      const Rect.fromLTWH(54, 63, 52, 10),
      _line
        ..color = _Colors.tableEdge
        ..strokeWidth = 0.8,
    );
    _rrect(c, const Rect.fromLTWH(64, 64.6, 10, 3.2), 0.6, _Colors.indigo400);
    _rrect(c, const Rect.fromLTWH(88, 62.4, 4.6, 5), 0.8, _Colors.white);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(88, 62.4, 4.6, 5),
        const Radius.circular(0.8),
      ),
      _line
        ..color = _Colors.tableEdge
        ..strokeWidth = 0.5,
    );
    // Speech bubbles.
    _bubble(c, const Rect.fromLTWH(6, 3, 26, 16), 20, '?');
    _bubble(c, const Rect.fromLTWH(44, 9, 22, 13), 56, '…');
    _bubble(c, const Rect.fromLTWH(90, 1, 26, 17), 102, 'idea');
    _bubble(c, const Rect.fromLTWH(126, 7, 24, 15), 134, '!');
  }

  /// A person seen from the front: shirt, arms, head, hair and a smile;
  /// [facing] turns the face and the raised or holding hand (1 right, -1
  /// left).
  static void _person(
    Canvas c, {
    required double x,
    required Color skin,
    required Color shirt,
    required Color hair,
    required double facing,
    bool armUp = false,
    bool longHair = false,
    bool notebook = false,
  }) {
    final f = facing;
    if (longHair) _rrect(c, Rect.fromLTWH(x - 9.5, 28, 19, 24), 8, hair);
    // Far arm down.
    _seg(
      c,
      Offset(x - 10.5 * f, 50),
      Offset(x - 13 * f, 69),
      labShade(shirt, -0.12),
      5,
    );
    _circle(c, Offset(x - 13.3 * f, 71), 2.5, skin);
    // Body and neck.
    _rect(c, Rect.fromLTWH(x - 2.6, 42, 5.2, 6), skin);
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        x - 12,
        46,
        x + 12,
        88,
        topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7),
      ),
      _fill..color = shirt,
    );
    _path(
      c,
      Path()
        ..moveTo(x - 3.4, 46)
        ..lineTo(x, 50.5)
        ..lineTo(x + 3.4, 46)
        ..close(),
      skin,
    );
    // Near arm: raised to make a point, or holding a notebook, or down.
    if (armUp) {
      _seg(c, Offset(x + 10 * f, 50), Offset(x + 18 * f, 39), shirt, 5);
      _circle(c, Offset(x + 19 * f, 37), 2.7, skin);
    } else if (notebook) {
      _seg(c, Offset(x + 10.5 * f, 50), Offset(x + 4 * f, 64), shirt, 5);
      final book = Rect.fromCenter(
        center: Offset(x - 1 * f, 64),
        width: 11,
        height: 13,
      );
      _rrect(c, book, 1, _Colors.white);
      c.drawRRect(
        RRect.fromRectAndRadius(book, const Radius.circular(1)),
        _line
          ..color = _Colors.bubbleEdge
          ..strokeWidth = 0.6,
      );
      for (var i = 1; i <= 3; i++) {
        final y = book.top + i * 3.2;
        _seg(
          c,
          Offset(book.left + 2, y),
          Offset(book.right - 2, y),
          _Colors.slate400,
          0.5,
        );
      }
      _circle(c, Offset(x + 3.5 * f, 65), 2.5, skin);
    } else {
      _seg(c, Offset(x + 10.5 * f, 50), Offset(x + 13 * f, 69), shirt, 5);
      _circle(c, Offset(x + 13.3 * f, 71), 2.5, skin);
    }
    // Head and hair.
    _circle(c, Offset(x, 34.4), 8.7, hair);
    _circle(c, Offset(x, 36.4), 8, skin);
    c.drawArc(
      Rect.fromCircle(center: Offset(x, 34.4), radius: 8.7),
      math.pi * 1.05,
      math.pi * 0.9,
      true,
      _fill..color = hair,
    );
    // Face, turned towards the others.
    _circle(c, Offset(x - 2.7 + f, 36.6), 0.9, _Colors.hair);
    _circle(c, Offset(x + 2.7 + f, 36.6), 0.9, _Colors.hair);
    c.drawArc(
      Rect.fromCenter(center: Offset(x + f, 39.6), width: 5, height: 3),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      _line
        ..color = _Colors.mouth
        ..strokeWidth = 0.8,
    );
  }

  /// A speech bubble with its tail towards [tailX] and a glyph: '?', '!',
  /// '…' or 'idea' (a lit bulb).
  static void _bubble(Canvas c, Rect r, double tailX, String glyph) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(5));
    final tail = Path()
      ..moveTo(tailX - 3, r.bottom - 0.6)
      ..lineTo(tailX - 1, r.bottom + 5)
      ..lineTo(tailX + 3, r.bottom - 0.6)
      ..close();
    _path(c, tail, _Colors.bubble);
    c.drawRRect(rr, _fill..color = _Colors.bubble);
    c.drawRRect(
      rr,
      _line
        ..color = _Colors.bubbleEdge
        ..strokeWidth = 0.8,
    );
    _stroke(
      c,
      Path()
        ..moveTo(tailX - 3, r.bottom)
        ..lineTo(tailX - 1, r.bottom + 5)
        ..lineTo(tailX + 3, r.bottom),
      _Colors.bubbleEdge,
      0.8,
    );
    final o = r.center;
    switch (glyph) {
      case '?':
        _stroke(
          c,
          Path()
            ..moveTo(o.dx - 2.6, o.dy - 2.4)
            ..cubicTo(
              o.dx - 2.6,
              o.dy - 6,
              o.dx + 3,
              o.dy - 6,
              o.dx + 3,
              o.dy - 2.8,
            )
            ..cubicTo(o.dx + 3, o.dy - 0.6, o.dx, o.dy - 0.8, o.dx, o.dy + 1.4),
          _Colors.indigo500,
          1.6,
        );
        _circle(c, o + const Offset(0, 3.8), 0.95, _Colors.indigo500);
      case '!':
        _seg(
          c,
          o + const Offset(0, -5),
          o + const Offset(0, 1),
          _Colors.shirtRose,
          1.8,
        );
        _circle(c, o + const Offset(0, 3.6), 1, _Colors.shirtRose);
      case '…':
        for (final dx in const [-4.0, 0.0, 4.0]) {
          _circle(c, o + Offset(dx, 0), 1.1, _Colors.slate500);
        }
      default:
        for (var k = 0; k < 5; k++) {
          final a = math.pi * (1.1 + k * 0.2);
          final u = Offset(math.cos(a), math.sin(a));
          _seg(
            c,
            o + u * 5 + const Offset(0, -1),
            o + u * 6.6 + const Offset(0, -1),
            _Colors.amber500,
            0.8,
          );
        }
        _circle(c, o + const Offset(0, -1), 3.6, _Colors.yellow400);
        _rrect(
          c,
          Rect.fromLTWH(o.dx - 1.6, o.dy + 2, 3.2, 2.6),
          0.6,
          _Colors.slate400,
        );
    }
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
