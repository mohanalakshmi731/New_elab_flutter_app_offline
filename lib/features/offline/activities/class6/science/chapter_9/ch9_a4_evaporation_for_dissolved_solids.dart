// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 9 • Activity 4
/// Evaporation for Dissolved Solids.
///
/// Native Flutter port of `Cl6S-Ch9-A4-Evaporation_for_Dissolved_Solids.html`
/// (Three.js r128 + Tween.js + canvas-confetti). The Three.js lab table is
/// redrawn in 2D by [_ScenePainter] through the HTML camera (45° field of
/// view, from (0, 15, 24) looking at (0, 3, 0)); the HTML pointer handlers
/// become a pan recogniser that only claims touches that start on the
/// object to move, and the hold-down buttons of the HTML HUD sit in a card
/// at the bottom of the canvas.
///
/// Scenario 1 (The Disappearing Water and the Magic Art, Activity 9.2): drag
/// the spoon to the salt container to pick up salt and drop it into the
/// bowl of water; hold 'Hold to Stir Solution' until the salt has
/// dissolved; drag the dropper to the bowl to fill it and over the black
/// paper to leave a wet patch; hold 'Hold to Fast-Forward Time' while the
/// patch dries to a white crust; drag the magnifying glass over it to see
/// the cubic salt crystals, then tap 'Finish Observation'.
///
/// Scenario 2 (Boiling Away the Water, Activity 9.3): drag the tripod stand
/// to the glowing spot and the wire gauze on top of it, the spirit lamp
/// under it and the glass bowl onto the gauze; drag the salt solution beaker
/// over the bowl (it tilts and pours); tap 'Ignite Spirit Lamp'; hold 'Hold
/// to Boil Away Water' while the solution bubbles, steam rises and a white
/// salt crust is left; 'Finish Observation' puts the flame out.
class Ch9A4EvaporationForDissolvedSolidsPage extends StatefulWidget {
  const Ch9A4EvaporationForDissolvedSolidsPage({super.key});

  @override
  State<Ch9A4EvaporationForDissolvedSolidsPage> createState() =>
      _EvaporationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises five Web Audio tones; each maps to the closest bundled file:
/// `click` (an object picked up, dropped or sent back) → click
/// (`science/click.mp3`); `boil` (a hold button pressed: stirring, the
/// time-lapse, boiling) → boil (`science/dropdown.mp3`); `pour` (the beaker
/// pouring, every 550 ms) → pour (`science/dropdown.mp3`); `ignite` (the
/// spirit lamp lit) → ignite (`science/page_open.mp3`); `ding` (the
/// magnifying glass placed, the summary popup) → success (`math/success.mp3`).
/// The shell plays toggle (`science/dropdown.mp3`), correct
/// (`math/success.mp3`: the added 'salt picked up' / 'dropper filled'
/// toasts), wrong (`science/error.mp3`: the added hints), scenario
/// (`science/page_open.mp3`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; HTML `click` (pick up, drop, send back).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toasts (added).
  correct('audio/class6/math/success.mp3'),

  /// Hints after a drop away from the target (added).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `ding`: the magnifying glass over the residue, the summary.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `boil`: a hold button pressed (stir, fast-forward, boil).
  boil('audio/class6/science/dropdown.mp3'),

  /// HTML `pour`: the beaker pouring.
  pour('audio/class6/science/dropdown.mp3'),

  /// HTML `ignite`: the spirit lamp lit.
  ignite('audio/class6/science/page_open.mp3');

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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (`materials`, `updateSceneTheme()`).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `scene.background` (`updateSceneTheme()`): 0x090e17 / 0xeef2f6.
  static const Color sceneDark = Color(0xFF090E17);
  static const Color sceneLight = Color(0xFFEEF2F6);

  /// `tableMat` 0x334155 / 0x64748b and `tableEdgeMat` 0x1f2937 / 0x475569.
  static const Color tableDark = slate700;
  static const Color tableLight = slate500;
  static const Color tableEdgeDark = Color(0xFF1F2937);
  static const Color tableEdgeLight = slate600;

  /// `metalMat` 0x94a3b8 (spoon scoop, lamp cap) and `darkMetalMat`
  /// 0x334155 (tripod, magnifying glass), drawn a shade darker than the
  /// table with a light edge so the tripod stands out on it.
  static const Color metal = slate400;
  static const Color darkMetal = Color(0xFF263244);
  static const Color darkMetalEdge = Color(0xFF64748B);

  /// `wireMat` 0xcbd5e1 (the wire gauze).
  static const Color wire = slate300;

  /// `glassMat` 0xb3e0ff (opacity 0.42) / 0xddeeff (0.55) and
  /// `glassRimMat` 0x7dd3fc (0.75).
  static const Color glassDark = Color(0xFFB3E0FF);
  static const Color glassLight = Color(0xFFDDEEFF);
  static const Color glassRim = sky300;

  /// `waterMat` 0x0ea5e9 / 0x0284c7 (opacity 0.78) and `waterStreamMat`
  /// 0x38bdf8 / 0x0284c7 (0.88).
  static const Color waterDark = sky500;
  static const Color waterLight = sky600;
  static const Color streamDark = sky400;
  static const Color streamLight = sky600;

  /// `saltMat` 0xffffff, its shading, and the crystal faces of the residue.
  static const Color salt = white;
  static const Color saltShade = Color(0xFFDDE5EE);
  static const Color saltEdge = Color(0xFFB8C4D2);

  /// `flameMat` 0xfab105 and the flame's hot core (added).
  static const Color flame = Color(0xFFFAB105);
  static const Color flameCore = Color(0xFFFFF3C4);
  static const Color flameGlow = orange500;

  /// `blackPaperMat` 0x1e293b and the wet patch 0x475569.
  static const Color paper = slate800;
  static const Color patch = slate600;

  /// `glowMat` 0x38bdf8 (opacity 0.35): the drop zones; and the
  /// `update3DHighlight()` pulse colour 0x38bdf8.
  static const Color zone = sky400;
  static const Color highlight = sky400;

  /// `spoonMat` 0xa78bfa, `blueLidMat` 0x3b82f6, `jarBodyMat` 0xf8fafc.
  static const Color spoon = Color(0xFFA78BFA);
  static const Color blueLid = Color(0xFF3B82F6);
  static const Color jarBody = Color(0xFFF8FAFC);

  /// Lamp wick (added: the HTML flame stood on the metal cap).
  static const Color wick = Color(0xFFE7E5E4);

  /// Steam particles (white, opacity 0.4).
  static const Color steam = white;

  /// Soft contact shadows (added).
  static const Color shadow = Color(0x4D000000);

  /// `createStdLabel`: glass chip (white/80 or slate-900/80), slate-300 /
  /// slate-700 border, slate-700 / slate-300 bold text.
  static const Color labelLight = Color(0xCCFFFFFF);
  static const Color labelDark = Color(0xCC0F172A);
  static const Color labelBorderLight = slate300;
  static const Color labelBorderDark = slate700;
  static const Color labelTextLight = slate700;
  static const Color labelTextDark = slate300;

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
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xF20F172A), // sidebar dark:bg-slate-900
    border: Color(0xD9334155), // --glass-border rgba(51, 65, 85, 0.85)
    card: Color(0xCC1E293B), // current step dark:bg-slate-800
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.sky500, // text-sky-500 headings, sky buttons
    onAccent: _Colors.slate950, // current step badge text-slate-950
    primary: _Colors.sky600, // 'Next Scenario' from-sky-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // done steps dark:text-emerald-400
    popupBg: _Colors.slate900, // summary bg-slate-900
    // The HTML header is sky-600 with white text; the shell draws the title
    // in the accent colour, so the header is a dark panel instead.
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x660C4A6E), // from-sky-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC7DD3FC), // subtitle text-sky-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // tools panel dark:bg-slate-900/90
    buttonIcon: _Colors.sky500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
    labelText: _Colors.labelTextDark,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: Color(0xFFF0F4F8), // --bg-primary
    panel: Color(0xF2FFFFFF), // sidebar bg-white
    border: Color(0xD9CBD5E1), // --glass-border rgba(203, 213, 225, 0.85)
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.sky500,
    onAccent: _Colors.slate950,
    primary: _Colors.sky600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // done steps text-emerald-600
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x660C4A6E),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC7DD3FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE6FFFFFF), // tools panel bg-white/90
    buttonIcon: _Colors.sky600,
    buttonBorder: _Colors.slate300,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelLight,
    labelText: _Colors.labelTextLight,
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
// Current Task, Close, the settings and canvas-tool names, 'Step') come
// from the shell's `kLabCommonStrings`. `sN_hud_M` are the HTML `hud`
// lines, `sN_cM` / `sN_aM` / `sN_oM` the step concept, action and
// observation, `sum_sN_head` / `sum_sN` the bold heading and the text of the
// HTML `summary`. Changes: "CLICK" is "TAP" ('क्लिक करें' → 'टैप करें'); the
// Hindi texts quote the Hindi button labels where the HTML quoted the
// English ones. Keys marked "Added." are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Evaporation for Dissolved Solids',
    'app_subtitle': 'Class 6. Methods of separation in Everyday Life',
    'scen_1_opt':
        'Scenario 1: The Disappearing Water and the Magic Art (Based on Activity 9.2)',
    'scen_2_opt': 'Scenario 2: Boiling Away the Water (Based on Activity 9.3)',
    's1_desc':
        'To observe the process of slow, natural evaporation and see the salt crystals left behind from a salt solution.',
    's2_desc':
        'To use heat to rapidly evaporate water from a salt solution and recover the salt.',
    // ------------------------------------------------- scenario 1 HUD
    's1_hud_1':
        'Step 1: DRAG the spoon to the salt container to pick up some salt. DROP the salt-filled spoon into the bowl of water.',
    's1_hud_2':
        "Step 2: Hold down 'Hold to Stir Solution' to mix the solution.",
    's1_hud_3':
        'Step 3: DRAG the dropper to the bowl to fill it. DRAG the filled dropper over the black paper and TAP/DROP to create a wet patch.',
    's1_hud_4':
        "Step 4: Hold down 'Hold to Fast-Forward Time' as natural sunlight evaporates the water patch.",
    's1_hud_5':
        'Step 5: DRAG the magnifying glass over the white patch on the paper to examine it closely.',
    // Added: the HTML kept showing the Step 5 line next to 'Finish
    // Observation'.
    's1_hud_6': "TAP 'Finish Observation' to conclude!",
    // ------------------------------------------------- scenario 2 HUD
    's2_hud_1':
        'Step 1: DRAG the Tripod Stand to the designated spot, then DRAG Wire Gauze and DROP on top of the tripod.',
    's2_hud_2':
        'Step 2: DRAG Spirit Lamp under the tripod, then DRAG the Glass Bowl onto the wire gauze.',
    's2_hud_3':
        "Step 3: DRAG the beaker labeled 'Salt Solution' and TILT over the Bowl to pour.",
    's2_hud_4': "Step 4: TAP 'Ignite Spirit Lamp' to light it.",
    's2_hud_5':
        "Step 5: Hold down 'Hold to Boil Away Water' to observe the water boil away.",
    's2_hud_6':
        "Step 6: TAP 'Finish Observation' to conclude and safely extinguish the flame!",
    // ------------------------------------------------ scenario 1 steps
    's1_c1': 'Add Solute',
    's1_a1':
        'DRAG spoon to salt container to pick up salt, then DROP into the water bowl.',
    's1_o1':
        'Salt crystals are added to the water in the bowl. Solid salt particles are visible at the bottom.',
    's1_c2': 'Dissolve Solute',
    's1_a2': "Hold down 'Hold to Stir Solution' to mix the solution.",
    's1_o2':
        'As the user stirs, the salt particles visually shrink and fade until completely gone. The water becomes clear again.',
    's1_c3': 'Sample Solution',
    's1_a3':
        'DRAG dropper to fill, then DRAG over black paper to create a wet patch.',
    's1_o3':
        'A visible dark, wet-looking circular patch of salt solution appears on the black paper.',
    's1_c4': 'Natural Evaporation',
    's1_a4':
        "Hold down 'Hold to Fast-Forward Time' to simulate daytime evaporation.",
    's1_o4':
        'The wet patch on the paper visibly shrinks. A white, crystalline texture appears where the water was.',
    's1_c5': 'Inspect Residue',
    's1_a5': 'DRAG the magnifying glass over the white patch on the paper.',
    's1_o5':
        'A close-up view reveals intricate, cubic salt crystals. The water has evaporated, leaving solid salt behind.',
    // ------------------------------------------------ scenario 2 steps
    's2_c1': 'Assemble Stand',
    's2_a1':
        'DRAG tripod stand to the designated spot, then DRAG wire gauze on top.',
    's2_o1':
        'The stand for heating is correctly set up. The tripod and wire gauze snap into place.',
    's2_c2': 'Place Lamp & Bowl',
    's2_a2': 'DRAG spirit lamp under tripod, then DRAG glass bowl onto gauze.',
    's2_o2':
        'The full heating apparatus is assembled. Lamp and bowl snap into position.',
    's2_c3': 'Pour Solution',
    's2_a3':
        "DRAG the beaker labeled 'Salt Solution' over the glass bowl to pour.",
    's2_o3': 'The wide glass bowl is filled with a clear salt solution.',
    's2_c4': 'Ignite Flame',
    's2_a4': "TAP 'Ignite Spirit Lamp' to start heating.",
    's2_o4':
        'The spirit lamp is lit, and the solution begins to heat up. A flame appears.',
    's2_c5': 'Rapid Evaporation',
    's2_a5': "Hold down 'Hold to Boil Away Water' until all liquid boils off.",
    's2_o5':
        'Bubbles form, and steam rises. The water level decreases until all water turns to steam, leaving a white solid crust.',
    's2_c6': 'Identify Residue',
    's2_a6': "TAP 'Finish Observation' to extinguish flame and examine.",
    's2_o6':
        'The flame goes out. Solid salt is left in the dish. The water turned into vapor and escaped!',
    // ---------------------------------------------------------- summary
    'sum_s1_head': 'Salt Recovered by Natural Evaporation!',
    'sum_s1':
        'You performed Activity 9.2! When left in warm air, liquid solvent (water) slowly turns into invisible gas (vapor), leaving the dissolved solute (salt) behind on the paper surface!',
    'sum_s2_head': 'Rapid Evaporation Complete!',
    'sum_s2':
        'You performed Activity 9.3! Direct heating causes rapid boiling and evaporation. Water escapes as steam, leaving behind pure white salt residue in the bowl!',
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    // ---------------------------------------------------------- sidebar
    'concept_exp': 'Observation Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // ---------------------------------------------------------- buttons
    'btn_finish': 'Finish Observation',
    'btn_ignite': 'Ignite Spirit Lamp',
    'btn_boil': 'Hold to Boil Away Water',
    'btn_sun': 'Hold to Fast-Forward Time',
    'btn_stir': 'Hold to Stir Solution',
    'cnt_evap': 'Evaporation Progress: {p}%',
    'cnt_solar': 'Time Progress: {p}%',
    // HTML literal: `t.cnt_stir || "Stirring Progress: {p}%"`.
    'cnt_stir': 'Stirring Progress: {p}%',
    // ----------------------------------------------------- scene labels
    'lbl_spoon': 'Spoon',
    'lbl_salt_jar': 'Salt Container',
    'lbl_water_bowl': 'Water Bowl',
    'lbl_dropper': 'Dropper',
    'lbl_black_paper': 'Black Paper',
    'lbl_mag_glass': 'Magnifying Glass',
    'lbl_tripod': 'Tripod Stand',
    'lbl_gauze': 'Wire Gauze',
    'lbl_lamp': 'Spirit Lamp',
    'lbl_dish': 'Glass Bowl',
    'lbl_beaker': 'Salt Solution Beaker',
    // Added: hints where the HTML silently sent an object back, the two
    // halves of the drag-and-drop steps, and the screen-reader texts.
    'miss_spoon':
        'DROP the spoon on the salt container or into the water bowl.',
    'miss_dropper':
        'DROP the dropper on the water bowl or over the black paper.',
    'miss_mag':
        'DROP the magnifying glass over the white patch on the black paper.',
    'miss_tripod':
        'DROP the tripod stand on the glowing spot in the middle of the table.',
    'miss_gauze': 'DROP the wire gauze on top of the tripod stand.',
    'miss_lamp': 'DROP the spirit lamp under the tripod stand.',
    'miss_dish': 'DROP the glass bowl onto the wire gauze.',
    'miss_beaker': 'DROP the beaker over the glass bowl to pour.',
    'toast_scooped': 'Salt picked up! Now DROP the spoon into the water bowl.',
    'toast_filled': 'Dropper filled! Now DRAG it over the black paper.',
    'first_tripod': 'First DRAG the tripod stand to the designated spot.',
    'first_lamp': 'First DRAG the spirit lamp under the tripod.',
    'sem_spot': 'Designated spot',
    'scene_s1':
        'Lab table with a glass bowl of water, a salt container, a spoon, a dropper, a sheet of black paper and a magnifying glass',
    'scene_s2':
        'Lab table with a tripod stand, a wire gauze, a spirit lamp, a glass bowl and a beaker of salt solution',
  },
  'hi': {
    'app_title': 'घुलित ठोस पदार्थों के लिए वाष्पीकरण',
    'app_subtitle': 'कक्षा 6. दैनिक जीवन में पृथक्करण की विधियाँ',
    'scen_1_opt': 'परिदृश्य 1: पानी का गायब होना (क्रियाकलाप 9.2)',
    'scen_2_opt': 'परिदृश्य 2: पानी को उबालकर सुखाना (क्रियाकलाप 9.3)',
    's1_desc':
        'धीमी और प्राकृतिक वाष्पीकरण प्रक्रिया का अवलोकन करना और काले कागज पर नमक के कणों को देखना।',
    's2_desc':
        'चाइना डिश में नमक के विलयन को तेजी से गर्म करके पानी को वाष्पित करना और शुद्ध नमक प्राप्त करना।',
    's1_hud_1':
        'चरण 1: नमक के डिब्बे से चम्मच द्वारा नमक निकालें और पानी के कटोरे में डालें।',
    's1_hud_2':
        "चरण 2: घोल को तब तक हिलाने के लिए 'घोलने के लिए दबाकर रखें' दबाए रखें जब तक नमक पूरी तरह घुल न जाए।",
    's1_hud_3':
        'चरण 3: ड्रॉपर को कटोरे में ले जाकर भरें और काले कागज पर एक गीला धब्बा बनाएं।',
    's1_hud_4':
        "चरण 4: समय आगे बढ़ाने और पानी वाष्पित करने के लिए 'समय आगे बढ़ाने के लिए दबाकर रखें' दबाए रखें।",
    's1_hud_5':
        'चरण 5: कागज पर बचे सफेद अवशेष को देखने के लिए आवर्धक लेंस (मैग्निफाइंग ग्लास) को ऊपर लाएं!',
    // Added.
    's1_hud_6': "निष्कर्ष के लिए 'अवलोकन समाप्त करें' पर टैप करें!",
    's2_hud_1':
        'चरण 1: ट्राइपॉड स्टैंड को मेज पर रखें और उसके ऊपर तार की जाली (Wire Gauze) रखें।',
    's2_hud_2':
        'चरण 2: स्पिरिट लैंप को ट्राइपॉड के नीचे रखें और कांच के कटोरे को जाली के ऊपर रखें।',
    's2_hud_3':
        'चरण 3: नमक के विलयन वाले बीकर को खींचकर कांच के कटोरे में उंडेलें।',
    's2_hud_4':
        "चरण 4: बर्नर की लौ जलाने के लिए 'बर्नर की लौ जलाएँ' पर टैप करें।",
    's2_hud_5':
        "चरण 5: पानी उबलने और वाष्पित होने तक 'पानी वाष्पीकृत करने के लिए दबाकर रखें' दबाए रखें।",
    's2_hud_6':
        "चरण 6: अवलोकन समाप्त करने और लौ बुझाने के लिए 'अवलोकन समाप्त करें' पर टैप करें!",
    's1_c1': 'नमक मिलाना',
    's1_a1': 'चम्मच से नमक को पानी के कटोरे में डालें।',
    's1_o1': 'ठोस नमक के कण पानी के कटोरे के तल पर बैठ जाते हैं।',
    's1_c2': 'घोल बनाना',
    's1_a2': "'घोलने के लिए दबाकर रखें' को दबाए रखें।",
    's1_o2':
        'हिलाने पर नमक पानी में पूरी तरह घुल जाता है और पारदर्शी विलयन बनता है।',
    's1_c3': 'नमूना लेना',
    's1_a3': 'ड्रॉपर से घोल लेकर काले कागज पर डालें।',
    's1_o3': 'काले कागज पर नमक के पानी का एक गोलाकार गीला धब्बा बन जाता है।',
    's1_c4': 'प्राकृतिक वाष्पीकरण',
    's1_a4': "'समय आगे बढ़ाने के लिए दबाकर रखें' को दबाए रखें।",
    's1_o4':
        'पानी धीरे-धीरे वाष्प बनकर हवा में उड़ जाता है और सफेद रवे शेष रह जाते हैं।',
    's1_c5': 'अवलोकन',
    's1_a5': 'आवर्धक लेंस से सफेद धब्बे को ध्यान से देखें।',
    's1_o5':
        'लेंस से देखने पर नमक के घनाकार क्रिस्टल दिखाई देते हैं। पानी उड़ गया जबकि नमक शेष रहा!',
    's2_c1': 'स्टैंड तैयार करना',
    's2_a1': 'ट्राइपॉड स्टैंड और तार की जाली को सही स्थान पर रखें।',
    's2_o1':
        'ट्राइपॉड स्टैंड और जाली बर्तन को गर्म करने के लिए स्थिर आधार देते हैं।',
    's2_c2': 'लैंप और डिश रखना',
    's2_a2': 'स्पिरिट लैंप और कांच के कटोरे को जाली पर रखें।',
    's2_o2': 'चौड़ा कटोरा वाष्पीकरण के लिए अधिक सतह प्रदान करता है।',
    's2_c3': 'विलयन डालना',
    's2_a3': 'बीकर से नमक के विलयन को कटोरे में डालें।',
    's2_o3': 'पारदर्शी विलयन ऊष्मा-रोधी कांच के कटोरे में भर जाता है।',
    's2_c4': 'लौ जलाना',
    's2_a4': "'बर्नर की लौ जलाएँ' पर टैप करें।",
    's2_o4': 'ऊष्मा मिलने से विलयन का तापमान तेजी से 100°C की ओर बढ़ता है।',
    's2_c5': 'तेज वाष्पीकरण',
    's2_a5':
        "'पानी वाष्पीकृत करने के लिए दबाकर रखें' को 100% होने तक दबाए रखें।",
    's2_o5':
        'तेज उबलने से सारा पानी भाप बनकर उड़ जाता है और सफेद नमक की मोटी परत बचती है!',
    's2_c6': 'निष्कर्ष',
    's2_a6': "'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o6':
        'सीधे गर्म करने से वाष्पीकरण प्राकृतिक विधि से कहीं अधिक तेजी से होता है!',
    'sum_s1_head': 'वाष्पीकरण द्वारा नमक प्राप्त!',
    'sum_s1':
        'आपने क्रियाकलाप 9.2 किया! गर्म हवा में पानी वाष्प बनकर उड़ जाता है और घुला हुआ नमक कागज पर शेष रह जाता है।',
    'sum_s2_head': 'तेज वाष्पीकरण पूर्ण!',
    'sum_s2':
        'आपने क्रियाकलाप 9.3 किया! उबालने पर पानी भाप बनकर तेजी से उड़ जाता है और कटोरे में शुद्ध नमक शेष रह जाता है।',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'concept_exp': 'अवलोकन चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'btn_finish': 'अवलोकन समाप्त करें',
    'btn_ignite': 'बर्नर की लौ जलाएँ',
    'btn_boil': 'पानी वाष्पीकृत करने के लिए दबाकर रखें',
    'btn_sun': 'समय आगे बढ़ाने के लिए दबाकर रखें',
    'btn_stir': 'घोलने के लिए दबाकर रखें',
    'cnt_evap': 'वाष्पीकरण प्रगति: {p}%',
    'cnt_solar': 'समय प्रगति: {p}%',
    // Added: Hindi for the HTML's English-only fallback.
    'cnt_stir': 'घोलने की प्रगति: {p}%',
    'lbl_spoon': 'चम्मच',
    'lbl_salt_jar': 'नमक का डिब्बा',
    'lbl_water_bowl': 'पानी का कटोरा',
    'lbl_dropper': 'ड्रॉपर',
    'lbl_black_paper': 'काला कागज',
    'lbl_mag_glass': 'आवर्धक लेंस',
    'lbl_tripod': 'तिपाई (ट्राइपॉड)',
    'lbl_gauze': 'तार की जाली',
    'lbl_lamp': 'स्पिरिट लैंप',
    'lbl_dish': 'कांच का कटोरा',
    'lbl_beaker': 'नमक का विलयन',
    // Added.
    'miss_spoon': 'चम्मच को नमक के डिब्बे पर या पानी के कटोरे में छोड़ें।',
    'miss_dropper': 'ड्रॉपर को पानी के कटोरे पर या काले कागज के ऊपर छोड़ें।',
    'miss_mag': 'आवर्धक लेंस को काले कागज पर बने सफेद धब्बे के ऊपर छोड़ें।',
    'miss_tripod': 'तिपाई को मेज के बीच में चमकते स्थान पर छोड़ें।',
    'miss_gauze': 'तार की जाली को तिपाई के ऊपर छोड़ें।',
    'miss_lamp': 'स्पिरिट लैंप को तिपाई के नीचे छोड़ें।',
    'miss_dish': 'कांच के कटोरे को तार की जाली के ऊपर छोड़ें।',
    'miss_beaker': 'उंडेलने के लिए बीकर को कांच के कटोरे के ऊपर छोड़ें।',
    'toast_scooped': 'नमक ले लिया! अब चम्मच को पानी के कटोरे में छोड़ें।',
    'toast_filled': 'ड्रॉपर भर गया! अब इसे काले कागज के ऊपर खींचें।',
    'first_tripod': 'पहले तिपाई को निर्धारित स्थान पर खींचें।',
    'first_lamp': 'पहले स्पिरिट लैंप को तिपाई के नीचे खींचें।',
    'sem_spot': 'निर्धारित स्थान',
    'scene_s1':
        'प्रयोगशाला की मेज पर पानी का कांच का कटोरा, नमक का डिब्बा, चम्मच, ड्रॉपर, काला कागज और आवर्धक लेंस',
    'scene_s2':
        'प्रयोगशाला की मेज पर तिपाई, तार की जाली, स्पिरिट लैंप, कांच का कटोरा और नमक के विलयन का बीकर',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [5, 6];

/// The two scenarios for [lang], built from the string table (HTML
/// `ScenariosData`).
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

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `resetCamera()` (screens wider than 768 px, which every landscape
/// screen is): `camera.position.set(0, 15, 24)`, `controls.target.set(0,
/// 3, 0)`, the same in both scenarios.
const _V _eye = _V(0, 15, 24);
const _V _lookAt = _V(0, 3, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.65)`, `HemisphereLight(…, 0.55)`
/// and a key `DirectionalLight(0xffffff, 0.95)` at (12, 25, 15), folded
/// into one ambient and one key term that keep the colours readable.
const double _ambient = 0.62;
const double _diffuse = 0.5;

/// (12, 25, 15) normalised.
const _V _light = _V(0.3806, 0.7929, 0.4757);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking objects up (short drags must pick them up).
const double _dragSlop = 8;

/// A drag shorter than this (design px) is a tap (added: the HTML treated
/// a click on an object as a drop where it lay).
const double _tapSlop = 3;

/// Scene labels: 11 design px (HTML `text-[10px]`), enlarged up to 1.8x on
/// small stages so they stay readable.
const double _labelPx = 11;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Label chip padding (`px-2.5 py-1`) and corner radius (`rounded-lg`), in
/// label sizes.
const double _chipPadX = 0.95;
const double _chipPadY = 0.38;
const double _chipRadius = 0.75;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make anything jump.
const double _maxFrameStep = 0.1;

/// Time constant (s) of the stage framing as it follows the sidebar and
/// the control card.
const double _viewSmoothing = 0.07;

/// The framing may enlarge the HTML picture up to this much to fill the
/// free canvas.
const double _maxZoom = 1.35;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas while the sidebar is open (two lines, label row, padding;
/// x UI scale) and the compact floating mission card while it is collapsed
/// (phones in landscape: screens shorter than [_compactBelow], at most
/// [_compactCardMax] of the height, [_missionTop] from the top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Canvas / design px kept free around cards and stage edges.
const double _cardGap = 8;

/// The control card (HTML `#action-controls` and `#counter-badge`): padding
/// (x UI scale) and widest size.
const double _controlPad = 6;
const double _controlMaxWidth = 560;

/// Minimum time (s) between two "do this first" hints.
const double _hintPause = 1.5;

// ------------------------------------------------------------ animations

/// TWEEN.js durations: most moves 400 ms (Linear); the spoon's and the
/// dropper's dips 200 ms down and 200 ms up (`yoyo`); the spoon's tip 200 ms.
const double _moveSeconds = 0.4;
const double _dipSeconds = 0.2;
const double _tipSeconds = 0.2;

/// The beaker: lifted and tilted to 0.38π in 450 ms (Quadratic.Out), pours
/// for 2200 ms, tilts back in 450 ms and returns in 500 ms
/// (Quadratic.InOut); `playSound('pour')` every 550 ms.
const double _liftSeconds = 0.45;
const double _pourSeconds = 2.2;
const double _tiltBackSeconds = 0.45;
const double _returnSeconds = 0.5;
const double _pourSoundEvery = 0.55;
const double _pourTilt = math.pi * 0.38;

/// HTML `animate()` rates per frame at 60 fps: stirring 0.8 %, the
/// fast-forwarded day 0.6 %, boiling 0.5 %; the spoon turns 0.2 rad and the
/// steam rises 0.15 per frame between y 6 and 10.
const double _fps = 60;
const double _stirRate = 0.8 * _fps;
const double _sunRate = 0.6 * _fps;
const double _boilRate = 0.5 * _fps;
const double _spinRate = 0.2 * _fps;
const double _steamRise = 0.15 * _fps;
const double _steamBottom = 6;
const double _steamTop = 10;

/// Added: the steam keeps rising and fades out over this time once the
/// hold button is let go (the HTML froze it in the air).
const double _steamFadeSeconds = 0.6;

/// Splash rings grow 0.03 per frame from 0.2 to 1.2; the droplets run down
/// the stream `(Date.now() * 0.005 * 1.6) % 1`, i.e. 8 times a second, and
/// wobble 0.06 at `Date.now() * 0.02`.
const double _ringGrow = 0.03 * _fps;
const List<double> _ringStart = [0.1, 0.4, 0.7];
const double _dropletRate = 8;
const double _wobbleRate = 20;
const double _wobble = 0.06;

/// HTML highlight: `(sin(Date.now() * 0.008) + 1) / 2`, lerped by 0.85.
const double _pulseRate = 8;
const double _pulseMax = 0.85;

/// HTML drop test: `Math.hypot(dx, dz) < 8.0` from the target.
const double _dropRange = 8;

/// Added: a drop falls from the dropper before the wet patch appears, the
/// patch spreads, and the salt falls from the spoon into the bowl.
const double _dropFallSeconds = 0.25;
const double _spreadSeconds = 0.15;
const double _grainSeconds = 0.35;

// -------------------------------------------------------------- the table

/// `BoxGeometry(36, 1.5, 20)` at y = -0.75 (top at 0) with a 0.2 trim.
const _V _tableCenter = _V(0, -0.75, 0);
const _V _tableSize = _V(36, 1.5, 20);
const double _trimOut = 0.1;
const double _trimHeight = 0.2;

/// A carried object stays over the table.
const double _reachX = 17;
const double _reachZ = 9.5;

// ------------------------------------------------------------ scenario 1

/// `bowlS1`: an open glass hemisphere (`SphereGeometry(3.5)` upper half,
/// turned over) with its rim at y 3.5, a 0.12 rim torus, water up to y 2.4
/// (`CylinderGeometry(3.3, 3.3, 2.2)` at y 1.3) and salt
/// (`CylinderGeometry(2, 2, 0.3)` at y 0.35) on its floor.
const _V _bowlPos = _V(0, 0, 0);
const double _bowlR = 3.5;
const double _bowlRimTube = 0.12;
const double _bowlWaterTop = 2.4;
const double _saltHeapR = 1.4;
const double _saltHeapY = 0.3;

/// `saltJarS1` at (-8, 0, -2): body r 1.8, 3.5 high; blue lid r 1.9, 0.4
/// high on top.
const _V _jarPos = _V(-8, 0, -2);
const double _jarR = 1.8;
const double _jarH = 3.5;
const double _lidR = 1.9;
const double _lidH = 0.4;

/// `spoonS1` at (-5, 0.2, 3): handle `CylinderGeometry(0.15, 0.2, 4)`
/// along z centred at z = -1, scoop sphere r 0.6 scaled (0.8, 0.3, 1) at
/// z = 1.2.
const _V _spoonHome = _V(-5, 0.2, 3);
const double _handleTipR = 0.15;
const double _handleEndR = 0.2;
const double _handleFrom = -3;
const double _handleTo = 1;
const _V _scoopAt = _V(0, 0, 1.2);
const _V _scoopSize = _V(0.48, 0.18, 0.6);

/// The spoon's stops (HTML `checkDrop`): over the jar, dipped in it, over
/// the bowl and in the bowl.
const _V _overJar = _V(-8, 3.5, -2);
const _V _inJar = _V(-8, 2.5, -2);
const _V _overBowl = _V(0, 4, 0);
const _V _inBowl = _V(0, 2, 0);

/// The spoon tips the salt out at `rotation.z` π/4 and stands in the bowl
/// tilted π/4 about x. The HTML tilted it -π/4, which stood the handle in
/// the water; here the scoop goes into the water and stirs round the bowl.
const double _tipAngle = math.pi / 4;
const double _stirTilt = math.pi / 4;

/// `blackPaperS1` 6 x 0.1 x 6 at (8, 0.05, -2); the wet patch
/// `CylinderGeometry(1.5, 1.5, 0.12)` at y 0.1; the salt left
/// `BoxGeometry(1.8, 0.2, 1.8)` at y 0.15.
const _V _paperPos = _V(8, 0.05, -2);
const _V _paperSize = _V(6, 0.1, 6);
const double _patchR = 1.5;
const double _patchH = 0.12;
const double _patchY = 0.1;
const _V _residueSize = _V(1.8, 0.2, 1.8);
const double _residueY = 0.15;

/// `dropperS1` at (-1, 0.5, 5): glass tube `CylinderGeometry(0.2, 0.05,
/// 2.2)` from its tip up to y 2.2, blue bulb r 0.5 stretched 1.5 at y 2.6.
const _V _dropperHome = _V(-1, 0.5, 5);
const double _tubeTopR = 0.2;
const double _tubeTipR = 0.05;
const double _tubeH = 2.2;
const double _bulbY = 2.6;
const double _bulbR = 0.5;
const double _bulbStretch = 1.5;

/// The dropper's stops: over the bowl, dipped in it, over the paper.
const _V _dropperOverBowl = _V(0, 3, 0);
const _V _dropperInBowl = _V(0, 2, 0);
const _V _dropperOverPaper = _V(8, 3, -2);

/// `magGlassS1` at (4, 0.5, 4), lying flat: ring torus r 1.5 (tube 0.2),
/// lens r 1.4, handle r 0.25 from z 1.25 to 3.75.
const _V _magHome = _V(4, 0.5, 4);
const double _ringR = 1.5;
const double _ringTube = 0.2;
const double _lensR = 1.4;
const double _magHandleR = 0.25;
const double _magHandleFrom = 1.25;
const double _magHandleTo = 3.75;

/// Over the residue the glass hovers at the HTML height 2.5, on the line
/// of sight from the camera to the residue so that it covers it on screen
/// (the HTML held it straight above at (8, 2.5, -2), where it showed
/// beside the patch, under the paper's label).
final _V _magOverPaper = () {
  const residue = _V(8, _residueY + 0.1, -2);
  final t = (_eye.y - 2.5) / (_eye.y - residue.y);
  return _V.lerp(_eye, residue, t);
}();

/// The lens shows the crystals (added close-up) while its centre is within
/// this many lens radii of the residue on screen.
const double _lensReach = 1.15;

/// Drop zones (`glowMat` spheres): `bowlZoneS1` r 4 at (0, 1.5, 0),
/// `paperZoneS1` / `magZoneS1` r 3 at (8, 0.5, -2).
const _V _bowlZone = _V(0, 1.5, 0);
const double _bowlZoneR = 4;
const _V _paperZone = _V(8, 0.5, -2);
const double _paperZoneR = 3;

// ------------------------------------------------------------ scenario 2

/// The heating stand is built at the centre of the table; with the glass
/// bowl on top it fills this box.
const _V _standPos = _V(0, 0, 0);
const (_V, _V) _standBox = (_V(-3.4, 0, -3.4), _V(3.4, 7.3, 3.4));

/// Labels on the assembled stand: the tripod's beside its right leg, the
/// lamp's in front of its base (see [_Scene.labelPoint]).
const _V _tripodLabel = _V(4.2, 2.8, 0);
const _V _lampLabel = _V(0, 0.4, 2.6);

/// `tripodS2` at (-8, 0, -4): ring torus r 3 (tube 0.25) at y 5.5 on three
/// legs r 0.2. The legs splay out to r 3.4 at the floor (the HTML tilted
/// their tops outwards instead).
const double _tripodRingY = 5.5;
const double _tripodRingR = 3;
const double _tripodTube = 0.25;
const double _legR = 0.2;
const double _legFootR = 3.4;

/// `gauzeS2`: 6.5 x 0.1 x 6.5 wire mesh at y 5.65 on the tripod. It lies on
/// the table at [_Kind.gauze]'s home until it is dragged there (added: the
/// HTML showed it once the tripod was placed although its HUD asks to drag
/// it).
const double _gauzeY = 5.65;
const double _gauzeSide = 6.5;
const int _gauzeWires = 13;

/// `lampS2` at (8, 0, -4): glass base r 2, glass body r 2.2, neck r 0.7,
/// metal cap r 0.8 up to y 3.5; flame `ConeGeometry(0.6, 1.8)` up to y 5.1.
/// The body is drawn as a round-shouldered bottle, widest at y 1.1 (the
/// HTML sphere segment floated above its base), and a wick is added under
/// the flame.
const double _lampBaseR = 2;
const double _lampBaseH = 0.2;
const double _lampBodyR = 2.2;
const double _lampBodyY = 1.1;
const double _neckR = 0.7;
const double _neckFrom = 2.2;
const double _neckTo = 3;
const double _capR = 0.8;
const double _capFrom = 2.9;
const double _capTo = 3.5;
const double _wickR = 0.14;
const double _wickTo = 3.7;
const double _flameR = 0.6;
const double _flameTip = 5.1;

/// `dishS2` at (7, 0, 4): an open glass bowl r 3, 1.5 deep (a hemisphere
/// scaled 0.5 in y), rim torus tube 0.1; on the gauze at y 5.7. Water
/// `CylinderGeometry(2.7, 2.7, 0.8)` from y 0.1 to 0.9; the salt crust
/// `CylinderGeometry(2.5, 2.0, 0.2)` at y 0.2, drawn inside the bowl.
const double _dishY = 5.7;
const double _dishR = 3;
const double _dishDepth = 1.5;
const double _dishRimTube = 0.1;
const double _dishWaterFrom = 0.1;
const double _dishWaterH = 0.8;
const double _crustR = 1.75;
const double _crustY = 0.25;

/// `beakerS2` at (-6, 0, 4): open glass cylinder r 1.8, 4.5 high, water
/// r 1.7 from y 0.1, 3.8 high. It pours from (3.2, 9, 0) tilted 0.38π.
const double _beakerR = 1.8;
const double _beakerH = 4.5;
const double _beakerWaterR = 1.7;
const double _beakerWaterFrom = 0.1;
const double _beakerWaterH = 3.8;
const _V _pourPivot = _V(3.2, 9, 0);

/// The pour stream (`CylinderGeometry(0.18, 0.1, 2.6)`), 16 droplets
/// (r 0.1–0.16) and three splash rings (r 0.3 + i x 0.25, tube 0.04).
const double _streamTopR = 0.18;
const double _streamFootR = 0.1;
const int _dropletCount = 16;
const double _splashR = 0.3;
const double _splashStep = 0.25;

/// 15 steam particles r 0.3 (white, opacity 0.4), x and z within ±1.
const int _steamCount = 15;
const double _steamR = 0.3;

/// Drop zones: `tripodZoneS2` r 3 at (0, 3, 0), `dishZoneS2` at (0, 6, 0),
/// `beakerZoneS2` at (0, 8, 0); and one for the gauze on the tripod
/// (added).
const _V _tripodZone = _V(0, 3, 0);
const _V _gauzeZone = _V(0, 5.6, 0);
const _V _dishZone = _V(0, 6, 0);
const _V _beakerZone = _V(0, 8, 0);
const double _standZoneR = 3;

/// Added: bubbles in the boiling solution.
const int _bubbleCount = 10;

// -------------------------------------------------------------- confetti

/// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})`
/// with canvas-confetti's defaults (start velocity 45, decay 0.9, gravity
/// 1, 200 ticks), in design px.
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
  _V withY(double v) => _V(x, v, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Distance between [a] and [b] across the table (HTML `Math.hypot(dx,
/// dz)`).
double _flat(_V a, _V b) {
  final dx = a.x - b.x, dz = a.z - b.z;
  return math.sqrt(dx * dx + dz * dz);
}

/// [v] turned about z by [rz], then about x by [rx], then about the
/// vertical by [ry] (the spoon stirs round the bowl's axis).
_V _turn(_V v, double rx, double ry, double rz) {
  var x = v.x, y = v.y, z = v.z;
  if (rz != 0) {
    final c = math.cos(rz), s = math.sin(rz);
    (x, y) = (x * c - y * s, x * s + y * c);
  }
  if (rx != 0) {
    final c = math.cos(rx), s = math.sin(rx);
    (y, z) = (y * c - z * s, y * s + z * c);
  }
  if (ry != 0) {
    final c = math.cos(ry), s = math.sin(ry);
    (x, z) = (x * c + z * s, -x * s + z * c);
  }
  return _V(x, y, z);
}

/// HTML `TWEEN.Easing.Linear.None` (the default easing).
double _linear(double t) => t;

/// HTML `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => 1 - (1 - t) * (1 - t);

/// HTML `TWEEN.Easing.Quadratic.InOut`.
double _quadInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) / 2;

/// How the scene is framed on the stage: the HTML camera's picture scaled
/// by [k] (never above 1) and shifted by ([dx], [dy]) design px, so the
/// objects stay clear of the shell's cards.
@immutable
class _View {
  const _View(this.dx, this.dy, this.k);

  static const _View identity = _View(0, 0, 1);

  final double dx;
  final double dy;
  final double k;

  bool same(_View o) => dx == o.dx && dy == o.dy && k == o.k;

  _View toward(_View t, double a) {
    final v = _View(
      dx + (t.dx - dx) * a,
      dy + (t.dy - dy) * a,
      k + (t.k - k) * a,
    );
    return (v.dx - t.dx).abs() < 0.05 &&
            (v.dy - t.dy).abs() < 0.05 &&
            (v.k - t.k).abs() < 0.0005
        ? t
        : v;
  }
}

/// The HTML PerspectiveCamera (position, look-at, fov 45) as a pinhole
/// projection onto the design stage, with the stage framing applied
/// ([frame]).
class _Camera {
  factory _Camera(_V eye, _V target) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Camera._(eye, f, r, r.cross(f));
  }

  _Camera._(this.eye, this.f, this.r, this.u);

  final _V eye;

  /// Forward, right and up unit vectors.
  final _V f;
  final _V r;
  final _V u;

  /// Where the look-at point lands and the pixels per unit at depth 1.
  Offset center = _designCenter;
  double focal = _focal;

  /// Applies the stage framing [v] to the HTML camera's picture.
  void frame(_View v) {
    center = Offset(
      v.dx + _designCenter.dx * v.k,
      v.dy + _designCenter.dy * v.k,
    );
    focal = _focal * v.k;
  }

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

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

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (HTML `dragPlane`, normal (0, 1, 0) through the object).
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (p(c + _V(0, 0, radius)).dy - p(c - _V(0, 0, radius)).dy).abs() / 2;

  /// Projected ellipse of the horizontal circle of [radius] at [c].
  Rect oval(_V c, double radius) => Rect.fromCenter(
    center: p(c),
    width: 2 * radius * scaleAt(c),
    height: 2 * ellipseHalf(c, radius),
  );

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

/// The unframed HTML camera (scene layout for the framing).
final _Camera _baseCam = _Camera(_eye, _lookAt);

/// The scene objects (HTML groups and meshes the learner sees or moves).
enum _Kind {
  // Scenario 1.
  bowl('lbl_water_bowl', 4),
  jar('lbl_salt_jar', 4.5),
  paper('lbl_black_paper', 3),
  spoon('lbl_spoon', 4),
  dropper('lbl_dropper', 4.5),
  magnifier('lbl_mag_glass', 3),
  // Scenario 2.
  tripod('lbl_tripod', 6),
  gauze('lbl_gauze', 1.2),
  lamp('lbl_lamp', 4.5),
  dish('lbl_dish', 5.5),
  beaker('lbl_beaker', 4.5);

  const _Kind(this.labelKey, this.labelLift);

  /// HTML `createStdLabel(id, key, mesh, yOff)`: the label's text and how
  /// far above the object's position it floats (the gauze's is added).
  final String labelKey;
  final double labelLift;

  int get scenario => index < _Kind.tripod.index ? 0 : 1;

  /// Starting position (HTML `position.set(…)` / `userData.homePos`).
  _V get home => switch (this) {
    _Kind.bowl => _bowlPos,
    _Kind.jar => _jarPos,
    _Kind.paper => _paperPos,
    _Kind.spoon => _spoonHome,
    _Kind.dropper => _dropperHome,
    _Kind.magnifier => _magHome,
    _Kind.tripod => const _V(-8, 0, -4),
    _Kind.gauze => const _V(-14, 0.05, 2.5),
    _Kind.lamp => const _V(8, 0, -4),
    _Kind.dish => const _V(7, 0, 4),
    _Kind.beaker => const _V(-6, 0, 4),
  };

  /// Its bounding box around its position (touch box, framing).
  (_V, _V) get box => switch (this) {
    _Kind.bowl => (const _V(-3.5, 0, -3.5), const _V(3.5, 3.6, 3.5)),
    _Kind.jar => (const _V(-1.9, 0, -1.9), const _V(1.9, 3.9, 1.9)),
    _Kind.paper => (const _V(-3, -0.05, -3), const _V(3, 0.15, 3)),
    _Kind.spoon => (const _V(-0.6, -0.3, -3.2), const _V(0.6, 0.4, 1.9)),
    _Kind.dropper => (const _V(-0.5, 0, -0.5), const _V(0.5, 3.4, 0.5)),
    _Kind.magnifier => (const _V(-1.7, -0.2, -1.7), const _V(1.7, 0.3, 3.8)),
    _Kind.tripod => (const _V(-3.4, 0, -3.4), const _V(3.4, 5.8, 3.4)),
    _Kind.gauze => (const _V(-3.25, -0.05, -3.25), const _V(3.25, 0.1, 3.25)),
    _Kind.lamp => (const _V(-2.2, 0, -2.2), const _V(2.2, 3.7, 2.2)),
    _Kind.dish => (const _V(-3.1, 0, -3.1), const _V(3.1, 1.6, 3.1)),
    _Kind.beaker => (const _V(-1.9, 0, -1.9), const _V(1.9, 4.6, 1.9)),
  };

  /// Hint shown when it is let go away from its target (added).
  String get missKey => switch (this) {
    _Kind.spoon => 'miss_spoon',
    _Kind.dropper => 'miss_dropper',
    _Kind.magnifier => 'miss_mag',
    _Kind.tripod => 'miss_tripod',
    _Kind.gauze => 'miss_gauze',
    _Kind.lamp => 'miss_lamp',
    _Kind.dish => 'miss_dish',
    _Kind.beaker => 'miss_beaker',
    _ => '',
  };

  static List<_Kind> of(int scenario) => [
    for (final k in values)
      if (k.scenario == scenario) k,
  ];
}

/// One scene object: where it is and how it is turned (HTML `position`
/// and `rotation`).
class _Body {
  _Body(this.kind) : pos = kind.home;

  final _Kind kind;
  _V pos;
  double rx = 0;
  double ry = 0;
  double rz = 0;

  /// Centre of its bounding box (draw order).
  _V get center {
    final (min, max) = kind.box;
    return pos + (min + max) * 0.5;
  }

  /// A point of the spoon (local frame: handle along z) in the world.
  _V at(_V local) => pos + _turn(local, rx, ry, rz);
}

/// The three hold-down buttons of the HTML HUD (`btn-stir`, `btn-sun`,
/// `btn-boil`): rate (% per second), label, counter and icon.
enum _Hold {
  stir(_stirRate, 'btn_stir', 'cnt_stir', Icons.autorenew),
  sun(_sunRate, 'btn_sun', 'cnt_solar', Icons.wb_sunny),
  boil(_boilRate, 'btn_boil', 'cnt_evap', Icons.cloud_upload);

  const _Hold(this.rate, this.labelKey, this.counterKey, this.icon);

  final double rate;
  final String labelKey;
  final String counterKey;
  final IconData icon;
}

/// One running HTML `TWEEN.Tween`: [apply] gets the eased progress every
/// frame, [done] runs when it ends (`onComplete`).
class _Tween {
  _Tween(this.start, this.seconds, this.apply, this.ease, this.done);

  final double start;
  final double seconds;
  final void Function(double e)? apply;
  final double Function(double t) ease;
  final VoidCallback? done;
}

/// One steam particle (HTML `steamParticlesS2`).
class _Puff {
  _Puff(this.x, this.y, this.z);

  final double x;
  final double z;
  double y;
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

/// Crystal flecks on the salt left on the paper and in the bowl: (x, z)
/// within ±1 and size, made once.
final List<(double, double, double)> _flecks = () {
  final rnd = math.Random(41);
  return [
    for (var i = 0; i < 36; i++)
      (
        rnd.nextDouble() * 2 - 1,
        rnd.nextDouble() * 2 - 1,
        0.5 + rnd.nextDouble() * 0.5,
      ),
  ];
}();

/// Cubic crystals seen through the magnifying glass (added close-up): centre
/// within the lens (x, y within ±1) and size, made once.
const List<(double, double, double)> _crystals = [
  (-0.42, -0.38, 1),
  (0.12, -0.5, 0.8),
  (0.55, -0.22, 0.95),
  (-0.6, 0.12, 0.85),
  (-0.08, 0.02, 1.1),
  (0.48, 0.3, 0.9),
  (-0.32, 0.5, 0.75),
  (0.18, 0.55, 0.85),
];

/// Mutable scene read by the painter every frame (HTML `State` and the
/// Three.js objects).
class _Scene {
  _Scene() {
    final rnd = math.Random(17);
    for (var i = 0; i < _steamCount; i++) {
      steam.add(
        _Puff(
          (rnd.nextDouble() - 0.5) * 2,
          6.5 + rnd.nextDouble() * 3,
          (rnd.nextDouble() - 0.5) * 2,
        ),
      );
    }
    for (var i = 0; i < _dropletCount; i++) {
      droplets.add((0.1 + rnd.nextDouble() * 0.06, rnd.nextDouble()));
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
    load(0);
  }

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1–6).
  int step = 1;

  /// HTML `State.isAnimating`: a tween sequence is running.
  bool busy = false;

  /// An object let go away from its target is going back (its drop zone
  /// stays lit).
  bool returning = false;

  /// 'Finish Observation' was tapped (the summary was shown).
  bool finished = false;

  /// The current scenario's objects.
  final Map<_Kind, _Body> bodies = {};

  /// The object under the finger (HTML `State.activeDragTarget`).
  _Body? held;

  final List<_Tween> _tweens = [];

  /// Something came to rest since the last [takeSettled].
  bool _settled = true;

  /// The HTML camera with the stage framing ([view], easing towards
  /// [viewTarget]; [snapView] jumps there on the next layout).
  final _Camera cam = _Camera(_eye, _lookAt);
  _View view = _View.identity;
  _View viewTarget = _View.identity;
  bool snapView = true;

  // ---------------------------------------------------------- scenario 1

  /// The spoon carries salt (added: the HTML scooped and tipped in one go).
  bool spoonSalt = false;

  /// `saltInBowlS1.visible` and its `scale` while it dissolves; when the
  /// salt fell in (added: falling grains).
  bool saltInBowl = false;
  double saltScale = 1;
  double grainsAt = -1;

  /// The dropper holds salt solution (added, as for the spoon); when its
  /// drop left the tip (added).
  bool dropperFilled = false;
  double dropAt = -1;

  /// `paperPatchS1` (visible, scale as it dries; [patchSpread] as it
  /// appears) and `paperSaltS1` (visible, scale as it forms).
  bool patchShown = false;
  double patchScale = 1;
  double patchSpread = 1;
  bool residueShown = false;
  double residueScale = 0;

  // ---------------------------------------------------------- scenario 2

  /// Parts of the heating stand in place (the HTML read them from the
  /// objects' positions).
  bool tripodPlaced = false;
  bool gauzePlaced = false;
  bool lampPlaced = false;
  bool dishPlaced = false;

  /// `flameGrpS2.visible` (HTML `State.isFlameOn`).
  bool flameOn = false;

  /// `waterInDishS2` (visible, `scale.y`), `saltCrustS2` (visible, scale)
  /// and the beaker's water (`scale.y`).
  bool dishWaterShown = false;
  double dishWater = 1;
  bool crustShown = false;
  double crustScale = 0;
  double beakerWater = 1;

  /// The pour stream is running (HTML `pourStreamMeshS2.visible`), when
  /// the next `pour` tone is due, and the splash rings' scales.
  bool streaming = false;
  double nextPourSound = 0;
  final List<double> rings = [..._ringStart];
  final List<(double, double)> droplets = [];

  /// Steam particles and how visible they are (1 while boiling).
  final List<_Puff> steam = [];
  double steamFade = 0;

  // ------------------------------------------------------------- holding

  /// The hold-down button being held (HTML `State.isStirring` /
  /// `isSunEvap` / `isBoiling`); [autoHold] keeps it going to the end (a
  /// screen-reader tap).
  _Hold? holding;
  bool autoHold = false;

  /// HTML `State.evapProgress` (0–100).
  double progress = 0;

  /// Scene time of the summary's confetti, or -1.
  double confettiAt = -1;
  final List<_Confetto> confetti = [];

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    returning = false;
    finished = false;
    held = null;
    _tweens.clear();
    bodies
      ..clear()
      ..addEntries([for (final k in _Kind.of(index)) MapEntry(k, _Body(k))]);
    spoonSalt = false;
    saltInBowl = false;
    saltScale = 1;
    grainsAt = -1;
    dropperFilled = false;
    dropAt = -1;
    patchShown = false;
    patchScale = 1;
    patchSpread = 1;
    residueShown = false;
    residueScale = 0;
    tripodPlaced = false;
    gauzePlaced = false;
    lampPlaced = false;
    dishPlaced = false;
    flameOn = false;
    dishWaterShown = false;
    dishWater = 1;
    crustShown = false;
    crustScale = 0;
    beakerWater = 1;
    streaming = false;
    rings
      ..clear()
      ..addAll(_ringStart);
    steamFade = 0;
    holding = null;
    autoHold = false;
    progress = 0;
    confettiAt = -1;
    snapView = true;
    _settled = true;
  }

  _Body body(_Kind k) => bodies[k]!;

  // -------------------------------------------------------------- tweens

  /// Starts a tween of [seconds] (HTML `new TWEEN.Tween(…).to(…, ms)`).
  void tween(
    double seconds,
    void Function(double e)? apply, {
    double Function(double t) ease = _linear,
    VoidCallback? then,
  }) => _tweens.add(_Tween(time, seconds, apply, ease, then));

  /// Tweens [b] from where it is to [to].
  void move(
    _Body b,
    _V to,
    double seconds, {
    double Function(double t) ease = _linear,
    VoidCallback? then,
  }) {
    final from = b.pos;
    tween(seconds, (e) => b.pos = _V.lerp(from, to, e), ease: ease, then: then);
  }

  /// Tweens [b]'s rotation (the angles given) from what it is now.
  void rotate(
    _Body b, {
    double? rx,
    double? ry,
    double? rz,
    required double seconds,
    double Function(double t) ease = _linear,
    VoidCallback? then,
  }) {
    final x0 = b.rx, y0 = b.ry, z0 = b.rz;
    tween(
      seconds,
      (e) {
        if (rx != null) b.rx = x0 + (rx - x0) * e;
        if (ry != null) b.ry = y0 + (ry - y0) * e;
        if (rz != null) b.rz = z0 + (rz - z0) * e;
      },
      ease: ease,
      then: then,
    );
  }

  /// Runs [then] after [seconds] (HTML `setTimeout`).
  void wait(double seconds, VoidCallback then) =>
      tween(seconds, null, then: then);

  /// HTML `TWEEN.update()`: advances the running tweens and runs the
  /// `onComplete` of those that ended (which may start new ones, or reload
  /// the scenario).
  void updateTweens() {
    if (_tweens.isEmpty) return;
    for (final tw in List.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final raw = tw.seconds <= 0
          ? 1.0
          : ((time - tw.start) / tw.seconds).clamp(0.0, 1.0);
      tw.apply?.call(tw.ease(raw));
      if (raw >= 1) {
        _tweens.remove(tw);
        _settled = true;
        tw.done?.call();
      }
    }
  }

  /// True once after something came to rest (the semantics nodes re-read
  /// where things are).
  bool takeSettled() {
    final s = _settled;
    _settled = false;
    return s;
  }

  void markSettled() => _settled = true;

  // ------------------------------------------------------------- queries

  /// HTML `getNextStepDraggable()`: the object to move at this step.
  _Kind? get draggable {
    if (busy || finished) return null;
    if (scenario == 0) {
      return switch (step) {
        1 => _Kind.spoon,
        3 => _Kind.dropper,
        5 => _Kind.magnifier,
        _ => null,
      };
    }
    return switch (step) {
      1 => tripodPlaced ? _Kind.gauze : _Kind.tripod,
      2 => lampPlaced ? _Kind.dish : _Kind.lamp,
      3 => _Kind.beaker,
      _ => null,
    };
  }

  /// The hold-down button of this step (HTML `setStepState()`), hidden
  /// while an animation runs.
  _Hold? get holdKind {
    if (busy) return null;
    return counterKind;
  }

  /// The progress counter of this step (HTML `#counter-badge`).
  _Hold? get counterKind {
    if (scenario == 0) {
      return switch (step) {
        2 => _Hold.stir,
        4 => _Hold.sun,
        _ => null,
      };
    }
    return step == 5 ? _Hold.boil : null;
  }

  /// The lit drop zone (HTML `…Zone.visible`): centre and radius. It goes
  /// out as soon as a drop is accepted.
  (_V, double)? get zone {
    if (busy && !returning) return null;
    if (scenario == 0) {
      return switch (step) {
        1 => (_bowlZone, _bowlZoneR),
        3 || 5 => (_paperZone, _paperZoneR),
        _ => null,
      };
    }
    return switch (step) {
      1 => (tripodPlaced ? _gauzeZone : _tripodZone, _standZoneR),
      2 => dishPlaced ? null : (_dishZone, _standZoneR),
      3 => (_beakerZone, _standZoneR),
      _ => null,
    };
  }

  /// The pulse of the HTML highlight on the object to move (0 … 1).
  double get pulse => (math.sin(time * _pulseRate) + 1) / 2;

  /// Is [b] standing in the scenario 1 bowl (drawn between its walls)?
  bool inBowl(_Body b) =>
      b.kind != _Kind.bowl &&
      !identical(b, held) &&
      _flat(b.pos, _bowlPos) < _bowlR &&
      b.pos.y < _bowlR + 1.5;

  /// Is [b] part of the heating stand (drawn with the tripod)?
  bool mounted(_Body b) => switch (b.kind) {
    _Kind.lamp => lampPlaced,
    _Kind.gauze => gauzePlaced,
    _Kind.dish => dishPlaced,
    _ => false,
  };

  /// Where [b]'s label floats (HTML `createStdLabel`: `yOff` above it). On
  /// the assembled stand the tripod's label moves beside its right leg and
  /// the lamp's in front of its base, so they do not cover the glass bowl
  /// and the flame.
  _V labelPoint(_Body b) => switch (b.kind) {
    _Kind.tripod when tripodPlaced => b.pos + _tripodLabel,
    _Kind.lamp when lampPlaced => b.pos + _lampLabel,
    _ => b.pos + _V(0, b.kind.labelLift, 0),
  };

  /// Height of the solution's surface in the glass bowl.
  double get dishSurface =>
      body(_Kind.dish).pos.y + _dishWaterFrom + _dishWaterH * dishWater;
}

/// Pan recogniser that only joins the gesture arena for pointers that land
/// on the object to move ([canGrab]), so other drags still pan / zoom the
/// canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _EvaporationLabState extends State<Ch9A4EvaporationForDissolvedSolidsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped whenever objects or the framing come to rest: the semantics
  /// nodes re-read where things are drawn.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};

  /// The control card on the canvas, measured so the scene keeps clear of
  /// it.
  final GlobalKey _controlsKey = GlobalKey(debugLabel: 'ch9a4-controls');
  late final Ticker _ticker;

  /// Touch radius and label size in design px for the current stage scale,
  /// and the design x of the tool column (labels stay left of it).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// The control card is shown, and its last measured height.
  bool _controlsShown = false;
  double _controlsHeight = 0;
  bool _measureQueued = false;

  /// The object the current pointer holds, the scenario it was picked up
  /// in, the drag-plane offset of the grab, where the finger went down,
  /// where it is now and whether it has moved since.
  _Body? _grab;
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  Offset _downAt = Offset.zero;
  Offset _lastPointer = Offset.zero;
  bool _moved = false;

  /// Scene time of the last "do this first" hint.
  double _lastHint = -_hintPause;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// 1-based current step for the shell: the HTML `State.step` (Scenario 1
  /// reaches 6 = its 'Finish Observation' state), or the step count + 1
  /// once Scenario 2 was finished.
  int get _currentStep {
    final s = _scene;
    final n = _stepCounts[s.scenario];
    return s.finished ? math.max(s.step, n + 1) : s.step;
  }

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
    _layout.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: `TWEEN.update()`, the hold-down processes, the pour
  /// stream and the steam, then one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.updateTweens();
    _runHold(dt);
    _runPour(dt);
    _runSteam(dt);
    final before = s.view;
    s.view = s.view.toward(s.viewTarget, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    if (!before.same(s.view) && s.view.same(s.viewTarget)) s.markSettled();
    if (s.takeSettled()) _layout.value++;
    _frame.value = now;
  }

  /// HTML `animate()` while a hold-down button is held: the counter climbs
  /// and the salt dissolves (the spoon turning), the patch dries to a white
  /// crust, or the solution boils away to a salt crust.
  void _runHold(double dt) {
    final s = _scene;
    final hold = s.holding;
    if (hold == null) return;
    if (s.holdKind != hold) {
      s.holding = null;
      return;
    }
    s.progress = math.min(100, s.progress + hold.rate * dt);
    final p = s.progress / 100;
    switch (hold) {
      case _Hold.stir:
        s.body(_Kind.spoon).ry += _spinRate * dt;
        s.saltScale = math.max(0.01, 1 - p);
      case _Hold.sun:
        s
          ..patchScale = math.max(0.01, 1 - p)
          ..residueShown = true
          ..residueScale = math.min(1, p);
      case _Hold.boil:
        s
          ..dishWater = math.max(0.05, 1 - p)
          ..crustShown = true
          ..crustScale = math.min(1, p);
    }
    if (s.progress >= 100) _completeHold(hold);
  }

  /// HTML `evapProgress >= 100`: the salt is gone and the spoon goes home
  /// (400 ms) before the step moves on; the patch has dried; the water has
  /// boiled away.
  void _completeHold(_Hold hold) {
    final s = _scene;
    s
      ..holding = null
      ..autoHold = false;
    switch (hold) {
      case _Hold.stir:
        s
          ..saltInBowl = false
          ..busy = true;
        final spoon = s.body(_Kind.spoon);
        // The HTML turned `rotation.y` back to 0 from wherever the stirring
        // left it; here it finishes its last turn.
        final spin = spoon.ry % (2 * math.pi);
        spoon.ry = spin;
        s.rotate(
          spoon,
          rx: 0,
          ry: spin > math.pi ? 2 * math.pi : 0,
          rz: 0,
          seconds: _moveSeconds,
        );
        s.move(
          spoon,
          _spoonHome,
          _moveSeconds,
          then: () {
            s.busy = false;
            _advance();
          },
        );
        _refresh();
      case _Hold.sun:
        s.patchShown = false;
        _advance();
      case _Hold.boil:
        s.dishWaterShown = false;
        _advance();
    }
  }

  /// The pour stream's splash rings and its `pour` tone every 550 ms.
  void _runPour(double dt) {
    final s = _scene;
    if (!s.streaming) return;
    for (var i = 0; i < s.rings.length; i++) {
      final r = s.rings[i] + _ringGrow * dt;
      s.rings[i] = r > 1.2 ? 0.2 : r;
    }
    if (s.time >= s.nextPourSound) {
      _Sound.pour.play();
      s.nextPourSound += _pourSoundEvery;
    }
  }

  /// HTML steam: while boiling the particles rise and start again at y 6;
  /// let go, they rise on and fade out (added).
  void _runSteam(double dt) {
    final s = _scene;
    final boiling = s.holding == _Hold.boil;
    s.steamFade = boiling
        ? 1
        : math.max(0.0, s.steamFade - dt / _steamFadeSeconds);
    if (s.steamFade <= 0) return;
    for (final p in s.steam) {
      p.y += _steamRise * dt;
      if (p.y > _steamTop) p.y = _steamBottom;
    }
  }

  // ----------------------------------------------------------- scenarios

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `advanceStep()` → `setStepState()`: the next step, its counter
  /// back at 0.
  void _advance() {
    _scene
      ..step += 1
      ..progress = 0
      ..markSettled();
    _refresh();
  }

  /// Shows the toast [key] (the HTML has none; every toast is added).
  void _toast(String key, {bool isError = false, bool sound = true}) =>
      _lab.showToast(_t(key), isError: isError, sound: sound);

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears the
  /// tweens and puts every object back.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _grabScenario = -1;
    });
    _lab.resetView(sound: false);
    _layout.value++;
  }

  /// HTML `checkDrop()` for [b] let go at [at].
  void _drop(_Body b, _V at) {
    switch (b.kind) {
      case _Kind.spoon:
        _dropSpoon(b, at);
      case _Kind.dropper:
        _dropDropper(b, at);
      case _Kind.magnifier:
        _dropMagnifier(b, at);
      case _Kind.tripod || _Kind.gauze || _Kind.lamp || _Kind.dish:
        _dropOnStand(b, at);
      case _Kind.beaker:
        _dropBeaker(b, at);
      case _Kind.bowl || _Kind.jar || _Kind.paper:
        break;
    }
  }

  /// HTML `checkDrop()` miss: back home (400 ms) with a click; a hint says
  /// where it goes (added).
  void _missed(_Body b) {
    final s = _scene;
    _Sound.click.play();
    s
      ..busy = true
      ..returning = true;
    s.move(
      b,
      b.kind.home,
      _moveSeconds,
      then: () {
        s
          ..busy = false
          ..returning = false;
        _refresh();
      },
    );
    _toast(b.kind.missKey, isError: true, sound: false);
    _refresh();
  }

  // ------------------------------------------------------------ scenario 1

  /// The spoon (HTML: let go within 8 of the salt container or the bowl, it
  /// scoops salt and tips it into the bowl in one go). Its HUD asks for two
  /// drags, so here a drop at the container scoops the salt and brings the
  /// spoon back with it, and a drop at the bowl with salt tips it in; a
  /// drop at the bowl without salt still does both.
  void _dropSpoon(_Body b, _V at) {
    final s = _scene;
    final toBowl = _flat(at, _bowlPos), toJar = _flat(at, _jarPos);
    if (math.min(toBowl, toJar) >= _dropRange) {
      _missed(b);
      return;
    }
    _Sound.click.play();
    s.busy = true;
    if (s.spoonSalt && toBowl <= toJar) {
      _tipSalt(b);
    } else if (!s.spoonSalt && toJar < toBowl) {
      _scoop(
        b,
        then: () => s.move(
          b,
          _spoonHome,
          _moveSeconds,
          then: () {
            s.busy = false;
            _toast('toast_scooped');
            _refresh();
          },
        ),
      );
    } else {
      _scoop(b, then: () => _tipSalt(b));
    }
    _refresh();
  }

  /// The spoon goes over the salt container (400 ms), dips in (200 ms) and
  /// comes up with salt (200 ms).
  void _scoop(_Body b, {required VoidCallback then}) {
    final s = _scene;
    s.move(
      b,
      _overJar,
      _moveSeconds,
      then: () => s.move(
        b,
        _inJar,
        _dipSeconds,
        then: () {
          s.spoonSalt = true;
          s.move(b, _overJar, _dipSeconds, then: then);
        },
      ),
    );
  }

  /// Over the bowl (400 ms) the spoon tips (200 ms) and the salt falls in;
  /// then it goes into the bowl (400 ms) and the step moves on.
  void _tipSalt(_Body b) {
    final s = _scene;
    s.move(
      b,
      _overBowl,
      _moveSeconds,
      then: () => s.rotate(
        b,
        rz: _tipAngle,
        seconds: _tipSeconds,
        then: () {
          s
            ..spoonSalt = false
            ..saltInBowl = true
            ..saltScale = 1
            ..grainsAt = s.time;
          s.rotate(b, rx: _stirTilt, rz: 0, seconds: _moveSeconds);
          s.move(
            b,
            _inBowl,
            _moveSeconds,
            then: () {
              s.busy = false;
              _advance();
            },
          );
        },
      ),
    );
  }

  /// The dropper, like the spoon: a drop at the bowl fills it and brings
  /// it back filled; filled, a drop over the black paper leaves the wet
  /// patch; empty, a drop over the paper does both (the HTML always did
  /// both).
  void _dropDropper(_Body b, _V at) {
    final s = _scene;
    final toPaper = _flat(at, _paperPos), toBowl = _flat(at, _bowlPos);
    if (math.min(toPaper, toBowl) >= _dropRange) {
      _missed(b);
      return;
    }
    _Sound.click.play();
    s.busy = true;
    if (s.dropperFilled && toPaper <= toBowl) {
      _wetPaper(b);
    } else if (!s.dropperFilled && toBowl < toPaper) {
      _fill(
        b,
        then: () => s.move(
          b,
          _dropperHome,
          _moveSeconds,
          then: () {
            s.busy = false;
            _toast('toast_filled');
            _refresh();
          },
        ),
      );
    } else {
      _fill(b, then: () => _wetPaper(b));
    }
    _refresh();
  }

  /// Over the bowl (400 ms), dipped in (200 ms), up again filled (200 ms).
  void _fill(_Body b, {required VoidCallback then}) {
    final s = _scene;
    s.move(
      b,
      _dropperOverBowl,
      _moveSeconds,
      then: () => s.move(
        b,
        _dropperInBowl,
        _dipSeconds,
        then: () {
          s.dropperFilled = true;
          s.move(b, _dropperOverBowl, _dipSeconds, then: then);
        },
      ),
    );
  }

  /// Over the paper (400 ms) a drop falls and spreads into the wet patch
  /// (added: the HTML patch just appeared) while the dropper goes home
  /// (400 ms); then the step moves on.
  void _wetPaper(_Body b) {
    final s = _scene;
    s.move(
      b,
      _dropperOverPaper,
      _moveSeconds,
      then: () {
        s
          ..dropperFilled = false
          ..dropAt = s.time;
        s.wait(_dropFallSeconds, () {
          s
            ..patchShown = true
            ..patchScale = 1
            ..patchSpread = 0;
          s.tween(_spreadSeconds, (e) => s.patchSpread = e, ease: _quadOut);
        });
        s.move(
          b,
          _dropperHome,
          _moveSeconds,
          then: () {
            s.busy = false;
            _advance();
          },
        );
      },
    );
  }

  /// The magnifying glass: within 8 of the paper it glides over the white
  /// patch (400 ms, `ding`) and 'Finish Observation' appears.
  void _dropMagnifier(_Body b, _V at) {
    final s = _scene;
    if (_flat(at, _paperPos) >= _dropRange) {
      _missed(b);
      return;
    }
    _Sound.success.play();
    s.busy = true;
    s.move(
      b,
      _magOverPaper,
      _moveSeconds,
      then: () {
        s.busy = false;
        _advance();
      },
    );
    _refresh();
  }

  // ------------------------------------------------------------ scenario 2

  /// The tripod, the gauze (added drag), the lamp and the glass bowl:
  /// within 8 of the centre of the table they snap into place (400 ms).
  /// The step moves on with the gauze (step 1) and the bowl (step 2).
  void _dropOnStand(_Body b, _V at) {
    final s = _scene;
    if (_flat(at, _standPos) >= _dropRange) {
      _missed(b);
      return;
    }
    _Sound.click.play();
    s.busy = true;
    switch (b.kind) {
      case _Kind.tripod:
        s.move(
          b,
          _standPos,
          _moveSeconds,
          then: () {
            s
              ..tripodPlaced = true
              ..busy = false;
            _refresh();
          },
        );
      case _Kind.gauze:
        s.move(
          b,
          const _V(0, _gauzeY, 0),
          _moveSeconds,
          then: () {
            s
              ..gauzePlaced = true
              ..busy = false;
            _advance();
          },
        );
      case _Kind.lamp:
        s.move(
          b,
          _standPos,
          _moveSeconds,
          then: () {
            s
              ..lampPlaced = true
              ..busy = false;
            _refresh();
          },
        );
      case _Kind.dish:
        s.move(
          b,
          const _V(0, _dishY, 0),
          _moveSeconds,
          then: () {
            s
              ..dishPlaced = true
              ..busy = false;
            _advance();
          },
        );
      default:
        s.busy = false;
    }
    _refresh();
  }

  /// The beaker: within 8 of the centre it pours.
  void _dropBeaker(_Body b, _V at) {
    if (_flat(at, _standPos) >= _dropRange) {
      _missed(b);
      return;
    }
    _pour(b);
  }

  /// HTML pour: the beaker lifts over the bowl and tilts (450 ms), pours
  /// for 2200 ms (its water falls to 5 %, the bowl's rises), tilts back
  /// (450 ms) and goes home (500 ms); then the step moves on.
  void _pour(_Body b) {
    final s = _scene;
    s.busy = true;
    _Sound.pour.play();
    s.move(b, _pourPivot, _liftSeconds, ease: _quadOut);
    s.rotate(
      b,
      rz: _pourTilt,
      seconds: _liftSeconds,
      ease: _quadOut,
      then: () {
        s
          ..streaming = true
          ..dishWaterShown = true
          ..dishWater = 0.05
          ..nextPourSound = s.time + _pourSoundEvery;
        s.tween(
          _pourSeconds,
          (e) {
            s
              ..beakerWater = math.max(0.05, 1 - e * 0.95)
              ..dishWater = math.max(0.05, e);
          },
          then: () {
            s.streaming = false;
            s.rotate(b, rz: 0, seconds: _tiltBackSeconds, ease: _quadInOut);
            s.move(
              b,
              _Kind.beaker.home,
              _returnSeconds,
              ease: _quadInOut,
              then: () {
                s.busy = false;
                _advance();
              },
            );
          },
        );
      },
    );
    _refresh();
  }

  /// HTML `igniteBurner()`: the flame appears and the step moves on.
  void _ignite() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4 || s.busy) return;
    _Sound.ignite.play();
    s.flameOn = true;
    _advance();
  }

  // ------------------------------------------------------------- holding

  /// HTML `startStirring()` / `startSunEvap()` / `startBoiling()` (on
  /// pointer-down, with the `boil` tone).
  void _startHold() {
    final s = _scene;
    final hold = s.holdKind;
    if (hold == null || !_lab.isLabActive) return;
    if (s.holding == null) _Sound.boil.play();
    s.holding = hold;
  }

  /// HTML `stopStirring()` … (pointer-up or pointer-leave).
  void _stopHold() {
    final s = _scene;
    if (!s.autoHold) s.holding = null;
  }

  /// A screen-reader tap on a hold button (added): it keeps going to 100 %.
  void _autoHold() {
    _startHold();
    final s = _scene;
    if (s.holding != null) s.autoHold = true;
  }

  // ---------------------------------------------------------- conclusion

  /// HTML `triggerMainAction()`: the summary popup with 'Next Scenario'
  /// (Scenario 1) or 'Restart Entire Lab', confetti and the flame put out
  /// (Scenario 2).
  void _finish() {
    final s = _scene;
    if (s.step != 6 || s.busy) return;
    final sc = s.scenario;
    final last = sc == _stepCounts.length - 1;
    setState(() {
      s.finished = true;
      if (last) {
        s
          ..flameOn = false
          ..confettiAt = s.time;
      }
    });
    _lab.completedScenarios.add(sc);
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('success'),
        icon: Icons.check_circle,
        accent: _Colors.sky500,
        extra: Builder(
          builder: (context) => _SummaryBody(
            title: labFormat(_t('sc_complete'), {'n': sc + 1}),
            head: _t('sum_s${sc + 1}_head'),
            body: _t('sum_s${sc + 1}'),
            palette: _lab.palette,
            scale: context.labScale,
            fontScale: _lab.fontScale.clamp(0.9, 1.4),
          ),
        ),
        actions: [
          if (last)
            LabAction(
              label: _t('restart_lab'),
              icon: Icons.restart_alt,
              color: _lab.palette.primary,
              foreground: _lab.palette.onPrimary,
              onTap: _lab.requestFullReset,
            )
          else
            LabAction(
              label: _t('next_sc'),
              icon: Icons.arrow_forward,
              color: _lab.palette.primary,
              foreground: _lab.palette.onPrimary,
              sound: _Sound.scenario,
              onTap: () => _nextScenario(sc),
            ),
        ],
      ),
    );
  }

  /// HTML 'Next Scenario': `closeSummary()` and `changeScenario(2)`.
  void _nextScenario(int from) {
    _lab.hidePopup(sound: false);
    if (_scene.scenario == from) _loadScenario(from + 1);
  }

  /// HTML `#btn-ignite` (Scenario 2 step 4) and `#btn-action-main`
  /// ('Finish Observation', step 6 of both scenarios).
  List<LabAction> _actions() {
    final s = _scene;
    if (!_lab.isLabActive || s.busy) return const [];
    if (s.scenario == 1 && s.step == 4) {
      return [
        LabAction(
          label: _t('btn_ignite'),
          icon: Icons.local_fire_department,
          color: _Colors.orange600,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _ignite,
        ),
      ];
    }
    if (s.step == 6) {
      return [
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.check,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: !s.finished,
          silent: true,
          onTap: _finish,
        ),
      ];
    }
    return const [];
  }

  // -------------------------------------------------------------- gestures

  /// Where [b] is drawn, widened to a finger-sized target.
  Rect _hitRect(_Body b) {
    final (min, max) = b.kind.box;
    return _scene.cam.boxRect(b.pos + min, b.pos + max).inflate(_touch);
  }

  /// HTML `pointerdown` raycast: only the object to move at this step, not
  /// while an animation plays (HTML `State.isAnimating`).
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grab != null || s.busy || s.finished) {
      return false;
    }
    final p = event.localPosition;
    final k = s.draggable;
    if (k != null && _hitRect(s.body(k)).contains(p)) return true;
    _firstHint(p);
    return false;
  }

  /// A press on the glass bowl before the lamp is under the tripod, or on
  /// the gauze before the tripod is in place, says what comes first
  /// (added: the HTML ignored it).
  void _firstHint(Offset p) {
    final s = _scene;
    if (s.scenario != 1 || s.time - _lastHint < _hintPause) return;
    String? key;
    if (s.step == 1 &&
        !s.tripodPlaced &&
        _hitRect(s.body(_Kind.gauze)).contains(p)) {
      key = 'first_tripod';
    } else if (s.step == 2 &&
        !s.lampPlaced &&
        _hitRect(s.body(_Kind.dish)).contains(p)) {
      key = 'first_lamp';
    }
    if (key == null) return;
    _lastHint = s.time;
    _toast(key, isError: true);
  }

  /// HTML `startDrag()`: picks the object up on the horizontal plane
  /// through it (with a click).
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final k = s.draggable;
    if (k == null || _grab != null) return;
    final b = s.body(k);
    final hit = s.cam.onPlaneY(d.localPosition, b.pos.y);
    _grabOffset = hit == null
        ? _V.zero
        : _V(hit.x - b.pos.x, 0, hit.z - b.pos.z);
    _grab = b;
    _grabScenario = s.scenario;
    _downAt = d.localPosition;
    _lastPointer = d.localPosition;
    _moved = false;
    s.held = b;
    _Sound.click.play();
  }

  /// HTML `pointermove`: the object follows the finger on its plane (kept
  /// over the table).
  void _onDragUpdate(DragUpdateDetails d) {
    final b = _grab;
    final s = _scene;
    if (b == null || _grabScenario != s.scenario) return;
    _lastPointer = d.localPosition;
    if ((d.localPosition - _downAt).distance > _tapSlop) _moved = true;
    final hit = s.cam.onPlaneY(d.localPosition, b.pos.y);
    if (hit == null) return;
    b.pos = _V(
      (hit.x - _grabOffset.x).clamp(-_reachX, _reachX),
      b.pos.y,
      (hit.z - _grabOffset.z).clamp(-_reachZ, _reachZ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` → `checkDrop()`. A tap without a drag says where to
  /// take the object (added: the HTML dropped it where it lay, which
  /// counted as a drop on its target).
  void _release() {
    final b = _grab;
    final scenario = _grabScenario;
    _grab = null;
    _grabScenario = -1;
    final s = _scene;
    if (b == null || scenario != s.scenario) return;
    s
      ..held = null
      ..markSettled();
    if (!_moved) {
      _toast(b.kind.missKey, sound: false);
      return;
    }
    _drop(b, _dropPoint(b, _lastPointer));
  }

  /// Where [b] counts as let go: with the finger over one of its targets as
  /// drawn (the salt container, the bowl, the paper, the tripod with what
  /// stands on it, the glass bowl), that target's position; otherwise where
  /// [b] is. Added: the HTML only measured the object's position on its
  /// drag plane, so the gauze or the glass bowl carried up onto the tripod
  /// by eye landed far behind it.
  _V _dropPoint(_Body b, Offset pointer) {
    final s = _scene;
    final cam = s.cam;
    final targets = switch (b.kind) {
      _Kind.spoon => const [_Kind.jar, _Kind.bowl],
      _Kind.dropper => const [_Kind.bowl, _Kind.paper],
      _Kind.magnifier => const [_Kind.paper],
      _Kind.gauze || _Kind.lamp || _Kind.dish => const [_Kind.tripod],
      _Kind.beaker => const [_Kind.dish],
      _ => const <_Kind>[],
    };
    for (final k in targets) {
      final t = s.body(k);
      final (min, max) = k == _Kind.tripod ? _standBox : k.box;
      if (cam.boxRect(t.pos + min, t.pos + max).contains(pointer)) {
        return t.pos;
      }
    }
    final zone = s.zone;
    if (b.kind == _Kind.tripod &&
        zone != null &&
        Rect.fromCircle(
          center: cam.p(zone.$1),
          radius: zone.$2 * cam.scaleAt(zone.$1),
        ).contains(pointer)) {
      return _standPos;
    }
    return b.pos;
  }

  /// A screen-reader tap on the object to move (added): it goes to its
  /// next target as if dragged there.
  void _activate(_Kind k) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null || s.draggable != k) return;
    final target = switch (k) {
      _Kind.spoon => s.spoonSalt ? _bowlPos : _jarPos,
      _Kind.dropper => s.dropperFilled ? _paperPos : _bowlPos,
      _Kind.magnifier => _paperPos,
      _ => _standPos,
    };
    _drop(s.body(k), target);
  }

  // --------------------------------------------------------------- framing

  /// Height of the control card before it was measured: a 48 dp button
  /// and the card's padding.
  double _controlEstimate(double s) =>
      math.max(kMinInteractiveDimension, 36 * s) + 2 * _controlPad * s;

  /// Space below the control card: the shell's HUD chip (sidebar open).
  double _controlsBottom(double s, EdgeInsets pad) =>
      _cardGap + pad.bottom + (_lab.isSidebarOpen ? _hudBand * s + 4 : 0);

  /// Measures the control card after this frame; a new height re-frames
  /// the scene.
  void _scheduleMeasure() {
    if (_measureQueued) return;
    _measureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureQueued = false;
      if (!mounted) return;
      final box = _controlsKey.currentContext?.findRenderObject();
      final h = _controlsShown && box is RenderBox && box.hasSize
          ? box.size.height
          : 0.0;
      if ((h - _controlsHeight).abs() > 0.5) {
        setState(() => _controlsHeight = h);
      }
    });
  }

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// shell card covers: the tool column, the HUD chip (sidebar open), the
  /// control card and the floating mission card (sidebar collapsed: the
  /// scene moves to its right or, on a phone, below it). Returns the
  /// framing in design px for a canvas of [canvas] dp at stage scale [fit].
  _View _framing(BuildContext context, Size canvas, double fit) {
    final stage = Offset(
      (canvas.width - _design.width * fit) / 2,
      (canvas.height - _design.height * fit) / 2,
    );
    Rect toDesign(Rect r) => Rect.fromLTRB(
      (r.left - stage.dx) / fit,
      (r.top - stage.dy) / fit,
      (r.right - stage.dx) / fit,
      (r.bottom - stage.dy) / fit,
    );
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final s = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    var bottom = _cardGap + pad.bottom + (open ? _hudBand * s : 0);
    if (_controlsShown) {
      bottom +=
          (_controlsHeight > 0 ? _controlsHeight : _controlEstimate(s)) +
          _cardGap;
    }
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _cardGap + pad.top,
      canvas.width - insets.right,
      canvas.height - bottom,
    );
    final frees = <Rect>[
      if (open || !_lab.isLabActive)
        base
      else ...[
        Rect.fromLTRB(insets.left, base.top, base.right, base.bottom),
        Rect.fromLTRB(
          base.left,
          size.height < _compactBelow
              ? math.max(
                  base.top,
                  _missionTop +
                      pad.top +
                      size.height * _compactCardMax +
                      _cardGap,
                )
              : canvas.height,
          base.right,
          base.bottom,
        ),
      ],
    ];
    final stageRect = (Offset.zero & _design).deflate(_cardGap);
    return _fitView(_focusRect(), [
      for (final r in frees) toDesign(r).intersect(stageRect),
    ]);
  }

  /// Bounds (unframed design px) of what the learner touches and reads in
  /// the current scenario: the objects at their places, where they go, and
  /// their labels.
  Rect _focusRect() {
    _cache.prepare(_lab.lang, _labelSize, _lab.isDark);
    final cam = _baseCam;
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    void body(_Kind k, [_V? at]) {
      final p = at ?? k.home;
      final (min, max) = k.box;
      add(cam.boxRect(p + min, p + max));
    }

    void chip(_V at, String key) {
      final size = _cache.chipSize(_t(key));
      add(
        Rect.fromCenter(
          center: cam.p(at),
          width: size.width,
          height: size.height,
        ),
      );
    }

    final sc = _scene.scenario;
    for (final k in _Kind.of(sc)) {
      body(k);
      chip(k.home + _V(0, k.labelLift, 0), k.labelKey);
    }
    if (sc == 0) {
      body(_Kind.spoon, _overBowl);
      body(_Kind.dropper, _dropperOverPaper);
      body(_Kind.magnifier, _magOverPaper);
      chip(_magOverPaper + const _V(0, 3, 0), 'lbl_mag_glass');
    } else {
      // The heating stand with the bowl on top, its labels, the steam and
      // the beaker pouring.
      add(
        cam.boxRect(
          const _V(-_legFootR, 0, -_legFootR),
          const _V(_legFootR, _dishY + _dishDepth, _legFootR),
        ),
      );
      chip(const _V(0, _dishY + 5.5, 0), 'lbl_dish');
      chip(_tripodLabel, 'lbl_tripod');
      chip(_lampLabel, 'lbl_lamp');
      add(cam.boxRect(const _V(-1, _steamBottom, -1), const _V(1, 10, 1)));
      add(cam.boxRect(const _V(-1.7, 7.3, -1.9), const _V(3.9, 10.5, 1.9)));
    }
    return r ?? Offset.zero & _design;
  }

  /// The framing that shows [focus] as large as possible (up to
  /// [_maxZoom] times the HTML size) centred in the largest of [frees].
  /// The HTML camera leaves the top of the picture empty, so the scene is
  /// enlarged into the free canvas where there is room.
  static _View _fitView(Rect focus, List<Rect> frees) {
    _View? best;
    var bestK = -1.0;
    for (final free in frees) {
      if (free.width <= 0 || free.height <= 0) continue;
      final k = math.min(
        _maxZoom,
        math.min(free.width / focus.width, free.height / focus.height),
      );
      if (k > bestK + 1e-6) {
        best = _View(
          free.center.dx - focus.center.dx * k,
          free.center.dy - focus.center.dy * k,
          k,
        );
        bestK = k;
      }
    }
    return best ?? _View.identity;
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final p = _lab.palette;
        final scene = _scene;
        final data = _scenarioData;
        final sc = scene.scenario;
        final n = data.steps.length;
        final step = _currentStep;
        final actions = _actions();
        // The tap buttons also float on the canvas while the sidebar is
        // open (its copy can be below the fold on a phone); with the sidebar
        // collapsed the mission card carries them. The hold buttons and the
        // counter are only on the canvas, as in the HTML HUD.
        final cardActions = _lab.isSidebarOpen ? actions : const <LabAction>[];
        final counter = scene.counterKind;
        final shown =
            _lab.isLabActive && (counter != null || cardActions.isNotEmpty);
        _controlsShown = shown;
        _scheduleMeasure();
        final insets = labOverlayInsets(context, _lab);
        final pad = MediaQuery.paddingOf(context);
        return LabShell(
          controller: _lab,
          icon: Icons.wb_twilight,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          // Scenario 1's 'Finish Observation' state has no HTML step text.
          instruction: sc == 0 && step > n ? _t('s1_hud_6') : null,
          // HTML `#hud-instruction` (`hud[State.step]`).
          hud: _t('s${sc + 1}_hud_${scene.step.clamp(1, 6)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch9a4-steps-$sc-$step'),
            steps: data.steps,
            current: step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
          overlays: [
            // HTML `#action-controls` and `#counter-badge`, at the bottom of
            // the canvas above the HUD chip. A full-size layer (not a
            // movable card) so a hold is never taken for a card drag.
            if (shown)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: _lab.isSidebarOpen ? 12 : insets.left,
                    right: insets.right,
                    bottom: _controlsBottom(s, pad),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _ControlCard(
                      key: _controlsKey,
                      palette: p,
                      scale: s,
                      frame: _frame,
                      counter: counter,
                      counterText: () => labFormat(
                        _t(counter?.counterKey ?? 'cnt_evap'),
                        {'p': scene.progress.floor().clamp(0, 100)},
                      ),
                      hold: scene.holdKind,
                      holdLabel: scene.holdKind == null
                          ? ''
                          : _t(scene.holdKind!.labelKey),
                      holding: () => scene.holding != null,
                      onHoldStart: _startHold,
                      onHoldStop: _stopHold,
                      onHoldAuto: _autoHold,
                      actions: cardActions,
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
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          _labelRight = (box.maxWidth - tools - stageLeft) / fit;
          final s = _scene;
          s.viewTarget = _framing(context, box.biggest, fit);
          if (s.snapView) {
            s
              ..view = s.viewTarget
              ..snapView = false
              ..markSettled();
            s.cam.frame(s.view);
          }
        }
        return LabStage(
          designSize: _design,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags on the scene are not screen-reader actions; the
                // scene and its objects are announced instead.
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
              // One semantics node per object where it is drawn (added), so
              // a screen reader can find them and tap the one to move. They
              // take no touches: those reach the scene below.
              ValueListenableBuilder<int>(
                valueListenable: _layout,
                builder: (context, _, _) => _semanticsNodes(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _semanticsNodes() {
    final s = _scene;
    final cam = s.cam;
    final drag = s.draggable;
    final zone = s.zone;
    return Stack(
      fit: StackFit.expand,
      children: [
        // The tripod's designated spot (HTML `tripodZoneS2`).
        if (s.scenario == 1 && s.step == 1 && !s.tripodPlaced && zone != null)
          Positioned.fromRect(
            rect: Rect.fromCircle(
              center: cam.p(zone.$1),
              radius: zone.$2 * cam.scaleAt(zone.$1),
            ),
            child: Semantics(
              container: true,
              label: _t('sem_spot'),
              child: const SizedBox.expand(),
            ),
          ),
        for (final b in s.bodies.values)
          Positioned.fromRect(
            rect: cam.boxRect(b.pos + b.kind.box.$1, b.pos + b.kind.box.$2),
            child: Semantics(
              container: true,
              button: b.kind == drag,
              label: _t(b.kind.labelKey),
              onTap: b.kind == drag ? () => _activate(b.kind) : null,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

/// HTML `#action-controls` and `#counter-badge`: the progress counter, the
/// hold-down button of the step and, while the sidebar is open, the tap
/// buttons ('Ignite Spirit Lamp', 'Finish Observation').
class _ControlCard extends StatelessWidget {
  const _ControlCard({
    super.key,
    required this.palette,
    required this.scale,
    required this.frame,
    required this.counter,
    required this.counterText,
    required this.hold,
    required this.holdLabel,
    required this.holding,
    required this.onHoldStart,
    required this.onHoldStop,
    required this.onHoldAuto,
    required this.actions,
  });

  final LabPalette palette;
  final double scale;

  /// Repaints the counter and the pressed button every frame.
  final ValueListenable<double> frame;
  final _Hold? counter;
  final String Function() counterText;

  /// The hold-down button (null while it is hidden).
  final _Hold? hold;
  final String holdLabel;
  final bool Function() holding;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldStop;
  final VoidCallback onHoldAuto;
  final List<LabAction> actions;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final h = hold;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _controlMaxWidth * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.all(_controlPad * s),
        borderColor: _Colors.sky500.withValues(alpha: 0.6),
        child: ValueListenableBuilder<double>(
          valueListenable: frame,
          builder: (context, _, _) => Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8 * s,
            runSpacing: 6 * s,
            children: [
              if (counter != null) _CounterBadge(text: counterText(), scale: s),
              if (h != null)
                _HoldButton(
                  label: holdLabel,
                  icon: h.icon,
                  scale: s,
                  pressed: holding(),
                  onStart: onHoldStart,
                  onStop: onHoldStop,
                  onAuto: onHoldAuto,
                ),
              for (final a in actions)
                LabActionButton(action: a, scale: s, expand: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// HTML `#counter-badge`: a sky-blue pill with an hourglass and the
/// uppercase progress text.
class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final label = text.toUpperCase();
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
          decoration: BoxDecoration(
            color: _Colors.sky500,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _Colors.sky400),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_bottom, size: 13 * s, color: _Colors.white),
              SizedBox(width: 4 * s),
              Text(
                label,
                style: TextStyle(
                  color: _Colors.white,
                  fontSize: 10.5 * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: labLetterSpacing(label, 1.2),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An HTML hold-down button (`onpointerdown` starts, `onpointerup` /
/// `onpointerleave` stops): sky gradient, white bold label, pulsing glow;
/// pressed it shrinks a little (`active:scale-95`). A screen-reader tap
/// runs it to the end.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.icon,
    required this.scale,
    required this.pressed,
    required this.onStart,
    required this.onStop,
    required this.onAuto,
  });

  final String label;
  final IconData icon;
  final double scale;
  final bool pressed;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onAuto;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: label,
      onTap: onAuto,
      child: ExcludeSemantics(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => onStart(),
          onPointerUp: (_) => onStop(),
          onPointerCancel: (_) => onStop(),
          onPointerMove: (e) {
            final size = context.size;
            if (size != null &&
                !(Offset.zero & size).contains(e.localPosition)) {
              onStop();
            }
          },
          child: AnimatedScale(
            scale: pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 100),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 18 * s,
                vertical: 6 * s,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Colors.sky600, _Colors.sky500],
                ),
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.sky400.withValues(
                      alpha: pressed ? 0.7 : 0.45,
                    ),
                    blurRadius: (pressed ? 16 : 10) * s,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17 * s, color: _Colors.white),
                  SizedBox(width: 7 * s),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
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

/// The HTML summary modal's body: a check in a sky circle, 'Scenario N
/// Complete!', the summary's bold sky-blue heading and its text, centred.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.title,
    required this.head,
    required this.body,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String title;
  final String head;
  final String body;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56 * s,
          height: 56 * s,
          decoration: BoxDecoration(
            color: _Colors.sky500.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: _Colors.sky500.withValues(alpha: 0.3)),
          ),
          child: Icon(
            Icons.check_circle,
            size: 30 * s,
            color: p.ink(_Colors.sky400),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 21 * s,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          head,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.ink(_Colors.sky400),
            fontSize: 16 * f,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
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
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task, action and result. The current step is open; every step can
/// be opened or closed (HTML `toggleAccordion`); done steps show a tick,
/// future steps are dimmed.
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
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

  Widget _body(String text, Color color, {FontWeight? weight}) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 11.5 * widget.fontScale,
      fontWeight: weight ?? FontWeight.w500,
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
    final open = _isOpen(i);
    final dim = future ? 0.6 : 1.0;
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
        border: Border.all(color: border.withValues(alpha: border.a * dim)),
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
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
                                : (past
                                      ? p.success.withValues(alpha: 0.4)
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
                  _heading(w.conceptLabel, accent),
                  SizedBox(height: 3 * s),
                  _body(step.concept, p.textStrong, weight: FontWeight.w600),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.observation, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Paints reused by every frame.
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Soft contact shadows.
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  /// Pulsing highlight behind the object to move, and the label chips'
  /// `shadow-sm`.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  final Paint chipShadow = Paint()
    ..color = const Color(0x26000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
}

/// What the painter makes once and reuses: pens and the label text
/// painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool _dark = true;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language, label size or theme
  /// changes.
  void prepare(LabLang lang, double labelSize, bool isDark) {
    if (lang == _lang && labelSize == _labelSize && isDark == _dark) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _dark = isDark;
  }

  /// HTML `.label-3d` text: bold, slate-300 (dark) or slate-700 (light).
  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _dark ? _Colors.labelTextDark : _Colors.labelTextLight,
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

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() => _disposeLabels();
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
  final k = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * k),
    green: math.min(1.0, c.g * k),
    blue: math.min(1.0, c.b * k),
  );
}

/// [c] lit by the pulsing highlight ([amount] 0 … 0.85). The HTML lerps
/// the emissive colour to sky blue, which adds to the lit colour; added at
/// 60 % here so the object stays recognisable.
Color _tint(Color c, double amount) => amount <= 0
    ? c
    : Color.from(
        alpha: c.a,
        red: math.min(1.0, c.r + _Colors.highlight.r * amount * 0.6),
        green: math.min(1.0, c.g + _Colors.highlight.g * amount * 0.6),
        blue: math.min(1.0, c.b + _Colors.highlight.b * amount * 0.6),
      );

/// Rotates [canvas] about [c] by the HTML `rotation.z` [tilt] (positive is
/// counter-clockwise on screen).
void _tiltAbout(Canvas canvas, Offset c, double tilt) {
  if (tilt == 0) return;
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-tilt);
  canvas.translate(-c.dx, -c.dy);
}

/// [d] turned like the canvas in [_tiltAbout].
Offset _tilted(Offset d, double tilt) {
  final a = -tilt;
  return Offset(
    d.dx * math.cos(a) - d.dy * math.sin(a),
    d.dx * math.sin(a) + d.dy * math.cos(a),
  );
}

/// An open bowl on screen: its rim ellipse and the lower outline (half an
/// ellipse as wide as the rim, round the same centre).
@immutable
class _Bowl {
  const _Bowl(this.rim, this.low);

  final Rect rim;
  final Rect low;

  /// The whole silhouette: the rim's far half and the lower outline.
  Path get outline => Path()
    ..moveTo(rim.left, rim.center.dy)
    ..arcTo(rim, math.pi, math.pi, false)
    ..arcTo(low, 0, math.pi, false)
    ..close();

  /// The near wall: between the rim's near half and the lower outline.
  Path get front => Path()
    ..moveTo(rim.right, rim.center.dy)
    ..arcTo(rim, 0, math.pi, false)
    ..arcTo(low, math.pi, -math.pi, false)
    ..close();
}

/// Mesh drawing in the scene camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Camera cam;
  final _Pens pens;

  Path _quad(List<Offset> pts) => Path()..addPolygon(pts, true);

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
  }) {
    final h = size * 0.5;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * h.x, c.y + n.y * h.y, c.z + n.z * h.z);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = _quad([
        for (final k in face.corners)
          cam.p(_V(c.x + k.x * h.x, c.y + k.y * h.y, c.z + k.z * h.z)),
      ]);
      canvas.drawPath(
        path,
        pens.fill..color = _lit(color, n, opacity: opacity),
      );
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.9
            ..color = (edgeColor ?? labShade(color, -0.5)).withValues(
              alpha: edge * opacity,
            ),
        );
      }
    }
  }

  /// Projected outline of an upright frustum (bottom radius [rb], top
  /// [rt], height [h]) standing on [bottom]: side plus the top ellipse.
  Path frustumPath(_V bottom, double rb, double rt, double h) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    return Path()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(cam.oval(bottom, rb), math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(cam.oval(top, rt), 0, -math.pi, false)
      ..close();
  }

  /// A solid upright cylinder / frustum, its side shaded round and its top
  /// cap lit from above.
  void frustum(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 1,
  }) {
    final path = frustumPath(bottom, rb, rt, h);
    final side = _lit(color, const _V(0, 0, 1), opacity: opacity);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            labShade(side, -0.32),
            labShade(side, 0.12),
            side,
            labShade(side, -0.4),
          ],
          stops: const [0, 0.35, 0.62, 1],
        ).createShader(path.getBounds()),
    );
    final top = cam.oval(bottom + _V(0, h, 0), rt);
    canvas.drawOval(
      top,
      pens.fill..color = _lit(color, _V.up, opacity: opacity),
    );
    canvas.drawOval(
      top,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.4).withValues(alpha: 0.5 * opacity),
    );
  }

  /// The far half of an open glass cylinder: its outline filled faintly
  /// (both walls are seen through each other).
  void cupBack(_V bottom, double rb, double rt, double h, Color fill) {
    canvas.drawPath(frustumPath(bottom, rb, rt, h), pens.fill..color = fill);
  }

  /// The near half of an open glass cylinder: a faint front pane, its side
  /// lines and base, the rim and a highlight.
  void cupFront(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color fill,
    Color edge,
  ) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final bottomOval = cam.oval(bottom, rb);
    final pane = Path()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(cam.oval(top, rt), 0, math.pi, false)
      ..close();
    canvas.drawPath(pane, pens.fill..color = fill);
    final outline = Path()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy);
    canvas.drawPath(
      outline,
      pens.stroke
        ..strokeWidth = 1.2
        ..color = edge,
    );
    // Glass highlight on the left.
    canvas.drawLine(
      Offset(pt.dx - wt * 0.62, pt.dy + 4),
      Offset(pb.dx - wb * 0.62, pb.dy - 2),
      pens.stroke
        ..strokeWidth = math.max(1.0, wb * 0.12)
        ..color = _Colors.white.withValues(alpha: 0.22),
    );
  }

  /// Liquid standing [h] high on [bottom] in a cylinder (radius [rb] at the
  /// floor, [rt] at the surface): the body and its lighter surface.
  void liquid(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 0.78,
  }) {
    if (h <= 0.01) return;
    canvas.drawPath(
      frustumPath(bottom, rb, rt, h),
      pens.fill..color = _lit(color, const _V(0, 0, 1), opacity: opacity),
    );
    canvas.drawOval(
      cam.oval(bottom + _V(0, h, 0), rt),
      pens.fill..color = labShade(color, 0.25).withValues(alpha: opacity),
    );
  }

  /// A rod (CylinderGeometry between [a] and [b], radius [ra] at [a] and
  /// [rb] at [b]), shaded across, with round ends and a light edge.
  void rod(_V a, _V b, double ra, double rb, Color color, {Color? edge}) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.8, ra * cam.scaleAt(a));
    final wb = math.max(0.8, rb * cam.scaleAt(b));
    final d = pb - pa;
    final len = d.distance;
    final lit = _lit(color, const _V(0, 0.6, 0.8));
    if (len < 0.01) {
      canvas.drawCircle(pa, math.max(wa, wb), pens.fill..color = lit);
      return;
    }
    // Across the rod, the side facing up is the lit one.
    var n = Offset(-d.dy / len, d.dx / len);
    if (n.dy > 0) n = -n;
    final path = _quad([pa + n * wa, pb + n * wb, pb - n * wb, pa - n * wa]);
    final mid = (pa + pb) / 2;
    final w = math.max(wa, wb);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(lit, 0.3), lit, labShade(lit, -0.4)],
        ).createShader(Rect.fromPoints(mid + n * w, mid - n * w)),
    );
    canvas.drawCircle(pa, wa, pens.fill..color = lit);
    canvas.drawCircle(pb, wb, pens.fill..color = labShade(lit, 0.08));
    if (edge != null) {
      canvas.drawLine(
        pa + n * wa * 0.55,
        pb + n * wb * 0.55,
        pens.stroke
          ..strokeWidth = math.max(0.7, w * 0.3)
          ..color = edge.withValues(alpha: 0.75),
      );
    }
  }

  /// Ellipse spanned by the screen axes [ax] and [by] round [c] (a flat
  /// mesh seen at an angle).
  Path axesOval(Offset c, Offset ax, Offset by) {
    final path = Path();
    for (var i = 0; i <= 32; i++) {
      final t = i / 32 * 2 * math.pi;
      final q = c + ax * math.cos(t) + by * math.sin(t);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    return path..close();
  }

  /// An open bowl of radius [r] and [depth] whose rim circle is centred at
  /// [rimC] (a hemisphere, or one squashed in y). Its lower outline is the
  /// silhouette of the ellipsoid seen from the camera's elevation.
  _Bowl bowl(_V rimC, double r, double depth) {
    final rim = cam.oval(rimC, r);
    final k = cam.scaleAt(rimC);
    final v = rimC - cam.eye;
    final sinA = (-v.y / v.length).clamp(0.0, 1.0);
    final cosA = math.sqrt(1 - sinA * sinA);
    final h = math.sqrt(depth * cosA * depth * cosA + r * sinA * r * sinA) * k;
    return _Bowl(
      rim,
      Rect.fromCenter(center: rim.center, width: rim.width, height: 2 * h),
    );
  }

  /// The liquid in such a bowl up to [surfaceY]: a smaller bowl whose rim
  /// is the liquid's surface.
  _Bowl? bowlLiquid(_V rimC, double r, double depth, double surfaceY) {
    final d = surfaceY - (rimC.y - depth);
    if (d <= 0.01) return null;
    final u = ((rimC.y - surfaceY) / depth).clamp(0.0, 1.0);
    final rw = r * math.sqrt(1 - u * u);
    return bowl(_V(rimC.x, surfaceY, rimC.z), rw, d);
  }

  /// Soft blurred shadow of a round footprint of [radius] on the table.
  void shadow(_V at, double radius) {
    final c = _V(at.x + 0.3, 0.01, at.z - 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: cam.p(c),
        width: 2.2 * radius * cam.scaleAt(c),
        height: 2.2 * cam.ellipseHalf(c, radius),
      ),
      pens.shadow,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: the lab table;
/// Scenario 1 the black paper, the salt container, the bowl of water, the
/// spoon, the dropper and the magnifying glass; Scenario 2 the tripod, the
/// wire gauze, the spirit lamp, the glass bowl and the beaker; the drop
/// zones, the floating labels and the confetti.
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

  /// Design x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  // ----------------------------------------------------- theme colours

  Color get _glass => isDark ? _Colors.glassDark : _Colors.glassLight;

  /// One glass wall (`glassMat`), the closed glass of the lamp (two walls)
  /// and the glass edges. On the light theme the edges are darker so the
  /// glassware shows on the pale scene.
  Color get _glassFill => _glass.withValues(alpha: isDark ? 0.2 : 0.3);
  Color get _glassBody => _glass.withValues(alpha: isDark ? 0.34 : 0.5);
  Color get _glassEdge => isDark
      ? _Colors.glassDark.withValues(alpha: 0.6)
      : const Color(0xD96B93B8);

  /// `glassRimMat` 0x7dd3fc (0.75); sky-600 on the light theme.
  Color get _rim =>
      (isDark ? _Colors.glassRim : _Colors.sky600).withValues(alpha: 0.75);
  Color get _water => isDark ? _Colors.waterDark : _Colors.waterLight;
  Color get _stream => isDark ? _Colors.streamDark : _Colors.streamLight;

  /// White steam, slate on the light theme (white on white would vanish).
  Color get _steam => isDark ? _Colors.steam : _Colors.slate400;

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    final s = scene;
    final g = _Gfx(canvas, s.cam, _pens);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    _paintTable(g);
    if (s.scenario == 0) {
      _paintScenario1(g);
    } else {
      _paintScenario2(g);
    }
    if (showLabels) _paintLabels(g);
    _paintConfetti(canvas);
  }

  /// `table` (36 x 1.5 x 20) and its trim: a dark band round the top edge.
  void _paintTable(_Gfx g) {
    final canvas = g.canvas;
    final cam = g.cam;
    final top = isDark ? _Colors.tableDark : _Colors.tableLight;
    final edge = isDark ? _Colors.tableEdgeDark : _Colors.tableEdgeLight;
    g.box(_tableCenter, _tableSize, top, edge: 0);
    const hx = 18 + _trimOut, hz = 10 + _trimOut;
    canvas.drawPath(
      g._quad([
        cam.p(const _V(-hx, 0, hz)),
        cam.p(const _V(hx, 0, hz)),
        cam.p(const _V(hx, -_trimHeight, hz)),
        cam.p(const _V(-hx, -_trimHeight, hz)),
      ]),
      _pens.fill..color = _lit(edge, const _V(0, 0, 1)),
    );
    canvas.drawPath(
      g._quad([
        cam.p(const _V(-hx, 0, -hz)),
        cam.p(const _V(hx, 0, -hz)),
        cam.p(const _V(hx, 0, hz)),
        cam.p(const _V(-hx, 0, hz)),
      ]),
      _pens.stroke
        ..strokeWidth = 2
        ..color = edge,
    );
  }

  /// HTML `…Zone` glow spheres (sky blue, opacity 0.35), drawn behind the
  /// objects so they stay readable. The part inside the table is hidden.
  void _paintZone(_Gfx g) {
    final z = scene.zone;
    if (z == null) return;
    final (c, r) = z;
    final canvas = g.canvas;
    final pc = g.cam.p(c);
    final rr = r * g.cam.scaleAt(c);
    canvas.save();
    if (c.y < r) {
      final cut = g.cam.oval(c.withY(0), math.sqrt(r * r - c.y * c.y));
      canvas.clipPath(
        Path()
          ..addRect(
            Rect.fromLTRB(
              pc.dx - rr - 2,
              pc.dy - rr - 2,
              pc.dx + rr + 2,
              cut.center.dy,
            ),
          )
          ..addOval(cut),
      );
    }
    final circle = Rect.fromCircle(center: pc, radius: rr);
    canvas.drawCircle(
      pc,
      rr,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _Colors.zone.withValues(alpha: 0.18),
            _Colors.zone.withValues(alpha: 0.3),
            _Colors.zone.withValues(alpha: 0.5),
          ],
          stops: const [0, 0.78, 1],
        ).createShader(circle),
    );
    canvas.restore();
  }

  /// The pulse of the object to move (HTML `update3DHighlight()`).
  double _glowOf(_Body b) {
    final s = scene;
    final active = s.draggable == b.kind || identical(s.held, b);
    return active ? _pulseMax * s.pulse : 0;
  }

  /// The pulsing sky-blue halo behind the object to move.
  void _halo(_Gfx g, _Body b, double glow) {
    if (glow <= 0) return;
    final (min, max) = b.kind.box;
    final rect = g.cam.boxRect(b.pos + min, b.pos + max);
    g.canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6), const Radius.circular(14)),
      _pens.glow..color = _Colors.highlight.withValues(alpha: glow * 0.55),
    );
  }

  /// Soft shadows of the objects resting on the table (added: the HTML
  /// table received shadows but no object cast one).
  void _paintShadow(_Gfx g, _Body b) {
    final s = scene;
    if (s.mounted(b) || b.pos.y > 0.7) return;
    final r = switch (b.kind) {
      _Kind.bowl => 2.6,
      _Kind.jar => 2.0,
      _Kind.dropper => 0.45,
      _Kind.magnifier => 1.5,
      _Kind.lamp => 2.1,
      _Kind.dish => 2.2,
      _Kind.beaker => 1.9,
      _ => 0.0,
    };
    if (r > 0) g.shadow(b.pos, r);
  }

  void _paintBody(_Gfx g, _Body b) {
    final glow = _glowOf(b);
    switch (b.kind) {
      case _Kind.bowl:
        _paintBowl(g, b, const []);
      case _Kind.jar:
        _paintJar(g, b);
      case _Kind.paper:
        _paintPaper(g);
      case _Kind.spoon:
        _paintSpoon(g, b, glow);
      case _Kind.dropper:
        _paintDropper(g, b, glow);
      case _Kind.magnifier:
        _paintMagnifier(g, b, glow);
      case _Kind.tripod:
        _paintTripod(g, b, glow);
      case _Kind.gauze:
        _paintGauze(g, b, glow);
      case _Kind.lamp:
        _paintLamp(g, b, glow);
      case _Kind.dish:
        _paintDish(g, b, glow);
      case _Kind.beaker:
        _paintBeaker(g, b, glow);
    }
  }

  /// Objects far to near; the one under the finger on top.
  List<_Body> _order(_Gfx g, bool Function(_Body b) keep) {
    final s = scene;
    return [
      for (final b in s.bodies.values)
        if (!identical(b, s.held) && keep(b)) b,
    ]..sort((a, b) => g.cam.depth(b.center).compareTo(g.cam.depth(a.center)));
  }

  /// A glass rim torus as a thick ellipse stroke: its far half (drawn
  /// before the contents) or its near half.
  void _rimArc(_Gfx g, Rect rim, _V at, double tube, {required bool far}) {
    g.canvas.drawArc(
      rim,
      far ? math.pi : 0,
      math.pi,
      false,
      _pens.stroke
        ..strokeWidth = math.max(1.2, 2 * tube * g.cam.scaleAt(at))
        ..color = _rim,
    );
  }

  /// Liquid in a bowl: the body, its lighter surface and a sheen.
  void _paintLiquid(_Gfx g, _Bowl liquid, {double opacity = 0.62}) {
    final canvas = g.canvas;
    canvas.drawPath(
      liquid.outline,
      _pens.fill..color = _lit(_water, const _V(0, 0, 1), opacity: opacity),
    );
    canvas.drawOval(
      liquid.rim,
      _pens.fill..color = labShade(_water, 0.22).withValues(alpha: 0.72),
    );
    canvas.drawArc(
      liquid.rim.deflate(liquid.rim.height * 0.18),
      math.pi * 1.15,
      math.pi * 0.4,
      false,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.white.withValues(alpha: 0.35),
    );
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildScenario1Scene()`: the black paper (flat on the table), the drop
  /// zone, then the salt container, the bowl, the spoon, the dropper and
  /// the magnifying glass far to near (the spoon or dropper in the bowl is
  /// drawn between its walls).
  void _paintScenario1(_Gfx g) {
    final s = scene;
    _paintPaper(g);
    _paintZone(g);
    for (final b in s.bodies.values) {
      _paintShadow(g, b);
    }
    final inside = [
      for (final b in s.bodies.values)
        if (s.inBowl(b)) b,
    ];
    for (final b in _order(
      g,
      (b) => b.kind != _Kind.paper && !inside.contains(b),
    )) {
      if (b.kind == _Kind.bowl) {
        _paintBowl(g, b, inside);
      } else {
        _paintBody(g, b);
      }
    }
    final held = s.held;
    if (held != null) _paintBody(g, held);
    _paintDrop(g);
  }

  /// `saltJarS1`: white body with a blue lid (the salt inside is hidden by
  /// the opaque body, as in the HTML).
  void _paintJar(_Gfx g, _Body b) {
    g
      ..frustum(b.pos, _jarR, _jarR, _jarH, _Colors.jarBody)
      ..frustum(
        b.pos + const _V(0, _jarH, 0),
        _lidR,
        _lidR,
        _lidH,
        _Colors.blueLid,
      );
  }

  /// `bowlS1`: the far wall and rim, the water, the salt on the floor, the
  /// falling salt and whatever stands in it, then the near wall and rim.
  void _paintBowl(_Gfx g, _Body b, List<_Body> inside) {
    final s = scene;
    final canvas = g.canvas;
    final rimC = b.pos + const _V(0, _bowlR, 0);
    final shape = g.bowl(rimC, _bowlR, _bowlR);
    final outline = shape.outline;
    canvas.drawPath(outline, _pens.fill..color = _glassFill);
    _rimArc(g, shape.rim, rimC, _bowlRimTube, far: true);
    final water = g.bowlLiquid(rimC, _bowlR, _bowlR, b.pos.y + _bowlWaterTop);
    if (water != null) _paintLiquid(g, water);
    if (s.saltInBowl) _paintSaltHeap(g, b.pos);
    _paintGrains(g, b.pos);
    for (final o in inside) {
      _paintBody(g, o);
    }
    canvas.drawPath(shape.front, _pens.fill..color = _glassFill);
    canvas.drawPath(
      outline,
      _pens.stroke
        ..strokeWidth = 1.3
        ..color = _glassEdge,
    );
    canvas.drawArc(
      shape.low.deflate(shape.low.width * 0.08),
      math.pi * 0.62,
      math.pi * 0.22,
      false,
      _pens.stroke
        ..strokeWidth = math.max(1.0, shape.low.width * 0.02)
        ..color = _Colors.white.withValues(alpha: 0.25),
    );
    _rimArc(g, shape.rim, rimC, _bowlRimTube, far: false);
  }

  /// `saltInBowlS1`: salt crystals on the bowl's floor, seen through the
  /// water; they shrink and fade while the learner stirs. The heap builds
  /// up as the falling salt lands (added).
  void _paintSaltHeap(_Gfx g, _V bowl) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final landed = s.grainsAt < 0
        ? 1.0
        : ((s.time - s.grainsAt) / _grainSeconds).clamp(0.0, 1.0);
    final r = _saltHeapR * s.saltScale * (0.3 + 0.7 * landed);
    final fade = s.saltScale.clamp(0.0, 1.0);
    if (r <= 0.02 || fade <= 0.02) return;
    final c = _V(bowl.x, bowl.y + _saltHeapY, bowl.z);
    final salt = Color.lerp(_Colors.salt, _water, 0.3)!;
    canvas.drawOval(
      cam.oval(c, r),
      _pens.fill..color = salt.withValues(alpha: 0.85 * fade),
    );
    for (final (x, z, f) in _flecks) {
      if (x * x + z * z > 1) continue;
      final w = _V(c.x + x * r * 0.9, c.y + 0.02, c.z + z * r * 0.9);
      final px = 0.13 * f * cam.scaleAt(w) * math.min(1.0, s.saltScale * 1.5);
      canvas.drawRect(
        Rect.fromCenter(center: cam.p(w), width: px, height: px * 0.8),
        _pens.fill..color = _Colors.white.withValues(alpha: fade),
      );
    }
  }

  /// Salt grains falling from the tipped spoon into the bowl (added).
  void _paintGrains(_Gfx g, _V bowl) {
    final s = scene;
    if (s.grainsAt < 0) return;
    final e = (s.time - s.grainsAt) / _grainSeconds;
    if (e >= 1) return;
    final cam = g.cam;
    for (var i = 0; i < 9; i++) {
      final t = (e * 1.3 - i * 0.035).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final from = _V(
        bowl.x - 0.5 + (i % 3) * 0.3,
        bowl.y + _overBowl.y - 0.2,
        bowl.z + 0.7 + (i ~/ 3) * 0.2,
      );
      final to = _V(
        bowl.x + ((i * 37) % 9 - 4) * 0.25,
        bowl.y + _saltHeapY,
        bowl.z + ((i * 53) % 9 - 4) * 0.2,
      );
      final w = _V.lerp(from, to, t * t);
      final px = 0.14 * cam.scaleAt(w);
      g.canvas.drawRect(
        Rect.fromCenter(center: cam.p(w), width: px, height: px),
        _pens.fill..color = _Colors.salt,
      );
    }
  }

  /// `blackPaperS1` with the wet patch (`paperPatchS1`, shrinking as it
  /// dries) and the white salt left behind (`paperSaltS1`, growing), with
  /// its crystal flecks.
  void _paintPaper(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    g.box(_paperPos, _paperSize, _Colors.paper, edge: 0.3);
    if (s.patchShown) {
      final k = s.patchScale;
      final r = _patchR * k * (0.35 + 0.65 * s.patchSpread);
      final h = _patchH * k;
      final bottom = _V(_paperPos.x, _patchY - h / 2, _paperPos.z);
      g.frustum(bottom, r, r, h, _Colors.patch);
      // The wet shine (`roughness: 0.2`).
      final top = cam.oval(bottom + _V(0, h, 0), r * 0.55);
      canvas.drawOval(
        top.shift(Offset(-top.width * 0.25, -top.height * 0.15)),
        _pens.fill..color = _Colors.white.withValues(alpha: 0.12),
      );
    }
    if (s.residueShown && s.residueScale > 0.01) {
      final k = s.residueScale;
      final size = _residueSize * k;
      g.box(
        _V(_paperPos.x, _residueY, _paperPos.z),
        size,
        _Colors.salt,
        edge: 0.5,
        edgeColor: _Colors.saltEdge,
      );
      final top = _residueY + size.y / 2 + 0.005;
      for (final (x, z, f) in _flecks) {
        final w = _V(
          _paperPos.x + x * size.x * 0.45,
          top,
          _paperPos.z + z * size.z * 0.45,
        );
        final px = 0.12 * f * k * cam.scaleAt(w);
        canvas.drawRect(
          Rect.fromCenter(center: cam.p(w), width: px, height: px * 0.7),
          _pens.fill..color = _Colors.saltShade,
        );
      }
    }
  }

  /// `spoonS1`: purple handle and metal scoop, turned like the HTML group;
  /// a heap of salt on the scoop once it has scooped some (added).
  void _paintSpoon(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    _halo(g, b, glow);
    final end = b.at(const _V(0, 0, _handleFrom));
    final tip = b.at(const _V(0, 0, _handleTo));
    final scoop = b.at(_scoopAt);
    final handle = _tint(_Colors.spoon, glow);
    final metal = _tint(_Colors.metal, glow);

    void paintScoop() {
      final c = cam.p(scoop);
      final ax = cam.dp(
        scoop,
        _turn(const _V(1, 0, 0), b.rx, b.ry, b.rz) * _scoopSize.x,
      );
      final az = cam.dp(
        scoop,
        _turn(const _V(0, 0, 1), b.rx, b.ry, b.rz) * _scoopSize.z,
      );
      final ay = cam.dp(
        scoop,
        _turn(const _V(0, 1, 0), b.rx, b.ry, b.rz) * _scoopSize.y,
      );
      canvas.drawPath(
        g.axesOval(c - ay * 0.6, ax, az),
        _pens.fill..color = labShade(_lit(metal, _V.up), -0.35),
      );
      final top = g.axesOval(c, ax, az);
      final bounds = top.getBounds();
      canvas.drawPath(
        top,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.35),
            colors: [
              labShade(_lit(metal, _V.up), 0.35),
              _lit(metal, _V.up),
              labShade(metal, -0.35),
            ],
          ).createShader(bounds),
      );
      canvas.drawPath(
        top,
        _pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(metal, -0.5).withValues(alpha: 0.7),
      );
      if (s.spoonSalt) {
        final heap = g.axesOval(c + ay * 0.7, ax * 0.68, az * 0.68);
        canvas.drawPath(heap, _pens.fill..color = _Colors.salt);
        canvas.drawPath(
          heap,
          _pens.stroke
            ..strokeWidth = 0.6
            ..color = _Colors.saltEdge,
        );
      }
    }

    void paintHandle() => g.rod(end, tip, _handleEndR, _handleTipR, handle);

    if (cam.depth(scoop) > cam.depth(end)) {
      paintScoop();
      paintHandle();
    } else {
      paintHandle();
      paintScoop();
    }
  }

  /// `dropperS1`: a glass tube narrowing to its tip, the solution inside
  /// once filled (added), and the blue rubber bulb.
  void _paintDropper(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final p = b.pos;
    _halo(g, b, glow);
    final tube = g.frustumPath(p, _tubeTipR, _tubeTopR, _tubeH);
    canvas.drawPath(tube, _pens.fill..color = _tint(_glassBody, glow));
    if (s.dropperFilled) {
      canvas.drawPath(
        g.frustumPath(p + const _V(0, 0.03, 0), 0.04, 0.15, 1.5),
        _pens.fill..color = _water.withValues(alpha: 0.85),
      );
    }
    canvas.drawPath(
      tube,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _glassEdge,
    );
    final bc = p + const _V(0, _bulbY, 0);
    final k = cam.scaleAt(bc);
    final rect = Rect.fromCenter(
      center: cam.p(bc),
      width: 2 * _bulbR * k,
      height: 2 * _bulbR * _bulbStretch * k,
    );
    final blue = _tint(_Colors.blueLid, glow);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [
            labShade(blue, 0.4),
            _lit(blue, const _V(0, 0.6, 0.8)),
            labShade(blue, -0.45),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
  }

  /// `magGlassS1`, lying flat: glass lens, dark metal ring and handle. Over
  /// the white residue the lens shows its cubic crystals close up (added:
  /// the HTML only moved the glass there).
  void _paintMagnifier(_Gfx g, _Body b, double glow) {
    final canvas = g.canvas;
    final cam = g.cam;
    final p = b.pos;
    _halo(g, b, glow);
    final metal = _tint(_Colors.darkMetal, glow);
    final lens = cam.oval(p, _lensR);
    canvas.drawOval(lens, _pens.fill..color = _glassBody);
    _paintCloseUp(g, b, lens);
    canvas.drawArc(
      lens.deflate(lens.height * 0.18),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.white.withValues(alpha: 0.45),
    );
    final ring = cam.oval(p, _ringR);
    final w = math.max(1.5, 2 * _ringTube * cam.scaleAt(p));
    canvas.drawOval(
      ring,
      _pens.stroke
        ..strokeWidth = w
        ..color = _lit(metal, _V.up),
    );
    canvas.drawOval(
      ring.deflate(w * 0.25),
      _pens.stroke
        ..strokeWidth = math.max(0.7, w * 0.25)
        ..color = _Colors.darkMetalEdge.withValues(alpha: 0.8),
    );
    g.rod(
      p + const _V(0, 0, _magHandleFrom),
      p + const _V(0, 0, _magHandleTo),
      _magHandleR,
      _magHandleR,
      metal,
      edge: _Colors.darkMetalEdge,
    );
  }

  /// The close-up inside the lens: the black paper with cubic salt
  /// crystals, clearer the closer the lens is to the residue on screen.
  void _paintCloseUp(_Gfx g, _Body b, Rect lens) {
    final s = scene;
    if (!s.residueShown || s.residueScale < 0.15) return;
    final residue = g.cam.p(const _V(8, _residueY + 0.1, -2));
    final d = (lens.center - residue).distance / (lens.width / 2);
    final a = ((_lensReach - d) / 0.5).clamp(0.0, 1.0);
    if (a <= 0) return;
    final canvas = g.canvas;
    canvas.save();
    canvas.clipPath(Path()..addOval(lens));
    canvas.drawOval(
      lens,
      _pens.fill..color = labShade(_Colors.paper, 0.1).withValues(alpha: a),
    );
    final rx = lens.width / 2, ry = lens.height / 2;
    for (final (u, v, size) in _crystals) {
      final c = lens.center + Offset(u * rx * 0.72, v * ry * 0.72);
      _cube(canvas, c, rx * 0.24 * size * s.residueScale, a);
    }
    canvas.restore();
  }

  /// A salt crystal: a small cube seen from the front and above.
  void _cube(Canvas canvas, Offset c, double side, double alpha) {
    final d = side * 0.35;
    final f = Rect.fromCenter(center: c, width: side, height: side);
    final top = Path()
      ..moveTo(f.left, f.top)
      ..lineTo(f.left + d, f.top - d)
      ..lineTo(f.right + d, f.top - d)
      ..lineTo(f.right, f.top)
      ..close();
    final right = Path()
      ..moveTo(f.right, f.top)
      ..lineTo(f.right + d, f.top - d)
      ..lineTo(f.right + d, f.bottom - d)
      ..lineTo(f.right, f.bottom)
      ..close();
    canvas
      ..drawRect(
        f,
        _pens.fill..color = _Colors.saltShade.withValues(alpha: alpha),
      )
      ..drawPath(top, _pens.fill..color = _Colors.salt.withValues(alpha: alpha))
      ..drawPath(
        right,
        _pens.fill..color = _Colors.saltEdge.withValues(alpha: alpha),
      );
    final edge = _pens.stroke
      ..strokeWidth = 0.8
      ..color = _Colors.slate400.withValues(alpha: 0.7 * alpha);
    canvas
      ..drawRect(f, edge)
      ..drawPath(top, edge)
      ..drawPath(right, edge);
  }

  /// A drop of solution falling from the dropper onto the paper (added).
  void _paintDrop(_Gfx g) {
    final s = scene;
    if (s.dropAt < 0) return;
    final e = (s.time - s.dropAt) / _dropFallSeconds;
    if (e >= 1) return;
    const to = _V(8, _patchY + 0.06, -2);
    final w = _V.lerp(_dropperOverPaper, to, e * e);
    final k = g.cam.scaleAt(w);
    g.canvas.drawOval(
      Rect.fromCenter(center: g.cam.p(w), width: 0.26 * k, height: 0.34 * k),
      _pens.fill..color = _water.withValues(alpha: 0.9),
    );
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildScenario2Scene()`: the gauze while it lies on the table, the
  /// drop zone, then the tripod (with what is mounted on it), the lamp,
  /// the glass bowl and the beaker far to near; the pour stream and the
  /// steam on top.
  void _paintScenario2(_Gfx g) {
    final s = scene;
    final gauze = s.body(_Kind.gauze);
    final flat =
        !s.gauzePlaced && !identical(gauze, s.held) && gauze.pos.y < 0.2;
    if (flat) _paintGauze(g, gauze, _glowOf(gauze));
    _paintZone(g);
    for (final b in s.bodies.values) {
      _paintShadow(g, b);
    }
    for (final b in _order(
      g,
      (b) => !s.mounted(b) && !(flat && b.kind == _Kind.gauze),
    )) {
      _paintBody(g, b);
    }
    final held = s.held;
    if (held != null) _paintBody(g, held);
    if (s.streaming) _paintStream(g);
    _paintSteam(g);
  }

  /// `tripodS2`: the two far legs, the lamp under it, the ring, the near
  /// leg, then the gauze and the glass bowl on top.
  void _paintTripod(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final p = b.pos;
    _halo(g, b, glow);
    final metal = _tint(_Colors.darkMetal, glow);
    void leg(double a) => g.rod(
      p +
          _V(
            _tripodRingR * math.cos(a),
            _tripodRingY,
            _tripodRingR * math.sin(a),
          ),
      p + _V(_legFootR * math.cos(a), 0, _legFootR * math.sin(a)),
      _legR,
      _legR,
      metal,
      edge: _Colors.darkMetalEdge,
    );
    leg(4 * math.pi / 3);
    leg(0);
    if (s.lampPlaced) {
      final lamp = s.body(_Kind.lamp);
      _paintLamp(g, lamp, _glowOf(lamp));
    }
    final ringC = p + const _V(0, _tripodRingY, 0);
    final ring = cam.oval(ringC, _tripodRingR);
    final w = math.max(1.5, 2 * _tripodTube * cam.scaleAt(ringC));
    canvas.drawOval(
      ring,
      _pens.stroke
        ..strokeWidth = w
        ..color = _lit(metal, _V.up),
    );
    canvas.drawOval(
      ring.inflate(-w * 0.2),
      _pens.stroke
        ..strokeWidth = math.max(0.7, w * 0.22)
        ..color = _Colors.darkMetalEdge.withValues(alpha: 0.8),
    );
    leg(2 * math.pi / 3);
    if (s.gauzePlaced) {
      final gauze = s.body(_Kind.gauze);
      _paintGauze(g, gauze, _glowOf(gauze));
    }
    if (s.dishPlaced) {
      final dish = s.body(_Kind.dish);
      _paintDish(g, dish, _glowOf(dish));
    }
  }

  /// `gauzeS2`: a square of wire mesh.
  void _paintGauze(_Gfx g, _Body b, double glow) {
    final canvas = g.canvas;
    final cam = g.cam;
    final p = b.pos;
    _halo(g, b, glow);
    const h = _gauzeSide / 2;
    final corners = [
      cam.p(p + const _V(-h, 0, -h)),
      cam.p(p + const _V(h, 0, -h)),
      cam.p(p + const _V(h, 0, h)),
      cam.p(p + const _V(-h, 0, h)),
    ];
    final wire = _tint(_Colors.wire, glow);
    canvas.drawPath(
      g._quad(corners),
      _pens.fill..color = wire.withValues(alpha: 0.1),
    );
    final pen = _pens.stroke
      ..strokeWidth = math.max(0.6, 0.04 * cam.scaleAt(p))
      ..color = wire.withValues(alpha: 0.75);
    for (var i = 1; i < _gauzeWires; i++) {
      final t = -h + 2 * h * i / _gauzeWires;
      canvas
        ..drawLine(cam.p(p + _V(t, 0, -h)), cam.p(p + _V(t, 0, h)), pen)
        ..drawLine(cam.p(p + _V(-h, 0, t)), cam.p(p + _V(h, 0, t)), pen);
    }
    canvas.drawPath(
      g._quad(corners),
      _pens.stroke
        ..strokeWidth = math.max(1.2, 0.08 * cam.scaleAt(p))
        ..color = wire,
    );
  }

  /// `lampS2`: glass base and body, glass neck, metal cap, the wick and,
  /// once lit, the flame.
  void _paintLamp(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final p = b.pos;
    _halo(g, b, glow);
    final glass = _tint(_glassBody, glow);
    final base = g.frustumPath(p, _lampBaseR, _lampBaseR, _lampBaseH);
    canvas.drawPath(base, _pens.fill..color = glass);
    canvas.drawPath(
      base,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _glassEdge,
    );
    // A round-shouldered glass bottle from the base up to the neck.
    final bottom = cam.oval(p + const _V(0, _lampBaseH, 0), _lampBaseR);
    final wide = p + const _V(0, _lampBodyY, 0);
    final pw = cam.p(wide);
    final ww = _lampBodyR * cam.scaleAt(wide);
    final shoulder = p + const _V(0, _neckFrom, 0);
    final ps = cam.p(shoulder);
    final ws = _neckR * cam.scaleAt(shoulder);
    final body = Path()
      ..moveTo(pw.dx - ww, pw.dy)
      ..lineTo(bottom.left, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(pw.dx + ww, pw.dy)
      ..quadraticBezierTo(pw.dx + ww, ps.dy, ps.dx + ws, ps.dy)
      ..lineTo(ps.dx - ws, ps.dy)
      ..quadraticBezierTo(pw.dx - ww, ps.dy, pw.dx - ww, pw.dy)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            labShade(glass, 0.35).withValues(alpha: glass.a),
            glass,
            labShade(glass, -0.3).withValues(alpha: glass.a),
          ],
        ).createShader(body.getBounds()),
    );
    canvas.drawPath(
      body,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _glassEdge,
    );
    final neck = g.frustumPath(
      p + const _V(0, _neckFrom, 0),
      _neckR,
      _neckR,
      _neckTo - _neckFrom,
    );
    canvas.drawPath(neck, _pens.fill..color = glass);
    canvas.drawPath(
      neck,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _glassEdge,
    );
    g
      ..frustum(
        p + const _V(0, _capFrom, 0),
        _capR,
        _capR,
        _capTo - _capFrom,
        _tint(_Colors.metal, glow),
      )
      ..frustum(
        p + const _V(0, _capTo, 0),
        _wickR,
        _wickR * 0.8,
        _wickTo - _capTo,
        _Colors.wick,
      );
    if (s.flameOn) {
      final foot = p + const _V(0, _wickTo - 0.1, 0);
      _paintFlame(g, foot, _flameTip - foot.y + p.y);
    }
  }

  /// `flameGrpS2`: the 0xfab105 flame, flickering, with a hot core, a blue
  /// foot and a glow (added).
  void _paintFlame(_Gfx g, _V foot, double height) {
    final canvas = g.canvas;
    final t = scene.time;
    final pb = g.cam.p(foot);
    final k = g.cam.scaleAt(foot);
    final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
    final h = height * k * flick;
    final w = _flameR * k * (1 + 0.05 * math.sin(t * 23));
    final sway = 0.07 * math.sin(t * 11);
    labGlow(
      canvas,
      pb.translate(0, -h * 0.45),
      h * 1.15,
      _Colors.flameGlow,
      intensity: 0.55,
    );
    Path flame(double sx, double sy) {
      final tip = Offset(pb.dx + sway * h * sy, pb.dy - h * sy);
      return Path()
        ..moveTo(tip.dx, tip.dy)
        ..cubicTo(
          pb.dx + w * sx * 1.1,
          pb.dy - h * sy * 0.45,
          pb.dx + w * sx,
          pb.dy,
          pb.dx,
          pb.dy,
        )
        ..cubicTo(
          pb.dx - w * sx,
          pb.dy,
          pb.dx - w * sx * 1.1,
          pb.dy - h * sy * 0.45,
          tip.dx,
          tip.dy,
        )
        ..close();
    }

    canvas
      ..drawPath(
        flame(1, 1),
        _pens.fill..color = _Colors.flame.withValues(alpha: 0.95),
      )
      ..drawPath(
        flame(0.6, 0.66),
        _pens.fill..color = _Colors.flameCore.withValues(alpha: 0.9),
      )
      ..drawPath(
        flame(0.34, 0.26),
        _pens.fill..color = _Colors.sky400.withValues(alpha: 0.7),
      );
  }

  /// `dishS2`: the far wall and rim, the salt crust, the solution (with
  /// bubbles while it boils), then the near wall and rim.
  void _paintDish(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    _halo(g, b, glow);
    final rimC = b.pos + const _V(0, _dishDepth, 0);
    final shape = g.bowl(rimC, _dishR, _dishDepth);
    final fill = _tint(_glassFill, glow);
    canvas.drawPath(shape.outline, _pens.fill..color = fill);
    _rimArc(g, shape.rim, rimC, _dishRimTube, far: true);
    final wet = s.dishWaterShown && s.dishPlaced;
    if (wet) {
      final liquid = g.bowlLiquid(rimC, _dishR, _dishDepth, s.dishSurface);
      if (liquid != null) _paintLiquid(g, liquid);
    }
    if (s.crustShown && s.crustScale > 0.01) _paintCrust(g, b.pos, wet);
    if (wet) _paintBubbles(g, b.pos, rimC);
    canvas.drawPath(shape.front, _pens.fill..color = fill);
    canvas.drawPath(
      shape.outline,
      _pens.stroke
        ..strokeWidth = 1.3
        ..color = _glassEdge,
    );
    _rimArc(g, shape.rim, rimC, _dishRimTube, far: false);
  }

  /// `saltCrustS2`: the white salt left on the bowl's floor, growing as the
  /// water boils away (tinted while it is still under water).
  void _paintCrust(_Gfx g, _V dish, bool underWater) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final c = _V(dish.x, dish.y + _crustY, dish.z);
    final r = _crustR * s.crustScale;
    final salt = underWater
        ? Color.lerp(_Colors.salt, _water, 0.35 * s.dishWater)!
        : _Colors.salt;
    final oval = cam.oval(c, r);
    canvas.drawOval(oval, _pens.fill..color = _lit(salt, _V.up));
    canvas.drawOval(
      oval,
      _pens.stroke
        ..strokeWidth = 0.8
        ..color = _Colors.saltEdge,
    );
    for (final (x, z, f) in _flecks) {
      if (x * x + z * z > 1) continue;
      final w = _V(c.x + x * r * 0.9, c.y + 0.01, c.z + z * r * 0.9);
      final px = 0.12 * f * s.crustScale * cam.scaleAt(w);
      canvas.drawRect(
        Rect.fromCenter(center: cam.p(w), width: px, height: px * 0.7),
        _pens.fill..color = _Colors.saltShade,
      );
    }
  }

  /// Bubbles rising through the boiling solution (added: the HTML
  /// observation says "Bubbles form").
  void _paintBubbles(_Gfx g, _V dish, _V rimC) {
    final s = scene;
    final fade = s.steamFade;
    if (fade <= 0 || s.dishWater < 0.08) return;
    final canvas = g.canvas;
    final cam = g.cam;
    final surface = s.dishSurface;
    final floor = dish.y + 0.12;
    for (var i = 0; i < _bubbleCount; i++) {
      final phase = (s.time * 1.7 + i * 0.37) % 1.0;
      final angle = i * 2.39996;
      final y = floor + (surface - floor) * phase;
      final u = ((rimC.y - y) / _dishDepth).clamp(0.0, 1.0);
      final room = _dishR * math.sqrt(1 - u * u) * 0.75;
      final rad = math.min(0.25 + (i * 0.618) % 1.0, room);
      final w = _V(
        dish.x + math.cos(angle) * rad,
        y,
        dish.z + math.sin(angle) * rad,
      );
      final c = cam.p(w);
      final r = (0.06 + 0.07 * phase) * cam.scaleAt(w);
      canvas
        ..drawCircle(
          c,
          r,
          _pens.fill..color = _Colors.white.withValues(alpha: 0.2 * fade),
        )
        ..drawCircle(
          c,
          r,
          _pens.stroke
            ..strokeWidth = 0.8
            ..color = _Colors.white.withValues(alpha: 0.75 * fade),
        );
    }
  }

  /// `beakerS2`, turned about its base like the HTML group: the far wall,
  /// the solution, the near wall and the rim.
  void _paintBeaker(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    canvas.save();
    _tiltAbout(canvas, cam.p(b.pos), b.rz);
    _halo(g, b, glow);
    final fill = _tint(_glassFill, glow);
    g
      ..cupBack(b.pos, _beakerR, _beakerR, _beakerH, fill)
      ..liquid(
        b.pos + const _V(0, _beakerWaterFrom, 0),
        _beakerWaterR,
        _beakerWaterR,
        _beakerWaterH * s.beakerWater,
        _water,
        opacity: 0.66,
      )
      ..cupFront(b.pos, _beakerR, _beakerR, _beakerH, fill, _glassEdge);
    final top = b.pos + const _V(0, _beakerH, 0);
    canvas.drawOval(
      cam.oval(top, _beakerR),
      _pens.stroke
        ..strokeWidth = math.max(1.2, 0.16 * cam.scaleAt(top))
        ..color = _rim,
    );
    canvas.restore();
  }

  /// The pour: a stream from the tilted beaker's lip down to the solution
  /// in the bowl, droplets running down it and splash rings where it lands
  /// (HTML `pourStreamMeshS2`, `pourDropletsS2`, `pourSplashRingsS2`).
  void _paintStream(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final b = s.body(_Kind.beaker);
    final pivot = cam.p(b.pos);
    final lip =
        pivot +
        _tilted(cam.p(b.pos + const _V(-_beakerR, _beakerH, 0)) - pivot, b.rz);
    final dish = s.body(_Kind.dish);
    final at = dish.pos.withY(s.dishSurface);
    final surface = cam.p(at);
    final end = Offset(lip.dx, math.max(lip.dy + 4, surface.dy));
    final k = cam.scaleAt(at);
    final wa = _streamTopR * k, wb = _streamFootR * k;
    final stream = g._quad([
      Offset(lip.dx - wa, lip.dy),
      Offset(lip.dx + wa, lip.dy),
      Offset(end.dx + wb, end.dy),
      Offset(end.dx - wb, end.dy),
    ]);
    canvas.drawPath(
      stream,
      Paint()
        ..shader = LinearGradient(
          colors: [
            labShade(_stream, 0.25).withValues(alpha: 0.88),
            _stream.withValues(alpha: 0.88),
            labShade(_stream, -0.15).withValues(alpha: 0.88),
          ],
        ).createShader(stream.getBounds()),
    );
    for (var i = 0; i < s.droplets.length; i++) {
      final (r, offset) = s.droplets[i];
      final t = (s.time * _dropletRate + offset) % 1.0;
      final c =
          Offset.lerp(lip, end, t)! +
          Offset(math.sin(s.time * _wobbleRate + i) * _wobble * k, 0);
      canvas.drawCircle(
        c,
        r * k,
        _pens.fill..color = _stream.withValues(alpha: 0.88),
      );
    }
    final squash = cam.ellipseHalf(at, 1) / cam.scaleAt(at);
    for (var i = 0; i < s.rings.length; i++) {
      final scale = s.rings[i];
      final rr = (_splashR + i * _splashStep) * scale * k;
      final alpha = (1 - (scale - 0.2)).clamp(0.0, 1.0) * 0.88;
      canvas.drawOval(
        Rect.fromCenter(center: end, width: 2 * rr, height: 2 * rr * squash),
        _pens.stroke
          ..strokeWidth = math.max(1.0, 0.08 * k)
          ..color = _stream.withValues(alpha: alpha),
      );
    }
  }

  /// `steamParticlesS2`: white puffs rising above the bowl while the water
  /// boils (softened, and fading out once the button is let go).
  void _paintSteam(_Gfx g) {
    final s = scene;
    if (s.steamFade <= 0) return;
    final canvas = g.canvas;
    final cam = g.cam;
    for (final p in s.steam) {
      final w = _V(p.x, p.y, p.z);
      final c = cam.p(w);
      final rise = ((p.y - _steamBottom) / (_steamTop - _steamBottom)).clamp(
        0.0,
        1.0,
      );
      final r = _steamR * cam.scaleAt(w) * (1.4 + 0.8 * rise);
      final a = 0.4 * s.steamFade * (1 - 0.5 * rise);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _steam.withValues(alpha: a),
              _steam.withValues(alpha: a * 0.5),
              _steam.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }
  }

  // ---------------------------------------------------------- overlays

  /// HTML `createStdLabel` chips, centred on each object's label point
  /// ([_Scene.labelPoint]; the gauze's is added and hidden once it is on
  /// the tripod).
  void _paintLabels(_Gfx g) {
    final s = scene;
    for (final b in s.bodies.values) {
      if (b.kind == _Kind.gauze && s.gauzePlaced) continue;
      final at = s.labelPoint(b);
      if (g.cam.depth(at) < 0.5) continue;
      _chip(g, g.cam.p(at), _t(b.kind.labelKey));
    }
  }

  /// `.label-3d glass-panel`: a rounded glass chip with a thin border and
  /// bold text, kept left of the tool column.
  void _chip(_Gfx g, Offset c, String text) {
    final canvas = g.canvas;
    final size = cache.chipSize(text);
    var rect = Rect.fromCenter(
      center: c,
      width: size.width,
      height: size.height,
    );
    if (rect.right > labelRight - 4) {
      rect = rect.shift(Offset(labelRight - 4 - rect.right, 0));
    }
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * _chipRadius),
    );
    canvas
      ..drawRRect(rr.shift(const Offset(0, 1)), _pens.chipShadow)
      ..drawRRect(
        rr,
        _pens.fill..color = isDark ? _Colors.labelDark : _Colors.labelLight,
      )
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1
          ..color = isDark ? _Colors.labelBorderDark : _Colors.labelBorderLight,
      );
    final tp = cache.label(text);
    tp.paint(
      canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  /// HTML `confetti(...)` with the Scenario 2 summary.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 < 0) return;
    final ticks = (s.time - t0) * _fps;
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
