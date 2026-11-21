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

/// Class 6 Science • Chapter 7 • Activity 1
/// Hotness, Coldness, and the Sense of Touch.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A1-Hotness__Coldness__and_the_Sense_of_Touch.html`.
///
/// Scenario 1 (The Deceptive Touch): put the beakers of warm, tap and
/// ice-cold water on Positions A, B and C, dip the right hand in the warm
/// water and the left hand in the ice-cold water, then move both hands into
/// the tap water: it feels cold to one hand and warm to the other.
///
/// Scenario 2 (A Reliable Measurement): feel Lambok's forehead with a hand
/// (warm, but is it a fever?), take the digital thermometer out of the
/// first-aid box and put it in his mouth: it reads 37.0 °C, which is normal.
///
/// The Three.js scenes are redrawn by a CustomPainter through a perspective
/// projection of the same camera (fov 45°, position (0, 12, 28), looking at
/// (0, 2, 0)).
class Ch7A1HotnessColdnessAndTheSenseOfTouchPage extends StatefulWidget {
  const Ch7A1HotnessColdnessAndTheSenseOfTouchPage({super.key});

  @override
  State<Ch7A1HotnessColdnessAndTheSenseOfTouchPage> createState() =>
      _TouchLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with Web Audio:
/// 'pop' (every button, beaker placed, forehead touched, box opened),
/// 'success' (summary popup) and 'measure' (a 0.15 s 2 kHz square-wave
/// beep of the thermometer). It also asks for a 'pour' tone when a hand is
/// dipped but never synthesises it (silent); the splash-like drop.mp3 is
/// used. error.mp3 goes with the error toasts this port adds.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// success → `math/success.mp3`, wrong → `science/error.mp3`,
/// beep → `science/click.mp3`, dip → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// HTML `pop`: buttons, toggles, scenario change, curtain, a beaker on
  /// its spot, the forehead touched, the box opened.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `success`: the summary popup.
  success('audio/class6/math/success.mp3'),

  /// A beaker, hand or thermometer let go in the wrong place.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `measure`: the thermometer's beep (the shortest bundled tone).
  beep('audio/class6/science/click.mp3'),

  /// HTML `pour` (never synthesised by the HTML): a hand dipped in water.
  dip('audio/class6/science/drop.mp3');

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

/// Tailwind colours of the HTML page and the material colours of its
/// Three.js scenes.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  /// ZSL yellow (`zsl.yellow`): active tools and the pulsing highlight of
  /// the object to use (emissive 0xeab308).
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color indigo400 = Color(0xFF818CF8);

  /// Label border (`strokeStyle '#6366f1'`), current step.
  static const Color indigo500 = Color(0xFF6366F1);

  /// 'Observe Conclusion' button (`from-blue-600 to-indigo-600`).
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color red500 = Color(0xFFEF4444);
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

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617 (dark theme), 0xf1f5f9 (light theme).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate100;

  /// Table (0x334155) and the beaker spots (RingGeometry, 0x64748b).
  static const Color table = slate700;
  static const Color spot = slate500;

  /// Beaker glass (white, opacity 0.3) and the three waters.
  static const Color glass = white;
  static const Color warm = Color(0xFFF59E0B);
  static const Color tap = Color(0xFF38BDF8);
  static const Color ice = Color(0xFF1D4ED8);
  static const Color iceCube = Color(0xE6FFFFFF);

  /// Steam over the warm water (`rgba(255,255,255,0.6)`).
  static const Color steam = Color(0x99FFFFFF);

  /// Hands: skin 0xfca5a5, hot 0xf87171, cold 0x60a5fa.
  static const Color skin = Color(0xFFFCA5A5);
  static const Color skinHot = Color(0xFFF87171);
  static const Color skinCold = Color(0xFF60A5FA);

  /// Hot (#ef4444 waves) and cold (#3b82f6 snowflake) icons.
  static const Color hotIcon = red500;
  static const Color coldIcon = Color(0xFF3B82F6);

  /// Pillow (white) and Lambok: skin 0xfcd34d, hair 0x0f172a.
  static const Color pillow = white;
  static const Color pillowEdge = slate300;
  static const Color boySkin = Color(0xFFFCD34D);
  static const Color hair = slate900;
  static const Color faceInk = slate900;

  /// Tired circles under the eyes (`rgba(0,0,0,0.12)`).
  static const Color tired = Color(0x1F000000);

  /// Fever blush (`rgba(239, 68, 68, 0.7)` fading out).
  static const Color blush = Color(0xB3EF4444);
  static const Color blushClear = Color(0x00EF4444);

  /// Question mark bubble (`rgba(255,255,255,0.9)`), tick (#10b981) and
  /// smiley (#fde047, black features).
  static const Color question = Color(0xE6FFFFFF);
  static const Color check = Color(0xFF10B981);
  static const Color smiley = Color(0xFFFDE047);
  static const Color smileyInk = Color(0xFF000000);

  /// First-aid box (white), its red cross (#ef4444) and its inside.
  static const Color box = white;
  static const Color boxEdge = slate300;
  static const Color boxInside = slate400;

  /// Digital thermometer: body 0x0ea5e9, metal tip 0x94a3b8, display
  /// #0f172a with #10b981 digits.
  static const Color thermBody = Color(0xFF0EA5E9);
  static const Color thermTip = slate400;
  static const Color lcdBg = slate900;
  static const Color lcdText = Color(0xFF10B981);

  /// Scene label chips: `rgba(15, 23, 42, 0.9)` with an indigo border.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = indigo500;

  /// Soft shadows under the beakers.
  static const Color shadow = Color(0x40000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The canvas follows the theme like the HTML `setTheme()`.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // done steps (dark:text-emerald-400)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // done steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font slider (12–22 px, default 15 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The
/// HTML plays its 'pop' for every UI action.
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.pop,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.pop,
  curtain: _Sound.pop,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Changes:
// * The step actions say exactly what to drag or tap (the HTML texts, e.g.
//   'Place three beakers of water on the table.', did not say how); the
//   HUD lines are the HTML's with 'CLICK' as 'TAP'.
// * S1 step 3 observation: tap water feels 'warm' (not 'hot') to the hand
//   from the ice-cold water, as in the summary and NCERT Activity 7.1.
// * Subtitle: 'Temperature and its Measurement' (NCERT chapter title; the
//   HTML had 'Measurements'). Hindi objective: 'अनुमान लगाने' instead of
//   'न्याय करने' (to judge, as in a court).
// * The HTML's step cards printed the observation twice instead of the
//   'Observation' label.
// Keys marked "added" are texts the HTML did not have (feedback toasts for
// what the learner did, and the scene descriptions for screen readers).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Hotness, Coldness, and the Sense of Touch',
    'app_subtitle': 'Class 6 • Temperature and its Measurement',
    'scen_1_opt': 'Scenario 1: The Deceptive Touch',
    'scen_2_opt': 'Scenario 2: A Reliable Measurement',
    's1_desc':
        'To demonstrate through a hands-on experiment that the human sense of touch is an unreliable way to judge temperature.',
    's2_desc':
        'To understand the need for a scientific instrument (a thermometer) for an accurate and reliable temperature measurement.',
    // Steps: concept (c), action (a), observation (o).
    's1_c1': 'Setting up the experiment.',
    's1_a1':
        'Place three beakers of water on the table: drag the Warm Water beaker (A) onto Position A, the Tap Water beaker (B) onto Position B and the Ice-Cold Water beaker (C) onto Position C.',
    's1_o1': 'Beakers A, B, and C are ready.',
    's1_c2': 'Experiencing hot and cold.',
    's1_a2':
        'Dip the right hand in warm water and the left hand in cold water: drag the Right Hand into Beaker A and the Left Hand into Beaker C.',
    's1_o2': 'Right feels hot, left feels cold.',
    's1_c3': 'The subjective nature of touch.',
    's1_a3':
        'Move both hands into the tap water beaker: drag the Right Hand and the Left Hand into Beaker B.',
    's1_o3':
        'The SAME water feels cold to the right hand and warm to the left hand!',
    's1_c4': 'Conclusion',
    's1_a4': "Analyse the feelings, then tap 'Observe Conclusion'.",
    's1_o4':
        'Our sense of touch tells us about heat flow, not actual temperature. It can be fooled.',
    's2_c1': 'Sensing heat through touch.',
    's2_a1':
        "Touch Lambok's forehead to check for fever: drag the Hand onto his forehead.",
    's2_o1': "He feels warm... but does he have a fever? It's uncertain.",
    's2_c2': 'Finding the right tool.',
    's2_a2':
        'Tap the First-Aid Box to open it, then drag the digital thermometer out of the box.',
    's2_o2': 'A clinical/digital thermometer is ready for use.',
    's2_c3': 'Scientific measurement.',
    's2_a3':
        "Place the thermometer in Lambok's mouth to measure his temperature: drag it to his mouth and wait for the beep.",
    's2_o3':
        'The thermometer beeps and gives a precise numerical reading (37.0 °C).',
    's2_c4': 'Conclusion',
    's2_a4': "Observe the final reading, then tap 'Observe Conclusion'.",
    's2_o4':
        'A thermometer gives a reliable number, not just a feeling. His temperature is normal!',
    // HUD (HTML `hud`).
    's1_hud_1':
        'Step 1: DRAG the three beakers (Warm, Tap, Ice-Cold) onto their spots (A, B, C) on the table.',
    's1_hud_2':
        'Step 2: DRAG the Right Hand to Beaker A (Warm) and Left Hand to Beaker C (Ice-Cold).',
    's1_hud_3':
        'Step 3: DRAG both the Right Hand and Left Hand into Beaker B (Tap Water).',
    's1_hud_4':
        "Step 4: Observe the contradiction and tap 'Observe Conclusion'.",
    's2_hud_1':
        "Step 1: DRAG the Hand to Lambok's forehead to check for a fever.",
    's2_hud_2':
        'Step 2: TAP the First-Aid Box to open it, then DRAG the digital thermometer out.',
    's2_hud_3':
        "Step 3: DRAG the thermometer to Lambok's mouth to take a reading.",
    's2_hud_4': "Step 4: Observe the reading and tap 'Observe Conclusion'.",
    'btn_conclude': 'Observe Conclusion',
    // Summary popups.
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete': 'Mastery Achieved!',
    's1_sum_title': 'Our sense of touch can be fooled!',
    's1_sum':
        'The same tap water felt cold to one hand and warm to the other. Our skin senses heat flow (gaining or losing heat), making it unreliable for finding actual temperature.',
    's2_sum_title': 'A thermometer is reliable!',
    's2_sum':
        "Even though Lambok's forehead felt warm to the touch, the thermometer gave us an exact reading (37.0 °C), showing us he doesn't have a fever. We need instruments for exact measurements.",
    'all_complete_desc':
        'You learned that our sense of touch is subjective and can be fooled! A thermometer is necessary to accurately measure temperature.',
    // Scene labels.
    'lbl_warm': 'Warm Water',
    'lbl_tap': 'Tap Water',
    'lbl_ice': 'Ice-Cold Water',
    'lbl_pos_a': 'Position A',
    'lbl_pos_b': 'Position B',
    'lbl_pos_c': 'Position C',
    'lbl_rhand': 'Right Hand',
    'lbl_lhand': 'Left Hand',
    'lbl_hand': 'Hand',
    'lbl_box': 'First-Aid Box',
    'lbl_therm': 'Digital Thermometer',
    'lbl_lambok': 'Lambok',
    // Added: feedback toasts.
    'err_beaker': 'Drag Beaker {l} ({liquid}) onto Position {l}.',
    'err_dip_r': 'Dip the Right Hand into Beaker A (Warm Water).',
    'err_dip_l': 'Dip the Left Hand into Beaker C (Ice-Cold Water).',
    'err_dip_b': 'Move both hands into Beaker B (Tap Water).',
    'feel_r_hot': 'The Right Hand feels hot in the warm water.',
    'feel_l_cold': 'The Left Hand feels cold in the ice-cold water.',
    'feel_r_cold': 'The tap water feels cold to the Right Hand!',
    'feel_l_warm': 'The tap water feels warm to the Left Hand!',
    'feel_forehead': "Lambok's forehead feels warm. Does he have a fever?",
    'err_forehead': "Drag the Hand onto Lambok's forehead.",
    'err_box_early': "First check Lambok's forehead with the Hand.",
    'toast_box_open': 'The First-Aid Box is open. Drag the thermometer out.',
    'toast_therm_out': "Thermometer out! Now drag it to Lambok's mouth.",
    'err_mouth': "Drag the thermometer to Lambok's mouth.",
    'toast_measuring': 'Measuring... wait for the beep.',
    'toast_reading': 'Beep! The thermometer reads 37.0 °C.',
    // Teacher board "Conceptual Exploration" list.
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration Step',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    // Added: scene descriptions (screen readers).
    'scene_s1':
        'A table with beakers of warm, tap and ice-cold water, Positions A, B and C, and a right and a left hand',
    'scene_s2':
        'Lambok lying on a pillow, a hand and a first-aid box with a digital thermometer',
  },
  'hi': {
    'app_title': 'गर्मी, सर्दी और स्पर्श का अहसास',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'scen_1_opt': 'परिदृश्य 1: भ्रामक स्पर्श',
    'scen_2_opt': 'परिदृश्य 2: एक विश्वसनीय मापन',
    's1_desc':
        'एक प्रयोग द्वारा यह प्रदर्शित करना कि तापमान का अनुमान लगाने के लिए मानव स्पर्श की भावना एक अविश्वसनीय तरीका है।',
    's2_desc':
        'सटीक और विश्वसनीय तापमान मापन के लिए वैज्ञानिक उपकरण (थर्मामीटर) की आवश्यकता को समझना।',
    's1_c1': 'प्रयोग की स्थापना।',
    's1_a1':
        'मेज पर पानी के तीन बीकर रखें: गर्म पानी वाले बीकर (A) को स्थिति A पर, नल के पानी वाले बीकर (B) को स्थिति B पर और बर्फ-ठंडे पानी वाले बीकर (C) को स्थिति C पर खींचें।',
    's1_o1': 'बीकर A, B और C तैयार हैं।',
    's1_c2': 'गर्म और ठंडे का अनुभव।',
    's1_a2':
        'दाहिने हाथ को गर्म पानी में और बाएं हाथ को ठंडे पानी में डुबोएं: दाहिने हाथ को बीकर A में और बाएं हाथ को बीकर C में खींचें।',
    's1_o2': 'दाहिना हाथ गर्म महसूस करता है, बायां ठंडा।',
    's1_c3': 'स्पर्श की व्यक्तिपरक प्रकृति।',
    's1_a3':
        'दोनों हाथों को नल के पानी वाले बीकर में ले जाएं: दाहिने हाथ और बाएं हाथ को बीकर B में खींचें।',
    's1_o3': 'वही पानी दाहिने हाथ को ठंडा और बाएं हाथ को गर्म लगता है!',
    's1_c4': 'निष्कर्ष',
    's1_a4': "अनुभूतियों का विश्लेषण करें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's1_o4':
        'हमारा स्पर्श हमें ऊष्मा प्रवाह के बारे में बताता है, वास्तविक तापमान के बारे में नहीं। इसे धोखा दिया जा सकता है।',
    's2_c1': 'स्पर्श के माध्यम से गर्मी महसूस करना।',
    's2_a1':
        'बुखार की जांच के लिए लाम्बोक का माथा छुएं: हाथ को उसके माथे पर खींचें।',
    's2_o1': 'वह गर्म लग रहा है... लेकिन क्या उसे बुखार है? यह अनिश्चित है।',
    's2_c2': 'सही उपकरण ढूँढना।',
    's2_a2':
        'प्राथमिक चिकित्सा बॉक्स को खोलने के लिए उस पर टैप करें, फिर डिजिटल थर्मामीटर को बॉक्स से बाहर खींचें।',
    's2_o2': 'एक डिजिटल थर्मामीटर उपयोग के लिए तैयार है।',
    's2_c3': 'वैज्ञानिक मापन।',
    's2_a3':
        'तापमान मापने के लिए थर्मामीटर को लाम्बोक के मुंह में रखें: उसे मुंह तक खींचें और बीप की प्रतीक्षा करें।',
    's2_o3': 'थर्मामीटर बीप करता है और एक सटीक रीडिंग (37.0 °C) देता है।',
    's2_c4': 'निष्कर्ष',
    's2_a4': "अंतिम रीडिंग देखें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's2_o4':
        'थर्मामीटर एक विश्वसनीय संख्या देता है, न कि केवल एक अहसास। उसका तापमान सामान्य है!',
    's1_hud_1':
        'चरण 1: तीन बीकरों (गर्म, नल, बर्फ) को मेज पर उनके स्थानों (A, B, C) पर खींचें।',
    's1_hud_2':
        'चरण 2: दाहिने हाथ को बीकर A (गर्म) में और बाएं हाथ को बीकर C (बर्फ-ठंडा) में खींचें।',
    's1_hud_3': 'चरण 3: दोनों हाथों को बीकर B (नल का पानी) में खींचें।',
    's1_hud_4':
        "चरण 4: विरोधाभास का निरीक्षण करें और 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_1': 'चरण 1: बुखार की जांच के लिए हाथ को लाम्बोक के माथे पर खींचें।',
    's2_hud_2':
        'चरण 2: प्राथमिक चिकित्सा बॉक्स खोलने के लिए उस पर टैप करें, फिर थर्मामीटर बाहर खींचें।',
    's2_hud_3':
        'चरण 3: रीडिंग लेने के लिए थर्मामीटर को लाम्बोक के मुंह तक खींचें।',
    's2_hud_4': "चरण 4: रीडिंग देखें और 'निष्कर्ष देखें' पर टैप करें।",
    'btn_conclude': 'निष्कर्ष देखें',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete': 'महारत हासिल की!',
    's1_sum_title': 'हमारे स्पर्श को धोखा दिया जा सकता है!',
    's1_sum':
        'वही नल का पानी एक हाथ को ठंडा और दूसरे को गर्म लगा। हमारी त्वचा ऊष्मा प्रवाह (ऊष्मा मिलना या खोना) को महसूस करती है, जिससे यह वास्तविक तापमान का पता लगाने के लिए अविश्वसनीय हो जाती है।',
    's2_sum_title': 'थर्मामीटर विश्वसनीय है!',
    's2_sum':
        'भले ही लाम्बोक का माथा छूने पर गर्म लगा, थर्मामीटर ने हमें सटीक रीडिंग (37.0 °C) दी, जिससे पता चला कि उसे बुखार नहीं है। सटीक मापन के लिए हमें उपकरणों की आवश्यकता है।',
    'all_complete_desc':
        'आपने सीखा कि हमारे स्पर्श का अहसास व्यक्तिपरक है और धोखा खा सकता है! तापमान को सटीक रूप से मापने के लिए थर्मामीटर आवश्यक है।',
    'lbl_warm': 'गर्म पानी',
    'lbl_tap': 'नल का पानी',
    'lbl_ice': 'बर्फ-ठंडा पानी',
    'lbl_pos_a': 'स्थिति A',
    'lbl_pos_b': 'स्थिति B',
    'lbl_pos_c': 'स्थिति C',
    'lbl_rhand': 'दाहिना हाथ',
    'lbl_lhand': 'बायां हाथ',
    'lbl_hand': 'हाथ',
    'lbl_box': 'प्राथमिक चिकित्सा बॉक्स',
    'lbl_therm': 'डिजिटल थर्मामीटर',
    'lbl_lambok': 'लाम्बोक',
    'err_beaker': 'बीकर {l} ({liquid}) को स्थिति {l} पर खींचें।',
    'err_dip_r': 'दाहिने हाथ को बीकर A (गर्म पानी) में डुबोएं।',
    'err_dip_l': 'बाएं हाथ को बीकर C (बर्फ-ठंडा पानी) में डुबोएं।',
    'err_dip_b': 'दोनों हाथों को बीकर B (नल का पानी) में ले जाएं।',
    'feel_r_hot': 'गर्म पानी में दाहिना हाथ गर्म महसूस करता है।',
    'feel_l_cold': 'बर्फ-ठंडे पानी में बायां हाथ ठंडा महसूस करता है।',
    'feel_r_cold': 'नल का पानी दाहिने हाथ को ठंडा लगता है!',
    'feel_l_warm': 'नल का पानी बाएं हाथ को गर्म लगता है!',
    'feel_forehead': 'लाम्बोक का माथा गर्म लग रहा है। क्या उसे बुखार है?',
    'err_forehead': 'हाथ को लाम्बोक के माथे पर खींचें।',
    'err_box_early': 'पहले हाथ से लाम्बोक का माथा जांचें।',
    'toast_box_open':
        'प्राथमिक चिकित्सा बॉक्स खुल गया। थर्मामीटर को बाहर खींचें।',
    'toast_therm_out':
        'थर्मामीटर बाहर आ गया! अब इसे लाम्बोक के मुंह तक खींचें।',
    'err_mouth': 'थर्मामीटर को लाम्बोक के मुंह तक खींचें।',
    'toast_measuring': 'माप हो रहा है... बीप की प्रतीक्षा करें।',
    'toast_reading': 'बीप! थर्मामीटर 37.0 °C दिखाता है।',
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण चरण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'scene_s1':
        'एक मेज जिस पर गर्म, नल के और बर्फ-ठंडे पानी के बीकर, स्थितियाँ A, B और C, और एक दाहिना तथा एक बायां हाथ हैं',
    'scene_s2':
        'तकिए पर लेटा लाम्बोक, एक हाथ और डिजिटल थर्मामीटर वाला प्राथमिक चिकित्सा बॉक्स',
  },
};

/// Steps per scenario (HTML `steps`), and the value of `step` once the
/// conclusion has been opened.
const int _stepCount = 4;
const int _doneStep = _stepCount + 1;

/// Scenarios and steps for [lang], built from [_i18n] (HTML `ScenariosData`:
/// four steps of concept / action / observation per scenario).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      LabScenarioData scenario(int n) => LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_c$i'),
              action: t('s${n}_a$i'),
              observation: t('s${n}_o$i'),
            ),
        ],
      );
      return [scenario(1), scenario(2)];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target (logical px) and the scene drags' touch slop
/// (Flutter's default is 18 px; short drags must pick objects up).
const double _minTouch = 48;
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

/// Longest frame step (s), so a stalled frame does not jump the framing.
const double _maxFrameStep = 0.1;

// ------------------------------------------------------------------ camera
// HTML `init3D()`: PerspectiveCamera(45°) at (0, 12, 28), OrbitControls
// target (0, 2, 0); the camera stays locked.

const _V _eye = _V(0, 12, 28);
const _V _lookAt = _V(0, 2, 0);

/// 280 / tan(22.5°): the 45° vertical field of view over the 560 px stage.
const double _focal = 675.98;
const Offset _stageCentre = Offset(500, 280);

/// Horizontal extent (design px, home view) of what the learner touches in
/// each scenario: S1 the hands and the beakers, S2 the hand and the
/// first-aid box. While the sidebar is collapsed the floating mission card
/// covers the top-left of the canvas, so the scene slides (and if needed
/// shrinks) into the room between the card and the tool column, easing
/// over 380 ms like the sidebar.
const (double, double) _s1Extent = (222, 768);
const (double, double) _s2Extent = (224, 802);
const double _framingSeconds = 0.38;

/// LAB FRAMEWORK: the floating mission card's left edge (beside the menu
/// button) and the gap kept from it and from the tool column.
const double _missionCardLeft = 76;
const double _cardGap = 12;

/// Canvas labels: 12 design px, enlarged up to 1.8× on small stages so the
/// HTML's label sprites stay readable (same rule as the Chapter 4 labs).
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// HTML DirectionalLight at (10, 30, 20), normalised. The HTML's
/// AmbientLight 0.9 plus DirectionalLight 1.0 saturate most faces; the
/// shading is scaled down so the faces of a box stay distinguishable.
const _V _light = _V(0.2673, 0.8018, 0.5345);
const double _ambient = 0.7;
const double _diffuse = 0.45;

/// Label chip padding, in units of the label size (HTML sprite: 376 × 88
/// rounded box around 36 px text).
const double _chipPadX = 0.6;
const double _chipPadY = 0.3;

/// The highlight pulse: emissive 0 → 0.6 over 500 ms, yoyo (HTML
/// `setHighlightGlow`).
const double _glowHalfPeriod = 0.5;
const double _glowMin = 0.15;
const double _glowMax = 0.6;

// --------------------------------------------------------------- scenario 1
// HTML `buildS1()`.

/// Table: BoxGeometry(40, 0.5, 15) at y = -0.25.
const _V _tableCentre = _V(0, -0.25, 0);
const _V _tableHalf = _V(20, 0.25, 7.5);

/// Spots A, B, C (RingGeometry(1.8, 2.0) at y = 0.01) and their labels.
const List<_V> _spots = [_V(-6, 0, 2), _V(0, 0, 2), _V(6, 0, 2)];
const double _spotRadius = 1.9;
const double _spotWidth = 0.2;
const _V _spotLabelOffset = _V(0, 0.2, 2.5); // lblSA at (-6, 0.2, 4.5)

/// Beakers A, B, C start at the back of the table.
const List<_V> _beakerHomes = [_V(-10, 0, -3), _V(0, 0, -3), _V(10, 0, -3)];

/// Glass: open CylinderGeometry(1.6, 1.4, 3.5); water: CylinderGeometry(1.5,
/// 1.35, 2.5) centred 1.3 up (opacity 0.8).
const double _beakerTopR = 1.6;
const double _beakerBottomR = 1.4;
const double _beakerHeight = 3.5;
const double _waterBottom = 0.05;
const double _waterTop = 2.55;
const double _waterTopR = 1.5;
const double _waterBottomR = 1.35;

/// Centre of a beaker's body (hand drop target).
const _V _beakerMiddle = _V(0, 1.75, 0);

/// The big letter on the glass (sprite at (0, 1.75, 1.7)), drawn lower and
/// larger so it stays readable on a phone; the name label sits in front of
/// the beaker on the table (the HTML's sprite at y = -1 was hidden by the
/// table top).
const _V _letterOffset = _V(0, 1.1, 1.7);
const double _letterHeight = 0.9;
const _V _nameLabelOffset = _V(0, 0, 1.9);

/// Steam over the warm water: a 1.5 × 3 sprite 4.5 above the beaker.
const _V _steamOffset = _V(0, 4.5, 0);
const double _steamHeight = 3;

/// `checkDrop`: a beaker snaps onto its own spot within this distance.
const double _snapDist = 4;

/// Beakers slide on the table top (y = 0) and stay on it.
const double _tableDragX = 18;
const double _tableDragZ = 6.5;

/// Hands: `createStylizedHand` (palm 1.8 × 2.2 × 0.5, four fingers, thumb),
/// turned upside down (rotation.z = π). They start raised above the table
/// at (∓8, 10, 4); at the HTML's (∓8, 5, 5) they covered beakers A and C,
/// which the learner must drag first.
const List<_V> _handHomes = [_V(-8, 10, 4), _V(8, 10, 4)];

/// A dipped hand's wrist (HTML target (-6, 3, 2), (6, 3, 2) and (∓1, 3, 2)),
/// a little higher so the fingers end on the beaker's floor.
const double _dipY = 3.4;
const List<_V> _dipFirst = [_V(-6, _dipY, 2), _V(6, _dipY, 2)];
const List<_V> _dipTap = [_V(-1, _dipY, 2), _V(1, _dipY, 2)];

/// A hand dips into a beaker when its palm is let go within this distance
/// (world units, on screen) of the beaker's middle. The HTML used 4 units
/// for steps 2 and 6 for step 3, measured from where the hand already was:
/// in step 3 a hand still in beaker A was 5.9 units from beaker B, so a
/// tiny nudge "moved" it into the tap water.
const double _dipRadius = 2.5;

/// Hand label and hot / cold icon: above the wrist; once dipped, beside the
/// beaker on the hand's outer side so the two hands' labels never overlap.
const _V _handLabelUp = _V(0, 0.9, 0);
const double _dippedLabelOut = 2.6;
const double _dippedLabelUp = 1.9;
const double _dippedIconUp = 3.7;
const double _feelIconSize = 2;

// --------------------------------------------------------------- scenario 2
// HTML `buildS2()`.

/// Pillow: BoxGeometry(16, 12, 3) at (0, 4, -5.5).
const _V _pillowCentre = _V(0, 4, -5.5);
const _V _pillowHalf = _V(8, 6, 1.5);

/// Lambok: head sphere r 3.5 at (0, 3.5, -2); hair sphere r 3.6 raised 0.5,
/// a cap of 100° (π / 1.8) tilted back by 60°; face disc r 2.6 at
/// (0, -0.2, 3.4) from the head centre.
const _V _headCentre = _V(0, 3.5, -2);
const double _headR = 3.5;
const _V _hairCentre = _V(0, 4.0, -2);
const double _hairR = 3.6;
const _V _faceCentre = _V(0, 3.3, 1.4);
const double _faceR = 2.6;

/// Face texture: 512 × 512 canvas mapped onto the face disc.
const double _faceTex = 512;

/// Forehead (on the head sphere, 40° above its front) and mouth (face
/// texture (256, 350)).
const _V _forehead = _V(0, 5.75, 0.68);
const _V _mouth = _V(0, 2.35, 1.4);

/// Question mark (scale 4) and tick (scale 4) beside the head. The smiley
/// (scale 3) takes the question mark's place: at the HTML's (-6, 5, 0) it
/// overlapped the tick.
const _V _questionAt = _V(5, 8.5, -2);
const double _questionSize = 4;
const _V _checkAt = _V(-4, 8.5, -2);
const double _checkSize = 4;
const _V _smileyAt = _V(5, 8.5, -2);
const double _smileySize = 3;
const _V _lambokLabelAt = _V(0, -2, 0);

/// Icon textures are 256 × 256 canvases.
const double _iconTex = 256;

/// The hand (scale 1.4, rotation.z = π, rotation.x = -π/6). It starts at
/// (-7.5, 4.5, 4.5): at the HTML's (-8, -2, 6) it hung off the bottom of
/// the view, under the HUD.
const _V _s2HandHome = _V(-7.5, 4.5, 4.5);
const double _s2HandScale = 1.4;
const double _s2HandTilt = -math.pi / 6;

/// Where the hand rests on the forehead (HTML tween to (-1, 8.5, 1.5)).
const _V _s2HandOnForehead = _V(-1, 8.5, 1.5);

/// The hand touches the forehead when its palm is let go within this
/// distance (world units, on screen) of it. The HTML accepted anything
/// within 7 units of (0, 7.5, 1), most of the head and pillow.
const double _foreheadRadius = 2.5;

/// First-aid box: 6 × 3 × 4 base at (8, -1, 4) + (0, 1.5, 0); lid 6 × 0.5 × 4
/// hinged at its back top edge, opened to rotation.x = -π / 1.5.
const _V _boxCentre = _V(8, 0.5, 4);
const _V _boxHalf = _V(3, 1.5, 2);
const double _boxTopY = 2;
const _V _lidHinge = _V(8, 2, 2);
const _V _lidOffset = _V(0, 0.25, 2);
const double _lidOpenAngle = -math.pi / 1.5;
const _V _boxLabelAt = _V(8, -1.6, 6);

/// Red cross texture (128 × 128 canvas, two 40 × 100 bars) on a 2 × 2 plane
/// in front of the box.
const _V _crossCentre = _V(8, 0.5, 6.01);
const double _crossTex = 128;

/// Digital thermometer: body 4.5 × 0.6 × 0.9, metal tip (r 0.25–0.3, 1.5
/// long) 2.8 left of the centre, display sprite 2.2 × 0.5 on top.
const _V _thermInBox = _V(8, -0.5, 4);
const _V _thermPopped = _V(8, 4.5, 4);
const _V _thermInMouth = _V(2, 3.5, 4.5);
const double _thermMouthRz = math.pi / 6;
const double _thermMouthRy = -math.pi / 8;
const _V _thermHalf = _V(2.25, 0.3, 0.45);
const _V _tipNear = _V(-2.05, 0, 0);
const _V _tipFar = _V(-3.55, 0, 0);
const double _tipRadius = 0.27;
const _V _lcdOffset = _V(0, 0.31, 0);
const double _lcdWidth = 2.2;
const double _lcdHeight = 0.5;
const _V _thermLabelUp = _V(0, 1.1, 0);

/// The thermometer is "out" once dragged this far from where it popped up
/// (the HTML told the learner to drag it out, then moved on without it).
const double _takeOutDistance = 2;

/// It goes in the mouth when its tip or its middle is let go within this
/// distance (world units, on screen) of the mouth; let go with its middle
/// over the rest of the head it is refused.
const double _mouthRadius = 2.5;
const double _headRefuse = 1.3;

/// Where a thermometer let go elsewhere may stay (design px); beyond that
/// it floats back over the box.
const double _restTop = 80;
const double _restBottom = 430;
const double _restSide = 40;

/// The digital reading counts from 35.0 to 37.0 °C (HTML `measureTemp`).
const double _readingFrom = 35;
const double _readingTo = 37;

/// Magnified display beside Lambok's head while the thermometer reads (the
/// HTML's 2.2 × 0.5 display sprite is a few pixels tall on a phone).
const _V _calloutAt = _V(7.5, 6.2, 3);
const double _calloutFont = 22;

// ------------------------------------------------------------------ timings
// HTML TWEEN durations and setTimeouts.

const double _snapTween = 0.3; // onto a spot / into a beaker / forehead
const double _returnTween = 0.4; // back after a missed drop
const Duration _beakersDoneDelay = Duration(milliseconds: 500);
const Duration _handsFirstDelay = Duration(milliseconds: 1000);
const Duration _handsTapDelay = Duration(milliseconds: 1500);
const Duration _foreheadDelay = Duration(milliseconds: 1500);
const double _lidTween = 0.5;
const double _riseDelay = 0.3;
const double _riseTween = 0.6; // TWEEN.Easing.Back.Out
const Duration _measureDelay = Duration(milliseconds: 1000);
const double _measureTween = 1.5;
const Duration _resultDelay = Duration(milliseconds: 1000);
const double _handHomeTween = 0.5;
const Duration _conclusionDelay = Duration(milliseconds: 300);

/// Height kept free above the canvas bottom for the shell's HUD chip (two
/// lines of 11 px text, its label and padding, at UI scale 1).
const double _hudClearance = 64;

/// A drag shorter than this (world units) is a tap: no error toast.
const double _moveThreshold = 0.4;

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);

  final double x;
  final double y;
  final double z;

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Rotations about the x, y and z axes (Three.js Euler 'XYZ' applies z,
/// then y, then x).
_V _rotX(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x, v.y * c - v.z * s, v.y * s + v.z * c);
}

_V _rotY(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

_V _rotZ(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}

/// Horizontal (x, z) distance, as the HTML snap tests use on the table.
double _xzDist(_V a, _V b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z));

/// The HTML camera projected onto the design stage: [centre] and [focal]
/// carry the collapsed-sidebar framing.
@immutable
class _Proj {
  const _Proj(this.centre, this.focal);

  /// Camera axes: forward (to the look-at point), right and up.
  static final _V f = (_lookAt - _eye).unit;
  static final _V r = f.cross(_V.up).unit;
  static final _V u = r.cross(f);

  final Offset centre;
  final double focal;

  double depth(_V w) => (w - _eye).dot(f);

  /// Design px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - _eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(centre.dx + d.dot(r) * k, centre.dy - d.dot(u) * k);
  }

  /// World ray through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - centre.dx) / focal) + u * (-(s.dy - centre.dy) / focal))
          .unit;

  /// Where that ray meets the plane `n · x = d`, or null.
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-9) return null;
    final t = (d - _eye.dot(n)) / den;
    if (t <= 0) return null;
    return _eye + dir * t;
  }

  /// Vertical half size of the ellipse a horizontal circle of radius [r]
  /// at [c] projects to.
  double ellipseHalf(_V c, double r) =>
      (p(c + _V(0, 0, r)).dy - p(c - _V(0, 0, r)).dy).abs() / 2;

  /// Screen rect of a horizontal circle of radius [r] at [c].
  Rect oval(_V c, double r) => Rect.fromCenter(
    center: p(c),
    width: 2 * r * scaleAt(c),
    height: 2 * ellipseHalf(c, r),
  );

  /// Screen bounds of [points].
  Rect bounds(Iterable<_V> points) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final w in points) {
      final o = p(w);
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// A hand's placement: wrist position, size, tilt (rotation.x) and
/// whether it is a left hand (mirrored, thumb on the other side).
@immutable
class _HandPose {
  const _HandPose(
    this.wrist, {
    this.scale = 1,
    this.tilt = 0,
    this.mirror = false,
  });

  final _V wrist;
  final double scale;
  final double tilt;
  final bool mirror;

  /// A model-space direction turned like the hand (rotation.z = π, then
  /// rotation.x = [tilt]).
  _V dir(_V local) {
    final m = _V(mirror ? -local.x : local.x, local.y, local.z) * scale;
    return _rotX(_V(-m.x, -m.y, m.z), tilt);
  }

  _V world(_V local) => wrist + dir(local);

  /// Middle of the palm: the point that follows the finger while dragging.
  _V get palm => world(_palmCentre);

  /// Every corner and tip (hit tests, bounds).
  List<_V> get outline => [
    for (final c in _palmCorners) world(c),
    for (var i = 0; i < 4; i++) world(_V(_fingerX(i), _fingerTip, 0)),
    world(_thumbTip),
  ];
}

/// `createStylizedHand` geometry (model space, fingers pointing +y).
const _V _palmCentre = _V(0, 1.1, 0);
const _V _palmHalf = _V(0.9, 1.1, 0.25);
const List<_V> _palmCorners = [
  _V(-0.9, 0, 0),
  _V(0.9, 0, 0),
  _V(-0.9, 2.2, 0),
  _V(0.9, 2.2, 0),
];
const double _fingerBase = 2.2;
const double _fingerTip = 3.4;
const double _fingerR = 0.2;
double _fingerX(int i) => -0.6 + i * 0.4;

/// Thumb: CylinderGeometry(0.25, 0.25, 1) at (1.2, 1.2, 0), rotation.z =
/// -π/4.
const _V _thumbBase = _V(0.846, 0.846, 0);
const _V _thumbTip = _V(1.554, 1.554, 0);
const double _thumbR = 0.25;

// ------------------------------------------------------------------ tweens

/// TWEEN.Easing.Linear.None.
double _linear(double t) => t;

/// TWEEN.Easing.Back.Out.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// What a tween moves (cancelled when the learner grabs that object).
enum _Kind { beaker, hand, s2Hand, thermometer, other }

/// One tween.js tween: [apply] receives the eased progress 0..1.
class _Tween {
  _Tween({
    required this.start,
    required this.duration,
    required this.apply,
    required this.ease,
    required this.kind,
    required this.index,
    this.onComplete,
  });

  final double start;
  final double duration;
  final void Function(double k) apply;
  final double Function(double t) ease;
  final _Kind kind;
  final int index;
  final VoidCallback? onComplete;

  /// Applies the tween at [now] (seconds); true once it has finished.
  bool update(double now) {
    final t = ((now - start) / duration).clamp(0.0, 1.0);
    apply(ease(t));
    return t >= 1;
  }
}

// ------------------------------------------------------------- scene model

/// How a dipped hand feels (the HTML hot / cold icons and hand colours).
enum _Feel { none, hot, cold }

/// Lambok's face (HTML `updateLambokFace` states).
enum _FaceState { sick, open, happy }

/// One beaker of Scenario 1: 0 A (warm), 1 B (tap), 2 C (ice-cold).
class _Beaker {
  _Beaker(this.index) : pos = _beakerHomes[index];

  final int index;

  /// Centre of the beaker's base, on the table.
  _V pos;

  /// On its own spot (HTML `userData.placed`).
  bool placed = false;

  _V get middle => pos + _beakerMiddle;

  void reset() {
    pos = _beakerHomes[index];
    placed = false;
  }
}

/// One hand of Scenario 1: 0 right, 1 left.
class _Hand {
  _Hand(this.index) : wrist = _handHomes[index];

  final int index;
  _V wrist;

  /// 0 = raised, 1 = in its first beaker (A or C), 2 = in beaker B.
  int stage = 0;

  /// The beaker it is drawn in, or -1 while it is free.
  int inBeaker = -1;
  _Feel feel = _Feel.none;

  /// -1 for the right hand (left of the screen), 1 for the left hand.
  int get side => index == 0 ? -1 : 1;
  _HandPose get pose => _HandPose(wrist, mirror: index == 1);
  _V get palm => pose.palm;

  /// The beaker this hand dips into first (A for the right hand, C for the
  /// left one).
  int get firstBeaker => index == 0 ? 0 : 2;

  Color get skin => switch (feel) {
    _Feel.none => _Colors.skin,
    _Feel.hot => _Colors.skinHot,
    _Feel.cold => _Colors.skinCold,
  };

  void reset() {
    wrist = _handHomes[index];
    stage = 0;
    inBeaker = -1;
    feel = _Feel.none;
  }
}

/// All mutable simulation state; the painter reads it every frame.
class _Scene {
  _Scene() {
    load(0);
  }

  int scenario = 0;

  /// 1–4 (HTML `State.step`); [_doneStep] once the conclusion is open.
  int step = 1;

  /// Ticker time in seconds.
  double time = 0;
  final List<_Tween> tweens = [];

  /// 0 = sidebar open, 1 = collapsed (linear; eased in [framing]).
  double framingT = 0;

  /// Collapsed-sidebar framing: zoom and horizontal shift (design px).
  double collapsedZoom = 1;
  double collapsedShift = 0;

  // ----------------------------------------------------------- scenario 1
  final List<_Beaker> beakers = [for (var i = 0; i < 3; i++) _Beaker(i)];
  final List<_Hand> hands = [_Hand(0), _Hand(1)];

  // ----------------------------------------------------------- scenario 2
  _V s2Wrist = _s2HandHome;

  /// The hand has felt the forehead (red while it rests there).
  bool touched = false;
  bool s2HandWarm = false;
  bool boxOpen = false;

  /// Lid opening 0..1.
  double lid = 0;
  bool thermVisible = false;

  /// Risen out of the box and draggable.
  bool thermReady = false;

  /// Dragged out of the box (step 2 done).
  bool thermOut = false;
  bool inMouth = false;
  _V therm = _thermInBox;

  /// Blend 0..1 towards the in-mouth rotation.
  double thermTurn = 0;

  /// The display: null shows '---'.
  double? reading;
  bool measured = false;
  _FaceState face = _FaceState.sick;
  bool fever = false;
  bool question = false;
  bool tick = false;
  bool smiley = false;

  // ----------------------------------------------------------------- drag
  _Kind? dragKind;
  int dragIndex = -1;

  /// Drag plane `planeN · x = planeD`, grab offset (plane hit minus the
  /// object's drag point) and where the drag point started.
  _V planeN = _V.up;
  double planeD = 0;
  _V grabOffset = _V.zero;
  _V dragFrom = _V.zero;

  double get framing => Curves.easeInOutCubic.transform(framingT);

  /// The camera with the current framing.
  _Proj get proj => projAt(framing);

  /// The camera at framing [e] (0 = sidebar open, 1 = collapsed).
  _Proj projAt(double e) {
    final z = 1 + (collapsedZoom - 1) * e;
    return _Proj(
      Offset(_stageCentre.dx + collapsedShift * e, _stageCentre.dy),
      _focal * z,
    );
  }

  /// Pulse 0..1..0 of the highlight glow (period 1 s).
  double get pulse => 0.5 - 0.5 * math.cos(time * math.pi / _glowHalfPeriod);

  _HandPose get s2Pose =>
      _HandPose(s2Wrist, scale: _s2HandScale, tilt: _s2HandTilt);

  /// The thermometer's model-to-world turn (rotation y, z blended in).
  _V thermDir(_V local) =>
      _rotY(_rotZ(local, _thermMouthRz * thermTurn), _thermMouthRy * thermTurn);

  _V thermWorld(_V local) => therm + thermDir(local);

  /// The object that pulses (HTML `updateHighlights`); none while dragging.
  bool glows(_Kind kind, [int index = 0]) {
    if (dragKind != null) return false;
    if (scenario == 0) {
      return switch (kind) {
        _Kind.beaker => step == 1 && !beakers[index].placed,
        _Kind.hand =>
          (step == 2 || step == 3) && hands[index].stage == step - 2,
        _ => false,
      };
    }
    return switch (kind) {
      _Kind.s2Hand => step == 1 && !touched,
      _Kind.other => step == 2 && !boxOpen,
      _Kind.thermometer =>
        (step == 2 && thermReady && !thermOut) || (step == 3 && !inMouth),
      _ => false,
    };
  }

  // Read by the QA flow (integration_test/qa/flows) through the painter:
  // design-space positions with the current framing, and outcomes.

  /// Design position of world point (x, y, z).
  Offset designPoint(double x, double y, double z) => proj.p(_V(x, y, z));

  /// Beaker [i]'s base centre (where a drag along the table grabs it), its
  /// middle (hand drop target) and spot [i].
  Offset beakerBasePoint(int i) => proj.p(beakers[i].pos);
  Offset beakerPoint(int i) => proj.p(beakers[i].middle);
  Offset spotPoint(int i) => proj.p(_spots[i]);
  bool beakerPlaced(int i) => beakers[i].placed;

  /// Hand [i]'s palm (0 right, 1 left) and how it feels.
  Offset handPoint(int i) => proj.p(hands[i].palm);
  String handFeel(int i) => hands[i].feel.name;

  Offset get s2HandPoint => proj.p(s2Pose.palm);
  Offset get foreheadPoint => proj.p(_forehead);
  Offset get mouthPoint => proj.p(_mouth);
  Offset get boxPoint => proj.p(_boxCentre + const _V(0, 0, 2));
  Offset get thermPoint => proj.p(therm);
  bool get thermometerReady => thermReady;
  bool get thermometerOut => thermOut;
  bool get thermometerInMouth => inMouth;
  double? get thermometerReading => measured ? reading : null;

  /// HTML `resetScenarioState(sc)`: every object home, step 1.
  void load(int index) {
    scenario = index;
    step = 1;
    tweens.clear();
    for (final b in beakers) {
      b.reset();
    }
    for (final h in hands) {
      h.reset();
    }
    s2Wrist = _s2HandHome;
    touched = false;
    s2HandWarm = false;
    boxOpen = false;
    lid = 0;
    thermVisible = false;
    thermReady = false;
    thermOut = false;
    inMouth = false;
    therm = _thermInBox;
    thermTurn = 0;
    reading = null;
    measured = false;
    face = _FaceState.sick;
    fever = false;
    question = false;
    tick = false;
    smiley = false;
    dragKind = null;
    dragIndex = -1;
  }

  void tween(
    double seconds,
    void Function(double k) apply, {
    double Function(double t) ease = _linear,
    _Kind kind = _Kind.other,
    int index = 0,
    double delay = 0,
    VoidCallback? onComplete,
  }) {
    tweens.add(
      _Tween(
        start: time + delay,
        duration: seconds,
        apply: apply,
        ease: ease,
        kind: kind,
        index: index,
        onComplete: onComplete,
      ),
    );
  }

  /// Moves a point from [from] to [to] over [seconds] (owned by an object).
  void moveTween(
    double seconds,
    _V from,
    _V to,
    void Function(_V v) set, {
    required _Kind kind,
    int index = 0,
    VoidCallback? onComplete,
  }) => tween(
    seconds,
    (k) => set(_V.lerp(from, to, k)),
    kind: kind,
    index: index,
    onComplete: onComplete,
  );

  /// Stops the tweens that move [kind] / [index] (the learner grabbed it).
  void cancelTweens(_Kind kind, int index) =>
      tweens.removeWhere((t) => t.kind == kind && t.index == index);

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    if (tweens.isEmpty) return;
    final finished = <_Tween>[];
    for (final tw in List.of(tweens)) {
      if (tw.update(time)) finished.add(tw);
    }
    tweens.removeWhere(finished.contains);
    for (final tw in finished) {
      tw.onComplete?.call();
    }
  }
}

/// Pan recogniser that only joins the gesture arena when [canGrab] picks up
/// an object of the current step at pointer-down (HTML `pointerdown`
/// raycast), so every other drag still reaches the zoom viewer.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

/// Grows [r] to at least [min] × [min] around its centre.
Rect _atLeast(Rect r, double min) => Rect.fromCenter(
  center: r.center,
  width: math.max(r.width, min),
  height: math.max(r.height, min),
);

class _TouchLabState extends State<Ch7A1HotnessColdnessAndTheSenseOfTouchPage>
    with SingleTickerProviderStateMixin {
  // HTML `State.isCamLocked = true`: drags interact with the scene.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for finger-sized hit areas.
  double _fit = 1;

  /// Visible design-space columns of the stage (for label clamping and
  /// where a let-go thermometer may rest).
  double _visibleLeft = 0;
  double _visibleRight = _design.width;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

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

  /// HTML `animate()`: tweens and the framing, then one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    final target = _lab.isSidebarOpen ? 0.0 : 1.0;
    if (s.framingT != target) {
      final stepT = dt / _framingSeconds;
      s.framingT = s.framingT < target
          ? math.min(target, s.framingT + stepT)
          : math.max(target, s.framingT - stepT);
    }
    s.updateTweens();
    _frame.value = now;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: clears pending
  /// timers and tweens and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// Moves on from step [from] after [delay] (HTML `setTimeout(progressStep,
  /// …)`), unless the scenario or step changed meanwhile.
  void _advanceAfter(Duration delay, int from) {
    final s = _scene;
    final scenario = s.scenario;
    _lab.after(delay, () {
      if (!mounted || s.scenario != scenario || s.step != from) return;
      setState(() => s.step = from + 1);
      if (s.scenario == 1 && s.step == _stepCount) _showResult();
    });
  }

  /// HTML `progressStep()` into Scenario 2 step 4: the tick and smiley
  /// appear, Lambok smiles (no blush) and the hand goes back.
  void _showResult() {
    final s = _scene;
    s
      ..question = false
      ..tick = true
      ..smiley = true
      ..face = _FaceState.happy
      ..fever = false
      ..s2HandWarm = false;
    s.moveTween(
      _handHomeTween,
      s.s2Wrist,
      _s2HandHome,
      (v) => s.s2Wrist = v,
      kind: _Kind.s2Hand,
    );
  }

  void _toast(
    String key, {
    bool isError = false,
    bool sound = true,
    Map<String, Object>? values,
  }) {
    final text = values == null ? _t(key) : labFormat(_t(key), values);
    _lab.showToast(text, isError: isError, sound: sound);
  }

  /// HTML `triggerConclusion()` / `showObservationPopup()`: the summary of
  /// the scenario (Scenario 2 adds the HTML's final "Mastery Achieved!"
  /// text). Tapped again later it re-opens the summary.
  void _observeConclusion() {
    final s = _scene;
    if (s.step < _stepCount || !_lab.isLabActive) return;
    _Sound.pop.play();
    final index = s.scenario;
    if (s.step == _stepCount) setState(() => s.step = _doneStep);
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: 2,
      delay: _conclusionDelay,
      heading: () => index == 0
          ? labFormat(_t('sc_complete'), {'n': 1})
          : _t('all_complete'),
      body: () => index == 0
          ? '${_t('s1_sum_title')}\n\n${_t('s1_sum')}'
          : '${_t('s2_sum_title')}\n\n${_t('s2_sum')}\n\n'
                '${_t('all_complete_desc')}',
    );
  }

  // ------------------------------------------------------------ hit tests

  /// Screen rect of beaker [b] (at least a finger wide).
  Rect _beakerRect(_Beaker b) {
    final proj = _scene.proj;
    final top = proj.oval(b.pos + const _V(0, _beakerHeight, 0), _beakerTopR);
    final bottom = proj.oval(b.pos, _beakerBottomR);
    return _atLeast(top.expandToInclude(bottom), _minTouch / _fit);
  }

  Rect _handRect(_HandPose pose) =>
      _atLeast(_scene.proj.bounds(pose.outline).inflate(4), _minTouch / _fit);

  Rect _thermRect() {
    final s = _scene;
    final r = s.proj.bounds([
      s.thermWorld(_tipFar),
      s.thermWorld(const _V(2.25, 0.3, 0)),
      s.thermWorld(const _V(2.25, -0.3, 0)),
      s.thermWorld(const _V(-2.25, 0.3, 0)),
    ]);
    return _atLeast(r.inflate(4), _minTouch / _fit);
  }

  Rect _boxRect() {
    final c = _boxCentre, h = _boxHalf;
    return _atLeast(
      _scene.proj.bounds([
        for (var i = 0; i < 8; i++)
          _V(
            c.x + (i & 1 == 0 ? -h.x : h.x),
            c.y + (i & 2 == 0 ? -h.y : h.y + 0.5),
            c.z + (i & 4 == 0 ? -h.z : h.z),
          ),
      ]),
      _minTouch / _fit,
    );
  }

  /// HTML `pointerdown` raycast: the object of the current step under
  /// [at], nearest to the camera first.
  (_Kind, int)? _pick(Offset at) {
    final s = _scene;
    final proj = s.proj;
    (_Kind, int)? best;
    var bestDepth = double.infinity;
    void consider(_Kind kind, int index, Rect rect, _V centre) {
      if (!rect.contains(at)) return;
      final d = proj.depth(centre);
      if (d < bestDepth) {
        bestDepth = d;
        best = (kind, index);
      }
    }

    if (s.scenario == 0) {
      if (s.step == 1) {
        for (final b in s.beakers) {
          if (!b.placed) {
            consider(_Kind.beaker, b.index, _beakerRect(b), b.middle);
          }
        }
      } else if (s.step == 2 || s.step == 3) {
        for (final h in s.hands) {
          if (h.stage == s.step - 2) {
            consider(_Kind.hand, h.index, _handRect(h.pose), h.palm);
          }
        }
      }
    } else {
      if (s.step == 1 && !s.touched) {
        consider(_Kind.s2Hand, 0, _handRect(s.s2Pose), s.s2Pose.palm);
      }
      if ((s.step == 2 || s.step == 3) && s.thermReady && !s.inMouth) {
        consider(_Kind.thermometer, 0, _thermRect(), s.therm);
      }
    }
    return best;
  }

  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _scene.dragKind != null) return false;
    return _pick(event.localPosition) != null;
  }

  /// The point of [kind] that follows the finger.
  _V _dragPoint(_Kind kind, int index) {
    final s = _scene;
    return switch (kind) {
      _Kind.beaker => s.beakers[index].pos,
      _Kind.hand => s.hands[index].palm,
      _Kind.s2Hand => s.s2Pose.palm,
      _Kind.thermometer => s.therm,
      _Kind.other => _V.zero,
    };
  }

  // -------------------------------------------------------------- gestures

  /// HTML `pointerdown` on a draggable object: drag plane and grab offset.
  /// Beakers slide on the table top (y = 0); hands and the thermometer move
  /// on the plane facing the camera through their drag point (HTML
  /// `dragPlane.setFromNormalAndCoplanarPoint(camera direction, …)`).
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final hit = _pick(d.localPosition);
    if (hit == null) return;
    final (kind, index) = hit;
    s
      ..dragKind = kind
      ..dragIndex = index
      ..cancelTweens(kind, index);
    final point = _dragPoint(kind, index);
    s.dragFrom = point;
    if (kind == _Kind.beaker) {
      s
        ..planeN = _V.up
        ..planeD = 0;
    } else {
      s
        ..planeN = _Proj.f
        ..planeD = _Proj.f.dot(point);
    }
    final onPlane = s.proj.onPlane(d.localPosition, s.planeN, s.planeD);
    s.grabOffset = onPlane == null ? _V.zero : onPlane - point;
    if (kind == _Kind.hand) s.hands[index].inBeaker = -1;
    setState(() {});
  }

  /// HTML `pointermove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final kind = s.dragKind;
    if (kind == null) return;
    final hit = s.proj.onPlane(d.localPosition, s.planeN, s.planeD);
    if (hit == null) return;
    final point = hit - s.grabOffset;
    switch (kind) {
      case _Kind.beaker:
        s.beakers[s.dragIndex].pos = _V(
          point.x.clamp(-_tableDragX, _tableDragX),
          0,
          point.z.clamp(-_tableDragZ, _tableDragZ),
        );
      case _Kind.hand:
        final h = s.hands[s.dragIndex];
        h.wrist = point - (h.palm - h.wrist);
      case _Kind.s2Hand:
        s.s2Wrist = point - (s.s2Pose.palm - s.s2Wrist);
      case _Kind.thermometer:
        s.therm = point;
        if (s.step == 2 &&
            !s.thermOut &&
            (point - _thermPopped).length > _takeOutDistance) {
          setState(() {
            s
              ..thermOut = true
              ..step = 3;
          });
          _Sound.pop.play();
          _toast('toast_therm_out', sound: false);
        }
      case _Kind.other:
        break;
    }
  }

  /// HTML `pointerup` + `checkDrop(obj)`.
  void _release() {
    final s = _scene;
    final kind = s.dragKind;
    final index = s.dragIndex;
    s
      ..dragKind = null
      ..dragIndex = -1;
    if (kind == null || !mounted) return;
    final moved =
        (_dragPoint(kind, index) - s.dragFrom).length > _moveThreshold;
    switch (kind) {
      case _Kind.beaker:
        _dropBeaker(index, moved);
      case _Kind.hand:
        _dropHand(index, moved);
      case _Kind.s2Hand:
        _dropS2Hand(moved);
      case _Kind.thermometer:
        _dropThermometer(moved);
      case _Kind.other:
        break;
    }
    setState(() {});
  }

  /// Step 1: on its own spot the beaker snaps there (300 ms); all three
  /// placed, step 2 follows 500 ms later. Anywhere else it slides back
  /// (400 ms) and, after a real drag, a toast says where it goes.
  void _dropBeaker(int i, bool moved) {
    final s = _scene;
    final b = s.beakers[i];
    final from = b.pos;
    if (_xzDist(from, _spots[i]) < _snapDist) {
      s.moveTween(
        _snapTween,
        from,
        _spots[i],
        (v) => b.pos = v,
        kind: _Kind.beaker,
        index: i,
      );
      b.placed = true;
      _Sound.pop.play();
      if (s.beakers.every((x) => x.placed)) {
        _advanceAfter(_beakersDoneDelay, 1);
      }
      return;
    }
    s.moveTween(
      _returnTween,
      from,
      _beakerHomes[i],
      (v) => b.pos = v,
      kind: _Kind.beaker,
      index: i,
    );
    if (moved) {
      const letters = ['A', 'B', 'C'];
      const liquids = ['lbl_warm', 'lbl_tap', 'lbl_ice'];
      _toast(
        'err_beaker',
        isError: true,
        values: {'l': letters[i], 'liquid': _t(liquids[i])},
      );
    }
  }

  /// The beaker whose middle is within [_dipRadius] (on screen) of [palm],
  /// or -1.
  int _beakerUnder(_V palm) {
    final s = _scene;
    final proj = s.proj;
    final at = proj.p(palm);
    var best = -1;
    var bestD = double.infinity;
    for (final b in s.beakers) {
      final m = b.middle;
      final d = (proj.p(m) - at).distance;
      if (d < _dipRadius * proj.scaleAt(m) && d < bestD) {
        bestD = d;
        best = b.index;
      }
    }
    return best;
  }

  /// Step 2: the right hand dips into beaker A (hot), the left one into
  /// beaker C (cold); both in, step 3 follows 1 s later. Step 3: both move
  /// into beaker B, where the feelings swap; step 4 follows 1.5 s later. A
  /// hand let go elsewhere goes back (home in step 2, its first beaker in
  /// step 3, where the HTML sent it back up into the air).
  void _dropHand(int i, bool moved) {
    final s = _scene;
    final h = s.hands[i];
    final over = _beakerUnder(h.palm);
    final from = h.wrist;
    void moveTo(_V to, double seconds) => s.moveTween(
      seconds,
      from,
      to,
      (v) => h.wrist = v,
      kind: _Kind.hand,
      index: i,
    );
    if (s.step == 2 && h.stage == 0) {
      if (over == h.firstBeaker) {
        moveTo(_dipFirst[i], _snapTween);
        h
          ..stage = 1
          ..inBeaker = h.firstBeaker
          ..feel = i == 0 ? _Feel.hot : _Feel.cold;
        _Sound.dip.play();
        _toast(i == 0 ? 'feel_r_hot' : 'feel_l_cold', sound: false);
        if (s.hands.every((x) => x.stage >= 1)) {
          _advanceAfter(_handsFirstDelay, 2);
        }
      } else {
        moveTo(_handHomes[i], _returnTween);
        if (moved || over >= 0) {
          _toast(i == 0 ? 'err_dip_r' : 'err_dip_l', isError: true);
        }
      }
      return;
    }
    if (s.step == 3 && h.stage == 1) {
      if (over == 1) {
        moveTo(_dipTap[i], _snapTween);
        h
          ..stage = 2
          ..inBeaker = 1
          ..feel = i == 0 ? _Feel.cold : _Feel.hot;
        _Sound.dip.play();
        _toast(i == 0 ? 'feel_r_cold' : 'feel_l_warm', sound: false);
        if (s.hands.every((x) => x.stage == 2)) {
          _advanceAfter(_handsTapDelay, 3);
        }
      } else {
        h.inBeaker = h.firstBeaker;
        moveTo(_dipFirst[i], _returnTween);
        if (moved) _toast('err_dip_b', isError: true);
      }
    }
  }

  /// Step 1: on the forehead the hand rests there (300 ms), turns red,
  /// Lambok's forehead glows and a question mark appears; step 2 follows
  /// 1.5 s later. Elsewhere it goes back with a toast.
  void _dropS2Hand(bool moved) {
    final s = _scene;
    final proj = s.proj;
    final from = s.s2Wrist;
    final d = (proj.p(s.s2Pose.palm) - proj.p(_forehead)).distance;
    if (s.step == 1 && d < _foreheadRadius * proj.scaleAt(_forehead)) {
      s.moveTween(
        _snapTween,
        from,
        _s2HandOnForehead,
        (v) => s.s2Wrist = v,
        kind: _Kind.s2Hand,
      );
      s
        ..touched = true
        ..s2HandWarm = true
        ..fever = true
        ..question = true;
      _Sound.pop.play();
      _toast('feel_forehead', sound: false);
      _advanceAfter(_foreheadDelay, 1);
      return;
    }
    s.moveTween(
      _returnTween,
      from,
      _s2HandHome,
      (v) => s.s2Wrist = v,
      kind: _Kind.s2Hand,
    );
    if (moved) _toast('err_forehead', isError: true);
  }

  /// Taps on the scene: the first-aid box (HTML `openBox()` in step 2).
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.dragKind != null) return;
    if (!_boxRect().contains(d.localPosition)) return;
    if (s.step == 1) {
      _toast('err_box_early', isError: true);
    } else if (s.step == 2 && !s.boxOpen) {
      _openBox();
    }
  }

  /// HTML `openBox()`: the lid swings open (500 ms) and the thermometer
  /// rises out (600 ms, Back.Out, after 300 ms). The learner then drags it
  /// out (the HTML moved on to step 3 by itself here).
  void _openBox() {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      s
        ..boxOpen = true
        ..thermVisible = true;
    });
    s
      ..tween(_lidTween, (k) => s.lid = k)
      ..tween(
        _riseTween,
        (k) => s.therm = _V.lerp(_thermInBox, _thermPopped, k),
        ease: _backOut,
        kind: _Kind.thermometer,
        delay: _riseDelay,
        onComplete: () {
          if (!mounted) return;
          setState(() => s.thermReady = true);
          _toast('toast_box_open', sound: false);
        },
      );
  }

  /// Step 3: at the mouth the thermometer goes in (300 ms, tilted), Lambok
  /// opens his mouth and the reading starts 1 s later. On the rest of the
  /// head it is refused and floats back over the box. Elsewhere it stays
  /// where it was let go (out of the box), or floats back if that is off
  /// the scene.
  void _dropThermometer(bool moved) {
    final s = _scene;
    final proj = s.proj;
    final from = s.therm;
    void floatBack() => s.moveTween(
      _returnTween,
      from,
      _thermPopped,
      (v) => s.therm = v,
      kind: _Kind.thermometer,
    );
    if (!s.thermOut) {
      floatBack();
      return;
    }
    final mouth = proj.p(_mouth);
    final reach = _mouthRadius * proj.scaleAt(_mouth);
    final tip = proj.p(s.thermWorld(_tipFar));
    final middle = proj.p(from);
    if ((tip - mouth).distance < reach || (middle - mouth).distance < reach) {
      s
        ..inMouth = true
        ..face = _FaceState.open;
      s
        ..moveTween(
          _snapTween,
          from,
          _thermInMouth,
          (v) => s.therm = v,
          kind: _Kind.thermometer,
        )
        ..tween(_snapTween, (k) => s.thermTurn = k);
      _lab.after(_measureDelay, _measure);
      return;
    }
    final head = proj.p(_headCentre);
    final headR = _headR * proj.scaleAt(_headCentre) * _headRefuse;
    final onHead = (middle - head).distance < headR;
    final offScene =
        middle.dy < _restTop ||
        middle.dy > _restBottom ||
        middle.dx < _visibleLeft + _restSide ||
        middle.dx > _visibleRight - _restSide;
    if (onHead || offScene) floatBack();
    if (onHead && moved) _toast('err_mouth', isError: true);
  }

  /// HTML `measureTemp()`: the display counts from 35.0 to 37.0 °C over
  /// 1.5 s; then the thermometer beeps (the HTML beeped at the start; a
  /// digital thermometer beeps when its reading is ready) and step 4
  /// follows 1 s later.
  void _measure() {
    final s = _scene;
    if (!mounted || s.scenario != 1 || !s.inMouth) return;
    final scenario = s.scenario;
    s.reading = _readingFrom;
    _toast('toast_measuring', sound: false);
    s.tween(
      _measureTween,
      (k) => s.reading = _readingFrom + (_readingTo - _readingFrom) * k,
      onComplete: () {
        if (!mounted || s.scenario != scenario) return;
        setState(() {
          s
            ..reading = _readingTo
            ..measured = true;
        });
        _Sound.beep.play();
        _toast('toast_reading', sound: false);
        _advanceAfter(_resultDelay, 3);
      },
    );
  }

  // --------------------------------------------------------------- framing

  /// Collapsed-sidebar framing for the current scenario: slides (and if
  /// needed shrinks) the scene into the room right of the floating mission
  /// card. Uses the shell's own card width ([_missionCardWidth]).
  void _syncCollapsedFraming(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0 && fit.isFinite)) return;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final cardRight =
        _missionCardLeft + pad.left + _missionCardWidth(size, context.labScale);
    // Hit tests stop at the design box, so the scene stays inside it.
    final freeLeft = math.max(0.0, (cardRight + _cardGap - stageLeft) / fit);
    final freeRight = math.min(
      _design.width - _cardGap,
      (size.width -
              labOverlayInsets(context, _lab).right -
              _cardGap -
              stageLeft) /
          fit,
    );
    final (left, right) = _scene.scenario == 0 ? _s1Extent : _s2Extent;
    var zoom = 1.0, shift = 0.0;
    if (freeLeft > left || freeRight < right) {
      zoom = math.min(1.0, (freeRight - freeLeft) / (right - left));
      final slack = (freeRight - freeLeft) - (right - left) * zoom;
      shift =
          freeLeft +
          slack / 2 -
          _stageCentre.dx -
          zoom * (left - _stageCentre.dx);
    }
    _scene
      ..collapsedZoom = zoom
      ..collapsedShift = shift;
  }

  /// Visible design-space columns of the stage: right of the sidebar or the
  /// mission card, left of the tool column.
  (double, double) _visibleColumns(BuildContext context, BoxConstraints box) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final stageLeft = (box.maxWidth - _design.width * _fit) / 2;
    final right =
        (box.maxWidth - labOverlayInsets(context, _lab).right - stageLeft) /
        _fit;
    final leftEdge = _lab.isSidebarOpen
        ? 0.0
        : _missionCardLeft +
              pad.left +
              _missionCardWidth(size, context.labScale) +
              _cardGap;
    return (math.max(0.0, (leftEdge - stageLeft) / _fit), right);
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#compare-btn-container` ('Observe Conclusion'), shown from step
  /// 4; after the conclusion it re-opens the summary.
  LabAction _concludeAction() => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.indigo600,
    highlight: _scene.step == _stepCount,
    silent: true,
    onTap: _observeConclusion,
  );

  List<LabAction> _actions() =>
      _scene.step < _stepCount ? const [] : [_concludeAction()];

  /// The HTML shows 'Observe Conclusion' on the canvas, just above the HUD
  /// (`bottom-28`, bouncing). While the sidebar is open its copy there is
  /// below the fold on a phone, so the canvas copy is kept for step 4 (the
  /// floating mission card carries it while the sidebar is collapsed).
  List<Widget> _overlays(BuildContext context, double s) {
    if (!_lab.isLabActive ||
        !_lab.isSidebarOpen ||
        _lab.popup != null ||
        _scene.step != _stepCount) {
      return const [];
    }
    final inset = labOverlayInsets(context, _lab);
    return [
      Positioned(
        key: const ValueKey('ch7-a1-conclude'),
        left: inset.left,
        right: inset.right,
        bottom: inset.bottom + _hudClearance * s,
        child: Center(
          child: LabActionButton(
            action: _concludeAction(),
            scale: s,
            expand: false,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final sc = _scene.scenario;
        _syncCollapsedFraming(context);
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: _actions(),
          overlays: _overlays(context, s),
          // HTML `#hud-instruction` (`hud[State.step]`); it goes once the
          // conclusion is open.
          showHud: _scene.step <= _stepCount,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, _stepCount)}'),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _ExplorationList(
            key: ValueKey('explore-$sc-${_scene.step}'),
            steps: data.steps,
            current: _scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
          stage: _buildStage(),
        );
      },
    );
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        final (visibleLeft, visibleRight) = _visibleColumns(context, box);
        _visibleLeft = visibleLeft;
        _visibleRight = visibleRight;
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags and taps on the scene are not screen-reader actions;
            // the scene is announced by its label instead.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
                  ),
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      // A RawGestureDetector does not take MediaQuery's
                      // gesture settings; short drags must pick up.
                      ..gestureSettings = _dragSettings
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onDown = _onDown
                      ..onUpdate = _onDragUpdate
                      ..onEnd = ((_) => _release())
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
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    labelScale: labelScale,
                    visibleLeft: visibleLeft,
                    visibleRight: visibleRight,
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

/// HTML teacher board "Conceptual Exploration": one card per step; the
/// current step is open with its concept and action, done steps show a tick
/// and open to show their observation too, future steps stay closed. (The
/// HTML let future steps open and showed the current step's observation
/// before the learner acted, giving the results away.)
class _ExplorationList extends StatefulWidget {
  const _ExplorationList({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.conceptLabel,
    required this.actionLabel,
    required this.observationLabel,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String conceptLabel;
  final String actionLabel;
  final String observationLabel;

  @override
  State<_ExplorationList> createState() => _ExplorationListState();
}

class _ExplorationListState extends State<_ExplorationList> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
  final Set<int> _toggled = {};

  /// The current step is open; once the scenario is done, the last one.
  bool _isOpen(int i) =>
      (i == math.min(widget.current, widget.steps.length)) !=
      _toggled.contains(i);

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
    final future = i > w.current;
    final open = !future && _isOpen(i);
    final dim = future ? 0.55 : 1.0;
    final tone = current
        ? p.ink(_Colors.indigo400)
        : (past ? p.info : p.textMuted);
    final border = current
        ? _Colors.indigo500
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    TextSpan labelled(String label, String text, Color labelColor) => TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: TextStyle(color: labelColor, fontWeight: FontWeight.w800),
        ),
        TextSpan(text: text),
      ],
    );

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
                constraints: const BoxConstraints(minHeight: _minTouch),
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
                              ? _Colors.indigo500
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? _Colors.indigo400
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
                                      ? _Colors.white
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
                  Text.rich(
                    labelled(w.conceptLabel, step.concept, p.accentInk),
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    labelled(w.actionLabel, step.action, p.textStrong),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  // The observation once the learner has made it.
                  if (past) ...[
                    SizedBox(height: 6 * s),
                    Text.rich(
                      labelled(
                        w.observationLabel,
                        step.observation,
                        p.textStrong,
                      ),
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11.5 * f,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
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

// ================================================================== PAINTING

/// Paints reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Thick butt-ended lines (shading bands, metal tip).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// Round-ended lines (fingers, icon strokes).
  final Paint cap = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// The pulsing highlight of the object to use.
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();
  final Path pathA = Path();
  final Path pathB = Path();
}

/// What the painter makes once and reuses: pens, the static backdrop
/// (background, table / pillow and head), icon shapes, the face paints and
/// the text painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _fixed = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  Object? _backdropKey;

  double get labelSize => _labelSize;

  /// Hot icon: three red waves (HTML `drawCanvasIcon('hot')`).
  final Path hot = () {
    final p = Path();
    for (var i = 0; i < 3; i++) {
      final x = 64.0 + i * 64;
      p
        ..moveTo(x, 200)
        ..cubicTo(x, 150, x - 40, 100, x, 56);
    }
    return p;
  }();

  /// Cold icon: a six-armed snowflake around (128, 128).
  final Path cold = () {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      Offset rot(double x, double y) => Offset(
        128 + x * math.cos(a) - y * math.sin(a),
        128 + x * math.sin(a) + y * math.cos(a),
      );
      final o = rot(0, 0), tip = rot(0, -100);
      final l = rot(-20, -60), m = rot(0, -80), r = rot(20, -60);
      p
        ..moveTo(o.dx, o.dy)
        ..lineTo(tip.dx, tip.dy)
        ..moveTo(l.dx, l.dy)
        ..lineTo(m.dx, m.dy)
        ..lineTo(r.dx, r.dy);
    }
    return p;
  }();

  /// Steam over the warm water (64 × 128 canvas, two curls).
  final Path steam = Path()
    ..moveTo(20, 110)
    ..cubicTo(0, 60, 40, 50, 20, 10)
    ..moveTo(44, 120)
    ..cubicTo(64, 70, 24, 60, 44, 20);

  /// Tick (HTML `drawCanvasIcon('check')`).
  final Path tick = Path()
    ..moveTo(50, 130)
    ..lineTo(100, 180)
    ..lineTo(200, 70);

  /// Lambok's eyebrows (happy: arched; sick: slanted).
  final Path browsHappy = Path()
    ..moveTo(140, 170)
    ..quadraticBezierTo(180, 140, 220, 170)
    ..moveTo(292, 170)
    ..quadraticBezierTo(332, 140, 372, 170);
  final Path browsSick = Path()
    ..moveTo(150, 160)
    ..lineTo(210, 190)
    ..moveTo(362, 160)
    ..lineTo(302, 190);

  /// The face disc (clip of the blush).
  final Path faceDisk = Path()
    ..addOval(Rect.fromCircle(center: const Offset(256, 256), radius: 256));

  /// Fever blush: radial gradient from (256, 120) r 20 to (256, 140) r 180.
  final Paint blush = Paint()
    ..shader = ui.Gradient.radial(
      const Offset(256, 140),
      180,
      const [_Colors.blush, _Colors.blushClear],
      null,
      TileMode.clamp,
      null,
      const Offset(256, 120),
      20,
    );

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeMap(_labels);
    _lang = lang;
    _labelSize = labelSize;
  }

  /// A scene label in white bold at the label size.
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Text that does not depend on the language (beaker letters, the '?',
  /// the thermometer's digits), by text, size, colour and weight. Digits
  /// are tabular (fixed width, like the HTML's monospace display) so the
  /// counting reading does not jitter.
  TextPainter fixed(
    String text,
    double size,
    Color color, {
    FontWeight weight = FontWeight.w900,
  }) =>
      _fixed['$text|$size|${color.toARGB32()}|${weight.value}'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            height: 1.1,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// The static part of the scene, recorded once per scenario, theme and
  /// framing.
  ui.Picture backdrop(_Scene s, _Proj proj, bool dark, Size size) {
    final key = (s.scenario, dark, proj.centre, proj.focal);
    final cached = _backdrop;
    if (cached != null && key == _backdropKey) return cached;
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), s.scenario, proj, dark, size, pens);
    _backdropKey = key;
    return _backdrop = recorder.endRecording();
  }

  /// Keeps the digit painters from piling up while the reading counts.
  void trimFixed() {
    if (_fixed.length > 64) _disposeMap(_fixed);
  }

  static void _disposeMap(Map<String, TextPainter> map) {
    for (final tp in map.values) {
      tp.dispose();
    }
    map.clear();
  }

  void dispose() {
    _disposeMap(_labels);
    _disposeMap(_fixed);
    _backdrop?.dispose();
    _backdrop = null;
  }
}

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

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.proj, this.pens);

  final Canvas canvas;
  final _Proj proj;
  final _Pens pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat quad (already lit [color]); optional [edge] colour.
  void quad(_V a, _V b, _V c, _V d, Color color, {Color? edge}) {
    final path = pens.path..reset();
    final pts = [a, b, c, d];
    for (var i = 0; i < 4; i++) {
      _move(path, i, proj.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 1
          ..color = edge,
      );
    }
  }

  /// A box centred at [c] with half-size axes [ax], [ay], [az] (any
  /// orientation): the faces turned to the camera, lit.
  void obox(
    _V c,
    _V ax,
    _V ay,
    _V az,
    Color color, {
    double opacity = 1,
    Color? edge,
  }) {
    final axes = [ax, ay, az];
    for (var k = 0; k < 3; k++) {
      final a = axes[k], u = axes[(k + 1) % 3], v = axes[(k + 2) % 3];
      for (final sign in const [1.0, -1.0]) {
        final mid = c + a * sign;
        final n = a.unit * sign;
        if (n.dot(_eye - mid) <= 0) continue;
        quad(
          mid - u - v,
          mid + u - v,
          mid + u + v,
          mid - u + v,
          _lit(color, n, opacity: opacity),
          edge: edge?.withValues(alpha: edge.a * opacity),
        );
      }
    }
  }

  /// A finger-like round-ended rod from [a] to [b].
  void capsule(_V a, _V b, double r, Color color) {
    final pa = proj.p(a), pb = proj.p(b);
    final w = math.max(1.5, 2 * r * proj.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      pa,
      pb,
      pens.cap
        ..strokeWidth = w
        ..color = labShade(color, -0.15),
    );
    canvas.drawLine(
      pa,
      pb,
      pens.cap
        ..strokeWidth = w * 0.5
        ..color = labShade(color, 0.12),
    );
  }

  /// A round metal rod (CylinderGeometry lying along [a]–[b]).
  void rod(_V a, _V b, double r, Color color) {
    final pa = proj.p(a), pb = proj.p(b);
    final w = math.max(1.5, 2 * r * proj.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      pa,
      pb,
      pens.bar
        ..strokeWidth = w
        ..color = color,
    );
    canvas.drawLine(
      pa,
      pb,
      pens.bar
        ..strokeWidth = w * 0.3
        ..color = labShade(color, 0.5),
    );
  }

  /// Glow along [a]–[b] [width] design px wide (pulsing highlight).
  void glowLine(Offset a, Offset b, double width, double alpha) {
    canvas.drawLine(
      a,
      b,
      pens.glow
        ..strokeWidth = width
        ..color = _Colors.zslYellow.withValues(alpha: alpha),
    );
  }

  /// Glow around [path].
  void glowPath(Path path, double alpha, {double width = 8}) {
    canvas.drawPath(
      path,
      pens.glow
        ..strokeWidth = width
        ..color = _Colors.zslYellow.withValues(alpha: alpha),
    );
  }
}

/// Draws the 2D texture of size [tex] (an HTML canvas texture) as a sprite
/// [world] units wide at [at]: [draw] paints in the texture's own pixels.
void _sprite(
  Canvas canvas,
  _Proj proj,
  _V at,
  double world,
  double tex,
  void Function() draw,
) {
  final c = proj.p(at);
  final k = world * proj.scaleAt(at) / tex;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(k);
  canvas.translate(-tex / 2, -tex / 2);
  draw();
  canvas.restore();
}

/// The scene's static layer: background, then the table with its three
/// spots (S1) or the pillow with Lambok's head and hair (S2).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  _Proj proj,
  bool dark,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final g = _Gfx(canvas, proj, pens);
  if (scenario == 0) {
    g.obox(
      _tableCentre,
      _V(_tableHalf.x, 0, 0),
      _V(0, _tableHalf.y, 0),
      _V(0, 0, _tableHalf.z),
      _Colors.table,
      edge: labShade(_Colors.table, 0.25),
    );
    for (final spot in _spots) {
      canvas.drawOval(
        proj.oval(spot + const _V(0, 0.01, 0), _spotRadius),
        pens.stroke
          ..strokeWidth = _spotWidth * proj.scaleAt(spot)
          ..color = _Colors.spot,
      );
    }
    return;
  }
  // The pillow behind the head.
  g.obox(
    _pillowCentre,
    _V(_pillowHalf.x, 0, 0),
    _V(0, _pillowHalf.y, 0),
    _V(0, 0, _pillowHalf.z),
    _Colors.pillow,
    edge: _Colors.pillowEdge,
  );
  // The head: SphereGeometry(3.5), MeshStandardMaterial 0xfcd34d.
  final c = proj.p(_headCentre);
  final r = _headR * proj.scaleAt(_headCentre);
  labSphere(canvas, c, r, _Colors.boySkin, highlight: 0.3, shade: 0.35);
  canvas.drawPath(_hairPath(proj), pens.fill..color = _Colors.hair);
}

/// The hair: a 100° cap of a sphere (r 3.6, 0.5 above the head centre)
/// tilted back by 60°. Its edge is projected along the front of the head,
/// then the outline closes over the top of the hair sphere.
Path _hairPath(_Proj proj) {
  final pole = _rotX(_V.up, -math.pi / 3);
  final capAngle = math.pi / 1.8;
  final centre = _hairCentre + pole * (_hairR * math.cos(capAngle));
  final radius = _hairR * math.sin(capAngle);
  const e1 = _V(1, 0, 0);
  final e2 = pole.cross(e1);
  const steps = 24;
  final path = Path();
  late Offset first, last;
  for (var i = 0; i <= steps; i++) {
    final t = math.pi + math.pi * i / steps;
    final o = proj.p(
      centre + e1 * (radius * math.cos(t)) + e2 * (radius * math.sin(t)),
    );
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
      first = o;
    } else {
      path.lineTo(o.dx, o.dy);
    }
    last = o;
  }
  final s = proj.p(_hairCentre);
  final rs = _hairR * proj.scaleAt(_hairCentre);
  final aEnd = math.atan2(last.dy - s.dy, last.dx - s.dx);
  var aStart = math.atan2(first.dy - s.dy, first.dx - s.dx);
  if (aStart < aEnd) aStart += 2 * math.pi;
  path
    ..arcTo(
      Rect.fromCircle(center: s, radius: rs),
      aEnd,
      aStart - aEnd - 2 * math.pi,
      false,
    )
    ..close();
  return path;
}

/// Paints the HTML Three.js scene of the current scenario: S1 the table
/// with three beakers and two hands, S2 Lambok on his pillow with the hand,
/// the first-aid box and the thermometer. Static parts come from
/// [_PaintCache].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
    required this.visibleLeft,
    required this.visibleRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  /// Canvas text boost on small stages (1 … 1.8).
  final double labelScale;

  /// Visible design-space columns (labels stay inside them).
  final double visibleLeft;
  final double visibleRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  double get _glowAlpha => _glowMin + (_glowMax - _glowMin) * scene.pulse;

  @override
  void paint(Canvas canvas, Size size) {
    cache
      ..prepare(lang, _labelPx * labelScale)
      ..trimFixed();
    final proj = scene.proj;
    canvas.drawPicture(cache.backdrop(scene, proj, isDark, size));
    final g = _Gfx(canvas, proj, _pens);
    if (scene.scenario == 0) {
      _paintTable(g);
    } else {
      _paintBedside(g);
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _paintTable(_Gfx g) {
    final s = scene;
    final proj = g.proj;
    if (showLabels) {
      // Position labels on the table, while their spot is free.
      const keys = ['lbl_pos_a', 'lbl_pos_b', 'lbl_pos_c'];
      for (var i = 0; i < 3; i++) {
        if (s.beakers[i].placed) continue;
        _chip(
          g.canvas,
          proj.p(_spots[i] + _spotLabelOffset),
          _t(keys[i]),
          plain: true,
        );
      }
    }
    // Shadows under the beakers.
    for (final b in s.beakers) {
      final o = proj.oval(b.pos, _beakerBottomR * 1.05);
      g.canvas.drawOval(
        o.translate(-o.width * 0.08, o.height * 0.1),
        _pens.shadow,
      );
    }
    // Beakers (with the hands dipped in them) and free hands, far to near.
    final order = <(double, int)>[
      for (final b in s.beakers) (proj.depth(b.middle), b.index),
      for (final h in s.hands)
        if (h.inBeaker < 0) (proj.depth(h.palm), 10 + h.index),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, id) in order) {
      if (id < 10) {
        final b = s.beakers[id];
        _paintBeaker(g, b, [
          for (final h in s.hands)
            if (h.inBeaker == id) h,
        ], s.glows(_Kind.beaker, id) ? _glowAlpha : 0);
      } else {
        final h = s.hands[id - 10];
        _paintHand(
          g,
          h.pose,
          h.skin,
          s.glows(_Kind.hand, h.index) ? _glowAlpha : 0,
        );
      }
    }
    // Hot / cold icons and labels (sprites, always in front).
    for (final h in s.hands) {
      if (h.feel == _Feel.none) continue;
      final at = h.wrist + _V(h.side * _dippedLabelOut, _dippedIconUp, 0);
      _feelIcon(g, at, h.feel);
    }
    if (!showLabels) return;
    // Name labels in front of the beakers; on a small stage a label that
    // would touch its neighbour drops below it.
    const names = ['lbl_warm', 'lbl_tap', 'lbl_ice'];
    final placed = <Rect>[];
    for (final b in [
      ...s.beakers,
    ]..sort((a, c) => a.pos.x.compareTo(c.pos.x))) {
      final text = _t(names[b.index]);
      var rect = _chipRect(proj.p(b.pos + _nameLabelOffset), text);
      for (final other in placed) {
        if (rect.inflate(2).overlaps(other)) {
          rect = rect.translate(0, other.bottom + 4 - rect.top);
        }
      }
      placed.add(rect);
      _drawChip(g.canvas, rect, text);
    }
    for (final h in s.hands) {
      final at = h.inBeaker >= 0
          ? h.wrist + _V(h.side * _dippedLabelOut, _dippedLabelUp, 0)
          : h.wrist + _handLabelUp;
      _chip(g.canvas, proj.p(at), _t(h.index == 0 ? 'lbl_rhand' : 'lbl_lhand'));
    }
  }

  /// Fills [path] with the outline of a frustum standing on [base]: bottom
  /// circle (y0, r0), top circle (y1, r1).
  static void _frustum(
    Path path,
    _Proj proj,
    _V base,
    double y0,
    double r0,
    double y1,
    double r1,
  ) {
    final b = base + _V(0, y0, 0), t = base + _V(0, y1, 0);
    final bo = proj.oval(b, r0), to = proj.oval(t, r1);
    path
      ..reset()
      ..moveTo(to.left, to.center.dy)
      ..lineTo(bo.left, bo.center.dy)
      ..arcTo(bo, math.pi, -math.pi, false)
      ..lineTo(to.right, to.center.dy)
      ..arcTo(to, 0, -math.pi, false)
      ..close();
  }

  /// HTML `createBeaker`: glass (white, 0.3), water (opacity 0.8), ice cubes
  /// in C, steam over A, the letter on the glass. Dipped hands are drawn in
  /// the water, which tints them where they are under its surface.
  void _paintBeaker(_Gfx g, _Beaker b, List<_Hand> inside, double glow) {
    final canvas = g.canvas;
    final proj = g.proj;
    final c = b.pos;
    final glass = _pens.pathA;
    final water = _pens.pathB;
    _frustum(glass, proj, c, 0, _beakerBottomR, _beakerHeight, _beakerTopR);
    if (glow > 0) g.glowPath(glass, glow, width: 10);
    final bottom = proj.oval(c, _beakerBottomR);
    final top = proj.oval(c + const _V(0, _beakerHeight, 0), _beakerTopR);
    canvas.drawOval(
      bottom,
      _pens.fill..color = _Colors.glass.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      glass,
      _pens.fill..color = _Colors.glass.withValues(alpha: 0.1),
    );
    canvas.drawArc(
      top,
      math.pi,
      math.pi,
      false,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.glass.withValues(alpha: 0.35),
    );
    // Water with light and shade bands.
    const fluids = [_Colors.warm, _Colors.tap, _Colors.ice];
    final fluid = fluids[b.index];
    _frustum(
      water,
      proj,
      c,
      _waterBottom,
      _waterBottomR,
      _waterTop,
      _waterTopR,
    );
    canvas.drawPath(water, _pens.fill..color = fluid.withValues(alpha: 0.8));
    final wb = proj.oval(c + const _V(0, _waterBottom, 0), _waterBottomR);
    final wt = proj.oval(c + const _V(0, _waterTop, 0), _waterTopR);
    canvas.save();
    canvas.clipPath(water);
    canvas.drawLine(
      Offset(wt.center.dx - wt.width * 0.22, wt.center.dy),
      Offset(wb.center.dx - wb.width * 0.22, wb.bottom),
      _pens.bar
        ..strokeWidth = wb.width * 0.16
        ..color = labShade(fluid, 0.3).withValues(alpha: 0.5),
    );
    canvas.drawLine(
      Offset(wt.center.dx + wt.width * 0.4, wt.center.dy),
      Offset(wb.center.dx + wb.width * 0.4, wb.bottom),
      _pens.bar
        ..strokeWidth = wb.width * 0.2
        ..color = labShade(fluid, -0.35).withValues(alpha: 0.5),
    );
    canvas.restore();
    canvas.drawOval(
      wt,
      _pens.fill..color = labShade(fluid, 0.25).withValues(alpha: 0.85),
    );
    if (b.index == 2) {
      for (final cube in _iceCubes) {
        g.obox(
          c + cube.$1,
          cube.$2,
          cube.$3,
          cube.$4,
          _Colors.iceCube,
          edge: _Colors.slate300.withValues(alpha: 0.6),
        );
      }
    }
    for (final h in inside) {
      _paintHand(g, h.pose, h.skin, 0);
    }
    if (inside.isNotEmpty) {
      canvas.drawPath(water, _pens.fill..color = fluid.withValues(alpha: 0.35));
      canvas.drawOval(
        wt,
        _pens.stroke
          ..strokeWidth = 1.2
          ..color = labShade(fluid, 0.4).withValues(alpha: 0.8),
      );
    }
    // Front of the glass: sides, bottom and rim, and a highlight.
    final rim = _pens.stroke
      ..strokeWidth = 1.4
      ..color = _Colors.glass.withValues(alpha: 0.6);
    canvas
      ..drawLine(
        Offset(top.left, top.center.dy),
        Offset(bottom.left, bottom.center.dy),
        rim,
      )
      ..drawLine(
        Offset(top.right, top.center.dy),
        Offset(bottom.right, bottom.center.dy),
        rim,
      )
      ..drawArc(bottom, 0, math.pi, false, rim)
      ..drawArc(top, 0, math.pi, false, rim)
      ..drawLine(
        Offset(top.left + top.width * 0.2, top.center.dy + top.height * 0.6),
        Offset(bottom.left + bottom.width * 0.2, bottom.center.dy - 3),
        _pens.cap
          ..strokeWidth = math.max(1.5, top.width * 0.05)
          ..color = _Colors.glass.withValues(alpha: 0.28),
      );
    if (showLabels) {
      const letters = ['A', 'B', 'C'];
      final at = c + _letterOffset;
      final size = _letterHeight * proj.scaleAt(at);
      final tp = cache.fixed(
        letters[b.index],
        size.roundToDouble(),
        _Colors.white,
      );
      tp.paint(canvas, proj.p(at) - Offset(tp.width / 2, tp.height / 2));
    }
    if (b.index == 0) {
      // The steam sprite (64 × 128 canvas, 3 units tall).
      final at = c + _steamOffset;
      final k = _steamHeight * proj.scaleAt(at) / 128;
      final o = proj.p(at);
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.scale(k);
      canvas.translate(-32, -64);
      canvas.drawPath(
        cache.steam,
        _pens.cap
          ..strokeWidth = 6
          ..color = _Colors.steam,
      );
      canvas.restore();
    }
  }

  /// `createStylizedHand`: palm box, four fingers and the thumb, hanging
  /// down; with the pulsing glow when it is the hand to drag.
  void _paintHand(_Gfx g, _HandPose pose, Color skin, double glow) {
    final proj = g.proj;
    final s = pose.scale;
    final fingers = [
      for (var i = 0; i < 4; i++)
        (
          pose.world(_V(_fingerX(i), _fingerBase, 0)),
          pose.world(_V(_fingerX(i), _fingerTip, 0)),
        ),
    ];
    final thumb = (pose.world(_thumbBase), pose.world(_thumbTip));
    if (glow > 0) {
      for (final (a, b) in [...fingers, thumb]) {
        final w = 2 * _fingerR * s * proj.scaleAt(a) + 8;
        g.glowLine(proj.p(a), proj.p(b), w, glow);
      }
      final path = _pens.path..reset();
      final corners = [
        for (final k in const [
          _V(-0.9, 0, 0.25),
          _V(0.9, 0, 0.25),
          _V(0.9, 2.2, 0.25),
          _V(-0.9, 2.2, 0.25),
        ])
          proj.p(pose.world(k)),
      ];
      path.addPolygon(corners, true);
      g.glowPath(path, glow);
    }
    for (final (a, b) in fingers) {
      g.capsule(a, b, _fingerR * s, skin);
    }
    g.capsule(thumb.$1, thumb.$2, _thumbR * s, skin);
    g.obox(
      pose.palm,
      pose.dir(_V(_palmHalf.x, 0, 0)),
      pose.dir(_V(0, _palmHalf.y, 0)),
      pose.dir(_V(0, 0, _palmHalf.z)),
      skin,
      edge: labShade(skin, -0.3),
    );
  }

  /// HTML `drawCanvasIcon('hot' | 'cold')` sprite (2 units).
  void _feelIcon(_Gfx g, _V at, _Feel feel) {
    final canvas = g.canvas;
    _sprite(canvas, g.proj, at, _feelIconSize, _iconTex, () {
      if (feel == _Feel.hot) {
        canvas.drawPath(
          cache.hot,
          _pens.cap
            ..strokeWidth = 20
            ..color = _Colors.hotIcon,
        );
      } else {
        canvas.drawPath(
          cache.cold,
          _pens.cap
            ..strokeWidth = 16
            ..color = _Colors.coldIcon,
        );
      }
    });
  }

  // ---------------------------------------------------------- scenario 2

  void _paintBedside(_Gfx g) {
    final s = scene;
    final proj = g.proj;
    final canvas = g.canvas;
    _paintFace(canvas, proj);
    // Question mark, tick and smiley sprites beside the head.
    if (s.question) _questionIcon(canvas, proj);
    if (s.tick) {
      _sprite(canvas, proj, _checkAt, _checkSize, _iconTex, () {
        canvas.drawPath(
          cache.tick,
          _pens.cap
            ..strokeWidth = 30
            ..color = _Colors.check,
        );
      });
    }
    if (s.smiley) _smileyIcon(canvas, proj);
    // The thermometer rising inside the box is covered by the box.
    final rising = s.thermVisible && !s.thermReady;
    if (rising) _paintThermometer(g, 0);
    _paintBox(g, s.glows(_Kind.other) ? _glowAlpha : 0);
    final thermFree = s.thermVisible && !rising;
    final handGlow = s.glows(_Kind.s2Hand) ? _glowAlpha : 0.0;
    final thermGlow = s.glows(_Kind.thermometer) ? _glowAlpha : 0.0;
    final skin = s.s2HandWarm ? _Colors.skinHot : _Colors.skin;
    final handDepth = proj.depth(s.s2Pose.palm);
    if (thermFree && proj.depth(s.therm) > handDepth) {
      _paintThermometer(g, thermGlow);
      _paintHand(g, s.s2Pose, skin, handGlow);
    } else {
      _paintHand(g, s.s2Pose, skin, handGlow);
      if (thermFree) _paintThermometer(g, thermGlow);
    }
    if (showLabels) {
      _chip(canvas, proj.p(_lambokLabelAt), _t('lbl_lambok'));
      _chip(canvas, proj.p(_boxLabelAt), _t('lbl_box'));
      _chip(canvas, proj.p(s.s2Wrist + _handLabelUp), _t('lbl_hand'));
      if (thermFree && !s.inMouth) {
        _chip(canvas, proj.p(s.therm + _thermLabelUp), _t('lbl_therm'));
      }
    }
    if (s.inMouth && s.reading != null) _paintCallout(g);
  }

  /// HTML `updateLambokFace(state, hasFever)`: the 512 × 512 face texture on
  /// the face disc (drawn over the head, like the HTML's depthTest: false).
  void _paintFace(Canvas canvas, _Proj proj) {
    final s = scene;
    final c = proj.p(_faceCentre);
    final k = _faceR * proj.scaleAt(_faceCentre) / (_faceTex / 2);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(k);
    canvas.translate(-_faceTex / 2, -_faceTex / 2);
    if (s.fever) {
      canvas.save();
      canvas.clipPath(cache.faceDisk);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 512, 300), cache.blush);
      canvas.restore();
    }
    final ink = _pens.cap
      ..strokeWidth = 14
      ..color = _Colors.faceInk;
    if (s.face == _FaceState.happy) {
      final fill = _pens.fill..color = _Colors.faceInk;
      canvas
        ..drawCircle(const Offset(180, 220), 24, fill)
        ..drawCircle(const Offset(332, 220), 24, fill)
        ..drawPath(cache.browsHappy, ink)
        ..drawArc(
          Rect.fromCircle(center: const Offset(256, 300), radius: 70),
          0,
          math.pi,
          false,
          ink,
        );
    } else {
      final tired = _pens.fill..color = _Colors.tired;
      canvas
        ..drawOval(
          Rect.fromCenter(
            center: const Offset(180, 240),
            width: 88,
            height: 48,
          ),
          tired,
        )
        ..drawOval(
          Rect.fromCenter(
            center: const Offset(332, 240),
            width: 88,
            height: 48,
          ),
          tired,
        )
        ..drawArc(
          Rect.fromCircle(center: const Offset(180, 220), radius: 32),
          math.pi,
          math.pi,
          false,
          ink,
        )
        ..drawArc(
          Rect.fromCircle(center: const Offset(332, 220), radius: 32),
          math.pi,
          math.pi,
          false,
          ink,
        )
        ..drawPath(cache.browsSick, ink);
      if (s.face == _FaceState.open) {
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(256, 350),
            width: 64,
            height: 112,
          ),
          _pens.fill..color = _Colors.faceInk,
        );
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(256, 380), radius: 50),
          math.pi,
          math.pi,
          false,
          ink,
        );
      }
    }
    canvas.restore();
  }

  /// HTML `drawCanvasIcon('question')`: white bubble with a dark '?'.
  void _questionIcon(Canvas canvas, _Proj proj) {
    _sprite(canvas, proj, _questionAt, _questionSize, _iconTex, () {
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(128, 128),
          width: 240,
          height: 200,
        ),
        _pens.fill..color = _Colors.question,
      );
      final tp = cache.fixed(
        '?',
        140,
        _Colors.faceInk,
        weight: FontWeight.w700,
      );
      tp.paint(canvas, Offset(128 - tp.width / 2, 140 - tp.height / 2));
    });
  }

  /// HTML `drawCanvasIcon('smiley')`.
  void _smileyIcon(Canvas canvas, _Proj proj) {
    _sprite(canvas, proj, _smileyAt, _smileySize, _iconTex, () {
      canvas
        ..drawCircle(
          const Offset(128, 128),
          120,
          _pens.fill..color = _Colors.smiley,
        )
        ..drawCircle(
          const Offset(80, 90),
          15,
          _pens.fill..color = _Colors.smileyInk,
        )
        ..drawCircle(const Offset(176, 90), 15, _pens.fill)
        ..drawArc(
          Rect.fromCircle(center: const Offset(128, 130), radius: 60),
          0,
          math.pi,
          false,
          _pens.cap
            ..strokeWidth = 15
            ..color = _Colors.smileyInk,
        );
    });
  }

  /// The first-aid box: white base with the red cross and the hinged lid;
  /// once open, its inside shows and the lid stands up behind it.
  void _paintBox(_Gfx g, double glow) {
    final s = scene;
    final proj = g.proj;
    final c = _boxCentre, h = _boxHalf;
    if (glow > 0) {
      final r = proj.bounds([
        for (var i = 0; i < 8; i++)
          _V(
            c.x + (i & 1 == 0 ? -h.x : h.x),
            c.y + (i & 2 == 0 ? -h.y : h.y + 0.5),
            c.z + (i & 4 == 0 ? -h.z : h.z),
          ),
      ]);
      final path = _pens.path
        ..reset()
        ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)));
      g.glowPath(path, glow, width: 10);
    }
    g.obox(
      c,
      _V(h.x, 0, 0),
      _V(0, h.y, 0),
      _V(0, 0, h.z),
      _Colors.box,
      edge: _Colors.boxEdge,
    );
    if (s.lid > 0.05) {
      const inset = 0.25;
      g.quad(
        _V(c.x - h.x + inset, _boxTopY + 0.001, c.z - h.z + inset),
        _V(c.x + h.x - inset, _boxTopY + 0.001, c.z - h.z + inset),
        _V(c.x + h.x - inset, _boxTopY + 0.001, c.z + h.z - inset),
        _V(c.x - h.x + inset, _boxTopY + 0.001, c.z + h.z - inset),
        _Colors.boxInside,
      );
    }
    // Red cross (40 × 100 bars on a 128 canvas, 2 × 2 units).
    _V tex(double u, double v) => _V(
      _crossCentre.x - 1 + u / _crossTex * 2,
      _crossCentre.y + 1 - v / _crossTex * 2,
      _crossCentre.z,
    );
    for (final (l, t, w, hh) in const [
      (44.0, 14.0, 40.0, 100.0),
      (14.0, 44.0, 100.0, 40.0),
    ]) {
      g.quad(
        tex(l, t),
        tex(l + w, t),
        tex(l + w, t + hh),
        tex(l, t + hh),
        _Colors.red500,
      );
    }
    final a = _lidOpenAngle * s.lid;
    g.obox(
      _lidHinge + _rotX(_lidOffset, a),
      const _V(3, 0, 0),
      _rotX(const _V(0, 0.25, 0), a),
      _rotX(const _V(0, 0, 2), a),
      _Colors.box,
      edge: _Colors.boxEdge,
    );
  }

  /// The digital thermometer: body, metal tip and its small display.
  void _paintThermometer(_Gfx g, double glow) {
    final s = scene;
    final proj = g.proj;
    final canvas = g.canvas;
    final tipA = s.thermWorld(_tipNear), tipB = s.thermWorld(_tipFar);
    final end = s.thermWorld(const _V(2.25, 0, 0));
    if (glow > 0) {
      g.glowLine(
        proj.p(tipB),
        proj.p(end),
        2 * _thermHalf.z * proj.scaleAt(s.therm) + 8,
        glow,
      );
    }
    g.rod(tipA, tipB, _tipRadius, _Colors.thermTip);
    g.obox(
      s.therm,
      s.thermDir(_V(_thermHalf.x, 0, 0)),
      s.thermDir(_V(0, _thermHalf.y, 0)),
      s.thermDir(_V(0, 0, _thermHalf.z)),
      _Colors.thermBody,
      edge: labShade(_Colors.thermBody, -0.4),
    );
    final lcd = s.thermWorld(_lcdOffset);
    final k = proj.scaleAt(lcd);
    final rect = Rect.fromCenter(
      center: proj.p(lcd),
      width: _lcdWidth * k,
      height: _lcdHeight * k,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.2)),
      _pens.fill..color = _Colors.lcdBg,
    );
    final size = (rect.height * 0.75).roundToDouble();
    if (size >= 6) {
      final tp = cache.fixed(
        _lcdText(s.reading),
        size,
        _Colors.lcdText,
        weight: FontWeight.w700,
      );
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  /// HTML `dummy.val.toFixed(1) + "°C"`, or '---' before the reading.
  static String _lcdText(double? reading) =>
      reading == null ? '---' : '${reading.toStringAsFixed(1)}°C';

  /// A magnified copy of the thermometer's display beside Lambok's head,
  /// with a line to the thermometer.
  void _paintCallout(_Gfx g) {
    final s = scene;
    final proj = g.proj;
    final canvas = g.canvas;
    final tp = cache.fixed(
      _lcdText(s.reading),
      (_calloutFont * labelScale).roundToDouble(),
      _Colors.lcdText,
      weight: FontWeight.w800,
    );
    final at = proj.p(_calloutAt);
    final rect = Rect.fromCenter(
      center: at,
      width: tp.width + tp.height * 0.9,
      height: tp.height * 1.5,
    );
    final lcd = proj.p(s.thermWorld(_lcdOffset));
    canvas.drawLine(
      lcd,
      Offset(rect.left + rect.width * 0.2, rect.bottom),
      _pens.cap
        ..strokeWidth = 2
        ..color = _Colors.lcdText.withValues(alpha: 0.7),
    );
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height * 0.25),
    );
    canvas
      ..drawRRect(rr.shift(const Offset(0, 3)), _pens.shadow)
      ..drawRRect(rr, _pens.fill..color = _Colors.lcdBg)
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 2
          ..color = _Colors.lcdText.withValues(alpha: s.measured ? 0.9 : 0.4),
      );
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  // ------------------------------------------------------------ labels

  /// HTML `createTextSprite`: a dark chip with an indigo border and white
  /// bold text centred on [at] (with [plain], the text alone, like the
  /// transparent Position labels). It is kept inside the visible columns.
  void _chip(Canvas canvas, Offset at, String text, {bool plain = false}) =>
      _drawChip(canvas, _chipRect(at, text), text, plain: plain);

  /// The chip of [text] centred on [at], kept inside the visible columns.
  Rect _chipRect(Offset at, String text) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final w = tp.width + 2 * size * _chipPadX;
    final h = tp.height + 2 * size * _chipPadY;
    final lo = visibleLeft + 4 + w / 2;
    final hi = visibleRight - 4 - w / 2;
    final cx = lo <= hi ? at.dx.clamp(lo, hi) : at.dx;
    return Rect.fromCenter(center: Offset(cx, at.dy), width: w, height: h);
  }

  void _drawChip(Canvas canvas, Rect rect, String text, {bool plain = false}) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * _chipPadX, padY = size * _chipPadY;
    final h = rect.height;
    if (!plain) {
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(h * 0.3));
      canvas
        ..drawRRect(rr, _pens.fill..color = _Colors.labelBg)
        ..drawRRect(
          rr,
          _pens.stroke
            ..strokeWidth = 1.5
            ..color = _Colors.labelBorder,
        );
    }
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale ||
      old.visibleLeft != visibleLeft ||
      old.visibleRight != visibleRight;
}

/// Ice cubes in beaker C: five 0.6 cubes (offset from the beaker's base
/// centre and their turned half axes). The HTML placed and turned them at
/// random; these are fixed so the beaker looks the same every time.
final List<(_V, _V, _V, _V)> _iceCubes = [
  for (final (x, y, z, a, b) in const [
    (-0.45, 1.7, 0.3, 0.4, 0.7),
    (0.4, 2.1, -0.35, 0.9, 0.2),
    (0.1, 2.4, 0.5, 0.3, 1.1),
    (-0.3, 2.3, -0.5, 1.2, 0.5),
    (0.55, 1.6, 0.45, 0.6, 0.9),
  ])
    (
      _V(x, y, z),
      _rotY(_rotX(const _V(0.3, 0, 0), a), b),
      _rotY(_rotX(const _V(0, 0.3, 0), a), b),
      _rotY(_rotX(const _V(0, 0, 0.3), a), b),
    ),
];

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
