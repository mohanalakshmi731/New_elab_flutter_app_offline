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

/// Class 6 Science • Chapter 10 • Activity 6
/// Life Cycle of Amphibians (Frog).
///
/// Native Flutter port of `Cl6S-Ch10-A6-Life_Cycle_of_Amphibians__Frog_.html`
/// (Three.js r128). The Three.js pond and habitat scenes are redrawn by a
/// small painter ([_Gfx]) through a perspective projection of the HTML
/// camera (position (0, 16, 35), looking at the origin, 45° field of view),
/// fitted into the part of the canvas the cards leave free ([_Framing]).
///
/// Scenario 1 (The Pond Timeline Puzzle): drag the five stage cards from the
/// tray into the timeline slots in the order of a frog's life; each stage
/// appears in the pond once it is placed. Then play the time-lapse or open
/// the summary.
///
/// Scenario 2 (Habitat Match-Up): drag the tadpole, the froglet and the
/// adult frog onto the habitat each one needs (deep water, shallow bank or
/// dry land), then open the summary.
class Ch10A6LifeCycleOfAmphibiansFrogPage extends StatefulWidget {
  const Ch10A6LifeCycleOfAmphibiansFrogPage({super.key});

  @override
  State<Ch10A6LifeCycleOfAmphibiansFrogPage> createState() => _FrogLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises four Web Audio tones: `click`
/// (buttons, picking up a card, Enter Lab, the sidebar, scenario change),
/// `pop` (a card dropped in the wrong place), `success` (a card dropped in
/// the right place, the summary) and `croak` (a sawtooth buzz for the adult
/// frog and the time-lapse). There is no croak in `assets/audio/`, so it
/// plays drop.mp3, the closest short low sound; the right-drop `success`
/// plays correct.mp3 so success.mp3 stays the summary's tone.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pop → `science/pop.mp3`, correct → `science/correct.mp3`,
/// success → `math/success.mp3`, croak → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `pop` (wrong drop).
  pop('audio/class6/science/pop.mp3'),

  /// HTML `success` after a right drop.
  correct('audio/class6/science/correct.mp3'),

  /// HTML `success` with the summary popup.
  success('audio/class6/math/success.mp3'),

  /// HTML `croak`.
  croak('audio/class6/science/drop.mp3');

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
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // the lab's accent
  static const Color green600 = Color(0xFF16A34A);
  static const Color emerald600 = Color(0xFF059669);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
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
  /// `#canvas-wrapper` background: `#1e293b` (dark), `#e2e8f0` (light).
  static const Color sceneDark = slate800;
  static const Color sceneLight = slate200;

  /// Lab bench `0x334155`, pond / deep water `0x0284c7`.
  static const Color bench = slate700;
  static const Color water = Color(0xFF0284C7);

  /// Spawn: jelly `0xe2e8f0`, embryo `0x0f172a`.
  static const Color jelly = slate200;
  static const Color embryo = slate900;

  /// Tadpole head `0x1e293b`, tail `0x334155`.
  static const Color tadpoleHead = slate800;
  static const Color tadpoleTail = slate700;

  /// Frog greens `0x15803d`, `0x16a34a`, `0x22c55e`, spots `0x14532d`,
  /// vocal sac `0x86efac`.
  static const Color frogDark = Color(0xFF15803D);
  static const Color frog = Color(0xFF16A34A);
  static const Color frogLight = Color(0xFF22C55E);
  static const Color frogSpot = Color(0xFF14532D);
  static const Color sac = green300;

  /// Eyes `0xfde047`, pupils `0x000000`.
  static const Color eye = Color(0xFFFDE047);
  static const Color pupil = Color(0xFF000000);

  /// Small eyes added to the tadpoles and the froglet (none in the HTML).
  static const Color eyeWhite = Color(0xFFF8FAFC);

  /// Habitats: sand `0xc2b280`, lily pads `0x15803d`, mud `0x78350f`,
  /// rocks `0x64748b`, grass `0x16a34a`, bushes `0x14532d`.
  static const Color sand = Color(0xFFC2B280);
  static const Color lilyPad = frogDark;
  static const Color mud = Color(0xFF78350F);
  static const Color rock = slate500;
  static const Color grass = frog;
  static const Color bush = frogSpot;

  /// Habitat drop labels: `bg-blue-900/70`, `bg-teal-900/70`,
  /// `bg-green-900/70` with `border-*-500/50`.
  static const Color zoneWater = Color(0xB31E3A8A);
  static const Color zoneBank = Color(0xB3134E4A);
  static const Color zoneLand = Color(0xB314532D);
  static const Color zoneWaterEdge = Color(0x803B82F6);
  static const Color zoneBankEdge = Color(0x8014B8A6);
  static const Color zoneLandEdge = Color(0x8022C55E);

  /// Contact shadows under the animals.
  static const Color shadow = Color(0x66000000);

  /// Sprite labels: `rgba(30, 41, 59, 0.92)` / `#475569` (dark theme),
  /// `rgba(255, 255, 255, 0.92)` / `#cbd5e1` (light theme).
  static const Color labelBgDark = Color(0xEB1E293B);
  static const Color labelBgLight = Color(0xEBFFFFFF);

  /// canvas-confetti's default colours (HTML `confetti(...)`).
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
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.green500,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6614532D), // green-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC86EFAC), // green-300/80
    curtainIcon: _Colors.green400,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.green400,
    buttonBorder: Color(0x9922C55E),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.green500,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.green600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6614532D),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC86EFAC),
    curtainIcon: _Colors.green400,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.green400,
    buttonBorder: Color(0x9922C55E),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
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
/// plays its `click` tone for buttons, the sidebar, scenario changes and
/// Enter Lab, `pop` for a wrong drop and `success` for the summary.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.click,
  correct: _Sound.correct,
  wrong: _Sound.pop,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The HTML
// cards carried their answer ("Stage 3: With Legs" for Slot 3, "Tadpole
// (Deep Water Only)"), and its step texts said "Click" for a drag; the cards
// now show only the name and the steps say what to drag where without
// naming the answer. Each step's observation (shown once the step is done)
// starts with what was found. Canvas texts, toasts and hints the HTML had
// in English only got their Hindi; keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Life Cycle of Amphibians (Frog)',
    'app_subtitle':
        'Class 6 • Living Creatures: Exploring their Characteristics',
    'scen_1_opt': 'Scenario 1: The Pond Timeline Puzzle (5 Stages)',
    'scen_2_opt': 'Scenario 2: Habitat Match-Up (Aquatic vs Land)',
    's1_desc':
        "To identify and sequence the five stages of a frog's metamorphosis from jelly-like spawn to fully grown adult frog.",
    's2_desc':
        'To investigate how physical adaptations at each life stage determine whether the organism needs deep water, shallow banks, or dry land.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': "Where does a frog's life begin?",
    's1_a1':
        "Find the card of the first stage of a frog's life in the tray and drag it into Slot 1 of the timeline.",
    's1_o1':
        'Eggs (spawn): soft, jelly-like eggs float protected in water. Inside each dark centre, an embryo develops.',
    's1_c2': 'What hatches from the eggs?',
    's1_a2':
        'Drag the card of the stage that hatches from the eggs into Slot 2.',
    's1_o2':
        'Tadpole: tadpoles hatch! They look like fish, breathe through gills, and swim using a long muscular tail.',
    's1_c3': 'How does the tadpole begin to change?',
    's1_a3': 'Drag the card of the next stage into Slot 3.',
    's1_o3':
        'Tadpole with legs: hind legs begin to sprout! The organism still lives underwater using its tail and gills.',
    's1_c4': 'What comes just before the adult?',
    's1_a4': 'Drag the card of the next stage into Slot 4.',
    's1_o4':
        'Froglet: front legs emerge and the tail shrinks into a short stub. Lungs begin to develop for air breathing.',
    's1_c5': 'Which stage completes the life cycle?',
    's1_a5': 'Drag the last card into Slot 5.',
    's1_o5':
        'Adult frog: the tail is completely reabsorbed! The adult frog has powerful jumping legs, webbed feet, and breathes air.',
    // Step 6 is the HTML HUD's sixth line.
    's1_c6': 'The complete life cycle',
    's1_a6':
        "Tap 'Observe Summary & Conclusion'. To first watch all five stages in order, tap 'Play Metamorphosis Animation'.",
    's1_o6':
        'Eggs → tadpole → tadpole with legs → froglet → adult frog. This change in body form as a frog grows is called metamorphosis.',
    // Scenario 2 steps.
    's2_c1': 'Where can a tadpole live?',
    's2_a1':
        'Drag the Tadpole card onto the habitat in the scene where a tadpole can breathe and swim.',
    's2_o1':
        'Deep water: tadpoles swim gracefully in water. If placed on land, they cannot breathe and flop helplessly!',
    's2_c2': 'Where does a froglet rest?',
    's2_a2': 'Drag the Froglet card onto the habitat that suits a froglet.',
    's2_o2':
        'Shallow bank: froglets prefer the shallow bank edge where they can use developing lungs while staying wet.',
    's2_c3': 'Where does an adult frog live?',
    's2_a3':
        'Drag the Adult Frog card onto the habitat that suits an adult frog.',
    's2_o3':
        'Dry land: adult frogs live on land catching insects with their tongue, and dive into water to stay moist and lay eggs.',
    's2_c4': 'Conclusion',
    's2_a4': "Tap 'Observe Summary & Conclusion'.",
    's2_o4':
        'Because amphibians need both clean water and healthy land environments, they are critical environmental health indicators.',
    // HTML `hud` lines (canvas "Current Task"), without the answers.
    's1_hud_1': 'Which stage comes first? Drag its card into Slot 1.',
    's1_hud_2': 'What hatches from the eggs? Drag its card into Slot 2.',
    's1_hud_3': 'Drag the next stage into Slot 3.',
    's1_hud_4': 'Drag the next stage into Slot 4.',
    's1_hud_5': 'Drag the last stage into Slot 5.',
    's1_hud_6':
        "Tap 'Play Metamorphosis Animation' or 'Observe Summary & Conclusion'.",
    's2_hud_1':
        'Drag the Tadpole to the habitat where it can breathe with gills and swim with its tail.',
    's2_hud_2':
        'Drag the Froglet to the habitat that suits it while its lungs develop.',
    's2_hud_3':
        'Drag the Adult Frog to the habitat where it can hop about and catch insects.',
    's2_hud_4':
        "Tap 'Observe Summary & Conclusion' to master amphibian habitat shifts.",
    // Tray cards and timeline.
    'drag_timeline': 'Drag to Timeline Slots',
    'drag_habitat': 'Drag Organism to Habitat Area',
    'chip_eggs': 'Eggs',
    'chip_tadpole': 'Tadpole',
    'chip_legs': 'Tadpole with Legs',
    'chip_froglet': 'Froglet',
    'chip_adult': 'Adult Frog',
    'slot_n': 'Slot {n}',
    'slot_eggs': 'Eggs',
    'slot_tadpole': 'Tadpole',
    'slot_legs': 'With Legs',
    'slot_froglet': 'Froglet',
    'slot_adult': 'Adult',
    'play_all_btn': 'Play Metamorphosis Animation',
    'btn_conclude': 'Observe Summary & Conclusion',
    // Canvas labels (HTML `createTextSprite`).
    'lbl_eggs': 'Stage 1: Egg Cluster (Spawn)',
    'lbl_tadpole': 'Stage 2: Tadpole (Fish-like/Gills)',
    'lbl_legs': 'Stage 3: Tadpole with Legs',
    'lbl_froglet': 'Stage 4: Froglet (Tail Stub)',
    'lbl_adult': 'Stage 5: Adult Frog (Amphibious)',
    // Habitat drop labels (HTML `.drop-label`).
    'zone_water': 'Deep Water',
    'zone_bank': 'Shallow Bank',
    'zone_land': 'Dry Land',
    // HTML `#stage-text` ("Current Phase").
    'phase_title': 'Current Phase',
    'phase_none': 'Nothing placed yet', // added
    'phase_eggs': 'Stage 1: Eggs (Spawn)',
    'phase_tadpole': 'Stage 2: Tadpole',
    'phase_legs': 'Stage 3: Tadpole with Legs',
    'phase_froglet': 'Stage 4: Froglet',
    'phase_adult': 'Stage 5: Adult Frog',
    'phase_s2_tadpole': 'Aquatic Habitat (Tadpole)',
    'phase_s2_froglet': 'Shallow Bank Edge (Froglet)',
    'phase_s2_adult': 'Amphibious Dual-Habitat (Adult)',
    // HTML toasts. The tadpole needs water, not deep water.
    't_play': 'Playing full 5-stage metamorphosis time-lapse sequence...',
    't_tadpole': 'Tadpoles need water to swim and to breathe with their gills!',
    't_froglet':
        'Froglets prefer shallow water edge while their lungs develop!',
    't_adult':
        'Adult frogs can jump on dry land and swim in deep water (Amphibious)!',
    // Added: hints for a wrong drop (the HTML only shook the slot / zone).
    'e_wrong_stage':
        "Not this stage! Think about what comes at this point of a frog's life, then try another card.",
    'e_order_s1':
        'Fill the timeline in order: the next card goes into Slot {n}.',
    'e_drop_slot': 'Drop the card into one of the timeline slots.',
    'e_order_s2': 'Place the {name} first.',
    'e_drop_zone':
        'Drop the card on one of the habitats: deep water, shallow bank or dry land.',
    'e_hab_tadpole':
        'A tadpole breathes with gills and swims with its tail. It cannot live out of water. Try again.',
    'e_hab_froglet':
        'A froglet is between water life and land life: its lungs are developing, but it must stay wet. Try again.',
    'e_hab_adult':
        'An adult frog breathes air with its lungs and hops on strong legs to catch insects. Try again.',
    // Summary popup (HTML `ScenariosData[...].summary`). "Complete
    // metamorphosis" is the insect term (egg, larva, pupa, adult).
    'sum_s1_title': 'Metamorphosis Mastered!',
    'sum_s1':
        "Frogs undergo metamorphosis. The transition from a fish-like, water-breathing tadpole to a four-legged, air-breathing adult is one of nature's most dramatic transformations.",
    'sum_s2_title': 'Amphibian Adaptations Verified!',
    'sum_s2':
        "The word 'Amphibian' means 'double life'. Frogs start life entirely in water (aquatic tadpole) and mature into dual-habitat adults capable of thriving on land and water.",
    // Added: the sidebar's observation list.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        "A pond on a lab bench, where each stage of the frog's life cycle appears once it is placed on the timeline",
    'scene_s2':
        'A habitat model with deep water, a shallow muddy bank and dry land',
  },
  'hi': {
    'app_title': 'उभयचरों का जीवन चक्र (मेंढक)',
    'app_subtitle': 'कक्षा 6 • सजीव प्राणी: उनकी विशेषताओं की खोज',
    'scen_1_opt': 'परिदृश्य 1: तालाब की समयरेखा पहेली (5 चरण)',
    'scen_2_opt': 'परिदृश्य 2: आवास मिलान (जल बनाम थल)',
    's1_desc':
        'जेली जैसे अंडों के समूह (स्पॉन) से पूरी तरह बड़े वयस्क मेंढक तक, मेंढक के कायांतरण के पाँच चरणों को पहचानना और उन्हें सही क्रम में लगाना।',
    's2_desc':
        'यह जाँचना कि हर चरण की शारीरिक विशेषताएँ कैसे तय करती हैं कि जीव को गहरा पानी, उथला किनारा या सूखी ज़मीन चाहिए।',
    's1_c1': 'मेंढक का जीवन कहाँ से शुरू होता है?',
    's1_a1':
        'ट्रे में मेंढक के जीवन के पहले चरण का कार्ड खोजें और उसे समयरेखा के स्थान 1 में खींचें।',
    's1_o1':
        'अंडे (स्पॉन): जेली जैसे मुलायम अंडे पानी में सुरक्षित तैरते हैं। हर अंडे के काले केंद्र में भ्रूण विकसित होता है।',
    's1_c2': 'अंडों से क्या निकलता है?',
    's1_a2': 'जो चरण अंडों से निकलता है, उसका कार्ड स्थान 2 में खींचें।',
    's1_o2':
        'टैडपोल: अंडों से टैडपोल निकलते हैं! वे मछली जैसे दिखते हैं, गलफड़ों से साँस लेते हैं और लंबी मज़बूत पूँछ से तैरते हैं।',
    's1_c3': 'टैडपोल में बदलाव कैसे शुरू होता है?',
    's1_a3': 'अगले चरण का कार्ड स्थान 3 में खींचें।',
    's1_o3':
        'पैरों वाला टैडपोल: पिछले पैर निकलने लगते हैं! यह अब भी पानी में रहता है और पूँछ व गलफड़ों का उपयोग करता है।',
    's1_c4': 'वयस्क बनने से ठीक पहले कौन-सा चरण आता है?',
    's1_a4': 'अगले चरण का कार्ड स्थान 4 में खींचें।',
    's1_o4':
        'फ्रॉगलेट: अगले पैर निकल आते हैं और पूँछ छोटी होकर एक ठूँठ रह जाती है। हवा में साँस लेने के लिए फेफड़े विकसित होने लगते हैं।',
    's1_c5': 'कौन-सा चरण जीवन चक्र को पूरा करता है?',
    's1_a5': 'आख़िरी कार्ड को स्थान 5 में खींचें।',
    's1_o5':
        'वयस्क मेंढक: पूँछ पूरी तरह शरीर में समा जाती है! वयस्क मेंढक के कूदने वाले मज़बूत पैर और जालीदार पंजे होते हैं, और वह हवा में साँस लेता है।',
    's1_c6': 'पूरा जीवन चक्र',
    's1_a6':
        "'निष्कर्ष और सारांश देखें' पर टैप करें। पहले पाँचों चरण क्रम से देखने के लिए 'कायांतरण एनीमेशन चलाएं' पर टैप करें।",
    's1_o6':
        'अंडे → टैडपोल → पैरों वाला टैडपोल → फ्रॉगलेट → वयस्क मेंढक। बढ़ते हुए मेंढक के शरीर के रूप में होने वाले इस बदलाव को कायांतरण कहते हैं।',
    's2_c1': 'टैडपोल कहाँ रह सकता है?',
    's2_a1':
        'टैडपोल के कार्ड को दृश्य में उस आवास पर खींचें जहाँ टैडपोल साँस ले सके और तैर सके।',
    's2_o1':
        'गहरा पानी: टैडपोल पानी में आसानी से तैरते हैं। ज़मीन पर रखने पर वे साँस नहीं ले पाते और छटपटाते हैं!',
    's2_c2': 'फ्रॉगलेट कहाँ आराम करता है?',
    's2_a2':
        'फ्रॉगलेट के कार्ड को उस आवास पर खींचें जो फ्रॉगलेट के लिए सही हो।',
    's2_o2':
        'उथला किनारा: फ्रॉगलेट उथले किनारे को पसंद करते हैं, जहाँ वे विकसित होते फेफड़ों का उपयोग कर सकते हैं और गीले भी रहते हैं।',
    's2_c3': 'वयस्क मेंढक कहाँ रहता है?',
    's2_a3':
        'वयस्क मेंढक के कार्ड को उस आवास पर खींचें जो वयस्क मेंढक के लिए सही हो।',
    's2_o3':
        'सूखी ज़मीन: वयस्क मेंढक ज़मीन पर रहकर जीभ से कीड़े पकड़ते हैं, और नम रहने तथा अंडे देने के लिए पानी में जाते हैं।',
    's2_c4': 'निष्कर्ष',
    's2_a4': "'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_o4':
        'चूँकि उभयचरों को साफ़ पानी और स्वस्थ ज़मीन दोनों चाहिए, इसलिए वे पर्यावरण के स्वास्थ्य के महत्वपूर्ण संकेतक हैं।',
    's1_hud_1': 'कौन-सा चरण सबसे पहले आता है? उसका कार्ड स्थान 1 में खींचें।',
    's1_hud_2': 'अंडों से क्या निकलता है? उसका कार्ड स्थान 2 में खींचें।',
    's1_hud_3': 'अगले चरण को स्थान 3 में खींचें।',
    's1_hud_4': 'अगले चरण को स्थान 4 में खींचें।',
    's1_hud_5': 'आख़िरी चरण को स्थान 5 में खींचें।',
    's1_hud_6':
        "'कायांतरण एनीमेशन चलाएं' या 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_hud_1':
        'टैडपोल को उस आवास पर खींचें जहाँ वह गलफड़ों से साँस ले सके और पूँछ से तैर सके।',
    's2_hud_2':
        'फ्रॉगलेट को उस आवास पर खींचें जो फेफड़े विकसित होते समय उसके लिए सही हो।',
    's2_hud_3':
        'वयस्क मेंढक को उस आवास पर खींचें जहाँ वह फुदक सके और कीड़े पकड़ सके।',
    's2_hud_4':
        "उभयचरों के आवास में बदलाव समझने के लिए 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    'drag_timeline': 'समयरेखा के स्थानों में खींचें',
    'drag_habitat': 'जीव को आवास क्षेत्र में खींचें',
    'chip_eggs': 'अंडे',
    'chip_tadpole': 'टैडपोल',
    'chip_legs': 'पैरों वाला टैडपोल',
    'chip_froglet': 'फ्रॉगलेट',
    'chip_adult': 'वयस्क मेंढक',
    'slot_n': 'स्थान {n}',
    'slot_eggs': 'अंडे',
    'slot_tadpole': 'टैडपोल',
    'slot_legs': 'पैरों वाला',
    'slot_froglet': 'फ्रॉगलेट',
    'slot_adult': 'वयस्क',
    'play_all_btn': 'कायांतरण एनीमेशन चलाएं',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'lbl_eggs': 'चरण 1: अंडों का समूह (स्पॉन)',
    'lbl_tadpole': 'चरण 2: टैडपोल (मछली जैसा/गलफड़े)',
    'lbl_legs': 'चरण 3: पैरों वाला टैडपोल',
    'lbl_froglet': 'चरण 4: फ्रॉगलेट (छोटी पूँछ)',
    'lbl_adult': 'चरण 5: वयस्क मेंढक (उभयचर)',
    'zone_water': 'गहरा पानी',
    'zone_bank': 'उथला किनारा',
    'zone_land': 'सूखी ज़मीन',
    'phase_title': 'वर्तमान अवस्था',
    'phase_none': 'अभी कुछ नहीं रखा गया',
    'phase_eggs': 'चरण 1: अंडे (स्पॉन)',
    'phase_tadpole': 'चरण 2: टैडपोल',
    'phase_legs': 'चरण 3: पैरों वाला टैडपोल',
    'phase_froglet': 'चरण 4: फ्रॉगलेट',
    'phase_adult': 'चरण 5: वयस्क मेंढक',
    'phase_s2_tadpole': 'जलीय आवास (टैडपोल)',
    'phase_s2_froglet': 'उथला किनारा (फ्रॉगलेट)',
    'phase_s2_adult': 'जल-थल दोनों आवास (वयस्क)',
    't_play': 'पाँचों चरणों का पूरा कायांतरण क्रम चल रहा है...',
    't_tadpole': 'टैडपोल को तैरने और गलफड़ों से साँस लेने के लिए पानी चाहिए!',
    't_froglet':
        'फेफड़े विकसित होते समय फ्रॉगलेट उथले पानी के किनारे को पसंद करते हैं!',
    't_adult':
        'वयस्क मेंढक सूखी ज़मीन पर कूद सकते हैं और गहरे पानी में तैर सकते हैं (उभयचर)!',
    'e_wrong_stage':
        'यह चरण यहाँ नहीं आता! सोचें कि मेंढक के जीवन में इस समय क्या आता है, फिर कोई दूसरा कार्ड आज़माएँ।',
    'e_order_s1': 'समयरेखा को क्रम से भरें: अगला कार्ड स्थान {n} में रखें।',
    'e_drop_slot': 'कार्ड को समयरेखा के किसी स्थान में छोड़ें।',
    'e_order_s2': 'पहले {name} को रखें।',
    'e_drop_zone':
        'कार्ड को किसी एक आवास पर छोड़ें: गहरा पानी, उथला किनारा या सूखी ज़मीन।',
    'e_hab_tadpole':
        'टैडपोल गलफड़ों से साँस लेता है और पूँछ से तैरता है। वह पानी से बाहर नहीं रह सकता। फिर से कोशिश करें।',
    'e_hab_froglet':
        'फ्रॉगलेट जल-जीवन और थल-जीवन के बीच के चरण में है: उसके फेफड़े विकसित हो रहे हैं, पर उसे गीला रहना ज़रूरी है। फिर से कोशिश करें।',
    'e_hab_adult':
        'वयस्क मेंढक फेफड़ों से हवा में साँस लेता है और कीड़े पकड़ने के लिए मज़बूत पैरों से फुदकता है। फिर से कोशिश करें।',
    'sum_s1_title': 'कायांतरण पूर्ण!',
    'sum_s1':
        'मेंढक कायांतरण से गुज़रते हैं। मछली जैसे, पानी में साँस लेने वाले टैडपोल से चार पैरों वाले, हवा में साँस लेने वाले वयस्क में बदलना प्रकृति के सबसे अद्भुत परिवर्तनों में से एक है।',
    'sum_s2_title': 'उभयचर अनुकूलन सिद्ध!',
    'sum_s2':
        "'उभयचर' का अर्थ है 'दोहरा जीवन'। मेंढक जीवन की शुरुआत पूरी तरह पानी में (जलीय टैडपोल के रूप में) करते हैं और बड़े होकर जल और थल दोनों में रहने में सक्षम वयस्क बन जाते हैं।",
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'प्रयोगशाला की मेज़ पर एक तालाब, जिसमें समयरेखा पर रखा गया मेंढक के जीवन चक्र का हर चरण दिखाई देता है',
    'scene_s2':
        'गहरे पानी, उथले कीचड़ वाले किनारे और सूखी ज़मीन वाला आवास मॉडल',
  },
};

/// Steps per scenario: Scenario 1 has the HTML's five stage steps plus the
/// HUD's sixth ("Play ... or Observe Summary & Conclusion"); Scenario 2 the
/// HTML's four.
const List<int> _stepCounts = [6, 4];

/// The two scenarios for [lang], built from the string table.
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

/// Where the HTML camera's look-at point lands before any framing.
const Offset _designCenter = Offset(500, 280);
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view, and
/// `camera.position.set(0, 16, 35)` looking at `controls.target` (0, 0, 0)
/// in both scenarios.
const double _fovDegrees = 45;
const _V _eye = _V(0, 16, 35);

/// Sine / cosine of the camera's downward tilt (atan(16 / 35)), used to
/// project the outline of a scaled sphere.
final double _sinPitch = 16 / math.sqrt(16 * 16 + 35 * 35);
final double _cosPitch = 35 / math.sqrt(16 * 16 + 35 * 35);

/// HTML `DirectionalLight` at (20, 40, 20), normalised, and the light
/// intensities (`AmbientLight` 0.65, `DirectionalLight` 0.9).
const _V _light = _V(0.4082, 0.8165, 0.4082);
const double _ambient = 0.65;
const double _diffuse = 0.9;

/// Scene labels: 13 design px, enlarged up to 1.8x on small stages so the
/// HTML's 20 px sprite text stays readable.
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the animations (s).
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the cards and the framing keep clear of: the HUD chip at
/// the bottom of the canvas while the sidebar is open (label row and two
/// lines of Devanagari, x UI scale), the tool column, and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 70;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene: the single animal of Scenario 1 may be
/// drawn up to 2.4x the HTML camera's size, the habitat model up to 1.7x;
/// never smaller than [_minZoom].
const List<double> _maxZoom = [2.4, 1.7];
const double _minZoom = 0.4;

/// A placed stage / organism grows in over this time (s).
const double _popSeconds = 0.35;

/// HTML `play_all`: each stage shows for 1.5 s; the adult arrives at 6 s.
const double _playStepSeconds = 1.5;

/// HTML `.shake-error` (0.4 s) on a slot or habitat after a wrong drop.
const Duration _shakeDuration = Duration(milliseconds: 400);
const double _shakeSeconds = 0.4;

/// HTML `animate()`: the vocal sac scales by `1 + sin(Date.now() * 0.008) *
/// 0.3`, i.e. 8 rad/s.
const double _sacRate = 8;
const double _sacAmp = 0.3;

/// Added life: the tadpoles' tails wave (rad/s), the animals of Scenario 1
/// bob gently, and the adult frog of Scenario 2 hops every few seconds.
const double _wagRate = 7;
const double _bobRate = 1.6;
const double _bobAmp = 0.08;
const double _hopEvery = 3;
const double _hopSeconds = 0.5;
const double _hopHeight = 1.1;

/// The summary popup opens just after its button (HTML: at once, with
/// confetti).
const Duration _conclusionDelay = Duration(milliseconds: 250);

/// HTML `confetti({particleCount: 80, spread: 70, origin: {y: 0.6}})` with
/// the summary: canvas-confetti's 200 ticks of 1/60 s, velocity x 0.9 per
/// tick, gravity 3 px per tick and start velocity 45 (scaled by
/// [_confettiSpeed] for the stage), from 60 % down the canvas.
const int _confettiCount = 80;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 336);
const Rect _confettiPiece = Rect.fromLTWH(-5, -3, 10, 6);

/// Number of life-cycle stages (timeline slots).
const int _stageCount = 5;

/// Tray cards and timeline slots (dp, x UI scale).
double _chipHeight(double s) => math.max(kMinInteractiveDimension, 40 * s);
double _slotSize(double s) => math.max(kMinInteractiveDimension, 52 * s);

/// Tray card padding (dp, x UI scale), the drag-handle icon with its gap,
/// and the space between cards.
const double _chipPadX = 9;
const double _chipIcon = 15;
const double _chipIconGap = 4;
const double _chipSpacing = 6;

/// Timeline: the line between two slots (its margin on each side, its
/// length at full size and at least) and the card's border.
const double _lineMargin = 2;
const double _lineLength = 14;
const double _lineMin = 8;
const double _cardBorder = 1;

/// Key of the scene layer; flows read the scene through its painter.
const ValueKey<String> _sceneKey = ValueKey('ch10a6-scene');

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
}

/// Three.js Euler 'XYZ' rotation of the +y axis by [rx] about x and [rz]
/// about z (the axis of a rotated `CylinderGeometry`).
_V _axisXZ(double rx, double rz) {
  final x = -math.sin(rz);
  final y = math.cos(rz);
  return _V(x, y * math.cos(rx), y * math.sin(rx));
}

/// Ends of a rotated `CylinderGeometry` of [length] centred at [c]: the
/// +y end (`radiusTop`) first.
(_V, _V) _rodEnds(_V c, double length, {double rx = 0, double rz = 0}) {
  final a = _axisXZ(rx, rz) * (length / 2);
  return (c + a, c - a);
}

/// Where the HTML camera's look-at point is drawn on the stage, and how much
/// the scene is enlarged, so it fits beside the cards.
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

/// The HTML PerspectiveCamera as a pinhole projection onto the design
/// stage, in a [_Framing].
class _Cam {
  _Cam(this.framing) : focal = _focal * framing.zoom;

  final _Framing framing;

  /// Pixels per world unit at depth 1.
  final double focal;

  static final _V _f = (_V.zero - _eye).unit;
  static final _V _r = _f.cross(_V.up).unit;
  static final _V _u = _r.cross(_f);

  /// Half the stage height over tan(fov / 2), as in Three.js.
  static final double _focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  _V get eye => _eye;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, (w - _eye).dot(_f));

  Offset p(_V w) {
    final d = w - _eye;
    final k = focal / math.max(0.1, d.dot(_f));
    return Offset(
      framing.center.dx + d.dot(_r) * k,
      framing.center.dy - d.dot(_u) * k,
    );
  }
}

// ------------------------------------------------------ scenario 1: pond

/// The five life-cycle stages: tray card, filled-slot name, canvas label,
/// "Current Phase" text, card colour (HTML `bg-*-600`), where the model
/// floats in the pond and the height of its label.
///
/// The HTML showed every model at y = 3.5 above the 1-unit-deep pond; the
/// eggs and the tadpoles now float on the water.
enum _Stage {
  eggs(
    'chip_eggs',
    'slot_eggs',
    'lbl_eggs',
    'phase_eggs',
    _Colors.indigo600,
    1.3,
    2.9,
  ),
  tadpole(
    'chip_tadpole',
    'slot_tadpole',
    'lbl_tadpole',
    'phase_tadpole',
    _Colors.teal600,
    1.5,
    3.4,
  ),
  legs(
    'chip_legs',
    'slot_legs',
    'lbl_legs',
    'phase_legs',
    _Colors.emerald600,
    1.7,
    3.8,
  ),
  froglet(
    'chip_froglet',
    'slot_froglet',
    'lbl_froglet',
    'phase_froglet',
    _Colors.amber600,
    3.2,
    5.3,
  ),
  adult(
    'chip_adult',
    'slot_adult',
    'lbl_adult',
    'phase_adult',
    _Colors.green600,
    3.5,
    5.7,
  );

  const _Stage(
    this.chipKey,
    this.slotKey,
    this.labelKey,
    this.phaseKey,
    this.color,
    this.y,
    this.labelY,
  );

  final String chipKey;
  final String slotKey;
  final String labelKey;
  final String phaseKey;
  final Color color;
  final double y;
  final double labelY;
}

/// The tray order of the stage cards. The HTML listed them in order with
/// their stage numbers; mixed here so the learner decides the order.
const List<_Stage> _trayOrder = [
  _Stage.legs,
  _Stage.adult,
  _Stage.eggs,
  _Stage.froglet,
  _Stage.tadpole,
];

/// HTML pond: `CylinderGeometry(8, 8, 1)` at y = 0.5 on the lab bench
/// (`BoxGeometry(36, 1.5, 18)` at y = -0.75).
const double _pondRadius = 8;
const double _pondTop = 1;
const _V _benchCenter = _V(0, -0.75, 0);
const _V _benchSize = _V(36, 1.5, 18);

/// HTML spawn: 24 jelly spheres (r 0.5) on a 5 x 5 grid 0.8 apart (x =
/// (e % 5) * 0.8 - 1.6, y = sin(e) * 0.3, z = floor(e / 5) * 0.8 - 1.6),
/// each with a dark embryo (r 0.2); back row first.
final List<_V> _eggSpots = () {
  final spots = [
    for (var e = 0; e < 24; e++)
      _V((e % 5) * 0.8 - 1.6, math.sin(e) * 0.3, (e ~/ 5) * 0.8 - 1.6),
  ];
  spots.sort((a, b) => a.z != b.z ? a.z.compareTo(b.z) : a.x.compareTo(b.x));
  return spots;
}();

// --------------------------------------------------- scenario 2: habitats

/// The three habitats of `s2Group`: deep water (`BoxGeometry(12, 3.5, 14)`
/// at x = -8), the muddy bank between (a ramp from under the water up to
/// the land) and dry land (`BoxGeometry(11, 4.5, 14)` at x = 8.5). [x0] /
/// [x1] bound the drop zone, [top] is where a dropped card aims, [chipAt]
/// carries the zone's name.
enum _Zone {
  water('zone_water', _Colors.zoneWater, _Colors.zoneWaterEdge, -14, -1.5),
  bank('zone_bank', _Colors.zoneBank, _Colors.zoneBankEdge, -1.5, 3),
  land('zone_land', _Colors.zoneLand, _Colors.zoneLandEdge, 3, 14);

  const _Zone(this.key, this.fill, this.edge, this.x0, this.x1);

  final String key;
  final Color fill;
  final Color edge;
  final double x0;
  final double x1;

  double get midX => switch (this) {
    _Zone.water => -7.5,
    _Zone.bank => 0.9,
    _Zone.land => 8.5,
  };

  /// A point on the habitat's surface, in front of where its animal sits.
  _V get top => switch (this) {
    _Zone.water => _V(midX, _waterTop, 2),
    _Zone.bank => _V(midX, _rampY(midX), 2),
    _Zone.land => _V(midX, _landTop, 2),
  };

  /// Anchor of the zone's name chip, on the bench in front of the habitat.
  _V get chipAt => _V(midX, 0, 7.6);
}

/// The organisms of Scenario 2 in step order: tray card, the habitat it
/// needs, its "Current Phase" text, the toast of a right drop, the hint of
/// a wrong one and its card colour (HTML `bg-*-600`).
enum _Org {
  tadpole(
    'chip_tadpole',
    _Zone.water,
    'phase_s2_tadpole',
    't_tadpole',
    'e_hab_tadpole',
    _Colors.blue600,
  ),
  froglet(
    'chip_froglet',
    _Zone.bank,
    'phase_s2_froglet',
    't_froglet',
    'e_hab_froglet',
    _Colors.teal600,
  ),
  adult(
    'chip_adult',
    _Zone.land,
    'phase_s2_adult',
    't_adult',
    'e_hab_adult',
    _Colors.green600,
  );

  const _Org(
    this.chipKey,
    this.zone,
    this.phaseKey,
    this.toastKey,
    this.hintKey,
    this.color,
  );

  final String chipKey;
  final _Zone zone;
  final String phaseKey;
  final String toastKey;
  final String hintKey;
  final Color color;

  /// Where the animal rests: the tadpole under water (HTML (-8, 2, 0)), the
  /// froglet on the bank at the waterline, the adult standing on the grass
  /// (the HTML clones at (0, 3.8, 0) and (8.5, 5, 0) sank into the bank and
  /// the land).
  _Pose get pose => switch (this) {
    _Org.tadpole => const _Pose(_V(-8, 1.8, 0)),
    _Org.froglet => _Pose(
      _V(-0.2, _rampY(-0.2) + 2.25, 0.5),
      roll: math.atan(_rampSlope),
    ),
    _Org.adult => const _Pose(_V(8.5, _landTop + 2.45, 0)),
  };

  /// Anchor (bottom centre) of the label above the animal.
  _V get labelAt => switch (this) {
    _Org.tadpole => const _V(-8, 4.3, 0),
    _Org.froglet => _V(-0.2, _rampY(-0.2) + 4.3, 0.5),
    _Org.adult => const _V(8.5, _landTop + 4.4, 0),
  };
}

/// Deep water top (`BoxGeometry(12, 3.5, 14)` at y = 1.75) and its right
/// edge, where it meets the bank ramp at the waterline.
const double _waterTop = 3.5;
const double _waterLeft = -14;
const double _waterRight = -0.8;
const double _habitatHalfZ = 7;

/// Dry land: `BoxGeometry(11, 4.5, 14)` at (8.5, 2.25, 0).
const double _landTop = 4.5;
const double _landLeft = 3;
const double _landRight = 14;

/// The muddy bank (HTML `BoxGeometry(7, 5, 14)` turned by -0.3, which
/// sloped up towards the water and under the land): a ramp from under the
/// water at x = -5 up to the land's edge.
const double _rampX0 = -5;
const double _rampY0 = 2.4;
const double _rampSlope = (_landTop - _rampY0) / (_landLeft - _rampX0);
double _rampY(double x) => _rampY0 + (x - _rampX0) * _rampSlope;

/// HTML lily pads (`CylinderGeometry(0.8, 0.8, 0.1)` at random spots on the
/// water), placed behind the tadpole.
const List<_V> _lilyPads = [
  _V(-12, _waterTop + 0.05, -3),
  _V(-9.5, _waterTop + 0.05, -5.2),
  _V(-6.2, _waterTop + 0.05, -3.8),
  _V(-3.4, _waterTop + 0.05, -5.4),
];

/// HTML rocks on the bank (`DodecahedronGeometry(0.5–0.8)` at random spots):
/// x, z and radius, clear of the froglet.
const List<(double, double, double)> _rocks = [
  (0.6, -4.6, 0.7),
  (2.1, -2.5, 0.55),
  (2.3, 4.6, 0.6),
  (1.0, 5.6, 0.5),
];

/// HTML bushes on the land: centre and radii (`SphereGeometry(1.5)`
/// scaled). The front one is drawn after the adult frog.
const List<(_V, _V)> _bushes = [
  (_V(7, 4.6, -5), _V(1.2, 1.2, 1.2)),
  (_V(11, 5.0, -4), _V(1.5, 1.5, 1.5)),
  (_V(12.5, 5.0, 4.6), _V(1.8, 1.2, 1.8)),
];

/// A model's placement: position, uniform scale (pop-in) and roll about z
/// (`rotation.z`).
@immutable
class _Pose {
  const _Pose(this.origin, {this.scale = 1, this.roll = 0});

  final _V origin;
  final double scale;
  final double roll;

  _Pose scaled(double k) => _Pose(origin, scale: scale * k, roll: roll);
  _Pose lifted(double dy) =>
      _Pose(origin + _V(0, dy, 0), scale: scale, roll: roll);

  /// World position of the model-space point [v].
  _V at(_V v) {
    final x = v.x * scale, y = v.y * scale;
    if (roll == 0) return origin + _V(x, y, v.z * scale);
    final c = math.cos(roll), s = math.sin(roll);
    return origin + _V(x * c - y * s, x * s + y * c, v.z * scale);
  }

  double r(double radius) => radius * scale;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  // ------------------------------------------------------------ scenario 1
  /// Timeline slots filled so far (in order).
  int filled = 0;

  /// Stage shown in the pond (-1: none yet) and when it appeared.
  int shown = -1;
  double shownAt = -10;

  /// HTML `play_all` time-lapse: start time (-1: not playing) and the stage
  /// it shows.
  double playStart = -1;
  int playStage = -1;

  // ------------------------------------------------------------ scenario 2
  /// Organisms placed in their habitats so far (in step order).
  int placed = 0;

  /// Organism shown in its habitat (-1: none) and when it appeared.
  int orgShown = -1;
  double orgShownAt = -10;

  /// Habitat under a dragged card, and the habitat flashing red after a
  /// wrong drop.
  int hoverZone = -1;
  int errorZone = -1;
  double errorAt = -10;

  /// The summary of each scenario has been opened.
  final List<bool> concluded = [false, false];

  /// When the summary's confetti burst started (null: none).
  double? confettiAt;

  /// The confetti pieces: launch angle, speed, colour and spin.
  final List<({double angle, double velocity, Color color, double spin})>
  confetti = () {
    final rnd = math.Random(6);
    return [
      for (var i = 0; i < _confettiCount; i++)
        (
          angle: -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          velocity:
              (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          color: _Colors.confetti[i % _Colors.confetti.length],
          spin: (rnd.nextDouble() - 0.5) * 0.4,
        ),
    ];
  }();

  /// The free part of the stage (design px): labels are kept inside it.
  Rect labelBounds = Offset.zero & _design;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  bool get framingSettled => _framingT >= 1;
  bool get playing => playStart >= 0;

  /// Stage the pond shows now (the time-lapse overrides the last placed).
  int get displayStage => playing ? playStage : shown;
  bool get s1Done => filled >= _stageCount;
  bool get s2Done => placed >= _Org.values.length;

  /// 1-based current step; one past the last once the summary was opened.
  int get step => scenario == 0
      ? (concluded[0] ? _stepCounts[0] + 1 : filled + 1)
      : (concluded[1] ? _stepCounts[1] + 1 : placed + 1);

  /// HTML `changeScenario(id)` / `resetApp()`: everything back to the start.
  void load(int index) {
    scenario = index;
    filled = 0;
    shown = -1;
    shownAt = -10;
    playStart = -1;
    playStage = -1;
    placed = 0;
    orgShown = -1;
    orgShownAt = -10;
    hoverZone = -1;
    errorZone = -1;
    errorAt = -10;
    concluded
      ..[0] = false
      ..[1] = false;
    confettiAt = null;
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

  void tickFraming(double dt) {
    if (_framingT >= 1) return;
    _framingT = math.min(1, _framingT + dt / _framingSeconds);
    framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
  }

  /// Design point aimed at when dropping on habitat [i] (flows).
  Offset zonePointAt(int i) => _Cam(framing).p(_Zone.values[i].top);

  /// Design point on the pond's water, off the timeline (flows).
  Offset get pondPoint => _Cam(framing).p(const _V(0, _pondTop, 0));

  /// The whole habitat model on the stage (drop area), in [cam].
  static Rect dioramaRect(_Cam cam) {
    var r = Rect.fromCircle(center: cam.p(_V.zero), radius: 1);
    for (final x in const [_waterLeft, _landRight]) {
      for (final y in const [0.0, 7.5]) {
        for (final z in const [-_habitatHalfZ, _habitatHalfZ]) {
          final o = cam.p(_V(x, y, z));
          r = r.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0));
        }
      }
    }
    return r;
  }

  /// Rect of habitat [z] on the stage: the HTML drop zones were thirds of
  /// the canvas; here they follow the habitats' borders.
  static Rect zoneRect(_Cam cam, _Zone z) {
    final all = dioramaRect(cam);
    final left = z == _Zone.water ? all.left : cam.p(_V(z.x0, 3.5, 0)).dx;
    final right = z == _Zone.land ? all.right : cam.p(_V(z.x1, 3.5, 0)).dx;
    return Rect.fromLTRB(left, all.top, right, all.bottom);
  }

  /// The habitat under design point [p], or null when [p] is off the model.
  _Zone? zoneAt(Offset p) {
    final cam = _Cam(framing);
    if (!dioramaRect(cam).inflate(12).contains(p)) return null;
    for (final z in _Zone.values) {
      final r = zoneRect(cam, z);
      if (p.dx < r.right || z == _Zone.land) return z;
    }
    return null;
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
  return _Framing(rect.center - extent(zoom).center, zoom);
}

/// HTML `.shake-error` keyframes: 0, -6, 6, -4, 4, 0 px at 0, 20 … 100 %.
double _shakeOffset(double t) {
  const keys = [0.0, -6.0, 6.0, -4.0, 4.0, 0.0];
  final x = (t.clamp(0.0, 1.0)) * (keys.length - 1);
  final i = math.min(keys.length - 2, x.floor());
  return keys[i] + (keys[i + 1] - keys[i]) * (x - i);
}

class _FrogLabState extends State<Ch10A6LifeCycleOfAmphibiansFrogPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas (measured for the framing), the tray and timeline cards,
  /// and the painted scene (drop positions are converted through it).
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _trayKey = GlobalKey();
  final GlobalKey _timelineKey = GlobalKey();
  final GlobalKey _paintKey = GlobalKey();

  /// Wrong drops per timeline slot (each one restarts the slot's shake).
  final List<int> _shakes = List.filled(_stageCount, 0);

  /// Label size in design pixels for the current stage scale.
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card's box, kept at its largest so the scene
  /// does not jump while its text changes.
  Rect? _cardRect;

  /// The last toast this lab showed (re-translated on a language switch).
  String Function()? _toastText;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

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

  /// HTML `animate()`: the time-lapse, the framing slide and one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.tickFraming(dt);
    if (s.playing) _tickPlay();
    _frame.value = now;
  }

  /// HTML `handleS1Action('play_all')`: a stage every 1.5 s; at 6 s the
  /// adult frog croaks and the time-lapse ends on it.
  void _tickPlay() {
    final s = _scene;
    final elapsed = s.time - s.playStart;
    final last = _stageCount - 1;
    if (elapsed >= last * _playStepSeconds) {
      _Sound.croak.play();
      setState(() {
        s
          ..playStart = -1
          ..playStage = -1
          ..shown = last
          ..shownAt = s.time;
      });
      return;
    }
    final stage = (elapsed / _playStepSeconds).floor().clamp(0, last);
    if (stage != s.playStage) {
      setState(() {
        s
          ..playStage = stage
          ..shownAt = s.time;
      });
    }
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)`: clears timers and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _shakes.fillRange(0, _shakes.length, 0);
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Shows the toast built by [text] (re-built on a language switch).
  void _toast(
    String Function() text, {
    bool error = false,
    bool sound = false,
  }) {
    _toastText = text;
    _lab.showToast(text(), isError: error, sound: sound);
    _toastId = _lab.toast?.id;
  }

  /// After a language switch, shows this lab's toast in the new language.
  void _retranslateToast() {
    final shown = _lab.toast;
    final text = _toastText;
    if (shown == null || text == null || shown.id != _toastId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(text(), isError: shown.isError, sound: false);
      _toastId = _lab.toast?.id;
    });
  }

  /// HTML `triggerConclusion()`: the summary popup (success tone).
  void _conclude(int sc) {
    final s = _scene;
    if (s.scenario != sc || !(sc == 0 ? s.s1Done : s.s2Done)) return;
    setState(() {
      s
        ..concluded[sc] = true
        ..confettiAt = s.time;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: _conclusionDelay,
      heading: () => _t('sum_s${sc + 1}_title'),
      body: () => _t('sum_s${sc + 1}'),
    );
  }

  /// HTML `handleS1Action('play_all')`: croak, toast, then the five stages
  /// one after another.
  void _playAll() {
    final s = _scene;
    if (s.scenario != 0 || !s.s1Done || s.playing) return;
    _Sound.croak.play();
    _toast(() => _t('t_play'));
    setState(() {
      s
        ..playStart = s.time
        ..playStage = 0
        ..shownAt = s.time;
    });
  }

  // ------------------------------------------------------------- dropping

  /// HTML `onDrop(event, slot)`: the card that belongs in the slot fills it
  /// and its stage appears in the pond; any other card shakes the slot. The
  /// slots are filled in order (the HTML jumped to the step after the stage
  /// dropped, whichever it was); a card dropped on a filled or a later slot
  /// is told which slot comes next.
  void _dropOnSlot(int slot, _Stage stage) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.s1Done) return;
    if (slot != s.filled) {
      final next = s.filled + 1;
      _shake(slot);
      _toast(() => labFormat(_t('e_order_s1'), {'n': next}), error: true);
      return;
    }
    if (stage.index != slot) {
      _shake(slot);
      _toast(() => _t('e_wrong_stage'), error: true);
      return;
    }
    _Sound.correct.play();
    if (stage == _Stage.adult) _Sound.croak.play();
    setState(() {
      s
        ..filled = slot + 1
        ..shown = stage.index
        ..shownAt = s.time;
    });
  }

  void _shake(int slot) {
    _Sound.pop.play();
    setState(() => _shakes[slot]++);
  }

  /// A card let go on the scene: Scenario 1 wants it in a slot; Scenario 2
  /// checks the habitat under it (HTML `onDropHab`).
  void _dropOnStage(Object data, Offset global) {
    final s = _scene;
    s.hoverZone = -1;
    if (!_lab.isLabActive) return;
    if (s.scenario == 0 || data is! _Org) {
      if (data is _Stage && s.scenario == 0) {
        _Sound.pop.play();
        _toast(() => _t('e_drop_slot'), error: true);
      }
      return;
    }
    if (s.s2Done) return;
    final local = labGlobalToLocal(_paintKey, global);
    final zone = local == null ? null : s.zoneAt(local);
    if (zone == null) {
      _Sound.pop.play();
      _toast(() => _t('e_drop_zone'), error: true);
      return;
    }
    final current = _Org.values[s.placed];
    if (data != current) {
      _flashZone(zone);
      _toast(
        () => labFormat(_t('e_order_s2'), {'name': _t(current.chipKey)}),
        error: true,
      );
      return;
    }
    if (zone != data.zone) {
      _flashZone(zone);
      _toast(() => _t(data.hintKey), error: true);
      return;
    }
    // HTML `handleS2Action`: the animal appears in its habitat with a toast.
    _Sound.correct.play();
    if (data == _Org.adult) _Sound.croak.play();
    setState(() {
      s
        ..placed = s.placed + 1
        ..orgShown = data.index
        ..orgShownAt = s.time;
    });
    _toast(() => _t(data.toastKey));
  }

  void _flashZone(_Zone zone) {
    _Sound.pop.play();
    _scene
      ..errorZone = zone.index
      ..errorAt = _scene.time;
  }

  /// HTML `onDragOver`: the habitat under a dragged animal card lights up.
  void _hoverStage(Object data, Offset global) {
    final s = _scene;
    if (s.scenario != 1 || data is! _Org) {
      s.hoverZone = -1;
      return;
    }
    final local = labGlobalToLocal(_paintKey, global);
    s.hoverZone = local == null ? -1 : (s.zoneAt(local)?.index ?? -1);
  }

  void _clearHover() => _scene.hoverZone = -1;

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

  /// Bottom of the canvas kept free: the HUD chip while the sidebar is open.
  double _bottomBand(double s, EdgeInsets pad) {
    final hud = _lab.isSidebarOpen && !_scene.concluded[_scene.scenario];
    return 8 + (hud ? _hudBand * s : 0) + pad.bottom;
  }

  /// Fits the animal (Scenario 1) or the habitat model (Scenario 2) and
  /// their labels into the part of the canvas no card covers: the tool
  /// column, the HUD (sidebar open), the tray, the timeline and the
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
      size.height - _bottomBand(context.labScale, pad),
    );
    final hard = <Rect>[];
    void addCard(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize && box.attached) {
        hard.add((box.localToGlobal(Offset.zero) - origin) & box.size);
      }
    }

    if (_lab.isLabActive) {
      addCard(_trayKey);
      if (_scene.scenario == 0) addCard(_timelineKey);
    }
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
    final freeDesign = toDesign(free).intersect(_stageRect);
    _scene.labelBounds = freeDesign;
    final target = _fitFraming(_focusItems(), freeDesign, [
      for (final r in hard) toDesign(r.inflate(_cardGap)),
    ], _maxZoom[_scene.scenario]);
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

  /// What the learner must see: the animal's box (Scenario 1) or the three
  /// habitats (Scenario 2) at zoom 1, and the label chips at their painted
  /// size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V lo, _V hi) {
      for (var i = 0; i < 8; i++) {
        final c = _V(
          i & 1 == 0 ? lo.x : hi.x,
          i & 2 == 0 ? lo.y : hi.y,
          i & 4 == 0 ? lo.z : hi.z,
        );
        items.add((cam.p(c), Rect.zero));
      }
    }

    if (_scene.scenario == 0) {
      box(const _V(-6.6, 0.2, -2.3), const _V(3.7, 5.0, 2.3));
      for (final st in _Stage.values) {
        final size = _cache.chipSize(_t(st.labelKey));
        items.add((
          cam.p(_V(0, st.labelY, 0)),
          Rect.fromLTRB(-size.width / 2, -size.height, size.width / 2, 0),
        ));
      }
    } else {
      box(
        const _V(_waterLeft, 0, -_habitatHalfZ),
        const _V(_landRight, 7.5, _habitatHalfZ),
      );
      for (final o in _Org.values) {
        final size = _cache.chipSize(_t(o.phaseKey));
        items.add((
          cam.p(o.labelAt),
          Rect.fromLTRB(-size.width / 2, -size.height, size.width / 2, 0),
        ));
      }
      for (final z in _Zone.values) {
        final size = _cache.chipSize(_t(z.key));
        items.add((
          cam.p(z.chipAt),
          Rect.fromLTRB(-size.width / 2, 0, size.width / 2, size.height),
        ));
      }
    }
    return items;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#s1-play-btn` and `#compare-btn-container`, shown once every
  /// card is placed (the HTML showed the summary button as soon as Stage 5
  /// was dropped, even with other slots empty).
  List<LabAction> _actions() {
    final s = _scene;
    final sc = s.scenario;
    if (!(sc == 0 ? s.s1Done : s.s2Done)) return const [];
    return [
      if (sc == 0)
        LabAction(
          label: _t('play_all_btn'),
          icon: Icons.play_circle,
          color: _Colors.amber500,
          foreground: _Colors.slate950,
          enabled: !s.playing,
          // The time-lapse plays the HTML croak.
          silent: true,
          onTap: _playAll,
        ),
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.green600,
        foreground: _Colors.white,
        highlight: !s.concluded[sc],
        // The summary plays the success tone.
        silent: true,
        onTap: () => _conclude(sc),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        if (_lab.lang != _builtLang) {
          _builtLang = _lab.lang;
          _retranslateToast();
        }
        final p = _lab.palette;
        final s = context.labScale;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final step = _scene.step;
        final done = _scene.concluded[sc];
        final inset = labOverlayInsets(context, _lab);
        final pad = MediaQuery.paddingOf(context);
        final compact = MediaQuery.sizeOf(context).height < _compactBelow;
        // While the sidebar is collapsed on a phone the timeline sits below
        // the mission card (which is at most 55 % of the height), so it may
        // use the canvas from its left edge.
        final timelineLeft = _lab.isSidebarOpen
            ? 8.0
            : (compact ? 8 + pad.left : inset.left);
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.waves,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          // HTML `hud-instruction`; it no longer applies once the summary
          // was opened.
          showHud: !done,
          hud: _t('s${sc + 1}_hud_${step.clamp(1, data.steps.length)}'),
          actions: _actions(),
          // HTML `enterLab()` and `restartApp()` (page reload) both start
          // at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _sidebarExtra(p, f),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#s1-draggables` / `#s2-draggables` (top of the canvas).
            if (_lab.isLabActive)
              Positioned(
                key: const ValueKey('ch10a6-tray-card'),
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _tray(p, s),
                ),
              ),
            // HTML timeline drop zones (bottom of the canvas, Scenario 1).
            if (_lab.isLabActive && sc == 0)
              Positioned(
                key: const ValueKey('ch10a6-timeline-card'),
                bottom: _bottomBand(s, pad),
                left: timelineLeft,
                right: inset.right,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _timeline(p, s),
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          // HTML `#s2-drop-zones` over the 3D scene; in Scenario 1 a card
          // let go on the scene is told to go into a slot.
          child: DragTarget<Object>(
            onWillAcceptWithDetails: (d) =>
                _lab.isLabActive && (d.data is _Stage || d.data is _Org),
            onMove: (d) => _hoverStage(d.data, d.offset),
            onLeave: (_) => _clearHover(),
            onAcceptWithDetails: (d) => _dropOnStage(d.data, d.offset),
            builder: (context, candidates, rejected) => KeyedSubtree(
              key: _sceneKey,
              child: Semantics(
                image: true,
                label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: _paintKey,
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
            ),
          ),
        );
      },
    );
  }

  /// HTML tray: "Drag to Timeline Slots" (the five stage cards) or "Drag
  /// Organism to Habitat Area" (tadpole, froglet, adult frog).
  Widget _tray(LabPalette p, double s) {
    final sc = _scene.scenario;
    final title = _t(sc == 0 ? 'drag_timeline' : 'drag_habitat');
    final accent = sc == 0 ? _Colors.indigo500 : _Colors.cyan500;
    final ink = p.ink(
      sc == 0
          ? (p.isDark ? _Colors.indigo400 : _Colors.indigo600)
          : (p.isDark ? _Colors.cyan500 : _Colors.cyan600),
    );
    final cards = sc == 0
        ? [for (final st in _trayOrder) _t(st.chipKey)]
        : [for (final o in _Org.values) _t(o.chipKey)];
    final maxWidth = 600 * s;
    return LayoutBuilder(
      builder: (context, box) {
        // The drag-handle icons are left out when they would push the cards
        // onto a second row (small phones), which would leave the scene
        // only a thin strip between the tray and the timeline.
        final room =
            math.min(maxWidth, box.maxWidth) - 2 * (8 * s + _cardBorder);
        final icons =
            _chipsWidth(context, cards, s, icons: true) <= room ||
            _chipsWidth(context, cards, s, icons: false) > room;
        return _trayCard(p, s, title, accent, ink, maxWidth, icons);
      },
    );
  }

  /// Width of the tray cards labelled [labels] in one row.
  double _chipsWidth(
    BuildContext context,
    List<String> labels,
    double s, {
    required bool icons,
  }) {
    final style = DefaultTextStyle.of(
      context,
    ).style.merge(_ChipView.textStyle(s, _Colors.white));
    final scaler = MediaQuery.textScalerOf(context);
    var width = (labels.length - 1) * _chipSpacing * s;
    for (final label in labels) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      width +=
          tp.width +
          2 * _chipPadX * s +
          (icons ? (_chipIcon + _chipIconGap) * s : 0) +
          1;
      tp.dispose();
    }
    return width;
  }

  Widget _trayCard(
    LabPalette p,
    double s,
    String title,
    Color accent,
    Color ink,
    double maxWidth,
    bool icons,
  ) {
    final sc = _scene.scenario;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: LabGlassCard(
        key: _trayKey,
        palette: p,
        padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 8 * s),
        radius: 12,
        borderColor: accent.withValues(alpha: 0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: labLetterSpacing(title, 1.2),
              ),
            ),
            SizedBox(height: 5 * s),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: _chipSpacing * s,
              runSpacing: _chipSpacing * s,
              children: sc == 0
                  ? [
                      for (final st in _trayOrder)
                        _chip<_Stage>(
                          st,
                          id: st.name,
                          label: _t(st.chipKey),
                          color: st.color,
                          placed: st.index < _scene.filled,
                          s: s,
                          icon: icons,
                        ),
                    ]
                  : [
                      for (final o in _Org.values)
                        _chip<_Org>(
                          o,
                          id: 'org-${o.name}',
                          label: _t(o.chipKey),
                          color: o.color,
                          placed: o.index < _scene.placed,
                          s: s,
                          icon: icons,
                        ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  /// One draggable tray card (HTML `.draggable-item`): it fades while it is
  /// dragged and stays faded, no longer draggable, once placed.
  Widget _chip<T extends Object>(
    T data, {
    required String id,
    required String label,
    required Color color,
    required bool placed,
    required double s,
    required bool icon,
  }) {
    Widget view({bool lifted = false, bool dim = false}) => _ChipView(
      label: label,
      color: color,
      scale: s,
      lifted: lifted,
      dim: dim,
      placed: placed,
      icon: icon,
    );
    return Draggable<T>(
      key: ValueKey('ch10a6-chip-$id'),
      data: data,
      maxSimultaneousDrags: placed || !_lab.isLabActive ? 0 : 1,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      // HTML `onDragStart`: click tone.
      onDragStarted: _Sound.click.play,
      onDragEnd: (_) => _clearHover(),
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: view(lifted: true),
        ),
      ),
      childWhenDragging: view(dim: true),
      child: view(),
    );
  }

  /// HTML timeline: five drop slots joined by lines. On a narrow canvas
  /// the lines and then the slots get shorter (not below a 48 dp target);
  /// past that (a wide sidebar on a small phone) the row scales down.
  Widget _timeline(LabPalette p, double s) {
    return LayoutBuilder(
      builder: (context, box) {
        final pad = 10 * s;
        var slot = _slotSize(s);
        var gap = _lineLength * s;
        double row() =>
            _stageCount * slot + (_stageCount - 1) * (gap + 2 * _lineMargin);
        if (box.maxWidth.isFinite) {
          final room = box.maxWidth - 2 * (pad + _cardBorder);
          if (row() > room) {
            gap = _lineMin;
            slot = math.max(
              kMinInteractiveDimension,
              math.min(
                slot,
                (room - (_stageCount - 1) * (gap + 2 * _lineMargin)) /
                    _stageCount,
              ),
            );
          }
        }
        return LabGlassCard(
          key: _timelineKey,
          palette: p,
          padding: EdgeInsets.all(pad),
          radius: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _stageCount; i++) ...[
                  if (i > 0)
                    Container(
                      width: gap,
                      height: 3,
                      margin: const EdgeInsets.symmetric(
                        horizontal: _lineMargin,
                      ),
                      decoration: BoxDecoration(
                        color: _Colors.slate400.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  _slot(i, slot, p, s),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// One timeline slot (HTML `.drop-slot`): dashed while empty, highlighted
  /// while a card is over it, green with the stage's name once filled, red
  /// and shaking after a wrong drop.
  Widget _slot(int i, double size, LabPalette p, double s) {
    final sc = _scene;
    final filled = i < sc.filled;
    final playing = sc.playing && sc.playStage == i;
    return DragTarget<_Stage>(
      key: ValueKey('ch10a6-slot-${i + 1}'),
      onWillAcceptWithDetails: (_) => _lab.isLabActive,
      onAcceptWithDetails: (d) => _dropOnSlot(i, d.data),
      builder: (context, candidates, rejected) {
        final hover = candidates.isNotEmpty;
        return TweenAnimationBuilder<double>(
          key: ValueKey('ch10a6-shake-$i-${_shakes[i]}'),
          tween: Tween(begin: _shakes[i] == 0 ? 1.0 : 0.0, end: 1.0),
          duration: _shakeDuration,
          builder: (context, t, _) => Transform.translate(
            offset: Offset(_shakeOffset(t) * s, 0),
            child: _SlotView(
              size: size,
              scale: s,
              palette: p,
              label: labFormat(_t('slot_n'), {'n': i + 1}),
              name: filled ? _t(_Stage.values[i].slotKey) : null,
              hover: hover && !filled,
              error: t < 1,
              playing: playing,
            ),
          ),
        );
      },
    );
  }

  /// Sidebar: the HTML "Current Phase" card and the observations of the
  /// steps done so far (the HTML accordion showed every step's observation
  /// before it was made).
  Widget _sidebarExtra(LabPalette p, double f) {
    final s = _scene;
    final steps = _scenarioData.steps;
    final String phase;
    final int done;
    if (s.scenario == 0) {
      final st = s.displayStage;
      phase = st < 0 ? _t('phase_none') : _t(_Stage.values[st].phaseKey);
      done = s.concluded[0] ? steps.length : s.filled;
    } else {
      phase = s.orgShown < 0
          ? _t('phase_none')
          : _t(_Org.values[s.orgShown].phaseKey);
      done = s.concluded[1] ? steps.length : s.placed;
    }
    return _SidebarExtra(
      palette: p,
      scale: f,
      phaseLabel: _t('phase_title'),
      phase: phase,
      empty: _t('obs_empty'),
      entries: [
        for (var i = 1; i <= done.clamp(0, steps.length); i++)
          (labFormat(_t('obs_step'), {'n': i}), steps[i - 1].observation),
      ],
    );
  }
}

/// A tray card. Built without the shell's style scope so it can also be the
/// drag feedback; colours fade by alpha (no Opacity layer). Without [icon]
/// (small phones) a placed card is shown only faded, as in the HTML.
class _ChipView extends StatelessWidget {
  const _ChipView({
    required this.label,
    required this.color,
    required this.scale,
    this.lifted = false,
    this.dim = false,
    this.placed = false,
    this.icon = true,
  });

  final String label;
  final Color color;
  final double scale;
  final bool lifted;
  final bool dim;
  final bool placed;

  /// Shows the drag handle (the check mark once placed) before the label.
  final bool icon;

  /// The label's style at UI scale [s] (also used to measure the tray).
  static TextStyle textStyle(double s, Color color) => TextStyle(
    color: color,
    fontSize: 11.5 * s,
    fontWeight: FontWeight.w900,
    height: 1.15,
    fontFamily: LabFont.active.family,
    fontFamilyFallback: LabFont.active.fallback,
    decoration: TextDecoration.none,
  );

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final alpha = placed ? 0.3 : (dim ? 0.5 : 1.0);
    final fg = _Colors.white.withValues(alpha: placed ? 0.75 : 1);
    return Container(
      constraints: BoxConstraints(minHeight: _chipHeight(s)),
      padding: EdgeInsets.symmetric(horizontal: _chipPadX * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(9 * s),
        border: lifted
            ? Border.all(color: _Colors.white.withValues(alpha: 0.7), width: 2)
            : null,
        boxShadow: placed || dim
            ? null
            : [
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: lifted ? 14 : 4,
                  offset: Offset(0, lifted ? 6 : 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon) ...[
            Icon(
              placed ? Icons.check_circle : Icons.drag_indicator,
              size: _chipIcon * s,
              color: fg,
            ),
            SizedBox(width: _chipIconGap * s),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle(s, fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// A timeline slot's face (see `_FrogLabState._slot`).
class _SlotView extends StatelessWidget {
  const _SlotView({
    required this.size,
    required this.scale,
    required this.palette,
    required this.label,
    required this.name,
    required this.hover,
    required this.error,
    required this.playing,
  });

  final double size;
  final double scale;
  final LabPalette palette;
  final String label;

  /// The stage's name once the slot is filled.
  final String? name;
  final bool hover;
  final bool error;

  /// The time-lapse shows this slot's stage.
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final filled = name != null;
    final Color fill;
    final Color edge;
    var dashed = false;
    if (error) {
      fill = _Colors.red500.withValues(alpha: 0.2);
      edge = _Colors.red500;
    } else if (playing) {
      fill = _Colors.amber400.withValues(alpha: 0.22);
      edge = _Colors.amber400;
    } else if (filled) {
      fill = _Colors.green500.withValues(alpha: 0.15);
      edge = _Colors.green500;
    } else if (hover) {
      fill = _Colors.indigo500.withValues(alpha: 0.2);
      edge = _Colors.indigo400;
      dashed = true;
    } else {
      fill = (p.isDark ? _Colors.slate800 : _Colors.slate200).withValues(
        alpha: 0.5,
      );
      edge = _Colors.slate400.withValues(alpha: 0.6);
      dashed = true;
    }
    final Widget face = filled
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16 * s,
                color: p.ink(_Colors.green500),
              ),
              SizedBox(height: 1 * s),
              Text(
                name!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.textStrong,
                  fontSize: 8.5 * s,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          )
        : Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: error ? _Colors.red500 : p.textMuted,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          );
    return AnimatedScale(
      scale: hover ? 1.06 : 1,
      duration: const Duration(milliseconds: 200),
      child: CustomPaint(
        painter: _SlotBorderPainter(
          fill: fill,
          edge: edge,
          dashed: dashed,
          width: playing ? 3 : 2,
        ),
        child: SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.all(3 * s),
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: face),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded slot box with a solid or dashed border (HTML `border-2
/// border-dashed`).
class _SlotBorderPainter extends CustomPainter {
  _SlotBorderPainter({
    required this.fill,
    required this.edge,
    required this.dashed,
    required this.width,
  });

  final Color fill;
  final Color edge;
  final bool dashed;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = edge;
    if (dashed) {
      labDashedPath(canvas, Path()..addRRect(rrect), pen, dash: 6, gap: 4);
    } else {
      canvas.drawRRect(rrect, pen);
    }
  }

  @override
  bool shouldRepaint(_SlotBorderPainter old) =>
      old.fill != fill ||
      old.edge != edge ||
      old.dashed != dashed ||
      old.width != width;
}

/// The sidebar's "Current Phase" card and observation list.
class _SidebarExtra extends StatelessWidget {
  const _SidebarExtra({
    required this.palette,
    required this.scale,
    required this.phaseLabel,
    required this.phase,
    required this.empty,
    required this.entries,
  });

  final LabPalette palette;
  final double scale;
  final String phaseLabel;
  final String phase;
  final String empty;

  /// (step heading, observation text), in step order.
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final box = BoxDecoration(
      color: p.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: p.cardBorder),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // HTML `#stage-overlay` ("Current Phase").
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * f, vertical: 8 * f),
          decoration: box.copyWith(
            border: Border.all(color: _Colors.green500.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.cyclone, size: 18 * f, color: p.ink(_Colors.green500)),
              SizedBox(width: 8 * f),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phaseLabel.toUpperCase(),
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 9 * f,
                        fontWeight: FontWeight.w800,
                        letterSpacing: labLetterSpacing(phaseLabel, 0.8),
                      ),
                    ),
                    SizedBox(height: 2 * f),
                    Text(
                      phase,
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 12 * f,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * f),
        Container(
          padding: EdgeInsets.all(10 * f),
          decoration: box,
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
        ),
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

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background, bench, pond or habitat ground) and the label text painters.
/// Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;
  _Framing? _backdropFraming;

  double get labelSize => _labelSize;

  /// Label chip padding (x, y) and corner radius, as fractions of the label
  /// size (HTML sprite: 6 px inset, radius 14 on a 64 px canvas).
  static const double _padX = 0.75;
  static const double _padY = 0.38;
  static const double _radius = 0.55;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  /// Text of a label in [color] (bold, HTML `bold 20px`).
  TextPainter label(String text, Color color) =>
      _labels['${color.toARGB32()}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: _labelSize,
            fontWeight: FontWeight.w800,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Size of the chip around [text].
  Size chipSize(String text) {
    final tp = label(text, _Colors.white);
    return Size(
      tp.width + 2 * _padX * _labelSize,
      tp.height + 2 * _padY * _labelSize,
    );
  }

  /// The static part of [scenario]'s scene in [framing], recorded once.
  ui.Picture backdrop(int scenario, bool dark, _Framing framing, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark &&
        framing == _backdropFraming) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, _Cam(framing), size, pens);
    _backdropScenario = scenario;
    _backdropDark = dark;
    _backdropFraming = framing;
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

/// [v] turned by [yaw] about the y axis (Three.js `rotation.y`).
_V _yawed(_V v, double yaw) {
  if (yaw == 0) return v;
  final c = math.cos(yaw), s = math.sin(yaw);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

/// Convex hull of [pts] (monotone chain).
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

/// Segments of rims and discs (smooth enough at this size).
const int _ringSides = 32;

/// Mesh drawing in one camera's projection.
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

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color, {Color? edge, double edgeWidth = 1}) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = edgeWidth
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c], turned by [yaw]: the faces seen by the
  /// camera, lit, with darker rims.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    double yaw = 0,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final f = face.normal;
      final n = _yawed(f, yaw);
      final mid = c + _yawed(_V(f.x * hx, f.y * hy, f.z * hz), yaw);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _yawed(_V(k.x * hx, k.y * hy, k.z * hz), yaw)));
      }
      path.close();
      final lit = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = lit);
      if (opacity >= 1) canvas.drawPath(path, pens.seam..color = lit);
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// SphereGeometry of radius 1 scaled by [radii]: a lit oval (its outline
  /// as seen from the tilted camera), shaded away from the key light, with
  /// a highlight. [roll] turns it with its model.
  void ellipsoid(
    _V c,
    _V radii,
    Color color, {
    double opacity = 1,
    double roll = 0,
    bool highlight = true,
  }) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    final rx = radii.x * k;
    final ry =
        math.sqrt(
          math.pow(radii.y * _cosPitch, 2) + math.pow(radii.z * _sinPitch, 2),
        ) *
        k;
    if (rx < 0.3 || ry < 0.3) return;
    canvas.save();
    canvas.translate(o.dx, o.dy);
    if (roll != 0) canvas.rotate(-roll);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 2 * rx, height: 2 * ry),
      pens.fill..color = labShade(color, -0.32).withValues(alpha: opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rx * 0.1, -ry * 0.12),
        width: 1.72 * rx,
        height: 1.7 * ry,
      ),
      pens.fill..color = color.withValues(alpha: opacity),
    );
    if (highlight) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rx * 0.32, -ry * 0.4),
          width: 0.5 * rx,
          height: 0.36 * ry,
        ),
        pens.fill
          ..color = labShade(color, 0.45).withValues(alpha: 0.85 * opacity),
      );
    }
    canvas.restore();
  }

  /// A round, tapered rod (CylinderGeometry) from [a] (radius [ra]) to [b]
  /// (radius [rb]), with a highlight along its lit side.
  void rod(_V a, _V b, double ra, double rb, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.7, ra * cam.scaleAt(a));
    final wb = math.max(0.7, rb * cam.scaleAt(b));
    final base = labShade(color, -0.12);
    pens.fill.color = base;
    canvas.drawCircle(pa, wa, pens.fill);
    canvas.drawCircle(pb, wb, pens.fill);
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    var n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas.drawPath(path, pens.fill);
    if (n.dy > 0) n = -n; // towards the key light (above)
    final hw = math.max(0.6, (wa + wb) * 0.18);
    canvas.drawLine(
      pa + n * (wa * 0.45),
      pb + n * (wb * 0.45),
      pens.stroke
        ..strokeWidth = hw
        ..color = labShade(color, 0.32),
    );
  }

  /// A flat disc of radius [r] lying at [c] (lily pads, the pond's top).
  void disc(_V c, double r, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(path, i, cam.p(c + _V(math.cos(a) * r, 0, math.sin(a) * r)));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// Soft blurred shadow of an elliptic footprint at height [y].
  void shadow(_V c, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(path, i, cam.p(c + _V(math.cos(a) * rx, 0, math.sin(a) * rz)));
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// An upright CylinderGeometry of radius [r] from [base] up [h]: its
  /// silhouette in the side colour, then its lit top (the pond).
  void uprightCylinder(_V base, double r, double h, Color color, double alpha) {
    final pts = <Offset>[];
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      final d = _V(math.cos(a) * r, 0, math.sin(a) * r);
      pts
        ..add(cam.p(base + d))
        ..add(cam.p(base + d + _V(0, h, 0)));
    }
    final hull = _hull(pts);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(0, 0, 1), opacity: alpha),
    );
    disc(
      base + _V(0, h, 0),
      r,
      _lit(color, _V.up, opacity: alpha).withValues(alpha: alpha),
    );
  }

  /// The ramp of [section] points (x, y) extruded from z0 to z1: its front
  /// face and the faces turned to the camera, lit.
  void prism(List<Offset> section, double z0, double z1, Color color) {
    final n = section.length;
    for (var i = 0; i < n; i++) {
      final a = section[i], b = section[(i + 1) % n];
      // Outward normal of a counter-clockwise section.
      final e = b - a;
      final normal = _V(e.dy, -e.dx, 0).unit;
      final mid = _V((a.dx + b.dx) / 2, (a.dy + b.dy) / 2, (z0 + z1) / 2);
      if (normal.dot(cam.eye - mid) <= 0) continue;
      final lit = _lit(color, normal);
      poly([
        _V(a.dx, a.dy, z0),
        _V(b.dx, b.dy, z0),
        _V(b.dx, b.dy, z1),
        _V(a.dx, a.dy, z1),
      ], lit);
      canvas.drawPath(pens.path, pens.seam..color = lit);
    }
    final front = _lit(color, const _V(0, 0, 1));
    poly([for (final p in section) _V(p.dx, p.dy, z1)], front);
    canvas.drawPath(pens.path, pens.seam..color = front);
  }
}

/// The scene's static layer: background, the bench and the pond (S1) or the
/// habitat ground: bench, sand, bank ramp, dry land and rocks (S2).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  _Cam cam,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final g = _Gfx(canvas, cam, pens);
  g.box(_benchCenter, _benchSize, _Colors.bench, edge: 0.45);
  if (scenario == 0) {
    // HTML pondWater: `CylinderGeometry(8, 8, 1)`, opacity 0.55.
    g.uprightCylinder(_V.zero, _pondRadius, _pondTop, _Colors.water, 0.55);
    return;
  }
  // Sand bed under the deep water (HTML `sandbed`).
  g.poly([
    const _V(_waterLeft, 0.02, -_habitatHalfZ),
    const _V(_waterRight, 0.02, -_habitatHalfZ),
    const _V(_waterRight, 0.02, _habitatHalfZ),
    const _V(_waterLeft, 0.02, _habitatHalfZ),
  ], _lit(_Colors.sand, _V.up));
  // The muddy bank ramp, then the dry land over its right end.
  g.prism(
    const [
      Offset(_rampX0, 0),
      Offset(_landLeft, 0),
      Offset(_landLeft, _landTop),
      Offset(_rampX0, _rampY0),
    ],
    -_habitatHalfZ,
    _habitatHalfZ,
    _Colors.mud,
  );
  g.box(
    const _V((_landLeft + _landRight) / 2, _landTop / 2, 0),
    const _V(_landRight - _landLeft, _landTop, 2 * _habitatHalfZ),
    _Colors.grass,
    edge: 0.3,
  );
  for (final (x, z, r) in _rocks) {
    g.ellipsoid(_V(x, _rampY(x) + r * 0.5, z), _V(r, r * 0.8, r), _Colors.rock);
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the pond with
/// the stage placed last (or the time-lapse), S2 the habitats with the
/// animal placed last, the drop highlights and the labels.
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

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(s.scenario, isDark, s.framing, size));
    final g = _Gfx(canvas, _Cam(s.framing), cache.pens);
    if (s.scenario == 0) {
      _paintPond(g);
    } else {
      _paintHabitats(g);
    }
    _paintConfetti(canvas);
  }

  /// HTML `confetti(...)` with the summary.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 == null) return;
    final ticks = (s.time - t0) * 60;
    if (ticks < 0 || ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    final pen = cache.pens.fill;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      canvas.save();
      canvas.translate(
        _confettiOrigin.dx + math.cos(c.angle) * d,
        _confettiOrigin.dy + math.sin(c.angle) * d + fall,
      );
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        _confettiPiece,
        pen..color = c.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  /// Growth of a model that appeared at [since] (0 → 1, overshooting a
  /// little).
  double _pop(double since) {
    final t = ((scene.time - since) / _popSeconds).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(t);
  }

  // ------------------------------------------------------------ scenario 1

  void _paintPond(_Gfx g) {
    final s = scene;
    final shown = s.displayStage;
    if (shown < 0) return;
    final stage = _Stage.values[shown];
    final bob = math.sin(s.time * _bobRate) * _bobAmp;
    final pose = _Pose(_V(0, stage.y + bob, 0)).scaled(_pop(s.shownAt));
    if (pose.scale <= 0.01) return;
    // Contact shadow on the water.
    g.shadow(
      const _V(0, _pondTop + 0.01, 0),
      pose.r(stage == _Stage.eggs ? 2.2 : 2.8),
      pose.r(1.8),
    );
    _paintStage(g, stage, pose, s.time);
    if (showLabels) {
      _chip(
        g.canvas,
        _t(stage.labelKey),
        g.cam.p(_V(0, stage.labelY, 0)),
        anchor: Alignment.bottomCenter,
      );
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _paintHabitats(_Gfx g) {
    final s = scene;
    final org = s.orgShown < 0 ? null : _Org.values[s.orgShown];
    final grow = _pop(s.orgShownAt);
    // The tadpole swims under the water, so it is drawn before it.
    if (org == _Org.tadpole) {
      _paintTadpole(g, org!.pose.scaled(grow), s.time, legs: false);
    }
    _paintWater(g);
    // Back bushes, the animal on the bank or the land, the front bush.
    g.ellipsoid(_bushes[0].$1, _bushes[0].$2, _Colors.bush);
    g.ellipsoid(_bushes[1].$1, _bushes[1].$2, _Colors.bush);
    if (org == _Org.froglet) {
      final pose = org!.pose.scaled(grow);
      g.shadow(_V(pose.origin.x, _rampY(pose.origin.x) + 0.02, 0.5), 2.2, 1.6);
      _paintFroglet(g, pose);
    } else if (org == _Org.adult) {
      final pose = org!.pose.scaled(grow);
      // An occasional hop in place ("hop on dry land").
      final phase = (s.time - s.orgShownAt) % _hopEvery;
      final hop = phase < _hopSeconds
          ? math.sin(phase / _hopSeconds * math.pi) * _hopHeight
          : 0.0;
      g.shadow(
        _V(pose.origin.x, _landTop + 0.02, 0),
        2.6 * (1 - hop * 0.2),
        1.8,
      );
      _paintAdult(g, pose.lifted(hop), s.time);
    }
    g.ellipsoid(_bushes[2].$1, _bushes[2].$2, _Colors.bush);
    _paintZones(g);
    if (showLabels && org != null) {
      _chip(
        g.canvas,
        _t(org.phaseKey),
        g.cam.p(org.labelAt),
        anchor: Alignment.bottomCenter,
      );
    }
  }

  /// HTML `deepWater` (opacity 0.65): its top and front faces over the sand
  /// and the tadpole, then the lily pads.
  void _paintWater(_Gfx g) {
    const alpha = 0.55;
    g.poly(const [
      _V(_waterLeft, 0, _habitatHalfZ),
      _V(_waterRight, 0, _habitatHalfZ),
      _V(_waterRight, _waterTop, _habitatHalfZ),
      _V(_waterLeft, _waterTop, _habitatHalfZ),
    ], _lit(_Colors.water, const _V(0, 0, 1), opacity: alpha));
    g.poly(
      const [
        _V(_waterLeft, _waterTop, -_habitatHalfZ),
        _V(_waterRight, _waterTop, -_habitatHalfZ),
        _V(_waterRight, _waterTop, _habitatHalfZ),
        _V(_waterLeft, _waterTop, _habitatHalfZ),
      ],
      _lit(_Colors.water, _V.up, opacity: alpha),
      edge: _Colors.white.withValues(alpha: 0.25),
    );
    for (final pad in _lilyPads) {
      g.disc(pad, 0.8, _lit(_Colors.lilyPad, _V.up));
    }
  }

  /// HTML `.habitat-zone.drag-over` (dashed indigo border, indigo/10 fill
  /// and the zone's name) and `.shake-error` (red) on the habitats, and the
  /// habitat names on the bench.
  void _paintZones(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final pens = g.pens;
    final errorT = (s.time - s.errorAt) / _shakeSeconds;
    final error = errorT >= 0 && errorT < 1 ? s.errorZone : -1;
    for (final z in _Zone.values) {
      final hovered = s.hoverZone == z.index;
      final failed = error == z.index;
      if (!hovered && !failed) continue;
      var r = _Scene.zoneRect(g.cam, z).deflate(4);
      if (failed) r = r.shift(Offset(_shakeOffset(errorT), 0));
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(18));
      final color = failed ? _Colors.red500 : _Colors.indigo500;
      canvas.drawRRect(
        rr,
        pens.fill..color = color.withValues(alpha: failed ? 0.2 : 0.1),
      );
      labDashedPath(
        canvas,
        Path()..addRRect(rr),
        pens.stroke
          ..strokeWidth = 4
          ..color = color.withValues(alpha: 0.6),
        dash: 12,
        gap: 8,
      );
    }
    if (!showLabels && s.hoverZone < 0) return;
    for (final z in _Zone.values) {
      final hovered = s.hoverZone == z.index;
      if (!showLabels && !hovered) continue;
      _chip(
        canvas,
        _t(z.key),
        g.cam.p(z.chipAt),
        anchor: Alignment.topCenter,
        background: hovered ? z.fill.withValues(alpha: 0.95) : z.fill,
        border: hovered ? _Colors.white : z.edge,
        ink: _Colors.white,
      );
    }
  }

  // ---------------------------------------------------------------- models

  void _paintStage(_Gfx g, _Stage stage, _Pose pose, double t) {
    switch (stage) {
      case _Stage.eggs:
        _paintEggs(g, pose);
      case _Stage.tadpole:
        _paintTadpole(g, pose, t, legs: false);
      case _Stage.legs:
        _paintTadpole(g, pose, t, legs: true);
      case _Stage.froglet:
        _paintFroglet(g, pose);
      case _Stage.adult:
        _paintAdult(g, pose, t);
    }
  }

  /// HTML `s1SpawnGrp`: jelly spheres (opacity 0.65) with dark embryos.
  void _paintEggs(_Gfx g, _Pose pose) {
    for (final e in _eggSpots) {
      final c = pose.at(e);
      g.ellipsoid(
        c,
        _V(pose.r(0.5), pose.r(0.5), pose.r(0.5)),
        _Colors.jelly,
        opacity: 0.6,
        highlight: false,
      );
      g.ellipsoid(
        c,
        _V(pose.r(0.2), pose.r(0.2), pose.r(0.2)),
        _Colors.embryo,
        opacity: 0.9,
        highlight: false,
      );
      // Glint on the jelly.
      final o = g.cam.p(c + _V(pose.r(0.18), pose.r(0.22), 0));
      g.canvas.drawCircle(
        o,
        math.max(0.6, pose.r(0.09) * g.cam.scaleAt(c)),
        g.pens.fill..color = _Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  /// HTML `s1TadpoleGrp` (head `SphereGeometry(1.4)` scaled (1.4, 1, 1),
  /// tail `CylinderGeometry(0.5, 0.08, 5)` behind it) and `s1WithLegsGrp`
  /// (head 1.5, tail (0.45, 0.08, 4.5), two hind legs `CylinderGeometry(0.2,
  /// 0.15, 2.2)` at (-1, -1, ±1) turned by -0.5). The HTML tails were thick
  /// at the tip; here they taper away from the body and wave.
  void _paintTadpole(_Gfx g, _Pose pose, double t, {required bool legs}) {
    final headR = legs ? 1.5 : 1.4;
    final head = legs ? _Colors.frogDark : _Colors.tadpoleHead;
    final tail = legs ? _Colors.frog : _Colors.tadpoleTail;
    final tailLen = legs ? 4.5 : 5.0;
    final tailR = legs ? 0.45 : 0.5;
    final wag = math.sin(t * _wagRate);
    if (legs) _hindLeg(g, pose, -1);
    const base = _V(-1, 0, 0);
    final mid = _V(base.x - tailLen * 0.5, 0, wag * 0.25);
    final tip = _V(base.x - tailLen, 0, wag * 0.7);
    g.rod(
      pose.at(base),
      pose.at(mid),
      pose.r(tailR),
      pose.r(tailR * 0.55),
      tail,
    );
    g.rod(pose.at(mid), pose.at(tip), pose.r(tailR * 0.55), pose.r(0.08), tail);
    g.ellipsoid(
      pose.at(_V.zero),
      _V(pose.r(headR * 1.4), pose.r(headR), pose.r(headR)),
      head,
      roll: pose.roll,
    );
    _eyes(g, pose, _V(headR * 1.05, headR * 0.45, headR * 0.5), 0.22);
    if (legs) _hindLeg(g, pose, 1);
  }

  void _hindLeg(_Gfx g, _Pose pose, double side) {
    final (hip, foot) = _rodEnds(_V(-1, -1, side), 2.2, rz: -0.5);
    g.rod(
      pose.at(hip),
      pose.at(foot),
      pose.r(0.2),
      pose.r(0.15),
      _Colors.frogLight,
    );
  }

  /// Small dark eyes (added; the HTML tadpoles and froglet had none).
  void _eyes(_Gfx g, _Pose pose, _V at, double r) {
    for (final side in const [-1.0, 1.0]) {
      final c = pose.at(_V(at.x, at.y, at.z * side));
      final rr = _V(pose.r(r), pose.r(r), pose.r(r));
      g.ellipsoid(c, rr, _Colors.eyeWhite, highlight: false);
      g.ellipsoid(
        pose.at(_V(at.x + r * 0.35, at.y, at.z * side)),
        rr * 0.55,
        _Colors.pupil,
        highlight: false,
      );
    }
  }

  /// HTML `s1FrogletGrp`: body `SphereGeometry(1.6)` scaled (1.3, 0.9, 1.1),
  /// a tail stub `CylinderGeometry(0.3, 0.05, 1.5)` (thick end at the
  /// body), front legs (0.2, 0.15, 2) at (0.8, -1.2, ±1.1) and hind legs
  /// (0.25, 0.18, 2.5) at (-1, -1.2, ±1.2).
  void _paintFroglet(_Gfx g, _Pose pose) {
    void legs(double side) {
      final (fTop, fEnd) = _rodEnds(_V(0.8, -1.2, 1.1 * side), 2);
      g.rod(
        pose.at(fTop),
        pose.at(fEnd),
        pose.r(0.2),
        pose.r(0.15),
        _Colors.frogLight,
      );
      final (hTop, hEnd) = _rodEnds(_V(-1, -1.2, 1.2 * side), 2.5);
      g.rod(
        pose.at(hTop),
        pose.at(hEnd),
        pose.r(0.25),
        pose.r(0.18),
        _Colors.frog,
      );
    }

    legs(-1);
    g.rod(
      pose.at(const _V(-1.6, 0, 0)),
      pose.at(const _V(-2.85, 0, 0)),
      pose.r(0.3),
      pose.r(0.05),
      _Colors.frog,
    );
    g.ellipsoid(
      pose.at(_V.zero),
      _V(pose.r(1.6 * 1.3), pose.r(1.6 * 0.9), pose.r(1.6 * 1.1)),
      _Colors.frogLight,
      roll: pose.roll,
    );
    _eyes(g, pose, const _V(1.55, 0.85, 0.6), 0.26);
    legs(1);
  }

  /// HTML `s1AdultGrp`: body, snout, back spots, yellow eyes with slit
  /// pupils, the vocal sac (pulsing), front legs with feet and jointed hind
  /// legs (thigh, calf, webbed foot); far side first.
  void _paintAdult(_Gfx g, _Pose pose, double t) {
    void hind(double side) {
      final (hip, knee) = _rodEnds(
        _V(-1, -0.2, 1.4 * side),
        2.2,
        rz: -1.0,
        rx: 0.5 * side,
      );
      g.rod(
        pose.at(hip),
        pose.at(knee),
        pose.r(0.4),
        pose.r(0.3),
        _Colors.frogDark,
      );
      final (calfTop, calfEnd) = _rodEnds(
        _V(-1.5, -1.5, 1.6 * side),
        2.2,
        rz: 0.5,
      );
      g.rod(
        pose.at(calfTop),
        pose.at(calfEnd),
        pose.r(0.25),
        pose.r(0.2),
        _Colors.frog,
      );
      g.box(
        pose.at(_V(-0.5, -2.4, 1.8 * side)),
        _V(pose.r(1.2), pose.r(0.1), pose.r(1.0)),
        _Colors.frog,
        edge: 0.2,
      );
    }

    void front(double side) {
      final (top, end) = _rodEnds(
        _V(1.2, -1.4, 1.2 * side),
        2.2,
        rz: -0.2,
        rx: -0.2 * side,
      );
      g.rod(
        pose.at(top),
        pose.at(end),
        pose.r(0.2),
        pose.r(0.15),
        _Colors.frogLight,
      );
      g.box(
        pose.at(_V(1.4, -2.4, 1.5 * side)),
        _V(pose.r(0.6), pose.r(0.1), pose.r(0.8)),
        _Colors.frogLight,
        edge: 0.2,
        yaw: 0.2 * side,
      );
    }

    hind(-1);
    front(-1);
    g.ellipsoid(
      pose.at(_V.zero),
      _V(pose.r(1.8 * 1.4), pose.r(1.8 * 0.8), pose.r(1.8 * 1.2)),
      _Colors.frog,
      roll: pose.roll,
    );
    g.ellipsoid(
      pose.at(const _V(1.5, 0.2, 0)),
      _V(pose.r(1.2), pose.r(0.7), pose.r(1.0)),
      _Colors.frog,
      roll: pose.roll,
    );
    // Vocal sac: `1 + sin(t * 8) * 0.3`, scaled (sc, 0.6 sc, sc).
    final sc = 1 + math.sin(t * _sacRate) * _sacAmp;
    g.ellipsoid(
      pose.at(const _V(1.5, -0.5, 0)),
      _V(pose.r(sc), pose.r(0.6 * sc), pose.r(sc)),
      _Colors.sac,
      opacity: 0.9,
    );
    // Dark spots on the back (flattened spheres turned upwards).
    for (final spot in const [
      _V(-0.5, 1.2, 0.5),
      _V(0.2, 1.3, -0.6),
      _V(-1.0, 1.0, -0.4),
      _V(0.8, 1.1, 0.4),
      _V(-0.2, 1.4, 0),
    ]) {
      g.ellipsoid(
        pose.at(spot),
        _V(pose.r(0.25), pose.r(0.075), pose.r(0.25)),
        _Colors.frogSpot,
        highlight: false,
      );
    }
    // Eyes `SphereGeometry(0.45)` with slit pupils (0.2 scaled (0.4, 1, 1))
    // 0.3 in front.
    for (final side in const [-1.0, 1.0]) {
      g.ellipsoid(
        pose.at(_V(1.6, 1.0, 0.7 * side)),
        _V(pose.r(0.45), pose.r(0.45), pose.r(0.45)),
        _Colors.eye,
      );
      g.ellipsoid(
        pose.at(_V(1.9, 1.0, 0.7 * side)),
        _V(pose.r(0.08), pose.r(0.2), pose.r(0.2)),
        _Colors.pupil,
        highlight: false,
      );
    }
    front(1);
    hind(1);
  }

  // ---------------------------------------------------------------- labels

  /// A label chip (HTML `createTextSprite`: rounded box, border, bold text)
  /// with [anchor] at [at], kept inside the free part of the stage.
  void _chip(
    Canvas canvas,
    String text,
    Offset at, {
    Alignment anchor = Alignment.center,
    Color? background,
    Color? border,
    Color? ink,
  }) {
    final fg = ink ?? (isDark ? _Colors.white : _Colors.slate900);
    final tp = cache.label(text, fg);
    final size = cache.labelSize;
    final w = tp.width + 2 * _PaintCache._padX * size;
    final h = tp.height + 2 * _PaintCache._padY * size;
    var left = at.dx - (anchor.x + 1) / 2 * w;
    final top = at.dy - (anchor.y + 1) / 2 * h;
    final bounds = scene.labelBounds;
    if (bounds.width > w) {
      left = left.clamp(bounds.left, bounds.right - w);
    }
    final rect = Rect.fromLTWH(left, top, w, h);
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(_PaintCache._radius * size),
    );
    final pens = cache.pens;
    canvas.drawRRect(
      rr,
      pens.fill
        ..color =
            background ?? (isDark ? _Colors.labelBgDark : _Colors.labelBgLight),
    );
    canvas.drawRRect(
      rr,
      pens.stroke
        ..strokeWidth = 1.5
        ..color = border ?? (isDark ? _Colors.slate600 : _Colors.slate300),
    );
    tp.paint(
      canvas,
      Offset(left + _PaintCache._padX * size, top + _PaintCache._padY * size),
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
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
