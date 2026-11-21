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

/// Class 6 Science • Chapter 11 • Activity 1
/// Air: Composition, Importance, and Uses.
///
/// Native Flutter port of
/// `Cl6S-Ch11-A1-Air__Composition__Importance__and_Uses.html` (Three.js r128
/// + Tween.js). The Three.js scenes are redrawn in 2D by [_ScenePainter]
/// with the HTML camera (45° field of view at (0, 11, 29) looking at
/// (0, 3.5, 0)); the picture is fitted into the part of the canvas that the
/// oxygen meter, the controls and the HUD leave free ([_Framing]).
///
/// Scenario 1 (The Breath of Life): Ajji meditates cross-legged on a mat in
/// a village. Pressing and holding 'Hold Breath' drains the Oxygen Level bar
/// and runs the breath timer; below 50% her face turns bluish, she sweats
/// and trembles. Letting go before 0% makes her gasp for air while the bar
/// refills to 100%. Held down to 0%, she slumps and faints, and 'Observe
/// Conclusion' opens the summary.
///
/// Scenario 2 (Harnessing the Wind): the Wind Speed slider sends wind lines
/// across the sky and spins a paper pinwheel (firki). Past 70% the scene
/// changes to a wind turbine on a hill, wired to a house; the slider turns
/// its blades, and above 80% the power lines and the house windows glow with
/// electricity. 'Observe Conclusion' then shows the summary with confetti.
class Ch11A1AirCompositionImportanceAndUsesPage extends StatefulWidget {
  const Ch11A1AirCompositionImportanceAndUsesPage({super.key});

  @override
  State<Ch11A1AirCompositionImportanceAndUsesPage> createState() =>
      _AirLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'pop' (letting go of 'Hold Breath', fainting, closing a popup) → pop
/// (`science/click.mp3`), 'breath' (a filtered-noise breath when the button
/// is pressed) → breath and 'wind' (the scene change to the wind turbine) →
/// wind (both `science/curtain.mp3`, the closest soft whoosh), 'success'
/// (the house is powered, 'Observe Conclusion') → success
/// (`math/success.mp3`). The shell plays click (`science/click.mp3`),
/// toggle (`science/dropdown.mp3`), correct (`math/success.mp3`), wrong
/// (`science/error.mp3`), scenario (`science/page_open.mp3`) and curtain
/// (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toasts.
  correct('audio/class6/math/success.mp3'),

  /// Error toasts.
  wrong('audio/class6/science/error.mp3'),

  /// HTML 'success': the house lights up, the summary popups.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'pop': 'Hold Breath' let go (a gasp), the faint.
  pop('audio/class6/science/click.mp3'),

  /// HTML 'breath': 'Hold Breath' pressed.
  breath('audio/class6/science/curtain.mp3'),

  /// HTML 'wind': the pinwheel gives way to the wind turbine.
  wind('audio/class6/science/curtain.mp3');

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

/// Tailwind colours of the HTML page and its Three.js materials.
abstract final class _Colors {
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  // ------------------------------------------------- scenes (HTML colours)

  /// `scene.background`: the village sky (S1) and the night-blue sky (S2).
  static const Color sky = Color(0xFF87CEEB);
  static const Color night = Color(0xFF1E3A8A);

  /// Village: grass, houses (cream walls, terracotta roofs), doors,
  /// windows, tree trunks and leaves.
  static const Color grass = Color(0xFF4ADE80);
  static const Color wall = Color(0xFFFEF08A);
  static const Color tiles = Color(0xFFC2410C);
  static const Color door = Color(0xFF78350F);
  static const Color pane = Color(0xFF1E293B);
  static const Color trunk = Color(0xFF78350F);
  static const Color leaves = Color(0xFF15803D);

  /// Ajji: meditation mat, orange saree, gold border, royal blue blouse,
  /// gold jewellery, silver hair, jasmine gajra and her skin tones (calm,
  /// straining, fainted).
  static const Color mat = Color(0xFF854D0E);
  static const Color saree = Color(0xFFEA580C);
  static const Color sareeBorder = yellow400;
  static const Color blouse = blue600;
  static const Color gold = amber400;
  static const Color hair = slate300;
  static const Color gajra = white;
  static const Color skin = Color(0xFFF3C2B1);
  static const Color skinStrain = Color(0xFFBFDBFE);
  static const Color skinFaint = Color(0xFF93C5FD);

  /// Face texture (HTML `createFaceTexture`).
  static const Color blush = Color(0x73F87171);
  static const Color blushStrain = Color(0x8060A5FA);
  static const Color blushFaint = Color(0x4D3B82F6);
  static const Color hairDark = slate400;
  static const Color strand = slate500;
  static const Color bindi = red600;
  static const Color bindiDot = yellow400;
  static const Color ink = slate800;
  static const Color pupil = slate900;
  static const Color iris = Color(0xFF3B82F6);
  static const Color nose = Color(0xFFD97757);
  static const Color mouth = Color(0xFF450A0A);
  static const Color lips = Color(0xFFBE123C);
  static const Color smile = Color(0xFF9F1239);
  static const Color air = Color(0xFF38BDF8);
  static const Color slack = slate700;
  static const Color sweat = Color(0xFF60A5FA);
  static const Color sweatShine = Color(0xFFEFF6FF);

  /// Pinwheel: stick, hub and its red, blue, yellow and purple blades.
  static const Color stick = Color(0xFFA16207);
  static const List<Color> blades = [
    red500,
    Color(0xFF3B82F6),
    yellow500,
    Color(0xFFA855F7),
  ];

  /// Wind turbine, its house and the power lines (glowing yellow).
  static const Color tower = slate50;
  static const Color nacelle = slate200;
  static const Color rotorHub = slate400;
  static const Color rotorBlade = slate300;
  static const Color house = slate700;
  static const Color houseRoof = slate800;
  static const Color dark = slate950;
  static const Color wire = Color(0xFF111827);
  static const Color power = yellow500;

  /// Scene label sprites: `rgba(15, 23, 42, 0.9)` with an indigo border.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = indigo500;

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
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// HTML accent is indigo; the canvas (`#canvas-wrapper`, `bg-[#87CEEB]`)
/// is sky blue in both themes.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.sky,
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
    info: _Colors.emerald400, // past steps (dark:text-emerald-400)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // text-indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sky,
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
    info: _Colors.emerald600, // past steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.slate300,
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
// Current Task, Step, Success!, the settings and canvas-tool names and the
// footer) come from the shell's `kLabCommonStrings`. `sN_hud_M` are the
// HTML `hud` lines, `sN_concept_M` / `sN_action_M` / `sN_obs_M` the step
// concept, action and observation; 'CLICK' became 'TAP' ('क्लिक' → 'टैप').
// Each HTML `summary` is split into its bold heading (`sN_sum_title`) and
// its text (`sN_summary`). Keys marked "Added." are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Air: Composition, Importance, and Uses',
    'app_subtitle': "Class 6 . Nature's Treasures",
    'scen_1_opt': 'Scenario 1: The Breath of Life',
    'scen_2_opt': 'Scenario 2: Harnessing the Wind',
    's1_desc':
        'To visually understand and experience why air, specifically the oxygen in it, is essential for survival.',
    's2_desc':
        'To understand that moving air (wind) has energy and can be used to do useful work, like generating electricity.',
    's1_hud_1':
        "Step 1: Observe the character and the Oxygen Level bar (at 100%), then tap and hold the 'Hold Breath' button.",
    's1_hud_2':
        'Step 2: Continue holding the button until the Oxygen Level drops below 60% and observe the changes.',
    's1_hud_3':
        'Step 3: Release the button before the Oxygen Level reaches 0% to let the character breathe and refill to 100%.',
    's1_hud_4':
        'Step 4: Hold the button continuously until the Oxygen Level hits exactly 0%.',
    's1_hud_5':
        "Step 5: Tap 'Observe Conclusion' to understand the learning outcomes.",
    's1_concept_1': 'Observing Normalcy',
    's1_action_1':
        "Observe the calm character, then TAP and HOLD the 'Hold Breath' button.",
    's1_obs_1':
        'The simulation starts and the oxygen timer begins counting up.',
    's1_concept_2': 'Holding Breath',
    's1_action_2': 'Continue HOLDING the button as oxygen drops below 60%.',
    's1_obs_2':
        "Oxygen bar drops. The character's face turns slightly bluish, sweats, and starts trembling in discomfort.",
    's1_concept_3': 'Relief of Breathing',
    's1_action_3': 'RELEASE the button before the oxygen bar reaches 0%.',
    's1_obs_3':
        'The character takes a deep gasp of air. Face color returns to normal and oxygen rapidly refills to 100%.',
    's1_concept_4': 'Lack of Oxygen',
    's1_action_4': 'TAP and HOLD the button continuously until oxygen hits 0%.',
    's1_obs_4':
        'Severe discomfort occurs; the character slumps and faints due to lack of oxygen.',
    's1_concept_5': 'Conclusion',
    's1_action_5': "Tap the 'Observe Conclusion' button at the bottom.",
    's1_obs_5':
        'Confirms that humans need a constant supply of oxygen from air to survive.',
    's1_sum_title': 'Observation Complete!',
    's1_summary':
        'We cannot survive for more than a few minutes without breathing. Our bodies need a constant supply of oxygen from the air to function. This activity shows that air is a vital treasure for life.',
    's2_hud_1':
        "Step 1: Drag the 'Wind Speed' slider to spin the paper pinwheel.",
    's2_hud_2': 'Step 2: Drag the slider to make the large windmill rotate.',
    's2_hud_3': "Step 3: Increase wind speed to 'High' to power the house.",
    's2_hud_4': "Step 4: Tap 'Observe Conclusion'.",
    's2_concept_1': 'Wind moves objects',
    's2_action_1': "DRAG the 'Wind Speed' slider from Low towards High.",
    's2_obs_1':
        'Wind lines flow across the screen and the paper pinwheel (firki) spins rapidly.',
    's2_concept_2': 'Scaling up wind power',
    's2_action_2': 'The scene transitions to a hill. DRAG the slider right.',
    's2_obs_2':
        'The large blades of the wind turbine start rotating against the wind.',
    's2_concept_3': 'Generating Electricity',
    's2_action_3': "Move the 'Wind Speed' slider all the way to 'High'.",
    's2_obs_3':
        'Power lines glow yellow with electricity and the house windows light up brightly.',
    's2_concept_4': 'Conclusion',
    's2_action_4': "Tap the 'Observe Conclusion' button.",
    's2_obs_4':
        'Demonstrates that wind energy can be captured to produce clean electricity.',
    's2_sum_title': 'Power Generated!',
    's2_summary':
        "Moving air is called wind. Wind has energy that can make things move, from a small firki to a giant windmill. This energy can be captured by windmills to do useful work, like generating electricity to power our homes. This is a clean way to use one of nature's treasures.",
    // Teacher board (HTML `concept_exp`, `concept_focus`, `action`,
    // `observation`).
    'concept_exp': 'Observation Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Popups.
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete_desc':
        'You learned that air is essential for life and moving air (wind) can generate clean energy!',
    // Canvas panels and toasts.
    'oxy_level': 'Oxygen Level',
    'hold_breath': 'Hold Breath',
    'wind_speed': 'Wind Speed',
    'low': 'Low',
    'high': 'High',
    'btn_conclude': 'Observe Conclusion',
    'toast_faint': 'The character fainted! Oxygen is vital.',
    // HTML literal (English only in the HTML).
    'toast_hold_longer':
        'Hold longer until oxygen drops to observe character strain & blue tint!',
    // Scene label sprites.
    'lbl_ajji': 'Ajji',
    'lbl_firki': 'Firki',
    'lbl_windmill': 'Windmill',
    // Added: screen-reader descriptions of the scenes.
    'scene_s1':
        'A village with houses and trees. Ajji sits cross-legged on a meditation mat, breathing calmly.',
    'scene_s2_pinwheel':
        'A paper pinwheel (firki) on a stick against a blue sky, with wind lines blowing across.',
    'scene_s2_windmill':
        'A wind turbine on a green hill, joined by power lines to a house.',
  },
  'hi': {
    'app_title': 'हवा: संरचना, महत्व और उपयोग',
    'app_subtitle': 'कक्षा 6 . प्रकृति का खजाना',
    'scen_1_opt': 'परिदृश्य 1: जीवन की सांस',
    'scen_2_opt': 'परिदृश्य 2: हवा का दोहन',
    's1_desc':
        'यह समझने के लिए कि हवा, विशेष रूप से उसमें मौजूद ऑक्सीजन, जीवित रहने के लिए क्यों आवश्यक है।',
    's2_desc':
        'यह समझने के लिए कि चलती हवा (हवा) में ऊर्जा होती है और इसका उपयोग उपयोगी कार्य करने के लिए किया जा सकता है, जैसे बिजली पैदा करना।',
    's1_hud_1': "चरण 1: 'सांस रोकें' बटन को दबाकर रखें। (ऑक्सीजन 100% पर है)",
    's1_hud_2': 'चरण 2: बटन को दबाए रखें जब तक कि ऑक्सीजन 60% से नीचे न आ जाए।',
    's1_hud_3':
        'चरण 3: ऑक्सीजन 0% होने से पहले सांस लेने के लिए बटन छोड़ दें और 100% भरने दें।',
    's1_hud_4':
        'चरण 4: अब, बटन को तब तक दबाए रखें जब तक कि ऑक्सीजन का स्तर 0% न हो जाए।',
    's1_hud_5': "चरण 5: 'निष्कर्ष देखें' पर टैप करें।",
    's1_concept_1': 'सामान्यता का अवलोकन',
    's1_action_1': "'सांस रोकें' बटन पर टैप करें और दबाए रखें।",
    's1_obs_1': 'सिमुलेशन शुरू होता है और ऑक्सीजन टाइमर चलने लगता है।',
    's1_concept_2': 'सांस रोकना',
    's1_action_2': 'बटन को दबाए रखें और ऑक्सीजन का स्तर घटते हुए देखें।',
    's1_obs_2':
        'ऑक्सीजन बार घटता है। चरित्र का चेहरा नीला पड़ जाता है, पसीना आता है और कांपने लगता है।',
    's1_concept_3': 'सांस लेने की राहत',
    's1_action_3': 'ऑक्सीजन बार 0% होने से पहले बटन छोड़ दें।',
    's1_obs_3':
        'चरित्र हवा की गहरी सांस लेती है। चेहरे का रंग सामान्य हो जाता है और ऑक्सीजन 100% भर जाता है।',
    's1_concept_4': 'ऑक्सीजन की कमी',
    's1_action_4':
        'बटन को फिर से तब तक दबाए रखें जब तक कि ऑक्सीजन 0% न हो जाए।',
    's1_obs_4':
        'अत्यधिक बेचैनी होती है; ऑक्सीजन की कमी से चरित्र बेहोश हो जाती है।',
    's1_concept_5': 'निष्कर्ष',
    's1_action_5': "नीचे 'निष्कर्ष देखें' बटन पर टैप करें।",
    's1_obs_5':
        'यह पुष्टि करता है कि जीवित रहने के लिए हवा से निरंतर ऑक्सीजन आवश्यक है।',
    's1_sum_title': 'अवलोकन पूर्ण!',
    's1_summary':
        'हम बिना सांस लिए कुछ मिनटों से अधिक जीवित नहीं रह सकते। हमारे शरीर को कार्य करने के लिए हवा से ऑक्सीजन की निरंतर आपूर्ति की आवश्यकता होती है। यह गतिविधि दर्शाती है कि हवा जीवन के लिए एक महत्वपूर्ण खजाना है।',
    's2_hud_1': "चरण 1: 'हवा की गति' स्लाइडर को 'कम' से 'उच्च' तक खींचें।",
    's2_hud_2':
        'चरण 2: दृश्य बदल गया। पवनचक्की को घुमाने के लिए फिर से स्लाइडर खींचें।',
    's2_hud_3': "चरण 3: बिजली पैदा करने के लिए स्लाइडर को 'उच्च' पर ले जाएं।",
    's2_hud_4': "चरण 4: 'निष्कर्ष देखें' पर टैप करें।",
    's2_concept_1': 'हवा वस्तुओं को ले जाती है',
    's2_action_1': "'हवा की गति' स्लाइडर को दाईं ओर खींचें।",
    's2_obs_1':
        'हवा की रेखाएं दिखाई देती हैं और कागज की फिरकी तेजी से घूमने लगती है।',
    's2_concept_2': 'पवन ऊर्जा को बढ़ाना',
    's2_action_2': 'दृश्य पहाड़ी पर बदलता है। स्लाइडर को फिर से खींचें।',
    's2_obs_2': 'पवनचक्की के विशाल ब्लेड हवा के साथ तेजी से घूमने लगते हैं।',
    's2_concept_3': 'बिजली पैदा करना',
    's2_action_3': "स्लाइडर को पूरी तरह से 'उच्च' पर ले जाएं।",
    's2_obs_3':
        'बिजली के तार पीले रंग में चमकते हैं और घर की खिड़कियां रोशन हो जाती हैं।',
    's2_concept_4': 'निष्कर्ष',
    's2_action_4': "'निष्कर्ष देखें' बटन पर टैप करें।",
    's2_obs_4':
        'दर्शाता है कि पवन ऊर्जा से स्वच्छ बिजली उत्पन्न की जा सकती है।',
    's2_sum_title': 'डेटा का विश्लेषण किया गया!',
    's2_summary':
        'चलती हवा को पवन कहा जाता है। हवा में ऊर्जा होती है जो एक छोटी फिरकी से लेकर विशाल पवनचक्की तक चीजों को घुमा सकती है। इस ऊर्जा को पवन चक्कियों द्वारा हमारे घरों को बिजली देने जैसे उपयोगी काम करने के लिए प्राप्त किया जा सकता है।',
    'concept_exp': 'अवलोकन चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete_desc':
        'आपने सीखा कि हवा जीवन के लिए आवश्यक है और चलती हवा (हवा) स्वच्छ ऊर्जा उत्पन्न कर सकती है!',
    'oxy_level': 'ऑक्सीजन स्तर',
    'hold_breath': 'सांस रोकें',
    'wind_speed': 'हवा की गति',
    'low': 'कम',
    'high': 'उच्च',
    'btn_conclude': 'निष्कर्ष देखें',
    'toast_faint': 'चरित्र बेहोश हो गया! ऑक्सीजन महत्वपूर्ण है।',
    // Added: Hindi for the HTML literal toast.
    'toast_hold_longer':
        'ऑक्सीजन घटने तक और देर तक दबाए रखें, ताकि चरित्र का तनाव और नीला रंग दिख सके!',
    'lbl_ajji': 'अज्जी',
    'lbl_firki': 'फिरकी',
    'lbl_windmill': 'पवनचक्की',
    // Added.
    'scene_s1':
        'घरों और पेड़ों वाला एक गाँव। अज्जी ध्यान की चटाई पर पालथी मारकर बैठी हैं और शांति से सांस ले रही हैं।',
    'scene_s2_pinwheel':
        'नीले आसमान में एक डंडी पर कागज़ की फिरकी, जिसके पार हवा की रेखाएं बह रही हैं।',
    'scene_s2_windmill':
        'हरी पहाड़ी पर एक पवनचक्की, जो बिजली के तारों से एक घर से जुड़ी है।',
  },
};

/// Steps per scenario (the HTML `steps` arrays).
const List<int> _stepCounts = [5, 4];

/// HTML `ScenariosData[lang][n]`: title, objective and the steps' concept,
/// action and observation for scenario [index] in [lang].
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('scen_${n}_opt'),
    objective: t('s${n}_desc'),
    steps: [
      for (var i = 1; i <= _stepCounts[index]; i++)
        LabStep(
          concept: t('s${n}_concept_$i'),
          action: t('s${n}_action_$i'),
          observation: t('s${n}_obs_$i'),
        ),
    ],
  );
}

/// Both scenarios in both languages, built once from [_i18n].
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values)
    lang: [
      for (var i = 0; i < _stepCounts.length; i++) _buildScenario(lang, i),
    ],
};

// ===================================================================== STATE

/// Design size of the stage; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 11, 29) looking at `controls.target` (0, 3.5, 0).
const double _fovDegrees = 45;
const _V _eye = _V(0, 11, 29);
const _V _lookAt = _V(0, 3.5, 0);

/// Design pixels per world unit at depth 1 with the HTML framing: half the
/// stage height over tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// The camera's forward, right and up axes.
final _V _camF = (_lookAt - _eye).unit;
final _V _camR = _camF.cross(_V.up).unit;
final _V _camU = _camR.cross(_camF);

/// Points nearer the camera plane than [_near] are clamped; meshes nearer
/// than [_clipDepth] are not drawn.
const double _near = 0.1;
const double _clipDepth = 0.5;

/// Longest frame step fed to the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

// ------------------------------------------------------------------ framing

/// The fitted scene is drawn between [_minZoom] and [_maxZoom] times the
/// size the HTML camera gives it.
const double _minZoom = 0.3;
const double _maxZoom = 1.35;

/// Re-framing (new scene, sidebar toggled) slides like the sidebar (s).
const double _framingSeconds = 0.45;

/// Canvas room (logical px, times the UI scale) that the scene keeps clear
/// of: the oxygen meter at the top (Scenario 1; in Scenario 2 room for the
/// enlarged Firki label), the HUD chip at the bottom (sidebar open) and the
/// breath controls or the wind-speed panel above it; plus a small gap.
const double _oxygenRoom = 52;
const double _labelRoom = 22;
const double _hudRoom = 66;
const double _holdRoom = 64;
const double _windRoom = 84;
const double _edgeGap = 6;

/// World points that must stay in view: Ajji from her lap to her label,
/// the pinwheel from the foot of its stick to its label, the wind turbine's
/// whole blade circle, its label, the house and the poles.
const List<_V> _ajjiFocus = [
  _V(-8.6, -1.4, 1.6),
  _V(8.6, -1.4, 1.6),
  _V(0, -3.6, 4.6),
  _V(-3, 16.05, 0),
  _V(3, 16.05, 0),
];
const List<_V> _pinwheelFocus = [
  _V(-3, 13.25, 0),
  _V(3, 13.25, 0),
  _V(-4, 3.5, 0.8),
  _V(4, 11.5, 0.8),
  _V(0, -8.5, 0),
];
const List<_V> _windmillFocus = [
  _V(-28.75, 18, 2.7),
  _V(4.75, 18, 2.7),
  _V(-12, 34.75, 2.7),
  _V(-12, -2, 0),
  _V(-4, -2, 2),
  _V(17, 14, 9),
  _V(17, 1, 9),
];

// --------------------------------------------------------------- scenario 1
// HTML `setupInteraction()` and `animate()` (60 frames a second).

/// Holding the breath drains 0.35% a frame; breathing refills 2% a frame;
/// the breath timer adds 0.016 s a frame.
const double _drainPerSecond = 21;
const double _refillPerSecond = 120;
const double _timerPerSecond = 0.96;

/// Below 50% Ajji strains (blue face, sweat, shivering); the bar turns
/// amber below 60% and red below 30%.
const double _strainBelow = 50;
const double _medBelow = 60;
const double _lowBelow = 30;

/// Step 2 moves on when 'Hold Breath' is let go at 75% or less, or after
/// it was held for 2.5 s.
const double _advanceAtOrBelow = 75;
const double _advanceAfter = 2.5;

/// The gasp turns back into a calm face after 1 s.
const Duration _calmAfter = Duration(seconds: 1);

/// Letting go: Ajji grows to 1.05 and back (200 ms each way, yoyo).
const double _pulseSeconds = 0.2;
const double _pulseScale = 1.05;

/// Shivering `sin(Date.now() × 0.08) × 0.05` and the calm breathing
/// `sin(Date.now() × 0.0035) × 0.04` (time in ms).
const double _shiverRate = 80;
const double _shiverAmp = 0.05;
const double _breathRate = 3.5;
const double _breathAmp = 0.04;

/// The faint: torso and head turn to these angles in 1 s.
const double _slumpSeconds = 1;
const double _torsoSlumpX = math.pi / 5;
const double _torsoSlumpZ = math.pi / 6;
const double _headSlumpX = math.pi / 3;
const double _headSlumpZ = math.pi / 4;

// --------------------------------------------------------------- scenario 2
// HTML slider `input` handler, `switchS2Phase()` and `animate()`.

/// Above these wind speeds the step moves on after the given wait.
const double _pinwheelAt = 70;
const double _windmillAt = 40;
const double _powerAt = 80;
const Duration _pinwheelWait = Duration(milliseconds: 2500);
const Duration _windmillWait = Duration(milliseconds: 2500);
const Duration _powerWait = Duration(milliseconds: 2000);

/// Rotation `windSpeed × 0.005` a frame (the pinwheel 2.5 times faster);
/// wind lines move `windSpeed × 0.005 × 12 × speed` a frame.
const double _spinPerSecond = 0.3;
const double _pinwheelFactor = 2.5;
const double _gustPerSecond = 3.6;

/// 40 wind lines in x −30…30, y 0…25, z −15…15.
const int _particleCount = 40;
const double _particleHalfX = 30;

/// The pinwheel shrinks away in 500 ms; the turbine scene then grows from
/// 0.1 and rises from y −10 in 1000 ms (Elastic.Out).
const double _shrinkSeconds = 0.5;
const double _growSeconds = 1;
const double _growFrom = 0.1;
const double _growDrop = -10;

// ----------------------------------------------------------------- labels

/// HTML text sprites: 6 × 1.5 world units (384 × 96 px canvas, bold 36 px
/// text, 24 px corners, 4 px indigo border). On small stages they are
/// enlarged (up to 1.8x) so they stay readable on phones.
const double _spriteW = 6;
const double _spriteH = 1.5;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Label text is never drawn smaller than this (design px, before the
/// small-stage boost), however far the scene is zoomed out.
const double _labelMinText = 12;

// ---------------------------------------------------------------- confetti

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks, decay 0.9, gravity 3 px a tick, start velocity 45 px a tick,
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

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

  /// A local surface normal in world space (the axes are orthogonal, so
  /// the inverse transpose divides each axis by its squared length).
  _V normal(_V n) =>
      (x * (n.x / x.dot(x)) + y * (n.y / y.dot(y)) + z * (n.z / z.dot(z))).unit;

  /// The same frame scaled by [k] about its origin (Three.js `scale`).
  _Xf scaled(double k) => _Xf(o, x * k, y * k, z * k);

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
}

/// The HTML PerspectiveCamera as a pinhole projection onto the stage:
/// [center] is where the look-at line lands and [scale] the design pixels
/// per world unit at depth 1 (the HTML framing is [_designCenter] and
/// [_focal]).
@immutable
class _Cam {
  const _Cam(this.center, this.scale);

  final Offset center;
  final double scale;

  _V get eye => _eye;

  double depth(_V w) => (w - _eye).dot(_camF);

  /// The design point of [w] (points behind the camera are clamped to the
  /// near plane; callers skip them).
  Offset p(_V w) {
    final d = w - _eye;
    final z = math.max(_near, d.dot(_camF));
    return Offset(
      center.dx + scale * d.dot(_camR) / z,
      center.dy - scale * d.dot(_camU) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  /// The screen offset of a small step [a] taken at [w] (the projection's
  /// derivative): how a mesh's axes look on screen.
  Offset dp(_V w, _V a) {
    final d = w - _eye;
    final z = math.max(_near, d.dot(_camF));
    final az = a.dot(_camF);
    return Offset(
      scale * (a.dot(_camR) * z - d.dot(_camR) * az) / (z * z),
      -scale * (a.dot(_camU) * z - d.dot(_camU) * az) / (z * z),
    );
  }
}

/// Where the camera's look-at line lands on the stage and how large the
/// scene is drawn: fitted into the part of the canvas no panel covers.
@immutable
class _Framing {
  const _Framing(this.center, this.scale);

  final Offset center;
  final double scale;

  /// The HTML framing.
  static final _Framing base = _Framing(_designCenter, _focal);

  /// The framing that fits the projection of [points] into [free] (design
  /// px), at a zoom within [_minZoom]…[_maxZoom].
  static _Framing fit(List<_V> points, Rect free) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final w in points) {
      final d = w - _eye;
      final z = math.max(_near, d.dot(_camF));
      final x = d.dot(_camR) / z, y = -d.dot(_camU) / z;
      l = math.min(l, x);
      r = math.max(r, x);
      t = math.min(t, y);
      b = math.max(b, y);
    }
    final w = math.max(1e-3, r - l), h = math.max(1e-3, b - t);
    final scale = math
        .min(free.width / w, free.height / h)
        .clamp(_focal * _minZoom, _focal * _maxZoom);
    return _Framing(
      free.center - Offset((l + r) / 2, (t + b) / 2) * scale,
      scale,
    );
  }

  _Framing lerpTo(_Framing o, double k) => _Framing(
    Offset.lerp(center, o.center, k)!,
    scale + (o.scale - scale) * k,
  );

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (scale - o.scale).abs() < 0.5;

  _Cam get cam => _Cam(center, scale);
}

/// HTML `TWEEN.Easing.Elastic.Out`.
double _elasticOut(double k) {
  if (k <= 0) return 0;
  if (k >= 1) return 1;
  return math.pow(2, -10 * k).toDouble() * math.sin((k - 0.1) * 5 * math.pi) +
      1;
}

/// Ease in-out (cubic) for the re-framing slide.
double _easeInOut(double t) =>
    t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;

/// HTML `THREE.CatmullRomCurve3(points)` (centripetal) sampled at
/// [samples] + 1 evenly spaced parameters.
List<_V> _catmullRom(List<_V> pts, int samples) {
  double distSq(_V a, _V b) => (a - b).dot(a - b);
  double poly(
    double x0,
    double x1,
    double x2,
    double x3,
    double dt0,
    double dt1,
    double dt2,
    double t,
  ) {
    final t1 =
        ((x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1) * dt1;
    final t2 =
        ((x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2) * dt1;
    final c2 = -3 * x1 + 3 * x2 - 2 * t1 - t2;
    final c3 = 2 * x1 - 2 * x2 + t1 + t2;
    return x1 + t1 * t + c2 * t * t + c3 * t * t * t;
  }

  final n = pts.length;
  return [
    for (var i = 0; i <= samples; i++)
      () {
        final p = (n - 1) * i / samples;
        var k = p.floor();
        var w = p - k;
        if (k >= n - 1) {
          k = n - 2;
          w = 1;
        }
        final p1 = pts[k], p2 = pts[k + 1];
        final p0 = k > 0 ? pts[k - 1] : p1 * 2 - p2;
        final p3 = k + 2 < n ? pts[k + 2] : p2 * 2 - p1;
        var dt1 = math.pow(distSq(p1, p2), 0.25).toDouble();
        var dt0 = math.pow(distSq(p0, p1), 0.25).toDouble();
        var dt2 = math.pow(distSq(p2, p3), 0.25).toDouble();
        if (dt1 < 1e-4) dt1 = 1;
        if (dt0 < 1e-4) dt0 = dt1;
        if (dt2 < 1e-4) dt2 = dt1;
        return _V(
          poly(p0.x, p1.x, p2.x, p3.x, dt0, dt1, dt2, w),
          poly(p0.y, p1.y, p2.y, p3.y, dt0, dt1, dt2, w),
          poly(p0.z, p1.z, p2.z, p3.z, dt0, dt1, dt2, w),
        );
      }(),
  ];
}

/// The two power lines of the turbine scene (HTML `TubeGeometry` along
/// these curves, radius 0.15).
final List<List<_V>> _powerLines = [
  _catmullRom(const [
    _V(-12, 16, 0),
    _V(-4, 6, 2),
    _V(4, 6, 3),
    _V(12, 6, 5),
  ], 40),
  _catmullRom(const [
    _V(-12, 15, 0),
    _V(-4, 5, 2),
    _V(4, 5, 3),
    _V(12, 5, 5),
  ], 40),
];

// ------------------------------------------------------------- scene model

/// Ajji's face texture (HTML `createFaceTexture(state)`).
enum _Face { calm, straining, gasping, fainted }

/// One wind line (HTML `createWindParticles()`): its position and speed.
class _Particle {
  _Particle(this.x, this.y, this.z, this.speed);

  double x;
  final double y;
  final double z;
  final double speed;
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

/// Mutable scene read by the painter and the canvas panels every frame
/// (HTML `State`, the Three.js objects' animated values and the tweens).
class _Scene {
  _Scene() {
    final rnd = math.Random(11);
    for (var i = 0; i < _particleCount; i++) {
      particles.add(
        _Particle(
          (rnd.nextDouble() - 0.5) * 60,
          rnd.nextDouble() * 25,
          (rnd.nextDouble() - 0.5) * 30,
          rnd.nextDouble() * 0.5 + 0.5,
        ),
      );
    }
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

  /// Scene clock (s).
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// 'Observe Conclusion' is shown (HTML `#compare-btn-container`).
  bool conclusionShown = false;

  /// 'Observe Conclusion' was tapped: the summary has been shown.
  bool concluded = false;

  // ------------------------------------------------------------ scenario 1

  /// HTML `State.s1`: button held, oxygen level (%), fainted, breath timer
  /// (s) and when step 2 began.
  bool pressed = false;
  double breath = 100;
  bool fainted = false;
  double timePassed = 0;
  double step2At = 0;

  /// The breath controls are shown (hidden once Ajji faints).
  bool controlsShown = true;

  /// Face texture and skin colour (HTML `ajjiFaceMat.map`, `skinMats`).
  _Face face = _Face.calm;
  Color skin = _Colors.skin;

  /// Torso and head rotations (x forward, z sideways) and the calm
  /// breathing value (HTML `breathSine`).
  double torsoRx = 0;
  double torsoRz = 0;
  double headRx = 0;
  double headRz = 0;
  double breathe = 0;

  /// The faint tweens: start time and the angles they start from.
  double slumpAt = -1;
  List<double> slumpFrom = const [0, 0, 0, 0];

  /// The 1.05 scale pulse when Ajji gasps (start time).
  double pulseAt = -1;

  // ------------------------------------------------------------ scenario 2

  /// HTML `State.s2`: wind speed (0–100) and the turbine scene shown.
  double wind = 0;
  bool showWindmill = false;

  /// The wind-speed panel is shown (hidden once the house is powered).
  bool windPanelShown = true;

  /// Pinwheel blades and turbine rotor angles (rad, HTML `rotation.z`).
  double pinwheelAngle = 0;
  double rotorAngle = 0;

  /// The scene change: pinwheel shrink and turbine grow start times.
  double shrinkAt = -1;
  double growAt = -1;

  final List<_Particle> particles = [];

  // --------------------------------------------------------------- shared

  /// Scene time of the summary's confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// The camera framing on screen, sliding from [_from] to [_to].
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framedAt = -1;
  bool _snapFraming = true;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    conclusionShown = false;
    concluded = false;
    pressed = false;
    breath = 100;
    fainted = false;
    timePassed = 0;
    step2At = 0;
    controlsShown = true;
    face = _Face.calm;
    skin = _Colors.skin;
    torsoRx = 0;
    torsoRz = 0;
    headRx = 0;
    headRz = 0;
    breathe = 0;
    slumpAt = -1;
    pulseAt = -1;
    wind = 0;
    showWindmill = false;
    windPanelShown = true;
    shrinkAt = -1;
    growAt = -1;
    confettiAt = -1;
    _snapFraming = true;
  }

  /// The points the framing keeps in view.
  List<_V> get focus => scenario == 0
      ? _ajjiFocus
      : (showWindmill ? _windmillFocus : _pinwheelFocus);

  /// Fits [focus] into [free] (design px): jumps there after a scenario
  /// change, otherwise slides.
  void frame(Rect free) {
    final target = _Framing.fit(focus, free);
    if (_snapFraming) {
      _snapFraming = false;
      framing = _from = _to = target;
      _framedAt = -1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framedAt = time;
  }

  /// Advances the framing slide.
  void advanceFraming() {
    if (_framedAt < 0) return;
    final e = ((time - _framedAt) / _framingSeconds).clamp(0.0, 1.0);
    framing = _from.lerpTo(_to, _easeInOut(e));
    if (e >= 1) _framedAt = -1;
  }

  // ------------------------------------------------------- derived values

  /// Ajji's scale (the yoyo pulse when she gasps).
  double get ajjiScale {
    if (pulseAt < 0) return 1;
    final u = (time - pulseAt) / _pulseSeconds;
    if (u >= 2) return 1;
    final k = u < 1 ? u : 2 - u;
    return 1 + (_pulseScale - 1) * k;
  }

  /// Pinwheel scale while it shrinks away (0 once gone).
  double get pinwheelScale {
    if (shrinkAt < 0) return 1;
    return (1 - (time - shrinkAt) / _shrinkSeconds).clamp(0.0, 1.0);
  }

  /// Turbine scene scale and height while it grows in (Elastic.Out).
  (double, double) get windmillGrowth {
    if (growAt < 0) return (1, 0);
    final e = _elasticOut(((time - growAt) / _growSeconds).clamp(0.0, 1.0));
    return (_growFrom + (1 - _growFrom) * e, _growDrop * (1 - e));
  }

  /// The house and power lines glow (HTML: wind speed above 80 with the
  /// turbine shown).
  bool get powered => showWindmill && wind > _powerAt;
}

// ================================================================== THE LAB

class _AirLabState extends State<Ch11A1AirCompositionImportanceAndUsesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) and the part of the stage (design
  /// px, may reach into the letterbox) that the canvas panels leave free;
  /// null until the stage is laid out.
  double _fit = 1;
  Rect? _free;

  /// UI scale of the last build (popup cards).
  double _uiScale = 1;

  /// Scenario 2: the step whose wait (HTML `setTimeout`) is running.
  int? _waitingStep;

  /// Last feedback toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

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
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update(), the scenario's per-frame logic and
  /// the render (one repaint of the canvas and its panels).
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    if (s.scenario == 0) {
      _breathFrame(dt);
    } else {
      _windFrame(dt);
    }
    // Framed once the stage has been laid out (so it starts in place).
    final free = _free;
    if (free != null) s.frame(free);
    s.advanceFraming();
    _frame.value = now;
  }

  /// Scenario 1, every frame: holding drains the oxygen and runs the timer
  /// (below 50% Ajji strains and shivers; at 0% she faints); otherwise the
  /// oxygen refills and she breathes calmly. After the faint only the slump
  /// tweens run.
  void _breathFrame(double dt) {
    final s = _scene;
    if (s.fainted) {
      final e = s.slumpAt < 0
          ? 1.0
          : ((s.time - s.slumpAt) / _slumpSeconds).clamp(0.0, 1.0);
      double tween(double from, double to) => from + (to - from) * e;
      s
        ..torsoRx = tween(s.slumpFrom[0], _torsoSlumpX)
        ..torsoRz = tween(s.slumpFrom[1], _torsoSlumpZ)
        ..headRx = tween(s.slumpFrom[2], _headSlumpX)
        ..headRz = tween(s.slumpFrom[3], _headSlumpZ);
      return;
    }
    if (s.pressed) {
      s
        ..breath -= _drainPerSecond * dt
        ..timePassed += _timerPerSecond * dt;
      if (s.breath < _strainBelow) {
        final shiver = math.sin(s.time * _shiverRate) * _shiverAmp;
        s
          ..face = _Face.straining
          ..skin = _Colors.skinStrain
          ..torsoRz = shiver
          ..headRz = shiver;
      }
      if (s.breath <= 0) _faint();
    } else {
      s
        ..breath = math.min(100, s.breath + _refillPerSecond * dt)
        ..skin = _Colors.skin
        ..timePassed = 0
        ..torsoRz = 0
        ..headRz = 0
        ..breathe = math.sin(s.time * _breathRate) * _breathAmp;
    }
  }

  /// Scenario 2, every frame: the pinwheel (or, once shown, the turbine)
  /// turns with the wind speed and the wind lines blow across; the turbine
  /// scene appears when the pinwheel has shrunk away.
  void _windFrame(double dt) {
    final s = _scene;
    final spin = s.wind * _spinPerSecond * dt;
    if (s.showWindmill) {
      s.rotorAngle -= spin;
    } else {
      s.pinwheelAngle -= spin * _pinwheelFactor;
    }
    final gust = s.wind * _gustPerSecond * dt;
    for (final p in s.particles) {
      p.x += gust * p.speed;
      if (p.x > _particleHalfX) p.x = -_particleHalfX;
    }
    if (s.shrinkAt >= 0 &&
        !s.showWindmill &&
        s.time >= s.shrinkAt + _shrinkSeconds) {
      setState(() {
        s
          ..showWindmill = true
          ..growAt = s.shrinkAt + _shrinkSeconds;
      });
    }
  }

  // ------------------------------------------------------------ scenario 1

  /// HTML `startHolding`: 'Hold Breath' pressed. Step 1 moves on to step 2
  /// (and starts its clock), step 3 to step 4.
  void _startHolding() {
    final s = _scene;
    if (s.scenario != 0 || s.fainted || s.pressed || !_lab.isLabActive) {
      return;
    }
    setState(() {
      s.pressed = true;
      if (s.step == 1) {
        s
          ..step2At = s.time
          ..step = 2;
      } else if (s.step == 3) {
        s.step = 4;
      }
    });
    _Sound.breath.play();
  }

  /// HTML `stopHolding`: 'Hold Breath' let go before 0%. Ajji gasps for
  /// air (and turns calm again after 1 s); at step 2 the step moves on once
  /// the oxygen dropped to 75% or the button was held for 2.5 s, otherwise
  /// a toast asks to hold longer. (The HTML also ran this on releases that
  /// had not pressed the button.)
  void _stopHolding() {
    final s = _scene;
    if (s.scenario != 0 || s.fainted || !s.pressed) return;
    setState(() => s.pressed = false);
    if (s.breath <= 0 || s.breath >= 100) return;
    _Sound.pop.play();
    s
      ..face = _Face.gasping
      ..skin = _Colors.skin
      ..pulseAt = s.time;
    _lab.after(_calmAfter, () {
      if (!s.pressed && !s.fainted) s.face = _Face.calm;
    });
    if (s.step != 2) return;
    if (s.breath <= _advanceAtOrBelow || s.time - s.step2At >= _advanceAfter) {
      setState(() => s.step = 3);
    } else {
      _toast('toast_hold_longer');
    }
  }

  /// HTML `animate()` at 0% oxygen: Ajji faints (blue face, X eyes) and
  /// slumps; the breath controls give way to 'Observe Conclusion'.
  void _faint() {
    final s = _scene;
    setState(() {
      s
        ..breath = 0
        ..fainted = true
        ..pressed = false
        ..face = _Face.fainted
        ..skin = _Colors.skinFaint
        ..slumpAt = s.time
        ..slumpFrom = [s.torsoRx, s.torsoRz, s.headRx, s.headRz]
        ..conclusionShown = true
        ..controlsShown = false;
      // HTML: step 4 moves on to step 5. Held straight through from step 2
      // she faints as well; then the HUD moves on to step 5 too, to match
      // the 'Observe Conclusion' button that replaces the controls.
      if (s.step == 4 || s.step == 2) s.step = 5;
    });
    _Sound.pop.play();
    _toast('toast_faint');
  }

  // ------------------------------------------------------------ scenario 2

  /// HTML slider `input`: the wind speed; past 70% (step 1), 40% (step 2)
  /// or 80% (step 3) the step moves on after a short wait.
  void _onWind(double value) {
    final s = _scene;
    if (s.scenario != 1 || !s.windPanelShown) return;
    final v = value.roundToDouble();
    setState(() => s.wind = v);
    switch (s.step) {
      case 1 when v > _pinwheelAt:
        _wait(1, _pinwheelWait, _switchPhase);
      case 2 when v > _windmillAt:
        _wait(2, _windmillWait, () => setState(() => s.step = 3));
      case 3 when v > _powerAt:
        _wait(3, _powerWait, _powerHouse);
    }
  }

  /// Runs [then] after [wait] if scenario 2 is still at [step] (the HTML
  /// `setTimeout` with its `State.step` check).
  void _wait(int step, Duration wait, VoidCallback then) {
    if (_waitingStep == step) return;
    _waitingStep = step;
    _lab.after(wait, () {
      if (_waitingStep == step) _waitingStep = null;
      final s = _scene;
      if (!mounted || s.scenario != 1 || s.step != step) return;
      then();
    });
  }

  /// HTML `switchS2Phase()`: step 2; the pinwheel shrinks away and the
  /// turbine scene grows in; the slider goes back to 0.
  void _switchPhase() {
    final s = _scene;
    _Sound.wind.play();
    setState(() {
      s
        ..step = 2
        ..wind = 0
        ..shrinkAt = s.time;
    });
  }

  /// Step 3 → 4: the house is powered; the wind panel gives way to
  /// 'Observe Conclusion'.
  void _powerHouse() {
    final s = _scene;
    setState(() {
      s
        ..step = 4
        ..conclusionShown = true
        ..windPanelShown = false;
    });
    _Sound.success.play();
  }

  // ---------------------------------------------------------------- shared

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

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`.
  void _loadScenario(int index) {
    _lab
      ..cancelPending()
      ..hidePopup(sound: false);
    _waitingStep = null;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `triggerConclusion()`: Scenario 1's summary popup, or Scenario
  /// 2's success popup with confetti.
  void _observeConclusion() {
    final s = _scene;
    if (!s.conclusionShown || s.concluded) return;
    final index = s.scenario;
    setState(() {
      s
        ..conclusionShown = false
        ..concluded = true;
      if (index == 1) s.confettiAt = s.time;
    });
    _lab.completedScenarios.add(index);
    _lab.showPopup(() => _summary(index), sound: _Sound.success);
  }

  /// HTML `closeSummary(); changeScenario(2)`.
  void _nextScenario() {
    _lab.hidePopup(sound: false);
    _loadScenario(1);
  }

  /// The HTML `#summary-modal` (Scenario 1: "Scenario 1 Complete!", the
  /// summary and 'Next Scenario') and `#success-modal` (Scenario 2:
  /// "Mastery Achieved!" and 'Restart Entire Lab'). The HTML never showed
  /// Scenario 2's own summary; here it comes first in its popup.
  LabPopupContent _summary(int index) {
    final p = _lab.palette;
    final s = _uiScale;
    final n = index + 1;
    final card = _SummaryCard(
      icon: Icons.lightbulb,
      iconColor: _Colors.indigo400,
      title: labFormat(_t('sc_complete'), {'n': n}),
      heading: _t('s${n}_sum_title'),
      headingColor: index == 0 ? _Colors.emerald400 : _Colors.indigo400,
      body: _t('s${n}_summary'),
      palette: p,
      scale: s,
      fontScale: s * _lab.fontScale.clamp(0.9, 1.4),
    );
    if (index == 0) {
      return LabPopupContent(
        title: _lab.t('success'),
        extra: card,
        actions: [
          LabAction(
            label: _t('next_sc'),
            icon: Icons.arrow_forward,
            color: p.primary,
            foreground: p.onPrimary,
            sound: _Sound.scenario,
            onTap: _nextScenario,
          ),
        ],
      );
    }
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.emoji_events,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          SizedBox(height: 10 * s),
          _SummaryCard(
            icon: Icons.emoji_events,
            iconColor: _Colors.yellow400,
            title: _t('all_complete'),
            body: _t('all_complete_desc'),
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale.clamp(0.9, 1.4),
          ),
        ],
      ),
      actions: [
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

  // -------------------------------------------------------------------- UI

  /// Canvas HUD line for the current step (HTML `hud[State.step]`).
  String get _hud {
    final s = _scene;
    final n = s.scenario + 1;
    return _t('s${n}_hud_${s.step.clamp(1, _stepCounts[s.scenario])}');
  }

  /// 1-based step for the shell: the HTML step, then steps + 1 once the
  /// conclusion was opened.
  int get _shellStep =>
      _scene.concluded ? _stepCounts[_scene.scenario] + 1 : _scene.step;

  /// Screen-reader description of the scene (added).
  String get _sceneLabel => _t(
    _scene.scenario == 0
        ? 'scene_s1'
        : (_scene.showWindmill ? 'scene_s2_windmill' : 'scene_s2_pinwheel'),
  );

  /// 'Observe Conclusion' in the sidebar's action area (and the floating
  /// mission card); the canvas shows it too.
  List<LabAction> _actions() {
    if (!_scene.conclusionShown) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        highlight: true,
        silent: true,
        onTap: _observeConclusion,
      ),
    ];
  }

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
        final p = _lab.palette;
        final s = context.labScale;
        _uiScale = s;
        final scene = _scene;
        final data = _data;
        final step = _shellStep;
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch11a1-steps-${scene.scenario}-$step'),
            steps: data.steps,
            current: step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            taskLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            resultLabel: _t('observation'),
          ),
          overlays: _overlays(context, p, s),
          stage: _buildStage(),
        );
      },
    );
  }

  /// The HTML canvas panels: the Oxygen Level meter (top centre) and the
  /// breath timer with 'Hold Breath' (Scenario 1), the Wind Speed slider
  /// (Scenario 2) and the bouncing 'Observe Conclusion' button, all above
  /// the HUD at the bottom.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    final scene = _scene;
    final inset = labOverlayInsets(context, _lab);
    final bottom = inset.bottom + (_lab.isSidebarOpen ? _hudRoom * s : 0);
    final popupOpen = _lab.popup != null;
    return [
      if (scene.scenario == 0)
        Positioned(
          key: const ValueKey('ch11a1-oxygen'),
          top: inset.top + 2,
          left: inset.left,
          right: inset.right,
          child: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: _frame,
              builder: (context, _, _) => _OxygenPanel(
                level: scene.breath,
                label: _t('oxy_level'),
                palette: p,
                scale: s,
              ),
            ),
          ),
        ),
      if (scene.scenario == 0 && scene.controlsShown)
        Positioned(
          key: const ValueKey('ch11a1-breath'),
          bottom: bottom,
          left: inset.left,
          right: inset.right,
          child: Center(
            child: _BreathControls(
              frame: _frame,
              scene: scene,
              label: _t('hold_breath'),
              palette: p,
              scale: s,
              onDown: _startHolding,
              onUp: _stopHolding,
            ),
          ),
        ),
      if (scene.scenario == 1 && scene.windPanelShown)
        Positioned(
          key: const ValueKey('ch11a1-wind'),
          bottom: bottom,
          left: inset.left,
          right: inset.right,
          child: Center(
            child: _WindPanel(
              value: scene.wind,
              title: _t('wind_speed'),
              low: _t('low'),
              high: _t('high'),
              palette: p,
              scale: s,
              onChanged: _onWind,
            ),
          ),
        ),
      if (scene.conclusionShown && !popupOpen)
        Positioned(
          key: const ValueKey('ch11a1-conclude'),
          bottom: bottom + 8 * s,
          left: inset.left,
          right: inset.right,
          child: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: _frame,
              builder: (context, time, child) => Transform.translate(
                offset: Offset(0, _bounce(time) * 14 * s),
                child: child,
              ),
              child: _ConclusionButton(
                label: _t('btn_conclude'),
                scale: s,
                onTap: _observeConclusion,
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final fit = math.min(
          size.width / _design.width,
          size.height / _design.height,
        );
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        _free = _freeArea(context, size);
        // Canvas labels stay readable when the stage is scaled down.
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        return LabStage(
          designSize: _design,
          child: Semantics(
            image: true,
            label: _sceneLabel,
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  cache: _cache,
                  repaint: _frame,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  labelScale: labelScale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The part of the canvas (as stage design px) that no panel covers: the
  /// tool column, the floating mission card (sidebar collapsed), the
  /// oxygen meter, the HUD and the controls above it.
  Rect _freeArea(BuildContext context, Size canvas) {
    final s = context.labScale;
    final scene = _scene;
    final inset = labOverlayInsets(context, _lab);
    final top =
        inset.top +
        (scene.scenario == 0 ? _oxygenRoom : _labelRoom) * s +
        _edgeGap;
    final bottom =
        inset.bottom +
        (_lab.isSidebarOpen ? _hudRoom * s : 0) +
        (scene.scenario == 0 ? _holdRoom : _windRoom) * s +
        _edgeGap;
    final fit = _fit;
    final ox = (canvas.width - _design.width * fit) / 2;
    final oy = (canvas.height - _design.height * fit) / 2;
    var free = Rect.fromLTRB(
      inset.left,
      top,
      canvas.width - inset.right,
      canvas.height - bottom,
    );
    if (free.width < 60 || free.height < 60) free = Offset.zero & canvas;
    return Rect.fromLTRB(
      (free.left - ox) / fit,
      (free.top - oy) / fit,
      (free.right - ox) / fit,
      (free.bottom - oy) / fit,
    );
  }
}

/// Tailwind `animate-bounce`: up by a quarter of the height and back once
/// a second (-1 at the top, 0 at rest).
double _bounce(double time) {
  final phase = time % 1;
  if (phase < 0.5) {
    final u = phase / 0.5;
    return -(1 - u * u * u);
  }
  final u = (phase - 0.5) / 0.5;
  return -(1 - math.pow(1 - u, 3).toDouble());
}

// ============================================================ CANVAS PANELS

/// HTML `#ui-s1-container`: the lung icon, "Oxygen Level", the percentage
/// and the bar (emerald, amber below 60%, red below 30%).
class _OxygenPanel extends StatelessWidget {
  const _OxygenPanel({
    required this.level,
    required this.label,
    required this.palette,
    required this.scale,
  });

  /// Oxygen level, 0–100.
  final double level;
  final String label;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final colors = level < _lowBelow
        ? const [_Colors.red500, _Colors.red400]
        : (level < _medBelow
              ? const [_Colors.amber500, _Colors.amber400]
              : const [_Colors.emerald500, _Colors.emerald400]);
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    return SizedBox(
      width: 280 * s,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        borderColor: p.isDark
            ? const Color(0xCC334155)
            : const Color(0xCCE2E8F0),
        child: Row(
          children: [
            Container(
              width: 30 * s,
              height: 30 * s,
              padding: EdgeInsets.all(5 * s),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.isDark
                    ? _Colors.slate800
                    : _Colors.indigo500.withValues(alpha: 0.1),
                border: Border.all(
                  color: _Colors.indigo500.withValues(alpha: 0.2),
                ),
              ),
              child: const CustomPaint(painter: _IconPainter(_Icon.lungs)),
            ),
            SizedBox(width: 8 * s),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.textStrong,
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w900,
                            letterSpacing: labLetterSpacing(label, 0.8),
                          ),
                        ),
                      ),
                      SizedBox(width: 4 * s),
                      Text(
                        '${level.round()}%',
                        key: const ValueKey('ch11a1-oxygen-text'),
                        style: TextStyle(
                          color: indigo,
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3 * s),
                  Container(
                    height: 10 * s,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: p.isDark ? _Colors.slate700 : _Colors.slate300,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: p.isDark ? _Colors.slate900 : _Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (level / 100).clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(colors: colors),
                          ),
                        ),
                      ),
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

/// HTML `#ui-s1-controls`: the breath timer ("00:SS") and the 'Hold
/// Breath' button.
class _BreathControls extends StatelessWidget {
  const _BreathControls({
    required this.frame,
    required this.scene,
    required this.label,
    required this.palette,
    required this.scale,
    required this.onDown,
    required this.onUp,
  });

  final ValueListenable<double> frame;
  final _Scene scene;
  final String label;
  final LabPalette palette;
  final double scale;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return SizedBox(
      width: 330 * s,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
        borderColor: _Colors.indigo500.withValues(alpha: 0.4),
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        // Both halves scale down rather than overflow (long Hindi labels,
        // narrow canvases).
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ValueListenableBuilder<double>(
                  valueListenable: frame,
                  builder: (context, time, _) {
                    final secs = scene.timePassed.floor().toString().padLeft(
                      2,
                      '0',
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // animate-pulse on the timer icon.
                        Opacity(
                          opacity:
                              0.6 +
                              0.4 * (0.5 + 0.5 * math.cos(time * math.pi)),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 20 * s,
                            color: _Colors.indigo500,
                          ),
                        ),
                        SizedBox(width: 6 * s),
                        Text(
                          '00:$secs',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: p.textStrong,
                            fontSize: 17 * s,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 8 * s),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: _HoldButton(
                  label: label,
                  pressed: scene.pressed,
                  scale: s,
                  onDown: onDown,
                  onUp: onUp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HTML `#btn-hold-breath` (`.btn-hold`): pressing starts holding the
/// breath, letting go (anywhere) stops it. A pan recogniser keeps a finger
/// that wobbles from moving the card instead.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.pressed,
    required this.scale,
    required this.onDown,
    required this.onUp,
  });

  final String label;
  final bool pressed;
  final double scale;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => onDown(),
        onPointerUp: (_) => onUp(),
        onPointerCancel: (_) => onUp(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Center(
              widthFactor: 1,
              child: AnimatedScale(
                scale: pressed ? 0.95 : 1,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * s,
                    vertical: 8 * s,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: pressed
                          ? const [_Colors.indigo600, _Colors.indigo700]
                          : const [_Colors.indigo500, _Colors.indigo600],
                    ),
                    // border-b-2 border-indigo-700, gone while pressed.
                    border: pressed
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: _Colors.indigo700,
                              width: 2,
                            ),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: LabInk.black.withValues(
                          alpha: pressed ? 0.15 : 0.25,
                        ),
                        blurRadius: pressed ? 2 : 6,
                        offset: Offset(0, pressed ? 1 : 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.back_hand, size: 16 * s, color: _Colors.white),
                      SizedBox(width: 6 * s),
                      Text(
                        label,
                        style: TextStyle(
                          color: _Colors.white,
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w900,
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
    );
  }
}

/// HTML `#ui-s2-container`: the wind icon, "Wind Speed", the value chip
/// and the Low–High range slider.
class _WindPanel extends StatelessWidget {
  const _WindPanel({
    required this.value,
    required this.title,
    required this.low,
    required this.high,
    required this.palette,
    required this.scale,
    required this.onChanged,
  });

  final double value;
  final String title;
  final String low;
  final String high;
  final LabPalette palette;
  final double scale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    TextStyle end() => TextStyle(
      color: _Colors.slate400,
      fontSize: 9.5 * s,
      fontWeight: FontWeight.w800,
    );
    return SizedBox(
      width: 330 * s,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
        borderColor: _Colors.indigo500.withValues(alpha: 0.4),
        padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 2 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 20 * s,
                  height: 20 * s,
                  padding: EdgeInsets.all(2 * s),
                  decoration: BoxDecoration(
                    color: p.isDark
                        ? _Colors.slate800
                        : _Colors.indigo500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const CustomPaint(painter: _IconPainter(_Icon.wind)),
                ),
                SizedBox(width: 6 * s),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * s,
                    vertical: 2 * s,
                  ),
                  decoration: BoxDecoration(
                    color: _Colors.indigo500.withValues(
                      alpha: p.isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${value.round()}%',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: indigo,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(low.toUpperCase(), style: end()),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6 * s,
                      activeTrackColor: _Colors.indigo500,
                      inactiveTrackColor: p.isDark
                          ? _Colors.slate700
                          : _Colors.slate200,
                      thumbColor: _Colors.white,
                      overlayColor: _Colors.indigo500.withValues(alpha: 0.15),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 20 * s,
                      ),
                      thumbShape: _RingThumbShape(radius: 11 * s),
                    ),
                    child: Slider(
                      value: value.clamp(0, 100),
                      max: 100,
                      onChanged: onChanged,
                    ),
                  ),
                ),
                Text(high.toUpperCase(), style: end()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The HTML range thumb: a white disc with a 2 px indigo ring and a soft
/// shadow.
class _RingThumbShape extends SliderComponentShape {
  const _RingThumbShape({required this.radius});

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
    final canvas = context.canvas;
    canvas
      ..drawCircle(
        center.translate(0, 1.5),
        radius,
        Paint()
          ..color = LabInk.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(center, radius, Paint()..color = _Colors.white)
      ..drawCircle(
        center,
        radius - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _Colors.indigo500,
      );
  }
}

/// HTML `#compare-btn-container`: the blue-to-indigo 'Observe Conclusion'
/// button with its lightbulb.
class _ConclusionButton extends StatelessWidget {
  const _ConclusionButton({
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
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _Colors.white.withValues(alpha: 0.2), width: 2),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [_Colors.blue600, _Colors.indigo600],
        ),
        boxShadow: [
          BoxShadow(
            color: _Colors.blue600.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: LabInk.clear,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * s,
                vertical: 10 * s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb, size: 20 * s, color: _Colors.white),
                  SizedBox(width: 8 * s),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w900,
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

/// The body of the HTML summary / success modals: the round icon, the
/// title ("Scenario 1 Complete!"), the bold coloured heading and the text.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.palette,
    required this.scale,
    required this.fontScale,
    this.heading,
    this.headingColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? heading;
  final Color? headingColor;
  final String body;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = fontScale;
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 52 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.2),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, size: 26 * s, color: p.ink(iconColor)),
          ),
          SizedBox(height: 10 * s),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 19 * s,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          if (heading != null) ...[
            SizedBox(height: 8 * s),
            Text(
              heading!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(headingColor ?? p.accent),
                fontSize: 15 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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
        ],
      ),
    );
  }
}

// --------------------------------------------------------- steps accordion

/// HTML teacher board ("Observation Step"): one card per step with its
/// task (concept), action and result. The current step is open; any step
/// can be opened or closed (HTML `toggleAccordion`); done steps show a
/// tick.
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.taskLabel,
    required this.actionLabel,
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
  final String actionLabel;
  final String resultLabel;

  @override
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
  /// Steps the learner opened or closed.
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

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final open = _isOpen(i);
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    final tone = current ? indigo : (past ? p.info : p.textMuted);
    final border = current
        ? _Colors.indigo500
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: current
            ? (p.isDark
                  ? _Colors.slate800
                  : _Colors.indigo500.withValues(alpha: 0.1))
            : p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: current ? 1.5 : 1),
        boxShadow: current
            ? [
                BoxShadow(
                  color: _Colors.indigo500.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: LabInk.clear,
            child: InkWell(
              onTap: () {
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
                          color: past
                              ? p.success.withValues(alpha: 0.2)
                              : (current
                                    ? _Colors.indigo500
                                    : (p.isDark
                                          ? _Colors.slate800
                                          : _Colors.slate200)),
                          border: Border.all(
                            color: past
                                ? p.success.withValues(alpha: 0.4)
                                : (current
                                      ? _Colors.indigo400
                                      : _Colors.slate400),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.success)
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: current ? _Colors.white : p.textMuted,
                                  fontSize: 11 * s,
                                  fontWeight: FontWeight.w900,
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
                            color: tone,
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
                        color: tone.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open) _body(step, indigo),
        ],
      ),
    );
  }

  /// "TASK:" (indigo) with the concept, "Action:" and "Result:".
  Widget _body(LabStep step, Color indigo) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    TextSpan head(String label, Color color) => TextSpan(
      text: '$label: ',
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
    final text = TextStyle(
      color: p.text,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0x660F172A) : _Colors.slate50,
        border: Border(top: BorderSide(color: p.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${w.taskLabel.toUpperCase()}:',
            style: TextStyle(
              color: _Colors.indigo500,
              fontSize: 9.5 * f,
              fontWeight: FontWeight.w800,
              letterSpacing: labLetterSpacing(w.taskLabel, 0.8),
            ),
          ),
          SizedBox(height: 2 * s),
          Text(step.concept, style: text.copyWith(color: p.textStrong)),
          SizedBox(height: 6 * s),
          Text.rich(
            TextSpan(
              children: [
                head(w.actionLabel, p.textStrong),
                TextSpan(text: step.action),
              ],
            ),
            style: text,
          ),
          SizedBox(height: 6 * s),
          Text.rich(
            TextSpan(
              children: [
                head(w.resultLabel, p.textStrong),
                TextSpan(text: step.observation),
              ],
            ),
            style: text.copyWith(color: p.textMuted),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------- icons

/// The HTML's two inline SVG icons (24 × 24 viewBox, indigo and white
/// paths): the lungs of the Oxygen Level meter and the wind of the Wind
/// Speed panel.
enum _Icon {
  lungs([
    (
      _Colors.indigo500,
      'M12 2c-3.31 0-6 2.69-6 6v10c0 1.1.9 2 2 2h1c.55 0 1-.45 1-1v-3c0-.55-.45-1-1-1h-1c-.55 0-1-.45-1-1V8c0-2.21 1.79-4 4-4s4 1.79 4 4v6c0 .55-.45 1-1 1h-1c-.55 0-1 .45-1 1v3c0 .55.45 1 1 1h1c1.1 0 2-.9 2-2V8c0-3.31-2.69-6-6-6z',
    ),
    (
      _Colors.slate50,
      'M10 17h-1c-.55 0-1-.45-1-1V8c0-2.21 1.79-4 4-4s4 1.79 4 4v8c0 .55-.45 1-1 1h-1v-3c0-.55-.45-1-1-1h-2c-.55 0-1 .45-1 1v3z',
    ),
  ]),
  wind([
    (
      _Colors.indigo500,
      'M12 10.5c.83 0 1.5.67 1.5 1.5s-.67 1.5-1.5 1.5-1.5-.67-1.5-1.5.67-1.5 1.5-1.5zM12 2l.12 8.59L19.9 3.1c.45-.45 1.18-.45 1.63 0l.07.07c.45.45.45 1.18 0 1.63L13.41 12l7.2 7.2c.45.45.45 1.18 0 1.63l-.07.07c-.45.45-1.18.45-1.63 0L12.12 13.41 12 22c0 .66-.54 1.2-1.2 1.2h-.1c-.51 0-.96-.32-1.13-.78L2.1 12.12c-.22-.59.08-1.25.67-1.44l.11-.04L10.59 2.12c.46-.17.96-.01 1.26.38l.15.22L12 2z',
    ),
    (
      _Colors.slate50,
      'M12 10.59L4.1 3.1c-.45-.45-1.18-.45-1.63 0l-.07.07c-.45.45-.45 1.18 0 1.63L10.59 12l-8.2 8.2c-.45.45-.45 1.18 0 1.63l.07.07c.45.45 1.18.45 1.63 0L12 13.41V22c0 .66.54 1.2 1.2 1.2h.1c.51 0 .96-.32 1.13-.78l7.47-10.3c.22-.59-.08-1.25-.67-1.44l-.11-.04L13.41 2.12c-.46-.17-.96-.01-1.26.38l-.15.22L12 10.59z',
    ),
  ]);

  const _Icon(this.layers);

  /// Fill colour and SVG path data of each layer.
  final List<(Color, String)> layers;

  /// The parsed paths (in viewBox units), built once.
  List<(Color, Path)> get paths => _iconPaths[this] ??= [
    for (final (color, data) in layers) (color, _svgPath(data)),
  ];
}

final Map<_Icon, List<(Color, Path)>> _iconPaths = {};

/// Paints an [_Icon] scaled to its box.
class _IconPainter extends CustomPainter {
  const _IconPainter(this.icon);

  final _Icon icon;

  @override
  void paint(Canvas canvas, Size size) {
    final k = math.min(size.width, size.height) / 24;
    canvas
      ..save()
      ..translate((size.width - 24 * k) / 2, (size.height - 24 * k) / 2)
      ..scale(k);
    final paint = Paint();
    for (final (color, path) in icon.paths) {
      canvas.drawPath(path, paint..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) => old.icon != icon;
}

/// Parses SVG path data (M, L, H, V, C, S, Q, T, Z; absolute and
/// relative) into a [Path].
Path _svgPath(String data) {
  final tokens = RegExp(
    r'[MmLlHhVvCcSsQqTtZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?',
  ).allMatches(data).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  var ctrlX = 0.0, ctrlY = 0.0;
  var prev = '';
  bool isCommand(String t) => RegExp('^[A-Za-z]\$').hasMatch(t);
  double next() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (isCommand(tokens[i])) cmd = tokens[i++];
    final rel = cmd.toLowerCase() == cmd;
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + next();
        y = oy + next();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // Further pairs after a moveto are linetos.
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = ox + next();
        y = oy + next();
        path.lineTo(x, y);
      case 'H':
        x = ox + next();
        path.lineTo(x, y);
      case 'V':
        y = oy + next();
        path.lineTo(x, y);
      case 'C':
        final x1 = ox + next(), y1 = oy + next();
        ctrlX = ox + next();
        ctrlY = oy + next();
        x = ox + next();
        y = oy + next();
        path.cubicTo(x1, y1, ctrlX, ctrlY, x, y);
      case 'S':
        final smooth = prev == 'C' || prev == 'S';
        final x1 = smooth ? 2 * x - ctrlX : x;
        final y1 = smooth ? 2 * y - ctrlY : y;
        ctrlX = ox + next();
        ctrlY = oy + next();
        x = ox + next();
        y = oy + next();
        path.cubicTo(x1, y1, ctrlX, ctrlY, x, y);
      case 'Q':
        ctrlX = ox + next();
        ctrlY = oy + next();
        x = ox + next();
        y = oy + next();
        path.quadraticBezierTo(ctrlX, ctrlY, x, y);
      case 'T':
        final smooth = prev == 'Q' || prev == 'T';
        ctrlX = smooth ? 2 * x - ctrlX : x;
        ctrlY = smooth ? 2 * y - ctrlY : y;
        x = ox + next();
        y = oy + next();
        path.quadraticBezierTo(ctrlX, ctrlY, x, y);
      case 'Z':
        path.close();
        x = startX;
        y = startY;
    }
    prev = cmd.toUpperCase();
  }
  return path;
}

// ================================================================== PAINTING

/// HTML lights: `AmbientLight(0xffffff, 0.6)` and `DirectionalLight
/// (0xffffff, 1.0)` at (10, 30, 20).
const double _ambient = 0.6;
const double _keyPower = 1;
const _V _keyLight = _V(0.26726, 0.80178, 0.53452);

/// The key light's direction on screen (towards the upper right).
final Offset _lightOnScreen = () {
  final o = Offset(_keyLight.dot(_camR), -_keyLight.dot(_camU));
  return o / o.distance;
}();

/// Light falling on a surface beyond full strength is softened by this
/// factor (the HTML's 0.6 + 1.0 lights reach 1.6 and wash pale colours
/// such as the skin out to white).
const double _overLight = 0.5;

/// The light on a surface with normal [n]: ambient plus the key light's
/// Lambert term, softened above 1.
double _light(_V n) {
  final k = _ambient + _keyPower * math.max(0.0, n.dot(_keyLight));
  return k <= 1 ? k : 1 + (k - 1) * _overLight;
}

/// MeshStandardMaterial look: [c] under the [_light] on a surface with
/// normal [n]; colours clip at white, as in the HTML's linear output.
/// [emissive] (the glowing house) is added on top.
Color _lit(Color c, _V n, {Color? emissive}) {
  final k = _light(n);
  double channel(double v, double e) => math.min(1.0, v * k + e);
  return Color.from(
    alpha: c.a,
    red: channel(c.r, emissive?.r ?? 0),
    green: channel(c.g, emissive?.g ?? 0),
    blue: channel(c.b, emissive?.b ?? 0),
  );
}

/// Box faces: outward normal and the four corners, in units of the half
/// size.
const List<(_V, List<_V>)> _boxFaces = [
  (_V(1, 0, 0), [_V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1), _V(1, -1, 1)]),
  (_V(-1, 0, 0), [_V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, 1), _V(-1, 1, -1)]),
  (_V(0, 1, 0), [_V(-1, 1, -1), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1)]),
  (_V(0, -1, 0), [_V(-1, -1, -1), _V(1, -1, -1), _V(1, -1, 1), _V(-1, -1, 1)]),
  (_V(0, 0, 1), [_V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)]),
  (_V(0, 0, -1), [_V(-1, -1, -1), _V(-1, 1, -1), _V(1, 1, -1), _V(1, -1, -1)]),
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

/// Paints, the reused path and the cached pictures / text of the canvas.
/// Owned (and disposed) by the page State.
class _PaintCache {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Path path = Path();
  final Map<_Face, ui.Picture> _faces = {};
  final Map<String, TextPainter> _labels = {};

  /// Font size the sprite labels are laid out at (then scaled).
  static const double labelFont = 36;

  /// Ajji's face texture for [state], recorded once (1024 × 1024 px).
  ui.Picture face(_Face state) => _faces[state] ??= () {
    final recorder = ui.PictureRecorder();
    _paintFace(Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024)), state);
    return recorder.endRecording();
  }();

  /// A sprite label's text (bold 36 px, white).
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white,
        fontSize: labelFont,
        fontWeight: FontWeight.w800,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  void dispose() {
    for (final picture in _faces.values) {
      picture.dispose();
    }
    _faces.clear();
    for (final painter in _labels.values) {
      painter.dispose();
    }
    _labels.clear();
  }
}

/// HTML `createFaceTexture(state)`: Ajji's face on a 1024 px canvas,
/// clipped to a circle (r 480) so it blends onto the head: skin and
/// cheeks, parted silver hair, bindi, eyebrows, eyes, nose, mouth and, when
/// straining or fainted, sweat drops.
void _paintFace(Canvas c, _Face state) {
  final fill = Paint();
  final line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  void dot(double x, double y, double r, Color color) =>
      c.drawCircle(Offset(x, y), r, fill..color = color);
  void pen(Path p, Color color, double width) => c.drawPath(
    p,
    line
      ..color = color
      ..strokeWidth = width,
  );
  Path seg(double x0, double y0, double x1, double y1) => Path()
    ..moveTo(x0, y0)
    ..lineTo(x1, y1);
  Path arc(double x, double y, double r, double from, double to) => Path()
    ..addArc(Rect.fromCircle(center: Offset(x, y), radius: r), from, to - from);
  Path quad(double x0, double y0, double cx, double cy, double x1, double y1) =>
      Path()
        ..moveTo(x0, y0)
        ..quadraticBezierTo(cx, cy, x1, y1);
  const pi = math.pi;

  final (skin, blush) = switch (state) {
    _Face.straining => (_Colors.skinStrain, _Colors.blushStrain),
    _Face.fainted => (_Colors.skinFaint, _Colors.blushFaint),
    _ => (_Colors.skin, _Colors.blush),
  };

  c.save();
  c.clipPath(
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(512, 512), radius: 480)),
  );
  c.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), fill..color = skin);

  // Rosy / stressed cheeks.
  dot(280, 590, 85, blush);
  dot(744, 590, 85, blush);

  // Forehead hair, parted in the middle, with strands.
  c
    ..drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(1024, 0)
        ..lineTo(1024, 320)
        ..quadraticBezierTo(760, 240, 512, 190)
        ..quadraticBezierTo(264, 240, 0, 320)
        ..close(),
      fill..color = _Colors.hairDark,
    )
    ..drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(1024, 0)
        ..lineTo(1024, 290)
        ..quadraticBezierTo(760, 210, 512, 160)
        ..quadraticBezierTo(264, 210, 0, 290)
        ..close(),
      fill..color = _Colors.hair,
    );
  pen(seg(512, 0, 512, 180), _Colors.strand, 6);
  for (var i = 1; i <= 6; i++) {
    pen(
      quad(512, 60, 512 - i * 60.0, 140, 120 - i * 15.0, 300),
      _Colors.strand,
      6,
    );
    pen(
      quad(512, 60, 512 + i * 60.0, 140, 904 + i * 15.0, 300),
      _Colors.strand,
      6,
    );
  }

  // Red bindi with a yellow centre.
  dot(512, 330, 34, _Colors.bindi);
  dot(512, 330, 8, _Colors.bindiDot);

  // Eyebrows.
  switch (state) {
    case _Face.straining:
      pen(seg(250, 420, 430, 370), _Colors.ink, 22);
      pen(seg(774, 420, 594, 370), _Colors.ink, 22);
    case _Face.gasping:
      pen(arc(330, 400, 90, pi * 1.15, pi * 1.85), _Colors.ink, 22);
      pen(arc(694, 400, 90, pi * 1.15, pi * 1.85), _Colors.ink, 22);
    case _Face.fainted:
      pen(seg(250, 395, 430, 405), _Colors.ink, 22);
      pen(seg(774, 395, 594, 405), _Colors.ink, 22);
    case _Face.calm:
      pen(arc(330, 410, 95, pi * 1.15, pi * 1.85), _Colors.ink, 22);
      pen(arc(694, 410, 95, pi * 1.15, pi * 1.85), _Colors.ink, 22);
  }

  // Eyes.
  switch (state) {
    case _Face.fainted:
      // Dizzy X eyes.
      pen(seg(260, 440, 390, 540), _Colors.ink, 26);
      pen(seg(390, 440, 260, 540), _Colors.ink, 26);
      pen(seg(634, 440, 764, 540), _Colors.ink, 26);
      pen(seg(764, 440, 634, 540), _Colors.ink, 26);
    case _Face.straining:
      // Wide, stressed eyes with small pupils and under-eye lines.
      for (final x in const [325.0, 699.0]) {
        dot(x, 490, 85, _Colors.white);
        dot(x, 490, 32, _Colors.pupil);
        pen(arc(x, 490, 85, 0, 2 * pi), _Colors.ink, 14);
        pen(arc(x, 500, 105, 0.2, pi - 0.2), _Colors.strand, 8);
      }
    case _Face.gasping:
      // Wide-open, relieved eyes.
      for (final x in const [325.0, 699.0]) {
        dot(x, 480, 85, _Colors.white);
        dot(x, 480, 48, _Colors.iris);
        dot(x, 480, 26, _Colors.pupil);
        dot(x + 20, 460, 14, _Colors.white);
        pen(arc(x, 480, 85, 0, 2 * pi), _Colors.ink, 14);
      }
    case _Face.calm:
      // Serene closed eyes with soft lashes.
      for (final x in const [325.0, 699.0]) {
        pen(arc(x, 460, 85, pi * 0.15, pi * 0.85), _Colors.ink, 22);
        for (final dx in const [-60.0, 0.0, 60.0]) {
          pen(seg(x + dx, 520, x + dx + dx * 0.2, 545), _Colors.ink, 10);
        }
      }
  }

  // Nose bridge and nostrils (the second arc joins the first with a line,
  // as on the HTML canvas).
  pen(seg(512, 440, 512, 535), _Colors.nose, 6);
  pen(
    Path()
      ..addArc(
        Rect.fromCircle(center: const Offset(486, 548), radius: 16),
        0.3,
        pi - 0.6,
      )
      ..arcTo(
        Rect.fromCircle(center: const Offset(538, 548), radius: 16),
        0.3,
        pi - 0.6,
        false,
      ),
    _Colors.nose,
    6,
  );

  // Mouth.
  switch (state) {
    case _Face.gasping:
      // Large 'O' and the air rushing in from the sides.
      final o = Rect.fromCenter(
        center: const Offset(512, 730),
        width: 130,
        height: 200,
      );
      c.drawOval(o, fill..color = _Colors.mouth);
      pen(Path()..addOval(o), _Colors.lips, 18);
      pen(quad(180, 730, 300, 690, 420, 730), _Colors.air, 14);
      pen(quad(844, 730, 724, 690, 604, 730), _Colors.air, 14);
      pen(quad(230, 770, 320, 740, 430, 750), _Colors.air, 14);
      pen(quad(794, 770, 704, 740, 594, 750), _Colors.air, 14);
    case _Face.straining:
      // Clenched teeth.
      final teeth = RRect.fromLTRBR(
        430,
        700,
        594,
        756,
        const Radius.circular(16),
      );
      c.drawRRect(teeth, fill..color = _Colors.white);
      pen(Path()..addRRect(teeth), _Colors.ink, 14);
      pen(seg(430, 728, 594, 728), _Colors.ink, 14);
      for (var x = 460.0; x <= 564; x += 32) {
        pen(seg(x, 700, x, 756), _Colors.ink, 14);
      }
    case _Face.fainted:
      // Slack, open mouth.
      final slack = arc(512, 740, 60, 0, pi);
      c.drawPath(slack, fill..color = _Colors.slack);
      pen(slack, _Colors.ink, 16);
    case _Face.calm:
      // Serene, warm smile.
      pen(arc(512, 660, 110, pi * 0.15, pi * 0.85), _Colors.smile, 20);
      pen(arc(512, 665, 105, pi * 0.18, pi * 0.82), _Colors.lips, 14);
  }

  // Sweat drops.
  if (state == _Face.straining || state == _Face.fainted) {
    for (final (x, y, r) in const [
      (210.0, 390.0, 24.0),
      (814.0, 420.0, 26.0),
      (320.0, 310.0, 18.0),
      (710.0, 310.0, 20.0),
    ]) {
      dot(x, y, r, _Colors.sweat);
      c.drawPath(
        Path()
          ..moveTo(x, y - r * 1.5)
          ..lineTo(x - r * 0.8, y)
          ..lineTo(x + r * 0.8, y)
          ..close(),
        fill..color = _Colors.sweat,
      );
      dot(x - r * 0.3, y - r * 0.2, r * 0.3, _Colors.sweatShine);
    }
  }
  c.restore();
}

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;
  final List<(double, int, VoidCallback)> _queue = [];

  Paint get _fill => cache.fill..shader = null;
  Paint get _stroke => cache.stroke;

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
    final path = cache.path..reset();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  /// Fills the polygon [pts] with [color] and a hairline of the same
  /// colour, so neighbouring faces meet without a seam.
  void _face(List<Offset> pts, Color color) {
    final path = polygon(pts);
    canvas
      ..drawPath(path, _fill..color = color)
      ..drawPath(
        path,
        _stroke
          ..strokeWidth = 0.8
          ..color = color,
      );
  }

  // ---------------------------------------------------------- primitives

  /// A flat plane now (the village ground), clipped to the part in front
  /// of the camera.
  void ground(List<_V> corners, Color color) {
    final pts = _clipNear(corners, cam, _clipDepth);
    if (pts.length < 3) return;
    canvas.drawPath(
      polygon([for (final p in pts) cam.p(p)]),
      _fill..color = color,
    );
  }

  /// A shaded ellipse of radii [rx] × [ry] at [c], turned by [angle]: lit
  /// towards the key light, falling to the ambient colour at the far rim.
  void _blob(Offset c, double rx, double ry, double angle, Color color) {
    final ca = math.cos(-angle), sa = math.sin(-angle);
    final l = _lightOnScreen;
    final h = Offset(l.dx * ca - l.dy * sa, l.dx * sa + l.dy * ca) * 0.45;
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle)
      ..scale(math.max(0.01, rx), math.max(0.01, ry));
    final paint = cache.fill
      ..shader = ui.Gradient.radial(
        h,
        1.45,
        [
          _lit(color, _keyLight),
          _lit(color, -_camF),
          Color.lerp(
            _lit(color, -_camF),
            _lit(color, const _V(0, -1, 0)),
            0.8,
          )!,
        ],
        const [0, 0.45, 1],
      );
    canvas
      ..drawCircle(Offset.zero, 1, paint)
      ..restore();
    cache.fill.shader = null;
  }

  /// An ellipsoid at [c] with semi-axes [a], [b], [d] as the camera sees
  /// it: the projected axes' ellipse (eigen-decomposition of Σ q qᵀ).
  void _ellipsoid(_V c, _V a, _V b, _V d, Color color) {
    final pa = cam.dp(c, a), pb = cam.dp(c, b), pd = cam.dp(c, d);
    final m00 = pa.dx * pa.dx + pb.dx * pb.dx + pd.dx * pd.dx;
    final m01 = pa.dx * pa.dy + pb.dx * pb.dy + pd.dx * pd.dy;
    final m11 = pa.dy * pa.dy + pb.dy * pb.dy + pd.dy * pd.dy;
    final mean = (m00 + m11) / 2;
    final spread = math.sqrt(
      math.max(0.0, (m00 - m11) * (m00 - m11) / 4 + m01 * m01),
    );
    _blob(
      cam.p(c),
      math.sqrt(mean + spread),
      math.sqrt(math.max(0.0, mean - spread)),
      0.5 * math.atan2(2 * m01, m00 - m11),
      color,
    );
  }

  /// SphereGeometry of radius [r] in the frame [xf] (its axes carry the
  /// mesh scale).
  void sphere(_Xf xf, double r, Color color, {double bias = 0}) {
    final depth = cam.depth(xf.o);
    if (depth - r < _clipDepth) return;
    later(
      depth + bias,
      () => _ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color),
    );
  }

  /// The top of a SphereGeometry (polar angle 0…[thetaLength]): the hair
  /// cap and the hill. Its outline is the hull of its projected points; it
  /// is shaded from its top to the front of its rim.
  void cap(
    _Xf xf,
    double r,
    double thetaLength,
    Color color, {
    double bias = 0,
  }) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    later(depth + bias, () {
      const rings = 8, around = 32;
      final pts = <Offset>[cam.p(xf(0, r, 0))];
      for (var i = 1; i <= rings; i++) {
        final th = thetaLength * i / rings;
        for (var j = 0; j < around; j++) {
          final ph = 2 * math.pi * j / around;
          pts.add(
            cam.p(
              xf(
                -r * math.cos(ph) * math.sin(th),
                r * math.cos(th),
                r * math.sin(ph) * math.sin(th),
              ),
            ),
          );
        }
      }
      final rim = _V(0, math.cos(thetaLength), math.sin(thetaLength));
      final top = cam.p(xf(0, r, 0));
      final front = cam.p(xf.at(rim * r));
      final paint = cache.fill
        ..shader = ui.Gradient.linear(
          top,
          front == top ? top + const Offset(0, 1) : front,
          [_lit(color, xf.normal(_V.up)), _lit(color, xf.normal(rim))],
        );
      canvas.drawPath(polygon(_hull(pts)), paint);
      cache.fill.shader = null;
    });
  }

  /// CylinderGeometry([rTop], [rBottom], [h], segments, openEnded,
  /// [thetaStart], [thetaLength]) centred on [xf], its axis along the
  /// frame's y. The side faces turned to the camera are filled, shaded
  /// across the side; then the end cap turned to the camera.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 24,
    double thetaStart = 0,
    double thetaLength = 2 * math.pi,
    bool openEnded = false,
    double bias = 0,
    Color? emissive,
  }) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    later(
      depth + bias,
      () => _cylinderNow(
        xf,
        rTop,
        rBottom,
        h,
        color,
        segments,
        thetaStart,
        thetaLength,
        openEnded,
        emissive,
      ),
    );
  }

  void _cylinderNow(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color,
    int segments,
    double thetaStart,
    double thetaLength,
    bool openEnded,
    Color? emissive,
  ) {
    final full = thetaLength >= 2 * math.pi - 1e-6;
    final n = full
        ? segments
        : math.max(2, (segments * thetaLength / (2 * math.pi)).ceil());
    final hh = h / 2;
    final pc = cam.p(xf.o);
    final along = cam.p(xf(0, hh, 0)) - cam.p(xf(0, -hh, 0));
    final len = along.distance;
    final perp = len < 1e-3
        ? const Offset(1, 0)
        : Offset(-along.dy / len, along.dx / len);
    final top = <Offset>[], bottom = <Offset>[];
    final across = <double>[], shades = <Color>[], facing = <bool>[];
    for (var i = 0; i <= n; i++) {
      final th = thetaStart + thetaLength * i / n;
      final sx = math.sin(th), cz = math.cos(th);
      final t = xf(rTop * sx, hh, rTop * cz);
      final b = xf(rBottom * sx, -hh, rBottom * cz);
      final pt = cam.p(t), pb = cam.p(b);
      top.add(pt);
      bottom.add(pb);
      final normal = xf.normal(_V(sx * h, rBottom - rTop, cz * h));
      facing.add(normal.dot(cam.eye - (t + b) * 0.5) > 0);
      shades.add(_lit(color, normal, emissive: emissive));
      final m = (pt + pb) / 2 - pc;
      across.add(m.dx * perp.dx + m.dy * perp.dy);
    }
    bool visible(int k) => facing[k] || facing[k + 1];
    // Runs of visible side segments: (first segment, count).
    final runs = <(int, int)>[];
    if (full) {
      final start = [
        for (var k = 0; k < n; k++) k,
      ].firstWhere((k) => !visible(k), orElse: () => -1);
      if (start < 0) {
        runs.add((0, n));
      } else {
        var k = 0;
        while (k < n) {
          final first = (start + 1 + k) % n;
          if (!visible(first)) {
            k++;
            continue;
          }
          var count = 0;
          while (k < n && visible((start + 1 + k) % n)) {
            count++;
            k++;
          }
          runs.add((first, count));
        }
      }
    } else {
      var k = 0;
      while (k < n) {
        if (!visible(k)) {
          k++;
          continue;
        }
        final first = k;
        while (k < n && visible(k)) {
          k++;
        }
        runs.add((first, k - first));
      }
    }
    for (final (first, count) in runs) {
      final idx = [
        for (var j = 0; j <= count; j++) full ? (first + j) % n : first + j,
      ];
      final pts = [
        for (final i in idx) top[i],
        for (final i in idx.reversed) bottom[i],
      ];
      final stops = [for (final i in idx) (across[i], shades[i])]
        ..sort((a, b) => a.$1.compareTo(b.$1));
      final lo = stops.first.$1, hi = stops.last.$1;
      if (hi - lo < 0.5) {
        _face(pts, shades[idx[idx.length ~/ 2]]);
        continue;
      }
      final paint = cache.fill
        ..shader = ui.Gradient.linear(
          pc + perp * lo,
          pc + perp * hi,
          [for (final s in stops) s.$2],
          [for (final s in stops) (s.$1 - lo) / (hi - lo)],
        );
      canvas.drawPath(polygon(pts), paint);
      cache.fill.shader = null;
    }
    if (!full || openEnded) return;
    final axis = xf.normal(_V.up);
    if (rTop > 1e-4 && axis.dot(cam.eye - xf(0, hh, 0)) > 0) {
      _face(top.sublist(0, n), _lit(color, axis, emissive: emissive));
    } else if (rBottom > 1e-4 && (-axis).dot(cam.eye - xf(0, -hh, 0)) > 0) {
      _face(bottom.sublist(0, n), _lit(color, -axis, emissive: emissive));
    }
  }

  /// BoxGeometry of [size] centred on [xf]: the faces turned to the
  /// camera, lit by the key light.
  void box(_Xf xf, _V size, Color color, {double bias = 0, Color? emissive}) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    later(depth + bias, () {
      for (final (n, corners) in _boxFaces) {
        final normal = xf.normal(n);
        if (normal.dot(cam.eye - xf(n.x * hx, n.y * hy, n.z * hz)) <= 0) {
          continue;
        }
        _face([
          for (final k in corners) cam.p(xf(k.x * hx, k.y * hy, k.z * hz)),
        ], _lit(color, normal, emissive: emissive));
      }
    });
  }

  /// PlaneGeometry([w], [h]) in the frame's xy plane, seen from the front
  /// only (doors, windows).
  void plane(
    _Xf xf,
    double w,
    double h,
    Color color, {
    double bias = 0,
    Color? emissive,
  }) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    final normal = xf.normal(const _V(0, 0, 1));
    if (normal.dot(cam.eye - xf.o) <= 0) return;
    later(depth + bias, () {
      _face([
        cam.p(xf(-w / 2, -h / 2, 0)),
        cam.p(xf(w / 2, -h / 2, 0)),
        cam.p(xf(w / 2, h / 2, 0)),
        cam.p(xf(-w / 2, h / 2, 0)),
      ], _lit(color, normal, emissive: emissive));
    });
  }

  /// A flat, double-sided ShapeGeometry with the corners [local] in the
  /// frame's xy plane (the pinwheel blades).
  void shape(_Xf xf, List<_V> local, Color color, {double bias = 0}) {
    final world = [for (final p in local) xf.at(p)];
    final centre = world.reduce((a, b) => a + b) * (1 / world.length);
    final depth = cam.depth(centre);
    if (depth < _clipDepth) return;
    var normal = xf.normal(const _V(0, 0, 1));
    if (normal.dot(cam.eye - centre) < 0) normal = -normal;
    later(depth + bias, () {
      _face([for (final w in world) cam.p(w)], _lit(color, normal));
    });
  }

  /// ConeGeometry([r], [h], [sides]) on [xf]: the four-sided roofs and
  /// the jhumka earrings.
  void cone(
    _Xf xf,
    double r,
    double h,
    int sides,
    Color color, {
    double bias = 0,
  }) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    later(depth + bias, () {
      final hh = h / 2;
      final apex = xf(0, hh, 0);
      final base = [
        for (var i = 0; i < sides; i++)
          xf(
            r * math.sin(i * 2 * math.pi / sides),
            -hh,
            r * math.cos(i * 2 * math.pi / sides),
          ),
      ];
      final mid = xf.o;
      for (var i = 0; i < sides; i++) {
        final a = base[i], b = base[(i + 1) % sides];
        var normal = (a - apex).cross(b - apex).unit;
        final centre = (apex + a + b) * (1 / 3);
        if (normal.dot(centre - mid) < 0) normal = -normal;
        if (normal.dot(cam.eye - centre) <= 0) continue;
        _face([cam.p(apex), cam.p(a), cam.p(b)], _lit(color, normal));
      }
      final down = -xf.normal(_V.up);
      if (down.dot(cam.eye - xf(0, -hh, 0)) > 0) {
        _face([for (final v in base) cam.p(v)], _lit(color, down));
      }
    });
  }

  /// TorusGeometry([radius], [tube]) in the frame's xy plane (bangles,
  /// the necklace, the gajra): its far half, then its near half, as thick
  /// round strokes.
  void torus(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double bias = 0,
  }) {
    final depth = cam.depth(xf.o);
    if (depth < _clipDepth) return;
    const n = 28;
    final pts = [
      for (var i = 0; i <= n; i++)
        xf(
          radius * math.cos(i * 2 * math.pi / n),
          radius * math.sin(i * 2 * math.pi / n),
          0,
        ),
    ];
    final scale = xf.x.length;
    void half({required bool far}) {
      final path = Path();
      var open = false;
      for (var i = 0; i < n; i++) {
        if ((cam.depth((pts[i] + pts[i + 1]) * 0.5) > depth) != far) {
          open = false;
          continue;
        }
        final a = cam.p(pts[i]), b = cam.p(pts[i + 1]);
        if (!open) path.moveTo(a.dx, a.dy);
        path.lineTo(b.dx, b.dy);
        open = true;
      }
      final width = math.max(1.0, 2 * tube * scale * cam.scaleAt(xf.o));
      final body = _lit(color, -_camF);
      canvas.drawPath(
        path,
        _stroke
          ..strokeWidth = width
          ..color = far ? labShade(body, -0.3) : body,
      );
      if (!far && width > 3) {
        canvas.drawPath(
          path.shift(Offset(0, -width * 0.18)),
          _stroke
            ..strokeWidth = width * 0.3
            ..color = labShade(body, 0.35),
        );
      }
    }

    later(depth + radius * scale * 0.5 + bias, () => half(far: true));
    later(depth - radius * scale * 0.5 + bias, () => half(far: false));
  }

  /// TubeGeometry of radius [r] along [pts] (the power lines).
  void tube(
    _Xf xf,
    List<_V> pts,
    double r,
    Color color, {
    double bias = 0,
    Color? emissive,
  }) {
    final world = [for (final p in pts) xf.at(p)];
    final mid = world[world.length ~/ 2];
    final depth = cam.depth(mid);
    if (depth < _clipDepth) return;
    later(depth + bias, () {
      final path = Path();
      for (var i = 0; i < world.length; i++) {
        final o = cam.p(world[i]);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(
        path,
        _stroke
          ..strokeWidth = math.max(1.0, 2 * r * xf.x.length * cam.scaleAt(mid))
          ..color = _lit(color, -_camF, emissive: emissive),
      );
    });
  }

  /// A thin unlit box from [a] to [b] ([thickness] world units wide): the
  /// wind lines.
  void streak(_V a, _V b, double thickness, Color color) {
    final mid = (a + b) * 0.5;
    final depth = cam.depth(mid);
    if (depth < _clipDepth) return;
    later(depth, () {
      canvas.drawLine(
        cam.p(a),
        cam.p(b),
        _stroke
          ..strokeWidth = math.max(1.0, thickness * cam.scaleAt(mid))
          ..color = color,
      );
    });
  }

  /// Ajji's face plane (6.4 × 6.4 at (0, 2, 3.32) in the head) with the
  /// [state] texture, mapped onto the plane's projected corners and lit
  /// like the head.
  void face(_Xf head, _Face state) {
    final centre = head(0, 2, 3.32);
    final depth = cam.depth(centre);
    if (depth < _clipDepth) return;
    final normal = head.normal(const _V(0, 0, 1));
    if (normal.dot((cam.eye - centre).unit) < 0.05) return;
    later(depth, () {
      final tl = cam.p(head(-3.2, 5.2, 3.32));
      final tr = cam.p(head(3.2, 5.2, 3.32));
      final bl = cam.p(head(-3.2, -1.2, 3.32));
      final u = (tr - tl) / 1024, v = (bl - tl) / 1024;
      final k = _light(normal);
      canvas
        ..save()
        ..transform(
          Float64List.fromList([
            u.dx, u.dy, 0, 0, //
            v.dx, v.dy, 0, 0, //
            0, 0, 1, 0, //
            tl.dx, tl.dy, 0, 1,
          ]),
        )
        ..saveLayer(
          const Rect.fromLTWH(0, 0, 1024, 1024),
          Paint()
            ..colorFilter = ColorFilter.matrix([
              k, 0, 0, 0, 0, //
              0, k, 0, 0, 0, //
              0, 0, k, 0, 0, //
              0, 0, 0, 1, 0,
            ]),
        )
        ..drawPicture(cache.face(state))
        ..restore()
        ..restore();
    });
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the village
/// and Ajji on her mat; S2 the wind lines with the pinwheel or the wind
/// turbine, its house and power lines; then the sprite labels and the
/// confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final g = _Gfx(canvas, s.framing.cam, cache);
    canvas.drawRect(
      labBleed(size),
      cache.fill
        ..shader = null
        ..color = s.scenario == 0 ? _Colors.sky : _Colors.night,
    );
    if (s.scenario == 0) {
      _village(g);
      _ajji(g);
    } else {
      _windLines(g);
      if (s.showWindmill) {
        _turbine(g);
      } else {
        _pinwheel(g);
      }
    }
    g.flush();
    if (showLabels) _labels(g);
    _confetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  /// HTML `buildVillageBackground()`: the grass (160 × 160 at y −4), three
  /// cream houses with terracotta roofs, doors and windows, and five
  /// trees.
  void _village(_Gfx g) {
    g.ground(const [
      _V(-80, -4, -80),
      _V(80, -4, -80),
      _V(80, -4, 80),
      _V(-80, -4, 80),
    ], _lit(_Colors.grass, _V.up));
    for (final at in const [
      _V(-24, 0.5, -24),
      _V(24, 0.5, -28),
      _V(0, 0.5, -38),
    ]) {
      final house = _Xf.at(at);
      g
        ..box(house, const _V(14, 9, 12), _Colors.wall)
        ..cone(
          house.child(const _V(0, 7.5, 0), ry: math.pi / 4),
          11,
          6,
          4,
          _Colors.tiles,
        )
        ..plane(house.child(const _V(0, -1.5, 6.02)), 3, 6, _Colors.door)
        ..plane(house.child(const _V(-4, 0.5, 6.02)), 2.2, 2.5, _Colors.pane)
        ..plane(house.child(const _V(4, 0.5, 6.02)), 2.2, 2.5, _Colors.pane);
    }
    for (final at in const [
      _V(-35, -1, -16),
      _V(35, -1, -20),
      _V(-18, -1, -34),
      _V(28, -1, -12),
      _V(-12, -1, -18),
    ]) {
      final trunk = _Xf.at(at);
      g
        ..cylinder(trunk, 0.9, 1.4, 6, _Colors.trunk, segments: 10)
        ..sphere(trunk.child(const _V(0, 4.5, 0)), 4.8, _Colors.leaves);
    }
  }

  /// HTML `buildAjji()`: the mat; the crossed legs in the orange saree
  /// (thighs, knees, shins, pleats with the gold border, bare feet); the
  /// torso (blue blouse, saree pallu with its gold trim, arms in Dhyana
  /// Mudra with gold bangles); the head (neck, necklace, silver hair with a
  /// bun and jasmine gajra, jhumkas) and the face texture. The torso and
  /// head breathe, shiver and slump; the skin changes colour.
  void _ajji(_Gfx g) {
    final s = scene;
    final b = s.breathe;
    final skin = s.skin;
    final group = _Xf.at(const _V(0, -4, 0)).scaled(s.ajjiScale);
    final legs = group.child(const _V(0, 2, 0));
    final torso = group.child(
      _V(0, 5.2 + b * 0.5, 0),
      rx: s.torsoRx,
      rz: s.torsoRz,
      sy: 1 + b * 0.03,
    );
    final head = group.child(
      _V(0, 10.8 + b * 0.7, 0),
      rx: s.headRx,
      rz: s.headRz,
    );
    const pi = math.pi;

    // Meditation mat on the grass (drawn under everything of Ajji's).
    g.cylinder(
      group.child(const _V(0, 0.2, 0)),
      8.5,
      9,
      0.4,
      _Colors.mat,
      segments: 40,
      bias: 5,
    );

    // Padmasana legs.
    g
      ..cylinder(
        legs.child(const _V(-3.2, 0.6, 0.5), rz: pi / 2.6, ry: pi / 8),
        2.4,
        2.6,
        7.5,
        _Colors.saree,
      )
      ..cylinder(
        legs.child(const _V(3.2, 0.6, 0.5), rz: -pi / 2.6, ry: -pi / 8),
        2.4,
        2.6,
        7.5,
        _Colors.saree,
      )
      ..sphere(legs.child(const _V(-6.2, 0.6, 1.6)), 2.4, _Colors.saree)
      ..sphere(legs.child(const _V(6.2, 0.6, 1.6)), 2.4, _Colors.saree)
      ..cylinder(
        legs.child(const _V(-2.8, 0.4, 2.4), rz: -pi / 2.3, rx: pi / 10),
        2,
        2.2,
        6.5,
        _Colors.saree,
      )
      ..cylinder(
        legs.child(const _V(2.8, 0.4, 2.4), rz: pi / 2.3, rx: pi / 10),
        2,
        2.2,
        6.5,
        _Colors.saree,
      )
      ..box(
        legs.child(const _V(0, 0.6, 2.6)),
        const _V(4.5, 3.2, 3.8),
        _Colors.saree,
      )
      ..box(
        legs.child(const _V(0, -0.7, 2.65)),
        const _V(4.6, 0.6, 3.9),
        _Colors.sareeBorder,
        bias: -0.01,
      );
    for (final side in const [1.0, -1.0]) {
      g.sphere(
        legs.child(
          _V(2.2 * side, 1.2, 3.1),
          ry: -side * pi / 6,
          sx: 1.4,
          sy: 0.7,
          sz: 1.8,
        ),
        1.2,
        skin,
      );
    }

    // Torso: blouse, pallu over the shoulder and its gold trim.
    final chest = torso.child(const _V(0, 2.8, 0));
    final pallu = torso.child(const _V(0, 2.8, 0), ry: pi / 5);
    g
      ..cylinder(chest, 2.6, 3.4, 5.6, _Colors.blouse, segments: 32)
      ..cylinder(
        pallu,
        2.7,
        3.5,
        5.7,
        _Colors.saree,
        segments: 32,
        thetaLength: pi * 1.3,
        openEnded: true,
        bias: -0.001,
      )
      ..cylinder(
        pallu,
        2.75,
        3.55,
        5.75,
        _Colors.sareeBorder,
        segments: 32,
        thetaLength: 0.3,
        openEnded: true,
        bias: -0.002,
      );

    // Arms in Dhyana Mudra: shoulder, sleeve, forearm, three bangles, hand
    // resting on the knee (left side first, as in the HTML).
    for (final side in const [-1.0, 1.0]) {
      g
        ..sphere(torso.child(_V(3.2 * side, 4.6, 0)), 1.4, _Colors.blouse)
        ..cylinder(
          torso.child(
            _V(3.9 * side, 3.6, 0.5),
            rz: -side * pi / 6,
            rx: -pi / 10,
          ),
          1.3,
          1.2,
          2.4,
          _Colors.blouse,
          segments: 16,
        )
        ..cylinder(
          torso.child(
            _V(4.8 * side, 1.2, 1.8),
            rz: -side * pi / 8,
            rx: -pi / 5,
          ),
          0.95,
          0.75,
          5,
          skin,
          segments: 16,
        );
      for (var i = 0; i < 3; i++) {
        g.torus(
          torso.child(
            _V(side * (5.2 - i * 0.15), 0.2 - i * 0.2, 2.6 + i * 0.2),
            rx: pi / 2.5,
          ),
          0.85,
          0.1,
          _Colors.gold,
        );
      }
      g.sphere(
        torso.child(_V(5.5 * side, -0.6, 3.4), sx: 1.2, sy: 0.6, sz: 1.4),
        0.85,
        skin,
      );
    }

    // Head: neck and necklace (inside the blouse's neckline, drawn before
    // the torso), head, silver hair cap, bun with gajra, jhumkas, face.
    g
      ..cylinder(
        head.child(const _V(0, -0.6, 0)),
        1.1,
        1.4,
        2.2,
        skin,
        segments: 16,
        bias: 1,
      )
      ..torus(
        head.child(const _V(0, -1.2, 0), rx: pi / 2.2),
        1.4,
        0.12,
        _Colors.gold,
        bias: 1,
      )
      ..sphere(head.child(const _V(0, 2, 0)), 3.3, skin)
      ..cap(head.child(const _V(0, 2.05, 0)), 3.4, pi / 1.7, _Colors.hair)
      ..sphere(head.child(const _V(0, 3.2, -3.2)), 1.6, _Colors.hair)
      ..torus(
        head.child(const _V(0, 3.2, -2.6), rx: pi / 4),
        1.5,
        0.38,
        _Colors.gajra,
      )
      ..cone(head.child(const _V(-3.4, 1.2, 0)), 0.5, 0.8, 16, _Colors.gold)
      ..cone(head.child(const _V(3.4, 1.2, 0)), 0.5, 0.8, 16, _Colors.gold)
      ..face(head, s.face);
  }

  // ---------------------------------------------------------- scenario 2

  /// HTML `createWindParticles()`: 40 thin white boxes (6 long, 40%
  /// opaque) blowing along +x.
  void _windLines(_Gfx g) {
    final color = _Colors.white.withValues(alpha: 0.4);
    for (final p in scene.particles) {
      g.streak(_V(p.x - 3, p.y, p.z), _V(p.x + 3, p.y, p.z), 0.15, color);
    }
  }

  /// HTML `buildPinwheel()`: the stick, the white hub and the four paper
  /// blades (red, blue, yellow, purple), which spin with the wind; it
  /// shrinks away when the scene changes.
  void _pinwheel(_Gfx g) {
    final s = scene;
    final k = s.pinwheelScale;
    if (k <= 0) return;
    final group = const _Xf.at(_V.zero).scaled(k);
    g
      ..cylinder(
        group.child(const _V(0, -0.5, 0)),
        0.3,
        0.3,
        16,
        _Colors.stick,
        segments: 12,
      )
      ..cylinder(
        group.child(const _V(0, 7.5, 0), rx: math.pi / 2),
        0.6,
        0.6,
        1.5,
        _Colors.white,
        segments: 16,
      );
    final blades = group.child(const _V(0, 7.5, 0.8), rz: s.pinwheelAngle);
    for (var i = 0; i < 4; i++) {
      g.shape(blades.child(_V.zero, rz: i * math.pi / 2), const [
        _V.zero,
        _V(4, 4, 0),
        _V(0, 4, 0),
      ], _Colors.blades[i]);
    }
  }

  /// HTML `buildWindmillScene()`: the green hill, the tower, nacelle and
  /// three-bladed rotor, the house with its two windows, the two poles and
  /// the two power lines; windows, poles and lines glow yellow when the
  /// house is powered. The scene grows in with an elastic bounce.
  void _turbine(_Gfx g) {
    final s = scene;
    final (k, y) = s.windmillGrowth;
    final scene2 = _Xf.at(_V(0, y, 0)).scaled(k);
    final glow = s.powered ? _Colors.power : null;
    g
      ..cap(
        scene2.child(const _V(0, -38, 0)),
        40,
        math.pi / 4,
        _Colors.grass,
        bias: 50,
      )
      ..cylinder(
        scene2.child(const _V(-12, 8, 0)),
        1.5,
        3.5,
        20,
        _Colors.tower,
        bias: 2,
      )
      ..box(
        scene2.child(const _V(-12, 18, 0)),
        const _V(2.5, 2.5, 5),
        _Colors.nacelle,
        bias: 1,
      );
    final rotor = scene2.child(const _V(-12, 18, 2.7), rz: s.rotorAngle);
    for (var i = 0; i < 3; i++) {
      g.box(
        rotor.child(_V.zero, rz: i * 2 * math.pi / 3).child(const _V(0, 8, 0)),
        const _V(1.5, 16, 0.3),
        _Colors.rotorBlade,
      );
    }
    g.sphere(rotor, 1.5, _Colors.rotorHub, bias: -5);

    final house = scene2.child(const _V(12, 1, 5));
    g
      ..box(house.child(const _V(0, 4, 0)), const _V(10, 8, 8), _Colors.house)
      ..cone(
        house.child(const _V(0, 10.5, 0), ry: math.pi / 4),
        8,
        5,
        4,
        _Colors.houseRoof,
      )
      ..plane(
        house.child(const _V(-2.5, 5, 4.01)),
        2,
        2,
        _Colors.dark,
        emissive: glow,
      )
      ..plane(
        house.child(const _V(2.5, 5, 4.01)),
        2,
        2,
        _Colors.dark,
        emissive: glow,
      )
      ..cylinder(
        scene2.child(const _V(-4, 2, 2)),
        0.3,
        0.3,
        8,
        _Colors.wire,
        segments: 10,
        emissive: glow,
      )
      ..cylinder(
        scene2.child(const _V(4, 2, 3)),
        0.3,
        0.3,
        8,
        _Colors.wire,
        segments: 10,
        emissive: glow,
      );
    for (final line in _powerLines) {
      g.tube(scene2, line, 0.15, _Colors.wire, emissive: glow);
    }
  }

  // -------------------------------------------------------------- labels

  /// HTML `createTextSprite()`: the Ajji, Firki and Windmill labels
  /// (6 × 1.5 world units, scaled with their groups).
  void _labels(_Gfx g) {
    final s = scene;
    if (s.scenario == 0) {
      final scale = s.ajjiScale;
      final head = _Xf.at(const _V(0, -4, 0))
          .scaled(scale)
          .child(_V(0, 10.8 + s.breathe * 0.7, 0), rx: s.headRx, rz: s.headRz);
      _sprite(g, head(0, 8.5, 0), scale, _t('lbl_ajji'));
    } else if (s.showWindmill) {
      final (k, y) = s.windmillGrowth;
      _sprite(g, _V(-12 * k, y + 22 * k, 0), k, _t('lbl_windmill'));
    } else {
      final k = s.pinwheelScale;
      _sprite(g, _V(0, 12.5 * k, 0), k, _t('lbl_firki'));
    }
  }

  /// One sprite: a dark rounded chip with an indigo border and bold white
  /// text, its size following the perspective (enlarged on small stages,
  /// and never smaller than readable when the scene is zoomed out).
  void _sprite(_Gfx g, _V at, double groupScale, String text) {
    final cam = g.cam;
    if (groupScale < 0.02 || cam.depth(at) < _clipDepth) return;
    final o = cam.p(at);
    // Design px per world unit; the text is 36 / 96 of the sprite height.
    // The smallest readable size still shrinks with a shrinking group.
    final readable =
        _labelMinText *
        labelScale /
        (_spriteH * 36 / 96) *
        math.min(1.0, groupScale);
    final k = math.max(cam.scaleAt(at) * groupScale * labelScale, readable);
    final rect = Rect.fromCenter(
      center: o,
      width: _spriteW * 376 / 384 * k,
      height: _spriteH * 88 / 96 * k,
    );
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(_spriteH * 24 / 96 * k),
    );
    final canvas = g.canvas;
    canvas
      ..drawRRect(
        rr,
        cache.fill
          ..shader = null
          ..color = _Colors.labelBg,
      )
      ..drawRRect(
        rr,
        cache.stroke
          ..strokeWidth = math.max(1.0, _spriteH * 4 / 96 * k)
          ..color = _Colors.labelBorder,
      );
    final tp = cache.label(text);
    final f = _spriteH * 36 / 96 * k / _PaintCache.labelFont;
    // Text wider than the sprite canvas is clipped, as on the HTML canvas.
    canvas
      ..save()
      ..clipRRect(rr)
      ..translate(o.dx, o.dy)
      ..scale(f);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  /// HTML `confetti(...)` with the Scenario 2 success popup.
  void _confetti(Canvas canvas) {
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
      canvas
        ..save()
        ..translate(
          _confettiOrigin.dx + math.cos(c.angle) * d,
          _confettiOrigin.dy + math.sin(c.angle) * d + fall,
        )
        ..rotate(c.spin * ticks)
        ..drawRect(
          const Rect.fromLTWH(-5, -3, 10, 6),
          cache.fill
            ..shader = null
            ..color = c.color.withValues(alpha: fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
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
