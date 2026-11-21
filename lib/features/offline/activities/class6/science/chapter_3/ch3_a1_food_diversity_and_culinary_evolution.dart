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

/// Class 6 Science • Chapter 3 • Activity 1
/// Food Diversity and Culinary Evolution.
///
/// Native Flutter port of
/// `Cl6S-Ch03-A1-Food_Diversity_and_Culinary_Evolution.html`.
///
/// Scenario 1 (The Regional Food Map): a map of India lies on a table with
/// a shelf of crop icons beside it (Wheat, Cactus, Rice, Bamboo). Wheat
/// dragged onto Punjab makes the state glow green and its food models pop
/// up; tapping them names the dishes ('Makki di Roti & Saag'). Rice dragged
/// onto Karnataka (it returns to the shelf for reuse) brings 'Idli, Dosa,
/// Sambhar'; Rice and Bamboo dragged onto Manipur bring 'Eromba & Kangsoi'.
/// 'Review Findings' opens the regional summary.
///
/// Scenario 2 (The Culinary Time Machine): a split-screen kitchen, a
/// traditional one (sil-batta, chulha) and a modern one (electric grinder,
/// gas stove), with a spice bowl and dough on the table between them. The
/// spice bowl dropped on the sil-batta is ground for 10 s (the roller
/// scrapes, "GRIND! SCRAPE!", a progress bar, the camera closes in); after
/// 'Reset & Try Modern Grinder' it is dropped into the grinder and ground
/// in 2 s ("WHIRRRR!"). The dough cooks on the chulha in 8 s (orange
/// flame, it puffs up and browns) and, after 'Reset & Try Gas Stove', on
/// the gas stove in 3 s (blue flame). 'Review Findings' compares the times.
///
/// The Three.js scenes are redrawn by a CustomPainter through a perspective
/// projection of the HTML camera (fov 45°, at (0, 12, 16) looking at the
/// origin) and the close-ups it tweens to while a tool works. The map's SVG
/// texture is redrawn from a simplified copy of its state outlines.
class Ch3A1FoodDiversityAndCulinaryEvolutionPage extends StatefulWidget {
  const Ch3A1FoodDiversityAndCulinaryEvolutionPage({super.key});

  @override
  State<Ch3A1FoodDiversityAndCulinaryEvolutionPage> createState() =>
      _FoodDiversityLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, from the app's bundled `assets/audio/` tones.
/// The HTML synthesises its tones with Web Audio: 'click' / 'pop' (a food
/// model tapped, every button) → science/click.mp3; 'success' (a crop or an
/// ingredient dropped on its target, the summary) and 'chime' ('Review
/// Findings' appears) → math/success.mp3; 'error' (a missed drop) →
/// science/error.mp3; 'grind_slow' (the sil-batta and the chulha start, a
/// low rasp) → science/dropdown.mp3, a long swish; 'grind_fast' (the
/// grinder and the gas stove start, a short buzz) → science/click.mp3.
enum _Sound implements LabTone {
  /// Generic button click; a food model tapped (HTML `click`, `pop`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A crop or an ingredient dropped on its target (HTML `success`).
  correct('audio/class6/math/success.mp3'),

  /// Missed drop and the added hints (HTML `error`).
  wrong('audio/class6/science/error.mp3'),

  /// The summary (HTML `success`) and 'Review Findings' appearing (HTML
  /// `chime`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// The sil-batta or the chulha starts (HTML `grind_slow`).
  grindSlow('audio/class6/science/dropdown.mp3'),

  /// The grinder or the gas stove starts (HTML `grind_fast`).
  grindFast('audio/class6/science/click.mp3');

  const _Sound(this.asset);

  /// Asset path below `assets/`.
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

/// Colours of the HTML page (Tailwind classes), of its Three.js scenes
/// (material colours), of its SVG icons and of its summary panels.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color orange500 = Color(0xFFF97316);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green700 = Color(0xFF15803D);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
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
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark theme), 0xe0f2fe (light theme).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFE0F2FE);

  /// The S1 table: its material (`Mats.tableWood`) is not defined in the
  /// HTML, so Three.js gives it the default white `MeshBasicMaterial`.
  static const Color table = white;
  static const Color tableEdge = slate300;

  /// The map texture (SVG `fill` / `stroke`); `Mats.zoneHL` (a ring lit
  /// while a crop hovers) and `Mats.zoneOK` (claimed).
  static const Color mapFill = green100;
  static const Color mapStroke = green700;
  static const Color zoneHover = green400;
  static const Color zoneDone = green500;

  /// `Mats.shelfWood`, `Mats.foodBase`, `Mats.metal`, `Mats.mud`,
  /// `Mats.stone`, `Mats.spiceMat`, `Mats.doughMat`.
  static const Color shelfWood = amber800;
  static const Color foodBase = Color(0xFFFDE047);
  static const Color metal = slate400;
  static const Color mud = amber900;
  static const Color stone = slate500;
  static const Color spice = Color(0xFFA16207);
  static const Color dough = Color(0xFFFEF08A);

  /// The dough browns towards rgb(0.8, 0.5, 0.2) while it cooks.
  static const Color doughCooked = Color(0xFFCC8033);

  /// Food models: saag (0x166534), idli (white), Manipur soup (0xd97706).
  static const Color saag = Color(0xFF166534);
  static const Color idli = white;
  static const Color soup = amber600;

  /// S2 floors (0xa16207, 0x94a3b8), walls (0xf4e6ce, 0xccfbf1) and the
  /// central divider (0x1e293b).
  static const Color floorTrad = Color(0xFFA16207);
  static const Color floorModern = slate400;
  static const Color wallTrad = Color(0xFFF4E6CE);
  static const Color wallModern = Color(0xFFCCFBF1);
  static const Color divider = slate800;

  /// Sil-batta stone (0x6e7b85) and roller (0x5a656d); chulha clay
  /// (0xc85a32); grinder trim (0x3b82f6) and lid (0x1e293b); gas stove
  /// steel (0xd1d5db), burners and knobs (0x111111), grates (black).
  static const Color silStone = Color(0xFF6E7B85);
  static const Color silRoller = Color(0xFF5A656D);
  static const Color chulha = Color(0xFFC85A32);
  static const Color grinderBody = white;
  static const Color grinderTrim = blue500;
  static const Color grinderLid = slate800;
  static const Color stoveSteel = Color(0xFFD1D5DB);
  static const Color burner = Color(0xFF111111);
  static const Color grate = black;

  /// Flame sprites: `createFlameSprite('#f97316')` on the chulha and
  /// `('#3b82f6')` on the gas stove; their inner ring is white.
  static const Color flameChulha = orange500;
  static const Color flameGas = blue500;

  /// Text sprites (`createTextSprite`): `#1e293b` chip, `#f59e0b` border,
  /// white text; the 'Inventory' and 'Traditional Kitchen' chips are
  /// `#78350f` with a `#92400e` border, 'Modern Kitchen' `#0f172a` with a
  /// `#3b82f6` border; the dish names (`createRawTextSprite`) are white
  /// chips with `#1e293b` text and border.
  static const Color chipBg = slate800;
  static const Color chipBorder = amber500;
  static const Color chipText = white;
  static const Color chipWood = amber900;
  static const Color chipWoodBorder = amber800;
  static const Color chipModern = slate900;
  static const Color chipModernBorder = blue500;
  static const Color dishChip = white;
  static const Color dishText = slate800;

  /// Crop icon sprites: white card, `#d97706` border, `#1e293b` name.
  static const Color card = white;
  static const Color cardBorder = amber600;
  static const Color cardText = slate800;
  static const Color cardShadow = Color(0x40000000);

  /// Soft contact shadows (the HTML scene casts PCF soft shadows).
  static const Color shadow = Color(0x4D000000);

  // ------------------------------------------------------------ SVG icons
  /// `SVGs.wheat` / `SVGs.rice`: indigo body, near-white grains;
  /// `SVGs.bamboo` green-400; `SVGs.cactus` green-500.
  static const Color iconBody = indigo500;
  static const Color iconGrain = slate50;
  static const Color bamboo = green400;
  static const Color cactus = green500;

  /// canvas-confetti colours of the HTML summary.
  static const List<Color> confetti = [amber500, blue500, emerald500];

  // -------------------------------------------------------- summary (S2)
  /// The chalkboard comparison: board, its frame, the traditional panel
  /// (frame, body, header) and the modern one, the stopwatch face.
  static const Color board = Color(0xFF5C564B);
  static const Color boardFrame = Color(0xFF3E3931);
  static const Color tradFrame = Color(0xFFB48052);
  static const Color tradBody = Color(0xFF87654B);
  static const Color tradHeader = Color(0xFFE5BC7D);
  static const Color modFrame = Color(0xFF5C8B9B);
  static const Color modBody = Color(0xFF537381);
  static const Color modHeader = Color(0xFF98D4D8);
  static const Color watchFace = Color(0xFF2D2D2D);
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
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.amber500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6692400E), // from-amber-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: Color(0xCCF59E0B),
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
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.amber600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6692400E),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: Color(0xCCF59E0B),
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
// From the HTML `i18n`, `ScenariosData` and `labelDict` tables (Telugu
// dropped). `sN_focus_M`, `sN_step_M`, `sN_obs_M` and `sN_expl_M` are each
// step's concept, action, observation and explanation; `sN_hud_M` the HTML
// "Current Task" lines. Steps and HUD lines say what to do on a touch
// screen ("TAP" instead of "CLICK"). The last step of each scenario is the
// HTML's 'Review Findings' HUD line. The HTML showed a few texts in English
// only (the icon names on the crop cards, the dish names, 'Spices',
// 'Dough', 'Electric Grinder', the progress card, the comic texts and the
// 'Reset & Try …' buttons); their Hindi is added. Keys marked "Added." are
// new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Food Diversity and Culinary Evolution',
    'app_subtitle': 'Class 6. Mindful Eating: A path to a Healthy Body',
    'scen_1_opt': 'Scenario 1: The Regional Food Map',
    'scen_2_opt': 'Scenario 2: The Culinary Time Machine',
    's1_desc':
        'Visually connect the staple crops grown in different Indian states with their traditional food items.',
    's2_desc':
        'Compare traditional and modern cooking tools and understand how technology has changed food preparation.',
    // Scenario 1 steps.
    's1_focus_1': 'Agriculture in Punjab',
    's1_step_1': 'Drag Wheat to Punjab.',
    's1_obs_1': 'State glows green. Food models appear.',
    's1_expl_1':
        "Wheat grows well in Punjab's climate. The crops grown locally become the staple diet.",
    's1_focus_2': 'Traditional Diet',
    's1_step_2': 'Tap Punjab food models.',
    's1_obs_2': "Identified 'Makki di Roti & Sarson da Saag' and 'Lassi'.",
    's1_expl_2':
        'These traditional foods are directly linked to the crops and dairy farming prevalent in the region.',
    's1_focus_3': 'Agriculture in Karnataka',
    's1_step_3': 'Drag Rice to Karnataka.',
    's1_obs_3': 'State glows green. Food models appear.',
    's1_expl_3':
        'Rice is a major crop in the southern states due to suitable soil and water availability.',
    's1_focus_4': 'Traditional Diet',
    's1_step_4': 'Tap Karnataka food models.',
    's1_obs_4': "Identified 'Idli, Dosa, Sambhar'.",
    's1_expl_4':
        'Idli and Dosa are primarily made from fermented rice and lentil batter, showcasing the reliance on local agriculture.',
    's1_focus_5': 'Agriculture in Manipur',
    's1_step_5': 'Drag Rice & Bamboo to Manipur.',
    's1_obs_5': 'State glows green. Unique food models appear.',
    's1_expl_5':
        'Manipur relies heavily on rice, and bamboo shoots are a common local ingredient reflecting their unique geography.',
    's1_focus_6': 'Traditional Diet',
    's1_step_6': 'Tap Manipur food models.',
    's1_obs_6': "Identified 'Eromba' and 'Kangsoi'.",
    's1_expl_6':
        'These dishes use local vegetables, bamboo, and fish, highlighting how distinct local resources shape a unique food culture.',
    's1_step_7':
        "TAP the 'Review Findings' button to summarize the regional diversity.",
    's1_hud_1':
        "A map of India is displayed. On the right, there is an inventory of crops. DRAG the 'Wheat' icon and DROP it onto the state of Punjab (North-West).",
    's1_hud_2':
        '3D models of food popped up! TAP on the food models in Punjab to see their names.',
    's1_hud_3':
        "Let's try another state. DRAG the 'Rice' icon and DROP it onto the state of Karnataka (South-West).",
    's1_hud_4':
        'Models appeared in Karnataka. TAP on the food models to learn their names.',
    's1_hud_5':
        "Complete the map! DRAG the 'Rice' AND 'Bamboo' icons and DROP them onto Manipur (North-East). TAP the new dishes.",
    // Added. The HTML showed the 'Review Findings' line already here.
    's1_hud_6':
        'Unique dishes appeared in Manipur. TAP the new food models to learn their names.',
    's1_hud_7':
        "TAP the 'Review Findings' button to summarize the regional diversity.",
    's1_summary':
        'You successfully mapped the connection! The food people eat is deeply connected to the land they live on. The climate and soil determine what crops grow, which in turn shape the traditional cuisine of that region.',
    // Scenario 2 steps.
    's2_focus_1': 'Traditional Grinding',
    's2_step_1': 'Use Sil-batta.',
    's2_obs_1': 'Grinding takes a long time (10s simulated).',
    's2_expl_1':
        'Traditional methods like using a sil-batta required significant manual labor and time to prepare ingredients.',
    's2_focus_2': 'Modern Grinding',
    's2_step_2': 'Use Electric Grinder.',
    's2_obs_2': 'Grinding is very fast (2s simulated).',
    's2_expl_2':
        'Electric appliances revolutionized kitchens by drastically reducing the time and physical effort needed for preparation.',
    's2_focus_3': 'Traditional Cooking',
    's2_step_3': 'Use Chulha.',
    's2_obs_3': 'Cooking is slow (8s simulated).',
    's2_expl_3':
        'Cooking on a wood or coal-fired chulha is a slow process that requires constant monitoring and fire management.',
    's2_focus_4': 'Modern Cooking',
    's2_step_4': 'Use Gas Stove.',
    's2_obs_4': 'Cooking is fast (3s simulated).',
    's2_expl_4':
        'Gas stoves provide instant, high-heat energy, making cooking much faster and more controllable.',
    's2_step_5':
        "TAP the 'Review Findings' button to compare the time and efficiency.",
    's2_hud_1':
        "Welcome to the split-screen kitchen. DRAG the spice bowl from the table and DROP it onto the 'Sil-batta' in the Traditional Kitchen.",
    's2_hud_2':
        "The grinding took a lot of time and effort! Now, DRAG the spice bowl and DROP it into the 'Electric Grinder' in the Modern Kitchen.",
    's2_hud_3':
        "That was fast! Next task: DRAG the dough and DROP it onto the 'Chulha' (mud stove) in the Traditional Kitchen.",
    's2_hud_4':
        "Slow cooking... Now, DRAG the dough and DROP it onto the 'Gas Stove' in the Modern Kitchen.",
    's2_hud_5':
        "TAP the 'Review Findings' button to compare the time and efficiency.",
    's2_summary':
        'You explored culinary evolution! Technology has drastically changed food preparation. While traditional methods are often prized for authentic flavors, modern appliances have significantly increased efficiency, saving hours of manual labor in the kitchen.',
    // Summary popup.
    'sum_title': 'Discovery Complete!',
    'sum_heading': 'Exploration Complete!',
    'next_msg': 'Scenario 1 completed. Select the next from the sidebar!',
    'sum_r_div': 'Regional Diversity: Explored!',
    'sum_total': 'Total',
    'sum_t_time': '18s',
    'sum_m_time': '5s',
    'sum_res': 'TECHNOLOGY: INCREASED EFFICIENCY!',
    'btn_conclude': 'Review Findings',
    'btn_reset_grinder': 'Reset & Try Modern Grinder',
    'btn_reset_gas': 'Reset & Try Gas Stove',
    // Scene labels (HTML `labelDict` and text sprites).
    'lbl_punjab': 'Punjab',
    'lbl_karnataka': 'Karnataka',
    'lbl_manipur': 'Manipur',
    'lbl_inventory': 'Inventory',
    'crop_wheat': 'Wheat',
    'crop_rice': 'Rice',
    'crop_bamboo': 'Bamboo',
    'crop_cactus': 'Cactus',
    'lbl_trad': 'Traditional Kitchen',
    'lbl_modern': 'Modern Kitchen',
    'tool_silbatta': 'Sil-batta',
    'tool_grinder': 'Electric Grinder',
    'tool_chulha': 'Chulha',
    'tool_gas': 'Gas Stove',
    'lbl_spices': 'Spices',
    'lbl_dough': 'Dough',
    'dish_punjab': 'Makki di Roti & Saag',
    'dish_karn': 'Idli, Dosa, Sambhar',
    'dish_man': 'Eromba & Kangsoi',
    // Progress card and comic texts (HTML `#progress-overlay`,
    // `#anim-text-grind`, `#anim-text-whirr`).
    'prog_grinding': 'Grinding...',
    'prog_cooking': 'Cooking...',
    'comic_grind': '⚡ GRIND!\nSCRAPE!',
    'comic_whirr': 'WHIRRRR! ⚡',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // Added.
    'pending': 'Do this step to see the result.',
    'miss_wheat': 'Missed! Drop the Wheat right onto Punjab (North-West).',
    'miss_rice_karn':
        'Missed! Drop the Rice right onto Karnataka (South-West).',
    'miss_rice_man': 'Missed! Drop the Rice right onto Manipur (North-East).',
    'miss_bamboo': 'Missed! Drop the Bamboo right onto Manipur (North-East).',
    'wrong_cactus':
        'Cactus is not a staple crop of Punjab. Drag the Wheat onto Punjab instead.',
    'hint_s1_1': 'In this step, drag the Wheat onto Punjab (North-West).',
    'hint_s1_2': 'TAP the food models in Punjab to see their names.',
    'hint_s1_3': 'In this step, drag the Rice onto Karnataka (South-West).',
    'hint_s1_4': 'TAP the food models in Karnataka to learn their names.',
    'hint_s1_5':
        'In this step, drag the Rice and the Bamboo onto Manipur (North-East).',
    'hint_s1_6': 'TAP the new dishes in Manipur to learn their names.',
    'hint_review': "TAP 'Review Findings' to see your findings.",
    'miss_spices_sil': 'Missed! Drop the spice bowl right onto the Sil-batta.',
    'miss_spices_grinder':
        'Missed! Drop the spice bowl right into the Electric Grinder.',
    'miss_dough_chulha': 'Missed! Drop the dough right onto the Chulha.',
    'miss_dough_gas': 'Missed! Drop the dough right onto the Gas Stove.',
    'hint_s2_1': 'In this step, drag the spice bowl onto the Sil-batta.',
    'hint_s2_2': 'In this step, drag the spice bowl into the Electric Grinder.',
    'hint_s2_3': 'In this step, drag the dough onto the Chulha.',
    'hint_s2_4': 'In this step, drag the dough onto the Gas Stove.',
    'need_reset_grinder': "TAP 'Reset & Try Modern Grinder' first.",
    'need_reset_gas': "TAP 'Reset & Try Gas Stove' first.",
    'scene_s1':
        'A table with a map of India, and a shelf of crop icons: wheat, cactus, rice and bamboo',
    'scene_s2':
        'A split-screen kitchen: a traditional kitchen with a sil-batta and a chulha, a modern kitchen with an electric grinder and a gas stove, and a spice bowl and dough on the table between them',
    'sem_food_punjab': 'Food models in Punjab',
    'sem_food_karn': 'Food models in Karnataka',
    'sem_food_man': 'Food models in Manipur',
  },
  'hi': {
    'app_title': 'भोजन विविधता और पाक विकास',
    'app_subtitle': 'कक्षा 6. सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_opt': 'परिदृश्य 1: क्षेत्रीय खाद्य मानचित्र',
    'scen_2_opt': 'परिदृश्य 2: पाक समय मशीन',
    's1_desc':
        'भारत के विभिन्न राज्यों में उगाई जाने वाली मुख्य फसलों को उनके पारंपरिक खाद्य पदार्थों के साथ जोड़ें।',
    's2_desc':
        'पारंपरिक और आधुनिक खाना पकाने के उपकरणों की तुलना करें और समझें कि तकनीक ने भोजन तैयार करने के तरीके को कैसे बदल दिया है।',
    's1_focus_1': 'पंजाब में कृषि',
    's1_step_1': 'गेहूं को पंजाब में खींचें।',
    's1_obs_1': 'राज्य हरे रंग में चमकता है। भोजन मॉडल दिखाई देते हैं।',
    's1_expl_1':
        'पंजाब की जलवायु में गेहूं अच्छी तरह से बढ़ता है। स्थानीय रूप से उगाई जाने वाली फसलें मुख्य आहार बन जाती हैं।',
    's1_focus_2': 'पारंपरिक आहार',
    's1_step_2': 'पंजाब के भोजन मॉडल पर टैप करें।',
    's1_obs_2': "'मक्की दी रोटी और सरसों दा साग' और 'लस्सी' की पहचान की।",
    's1_expl_2':
        'ये पारंपरिक खाद्य पदार्थ सीधे क्षेत्र में प्रचलित फसलों और डेयरी खेती से जुड़े हुए हैं।',
    's1_focus_3': 'कर्नाटक में कृषि',
    's1_step_3': 'चावल को कर्नाटक में खींचें।',
    's1_obs_3': 'राज्य हरे रंग में चमकता है। भोजन मॉडल दिखाई देते हैं।',
    's1_expl_3':
        'उपयुक्त मिट्टी और पानी की उपलब्धता के कारण दक्षिणी राज्यों में चावल एक प्रमुख फसल है।',
    's1_focus_4': 'पारंपरिक आहार',
    's1_step_4': 'कर्नाटक के भोजन मॉडल पर टैप करें।',
    's1_obs_4': "'इडली, डोसा, सांभर' की पहचान की।",
    's1_expl_4':
        'इडली और डोसा मुख्य रूप से किण्वित चावल और दाल के घोल से बनाए जाते हैं, जो स्थानीय कृषि पर निर्भरता को दर्शाते हैं।',
    's1_focus_5': 'मणिपुर में कृषि',
    's1_step_5': 'चावल और बांस को मणिपुर में खींचें।',
    's1_obs_5':
        'राज्य हरे रंग में चमकता है। अद्वितीय भोजन मॉडल दिखाई देते हैं।',
    's1_expl_5':
        'मणिपुर काफी हद तक चावल पर निर्भर है, और बांस के अंकुर एक सामान्य स्थानीय घटक हैं जो उनके अद्वितीय भूगोल को दर्शाते हैं।',
    's1_focus_6': 'पारंपरिक आहार',
    's1_step_6': 'मणिपुर के भोजन मॉडल पर टैप करें।',
    's1_obs_6': "'एरोम्बा' और 'कांगसोइ' की पहचान की।",
    's1_expl_6':
        'इन व्यंजनों में स्थानीय सब्जियों, बांस और मछली का उपयोग किया जाता है, जो इस बात पर प्रकाश डालता है कि कैसे अलग-अलग स्थानीय संसाधन एक अनूठी खाद्य संस्कृति को आकार देते हैं।',
    's1_step_7':
        "क्षेत्रीय विविधता को सारांशित करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    // HTML: 'बाईं ओर' (on the left); the crops are on the right.
    's1_hud_1':
        "भारत का एक नक्शा प्रदर्शित किया गया है। दाईं ओर, फसलों की एक सूची है। 'गेहूं' आइकन को खींचें (DRAG) और इसे पंजाब (उत्तर-पश्चिम) राज्य पर छोड़ें (DROP)।",
    's1_hud_2':
        'भोजन के 3D मॉडल पॉप अप हुए! उनके नाम देखने के लिए पंजाब में भोजन मॉडल पर टैप करें।',
    's1_hud_3':
        "आइए एक और राज्य का प्रयास करें। 'चावल' आइकन को खींचें और इसे कर्नाटक (दक्षिण-पश्चिम) राज्य पर छोड़ें।",
    's1_hud_4':
        'कर्नाटक में मॉडल दिखाई दिए। उनके नाम जानने के लिए भोजन मॉडल पर टैप करें।',
    's1_hud_5':
        "नक्शा पूरा करें! 'चावल' और 'बांस' आइकन को खींचें और उन्हें मणिपुर (उत्तर-पूर्व) पर छोड़ें। नए व्यंजनों पर टैप करें।",
    's1_hud_6':
        'मणिपुर में अनोखे व्यंजन दिखाई दिए। उनके नाम जानने के लिए नए भोजन मॉडल पर टैप करें।',
    's1_hud_7':
        "क्षेत्रीय विविधता को सारांशित करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's1_summary':
        'आपने सफलतापूर्वक कनेक्शन मैप किया! लोग जो भोजन खाते हैं वह उस भूमि से गहराई से जुड़ा होता है जिस पर वे रहते हैं। जलवायु और मिट्टी यह निर्धारित करती है कि कौन सी फसलें उगती हैं, जो बदले में उस क्षेत्र के पारंपरिक व्यंजनों को आकार देती हैं।',
    's2_focus_1': 'पारंपरिक पिसाई',
    's2_step_1': 'सिल-बट्टा का प्रयोग करें।',
    's2_obs_1': 'पीसने में लंबा समय लगता है (10s)।',
    's2_expl_1':
        'सिल-बट्टा का उपयोग करने जैसे पारंपरिक तरीकों में सामग्री तैयार करने के लिए महत्वपूर्ण शारीरिक श्रम और समय की आवश्यकता होती थी।',
    's2_focus_2': 'आधुनिक पिसाई',
    's2_step_2': 'इलेक्ट्रिक ग्राइंडर का प्रयोग करें।',
    's2_obs_2': 'पिसाई बहुत तेज होती है (2s)।',
    's2_expl_2':
        'बिजली के उपकरणों ने तैयारी के लिए आवश्यक समय और शारीरिक प्रयास को काफी कम करके रसोई में क्रांति ला दी।',
    's2_focus_3': 'पारंपरिक खाना पकाना',
    's2_step_3': 'चूल्हे का प्रयोग करें।',
    's2_obs_3': 'खाना पकाना धीमा है (8s)।',
    's2_expl_3':
        'लकड़ी या कोयले से चलने वाले चूल्हे पर खाना पकाना एक धीमी प्रक्रिया है जिसके लिए निरंतर निगरानी और अग्नि प्रबंधन की आवश्यकता होती है।',
    's2_focus_4': 'आधुनिक खाना पकाना',
    's2_step_4': 'गैस स्टोव का प्रयोग करें।',
    's2_obs_4': 'खाना पकाना तेज है (3s)।',
    's2_expl_4':
        'गैस स्टोव तत्काल, उच्च-ऊष्मा ऊर्जा प्रदान करते हैं, जिससे खाना पकाना बहुत तेज और अधिक नियंत्रणीय हो जाता है।',
    's2_step_5':
        "समय और दक्षता की तुलना करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's2_hud_1':
        "स्प्लिट-स्क्रीन किचन में आपका स्वागत है। मेज से मसाले के कटोरे को खींचें और उसे पारंपरिक रसोई में 'सिल-बट्टा' पर छोड़ें।",
    's2_hud_2':
        "पीसने में बहुत समय और मेहनत लगी! अब, मसाले के कटोरे को खींचें और इसे आधुनिक रसोई में 'इलेक्ट्रिक ग्राइंडर' में छोड़ें।",
    's2_hud_3':
        "यह तेज़ था! अगला कार्य: आटे को खींचें और उसे पारंपरिक रसोई में 'चूल्हा' (मिट्टी का चूल्हा) पर छोड़ें।",
    's2_hud_4':
        "धीमा खाना बनाना... अब, आटे को खींचें और इसे आधुनिक रसोई में 'गैस स्टोव' पर छोड़ें।",
    's2_hud_5':
        "समय और दक्षता की तुलना करने के लिए 'निष्कर्ष की समीक्षा करें' बटन पर टैप करें।",
    's2_summary':
        'आपने पाक विकास का अन्वेषण किया! प्रौद्योगिकी ने भोजन की तैयारी को काफी बदल दिया है। जबकि पारंपरिक तरीकों को अक्सर प्रामाणिक स्वाद के लिए बेशकीमती माना जाता है, आधुनिक उपकरणों ने रसोई में घंटों के शारीरिक श्रम को बचाते हुए दक्षता में काफी वृद्धि की है।',
    'sum_title': 'खोज पूर्ण!',
    'sum_heading': 'अन्वेषण पूर्ण!',
    'next_msg': 'परिदृश्य 1 पूरा हुआ। साइडबार से अगला चुनें!',
    'sum_r_div': 'क्षेत्रीय विविधता: अन्वेषण किया गया!',
    'sum_total': 'कुल',
    'sum_t_time': '18s',
    'sum_m_time': '5s',
    'sum_res': 'प्रौद्योगिकी: बढ़ी हुई दक्षता!',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'btn_reset_grinder': 'रीसेट करें और आधुनिक ग्राइंडर आज़माएँ',
    'btn_reset_gas': 'रीसेट करें और गैस स्टोव आज़माएँ',
    'lbl_punjab': 'पंजाब',
    'lbl_karnataka': 'कर्नाटक',
    'lbl_manipur': 'मणिपुर',
    'lbl_inventory': 'सामग्री',
    'crop_wheat': 'गेहूं',
    'crop_rice': 'चावल',
    'crop_bamboo': 'बांस',
    'crop_cactus': 'कैक्टस',
    'lbl_trad': 'पारंपरिक रसोई',
    'lbl_modern': 'आधुनिक रसोई',
    'tool_silbatta': 'सिल-बट्टा',
    'tool_grinder': 'इलेक्ट्रिक ग्राइंडर',
    'tool_chulha': 'चूल्हा',
    'tool_gas': 'गैस स्टोव',
    'lbl_spices': 'मसाले',
    'lbl_dough': 'आटा',
    'dish_punjab': 'मक्की दी रोटी और साग',
    'dish_karn': 'इडली, डोसा, सांभर',
    'dish_man': 'एरोम्बा और कांगसोइ',
    'prog_grinding': 'पिसाई हो रही है...',
    'prog_cooking': 'खाना पक रहा है...',
    'comic_grind': '⚡ घिसो!\nरगड़ो!',
    'comic_whirr': 'घर्रर्रर्र! ⚡',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'miss_wheat':
        'निशाना चूक गया! गेहूं को सीधे पंजाब (उत्तर-पश्चिम) पर छोड़ें।',
    'miss_rice_karn':
        'निशाना चूक गया! चावल को सीधे कर्नाटक (दक्षिण-पश्चिम) पर छोड़ें।',
    'miss_rice_man':
        'निशाना चूक गया! चावल को सीधे मणिपुर (उत्तर-पूर्व) पर छोड़ें।',
    'miss_bamboo':
        'निशाना चूक गया! बांस को सीधे मणिपुर (उत्तर-पूर्व) पर छोड़ें।',
    'wrong_cactus':
        'कैक्टस पंजाब की मुख्य फसल नहीं है। इसके बजाय गेहूं को पंजाब पर खींचें।',
    'hint_s1_1': 'इस चरण में गेहूं को पंजाब (उत्तर-पश्चिम) पर खींचें।',
    'hint_s1_2': 'उनके नाम देखने के लिए पंजाब में भोजन मॉडल पर टैप करें।',
    'hint_s1_3': 'इस चरण में चावल को कर्नाटक (दक्षिण-पश्चिम) पर खींचें।',
    'hint_s1_4': 'उनके नाम जानने के लिए कर्नाटक में भोजन मॉडल पर टैप करें।',
    'hint_s1_5': 'इस चरण में चावल और बांस को मणिपुर (उत्तर-पूर्व) पर खींचें।',
    'hint_s1_6': 'उनके नाम जानने के लिए मणिपुर के नए व्यंजनों पर टैप करें।',
    'hint_review':
        "अपने निष्कर्ष देखने के लिए 'निष्कर्ष की समीक्षा करें' पर टैप करें।",
    'miss_spices_sil':
        'निशाना चूक गया! मसाले के कटोरे को सीधे सिल-बट्टा पर छोड़ें।',
    'miss_spices_grinder':
        'निशाना चूक गया! मसाले के कटोरे को सीधे इलेक्ट्रिक ग्राइंडर में छोड़ें।',
    'miss_dough_chulha': 'निशाना चूक गया! आटे को सीधे चूल्हे पर छोड़ें।',
    'miss_dough_gas': 'निशाना चूक गया! आटे को सीधे गैस स्टोव पर छोड़ें।',
    'hint_s2_1': 'इस चरण में मसाले के कटोरे को सिल-बट्टा पर खींचें।',
    'hint_s2_2': 'इस चरण में मसाले के कटोरे को इलेक्ट्रिक ग्राइंडर में खींचें।',
    'hint_s2_3': 'इस चरण में आटे को चूल्हे पर खींचें।',
    'hint_s2_4': 'इस चरण में आटे को गैस स्टोव पर खींचें।',
    'need_reset_grinder':
        "पहले 'रीसेट करें और आधुनिक ग्राइंडर आज़माएँ' पर टैप करें।",
    'need_reset_gas': "पहले 'रीसेट करें और गैस स्टोव आज़माएँ' पर टैप करें।",
    'scene_s1':
        'भारत के नक्शे वाली एक मेज़, और फसल आइकनों वाली एक शेल्फ़: गेहूं, कैक्टस, चावल और बांस',
    'scene_s2':
        'एक स्प्लिट-स्क्रीन रसोई: सिल-बट्टा और चूल्हे वाली पारंपरिक रसोई, इलेक्ट्रिक ग्राइंडर और गैस स्टोव वाली आधुनिक रसोई, और उनके बीच की मेज़ पर मसाले का कटोरा और आटा',
    'sem_food_punjab': 'पंजाब में भोजन मॉडल',
    'sem_food_karn': 'कर्नाटक में भोजन मॉडल',
    'sem_food_man': 'मणिपुर में भोजन मॉडल',
  },
};

/// Steps of each scenario: the HTML `steps` (six and four) plus its last
/// HUD task ('Review Findings').
const List<int> _stepCounts = [7, 5];

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.focus,
    required this.action,
    required this.result,
    required this.explanation,
  });

  final String focus;
  final String action;
  final String result;
  final String explanation;
}

/// The steps of scenario [index] (0 or 1) in [lang]. The 'Review Findings'
/// step has no concept, result or explanation.
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  final last = _stepCounts[index];
  return [
    for (var i = 1; i <= last; i++)
      _StepInfo(
        focus: i < last ? t('s${n}_focus_$i') : '',
        action: t('s${n}_step_$i'),
        result: i < last ? t('s${n}_obs_$i') : '',
        explanation: i < last ? t('s${n}_expl_$i') : '',
      ),
  ];
}

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
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

/// HTML `PerspectiveCamera(45, …)`: vertical field of view; pixels per world
/// unit at depth 1 are half the stage height over tan(fov / 2), as in
/// Three.js.
const double _fovDegrees = 45;
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);
const double _near = 0.1;

/// HTML lights: `AmbientLight(0xffffff, 0.6)`, the key
/// `DirectionalLight(0xfff5b6, 0.8)` at (15, 25, 15) and the fill
/// `DirectionalLight(0xaabbff, 0.3)` at (-15, 10, -15), normalised.
const double _ambient = 0.6;
const double _keyLight = 0.8;
const _V _keyDir = _V(0.4575, 0.7625, 0.4575);
const _V _keyTint = _V(1, 0.961, 0.714);
const double _fillLight = 0.3;
const _V _fillDir = _V(-0.6396, 0.4264, -0.6396);
const _V _fillTint = _V(0.667, 0.733, 1);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up a crop or an ingredient (short drags must pick
/// it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's text sprites stay readable on phones; chip padding as a share of
/// the label size.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

/// The dish names (`createRawTextSprite`, 28 px on a 380 px canvas) are a
/// little larger than the other labels (24 px on 256 px).
const double _dishLabelScale = 1.1;

/// Longest frame step used by the simulation (s), and how long a re-fit of
/// the scene slides (s).
const double _maxFrameStep = 0.1;
const double _framingSeconds = 0.38;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (up to three lines, label row, padding; x UI scale), the gap
/// kept between a card and the scene, and the compact floating mission card
/// (phones in landscape: screens shorter than [_compactBelow], at most
/// [_compactCardMax] of the height, 12 px from the top).
const double _hudBand = 66;
const double _cardGap = 8;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// HTML `#progress-overlay` (`w-72`, at `top-24`): its top, width and the
/// band it takes (dp x UI scale); the close-ups keep clear of it.
const double _progressTop = 56;
const double _progressWidth = 288;
const double _progressBand = 64;

/// Largest zoom of the fitted views (the HTML camera is zoom 1): the start
/// view of each scenario and the S2 close-ups. Never smaller than
/// [_minZoom].
const List<double> _maxZoomWide = [1.4, 1.25];
const double _maxZoomClose = 1;
const double _minZoom = 0.3;

// ------------------------------------------------------------- timings

/// HTML tweens: a crop used up shrinks (300 ms), a missed one or one to
/// reuse glides back (300 ms); food models pop in with `Elastic.Out` over
/// 800 ms after a 300 ms delay and bob 0 → 0.2 (`Sinusoidal.InOut`, 1000 ms
/// yoyo); the dish name shows the next step 1000 ms after the tap.
const double _shrinkSeconds = 0.3;
const double _returnSeconds = 0.3;
const double _popDelay = 0.3;
const double _popSeconds = 0.8;
const double _bobHalf = 1;
const double _bobHeight = 0.2;
const double _inspectSeconds = 1;

/// HTML S2 tweens: an ingredient moves onto its tool in 300 ms; the camera
/// glides to the close-up in 500 ms (`Cubic.Out`) and back in 500 ms
/// (`Cubic.InOut`); the progress card stays 500 ms after the bar is full,
/// then fades in 300 ms.
const double _moveSeconds = 0.3;
const double _camInSeconds = 0.5;
const double _camOutSeconds = 0.5;
const double _progressTail = 0.5;
const double _progressFade = 0.3;

/// Sil-batta roller: x 0 → 0.5 in 500 ms, yoyo, 20 legs (10 s). Grinder:
/// `rotation.y` 0 → 0.1 in 50 ms, yoyo, 40 legs (2 s), shown here as a
/// small sideways shiver ([_shiver] units). Flames: chulha x 1.5 ↔ 1.2,
/// y 1.5 ↔ 1.8 every 200 ms; gas 1.5 ↔ 1.6 every 100 ms.
const double _rollerLeg = 0.5;
const int _rollerLegs = 20;
const double _rollerShift = 0.5;
const double _shakeLeg = 0.05;
const int _shakeLegs = 40;
const double _shiver = 0.035;
const double _flameScale = 1.5;

// ---------------------------------------------------------- scenario 1

/// Table `BoxGeometry(16, 0.5, 18)` at (-2, -0.25, 0).
const _V _tableMin = _V(-10, -0.5, -9);
const _V _tableMax = _V(6, 0, 9);

/// Inventory shelf `BoxGeometry(3, 0.5, 10)` at (6.5, 0.25, 0) and its
/// 'Inventory' sprite: at (6.5, 1.5, -4) in the HTML, over the first card;
/// here over the shelf's far end.
const _V _shelfCenter = _V(6.5, 0.25, 0);
const _V _shelfSize = _V(3, 0.5, 10);
const _V _inventoryLabel = _V(6.5, 1.5, -5.4);

/// Crop icon sprites (`scale 1.5`) at (6.5, 1, z). HTML drag: the ray meets
/// `dragPlane` (y = 1); a held icon is lifted by 0.5 and kept at y = 1.5.
const double _cropX = 6.5;
const double _cropY = 1;
const double _cardSize = 1.5;
const double _s1PlaneY = 1;
const double _s1HeldY = 1.5;

/// Map zones: group at y 0.5 with its ring (`TorusGeometry(r, 0.1)`) 0.1
/// above and its name sprite 2 above. HTML hover and drop test:
/// `distanceTo(zone.position) < 2`.
const double _zoneY = 0.5;
const double _ringLift = 0.1;
const double _ringTube = 0.1;
const double _zoneLabelLift = 2;
const double _zoneRange = 2;

/// The dish name sprite: 2.5 above the food model in the HTML, where it
/// covers the zone's name; here it sits just above the model.
const double _dishLabelLift = 1.1;

// ---------------------------------------------------------- scenario 2

/// Floors `PlaneGeometry(15, 15)` at x = ∓7.5 (z -7.5 … 7.5), walls
/// `PlaneGeometry(15, 12)` at (∓7.5, 6, -4), divider `BoxGeometry(0.2, 12,
/// 8)` at (0, 6, -1). The floors and walls run on here (to x ±40, the walls
/// 30 high, the floors up to the camera) so the fitted views and the
/// close-ups never look past their ends into the empty background.
const double _floorBack = -7.5;
const double _floorReach = 40;
const double _wallZ = -4;
const double _wallTop = 30;
const double _dividerHeight = 12;
const _V _dividerCenter = _V(0, 6, -1);
const _V _dividerSize = _V(0.2, 12, 8);

/// Kitchen name sprites (`scale 1.8`, 1.5x the tools' names) at (-4.5, 9,
/// -3.9) and (3.5, 9, -3.9); their chips are 1.3x the other labels.
const _V _tradLabel = _V(-4.5, 9, -3.9);
const _V _modernLabel = _V(3.5, 9, -3.9);
const double _kitchenLabelScale = 1.3;

/// Benches: `BoxGeometry(7, 2, 4)` at (-4.5, 1, 2) and `(6, 2, 4)` at (3.5,
/// 1, 2). Widened here (to x -9.5 and 10.5) so the sil-batta at x = -8 and
/// the 4-wide gas stove at x = 8 stand on them instead of hanging past
/// their ends.
const _V _benchTradMin = _V(-9.5, 0, 0);
const _V _benchTradMax = _V(-1, 2, 4);
const _V _benchModMin = _V(0.5, 0, 0);
const _V _benchModMax = _V(10.5, 2, 4);

/// Central table `CylinderGeometry(1.5, 1.5, 1)` at (0, 0.5, 0). The
/// ingredients sit at y = 2 (the bench height), so it is 2 high here.
const double _centreTableR = 1.5;
const double _centreTableH = 2;

/// HTML drag: the ray meets `dragPlane` (y = 1); a held ingredient is
/// lifted by 0.5 and kept at y = 2.5. Drop test `distanceTo(tool.position)
/// < 2`.
const double _s2PlaneY = 1;
const double _s2HeldY = 2.5;
const double _toolRange = 2;

/// Ingredient name sprites 1.2 above the bowl.
const double _ingredientLabelLift = 1.2;

// ---------------------------------------------------------- summary

/// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})`:
/// canvas-confetti's 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity
/// 3 px per tick and start velocity 45 (scaled for the stage).
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);
const Rect _confettiPiece = Rect.fromLTWH(-5, -3, 10, 6);

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

  /// Distance in the horizontal plane.
  double flatDistance(_V o) =>
      math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A camera: where it is and what it looks at (`controls.target`).
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;

  static _View lerp(_View a, _View b, double t) =>
      _View(_V.lerp(a.eye, b.eye, t), _V.lerp(a.target, b.target, t));
}

/// Where the camera's look-at point lands on the stage and how much the
/// scene is enlarged (1 = the HTML camera on the design stage). The scene
/// is fitted into the part of the canvas no card covers.
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
      framing.center,
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

  /// View depth of [w].
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

  /// Same projection as [o] (the cached map outlines stay valid).
  bool sameAs(_Cam o) =>
      (eye - o.eye).length < 1e-9 &&
      (f - o.f).length < 1e-9 &&
      (center - o.center).distance < 1e-6 &&
      (scale - o.scale).abs() < 1e-6;
}

/// A point moved from [from] to [to] over [seconds] from scene time
/// [start] (a linear Tween.js tween).
class _Glide {
  _Glide(this.from, this.to, this.start, this.seconds);

  final _V from;
  final _V to;
  final double start;
  final double seconds;

  double progress(double time) =>
      seconds <= 0 ? 1 : ((time - start) / seconds).clamp(0.0, 1.0).toDouble();

  bool done(double time) => progress(time) >= 1;

  _V at(double time) => _V.lerp(from, to, progress(time));
}

/// A triangle wave of [legs] legs of [leg] seconds from [start] (a yoyo
/// Tween.js tween with `repeat(legs - 1)`), 0 … 1; 0 before and after.
double _yoyo(double time, double start, double leg, int legs) {
  if (start < 0) return 0;
  final k = (time - start) / leg;
  if (k <= 0 || k >= legs) return 0;
  final i = k.floor();
  final f = k - i;
  return i.isEven ? f : 1 - f;
}

// ---------------------------------------------------------------- models

/// The HTML camera positions: the start view (`resetCamera()`) and the S2
/// close-ups, `(tool.x, 5, tool.z + 6)` looking at the tool.
enum _Shot {
  wide(_View(_V(0, 12, 16), _V.zero)),
  silbatta(_View(_V(-8, 5, 8), _V(-8, 2, 2))),
  grinder(_View(_V(3, 5, 8), _V(3, 2, 2))),
  chulha(_View(_V(-3, 5, 8), _V(-3, 2, 2))),
  gas(_View(_V(8, 5, 8), _V(8, 2, 2)));

  const _Shot(this.view);

  final _View view;

  /// The views of scenario [index].
  static List<_Shot> of(int index) => index == 0 ? const [wide] : values;
}

/// The pictures of the HTML `SVGs`.
enum _Art { wheat, rice, bamboo, cactus }

/// The crop icons on the inventory shelf (HTML `createIconSprite` calls).
/// The HTML puts them 2 apart (z = -3, -1, 1, 3), where each card covers
/// the name on the card behind it; here they are 2.7 apart.
enum _Crop {
  wheat('crop_wheat', -4.05, _Art.wheat),
  cactus('crop_cactus', -1.35, _Art.cactus),
  rice('crop_rice', 1.35, _Art.rice),
  bamboo('crop_bamboo', 4.05, _Art.bamboo);

  const _Crop(this.nameKey, this.z, this.art);

  final String nameKey;
  final double z;
  final _Art art;

  _V get home => _V(_cropX, _cropY, z);
}

/// The map zones (HTML `buildMapZone`): name, centre and ring radius, the
/// state's id in the map and a point well inside the state (view box).
enum _Zone {
  punjab('lbl_punjab', _V(-4.5, _zoneY, -3.5), 1.2, 'pb', Offset(152.6, 160.9)),
  karnataka(
    'lbl_karnataka',
    _V(-3, _zoneY, 3.5),
    1.2,
    'ka',
    Offset(156.5, 503.7),
  ),
  manipur('lbl_manipur', _V(2.5, _zoneY, -1), 1, 'mn', Offset(535.6, 305.6));

  const _Zone(this.nameKey, this.center, this.radius, this.state, this.anchor);

  final String nameKey;
  final _V center;
  final double radius;
  final String state;
  final Offset anchor;

  _V get labelAt => center + const _V(0, _zoneLabelLift, 0);
}

/// The food models (HTML `createFoodModel`): their zone, where they stand
/// (the bounce tween keeps them at y 0 … 0.2), the dish name, the
/// screen-reader label and the step that taps them.
enum _Dish {
  punjab(_Zone.punjab, _V(-5.5, 0, -3.5), 'dish_punjab', 'sem_food_punjab', 2),
  karnataka(_Zone.karnataka, _V(-4, 0, 3.5), 'dish_karn', 'sem_food_karn', 4),
  manipur(_Zone.manipur, _V(1.5, 0, -1), 'dish_man', 'sem_food_man', 6);

  const _Dish(this.zone, this.base, this.nameKey, this.semanticsKey, this.step);

  final _Zone zone;
  final _V base;
  final String nameKey;
  final String semanticsKey;
  final int step;
}

/// The kitchen tools (HTML `Objects.s2`): name, position, name sprite
/// height, close-up and hit volume (relative to the position).
enum _Tool {
  silbatta(
    'tool_silbatta',
    _V(-8, 2, 2),
    2,
    _Shot.silbatta,
    _V(-1.8, 0, -1.8),
    _V(1.8, 1, 1.8),
  ),
  grinder(
    'tool_grinder',
    _V(3, 2, 2),
    3,
    _Shot.grinder,
    _V(-1.2, 0, -1.2),
    _V(1.2, 2.45, 1.2),
  ),
  chulha(
    'tool_chulha',
    _V(-3, 2, 2),
    2,
    _Shot.chulha,
    _V(-1.5, 0, -1.5),
    _V(1.5, 1.25, 1.5),
  ),
  gas('tool_gas', _V(8, 2, 2), 2, _Shot.gas, _V(-2, 0, -1.5), _V(2, 1.5, 1.5));

  const _Tool(
    this.nameKey,
    this.pos,
    this.labelLift,
    this.shot,
    this.hitMin,
    this.hitMax,
  );

  final String nameKey;
  final _V pos;
  final double labelLift;
  final _Shot shot;
  final _V hitMin;
  final _V hitMax;

  _V get labelAt => pos + _V(0, labelLift, 0);
}

/// The ingredients on the central table (HTML `Objects.s2.spices` /
/// `dough`).
enum _Ingredient {
  spices('lbl_spices', _V(-1.5, 2, 0)),
  dough('lbl_dough', _V(1.5, 2, 0));

  const _Ingredient(this.nameKey, this.home);

  final String nameKey;
  final _V home;
}

/// The four timed tasks of Scenario 2 (HTML `startS2Progress` calls): the
/// tool, the ingredient, how long it takes (s), the progress card texts,
/// the comic text, the starting tone and where the ingredient rests on the
/// tool (null: the grinder swallows it). The HTML put the spice bowl at
/// y 2.2 (sunk into the 2.3-high stone) and the dough at y 2.3 (inside the
/// stove top); here they rest on the stone and on the grate.
enum _Task {
  silbatta(
    _Tool.silbatta,
    _Ingredient.spices,
    10,
    'prog_grinding',
    '10s',
    'comic_grind',
    _Sound.grindSlow,
    _V(-8, 2.3, 2),
  ),
  grinder(
    _Tool.grinder,
    _Ingredient.spices,
    2,
    'prog_grinding',
    '2s',
    'comic_whirr',
    _Sound.grindFast,
    null,
  ),
  chulha(
    _Tool.chulha,
    _Ingredient.dough,
    8,
    'prog_cooking',
    '8s',
    null,
    _Sound.grindSlow,
    _V(-3, 2.7, 2),
  ),
  gas(
    _Tool.gas,
    _Ingredient.dough,
    3,
    'prog_cooking',
    '3s',
    null,
    _Sound.grindFast,
    _V(7, 2.6, 2),
  );

  const _Task(
    this.tool,
    this.ingredient,
    this.seconds,
    this.labelKey,
    this.time,
    this.comicKey,
    this.sound,
    this.rest,
  );

  final _Tool tool;
  final _Ingredient ingredient;
  final double seconds;
  final String labelKey;
  final String time;
  final String? comicKey;
  final _Sound sound;
  final _V? rest;

  /// The step (1–4) this task finishes.
  int get step => index + 1;

  /// Tasks after which the HTML shows its 'Reset & Try …' button.
  bool get needsReset => this == silbatta || this == chulha;
}

// ================================================================= SVG ICONS

/// Builds a [Path] from SVG path data with the commands the HTML's icons
/// use (M, L, H, V, C, S and Z, absolute and relative; numbers may run
/// together as in "1.5.41" or "2-.9").
Path _svgPath(String data) {
  final tokens = [
    for (final m in RegExp(
      r'[MmLlHhVvCcSsZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
    ).allMatches(data))
      m[0]!,
  ];
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var x = 0.0, y = 0.0;
  var startX = 0.0, startY = 0.0;
  // Second control point of the last curve (for S / s).
  var cx = 0.0, cy = 0.0;
  var lastCurve = false;
  double next() => double.parse(tokens[i++]);
  bool isCommand(String t) => RegExp('[A-Za-z]').hasMatch(t);

  while (i < tokens.length) {
    if (isCommand(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    var curve = false;
    switch (cmd) {
      case 'M' || 'm':
        x = ox + next();
        y = oy + next();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // Further pairs are line-tos.
        cmd = rel ? 'l' : 'L';
      case 'L' || 'l':
        x = ox + next();
        y = oy + next();
        path.lineTo(x, y);
      case 'H' || 'h':
        x = ox + next();
        path.lineTo(x, y);
      case 'V' || 'v':
        y = oy + next();
        path.lineTo(x, y);
      case 'C' || 'c':
        final x1 = ox + next(), y1 = oy + next();
        cx = ox + next();
        cy = oy + next();
        x = ox + next();
        y = oy + next();
        path.cubicTo(x1, y1, cx, cy, x, y);
        curve = true;
      case 'S' || 's':
        final x1 = lastCurve ? 2 * x - cx : x;
        final y1 = lastCurve ? 2 * y - cy : y;
        cx = ox + next();
        cy = oy + next();
        x = ox + next();
        y = oy + next();
        path.cubicTo(x1, y1, cx, cy, x, y);
        curve = true;
      case 'Z' || 'z':
        path.close();
        x = startX;
        y = startY;
      default:
        throw FormatException('Unsupported SVG path command', cmd);
    }
    lastCurve = curve;
  }
  return path;
}

/// The HTML `SVGs` icons in their 24 x 24 view box (paths made once): the
/// crop icons and the flame sprite (two concentric rings).
abstract final class _IconArt {
  static final List<(Path, Color)> _wheat = [
    (
      _svgPath(
        'M12 2c-2.21 0-4 1.79-4 4v2.5c-1.1 0-2 .9-2 2v1.5c0 .83.67 1.5 1.5 '
        '1.5.41 0 .79-.17 1.06-.44.4-.4.99-.44 1.44-.04.45.4.49 1 .04 '
        '1.44-.27.27-.44.65-.44 1.06 0 1.1.9 2 2 2s2-.9 2-2c0-.41-.17-.79'
        '-.44-1.06-.45-.44-.4-1.04.04-1.44.45-.4.99-.44 1.44-.04.27.27.65'
        '.44 1.06.44 1.1 0 2-.9 2-2V8.5c0-1.1-.9-2-2-2V6c0-2.21-1.79-4-4-4'
        'zm-1.5 12.5c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5'
        '-.67-1.5-1.5-1.5zm3 0c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5'
        '-.67 1.5-1.5-.67-1.5-1.5-1.5z',
      ),
      _Colors.iconBody,
    ),
    (
      _svgPath(
        'M12 4c1.1 0 2 .9 2 2v2.5c-1.1 0-2 .9-2 2s.9 2 2 2v1.5c0 .83-.67 '
        '1.5-1.5 1.5s-1.5-.67-1.5-1.5V12c0-1.1-.9-2-2-2s-2 .9-2 2v1.5c0 '
        '.83-.67 1.5-1.5 1.5S7 14.33 7 13.5V12c0-1.1.9-2 2-2V6c0-1.1.9-2 '
        '2-2z',
      ),
      _Colors.iconGrain,
    ),
  ];

  static final List<(Path, Color)> _rice = [
    (
      _svgPath(
        'M20.5 11H3.5c-.28 0-.5.22-.5.5v.5c0 3.59 2.91 6.5 6.5 6.5h5c3.59 '
        '0 6.5-2.91 6.5-6.5v-.5c0-.28-.22-.5-.5-.5z',
      ),
      _Colors.iconBody,
    ),
    (
      _svgPath(
        'M12 4c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-4 4c-1.1 0-2 .9'
        '-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm8 0c-1.1 0-2 .9-2 2s.9 2 2 2 2'
        '-.9 2-2-.9-2-2-2z',
      ),
      _Colors.iconGrain,
    ),
  ];

  static final List<(Path, Color)> _bamboo = [
    (
      _svgPath('M7 2v20h3V2H7zm7 0v20h3V2h-3zm-6 4h5v2H8V6zm7 8h5v2h-5v-2z'),
      _Colors.bamboo,
    ),
  ];

  static final List<(Path, Color)> _cactus = [
    (_svgPath('M14 2H10v20h4V2zm4 7h-2v7h2V9zm-8 4H8V6h2v7z'), _Colors.cactus),
  ];

  /// `SVGs.flame`: the outer ring takes the flame colour, the inner one is
  /// white.
  static final Path flameOuter = _svgPath(
    'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 '
    '18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z',
  );
  static final Path flameInner = _svgPath(
    'M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0 8c-1.65 '
    '0-3-1.35-3-3s1.35-3 3-3 3 1.35 3 3-1.35 3-3 3z',
  );

  static List<(Path, Color)> of(_Art art) => switch (art) {
    _Art.wheat => _wheat,
    _Art.rice => _rice,
    _Art.bamboo => _bamboo,
    _Art.cactus => _cactus,
  };

  /// Draws [art] into [box] with the reused [fill] paint.
  static void draw(Canvas canvas, _Art art, Rect box, Paint fill) {
    canvas
      ..save()
      ..translate(box.left, box.top)
      ..scale(box.width / 24, box.height / 24);
    for (final (path, color) in of(art)) {
      canvas.drawPath(path, fill..color = color);
    }
    canvas.restore();
  }
}

/// An SVG icon for widgets (the summary popup). Static pictures, so the
/// paint is shared.
class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.art);

  final _Art art;

  static final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) =>
      _IconArt.draw(canvas, art, Offset.zero & size, _fill);

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.art != art;
}

// ================================================================= INDIA MAP

/// The HTML's map plane: `PlaneGeometry(12, 14)` at (-2, 0.01, 0), laid
/// flat and textured with an SVG of India (view box 612 x 696, states
/// filled `#dcfce7` with a 2 px `#15803d` outline). Here the state outlines
/// come from [_indiaStates] and are drawn in perspective; the view box's
/// top-left corner lies at world (-8, 0.01, -7).
abstract final class _IndiaMap {
  static const double viewWidth = 612;
  static const double viewHeight = 696;
  static const _V corner = _V(-8, 0.01, -7);
  static const double planeWidth = 12;
  static const double planeDepth = 14;

  /// SVG `stroke-width="2"`, in view box px.
  static const double strokeWidth = 2;

  /// The world point of a view box point.
  static _V world(Offset v) => _V(
    corner.x + v.dx * planeWidth / viewWidth,
    corner.y,
    corner.z + v.dy * planeDepth / viewHeight,
  );

  /// The view box point of a world point (its x and z).
  static Offset view(_V w) => Offset(
    (w.x - corner.x) * viewWidth / planeWidth,
    (w.z - corner.z) * viewHeight / planeDepth,
  );

  /// World size of one view box px (for the outline width).
  static const double pxWorld = planeWidth / viewWidth;

  /// The outline rings of every state (view box px), decoded once, in the
  /// SVG's drawing order.
  static final Map<String, List<List<Offset>>> rings = {
    for (final e in _indiaStates.entries) e.key: _decode(e.value),
  };

  /// Each state as a path in view box px (`Path.contains` for drops).
  static final Map<String, Path> paths = {
    for (final e in rings.entries) e.key: _ringsPath(e.value),
  };

  static Path _ringsPath(List<List<Offset>> rings) {
    final path = Path();
    for (final ring in rings) {
      path.addPolygon(ring, true);
    }
    return path;
  }

  /// Whether the world point [w] (its x and z) lies inside [state].
  static bool contains(String state, _V w) =>
      paths[state]?.contains(view(w)) ?? false;

  static final Map<int, int> _contDigits = {
    for (var i = 0; i < 32; i++) _mapCont.codeUnitAt(i): i,
  };
  static final Map<int, int> _termDigits = {
    for (var i = 0; i < 32; i++) _mapTerm.codeUnitAt(i): i,
  };

  /// Decodes one state of [_indiaStates] (see there).
  static List<List<Offset>> _decode(String code) {
    final out = <List<Offset>>[];
    for (final ring in code.split('|')) {
      var i = 0;
      int read() {
        var value = 0;
        var shift = 0;
        while (true) {
          final c = ring.codeUnitAt(i++);
          final last = _termDigits[c];
          if (last != null) return value | (last << shift);
          value |= _contDigits[c]! << shift;
          shift += 5;
        }
      }

      int unzig(int n) => n.isEven ? n >> 1 : -((n + 1) >> 1);
      var x = read();
      var y = read();
      final points = [Offset(x / _mapQuant, y / _mapQuant)];
      while (i < ring.length) {
        x += unzig(read());
        y += unzig(read());
        points.add(Offset(x / _mapQuant, y / _mapQuant));
      }
      out.add(points);
    }
    return out;
  }
}

/// The map outlines projected by one camera, rebuilt only when the camera
/// or the framing moves.
class _MapProjection {
  _Cam? _cam;
  final Map<String, Path> paths = {};

  void update(_Cam cam) {
    final old = _cam;
    if (old != null && old.sameAs(cam)) return;
    _cam = cam;
    paths.clear();
    for (final e in _IndiaMap.rings.entries) {
      final path = Path();
      for (final ring in e.value) {
        for (var i = 0; i < ring.length; i++) {
          final q = cam.p(_IndiaMap.world(ring[i]));
          if (i == 0) {
            path.moveTo(q.dx, q.dy);
          } else {
            path.lineTo(q.dx, q.dy);
          }
        }
        path.close();
      }
      paths[e.key] = path;
    }
  }
}

/// Quantisation of [_indiaStates]: 1/4 view box px.
const double _mapQuant = 4;

/// Digits of [_indiaStates]: a number's low 5-bit groups come first, every
/// group but the last from [_mapCont], the last from [_mapTerm].
const String _mapCont = 'ghijklmnopqrstuvwxyz0123456789+/';
const String _mapTerm = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef';

/// State outlines of the HTML's India map texture (the base64 SVG of
/// `buildS1Scene`, `<path id="pb" name="Punjab" d="m …">` and so on, 36
/// states and union territories in the SVG's order), generated by a script
/// that parses each path's m / l / z commands into rings, simplifies every
/// ring with Douglas–Peucker at a 0.75 px tolerance (view box px; islets
/// that would vanish are kept at a quarter of it), rounds the points to
/// 1/4 px and writes each ring as varints: the first point absolute, the
/// rest as zig-zag deltas ([_mapCont], [_mapTerm]); rings are separated by
/// '|'. 11,923 points become 4,638.
const Map<String, String> _indiaStates = {
  // Andaman and Nicobar Islands.
  'an':
      'ljC21CQoBHgBLKNjBNFAVEJ|5iCl1CIORUBVOD|+hCzzCMaXJ|siCzzCESLJ|uiCrzCC'
      'ODL|qiCizCEgBHIENHEDT|xhC/yCCIDD|ohC3yCMcRL|hhCtyCEGDA|xiClyCGSDAAI|'
      'sgCswCMGDMRCBN|1/B/rCMUBkBJKVDGNHb|ggCrqCIYPE|8/BoqCBCCH|8+BkqCKCAKJ'
      'B|3/BjqCGCHG|/gCupCKCDEFB|7gC+oCMaRT|9gC4oCAKDDBF|ghC0oCESPP|jhCvoCG'
      'MDKFH|lgCtoCAMIBFQMGHCBgBENGEFkBNIOBFgBPPELNJHZIPIMCnB|ogCuoCCAAGDA|'
      '2gCroCAGBBBEAF|khCroCCEEDBKFF|5gCpoCDIDJGCAF|rgCmoCSITkB|kjCmoCGOHB|'
      '6gC9nCDKBACJ|mgC6mCASDL|1gCymCOkBBkBHQNDKUdCFzBMLDZ|kgCsmCESHS|+gCrm'
      'CDGAGDBAHCE|ghC6kCKoBVASMDgBJMJFEOJBFSJXKVFBGpBMX|/gCxkCCIHD|ziCnhCD'
      'MAH',
  // Andhra Pradesh.
  'ap':
      'glBp8BBUFP|+kBp8BVBOGKW9BelBOdHtBOT2BdqBXCBVTFrBMZYlBoDM8BOYLwCgB4DX'
      'rBFMFJJQgBQMUNRlBHGGLGFUhBMKIFENNNGHLRBHEIEAQTQNHLYbLLACKHLbEPOGKPoB'
      'JBFONCRNLCIdKAINOGBLYfCRjBJEtBhBEDPNCGhBLHPMEXJKNFAMRMBKJHfSDbdABJJG'
      'AJJMIQdCDLMTRPIHNPWBAUUMcFOYGNRJMNHDaDAVTHAWPXVAHWbFJZQNRARVS/BRACR0'
      'BMMTFRIFRLNbIBAXQDLLEdeJ8CQiBCGHMMWPCRaJaEIFcMKVMICPyBHI3B0CbgBOSdLH'
      'CHcXOGSiBGFaQIDHHERlBHCNOGSTOOgBGMfsBDCPOAKLQEMNOxBiBRERmBVkBOELKAGP'
      'JJQTJBEPSVOQDKMCDSIIYRGTWQUDFLMRJADPWXMKCJeJPdSAIIAVMMQZUqBGPOiBaCKK'
      'qBHANQHBRKGQNCIMFJLSFKOpDoE9CyB7BsCjD0BnBgBTgBQO',
  // Arunachal Pradesh.
  'ar':
      'mpCjYOcUJGGHQlBSKSBQeXeJHQYqBXSCIbUIKROWMKNkBHSSUDQOQJ0BgBPYSKDYVB7B'
      '2BCesB+BDGtBPCPNPfBNOvBChBQPcVGNYHDLSLBRYTILFFhCsBRIZOIkBLOGUTFLVAGV'
      'PNDTkBtB9BCPOVIJFrCajCiBDHZCDJHGIQrCqCGMbSdIvCEXRjBFLOvCONzBIJFHODJH'
      'Fd/BALRMjBPPuBIQSyBZQOqBHefLNELuBZGGENgBFFTQLKZ0CLOGMfaVKXmBbUAMXaUC'
      'QmBGDHmCaOTICBPoBbeDWP',
  // Assam.
  'as':
      '44BujBAKDC|z+BwfwCNMNkBGYSuDLcRFLadyBrBHPIFEKaBEIkChBsCZKGWHQN+BBjBu'
      'BEUQOFWWAGMTUNFjBMNHHapCoBVBhBmBjBMZmBFRPSBWJERcDwBfUDbNKEM9B4BUUCYj'
      'B2BJmBNAAqBHCDejBGJZLejBoBJVhBCKXHXMpBJdKDQMQDJbKPWAeTBTjBZOVNEfhBlB'
      'OAZMRLFYZ/BQPXPMJcJFEPJBPgBIBfIRUDXhBGGLJAFLDIRHDIPHJKHLLMELJJ7BKjBq'
      'BUaXKJxBMXftBEVGCSPAhCwBDMRWH8BY6BBGHoBGMJQKgBDcTgBM',
  // Bihar.
  'br':
      '2pB1dea2BIMYHe2BQQOFGcBEUUEyBXSOBaUIAIeRgBOSDkCkBcHeVCYqBUWRWMMJQEEJ'
      'KGGJYWMfUBHMUYlBiBREAOTGFaSKBQYODUIUXJXQAWMKDOpBbFMJBBSZDDYNAJMCaNMD'
      'oBVHBURDDJRKLHPQJcbRIVfDNfRILLVDPYEUPDJOlBAhBcBLdMPbXYVEFQfdATRCBIFF'
      'FKTbTU9BAIRZdLpBGhByCrBFFSPcPCNgBKIPaOIJCICJMCRb7BVTTFZYACXrBPALYDGT'
      'gBIYDTXJCAVLEDJPADlBNAGTLLCLNAMLFHcA',
  // Chandigarh.
  'ch': 'zWkUPAFNSD',
  // Chhattisgarh.
  'ct':
      'znBznBgBOIeYIMoBcIALMBHuBSKFkBQKEUGJEIaAAUXYAMjBSFMMIHS7BaNWIGLCAQMK'
      'DMRMHSKKRCHUMcVFNsBLGZN1BGBUbmBRJEuBHMSYHgC2BMAeTKAPXHRORdHETNFINRNM'
      'BYkBWFyBKBGQKAHKIIDiBIIGgBLCBSNOREDKJBKQhBmBjBOH0BPclBHTMPzBGPTGDRFM'
      'JAINJbnBlBXGRdSLLbStBgBbGQYEQLJLSHJPdJCNTVNBCKNDSNPJUAEXHNRABRoBPAvB'
      'VDQLFrBPADNEbmBXIdBrBEHMCClBOdQKEdOLAZkBPMQURQAIPSFAlBePBVkBLGhBhBPJ'
      'TPCNJVMFPSXLhBIDUWYLUKcFEIwBEwBfWQaAQH',
  // Dadra and Nagar Haveli.
  'dn': 'lN8yBDMXBLLHZUBKNMOPKAOWH',
  // Daman and Diu.
  'dd': 'wGixBMnBYICKNGOGHKGKJE',
  // Delhi.
  'dl': 'yX0ZAOWQDcGMbSPTfCHPQJChBWLMI',
  // Goa.
  'ga': 'sO/+BaBGJWgBgBLKGAcOiBNGMMDaNUdAVbGJHfRNSBRH',
  // Gujarat.
  'gj':
      '5DpsBEGDEHF|wCosBACJICH|5E9rBCELECD|f8pBKCHK|iB2pBEEAEFDBD|YspBEGBID'
      'BAFFGBB|ZipBAGJKCJ|X/oBAEDEAF|OvoBMAFaLOTB|LvoBCMHGAP|asoBEONE|RpoBG'
      'KJA|VjoBAMNE|dioBIGJK|Z9nBGOLOEPHB|U9nBf6BFJCR|1H+lBgBOeLeGYFIMENMKS'
      'NSQgBARGgBOESORaKGQgBIKHCTQDBSYGXiBYQEQUVKkBLaaQAQKHOGDgBQGSFKUMFWOE'
      'WUBUuBQCEMPoBTBRYPFDIIAGQMJQOPOTHAaSYNOIK3BYOWBKPEMWqCLEMjBKHFBKPEBS'
      'RGBSfGHFMKQAESWGIqBVKCObIjBZHMQSRcGgBTAPQANVIBNSJLNJOTCIMPDHQPAavCbx'
      'CIDLBELJBFOFlBSrBLIFLGJiBJxBADFKVLXOrBcEcRbIjBHHOTfIaJHGULGFkBFVIJLe'
      'O6BNiBTcDDGSjDuBNO7CcFJIJNFOFBJXHLoBlBP5BrB/BtCIHDLJCES7D/DDLWfAQUDF'
      'UOKQNaACTKQQBMTMOaXkBD2B/CXaRHTECG3BOPUzCRpCrBbXOJdjBBfqBlBVCNOALYRT'
      'HiBAE7BKDKWKPIKQHSGiCHWUuBAUVsCXGEFamBGaVeJVHBREP',
  // Haryana.
  'hr':
      'vWvTWCSeYKHYQSiBMIJFMQHOOd0BXMZ0BAgEQUCUNMLHVMBiBPKIQgBBQUcRYSBaMGHG'
      'IGLSMYzBgBfFIQPABQPHO1CTNfYCOVKANNBIBHFIBDJfDMKJGIMbDGEJGMeHGNJVAFLS'
      'bHEHHQNKCbnBZHCHlBdN7BGPLBLXGXNGALPMFFRGFJNCFPNHnBOLXONHHGjBVCAHOPFN'
      'WGILSDgBaQLAWKEGJIQLSKWMDETWZUMWBMNSQaAkBXNLQhBJJUKCHKEENGSaEGXJJHGC'
      'HcLBLKHMAIOIFBnBPRET',
  // Himachal Pradesh.
  'hp':
      'kUqOGjBTVCLYIYXYDaf4BCIPKCDSSYkBMCMeUKNMGkBZIEMMDIaUBOMWiChBCaNKDOcC'
      'BIOILiBYGCScYLqBWiBTUwBuCTCNRXCHHVGRR5BcJFZYCULAKGBOHFHWOWHMMGAMjBOB'
      'KJLPIGLHKhBLPRIXXJRdHEpBZBhBGFHABNXAJfLYTEvB/DzBZOPFN0BjBNR',
  // Jammu and Kashmir.
  'jk':
      'vRFKKgBAaPMI8B0CmD8BgBiBWCSUBaOeuCQQQQiBcEgBNyBHiBpB4BXcBkBQKFAVYNec'
      '4BOcJUgBeUC0BlB+DpBUFcnBGOoBHePSrBFjBKDKc4BXYDeYWCO4BKJoBesBCelBYTDL'
      'IDSTGhBZFrBnCsBBTOJBZhCiBLVCNZTEHLLHDjBaLFJOdTBLjBLRXERJBHQ3BBZgBXEX'
      'YXHU4BTgBtBcDOFLXAvBfJKvBHHXItBjBaXDtCtBXAZdC1DLLKTTjBF/CqBVKhBwBJO3'
      'B7BhBBZQPHRvCHNNNjBTJZFfMHxBMdmBfkBpBIVOJ8CGQDbXGJQBkBSuCtB',
  // Jharkhand.
  'jh':
      'ioBsmB+BAUTUcGJGGCHSBAUgBeGPWDYXQceLCMiBbmBAKNQEDTQXWEMMSHOgBgBEHWcS'
      'KbQPMISJEKSECTWIEnBOLBZKLOAEXaECRKCGLiBUBciBkBZYOIFUIELILFGgBHUTKIST'
      'BCONFCOLGEElBJKaHBAQTHGIFElBNRIAa7BMVmBZJARPBFGGKfEGSJgBMMWBcc4BARMD'
      'aiBUGSSAGOHECIOGBOKEAILBHKtBXJIZZbHLNNUOaLMKKToBXDKPDFTM1BTVcVRTCWjB'
      'HhBbK9BAPMXCvBfOVYFcvBhBPFKDTPJGjBRJItBLCAMbHLnBXHHdfNOdDHMJJX',
  // Karnataka.
  'ka':
      'xPm/BCLQLEISFELFBEFGGKfPBKJKEERPPNCBTIBLTHCEHGICJKEQVMEEOUHATmBJCdaB'
      'WUKFCNeFEIOLQIHjBGPNVKPcSEHKAIQeFKMAJMDWMEJLLIJHRaLGRIAAKILMQERMHHLK'
      'GUHGvBaGWtBOHOMHOSIIHOEFOGSHISQXeIIRKBUYEQODDXMCKLAASLKDKSKGQN0BIGHC'
      'IEAKLEEIHGVESOqBIBIPIE4B9BBTSQePEAYHCOcSMHGGSLUzBLBSSCR+BSWSAPOKacGI'
      'VWAQYAVUIAWZEIELOSKFONXbGTLATVCOQHISQLUEMeBHPKLAKKFCKeAEcKBCJQEEJKIC'
      'JSLALOGKJDYQLMIFiBOBEQiBDDuBkBKBSXgBCMNFHOJADQbNHIJJDGAJVGJeXCBgBIBA'
      'MZkBsBGGKRcbCLedHVGAKRPPELiBtBFJNLGDPLEXVNCATlBENVLCXPPXJAJTIPLIJJIL'
      'HDJILTPCJVVGpB/FRZZzCIDNCHhBbNARcLKlBLLOFNhBAd',
  // Kerala.
  'kl':
      'vRgnCWFKWQBMUKHIEHMKKMHHQKUKAeiBWEOWmBDAUOBYWMDEWhBKCSyBUNcuBDFKISKA'
      'PCHScKMQDYJAC6BaOqBVIWBQLEMYR6BgBCISViBBaTWSaNUSiBLIFeJCTNnC3ChB3CR7'
      'CUYAyBYANFFzBFHDETrBEexCrHTTLjBtB1BLA',
  // Lakshadweep.
  'ld': '5M8yCDGDAGB|qOjuCBIAB|1L7sCCCFE|sOmsCECFA|9LrrCBEAB',
  // Madhya Pradesh.
  'mp':
      'na1fYFkBWaHmBSBGKDBWMWMCHQKCfoBKKZqBCKHFLQKYZKjBABQVUauBTGASbaSiBHcY'
      'YFKKKUVccOBGOefCPLDKFNZXGGlBZbCRLjBVFQDAJICBHOJIEFGSGDJMBJBDLSMBNSHF'
      'UOORBPQKMGTOBCMPGAQMJIECNIKFOMHGOKHIIAHMEFVOIBLNAGLICCMYBRUCKMDCKORG'
      'IqBGBZaDENSAWPIIASUUZcSEBJMDKGDJWGBPOSQALNWEIPEIRoBuBBKKELKGIrBkBSAL'
      'OLKIBSwBKAUKMaIOFDQMHBUKAAKUEETQKWJSKGSPBAgBICCQHcJASMDKKKvBgBvBDDHb'
      'GTJXMTVHEMiBRYGQWLOKQBKUiBQFiBjBMCWdQAmBRGHQPATSLPjBQAaNMDePJNeCcTQC'
      'sBLYbLNEFZRR5BSdNhBKHXpBHBMzBMESzCBHVhBMBKlBUXDjBIPBLbgBBLbJLfANOVFb'
      'WRABYZYGKHQVBFQbGRBJNKDLhBlEBfLJTZLRElBLHHChBNTnBSRPONRXAZUIQNPNLKFP'
      'HAEHQGSXUCQnBDLPBFXMHUEmBVlBVQX2BdDtBObPpBXDShBZHSdFDETQaURBHZCAhBMO'
      'UGMDIdeCDaFNDQaERKPRIOLMGIiCGYNOGBWOIAWLGHJLMSeNUOMVUDLPGJJJYUWSICbO'
      'KgBNBReLIrBEWsBDKOKPQHCWiBIGNPXFlBSAIOQTFZLJREHNaJPX0BTmBAF3BLBNWVFV'
      'MHHTChBZNxBSdkBNOZmBbOAWVQBAHgCZOTgBDCV',
  // Maharashtra.
  'mh':
      'zP3tBYEaPOUBiBIImBMSDaMKUSI0EGMiBJEKOSCcFGPWCIPFJaXCXSAcVWGONgBAKMMc'
      'fCMcQCkBHYEmBTCJiBLIW0CCDR0BLCLqBIIYiBJeO6BRSSGaODgBSlBYDMEeQAGsBPMW'
      'EAwBnBQCSSAIODYTAQKROOEBJOCUWBOcKMQRIKMPMXDFPPMhB+BMcRMGIbGjBZIFAbND'
      'ALOLGnBfhBzBQlBTDaHCjBPCRRBBRpBJREdVDMOMRWIkBVIBgBTBRRNIIGJgBHBHMgBk'
      'BREHWJACWXCAMHCGEJCEYNGRHINNLNIVuBZFFuBTKJFIMLIDSLPHMAJHAFSZMISHKMKD'
      'MVLLEAKJLdGHPJADIbRJQOWFQIkBPHNMDHdGBOJGVTZCBelBKAUTIDNLDPWJDBKFHDII'
      'BMUHCCUOBQQDSJDJKQCJgBFFDGGCDMRGDHhBgBZhBFKZClB3BN1BGHFCHTEVPjCIJRlB'
      'KBNRGFJTBbfjDWKCOANbVChBLbCRUBAJJEDJWPLLPKJUGZPrCGJLBJ5BOxBQAIPQEAOM'
      'MYCUbUAFfSbPRILkBacHBNWJHpBVFDRPALJIGgBFCRSFCRQDCJIGkBJDLpCMLVQDCJNV',
  // Manipur.
  'mn':
      'liCkkBYUgBxBFNqBJMMSDCKSCuBlBFiBWKRsBcQAUV4BJClBmCb4ChBRXEJNVBROPZLB'
      'PMAJZIDLPBKpBFJKfIBApBOAKlB',
  // Meghalaya.
  'ml':
      '44BujBYJTZkBpB+BJIKDMMLIMKJQIEHUICHGMKAFMiBFEYSTgBHHCQfKCDQKGMbOLQYg'
      'CPXaMGLSAamBPgBkBODNWkBaCUdUPDCGHBJQ7Bd1BCRKDJXIhBLpEKvCdVC',
  // Mizoram.
  'mz':
      'j/BmnBUBKWkBnBMdKaiBBHyBQCEMIHMGGFAKODKWIuBF2BHGGoBPYbHGYLSC0BOSCeJE'
      'CMRDFmBJHHQFVZPFYLIL7DPpBLHB3BIAXnDMR',
  // Nagaland.
  'nl':
      '2mCifGiCbqBMOD0BMGbgBGcTQFUNOfELHChBpBmBRBBJRELLVGTEGOfyBRHHjBTT+B3B'
      'DLOJEcgBTEvBSbKDCVQRGSalBkBLiBlBWC',
  // Odisha.
  'or':
      '9wBixBUAAKlBM|spBksBwBgBYBQL+BAcJIiBVkBUBWSWb2BUULEGJQYEUnBJJMLNZOTM'
      'OcIaaKHmBWAOMBGKgBKCgBKCMVMEEaeKIaRMrBGlBkBJgBY4BXKJWuBLrBgBHWIMlBYb'
      'qBXNUSjF+BtC+BZgBPNLGKMLGBHPOJFCSPIAOpBIJJZBNhBHEIOZrBPaLLAWHHRAQedK'
      'BKLJVYEQKALSGMTEVPFUXSHHERJBCJNPRWDQKCPUKKPanBLlCqBlBCQbIzBkBNiBlBJP'
      'KCEJSDONCRMBFfHHEhBHHIJJAFPJCGxBjBVEXMLOSGHUOIDSeSNYIAQUJAd1BLI/BRXI'
      'LDtBSKclBCT2BFaOMFOrBWGLbITSBJJIRSLELLJCPKBHFQV8BZGR',
  // Puducherry.
  'py': 'xemsCVNCNUC|sexpCVHKFNPGFMIBMSF|6kBr8BNFUD',
  // Punjab.
  'pb':
      'kUqODOOSzBkBGONQ0BawBgEUDMXKgBGFcSDqBSIWiBZGGOWCKQCoBHGHNLAJICMbMBII'
      'FKKFYZDFRDOJDBITJKKPiBOMjBYZARPLOVCTLVaDULEJVMRHPFKJDAVPMfZREHM9DLMd'
      'BZNVKRYLCPgBXGVmBdENKEMJLHLKHJCZWjBNHGNNdGVaZSCKTWEgBPIGUdFTYAGMENeN',
  // Rajasthan.
  'rj':
      'kP0VLsBoDGGONQAIWBFkBIINOMYoBNOIGQOBGKSFGGQLAMOFFYMYMCFQO8BmBeBIaIco'
      'BJBPOIIIDRcGMWAOKIFLdKFFDcEHLKFLJgBEEKHCIGHCOCAOWJBNgBXUOJ+CMACPQAHP'
      'QIKHSGGyBQMAMeKBIMUbUWOGFGKID3BcGYITSCYRYIAFSCEKORaGLGDSLABWfENU/BaA'
      'IPCVWNAlBcVgBbIReOyBiBaUBIIWLWGOVMCG4BlBAzBUQYZKIOSDMKGaPUHNRAGmBQYF'
      'OhBHBVPIJQJNrBEDVHsBdMCSfONJBcRHTVKXKKQFEMWTNLOTRdMLIKMFAVNHCVNFXOhC'
      'FFHMLHNQSSJZDEPGOEZdBHeLETFLNAiBaBCITSPZDUGEReaIRiBYEQqBNcEuB1BePYmB'
      'WlBWTDLINVTCCPbTLGJTRGPFEfNFJIAPZPMZJjBTWDPXPYhBXFCRPEBUJIfHFPZJNSDR'
      'fNSFfARPROLHDMHLXGdFdMfNbtBHnBlBtBA3BtBGTHdrBBXOfA5BRJpBCxBdDJQjCoCp'
      'CYzBkBhBgBBSUOmBWEgCbiCDoBRGfqBrBiBtC8CxB4BlDUpCiCX',
  // Sikkim.
  'sk': 'x1B+bgBQIcT4BIgBSODKPELWbJVUvBFVTMlBFNa3BNduBFYLMP',
  // Tamil Nadu.
  'tn':
      'kdlwCUclBP|oagnCDOsBKGNKCQnBFJQNcDIMBJMAcMMVOGUPAPHDIDSCIMOFOOGDJHiB'
      'LGTMFFFmBIOSAHGafqEzB6CRGCLLHFGOQJGWIFqBOkBCiCZEaWE6CxCDPKJUGStB4BPm'
      'BceUEzBEtCYnBoBBSMETQEaLWzBiBdGDKnBHjBdKBGdMHRhBOTRZUVCZWhBHRfBS5BLX'
      'MDCPHVpBWZNB5BKAEXLPbJIRQBJAHRGJtBEObxBTBRWBYTKOuBGMhBMDWQAJWFeIMdcB'
      'SbFJrBFajBALHCCfYBKdWFAKEFKKIH',
  // Telangana.
  'tg':
      'wY+3BDXKBFDIBALYBBVKAIVSDfjBILICKfHFOHSSUCCfWHHjBSVNLELeWSDqBKCSSCBS'
      'kBQIBEZmBU0BPgBiBFoBNMAOOCAcHGkBacFMWYFYSawBHOKAGLESUFFQQ0BUL2BIWBOL'
      'QGjBWNyBLOPDJMNABQrBELgBfFNNRUNFBOmBIDSIIHEZPFGRhBNFbYBIMIRefNzCcH4B'
      'xBIBQLHJWbL7BMBSVQLLFIhBBvBJD3BQHCHpBHRPWBIFDHMDAJHDIBHFOzBFPRJEJMJA'
      'RMABJYLEEPNXDCTSJHHYdRPIHFRGN',
  // Tripura.
  'tr':
      '6+BtmBOaJYOAGSB0BPmBHPRSRNCsBhBmBKgBlBaX1BLOGWHBH1BbrBALGECHHAAHKAKt'
      'BQCAXqBAGXQQBRQEKQCjBOCDLYA',
  // Uttar Pradesh.
  'up':
      'xYgVMByBgBhByBDYOkBcDGe6BvBaKSkB2BUhBaWMIUKBKICJQIGUYOKDIWUFEISASHCQ'
      'MFUYIPQFkC2BBVKDkBeoCgBSqBUDGOkCsBONSA+BwBsBHEoBsCKUYSPDNmBCoBYDEOAB'
      'MMMFUOAEmBQAEKMDAWKBUYXEfHFUXEAMsBQBYXACSYc8BWScLBBKBHHKZNHQfJBObQRQ'
      'GG1CwBE4BgBuBHSRGKYLKEIjBgCpBItBvBKAIbBPHBAfQCFRRJVKPJDUTDAJJACTLIEP'
      'NGZHJLATvBJCRJHNMAMjBRHsBJFDMJJtBCSnBDHHQVDMOPANRCQVFEKJFLECKRDabTTA'
      'RHHVQRADOZECapBFFHNSBJLEBJSTXCBLHBFMOACMNHGWLDAIHHJIFNLIGNHJBOHDLKAP'
      'QFBLNCFUJLQPSCNNGTRICORLEMKCLCEKRFGFHDNKCIHBAKPEWGMkBBSacFmBYFOaJGME'
      'BQdgBFNNCbbTWJJGJXXIbRhBcZARUFZtBWTCPkBAaJJXMPIGBJapBJJehBHHIPLBLVCV'
      'JECFlBRZIjBVXGBJMFHFRANSDJRBAGXHXSRBBQJBBR4BbHEFJFGVNcTLTCHdJTnBEPJT'
      'sBdLXMdLFCZddEbVPEnBPTGrBLxBQ7BQZYLanB',
  // Uttarakhand.
  'ut':
      '6cjSkB+BOAQSaLSGqBmBIFMKHSGS0BYKFmBgBkBORGbqBXIRgBVIGePcJCMaDUHDEQVI'
      'L0BPWTXLGBPRIRADHTGHVLEVNFTPHBKJHJCHTVLiBZ1BTRjBZJ5BwBFdbENjBOrBYdxB'
      'fLCqBZNLILNVIVIGCNJFMABTORWA6BbSSWFIIYBOSUBNTCVUZ',
  // West Bengal.
  'wb':
      'l1B3uBEECGJB|h2B2uBMKJA|41B1uBEEBGFD|o1B0uBIGFG|81ByuBEMHC|s2BzuBEEF'
      'AAH|t1BwuBAKHD|u2BuuBAGEECIDAADDFDH|+1BuuBAIFD|10BtuBIMHG|h1BtuBCGBK'
      'DJ|s0BsuBEOBIFP|02BsuBGOHEHJ|p1BsuBIGHI|l2BquBKIDM|+0BruBCGBICGFEBNE'
      'FDDCD|t0BquBOODU|p2BpuBIGHA|60BpuBAGCEDCBJ|w2BpuBGEDC|h2BpuBCYLN|s1B'
      'nuBGIBGFJ|t2BnuBGKBCHJ|u1BmuBCIDH|i1BmuBAKFCCH|31BkuBGcJD|p1BkuBEOHC'
      '|+0BkuBECDKDH|v2BkuBCACIFD|g2BluBCGHEGN|q2BhuBGEJK|t1BguBCEAGFD|30Bh'
      'uBIKHMJN|j2B/tBIYJJ|n0B+tBEYJWLJ|91BguBKBJM|t2B9tBGMJD|v1B8tBGGBOHN|'
      'q1B8tBCEBKDD|g1B8tBIINI|31B8tBKIBOLJ|x1B6tBECDE|h2B6tBWEJK|41B5tBMCC'
      'GDEBFJB|51B1tBCEGEHBBF|y1BxtBKEFKHB|n0BxtBJQFEEP|/1BxtBQCBOVF|y2BvtB'
      'GKFMJR|k2BstBCINB|i2BqtBCCLEAEDBEJGB|j2BitBKSNH|r2BitBFeIFIcRRBd|v2B'
      'htBGYLB|11BhtBQGRQIMPR|i2BltBRSFDSR|q2B/sBEEFEAH|/1B5sBDUFJ|i2B0sBQI'
      'DWRH|u2BwsBSqBFERV|m2BisBAOEMFEDX|p2BgsBMYJW|8zBxeWUwBGWT0BQAcIHIOKD'
      'SaoBLuBQBMmBECuBBORQFBDWGCPJEKJEGGFEIIRQRNNIfXJxBVLHSaWRCNJFMlBtBJET'
      'RDPFIHWaCGULBPQAMdOCWRWGUaB0B6BUGSJGecMPYLHHI7BFCeHSJADOJBFPNEGObkB2'
      'B0BkCUHeOYHOZKBoBecKBNsBuBIXmBUeHOGcRSEcHBhBuBBkBNKANREDUNHFQJBHTGzB'
      'VHGRJQJDFdLFKgBgBOKQjCqCxBOHZdJDZLDLWJBBffJFJLCANcFAHJDCNNFBHIDFNRAF'
      'RhBREbSL3BAbbVCNXMTFRgBDFJGFQCASaKWlB8BLAZSHmBQGFFHUIAPICJZmBKDDMFBN'
      'OGBNUCHRUJITFfMGMHHDGTNHaXhBjBCXIEENPXcXYGHPETXNCPRJGZUFANSDmBhBTXIL'
      'TCOrBHnBXV',
};

/// One thing the learner can drag: a crop card (S1) or an ingredient (S2).
class _Piece {
  _Piece(this.home) : pos = home;

  final _V home;

  /// Where it rests, or is held.
  _V pos;

  /// A glide to [pos] (HTML position tween), or null.
  _Glide? glide;

  /// Scene time it started to shrink away (used up), or -1.
  double shrinkAt = -1;

  bool get used => shrinkAt >= 0;

  /// Where it is drawn at [time].
  _V at(double time) => glide?.at(time) ?? pos;

  /// Its size at [time] (1, shrinking to 0 once used up).
  double scale(double time) => shrinkAt < 0
      ? 1
      : 1 - ((time - shrinkAt) / _shrinkSeconds).clamp(0.0, 1.0);

  void glideTo(_V to, double time, double seconds) {
    glide = _Glide(at(time), to, time, seconds);
    pos = to;
  }

  void reset() {
    pos = home;
    glide = null;
    shrinkAt = -1;
  }
}

/// One confetti piece (canvas-confetti): launch angle, speed, colour and
/// spin.
typedef _Confetto = ({double angle, double velocity, Color color, double spin});

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based); one past the last step once 'Review
  /// Findings' was tapped.
  int step = 1;

  /// A tool is working (HTML `State.s2.isAnimating`): drags wait.
  bool busy = false;

  /// 'Review Findings' is offered (HTML `triggerConclusionState`), and was
  /// tapped.
  bool conclusionReady = false;
  bool reviewed = false;

  /// Pending events, in scene time (the HTML tween `onComplete` callbacks
  /// and `setTimeout`s).
  final List<(double, VoidCallback)> _cues = [];

  // -------------------------------------------------------------- camera
  _Shot shot = _Shot.wide;
  _View view = _Shot.wide.view;
  _Framing framing = _Framing.base;
  _Cam cam = _Cam(_Shot.wide.view, _Framing.base);
  _View _fromView = _Shot.wide.view;
  _Framing _fromFraming = _Framing.base;
  double _glideStart = 0;
  double _glideSeconds = 0;
  Curve _glideCurve = Curves.easeOutCubic;

  /// Each view of the scenario fitted beside the cards; slides when the
  /// cards change.
  final Map<_Shot, _Framing> _fitNow = {};
  Map<_Shot, _Framing> _fitFrom = {};
  Map<_Shot, _Framing> _fitTo = {};
  double _fitT = 1;
  bool _settledReported = true;

  // ---------------------------------------------------------- scenario 1
  final Map<_Crop, _Piece> crops = {
    for (final c in _Crop.values) c: _Piece(c.home),
  };

  /// The crop card in the learner's hand (HTML `State.draggingObject`).
  _Crop? heldCrop;

  /// Zones whose crop was planted: their ring stays green (HTML
  /// `zoneOK`-like `0x22c55e`, opacity 0.5) and their state glows.
  final Set<_Zone> claimed = {};

  /// Rings lit while a crop is held within range (HTML opacity 1).
  final Set<_Zone> lit = {};

  /// The zone whose state is under the finger while a crop is held (added:
  /// the state glows).
  _Zone? hoverState;

  /// When each dish's models were called up (they pop in after a delay).
  final Map<_Dish, double> dishAt = {};

  /// Dishes whose names were revealed (HTML `lblSprite`).
  final Set<_Dish> named = {};

  /// HTML `State.s1.manRice` / `manBam`.
  bool manRice = false;
  bool manBamboo = false;

  // ---------------------------------------------------------- scenario 2
  final Map<_Ingredient, _Piece> ingredients = {
    for (final i in _Ingredient.values) i: _Piece(i.home),
  };

  /// The ingredient in the learner's hand.
  _Ingredient? heldIngredient;

  /// The task the tools are working on (HTML `startS2Progress`), since
  /// [taskStart]; null when none is shown.
  _Task? task;
  double taskStart = -1;

  /// Tasks finished (HTML `spiceSil`, `spiceGrind`, `doughChulha`,
  /// `doughGas`).
  final Set<_Task> done = {};

  /// The HTML's 'Reset & Try …' button is shown.
  bool resetOffered = false;

  /// The grinder jar holds the spices (`jar.material.color` 0xa16207).
  bool jarFilled = false;

  /// Roller and grinder animations (start times, or -1).
  double rollerStart = -1;
  double shakeStart = -1;

  /// The burning flame (chulha or gas stove) and when it was lit.
  _Tool? flame;
  double flameStart = -1;

  /// The dough puffs up and browns over [puffSeconds] from [puffStart]
  /// (-1: raw).
  double puffStart = -1;
  double puffSeconds = 1;

  // -------------------------------------------------------------- summary
  double? confettiAt;
  final List<_Confetto> confetti = () {
    final rnd = math.Random(3);
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

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  /// HTML `resetScenarioState(sc)`: everything back in place, the camera at
  /// the start view.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    conclusionReady = false;
    reviewed = false;
    _cues.clear();
    for (final p in crops.values) {
      p.reset();
    }
    heldCrop = null;
    claimed.clear();
    lit.clear();
    hoverState = null;
    dishAt.clear();
    named.clear();
    manRice = false;
    manBamboo = false;
    for (final p in ingredients.values) {
      p.reset();
    }
    heldIngredient = null;
    task = null;
    taskStart = -1;
    done.clear();
    resetOffered = false;
    jarFilled = false;
    rollerStart = -1;
    shakeStart = -1;
    flame = null;
    flameStart = -1;
    puffStart = -1;
    confettiAt = null;
    snapTo(_Shot.wide);
  }

  /// Runs [run] at scene time [at].
  void cue(double at, VoidCallback run) => _cues.add((at, run));

  /// Runs the cues that are due.
  void runCues() {
    if (!_cues.any((c) => c.$1 <= time)) return;
    final due = [
      for (final c in _cues)
        if (c.$1 <= time) c,
    ];
    _cues.removeWhere((c) => c.$1 <= time);
    for (final c in due) {
      c.$2();
    }
  }

  // --------------------------------------------------------------- camera

  /// The fitted framing of [s].
  _Framing fit(_Shot s) => _fitNow[s] ?? _Framing.base;

  /// HTML `new TWEEN.Tween(camera.position).to(…)` with `controls.target`
  /// (eased together).
  void glideTo(_Shot to, double seconds, Curve curve) {
    _fromView = view;
    _fromFraming = framing;
    shot = to;
    _glideStart = time;
    _glideSeconds = seconds;
    _glideCurve = curve;
    _settledReported = false;
  }

  void snapTo(_Shot to) {
    shot = to;
    _glideSeconds = 0;
    _settledReported = false;
    _update();
  }

  bool get gliding => time - _glideStart < _glideSeconds;

  void setFits(Map<_Shot, _Framing> fits, {required bool snap}) {
    if (snap) {
      _fitNow
        ..clear()
        ..addAll(fits);
      _fitFrom = Map.of(fits);
      _fitTo = Map.of(fits);
      _fitT = 1;
      _settledReported = false;
      _update();
      return;
    }
    final same = fits.entries.every(
      (e) => _fitTo[e.key]?.closeTo(e.value) ?? false,
    );
    if (same) return;
    _fitFrom = {for (final s in fits.keys) s: _fitNow[s] ?? fits[s]!};
    _fitTo = Map.of(fits);
    _fitT = 0;
    _settledReported = false;
  }

  /// The scene has stopped sliding and the camera has stopped gliding.
  bool get framingSettled => _fitT >= 1 && !gliding;

  /// True once each time the view comes to rest (the semantics boxes are
  /// then moved to where things are drawn).
  bool takeSettled() {
    if (_settledReported || !framingSettled) return false;
    _settledReported = true;
    return true;
  }

  /// HTML `animate()`: glides end, the framing slides, the camera glides.
  void advance(double dt) {
    for (final p in [...crops.values, ...ingredients.values]) {
      if (p.glide?.done(time) ?? false) p.glide = null;
    }
    if (_fitT < 1) {
      _fitT = math.min(1, _fitT + dt / _framingSeconds);
      final e = Curves.easeInOutCubic.transform(_fitT);
      for (final s in _fitTo.keys) {
        _fitNow[s] = (_fitFrom[s] ?? _fitTo[s]!).lerpTo(_fitTo[s]!, e);
      }
    }
    _update();
  }

  void _update() {
    final k = _glideSeconds <= 0
        ? 1.0
        : ((time - _glideStart) / _glideSeconds).clamp(0.0, 1.0);
    final e = _glideCurve.transform(k);
    view = _View.lerp(_fromView, shot.view, e);
    framing = _fromFraming.lerpTo(fit(shot), e);
    if (k >= 1) {
      _fromView = view;
      _fromFraming = framing;
    }
    cam = _Cam(view, framing);
  }

  // ----------------------------------------------------------- scenario 1

  /// Height of the dishes' bounce (HTML `Sinusoidal.InOut` yoyo, 0 → 0.2).
  double get bob =>
      _bobHeight * 0.5 * (1 - math.cos(math.pi * time / _bobHalf));

  /// Where [d]'s models stand now.
  _V dishPos(_Dish d) => d.base + _V(0, bob, 0);

  /// Size of [d]'s models (0 until called up, then `Elastic.Out` to 1).
  double dishScale(_Dish d) {
    final at = dishAt[d];
    if (at == null) return 0;
    final k = (time - at - _popDelay) / _popSeconds;
    if (k <= 0) return 0;
    return k >= 1 ? 1 : Curves.elasticOut.transform(k);
  }

  bool dishShown(_Dish d) => dishScale(d) > 0.05;

  /// Whether this step lets [c] be dragged (HTML `activeObjects` of steps
  /// 1, 3 and 5; the cactus can be picked up in step 1 but fits nowhere).
  bool cropWanted(_Crop c) => switch (step) {
    1 => c == _Crop.wheat || c == _Crop.cactus,
    3 => c == _Crop.rice,
    5 => (c == _Crop.rice && !manRice) || (c == _Crop.bamboo && !manBamboo),
    _ => false,
  };

  /// Screen rect of a crop card at [pos] with size [k].
  Rect cardRect(_V pos, double k) {
    final side = _cardSize * cam.scaleAt(pos) * k;
    return Rect.fromCenter(center: cam.p(pos), width: side, height: side);
  }

  /// The crop card at [p] (HTML raycast on the icon sprites): the card
  /// itself or, on a small screen, within a finger's reach of its centre.
  _Crop? cropAt(Offset p, double touch) {
    _Crop? best;
    var bestD = double.infinity;
    for (final e in crops.entries) {
      final piece = e.value;
      if (piece.used || e.key == heldCrop) continue;
      final r = cardRect(piece.at(time), 1);
      final d = (p - r.center).distance;
      if ((r.contains(p) || d <= touch) && d < bestD) {
        best = e.key;
        bestD = d;
      }
    }
    return best;
  }

  /// Screen box of [d]'s models (HTML hit `CylinderGeometry(1, 1, 1)`).
  Rect dishRect(_Dish d) {
    final c = dishPos(d);
    return cam.boxRect(c + const _V(-1, 0, -1), c + const _V(1, 1, 1));
  }

  /// The shown dish at [p], or null.
  _Dish? dishUnder(Offset p, double touch) {
    _Dish? best;
    var bestD = double.infinity;
    for (final d in _Dish.values) {
      if (!dishShown(d)) continue;
      final r = dishRect(d);
      final dist = (p - r.center).distance;
      if ((r.contains(p) || dist <= touch) && dist < bestD) {
        best = d;
        bestD = dist;
      }
    }
    return best;
  }

  /// The zone whose state lies under the screen point [p], or null.
  _Zone? zoneUnder(Offset p) {
    final w = cam.onPlaneY(p, _IndiaMap.corner.y);
    if (w == null) return null;
    for (final z in _Zone.values) {
      if (_IndiaMap.contains(z.state, w)) return z;
    }
    return null;
  }

  /// HTML `handleMove`: rings within range of the held card light up.
  void lightRings(_V card) {
    lit
      ..clear()
      ..addAll([
        for (final z in _Zone.values)
          if ((card - z.center).length < _zoneRange) z,
      ]);
  }

  /// Does a crop released at [card] (finger at [pointer]) land on [z]? The
  /// HTML only tests `distanceTo(zone.position) < 2` from the lifted card,
  /// whose zone centre can lie off the state (Karnataka's is in Andhra
  /// Pradesh); a release over the state as drawn counts as well.
  bool landsOn(_Zone z, _V card, Offset pointer) {
    if ((card - z.center).length < _zoneRange) return true;
    if (_IndiaMap.contains(z.state, card)) return true;
    final w = cam.onPlaneY(pointer, _IndiaMap.corner.y);
    return w != null && _IndiaMap.contains(z.state, w);
  }

  /// Screen rect around [z]'s state, centred on a point well inside it.
  Rect zoneRect(_Zone z) {
    final bounds = _IndiaMap.paths[z.state]!.getBounds();
    final a = cam.p(_IndiaMap.world(z.anchor));
    final corners = [
      cam.p(_IndiaMap.world(bounds.topLeft)),
      cam.p(_IndiaMap.world(bounds.topRight)),
      cam.p(_IndiaMap.world(bounds.bottomLeft)),
      cam.p(_IndiaMap.world(bounds.bottomRight)),
    ];
    final l = corners.map((o) => o.dx).reduce(math.min);
    final r = corners.map((o) => o.dx).reduce(math.max);
    final t = corners.map((o) => o.dy).reduce(math.min);
    final b = corners.map((o) => o.dy).reduce(math.max);
    final hw = math.max(4.0, math.min(a.dx - l, r - a.dx) * 0.8);
    final hh = math.max(4.0, math.min(a.dy - t, b - a.dy) * 0.8);
    return Rect.fromCenter(center: a, width: 2 * hw, height: 2 * hh);
  }

  // ----------------------------------------------------------- scenario 2

  /// Screen box of an ingredient at [pos] (HTML hit `CylinderGeometry(0.8,
  /// 0.8, 1)`).
  Rect ingredientRect(_V pos) =>
      cam.boxRect(pos + const _V(-0.8, 0, -0.8), pos + const _V(0.8, 1, 0.8));

  /// The ingredient at [p], or null.
  _Ingredient? ingredientAt(Offset p, double touch) {
    _Ingredient? best;
    var bestD = double.infinity;
    for (final e in ingredients.entries) {
      final piece = e.value;
      if (piece.used || e.key == heldIngredient) continue;
      final r = ingredientRect(piece.at(time));
      final d = (p - r.center).distance;
      if ((r.contains(p) || d <= touch) && d < bestD) {
        best = e.key;
        bestD = d;
      }
    }
    return best;
  }

  /// Screen box of [t]'s hit volume.
  Rect toolRect(_Tool t) => cam.boxRect(t.pos + t.hitMin, t.pos + t.hitMax);

  /// Does an ingredient released at [pos] (finger at [pointer]) land on
  /// [t]? HTML: `distanceTo(tool.position) < 2` from the lifted
  /// ingredient; a release over the tool as drawn counts as well.
  bool landsOnTool(_Tool t, _V pos, Offset pointer, double margin) {
    if ((pos - t.pos).length < _toolRange) return true;
    final r = toolRect(t).inflate(margin);
    return r.contains(pointer) || r.contains(cam.p(pos));
  }

  /// Fill of the progress bar (0 … 1).
  double get progress {
    final t = task;
    if (t == null) return 0;
    return ((time - taskStart) / t.seconds).clamp(0.0, 1.0);
  }

  /// Opacity of the progress card: fades in (300 ms), stays until 500 ms
  /// after the bar is full, then fades out (300 ms).
  double get progressOpacity {
    final t = task;
    if (t == null) return 0;
    final e = time - taskStart;
    final end = t.seconds + _progressTail;
    if (e < 0) return 0;
    if (e < _progressFade) return e / _progressFade;
    if (e < end) return 1;
    return (1 - (e - end) / _progressFade).clamp(0.0, 1.0);
  }

  /// The comic text shown while grinding (HTML `#anim-text-grind`,
  /// `#anim-text-whirr`), or null.
  String? get comicKey {
    final t = task;
    if (t == null || time - taskStart >= t.seconds) return null;
    return t.comicKey;
  }

  /// The sil-batta roller's sideways shift (0 … 0.5).
  double get rollerShift =>
      _rollerShift * _yoyo(time, rollerStart, _rollerLeg, _rollerLegs);

  /// The grinder's sideways shiver while it runs (HTML `rotation.y`
  /// shake).
  double get grinderShiver {
    if (shakeStart < 0) return 0;
    final e = time - shakeStart;
    if (e <= 0 || e >= _shakeLeg * _shakeLegs) return 0;
    return _shiver * (2 * _yoyo(time, shakeStart, _shakeLeg, _shakeLegs) - 1);
  }

  /// The flame sprite's scale now (x, y), flickering.
  (double, double) get flameScale {
    final f = flame;
    if (f == null) return (0, 0);
    if (f == _Tool.chulha) {
      final k = _yoyo(time, flameStart, 0.2, 1 << 30);
      return (_flameScale - 0.3 * k, _flameScale + 0.3 * k);
    }
    final k = _yoyo(time, flameStart, 0.1, 1 << 30);
    return (_flameScale + 0.1 * k, _flameScale + 0.1 * k);
  }

  /// How far the dough has puffed up and browned (0 … 1).
  double get puff =>
      puffStart < 0 ? 0 : ((time - puffStart) / puffSeconds).clamp(0.0, 1.0);

  /// Where the ingredient [i] is drawn now.
  _V ingredientPos(_Ingredient i) => ingredients[i]!.at(time);
}

/// What a view keeps in sight: a point of its projection at zoom 1 and a
/// rect around it that does not scale with the zoom (a label chip; empty
/// for a point of an object).
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

/// How a label chip sits on its anchor (x, y: -1 left / top edge, 0
/// centre, 1 right / bottom edge).
const (double, double) _centred = (0, 0);
const (double, double) _above = (0, 1);

/// Top-left of a chip of [size] relative to its anchor.
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// A label chip's look: background, border, text colour and text scale.
enum _ChipStyle {
  /// `createTextSprite` defaults.
  normal(_Colors.chipBg, _Colors.chipBorder, _Colors.chipText, 1),

  /// 'Inventory'.
  wood(_Colors.chipWood, _Colors.chipWoodBorder, _Colors.chipText, 1),

  /// 'Traditional Kitchen' (a larger sprite).
  trad(
    _Colors.chipWood,
    _Colors.chipWoodBorder,
    _Colors.chipText,
    _kitchenLabelScale,
  ),

  /// 'Modern Kitchen'.
  modern(
    _Colors.chipModern,
    _Colors.chipModernBorder,
    _Colors.chipText,
    _kitchenLabelScale,
  ),

  /// The dish names (`createRawTextSprite`).
  dish(_Colors.dishChip, _Colors.dishText, _Colors.dishText, _dishLabelScale);

  const _ChipStyle(this.bg, this.border, this.text, this.scale);

  final Color bg;
  final Color border;
  final Color text;
  final double scale;
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a crop, a food model or an ingredient ([canGrab]), so other drags
/// still pan / zoom the canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _FoodDiversityLabState
    extends State<Ch3A1FoodDiversityAndCulinaryEvolutionPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped when the view comes to rest or a piece comes or goes: the
  /// semantics boxes follow.
  final ValueNotifier<int> _layout = ValueNotifier(0);
  String _shownKey = '';
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), measured to fit the
  /// scene beside the cards.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch3-a1-canvas');

  /// Touch radius and label size in design px for the current stage scale.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The current pointer's grab: the scenario it began in, the drag-plane
  /// offset of the grab, the last pointer position and whether it moved.
  int _grabScenario = -1;
  _V _grabOffset = _V.zero;
  Offset _lastPointer = Offset.zero;
  bool _moved = false;

  /// The toast on screen (a string key), so it can follow a language
  /// switch.
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
    s.runCues();
    final key = _semanticsKey();
    if (s.takeSettled() || key != _shownKey) {
      _shownKey = key;
      _layout.value++;
    }
    _frame.value = now;
  }

  /// What the semantics boxes show besides the view: which pieces are
  /// there, held or gliding and which food models are up.
  String _semanticsKey() {
    final s = _scene;
    final b = StringBuffer('${s.scenario}${s.step}');
    for (final p in [...s.crops.values, ...s.ingredients.values]) {
      b.write(p.used ? 'u' : (p.glide != null ? 'g' : 'r'));
    }
    for (final d in _Dish.values) {
      b.write(s.dishShown(d) ? 'd' : '-');
    }
    b.write('${s.heldCrop?.index}${s.heldIngredient?.index}');
    return b.toString();
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the views after this frame (cards and canvas are laid out by
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

  /// Fits each view of the scenario into the part of the canvas no card
  /// covers: the tool column, the HUD (sidebar open) and the floating
  /// mission card (sidebar collapsed); the S2 close-ups also keep clear of
  /// the progress card. Never while something is held, so the scene does
  /// not move under the finger.
  void _updateFraming() {
    final s = _scene;
    if (s.heldCrop != null || s.heldIngredient != null) return;
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
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
    final k = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (open ? _hudBand * k + 8 : 8) - pad.bottom,
    );
    final hard = <Rect>[];
    if (!open && _lab.isLabActive) {
      final bottom = screen.height < _compactBelow
          ? _missionTop + pad.top + screen.height * _compactCardMax
          : size.height;
      hard.add(Rect.fromLTRB(0, 0, insets.left, bottom));
    }
    final band = Rect.fromLTRB(
      0,
      0,
      size.width,
      (_progressTop + _progressBand) * k + pad.top,
    );
    s
      ..labelLeft = math.max(0.0, (4 - stage.dx) / fit)
      ..labelRight = math.min(
        _design.width,
        (size.width - insets.right - stage.dx) / fit,
      );
    final area = toDesign(free).intersect(_stageRect);
    List<Rect> obstacles(List<Rect> rects) => [
      for (final r in rects) toDesign(r.inflate(_cardGap)),
    ];
    _cache.prepare(_lab.lang, _labelSize);
    s.setFits({
      for (final shot in _Shot.of(s.scenario))
        shot: _fitFraming(
          _focusFor(shot),
          area,
          obstacles(shot == _Shot.wide ? hard : [...hard, band]),
          shot == _Shot.wide ? _maxZoomWide[s.scenario] : _maxZoomClose,
        ),
    }, snap: _snapFraming);
    _snapFraming = false;
  }

  /// What a view must show (HTML camera, zoom 1): the map, shelf and crops
  /// (S1), the benches, tools and ingredients (S2) or the working tool
  /// (close-ups), with their label chips at their painted size.
  List<_Focus> _focusFor(_Shot shot) {
    final cam = _Cam(shot.view, _Framing.base);
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

    void chip(
      _V at,
      String key, {
      _ChipStyle style = _ChipStyle.normal,
      (double, double) align = _centred,
    }) {
      final size = _cache.chipSize(_t(key), style);
      items.add((cam.p(at), _chipOffset(size, align) & size));
    }

    void tool(_Tool t) {
      box(t.pos + t.hitMin, t.pos + t.hitMax);
      chip(t.labelAt, t.nameKey);
    }

    if (_scene.scenario == 0) {
      box(
        _IndiaMap.corner,
        _IndiaMap.corner +
            const _V(_IndiaMap.planeWidth, 0, _IndiaMap.planeDepth),
      );
      box(_shelfCenter - _shelfSize * 0.5, _shelfCenter + _shelfSize * 0.5);
      for (final c in _Crop.values) {
        const half = _cardSize / 2;
        box(c.home - const _V(half, half, 0), c.home + const _V(half, half, 0));
      }
      chip(_inventoryLabel, 'lbl_inventory', style: _ChipStyle.wood);
      for (final z in _Zone.values) {
        chip(z.labelAt, z.nameKey);
      }
      for (final d in _Dish.values) {
        box(d.base - const _V(1, 0, 1), d.base + const _V(1, 0.6, 1));
        chip(
          d.base + const _V(0, _dishLabelLift + _bobHeight, 0),
          d.nameKey,
          style: _ChipStyle.dish,
          align: _above,
        );
      }
      return items;
    }
    switch (shot) {
      case _Shot.wide:
        box(_benchTradMin, _benchTradMax);
        box(_benchModMin, _benchModMax);
        for (final t in _Tool.values) {
          tool(t);
        }
        for (final i in _Ingredient.values) {
          box(i.home - const _V(0.6, 0, 0.6), i.home + const _V(0.6, 0.5, 0.6));
          chip(i.home + const _V(0, _ingredientLabelLift, 0), i.nameKey);
        }
        chip(_tradLabel, 'lbl_trad', style: _ChipStyle.trad);
        chip(_modernLabel, 'lbl_modern', style: _ChipStyle.modern);
      case _Shot.silbatta || _Shot.grinder || _Shot.chulha || _Shot.gas:
        final t = _Tool.values.firstWhere((t) => t.shot == shot);
        tool(t);
        if (t == _Tool.chulha || t == _Tool.gas) {
          // The flame, flickering up to 1.8 high.
          final f = t.pos + _V(t == _Tool.gas ? -1 : 0, 0, 0);
          box(f + const _V(-0.5, 0.3, 0), f + const _V(0.5, 1.9, 0));
        }
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens and rebuilds the scenario's scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grabScenario = -1;
      _moved = false;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Rebuilds after a scene event.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// The HUD line of the current step.
  String get _hudText {
    final sc = _scene.scenario;
    final step = _scene.step.clamp(1, _stepCounts[sc]);
    return _t('s${sc + 1}_hud_$step');
  }

  /// Shows the toast [key]; [error] plays the wrong tone.
  void _toast(String key, {bool error = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: error);
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    final translated = labTr(_i18n, _lab.lang, key);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  /// What to do now, as a hint (a press on the wrong thing, or a tap
  /// without a drag).
  String get _hintKey {
    final s = _scene;
    if (s.scenario == 0) {
      return s.step <= 6 ? 'hint_s1_${s.step}' : 'hint_review';
    }
    if (s.step > _Task.values.length) return 'hint_review';
    final task = _Task.values[s.step - 1];
    if (s.done.contains(task) && s.resetOffered) {
      return task == _Task.silbatta ? 'need_reset_grinder' : 'need_reset_gas';
    }
    return 'hint_s2_${s.step}';
  }

  void _hint({bool error = true}) => _toast(_hintKey, error: error);

  /// HTML `progressStep()`.
  void _nextStep() {
    _scene.step += 1;
    _refresh();
  }

  /// HTML `triggerConclusionState()`: 'Review Findings' with a chime.
  void _offerReview() {
    _scene.conclusionReady = true;
    _Sound.success.play();
    _refresh();
  }

  // ----------------------------------------------------------- scenario 1

  /// HTML `handleUp` success branches of Scenario 1: the crop is used up
  /// (or, Rice on Karnataka, goes back for reuse), the state glows and its
  /// food models pop up.
  void _plant(_Crop crop, _Zone zone) {
    final s = _scene;
    final piece = s.crops[crop]!;
    final t = s.time;
    _Sound.correct.play();
    void claim(_Dish dish) {
      s.claimed.add(zone);
      s.dishAt[dish] = t;
      _nextStep();
    }

    switch (zone) {
      case _Zone.punjab:
        piece.shrinkAt = t;
        claim(_Dish.punjab);
      case _Zone.karnataka:
        piece.glideTo(crop.home, t, _returnSeconds);
        claim(_Dish.karnataka);
      case _Zone.manipur:
        piece.shrinkAt = t;
        if (crop == _Crop.rice) s.manRice = true;
        if (crop == _Crop.bamboo) s.manBamboo = true;
        if (s.manRice && s.manBamboo) {
          claim(_Dish.manipur);
        } else {
          _refresh();
        }
    }
  }

  /// HTML `handleInspection`: the dish's name appears; the next step
  /// follows a second later (after Manipur's, 'Review Findings').
  void _inspect(_Dish dish) {
    final s = _scene;
    if (s.named.contains(dish)) return;
    _Sound.click.play();
    s.named.add(dish);
    final scenario = s.scenario;
    s.cue(s.time + _inspectSeconds, () {
      if (s.scenario != scenario || s.step != dish.step) return;
      _nextStep();
      if (s.step > 6) _offerReview();
    });
    _refresh();
  }

  /// The zone each draggable crop of this step goes to.
  _Zone? _targetOf(_Crop crop) => switch (_scene.step) {
    1 when crop == _Crop.wheat => _Zone.punjab,
    3 when crop == _Crop.rice => _Zone.karnataka,
    5 when crop == _Crop.rice || crop == _Crop.bamboo => _Zone.manipur,
    _ => null,
  };

  /// The 'missed' toast for [crop] in this step.
  String _missKey(_Crop crop) => switch (crop) {
    _Crop.cactus => 'wrong_cactus',
    _Crop.wheat => 'miss_wheat',
    _Crop.bamboo => 'miss_bamboo',
    _Crop.rice => _scene.step == 3 ? 'miss_rice_karn' : 'miss_rice_man',
  };

  // ----------------------------------------------------------- scenario 2

  /// The task of this step, if it still waits for its ingredient.
  _Task? get _openTask {
    final s = _scene;
    if (s.step < 1 || s.step > _Task.values.length) return null;
    final task = _Task.values[s.step - 1];
    return s.done.contains(task) ? null : task;
  }

  /// HTML `handleUp` success branches of Scenario 2 and `startS2Progress`:
  /// the ingredient goes onto (or into) the tool, the camera closes in and
  /// the tool works for its time with a progress bar.
  void _startTask(_Task task) {
    final s = _scene;
    final t = s.time;
    final piece = s.ingredients[task.ingredient]!;
    _Sound.correct.play();
    task.sound.play();
    s
      ..busy = true
      ..task = task
      ..taskStart = t;
    s.done.add(task);
    final rest = task.rest;
    if (rest != null) {
      piece.glideTo(rest, t, _moveSeconds);
    } else {
      piece.shrinkAt = t;
    }
    switch (task) {
      case _Task.silbatta:
        s.rollerStart = t;
      case _Task.grinder:
        s
          ..jarFilled = true
          ..shakeStart = t;
      case _Task.chulha || _Task.gas:
        s
          ..flame = task.tool
          ..flameStart = t
          ..puffStart = t
          ..puffSeconds = task.seconds;
    }
    s.glideTo(task.tool.shot, _camInSeconds, Curves.easeOutCubic);
    final end = t + task.seconds + _progressTail;
    s.cue(end, () => _finishTask(task));
    s.cue(end + _progressFade, () {
      if (s.task == task) s.task = null;
    });
    _refresh();
  }

  /// The task's `onComplete`: the flame goes out, the camera returns, and
  /// either the 'Reset & Try …' button appears (sil-batta, chulha) or the
  /// next step begins (grinder; gas stove, then 'Review Findings').
  void _finishTask(_Task task) {
    final s = _scene;
    s.busy = false;
    if (s.flame == task.tool) s.flame = null;
    s.glideTo(_Shot.wide, _camOutSeconds, Curves.easeInOutCubic);
    if (task.needsReset) {
      s.resetOffered = true;
      _refresh();
    } else {
      _nextStep();
      if (task == _Task.gas) _offerReview();
    }
    _scheduleFraming();
  }

  /// HTML `executeStepAction()`: the spice bowl or the dough is put back on
  /// the table as it was, and the next step begins.
  void _tryModern() {
    final s = _scene;
    if (!s.resetOffered) return;
    s.resetOffered = false;
    if (s.step == 1) {
      s.ingredients[_Ingredient.spices]!.reset();
    } else if (s.step == 3) {
      s.ingredients[_Ingredient.dough]!.reset();
      s.puffStart = -1;
    }
    _nextStep();
  }

  /// The 'missed' toast for this step's ingredient.
  String _missIngredientKey(_Task task) => switch (task) {
    _Task.silbatta => 'miss_spices_sil',
    _Task.grinder => 'miss_spices_grinder',
    _Task.chulha => 'miss_dough_chulha',
    _Task.gas => 'miss_dough_gas',
  };

  // --------------------------------------------------------------- summary

  /// HTML `triggerConclusion()`: the summary popup ('success') and
  /// confetti; the button hides once tapped.
  void _review() {
    final s = _scene;
    if (!s.conclusionReady || s.reviewed) return;
    final sc = s.scenario;
    setState(() {
      s
        ..reviewed = true
        ..step = _stepCounts[sc] + 1
        ..confettiAt = s.time;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _t('sum_title'),
      heading: () => _t('sum_heading'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => _SummaryVisual(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
        ),
      ),
    );
  }

  /// The HTML's own buttons: 'Reset & Try …' (HTML `#action-btn-container`)
  /// and 'Review Findings' (HTML `#compare-btn-container`).
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 1 && s.resetOffered) {
      return [
        LabAction(
          label: _t(s.step == 1 ? 'btn_reset_grinder' : 'btn_reset_gas'),
          icon: Icons.refresh,
          color: _Colors.amber600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _tryModern,
        ),
      ];
    }
    if (s.conclusionReady && !s.reviewed) {
      return [
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.check_circle,
          color: _Colors.amber600,
          foreground: _Colors.white,
          highlight: true,
          // The summary plays the HTML `success`.
          silent: true,
          onTap: _review,
        ),
      ];
    }
    return const [];
  }

  // -------------------------------------------------------------- gestures

  /// HTML `handleDown`: a press on a crop card or a food model (S1) or on
  /// an ingredient (S2), not while a tool works.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grabScenario >= 0) return false;
    final p = event.localPosition;
    if (s.scenario == 0) {
      return s.dishUnder(p, _touch) != null || s.cropAt(p, _touch) != null;
    }
    return !s.busy && s.ingredientAt(p, _touch) != null;
  }

  /// Taps a food model (S1 inspection steps) or picks up a crop or an
  /// ingredient. The HTML only reacted to the step's objects; a press on
  /// another one now says what to do instead.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final p = d.localPosition;
    if (s.scenario == 0) {
      final dish = s.dishUnder(p, _touch);
      if (dish != null) {
        // The tapped dish names itself (once); another dish gets a hint.
        if (s.step == dish.step) {
          _inspect(dish);
        } else {
          _hint(error: false);
        }
        return;
      }
      final crop = s.cropAt(p, _touch);
      if (crop == null) return;
      if (!s.cropWanted(crop)) {
        _hint();
        return;
      }
      final piece = s.crops[crop]!;
      _grab(piece, p, _s1PlaneY, _s1HeldY - _s1PlaneY);
      s.heldCrop = crop;
      return;
    }
    if (s.busy) return;
    final ingredient = s.ingredientAt(p, _touch);
    if (ingredient == null) return;
    final task = _openTask;
    if (task == null || task.ingredient != ingredient) {
      _hint();
      return;
    }
    _grab(s.ingredients[ingredient]!, p, _s2PlaneY, 0.5);
    s.heldIngredient = ingredient;
  }

  /// HTML grab: the drag-plane offset of the grab is kept and the piece is
  /// lifted by [lift].
  void _grab(_Piece piece, Offset p, double planeY, double lift) {
    final s = _scene;
    final rest = piece.at(s.time);
    final hit = s.cam.onPlaneY(p, planeY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - rest.x, 0, hit.z - rest.z);
    piece
      ..glide = null
      ..pos = rest + _V(0, lift, 0);
    _grabScenario = s.scenario;
    _lastPointer = p;
    _moved = false;
  }

  /// HTML `handleMove`: the piece follows the finger on the drag plane,
  /// lifted to y = 1.5 (crops) or 2.5 (ingredients); in S1 the rings in
  /// range light up and the state under the finger glows (added).
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (_grabScenario != s.scenario) return;
    final crop = s.heldCrop;
    final ingredient = s.heldIngredient;
    final piece = crop != null
        ? s.crops[crop]
        : (ingredient != null ? s.ingredients[ingredient] : null);
    if (piece == null) return;
    _lastPointer = d.localPosition;
    _moved = true;
    final planeY = crop != null ? _s1PlaneY : _s2PlaneY;
    final heldY = crop != null ? _s1HeldY : _s2HeldY;
    final hit = s.cam.onPlaneY(d.localPosition, planeY);
    if (hit == null) return;
    piece.pos = _V(hit.x - _grabOffset.x, heldY, hit.z - _grabOffset.z);
    if (crop != null) {
      s.lightRings(piece.pos);
      s.hoverState = s.zoneUnder(d.localPosition);
    }
  }

  void _onDragEnd(DragEndDetails _) => _release(cancel: false);

  void _onDragCancel() => _release(cancel: true);

  /// HTML `handleUp`: a crop on its state or an ingredient on its tool
  /// works ('success'); anything else glides back (`playSound('error')`)
  /// and a toast says why (added). A press without a drag says what to do.
  void _release({required bool cancel}) {
    final s = _scene;
    final scenario = _grabScenario;
    final moved = _moved;
    _grabScenario = -1;
    _moved = false;
    final crop = s.heldCrop;
    final ingredient = s.heldIngredient;
    s
      ..heldCrop = null
      ..heldIngredient = null
      ..lit.clear()
      ..hoverState = null;
    if (scenario != s.scenario) return;
    if (crop != null) {
      final piece = s.crops[crop]!;
      final zone = _targetOf(crop);
      if (!cancel &&
          moved &&
          zone != null &&
          s.landsOn(zone, piece.pos, _lastPointer)) {
        _plant(crop, zone);
      } else {
        piece.glideTo(crop.home, s.time, _returnSeconds);
        if (!cancel) {
          if (moved) {
            _toast(_missKey(crop), error: true);
          } else {
            _hint(error: false);
          }
        }
        _refresh();
      }
    } else if (ingredient != null) {
      final piece = s.ingredients[ingredient]!;
      final task = _openTask;
      if (!cancel &&
          moved &&
          task != null &&
          task.ingredient == ingredient &&
          s.landsOnTool(task.tool, piece.pos, _lastPointer, _touch * 0.5)) {
        _startTask(task);
      } else {
        piece.glideTo(ingredient.home, s.time, _returnSeconds);
        if (!cancel && task != null) {
          if (moved) {
            _toast(_missIngredientKey(task), error: true);
          } else {
            _hint(error: false);
          }
        }
        _refresh();
      }
    }
    _scheduleFraming();
  }

  // ---------------------------------------------------- screen readers

  /// A screen-reader tap on a crop or an ingredient (added): says what to
  /// do with it.
  void _activatePiece() {
    if (_lab.isLabActive) _hint(error: false);
  }

  /// A screen-reader tap on a state (added): at a planting step it plants
  /// the step's crop there, as a drag would.
  void _activateZone(_Zone z) {
    final s = _scene;
    if (!_lab.isLabActive || s.heldCrop != null) return;
    final crop = switch (s.step) {
      1 => _Crop.wheat,
      3 => _Crop.rice,
      5 => s.manRice ? _Crop.bamboo : _Crop.rice,
      _ => null,
    };
    if (crop != null && _targetOf(crop) == z) {
      _plant(crop, z);
    } else {
      _hint(error: crop != null);
    }
  }

  /// A screen-reader tap on a food model (added): names the dish.
  void _activateDish(_Dish d) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    if (s.step == d.step && !s.named.contains(d)) {
      _inspect(d);
    } else {
      _hint(error: false);
    }
  }

  /// A screen-reader tap on a tool (added): at its step it puts the
  /// ingredient there, as a drag would.
  void _activateTool(_Tool t) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.heldIngredient != null) return;
    final task = _openTask;
    if (task != null && task.tool == t) {
      _startTask(task);
    } else {
      _hint(error: task != null);
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
        final p = _lab.palette;
        final s = context.labScale;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final hud = _hudText;
        final insets = labOverlayInsets(context, _lab);
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.rice_bowl,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          instruction: hud,
          hud: hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('steps_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-${_scene.step}'),
            steps: _stepData,
            current: _scene.step,
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
            // HTML `#progress-overlay` and the comic texts (S2); they take
            // no touches.
            if (sc == 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: _TaskOverlay(
                    scene: _scene,
                    frame: _frame,
                    palette: p,
                    scale: s,
                    top: _progressTop * s + MediaQuery.paddingOf(context).top,
                    insets: insets,
                    t: _t,
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
              // One semantics node per crop, state, food model, ingredient
              // and tool where it is drawn (added), so a screen reader can
              // find and use them. They take no touches: those reach the
              // scene below.
              ValueListenableBuilder<int>(
                valueListenable: _layout,
                builder: (context, _, _) =>
                    Stack(fit: StackFit.expand, children: _semanticsBoxes()),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _semanticsBoxes() {
    final s = _scene;
    Widget node(Rect rect, String label, VoidCallback onTap) =>
        Positioned.fromRect(
          rect: rect,
          child: Semantics(
            container: true,
            button: true,
            label: label,
            onTap: onTap,
            child: const SizedBox.expand(),
          ),
        );
    if (s.scenario == 0) {
      return [
        for (final z in _Zone.values)
          node(s.zoneRect(z), _t(z.nameKey), () => _activateZone(z)),
        for (final d in _Dish.values)
          if (s.dishShown(d))
            node(s.dishRect(d), _t(d.semanticsKey), () => _activateDish(d)),
        for (final e in s.crops.entries)
          if (!e.value.used)
            node(
              s.cardRect(e.value.at(s.time), 1),
              _t(e.key.nameKey),
              _activatePiece,
            ),
      ];
    }
    return [
      for (final t in _Tool.values)
        node(s.toolRect(t), _t(t.nameKey), () => _activateTool(t)),
      for (final e in s.ingredients.entries)
        if (!e.value.used)
          node(
            s.ingredientRect(e.value.at(s.time)),
            _t(e.key.nameKey),
            _activatePiece,
          ),
    ];
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and result (and the HTML explanation). The current
/// step is open, done steps show a tick and can be re-opened, future steps
/// are dimmed. A step's focus, result and explanation are shown once the
/// step is done (the HTML showed them before the learner had seen them).
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
                  if (past && step.focus.isNotEmpty) ...[
                    _heading(w.focusLabel, accent),
                    SizedBox(height: 3 * s),
                    _body(step.focus, p.textStrong),
                    SizedBox(height: 8 * s),
                  ],
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
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

/// HTML `#progress-overlay` (a glass card with an amber border: 'Grinding…'
/// or 'Cooking…', the simulated time and a filling amber bar) and the comic
/// texts `#anim-text-grind` ("⚡ GRIND! SCRAPE!", left 20%, top 35%, turned
/// -12°) and `#anim-text-whirr` ("WHIRRRR! ⚡", left 65%, turned 6°) shown
/// while a tool works. Repaints with the scene.
class _TaskOverlay extends StatelessWidget {
  const _TaskOverlay({
    required this.scene,
    required this.frame,
    required this.palette,
    required this.scale,
    required this.top,
    required this.insets,
    required this.t,
  });

  final _Scene scene;
  final ValueListenable<double> frame;
  final LabPalette palette;
  final double scale;

  /// Top of the progress card in the canvas.
  final double top;

  /// The shell's overlay insets (tool column, mission card).
  final EdgeInsets insets;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: frame,
      builder: (context, _, _) {
        final task = scene.task;
        final opacity = scene.progressOpacity;
        final comic = scene.comicKey;
        if (task == null || (opacity <= 0 && comic == null)) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              if (comic != null)
                Positioned(
                  left: box.maxWidth * (comic == 'comic_grind' ? 0.2 : 0.65),
                  top: box.maxHeight * 0.35,
                  child: _comic(t(comic), comic == 'comic_grind'),
                ),
              if (opacity > 0)
                Positioned(
                  top: top,
                  left: insets.left,
                  right: insets.right,
                  child: Center(
                    child: Opacity(opacity: opacity, child: _card(task)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// The comic text: white, black-weight italics with a 2 px outline of
  /// amber-600 (grind) or sky-600 (whirr).
  Widget _comic(String text, bool grind) {
    final edge = grind ? _Colors.amber600 : _Colors.sky600;
    return Transform.rotate(
      angle: (grind ? -12 : 6) * math.pi / 180,
      child: Text(
        text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: 26 * scale,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: labLetterSpacing(text, 1.5),
          height: 1.1,
          shadows: [
            for (final o in const [
              Offset(2, 2),
              Offset(-2, -2),
              Offset(2, -2),
              Offset(-2, 2),
            ])
              Shadow(color: edge, offset: o),
            const Shadow(
              color: Color(0x66000000),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(_Task task) {
    final p = palette;
    final s = scale;
    final label = t(task.labelKey);
    return Container(
      width: _progressWidth * s,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Colors.amber500, width: 2),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: labLetterSpacing(label, 1),
                  ),
                ),
              ),
              Text(
                task.time,
                style: TextStyle(
                  color: p.ink(_Colors.amber500),
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 5 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12 * s,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: p.isDark ? _Colors.slate700 : _Colors.slate200,
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: scene.progress,
                    child: const ColoredBox(color: _Colors.amber500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML `#summary-visual-area`. Scenario 1: 'Regional Diversity: Explored!'
/// and three columns (Wheat ➔ Punjab, Rice ➔ Karnataka, Rice & Bamboo ➔
/// Manipur) with the crop icons and food emojis, then the HTML's 'select
/// the next scenario' note. Scenario 2: a chalkboard comparing the
/// Traditional Kitchen (total 18s) with the Modern Kitchen (total 5s), two
/// stopwatches, a falling-time graph and 'TECHNOLOGY: INCREASED
/// EFFICIENCY!'.
class _SummaryVisual extends StatelessWidget {
  const _SummaryVisual({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.t,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) =>
      scenario == 0 ? _regional() : _kitchens();

  // ---------------------------------------------------------- scenario 1

  Widget _regional() {
    final p = palette;
    final s = scale;
    final title = t('sum_r_div');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.ink(_Colors.amber400),
            fontSize: 15 * s,
            fontWeight: FontWeight.w900,
            letterSpacing: labLetterSpacing(title, 2),
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 6 * s),
          decoration: BoxDecoration(
            color: _Colors.slate900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Colors.slate700),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _region(
                    const [_Art.wheat],
                    '${t('crop_wheat')} ➔ ${t('lbl_punjab')}',
                    '🥘 🥛',
                  ),
                ),
                _rule(),
                Expanded(
                  child: _region(
                    const [_Art.rice],
                    '${t('crop_rice')} ➔ ${t('lbl_karnataka')}',
                    '🍛 ☕',
                  ),
                ),
                _rule(),
                Expanded(
                  child: _region(
                    const [_Art.rice, _Art.bamboo],
                    '${t('crop_rice')} & ${t('crop_bamboo')} ➔ '
                        '${t('lbl_manipur')}',
                    '🍲 🍜',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.all(11 * s),
          decoration: BoxDecoration(
            color: _Colors.amber500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.amber500.withValues(alpha: 0.2)),
          ),
          child: Text(
            t('next_msg'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(_Colors.amber400),
              fontSize: 12.5 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// A thin vertical rule between the regions (`h-16 w-px bg-slate-700`).
  Widget _rule() => Container(
    width: 1,
    margin: EdgeInsets.symmetric(vertical: 6 * scale),
    color: _Colors.slate700,
  );

  Widget _region(List<_Art> icons, String caption, String emoji) {
    final s = scale;
    final side = icons.length == 1 ? 44 * s : 22 * s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 44 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < icons.length; i++) ...[
                if (i > 0) SizedBox(width: 3 * s),
                SizedBox(
                  width: side,
                  height: side,
                  child: CustomPaint(painter: _ArtPainter(icons[i])),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _Colors.slate400,
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        SizedBox(height: 6 * s),
        Text(emoji, style: TextStyle(fontSize: 22 * s)),
      ],
    );
  }

  // ---------------------------------------------------------- scenario 2

  Widget _kitchens() {
    final s = scale;
    final result = t('sum_res');
    return Container(
      padding: EdgeInsets.all(11 * s),
      decoration: BoxDecoration(
        color: _Colors.board,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.boardFrame, width: 4),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _kitchen(
                    t('lbl_trad'),
                    t('sum_t_time'),
                    _Colors.tradFrame,
                    _Colors.tradBody,
                    _Colors.tradHeader,
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: _kitchen(
                    t('lbl_modern'),
                    t('sum_m_time'),
                    _Colors.modFrame,
                    _Colors.modBody,
                    _Colors.modHeader,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            children: [
              SizedBox(width: 8 * s),
              _watch('195', _Colors.amber400, _Colors.amber400, bottom: true),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: SizedBox(
                    height: 56 * s,
                    child: const CustomPaint(painter: _GraphPainter()),
                  ),
                ),
              ),
              _watch('55', _Colors.white, _Colors.emerald400, bottom: false),
              SizedBox(width: 8 * s),
            ],
          ),
          SizedBox(height: 10 * s),
          Text(
            result.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Colors.white,
              fontSize: 11 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(result, 2.5),
            ),
          ),
        ],
      ),
    );
  }

  /// One kitchen's panel: coloured header and 'Total' with its time.
  Widget _kitchen(
    String name,
    String time,
    Color frame,
    Color body,
    Color header,
  ) {
    final s = scale;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: body,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: frame, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: header,
            padding: EdgeInsets.symmetric(vertical: 5 * s, horizontal: 4 * s),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Colors.black,
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * s),
            child: Column(
              children: [
                Text(
                  t('sum_total'),
                  style: TextStyle(
                    color: _Colors.white,
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: _Colors.white,
                    fontSize: 26 * s,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A stopwatch: dark face, crown and side button, its reading and a
  /// half ring ([bottom] half amber, else the top half emerald).
  Widget _watch(String value, Color text, Color ring, {required bool bottom}) {
    final s = scale;
    return SizedBox(
      width: 56 * s,
      height: 66 * s,
      child: CustomPaint(
        painter: _StopwatchPainter(ring: ring, bottom: bottom),
        child: Padding(
          padding: EdgeInsets.only(top: 10 * s),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: text,
                fontSize: 17 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The summary's stopwatch: a `#2d2d2d` face with a 3 px slate-300 rim, a
/// crown on top and a small button at the upper right, and a 3 px half
/// ring inside the rim.
class _StopwatchPainter extends CustomPainter {
  const _StopwatchPainter({required this.ring, required this.bottom});

  final Color ring;
  final bool bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, size.height - r);
    final rim = r * 0.1;
    final metal = Paint()..color = _Colors.slate300;
    // Crown and side button.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: c - Offset(0, r + r * 0.16),
            width: r * 0.5,
            height: r * 0.34,
          ),
          Radius.circular(r * 0.06),
        ),
        metal,
      )
      ..save()
      ..translate(c.dx + r * 0.62, c.dy - r * 0.92)
      ..rotate(math.pi / 4)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: r * 0.3,
            height: r * 0.16,
          ),
          Radius.circular(r * 0.04),
        ),
        metal,
      )
      ..restore()
      ..drawCircle(c, r - rim / 2, Paint()..color = _Colors.watchFace)
      ..drawCircle(
        c,
        r - rim / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rim
          ..color = _Colors.slate300,
      )
      ..drawArc(
        Rect.fromCircle(center: c, radius: r - rim * 2.6),
        bottom ? 0 : math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rim
          ..color = ring,
      );
  }

  @override
  bool shouldRepaint(covariant _StopwatchPainter old) =>
      old.ring != ring || old.bottom != bottom;
}

/// The summary's graph (`viewBox 0 0 100 60`): three rising polylines, red,
/// amber and green, 4 wide with round caps.
class _GraphPainter extends CustomPainter {
  const _GraphPainter();

  static const List<(Color, List<Offset>)> _lines = [
    (
      _Colors.red500,
      [Offset(0, 50), Offset(30, 50), Offset(60, 30), Offset(100, 10)],
    ),
    (
      _Colors.amber500,
      [Offset(0, 55), Offset(30, 55), Offset(60, 45), Offset(100, 25)],
    ),
    (
      _Colors.green500,
      [Offset(0, 60), Offset(30, 60), Offset(60, 55), Offset(100, 45)],
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final k = math.min(size.width / 100, size.height / 60);
    canvas
      ..save()
      ..translate((size.width - 100 * k) / 2, (size.height - 60 * k) / 2)
      ..scale(k);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final (color, points) in _lines) {
      canvas.drawPath(Path()..addPolygon(points, false), pen..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) => false;
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();

  /// Cylinder facets: not anti-aliased, so neighbouring facets leave no
  /// seams (the cylinder's outline is drawn smooth on top).
  final Paint facet = Paint()..isAntiAlias = false;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Butt-ended shading bands along limbs.
  final Paint band = Paint()..style = PaintingStyle.stroke;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Flame sprites (`THREE.AdditiveBlending`).
  final Paint flame = Paint()..blendMode = BlendMode.plus;
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the projected map, the
/// shaded-ball shaders (one per colour, drawn on a unit circle) and the
/// label text painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final _MapProjection map = _MapProjection();
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

  /// A bold label in [color], [scale] times the label size.
  TextPainter label(
    String text, {
    Color color = _Colors.chipText,
    double scale = 1,
  }) => _labels['${color.toARGB32()}|$scale|$text'] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: _labelSize * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Size of a label chip with [text] in [style].
  Size chipSize(String text, _ChipStyle style) {
    final tp = label(text, color: style.text, scale: style.scale);
    final k = _labelSize * style.scale;
    return Size(tp.width + 2 * _chipPadX * k, tp.height + 2 * _chipPadY * k);
  }

  /// MeshStandardMaterial look for a sphere of [c]: a radial gradient on a
  /// unit circle (lit from the upper right, like the HTML key light).
  Paint ball(Color c) => _balls[c.toARGB32()] ??= Paint()
    ..shader = ui.Gradient.radial(
      const Offset(0.3, -0.4),
      1.4,
      [labShade(c, 0.4), c, labShade(c, -0.35)],
      const [0, 0.45, 1],
    );

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

/// MeshStandardMaterial look: ambient light plus the key and fill lights'
/// Lambert terms (with their tints) on a face with normal [n]. Metals
/// ([metal], the HTML `metalness`) keep less diffuse light.
Color _lit(Color c, _V n, {double metal = 0}) {
  final key = _keyLight * math.max(0.0, n.dot(_keyDir));
  final fill = _fillLight * math.max(0.0, n.dot(_fillDir));
  final diffuse = 1 - 0.45 * metal;
  double ch(double v, double kt, double ft) =>
      math.min(1.0, v * diffuse * (_ambient + key * kt + fill * ft));
  return Color.from(
    alpha: c.a,
    red: ch(c.r, _keyTint.x, _fillTint.x),
    green: ch(c.g, _keyTint.y, _fillTint.y),
    blue: ch(c.b, _keyTint.z, _fillTint.z),
  );
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat quad (already lit [color]).
  void quad(_V a, _V b, _V c, _V d, Color color) {
    final path = pens.path..reset();
    final pts = [a, b, c, d];
    for (var i = 0; i < 4; i++) {
      _move(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3, double metal = 0}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _move(
          path,
          i,
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        );
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = _lit(color, n, metal: metal));
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge),
        );
      }
    }
  }

  /// CylinderGeometry(rTop, rBottom, height) standing on [base]: the side
  /// facets turned to the camera (Lambert-shaded each), its outline and
  /// its top cap. [sx] stretches it along x (`scale.x`). A part of a turn
  /// ([thetaStart], [thetaLength]; Three.js angles, 0 = +z) is open;
  /// [inner] draws the inside surface seen through the opening instead.
  void cylinder(
    _V base,
    double rBottom,
    double rTop,
    double height,
    Color color, {
    double sx = 1,
    double alpha = 1,
    double metal = 0,
    bool cap = true,
    double thetaStart = 0,
    double thetaLength = 2 * math.pi,
    bool inner = false,
    int segments = 28,
  }) {
    final full = thetaLength >= 2 * math.pi - 1e-9;
    // A full turn starts at the back, so the outline has no seam in front.
    final start = full ? math.pi : thetaStart;
    final n = segments;
    final bottom = <Offset>[];
    final top = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final a = start + thetaLength * i / n;
      final sn = math.sin(a), cs = math.cos(a);
      bottom.add(
        cam.p(_V(base.x + rBottom * sx * sn, base.y, base.z + rBottom * cs)),
      );
      top.add(
        cam.p(_V(base.x + rTop * sx * sn, base.y + height, base.z + rTop * cs)),
      );
    }
    final slope = height <= 0 ? 0.0 : (rBottom - rTop) / height;
    final shown = List<bool>.filled(n, false);
    for (var i = 0; i < n; i++) {
      final a = start + thetaLength * (i + 0.5) / n;
      final sn = math.sin(a), cs = math.cos(a);
      final normal = _V(sn / sx, slope, cs).unit;
      final r = (rBottom + rTop) / 2;
      final mid = _V(
        base.x + r * sx * sn,
        base.y + height / 2,
        base.z + r * cs,
      );
      final facing = normal.dot(cam.eye - mid) > 0;
      if (facing == inner) continue;
      shown[i] = true;
      final path = pens.path
        ..reset()
        ..moveTo(bottom[i].dx, bottom[i].dy)
        ..lineTo(bottom[i + 1].dx, bottom[i + 1].dy)
        ..lineTo(top[i + 1].dx, top[i + 1].dy)
        ..lineTo(top[i].dx, top[i].dy)
        ..close();
      final shade = _lit(color, inner ? normal * -0.6 : normal, metal: metal);
      canvas.drawPath(
        path,
        pens.facet..color = shade.withValues(alpha: shade.a * alpha),
      );
    }
    final edge = labShade(color, -0.45).withValues(alpha: 0.45 * alpha);
    if (!inner) {
      // Outline of each run of facets.
      final path = pens.path..reset();
      var i = 0;
      while (i < n) {
        if (!shown[i]) {
          i++;
          continue;
        }
        var j = i;
        while (j < n && shown[j]) {
          j++;
        }
        path.moveTo(bottom[i].dx, bottom[i].dy);
        for (var k = i + 1; k <= j; k++) {
          path.lineTo(bottom[k].dx, bottom[k].dy);
        }
        for (var k = j; k >= i; k--) {
          path.lineTo(top[k].dx, top[k].dy);
        }
        path.close();
        i = j;
      }
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.9
          ..color = edge,
      );
    }
    if (cap && full && !inner && cam.eye.y > base.y + height) {
      final path = pens.path
        ..reset()
        ..addPolygon(top.sublist(0, n), true);
      final shade = _lit(color, _V.up, metal: metal);
      canvas
        ..drawPath(
          path,
          pens.fill..color = shade.withValues(alpha: shade.a * alpha),
        )
        ..drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = edge,
        );
    }
  }

  /// A flat disc of radius [r] lying at [c] (a cylinder's top seen from
  /// above), already lit [color].
  void disc(_V c, double r, Color color, {int segments = 28}) {
    final path = pens.path..reset();
    for (var i = 0; i < segments; i++) {
      final a = 2 * math.pi * i / segments;
      _move(path, i, cam.p(c + _V(r * math.sin(a), 0, r * math.cos(a))));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A shaded ellipse of radii [rx] x [ry] world units at [c] (spheres and
  /// ellipsoids).
  void blob(_V c, double rx, double ry, Color color) {
    final p = cam.p(c);
    final k = cam.scaleAt(c);
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..scale(math.max(0.01, rx * k), math.max(0.01, ry * k))
      ..drawCircle(Offset.zero, 1, cache.ball(color))
      ..restore();
  }

  /// An ellipsoid with radii [rx], [ry], [rz] as the camera sees it (its
  /// x axis is the screen's horizontal).
  void ellipsoid(_V c, double rx, double ry, double rz, Color color) {
    final hy = math.sqrt(math.pow(ry * cam.u.y, 2) + math.pow(rz * cam.u.z, 2));
    blob(c, rx, hy, color);
  }

  /// A rod (a CylinderGeometry lying down, with rounded ends) from [a] to
  /// [b] with radii [ra] and [rb]: body, shaded side and highlight.
  void limb(_V a, _V b, double ra, double rb, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.8, ra * cam.scaleAt(a));
    final wb = math.max(0.8, rb * cam.scaleAt(b));
    final fill = pens.fill..color = color;
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) {
      canvas.drawCircle(pa, math.max(wa, wb), fill);
      return;
    }
    final n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas
      ..drawPath(path, fill)
      ..drawCircle(pa, wa, fill)
      ..drawCircle(pb, wb, fill);
    // The key light comes from the upper right of the screen.
    var lit = n;
    if (lit.dy > 0 || (lit.dy == 0 && lit.dx < 0)) lit = -lit;
    final w = (wa + wb) / 2;
    canvas
      ..drawLine(
        pa - lit * (wa * 0.55),
        pb - lit * (wb * 0.55),
        pens.band
          ..strokeWidth = w * 0.7
          ..color = labShade(color, -0.22),
      )
      ..drawLine(
        pa + lit * (wa * 0.45),
        pb + lit * (wb * 0.45),
        pens.band
          ..strokeWidth = w * 0.3
          ..color = labShade(color, 0.25),
      );
  }

  /// Soft contact shadow: an ellipse of half sizes [rx] x [rz] on the
  /// horizontal plane through [c].
  void shadow(_V c, double rx, double rz) {
    final p = cam.p(c);
    final w = rx * cam.scaleAt(c);
    final h =
        (cam.p(c + _V(0, 0, rz)).dy - cam.p(c - _V(0, 0, rz)).dy).abs() / 2;
    canvas.drawOval(
      Rect.fromCenter(center: p, width: 2 * w, height: 2 * math.max(1, h)),
      pens.shadow,
    );
  }

  /// A lying ring (`TorusGeometry(r, tube)` turned flat) at [c].
  void ring(_V c, double r, double tube, Color color) {
    final path = pens.path..reset();
    const n = 48;
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n;
      _move(path, i, cam.p(c + _V(r * math.cos(a), 0, r * math.sin(a))));
    }
    path.close();
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(1.5, 2 * tube * cam.scaleAt(c))
        ..color = color,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the table
/// with the map of India, its zones, the food models and the crop shelf;
/// S2 the split-screen kitchen with its tools and ingredients; then the
/// labels, the held piece and the summary's confetti on top.
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

  /// The label chips drawn so far this frame.
  final List<Rect> _placed = [];

  String _t(String key) => labTr(_i18n, lang, key);

  /// Each zone's state id.
  static final Map<String, _Zone> _zoneOfState = {
    for (final z in _Zone.values) z.state: z,
  };

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    _placed.clear();
    final s = scene;
    final g = _Gfx(canvas, s.cam, cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    if (s.scenario == 0) {
      _paintMapTable(g);
    } else {
      _paintKitchen(g);
    }
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  void _paintMapTable(_Gfx g) {
    final s = scene;
    _paintTable(g);
    _paintMap(g);
    final dishes = [
      for (final d in _Dish.values)
        if (s.dishScale(d) > 0.01) d,
    ]..sort((a, b) => g.cam.depth(b.base).compareTo(g.cam.depth(a.base)));
    for (final d in dishes) {
      _paintDish(g, d);
    }
    // Zone rings: lit while a crop is near (opacity 1), half-lit green once
    // claimed.
    for (final z in _Zone.values) {
      final claimed = s.claimed.contains(z);
      final alpha = s.lit.contains(z) ? 1.0 : (claimed ? 0.5 : 0.0);
      if (alpha <= 0) continue;
      g.ring(
        z.center + const _V(0, _ringLift, 0),
        z.radius,
        _ringTube,
        (claimed ? _Colors.zoneDone : _Colors.zoneHover).withValues(
          alpha: alpha,
        ),
      );
    }
    g.box(_shelfCenter, _shelfSize, _Colors.shelfWood, edge: 0.5);
    final cards = [
      for (final c in _Crop.values)
        if (c != s.heldCrop && s.crops[c]!.scale(s.time) > 0.01) c,
    ]..sort((a, b) => g.cam.depth(b.home).compareTo(g.cam.depth(a.home)));
    for (final c in cards) {
      final piece = s.crops[c]!;
      _paintCard(g, piece.at(s.time), c, piece.scale(s.time));
    }
    if (showLabels) {
      for (final z in _Zone.values) {
        _chip(g, g.cam.p(z.labelAt), _t(z.nameKey));
      }
      _chip(
        g,
        g.cam.p(_inventoryLabel),
        _t('lbl_inventory'),
        style: _ChipStyle.wood,
      );
    }
    // The dish names stay (the HTML did not hide them with the labels).
    for (final d in _Dish.values) {
      if (!s.named.contains(d) || s.dishScale(d) < 0.5) continue;
      _chip(
        g,
        g.cam.p(s.dishPos(d) + const _V(0, _dishLabelLift, 0)),
        _t(d.nameKey),
        style: _ChipStyle.dish,
        align: _above,
      );
    }
    final held = s.heldCrop;
    if (held != null) {
      final pos = s.crops[held]!.pos;
      g.shadow(_V(pos.x - 0.25, 0.02, pos.z - 0.25), 0.6, 0.35);
      _paintCard(g, pos, held, 1);
    }
  }

  /// The table: Three.js's default white `MeshBasicMaterial` (unlit), so
  /// only its outline shows it.
  void _paintTable(_Gfx g) {
    const a = _tableMin, b = _tableMax;
    g.quad(
      _V(a.x, b.y, a.z),
      _V(b.x, b.y, a.z),
      _V(b.x, b.y, b.z),
      _V(a.x, b.y, b.z),
      _Colors.table,
    );
    if (g.cam.eye.z > b.z) {
      g.quad(
        _V(a.x, a.y, b.z),
        _V(b.x, a.y, b.z),
        _V(b.x, b.y, b.z),
        _V(a.x, b.y, b.z),
        _Colors.table,
      );
    }
    final edge = _pens.stroke
      ..strokeWidth = 1
      ..color = _Colors.tableEdge;
    g.canvas
      ..drawLine(g.cam.p(_V(a.x, b.y, b.z)), g.cam.p(_V(b.x, b.y, b.z)), edge)
      ..drawLine(g.cam.p(_V(b.x, b.y, a.z)), g.cam.p(_V(b.x, b.y, b.z)), edge);
  }

  /// The map texture: every state filled `#dcfce7` and outlined `#15803d`
  /// in the SVG's order; a zone's state glows green while a crop is over it
  /// (added) and once its crop was planted.
  void _paintMap(_Gfx g) {
    final s = scene;
    cache.map.update(g.cam);
    final width = math.max(
      0.6,
      _IndiaMap.strokeWidth *
          _IndiaMap.pxWorld *
          g.cam.scaleAt(const _V(-2, 0, 0)),
    );
    final outline = _pens.stroke
      ..strokeWidth = width
      ..color = _Colors.mapStroke;
    for (final e in cache.map.paths.entries) {
      final zone = _zoneOfState[e.key];
      var fill = _Colors.mapFill;
      if (zone != null && s.claimed.contains(zone)) {
        fill = Color.lerp(_Colors.mapFill, _Colors.zoneDone, 0.55)!;
      } else if (zone != null && zone == s.hoverState) {
        fill = Color.lerp(_Colors.mapFill, _Colors.zoneHover, 0.45)!;
      }
      g.canvas
        ..drawPath(e.value, _pens.fill..color = fill)
        ..drawPath(e.value, outline);
    }
  }

  /// HTML `createFoodModel`: Punjab a metal plate with a roti and a bowl
  /// of saag, Karnataka a plate with two idlis, Manipur a clay bowl of
  /// soup; popping in and bobbing.
  void _paintDish(_Gfx g, _Dish d) {
    final s = scene;
    final k = s.dishScale(d);
    final b = s.dishPos(d);
    _V at(double x, double y, double z) => b + _V(x * k, y * k, z * k);
    switch (d) {
      case _Dish.punjab:
        g
          ..cylinder(
            at(0, 0, 0),
            0.8 * k,
            0.8 * k,
            0.1 * k,
            _Colors.metal,
            metal: 0.6,
          )
          ..cylinder(
            at(0, 0.1, 0),
            0.6 * k,
            0.6 * k,
            0.05 * k,
            _Colors.foodBase,
          )
          ..cylinder(at(0.3, 0.1, 0), 0.3 * k, 0.3 * k, 0.2 * k, _Colors.saag);
      case _Dish.karnataka:
        g
          ..cylinder(
            at(0, 0, 0),
            0.8 * k,
            0.8 * k,
            0.1 * k,
            _Colors.metal,
            metal: 0.6,
          )
          ..ellipsoid(
            at(0.2, 0.15, -0.2),
            0.2 * k,
            0.1 * k,
            0.2 * k,
            _Colors.idli,
          )
          ..ellipsoid(
            at(-0.2, 0.15, 0),
            0.2 * k,
            0.1 * k,
            0.2 * k,
            _Colors.idli,
          );
      case _Dish.manipur:
        g
          ..cylinder(at(0, 0, 0), 0.4 * k, 0.6 * k, 0.4 * k, _Colors.mud)
          ..disc(at(0, 0.4, 0), 0.55 * k, _lit(_Colors.soup, _V.up));
    }
  }

  /// HTML `createIconSprite`: a white card with an amber border, the crop's
  /// picture and its name, [k] times the 1.5-unit sprite. The name is never
  /// smaller than a readable size (the HTML's 20 px on a 128 px card is
  /// tiny on a phone); the picture makes room for it.
  void _paintCard(_Gfx g, _V pos, _Crop crop, double k) {
    final rect = scene.cardRect(pos, k);
    final side = rect.width;
    if (side < 2) return;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(side * 0.125));
    g.canvas
      ..drawRRect(
        rr.shift(Offset(0, side * 0.05)),
        _pens.fill..color = _Colors.cardShadow,
      )
      ..drawRRect(rr, _pens.fill..color = _Colors.card)
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = math.max(1.2, side * 4 / 128)
          ..color = _Colors.cardBorder,
      );
    final tp = cache.label(
      _t(crop.nameKey),
      color: _Colors.cardText,
      scale: 0.8,
    );
    var f = math.max(1.0, side * 20 / 128 / (tp.height / 1.2));
    f = math.min(f, side * 0.9 / tp.width);
    final textTop = rect.bottom - side * 0.06 - tp.height * f;
    g.canvas
      ..save()
      ..translate(rect.center.dx - tp.width * f / 2, textTop)
      ..scale(f);
    tp.paint(g.canvas, Offset.zero);
    g.canvas.restore();
    final top = rect.top + side * 0.1;
    final icon = math.min(side * 0.5, textTop - side * 0.03 - top);
    if (icon > 2) {
      _IconArt.draw(
        g.canvas,
        crop.art,
        Rect.fromCenter(
          center: Offset(rect.center.dx, top + (textTop - top) / 2),
          width: icon,
          height: icon,
        ),
        _pens.fill,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintKitchen(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    const r = _floorReach;
    // The floors end just in front of the camera.
    final z = cam.eye.z - 0.5;
    g
      ..quad(
        const _V(-r, 0, _floorBack),
        const _V(0, 0, _floorBack),
        _V(0, 0, z),
        _V(-r, 0, z),
        _lit(_Colors.floorTrad, _V.up),
      )
      ..quad(
        const _V(0, 0, _floorBack),
        const _V(r, 0, _floorBack),
        _V(r, 0, z),
        _V(0, 0, z),
        _lit(_Colors.floorModern, _V.up),
      )
      ..quad(
        const _V(-r, 0, _wallZ),
        const _V(0, 0, _wallZ),
        const _V(0, _wallTop, _wallZ),
        const _V(-r, _wallTop, _wallZ),
        _lit(_Colors.wallTrad, const _V(0, 0, 1)),
      )
      ..quad(
        const _V(0, 0, _wallZ),
        const _V(r, 0, _wallZ),
        const _V(r, _wallTop, _wallZ),
        const _V(0, _wallTop, _wallZ),
        _lit(_Colors.wallModern, const _V(0, 0, 1)),
      );
    // The kitchen on the far side of the divider (seen from a close-up)
    // first, then the divider, the central table and the near side(s).
    final side = cam.eye.x < -0.2 ? -1 : (cam.eye.x > 0.2 ? 1 : 0);
    if (side != 0) _paintSide(g, -side);
    g.box(_dividerCenter, _dividerSize, _Colors.divider, edge: 0.4);
    g
      ..shadow(const _V(-0.35, 0.01, -0.3), 1.7, 1.6)
      ..cylinder(
        _V.zero,
        _centreTableR,
        _centreTableR,
        _centreTableH,
        _Colors.shelfWood,
      );
    // The divider's front face is in front of the table.
    final front = _dividerCenter.z + _dividerSize.z / 2;
    if (cam.eye.z > front) {
      const hx = 0.1;
      g.quad(
        _V(-hx, 0, front),
        _V(hx, 0, front),
        _V(hx, _dividerHeight, front),
        _V(-hx, _dividerHeight, front),
        _lit(_Colors.divider, const _V(0, 0, 1)),
      );
    }
    if (side == 0) {
      _paintSide(g, -1);
      _paintSide(g, 1);
    } else {
      _paintSide(g, side);
    }
    if (showLabels) _paintKitchenLabels(g);
    final held = s.heldIngredient;
    if (held != null) {
      final pos = s.ingredients[held]!.pos;
      g.shadow(_V(pos.x - 0.3, 2.01, pos.z - 0.3), 0.55, 0.4);
      _paintIngredient(g, held, pos, 1);
      if (showLabels) {
        _chip(
          g,
          g.cam.p(pos + const _V(0, _ingredientLabelLift, 0)),
          _t(held.nameKey),
        );
      }
    }
  }

  /// One kitchen ([side] -1 traditional, 1 modern): its bench, then its
  /// tools and the ingredients on that side, far ones first.
  void _paintSide(_Gfx g, int side) {
    final s = scene;
    final cam = g.cam;
    if (side < 0) {
      g.box(
        (_benchTradMin + _benchTradMax) * 0.5,
        _benchTradMax - _benchTradMin,
        _Colors.mud,
        edge: 0.5,
      );
    } else {
      g.box(
        (_benchModMin + _benchModMax) * 0.5,
        _benchModMax - _benchModMin,
        _Colors.metal,
        edge: 0.5,
        metal: 0.6,
      );
    }
    final items = <(double, VoidCallback)>[];
    for (final t in _Tool.values) {
      if (t.pos.x.sign != side) continue;
      items.add((cam.depth(t.pos), () => _paintTool(g, t)));
    }
    for (final i in _Ingredient.values) {
      if (i == s.heldIngredient) continue;
      final piece = s.ingredients[i]!;
      final k = piece.scale(s.time);
      final pos = piece.at(s.time);
      if (k <= 0.01 || pos.x.sign != side || _onChulha(i)) continue;
      // Resting on a tool: drawn just after it.
      items.add((cam.depth(pos) - 0.6, () => _paintIngredient(g, i, pos, k)));
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, paint) in items) {
      paint();
    }
  }

  /// The dough sits inside the chulha (drawn between its walls).
  bool _onChulha(_Ingredient i) {
    final s = scene;
    if (i != _Ingredient.dough || i == s.heldIngredient) return false;
    final pos = s.ingredients[i]!.at(s.time);
    return pos.flatDistance(_Tool.chulha.pos) < 0.3;
  }

  void _paintTool(_Gfx g, _Tool t) {
    switch (t) {
      case _Tool.silbatta:
        _paintSilbatta(g);
      case _Tool.grinder:
        _paintGrinder(g);
      case _Tool.chulha:
        _paintChulha(g);
      case _Tool.gas:
        _paintGasStove(g);
    }
  }

  /// Sil-batta: a flat stone slab (`CylinderGeometry(1.5, 1.5, 0.3)`,
  /// `scale.x 0.8`) and the stone roller lying across it, rolling to and
  /// fro while it grinds.
  void _paintSilbatta(_Gfx g) {
    final p = _Tool.silbatta.pos;
    g
      ..shadow(p + const _V(-0.3, 0.01, -0.25), 1.35, 1.6)
      ..cylinder(p, 1.5, 1.5, 0.3, _Colors.silStone, sx: 0.8);
    final x = p.x + scene.rollerShift;
    g.limb(
      _V(x - 0.9, p.y + 0.45, p.z),
      _V(x + 0.9, p.y + 0.45, p.z),
      0.25,
      0.25,
      _Colors.silRoller,
    );
  }

  /// Electric grinder: white motor base with a blue trim, a see-through jar
  /// (brown once the spices are in) and a dark lid; it shivers while it
  /// runs.
  void _paintGrinder(_Gfx g) {
    final s = scene;
    final p = _Tool.grinder.pos + _V(s.grinderShiver, 0, 0);
    g
      ..shadow(p + const _V(-0.3, 0.01, -0.25), 1.05, 0.95)
      ..cylinder(p, 0.9, 0.8, 1.2, _Colors.grinderBody)
      ..cylinder(
        p + const _V(0, 0.1, 0),
        0.905,
        0.905,
        0.2,
        _Colors.grinderTrim,
        cap: false,
      )
      ..cylinder(
        p + const _V(0, 1.2, 0),
        0.5,
        0.6,
        1,
        s.jarFilled ? _Colors.spice : _Colors.grinderBody,
        alpha: 0.6,
      )
      ..cylinder(
        p + const _V(0, 2.175, 0),
        0.65,
        0.65,
        0.15,
        _Colors.grinderLid,
      );
  }

  /// Chulha: a clay ring (`CylinderGeometry(1.5, 1.5, 1.2, …, 0, 1.5π)`,
  /// open at the front left) with two logs inside, the dough when it
  /// cooks and its orange flame.
  void _paintChulha(_Gfx g) {
    final s = scene;
    final p = _Tool.chulha.pos;
    const length = 1.5 * math.pi;
    g
      ..shadow(p + const _V(-0.3, 0.01, -0.25), 1.6, 1.5)
      ..cylinder(
        p,
        1.5,
        1.5,
        1.2,
        _Colors.chulha,
        thetaLength: length,
        inner: true,
      )
      // Logs: along z at x -0.3, and turned 0.5 rad at x 0.3.
      ..limb(
        p + const _V(-0.3, 0.15, -0.75),
        p + const _V(-0.3, 0.15, 0.75),
        0.15,
        0.15,
        _Colors.shelfWood,
      )
      ..limb(
        p + const _V(0.3 + 0.359, 0.15, -0.659),
        p + const _V(0.3 - 0.359, 0.15, 0.659),
        0.15,
        0.15,
        _Colors.shelfWood,
      );
    if (_onChulha(_Ingredient.dough)) {
      final piece = s.ingredients[_Ingredient.dough]!;
      _paintIngredient(g, _Ingredient.dough, piece.at(s.time), 1);
    }
    g.cylinder(p, 1.5, 1.5, 1.2, _Colors.chulha, thetaLength: length);
    if (s.flame == _Tool.chulha) {
      _paintFlame(g, p + const _V(0, 1, 0), _Colors.flameChulha);
    }
  }

  /// Gas stove: a steel top with two black burners and grates and two
  /// knobs in front; the left burner's blue flame while it cooks.
  void _paintGasStove(_Gfx g) {
    final s = scene;
    final p = _Tool.gas.pos;
    g
      ..shadow(p + const _V(-0.35, 0.01, -0.3), 2.3, 1.5)
      ..box(
        p + const _V(0, 0.25, 0),
        const _V(4, 0.5, 2.5),
        _Colors.stoveSteel,
        metal: 0.8,
      );
    for (final x in const [-1.0, 1.0]) {
      g
        ..cylinder(p + _V(x, 0.5, 0), 0.4, 0.4, 0.1, _Colors.burner)
        ..box(
          p + _V(x, 0.6, 0),
          const _V(1.2, 0.05, 0.1),
          _Colors.grate,
          edge: 0,
        )
        ..box(
          p + _V(x, 0.6, 0),
          const _V(0.1, 0.05, 1.2),
          _Colors.grate,
          edge: 0,
        )
        ..blob(p + _V(x, 0.25, 1.33), 0.15, 0.15, _Colors.burner);
    }
    if (s.flame == _Tool.gas) {
      _paintFlame(g, p + const _V(-1, 0.7, 0), _Colors.flameGas);
    }
  }

  /// HTML `createFlameSprite`: the `SVGs.flame` rings (outer in the flame
  /// colour, inner white) on an additive sprite, flickering.
  void _paintFlame(_Gfx g, _V at, Color color) {
    final (sx, sy) = scene.flameScale;
    final c = g.cam.p(at);
    // 24 view box units span 96 of the sprite's 128 px.
    final unit = g.cam.scaleAt(at) * 96 / 128 / 24;
    g.canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(sx * unit, sy * unit)
      ..translate(-12, -12)
      ..drawPath(_IconArt.flameOuter, _pens.flame..color = color)
      ..drawPath(_IconArt.flameInner, _pens.flame..color = _Colors.white)
      ..restore();
  }

  /// The spice bowl (stone bowl with a brown heap of spices) or the dough
  /// (metal bowl with a dough ball that puffs up and browns as it cooks),
  /// [k] times its size.
  void _paintIngredient(_Gfx g, _Ingredient i, _V pos, double k) {
    final s = scene;
    _V at(double y) => pos + _V(0, y * k, 0);
    switch (i) {
      case _Ingredient.spices:
        g
          ..cylinder(pos, 0.3 * k, 0.4 * k, 0.3 * k, _Colors.stone)
          ..disc(at(0.35), 0.35 * k, _lit(_Colors.spice, _V.up));
      case _Ingredient.dough:
        final puff = s.puff;
        g
          ..cylinder(pos, 0.4 * k, 0.5 * k, 0.2 * k, _Colors.metal, metal: 0.6)
          ..ellipsoid(
            at(0.2),
            0.4 * k,
            (0.2 + 0.2 * puff) * k,
            0.4 * k,
            Color.lerp(_Colors.dough, _Colors.doughCooked, puff)!,
          );
    }
  }

  void _paintKitchenLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    _chip(g, cam.p(_tradLabel), _t('lbl_trad'), style: _ChipStyle.trad);
    _chip(g, cam.p(_modernLabel), _t('lbl_modern'), style: _ChipStyle.modern);
    for (final t in _Tool.values) {
      _chip(g, cam.p(t.labelAt), _t(t.nameKey));
    }
    // An ingredient's name hides while it rests on a tool (it covered the
    // tool's name).
    for (final i in _Ingredient.values) {
      final piece = s.ingredients[i]!;
      if (i == s.heldIngredient ||
          piece.scale(s.time) < 0.5 ||
          piece.pos.flatDistance(i.home) > 0.1) {
        continue;
      }
      _chip(
        g,
        cam.p(piece.at(s.time) + const _V(0, _ingredientLabelLift, 0)),
        _t(i.nameKey),
      );
    }
  }

  // ----------------------------------------------------------- shared

  /// HTML `createTextSprite` / `createRawTextSprite`: a rounded chip with a
  /// border and bold text in [style], placed on [at] by [align] and kept
  /// inside the visible canvas. A chip that would cover one drawn before
  /// it this frame is nudged aside (the HTML sprites overlapped).
  void _chip(
    _Gfx g,
    Offset at,
    String text, {
    _ChipStyle style = _ChipStyle.normal,
    (double, double) align = _centred,
  }) {
    final size = cache.chipSize(text, style);
    var rect = (at + _chipOffset(size, align)) & size;
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
    for (var i = 0; i < 4; i++) {
      Rect? other;
      for (final o in _placed) {
        if (o.overlaps(rect.inflate(1))) {
          other = o;
          break;
        }
      }
      if (other == null) break;
      // The smallest move up, left or right that clears it.
      final moves = [
        Offset(0, other.top - 2 - rect.bottom),
        Offset(other.left - 2 - rect.right, 0),
        Offset(other.right + 2 - rect.left, 0),
      ]..sort((a, b) => a.distance.compareTo(b.distance));
      rect = rect.shift(moves.first);
    }
    _placed.add(rect);
    final k = cache.labelSize * style.scale;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(k * 0.45));
    g.canvas
      ..drawRRect(rr, _pens.fill..color = style.bg)
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1.4
          ..color = style.border,
      );
    final tp = cache.label(text, color: style.text, scale: style.scale);
    tp.paint(
      g.canvas,
      Offset(rect.center.dx - tp.width / 2, rect.top + _chipPadY * k),
    );
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
    final pen = _pens.fill;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      canvas
        ..save()
        ..translate(
          _confettiOrigin.dx + math.cos(c.angle) * d,
          _confettiOrigin.dy + math.sin(c.angle) * d + fall,
        )
        ..rotate(c.spin * ticks)
        ..drawRect(_confettiPiece, pen..color = c.color.withValues(alpha: fade))
        ..restore();
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
