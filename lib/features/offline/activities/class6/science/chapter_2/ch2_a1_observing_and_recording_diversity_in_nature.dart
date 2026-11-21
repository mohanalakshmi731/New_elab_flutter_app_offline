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

/// Class 6 Science • Chapter 2 • Activity 1
/// Observing and Recording Diversity in Nature.
///
/// Native Flutter port of
/// `Cl6S-Ch02-A1-Observing_and_Recording_Diversity_in_Nature.html`.
///
/// Scenario 1 (The Virtual Nature Walk): tap the Hibiscus plant (the camera
/// glides in), drag the Touch Hand onto its stem (a 'Hard' tag appears),
/// record the 'Hard Stem' icon in Notebook 2.1, tap the crow on the tree
/// branch (it flies up and lands again), record the 'Legs' and 'Wings'
/// icons in Notebook 2.2, then tap 'Complete Observation'.
///
/// Scenario 2 (Uncovering Nature's Hidden Connections): tap the Sadabahar
/// plant, drag the Magnifying Glass over its big leaf (the net-like veins
/// glow), record 'Reticulate Venation' in Notebook 2.4, drag the X-Ray
/// Scanner over the ground at its base (the taproot glows), record
/// 'Taproot'; repeat for the Lemongrass plant (parallel veins, fibrous
/// roots), after which glowing lines link each plant's venation to its
/// root type and the pattern is revealed. 'Complete Observation' opens the
/// summary.
///
/// The Three.js garden scenes are redrawn by a CustomPainter through a
/// perspective projection of the HTML cameras (fov 45°): the start view at
/// (0, 8, 22) looking at (0, 2, 0) and the close-ups the HTML tweens to
/// when a plant or the crow is tapped. Each view is fitted into the part of
/// the canvas the notebook and the toolkit leave free.
class Ch2A1ObservingAndRecordingDiversityInNaturePage extends StatefulWidget {
  const Ch2A1ObservingAndRecordingDiversityInNaturePage({super.key});

  @override
  State<Ch2A1ObservingAndRecordingDiversityInNaturePage> createState() =>
      _DiversityLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, from the app's bundled `assets/audio/` tones.
/// The HTML synthesises its tones with Web Audio: 'click' / 'pop' (a plant
/// or the crow tapped, every button) → click.mp3; 'snap' (an icon dropped
/// into its table cell) → click.mp3 too, the closest short knock; 'magic'
/// (a tool reveals something, the crow takes off) → dropdown.mp3, a short
/// swish; 'success' (the pattern lines, the summary) and 'chime'
/// ('Complete Observation' appears) → math/success.mp3. The added hints
/// after a wrong move play science/error.mp3.
enum _Sound implements LabTone {
  /// Generic button click; a plant or the crow tapped (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// The shell's "right" feedback tone.
  correct('audio/class6/math/success.mp3'),

  /// Added hints after a wrong move (the HTML stayed silent).
  wrong('audio/class6/science/error.mp3'),

  /// The summary, the pattern lines (HTML `success`) and 'Complete
  /// Observation' appearing (HTML `chime`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An icon dropped into its table cell (HTML `snap`).
  snap('audio/class6/science/click.mp3'),

  /// A tool reveals the stem, veins or roots; the crow takes off (HTML
  /// `magic`).
  magic('audio/class6/science/dropdown.mp3');

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
/// (material colours) and of its SVG notebook icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amberNote = Color(0x6678350F); // amber-900/40
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color blue500 = Color(0xFF3B82F6);
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
  static const Color paper = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Notebook: dashed empty cell (gray-400/40), hovered cell (indigo-500
  /// /20) and filled cell (emerald-500/20).
  static const Color cellDash = Color(0x669CA3AF);
  static const Color cellHover = Color(0x336366F1);
  static const Color cellFilled = Color(0x3310B981);
  static const Color gridLine = Color(0x4D9CA3AF);

  // --------------------------------------------------------------- scene
  /// `scene.background` and `scene.fog` (0xecfdf5) in both themes.
  static const Color sky = Color(0xFFECFDF5);

  /// Scenario 1: ground `0x65a30d`, tree `0x78350f`.
  static const Color grass = Color(0xFF65A30D);
  static const Color bark = amber900;

  /// Crow: body `0x0f172a`, beak `0x334155`, legs `0x475569`.
  static const Color crow = slate900;
  static const Color beak = slate700;
  static const Color crowLegs = slate600;

  /// Hibiscus: stem `0x14532d`, leaves `0x22c55e`, petals `0xf43f5e`,
  /// centre `0x7f1d1d`, pollen `0xfde047`, stigma pads `0x9f1239`, calyx
  /// and sepal `0x166534`.
  static const Color hibiscusStem = Color(0xFF14532D);
  static const Color leaf = Color(0xFF22C55E);
  static const Color petal = Color(0xFFF43F5E);
  static const Color flowerCentre = Color(0xFF7F1D1D);
  static const Color pollen = Color(0xFFFDE047);
  static const Color stigma = Color(0xFF9F1239);
  static const Color calyx = Color(0xFF166534);

  /// Scenario 2: bed `0x78350f`, dirt box `0x451a03`.
  static const Color bed = amber900;
  static const Color dirt = Color(0xFF451A03);

  /// Sadabahar: stem and veins `0x166534`, petals `0x6366f1`, white centre;
  /// lemongrass blades `0x65a30d`.
  static const Color sadaStem = calyx;
  static const Color vein = calyx;
  static const Color sadaPetal = indigo500;
  static const Color blade = grass;

  /// Glowing veins and roots (`#fbbf24`).
  static const Color glow = amber400;

  /// Text sprites: `#1e293b` chip, `#34d399` border, white text; the 'Hard'
  /// sprite is `#78350f`.
  static const Color chipBg = slate800;
  static const Color chipBorder = emerald400;
  static const Color chipText = white;
  static const Color hardChip = amber900;

  /// canvas-confetti colours of the HTML summary.
  static const List<Color> confetti = [emerald400, amber300, blue500];
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
    canvasBg: _Colors.sky,
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
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.emerald950,
    curtainGlow: Color(0x66065F46), // emerald-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // emerald-300/80
    curtainIcon: _Colors.emerald300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald300,
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
    canvasBg: _Colors.sky,
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
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.emerald950,
    curtainGlow: Color(0x66065F46),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7),
    curtainIcon: _Colors.emerald300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.emerald300,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). `sN_cM`,
// `sN_aM` and `sN_oM` are each step's concept, action and observation,
// `sN_hud_M` the HTML "Current Task" lines. Steps and HUD lines say what to
// do on a touch screen ("tap" instead of "click"). The HTML showed a few
// texts in English only (the notebook headers, the 'Items Tray', the row
// and scene labels, 'Scenario Complete!'); their Hindi is added. Keys
// marked "added" are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Observing and Recording Diversity in Nature',
    'app_subtitle': 'Class 6. Diversity in the Living World',
    'scen_1': 'Scenario 1 - The Virtual Nature Walk',
    'scen_2': "Scenario 2 - Uncovering Nature's Hidden Connections",
    's1_obj':
        'To observe the distinct features of different plants and animals and record them.',
    's2_obj':
        "To investigate the relationship between a plant's leaf venation and its root system by using virtual scientific tools.",
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Observation',
    's1_a1': 'TAP the Hibiscus plant to zoom in.',
    's1_o1': 'Zoomed in on the plant.',
    's1_c2': 'Texture',
    's1_a2': "DRAG the 'Touch Hand' icon onto the stem of the Hibiscus plant.",
    's1_o2': 'The stem is hard and woody.',
    's1_c3': 'Recording',
    's1_a3':
        "DRAG the 'Hard Stem' icon from the observation panel and DROP it into the 'Stem' column for the Hibiscus row.",
    's1_o3': 'Data recorded.',
    's1_c4': 'Animal Movement',
    's1_a4': 'TAP the crow.',
    's1_o4': 'Crow walks and flies.',
    's1_c5': 'Recording',
    's1_a5':
        "DRAG the 'Legs' icon and the 'Wings' icon into 'The way they move around' column for the Crow.",
    's1_o5': 'Data recorded.',
    's1_c6': 'Conclusion',
    's1_a6': 'Review tables.',
    's1_o6':
        'You have successfully observed and recorded the features of a plant and an animal. This is the first step scientists take to understand the amazing diversity of life around us.',
    's1_hud_1': 'Step 1: Tap the Hibiscus plant to zoom in.',
    's1_hud_2':
        "Step 2: Drag the 'Touch Hand' icon onto the stem of the Hibiscus plant.",
    's1_hud_3':
        "Step 3: Drag the 'Hard Stem' icon from the observation panel and drop it into the 'Stem' column for the Hibiscus row.",
    's1_hud_4': 'Step 4: Tap the crow.',
    's1_hud_5':
        "Step 5: Drag the 'Legs' icon and the 'Wings' icon into 'The way they move around' column for the Crow.",
    's1_hud_6': "Step 6: Tap 'Complete Observation'.",
    's1_sum':
        'You successfully observed and recorded features of a plant and an animal. This systematic recording is the first step scientists take to classify life!',
    // Scenario 2 steps.
    's2_c1': 'Focus',
    's2_a1': 'TAP the Sadabahar plant to begin your investigation.',
    's2_o1': 'Ready to inspect.',
    's2_c2': 'Venation',
    's2_a2':
        "DRAG the 'Magnifying Glass' tool over the leaf to observe the pattern of its veins.",
    's2_o2': 'Net-like (Reticulate) veins found.',
    's2_c3': 'Recording',
    's2_a3':
        "DRAG the 'Reticulate Venation' icon into the 'Type of leaf venation' column for the Sadabahar plant.",
    's2_o3': 'Data recorded.',
    's2_c4': 'Roots',
    's2_a4':
        "DRAG the 'X-Ray Scanner' tool over the base of the Sadabahar plant.",
    's2_o4': 'Main thick root (Taproot) found.',
    's2_c5': 'Recording',
    's2_a5':
        "DRAG the 'Taproot' icon into the 'Type of root' column for the Sadabahar plant.",
    's2_o5': 'Data recorded.',
    's2_c6': 'Comparison',
    's2_a6': 'REPEAT steps 1-5 for the Lemongrass plant.',
    's2_o6': 'Parallel veins and Fibrous roots found and recorded.',
    's2_c7': 'Analysis',
    's2_a7': 'Look at your completed table. Do you see a pattern?',
    's2_o7':
        'Plants with reticulate venation also have taproots, and plants with parallel venation have fibrous roots!',
    's2_hud_1': 'Step 1: Tap the Sadabahar plant to begin your investigation.',
    's2_hud_2':
        "Step 2: Drag the 'Magnifying Glass' tool over the leaf to observe the pattern of its veins.",
    's2_hud_3':
        "Step 3: Drag the 'Reticulate Venation' icon into the 'Type of leaf venation' column for the Sadabahar plant.",
    's2_hud_4':
        "Step 4: Drag the 'X-Ray Scanner' tool over the base of the Sadabahar plant.",
    's2_hud_5':
        "Step 5: Drag the 'Taproot' icon into the 'Type of root' column for the Sadabahar plant.",
    's2_hud_6': 'Step 6: Repeat steps 1-5 for the Lemongrass plant.',
    's2_hud_7': 'Step 7: Look at your completed table. Do you see a pattern?',
    's2_sum':
        'You discovered a hidden rule of nature! Plants with reticulate (net-like) leaf veins typically have taproots, while those with parallel veins have fibrous roots.',
    // Summary popup.
    'sum_heading': 'Scenario Complete!',
    'next_msg':
        'Exploration 1 completed. Please select the next from the sidebar!',
    'btn_conclude': 'Complete Observation',
    // Toolkit and notebook.
    'toolkit': 'Toolkit',
    'notebook_2_1': 'Notebook 2.1',
    'notebook_2_2': 'Notebook 2.2',
    'notebook_2_4': 'Notebook 2.4',
    'table_2_1': 'Table 2.1: Plant Observations',
    'table_2_2': 'Table 2.2: Animal Observations',
    'table_2_4': 'Table 2.4: Venation & Roots',
    'plant_name': 'Plant',
    'stem_type': 'Stem Type',
    'animal_name': 'Animal',
    'movement': 'Movement Parts',
    'venation': 'Venation',
    'root_type': 'Root Type',
    'pattern_revealed':
        'Pattern Revealed! Reticulate venation relates to taproots, and parallel to fibrous roots.',
    'items_tray': 'Items Tray',
    // Row names and scene labels (HTML text sprites).
    'name_hibiscus': 'Hibiscus',
    'name_crow': 'Crow',
    'name_sada': 'Sadabahar',
    'name_lemon': 'Lemongrass',
    'lbl_hard': 'Hard',
    // Tool and icon names (HTML `title`s and HUD names).
    'tool_hand': 'Touch Hand',
    'tool_mag': 'Magnifying Glass',
    'tool_xray': 'X-Ray Scanner',
    'item_hard_stem': 'Hard Stem',
    'item_legs': 'Legs',
    'item_wings': 'Wings',
    'item_reticulate': 'Reticulate Venation',
    'item_parallel': 'Parallel Venation',
    'item_taproot': 'Taproot',
    'item_fibrous': 'Fibrous Root',
    // Steps accordion (HTML teacher board).
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'focus_lbl': 'Focus',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    // Added.
    'pending': 'Do this step to see the result.',
    'hint_tap_hibiscus': 'Start with the Hibiscus plant: tap it to zoom in.',
    'hint_tap_crow': 'Now tap the crow sitting on the tree branch.',
    'hint_tap_sada': 'Start with the Sadabahar plant: tap it first.',
    'hint_tap_lemon': 'Now tap the Lemongrass plant.',
    'miss_hand':
        'Missed! Drag the Touch Hand right onto the stem of the Hibiscus plant.',
    'miss_mag_sada':
        'Missed! Drag the Magnifying Glass right over the big Sadabahar leaf.',
    'miss_mag_lemon':
        'Missed! Drag the Magnifying Glass right over the long Lemongrass leaf.',
    'miss_xray_sada':
        'Missed! Drag the X-Ray Scanner over the ground at the base of the Sadabahar plant.',
    'miss_xray_lemon':
        'Missed! Drag the X-Ray Scanner over the ground at the base of the Lemongrass plant.',
    'miss_item': "Drop the '{item}' icon into its column in the table.",
    'wrong_cell':
        "That is not the right column for the '{item}' icon. Try again!",
    's2_lemon_mag':
        "Lemongrass: drag the 'Magnifying Glass' tool over its leaf to observe the pattern of its veins.",
    's2_lemon_xray':
        "Lemongrass: drag the 'X-Ray Scanner' tool over the base of the plant.",
    's2_lemon_record':
        "Lemongrass: drag the 'Parallel Venation' and 'Fibrous Root' icons into its row of the table.",
    'scene_s1':
        'A garden with a Hibiscus plant and a bare tree with a crow on its branch',
    'scene_s2':
        'A garden bed with a Sadabahar plant on the left and a Lemongrass plant on the right',
    'target_hibiscus': 'Hibiscus plant',
    'target_crow': 'Crow on the tree branch',
    'target_sada': 'Sadabahar plant',
    'target_lemon': 'Lemongrass plant',
    'target_stem': 'Stem of the Hibiscus plant',
    'target_sada_leaf': 'The big Sadabahar leaf',
    'target_lemon_leaf': 'The long Lemongrass leaf',
    'target_sada_base': 'Ground at the base of the Sadabahar plant',
    'target_lemon_base': 'Ground at the base of the Lemongrass plant',
  },
  'hi': {
    'app_title': 'प्रकृति में विविधता का अवलोकन और रिकॉर्डिंग',
    'app_subtitle': 'कक्षा 6. सजीव जगत में विविधता',
    'scen_1': 'परिदृश्य 1 - वर्चुअल नेचर वॉक',
    'scen_2': 'परिदृश्य 2 - प्रकृति के छिपे हुए संबंध',
    's1_obj':
        'विभिन्न पौधों और जानवरों की विशिष्ट विशेषताओं का निरीक्षण करना और उन्हें रिकॉर्ड करना।',
    's2_obj':
        'पौधे के शिराविन्यास और उसकी जड़ प्रणाली के बीच संबंध की जांच करना।',
    's1_c1': 'अवलोकन',
    's1_a1': 'गुड़हल पर टैप करें।',
    's1_o1': 'पौधे पर ज़ूम किया गया।',
    's1_c2': 'बनावट',
    's1_a2': 'तने पर टच टूल का उपयोग करें।',
    's1_o2': 'तना कठोर और लकड़ी जैसा है।',
    's1_c3': 'रिकॉर्डिंग',
    's1_a3': 'तालिका में आइकन रखें।',
    's1_o3': 'डेटा रिकॉर्ड किया गया।',
    's1_c4': 'पशु गति',
    's1_a4': 'कौवे पर टैप करें।',
    's1_o4': 'कौवा चलता है और उड़ता है।',
    's1_c5': 'रिकॉर्डिंग',
    's1_a5': 'तालिका में गति आइकन रखें।',
    's1_o5': 'डेटा रिकॉर्ड किया गया।',
    's1_c6': 'निष्कर्ष',
    's1_a6': 'तालिकाओं की समीक्षा करें।',
    's1_o6': 'जीवों में विविध विशेषताएं होती हैं।',
    's1_hud_1': 'चरण 1: ज़ूम इन करने के लिए गुड़हल के पौधे पर टैप करें।',
    's1_hud_2': "चरण 2: 'टच हैंड' टूल को तने पर खींचें।",
    's1_hud_3': "चरण 3: 'कठोर तना' आइकन को तालिका 2.1 में खींचें।",
    's1_hud_4': 'चरण 4: पेड़ की शाखा पर कौवे पर टैप करें।',
    's1_hud_5': 'चरण 5: सही गति आइकन (पैर, पंख) को तालिका 2.2 में खींचें।',
    's1_hud_6': "चरण 6: 'अवलोकन पूर्ण करें' पर टैप करें।",
    's1_sum':
        'आपने एक पौधे और एक जानवर की विशेषताओं का सफलतापूर्वक अवलोकन और रिकॉर्ड किया।',
    's2_c1': 'ध्यान दें',
    's2_a1': 'सदाबहार पर टैप करें।',
    's2_o1': 'निरीक्षण के लिए तैयार।',
    's2_c2': 'शिराविन्यास',
    's2_a2': 'पत्ती पर मैग्निफायर का उपयोग करें।',
    's2_o2': 'जाल जैसी नसें पाई गईं।',
    's2_c3': 'रिकॉर्डिंग',
    's2_a3': 'शिराविन्यास आइकन रखें।',
    's2_o3': 'डेटा रिकॉर्ड किया गया।',
    's2_c4': 'जड़ें',
    's2_a4': 'आधार पर एक्स-रे का उपयोग करें।',
    's2_o4': 'मुख्य मोटी जड़ (मूसला जड़) पाई गई।',
    's2_c5': 'रिकॉर्डिंग',
    's2_a5': 'जड़ आइकन रखें।',
    's2_o5': 'डेटा रिकॉर्ड किया गया।',
    's2_c6': 'तुलना',
    's2_a6': 'लेमनग्रास का निरीक्षण करें।',
    's2_o6': 'समानांतर नसें और रेशेदार जड़ें पाई गईं और रिकॉर्ड की गईं।',
    's2_c7': 'विश्लेषण',
    's2_a7': 'पूरी हुई तालिका की समीक्षा करें।',
    's2_o7': 'पत्तियों और जड़ों के बीच स्पष्ट पैटर्न उभरता है।',
    's2_hud_1': 'चरण 1: सदाबहार पौधे पर टैप करें।',
    's2_hud_2':
        "चरण 2: नसों को देखने के लिए 'मैग्निफाइंग ग्लास' को पत्ती पर खींचें।",
    's2_hud_3':
        "चरण 3: 'जालिकारूपी शिराविन्यास' आइकन को तालिका 2.4 में खींचें।",
    's2_hud_4':
        "चरण 4: जड़ों को देखने के लिए 'एक्स-रे स्कैनर' को आधार पर खींचें।",
    's2_hud_5': "चरण 5: 'मूसला जड़' आइकन को तालिका 2.4 में खींचें।",
    's2_hud_6': 'चरण 6: लेमनग्रास पौधे के लिए प्रक्रिया दोहराएं।',
    's2_hud_7': 'चरण 7: तालिका में पैटर्न देखें।',
    's2_sum':
        'आपने प्रकृति के एक छिपे हुए नियम की खोज की! जालिकारूपी शिराविन्यास वाले पौधों में आमतौर पर मूसला जड़ें होती हैं, जबकि समानांतर शिराविन्यास वाले पौधों में रेशेदार जड़ें होती हैं।',
    'sum_heading': 'परिदृश्य पूर्ण!',
    'next_msg': 'अन्वेषण 1 पूरा हुआ। कृपया साइडबार से अगला चुनें!',
    'btn_conclude': 'अवलोकन पूर्ण करें',
    'toolkit': 'टूलकिट',
    'notebook_2_1': 'नोटबुक 2.1',
    'notebook_2_2': 'नोटबुक 2.2',
    'notebook_2_4': 'नोटबुक 2.4',
    'table_2_1': 'तालिका 2.1: पौधे का अवलोकन',
    'table_2_2': 'तालिका 2.2: पशु अवलोकन',
    'table_2_4': 'तालिका 2.4: शिराविन्यास और जड़ें',
    'plant_name': 'पौधा',
    'stem_type': 'तने का प्रकार',
    'animal_name': 'जानवर',
    'movement': 'चलने के अंग',
    'venation': 'शिराविन्यास',
    'root_type': 'जड़ का प्रकार',
    'pattern_revealed':
        'पैटर्न का खुलासा! जालिकारूपी शिराविन्यास मूसला जड़ से, और समानांतर रेशेदार जड़ से संबंधित है।',
    'items_tray': 'वस्तुओं की ट्रे',
    'name_hibiscus': 'गुड़हल',
    'name_crow': 'कौवा',
    'name_sada': 'सदाबहार',
    'name_lemon': 'लेमनग्रास',
    'lbl_hard': 'कठोर',
    'tool_hand': 'टच हैंड',
    'tool_mag': 'मैग्निफाइंग ग्लास',
    'tool_xray': 'एक्स-रे स्कैनर',
    'item_hard_stem': 'कठोर तना',
    'item_legs': 'पैर',
    'item_wings': 'पंख',
    'item_reticulate': 'जालिकारूपी शिराविन्यास',
    'item_parallel': 'समानांतर शिराविन्यास',
    'item_taproot': 'मूसला जड़',
    'item_fibrous': 'रेशेदार जड़',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'focus_lbl': 'ध्यान दें',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'hint_tap_hibiscus':
        'गुड़हल के पौधे से शुरू करें: ज़ूम इन करने के लिए उस पर टैप करें।',
    'hint_tap_crow': 'अब पेड़ की शाखा पर बैठे कौवे पर टैप करें।',
    'hint_tap_sada': 'सदाबहार के पौधे से शुरू करें: पहले उस पर टैप करें।',
    'hint_tap_lemon': 'अब लेमनग्रास के पौधे पर टैप करें।',
    'miss_hand': 'निशाना चूक गया! टच हैंड को सीधे गुड़हल के तने पर खींचें।',
    'miss_mag_sada':
        'निशाना चूक गया! मैग्निफाइंग ग्लास को सीधे सदाबहार की बड़ी पत्ती पर खींचें।',
    'miss_mag_lemon':
        'निशाना चूक गया! मैग्निफाइंग ग्लास को सीधे लेमनग्रास की लंबी पत्ती पर खींचें।',
    'miss_xray_sada':
        'निशाना चूक गया! एक्स-रे स्कैनर को सदाबहार के पौधे के आधार की ज़मीन पर खींचें।',
    'miss_xray_lemon':
        'निशाना चूक गया! एक्स-रे स्कैनर को लेमनग्रास के पौधे के आधार की ज़मीन पर खींचें।',
    'miss_item': "'{item}' आइकन को तालिका में उसके कॉलम में छोड़ें।",
    'wrong_cell': "यह '{item}' आइकन का सही कॉलम नहीं है। फिर से कोशिश करें!",
    's2_lemon_mag':
        "लेमनग्रास: नसों का पैटर्न देखने के लिए 'मैग्निफाइंग ग्लास' को उसकी पत्ती पर खींचें।",
    's2_lemon_xray': "लेमनग्रास: 'एक्स-रे स्कैनर' को पौधे के आधार पर खींचें।",
    's2_lemon_record':
        "लेमनग्रास: 'समानांतर शिराविन्यास' और 'रेशेदार जड़' आइकनों को तालिका में उसकी पंक्ति में खींचें।",
    'scene_s1':
        'एक बगीचा जिसमें गुड़हल का पौधा और एक बिना पत्तों वाला पेड़ है, जिसकी शाखा पर कौवा बैठा है',
    'scene_s2':
        'एक क्यारी जिसमें बाईं ओर सदाबहार का पौधा और दाईं ओर लेमनग्रास का पौधा है',
    'target_hibiscus': 'गुड़हल का पौधा',
    'target_crow': 'पेड़ की शाखा पर कौवा',
    'target_sada': 'सदाबहार का पौधा',
    'target_lemon': 'लेमनग्रास का पौधा',
    'target_stem': 'गुड़हल के पौधे का तना',
    'target_sada_leaf': 'सदाबहार की बड़ी पत्ती',
    'target_lemon_leaf': 'लेमनग्रास की लंबी पत्ती',
    'target_sada_base': 'सदाबहार के पौधे के आधार की ज़मीन',
    'target_lemon_base': 'लेमनग्रास के पौधे के आधार की ज़मीन',
  },
};

/// Steps of each scenario (HTML `ScenariosData[…].steps`).
const List<int> _stepCounts = [6, 7];

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
    for (var i = 1; i <= _stepCounts[index]; i++)
      _StepInfo(
        focus: t('s${n}_c$i'),
        action: t('s${n}_a$i'),
        result: t('s${n}_o$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table. The step
/// observations are shown in the accordion once each step is done.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('scen_$n'),
        objective: t('s${n}_obj'),
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

/// The camera glides right up to the plants and the crow: solids nearer
/// than this (or behind the camera) are not drawn, and the ground is
/// clipped here.
const double _cullDepth = 0.6;

/// HTML `scene.fog = new THREE.Fog(0xecfdf5, 10, 40)` (by view depth).
const double _fogNear = 10;
const double _fogFar = 40;

/// Fog is quantised to this many steps so the shaded-ball cache stays
/// small while the camera glides.
const double _fogSteps = 32;

/// HTML `AmbientLight(0xffffff, 0.8)` and `DirectionalLight(0xffffff, 0.6)`
/// at (10, 20, 10), normalised.
const double _ambient = 0.8;
const double _diffuse = 0.6;
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Scene labels: 13 design px, enlarged up to 1.8x on small stages so the
/// HTML's text sprites stay readable on phones; chip padding as a share of
/// the label size.
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

/// Longest frame step used by the simulation (s), and how long a re-fit of
/// the scene slides (s).
const double _maxFrameStep = 0.1;
const double _framingSeconds = 0.4;

/// Canvas cards: the top of the toolkit (below the toast band), the band
/// kept for the HUD chip while the sidebar is open, the gap kept between a
/// card and the scene, and the notebook's width (dp, x UI scale).
const double _cardTop = 56;
const double _hudBand = 66;
const double _cardGap = 8;
const double _notebookWidth = 290;

/// Floating mission card (sidebar collapsed): its top, and on phones
/// (screens shorter than [_compactBelow]) its greatest height as a fraction
/// of the screen (as the shell lays it out).
const double _missionTop = 12;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;

/// The fitted scene is never drawn smaller than this.
const double _minZoom = 0.3;

// ------------------------------------------------------------- timings

/// HTML camera tweens: 1000 ms to a plant, 800 ms to the crow (Cubic.Out).
/// `resetCamera()` jumped back to the start view; it glides here.
const double _zoomSeconds = 1;
const double _crowZoomSeconds = 0.8;
const double _resetSeconds = 0.8;

/// HTML `setTimeout`s: the toolkit 1200 ms after a plant is tapped, the
/// next step 1500 ms after a tool has revealed something, 800 ms after the
/// last icon of a step is dropped, the notebook's 300 ms fade, the crow's
/// flight 500 ms after the tap, the pattern lines 500 ms after the table is
/// complete and 'Complete Observation' 2000 ms after them.
const int _toolkitMs = 1200;
const int _revealMs = 1500;
const int _recordMs = 800;
const int _fadeMs = 300;
const int _flightDelayMs = 500;
const int _linesMs = 500;
const int _conclusionMs = 2000;

/// HTML crow flight: up in 1000 ms while it turns (`rotation.y += 0.1` a
/// frame, one turn a second), back to its branch in 1000 ms. Added: the
/// wings beat while it flies.
const double _flightUp = 1;
const double _flightDown = 1;
const double _flapRate = 22;
const double _flapMax = 1.3;

/// Added: the glowing veins and roots fade in instead of popping.
const double _glowFade = 0.4;

// --------------------------------------------------------------- world

/// Scenario 1: ground `PlaneGeometry(50, 50)`; the Hibiscus group at
/// (-4, 0, 2); the tree group at (6, 0, -5); the crow on the branch at
/// (3, 6, -5).
const double _walkHalf = 25;
const _V _hibiscusPos = _V(-4, 0, 2);
const _V _treePos = _V(6, 0, -5);
const _V _crowPerch = _V(3, 6, -5);

/// The HTML crow flew to (0, 10, 2), behind the close-up camera and out of
/// the picture; it now flies up to the left of its branch, in view.
const _V _crowApex = _V(1.6, 7.5, -4.4);

/// Scenario 2: garden bed `PlaneGeometry(40, 20)` over a dirt box 4 deep;
/// Sadabahar at (-5, 0, 2), Lemongrass at (5, 0, 2).
const double _bedHalfW = 20;
const double _bedHalfD = 10;
const double _dirtDepth = 4;
const _V _sadaPos = _V(-5, 0, 2);
const _V _lemonPos = _V(5, 0, 2);

/// HTML x-ray test `hitGround.point.distanceTo(base) < 3`, and the dark
/// `CircleGeometry(2.5)` laid on the ground at the scanned plant.
const double _xrayRange = 3;
const double _xrayHoleR = 2.5;

/// Text sprites (`createTextSprite`) and the 'Hard' sprite 1 above the
/// touched point of the stem.
const _V _hibiscusLabel = _V(-4, 5.5, 2);
const _V _crowLabel = _V(3, 8, -5);
const _V _sadaLabel = _V(-5, 4.5, 2);
const _V _lemonLabel = _V(5, 5, 2);
const double _hardLift = 1;

/// Largest zoom of each fitted view (the HTML cameras are zoom 1). The
/// close-ups show the whole plant (the HTML cut off the flowers, the crow's
/// label and the roots), so they are usually fitted below 1.
const double _maxZoomWide = 1.3;
const double _maxZoomClose = 1;

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
  static const _V one = _V(1, 1, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  _V operator -() => _V(-x, -y, -z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A rotation matrix (row-major), built like a Three.js `Euler` in its
/// default XYZ order: Rx · Ry · Rz.
@immutable
class _M3 {
  const _M3(
    this.xx,
    this.xy,
    this.xz,
    this.yx,
    this.yy,
    this.yz,
    this.zx,
    this.zy,
    this.zz,
  );

  factory _M3.euler(double x, double y, double z) {
    final cx = math.cos(x), sx = math.sin(x);
    final cy = math.cos(y), sy = math.sin(y);
    final cz = math.cos(z), sz = math.sin(z);
    return _M3(
      cy * cz,
      -cy * sz,
      sy,
      cx * sz + sx * sy * cz,
      cx * cz - sx * sy * sz,
      -sx * cy,
      sx * sz - cx * sy * cz,
      sx * cz + cx * sy * sz,
      cx * cy,
    );
  }

  static const _M3 identity = _M3(1, 0, 0, 0, 1, 0, 0, 0, 1);

  final double xx;
  final double xy;
  final double xz;
  final double yx;
  final double yy;
  final double yz;
  final double zx;
  final double zy;
  final double zz;

  _V apply(_V v) => _V(
    xx * v.x + xy * v.y + xz * v.z,
    yx * v.x + yy * v.y + yz * v.z,
    zx * v.x + zy * v.y + zz * v.z,
  );

  _M3 operator *(_M3 o) => _M3(
    xx * o.xx + xy * o.yx + xz * o.zx,
    xx * o.xy + xy * o.yy + xz * o.zy,
    xx * o.xz + xy * o.yz + xz * o.zz,
    yx * o.xx + yy * o.yx + yz * o.zx,
    yx * o.xy + yy * o.yy + yz * o.zy,
    yx * o.xz + yy * o.yz + yz * o.zz,
    zx * o.xx + zy * o.yx + zz * o.zx,
    zx * o.xy + zy * o.yy + zz * o.zy,
    zx * o.xz + zy * o.yz + zz * o.zz,
  );
}

/// A Three.js group: where it is and how it is turned. Builds the HTML
/// meshes (spheres, cylinders, cones, planes) as world-space [_Solid]s.
@immutable
class _Pose {
  const _Pose(this.origin, [this.rot = _M3.identity]);

  final _V origin;
  final _M3 rot;

  _V at(_V p) => origin + rot.apply(p);

  /// A child group at [p], turned by [turn].
  _Pose child(_V p, [_M3 turn = _M3.identity]) => _Pose(at(p), rot * turn);

  /// `SphereGeometry(r)` scaled by [scale] at [p], turned by [turn].
  _Solid sphere(
    _V p,
    double r,
    Color color, {
    _V scale = _V.one,
    _M3 turn = _M3.identity,
  }) {
    final m = rot * turn;
    return _Solid.blob(
      at(p),
      m.apply(_V(r * scale.x, 0, 0)),
      m.apply(_V(0, r * scale.y, 0)),
      m.apply(_V(0, 0, r * scale.z)),
      color,
    );
  }

  /// `CylinderGeometry(top, bottom, h)` (a cone has [top] 0) at [p], turned
  /// by [turn]; its top end is local +y.
  _Solid cylinder(
    _V p,
    double top,
    double bottom,
    double h,
    Color color, {
    _M3 turn = _M3.identity,
  }) {
    final half = (rot * turn).apply(_V(0, h / 2, 0));
    final c = at(p);
    return _Solid.rod(c - half, c + half, bottom, top, color);
  }

  /// `PlaneGeometry(w, h)` at [p], turned by [turn].
  _Solid plane(
    _V p,
    double w,
    double h,
    Color color, {
    _M3 turn = _M3.identity,
    _Veins veins = _Veins.none,
    bool blade = false,
    _Tag tag = _Tag.none,
  }) {
    final m = rot * turn;
    return _Solid.leaf(
      at(p),
      m.apply(_V(w / 2, 0, 0)),
      m.apply(_V(0, h / 2, 0)),
      color,
      veins: veins,
      blade: blade,
      tag: tag,
    );
  }
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

  /// View depth of [w] (Three.js `-mvPosition.z`, also used by the fog).
  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w].
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

  /// The screen vector of the small world vector [v] at [w] (the
  /// projection's derivative), for drawing ellipsoids.
  Offset jac(_V w, _V v) {
    final d = w - eye;
    final z = math.max(_near, d.dot(f));
    final vz = v.dot(f);
    return Offset(
      scale * (v.dot(r) - d.dot(r) * vz / z) / z,
      -scale * (v.dot(u) - d.dot(u) * vz / z) / z,
    );
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the horizontal plane at height [y].
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen y of the ground (y = 0) at view depth [depth] (the camera has
  /// no roll, so a screen row of the ground has one depth).
  double groundRow(double depth) {
    final k = (-eye.y / depth - f.y) / u.y;
    return center.dy - k * scale;
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

// --------------------------------------------------------------- models

/// The HTML camera positions: the start view (`resetCamera()`) and the
/// close-ups tweened to when a plant or the crow is tapped.
enum _Shot {
  wide(_View(_V(0, 8, 22), _V(0, 2, 0)), _maxZoomWide),
  hibiscus(_View(_V(-4, 3, 7), _V(-4, 2, 2)), _maxZoomClose),
  crow(_View(_V(3, 7, -1), _V(3, 6, -5)), _maxZoomClose),
  sada(_View(_V(-5, 3, 6), _V(-5, 2, 2)), _maxZoomClose),
  lemon(_View(_V(5, 3, 6), _V(5, 2, 2)), _maxZoomClose);

  const _Shot(this.view, this.maxZoom);

  final _View view;
  final double maxZoom;

  /// The views of scenario [index].
  static List<_Shot> of(int index) =>
      index == 0 ? const [wide, hibiscus, crow] : const [wide, sada, lemon];
}

/// The toolkit's tools (HTML `.draggable-tool`).
enum _Tool {
  hand('tool_hand'),
  magnifier('tool_mag'),
  xray('tool_xray');

  const _Tool(this.key);

  /// String table key of its name.
  final String key;
}

/// The notebook icons (HTML `Icons`); each fits exactly one table cell
/// (HTML `data-accept`).
enum _Item {
  hardStem('item_hard_stem'),
  legs('item_legs'),
  wings('item_wings'),
  reticulate('item_reticulate'),
  taproot('item_taproot'),
  parallel('item_parallel'),
  fibrous('item_fibrous');

  const _Item(this.key);

  final String key;
}

/// The notebook tables (HTML `#table-2-1`, `#table-2-2`, `#table-2-4`).
enum _Table {
  plants('notebook_2_1', 'table_2_1'),
  animals('notebook_2_2', 'table_2_2'),
  roots('notebook_2_4', 'table_2_4');

  const _Table(this.notebookKey, this.titleKey);

  final String notebookKey;
  final String titleKey;
}

/// What can be tapped in the scene (HTML raycasts on the groups).
enum _Thing {
  hibiscus('target_hibiscus'),
  crow('target_crow'),
  sada('target_sada'),
  lemon('target_lemon');

  const _Thing(this.key);

  final String key;
}

/// Where a tool is dragged (HTML raycasts on `hibiscusStem`,
/// `sadaLeafTarget`, `lemonLeafTarget` and `groundPlane`).
enum _Spot {
  stem('target_stem'),
  sadaLeaf('target_sada_leaf'),
  lemonLeaf('target_lemon_leaf'),
  sadaBase('target_sada_base'),
  lemonBase('target_lemon_base');

  const _Spot(this.key);

  final String key;
}

enum _Kind { blob, rod, leaf }

/// Vein texture of a leaf (HTML `createLeafTexture`).
enum _Veins { none, reticulate, parallel }

/// The two leaves the magnifying glass is dragged over.
enum _Tag { none, sadaLeaf, lemonLeaf }

/// One HTML mesh in world space: an ellipsoid (a scaled sphere) with
/// semi-axes [a], [b] and [c]; a rod (cylinder or cone) from [a] (radius
/// [r0]) to [b] (radius [r1]); or a leaf (a textured plane) spanned by the
/// half-axes [a] (across) and [b] (along, towards the tip).
@immutable
class _Solid {
  const _Solid.blob(this.center, this.a, this.b, this.c, this.color)
    : kind = _Kind.blob,
      r0 = 0,
      r1 = 0,
      veins = _Veins.none,
      blade = false,
      tag = _Tag.none;

  factory _Solid.rod(_V from, _V to, double r0, double r1, Color color) =>
      _Solid._rod((from + to) * 0.5, from, to, r0, r1, color);

  const _Solid._rod(this.center, this.a, this.b, this.r0, this.r1, this.color)
    : kind = _Kind.rod,
      c = _V.zero,
      veins = _Veins.none,
      blade = false,
      tag = _Tag.none;

  const _Solid.leaf(
    this.center,
    this.a,
    this.b,
    this.color, {
    this.veins = _Veins.none,
    this.blade = false,
    this.tag = _Tag.none,
  }) : kind = _Kind.leaf,
       c = _V.zero,
       r0 = 0,
       r1 = 0;

  final _Kind kind;
  final _V center;
  final _V a;
  final _V b;
  final _V c;
  final double r0;
  final double r1;
  final Color color;
  final _Veins veins;

  /// A grass blade (wide base, pointed tip) instead of a pointed oval leaf.
  final bool blade;
  final _Tag tag;

  /// World bounds (min, max).
  (_V, _V) get bounds {
    switch (kind) {
      case _Kind.blob:
        double ext(double p, double q, double s) =>
            math.sqrt(p * p + q * q + s * s);
        final e = _V(
          ext(a.x, b.x, c.x),
          ext(a.y, b.y, c.y),
          ext(a.z, b.z, c.z),
        );
        return (center - e, center + e);
      case _Kind.rod:
        final r = math.max(r0, r1);
        return (
          _V(
            math.min(a.x, b.x) - r,
            math.min(a.y, b.y) - r,
            math.min(a.z, b.z) - r,
          ),
          _V(
            math.max(a.x, b.x) + r,
            math.max(a.y, b.y) + r,
            math.max(a.z, b.z) + r,
          ),
        );
      case _Kind.leaf:
        final e = _V(
          a.x.abs() + b.x.abs(),
          a.y.abs() + b.y.abs(),
          a.z.abs() + b.z.abs(),
        );
        return (center - e, center + e);
    }
  }

  /// The leaf's corners (u, v = ±1).
  List<_V> get corners => [
    center - a - b,
    center + a - b,
    center + a + b,
    center - a + b,
  ];

  /// Points on its surface that the framing keeps in view: an ellipsoid's
  /// six axis ends, a rod's ends widened by their radii, a leaf's corners.
  /// (A model's bounding box is far too big for the close-up cameras.)
  List<_V> get extremes => switch (kind) {
    _Kind.blob => [
      center + a,
      center - a,
      center + b,
      center - b,
      center + c,
      center - c,
    ],
    _Kind.rod => [
      for (final (end, r) in [(a, r0), (b, r1)]) ...[
        end + _V(r, 0, 0),
        end - _V(r, 0, 0),
        end + _V(0, r, 0),
        end - _V(0, r, 0),
      ],
    ],
    _Kind.leaf => corners,
  };
}

/// The HTML scene builders (`buildS1Scene`, `buildS2Scene`) as world-space
/// solids, made once. `Math.random()` placements use fixed seeds, so the
/// plants look the same every time.
abstract final class _Models {
  /// The Hibiscus: stem first (the Touch Hand target), branch, leaves,
  /// flower (calyx, centre, petals, stamen tube, pollen, stigma pads), bud.
  static final List<_Solid> hibiscus = _hibiscus();
  static final List<_Solid> tree = _tree();
  static final List<_Solid> sada = _sada();
  static final List<_Solid> sadaRoots = _sadaRoots();
  static final List<_Solid> lemon = _lemon();
  static final List<_Solid> lemonRoots = _lemonRoots();

  static final _Solid stem = hibiscus.first;
  static final _Solid sadaLeaf = sada.firstWhere((s) => s.tag == _Tag.sadaLeaf);
  static final _Solid lemonLeaf = lemon.firstWhere(
    (s) => s.tag == _Tag.lemonLeaf,
  );

  /// World boxes of the tappable plants.
  static final (_V, _V) hibiscusBox = boundsOf(hibiscus);
  static final (_V, _V) sadaBox = boundsOf(sada);
  static final (_V, _V) lemonBox = boundsOf(lemon);

  /// Surface points the views keep in view (see [_Solid.extremes]): each
  /// model with its roots (revealed or not), and the crow on its branch
  /// and at the top of its flight.
  static final List<_V> hibiscusPoints = pointsOf(hibiscus);
  static final List<_V> treePoints = pointsOf(tree);
  static final List<_V> sadaPoints = pointsOf([...sada, ...sadaRoots]);
  static final List<_V> lemonPoints = pointsOf([...lemon, ...lemonRoots]);
  static final List<_V> perchPoints = pointsOf(crow(_crowPerch, 0, 0));
  static final List<_V> apexPoints = pointsOf(crow(_crowApex, 0, _flapMax));

  static List<_V> pointsOf(Iterable<_Solid> solids) => [
    for (final s in solids) ...s.extremes,
  ];

  static (_V, _V) boundsOf(Iterable<_Solid> solids) {
    var lo = const _V(double.infinity, double.infinity, double.infinity);
    var hi = const _V(
      double.negativeInfinity,
      double.negativeInfinity,
      double.negativeInfinity,
    );
    for (final s in solids) {
      final (a, b) = s.bounds;
      lo = _V(math.min(lo.x, a.x), math.min(lo.y, a.y), math.min(lo.z, a.z));
      hi = _V(math.max(hi.x, b.x), math.max(hi.y, b.y), math.max(hi.z, b.z));
    }
    return (lo, hi);
  }

  static List<_Solid> _hibiscus() {
    const g = _Pose(_hibiscusPos);
    final rnd = math.Random(7);
    final out = <_Solid>[
      g.cylinder(const _V(0, 2.25, 0), 0.12, 0.18, 4.5, _Colors.hibiscusStem),
      g.cylinder(
        const _V(0.8, 2.5, 0),
        0.06,
        0.08,
        2,
        _Colors.hibiscusStem,
        turn: _M3.euler(0, 0, -math.pi / 4),
      ),
    ];
    // `addLeaf(x, y, z, rx, ry, rz)`: SphereGeometry(0.5) scaled (1.5, 0.1,
    // 2.5).
    const leaves = [
      (_V(0.3, 1.5, 0.3), 0.2, 0.5, -0.3),
      (_V(-0.3, 2, -0.2), -0.1, -0.4, 0.5),
      (_V(0.2, 3, -0.4), -0.3, 0.2, -0.4),
      (_V(1.5, 3.2, 0), 0.0, 0.0, -0.2),
      (_V(1, 2.2, 0.4), 0.5, 0.5, 0.0),
    ];
    for (final (p, rx, ry, rz) in leaves) {
      out.add(
        g.sphere(
          p,
          0.5,
          _Colors.leaf,
          scale: const _V(1.5, 0.1, 2.5),
          turn: _M3.euler(rx, ry, rz),
        ),
      );
    }
    // Flower group at (-0.2, 4.8, 0.2), rotation (-0.3, -0.4, 0.2).
    final f = g.child(const _V(-0.2, 4.8, 0.2), _M3.euler(-0.3, -0.4, 0.2));
    final flip = _M3.euler(math.pi, 0, 0);
    out
      ..add(
        f.cylinder(
          const _V(0, -0.2, 0),
          0,
          0.5,
          0.6,
          _Colors.calyx,
          turn: flip,
        ),
      )
      ..add(
        f.cylinder(
          const _V(0, 0.2, 0),
          0,
          0.4,
          0.6,
          _Colors.flowerCentre,
          turn: flip,
        ),
      );
    for (var i = 0; i < 5; i++) {
      final a = 2 * math.pi / 5 * i;
      out.add(
        f.sphere(
          _V(math.sin(a) * 0.8, 0.4, math.cos(a) * 0.8),
          1.2,
          _Colors.petal,
          scale: const _V(0.8, 0.05, 1.2),
          turn: _M3.euler(math.pi / 3.5, a, -0.2),
        ),
      );
    }
    out.add(f.cylinder(const _V(0, 1.2, 0), 0.05, 0.08, 2.5, _Colors.petal));
    for (var i = 0; i < 30; i++) {
      final h = 0.8 + rnd.nextDouble() * 1.4;
      final r = 0.1 + rnd.nextDouble() * 0.05;
      final a = rnd.nextDouble() * math.pi * 2;
      out.add(
        f.sphere(_V(math.cos(a) * r, h, math.sin(a) * r), 0.04, _Colors.pollen),
      );
    }
    for (var i = 0; i < 5; i++) {
      final a = 2 * math.pi / 5 * i;
      out
        ..add(
          f.cylinder(
            _V(math.cos(a) * 0.1, 2.4, math.sin(a) * 0.1),
            0.015,
            0.015,
            0.3,
            _Colors.petal,
            turn: _M3.euler(math.cos(a) * 0.5, 0, -math.sin(a) * 0.5),
          ),
        )
        ..add(
          f.sphere(
            _V(math.cos(a) * 0.2, 2.5, math.sin(a) * 0.2),
            0.06,
            _Colors.stigma,
          ),
        );
    }
    // Bud and its sepal.
    out
      ..add(
        g.sphere(
          const _V(2, 3.6, 0),
          0.3,
          _Colors.petal,
          scale: const _V(1, 1.5, 1),
          turn: _M3.euler(0, 0, -0.5),
        ),
      )
      ..add(
        g.cylinder(
          const _V(1.8, 3.3, 0),
          0.05,
          0.25,
          0.4,
          _Colors.calyx,
          turn: _M3.euler(0, 0, -0.5),
        ),
      );
    return out;
  }

  /// Trunk `CylinderGeometry(0.8, 1, 8)` and the branch
  /// `CylinderGeometry(0.2, 0.4, 6)` turned by π/3 the crow sits on.
  static List<_Solid> _tree() {
    const g = _Pose(_treePos);
    return [
      g.cylinder(const _V(0, 4, 0), 0.8, 1, 8, _Colors.bark),
      g.cylinder(
        const _V(-2.5, 5, 0),
        0.2,
        0.4,
        6,
        _Colors.bark,
        turn: _M3.euler(0, 0, math.pi / 3),
      ),
    ];
  }

  /// The crow at [at], turned by [yaw], wings raised by [flap] (rad;
  /// added: the HTML crow flew with folded wings). The HTML's beak cone
  /// pointed into the head; it points forward here.
  static List<_Solid> crow(_V at, double yaw, double flap) {
    final g = _Pose(at, _M3.euler(0, yaw, 0));
    final out = <_Solid>[
      for (final side in const [-0.2, 0.2])
        g.cylinder(_V(side, -0.2, 0.1), 0.03, 0.03, 0.4, _Colors.crowLegs),
      g.cylinder(
        const _V(0, 0, -0.8),
        0,
        0.2,
        1,
        _Colors.crow,
        turn: _M3.euler(math.pi / 2 - 0.2, 0, 0),
      ),
      g.sphere(
        const _V(0, 0.2, 0),
        0.5,
        _Colors.crow,
        scale: const _V(0.8, 0.8, 1.4),
      ),
      g.sphere(const _V(0, 0.5, 0.6), 0.35, _Colors.crow),
      _Solid.rod(
        g.at(const _V(0, 0.5, 0.7)),
        g.at(const _V(0, 0.4, 1.18)),
        0.12,
        0,
        _Colors.beak,
      ),
    ];
    for (final side in const [-1.0, 1.0]) {
      final swing = _M3.euler(0, 0, side * flap);
      out.add(
        g.sphere(
          _V(side * 0.4, 0.44, 0) + swing.apply(const _V(0, -0.24, 0)),
          0.4,
          _Colors.crow,
          scale: const _V(0.3, 0.6, 1.2),
          turn: swing * _M3.euler(-0.1, 0, 0),
        ),
      );
    }
    return out;
  }

  /// Sadabahar: stem, six reticulate leaves around it, the big target leaf
  /// and three purple flowers with white centres.
  static List<_Solid> _sada() {
    const g = _Pose(_sadaPos);
    final rnd = math.Random(11);
    final out = <_Solid>[
      g.cylinder(const _V(0, 1.5, 0), 0.08, 0.1, 3, _Colors.sadaStem),
    ];
    for (var i = 0; i < 6; i++) {
      final a = 2 * math.pi / 6 * i;
      out.add(
        g.plane(
          _V(math.sin(a) * 0.4, 0.5 + i * 0.4, math.cos(a) * 0.4),
          1,
          1.8,
          _Colors.leaf,
          turn: _M3.euler(rnd.nextDouble() * 0.5, a, math.pi / 2 - 0.2),
          veins: _Veins.reticulate,
        ),
      );
    }
    out.add(
      g.plane(
        const _V(1.5, 2, 0),
        1.5,
        2.5,
        _Colors.leaf,
        turn: _M3.euler(0.2, 0, -math.pi / 3),
        veins: _Veins.reticulate,
        tag: _Tag.sadaLeaf,
      ),
    );
    const flowers = [
      (_V(-0.5, 3.2, 0.5), 0.3, 0.5, 0.2),
      (_V(0.6, 2.8, -0.6), -0.2, -0.4, -0.3),
      (_V(0, 3.5, -0.2), 0.5, 0.0, 0.0),
    ];
    for (final (p, rx, ry, rz) in flowers) {
      final fl = g.child(p, _M3.euler(rx, ry, rz));
      for (var k = 0; k < 5; k++) {
        final a = 2 * math.pi / 5 * k;
        out.add(
          fl.sphere(
            _V(math.sin(a) * 0.25, 0, math.cos(a) * 0.25),
            0.3,
            _Colors.sadaPetal,
            scale: const _V(1, 0.1, 1.5),
            turn: _M3.euler(0, a, 0),
          ),
        );
      }
      out.add(fl.sphere(_V.zero, 0.12, _Colors.white));
    }
    return out;
  }

  /// Taproot `CylinderGeometry(0.15, 0.02, 3)` and eight side roots.
  static List<_Solid> _sadaRoots() {
    const g = _Pose(_sadaPos);
    final rnd = math.Random(13);
    final out = <_Solid>[
      g.cylinder(const _V(0, -1.5, 0), 0.15, 0.02, 3, _Colors.glow),
    ];
    for (var i = 0; i < 8; i++) {
      final x = (rnd.nextDouble() - 0.5) * 0.5;
      final y = -0.5 - rnd.nextDouble() * 2;
      final turn = (rnd.nextDouble() - 0.5) * math.pi;
      out.add(
        g.cylinder(
          _V(x, y, 0),
          0.03,
          0.01,
          1,
          _Colors.glow,
          turn: _M3.euler(0, 0, turn),
        ),
      );
    }
    return out;
  }

  /// Lemongrass: twelve blades and the long target leaf.
  static List<_Solid> _lemon() {
    const g = _Pose(_lemonPos);
    final rnd = math.Random(17);
    final out = <_Solid>[];
    for (var i = 0; i < 12; i++) {
      final x = (rnd.nextDouble() - 0.5) * 0.5;
      final z = (rnd.nextDouble() - 0.5) * 0.5;
      final rx = (rnd.nextDouble() - 0.5) * 0.2;
      final ry = rnd.nextDouble() * math.pi;
      final rz = (rnd.nextDouble() - 0.5) * 0.2;
      out.add(
        g.plane(
          _V(x, 2, z),
          0.4,
          4,
          _Colors.blade,
          turn: _M3.euler(rx, ry, rz),
          blade: true,
        ),
      );
    }
    out.add(
      g.plane(
        const _V(0, 2.5, 1),
        0.6,
        5,
        _Colors.leaf,
        turn: _M3.euler(-0.2, 0, 0),
        veins: _Veins.parallel,
        blade: true,
        tag: _Tag.lemonLeaf,
      ),
    );
    return out;
  }

  /// Twenty fibrous roots `CylinderGeometry(0.04, 0.01, 2)` fanning down
  /// from the base.
  static List<_Solid> _lemonRoots() {
    const g = _Pose(_lemonPos);
    final rnd = math.Random(19);
    final out = <_Solid>[];
    for (var i = 0; i < 20; i++) {
      final rx = (rnd.nextDouble() - 0.5) * 0.5;
      final ry = (rnd.nextDouble() - 0.5) * 0.5;
      final rz = (rnd.nextDouble() - 0.5) * 0.5;
      out.add(
        g.cylinder(
          _V(math.sin(rz), -math.cos(rz), 0),
          0.04,
          0.01,
          2,
          _Colors.glow,
          turn: _M3.euler(rx, ry, rz),
        ),
      );
    }
    return out;
  }
}

/// One confetti piece (canvas-confetti): launch angle, speed, colour and
/// spin.
typedef _Confetto = ({double angle, double velocity, Color color, double spin});

/// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})` with
/// the summary: canvas-confetti's 200 ticks of 1/60 s, velocity x 0.9 per
/// tick, gravity 3 px per tick and start velocity 45 (scaled for the
/// stage).
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);
const Rect _confettiPiece = Rect.fromLTWH(-5, -3, 10, 6);

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// A camera move, tool effect or flight is playing; taps and tools wait.
  bool busy = false;

  /// 'Complete Observation' is offered (HTML `triggerConclusionState`), and
  /// was tapped.
  bool conclusionReady = false;
  bool concluded = false;

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

  // ---------------------------------------------------------- scenario 1
  bool hibiscusTapped = false;
  bool stemTouched = false;
  bool crowTapped = false;

  /// Where the 'Hard' sprite floats (null: not shown).
  _V? hardAt;

  /// When the crow took off (null: on its branch).
  double? flightStart;

  // ---------------------------------------------------------- scenario 2
  bool sadaTapped = false;
  bool sadaLeafScanned = false;
  bool sadaRootScanned = false;
  bool lemonTapped = false;
  bool lemonLeafScanned = false;
  bool lemonRootScanned = false;

  /// When the veins started to glow and the roots appeared.
  double? sadaGlowAt;
  double? lemonGlowAt;
  double? sadaRootsAt;
  double? lemonRootsAt;

  /// Base of the plant the x-ray circle lies at (null: none).
  _V? xrayAt;

  // ---------------------------------------------------- toolkit, notebook
  /// The tool offered in the toolkit (null: toolkit hidden).
  _Tool? toolkit;

  /// The table on show (null: notebook hidden) and whether it is faded in.
  _Table? table;
  bool notebookShown = false;

  /// Icons waiting in the tray, and icons placed in their cells.
  final List<_Item> tray = [];
  final Set<_Item> placed = {};

  /// The pattern lines and message of Table 2.4.
  bool linesShown = false;

  // -------------------------------------------------------------- summary
  double? confettiAt;
  final List<_Confetto> confetti = () {
    final rnd = math.Random(2);
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

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    conclusionReady = false;
    concluded = false;
    hibiscusTapped = false;
    stemTouched = false;
    crowTapped = false;
    hardAt = null;
    flightStart = null;
    sadaTapped = false;
    sadaLeafScanned = false;
    sadaRootScanned = false;
    lemonTapped = false;
    lemonLeafScanned = false;
    lemonRootScanned = false;
    sadaGlowAt = null;
    lemonGlowAt = null;
    sadaRootsAt = null;
    lemonRootsAt = null;
    xrayAt = null;
    toolkit = null;
    table = null;
    notebookShown = false;
    tray.clear();
    placed.clear();
    linesShown = false;
    confettiAt = null;
    snapTo(_Shot.wide);
  }

  // --------------------------------------------------------------- camera

  /// The fitted framing of [s].
  _Framing fit(_Shot s) => _fitNow[s] ?? _Framing.base;

  /// HTML `new TWEEN.Tween(camera.position).to(…)` with `controls.target`
  /// (here eased together).
  void glideTo(_Shot to, double seconds) {
    _fromView = view;
    _fromFraming = framing;
    shot = to;
    _glideStart = time;
    _glideSeconds = seconds;
    _glideCurve = Curves.easeOutCubic;
  }

  /// `resetCamera()`: back to the start view (gliding).
  void glideHome() {
    glideTo(_Shot.wide, _resetSeconds);
    _glideCurve = Curves.easeInOutCubic;
  }

  void snapTo(_Shot to) {
    shot = to;
    _glideSeconds = 0;
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
  }

  /// The scene has stopped sliding and the camera has stopped gliding.
  bool get framingSettled => _fitT >= 1 && !gliding;

  /// HTML `animate()`: the framing slides, the camera glides.
  void advance(double dt) {
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

  // ------------------------------------------------------------------ crow

  /// The crow now: where it is, how far it has turned and how far its
  /// wings are raised. HTML: up to the top of its flight in 1 s turning one
  /// full turn, then back to the branch in 1 s.
  ({_V at, double yaw, double flap}) get crowPose {
    final f0 = flightStart;
    if (f0 == null) return (at: _crowPerch, yaw: 0, flap: 0);
    final t = time - f0;
    final beat = 0.5 + 0.5 * math.sin(t * _flapRate);
    if (t < _flightUp) {
      final k = (t / _flightUp).clamp(0.0, 1.0);
      return (
        at: _V.lerp(_crowPerch, _crowApex, k),
        yaw: 2 * math.pi * k,
        flap: _flapMax * beat * math.min(1, k * 5),
      );
    }
    final k = ((t - _flightUp) / _flightDown).clamp(0.0, 1.0);
    return (
      at: _V.lerp(_crowApex, _crowPerch, k),
      yaw: 0,
      flap: _flapMax * beat * math.min(1, (1 - k) * 5),
    );
  }

  /// 0 … 1 while a glow or roots fade in from [since].
  double fadeIn(double? since) =>
      since == null ? 0 : ((time - since) / _glowFade).clamp(0.0, 1.0);

  /// How much the veins of the target leaf [tag] glow (0 … 1).
  double glow(_Tag tag) => switch (tag) {
    _Tag.sadaLeaf => fadeIn(sadaGlowAt),
    _Tag.lemonLeaf => fadeIn(lemonGlowAt),
    _Tag.none => 0,
  };

  // ------------------------------------------------------------- picking

  /// The world box of a tappable thing.
  (_V, _V) boxOf(_Thing thing) => switch (thing) {
    _Thing.hibiscus => _Models.hibiscusBox,
    _Thing.crow => _Models.boundsOf(_Models.crow(crowPose.at, 0, 0)),
    _Thing.sada => _Models.sadaBox,
    _Thing.lemon => _Models.lemonBox,
  };

  /// The things of the current scenario that are in front of the camera.
  List<_Thing> get things => [
    for (final t
        in scenario == 0
            ? const [_Thing.hibiscus, _Thing.crow]
            : const [_Thing.sada, _Thing.lemon])
      if (cam.depth(_mid(boxOf(t))) > _cullDepth + 1) t,
  ];

  static _V _mid((_V, _V) box) => (box.$1 + box.$2) * 0.5;

  /// Screen rect of [thing] (its projected world box).
  Rect rectOf(_Thing thing) {
    final (lo, hi) = boxOf(thing);
    return cam.boxRect(lo, hi);
  }

  /// HTML raycast on the groups: the thing under [p] (within half a
  /// finger), the nearest to the camera if several are.
  _Thing? thingAt(Offset p, double touch) {
    _Thing? best;
    var bestDepth = double.infinity;
    for (final t in things) {
      if (!rectOf(t).inflate(touch * 0.5).contains(p)) continue;
      final d = cam.depth(_mid(boxOf(t)));
      if (d < bestDepth) {
        best = t;
        bestDepth = d;
      }
    }
    return best;
  }

  /// HTML raycast on `hibiscusStem`: the pointer over the stem (or within
  /// a finger's reach of it). Returns the touched point of the stem.
  _V? stemAt(Offset p, double touch) {
    final s = _Models.stem;
    if (cam.depth(s.a) < _cullDepth || cam.depth(s.b) < _cullDepth) {
      return null;
    }
    final pa = cam.p(s.a), pb = cam.p(s.b);
    final d = pb - pa;
    final len2 = d.distanceSquared;
    if (len2 < 1) return null;
    final w = p - pa;
    final t = ((w.dx * d.dx + w.dy * d.dy) / len2).clamp(0.0, 1.0);
    final at = _V.lerp(s.a, s.b, t);
    final radius = (s.r0 + (s.r1 - s.r0) * t) * cam.scaleAt(at);
    if ((p - (pa + d * t)).distance > radius + touch * 0.6) return null;
    return at;
  }

  /// HTML raycast on a target leaf: over its outline (or within half a
  /// finger of it).
  bool overLeaf(_Solid leaf, Offset p, double touch) {
    if (cam.depth(leaf.center) < _cullDepth) return false;
    final pts = [for (final c in leaf.corners) cam.p(c)];
    if (_inside(pts, p)) return true;
    for (var i = 0; i < pts.length; i++) {
      if (_segmentDistance(p, pts[i], pts[(i + 1) % pts.length]) <=
          touch * 0.5) {
        return true;
      }
    }
    return false;
  }

  /// HTML raycast on `groundPlane` within 3 of [base].
  bool overBase(_V base, Offset p) {
    final hit = cam.onPlaneY(p, 0);
    if (hit == null) return false;
    if (hit.x.abs() > _bedHalfW || hit.z.abs() > _bedHalfD) return false;
    return (hit - base).length < _xrayRange;
  }

  static bool _inside(List<Offset> poly, Offset p) {
    var inside = false;
    for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final a = poly[i], b = poly[j];
      if ((a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  static double _segmentDistance(Offset p, Offset a, Offset b) {
    final d = b - a;
    final len2 = d.distanceSquared;
    if (len2 < 1e-9) return (p - a).distance;
    final w = p - a;
    final t = ((w.dx * d.dx + w.dy * d.dy) / len2).clamp(0.0, 1.0);
    return (p - (a + d * t)).distance;
  }

  /// Screen rect of a tool target (for its semantics box): the stem, a
  /// target leaf, or a spot of ground at a plant's base.
  Rect? spotRect(_Spot spot) {
    switch (spot) {
      case _Spot.stem:
        final s = _Models.stem;
        if (cam.depth(s.b) < _cullDepth) return null;
        final r = s.r0 * cam.scaleAt(s.a);
        return Rect.fromPoints(cam.p(s.a), cam.p(s.b)).inflate(r);
      case _Spot.sadaLeaf:
      case _Spot.lemonLeaf:
        final leaf = spot == _Spot.sadaLeaf
            ? _Models.sadaLeaf
            : _Models.lemonLeaf;
        if (cam.depth(leaf.center) < _cullDepth) return null;
        final c = cam.p(leaf.center);
        final k = cam.scaleAt(leaf.center);
        final half = math.min(leaf.a.length, leaf.b.length) * k * 0.6;
        return Rect.fromCircle(center: c, radius: math.max(4, half));
      case _Spot.sadaBase:
      case _Spot.lemonBase:
        final base = spot == _Spot.sadaBase ? _sadaPos : _lemonPos;
        if (cam.depth(base) < _cullDepth) return null;
        return Rect.fromCircle(
          center: cam.p(base),
          radius: math.max(6, 0.6 * cam.scaleAt(base)),
        );
    }
  }
}

/// What the framing keeps in view: a point of the unfitted projection and
/// a rect around it that does not scale with the zoom (a label chip;
/// empty for a point of an object).
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

/// Top-left of a chip of [size] centred on its anchor.
Offset _chipOffset(Size size) => Offset(-size.width / 2, -size.height / 2);

class _DiversityLabState
    extends State<Ch2A1ObservingAndRecordingDiversityInNaturePage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (framing), the design box (drops) and the canvas
  /// cards (framing obstacles).
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch2-a1-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch2-a1-design');
  final GlobalKey _notebookKey = GlobalKey(debugLabel: 'ch2-a1-notebook');
  final GlobalKey _toolkitKey = GlobalKey(debugLabel: 'ch2-a1-toolkit');
  final GlobalKey _bottomKey = GlobalKey(debugLabel: 'ch2-a1-bottom');

  /// Touch reach and label size for the current stage scale (design px).
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The icon being dragged: its cell is highlighted (HTML `.highlight`).
  _Item? _draggingItem;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  Map<String, Object> _toastArgs = const {};
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

  /// 1-based step for the shell (steps.length + 1 once the summary opened).
  int get _currentStep =>
      _scene.concluded ? _stepCounts[_scene.scenario] + 1 : _scene.step;

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

  /// HTML `animate()` + `TWEEN.update()`: every motion is a function of the
  /// scene time, so a frame advances the clock, the framing and the camera,
  /// and repaints the canvas.
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

  /// Fits each view of the scenario into the part of the canvas no card
  /// covers: the tool column, the HUD (sidebar open), the floating mission
  /// card (sidebar collapsed), the notebook, the toolkit and the
  /// 'Complete Observation' button.
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
    for (final key in [_notebookKey, _toolkitKey, _bottomKey]) {
      final r = measured(key);
      if (r != null) hard.add(r);
    }
    final s = _scene;
    s
      ..labelLeft = math.max(0.0, (4 - stage.dx) / fit)
      ..labelRight = math.min(
        _design.width,
        (size.width - insets.right - stage.dx) / fit,
      );
    final area = toDesign(free).intersect(_stageRect);
    final obstacles = [for (final r in hard) toDesign(r.inflate(_cardGap))];
    _cache.prepare(_lab.lang, _labelSize);
    s.setFits({
      for (final shot in _Shot.of(s.scenario))
        shot: _fitFraming(_focusFor(shot), area, obstacles, shot.maxZoom),
    }, snap: _snapFraming);
    _snapFraming = false;
  }

  /// What a view must show (HTML camera, zoom 1): the plants, tree and
  /// crow it looks at (with the roots, revealed or not) and their label
  /// chips at their painted size.
  List<_Focus> _focusFor(_Shot shot) {
    final cam = _Cam(shot.view, _Framing.base);
    final items = <_Focus>[];
    void model(List<_V> points) {
      for (final w in points) {
        if (cam.depth(w) > _cullDepth) items.add((cam.p(w), Rect.zero));
      }
    }

    void chip(_V at, String key) {
      if (cam.depth(at) <= _cullDepth) return;
      final size = _cache.chipSize(_t(key));
      items.add((cam.p(at), _chipOffset(size) & size));
    }

    switch (shot) {
      case _Shot.wide:
        if (_scene.scenario == 0) {
          model(_Models.hibiscusPoints);
          model(_Models.treePoints);
          model(_Models.perchPoints);
          chip(_hibiscusLabel, 'name_hibiscus');
          chip(_crowLabel, 'name_crow');
        } else {
          model(_Models.sadaPoints);
          model(_Models.lemonPoints);
          chip(_sadaLabel, 'name_sada');
          chip(_lemonLabel, 'name_lemon');
        }
      case _Shot.hibiscus:
        model(_Models.hibiscusPoints);
        chip(_hibiscusLabel, 'name_hibiscus');
      case _Shot.crow:
        model(_Models.perchPoints);
        model(_Models.apexPoints);
        chip(_crowLabel, 'name_crow');
      case _Shot.sada:
        model(_Models.sadaPoints);
        chip(_sadaLabel, 'name_sada');
      case _Shot.lemon:
        model(_Models.lemonPoints);
        chip(_lemonLabel, 'name_lemon');
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scenario's scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _draggingItem = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// Runs [then] after [ms] (HTML `setTimeout`) if the page is still open.
  void _after(int ms, VoidCallback then) {
    _lab.after(Duration(milliseconds: ms), () {
      if (mounted) then();
    });
  }

  /// [key] from the string table in [lang], with [args] filled in (an icon
  /// is named in the same language).
  String _format(LabLang lang, String key, Map<String, Object> args) =>
      labFormat(labTr(_i18n, lang, key), {
        for (final e in args.entries)
          e.key: switch (e.value) {
            final _Item item => labTr(_i18n, lang, item.key),
            final Object v => v,
          },
      });

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone.
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

  // ------------------------------------------------------------------ taps

  void _onSceneTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.concluded) return;
    final thing = s.thingAt(d.localPosition, _touch);
    if (thing != null) _tapThing(thing);
  }

  /// HTML `pointerdown` raycasts: the Hibiscus (S1 step 1), the crow (S1
  /// step 4), the Sadabahar (S2 step 1) and the Lemongrass (S2 step 6).
  /// The HTML ignored taps on the other one; they now get a hint.
  void _tapThing(_Thing thing) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.concluded) return;
    if (s.scenario == 0) {
      if (s.step == 1 && !s.hibiscusTapped) {
        if (thing == _Thing.hibiscus) {
          _openHibiscus();
        } else {
          _toast('hint_tap_hibiscus', error: true, sound: true);
        }
      } else if (s.step == 4 && !s.crowTapped) {
        if (thing == _Thing.crow) {
          _openCrow();
        } else {
          _toast('hint_tap_crow', error: true, sound: true);
        }
      }
    } else {
      if (s.step == 1 && !s.sadaTapped) {
        if (thing == _Thing.sada) {
          _openSada();
        } else {
          _toast('hint_tap_sada', error: true, sound: true);
        }
      } else if (s.step == 6 && !s.lemonTapped) {
        if (thing == _Thing.lemon) {
          _openLemon();
        } else {
          _toast('hint_tap_lemon', error: true, sound: true);
        }
      }
    }
  }

  /// S1 step 1: click, the camera glides to the Hibiscus (1 s) and, 1.2 s
  /// after the tap, step 2 offers the Touch Hand.
  void _openHibiscus() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..hibiscusTapped = true
        ..busy = true
        ..glideTo(_Shot.hibiscus, _zoomSeconds);
    });
    _after(_toolkitMs, () {
      setState(() {
        s
          ..step = 2
          ..busy = false
          ..toolkit = _Tool.hand;
      });
      _scheduleFraming();
    });
  }

  /// S1 step 4: click, the camera glides to the crow (0.8 s); 0.5 s after
  /// the tap it takes off ('magic'), flies up and lands again (2 s); then
  /// step 5 and Table 2.2.
  void _openCrow() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..crowTapped = true
        ..busy = true
        ..glideTo(_Shot.crow, _crowZoomSeconds);
    });
    _after(_flightDelayMs, () {
      _Sound.magic.play();
      s.flightStart = s.time;
      _after(((_flightUp + _flightDown) * 1000).round(), () {
        setState(() {
          s
            ..flightStart = null
            ..step = 5
            ..busy = false;
        });
        _showTable(_Table.animals, const [_Item.legs, _Item.wings]);
      });
    });
  }

  /// S2 step 1: click, the camera glides to the Sadabahar; step 2 offers
  /// the Magnifying Glass.
  void _openSada() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..sadaTapped = true
        ..busy = true
        ..glideTo(_Shot.sada, _zoomSeconds);
    });
    _after(_toolkitMs, () {
      setState(() {
        s
          ..step = 2
          ..busy = false
          ..toolkit = _Tool.magnifier;
      });
      _scheduleFraming();
    });
  }

  /// S2 step 6: click, the camera glides to the Lemongrass; the Magnifying
  /// Glass is offered again with the step-2 task (the HTML meant to toast
  /// its step-2 line here, but the call failed).
  void _openLemon() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..lemonTapped = true
        ..busy = true
        ..glideTo(_Shot.lemon, _zoomSeconds);
    });
    _after(_toolkitMs, () {
      setState(() {
        s
          ..busy = false
          ..toolkit = _Tool.magnifier;
      });
      _toast('s2_lemon_mag');
      _scheduleFraming();
    });
  }

  /// HTML `setupDropzones(zones, iconIds)`: the notebook shows [table] and
  /// the tray holds [items].
  void _showTable(_Table table, List<_Item> items) {
    setState(() {
      _scene
        ..table = table
        ..notebookShown = true
        ..tray.clear()
        ..tray.addAll(items);
    });
    _scheduleFraming();
  }

  // ----------------------------------------------------------------- tools

  /// The toolkit's tool can be picked up (HTML `.draggable-tool`).
  bool _toolEnabled(_Tool tool) =>
      _lab.isLabActive && !_scene.busy && _scene.toolkit == tool;

  /// HTML `handleDragMove`: while a tool moves over the scene, its target
  /// is raycast in real time; a hit plays the step's reveal at once.
  /// Returns whether it did.
  bool _tryTool(_Tool tool, Offset p) {
    final s = _scene;
    if (s.toolkit != tool || s.busy) return false;
    switch (tool) {
      case _Tool.hand:
        if (s.scenario != 0 || s.step != 2 || s.stemTouched) return false;
        final at = s.stemAt(p, _touch);
        if (at == null) return false;
        _touchStem(at);
        return true;
      case _Tool.magnifier:
        if (s.scenario != 1) return false;
        if (s.step == 2 && !s.sadaLeafScanned) {
          if (!s.overLeaf(_Models.sadaLeaf, p, _touch)) return false;
          _scanSadaLeaf();
          return true;
        }
        if (s.step == 6 && s.lemonTapped && !s.lemonLeafScanned) {
          if (!s.overLeaf(_Models.lemonLeaf, p, _touch)) return false;
          _scanLemonLeaf();
          return true;
        }
        return false;
      case _Tool.xray:
        if (s.scenario != 1) return false;
        if (s.step == 4 && !s.sadaRootScanned) {
          if (!s.overBase(_sadaPos, p)) return false;
          _scanSadaRoots();
          return true;
        }
        if (s.step == 6 && s.lemonLeafScanned && !s.lemonRootScanned) {
          if (!s.overBase(_lemonPos, p)) return false;
          _scanLemonRoots();
          return true;
        }
        return false;
    }
  }

  void _onToolMove(_Tool tool, Offset global) {
    final p = labGlobalToLocal(_designKey, global);
    if (p != null) _tryTool(tool, p);
  }

  /// The tool let go over the scene: a last test at the drop point.
  void _onToolDrop(_Tool tool, Offset global) {
    if (_scene.toolkit != tool) return;
    final p = labGlobalToLocal(_designKey, global);
    if (p != null && _tryTool(tool, p)) return;
    _toolMissed(tool);
  }

  /// The tool goes back to the toolkit without having found its target
  /// (the HTML put it back silently); a hint says where it goes.
  void _toolMissed(_Tool tool) {
    final s = _scene;
    if (s.toolkit != tool) return;
    final key = switch (tool) {
      _Tool.hand => 'miss_hand',
      _Tool.magnifier => s.step == 6 ? 'miss_mag_lemon' : 'miss_mag_sada',
      _Tool.xray => s.step == 6 ? 'miss_xray_lemon' : 'miss_xray_sada',
    };
    _toast(key, error: true, sound: true);
  }

  /// S1 step 2: 'magic', the toolkit hides and a 'Hard' tag floats above
  /// the touched point of the stem for 1.5 s; then step 3 and Table 2.1.
  void _touchStem(_V at) {
    final s = _scene;
    _Sound.magic.play();
    setState(() {
      s
        ..stemTouched = true
        ..toolkit = null
        ..busy = true
        ..hardAt = at + const _V(0, _hardLift, 0);
    });
    _scheduleFraming();
    _after(_revealMs, () {
      setState(() {
        s
          ..hardAt = null
          ..step = 3
          ..busy = false;
      });
      _showTable(_Table.plants, const [_Item.hardStem]);
    });
  }

  /// S2 step 2: the Sadabahar leaf's net of veins glows amber; then step 3
  /// and Table 2.4 with the 'Reticulate Venation' icon.
  void _scanSadaLeaf() {
    final s = _scene;
    _Sound.magic.play();
    setState(() {
      s
        ..sadaLeafScanned = true
        ..sadaGlowAt = s.time
        ..toolkit = null
        ..busy = true;
    });
    _scheduleFraming();
    _after(_revealMs, () {
      setState(() {
        s
          ..step = 3
          ..busy = false;
      });
      _showTable(_Table.roots, const [_Item.reticulate]);
    });
  }

  /// S2 step 4: the x-ray circle lies at the Sadabahar's base and its
  /// glowing taproot shows; then step 5 with the 'Taproot' icon.
  void _scanSadaRoots() {
    final s = _scene;
    _Sound.magic.play();
    setState(() {
      s
        ..sadaRootScanned = true
        ..sadaRootsAt = s.time
        ..xrayAt = _sadaPos
        ..toolkit = null
        ..busy = true;
    });
    _scheduleFraming();
    _after(_revealMs, () {
      setState(() {
        s
          ..step = 5
          ..busy = false;
      });
      _showTable(_Table.roots, const [_Item.taproot]);
    });
  }

  /// S2 step 6: the Lemongrass leaf's parallel veins glow; the X-Ray
  /// Scanner is offered next (the HTML meant to toast its step-4 line).
  void _scanLemonLeaf() {
    final s = _scene;
    _Sound.magic.play();
    setState(() {
      s
        ..lemonLeafScanned = true
        ..lemonGlowAt = s.time
        ..toolkit = null
        ..busy = true;
    });
    _scheduleFraming();
    _after(_revealMs, () {
      setState(() {
        s
          ..busy = false
          ..toolkit = _Tool.xray;
      });
      _toast('s2_lemon_xray');
      _scheduleFraming();
    });
  }

  /// S2 step 6: the x-ray circle moves to the Lemongrass and its fibrous
  /// roots show; the tray then holds both of its icons.
  void _scanLemonRoots() {
    final s = _scene;
    _Sound.magic.play();
    setState(() {
      s
        ..lemonRootScanned = true
        ..lemonRootsAt = s.time
        ..xrayAt = _lemonPos
        ..toolkit = null
        ..busy = true;
    });
    _scheduleFraming();
    _after(_revealMs, () {
      setState(() => s.busy = false);
      _showTable(_Table.roots, const [_Item.parallel, _Item.fibrous]);
      _toast('s2_lemon_record');
    });
  }

  // ----------------------------------------------------------------- icons

  /// HTML `handleDragEnd` over a cell: the right icon locks into it
  /// ('snap', green cell); a wrong one goes back to the tray (with a hint,
  /// added). After a step's last icon the step ends 0.8 s later.
  void _onItemDrop(_Item item, _Item cell) {
    final s = _scene;
    if (s.placed.contains(cell)) return;
    if (item != cell) {
      _toast('wrong_cell', error: true, sound: true, args: {'item': item});
      return;
    }
    _Sound.snap.play();
    setState(() {
      s
        ..placed.add(item)
        ..tray.remove(item);
      _draggingItem = null;
    });
    _scheduleFraming();
    if (s.tray.isEmpty) {
      s.busy = true;
      _after(_recordMs, _recorded);
    }
  }

  /// An icon let go away from the table goes back to the tray (silently in
  /// the HTML; with a hint here).
  void _onItemMissed(_Item item) {
    if (!_scene.tray.contains(item)) return;
    _toast('miss_item', error: true, sound: true, args: {'item': item});
  }

  /// HTML `checkStepCompletion()`.
  void _recorded() {
    final s = _scene;
    if (s.scenario == 0 && s.step == 3) {
      // The notebook fades out; step 4 in the start view.
      setState(() => s.notebookShown = false);
      _after(_fadeMs, () {
        setState(() {
          s
            ..table = null
            ..step = 4
            ..busy = false
            ..glideHome();
        });
        _scheduleFraming();
      });
      return;
    }
    if (s.scenario == 0 && s.step == 5) {
      // HTML `triggerConclusionState()`: the button and a chime.
      setState(() {
        s
          ..step = 6
          ..busy = false
          ..conclusionReady = true;
      });
      _Sound.success.play();
    } else if (s.scenario == 1 && s.step == 3) {
      setState(() {
        s
          ..step = 4
          ..busy = false
          ..toolkit = _Tool.xray;
      });
    } else if (s.scenario == 1 && s.step == 5) {
      setState(() {
        s
          ..step = 6
          ..busy = false
          ..glideHome();
      });
    } else if (s.scenario == 1 && s.step == 6) {
      // HTML `drawConnectionLines()`: lines and the pattern message after
      // 0.5 s ('success'), 'Complete Observation' 2 s later (chime).
      setState(() {
        s
          ..step = 7
          ..busy = false;
      });
      _after(_linesMs, () {
        setState(() => s.linesShown = true);
        _Sound.success.play();
        _after(_conclusionMs, () {
          setState(() => s.conclusionReady = true);
          _Sound.success.play();
        });
      });
    }
    _scheduleFraming();
  }

  // --------------------------------------------------------------- summary

  /// HTML `triggerConclusion()`: 'success', the summary popup and
  /// confetti. The button hides once tapped.
  void _conclude() {
    final s = _scene;
    if (!s.conclusionReady || s.concluded) return;
    setState(() {
      s
        ..concluded = true
        ..confettiAt = s.time;
    });
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _lab.t('success'),
      heading: () => _t('sum_heading'),
      body: () => _t('s${sc + 1}_sum'),
      extra: () => Builder(
        builder: (context) => _SummaryVisual(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale,
          t: _t,
        ),
      ),
    );
    _scheduleFraming();
  }

  /// HTML `#compare-btn-container`: 'Complete Observation'.
  List<LabAction> _actions() {
    final s = _scene;
    if (!s.conclusionReady || s.concluded) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.check_circle,
        color: _Colors.emerald600,
        foreground: _Colors.white,
        highlight: true,
        // The summary plays the HTML `success`.
        silent: true,
        onTap: _conclude,
      ),
    ];
  }

  /// The Lemongrass part of Scenario 2's step 6, one task at a time (the
  /// HTML kept "Repeat steps 1-5" and meant to toast the tasks).
  String? get _subTaskKey {
    final s = _scene;
    if (s.scenario != 1 || s.step != 6 || !s.lemonTapped) return null;
    if (s.toolkit == _Tool.magnifier) return 's2_lemon_mag';
    if (s.toolkit == _Tool.xray) return 's2_lemon_xray';
    if (s.lemonRootScanned && s.tray.isNotEmpty) return 's2_lemon_record';
    return null;
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
        final sc = _scene;
        final n = sc.scenario;
        final actions = _actions();
        final sub = _subTaskKey;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: n,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _currentStep,
          instruction: sub == null ? null : _t(sub),
          hud: _t(sub ?? 's${n + 1}_hud_${sc.step.clamp(1, _stepCounts[n])}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('steps_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$n-$_currentStep'),
            steps: _stepData,
            current: _currentStep,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('step_word'),
            focusLabel: _t('focus_lbl'),
            actionLabel: _t('action_lbl'),
            resultLabel: _t('result_lbl'),
            pendingText: _t('pending'),
          ),
          overlays: _overlays(context, p, s, actions),
          stage: _stage(),
        );
      },
    );
  }

  /// The canvas cards: the notebook (HTML `#notebook-container`, top left),
  /// the toolkit (HTML `#toolkit-panel`, top right) and, while the sidebar
  /// is open, 'Complete Observation' above the HUD (HTML
  /// `#compare-btn-container`).
  List<Widget> _overlays(
    BuildContext context,
    LabPalette p,
    double s,
    List<LabAction> actions,
  ) {
    final sc = _scene;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final active = _lab.isLabActive;
    final table = sc.table;
    final tool = sc.toolkit;
    return [
      // Measures the canvas area for the framing.
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      if (active && table != null)
        Positioned(
          key: const ValueKey('ch2a1-notebook'),
          top: inset.top,
          left: inset.left,
          child: _notebook(table, p, s),
        ),
      if (active && tool != null)
        Positioned(
          key: const ValueKey('ch2a1-toolkit'),
          top: _cardTop + pad.top,
          right: inset.right,
          child: _toolkitCard(tool, p, s),
        ),
      if (active && _lab.isSidebarOpen && actions.isNotEmpty)
        Positioned(
          key: const ValueKey('ch2a1-bottom'),
          left: inset.left,
          right: inset.right,
          bottom: inset.bottom + _hudBand * s,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LabActionButton(
                key: _bottomKey,
                action: actions.first,
                scale: s,
                expand: false,
              ),
            ),
          ),
        ),
    ];
  }

  /// HTML `#toolkit-panel`: the 'Toolkit' pill over the one tool of the
  /// step, which is dragged onto the scene (its name is added below).
  Widget _toolkitCard(_Tool tool, LabPalette p, double s) {
    final name = _t(tool.key);
    final title = _t('toolkit');
    final size = math.max(56.0, 56 * s);
    Widget tile({bool ghost = false, bool lifted = false}) =>
        _ToolTile(tool: tool, size: size, ghost: ghost, lifted: lifted);
    return Container(
      key: _toolkitKey,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: _Colors.emerald800.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Colors.emerald700, width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
            decoration: BoxDecoration(
              color: _Colors.emerald950,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _Colors.emerald600),
            ),
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                color: _Colors.emerald300,
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: labLetterSpacing(title, 1.5),
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Draggable<_Tool>(
            data: tool,
            maxSimultaneousDrags: _toolEnabled(tool) ? 1 : 0,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDraggableCanceled: (_, _) => _toolMissed(tool),
            // Centred on the finger.
            feedback: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: Material(
                type: MaterialType.transparency,
                child: tile(lifted: true),
              ),
            ),
            childWhenDragging: tile(ghost: true),
            child: Semantics(
              label: name,
              child: KeyedSubtree(
                key: ValueKey('ch2a1-tool-${tool.name}'),
                child: tile(),
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 96 * s),
            child: Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Colors.emerald100,
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The scenario's last table is filled in (S1 step 6, S2 step 7).
  bool get _tableComplete =>
      _scene.tray.isEmpty && _scene.step >= _stepCounts[_scene.scenario];

  /// HTML `#notebook-container`: a spiral-bound page with the table of the
  /// step and the items tray; it fades in and out (300 ms).
  Widget _notebook(_Table table, LabPalette p, double s) {
    final sc = _scene;
    final dark = p.isDark;
    final width = (_notebookWidth * s).clamp(230.0, 380.0);
    final title = _t(table.titleKey);
    final trayLabel = _t('items_tray');
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: sc.notebookShown ? 1 : 0),
      duration: const Duration(milliseconds: _fadeMs),
      builder: (context, v, child) => Opacity(opacity: v, child: child),
      child: Container(
        key: _notebookKey,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? _Colors.slate800 : _Colors.paper,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(16),
          ),
          border: Border.all(color: _Colors.emerald800, width: 4),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowStrong,
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 22 * s,
              child: _Spiral(dark: dark, scale: s),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30 * s, 8 * s, 8 * s, 8 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4 * s),
                    decoration: const BoxDecoration(
                      color: _Colors.emerald600,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      _t(table.notebookKey),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 5 * s),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark ? _Colors.emerald400 : _Colors.emerald800,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 5 * s),
                  _tableGrid(table, p, s),
                  if (table == _Table.roots && sc.linesShown) ...[
                    SizedBox(height: 6 * s),
                    _PulseNote(
                      text: _t('pattern_revealed'),
                      dark: dark,
                      scale: s,
                    ),
                  ],
                  // Once the table is complete the empty tray is left out,
                  // so the notebook stays clear of 'Complete Observation'.
                  if (!_tableComplete) ...[
                    SizedBox(height: 8 * s),
                    Padding(
                      padding: EdgeInsets.only(left: 2 * s, bottom: 3 * s),
                      child: Text(
                        trayLabel.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: _Colors.slate500,
                          fontSize: 9 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: labLetterSpacing(trayLabel, 0.8),
                        ),
                      ),
                    ),
                    _tray(p, s),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HTML `.notebook-table`: a header row and the rows of plants or the
  /// crow, each with its drop cells.
  Widget _tableGrid(_Table table, LabPalette p, double s) {
    final dark = p.isDark;
    final head = dark ? _Colors.emerald900 : _Colors.emerald100;
    final body = dark ? _Colors.slate700 : _Colors.white;
    final ink = dark ? _Colors.white : _Colors.slate800;
    final rowH = math.max(46.0, (table == _Table.roots ? 50 : 56) * s);
    const line = BorderSide(color: _Colors.gridLine);

    Widget headCell(String key, int flex, {bool last = false}) => Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          border: Border(right: last ? BorderSide.none : line),
        ),
        alignment: Alignment.center,
        child: Text(
          _t(key),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ink,
            fontSize: 10.5 * s,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ),
    );

    Widget nameCell(String key, Color light, Color darkInk, int flex) =>
        Expanded(
          flex: flex,
          child: Container(
            height: rowH,
            padding: EdgeInsets.symmetric(horizontal: 3 * s),
            decoration: const BoxDecoration(border: Border(right: line)),
            alignment: Alignment.center,
            child: Text(
              _t(key),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dark ? darkInk : light,
                fontSize: 11 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

    Widget cell(_Item item, int flex, {bool last = false}) => Expanded(
      flex: flex,
      child: Container(
        height: rowH,
        decoration: BoxDecoration(
          border: Border(right: last ? BorderSide.none : line),
        ),
        child: _dropCell(item, ink, s),
      ),
    );

    Widget row(List<Widget> cells, {bool first = false, bool link = false}) {
      final r = Container(
        decoration: BoxDecoration(
          color: body,
          border: Border(top: first ? BorderSide.none : line),
        ),
        child: Row(children: cells),
      );
      if (!link) return r;
      // Table 2.4: a glowing line from the venation icon to the root icon
      // once the table is complete (HTML `#connection-lines`).
      return Stack(
        children: [
          r,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _scene.linesShown ? 1 : 0,
                duration: const Duration(milliseconds: 1000),
                child: const CustomPaint(painter: _LinkPainter()),
              ),
            ),
          ),
        ],
      );
    }

    final List<Widget> rows;
    switch (table) {
      case _Table.plants:
        rows = [
          Container(
            color: head,
            child: Row(
              children: [
                headCell('plant_name', 1),
                headCell('stem_type', 1, last: true),
              ],
            ),
          ),
          row([
            nameCell(
              'name_hibiscus',
              _Colors.emerald700,
              _Colors.emerald300,
              1,
            ),
            cell(_Item.hardStem, 1, last: true),
          ]),
        ];
      case _Table.animals:
        rows = [
          Container(
            color: head,
            child: Row(
              children: [
                headCell('animal_name', 1),
                headCell('movement', 2, last: true),
              ],
            ),
          ),
          row([
            nameCell('name_crow', _Colors.slate700, _Colors.slate200, 1),
            cell(_Item.legs, 1),
            cell(_Item.wings, 1, last: true),
          ]),
        ];
      case _Table.roots:
        rows = [
          Container(
            color: head,
            child: Row(
              children: [
                headCell('plant_name', _nameFlex),
                headCell('venation', _cellFlex),
                headCell('root_type', _cellFlex, last: true),
              ],
            ),
          ),
          row([
            nameCell(
              'name_sada',
              _Colors.indigo600,
              _Colors.indigo400,
              _nameFlex,
            ),
            cell(_Item.reticulate, _cellFlex),
            cell(_Item.taproot, _cellFlex, last: true),
          ], link: true),
          row([
            nameCell('name_lemon', _Colors.teal600, _Colors.teal400, _nameFlex),
            cell(_Item.parallel, _cellFlex),
            cell(_Item.fibrous, _cellFlex, last: true),
          ], link: true),
        ];
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: body,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border.all(color: dark ? _Colors.slate600 : _Colors.slate300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  /// HTML `.dropzone`: dashed while empty, indigo while its icon is being
  /// dragged (HTML `.highlight`), green with the icon once filled.
  Widget _dropCell(_Item item, Color ink, double s) {
    final sc = _scene;
    final filled = sc.placed.contains(item);
    return DragTarget<_Item>(
      onWillAcceptWithDetails: (_) =>
          !filled && !sc.concluded && _lab.isLabActive,
      onAcceptWithDetails: (d) => _onItemDrop(d.data, item),
      builder: (context, candidates, _) {
        final wanted = !filled && _draggingItem == item;
        final hover = candidates.isNotEmpty;
        final Color? fill;
        final Color border;
        if (filled) {
          fill = _Colors.cellFilled;
          border = _Colors.emerald500;
        } else if (wanted) {
          fill = hover
              ? _Colors.indigo500.withValues(alpha: 0.32)
              : _Colors.cellHover;
          border = _Colors.indigo500;
        } else {
          fill = null;
          border = hover ? _Colors.slate400 : _Colors.cellDash;
        }
        return Padding(
          key: ValueKey('ch2a1-cell-${item.name}'),
          padding: EdgeInsets.all(3 * s),
          child: CustomPaint(
            painter: _DashPainter(
              color: border,
              fill: fill,
              dashed: !filled && !wanted,
              radius: 6,
            ),
            child: filled
                ? Padding(
                    padding: EdgeInsets.all(4 * s),
                    child: Semantics(
                      label: _t(item.key),
                      child: CustomPaint(
                        painter: _ItemPainter(item, ink),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        );
      },
    );
  }

  /// HTML `#icon-tray`: the step's icons, dragged into the table.
  Widget _tray(LabPalette p, double s) {
    final sc = _scene;
    final dark = p.isDark;
    return CustomPaint(
      painter: _DashPainter(
        color: dark ? _Colors.slate700 : _Colors.slate300,
        fill: dark ? _Colors.slate900 : _Colors.slate200,
        dashed: true,
        radius: 12,
        width: 2,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 60 * s),
        child: Padding(
          padding: EdgeInsets.all(6 * s),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8 * s,
              runSpacing: 4 * s,
              children: [
                for (final item in sc.tray) _itemDraggable(item, p, s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One icon of the tray (HTML `.draggable-item`), with its name (added).
  Widget _itemDraggable(_Item item, LabPalette p, double s) {
    final name = _t(item.key);
    final ink = p.isDark ? _Colors.slate200 : _Colors.slate800;
    Widget tile({bool ghost = false, bool lifted = false}) => _ItemTile(
      item: item,
      label: name,
      ink: ink,
      dark: p.isDark,
      scale: s,
      ghost: ghost,
      lifted: lifted,
    );
    return Draggable<_Item>(
      data: item,
      maxSimultaneousDrags: _lab.isLabActive && !_scene.concluded ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => setState(() => _draggingItem = item),
      onDragEnd: (_) {
        if (mounted) setState(() => _draggingItem = null);
      },
      onDraggableCanceled: (_, _) => _onItemMissed(item),
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: tile(lifted: true),
        ),
      ),
      childWhenDragging: tile(ghost: true),
      child: Semantics(
        label: name,
        child: KeyedSubtree(
          key: ValueKey('ch2a1-item-${item.name}'),
          child: tile(),
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
            onWillAcceptWithDetails: (d) => _scene.toolkit == d.data,
            onMove: (d) => _onToolMove(d.data, d.offset),
            onAcceptWithDetails: (d) => _onToolDrop(d.data, d.offset),
            builder: (context, _, _) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _onSceneTap,
              child: Stack(
                children: [
                  Semantics(
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
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelSize: _labelSize,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _frame,
                      builder: (context, _, _) => _targets(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Screen-reader boxes over what the step needs: the plant or crow to
  /// tap (with a tap action) or where the toolkit's tool goes. They follow
  /// the camera every frame and take no touches themselves.
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.concluded) {
      return const SizedBox.shrink();
    }
    final things = <_Thing>[
      if (s.scenario == 0 && s.step == 1 && !s.hibiscusTapped) _Thing.hibiscus,
      if (s.scenario == 0 && s.step == 4 && !s.crowTapped) _Thing.crow,
      if (s.scenario == 1 && s.step == 1 && !s.sadaTapped) _Thing.sada,
      if (s.scenario == 1 && s.step == 6 && !s.lemonTapped) _Thing.lemon,
    ];
    final spot = switch (s.toolkit) {
      _Tool.hand => _Spot.stem,
      _Tool.magnifier => s.step == 6 ? _Spot.lemonLeaf : _Spot.sadaLeaf,
      _Tool.xray => s.step == 6 ? _Spot.lemonBase : _Spot.sadaBase,
      null => null,
    };
    final spotRect = spot == null ? null : s.spotRect(spot);
    return Stack(
      children: [
        for (final thing in things)
          if (s.things.contains(thing))
            Positioned.fromRect(
              rect: s.rectOf(thing),
              child: Semantics(
                key: ValueKey('ch2a1-target-${thing.name}'),
                label: _t(thing.key),
                button: true,
                onTap: () => _tapThing(thing),
                child: const SizedBox.expand(),
              ),
            ),
        if (spot != null && spotRect != null)
          Positioned.fromRect(
            rect: spotRect,
            child: Semantics(
              key: ValueKey('ch2a1-spot-${spot.name}'),
              label: _t(spot.key),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

/// Flexes of Table 2.4's columns (plant, venation, root type).
const int _nameFlex = 5;
const int _cellFlex = 4;

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed. A step's result
/// shows once the step is done (the HTML showed it before the learner had
/// seen it).
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// What the summary popup adds under the HTML summary: the filled-in
/// notebook (S1: Hibiscus → hard stem, Crow → legs and wings; S2: the two
/// venation → root pairs of the pattern) and, after Scenario 1, the HTML
/// `#next-sc-msg` note.
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
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final rows = scenario == 0
        ? [
            _row(
              left: _name(t('name_hibiscus'), _Colors.emerald500),
              right: _badges(const [_Item.hardStem], t('item_hard_stem')),
            ),
            _row(
              left: _name(t('name_crow'), p.textStrong),
              right: _badges(const [
                _Item.legs,
                _Item.wings,
              ], '${t('item_legs')} + ${t('item_wings')}'),
            ),
          ]
        : [
            _row(
              left: _badges(const [_Item.reticulate], t('item_reticulate')),
              right: _badges(const [_Item.taproot], t('item_taproot')),
            ),
            _row(
              left: _badges(const [_Item.parallel], t('item_parallel')),
              right: _badges(const [_Item.fibrous], t('item_fibrous')),
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: 6 * s),
          rows[i],
        ],
        if (scenario == 0) ...[
          SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.amber400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.amber400.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              t('next_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.amber400),
                fontSize: 12 * s,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row({required Widget left, required Widget right}) {
    final p = palette;
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(child: left),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * s),
            child: Icon(
              Icons.arrow_forward,
              size: 18 * s,
              color: p.ink(_Colors.amber400),
            ),
          ),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _name(String text, Color color) => Text(
    text,
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: palette.ink(color),
      fontSize: 13 * scale,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _badges(List<_Item> items, String caption) {
    final s = scale;
    final size = 34 * s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(width: 4 * s),
              Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(size * 0.1),
                decoration: BoxDecoration(
                  color: _Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.22),
                  border: Border.all(color: _Colors.emerald500, width: 2),
                ),
                child: CustomPaint(
                  painter: _ItemPainter(items[i], _Colors.slate800),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 3 * s),
        Text(
          caption,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: 10.5 * s,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// The notebook's spiral binding (HTML: a slate strip with eight rings).
class _Spiral extends StatelessWidget {
  const _Spiral({required this.dark, required this.scale});

  final bool dark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? _Colors.slate900 : _Colors.slate200,
        border: const Border(
          right: BorderSide(color: _Colors.emerald800, width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < 8; i++)
            Transform.translate(
              offset: Offset(-4 * s, 0),
              child: Container(
                width: 20 * s,
                height: 9 * s,
                decoration: BoxDecoration(
                  color: _Colors.slate100,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _Colors.slate500,
                    width: math.max(1.5, 2.5 * s),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#pattern-msg`: the amber "Pattern Revealed!" note, pulsing
/// (Tailwind `animate-pulse`).
class _PulseNote extends StatefulWidget {
  const _PulseNote({
    required this.text,
    required this.dark,
    required this.scale,
  });

  final String text;
  final bool dark;
  final double scale;

  @override
  State<_PulseNote> createState() => _PulseNoteState();
}

class _PulseNoteState extends State<_PulseNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final dark = widget.dark;
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: EdgeInsets.all(7 * s),
        decoration: BoxDecoration(
          color: dark ? _Colors.amberNote : _Colors.amber100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: dark ? _Colors.amber700 : _Colors.amber300),
          boxShadow: const [BoxShadow(color: LabInk.shadowSoft, blurRadius: 4)],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? _Colors.amber400 : _Colors.amber600,
            fontSize: 10.5 * s,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// A toolkit tool (HTML `.draggable-tool`: white card, slate border; the
/// held one grows by 10 %). [ghost]: left behind while dragged.
class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.tool,
    required this.size,
    this.ghost = false,
    this.lifted = false,
  });

  final _Tool tool;
  final double size;
  final bool ghost;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    // The HTML hand icon was a white shape on the white card; an indigo
    // hand is drawn instead.
    final Widget art = tool == _Tool.hand
        ? FittedBox(child: Icon(Icons.back_hand, color: _Colors.indigo500))
        : CustomPaint(
            painter: _ToolPainter(tool),
            child: const SizedBox.expand(),
          );
    return Opacity(
      opacity: ghost ? 0.35 : 1,
      child: Transform.scale(
        scale: lifted ? 1.1 : 1,
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.17),
          decoration: BoxDecoration(
            color: _Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: lifted ? _Colors.emerald500 : _Colors.slate300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: lifted ? LabInk.shadowStrong : LabInk.shadowSoft,
                blurRadius: lifted ? 16 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: art,
        ),
      ),
    );
  }
}

/// A tray icon (HTML `.draggable-item`) with its name below (added). The
/// held icon (the drag feedback) sits on a card and grows by 10 %.
class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.label,
    required this.ink,
    required this.dark,
    required this.scale,
    this.ghost = false,
    this.lifted = false,
  });

  final _Item item;
  final String label;

  /// `currentColor` of the stroke icons (the legs).
  final Color ink;
  final bool dark;
  final double scale;
  final bool ghost;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final box = math.max(44.0, 46 * s);
    final icon = Container(
      width: box,
      height: box,
      padding: EdgeInsets.all(4 * s),
      decoration: lifted
          ? BoxDecoration(
              color: dark ? _Colors.slate800 : _Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _Colors.emerald500, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: LabInk.shadowStrong,
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : null,
      child: CustomPaint(
        painter: _ItemPainter(item, ink),
        child: const SizedBox.expand(),
      ),
    );
    if (lifted) return Transform.scale(scale: 1.1, child: icon);
    return Opacity(
      opacity: ghost ? 0.35 : 1,
      child: SizedBox(
        width: math.max(60.0, 68 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 2 * s),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ink,
                fontSize: 9 * s,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded box, filled with [fill], with a dashed (HTML `border-dashed`)
/// or solid [color] border.
class _DashPainter extends CustomPainter {
  const _DashPainter({
    required this.color,
    this.fill,
    this.dashed = true,
    this.radius = 6,
    this.width = 2,
  });

  final Color color;
  final Color? fill;
  final bool dashed;
  final double radius;
  final double width;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    final f = fill;
    if (f != null) canvas.drawRRect(rr, Paint()..color = f);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    if (!dashed) {
      canvas.drawRRect(rr, pen);
      return;
    }
    for (final metric in (Path()..addRRect(rr)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), pen);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.dashed != dashed ||
      old.radius != radius ||
      old.width != width;
}

/// HTML `#connection-lines`: a glowing amber line across a row of Table
/// 2.4, from the venation icon to the root icon.
class _LinkPainter extends CustomPainter {
  const _LinkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const total = _nameFlex + 2 * _cellFlex;
    final reach = size.height * 0.3;
    final x0 = size.width * (_nameFlex + _cellFlex / 2) / total + reach;
    final x1 = size.width * (_nameFlex + _cellFlex * 1.5) / total - reach;
    final y = size.height / 2;
    canvas.drawLine(
      Offset(x0, y),
      Offset(x1, y),
      Paint()
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = _Colors.amber400.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(
      Offset(x0, y),
      Offset(x1, y),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = _Colors.amber400,
    );
  }

  @override
  bool shouldRepaint(covariant _LinkPainter old) => false;
}

/// A notebook icon for widgets (tray, cells, summary).
class _ItemPainter extends CustomPainter {
  const _ItemPainter(this.item, this.ink);

  final _Item item;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) =>
      _IconArt.drawItem(canvas, item, Offset.zero & size, ink);

  @override
  bool shouldRepaint(covariant _ItemPainter old) =>
      old.item != item || old.ink != ink;
}

/// The magnifying glass or the x-ray scanner for the toolkit.
class _ToolPainter extends CustomPainter {
  const _ToolPainter(this.tool);

  final _Tool tool;

  @override
  void paint(Canvas canvas, Size size) =>
      _IconArt.drawTool(canvas, tool, Offset.zero & size);

  @override
  bool shouldRepaint(covariant _ToolPainter old) => old.tool != tool;
}

/// The HTML `Icons` SVGs and tool SVGs, redrawn as paths in their 24 x 24
/// view box (made once).
abstract final class _IconArt {
  static final Paint _fill = Paint();
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  static Path _lines(List<(double, double, double, double)> segments) {
    final path = Path();
    for (final (x0, y0, x1, y1) in segments) {
      path
        ..moveTo(x0, y0)
        ..lineTo(x1, y1);
    }
    return path;
  }

  /// `icon-hard-stem`: a 32 x 40 amber-800 bar with an amber-900 border.
  static final RRect _stemBar = RRect.fromLTRBR(
    4.8,
    3,
    19.2,
    21,
    const Radius.circular(0.7),
  );

  /// `icon-legs`: two legs with feet and the hips.
  static final Path _legs =
      _lines(const [
          (9, 20, 9, 12),
          (15, 20, 15, 12),
          (7, 20, 11, 20),
          (13, 20, 17, 20),
        ])
        ..moveTo(12, 12)
        ..cubicTo(12, 10, 10, 8, 10, 8)
        ..moveTo(12, 12)
        ..cubicTo(12, 10, 14, 8, 14, 8);

  /// `icon-wings`: an indigo disc with a white wing arc.
  static final Path _wing = Path()
    ..moveTo(12, 5)
    ..cubicTo(15.866, 5, 19, 8.134, 19, 12)
    ..lineTo(14, 12)
    ..cubicTo(14, 9.791, 12.209, 8, 10, 8)
    ..cubicTo(8.343, 8, 7, 9.343, 7, 11)
    ..lineTo(7, 12)
    ..lineTo(5, 12)
    ..cubicTo(5, 8.134, 8.134, 5, 12, 5)
    ..close();

  /// `icon-reticulate` / `icon-parallel`: the leaf and its veins.
  static final Path _leaf = Path()
    ..moveTo(12, 22)
    ..cubicTo(12, 22, 4, 16, 4, 10)
    ..cubicTo(4, 5.5, 8, 2, 12, 2)
    ..cubicTo(16, 2, 20, 5.5, 20, 10)
    ..cubicTo(20, 16, 12, 22, 12, 22)
    ..close();
  static final Path _netVeins = _lines(const [
    (12, 2, 12, 22),
    (12, 8, 8, 5),
    (12, 12, 7, 10),
    (12, 16, 9, 15),
    (12, 7, 17, 5),
    (12, 11, 16, 9.5),
    (12, 15, 15, 14),
    (8, 10, 6, 12),
    (15, 11, 17, 13),
  ]);
  static final Path _parallelVeins = _lines(const [
    (12, 2, 12, 22),
    (10, 3.5, 10, 19.5),
    (14, 3.5, 14, 19.5),
    (8, 6, 8, 16),
    (16, 6, 16, 16),
  ]);

  /// `icon-taproot` / `icon-fibrous`.
  static final Path _taproot = _lines(const [
    (12, 2, 12, 22),
    (12, 6, 9, 8),
    (12, 10, 15, 13),
    (12, 14, 10, 16),
    (12, 18, 13.5, 19.5),
    (9, 8, 8, 7),
    (15, 13, 17, 12),
  ]);
  static final Path _fibrous = Path()
    ..moveTo(12, 2)
    ..lineTo(12, 6)
    ..moveTo(12, 6)
    ..cubicTo(9, 9, 7, 14, 7, 20)
    ..moveTo(12, 6)
    ..cubicTo(15, 9, 17, 14, 17, 20)
    ..moveTo(12, 6)
    ..cubicTo(11, 10, 10, 15, 10, 21)
    ..moveTo(12, 6)
    ..cubicTo(13, 10, 14, 15, 14, 21)
    ..moveTo(12, 6)
    ..cubicTo(7.5, 8, 5, 12, 5, 18)
    ..moveTo(12, 6)
    ..cubicTo(16.5, 8, 19, 12, 19, 18);

  /// Phosphor `ph-scan` (duotone): four corner brackets round a pale
  /// square.
  static final Path _scanCorners = Path()
    ..moveTo(3.5, 8)
    ..lineTo(3.5, 3.5)
    ..lineTo(8, 3.5)
    ..moveTo(16, 3.5)
    ..lineTo(20.5, 3.5)
    ..lineTo(20.5, 8)
    ..moveTo(20.5, 16)
    ..lineTo(20.5, 20.5)
    ..lineTo(16, 20.5)
    ..moveTo(8, 20.5)
    ..lineTo(3.5, 20.5)
    ..lineTo(3.5, 16);
  static final RRect _scanSquare = RRect.fromLTRBR(
    7.5,
    7.5,
    16.5,
    16.5,
    const Radius.circular(1),
  );

  static void _begin(Canvas canvas, Rect box) {
    canvas
      ..save()
      ..translate(box.left, box.top)
      ..scale(box.width / 24, box.height / 24);
  }

  static void _line(Canvas canvas, Path path, Color color, double width) =>
      canvas.drawPath(
        path,
        _stroke
          ..strokeWidth = width
          ..color = color,
      );

  /// Draws [item] into [box]; [ink] is the stroke icons' `currentColor`.
  static void drawItem(Canvas canvas, _Item item, Rect box, Color ink) {
    _begin(canvas, box);
    switch (item) {
      case _Item.hardStem:
        canvas.drawRRect(
          _stemBar,
          _fill
            ..shader = ui.Gradient.linear(
              const Offset(4.8, 0),
              const Offset(19.2, 0),
              const [_Colors.amber900, _Colors.amber800, _Colors.amber900],
              const [0, 0.5, 1],
            ),
        );
        _fill.shader = null;
        canvas.drawRRect(
          _stemBar.deflate(0.6),
          _stroke
            ..strokeWidth = 1.2
            ..color = _Colors.amber900,
        );
      case _Item.legs:
        _line(canvas, _legs, ink, 2);
      case _Item.wings:
        canvas
          ..drawCircle(
            const Offset(12, 12),
            9,
            _fill..color = _Colors.indigo500,
          )
          ..drawPath(_wing, _fill..color = _Colors.slate100);
      case _Item.reticulate:
      case _Item.parallel:
        canvas.drawPath(_leaf, _fill..color = _Colors.sky);
        _line(canvas, _leaf, _Colors.emerald500, 1.5);
        _line(
          canvas,
          item == _Item.reticulate ? _netVeins : _parallelVeins,
          _Colors.emerald500,
          1.5,
        );
      case _Item.taproot:
        _line(canvas, _taproot, _Colors.amber700, 2);
      case _Item.fibrous:
        _line(canvas, _fibrous, _Colors.amber700, 1.5);
    }
    canvas.restore();
  }

  /// Draws the magnifying glass or the x-ray scanner into [box] (the hand
  /// is an icon).
  static void drawTool(Canvas canvas, _Tool tool, Rect box) {
    _begin(canvas, box);
    switch (tool) {
      case _Tool.magnifier:
        canvas.drawCircle(
          const Offset(11, 11),
          8,
          _fill..color = _Colors.slate100,
        );
        canvas.drawLine(
          const Offset(16.65, 18.06),
          const Offset(21, 22.41),
          _stroke
            ..strokeWidth = 2
            ..color = _Colors.indigo500,
        );
        canvas.drawCircle(const Offset(11, 11), 7, _stroke);
      case _Tool.xray:
        canvas.drawRRect(
          _scanSquare,
          _fill..color = _Colors.cyan500.withValues(alpha: 0.2),
        );
        canvas.drawRRect(
          _scanSquare,
          _stroke
            ..strokeWidth = 1.2
            ..color = _Colors.cyan500,
        );
        _line(canvas, _scanCorners, _Colors.cyan500, 1.8);
      case _Tool.hand:
        break;
    }
    canvas.restore();
  }
}

// ================================================================== PAINTING

/// Paints, paths and the ellipsoid matrix reused by every frame.
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Butt-ended shading bands along rods.
  final Paint band = Paint()..style = PaintingStyle.stroke;

  /// Soft glow of the scanned veins and the roots (HTML `shadowBlur`).
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// The ground (its fog gradient changes with the camera).
  final Paint ground = Paint();
  final Path path = Path();
  final Path outline = Path();
  final Matrix4 matrix = Matrix4.identity();
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
    final a = label(text);
    return Size(
      a.width + 2 * _chipPadX * _labelSize,
      a.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// MeshStandardMaterial look for an ellipsoid of [c]: a radial gradient
  /// on a unit circle (lit from the upper right, like the HTML key light).
  Paint ball(Color c) => _balls[c.toARGB32()] ??= Paint()
    ..shader = ui.Gradient.radial(
      const Offset(0.3, -0.4),
      1.4,
      [labShade(c, 0.35), c, labShade(c, -0.35)],
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

/// HTML `createLeafTexture` on its 256 x 512 canvas, in leaf coordinates
/// (u across, v along towards the tip, both -1 … 1), and the leaf shapes.
/// The HTML planes were green rectangles; the texture is now clipped to a
/// pointed oval (Sadabahar) or a grass blade (Lemongrass).
abstract final class _Texture {
  static Offset _uv(double x, double y) => Offset(x / 128 - 1, 1 - y / 256);

  /// `quadraticCurveTo` from (x0, y0) over (cx, cy) to (x1, y1).
  static List<Offset> _curve(
    double x0,
    double y0,
    double cx,
    double cy,
    double x1,
    double y1,
  ) {
    const n = 8;
    final out = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final m = 1 - t;
      out.add(
        _uv(
          m * m * x0 + 2 * m * t * cx + t * t * x1,
          m * m * y0 + 2 * m * t * cy + t * t * y1,
        ),
      );
    }
    return out;
  }

  /// 'reticulate': the midrib and side veins every 60 px.
  static final List<List<Offset>> reticulate = () {
    final out = [
      [_uv(128, 0), _uv(128, 512)],
    ];
    for (var i = 50.0; i < 450; i += 60) {
      out
        ..add(_curve(128, i, 64, i + 30, 20, i - 20))
        ..add(_curve(128, i, 192, i + 30, 236, i - 20));
    }
    return out;
  }();

  /// The extra net lines of the glowing texture.
  static final List<List<Offset>> net = [
    for (var i = 50.0; i < 450; i += 60) ...[
      [_uv(96, i + 15), _uv(64, i + 40)],
      [_uv(160, i + 15), _uv(192, i + 40)],
    ],
  ];

  /// 'parallel': veins every 30 px, meeting towards the base.
  static final List<List<Offset>> parallel = [
    for (var i = 20.0; i < 256; i += 30)
      _curve(i, 0, i, 256, 128 + (i - 128) * 0.2, 512),
  ];

  static final List<Offset> leaf = _outline(
    (v) => 0.95 * math.pow(math.sin(math.pi * (v + 1) / 2), 0.7).toDouble(),
  );
  static final List<Offset> blade = _outline(
    (v) => v < -0.2
        ? 0.85 + 0.15 * (v + 1) / 0.8
        : math.pow((1 - v) / 1.2, 0.8).toDouble(),
  );

  static List<Offset> _outline(double Function(double v) half) {
    const n = 14;
    return [
      for (var i = 0; i <= n; i++) Offset(half(-1 + 2 * i / n), -1 + 2 * i / n),
      for (var i = n - 1; i >= 1; i--)
        Offset(-half(-1 + 2 * i / n), -1 + 2 * i / n),
    ];
  }
}

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// [c] seen through the HTML fog at view depth [depth].
Color _fogged(Color c, double depth) {
  final t = ((depth - _fogNear) / (_fogFar - _fogNear)).clamp(0.0, 1.0);
  if (t <= 0) return c;
  return Color.lerp(c, _Colors.sky, (t * _fogSteps).round() / _fogSteps)!;
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  /// In front of the camera (the glides pass close to the plants).
  bool visible(_V w) => cam.depth(w) > _cullDepth;

  Color fog(Color c, _V w) => _fogged(c, cam.depth(w));

  /// A shaded ellipsoid: the unit circle mapped onto the outline of the
  /// projected semi-axes (Cholesky factor of their 2 x 2 spread).
  void blob(_Solid s) {
    if (!visible(s.center)) return;
    final p = cam.p(s.center);
    final a = cam.jac(s.center, s.a);
    final b = cam.jac(s.center, s.b);
    final c = cam.jac(s.center, s.c);
    final m11 = a.dx * a.dx + b.dx * b.dx + c.dx * c.dx;
    final m21 = a.dx * a.dy + b.dx * b.dy + c.dx * c.dy;
    final m22 = a.dy * a.dy + b.dy * b.dy + c.dy * c.dy;
    const eps = 0.05;
    final l11 = math.sqrt(m11 + eps);
    final l21 = m21 / l11;
    final l22 = math.sqrt(math.max(eps, m22 - l21 * l21));
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..transform(
        (pens.matrix
              ..setValues(l11, l21, 0, 0, 0, l22, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1))
            .storage,
      )
      ..drawCircle(Offset.zero, 1, cache.ball(fog(s.color, s.center)))
      ..restore();
  }

  /// A rod (tapered CylinderGeometry or cone, rounded ends): body, shaded
  /// side and highlight.
  void rod(_Solid s) {
    if (!visible(s.a) || !visible(s.b)) return;
    final color = fog(s.color, s.center);
    final pa = cam.p(s.a), pb = cam.p(s.b);
    final wa = math.max(0.8, s.r0 * cam.scaleAt(s.a));
    final wb = math.max(0.8, s.r1 * cam.scaleAt(s.b));
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
    if (w < 1.2) return;
    canvas
      ..drawLine(
        pa - lit * (wa * 0.55),
        pb - lit * (wb * 0.55),
        pens.band
          ..strokeWidth = w * 0.7
          ..color = labShade(color, -0.2),
      )
      ..drawLine(
        pa + lit * (wa * 0.45),
        pb + lit * (wb * 0.45),
        pens.band
          ..strokeWidth = w * 0.3
          ..color = labShade(color, 0.28),
      );
  }

  /// A glowing root (HTML MeshBasicMaterial: flat, unlit), [alpha] faded.
  void glowRod(_Solid s, double alpha) {
    if (!visible(s.a) || !visible(s.b)) return;
    final color = fog(s.color, s.center);
    final pa = cam.p(s.a), pb = cam.p(s.b);
    final wa = math.max(0.7, s.r0 * cam.scaleAt(s.a));
    final wb = math.max(0.5, s.r1 * cam.scaleAt(s.b));
    canvas.drawLine(
      pa,
      pb,
      pens.glow
        ..strokeWidth = wa + wb + 4
        ..color = color.withValues(alpha: 0.5 * alpha),
    );
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    final n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    final fill = pens.fill..color = color.withValues(alpha: alpha);
    canvas
      ..drawPath(path, fill)
      ..drawCircle(pa, wa, fill);
  }

  /// The flat polygon [poly] (world), clipped at the near plane and
  /// projected into [path]. False when nothing of it is in front of the
  /// camera.
  bool polygon(List<_V> poly, Path path) {
    path.reset();
    var count = 0;
    void add(_V w) {
      final o = cam.p(w);
      if (count == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
      count++;
    }

    for (var i = 0; i < poly.length; i++) {
      final a = poly[i], b = poly[(i + 1) % poly.length];
      final da = cam.depth(a) - _cullDepth;
      final db = cam.depth(b) - _cullDepth;
      if (da >= 0) add(a);
      if ((da >= 0) != (db >= 0)) add(_V.lerp(a, b, da / (da - db)));
    }
    if (count < 3) return false;
    path.close();
    return true;
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the garden
/// walk (Hibiscus, bare tree, crow), S2 the garden bed (Sadabahar,
/// Lemongrass, x-ray circle and roots); then the text sprites and the
/// summary's confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.cam, cache);
    // `scene.background` (the same in both themes).
    canvas.drawRect(labBleed(size), _pens.fill..color = _Colors.sky);
    if (s.scenario == 0) {
      _paintWalk(g);
    } else {
      _paintGarden(g);
    }
    if (showLabels) _paintLabels(g);
    _paintConfetti(canvas);
  }

  /// A ground plane of [color] (lit from above), fading into the fog with
  /// distance: the camera has no roll, so each screen row of the ground has
  /// one depth and the fog is a vertical gradient.
  void _paintGround(_Gfx g, List<_V> quad, Color color) {
    final cam = g.cam;
    final path = _pens.path;
    if (!g.polygon(quad, path)) return;
    final lit = _lit(color, _V.up);
    final far = cam.groundRow(_fogFar);
    final near = cam.groundRow(_fogNear);
    if (!far.isFinite || !near.isFinite || near - far < 1) {
      g.canvas.drawPath(path, _pens.fill..color = lit);
      return;
    }
    const steps = 6;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i <= steps; i++) {
      final depth = _fogFar - (_fogFar - _fogNear) * i / steps;
      colors.add(
        Color.lerp(
          lit,
          _Colors.sky,
          (depth - _fogNear) / (_fogFar - _fogNear),
        )!,
      );
      stops.add(((cam.groundRow(depth) - far) / (near - far)).clamp(0.0, 1.0));
    }
    _pens.ground.shader = ui.Gradient.linear(
      Offset(0, far),
      Offset(0, near),
      colors,
      stops,
    );
    g.canvas.drawPath(path, _pens.ground);
  }

  /// The solids of one model, far first (painter's algorithm).
  void _paintSolids(_Gfx g, List<_Solid> solids) {
    final cam = g.cam;
    final depths = [for (final s in solids) cam.depth(s.center)];
    final order = List<int>.generate(solids.length, (i) => i)
      ..sort((i, j) => depths[j].compareTo(depths[i]));
    for (final i in order) {
      final s = solids[i];
      switch (s.kind) {
        case _Kind.blob:
          g.blob(s);
        case _Kind.rod:
          g.rod(s);
        case _Kind.leaf:
          _paintLeaf(g, s);
      }
    }
  }

  /// Models drawn far to near by their [anchor]s.
  void _paintGroups(_Gfx g, List<(_V, List<_Solid>)> groups) {
    final cam = g.cam;
    final sorted = [...groups]
      ..sort((a, b) => cam.depth(b.$1).compareTo(cam.depth(a.$1)));
    for (final (_, solids) in sorted) {
      _paintSolids(g, solids);
    }
  }

  // ---------------------------------------------------------- scenario 1

  /// `buildS1Scene()`: the lime ground, the bare tree with its branch, the
  /// crow on it (flying when tapped) and the Hibiscus.
  void _paintWalk(_Gfx g) {
    final s = scene;
    _paintGround(g, const [
      _V(-_walkHalf, 0, -_walkHalf),
      _V(_walkHalf, 0, -_walkHalf),
      _V(_walkHalf, 0, _walkHalf),
      _V(-_walkHalf, 0, _walkHalf),
    ], _Colors.grass);
    final pose = s.crowPose;
    _paintGroups(g, [
      (const _V(6, 4, -5.6), _Models.tree),
      (pose.at, _Models.crow(pose.at, pose.yaw, pose.flap)),
      (const _V(-4, 2, 2), _Models.hibiscus),
    ]);
  }

  // ---------------------------------------------------------- scenario 2

  /// `buildS2Scene()`: the garden bed over its dirt box, the x-ray circle
  /// and the glowing roots it reveals, then the two plants. The HTML's
  /// opaque ground hid the roots under it; here they show through the
  /// x-ray circle.
  void _paintGarden(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final path = _pens.path;
    _paintGround(g, const [
      _V(-_bedHalfW, 0, -_bedHalfD),
      _V(_bedHalfW, 0, -_bedHalfD),
      _V(_bedHalfW, 0, _bedHalfD),
      _V(-_bedHalfW, 0, _bedHalfD),
    ], _Colors.bed);
    // The dirt box's front face, seen from the start view.
    if (g.cam.eye.z > _bedHalfD &&
        g.polygon(const [
          _V(-_bedHalfW, 0, _bedHalfD),
          _V(_bedHalfW, 0, _bedHalfD),
          _V(_bedHalfW, -_dirtDepth, _bedHalfD),
          _V(-_bedHalfW, -_dirtDepth, _bedHalfD),
        ], path)) {
      canvas.drawPath(
        path,
        _pens.fill
          ..color = g.fog(
            _lit(_Colors.dirt, const _V(0, 0, 1)),
            const _V(0, -_dirtDepth / 2, _bedHalfD),
          ),
      );
    }
    final hole = s.xrayAt;
    if (hole != null &&
        g.polygon([
          for (var i = 0; i < 32; i++)
            _V(
              hole.x + _xrayHoleR * math.cos(2 * math.pi * i / 32),
              0.01,
              hole.z + _xrayHoleR * math.sin(2 * math.pi * i / 32),
            ),
        ], path)) {
      canvas.drawPath(
        path,
        _pens.fill..color = g.fog(_Colors.black, hole).withValues(alpha: 0.6),
      );
    }
    final sada = s.fadeIn(s.sadaRootsAt);
    if (sada > 0) {
      for (final root in _Models.sadaRoots) {
        g.glowRod(root, sada);
      }
    }
    final lemon = s.fadeIn(s.lemonRootsAt);
    if (lemon > 0) {
      for (final root in _Models.lemonRoots) {
        g.glowRod(root, lemon);
      }
    }
    _paintGroups(g, [
      (const _V(-5, 1.5, 2), _Models.sada),
      (const _V(5, 2, 2), _Models.lemon),
    ]);
  }

  /// A textured plane (HTML `createLeafTexture`): the leaf shape lit by its
  /// face, its veins clipped to it; the scanned target leaf's veins glow
  /// amber (HTML: the texture redrawn with `#fbbf24`, width 6, blur 15).
  void _paintLeaf(_Gfx g, _Solid leaf) {
    if (!g.visible(leaf.center)) return;
    final cam = g.cam;
    final canvas = g.canvas;
    var n = leaf.a.cross(leaf.b).unit;
    if (n.dot(cam.eye - leaf.center) < 0) n = -n;
    final base = g.fog(_lit(leaf.color, n), leaf.center);
    Offset at(Offset uv) =>
        cam.p(leaf.center + leaf.a * uv.dx + leaf.b * uv.dy);
    final outline = _pens.outline..reset();
    final shape = leaf.blade ? _Texture.blade : _Texture.leaf;
    for (var i = 0; i < shape.length; i++) {
      final o = at(shape[i]);
      if (i == 0) {
        outline.moveTo(o.dx, o.dy);
      } else {
        outline.lineTo(o.dx, o.dy);
      }
    }
    outline.close();
    canvas.drawPath(outline, _pens.fill..color = base);
    // Design px per texture px.
    final k = cam.scaleAt(leaf.center) * 2 * leaf.a.length / 256;
    if (leaf.veins == _Veins.none) {
      canvas.drawPath(
        outline,
        _pens.stroke
          ..strokeWidth = math.max(0.6, 3 * k)
          ..color = labShade(base, -0.22),
      );
      return;
    }
    final glow = scene.glow(leaf.tag);
    final veins = leaf.veins == _Veins.reticulate
        ? _Texture.reticulate
        : _Texture.parallel;
    final vein = g.fog(_lit(_Colors.vein, n), leaf.center);
    final gold = g.fog(_Colors.glow, leaf.center);
    final width = math.max(0.6, (3 + 3 * glow) * k);
    final path = _pens.path;
    void draw(List<List<Offset>> lines, Paint paint) {
      for (final line in lines) {
        path.reset();
        for (var i = 0; i < line.length; i++) {
          final o = at(line[i]);
          if (i == 0) {
            path.moveTo(o.dx, o.dy);
          } else {
            path.lineTo(o.dx, o.dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }

    canvas
      ..save()
      ..clipPath(outline);
    if (glow > 0) {
      draw(
        veins,
        _pens.glow
          ..strokeWidth = width * 3
          ..color = gold.withValues(alpha: 0.7 * glow),
      );
    }
    draw(
      veins,
      _pens.stroke
        ..strokeWidth = width
        ..color = Color.lerp(vein, gold, glow)!,
    );
    if (glow > 0 && leaf.veins == _Veins.reticulate) {
      draw(
        _Texture.net,
        _pens.stroke
          ..strokeWidth = math.max(0.5, 2 * k)
          ..color = gold.withValues(alpha: glow),
      );
    }
    canvas.restore();
  }

  // ---------------------------------------------------------- labels

  /// Every text sprite of the scene (HTML `createTextSprite`, drawn on top
  /// like `depthTest: false`), and the 'Hard' sprite while it floats.
  void _paintLabels(_Gfx g) {
    final s = scene;
    void label(_V at, String key, [Color bg = _Colors.chipBg]) {
      if (g.visible(at)) _chip(g, g.cam.p(at), _t(key), bg);
    }

    if (s.scenario == 0) {
      label(_hibiscusLabel, 'name_hibiscus');
      label(_crowLabel, 'name_crow');
      final hard = s.hardAt;
      if (hard != null) label(hard, 'lbl_hard', _Colors.hardChip);
    } else {
      label(_sadaLabel, 'name_sada');
      label(_lemonLabel, 'name_lemon');
    }
  }

  /// A dark chip with an emerald border and white bold text, centred on
  /// [at] and kept inside the visible canvas.
  void _chip(_Gfx g, Offset at, String text, Color bg) {
    final size = cache.chipSize(text);
    var rect = (at + _chipOffset(size)) & size;
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
    g.canvas
      ..drawRRect(rr, _pens.fill..color = bg)
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1.5
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
