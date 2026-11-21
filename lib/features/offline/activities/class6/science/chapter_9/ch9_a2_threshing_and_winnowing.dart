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

/// Class 6 Science • Chapter 9 • Activity 2
/// Methods of Separation (Threshing and Winnowing).
///
/// Native Flutter port of `Cl6S-Ch9-A2-Threshing_and_Winnowing.html`.
///
/// Scenario 1 (The Threshing Floor, 4 steps): the bundle of harvested wheat
/// stalks is dragged onto the wooden beating log and beaten against it five
/// times ('Beat Stalks' or a tap on the bundle). The grains fly off the ears
/// and pile up below the log, mixed with a little husk; the empty straw is
/// set aside.
///
/// Scenario 2 (The Power of Wind, 5 steps): the bamboo winnowing tray (soop)
/// scoops up the grain and husk mixture and is carried up onto the raised
/// platform. Tilted with the fan OFF, grains and husk fall straight down into
/// one mixed heap; with the fan ON the light husk is blown far to the side
/// while the heavy grains fall straight down: two separate heaps.
///
/// The Three.js scene is redrawn by a CustomPainter through a perspective
/// projection of the HTML camera (position (0, 16, 26), look-at (0, 3, 0),
/// fov 45°). Objects are dragged on horizontal planes, as the HTML
/// `dragPlane` does.
class Ch9A2ThreshingAndWinnowingPage extends StatefulWidget {
  const Ch9A2ThreshingAndWinnowingPage({super.key});

  @override
  State<Ch9A2ThreshingAndWinnowingPage> createState() => _WinnowingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with the Web Audio
/// API; they map to the closest bundled file: 'click' (buttons, the fan) ->
/// click, 'click' when an object is picked up -> pickup, 'thud' (the stalks
/// landing on the log, every beat, the tray put on the platform) and 'pour'
/// (the tray scooping the mixture, the tray tilting) -> drop, 'ding' (the
/// summary) -> success. A drop away from the target, a plain 'click' in the
/// HTML, now plays wrong with its hint.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// HTML 'click'.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// The shell's "right" tone (toasts without an error).
  correct('audio/class6/science/correct.mp3'),

  /// An object dropped away from its target, the tray tilted with the fan
  /// still off in step 4 (added hints).
  wrong('audio/class6/science/error.mp3'),

  /// HTML 'ding' with the summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'thud' and 'pour'.
  drop('audio/class6/science/drop.mp3'),

  /// HTML 'click' when an object is picked up.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
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
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo950 = Color(0xFF1E1B4B);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red600 = Color(0xFFDC2626);
  static const Color amber400 = Color(0xFFFBBF24);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// `materials`: soil 0x3f2e21, wood 0x78350f, stalk 0xd97706, straw
  /// 0xfef08a, grain 0xf59e0b, bamboo 0xb45309, metal 0x64748b, husk
  /// 0x92400e.
  static const Color soil = Color(0xFF3F2E21);
  static const Color wood = Color(0xFF78350F);
  static const Color stalk = Color(0xFFD97706);
  static const Color straw = Color(0xFFFEF08A);
  static const Color grain = Color(0xFFF59E0B);
  static const Color bamboo = Color(0xFFB45309);
  static const Color metal = slate500;
  static const Color husk = Color(0xFF92400E);

  /// `glowMat` 0xf59e0b (opacity 0.35): the drop rings; the wind streaks
  /// use the same material, a little stronger so they show on the soil.
  static const Color glow = Color(0x59F59E0B);
  static const Color wind = Color(0x80F59E0B);

  /// `update3DHighlight` pulse colour 0x6366f1.
  static const Color highlight = indigo500;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x4D000000);

  /// `.label-3d` glass chips: dark `rgba(15,23,42,0.92)` / light white,
  /// `border-indigo-400`.
  static const Color labelDark = Color(0xEB0F172A);
  static const Color labelLight = Color(0xF2FFFFFF);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML's brand colour is indigo (Enter Lab, the sidebar
/// tab, the HUD border): indigo-400 on the dark panels, indigo-600 on the
/// light ones.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo400, // dark:text-indigo-400
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600, // summary button from-indigo-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.indigo950, // header bg-indigo-600 (dark for text)
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // subtitle text-indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo600, // text-indigo-600
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.indigo50,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// say exactly what to do on a touch screen ("tap" instead of "click"; the
// HTML's 'Hold to Tilt Tray' is a press and hold on the tray or a tap on
// 'Tilt Tray'). The HTML's Hindi steps and summaries were shorter or said
// something else; they now say the same as the English. Hindi button names
// replace the English ones the HTML kept in its Hindi text. Toasts, the
// heap labels, the observation list and the scene descriptions are added.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Methods of Separation (Threshing and Winnowing)',
    'app_subtitle': 'Class 6 • Methods of Separation in Everyday Life',
    'scen_1_opt': 'Scenario 1: The Threshing Floor',
    'scen_2_opt': 'Scenario 2: The Power of Wind (Winnowing)',
    's1_desc':
        'To beat harvested wheat stalks against a stone or wooden log to separate the grain seeds from the stalks.',
    's2_desc':
        'To separate heavier grain seeds from lighter husk using moving air on a raised platform.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Place Stalks',
    's1_a1':
        'DRAG the wheat stalk bundle and DROP it on the glowing ring on top of the wooden log.',
    's1_o1':
        'Harvested crops consist of thousands of stalks attached to grain kernels.',
    's1_c2': 'Start Threshing',
    's1_a2':
        "Beat the stalks against the log 2 times: tap 'Beat Stalks' (or tap the bundle).",
    's1_o2':
        'Impact force loosens the attachment between grain seeds and dry stalks.',
    's1_c3': 'Complete Beating',
    's1_a3':
        "Keep beating: tap 'Beat Stalks' (or the bundle) until Beating Progress reaches 5 / 5.",
    's1_o3':
        'All golden grains detach and collect on the ground below the log.',
    's1_c4': 'Threshing Result',
    's1_a4':
        "The empty straw has been set aside. Observe the grain pile, then tap 'Finish Observation'.",
    's1_o4':
        'Threshing separates grains from stalks, leaving grains mixed with light husk.',
    // Scenario 2 steps.
    's2_c1': 'Scoop Mixture',
    's2_a1':
        'DRAG the bamboo winnowing tray (soop) onto the mixture pile to scoop up the threshed grain and husk.',
    's2_o1':
        'The mixture has heavy wheat grains combined with flaky, light husk.',
    's2_c2': 'Stand High',
    's2_a2':
        'DRAG the filled tray up and DROP it on the glowing ring on the raised platform.',
    's2_o2':
        'Standing at a height gives falling particles time to interact with air currents.',
    's2_c3': 'Without Wind',
    's2_a3':
        "Keep the fan OFF. PRESS and HOLD the tray on the platform to tilt it until it is empty (or tap 'Tilt Tray').",
    's2_o3':
        'Without blowing air, both grains and husk fall vertically into a single mixed heap.',
    's2_c4': 'With Wind',
    's2_a4':
        "The mixed heap is scooped back into the tray. Tap 'Fan: OFF' to turn the fan ON, then PRESS and HOLD the tray until it is empty (or tap 'Tilt Tray').",
    's2_o4':
        'Moving air blows lighter husk diagonally into a far pile, while heavy grains fall vertically below!',
    's2_c5': 'Conclusion',
    's2_a5':
        "Review the winnowing separation principle, then tap 'Finish Observation'.",
    's2_o5':
        'Winnowing separates components of a mixture based on density/weight differences using wind.',
    // HTML `hud` lines (the canvas "Current Task"). Step 3 no longer tells
    // the result ("to see them drop together") before it is observed.
    's1_hud_1':
        'Step 1: DRAG the bundle of harvested wheat stalks to the top of the wooden beating log.',
    's1_hud_2':
        "Step 2: Tap the 'Beat Stalks' button or tap the bundle to release grains.",
    's1_hud_3':
        "Step 3: Keep tapping 'Beat Stalks' until all grains are separated (5 / 5).",
    's1_hud_4':
        "Step 4: Threshing complete! Observe the separated grain pile and tap 'Finish Observation'.",
    's2_hud_1':
        'Step 1: DRAG the bamboo tray (soop) over the mixture pile to scoop mixed grains and husk.',
    's2_hud_2': 'Step 2: DRAG the filled soop onto the raised wooden platform.',
    's2_hud_3':
        "Step 3: With the fan OFF, PRESS and HOLD the tray (or tap 'Tilt Tray') and watch how grain and husk fall.",
    's2_hud_4':
        "Step 4: Turn ON the fan, then PRESS and HOLD the tray (or tap 'Tilt Tray') to winnow with wind!",
    's2_hud_5':
        "Step 5: Winnowing complete! Observe the two distinct piles and tap 'Finish Observation'.",
    // Buttons.
    'btn_beat': 'Beat Stalks',
    'btn_tilt': 'Tilt Tray',
    'fan_on': 'Fan: ON',
    'fan_off': 'Fan: OFF',
    'btn_finish': 'Finish Observation',
    'cnt_beat': 'Beating Progress: {c} / 5',
    // Canvas labels (HTML `createStdLabel`).
    'lbl_log': 'Beating Log',
    'lbl_stalks': 'Wheat Stalks Bundle',
    'lbl_mixpile': 'Grain & Husk Mixture Pile',
    'lbl_soop': 'Winnowing Tray (Soop)',
    'lbl_stand': 'Raised Platform',
    'lbl_fan': 'Electric Wind Fan',
    // Added: labels of the empty straw and of the heaps once they form.
    'lbl_straw': 'Empty Straw',
    'lbl_mixed': 'Mixed Heap',
    'lbl_grain': 'Grains',
    'lbl_husk': 'Husk',
    // Added: hints when an object is dropped away from its target or the
    // tray is tilted with the fan still off, and the refill of the tray.
    'e_log': 'Drop the wheat stalks on the glowing ring on top of the log.',
    'e_pile': 'Drag the tray onto the mixture pile to scoop it up.',
    'e_stand':
        'Drop the filled tray on the glowing ring on the raised platform.',
    'e_fan_off': "Turn ON the fan first: tap 'Fan: OFF'.",
    't_refill':
        'The mixed heap is scooped back into the tray for the next try.',
    // Summary popup (HTML `summary-modal`).
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1':
        'Threshing Complete! You just performed Threshing! Beating stalks releases grain seeds. But now the grains are mixed with light husk. How can we separate them?',
    'sum_s2':
        'Excellent Winnowing! You used Winnowing! Because husk is much lighter than grain, moving air carries it farther away, leaving clean grain ready for flour mills!',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Threshing floor with a wooden beating log and a bundle of harvested wheat stalks',
    'scene_s2':
        'Winnowing yard with a raised platform, an electric fan, a bamboo winnowing tray and a pile of grain and husk',
  },
  'hi': {
    'app_title': 'पृथक्करण की विधियाँ (थ्रेशिंग और निष्पावन)',
    'app_subtitle': 'कक्षा 6 • दैनिक जीवन में पृथक्करण की विधियाँ',
    'scen_1_opt': 'परिदृश्य 1: खलिहान में थ्रेशिंग',
    'scen_2_opt': 'परिदृश्य 2: हवा की शक्ति (निष्पावन)',
    's1_desc':
        'कटे हुए गेहूँ के डंठलों को पत्थर या लकड़ी के लट्ठे पर पीटकर अनाज के दानों को डंठलों से अलग करना।',
    's2_desc':
        'ऊँचे चबूतरे पर बहती हवा की मदद से भारी अनाज के दानों को हल्की भूसी से अलग करना।',
    's1_c1': 'डंठल रखें',
    's1_a1':
        'गेहूँ के डंठलों के गट्ठर को खींचें और लकड़ी के लट्ठे के ऊपर चमकते घेरे पर छोड़ें।',
    's1_o1':
        'कटी हुई फ़सल में हज़ारों डंठल होते हैं, जिनसे अनाज के दाने जुड़े रहते हैं।',
    's1_c2': 'पीटना शुरू करें',
    's1_a2':
        "डंठलों को लट्ठे पर 2 बार पीटें: 'डंठल पीटें' पर टैप करें (या गट्ठर पर टैप करें)।",
    's1_o2':
        'चोट लगने से अनाज के दानों और सूखे डंठलों का जुड़ाव ढीला हो जाता है।',
    's1_c3': 'पीटना पूरा करें',
    's1_a3':
        "पीटते रहें: 'डंठल पीटें' (या गट्ठर) पर तब तक टैप करें, जब तक थ्रेशिंग प्रगति 5 / 5 न हो जाए।",
    's1_o3':
        'सभी सुनहरे दाने डंठलों से छूटकर लट्ठे के नीचे ज़मीन पर इकट्ठा हो जाते हैं।',
    's1_c4': 'थ्रेशिंग का परिणाम',
    's1_a4':
        "खाली पुआल एक ओर रख दिया गया है। अनाज के ढेर को देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o4':
        'थ्रेशिंग से दाने डंठलों से अलग हो जाते हैं, पर दाने हल्की भूसी के साथ मिले रहते हैं।',
    's2_c1': 'मिश्रण उठाएँ',
    's2_a1':
        'बाँस के सूप (छाज) को खींचकर मिश्रण के ढेर पर छोड़ें, ताकि अनाज और भूसी का मिश्रण सूप में भर जाए।',
    's2_o1': 'मिश्रण में गेहूँ के भारी दाने और हल्की, परतदार भूसी दोनों हैं।',
    's2_c2': 'ऊँचाई पर',
    's2_a2':
        'भरे हुए सूप को खींचकर ऊपर ले जाएँ और ऊँचे चबूतरे पर चमकते घेरे पर छोड़ें।',
    's2_o2':
        'ऊँचाई से गिराने पर गिरते कणों को हवा के संपर्क में रहने का पर्याप्त समय मिलता है।',
    's2_c3': 'बिना हवा के',
    's2_a3':
        "पंखा बंद ही रहने दें। चबूतरे पर रखे सूप को खाली होने तक दबाकर रखें, ताकि वह झुका रहे (या 'सूप झुकाएँ' पर टैप करें)।",
    's2_o3':
        'हवा न चलने पर दाने और भूसी दोनों सीधे नीचे गिरकर एक ही मिले-जुले ढेर में इकट्ठा हो जाते हैं।',
    's2_c4': 'हवा के साथ',
    's2_a4':
        "मिले-जुले ढेर को वापस सूप में भर दिया जाता है। पंखा चालू करने के लिए 'पंखा: बंद' पर टैप करें, फिर सूप को खाली होने तक दबाकर रखें (या 'सूप झुकाएँ' पर टैप करें)।",
    's2_o4':
        'बहती हवा हल्की भूसी को तिरछा उड़ाकर दूर एक अलग ढेर में ले जाती है, जबकि भारी दाने सीधे नीचे गिरते हैं!',
    's2_c5': 'निष्कर्ष',
    's2_a5':
        "निष्पावन के सिद्धांत को समझें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o5':
        'निष्पावन में हवा की मदद से मिश्रण के घटकों को उनके भार (घनत्व) के अंतर के आधार पर अलग किया जाता है।',
    's1_hud_1':
        'चरण 1: कटे हुए गेहूँ के डंठलों के गट्ठर को खींचकर लकड़ी के लट्ठे के ऊपर रखें।',
    's1_hud_2':
        "चरण 2: दाने अलग करने के लिए 'डंठल पीटें' बटन या गट्ठर पर टैप करें।",
    's1_hud_3':
        "चरण 3: 'डंठल पीटें' पर तब तक टैप करते रहें, जब तक सभी दाने अलग न हो जाएँ (5 / 5)।",
    's1_hud_4':
        "चरण 4: थ्रेशिंग पूर्ण! अलग हुए अनाज का ढेर देखें और 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1':
        'चरण 1: अनाज और भूसी का मिश्रण भरने के लिए बाँस के सूप को खींचकर मिश्रण के ढेर पर ले जाएँ।',
    's2_hud_2': 'चरण 2: भरे हुए सूप को खींचकर ऊँचे लकड़ी के चबूतरे पर रखें।',
    's2_hud_3':
        "चरण 3: पंखा बंद रखकर सूप को दबाकर रखें (या 'सूप झुकाएँ' पर टैप करें) और देखें कि दाने और भूसी कैसे गिरते हैं।",
    's2_hud_4':
        "चरण 4: पंखा चालू करें, फिर हवा से फटकने के लिए सूप को दबाकर रखें (या 'सूप झुकाएँ' पर टैप करें)!",
    's2_hud_5':
        "चरण 5: निष्पावन पूर्ण! दो अलग-अलग ढेरों को देखें और 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_beat': 'डंठल पीटें',
    'btn_tilt': 'सूप झुकाएँ',
    'fan_on': 'पंखा: चालू',
    'fan_off': 'पंखा: बंद',
    'btn_finish': 'अवलोकन समाप्त करें',
    'cnt_beat': 'थ्रेशिंग प्रगति: {c} / 5',
    'lbl_log': 'पीटने का लट्ठा',
    'lbl_stalks': 'गेहूँ के डंठलों का गट्ठर',
    'lbl_mixpile': 'अनाज और भूसी का मिश्रण',
    'lbl_soop': 'सूप (छाज)',
    'lbl_stand': 'ऊँचा चबूतरा',
    'lbl_fan': 'बिजली का पंखा',
    'lbl_straw': 'खाली पुआल',
    'lbl_mixed': 'मिला-जुला ढेर',
    'lbl_grain': 'अनाज के दाने',
    'lbl_husk': 'भूसी',
    'e_log': 'गेहूँ के डंठलों को लट्ठे के ऊपर चमकते घेरे पर छोड़ें।',
    'e_pile': 'मिश्रण भरने के लिए सूप को खींचकर मिश्रण के ढेर पर ले जाएँ।',
    'e_stand': 'भरे हुए सूप को ऊँचे चबूतरे पर चमकते घेरे पर छोड़ें।',
    'e_fan_off': "पहले पंखा चालू करें: 'पंखा: बंद' पर टैप करें।",
    't_refill': 'अगली बार के लिए मिले-जुले ढेर को वापस सूप में भर दिया गया।',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1':
        'थ्रेशिंग पूर्ण! आपने थ्रेशिंग (गहाई) की! डंठलों को पीटने से अनाज के दाने अलग हो जाते हैं। पर अब दाने हल्की भूसी के साथ मिले हुए हैं। इन्हें कैसे अलग करें?',
    'sum_s2':
        'शानदार निष्पावन! आपने निष्पावन (फटकना) किया! भूसी दानों से बहुत हल्की होती है, इसलिए बहती हवा उसे दूर ले जाती है और साफ़ अनाज आटा चक्की के लिए तैयार रह जाता है!',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'खलिहान, जिसमें पीटने का लकड़ी का लट्ठा और कटे हुए गेहूँ के डंठलों का गट्ठर है',
    'scene_s2':
        'निष्पावन का आँगन, जिसमें ऊँचा चबूतरा, बिजली का पंखा, बाँस का सूप और अनाज व भूसी के मिश्रण का ढेर है',
  },
};

/// Scenarios and the number of steps of each (HTML `ScenariosData`).
const int _scenarioCount = 2;
const List<int> _stepCounts = [4, 5];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
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

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10–12 px label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make anything jump.
const double _maxFrameStep = 0.1;

/// While the sidebar is collapsed the scene slides right (and on small
/// screens shrinks) so the floating mission card at the top left leaves
/// everything the learner taps, drags or reads in view; the move follows
/// the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Gap (design px) kept between the scene and the mission card / tools.
const double _cardGap = 16;

/// Smallest scale the collapsed-sidebar fit may use.
const double _minFit = 0.6;

/// Design x extent of what the learner taps, drags or reads: Scenario 1
/// from the bundle's label to the grain pile, Scenario 2 from the tray at
/// home to the husk heap.
const (double, double) _floorExtent = (120, 690);
const (double, double) _yardExtent = (80, 800);

/// Key of the scene layer. Flows map scene design coordinates to the screen
/// through it, so they follow the collapsed-sidebar move.
const ValueKey<String> _sceneKey = ValueKey('ch9-a2-scene');

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Horizontal (x / z) distance between two points (HTML `Math.hypot` of
/// the x and z differences).
double _flat(_V a, _V b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z));

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage. [center] is where the look-at
/// point lands on the stage.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, Offset center) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, center, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final _V f;
  final _V r;
  final _V u;

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

  /// Where the ray through [s] meets the horizontal plane y = [h] (HTML
  /// `raycaster.ray.intersectPlane(dragPlane)` with an upward normal).
  _V? onPlaneY(Offset s, double h) {
    final dir = ray(s);
    if (dir.y.abs() < 1e-6) return null;
    final t = (h - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// HTML `resetCamera()` on a wide canvas: `camera.position.set(0, 16,
/// 26)`, `controls.target.set(0, 3, 0)` (Scenario 2).
final _Cam _camYard = _Cam(
  const _V(0, 16, 26),
  const _V(0, 3, 0),
  const Offset(500, 280),
);

/// Scenario 1: the same view from 20 % closer (0, 13.4, 20.8). The small
/// threshing floor filled only the middle third of the canvas, too small
/// on a phone.
final _Cam _camFloor = _Cam(
  const _V(0, 13.4, 20.8),
  const _V(0, 3, 0),
  const Offset(500, 280),
);

/// The camera of [scenario].
_Cam _camOf(int scenario) => scenario == 0 ? _camFloor : _camYard;

/// HTML `DirectionalLight(0xffffff, 0.65)` at (15, 25, 15), normalised.
const _V _light = _V(0.4575, 0.7625, 0.4575);

/// HTML `AmbientLight(0xffffff, 0.85)` plus the key light, toned down so
/// the lit faces do not all clip to white.
const double _ambient = 0.62;
const double _diffuse = 0.5;

/// HTML `update3DHighlight`: the object to handle pulses towards indigo,
/// `(sin(Date.now() * 0.008) + 1) / 2`.
const double _pulseRate = 8;
const double _pulseMax = 0.45;

/// HTML ground discs: `CylinderGeometry(20, 20, 1)` (Scenario 1) and
/// `CylinderGeometry(24, 24, 1)` (Scenario 2), top at y 0.
const double _floorR = 20;
const double _yardR = 24;
const int _groundSides = 64;

/// Segments of rims and rings (smooth enough at this size).
const int _ringSides = 28;

// ---------------------------------------------- scenario 1: threshing floor

/// `woodenLogS1`: CylinderGeometry(2.5, 2.8, 3.5) standing on the ground.
const double _logTopR = 2.5;
const double _logBottomR = 2.8;
const double _logH = 3.5;

/// `logZoneS1`: RingGeometry(2.6, 4.0) at y 3.55, shown in step 1.
const double _logRingIn = 2.6;
const double _logRingOut = 4.0;
const double _logRingY = 3.55;

/// `stalksGrpS1` at home, and on top of the log after the drop.
const _V _bundleHome = _V(-8, 1, 4);
const _V _bundleOnLog = _V(0, 3.8, 0);

/// `checkDrop`: the bundle counts as on the log within 3.8 (x / z) of its
/// axis.
const double _logRange = 3.8;

/// While dragged, the bundle rises from its home height to the log's top
/// as it nears the log (the HTML dragged it at y 1, so a drop on the
/// glowing ring, where the learner sees it, was refused); it is at full
/// height within this distance of the log's axis.
const double _logLiftFull = 3.0;

/// `beatStalks`: the bundle rises to (1.5, 6.5) in 150 ms and comes back
/// down (yoyo); it also swings its ears up a little (added).
const _V _beatTop = _V(1.5, 6.5, 0);
const double _beatRoll = 0.35;
const int _swingMs = 150;

/// Beats to complete step 2 and the scenario (HTML `beatCount >= 2`, 5).
const int _beatsForStep3 = 2;
const int _beatsNeeded = 5;

/// After the fifth beat the empty straw is set aside (HTML tween to
/// (-4, 1.2, -2) in 500 ms, which put it half inside the log).
const _V _strawSpot = _V(-6, 0.6, -1.5);
const int _strawMs = 500;

/// HTML tweens: onto the log / tray onto the pile or platform 400 ms; back
/// home 400 ms.
const int _snapMs = 400;
const int _returnMs = 400;

/// `stalksGrpS1`: 15 stalks, `CylinderGeometry(0.12, 0.12, 5.5)` lying
/// along x (tilted ±0.15 rad), within ±0.4 (x, y) and ±0.75 (z). Each now
/// carries a wheat ear at its +x end (added) that empties as it is beaten.
const int _stalkCount = 15;
const double _stalkHalf = 2.75;
const double _stalkR = 0.12;
const double _earLen = 1.1;
const double _earR = 0.22;

/// `grainPileS1`: 60 grains (`SphereGeometry(0.2)`) next to the log, shown
/// 12 per beat (`scale = beatCount * 0.2`). Every fourth piece is husk, as
/// threshing leaves the grains mixed with husk.
const int _pileCount = 60;
const int _bitsPerBeat = 12;
const _V _pileCentre = _V(3.4, 0, 0.9);
const double _pileR = 1.3;

/// Pile pieces stay this far from the log's axis (outside the log).
const double _pileClear = 3.0;
const double _pileGrainR = 0.2;

/// Knocked-off grains leave the ears one after another this far apart (s).
const double _bitStagger = 0.015;

// ------------------------------------------------ scenario 2: winnowing yard

/// `soopS2` at home: the HTML's (-11, 1.5, 4) was 3 units from the
/// mixture pile's centre, inside its 4.5 drop range, so a mere tap scooped
/// it; it now starts 6 units away.
const _V _soopStart = _V(-14, 1.5, 4);

/// `mixPileS2`: ConeGeometry(3, 1.8) at (-8, 0.3, 4), i.e. a mound of
/// radius 2 rising 1.2 above the ground; it shrinks once scooped (added).
const _V _mixAt = _V(-8, 0, 4);
const double _mixR = 2;
const double _mixH = 1.2;
const double _mixScooped = 0.8;

/// The filled tray rests on the pile (HTML tween to (-8, 2.2, 4)). The drop
/// counts within 3.5 of the pile's centre (HTML 4.5, see [_soopStart]).
const _V _soopFilled = _V(-8, 2.2, 4);
const double _scoopRange = 3.5;

/// On the platform the tray rests at its right edge, overhanging it, so
/// what it pours falls to the ground beside the platform (the HTML centred
/// it at (0, 8.5, 0), above the platform top that the grains fell through).
const _V _soopPour = _V(2.5, 8.5, 0);

/// `checkDrop`: on the platform within 4.5 (x / z) of its centre.
const double _standRange = 4.5;

/// While dragged in step 2 the tray rises from the pile to y 8 (HTML: `y =
/// 8` while dragged) as it nears the platform; full height within 3.2.
const double _standLift = 8;
const double _standLiftFull = 3.2;

/// `standS2`: four legs `CylinderGeometry(0.3, 0.3, 7)` at (±2, ±2) and a
/// top `BoxGeometry(6, 0.5, 6)` at y 7.
const double _legR = 0.3;
const double _legH = 7;
const double _legAt = 2;
const double _topHalf = 3;
const double _topY = 7;
const double _topHalfH = 0.25;

/// `standZoneS2`: RingGeometry(1.5, 3.2) at y 7.3, shown in step 2.
const double _standRingIn = 1.5;
const double _standRingOut = 3.2;
const double _standRingY = 7.3;

/// The tray: body `BoxGeometry(3.5, 0.3, 4.5)` and a raised back 0.8 high.
/// The back is on the side away from the pouring edge (the HTML put it
/// along the side facing away from the camera).
const double _trayHalfX = 1.75;
const double _trayHalfY = 0.15;
const double _trayHalfZ = 2.25;
const double _wallHalfX = 0.15;
const double _wallHalfY = 0.4;
const double _rimHalf = 0.1;

/// `trayFill`: 40 spheres of radius 0.2, grain and husk alternately.
const int _trayItems = 40;
const double _itemR = 0.2;

/// `startTilt`: the tray turns to π/5 in 300 ms; it pours once it is
/// tilted this far (fraction of the full tilt).
const double _maxTilt = math.pi / 5;
const double _tiltSeconds = 0.3;
const double _pourTilt = 0.7;

/// The HTML emptied the tray in 50 frames (`tiltProgress += 0.02`, under
/// a second) by shrinking it; here the 40 pieces leave the tray one by one
/// over 2 s so the falling grain and husk can be seen.
const double _pourSeconds = 2;
const double _emitGap = _pourSeconds / _trayItems;

/// Where the pieces leave the tray: its tilted edge (+x), across this part
/// of its width.
const double _lipSpread = 1.2;

/// Falling: grains drop freely (20 units / s²); husk drifts down at 4.5
/// units / s and, with the fan on, is blown sideways (the wind takes hold
/// over the first third of the fall).
const double _gravity = 20;
const double _huskSink = 4.5;
const double _windBend = 3;

/// HTML heaps: `grainHeapS2` (45 spheres within ±1.1) and `huskHeapS2` (45
/// flakes within ±1.75), here under the tray's edge and 6.8 units
/// downwind. Each piece that lands fills the next place of its heap.
const _V _grainHeapAt = _V(4.4, 0, 0);
const double _grainHeapR = 1.2;
const _V _huskHeapAt = _V(11.2, 0, 0);
const double _huskHeapR = 1.8;
const double _mixedHeapR = 1.4;

/// A heap gets its label once it holds this many pieces.
const int _heapLabelMin = 6;

/// Step 3's mixed heap is scooped back into the tray for step 4 (added; the
/// HTML refilled the tray from nowhere and poured the clean grains onto
/// the mixed heap): it starts 2.5 s after step 3 and takes 1.2 s.
const int _refillDelayMs = 2500;
const double _refillSeconds = 1.2;

/// `fanGrpS2` at (-7, 8.5, 0): pole `CylinderGeometry(0.2, 0.2, 8.5)`,
/// head `SphereGeometry(1.2)`, three blades `BoxGeometry(0.1, 2.8, 0.6)`
/// at (+1.3, 0, 0) turning about x.
const _V _fanHead = _V(-7, 8.5, 0);
const double _fanHeadR = 1.2;
const double _fanPoleR = 0.2;
const _V _fanHub = _V(-5.7, 8.5, 0);
const double _bladeHalfLen = 1.4;
const double _bladeHalfW = 0.3;
const double _bladeHalfT = 0.05;

/// `fanBladesS2.rotation.x += 0.45` per frame while on (27 rad / s at 60
/// fps). Switched off, the fan now spins down and stops (the HTML kept it
/// turning slowly at 0.02 per frame).
const double _fanSpin = 27;
const double _fanAccel = 30;

/// `windParticlesS2`: streaks 1.8 long moving 0.45 per frame (27 units /
/// s) from x -5 to 18, in z ±1.5. The HTML kept them at the fan's height
/// (y 6.5–9.5); they now reach down through the falling stream (y 1.5–9.5)
/// so the learner sees the moving air carry the husk.
const int _windCount = 32;
const double _windSpeed = 27;
const double _windStartX = -5;
const double _windEndX = 18;
const double _windLen = 1.8;
const double _windR = 0.04;

/// Where the labels sit (world units). Scenario 1: the log's at its foot
/// (clear of the bundle beaten on top and of the grains falling to its
/// right), the beating progress in front of the grain pile, the bundle's /
/// straw's above it. Scenario 2: the mixture pile's at its front foot
/// (clear of the tray resting on it), the platform's between its front
/// legs, the fan's above its head (the HTML's sat at the top edge, under
/// the toasts), the tray's above it or, on the platform, right of it, and
/// each heap's in front of it.
const _V _logLabelAt = _V(0, 0.3, 3.4);
const _V _beatChipAt = _V(2.5, 0, 5.5);
const double _bundleLabelUp = 3;
const double _strawLabelUp = 2.5;
const _V _mixLabelAt = _V(-8, 0, 6.4);
const _V _standLabelAt = _V(0, 4.2, 2);
const _V _fanLabelAt = _V(-7, 10.4, 0);
const double _soopLabelUp = 3;
const _V _soopLabelBeside = _V(_trayHalfX + 0.45, 0.8, 0);
const double _heapLabelGap = 0.9;

/// Contents of a heap place.
const int _none = -1;
const int _grainKind = 0;
const int _huskKind = 1;

/// The objects the learner drags.
enum _Obj { bundle, soop }

/// How a falling piece moves sideways: knocked off the ears (straight
/// line), dropped from the tray (straight down, settling into the heap at
/// the end) or blown by the wind.
enum _Fall { thrown, drops, blown }

/// One stalk of the bundle: its offset in the bundle and its tilt.
@immutable
class _Stalk {
  const _Stalk(this.offset, this.tilt);

  final _V offset;
  final double tilt;
}

/// The bundle's stalks (fixed, so every run looks the same), far to near.
final List<_Stalk> _stalks = () {
  final rnd = math.Random(11);
  return [
    for (var i = 0; i < _stalkCount; i++)
      _Stalk(
        _V(
          (rnd.nextDouble() - 0.5) * 0.8,
          (rnd.nextDouble() - 0.5) * 0.8,
          (rnd.nextDouble() - 0.5) * 1.5,
        ),
        (rnd.nextDouble() - 0.5) * 0.3,
      ),
  ]..sort((a, b) => a.offset.z.compareTo(b.offset.z));
}();

/// One grain or husk flake on the tray.
@immutable
class _Item {
  const _Item(this.local, this.husk);

  final _V local;
  final bool husk;
}

/// `trayFill` (x ±1.25, y 0.3–0.6, z ±1.5), sorted so the pieces nearest
/// the pouring edge leave first.
final List<_Item> _trayFill = () {
  final rnd = math.Random(17);
  return [
    for (var i = 0; i < _trayItems; i++)
      _Item(
        _V(
          (rnd.nextDouble() - 0.5) * 2.5,
          0.3 + rnd.nextDouble() * 0.3,
          (rnd.nextDouble() - 0.5) * 3,
        ),
        i.isOdd,
      ),
  ]..sort((a, b) => b.local.x.compareTo(a.local.x));
}();

/// Grain and husk specks on the front of the mixture pile (offsets from
/// its base centre), far to near.
final List<_Item> _mixSpecks = () {
  final rnd = math.Random(19);
  return [
    for (var i = 0; i < 30; i++)
      () {
        final a = (rnd.nextDouble() * 1.2 - 0.1) * math.pi;
        final h = (0.05 + rnd.nextDouble() * 0.8) * _mixH;
        final r = _mixR * (1 - h / _mixH) * 0.98;
        return _Item(_V(math.cos(a) * r, h, math.sin(a) * r), i.isOdd);
      }(),
  ]..sort((a, b) => a.local.z.compareTo(b.local.z));
}();

/// Where the wind streaks start (x) and run (y, z).
final List<_V> _windSeeds = () {
  final rnd = math.Random(41);
  return [
    for (var i = 0; i < _windCount; i++)
      _V(
        _windStartX + rnd.nextDouble() * (_windEndX - _windStartX),
        1.5 + rnd.nextDouble() * 8,
        (rnd.nextDouble() - 0.5) * 3,
      ),
  ];
}();

/// [count] places of a heap of [radius] around [centre], lowest first (the
/// heap builds up from the ground), at least [clear] from the y axis.
List<_V> _heapSlots(
  int seed,
  _V centre,
  double radius,
  int count, {
  double rise = 0.5,
  double clear = 0,
}) {
  final rnd = math.Random(seed);
  final out = <_V>[];
  while (out.length < count) {
    final a = rnd.nextDouble() * 2 * math.pi;
    final r = math.sqrt(rnd.nextDouble()) * radius;
    final x = centre.x + math.cos(a) * r;
    final z = centre.z + math.sin(a) * r;
    if (math.sqrt(x * x + z * z) < clear) continue;
    final k = r / radius;
    final y = 0.15 + rise * (1 - k * k) * (0.55 + 0.45 * rnd.nextDouble());
    out.add(_V(x, y, z));
  }
  return out..sort((a, b) => a.y.compareTo(b.y));
}

/// The places of [slots] in drawing order (far to near) for [cam].
List<int> _depthOrder(List<_V> slots, _Cam cam) =>
    [for (var i = 0; i < slots.length; i++) i]
      ..sort((a, b) => cam.depth(slots[b]).compareTo(cam.depth(slots[a])));

final List<_V> _pileSlots = _heapSlots(
  23,
  _pileCentre,
  _pileR,
  _pileCount,
  rise: 0.55,
  clear: _pileClear,
);
final List<_V> _mixedSlots = _heapSlots(
  29,
  _grainHeapAt,
  _mixedHeapR,
  _trayItems,
  rise: 0.6,
);
final List<_V> _grainSlots = _heapSlots(
  31,
  _grainHeapAt,
  _grainHeapR,
  _trayItems ~/ 2,
);
final List<_V> _huskSlots = _heapSlots(
  37,
  _huskHeapAt,
  _huskHeapR,
  _trayItems ~/ 2,
  rise: 0.35,
);

/// A heap of grain and husk pieces: which of its places are filled.
class _Heap {
  _Heap(this.slots, this.centre, this.radius, _Cam cam)
    : order = _depthOrder(slots, cam),
      kinds = List.filled(slots.length, _none);

  final List<_V> slots;
  final _V centre;
  final double radius;

  /// Places in drawing order (far to near).
  final List<int> order;

  /// What lies in each place: [_none], [_grainKind] or [_huskKind].
  final List<int> kinds;

  /// Places handed to falling pieces so far, and pieces landed.
  int assigned = 0;
  int shown = 0;

  /// The next free place (lowest first).
  int take() => assigned++ % slots.length;

  /// A piece landed in [slot].
  void show(int slot, bool husk) {
    if (kinds[slot] == _none) shown++;
    kinds[slot] = husk ? _huskKind : _grainKind;
  }

  /// Keeps the [count] lowest places (the rest is scooped away).
  void keep(int count) {
    for (var i = count; i < slots.length; i++) {
      if (kinds[i] != _none) {
        kinds[i] = _none;
        shown--;
      }
    }
    assigned = math.min(assigned, count);
  }

  void clear() => keep(0);
}

/// [u] of a fall bent by the wind: the husk drifts slowly at first and
/// faster once the wind has taken hold (`x(t) = W·(t − (1 − e^(−kt)) / k)`,
/// scaled to 0 … 1).
double _windCurve(double u) {
  const k = _windBend;
  final end = 1 - (1 - math.exp(-k)) / k;
  return (u - (1 - math.exp(-k * u)) / k) / end;
}

/// A grain or husk flake on its way from [from] to its heap place [to].
@immutable
class _Bit {
  const _Bit({
    required this.husk,
    required this.from,
    required this.to,
    required this.start,
    required this.seconds,
    required this.fall,
    required this.heap,
    required this.slot,
  });

  final bool husk;
  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final _Fall fall;
  final _Heap heap;
  final int slot;

  bool landed(double t) => t >= start + seconds;

  _V at(double t) {
    final u = ((t - start) / seconds).clamp(0.0, 1.0);
    // Grains fall freely (accelerating); husk sinks slowly and evenly.
    final fy = husk ? u : u * u;
    final fx = switch (fall) {
      _Fall.thrown => u,
      _Fall.drops => u * u * u,
      _Fall.blown => _windCurve(u),
    };
    return _V(
      from.x + (to.x - from.x) * fx,
      from.y + (to.y - from.y) * fy,
      from.z + (to.z - from.z) * u,
    );
  }
}

/// A straight move between two points over [seconds] from [start] (scene
/// time), eased by [curve] (a TWEEN.js tween on `position`).
@immutable
class _Move {
  const _Move(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Move.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, curve.transform((t - start) / seconds));
  }
}

/// A number eased from [from] to [to] (a TWEEN.js tween on a scalar).
@immutable
class _Anim {
  const _Anim(this.from, this.to, this.start, this.seconds);

  const _Anim.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0;

  final double from;
  final double to;
  final double start;
  final double seconds;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * (t - start) / seconds;
  }
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// HTML `State.isAnimating`: an object glides or the bundle swings, and
  /// the scene ignores drags and beats meanwhile.
  bool busy = false;

  /// 'Finish Observation' was tapped: the scenario is complete.
  bool done = false;

  /// The object being dragged.
  _Obj? held;

  _Move bundle = const _Move.still(_bundleHome);
  _Move soop = const _Move.still(_soopStart);

  /// Where a refused tray goes back to (`userData.homePos`).
  _V soopHome = _soopStart;

  /// Grains and husk flakes in the air.
  final List<_Bit> bits = [];

  // ------------------------------------------------------------ scenario 1
  /// HTML `State.beatCount`.
  int beats = 0;

  /// Scene time of the last beat's swing.
  double swingAt = -10;

  /// The stalks are empty straw (HTML `strawMat`).
  bool straw = false;

  /// How full the wheat ears still are (1 … 0).
  _Anim ears = const _Anim.still(1);
  final _Heap pile = _Heap(_pileSlots, _pileCentre, _pileR, _camFloor);

  // ------------------------------------------------------------ scenario 2
  /// The tray has scooped the mixture (the pile is smaller).
  bool scooped = false;

  /// Pieces still on the tray.
  int trayLeft = 0;

  /// HTML `State.isFanOn`, the blades' speed (rad / s) and angle.
  bool fanOn = false;
  double fanSpeed = 0;
  double fanAngle = 0;

  /// HTML `soopS2.rotation.z` as a fraction of the full tilt.
  _Anim tilt = const _Anim.still(0);

  /// HTML `State.isTilting`: the tray is pressed, or 'Tilt Tray' pours it.
  bool holding = false;
  bool autoPour = false;

  /// Something was poured in the current step.
  bool poured = false;

  /// Scene time the next piece leaves the tray.
  double nextEmit = 0;

  /// Step 3's heap is being scooped back into the tray (from [refillAt];
  /// -1 while it waits).
  bool refilling = false;
  double refillAt = -1;
  final _Heap mixed = _Heap(_mixedSlots, _grainHeapAt, _mixedHeapR, _camYard);
  final _Heap grain = _Heap(_grainSlots, _grainHeapAt, _grainHeapR, _camYard);
  final _Heap husk = _Heap(_huskSlots, _huskHeapAt, _huskHeapR, _camYard);

  /// x of each wind streak.
  final List<double> windX = [for (final w in _windSeeds) w.x];

  /// The beat's swing (0 at rest on the log … 1 at the top) at [t].
  double _swing(double t) {
    final e = t - swingAt;
    const up = _swingMs / 1000;
    if (scenario != 0 || e < 0 || e >= 2 * up) return 0;
    return e < up ? e / up : 2 - e / up;
  }

  /// The bundle's centre at [t] (HTML `stalksGrpS1.position`).
  _V bundleAt(double t) {
    final u = _swing(t);
    if (u <= 0) return bundle.at(t);
    return _V.lerp(_bundleOnLog, _beatTop, u);
  }

  /// The bundle's swing about z at [t].
  double bundleRoll(double t) => _beatRoll * _swing(t);

  /// HTML `State.activeDragTarget` of the current step.
  _Obj? get target {
    if (done || busy) return null;
    if (scenario == 0) return step == 1 ? _Obj.bundle : null;
    return step <= 2 ? _Obj.soop : null;
  }

  /// The object that pulses (HTML `update3DHighlight`; here also the
  /// bundle to tap and the tray to hold).
  _Obj? get glowing {
    if (held != null) return held;
    if (done || busy) return null;
    if (scenario == 0) return step <= 3 ? _Obj.bundle : null;
    if (step <= 2) return _Obj.soop;
    return (step == 3 || step == 4) && trayLeft > 0 && !refilling
        ? _Obj.soop
        : null;
  }

  /// The last step: 'Finish Observation' opens the summary.
  bool get finishStep => step == _stepCounts[scenario] || done;

  /// HTML `resetScenarioState(sc)` / `resetAllObjects()`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = null;
    bundle = const _Move.still(_bundleHome);
    soop = const _Move.still(_soopStart);
    soopHome = _soopStart;
    bits.clear();
    beats = 0;
    swingAt = -10;
    straw = false;
    ears = const _Anim.still(1);
    pile.clear();
    scooped = false;
    trayLeft = 0;
    fanOn = false;
    fanSpeed = 0;
    fanAngle = 0;
    tilt = const _Anim.still(0);
    holding = false;
    autoPour = false;
    poured = false;
    nextEmit = 0;
    refilling = false;
    refillAt = -1;
    mixed.clear();
    grain.clear();
    husk.clear();
    for (var i = 0; i < _windCount; i++) {
      windX[i] = _windSeeds[i].x;
    }
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the object the current step lets the learner drag ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

/// How the scene layer is placed while the sidebar is collapsed: scale [k]
/// and offset ([dx], [dy]) in design pixels.
typedef _Fit = ({double k, double dx, double dy});

const _Fit _noFit = (k: 1, dx: 0, dy: 0);

Duration _ms(int ms) => Duration(milliseconds: ms);

class _WinnowingLabState extends State<Ch9A2ThreshingAndWinnowingPage>
    with SingleTickerProviderStateMixin {
  /// HTML `State.isCamLocked: true`.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in scene pixels for the current stage
  /// scale, and the tool column's left edge in scene pixels (set while
  /// laying out).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// Where the finger holds the object relative to its centre (screen).
  Offset _grabShift = Offset.zero;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// The pointer pressing the tray (steps 3 and 4 of Scenario 2).
  int? _holdPointer;

  /// The tray is tilted or being tilted (the fan cannot be switched then).
  bool _pouring = false;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]` of the current scenario.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

  _Cam get _cam => _camOf(_scene.scenario);

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

  /// HTML `animate()`: tweens are functions of the scene time; falling
  /// pieces land, the fan turns, the wind blows and the tilted tray pours.
  /// Repaints the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    _landBits();
    if (s.scenario == 1) _tickYard(dt);
    _frame.value = now;
  }

  /// Pieces that reached their heap join it.
  void _landBits() {
    final s = _scene;
    if (s.bits.isEmpty) return;
    s.bits.removeWhere((b) {
      if (!b.landed(s.time)) return false;
      b.heap.show(b.slot, b.husk);
      return true;
    });
  }

  /// Can the tray pour now (HTML `startTilt` guard, plus: the fan must be
  /// on in step 4, and there must be something on the tray)?
  bool get _canPour {
    final s = _scene;
    return s.scenario == 1 &&
        (s.step == 3 || s.step == 4) &&
        !s.done &&
        !s.busy &&
        !s.refilling &&
        s.trayLeft > 0 &&
        (s.step == 3 || s.fanOn);
  }

  void _tickYard(double dt) {
    final s = _scene;
    final t = s.time;
    // HTML `fanBladesS2.rotation.x += …` and the wind streaks.
    final spin = s.fanOn ? _fanSpin : 0.0;
    if (s.fanSpeed < spin) {
      s.fanSpeed = math.min(spin, s.fanSpeed + _fanAccel * dt);
    } else if (s.fanSpeed > spin) {
      s.fanSpeed = math.max(spin, s.fanSpeed - _fanAccel * dt);
    }
    s.fanAngle = (s.fanAngle + s.fanSpeed * dt) % (2 * math.pi);
    if (s.fanOn) {
      for (var i = 0; i < _windCount; i++) {
        s.windX[i] += _windSpeed * dt;
        if (s.windX[i] > _windEndX) s.windX[i] = _windStartX;
      }
    }
    // Step 3's heap goes back into the tray.
    if (s.refillAt >= 0) {
      final u = ((t - s.refillAt) / _refillSeconds).clamp(0.0, 1.0);
      final back = (u * _trayItems).round();
      s.trayLeft = back;
      s.mixed.keep(_trayItems - back);
      if (u >= 1) {
        setState(() {
          s
            ..refillAt = -1
            ..refilling = false;
        });
      }
    }
    // HTML `startTilt` / `stopTilt` and the pour in `animate()`.
    final want = (s.holding || s.autoPour) && _canPour;
    final now = s.tilt.at(t);
    if (want && s.tilt.to != 1) {
      s.tilt = _Anim(now, 1, t, _tiltSeconds * (1 - now));
      _Sound.drop.play();
    } else if (!want && s.tilt.to != 0) {
      s.tilt = _Anim(now, 0, t, _tiltSeconds * now);
    }
    if (want && s.tilt.at(t) >= _pourTilt) {
      while (s.trayLeft > 0 && s.nextEmit <= t) {
        _emit();
        s.nextEmit += _emitGap;
      }
    } else {
      s.nextEmit = t;
    }
    if (s.autoPour && s.trayLeft == 0) s.autoPour = false;
    final pouring = s.autoPour || (s.holding && want) || s.tilt.at(t) > 0;
    if (pouring != _pouring) setState(() => _pouring = pouring);
    if ((s.step == 3 || s.step == 4) &&
        s.poured &&
        s.trayLeft == 0 &&
        s.bits.isEmpty) {
      _pourDone();
    }
  }

  /// The next piece leaves the tray's tilted edge for its heap: one mixed
  /// heap without wind (step 3), grains below and husk downwind (step 4).
  void _emit() {
    final s = _scene;
    final item = _trayFill[_trayItems - s.trayLeft];
    s
      ..trayLeft -= 1
      ..poured = true;
    final from = _soopPoint(
      _V(_trayHalfX, _trayHalfY + 0.1, item.local.z * _lipSpread / 1.5),
    );
    final heap = s.step == 3 ? s.mixed : (item.husk ? s.husk : s.grain);
    final slot = heap.take();
    final to = heap.slots[slot];
    final drop = math.max(0.5, from.y - to.y);
    s.bits.add(
      _Bit(
        husk: item.husk,
        from: from,
        to: to,
        start: s.time,
        seconds: item.husk ? drop / _huskSink : math.sqrt(2 * drop / _gravity),
        fall: item.husk && s.step == 4 ? _Fall.blown : _Fall.drops,
        heap: heap,
        slot: slot,
      ),
    );
  }

  /// A point given in the tray's own frame, in the world (HTML `soopS2`
  /// position and `rotation.z`).
  _V _soopPoint(_V local) {
    final s = _scene;
    final th = s.tilt.at(s.time) * _maxTilt;
    final c = math.cos(th), sn = math.sin(th);
    return s.soop.at(s.time) +
        _V(local.x * c + local.y * sn, -local.x * sn + local.y * c, local.z);
  }

  /// HTML: `tiltProgress >= 1` → `advanceStep()`. Step 3 moves on to step 4
  /// and its heap is scooped back into the tray for the windy try.
  void _pourDone() {
    final s = _scene;
    s.poured = false;
    if (s.step == 3) {
      setState(() {
        s
          ..step = 4
          ..refilling = true;
      });
      _lab.after(_ms(_refillDelayMs), () {
        if (!mounted) return;
        s.refillAt = s.time;
        _toast('t_refill');
      });
    } else {
      setState(() => s.step = 5);
    }
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _holdPointer = null;
    _moved = false;
    _pouring = false;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  void _setBusy(bool busy) {
    if (!mounted || _scene.busy == busy) return;
    setState(() => _scene.busy = busy);
  }

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone.
  void _toast(String key, {bool error = false, bool sound = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: sound);
    _toastId = _lab.toast?.id;
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null || shown.id != _toastId) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(_t(key), isError: shown.isError, sound: false);
      _toastId = _lab.toast?.id;
    });
  }

  /// HTML `triggerMainAction()` ('Finish Observation'): the scenario is
  /// done and its summary opens (again, if the learner closed it).
  void _finish() {
    final s = _scene;
    if (!_lab.isLabActive || !s.finishStep) return;
    if (!s.done) setState(() => s.done = true);
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () => _t('sum_s${sc + 1}'),
    );
  }

  /// [obj] glides to [to] in [ms]; drags are ignored until it arrives,
  /// then [then] runs.
  void _glide(
    _Obj obj,
    _V to,
    int ms, {
    Curve curve = Curves.linear,
    VoidCallback? then,
  }) {
    final s = _scene;
    _setBusy(true);
    final t = s.time;
    if (obj == _Obj.bundle) {
      s.bundle = _Move(s.bundle.at(t), to, t, ms / 1000, curve);
    } else {
      s.soop = _Move(s.soop.at(t), to, t, ms / 1000, curve);
    }
    _lab.after(_ms(ms), () {
      if (!mounted) return;
      _setBusy(false);
      then?.call();
    });
  }

  /// A refused drop: the object goes back home in 400 ms (HTML) with the
  /// hint [key] (the HTML only clicked).
  void _revert(_Obj obj, String key) {
    _toast(key, error: true, sound: true);
    _glide(obj, obj == _Obj.bundle ? _bundleHome : _scene.soopHome, _returnMs);
  }

  // ------------------------------------------------- scenario 1 actions

  /// Step 1 done (HTML 'thud'): the bundle settles on the log (Quadratic.Out).
  void _onLog() {
    _Sound.drop.play();
    _glide(
      _Obj.bundle,
      _bundleOnLog,
      _snapMs,
      curve: Curves.easeOutQuad,
      then: () => setState(() => _scene.step = 2),
    );
  }

  /// HTML `beatStalks()` ('Beat Stalks', and here a tap on the bundle as the
  /// HTML text promised): one beat against the log. The second beat ends
  /// step 2; the grains fly off when the bundle hits the log.
  void _beat() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.done || s.busy) return;
    if (s.step != 2 && s.step != 3) return;
    _Sound.drop.play();
    setState(() {
      s
        ..busy = true
        ..beats += 1
        ..swingAt = s.time;
      if (s.step == 2 && s.beats >= _beatsForStep3) s.step = 3;
    });
    _lab.after(_ms(2 * _swingMs), _impact);
  }

  /// The bundle hits the log: 12 pieces leave the ears for the pile (HTML
  /// `grainPileS1.scale = beatCount * 0.2`). After the fifth beat the empty
  /// straw is set aside and step 4 begins.
  void _impact() {
    if (!mounted) return;
    final s = _scene;
    final t = s.time;
    for (var i = 0; i < _bitsPerBeat; i++) {
      final stalk = _stalks[(s.beats * 4 + i) % _stalkCount];
      final from = _earAt(stalk);
      final slot = s.pile.take();
      final to = s.pile.slots[slot];
      s.bits.add(
        _Bit(
          husk: i % 4 == 3,
          from: from,
          to: to,
          start: t + i * _bitStagger,
          seconds: math.sqrt(2 * math.max(0.5, from.y - to.y) / _gravity),
          fall: _Fall.thrown,
          heap: s.pile,
          slot: slot,
        ),
      );
    }
    s.ears = _Anim(
      s.ears.at(t),
      1 - s.beats / _beatsNeeded,
      t,
      _swingMs / 1000,
    );
    if (s.beats < _beatsNeeded) {
      setState(() => s.busy = false);
      return;
    }
    setState(() {
      s
        ..straw = true
        ..bundle = _Move(_bundleOnLog, _strawSpot, t, _strawMs / 1000)
        ..busy = false;
      if (s.step < 4) s.step = 4;
    });
  }

  /// The ear of [stalk] while the bundle rests on the log.
  _V _earAt(_Stalk stalk) {
    final dir = _V(math.cos(stalk.tilt), math.sin(stalk.tilt), 0);
    return _bundleOnLog + stalk.offset + dir * (_stalkHalf - _earLen / 2);
  }

  // ------------------------------------------------- scenario 2 actions

  /// Step 1 done (HTML 'pour'): the tray fills and settles on the pile.
  void _scoop() {
    final s = _scene;
    _Sound.drop.play();
    setState(() {
      s
        ..scooped = true
        ..trayLeft = _trayItems;
    });
    _glide(
      _Obj.soop,
      _soopFilled,
      _snapMs,
      then: () => setState(() {
        s
          ..soopHome = _soopFilled
          ..step = 2;
      }),
    );
  }

  /// Step 2 done (HTML 'thud'): the tray settles on the platform's edge.
  void _onStand() {
    final s = _scene;
    _Sound.drop.play();
    _glide(
      _Obj.soop,
      _soopPour,
      _snapMs,
      then: () => setState(() {
        s
          ..soopHome = _soopPour
          ..step = 3;
      }),
    );
  }

  /// HTML `toggleFan()` ('Fan: OFF' / 'Fan: ON', step 4).
  void _toggleFan() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4 || s.done || _pouring) return;
    setState(() => s.fanOn = !s.fanOn);
  }

  /// 'Tilt Tray' (the HTML's 'Hold to Tilt Tray' as a tap): tilts the tray
  /// and pours it until it is empty. In step 4 the fan must be on first.
  void _tiltButton() {
    final s = _scene;
    if (s.scenario != 1 || (s.step != 3 && s.step != 4) || s.done) return;
    if (s.step == 4 && !s.fanOn) {
      _toast('e_fan_off', error: true, sound: true);
      return;
    }
    if (s.trayLeft == 0 || s.refilling) return;
    setState(() => s.autoPour = true);
  }

  // -------------------------------------------------------------- gestures

  /// The object's mesh as a screen rectangle, at least a 48 dp target
  /// around its centre.
  Rect _hitRect(_Obj obj) {
    final s = _scene;
    final (centre, half) = obj == _Obj.bundle
        ? (s.bundleAt(s.time), const _V(_stalkHalf + 0.3, 0.7, 1))
        : (
            s.soop.at(s.time) + const _V(0, 0.2, 0),
            const _V(_trayHalfX + 0.2, 0.6, _trayHalfZ),
          );
    var rect = Rect.fromCircle(center: _cam.p(centre), radius: _touch);
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final c = _cam.p(centre + _V(sx * half.x, sy * half.y, sz * half.z));
          rect = rect.expandToInclude(Rect.fromLTWH(c.dx, c.dy, 0, 0));
        }
      }
    }
    return rect;
  }

  /// HTML `pointerdown`: only the step's object can be picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null) return false;
    final target = s.target;
    return target != null && _hitRect(target).contains(event.localPosition);
  }

  /// HTML `startDrag`: the finger keeps its offset from the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final target = s.target;
    if (target == null || !_hitRect(target).contains(d.localPosition)) return;
    final at = target == _Obj.bundle ? s.bundle.at(s.time) : s.soop.at(s.time);
    _grabShift = d.localPosition - _cam.p(at);
    _moved = false;
    setState(() => s.held = target);
  }

  void _onDragStart(DragStartDetails d) {
    if (_scene.held == null) return;
    _moved = true;
    _Sound.pickup.play();
  }

  /// HTML `pointermove`: the object follows the finger on its drag plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    final p = _dragPoint(d.localPosition - _grabShift);
    if (p == null) return;
    if (obj == _Obj.bundle) {
      s.bundle = _Move.still(p);
    } else {
      s.soop = _Move.still(p);
    }
  }

  /// The drag plane under [at]. The HTML dragged on the horizontal plane
  /// through the object; the bundle (step 1) and the filled tray (step 2)
  /// now rise smoothly to their target's height as they near it, so they
  /// stay under the finger and land where the learner sees them.
  _V? _dragPoint(Offset at) {
    final s = _scene;
    if (s.scenario == 1 && s.step == 1) return _cam.onPlaneY(at, _soopStart.y);
    final bundle = s.scenario == 0;
    final from = bundle ? _bundleHome : _soopFilled;
    final to = bundle ? _bundleOnLog : const _V(0, _standLift, 0);
    final full = (bundle ? _logLiftFull : _standLiftFull) * _cam.scaleAt(to);
    // How far along the way from its start to its target (on screen) the
    // object is: 0 at the start (or farther), 1 near the target.
    final a = _cam.p(from), b = _cam.p(to);
    final span = (a - b).distance;
    final u = ((span - (at - b).distance) / (span - full)).clamp(0.0, 1.0);
    return _cam.onPlaneY(at, from.y + (to.y - from.y) * u * u * (3 - 2 * u));
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` / `pointercancel`: a dragged object is checked against
  /// the step's target; a mere press leaves it where it was.
  void _release() {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    setState(() => s.held = null);
    if (!_moved) return;
    _moved = false;
    _checkDrop(obj);
  }

  /// HTML `checkDrop()`.
  void _checkDrop(_Obj obj) {
    final s = _scene;
    if (obj == _Obj.bundle) {
      if (_flat(s.bundle.at(s.time), _V.zero) < _logRange) {
        _onLog();
      } else {
        _revert(obj, 'e_log');
      }
      return;
    }
    final p = s.soop.at(s.time);
    if (s.step == 1) {
      if (_flat(p, _mixAt) < _scoopRange) {
        _scoop();
      } else {
        _revert(obj, 'e_pile');
      }
    } else if (_flat(p, _V.zero) < _standRange) {
      _onStand();
    } else {
      _revert(obj, 'e_stand');
    }
  }

  /// A tap on the bundle in steps 2 and 3 beats it (the HTML's step text
  /// offered it, but only the button worked).
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.done) return;
    if (s.step != 2 && s.step != 3) return;
    if (_hitRect(_Obj.bundle).contains(d.localPosition)) _beat();
  }

  /// Press and hold on the tray tilts it (HTML 'Hold to Tilt Tray',
  /// steps 3 and 4); in step 4 the fan must be on first.
  void _onPointerDown(PointerDownEvent e) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.done) return;
    if ((s.step != 3 && s.step != 4) || _holdPointer != null) return;
    if (!_hitRect(_Obj.soop).contains(e.localPosition)) return;
    _holdPointer = e.pointer;
    if (s.step == 4 && !s.fanOn) {
      _toast('e_fan_off', error: true, sound: true);
      return;
    }
    s.holding = true;
  }

  /// HTML `stopTilt()`.
  void _onPointerUp(PointerEvent e) {
    if (e.pointer != _holdPointer) return;
    _holdPointer = null;
    _scene.holding = false;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#action-controls`: 'Beat Stalks' (S1 steps 2–3), 'Fan' (S2 step
  /// 4), 'Tilt Tray' (S2 steps 3–4) and `#btn-action-main` 'Finish
  /// Observation' (the last step; afterwards it re-opens the summary).
  List<LabAction> _actions() {
    final s = _scene;
    final finish = LabAction(
      label: _t('btn_finish'),
      icon: Icons.arrow_forward,
      color: _Colors.emerald500,
      foreground: _Colors.white,
      highlight: !s.done,
      // The summary plays the HTML 'ding'.
      silent: true,
      onTap: _finish,
    );
    if (s.scenario == 0) {
      return [
        if ((s.step == 2 || s.step == 3) && !s.done)
          LabAction(
            label: _t('btn_beat'),
            icon: Icons.gavel,
            color: _Colors.indigo600,
            foreground: _Colors.white,
            highlight: true,
            // Each beat plays the HTML 'thud'.
            silent: true,
            onTap: _beat,
          ),
        if (s.finishStep) finish,
      ];
    }
    return [
      if (s.step == 4 && !s.done)
        LabAction(
          label: _t(s.fanOn ? 'fan_on' : 'fan_off'),
          icon: Icons.air,
          color: s.fanOn ? _Colors.indigo500 : _Colors.slate800,
          foreground: s.fanOn ? _Colors.slate950 : _Colors.indigo400,
          enabled: !_pouring,
          onTap: _toggleFan,
        ),
      if ((s.step == 3 || s.step == 4) && !s.done)
        LabAction(
          label: _t('btn_tilt'),
          icon: Icons.south_east,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          highlight: true,
          enabled: !s.autoPour && s.trayLeft > 0 && !s.refilling,
          onTap: _tiltButton,
        ),
      if (s.finishStep) finish,
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
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the scenario
          // is done.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _sidebarExtra(p, f),
          stage: _stage(),
        );
      },
    );
  }

  /// While the sidebar is collapsed: moves (and on small screens shrinks)
  /// the scene so everything the learner needs lies between the floating
  /// mission card and the tool column.
  _Fit _collapsedFit(BuildContext context) {
    if (_lab.isSidebarOpen) return _noFit;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return _noFit;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = _missionCardWidth(size, context.labScale);
    // The shell puts the mission card 76 px from the left edge.
    final freeLeft = (76 + pad.left + card - stageLeft) / fit + _cardGap;
    final tools = labOverlayInsets(context, _lab).right;
    final freeRight =
        math.min((size.width - tools - stageLeft) / fit, _design.width) -
        _cardGap;
    final (left, right) = _scene.scenario == 0 ? _floorExtent : _yardExtent;
    final k = ((freeRight - freeLeft) / (right - left)).clamp(_minFit, 1.0);
    return (
      k: k,
      dx: (freeLeft + freeRight) / 2 - k * (left + right) / 2,
      dy: (1 - k) * _design.height / 2,
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final view = _collapsedFit(context);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          final px = fit * view.k;
          _touch = _touchDp / px;
          _labelSize =
              _labelPx * (_labelFullScale / px).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          final toolsLeft = math.min(
            (box.maxWidth - tools - stageLeft) / fit,
            _design.width,
          );
          _labelRight = (toolsLeft - view.dx) / view.k;
        }
        return LabStage(
          designSize: _design,
          // The move transforms the whole scene layer (painting and hit
          // tests), so gestures arrive in the scene's own coordinates.
          child: AnimatedContainer(
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            transform: Matrix4(
              view.k,
              0,
              0,
              0, //
              0,
              view.k,
              0,
              0, //
              0,
              0,
              1,
              0, //
              view.dx,
              view.dy,
              0,
              1,
            ),
            child: KeyedSubtree(
              key: _sceneKey,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags and taps on the scene are not screen-reader
                  // actions; the scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
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
                            ..onStart = _onDragStart
                            ..onUpdate = _onDragUpdate
                            ..onEnd = _onDragEnd
                            ..onCancel = _release,
                        ),
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TapGestureRecognizer
                        >(
                          () => TapGestureRecognizer(debugOwner: this),
                          (r) => r.onTapUp = _onTap,
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
                          labelSize: _labelSize,
                          labelRight: _labelRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The sidebar's extra panel: the beating progress (Scenario 1, HTML
  /// `cnt_beat`, which had no element to show it) and the observations.
  Widget _sidebarExtra(LabPalette p, double f) {
    final list = _observations(p, f);
    if (_scene.scenario != 0) return list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _beatReadout(p, f),
        SizedBox(height: 8 * f),
        list,
      ],
    );
  }

  Widget _beatReadout(LabPalette p, double f) {
    final full = _scene.beats >= _beatsNeeded;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * f, vertical: 8 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: full ? p.success : p.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.gavel, size: 14 * f, color: full ? p.success : p.accent),
          SizedBox(width: 8 * f),
          Expanded(
            child: Text(
              labFormat(_t('cnt_beat'), {'c': _scene.beats}),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.textStrong,
                fontSize: 12 * f,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
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

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Round-ended thick lines (stalks, the fan pole, wind streaks).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// Even-odd path for rings (the glowing drop zones).
  final Path ringPath = Path();
}

/// Label chip styles: glass chip in the dark / light theme, and the
/// amber-edged beating progress readout.
enum _Chip { dark, light, counter }

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background and the ground) and the label text painters. Owned by the
/// page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text, _Chip chip) =>
      _labels['${chip.index}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: chip == _Chip.light ? _Colors.slate800 : _Colors.white,
            fontSize: _labelSize,
            fontWeight: chip == _Chip.counter
                ? FontWeight.w800
                : FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// The static part of [scenario]'s scene, recorded once.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, size, pens);
    _backdropScenario = scenario;
    _backdropDark = dark;
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

/// [c] pulsing towards the HTML highlight colour by [amount] (0 … 0.45).
Color _pulsed(Color c, double amount) => amount <= 0
    ? c
    : Color.lerp(c, _Colors.highlight.withValues(alpha: c.a), amount)!;

/// Mesh drawing in the camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// One face of a box: centre [m], outward normal [n], spanned by [a] and
  /// [b] (half sizes [ha], [hb]); drawn only when it faces the camera.
  void _face(
    _V m,
    _V n,
    _V a,
    double ha,
    _V b,
    double hb,
    Color color,
    double edge,
  ) {
    if (n.dot(cam.eye - m) <= 0) return;
    final path = pens.path..reset();
    _to(path, 0, cam.p(m - a * ha - b * hb));
    _to(path, 1, cam.p(m + a * ha - b * hb));
    _to(path, 2, cam.p(m + a * ha + b * hb));
    _to(path, 3, cam.p(m - a * ha + b * hb));
    path.close();
    final lit = _lit(color, n);
    canvas.drawPath(path, pens.fill..color = lit);
    if (edge > 0) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: edge),
      );
    } else {
      canvas.drawPath(path, pens.seam..color = lit);
    }
  }

  /// BoxGeometry centred at [c] with half sizes [hx], [hy], [hz] along the
  /// axes [ex], [ey], [ez] (turned boxes: the tray, the fan blades).
  void box(
    _V c,
    double hx,
    double hy,
    double hz,
    Color color, {
    _V ex = _V.right,
    _V ey = _V.up,
    _V ez = _V.front,
    double edge = 0.35,
  }) {
    _face(c + ex * hx, ex, ey, hy, ez, hz, color, edge);
    _face(c - ex * hx, -ex, ey, hy, ez, hz, color, edge);
    _face(c + ey * hy, ey, ex, hx, ez, hz, color, edge);
    _face(c - ey * hy, -ey, ex, hx, ez, hz, color, edge);
    _face(c + ez * hz, ez, ex, hx, ey, hy, color, edge);
    _face(c - ez * hz, -ez, ex, hx, ey, hy, color, edge);
  }

  /// Cross-section direction at [a] radians in the frame ([ex], [ez]).
  static _V _dir(_V ex, _V ez, double a) => ex * math.cos(a) + ez * math.sin(a);

  /// Upright CylinderGeometry (or cone): radius [r0] at [base], [r1] at the
  /// top, [h] high. The facets turned to the camera are lit one by one;
  /// [cap] closes the top.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    bool cap = true,
    int sides = 24,
  }) {
    if (h <= 0) return;
    final top = base + _V.up * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(_V.right, _V.front, (a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final d0 = _dir(_V.right, _V.front, a0);
      final d1 = _dir(_V.right, _V.front, a1);
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
    if (cap && _V.up.dot(cam.eye - top) > 0) {
      disc(top, r1, _lit(color, _V.up));
    }
  }

  /// A flat disc of radius [r] centred at [c] in the plane ([ex], [ez]).
  void disc(_V c, double r, Color color, [_V ex = _V.right, _V ez = _V.front]) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// The outline of a horizontal circle of radius [r] around [c].
  void circle(_V c, double r, Color color, double width) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(
        path,
        i,
        cam.p(c + _dir(_V.right, _V.front, i * 2 * math.pi / _ringSides) * r),
      );
    }
    path.close();
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  /// RingGeometry lying flat at [c] (MeshBasicMaterial: not lit).
  void ring(_V c, double rIn, double rOut, Color color) {
    // `reset()` also resets the fill type, so set it again each time.
    final path = pens.ringPath
      ..reset()
      ..fillType = PathFillType.evenOdd;
    for (final r in [rOut, rIn]) {
      for (var i = 0; i < _ringSides; i++) {
        final o = cam.p(
          c + _dir(_V.right, _V.front, i * 2 * math.pi / _ringSides) * r,
        );
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
    }
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A round limb from [a] to [b] (a thin CylinderGeometry of radius [r]).
  void limb(_V a, _V b, double r, Color color) {
    final w = math.max(1.2, 2 * r * cam.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      pens.limb
        ..strokeWidth = w
        ..color = color,
    );
  }

  /// A spindle from [a] to [b] of radius [r] (a wheat ear), with a darker
  /// middle line for its rows of grains.
  void spindle(_V a, _V b, double r, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    final w = math.max(1.5, 2 * r * cam.scaleAt((a + b) * 0.5));
    final mid = (pa + pb) / 2;
    canvas
      ..save()
      ..translate(mid.dx, mid.dy)
      ..rotate(math.atan2(d.dy, d.dx));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: len, height: w),
      pens.fill..color = color,
    );
    canvas.drawLine(
      Offset(-len * 0.35, 0),
      Offset(len * 0.35, 0),
      pens.stroke
        ..strokeWidth = math.max(0.6, w * 0.16)
        ..color = labShade(color, -0.35),
    );
    canvas.restore();
  }

  /// SphereGeometry: a lit disc with its shaded side away from the key
  /// light and a highlight (no gradient, so nothing is allocated).
  void sphere(_V c, double r, Color color, {bool shine = true}) {
    final o = cam.p(c);
    final rr = r * cam.scaleAt(c);
    canvas.drawCircle(o, rr, pens.fill..color = labShade(color, -0.25));
    canvas.drawCircle(
      o + Offset(rr * 0.12, -rr * 0.14),
      rr * 0.84,
      pens.fill..color = color,
    );
    if (shine) {
      canvas.drawCircle(
        o + Offset(rr * 0.3, -rr * 0.34),
        rr * 0.24,
        pens.fill..color = labShade(color, 0.4),
      );
    }
  }

  /// A husk flake: a sphere of radius [r] flattened to (1.4, 0.5, 1.4)
  /// (HTML `huskHeapS2`), turned by [angle] on screen.
  void flake(_V c, double r, double angle, Color color) {
    final o = cam.p(c);
    final k = r * cam.scaleAt(c);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 2.8 * k,
      height: math.max(1, k),
    );
    canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..rotate(angle);
    canvas.drawOval(rect, pens.fill..color = color);
    canvas.drawOval(
      rect,
      pens.stroke
        ..strokeWidth = 0.6
        ..color = labShade(color, -0.35),
    );
    canvas.restore();
  }

  /// Soft blurred shadow of an elliptic footprint on the ground.
  void shadow(double x, double z, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, 0.003, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }
}

/// The scene's static layer: the background and the ground disc of soil.
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final radius = scenario == 0 ? _floorR : _yardR;
  final cam = _camOf(scenario);
  final g = _Gfx(canvas, cam, pens);
  final path = pens.path..reset();
  for (var i = 0; i < _groundSides; i++) {
    final a = i * 2 * math.pi / _groundSides;
    g._to(path, i, cam.p(_V(math.cos(a) * radius, 0, math.sin(a) * radius)));
  }
  path.close();
  canvas.drawPath(path, pens.fill..color = _lit(_Colors.soil, _V.up));
  canvas.drawPath(
    path,
    pens.stroke
      ..strokeWidth = 1.5
      ..color = labShade(_Colors.soil, -0.45),
  );
  // Clods and straw bits on the packed soil (fixed).
  final rnd = math.Random(scenario == 0 ? 3 : 5);
  for (var i = 0; i < 140; i++) {
    final a = rnd.nextDouble() * 2 * math.pi;
    final r = math.sqrt(rnd.nextDouble()) * (radius - 0.6);
    final p = _V(math.cos(a) * r, 0, math.sin(a) * r);
    final k = cam.scaleAt(p);
    canvas.drawOval(
      Rect.fromCenter(center: cam.p(p), width: 0.35 * k, height: 0.12 * k),
      pens.fill
        ..color = (i.isEven
            ? labShade(_Colors.soil, -0.3)
            : labShade(_Colors.soil, 0.15)),
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the
/// threshing floor (log, bundle, grain pile), S2 the winnowing yard
/// (platform, fan, mixture pile, tray, falling grain and husk, heaps).
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Scene x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  _Cam get _cam => _camOf(scene.scenario);

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    final g = _Gfx(canvas, _cam, _pens);
    if (scene.scenario == 0) {
      _paintFloor(g);
    } else {
      _paintYard(g);
    }
  }

  /// HTML `update3DHighlight`: how far [obj] pulses towards indigo now.
  double _pulse(_Obj obj) {
    final s = scene;
    if (s.glowing != obj) return 0;
    return (math.sin(s.time * _pulseRate) + 1) / 2 * _pulseMax;
  }

  /// Alpha of a glowing drop ring (it breathes a little).
  double get _ringAlpha => 0.75 + 0.25 * math.sin(scene.time * 4);

  // ---------------------------------------------------------- scenario 1

  void _paintFloor(_Gfx g) {
    final s = scene;
    final at = s.bundleAt(s.time);
    g.shadow(0.4, -0.3, _logBottomR + 0.3, _logBottomR + 0.3);
    if (_flat(at, _V.zero) > _logBottomR) {
      g.shadow(at.x + 0.3, at.z - 0.3, _stalkHalf, 0.9);
    }
    // The straw set aside lies behind the log.
    final behind = _cam.depth(at) > _cam.depth(const _V(0, _logH / 2, 0));
    if (behind) _paintBundle(g, at);
    _paintLog(g);
    if (s.step == 1 && !s.done) {
      g.ring(
        const _V(0, _logRingY, 0),
        _logRingIn,
        _logRingOut,
        _Colors.glow.withValues(alpha: _Colors.glow.a * _ringAlpha),
      );
    }
    _paintHeap(g, s.pile, _pileGrainR);
    if (!behind) _paintBundle(g, at);
    _paintBits(g, _pileGrainR);

    // The beating progress (HTML `cnt_beat`, never shown there).
    if (s.step >= 2) {
      _chip(
        g.canvas,
        _cam.p(_beatChipAt),
        labFormat(_t('cnt_beat'), {'c': s.beats}),
        chip: _Chip.counter,
      );
    }
    if (!showLabels) return;
    // HTML `createStdLabel`s.
    _chip(g.canvas, _cam.p(_logLabelAt), _t('lbl_log'));
    _chip(
      g.canvas,
      _cam.p(at + _V(0, s.straw ? _strawLabelUp : _bundleLabelUp, 0)),
      _t(s.straw ? 'lbl_straw' : 'lbl_stalks'),
    );
  }

  /// `woodenLogS1` with growth rings on its cut top.
  void _paintLog(_Gfx g) {
    g.cylinder(_V.zero, _logBottomR, _logTopR, _logH, _Colors.wood, sides: 28);
    final rings = labShade(_Colors.wood, -0.25).withValues(alpha: 0.8);
    for (final r in const [0.7, 1.4, 2.0]) {
      g.circle(const _V(0, _logH + 0.005, 0), r, rings, 1);
    }
  }

  /// `stalksGrpS1`: the stalks (amber; pale straw once threshed) with their
  /// wheat ears, which empty beat by beat.
  void _paintBundle(_Gfx g, _V at) {
    final s = scene;
    final t = s.time;
    final roll = s.bundleRoll(t);
    final pulse = _pulse(_Obj.bundle);
    final stalk = _pulsed(s.straw ? _Colors.straw : _Colors.stalk, pulse);
    final ear = _pulsed(_Colors.grain, pulse);
    final ears = s.ears.at(t);
    final c = math.cos(roll), sn = math.sin(roll);
    for (final st in _stalks) {
      final o = st.offset;
      final mid = at + _V(o.x * c - o.y * sn, o.x * sn + o.y * c, o.z);
      final a = st.tilt + roll;
      final dir = _V(math.cos(a), math.sin(a), 0);
      final tip = mid + dir * _stalkHalf;
      g.limb(mid - dir * _stalkHalf, tip, _stalkR, stalk);
      if (ears > 0.02) {
        g.spindle(
          tip - dir * (_earLen * ears),
          tip + dir * 0.1,
          _earR * (0.5 + 0.5 * ears),
          ear,
        );
      }
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintYard(_Gfx g) {
    final s = scene;
    final soop = s.soop.at(s.time);
    g
      ..shadow(0.4, -0.3, _topHalf + 0.3, _topHalf + 0.3)
      ..shadow(_fanHead.x + 0.3, -0.3, 0.9, 0.9);
    if (soop.y < 3) {
      g.shadow(soop.x + 0.3, soop.z - 0.3, _trayHalfX, _trayHalfZ);
    }
    _paintHeap(g, s.mixed, _itemR);
    _paintHeap(g, s.grain, _itemR + 0.02);
    _paintHeap(g, s.husk, _itemR + 0.05);
    _paintFan(g);
    _paintStand(g);
    if (s.step == 2 && !s.done) {
      g.ring(
        const _V(0, _standRingY, 0),
        _standRingIn,
        _standRingOut,
        _Colors.glow.withValues(alpha: _Colors.glow.a * _ringAlpha),
      );
    }
    if (s.fanOn) _paintWind(g);
    _paintMix(g);
    _paintSoop(g, soop);
    _paintBits(g, _itemR);
    if (!showLabels) return;
    final c = g.canvas;
    _chip(c, _cam.p(_mixLabelAt), _t('lbl_mixpile'));
    _chip(c, _cam.p(_standLabelAt), _t('lbl_stand'));
    _chip(c, _cam.p(_fanLabelAt), _t('lbl_fan'));
    if (s.held == null && s.soopHome == _soopPour && !s.busy) {
      // On the platform: right of the tray, clear of the falling stream.
      _chip(
        c,
        _cam.p(soop + _soopLabelBeside),
        _t('lbl_soop'),
        anchor: Alignment.centerLeft,
      );
    } else {
      _chip(c, _cam.p(soop + const _V(0, _soopLabelUp, 0)), _t('lbl_soop'));
    }
    for (final (heap, key) in [
      (s.mixed, 'lbl_mixed'),
      (s.grain, 'lbl_grain'),
      (s.husk, 'lbl_husk'),
    ]) {
      if (heap.shown < _heapLabelMin) continue;
      _chip(
        c,
        _cam.p(heap.centre + _V(0, 0, heap.radius + _heapLabelGap)),
        _t(key),
      );
    }
  }

  /// `fanGrpS2`: pole, head and three blades turning about x.
  void _paintFan(_Gfx g) {
    final s = scene;
    g
      ..cylinder(
        _V(_fanHead.x, 0, _fanHead.z),
        _fanPoleR,
        _fanPoleR,
        _fanHead.y,
        _Colors.metal,
        cap: false,
        sides: 10,
      )
      ..sphere(_fanHead, _fanHeadR, _Colors.metal);
    if (s.fanSpeed > 8) {
      // The blur of fast blades.
      g.disc(
        _fanHub,
        _bladeHalfLen + 0.1,
        _Colors.slate300.withValues(alpha: 0.18 * s.fanSpeed / _fanSpin),
        _V.up,
        _V.front,
      );
    }
    final blade = labShade(_Colors.metal, 0.2);
    for (var i = 0; i < 3; i++) {
      final a = s.fanAngle + i * 2 * math.pi / 3;
      g.box(
        _fanHub,
        _bladeHalfT,
        _bladeHalfLen,
        _bladeHalfW,
        blade,
        ey: _V(0, math.cos(a), math.sin(a)),
        ez: _V(0, -math.sin(a), math.cos(a)),
        edge: 0.5,
      );
    }
    g.sphere(_fanHub + const _V(0.1, 0, 0), 0.32, _Colors.metal);
  }

  /// `standS2`: the legs (back pair first), then the top with its planks.
  void _paintStand(_Gfx g) {
    for (final (x, z) in const [
      (-_legAt, -_legAt),
      (_legAt, -_legAt),
      (-_legAt, _legAt),
      (_legAt, _legAt),
    ]) {
      g.cylinder(_V(x, 0, z), _legR, _legR, _legH, _Colors.wood, sides: 10);
    }
    g.box(const _V(0, _topY, 0), _topHalf, _topHalfH, _topHalf, _Colors.wood);
    final plank = _pens.stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.wood, -0.35).withValues(alpha: 0.7);
    for (var i = -2; i <= 2; i++) {
      g.canvas.drawLine(
        _cam.p(_V(-_topHalf, _topY + _topHalfH + 0.005, i.toDouble())),
        _cam.p(_V(_topHalf, _topY + _topHalfH + 0.005, i.toDouble())),
        plank,
      );
    }
  }

  /// `windParticlesS2`: streaks moving with the air.
  void _paintWind(_Gfx g) {
    final s = scene;
    for (var i = 0; i < _windCount; i++) {
      final w = _windSeeds[i];
      final x = s.windX[i];
      g.limb(_V(x, w.y, w.z), _V(x + _windLen, w.y, w.z), _windR, _Colors.wind);
    }
  }

  /// `mixPileS2`: a mound of the threshed mixture, with grain and husk
  /// specks (added) so it reads as a mixture.
  void _paintMix(_Gfx g) {
    final k = scene.scooped ? _mixScooped : 1.0;
    g.cylinder(
      _mixAt,
      _mixR * k,
      0.06,
      _mixH * k,
      _Colors.stalk,
      cap: false,
      sides: 18,
    );
    for (final sp in _mixSpecks) {
      final p = _mixAt + sp.local * k;
      if (sp.husk) {
        g.flake(p, 0.11, 0.4, _Colors.husk);
      } else {
        g.sphere(p, 0.12, _Colors.grain, shine: false);
      }
    }
  }

  /// `soopS2`: the bamboo tray with its raised back, low rims and the
  /// grain and husk on it, tilted about z while it pours.
  void _paintSoop(_Gfx g, _V c) {
    final s = scene;
    final th = s.tilt.at(s.time) * _maxTilt;
    final ex = _V(math.cos(th), -math.sin(th), 0);
    final ey = _V(math.sin(th), math.cos(th), 0);
    const ez = _V.front;
    final color = _pulsed(_Colors.bamboo, _pulse(_Obj.soop));
    final rim = labShade(color, -0.15);
    g.box(c, _trayHalfX, _trayHalfY, _trayHalfZ, color, ex: ex, ey: ey);
    // The woven top.
    if (ey.dot(_cam.eye - c) > 0) {
      final weave = _pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(_Colors.bamboo, -0.4).withValues(alpha: 0.55);
      final top = c + ey * (_trayHalfY + 0.005);
      for (var i = -2; i <= 2; i++) {
        final x = ex * (i * 0.6);
        g.canvas.drawLine(
          _cam.p(top + x - ez * (_trayHalfZ - 0.1)),
          _cam.p(top + x + ez * (_trayHalfZ - 0.1)),
          weave,
        );
      }
      for (var i = -2; i <= 2; i++) {
        final z = ez * (i * 0.85);
        g.canvas.drawLine(
          _cam.p(top + z - ex * (_trayHalfX - 0.1)),
          _cam.p(top + z + ex * (_trayHalfX - 0.1)),
          weave,
        );
      }
    }
    final wall = c + ex * (-_trayHalfX + _wallHalfX) + ey * _wallHalfY;
    final wallFirst = _cam.depth(wall) > _cam.depth(c);
    void paintWall() =>
        g.box(wall, _wallHalfX, _wallHalfY, _trayHalfZ, color, ex: ex, ey: ey);
    if (wallFirst) paintWall();
    g.box(
      c + ey * (_trayHalfY + _rimHalf) - ez * (_trayHalfZ - _rimHalf),
      _trayHalfX,
      _rimHalf,
      _rimHalf,
      rim,
      ex: ex,
      ey: ey,
    );
    for (var i = _trayItems - s.trayLeft; i < _trayItems; i++) {
      final it = _trayFill[i];
      final l = it.local;
      final p = c + ex * l.x + ey * l.y + ez * l.z;
      if (it.husk) {
        g.flake(p, _itemR, 0.3 - th, _Colors.husk);
      } else {
        g.sphere(p, _itemR, _Colors.grain);
      }
    }
    g.box(
      c + ey * (_trayHalfY + _rimHalf) + ez * (_trayHalfZ - _rimHalf),
      _trayHalfX,
      _rimHalf,
      _rimHalf,
      rim,
      ex: ex,
      ey: ey,
    );
    if (!wallFirst) paintWall();
  }

  // ---------------------------------------------------------- shared

  /// A heap's places that are filled, far to near, on a darker mound.
  void _paintHeap(_Gfx g, _Heap heap, double r) {
    if (heap.shown == 0) return;
    final f = heap.shown / heap.slots.length;
    final husky = identical(heap, scene.husk);
    g.disc(
      heap.centre + const _V(0, 0.01, 0),
      heap.radius * (0.45 + 0.6 * math.sqrt(f)),
      labShade(
        husky ? _Colors.husk : _Colors.grain,
        -0.45,
      ).withValues(alpha: 0.85),
    );
    for (final i in heap.order) {
      final k = heap.kinds[i];
      if (k == _none) continue;
      final p = heap.slots[i];
      if (k == _huskKind) {
        g.flake(p, r + 0.03, (i * 0.7) % math.pi, _Colors.husk);
      } else {
        g.sphere(p, r, _Colors.grain);
      }
    }
  }

  /// Grains and husk flakes in the air; husk flutters as it falls.
  void _paintBits(_Gfx g, double r) {
    final s = scene;
    final t = s.time;
    for (final b in s.bits) {
      if (t < b.start) continue;
      final p = b.at(t);
      if (b.husk) {
        g.flake(p, r + 0.02, t * 9 + b.slot, _Colors.husk);
      } else {
        g.sphere(p, r, _Colors.grain);
      }
    }
  }

  // ------------------------------------------------------------ labels

  /// A label chip (HTML `.label-3d`) placed by [anchor] at [at], kept left
  /// of the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    _Chip? chip,
    Alignment anchor = Alignment.center,
  }) {
    final style = chip ?? (isDark ? _Chip.dark : _Chip.light);
    final tp = cache.label(text, style);
    final size = cache.labelSize;
    final padX = size * 0.65, padY = size * 0.32;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final cx = at.dx - anchor.x * w / 2;
    final minX = w / 2 + 4;
    final x = cx.clamp(minX, math.max(minX, labelRight - w / 2 - 4)).toDouble();
    final rect = Rect.fromCenter(
      center: Offset(x, at.dy - anchor.y * h / 2),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas.drawRRect(
      rr,
      _pens.fill
        ..color = style == _Chip.light ? _Colors.labelLight : _Colors.labelDark,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = style == _Chip.counter ? 1.5 : 1
        ..color = style == _Chip.counter ? _Colors.amber400 : _Colors.indigo400,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.labelRight != labelRight;
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
