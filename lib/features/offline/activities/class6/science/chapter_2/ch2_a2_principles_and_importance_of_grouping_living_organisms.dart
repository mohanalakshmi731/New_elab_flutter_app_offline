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

/// Class 6 Science • Chapter 2 • Activity 2
/// Principles and Importance of Grouping Living Organisms ("Principles of
/// Grouping Organisms").
///
/// Native Flutter port of
/// `Cl6S-Ch02-A2-Principles_and_Importance_of_Grouping_Living_Organisms.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML camera: position (0, 10, 18), look-at
/// (0, 0, 0), 45° field of view, and its close-ups.
///
/// Scenario 1 (The Virtual Gardener's Challenge): in a virtual park, tap the
/// Tomato plant (the camera zooms in and an inspection card compares its
/// stem with a person), tap 'Got it!', then drag the plant into the 'Herbs'
/// garden plot; then the Rose plant ('Shrubs') and the Mango tree ('Trees').
///
/// Scenario 2 (Habitat Match-Up): the same with three animals and three
/// habitat islands: the Fish (fins, into the Ocean), the Goat (hooves, into
/// the grassy Plain) and the Camel (wide hooves and a hump, into the Desert).
/// 'Review Classification' opens each summary.
class Ch2A2PrinciplesAndImportanceOfGroupingLivingOrganismsPage
    extends StatefulWidget {
  const Ch2A2PrinciplesAndImportanceOfGroupingLivingOrganismsPage({super.key});

  @override
  State<Ch2A2PrinciplesAndImportanceOfGroupingLivingOrganismsPage>
  createState() => _GroupingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'click' (a plant or animal inspected) and 'pop' ('Got it!') → click
/// (`science/click.mp3`), 'success' (a correct drop) → correct, 'error' (a
/// missed or wrong drop) → wrong (`science/error.mp3`), 'chime' (the last
/// drop shows 'Review Classification') and the summary → success (both
/// `math/success.mp3`). The shell plays toggle (`science/dropdown.mp3`),
/// scenario (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; a plant or animal inspected (HTML `click`) and
  /// 'Got it!' (HTML `pop`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A plant or animal dropped into its group (HTML `success`).
  correct('audio/class6/math/success.mp3'),

  /// Missed or wrong drop, or another organism's turn (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// 'Review Classification' appears (HTML `chime`) and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3');

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

/// Colours of the HTML page (Tailwind classes), of its Three.js scene
/// (material colours) and of its SVG icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green900 = Color(0xFF14532D);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow900 = Color(0xFF713F12);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
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
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background` (and fog): 0x0f172a (dark theme), 0xe0f2fe (light
  /// theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// Scenario 1 park: grass ground `0x4ade80` and tufts `0x22c55e`.
  static const Color park = Color(0xFF4ADE80);
  static const Color grass = green500;

  /// Garden plots: dark dirt mound `0x3e2723` and pebbles `0x78716c`.
  static const Color dirt = Color(0xFF3E2723);
  static const Color pebble = Color(0xFF78716C);

  /// Tomato: stem `0x4ade80`, leaves `0x15803d`, fruit `0xef4444`.
  static const Color tomatoStem = Color(0xFF4ADE80);
  static const Color leaf = Color(0xFF15803D);
  static const Color tomato = red500;

  /// Rose: woody stems `0x57534e`, leaves `0x166534`, flowers `0xbe123c`.
  static const Color roseStem = Color(0xFF57534E);
  static const Color roseLeaf = Color(0xFF166534);
  static const Color rose = Color(0xFFBE123C);

  /// Mango: trunk and fruit stems `0x451a03`, canopy `0x15803d`, fruit
  /// `0xf59e0b`.
  static const Color mangoTrunk = Color(0xFF451A03);
  static const Color canopy = leaf;
  static const Color mango = amber500;

  /// Scenario 2 floor `0x1e293b`.
  static const Color floor = slate800;

  /// Habitat islands: plain `0x84cc16`, ocean sea floor `0xfef08a`, desert
  /// and dunes `0xfde047`, water `0x0ea5e9` at 40 % opacity.
  static const Color plain = Color(0xFF84CC16);
  static const Color seaFloor = Color(0xFFFEF08A);
  static const Color desert = Color(0xFFFDE047);
  static const Color water = Color(0xFF0EA5E9);

  /// Ocean: rock `0x64748b`, corals `0xf43f5e` / `0xd946ef`, seaweed
  /// `0x10b981`.
  static const Color seaRock = slate500;
  static const Color coralRed = Color(0xFFF43F5E);
  static const Color coralPink = Color(0xFFD946EF);
  static const Color seaweed = emerald500;

  /// Desert: cactus `0x16a34a`, rocks `0xa8a29e`.
  static const Color cactus = Color(0xFF16A34A);
  static const Color desertRock = Color(0xFFA8A29E);

  /// Plain: tree trunk `0x78350f`, canopy `0x15803d`, grass `0x22c55e`.
  static const Color treeTrunk = amber900;

  /// Fish: body `0x38bdf8`, fins and tail `0x0284c7`.
  static const Color fish = Color(0xFF38BDF8);
  static const Color fin = Color(0xFF0284C7);

  /// Goat: off-white `0xf3f4f6`, brown patch `0x78350f`, hooves and nose
  /// `0x1f2937`, horns `0x5c4033`.
  static const Color goat = Color(0xFFF3F4F6);
  static const Color goatPatch = amber900;
  static const Color hoof = Color(0xFF1F2937);
  static const Color horn = Color(0xFF5C4033);

  /// Camel `0xc2410c` and its hooves `0x78350f`.
  static const Color camel = orange700;
  static const Color camelHoof = amber900;

  /// Eyes: white and black spheres.
  static const Color eyeWhite = white;
  static const Color pupil = black;

  /// Text sprites: `#1e293b` chip, `#6366f1` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = indigo500;
  static const Color chipText = white;

  /// Plot / habitat under a held organism (added: the HTML's highlight
  /// ring is transparent).
  static const Color dropRing = indigo300;

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x4D000000);

  // ------------------------------------------------------- SVG icons
  /// `#f8fafc` and `#6366f1` of the fin, hoof and hump icons.
  static const Color iconLight = Color(0xFFF8FAFC);
  static const Color iconInk = indigo500;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B),
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
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x663730A3), // indigo-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
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
    cardBorder: _Colors.slate300,
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
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x663730A3),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
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
// From the HTML `i18n`, `ScenariosData`, `labelDict` and summary tables
// (Telugu dropped). `sN_hud_M` are the HTML "Current Task" lines (CLICK →
// TAP), `sN_act_M` / `sN_focus_M` / `sN_obs_M` / `sN_expl_M` the HTML step
// action, concept, observation and explanation, and `sN_step_M` the step
// instructions spelled out for touch (shown until the step is done; the
// HTML grouping actions, "DRAG to 'Herbs' plot.", name the answer). Step 7
// of each scenario is the HTML's seventh HUD line ('Review
// Classification'). Keys marked "added" are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Principles of Grouping Organisms',
    'app_subtitle': 'Class 6 • Diversity in the Living World',
    'scen_1_opt': "Scenario 1: The Virtual Gardener's Challenge",
    'scen_2_opt': 'Scenario 2: Habitat Match-Up',
    's1_desc':
        'Group plants into Herbs, Shrubs, and Trees based on their physical characteristics (height and stem).',
    's2_desc':
        'Group animals into their correct habitats (Aquatic or Terrestrial) based on their adaptations.',
    // The HTML says "On the left … On the right", but its scene puts the
    // plants in front of the plots.
    's1_hud_1':
        "You are in a virtual park. In front, you see a Mango plant, a Rose plant, and a Tomato plant. Behind them, there are three empty, labeled garden plots: 'Herbs', 'Shrubs', and 'Trees'. TAP the Tomato plant to inspect it.",
    's1_hud_2':
        "Now that you have observed the Tomato plant's features, DRAG it and DROP it into the garden plot where you think it belongs.",
    's1_hud_3': 'Great! Now, TAP the Rose plant to inspect its features.',
    's1_hud_4':
        'You know what to do! DRAG the Rose plant and DROP it into the correct garden plot.',
    's1_hud_5': 'Finally, TAP the Mango plant to see its characteristics.',
    's1_hud_6':
        'Complete your garden. DRAG the Mango plant and DROP it into the last remaining plot.',
    // The HTML names a 'Summary' button; its button reads 'Review
    // Classification'.
    's1_hud_7':
        "TAP the 'Review Classification' button to review what you've learned.",
    's2_hud_1':
        'You see three different environments: a sandy Desert, a deep Ocean, and a grassy Plain/Forest. Below them are three animals: a Camel, a Fish, and a Goat. TAP the Fish to see how it is built for its home.',
    's2_hud_2':
        "The fish's fins and body are perfect for swimming. DRAG the Fish and DROP it into the habitat where it can live.",
    's2_hud_3': 'Excellent. Now, TAP the Goat to observe its features.',
    's2_hud_4':
        "The goat's legs are made for walking on land. DRAG the Goat and DROP it into its natural home.",
    's2_hud_5': 'Lastly, TAP the Camel to see its special adaptations.',
    's2_hud_6':
        'Those features are perfect for a specific environment. DRAG the Camel and DROP it into its correct habitat.',
    's2_hud_7':
        "TAP the 'Review Classification' button to review the groupings.",
    's1_step_1': 'TAP the Tomato plant to inspect it.',
    's1_step_2':
        'DRAG the Tomato plant and DROP it into the garden plot where it belongs.',
    's1_step_3': 'TAP the Rose plant to inspect it.',
    's1_step_4':
        'DRAG the Rose plant and DROP it into the garden plot where it belongs.',
    's1_step_5': 'TAP the Mango tree to inspect it.',
    's1_step_6':
        'DRAG the Mango tree and DROP it into the garden plot where it belongs.',
    's1_step_7': "TAP 'Review Classification' to review what you've learned.",
    's2_step_1': 'TAP the Fish to see how it is built for its home.',
    's2_step_2':
        'DRAG the Fish and DROP it into the habitat where it can live.',
    's2_step_3': 'TAP the Goat to observe its features.',
    's2_step_4': 'DRAG the Goat and DROP it into its natural home.',
    's2_step_5': 'TAP the Camel to see its special adaptations.',
    's2_step_6': 'DRAG the Camel and DROP it into its correct habitat.',
    's2_step_7': "TAP 'Review Classification' to review the groupings.",
    's1_act_1': 'TAP the Tomato plant.',
    's1_act_2': "DRAG to 'Herbs' plot.",
    's1_act_3': 'TAP the Rose plant.',
    's1_act_4': "DRAG to 'Shrubs' plot.",
    's1_act_5': 'TAP the Mango tree.',
    's1_act_6': "DRAG to 'Trees' plot.",
    's2_act_1': 'TAP the Fish.',
    's2_act_2': 'DRAG to Ocean.',
    's2_act_3': 'TAP the Goat.',
    's2_act_4': 'DRAG to Plain.',
    's2_act_5': 'TAP the Camel.',
    's2_act_6': 'DRAG to Desert.',
    'focus_observe': 'Observation',
    'focus_group': 'Grouping',
    's1_obs_1': 'Short height, green tender stem.',
    's1_obs_2': 'Placed correctly.',
    's1_obs_3': 'Medium height, hard stem branching near base.',
    's1_obs_4': 'Placed correctly.',
    's1_obs_5': 'Tall height, thick hard woody stem.',
    's1_obs_6': 'Placed correctly.',
    's2_obs_1': 'Fins and streamlined body for swimming.',
    's2_obs_2': 'Aquatic habitat confirmed.',
    's2_obs_3': 'Hooves and strong legs for walking on land.',
    's2_obs_4': 'Terrestrial habitat confirmed.',
    's2_obs_5': 'Wide hooves for sand, hump for energy storage.',
    's2_obs_6': 'Terrestrial habitat confirmed.',
    's1_expl_1':
        "The scene shows the three plants and three plots. By tapping the Tomato plant, you visually compare its height to a human (it's shorter), showing its stem is green, thin, and bends easily.",
    's1_expl_2':
        "Drag the Tomato plant to the correct 'Herbs' plot based on its short height and tender stem characteristics.",
    's1_expl_3':
        'The Rose plant is medium in height (waist-high), its stem is brown, hard, and thin, and its branches start close to the ground.',
    's1_expl_4':
        "Drag the Rose plant to the correct 'Shrubs' plot based on its branching near the base and hard stem.",
    's1_expl_5':
        'The Mango plant is much taller than a human, its stem is brown, hard, and thick, and its branches are high up on the stem.',
    's1_expl_6':
        "Drag the Mango plant to the correct 'Trees' plot based on its tall height and thick trunk.",
    's2_expl_1':
        'The Fish has fins and a streamlined body perfectly adapted for swimming efficiently in water.',
    's2_expl_2':
        'Place the Fish in the Ocean habitat where it can utilize its aquatic adaptations to survive.',
    's2_expl_3':
        'The Goat has strong legs and hooves which are perfect for walking and jumping on solid land surfaces.',
    's2_expl_4':
        'Place the Goat in the grassy Plain habitat where it can freely walk on land and eat grass.',
    's2_expl_5':
        "The Camel has wide hooves so it doesn't sink in sand, and a hump to store energy, making it perfectly suited for harsh conditions.",
    's2_expl_6':
        'Place the Camel in the Desert habitat where its specialized terrestrial adaptations are most useful.',
    's1_summary':
        'You grouped plants by height and stem type! Herbs are short with green stems. Shrubs have hard stems branching near the base. Trees are tall with thick trunks.',
    's2_summary':
        'You grouped animals by habitat! Fish are Aquatic (water-living) with fins. Goats and Camels are Terrestrial (land-living) adapted to specific environments like plains and deserts.',
    'classification_complete': 'Classification Complete!',
    'select_next_sc_msg':
        'Scenario 1 completed. Select the next from the sidebar!',
    'btn_conclude': 'Review Classification',
    'got_it': 'Got it!',
    'feature': 'Feature',
    // Steps accordion (HTML teacher board). The HTML labels its step cards
    // with its `exploration` text ("Scenario 1" … "Scenario 6").
    'concept_exp': 'Classification Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // HTML `labelDict` (scene labels and inspection card titles).
    'lbl_herbs': 'Herbs',
    'lbl_shrubs': 'Shrubs',
    'lbl_trees': 'Trees',
    'lbl_tomato': 'Tomato',
    'lbl_rose': 'Rose',
    'lbl_mango': 'Mango',
    'lbl_ocean': 'Ocean (Aquatic)',
    'lbl_plain': 'Plain (Terrestrial)',
    'lbl_desert': 'Desert (Terrestrial)',
    'lbl_fish': 'Fish',
    'lbl_goat': 'Goat',
    'lbl_camel': 'Camel',
    // HTML `triggerConclusion` summary cards.
    'sum_herbs': 'Herbs',
    'sum_shrubs': 'Shrubs',
    'sum_trees': 'Trees',
    'sum_tender_stem': 'Tender stem',
    'sum_short_ht': 'Short height',
    'sum_hard_stem': 'Hard stem',
    'sum_medium_ht': 'Medium height',
    'sum_thick_trunk': 'Thick trunk',
    'sum_tall_ht': 'Tall height',
    'sum_aquatic': 'Aquatic',
    'sum_terrestrial': 'Terrestrial',
    'sum_live_water': '(Live in Water)',
    'sum_live_land': '(Live on Land)',
    'sum_fish': 'Fish',
    'sum_goat_camel': 'Goat / Camel',
    // Added.
    'pending': 'Do this step to see the result.',
    'hint_got_it': "Read the card, then TAP 'Got it!'.",
    'hint_tap_tomato': 'Not yet! First TAP the Tomato plant to inspect it.',
    'hint_tap_rose': 'Not yet! First TAP the Rose plant to inspect it.',
    'hint_tap_mango': 'Not yet! First TAP the Mango tree to inspect it.',
    'hint_tap_fish': 'Not yet! First TAP the Fish to inspect it.',
    'hint_tap_goat': 'Not yet! First TAP the Goat to inspect it.',
    'hint_tap_camel': 'Not yet! First TAP the Camel to inspect it.',
    'hint_drag_tomato': 'DRAG the Tomato plant and DROP it into a garden plot.',
    'hint_drag_rose': 'DRAG the Rose plant and DROP it into a garden plot.',
    'hint_drag_mango': 'DRAG the Mango tree and DROP it into a garden plot.',
    'hint_drag_fish': 'DRAG the Fish and DROP it into a habitat.',
    'hint_drag_goat': 'DRAG the Goat and DROP it into a habitat.',
    'hint_drag_camel': 'DRAG the Camel and DROP it into a habitat.',
    'miss_tomato': 'Missed! Drop the Tomato plant right onto a garden plot.',
    'miss_rose': 'Missed! Drop the Rose plant right onto a garden plot.',
    'miss_mango': 'Missed! Drop the Mango tree right onto a garden plot.',
    'miss_fish': 'Missed! Drop the Fish right onto a habitat.',
    'miss_goat': 'Missed! Drop the Goat right onto a habitat.',
    'miss_camel': 'Missed! Drop the Camel right onto a habitat.',
    'wrong_tomato':
        'Not quite! The Tomato plant is short, with a green, tender stem. Which plot fits it?',
    'wrong_rose':
        'Not quite! The Rose plant is medium in height, with a hard stem that branches near the base. Which plot fits it?',
    'wrong_mango':
        'Not quite! The Mango tree is tall, with a thick, hard, woody trunk. Which plot fits it?',
    'wrong_fish':
        'Not quite! The Fish has fins and a streamlined body for swimming. Which habitat fits it?',
    'wrong_goat':
        'Not quite! The Goat has hooves and strong legs for walking on grassy land. Which habitat fits it?',
    'wrong_camel':
        'Not quite! The Camel has wide hooves for sand and a hump to store energy. Which habitat fits it?',
    'scene_s1':
        'A virtual park: a tomato plant, a rose plant and a mango tree in front of three empty garden plots labelled Herbs, Shrubs and Trees',
    'scene_s2':
        'Three habitats, an ocean, a grassy plain and a sandy desert, with a fish, a goat and a camel in front of them',
  },
  'hi': {
    'app_title': 'जीवों के समूहन के सिद्धांत',
    'app_subtitle': 'कक्षा 6 • सजीव जगत में विविधता',
    'scen_1_opt': 'परिदृश्य 1: वर्चुअल माली की चुनौती',
    'scen_2_opt': 'परिदृश्य 2: आवास मिलान',
    's1_desc':
        'पौधों को उनकी शारीरिक विशेषताओं (ऊंचाई और तने) के आधार पर शाक, झाड़ी और पेड़ में समूहित करें।',
    's2_desc':
        'जानवरों को उनके अनुकूलन के आधार पर उनके सही आवासों (जलीय या स्थलीय) में समूहित करें।',
    's1_hud_1':
        "आप एक वर्चुअल पार्क में हैं। सामने, आपको एक आम का पौधा, एक गुलाब का पौधा और एक टमाटर का पौधा दिखाई देता है। उनके पीछे, 'शाक', 'झाड़ी' और 'पेड़' लेबल वाले तीन खाली भूखंड हैं। टमाटर के पौधे पर टैप करें।",
    's1_hud_2':
        'अब जब आपने टमाटर के पौधे की विशेषताओं का निरीक्षण कर लिया है, तो इसे खींचें (DRAG) और उस भूखंड में छोड़ें (DROP) जहां आपको लगता है कि यह संबंधित है।',
    's1_hud_3':
        'बढ़िया! अब, गुलाब के पौधे की विशेषताओं का निरीक्षण करने के लिए उस पर टैप करें।',
    's1_hud_4':
        'आपको पता है क्या करना है! गुलाब के पौधे को खींचें और सही भूखंड में छोड़ें।',
    's1_hud_5':
        'अंत में, आम के पौधे की विशेषताओं को देखने के लिए उस पर टैप करें।',
    's1_hud_6':
        'अपना बगीचा पूरा करें। आम के पौधे को खींचें और अंतिम बचे हुए भूखंड में छोड़ें।',
    's1_hud_7':
        "आपने जो सीखा है उसकी समीक्षा करने के लिए 'वर्गीकरण की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        'आप तीन अलग-अलग वातावरण देखते हैं: एक रेतीला रेगिस्तान, एक गहरा महासागर, और एक घास का मैदान/जंगल। उनके नीचे तीन जानवर हैं: एक ऊंट, एक मछली, और एक बकरी। यह देखने के लिए मछली पर टैप करें कि यह अपने घर के लिए कैसे बनी है।',
    's2_hud_2':
        'मछली के पंख और शरीर तैरने के लिए एकदम सही हैं। मछली को खींचें और उस आवास में छोड़ें जहां वह रह सकती है।',
    's2_hud_3':
        'बहुत बढ़िया। अब, बकरी की विशेषताओं का निरीक्षण करने के लिए उस पर टैप करें।',
    's2_hud_4':
        'बकरी के पैर जमीन पर चलने के लिए बने हैं। बकरी को खींचें और उसके प्राकृतिक घर में छोड़ें।',
    's2_hud_5': 'अंत में, ऊंट के विशेष अनुकूलन देखने के लिए उस पर टैप करें।',
    's2_hud_6':
        'ये विशेषताएं एक विशिष्ट वातावरण के लिए एकदम सही हैं। ऊंट को खींचें और उसके सही आवास में छोड़ें।',
    's2_hud_7':
        "समूहों की समीक्षा करने के लिए 'वर्गीकरण की समीक्षा करें' बटन पर टैप करें।",
    's1_step_1': 'निरीक्षण करने के लिए टमाटर के पौधे पर टैप करें।',
    's1_step_2':
        'टमाटर के पौधे को खींचें और उस भूखंड में छोड़ें जहाँ वह संबंधित है।',
    's1_step_3': 'निरीक्षण करने के लिए गुलाब के पौधे पर टैप करें।',
    's1_step_4':
        'गुलाब के पौधे को खींचें और उस भूखंड में छोड़ें जहाँ वह संबंधित है।',
    's1_step_5': 'निरीक्षण करने के लिए आम के पेड़ पर टैप करें।',
    's1_step_6':
        'आम के पेड़ को खींचें और उस भूखंड में छोड़ें जहाँ वह संबंधित है।',
    's1_step_7':
        "आपने जो सीखा है उसकी समीक्षा करने के लिए 'वर्गीकरण की समीक्षा करें' पर टैप करें।",
    's2_step_1':
        'यह देखने के लिए मछली पर टैप करें कि वह अपने घर के लिए कैसे बनी है।',
    's2_step_2': 'मछली को खींचें और उस आवास में छोड़ें जहाँ वह रह सकती है।',
    's2_step_3': 'बकरी की विशेषताओं का निरीक्षण करने के लिए उस पर टैप करें।',
    's2_step_4': 'बकरी को खींचें और उसके प्राकृतिक घर में छोड़ें।',
    's2_step_5': 'ऊंट के विशेष अनुकूलन देखने के लिए उस पर टैप करें।',
    's2_step_6': 'ऊंट को खींचें और उसके सही आवास में छोड़ें।',
    's2_step_7':
        "समूहों की समीक्षा करने के लिए 'वर्गीकरण की समीक्षा करें' पर टैप करें।",
    's1_act_1': 'टमाटर के पौधे पर टैप करें।',
    's1_act_2': "'शाक' भूखंड में खींचें।",
    's1_act_3': 'गुलाब के पौधे पर टैप करें।',
    's1_act_4': "'झाड़ी' भूखंड में खींचें।",
    's1_act_5': 'आम के पेड़ पर टैप करें।',
    's1_act_6': "'पेड़' भूखंड में खींचें।",
    's2_act_1': 'मछली पर टैप करें।',
    's2_act_2': 'महासागर में खींचें।',
    's2_act_3': 'बकरी पर टैप करें।',
    's2_act_4': 'मैदान में खींचें।',
    's2_act_5': 'ऊंट पर टैप करें।',
    's2_act_6': 'रेगिस्तान में खींचें।',
    'focus_observe': 'अवलोकन',
    'focus_group': 'समूहन',
    's1_obs_1': 'कम ऊंचाई, हरा कोमल तना।',
    's1_obs_2': 'सही ढंग से रखा गया।',
    's1_obs_3': 'मध्यम ऊंचाई, आधार के पास से शाखाओं वाला कठोर तना।',
    's1_obs_4': 'सही ढंग से रखा गया।',
    's1_obs_5': 'लंबी ऊंचाई, मोटा कठोर लकड़ी का तना।',
    's1_obs_6': 'सही ढंग से रखा गया।',
    's2_obs_1': 'तैरने के लिए पंख और सुव्यवस्थित शरीर।',
    's2_obs_2': 'जलीय आवास की पुष्टि की गई।',
    's2_obs_3': 'जमीन पर चलने के लिए खुर और मजबूत पैर।',
    's2_obs_4': 'स्थलीय आवास की पुष्टि की गई।',
    's2_obs_5': 'रेत के लिए चौड़े खुर, ऊर्जा भंडारण के लिए कूबड़।',
    's2_obs_6': 'स्थलीय आवास की पुष्टि की गई।',
    's1_expl_1':
        'दृश्य में तीन पौधे और तीन भूखंड हैं। टमाटर के पौधे पर टैप करने से इसकी ऊंचाई (मनुष्य से छोटी) और हरे, पतले, आसानी से मुड़ने वाले तने का पता चलता है।',
    's1_expl_2':
        "टमाटर के पौधे को इसकी कम ऊंचाई और कोमल तने के आधार पर सही 'शाक' भूखंड में खींचें।",
    's1_expl_3':
        'गुलाब का पौधा मध्यम ऊंचाई का है, इसका तना भूरा, कठोर और पतला है, और इसकी शाखाएं जमीन के करीब से शुरू होती हैं।',
    's1_expl_4':
        "गुलाब के पौधे को आधार के पास से शाखाओं और कठोर तने के आधार पर सही 'झाड़ी' भूखंड में खींचें।",
    's1_expl_5':
        'आम का पौधा मनुष्य से बहुत लंबा है, इसका तना भूरा, कठोर और मोटा है, और इसकी शाखाएं तने पर बहुत ऊपर हैं।',
    's1_expl_6':
        "आम के पौधे को उसकी लंबी ऊंचाई और मोटे तने के आधार पर सही 'पेड़' भूखंड में खींचें।",
    's2_expl_1':
        'मछली के पंख और एक सुव्यवस्थित शरीर होता है जो पानी में कुशलता से तैरने के लिए अनुकूलित होता है।',
    's2_expl_2':
        'मछली को महासागर के आवास में रखें जहां वह जीवित रहने के लिए अपने जलीय अनुकूलन का उपयोग कर सके।',
    's2_expl_3':
        'बकरी के मजबूत पैर और खुर होते हैं जो ठोस भूमि की सतहों पर चलने और कूदने के लिए एकदम सही हैं।',
    's2_expl_4':
        'बकरी को घास के मैदान के आवास में रखें जहां वह स्वतंत्र रूप से भूमि पर चल सके और घास खा सके।',
    's2_expl_5':
        'ऊंट के चौड़े खुर होते हैं ताकि वह रेत में न डूबे, और ऊर्जा को स्टोर करने के लिए एक कूबड़ होता है, जो इसे कठोर परिस्थितियों के लिए अनुकूल बनाता है।',
    's2_expl_6':
        'ऊंट को रेगिस्तान के आवास में रखें जहां उसके विशेष स्थलीय अनुकूलन सबसे उपयोगी हैं।',
    's1_summary':
        'आपने ऊंचाई और तने के प्रकार के आधार पर पौधों को समूहित किया! शाक छोटे होते हैं और हरे तने वाले होते हैं। झाड़ियों में आधार के पास से शाखाओं वाले कठोर तने होते हैं। पेड़ मोटे तने वाले लंबे होते हैं।',
    's2_summary':
        'आपने जानवरों को आवास द्वारा समूहित किया! मछलियाँ पंखों के साथ जलीय (पानी में रहने वाली) होती हैं। बकरियाँ और ऊंट स्थलीय (जमीन पर रहने वाले) होते हैं जो मैदानों और रेगिस्तानों जैसे विशिष्ट वातावरण के अनुकूल होते हैं।',
    'classification_complete': 'वर्गीकरण पूरा हुआ!',
    'select_next_sc_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'btn_conclude': 'वर्गीकरण की समीक्षा करें',
    'got_it': 'समझ गया!',
    'feature': 'विशेषता',
    'concept_exp': 'वर्गीकरण चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'lbl_herbs': 'शाक',
    'lbl_shrubs': 'झाड़ी',
    'lbl_trees': 'पेड़',
    'lbl_tomato': 'टमाटर',
    'lbl_rose': 'गुलाब',
    'lbl_mango': 'आम',
    'lbl_ocean': 'महासागर (जलीय)',
    'lbl_plain': 'मैदान (स्थलीय)',
    'lbl_desert': 'रेगिस्तान (स्थलीय)',
    'lbl_fish': 'मछली',
    'lbl_goat': 'बकरी',
    'lbl_camel': 'ऊंट',
    'sum_herbs': 'शाक',
    'sum_shrubs': 'झाड़ी',
    'sum_trees': 'पेड़',
    'sum_tender_stem': 'कोमल तना',
    'sum_short_ht': 'कम ऊंचाई',
    'sum_hard_stem': 'कठोर तना',
    'sum_medium_ht': 'मध्यम ऊंचाई',
    'sum_thick_trunk': 'मोटा तना',
    'sum_tall_ht': 'लंबी ऊंचाई',
    'sum_aquatic': 'जलीय',
    'sum_terrestrial': 'स्थलीय',
    'sum_live_water': '(पानी में रहते हैं)',
    'sum_live_land': '(जमीन पर रहते हैं)',
    'sum_fish': 'मछली',
    'sum_goat_camel': 'बकरी / ऊंट',
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'hint_got_it': "कार्ड पढ़ें, फिर 'समझ गया!' पर टैप करें।",
    'hint_tap_tomato':
        'अभी नहीं! पहले निरीक्षण करने के लिए टमाटर के पौधे पर टैप करें।',
    'hint_tap_rose':
        'अभी नहीं! पहले निरीक्षण करने के लिए गुलाब के पौधे पर टैप करें।',
    'hint_tap_mango':
        'अभी नहीं! पहले निरीक्षण करने के लिए आम के पेड़ पर टैप करें।',
    'hint_tap_fish': 'अभी नहीं! पहले निरीक्षण करने के लिए मछली पर टैप करें।',
    'hint_tap_goat': 'अभी नहीं! पहले निरीक्षण करने के लिए बकरी पर टैप करें।',
    'hint_tap_camel': 'अभी नहीं! पहले निरीक्षण करने के लिए ऊंट पर टैप करें।',
    'hint_drag_tomato': 'टमाटर के पौधे को खींचें और किसी भूखंड में छोड़ें।',
    'hint_drag_rose': 'गुलाब के पौधे को खींचें और किसी भूखंड में छोड़ें।',
    'hint_drag_mango': 'आम के पेड़ को खींचें और किसी भूखंड में छोड़ें।',
    'hint_drag_fish': 'मछली को खींचें और किसी आवास में छोड़ें।',
    'hint_drag_goat': 'बकरी को खींचें और किसी आवास में छोड़ें।',
    'hint_drag_camel': 'ऊंट को खींचें और किसी आवास में छोड़ें।',
    'miss_tomato':
        'निशाना चूक गया! टमाटर के पौधे को सीधे किसी भूखंड पर छोड़ें।',
    'miss_rose': 'निशाना चूक गया! गुलाब के पौधे को सीधे किसी भूखंड पर छोड़ें।',
    'miss_mango': 'निशाना चूक गया! आम के पेड़ को सीधे किसी भूखंड पर छोड़ें।',
    'miss_fish': 'निशाना चूक गया! मछली को सीधे किसी आवास पर छोड़ें।',
    'miss_goat': 'निशाना चूक गया! बकरी को सीधे किसी आवास पर छोड़ें।',
    'miss_camel': 'निशाना चूक गया! ऊंट को सीधे किसी आवास पर छोड़ें।',
    'wrong_tomato':
        'यह सही जगह नहीं है! टमाटर का पौधा छोटा है और उसका तना हरा और कोमल है। यह किस भूखंड में आएगा?',
    'wrong_rose':
        'यह सही जगह नहीं है! गुलाब का पौधा मध्यम ऊंचाई का है और उसका कठोर तना आधार के पास से शाखाओं में बँटता है। यह किस भूखंड में आएगा?',
    'wrong_mango':
        'यह सही जगह नहीं है! आम का पेड़ लंबा है और उसका तना मोटा, कठोर और लकड़ी जैसा है। यह किस भूखंड में आएगा?',
    'wrong_fish':
        'यह सही जगह नहीं है! मछली के पास तैरने के लिए पंख और सुव्यवस्थित शरीर है। यह किस आवास में रह सकती है?',
    'wrong_goat':
        'यह सही जगह नहीं है! बकरी के पास घास वाली ज़मीन पर चलने के लिए खुर और मज़बूत पैर हैं। यह किस आवास में रह सकती है?',
    'wrong_camel':
        'यह सही जगह नहीं है! ऊंट के पास रेत के लिए चौड़े खुर और ऊर्जा जमा करने के लिए कूबड़ है। यह किस आवास में रह सकता है?',
    'scene_s1':
        "एक वर्चुअल पार्क: 'शाक', 'झाड़ी' और 'पेड़' लेबल वाले तीन खाली भूखंडों के सामने एक टमाटर का पौधा, एक गुलाब का पौधा और एक आम का पेड़",
    'scene_s2':
        'तीन आवास, एक महासागर, एक घास का मैदान और एक रेतीला रेगिस्तान, और उनके सामने एक मछली, एक बकरी और एक ऊंट',
  },
};

/// The HTML `steps` of each scenario: inspect (odd) and group (even) each
/// of its three organisms.
const int _actionSteps = 6;

/// Number of steps of each scenario: the HTML's six steps plus its seventh
/// HUD task ('Review Classification').
const int _stepCount = _actionSteps + 1;

/// Number of scenarios (the HTML scenario selector).
const int _scenarioCount = 2;

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.done,
    required this.result,
    required this.explanation,
  });

  /// HTML `concept` ("Observation" / "Grouping").
  final String focus;

  /// What to do now (touch instruction).
  final String action;

  /// The HTML `action`, shown once the step is done.
  final String done;

  /// HTML `observation`.
  final String result;

  /// HTML `explanation`.
  final String explanation;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCount; i++)
      if (i <= _actionSteps)
        _StepInfo(
          focus: t(i.isOdd ? 'focus_observe' : 'focus_group'),
          action: t('s${n}_step_$i'),
          done: t('s${n}_act_$i'),
          result: t('s${n}_obs_$i'),
          explanation: t('s${n}_expl_$i'),
        )
      else
        _StepInfo(
          focus: '',
          action: t('s${n}_step_$i'),
          done: t('s${n}_step_$i'),
          result: '',
          explanation: '',
        ),
  ];
}

/// The two scenarios for [lang], built from the string table. The concept
/// ("Observation" / "Grouping") is shown with the current step, as in the
/// HTML.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(concept: s.focus, action: s.action, observation: s.result),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 10, 18) looking at `controls.target` (0, 0, 0).
const double _fovDegrees = 45;
const double _near = 0.1;
const _View _homeView = _View(_V(0, 10, 18), _V.zero, 0);

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `handleInspection`: the camera moves to the organism + (0, 3, 5),
/// looking at it at height 1, over 800 ms (`Cubic.Out`); the card opens
/// 800 ms after the tap.
const _V _inspectOffset = _V(0, 3, 5);
const double _inspectLookY = 1;
const double _inspectSeconds = 0.8;
const Duration _cardDelay = Duration(milliseconds: 800);

/// HTML `closeInspection`: the card closes (400 ms), then the camera moves
/// to (midX, 8, 12) looking at (midX, 0, 0), midX halfway between the
/// organism and its group, over 800 ms (linear).
const Duration _cardCloseDelay = Duration(milliseconds: 400);
const Duration _cardAnimation = Duration(milliseconds: 400);
const double _placeEyeY = 8;
const double _placeEyeZ = 12;
const double _placeSeconds = 0.8;

/// HTML `resetCamera()` after a drop jumps back to the start view; here the
/// camera glides back.
const double _homeSeconds = 0.6;

/// HTML drop test: `obj.position.distanceTo(target.position) < 3`.
const double _dropRange = 3;

/// HTML tweens: a correct drop settles on the group's centre (`Back.Out`,
/// 300 ms); any other drop springs back home (`Elastic.Out`, 500 ms).
const double _snapSeconds = 0.3;
const double _returnSeconds = 0.5;

/// The HTML drag plane (y = 0). A held organism stays inside these bounds
/// (added, so a drag towards the horizon keeps it in view).
const double _groundHalfX = 19;
const double _groundBackZ = -14;
const double _groundFrontZ = 10;

/// Ground planes `PlaneGeometry(40, 30)` and the fog `FogExp2(…, 0.015)`.
const double _groundHalfW = 20;
const double _groundHalfD = 15;
const double _fogDensity = 0.015;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up an organism (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Chip padding as a share of the label size.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; x UI scale) and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene (the HTML camera is zoom 1); it is
/// never drawn smaller than [_minZoom].
const double _maxZoom = 1.3;
const double _minZoom = 0.3;

/// Inspection card (HTML `.inspection-card`, `max-w-sm`): width and the
/// side of its picture box (`w-32 h-32`), x UI scale.
const double _inspectCardWidth = 330;
const double _inspectArtSide = 112;

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
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// Distance on the ground (x, z), as for objects that all stand at y = 0.
  double flatDistance(_V o) =>
      math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

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

/// HTML `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = 1 - t;
  return 1 - k * k * k;
}

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// HTML `TWEEN.Easing.Back.Out`.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// HTML `TWEEN.Easing.Elastic.Out`.
double _elasticOut(double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  return math.pow(2, -10 * t).toDouble() * math.sin((t - 0.1) * 5 * math.pi) +
      1;
}

/// A camera pose: HTML `camera.position` and `controls.target`.
@immutable
class _View {
  const _View(this.eye, this.target, this.close);

  final _V eye;
  final _V target;

  /// 0: the HTML start view, fitted beside the cards; 1: a close-up,
  /// centred in the free part of the canvas.
  final double close;

  _View lerpTo(_View o, double t) => _View(
    _V.lerp(eye, o.eye, t),
    _V.lerp(target, o.target, t),
    close + (o.close - close) * t,
  );
}

/// Where the start view's look-at point lands on the stage, how much the
/// scene is enlarged (the HTML camera is [base]) and the centre of the
/// free part of the canvas (where close-ups look). The scene is fitted
/// into the part of the canvas no card covers.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom, this.mid);

  final Offset center;
  final double zoom;
  final Offset mid;

  static const _Framing base = _Framing(_designCenter, 1, _designCenter);

  _Framing lerpTo(_Framing o, double t) => _Framing(
    Offset.lerp(center, o.center, t)!,
    zoom + (o.zoom - zoom) * t,
    Offset.lerp(mid, o.mid, t)!,
  );

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 &&
      (mid - o.mid).distance < 0.5 &&
      (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_View view, _Framing framing) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      view.eye,
      f,
      r,
      r.cross(f),
      Offset.lerp(framing.center, framing.mid, view.close)!,
      _focal * framing.zoom,
    );
  }

  const _Cam._(this.eye, this.f, this.r, this.u, this.center, this.scale);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w] (everything in the scenes is in front of the
  /// camera).
  Offset p(_V w) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  /// The screen offset of a small step [a] taken at [w] (the projection's
  /// derivative): how a mesh's axes look on screen.
  Offset dp(_V w, _V a) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    final az = a.dot(f);
    return Offset(
      scale * (a.dot(r) * z - d.dot(r) * az) / (z * z),
      -scale * (a.dot(u) * z - d.dot(u) * az) / (z * z),
    );
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (HTML `getIntersects(e, [dragPlane])`).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the box [min]–[max].
  Rect boxRect(_V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        _V(
          (i & 1) != 0 ? max.x : min.x,
          (i & 2) != 0 ? max.y : min.y,
          (i & 4) != 0 ? max.z : min.z,
        ),
      );
      l = math.min(l, q.dx);
      t = math.min(t, q.dy);
      r = math.max(r, q.dx);
      b = math.max(b, q.dy);
    }
    return Rect.fromLTRB(l, t, r, b);
  }
}

/// The garden plots (scenario 1) and habitat islands (scenario 2): the
/// HTML `createPlotBox` / `createDiorama` groups, in drop-target order.
enum _Zone {
  /// `createPlotBox(…, 3, 3, 'Herbs')` at (-6, 0, -3): a dirt mound
  /// `CylinderGeometry(1.3, 1.5, 0.3)`.
  herbs('lbl_herbs', _V(-6, 0, -3), 1.5, 0.3, 0.3, 0.5),

  /// `createPlotBox(…, 4, 4, 'Shrubs')` at (0, 0, -3).
  shrubs('lbl_shrubs', _V(0, 0, -3), 2, 0.3, 0.3, 0.5),

  /// `createPlotBox(…, 6, 6, 'Trees')` at (7, 0, -3).
  trees('lbl_trees', _V(7, 0, -3), 3, 0.3, 0.3, 0.5),

  /// `createDiorama('ocean', -8, …)`: an island `CylinderGeometry(3.5, 4,
  /// 0.5)` with a water column up to y = 2.
  ocean('lbl_ocean', _V(-8, 0, -3), 4, 0.5, 2, 1.2),

  /// `createDiorama('plain', 0, …)`, with a tree up to y ≈ 3.1.
  plain('lbl_plain', _V(0, 0, -3), 4, 0.5, 3.1, 1.2),

  /// `createDiorama('desert', 8, …)`, with dunes and a cactus.
  desert('lbl_desert', _V(8, 0, -3), 4, 0.5, 1.9, 1.2);

  const _Zone(
    this.labelKey,
    this.pos,
    this.radius,
    this.top,
    this.height,
    this.labelY,
  );

  final String labelKey;
  final _V pos;

  /// Radius at ground level.
  final double radius;

  /// Height of the mound / island top.
  final double top;

  /// Height of the tallest thing on it (for the framing).
  final double height;

  /// Height of the label sprite (`createTextSprite(label, y, 0.8)`).
  final double labelY;

  static List<_Zone> of(int scenario) =>
      values.sublist(scenario * 3, scenario * 3 + 3);
}

/// The organisms, in step order: each is inspected (odd step), then
/// dropped into its group (even step).
enum _Obj {
  /// Tomato plant (herb) at (-6, 0, 4), label at y 2.
  tomato('lbl_tomato', _V(-6, 0, 4), _Zone.herbs, 2),

  /// Rose plant (shrub) at (0, 0, 4), label at y 2.8.
  rose('lbl_rose', _V(0, 0, 4), _Zone.shrubs, 2.8),

  /// Mango tree at (7, 0, 4), label at y 7.5.
  mango('lbl_mango', _V(7, 0, 4), _Zone.trees, 7.5),

  /// Fish at (-6, 0, 4), label at y 2.2.
  fish('lbl_fish', _V(-6, 0, 4), _Zone.ocean, 2.2),

  /// Goat at (0, 0, 4), label at y 2.5.
  goat('lbl_goat', _V(0, 0, 4), _Zone.plain, 2.5),

  /// Camel at (6, 0, 4), label at y 3.8.
  camel('lbl_camel', _V(6, 0, 4), _Zone.desert, 3.8);

  const _Obj(this.nameKey, this.home, this.target, this.labelY);

  final String nameKey;

  /// HTML `userData.initPos`.
  final _V home;

  /// HTML `userData.target`.
  final _Zone target;
  final double labelY;

  /// The organism of the HTML step [step] (1–6) of [scenario].
  static _Obj forStep(int scenario, int step) =>
      values[scenario * 3 + (step - 1) ~/ 2];

  static List<_Obj> of(int scenario) =>
      values.sublist(scenario * 3, scenario * 3 + 3);

  /// Bounds of the meshes around the group's origin (hit test, framing).
  List<(_V, _V)> get boxes => switch (this) {
    _Obj.tomato => const [(_V(-0.45, 0, -0.45), _V(0.45, 1.65, 0.45))],
    _Obj.rose => const [(_V(-0.75, 0, -0.75), _V(0.75, 2.45, 0.75))],
    _Obj.mango => const [
      (_V(-0.6, 0, -0.6), _V(0.6, 2.6, 0.6)),
      (_V(-2.7, 2.3, -2.7), _V(2.7, 6.6, 2.7)),
    ],
    _Obj.fish => const [(_V(-1.55, 0.45, -0.35), _V(1.15, 1.9, 0.35))],
    _Obj.goat => const [(_V(-0.9, 0, -0.35), _V(1.2, 2.05, 0.35))],
    _Obj.camel => const [(_V(-1.2, 0, -0.65), _V(2, 3.25, 0.65))],
  };
}

/// One organism: where it stands, its tweens and its progress (HTML
/// `State.s1` / `State.s2` flags).
class _Pose {
  _Pose(this.obj) : pos = obj.home;

  final _Obj obj;

  /// Where it rests, is held, or is gliding to.
  _V pos;

  _V _from = _V.zero;
  double _start = -1;
  double _seconds = 1;
  bool _elastic = false;

  /// HTML `tomatoInspected` …: tapped (the card is opening or open).
  bool inspected = false;

  /// HTML `tomatoPlaced` …: dropped into its group.
  bool placed = false;

  /// Position at scene [time].
  _V at(double time) {
    if (_start < 0) return pos;
    final t = ((time - _start) / _seconds).clamp(0.0, 1.0);
    return _V.lerp(_from, pos, _elastic ? _elasticOut(t) : _backOut(t));
  }

  /// Glides from where it is to [to] (HTML `new TWEEN.Tween(obj.position)`).
  void glide(double time, _V to, double seconds, {required bool elastic}) {
    _from = at(time);
    pos = to;
    _start = time;
    _seconds = seconds;
    _elastic = elastic;
  }

  /// Puts it at [p] at once (held by the finger).
  void hold(_V p) {
    _start = -1;
    pos = p;
  }

  /// Ends a finished glide; true if one ended.
  bool settle(double time) {
    if (_start < 0 || time - _start < _seconds) return false;
    _start = -1;
    return true;
  }
}

/// The HTML's `Math.random()` scatter (grass tufts, pebbles, leaves,
/// petals, fruit, rocks), drawn once from seeded generators so the scene
/// looks the same every time.
abstract final class _Scatter {
  /// 40 grass tufts on the park ground: position (±17.5, 0.2, ±12.5) and
  /// a slight random tilt.
  static final List<(_V, double, double, double)> tufts = () {
    final rng = math.Random(21);
    return [
      for (var i = 0; i < 40; i++)
        (
          _V((rng.nextDouble() - 0.5) * 35, 0.2, (rng.nextDouble() - 0.5) * 25),
          (rng.nextDouble() - 0.5) * 0.2,
          rng.nextDouble() * math.pi,
          (rng.nextDouble() - 0.5) * 0.2,
        ),
    ];
  }();

  /// Six pebbles around each plot (offsets from its centre).
  static final List<List<_V>> pebbles = () {
    final rng = math.Random(22);
    return [
      for (final z in _Zone.of(0))
        [
          for (var i = 0; i < 6; i++)
            () {
              final a = rng.nextDouble() * math.pi * 2;
              final r = z.radius * (0.8 + rng.nextDouble() * 0.2);
              return _V(math.cos(a) * r, 0.05, math.sin(a) * r);
            }(),
        ],
    ];
  }();

  /// Random x / z turns of the tomato's 12 leaf cones.
  static final List<(double, double)> tomatoLeaves = () {
    final rng = math.Random(23);
    return [for (var i = 0; i < 12; i++) (rng.nextDouble(), rng.nextDouble())];
  }();

  /// Base offsets of the rose's 7 stems (`Math.random() * 0.2`).
  static final List<double> roseDist = () {
    final rng = math.Random(24);
    return [for (var i = 0; i < 7; i++) rng.nextDouble() * 0.2];
  }();

  /// Extra height of the rose's 28 leaves (`Math.random() * 0.2`).
  static final List<double> roseLeafLift = () {
    final rng = math.Random(25);
    return [for (var i = 0; i < 28; i++) rng.nextDouble() * 0.2];
  }();

  /// The 20 petals of the four roses: offset (±0.05) and turn.
  static final List<(_V, double, double, double)> petals = () {
    final rng = math.Random(26);
    return [
      for (var i = 0; i < 20; i++)
        (
          _V(
            (rng.nextDouble() - 0.5) * 0.1,
            (rng.nextDouble() - 0.5) * 0.1,
            (rng.nextDouble() - 0.5) * 0.1,
          ),
          rng.nextDouble() * math.pi,
          rng.nextDouble() * math.pi,
          rng.nextDouble() * math.pi,
        ),
    ];
  }();

  /// The mango canopy: eight leaf clumps `IcosahedronGeometry(1.2)` at
  /// these centres (around (0, 4, 0)) and scales.
  static const List<(double, double, double, double)> canopy = [
    (0, 0.5, 0, 1.5),
    (-1.2, 0, 0.8, 1.2),
    (1.2, 0, -0.8, 1.2),
    (0.8, -0.5, 1.2, 1.1),
    (-0.8, -0.5, -1.2, 1.1),
    (0, 1.2, 0, 1.3),
    (-1.5, 0.5, -0.5, 1),
    (1.5, 0.5, 0.5, 1),
  ];

  /// The 12 mangoes hanging from the canopy (group positions), without
  /// the ones buried inside a clump (Three.js hides them by depth).
  static final List<_V> mangoes = () {
    final rng = math.Random(27);
    final all = [
      for (var i = 0; i < 12; i++)
        () {
          final a = rng.nextDouble() * math.pi * 2;
          final r = 1 + rng.nextDouble() * 1.5;
          return _V(
            math.cos(a) * r,
            2.5 + rng.nextDouble() * 1.5,
            math.sin(a) * r,
          );
        }(),
    ];
    bool buried(_V g) {
      final fruit = g - const _V(0, 0.2, 0);
      for (final (x, y, z, s) in canopy) {
        if ((fruit - _V(x, 4 + y, z)).length < 1.2 * s * 0.92) return true;
      }
      return false;
    }

    return [
      for (final g in all)
        if (!buried(g)) g,
    ];
  }();

  /// Four rocks on the desert island (offsets from its centre).
  static final List<_V> desertRocks = () {
    final rng = math.Random(28);
    return [
      for (var i = 0; i < 4; i++)
        _V(rng.nextDouble() * 4 - 2, 0.5, rng.nextDouble() * 4 - 2),
    ];
  }();

  /// Eight grass tufts on the plain island: offset and turn.
  static final List<(_V, double, double, double)> plainGrass = () {
    final rng = math.Random(29);
    return [
      for (var i = 0; i < 8; i++)
        (
          _V(rng.nextDouble() * 5 - 2.5, 0.65, rng.nextDouble() * 5 - 2.5),
          (rng.nextDouble() - 0.5) * 0.3,
          rng.nextDouble() * math.pi,
          (rng.nextDouble() - 0.5) * 0.3,
        ),
    ];
  }();
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step`: 1–6 the inspect / group steps, 7 'Review
  /// Classification'.
  int step = 1;

  /// 'Review Classification' was tapped.
  bool reviewed = false;

  /// The current scenario's three organisms.
  final List<_Pose> poses = [];

  /// The organism the learner is dragging (HTML `State.draggingObject`).
  _Pose? held;

  /// The plot / habitat under the held organism (added highlight).
  _Zone? hover;

  /// Something came to rest this frame (camera, framing, an organism).
  bool _settled = false;

  // ---------------------------------------------------------------- camera
  _View view = _homeView;
  _View _viewFrom = _homeView;
  _View _viewTo = _homeView;
  double _viewT = 1;
  double _viewSeconds = 1;
  double Function(double) _viewEase = _linear;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// HTML `resetScenarioState(sc)`: organisms home, flags cleared, step 1,
  /// camera reset.
  void load(int index) {
    scenario = index;
    poses
      ..clear()
      ..addAll([for (final o in _Obj.of(index)) _Pose(o)]);
    step = 1;
    reviewed = false;
    held = null;
    hover = null;
    view = _viewFrom = _viewTo = _homeView;
    _viewT = 1;
    _settled = true;
  }

  _Pose pose(_Obj o) => poses.firstWhere((p) => p.obj == o);

  /// The organism the current step is about (none at the review step).
  _Obj? get current =>
      step <= _actionSteps ? _Obj.forStep(scenario, step) : null;

  /// HTML camera tweens (`camera.position` to [to]).
  void moveCamera(_View to, double seconds, double Function(double) ease) {
    _viewFrom = view;
    _viewTo = to;
    _viewT = 0;
    _viewSeconds = seconds;
    _viewEase = ease;
  }

  /// HTML `animate()` + `TWEEN.update()`: camera, organisms and framing.
  void advance(double dt) {
    if (_viewT < 1) {
      _viewT = math.min(1, _viewT + dt / _viewSeconds);
      view = _viewFrom.lerpTo(_viewTo, _viewEase(_viewT));
      if (_viewT >= 1) _settled = true;
    }
    for (final p in poses) {
      if (p.settle(time)) _settled = true;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      if (_framingT >= 1) _settled = true;
    }
  }

  /// True once after something came to rest.
  bool takeSettled() {
    final s = _settled;
    _settled = false;
    return s;
  }

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      _settled = true;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(view, framing);

  /// Where [p] is drawn now.
  _V posOf(_Pose p) => p.at(time);

  /// Screen bounds of the plot / island [z] (its base and top).
  Rect zoneRect(_Zone z, _Cam cam) => cam.boxRect(
    z.pos - _V(z.radius, 0, z.radius),
    z.pos + _V(z.radius, z.top, z.radius),
  );

  /// Screen bounds of [p] as drawn now.
  Rect rectOf(_Pose p, _Cam cam) {
    final at = posOf(p);
    Rect? out;
    for (final (min, max) in p.obj.boxes) {
      final r = cam.boxRect(at + min, at + max);
      out = out == null ? r : out.expandToInclude(r);
    }
    return out!;
  }

  /// The organism at [pt] (HTML raycast): the front-most one whose bounds,
  /// widened by half a finger ([touch]), contain the point.
  _Pose? objAt(Offset pt, double touch) {
    final cam = camera();
    _Pose? best;
    var bestDepth = double.infinity;
    for (final p in poses) {
      final at = posOf(p);
      var hit = false;
      for (final (min, max) in p.obj.boxes) {
        if (cam.boxRect(at + min, at + max).inflate(touch / 2).contains(pt)) {
          hit = true;
          break;
        }
      }
      if (!hit) continue;
      final d = cam.depth(at);
      if (d < bestDepth) {
        best = p;
        bestDepth = d;
      }
    }
    return best;
  }

  /// The plot / habitat within the HTML drop range of [pos] (the nearest).
  _Zone? zoneNear(_V pos) {
    _Zone? best;
    var bestD = _dropRange;
    for (final z in _Zone.of(scenario)) {
      final d = pos.flatDistance(z.pos);
      if (d < bestD) {
        best = z;
        bestD = d;
      }
    }
    return best;
  }

  /// The plot / habitat whose top is under the pointer [pt] (added: a
  /// release over a group as drawn counts, not only the HTML distance).
  _Zone? zoneAtPointer(Offset pt) {
    final cam = camera();
    for (final z in _Zone.of(scenario)) {
      final hit = cam.onPlaneY(pt, z.top);
      if (hit != null && hit.flatDistance(z.pos) < z.radius) return z;
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
  return _Framing(rect.center - extent(zoom).center, zoom, rect.center);
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on an organism ([canGrab]), so other drags still pan / zoom the canvas
/// when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _GroupingLabState
    extends State<Ch2A2PrinciplesAndImportanceOfGroupingLivingOrganismsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped whenever the organisms, camera or framing come to rest: the
  /// organisms' semantics nodes re-read where they are.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a2-canvas');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _missionRect;

  /// The inspection card (HTML `#inspection-panel`): the organism it shows
  /// and whether it is open (it scales in and fades out).
  _Obj? _card;
  bool _cardOpen = false;

  /// The organism the current pointer holds, the scenario it was picked up
  /// in, the ground offset of the grab, whether it moved and the last
  /// pointer position.
  _Pose? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  bool _moved = false;
  Offset _lastPointer = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// 1-based current step for the shell; steps + 1 once reviewed.
  int get _step => _scene.reviewed ? _stepCount + 1 : _scene.step;

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
    _layout.dispose();
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
    if (s.takeSettled()) _layout.value++;
    _frame.value = now;
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

  /// Fits the scenario's plots / habitats, organisms and labels into the
  /// part of the canvas no card covers: the tool column, the HUD (sidebar
  /// open) and the floating mission card (sidebar collapsed). Never while
  /// an organism is held, so the scene does not move under the finger.
  void _updateFraming() {
    if (_scene.held != null) return;
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
    if (open) _missionRect = null;
    if (!open && _lab.isLabActive) {
      // The floating mission card as it is laid out; before that, the room
      // the shell gives it.
      final card = _missionCardBox();
      if (card != null) {
        final now = (card.localToGlobal(Offset.zero) - origin) & card.size;
        final kept = _missionRect;
        _missionRect = kept == null
            ? now
            : Rect.fromLTWH(
                now.left,
                now.top,
                math.max(now.width, kept.width),
                math.max(now.height, kept.height),
              );
        hard.add(_missionRect!);
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

  /// What the learner must see in the start view: the plots / habitats and
  /// the organisms at home (HTML camera, zoom 1), and the label chips at
  /// their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_homeView, _Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V min, _V max) {
      for (var i = 0; i < 8; i++) {
        items.add((
          cam.p(
            _V(
              (i & 1) != 0 ? max.x : min.x,
              (i & 2) != 0 ? max.y : min.y,
              (i & 4) != 0 ? max.z : min.z,
            ),
          ),
          Rect.zero,
        ));
      }
    }

    void chip(_V at, String text) {
      final size = _cache.chipSize(text);
      items.add((
        cam.p(at),
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        ),
      ));
    }

    for (final z in _Zone.of(_scene.scenario)) {
      final r = z.radius + 0.1;
      box(z.pos - _V(r, 0, r), z.pos + _V(r, z.height, r));
      chip(z.pos + _V(0, z.labelY, 0), _t(z.labelKey));
    }
    for (final o in _Obj.of(_scene.scenario)) {
      for (final (min, max) in o.boxes) {
        box(o.home + min, o.home + max);
      }
      chip(o.home + _V(0, o.labelY, 0), _t(o.nameKey));
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens, closes the card and puts every organism back home.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _card = null;
      _cardOpen = false;
      _grab = null;
      _grabScenario = -1;
      _moved = false;
      _missionRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `handleInspection(obj)`: the camera zooms to the organism and,
  /// 800 ms later, its inspection card opens.
  void _inspect(_Pose p) {
    final s = _scene;
    _Sound.click.play();
    p.inspected = true;
    final at = s.posOf(p);
    s.moveCamera(
      _View(at + _inspectOffset, _V(at.x, _inspectLookY, at.z), 1),
      _inspectSeconds,
      _cubicOut,
    );
    final scenario = s.scenario;
    _lab.after(_cardDelay, () {
      if (!mounted || s.scenario != scenario) return;
      setState(() {
        _card = p.obj;
        _cardOpen = true;
      });
    });
    _refresh();
  }

  /// HTML `closeInspection()` ('Got it!'): the card closes; 400 ms later
  /// the step moves on and the camera frames the organism and the groups.
  /// (The HTML picks scenario 1's plants here in scenario 2 as well; the
  /// camera follows the inspected organism.)
  void _closeInspection() {
    final obj = _card;
    if (obj == null || !_cardOpen) return;
    _Sound.click.play();
    setState(() => _cardOpen = false);
    final s = _scene;
    final scenario = s.scenario;
    _lab.after(_cardCloseDelay, () {
      if (!mounted || s.scenario != scenario) return;
      s.step += 1;
      final at = s.posOf(s.pose(obj));
      final midX = (at.x + obj.target.pos.x) / 2;
      s.moveCamera(
        _View(_V(midX, _placeEyeY, _placeEyeZ), _V(midX, 0, 0), 1),
        _placeSeconds,
        _linear,
      );
      setState(() => _card = null);
    });
  }

  /// HTML `handleUp` success branch: the organism settles on its group
  /// (`Back.Out`) and the step moves on; the camera returns to the start
  /// view, or, after the last one, 'Review Classification' appears with a
  /// chime (HTML `triggerConclusionState`).
  void _place(_Pose p) {
    final s = _scene;
    p
      ..glide(s.time, p.obj.target.pos, _snapSeconds, elastic: false)
      ..placed = true;
    s.step += 1;
    if (s.step > _actionSteps) {
      _Sound.success.play();
    } else {
      _Sound.correct.play();
      s.moveCamera(_homeView, _homeSeconds, _cubicOut);
    }
    _refresh();
  }

  /// HTML `triggerConclusion()`.
  void _review() {
    final s = _scene;
    if (s.step <= _actionSteps) return;
    s.reviewed = true;
    _refresh();
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('classification_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _SummaryVisual(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
          // HTML `#next-sc-msg`, shown after Scenario 1 while Scenario 2 is
          // still to do.
          showNext: sc == 0 && !_lab.completedScenarios.contains(1),
        ),
      ),
    );
  }

  /// HTML `#compare-btn-container` ('Review Classification'), once every
  /// organism is in its group.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.step <= _actionSteps) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.check_circle,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        highlight: !s.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  // -------------------------------------------------------------- gestures

  /// What to do now, as a toast (added): tap or drag the step's organism.
  void _hint({bool error = true}) {
    final s = _scene;
    final want = s.current;
    if (want == null) return;
    final key = s.step.isEven
        ? 'hint_drag_${want.name}'
        : (s.pose(want).inspected ? 'hint_got_it' : 'hint_tap_${want.name}');
    _lab.showToast(_t(key), isError: error, sound: error);
  }

  /// HTML `handleDown`: a press on an organism (the HTML only reacts to the
  /// step's organism; a press on another one says what to do instead).
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null) return false;
    return _scene.objAt(event.localPosition, _touch) != null;
  }

  /// Inspects the step's organism (odd steps) or picks it up (even steps).
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final p = s.objAt(d.localPosition, _touch);
    final want = s.current;
    if (p == null || want == null) return;
    if (p.obj != want) {
      _hint();
      return;
    }
    if (s.step.isOdd) {
      if (p.inspected) {
        _hint(error: false);
      } else {
        _inspect(p);
      }
      return;
    }
    if (p.placed) return;
    final rest = s.posOf(p);
    final hit = s.camera().onPlaneY(d.localPosition, 0);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - rest.x, 0, hit.z - rest.z);
    p.hold(rest);
    s.held = p;
    _grab = p;
    _grabScenario = s.scenario;
    _moved = false;
    _lastPointer = d.localPosition;
  }

  /// HTML `handleMove`: the organism follows the finger on the ground; the
  /// plot / habitat under it is outlined (added).
  void _onDragUpdate(DragUpdateDetails d) {
    final p = _grab;
    final s = _scene;
    if (p == null || _grabScenario != s.scenario || s.held != p) return;
    _moved = true;
    _lastPointer = d.localPosition;
    final hit = s.camera().onPlaneY(d.localPosition, 0);
    if (hit != null) {
      p.hold(
        _V(
          (hit.x - _grabOffset.x).clamp(-_groundHalfX, _groundHalfX),
          0,
          (hit.z - _grabOffset.z).clamp(_groundBackZ, _groundFrontZ),
        ),
      );
    }
    s.hover = s.zoneNear(p.pos) ?? s.zoneAtPointer(_lastPointer);
  }

  void _onDragEnd(DragEndDetails _) => _release(cancel: false);

  void _onDragCancel() => _release(cancel: true);

  /// HTML `handleUp`: dropped on its group, the organism settles there;
  /// anywhere else it springs back home (`playSound('error')`) and a toast
  /// says why (added). A press without a drag explains what to do.
  void _release({required bool cancel}) {
    final p = _grab;
    final scenario = _grabScenario;
    final moved = _moved;
    _grab = null;
    _grabScenario = -1;
    _moved = false;
    final s = _scene;
    s.hover = null;
    if (p == null || scenario != s.scenario || s.held != p) return;
    s.held = null;
    if (!moved) {
      _hint(error: false);
      return;
    }
    final zone = cancel
        ? null
        : (s.zoneNear(p.pos) ?? s.zoneAtPointer(_lastPointer));
    if (zone == p.obj.target) {
      _place(p);
      return;
    }
    p.glide(s.time, p.obj.home, _returnSeconds, elastic: true);
    if (!cancel) {
      _lab.showToast(
        _t(zone == null ? 'miss_${p.obj.name}' : 'wrong_${p.obj.name}'),
        isError: true,
      );
    }
    _scheduleFraming();
  }

  /// A screen-reader tap on an organism (added): inspects it at its step,
  /// otherwise says what to do.
  void _activate(_Pose p) {
    final s = _scene;
    if (!_lab.isLabActive || s.current == null) return;
    if (p.obj == s.current && s.step.isOdd && !p.inspected) {
      _inspect(p);
    } else {
      _hint(error: false);
    }
  }

  /// A screen-reader tap on a plot / habitat (added): at a grouping step it
  /// drops the step's organism there, as a drag would.
  void _activateZone(_Zone z) {
    final s = _scene;
    final want = s.current;
    if (!_lab.isLabActive || want == null || s.held != null) return;
    if (s.step.isOdd) {
      _hint(error: false);
      return;
    }
    if (z == want.target) {
      _place(s.pose(want));
    } else {
      _lab.showToast(_t('wrong_${want.name}'), isError: true);
    }
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
        final inset = labOverlayInsets(context, _lab);
        final card = _card;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.account_tree,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, _stepCount)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$_step'),
            steps: _stepData,
            current: _step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('step_word'),
            focusLabel: _t('focus_lbl'),
            actionLabel: _t('action_lbl'),
            resultLabel: _t('result_lbl'),
            pendingText: _t('pending'),
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#inspection-panel`, centred on the canvas.
            if (card != null)
              Positioned(
                key: const ValueKey('ch2a2-inspection-card'),
                left: inset.left,
                top: inset.top,
                right: inset.right,
                bottom: inset.bottom + (_lab.isSidebarOpen ? _hudBand * s : 0),
                child: Center(
                  child: _InspectionCard(
                    key: ValueKey('inspect-${card.name}'),
                    obj: card,
                    open: _cardOpen,
                    palette: p,
                    scale: s,
                    title: _t(card.nameKey),
                    featureLabel: _t('feature'),
                    feature: _t('s${sc + 1}_obs_${card.index % 3 * 2 + 1}'),
                    button: _t('got_it'),
                    onClose: _closeInspection,
                    time: _frame,
                  ),
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
          _touch = _touchDp / fit;
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags on the scene are not screen-reader actions; the
                // scene and its organisms are announced instead.
                excludeFromSemantics: true,
                gestures: <Type, GestureRecognizerFactory>{
                  _GrabPanRecognizer:
                      GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
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
                          ..onUpdate = _onDragUpdate
                          ..onEnd = _onDragEnd
                          ..onCancel = _onDragCancel,
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
                      ),
                    ),
                  ),
                ),
              ),
              // One semantics node per plot / habitat and per organism where
              // it is drawn (added), so a screen reader can find and tap
              // them. They take no touches: those reach the scene below.
              ValueListenableBuilder<int>(
                valueListenable: _layout,
                builder: (context, _, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    for (final z in _Zone.of(_scene.scenario))
                      Positioned.fromRect(
                        rect: _scene.zoneRect(z, _scene.camera()),
                        child: Semantics(
                          container: true,
                          button: true,
                          label: _t(z.labelKey),
                          onTap: () => _activateZone(z),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    for (final p in _scene.poses)
                      Positioned.fromRect(
                        rect: _scene.rectOf(p, _scene.camera()),
                        child: Semantics(
                          container: true,
                          button: true,
                          label: _t(p.obj.nameKey),
                          onTap: () => _activate(p),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// HTML `#inspection-panel`: the organism's name, a picture of the feature
/// to notice (HTML `SVGs`: the stem next to a person, the fin, hooves and
/// hump), "Feature: …" (the step's observation) and 'Got it!'. It scales
/// in like the HTML `.inspection-card.show` and fades out when closed.
class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    super.key,
    required this.obj,
    required this.open,
    required this.palette,
    required this.scale,
    required this.title,
    required this.featureLabel,
    required this.feature,
    required this.button,
    required this.onClose,
    required this.time,
  });

  final _Obj obj;
  final bool open;
  final LabPalette palette;
  final double scale;
  final String title;
  final String featureLabel;
  final String feature;
  final String button;
  final VoidCallback onClose;

  /// Scene time (the tomato stem pulses).
  final ValueListenable<double> time;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(_inspectCardWidth * s, box.maxWidth * 0.95);
        final art = math.min(_inspectArtSide * s, box.maxHeight * 0.32);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: open ? 1.0 : 0.0),
          duration: _cardAnimation,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.9 + 0.1 * Curves.easeOutBack.transform(v),
              child: child,
            ),
          ),
          child: Container(
            width: width,
            constraints: BoxConstraints(maxHeight: box.maxHeight),
            decoration: BoxDecoration(
              color: p.isDark
                  ? _Colors.slate900.withValues(alpha: 0.95)
                  : _Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _Colors.indigo500.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: LabInk.scrim,
                  blurRadius: 50,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(18 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: indigo,
                      fontSize: 19 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title, 1.2),
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  ExcludeSemantics(
                    child: Container(
                      width: art,
                      height: art,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: p.isDark ? _Colors.slate800 : _Colors.slate100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: p.isDark ? _Colors.slate700 : _Colors.slate300,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _InspectPainter(obj: obj, time: time),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$featureLabel: ',
                          style: const TextStyle(
                            color: _Colors.indigo500,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: feature),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.isDark ? _Colors.slate300 : _Colors.slate600,
                      fontSize: 13.5 * s,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14 * s),
                  FilledButton(
                    onPressed: open ? onClose : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _Colors.indigo600,
                      foregroundColor: _Colors.white,
                      disabledBackgroundColor: _Colors.indigo600,
                      disabledForegroundColor: _Colors.indigo100,
                      minimumSize: const Size(
                        kMinInteractiveDimension * 2,
                        kMinInteractiveDimension,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 26 * s),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 14.5 * s,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(button),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// HTML teacher-board "Classification Step" accordion: one card per step
/// with its focus, action and result (and the HTML explanation). The
/// current step is open, done steps show a tick and can be re-opened,
/// future steps are dimmed. A step's result and explanation are shown once
/// it is done, and its action then reads as the HTML's ("DRAG to 'Herbs'
/// plot."), which would give the answer away before.
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.focusLabel,
    required this.actionLabel,
    required this.resultLabel,
    required this.pendingText,
  });

  final List<_StepInfo> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String focusLabel;
  final String actionLabel;
  final String resultLabel;
  final String pendingText;

  @override
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
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

  Widget _heading(String text, Color color) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 9.5 * widget.fontScale,
      fontWeight: FontWeight.w800,
      letterSpacing: labLetterSpacing(text, 0.8),
    ),
  );

  Widget _body(String text, Color color, {bool italic = false}) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: (italic ? 11 : 11.5) * widget.fontScale,
      fontWeight: FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: 1.4,
    ),
  );

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    // Future steps: dimmed, closed.
    final dim = future ? 0.5 : 1.0;
    final accent = p.accentInk;
    final tone = current ? accent : (past ? p.success : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

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
                          color: current
                              ? p.accent
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
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
                                      ? p.onAccent
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  if (step.focus.isNotEmpty) ...[
                    _heading(w.focusLabel, accent),
                    SizedBox(height: 3 * s),
                    _body(step.focus, p.textStrong),
                    SizedBox(height: 8 * s),
                  ],
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(past ? step.done : step.action, p.text),
                  if (step.result.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    _heading(w.resultLabel, p.textStrong),
                    SizedBox(height: 3 * s),
                    if (past)
                      _body(step.result, p.text)
                    else
                      _body(w.pendingText, p.textMuted, italic: true),
                  ],
                  if (past && step.explanation.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    Container(
                      padding: EdgeInsets.only(top: 8 * s),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: p.cardBorder)),
                      ),
                      child: _body(step.explanation, p.textMuted, italic: true),
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

/// HTML `#summary-visual-area`: S1 the Herbs, Shrubs and Trees cards (icon
/// and the two features of each group); S2 the Aquatic (fish, fin) and
/// Terrestrial (goat / camel, hoof and hump) cards. Below, after Scenario
/// 1, the HTML's "select the next scenario" note.
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.t,
    required this.showNext,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cards = scenario == 0
        ? [
            _plantCard(
              t('sum_herbs'),
              _Colors.green500,
              _Glyph.herb,
              t('sum_tender_stem'),
              t('sum_short_ht'),
            ),
            _plantCard(
              t('sum_shrubs'),
              _Colors.amber500,
              _Glyph.shrub,
              t('sum_hard_stem'),
              t('sum_medium_ht'),
            ),
            _plantCard(
              t('sum_trees'),
              _Colors.orange500,
              _Glyph.tree,
              t('sum_thick_trunk'),
              t('sum_tall_ht'),
            ),
          ]
        : [
            _habitatCard(
              t('sum_aquatic'),
              t('sum_live_water'),
              _Colors.blue500,
              [
                (
                  _Glyph.fin,
                  palette.isDark
                      ? _Colors.blue900.withValues(alpha: 0.3)
                      : _Colors.blue100,
                ),
              ],
              t('sum_fish'),
            ),
            _habitatCard(
              t('sum_terrestrial'),
              t('sum_live_land'),
              _Colors.green500,
              [
                (
                  _Glyph.hoof,
                  palette.isDark
                      ? _Colors.green900.withValues(alpha: 0.3)
                      : _Colors.green100,
                ),
                (
                  _Glyph.hump,
                  palette.isDark
                      ? _Colors.yellow900.withValues(alpha: 0.3)
                      : _Colors.yellow100,
                ),
              ],
              t('sum_goat_camel'),
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: palette.isDark ? _Colors.slate800 : _Colors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: palette.isDark ? _Colors.slate700 : _Colors.slate300,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) SizedBox(width: 6 * s),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          ),
        ),
        if (showNext) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.ink(_Colors.amber400),
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// One S1 card: group name, icon and its two features.
  Widget _plantCard(
    String name,
    Color color,
    _Glyph glyph,
    String first,
    String second,
  ) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate900 : _Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: p.isDark ? _Colors.slate700 : _Colors.slate200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.ink(color),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(name, 0.6),
            ),
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            width: 48 * s,
            height: 48 * s,
            child: CustomPaint(painter: _GlyphPainter(glyph)),
          ),
          SizedBox(height: 6 * s),
          Text(
            '$first\n$second',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// One S2 card: habitat, where they live, icons and the animals.
  Widget _habitatCard(
    String name,
    String where,
    Color color,
    List<(_Glyph, Color)> icons,
    String animals,
  ) {
    final p = palette;
    final s = scale;
    final side = icons.length == 1 ? 52 * s : 40 * s;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate900 : _Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(color),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(name, 0.6),
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            where,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < icons.length; i++) ...[
                if (i > 0) SizedBox(width: 6 * s),
                Container(
                  width: side,
                  height: side,
                  padding: EdgeInsets.all(side * 0.17),
                  decoration: BoxDecoration(
                    color: icons[i].$2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(painter: _GlyphPainter(icons[i].$1)),
                ),
              ],
            ],
          ),
          SizedBox(height: 6 * s),
          Text(
            animals,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 11.5 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Tokens of an SVG path: a command letter or a number.
final RegExp _svgToken = RegExp(
  r'[MmLlHhVvCcSsZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
);
final RegExp _svgCommand = RegExp(r'^[A-Za-z]$');

/// Parses an SVG path `d` string into a [Path]: M, L, H, V, C, S and Z
/// with their relative forms and repeated arguments (the commands the HTML
/// icons use).
Path _svgPath(String d) {
  final tokens = [for (final m in _svgToken.allMatches(d)) m.group(0)!];
  final path = Path();
  var i = 0;
  var cmd = '';
  var x = 0.0, y = 0.0; // current point
  var sx = 0.0, sy = 0.0; // subpath start
  var cx = 0.0, cy = 0.0; // last cubic control point (for S)
  var lastCubic = false;
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (_svgCommand.hasMatch(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty || cmd == 'Z' || cmd == 'z') {
      i++;
      continue;
    }
    final rel = cmd == cmd.toLowerCase();
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    var cubic = false;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + n();
        y = oy + n();
        path.moveTo(x, y);
        sx = x;
        sy = y;
        // Further pairs are line-tos.
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = ox + n();
        y = oy + n();
        path.lineTo(x, y);
      case 'H':
        x = ox + n();
        path.lineTo(x, y);
      case 'V':
        y = oy + n();
        path.lineTo(x, y);
      case 'C':
        final x1 = ox + n(), y1 = oy + n();
        cx = ox + n();
        cy = oy + n();
        x = ox + n();
        y = oy + n();
        path.cubicTo(x1, y1, cx, cy, x, y);
        cubic = true;
      case 'S':
        final x1 = lastCubic ? 2 * x - cx : x;
        final y1 = lastCubic ? 2 * y - cy : y;
        cx = ox + n();
        cy = oy + n();
        x = ox + n();
        y = oy + n();
        path.cubicTo(x1, y1, cx, cy, x, y);
        cubic = true;
      case 'Z':
        path.close();
        x = sx;
        y = sy;
    }
    lastCubic = cubic;
  }
  return path;
}

/// The HTML `SVGs` icons in their 24 x 24 view box, parsed once.
abstract final class _Icons {
  static final Path human = _svgPath(
    'M12 2C10.9 2 10 2.9 10 4C10 5.1 10.9 6 12 6C13.1 6 14 5.1 14 4C14 2.9 '
    '13.1 2 12 2ZM8 22V15.5L10 15V10C9.6 10 9 10 9 10H8C6.9 10 6 9.1 6 8V7H18'
    'V8C18 9.1 17.1 10 16 10H15C15 10 14.4 10 14 10V15L16 15.5V22H14V17H10V22'
    'H8Z',
  );
  static final Path finLight = _svgPath(
    'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 '
    '14.59V15c0-.55.45-1 1-1s1 .45 1 1v1.59c.91-.32 1.5-.91 1.5-1.59 0-.83-'
    '.67-1.5-1.5-1.5s-1.5.67-1.5 1.5c0 .68.59 1.27 1.5 1.59V18c0 .55-.45 1-1 '
    '1s-1-.45-1-1v-1.41c-.91.32-1.5.91-1.5 1.59 0 .83.67 1.5 1.5 1.5s1.5-.67 '
    '1.5-1.5c0-.68-.59-1.27-1.5-1.59z',
  );
  static final Path finInk = _svgPath(
    'M12.5 16.59V18c0 .55-.45 1-1 1s-1-.45-1-1v-1.41c-.91.32-1.5.91-1.5 1.59 '
    '0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5c0-.68-.59-1.27-1.5-1.59V15c0-.55'
    '.45-1 1-1s1 .45 1 1v1.59c.91-.32 1.5-.91 1.5-1.59 0-.83-.67-1.5-1.5-'
    '1.5s-1.5.67-1.5 1.5c0 .68.59 1.27 1.5 1.59z',
  );
  static final Path hoofLight = _svgPath(
    'M17.7 5.3c-.4-.4-1-.4-1.4 0l-1.4 1.4c-.4.4-.4 1 0 1.4.4.4 1 .4 1.4 0l1.4'
    '-1.4c.4-.4.4-1 0-1.4zM8.7 15.3c.4.4 1 .4 1.4 0l1.4-1.4c.4-.4.4-1 0-1.4-'
    '.4-.4-1-.4-1.4 0l-1.4 1.4c-.4.4-.4 1 0 1.4z',
  );
  static final Path hoofInk = _svgPath(
    'M19 12c-1.1 0-2 .9-2 2v5c0 .6-.4 1-1 1s-1-.4-1-1v-5c0-1.1-.9-2-2-2s-2 .9'
    '-2 2v5c0 .6-.4 1-1 1s-1-.4-1-1v-5c0-1.1-.9-2-2-2s-2 .9-2 2v5c0 .6-.4 1-1'
    ' 1s-1-.4-1-1v-5c0-1.1-.9-2-2-2H3v-2h1c1.1 0 2-.9 2-2V5c0-.6.4-1 1-1s1 .4'
    ' 1 1v3c0 1.1.9 2 2 2s2-.9 2-2V5c0-.6.4-1 1-1s1 .4 1 1v3c0 1.1.9 2 2 2s2-'
    '.9 2-2V5c0-.6.4-1 1-1s1 .4 1 1v3c0 1.1.9 2 2 2h1v2h-1z',
  );
  static final Path hump = _svgPath(
    'M3 18v-2c0-3 2.5-5 5-5 1.5 0 2.5 1 3.5 2 1-1 2-2 3.5-2 2.5 0 5 2 5 5v2H3z',
  );
  static final Path herb = _svgPath(
    'M12 22v-8m0 0C9 14 6 17 6 17s0-4 3-6c-3 0-6 2-6 2s1-4 4-5c3-1 5 0 5 0s-2'
    '-2-5-1c-1 0-1-2 1-2 3 0 6 3 6 3s3-3 6-3c2 0 2 2 1 2-3-1-5 1-5 1s2-1 5 0c3'
    ' 1 4 5 4 5s-3-2-6-2c3 2 3 6 3 6s-3-3-6-3v8Z',
  );
  static final Path shrub = _svgPath(
    'M12 22v-6m-4 6v-5m8 5v-4M7 10C5 10 3 12 3 14c0 2 2 3 4 3 0 2 2 4 5 4 3 0'
    ' 5-2 5-4 2 0 4-1 4-3 0-2-2-4-4-4 0-3-3-5-6-5-3 0-6 2-4 5Z',
  );
  static final Path tree = _svgPath(
    'M11 22h2v-8h-2v8ZM12 2C7 2 3 5 3 10c0 4 3 6 5 7 0 1 1 2 2 2h4c1 0 2-1 2-'
    '2 2-1 5-3 5-7 0-5-4-8-9-8Z',
  );
}

/// Pictures of the inspection card and the summary (HTML `SVGs`).
enum _Glyph { human, fin, hoof, hump, herb, shrub, tree }

/// Draws [glyph] into [box] with the reused [fill] and [stroke] paints.
void _drawGlyph(
  Canvas canvas,
  _Glyph glyph,
  Rect box,
  Paint fill,
  Paint stroke,
) {
  canvas.save();
  canvas.translate(box.left, box.top);
  canvas.scale(box.width / 24, box.height / 24);
  switch (glyph) {
    case _Glyph.human:
      canvas.drawPath(_Icons.human, fill..color = _Colors.slate500);
    case _Glyph.fin:
      canvas.drawPath(_Icons.finLight, fill..color = _Colors.iconLight);
      canvas.drawPath(_Icons.finInk, fill..color = _Colors.iconInk);
    case _Glyph.hoof:
      canvas.drawPath(_Icons.hoofLight, fill..color = _Colors.iconLight);
      canvas.drawPath(_Icons.hoofInk, fill..color = _Colors.iconInk);
    case _Glyph.hump:
      canvas.drawPath(_Icons.hump, fill..color = _Colors.iconLight);
      canvas.drawPath(
        _Icons.hump,
        stroke
          ..strokeWidth = 2
          ..color = _Colors.iconInk,
      );
    case _Glyph.herb:
      canvas.drawPath(_Icons.herb, fill..color = _Colors.green500);
    case _Glyph.shrub:
      canvas.drawPath(_Icons.shrub, fill..color = _Colors.amber600);
    case _Glyph.tree:
      canvas.drawPath(_Icons.tree, fill..color = _Colors.orange700);
  }
  canvas.restore();
}

/// A static icon for widgets (the summary). Shares its paints.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph);

  final _Glyph glyph;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) =>
      _drawGlyph(canvas, glyph, Offset.zero & size, _fill, _stroke);

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.glyph != glyph;
}

/// The inspection card's picture (HTML `#inspect-visual`, a 128 px box):
/// plants stand next to a person for scale (the tomato's thin green stem
/// pulses, the rose's brown stem branches at its foot, the mango's trunk
/// is thick); the fish shows its fin, the goat a hoof, the camel a hoof
/// and its hump.
class _InspectPainter extends CustomPainter {
  _InspectPainter({required this.obj, required this.time})
    : super(repaint: obj == _Obj.tomato ? time : null);

  final _Obj obj;
  final ValueListenable<double> time;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  static final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 128, size.height / 128);
    switch (obj) {
      case _Obj.tomato || _Obj.rose || _Obj.mango:
        // `absolute left-2 bottom-2`: the person, 48 px.
        _drawGlyph(
          canvas,
          _Glyph.human,
          const Rect.fromLTWH(8, 72, 48, 48),
          _fill,
          _stroke,
        );
        _paintStem(canvas);
      case _Obj.fish:
        _drawGlyph(
          canvas,
          _Glyph.fin,
          const Rect.fromLTWH(40, 40, 48, 48),
          _fill,
          _stroke,
        );
      case _Obj.goat:
        _drawGlyph(
          canvas,
          _Glyph.hoof,
          const Rect.fromLTWH(40, 40, 48, 48),
          _fill,
          _stroke,
        );
      case _Obj.camel:
        // `flex gap-2`: hoof and hump side by side.
        _drawGlyph(
          canvas,
          _Glyph.hoof,
          const Rect.fromLTWH(12, 40, 48, 48),
          _fill,
          _stroke,
        );
        _drawGlyph(
          canvas,
          _Glyph.hump,
          const Rect.fromLTWH(68, 40, 48, 48),
          _fill,
          _stroke,
        );
    }
    canvas.restore();
  }

  /// HTML `tomatoStem`, `roseStem` and `mangoTrunk`, bottom-right.
  void _paintStem(Canvas canvas) {
    switch (obj) {
      case _Obj.tomato:
        // `w-2 h-12 bg-green-500 rounded-full animate-pulse` and its glow.
        final o = _pulse(time.value);
        final stem = RRect.fromRectAndRadius(
          const Rect.fromLTWH(96, 64, 8, 48),
          const Radius.circular(4),
        );
        canvas.drawRRect(
          stem,
          _glow..color = _Colors.green500.withValues(alpha: 0.9 * o),
        );
        canvas.drawRRect(
          stem,
          _fill..color = _Colors.green500.withValues(alpha: o),
        );
      case _Obj.rose:
        // `w-3 h-12 bg-amber-800` and two `w-2 h-8` branches at its foot,
        // turned ±45° about their bottom centres.
        _fill.color = _Colors.amber800;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(92, 64, 12, 48),
            const Radius.circular(2),
          ),
          _fill,
        );
        for (final (x, turn) in const [(88.0, 0.25), (108.0, -0.25)]) {
          canvas.save();
          canvas.translate(x, 112);
          canvas.rotate(turn * math.pi);
          canvas.drawRect(const Rect.fromLTWH(-4, -32, 8, 32), _fill);
          canvas.restore();
        }
      case _Obj.mango:
        // `w-8 h-12 bg-amber-900`.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(80, 64, 32, 48),
            const Radius.circular(2),
          ),
          _fill..color = _Colors.amber900,
        );
      case _Obj.fish || _Obj.goat || _Obj.camel:
        break;
    }
  }

  /// Tailwind `animate-pulse`: opacity 1 → 0.5 → 1 every 2 s.
  static double _pulse(double t) {
    final k = (t % 2) / 2;
    final e = Curves.easeInOut.transform(k < 0.5 ? k * 2 : 2 - k * 2);
    return 1 - 0.5 * e;
  }

  @override
  bool shouldRepaint(covariant _InspectPainter old) =>
      old.obj != obj || old.time != time;
}

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  /// The drop ring's soft glow.
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// Opacity of a translucent mesh (the water).
  final Paint layer = Paint();
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour, drawn on a unit circle) and the label text painters.
/// Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<int, Paint> _balls = {};
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
    final tp = label(text);
    return Size(
      tp.width + 2 * _chipPadX * _labelSize,
      tp.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle, lit from the upper right like the HTML key light.
  Paint ball(Color c) => _balls[c.toARGB32()] ??= () {
    final lit = _lit(c, _viewNormal);
    return Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.4),
        1.4,
        [labShade(lit, 0.35), lit, labShade(c, -0.3)],
        const [0, 0.45, 1],
      );
  }();

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    _balls.clear();
  }
}

/// HTML lights: `AmbientLight(0xffffff, 0.6)`, the warm key light
/// `DirectionalLight(0xfff5b6, 0.8)` at (15, 25, 15) and the bluish fill
/// light `DirectionalLight(0xaabbff, 0.3)` at (-15, 10, -15), normalised.
const _V _keyLight = _V(0.4575, 0.7625, 0.4575);
const _V _fillLight = _V(-0.6396, 0.4264, -0.6396);
const double _ambient = 0.6;
const double _keyPower = 0.8;
const double _fillPower = 0.3;
const List<double> _keyTint = [1, 0.961, 0.714];
const List<double> _fillTint = [0.667, 0.733, 1];

/// A surface turned to the start camera (round meshes) and the side of an
/// upright mesh turned to the camera and the key light.
const _V _viewNormal = _V(0, 0.49, 0.87);
const _V _sideNormal = _V(0.35, 0.25, 0.9);

/// Nothing closer to the camera plane than this is drawn (the ground and
/// grass behind a close-up camera).
const double _clipDepth = 0.5;

/// An unturned group at the world origin.
const _Xf _world = _Xf.at(_V.zero);

/// MeshStandardMaterial look: ambient light plus both directional lights'
/// Lambert terms on a surface with normal [n].
Color _lit(Color c, _V n) {
  final k = _keyPower * math.max(0.0, n.dot(_keyLight));
  final f = _fillPower * math.max(0.0, n.dot(_fillLight));
  double channel(double v, int i) =>
      math.min(1.0, v * (_ambient + k * _keyTint[i] + f * _fillTint[i]));
  return Color.from(
    alpha: c.a,
    red: channel(c.r, 0),
    green: channel(c.g, 1),
    blue: channel(c.b, 2),
  );
}

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

/// Mesh drawing in one camera's projection. Meshes are queued with their
/// depth and drawn far to near ([flush]), like the HTML depth buffer.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;
  final List<(double, int, VoidCallback)> _queue = [];

  _Pens get pens => cache.pens;

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
    final path = pens.path..reset();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  // ---------------------------------------------------------- primitives

  /// A shaded ellipse of radii [rx] x [ry] at [c], turned by [angle].
  void blob(Offset c, double rx, double ry, Color color, {double angle = 0}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(math.max(0.01, rx), math.max(0.01, ry));
    canvas.drawCircle(Offset.zero, 1, cache.ball(color));
    canvas.restore();
  }

  /// An ellipsoid at [c] with semi-axes [a], [b], [d] as the camera sees
  /// it: the projected axes' ellipse (eigen-decomposition of Σ q qᵀ).
  void ellipsoid(_V c, _V a, _V b, _V d, Color color) {
    final pa = cam.dp(c, a), pb = cam.dp(c, b), pd = cam.dp(c, d);
    final m00 = pa.dx * pa.dx + pb.dx * pb.dx + pd.dx * pd.dx;
    final m01 = pa.dx * pa.dy + pb.dx * pb.dy + pd.dx * pd.dy;
    final m11 = pa.dy * pa.dy + pb.dy * pb.dy + pd.dy * pd.dy;
    final mean = (m00 + m11) / 2;
    final spread = math.sqrt(
      math.max(0.0, (m00 - m11) * (m00 - m11) / 4 + m01 * m01),
    );
    blob(
      cam.p(c),
      math.sqrt(mean + spread),
      math.sqrt(math.max(0.0, mean - spread)),
      color,
      angle: 0.5 * math.atan2(2 * m01, m00 - m11),
    );
  }

  /// SphereGeometry of radius [r] in the frame [xf] (its axes carry the
  /// mesh scale).
  void sphere(_Xf xf, double r, Color color, {double? depth}) => later(
    depth ?? cam.depth(xf.o),
    () => ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color),
  );

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf], its axis
  /// along the frame's y.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 8,
    double? depth,
    double opacity = 1,
  }) => later(
    depth ?? cam.depth(xf.o),
    () => drawCylinder(
      xf,
      rTop,
      rBottom,
      h,
      color,
      segments: segments,
      opacity: opacity,
    ),
  );

  /// Draws a cylinder now: its outline (hull of both rims), shading along
  /// its side and the end cap turned to the camera.
  void drawCylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 8,
    double opacity = 1,
  }) {
    final hh = h / 2;
    final top = <Offset>[];
    final bottom = <Offset>[];
    for (var i = 0; i < segments; i++) {
      final t = 2 * math.pi * i / segments;
      final c = math.cos(t), s = math.sin(t);
      top.add(cam.p(xf(rTop * c, hh, rTop * s)));
      bottom.add(cam.p(xf(rBottom * c, -hh, rBottom * s)));
    }
    final a = xf(0, -hh, 0), b = xf(0, hh, 0);
    final body = _lit(color, _sideNormal);
    final translucent = opacity < 1;
    if (translucent) {
      canvas.saveLayer(
        null,
        pens.layer..color = _Colors.black.withValues(alpha: opacity),
      );
    }
    canvas.drawPath(
      polygon(_hull([...top, ...bottom])),
      pens.fill..color = body,
    );
    _bands(
      cam.p(a),
      cam.p(b),
      rBottom * cam.scaleAt(a),
      rTop * cam.scaleAt(b),
      body,
    );
    final axis = xf.y.unit;
    final showTop = (cam.eye - b).dot(axis) > 0;
    if ((showTop ? rTop : rBottom) > 0.0005) {
      canvas.drawPath(
        polygon(showTop ? top : bottom),
        pens.fill..color = _lit(color, showTop ? axis : -axis),
      );
    }
    if (translucent) canvas.restore();
  }

  /// Shading bands along a mesh's side from [pa] to [pb] (half widths [wa],
  /// [wb]): shadow away from the key light, highlight towards it.
  void _bands(Offset pa, Offset pb, double wa, double wb, Color body) {
    final d = pb - pa;
    final len = d.distance;
    if (len < 1 || wa + wb < 2) return;
    var n = Offset(-d.dy / len, d.dx / len);
    // The key light comes from the upper right of the screen.
    if (n.dy > 0 || (n.dy == 0 && n.dx < 0)) n = -n;
    void band(double from, double to, Color color) => canvas.drawPath(
      polygon([
        pa + n * (wa * from),
        pb + n * (wb * from),
        pb + n * (wb * to),
        pa + n * (wa * to),
      ]),
      pens.fill..color = color,
    );
    band(-0.92, -0.3, labShade(body, -0.2));
    band(0.28, 0.6, labShade(body, 0.22));
  }

  /// ConeGeometry([r], [h]) centred on [xf], apex along the frame's y.
  void cone(
    _Xf xf,
    double r,
    double h,
    Color color, {
    int segments = 12,
    double? depth,
  }) => later(depth ?? cam.depth(xf.o), () {
    final hh = h / 2;
    final pts = <Offset>[cam.p(xf(0, hh, 0))];
    for (var i = 0; i < segments; i++) {
      final t = 2 * math.pi * i / segments;
      pts.add(cam.p(xf(r * math.cos(t), -hh, r * math.sin(t))));
    }
    final axis = xf.y.unit;
    final toCam = (cam.eye - xf.o).unit;
    final side = toCam - axis * toCam.dot(axis);
    final n = side.length < 1e-6 ? toCam : side.unit;
    final path = polygon(_hull(pts));
    canvas.drawPath(path, pens.fill..color = _lit(color, n));
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 0.6
        ..color = labShade(color, -0.35).withValues(alpha: 0.5),
    );
  });

  /// BoxGeometry of [size] centred on [xf].
  void box(_Xf xf, _V size, Color color) => later(cam.depth(xf.o), () {
    final pts = [
      for (var i = 0; i < 8; i++)
        cam.p(
          xf(
            ((i & 1) != 0 ? 0.5 : -0.5) * size.x,
            ((i & 2) != 0 ? 0.5 : -0.5) * size.y,
            ((i & 4) != 0 ? 0.5 : -0.5) * size.z,
          ),
        ),
    ];
    canvas.drawPath(
      polygon(_hull(pts)),
      pens.fill..color = _lit(color, _viewNormal),
    );
  });

  /// The part of a sphere of radius [r] on [xf] whose points pass [keep]
  /// (local and world point): dunes above the island, the goat's patch.
  /// Shaded like a ball, clipped to the kept part's outline.
  void dome(
    _Xf xf,
    double r,
    Color color,
    bool Function(_V local, _V world) keep, {
    double? depth,
  }) => later(depth ?? cam.depth(xf.o), () {
    final pts = <Offset>[];
    for (var i = 0; i <= 12; i++) {
      final th = math.pi * i / 12;
      final st = math.sin(th), ct = math.cos(th);
      for (var j = 0; j < 24; j++) {
        final ph = 2 * math.pi * j / 24;
        // Three.js SphereGeometry vertex (phi, theta).
        final local = _V(-r * math.cos(ph) * st, r * ct, r * math.sin(ph) * st);
        final world = xf.at(local);
        if (keep(local, world)) pts.add(cam.p(world));
      }
    }
    if (pts.length < 3) return;
    canvas.save();
    canvas.clipPath(polygon(_hull(pts)));
    ellipsoid(xf.o, xf.x * r, xf.y * r, xf.z * r, color);
    canvas.restore();
  });

  /// TorusKnotGeometry([radius], [tube]) (p = 2, q = 3) at [c]: its centre
  /// line, stroked as a shaded tube.
  void knot(_V c, double radius, double tube, Color color) =>
      later(cam.depth(c), () {
        final path = pens.path..reset();
        const steps = 64;
        for (var i = 0; i <= steps; i++) {
          final u = i / steps * 4 * math.pi;
          final q = 1.5 * u;
          final cs = math.cos(q);
          final s = cam.p(
            c +
                _V(
                  radius * (2 + cs) * 0.5 * math.cos(u),
                  radius * (2 + cs) * 0.5 * math.sin(u),
                  radius * math.sin(q) * 0.5,
                ),
          );
          if (i == 0) {
            path.moveTo(s.dx, s.dy);
          } else {
            path.lineTo(s.dx, s.dy);
          }
        }
        final k = cam.scaleAt(c);
        final lit = _lit(color, _viewNormal);
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = math.max(1.2, 2 * tube * k)
            ..color = labShade(color, -0.3),
        );
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = math.max(0.9, 1.4 * tube * k)
            ..color = lit,
        );
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = math.max(0.5, 0.4 * tube * k)
            ..color = labShade(lit, 0.35),
        );
      });

  /// Soft contact shadow now: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz) {
    if (cam.depth(c) < _clipDepth) return;
    final p = cam.p(c);
    final w = rx * cam.scaleAt(c);
    final h =
        (cam.p(c + _V(0, 0, rz)).dy - cam.p(c - _V(0, 0, rz)).dy).abs() / 2;
    canvas.drawOval(
      Rect.fromCenter(center: p, width: 2 * w, height: 2 * math.max(1, h)),
      pens.shadow,
    );
  }

  /// A glowing ring of [radius] on the horizontal plane through [c] now.
  void ring(_V c, double radius, Color color) {
    final path = polygon([
      for (var i = 0; i < 48; i++)
        cam.p(
          c +
              _V(
                radius * math.cos(i * math.pi / 24),
                0,
                radius * math.sin(i * math.pi / 24),
              ),
        ),
    ]);
    canvas.drawPath(
      path,
      pens.glow
        ..strokeWidth = 7
        ..color = color.withValues(alpha: 0.7),
    );
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 2.4
        ..color = color,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the park
/// (grass, the Herbs / Shrubs / Trees plots, tomato, rose and mango), S2
/// the three habitat islands (ocean, plain, desert) with the fish, goat
/// and camel; then the labels.
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
    final g = _Gfx(canvas, s.camera(), cache);
    final sky = isDark ? _Colors.sceneDark : _Colors.sceneLight;
    canvas.drawRect(labBleed(size), _pens.fill..color = sky);
    _paintGround(g, s.scenario == 0 ? _Colors.park : _Colors.floor, sky);
    if (s.scenario == 0) {
      _paintPark(g);
    } else {
      _paintHabitats(g);
    }
    g.flush();
    if (showLabels) _paintLabels(g);
  }

  /// Ground `PlaneGeometry(40, 30)`, fading into the background colour with
  /// distance (HTML `FogExp2`).
  void _paintGround(_Gfx g, Color color, Color sky) {
    final cam = g.cam;
    final ground = _clipNear(
      const [
        _V(-_groundHalfW, 0, -_groundHalfD),
        _V(_groundHalfW, 0, -_groundHalfD),
        _V(_groundHalfW, 0, _groundHalfD),
        _V(-_groundHalfW, 0, _groundHalfD),
      ],
      cam,
      _clipDepth,
    );
    if (ground.length < 3) return;
    final lit = _lit(color, _V.up);
    Color fogged(_V at) {
      final d = cam.depth(at) * _fogDensity;
      return Color.lerp(lit, sky, 1 - math.exp(-d * d))!;
    }

    final near =
        cam.onPlaneY(Offset(cam.center.dx, _design.height), 0) ??
        _V(cam.eye.x, 0, _groundHalfD);
    final far = _V(cam.eye.x, 0, -_groundHalfD);
    final paint = _pens.fill
      ..shader = ui.Gradient.linear(cam.p(near), cam.p(far), [
        fogged(near),
        fogged(far),
      ]);
    g.canvas.drawPath(g.polygon([for (final v in ground) cam.p(v)]), paint);
    paint.shader = null;
  }

  // ---------------------------------------------------------- scenario 1

  /// HTML `buildS1Scene()`.
  void _paintPark(_Gfx g) {
    final s = scene;
    for (final (pos, rx, ry, rz) in _Scatter.tufts) {
      g.cone(
        _world.child(pos, rx: rx, ry: ry, rz: rz),
        0.1,
        0.4,
        _Colors.grass,
        segments: 3,
      );
    }
    for (final z in _Zone.of(0)) {
      _paintPlot(g, z);
    }
    for (final p in s.poses) {
      final at = s.posOf(p);
      _paintShadow(g, p.obj, at);
      switch (p.obj) {
        case _Obj.tomato:
          _paintTomato(g, at);
        case _Obj.rose:
          _paintRose(g, at);
        case _Obj.mango || _Obj.fish || _Obj.goat || _Obj.camel:
          _paintMango(g, at);
      }
    }
  }

  /// HTML `createPlotBox`: a dark dirt mound with six pebbles around it;
  /// the glowing ring marks the plot under a held plant (added).
  void _paintPlot(_Gfx g, _Zone z) {
    final hovered = scene.hover == z;
    g.later(g.cam.depth(z.pos - _V(0, 0, z.radius)), () {
      if (hovered) {
        g.ring(z.pos + const _V(0, 0.02, 0), z.radius + 0.1, _Colors.dropRing);
      }
      g.drawCylinder(
        _world.child(z.pos + const _V(0, 0.15, 0)),
        z.radius - 0.2,
        z.radius,
        0.3,
        _Colors.dirt,
        segments: 16,
      );
    });
    for (final pebble in _Scatter.pebbles[z.index]) {
      g.sphere(_world.child(z.pos + pebble, sy: 0.5), 0.1, _Colors.pebble);
    }
  }

  /// Tomato (herb): a thin green stem, six branches with leaf cones and
  /// three red tomatoes.
  void _paintTomato(_Gfx g, _V at) {
    final t = _world.child(at);
    g.cylinder(
      t.child(const _V(0, 0.7, 0), rz: 0.05),
      0.04,
      0.05,
      1.4,
      _Colors.tomatoStem,
      segments: 6,
    );
    for (var i = 0; i < 6; i++) {
      final h = 0.4 + i * 0.15;
      final a = i * 2.4;
      final ca = math.cos(a), sa = math.sin(a);
      final bp = _V(ca * 0.2, h, sa * 0.2);
      g.cylinder(
        t.child(bp, rx: ca * 0.8, ry: a, rz: sa * 0.8),
        0.015,
        0.02,
        0.5,
        _Colors.tomatoStem,
        segments: 6,
      );
      for (var j = 0; j < 2; j++) {
        final (lx, lz) = _Scatter.tomatoLeaves[i * 2 + j];
        g.cone(
          t.child(
            bp + _V(ca * 0.2 * (j + 1), 0.1, sa * 0.2 * (j + 1)),
            rx: lx,
            ry: a,
            rz: lz,
          ),
          0.12,
          0.3,
          _Colors.leaf,
          segments: 3,
        );
      }
      if (i.isEven) {
        final fruit = t.child(bp + _V(ca * 0.2, -0.1, sa * 0.2));
        g.sphere(fruit.child(_V.zero, sy: 0.9), 0.12, _Colors.tomato);
        g.cone(
          fruit.child(const _V(0, 0.11, 0)),
          0.04,
          0.05,
          _Colors.leaf,
          segments: 5,
        );
      }
    }
  }

  /// Rose (shrub): seven woody stems from the base, leaves along them and
  /// four red flowers.
  void _paintRose(_Gfx g, _V at) {
    final r = _world.child(at);
    for (var i = 0; i < 7; i++) {
      final a = i * 1.5;
      final dist = _Scatter.roseDist[i];
      final stem = r.child(
        _V(math.cos(a) * dist, 0, math.sin(a) * dist),
        rx: math.sin(a) * 0.3,
        ry: a,
        rz: -math.cos(a) * 0.3,
      );
      g.cylinder(
        stem.child(const _V(0, 1.1, 0)),
        0.03,
        0.05,
        2.2,
        _Colors.roseStem,
        segments: 5,
      );
      for (var j = 0; j < 4; j++) {
        final lift = 0.6 + j * 0.4 + _Scatter.roseLeafLift[i * 4 + j];
        final leaf = stem.child(_V(0, lift, 0), rx: 0.3, ry: j * 2.1);
        g.sphere(
          leaf.child(const _V(0, 0, 0.15), sy: 0.1, sz: 2),
          0.12,
          _Colors.roseLeaf,
        );
      }
      if (i < 4) {
        final flower = stem.child(const _V(0, 2.2, 0));
        for (var f = 0; f < 5; f++) {
          final (pos, ax, ay, az) = _Scatter.petals[i * 5 + f];
          g.sphere(
            flower.child(pos, rx: ax, ry: ay, rz: az, sy: 0.3, sz: 1.5),
            0.08,
            _Colors.rose,
          );
        }
      }
    }
  }

  /// Mango (tree): a tapered trunk with roots, a canopy of eight leaf
  /// clumps and the mangoes hanging below it.
  void _paintMango(_Gfx g, _V at) {
    final m = _world.child(at);
    g.cylinder(
      m.child(const _V(0, 1.75, 0)),
      0.25,
      0.5,
      3.5,
      _Colors.mangoTrunk,
    );
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      g.cylinder(
        m.child(
          _V(math.cos(a) * 0.5, 0.2, math.sin(a) * 0.5),
          rx: math.pi / 2 - 0.3,
          rz: -a,
        ),
        0.05,
        0.2,
        1.2,
        _Colors.mangoTrunk,
        segments: 5,
      );
    }
    final canopy = m.child(const _V(0, 4, 0));
    for (final (x, y, z, s) in _Scatter.canopy) {
      g.sphere(canopy.child(_V(x, y, z)), 1.2 * s, _Colors.canopy);
    }
    for (final pos in _Scatter.mangoes) {
      final fruit = m.child(pos);
      g.sphere(
        fruit.child(const _V(0, -0.2, 0), sy: 1.4, sz: 0.9),
        0.15,
        _Colors.mango,
      );
      g.cylinder(fruit, 0.01, 0.01, 0.2, _Colors.mangoTrunk, segments: 4);
    }
  }

  /// Soft shadow of an organism standing at [at]: the key light at (15,
  /// 25, 15) casts it towards -x / -z, onto the ground or onto the plot /
  /// island under it.
  void _paintShadow(_Gfx g, _Obj o, _V at) {
    final (lift, rx, rz) = switch (o) {
      _Obj.tomato => (0.8, 0.55, 0.5),
      _Obj.rose => (1.2, 0.8, 0.75),
      _Obj.mango => (4.5, 2.4, 2.2),
      _Obj.fish => (1.0, 1.2, 0.35),
      _Obj.goat => (1.0, 1.0, 0.45),
      _Obj.camel => (1.8, 1.4, 0.6),
    };
    void cast(_V c, double halfW, double halfD) {
      _Zone? under;
      for (final z in _Zone.of(o.index ~/ 3)) {
        if (c.flatDistance(z.pos) < z.radius) under = z;
      }
      final on = under;
      if (on == null) {
        g.shadow(c + const _V(0, 0.01, 0), halfW, halfD);
        return;
      }
      // On a plot / island: just after its mound, before what stands on it.
      g.later(
        g.cam.depth(on.pos - _V(0, 0, on.radius)) - 0.001,
        () => g.shadow(c + _V(0, on.top + 0.01, 0), halfW, halfD),
      );
    }

    cast(at - _V(0.6 * lift, 0, 0.6 * lift), rx, rz);
    if (o == _Obj.mango) cast(at - const _V(0.3, 0, 0.3), 0.7, 0.6);
  }

  // ---------------------------------------------------------- scenario 2

  /// HTML `buildS2Scene()`.
  void _paintHabitats(_Gfx g) {
    final s = scene;
    for (final z in _Zone.of(1)) {
      _paintIsland(g, z);
    }
    for (final p in s.poses) {
      final at = s.posOf(p);
      _paintShadow(g, p.obj, at);
      switch (p.obj) {
        case _Obj.fish:
          _paintFish(g, at);
        case _Obj.goat:
          _paintGoat(g, at);
        case _Obj.camel || _Obj.tomato || _Obj.rose || _Obj.mango:
          _paintCamel(g, at);
      }
    }
  }

  /// HTML `createDiorama`: a round island (sea floor, grass or sand) with
  /// its habitat on top; the glowing ring marks the island under a held
  /// animal (added).
  void _paintIsland(_Gfx g, _Zone z) {
    final base = _world.child(z.pos);
    final hovered = scene.hover == z;
    final color = switch (z) {
      _Zone.ocean => _Colors.seaFloor,
      _Zone.desert => _Colors.desert,
      _ => _Colors.plain,
    };
    g.later(g.cam.depth(z.pos - _V(0, 0, z.radius)), () {
      if (hovered) {
        g.ring(z.pos + const _V(0, 0.02, 0), z.radius + 0.1, _Colors.dropRing);
      }
      g.drawCylinder(
        base.child(const _V(0, 0.25, 0)),
        3.5,
        4,
        0.5,
        color,
        segments: 32,
      );
    });
    switch (z) {
      case _Zone.ocean:
        _paintOcean(g, z, base);
      case _Zone.desert:
        _paintDesert(g, z, base);
      case _Zone.plain || _Zone.herbs || _Zone.shrubs || _Zone.trees:
        _paintPlain(g, base);
    }
  }

  /// Ocean: a rock, a torus-knot coral, a pink coral, three seaweeds and
  /// the 40 % opaque water column over them.
  void _paintOcean(_Gfx g, _Zone z, _Xf base) {
    g.sphere(base.child(const _V(-1.5, 0.6, -1.5)), 0.6, _Colors.seaRock);
    g.knot(base(-1.5, 1.2, -1.5), 0.3, 0.1, _Colors.coralRed);
    g.sphere(base.child(const _V(1.5, 0.8, -1), sy: 2), 0.4, _Colors.coralPink);
    for (var i = 0; i < 3; i++) {
      g.cylinder(
        base.child(
          _V(0.5 + i * 0.3, 1, 1.5 + (i % 2) * 0.2),
          rx: math.sin(i) * 0.2,
          rz: math.cos(i) * 0.2,
        ),
        0.05,
        0.02,
        1.2,
        _Colors.seaweed,
        segments: 5,
      );
    }
    // Drawn after everything inside it (its front edge is the nearest).
    g.cylinder(
      base.child(const _V(0, 1.25, 0)),
      3.5,
      3.5,
      1.5,
      _Colors.water,
      segments: 32,
      opacity: 0.4,
      depth: g.cam.depth(z.pos + const _V(0, 1.25, 3.5)),
    );
  }

  /// Desert: two sand dunes, a cactus with two arms and four rocks.
  void _paintDesert(_Gfx g, _Zone z, _Xf base) {
    bool above(_V local, _V world) => world.y >= z.top - 0.001;
    // The low dunes are part of the island's surface: drawn right after it,
    // under whatever stands on them.
    final surface = g.cam.depth(z.pos - _V(0, 0, z.radius)) - 0.002;
    g.dome(
      base.child(const _V(-0.5, 0.4, -1), sy: 0.25, sz: 0.8),
      2.5,
      _Colors.desert,
      above,
      depth: surface,
    );
    g.dome(
      base.child(const _V(1.5, 0.3, 1), sx: 0.8, sy: 0.3),
      1.8,
      _Colors.desert,
      above,
      depth: surface,
    );
    final c = base.child(const _V(-2, 0.2, 1.5));
    g.cylinder(c.child(const _V(0, 0.8, 0)), 0.2, 0.2, 1.4, _Colors.cactus);
    g.cylinder(
      c.child(const _V(0.3, 1, 0), rz: -0.8),
      0.12,
      0.12,
      0.6,
      _Colors.cactus,
    );
    g.cylinder(c.child(const _V(0.5, 1.4, 0)), 0.12, 0.12, 0.5, _Colors.cactus);
    g.cylinder(
      c.child(const _V(-0.3, 0.7, 0), rz: 0.8),
      0.12,
      0.12,
      0.5,
      _Colors.cactus,
    );
    g.cylinder(c.child(const _V(-0.45, 1, 0)), 0.12, 0.12, 0.4, _Colors.cactus);
    for (final rock in _Scatter.desertRocks) {
      g.sphere(base.child(rock), 0.15, _Colors.desertRock);
    }
  }

  /// Plain: a small tree and eight grass tufts.
  void _paintPlain(_Gfx g, _Xf base) {
    final tree = base.child(const _V(-1.5, 0.5, -1.5));
    g.cylinder(
      tree.child(const _V(0, 0.75, 0)),
      0.15,
      0.2,
      1.5,
      _Colors.treeTrunk,
      segments: 6,
    );
    g.sphere(tree.child(const _V(0, 1.8, 0)), 0.8, _Colors.canopy);
    g.sphere(tree.child(const _V(0.5, 1.5, 0)), 0.6, _Colors.canopy);
    g.sphere(tree.child(const _V(-0.5, 1.6, 0.3)), 0.6, _Colors.canopy);
    for (final (pos, rx, ry, rz) in _Scatter.plainGrass) {
      g.cone(
        base.child(pos, rx: rx, ry: ry, rz: rz),
        0.1,
        0.3,
        _Colors.grass,
        segments: 3,
      );
    }
  }

  /// Fish: streamlined body, tail, dorsal and pectoral fins, eyes.
  void _paintFish(_Gfx g, _V at) {
    final f = _world.child(at);
    g.sphere(
      f.child(const _V(0, 1, 0), sx: 1.6, sy: 0.8, sz: 0.4),
      0.7,
      _Colors.fish,
    );
    g.cone(
      f.child(const _V(-1.1, 1, 0), rz: -math.pi / 2, sx: 0.2),
      0.5,
      0.8,
      _Colors.fin,
      segments: 16,
    );
    g.cone(
      f.child(const _V(0.1, 1.6, 0), rz: -0.5, sz: 0.2),
      0.3,
      0.6,
      _Colors.fin,
      segments: 16,
    );
    for (final side in const [1.0, -1.0]) {
      g.cone(
        f.child(_V(0.3, 0.7, side * 0.3), rx: -side * 0.5, rz: 1, sz: 0.2),
        0.2,
        0.5,
        _Colors.fin,
        segments: 16,
      );
      final eye = f.child(_V(0.6, 1.1, side * 0.25));
      g.sphere(eye, 0.08, _Colors.eyeWhite);
      g.sphere(eye.child(_V(0, 0, side * 0.06)), 0.04, _Colors.pupil);
    }
  }

  /// Goat: body with a brown patch, neck, head with snout, curved horns,
  /// floppy ears and eyes, tail and four legs with dark hooves.
  void _paintGoat(_Gfx g, _V at) {
    final b = _world.child(at);
    g.cylinder(
      b.child(const _V(0, 1, 0), rz: math.pi / 2),
      0.4,
      0.4,
      1.2,
      _Colors.goat,
      segments: 16,
    );
    // `SphereGeometry(0.42, …, 0, π, 0, π / 2)`: the top front quarter.
    g.dome(
      b.child(const _V(-0.2, 1, 0)),
      0.42,
      _Colors.goatPatch,
      (local, world) => local.y >= -0.001 && local.z >= -0.001,
      depth: g.cam.depth(b(-0.2, 1.2, 0.3)),
    );
    g.cylinder(
      b.child(const _V(0.6, 1.3, 0), rz: -0.4),
      0.2,
      0.25,
      0.6,
      _Colors.goat,
      segments: 12,
    );
    final head = b.child(const _V(0.8, 1.6, 0));
    g.cylinder(
      head.child(_V.zero, rz: math.pi / 2 - 0.2),
      0.2,
      0.2,
      0.6,
      _Colors.goat,
      segments: 12,
    );
    g.sphere(head.child(const _V(0.35, -0.05, 0)), 0.1, _Colors.hoof);
    for (final side in const [1.0, -1.0]) {
      final horn = head.child(
        _V(-0.1, 0.15, side * 0.15),
        rx: side * 0.2,
        rz: -0.3,
      );
      g.cylinder(
        horn.child(const _V(0, 0.15, 0)),
        0.02,
        0.04,
        0.3,
        _Colors.horn,
        segments: 6,
      );
      g.cylinder(
        horn.child(const _V(-0.05, 0.35, 0), rz: 0.4),
        0.005,
        0.02,
        0.2,
        _Colors.horn,
        segments: 6,
      );
      g.cylinder(
        head.child(
          _V(-0.1, 0, side * 0.25),
          rx: side * 0.5,
          ry: side * 0.2,
          rz: -0.5,
        ),
        0.04,
        0.04,
        0.25,
        _Colors.goat,
        segments: 6,
      );
      final eye = head.child(_V(0.1, 0.05, side * 0.18));
      g.sphere(eye, 0.05, _Colors.eyeWhite);
      g.sphere(eye.child(_V(0, 0, side * 0.03)), 0.03, _Colors.pupil);
    }
    g.cylinder(
      b.child(const _V(-0.8, 1.2, 0), rz: -0.5),
      0.05,
      0.05,
      0.25,
      _Colors.goat,
      segments: 6,
    );
    for (var i = 0; i < 4; i++) {
      final leg = b.child(_V(i.isEven ? -0.5 : 0.5, 0, i < 2 ? -0.2 : 0.2));
      g.cylinder(
        leg.child(const _V(0, 0.35, 0)),
        0.08,
        0.06,
        0.7,
        _Colors.goat,
      );
      g.cylinder(
        leg.child(const _V(0, 0.075, 0)),
        0.06,
        0.07,
        0.15,
        _Colors.hoof,
      );
    }
  }

  /// Camel: body, a single large hump, a curved neck of spheres, a head
  /// with ears, tail and four legs (thick thighs, thin calves, wide
  /// hooves).
  void _paintCamel(_Gfx g, _V at) {
    final b = _world.child(at);
    g.cylinder(
      b.child(const _V(0, 1.6, 0), rz: math.pi / 2),
      0.6,
      0.6,
      1.8,
      _Colors.camel,
      segments: 16,
    );
    g.sphere(
      b.child(const _V(0, 2.2, 0), sy: 1.2, sz: 0.8),
      0.6,
      _Colors.camel,
    );
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      g.sphere(
        b.child(_V(0.8 + t * 0.6, 1.8 + t * 0.2 + t * t * 0.6, 0)),
        0.25 - i * 0.015,
        _Colors.camel,
      );
    }
    final head = b.child(const _V(1.6, 2.8, 0), rz: -0.1);
    g.cylinder(
      head.child(_V.zero, rz: math.pi / 2 - 0.2),
      0.2,
      0.2,
      0.7,
      _Colors.camel,
      segments: 12,
    );
    for (final side in const [1.0, -1.0]) {
      g.cone(
        head.child(
          _V(-0.15, 0.1, side * 0.15),
          rx: side * 0.5,
          ry: side * 0.2,
          rz: -0.5,
        ),
        0.05,
        0.2,
        _Colors.camel,
        segments: 8,
      );
    }
    g.cylinder(
      b.child(const _V(-1.1, 1.4, 0), rz: -0.5),
      0.03,
      0.01,
      0.6,
      _Colors.camel,
      segments: 6,
    );
    for (var i = 0; i < 4; i++) {
      final leg = b.child(_V(i.isEven ? -0.8 : 0.8, 0, i < 2 ? -0.35 : 0.35));
      g.cylinder(leg.child(const _V(0, 1, 0)), 0.18, 0.18, 0.6, _Colors.camel);
      g.cylinder(
        leg.child(const _V(0, 0.4, 0)),
        0.08,
        0.06,
        0.8,
        _Colors.camel,
      );
      g.box(
        leg.child(const _V(0.05, 0.05, 0)),
        const _V(0.2, 0.1, 0.25),
        _Colors.camelHoof,
      );
    }
  }

  // ----------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip (HTML `labelDict`):
  /// the groups first, then the organisms (the held one on top).
  void _paintLabels(_Gfx g) {
    final s = scene;
    for (final z in _Zone.of(s.scenario)) {
      _chip(g, z.pos + _V(0, z.labelY, 0), _t(z.labelKey));
    }
    for (final p in s.poses) {
      if (identical(p, s.held)) continue;
      _chip(g, s.posOf(p) + _V(0, p.obj.labelY, 0), _t(p.obj.nameKey));
    }
    final held = s.held;
    if (held != null) {
      _chip(g, held.pos + _V(0, held.obj.labelY, 0), _t(held.obj.nameKey));
    }
  }

  /// HTML `createTextSprite`: dark chip with an indigo border and white
  /// bold text, centred on [at] and kept inside the visible canvas.
  void _chip(_Gfx g, _V at, String text) {
    if (g.cam.depth(at) < _clipDepth) return;
    final size = cache.chipSize(text);
    var rect = Rect.fromCenter(
      center: g.cam.p(at),
      width: size.width,
      height: size.height,
    );
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.45),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text);
    tp.paint(
      g.canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.top + _chipPadY * cache.labelSize,
      ),
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
