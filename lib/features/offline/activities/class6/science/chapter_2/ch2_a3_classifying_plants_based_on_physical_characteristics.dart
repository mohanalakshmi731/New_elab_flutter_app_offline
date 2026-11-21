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

/// Class 6 Science • Chapter 2 • Activity 3
/// Classifying Plants Based on Physical Characteristics.
///
/// Native Flutter port of
/// `Cl6S-Ch02-A3-Classifying_Plants_Based_on_Physical_Characteristics.html`
/// (Three.js r128 + TWEEN). The Three.js scenes are redrawn by a painter
/// that reproduces the HTML PerspectiveCamera (45° field of view, from
/// (0, 12, 18) in Scenario 1 and (0, 10, 15) in Scenario 2, looking at the
/// origin); the HTML's SVG sprites and pictures are drawn from their own
/// path data.
///
/// Scenario 1 (Herbs, Shrubs, and Trees): in a virtual park the learner
/// taps the tomato plant, the rose plant and the mango tree in turn. The
/// view glides to each plant and an inspection card shows its stem: soft
/// and bendy, hard and woody with low branches, a thick trunk. Then the
/// three plants are dragged into the Herb, Shrub and Tree bins, where they
/// shrink into place, and 'Review Classification' opens the summary.
///
/// Scenario 2 (Uncovering Monocots & Dicots): at a lab bench with a
/// chickpea and a maize plant in pots, the learner drops the magnifying
/// glass from the toolkit on each plant's leaf (net-like and parallel
/// veins), drags the X-ray scanner over each pot's soil (a taproot and
/// fibrous roots) and taps each seed on the bench (two cotyledons and one
/// cotyledon); 'Assemble Profiles' shows the dicot and monocot profiles.
class Ch2A3ClassifyingPlantsBasedOnPhysicalCharacteristicsPage
    extends StatefulWidget {
  const Ch2A3ClassifyingPlantsBasedOnPhysicalCharacteristicsPage({super.key});

  @override
  State<Ch2A3ClassifyingPlantsBasedOnPhysicalCharacteristicsPage>
  createState() => _PlantClassificationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, played from the app's own assets
/// (`assets/audio/`). The HTML synthesises its tones with the Web Audio
/// API; each maps to the closest file: 'click' (a plant or a zone is
/// inspected) and 'pop' ('Got it!', the camera going back) →
/// science/click.mp3; 'success' (a plant dropped into its bin), 'chime'
/// (the review button appears) and the summary → math/success.mp3; 'error'
/// (a missed drop, a wrong bin or tool) → science/error.mp3. The sidebar
/// plays science/dropdown.mp3, a scenario change science/page_open.mp3 and
/// the intro curtain science/curtain.mp3.
enum _Sound implements LabTone {
  /// Generic button click; the HTML 'click' when something is inspected.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A plant dropped into its bin (HTML 'success').
  correct('audio/class6/math/success.mp3'),

  /// Missed drop, wrong bin or tool, a step out of turn (HTML 'error').
  wrong('audio/class6/science/error.mp3'),

  /// The review button appears (HTML 'chime') and the summary opens.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// 'Got it!' closes the inspection card and the camera goes back (HTML
  /// 'pop').
  pop('audio/class6/science/click.mp3');

  const _Sound(this.asset);

  /// Asset path, relative to `assets/`.
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
/// (material colours). The SVG pictures keep their own colours (see
/// [_ArtBook]).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color lime400 = Color(0xFFA3E635);
  static const Color lime500 = Color(0xFF84CC16);
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

  /// Toolkit tiles: `bg-blue-100 dark:bg-blue-900/40`, `text-blue-600
  /// dark:text-blue-400`, `border-blue-500/30` (purple for the scanner).
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blueTileDark = Color(0x661E3A8A);
  static const Color blueEdge = Color(0x4D3B82F6);
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purpleTileDark = Color(0x66581C87);
  static const Color purpleEdge = Color(0x4DA855F7);

  /// Inspection card: `bg-white/95 dark:bg-slate-900/95`, the tool badge
  /// `bg-emerald-100 dark:bg-emerald-900/40` and its drop shadow.
  static const Color cardLight = Color(0xF2FFFFFF);
  static const Color cardDark = Color(0xF20F172A);
  static const Color badgeDark = Color(0x66064E3B);
  static const Color cardShadow = Color(0x80000000);

  /// "Select the next" note in the summary: amber-500/10 box, amber-500/20
  /// border.
  static const Color noteBg = Color(0x1AF59E0B);
  static const Color noteBorder = Color(0x33F59E0B);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark theme), 0xe0f2fe (light theme);
  /// the fog fades to the same colour.
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// Key light 0xfff5b6 and fill light 0xaabbff.
  static const Color keyLight = Color(0xFFFFF5B6);
  static const Color fillLight = Color(0xFFAABBFF);

  /// Park ground (0x86efac) and the three bins (0x22c55e, 0xf59e0b,
  /// 0x047857); the highlight ring 0x4ade80.
  static const Color ground = Color(0xFF86EFAC);
  static const Color binHerb = green500;
  static const Color binShrub = amber500;
  static const Color binTree = emerald700;
  static const Color binGlow = green400;

  /// Lab bench (0x94a3b8), terracotta pots (0xb45309) and soil (0x3e2723).
  static const Color bench = slate400;
  static const Color pot = Color(0xFFB45309);
  static const Color soil = Color(0xFF3E2723);

  /// Inspection zones: a 0xffff00 cylinder at opacity 0.1 and an 0x10b981
  /// ring; 0x34d399 while a tool hovers over it.
  static const Color zoneFill = Color(0x1AFFFF00);
  static const Color zoneRing = emerald500;
  static const Color zoneHover = emerald400;

  /// Contact shadows (the HTML scene casts PCF soft shadows) and the
  /// plants' `createShadowBlob` (black, opacity 0.15).
  static const Color shadow = Color(0x52000000);
  static const Color blob = Color(0x26000000);

  /// Text sprites: `#1e293b` chip, `#10b981` border, white text; the zone
  /// labels are white chips with `#10b981` text.
  static const Color chipBg = slate800;
  static const Color chipBorder = emerald500;
  static const Color chipText = white;
  static const Color zoneChipBg = white;
  static const Color zoneChipText = emerald500;

  /// HTML `confetti({colors: ['#10b981', '#f59e0b', '#84cc16']})`.
  static const List<Color> confetti = [emerald500, amber500, lime500];
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
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
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
    curtainGlow: Color(0x66065F46), // emerald-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
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
    accent: _Colors.emerald500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
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
    curtainGlow: Color(0x66065F46),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald400,
    buttonBorder: Color(0xCC10B981),
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
// From the HTML `i18n`, `ScenariosData`, `labelDict`, inspection `names`
// and summary tables (Telugu dropped). `sN_hud_M` are the HTML "Current
// Task" lines (CLICK became TAP for touch), `sN_focus_M` / `sN_obs_M` /
// `sN_expl_M` the HTML step concept, observation and explanation, and
// `sN_step_M` the HTML step `action` spelled out for touch. Step 7 of each
// scenario is the HTML's seventh HUD line (the review button). Keys marked
// "Added." are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Classifying Plants Based on Physical Characteristics',
    'app_subtitle': 'Class 6. Diversity in the Living World',
    'scen_1': 'Scenario 1: Herbs, Shrubs, and Trees',
    'scen_2': 'Scenario 2: Uncovering Monocots & Dicots',
    's1_desc':
        'Observe the physical characteristics of different plants and classify them into herbs, shrubs, or trees.',
    's2_desc':
        "Investigate the relationship between a plant's seeds, leaf venation, and root system to classify it.",
    's1_hud_1':
        'You are in a virtual park. TAP on the Tomato plant to inspect its stem.',
    's1_hud_2': 'Now, TAP on the Rose plant to inspect its stem.',
    's1_hud_3': 'Finally, TAP on the Mango tree to inspect its trunk.',
    's1_hud_4':
        'Three sorting bins have appeared. DRAG the Tomato plant and DROP it into the correct bin.',
    's1_hud_5': 'DRAG the Rose plant and DROP it into the correct bin.',
    's1_hud_6': 'DRAG the Mango tree and DROP it into the correct bin.',
    's1_hud_7':
        "TAP the 'Review Classification' button to summarize your findings.",
    's2_hud_1':
        "You are at a virtual lab bench. DRAG the 'Magnifying Glass' tool and DROP it onto a leaf of the Chickpea plant.",
    's2_hud_2':
        "Now, DRAG the 'Magnifying Glass' tool and DROP it onto a leaf of the Maize plant.",
    's2_hud_3':
        "Select the 'X-Ray Scanner' tool and DRAG it over the soil beneath the Chickpea plant.",
    's2_hud_4':
        "DRAG the 'X-Ray Scanner' tool over the soil beneath the Maize plant.",
    's2_hud_5': 'TAP on the Chickpea SEED to observe its structure.',
    's2_hud_6': 'TAP on the Maize SEED to observe its structure.',
    's2_hud_7':
        "TAP the 'Assemble Profiles' button to connect these characteristics.",
    's1_focus_1': 'Stem Flexibility',
    's1_focus_2': 'Stem Hardness',
    's1_focus_3': 'Trunk Thickness',
    's1_focus_4': 'Classification',
    's1_focus_5': 'Classification',
    's1_focus_6': 'Classification',
    's1_obs_1': 'Soft, green, and bends easily.',
    's1_obs_2': 'Hard, woody, branches near the base.',
    's1_obs_3': 'Thick, hard, branches high up.',
    's1_obs_4': 'Placed correctly based on soft stem.',
    's1_obs_5': 'Placed correctly based on hard stem and low branches.',
    's1_obs_6': 'Placed correctly based on thick trunk.',
    's1_expl_1':
        'Plants with green and tender stems are called herbs. They are usually short.',
    's1_expl_2': 'Plants with a hard stem branching near the base are shrubs.',
    's1_expl_3': 'Tall plants with a hard, thick brown stem (trunk) are trees.',
    's2_focus_1': 'Leaf Venation',
    's2_focus_2': 'Leaf Venation',
    's2_focus_3': 'Root System',
    's2_focus_4': 'Root System',
    's2_focus_5': 'Seed Structure',
    's2_focus_6': 'Seed Structure',
    's2_obs_1': 'Net-like pattern (Reticulate Venation).',
    's2_obs_2': 'Parallel lines (Parallel Venation).',
    's2_obs_3': 'One main root with smaller branches (Taproot).',
    's2_obs_4': 'Cluster of similar thin roots (Fibrous Root).',
    's2_obs_5': 'Splits into two halves (Two Cotyledons).',
    's2_obs_6': 'Single solid unit (One Cotyledon).',
    's2_expl_1': 'The veins form a network on the leaf.',
    's2_expl_2': 'The veins run parallel to each other.',
    's2_expl_3': 'A taproot system has a prominent central root.',
    's2_expl_4': 'Fibrous roots do not have a main central root.',
    's2_expl_5': 'Seeds that divide into two are called Dicots.',
    's2_expl_6': 'Seeds that do not split naturally are called Monocots.',
    's1_summary':
        'You successfully classified the plants based on their stems and height. Herbs have soft green stems. Shrubs have hard stems branching near the base. Trees are tall with thick, woody trunks.',
    's2_summary':
        'Great detective work! You discovered the key relationships in plant classification. Plants with reticulate venation and taproots have seeds with two cotyledons (Dicots). Plants with parallel venation and fibrous roots have seeds with one cotyledon (Monocots).',
    // Spelled out for touch from the HTML step `action` (added).
    's1_step_1': 'Tap the Tomato plant to inspect its stem.',
    's1_step_2': 'Tap the Rose plant to inspect its stem.',
    's1_step_3': 'Tap the Mango tree to inspect its trunk.',
    's1_step_4': "Drag the Tomato plant into the 'Herb' bin.",
    's1_step_5': "Drag the Rose plant into the 'Shrub' bin.",
    's1_step_6': "Drag the Mango tree into the 'Tree' bin.",
    's1_step_7': "Tap 'Review Classification' to summarize your findings.",
    's2_step_1': 'Drag the Magnifying Glass onto a leaf of the Chickpea plant.',
    's2_step_2': 'Drag the Magnifying Glass onto a leaf of the Maize plant.',
    's2_step_3': 'Drag the X-Ray Scanner over the soil of the Chickpea pot.',
    's2_step_4': 'Drag the X-Ray Scanner over the soil of the Maize pot.',
    's2_step_5': 'Tap the Chickpea seed on the bench.',
    's2_step_6': 'Tap the Maize seed on the bench.',
    's2_step_7': "Tap 'Assemble Profiles' to connect these characteristics.",
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'obs_lbl': 'Observation',
    // Buttons, inspection card and summary.
    'btn_conclude': 'Review Classification',
    'btn_conclude_s2': 'Assemble Profiles',
    'classification_complete': 'Classification Complete!',
    'got_it': 'Got it!',
    'select_next_sc_msg':
        'Scenario 1 completed. Select the next from the sidebar!',
    'insp_tomato': 'Tomato Stem',
    'insp_rose': 'Rose Stem',
    'insp_mango': 'Mango Trunk',
    'insp_cpLeaf': 'Chickpea Leaf',
    'insp_mzLeaf': 'Maize Leaf',
    'insp_cpRoot': 'Chickpea Root',
    'insp_mzRoot': 'Maize Root',
    'insp_cpSeed': 'Chickpea Seed',
    'insp_mzSeed': 'Maize Seed',
    'sum_herb': 'Herb',
    'sum_shrub': 'Shrub',
    'sum_tree': 'Tree',
    'sum_stem': 'Stem',
    'sum_soft': 'Soft',
    'sum_hard': 'Hard',
    'sum_trunk': 'Trunk',
    'sum_dicot': 'Dicot Plant',
    'sum_monocot': 'Monocot Plant',
    'sum_reticulate': 'Reticulate',
    'sum_parallel': 'Parallel',
    'sum_taproot': 'Taproot',
    'sum_fibrous': 'Fibrous',
    'sum_two_cot': '2 Cotyledons',
    'sum_one_cot': '1 Cotyledon',
    // Scene labels (HTML `labelDict`) and the toolkit (English only in
    // the HTML).
    'lbl_herb_bin': 'Herb Bin',
    'lbl_shrub_bin': 'Shrub Bin',
    'lbl_tree_bin': 'Tree Bin',
    'lbl_tomato': 'Tomato',
    'lbl_rose': 'Rose',
    'lbl_mango': 'Mango',
    'lbl_chickpea': 'Chickpea',
    'lbl_maize': 'Maize',
    'lbl_leaf': 'Leaf',
    'lbl_seed': 'Seed',
    'lbl_soil': 'Soil',
    'toolkit': 'Toolkit',
    'tool_magnifier': 'Magnifying Glass',
    'tool_xray': 'X-Ray Scanner',
    // Added.
    'pending': 'Do this step to see the observation.',
    'hint_s1_1':
        'Not yet! In this step, tap the Tomato plant to inspect its stem.',
    'hint_s1_2':
        'Not yet! In this step, tap the Rose plant to inspect its stem.',
    'hint_s1_3':
        'Not yet! In this step, tap the Mango tree to inspect its trunk.',
    'hint_s1_4':
        'In this step, drag the Tomato plant and drop it into the correct bin.',
    'hint_s1_5':
        'In this step, drag the Rose plant and drop it into the correct bin.',
    'hint_s1_6':
        'In this step, drag the Mango tree and drop it into the correct bin.',
    'miss_tomato': 'Missed! Drop the Tomato plant right into a bin.',
    'miss_rose': 'Missed! Drop the Rose plant right into a bin.',
    'miss_mango': 'Missed! Drop the Mango tree right into a bin.',
    'wrong_bin_tomato':
        'Not that bin! The tomato has a soft, green stem that bends easily.',
    'wrong_bin_rose':
        'Not that bin! The rose has a hard, woody stem that branches near the base.',
    'wrong_bin_mango':
        'Not that bin! The mango is tall, with a thick, hard trunk.',
    'wrong_s2_1':
        'Not here! In this step, drop the Magnifying Glass on a leaf of the Chickpea plant.',
    'wrong_s2_2':
        'Not here! In this step, drop the Magnifying Glass on a leaf of the Maize plant.',
    'wrong_s2_3':
        'Not here! In this step, drag the X-Ray Scanner over the soil of the Chickpea pot.',
    'wrong_s2_4':
        'Not here! In this step, drag the X-Ray Scanner over the soil of the Maize pot.',
    'wrong_s2_5': 'Not here! In this step, tap the Chickpea seed on the bench.',
    'wrong_s2_6': 'Not here! In this step, tap the Maize seed on the bench.',
    'hint_magnifier':
        'Drag the Magnifying Glass and drop it on a leaf or a seed.',
    'hint_xray': 'Drag the X-Ray Scanner and drop it on the soil of a pot.',
    'scene_s1':
        'A park with a tomato plant, a rose plant and a mango tree in front of three sorting bins: the Herb Bin, the Shrub Bin and the Tree Bin',
    'scene_s2':
        'A lab bench with a chickpea plant and a maize plant in pots, a seed of each plant on the bench, and a toolkit with a magnifying glass and an X-ray scanner',
  },
  'hi': {
    'app_title': 'भौतिक विशेषताओं के आधार पर पौधों का वर्गीकरण',
    'app_subtitle': 'कक्षा 6. सजीव जगत में विविधता',
    'scen_1': 'परिदृश्य 1: शाक, झाड़ी और पेड़',
    'scen_2': 'परिदृश्य 2: एकबीजपत्री और द्विबीजपत्री',
    's1_desc':
        'विभिन्न पौधों की भौतिक विशेषताओं का निरीक्षण करें और उन्हें शाक, झाड़ी या पेड़ में वर्गीकृत करें।',
    's2_desc':
        'पौधे को वर्गीकृत करने के लिए उसके बीज, पत्ती के शिराविन्यास और जड़ प्रणाली के बीच संबंधों की जांच करें।',
    's1_hud_1':
        'आप एक वर्चुअल पार्क में हैं। टमाटर के पौधे के तने का निरीक्षण करने के लिए उस पर टैप करें।',
    's1_hud_2': 'गुलाब के पौधे के तने का निरीक्षण करने के लिए उस पर टैप करें।',
    's1_hud_3':
        'आम के पेड़ के तने (ट्रंक) का निरीक्षण करने के लिए उस पर टैप करें।',
    's1_hud_4':
        'अब, टमाटर के पौधे को खींचें और सही वर्गीकरण डिब्बे में छोड़ें।',
    's1_hud_5': 'गुलाब के पौधे को खींचें और सही वर्गीकरण डिब्बे में छोड़ें।',
    's1_hud_6': 'अंत में, आम के पेड़ को खींचें और सही डिब्बे में छोड़ें।',
    's1_hud_7':
        "अपने निष्कर्षों को सारांशित करने के लिए 'वर्गीकरण की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        'आप चना और मक्का का पौधा देखते हैं। चने की पत्ती के शिराविन्यास की जांच करने के लिए उस पर टैप करें।',
    's2_hud_2':
        'मक्के की पत्ती के शिराविन्यास की जांच करने के लिए उस पर टैप करें।',
    's2_hud_3':
        'चने के पौधे की जड़ों को स्कैन करने के लिए मिट्टी के आधार पर टैप करें।',
    's2_hud_4':
        'मक्के के पौधे की जड़ों को स्कैन करने के लिए मिट्टी के आधार पर टैप करें।',
    's2_hud_5': 'चने के बीज की संरचना का निरीक्षण करने के लिए उस पर टैप करें।',
    's2_hud_6':
        'मक्के के बीज की संरचना का निरीक्षण करने के लिए उस पर टैप करें।',
    's2_hud_7':
        "इन विशेषताओं को जोड़ने के लिए 'प्रोफाइल बनाएं' बटन पर टैप करें।",
    's1_focus_1': 'तने का लचीलापन',
    's1_focus_2': 'तने की कठोरता',
    's1_focus_3': 'तने की मोटाई',
    's1_focus_4': 'वर्गीकरण',
    's1_focus_5': 'वर्गीकरण',
    's1_focus_6': 'वर्गीकरण',
    's1_obs_1': 'मुलायम, हरा और आसानी से मुड़ता है।',
    's1_obs_2': 'कठोर, लकड़ी का, आधार के पास शाखाएं।',
    's1_obs_3': 'मोटा, कठोर, शाखाएं ऊपर होती हैं।',
    's1_obs_4': 'मुलायम तने के आधार पर सही ढंग से रखा गया।',
    's1_obs_5': 'कठोर तने और निचली शाखाओं के आधार पर सही ढंग से रखा गया।',
    's1_obs_6': 'मोटे तने के आधार पर सही ढंग से रखा गया।',
    's1_expl_1':
        'हरे और कोमल तने वाले पौधों को शाक कहा जाता है। वे आमतौर पर छोटे होते हैं।',
    's1_expl_2': 'आधार के पास शाखाओं वाले कठोर तने वाले पौधे झाड़ियाँ हैं।',
    's1_expl_3': 'कठोर, मोटे भूरे तने (ट्रंक) वाले ऊंचे पौधे पेड़ हैं।',
    's2_focus_1': 'पत्ती शिराविन्यास',
    's2_focus_2': 'पत्ती शिराविन्यास',
    's2_focus_3': 'जड़ प्रणाली',
    's2_focus_4': 'जड़ प्रणाली',
    's2_focus_5': 'बीज संरचना',
    's2_focus_6': 'बीज संरचना',
    's2_obs_1': 'जाल जैसा पैटर्न (जालिका रूपी शिराविन्यास)।',
    's2_obs_2': 'समानांतर रेखाएं (समानांतर शिराविन्यास)।',
    's2_obs_3': 'छोटी शाखाओं के साथ एक मुख्य जड़ (मूसला जड़)।',
    's2_obs_4': 'समान पतली जड़ों का गुच्छा (झकड़ा जड़)।',
    's2_obs_5': 'दो हिस्सों में बंट जाता है (दो बीजपत्र)।',
    's2_obs_6': 'एकल ठोस इकाई (एक बीजपत्र)।',
    's2_expl_1': 'शिराएं पत्ती पर एक जाल बनाती हैं।',
    's2_expl_2': 'शिराएं एक दूसरे के समानांतर चलती हैं।',
    's2_expl_3': 'मूसला जड़ प्रणाली में एक प्रमुख केंद्रीय जड़ होती है।',
    's2_expl_4': 'झकड़ा जड़ों में एक मुख्य केंद्रीय जड़ नहीं होती है।',
    's2_expl_5':
        'जो बीज दो भागों में विभाजित हो जाते हैं उन्हें द्विबीजपत्री (Dicots) कहा जाता है।',
    's2_expl_6':
        'जो बीज स्वाभाविक रूप से विभाजित नहीं होते हैं उन्हें एकबीजपत्री (Monocots) कहा जाता है।',
    's1_summary':
        'आपने पौधों को उनके तने और ऊंचाई के आधार पर सफलतापूर्वक वर्गीकृत किया। शाक के तने मुलायम हरे होते हैं। झाड़ियों में आधार के पास शाखाओं वाले कठोर तने होते हैं। पेड़ मोटे, लकड़ी के तने वाले लंबे होते हैं।',
    's2_summary':
        'महान जासूसी काम! आपने पौधों के वर्गीकरण में प्रमुख संबंधों की खोज की। जालिका रूपी शिराविन्यास और मूसला जड़ वाले पौधों के बीजों में दो बीजपत्र (द्विबीजपत्री) होते हैं। समानांतर शिराविन्यास और झकड़ा जड़ वाले पौधों के बीजों में एक बीजपत्र (एकबीजपत्री) होता है।',
    's1_step_1': 'टमाटर के पौधे पर टैप करें और उसके तने का निरीक्षण करें।',
    's1_step_2': 'गुलाब के पौधे पर टैप करें और उसके तने का निरीक्षण करें।',
    's1_step_3': 'आम के पेड़ पर टैप करें और उसके तने (ट्रंक) का निरीक्षण करें।',
    's1_step_4': "टमाटर के पौधे को खींचकर 'शाक' डिब्बे में छोड़ें।",
    's1_step_5': "गुलाब के पौधे को खींचकर 'झाड़ी' डिब्बे में छोड़ें।",
    's1_step_6': "आम के पेड़ को खींचकर 'पेड़' डिब्बे में छोड़ें।",
    's1_step_7':
        "निष्कर्षों का सारांश देखने के लिए 'वर्गीकरण की समीक्षा करें' पर टैप करें।",
    's2_step_1': 'आवर्धक लेंस को खींचकर चने के पौधे की पत्ती पर छोड़ें।',
    's2_step_2': 'आवर्धक लेंस को खींचकर मक्के के पौधे की पत्ती पर छोड़ें।',
    's2_step_3': 'एक्स-रे स्कैनर को खींचकर चने के गमले की मिट्टी पर छोड़ें।',
    's2_step_4': 'एक्स-रे स्कैनर को खींचकर मक्के के गमले की मिट्टी पर छोड़ें।',
    's2_step_5': 'मेज़ पर रखे चने के बीज पर टैप करें।',
    's2_step_6': 'मेज़ पर रखे मक्के के बीज पर टैप करें।',
    's2_step_7': "इन विशेषताओं को जोड़ने के लिए 'प्रोफाइल बनाएं' पर टैप करें।",
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'obs_lbl': 'अवलोकन',
    'btn_conclude': 'वर्गीकरण की समीक्षा करें',
    'btn_conclude_s2': 'प्रोफाइल बनाएं',
    'classification_complete': 'वर्गीकरण पूरा हुआ!',
    'got_it': 'समझ गया!',
    'select_next_sc_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'insp_tomato': 'टमाटर का तना',
    'insp_rose': 'गुलाब का तना',
    'insp_mango': 'आम का तना',
    'insp_cpLeaf': 'चने की पत्ती',
    'insp_mzLeaf': 'मक्के की पत्ती',
    'insp_cpRoot': 'चने की जड़',
    'insp_mzRoot': 'मक्के की जड़',
    'insp_cpSeed': 'चने का बीज',
    'insp_mzSeed': 'मक्के का बीज',
    'sum_herb': 'शाक',
    'sum_shrub': 'झाड़ी',
    'sum_tree': 'पेड़',
    'sum_stem': 'तना',
    'sum_soft': 'मुलायम',
    'sum_hard': 'कठोर',
    'sum_trunk': 'मोटा तना',
    'sum_dicot': 'द्विबीजपत्री',
    'sum_monocot': 'एकबीजपत्री',
    'sum_reticulate': 'जालिका रूपी',
    'sum_parallel': 'समानांतर',
    'sum_taproot': 'मूसला जड़',
    'sum_fibrous': 'झकड़ा जड़',
    'sum_two_cot': '2 बीजपत्र',
    'sum_one_cot': '1 बीजपत्र',
    'lbl_herb_bin': 'शाक डिब्बा',
    'lbl_shrub_bin': 'झाड़ी डिब्बा',
    'lbl_tree_bin': 'पेड़ डिब्बा',
    'lbl_tomato': 'टमाटर',
    'lbl_rose': 'गुलाब',
    'lbl_mango': 'आम',
    'lbl_chickpea': 'चना',
    'lbl_maize': 'मक्का',
    'lbl_leaf': 'पत्ती',
    'lbl_seed': 'बीज',
    // Added (the HTML showed these in English only).
    'lbl_soil': 'मिट्टी',
    'toolkit': 'टूलकिट',
    'tool_magnifier': 'आवर्धक लेंस',
    'tool_xray': 'एक्स-रे स्कैनर',
    // Added.
    'pending': 'अवलोकन देखने के लिए यह चरण पूरा करें।',
    'hint_s1_1':
        'अभी नहीं! इस चरण में टमाटर के पौधे पर टैप करके उसके तने का निरीक्षण करें।',
    'hint_s1_2':
        'अभी नहीं! इस चरण में गुलाब के पौधे पर टैप करके उसके तने का निरीक्षण करें।',
    'hint_s1_3':
        'अभी नहीं! इस चरण में आम के पेड़ पर टैप करके उसके तने का निरीक्षण करें।',
    'hint_s1_4': 'इस चरण में टमाटर के पौधे को खींचकर सही डिब्बे में छोड़ें।',
    'hint_s1_5': 'इस चरण में गुलाब के पौधे को खींचकर सही डिब्बे में छोड़ें।',
    'hint_s1_6': 'इस चरण में आम के पेड़ को खींचकर सही डिब्बे में छोड़ें।',
    'miss_tomato':
        'निशाना चूक गया! टमाटर के पौधे को सीधे किसी डिब्बे में छोड़ें।',
    'miss_rose':
        'निशाना चूक गया! गुलाब के पौधे को सीधे किसी डिब्बे में छोड़ें।',
    'miss_mango': 'निशाना चूक गया! आम के पेड़ को सीधे किसी डिब्बे में छोड़ें।',
    'wrong_bin_tomato':
        'यह सही डिब्बा नहीं है! टमाटर का तना मुलायम और हरा होता है, जो आसानी से मुड़ जाता है।',
    'wrong_bin_rose':
        'यह सही डिब्बा नहीं है! गुलाब का तना कठोर और लकड़ी जैसा होता है, जिसकी शाखाएँ आधार के पास निकलती हैं।',
    'wrong_bin_mango':
        'यह सही डिब्बा नहीं है! आम का पेड़ ऊँचा होता है और उसका तना मोटा व कठोर होता है।',
    'wrong_s2_1':
        'यहाँ नहीं! इस चरण में आवर्धक लेंस को चने के पौधे की पत्ती पर छोड़ें।',
    'wrong_s2_2':
        'यहाँ नहीं! इस चरण में आवर्धक लेंस को मक्के के पौधे की पत्ती पर छोड़ें।',
    'wrong_s2_3':
        'यहाँ नहीं! इस चरण में एक्स-रे स्कैनर को चने के गमले की मिट्टी पर खींचें।',
    'wrong_s2_4':
        'यहाँ नहीं! इस चरण में एक्स-रे स्कैनर को मक्के के गमले की मिट्टी पर खींचें।',
    'wrong_s2_5': 'यहाँ नहीं! इस चरण में मेज़ पर रखे चने के बीज पर टैप करें।',
    'wrong_s2_6': 'यहाँ नहीं! इस चरण में मेज़ पर रखे मक्के के बीज पर टैप करें।',
    'hint_magnifier': 'आवर्धक लेंस को खींचकर किसी पत्ती या बीज पर छोड़ें।',
    'hint_xray': 'एक्स-रे स्कैनर को खींचकर किसी गमले की मिट्टी पर छोड़ें।',
    'scene_s1':
        'एक पार्क जिसमें टमाटर का पौधा, गुलाब का पौधा और आम का पेड़ तीन वर्गीकरण डिब्बों (शाक डिब्बा, झाड़ी डिब्बा और पेड़ डिब्बा) के सामने हैं',
    'scene_s2':
        'एक प्रयोगशाला मेज़ जिस पर गमलों में चने और मक्के के पौधे हैं, मेज़ पर दोनों पौधों का एक-एक बीज है, और आवर्धक लेंस व एक्स-रे स्कैनर वाला एक टूलकिट है',
  },
};

/// Number of scenarios (the HTML `<select>` options).
const int _scenarioCount = 2;

/// The HTML `steps` of each scenario (six) and its seventh HUD task, the
/// review button.
const int _taskSteps = 6;
const int _stepCount = 7;

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.observation,
    required this.explanation,
  });

  final String focus;
  final String action;
  final String observation;
  final String explanation;
}

/// [key] in [lang], or '' when the HTML has no such text (its steps 4–6
/// of Scenario 1 have no explanation).
String _trOrEmpty(LabLang lang, String key) =>
    _i18n['en']!.containsKey(key) ? labTr(_i18n, lang, key) : '';

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCount; i++)
      _StepInfo(
        focus: _trOrEmpty(lang, 's${n}_focus_$i'),
        action: labTr(_i18n, lang, 's${n}_step_$i'),
        observation: _trOrEmpty(lang, 's${n}_obs_$i'),
        explanation: _trOrEmpty(lang, 's${n}_expl_$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The step
/// concept is the HTML "Focus" (a topic, not a result); the observation is
/// shown in the accordion once the step is done.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_$n'),
        objective: t('s${n}_desc'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(
              concept: s.focus,
              action: s.action,
              observation: s.observation,
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

/// HTML camera: `PerspectiveCamera(45, …)`; `resetCamera()` puts it at
/// (0, 12, 18) in Scenario 1 and (0, 10, 15) in Scenario 2, looking at
/// `controls.target` (0, 0, 0).
const double _fovDegrees = 45;
const List<_V> _eyes = [_V(0, 12, 18), _V(0, 10, 15)];
const _V _lookAt = _V(0, 0, 0);
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a plant (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Text sprite sizes (HTML `createTextSprite` scale 0.8, 0.7 and 0.6) as
/// label size factors.
const double _chipBig = 1;
const double _chipMedium = 0.92;
const double _chipSmall = 0.85;

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
/// top). Canvas cards above the HUD sit [_hudReserve] (x UI scale) higher.
const double _hudBand = 54;
const double _hudReserve = 66;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene in each scenario (the HTML camera is
/// zoom 1), and of a close-up while something is inspected; it is never
/// drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.3, 1.35];
const double _inspectZoom = 2.4;
const double _minZoom = 0.3;

/// HTML `handleInspection`: the camera glides to the object (600 ms,
/// Cubic.Out) and the card shows once it is there.
const double _cameraSeconds = 0.6;
const Duration _cardDelay = Duration(milliseconds: 600);

/// `.inspection-card` transition (0.4 s, cubic-bezier(0.175, 0.885, 0.32,
/// 1.275)); `closeInspection()` moves on 400 ms after 'Got it!'.
const Duration _cardFade = Duration(milliseconds: 400);

/// The inspection card: width (x UI scale, at most [_cardShare] of the
/// canvas) and its picture box (`w-40 h-40`).
const double _cardMaxWidth = 300;
const double _cardMinWidth = 210;
const double _cardShare = 0.46;
const double _cardVisual = 150;

/// `.svg-animate-dash`: the stem picture's strokes are drawn in over 2 s
/// (ease-in-out) with a 100-unit dash.
const double _drawSeconds = 2;
const double _dashLength = 100;

/// HTML `FogExp2(background, 0.015)`.
const double _fogDensity = 0.015;

// ----------------------------------------------- scenario 1: the park

/// Ground `PlaneGeometry(40, 30)`; widened sideways and towards the camera
/// here so its edges never show beside the stage (its far edge stays).
const double _groundHalfZ = 15;
const double _groundBleedX = 60;
const double _groundNear = 17;

/// Bins (`createBin`) at (-6 / 0 / 6, 0, -4): an open
/// `CylinderGeometry(1.2, 1.0, 2, 8)`, a bottom `(1.0, 1.0, 0.1, 8)`, the
/// rim `TorusGeometry(1.2, 0.1, 8, 8)` at y 2, the highlight ring
/// `TorusGeometry(1.4, 0.1)` at y 2.1 and the label at y 2.8.
const double _binZ = -4;
const double _binTopR = 1.2;
const double _binBottomR = 1;
const double _binHeight = 2;
const int _binSides = 8;
const double _binFloor = 0.1;
const double _rimTube = 0.1;
const double _glowR = 1.4;
const double _glowY = 2.1;
const double _binLabelY = 2.8;

/// The icon plane on each bin's front (`PlaneGeometry(1.2, 1.2)` at
/// (0, 1, 1.05), the SVG drawn on its middle 192 of 256 px): just in front
/// of the bin's front edge here.
const double _iconY = 1;
const double _iconZ = 1.12;
const double _iconHalf = 0.45;

/// Plants at (-6 / 0 / 6, 0, 4).
const double _plantZ = 4;

/// HTML drop test: `obj.position.distanceTo(target.position) < 2.5`.
const double _binReach = 2.5;

/// A plant dropped into its bin glides to (bin.x, 1, bin.z) (300 ms,
/// Back.Out) while it shrinks to half size (300 ms); a missed one goes back
/// home (500 ms, Elastic.Out).
const double _placeY = 1;
const double _placeScale = 0.5;
const double _placeSeconds = 0.3;
const double _returnSeconds = 0.5;

/// A plant counts as dragged once it moved this far (world units).
const double _movedFar = 0.3;

// ------------------------------------------- scenario 2: the lab bench

/// Lab bench `BoxGeometry(30, 1, 15)` at (0, -0.5, 0).
const double _benchHalfX = 15;
const double _benchHalfZ = 7.5;
const double _benchDepth = 1;

/// Pots `CylinderGeometry(1.2, 0.9, 1.5, 16)` at y 0.75, soil
/// `CylinderGeometry(1.15, 1.15, 0.1, 16)` at y 1.45.
const double _potTopR = 1.2;
const double _potBottomR = 0.9;
const double _potHeight = 1.5;
const double _soilR = 1.15;

/// Zone rings `TorusGeometry(radius, 0.05)`.
const double _ringTube = 0.05;

// ------------------------------------------------------------- labels

/// How a chip sits on its anchor (x, y alignment: -1 left / top edge,
/// 0 centre, 1 right / bottom edge).
const (double, double) _centre = (0, 0);
const (double, double) _above = (0, 1);

// ------------------------------------------------------------- confetti

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

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

  /// Distance on the ground (x, z).
  double flatTo(_V o) =>
      math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
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

/// The HTML PerspectiveCamera of a scenario (position, `controls.target`,
/// fov 45) as a pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(int scenario, _Framing framing) {
    final eye = _eyes[scenario];
    final f = (_lookAt - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, f, r, r.cross(f), framing.center, _focal * framing.zoom);
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

  /// Where the ray through [s] meets the camera-facing plane through [c]
  /// (a sprite's billboard).
  _V? onBillboard(Offset s, _V c) {
    final d = ray(s);
    final k = d.dot(f);
    if (k < 1e-6) return null;
    return eye + d * ((c - eye).dot(f) / k);
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

/// The three sorting bins (HTML `Objects.s1.binHerb` …).
enum _Bin {
  herb(-6, _Colors.binHerb, _Art.herbBin, 'lbl_herb_bin'),
  shrub(0, _Colors.binShrub, _Art.shrubBin, 'lbl_shrub_bin'),
  tree(6, _Colors.binTree, _Art.treeBin, 'lbl_tree_bin');

  const _Bin(this.x, this.color, this.icon, this.labelKey);

  final double x;
  final Color color;
  final _Art icon;
  final String labelKey;

  _V get pos => _V(x, 0, _binZ);
}

/// The three park plants, in step order: their SVG sprite, bin, x, sprite
/// size, invisible hit cylinder (radius, height), label height and shadow
/// blob radius (HTML `buildS1Scene`).
enum _Plant {
  tomato(_Art.tomato, _Bin.herb, -6, 3, 1.2, 3.5, 3.3, 1, 'lbl_tomato'),
  rose(_Art.rose, _Bin.shrub, 0, 4.5, 1.8, 4.5, 4.8, 1.5, 'lbl_rose'),
  mango(_Art.mango, _Bin.tree, 6, 7.5, 3, 7.5, 7.8, 2.5, 'lbl_mango');

  const _Plant(
    this.art,
    this.bin,
    this.x,
    this.size,
    this.hitR,
    this.hitH,
    this.labelY,
    this.blob,
    this.nameKey,
  );

  final _Art art;
  final _Bin bin;
  final double x;
  final double size;
  final double hitR;
  final double hitH;
  final double labelY;
  final double blob;
  final String nameKey;

  _V get home => _V(x, 0, _plantZ);

  /// Its inspection (steps 1–3).
  _Subject get subject => _Subject.values[index];
}

/// The two inspection tools of the toolkit (HTML `#virtual-toolkit`; its
/// third, the bending hand, is never shown).
enum _Tool {
  magnifier(
    'tool_magnifier',
    Icons.search,
    _Colors.blue100,
    _Colors.blueTileDark,
    _Colors.blue600,
    _Colors.blue400,
    _Colors.blueEdge,
  ),
  xray(
    'tool_xray',
    Icons.flashlight_on,
    _Colors.purple100,
    _Colors.purpleTileDark,
    _Colors.purple600,
    _Colors.purple400,
    _Colors.purpleEdge,
  );

  const _Tool(
    this.labelKey,
    this.icon,
    this.tile,
    this.tileDark,
    this.ink,
    this.inkDark,
    this.edge,
  );

  final String labelKey;
  final IconData icon;
  final Color tile;
  final Color tileDark;
  final Color ink;
  final Color inkDark;
  final Color edge;
}

/// The six inspection zones of the bench, in step order (HTML
/// `createClickZone`): centre, radius, height, label and the tool that
/// inspects it; the seeds also have their sprite.
enum _Zone {
  cpLeaf(_V(-5, 3.5, 0), 1.5, 2, 'lbl_leaf', _Tool.magnifier),
  mzLeaf(_V(5, 4, 0), 1.5, 2.5, 'lbl_leaf', _Tool.magnifier),
  cpRoot(_V(-5, 0.75, 0), 1.5, 1.5, 'lbl_soil', _Tool.xray),
  mzRoot(_V(5, 0.75, 0), 1.5, 1.5, 'lbl_soil', _Tool.xray),
  cpSeed(
    _V(-8, 1.2, 2),
    1,
    1,
    'lbl_seed',
    _Tool.magnifier,
    seed: _Art.chickpeaSeed,
    seedAt: _V(-8, 0.6, 2),
    seedSize: 1.2,
  ),
  mzSeed(
    _V(2, 1, 2),
    1,
    1,
    'lbl_seed',
    _Tool.magnifier,
    seed: _Art.maizeSeed,
    seedAt: _V(2, 0.5, 2),
    seedSize: 1,
  );

  const _Zone(
    this.center,
    this.radius,
    this.height,
    this.labelKey,
    this.tool, {
    this.seed,
    this.seedAt = _V.zero,
    this.seedSize = 0,
  });

  final _V center;
  final double radius;
  final double height;
  final String labelKey;
  final _Tool tool;
  final _Art? seed;
  final _V seedAt;
  final double seedSize;

  /// HTML label sprite at `yPos + height / 2 + 0.5`.
  _V get labelAt => center + _V(0, height / 2 + 0.5, 0);

  /// Its inspection (steps 1–6).
  _Subject get subject => _Subject.values[3 + index];
}

/// The two potted plants of the bench (HTML `buildS2Scene`): x, sprite,
/// sprite size and height, name label height and their zones.
enum _Pot {
  chickpea(
    -5,
    _Art.chickpea,
    4,
    3.3,
    5.5,
    'lbl_chickpea',
    _Zone.cpLeaf,
    _Zone.cpRoot,
  ),
  maize(5, _Art.maize, 4.5, 3.6, 6, 'lbl_maize', _Zone.mzLeaf, _Zone.mzRoot);

  const _Pot(
    this.x,
    this.art,
    this.size,
    this.spriteY,
    this.labelY,
    this.nameKey,
    this.leaf,
    this.root,
  );

  final double x;
  final _Art art;
  final double size;
  final double spriteY;
  final double labelY;
  final String nameKey;
  final _Zone leaf;
  final _Zone root;
}

/// Everything that can be inspected, in step order, with the HTML card
/// picture and tool badge (`handleInspection`).
enum _Subject {
  tomato(_Art.stemSoft, Icons.back_hand),
  rose(_Art.stemHard, Icons.back_hand),
  mango(_Art.stemTrunk, Icons.back_hand),
  cpLeaf(_Art.leafReticulate, Icons.search),
  mzLeaf(_Art.leafParallel, Icons.search),
  cpRoot(_Art.taproot, Icons.crop_free),
  mzRoot(_Art.fibrousRoot, Icons.crop_free),
  cpSeed(_Art.seedDicot, Icons.search),
  mzSeed(_Art.seedMonocot, Icons.search);

  const _Subject(this.art, this.icon);

  final _Art art;
  final IconData icon;

  int get scenario => index < 3 ? 0 : 1;

  /// Its step (1-based) in its scenario.
  int get step => index < 3 ? index + 1 : index - 2;

  _Plant? get plant => index < 3 ? _Plant.values[index] : null;
  _Zone? get zone => index < 3 ? null : _Zone.values[index - 3];
}

/// TWEEN.Easing.Back.Out.
double _backOut(double k) {
  const s = 1.70158;
  final t = k - 1;
  return t * t * ((s + 1) * t + s) + 1;
}

/// TWEEN.Easing.Elastic.Out (the same formula as [Curves.elasticOut]).
double _elasticOut(double k) => Curves.elasticOut.transform(k);

/// One park plant: where it is, how big, and its TWEEN glide.
class _PlantState {
  _PlantState(this.plant) : pos = plant.home;

  final _Plant plant;

  /// Group position: on the ground, or in its bin once placed.
  _V pos;
  double scale = 1;

  /// Dropped into its bin.
  bool placed = false;

  _V _from = _V.zero;
  _V _to = _V.zero;
  double _scaleFrom = 1;
  double _scaleTo = 1;
  double _start = -1;
  double _seconds = 1;
  double Function(double) _ease = _backOut;

  void reset() {
    pos = plant.home;
    scale = 1;
    placed = false;
    _start = -1;
  }

  /// HTML `new TWEEN.Tween(obj.position).to(…)` (and `obj.scale`, which the
  /// HTML tweens linearly).
  void glide(
    double now,
    _V to,
    double seconds,
    double Function(double) ease, {
    double? scaleTo,
  }) {
    _from = pos;
    _to = to;
    _scaleFrom = scale;
    _scaleTo = scaleTo ?? scale;
    _start = now;
    _seconds = seconds;
    _ease = ease;
  }

  void stop() => _start = -1;

  /// Position and scale at [time]; ends the glide when it is over.
  void update(double time) {
    if (_start < 0) return;
    final t = ((time - _start) / _seconds).clamp(0.0, 1.0);
    pos = _V.lerp(_from, _to, _ease(t));
    scale = _scaleFrom + (_scaleTo - _scaleFrom) * t;
    if (t >= 1) _start = -1;
  }
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

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    final rnd = math.Random(23);
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

  double time = 0;
  int scenario = 0;

  /// The park's plants (HTML `Objects.s1`).
  final List<_PlantState> plants = [
    for (final p in _Plant.values) _PlantState(p),
  ];

  /// The plant the learner is dragging (HTML `State.draggingObject`).
  _PlantState? held;

  /// The bin whose highlight ring glows: the held plant's own bin, while
  /// the plant is within reach of it.
  _Bin? glowBin;

  /// The zone a tool hovers over (glows when it is the right one).
  _Zone? hoverZone;

  /// Inspections done (HTML `State.s1.*Insp` / `State.s2.*`).
  final Set<_Subject> inspected = {};

  /// The inspection under way (from the tap until 'Got it!').
  _Subject? inspecting;

  /// Scene time the inspection card opened (its picture is drawn in), or
  /// -1.
  double cardAt = -1;

  /// The review button was tapped.
  bool reviewed = false;

  /// Scene time of the summary's confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;
  double _framingDuration = _framingSeconds;
  Curve _framingCurve = Curves.easeInOutCubic;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    for (final p in plants) {
      p.reset();
    }
    held = null;
    glowBin = null;
    hoverZone = null;
    inspected.clear();
    inspecting = null;
    cardAt = -1;
    reviewed = false;
    confettiAt = -1;
  }

  int get placedCount => plants.where((p) => p.placed).length;

  /// Steps of the current scenario done so far.
  int get done {
    final seen = inspected.where((s) => s.scenario == scenario).length;
    return scenario == 0 ? seen + placedCount : seen;
  }

  /// HTML `State.step` (1-based); 8 once the summary was opened.
  int get step {
    final d = done;
    if (d < _taskSteps) return d + 1;
    return reviewed ? _stepCount + 1 : _stepCount;
  }

  /// HTML `animate()`: the TWEEN glides and the framing.
  void advance(double dt) {
    for (final p in plants) {
      p.update(time);
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingDuration);
      framing = _from.lerpTo(_to, _framingCurve.transform(_framingT));
    }
  }

  void setFraming(
    _Framing target, {
    required bool snap,
    double seconds = _framingSeconds,
    Curve curve = Curves.easeInOutCubic,
  }) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
    _framingDuration = seconds;
    _framingCurve = curve;
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(scenario, framing);

  // ------------------------------------------------------------ hit tests

  /// The park plant at [p] (HTML raycast on the invisible hit cylinders),
  /// within a finger's reach.
  _PlantState? plantAt(Offset p, double touch) {
    final cam = camera();
    _PlantState? best;
    var bestD = double.infinity;
    for (final f in plants) {
      if (f.placed) continue;
      final r = f.plant.hitR * f.scale;
      final h = f.plant.hitH * f.scale;
      final rect = cam
          .boxRect(f.pos - _V(r, 0, r), f.pos + _V(r, h, r))
          .inflate(touch * 0.5);
      if (!rect.contains(p)) continue;
      final d = (p - rect.center).distance;
      if (d < bestD) {
        best = f;
        bestD = d;
      }
    }
    return best;
  }

  /// Screen bounds of [b] as drawn in [cam].
  Rect binRect(_Bin b, _Cam cam) => cam.boxRect(
    b.pos - const _V(_binTopR, 0, _binTopR),
    b.pos + const _V(_binTopR, _glowY, _binTopR),
  );

  /// The bin [plant] was dropped into: within the HTML's reach (2.5) of the
  /// bin, or let go with the finger over the bin as drawn. Its own bin wins
  /// over another one within reach.
  _Bin? binFor(_PlantState plant, Offset pointer, double margin) {
    final cam = camera();
    bool reaches(_Bin b) =>
        plant.pos.flatTo(b.pos) < _binReach ||
        binRect(b, cam).inflate(margin).contains(pointer);
    final own = plant.plant.bin;
    if (reaches(own)) return own;
    _Bin? best;
    var bestD = double.infinity;
    for (final b in _Bin.values) {
      if (b == own || !reaches(b)) continue;
      final d = plant.pos.flatTo(b.pos);
      if (d < bestD) {
        best = b;
        bestD = d;
      }
    }
    return best;
  }

  /// Screen bounds of [z] (its cylinder, and its seed) in [cam].
  Rect zoneRect(_Zone z, _Cam cam) {
    final half = _V(z.radius, z.height / 2, z.radius);
    var rect = cam.boxRect(z.center - half, z.center + half);
    if (z.seed != null) {
      final side = z.seedSize * cam.scaleAt(z.seedAt);
      rect = rect.expandToInclude(
        Rect.fromCenter(center: cam.p(z.seedAt), width: side, height: side),
      );
    }
    return rect;
  }

  /// The bench zone at [p] (HTML raycast on the click zones), within a
  /// finger's reach.
  _Zone? zoneAt(Offset p, double touch) {
    final cam = camera();
    _Zone? best;
    var bestD = double.infinity;
    for (final z in _Zone.values) {
      final rect = zoneRect(z, cam).inflate(touch * 0.5);
      if (!rect.contains(p)) continue;
      final d = (p - rect.center).distance;
      if (d < bestD) {
        best = z;
        bestD = d;
      }
    }
    return best;
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

/// Top-left of a chip of [size] relative to its anchor (see [_above] …).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a plant ([canGrab]), so other drags still pan / zoom the canvas when
/// the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _PlantClassificationLabState
    extends State<Ch2A3ClassifyingPlantsBasedOnPhysicalCharacteristicsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), the design box
  /// (tool drops), the toolkit and the canvas review button (framing
  /// obstacles).
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a3-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch2-a3-design');
  final GlobalKey _toolkitKey = GlobalKey(debugLabel: 'ch2-a3-toolkit');
  final GlobalKey _actionKey = GlobalKey(debugLabel: 'ch2-a3-action');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The next re-framing is the camera gliding to or from an inspected
  /// object (600 ms, Cubic.Out) rather than a layout change.
  bool _glideNext = false;

  /// The canvas size at the last framing (the inspection card's width).
  Size _canvasSize = Size.zero;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// The inspection card is on the canvas, and open (scaled in) or closing.
  bool _cardShown = false;
  bool _cardOpen = false;

  /// The plant the current pointer holds, the scenario it was picked up in,
  /// the drag-plane offset and height of the grab, and the pointer's last
  /// position.
  _PlantState? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  double _grabHeight = 0;
  Offset _lastPointer = Offset.zero;

  /// The last feedback toast and the language of the last build, so a
  /// toast still on screen after a language switch is shown again
  /// translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

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

  /// HTML `animate()` + `TWEEN.update()`; then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
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

  /// Width of the inspection card at UI scale [s].
  double _cardWidth(double s) {
    final canvas = _canvasSize.width > 0
        ? _canvasSize.width
        : MediaQuery.sizeOf(context).width;
    return math.min(
      _cardMaxWidth * s,
      math.max(_cardMinWidth, canvas * _cardShare),
    );
  }

  /// Fits the scenario's plants, bins, pots, seeds and labels into the
  /// part of the canvas no card covers: the tool column, the HUD (sidebar
  /// open), the floating mission card (sidebar collapsed), the toolkit and
  /// the review button. While something is inspected the view closes in on
  /// it beside the inspection card (HTML camera tween). Never while a plant
  /// is held, so the scene does not move under the finger.
  void _updateFraming() {
    if (_scene.held != null) return;
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    _canvasSize = size;
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
    final scale = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (open ? _hudBand * scale + 8 : 8) - pad.bottom,
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
    final subject = _scene.inspecting;
    if (subject != null) {
      // The inspection card on the right of the canvas.
      final w = _cardWidth(scale);
      hard.add(
        Rect.fromLTRB(
          size.width - insets.right - w,
          0,
          size.width,
          size.height,
        ),
      );
    } else {
      for (final key in [_toolkitKey, _actionKey]) {
        final r = measured(key);
        if (r != null) hard.add(r);
      }
    }
    _scene
      ..labelLeft = (4 - stage.dx) / fit
      ..labelRight = (size.width - insets.right - stage.dx) / fit;
    final target = _fitFraming(
      subject == null ? _focusItems() : _inspectFocus(subject),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      subject == null ? _maxZoom[_scene.scenario] : _inspectZoom,
    );
    final glide = _glideNext;
    _scene.setFraming(
      target,
      snap: _snapFraming,
      seconds: glide ? _cameraSeconds : _framingSeconds,
      curve: glide ? Curves.easeOutCubic : Curves.easeInOutCubic,
    );
    _snapFraming = false;
    _glideNext = false;
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

  /// Adds the 8 corners of the box [min]–[max] (base projection) to
  /// [items].
  void _addBox(List<_Focus> items, _Cam cam, _V min, _V max) {
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

  /// What the learner must see: the park (plants, also where they end up in
  /// the bins, and the bins) or the bench (pots, plants, zones and seeds) in
  /// the HTML camera, and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_scene.scenario, _Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V min, _V max) => _addBox(items, cam, min, max);
    void chip(_V at, (double, double) align, String text, double factor) {
      final size = _cache.chipSize(text, factor, _Colors.chipText);
      items.add((cam.p(at), _chipOffset(size, align) & size));
    }

    if (_scene.scenario == 0) {
      for (final p in _Plant.values) {
        final h = p.size / 2;
        box(p.home - _V(h, 0, 0.3), p.home + _V(h, p.size, 0.3));
        chip(p.home + _V(0, p.labelY, 0), _centre, _t(p.nameKey), _chipMedium);
        // Where it stands once sorted (half size, in its bin).
        final inBin = p.bin.pos + const _V(0, _placeY, 0);
        final k = h * _placeScale;
        box(inBin - _V(k, 0, 0), inBin + _V(k, p.size * _placeScale, 0));
      }
      for (final b in _Bin.values) {
        box(
          b.pos - const _V(_glowR, 0, _glowR),
          b.pos + const _V(_glowR, _glowY, _glowR),
        );
        chip(
          b.pos + const _V(0, _binLabelY, 0),
          _centre,
          _t(b.labelKey),
          _chipBig,
        );
      }
    } else {
      for (final pot in _Pot.values) {
        final h = pot.size / 2;
        box(
          _V(pot.x - h, pot.spriteY - h, 0),
          _V(pot.x + h, pot.spriteY + h, 0),
        );
        chip(_V(pot.x, pot.labelY, 0), _above, _t(pot.nameKey), _chipBig);
      }
      for (final z in _Zone.values) {
        final half = _V(z.radius, z.height / 2, z.radius);
        box(z.center - half, z.center + half);
        chip(z.labelAt, _centre, _t(z.labelKey), _chipSmall);
        if (z.seed != null) {
          final k = z.seedSize / 2;
          box(z.seedAt - _V(k, k, 0), z.seedAt + _V(k, k, 0));
        }
      }
    }
    return items;
  }

  /// The close-up of [subject]: its plant (sprite) or its zone (and seed).
  List<_Focus> _inspectFocus(_Subject subject) {
    final cam = _Cam(_scene.scenario, _Framing.base);
    final items = <_Focus>[];
    final plant = subject.plant;
    if (plant != null) {
      final h = plant.size / 2;
      _addBox(
        items,
        cam,
        plant.home - _V(h, 0, 0.3),
        plant.home + _V(h, plant.size, 0.3),
      );
    }
    final zone = subject.zone;
    if (zone != null) {
      final half = _V(zone.radius, zone.height / 2, zone.radius);
      _addBox(items, cam, zone.center - half, zone.center + half);
      if (zone.seed != null) {
        final k = zone.seedSize / 2;
        _addBox(
          items,
          cam,
          zone.seedAt - _V(k, k, 0),
          zone.seedAt + _V(k, k, 0),
        );
      }
    }
    return items;
  }

  // ---------------------------------------------------------------- toasts

  /// Feedback toast [key] from [_i18n]. Error toasts play the wrong tone
  /// (HTML 'error'); hints are silent.
  void _toast(String key, {bool error = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: error);
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

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens, rebuilds the scenario's scene and resets the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _grabScenario = -1;
      _cardRect = null;
      _cardShown = false;
      _cardOpen = false;
      _glideNext = false;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// HTML `handleInspection(obj)`: the camera glides to [subject] and, once
  /// it is there, the inspection card shows its picture and observation.
  void _inspect(_Subject subject) {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..inspecting = subject
        ..cardAt = -1
        ..hoverZone = null;
      _cardShown = false;
      _cardOpen = false;
      _glideNext = true;
    });
    _lab.after(_cardDelay, () {
      if (!mounted || s.inspecting != subject) return;
      setState(() {
        _cardShown = true;
        _cardOpen = true;
        s.cardAt = s.time;
      });
    });
  }

  /// HTML `closeInspection()`: the card scales out, then the step moves on
  /// (`progressStep`) and the camera goes back (`resetCamera`, 'pop'); after
  /// the last bench step the 'Assemble Profiles' button appears with a
  /// chime instead (`triggerConclusionState`).
  void _closeInspection() {
    final s = _scene;
    final subject = s.inspecting;
    if (subject == null || !_cardOpen) return;
    _Sound.pop.play();
    setState(() => _cardOpen = false);
    _lab.after(_cardFade, () {
      if (!mounted || s.inspecting != subject) return;
      setState(() {
        s.inspected.add(subject);
        s
          ..inspecting = null
          ..cardAt = -1;
        _cardShown = false;
        _glideNext = true;
      });
      if (s.done == _taskSteps) {
        _Sound.success.play();
      } else {
        _Sound.pop.play();
      }
    });
  }

  /// HTML `handleUp` success branch: the plant glides into its bin and
  /// shrinks to half size; after the third plant the 'Review
  /// Classification' button appears with a chime.
  void _place(_PlantState p) {
    final s = _scene;
    final bin = p.plant.bin;
    p
      ..placed = true
      ..glide(
        s.time,
        _V(bin.x, _placeY, _binZ),
        _placeSeconds,
        _backOut,
        scaleTo: _placeScale,
      );
    if (s.done == _taskSteps) {
      _Sound.success.play();
    } else {
      _Sound.correct.play();
    }
    setState(() {});
    _scheduleFraming();
  }

  /// HTML `triggerConclusion()`: the summary with its picture and confetti.
  void _review() {
    final s = _scene;
    if (s.done < _taskSteps) return;
    final sc = s.scenario;
    setState(() {
      s
        ..reviewed = true
        ..confettiAt = s.time;
    });
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
          // HTML `#next-sc-msg` after Scenario 1 (while Scenario 2 is still
          // to do).
          nextHint: sc == 0 && !_lab.completedScenarios.contains(1),
        ),
      ),
    );
  }

  /// The HTML's conclusion button (`#compare-btn-container`) once the six
  /// steps are done: 'Review Classification' / 'Assemble Profiles'. It
  /// stays after the summary so the summary can be opened again.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.done < _taskSteps || s.inspecting != null) return const [];
    return [
      LabAction(
        label: _t(s.scenario == 0 ? 'btn_conclude' : 'btn_conclude_s2'),
        icon: Icons.check_circle,
        color: _Colors.emerald600,
        foreground: _Colors.white,
        highlight: !s.reviewed,
        silent: true,
        onTap: _review,
      ),
    ];
  }

  // -------------------------------------------------------------- gestures

  /// The stage takes taps and drags (lab open, no popup, nothing being
  /// inspected).
  bool get _stageLive =>
      _lab.isLabActive && _lab.popup == null && _scene.inspecting == null;

  /// HTML `handleDown` in Scenario 1, steps 4–6: a press on a plant.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_stageLive || s.scenario != 0 || _grab != null) return false;
    final step = s.step;
    if (step <= 3 || step > _taskSteps) return false;
    return s.plantAt(event.localPosition, _touch) != null;
  }

  /// Picks up the step's plant (HTML: only it moves). The plant follows the
  /// finger at the height it was grabbed; a press on another plant
  /// explains what to do instead.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final p = s.plantAt(d.localPosition, _touch);
    if (p == null) return;
    final step = s.step;
    if (p.plant.index != step - 4) {
      _toast('hint_s1_$step', error: true);
      return;
    }
    final cam = s.camera();
    final centre = p.pos + _V(0, p.plant.size / 2 * p.scale, 0);
    final on = cam.onBillboard(d.localPosition, centre);
    final height = on == null
        ? 0.0
        : on.y.clamp(0.0, p.plant.size * p.scale * 0.95);
    final hit = cam.onPlaneY(d.localPosition, height);
    _grabOffset = hit == null
        ? _V.zero
        : _V(hit.x - p.pos.x, 0, hit.z - p.pos.z);
    _grabHeight = height;
    p.stop();
    s.held = p;
    _grab = p;
    _grabScenario = s.scenario;
    _lastPointer = d.localPosition;
  }

  /// HTML `handleMove`: the plant slides over the ground under the finger;
  /// its bin's ring glows while the plant is within reach of it.
  void _onDragUpdate(DragUpdateDetails d) {
    final p = _grab;
    final s = _scene;
    if (p == null || _grabScenario != s.scenario) return;
    _lastPointer = d.localPosition;
    final hit = s.camera().onPlaneY(d.localPosition, _grabHeight);
    if (hit == null) return;
    p.pos = _V(hit.x - _grabOffset.x, 0, hit.z - _grabOffset.z);
    final bin = p.plant.bin;
    s.glowBin = p.pos.flatTo(bin.pos) < _binReach ? bin : null;
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`: into its bin, or back home (Elastic.Out,
  /// `playSound('error')`) with a hint.
  void _release() {
    final p = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (p == null || scenario != s.scenario) return;
    s
      ..held = null
      ..glowBin = null;
    final bin = s.binFor(p, _lastPointer, _touch * 0.5);
    if (bin == p.plant.bin) {
      _place(p);
      return;
    }
    final moved = p.pos.flatTo(p.plant.home) > _movedFar;
    p.glide(s.time, p.plant.home, _returnSeconds, _elasticOut);
    if (!moved) {
      // A tap on the plant: how to move it.
      _toast('hint_s1_${s.step}');
    } else if (bin != null) {
      _toast('wrong_bin_${p.plant.name}', error: true);
    } else {
      _toast('miss_${p.plant.name}', error: true);
    }
    _scheduleFraming();
  }

  /// HTML `handleDown` clicks: Scenario 1 steps 1–3 inspect the step's
  /// plant, Scenario 2 the step's zone (the HTML also took a click on the
  /// zone instead of a tool drop). Anything else of the scene explains the
  /// step.
  void _onStageTap(TapUpDetails d) {
    final s = _scene;
    if (!_stageLive) return;
    final step = s.step;
    if (step > _taskSteps) return;
    final p = d.localPosition;
    if (s.scenario == 0) {
      // Steps 4–6 are drags; the grab handles a press on a plant.
      if (step > 3) return;
      final plant = s.plantAt(p, _touch);
      if (plant == null) return;
      if (plant.plant.index == step - 1) {
        _inspect(plant.plant.subject);
      } else {
        _toast('hint_s1_$step', error: true);
      }
      return;
    }
    final zone = s.zoneAt(p, _touch);
    if (zone == null) return;
    if (zone.index == step - 1) {
      _inspect(zone.subject);
    } else {
      _toast('wrong_s2_$step', error: true);
    }
  }

  /// A tool can be dragged onto the bench (Scenario 2, steps 1–6).
  bool get _canUseTool =>
      _stageLive && _scene.scenario == 1 && _scene.step <= _taskSteps;

  /// The step's zone, under a tool that inspects it, or null.
  _Zone? _toolTarget(_Tool tool, Offset global) {
    final local = labGlobalToLocal(_designKey, global);
    if (local == null) return null;
    final zone = _scene.zoneAt(local, _touch);
    if (zone == null || zone.index != _scene.step - 1 || zone.tool != tool) {
      return null;
    }
    return zone;
  }

  /// HTML `dragover`: the zone glows when the right tool is over it.
  void _onToolHover(_Tool tool, Offset global) {
    if (!_canUseTool) return;
    _scene.hoverZone = _toolTarget(tool, global);
  }

  /// HTML `drop`: the magnifier on a leaf or a seed, the scanner on the
  /// soil, each in its step, inspects the zone; anything else is an error.
  void _onToolDrop(_Tool tool, Offset global) {
    final s = _scene;
    s.hoverZone = null;
    if (!_canUseTool) return;
    final zone = _toolTarget(tool, global);
    if (zone != null) {
      _inspect(zone.subject);
    } else {
      _toast('wrong_s2_${s.step}', error: true);
    }
  }

  // -------------------------------------------------------------------- UI

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
        final s = context.labScale;
        final p = _lab.palette;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final step = _scene.step;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final open = _lab.isSidebarOpen;
        final live = _lab.isLabActive && _lab.popup == null;
        final subject = _scene.inspecting;
        final above = inset.bottom + (open ? _hudReserve * s : 0);
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _t('s${sc + 1}_hud_${step.clamp(1, _stepCount)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('steps_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$step'),
            steps: _stepData,
            current: step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('step_word'),
            focusLabel: _t('focus_lbl'),
            actionLabel: _t('action_lbl'),
            observationLabel: _t('obs_lbl'),
            pendingText: _t('pending'),
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#virtual-toolkit` (Scenario 2), on the right of the
            // canvas; hidden while the inspection card is there.
            if (_lab.isLabActive && sc == 1 && subject == null)
              Positioned(
                key: const ValueKey('ch2a3-toolkit'),
                right: inset.right,
                top: inset.top,
                bottom: above,
                child: Center(child: _toolkit(p, s)),
              ),
            // HTML `#compare-btn-container`, above the HUD. While the
            // sidebar is collapsed the mission card carries it.
            if (actions.isNotEmpty && live && open)
              Positioned(
                key: const ValueKey('ch2a3-review'),
                left: inset.left,
                right: inset.right,
                bottom: above,
                child: Center(
                  child: FittedBox(
                    key: _actionKey,
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(
                      action: actions.first,
                      scale: s,
                      expand: false,
                    ),
                  ),
                ),
              ),
            // HTML `#inspection-panel`: on the right, so the plant the
            // camera closed in on stays in view.
            if (_cardShown && subject != null)
              Positioned(
                key: const ValueKey('ch2a3-card'),
                right: inset.right,
                top: inset.top,
                bottom: above,
                child: Center(
                  child: _InspectionCard(
                    key: ValueKey('ch2a3-card-${subject.name}'),
                    subject: subject,
                    title: _t('insp_${subject.name}'),
                    label: _t('obs_lbl'),
                    observation: _t(
                      's${subject.scenario + 1}_obs_${subject.step}',
                    ),
                    button: _t('got_it'),
                    open: _cardOpen,
                    onClose: _closeInspection,
                    isDark: _lab.isDark,
                    palette: p,
                    scale: s,
                    width: _cardWidth(s),
                    visual: CustomPaint(
                      painter: _InspectVisualPainter(
                        scene: _scene,
                        art: subject.art,
                        repaint: _frame,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#virtual-toolkit`: the magnifying glass and the X-ray scanner,
  /// dragged onto the bench (a tap explains how).
  Widget _toolkit(LabPalette p, double s) {
    final title = _t('toolkit');
    return Container(
      key: _toolkitKey,
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Colors.emerald500.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: p.ink(_Colors.emerald500),
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(title, 1.4),
            ),
          ),
          Container(
            width: 56 * s,
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 6 * s),
            color: p.cardBorder,
          ),
          for (final tool in _Tool.values) ...[
            if (tool.index > 0) SizedBox(height: 8 * s),
            _toolTile(tool, s),
          ],
        ],
      ),
    );
  }

  Widget _toolTile(_Tool tool, double s) {
    final label = _t(tool.labelKey);
    final dark = _lab.isDark;
    Widget face({bool lifted = false}) => _ToolFace(
      tool: tool,
      label: label,
      isDark: dark,
      scale: s,
      lifted: lifted,
    );
    return Draggable<_Tool>(
      data: tool,
      maxSimultaneousDrags: _canUseTool ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragEnd: (_) => _scene.hoverZone = null,
      // Centred on the finger (HTML `setDragImage`).
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: face(lifted: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: face()),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          key: ValueKey('ch2a3-tool-${tool.name}'),
          borderRadius: BorderRadius.circular(14 * s),
          onTap: () => _toast('hint_${tool.name}'),
          child: face(),
        ),
      ),
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
          child: DragTarget<_Tool>(
            onWillAcceptWithDetails: (_) => _canUseTool,
            onMove: (d) => _onToolHover(d.data, d.offset),
            onLeave: (_) => _scene.hoverZone = null,
            onAcceptWithDetails: (d) => _onToolDrop(d.data, d.offset),
            builder: (context, candidates, rejected) => RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              // Drags and taps on the scene are not screen-reader actions;
              // the scene is announced by its label instead.
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
                        ..onCancel = _release,
                    ),
                TapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                      () => TapGestureRecognizer(debugOwner: this),
                      (r) => r.onTapUp = _onStageTap,
                    ),
              },
              child: Semantics(
                image: true,
                label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
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
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action, observation and explanation. The current step is
/// open, done steps show a tick and can be re-opened, future steps are
/// dimmed. A step's observation and explanation are shown once the step is
/// done (the HTML showed them before the learner had seen them).
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
    required this.observationLabel,
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
  final String observationLabel;
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
                  _body(step.action, p.text),
                  if (step.observation.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    _heading(w.observationLabel, p.textStrong),
                    SizedBox(height: 3 * s),
                    if (past)
                      _body(step.observation, p.text)
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

/// One toolkit tool (HTML `.toolkit-item`): a coloured tile with its icon
/// and name. Built without the shell's style scope so it can also be the
/// drag feedback.
class _ToolFace extends StatelessWidget {
  const _ToolFace({
    required this.tool,
    required this.label,
    required this.isDark,
    required this.scale,
    this.lifted = false,
  });

  final _Tool tool;
  final String label;
  final bool isDark;
  final double scale;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: 66 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46 * s,
            height: 46 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? tool.tileDark : tool.tile,
              borderRadius: BorderRadius.circular(14 * s),
              border: Border.all(color: tool.edge, width: 2),
              boxShadow: [
                BoxShadow(
                  color: lifted ? LabInk.shadowStrong : LabInk.shadowSoft,
                  blurRadius: lifted ? 14 : 4,
                  offset: Offset(0, lifted ? 6 : 1),
                ),
              ],
            ),
            child: Icon(
              tool.icon,
              size: 24 * s,
              color: isDark ? tool.inkDark : tool.ink,
            ),
          ),
          SizedBox(height: 3 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? _Colors.slate300 : _Colors.slate600,
              fontSize: 9 * s,
              fontWeight: FontWeight.w700,
              height: 1.15,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML `#inspection-panel`: the tool badge and title, the picture (drawn
/// in, `.svg-animate-dash`), "Observation: …" and 'Got it!'. It scales in
/// when [open] turns on and out when it turns off.
class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    super.key,
    required this.subject,
    required this.title,
    required this.label,
    required this.observation,
    required this.button,
    required this.open,
    required this.onClose,
    required this.isDark,
    required this.palette,
    required this.scale,
    required this.width,
    required this.visual,
  });

  final _Subject subject;
  final String title;
  final String label;
  final String observation;
  final String button;
  final bool open;
  final VoidCallback onClose;
  final bool isDark;
  final LabPalette palette;
  final double scale;
  final double width;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final height = MediaQuery.sizeOf(context).height;
    final side = math.min(_cardVisual * s, height * 0.3);
    final card = Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? _Colors.cardDark : _Colors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _Colors.emerald500.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: _Colors.cardShadow,
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32 * s,
                  height: 32 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? _Colors.badgeDark : _Colors.emerald100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subject.icon,
                    size: 17 * s,
                    color: isDark ? _Colors.emerald400 : _Colors.emerald600,
                  ),
                ),
                SizedBox(width: 8 * s),
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title, 1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Semantics(
              image: true,
              label: title,
              child: Container(
                width: side,
                height: side,
                padding: EdgeInsets.all(8 * s),
                decoration: BoxDecoration(
                  color: isDark ? _Colors.slate800 : _Colors.slate100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? _Colors.slate700 : _Colors.slate300,
                  ),
                ),
                child: visual,
              ),
            ),
            SizedBox(height: 12 * s),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: p.ink(_Colors.emerald500),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: observation),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? _Colors.slate300 : _Colors.slate600,
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14 * s),
            FilledButton(
              onPressed: open ? onClose : null,
              style: FilledButton.styleFrom(
                backgroundColor: _Colors.emerald600,
                foregroundColor: _Colors.white,
                disabledBackgroundColor: _Colors.emerald600,
                disabledForegroundColor: _Colors.white,
                minimumSize: const Size(0, kMinInteractiveDimension),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(button),
            ),
          ],
        ),
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: _cardFade,
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
      ),
      child: card,
    );
  }
}

/// HTML `#summary-visual-area`: Scenario 1 the three plant classes (Herb,
/// Shrub, Tree with their bin icons), Scenario 2 the dicot and monocot
/// profiles (venation, root system, cotyledons); and, after Scenario 1, the
/// HTML's "select the next" note.
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.t,
    required this.nextHint,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;
  final bool nextHint;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        scenario == 0 ? _classes() : _profiles(),
        if (nextHint) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.noteBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Colors.noteBorder),
            ),
            child: Text(
              t('select_next_sc_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.amber400),
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _classes() {
    final s = scale;
    final classes = [
      (
        t('sum_herb'),
        _Colors.green400,
        _Art.herbBin,
        _Colors.green500,
        '${t('sum_soft')} ${t('sum_stem')}',
      ),
      (
        t('sum_shrub'),
        _Colors.amber400,
        _Art.shrubBin,
        _Colors.amber500,
        '${t('sum_hard')} ${t('sum_stem')}',
      ),
      (
        t('sum_tree'),
        _Colors.emerald400,
        _Art.treeBin,
        _Colors.emerald700,
        t('sum_trunk'),
      ),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < classes.length; i++) ...[
            if (i > 0) SizedBox(width: 8 * s),
            Expanded(child: _classCard(classes[i])),
          ],
        ],
      ),
    );
  }

  Widget _classCard((String, Color, _Art, Color, String) c) {
    final p = palette;
    final s = scale;
    final (name, nameColor, icon, iconColor, caption) = c;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(nameColor),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            width: 48 * s,
            height: 48 * s,
            child: CustomPaint(painter: _ArtPainter(icon, tint: iconColor)),
          ),
          SizedBox(height: 6 * s),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profiles() {
    final s = scale;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _profile(t('sum_dicot'), _Colors.emerald400, [
              (t('sum_reticulate'), _Art.leafReticulate),
              (t('sum_taproot'), _Art.taproot),
              (t('sum_two_cot'), _Art.seedDicot),
            ], _Colors.emerald500),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: _profile(t('sum_monocot'), _Colors.lime400, [
              (t('sum_parallel'), _Art.leafParallel),
              (t('sum_fibrous'), _Art.fibrousRoot),
              (t('sum_one_cot'), _Art.seedMonocot),
            ], _Colors.lime500),
          ),
        ],
      ),
    );
  }

  Widget _profile(
    String title,
    Color color,
    List<(String, _Art)> rows,
    Color edge,
  ) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edge.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(color),
              fontSize: 13 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 8 * s),
            color: p.cardBorder,
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 6 * s),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 6 * s),
                Container(
                  width: 36 * s,
                  height: 36 * s,
                  padding: EdgeInsets.all(4 * s),
                  decoration: BoxDecoration(
                    color: _Colors.slate800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(painter: _ArtPainter(rows[i].$2)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// The HTML's SVG pictures: the plant and seed sprites of the scenes, the
/// inspection card pictures and the bin icons.
enum _Art {
  tomato(100),
  rose(100),
  mango(100),
  chickpea(100),
  maize(100),
  chickpeaSeed(100),
  maizeSeed(100),
  stemSoft(100),
  stemHard(100),
  stemTrunk(100),
  leafReticulate(24),
  leafParallel(24),
  taproot(24),
  fibrousRoot(24),
  seedDicot(24),
  seedMonocot(24),
  herbBin(24),
  shrubBin(24),
  treeBin(24);

  const _Art(this.viewBox);

  /// Side of the SVG `viewBox`.
  final double viewBox;

  List<_Op> get ops => _ArtBook.of(this);
}

final RegExp _svgToken = RegExp(
  r'[MmLlHhVvCcSsQqTtZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
);

/// Parses SVG path data (absolute and relative `M L H V C S Q T Z`) into a
/// [Path], so the HTML's pictures are drawn from their own path strings.
Path _svgPath(String d) {
  final tokens = [for (final m in _svgToken.allMatches(d)) m[0]!];
  final path = Path();
  bool isCommand(String token) => 'MmLlHhVvCcSsQqTtZz'.contains(token);
  var i = 0;
  var command = '';
  var previous = '';
  // Current point, start of the subpath and the last control point (which
  // S and T reflect).
  var x = 0.0, y = 0.0;
  var startX = 0.0, startY = 0.0;
  var ctrlX = 0.0, ctrlY = 0.0;
  double next() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (isCommand(tokens[i])) {
      command = tokens[i++];
    } else if (command.isEmpty || command == 'Z' || command == 'z') {
      break;
    }
    final relative = command == command.toLowerCase();
    final ox = relative ? x : 0.0;
    final oy = relative ? y : 0.0;
    final upper = command.toUpperCase();
    switch (upper) {
      case 'M':
        x = ox + next();
        y = oy + next();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // Further pairs are line segments.
        command = relative ? 'l' : 'L';
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
        final x1 = ox + next();
        final y1 = oy + next();
        ctrlX = ox + next();
        ctrlY = oy + next();
        x = ox + next();
        y = oy + next();
        path.cubicTo(x1, y1, ctrlX, ctrlY, x, y);
      case 'S':
        final smooth = previous == 'C' || previous == 'S';
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
        final smooth = previous == 'Q' || previous == 'T';
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
    previous = upper;
  }
  return path;
}

/// One shape of an SVG picture: its path, fill (or `currentColor`) and
/// stroke.
class _Op {
  _Op.path(
    String d, {
    this.fill,
    this.stroke,
    this.width = 0,
    this.round = false,
    this.drawIn = false,
    this.current = false,
  }) : path = _svgPath(d);

  _Op.circle(double cx, double cy, double r, {required Color this.fill})
    : path = (Path()
        ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r))),
      stroke = null,
      width = 0,
      round = false,
      drawIn = false,
      current = false;

  _Op.ellipse(
    double cx,
    double cy,
    double rx,
    double ry, {
    required Color this.fill,
    this.stroke,
    this.width = 0,
  }) : path = (Path()
         ..addOval(
           Rect.fromCenter(
             center: Offset(cx, cy),
             width: 2 * rx,
             height: 2 * ry,
           ),
         )),
       round = false,
       drawIn = false,
       current = false;

  _Op.rect(double x, double y, double w, double h, {required Color this.fill})
    : path = (Path()..addRect(Rect.fromLTWH(x, y, w, h))),
      stroke = null,
      width = 0,
      round = false,
      drawIn = false,
      current = false;

  final Path path;
  final Color? fill;
  final Color? stroke;
  final double width;

  /// `stroke-linecap="round"`.
  final bool round;

  /// Drawn in by the `.svg-animate-dash` animation.
  final bool drawIn;

  /// `fill="currentColor"`.
  final bool current;

  /// The path's contours, for the draw-in.
  late final List<ui.PathMetric> metrics = path.computeMetrics().toList();
}

/// The HTML `SVGs` table, path for path (made once, on first use).
abstract final class _ArtBook {
  static final Map<_Art, List<_Op>> _ops = {};

  static List<_Op> of(_Art art) => _ops[art] ??= _build(art);

  static List<_Op> _leaves(List<String> paths, Color fill) => [
    for (final d in paths) _Op.path(d, fill: fill),
  ];

  static List<_Op> _dots(
    List<(double, double)> centres,
    double r,
    Color fill,
  ) => [for (final (x, y) in centres) _Op.circle(x, y, r, fill: fill)];

  static List<_Op> _build(_Art art) {
    switch (art) {
      case _Art.tomato:
        return [
          _Op.path(
            'M50 95 L50 20',
            stroke: const Color(0xFF16A34A),
            width: 3,
            round: true,
          ),
          ..._leaves(const [
            'M50 80 Q35 70 30 85 Q40 90 50 80',
            'M50 60 Q65 50 70 65 Q60 70 50 60',
            'M50 40 Q35 30 30 45 Q40 50 50 40',
            'M50 25 Q65 15 70 30 Q60 35 50 25',
          ], const Color(0xFF22C55E)),
          ..._dots(const [(35, 65), (65, 45), (35, 30)], 6, _Colors.red500),
        ];
      case _Art.rose:
        return [
          _Op.path(
            'M50 95 L50 60 M50 85 L30 55 M50 80 L70 50 M35 70 L20 60 M65 65 L80 55',
            stroke: const Color(0xFF78350F),
            width: 4,
            round: true,
          ),
          _Op.circle(30, 45, 18, fill: const Color(0xFF15803D)),
          _Op.circle(70, 40, 18, fill: const Color(0xFF15803D)),
          _Op.circle(50, 30, 22, fill: const Color(0xFF16A34A)),
          _Op.circle(20, 60, 14, fill: const Color(0xFF16A34A)),
          _Op.circle(80, 55, 14, fill: const Color(0xFF15803D)),
          ..._dots(
            const [(30, 40), (65, 35), (50, 20), (25, 60), (75, 50)],
            4,
            const Color(0xFFF43F5E),
          ),
        ];
      case _Art.mango:
        return [
          _Op.path(
            'M45 95 C45 60 42 50 42 40 L58 40 C58 50 55 60 55 95 Z',
            fill: const Color(0xFF451A03),
          ),
          _Op.path(
            'M42 95 Q30 95 25 100 M58 95 Q70 95 75 100',
            stroke: const Color(0xFF451A03),
            width: 4,
            round: true,
          ),
          _Op.circle(50, 40, 28, fill: const Color(0xFF166534)),
          _Op.circle(30, 35, 22, fill: const Color(0xFF15803D)),
          _Op.circle(70, 35, 22, fill: const Color(0xFF15803D)),
          _Op.circle(50, 20, 22, fill: const Color(0xFF14532D)),
          for (final (x, y) in const <(double, double)>[
            (35, 35),
            (65, 25),
            (45, 45),
            (55, 15),
            (25, 20),
            (75, 40),
          ])
            _Op.ellipse(x, y, 3.5, 5.5, fill: _Colors.amber500),
        ];
      case _Art.chickpea:
        return [
          _Op.path(
            'M50 95 L50 40 M50 70 L30 50 M50 60 L70 40 M30 60 L15 45 M70 55 L85 45',
            stroke: const Color(0xFF65A30D),
            width: 4,
            round: true,
          ),
          ..._leaves(const [
            'M50 40 Q40 20 50 15 Q60 20 50 40',
            'M30 50 Q20 30 30 25 Q40 30 30 50',
            'M70 40 Q60 20 70 15 Q80 20 70 40',
            'M15 45 Q5 25 15 20 Q25 25 15 45',
            'M85 45 Q75 25 85 20 Q95 25 85 45',
          ], _Colors.green400),
          _Op.path(
            'M50 40 L50 20 M30 50 L30 30 M70 40 L70 20 M15 45 L15 25 M85 45 L85 25',
            stroke: const Color(0xFF166534),
            width: 1.5,
          ),
        ];
      case _Art.maize:
        return [
          _Op.path(
            'M50 95 L50 10',
            stroke: _Colors.lime400,
            width: 6,
            round: true,
          ),
          ..._leaves(const [
            'M50 80 Q30 70 20 40 Q40 50 50 75',
            'M50 65 Q70 55 80 25 Q60 35 50 60',
            'M50 50 Q30 40 15 15 Q35 25 50 45',
            'M50 35 Q70 25 85 5 Q65 15 50 30',
          ], const Color(0xFF65A30D)),
          _Op.path(
            'M50 80 L25 45 M50 65 L75 30 M50 50 L20 20 M50 35 L80 10',
            stroke: const Color(0xFF4D7C0F),
            width: 1.5,
          ),
        ];
      case _Art.chickpeaSeed:
        return [
          _Op.path(
            'M30 50 C30 20 70 20 70 50 C70 80 40 80 30 50 Z',
            fill: const Color(0xFFFDE047),
            stroke: const Color(0xFFCA8A04),
            width: 4,
          ),
          _Op.path(
            'M45 40 Q35 50 40 65',
            stroke: const Color(0xFFCA8A04),
            width: 4,
            round: true,
          ),
        ];
      case _Art.maizeSeed:
        return [
          _Op.path(
            'M40 20 Q70 20 70 50 Q70 80 50 80 Q30 80 30 50 Q30 20 40 20 Z',
            fill: const Color(0xFFFEF08A),
            stroke: const Color(0xFFD97706),
            width: 4,
          ),
          _Op.path(
            'M45 30 Q55 50 45 70',
            stroke: const Color(0xFFD97706),
            width: 3,
            round: true,
          ),
        ];
      case _Art.stemSoft:
        return [
          _Op.path(
            'M40 90 Q10 50 60 10',
            stroke: _Colors.green500,
            width: 8,
            round: true,
            drawIn: true,
          ),
          _Op.path(
            'M70 60 Q50 55 45 40',
            stroke: _Colors.amber500,
            width: 6,
            round: true,
            drawIn: true,
          ),
          _Op.circle(75, 65, 8, fill: const Color(0xFFFCD34D)),
        ];
      case _Art.stemHard:
        return [
          _Op.rect(45, 20, 10, 70, fill: const Color(0xFF78350F)),
          _Op.path(
            'M45 60 L20 40 M55 50 L80 30',
            stroke: const Color(0xFF78350F),
            width: 6,
            round: true,
          ),
          _Op.path(
            'M80 50 Q60 50 50 40',
            stroke: _Colors.amber500,
            width: 6,
            round: true,
            drawIn: true,
          ),
          _Op.circle(85, 50, 8, fill: const Color(0xFFFCD34D)),
        ];
      case _Art.stemTrunk:
        return [
          _Op.rect(35, 10, 30, 90, fill: const Color(0xFF451A03)),
          _Op.path(
            'M75 50 Q60 50 50 40',
            stroke: _Colors.amber500,
            width: 6,
            round: true,
            drawIn: true,
          ),
          _Op.circle(80, 50, 8, fill: const Color(0xFFFCD34D)),
        ];
      case _Art.leafReticulate:
        return [
          _Op.path(
            'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z',
            fill: _Colors.green400,
          ),
          _Op.path(
            'M12 4v16m-4-8h8m-6-6l4 4m-4 0l4-4m-4 8l4 4m-4 0l4-4',
            stroke: const Color(0xFF166534),
            width: 1.5,
            round: true,
          ),
        ];
      case _Art.leafParallel:
        return [
          _Op.path(
            'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z',
            fill: _Colors.lime400,
          ),
          _Op.path(
            'M8 4v16m8-16v16m-4-16v16',
            stroke: const Color(0xFF4D7C0F),
            width: 1.5,
            round: true,
          ),
        ];
      case _Art.taproot:
        return [
          _Op.path(
            'M12 2v18',
            stroke: const Color(0xFF78350F),
            width: 3,
            round: true,
          ),
          _Op.path(
            'M12 6l-3 3m3-1l4 4m-4 2l-2 2m2-1l3 3',
            stroke: const Color(0xFF78350F),
            width: 1.5,
            round: true,
          ),
        ];
      case _Art.fibrousRoot:
        return [
          _Op.path(
            'M12 2l-4 18m4-18l-2 17m2-17v18m0-18l2 17m-2-17l4 18M12 2l-6 15m6-15l6 15',
            stroke: const Color(0xFF92400E),
            width: 1.5,
            round: true,
          ),
        ];
      case _Art.seedDicot:
        return [
          for (final x in const [9.0, 15.0])
            _Op.ellipse(
              x,
              12,
              4,
              8,
              fill: const Color(0xFFFDE047),
              stroke: const Color(0xFFCA8A04),
              width: 1.5,
            ),
        ];
      case _Art.seedMonocot:
        return [
          _Op.ellipse(
            12,
            12,
            6,
            9,
            fill: const Color(0xFFFEF08A),
            stroke: const Color(0xFFD97706),
            width: 1.5,
          ),
        ];
      case _Art.herbBin:
        return [
          _Op.path(
            'M12 22v-8m0 0C9 14 6 17 6 17s0-4 3-6c-3 0-6 2-6 2s1-4 4-5c3-1 5 0 5 0s-2-2-5-1c-1 0-1-2 1-2 3 0 6 3 6 3s3-3 6-3c2 0 2 2 1 2-3-1-5 1-5 1s2-1 5 0c3 1 4 5 4 5s-3-2-6-2c3 2 3 6 3 6s-3-3-6-3v8Z',
            current: true,
          ),
        ];
      case _Art.shrubBin:
        return [
          _Op.path(
            'M12 22v-6m-4 6v-5m8 5v-4M7 10C5 10 3 12 3 14c0 2 2 3 4 3 0 2 2 4 5 4 3 0 5-2 5-4 2 0 4-1 4-3 0-2-2-4-4-4 0-3-3-5-6-5-3 0-6 2-4 5Z',
            current: true,
          ),
        ];
      case _Art.treeBin:
        return [
          _Op.path(
            'M11 22h2v-8h-2v8ZM12 2C7 2 3 5 3 10c0 4 3 6 5 7 0 1 1 2 2 2h4c1 0 2-1 2-2 2-1 5-3 5-7 0-5-4-8-9-8Z',
            current: true,
          ),
        ];
    }
  }
}

/// Draws [art] into [box] with the reused [fill] and [stroke] paints;
/// `currentColor` shapes take [tint]. Shapes that are drawn in show their
/// first [drawn] units (the 100-unit dash of `.svg-animate-dash`).
void _drawArt(
  Canvas canvas,
  _Art art,
  Rect box,
  Paint fill,
  Paint stroke, {
  Color? tint,
  double drawn = double.infinity,
}) {
  canvas.save();
  canvas.translate(box.left, box.top);
  canvas.scale(box.width / art.viewBox, box.height / art.viewBox);
  for (final op in art.ops) {
    final fillColor = op.current ? tint : op.fill;
    if (fillColor != null) canvas.drawPath(op.path, fill..color = fillColor);
    final strokeColor = op.stroke;
    if (strokeColor == null || op.width <= 0) continue;
    stroke
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = op.width
      ..strokeCap = op.round ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;
    if (op.drawIn && drawn.isFinite) {
      if (drawn <= 0) continue;
      final part = Path();
      var left = drawn;
      for (final m in op.metrics) {
        if (left <= 0) break;
        part.addPath(m.extractPath(0, math.min(left, m.length)), Offset.zero);
        left -= m.length;
      }
      canvas.drawPath(part, stroke);
    } else {
      canvas.drawPath(op.path, stroke);
    }
  }
  canvas.restore();
}

/// A picture for widgets (the summary). Static pictures, so the paints are
/// shared.
class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.art, {this.tint});

  final _Art art;
  final Color? tint;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) =>
      _drawArt(canvas, art, Offset.zero & size, _fill, _stroke, tint: tint);

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.art != art || old.tint != tint;
}

/// The inspection card's picture, its strokes drawn in over 2 s once the
/// card opens (HTML `.svg-animate-dash`).
class _InspectVisualPainter extends CustomPainter {
  _InspectVisualPainter({
    required this.scene,
    required this.art,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _Art art;

  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final t0 = scene.cardAt;
    final t = t0 < 0 ? 0.0 : ((scene.time - t0) / _drawSeconds).clamp(0.0, 1.0);
    final drawn = _dashLength * Curves.easeInOut.transform(t);
    _drawArt(canvas, art, Offset.zero & size, _fill, _stroke, drawn: drawn);
  }

  @override
  bool shouldRepaint(covariant _InspectVisualPainter old) =>
      old.scene != scene || old.art != art;
}

/// Paints and the path reused by every frame.
class _Pens {
  final Paint fill = Paint();

  /// Gradient fills (the ground, the bench, cylinder sides).
  final Paint shaded = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Paint blob = Paint()
    ..color = _Colors.blob
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// The SVG pictures (their caps and joins change per shape).
  final Paint artFill = Paint();
  final Paint artStroke = Paint()..style = PaintingStyle.stroke;
  final Path path = Path();
}

/// What the painter makes once and reuses: pens and the label text
/// painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
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

  TextPainter label(String text, double factor, Color color) =>
      _labels['$factor|${color.toARGB32()}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: _labelSize * factor,
            fontWeight: FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Size of a label chip with [text] at [factor] times the label size.
  Size chipSize(String text, double factor, Color color) {
    final tp = label(text, factor, color);
    final k = _labelSize * factor;
    return Size(tp.width + 2 * _chipPadX * k, tp.height + 2 * _chipPadY * k);
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() => _disposeLabels();
}

/// HTML key light `DirectionalLight(0xfff5b6, 0.8)` at (15, 25, 15) and
/// fill light `DirectionalLight(0xaabbff, 0.3)` at (-15, 10, -15),
/// normalised, and `AmbientLight(0xffffff, 0.6)`.
const _V _keyDir = _V(0.45749, 0.76249, 0.45749);
const _V _fillDir = _V(-0.63960, 0.42640, -0.63960);
const double _ambient = 0.6;
const double _keyPower = 0.8;
const double _fillPower = 0.3;

/// MeshStandardMaterial look: ambient light plus the two directional
/// lights' Lambert terms on a face with normal [n].
Color _lit(Color c, _V n) {
  final k = _keyPower * math.max(0.0, n.dot(_keyDir));
  final f = _fillPower * math.max(0.0, n.dot(_fillDir));
  const kl = _Colors.keyLight;
  const fl = _Colors.fillLight;
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * (_ambient + k * kl.r + f * fl.r)),
    green: math.min(1.0, c.g * (_ambient + k * kl.g + f * fl.g)),
    blue: math.min(1.0, c.b * (_ambient + k * kl.b + f * fl.b)),
  );
}

/// [c] seen through the HTML `FogExp2` at [distance] from the camera.
Color _fogged(Color c, Color fog, double distance) {
  final d = _fogDensity * distance;
  final amount = (1 - math.exp(-d * d)).clamp(0.0, 1.0);
  return Color.lerp(c, fog.withValues(alpha: c.a), amount)!;
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache, this.fog);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  /// Fog (and background) colour.
  final Color fog;

  _Pens get pens => cache.pens;

  /// MeshStandardMaterial colour [c] on a face with normal [n] at [at], in
  /// the fog.
  Color lit(Color c, _V n, _V at) =>
      _fogged(_lit(c, n), fog, (at - cam.eye).length);

  Path _polyPath(List<_V> pts) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      final o = cam.p(pts[i]);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    return path..close();
  }

  /// A flat polygon (already lit [color]), with an optional darker edge.
  void poly(List<_V> pts, Color color, {double edge = 0}) {
    final path = _polyPath(pts);
    canvas.drawPath(path, pens.fill..color = color);
    if (edge > 0) {
      canvas.drawPath(
        path,
        pens.edge
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: edge),
      );
    }
  }

  /// A horizontal plane at height [y] from [near] to [far] (z), [halfX]
  /// wide, lit from above and fading into the fog with distance.
  void floor(double halfX, double near, double far, double y, Color color) {
    final a = cam.p(_V(0, y, near));
    final b = cam.p(_V(0, y, far));
    final len = (b - a).distance;
    final path = _polyPath([
      _V(-halfX, y, far),
      _V(halfX, y, far),
      _V(halfX, y, near),
      _V(-halfX, y, near),
    ]);
    if (len < 1) {
      canvas.drawPath(
        path,
        pens.fill..color = lit(color, _V.up, _V(0, y, near)),
      );
      return;
    }
    const samples = 6;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < samples; i++) {
      final at = _V(0, y, near + (far - near) * i / (samples - 1));
      colors.add(lit(color, _V.up, at));
      stops.add(((cam.p(at) - a).distance / len).clamp(0.0, 1.0));
    }
    stops
      ..first = 0
      ..last = 1;
    canvas.drawPath(
      path,
      pens.shaded..shader = ui.Gradient.linear(a, b, colors, stops),
    );
  }

  /// The screen ellipse of a horizontal circle of radius [r] around [c].
  Rect circle(_V c, double r) {
    final p = cam.p(c);
    final w = r * cam.scaleAt(c);
    final h = (cam.p(c + _V(0, 0, r)).dy - cam.p(c - _V(0, 0, r)).dy).abs() / 2;
    return Rect.fromCenter(
      center: p,
      width: 2 * math.max(0.5, w),
      height: 2 * math.max(0.5, h),
    );
  }

  /// The visible side of an upright (tapered) cylinder from [base]:
  /// shaded across like a lit MeshStandardMaterial, or a flat [color]
  /// ([shade] off, for the see-through zones).
  void cylinder(
    _V base,
    double rBottom,
    double rTop,
    double height,
    Color color, {
    bool shade = true,
  }) {
    final bottom = circle(base, rBottom);
    final top = circle(base + _V(0, height, 0), rTop);
    final path = pens.path
      ..reset()
      ..moveTo(top.left, top.center.dy)
      ..arcTo(top, math.pi, -math.pi, false)
      ..lineTo(bottom.right, bottom.center.dy)
      ..arcTo(bottom, 0, math.pi, false)
      ..close();
    if (!shade) {
      canvas.drawPath(path, pens.fill..color = color);
      return;
    }
    final left = math.min(top.left, bottom.left);
    final right = math.max(top.right, bottom.right);
    final mid = base + _V(0, height / 2, 0);
    final slope = (rBottom - rTop) / height;
    const samples = 9;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < samples; i++) {
      final a = -math.pi / 2 + math.pi * i / (samples - 1);
      final n = _V(math.sin(a), slope, math.cos(a)).unit;
      colors.add(lit(color, n, mid));
      stops.add((math.sin(a) + 1) / 2);
    }
    canvas.drawPath(
      path,
      pens.shaded
        ..shader = ui.Gradient.linear(
          Offset(left, 0),
          Offset(right, 0),
          colors,
          stops,
        ),
    );
  }

  /// A flat disc (lit [color]) of radius [r] around [c].
  void disc(_V c, double r, Color color) =>
      canvas.drawOval(circle(c, r), pens.fill..color = color);

  /// Half of a horizontal ring (TorusGeometry) of radius [r] around [c]:
  /// the half nearer the camera ([front]) or the far half; [glow] adds a
  /// soft halo.
  void ringHalf(
    _V c,
    double r,
    double tube,
    Color color, {
    required bool front,
    bool glow = false,
  }) {
    final rect = circle(c, r);
    final w = math.max(1.2, 2 * tube * cam.scaleAt(c));
    final start = front ? 0.0 : math.pi;
    if (glow) {
      canvas.drawArc(
        rect,
        start,
        math.pi,
        false,
        pens.glow
          ..strokeWidth = w * 3
          ..color = color.withValues(alpha: 0.7),
      );
    }
    canvas.drawArc(
      rect,
      start,
      math.pi,
      false,
      pens.stroke
        ..strokeWidth = w
        ..color = color,
    );
  }

  /// Soft contact shadow: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz, {Paint? paint}) {
    final rect = circle(c, 1);
    final k = cam.scaleAt(c);
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center,
        width: 2 * rx * k,
        height: math.max(2, rect.height * rz),
      ),
      paint ?? pens.shadow,
    );
  }

  /// A sprite (always facing the camera) showing [art], [size] world units
  /// square, centred on [c].
  void sprite(_Art art, _V c, double size, {Color? tint}) {
    final side = size * cam.scaleAt(c);
    if (side < 0.5) return;
    _drawArt(
      canvas,
      art,
      Rect.fromCenter(center: cam.p(c), width: side, height: side),
      pens.artFill,
      pens.artStroke,
      tint: tint,
    );
  }

  /// [art] on an upright plane facing +z, centred on [c], 2 x [half] world
  /// units square (a decal on a bin's front).
  void decal(_Art art, _V c, double half, Color tint) {
    final o = cam.p(c + _V(-half, half, 0));
    final ax = cam.p(c + _V(half, half, 0)) - o;
    final ay = cam.p(c + _V(-half, -half, 0)) - o;
    canvas.save();
    canvas.transform(
      Matrix4(
        ax.dx,
        ax.dy,
        0,
        0,
        ay.dx,
        ay.dy,
        0,
        0,
        0,
        0,
        1,
        0,
        o.dx,
        o.dy,
        0,
        1,
      ).storage,
    );
    _drawArt(
      canvas,
      art,
      const Rect.fromLTWH(0, 0, 1, 1),
      pens.artFill,
      pens.artStroke,
      tint: tint,
    );
    canvas.restore();
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the park
/// (ground, bins, plants), S2 the lab bench (pots, plants, zones, seeds);
/// then the labels and the confetti on top.
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
    final bg = isDark ? _Colors.sceneDark : _Colors.sceneLight;
    final g = _Gfx(canvas, s.camera(), cache, bg);
    canvas.drawRect(labBleed(size), _pens.fill..color = bg);
    if (s.scenario == 0) {
      _paintPark(g);
    } else {
      _paintBench(g);
    }
    if (showLabels) _paintLabels(g);
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: the ground, the bins and the plants, far to near.
  void _paintPark(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    g.floor(_groundBleedX, _groundNear, -_groundHalfZ, 0, _Colors.ground);
    // The bins cast soft shadows away from the key light.
    for (final b in _Bin.values) {
      g.shadow(b.pos + const _V(-0.45, 0.01, -0.45), 1.3, 1.3);
    }
    final items = <(double, _Bin?, _PlantState?)>[
      for (final b in _Bin.values) (cam.depth(b.pos), b, null),
      for (final p in s.plants)
        if (!p.placed) (cam.depth(p.pos), null, p),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, bin, plant) in items) {
      if (bin != null) _paintBin(g, bin);
      if (plant != null) _paintGroundPlant(g, plant);
    }
  }

  /// A plant on the ground: its shadow blob (`createShadowBlob`, a plane
  /// 2r x 1.2r) and its sprite.
  void _paintGroundPlant(_Gfx g, _PlantState p) {
    final r = p.plant.blob * p.scale;
    g.shadow(_V(p.pos.x, 0.05, p.pos.z), r, 0.6 * r, paint: _pens.blob);
    _paintSprite(g, p);
  }

  void _paintSprite(_Gfx g, _PlantState p) => g.sprite(
    p.plant.art,
    p.pos + _V(0, p.plant.size / 2 * p.scale, 0),
    p.plant.size * p.scale,
  );

  /// `createBin()`: the open octagonal bin (inside, floor, the plant
  /// sorted into it, outside walls, icon and rim) and its highlight ring.
  void _paintBin(_Gfx g, _Bin bin) {
    final s = scene;
    final cam = g.cam;
    final c = bin.pos;
    _V at(int k, double r, double y) {
      final a = k * 2 * math.pi / _binSides;
      return _V(c.x + r * math.sin(a), y, c.z + r * math.cos(a));
    }

    _V normal(int k) {
      final a = (k + 0.5) * 2 * math.pi / _binSides;
      return _V(
        math.sin(a),
        (_binBottomR - _binTopR) / _binHeight,
        math.cos(a),
      ).unit;
    }

    List<_V> face(int k) => [
      at(k, _binBottomR, 0),
      at(k + 1, _binBottomR, 0),
      at(k + 1, _binTopR, _binHeight),
      at(k, _binTopR, _binHeight),
    ];
    final outer = <int>[];
    final inner = <int>[];
    for (var k = 0; k < _binSides; k++) {
      final mid = (at(k, 1.1, 1) + at(k + 1, 1.1, 1)) * 0.5;
      (normal(k).dot(cam.eye - mid) > 0 ? outer : inner).add(k);
    }
    // The inside of the far walls and the floor.
    for (final k in inner) {
      g.poly(face(k), labShade(g.lit(bin.color, normal(k) * -1, c), -0.25));
    }
    g.poly([
      for (var k = 0; k < _binSides; k++) at(k, _binBottomR, _binFloor),
    ], labShade(g.lit(bin.color, _V.up, c), -0.2));
    final rimColor = labShade(g.lit(bin.color, _V.up, c), 0.08);
    _paintRim(g, c, rimColor, front: false);
    for (final p in s.plants) {
      if (p.placed && p.plant.bin == bin) _paintSprite(g, p);
    }
    for (final k in outer) {
      g.poly(face(k), g.lit(bin.color, normal(k), c), edge: 0.35);
    }
    g.decal(
      bin.icon,
      c + const _V(0, _iconY, _iconZ),
      _iconHalf,
      labShade(bin.color, -0.6),
    );
    _paintRim(g, c, rimColor, front: true);
    if (s.glowBin == bin) {
      final ring = c + const _V(0, _glowY, 0);
      g
        ..ringHalf(
          ring,
          _glowR,
          _rimTube,
          _Colors.binGlow,
          front: false,
          glow: true,
        )
        ..ringHalf(
          ring,
          _glowR,
          _rimTube,
          _Colors.binGlow,
          front: true,
          glow: true,
        );
    }
  }

  /// The rim `TorusGeometry(1.2, 0.1, 8, 8)`: the far or the near half of
  /// the octagon.
  void _paintRim(_Gfx g, _V c, Color color, {required bool front}) {
    final cam = g.cam;
    final pen = _pens.stroke
      ..strokeWidth = math.max(1.2, 2 * _rimTube * cam.scaleAt(c))
      ..color = color;
    for (var k = 0; k < _binSides; k++) {
      final a = k * 2 * math.pi / _binSides;
      final b = (k + 1) * 2 * math.pi / _binSides;
      final p = _V(
        c.x + _binTopR * math.sin(a),
        _binHeight,
        c.z + _binTopR * math.cos(a),
      );
      final q = _V(
        c.x + _binTopR * math.sin(b),
        _binHeight,
        c.z + _binTopR * math.cos(b),
      );
      if (((p.z + q.z) / 2 > c.z) != front) continue;
      g.canvas.drawLine(cam.p(p), cam.p(q), pen);
    }
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the bench, the pots with their plants and zones, and
  /// the seeds in front.
  void _paintBench(_Gfx g) {
    g.floor(_benchHalfX, _benchHalfZ, -_benchHalfZ, 0, _Colors.bench);
    g.poly(
      const [
        _V(-_benchHalfX, 0, _benchHalfZ),
        _V(_benchHalfX, 0, _benchHalfZ),
        _V(_benchHalfX, -_benchDepth, _benchHalfZ),
        _V(-_benchHalfX, -_benchDepth, _benchHalfZ),
      ],
      g.lit(
        _Colors.bench,
        const _V(0, 0, 1),
        const _V(0, -_benchDepth / 2, _benchHalfZ),
      ),
      edge: 0.3,
    );
    for (final pot in _Pot.values) {
      g.shadow(_V(pot.x - 0.45, 0.01, -0.45), 1.35, 1.35);
    }
    for (final z in const [_Zone.cpSeed, _Zone.mzSeed]) {
      g.shadow(
        z.seedAt + _V(-0.12, 0.01 - z.seedAt.y, -0.12),
        z.seedSize * 0.4,
        z.seedSize * 0.3,
      );
    }
    for (final pot in _Pot.values) {
      _paintPot(g, pot);
    }
    for (final z in const [_Zone.cpSeed, _Zone.mzSeed]) {
      _paintSeed(g, z);
    }
  }

  /// A terracotta pot with its soil, the plant sprite and its two zones
  /// (the rings' far halves behind, near halves in front).
  void _paintPot(_Gfx g, _Pot pot) {
    final base = _V(pot.x, 0, 0);
    final top = _V(pot.x, _potHeight, 0);
    _paintRing(g, pot.root, front: false);
    g
      ..cylinder(base, _potBottomR, _potTopR, _potHeight, _Colors.pot)
      ..disc(top, _potTopR, g.lit(_Colors.pot, _V.up, top))
      ..disc(top, _soilR, g.lit(_Colors.soil, _V.up, top));
    _paintShell(g, pot.root);
    _paintRing(g, pot.root, front: true);
    _paintRing(g, pot.leaf, front: false);
    g.sprite(pot.art, _V(pot.x, pot.spriteY, 0), pot.size);
    _paintShell(g, pot.leaf);
    _paintRing(g, pot.leaf, front: true);
  }

  /// A seed sprite on the bench inside its zone.
  void _paintSeed(_Gfx g, _Zone z) {
    _paintRing(g, z, front: false);
    g.sprite(z.seed!, z.seedAt, z.seedSize);
    _paintShell(g, z);
    _paintRing(g, z, front: true);
  }

  /// A zone's ring `TorusGeometry(radius, 0.05)` (0x10b981); it glows when
  /// the right tool hovers over it.
  void _paintRing(_Gfx g, _Zone z, {required bool front}) {
    final hover = scene.hoverZone == z;
    g.ringHalf(
      z.center,
      z.radius,
      hover ? _ringTube * 1.6 : _ringTube,
      hover ? _Colors.zoneHover : _Colors.zoneRing,
      front: front,
      glow: hover,
    );
  }

  /// A zone's see-through cylinder (0xffff00, opacity 0.1) and its top.
  void _paintShell(_Gfx g, _Zone z) {
    final base = z.center - _V(0, z.height / 2, 0);
    g
      ..cylinder(
        base,
        z.radius,
        z.radius,
        z.height,
        _Colors.zoneFill,
        shade: false,
      )
      ..disc(base + _V(0, z.height, 0), z.radius, _Colors.zoneFill);
  }

  // ---------------------------------------------------------- labels

  /// Every text sprite of the scene as a label chip (HTML `labelDict`).
  void _paintLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    if (s.scenario == 0) {
      for (final b in _Bin.values) {
        _chip(
          g,
          cam.p(b.pos + const _V(0, _binLabelY, 0)),
          _t(b.labelKey),
          _chipBig,
        );
      }
      for (final p in s.plants) {
        if (p.placed) continue;
        _chip(
          g,
          cam.p(p.pos + _V(0, p.plant.labelY * p.scale, 0)),
          _t(p.plant.nameKey),
          _chipMedium,
        );
      }
      return;
    }
    for (final pot in _Pot.values) {
      _chip(
        g,
        cam.p(_V(pot.x, pot.labelY, 0)),
        _t(pot.nameKey),
        _chipBig,
        align: _above,
      );
    }
    for (final z in _Zone.values) {
      _chip(g, cam.p(z.labelAt), _t(z.labelKey), _chipSmall, light: true);
    }
  }

  /// HTML `createTextSprite`: a rounded chip with an emerald border (dark
  /// with white text, or [light]: white with emerald text) on [at], kept
  /// inside the visible canvas while it is partly in view.
  void _chip(
    _Gfx g,
    Offset at,
    String text,
    double factor, {
    bool light = false,
    (double, double) align = _centre,
  }) {
    final color = light ? _Colors.zoneChipText : _Colors.chipText;
    final size = cache.chipSize(text, factor, color);
    var rect = (at + _chipOffset(size, align)) & size;
    final s = scene;
    if (rect.right > s.labelLeft && rect.left < s.labelRight) {
      if (rect.right > s.labelRight) {
        rect = rect.shift(Offset(s.labelRight - rect.right, 0));
      }
      if (rect.left < s.labelLeft) {
        rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
      }
    }
    final k = cache.labelSize * factor;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(k * 0.45));
    g.canvas.drawRRect(
      rr,
      _pens.fill..color = light ? _Colors.zoneChipBg : _Colors.chipBg,
    );
    g.canvas.drawRRect(
      rr,
      _pens.edge
        ..strokeWidth = 1.2
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text, factor, color);
    tp.paint(
      g.canvas,
      Offset(rect.center.dx - tp.width / 2, rect.top + _chipPadY * k),
    );
  }

  /// HTML `confetti(...)` with the summary.
  void _paintConfetti(Canvas canvas) {
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
      canvas.save();
      canvas.translate(
        _confettiOrigin.dx + math.cos(c.angle) * d,
        _confettiOrigin.dy + math.sin(c.angle) * d + fall,
      );
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        _pens.fill..color = c.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
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
