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

/// Class 6 Science • Chapter 10 • Activity 3
/// Plant Growth and Tropisms.
///
/// Native Flutter port of `Cl6S-Ch10-A3-Plant_Growth_and_Tropisms.html`.
///
/// Scenario 1 (The Upside-Down Plant): a germinated bean on blotting paper
/// lies sideways inside an upside-down glass beaker; the Time-Lapse slider
/// runs 7 days, in which the root bends down and the shoot bends up.
///
/// Scenario 2 (The Plant in a Box): the seedling in an upright beaker is
/// covered with a cardboard box that lets sunlight in through one hole on
/// its right side; after 7 days the box is lifted and the shoot has grown
/// towards the hole.
///
/// The Three.js bench, beakers, seedlings and box are redrawn by a
/// CustomPainter through a perspective projection of the HTML camera (fov
/// 45°, looking along (0, 16, 35)), brought closer to the beaker so the
/// seedling is large enough on a phone. Scenario 2 looks from 28° to the
/// right, so the right side of the box and its hole can be seen.
class Ch10A3PlantGrowthAndTropismsPage extends StatefulWidget {
  const Ch10A3PlantGrowthAndTropismsPage({super.key});

  @override
  State<Ch10A3PlantGrowthAndTropismsPage> createState() => _TropismLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises four Web Audio tones: `click`
/// (buttons, the sidebar, scenario change, Enter Lab, Cover with Box),
/// `pop` (placing a beaker, lifting the box), `grow` (a rising tone on every
/// new day of the time-lapse, mapped to pickup.mp3) and `success` (Day 7
/// and the summary). correct.mp3 / error.mp3 are the shell's feedback
/// tones.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pop → `science/pop.mp3`, grow → `science/pickup.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `pop`: a beaker is set down, the box is lifted.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `grow`: one more day of the time-lapse.
  grow('audio/class6/science/pickup.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// A hint after a wrong action (added: the HTML stayed silent).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: Day 7 and the summary.
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
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background: #1e293b (dark), #e2e8f0 (light,
  /// `setTheme`); the renderer is transparent over it.
  static const Color sceneDark = slate800;
  static const Color sceneLight = slate200;

  /// Bench `MeshStandardMaterial({ color: 0x334155 })`.
  static const Color bench = slate700;

  /// `beakerMat` 0xe2e8f0, opacity 0.35.
  static const Color glass = slate200;

  /// `blotMat` 0xcccccc.
  static const Color paper = Color(0xFFCCCCCC);

  /// Seed 0xd97706, shoot 0x16a34a (base) and 0x22c55e (tip), leaves
  /// 0x15803d, root 0xfef08a.
  static const Color seed = Color(0xFFD97706);
  static const Color stem = Color(0xFF16A34A);
  static const Color stemTip = Color(0xFF22C55E);
  static const Color leaf = Color(0xFF15803D);
  static const Color root = Color(0xFFFEF08A);

  /// `boxMat` 0xb45309 (cardboard); the hole's dark inside (added).
  static const Color cardboard = Color(0xFFB45309);
  static const Color cardboardEdge = Color(0xB3713F12);
  static const Color holeInside = Color(0xFF1C1206);

  /// `s2Sunbeam`: 0xfde047 at opacity 0.45, emissive 0xfacc15.
  static const Color beam = Color(0xFFFDE047);
  static const Color sun = Color(0xFFFACC15);

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// `updateSpriteText()` label chips: rgba(30, 41, 59, 0.92) with a #475569
  /// border and white text (dark theme); rgba(255, 255, 255, 0.92), #cbd5e1
  /// and #0f172a (light theme).
  static const Color labelBgDark = Color(0xEB1E293B);
  static const Color labelBorderDark = slate600;
  static const Color labelTextDark = white;
  static const Color labelBgLight = Color(0xEBFFFFFF);
  static const Color labelBorderLight = slate300;
  static const Color labelTextLight = slate900;
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
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.teal500, // text-teal-500 headings, border-teal-500
    onAccent: _Colors.slate950, // Enter Lab: text-slate-950 on teal
    primary: _Colors.teal600, // summary button from-teal-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.teal400,
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // #toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66134E4A), // from-teal-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC5EEAD4), // subtitle text-teal-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.teal500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgDark,
    labelText: _Colors.labelTextDark,
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
    accent: _Colors.teal600,
    onAccent: _Colors.white,
    primary: _Colors.teal600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.teal600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66134E4A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC5EEAD4),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.teal500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
    labelText: _Colors.labelTextLight,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// say what to do on a touch screen ("Tap" instead of "Click"; the slider is
// dragged "up", as it stands upright beside the scene). Texts that told a
// result before it could be seen (the shoot curving inside the closed box,
// "Examine Curve") are neutral; the Hindi term for phototropism is
// प्रकाशानुवर्तन (the HTML had the typo प्रकाशाववर्तन). The HTML toasts were
// English only. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Plant Growth and Tropisms',
    'app_subtitle':
        'Class 6 • Living Creatures: Exploring their Characteristics',
    'scen_1_opt': 'Scenario 1: The Upside-Down Plant (Gravitropism)',
    'scen_2_opt': 'Scenario 2: The Plant in a Box (Phototropism)',
    's1_desc':
        "To observe how a plant's root and shoot respond to gravity when the plant is placed upside down.",
    's2_desc':
        "To observe how a plant's shoot grows when light is provided from only one direction.",
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Inverted Setup',
    's1_a1': "Tap 'Place Inverted Beaker'.",
    's1_o1':
        'The seedling is placed on blotting paper inside an inverted glass beaker. Shoot and root point horizontally.',
    's1_c2': 'Directional Growth',
    's1_a2': "Drag the 'Time-Lapse' slider up to Day 7.",
    's1_o2':
        'Over 7 days, the shoot visibly bends upwards against gravity, while the root bends downwards towards gravity.',
    's1_c3': 'Conclusion',
    's1_a3': "Tap 'Observe Summary & Conclusion'.",
    's1_o3':
        'Roots grow downwards, in the direction of gravity, while shoots grow upwards, against gravity.',
    // Scenario 2 steps.
    's2_c1': 'Upright Setup',
    's2_a1': "Tap 'Place Upright Beaker'.",
    's2_o1':
        'The seedling and blotting paper are placed in the glass beaker, sitting upright on the lab table.',
    's2_c2': 'Covering the Plant',
    's2_a2': "Tap 'Cover with Box'.",
    's2_o2':
        'A cardboard box covers the beaker. A bright sunbeam shines through a hole on the right.',
    's2_c3': 'Growth in One-Sided Light',
    's2_a3': "Drag the 'Time-Lapse' slider up to Day 7.",
    's2_o3':
        'Seven days pass inside the box. Light reaches the seedling only through the hole on the right.',
    's2_c4': 'Examine the Plant',
    's2_a4': "Tap 'Remove Box & Examine Plant'.",
    's2_o4':
        'The shoot has grown longer and curved towards the hole on the right, while the root still points straight down.',
    's2_c5': 'Conclusion',
    's2_a5': "Tap 'Observe Summary & Conclusion'.",
    's2_o5':
        'Confirms that plant shoots exhibit positive phototropism, growing towards the light source.',
    // HTML `hud` lines (the canvas "Current Task" banner).
    's1_hud_1':
        "Step 1: Tap 'Place Inverted Beaker' to position the germinated bean on the blotting paper and place the beaker upside down.",
    's1_hud_2':
        "Step 2: Drag the 'Time-Lapse' slider up to Day 7 to simulate 7 days of growth.",
    's1_hud_3':
        "Step 3: Observe the final state, then tap 'Observe Summary & Conclusion'.",
    's2_hud_1':
        "Step 1: Tap 'Place Upright Beaker' to place the beaker with seedling upright on the table.",
    's2_hud_2':
        "Step 2: Tap 'Cover with Box' to place the cardboard box over the beaker.",
    's2_hud_3':
        "Step 3: Drag the 'Time-Lapse' slider up to Day 7 to simulate 7 days of growth.",
    's2_hud_4':
        "Step 4: Tap 'Remove Box & Examine Plant' to inspect how the plant grew.",
    's2_hud_5': "Step 5: Tap 'Observe Summary & Conclusion'.",
    // Buttons.
    'btn_place_inverted': 'Place Inverted Beaker',
    'btn_place_upright': 'Place Upright Beaker',
    'btn_cover': 'Cover with Box',
    'btn_remove': 'Remove Box & Examine Plant',
    'btn_conclude': 'Observe Summary & Conclusion',
    // Time-lapse card (HTML day slider and `#day-counter-overlay`).
    'time_lapse': 'Time-Lapse',
    'sim_time': 'Simulation Time',
    'day_of': 'Day {d} / 7',
    'day_n': 'Day {d}',
    // Canvas labels (HTML `createTextSprite`); shoot and root added.
    'lbl_inverted': 'Inverted Beaker Setup',
    'lbl_box': 'Cardboard Box (Right Hole)',
    'lbl_shoot': 'Shoot',
    'lbl_root': 'Root',
    // HTML toasts.
    't_s1_placed': 'Beaker placed upside down! Seedling is horizontal.',
    't_s1_day7': '7 Days passed: Shoots bent UP, Roots bent DOWN!',
    't_s2_placed': 'Upright Beaker with seedling placed on table.',
    't_s2_box':
        'Box placed. Sunlight beam enters only from the right side window hole!',
    't_s2_day7':
        '7 days have passed. Remove the box to see how the plant has grown.',
    't_s2_removed':
        'Box removed! Notice how the shoot curved directly toward the right light hole.',
    // Added: hints where the HTML silently refused the action.
    'e_place_inverted': "First tap 'Place Inverted Beaker'.",
    'e_place_upright': "First tap 'Place Upright Beaker'.",
    'e_cover_first': "First tap 'Cover with Box'.",
    'e_slide_day7': 'Drag the slider all the way up to Day 7.',
    // Summary popup (HTML `triggerConclusion`).
    'sum_title_1': 'Gravitropism Verified!',
    'sum_1':
        'Plants possess gravitropism (geotropism). Roots exhibit positive gravitropism by bending downwards toward gravity, while shoots exhibit negative gravitropism by growing upwards away from gravity.',
    'next_1':
        'Scenario 1 Complete! Please select Scenario 2 from the sidebar to continue...',
    'sum_title_2': 'Phototropism Verified!',
    'sum_2':
        'The shoot of a plant will always grow towards a light source. This is called phototropism. It helps the plant get the maximum amount of light for photosynthesis.',
    'next_2':
        'Scenario 2 Complete! You have explored both scenarios in this activity.',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Lab bench with a germinated bean lying sideways inside an upside-down glass beaker',
    'scene_s2':
        'Lab bench with a seedling in an upright glass beaker and a cardboard box with a hole in its right side',
  },
  'hi': {
    'app_title': 'पादप वृद्धि और अनुवर्तन',
    'app_subtitle': 'कक्षा 6 • सजीव प्राणी: उनकी विशेषताओं की खोज',
    'scen_1_opt': 'परिदृश्य 1: उल्टा पौधा (गुरुत्वानुवर्तन)',
    'scen_2_opt': 'परिदृश्य 2: डिब्बे में पौधा (प्रकाशानुवर्तन)',
    's1_desc':
        'यह देखने के लिए कि जब पौधे को उल्टा रखा जाता है तो उसकी जड़ और तना गुरुत्वाकर्षण के प्रति कैसे प्रतिक्रिया करते हैं।',
    's2_desc':
        'यह देखने के लिए कि जब केवल एक दिशा से प्रकाश प्रदान किया जाता है तो पौधे का तना कैसे बढ़ता है।',
    's1_c1': 'उल्टा सेटअप',
    's1_a1': "'उल्टा बीकर रखें' पर टैप करें।",
    's1_o1':
        'अंकुर को एक उल्टे काँच के बीकर के अंदर सोख्ता कागज़ पर रखा गया है। तना और जड़ क्षैतिज दिशा में हैं।',
    's1_c2': 'दिशात्मक वृद्धि',
    's1_a2': "'टाइम-लैप्स' स्लाइडर को ऊपर दिन 7 तक खींचें।",
    's1_o2':
        '7 दिनों में, तना गुरुत्वाकर्षण के विरुद्ध ऊपर मुड़ता है, और जड़ गुरुत्वाकर्षण की ओर नीचे मुड़ती है।',
    's1_c3': 'निष्कर्ष',
    's1_a3': "'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's1_o3':
        'जड़ें गुरुत्वाकर्षण की दिशा में नीचे की ओर बढ़ती हैं, जबकि तना गुरुत्वाकर्षण के विरुद्ध ऊपर की ओर बढ़ता है।',
    's2_c1': 'सीधा सेटअप',
    's2_a1': "'सीधा बीकर रखें' पर टैप करें।",
    's2_o1':
        'अंकुर और सोख्ता कागज़ काँच के बीकर में रखे गए हैं, और बीकर प्रयोगशाला की मेज़ पर सीधा रखा है।',
    's2_c2': 'पौधे को ढकना',
    's2_a2': "'डिब्बे से ढकें' पर टैप करें।",
    's2_o2':
        'एक गत्ते का डिब्बा बीकर को ढकता है। दाईं ओर के एक छेद से सूर्य का तेज़ प्रकाश अंदर आता है।',
    's2_c3': 'एक ओर से आते प्रकाश में वृद्धि',
    's2_a3': "'टाइम-लैप्स' स्लाइडर को ऊपर दिन 7 तक खींचें।",
    's2_o3':
        'डिब्बे के अंदर सात दिन बीत जाते हैं। अंकुर तक प्रकाश केवल दाईं ओर के छेद से पहुँचता है।',
    's2_c4': 'पौधे की जाँच',
    's2_a4': "'डिब्बा हटाएं और पौधा देखें' पर टैप करें।",
    's2_o4':
        'तना लंबा हो गया है और दाईं ओर के छेद की ओर मुड़ गया है, जबकि जड़ अब भी सीधी नीचे की ओर है।',
    's2_c5': 'निष्कर्ष',
    's2_a5': "'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_o5':
        'यह पुष्टि करता है कि पौधे का तना धनात्मक प्रकाशानुवर्तन दिखाता है, यानी प्रकाश स्रोत की ओर बढ़ता है।',
    's1_hud_1':
        "चरण 1: अंकुरित बीज को सोख्ता कागज़ पर रखकर बीकर को उल्टा रखने के लिए 'उल्टा बीकर रखें' पर टैप करें।",
    's1_hud_2':
        "चरण 2: 7 दिनों की वृद्धि देखने के लिए 'टाइम-लैप्स' स्लाइडर को ऊपर दिन 7 तक खींचें।",
    's1_hud_3':
        "चरण 3: अंतिम स्थिति का अवलोकन करें, फिर 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_hud_1':
        "चरण 1: अंकुर वाले बीकर को मेज़ पर सीधा रखने के लिए 'सीधा बीकर रखें' पर टैप करें।",
    's2_hud_2':
        "चरण 2: बीकर के ऊपर गत्ते का डिब्बा रखने के लिए 'डिब्बे से ढकें' पर टैप करें।",
    's2_hud_3':
        "चरण 3: 7 दिनों की वृद्धि देखने के लिए 'टाइम-लैप्स' स्लाइडर को ऊपर दिन 7 तक खींचें।",
    's2_hud_4':
        "चरण 4: पौधा कैसे बढ़ा, यह देखने के लिए 'डिब्बा हटाएं और पौधा देखें' पर टैप करें।",
    's2_hud_5': "चरण 5: 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    'btn_place_inverted': 'उल्टा बीकर रखें',
    'btn_place_upright': 'सीधा बीकर रखें',
    'btn_cover': 'डिब्बे से ढकें',
    'btn_remove': 'डिब्बा हटाएं और पौधा देखें',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'time_lapse': 'टाइम-लैप्स',
    'sim_time': 'सिमुलेशन समय',
    'day_of': 'दिन {d} / 7',
    'day_n': 'दिन {d}',
    'lbl_inverted': 'उल्टा बीकर सेटअप',
    'lbl_box': 'गत्ते का डिब्बा (दाईं ओर छेद)',
    'lbl_shoot': 'तना',
    'lbl_root': 'जड़',
    't_s1_placed': 'बीकर उल्टा रख दिया गया! अंकुर क्षैतिज है।',
    't_s1_day7': '7 दिन बीत गए: तना ऊपर मुड़ा, जड़ नीचे मुड़ी!',
    't_s2_placed': 'अंकुर वाला सीधा बीकर मेज़ पर रख दिया गया।',
    't_s2_box':
        'डिब्बा रख दिया गया। सूर्य का प्रकाश केवल दाईं ओर के छेद से अंदर आता है!',
    't_s2_day7': '7 दिन बीत गए। पौधा कैसे बढ़ा, यह देखने के लिए डिब्बा हटाएँ।',
    't_s2_removed':
        'डिब्बा हटा दिया गया! देखिए, तना सीधे दाईं ओर के प्रकाश वाले छेद की ओर मुड़ गया है।',
    'e_place_inverted': "पहले 'उल्टा बीकर रखें' पर टैप करें।",
    'e_place_upright': "पहले 'सीधा बीकर रखें' पर टैप करें।",
    'e_cover_first': "पहले 'डिब्बे से ढकें' पर टैप करें।",
    'e_slide_day7': 'स्लाइडर को पूरा ऊपर, दिन 7 तक खींचें।',
    'sum_title_1': 'गुरुत्वानुवर्तन सिद्ध!',
    'sum_1':
        'पौधों में गुरुत्वानुवर्तन (भू-अनुवर्तन) होता है। जड़ें गुरुत्वाकर्षण की ओर नीचे मुड़कर धनात्मक गुरुत्वानुवर्तन दिखाती हैं, जबकि तने गुरुत्वाकर्षण से दूर ऊपर बढ़कर ऋणात्मक गुरुत्वानुवर्तन दिखाते हैं।',
    'next_1':
        'परिदृश्य 1 पूर्ण! कृपया आगे बढ़ने के लिए साइडबार से परिदृश्य 2 चुनें...',
    'sum_title_2': 'प्रकाशानुवर्तन सिद्ध!',
    'sum_2':
        'पौधे का तना हमेशा प्रकाश स्रोत की ओर बढ़ता है। इसे प्रकाशानुवर्तन कहा जाता है। यह पौधे को प्रकाश संश्लेषण के लिए अधिकतम प्रकाश प्राप्त करने में मदद करता है।',
    'next_2':
        'परिदृश्य 2 पूर्ण! आपने इस गतिविधि के सभी परिदृश्यों का सफलतापूर्वक अवलोकन कर लिया है।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'प्रयोगशाला की मेज़ पर उल्टे काँच के बीकर के अंदर आड़ा रखा अंकुरित सेम का बीज',
    'scene_s2':
        'प्रयोगशाला की मेज़ पर सीधे काँच के बीकर में एक अंकुर और दाईं ओर छेद वाला गत्ते का डिब्बा',
  },
};

/// Scenarios and the steps of each (HTML `ScenariosData`).
const int _scenarioCount = 2;
const List<int> _stepCounts = [3, 5];

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

/// HTML `camera.position.set(0, 16, 35)` looking at `controls.target`
/// (0, 0, 0): the direction the scene is seen from.
const _V _htmlView = _V(0, 16, 35);

/// Scenario 1 camera: the HTML direction, aimed at the seedling (y 4.5)
/// from 24 units away (the HTML stood 38.5 away, where the seedling is a
/// few pixels thick on a phone).
const _V _s1Target = _V(0, 4.5, 0);
const double _s1Distance = 24;

/// Scenario 2 camera: aimed at the middle of the box from 31 units away and
/// turned 28° to the right about the vertical, so the box's right side (with
/// the hole the HTML text describes) faces the viewer.
const _V _s2Target = _V(0, 7.5, 0);
const double _s2Distance = 31;
const double _s2Yaw = 28 * math.pi / 180;

/// Where the look-at point lands on the stage: left of centre, clear of the
/// Time-Lapse card and the tool column on the right.
const Offset _stageCenter = Offset(400, 260);

/// While the sidebar is collapsed the scene slides right by this much
/// (design px), so the seedling is clear of the floating mission card at
/// the top left.
const double _s1Shift = 200;
const double _s2Shift = 150;

/// The slide follows the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the sliding scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the slide.
const ValueKey<String> _sceneKey = ValueKey('ch10-a3-scene');

/// Key of the Time-Lapse slider's track.
const ValueKey<String> _sliderKey = ValueKey('ch10a3-day-slider');

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's labels stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// The Time-Lapse card: its top edge (below the toast band), the band kept
/// free for the HUD while the sidebar is open, its width (dp, scaled by the
/// UI scale, at least the minimum), the longest / shortest slider track and
/// the room the rest of the card takes (labels, icon, padding, at UI scale
/// 1).
const double _cardTop = 56;
const double _hudBand = 80;
const double _cardWidth = 64;
const double _cardMinWidth = 60;
const double _columnMax = 140;
const double _columnMin = 56;
const double _cardChrome = 112;

/// HTML `DirectionalLight(0xffffff, 0.9)` at (20, 40, 20), normalised, and
/// the share of ambient (`AmbientLight 0.65`) and direct light on a face.
const _V _light = _V(0.4082, 0.8165, 0.4082);
const double _ambient = 0.62;
const double _diffuse = 0.5;

/// HTML tweens: a beaker (with its seedling) falls from y 20 onto the bench
/// in 1000 ms (Bounce.Out); the box falls from y 25 in 1000 ms (Bounce.Out)
/// and is lifted back up in 1000 ms (Quadratic.Out).
const int _dropMs = 1000;
const int _boxMs = 1000;
const double _dropHeight = 20;
const double _boxLift = 25;

/// HTML day slider: `min="1" max="7"`.
const int _days = 7;

/// The seedling follows the slider with this lag (s), so each new day grows
/// smoothly (the HTML jumped).
const double _growLag = 0.12;

/// Bench `BoxGeometry(36, 1.5, 18)` at y -0.75.
const _V _benchAt = _V(0, -0.75, 0);
const _V _benchSize = _V(36, 1.5, 18);

/// Glass beaker `CylinderGeometry(4.5, 4.5, 9, 32, 1, true)` with a 0.3
/// thick closed end; blotting paper lining it (`CylinderGeometry(4.3, 4.3,
/// 8.5)`, kept inside the glass).
const double _beakerR = 4.5;
const double _beakerH = 9;
const double _endT = 0.3;
const double _paperR = 4.3;
const double _paperBottom = 0.35;
const double _paperH = 8.3;

/// Glass and shadow strengths.
const double _glassBody = 0.08;
const double _glassCap = 0.16;
const double _shadowAlpha = 0.35;

/// Bean seed `SphereGeometry(1)` scaled (1.4, 0.8): drawn 1.0 × 0.62 so the
/// whole seedling fits inside the beaker (the HTML seedling stuck out
/// through the glass).
const double _seedRx = 1.0;
const double _seedRy = 0.62;

/// Scenario 1 seedling (beaker space): the seed at y 4.5 (HTML
/// `s1SeedlingGrp` y 4.5); shoot (left) and root (right) leave it
/// horizontally, run straight from [_s1BaseIn] to [_s1Pivot] from its
/// centre, then grow an arc from [_s1Arc0] to `_s1Arc0 + _s1ArcGrow` long
/// that turns by up to π / 2.2 (the HTML day-7 tip angle): the shoot up,
/// the root down.
const double _s1SeedY = 4.5;
const double _s1BaseIn = 0.8;
const double _s1Pivot = 1.4;
const double _s1Arc0 = 1.4;
const double _s1ArcGrow = 1.6;
const double _s1Bend = math.pi / 2.2;

/// Scenario 2 seedling (beaker space): the plant group sits 0.5 up (HTML
/// `s2PlantGrp` y 0.5) with the seed 4.5 above it; the root points straight
/// down for [_s2Root]; the shoot rises straight from [_s2BaseIn] to
/// [_s2Pivot] above the seed, then its arc grows from [_s2Arc0] to
/// `_s2Arc0 + _s2ArcGrow` and turns by up to π / 4 to the right (the HTML
/// day-7 tip angle).
const double _s2PlantY = 0.5;
const double _s2SeedY = 4.5;
const double _s2RootIn = 0.45;
const double _s2Root = 2.6;
const double _s2BaseIn = 0.5;
const double _s2Pivot = 1.5;
const double _s2Arc0 = 2.5;
const double _s2ArcGrow = 2.5;
const double _s2Bend = math.pi / 4;

/// Stem radii (HTML 0.2 → 0.18 shoot, 0.18 → 0.05 root) and the two first
/// leaves at the shoot tip (the HTML's flattened green sphere, 1.2 × 0.8):
/// half length, half width and spread from the tip direction.
const double _stemR = 0.2;
const double _stemTipR = 0.17;
const double _rootR = 0.17;
const double _rootTipR = 0.06;
const double _leafA = 0.7;
const double _leafB = 0.3;
const double _leafSpread = 0.9;

/// Segments of each growing arc.
const int _arcSegments = 10;

/// Cardboard box `BoxGeometry(11, 14, 11)`, centred 7 up; the hole in its
/// right side (added: the HTML label promises one) and the sunbeam that
/// enters it (`s2Sunbeam`, a cone 2.5 → 1 wide, here coming down from the
/// upper right into the hole).
const _V _boxSize = _V(11, 14, 11);
const double _holeY = 10.5;
const double _holeR = 1.2;
const _V _sunAt = _V(10.5, 15.5, 1);
const double _beamSrcR = 2.2;
const double _beamHoleR = 1.0;
const double _beamAlpha = 0.45;
const double _sunGlowR = 2.2;

/// Above this the box no longer hides the seedling (its tip is below).
const double _plantTopY = 12.5;

/// Scene label heights (HTML `lblInv` y 11.5, `lblBox` y 16.5), and where
/// the added shoot / root labels sit beside the seedling (on the side its
/// shoot and root do not bend to).
const double _invLabelY = 11.2;
const double _boxLabelY = 16.5;
const _V _s1ShootLabel = _V(-2.4, 3.1, 0);
const _V _s1RootLabel = _V(2.4, 5.9, 0);
const _V _s2ShootLabel = _V(3.0, 7.2, 0);
const _V _s2RootLabel = _V(2.4, 3.4, 0);

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);
}

/// [v] turned by [yaw] about the y axis (Three.js `rotation.y`).
_V _yawed(_V v, double yaw) {
  if (yaw == 0) return v;
  final c = math.cos(yaw), s = math.sin(yaw);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

/// Unit direction at angle [a] in the x–y plane (0 = +x, π / 2 = up).
_V _dir(double a) => _V(math.cos(a), math.sin(a), 0);

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage. [center] is where the look-at
/// point lands on the stage.
@immutable
class _Cam {
  /// A camera [distance] from [target] along the HTML view direction,
  /// turned by [yaw] about the vertical.
  factory _Cam.orbit(_V target, double yaw, double distance, Offset center) {
    final eye = target + _yawed(_htmlView.unit, yaw) * distance;
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

  /// Forward (`camera.getWorldDirection`), right and up.
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
}

final _Cam _camS1 = _Cam.orbit(_s1Target, 0, _s1Distance, _stageCenter);
final _Cam _camS2 = _Cam.orbit(_s2Target, _s2Yaw, _s2Distance, _stageCenter);

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
}

/// Points of a growing stem in the x–y plane: straight from [start] to
/// [pivot], then an arc [length] long leaving in direction [angle] and
/// turning clockwise by [turn] (the HTML's negative `rotation.z`).
List<_V> _stem(_V start, _V pivot, double angle, double turn, double length) {
  final pts = <_V>[start, pivot];
  var p = pivot;
  final ds = length / _arcSegments;
  for (var i = 0; i < _arcSegments; i++) {
    p = p + _dir(angle - turn * (i + 0.5) / _arcSegments) * ds;
    pts.add(p);
  }
  return pts;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// A beaker falls or the box moves: the buttons wait.
  bool busy = false;

  /// 'Observe Summary & Conclusion' was tapped: the summary is open.
  bool done = false;

  /// The beaker has started to fall (HTML `visible = true`) / has landed
  /// (HTML `s1Done.place` / `s2Done.place`).
  bool beakerShown = false;
  bool placed = false;

  /// Height of the beaker group above the bench.
  _Ramp drop = const _Ramp.still(_dropHeight);

  /// Scenario 2 box: in the scene, resting over the beaker, its sunbeam on,
  /// and lifted away for good (HTML `s2Done.remove`).
  bool boxShown = false;
  bool boxOn = false;
  bool beamOn = false;
  bool boxRemoved = false;

  /// Height of the box above the bench.
  _Ramp box = const _Ramp.still(_boxLift);

  /// Time-lapse day (HTML slider value) and Day 7 reached (HTML
  /// `s1Done.timelapse` / `s2Done.timelapse`; the slider then stays there).
  int day = 1;
  bool grown = false;

  /// How far the seedling has grown (0 at Day 1 … 1 at Day 7), following
  /// [day] smoothly.
  double growth = 0;

  double get beakerY => drop.at(time);
  double get boxY => box.at(time);

  /// The box hides the seedling.
  bool get plantHidden => boxShown && boxY < _plantTopY;

  /// The last step: 'Observe Summary & Conclusion'.
  int get finishStep => _stepCounts[scenario];

  /// The step with the Time-Lapse slider.
  int get timeLapseStep => scenario == 0 ? 2 : 3;

  _Cam get cam => scenario == 0 ? _camS1 : _camS2;

  // ------------------------------------------ seedling (world space)

  /// Centre of the bean.
  _V get seed => scenario == 0
      ? _V(0, beakerY + _s1SeedY, 0)
      : _V(0, beakerY + _s2PlantY + _s2SeedY, 0);

  /// The shoot from the seed to its tip.
  List<_V> get shoot {
    final c = seed;
    if (scenario == 0) {
      return _stem(
        c + const _V(-_s1BaseIn, 0, 0),
        c + const _V(-_s1Pivot, 0, 0),
        math.pi,
        growth * _s1Bend,
        _s1Arc0 + _s1ArcGrow * growth,
      );
    }
    return _stem(
      c + const _V(0, _s2BaseIn, 0),
      c + const _V(0, _s2Pivot, 0),
      math.pi / 2,
      growth * _s2Bend,
      _s2Arc0 + _s2ArcGrow * growth,
    );
  }

  /// The root from the seed to its tip: in Scenario 1 it bends down as
  /// the shoot bends up (the HTML turned both tips the same way, so its
  /// root bent up); in Scenario 2 it points straight down.
  List<_V> get root {
    final c = seed;
    if (scenario == 0) {
      return _stem(
        c + const _V(_s1BaseIn, 0, 0),
        c + const _V(_s1Pivot, 0, 0),
        0,
        growth * _s1Bend,
        _s1Arc0 + _s1ArcGrow * growth,
      );
    }
    return [
      c - const _V(0, _s2RootIn, 0),
      c - const _V(0, _s2RootIn + _s2Root, 0),
    ];
  }

  /// Direction of the shoot's tip (radians in the x–y plane).
  double get shootTipAngle => scenario == 0
      ? math.pi - growth * _s1Bend
      : math.pi / 2 - growth * _s2Bend;

  _V get shootTip => shoot.last;
  _V get rootTip => root.last;

  // ------------------------------------ design points (scene layer)
  // Where the flows look; in the scene layer's own design coordinates.

  /// The bean, the shoot tip and the root tip on the stage.
  Offset get seedPoint => cam.p(seed);
  Offset get shootTipPoint => cam.p(shootTip);
  Offset get rootTipPoint => cam.p(rootTip);

  /// The hole in the box's right side (Scenario 2).
  Offset get holePoint => _camS2.p(_V(_boxSize.x / 2, boxY + _holeY, 0));

  /// HTML `changeScenario(sc)` / `resetApp()`: everything back to the start.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    beakerShown = false;
    placed = false;
    drop = const _Ramp.still(_dropHeight);
    boxShown = false;
    boxOn = false;
    beamOn = false;
    boxRemoved = false;
    box = const _Ramp.still(_boxLift);
    day = 1;
    grown = false;
    growth = 0;
  }
}

class _TropismLabState extends State<Ch10A3PlantGrowthAndTropismsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The Time-Lapse day: only the Time-Lapse card rebuilds when it changes.
  final ValueNotifier<int> _dayShown = ValueNotifier(1);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Label size in design pixels for the current stage scale, and the
  /// scene x range clear of the floating mission card (sidebar collapsed)
  /// and the tool column (set while laying out).
  double _labelSize = _labelPx;
  double _labelLeft = 0;
  double _labelRight = _design.width;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]` of the current scenario.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

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
    _dayShown.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame advances the clock, lets the seedling catch up with the slider
  /// and repaints.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (t - s.time).clamp(0.0, 0.1);
    s.time = t;
    final target = (s.day - 1) / (_days - 1);
    s.growth += (target - s.growth) * (1 - math.exp(-dt / _growLag));
    _frame.value = t;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)`: cancels every timer and animation and
  /// rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _dayShown.value = 1;
    _lab.resetView(sound: false);
  }

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone
  /// (the HTML toasts were silent).
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

  /// Runs [then] after [ms] if the page is still open.
  void _after(int ms, VoidCallback then) {
    _lab.after(Duration(milliseconds: ms), () {
      if (mounted) then();
    });
  }

  /// The summary popup (HTML `triggerConclusion()`: header "Success!", the
  /// scenario's title, the summary and the "Scenario n Complete!" line).
  void _conclude(int scenario) {
    final n = scenario + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('scen_${n}_opt'),
      body: () => '${_t('sum_title_$n')}\n${_t('sum_$n')}\n\n${_t('next_$n')}',
    );
  }

  // ---------------------------------------------------------------- actions

  /// HTML `handleS1Action('place_inverted')` / `handleS2Action(
  /// 'place_upright')`: the beaker with its seedling falls onto the bench
  /// (1000 ms, Bounce.Out), then the toast and step 2.
  void _place() {
    final s = _scene;
    if (s.busy || s.placed || s.done) return;
    _Sound.pop.play();
    setState(() {
      s
        ..busy = true
        ..beakerShown = true
        ..drop = _Ramp(
          _dropHeight,
          0,
          s.time,
          _dropMs / 1000,
          Curves.bounceOut,
        );
    });
    _after(_dropMs, () {
      setState(() {
        s
          ..busy = false
          ..placed = true
          ..step = 2;
      });
      _toast(s.scenario == 0 ? 't_s1_placed' : 't_s2_placed');
    });
  }

  /// HTML `handleS2Action('cover_box')`: the box falls over the beaker
  /// (1000 ms, Bounce.Out); the sunbeam lights the hole, the slider unlocks,
  /// step 3.
  void _cover() {
    final s = _scene;
    if (s.scenario != 1 || s.busy || !s.placed || s.boxShown || s.done) {
      return;
    }
    setState(() {
      s
        ..busy = true
        ..boxShown = true
        ..box = _Ramp(_boxLift, 0, s.time, _boxMs / 1000, Curves.bounceOut);
    });
    _after(_boxMs, () {
      setState(() {
        s
          ..busy = false
          ..boxOn = true
          ..beamOn = true
          ..step = 3;
      });
      _toast('t_s2_box');
    });
  }

  /// HTML `handleS2Action('remove_box')`: the sunbeam goes out and the box
  /// rises away (1000 ms, Quadratic.Out), then the toast and step 5.
  void _removeBox() {
    final s = _scene;
    if (s.scenario != 1 || s.busy || !s.boxOn || !s.grown || s.done) return;
    _Sound.pop.play();
    setState(() {
      s
        ..busy = true
        ..beamOn = false
        ..boxOn = false
        ..box = _Ramp(0, _boxLift, s.time, _boxMs / 1000, Curves.easeOutQuad);
    });
    _after(_boxMs, () {
      setState(() {
        s
          ..busy = false
          ..boxShown = false
          ..boxRemoved = true
          ..step = 5;
      });
      _toast('t_s2_removed');
    });
  }

  /// HTML `triggerConclusion()` ('Observe Summary & Conclusion'): the
  /// summary. Once done, the button re-opens it.
  void _finish() {
    final s = _scene;
    if (s.busy || (!s.done && s.step != s.finishStep)) return;
    setState(() => s.done = true);
    _conclude(s.scenario);
  }

  // ------------------------------------------------------- time-lapse slider

  /// HTML `slider.disabled`: it moves once the setup is ready (Scenario 1:
  /// the beaker is placed; Scenario 2: the box is on) and stops at Day 7
  /// (added: the HTML let the slider run back, which un-grew the plant).
  bool get _sliderEnabled {
    final s = _scene;
    return _lab.isLabActive &&
        !s.busy &&
        !s.done &&
        !s.grown &&
        (s.scenario == 0 ? s.placed : s.boxOn);
  }

  /// HTML `handleS1Slider(val)` / `handleS2Slider(val)`: the day readout
  /// and the seedling follow the slider (`grow` tone); Day 7 the first time
  /// plays `success`, shows the toast and moves to the next step.
  void _onDay(double value) {
    final s = _scene;
    if (!_sliderEnabled) return;
    final d = value.round().clamp(1, _days);
    if (d == s.day) return;
    s.day = d;
    _dayShown.value = d;
    if (d == _days) {
      _Sound.success.play();
      setState(() {
        s
          ..grown = true
          ..step = s.timeLapseStep + 1;
      });
      _toast(s.scenario == 0 ? 't_s1_day7' : 't_s2_day7');
    } else {
      _Sound.grow.play();
    }
  }

  /// Added: letting go of the slider before Day 7 says how far to go (the
  /// HTML waited silently).
  void _onDayEnd(double value) {
    final s = _scene;
    if (!_lab.isLabActive || s.grown || s.busy || s.done) return;
    if (s.step == s.timeLapseStep && value.round() < _days) {
      _toast('e_slide_day7', error: true, sound: true);
    }
  }

  /// Added: touching the locked slider says what comes first (the HTML
  /// slider was silently disabled).
  void _onSliderLocked() {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done || s.grown) return;
    if (!s.placed) {
      _toast(
        s.scenario == 0 ? 'e_place_inverted' : 'e_place_upright',
        error: true,
        sound: true,
      );
    } else if (s.scenario == 1 && !s.boxOn) {
      _toast('e_cover_first', error: true, sound: true);
    }
  }

  // -------------------------------------------------------------------- UI

  /// The HTML `#ui-s1-controls` / `#ui-s2-controls` buttons and the
  /// conclusion button, each while it applies (the HTML left them
  /// clickable after use, replaying their toasts).
  List<LabAction> _actions() {
    final s = _scene;
    final finish = s.done || (!s.busy && s.step == s.finishStep);
    return [
      if (!s.placed)
        LabAction(
          label: _t(
            s.scenario == 0 ? 'btn_place_inverted' : 'btn_place_upright',
          ),
          icon: s.scenario == 0
              ? Icons.arrow_circle_down
              : Icons.arrow_circle_up,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          enabled: !s.busy,
          highlight: !s.busy,
          // `_place` plays the HTML `pop`.
          silent: true,
          onTap: _place,
        ),
      if (s.scenario == 1 && !s.boxShown && !s.boxRemoved)
        LabAction(
          label: _t('btn_cover'),
          icon: Icons.inventory_2,
          color: _Colors.slate600,
          foreground: _Colors.white,
          enabled: s.placed && !s.busy,
          highlight: s.placed && !s.busy,
          onTap: _cover,
        ),
      if (s.scenario == 1 && s.grown && !s.boxRemoved)
        LabAction(
          label: _t('btn_remove'),
          icon: Icons.visibility,
          color: _Colors.teal600,
          foreground: _Colors.white,
          enabled: !s.busy,
          highlight: !s.busy,
          silent: true,
          onTap: _removeBox,
        ),
      if (finish)
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.emerald600,
          foreground: _Colors.white,
          highlight: !s.done,
          // The summary plays the HTML `success`.
          silent: true,
          onTap: _finish,
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
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.park,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the summary
          // has been opened.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `restartApp()`: back to Scenario 1.
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          overlays: _overlays(context, p),
          stage: _stage(),
        );
      },
    );
  }

  /// The Time-Lapse card (HTML day slider and `#day-counter-overlay`): at
  /// the top right of the canvas, below the toast band, left of the tool
  /// column and above the HUD band.
  List<Widget> _overlays(BuildContext context, LabPalette p) {
    if (!_lab.isLabActive) return const [];
    final s = context.labScale;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final height = MediaQuery.sizeOf(context).height;
    final top = _cardTop + pad.top;
    final band = _lab.isSidebarOpen ? _hudBand : inset.bottom;
    final column = (height - top - band - pad.bottom - _cardChrome * s)
        .clamp(_columnMin, math.max(_columnMin, _columnMax * s))
        .toDouble();
    final width = math.max(_cardMinWidth, _cardWidth * s);
    return [
      Positioned(
        key: const ValueKey('ch10a3-time-lapse'),
        top: top,
        right: inset.right,
        child: _TimeLapseCard(
          palette: p,
          scale: s,
          width: width,
          column: column,
          label: _t('time_lapse'),
          semantics: _t('sim_time'),
          dayOf: _t('day_of'),
          dayN: _t('day_n'),
          day: _dayShown,
          enabled: _sliderEnabled,
          onChanged: _onDay,
          onChangeEnd: _onDayEnd,
          onLocked: _onSliderLocked,
        ),
      ),
    ];
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final shift = _lab.isSidebarOpen
            ? 0.0
            : (_scene.scenario == 0 ? _s1Shift : _s2Shift);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final insets = labOverlayInsets(context, _lab);
          final tools = insets.right;
          _labelLeft = _lab.isSidebarOpen
              ? 0
              : (insets.left - stageLeft) / fit - shift;
          _labelRight =
              math.min(
                _design.width,
                (box.maxWidth - tools - stageLeft) / fit,
              ) -
              shift;
        }
        return LabStage(
          designSize: _design,
          // The slide moves the whole scene layer, so the flows reach its
          // points in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(shift / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
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
                      labelLeft: _labelLeft,
                      labelRight: _labelRight,
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

/// HTML day slider (`<input type="range" min="1" max="7">` with the
/// calendar icon) and `#day-counter-overlay` ("Day n / 7") in one card: an
/// upright slider, Day 7 at the top, Day 1 at the bottom (an upright track
/// fits beside the scene on a phone in landscape).
class _TimeLapseCard extends StatelessWidget {
  const _TimeLapseCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.column,
    required this.label,
    required this.semantics,
    required this.dayOf,
    required this.dayN,
    required this.day,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onLocked,
  });

  final LabPalette palette;
  final double scale;
  final double width;

  /// Length of the slider track (dp).
  final double column;

  /// 'Time-Lapse', 'Simulation Time', `Day {d} / 7` and `Day {d}`.
  final String label;
  final String semantics;
  final String dayOf;
  final String dayN;
  final ValueListenable<int> day;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  /// A touch on the slider while it is locked.
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    final inner = width - 6 * s;
    final teal = p.ink(_Colors.teal500);
    Widget caption(int d) => SizedBox(
      width: inner,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          labFormat(dayN, {'d': d}),
          maxLines: 1,
          style: TextStyle(
            color: p.text,
            fontSize: 9 * s,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
    return LabGlassCard(
      palette: p,
      radius: 14,
      padding: EdgeInsets.symmetric(horizontal: 3 * s, vertical: 7 * s),
      borderColor: _Colors.teal500.withValues(alpha: 0.4),
      child: SizedBox(
        width: inner,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 9 * s,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 3 * s),
            Icon(Icons.calendar_month, size: 18 * s, color: teal),
            ValueListenableBuilder<int>(
              valueListenable: day,
              builder: (context, d, _) => SizedBox(
                width: inner,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labFormat(dayOf, {'d': d}),
                    maxLines: 1,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4 * s),
            caption(_days),
            Semantics(
              label: '$label, $semantics',
              child: SizedBox(
                key: _sliderKey,
                width: inner,
                height: column,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6 * s,
                            activeTrackColor: _Colors.teal500,
                            inactiveTrackColor: p.isDark
                                ? _Colors.slate700
                                : _Colors.slate300,
                            thumbColor: _Colors.white,
                            disabledActiveTrackColor: _Colors.teal500
                                .withValues(alpha: 0.45),
                            disabledInactiveTrackColor: p.isDark
                                ? _Colors.slate700
                                : _Colors.slate300,
                            disabledThumbColor: _Colors.slate400,
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 16 * s,
                            ),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 10 * s,
                              disabledThumbRadius: 9 * s,
                            ),
                            tickMarkShape: RoundSliderTickMarkShape(
                              tickMarkRadius: 2 * s,
                            ),
                            showValueIndicator: ShowValueIndicator.never,
                          ),
                          child: ValueListenableBuilder<int>(
                            valueListenable: day,
                            builder: (context, d, _) => Slider(
                              value: d.toDouble(),
                              min: 1,
                              max: _days.toDouble(),
                              divisions: _days - 1,
                              onChanged: enabled ? onChanged : null,
                              onChangeEnd: onChangeEnd,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // A locked slider ignores touches; this layer answers
                    // them with a hint instead.
                    if (!enabled)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (_) => onLocked(),
                          onVerticalDragStart: (_) => onLocked(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            caption(1),
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

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// The bean's lit look and the sun's glow, made for a unit circle at the
  /// origin and drawn through a transform.
  final Paint bean = Paint()
    ..shader = ui.Gradient.radial(
      const Offset(-0.35, -0.45),
      1.15,
      [labShade(_Colors.seed, 0.4), _Colors.seed, labShade(_Colors.seed, -0.5)],
      const [0, 0.5, 1],
    );
  final Paint sun = Paint()
    ..shader = ui.Gradient.radial(
      Offset.zero,
      1,
      [
        _Colors.sun.withValues(alpha: 0.85),
        _Colors.sun.withValues(alpha: 0.35),
        _Colors.sun.withValues(alpha: 0),
      ],
      const [0, 0.35, 1],
    );
}

/// What the painter makes once and reuses: pens, the background and bench
/// of each scenario and the label text painters. Owned by the page state
/// and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  bool _labelsDark = true;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language, theme or label size
  /// changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _labelsDark) {
      return;
    }
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _labelsDark = dark;
  }

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _labelsDark ? _Colors.labelTextDark : _Colors.labelTextLight,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// What never moves: the background and the bench, in the scenario's
  /// camera.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      labBleed(size),
      pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    _Gfx(
      canvas,
      scenario == 0 ? _camS1 : _camS2,
      pens,
    ).box(_benchAt, _benchSize, _Colors.bench, edge: 0.25);
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

/// Convex hull of [pts] (monotone chain), for glass silhouettes.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  pts.sort(
    (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
  );
  double turn(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in pts) {
    while (lower.length >= 2 &&
        turn(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in pts.reversed) {
    while (upper.length >= 2 &&
        turn(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Segments of rims, discs and ellipses (smooth enough at this size).
const int _ringSides = 40;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  _V get _eyeAt => cam.eye;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Horizontal ring direction at [a] radians (x towards z).
  static _V _ring(double a) => _V(math.cos(a), 0, math.sin(a));

  /// BoxGeometry centred at [c]: the faces seen by the camera, lit; [edge]
  /// darkens (or [edgeColor] colours) the rims.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = c + _V(n.x * hx, n.y * hy, n.z * hz);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _V(k.x * hx, k.y * hy, k.z * hz)));
      }
      path.close();
      final fill = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = fill);
      final rim =
          edgeColor ??
          (edge > 0
              ? labShade(color, -0.5).withValues(alpha: edge * opacity)
              : null);
      if (rim != null) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = rim,
        );
      } else if (opacity >= 1) {
        canvas.drawPath(path, pens.seam..color = fill);
      }
    }
  }

  /// Is the face with outward normal [n] through [point] turned to the
  /// camera?
  bool faces(_V n, _V point) => n.dot(_eyeAt - point) > 0;

  /// A flat horizontal disc of radius [r] centred at [c].
  void disc(_V c, double r, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _ring(i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A flat ellipse centred at [c] spanned by the half axes [a] and [b]
  /// (world vectors).
  void ellipse(_V c, _V a, _V b, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final t = i * 2 * math.pi / _ringSides;
      _to(path, i, cam.p(c + a * math.cos(t) + b * math.sin(t)));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// Soft blurred shadow of an elliptic footprint on the bench (y 0).
  void shadow(double x, double z, double rx, double rz, double alpha) {
    if (alpha <= 0) return;
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
    canvas.drawPath(
      path,
      pens.shadow..color = _Colors.shadow.withValues(alpha: alpha),
    );
  }

  /// Rim of a cylinder end: the ring of radius [r] at [c].
  List<Offset> _rim(_V c, double r) => [
    for (var i = 0; i < _ringSides; i++)
      cam.p(c + _ring(i * 2 * math.pi / _ringSides) * r),
  ];

  /// Clear glass cylinder (`beakerMat`), back part: the faint body and the
  /// far halves of its rims. Draw the contents next and [glassFront] last.
  void glassBack(_V base, double r, double h) {
    final top = base + _V.up * h;
    final hull = _hull([..._rim(base, r), ..._rim(top, r)]);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(
      path,
      pens.fill..color = _Colors.glass.withValues(alpha: _glassBody),
    );
    _halfRim(base, r, near: false, alpha: 0.3);
    _halfRim(top, r, near: false, alpha: 0.35);
  }

  /// Clear glass cylinder, front part: the near rims, the silhouette edges
  /// and a highlight stripe.
  void glassFront(_V base, double r, double h) {
    final top = base + _V.up * h;
    _halfRim(base, r, near: true, alpha: 0.5);
    _halfRim(top, r, near: true, alpha: 0.6);
    // Silhouette lines where the side turns away from the camera.
    final v = _eyeAt - (base + _V.up * (h / 2));
    final a = math.atan2(-v.x, v.z);
    final edge = pens.stroke
      ..strokeWidth = 1.3
      ..color = _Colors.glass.withValues(alpha: 0.5);
    for (final s in [a, a + math.pi]) {
      final d = _ring(s);
      canvas.drawLine(cam.p(base + d * r), cam.p(top + d * r), edge);
    }
    // Highlight towards the key light.
    final hl = _ring(a + math.pi * 0.72);
    canvas.drawLine(
      cam.p(base + _V.up * (h * 0.1) + hl * (r * 0.85)),
      cam.p(base + _V.up * (h * 0.9) + hl * (r * 0.85)),
      pens.limb
        ..strokeWidth = math.max(1.5, 0.14 * cam.scaleAt(base))
        ..color = _Colors.white.withValues(alpha: 0.18),
    );
  }

  /// The near or far half of a rim (seen from the camera).
  void _halfRim(_V c, double r, {required bool near, required double alpha}) {
    final v = _eyeAt - c;
    final path = pens.path..reset();
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final d = _ring(i * 2 * math.pi / _ringSides);
      final isNear = d.dot(v) > 0;
      final o = cam.p(c + d * r);
      if (isNear == near) {
        if (open) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          open = true;
        }
      } else {
        open = false;
      }
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.glass.withValues(alpha: alpha),
    );
  }

  /// The inside of the far half of an upright tube (the blotting paper
  /// lining the beaker behind the seedling), lit facet by facet.
  void liningBack(_V base, double r, double h, Color color) {
    const sides = 24;
    final top = base + _V.up * h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _ring((a0 + a1) / 2);
      final mid = base + _V.up * (h / 2) + m * r;
      // Only the far half: its outside faces away from the camera.
      if (m.dot(_eyeAt - mid) >= 0) continue;
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + _ring(a0) * r));
      _to(path, 1, cam.p(base + _ring(a1) * r));
      _to(path, 2, cam.p(top + _ring(a1) * r));
      _to(path, 3, cam.p(top + _ring(a0) * r));
      path.close();
      final c = _lit(color, m * -1);
      canvas.drawPath(path, pens.fill..color = c);
      canvas.drawPath(path, pens.seam..color = c);
    }
  }

  /// A stem along [pts] (radius [r0] at the start to [r1] at the end,
  /// colour [color] to [tip]): a dark rim, the body and a light streak.
  void stem(List<_V> pts, double r0, double r1, Color color, Color tip) {
    final n = pts.length - 1;
    if (n < 1) return;
    final dark = labShade(color, -0.45);
    for (var pass = 0; pass < 3; pass++) {
      for (var i = 0; i < n; i++) {
        final t = (i + 0.5) / n;
        final a = cam.p(pts[i]);
        final b = cam.p(pts[i + 1]);
        final w =
            2 *
            (r0 + (r1 - r0) * t) *
            cam.scaleAt(pts[i]) *
            (pass == 2 ? 0.35 : 1);
        final body = Color.lerp(color, tip, t)!;
        final paint = pens.limb;
        switch (pass) {
          case 0:
            paint
              ..strokeWidth = w + 1.6
              ..color = dark;
          case 1:
            paint
              ..strokeWidth = w
              ..color = body;
          default:
            paint
              ..strokeWidth = math.max(0.8, w)
              ..color = labShade(body, 0.45).withValues(alpha: 0.7);
        }
        final shift = pass == 2 ? Offset(-w * 0.5, -w * 0.5) : Offset.zero;
        canvas.drawLine(a + shift, b + shift, paint);
      }
    }
  }

  /// The bean (a flattened sphere facing the camera), lit by [paint]'s
  /// unit-circle gradient.
  void bean(_V c, double rx, double ry, Paint paint) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(rx * k, ry * k);
    canvas.drawCircle(Offset.zero, 1, paint);
    canvas.restore();
  }
}

/// Paints the HTML Three.js scene of the current scenario: Scenario 1 the
/// upside-down beaker with the sideways seedling, Scenario 2 the upright
/// beaker, the cardboard box with its hole and the sunbeam.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.labelLeft,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Scene x of the floating mission card's right edge (0 while the
  /// sidebar is open) and of the tool column's left edge: labels stay
  /// between them.
  final double labelLeft;
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintInverted(canvas);
    } else {
      _paintBoxed(canvas);
    }
  }

  /// Shadow strength under a beaker or box [height] above the bench.
  double _shadowAt(double height, double from) =>
      _shadowAlpha * (1 - height / from).clamp(0.0, 1.0);

  // ---------------------------------------------------------- scenario 1

  /// `s1BeakerGrp` (the glass upside down, its closed end on top) with the
  /// blotting paper and `s1SeedlingGrp` lying sideways inside.
  void _paintInverted(Canvas canvas) {
    final s = scene;
    if (!s.beakerShown) return;
    final g = _Gfx(canvas, _camS1, _pens);
    final y = s.beakerY;
    final base = _V(0, y, 0);
    g.shadow(0, 0, _beakerR + 0.4, _beakerR + 0.4, _shadowAt(y, _dropHeight));
    g.glassBack(base, _beakerR, _beakerH);
    g.liningBack(base + _V.up * _paperBottom, _paperR, _paperH, _Colors.paper);
    _paintSeedling(g);
    g.glassFront(base, _beakerR, _beakerH);
    // The closed end (`topClosed`, 0.3 thick at y 9), seen from above.
    final cap = base + _V.up * _beakerH;
    g.disc(cap, _beakerR, _Colors.glass.withValues(alpha: _glassCap));
    g.disc(
      cap - _V.up * _endT,
      _beakerR,
      _Colors.glass.withValues(alpha: _glassCap * 0.5),
    );

    if (!showLabels) return;
    _chip(canvas, _camS1.p(base + _V.up * _invLabelY), _t('lbl_inverted'));
    if (s.placed) _plantLabels(canvas, _camS1, _s1ShootLabel, _s1RootLabel);
  }

  // ---------------------------------------------------------- scenario 2

  /// `s2BeakerGrp` (upright) with the blotting paper and `s2PlantGrp`, then
  /// `s2BoxGrp` with its hole and `s2Sunbeam`.
  void _paintBoxed(Canvas canvas) {
    final s = scene;
    final g = _Gfx(canvas, _camS2, _pens);
    if (s.beakerShown) {
      final y = s.beakerY;
      final base = _V(0, y, 0);
      g.shadow(0, 0, _beakerR + 0.4, _beakerR + 0.4, _shadowAt(y, _dropHeight));
      g.glassBack(base, _beakerR, _beakerH);
      // The closed bottom (`bottomClosed`, 0.3 thick at y 0.15).
      g.disc(
        base + _V.up * _endT,
        _beakerR,
        _Colors.glass.withValues(alpha: _glassCap),
      );
      g.liningBack(
        base + _V.up * _paperBottom,
        _paperR,
        _paperH,
        _Colors.paper,
      );
      _paintSeedling(g);
      g.glassFront(base, _beakerR, _beakerH);
    }
    if (s.boxShown) _paintBox(canvas, g);

    if (!showLabels) return;
    if (s.boxShown) {
      _chip(canvas, _camS2.p(_V(0, s.boxY + _boxLabelY, 0)), _t('lbl_box'));
    }
    if (s.placed && !s.plantHidden) {
      _plantLabels(canvas, _camS2, _s2ShootLabel, _s2RootLabel);
    }
  }

  /// The cardboard box (`BoxGeometry(11, 14, 11)`) at its current height,
  /// the hole in its right side and, while the box is on, the sunbeam.
  void _paintBox(Canvas canvas, _Gfx g) {
    final s = scene;
    final y = s.boxY;
    final hx = _boxSize.x / 2;
    g.shadow(0, 0, hx + 0.6, hx + 0.6, _shadowAt(y, _boxLift));
    g.box(
      _V(0, y + _boxSize.y / 2, 0),
      _boxSize,
      _Colors.cardboard,
      edgeColor: _Colors.cardboardEdge,
    );
    final hole = _V(hx + 0.02, y + _holeY, 0);
    if (g.faces(_V.right, hole)) {
      g.ellipse(
        hole,
        const _V(0, _holeR, 0),
        const _V(0, 0, _holeR),
        _Colors.holeInside,
      );
    }
    if (!s.beamOn) return;
    // The sunbeam: from the sun at the upper right, narrowing into the hole.
    final src = g.cam.p(_sunAt);
    final end = g.cam.p(hole);
    final along = end - src;
    final len = along.distance;
    if (len < 1) return;
    final n = Offset(-along.dy, along.dx) / len;
    final ws = _beamSrcR * g.cam.scaleAt(_sunAt);
    final we = _beamHoleR * g.cam.scaleAt(hole);
    for (final (k, alpha) in const [(1.0, _beamAlpha * 0.6), (0.5, 0.3)]) {
      final path = _pens.path
        ..reset()
        ..moveTo(src.dx + n.dx * ws * k, src.dy + n.dy * ws * k)
        ..lineTo(end.dx + n.dx * we * k, end.dy + n.dy * we * k)
        ..lineTo(end.dx - n.dx * we * k, end.dy - n.dy * we * k)
        ..lineTo(src.dx - n.dx * ws * k, src.dy - n.dy * ws * k)
        ..close();
      canvas.drawPath(
        path,
        _pens.fill..color = _Colors.beam.withValues(alpha: alpha),
      );
    }
    // The lit rim of the hole and the sun's glow.
    final rim = _pens.stroke
      ..strokeWidth = 2
      ..color = _Colors.beam.withValues(alpha: 0.9);
    final path = _pens.path..reset();
    for (var i = 0; i <= _ringSides; i++) {
      final t = i * 2 * math.pi / _ringSides;
      final o = g.cam.p(
        hole + _V(0, _holeR * math.cos(t), _holeR * math.sin(t)),
      );
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, rim);
    final r = _sunGlowR * g.cam.scaleAt(_sunAt);
    canvas.save();
    canvas.translate(src.dx, src.dy);
    canvas.scale(r, r);
    canvas.drawCircle(Offset.zero, 1, _pens.sun);
    canvas.restore();
  }

  // ------------------------------------------------------------ seedling

  /// Root, shoot, bean and the two first leaves at the shoot tip.
  void _paintSeedling(_Gfx g) {
    final s = scene;
    g.stem(s.root, _rootR, _rootTipR, _Colors.root, _Colors.root);
    final shoot = s.shoot;
    g.stem(shoot, _stemR, _stemTipR, _Colors.stem, _Colors.stemTip);
    g.bean(s.seed, _seedRx, _seedRy, _pens.bean);
    final tip = shoot.last;
    final a = s.shootTipAngle;
    final color = _lit(_Colors.leaf, _V.front);
    final rib = _pens.stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.leaf, -0.35);
    for (final side in const [-1.0, 1.0]) {
      final la = a + side * _leafSpread;
      final along = _dir(la);
      final across = _dir(la + math.pi / 2);
      final c = tip + along * _leafA + _V.front * 0.05;
      g.ellipse(c, along * _leafA, across * _leafB, color);
      g.canvas.drawLine(g.cam.p(tip), g.cam.p(c + along * _leafA * 0.8), rib);
    }
  }

  // ------------------------------------------------------------ labels

  /// The added 'Shoot' and 'Root' labels beside the seedling (in beaker
  /// space, so they ride down with it).
  void _plantLabels(Canvas canvas, _Cam cam, _V shoot, _V root) {
    final base = _V(0, scene.beakerY, 0);
    _chip(canvas, cam.p(base + shoot), _t('lbl_shoot'));
    _chip(canvas, cam.p(base + root), _t('lbl_root'));
  }

  /// HTML `createTextSprite()` chip: a rounded panel with a thin border and
  /// bold text centred on [at], kept clear of the mission card and the tool
  /// column.
  void _chip(Canvas canvas, Offset at, String text) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.7, padY = size * 0.35;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final minX = math.max(0.0, labelLeft) + w / 2 + 4;
    final cx = at.dx
        .clamp(minX, math.max(minX, labelRight - w / 2 - 4))
        .toDouble();
    final rect = Rect.fromCenter(
      center: Offset(cx, at.dy),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.6));
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.labelBgDark : _Colors.labelBgLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = isDark ? _Colors.labelBorderDark : _Colors.labelBorderLight,
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
      old.labelLeft != labelLeft ||
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
