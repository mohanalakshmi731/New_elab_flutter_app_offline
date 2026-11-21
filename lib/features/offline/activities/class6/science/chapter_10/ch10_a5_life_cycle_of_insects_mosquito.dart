// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 10 • Activity 5
/// Life Cycle of Insects (Mosquito).
///
/// Native Flutter port of `Cl6S-Ch10-A5-Life_Cycle_of_Insects__Mosquito_.html`.
///
/// Scenario 1 (Sequencing the Metamorphosis): a magnifying glass dropped on
/// a container of stagnant water zooms in on the wriggling larvae and the
/// comma-shaped pupae; a time-lapse slider turns larvae into pupae and lets
/// adult mosquitoes emerge from the pupae; the stage labels Larva, Pupa and
/// Adult Mosquito are then dropped onto the boxes II, III and IV of a
/// timeline that starts with the egg (I).
///
/// Scenario 2 (Breaking the Cycle): a can of kerosene oil tilted over the
/// water spreads an oil film that the larvae and pupae cannot breathe
/// through, so they sink; with fresh water, a lid covers the container and
/// an adult mosquito that flies in cannot reach the water to lay eggs.
///
/// The Three.js bench, glass container and animals are redrawn by a
/// CustomPainter through a perspective projection of the HTML camera
/// (fov 45°, at (0, 16, 35) looking at the origin; the magnifying glass
/// glides it to (0, 10, 20) looking at (0, 5, 0)). The projected scene is
/// fitted into the part of the canvas no card covers.
class Ch10A5LifeCycleOfInsectsMosquitoPage extends StatefulWidget {
  const Ch10A5LifeCycleOfInsectsMosquitoPage({super.key});

  @override
  State<Ch10A5LifeCycleOfInsectsMosquitoPage> createState() =>
      _MosquitoLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises four Web Audio tones: `click`
/// (buttons, Enter Lab, scenario change, the magnifying glass placed),
/// `pop` (a label dropped on the wrong box, the lid placed, the adult
/// mosquito sent in), `water` (the kerosene poured, mapped to drop.mp3) and
/// `success` (the summary). A correct label plays correct.mp3 (the HTML
/// played its short `success` arpeggio); error.mp3 marks the added hints.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pop → `science/pop.mp3`, water → `science/drop.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `pop`.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `water`: a noise burst through a band-pass filter.
  water('audio/class6/science/drop.mp3'),

  /// A label on its right box; the "Scenario Complete" toast.
  correct('audio/class6/science/correct.mp3'),

  /// Added hints after a wrong action (the HTML stayed silent or popped).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the summary.
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
  static const Color cyan100 = Color(0xFFCFFAFE);
  static const Color cyan300 = Color(0xFF67E8F9);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan700 = Color(0xFF0E7490);
  static const Color cyan900 = Color(0xFF164E63);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green900 = Color(0xFF14532D);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange600 = Color(0xFFEA580C);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background: #1e293b (dark), #e2e8f0 (light).
  static const Color sceneDark = slate800;
  static const Color sceneLight = slate200;

  /// Bench `MeshStandardMaterial({color: 0x334155})`.
  static const Color bench = slate700;

  /// Glass jar 0xe2e8f0 (opacity 0.35) and water 0x0284c7 (opacity 0.6).
  static const Color glass = slate200;
  static const Color water = Color(0xFF0284C7);

  /// Animals: egg raft and pupae 0x1e293b, larva bodies 0x334155, heads
  /// 0x0f172a; adult body 0x1e293b, head 0x0f172a, wings white (0.7).
  static const Color animal = slate800;
  static const Color animalBody = slate700;
  static const Color animalHead = slate900;

  /// Light edge on the dark animals, so they stand out in the blue water.
  static const Color animalEdge = Color(0xFF94A3B8);

  /// Added: the empty pupal skin left floating after an adult emerges.
  static const Color pupalCase = Color(0xFFD6C7A1);

  /// Oil film `MeshStandardMaterial({color: 0xa855f7, metalness: 0.8})`
  /// (opacity 0.85), with an added oily sheen.
  static const Color oil = Color(0xFFA855F7);
  static const Color oilSheenPink = Color(0xFFF0ABFC);
  static const Color oilSheenTeal = Color(0xFF5EEAD4);

  /// Added: the kerosene poured from the can (pale amber).
  static const Color kerosene = Color(0xFFFDE68A);

  /// Lid `MeshStandardMaterial({color: 0x94a3b8})`.
  static const Color lid = slate400;

  /// Text sprites (`updateSpriteText`): dark rgba(30, 41, 59, 0.92) with a
  /// #475569 border and white text; light white (0.92), #cbd5e1, #0f172a.
  static const Color spriteDark = Color(0xEB1E293B);
  static const Color spriteLight = Color(0xEBFFFFFF);

  /// Soft contact shadow (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x66000000);
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
    accent: _Colors.cyan500, // text-cyan-500 headings, border-cyan-500
    onAccent: _Colors.slate950, // Enter Lab text-slate-950
    primary: _Colors.blue600, // conclude button to-blue-600
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.cyan400,
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66164E63), // from-cyan-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC67E8F9), // subtitle text-cyan-300/80
    curtainIcon: _Colors.cyan400,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.cyan500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteDark,
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
    accent: _Colors.cyan600,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.cyan600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66164E63),
    curtainText: _Colors.white,
    curtainMuted: _Colors.cyan300,
    curtainIcon: _Colors.cyan400,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.cyan500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteLight,
    labelText: _Colors.slate900,
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
// say exactly what to do on a touch screen ("tap" instead of "click"); the
// concepts that named a result before it was seen ("Larva to Pupa
// Transformation", "Adult Mosquito Emergence", "Mosquito Access Blocked")
// are neutral. The HTML's short Hindi steps are written out in full, and
// its garbled summaries are rewritten. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Life Cycle of Insects (Mosquito)',
    'app_subtitle':
        'Class 6 • Living Creatures: Exploring their Characteristics',
    'scen_1': 'Scenario 1: Sequencing the Metamorphosis',
    'scen_2': 'Scenario 2: Breaking the Cycle',
    's1_obj':
        'To observe a container of stagnant water over time and correctly identify the sequence of the mosquito life cycle from larva to adult.',
    's2_obj':
        'To investigate and apply methods to disrupt the mosquito life cycle in a stagnant water source, as discussed in the textbook.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Getting a Closer Look',
    's1_a1':
        'Drag the magnifying glass and drop it over the container of stagnant water to get a closer look at the creatures inside.',
    's1_o1':
        'The view zooms into the water, clearly showing many wriggling creatures of two different shapes: worm-like ones (larvae) and comma-shaped ones (pupae).',
    's1_c2': 'Time-Lapse: The First Days',
    's1_a2':
        "Drag the 'Time-Lapse' slider slowly to the right, past the middle, to speed up time and observe the changes.",
    's1_o2':
        'Some larvae transform into pupae. The number of larvae decreases while the number of pupae increases.',
    's1_c3': 'Time-Lapse: The Last Days',
    's1_a3':
        "Continue to drag the 'Time-Lapse' slider further, all the way to the right end, then let go.",
    's1_o3':
        'Pupae at the surface split open, and adult mosquitoes emerge from them.',
    's1_c4': 'Sequencing the Life Cycle',
    's1_a4':
        'Drag each stage label (Adult Mosquito, Larva, Pupa) from the panel and drop it onto the box where it belongs (II, III or IV) on the timeline below the container. Box I is the egg.',
    's1_o4':
        'Larva, Pupa and Adult Mosquito are placed in the correct sequence after the Egg.',
    // Scenario 2 steps.
    's2_c1': 'Pouring Kerosene Oil',
    's2_a1':
        'Drag the can of kerosene oil from the shelf over the water container and let go: the can tilts and pours the oil.',
    's2_o1':
        'Oil is poured onto the water, creating a visible film on the surface.',
    's2_c2': 'Effect of the Oil Film',
    's2_a2': 'Observe the effect of the oil film on the larvae and pupae.',
    's2_o2':
        'Larvae and pupae try to reach the surface but are blocked by the oil film. They stop moving and sink to the bottom.',
    's2_c3': 'Covering the Water Source',
    's2_a3':
        "Tap the 'Reset Water' button. Then drag the lid from the shelf and drop it onto the water container to cover it completely.",
    's2_o3': 'The water container is completely covered by the lid.',
    's2_c4': 'An Adult Mosquito Arrives',
    's2_a4': "Tap the 'Adult Mosquito' button to see what happens next.",
    's2_o4':
        'An adult mosquito flies in, tries to land on the covered container, cannot reach the water and flies away.',
    // HTML `hud-instruction` lines.
    's1_hud_1':
        'Step 1: Drag the magnifying glass over the container of stagnant water to get a closer look at the creatures inside.',
    's1_hud_2':
        "Step 2: Drag the 'Time-Lapse' slider slowly to the right to speed up time and observe the changes.",
    's1_hud_3':
        "Step 3: Continue to drag the 'Time-Lapse' slider further, to the right end.",
    's1_hud_4':
        'Step 4: Drag the stage labels (Adult Mosquito, Larva, Pupa) onto the boxes where they belong on the timeline below the container.',
    's1_hud_5': 'Step 5: Observe Summary & Conclusion',
    's2_hud_1':
        'Step 1: Drag the can of kerosene oil from the shelf over the water container and let go, so it tilts and pours.',
    's2_hud_2':
        'Step 2: Observe the effect of the oil film on the larvae and pupae.',
    's2_hud_3':
        "Step 3: Tap 'Reset Water'. Then drag the lid from the shelf onto the water container to cover it completely.",
    's2_hud_4':
        "Step 4: Tap the 'Adult Mosquito' button to see what happens next.",
    's2_hud_5': 'Step 5: Observe Summary & Conclusion',
    // Buttons.
    'btn_reset_water': 'Reset Water',
    'btn_adult': 'Adult Mosquito',
    'btn_conclude': 'Observe Summary & Conclusion',
    // Canvas cards.
    'phase': 'Current Phase',
    'phase_s1a': 'Getting a Closer Look',
    'phase_s1b': 'Magnified View',
    'phase_s2a': 'Pouring Kerosene Oil',
    'phase_s2b': 'Oil Slick Intervention',
    'drag_me': 'Drag Me',
    'magnifier': 'Magnifying glass',
    'shelf': 'Shelf',
    'oil': 'OIL',
    'oil_can': 'Can of kerosene oil',
    'lid': 'LID',
    'lid_long': 'Lid',
    'day_first': 'Day 1',
    'day_last': 'Day 7+',
    'time_lapse': 'Time-Lapse (7 Days)',
    'stage_egg': 'Egg',
    'stage_larva': 'Larva',
    'stage_pupa': 'Pupa',
    'stage_adult': 'Adult Mosquito',
    // Canvas labels (HTML `createTextSprite`).
    'lbl_eggs': 'Egg Raft (Floating)',
    'lbl_adult': 'Adult Mosquito (Imago)',
    // Toasts (HTML `showToast`).
    't_zoom': 'View zoomed! Wriggling larvae and tumbling pupae visible.',
    't_sequence': 'Sequence completed correctly!',
    't_covered': 'Water container completely covered!',
    't_blocked':
        'Access blocked! The mosquito cannot reach the water to lay eggs.',
    // Added toasts and hints (the HTML accepted any drop on the canvas,
    // stated the oil's effect before it was seen and stayed silent).
    't_poured': 'Oil poured! A thin film of oil now covers the water surface.',
    't_sunk':
        'The larvae and pupae could not get air through the oil film: they stopped moving and sank.',
    't_reset':
        'Fresh stagnant water with live larvae and pupae. Now cover it with the lid.',
    't_correct_label': 'Correct! Box {n}: {name}',
    't_more_half': 'Keep dragging the slider to the right, past the middle.',
    't_more_end': 'Drag the slider all the way to the right end.',
    't_lapse_done':
        'Time-lapse complete! Now drag the stage labels onto the timeline.',
    'e_mag': 'Drop the magnifying glass over the container of stagnant water.',
    'e_wrong_label':
        'That stage does not belong in box {n}. Think about the order you saw in the time-lapse.',
    'e_label_drop': 'Drop the label onto one of the boxes II, III or IV.',
    'e_oil_drop': 'Drop the can of kerosene oil over the water container.',
    'e_lid_early':
        'First pour the kerosene oil: drag the can over the water container.',
    'e_lid_reset':
        "Tap 'Reset Water' first to get fresh water, then cover it with the lid.",
    'e_lid_drop': 'Drop the lid onto the water container.',
    // Summary popup (HTML `triggerConclusion`).
    'sum_head_1': 'Life Cycle Summary',
    'sum_1':
        'We have seen that a mosquito begins its life as an egg (stage I). The egg develops into a larva (stage II), the larva grows into a pupa (stage III), and the pupa transforms into an adult mosquito (stage IV).',
    'next_1':
        'Scenario 1 Complete! Please select Scenario 2 from the sidebar to continue.',
    'sum_head_2': 'Cycle Breaker Summary',
    'sum_2':
        'Kerosene works because its oil film covers the water surface, so the larvae and pupae cannot take in air from the surface: they stop moving and sink to the bottom. A lid keeps adult mosquitoes away from the water, so they cannot lay their eggs in it. These are two ways of breaking the cycle: stop the larvae and pupae from breathing, and keep adult mosquitoes from laying eggs.',
    'next_2':
        'Scenario 2 Complete! You have explored both scenarios in this activity.',
    'all_done':
        'You mastered the 4-stage metamorphosis of mosquitoes (Egg, Larva, Pupa, Adult) and learned practical ways to break their breeding cycle and prevent diseases spread by mosquitoes!',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene': 'A glass container of stagnant water on a laboratory bench',
  },
  'hi': {
    'app_title': 'कीटों का जीवन चक्र (मच्छर)',
    'app_subtitle': 'कक्षा 6 • सजीव प्राणी: उनकी विशेषताओं की खोज',
    'scen_1': 'परिदृश्य 1: कायांतरण का क्रम',
    'scen_2': 'परिदृश्य 2: चक्र को तोड़ना',
    's1_obj':
        'ठहरे हुए पानी के एक पात्र को समय के साथ देखना और लार्वा से वयस्क तक मच्छर के जीवन चक्र का सही क्रम पहचानना।',
    's2_obj':
        'पाठ्यपुस्तक में बताए गए उपायों से ठहरे पानी में मच्छर के जीवन चक्र को तोड़ने के तरीके जाँचना और अपनाना।',
    's1_c1': 'करीब से देखना',
    's1_a1':
        'आवर्धक लेंस को खींचें और ठहरे पानी के पात्र के ऊपर छोड़ दें, ताकि अंदर के जीवों को करीब से देख सकें।',
    's1_o1':
        'दृश्य पानी के अंदर बड़ा हो जाता है और दो अलग आकार के कई छटपटाते जीव साफ दिखते हैं: कृमि जैसे (लार्वा) और कॉमा के आकार के (प्यूपा)।',
    's1_c2': 'टाइम-लैप्स: पहले कुछ दिन',
    's1_a2':
        "समय को तेज़ करने और बदलाव देखने के लिए 'टाइम-लैप्स' स्लाइडर को धीरे-धीरे दाईं ओर, बीच से आगे तक खींचें।",
    's1_o2':
        'कुछ लार्वा प्यूपा में बदल जाते हैं। लार्वा की संख्या घटती है और प्यूपा की संख्या बढ़ती है।',
    's1_c3': 'टाइम-लैप्स: आखिरी दिन',
    's1_a3':
        "'टाइम-लैप्स' स्लाइडर को और आगे, बिल्कुल दाएँ सिरे तक खींचें, फिर छोड़ दें।",
    's1_o3':
        'सतह पर प्यूपा फट जाते हैं और उनमें से वयस्क मच्छर बाहर निकलते हैं।',
    's1_c4': 'जीवन चक्र को क्रम में लगाना',
    's1_a4':
        'हर अवस्था के लेबल (वयस्क मच्छर, लार्वा, प्यूपा) को पैनल से खींचें और पात्र के नीचे समयरेखा पर उस खाने (II, III या IV) पर छोड़ें जहाँ वह आता है। खाना I अंडा है।',
    's1_o4': 'अंडे के बाद लार्वा, प्यूपा और वयस्क मच्छर सही क्रम में रखे गए।',
    's2_c1': 'केरोसिन तेल डालना',
    's2_a1':
        'केरोसिन तेल के डिब्बे को शेल्फ़ से खींचकर पानी के पात्र के ऊपर छोड़ें: डिब्बा झुककर तेल डालता है।',
    's2_o1': 'पानी पर तेल डाला जाता है और सतह पर तेल की एक परत दिखाई देती है।',
    's2_c2': 'तेल की परत का प्रभाव',
    's2_a2': 'लार्वा और प्यूपा पर तेल की परत का प्रभाव देखें।',
    's2_o2':
        'लार्वा और प्यूपा सतह तक पहुँचने की कोशिश करते हैं, पर तेल की परत उन्हें रोक देती है। वे हिलना बंद कर देते हैं और नीचे डूब जाते हैं।',
    's2_c3': 'पानी को ढकना',
    's2_a3':
        "'पानी रीसेट करें' बटन दबाएँ। फिर ढक्कन को शेल्फ़ से खींचकर पानी के पात्र पर छोड़ें, ताकि वह पूरी तरह ढक जाए।",
    's2_o3': 'पानी का पात्र ढक्कन से पूरी तरह ढक गया है।',
    's2_c4': 'एक वयस्क मच्छर आता है',
    's2_a4': "आगे क्या होता है, यह देखने के लिए 'वयस्क मच्छर' बटन दबाएँ।",
    's2_o4':
        'एक वयस्क मच्छर उड़कर आता है, ढके हुए पात्र पर बैठने की कोशिश करता है, पानी तक नहीं पहुँच पाता और उड़ जाता है।',
    's1_hud_1':
        'चरण 1: अंदर के जीवों को करीब से देखने के लिए आवर्धक लेंस को ठहरे पानी के पात्र के ऊपर खींचें।',
    's1_hud_2':
        "चरण 2: 'टाइम-लैप्स' स्लाइडर को धीरे-धीरे दाईं ओर खींचें और बदलाव देखें।",
    's1_hud_3': "चरण 3: 'टाइम-लैप्स' स्लाइडर को और आगे, दाएँ सिरे तक खींचें।",
    's1_hud_4':
        'चरण 4: अवस्था के लेबल (वयस्क मच्छर, लार्वा, प्यूपा) को पात्र के नीचे समयरेखा पर उनके सही खानों में खींचें।',
    's1_hud_5': 'चरण 5: निष्कर्ष और सारांश देखें',
    's2_hud_1':
        'चरण 1: केरोसिन तेल के डिब्बे को शेल्फ़ से पानी के पात्र के ऊपर खींचकर छोड़ें, ताकि वह झुककर तेल डाले।',
    's2_hud_2': 'चरण 2: लार्वा और प्यूपा पर तेल की परत का प्रभाव देखें।',
    's2_hud_3':
        "चरण 3: 'पानी रीसेट करें' दबाएँ। फिर ढक्कन को शेल्फ़ से खींचकर पात्र को पूरी तरह ढक दें।",
    's2_hud_4':
        "चरण 4: आगे क्या होता है, यह देखने के लिए 'वयस्क मच्छर' बटन दबाएँ।",
    's2_hud_5': 'चरण 5: निष्कर्ष और सारांश देखें',
    'btn_reset_water': 'पानी रीसेट करें',
    'btn_adult': 'वयस्क मच्छर',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'phase': 'वर्तमान चरण',
    'phase_s1a': 'करीब से देखना',
    'phase_s1b': 'आवर्धित दृश्य',
    'phase_s2a': 'केरोसिन तेल डालना',
    'phase_s2b': 'तेल की परत का उपाय',
    'drag_me': 'मुझे खींचें',
    'magnifier': 'आवर्धक लेंस',
    'shelf': 'शेल्फ़',
    'oil': 'तेल',
    'oil_can': 'केरोसिन तेल का डिब्बा',
    'lid': 'ढक्कन',
    'lid_long': 'ढक्कन',
    'day_first': 'दिन 1',
    'day_last': 'दिन 7+',
    'time_lapse': 'टाइम-लैप्स (7 दिन)',
    'stage_egg': 'अंडा',
    'stage_larva': 'लार्वा',
    'stage_pupa': 'प्यूपा',
    'stage_adult': 'वयस्क मच्छर',
    'lbl_eggs': 'अंडों का समूह (तैरता हुआ)',
    'lbl_adult': 'वयस्क मच्छर (इमागो)',
    't_zoom':
        'दृश्य बड़ा हुआ! छटपटाते लार्वा और लुढ़कते प्यूपा दिखाई दे रहे हैं।',
    't_sequence': 'क्रम सही ढंग से पूरा हुआ!',
    't_covered': 'पानी का पात्र पूरी तरह ढक गया!',
    't_blocked': 'रास्ता बंद! मच्छर अंडे देने के लिए पानी तक नहीं पहुँच पाता।',
    't_poured': 'तेल डाला गया! अब पानी की सतह पर तेल की पतली परत है।',
    't_sunk':
        'लार्वा और प्यूपा तेल की परत से हवा नहीं ले पाए: वे हिलना बंद करके नीचे डूब गए।',
    't_reset':
        'जीवित लार्वा और प्यूपा वाला ताज़ा ठहरा पानी। अब इसे ढक्कन से ढकें।',
    't_correct_label': 'सही! खाना {n}: {name}',
    't_more_half': 'स्लाइडर को दाईं ओर, बीच से आगे तक खींचते रहें।',
    't_more_end': 'स्लाइडर को बिल्कुल दाएँ सिरे तक खींचें।',
    't_lapse_done': 'टाइम-लैप्स पूरा हुआ! अब अवस्था के लेबल समयरेखा पर खींचें।',
    'e_mag': 'आवर्धक लेंस को ठहरे पानी के पात्र के ऊपर छोड़ें।',
    'e_wrong_label':
        'यह अवस्था खाने {n} में नहीं आती। टाइम-लैप्स में देखा गया क्रम याद करें।',
    'e_label_drop': 'लेबल को खाने II, III या IV में से किसी एक पर छोड़ें।',
    'e_oil_drop': 'केरोसिन तेल के डिब्बे को पानी के पात्र के ऊपर छोड़ें।',
    'e_lid_early':
        'पहले केरोसिन तेल डालें: डिब्बे को पानी के पात्र के ऊपर खींचें।',
    'e_lid_reset':
        "पहले 'पानी रीसेट करें' दबाकर ताज़ा पानी लें, फिर उसे ढक्कन से ढकें।",
    'e_lid_drop': 'ढक्कन को पानी के पात्र पर छोड़ें।',
    'sum_head_1': 'जीवन चक्र सारांश',
    'sum_1':
        'हमने देखा कि मच्छर का जीवन अंडे (अवस्था I) से शुरू होता है। अंडे से लार्वा (अवस्था II) बनता है, लार्वा बढ़कर प्यूपा (अवस्था III) बनता है, और प्यूपा से वयस्क मच्छर (अवस्था IV) बनता है।',
    'next_1':
        'परिदृश्य 1 पूर्ण! आगे बढ़ने के लिए कृपया साइडबार से परिदृश्य 2 चुनें।',
    'sum_head_2': 'चक्र तोड़ने का सारांश',
    'sum_2':
        'केरोसिन इसलिए काम करता है क्योंकि उसके तेल की परत पानी की सतह को ढक देती है, इसलिए लार्वा और प्यूपा सतह से हवा नहीं ले पाते: वे हिलना बंद करके नीचे डूब जाते हैं। ढक्कन वयस्क मच्छरों को पानी से दूर रखता है, इसलिए वे उसमें अंडे नहीं दे पाते। चक्र तोड़ने के ये दो तरीके हैं: लार्वा और प्यूपा का साँस लेना रोकना, और वयस्क मच्छरों को अंडे देने से रोकना।',
    'next_2':
        'परिदृश्य 2 पूर्ण! आपने इस गतिविधि के दोनों परिदृश्यों का अवलोकन कर लिया है।',
    'all_done':
        'आपने मच्छर के 4 अवस्थाओं वाले कायांतरण (अंडा, लार्वा, प्यूपा, वयस्क) को समझा और उसके प्रजनन चक्र को तोड़कर मच्छरों से फैलने वाली बीमारियों को रोकने के व्यावहारिक तरीके सीखे!',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene': 'लैब की मेज़ पर ठहरे पानी से भरा काँच का पात्र',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 4;

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_$n'),
        objective: t('s${n}_obj'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
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
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Scene labels: 13 design px, enlarged up to 1.8x on small stages so the
/// HTML's text sprites stay readable.
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Canvas cards: the top of the cards on the right (below the toast band),
/// the band kept for the HUD chip while the sidebar is open, the gap kept
/// between a card and the scene, and the widest bottom panel (dp, scaled by
/// the UI scale).
const double _cardTop = 56;
const double _hudBand = 66;
const double _cardGap = 8;
const double _panelMaxWidth = 440;

/// Floating mission card (sidebar collapsed): its top, and on phones
/// (screens shorter than [_compactBelow]) its greatest height as a fraction
/// of the screen (as the shell lays it out).
const double _missionTop = 12;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;

/// Largest zoom of the fitted scene (the start view shows the whole bench;
/// the magnified view and Scenario 2 the container), how long a re-fit
/// slides (s) and the longest frame step (s).
const double _maxZoomFar = 1.1;
const double _maxZoomNear = 1.6;
const double _framingSeconds = 0.4;
const double _maxFrameStep = 0.1;

// ---------------------------------------------------------------- camera

/// HTML `camera.position.set(0, 16, 35)` with `controls.target` (0, 0, 0),
/// and the magnified view: `TWEEN … to({y: 10, z: 20}, 1000)` (Cubic.Out)
/// with `controls.target.set(0, 5, 0)` (here eased together).
const _View _farView = _View(_V(0, 16, 35), _V.zero);
const _View _nearView = _View(_V(0, 10, 20), _V(0, 5, 0));
const double _zoomSeconds = 1;

// ----------------------------------------------------------- bench + jar

/// Bench `BoxGeometry(36, 1.5, 18)` at y -0.75: its top at y 0.
const double _benchHalfW = 18;
const double _benchHalfD = 9;
const double _benchH = 1.5;

/// Glass jar: open `CylinderGeometry(6.5, 6.0, 8.0)` at y 4 (0 … 8).
const double _jarTopR = 6.5;
const double _jarBottomR = 6.0;
const double _jarH = 8;

/// Water `CylinderGeometry(6.3, 5.8, 6.5)` at y 3.25: its surface at 6.5.
const double _waterTopR = 6.3;
const double _waterBottomR = 5.8;
const double _surfaceY = 6.5;

/// Egg raft group at (0, 6.5, 0): 15 eggs `(e % 4) * 0.3 - 0.4`,
/// `floor(e / 4) * 0.3 - 0.4`; its label sprite at (0, 10.5, 0).
const int _eggCount = 15;
const double _eggGrid = 0.3;
const double _eggOffset = 0.4;
const _V _eggLabelAt = _V(0, 10.5, 0);

// --------------------------------------------------------------- animals

/// Larvae group at y 6.3: six wrigglers at x `(l - 2.5) * 1.8`, z ±1.5,
/// hanging 2.8 below the surface; wriggle `sin(Date.now() * 0.006 + i) *
/// 0.3` (6 rad/s).
const int _larvaCount = 6;
const double _larvaY = 6.3;
const double _larvaSpacing = 1.8;
const double _rowZ = 1.5;
const double _wriggleRate = 6;
const double _wriggleAmp = 0.3;

/// Pupae group at y 6.2: four tumblers at x `(pu - 1.5) * 2`, z ∓1.5.
/// Added: a slow rocking (the HTML's pupae were still).
const int _pupaCount = 4;
const double _pupaY = 6.2;
const double _pupaSpacing = 2;
const double _rockRate = 2.2;
const double _rockAmp = 0.12;

/// Time-lapse (HTML `handleTimeLapse(v)`, slider 0 … 100). Up to the middle
/// larvae turn into pupae: larva i is gone once `v / 50 > (i + 1) / 6` and
/// pupa i there once `4 · v / 50 + 2 > i` (the HTML started from one pupa,
/// although the magnified view showed two). Past the middle the larvae are
/// gone and pupa i splits open at `(v - 50) / 50 =` [_emergeAt] +
/// [_emergeStep] · i, its adult climbing out over [_riseSpan] (the HTML's
/// thresholds were `(i + 1) / 4`, so the last pupa only opened at 100, and
/// its one adult never showed in Scenario 1: it belonged to the hidden
/// Scenario 2 group). Step 2 ends past [_lapseHalf]; step 3 when the slider
/// is let go past [_lapseEnd].
const double _lapseHalf = 50;
const double _lapseEnd = 90;
const double _lapseMax = 100;
const double _emergeAt = 0.12;
const double _emergeStep = 0.22;
const double _riseSpan = 0.14;
const double _fade = 0.03;

/// Where the adults that emerged in Scenario 1 hover (one per pupa), and
/// their size against the Scenario 2 adult (HTML body 3.5, wings 4.5).
const List<_V> _adultHover = [
  _V(-4.4, 10.1, -0.8),
  _V(-1.5, 11.3, 0.8),
  _V(1.6, 10.4, -0.6),
  _V(4.5, 11.5, 0.6),
];
const double _adultSmall = 0.85;
const double _adultBig = 1.25;

/// HTML `s2AdultGrp.position.y += Math.sin(Date.now() * 0.008) * 0.02`:
/// a gentle bob; wings beat (added).
const double _bobRate = 8;
const double _bobAmp = 0.15;
const double _flapRate = 45;

// --------------------------------------------------------- scenario 2

/// Kerosene (added: the can tilts and pours, as the step says): the can
/// glides in above the container's right rim and tilts (0.35 s), pours
/// (1 s) while the film spreads, then tilts back and fades (0.35 s). Oil
/// film `CylinderGeometry(6.35, 6.35, 0.15)` at y 6.55.
const _V _canStart = _V(9, 14, 1.5);
const _V _canPour = _V(5.4, 11.8, 1.5);
const double _canTilt = 1.95;
const double _pourIn = 0.35;
const double _pourFlow = 1;
const double _pourOut = 0.35;
const double _filmY = 6.55;
const double _filmR = 6.3;

/// HTML sink: larvae and pupae go down in 2.5 s (Quadratic.In); added
/// before it: 0.8 s of struggling under the film. The HTML sank the groups
/// to y 1.5, which put the hanging larvae through the bottom of the
/// container; they now come to rest on it, tilted over.
const double _struggleSeconds = 0.8;
const double _sinkSeconds = 2.5;
const double _larvaBottomY = 1;
const double _pupaBottomY = 1.9;
const double _sunkTilt = 1.3;

/// Lid `CylinderGeometry(6.6, 6.6, 0.4)`: the HTML dropped it from y 10 to
/// 6.6 (inside the jar, at the water) in 0.8 s (Bounce.Out); it now drops
/// onto the rim and covers the opening.
const double _lidR = 6.8;
const double _lidThick = 0.4;
const double _lidDropY = 12.5;
const double _lidRestY = _jarH + _lidThick / 2;
const double _lidSeconds = 0.8;

/// HTML `spawnAdultMosquito()`: from (-20, 10, 0) to the container in 1.5 s
/// (Quadratic.Out), the toast, after 1 s off to (20, 12, 0) in 1.5 s
/// (Quadratic.In); the summary 2.5 s after it arrived. Raised above the lid
/// on the rim; added: in the pause it dips onto the lid.
const _V _flyFrom = _V(-20, 11.5, 0);
const _V _flyHover = _V(0, 10.4, 0);
const _V _flyAway = _V(20, 13, 0);
const double _flyIn = 1.5;
const double _flyPause = 1;
const double _flyOut = 1.5;
const double _dipDepth = 1.1;

/// HTML `setTimeout(() => window.triggerConclusion(), 1500)` after the last
/// label.
const int _sequenceMs = 1500;

/// HTML wrong drop: the box is red for 500 ms.
const int _flashMs = 500;

// ------------------------------------------------------------- 3D math

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

/// A camera: where it is and what it looks at.
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;

  static _View lerp(_View a, _View b, double t) =>
      _View(_V.lerp(a.eye, b.eye, t), _V.lerp(a.target, b.target, t));
}

/// Where the scene is drawn: the camera's look-at point lands on [center]
/// and the projection is scaled by [zoom] (1 = the HTML camera on the
/// design stage). The lab fits the scene beside the cards with it.
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

  @override
  bool operator ==(Object other) =>
      other is _Framing && other.center == center && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(center, zoom);
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_View view, _Framing framing) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(view.eye, framing, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.framing, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final _Framing framing;

  /// Forward (`camera.getWorldDirection`), right and up.
  final _V f;
  final _V r;
  final _V u;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) =>
      focal / math.max(0.1, (w - eye).dot(f)) * framing.zoom;

  /// [w] on the stage (design coordinates).
  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f)) * framing.zoom;
    return Offset(
      framing.center.dx + d.dot(r) * k,
      framing.center.dy - d.dot(u) * k,
    );
  }
}

/// A number eased from [from] to [to] over [seconds] from [start] (scene
/// time; a TWEEN.js tween on a scalar).
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

  bool doneAt(double t) => seconds <= 0 || t >= start + seconds;
}

/// What can be dragged onto the container: the magnifying glass (Scenario
/// 1), the can of kerosene oil and the lid (Scenario 2 shelf).
enum _Tool { magnifier, oil, lid }

/// The stage labels of the timeline (HTML `#s1-labels-pool`) and the box
/// each belongs on (HTML `data-expected`).
enum _Life {
  larva('II', 'stage_larva'),
  pupa('III', 'stage_pupa'),
  adult('IV', 'stage_adult');

  const _Life(this.box, this.key);

  /// Roman numeral of the box.
  final String box;

  /// String table key of the label.
  final String key;
}

/// The HTML pool listed the labels in the answer's order (Larva, Pupa,
/// Adult Mosquito); they are shown mixed so the learner decides.
const List<_Life> _poolOrder = [_Life.adult, _Life.larva, _Life.pupa];

/// Points each framing keeps in view (world): Scenario 1's start view the
/// bench, the container and the egg label; the magnified view the container
/// and the adults above it; Scenario 2 the container, the lid and the can
/// coming down, and the adult with its label.
const List<_V> _benchFocus = [
  _V(-_benchHalfW, 0, -_benchHalfD),
  _V(_benchHalfW, 0, -_benchHalfD),
  _V(-_benchHalfW, -_benchH, _benchHalfD),
  _V(_benchHalfW, -_benchH, _benchHalfD),
  _V(0, 11.4, 0),
];
const List<_V> _nearFocus = [
  _V(-_jarBottomR, 0, 0),
  _V(_jarBottomR, 0, 0),
  _V(0, 0, _jarBottomR),
  _V(-_jarTopR, _jarH, 0),
  _V(_jarTopR, _jarH, 0),
  _V(0, _jarH, -_jarTopR),
  _V(-5.6, 12, 0),
  _V(5.6, 12.2, 0),
];
const List<_V> _coverFocus = [
  _V(-_lidR, 0, 0),
  _V(_lidR, 0, 0),
  _V(0, 0, _lidR),
  _V(-_lidR, _jarH, 0),
  _V(_lidR, _jarH, 0),
  _V(0, _jarH, -_lidR),
  _V(0, 13.4, 0),
  _V(7.2, 13.2, 1.5),
];

/// The jar outline used for drops: both rims at eight angles.
const List<_V> _jarOutline = [
  _V(_jarBottomR, 0, 0),
  _V(-_jarBottomR, 0, 0),
  _V(0, 0, _jarBottomR),
  _V(0, 0, -_jarBottomR),
  _V(_jarTopR, _jarH, 0),
  _V(-_jarTopR, _jarH, 0),
  _V(0, _jarH, _jarTopR),
  _V(0, _jarH, -_jarTopR),
];

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1 … 4); [done] once the scenario's last step is.
  int step = 1;
  bool done = false;

  /// Something moves on its own (the camera glides, oil pours, the lid
  /// falls, the mosquito flies); the scene takes no drops meanwhile.
  bool busy = false;

  // ------------------------------------------------------------- camera
  /// 0 = the HTML start view, 1 = the magnified view.
  _Ramp zoom = const _Ramp.still(0);

  _Framing farTarget = _Framing.base;
  _Framing nearTarget = _Framing.base;
  _Framing farNow = _Framing.base;
  _Framing nearNow = _Framing.base;
  _Framing _farFrom = _Framing.base;
  _Framing _nearFrom = _Framing.base;
  double _framingT = 1;

  /// The camera of this frame; [viewVersion] changes whenever it does.
  _Cam cam = _Cam(_farView, _Framing.base);
  int viewVersion = 0;
  double _camK = 0;
  _Framing _camFraming = _Framing.base;

  // --------------------------------------------------------- scenario 1
  /// The magnifying glass was dropped on the container.
  bool magnified = false;

  /// Time-lapse slider (HTML `#s1-slider`, 0 … 100).
  double lapse = 0;

  /// Boxes filled with their right label.
  final Set<_Life> placed = {};

  /// Box flashing red after a wrong label (HTML 500 ms).
  _Life? flashBox;

  // --------------------------------------------------------- scenario 2
  bool oilOnShelf = true;
  bool lidOnShelf = true;

  /// When the can started pouring (scene time), and whether the film is
  /// complete.
  double? pourStart;
  bool film = false;

  /// When the animals met the film (struggle, then sink).
  double? sinkStart;

  /// 'Reset Water' was tapped: fresh water, no film.
  bool waterReset = false;

  /// Lid height (its centre) and whether it was dropped on the container.
  _Ramp lid = const _Ramp.still(_lidDropY);
  bool lidPlaced = false;

  /// When the adult mosquito was sent in.
  double? flightStart;

  // ----------------------------------------------------------- dragging
  /// The tool being dragged, and whether it is over the container.
  _Tool? dragging;
  bool hoverJar = false;

  /// Stage x range the labels stay in (left of the tool column).
  double labelMinX = 0;
  double labelMaxX = _design.width;

  /// HTML `changeScenario(scId)`.
  void load(int index) {
    scenario = index;
    step = 1;
    done = false;
    busy = false;
    zoom = const _Ramp.still(0);
    magnified = false;
    lapse = 0;
    placed.clear();
    flashBox = null;
    oilOnShelf = true;
    lidOnShelf = true;
    pourStart = null;
    film = false;
    sinkStart = null;
    waterReset = false;
    lid = const _Ramp.still(_lidDropY);
    lidPlaced = false;
    flightStart = null;
    dragging = null;
    hoverJar = false;
  }

  // ------------------------------------------------------------ framing

  void advance(double dt) {
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      final e = Curves.easeInOutCubic.transform(_framingT);
      farNow = _farFrom.lerpTo(farTarget, e);
      nearNow = _nearFrom.lerpTo(nearTarget, e);
    }
    final k = zoom.at(time);
    final framing = farNow.lerpTo(nearNow, k);
    if (k != _camK || framing != _camFraming) {
      _camK = k;
      _camFraming = framing;
      cam = _Cam(_View.lerp(_farView, _nearView, k), framing);
      viewVersion++;
    }
  }

  void setFraming(_Framing far, _Framing near, {required bool snap}) {
    if (snap) {
      farNow = _farFrom = farTarget = far;
      nearNow = _nearFrom = nearTarget = near;
      _framingT = 1;
      return;
    }
    if (far.closeTo(farTarget) && near.closeTo(nearTarget)) return;
    _farFrom = farNow;
    _nearFrom = nearNow;
    farTarget = far;
    nearTarget = near;
    _framingT = 0;
  }

  /// The scene has stopped sliding and the camera has stopped gliding.
  bool get framingSettled => _framingT >= 1 && zoom.doneAt(time);

  /// Stage box of [near]'s focus points with the unfitted camera.
  Rect focusBounds({required bool near}) {
    final cam = _Cam(near ? _nearView : _farView, _Framing.base);
    final points = scenario == 1
        ? _coverFocus
        : (near ? _nearFocus : _benchFocus);
    Rect? box;
    for (final w in points) {
      final o = cam.p(w);
      final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
      box = box == null ? r : box.expandToInclude(r);
    }
    return box!;
  }

  /// The container on the stage (both rims), for drops.
  Rect get jarRect {
    Rect? box;
    for (final w in _jarOutline) {
      final o = cam.p(w);
      final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
      box = box == null ? r : box.expandToInclude(r);
    }
    return box!;
  }

  /// Design points the QA flows touch: 'jar' (the front of the water),
  /// 'surface' (the middle of the water surface) and 'away' (beside the
  /// container, on the bench).
  Offset anchor(String id) {
    switch (id) {
      case 'jar':
        return cam.p(const _V(0, 4.5, 3));
      case 'surface':
        return cam.p(const _V(0, _surfaceY, 0));
      case 'away':
        final jar = jarRect;
        final gap = jar.width * 0.25 + 50;
        final left = jar.left - gap;
        final x = left > 30 ? left : jar.right + gap;
        return Offset(x.clamp(10.0, _design.width - 10), jar.center.dy);
      default:
        return _designCenter;
    }
  }

  // ----------------------------------------------------------- time-lapse

  /// 0 … 1 while [margin] goes from -[_fade] to +[_fade].
  static double _vis(double margin) =>
      ((margin + _fade) / (2 * _fade)).clamp(0.0, 1.0);

  double get _first => lapse / _lapseHalf;
  double get _last => (lapse - _lapseHalf) / (_lapseMax - _lapseHalf);

  /// The egg raft floats in the start view of Scenario 1.
  bool get eggsShown => scenario == 0 && !magnified;

  /// How much of larva [i] shows (0 … 1).
  double larvaAlpha(int i) {
    if (scenario == 1) return 1;
    if (!magnified) return 0;
    return _vis((i + 1) / _larvaCount - _first);
  }

  /// How much of pupa [i] shows (0 … 1).
  double pupaAlpha(int i) {
    if (scenario == 1) return 1;
    if (!magnified) return 0;
    if (lapse <= _lapseHalf) {
      return _vis(_first - (i - 2) / _pupaCount - _fade);
    }
    return _vis(_emergeAt + _emergeStep * i - _last);
  }

  /// How far adult [i] has climbed out of its pupa (0 … 1; Scenario 1).
  double adultRise(int i) {
    if (scenario != 0 || !magnified || lapse <= _lapseHalf) return 0;
    return ((_last - _emergeAt - _emergeStep * i) / _riseSpan).clamp(0.0, 1.0);
  }

  int get larvaeShown => [
    for (var i = 0; i < _larvaCount; i++) larvaAlpha(i) > 0.5,
  ].where((v) => v).length;

  int get pupaeShown => [
    for (var i = 0; i < _pupaCount; i++) pupaAlpha(i) > 0.5,
  ].where((v) => v).length;

  int get adultsOut => [
    for (var i = 0; i < _pupaCount; i++) adultRise(i) > 0,
  ].where((v) => v).length;

  // ------------------------------------------------------------ oil film

  /// 0 … 1 struggling under the film (a single surge).
  double get struggle {
    final s0 = sinkStart;
    if (s0 == null) return 0;
    final t = (time - s0) / _struggleSeconds;
    return t <= 0 || t >= 1 ? 0 : math.sin(math.pi * t);
  }

  /// 0 … 1 sinking (HTML Quadratic.In).
  double get sink {
    final s0 = sinkStart;
    if (s0 == null) return 0;
    final t = (time - s0 - _struggleSeconds) / _sinkSeconds;
    return Curves.easeInQuad.transform(t.clamp(0.0, 1.0));
  }

  /// The animals lie on the bottom.
  bool get sunk => sink >= 1;

  /// How far the film has spread (0 … 1).
  double get filmSpread {
    if (scenario != 1) return 0;
    if (film) return 1;
    final p0 = pourStart;
    if (p0 == null) return 0;
    final t = (time - p0 - _pourIn) / _pourFlow;
    return Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
  }

  /// The can while it pours: where its centre is, how far it is tipped and
  /// how much of it shows; null when it is not in the scene.
  ({_V at, double tilt, double alpha})? get can {
    final p0 = pourStart;
    if (p0 == null || film) return null;
    final t = time - p0;
    if (t < _pourIn) {
      final e = Curves.easeOutCubic.transform(t / _pourIn);
      return (
        at: _V.lerp(_canStart, _canPour, e),
        tilt: _canTilt * e,
        alpha: 1,
      );
    }
    if (t < _pourIn + _pourFlow) {
      return (at: _canPour, tilt: _canTilt, alpha: 1);
    }
    final e = ((t - _pourIn - _pourFlow) / _pourOut).clamp(0.0, 1.0);
    return (
      at: _V.lerp(_canPour, _canStart, e),
      tilt: _canTilt * (1 - e),
      alpha: 1 - e,
    );
  }

  /// Oil runs from the can (0 … 1 of the pour; null when it does not).
  double? get stream {
    final p0 = pourStart;
    if (p0 == null || film) return null;
    final t = (time - p0 - _pourIn) / _pourFlow;
    return t < 0 || t > 1 ? null : t;
  }

  // ------------------------------------------------------------- animals

  /// Top of larva [i]'s breathing tube, at the surface until it sinks.
  _V larvaAt(int i) {
    final x = (i - 2.5) * _larvaSpacing;
    final z = i.isEven ? _rowZ : -_rowZ;
    if (scenario != 1) return _V(x, _larvaY, z);
    final s = sink;
    return _V(x, _larvaY + (_larvaBottomY - _larvaY) * s, z);
  }

  /// Larva [i]'s turn about its tube (rad, counter-clockwise): the wriggle,
  /// stronger in the struggle, gone once it has sunk and tipped over.
  double larvaAngle(int i) {
    final s = scenario == 1 ? sink : 0.0;
    final amp = _wriggleAmp * (1 + 0.8 * struggle) * (1 - s) * (1 - s);
    final tilt = (i.isEven ? 1 : -1) * _sunkTilt * s;
    return tilt + amp * math.sin(time * _wriggleRate + i);
  }

  /// Top of pupa [i] (its breathing trumpets), at the surface until it
  /// sinks.
  _V pupaAt(int i) {
    final x = (i - 1.5) * _pupaSpacing;
    final z = i.isEven ? -_rowZ : _rowZ;
    if (scenario != 1) return _V(x, _pupaY, z);
    return _V(x, _pupaY + (_pupaBottomY - _pupaY) * sink, z);
  }

  double pupaAngle(int i) {
    final s = scenario == 1 ? sink : 0.0;
    final rock = _rockAmp * (1 + 2 * struggle) * (1 - s);
    return rock * math.sin(time * _rockRate + i * 1.7) +
        (i.isEven ? 0.5 : -0.4) * s;
  }

  /// Where adult [i] of Scenario 1 is: from its pupa at the surface up to
  /// its hovering place.
  _V adultAt(int i) {
    final rise = Curves.easeOutCubic.transform(adultRise(i));
    final from = _V((i - 1.5) * _pupaSpacing, _surfaceY + 0.3, pupaAt(i).z);
    final bob = _bobAmp * math.sin(time * 3 + i) * rise;
    return _V.lerp(from, _adultHover[i], rise) + _V(0, bob, 0);
  }

  /// The Scenario 2 adult mosquito, or null when it is not on screen.
  _V? get flyer {
    final f0 = flightStart;
    if (f0 == null) return null;
    final t = time - f0;
    final bob = _V(0, _bobAmp * math.sin(time * _bobRate), 0);
    if (t < _flyIn) {
      final e = Curves.easeOutQuad.transform(t / _flyIn);
      return _V.lerp(_flyFrom, _flyHover, e) + bob;
    }
    if (t < _flyIn + _flyPause) {
      final d = math.sin(math.pi * (t - _flyIn) / _flyPause);
      return _flyHover - _V(0, _dipDepth * d, 0) + bob;
    }
    final u = (t - _flyIn - _flyPause) / _flyOut;
    if (u >= 1) return null;
    return _V.lerp(_flyHover, _flyAway, Curves.easeInQuad.transform(u)) + bob;
  }

  /// Wing beat (0.35 … 1 of the wing's width across).
  double get flap => 0.35 + 0.65 * math.sin(time * _flapRate).abs();

  /// Centre height of the lid (while it falls and once it rests).
  double get lidY => lid.at(time);
}

/// Best framing for [bounds] (unfitted projection) inside [free], clear of
/// the [hard] obstacles (all in design coordinates), at most [maxZoom].
_Framing _fitFraming(Rect bounds, Rect free, List<Rect> hard, double maxZoom) {
  if (free.width <= 1 || free.height <= 1 || bounds.isEmpty) {
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
  Rect? best;
  var bestZoom = 0.0;
  for (final r in rects) {
    final z = math.min(
      maxZoom,
      math.min(r.width / bounds.width, r.height / bounds.height),
    );
    if (best == null ||
        z > bestZoom + 1e-6 ||
        ((z - bestZoom).abs() <= 1e-6 &&
            r.width * r.height > best.width * best.height)) {
      best = r;
      bestZoom = z;
    }
  }
  if (best == null || bestZoom <= 0) return _Framing.base;
  return _Framing(
    best.center - (bounds.center - _designCenter) * bestZoom,
    bestZoom,
  );
}

class _MosquitoLabState extends State<Ch10A5LifeCycleOfInsectsMosquitoPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The time-lapse slider's value: only the slider rebuilds as it moves.
  final ValueNotifier<double> _lapse = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (framing), the design box (drops) and the canvas
  /// cards (framing obstacles).
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch10-a5-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch10-a5-design');
  final GlobalKey _phaseKey = GlobalKey(debugLabel: 'ch10-a5-phase');
  final GlobalKey _magKey = GlobalKey(debugLabel: 'ch10-a5-magnifier');
  final GlobalKey _shelfKey = GlobalKey(debugLabel: 'ch10-a5-shelf');
  final GlobalKey _bottomKey = GlobalKey(debugLabel: 'ch10-a5-bottom');

  /// Touch reach and label size for the current stage scale (design px),
  /// and the UI scale of the last build.
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _uiScale = 1;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  Map<String, Object> _toastArgs = const {};
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]`; `hud[5]` once the scenario is
  /// done.
  String get _hudKey =>
      's${_scene.scenario + 1}_hud_${_scene.done ? _stepCount + 1 : _scene.step}';

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
    _lapse.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame advances the clock and the framing, and repaints the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (t - s.time).clamp(0.0, _maxFrameStep);
    s.time = t;
    s.advance(dt);
    _frame.value = t;
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

  /// Fits the scene into the part of the canvas no card covers: the tool
  /// column, the HUD (sidebar open), the floating mission card (sidebar
  /// collapsed), the phase chip, the magnifying glass / shelf and the
  /// bottom panel.
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
    if (!open && _lab.isLabActive) {
      final bottom = screen.height < _compactBelow
          ? _missionTop + pad.top + screen.height * _compactCardMax
          : size.height;
      hard.add(Rect.fromLTRB(0, 0, insets.left, bottom));
    }
    for (final key in [_phaseKey, _magKey, _shelfKey, _bottomKey]) {
      final r = measured(key);
      if (r != null) hard.add(r);
    }
    final s = _scene;
    s.labelMinX = math.max(0.0, (4 - stage.dx) / fit);
    s.labelMaxX = math.min(
      _design.width,
      (size.width - insets.right - stage.dx) / fit,
    );
    final area = toDesign(free).intersect(_stageRect);
    final obstacles = [for (final r in hard) toDesign(r.inflate(_cardGap))];
    s.setFraming(
      _fitFraming(s.focusBounds(near: false), area, obstacles, _maxZoomFar),
      _fitFraming(s.focusBounds(near: true), area, obstacles, _maxZoomNear),
      snap: _snapFraming,
    );
    _snapFraming = false;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(scId)`: cancels every timer and animation and
  /// rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _lapse.value = 0;
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Runs [then] after [ms] if the page is still open.
  void _after(int ms, VoidCallback then) {
    _lab.after(Duration(milliseconds: ms), () {
      if (mounted) then();
    });
  }

  /// [key] from the string table in [lang], with [args] filled in (a stage
  /// label is translated too).
  String _format(LabLang lang, String key, Map<String, Object> args) =>
      labFormat(labTr(_i18n, lang, key), {
        for (final e in args.entries)
          e.key: switch (e.value) {
            final _Life life => labTr(_i18n, lang, life.key),
            final Object v => v,
          },
      });

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone
  /// (the HTML's toasts were silent; its own tones play beside them).
  void _toast(
    String key, {
    bool error = false,
    bool sound = false,
    Map<String, Object> args = const {},
  }) {
    _toastKey = key;
    _toastArgs = args;
    _lab.showToast(_format(_lab.lang, key, args), isError: error, sound: sound);
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null) return;
    if (shown.text != _format(previous, key, _toastArgs)) return;
    final translated = _format(_lab.lang, key, _toastArgs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  /// The summary popup (HTML `triggerConclusion()`: "Success!", the summary
  /// and the next-step note).
  void _conclude(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('sum_head_${scenario + 1}'),
      body: () => _t('sum_${scenario + 1}'),
      extra: () => _summaryNote(scenario),
    );
  }

  Widget _summaryNote(int scenario) {
    final p = _lab.palette;
    final s = _uiScale;
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
            _t('next_${scenario + 1}'),
            style: TextStyle(
              color: p.accentInk,
              fontSize: 12 * s,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          if (scenario == _scenarioCount - 1) ...[
            SizedBox(height: 6 * s),
            Text(
              _t('all_done'),
              style: TextStyle(
                color: p.text,
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------ dragging

  /// Which tools can be picked up now (HTML `draggable`, with the steps'
  /// order). The lid can be tried early: the drop explains the order.
  bool _toolEnabled(_Tool tool) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done) return false;
    return switch (tool) {
      _Tool.magnifier => s.scenario == 0 && s.step == 1 && !s.magnified,
      _Tool.oil => s.scenario == 1 && s.oilOnShelf && s.step == 1,
      _Tool.lid =>
        s.scenario == 1 && s.lidOnShelf && (s.step == 1 || s.step == 3),
    };
  }

  void _onToolDragStart(_Tool tool) {
    _scene
      ..dragging = tool
      ..hoverJar = false;
  }

  void _onToolDragEnd() {
    _scene
      ..dragging = null
      ..hoverJar = false;
  }

  bool _overJar(Offset? design) =>
      design != null && _scene.jarRect.inflate(_touch).contains(design);

  void _onToolHover(Offset global) {
    _scene.hoverJar = _overJar(labGlobalToLocal(_designKey, global));
  }

  /// HTML `handleDropOnCanvas(e)`. The HTML took any drop on the canvas;
  /// the tool now has to be over the container.
  void _onToolDrop(_Tool tool, Offset global) {
    final over = _overJar(labGlobalToLocal(_designKey, global));
    _scene.hoverJar = false;
    switch (tool) {
      case _Tool.magnifier:
        if (over) {
          _magnify();
        } else {
          _toast('e_mag', error: true, sound: true);
        }
      case _Tool.oil:
        if (over) {
          _pour();
        } else {
          _toast('e_oil_drop', error: true, sound: true);
        }
      case _Tool.lid:
        _dropLid(over);
    }
  }

  /// A tool let go off the scene (on a card, the sidebar or the margin).
  void _onToolMissed(_Tool tool) {
    switch (tool) {
      case _Tool.magnifier:
        _toast('e_mag', error: true, sound: true);
      case _Tool.oil:
        _toast('e_oil_drop', error: true, sound: true);
      case _Tool.lid:
        _dropLid(false);
    }
  }

  // ------------------------------------------------- scenario 1 actions

  /// HTML drop of 'mag' (step 1): click, toast, the camera glides in, the
  /// egg raft gives way to the larvae and the first pupae; step 2.
  void _magnify() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..magnified = true
        ..zoom = _Ramp(0, 1, s.time, _zoomSeconds, Curves.easeOutCubic)
        ..step = 2;
    });
    _toast('t_zoom');
    _scheduleFraming();
  }

  bool get _lapseEnabled {
    final s = _scene;
    return _lab.isLabActive &&
        s.scenario == 0 &&
        s.magnified &&
        !s.done &&
        (s.step == 2 || s.step == 3);
  }

  /// HTML `handleTimeLapse(v)`: the animals follow the slider; past the
  /// middle step 2 ends.
  void _onLapse(double v) {
    final s = _scene;
    if (!_lapseEnabled) return;
    s.lapse = v;
    _lapse.value = v;
    if (s.step == 2 && v > _lapseHalf) setState(() => s.step = 3);
  }

  /// Letting go: past 90 % step 3 ends and the timeline replaces the
  /// slider (the HTML swapped them while the slider was still being
  /// dragged); short of the mark, a hint (added).
  void _onLapseEnd(double v) {
    final s = _scene;
    if (!_lapseEnabled) return;
    if (s.step == 2) {
      _toast('t_more_half');
    } else if (v > _lapseEnd) {
      setState(() => s.step = 4);
      // Replaces a hint that may still show from an earlier release.
      _toast('t_lapse_done');
      _scheduleFraming();
    } else {
      _toast('t_more_end');
    }
  }

  /// HTML `dropLabel(e, expected)`: the right label fills its box (green);
  /// a wrong one flashes the box red (with a hint, added). All three placed:
  /// toast and the summary 1.5 s later.
  void _onLabelDrop(_Life label, _Life box) {
    final s = _scene;
    if (s.done || s.placed.contains(box)) return;
    if (label != box) {
      _Sound.pop.play();
      setState(() => s.flashBox = box);
      _toast('e_wrong_label', error: true, args: {'n': box.box});
      _after(_flashMs, () {
        if (s.flashBox == box) setState(() => s.flashBox = null);
      });
      return;
    }
    _Sound.correct.play();
    setState(() {
      s
        ..placed.add(box)
        ..flashBox = null;
    });
    if (s.placed.length < _Life.values.length) {
      _toast('t_correct_label', args: {'n': box.box, 'name': box});
      return;
    }
    setState(() => s.done = true);
    _toast('t_sequence');
    _after(_sequenceMs, () => _conclude(0));
  }

  void _onLabelMissed() {
    if (_scene.done) return;
    _toast('e_label_drop', error: true, sound: true);
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML drop of 'kerosene' (step 1), with the tilt the step promised: the
  /// can tips and pours, the film spreads (step 2), the larvae and pupae
  /// struggle and sink; then the 'Reset Water' button (step 3). The HTML
  /// skipped step 2 and named the result as the oil landed.
  void _pour() {
    final s = _scene;
    _Sound.water.play();
    setState(() {
      s
        ..oilOnShelf = false
        ..busy = true
        ..pourStart = s.time;
    });
    _scheduleFraming();
    final pourMs = ((_pourIn + _pourFlow + _pourOut) * 1000).round();
    _after(pourMs, () {
      setState(() {
        s
          ..film = true
          ..step = 2
          ..sinkStart = s.time;
      });
      _toast('t_poured');
      final sinkMs = ((_struggleSeconds + _sinkSeconds) * 1000).round();
      _after(sinkMs, () {
        setState(() {
          s
            ..busy = false
            ..step = 3;
        });
        _toast('t_sunk');
      });
    });
  }

  /// HTML `resetS2()`: the film goes and the larvae and pupae are back at
  /// the surface; the lid is next.
  void _resetWater() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || s.waterReset || s.busy) return;
    setState(() {
      s
        ..waterReset = true
        ..film = false
        ..pourStart = null
        ..sinkStart = null;
    });
    _toast('t_reset');
  }

  /// HTML drop of 'lid' (step 3): pop, the lid drops onto the container
  /// (Bounce.Out), toast; step 4. The HTML ignored the lid in step 1 and
  /// took it before 'Reset'; both now get a hint.
  void _dropLid(bool over) {
    final s = _scene;
    if (s.step == 1) {
      _toast('e_lid_early', error: true, sound: true);
      return;
    }
    if (!s.waterReset) {
      _toast('e_lid_reset', error: true, sound: true);
      return;
    }
    if (!over) {
      _toast('e_lid_drop', error: true, sound: true);
      return;
    }
    _Sound.pop.play();
    setState(() {
      s
        ..lidOnShelf = false
        ..lidPlaced = true
        ..busy = true
        ..lid = _Ramp(
          _lidDropY,
          _lidRestY,
          s.time,
          _lidSeconds,
          Curves.bounceOut,
        );
    });
    _toast('t_covered');
    _scheduleFraming();
    _after((_lidSeconds * 1000).round(), () {
      setState(() {
        s
          ..busy = false
          ..step = 4;
      });
    });
  }

  /// HTML `spawnAdultMosquito()`: the mosquito flies in, cannot get in
  /// (toast), flies away; the summary.
  void _sendAdult() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4 || s.busy || s.done) return;
    _Sound.pop.play();
    setState(() {
      s
        ..busy = true
        ..flightStart = s.time;
    });
    _after((_flyIn * 1000).round(), () => _toast('t_blocked'));
    _after(((_flyIn + _flyPause + _flyOut) * 1000).round(), () {
      setState(() {
        s
          ..busy = false
          ..done = true
          ..flightStart = null;
      });
      _conclude(1);
    });
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-reset-s2`, `#btn-adult-spawn` and the "Observe Summary &
  /// Conclusion" button that re-opens the summary.
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.scenario == 1 && s.step == 3 && !s.waterReset && !s.busy && !s.done)
        LabAction(
          label: _t('btn_reset_water'),
          icon: Icons.restart_alt,
          color: _Colors.slate600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _resetWater,
        ),
      if (s.scenario == 1 &&
          s.step == 4 &&
          !s.busy &&
          !s.done &&
          s.flightStart == null)
        LabAction(
          label: _t('btn_adult'),
          icon: Icons.bug_report,
          color: _Colors.cyan600,
          foreground: _Colors.white,
          highlight: true,
          // The mosquito's own pop plays.
          silent: true,
          onTap: _sendAdult,
        ),
      if (s.done)
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.blue600,
          foreground: _Colors.white,
          // The summary plays the HTML `success`.
          silent: true,
          onTap: () => _conclude(s.scenario),
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
        final data = _scenarioData;
        final sc = _scene;
        final actions = _actions();
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.bug_report,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.done ? data.steps.length + 1 : sc.step,
          actions: actions,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, s * _lab.fontScale),
          overlays: _overlays(context, p, s, actions),
          stage: _stage(),
        );
      },
    );
  }

  /// The canvas cards: the phase chip (HTML `#stage-overlay`, top left),
  /// the magnifying glass (HTML `#ui-s1-mag-container`) or the shelf (HTML
  /// `#ui-s2-shelf`) at the top right, and at the bottom, above the HUD,
  /// the action button (HTML `#ui-s2-controls`, `#compare-btn-container`)
  /// and the time-lapse slider or the timeline.
  List<Widget> _overlays(
    BuildContext context,
    LabPalette p,
    double s,
    List<LabAction> actions,
  ) {
    final sc = _scene;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final open = _lab.isSidebarOpen;
    final active = _lab.isLabActive;
    final showAction = active && open && actions.isNotEmpty;
    final panel = active && sc.scenario == 0 && sc.magnified;
    // On phones the collapsed mission card ends above the bottom panel, so
    // the panel may use the canvas's whole width.
    final bottomLeft = !open && screen.height < _compactBelow
        ? 8 + pad.left
        : inset.left;
    return [
      // Measures the canvas area for the framing.
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      if (active)
        Positioned(
          key: const ValueKey('ch10a5-phase'),
          top: inset.top,
          left: inset.left,
          child: _PhaseChip(
            key: _phaseKey,
            palette: p,
            scale: s,
            label: _t('phase'),
            phase: _t(_phaseText),
          ),
        ),
      if (active && sc.scenario == 0 && !sc.magnified)
        Positioned(
          key: const ValueKey('ch10a5-magnifier'),
          top: _cardTop + pad.top,
          right: inset.right,
          child: _magnifierCard(p, s),
        ),
      if (active && sc.scenario == 1 && (sc.oilOnShelf || sc.lidOnShelf))
        Positioned(
          key: const ValueKey('ch10a5-shelf'),
          top: _cardTop + pad.top,
          right: inset.right,
          child: _shelfCard(p, s),
        ),
      if (showAction || panel)
        Positioned(
          key: const ValueKey('ch10a5-bottom'),
          left: bottomLeft,
          right: inset.right,
          bottom: open ? inset.bottom + _hudBand * s : inset.bottom,
          child: Center(
            child: LayoutBuilder(
              builder: (context, box) {
                final width = math.min(box.maxWidth, _panelMaxWidth * s);
                return Column(
                  key: _bottomKey,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showAction)
                      Padding(
                        padding: EdgeInsets.only(bottom: panel ? 6 * s : 0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LabActionButton(
                            action: actions.first,
                            scale: s,
                            expand: false,
                          ),
                        ),
                      ),
                    if (panel)
                      sc.step >= 4 || sc.done
                          ? _timelineCard(p, s, width)
                          : _lapseCard(p, s, width),
                  ],
                );
              },
            ),
          ),
        ),
    ];
  }

  /// HTML `stage-text`: the phase of the current scenario.
  String get _phaseText {
    final s = _scene;
    if (s.scenario == 0) return s.magnified ? 'phase_s1b' : 'phase_s1a';
    return s.oilOnShelf ? 'phase_s2a' : 'phase_s2b';
  }

  /// A tool the learner drags onto the container. [glyph] draws it (also
  /// as the drag feedback, which is built outside the shell's style scope).
  Widget _toolDraggable(
    _Tool tool,
    Widget Function({bool ghost, bool lifted}) glyph,
    String semantics,
  ) {
    return Draggable<_Tool>(
      data: tool,
      maxSimultaneousDrags: _toolEnabled(tool) ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _onToolDragStart(tool),
      onDragEnd: (_) => _onToolDragEnd(),
      onDraggableCanceled: (_, _) => _onToolMissed(tool),
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: glyph(lifted: true),
        ),
      ),
      childWhenDragging: glyph(ghost: true),
      child: Semantics(
        label: semantics,
        child: KeyedSubtree(
          key: ValueKey('ch10a5-tool-${tool.name}'),
          child: glyph(),
        ),
      ),
    );
  }

  /// HTML `#ui-s1-mag-container`: "Drag Me" over the magnifying glass; the
  /// whole card is the handle.
  Widget _magnifierCard(LabPalette p, double s) {
    final lens = math.max(52.0, 64 * s);
    return LabGlassCard(
      key: _magKey,
      palette: p,
      radius: 16,
      padding: EdgeInsets.all(6 * s),
      borderColor: _Colors.cyan500.withValues(alpha: 0.45),
      child: _toolDraggable(
        _Tool.magnifier,
        ({bool ghost = false, bool lifted = false}) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!lifted)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 3 * s,
                ),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.cardBorder),
                ),
                child: Text(
                  _t('drag_me'),
                  maxLines: 1,
                  style: TextStyle(
                    color: p.ink(_Colors.cyan600),
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (!lifted) SizedBox(height: 5 * s),
            _ToolGlyph(
              tool: _Tool.magnifier,
              width: lens,
              height: lens,
              ghost: ghost,
              lifted: lifted,
            ),
          ],
        ),
        _t('magnifier'),
      ),
    );
  }

  /// HTML `#ui-s2-shelf`: the can of kerosene oil and the lid.
  Widget _shelfCard(LabPalette p, double s) {
    final sc = _scene;
    final title = _t('shelf');
    final canW = math.max(48.0, 52 * s);
    final canH = math.max(56.0, 64 * s);
    final lidW = math.max(56.0, 72 * s);
    final lidH = math.max(48.0, 48 * s);
    return LabGlassCard(
      key: _shelfKey,
      palette: p,
      radius: 16,
      padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 6 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(title, 1.2),
            ),
          ),
          SizedBox(height: 4 * s),
          if (sc.oilOnShelf)
            _toolDraggable(
              _Tool.oil,
              ({bool ghost = false, bool lifted = false}) => _ToolGlyph(
                tool: _Tool.oil,
                width: canW,
                height: canH,
                text: _t('oil'),
                textSize: 10 * s,
                ghost: ghost,
                lifted: lifted,
              ),
              _t('oil_can'),
            ),
          if (sc.oilOnShelf && sc.lidOnShelf) SizedBox(height: 6 * s),
          if (sc.lidOnShelf)
            _toolDraggable(
              _Tool.lid,
              ({bool ghost = false, bool lifted = false}) => _ToolGlyph(
                tool: _Tool.lid,
                width: lidW,
                height: lidH,
                text: _t('lid'),
                textSize: 10 * s,
                ghost: ghost,
                lifted: lifted,
              ),
              _t('lid_long'),
            ),
        ],
      ),
    );
  }

  /// HTML `#ui-s1-timelapse`: "Day 1 · Time-Lapse (7 Days) · Day 7+" and the
  /// slider.
  Widget _lapseCard(LabPalette p, double s, double width) {
    final caption = TextStyle(
      color: p.ink(_Colors.cyan600),
      fontSize: 10.5 * s,
      fontWeight: FontWeight.w900,
    );
    final enabled = _lapseEnabled;
    return SizedBox(
      width: width,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        padding: EdgeInsets.fromLTRB(12 * s, 7 * s, 12 * s, 0),
        borderColor: _Colors.cyan500.withValues(alpha: 0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(_t('day_first'), maxLines: 1, style: caption),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 13 * s,
                        color: p.ink(_Colors.cyan600),
                      ),
                      SizedBox(width: 4 * s),
                      Flexible(
                        child: Text(
                          _t('time_lapse'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: caption,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(_t('day_last'), maxLines: 1, style: caption),
              ],
            ),
            Semantics(
              label: _t('time_lapse'),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6 * s,
                  activeTrackColor: _Colors.cyan500,
                  inactiveTrackColor: p.isDark
                      ? _Colors.slate700
                      : _Colors.slate300,
                  thumbColor: _Colors.cyan500,
                  overlayColor: _Colors.cyan500.withValues(alpha: 0.2),
                  disabledActiveTrackColor: _Colors.cyan500.withValues(
                    alpha: 0.5,
                  ),
                  disabledInactiveTrackColor: p.isDark
                      ? _Colors.slate700
                      : _Colors.slate300,
                  disabledThumbColor: _Colors.cyan700,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 10 * s,
                    disabledThumbRadius: 9 * s,
                  ),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 18 * s),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: _lapse,
                  builder: (context, v, _) => Slider(
                    key: const ValueKey('ch10a5-lapse-slider'),
                    value: v,
                    max: _lapseMax,
                    onChanged: enabled ? _onLapse : null,
                    onChangeEnd: _onLapseEnd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `#ui-s1-timeline`: the label pool, then the boxes I (egg) to IV
  /// with arrows between them.
  Widget _timelineCard(LabPalette p, double s, double width) {
    final sc = _scene;
    final pool = [
      for (final l in _poolOrder)
        if (!sc.placed.contains(l)) l,
    ];
    const arrows = 3;
    final arrow = 14 * s;
    final inner = width - 20 * s;
    final box = ((inner - arrows * arrow) / 4).clamp(48.0, 76 * s).toDouble();
    return SizedBox(
      width: width,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        padding: EdgeInsets.fromLTRB(10 * s, 6 * s, 10 * s, 8 * s),
        borderColor: _Colors.cyan500.withValues(alpha: 0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pool.isNotEmpty) ...[
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8 * s,
                children: [for (final l in pool) _labelDraggable(l, p, s)],
              ),
              SizedBox(height: 4 * s),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _eggBox(p, s, box),
                for (final life in _Life.values) ...[
                  SizedBox(
                    width: arrow,
                    child: Icon(
                      Icons.chevron_right,
                      size: arrow + 4 * s,
                      color: p.ink(_Colors.cyan500),
                    ),
                  ),
                  _dropBox(life, p, s, box),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// One label of the pool (HTML `.draggable-label`), at least 48 dp tall.
  Widget _labelDraggable(_Life life, LabPalette p, double s) {
    final text = _t(life.key);
    Widget chip({bool ghost = false, bool lifted = false}) => _LabelChip(
      text: text,
      palette: p,
      scale: s,
      ghost: ghost,
      lifted: lifted,
    );
    return Draggable<_Life>(
      data: life,
      maxSimultaneousDrags: _scene.done ? 0 : 1,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDraggableCanceled: (_, _) => _onLabelMissed(),
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: chip(lifted: true),
        ),
      ),
      childWhenDragging: chip(ghost: true),
      child: KeyedSubtree(
        key: ValueKey('ch10a5-label-${life.name}'),
        child: chip(),
      ),
    );
  }

  /// Box I: the egg, given (HTML: dashed cyan, "I / Egg").
  Widget _eggBox(LabPalette p, double s, double size) {
    return _StageBox(
      size: size,
      scale: s,
      border: _Colors.cyan300,
      fill: p.isDark ? _Colors.cyan900 : _Colors.cyan100,
      ink: p.isDark ? _Colors.cyan300 : _Colors.cyan600,
      dashed: true,
      roman: 'I',
      text: _t('stage_egg'),
    );
  }

  /// Boxes II … IV (HTML `.drop-zone`): grey and dashed while empty, cyan
  /// while a label hovers, red for 0.5 s after a wrong label, green with the
  /// label once filled.
  Widget _dropBox(_Life life, LabPalette p, double s, double size) {
    final sc = _scene;
    final filled = sc.placed.contains(life);
    return DragTarget<_Life>(
      onWillAcceptWithDetails: (_) => !filled && !sc.done,
      onAcceptWithDetails: (d) => _onLabelDrop(d.data, life),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        final wrong = sc.flashBox == life;
        final Color border;
        final Color fill;
        final Color ink;
        if (filled) {
          border = _Colors.green500;
          fill = p.isDark ? _Colors.green900 : _Colors.green100;
          ink = p.isDark ? _Colors.green500 : _Colors.green600;
        } else if (wrong) {
          border = _Colors.red500;
          fill = p.isDark ? _Colors.red900 : _Colors.red100;
          ink = p.isDark ? _Colors.red500 : _Colors.red600;
        } else if (hover) {
          border = _Colors.cyan500;
          fill = p.isDark ? _Colors.cyan900 : _Colors.cyan100;
          ink = p.isDark ? _Colors.cyan300 : _Colors.cyan600;
        } else {
          border = _Colors.slate400;
          fill = p.isDark ? _Colors.slate800 : _Colors.slate200;
          ink = _Colors.slate500;
        }
        return _StageBox(
          key: ValueKey('ch10a5-box-${life.box}'),
          size: size,
          scale: s,
          border: border,
          fill: fill,
          ink: ink,
          dashed: !filled,
          roman: life.box,
          text: filled ? _t(life.key) : null,
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
        return LabStage(
          designSize: _design,
          child: DragTarget<_Tool>(
            onWillAcceptWithDetails: (d) => _toolEnabled(d.data),
            onMove: (d) => _onToolHover(d.offset),
            onLeave: (_) => _scene.hoverJar = false,
            onAcceptWithDetails: (d) => _onToolDrop(d.data, d.offset),
            builder: (context, _, _) => Semantics(
              image: true,
              label: _t('scene'),
              child: RepaintBoundary(
                child: CustomPaint(
                  key: _designKey,
                  size: _design,
                  painter: _ScenePainter(
                    scene: _scene,
                    cache: _cache,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    labelSize: _labelSize,
                    eggLabel: _t('lbl_eggs'),
                    adultLabel: _t('lbl_adult'),
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

/// HTML `#stage-overlay`: "Current Phase" and the phase.
class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    super.key,
    required this.palette,
    required this.scale,
    required this.label,
    required this.phase,
  });

  final LabPalette palette;
  final double scale;
  final String label;
  final String phase;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 190 * s),
      child: LabGlassCard(
        palette: p,
        radius: 14,
        padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 4 * s),
        borderColor: _Colors.cyan500.withValues(alpha: 0.4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waves, size: 16 * s, color: p.ink(_Colors.cyan500)),
            SizedBox(width: 6 * s),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 8 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(label, 0.8),
                    ),
                  ),
                  Text(
                    phase,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w900,
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

/// The magnifying glass, the can of kerosene oil (HTML orange can with a
/// drop and "OIL") or the lid (HTML grey lid with "LID"), as a [width] ×
/// [height] touch target. [ghost]: left behind while dragged (HTML opacity
/// 0.5); [lifted]: the drag feedback.
class _ToolGlyph extends StatelessWidget {
  const _ToolGlyph({
    required this.tool,
    required this.width,
    required this.height,
    this.text,
    this.textSize = 10,
    this.ghost = false,
    this.lifted = false,
  });

  final _Tool tool;
  final double width;
  final double height;
  final String? text;
  final double textSize;
  final bool ghost;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final label = text;
    final ink = tool == _Tool.oil ? _Colors.white : _Colors.slate800;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ToolPainter(tool: tool, ghost: ghost, lifted: lifted),
        child: label == null
            ? null
            : Align(
                alignment: tool == _Tool.oil
                    ? const Alignment(0, 0.62)
                    : const Alignment(0, 0.38),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: ink.withValues(alpha: ghost ? 0.5 : 1),
                      fontSize: textSize,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// A stage label (HTML `.draggable-label`: white chip, slate border, bold
/// text), centred in a 48 dp tall touch target.
class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.text,
    required this.palette,
    required this.scale,
    this.ghost = false,
    this.lifted = false,
  });

  final String text;
  final LabPalette palette;
  final double scale;
  final bool ghost;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final a = ghost ? 0.4 : 1.0;
    final fill = p.isDark ? _Colors.slate800 : _Colors.white;
    final ink = p.isDark ? _Colors.white : _Colors.slate800;
    final border = lifted ? _Colors.cyan500 : _Colors.slate300;
    return SizedBox(
      height: 48,
      // widthFactor 1: as wide as the chip, so the pool wraps in a row.
      child: Center(
        widthFactor: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            color: fill.withValues(alpha: a),
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(color: border.withValues(alpha: a), width: 2),
            boxShadow: lifted
                ? const [
                    BoxShadow(
                      color: LabInk.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              color: ink.withValues(alpha: a),
              fontSize: 13 * s,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// A box of the timeline: its Roman numeral and, once known, the stage.
class _StageBox extends StatelessWidget {
  const _StageBox({
    super.key,
    required this.size,
    required this.scale,
    required this.border,
    required this.fill,
    required this.ink,
    required this.dashed,
    required this.roman,
    this.text,
  });

  final double size;
  final double scale;
  final Color border;
  final Color fill;
  final Color ink;
  final bool dashed;
  final String roman;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final label = text;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BoxPainter(border: border, fill: fill, dashed: dashed),
        child: Padding(
          padding: EdgeInsets.all(5 * s),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  roman,
                  maxLines: 1,
                  style: TextStyle(
                    color: ink,
                    fontSize: (label == null ? 18 : 12) * s,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              if (label != null)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ink,
                        fontSize: 9.5 * s,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
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

/// Segments of a projected rim (HTML `CylinderGeometry(…, 32)`).
const int _ringSegments = 40;

/// Unit circle, once.
final List<double> _ringCos = [
  for (var j = 0; j < _ringSegments; j++)
    math.cos(2 * math.pi * j / _ringSegments),
];
final List<double> _ringSin = [
  for (var j = 0; j < _ringSegments; j++)
    math.sin(2 * math.pi * j / _ringSegments),
];

/// Projects the horizontal circle of [radius] at height [y] round [c].
List<Offset> _ring(_Cam cam, double y, double radius, [_V c = _V.zero]) => [
  for (var j = 0; j < _ringSegments; j++)
    cam.p(_V(c.x + radius * _ringCos[j], y, c.z + radius * _ringSin[j])),
];

/// Convex hull of [points] (monotone chain), counter-clockwise.
List<Offset> _hull(List<Offset> points) {
  final pts = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  if (pts.length < 3) return pts;
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
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

/// Replaces [path] with the closed polygon through [points].
void _polygon(Path path, List<Offset> points) {
  path.reset();
  if (points.isEmpty) return;
  path.moveTo(points.first.dx, points.first.dy);
  for (var i = 1; i < points.length; i++) {
    path.lineTo(points[i].dx, points[i].dy);
  }
  path.close();
}

/// Shapes drawn in an animal's own frame (world units, +y down), made once.
class _Shapes {
  _Shapes() {
    // Larva: breathing tube at the top (the surface), the abdomen widening
    // to the thorax, the head at the bottom with its mouth brushes.
    larvaBody
      ..moveTo(-0.07, 0.45)
      ..lineTo(-0.1, 0.85)
      ..lineTo(-0.13, 1.3)
      ..lineTo(-0.16, 1.75)
      ..lineTo(-0.17, 1.98)
      ..lineTo(0.17, 1.98)
      ..lineTo(0.16, 1.75)
      ..lineTo(0.13, 1.3)
      ..lineTo(0.1, 0.85)
      ..lineTo(0.07, 0.45)
      ..close();
    larvaThorax.addOval(
      Rect.fromCenter(center: const Offset(0, 2.22), width: 0.66, height: 0.6),
    );
    larvaHead.addOval(
      Rect.fromCenter(center: const Offset(0, 2.68), width: 0.46, height: 0.44),
    );
    larvaLines
      ..moveTo(0, -0.05)
      ..lineTo(0.02, 0.5);
    for (final y in const [0.75, 1.05, 1.35, 1.65]) {
      final w = 0.09 + (y - 0.45) * 0.055;
      larvaHairs
        ..moveTo(-w, y)
        ..lineTo(w, y)
        ..moveTo(-w, y)
        ..lineTo(-w - 0.2, y - 0.06)
        ..moveTo(w, y)
        ..lineTo(w + 0.2, y - 0.06);
    }
    larvaHairs
      ..moveTo(-0.12, 2.86)
      ..lineTo(-0.24, 3.02)
      ..moveTo(0.12, 2.86)
      ..lineTo(0.24, 3.02);

    // Pupa ("tumbler"): the big comma head with its two breathing trumpets
    // at the surface and the curled tail ending in paddles.
    pupaHead.addOval(
      Rect.fromCenter(center: const Offset(0, 0.62), width: 1.25, height: 1.1),
    );
    pupaEye.addOval(
      Rect.fromCenter(center: const Offset(0.3, 0.6), width: 0.2, height: 0.2),
    );
    pupaTrumpets
      ..moveTo(-0.22, 0.14)
      ..lineTo(-0.32, -0.06)
      ..moveTo(0.18, 0.12)
      ..lineTo(0.27, -0.06);
    pupaTail
      ..moveTo(-0.22, 1.02)
      ..quadraticBezierTo(-0.62, 1.78, 0.22, 1.88);
    pupaPaddle.addOval(
      Rect.fromCenter(
        center: const Offset(0.36, 1.86),
        width: 0.34,
        height: 0.18,
      ),
    );

    // The empty pupal skin floating after the adult has left: an open
    // shell split along its back.
    pupalCase.addOval(
      Rect.fromCenter(center: Offset.zero, width: 1.15, height: 0.5),
    );
    pupalSplit
      ..moveTo(-0.35, -0.05)
      ..quadraticBezierTo(0, -0.22, 0.35, -0.05);

    // Adult mosquito, seen from the side and facing +x: abdomen, thorax,
    // head, proboscis, palps, antennae and six long legs; the wings are
    // drawn apart so they can beat.
    mosquitoAbdomen.addOval(const Rect.fromLTRB(-2, -0.13, -0.25, 0.31));
    mosquitoThorax.addOval(
      Rect.fromCenter(center: const Offset(0, 0.02), width: 0.9, height: 0.72),
    );
    mosquitoHead.addOval(
      Rect.fromCenter(
        center: const Offset(0.58, 0.14),
        width: 0.44,
        height: 0.42,
      ),
    );
    for (final x in const [-0.62, -0.92, -1.22, -1.52]) {
      mosquitoBands
        ..moveTo(x, -0.08)
        ..lineTo(x, 0.27);
    }
    mosquitoFace
      ..moveTo(0.78, 0.22)
      ..lineTo(1.7, 0.55)
      ..moveTo(0.76, 0.2)
      ..lineTo(1.22, 0.33)
      ..moveTo(0.7, 0.02)
      ..lineTo(1.2, -0.42)
      ..moveTo(0.66, 0.02)
      ..lineTo(1.02, -0.5);
    const near = [
      [Offset(0.2, 0.3), Offset(0.75, 0.75), Offset(1.25, 1.55)],
      [Offset(0, 0.33), Offset(0.15, 0.95), Offset(0.05, 1.75)],
      [Offset(-0.22, 0.3), Offset(-0.85, 0.85), Offset(-1.55, 1.7)],
    ];
    const far = [
      [Offset(0.15, 0.3), Offset(0.55, 0.85), Offset(0.85, 1.6)],
      [Offset(-0.05, 0.32), Offset(-0.3, 0.95), Offset(-0.55, 1.7)],
      [Offset(-0.25, 0.28), Offset(-1.15, 0.7), Offset(-2, 1.35)],
    ];
    for (final (legs, path) in [(near, mosquitoLegs), (far, mosquitoFarLegs)]) {
      for (final leg in legs) {
        path
          ..moveTo(leg[0].dx, leg[0].dy)
          ..lineTo(leg[1].dx, leg[1].dy)
          ..lineTo(leg[2].dx, leg[2].dy);
      }
    }
    mosquitoWing.addOval(const Rect.fromLTRB(-2.05, -0.21, 0.05, 0.21));

    // Can of kerosene oil (2 × 2.8, upright): body, cap, spout to the top
    // left (tip at [canSpoutTip]) and a drop on the front.
    canBody.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-1, -1.4, 1, 1.4),
        const Radius.circular(0.22),
      ),
    );
    canCap.addRect(const Rect.fromLTRB(0.25, -1.75, 0.75, -1.4));
    canSpout
      ..moveTo(-0.55, -1.4)
      ..lineTo(canSpoutTip.dx, canSpoutTip.dy);
    canDrop
      ..moveTo(0, -0.62)
      ..quadraticBezierTo(0.42, -0.05, 0.36, 0.22)
      ..arcToPoint(
        const Offset(-0.36, 0.22),
        radius: const Radius.circular(0.37),
      )
      ..quadraticBezierTo(-0.42, -0.05, 0, -0.62)
      ..close();
  }

  static const Offset canSpoutTip = Offset(-1.25, -2.05);

  final Path larvaBody = Path();
  final Path larvaThorax = Path();
  final Path larvaHead = Path();
  final Path larvaLines = Path();
  final Path larvaHairs = Path();
  final Path pupaHead = Path();
  final Path pupaEye = Path();
  final Path pupaTrumpets = Path();
  final Path pupaTail = Path();
  final Path pupaPaddle = Path();
  final Path pupalCase = Path();
  final Path pupalSplit = Path();
  final Path mosquitoAbdomen = Path();
  final Path mosquitoThorax = Path();
  final Path mosquitoHead = Path();
  final Path mosquitoBands = Path();
  final Path mosquitoFace = Path();
  final Path mosquitoLegs = Path();
  final Path mosquitoFarLegs = Path();
  final Path mosquitoWing = Path();
  final Path canBody = Path();
  final Path canCap = Path();
  final Path canSpout = Path();
  final Path canDrop = Path();

  /// Orange can, light at the left (HTML `from-orange-400 to-orange-600`),
  /// in the can's own frame.
  final Shader canShade = const LinearGradient(
    colors: [_Colors.orange400, _Colors.orange600],
  ).createShader(const Rect.fromLTRB(-1, -1.4, 1, 1.4));
}

/// Paints, paths and text painters reused by every frame. Owned by the page
/// state and disposed with it.
class _PaintCache {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Paint shaded = Paint();
  final Paint water = Paint();
  final _Shapes shapes = _Shapes();

  // ------------------------------------------- view-dependent geometry
  final Path benchTop = Path();
  final Path benchFront = Path();
  final Path jarShadow = Path();
  final Path jarHull = Path();
  final Path waterHull = Path();
  final Path surface = Path();
  final Path rimTop = Path();
  final Path rimBottom = Path();
  final Path filmFull = Path();
  Offset filmCenter = Offset.zero;
  int _geometryVersion = -1;

  // ----------------------------------------------- lid (moves as it falls)
  final Path lidBand = Path();
  final Path lidTop = Path();
  final Path knobBand = Path();
  final Path knobTop = Path();
  int _lidVersion = -1;
  double _lidAt = double.nan;

  /// Reusable path for the oil stream.
  final Path stream = Path();

  // --------------------------------------------------------------- labels
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool _dark = true;

  /// Drops the label painters when the language, size or theme changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _dark) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _dark = dark;
  }

  double get labelSize => _labelSize;

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _dark ? _Colors.white : _Colors.slate900,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Re-projects the bench, the container and the water when the camera or
  /// the framing changed.
  void updateGeometry(_Scene s) {
    if (s.viewVersion == _geometryVersion) return;
    _geometryVersion = s.viewVersion;
    final cam = s.cam;
    _polygon(benchTop, [
      cam.p(const _V(-_benchHalfW, 0, -_benchHalfD)),
      cam.p(const _V(_benchHalfW, 0, -_benchHalfD)),
      cam.p(const _V(_benchHalfW, 0, _benchHalfD)),
      cam.p(const _V(-_benchHalfW, 0, _benchHalfD)),
    ]);
    _polygon(benchFront, [
      cam.p(const _V(-_benchHalfW, 0, _benchHalfD)),
      cam.p(const _V(_benchHalfW, 0, _benchHalfD)),
      cam.p(const _V(_benchHalfW, -_benchH, _benchHalfD)),
      cam.p(const _V(-_benchHalfW, -_benchH, _benchHalfD)),
    ]);
    _polygon(jarShadow, _ring(cam, 0, _jarBottomR + 0.9));
    final bottom = _ring(cam, 0, _jarBottomR);
    final top = _ring(cam, _jarH, _jarTopR);
    _polygon(jarHull, _hull([...bottom, ...top]));
    _polygon(rimTop, top);
    _polygon(rimBottom, bottom);
    final waterTop = _ring(cam, _surfaceY, _waterTopR);
    _polygon(waterHull, _hull([..._ring(cam, 0, _waterBottomR), ...waterTop]));
    _polygon(surface, waterTop);
    _polygon(filmFull, _ring(cam, _filmY, _filmR));
    filmCenter = cam.p(const _V(0, _filmY, 0));
    final surfaceAt = cam.p(const _V(0, _surfaceY, _waterTopR));
    final bottomAt = cam.p(const _V(0, 0, _waterBottomR));
    water.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _Colors.water.withValues(alpha: 0.5),
        _Colors.water.withValues(alpha: 0.72),
      ],
    ).createShader(Rect.fromPoints(surfaceAt, bottomAt));
  }

  /// Re-projects the lid at height [y] (its centre).
  void updateLid(_Scene s, double y) {
    if (s.viewVersion == _lidVersion && y == _lidAt) return;
    _lidVersion = s.viewVersion;
    _lidAt = y;
    final cam = s.cam;
    const h = _lidThick / 2;
    final top = _ring(cam, y + h, _lidR);
    _polygon(lidBand, _hull([..._ring(cam, y - h, _lidR), ...top]));
    _polygon(lidTop, top);
    final knobTopRing = _ring(cam, y + h + 0.45, 0.8);
    _polygon(knobBand, _hull([..._ring(cam, y + h, 0.9), ...knobTopRing]));
    _polygon(knobTop, knobTopRing);
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() => _disposeLabels();
}

/// Draws the bench, the container of stagnant water and its animals, the
/// oil, the lid, the can, the adult mosquitoes and the text sprites.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.eggLabel,
    required this.adultLabel,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;
  final String eggLabel;
  final String adultLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final c = cache;
    c.prepare(lang, labelSize, isDark);
    c.updateGeometry(s);
    canvas.drawRect(
      labBleed(size),
      c.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    _bench(canvas);
    _jarBack(canvas);
    _animals(canvas, back: true);
    _animals(canvas, back: false);
    _surface(canvas);
    _film(canvas);
    if (s.eggsShown) _eggs(canvas);
    _pupalCases(canvas);
    _jarFront(canvas);
    if (s.lidPlaced) _lid(canvas);
    _can(canvas);
    _adults(canvas);
    _dropHint(canvas);
    if (showLabels) _labels(canvas);
  }

  // ----------------------------------------------------------- bench + jar

  void _bench(Canvas canvas) {
    final c = cache;
    canvas.drawPath(
      c.benchTop,
      c.fill..color = labShade(_Colors.bench, isDark ? 0.06 : 0.1),
    );
    canvas.drawPath(
      c.benchFront,
      c.fill..color = labShade(_Colors.bench, -0.3),
    );
    canvas.drawPath(
      c.benchTop,
      c.stroke
        ..color = labShade(_Colors.bench, 0.25)
        ..strokeWidth = 1.2,
    );
    canvas.drawPath(c.jarShadow, c.shadow);
  }

  void _jarBack(Canvas canvas) {
    final c = cache;
    // Back wall of the glass (HTML opacity 0.35 for both walls together).
    canvas.drawPath(
      c.jarHull,
      c.fill..color = _Colors.glass.withValues(alpha: isDark ? 0.1 : 0.22),
    );
    canvas.drawPath(
      c.rimTop,
      c.stroke
        ..color = _Colors.glass.withValues(alpha: 0.35)
        ..strokeWidth = 1.4 * scene.cam.framing.zoom,
    );
    canvas.drawPath(c.waterHull, c.water);
  }

  void _surface(Canvas canvas) {
    final c = cache;
    canvas.drawPath(
      c.surface,
      c.fill..color = _Colors.cyan300.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      c.surface,
      c.stroke
        ..color = _Colors.cyan300.withValues(alpha: 0.55)
        ..strokeWidth = 1.3 * scene.cam.framing.zoom,
    );
  }

  void _jarFront(Canvas canvas) {
    final c = cache;
    final z = scene.cam.framing.zoom;
    canvas.drawPath(
      c.jarHull,
      c.fill..color = _Colors.glass.withValues(alpha: isDark ? 0.07 : 0.12),
    );
    canvas.drawPath(
      c.jarHull,
      c.stroke
        ..color = _Colors.glass.withValues(alpha: 0.55)
        ..strokeWidth = 1.6 * z,
    );
    canvas.drawPath(
      c.rimTop,
      c.stroke
        ..color = _Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.8 * z,
    );
    canvas.drawPath(
      c.rimBottom,
      c.stroke
        ..color = _Colors.glass.withValues(alpha: 0.3)
        ..strokeWidth = 1.2 * z,
    );
    // A vertical highlight on the glass, left of the middle.
    final cam = scene.cam;
    final a = cam.p(const _V(-4.2, 7.4, 4.9));
    final b = cam.p(const _V(-3.9, 0.8, 4.5));
    canvas.drawLine(
      a,
      b,
      c.stroke
        ..color = _Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 5 * z,
    );
  }

  // --------------------------------------------------------------- animals

  /// Larvae and pupae of one row: the back row ([back]) first, so the front
  /// row hides it.
  void _animals(Canvas canvas, {required bool back}) {
    final s = scene;
    for (var i = 0; i < _larvaCount; i++) {
      final at = s.larvaAt(i);
      if ((at.z < 0) != back) continue;
      final a = s.larvaAlpha(i);
      if (a <= 0) continue;
      _larva(canvas, at, s.larvaAngle(i), a);
    }
    for (var i = 0; i < _pupaCount; i++) {
      final at = s.pupaAt(i);
      if ((at.z < 0) != back) continue;
      final a = s.pupaAlpha(i);
      if (a <= 0) continue;
      _pupa(canvas, at, s.pupaAngle(i), a);
    }
  }

  /// Turns the canvas into an animal's own frame at [at] (world units, +y
  /// down), turned [angle] (rad, counter-clockwise in the world).
  void _frame(Canvas canvas, _V at, double angle) {
    final cam = scene.cam;
    final p = cam.p(at);
    final k = cam.scaleAt(at);
    canvas
      ..translate(p.dx, p.dy)
      ..scale(k)
      ..rotate(-angle);
  }

  void _larva(Canvas canvas, _V at, double angle, double alpha) {
    final c = cache;
    final sh = c.shapes;
    canvas.save();
    _frame(canvas, at, angle);
    final edge = c.stroke
      ..color = _Colors.animalEdge.withValues(alpha: 0.75 * alpha)
      ..strokeWidth = 0.05;
    canvas
      ..drawPath(
        sh.larvaLines,
        c.stroke
          ..color = _Colors.animalBody.withValues(alpha: alpha)
          ..strokeWidth = 0.09,
      )
      ..drawPath(
        sh.larvaBody,
        c.fill..color = _Colors.animalBody.withValues(alpha: alpha),
      )
      ..drawPath(sh.larvaBody, edge)
      ..drawPath(
        sh.larvaThorax,
        c.fill..color = _Colors.animal.withValues(alpha: alpha),
      )
      ..drawPath(sh.larvaThorax, edge)
      ..drawPath(
        sh.larvaHead,
        c.fill..color = _Colors.animalHead.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.larvaHairs,
        c.stroke
          ..color = _Colors.animalEdge.withValues(alpha: 0.6 * alpha)
          ..strokeWidth = 0.035,
      );
    canvas.restore();
  }

  void _pupa(Canvas canvas, _V at, double angle, double alpha) {
    final c = cache;
    final sh = c.shapes;
    canvas.save();
    _frame(canvas, at, angle);
    canvas
      ..drawPath(
        sh.pupaTrumpets,
        c.stroke
          ..color = _Colors.animalBody.withValues(alpha: alpha)
          ..strokeWidth = 0.09,
      )
      ..drawPath(
        sh.pupaTail,
        c.stroke
          ..color = _Colors.animalEdge.withValues(alpha: 0.7 * alpha)
          ..strokeWidth = 0.36,
      )
      ..drawPath(
        sh.pupaTail,
        c.stroke
          ..color = _Colors.animalBody.withValues(alpha: alpha)
          ..strokeWidth = 0.26,
      )
      ..drawPath(
        sh.pupaPaddle,
        c.fill..color = _Colors.animalBody.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.pupaHead,
        c.fill..color = _Colors.animal.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.pupaHead,
        c.stroke
          ..color = _Colors.animalEdge.withValues(alpha: 0.75 * alpha)
          ..strokeWidth = 0.05,
      )
      ..drawPath(
        sh.pupaEye,
        c.fill..color = _Colors.animalHead.withValues(alpha: alpha),
      );
    canvas.restore();
  }

  /// The floating egg raft (HTML 15 dark eggs standing on the surface).
  void _eggs(Canvas canvas) {
    final c = cache;
    final cam = scene.cam;
    c.fill.color = _Colors.animal;
    c.stroke
      ..color = _Colors.animalEdge.withValues(alpha: 0.7)
      ..strokeWidth = 0.6;
    for (var e = 0; e < _eggCount; e++) {
      final at = _V(
        (e % 4) * _eggGrid - _eggOffset,
        _surfaceY + 0.15,
        (e ~/ 4) * _eggGrid - _eggOffset,
      );
      final p = cam.p(at);
      final k = cam.scaleAt(at);
      final r = Rect.fromCenter(center: p, width: 0.16 * k, height: 0.42 * k);
      canvas
        ..drawOval(r, c.fill)
        ..drawOval(r, c.stroke);
    }
  }

  /// Scenario 1: the empty pupal skins left at the surface.
  void _pupalCases(Canvas canvas) {
    final s = scene;
    if (s.scenario != 0 || s.lapse <= _lapseHalf) return;
    final c = cache;
    final sh = c.shapes;
    for (var i = 0; i < _pupaCount; i++) {
      final a = (1 - s.pupaAlpha(i)) * 0.85;
      if (a <= 0) continue;
      canvas.save();
      _frame(canvas, _V(s.pupaAt(i).x, _surfaceY + 0.05, s.pupaAt(i).z), 0);
      canvas
        ..drawPath(
          sh.pupalCase,
          c.fill..color = _Colors.pupalCase.withValues(alpha: a),
        )
        ..drawPath(
          sh.pupalSplit,
          c.stroke
            ..color = _Colors.animalBody.withValues(alpha: a)
            ..strokeWidth = 0.06,
        );
      canvas.restore();
    }
  }

  // -------------------------------------------------------- scenario 2

  /// The oil film: spreading from where the oil lands, purple with an oily
  /// sheen.
  void _film(Canvas canvas) {
    final s = scene;
    final spread = s.filmSpread;
    if (spread <= 0) return;
    final c = cache;
    final land = s.cam.p(const _V(3.6, _filmY, 1.5));
    final center = Offset.lerp(land, c.filmCenter, spread)!;
    final z = s.cam.framing.zoom;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(spread)
      ..translate(-c.filmCenter.dx, -c.filmCenter.dy)
      ..drawPath(c.filmFull, c.fill..color = _Colors.oil.withValues(alpha: 0.6))
      ..drawPath(
        c.filmFull,
        c.stroke
          ..color = _Colors.oilSheenPink.withValues(alpha: 0.7)
          ..strokeWidth = 1.6 * z,
      );
    // Sheen: two inner rings.
    for (final (k, color) in [
      (0.72, _Colors.oilSheenTeal),
      (0.42, _Colors.oilSheenPink),
    ]) {
      canvas
        ..save()
        ..translate(c.filmCenter.dx, c.filmCenter.dy)
        ..scale(k)
        ..translate(-c.filmCenter.dx, -c.filmCenter.dy)
        ..drawPath(
          c.filmFull,
          c.stroke
            ..color = color.withValues(alpha: 0.45)
            ..strokeWidth = 2.2 * z / k,
        )
        ..restore();
    }
    canvas.restore();
  }

  /// The lid on the rim (HTML grey cylinder) with a knob.
  void _lid(Canvas canvas) {
    final s = scene;
    final c = cache;
    c.updateLid(s, s.lidY);
    final z = s.cam.framing.zoom;
    canvas
      ..drawPath(c.lidBand, c.fill..color = labShade(_Colors.lid, -0.3))
      ..drawPath(c.lidTop, c.fill..color = labShade(_Colors.lid, 0.12))
      ..drawPath(
        c.lidTop,
        c.stroke
          ..color = labShade(_Colors.lid, -0.45)
          ..strokeWidth = 1.2 * z,
      )
      ..drawPath(c.knobBand, c.fill..color = labShade(_Colors.lid, -0.4))
      ..drawPath(c.knobTop, c.fill..color = labShade(_Colors.lid, 0.25));
  }

  /// The can of kerosene oil tipping over the container, and the oil
  /// running from its spout down to the water.
  void _can(Canvas canvas) {
    final s = scene;
    final pose = s.can;
    if (pose == null) return;
    final c = cache;
    final sh = c.shapes;
    final cam = s.cam;
    final p = cam.p(pose.at);
    final k = cam.scaleAt(pose.at);
    final run = s.stream;
    if (run != null) {
      final tipLocal = _rotate(_Shapes.canSpoutTip, -pose.tilt);
      final tip = p + tipLocal * k;
      final land = cam.p(_V(pose.at.x + tipLocal.dx, _filmY, pose.at.z));
      final path = c.stream..reset();
      path.moveTo(tip.dx, tip.dy);
      const parts = 8;
      for (var i = 1; i <= parts; i++) {
        final t = i / parts;
        final wobble = math.sin(s.time * 18 + t * 9) * 0.05 * k * t;
        path.lineTo(
          tip.dx + (land.dx - tip.dx) * t + wobble,
          tip.dy + (land.dy - tip.dy) * t,
        );
      }
      canvas.drawPath(
        path,
        c.stroke
          ..color = _Colors.kerosene.withValues(alpha: 0.85)
          ..strokeWidth = 0.16 * k,
      );
    }
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..scale(k)
      ..rotate(-pose.tilt);
    final a = pose.alpha;
    final outline = c.stroke
      ..color = _Colors.slate800.withValues(alpha: a)
      ..strokeWidth = 0.1;
    canvas
      ..drawPath(
        sh.canSpout,
        c.stroke
          ..color = _Colors.slate800.withValues(alpha: a)
          ..strokeWidth = 0.34,
      )
      ..drawPath(
        sh.canSpout,
        c.stroke
          ..color = _Colors.slate400.withValues(alpha: a)
          ..strokeWidth = 0.2,
      )
      ..drawPath(
        sh.canCap,
        c.fill..color = _Colors.slate400.withValues(alpha: a),
      )
      ..drawPath(sh.canCap, outline)
      ..drawPath(
        sh.canBody,
        c.shaded
          ..shader = sh.canShade
          ..color = _Colors.white.withValues(alpha: a),
      )
      ..drawPath(sh.canBody, outline)
      ..drawPath(
        sh.canDrop,
        c.fill..color = _Colors.white.withValues(alpha: 0.9 * a),
      )
      ..restore();
  }

  static Offset _rotate(Offset v, double angle) {
    final cs = math.cos(angle), sn = math.sin(angle);
    return Offset(v.dx * cs - v.dy * sn, v.dx * sn + v.dy * cs);
  }

  // -------------------------------------------------------------- adults

  void _adults(Canvas canvas) {
    final s = scene;
    if (s.scenario == 0) {
      for (var i = 0; i < _pupaCount; i++) {
        final rise = s.adultRise(i);
        if (rise <= 0) continue;
        _mosquito(
          canvas,
          s.adultAt(i),
          _adultSmall,
          facingRight: i.isOdd,
          alpha: math.min(1, rise * 5),
        );
      }
      return;
    }
    final at = s.flyer;
    if (at != null) _mosquito(canvas, at, _adultBig, facingRight: true);
  }

  /// An adult mosquito at [at] (thorax), [size] times the HTML model.
  void _mosquito(
    Canvas canvas,
    _V at,
    double size, {
    required bool facingRight,
    double alpha = 1,
  }) {
    final s = scene;
    final c = cache;
    final sh = c.shapes;
    final p = s.cam.p(at);
    final k = s.cam.scaleAt(at) * size;
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..scale(facingRight ? k : -k, k);
    final legs = c.stroke
      ..color = _Colors.animal.withValues(alpha: 0.75 * alpha)
      ..strokeWidth = 0.045;
    canvas
      ..drawPath(sh.mosquitoFarLegs, legs)
      ..drawPath(
        sh.mosquitoAbdomen,
        c.fill..color = _Colors.animal.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.mosquitoBands,
        c.stroke
          ..color = _Colors.animalEdge.withValues(alpha: 0.8 * alpha)
          ..strokeWidth = 0.06,
      )
      ..drawPath(
        sh.mosquitoThorax,
        c.fill..color = _Colors.animalBody.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.mosquitoHead,
        c.fill..color = _Colors.animalHead.withValues(alpha: alpha),
      )
      ..drawPath(
        sh.mosquitoFace,
        c.stroke
          ..color = _Colors.animalHead.withValues(alpha: alpha)
          ..strokeWidth = 0.06,
      )
      ..drawPath(
        sh.mosquitoLegs,
        c.stroke
          ..color = _Colors.animalHead.withValues(alpha: alpha)
          ..strokeWidth = 0.05,
      );
    for (final tilt in const [0.28, 0.06]) {
      canvas
        ..save()
        ..translate(0, -0.26)
        ..rotate(tilt)
        ..scale(1, s.flap)
        ..drawPath(
          sh.mosquitoWing,
          c.fill..color = _Colors.white.withValues(alpha: 0.45 * alpha),
        )
        ..drawPath(
          sh.mosquitoWing,
          c.stroke
            ..color = _Colors.slate400.withValues(alpha: 0.8 * alpha)
            ..strokeWidth = 0.035,
        )
        ..restore();
    }
    canvas.restore();
  }

  // ----------------------------------------------------- drops and labels

  /// While a tool is dragged the container glows (brighter under it).
  void _dropHint(Canvas canvas) {
    final s = scene;
    if (s.dragging == null) return;
    final c = cache;
    final hover = s.hoverJar;
    canvas
      ..drawPath(
        c.jarHull,
        c.glow
          ..color = _Colors.cyan400.withValues(alpha: hover ? 0.8 : 0.35)
          ..strokeWidth = hover ? 12 : 8,
      )
      ..drawPath(
        c.jarHull,
        c.stroke
          ..color = _Colors.cyan300.withValues(alpha: hover ? 0.95 : 0.5)
          ..strokeWidth = hover ? 3 : 2,
      );
  }

  /// The HTML text sprites: the egg raft (Scenario 1 start view) and the
  /// adult mosquito (Scenario 2, now following it).
  void _labels(Canvas canvas) {
    final s = scene;
    if (s.eggsShown) _sprite(canvas, eggLabel, s.cam.p(_eggLabelAt));
    final flyer = s.flyer;
    if (s.scenario == 1 && flyer != null) {
      _sprite(canvas, adultLabel, s.cam.p(flyer + const _V(0, 2.4, 0)));
    }
  }

  void _sprite(Canvas canvas, String text, Offset at) {
    final c = cache;
    final tp = c.label(text);
    final padX = c.labelSize * 0.8;
    final padY = c.labelSize * 0.35;
    final w = tp.width + padX * 2;
    final h = tp.height + padY * 2;
    final x = at.dx
        .clamp(
          scene.labelMinX + w / 2 + 4,
          math.max(scene.labelMinX + w / 2 + 4, scene.labelMaxX - w / 2 - 4),
        )
        .toDouble();
    final rect = Rect.fromCenter(center: Offset(x, at.dy), width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(h * 0.32));
    canvas
      ..drawRRect(
        rr,
        c.fill..color = isDark ? _Colors.spriteDark : _Colors.spriteLight,
      )
      ..drawRRect(
        rr,
        c.stroke
          ..color = isDark ? _Colors.slate600 : _Colors.slate300
          ..strokeWidth = 1.5,
      );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.eggLabel != eggLabel ||
      old.adultLabel != adultLabel;
}

/// The tools on the cards: the magnifying glass (HTML white disc with a
/// dark lens ring and handle), the can of kerosene oil (orange, cap, drop)
/// and the lid (grey, rounded top, knob). Its text is laid over it by
/// [_ToolGlyph].
class _ToolPainter extends CustomPainter {
  _ToolPainter({required this.tool, required this.ghost, required this.lifted});

  final _Tool tool;
  final bool ghost;
  final bool lifted;

  @override
  void paint(Canvas canvas, Size size) {
    final a = ghost ? 0.45 : 1.0;
    final fill = Paint();
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (lifted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(2),
          Radius.circular(size.shortestSide * 0.3),
        ).shift(const Offset(0, 4)),
        Paint()
          ..color = LabInk.shadowSoft
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    switch (tool) {
      case _Tool.magnifier:
        final r = size.shortestSide / 2;
        final c = size.center(Offset.zero);
        canvas
          ..drawCircle(
            c,
            r - 2,
            fill..color = _Colors.white.withValues(alpha: 0.2 * a),
          )
          ..drawCircle(
            c,
            r - 2,
            line
              ..color = _Colors.slate300.withValues(alpha: a)
              ..strokeWidth = 4,
          );
        final lens = c - Offset(r * 0.14, r * 0.14);
        final lr = r * 0.4;
        final dir = const Offset(1, 1) / math.sqrt2;
        canvas
          ..drawLine(
            lens + dir * lr,
            lens + dir * (lr + r * 0.42),
            line
              ..color = _Colors.slate800.withValues(alpha: a)
              ..strokeWidth = r * 0.2,
          )
          ..drawCircle(
            lens,
            lr,
            fill..color = _Colors.cyan100.withValues(alpha: 0.5 * a),
          )
          ..drawCircle(
            lens,
            lr,
            line
              ..color = _Colors.slate800.withValues(alpha: a)
              ..strokeWidth = r * 0.16,
          );
      case _Tool.oil:
        final w = size.width * 0.78;
        final h = size.height * 0.8;
        final body = Rect.fromLTWH(
          (size.width - w) / 2,
          size.height - h - 1,
          w,
          h,
        );
        final cap = Rect.fromLTWH(
          body.center.dx - w * 0.17,
          body.top - h * 0.1,
          w * 0.34,
          h * 0.11,
        );
        canvas
          ..drawRect(cap, fill..color = _Colors.slate400.withValues(alpha: a))
          ..drawRect(
            cap,
            line
              ..color = _Colors.slate800.withValues(alpha: a)
              ..strokeWidth = 1.2,
          );
        final rr = RRect.fromRectAndRadius(body, Radius.circular(w * 0.14));
        canvas
          ..drawRRect(
            rr,
            fill
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _Colors.orange400.withValues(alpha: a),
                  _Colors.orange600.withValues(alpha: a),
                ],
              ).createShader(body),
          )
          ..drawRRect(
            rr,
            line
              ..color = _Colors.slate800.withValues(alpha: a)
              ..strokeWidth = 2,
          );
        fill.shader = null;
        final d = body.center - Offset(0, h * 0.12);
        final dr = w * 0.17;
        final drop = Path()
          ..moveTo(d.dx, d.dy - dr * 1.7)
          ..quadraticBezierTo(d.dx + dr * 1.1, d.dy - dr * 0.2, d.dx + dr, d.dy)
          ..arcToPoint(Offset(d.dx - dr, d.dy), radius: Radius.circular(dr))
          ..quadraticBezierTo(
            d.dx - dr * 1.1,
            d.dy - dr * 0.2,
            d.dx,
            d.dy - dr * 1.7,
          )
          ..close();
        canvas.drawPath(drop, fill..color = _Colors.white.withValues(alpha: a));
      case _Tool.lid:
        final w = size.width * 0.92;
        final h = size.height * 0.5;
        final body = Rect.fromLTWH(
          (size.width - w) / 2,
          size.height * 0.24,
          w,
          h,
        );
        final knob = Rect.fromLTWH(
          body.center.dx - w * 0.16,
          body.top - h * 0.24,
          w * 0.32,
          h * 0.26,
        );
        final top = Radius.circular(h * 0.5);
        canvas
          ..drawRRect(
            RRect.fromRectAndCorners(knob, topLeft: top / 2, topRight: top / 2),
            fill..color = _Colors.slate500.withValues(alpha: a),
          )
          ..drawRRect(
            RRect.fromRectAndCorners(body, topLeft: top, topRight: top),
            fill
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _Colors.slate300.withValues(alpha: a),
                  _Colors.slate400.withValues(alpha: a),
                ],
              ).createShader(body),
          )
          ..drawRRect(
            RRect.fromRectAndCorners(body, topLeft: top, topRight: top),
            line
              ..color = _Colors.slate500.withValues(alpha: a)
              ..strokeWidth = 2,
          );
    }
  }

  @override
  bool shouldRepaint(_ToolPainter old) =>
      old.tool != tool || old.ghost != ghost || old.lifted != lifted;
}

/// A timeline box: rounded, filled, with a dashed (empty) or solid border.
class _BoxPainter extends CustomPainter {
  _BoxPainter({required this.border, required this.fill, required this.dashed});

  final Color border;
  final Color fill;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(2),
      Radius.circular(size.shortestSide * 0.18),
    );
    canvas.drawRRect(rr, Paint()..color = fill);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = border;
    if (!dashed) {
      canvas.drawRRect(rr, line);
      return;
    }
    labDashedPath(canvas, Path()..addRRect(rr), line, dash: 7, gap: 5);
  }

  @override
  bool shouldRepaint(_BoxPainter old) =>
      old.border != border || old.fill != fill || old.dashed != dashed;
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
