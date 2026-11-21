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

/// Class 6 Science • Chapter 6 • Activity 1
/// Identifying and Grouping Objects by Materials.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A1-Identifying_and_Grouping_Objects_by_Materials.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML camera: position (0, 10, 24), look-at
/// (0, 2, 0), 45° field of view.
///
/// Scenario 1 (What's It Made Of?): tap an object in the classroom (desk,
/// notebook, pen, chair legs) and drag the material it is made of from the
/// Material Toolbox onto it, or tap the material.
///
/// Scenario 2 (The Sorting Challenge): tap an object on the floor and drag
/// it into the bin of its material (wood, metal, plastic or glass), or tap
/// the bin.
class Ch6A1IdentifyingAndGroupingObjectsByMaterialsPage extends StatefulWidget {
  const Ch6A1IdentifyingAndGroupingObjectsByMaterialsPage({super.key});

  @override
  State<Ch6A1IdentifyingAndGroupingObjectsByMaterialsPage> createState() =>
      _MaterialsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, drop → `science/drop.mp3`.
///
/// The HTML synthesises two Web-Audio tones in `playSound(type)`; each is
/// mapped onto the closest file: `pop` (short 400 → 800 Hz blip) → pop,
/// `success` (C-E-G arpeggio) → success. The HTML played `pop` for a wrong
/// material or bin too; here a wrong answer plays the lab's wrong tone, and
/// an object landing in its bin plays drop (the "thud" the HTML step 2
/// observation promises).
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Right action (shell feedback).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong material, wrong bin, nothing selected.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `playSound('success')`: material matched, object sorted, summary.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `playSound('pop')`: object selected, toolbox item picked up.
  pop('audio/class6/science/pop.mp3'),

  /// An object lands in its bin.
  drop('audio/class6/science/drop.mp3');

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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scenes
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color green400 = Color(0xFF4ADE80);
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
  /// `scene.background`: 0x020617 (dark) / 0xf1f5f9 (light theme).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate100;

  /// Floors: 0x334155 (classroom), 0x1e293b (sorting room).
  static const Color floorClassroom = slate700;
  static const Color floorSorting = slate800;

  // Scenario 1 (`buildS1`).
  static const Color deskTop = Color(0xFF92400E);
  static const Color deskLeg = Color(0xFF78350F);
  static const Color notebook = Color(0xFFF8FAFC);

  /// Ruled lines drawn on the notebook (not in the HTML's plain box).
  static const Color notebookLine = Color(0x8093C5FD);
  static const Color pen = Color(0xFF2563EB);
  static const Color chairSeat = Color(0xFFE2E8F0);
  static const Color chairLeg = Color(0xFF64748B);

  // Scenario 2 (`buildS2`).
  static const Color binWood = Color(0xFF92400E);
  static const Color binMetal = Color(0xFF64748B);
  static const Color binPlastic = Color(0xFF2563EB);
  static const Color binGlass = Color(0xFF06B6D4);
  static const Color block = Color(0xFFD97706);
  static const Color steel = Color(0xFF94A3B8);
  static const Color ball = Color(0xFF3B82F6);
  static const Color tumbler = Color(0xFFA5F3FC);
  static const Color combSpine = Color(0xFFEC4899);
  static const Color combTooth = Color(0xFFF472B6);

  /// HTML `setHighlight` colours: 0xeab308 (selected), 0x22c55e (correct),
  /// 0xef4444 (wrong).
  static const Color hlYellow = Color(0xFFEAB308);
  static const Color hlGreen = Color(0xFF22C55E);
  static const Color hlRed = Color(0xFFEF4444);

  /// `createTextSprite`: rgba(15, 23, 42, 0.9) badge, #eab308 border.
  static const Color spriteBg = Color(0xE60F172A);
  static const Color spriteBorder = Color(0xFFEAB308);

  /// Soft contact shadows of the floor objects.
  static const Color shadow = Color(0x66000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    // The HTML summary header is blue-600 with white text; the shell writes
    // the popup title in the accent colour, which reads on a darker blue.
    popupHeader: _Colors.blue900,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xCC0F172A), // bg-slate-900/80
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.blue100,
    dialogBg: _Colors.white,
    toastBg: Color(0xCC0F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteBg,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Step
// numbers ("Step 1: ") are dropped from the HUD lines because the shell
// shows "Step n of N"; emoji in the material names are icons instead.
// Changes from the HTML (see the report): "Click" is "Tap" and every step
// says how (object or its button; drag the icon or tap it). The learner
// decides every material and bin: no instruction, HUD line, concept or
// object name says which one it is (the HTML said "Drag 'Wood' icon onto
// the desk", "Wooden Block", "Metal Key"...), and a wrong answer gets a
// hint about what the object looks like (`hint_*`). The S1 step 1
// observation no longer says the toolbox opens (it is open all along, as
// in the HTML); the HTML's English-only toasts are translated; Hindi
// feedback avoids gendered verbs after an object's name ("निर्मित"). Keys
// marked "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Identifying and Grouping Objects by Materials',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1_opt': "Scenario 1: What's It Made Of?",
    'scen_2_opt': 'Scenario 2: The Sorting Challenge',
    's1_desc':
        'To identify the primary material of various objects found in a classroom.',
    's2_desc':
        'To group a variety of objects into bins based on the material they are made of.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Objects around us are made of distinct physical materials.',
    'step_1_1_a': "Tap the desk (or its 'Desk' button).",
    'step_1_1_o': 'Desk gets highlighted with a bright yellow glowing outline.',
    'step_1_2_c':
        'Furniture is often made of a hard, fibrous material that comes from trees.',
    'step_1_2_a':
        'Drag the icon of the material the desk is made of from the Material Toolbox onto the desk (or tap that icon).',
    'step_1_2_o': 'Desk outline turns green and labels as Wood.',
    'step_1_3_c':
        'Observing different everyday items carefully helps identify their composition.',
    'step_1_3_a':
        "Tap the student's notebook on the desk (or its 'Notebook' button).",
    'step_1_3_o':
        'Notebook gets highlighted with a bright yellow glowing outline.',
    'step_1_4_c':
        'Notebook pages are made of a material manufactured from plant (cellulose) pulp.',
    'step_1_4_a':
        'Drag the icon of the material the notebook is made of from the Material Toolbox onto the notebook (or tap that icon).',
    'step_1_4_o': 'Notebook outline turns green and labels correctly as Paper.',
    'step_1_5_c':
        'Some materials are man-made and moulded into shape; others are extracted from ores mined from the earth.',
    'step_1_5_a':
        'Identify the pen and the chair legs: tap each one (or its button), then drag the icon of the material it is made of onto it (or tap that icon).',
    'step_1_5_o':
        'All classroom objects successfully identified with clear green visual highlights!',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Different items can share the same composition.',
    'step_2_1_a': 'Tap the toy block on the floor.',
    'step_2_1_o':
        'Block lifts slightly off the floor with a yellow glowing outline.',
    'step_2_2_c': 'Grouping objects simplifies organization and recycling.',
    'step_2_2_a':
        'Drag the toy block into the bin of the material it is made of (or tap that bin).',
    'step_2_2_o':
        'Bin lights up green and block animates inside with a thud sound.',
    'step_2_3_c':
        'Objects that are shiny, dense and strong are usually made of the same kind of material.',
    'step_2_3_a':
        'Tap the key, then drag it into the bin of its material (or tap that bin).',
    'step_2_3_o': 'Key drops into Metal container and bin counter updates.',
    'step_2_4_c':
        'Systematic classification separates objects by the material they are made of.',
    'step_2_4_a':
        'Sort the ball, the tumbler, the spoon and the comb: tap each one, then drag it into the bin of its material (or tap that bin).',
    'step_2_4_o':
        'All 6 objects correctly classified into their matching material bins!',
    // ---------------------------------------------------- HUD (Current Task)
    's1_hud_1': 'Tap the desk to select it.',
    's1_hud_2': "Drag the icon of the desk's material onto it.",
    's1_hud_3': "Tap the student's notebook.",
    's1_hud_4': "Drag the icon of the notebook's material onto it.",
    's1_hud_5': 'Identify what the pen and the chair legs are made of.',
    's1_hud_6': 'Investigation Complete! All items correctly labeled.',
    's2_hud_1': 'Tap the toy block.',
    's2_hud_2': 'Drag the toy block into the bin of its material.',
    's2_hud_3': 'Tap the key and drop it into the bin of its material.',
    's2_hud_4':
        'Sort the ball, tumbler, spoon & comb into the bins of their materials.',
    's2_hud_5': 'Classification Complete! All objects sorted.',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration Step',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    // Added.
    'obs_pending': 'Complete this step to see what happens.',
    'findings': 'Material Findings',
    'tbl_object': 'Object',
    'tbl_material': 'Material',
    'bin_counter': 'Bin Counter',
    'bin_wood': 'Wood bin',
    'bin_metal': 'Metal bin',
    'bin_plastic': 'Plastic bin',
    'bin_glass': 'Glass bin',
    'on_floor': 'Still on the floor',
    'tbl_bin': 'Bin',
    'tbl_items': 'Objects',
    // ------------------------------------------------------------ toolbox
    'toolbox_title': 'Material Toolbox',
    'toolbox_s1_desc':
        'Drag a material onto an object, or select the object and tap the material:',
    'mat_wood': 'Wood',
    'mat_paper': 'Paper',
    'mat_plastic': 'Plastic',
    'mat_metal': 'Metal',
    'mat_glass': 'Glass',
    // ------------------------------------------------------------ objects
    'btn_desk': 'Desk',
    'btn_notebook': 'Notebook',
    'btn_pen': 'Pen',
    'btn_chair': 'Chair Legs',
    'obj_block': 'Toy Block',
    'obj_key': 'Key',
    'obj_ball': 'Ball',
    'obj_tumbler': 'Tumbler',
    'obj_spoon': 'Spoon',
    'obj_comb': 'Comb',
    // ------------------------------------------------------------- toasts
    'toast_selected':
        'Selected: {name}. Drag the matching material icon from the toolbox!',
    'toast_pick_first':
        'Please tap the Desk, Notebook, Pen or Chair Legs first!',
    // Added: hints after a wrong material or bin.
    'hint_desk':
        'Not the right material! The desk is hard and shows a grain: its material comes from trees.',
    'hint_notebook':
        "Not the right material! The notebook's pages are thin, flexible sheets made from plant pulp.",
    'hint_pen':
        'Not the right material! The pen body is light, smooth and moulded in one piece.',
    'hint_chair':
        'Not the right material! The chair legs are shiny, strong and hard to bend.',
    'hint_block':
        'Not the right bin! The toy block shows a grain: its material comes from trees.',
    'hint_key':
        'Not the right bin! The key is shiny, hard and heavy for its size.',
    'hint_ball':
        'Not the right bin! The ball is light, smooth and moulded in one piece.',
    'hint_tumbler': 'Not the right bin! You can see through the tumbler.',
    'hint_spoon':
        'Not the right bin! The spoon is shiny and hard and does not bend easily.',
    'hint_comb':
        'Not the right bin! The comb is light, bends a little and is moulded in one piece.',
    'toast_item_selected':
        'Selected: {name}. Now drop it into the matching material bin.',
    'toast_select_first': 'Select an object from the floor first!',
    // Added.
    'toast_drop_in_bin': 'Drop it into one of the material bins.',
    // ------------------------------------------------------- observations
    'obs_wood_title': 'Correct: Made of Wood!',
    'obs_wood_desc':
        'The desk is crafted from solid wood obtained from trees. Wood is strong and sturdy for furniture.',
    'obs_paper_title': 'Correct: Made of Paper!',
    'obs_paper_desc':
        'The notebook pages are made from plant pulp fiber processed into thin flexible sheets of paper.',
    'obs_plastic_title': 'Correct: Made of Plastic!',
    'obs_plastic_desc':
        'The ballpoint pen body is molded from synthetic lightweight waterproof plastic.',
    'obs_metal_title': 'Correct: Made of Metal!',
    'obs_metal_desc':
        'The chair support legs are made of steel/iron metal to bear heavy loads without bending.',
    'obs_sort_title': 'Item Sorted Correctly!',
    // --------------------------------------------------------- conclusion
    'sc_complete': 'Scenario {n} Complete!',
    's1_summary':
        "Well done! You've learned that different objects are made of different materials like wood, paper, plastic, and metal.",
    's2_summary':
        'Excellent work! You have grouped the objects based on the material they are made of. This is called classification.',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You have successfully identified primary materials and sorted objects into groups! You mastered classification by observable material properties.',
    // Added (screen readers).
    'scene_s1':
        'A classroom with a desk, a notebook and a pen on the desk, and a chair in front of it.',
    'scene_s2':
        'Six objects on the floor and four material bins: Wood, Metal, Plastic and Glass.',
  },
  'hi': {
    'app_title': 'सामग्री के आधार पर वस्तुओं की पहचान और समूहीकरण',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर की सामग्री',
    'scen_1_opt': 'परिदृश्य 1: यह किससे बना है?',
    'scen_2_opt': 'परिदृश्य 2: छंटाई की चुनौती',
    's1_desc':
        'कक्षा में पाई जाने वाली विभिन्न वस्तुओं की मुख्य सामग्री की पहचान करना।',
    's2_desc':
        'वस्तुओं को उनकी सामग्री के आधार पर सही डिब्बों में समूहित करना।',
    'step_1_1_c': 'हमारे चारों ओर की वस्तुएं अलग-अलग सामग्रियों से बनी हैं।',
    'step_1_1_a': "मेज (या उसके 'मेज' बटन) पर टैप करें।",
    'step_1_1_o': 'मेज पीले रंग की चमक के साथ हाइलाइट होती है।',
    'step_1_2_c':
        'फर्नीचर अक्सर पेड़ों से मिलने वाले कठोर, रेशेदार पदार्थ से बनता है।',
    'step_1_2_a':
        'सामग्री टूलबॉक्स से उस सामग्री का आइकन मेज पर खींचें जिससे मेज बनी है (या उस आइकन पर टैप करें)।',
    'step_1_2_o': 'मेज की आउटलाइन हरी हो जाती है और लकड़ी का लेबल लग जाता है।',
    'step_1_3_c': 'दैनिक वस्तुओं का ध्यानपूर्वक अवलोकन उनकी सामग्री बताता है।',
    'step_1_3_a': "मेज पर रखी कॉपी (या उसके 'कॉपी' बटन) पर टैप करें।",
    'step_1_3_o': 'कॉपी चमकदार पीली आउटलाइन के साथ हाइलाइट होती है।',
    'step_1_4_c':
        'कॉपी के पन्ने पौधों के गूदे (सेलुलोज़) से बनाए गए पदार्थ से बनते हैं।',
    'step_1_4_a':
        'सामग्री टूलबॉक्स से उस सामग्री का आइकन कॉपी पर खींचें जिससे कॉपी बनी है (या उस आइकन पर टैप करें)।',
    'step_1_4_o':
        'कॉपी की आउटलाइन हरी हो जाती है और उस पर कागज़ का लेबल लग जाता है।',
    'step_1_5_c':
        'कुछ पदार्थ मानव-निर्मित होते हैं और साँचे में ढाले जाते हैं; कुछ खदानों से निकाले गए अयस्कों से प्राप्त होते हैं।',
    'step_1_5_a':
        'कलम और कुर्सी के पैरों की पहचान करें: हर एक पर (या उसके बटन पर) टैप करें, फिर उसकी सामग्री का आइकन उस पर खींचें (या उस आइकन पर टैप करें)।',
    'step_1_5_o':
        'कक्षा की सभी वस्तुओं की सही पहचान हुई और वे हरे रंग से चिह्नित हैं!',
    'step_2_1_c': 'अलग-अलग वस्तुएं एक ही पदार्थ से बन सकती हैं।',
    'step_2_1_a': 'फर्श पर रखे खिलौना गुटके पर टैप करें।',
    'step_2_1_o': 'गुटका पीली चमक के साथ फर्श से थोड़ा ऊपर उठ जाता है।',
    'step_2_2_c': 'समूह बनाने से व्यवस्था और रीसाइक्लिंग आसान होती है।',
    'step_2_2_a':
        'गुटके को खींचकर उस डिब्बे में डालें जो उसकी सामग्री का है (या उस डिब्बे पर टैप करें)।',
    'step_2_2_o':
        'डिब्बा हरा चमकता है और गुटका धप की आवाज़ के साथ अंदर चला जाता है।',
    'step_2_3_c':
        'चमकदार, भारी और मजबूत वस्तुएं आमतौर पर एक ही तरह के पदार्थ से बनी होती हैं।',
    'step_2_3_a':
        'चाबी पर टैप करें, फिर उसे खींचकर उसकी सामग्री वाले डिब्बे में डालें (या उस डिब्बे पर टैप करें)।',
    'step_2_3_o':
        'चाबी धातु के डिब्बे में गिरती है और डिब्बे की गिनती बढ़ जाती है।',
    'step_2_4_c':
        'व्यवस्थित वर्गीकरण वस्तुओं को उनकी सामग्री के आधार पर अलग करता है।',
    'step_2_4_a':
        'गेंद, गिलास, चम्मच और कंघी को छांटें: हर एक पर टैप करें, फिर उसे खींचकर उसकी सामग्री वाले डिब्बे में डालें (या उस डिब्बे पर टैप करें)।',
    'step_2_4_o': 'सभी 6 वस्तुएं सही डिब्बों में वर्गीकृत की गईं!',
    's1_hud_1': 'चुनने के लिए मेज पर टैप करें।',
    's1_hud_2': 'मेज की सामग्री का आइकन उस पर खींचें।',
    's1_hud_3': 'कॉपी पर टैप करें।',
    's1_hud_4': 'कॉपी की सामग्री का आइकन उस पर खींचें।',
    's1_hud_5': 'पहचानें कि कलम और कुर्सी के पैर किस सामग्री से बने हैं।',
    's1_hud_6': 'जाँच पूर्ण! सभी वस्तुओं पर सही लेबल लग गए।',
    's2_hud_1': 'खिलौना गुटके पर टैप करें।',
    's2_hud_2': 'गुटके को उसकी सामग्री वाले डिब्बे में डालें।',
    's2_hud_3': 'चाबी को उसकी सामग्री वाले डिब्बे में डालें।',
    's2_hud_4':
        'गेंद, गिलास, चम्मच और कंघी को उनकी सामग्री वाले डिब्बों में डालें।',
    's2_hud_5': 'वर्गीकरण पूर्ण! सभी वस्तुएं छांटी गईं।',
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण चरण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'obs_pending': 'क्या होता है, यह देखने के लिए यह चरण पूरा करें।',
    'findings': 'सामग्री की पहचान',
    'tbl_object': 'वस्तु',
    'tbl_material': 'सामग्री',
    'bin_counter': 'डिब्बों की गिनती',
    'bin_wood': 'लकड़ी का डिब्बा',
    'bin_metal': 'धातु का डिब्बा',
    'bin_plastic': 'प्लास्टिक का डिब्बा',
    'bin_glass': 'काँच का डिब्बा',
    'on_floor': 'अभी फर्श पर',
    'tbl_bin': 'डिब्बा',
    'tbl_items': 'वस्तुएं',
    'toolbox_title': 'सामग्री टूलबॉक्स',
    'toolbox_s1_desc':
        'सामग्री को किसी वस्तु पर खींचें, या वस्तु चुनकर सामग्री पर टैप करें:',
    'mat_wood': 'लकड़ी',
    'mat_paper': 'कागज़',
    'mat_plastic': 'प्लास्टिक',
    'mat_metal': 'धातु',
    'mat_glass': 'काँच',
    'btn_desk': 'मेज',
    'btn_notebook': 'कॉपी',
    'btn_pen': 'कलम',
    'btn_chair': 'कुर्सी के पैर',
    'obj_block': 'खिलौना गुटका',
    'obj_key': 'चाबी',
    'obj_ball': 'गेंद',
    'obj_tumbler': 'गिलास',
    'obj_spoon': 'चम्मच',
    'obj_comb': 'कंघी',
    'toast_selected': 'चयन: {name}। टूलबॉक्स से सही सामग्री का आइकन खींचें!',
    'toast_pick_first':
        'कृपया पहले मेज, कॉपी, कलम या कुर्सी के पैर पर टैप करें!',
    'hint_desk':
        'यह सामग्री सही नहीं! मेज कठोर है और उस पर रेशों की धारियाँ हैं; इसकी सामग्री पेड़ों से मिलती है।',
    'hint_notebook':
        'यह सामग्री सही नहीं! कॉपी के पन्ने पौधों के गूदे से बनी पतली, लचीली चादरें हैं।',
    'hint_pen':
        'यह सामग्री सही नहीं! कलम का ढाँचा हल्का, चिकना और एक ही टुकड़े में ढला हुआ है।',
    'hint_chair':
        'यह सामग्री सही नहीं! कुर्सी के पैर चमकदार और मजबूत हैं और आसानी से नहीं मुड़ते।',
    'hint_block':
        'यह डिब्बा सही नहीं! गुटके पर रेशों की धारियाँ हैं; इसकी सामग्री पेड़ों से मिलती है।',
    'hint_key':
        'यह डिब्बा सही नहीं! चाबी चमकदार, कठोर और अपने आकार के हिसाब से भारी है।',
    'hint_ball':
        'यह डिब्बा सही नहीं! गेंद हल्की, चिकनी और एक ही टुकड़े में ढली हुई है।',
    'hint_tumbler': 'यह डिब्बा सही नहीं! गिलास के आर-पार देखा जा सकता है।',
    'hint_spoon':
        'यह डिब्बा सही नहीं! चम्मच चमकदार और कठोर है और आसानी से नहीं मुड़ता।',
    'hint_comb':
        'यह डिब्बा सही नहीं! कंघी हल्की है, थोड़ी मुड़ सकती है और एक ही टुकड़े में ढली हुई है।',
    'toast_item_selected':
        'चयन: {name}। अब इसे सही सामग्री वाले डिब्बे में डालें।',
    'toast_select_first': 'पहले फर्श से कोई वस्तु चुनें!',
    'toast_drop_in_bin': 'इसे सामग्री के किसी डिब्बे में डालें।',
    'obs_wood_title': 'सही: लकड़ी से निर्मित!',
    'obs_wood_desc':
        'यह मेज पेड़ों से प्राप्त मजबूत लकड़ी से बनाई गई है। फर्नीचर के लिए लकड़ी टिकाऊ होती है।',
    'obs_paper_title': 'सही: कागज़ से निर्मित!',
    'obs_paper_desc':
        'कॉपी के पन्ने पौधों के गूदे से पतली लचीली चादरों के रूप में बनाए जाते हैं।',
    'obs_plastic_title': 'सही: प्लास्टिक से निर्मित!',
    'obs_plastic_desc':
        'कलम का ढाँचा हल्के और जलरोधी कृत्रिम प्लास्टिक से ढाला गया है।',
    'obs_metal_title': 'सही: धातु से निर्मित!',
    'obs_metal_desc':
        'कुर्सी के पैर बिना झुके भारी वजन सहने के लिए स्टील या लोहे जैसी मजबूत धातु से बने हैं।',
    'obs_sort_title': 'वस्तु सही डिब्बे में रखी गई!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_summary':
        'शाबाश! आपने जाना कि वस्तुएं लकड़ी, कागज़, प्लास्टिक और धातु जैसी अलग-अलग सामग्रियों से बनती हैं।',
    's2_summary':
        'बहुत बढ़िया! आपने वस्तुओं को उनकी सामग्री के आधार पर समूहित किया। इसे वर्गीकरण कहते हैं।',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने सफलतापूर्वक प्राथमिक सामग्रियों की पहचान की और वस्तुओं को समूहों में बाँटा! आपने अवलोकन द्वारा वर्गीकरण में महारत हासिल की।',
    'scene_s1':
        'कक्षा में एक मेज, मेज पर रखी कॉपी और कलम, और उसके सामने एक कुर्सी।',
    'scene_s2':
        'फर्श पर छह वस्तुएं और सामग्री के चार डिब्बे: लकड़ी, धातु, प्लास्टिक और काँच।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [5, 4];

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
              concept: t('step_${n}_${i}_c'),
              action: t('step_${n}_${i}_a'),
              observation: t('step_${n}_${i}_o'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// The part of the design box the scene's touch targets are kept in (the
/// stage only hit-tests inside its design box).
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// HTML `new THREE.PerspectiveCamera(45, aspect, 0.1, 1000)`.
const double _fovDegrees = 45;
const double _near = 0.1;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `resetCamera()` (both scenarios): `camera.position.set(0, 10, 24)`,
/// `controls.target.set(0, 2, 0)`.
const _V _eye = _V(0, 10, 24);
const _V _target = _V(0, 2, 0);
const _V _up = _V(0, 1, 0);

/// The camera looks down by asin(8 / √640) ≈ 18.4°: sin² and cos² of that
/// pitch (the depth of a flat object shows foreshortened by sin).
const double _sinPitch2 = 0.1;
const double _cosPitch2 = 0.9;

/// HTML lights: `AmbientLight(0xffffff, 0.75)` and `DirectionalLight(
/// 0xfff8e7, 0.95)` at (15, 30, 20). Three.js r128 adds them linearly and
/// clips at white, which washes the lit faces out on a phone; both are
/// scaled by [_lightScale].
const double _lightScale = 0.75;
const double _ambient = 0.75 * _lightScale;
const double _diffuse = 0.95 * _lightScale;

/// (15, 30, 20) normalised.
const _V _light = _V(0.3841, 0.7682, 0.5121);

/// HTML `setHighlight`: emissive colour at intensity 0.55 and an outline
/// box 0.25 larger than the object (edges plus a fill at opacity 0.15),
/// pulsing by `1 + sin(Date.now() * 0.006) * 0.03`.
const double _emissive = 0.55;
const double _outlinePad = 0.25;
const double _outlineFill = 0.15;
const double _pulseRate = 6;
const double _pulseAmp = 0.03;

/// HTML `setTimeout(() => clearHighlight(), 1200)` after a correct match,
/// and the 1 s red flash before a wrong object turns yellow again.
const double _greenSeconds = 1.2;
const double _redSeconds = 1.0;

/// A bin lights up green this long when an object is sorted into it (the
/// HTML step 2 observation; the HTML only lit the bin while hovering).
const double _binGlowSeconds = 0.9;

/// HTML `setTimeout(() => window.showObservationPopup(), 800)`.
const Duration _conclusionDelay = Duration(milliseconds: 800);

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML sprite text stays readable. Floor-object and bin labels are drawn
/// smaller so neighbours stay apart.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;
const double _smallLabelScale = 0.85;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Exact hits on the thin pen include this share of the touch radius.
const double _penMargin = 0.35;

/// Pan slop for grabbing the floor objects (short drags must pick them up).
const double _dragSlop = 8;

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

/// Largest zoom of the fitted scene: the classroom is small in the HTML
/// camera, so it may be drawn up to 1.6x; the sorting floor up to 1.25x.
/// It is never drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.6, 1.25];
const double _minZoom = 0.3;

// ------------------------------------------------- scenario 1: classroom

/// `buildS1()` desk: top `BoxGeometry(8, 0.5, 5)` at y = 3 on four legs
/// `CylinderGeometry(0.2, 0.2, 3)` at (±3.5, 1.5, ±2), back legs first.
const _V _deskTop = _V(0, 3, 0);
const _V _deskTopSize = _V(8, 0.5, 5);
const double _deskLegR = 0.2;
const double _deskLegH = 3;
const List<(double, double)> _deskLegs = [
  (-3.5, -2),
  (3.5, -2),
  (-3.5, 2),
  (3.5, 2),
];

/// Notebook `BoxGeometry(2, 0.2, 2.5)` at (-1.5, 3.35, 0).
const _V _notebook = _V(-1.5, 3.35, 0);
const _V _notebookSize = _V(2, 0.2, 2.5);

/// Pen `CylinderGeometry(0.08, 0.08, 1.8)` lying along x
/// (`rotation.z = π/2`) at (1.5, 3.35, 0).
const _V _pen = _V(1.5, 3.35, 0);
const double _penR = 0.08;
const double _penHalf = 0.9;

/// Chair group at (0, 0, 4): seat `BoxGeometry(3, 0.3, 3)` at y = 1.8 on
/// legs `CylinderGeometry(0.12, 0.12, 1.8)` at (±1.2, 0.9, ±1.2).
const _V _chairSeat = _V(0, 1.8, 4);
const _V _chairSeatSize = _V(3, 0.3, 3);
const double _chairLegR = 0.12;
const double _chairLegH = 1.8;
const List<(double, double)> _chairLegs = [
  (-1.2, 2.8),
  (1.2, 2.8),
  (-1.2, 5.2),
  (1.2, 5.2),
];

// ---------------------------------------------- scenario 2: sorting room

/// `buildS2()` bins: `BoxGeometry(4, 3, 4)` at (x, 1.5, -6), opacity 0.7.
const double _binY = 1.5;
const double _binZ = -6;
const _V _binSize = _V(4, 3, 4);

/// Bins are drawn this see-through (top face lighter) so the sorted objects
/// show inside them.
const double _binOpacity = 0.62;
const double _binTopOpacity = 0.38;

/// HTML `selectFloorItem`: `position.y = 1.6`; `animate()`: `y = 1.6 +
/// sin(Date.now() * 0.005) * 0.15`, `rotation.y += 0.01` per frame.
const double _liftY = 1.6;
const double _bobAmp = 0.15;
const double _bobRate = 5;
const double _spinRate = 0.6;

/// HTML `new TWEEN.Tween(position).to(bin, 600).easing(Quadratic.Out)`.
const double _sortSeconds = 0.6;

/// A dropped object that missed (or hit the wrong bin) glides back to its
/// place on the floor.
const double _returnSeconds = 0.3;

/// A dragged object stays on the 40 x 30 floor, in front of the camera.
const double _floorHalfX = 19;
const double _floorBackZ = -14;
const double _floorFrontZ = 12;

/// The materials of the HTML: the four toolbox icons (S1) and the four
/// bins (S2).
enum _Mat {
  wood('mat_wood', Icons.forest),
  paper('mat_paper', Icons.description),
  plastic('mat_plastic', Icons.local_drink),
  metal('mat_metal', Icons.settings),
  glass('mat_glass', Icons.wine_bar);

  const _Mat(this.key, this.icon);
  final String key;
  final IconData icon;

  /// HTML toolbox colours: `bg-amber-700`, `bg-slate-500`, `bg-blue-600`,
  /// `bg-slate-700` (glass has no toolbox icon).
  Color get toolColor => switch (this) {
    _Mat.wood => _Colors.amber700,
    _Mat.paper => _Colors.slate500,
    _Mat.plastic => _Colors.blue600,
    _Mat.metal => _Colors.slate700,
    _Mat.glass => _Colors.binGlass,
  };

  /// `[['Wood', -9, 0x92400e], ['Metal', -3, 0x64748b], ['Plastic', 3,
  /// 0x2563eb], ['Glass', 9, 0x06b6d4]]` (paper has no bin).
  double get binX => switch (this) {
    _Mat.wood => -9,
    _Mat.metal => -3,
    _Mat.plastic => 3,
    _Mat.glass => 9,
    _Mat.paper => 0,
  };

  Color get binColor => switch (this) {
    _Mat.wood => _Colors.binWood,
    _Mat.metal => _Colors.binMetal,
    _Mat.plastic => _Colors.binPlastic,
    _Mat.glass => _Colors.binGlass,
    _Mat.paper => _Colors.slate500,
  };

  /// Sidebar name of this material's bin.
  String get binKey => 'bin_$name';

  _V get binCenter => _V(binX, _binY, _binZ);
}

/// HTML toolbox order (S1) and bin order (S2).
const List<_Mat> _toolMats = [_Mat.wood, _Mat.paper, _Mat.plastic, _Mat.metal];
const List<_Mat> _bins = [_Mat.wood, _Mat.metal, _Mat.plastic, _Mat.glass];

/// The bins far to near (the outer ones are farther from the camera).
const List<_Mat> _binsByDepth = [
  _Mat.wood,
  _Mat.glass,
  _Mat.metal,
  _Mat.plastic,
];

/// The four classroom objects of Scenario 1 and their materials.
enum _Obj {
  desk('btn_desk', _Mat.wood, _V(-4, 0, -2.5), _V(4, 3.25, 2.5)),
  notebook(
    'btn_notebook',
    _Mat.paper,
    _V(-2.5, 3.25, -1.25),
    _V(-0.5, 3.45, 1.25),
  ),
  pen('btn_pen', _Mat.plastic, _V(0.6, 3.27, -0.08), _V(2.4, 3.43, 0.08)),
  chair('btn_chair', _Mat.metal, _V(-1.5, 0, 2.5), _V(1.5, 1.95, 5.5));

  const _Obj(this.key, this.material, this.min, this.max);

  /// Name (HTML `btn_*`, also the sprite text).
  final String key;
  final _Mat material;

  /// World bounding box of the meshes (HTML `Box3.setFromObject`, here
  /// without the label sprite).
  final _V min;
  final _V max;

  /// Hint after a wrong material: what the object looks like, without
  /// naming its material.
  String get hintKey => 'hint_$name';

  /// Feedback strings (`obs_wood_title`, `obs_wood_desc`, ...).
  String get obsKey => 'obs_${material.name}';

  /// HTML control-banner button colours: `bg-amber-700`, `bg-slate-600`,
  /// `bg-blue-600`, `bg-slate-800`.
  Color get buttonColor => switch (this) {
    _Obj.desk => _Colors.amber700,
    _Obj.notebook => _Colors.slate600,
    _Obj.pen => _Colors.blue600,
    _Obj.chair => _Colors.slate800,
  };

  IconData get icon => switch (this) {
    _Obj.desk => Icons.table_restaurant,
    _Obj.notebook => Icons.menu_book,
    _Obj.pen => Icons.edit,
    _Obj.chair => Icons.chair,
  };

  /// Label anchor. The HTML sprites float above each object, where the
  /// desk's sits between the notebook's and the pen's; here the notebook
  /// and pen labels stand above them, the desk's beside its left end and
  /// the chair's beside its seat, so no label hides an object.
  _V get labelAt => switch (this) {
    _Obj.desk => const _V(-4.25, 3.0, 2.5),
    _Obj.notebook => const _V(-1.5, 4.0, 0),
    _Obj.pen => const _V(1.5, 4.0, 0),
    _Obj.chair => const _V(1.75, 1.8, 4.0),
  };

  /// Which point of the chip sits on [labelAt]: x -1 left edge, 0 centre,
  /// 1 right edge; y 0 centre, 1 bottom edge.
  (double, double) get labelAlign => switch (this) {
    _Obj.desk => (1, 0),
    _Obj.notebook || _Obj.pen => (0, 1),
    _Obj.chair => (-1, 0),
  };

  /// Where the object is tapped: the desk top's front edge, the tops of the
  /// notebook and pen, the chair's seat.
  _V get tapAt => switch (this) {
    _Obj.desk => const _V(0, 3.0, 2.5),
    _Obj.notebook => const _V(-1.5, 3.45, 0),
    _Obj.pen => const _V(1.5, 3.43, 0),
    _Obj.chair => const _V(0, 1.95, 4.0),
  };
}

/// The six floor objects of Scenario 2. The HTML places them all at
/// y = 0.8, which leaves the flat spoon and comb floating 0.7 above the
/// floor; they rest on it here.
enum _Item {
  block('obj_block', _Mat.wood, -11, 1.5, 0.8, 0.9),
  key('obj_key', _Mat.metal, -3.5, 1.5, 0.8, 0.75),
  ball('obj_ball', _Mat.plastic, 4, 1.5, 0.8, 0.8),
  tumbler('obj_tumbler', _Mat.glass, -8, 7.5, 0.8, 0.8),
  spoon('obj_spoon', _Mat.metal, 0, 7.5, 0.12, 0.7),
  comb('obj_comb', _Mat.plastic, 8, 7.5, 0.075, 0.7);

  const _Item(
    this.nameKey,
    this.material,
    this.x,
    this.z,
    this.restY,
    this.radius,
  );

  /// Name (HTML `obj_*`, also the sprite text).
  final String nameKey;
  final _Mat material;
  final double x;
  final double z;

  /// Height of the object's centre when it rests on a floor.
  final double restY;

  /// Rough size (world) for hit tests and shadows.
  final double radius;

  /// Hint after a wrong bin: what the object looks like, without naming
  /// its material.
  String get hintKey => 'hint_$name';

  _V get home => _V(x, restY, z);

  /// Half size of the mesh box (outline).
  _V get half => switch (this) {
    _Item.block => const _V(0.75, 0.75, 0.75),
    _Item.key => const _V(0.75, 0.75, 0.15),
    _Item.ball => const _V(0.8, 0.8, 0.8),
    _Item.tumbler => const _V(0.6, 0.8, 0.6),
    _Item.spoon => const _V(0.4, 0.12, 0.92),
    _Item.comb => const _V(0.7, 0.075, 0.35),
  };
}

/// Resting place [slot] of [it] in the bin of [m]: up to four places (the
/// HTML tweened every object to the bin's centre, y = 2, so the two metal
/// and the two plastic objects sat inside each other).
_V _binSpot(_Mat m, int slot, _Item it) => _V(
  m.binX + (slot.isEven ? -0.85 : 0.85),
  it.restY,
  _binZ + (slot < 2 ? 0.6 : -0.6),
);

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// [v] turned by [a] about the y axis (Three.js `rotation.y`).
_V _rotY(_V v, double a) {
  if (a == 0) return v;
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

/// Where the scene is drawn: the camera's look-at point lands on [center]
/// and the projection is scaled by [zoom] (1 = the HTML camera). The lab
/// fits the scene beside the cards with it.
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
  factory _Cam(_Framing framing) {
    final f = (_target - _eye).unit;
    final r = f.cross(_up).unit;
    return _Cam._(f, r, r.cross(f), framing.center, _focal * framing.zoom);
  }

  const _Cam._(this.f, this.r, this.u, this.center, this.scale);

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  _V get eye => _eye;

  double depth(_V w) => (w - _eye).dot(f);

  /// The design point of [w] (everything in the scenes is in front of the
  /// camera).
  Offset p(_V w) {
    final d = w - _eye;
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

  /// Where the ray through [s] meets the horizontal plane at height [y].
  _V? onPlaneY(Offset s, double y) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - _eye.y) / d.y;
    if (t <= 0) return null;
    return _eye + d * t;
  }
}

/// Box corners: bit 0 = +x, bit 1 = +y, bit 2 = +z. Faces as corner indices
/// and their outward normals.
const List<int> _faceCorners = [
  1, 3, 7, 5, // +x
  0, 4, 6, 2, // -x
  2, 6, 7, 3, // +y
  0, 1, 5, 4, // -y
  4, 5, 7, 6, // +z
  0, 2, 3, 1, // -z
];
const List<_V> _faceNormals = [
  _V(1, 0, 0),
  _V(-1, 0, 0),
  _V(0, 1, 0),
  _V(0, -1, 0),
  _V(0, 0, 1),
  _V(0, 0, -1),
];

/// Corner [i] of the box at [c] with half size [h], turned by [rotY].
_V _corner(_V c, _V h, int i, double rotY) =>
    c +
    _rotY(
      _V(
        (i & 1) != 0 ? h.x : -h.x,
        (i & 2) != 0 ? h.y : -h.y,
        (i & 4) != 0 ? h.z : -h.z,
      ),
      rotY,
    );

/// Is [p] inside the convex quad a-b-c-d (either winding)?
bool _inQuad(Offset p, Offset a, Offset b, Offset c, Offset d) {
  double side(Offset u, Offset v) =>
      (v.dx - u.dx) * (p.dy - u.dy) - (v.dy - u.dy) * (p.dx - u.dx);
  final s1 = side(a, b), s2 = side(b, c), s3 = side(c, d), s4 = side(d, a);
  final neg = s1 < 0 || s2 < 0 || s3 < 0 || s4 < 0;
  final pos = s1 > 0 || s2 > 0 || s3 > 0 || s4 > 0;
  return !(neg && pos);
}

/// Is [p] on the box at [c] (size [size]) as the camera sees it (HTML
/// raycast against a BoxGeometry)?
bool _onBox(Offset p, _Cam cam, _V c, _V size, {double rotY = 0}) {
  final h = size * 0.5;
  final pts = [for (var i = 0; i < 8; i++) cam.p(_corner(c, h, i, rotY))];
  for (var fi = 0; fi < 6; fi++) {
    final n = _rotY(_faceNormals[fi], rotY);
    final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
    if (n.dot(cam.eye - mid) <= 0) continue;
    final k = fi * 4;
    if (_inQuad(
      p,
      pts[_faceCorners[k]],
      pts[_faceCorners[k + 1]],
      pts[_faceCorners[k + 2]],
      pts[_faceCorners[k + 3]],
    )) {
      return true;
    }
  }
  return false;
}

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

/// An object on its way into (or resting in) a bin.
class _Sort {
  _Sort(this.bin, this.from, this.to, this.start, this.spin);

  final _Mat bin;
  final _V from;
  final _V to;
  final double start;

  /// Its turn about y when it was sorted (kept, as in the HTML).
  final double spin;

  /// It has reached its place (the drop sound has played).
  bool landed = false;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  // ------------------------------------------------------------ scenario 1
  /// HTML `State.s1Selected`.
  _Obj? selected;

  /// The object with the yellow selection outline (HTML `setHighlight(…,
  /// 'yellow')`; cleared after a correct match, as `clearHighlight`).
  _Obj? outline;

  /// The object a dragged material icon is over.
  _Obj? hover;

  /// HTML `State.s1Done`.
  final Set<_Obj> identified = {};

  /// The desk was tapped at step 1 / the notebook at step 3 (HTML step
  /// ladder `step 1 → 2`, `step 3 → 4`).
  bool deskPicked = false;
  bool notebookPicked = false;

  // ------------------------------------------------------------ scenario 2
  /// HTML `State.s2Selected`: lifted and bobbing.
  _Item? picked;

  /// The block was tapped at step 1.
  bool blockPicked = false;

  /// Turn of the picked object (HTML `rotation.y += 0.01` per frame).
  double spin = 0;

  /// HTML `State.s2Done_items` with where each object goes.
  final Map<_Item, _Sort> sorted = {};

  /// The object being dragged and where it is (on the plane y = 1.6).
  _Item? dragging;
  _V dragPos = _V.zero;

  /// An object gliding back to its place after a missed drop.
  _Item? returning;
  _V returnFrom = _V.zero;
  double returnStart = 0;

  /// The bin under the dragged object.
  _Mat? hoverBin;

  // --------------------------------------------------------------- flashes
  /// A green / red flash on an S1 object or an S2 bin, until [flashUntil].
  Object? flashTarget;
  Color flashColor = _Colors.hlGreen;
  double flashUntil = -1;

  /// Label chips as last painted (design px): the S1 labels are tapped too
  /// (the HTML sprites are children of their meshes), and the bin labels.
  final Map<Object, Rect> labelRects = {};

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  bool get framingSettled => _framingT >= 1;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    selected = null;
    outline = null;
    hover = null;
    identified.clear();
    deskPicked = false;
    notebookPicked = false;
    picked = null;
    blockPicked = false;
    spin = 0;
    sorted.clear();
    dragging = null;
    returning = null;
    hoverBin = null;
    flashTarget = null;
    flashUntil = -1;
    labelRects.clear();
  }

  /// HTML `animate()`: spin of the picked object, landings, the glide back
  /// and the framing. True when an object has just landed in its bin.
  bool advance(double dt) {
    var landed = false;
    if (picked != null) spin += _spinRate * dt;
    for (final s in sorted.values) {
      if (!s.landed && time - s.start >= _sortSeconds) {
        s.landed = true;
        landed = true;
      }
    }
    if (returning != null && time - returnStart >= _returnSeconds) {
      returning = null;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
    }
    return landed;
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

  /// The camera in the current framing.
  _Cam camera() => _Cam(framing);

  /// The flash colour of [target], while it lasts.
  Color? flashOf(Object target) =>
      flashTarget == target && time < flashUntil ? flashColor : null;

  /// Where [it] rests or is lifted (HTML `selectFloorItem` / `animate`).
  _V liftedPos(_Item it) => picked == it
      ? _V(it.x, _liftY + _bobAmp * math.sin(time * _bobRate), it.z)
      : it.home;

  /// Where [it] is drawn now.
  _V itemPos(_Item it) {
    final s = sorted[it];
    if (s != null) {
      final t = ((time - s.start) / _sortSeconds).clamp(0.0, 1.0);
      return _V.lerp(s.from, s.to, Curves.easeOutQuad.transform(t));
    }
    if (dragging == it) return dragPos;
    final rest = liftedPos(it);
    if (returning == it) {
      final t = ((time - returnStart) / _returnSeconds).clamp(0.0, 1.0);
      return _V.lerp(returnFrom, rest, Curves.easeOut.transform(t));
    }
    return rest;
  }

  double itemSpin(_Item it) => sorted[it]?.spin ?? (picked == it ? spin : 0);

  int binCount(_Mat m) => sorted.values.where((s) => s.bin == m).length;

  // ----------------------------------------------------------- hit tests

  /// The classroom object at [p] (HTML raycast on `s1Group`): a label,
  /// then what is exactly under [p] (the notebook and pen before the desk
  /// they lie on, the chair before the desk), and only then the object
  /// nearest [p] within [touch] (the pen is thin), so the margin around a
  /// small object never takes a tap that lands on the desk itself.
  _Obj? objAt(Offset p, double touch) {
    for (final o in const [_Obj.notebook, _Obj.pen, _Obj.chair, _Obj.desk]) {
      final r = labelRects[o];
      if (r != null && r.contains(p)) return o;
    }
    final cam = camera();
    final a = cam.p(_pen - const _V(_penHalf, 0, 0));
    final b = cam.p(_pen + const _V(_penHalf, 0, 0));
    final penD = _segmentDistance(p, a, b);
    final penThick = _penR * cam.scaleAt(_pen);
    if (_onBox(p, cam, _notebook, _notebookSize)) return _Obj.notebook;
    if (penD <= math.max(penThick, touch * _penMargin)) return _Obj.pen;
    final onChair =
        _onBox(p, cam, _chairSeat, _chairSeatSize) ||
        _chairLegs.any(
          (l) => _onBox(
            p,
            cam,
            _V(l.$1, _chairLegH / 2, l.$2),
            const _V(2 * _chairLegR, _chairLegH, 2 * _chairLegR),
          ),
        );
    if (onChair) return _Obj.chair;
    final onDesk =
        _onBox(p, cam, _deskTop, _deskTopSize) ||
        _deskLegs.any(
          (l) => _onBox(
            p,
            cam,
            _V(l.$1, _deskLegH / 2, l.$2),
            const _V(2 * _deskLegR, _deskLegH, 2 * _deskLegR),
          ),
        );
    if (onDesk) return _Obj.desk;
    final near = <(_Obj, double)>[
      (_Obj.notebook, (p - cam.p(_Obj.notebook.tapAt)).distance),
      (_Obj.pen, penD),
      (_Obj.chair, (p - cam.p(_Obj.chair.tapAt)).distance),
    ]..sort((x, y) => x.$2.compareTo(y.$2));
    return near.first.$2 <= touch ? near.first.$1 : null;
  }

  /// The bin at [p] (its box or its label).
  _Mat? binAt(Offset p) {
    final cam = camera();
    for (final m in _bins) {
      final r = labelRects[m];
      if (r != null && r.contains(p)) return m;
      if (_onBox(p, cam, m.binCenter, _binSize)) return m;
    }
    return null;
  }

  /// The unsorted floor object nearest [p] within reach. On a bin only the
  /// object itself counts, not the touch margin around it.
  _Item? itemAt(Offset p, double touch) {
    final cam = camera();
    final onBin = binAt(p) != null;
    _Item? best;
    var bestD = double.infinity;
    for (final it in _Item.values) {
      if (sorted.containsKey(it)) continue;
      final c = itemPos(it);
      final tight = it.radius * cam.scaleAt(c);
      final reach = onBin ? tight : math.max(tight, touch);
      final d = (p - cam.p(c)).distance;
      if (d <= reach && d < bestD) {
        best = it;
        bestD = d;
      }
    }
    return best;
  }

  /// Design point of a named place in the current framing (used by the
  /// instruction-flow tests): 'desk', 'notebook', 'pen', 'chair', a floor
  /// object ('block', 'key', ...), a bin ('bin_wood', ...) or 'floor'
  /// (empty floor between the S2 objects).
  Offset anchor(String id) {
    final cam = camera();
    for (final o in _Obj.values) {
      if (o.name == id) return cam.p(o.tapAt);
    }
    for (final it in _Item.values) {
      if (it.name == id) return cam.p(itemPos(it));
    }
    for (final m in _bins) {
      if ('bin_${m.name}' == id) {
        return cam.p(m.binCenter + const _V(0, 0, 2));
      }
    }
    if (id == 'floor') return cam.p(const _V(-6.5, 0, 4.5));
    return _designCenter;
  }

  // ---------------------------------------- plain readouts for the tests
  List<String> get identifiedNames => [for (final o in identified) o.name];
  String? get selectedName => selected?.name;
  String? get pickedName => picked?.name;
  List<String> get sortedNames => [for (final it in sorted.keys) it.name];
  Map<String, int> get binCounts => {
    for (final m in _bins) m.name: binCount(m),
  };
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

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a floor object ([canGrab]), so other touches still tap the bins (and
/// pan / zoom the canvas when the camera is unlocked).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _MaterialsLabState
    extends State<Ch6A1IdentifyingAndGroupingObjectsByMaterialsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), the toolbox and the
  /// scene's design box: measured to fit the scene beside the cards and to
  /// map drops into the scene.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch6-a1-canvas');
  final GlobalKey _toolboxKey = GlobalKey(debugLabel: 'ch6-a1-toolbox');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch6-a1-design');

  /// 1-based current step, derived from the scene ([_deriveStep]);
  /// steps.length + 1 once the scenario is done.
  int _step = 1;

  /// The current scenario's conclusion has been scheduled.
  bool _concluded = false;

  /// Touch radius and label size in design px for the current stage scale,
  /// and the canvas's left edge and the tool column's left edge (design px):
  /// labels are kept between them.
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelLeft = 0;
  double _labelRight = _design.width;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// The floor object the current pointer holds, whether it was dragged,
  /// the drag-plane offset of the grab and the last pointer position.
  _Item? _grab;
  bool _moved = false;
  _V _grabOffset = _V.zero;
  Offset _lastPointer = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `#floating-toolbox`: shown throughout Scenario 1.
  bool get _toolboxShown => _lab.isLabActive && _scene.scenario == 0;

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

  /// HTML `animate()`; then one repaint of the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    if (s.advance(dt)) _Sound.drop.play();
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

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// card covers: the tool column, the HUD (sidebar open), the floating
  /// mission card (sidebar collapsed) and the Material Toolbox (S1).
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
      size.height - (open ? _hudBand * context.labScale + 8 : 8) - pad.bottom,
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
    if (_toolboxShown) {
      final box = _toolboxKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize && box.attached) {
        hard.add((box.localToGlobal(Offset.zero) - origin) & box.size);
      }
    }
    _labelLeft = (4 - stage.dx) / fit;
    _labelRight = (size.width - insets.right - stage.dx) / fit;
    final target = _fitFraming(
      _focusItems(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      _maxZoom[_scene.scenario],
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

  /// What the learner must see: the corners of the objects and bins (HTML
  /// camera, zoom 1) and their label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void box(_V min, _V max) {
      final c = (min + max) * 0.5;
      final h = (max - min) * 0.5;
      for (var i = 0; i < 8; i++) {
        items.add((cam.p(_corner(c, h, i, 0)), Rect.zero));
      }
    }

    void label(
      _V at,
      (double, double) align,
      String text, {
      String? sub,
      bool badge = false,
      double scale = 1,
    }) {
      final size = _cache.chipSize(text, sub: sub, scale: scale);
      final chip = _chipOffset(size, align) & size;
      final r = badge ? _labelSize * _badgeR * scale : 0.0;
      items.add((
        cam.p(at),
        Rect.fromLTRB(chip.left, chip.top - r, chip.right + r, chip.bottom),
      ));
    }

    if (_scene.scenario == 0) {
      for (final o in _Obj.values) {
        box(o.min, o.max);
        // Room for the material line an identified object's label gets.
        label(o.labelAt, o.labelAlign, _t(o.key), sub: _t(o.material.key));
      }
    } else {
      for (final m in _bins) {
        box(m.binCenter - _binSize * 0.5, m.binCenter + _binSize * 0.5);
        label(
          _binLabelAt(m),
          (0, 1),
          _t(m.key),
          badge: true,
          scale: _smallLabelScale,
        );
      }
      for (final it in _Item.values) {
        final lifted = _V(it.x, _liftY + _bobAmp, it.z);
        box(it.home - it.half, it.home + it.half);
        box(lifted - it.half, lifted + it.half);
        for (final at in [it.home, lifted]) {
          label(
            _itemLabelAt(it, at),
            (-1, 0),
            _t(it.nameKey),
            scale: _smallLabelScale,
          );
        }
      }
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _step = 1;
      _concluded = false;
      _cardRect = null;
      _grab = null;
      _moved = false;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// The HTML step ladder (`State.step`), derived from what the learner has
  /// done. The HTML moved on only when an action happened at the matching
  /// step, so an object identified by a drop (which never counted as a
  /// selection) or the key picked at step 2 left the steps out of step;
  /// here each step is done once its own goal is reached.
  int _deriveStep() {
    final s = _scene;
    if (s.scenario == 0) {
      if (!s.identified.contains(_Obj.desk)) return s.deskPicked ? 2 : 1;
      if (!s.identified.contains(_Obj.notebook)) {
        return s.notebookPicked ? 4 : 3;
      }
      if (s.identified.length < _Obj.values.length) return 5;
      return 6;
    }
    if (!s.sorted.containsKey(_Item.block)) return s.blockPicked ? 2 : 1;
    if (!s.sorted.containsKey(_Item.key)) return 3;
    if (s.sorted.length < _Item.values.length) return 4;
    return 5;
  }

  /// Rebuilds after a scene event and schedules the conclusion when the
  /// scenario is done (HTML `showObservationPopup()` 800 ms later: the S1
  /// summary, the S2 "Mastery Achieved!" card).
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
    if (_concluded) return;
    final s = _scene;
    final done = s.scenario == 0
        ? s.identified.length == _Obj.values.length
        : s.sorted.length == _Item.values.length;
    if (!done) return;
    _concluded = true;
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: _conclusionDelay,
      heading: () =>
          sc == 0 ? labFormat(_t('sc_complete'), {'n': 1}) : _t('all_complete'),
      // The HTML's S2 card shows only the mastery text; its S2 summary
      // ("This is called classification.") was never shown, so both are.
      body: () => sc == 0
          ? _t('s1_summary')
          : '${_t('s2_summary')}\n\n${_t('all_complete_desc')}',
      extra: () => Builder(
        builder: (context) {
          final f = context.labScale * _lab.fontScale.clamp(0.9, 1.4);
          return sc == 0
              ? _findings(_lab.palette, f, details: true)
              : _groups(_lab.palette, f);
        },
      ),
    );
  }

  // ---------------------------------------------------------- scenario 1

  /// HTML `selectS1Object(obj)` (3D tap or control-banner button).
  void _select(_Obj o) {
    if (_scene.scenario != 0) return;
    _Sound.pop.play();
    _pickObj(o);
    _lab.showToast(
      labFormat(_t('toast_selected'), {'name': _t(o.key)}),
      sound: false,
    );
    _refresh();
  }

  /// The selection itself. A material dropped on an object selects it too
  /// (HTML `onDropItem` sets `State.s1Selected`), and here that counts for
  /// steps 1 and 3 like a tap.
  void _pickObj(_Obj o) {
    final s = _scene;
    s
      ..selected = o
      ..outline = o;
    // `setHighlight` replaces any other highlight.
    if (s.flashTarget is _Obj) s.flashUntil = -1;
    if (_step == 1 && o == _Obj.desk) s.deskPicked = true;
    if (_step == 3 && o == _Obj.notebook) s.notebookPicked = true;
  }

  /// HTML `triggerDropItem(mat)` (toolbox icon tapped, or dropped).
  void _apply(_Mat m) {
    final s = _scene;
    if (s.scenario != 0) return;
    final sel = s.selected;
    if (sel == null) {
      _lab.showToast(_t('toast_pick_first'), isError: true);
      return;
    }
    if (m == sel.material) {
      _Sound.success.play();
      s
        ..identified.add(sel)
        ..outline = null
        ..flashTarget = sel
        ..flashColor = _Colors.hlGreen
        ..flashUntil = s.time + _greenSeconds;
      _lab.showToast(_t('${sel.obsKey}_title'), sound: false);
      _refresh();
      return;
    }
    s
      ..flashTarget = sel
      ..flashColor = _Colors.hlRed
      ..flashUntil = s.time + _redSeconds;
    _lab.showToast(_t(sel.hintKey), isError: true);
  }

  /// A toolbox icon dropped on the scene at [global] (HTML `onDropItem`): on
  /// an object it selects that object first; elsewhere it is used on the
  /// selected object, as a tap on the icon is.
  void _onMatDrop(_Mat m, Offset global) {
    final s = _scene;
    s.hover = null;
    if (s.scenario != 0) return;
    final local = labGlobalToLocal(_designKey, global);
    final o = local == null ? null : s.objAt(local, _touch);
    if (o != null) _pickObj(o);
    _apply(m);
    _refresh();
  }

  /// A toolbox icon dragged over the scene: the object under it is outlined
  /// (the HTML coloured the selected object green / red here, which gave the
  /// answer away before the drop).
  void _onMatMove(Offset global) {
    final local = labGlobalToLocal(_designKey, global);
    _scene.hover = local == null ? null : _scene.objAt(local, _touch);
  }

  /// A tap on the scene: S1 selects the object (HTML raycast); S2 sorts the
  /// selected floor object into the tapped bin.
  void _onStageTap(Offset p) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    if (s.scenario == 0) {
      final o = s.objAt(p, _touch);
      if (o != null) _select(o);
      return;
    }
    if (_grab != null) return;
    final bin = s.binAt(p);
    // A tap on a floor object selected it already (touch-down).
    if (bin == null || s.itemAt(p, 0) != null) return;
    _sortTo(bin);
  }

  // ---------------------------------------------------------- scenario 2

  /// HTML `selectFloorItem(item)`: lifts the object with a yellow outline.
  void _pick(_Item it) {
    final s = _scene;
    if (s.scenario != 1 || s.sorted.containsKey(it)) return;
    _Sound.pop.play();
    s
      ..picked = it
      ..spin = 0;
    if (_step == 1 && it == _Item.block) s.blockPicked = true;
    _lab.showToast(
      labFormat(_t('toast_item_selected'), {'name': _t(it.nameKey)}),
      sound: false,
    );
    _refresh();
  }

  /// HTML `sortSelectedTo(binMat)`.
  void _sortTo(_Mat bin) {
    final s = _scene;
    final it = s.picked;
    if (it == null) {
      _lab.showToast(_t('toast_select_first'), isError: true);
      return;
    }
    if (bin == it.material) {
      _Sound.success.play();
      final spot = _binSpot(bin, s.binCount(bin), it);
      s.sorted[it] = _Sort(bin, s.itemPos(it), spot, s.time, s.spin);
      s
        ..picked = null
        ..dragging = null
        ..returning = null
        ..hoverBin = null
        ..flashTarget = bin
        ..flashColor = _Colors.hlGreen
        ..flashUntil = s.time + _binGlowSeconds;
      _lab.showToast(_t('obs_sort_title'), sound: false);
      _refresh();
      return;
    }
    s
      ..flashTarget = bin
      ..flashColor = _Colors.hlRed
      ..flashUntil = s.time + _redSeconds;
    _lab.showToast(_t(it.hintKey), isError: true);
  }

  /// HTML `pointerdown` raycast: only an unsorted floor object is grabbed.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null || _scene.scenario != 1) {
      return false;
    }
    return _scene.itemAt(event.localPosition, _touch) != null;
  }

  /// Touch-down on a floor object selects it (HTML `selectFloorItem`).
  void _onDown(DragDownDetails d) {
    final it = _scene.itemAt(d.localPosition, _touch);
    _grab = it;
    _moved = false;
    _lastPointer = d.localPosition;
    if (it != null) _pick(it);
  }

  /// The object follows the finger on its lifted plane (the HTML moved a
  /// name badge with the pointer and left the object in place).
  void _onDragStart(DragStartDetails d) {
    final s = _scene;
    final it = _grab;
    if (it == null || s.scenario != 1 || s.sorted.containsKey(it)) return;
    _moved = true;
    final hit = s.camera().onPlaneY(d.localPosition, _liftY);
    _grabOffset = hit == null ? _V.zero : _V(hit.x - it.x, 0, hit.z - it.z);
    s
      ..returning = null
      ..dragging = it
      ..dragPos = _V(it.x, _liftY, it.z);
    _onDragMove(d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) => _onDragMove(d.localPosition);

  void _onDragMove(Offset p) {
    final s = _scene;
    _lastPointer = p;
    if (s.dragging == null) return;
    final hit = s.camera().onPlaneY(p, _liftY);
    if (hit != null) {
      s.dragPos = _V(
        (hit.x - _grabOffset.x).clamp(-_floorHalfX, _floorHalfX),
        _liftY,
        (hit.z - _grabOffset.z).clamp(_floorBackZ, _floorFrontZ),
      );
    }
    s.hoverBin = s.binAt(p);
  }

  void _onDragEnd(DragEndDetails _) => _release(cancel: false);

  void _onDragCancel() => _release(cancel: true);

  /// HTML `pointerup`: dropped on a bin, the object is sorted (or refused);
  /// anywhere else it glides back to its place, still selected.
  void _release({required bool cancel}) {
    final s = _scene;
    final it = _grab;
    final moved = _moved;
    _grab = null;
    _moved = false;
    s.hoverBin = null;
    if (it == null || s.scenario != 1 || s.dragging != it) return;
    final bin = cancel ? null : s.binAt(_lastPointer);
    if (bin != null) _sortTo(bin);
    if (s.sorted.containsKey(it)) return;
    s
      ..returnFrom = s.dragPos
      ..returnStart = s.time
      ..returning = it
      ..dragging = null;
    if (bin == null && !cancel && moved) {
      _lab.showToast(_t('toast_drop_in_bin'), isError: true);
    }
  }

  // -------------------------------------------------------------------- UI

  /// HTML bottom control banner (S1): Desk, Notebook, Pen, Chair Legs.
  List<LabAction> _actions() {
    if (_scene.scenario != 0) return const [];
    return [
      for (final o in _Obj.values)
        LabAction(
          label: _t(o.key),
          icon: o.icon,
          color: o.buttonColor,
          foreground: _Colors.white,
          highlight:
              (_step == 1 && o == _Obj.desk) ||
              (_step == 3 && o == _Obj.notebook),
          silent: true,
          onTap: () => _select(o),
        ),
    ];
  }

  /// Width of the canvas (screen minus the sidebar, as the shell sizes it).
  double _canvasWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (!_lab.isSidebarOpen) return w;
    final min = math.max(180.0, w * 0.2);
    final max = math.max(min, w * 0.5);
    return w - (w * _lab.sidebarFraction).clamp(min, max);
  }

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
        final room = math.max(
          0.0,
          _canvasWidth(context) - inset.left - inset.right,
        );
        // Landscape phones get a two-column toolbox (see [_toolbox]).
        final compact = MediaQuery.sizeOf(context).height < _compactBelow;
        final toolboxWidth = math.min(
          room,
          compact
              ? (room * 0.36).clamp(170.0, 250 * s)
              : (room * 0.3).clamp(160.0, 230 * s),
        );
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.category,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          hud: _t('s${sc + 1}_hud_${_step.clamp(1, data.steps.length + 1)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t(sc == 0 ? 'findings' : 'bin_counter'),
          sidebarExtra: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sc == 0) _findings(p, f) else _binCounter(p, f),
              SizedBox(height: 14 * s),
              LabSectionLabel(
                _t('concept_exp'),
                size: 10.5 * s,
                icon: Icons.format_list_numbered,
              ),
              SizedBox(height: 8 * s),
              _StepsAccordion(
                key: ValueKey('steps-$sc-$_step'),
                steps: data.steps,
                current: _step,
                palette: p,
                scale: s,
                fontScale: f,
                stepLabel: _t('exploration'),
                conceptLabel: _t('concept_focus'),
                actionLabel: _t('action'),
                observationLabel: _t('observation'),
                pendingText: _t('obs_pending'),
              ),
            ],
          ),
          overlays: [
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#floating-toolbox` (top right of the canvas).
            if (_toolboxShown)
              Positioned(
                key: const ValueKey('ch6a1-toolbox-card'),
                top: inset.top,
                right: inset.right,
                child: _toolbox(s, toolboxWidth, compact: compact),
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
          child: DragTarget<_Mat>(
            onWillAcceptWithDetails: (_) =>
                _lab.isLabActive && _scene.scenario == 0,
            onMove: (d) => _onMatMove(d.offset),
            onLeave: (_) => _scene.hover = null,
            onAcceptWithDetails: (d) => _onMatDrop(d.data, d.offset),
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
                        ..onStart = _onDragStart
                        ..onUpdate = _onDragUpdate
                        ..onEnd = _onDragEnd
                        ..onCancel = _onDragCancel,
                    ),
                TapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                      () => TapGestureRecognizer(debugOwner: this),
                      (r) => r.onTapUp = (d) => _onStageTap(d.localPosition),
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

  /// HTML `#floating-toolbox` ("Material Toolbox"): Wood, Paper, Plastic and
  /// Metal; each can be dragged onto an object or tapped.
  ///
  /// On landscape phones ([compact]) the icons sit two by two, so the card
  /// stays short; elsewhere they are stacked, as in the HTML.
  Widget _toolbox(double s, double width, {required bool compact}) {
    final p = _lab.palette;
    final title = _t('toolbox_title');
    final gap = 6 * s;
    final itemWidth = compact ? (width - 20 * s - gap) / 2 : width - 20 * s;
    Widget item(_Mat m) => _toolItem(m, s, itemWidth, compact: compact);
    return SizedBox(
      key: _toolboxKey,
      width: width,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        radius: 16,
        borderColor: _Colors.indigo500.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.back_hand,
                  size: 15 * s,
                  color: p.ink(
                    p.isDark ? _Colors.indigo400 : _Colors.indigo600,
                  ),
                ),
                SizedBox(width: 6 * s),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title, 0.8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5 * s),
            Text(
              _t('toolbox_s1_desc'),
              maxLines: compact ? 2 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * s,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            if (compact)
              for (var i = 0; i < _toolMats.length; i += 2) ...[
                SizedBox(height: gap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: item(_toolMats[i])),
                      SizedBox(width: gap),
                      Expanded(child: item(_toolMats[i + 1])),
                    ],
                  ),
                ),
              ]
            else
              for (final m in _toolMats) ...[SizedBox(height: gap), item(m)],
          ],
        ),
      ),
    );
  }

  Widget _toolItem(_Mat m, double s, double width, {required bool compact}) {
    final label = _t(m.key);
    Widget chip({bool lifted = false, bool dim = false}) => _ToolChip(
      material: m,
      label: label,
      scale: s,
      lifted: lifted,
      dim: dim,
      compact: compact,
    );
    return Draggable<_Mat>(
      data: m,
      maxSimultaneousDrags: _toolboxShown ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: _Sound.pop.play,
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(width: width, child: chip(lifted: true)),
        ),
      ),
      childWhenDragging: chip(dim: true),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          key: ValueKey('ch6a1-mat-${m.name}'),
          borderRadius: BorderRadius.circular(12 * s),
          onTap: () => _apply(m),
          child: chip(),
        ),
      ),
    );
  }

  /// "Material Findings": each classroom object and, once identified, its
  /// material (with the HTML's explanation in the conclusion).
  Widget _findings(LabPalette p, double scale, {bool details = false}) {
    return _FindingsTable(
      rows: [
        for (final o in _Obj.values)
          (
            _t(o.key),
            _scene.identified.contains(o) ? _t(o.material.key) : null,
            details && _scene.identified.contains(o)
                ? _t('${o.obsKey}_desc')
                : null,
          ),
      ],
      objectLabel: _t('tbl_object'),
      materialLabel: _t('tbl_material'),
      palette: p,
      scale: scale,
    );
  }

  /// "Bin Counter" (the HTML step 3 observation): objects in each bin and
  /// on the floor.
  Widget _binCounter(LabPalette p, double scale) {
    final s = _scene;
    return _CounterTable(
      rows: [
        for (final m in _bins) (m.binColor, _t(m.binKey), s.binCount(m)),
        (p.textMuted, _t('on_floor'), _Item.values.length - s.sorted.length),
      ],
      palette: p,
      scale: scale,
    );
  }

  /// The groups the learner made (S2 conclusion): each bin and its objects.
  Widget _groups(LabPalette p, double scale) {
    return _GroupsTable(
      rows: [
        for (final m in _bins)
          (
            m.binColor,
            _t(m.binKey),
            [
              for (final e in _scene.sorted.entries)
                if (e.value.bin == m) _t(e.key.nameKey),
            ].join(', '),
          ),
      ],
      binLabel: _t('tbl_bin'),
      itemsLabel: _t('tbl_items'),
      palette: p,
      scale: scale,
    );
  }
}

/// Label chips (HTML `createTextSprite`): padding, corner radius and the
/// radius of the count badge on a bin label's top-right corner, as
/// fractions of the label size.
const double _chipPadX = 0.6;
const double _chipPadY = 0.3;
const double _chipRadius = 0.45;
const double _badgeR = 0.7;

/// Top-left of a chip of [size] relative to its anchor: [align] x -1 puts
/// the anchor on the chip's left edge, 0 at its centre, 1 on its right
/// edge; y 0 at its middle, 1 on its bottom edge.
Offset _chipOffset(Size size, (double, double) align) => Offset(
  -(align.$1 + 1) / 2 * size.width,
  align.$2 >= 1 ? -size.height : -size.height / 2,
);

/// Label anchor of the bin of [m]: just above its back top edge (the HTML
/// sprite at the bin's centre + 2.5).
_V _binLabelAt(_Mat m) => _V(m.binX, _binY + _binSize.y / 2, _binZ - 2);

/// Label anchor of the floor object [it] at [p]: beside its right side, at
/// its middle (the HTML sprites above the back-row objects covered the
/// bins' lower part).
_V _itemLabelAt(_Item it, _V p) => _V(p.x + it.half.x + 0.3, p.y, p.z);

/// One Material Toolbox icon. Built without the shell's style scope so it
/// can also be the drag feedback.
class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.material,
    required this.label,
    required this.scale,
    this.lifted = false,
    this.dim = false,
    this.compact = false,
  });

  final _Mat material;
  final String label;
  final double scale;

  /// Shown under the finger while dragged.
  final bool lifted;

  /// Left behind in the toolbox while dragged.
  final bool dim;

  /// Narrow item (two per row): no hand icon.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final a = dim ? 0.45 : 1.0;
    final fill = material.toolColor;
    return Container(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: a),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: _Colors.white.withValues(alpha: lifted ? 0.9 : 0.2 * a),
          width: lifted ? 2 : 1,
        ),
        boxShadow: [
          if (lifted)
            BoxShadow(color: fill.withValues(alpha: 0.6), blurRadius: 14 * s),
        ],
      ),
      child: Row(
        children: [
          Icon(
            material.icon,
            size: 16 * s,
            color: _Colors.white.withValues(alpha: a),
          ),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _Colors.white.withValues(alpha: a),
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          if (!compact) ...[
            SizedBox(width: 4 * s),
            Icon(
              Icons.touch_app,
              size: 15 * s,
              color: _Colors.white.withValues(alpha: 0.8 * a),
            ),
          ],
        ],
      ),
    );
  }
}

/// Object | Material table; a pending material shows "?". With details
/// each identified row carries the HTML's explanation below it.
class _FindingsTable extends StatelessWidget {
  const _FindingsTable({
    required this.rows,
    required this.objectLabel,
    required this.materialLabel,
    required this.palette,
    required this.scale,
  });

  /// (object, material or null, explanation or null).
  final List<(String, String?, String?)> rows;
  final String objectLabel;
  final String materialLabel;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
    );
    final body = TextStyle(
      color: p.text,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w600,
    );
    Widget row(
      Widget a,
      Widget b, {
      Widget? below,
      Color? fill,
      bool top = true,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: fill,
          border: top ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(flex: 3, child: a),
                SizedBox(width: 6 * f),
                Expanded(flex: 2, child: b),
              ],
            ),
            if (below != null) ...[SizedBox(height: 3 * f), below],
          ],
        ),
      );
    }

    Text cell(String text, TextStyle style, {bool end = false}) => Text(
      text,
      style: style,
      textAlign: end ? TextAlign.end : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            cell(objectLabel, head),
            cell(materialLabel, head, end: true),
            fill: p.cardBorder.withValues(alpha: 0.3),
            top: false,
          ),
          for (final (name, material, detail) in rows)
            row(
              cell(name, body),
              cell(
                material ?? '?',
                body.copyWith(
                  color: material == null ? p.textMuted : p.success,
                  fontWeight: FontWeight.w800,
                ),
                end: true,
              ),
              below: detail == null
                  ? null
                  : Text(
                      detail,
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 10.5 * f,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Coloured dot, label and count per row (the bin counter).
class _CounterTable extends StatelessWidget {
  const _CounterTable({
    required this.rows,
    required this.palette,
    required this.scale,
  });

  final List<(Color, String, int)> rows;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * f, vertical: 6 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (dot, label, count) in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3 * f),
              child: Row(
                children: [
                  Container(
                    width: 10 * f,
                    height: 10 * f,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8 * f),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 12 * f,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * f),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 13 * f,
                      fontWeight: FontWeight.w800,
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

/// Bin | Objects table (the groups made in Scenario 2).
class _GroupsTable extends StatelessWidget {
  const _GroupsTable({
    required this.rows,
    required this.binLabel,
    required this.itemsLabel,
    required this.palette,
    required this.scale,
  });

  final List<(Color, String, String)> rows;
  final String binLabel;
  final String itemsLabel;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
    );
    Widget row(Widget a, Widget b, {Color? fill, bool top = true}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: fill,
          border: top ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: a),
            SizedBox(width: 6 * f),
            Expanded(flex: 3, child: b),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Text(binLabel, style: head),
            Text(itemsLabel, style: head),
            fill: p.cardBorder.withValues(alpha: 0.3),
            top: false,
          ),
          for (final (dot, bin, items) in rows)
            row(
              Row(
                children: [
                  Container(
                    width: 9 * f,
                    height: 9 * f,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6 * f),
                  Expanded(
                    child: Text(
                      bin,
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11.5 * f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                items,
                style: TextStyle(
                  color: p.text,
                  fontSize: 11.5 * f,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML teacher-board "Conceptual Exploration" accordion: one card per
/// step with its concept, action and observation. The current step is
/// open, done steps show a tick and can be re-opened, future steps are
/// dimmed. A step's observation is shown once the step is done (the HTML
/// showed it before the learner had seen it).
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
    required this.pendingText,
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

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    // Future steps: HTML `opacity-50 pointer-events-none`.
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
                  Text(
                    step.concept,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    step.action,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    past ? step.observation : w.pendingText,
                    style: TextStyle(
                      color: past ? p.text : p.textMuted,
                      fontSize: 11.5 * f,
                      fontWeight: past ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: past ? FontStyle.normal : FontStyle.italic,
                      height: 1.4,
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

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Thick butt-ended lines (legs, the pen, shading bands).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// Thin round-ended lines (grain, ruling, highlights).
  final Paint thin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// The key's ring (round joins, so the polygon reads as a circle).
  final Paint ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path path = Path();

  /// Projected corners of the box being drawn.
  final List<Offset> corners = List<Offset>.filled(8, Offset.zero);
}

/// What the painter makes once and reuses: pens, the label text painters
/// and the spheres' shading. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<String, TextPainter> _subs = {};
  final Map<int, TextPainter> _badges = {};
  final Map<Color, Paint> _spheres = {};
  LabLang? _lang;
  double _labelSize = _labelPx;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeText();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter _text(String text, Color color, double size) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// An object's name (white, HTML sprite text).
  TextPainter label(String text) =>
      _labels[text] ??= _text(text, _Colors.white, _labelSize);

  /// The material found for an object (green, under its name).
  TextPainter sub(String text) =>
      _subs[text] ??= _text(text, _Colors.green400, _labelSize * 0.92);

  /// Size of a label chip (see [_ScenePainter._chip]; a count badge sits
  /// on its corner, outside this size).
  Size chipSize(String text, {String? sub, double scale = 1}) {
    final tp = label(text);
    final sp = sub == null ? null : this.sub(sub);
    final size = _labelSize;
    final w = math.max(tp.width, sp?.width ?? 0) + 2 * size * _chipPadX;
    final h = tp.height + (sp?.height ?? 0) + 2 * size * _chipPadY;
    return Size(w * scale, h * scale);
  }

  /// A bin's count.
  TextPainter badge(int n) =>
      _badges[n] ??= _text('$n', _Colors.slate950, _labelSize * 0.95);

  /// MeshStandardMaterial shading of a unit sphere at the origin in
  /// [color] (drawn scaled and moved into place), made once per colour.
  Paint sphere(Color color) =>
      _spheres[color] ??= Paint()
        ..shader = ui.Gradient.radial(
          const Offset(-0.35, -0.4),
          1.35,
          [labShade(color, 0.45), color, labShade(color, -0.5)],
          const [0, 0.5, 1],
        );

  void _disposeText() {
    for (final tp in [..._labels.values, ..._subs.values, ..._badges.values]) {
      tp.dispose();
    }
    _labels.clear();
    _subs.clear();
    _badges.clear();
  }

  void dispose() {
    _disposeText();
    _spheres.clear();
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

/// [c] with the highlight's emissive colour [tint] added (HTML
/// `emissive.setHex(col); emissiveIntensity = 0.55`).
Color _glow(Color c, Color? tint) {
  if (tint == null) return c;
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r + tint.r * _emissive),
    green: math.min(1.0, c.g + tint.g * _emissive),
    blue: math.min(1.0, c.b + tint.b * _emissive),
  );
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// BoxGeometry centred at [c], turned by [rotY]: the faces turned to the
  /// camera (a convex box needs no sorting), lit, with an optional rim.
  void box(
    _V c,
    _V size,
    Color color, {
    double rotY = 0,
    double opacity = 1,
    double topOpacity = -1,
    double edge = 0.3,
    Color? tint,
  }) {
    final h = size * 0.5;
    final pts = pens.corners;
    for (var i = 0; i < 8; i++) {
      pts[i] = cam.p(_corner(c, h, i, rotY));
    }
    for (var fi = 0; fi < 6; fi++) {
      final n = _rotY(_faceNormals[fi], rotY);
      final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var k = 0; k < 4; k++) {
        _to(path, k, pts[_faceCorners[fi * 4 + k]]);
      }
      path.close();
      final a = fi == 2 && topOpacity >= 0 ? topOpacity : opacity;
      final fill = _glow(_lit(color, n), tint);
      canvas.drawPath(
        path,
        pens.fill..color = fill.withValues(alpha: fill.a * a),
      );
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

  /// HTML `setHighlight` box: the bounds [min]–[max] grown by 0.25 and
  /// pulsing, filled at opacity 0.15 and outlined in [color].
  void outline(_V min, _V max, Color color, double time) {
    final k = 1 + math.sin(time * _pulseRate) * _pulseAmp;
    final c = (min + max) * 0.5;
    final h =
        ((max - min) * 0.5 + const _V(_outlinePad, _outlinePad, _outlinePad)) *
        k;
    final pts = pens.corners;
    for (var i = 0; i < 8; i++) {
      pts[i] = cam.p(_corner(c, h, i, 0));
    }
    for (var fi = 0; fi < 6; fi++) {
      final n = _faceNormals[fi];
      final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var j = 0; j < 4; j++) {
        _to(path, j, pts[_faceCorners[fi * 4 + j]]);
      }
      path.close();
      canvas.drawPath(
        path,
        pens.fill..color = color.withValues(alpha: _outlineFill),
      );
    }
    final line = pens.thin
      ..strokeWidth = 2
      ..color = color;
    for (var i = 0; i < 8; i++) {
      for (final bit in const [1, 2, 4]) {
        if ((i & bit) == 0) canvas.drawLine(pts[i], pts[i | bit], line);
      }
    }
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double _ellipseHalf(_V c, double radius) =>
      (cam.p(c + _V(0, 0, radius)).dy - cam.p(c - _V(0, 0, radius)).dy).abs() /
      2;

  /// Upright CylinderGeometry standing on [bottom] (radii [rTop] /
  /// [rBottom]): side with a highlight and a shadow band, then the top cap.
  /// A [glass] cylinder is see-through with a bright rim.
  void vCylinder(
    _V bottom,
    double rTop,
    double rBottom,
    double height,
    Color color, {
    double opacity = 1,
    Color? tint,
    bool glass = false,
  }) {
    final top = bottom + _V(0, height, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rBottom * cam.scaleAt(bottom), wt = rTop * cam.scaleAt(top);
    final bottomOval = Rect.fromCenter(
      center: pb,
      width: 2 * wb,
      height: 2 * _ellipseHalf(bottom, rBottom),
    );
    final topOval = Rect.fromCenter(
      center: pt,
      width: 2 * wt,
      height: 2 * _ellipseHalf(top, rTop),
    );
    final base = _glow(_lit(color, const _V(0, 0.3, 0.95)), tint);
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = base.withValues(alpha: base.a * opacity),
    );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx - wt * 0.45, pt.dy),
      Offset(pb.dx - wb * 0.45, bottomOval.bottom),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.32)
        ..color = labShade(
          base,
          glass ? 0.6 : 0.25,
        ).withValues(alpha: glass ? 0.7 : opacity),
    );
    canvas.drawLine(
      Offset(pt.dx + wt * 0.75, pt.dy),
      Offset(pb.dx + wb * 0.75, bottomOval.bottom),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.4)
        ..color = labShade(base, -0.4).withValues(alpha: opacity),
    );
    canvas.restore();
    final cap = _glow(_lit(color, const _V(0, 1, 0)), tint);
    canvas.drawOval(
      topOval,
      pens.fill..color = labShade(cap, 0.12).withValues(alpha: cap.a * opacity),
    );
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = glass ? 1.5 : 0.8
        ..color = glass
            ? _Colors.white.withValues(alpha: 0.8)
            : labShade(base, -0.35),
    );
  }

  /// CylinderGeometry lying along x (HTML `rotation.z = π/2`): body,
  /// shaded underside and highlight.
  void rodX(_V c, double half, double radius, Color color, {Color? tint}) {
    final a = cam.p(c - _V(half, 0, 0)), b = cam.p(c + _V(half, 0, 0));
    final w = math.max(1.5, 2 * radius * cam.scaleAt(c));
    final base = _glow(_lit(color, const _V(0, 0.7, 0.7)), tint);
    canvas.drawLine(
      a,
      b,
      pens.bar
        ..strokeWidth = w
        ..color = base,
    );
    canvas.drawLine(
      a.translate(0, w * 0.3),
      b.translate(0, w * 0.3),
      pens.bar
        ..strokeWidth = w * 0.36
        ..color = labShade(base, -0.4),
    );
    canvas.drawLine(
      a.translate(0, -w * 0.25),
      b.translate(0, -w * 0.25),
      pens.bar
        ..strokeWidth = w * 0.25
        ..color = labShade(base, 0.45),
    );
  }

  /// An ellipsoid (SphereGeometry scaled by [rx], [ry], [rz]) at [c], turned
  /// by [rotY]: a shaded ellipse of its outline as the camera sees it.
  void ellipsoid(
    _V c,
    double rx,
    double ry,
    double rz,
    Color color, {
    double rotY = 0,
    Color? tint,
  }) {
    final o = cam.p(c);
    final k = cam.scaleAt(c);
    final cs = math.cos(rotY).abs(), sn = math.sin(rotY).abs();
    final ex = (rx * cs + rz * sn) * k;
    final ez = rx * sn + rz * cs;
    final ey = math.sqrt(ry * ry * _cosPitch2 + ez * ez * _sinPitch2) * k;
    if (ex < 0.3 || ey < 0.3) return;
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(ex, ey);
    canvas.drawCircle(Offset.zero, 1, cache.sphere(_glow(color, tint)));
    canvas.restore();
  }

  /// TorusGeometry(radius, tube) in its own xy plane (facing +z), turned by
  /// [rotY]: the ring as a thick stroke with a metallic highlight.
  void torus(
    _V c,
    double radius,
    double tube,
    Color color, {
    double rotY = 0,
    Color? tint,
  }) {
    const segments = 28;
    final path = pens.path..reset();
    for (var i = 0; i < segments; i++) {
      final a = i * 2 * math.pi / segments;
      _to(
        path,
        i,
        cam.p(
          c + _rotY(_V(radius * math.cos(a), radius * math.sin(a), 0), rotY),
        ),
      );
    }
    path.close();
    final w = 2 * tube * cam.scaleAt(c);
    final base = _glow(_lit(color, const _V(0, 0.45, 0.89)), tint);
    canvas.drawPath(
      path,
      pens.ring
        ..strokeWidth = w
        ..color = base,
    );
    canvas.drawPath(
      path,
      pens.ring
        ..strokeWidth = w * 0.3
        ..color = labShade(base, 0.45),
    );
  }

  /// Soft shadow of a floor object of size [radius] at (x, z), fainter and
  /// wider the higher the object is lifted.
  void shadow(double x, double z, double radius, double lift) {
    final c = _V(x, 0.01, z);
    final o = cam.p(c);
    final r = radius * (1 + lift * 0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: o,
        width: 2 * r * cam.scaleAt(c),
        height: 2 * _ellipseHalf(c, r),
      ),
      pens.shadow
        ..color = _Colors.shadow.withValues(
          alpha: _Colors.shadow.a * (1 - lift * 0.35).clamp(0.3, 1.0),
        ),
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the
/// classroom (desk, notebook, pen, chair), S2 the sorting floor (four bins,
/// six objects).
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

  /// Design x of the canvas's left edge and the tool column's left edge
  /// (scene labels stay between them).
  final double labelLeft;
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    s.labelRects.clear();
    final g = _Gfx(canvas, s.camera(), cache);
    if (s.scenario == 0) {
      _paintClassroom(g);
    } else {
      _paintSorting(g);
    }
  }

  // ---------------------------------------------------------- scenario 1

  /// The highlight colour of [o]: a flash, the outline while a material is
  /// dragged over it, or the selection outline.
  Color? _highlight(_Obj o) {
    final s = scene;
    final flash = s.flashOf(o);
    if (flash != null) return flash;
    if (s.hover == o || s.outline == o) return _Colors.hlYellow;
    return null;
  }

  void _paintClassroom(_Gfx g) {
    final s = scene;
    // `BoxGeometry(40, 0.4, 30)` floor.
    g.box(
      const _V(0, -0.2, 0),
      const _V(40, 0.4, 30),
      _Colors.floorClassroom,
      edge: 0,
    );

    // Desk: legs (back first), then the top with a faint grain.
    final desk = _highlight(_Obj.desk);
    for (final (x, z) in _deskLegs) {
      g.vCylinder(
        _V(x, 0, z),
        _deskLegR,
        _deskLegR,
        _deskLegH,
        _Colors.deskLeg,
        tint: desk,
      );
    }
    g.box(_deskTop, _deskTopSize, _Colors.deskTop, tint: desk, edge: 0.45);
    final grain = _pens.thin
      ..strokeWidth = 1
      ..color = labShade(_Colors.deskTop, -0.35).withValues(alpha: 0.35);
    const top = 3.252;
    for (var z = -2.1; z < 2.4; z += 0.6) {
      final wobble = math.sin(z * 2.7) * 0.08;
      g.canvas.drawLine(
        g.cam.p(_V(-3.9, top, z)),
        g.cam.p(_V(3.9, top, z + wobble)),
        grain,
      );
    }
    if (desk != null) g.outline(_Obj.desk.min, _Obj.desk.max, desk, s.time);

    // Notebook with a few ruled lines.
    final book = _highlight(_Obj.notebook);
    g.box(_notebook, _notebookSize, _Colors.notebook, tint: book, edge: 0.35);
    final rule = _pens.thin
      ..strokeWidth = 1
      ..color = _Colors.notebookLine;
    for (final z in const [-0.8, -0.4, 0.0, 0.4, 0.8]) {
      g.canvas.drawLine(
        g.cam.p(_V(_notebook.x - 0.85, 3.452, z)),
        g.cam.p(_V(_notebook.x + 0.85, 3.452, z)),
        rule,
      );
    }
    if (book != null) {
      g.outline(_Obj.notebook.min, _Obj.notebook.max, book, s.time);
    }

    // Pen.
    final pen = _highlight(_Obj.pen);
    g.rodX(_pen, _penHalf, _penR, _Colors.pen, tint: pen);
    if (pen != null) g.outline(_Obj.pen.min, _Obj.pen.max, pen, s.time);

    // Chair: legs (back first), then the seat.
    final chair = _highlight(_Obj.chair);
    for (final (x, z) in _chairLegs) {
      g.vCylinder(
        _V(x, 0, z),
        _chairLegR,
        _chairLegR,
        _chairLegH,
        _Colors.chairLeg,
        tint: chair,
      );
    }
    g.box(
      _chairSeat,
      _chairSeatSize,
      _Colors.chairSeat,
      tint: chair,
      edge: 0.4,
    );
    if (chair != null) {
      g.outline(_Obj.chair.min, _Obj.chair.max, chair, s.time);
    }

    if (!showLabels) return;
    // HTML `createTextSprite`: dark badge, yellow border, white bold text.
    // An identified object's label shows its material under its name, with
    // a green border ("labels as Wood", step 2 observation).
    for (final o in _Obj.values) {
      final done = s.identified.contains(o);
      s.labelRects[o] = _chip(
        g.canvas,
        g.cam.p(o.labelAt),
        _t(o.key),
        sub: done ? _t(o.material.key) : null,
        border: done ? _Colors.hlGreen : _Colors.spriteBorder,
        align: o.labelAlign,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  Color? _binHighlight(_Mat m) {
    final s = scene;
    final flash = s.flashOf(m);
    if (flash != null) return flash;
    if (s.hoverBin == m) return _Colors.hlYellow;
    return null;
  }

  void _paintSorting(_Gfx g) {
    final s = scene;
    g.box(
      const _V(0, -0.2, 0),
      const _V(40, 0.4, 30),
      _Colors.floorSorting,
      edge: 0,
    );
    for (final it in _Item.values) {
      if (s.sorted.containsKey(it)) continue;
      final p = s.itemPos(it);
      g.shadow(p.x, p.z, it.radius, p.y - it.restY);
    }

    // Bins (far ones first), each after the objects resting inside it.
    for (final m in _binsByDepth) {
      for (final e in s.sorted.entries) {
        if (e.value.bin == m && e.value.landed) {
          _paintItem(g, e.key, s.itemPos(e.key), e.value.spin, null);
        }
      }
      final glow = _binHighlight(m);
      g.box(
        m.binCenter,
        _binSize,
        m.binColor,
        opacity: _binOpacity,
        topOpacity: _binTopOpacity,
        tint: glow,
        edge: 0.7,
      );
      if (glow != null) {
        g.outline(
          m.binCenter - _binSize * 0.5,
          m.binCenter + _binSize * 0.5,
          glow,
          s.time,
        );
      }
    }

    // Floor objects far to near, then the moving ones on top.
    final floor = [
      for (final it in _Item.values)
        if (!s.sorted.containsKey(it) && s.dragging != it && s.returning != it)
          it,
    ]..sort((a, b) => g.cam.depth(b.home).compareTo(g.cam.depth(a.home)));
    for (final it in floor) {
      _paintFloorItem(g, it);
    }
    for (final e in s.sorted.entries) {
      if (!e.value.landed) {
        _paintItem(g, e.key, s.itemPos(e.key), e.value.spin, null);
      }
    }
    for (final it in [?s.returning, ?s.dragging]) {
      _paintFloorItem(g, it);
    }

    if (!showLabels) return;
    for (final m in _bins) {
      s.labelRects[m] = _chip(
        g.canvas,
        g.cam.p(_binLabelAt(m)),
        _t(m.key),
        align: (0, 1),
        scale: _smallLabelScale,
        badge: s.binCount(m),
      );
    }
    for (final it in _Item.values) {
      if (s.sorted.containsKey(it)) continue;
      _chip(
        g.canvas,
        g.cam.p(_itemLabelAt(it, s.itemPos(it))),
        _t(it.nameKey),
        align: (-1, 0),
        scale: _smallLabelScale,
        border: s.picked == it ? _Colors.hlYellow : _Colors.spriteBorder,
      );
    }
  }

  /// An unsorted object at its place; the selected one with its yellow
  /// outline (HTML `setHighlight(mesh, 'yellow')`).
  void _paintFloorItem(_Gfx g, _Item it) {
    final s = scene;
    final p = s.itemPos(it);
    final tint = s.picked == it ? _Colors.hlYellow : null;
    _paintItem(g, it, p, s.itemSpin(it), tint);
    if (tint != null) g.outline(p - it.half, p + it.half, tint, s.time);
  }

  /// The HTML meshes of the six floor objects.
  void _paintItem(_Gfx g, _Item it, _V p, double spin, Color? tint) {
    switch (it) {
      case _Item.block:
        // `BoxGeometry(1.5, 1.5, 1.5)`, 0xd97706.
        g.box(
          p,
          const _V(1.5, 1.5, 1.5),
          _Colors.block,
          rotY: spin,
          tint: tint,
          edge: 0.45,
        );
        // A wood grain on its top (not in the HTML's plain box; the wrong-bin
        // hint mentions it).
        final grain = _pens.thin
          ..strokeWidth = 1
          ..color = labShade(_Colors.block, -0.4).withValues(alpha: 0.6);
        for (final z in const [-0.45, -0.1, 0.25, 0.55]) {
          final wobble = math.sin(z * 5) * 0.06;
          g.canvas.drawLine(
            g.cam.p(p + _rotY(_V(-0.7, 0.752, z), spin)),
            g.cam.p(p + _rotY(_V(0.7, 0.752, z + wobble), spin)),
            grain,
          );
        }
      case _Item.key:
        // `TorusGeometry(0.6, 0.15)`, 0x94a3b8, metalness 0.9.
        g.torus(p, 0.6, 0.15, _Colors.steel, rotY: spin, tint: tint);
      case _Item.ball:
        // `SphereGeometry(0.8)`, 0x3b82f6.
        g.ellipsoid(p, 0.8, 0.8, 0.8, _Colors.ball, tint: tint);
      case _Item.tumbler:
        // `CylinderGeometry(0.6, 0.5, 1.6)`, 0xa5f3fc, opacity 0.6.
        g.vCylinder(
          p - const _V(0, 0.8, 0),
          0.6,
          0.5,
          1.6,
          _Colors.tumbler,
          opacity: 0.6,
          tint: tint,
          glass: true,
        );
      case _Item.spoon:
        // Handle `BoxGeometry(0.25, 0.1, 1.2)` at z 0.4 and bowl
        // `SphereGeometry(0.4)` scaled (1, 0.3, 1.3) at z -0.3; far first.
        final handle = p + _rotY(const _V(0, 0, 0.4), spin);
        final bowl = p + _rotY(const _V(0, 0, -0.3), spin);
        void paintHandle() => g.box(
          handle,
          const _V(0.25, 0.1, 1.2),
          _Colors.steel,
          rotY: spin,
          tint: tint,
          edge: 0.4,
        );
        void paintBowl() => g.ellipsoid(
          bowl,
          0.4,
          0.12,
          0.52,
          _Colors.steel,
          rotY: spin,
          tint: tint,
        );
        if (g.cam.depth(bowl) > g.cam.depth(handle)) {
          paintBowl();
          paintHandle();
        } else {
          paintHandle();
          paintBowl();
        }
      case _Item.comb:
        // Spine `BoxGeometry(1.4, 0.15, 0.3)` at z -0.2 (0xec4899) and nine
        // teeth `BoxGeometry(0.08, 0.1, 0.4)` at x -0.6 … 0.6, z 0.1
        // (0xf472b6); far first.
        final spine = p + _rotY(const _V(0, 0, -0.2), spin);
        final teethMid = p + _rotY(const _V(0, 0, 0.1), spin);
        void paintSpine() => g.box(
          spine,
          const _V(1.4, 0.15, 0.3),
          _Colors.combSpine,
          rotY: spin,
          tint: tint,
          edge: 0.4,
        );
        void paintTeeth() {
          for (var k = 0; k <= 8; k++) {
            g.box(
              p + _rotY(_V(-0.6 + 0.15 * k, 0, 0.1), spin),
              const _V(0.08, 0.1, 0.4),
              _Colors.combTooth,
              rotY: spin,
              tint: tint,
              edge: 0,
            );
          }
        }

        if (g.cam.depth(spine) > g.cam.depth(teethMid)) {
          paintSpine();
          paintTeeth();
        } else {
          paintTeeth();
          paintSpine();
        }
    }
  }

  // ------------------------------------------------------------ labels

  /// HTML `createTextSprite` chip at [at]: [align] picks which point of the
  /// chip sits there (x -1 left edge, 0 centre, 1 right edge; y 0 centre,
  /// 1 bottom edge). An optional [sub] line (green) goes under the text and
  /// a [badge] count beside it. The chip is kept between the canvas's left
  /// edge and the tool column. Returns the painted rect.
  Rect _chip(
    Canvas canvas,
    Offset at,
    String text, {
    String? sub,
    Color border = _Colors.spriteBorder,
    (double, double) align = (0, 0),
    double scale = 1,
    int? badge,
  }) {
    final tp = cache.label(text);
    final sp = sub == null ? null : cache.sub(sub);
    final bp = badge == null ? null : cache.badge(badge);
    final size = cache.labelSize;
    final padY = size * _chipPadY;
    final w = math.max(tp.width, sp?.width ?? 0) + 2 * size * _chipPadX;
    final h = tp.height + (sp?.height ?? 0) + 2 * padY;
    final chip = cache.chipSize(text, sub: sub, scale: scale);
    final o = at + _chipOffset(chip, align);
    var left = o.dx;
    final top = o.dy;
    if (left + chip.width > labelRight - 2) {
      left = labelRight - 2 - chip.width;
    }
    if (left < labelLeft + 2) left = labelLeft + 2;
    canvas.save();
    canvas.translate(left, top);
    canvas.scale(scale);
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(size * _chipRadius),
    );
    canvas.drawRRect(rr, _pens.fill..color = _Colors.spriteBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = border,
    );
    tp.paint(canvas, Offset((w - tp.width) / 2, padY));
    if (sp != null) {
      sp.paint(canvas, Offset((w - sp.width) / 2, padY + tp.height));
    }
    if (bp != null) {
      final c = Offset(w, 0);
      canvas.drawCircle(
        c,
        size * _badgeR,
        _pens.fill..color = _Colors.hlYellow,
      );
      bp.paint(canvas, c - Offset(bp.width / 2, bp.height / 2));
    }
    canvas.restore();
    return Offset(left, top) & chip;
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
