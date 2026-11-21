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

/// Class 6 Science • Chapter 4 • Activity 3
/// Using Magnets to Find Directions.
///
/// Native Flutter port of `Cl6S-Ch4-A3-Using_Magnets_to_Find_Directions.html`.
/// The Three.js bench is redrawn by a CustomPainter through a perspective
/// projection of the same camera (fov 45°, same position and look-at).
///
/// Scenario 1 (Freely Suspended Bar Magnet): drag the spool of thread onto
/// the bar magnet to tie it, hang the magnet on the suspension stand, then
/// spin it clockwise and counter-clockwise: each time it comes to rest
/// North–South over the compass rose.
///
/// Scenario 2 (Floating Cork Compass): stroke the sewing needle 30 times with
/// the bar magnet, push it through the cork disc, float the cork in the bowl
/// of water and watch it turn North–South; spin it again and it realigns.
class Ch4A3UsingMagnetsToFindDirectionsPage extends StatefulWidget {
  const Ch4A3UsingMagnetsToFindDirectionsPage({super.key});

  @override
  State<Ch4A3UsingMagnetsToFindDirectionsPage> createState() =>
      _Ch4A3UsingMagnetsToFindDirectionsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML has no sounds of its own, so the
/// lab uses the shell tones plus pickup / drop for dragged objects.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// Generic button click; also a tap that spins the magnet or the cork.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action / right answer (tied, hooked, settled...).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action / invalid move.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An object is put down on the table without completing a step.
  drop('audio/class6/science/drop.mp3'),

  /// An object is picked up from the table.
  pickup('audio/class6/science/pickup.mp3');

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

/// Tailwind colours of the HTML page and the Three.js material colours of
/// its bench.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // Enter Lab button
  // Tailwind `primary` (#6366f1) and the indigo shades of the page.
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900Glow = Color(0x66312E81); // indigo-900/40
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D); // light-theme green text
  static const Color red500 = Color(0xFFEF4444);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Bench (Three.js materials).
  static const Color canvas = Color(0xFF0F172A); // #canvas-wrapper bg
  static const Color table = Color(0xFF472D1E);
  static const Color standWood = Color(0xFF451A03);
  static const Color pillar = Color(0xFF4F46E5);
  static const Color hook = Color(0xFF94A3B8);
  static const Color magnetN = Color(0xFFDC2626);
  static const Color magnetS = Color(0xFF2563EB);
  static const Color spoolWood = Color(0xFF78350F);
  static const Color thread = Color(0xFFF1F5F9);
  static const Color threadTie = Color(0xFFF8FAFC);

  /// Needle steel: the HTML chrome (#f8fafc, metalness 0.95) renders as a
  /// light steel grey with a bright highlight.
  static const Color steel = Color(0xFFCBD5E1);
  static const Color needleGlow = Color(0xFF38BDF8);
  static const Color cork = Color(0xFFD97706);
  static const Color glass = Color(0xFFBAE6FD);
  static const Color water = Color(0xFF0284C7);
  static const Color waterTop = Color(0xFF38BDF8);

  // Compass rose texture.
  static const Color roseRing = Color(0xFF6366F1);
  static const Color roseDash = Color(0xFFCBD5E1);
  static const Color roseN = Color(0xFFEF4444);
  static const Color roseS = Color(0xFF3B82F6);
  static const Color roseWE = Color(0xFF64748B);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A), // slate-900/95
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvas,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400,
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: _Colors.indigo900Glow,
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xD90F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0x996366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xCC000000), // dark:bg-black/80
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2F8FAFC), // slate-50/95
    border: Color(0x26000000),
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvas,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green700,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: _Colors.indigo900Glow,
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE6FFFFFF),
    buttonIcon: _Colors.indigo600,
    buttonBorder: Color(0x996366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xCC0F172A), // bg-slate-900/80
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px): the
/// HTML default 15 and minimum 12; the HTML maximum (32) is the shell's
/// common 24 so the sidebar still fits a landscape phone.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
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
// From the HTML `i18n` table (Telugu dropped). The step instructions are
// the HTML "Procedural Steps" reworded so each says exactly what to do
// (tap instead of "click and drag", the button names, the automatic
// conclusion instead of "Validate Model"). The short HUD texts (sN_hud_M)
// go to the canvas HUD; the two that said "click Validate Model" now say
// the conclusion opens next. Strings marked "added" are new in the native
// version (hard-coded English in the HTML, or canvas text).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Using Magnets to Find Directions',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'scen_1_opt': 'Scenario 1: Freely Suspended Bar Magnet',
    'scen_2_opt': 'Scenario 2: Floating Cork Compass',
    'concept_exp': 'Procedural Steps',
    'obs_table': 'Observation Table',
    'tbl_trial': 'Experiment / Trial',
    'tbl_rest_dir': 'Resting Direction',
    'step_lbl': 'Step',
    'task_instr': 'Task Instruction', // added (HTML hard-coded)
    'exp_outcome': 'Expected Outcome', // added (HTML hard-coded)
    's1_desc':
        'To observe and verify that a freely suspended bar magnet always aligns itself in the geographic North-South direction.',
    's2_desc':
        'To construct a simple magnetic compass using a sewing needle, cork disc, and water bowl, verifying its consistent North-South alignment.',
    'scen_1_note':
        'Apparatus: 3D Bar Magnet (Red N / Blue S), Spool of Thread, Wooden Suspension Stand, Compass Rose overlay.',
    'scen_2_note':
        'Apparatus: Sewing Needle, Bar Magnet for stroking, Cork Disc, Glass Bowl filled with water, Compass Rose overlay.',
    'step_1_1':
        'DRAG the spool of thread to the center of the bar magnet lying on the table.',
    'step_1_2':
        'DRAG the tied magnet and HOOK it onto the wooden suspension stand.',
    'step_1_3':
        "TAP the hanging magnet (or press 'Spin Clockwise') to spin it clockwise. Watch it come to rest.",
    'step_1_4':
        "TAP the magnet again (or press 'Spin Counter-Clockwise') to spin it counter-clockwise. Watch it settle in the exact same direction.",
    'step_1_5':
        'REVIEW the observation table in the sidebar: both spins came to rest North - South. The conclusion then opens by itself.',
    'step_2_1':
        "DRAG the bar magnet along the sewing needle from its left end past its tip, in one direction only. LIFT your finger and bring the magnet back to the left end for the next stroke. Repeat until the count reaches 30 strokes (or press 'Auto-Stroke Helper (30x)').",
    'step_2_2':
        'DRAG the magnetized needle onto the cork disc to PUSH it horizontally through the center of the cork.',
    'step_2_3':
        'DRAG the cork-and-needle assembly and DROP it into the center of the glass water bowl.',
    'step_2_4':
        'OBSERVE the floating cork assembly slowly rotate and settle pointing North-South. Just watch; no action is needed.',
    'step_2_5':
        "TAP the floating cork (or press 'Push & Spin Cork') to spin it again. Verify it realigns pointing North-South!",
    'step_2_6':
        'REVIEW the observation table in the sidebar confirming your simple device works as a magnetic compass. The conclusion then opens by itself.',
    'out_1_1':
        'The thread wraps around the center of the magnet, and a knot is tied automatically.',
    'out_1_2':
        'The magnet is now suspended horizontally in the air from the stand, free to rotate.',
    'out_1_3':
        'The magnet spins clockwise and slowly settles aligned with the North-South markings below.',
    'out_1_4':
        'The magnet spins counter-clockwise and settles in the exact same North-South alignment.',
    'out_1_5':
        'Investigation verified. The magnet consistently demonstrates directive North-South alignment.',
    'out_2_1':
        'The sewing needle becomes magnetized after 30 unidirectional strokes.',
    'out_2_2':
        'The magnetized needle is securely pushed through the cork disc.',
    'out_2_3':
        "The cork-and-needle assembly floats steadily on the water's surface.",
    'out_2_4':
        'The floating cork disc slowly rotates and settles with the needle pointing North-South.',
    'out_2_5':
        'The cork disc spins and realigns itself to the exact same North-South direction!',
    'out_2_6':
        'Compass construction verified. The magnetized needle consistently acts as a compass.',
    'dir_ns': 'North - South',
    'trial_cw': 'Clockwise Spin',
    'trial_ccw': 'Counter-Clockwise Spin',
    'trial_float': 'Initial Floating',
    'trial_respin': 'After Re-spinning',
    'btn_spin_cw': 'Spin Clockwise',
    'btn_spin_ccw': 'Spin Counter-Clockwise',
    's1_hud_1': 'Drag the thread spool to the center of the bar magnet.',
    's1_hud_2': 'Drag the tied magnet to hook it onto the suspension stand.',
    's1_hud_3':
        'Spin the suspended magnet Clockwise and watch its resting direction.',
    's1_hud_4':
        'Now spin the magnet Counter-Clockwise and verify its alignment.',
    's1_hud_5':
        'Investigation complete! Verify the table; the conclusion opens next.',
    's2_hud_1':
        'Stroke the needle with the bar magnet 30 times (or click Auto-Stroke).',
    's2_hud_2':
        'Drag the magnetized needle through the center of the cork disc.',
    's2_hud_3': 'Drop the cork assembly into the bowl of water.',
    's2_hud_4':
        'Floating compass aligning... Watch the needle align North-South.',
    's2_hud_5': 'Tap the floating cork to spin it again and test realignment.',
    's2_hud_6':
        'Compass construction verified! Review the table; the conclusion opens next.',
    'btn_auto_stroke': 'Auto-Stroke Helper (30x)',
    'btn_spin_cork': 'Push & Spin Cork',
    'toast_tied': 'Thread wrapped and tied!',
    'toast_hooked': 'Magnet suspended freely!',
    'toast_settled_ns': 'Settled in North-South direction!',
    'toast_stroke_prog': 'Stroking needle... ({n}/30)',
    'toast_magnetized': 'Needle magnetized successfully!',
    'toast_pierced': 'Needle pushed through cork!',
    'toast_floating': 'Cork compass floating!',
    'toast_respun': 'Cork spinning!',
    'sum_s1_title': 'Directive Property Verified!',
    'sum_s1_desc':
        "A freely suspended bar magnet always comes to rest in the Earth's geographic North-South direction regardless of initial spin.",
    'sum_s2_title': 'Working Compass Constructed!',
    'sum_s2_desc':
        "The magnetized needle floating on cork acts as a reliable magnetic compass, consistently aligning with Earth's magnetic field.",
    'lbl_bar_magnet': 'Bar Magnet (N/S)',
    'lbl_spool': 'Spool of Thread',
    'lbl_stand': 'Suspension Stand',
    'lbl_needle': 'Sewing Needle',
    'lbl_cork': 'Cork Disc',
    'lbl_water_bowl': 'Bowl with Water',
    // Canvas text (added): compass rose letters and the magnet's poles.
    'rose_n': 'N',
    'rose_s': 'S',
    'rose_e': 'E',
    'rose_w': 'W',
    'pole_n': 'N',
    'pole_s': 'S',
  },
  'hi': {
    'app_title': 'दिशाएं ज्ञात करने के लिए चुंबक का उपयोग',
    'app_subtitle': 'कक्षा 6 • चुंबकों की खोज',
    'scen_1_opt': 'परिदृश्य 1: स्वतंत्र लटका छड़ चुंबक',
    'scen_2_opt': 'परिदृश्य 2: तैरता कॉर्क कंपास',
    'concept_exp': 'प्रक्रियात्मक चरण',
    'obs_table': 'अवलोकन तालिका',
    'tbl_trial': 'प्रयोग / परीक्षण',
    'tbl_rest_dir': 'रुकने की दिशा',
    'step_lbl': 'चरण',
    'task_instr': 'कार्य निर्देश',
    'exp_outcome': 'अपेक्षित परिणाम',
    's1_desc':
        'यह देखना और सत्यापित करना कि स्वतंत्र रूप से लटका हुआ छड़ चुंबक हमेशा उत्तर-दक्षिण दिशा में संरेखित होता है।',
    's2_desc':
        'पानी पर तैरती हुई चुंबकित सुई का उपयोग करके एक सरल चुंबकीय कंपास का निर्माण करना और उसकी दिशा जांचना।',
    'scen_1_note':
        'उपकरण: 3D छड़ चुंबक (लाल N / नीला S), धागे की रील, लकड़ी का स्टैंड, दिशा सूचक चक्र।',
    'scen_2_note':
        'उपकरण: सिलाई सुई, छड़ चुंबक, कॉर्क डिस्क, पानी से भरा कांच का कटोरा, दिशा सूचक चक्र।',
    'step_1_1': 'मेज पर रखे छड़ चुंबक के केंद्र तक धागे की रील को खींचें।',
    'step_1_2': 'बंधे हुए चुंबक को खींचें और लकड़ी के स्टैंड के हुक पर लटकाएं।',
    'step_1_3':
        "लटके हुए चुंबक पर टैप करें (या 'दक्षिणावर्त घुमाएं' दबाएं) ताकि वह दक्षिणावर्त घूमे। उसे रुकते हुए देखें।",
    'step_1_4':
        "चुंबक पर फिर से टैप करें (या 'वामावर्त घुमाएं' दबाएं) ताकि वह वामावर्त घूमे। देखें कि यह ठीक उसी दिशा में रुकता है।",
    'step_1_5':
        'साइडबार में अवलोकन तालिका की समीक्षा करें: दोनों बार चुंबक उत्तर - दक्षिण दिशा में रुका। इसके बाद निष्कर्ष अपने आप खुलेगा।',
    'step_2_1':
        "सिलाई सुई को चुंबकित करने के लिए छड़ चुंबक को सुई के बाएँ सिरे से उसकी नोक के पार तक, केवल एक ही दिशा में खींचें। अगली रगड़ के लिए उंगली उठाएँ और चुंबक को फिर से बाएँ सिरे पर लाएँ। 30 रगड़ पूरी होने तक दोहराएँ (या 'ऑटो-स्ट्रोक (30 बार)' दबाएं)।",
    'step_2_2':
        'चुंबकित सुई को खींचकर कॉर्क डिस्क पर लाएँ ताकि वह कॉर्क के केंद्र के बीच से क्षैतिज रूप से पार हो जाए।',
    'step_2_3':
        'कॉर्क और सुई के संयोजन को खींचें और कांच के पानी के कटोरे के बीच में डालें।',
    'step_2_4':
        'तैरते हुए कॉर्क को धीरे-धीरे घूमते और उत्तर-दक्षिण दिशा में रुकते हुए देखें। केवल देखें, कुछ करने की आवश्यकता नहीं है।',
    'step_2_5':
        "तैरते हुए कॉर्क पर टैप करें (या 'कॉर्क घुमाएं' दबाएं) ताकि वह फिर से घूमे। देखें कि यह फिर से उत्तर-दक्षिण संरेखित होता है!",
    'step_2_6':
        'साइडबार में अवलोकन तालिका की समीक्षा करें और पुष्टि करें कि आपका सरल उपकरण चुंबकीय कंपास की तरह काम करता है। इसके बाद निष्कर्ष अपने आप खुलेगा।',
    'out_1_1':
        'धागा चुंबक के केंद्र के चारों ओर लिपट जाता है और स्वतः एक गांठ बंध जाती है।',
    'out_1_2':
        'चुंबक अब स्टैंड से हवा में क्षैतिज रूप से लटक गया है और स्वतंत्र रूप से घूमने में सक्षम है।',
    'out_1_3':
        'चुंबक दक्षिणावर्त घूमता है और धीरे-धीरे नीचे बने उत्तर-दक्षिण चिह्नों की सीध में आकर रुकता है।',
    'out_1_4':
        'चुंबक वामावर्त घूमता है और ठीक उसी उत्तर-दक्षिण दिशा में आकर रुकता है।',
    'out_1_5':
        'जांच सत्यापित हुई। चुंबक लगातार अपने दिशात्मक उत्तर-दक्षिण गुण को दर्शाता है।',
    'out_2_1': '30 एकतरफा घर्षणों के बाद सिलाई सुई चुंबकित हो जाती है।',
    'out_2_2':
        'चुंबकित सुई कॉर्क डिस्क के केंद्र के बीच से मजबूती से फिट हो जाती है।',
    'out_2_3': 'कॉर्क और सुई का संयोजन पानी की सतह पर तैरता है।',
    'out_2_4':
        'तैरता हुआ कॉर्क धीरे-धीरे घूमता है और सुई उत्तर-दक्षिण दिशा में रुकती है।',
    'out_2_5':
        'कॉर्क फिर से घूमता है और ठीक उसी उत्तर-दक्षिण दिशा में संरेखित होता है!',
    'out_2_6':
        'कंपास निर्माण सत्यापित हुआ। चुंबकित सुई एक विश्वसनीय कंपास की तरह कार्य करती है।',
    'dir_ns': 'उत्तर - दक्षिण',
    'trial_cw': 'दक्षिणावर्त घूर्णन',
    'trial_ccw': 'वामावर्त घूर्णन',
    'trial_float': 'प्रारंभिक तैराव',
    'trial_respin': 'पुनः घुमाने के बाद',
    'btn_spin_cw': 'दक्षिणावर्त घुमाएं',
    'btn_spin_ccw': 'वामावर्त घुमाएं',
    's1_hud_1': 'धागे की रील को छड़ चुंबक के केंद्र में खींचें।',
    's1_hud_2': 'बंधे हुए चुंबक को सस्पेंशन स्टैंड पर लटकाने के लिए खींचें।',
    's1_hud_3':
        'लटके हुए चुंबक को दक्षिणावर्त घुमाएं और उसके रुकने की दिशा देखें।',
    's1_hud_4': 'अब चुंबक को वामावर्त घुमाएं और दिशा संरेखण सत्यापित करें।',
    's1_hud_5': 'जांच पूरी हुई! तालिका जांचें; इसके बाद निष्कर्ष खुलेगा।',
    's2_hud_1': 'छड़ चुंबक से सुई को 30 बार रगड़ें (या ऑटो-स्ट्रोक बटन दबाएं)।',
    's2_hud_2': 'चुंबकित सुई को कॉर्क डिस्क के बीच से पार करें।',
    's2_hud_3': 'कॉर्क संयोजन को पानी के कटोरे में डालें।',
    's2_hud_4':
        'तैरता कंपास रुक रहा है... सुई के उत्तर-दक्षिण रुकने की प्रतीक्षा करें।',
    's2_hud_5': 'पुनः जांचने के लिए तैरते हुए कॉर्क पर टैप करके उसे घुमाएं।',
    's2_hud_6':
        'कंपास का सफल परीक्षण हुआ! तालिका देखें; इसके बाद निष्कर्ष खुलेगा।',
    'btn_auto_stroke': 'ऑटो-स्ट्रोक (30 बार)',
    'btn_spin_cork': 'कॉर्क घुमाएं',
    'toast_tied': 'धागा चुंबक से बंध गया!',
    'toast_hooked': 'चुंबक स्वतंत्र रूप से लटक गया!',
    'toast_settled_ns': 'उत्तर-दक्षिण दिशा में रुक गया!',
    'toast_stroke_prog': 'सुई रगड़ी जा रही है... ({n}/30)',
    'toast_magnetized': 'सुई सफलतापूर्वक चुंबकित हुई!',
    'toast_pierced': 'सुई कॉर्क में फिट हो गई!',
    'toast_floating': 'कॉर्क कंपास तैर रहा है!',
    'toast_respun': 'कॉर्क घूम रहा है!',
    'sum_s1_title': 'दिशात्मक गुण सत्यापित!',
    'sum_s1_desc':
        'स्वतंत्र रूप से लटका हुआ छड़ चुंबक हमेशा पृथ्वी की भौगोलिक उत्तर-दक्षिण दिशा में रुकता है।',
    'sum_s2_title': 'कार्यशील कंपास निर्मित!',
    'sum_s2_desc':
        'कॉर्क पर तैरती हुई चुंबकित सुई विश्वसनीय कंपास की तरह कार्य करती है, जो हमेशा उत्तर-दक्षिण दिशा दर्शाती है।',
    'lbl_bar_magnet': 'छड़ चुंबक (N/S)',
    'lbl_spool': 'धागे की रील',
    'lbl_stand': 'सस्पेंशन स्टैंड',
    'lbl_needle': 'सिलाई सुई',
    'lbl_cork': 'कॉर्क डिस्क',
    'lbl_water_bowl': 'पानी का कटोरा',
    // Compass rose: उत्तर, दक्षिण, पूर्व, पश्चिम. The magnet keeps the pole
    // symbols N / S, as the HTML's Hindi label "छड़ चुंबक (N/S)" does.
    'rose_n': 'उ',
    'rose_s': 'द',
    'rose_e': 'पू',
    'rose_w': 'प',
    'pole_n': 'N',
    'pole_s': 'S',
  },
};

/// Steps per scenario (HTML `numSteps`).
const List<int> _stepCounts = [5, 6];

/// Scenarios and steps for [lang]: action = the step instruction, observation
/// = the HTML "Expected Outcome". The HTML has no per-step concept text.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
            LabStep(
              concept: '',
              action: t('step_${n}_$i'),
              observation: t('out_${n}_$i'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the stage (16:9-ish landscape canvas).
const Size _design = Size(1000, 560);

// HTML camera per scenario (`resetCamera()`), PerspectiveCamera fov 45.
const _V _eyeS1 = _V(0, 12, 18);
const _V _targetS1 = _V(0, 3, 0);
const _V _eyeS2 = _V(0, 10, 16);
const _V _targetS2 = _V(0, 1.5, 0);

/// `resetCamera()` tween: 800 ms Cubic.Out.
const double _cameraTweenS = 0.8;

/// HTML `intersectPlane` y = 0.4: objects slide on the table at their own
/// height (`position.y = max(0.4, y)`).
const double _dragPlaneY = 0.4;

/// Dragged objects stay on the 26 × 18 table top (the HTML lets them fly
/// off it towards the horizon).
const double _tableHalfX = 13;
const double _tableHalfZ = 9;
const double _tableMargin = 1;

/// Lying objects point their N pole / needle tip along −x (HTML rotation 0).
const double _yawLying = -math.pi / 2;

// Scenario 1 (HTML setupScenario1 / checkInteractions).
const _V _magnetHomeS1 = _V(-6, 0.4, 3);
const _V _spoolHome = _V(6, 0.6, 3);
const _V _spoolAside = _V(-8, 0.6, -4); // "move spool aside"
const _V _hookPos = _V(0, 9.0, 1.5);
const _V _hangPos = _V(0, 6.5, 1.5);
const _V _roseS1 = _V(0, 0.02, 1.5);
const double _tieReach = 3.2;

/// The tied magnet hooks when it is brought to the stand: within 2.5 units
/// of the stand's x, from the back of the table to 2 units in front of the
/// hook (on screen: over the stand's base, pole or hook). The HTML test
/// (8 units from the base, or |x| < 5) passed on the first move in any
/// direction, since the magnet starts 6.95 units from the base.
const double _hookReachX = 2.5;
const double _hookReachFront = 2.0;

/// `magnet.rotation.set(0, Math.PI * 0.4, 0)` when hooked.
const double _hangYaw = 0.4 * math.pi;

/// Compass rose fades to 0.9 over 800 ms once the magnet hangs.
const double _roseFadeS = 0.8;
const double _roseOpacityS1 = 0.9;
const double _roseOpacityS2 = 0.85;

/// Hook tween: 500 ms Back.Out.
const double _hookTweenS = 0.5;

// Scenario 2 (HTML setupScenario2 / checkInteractions).
const _V _bowlPos = _V(0, 0, -1.5);
const _V _roseS2 = _V(0, 0.02, -1.5);
const _V _needleHome = _V(0, 0.15, 4);
const _V _magnetHomeS2 = _V(-6, 0.4, 4);
const _V _magnetAway = _V(-9, 0.4, -4); // "move magnet away"
const _V _corkHome = _V(6, 0.4, 4);
const _V _floatPos = _V(0, 1.8, -1.5); // bowlCenter
const double _pierceReach = 3.2;
const double _floatReach = 3.5;
const double _waterLevel = 1.8;

/// Afloat, the cork / needle chips go 2.2 units up (the HTML put them on
/// top of the bowl's chip).
const _V _floatLabelLift = _V(0, 2.2, 0);

/// `corkAssembly.rotation.y = 2.4` on landing ("random start angle").
const double _dropYaw = -2.4;

/// Landing tween: 600 ms Bounce.Out.
const double _dropTweenS = 0.6;

/// Needle pulse (`emissive` #38bdf8) after each stroke: 150 ms.
const double _pulseS = 0.15;

// Stroking (textbook Activity 4.4): one stroke is one pass of the magnet
// along the needle in one direction (+x), from left of its eye end
// (centre x < needle x - 1.9) to past its tip (> needle x + 1.9), while it
// stays within 2.2 (z) / 2.0 (y) of the needle. The next stroke counts only
// after the magnet is lifted (finger lifted, or moved off the needle).
// Moving back along the needle by more than 0.5 cancels the pass. 30
// strokes magnetize the needle.
const int _strokesNeeded = 30;
const double _strokeBandZ = 2.2;
const double _strokeBandY = 2.0;
const double _strokeEndX = 1.9;
const double _strokeBackTolerance = 0.5;

/// `setTimeout(alignCorkCompass, 1200)` after landing.
const Duration _alignDelay = Duration(milliseconds: 1200);

/// Time to read the table before the conclusion opens (replaces the HTML
/// "Validate Model" button).
const Duration _reviewDelay = Duration(milliseconds: 2500);

/// Touch slop 8 px (pan slop 16 px) for picking objects up.
const DeviceGestureSettings _dragGestureSettings = DeviceGestureSettings(
  touchSlop: 8,
);

/// Objects that can be dragged (HTML `interactables`).
enum _Obj { magnet, spool, needle, assembly }

/// Observation-table trials (rows store keys so they re-translate).
enum _Trial {
  cw('trial_cw'),
  ccw('trial_ccw'),
  float('trial_float'),
  respin('trial_respin');

  const _Trial(this.key);
  final String key;
}

/// A running rotation tween: the magnet's spins (S1) or the cork's
/// alignment and re-spin (S2).
enum _Spin {
  /// `triggerSpinCW()`: CatmullRom [θ, 2.2π, 1.8π, 2π], 3000 ms Cubic.Out.
  cw(3.0),

  /// `triggerSpinCCW()`: CatmullRom [θ, −2.2π, −1.8π, −2π], 3000 ms.
  ccw(3.0),

  /// `alignCorkCompass()`: θ → 0, 2800 ms Quadratic.Out.
  align(2.8),

  /// `triggerSpinCork()`: two full turns, 3200 ms Cubic.Out.
  respin(3.2);

  const _Spin(this.seconds);
  final double seconds;

  bool get isMagnet => this == cw || this == ccw;

  /// Yaw at progress [t] (0..1) of a tween that started at [from].
  double yaw(double from, double t) => switch (this) {
    _Spin.cw => _catmullRom(
      from,
      2.2 * math.pi,
      1.8 * math.pi,
      2 * math.pi,
      _cubicOut(t),
    ),
    _Spin.ccw => _catmullRom(
      from,
      -2.2 * math.pi,
      -1.8 * math.pi,
      -2 * math.pi,
      _cubicOut(t),
    ),
    _Spin.align => from + (0 - from) * _quadOut(t),
    // HTML rotation.y 0 → 4π; the cork's bearing turns the same way.
    _Spin.respin => from + (-4 * math.pi - from) * _cubicOut(t),
  };
}

// tween.js easing functions (exact, not Flutter's bezier approximations).
double _cubicOut(double k) => 1 - math.pow(1 - k, 3).toDouble();
double _quadOut(double k) => k * (2 - k);
double _backOut(double k) {
  const s = 1.70158;
  final t = k - 1;
  return t * t * ((s + 1) * t + s) + 1;
}

double _bounceOut(double k) {
  if (k < 1 / 2.75) return 7.5625 * k * k;
  if (k < 2 / 2.75) {
    final t = k - 1.5 / 2.75;
    return 7.5625 * t * t + 0.75;
  }
  if (k < 2.5 / 2.75) {
    final t = k - 2.25 / 2.75;
    return 7.5625 * t * t + 0.9375;
  }
  final t = k - 2.625 / 2.75;
  return 7.5625 * t * t + 0.984375;
}

/// tween.js `Interpolation.CatmullRom` over [v0, v1, v2, v3] (open path)
/// at eased progress [k] in 0..1.
double _catmullRom(double v0, double v1, double v2, double v3, double k) {
  final v = [v0, v1, v2, v3];
  const m = 3;
  final f = m * k;
  final i = f.floor().clamp(0, m);
  double fn(double p0, double p1, double p2, double p3, double t) {
    final a = (p2 - p0) * 0.5;
    final b = (p3 - p1) * 0.5;
    final t2 = t * t;
    final t3 = t * t2;
    return (2 * p1 - 2 * p2 + a + b) * t3 +
        (-3 * p1 + 3 * p2 - 2 * a - b) * t2 +
        a * t +
        p1;
  }

  return fn(
    v[i == 0 ? 0 : i - 1],
    v[i],
    v[math.min(m, i + 1)],
    v[math.min(m, i + 2)],
    f - i,
  );
}

/// Compass bearing → horizontal unit vector: 0 = North (−z, away from the
/// camera, where the rose's N is), π/2 = East (+x). Positive = clockwise
/// seen from above.
_V _dir(double bearing) => _V(math.sin(bearing), 0, -math.cos(bearing));

/// The horizontal axis 90° clockwise of [_dir] (completes a right-handed
/// frame with up).
_V _side(double bearing) => _V(math.cos(bearing), 0, math.sin(bearing));

/// Everything the painter draws, mutated by the page and its ticker.
class _Scene {
  _Scene() {
    load(0, tween: false);
  }

  double time = 0;
  int scenario = 0;
  int step = 1;

  // Camera (position + OrbitControls target) and its tween.
  _V eye = _eyeS1;
  _V target = _targetS1;
  _V _eyeFrom = _eyeS1;
  _V _eyeTo = _eyeS1;
  _V _targetFrom = _targetS1;
  _V _targetTo = _targetS1;
  double _cameraStart = -1;

  /// Observation table rows.
  final List<_Trial> rows = [];

  /// HTML `isSpinning` (a spin or the cork's alignment is running).
  bool spinning = false;
  _Spin? spin;
  double spinFrom = 0;
  double spinStart = -1;

  _Obj? dragging;

  // The bar magnet (both scenarios). Yaw = bearing of its N pole.
  _V magnetPos = _magnetHomeS1;
  double magnetYaw = _yawLying;

  // Scenario 1.
  bool tied = false;
  bool hooked = false;
  _V spoolPos = _spoolHome;
  _V _hookFrom = _magnetHomeS1;
  double hookStart = -1;
  double roseOpacity = 0;
  double roseStart = -1;

  // Scenario 2. Needle yaw = bearing of its tip.
  int strokes = 0;

  /// The magnet has been lifted since the last stroke (a new one may start).
  bool strokeArmed = true;

  /// A stroke is under way; the farthest x it reached.
  bool strokeOn = false;
  double strokeMaxX = 0;
  bool magnetized = false;
  bool pierced = false;
  bool floating = false;
  _V needlePos = _needleHome;
  double needleYaw = _yawLying;
  double needlePulse = -10;
  _V corkPos = _corkHome;
  _V assemblyPos = _corkHome;
  double assemblyYaw = _yawLying;
  _V _dropFrom = _corkHome;
  double dropStart = -1;

  /// HTML `changeScenario(id)`: fresh bench for [index] at step 1; the
  /// camera glides to the scenario's view (`resetCamera()`).
  void load(int index, {bool tween = true}) {
    scenario = index;
    step = 1;
    rows.clear();
    spinning = false;
    spin = null;
    spinStart = -1;
    dragging = null;
    tied = hooked = false;
    hookStart = -1;
    roseStart = -1;
    strokes = 0;
    strokeArmed = true;
    strokeOn = false;
    magnetized = pierced = floating = false;
    needlePulse = -10;
    dropStart = -1;
    magnetYaw = needleYaw = assemblyYaw = _yawLying;
    spoolPos = _spoolHome;
    needlePos = _needleHome;
    corkPos = assemblyPos = _corkHome;
    if (index == 0) {
      magnetPos = _magnetHomeS1;
      roseOpacity = 0;
    } else {
      magnetPos = _magnetHomeS2;
      roseOpacity = _roseOpacityS2;
    }
    final eyeTo = index == 0 ? _eyeS1 : _eyeS2;
    final targetTo = index == 0 ? _targetS1 : _targetS2;
    if (tween) {
      _eyeFrom = eye;
      _targetFrom = target;
      _eyeTo = eyeTo;
      _targetTo = targetTo;
      _cameraStart = time;
    } else {
      eye = _eyeFrom = _eyeTo = eyeTo;
      target = _targetFrom = _targetTo = targetTo;
      _cameraStart = -1;
    }
  }

  double _progress(double start, double seconds) =>
      ((time - start) / seconds).clamp(0.0, 1.0);

  /// Advances the camera, hook, rose and landing tweens. True while any
  /// of them is still running.
  bool advanceTweens() {
    var running = false;
    if (_cameraStart >= 0) {
      final k = _cubicOut(_progress(_cameraStart, _cameraTweenS));
      eye = _V.lerp(_eyeFrom, _eyeTo, k);
      target = _V.lerp(_targetFrom, _targetTo, k);
      if (k >= 1) _cameraStart = -1;
      running = true;
    }
    if (hookStart >= 0) {
      final t = _progress(hookStart, _hookTweenS);
      magnetPos = _V.lerp(_hookFrom, _hangPos, _backOut(t));
      if (t >= 1) hookStart = -1;
      running = true;
    }
    if (roseStart >= 0) {
      final t = _progress(roseStart, _roseFadeS);
      roseOpacity = _roseOpacityS1 * t;
      if (t >= 1) roseStart = -1;
      running = true;
    }
    if (dropStart >= 0) {
      final t = _progress(dropStart, _dropTweenS);
      assemblyPos = _V.lerp(_dropFrom, _floatPos, _bounceOut(t));
      if (t >= 1) dropStart = -1;
      running = true;
    }
    if (time - needlePulse < _pulseS + 0.05) running = true;
    return running;
  }

  void startHook(_V from) {
    _hookFrom = from;
    hookStart = time;
    magnetYaw = _hangYaw;
    roseStart = time;
  }

  void startDrop(_V from) {
    _dropFrom = from;
    dropStart = time;
    assemblyYaw = _dropYaw;
  }

  void startSpin(_Spin kind) {
    spinning = true;
    spin = kind;
    spinFrom = kind.isMagnet ? magnetYaw : assemblyYaw;
    spinStart = time;
  }

  /// Runs the active spin; returns it once it has finished.
  _Spin? advanceSpin() {
    final s = spin;
    if (s == null) return null;
    final t = _progress(spinStart, s.seconds);
    final yaw = s.yaw(spinFrom, t);
    if (s.isMagnet) {
      magnetYaw = yaw;
    } else {
      assemblyYaw = yaw;
    }
    if (t < 1) return null;
    spin = null;
    spinning = false;
    // HTML onComplete: rotation.y = 0 (exact North–South).
    if (s.isMagnet) {
      magnetYaw = 0;
    } else {
      assemblyYaw = 0;
    }
    return s;
  }

  /// Draggable objects right now (HTML `interactables`). The hooked magnet
  /// and the floating cork stay put (the HTML let them be dragged off the
  /// hook / out of the water while spinning).
  List<_Obj> get draggables => scenario == 0
      ? [if (!hooked) _Obj.magnet, _Obj.spool]
      : [
          if (!magnetized) _Obj.magnet,
          if (magnetized && !pierced) _Obj.needle,
          if (pierced && !floating) _Obj.assembly,
        ];

  _V posOf(_Obj obj) => switch (obj) {
    _Obj.magnet => magnetPos,
    _Obj.spool => spoolPos,
    _Obj.needle => needlePos,
    _Obj.assembly => assemblyPos,
  };

  void setPos(_Obj obj, _V p) {
    switch (obj) {
      case _Obj.magnet:
        magnetPos = p;
      case _Obj.spool:
        spoolPos = p;
      case _Obj.needle:
        needlePos = p;
      case _Obj.assembly:
        assemblyPos = p;
    }
  }

  /// Screen outline of an object's pick volume (the HTML glow meshes, which
  /// the raycaster also hits).
  List<Offset> pickHull(_Proj proj, _Obj obj) => switch (obj) {
    _Obj.magnet => _boxHull(proj, magnetPos, magnetYaw, 2.45, 0.5, 0.7),
    _Obj.spool => _boxHull(proj, spoolPos, 0, 0.9, 0.7, 0.9),
    _Obj.needle => _boxHull(proj, needlePos, needleYaw, 2.5, 0.2, 0.2),
    _Obj.assembly => _hull([
      ..._boxCorners(proj, assemblyPos, assemblyYaw, 1.7, 0.45, 1.7),
      ..._boxCorners(
        proj,
        assemblyPos + const _V(0, 0.4, 0),
        assemblyYaw,
        2.5,
        0.2,
        0.2,
      ),
    ]),
  };

  /// The hanging magnet's tap area (HTML raycast on `sceneObjects.magnet`).
  List<Offset> magnetHull(_Proj proj) => pickHull(proj, _Obj.magnet);

  /// The floating cork's tap area (HTML raycast on `corkAssembly`).
  List<Offset> assemblyHull(_Proj proj) => pickHull(proj, _Obj.assembly);
}

/// Projected corners of a box of half sizes [hx] (along [_dir] of [yaw]),
/// [hy] (up) and [hz] centred at [c].
List<Offset> _boxCorners(
  _Proj proj,
  _V c,
  double yaw,
  double hx,
  double hy,
  double hz,
) {
  final ex = _dir(yaw) * hx;
  final ey = const _V(0, 1, 0) * hy;
  final ez = _side(yaw) * hz;
  return [
    for (final sx in const [-1.0, 1.0])
      for (final sy in const [-1.0, 1.0])
        for (final sz in const [-1.0, 1.0])
          proj.p(c + ex * sx + ey * sy + ez * sz),
  ];
}

List<Offset> _boxHull(
  _Proj proj,
  _V c,
  double yaw,
  double hx,
  double hy,
  double hz,
) => _hull(_boxCorners(proj, c, yaw, hx, hy, hz));

/// Distance from [p] to the convex polygon [hull] (0 inside).
double _hullDistance(List<Offset> hull, Offset p) {
  if (hull.isEmpty) return double.infinity;
  if (hull.length < 3) return (hull.first - p).distance;
  var inside = true;
  var sign = 0;
  var best = double.infinity;
  for (var i = 0; i < hull.length; i++) {
    final a = hull[i];
    final b = hull[(i + 1) % hull.length];
    final cross = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
    final sgn = cross > 0 ? 1 : (cross < 0 ? -1 : 0);
    if (sgn != 0) {
      if (sign == 0) {
        sign = sgn;
      } else if (sgn != sign) {
        inside = false;
      }
    }
    best = math.min(best, _segmentDistance(p, a, b));
  }
  return inside ? 0 : best;
}

double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

/// Pan recognizer that only claims pointers for which [canGrab] says yes
/// (an object the learner may drag is under the finger), so other drags
/// still reach the zoomable canvas. [canGrab] also handles the HTML
/// pointer-down taps (spin the hanging magnet / floating cork).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch4A3UsingMagnetsToFindDirectionsPageState
    extends State<Ch4A3UsingMagnetsToFindDirectionsPage>
    with SingleTickerProviderStateMixin {
  /// HTML `cameraLocked = true`: pinch / drag do not move the canvas.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final _TextCache _text = _TextCache();
  late final Ticker _ticker;

  /// Scenario / step data per language, built once from [_i18n].
  final Map<LabLang, List<LabScenarioData>> _scenarios = {
    for (final lang in LabLang.values) lang: _buildScenarios(lang),
  };

  /// Object under the finger at pointer-down (validated, not yet dragging).
  _Obj? _grab;

  /// Grab point minus object position on the drag plane (HTML `offset`).
  _V _dragOffset = _V.zero;

  /// Stage scale (screen px per design px), for touch padding and labels.
  double _fit = 1;

  /// Procedural-step cards opened or closed by hand (HTML accordion).
  final Set<int> _toggledSteps = {};

  /// The scene changed outside a running tween: repaint on the next tick.
  bool _dirty = true;

  /// Key / values of the lab's last toast and the language it was shown
  /// in: a language switch re-shows it translated (the shell keeps a
  /// toast's text as shown).
  String? _toastKey;
  String _toastText = '';
  Map<String, Object> _toastArgs = const {};
  LabLang _toastLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];
  _Proj get _proj => _Proj(_scene.eye, _scene.target);

  /// Extra touch margin around objects (≈ 22 screen px).
  double get _touchPad => (22 / _fit).clamp(12.0, 48.0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_retranslateToast);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _lab.removeListener(_retranslateToast);
    _ticker.dispose();
    _frame.dispose();
    _text.dispose();
    _lab.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- animation

  /// HTML `animate()` + `TWEEN.update()`. Repaints only the canvas, and only
  /// while something moves.
  void _onTick(Duration elapsed) {
    final s = _scene..time = elapsed.inMicroseconds / 1e6;
    var moving = s.advanceTweens() || s.dragging != null || s.spin != null;
    final finished = s.advanceSpin();
    if (finished != null) {
      moving = true;
      _onSpinDone(finished);
    }
    if (moving || _dirty) {
      _dirty = false;
      _frame.value++;
    }
  }

  void _repaint() => _dirty = true;

  /// Shows the toast [key] (with `{name}` [args]) in the current language.
  void _toast(
    String key, {
    Map<String, Object> args = const {},
    bool sound = true,
  }) {
    _toastKey = key;
    _toastArgs = args;
    _toastLang = _lab.lang;
    _toastText = labFormat(_t(key), args);
    _lab.showToast(_toastText, sound: sound);
  }

  /// After a language switch, the toast still on screen is shown again in
  /// the new language (silently, after the current frame).
  void _retranslateToast() {
    final key = _toastKey;
    if (key == null || _lab.lang == _toastLang) return;
    _toastLang = _lab.lang;
    final shown = _lab.toast;
    if (shown == null || shown.text != _toastText) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _toast(key, args: _toastArgs, sound: false);
    });
  }

  /// Every state change also redraws the canvas: the painter reads the
  /// mutable scene, so `shouldRepaint` cannot see it change.
  @override
  void setState(VoidCallback fn) {
    _dirty = true;
    super.setState(fn);
  }

  void _goToStep(int step) {
    _scene.step = step;
    _toggledSteps.clear();
  }

  /// Tween `onComplete` handlers of the spins and the cork's alignment.
  void _onSpinDone(_Spin kind) {
    if (!mounted) return;
    final s = _scene;
    final row = switch (kind) {
      _Spin.cw => _Trial.cw,
      _Spin.ccw => _Trial.ccw,
      _Spin.align => _Trial.float,
      _Spin.respin => _Trial.respin,
    };
    setState(() {
      s.rows.add(row);
      _goToStep(switch (kind) {
        _Spin.cw => 4,
        _Spin.ccw => 5,
        _Spin.align => 5,
        _Spin.respin => 6,
      });
    });
    _toast('toast_settled_ns');
    if (kind == _Spin.ccw || kind == _Spin.respin) _showConclusion();
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` (also Restart Lab and Reset Lab).
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _toggledSteps.clear();
    });
    _lab.resetView(sound: false);
    _repaint();
  }

  /// HTML `validateInvestigation()` popup, opened automatically once the
  /// last step (review the table) is reached.
  void _showConclusion() {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: _reviewDelay,
      title: () => _t('sum_s${sc + 1}_title'),
      heading: () => _lab.t('sci_conclusion'),
      body: () => _t('sum_s${sc + 1}_desc'),
      extra: () => _ObservationTable(
        rows: List.of(_scene.rows),
        t: _t,
        fontScale: _lab.fontScale.clamp(0.9, 1.4),
      ),
    );
  }

  /// HTML `triggerSpinCW()` / `triggerSpinCCW()`.
  void _spinMagnet({required bool clockwise}) {
    final s = _scene;
    if (s.spinning || !s.hooked || s.scenario != 0) return;
    if (s.step != (clockwise ? 3 : 4)) return;
    setState(() => s.startSpin(clockwise ? _Spin.cw : _Spin.ccw));
  }

  /// HTML `autoStrokeNeedle()`.
  void _autoStroke() {
    final s = _scene;
    if (s.scenario != 1 || s.magnetized) return;
    _magnetize();
  }

  /// 30 strokes reached: the magnet is put away and the needle can be
  /// picked up.
  void _magnetize() {
    final s = _scene;
    setState(() {
      s
        ..strokes = _strokesNeeded
        ..magnetized = true
        ..magnetPos = _magnetAway
        ..dragging = null;
      _goToStep(2);
    });
    _toast('toast_magnetized');
    _repaint();
  }

  /// HTML `alignCorkCompass()`, 1.2 s after landing.
  void _alignCork() {
    final s = _scene;
    if (!s.floating || s.spin != null) return;
    s.startSpin(_Spin.align);
    _repaint();
  }

  /// HTML `triggerSpinCork()`.
  void _spinCork() {
    final s = _scene;
    if (!s.floating || s.spinning || s.step != 5) return;
    setState(() => s.startSpin(_Spin.respin));
    _toast('toast_respun', sound: false);
  }

  /// HTML `onPointerDown`: a tap on the hanging magnet (steps 3 / 4) or the
  /// floating cork (step 5) spins it; otherwise a draggable object under the
  /// finger is picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (s.dragging != null) return false;
    final at = event.localPosition;
    final proj = _proj;
    if (s.scenario == 0 && s.hooked && !s.spinning) {
      if (_hullDistance(s.magnetHull(proj), at) <= _touchPad) {
        if (s.step == 3 || s.step == 4) {
          _Sound.click.play();
          _spinMagnet(clockwise: s.step == 3);
        }
        return false;
      }
    } else if (s.scenario == 1 && s.floating && !s.spinning && s.step == 5) {
      if (_hullDistance(s.assemblyHull(proj), at) <= _touchPad) {
        _Sound.click.play();
        _spinCork();
        return false;
      }
    }
    _grab = _pick(at, proj);
    return _grab != null;
  }

  /// The draggable object under [at]: the closest outline wins, then the one
  /// nearest the camera (HTML `intersects[0]`).
  _Obj? _pick(Offset at, _Proj proj) {
    final s = _scene;
    _Obj? best;
    var bestDistance = double.infinity;
    var bestDepth = double.infinity;
    for (final obj in s.draggables) {
      final d = _hullDistance(s.pickHull(proj, obj), at);
      if (d > _touchPad) continue;
      final depth = proj.depth(s.posOf(obj));
      if (d < bestDistance - 1 ||
          ((d - bestDistance).abs() <= 1 && depth < bestDepth)) {
        best = obj;
        bestDistance = d;
        bestDepth = depth;
      }
    }
    return best;
  }

  void _dragStart(DragStartDetails d) {
    final obj = _grab;
    final s = _scene;
    if (obj == null || s.dragging != null) return;
    final hit = _proj.onPlane(d.localPosition, _dragPlaneY);
    if (hit == null) return;
    _Sound.pickup.play();
    _dragOffset = hit - s.posOf(obj);
    // A new drag means the finger was lifted: the next stroke may start.
    s
      ..dragging = obj
      ..strokeArmed = true
      ..strokeOn = false;
    _repaint();
  }

  /// HTML `onPointerMove`: the object follows the finger on the drag plane,
  /// then `checkInteractions()`.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.dragging;
    if (obj == null) return;
    final hit = _proj.onPlane(d.localPosition, _dragPlaneY);
    if (hit == null) return;
    final from = s.posOf(obj);
    final raw = hit - _dragOffset;
    final to = _V(
      raw.x.clamp(-_tableHalfX + _tableMargin, _tableHalfX - _tableMargin),
      math.max(_dragPlaneY, raw.y),
      raw.z.clamp(-_tableHalfZ + _tableMargin, _tableHalfZ - _tableMargin),
    );
    s.setPos(obj, to);
    _checkInteractions(obj, from, to);
  }

  void _dragEnd() {
    _grab = null;
    final s = _scene;
    if (s.dragging == null) return;
    // Put down where released (the HTML leaves it there too).
    s.dragging = null;
    _Sound.drop.play();
    _repaint();
  }

  /// HTML `checkInteractions()` for the dragged [obj], moved [from] → [to].
  void _checkInteractions(_Obj obj, _V from, _V to) {
    final s = _scene;
    if (s.scenario == 0) {
      if (s.step == 1 &&
          obj == _Obj.spool &&
          (to - s.magnetPos).length < _tieReach) {
        // Tie the thread; the spool is moved aside.
        setState(() {
          s
            ..tied = true
            ..spoolPos = _spoolAside
            ..dragging = null;
          _goToStep(2);
        });
        _toast('toast_tied');
      } else if (s.step == 2 &&
          obj == _Obj.magnet &&
          (to.x - _hookPos.x).abs() < _hookReachX &&
          to.z < _hookPos.z + _hookReachFront) {
        // Hook the magnet: it springs up under the hook, free to rotate.
        setState(() {
          s
            ..hooked = true
            ..dragging = null
            ..startHook(to);
          _goToStep(3);
        });
        _toast('toast_hooked');
      }
      return;
    }

    if (s.step == 1 && obj == _Obj.magnet) {
      _stroke(to);
    } else if (s.step == 2 &&
        obj == _Obj.needle &&
        (to - s.corkPos).length < _pierceReach) {
      // Needle through the cork: one assembly at the cork's place.
      setState(() {
        s
          ..pierced = true
          ..assemblyPos = s.corkPos
          ..assemblyYaw = s.needleYaw
          ..dragging = null;
        _goToStep(3);
      });
      _toast('toast_pierced');
    } else if (s.step == 3 &&
        obj == _Obj.assembly &&
        (to - _floatPos).length < _floatReach) {
      // Into the water; it settles North–South after 1.2 s.
      setState(() {
        s
          ..floating = true
          ..dragging = null
          ..startDrop(to);
        _goToStep(4);
      });
      _toast('toast_floating');
      _lab.after(_alignDelay, () {
        if (!mounted || _scene.scenario != 1) return;
        _alignCork();
      });
    }
  }

  /// Stroke counter. The HTML added 2 strokes per small forward move, so one
  /// swipe counted as 30; here a stroke is a whole pass along the needle in
  /// one direction, and the magnet must be lifted before the next one.
  void _stroke(_V to) {
    final s = _scene;
    final inBand =
        (to.z - s.needlePos.z).abs() < _strokeBandZ &&
        (to.y - s.needlePos.y).abs() < _strokeBandY;
    if (!inBand) {
      // Moved off the needle: counts as lifting the magnet.
      s
        ..strokeOn = false
        ..strokeArmed = true;
      return;
    }
    if (!s.strokeOn) {
      if (s.strokeArmed && to.x < s.needlePos.x - _strokeEndX) {
        s
          ..strokeOn = true
          ..strokeArmed = false
          ..strokeMaxX = to.x;
      }
      return;
    }
    if (to.x < s.strokeMaxX - _strokeBackTolerance) {
      // Rubbed back along the needle: this pass does not count.
      s.strokeOn = false;
      return;
    }
    s.strokeMaxX = math.max(s.strokeMaxX, to.x);
    if (to.x <= s.needlePos.x + _strokeEndX) return;
    s
      ..strokeOn = false
      ..strokes += 1
      ..needlePulse = s.time;
    if (s.strokes >= _strokesNeeded) {
      _magnetize();
    } else {
      _toast('toast_stroke_prog', args: {'n': s.strokes}, sound: false);
    }
  }

  void _toggleStep(int i) {
    _Sound.click.play();
    setState(() {
      if (!_toggledSteps.remove(i)) _toggledSteps.add(i);
    });
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#hud-actions` buttons for the current step.
  List<LabAction> _actions() {
    final s = _scene;
    final p = _lab.palette;
    LabAction action(String key, IconData icon, VoidCallback onTap) =>
        LabAction(
          label: _t(key),
          icon: icon,
          color: p.primary,
          foreground: p.onPrimary,
          enabled: !s.spinning,
          highlight: !s.spinning,
          onTap: onTap,
        );
    if (s.scenario == 0) {
      if (s.step == 3) {
        return [
          action(
            'btn_spin_cw',
            Icons.rotate_right,
            () => _spinMagnet(clockwise: true),
          ),
        ];
      }
      if (s.step == 4) {
        return [
          action(
            'btn_spin_ccw',
            Icons.rotate_left,
            () => _spinMagnet(clockwise: false),
          ),
        ];
      }
    } else {
      if (s.step == 1) {
        return [action('btn_auto_stroke', Icons.bolt, _autoStroke)];
      }
      if (s.step == 5) {
        return [action('btn_spin_cork', Icons.explore, _spinCork)];
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        final sc = _scene.scenario;
        return LabShell(
          controller: _lab,
          icon: Icons.explore,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, data.steps.length)}'),
          actions: _actions(),
          sidebarExtraTitle: _t('obs_table'),
          sidebarExtra: _Notebook(
            rows: List.of(_scene.rows),
            steps: data.steps,
            currentStep: _scene.step,
            toggled: Set.of(_toggledSteps),
            onToggle: _toggleStep,
            t: _t,
            fontScale: _lab.fontScale,
            note: _t('scen_${sc + 1}_note'),
            noteIcon: sc == 0 ? Icons.architecture : Icons.water_drop,
          ),
          onReset: () => _loadScenario(0),
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
        _fit = fit > 0 ? fit : 1;
        // Canvas labels stay readable when the stage is scaled down.
        final uiScale = (0.85 / _fit).clamp(1.0, 1.8);
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..canGrab = _canGrab
                      // Short drags must pick objects up: pan slop 16 px
                      // instead of 36 (RawGestureDetector ignores the
                      // MediaQuery gesture settings).
                      ..gestureSettings = _dragGestureSettings
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _dragStart
                      ..onUpdate = _dragUpdate
                      ..onCancel = _dragEnd
                      ..onEnd = (_) => _dragEnd(),
                  ),
            },
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  repaint: _frame,
                  palette: _lab.palette,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  uiScale: uiScale,
                  text: _text,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sidebar extra, in the HTML's indigo: the floating "Observation Table",
/// the "Procedural Steps" accordion (task instruction + expected outcome per
/// step) and the scenario's apparatus card.
class _Notebook extends StatelessWidget {
  const _Notebook({
    required this.rows,
    required this.steps,
    required this.currentStep,
    required this.toggled,
    required this.onToggle,
    required this.t,
    required this.fontScale,
    required this.note,
    required this.noteIcon,
  });

  final List<_Trial> rows;
  final List<LabStep> steps;
  final int currentStep;
  final Set<int> toggled;
  final ValueChanged<int> onToggle;
  final String Function(String key) t;
  final double fontScale;
  final String note;
  final IconData noteIcon;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ObservationTable(rows: rows, t: t, fontScale: fontScale),
        SizedBox(height: 14 * s),
        LabSectionLabel(
          t('concept_exp'),
          size: 10.5 * s,
          icon: Icons.format_list_numbered,
        ),
        SizedBox(height: 8 * s),
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 6 * s),
          _stepCard(p, s, f, i),
        ],
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(noteIcon, size: 18 * s, color: p.primary),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  note,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 11 * f,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// One accordion card: past steps green with a check, the current one
  /// open, future ones greyed out and closed.
  Widget _stepCard(LabPalette p, double s, double f, int i) {
    final past = i < currentStep;
    final current = i == currentStep;
    final future = i > currentStep;
    final open = !future && (current != toggled.contains(i));
    final tint = current ? p.primary : (past ? p.success : p.textMuted);
    final step = steps[i - 1];
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? p.primary
              : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: future ? null : () => onToggle(i),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
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
                            ? p.primary
                            : (past
                                  ? p.success.withValues(alpha: 0.2)
                                  : p.cardBorder.withValues(alpha: 0.5)),
                        border: Border.all(color: tint),
                      ),
                      child: past
                          ? Icon(Icons.check, size: 13 * s, color: p.success)
                          : Text(
                              '$i',
                              style: TextStyle(
                                color: current ? p.onPrimary : p.textMuted,
                                fontSize: 10.5 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        '${t('step_lbl')} $i',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: future ? p.textMuted : tint,
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
                      color: p.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: EdgeInsets.fromLTRB(10 * s, 0, 10 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t('task_instr').toUpperCase(),
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 9.5 * f,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 3 * s),
                  Text(
                    step.action,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: p.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(color: p.primary, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 13 * s,
                              color: p.ink(_Colors.amber500),
                            ),
                            SizedBox(width: 4 * s),
                            Expanded(
                              child: Text(
                                t('exp_outcome').toUpperCase(),
                                style: TextStyle(
                                  color: p.primary,
                                  fontSize: 9.5 * f,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3 * s),
                        Text(
                          step.observation,
                          style: TextStyle(
                            color: p.textStrong,
                            fontSize: 11 * f,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

/// HTML `#results-table-container` table: trial and resting direction.
class _ObservationTable extends StatelessWidget {
  const _ObservationTable({
    required this.rows,
    required this.t,
    required this.fontScale,
  });

  final List<_Trial> rows;
  final String Function(String key) t;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.3,
    );
    final body = TextStyle(
      color: p.textStrong,
      fontSize: 11 * f,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
    Widget cell(Widget child) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
      child: child,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.cardBorder),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.1), 1: FlexColumnWidth()},
        border: TableBorder(horizontalInside: BorderSide(color: p.cardBorder)),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: p.cardBorder.withValues(alpha: 0.35),
            ),
            children: [
              cell(Text(t('tbl_trial'), style: head)),
              cell(Text(t('tbl_rest_dir'), style: head)),
            ],
          ),
          for (final row in rows)
            TableRow(
              children: [
                cell(Text(t(row.key), style: body)),
                cell(
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: 4 * s),
                            child: Icon(
                              Icons.check_circle,
                              size: 13 * f,
                              color: p.success,
                            ),
                          ),
                        ),
                        TextSpan(text: t('dir_ns')),
                      ],
                    ),
                    style: body.copyWith(
                      color: p.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.isEmpty)
            TableRow(
              children: [
                cell(Text('—', style: head)),
                cell(Text('—', style: head)),
              ],
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);
  final double x, y, z;

  static const _V zero = _V(0, 0, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  _V operator -() => _V(-x, -y, -z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l < 1e-12 ? this : this * (1 / l);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

const _V _up = _V(0, 1, 0);

/// Key light direction: DirectionalLight at (12, 25, 15).
const _V _light = _V(0.3806, 0.7929, 0.4757);

/// Ambient (0.65) and directional (0.85) intensities, toned down so the lit
/// table top does not wash out.
const double _ambient = 0.55;
const double _diffuse = 0.6;

/// Shadows fall away from the light: per unit of height, −Lx/Ly in x and
/// −Lz/Ly in z.
const double _shadowDx = -0.48;
const double _shadowDz = -0.6;

/// Pinhole projection of the HTML PerspectiveCamera (fov 45° over the
/// 560 px stage height) at [eye] looking at the OrbitControls target.
class _Proj {
  _Proj(this.eye, _V target) {
    f = (target - eye).unit;
    r = f.cross(_up).unit;
    u = r.cross(f);
  }

  /// (560 / 2) / tan(45° / 2).
  static const double focal = 675.9798;
  static const Offset center = Offset(500, 280);

  final _V eye;
  late final _V f, r, u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray crosses the horizontal plane y = [py] (drag plane).
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }
}

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  final upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

/// Text painters for canvas text, laid out once and reused across frames.
class _TextCache {
  static const int _maxEntries = 160;
  final Map<String, TextPainter> _cache = {};

  TextPainter get(String text, double size, Color color, FontWeight weight) {
    final family = LabFont.active.family;
    final key =
        '$text|${size.toStringAsFixed(1)}|${color.toARGB32()}|'
        '$weight|$family';
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length >= _maxEntries) dispose();
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          fontFamily: family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.15,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    return _cache[key] = tp;
  }

  void dispose() {
    for (final tp in _cache.values) {
      tp.dispose();
    }
    _cache.clear();
  }
}

/// Paints the HTML Three.js bench: table, compass rose, stand, bar magnet,
/// spool, needle, cork, bowl of water, glow outlines and floating labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.uiScale,
    required this.text,
  }) : super(repaint: repaint);

  final _Scene scene;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double uiScale;
  final _TextCache text;

  // Reused for every shape of a frame.
  final Paint _fill = Paint();
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..color = _Colors.black.withValues(alpha: 0.28)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path _path = Path();

  late Canvas _c;
  late _Proj _p;

  /// The 50 px canvas grid (`.canvas-grid`), built once.
  static Path? _grid;
  static Rect? _gridRect;

  static const List<double> _cylStops = [
    0,
    1 / 6,
    2 / 6,
    3 / 6,
    4 / 6,
    5 / 6,
    1,
  ];

  String _tr(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = _Proj(scene.eye, scene.target);
    _background(size);
    _table();
    if (scene.scenario == 0) {
      _benchS1();
    } else {
      _benchS2();
    }
    if (showLabels) _labels();
  }

  // ------------------------------------------------------------ primitives

  Color _lit(Color c, _V n, {double opacity = 1}) {
    final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: (c.a * opacity).clamp(0.0, 1.0),
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  void _fillPoints(List<Offset> pts, Color color) {
    if (pts.length < 3) return;
    _path
      ..reset()
      ..addPolygon(pts, true);
    _c.drawPath(
      _path,
      _fill
        ..shader = null
        ..color = color,
    );
  }

  void _strokePoints(
    List<Offset> pts,
    Color color,
    double width, {
    bool close = false,
  }) {
    if (pts.length < 2) return;
    _path
      ..reset()
      ..addPolygon(pts, close);
    _c.drawPath(
      _path,
      _line
        ..color = color
        ..strokeWidth = width,
    );
  }

  void _poly(List<_V> pts, Color color) =>
      _fillPoints([for (final q in pts) _p.p(q)], color);

  /// Soft shadow of a footprint lying [height] above the table.
  void _shadowOf(List<_V> footprint, double height, {double opacity = 1}) {
    final pts = [
      for (final q in footprint)
        _p.p(_V(q.x + _shadowDx * height, 0.004, q.z + _shadowDz * height)),
    ];
    if (pts.length < 3) return;
    _path
      ..reset()
      ..addPolygon(pts, true);
    _c.drawPath(
      _path,
      _shadow..color = _Colors.black.withValues(alpha: 0.28 * opacity),
    );
  }

  /// Horizontal circle of radius [r] around [c], projected.
  List<Offset> _ring(_V c, double r, {int segments = 48}) => [
    for (var i = 0; i < segments; i++)
      _p.p(
        _V(
          c.x + r * math.cos(i * 2 * math.pi / segments),
          c.y,
          c.z + r * math.sin(i * 2 * math.pi / segments),
        ),
      ),
  ];

  /// Oriented box (BoxGeometry) at [c] with unit axes [ex], [ey], [ez] and
  /// half sizes; only faces turned to the camera are drawn.
  void _box(
    _V c,
    _V ex,
    _V ey,
    _V ez,
    double hx,
    double hy,
    double hz,
    Color color, {
    double edge = 0.35,
  }) {
    final ax = ex * hx, ay = ey * hy, az = ez * hz;
    void face(_V n, _V fc, _V a, _V b) {
      if (n.dot(_p.eye - fc) <= 0) return;
      final pts = [
        _p.p(fc + a + b),
        _p.p(fc - a + b),
        _p.p(fc - a - b),
        _p.p(fc + a - b),
      ];
      _fillPoints(pts, _lit(color, n));
      if (edge > 0) {
        _strokePoints(
          pts,
          labShade(color, -0.55).withValues(alpha: edge),
          0.8,
          close: true,
        );
      }
    }

    face(ex, c + ax, ay, az);
    face(-ex, c - ax, ay, az);
    face(ey, c + ay, ax, az);
    face(-ey, c - ay, ax, az);
    face(ez, c + az, ax, ay);
    face(-ez, c - az, ax, ay);
  }

  /// Box edges only (the HTML wireframe glow meshes).
  void _wireBox(
    _V c,
    _V ex,
    _V ey,
    _V ez,
    double hx,
    double hy,
    double hz,
    Color color,
  ) {
    final corners = [
      for (final sx in const [-1.0, 1.0])
        for (final sy in const [-1.0, 1.0])
          for (final sz in const [-1.0, 1.0])
            _p.p(c + ex * (sx * hx) + ey * (sy * hy) + ez * (sz * hz)),
    ];
    _line
      ..color = color
      ..strokeWidth = 1.4;
    // Corner index bits: x = 4, y = 2, z = 1.
    for (var i = 0; i < 8; i++) {
      for (final bit in const [4, 2, 1]) {
        if (i & bit == 0) _c.drawLine(corners[i], corners[i | bit], _line);
      }
    }
  }

  /// Lit colours across a cylinder's visible side, from one silhouette edge
  /// through the part facing the camera to the other (with a specular
  /// [sheen] like the MeshStandardMaterial highlight).
  Shader _cylinderShader(
    _V mid,
    _V axis,
    double radius,
    Color color,
    double sheen,
  ) {
    final view = _p.eye - mid;
    var nv = view - axis * view.dot(axis);
    if (nv.length < 1e-6) {
      // Looking straight along the axis: any side direction will do.
      nv = axis.cross(axis.y.abs() > 0.9 ? const _V(1, 0, 0) : _up);
    }
    nv = nv.unit;
    final w = axis.cross(nv).unit;
    final half = (_light + view.unit).unit;
    final colors = <Color>[];
    for (var i = 0; i <= 6; i++) {
      final a = -math.pi / 2 + math.pi * i / 6;
      final n = nv * math.cos(a) + w * math.sin(a);
      final lit = _ambient + _diffuse * math.max(0.0, n.dot(_light));
      final rim = 0.75 + 0.25 * math.cos(a);
      final spec = sheen * math.pow(math.max(0.0, n.dot(half)), 24);
      colors.add(
        Color.from(
          alpha: color.a,
          red: (color.r * lit * rim + spec).clamp(0.0, 1.0),
          green: (color.g * lit * rim + spec).clamp(0.0, 1.0),
          blue: (color.b * lit * rim + spec).clamp(0.0, 1.0),
        ),
      );
    }
    return ui.Gradient.linear(
      _p.p(mid - w * radius),
      _p.p(mid + w * radius),
      colors,
      _cylStops,
    );
  }

  /// Cylinder / cone frustum (CylinderGeometry, ConeGeometry) from [base]
  /// along unit [axis]: radius [r0] at the base, [r1] at the far end.
  void _frustum(
    _V base,
    _V axis,
    double r0,
    double r1,
    double length,
    Color color, {
    Color? cap,
    double sheen = 0.25,
    bool caps = true,
    int segments = 24,
  }) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : _up;
    final a1 = axis.cross(helper).unit;
    final a2 = axis.cross(a1).unit;
    final top = base + axis * length;
    List<_V> ring(_V c, double r) => [
      for (var i = 0; i < segments; i++)
        c +
            (a1 * math.cos(i * 2 * math.pi / segments) +
                    a2 * math.sin(i * 2 * math.pi / segments)) *
                r,
    ];
    final rb = ring(base, r0);
    final rt = ring(top, r1);
    final outline = _hull([
      for (final q in rb) _p.p(q),
      for (final q in rt) _p.p(q),
    ]);
    if (outline.length < 3) return;
    _path
      ..reset()
      ..addPolygon(outline, true);
    _c.drawPath(
      _path,
      _fill
        ..shader = _cylinderShader(
          base + axis * (length / 2),
          axis,
          math.max(r0, r1),
          color,
          sheen,
        ),
    );
    _fill.shader = null;
    if (!caps) return;
    final capColor = cap ?? labShade(color, 0.12);
    if (r1 > 0 && axis.dot(_p.eye - top) > 0) {
      _poly(rt, _lit(capColor, axis));
    } else if (r0 > 0 && (-axis).dot(_p.eye - base) > 0) {
      _poly(rb, _lit(capColor, -axis));
    }
  }

  /// Text lying on a surface (the rose letters, the N / S on the magnet):
  /// the text box is mapped onto the plane spanned by [right] and [up]
  /// through the projection's local scale at [center].
  void _decal(TextPainter tp, _V center, _V right, _V up, double worldPerPx) {
    final o = _p.p(center);
    final ax = _p.p(center + right * worldPerPx) - o;
    final ay = _p.p(center - up * worldPerPx) - o;
    _c.save();
    _c.transform(
      Float64List.fromList([
        ax.dx, ax.dy, 0, 0, //
        ay.dx, ay.dy, 0, 0, //
        0, 0, 1, 0, //
        o.dx, o.dy, 0, 1,
      ]),
    );
    tp.paint(_c, Offset(-tp.width / 2, -tp.height / 2));
    _c.restore();
  }

  // ------------------------------------------------------------- the set

  void _background(Size size) {
    final bleed = labBleed(size);
    _c.drawRect(
      bleed,
      _fill
        ..shader = null
        ..color = _Colors.canvas,
    );
    if (_grid == null || _gridRect != bleed) {
      final g = Path();
      const step = 50.0;
      for (
        var x = (bleed.left / step).floor() * step;
        x <= bleed.right;
        x += step
      ) {
        g
          ..moveTo(x, bleed.top)
          ..lineTo(x, bleed.bottom);
      }
      for (
        var y = (bleed.top / step).floor() * step;
        y <= bleed.bottom;
        y += step
      ) {
        g
          ..moveTo(bleed.left, y)
          ..lineTo(bleed.right, y);
      }
      _grid = g;
      _gridRect = bleed;
    }
    _c.drawPath(
      _grid!,
      _line
        ..strokeWidth = 1
        ..color = (palette.isDark ? _Colors.white : _Colors.black).withValues(
          alpha: 0.03,
        ),
    );
  }

  /// Table: BoxGeometry(26, 1, 18), top at y = 0, colour #472d1e.
  void _table() {
    const hx = _tableHalfX, hz = _tableHalfZ;
    final topFace = [
      _p.p(const _V(-hx, 0, -hz)),
      _p.p(const _V(hx, 0, -hz)),
      _p.p(const _V(hx, 0, hz)),
      _p.p(const _V(-hx, 0, hz)),
    ];
    _fillPoints(topFace, _lit(_Colors.table, _up));
    _poly(const [
      _V(-hx, 0, hz),
      _V(hx, 0, hz),
      _V(hx, -1, hz),
      _V(-hx, -1, hz),
    ], _lit(_Colors.table, const _V(0, 0, 1)));
    // Wood grain.
    _line
      ..strokeWidth = 1
      ..color = labShade(_Colors.table, -0.35).withValues(alpha: 0.3);
    for (var z = -8.6; z < hz; z += 0.8) {
      final wobble = math.sin(z * 2.7) * 0.18;
      _c.drawLine(
        _p.p(_V(-hx, 0.001, z)),
        _p.p(_V(hx, 0.001, z + wobble)),
        _line,
      );
    }
    _strokePoints(
      topFace,
      labShade(_Colors.table, 0.25).withValues(alpha: 0.5),
      1.2,
      close: true,
    );
  }

  /// Compass rose (512 px canvas texture on an 8 × 8 plane): rings, dashed
  /// cardinal lines, centre dot and N / S / W / E.
  void _rose(_V c, double opacity) {
    if (opacity <= 0.01) return;
    final k = _p.scaleAt(c);
    const unit = 8 / 512; // world units per texture px
    _strokePoints(
      _ring(c, 230 * unit, segments: 72),
      _Colors.roseRing.withValues(alpha: 0.8 * opacity),
      6 * unit * k,
      close: true,
    );
    _strokePoints(
      _ring(c, 180 * unit, segments: 72),
      _Colors.roseRing.withValues(alpha: 0.3 * opacity),
      math.max(1, 2 * unit * k),
      close: true,
    );
    // Dashed cardinal lines (setLineDash([8, 8]), 3 px).
    _line
      ..strokeWidth = math.max(1, 3 * unit * k)
      ..color = _Colors.roseDash.withValues(alpha: 0.5 * opacity);
    const reach = 230 * unit;
    const dash = 8 * unit;
    for (var d = -reach; d < reach; d += 2 * dash) {
      final e = math.min(d + dash, reach);
      _c.drawLine(_p.p(c + _V(0, 0, d)), _p.p(c + _V(0, 0, e)), _line);
      _c.drawLine(_p.p(c + _V(d, 0, 0)), _p.p(c + _V(e, 0, 0)), _line);
    }
    _fillPoints(
      _ring(c, 8 * unit, segments: 16),
      _Colors.roseRing.withValues(alpha: opacity),
    );
    // Letters: 900 64 px N / S, 700 48 px W / E, 191 px from the centre.
    final alpha = (opacity * 10).round() / 10;
    const right = _V(1, 0, 0), up = _V(0, 0, -1);
    const off = 191 * unit;
    void letter(String key, Color color, double px, FontWeight w, _V at) =>
        _decal(
          text.get(_tr(key), px, color.withValues(alpha: alpha), w),
          at,
          right,
          up,
          unit,
        );
    letter(
      'rose_n',
      _Colors.roseN,
      64,
      FontWeight.w900,
      c + const _V(0, 0, -off),
    );
    letter(
      'rose_s',
      _Colors.roseS,
      64,
      FontWeight.w900,
      c + const _V(0, 0, off),
    );
    letter(
      'rose_w',
      _Colors.roseWE,
      48,
      FontWeight.w700,
      c + const _V(-off, 0, 0),
    );
    letter(
      'rose_e',
      _Colors.roseWE,
      48,
      FontWeight.w700,
      c + const _V(off, 0, 0),
    );
  }

  /// Draws [items] far to near (painter's algorithm).
  void _flush(List<(double, VoidCallback)> items) {
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final item in items) {
      item.$2();
    }
  }

  // ------------------------------------------------------------ scenario 1

  void _benchS1() {
    final s = scene;
    _rose(_roseS1, s.roseOpacity);
    // Shadows: stand base, pillar, arm, magnet, spool.
    _shadowOf(const [
      _V(-2.5, 0, -5.5),
      _V(2.5, 0, -5.5),
      _V(2.5, 0, -0.5),
      _V(-2.5, 0, -0.5),
    ], 0.5);
    _shadowOf(
      const [
        _V(-0.25, 0, -3),
        _V(0.25, 0, -3),
        _V(0.25 + _shadowDx * 9.75, 0, -3 + _shadowDz * 9.75),
        _V(-0.25 + _shadowDx * 9.75, 0, -3 + _shadowDz * 9.75),
      ],
      0,
      opacity: 0.8,
    );
    _shadowOf(
      const [
        _V(-0.3, 0, -3.25),
        _V(0.3, 0, -3.25),
        _V(0.3, 0, 2.25),
        _V(-0.3, 0, 2.25),
      ],
      9.2,
      opacity: 0.6,
    );
    _magnetShadow(s.magnetPos, s.magnetYaw);
    _discShadow(s.spoolPos, 0.8, s.spoolPos.y - 0.675);

    final items = <(double, VoidCallback)>[
      (_p.depth(const _V(0, 0.25, -3)), _stand),
      if (s.dragging != _Obj.spool)
        (_p.depth(s.spoolPos), () => _spool(s.spoolPos)),
      if (s.dragging != _Obj.magnet)
        (_p.depth(s.magnetPos), () => _magnetS1(glow: false)),
    ];
    _flush(items);
    // The lifted object is drawn last, with its selection glow.
    if (s.dragging == _Obj.spool) _spool(s.spoolPos, glow: true);
    if (s.dragging == _Obj.magnet) _magnetS1(glow: true);
  }

  /// Suspension stand: wooden base, indigo metal pillar, arm and hook.
  void _stand() {
    const ex = _V(1, 0, 0), ez = _V(0, 0, 1);
    _box(const _V(0, 0.25, -3), ex, _up, ez, 2.5, 0.25, 2.5, _Colors.standWood);
    _frustum(
      const _V(0, 0.25, -3),
      _up,
      0.25,
      0.25,
      9.5,
      _Colors.pillar,
      sheen: 0.6,
    );
    _box(
      const _V(0, 9.5, -0.5),
      ex,
      _up,
      ez,
      0.3,
      0.3,
      2.75,
      _Colors.standWood,
    );
    // Hook: TorusGeometry(0.3, 0.06, ..., 1.5π) turned into the y–z plane.
    final hook = [
      for (var i = 0; i <= 27; i++)
        _p.p(
          _hookPos +
              _V(
                0,
                0.3 * math.sin(i * 1.5 * math.pi / 27),
                -0.3 * math.cos(i * 1.5 * math.pi / 27),
              ),
        ),
    ];
    final k = _p.scaleAt(_hookPos);
    _strokePoints(hook, labShade(_Colors.hook, -0.35), math.max(2, 0.14 * k));
    _strokePoints(hook, _Colors.hook, math.max(1.2, 0.08 * k));
  }

  void _magnetS1({required bool glow}) {
    final s = scene;
    if (s.hooked) {
      // Suspension thread from the hook to the knot loop.
      final knotTop = s.magnetPos + const _V(0, 1.07, 0);
      _line
        ..color = _Colors.threadTie.withValues(alpha: 0.9)
        ..strokeWidth = math.max(1.2, 0.05 * _p.scaleAt(knotTop));
      _c.drawLine(_p.p(_hookPos), _p.p(knotTop), _line);
    }
    _magnet(s.magnetPos, s.magnetYaw, tied: s.tied, glow: glow);
  }

  /// Bar magnet: BoxGeometry halves 2.3 × 0.8 × 1.2, red N / blue S, white
  /// N and S on top; once tied, a thread ring round the middle and a knot
  /// loop on top.
  void _magnet(_V pos, double yaw, {bool tied = false, bool glow = false}) {
    final d = _dir(yaw);
    final ez = _side(yaw);
    // With the thread ring the halves stop at its edges (±0.25).
    final inner = tied ? 0.25 : 0.0;
    final half = (2.3 - inner) / 2;
    final nCenter = pos + d * (inner + half);
    final sCenter = pos - d * (inner + half);
    final nFar = _p.depth(nCenter) > _p.depth(sCenter);
    void north() => _box(nCenter, d, _up, ez, half, 0.4, 0.6, _Colors.magnetN);
    void south() => _box(sCenter, d, _up, ez, half, 0.4, 0.6, _Colors.magnetS);
    void ring() => _frustum(
      pos - d * 0.25,
      d,
      0.68,
      0.68,
      0.5,
      _Colors.threadTie,
      caps: false,
      sheen: 0.15,
    );
    if (nFar) {
      north();
      if (tied) ring();
      south();
    } else {
      south();
      if (tied) ring();
      north();
    }
    // "N" / "S": bold 96 px on a 128 px canvas over a 0.7 plane.
    const pxPerLetter = 72.0;
    const worldPerPx = 0.7 / 128 * 96 / pxPerLetter;
    final top = _up * 0.41;
    _decal(
      text.get(_tr('pole_n'), pxPerLetter, _Colors.white, FontWeight.w800),
      pos + d * 1.8 + top,
      -d,
      ez,
      worldPerPx,
    );
    _decal(
      text.get(_tr('pole_s'), pxPerLetter, _Colors.white, FontWeight.w800),
      pos - d * 1.8 + top,
      -d,
      ez,
      worldPerPx,
    );
    if (tied) {
      // Knot loop: TorusGeometry(0.32, 0.06) standing on top.
      final c = pos + _up * 0.75;
      final loop = [
        for (var i = 0; i < 24; i++)
          _p.p(
            c +
                d * (0.32 * math.cos(i * math.pi / 12)) +
                _up * (0.32 * math.sin(i * math.pi / 12)),
          ),
      ];
      final k = _p.scaleAt(c);
      _strokePoints(
        loop,
        labShade(_Colors.threadTie, -0.3),
        math.max(1.6, 0.14 * k),
        close: true,
      );
      _strokePoints(
        loop,
        _Colors.threadTie,
        math.max(1, 0.09 * k),
        close: true,
      );
    }
    if (glow) {
      _wireBox(
        pos,
        d,
        _up,
        ez,
        2.45,
        0.5,
        0.7,
        _Colors.indigo500.withValues(alpha: 0.6),
      );
    }
  }

  void _magnetShadow(_V pos, double yaw) {
    final d = _dir(yaw) * 2.3;
    final e = _side(yaw) * 0.6;
    final b = _V(pos.x, 0, pos.z);
    _shadowOf([b + d + e, b - d + e, b - d - e, b + d - e], pos.y - 0.4);
  }

  void _discShadow(_V pos, double r, double height) {
    _shadowOf([
      for (var i = 0; i < 16; i++)
        _V(
          pos.x + r * math.cos(i * math.pi / 8),
          0,
          pos.z + r * math.sin(i * math.pi / 8),
        ),
    ], math.max(0, height));
  }

  /// Spool of thread: wooden rims (r 0.8) round white wound thread (r 0.7).
  void _spool(_V pos, {bool glow = false}) {
    _frustum(
      pos + const _V(0, -0.675, 0),
      _up,
      0.8,
      0.8,
      0.15,
      _Colors.spoolWood,
    );
    _frustum(
      pos + const _V(0, -0.5, 0),
      _up,
      0.7,
      0.7,
      1.0,
      _Colors.thread,
      sheen: 0.12,
    );
    // Thread windings on the side facing the camera.
    final toEye = _V(_p.eye.x - pos.x, 0, _p.eye.z - pos.z).unit;
    _line
      ..strokeWidth = 0.8
      ..color = labShade(_Colors.thread, -0.35).withValues(alpha: 0.55);
    for (final y in const [-0.32, -0.12, 0.08, 0.28]) {
      final arc = <Offset>[];
      for (var i = 0; i <= 12; i++) {
        final a = -math.pi / 2 + math.pi * i / 12;
        final dir = toEye * math.cos(a) + toEye.cross(_up) * math.sin(a);
        arc.add(_p.p(pos + _V(dir.x * 0.705, y, dir.z * 0.705)));
      }
      _path
        ..reset()
        ..addPolygon(arc, false);
      _c.drawPath(_path, _line);
    }
    _frustum(
      pos + const _V(0, 0.525, 0),
      _up,
      0.8,
      0.8,
      0.15,
      _Colors.spoolWood,
    );
    if (glow) {
      final color = _Colors.indigo500.withValues(alpha: 0.85);
      final top = _ring(pos + const _V(0, 0.7, 0), 0.9, segments: 24);
      final bottom = _ring(pos + const _V(0, -0.7, 0), 0.9, segments: 24);
      _strokePoints(top, color, 1.4, close: true);
      _strokePoints(bottom, color, 1.4, close: true);
      for (var i = 0; i < 24; i += 6) {
        _line
          ..color = color
          ..strokeWidth = 1.4;
        _c.drawLine(top[i], bottom[i], _line);
      }
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _benchS2() {
    final s = scene;
    _rose(_roseS2, _roseOpacityS2);
    // Shadows: bowl (faint, glass), needle, cork, magnet.
    _discShadow(_bowlPos, 3.4, 0);
    if (!s.pierced) {
      _needleShadow(s.needlePos, s.needleYaw, s.needlePos.y - 0.08);
      _discShadow(s.corkPos, 1.5, 0);
    } else if (!s.floating) {
      _discShadow(s.assemblyPos, 1.5, s.assemblyPos.y - 0.4);
    }
    _magnetShadow(s.magnetPos, s.magnetYaw);

    final items = <(double, VoidCallback)>[
      (_p.depth(_bowlPos + const _V(0, 1.25, 0)), _bowl),
      if (s.dragging != _Obj.magnet)
        (_p.depth(s.magnetPos), () => _magnet(s.magnetPos, s.magnetYaw)),
      if (!s.pierced && s.dragging != _Obj.needle)
        (_p.depth(s.needlePos), () => _needle(s.needlePos, s.needleYaw)),
      if (!s.pierced) (_p.depth(s.corkPos), () => _cork(s.corkPos, 0)),
      if (s.pierced && !s.floating && s.dragging != _Obj.assembly)
        (
          _p.depth(s.assemblyPos),
          () => _assembly(s.assemblyPos, s.assemblyYaw),
        ),
    ];
    _flush(items);
    switch (s.dragging) {
      case _Obj.magnet:
        _magnet(s.magnetPos, s.magnetYaw, glow: true);
      case _Obj.needle:
        _needle(s.needlePos, s.needleYaw, glow: true);
      case _Obj.assembly:
        _assembly(s.assemblyPos, s.assemblyYaw);
      case _Obj.spool:
      case null:
        break;
    }
  }

  void _needleShadow(_V pos, double yaw, double height) {
    final d = _dir(yaw) * 2.4;
    final e = _side(yaw) * 0.1;
    final b = _V(pos.x, 0, pos.z);
    _shadowOf(
      [b + d + e, b - d + e, b - d - e, b + d - e],
      math.max(0, height),
      opacity: 0.7,
    );
  }

  /// Sewing needle along its tip direction: body r 0.08 × 3.8, cone tip
  /// (0.6) and flared eye end (0.4). Glows #38bdf8 just after each stroke.
  void _needle(_V pos, double yaw, {bool glow = false}) {
    final d = _dir(yaw);
    final pulse = (1 - (scene.time - scene.needlePulse) / _pulseS).clamp(
      0.0,
      1.0,
    );
    final color = Color.lerp(_Colors.steel, _Colors.needleGlow, pulse)!;
    if (pulse > 0) {
      labGlow(
        _c,
        _p.p(pos),
        1.6 * _p.scaleAt(pos),
        _Colors.needleGlow,
        intensity: 0.5 * pulse,
      );
    }
    _frustum(pos - d * 1.9, -d, 0.08, 0.12, 0.4, color, sheen: 0.9);
    _frustum(pos - d * 1.9, d, 0.08, 0.08, 3.8, color, sheen: 0.9, caps: false);
    _frustum(pos + d * 1.9, d, 0.08, 0, 0.6, color, sheen: 0.9);
    if (glow) {
      _wireBox(
        pos,
        d,
        _up,
        _side(yaw),
        2.5,
        0.2,
        0.2,
        _Colors.needleGlow.withValues(alpha: 0.9),
      );
    }
  }

  /// Cork disc: CylinderGeometry(1.6, 1.5, 0.8), #d97706. Only the slice
  /// between heights [lo] and [hi] is drawn (the part under / above the
  /// water line).
  void _cork(_V pos, double yaw, {double lo = -1e9, double hi = 1e9}) {
    final y0 = pos.y - 0.4, y1 = pos.y + 0.4;
    final a = math.max(y0, lo), b = math.min(y1, hi);
    if (b <= a) return;
    double radius(double y) => 1.5 + 0.1 * (y - y0) / 0.8;
    _frustum(
      _V(pos.x, a, pos.z),
      _up,
      radius(a),
      radius(b),
      b - a,
      _Colors.cork,
      sheen: 0.05,
      segments: 32,
    );
    if (b < y1) return;
    // Cork grain on the top face, turning with the cork.
    final d = _dir(yaw), e = _side(yaw);
    for (var i = 0; i < 9; i++) {
      final ang = i * 2.39996;
      final rr = 0.35 + 0.95 * ((i * 37) % 10) / 10;
      final q =
          pos +
          _V(0, 0.401, 0) +
          d * (rr * math.cos(ang)) +
          e * (rr * math.sin(ang));
      final k = _p.scaleAt(q);
      _c.drawOval(
        Rect.fromCenter(center: _p.p(q), width: 0.12 * k, height: 0.06 * k),
        _fill
          ..shader = null
          ..color = labShade(_Colors.cork, -0.3).withValues(alpha: 0.6),
      );
    }
  }

  /// Cork with the needle lying through its top (needle at local y 0.4).
  void _assembly(_V pos, double yaw, {double lo = -1e9, double hi = 1e9}) {
    _cork(pos, yaw, lo: lo, hi: hi);
    final needleY = pos.y + 0.4;
    if (needleY >= lo && needleY < hi) {
      _needle(pos + const _V(0, 0.4, 0), yaw);
    }
  }

  /// Glass bowl (r 3.2 → 4.5, h 2.5, opacity 0.35) with water (r 3.1 → 4.3,
  /// h 1.8, #0284c7). The floating cork is drawn between the water and the
  /// front of the glass, its lower half under the water surface.
  void _bowl() {
    final s = scene;
    const c = _bowlPos;
    final rim = _ring(c + const _V(0, 2.5, 0), 4.5, segments: 64);
    final floor = _ring(c + const _V(0, 0.02, 0), 3.2, segments: 64);
    _fillPoints(
      _hull([...rim, ...floor]),
      _Colors.glass.withValues(alpha: 0.12),
    );
    _fillPoints(rim, _Colors.glass.withValues(alpha: 0.06));
    final surface = _ring(c + const _V(0, _waterLevel, 0), 4.3, segments: 64);
    final bed = _ring(c + const _V(0, 0.04, 0), 3.1, segments: 64);
    _fillPoints(
      _hull([...surface, ...bed]),
      _Colors.water.withValues(alpha: 0.5),
    );
    final floatHere = s.floating && s.dragging != _Obj.assembly;
    if (floatHere) {
      _assembly(s.assemblyPos, s.assemblyYaw, hi: _waterLevel);
    }
    _fillPoints(surface, _Colors.waterTop.withValues(alpha: 0.3));
    _strokePoints(
      surface,
      _Colors.waterTop.withValues(alpha: 0.6),
      1.4,
      close: true,
    );
    if (floatHere) {
      _assembly(s.assemblyPos, s.assemblyYaw, lo: _waterLevel);
    }
    // Front of the glass: rim (front brighter), sides, base and a glint.
    final k = _p.scaleAt(c + const _V(0, 2.5, 0));
    final n = rim.length;
    final back = [for (var i = n ~/ 2; i <= n; i++) rim[i % n]];
    final front = [for (var i = 0; i <= n ~/ 2; i++) rim[i]];
    _strokePoints(
      back,
      _Colors.white.withValues(alpha: 0.3),
      math.max(1, 0.1 * k),
    );
    _strokePoints(
      front,
      _Colors.white.withValues(alpha: 0.55),
      math.max(1.4, 0.16 * k),
    );
    _strokePoints(
      [for (var i = 0; i <= n ~/ 2; i++) floor[i]],
      _Colors.white.withValues(alpha: 0.25),
      1.2,
    );
    _line
      ..color = _Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    _c.drawLine(rim[0], floor[0], _line);
    _c.drawLine(rim[n ~/ 2], floor[n ~/ 2], _line);
    final glint = (n * 0.38).round();
    _line
      ..color = _Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = math.max(2, 0.22 * k);
    _c.drawLine(
      Offset.lerp(rim[glint], floor[glint], 0.12)!,
      Offset.lerp(rim[glint], floor[glint], 0.8)!,
      _line,
    );
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.html-label` chips 1.2 units above each object (stand: 10, bowl:
  /// 3).
  void _labels() {
    final s = scene;
    void label(String key, _V at, {double lift = 0}) {
      final tp = text.get(
        _tr(key),
        11 * uiScale,
        palette.labelText,
        FontWeight.w700,
      );
      final o = _p.p(at) - Offset(0, lift);
      final padX = 8 * uiScale, padY = 4 * uiScale;
      final rect = Rect.fromCenter(
        center: o,
        width: tp.width + 2 * padX,
        height: tp.height + 2 * padY,
      );
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(4 * uiScale));
      _c.drawRRect(
        rr,
        _fill
          ..shader = null
          ..color = palette.labelBg,
      );
      _c.drawRRect(
        rr,
        _line
          ..strokeWidth = 1
          ..color = _Colors.white.withValues(alpha: 0.1),
      );
      tp.paint(_c, Offset(rect.left + padX, rect.top + padY));
    }

    const above = _V(0, 1.2, 0);
    if (s.scenario == 0) {
      label('lbl_stand', const _V(0, 10, 0));
      label('lbl_bar_magnet', s.magnetPos + above);
      label('lbl_spool', s.spoolPos + above);
      return;
    }
    label('lbl_water_bowl', _bowlPos + const _V(0, 3, 0));
    label('lbl_bar_magnet', s.magnetPos + above);
    if (!s.pierced) {
      label('lbl_needle', s.needlePos + above);
      label('lbl_cork', s.corkPos + above);
    } else {
      // Needle and cork share the assembly's spot: stack the two chips
      // (afloat, above the bowl's chip, which sits at the same height).
      final at = s.assemblyPos + (s.floating ? _floatLabelLift : above);
      label('lbl_cork', at);
      label('lbl_needle', at, lift: 26 * uiScale);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.uiScale != uiScale;
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
