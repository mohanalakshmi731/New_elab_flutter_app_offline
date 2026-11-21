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

/// Class 6 Science • Chapter 11 • Activity 2
/// Water: Sources, Conservation and Pollution ("Water: A Precious
/// Treasure").
///
/// Native Flutter port of
/// `Cl6S-Ch11-A2-Water__Sources__Conservation__and_Pollution.html`
/// (Three.js r128 + Tween.js). The Three.js scenes are redrawn in 2D by
/// [_ScenePainter] through the HTML camera (45° field of view, at
/// (0, 16, 25) looking at (0, 3, 0)); the HTML pointer handlers become a
/// pan recogniser that acts on touch-down like the HTML `pointerdown`.
///
/// Scenario 1 (The Leaky Tap and the Wise Bucket): a boy stands in a
/// bathroom with a white porcelain sink and a glass Main Water Tank. Tapping
/// him starts brushing his teeth under a tap left running for 6 s: the tank
/// level drops fast and a comparison card shows the waste (~15 L). The
/// water bucket, dragged under the sink tap (or fetched by tapping him), is
/// filled once and the tap closes; he brushes from the bucket (~1 L). Then
/// he washes clothes in the sink under a running tap for 6 s, and finally
/// in the washing basin filled once, before the summary opens.
///
/// Scenario 2 (The River's Story: From Clean to Clogged): a freshwater river
/// between grassy banks with trees, reeds and swimming fish. Tapping the
/// river starts the story; the open trash basket dragged into the river (or
/// tapped) tips over and spills plastic; the red valve on the industrial
/// outfall pipe releases dark effluent that turns the river murky and the
/// fish float belly up. The trash basket dragged to the Recycling Bin and
/// the pipe dragged to the Water Treatment Plant sign clear the water and
/// the fish recover; the summary opens with confetti.
class Ch11A2WaterSourcesConservationAndPollutionPage extends StatefulWidget {
  const Ch11A2WaterSourcesConservationAndPollutionPage({super.key});

  @override
  State<Ch11A2WaterSourcesConservationAndPollutionPage> createState() =>
      _WaterTreasureLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises three tones with the Web Audio API; they map to the closest
/// files: 'click' (buttons, a picked-up or snapped object, the valve, an
/// item sorted) → click (`science/click.mp3`), 'water' (a tap turned on) →
/// water (`science/dropdown.mp3`, a short whoosh), 'ding' (a container
/// filled, the river tapped, the river restored) → correct
/// (`math/success.mp3`) and, with the summary, success (`math/success.mp3`).
/// The shell plays toggle (`science/dropdown.mp3`), wrong
/// (`science/error.mp3`, unused here: the HTML has no error feedback),
/// scenario (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML 'click'.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML 'ding' during a scenario.
  correct('audio/class6/math/success.mp3'),

  /// The shell's error tone (no HTML equivalent).
  wrong('audio/class6/science/error.mp3'),

  /// HTML 'ding' with the summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'water': the sink tap turned on.
  water('audio/class6/science/dropdown.mp3');

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

/// Colours of the HTML page (Tailwind classes) and of its Three.js
/// materials.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color slate50 = Color(0xFFF8FAFC);
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
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky950 = Color(0xFF082F49);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// `woodMat` 0x8b5a2b: the bathroom floor, tree trunks, cattail heads.
  static const Color wood = Color(0xFF8B5A2B);

  /// `metalMat` 0x94a3b8: tank base and rings, tap, bucket rim, pipe.
  static const Color metal = slate400;

  /// `glassMat` white (opacity 0.2): the tank.
  static const Color glass = white;

  /// `tankBlueWaterMat` 0x0077ff (0.88) and `tankSurfaceMat` 0x33bcff (the
  /// tank meniscus, the recycling bin lid and the sign board).
  static const Color tankWater = Color(0xFF0077FF);
  static const Color tankSurface = Color(0xFF33BCFF);

  /// Sink: `sinkPedestalMat` 0xe2e8f0, `sinkBasinMat` 0xf0f9ff,
  /// `sinkInnerMat` white, `sinkWaterMat` 0x0088ff (0.92).
  static const Color sinkPedestal = slate200;
  static const Color sinkBasin = sky50;
  static const Color sinkInner = white;
  static const Color sinkWater = Color(0xFF0088FF);

  /// `clearStreamMat` 0x00c3ff (0.85) and the stream core 0xe0f8ff (0.95).
  static const Color stream = Color(0xFF00C3FF);
  static const Color streamCore = Color(0xFFE0F8FF);

  /// `waterMat` 0x38bdf8 (0.35): water in the bucket and the basin.
  static const Color vesselWater = sky400;

  /// The boy: `skinMat` 0xfcb08f, `shirtMat` 0xef4444, `pantMat` 0x2563eb,
  /// `hairMat` 0x5c3a21, `shoeMat` 0xdc2626, eyes white, pupils black.
  static const Color skin = Color(0xFFFCB08F);
  static const Color shirt = red500;
  static const Color pants = Color(0xFF2563EB);
  static const Color hair = Color(0xFF5C3A21);
  static const Color shoe = Color(0xFFDC2626);

  /// Toothbrush `toothMat` 0xf1f5f9 with `bristleMat` 0x0ea5e9 bristles.
  static const Color toothbrush = slate100;
  static const Color bristles = sky500;

  /// `clothesMat` 0xfacc15.
  static const Color clothes = Color(0xFFFACC15);

  /// `bucketMat` 0x0284c7 and `basinMat` 0x0ea5e9.
  static const Color bucket = sky600;
  static const Color basin = sky500;

  /// `glowMat` 0x38bdf8 and `glowGreenMat` 0x22c55e (opacity 0.35): drop
  /// zones, the recycling icon and the sign's dock ring.
  static const Color glow = sky400;
  static const Color glowGreen = Color(0xFF22C55E);

  /// River: `riverBedMat` 0x5e4831, `bankGrassMat` 0x22c55e, `earthMat`
  /// 0x78533b, `reedMat` 0x3a5a20.
  static const Color riverBed = Color(0xFF5E4831);
  static const Color grass = Color(0xFF22C55E);
  static const Color earth = Color(0xFF78533B);
  static const Color reed = Color(0xFF3A5A20);

  /// `crystalWaterMat` 0x00d8ff (0.55) and `waterCausticMat` 0xcfefff
  /// (0.3).
  static const Color crystalWater = Color(0xFF00D8FF);
  static const Color caustic = Color(0xFFCFEFFF);

  /// `murkyMat` 0x2e3b23 (0.92): the polluted river and the effluent.
  static const Color murky = Color(0xFF2E3B23);

  /// `toxicBubblesMat` 0xa3e635 (0.75).
  static const Color toxicBubble = Color(0xFFA3E635);

  /// Trees: `treeDarkMat` 0x14532d, `treeMidMat` 0x15803d, `treeLightMat`
  /// 0x22c55e.
  static const Color treeDark = Color(0xFF14532D);
  static const Color treeMid = Color(0xFF15803D);
  static const Color treeLight = Color(0xFF22C55E);

  /// `basketMat` 0x475569 (0.6): the open trash basket.
  static const Color basket = slate600;

  /// Plastic: `bottlePlasticMat` 0x7dd3fc, `canRedMat` 0xdc2626,
  /// `canBlueMat` 0x2563eb, `wrapperYellowMat` 0xfacc15, `cartonBlueMat`
  /// 0x38bdf8.
  static const Color bottle = sky300;
  static const Color canRed = Color(0xFFDC2626);
  static const Color canBlue = Color(0xFF2563EB);
  static const Color wrapper = Color(0xFFFACC15);
  static const Color carton = sky400;

  /// Fish: `fishOrangeMat` 0xff6600, `fishBlueMat` 0x0ea5e9,
  /// `fishGoldMat` 0xfacc15 (with emissive glow), and the white stripe.
  static const Color fishOrange = Color(0xFFFF6600);
  static const Color fishBlue = sky500;
  static const Color fishGold = Color(0xFFFACC15);

  /// `redMat` 0xdc2626: the valve wheel.
  static const Color valve = Color(0xFFDC2626);

  /// `recycleDarkGreenMat` 0x064e3b and `ceramicMat` 0xf8fafc (the bin's
  /// label panel).
  static const Color recycleBin = Color(0xFF064E3B);
  static const Color ceramic = slate50;

  /// `.label-3d` chips: `glass-panel` (dark `rgba(15, 23, 42, 0.92)`, light
  /// `rgba(255, 255, 255, 0.95)`) with `border-sky-400`.
  static const Color labelDark = Color(0xEB0F172A);
  static const Color labelLight = Color(0xF2FFFFFF);

  /// Confetti (canvas-confetti's default colours).
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
/// variables). The HTML's brand colour is sky blue (Enter Lab, the sidebar
/// tab, the HUD border, the summary header).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.sky500, // text-sky-500
    onAccent: _Colors.white, // the HTML's sky buttons have white text
    primary: _Colors.sky600, // from-sky-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // completed steps dark:text-emerald-400
    popupBg: _Colors.slate900, // summary modal dark:bg-slate-900
    popupHeader: _Colors.sky950, // header bg-sky-600, dark enough for text
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950, // #shutter-screen bg-slate-950
    curtainGlow: Color(0x800C4A6E), // from-sky-900/50
    curtainText: _Colors.white,
    curtainMuted: Color(0xE67DD3FC), // subtitle text-sky-300/90
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xE60F172A), // tools panel dark:bg-slate-900/90
    buttonIcon: _Colors.sky500,
    buttonBorder: _Colors.slate800,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.sky400,
    readoutIcon: _Colors.sky500,
    labelBg: _Colors.labelDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100, // bg-slate-100
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.sky600, // text-sky-600
    onAccent: _Colors.white,
    primary: _Colors.sky600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // completed steps text-emerald-600
    popupBg: _Colors.white,
    popupHeader: _Colors.sky100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x800C4A6E),
    curtainText: _Colors.white,
    curtainMuted: Color(0xE67DD3FC),
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xE6FFFFFF), // tools panel bg-white/90
    buttonIcon: _Colors.sky600,
    buttonBorder: _Colors.slate300,
    readoutBg: _Colors.white,
    readoutBorder: _Colors.sky400,
    readoutIcon: _Colors.sky500,
    labelBg: _Colors.labelLight,
    labelText: _Colors.slate800,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar text size slider (15 px default, 12–22 px).
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
// shell-generic texts (Enter Lab, Select Scenario, Current Objective, the
// settings and canvas-tool names) come from the shell's
// `kLabCommonStrings`. `sN_step_M` are the HTML step `action` texts and
// `sN_hud_M` its `hud` lines, with CLICK → TAP ('क्लिक करें' → 'टैप
// करें'); `sN_focus_M` / `sN_obs_M` the step concept and observation;
// `sN_summary` the summary with its bold first line (up to the first "! ")
// and the rest. Keys marked "Added." are texts the HTML hard-codes in
// English in its scripts (given a Hindi translation) or new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Water: A Precious Treasure',
    'app_subtitle': "Class 6. Nature's Treasures",
    'exp_step': 'Observation Step',
    'focus': 'Focus',
    'action': 'Action',
    'result': 'Observation',
    'btn_finish': 'Complete Scenario',
    'comp_title': 'Water Usage Comparison',
    'lbl_running_tap': 'Running Tap',
    's1_btn_brush': 'Start Brushing Teeth',
    's1_btn_wash': 'Start Washing Clothes',
    's2_btn_reset': 'Reset Ecosystem',
    'lbl_tank': 'Main Water Tank (100L Cap.)',
    'lbl_sink': 'White Porcelain Sink',
    'lbl_bucket': 'Water Bucket (15L)',
    'lbl_basin': 'Washing Basin Tub (5L)',
    'lbl_river': 'Freshwater River',
    'lbl_trashcan': 'Trash Can',
    'lbl_pipe': 'Industrial Outfall',
    'lbl_recycle': 'Recycling Bin',
    'lbl_sign': 'No Pollution Area',
    'lbl_recbin': '♻️ RECYCLING BIN',
    'lbl_treatment': '🟢 WATER TREATMENT PLANT',
    'obs_complete_title_1': 'Observation Complete: Water Conserved!',
    'obs_complete_title_2': 'Observation Complete: River Protected!',
    // Scenario 1 (HTML `ScenariosData.en[1]`).
    'scen_1_opt': 'Scenario 1: The Leaky Tap and the Wise Bucket',
    's1_desc':
        'To visually understand and compare water consumption during daily activities and learn effective household conservation methods.',
    's1_hud_1':
        'Step 1: TAP the character to start brushing teeth with the tap continuously running for 6s. Observe the rapid drop in the water tank.',
    's1_hud_2':
        'Step 2: DRAG the bucket under the sink tap (or tap character). Then TAP the character: the tap fills the bucket and turns off, saving water!',
    's1_hud_3':
        'Step 3: TAP the character to wash clothes by hand under a continuously running tap for 6s. Observe the massive water wastage.',
    's1_hud_4':
        'Step 4: DRAG the washing basin under the tap (or tap character). Then TAP the character: the tap fills the basin and turns off, saving water!',
    's1_focus_1': 'Water Wastage',
    's1_step_1':
        'TAP on the character to start brushing teeth. The tap runs continuously.',
    's1_obs_1':
        'The character brushes while the water level in the tank decreases rapidly as the tap runs for 6 seconds.',
    's1_focus_2': 'Water Conservation',
    's1_step_2':
        'DRAG bucket under sink, TAP character. Tap fills bucket briefly, then turns off.',
    's1_obs_2':
        'The character brushes teeth using water from the bucket. The main tank water level drops only slightly (~1 Liter vs ~15 Liters)!',
    's1_focus_3': 'Water Wastage',
    's1_step_3':
        'TAP character to wash clothes under a running tap for 6 seconds.',
    's1_obs_3':
        'The character vigorously scrubs clothes while continuous water pours down the drain, depleting the tank rapidly.',
    's1_focus_4': 'Water Conservation',
    's1_step_4':
        'DRAG basin under tap, TAP character. Tap fills basin briefly, then turns off.',
    's1_obs_4':
        'The character washes clothes in the filled basin. Filling the basin uses a fraction of the water compared to a running tap!',
    's1_summary':
        '💧 Scenario 1 Conserved & Mastered! '
        'Using water from a bucket or basin instead of a running tap saves over 90% of household water every single day (~14L saved per wash!). Small daily habits make a massive impact.',
    // Scenario 2 (HTML `ScenariosData.en[2]`).
    'scen_2_opt': "Scenario 2: The River's Story: From Clean to Clogged",
    's2_desc':
        'To explore a natural freshwater ecosystem, observe how plastic waste and industrial chemical discharge pollute rivers, and practice proper waste sorting.',
    's2_hud_1':
        'Step 1: Observe the crystal clear water, lush grassy banks, and swimming 3D fish. TAP anywhere on the river or fish to investigate.',
    's2_hud_2':
        'Step 2: DRAG the Trash Basket (full of plastic items) and DROP it into the river (or tap it). Observe the plastic spill and aquatic distress.',
    's2_hud_3':
        'Step 3: TAP the red valve on the industrial outfall pipe to release chemical effluents into the river and observe the toxic change.',
    's2_hud_4':
        "Step 4: Restore & Protect: DRAG the Trash Basket to the green Recycling Bin and DRAG the Industrial Pipe to the 'No Pollution' treatment sign!",
    's2_focus_1': 'Healthy Natural Ecosystem',
    's2_step_1':
        'Observe the clear glistening water, sloped grassy riverbanks, and active swimming fish. TAP the river to continue.',
    's2_obs_1':
        'The freshwater ecosystem is balanced and thriving with crystal clear water and healthy aquatic biodiversity.',
    's2_focus_2': 'Plastic Spill Pollution',
    's2_step_2': 'DRAG the open Trash Basket into the river (or tap it).',
    's2_obs_2':
        'The basket tips over, spilling plastic bottles, cans, and wrappers into the river. The water clogs and fish struggle.',
    's2_focus_3': 'Industrial Chemical Dumping',
    's2_step_3': 'TAP the red valve on the industrial outfall pipe.',
    's2_obs_3':
        'Dark chemical waste pours into the river, turning the crystal water murky and toxic. All aquatic life stops swimming.',
    's2_focus_4': 'Restoration & Conservation',
    's2_step_4':
        'Sort plastic into the Recycling Bin and redirect the industrial pipe to the Water Treatment Plant sign.',
    's2_obs_4':
        'Removing plastic waste and treating industrial discharge cleans up the river immediately, restoring clear water and thriving fish!',
    's2_summary':
        '🌿 Freshwater Ecosystem Protected! '
        'Recognizing how plastic trash baskets and industrial pipelines pollute rivers empowers us to sort waste into recycling bins and enforce chemical treatment, preserving crystal clean water for all aquatic life and humanity.',
    // Added: the comparison card texts (HTML `showComparison` literals).
    'comp_desc_1':
        'Step 1 Complete: Leaving the tap running while brushing teeth wasted ~15 Liters of clean water down the drain!',
    'comp_desc_2':
        'Step 2 Complete: By filling a bucket and turning off the tap immediately, you used only ~1 Liter of water and saved ~14 Liters!',
    'comp_desc_3':
        'Step 3 Complete: Washing clothes under a continuous stream wasted ~15 Liters of water rapidly!',
    'comp_desc_4':
        'Step 4 Complete: Washing clothes in the basin used only ~1.5 Liters of water and prevented massive wastage!',
    'btn_view_final': 'View Final Observation & Next Scenario',
    // Added: the summary card heading and the Scenario 1 note (HTML
    // `triggerMainAction` literals).
    'final_obs': 'Final Observation & Conclusion',
    'next_sc_msg':
        "Please tap on 'Select Scenario' from the sidebar to start Scenario 2!",
    // Added: the timer badge, the boy's screen-reader name and the scene
    // descriptions.
    'timer_s': '{n}s',
    'sem_character': 'Character',
    'scene_s1':
        'A bathroom with a boy, a white porcelain sink with a tap, a glass main water tank and a water bucket',
    'scene_s2':
        'A freshwater river between grassy banks with trees, reeds and fish, an open trash basket full of plastic and an industrial outfall pipe with a red valve',
  },
  'hi': {
    'app_title': 'जल: एक अनमोल खजाना',
    'app_subtitle': 'कक्षा 6. प्रकृति का खजाना',
    'exp_step': 'अवलोकन चरण',
    'focus': 'मुख्य बिंदु',
    'action': 'क्या करें',
    'result': 'क्या हुआ',
    'btn_finish': 'परिदृश्य पूर्ण करें',
    'comp_title': 'जल उपयोग की तुलना',
    'lbl_running_tap': 'बहता नल',
    's1_btn_brush': 'ब्रश करना शुरू करें',
    's1_btn_wash': 'कपड़े धोना शुरू करें',
    's2_btn_reset': 'पारिस्थितिकी तंत्र रीसेट करें',
    'lbl_tank': 'मुख्य पानी की टंकी (100L)',
    'lbl_sink': 'सफेद चीनी मिट्टी सिंक',
    'lbl_bucket': 'पानी की बाल्टी (15L)',
    'lbl_basin': 'कपड़े धोने का टब (5L)',
    'lbl_river': 'मीठे पानी की नदी',
    'lbl_trashcan': 'कचरे का डिब्बा',
    'lbl_pipe': 'औद्योगिक पाइप',
    'lbl_recycle': 'रीसाइक्लिंग बिन',
    'lbl_sign': 'प्रदूषण निषिद्ध क्षेत्र',
    'lbl_recbin': '♻️ रीसाइक्लिंग बिन',
    'lbl_treatment': '🟢 जल उपचार संयंत्र',
    // Added: the HTML has no Hindi summary titles.
    'obs_complete_title_1': 'अवलोकन पूर्ण: जल संरक्षित!',
    'obs_complete_title_2': 'अवलोकन पूर्ण: नदी सुरक्षित!',
    'scen_1_opt': 'परिदृश्य 1: टपकता नल और समझदार बाल्टी',
    's1_desc':
        'दैनिक गतिविधियों के दौरान पानी की खपत को समझना और प्रभावी घरेलू संरक्षण के तरीके सीखना।',
    's1_hud_1':
        'चरण 1: बहते नल के साथ 6 सेकंड तक ब्रश करने के लिए पात्र पर टैप करें। पानी की टंकी में तेजी से गिरावट देखें।',
    's1_hud_2':
        'चरण 2: बाल्टी को सिंक के नीचे खींचें (या पात्र पर टैप करें)। फिर पात्र पर टैप करें: नल बाल्टी भरेगा और बंद हो जाएगा, जिससे पानी बचेगा!',
    's1_hud_3':
        'चरण 3: लगातार बहते नल के नीचे 6 सेकंड तक कपड़े धोने के लिए पात्र पर टैप करें। भारी पानी की बर्बादी देखें।',
    's1_hud_4':
        'चरण 4: टब (बेसिन) को नल के नीचे खींचें (या पात्र पर टैप करें)। फिर पात्र पर टैप करें: नल टब भरेगा और बंद हो जाएगा, जिससे पानी बचेगा!',
    's1_focus_1': 'पानी की बर्बादी',
    's1_step_1': 'ब्रश करने के लिए पात्र पर टैप करें। नल लगातार चलता है।',
    's1_obs_1':
        'पात्र ब्रश करता है और 6 सेकंड तक नल चलने से टंकी में पानी का स्तर तेजी से घटता है।',
    's1_focus_2': 'जल संरक्षण',
    's1_step_2':
        'बाल्टी को सिंक के नीचे खींचें, पात्र पर टैप करें। नल बाल्टी भरकर बंद हो जाता है।',
    's1_obs_2':
        'पात्र बाल्टी के पानी से ब्रश करता है। बहते नल की तुलना में टंकी का पानी बहुत कम घटता है (~1 लीटर बनाम ~15 लीटर)!',
    's1_focus_3': 'पानी की बर्बादी',
    's1_step_3':
        'बहते नल के नीचे 6 सेकंड तक कपड़े धोने के लिए पात्र पर टैप करें।',
    's1_obs_3':
        'पात्र कपड़े धोता है जबकि पानी लगातार बहकर बर्बाद होता है, जिससे टंकी तेजी से खाली होती है।',
    's1_focus_4': 'जल संरक्षण',
    's1_step_4':
        'टब को नल के नीचे खींचें, पात्र पर टैप करें। नल टब भरकर बंद हो जाता है।',
    's1_obs_4':
        'पात्र भरे हुए टब में कपड़े धोता है। बहते नल की तुलना में टब भरने में बहुत कम पानी लगता है!',
    's1_summary':
        '💧 जल संरक्षित और परिदृश्य पूर्ण! '
        'बहते नल की बजाय बाल्टी या टब से पानी का उपयोग करने से हर दिन 90% से अधिक पानी बचता है! दैनिक आदतों में छोटा बदलाव बड़ा प्रभाव लाता है।',
    'scen_2_opt': 'परिदृश्य 2: नदी की कहानी: स्वच्छ से प्रदूषित तक',
    's2_desc':
        'प्राकृतिक ताजे पानी के पारिस्थितिकी तंत्र का पता लगाना, प्लास्टिक और औद्योगिक रसायनों द्वारा प्रदूषण को समझना और सही निपटान का अभ्यास करना।',
    's2_hud_1':
        'चरण 1: पारदर्शी जल, हरी घास के तटों और तैरती मछलियों को देखें। आगे बढ़ने के लिए नदी या मछली पर टैप करें।',
    's2_hud_2':
        'चरण 2: कचरे से भरी टोकरी (बास्केट) को नदी में खींचें (या टैप करें)। कचरा बिखरने और जलीय जीवन पर प्रभाव देखें।',
    's2_hud_3':
        'चरण 3: नदी में रसायन छोड़ने के लिए औद्योगिक पाइप के लाल वाल्व पर टैप करें और पानी का गंदा होना देखें।',
    's2_hud_4':
        "चरण 4: सुधार और सुरक्षा: कचरे की टोकरी को रीसाइक्लिंग बिन में और औद्योगिक पाइप को 'प्रदूषण निषिद्ध' साइन पर खींचें!",
    's2_focus_1': 'स्वस्थ प्राकृतिक पारिस्थितिकी तंत्र',
    's2_step_1':
        'स्वच्छ चमकते पानी, हरे घास के किनारों और तैरती मछलियों को देखें। आगे बढ़ने के लिए नदी पर टैप करें।',
    's2_obs_1':
        'पारिस्थितिकी तंत्र संतुलित और फल-फूल रहा है, जिसमें स्वच्छ पानी और जलीय जीव सुरक्षित हैं।',
    's2_focus_2': 'प्लास्टिक कचरा प्रदूषण',
    's2_step_2': 'कचरे की खुली टोकरी को नदी में खींचें (या टैप करें)।',
    's2_obs_2':
        'टोकरी पलट जाती है, जिससे प्लास्टिक की बोतलें और डिब्बे नदी में गिर जाते हैं। पानी गंदा हो जाता है और मछलियां संघर्ष करती हैं।',
    's2_focus_3': 'औद्योगिक रसायन प्रदूषण',
    's2_step_3': 'औद्योगिक पाइप के लाल वाल्व पर टैप करें।',
    's2_obs_3':
        'काला रासायनिक कचरा नदी में बहता है, जिससे साफ पानी गंदा और जहरीला हो जाता है। सभी मछलियां तैरना बंद कर देती हैं।',
    's2_focus_4': 'पुनरुद्धार और जल संरक्षण',
    's2_step_4':
        'प्लास्टिक को रीसाइक्लिंग बिन में डालें और औद्योगिक पाइप को वाटर ट्रीटमेंट प्लांट साइन से जोड़ें।',
    's2_obs_4':
        'प्लास्टिक कचरा हटाने और रसायनों को साफ करने से नदी तुरंत स्वच्छ हो जाती है, जिससे मछलियां फिर से खुश और स्वस्थ हो जाती हैं!',
    's2_summary':
        '🌿 पारिस्थितिकी तंत्र सुरक्षित! '
        'यह पहचानना कि प्लास्टिक और रसायन नदियों को कैसे प्रदूषित करते हैं, हमें रीसाइक्लिंग और जल उपचार के प्रति जिम्मेदार बनाता है, जिससे सभी जीवों के लिए स्वच्छ पानी सुनिश्चित होता है।',
    // Added.
    'comp_desc_1':
        'चरण 1 पूर्ण: ब्रश करते समय नल चलता छोड़ने से ~15 लीटर साफ़ पानी नाली में बर्बाद हो गया!',
    'comp_desc_2':
        'चरण 2 पूर्ण: बाल्टी भरकर तुरंत नल बंद करने से आपने केवल ~1 लीटर पानी इस्तेमाल किया और ~14 लीटर पानी बचाया!',
    'comp_desc_3':
        'चरण 3 पूर्ण: लगातार बहते पानी के नीचे कपड़े धोने से ~15 लीटर पानी तेज़ी से बर्बाद हो गया!',
    'comp_desc_4':
        'चरण 4 पूर्ण: टब में कपड़े धोने में केवल ~1.5 लीटर पानी लगा और भारी बर्बादी रुक गई!',
    'btn_view_final': 'अंतिम अवलोकन और अगला परिदृश्य देखें',
    'final_obs': 'अंतिम अवलोकन और निष्कर्ष',
    'next_sc_msg':
        "परिदृश्य 2 शुरू करने के लिए कृपया साइडबार में 'परिदृश्य चुनें' पर टैप करें!",
    'timer_s': '{n}s',
    'sem_character': 'पात्र',
    'scene_s1':
        'एक बाथरूम जिसमें एक लड़का, नल वाला सफेद चीनी मिट्टी का सिंक, कांच की मुख्य पानी की टंकी और पानी की बाल्टी है',
    'scene_s2':
        'घास वाले किनारों, पेड़ों, सरकंडों और मछलियों वाली मीठे पानी की नदी, प्लास्टिक से भरी खुली कचरे की टोकरी और लाल वाल्व वाला औद्योगिक पाइप',
  },
};

/// Number of scenarios and of steps in each (the HTML `steps` arrays).
const int _scenarioCount = 2;
const int _stepCount = 4;

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.result,
  });

  final String focus;
  final String action;
  final String result;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCount; i++)
      _StepInfo(
        focus: t('s${n}_focus_$i'),
        action: t('s${n}_step_$i'),
        result: t('s${n}_obs_$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table (HTML
/// `ScenariosData`).
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

/// Splits an HTML summary into its bold first line (up to and including
/// the first "!") and the paragraph after it.
(String, String) _splitSummary(String text) {
  final cut = text.indexOf('! ');
  if (cut < 0) return ('', text);
  return (text.substring(0, cut + 1), text.substring(cut + 2));
}

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target for scene objects (logical px).
const double _minTouch = 48;

/// Short drags must move objects: 8 px touch slop instead of 18 px (a
/// RawGestureDetector does not take MediaQuery's gesture settings).
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

/// Longest frame step fed to the per-frame motion (s).
const double _maxFrameStep = 0.05;

/// Canvas label text (design px; HTML `text-[10px]` at a slightly larger
/// canvas), enlarged up to 1.8× when the stage is scaled down.
const double _labelPx = 11;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// HTML `animate()` clock: `Date.now() * 0.005`, 5 units a second.
const double _htmlClock = 5;

/// Dragged objects stay over the floor / the diorama.
const double _dragHalfX = 17, _dragBackZ = -9, _dragFrontZ = 9;

// --------------------------------------------------------------- scenario 1
// HTML buildScenario1Scene().

/// Tank water: `State.baseWaterLevel` 8 in the 12-high tank; never below
/// 0.1.
const double _baseLevel = 8;
const double _minLevel = 0.1;

/// Glass tank group at (10, 0, -5): glass r 4 × 12, metal base r 4.2 ×
/// 0.5, water r 3.8 with its meniscus r 3.78, ten level rings r 4.01 every
/// 1.1 and five step lines r 4.03.
const _V _tankPos = _V(10, 0, -5);
const double _tankR = 4, _tankH = 12, _tankBaseR = 4.2, _tankBaseH = 0.5;
const double _tankWaterR = 3.8, _meniscusR = 3.78;
const double _ringR = 4.01, _ringTube = 0.02, _ringGap = 1.1;
const double _lineR = 4.03, _lineTube = 0.05;
const List<double> _stepLines = [11.0, 7.5, 6.7, 3.2, 2.2];

/// Sink group at (-1.5, 0, -1): its bowl top is at 6.55 and its water
/// (0.75 high) rests at 6.05, bobbing up to 6.18 while the tap runs.
const _V _sinkPos = _V(-1.5, 0, -1);
const double _bowlTop = 6.55;
const double _sinkWaterRest = 6.05, _sinkWaterHigh = 6.18;
const double _sinkWaterHalfH = 0.375;

/// The tap's spout opens at 8.1 (tap at 6.5, spout 1.9 ± 0.3); the stream
/// (`waterStream` at 0.6 below the tap's top, 4.8 long) spans 3.5–8.3.
const double _spoutY = 8.1;

/// The sink's label floats just above the tap (HTML: 8, on the spout).
const double _sinkLabelY = 9.6;
const double _streamTop = 8.3, _streamBottom = 3.5;

/// The boy: at (-7.5, 0, 2.5) turned π / 4.8 for brushing (steps 1–2); at
/// (-3.8, 0, -0.8) facing the sink for washing (steps 3–4).
const _V _charBrushPos = _V(-7.5, 0, 2.5);
const double _charBrushYaw = math.pi / 4.8;
const _V _charWashPos = _V(-3.8, 0, -0.8);
const double _charWashYaw = math.pi / 2;
const double _torsoY = 5.8, _headY = 8.6;

/// The right arm at steps 1–2 (upper arm, then forearm). The HTML's
/// angles ((-1.89, -1.10, -1.50), (1.75, -0.30, 0.40)) leave the hand at
/// waist height although its comment says the hand and brush are "locked
/// directly beside face/mouth (y = 8.34)"; these put the elbow forward at
/// shoulder height and the bristles at the mouth. The HTML's ±0.15 swing of
/// the forearm's z turn then brushes round the mouth.
const _V _brushArm = _V(-0.19, -1.533, 1.394);
const _V _brushForearm = _V(-2.095, 0, 1.329);

/// The toothbrush in the right hand.
const _V _brushPos = _V(-0.15, 0.1, 0.1);
const _V _brushRot = _V(-0.3, 0, 1.57);

/// Bucket at (5, 0, 5) and basin at (8, 0, 5); in the sink at y 4.8 / 4.5.
const _V _bucketHome = _V(5, 0, 5);
const _V _bucketAtSink = _V(-1.5, 4.8, -1);
const _V _basinHome = _V(8, 0, 5);
const _V _basinAtSink = _V(-1.5, 4.5, -1);

/// Water `scale.y` of an empty container.
const double _fillEmpty = 0.05;

/// HTML `checkDrop()`: let go within 4.5 of the sink (or within 0.5 of
/// home: a tap) a container snaps into the sink; a tap on the boy fetches
/// it when it is more than 3.5 away.
const double _sinkReach = 4.5, _tapReach = 0.5, _fetchReach = 3.5;

/// Timings (s): running tap 6, filling 1.5, using the container 5, snaps
/// 0.4. Tank level drops: 3.5 (running tap), 0.8 (bucket), 1.0 (basin).
const int _runSeconds = 6, _useSeconds = 5;
const double _fillSeconds = 1.5, _snapSeconds = 0.4;
const double _wasteDrop = 3.5, _bucketDrop = 0.8, _basinDrop = 1.0;

/// Comparison card: it closes itself after 2.6 s (4 s at step 4); its
/// progress bar starts after 50 ms and fills in 2.4 s (3.8 s); it scales
/// out in 300 ms.
const double _compShort = 2.6, _compLong = 4;
const double _compFill = 2.4, _compFillLong = 3.8;
const double _compDelay = 0.05, _compFade = 0.3;

// --------------------------------------------------------------- scenario 2
// HTML buildScenario2Scene(): the river group sits 2 below the scene.

const double _riverY = -2;

/// Banks: earth 10.5 × 3.2 × 22 under grass 10.5 × 1.2 × 22, centred at
/// x ±10.25 (grass top at 0.2); river bed 10 × 1.8 × 20.
const double _bankX = 10.25, _grassTop = 0.2;

/// Clear water 9.8 × 2.4 × 20 (top at 0.4), its shimmering surface at 0.42
/// and the murky water 9.9 × 2.48 × 20.1 (top at 0.49).
const double _surfaceY = 0.42, _murkyTop = 0.49;

/// Reeds stand at x ±4.8 along the river edges.
const double _reedX = 4.8;

/// The effluent stream at (4.8, 0.5, -5) (r 0.35 → 0.45, 4.2 high) and its
/// bubbles rising from 0.45 to 0.85.
const double _effluentX = 4.8, _effluentZ = -5;
const double _effluentTop = 2.6, _effluentBottom = -1.6;
const double _bubbleLow = 0.45, _bubbleHigh = 0.85;

/// Dead fish float at 0.2; spilled plastic bobs at 2.4.
const double _deadFishY = 0.2;
const double _spillY = 2.4;

/// Trash basket at (-7.5, 3.2, 4), tipped out at (-1, 3, 1); the outfall
/// pipe at (7.5, 3.2, -5); the recycling bin and the treatment sign of
/// step 4.
const _V _trashHome = _V(-7.5, 3.2, 4);
const _V _trashSpillAt = _V(-1, 3, 1);
const _V _pipeHome = _V(7.5, 3.2, -5);
const _V _binPos = _V(-8.5, 0, -5);
const _V _signPos = _V(8.5, 0, 5);

/// HTML `checkDrop()`: the basket spills when let go within 8 of the river
/// centre or 6 of its axis (or within 1.5 of home: a tap); in step 4 the
/// basket and the pipe are sorted within 6.5 of the bin / sign (or 1.8 of
/// home).
const double _spillRadius = 8, _spillHalfX = 6, _spillTapReach = 1.5;
const double _sortReach = 6.5, _sortTapReach = 1.8;

/// Seven trees along the banks (HTML `treePositions`), scaled 0.85, 1.07
/// and 1.29 in turn.
const List<_V> _trees = [
  _V(-11, _grassTop, -6),
  _V(-12.5, _grassTop, 3),
  _V(-10.5, _grassTop, 7),
  _V(11.5, _grassTop, -5),
  _V(12.5, _grassTop, 5),
  _V(-13, _grassTop, -1.5),
  _V(13.2, _grassTop, 1.5),
];

/// The fish colours, in turn (orange, blue, gold).
const List<Color> _fishColors = [
  _Colors.fishOrange,
  _Colors.fishBlue,
  _Colors.fishGold,
];

/// HTML `spillGeoms`: (box?, size, colour, opacity); a cylinder's size is
/// (radius, height, radius).
const List<(bool, _V, Color, double)> _spillShapes = [
  (false, _V(0.22, 0.85, 0.22), _Colors.bottle, 0.7),
  (false, _V(0.25, 0.6, 0.25), _Colors.canRed, 1),
  (false, _V(0.25, 0.6, 0.25), _Colors.canBlue, 1),
  (true, _V(0.6, 0.4, 0.4), _Colors.wrapper, 1),
  (true, _V(0.5, 0.7, 0.5), _Colors.carton, 1),
  (false, _V(0.2, 0.8, 0.2), _Colors.bottle, 0.7),
];

/// Pan recogniser that only claims pointers that start on a draggable
/// object (decided by [canGrab], which also runs the HTML `pointerdown`
/// taps), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _WaterTreasureLabState
    extends State<Ch11A2WaterSourcesConservationAndPollutionPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _TextCache _texts = _TextCache();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for touch-sized hit areas.
  double _fit = 1;

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
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  /// HTML `animate()`: TWEEN.update(), the timeouts and countdown, the
  /// per-frame motion, then one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.update();
    s.animate(dt);
    _frame.value = now;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // -------------------------------------------------------------- scenario

  /// HTML `changeScenario()` / `resetScenarioState()`: rebuilds the scene
  /// of scenario [index] at step 1 and resets the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `advanceStep()`: the next step, or the summary after step 4.
  void _advance() {
    final s = _scene;
    s.step++;
    if (s.finished) {
      if (s.scenario == 1) s.launchConfetti();
      _showSummary();
    } else {
      s.applyStep();
    }
    _refresh();
  }

  /// HTML `triggerMainAction()`: the summary popup (title, "Final
  /// Observation & Conclusion", the summary and, after Scenario 1, the
  /// note to open Scenario 2). The shell's standard close: 'Continue', or
  /// 'Restart Lab' once both scenarios are done.
  void _showSummary() {
    final sc = _scene.scenario;
    _lab.completedScenarios.add(sc);
    final allDone =
        sc >= _scenarioCount - 1 ||
        _lab.completedScenarios.length >= _scenarioCount;
    _lab.openSidebar();
    _lab.showPopup(() {
      final (head, body) = _splitSummary(_t('s${sc + 1}_summary'));
      final p = _lab.palette;
      return LabPopupContent(
        title: _t('obs_complete_title_${sc + 1}'),
        heading: _t('final_obs'),
        icon: Icons.check_circle,
        accent: sc == 0 ? _Colors.sky500 : _Colors.emerald500,
        extra: Builder(
          builder: (context) => _SummaryCard(
            head: head,
            body: body,
            accent: sc == 0 ? _Colors.sky400 : _Colors.emerald400,
            note: sc == 0 && !_lab.completedScenarios.contains(1)
                ? _t('next_sc_msg')
                : null,
            palette: p,
            scale: context.labScale,
            fontScale: _lab.fontScale,
          ),
        ),
        actions: [
          if (allDone)
            LabAction(
              label: _lab.t('btn_restart'),
              icon: Icons.restart_alt,
              onTap: _lab.requestFullReset,
            )
          else
            LabAction(
              label: _lab.t('btn_continue'),
              icon: Icons.arrow_forward,
              color: p.primary,
              foreground: p.onPrimary,
              onTap: () {
                _lab.hidePopup(sound: false);
                _lab.showToast(_lab.t('msg_scenario_complete'));
              },
            ),
        ],
      );
    });
  }

  // ------------------------------------------------------------ scenario 1

  /// HTML `handleCharacterClick()`: what the boy does at this step. Ignored
  /// while the tap runs, he is busy or the comparison card is up.
  void _characterTap() {
    final s = _scene;
    if (!_lab.isLabActive ||
        s.scenario != 0 ||
        s.finished ||
        s.busy ||
        s.tapOn ||
        s.brushing ||
        s.washing ||
        s.comparison != null ||
        s.bucket.moving ||
        s.basin.moving) {
      return;
    }
    switch (s.step) {
      case 1:
        _runningTap(brushing: true);
      case 2:
        _fillAndUse(s.bucket, drop: _bucketDrop, brushing: true);
      case 3:
        _runningTap(brushing: false);
      default:
        _fillAndUse(s.basin, drop: _basinDrop, brushing: false);
    }
  }

  /// Steps 1 and 3: brushing or washing under a tap left running for 6 s;
  /// the tank drops 3.5 over the countdown, then the comparison card.
  void _runningTap({required bool brushing}) {
    final s = _scene;
    s
      ..brushing = brushing
      ..washing = !brushing
      ..tapOn = true
      ..sinkBob = true
      ..sinkBobStart = s.time;
    _Sound.water.play();
    final from = s.level;
    final to = math.max(_minLevel, s.levelValue - _wasteDrop);
    s.tween(_runSeconds.toDouble(), (t) => s.level = _lerp(from, to, t));
    s.startTimer(_runSeconds, () {
      s
        ..sinkBob = false
        ..tapOn = false
        ..brushing = false
        ..washing = false
        ..levelValue = to
        ..level = to;
      _showComparison();
    });
    _refresh();
  }

  /// Steps 2 and 4: the container is fetched into the sink if needed, the
  /// tap fills it once (1.5 s, the tank drops only [drop]) and turns off;
  /// the boy then brushes or washes from it for 5 s.
  void _fillAndUse(_Vessel v, {required double drop, required bool brushing}) {
    final s = _scene;
    if (!v.atSink && _flat(v.pos, _sinkPos) > _fetchReach) {
      // HTML: "If bucket is not at sink yet, auto-move it first!"
      _Sound.click.play();
      v
        ..zone = false
        ..atSink = true;
      _moveVessel(v, v.sinkPos, then: _characterTap);
      _refresh();
      return;
    }
    v
      ..atSink = true
      ..waterShown = true;
    s.tapOn = true;
    _Sound.water.play();
    final fill = v.fill;
    s.tween(_fillSeconds, (t) => v.fill = _lerp(fill, 1, t));
    final from = s.level;
    final to = math.max(_minLevel, s.levelValue - drop);
    s.tween(
      _fillSeconds,
      (t) => s.level = _lerp(from, to, t),
      done: () {
        s
          ..tapOn = false
          ..levelValue = to;
        _Sound.correct.play();
        if (brushing) {
          s.brushing = true;
        } else {
          s.washing = true;
        }
        s.startTimer(_useSeconds, () {
          s
            ..brushing = false
            ..washing = false;
          _showComparison();
        });
        _refresh();
      },
    );
    _refresh();
  }

  /// A container glides to [to] (400 ms), then [then] runs.
  void _moveVessel(_Vessel v, _V to, {VoidCallback? then}) {
    v.moving = true;
    _scene.tweenTo(
      v.pos,
      to,
      _snapSeconds,
      (p) => v.pos = p,
      tag: v.grab,
      done: () {
        v.moving = false;
        then?.call();
        _refresh();
      },
    );
  }

  /// HTML `checkDrop()` for the bucket (step 2) and the basin (step 4):
  /// into the sink when let go near it (or tapped), otherwise back home.
  void _dropVessel(_Vessel v) {
    if (_flat(v.pos, _sinkPos) < _sinkReach ||
        _flat(v.pos, v.home) < _tapReach) {
      _Sound.click.play();
      v
        ..zone = false
        ..atSink = true;
      _moveVessel(v, v.sinkPos);
    } else {
      _moveVessel(v, v.home);
    }
    _refresh();
  }

  /// HTML `showComparison(desc, step)`: the card closes itself after 2.6 s
  /// (4 s at step 4) or when tapped, then the next step begins.
  void _showComparison() {
    final s = _scene;
    final card = _Comparison(s.step, s.time);
    s.comparison = card;
    s.cue(
      s.step < _stepCount ? _compShort : _compLong,
      () => _closeComparison(card),
    );
    _refresh();
  }

  void _closeComparison(_Comparison card) {
    final s = _scene;
    if (s.comparison != card || card.closingAt != null) return;
    card.closingAt = s.time;
    s.cue(_compFade, () {
      if (s.comparison != card) return;
      s.comparison = null;
      _advance();
    });
    _refresh();
  }

  // ------------------------------------------------------------ scenario 2

  /// Step 1: a tap on the river (anywhere on the diorama) moves on.
  void _riverTap() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 1 || s.busy) return;
    _Sound.correct.play();
    _advance();
  }

  /// HTML `checkDrop()` for the basket at step 2: let go over the river (or
  /// tapped) it tips over and spills its plastic; otherwise it goes back.
  void _dropTrashInRiver() {
    final s = _scene;
    final p = s.trashPos;
    if (math.sqrt(p.x * p.x + p.z * p.z) < _spillRadius ||
        p.x.abs() < _spillHalfX ||
        (p - _trashHome).length < _spillTapReach) {
      _spill();
    } else {
      s.tweenTo(
        p,
        _trashHome,
        _snapSeconds,
        (v) => s.trashPos = v,
        tag: _Grab.trash,
      );
    }
  }

  /// The basket moves over the river (400 ms) and tips over (500 ms after
  /// 200 ms); the plastic pours out and scatters over the water; 700 ms
  /// later the basket returns upright (500 ms) and step 3 begins.
  void _spill() {
    final s = _scene;
    _Sound.click.play();
    s.busy = true;
    s.tweenTo(
      s.trashPos,
      _trashSpillAt,
      0.4,
      (v) => s.trashPos = v,
      tag: _Grab.trash,
    );
    final tilt = s.trashTilt;
    s.tween(
      0.5,
      (t) => s.trashTilt = _lerp(tilt, math.pi / 2, t),
      delay: 0.2,
      done: () {
        s.trashInside = false;
        for (var i = 0; i < s.spill.length; i++) {
          final item = s.spill[i];
          item
            ..pos = s.trashPos
            ..visible = true;
          final to = _V(
            (s.rng.nextDouble() - 0.5) * 6,
            _spillY,
            (s.rng.nextDouble() - 0.5) * 6,
          );
          s.tweenTo(item.pos, to, 0.6, (v) => item.pos = v, delay: i * 0.1);
        }
        s.cue(0.7, () {
          s.tweenTo(
            s.trashPos,
            _trashHome,
            0.5,
            (v) => s.trashPos = v,
            tag: _Grab.trash,
          );
          final back = s.trashTilt;
          s.tween(
            0.5,
            (t) => s.trashTilt = _lerp(back, 0, t),
            done: () {
              s.busy = false;
              _advance();
            },
          );
        });
        _refresh();
      },
    );
    _refresh();
  }

  /// HTML `handleValveClick()`: the red valve turns (1 s); after 500 ms the
  /// dark effluent pours and the murky water spreads over the river (2 s);
  /// the fish turn belly up (1 s) and 2 s later step 4 begins.
  void _openValve() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || s.busy || s.valveOpened) return;
    s
      ..busy = true
      ..valveOpened = true;
    _Sound.click.play();
    final spin = s.valveSpin;
    s.tween(1, (t) => s.valveSpin = _lerp(spin, math.pi * 2, t));
    s.cue(0.5, () {
      s
        ..murky = true
        ..murkyScale = 0.1
        ..effluent = true
        ..bubblesOn = true;
      s.tween(
        2,
        (t) => s.murkyScale = _lerp(0.1, 1, t),
        done: () {
          for (final f in s.fish) {
            final roll = f.roll;
            final y = f.pos.y;
            s.tween(1, (t) {
              f
                ..roll = _lerp(roll, math.pi, t)
                ..pos = f.pos.withY(_lerp(y, _deadFishY, t));
            });
          }
          s
            ..busy = false
            ..cue(2, _advance);
          _refresh();
        },
      );
      _refresh();
    });
    _refresh();
  }

  /// HTML `checkDrop()` at step 4: the basket near the recycling bin or the
  /// pipe near the treatment sign (or either tapped) is sorted; otherwise
  /// it goes back.
  void _dropForSorting(_Grab what) {
    final s = _scene;
    final trash = what == _Grab.trash;
    final p = trash ? s.trashPos : s.pipePos;
    final target = trash ? _binPos : _signPos;
    final home = trash ? _trashHome : _pipeHome;
    if (_flat(p, target) < _sortReach ||
        (p - target).length < _sortReach ||
        (p - home).length < _sortTapReach) {
      _sort(trash: trash);
    } else if (trash) {
      s.tweenTo(p, home, _snapSeconds, (v) => s.trashPos = v, tag: what);
    } else {
      s.tweenTo(p, home, _snapSeconds, (v) => s.pipePos = v, tag: what);
    }
  }

  /// HTML `sortItemStep4()`: the basket goes into the recycling bin (its
  /// plastic leaves the river) or the pipe to the treatment sign. With both
  /// done the effluent stops, the murky water shrinks away (1.2 s), the
  /// fish swim back home (1 s) and 1.8 s later the summary opens.
  void _sort({required bool trash}) {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4) return;
    if (trash && !s.trashSorted) {
      _Sound.click.play();
      s
        ..recycleZone = false
        ..trashSorted = true
        ..trashInside = true;
      s.stop(_Grab.trash);
      s.tweenTo(
        s.trashPos,
        _binPos,
        0.4,
        (v) => s.trashPos = v,
        tag: _Grab.trash,
      );
      final tilt = s.trashTilt;
      s.tween(0.4, (t) => s.trashTilt = _lerp(tilt, 0, t));
      for (final item in s.spill) {
        item.visible = false;
      }
    } else if (!trash && !s.pipeSorted) {
      _Sound.click.play();
      s
        ..signZone = false
        ..pipeSorted = true;
      s.stop(_Grab.pipe);
      s.tweenTo(
        s.pipePos,
        _signPos,
        0.4,
        (v) => s.pipePos = v,
        tag: _Grab.pipe,
      );
    } else {
      return;
    }
    if (s.trashSorted && s.pipeSorted && !s.restoring) {
      s.restoring = true;
      _Sound.correct.play();
      s
        ..effluent = false
        ..bubblesOn = false;
      if (s.murky) {
        final m = s.murkyScale;
        s.tween(
          1.2,
          (t) => s.murkyScale = _lerp(m, 0.05, t),
          done: () => s.murky = false,
        );
      }
      for (final f in s.fish) {
        f
          ..roll = 0
          ..yaw = 0;
        s.tweenTo(f.pos, f.orig, 1, (v) => f.pos = v);
      }
      s.cue(1.8, _advance);
    }
    _refresh();
  }

  // -------------------------------------------------------------- pressing

  /// HTML `pointerdown` raycast: the nearest object whose touch box
  /// contains [p]; the river (Scenario 2) only when nothing else is hit.
  _Hit? _hitAt(Offset p) {
    _Hit? best;
    var bestDepth = double.infinity;
    _Hit? background;
    for (final (hit, rect, depth) in _targets()) {
      if (!rect.contains(p)) continue;
      if (hit == _Hit.river) {
        background = hit;
      } else if (depth < bestDepth) {
        best = hit;
        bestDepth = depth;
      }
    }
    return best ?? background;
  }

  /// Screen boxes (at least finger-sized) and depths of the objects a
  /// press can hit.
  List<(_Hit, Rect, double)> _targets() {
    final s = _scene;
    final cam = _camera;
    final out = <(_Hit, Rect, double)>[];
    void add(_Hit hit, _Xf xf, _V min, _V max) {
      var rect = cam.bounds(xf, min, max);
      final least = _minTouch / _fit;
      if (rect.width < least || rect.height < least) {
        rect = Rect.fromCenter(
          center: rect.center,
          width: math.max(rect.width, least),
          height: math.max(rect.height, least),
        );
      }
      out.add((hit, rect, cam.depth(xf.at((min + max) * 0.5))));
    }

    if (s.scenario == 0) {
      final pose = s.pose();
      add(
        _Hit.character,
        _Xf.at(pose.pos).child(_V.zero, ry: pose.yaw),
        const _V(-1.8, 0, -1.0),
        const _V(1.8, 9.8, 1.2),
      );
      add(
        _Hit.sink,
        _Xf.at(_sinkPos),
        const _V(-3.3, 0, -3.3),
        const _V(3.3, 8.95, 3.3),
      );
      add(
        _Hit.tank,
        _Xf.at(_tankPos),
        const _V(-_tankBaseR, 0, -_tankBaseR),
        const _V(_tankBaseR, _tankH, _tankBaseR),
      );
      if (s.bucket.visible) {
        add(
          _Hit.bucket,
          _Xf.at(s.bucket.pos),
          const _V(-1.55, 0, -1.55),
          const _V(1.55, 3.1, 1.55),
        );
      }
      if (s.basin.visible) {
        add(
          _Hit.basin,
          _Xf.at(s.basin.pos),
          const _V(-2.5, 0, -2.5),
          const _V(2.5, 1.5, 2.5),
        );
      }
      return out;
    }
    add(
      _Hit.river,
      const _Xf.at(_V.zero),
      const _V(-15.5, -4, -11),
      const _V(15.5, _surfaceY, 11),
    );
    add(
      _Hit.trash,
      _Xf.at(s.trashPos),
      const _V(-1.2, -1.25, -1.2),
      const _V(1.2, 1.3, 1.2),
    );
    add(
      _Hit.pipe,
      _Xf.at(s.pipePos),
      const _V(-3, -0.85, -0.85),
      const _V(3, 1.2, 0.85),
    );
    // The bin and the sign with their drop-zone rings (HTML `recycleZone`
    // / `signZone` are hit too).
    if (s.binShown) {
      final r = s.recycleZone ? 3.4 : 1.4;
      add(_Hit.bin, const _Xf.at(_binPos), _V(-r, 0, -r), _V(r, 3.85, r));
    }
    if (s.signShown) {
      final rx = s.signZone ? 3.4 : 1.7, rz = s.signZone ? 3.4 : 0.3;
      add(_Hit.sign, const _Xf.at(_signPos), _V(-rx, 0, -rz), _V(rx, 4.8, rz));
    }
    return out;
  }

  /// HTML `pointerdown` (via the pan recogniser): runs the tap actions and
  /// claims the pointer when it picks an object up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.comparison != null) return false;
    if (s.drag != null) return false;
    final hit = _hitAt(event.localPosition);
    return hit != null && _press(hit, event.localPosition);
  }

  /// A screen-reader tap on [hit] (added): the same as a press without a
  /// drag (a dragged object is let go where it is, like a tap).
  void _activate(_Hit hit) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.comparison != null) return;
    if (s.drag != null) return;
    _press(hit, null);
  }

  /// What a press on [hit] at [at] does (HTML `pointerdown` handler).
  /// Returns true when it picks an object up to drag.
  bool _press(_Hit hit, Offset? at) {
    final s = _scene;
    if (s.scenario == 0) {
      switch (hit) {
        case _Hit.character || _Hit.sink:
          _characterTap();
        case _Hit.bucket when s.step == 2:
          if (s.bucket.atSink) {
            _characterTap();
          } else if (!s.bucket.moving) {
            return _grab(_Grab.bucket, at);
          }
        case _Hit.basin when s.step == 4:
          if (s.basin.atSink) {
            _characterTap();
          } else if (!s.basin.moving) {
            return _grab(_Grab.basin, at);
          }
        default:
          break;
      }
      return false;
    }
    if (s.finished) return false;
    if (s.step == 1) {
      _riverTap();
      return false;
    }
    switch (hit) {
      case _Hit.trash when s.step == 2 || (s.step == 4 && !s.trashSorted):
        return _grab(_Grab.trash, at);
      case _Hit.pipe when s.step == 3:
        _openValve();
      case _Hit.pipe when s.step == 4 && !s.pipeSorted:
        return _grab(_Grab.pipe, at);
      case _Hit.bin when s.step == 4:
        _sort(trash: true);
      case _Hit.sign when s.step == 4:
        _sort(trash: false);
      default:
        break;
    }
    return false;
  }

  _V _grabPos(_Grab what) => switch (what) {
    _Grab.bucket => _scene.bucket.pos,
    _Grab.basin => _scene.basin.pos,
    _Grab.trash => _scene.trashPos,
    _Grab.pipe => _scene.pipePos,
  };

  void _setGrabPos(_Grab what, _V p) {
    final s = _scene;
    switch (what) {
      case _Grab.bucket:
        s.bucket.pos = p;
      case _Grab.basin:
        s.basin.pos = p;
      case _Grab.trash:
        s.trashPos = p;
      case _Grab.pipe:
        s.pipePos = p;
    }
  }

  /// HTML `startDrag()`: the object is held on the horizontal plane
  /// through it, at the offset where the finger met that plane. Without a
  /// pointer (screen reader) it is let go at once, like a tap.
  bool _grab(_Grab what, Offset? at) {
    final s = _scene;
    if (at == null) {
      _drop(what);
      return false;
    }
    final pos = _grabPos(what);
    s.stop(what);
    final hit = _camera.onPlaneY(at, pos.y);
    s.drag = _Drag(
      what,
      pos.y,
      hit == null ? _V.zero : _V(hit.x - pos.x, 0, hit.z - pos.z),
    );
    _Sound.click.play();
    return true;
  }

  /// HTML `pointermove`: the object follows the finger on its plane.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final drag = s.drag;
    if (drag == null) return;
    final hit = _camera.onPlaneY(d.localPosition, drag.planeY);
    if (hit == null) return;
    _setGrabPos(
      drag.what,
      _V(
        (hit.x - drag.offset.x).clamp(-_dragHalfX, _dragHalfX),
        math.max(0, drag.planeY),
        (hit.z - drag.offset.z).clamp(_dragBackZ, _dragFrontZ),
      ),
    );
  }

  /// HTML `pointerup`: the drop checks (a press without a move is a tap).
  void _dragEnd() {
    final s = _scene;
    final drag = s.drag;
    if (drag == null) return;
    s.drag = null;
    _drop(drag.what);
  }

  /// HTML `checkDrop()`.
  void _drop(_Grab what) {
    final s = _scene;
    switch (what) {
      case _Grab.bucket:
        if (s.step == 2) _dropVessel(s.bucket);
      case _Grab.basin:
        if (s.step == 4) _dropVessel(s.basin);
      case _Grab.trash when s.step == 2:
        _dropTrashInRiver();
      case _Grab.trash || _Grab.pipe when s.step == 4:
        _dropForSorting(what);
      default:
        break;
    }
    _refresh();
  }

  // -------------------------------------------------------------------- UI

  /// Sidebar actions: the HTML's own (unused) 'Start Brushing Teeth' /
  /// 'Start Washing Clothes' / 'Reset Ecosystem' buttons, and 'Complete
  /// Scenario' (HTML `#btn-action-main`) to reopen the summary once a
  /// scenario is done.
  List<LabAction> _actions(LabPalette p) {
    final s = _scene;
    if (s.finished) return [_finishAction(p)];
    if (s.scenario == 0) {
      final idle =
          !s.tapOn &&
          !s.brushing &&
          !s.washing &&
          s.comparison == null &&
          !s.bucket.moving &&
          !s.basin.moving;
      final brush = s.step <= 2;
      return [
        LabAction(
          label: _t(brush ? 's1_btn_brush' : 's1_btn_wash'),
          icon: brush ? Icons.brush : Icons.local_laundry_service,
          color: p.primary,
          foreground: p.onPrimary,
          enabled: idle,
          silent: true,
          onTap: _characterTap,
        ),
      ];
    }
    return [
      LabAction(
        label: _t('s2_btn_reset'),
        icon: Icons.restart_alt,
        color: p.primary,
        foreground: p.onPrimary,
        onTap: () => _loadScenario(1),
      ),
    ];
  }

  LabAction _finishAction(LabPalette p) => LabAction(
    label: _t('btn_finish'),
    icon: Icons.arrow_forward,
    color: p.primary,
    foreground: p.onPrimary,
    highlight: _lab.popup == null,
    silent: true,
    onTap: _showSummary,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final p = _lab.palette;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final scene = _scene;
        final sc = scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final popupOpen = _lab.popup != null;
        final card = scene.comparison;
        return LabShell(
          controller: _lab,
          icon: Icons.water_drop,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          hud: _t('s${sc + 1}_hud_${scene.step.clamp(1, _stepCount)}'),
          // The comparison card sits over the HUD, as in the HTML.
          showHud: card == null,
          actions: _actions(p),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('exp_step'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch11a2-steps-$sc-${scene.step}'),
            steps: _stepData,
            current: scene.step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('exp_step'),
            focusLabel: _t('focus'),
            actionLabel: _t('action'),
            resultLabel: _t('result'),
          ),
          overlays: [
            // HTML `#timer-overlay` (top right of the canvas).
            if (scene.timerStart != null)
              Positioned(
                key: const ValueKey('ch11a2-timer'),
                top: inset.top + 56 * s,
                right: inset.right,
                child: ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, _, _) => _TimerBadge(
                    text: labFormat(_t('timer_s'), {'n': scene.timerLeft}),
                    palette: p,
                    scale: s,
                  ),
                ),
              ),
            // HTML `#comparison-overlay` (centre of the canvas).
            if (card != null)
              Positioned(
                key: const ValueKey('ch11a2-comparison'),
                left: inset.left,
                right: inset.right,
                top: inset.top,
                bottom: inset.bottom,
                child: Center(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, time, _) =>
                        _comparisonCard(card, time, p, s),
                  ),
                ),
              ),
            // 'Complete Scenario' on the canvas once the scenario is done
            // and its summary closed, so it is in reach on phones too.
            if (scene.finished && !popupOpen)
              Positioned(
                key: const ValueKey('ch11a2-finish'),
                bottom: inset.bottom + (_lab.isSidebarOpen ? 66 * s : 0),
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: _finishAction(p),
                    scale: s,
                    expand: false,
                  ),
                ),
              ),
          ],
          stage: _stage(p),
        );
      },
    );
  }

  /// The comparison card for [card] at [time]: bars, text, the progress
  /// bar and, at step 4, the 'View Final Observation' button.
  Widget _comparisonCard(
    _Comparison card,
    double time,
    LabPalette p,
    double s,
  ) {
    final last = card.step >= _stepCount;
    final waste = card.step == 1 || card.step == 3;
    final fill = last ? _compFillLong : _compFill;
    final progress = ((time - card.start - _compDelay) / fill).clamp(0.0, 1.0);
    final closing = card.closingAt;
    final grow = ((time - card.start) / _compFade).clamp(0.0, 1.0);
    final shrink = closing == null
        ? 0.0
        : ((time - closing) / _compFade).clamp(0.0, 1.0);
    return _ComparisonCard(
      title: _t('comp_title'),
      wasteLabel: _t('lbl_running_tap'),
      saveLabel: waste
          ? _t('lbl_running_tap')
          : _t(card.step == 2 ? 'lbl_bucket' : 'lbl_basin'),
      saveShare: waste ? 1 : 0.2,
      saveWasted: waste,
      text: _t('comp_desc_${card.step}'),
      progress: progress,
      zoom: 0.95 + 0.05 * grow - 0.05 * shrink,
      button: last ? _t('btn_view_final') : null,
      onTap: () => _closeComparison(card),
      palette: p,
      scale: s,
    );
  }

  Widget _stage(LabPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags on the scene are not screen-reader actions; the objects
            // have their own nodes ([_semanticsNodes]).
            excludeFromSemantics: true,
            gestures: {
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..gestureSettings = _dragSettings
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onUpdate = _dragUpdate
                      ..onEnd = ((_) => _dragEnd())
                      ..onCancel = _dragEnd,
                  ),
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  image: true,
                  label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: _design,
                      painter: _ScenePainter(
                        scene: _scene,
                        texts: _texts,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        labelScale: labelScale,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, _, _) => _semanticsNodes(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Screen-reader nodes over the objects a press can hit (added), where
  /// they are drawn; they follow the objects every frame and take no
  /// touches themselves (presses reach the scene below).
  Widget _semanticsNodes() {
    if (!_lab.isLabActive) return const SizedBox.shrink();
    const stage = Rect.fromLTWH(0, 0, 1000, 560);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final (hit, rect, _) in _targets())
          Positioned.fromRect(
            rect: rect.intersect(stage),
            child: Semantics(
              key: ValueKey('ch11a2-${hit.name}'),
              container: true,
              button: hit != _Hit.tank,
              label: _t(hit.labelKey),
              onTap: hit == _Hit.tank ? null : () => _activate(hit),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ overlay cards

/// HTML `#timer-overlay`: a round glass badge with a sky border, a timer
/// icon and the seconds left.
class _TimerBadge extends StatelessWidget {
  const _TimerBadge({
    required this.text,
    required this.palette,
    required this.scale,
  });

  final String text;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return Container(
      width: 80 * s,
      height: 80 * s,
      decoration: BoxDecoration(
        color: p.panel,
        shape: BoxShape.circle,
        border: Border.all(color: _Colors.sky400, width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, size: 24 * s, color: _Colors.sky500),
          SizedBox(height: 2 * s),
          Text(
            text,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 20 * s,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML `#comparison-overlay`: "Water Usage Comparison" with a red bar for
/// the running tap and a second bar (red and full again after a running
/// tap, sky blue at 20% after the bucket or basin), the step's comparison
/// text, the auto-advance progress bar and, at step 4, the 'View Final
/// Observation & Next Scenario' button. A tap anywhere on it moves on.
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.wasteLabel,
    required this.saveLabel,
    required this.saveShare,
    required this.saveWasted,
    required this.text,
    required this.progress,
    required this.zoom,
    required this.button,
    required this.onTap,
    required this.palette,
    required this.scale,
  });

  final String title;
  final String wasteLabel;
  final String saveLabel;

  /// Height of the second bar (1 or 0.2) and whether it is red.
  final double saveShare;
  final bool saveWasted;
  final String text;
  final double progress;

  /// Card scale (HTML `scale-95` → `scale-100`).
  final double zoom;
  final String? button;
  final VoidCallback onTap;
  final LabPalette palette;
  final double scale;

  Widget _bar(double share, bool wasted, String label, double height) {
    final s = scale;
    final p = palette;
    final top = wasted ? _Colors.red400 : _Colors.sky400;
    final base = wasted ? _Colors.red500 : _Colors.sky500;
    return SizedBox(
      width: 84 * s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 48 * s,
                height: height * share,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6 * s),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(top, base, 0.35)!.withValues(alpha: 0.9),
                      base.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.isDark ? _Colors.slate300 : _Colors.slate700,
              fontSize: 11.5 * s,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final label = button;
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(384 * s, box.maxWidth * 0.9);
        // The bars give way first on short (phone) screens.
        final spare = box.maxHeight.isFinite
            ? box.maxHeight - (label == null ? 215 : 265) * s
            : 128 * s;
        final barHeight = spare.clamp(36 * s, 128 * s);
        return Transform.scale(
          scale: zoom,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: box.maxHeight),
              padding: EdgeInsets.all(20 * s),
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _Colors.sky500.withValues(alpha: 0.5),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: LabInk.shadowStrong,
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.ink(_Colors.sky500),
                        fontSize: 17 * s,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(1, true, wasteLabel, barHeight),
                        SizedBox(width: 20 * s),
                        _bar(saveShare, saveWasted, saveLabel, barHeight),
                      ],
                    ),
                    SizedBox(height: 12 * s),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.isDark ? _Colors.slate400 : _Colors.slate600,
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        height: 6 * s,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: p.isDark
                                  ? _Colors.slate800
                                  : _Colors.slate200,
                            ),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: const ColoredBox(color: _Colors.sky500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (label != null) ...[
                      SizedBox(height: 14 * s),
                      _GradientButton(label: label, onTap: onTap, scale: s),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The comparison card's step-4 button (`from-emerald-500 to-teal-500`).
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: LabInk.clear,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [_Colors.emerald500, _Colors.teal500],
          ),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowSoft,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _Sound.click.play();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Icon(Icons.arrow_forward, size: 16 * s, color: _Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HTML `#summary-body`: the conclusion card (sky for Scenario 1, emerald
/// for Scenario 2) with the summary's bold first line and its text; after
/// Scenario 1, the pulsing amber note to open Scenario 2.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.head,
    required this.body,
    required this.accent,
    required this.note,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String head;
  final String body;
  final Color accent;
  final String? note;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final text = note;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: p.isDark
                ? _Colors.slate800.withValues(alpha: 0.8)
                : _Colors.slate100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (head.isNotEmpty) ...[
                Text(
                  head,
                  style: TextStyle(
                    color: p.ink(accent),
                    fontSize: 17 * f,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8 * s),
              ],
              Text(
                body,
                style: TextStyle(
                  color: p.isDark ? _Colors.slate200 : _Colors.slate700,
                  fontSize: 13.5 * f,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (text != null) ...[
          SizedBox(height: 12 * s),
          _PulsingNote(text: text, palette: p, scale: s),
        ],
      ],
    );
  }
}

/// The amber "select Scenario 2" note (`animate-pulse`: its opacity dips
/// to half and back every 2 s).
class _PulsingNote extends StatefulWidget {
  const _PulsingNote({
    required this.text,
    required this.palette,
    required this.scale,
  });

  final String text;
  final LabPalette palette;
  final double scale;

  @override
  State<_PulsingNote> createState() => _PulsingNoteState();
}

class _PulsingNoteState extends State<_PulsingNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final s = widget.scale;
    final ink = p.isDark ? _Colors.amber300 : _Colors.amber700;
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: 0.5,
      ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
      child: Container(
        padding: EdgeInsets.all(12 * s),
        decoration: BoxDecoration(
          color: _Colors.amber500.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Colors.amber400.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18 * s,
              color: p.ink(_Colors.amber400),
            ),
            SizedBox(width: 8 * s),
            Expanded(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ink,
                  fontSize: 12.5 * s,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- steps accordion

/// HTML teacher board: one card per "Observation Step" with its focus,
/// action and observation; the current step is open, past steps are
/// ticked and any card can be toggled (HTML `toggleAccordion`).
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

  Widget _heading(String text, Color color) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 9.5 * widget.fontScale,
      fontWeight: FontWeight.w800,
      letterSpacing: labLetterSpacing(text, 0.8),
    ),
  );

  Widget _body(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 11.5 * widget.fontScale,
      fontWeight: FontWeight.w500,
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
    final open = _isOpen(i);
    final accent = p.accentInk;
    final tone = current ? accent : (past ? p.info : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    return Container(
      margin: EdgeInsets.only(bottom: 6 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: current ? p.accent.withValues(alpha: 0.1) : p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
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
                          color: current
                              ? p.accent
                              : (past
                                    ? p.success.withValues(alpha: 0.2)
                                    : p.cardBorder.withValues(alpha: 0.5)),
                          border: Border.all(
                            color: current
                                ? p.accent
                                : (past
                                      ? p.success.withValues(alpha: 0.4)
                                      : p.cardBorder),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.success)
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: current ? p.onAccent : p.textMuted,
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
          if (open)
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heading('${w.focusLabel}:', accent),
                  SizedBox(height: 3 * s),
                  _body(step.focus, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading('${w.actionLabel}:', p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading('${w.resultLabel}:', p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.result, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ===================================================================== MODEL

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
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l < 1e-12 ? this : this * (1 / l);
  }

  _V withY(double v) => _V(x, v, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Linear interpolation (TWEEN.js `Easing.Linear.None`, the HTML default).
double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Distance between two points on the floor plane (HTML `Math.hypot` of
/// the x and z differences).
double _flat(_V a, _V b) {
  final dx = a.x - b.x, dz = a.z - b.z;
  return math.sqrt(dx * dx + dz * dz);
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

/// The HTML PerspectiveCamera (45° vertical field of view) at [eye] looking
/// at the OrbitControls target, as a pinhole projection onto the design
/// stage.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.f, this.r, this.u);

  /// 280 / tan(22.5°): the 45° field of view over the 560 px stage height.
  static const double focal = 675.96;
  static const Offset center = Offset(500, 280);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w].
  Offset p(_V w) {
    final d = w - eye;
    final z = math.max(0.1, d.dot(f));
    return Offset(
      center.dx + focal * d.dot(r) / z,
      center.dy - focal * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  /// The screen offset of a small step [a] taken at [w] (the projection's
  /// derivative): how a mesh's axes look on screen.
  Offset dp(_V w, _V a) {
    final d = w - eye;
    final z = math.max(0.1, d.dot(f));
    final az = a.dot(f);
    return Offset(
      focal * (a.dot(r) * z - d.dot(r) * az) / (z * z),
      -focal * (a.dot(u) * z - d.dot(u) * az) / (z * z),
    );
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (the HTML `dragPlane`).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the box [min]–[max] in the frame [xf].
  Rect bounds(_Xf xf, _V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        xf(
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

/// The HTML camera of both scenarios (`resetCamera()`: (0, 16, 25) looking
/// at (0, 3, 0)). The camera stays locked, as in the HTML.
final _Cam _camera = _Cam(const _V(0, 16, 25), const _V(0, 3, 0));

// ------------------------------------------------------------------ tweens

/// A TWEEN.js tween with the HTML's default linear easing: [apply] gets the
/// progress (0–1) every frame from [start] for [duration] seconds, then
/// [done] runs once. [tag] names the object it moves, so a new drag can
/// stop it.
class _Anim {
  _Anim(this.start, this.duration, this.apply, this.done, this.tag);

  final double start;
  final double duration;
  final void Function(double t) apply;
  final VoidCallback? done;
  final Object? tag;

  /// Applies the tween at [now]; true once it has finished.
  bool run(double now) {
    if (now < start) return false;
    final t = duration <= 0 ? 1.0 : ((now - start) / duration).clamp(0.0, 1.0);
    apply(t);
    if (t < 1) return false;
    done?.call();
    return true;
  }
}

// ------------------------------------------------------------- scene state

/// What a press on the scene hits (the HTML raycast's top-level group).
enum _Hit {
  character('sem_character'),
  sink('lbl_sink'),
  tank('lbl_tank'),
  bucket('lbl_bucket'),
  basin('lbl_basin'),
  river('lbl_river'),
  trash('lbl_trashcan'),
  pipe('lbl_pipe'),
  bin('lbl_recycle'),
  sign('lbl_sign');

  const _Hit(this.labelKey);

  /// Key of the object's screen-reader name in [_i18n].
  final String labelKey;
}

/// The objects that can be dragged (HTML `State.activeDragTarget`).
enum _Grab { bucket, basin, trash, pipe }

/// An object being dragged on the horizontal plane through its height,
/// held at [offset] from where the finger met that plane (HTML
/// `dragPlane` / `dragOffset`).
@immutable
class _Drag {
  const _Drag(this.what, this.planeY, this.offset);

  final _Grab what;
  final double planeY;
  final _V offset;
}

/// A container of Scenario 1 (HTML `bucketS1` / `basinS1`): where it is,
/// whether it stands in the sink (`userData.atSink`), its water
/// (`scale.y` 0.05 → 1) and its glowing drop-zone ring.
class _Vessel {
  _Vessel(this.grab, this.home, this.sinkPos) : pos = home;

  final _Grab grab;
  final _V home;

  /// Where it stands in the sink (HTML snap target).
  final _V sinkPos;
  _V pos;
  bool visible = false;
  bool atSink = false;

  /// A snap or return tween is moving it.
  bool moving = false;
  bool waterShown = false;
  double fill = _fillEmpty;
  bool zone = false;

  void reset({required bool show}) {
    pos = home;
    visible = show;
    atSink = false;
    moving = false;
    waterShown = false;
    fill = _fillEmpty;
    zone = false;
  }
}

/// One plastic item of the river spill (HTML `trashSpill`): [kind] picks
/// its shape and colour from [_spillShapes].
class _Spill {
  _Spill(this.kind, this.rot);

  final int kind;
  _V pos = _V.zero;

  /// Euler rotation (the HTML random turn, drifting while it floats).
  _V rot;
  bool visible = false;
}

/// One fish (HTML `fishList`): its home in the water, swim speed and phase,
/// and its pose (heading [yaw], [roll] π when it floats belly up, tail
/// wag).
class _Fish {
  _Fish({
    required this.orig,
    required this.speed,
    required this.phase,
    required this.color,
  }) : pos = orig;

  final _V orig;
  final double speed;
  final double phase;
  final Color color;
  _V pos;
  double yaw = 0;
  double roll = 0;
  double tail = 0;

  void reset() {
    pos = orig;
    yaw = 0;
    roll = 0;
    tail = 0;
  }
}

/// A toxic bubble rising from the effluent (HTML `toxicBubbles`).
class _Bubble {
  _Bubble(this.x, this.z, this.r) : y = _bubbleLow;

  final double x;
  final double z;
  final double r;
  double y;
}

/// A pebble on the river bed (HTML `SphereGeometry(0.3 + random × 0.3)`
/// squashed to 1.4 × 0.5 × 1.1).
@immutable
class _Pebble {
  const _Pebble(this.pos, this.r);

  final _V pos;
  final double r;
}

/// The comparison card of Scenario 1 (HTML `showComparison(desc, step)`):
/// shown at [start], closing (300 ms) from [closingAt].
class _Comparison {
  _Comparison(this.step, this.start);

  final int step;
  final double start;
  double? closingAt;
}

/// A confetti piece (HTML `confetti({particleCount: 200, spread: 90})`).
@immutable
class _Confetto {
  const _Confetto(this.vx, this.vy, this.size, this.spin, this.color);

  final double vx;
  final double vy;
  final double size;
  final double spin;
  final Color color;
}

/// The boy's pose this frame (HTML `resetCharacterPose()` and the brushing
/// / washing / breathing animation of `animate()`); rotations are Euler
/// angles.
@immutable
class _Pose {
  const _Pose({
    required this.pos,
    required this.yaw,
    required this.armR,
    required this.foreR,
    required this.armL,
    required this.foreL,
    required this.head,
    required this.headY,
    required this.torsoY,
    required this.torsoRx,
    required this.brushPos,
  });

  final _V pos;
  final double yaw;
  final _V armR;
  final _V foreR;
  final _V armL;
  final _V foreL;
  final _V head;
  final double headY;
  final double torsoY;
  final double torsoRx;
  final _V brushPos;
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  _Scene() {
    final rng = math.Random(11);
    double jitter(double span) => (rng.nextDouble() - 0.5) * span;
    // HTML buildScenario2Scene(): pebbles, reeds, bubbles, fish and the
    // spill items are placed at random once.
    for (var i = 0; i < 15; i++) {
      pebbles.add(
        _Pebble(
          _V(jitter(8), _riverY - 0.05, jitter(18)),
          0.3 + rng.nextDouble() * 0.3,
        ),
      );
    }
    for (var z = -8.0; z <= 8; z += 3.5) {
      reeds
        ..add(_V(-_reedX, _riverY, z + jitter(1)))
        ..add(_V(_reedX, _riverY, z + jitter(1)));
    }
    for (var i = 0; i < 8; i++) {
      bubbles.add(
        _Bubble(
          _effluentX - 0.3 + jitter(1.5),
          _effluentZ + jitter(1.5),
          0.2 + rng.nextDouble() * 0.2,
        )..y = _bubbleLow + rng.nextDouble() * (_bubbleHigh - _bubbleLow),
      );
    }
    for (var i = 0; i < 6; i++) {
      fish.add(
        _Fish(
          orig: _V(jitter(6), _riverY + 1.75 + (i % 2) * 0.35, jitter(14)),
          speed: 1.2 + rng.nextDouble() * 0.8,
          phase: rng.nextDouble() * math.pi * 2,
          color: _fishColors[i % _fishColors.length],
        ),
      );
    }
    for (var i = 0; i < _spillShapes.length; i++) {
      spill.add(
        _Spill(
          i,
          _V(
            rng.nextDouble() * math.pi,
            rng.nextDouble() * math.pi,
            rng.nextDouble() * math.pi,
          ),
        ),
      );
    }
    load(0);
  }

  /// Random numbers for the spill and the confetti.
  final math.Random rng = math.Random(23);

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1–4); 5 once the scenario is finished.
  int step = 1;

  /// Bumped by [load], so callbacks of the old scenario stop.
  int _generation = 0;
  final List<_Anim> _anims = [];
  final List<(double, VoidCallback)> _cues = [];

  // ---------------------------------------------------------------- shared

  /// HTML `State.isAnimating`: presses are ignored.
  bool busy = false;
  _Comparison? comparison;
  _Drag? drag;

  /// HTML `startTimer()`: the countdown badge.
  double? timerStart;
  int timerSeconds = 0;
  VoidCallback? _timerDone;

  double? confettiAt;
  final List<_Confetto> confetti = [];

  bool get finished => step > _stepCount;

  /// Seconds left on the countdown badge (HTML `#timer-text`).
  int get timerLeft {
    final start = timerStart;
    if (start == null) return 0;
    return math.max(1, timerSeconds - (time - start).floor());
  }

  // ------------------------------------------------------------ scenario 1

  /// HTML `State.currentWaterLevel` and the level drawn (tweened).
  double levelValue = _baseLevel;
  double level = _baseLevel;
  bool tapOn = false;
  bool brushing = false;
  bool washing = false;

  /// The sink water bobbing between 6.05 and 6.18 while the tap runs
  /// (HTML `State.sinkTween`, yoyo every 1 s).
  bool sinkBob = false;
  double sinkBobStart = 0;
  final _Vessel bucket = _Vessel(_Grab.bucket, _bucketHome, _bucketAtSink);
  final _Vessel basin = _Vessel(_Grab.basin, _basinHome, _basinAtSink);
  bool toothbrush = true;
  bool sinkCloth = false;
  bool basinCloth = false;

  // ------------------------------------------------------------ scenario 2

  _V trashPos = _trashHome;

  /// The basket's `rotation.x` (tipped over to π / 2 to spill).
  double trashTilt = 0;
  bool trashInside = true;
  bool trashSorted = false;
  final List<_Spill> spill = [];
  _V pipePos = _pipeHome;
  bool pipeSorted = false;

  /// The valve wheel's turn (`rotation.z`, 0 → 2π).
  double valveSpin = 0;
  bool valveOpened = false;
  bool murky = false;

  /// The murky water's `scale.x` / `scale.z` (spreads 0.1 → 1).
  double murkyScale = 1;
  bool effluent = false;
  bool bubblesOn = false;
  bool restoring = false;
  bool binShown = false;
  bool signShown = false;
  bool recycleZone = false;
  bool signZone = false;
  final List<_Bubble> bubbles = [];
  final List<_Fish> fish = [];
  final List<_Pebble> pebbles = [];
  final List<_V> reeds = [];

  // ---------------------------------------------------------------- set up

  /// HTML `resetScenarioState(sc)` + `setStepState()`.
  void load(int index) {
    _generation++;
    _anims.clear();
    _cues.clear();
    scenario = index;
    step = 1;
    busy = false;
    comparison = null;
    drag = null;
    timerStart = null;
    _timerDone = null;
    confettiAt = null;
    confetti.clear();
    levelValue = _baseLevel;
    level = _baseLevel;
    tapOn = false;
    brushing = false;
    washing = false;
    sinkBob = false;
    bucket.reset(show: true);
    basin.reset(show: false);
    toothbrush = true;
    sinkCloth = false;
    basinCloth = false;
    trashPos = _trashHome;
    trashTilt = 0;
    trashInside = true;
    trashSorted = false;
    for (final item in spill) {
      item.visible = false;
    }
    pipePos = _pipeHome;
    pipeSorted = false;
    valveSpin = 0;
    valveOpened = false;
    murky = false;
    murkyScale = 1;
    effluent = false;
    bubblesOn = false;
    restoring = false;
    for (final f in fish) {
      f.reset();
    }
    applyStep();
  }

  /// HTML `setStepState()`: what each step shows.
  void applyStep() {
    bucket.zone = false;
    basin.zone = false;
    recycleZone = false;
    signZone = false;
    if (scenario == 0) {
      switch (step) {
        case 1:
          toothbrush = true;
          sinkCloth = false;
          basinCloth = false;
        case 2:
          toothbrush = true;
          sinkCloth = false;
          basinCloth = false;
          bucket
            ..zone = true
            ..visible = true
            ..waterShown = false
            ..fill = _fillEmpty;
          basin.visible = false;
        case 3:
          toothbrush = false;
          sinkCloth = true;
          basinCloth = false;
          bucket.visible = false;
          basin.visible = false;
        case 4:
          toothbrush = false;
          sinkCloth = false;
          basinCloth = true;
          basin
            ..zone = true
            ..visible = true
            ..waterShown = false
            ..fill = _fillEmpty;
      }
      return;
    }
    if (step == 4) {
      binShown = true;
      signShown = true;
      recycleZone = true;
      signZone = true;
      trashTilt = 0;
      trashSorted = false;
      pipeSorted = false;
      trashInside = true;
      effluent = true;
      bubblesOn = true;
      murky = true;
      murkyScale = 1;
    } else if (step < 4) {
      binShown = false;
      signShown = false;
    }
  }

  // ---------------------------------------------------------------- tweens

  /// Starts a tween (HTML `new TWEEN.Tween(...).to(..., ms).start()`).
  void tween(
    double seconds,
    void Function(double t) apply, {
    double delay = 0,
    VoidCallback? done,
    Object? tag,
  }) => _anims.add(_Anim(time + delay, seconds, apply, done, tag));

  /// Moves an object from where it is to [to] (HTML position tween).
  void tweenTo(
    _V from,
    _V to,
    double seconds,
    void Function(_V v) set, {
    double delay = 0,
    VoidCallback? done,
    Object? tag,
  }) => tween(
    seconds,
    (t) => set(_V.lerp(from, to, t)),
    delay: delay,
    done: done,
    tag: tag,
  );

  /// Stops the tweens moving [tag] (a drag takes the object over).
  void stop(Object tag) => _anims.removeWhere((a) => a.tag == tag);

  /// Runs [run] after [seconds] (HTML `setTimeout`).
  void cue(double seconds, VoidCallback run) =>
      _cues.add((time + seconds, run));

  /// HTML `startTimer(seconds, onStart, onFinish)` without the start
  /// callback (the caller runs it).
  void startTimer(int seconds, VoidCallback onFinish) {
    timerStart = time;
    timerSeconds = seconds;
    _timerDone = onFinish;
  }

  /// HTML `TWEEN.update()`, the pending timeouts and the countdown.
  void update() {
    final gen = _generation;
    if (_anims.isNotEmpty) {
      for (final a in List.of(_anims)) {
        if (gen != _generation) return;
        if (a.run(time)) _anims.remove(a);
      }
    }
    if (_cues.isNotEmpty) {
      final due = [
        for (final c in _cues)
          if (c.$1 <= time) c,
      ];
      if (due.isNotEmpty) {
        _cues.removeWhere(due.contains);
        for (final c in due) {
          if (gen != _generation) return;
          c.$2();
        }
      }
    }
    final start = timerStart;
    if (start != null && time - start >= timerSeconds) {
      final done = _timerDone;
      timerStart = null;
      _timerDone = null;
      done?.call();
    }
  }

  // ------------------------------------------------------------- animate()

  /// The per-frame part of HTML `animate()` for Scenario 2: fish swimming
  /// in clean water (or floating in murky water), toxic bubbles rising and
  /// the spilled plastic bobbing. [dt] is the frame step in seconds.
  void animate(double dt) {
    if (scenario != 1) return;
    final t = time * _htmlClock;
    // The HTML moves bubbles and spill a fixed amount per (60 Hz) frame.
    final frames = dt * 60;
    if (!murky) {
      if (step < 3) {
        for (var i = 0; i < fish.length; i++) {
          final f = fish[i];
          final a = t * f.speed + f.phase;
          final dx = math.cos(a) * f.speed * 2.2;
          final dz = -math.sin(a) * f.speed * 3.2;
          f
            ..pos = _V(
              f.orig.x + math.sin(a) * 2.2,
              f.orig.y + math.sin(t * 2 + i) * 0.12,
              f.orig.z + math.cos(a) * 3.2,
            )
            // Heading along the swim (the HTML's atan2(dx, dz) + π turned
            // the fish sideways to its path).
            ..yaw = math.atan2(-dz, dx)
            ..tail = math.sin(t * 15 + i) * 0.45;
        }
      }
    } else {
      if (bubblesOn) {
        for (var i = 0; i < bubbles.length; i++) {
          final b = bubbles[i];
          b.y += (0.025 + (i % 3) * 0.01) * frames;
          if (b.y > _bubbleHigh) b.y = _bubbleLow;
        }
      }
      for (var i = 0; i < fish.length; i++) {
        final f = fish[i];
        f
          ..pos = f.pos.withY(_deadFishY + math.sin(t * 2 + i) * 0.05)
          ..tail = 0;
      }
    }
    for (var i = 0; i < spill.length; i++) {
      final item = spill[i];
      if (!item.visible) continue;
      item
        ..pos = item.pos.withY(_spillY + math.sin(t * 3 + i) * 0.05)
        ..rot = _V(
          item.rot.x + 0.005 * frames,
          item.rot.y,
          item.rot.z + 0.003 * frames,
        );
    }
  }

  /// The boy's pose now (HTML `resetCharacterPose()` for the step, then
  /// `animate()`): brushing at the mirror for steps 1–2, at the sink for
  /// steps 3–4.
  _Pose pose() {
    final t = time * _htmlClock;
    final atSink = step >= 3;
    var armR = atSink ? const _V(-math.pi / 3.5, 0, -math.pi / 12) : _brushArm;
    var foreR = atSink ? const _V(-math.pi / 4, 0, 0) : _brushForearm;
    var armL = atSink ? const _V(-math.pi / 3.5, 0, math.pi / 12) : _V.zero;
    var foreL = atSink ? const _V(-math.pi / 4, 0, 0) : _V.zero;
    var head = atSink ? const _V(-math.pi / 8, 0, 0) : _V.zero;
    var torsoY = _torsoY, headY = _headY, torsoRx = 0.0;
    var brushPos = _brushPos;
    if (brushing) {
      // Hand and brush at the mouth, brushing to and fro.
      final stroke = math.sin(t * 12);
      armR = _brushArm;
      foreR = _V(
        _brushForearm.x,
        _brushForearm.y,
        _brushForearm.z + stroke * 0.15,
      );
      brushPos = _V(_brushPos.x + stroke * 0.12, _brushPos.y, _brushPos.z);
      head = _V(head.x, math.sin(t * 3) * 0.04, head.z);
    } else if (washing) {
      // Vigorous scrubbing in the sink or the basin.
      armR = _V(-1.4 + math.sin(t * 8) * 0.25, -0.2, -0.15);
      armL = _V(-1.4 + math.cos(t * 8) * 0.25, 0.2, 0.15);
      foreR = const _V(-0.55, 0, 0);
      foreL = const _V(-0.55, 0, 0);
      torsoRx = math.sin(t * 8) * 0.08;
    } else {
      // Gentle breathing when idle.
      final breath = math.sin(t * 0.5) * 0.03;
      torsoY += breath;
      headY += breath;
    }
    return _Pose(
      pos: atSink ? _charWashPos : _charBrushPos,
      yaw: atSink ? _charWashYaw : _charBrushYaw,
      armR: armR,
      foreR: foreR,
      armL: armL,
      foreL: foreL,
      head: head,
      headY: headY,
      torsoY: torsoY,
      torsoRx: torsoRx,
      brushPos: brushPos,
    );
  }

  /// HTML `confetti({particleCount: 200, spread: 90, origin: {y: 0.4}})`.
  void launchConfetti() {
    confettiAt = time;
    confetti.clear();
    for (var i = 0; i < 200; i++) {
      final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * math.pi / 2;
      final speed = 380 + rng.nextDouble() * 520;
      confetti.add(
        _Confetto(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
          4 + rng.nextDouble() * 5,
          (rng.nextDouble() - 0.5) * 16,
          _Colors.confetti[i % _Colors.confetti.length],
        ),
      );
    }
  }
}

// ================================================================== PAINTING

/// HTML lights: `AmbientLight(0xffffff, 0.85)` and `DirectionalLight(
/// 0xffffff, 0.7)` at (12, 28, 18), normalised. Without the WebGL
/// renderer's specular light the faces would wash out at those strengths,
/// so they are toned down to keep the faces of a mesh apart.
const _V _keyLight = _V(0.3392, 0.7914, 0.5088);
const double _ambient = 0.68;
const double _keyPower = 0.48;

/// The key light as seen on screen: from the upper right.
const Offset _lightOnScreen = Offset(0.587, -0.809);

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a surface with normal [n].
Color _lit(Color c, _V n) {
  final len = n.length;
  final k =
      _ambient +
      (len < 1e-9 ? 0 : _keyPower * math.max(0.0, n.dot(_keyLight) / len));
  double channel(double v) => math.min(1.0, v * k);
  return Color.from(
    alpha: c.a,
    red: channel(c.r),
    green: channel(c.g),
    blue: channel(c.b),
  );
}

/// [c] with its alpha multiplied by [opacity] (a transparent material).
Color _alpha(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

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

/// How a cylinder's ends are drawn: the end cap turned to the camera, the
/// inside seen through an open top (`openEnded`), or nothing (a tube whose
/// ends are hidden).
enum _Ends { closed, open, none }

/// Mesh drawing in the HTML camera's projection. Meshes are queued with
/// their depth ([later]) and drawn far to near ([flush]), like the HTML
/// depth buffer; the `draw…` methods draw at once (parts of one object in a
/// fixed order).
class _Gfx {
  _Gfx(this.canvas, this.cam);

  final Canvas canvas;
  final _Cam cam;
  final List<(double, int, VoidCallback)> _queue = [];
  final Paint _paint = Paint();
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint fill(Color c) => _paint
    ..shader = null
    ..color = c;

  Paint shaded(Shader shader) => _paint
    ..color = LabInk.black
    ..shader = shader;

  Paint line(Color c, double width) => _line
    ..color = c
    ..strokeWidth = width;

  // ------------------------------------------------------------ ordering

  /// Queues [draw] at [depth].
  void later(double depth, VoidCallback draw) =>
      _queue.add((depth, _queue.length, draw));

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

  static Path polygon(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  // ---------------------------------------------------------- primitives

  /// A circle of radius [r] at height [y] in the frame's XZ plane (a
  /// CylinderGeometry end), as [n] screen points.
  List<Offset> _rim(_Xf xf, double r, double y, int n) => [
    for (var i = 0; i < n; i++)
      cam.p(
        xf(
          r * math.cos(2 * math.pi * i / n),
          y,
          r * math.sin(2 * math.pi * i / n),
        ),
      ),
  ];

  /// The colour of a round side around [axis] at [at], lit as the part
  /// turned to the camera.
  Color _sideColor(Color color, _V axis, _V at) {
    final k = (cam.eye - at).unit;
    final a = axis.unit;
    return _lit(color, k - a * k.dot(a));
  }

  /// Shading across a round side from [a] to [b] (half width [halfWidth]):
  /// shadow on the side away from the key light, a highlight towards it.
  Shader _sideShader(
    Offset a,
    Offset b,
    double halfWidth,
    Color base,
    double opacity,
  ) {
    final d = b - a;
    var n = d.distance < 1e-6
        ? const Offset(1, 0)
        : Offset(-d.dy, d.dx) / d.distance;
    if (n.dx * _lightOnScreen.dx + n.dy * _lightOnScreen.dy < 0) n = -n;
    final mid = (a + b) / 2;
    final w = math.max(1.0, halfWidth);
    return ui.Gradient.linear(
      mid - n * w,
      mid + n * w,
      [
        _alpha(labShade(base, -0.3), opacity),
        _alpha(base, opacity),
        _alpha(labShade(base, 0.18), opacity),
        _alpha(labShade(base, -0.1), opacity),
      ],
      const [0, 0.5, 0.78, 1],
    );
  }

  /// CylinderGeometry([rTop], [rBottom], [h]) centred on [xf] (axis along
  /// its y): the outline with its side shading and its [ends]. An open top
  /// shows the inside ([inner]) and [inside] draws the contents clipped to
  /// the opening.
  void drawCylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    double opacity = 1,
    _Ends ends = _Ends.closed,
    Color? inner,
    Color? cap,
    int segments = 24,
    VoidCallback? inside,
  }) {
    final hh = h / 2;
    final top = _rim(xf, rTop, hh, segments);
    final bottom = _rim(xf, rBottom, -hh, segments);
    final a = xf(0, -hh, 0), b = xf(0, hh, 0);
    final side = _sideColor(color, xf.y, xf.o);
    canvas.drawPath(
      polygon(_hull([...top, ...bottom])),
      shaded(
        _sideShader(
          cam.p(a),
          cam.p(b),
          math.max(rBottom * cam.scaleAt(a), rTop * cam.scaleAt(b)),
          side,
          opacity,
        ),
      ),
    );
    final topFacing = (cam.eye - b).dot(xf.y) > 0;
    switch (ends) {
      case _Ends.closed:
        final r = topFacing ? rTop : rBottom;
        if (r > 1e-4) {
          canvas.drawPath(
            polygon(topFacing ? top : bottom),
            fill(_alpha(cap ?? _lit(color, topFacing ? xf.y : -xf.y), opacity)),
          );
        }
      case _Ends.open:
        if (!topFacing || rTop <= 1e-4) break;
        final mouth = polygon(top);
        canvas.drawPath(
          mouth,
          fill(_alpha(inner ?? labShade(side, -0.35), opacity)),
        );
        if (inside != null) {
          canvas
            ..save()
            ..clipPath(mouth);
          inside();
          canvas.restore();
        }
        canvas.drawPath(mouth, line(_alpha(labShade(side, 0.3), opacity), 1.2));
      case _Ends.none:
        break;
    }
  }

  /// The near half of a cylinder's side: a band seen from outside (the
  /// bucket's rim band, the basket's front wall).
  void drawBand(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    double opacity = 1,
    int segments = 32,
  }) {
    final hh = h / 2;
    final top = _rim(xf, rTop, hh, segments);
    final bottom = _rim(xf, rBottom, -hh, segments);
    final centre = cam.depth(xf.o);
    final near = [
      for (var i = 0; i < segments; i++)
        cam.depth(
              xf(
                math.cos(2 * math.pi * i / segments),
                0,
                math.sin(2 * math.pi * i / segments),
              ),
            ) <
            centre,
    ];
    final run = _runOf(near);
    if (run.length < 2) return;
    final side = _sideColor(color, xf.y, xf.o);
    final a = xf(0, -hh, 0), b = xf(0, hh, 0);
    canvas.drawPath(
      polygon([
        for (final i in run) top[i],
        for (final i in run.reversed) bottom[i],
      ]),
      shaded(
        _sideShader(
          cam.p(a),
          cam.p(b),
          math.max(rBottom * cam.scaleAt(a), rTop * cam.scaleAt(b)),
          side,
          opacity,
        ),
      ),
    );
  }

  /// Indices of the longest run of consecutive true [flags] (wrapping
  /// round), in order.
  static List<int> _runOf(List<bool> flags) {
    final n = flags.length;
    var start = -1;
    for (var i = 0; i < n; i++) {
      if (flags[i] && !flags[(i - 1 + n) % n]) {
        start = i;
        break;
      }
    }
    if (start < 0) {
      return n > 0 && flags[0] ? List.generate(n, (i) => i) : const [];
    }
    final out = <int>[];
    for (var k = 0; k < n; k++) {
      final i = (start + k) % n;
      if (!flags[i]) break;
      out.add(i);
    }
    return out;
  }

  /// SphereGeometry of radius [r] in the frame [xf] (its axes carry the
  /// mesh scale); [flat] for an unlit `MeshBasicMaterial`.
  void drawSphere(
    _Xf xf,
    double r,
    Color color, {
    double opacity = 1,
    bool flat = false,
  }) => drawEllipsoid(
    xf.o,
    xf.x * r,
    xf.y * r,
    xf.z * r,
    color,
    opacity: opacity,
    flat: flat,
  );

  /// An ellipsoid at [c] with semi-axes [a], [b], [d] as the camera sees
  /// it: the projected axes' ellipse (eigen-decomposition of Σ q qᵀ).
  void drawEllipsoid(
    _V c,
    _V a,
    _V b,
    _V d,
    Color color, {
    double opacity = 1,
    bool flat = false,
  }) {
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
      0.5 * math.atan2(2 * m01, m00 - m11),
      color,
      opacity: opacity,
      flat: flat,
    );
  }

  /// A lit ellipse of radii [rx] × [ry] at [c], turned by [angle].
  void blob(
    Offset c,
    double rx,
    double ry,
    double angle,
    Color color, {
    double opacity = 1,
    bool flat = false,
  }) {
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle)
      ..scale(math.max(0.3, rx), math.max(0.3, ry));
    if (flat) {
      canvas.drawCircle(Offset.zero, 1, fill(_alpha(color, opacity)));
    } else {
      final cs = math.cos(-angle), sn = math.sin(-angle);
      final light = Offset(
        _lightOnScreen.dx * cs - _lightOnScreen.dy * sn,
        _lightOnScreen.dx * sn + _lightOnScreen.dy * cs,
      );
      canvas.drawCircle(
        Offset.zero,
        1,
        shaded(
          ui.Gradient.radial(
            light * 0.4,
            1.35,
            [
              _alpha(labShade(color, 0.32), opacity),
              _alpha(color, opacity),
              _alpha(labShade(color, -0.4), opacity),
            ],
            const [0, 0.42, 1],
          ),
        ),
      );
    }
    canvas.restore();
  }

  /// A small unlit sphere (eyes, pupils, droplets), at least 0.8 px.
  void dot(_V c, double r, Color color) => canvas.drawCircle(
    cam.p(c),
    math.max(0.8, r * cam.scaleAt(c)),
    fill(color),
  );

  /// TorusGeometry([radius], [tube]) in the frame's XY plane, from angle 0
  /// to [arc]; [near] keeps only the half nearer (true) or farther (false)
  /// than its centre.
  void drawTorus(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    double arc = 2 * math.pi,
    double opacity = 1,
    bool? near,
    int segments = 48,
  }) {
    final centre = cam.depth(xf.o);
    final width = math.max(0.8, 2 * tube * cam.scaleAt(xf.o));
    final n = math.max(4, (segments * arc / (2 * math.pi)).ceil());
    final path = Path();
    var pen = false;
    for (var i = 0; i <= n; i++) {
      final th = arc * i / n;
      final q = xf(radius * math.cos(th), radius * math.sin(th), 0);
      if (near != null && (cam.depth(q) < centre) != near) {
        pen = false;
        continue;
      }
      final o = cam.p(q);
      if (pen) {
        path.lineTo(o.dx, o.dy);
      } else {
        path.moveTo(o.dx, o.dy);
      }
      pen = true;
    }
    canvas.drawPath(path, line(_alpha(labShade(color, -0.12), opacity), width));
    if (width > 2.5) {
      canvas.drawPath(
        path,
        line(_alpha(labShade(color, 0.3), opacity), width * 0.35),
      );
    }
  }

  /// CircleGeometry([r]) or RingGeometry([inner], [r]) in the frame's XY
  /// plane.
  void drawDisc(
    _Xf xf,
    double r,
    Color color, {
    double inner = 0,
    double opacity = 1,
    int segments = 48,
  }) {
    List<Offset> circle(double radius) => [
      for (var i = 0; i < segments; i++)
        cam.p(
          xf(
            radius * math.cos(2 * math.pi * i / segments),
            radius * math.sin(2 * math.pi * i / segments),
            0,
          ),
        ),
    ];
    final path = polygon(circle(r));
    if (inner > 0) {
      path
        ..addPath(polygon(circle(inner)), Offset.zero)
        ..fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, fill(_alpha(color, opacity)));
  }

  /// BoxGeometry of [size] in the frame [xf]: the faces turned to the
  /// camera, lit by the key light, with soft edges.
  void drawBox(
    _Xf xf,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final fn = face.normal;
      final n = xf.dir(fn);
      final mid = xf(fn.x * hx, fn.y * hy, fn.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = polygon([
        for (final k in face.corners) cam.p(xf(k.x * hx, k.y * hy, k.z * hz)),
      ]);
      canvas.drawPath(path, fill(_alpha(_lit(color, n), opacity)));
      if (edge > 0) {
        canvas.drawPath(
          path,
          line(_alpha(labShade(color, -0.5), edge * opacity), 0.8),
        );
      }
    }
  }

  /// [drawBox] queued at the box's depth.
  void box(_Xf xf, _V size, Color color, {double opacity = 1}) =>
      later(cam.depth(xf.o), () => drawBox(xf, size, color, opacity: opacity));

  /// [drawCylinder] (closed) queued at the cylinder's depth.
  void cylinder(
    _Xf xf,
    double rTop,
    double rBottom,
    double h,
    Color color, {
    int segments = 16,
  }) => later(
    cam.depth(xf.o),
    () => drawCylinder(xf, rTop, rBottom, h, color, segments: segments),
  );

  /// [drawSphere] queued at the sphere's depth.
  void sphere(_Xf xf, double r, Color color) =>
      later(cam.depth(xf.o), () => drawSphere(xf, r, color));

  /// Outline of the part of the sphere ([c], [r]) the camera sees where
  /// (p − c)·[axis] ≤ r·[cosLimit]: below the rim of a cap round [axis]
  /// (the face under the hair). Empty when that part is hidden.
  List<Offset> sphereZone(
    _V c,
    double r,
    _V axis,
    double cosLimit, {
    int segments = 48,
  }) {
    final a = axis.unit;
    final k = (cam.eye - c).unit;
    var e1 = k.cross(_V.up);
    if (e1.length < 1e-6) e1 = const _V(1, 0, 0);
    e1 = e1.unit;
    final e2 = k.cross(e1).unit;
    final limit = r * cosLimit;
    // The silhouette (seen from afar) and which of it lies in the zone.
    final silhouette = <_V>[];
    final inZone = <bool>[];
    for (var i = 0; i < segments; i++) {
      final th = 2 * math.pi * i / segments;
      final q = c + (e1 * math.cos(th) + e2 * math.sin(th)) * r;
      silhouette.add(q);
      inZone.add((q - c).dot(a) <= limit);
    }
    // The cap's rim and which of it faces the camera.
    var b1 = a.cross(k);
    if (b1.length < 1e-6) b1 = a.cross(const _V(1, 0, 0));
    b1 = b1.unit;
    final b2 = a.cross(b1).unit;
    final m = c + a * limit;
    final rho = r * math.sqrt(math.max(0.0, 1 - cosLimit * cosLimit));
    final rim = <_V>[];
    final front = <bool>[];
    for (var i = 0; i < segments; i++) {
      final th = 2 * math.pi * i / segments;
      final q = m + (b1 * math.cos(th) + b2 * math.sin(th)) * rho;
      rim.add(q);
      front.add((q - c).dot(k) >= 0);
    }
    final silRun = _runOf(inZone);
    final rimRun = _runOf(front);
    if (silRun.isEmpty) {
      return rimRun.length == segments
          ? [for (final q in rim) cam.p(q)]
          : const [];
    }
    if (silRun.length == segments || rimRun.isEmpty) {
      return [for (final i in silRun) cam.p(silhouette[i])];
    }
    // The silhouette arc, then the visible rim back to its start.
    final end = silhouette[silRun.last];
    final first = rim[rimRun.first], last = rim[rimRun.last];
    final rimIdx = (first - end).length <= (last - end).length
        ? rimRun
        : rimRun.reversed;
    return [
      for (final i in silRun) cam.p(silhouette[i]),
      for (final i in rimIdx) cam.p(rim[i]),
    ];
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the bathroom
/// (wooden floor, glass water tank, porcelain sink with its tap and stream,
/// the boy, the bucket and the basin), S2 the river diorama (banks, bed,
/// trees, reeds, fish, water, trash basket, spilled plastic, outfall pipe,
/// effluent, bubbles, recycling bin, treatment sign); then the floating
/// labels and the confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  _Cam get _cam => _camera;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      labBleed(size),
      Paint()..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    final g = _Gfx(canvas, _cam);
    final t = scene.time * _htmlClock;
    if (scene.scenario == 0) {
      _paintBathroom(g, t);
    } else {
      _paintRiver(g, t);
    }
    g.flush();
    if (showLabels) _paintLabels(canvas);
    _paintConfetti(canvas);
  }

  // ------------------------------------------------------------ scenario 1

  /// `buildScenario1Scene()`.
  void _paintBathroom(_Gfx g, double t) {
    final s = scene;
    // Floor BoxGeometry(40, 1, 20) at y -0.5 (woodMat).
    g.drawBox(
      const _Xf.at(_V(0, -0.5, 0)),
      const _V(40, 1, 20),
      _Colors.wood,
      edge: 0.25,
    );
    // Drop zones: glowing RingGeometry round the sink pedestal.
    final ring = _Xf.at(_sinkPos.withY(0.1)).child(_V.zero, rx: -math.pi / 2);
    if (s.bucket.zone) {
      g.drawDisc(ring, 2.8, _Colors.glow, inner: 1.5, opacity: 0.35);
    }
    if (s.basin.zone) {
      g.drawDisc(ring, 3.2, _Colors.glow, inner: 2.0, opacity: 0.35);
    }
    g
      ..later(
        _cam.depth(_tankPos + const _V(0, _tankH / 2, 0)),
        () => _paintTank(g, t),
      )
      ..later(_cam.depth(_sinkPos + const _V(0, 4, 0)), () => _paintSink(g, t));
    _paintBoy(g);
    for (final v in [s.bucket, s.basin]) {
      if (!v.visible || v.atSink) continue;
      g.later(
        _cam.depth(v.pos + const _V(0, 1, 0)),
        () => _paintVessel(g, v, t),
      );
    }
  }

  /// The Main Water Tank: metal base, glass, level rings and step lines,
  /// and the blue water whose meniscus ripples while the tap runs.
  void _paintTank(_Gfx g, double t) {
    final s = scene;
    const tank = _Xf.at(_tankPos);
    g.drawCylinder(
      tank,
      _tankBaseR,
      _tankBaseR,
      _tankBaseH,
      _Colors.metal,
      segments: 40,
    );
    // Glass CylinderGeometry(4, 4, 12, open) (glassMat, opacity 0.2).
    final glass = tank.child(const _V(0, _tankH / 2, 0));
    g.drawCylinder(
      glass,
      _tankR,
      _tankR,
      _tankH,
      _Colors.glass,
      opacity: 0.08,
      ends: _Ends.none,
      segments: 40,
    );
    _tankRings(g, tank, near: false);
    // Water CylinderGeometry(3.8) up to the level and its meniscus
    // CircleGeometry(3.78).
    final level = math.max(_minLevel, s.level);
    g.drawCylinder(
      tank.child(_V(0, level / 2, 0)),
      _tankWaterR,
      _tankWaterR,
      level,
      _Colors.tankWater,
      opacity: 0.88,
      ends: _Ends.none,
      segments: 40,
    );
    final wobble = s.tapOn ? 0.015 : 0.0;
    g.drawDisc(
      tank.child(
        _V(0, level, 0),
        rx: -math.pi / 2,
        sx: 1 + math.sin(t * 10) * wobble,
        sy: 1 + math.cos(t * 10) * wobble,
      ),
      _meniscusR,
      _lit(_Colors.tankSurface, _V.up),
    );
    _glassFront(g, glass);
    _tankRings(g, tank, near: true);
  }

  /// The ten thin level rings (every 1.1) and the five thicker step lines
  /// round the tank: their far or near halves.
  void _tankRings(_Gfx g, _Xf tank, {required bool near}) {
    for (var i = 1; i <= 10; i++) {
      g.drawTorus(
        tank.child(_V(0, i * _ringGap, 0), rx: math.pi / 2),
        _ringR,
        _ringTube,
        _Colors.metal,
        near: near,
      );
    }
    for (final y in _stepLines) {
      g.drawTorus(
        tank.child(_V(0, y, 0), rx: math.pi / 2),
        _lineR,
        _lineTube,
        _Colors.metal,
        near: near,
      );
    }
  }

  /// The near side of the glass: two sheen stripes, the edges and rims.
  void _glassFront(_Gfx g, _Xf glass) {
    final c = g.canvas;
    final top = glass.at(const _V(0, _tankH / 2, 0));
    final bottom = glass.at(const _V(0, -_tankH / 2, 0));
    final pt = _cam.p(top), pb = _cam.p(bottom);
    final wt = _tankR * _cam.scaleAt(top), wb = _tankR * _cam.scaleAt(bottom);
    void stripe(double from, double to, double alpha) => c.drawPath(
      _Gfx.polygon([
        Offset(pt.dx + wt * from, pt.dy),
        Offset(pt.dx + wt * to, pt.dy),
        Offset(pb.dx + wb * to, pb.dy),
        Offset(pb.dx + wb * from, pb.dy),
      ]),
      g.fill(_Colors.white.withValues(alpha: alpha)),
    );
    stripe(0.38, 0.58, 0.14);
    stripe(-0.78, -0.7, 0.1);
    final edge = g.line(_Colors.white.withValues(alpha: 0.32), 1.2);
    c
      ..drawLine(Offset(pt.dx - wt, pt.dy), Offset(pb.dx - wb, pb.dy), edge)
      ..drawLine(Offset(pt.dx + wt, pt.dy), Offset(pb.dx + wb, pb.dy), edge);
    g
      ..drawTorus(
        glass.child(const _V(0, _tankH / 2, 0), rx: math.pi / 2),
        _tankR,
        0.03,
        _Colors.white,
        opacity: 0.45,
      )
      ..drawTorus(
        glass.child(const _V(0, -_tankH / 2 + 0.3, 0), rx: math.pi / 2),
        _tankR,
        0.03,
        _Colors.white,
        opacity: 0.3,
        near: true,
      );
  }

  /// The white porcelain sink: pedestal, bowl with the blue water (and the
  /// clothes at step 3), the tap, a container standing in it and the
  /// running stream.
  void _paintSink(_Gfx g, double t) {
    final s = scene;
    const sink = _Xf.at(_sinkPos);
    // Pedestal CylinderGeometry(1.3, 1.7, 5) at 2.5 (sinkPedestalMat).
    g.drawCylinder(
      sink.child(const _V(0, 2.5, 0)),
      1.3,
      1.7,
      5,
      _Colors.sinkPedestal,
      segments: 32,
    );
    // Bowl CylinderGeometry(3.3, 1.9, 1.6) at 5.75 (sinkBasinMat), drawn
    // open so the inner bowl and its water show.
    g.drawCylinder(
      sink.child(const _V(0, 5.75, 0)),
      3.3,
      1.9,
      1.6,
      _Colors.sinkBasin,
      ends: _Ends.open,
      inner: _lit(_Colors.sinkBasin, _V.up),
      segments: 40,
      inside: () => _paintBowl(g, sink, t),
    );
    if (s.sinkCloth) _paintSinkCloth(g, sink, t);
    // Tap: a pipe up, over and down (metalMat) at (0, 6.5, -2.2).
    final tap = sink.child(const _V(0, 6.5, -2.2));
    g
      ..drawCylinder(
        tap.child(const _V(0, 1.1, 0)),
        0.25,
        0.28,
        2.2,
        _Colors.metal,
        segments: 16,
      )
      ..drawCylinder(
        tap.child(const _V(0, 2.2, 1.2), rx: math.pi / 2),
        0.22,
        0.25,
        2.4,
        _Colors.metal,
        segments: 16,
      )
      ..drawCylinder(
        tap.child(const _V(0, 1.9, 2.2)),
        0.2,
        0.22,
        0.6,
        _Colors.metal,
        segments: 16,
      );
    for (final v in [s.bucket, s.basin]) {
      if (v.visible && v.atSink) _paintVessel(g, v, t);
    }
    if (s.tapOn) _paintStream(g, t);
  }

  /// Height of the sink water's top: resting, or bobbing (HTML yoyo tween,
  /// linear, 1 s each way) while the tap runs.
  double _sinkWaterTop() {
    final s = scene;
    var y = _sinkWaterRest;
    if (s.sinkBob) {
      final phase = (s.time - s.sinkBobStart) % 2;
      y += (_sinkWaterHigh - _sinkWaterRest) * (1 - (phase - 1).abs());
    }
    return y + _sinkWaterHalfH;
  }

  /// Inside the bowl: the inner bowl (CylinderGeometry(2.9, 1.5, 1.4),
  /// sinkInnerMat) and the swirling water (CylinderGeometry(2.65, 1.48,
  /// 0.75), sinkWaterMat).
  void _paintBowl(_Gfx g, _Xf sink, double t) {
    final opening = sink.child(const _V(0, _bowlTop, 0), rx: -math.pi / 2);
    g.drawDisc(opening, 2.9, labShade(_Colors.sinkInner, -0.16));
    final c = g.canvas;
    c
      ..save()
      ..clipPath(
        _Gfx.polygon([
          for (var i = 0; i < 48; i++)
            _cam.p(
              opening(
                2.9 * math.cos(2 * math.pi * i / 48),
                2.9 * math.sin(2 * math.pi * i / 48),
                0,
              ),
            ),
        ]),
      );
    final ripple = 1 + math.sin(t * 8) * 0.02;
    final surface = sink.child(
      _V(0, _sinkWaterTop(), 0),
      rx: -math.pi / 2,
      sx: ripple,
      sy: ripple,
    );
    g.drawDisc(surface, 2.65, _Colors.sinkWater, opacity: 0.92);
    // The water turns (`rotation.y = time * 3`): two light swirl arcs.
    final swirl = surface.child(_V.zero, rz: t * 3);
    g
      ..drawTorus(swirl, 1.7, 0.035, _Colors.white, arc: 1.5, opacity: 0.3)
      ..drawTorus(
        swirl.child(_V.zero, rz: math.pi),
        1.05,
        0.03,
        _Colors.white,
        arc: 1.2,
        opacity: 0.25,
      );
    c.restore();
  }

  /// The clothes in the sink (step 3): a folded box and roll
  /// (`sinkClothMesh`), squashed and bouncing while scrubbed.
  void _paintSinkCloth(_Gfx g, _Xf sink, double t) {
    final scrub = scene.washing;
    final k = math.sin(t * 8);
    final cloth = sink.child(
      _V(0, 6.15 + (scrub ? k.abs() * 0.12 : 0), -0.2),
      sx: scrub ? 1 + k * 0.18 : 1,
      sy: scrub ? 1 - k * 0.18 : 1,
      sz: scrub ? 1 + math.cos(t * 8) * 0.18 : 1,
    );
    g
      ..drawBox(
        cloth.child(const _V(0, 0.1, 0)),
        const _V(1.6, 0.4, 1.2),
        _Colors.clothes,
      )
      ..drawCylinder(
        cloth.child(const _V(0, 0.25, 0), rz: math.pi / 2),
        0.5,
        0.6,
        1.3,
        _Colors.clothes,
        segments: 16,
      );
  }

  /// The running tap: a tapered stream (CylinderGeometry(0.18, 0.08, 4.8)
  /// with a bright core) from the spout to where it lands, a splash disc,
  /// two spreading ripple rings and twelve bouncing droplets there. (The
  /// HTML's splash sits 2.4 below the stream's middle, inside the sink;
  /// here it is drawn where the stream meets the water.)
  void _paintStream(_Gfx g, double t) {
    final s = scene;
    var land = _sinkWaterTop();
    for (final v in [s.bucket, s.basin]) {
      if (!v.visible || !v.atSink) continue;
      land = v.grab == _Grab.bucket
          ? v.pos.y + 1.4 + 1.3 * v.fill
          : v.pos.y + 0.7 + 0.6 * v.fill;
    }
    final h = _spoutY - land;
    if (h <= 0) return;
    double radius(double y, double rTop, double rBottom) =>
        rBottom +
        (rTop - rBottom) * (y - _streamBottom) / (_streamTop - _streamBottom);
    final flow = 1 + math.sin(t * 25) * 0.05;
    final column = _Xf.at(_V(_sinkPos.x, (_spoutY + land) / 2, _sinkPos.z));
    g
      ..drawCylinder(
        column.child(_V.zero, sx: flow, sz: flow),
        radius(_spoutY, 0.18, 0.08),
        radius(land, 0.18, 0.08),
        h,
        _Colors.stream,
        opacity: 0.85,
        ends: _Ends.none,
        segments: 16,
      )
      ..drawCylinder(
        column.child(_V.zero, sx: 2 - flow, sz: 2 - flow),
        radius(_spoutY, 0.1, 0.04),
        radius(land, 0.1, 0.04),
        h,
        _Colors.streamCore,
        opacity: 0.95,
        ends: _Ends.none,
        segments: 12,
      );
    final at = _Xf.at(_V(_sinkPos.x, land + 0.02, _sinkPos.z));
    final disc = 1 + math.sin(t * 18) * 0.15;
    g.drawDisc(
      at.child(_V.zero, rx: -math.pi / 2, sx: disc, sy: disc),
      0.75,
      _Colors.stream,
      opacity: 0.85,
    );
    final ring1 = 1 + ((t * 3) % 1) * 0.5;
    final ring2 = 1 + ((t * 3 + 0.5) % 1) * 0.6;
    g
      ..drawTorus(
        at.child(_V.zero, rx: math.pi / 2, sx: ring1, sy: ring1),
        0.55,
        0.06,
        _Colors.streamCore,
        opacity: 0.85,
      )
      ..drawTorus(
        at.child(_V.zero, rx: math.pi / 2, sx: ring2, sy: ring2),
        0.35,
        0.04,
        _Colors.streamCore,
        opacity: 0.85,
      );
    final drop = _alpha(_Colors.streamCore, 0.9);
    for (var d = 0; d < 12; d++) {
      final angle = d / 12 * math.pi * 2 + t * 3;
      final reach = 0.3 + (d % 3) * 0.15 + math.sin(t * 10 + d) * 0.08;
      final speed = 8 + (d % 4) * 3;
      g.dot(
        at(
          math.cos(angle) * reach,
          (math.sin(t * speed + d * 0.5)).abs() * 0.5,
          math.sin(angle) * reach,
        ),
        0.04,
        drop,
      );
    }
  }

  /// The bucket (open, with a rim band and a handle) or the washing basin
  /// (open, with the clothes at step 4), and the water filling them. The
  /// water (waterMat, opacity 0.35) is drawn at 0.5 so its level reads.
  void _paintVessel(_Gfx g, _Vessel v, double t) {
    final s = scene;
    final xf = _Xf.at(v.pos);
    if (v.grab == _Grab.bucket) {
      g
        ..drawCylinder(
          xf.child(const _V(0, 1.5, 0)),
          1.5,
          1.2,
          3,
          _Colors.bucket,
          ends: _Ends.open,
          segments: 32,
          inside: () {
            if (v.waterShown) _vesselWater(g, xf, 1.4 + 1.3 * v.fill, 1.4);
          },
        )
        // The rib CylinderGeometry(1.53, 1.53, 0.15) at 2.8 as a band (its
        // caps would lid the bucket).
        ..drawBand(
          xf.child(const _V(0, 2.8, 0)),
          1.53,
          1.53,
          0.15,
          _Colors.metal,
        )
        // Handle: half TorusGeometry(1.45, 0.06) at 3.0, tipped 0.3.
        ..drawTorus(
          xf.child(const _V(0, 3, 0), rx: 0.3),
          1.45,
          0.06,
          _Colors.metal,
          arc: math.pi,
        );
      return;
    }
    g.drawCylinder(
      xf.child(const _V(0, 0.75, 0)),
      2.5,
      2.0,
      1.5,
      _Colors.basin,
      ends: _Ends.open,
      segments: 40,
      inside: () {
        if (v.waterShown) _vesselWater(g, xf, 0.7 + 0.6 * v.fill, 2.4);
        if (!s.basinCloth) return;
        // `basinClothMesh` CylinderGeometry(1.4, 1.6, 0.6) at 1.1, squashed
        // and bouncing while scrubbed.
        final scrub = s.washing;
        final k = math.sin(t * 8);
        g.drawCylinder(
          xf.child(
            _V(0, 1.1 + (scrub ? k.abs() * 0.12 : 0), 0),
            sx: scrub ? 1 + k * 0.18 : 1,
            sy: scrub ? 1 - k * 0.18 : 1,
            sz: scrub ? 1 + math.cos(t * 8) * 0.18 : 1,
          ),
          1.4,
          1.6,
          0.6,
          _Colors.clothes,
        );
      },
    );
  }

  /// A container's water surface at height [top] (radius [r]).
  void _vesselWater(_Gfx g, _Xf xf, double top, double r) {
    final surface = xf.child(_V(0, top, 0), rx: -math.pi / 2);
    g
      ..drawDisc(surface, r, _Colors.vesselWater, opacity: 0.5)
      ..drawTorus(surface, r * 0.97, 0.03, _Colors.white, opacity: 0.35);
  }

  /// The boy (`characterS1`): shoes, legs, pelvis, torso, neck, head with
  /// hair, eyes and smile, and two jointed arms; the toothbrush in his
  /// right hand at steps 1–2.
  void _paintBoy(_Gfx g) {
    final s = scene;
    final pose = s.pose();
    final body = _Xf.at(pose.pos).child(_V.zero, ry: pose.yaw);
    for (final side in const [-1.0, 1.0]) {
      g
        ..box(
          body.child(_V(side * 0.7, 0.3, 0.2)),
          const _V(1.1, 0.6, 1.8),
          _Colors.shoe,
        )
        ..cylinder(
          body.child(_V(side * 0.7, 2.2, 0)),
          0.45,
          0.45,
          3.2,
          _Colors.pants,
        );
    }
    g
      ..box(
        body.child(const _V(0, 3.8, 0)),
        const _V(2.2, 1.0, 1.3),
        _Colors.pants,
      )
      ..box(
        body.child(_V(0, pose.torsoY, 0), rx: pose.torsoRx),
        const _V(2.4, 3.2, 1.4),
        _Colors.shirt,
      )
      ..cylinder(body.child(const _V(0, 7.6, 0)), 0.35, 0.4, 0.6, _Colors.skin);
    final head = body.child(
      _V(0, pose.headY, 0),
      rx: pose.head.x,
      ry: pose.head.y,
      rz: pose.head.z,
    );
    g.later(_cam.depth(head.o), () => _paintHead(g, head));
    _paintArm(
      g,
      body.child(
        const _V(-1.4, 7.0, 0),
        rx: pose.armL.x,
        ry: pose.armL.y,
        rz: pose.armL.z,
      ),
      pose.foreL,
    );
    _paintArm(
      g,
      body.child(
        const _V(1.4, 7.0, 0),
        rx: pose.armR.x,
        ry: pose.armR.y,
        rz: pose.armR.z,
      ),
      pose.foreR,
      brush: s.toothbrush ? pose.brushPos : null,
    );
  }

  /// An arm group: shoulder, upper arm, elbow joint with the forearm and
  /// hand; [brush] places the toothbrush in the hand.
  void _paintArm(_Gfx g, _Xf arm, _V fore, {_V? brush}) {
    g
      ..sphere(arm, 0.45, _Colors.shirt)
      ..cylinder(
        arm.child(const _V(0, -0.9, 0)),
        0.35,
        0.32,
        1.8,
        _Colors.shirt,
      );
    final forearm = arm.child(
      const _V(0, -1.8, 0),
      rx: fore.x,
      ry: fore.y,
      rz: fore.z,
    );
    g.cylinder(
      forearm.child(const _V(0, -0.8, 0)),
      0.3,
      0.28,
      1.6,
      _Colors.skin,
    );
    final hand = forearm.child(const _V(0, -1.7, 0));
    g.sphere(hand, 0.35, _Colors.skin);
    if (brush == null) return;
    final tb = hand.child(
      brush,
      rx: _brushRot.x,
      ry: _brushRot.y,
      rz: _brushRot.z,
    );
    g.later(_cam.depth(tb.at(const _V(0, 0.7, 0))), () {
      g.drawCylinder(
        tb.child(const _V(0, 0.4, 0)),
        0.06,
        0.08,
        1.2,
        _Colors.toothbrush,
        segments: 8,
      );
      final head = tb.child(const _V(0, 1.1, 0));
      final bristles = tb.child(const _V(0, 1.1, -0.15));
      void drawHead() =>
          g.drawBox(head, const _V(0.16, 0.45, 0.16), _Colors.toothbrush);
      void drawBristles() =>
          g.drawBox(bristles, const _V(0.14, 0.4, 0.2), _Colors.bristles);
      if (_cam.depth(head.o) > _cam.depth(bristles.o)) {
        drawHead();
        drawBristles();
      } else {
        drawBristles();
        drawHead();
      }
    });
  }

  /// The head: a hair cap (SphereGeometry(1.15) down to 100° from its top,
  /// tipped back 0.2) over the skull (SphereGeometry(1.1)), whose face shows
  /// below the hair line; white eyes with black pupils and a black smile.
  void _paintHead(_Gfx g, _Xf head) {
    g.drawSphere(head, 1.15, _Colors.hair);
    final axis = head.dir(_rot(_V.up, -0.2, 0, 0));
    final face = g.sphereZone(head.o, 1.1, axis, math.cos(math.pi / 1.8));
    if (face.length >= 3) {
      final path = _Gfx.polygon(face);
      final bounds = path.getBounds();
      g.canvas.drawPath(
        path,
        g.shaded(
          ui.Gradient.radial(
            bounds.center + _lightOnScreen * (bounds.shortestSide * 0.3),
            math.max(1.0, bounds.longestSide * 0.75),
            [labShade(_Colors.skin, 0.12), labShade(_Colors.skin, -0.18)],
          ),
        ),
      );
    }
    final k = (_cam.eye - head.o).unit;
    bool facing(_V p) => (p - head.o).dot(k) > 0.15;
    for (final x in const [-0.35, 0.35]) {
      final eye = head(x, 0.15, 0.95);
      if (!facing(eye)) continue;
      g
        ..dot(eye, 0.2, _Colors.white)
        ..dot(head(x, 0.15, 1.08), 0.1, _Colors.black);
    }
    final mouth = head.child(const _V(0, -0.25, 0.98), rz: math.pi);
    if (facing(mouth.o)) {
      g.drawTorus(mouth, 0.35, 0.05, _Colors.black, arc: math.pi);
    }
  }

  // ------------------------------------------------------------ scenario 2

  /// `buildScenario2Scene()`.
  void _paintRiver(_Gfx g, double t) {
    final s = scene;
    // Grassy banks: earth (earthMat) under grass (bankGrassMat).
    for (final side in const [-1.0, 1.0]) {
      g
        ..drawBox(
          _Xf.at(_V(side * _bankX, _riverY - 0.4, 0)),
          const _V(10.5, 3.2, 22),
          _Colors.earth,
          edge: 0.25,
        )
        ..drawBox(
          _Xf.at(_V(side * _bankX, _riverY + 1.6, 0)),
          const _V(10.5, 1.2, 22),
          _Colors.grass,
          edge: 0.25,
        );
    }
    // River bed (riverBedMat) and its pebbles.
    g.drawBox(
      const _Xf.at(_V(0, _riverY - 1, 0)),
      const _V(10, 1.8, 20),
      _Colors.riverBed,
      edge: 0.25,
    );
    final pebbles = [...s.pebbles]
      ..sort((a, b) => _cam.depth(b.pos).compareTo(_cam.depth(a.pos)));
    for (final p in pebbles) {
      g.drawSphere(
        _Xf.at(p.pos).child(_V.zero, sx: 1.4, sy: 0.5, sz: 1.1),
        p.r,
        labShade(_Colors.riverBed, 0.1),
      );
    }
    // Reeds at the water's edge and the fish, under the water.
    final under = <(double, VoidCallback)>[
      for (final r in s.reeds) (_cam.depth(r), () => _paintReed(g, r)),
      for (final f in s.fish) (_cam.depth(f.pos), () => _paintFish(g, f)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, draw) in under) {
      draw();
    }
    // Crystal water (crystalWaterMat) and its shimmering surface
    // (waterCausticMat).
    g.drawBox(
      const _Xf.at(_V(0, _riverY + 1.2, 0)),
      const _V(9.8, 2.4, 20),
      _Colors.crystalWater,
      opacity: 0.55,
      edge: 0,
    );
    final y = _surfaceY + math.sin(t * 3) * 0.02;
    g.canvas.drawPath(
      _Gfx.polygon([
        _cam.p(_V(-4.9, y, -10)),
        _cam.p(_V(4.9, y, -10)),
        _cam.p(_V(4.9, y, 10)),
        _cam.p(_V(-4.9, y, 10)),
      ]),
      g.fill(_alpha(_Colors.caustic, 0.3)),
    );
    // Murky water (murkyMat) spreading from the middle.
    if (s.murky) {
      g.drawBox(
        _Xf.at(
          const _V(0, _riverY + 1.25, 0),
        ).child(_V.zero, sx: s.murkyScale, sz: s.murkyScale),
        const _V(9.9, 2.48, 20.1),
        _Colors.murky,
        opacity: 0.92,
        edge: 0,
      );
    }
    // Drop zones on the grass (step 4). The HTML puts them 0.15 below the
    // grass top, where they are hidden; here they lie on it.
    for (final (shown, at) in [
      (s.recycleZone, _binPos),
      (s.signZone, _signPos),
    ]) {
      if (!shown) continue;
      g.drawDisc(
        _Xf.at(at.withY(_grassTop + 0.01)).child(_V.zero, rx: -math.pi / 2),
        3.4,
        _Colors.glowGreen,
        inner: 1.6,
        opacity: 0.35,
      );
    }
    for (var i = 0; i < _trees.length; i++) {
      final at = _trees[i];
      final scale = 0.85 + (i % 3) * 0.22;
      g.later(
        _cam.depth(at + _V(0, 2.5 * scale, 0)),
        () => _paintTree(g, at, scale),
      );
    }
    g
      ..later(_cam.depth(s.trashPos), () => _paintBasket(g))
      ..later(_cam.depth(s.pipePos), () => _paintPipe(g));
    for (final item in s.spill) {
      if (item.visible) {
        g.later(_cam.depth(item.pos), () => _paintSpill(g, item));
      }
    }
    if (s.effluent) {
      g.later(
        _cam.depth(const _V(_effluentX, 1.5, _effluentZ)),
        () => _paintEffluent(g),
      );
    }
    if (s.bubblesOn) {
      for (var i = 0; i < s.bubbles.length; i++) {
        final b = s.bubbles[i];
        final at = _V(b.x, b.y, b.z);
        final r = b.r * (1 + math.sin(t * 5 + i) * 0.15);
        g.later(
          _cam.depth(at),
          () => g.drawSphere(_Xf.at(at), r, _Colors.toxicBubble, opacity: 0.75),
        );
      }
    }
    if (s.binShown) {
      g.later(_cam.depth(_binPos + const _V(0, 1.7, 0)), () => _paintBin(g));
    }
    if (s.signShown) {
      g.later(_cam.depth(_signPos + const _V(0, 2.4, 0)), () => _paintSign(g));
    }
  }

  /// A three-tier forest tree: trunk (woodMat) and dark, mid and light green
  /// cones, scaled by [scale].
  void _paintTree(_Gfx g, _V at, double scale) {
    final tree = _Xf.at(at).child(_V.zero, sx: scale, sy: scale, sz: scale);
    g
      ..drawCylinder(
        tree.child(const _V(0, 1.1, 0)),
        0.28,
        0.42,
        2.2,
        _Colors.wood,
        segments: 8,
      )
      ..drawCylinder(
        tree.child(const _V(0, 2.4, 0)),
        0,
        1.6,
        2.0,
        _Colors.treeDark,
        segments: 8,
      )
      ..drawCylinder(
        tree.child(const _V(0, 3.5, 0)),
        0,
        1.25,
        1.8,
        _Colors.treeMid,
        segments: 8,
      )
      ..drawCylinder(
        tree.child(const _V(0, 4.4, 0)),
        0,
        0.9,
        1.5,
        _Colors.treeLight,
        segments: 8,
      );
  }

  /// A cattail: a thin stem (reedMat) with a brown head (woodMat).
  void _paintReed(_Gfx g, _V at) {
    g
      ..drawCylinder(
        _Xf.at(at + const _V(0, 1.6, 0)),
        0.04,
        0.04,
        1.5,
        _Colors.reed,
        segments: 6,
      )
      ..drawCylinder(
        _Xf.at(at + const _V(0, 2.2, 0)),
        0.08,
        0.08,
        0.5,
        _Colors.wood,
        segments: 6,
      );
  }

  /// A fish: tail fin (wagging), body with a white stripe, dorsal and side
  /// fins, eyes. The HTML stretched the body across its head–tail axis;
  /// here it is long along it (0.81 long, 0.45 high, 0.27 wide).
  void _paintFish(_Gfx g, _Fish f) {
    final xf = _Xf.at(f.pos).child(_V.zero, rx: f.roll, ry: f.yaw);
    final body = labShade(f.color, 0.08);
    final k = (_cam.eye - f.pos).unit;
    final nearSide = xf.z.dot(k) >= 0 ? 1.0 : -1.0;
    void fin(double side) => g.drawCylinder(
      xf.child(_V(0.15, -0.15, 0.35 * side), rx: math.pi / 3 * side),
      0,
      0.18,
      0.35,
      body,
      segments: 4,
    );
    fin(-nearSide);
    // Tail fin, hinged behind the body.
    final tail = xf.child(const _V(-0.55, 0, 0), ry: f.tail);
    g.canvas.drawPath(
      _Gfx.polygon([
        _cam.p(tail(0, 0, 0)),
        _cam.p(tail(-0.6, 0.38, 0)),
        _cam.p(tail(-0.48, 0, 0)),
        _cam.p(tail(-0.6, -0.38, 0)),
      ]),
      g.fill(_lit(f.color, xf.z * nearSide)),
    );
    g
      ..drawEllipsoid(xf.o, xf.x * 0.81, xf.y * 0.45, xf.z * 0.27, body)
      // White stripe round the body.
      ..drawCylinder(
        xf.child(const _V(0.08, 0, 0), rz: -math.pi / 2, sx: 0.46, sz: 0.29),
        1,
        1,
        0.25,
        _Colors.white,
        segments: 20,
      )
      // Dorsal fin (ConeGeometry(0.2, 0.45, 4)), tipped back.
      ..drawCylinder(
        xf.child(const _V(0, 0.45, 0), rz: -math.pi / 6),
        0,
        0.2,
        0.45,
        body,
        segments: 4,
      );
    fin(nearSide);
    final eye = xf(0.55, 0.15, 0.22 * nearSide);
    g
      ..dot(eye, 0.08, _Colors.white)
      ..dot(xf(0.6, 0.15, 0.25 * nearSide), 0.04, _Colors.black);
  }

  /// The open trash basket (basketMat, translucent): base, far wall, the
  /// plastic inside, near wall and rim; tipped over to spill.
  void _paintBasket(_Gfx g) {
    final s = scene;
    final at = s.trashPos;
    final xf = _Xf.at(at).child(_V.zero, rx: s.trashTilt);
    // Put into the recycling bin it sinks to y 0: the part below the grass
    // is hidden, as the HTML ground hides it.
    final sunk = _clipBelowGround(
      g.canvas,
      at.y < _grassTop + 1.25,
      _V(at.x - 1.3, _grassTop, at.z + 1.2),
      _V(at.x + 1.3, _grassTop, at.z + 1.2),
    );
    g
      ..drawCylinder(
        xf.child(const _V(0, -1.2, 0)),
        0.9,
        0.9,
        0.1,
        _Colors.basket,
        opacity: 0.6,
      )
      ..drawCylinder(
        xf,
        1.2,
        0.9,
        2.5,
        _Colors.basket,
        opacity: 0.45,
        ends: _Ends.none,
      );
    if (s.trashInside) {
      // HTML `trashInsideGroup`: a bottle, a red can, a yellow wrapper and a
      // blue carton.
      final items = <(_Xf, VoidCallback)>[];
      void add(_Xf at, VoidCallback draw) => items.add((at, draw));
      final bottle = xf.child(
        const _V(-0.3, 0.4, 0.2),
        rx: 0.4,
        ry: 0.2,
        rz: 0.5,
      );
      add(
        bottle,
        () => g.drawCylinder(
          bottle,
          0.2,
          0.2,
          0.8,
          _Colors.bottle,
          opacity: 0.7,
          segments: 12,
        ),
      );
      final can = xf.child(
        const _V(0.35, 0.3, -0.2),
        rx: -0.5,
        ry: 0.3,
        rz: -0.4,
      );
      add(
        can,
        () =>
            g.drawCylinder(can, 0.22, 0.22, 0.55, _Colors.canRed, segments: 12),
      );
      final wrapper = xf.child(const _V(0, 0.65, 0), rx: 0.2, ry: 0.8, rz: 0.3);
      add(
        wrapper,
        () => g.drawBox(wrapper, const _V(0.6, 0.35, 0.45), _Colors.wrapper),
      );
      final carton = xf.child(
        const _V(-0.2, 0, -0.3),
        rx: 0.1,
        ry: -0.4,
        rz: 0.2,
      );
      add(
        carton,
        () => g.drawBox(carton, const _V(0.45, 0.6, 0.45), _Colors.carton),
      );
      items.sort((a, b) => _cam.depth(b.$1.o).compareTo(_cam.depth(a.$1.o)));
      for (final (_, draw) in items) {
        draw();
      }
    }
    g
      ..drawBand(xf, 1.2, 0.9, 2.5, _Colors.basket, opacity: 0.5)
      ..drawTorus(
        xf.child(const _V(0, 1.25, 0), rx: math.pi / 2),
        1.2,
        0.08,
        _Colors.basket,
        opacity: 0.85,
      );
    if (sunk) g.canvas.restore();
  }

  /// Clips [canvas] to what lies above the ground line from [a] to [b] (the
  /// front edge where a sunken object meets the grass), when [when]. The
  /// caller restores the canvas when this returns true.
  bool _clipBelowGround(Canvas canvas, bool when, _V a, _V b) {
    if (!when) return false;
    final pa = _cam.p(a), pb = _cam.p(b);
    final along = pb - pa;
    final far = along.distance < 1e-6
        ? const Offset(1, 0)
        : along / along.distance;
    final left = pa - far * 2000, right = pb + far * 2000;
    canvas
      ..save()
      ..clipPath(
        _Gfx.polygon([
          left,
          right,
          Offset(right.dx, -1e4),
          Offset(left.dx, -1e4),
        ]),
      );
    return true;
  }

  /// A piece of spilled plastic (HTML `spillGeoms`), drifting.
  void _paintSpill(_Gfx g, _Spill item) {
    final (box, size, color, opacity) = _spillShapes[item.kind];
    final xf = _Xf.at(
      item.pos,
    ).child(_V.zero, rx: item.rot.x, ry: item.rot.y, rz: item.rot.z);
    if (box) {
      g.drawBox(xf, size, color, opacity: opacity);
    } else {
      g.drawCylinder(
        xf,
        size.x,
        size.x,
        size.y,
        color,
        opacity: opacity,
        segments: 14,
      );
    }
  }

  /// The industrial outfall pipe (CylinderGeometry(0.85, 0.85, 6) along x,
  /// metalMat) with its red valve wheel (TorusGeometry(0.6, 0.2)) on top. A
  /// spoke (added) shows the wheel turning.
  void _paintPipe(_Gfx g) {
    final s = scene;
    final at = s.pipePos;
    final xf = _Xf.at(at);
    // Laid at the sign it lies at y 0, half under the grass.
    final sunk = _clipBelowGround(
      g.canvas,
      at.y < _grassTop + 0.85,
      _V(at.x - 3, _grassTop, at.z + 0.83),
      _V(at.x + 3, _grassTop, at.z + 0.83),
    );
    g.drawCylinder(
      xf.child(_V.zero, rz: math.pi / 2),
      0.85,
      0.85,
      6,
      _Colors.metal,
      segments: 28,
    );
    final wheel = xf.child(const _V(0, 1, 0), rx: math.pi / 2, rz: s.valveSpin);
    g.canvas.drawLine(
      _cam.p(wheel(-0.6, 0, 0)),
      _cam.p(wheel(0.6, 0, 0)),
      g.line(
        labShade(_Colors.valve, -0.25),
        math.max(1.0, 0.16 * _cam.scaleAt(wheel.o)),
      ),
    );
    g.drawTorus(wheel, 0.6, 0.2, _Colors.valve);
    if (sunk) g.canvas.restore();
  }

  /// The dark effluent pouring from under the pipe's mouth (CylinderGeometry
  /// (0.35, 0.45, 4.2), murkyMat) down to the water.
  void _paintEffluent(_Gfx g) {
    final bottom = scene.murky ? _murkyTop : _surfaceY;
    double radius(double y) =>
        0.45 +
        (0.35 - 0.45) *
            (y - _effluentBottom) /
            (_effluentTop - _effluentBottom);
    g.drawCylinder(
      _Xf.at(_V(_effluentX, (_effluentTop + bottom) / 2, _effluentZ)),
      radius(_effluentTop),
      radius(bottom),
      _effluentTop - bottom,
      _Colors.murky,
      opacity: 0.92,
      ends: _Ends.none,
      segments: 16,
    );
  }

  /// The recycling bin: dark green body, sky-blue lid, white label panel
  /// with a green recycling ring.
  void _paintBin(_Gfx g) {
    const bin = _Xf.at(_binPos);
    g
      ..drawBox(
        bin.child(const _V(0, 1.7, 0)),
        const _V(2.6, 3.4, 2.6),
        _Colors.recycleBin,
      )
      ..drawBox(
        bin.child(const _V(0, 3.6, 0)),
        const _V(2.8, 0.45, 2.8),
        _Colors.tankSurface,
      )
      ..drawBox(
        bin.child(const _V(0, 2.1, 1.32)),
        const _V(1.8, 1.4, 0.1),
        _Colors.ceramic,
      )
      ..drawTorus(
        bin.child(const _V(0, 2.1, 1.38)),
        0.48,
        0.09,
        _Colors.glowGreen,
        opacity: 0.35,
      );
  }

  /// The Water Treatment Plant sign: two metal posts, a metal border and a
  /// sky-blue board, and a green dock ring.
  void _paintSign(_Gfx g) {
    const sign = _Xf.at(_signPos);
    for (final x in const [-1.1, 1.1]) {
      g.drawCylinder(
        sign.child(_V(x, 2.4, 0)),
        0.14,
        0.18,
        4.8,
        _Colors.metal,
        segments: 12,
      );
    }
    g
      ..drawBox(
        sign.child(const _V(0, 3.8, -0.05)),
        const _V(3.4, 2.2, 0.2),
        _Colors.metal,
      )
      ..drawBox(
        sign.child(const _V(0, 3.8, 0)),
        const _V(3.2, 2.0, 0.28),
        _Colors.tankSurface,
      )
      ..drawTorus(
        sign.child(const _V(-0.6, 1.6, 0), ry: math.pi / 2),
        0.6,
        0.18,
        _Colors.glowGreen,
        opacity: 0.35,
      );
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.label-3d` chips (`createStdLabel` / `updateOverlays()`):
  /// centred on each object's anchor (its position raised by the label's
  /// offset); chips that would overlap are pushed apart.
  void _paintLabels(Canvas canvas) {
    final s = scene;
    final items = <(String, _V)>[];
    if (s.scenario == 0) {
      items
        ..add((_t('lbl_tank'), _tankPos + const _V(0, 8, 0)))
        // HTML offset 8 puts the chip on the tap's spout; it sits just
        // above the tap so the running stream stays in view.
        ..add((_t('lbl_sink'), _sinkPos + const _V(0, _sinkLabelY, 0)));
      if (s.step == 2 && s.bucket.visible) {
        items.add((_t('lbl_bucket'), s.bucket.pos + const _V(0, 4.2, 0)));
      }
      if (s.step >= 4 && s.basin.visible) {
        items.add((_t('lbl_basin'), s.basin.pos + const _V(0, 3.2, 0)));
      }
    } else {
      items
        ..add((_t('lbl_river'), const _V(0, _riverY + 3, 0)))
        ..add((_t('lbl_trashcan'), s.trashPos + const _V(0, 3, 0)))
        ..add((_t('lbl_pipe'), s.pipePos + const _V(0, 3, 0)));
      if (s.binShown) {
        items.add((_t('lbl_recbin'), _binPos + const _V(0, 4.2, 0)));
      }
      if (s.signShown) {
        items.add((_t('lbl_treatment'), _signPos + const _V(0, 4.8, 0)));
      }
    }
    final k = labelScale;
    final chips = <(TextPainter, Rect)>[];
    for (final (text, at) in items) {
      final tp = texts.get(
        text,
        size: _labelPx * k,
        color: isDark ? _Colors.white : _Colors.slate800,
        weight: FontWeight.w700,
      );
      chips.add((
        tp,
        Rect.fromCenter(
          center: _cam.p(at),
          width: tp.width + 16 * k,
          height: tp.height + 8 * k,
        ),
      ));
    }
    chips.sort((a, b) => a.$2.top.compareTo(b.$2.top));
    for (var i = 1; i < chips.length; i++) {
      for (var j = 0; j < i; j++) {
        final a = chips[j].$2, b = chips[i].$2;
        if (!a.overlaps(b)) continue;
        chips[i] = (chips[i].$1, b.shift(Offset(0, a.bottom + 2 - b.top)));
      }
    }
    final shadow = Paint()
      ..color = LabInk.shadowSoft
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final fill = Paint()
      ..color = isDark ? _Colors.labelDark : _Colors.labelLight;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _Colors.sky400;
    for (final (tp, rect) in chips) {
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(6 * k));
      canvas
        ..drawRRect(rr.shift(const Offset(0, 1.5)), shadow)
        ..drawRRect(rr, fill)
        ..drawRRect(rr, border);
      tp.paint(canvas, rect.topLeft + Offset(8 * k, 4 * k));
    }
  }

  /// HTML `confetti()` with the Scenario 2 summary: 200 pieces burst up
  /// from 40% down the canvas, slow down, fall and fade within 3 s.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final start = s.confettiAt;
    if (start == null) return;
    final age = s.time - start;
    if (age < 0 || age > 3.2) return;
    const origin = Offset(500, 224);
    final fade = 1 - ((age - 2.2) / 1.0).clamp(0.0, 1.0);
    final travel = (1 - math.exp(-2.6 * age)) / 2.6;
    final fall = 0.5 * 520 * age * age;
    final paint = Paint();
    for (final c in s.confetti) {
      final at = origin + Offset(c.vx * travel, c.vy * travel + fall);
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(c.spin * age)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: c.size,
            height: c.size * 0.6,
          ),
          paint..color = _alpha(c.color, fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// TextPainters for the canvas labels, laid out once and reused every
/// frame. Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
  }) {
    final key = '$text|$size|${color.toARGB32()}|${weight.value}';
    return _painters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
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
