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

/// Class 6 Science • Chapter 5 • Activity 1
/// Non-Standard Units of Length and Their Limitations.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A1-Non_Standard_Units_of_Length_and_Their_Limitations.html`.
///
/// Scenario 1 (The Classroom Table Mystery): Deepa stamps her child-sized
/// handspan end to end across the classroom table (15 handspans), then
/// Hardeep stamps his larger handspan across the same table (11 handspans).
///
/// Scenario 2 (The Farmer's Field): a farmer measures the bottom boundary of
/// the crop field heel-to-toe with his boots (40 feet), then a child with
/// small shoes measures the same boundary (65 feet).
///
/// As in the HTML every action is a button (sidebar, canvas and the floating
/// mission card); the scene shows the units laid end to end.
class Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPage
    extends StatefulWidget {
  const Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPage({super.key});

  @override
  State<Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPage> createState() =>
      _Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises three tones (Web
/// Audio): 'pop' (sine 400 → 800 Hz) → pop.mp3, 'stamp' (triangle
/// 200 → 100 Hz thud) → drop.mp3, 'success' (C–E–G arpeggio) →
/// success.mp3; the shell adds its own tones.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, stamp → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action (shell feedback toasts).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action (shell error toasts).
  wrong('audio/class6/science/error.mp3'),

  /// Length measured / conclusion popup (HTML 'success').
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A measurer is selected (HTML 'pop').
  pop('audio/class6/science/pop.mp3'),

  /// A handspan or footstep is stamped down (HTML 'stamp').
  stamp('audio/class6/science/drop.mp3');

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

/// Tailwind colours used by the HTML (UI and Three.js materials).
abstract final class _Colors {
  /// ZSL yellow (`zsl.yellow`): Enter Lab, Stamp buttons, labels, counter.
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color amber500 = Color(0xFFF59E0B); // Select Hardeep button
  static const Color amber700 = Color(0xFFB45309); // table top 0xb45309
  static const Color amber900 = Color(0xFF78350F); // table legs 0x78350f
  static const Color amber950 = Color(0xFF451A03); // boots, crop rows
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // Select Deepa button
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue500 = Color(0xFF3B82F6); // farmer button, prints
  static const Color blue800 = Color(0xFF1E40AF); // farmer trousers
  static const Color pink500 = Color(0xFFEC4899); // child button, prints
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // Conclude buttons
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D); // grass, farmer shirt
  static const Color rose300 = Color(0xFFFDA4AF); // Deepa's hand, skin
  static const Color yellow300 = Color(0xFFFDE047); // Hardeep's hand
  static const Color yellow400 = Color(0xFFFACC15); // straw hat brim
  static const Color red500 = Color(0xFFEF4444);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155); // classroom floor
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // `zsl.dark`
  static const Color white = Color(0xFFFFFFFF);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xE60F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Scene labels and toast: `bg-slate-950/90` and `/80`.
  static const Color labelBg = Color(0xE6020617);
  static const Color toastBg = Color(0xCC020617);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The canvas is `bg-slate-100 dark:bg-[#020617]`; labels and
/// toasts stay dark with ZSL-yellow text in both themes, as in the HTML.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate600,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.toastBg,
    toastText: _Colors.zslYellow,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66EAB308), // border-zsl-yellow/40
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.zslYellow,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // completed steps (text-green-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.toastBg,
    toastText: _Colors.zslYellow,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66EAB308),
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.zslYellow,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting (px): HTML default 15 px, slider 12 … 24 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 24,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// Changes, all in English and Hindi:
// * The step instructions name the buttons exactly and say when a button
//   must be pressed repeatedly; S1 step 4 and S2 step 3 include the
//   stamping that the HTML moved back to steps 2/3 (see `_Scene.stamp`).
// * The HUD lines lose "below" (the buttons sit above the HUD here) and get
//   a second line for the Hardeep / child stamping (`s1_hud_4b`,
//   `s2_hud_3b`).
// * The scene labels no longer give the answer away: the HTML's English-only
//   'Classroom Table (15 Handspans)' / 'Crop Field Boundary (40 Feet)' become
//   'Classroom Table' / 'Crop Field Boundary'.
// * The "<name> Selected! Ready to Stamp" toast is one string per measurer
//   (Hindi verbs agree: दीपा चुनी गई, हरदीप चुना गया).
// * Subtitle typo 'Measurment' fixed. 'Scenario 2 Complete!' is the S2
//   popup title unless both scenarios are done ('All Scenarios Completed!').

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Non-Standard Units of Length and Their Limitations',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1_opt': 'Scenario 1: The Classroom Table Mystery',
    'scen_2_opt': "Scenario 2: The Farmer's Field",
    's1_desc':
        'To understand that using a non-standard unit like a handspan results in different numerical measurements for the same object when measured by different people.',
    's2_desc':
        'To explore different types of non-standard units (foot length, walking stride) and reinforce why body units cannot measure land reliably.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1':
        'People traditionally used body parts like handspans to measure lengths.',
    's1_a1': "CLICK the 'Select Deepa (Child Hand)' button.",
    's1_o1': 'A child-sized 3D hand model appears next to the classroom table.',
    's1_c2':
        'A handspan is the distance from thumb tip to little finger tip on an outstretched hand.',
    's1_a2': "CLICK 'Stamp Handspan (+1)' button to place the first unit.",
    's1_o2':
        'The hand snaps to the left edge marking count 1. A ghost imprint remains.',
    's1_c3':
        'Units must be placed end-to-end without gaps or overlaps to capture length.',
    's1_a3':
        "KEEP CLICKING 'Stamp Handspan (+1)' until reaching the right edge.",
    's1_o3':
        "Deepa's small hands require exactly 15 handspans to cross the classroom table.",
    's1_c4':
        'Larger body units produce smaller numerical counts for identical lengths.',
    's1_a4':
        "CLICK 'Select Hardeep (Large Hand)', then KEEP CLICKING 'Stamp Handspan (+1)' until his hand reaches the right edge.",
    's1_o4':
        "Because Hardeep's hand is larger, it takes fewer handspans (exactly 11) to cross the table!",
    's1_c5':
        'Non-standard body units vary by person, creating measurement confusion.',
    's1_a5': "REVIEW the comparison findings and CLICK 'Conclude Table Study'.",
    's1_o5':
        'Discrepancy confirms the absolute necessity of standardized SI units like the Metre.',
    // Scenario 2 steps.
    's2_c1':
        'For agricultural land, traditional farmers measured using foot lengths or walking strides.',
    's2_a1': "CLICK the 'Select Farmer (Adult Boots)' button.",
    's2_o1':
        'An adult farmer character appears at the corner of the crop field.',
    's2_c2': 'Stamping boot lengths heel-to-toe captures boundary distance.',
    's2_a2':
        "CLICK 'Stamp Footsteps (+5)' repeatedly along the bottom boundary until the farmer reaches its end.",
    's2_o2':
        "The adult farmer's large boots measure the field edge as exactly 40 feet.",
    's2_c3':
        "A child's smaller foot requires more steps to cover identical distance.",
    's2_a3':
        "CLICK 'Select Child (Small Shoes)', then CLICK 'Stamp Footsteps (+10)' repeatedly along the same boundary until its end.",
    's2_o3':
        "The child's smaller shoes require 65 footsteps to cover the exact same boundary!",
    's2_c4':
        'Land measurement disputes arise when relying on variable body proportions.',
    's2_a4': "REVIEW the land comparison and CLICK 'Conclude Land Study'.",
    's2_o4':
        'Universal mapping requires standardized standard scales like metres and kilometres.',
    // Canvas HUD ("Current Task") lines.
    's1_hud_1':
        "Step 1: Click on Deepa's button to spawn her child-sized 3D hand model.",
    's1_hud_2':
        "Step 2: Click 'Stamp Handspan (+1)' button to snap the first handspan to the table edge.",
    's1_hud_3':
        "Step 3: Keep clicking 'Stamp Handspan (+1)' repeatedly across the wooden table.",
    's1_hud_4':
        "Step 4: Now click Hardeep's button to measure with his larger hand model!",
    's1_hud_4b':
        "Step 4: Keep clicking 'Stamp Handspan (+1)' to measure the same table with Hardeep's larger hand.",
    's1_hud_5':
        'Step 5: Compare the findings: 15 child handspans vs 11 large handspans for the same table.',
    's2_hud_1':
        "Step 1: Click the 'Farmer' button to place him in the crop field.",
    's2_hud_2':
        "Step 2: Click 'Stamp Footsteps' to measure the field boundary heel-to-toe.",
    's2_hud_3':
        "Step 3: Click 'Child' button to test a child's smaller shoes on the same boundary.",
    's2_hud_3b':
        "Step 3: Keep clicking 'Stamp Footsteps (+10)' to measure the same boundary with the child's smaller shoes.",
    's2_hud_4':
        'Step 4: Compare 40 adult footsteps vs 65 child footsteps for the exact same field!',
    // Conclusion popups.
    'sum_s1':
        'You discovered measurement variability: Deepa measured 15 handspans while Hardeep measured 11 handspans for the exact same table. Standard SI units solve this!',
    'sum_s2':
        'Field boundary comparison: 40 adult feet vs 65 child feet. Non-standard land units cause severe commercial confusion.',
    'popup_sc1_title': 'Scenario 1 Complete!',
    'popup_sc2_title': 'All Scenarios Completed!',
    'popup_sc2_done': 'Scenario 2 Complete!',
    // Action buttons.
    'btn_deepa': 'Select Deepa (Child Hand)',
    'btn_stamp_hand': 'Stamp Handspan (+1)',
    'btn_hardeep': 'Select Hardeep (Large Hand)',
    'btn_conclude_sc1': 'Conclude Table Study',
    'btn_farmer': 'Select Farmer (Adult Boots)',
    'btn_stamp_foot': 'Stamp Footsteps (+{n})',
    'btn_child': 'Select Child (Small Shoes)',
    'btn_conclude_sc2': 'Conclude Land Study',
    // Toasts.
    'toast_sel_deepa': 'Deepa Selected! Ready to Stamp',
    'toast_sel_hardeep': 'Hardeep Selected! Ready to Stamp',
    'toast_sel_farmer': 'Farmer Selected! Ready to Stamp',
    'toast_sel_child': 'Child Selected! Ready to Stamp',
    'toast_done_deepa': 'Table Measured: 15 Handspans',
    'toast_done_hardeep': 'Table Measured: 11 Handspans!',
    'toast_done_farmer': 'Boundary Measured: 40 Feet',
    'toast_done_child': 'Boundary Measured: 65 Footsteps!',
    // Stamp counter banner.
    'stamp_count': 'Stamp Count:',
    'name_deepa': 'Deepa',
    'name_hardeep': 'Hardeep',
    'name_farmer': 'Farmer',
    'name_child': 'Child',
    // Scene labels.
    'lbl_table': 'Classroom Table',
    'lbl_field': 'Crop Field Boundary',
    // Sidebar findings and observations.
    'findings': 'Measurement Findings',
    'tbl_who': 'Measured by',
    'tbl_len': 'Length',
    'who_deepa': 'Deepa (child hand)',
    'who_hardeep': 'Hardeep (large hand)',
    'who_farmer': 'Farmer (adult boots)',
    'who_child': 'Child (small shoes)',
    'len_deepa': '{n} handspans',
    'len_hardeep': '{n} handspans',
    'len_farmer': '{n} feet',
    'len_child': '{n} feet',
    'measuring': 'Measuring… {n}',
    'not_measured': 'Not measured yet',
    'observations': 'Observations',
  },
  'hi': {
    'app_title': 'लंबाई के अमानक मात्रक और उनकी सीमाएँ',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: कक्षा की मेज का रहस्य',
    'scen_2_opt': 'परिदृश्य 2: किसान का खेत',
    's1_desc':
        'यह समझना कि बालिश्त जैसे अमानक मात्रकों से नापने पर अलग-अलग लोगों के लिए एक ही वस्तु की माप अलग-अलग आती है।',
    's2_desc':
        'पैर की लंबाई और कदम जैसे अमानक मात्रकों की भिन्नता को जाँचना और यह समझना कि भूमि मापन के लिए ये विश्वसनीय नहीं हैं।',
    's1_c1':
        'प्राचीन काल में लोग लंबाई नापने के लिए हाथ की बालिश्त का उपयोग करते थे।',
    's1_a1': "'दीपा चुनें (बच्चे का हाथ)' बटन पर क्लिक करें।",
    's1_o1': 'दीपा का छोटा 3D हाथ मेज के पास आ जाता है।',
    's1_c2': 'अंगूठे के सिरे से छोटी उंगली के सिरे तक की दूरी एक बालिश्त है।',
    's1_a2': "पहली इकाई रखने के लिए 'बालिश्त लगाएं (+1)' पर क्लिक करें।",
    's1_o2': 'पहला निशान मेज के किनारे पर सेट हो जाता है।',
    's1_c3':
        'सही माप के लिए इकाइयों को बिना खाली स्थान छोड़े सटाकर रखना चाहिए।',
    's1_a3':
        "मेज के दाएँ किनारे तक पहुँचने तक 'बालिश्त लगाएं (+1)' को बार-बार दबाते रहें।",
    's1_o3': 'दीपा के छोटे हाथों से मेज नापने में ठीक 15 बालिश्त लगती हैं।',
    's1_c4': 'बड़े मात्रक से नापने पर इकाइयों की संख्या कम आती है।',
    's1_a4':
        "'हरदीप चुनें (बड़ा हाथ)' दबाएँ, फिर उसका हाथ मेज के दाएँ किनारे तक पहुँचने तक 'बालिश्त लगाएं (+1)' बार-बार दबाते रहें।",
    's1_o4': 'हरदीप का हाथ बड़ा होने के कारण केवल 11 बालिश्त लगती हैं!',
    's1_c5': 'अमानक मात्रक व्यक्ति दर व्यक्ति बदलते हैं।',
    's1_a5': "परिणामों की समीक्षा करें और 'मेज का अध्ययन समाप्त करें' दबाएं।",
    's1_o5': 'इससे मानक SI मात्रकों (मीटर) की आवश्यकता सिद्ध होती है।',
    's2_c1':
        'खेतों को नापने के लिए लोग पारंपरिक रूप से पैरों की लंबाई का उपयोग करते थे।',
    's2_a1': "'किसान चुनें (वयस्क जूते)' बटन पर क्लिक करें।",
    's2_o1': 'किसान खेत के कोने पर आ जाता है।',
    's2_c2': 'जूतों को एड़ी से पंजा सटाकर नापना।',
    's2_a2':
        "खेत की निचली सीमा को अंत तक नापने के लिए 'कदम लगाएं (+5)' बार-बार दबाएं।",
    's2_o2': 'किसान के बड़े जूतों से खेत की लंबाई ठीक 40 पैर आती है।',
    's2_c3': 'छोटे पैर से नापने पर कदमों की संख्या अधिक आती है।',
    's2_a3':
        "'बच्चा चुनें (छोटे जूते)' दबाएँ, फिर उसी सीमा को अंत तक नापने के लिए 'कदम लगाएं (+10)' बार-बार दबाएं।",
    's2_o3': 'बच्चे के छोटे जूतों से उसी सीमा को ढकने में 65 कदम लगते हैं!',
    's2_c4': 'शरीर के अंगों से माप लेने पर मतभेद होते हैं।',
    's2_a4': "तुलना देखें और 'खेत का अध्ययन समाप्त करें' दबाएं।",
    's2_o4': 'सटीक मापन के लिए मानक मात्रक (मीटर/किलोमीटर) आवश्यक हैं।',
    's1_hud_1': 'चरण 1: दीपा का 3D हाथ लाने के लिए दीपा के बटन पर क्लिक करें।',
    's1_hud_2':
        "चरण 2: पहला निशान लगाने के लिए 'बालिश्त लगाएं (+1)' बटन दबाएं।",
    's1_hud_3':
        "चरण 3: मेज के दूसरे छोर तक पहुंचने के लिए 'बालिश्त लगाएं (+1)' बार-बार दबाएं।",
    's1_hud_4':
        'चरण 4: अब हरदीप के बड़े हाथ से नापने के लिए उसके बटन पर क्लिक करें!',
    's1_hud_4b':
        "चरण 4: हरदीप के बड़े हाथ से उसी मेज को नापने के लिए 'बालिश्त लगाएं (+1)' बार-बार दबाएं।",
    's1_hud_5':
        'चरण 5: तुलना करें: दीपा की 15 बालिश्त बनाम हरदीप की 11 बालिश्त।',
    's2_hud_1': 'चरण 1: किसान को खेत में लाने के लिए उसके बटन पर क्लिक करें।',
    's2_hud_2': "चरण 2: खेत की सीमा नापने के लिए 'कदम लगाएं' दबाएं।",
    's2_hud_3':
        'चरण 3: बच्चे के छोटे जूतों से नापने के लिए बच्चे का बटन चुनें।',
    's2_hud_3b':
        "चरण 3: बच्चे के छोटे जूतों से उसी सीमा को नापने के लिए 'कदम लगाएं (+10)' बार-बार दबाएं।",
    's2_hud_4': 'चरण 4: तुलना करें: 40 वयस्क पैर बनाम 65 बच्चे के पैर।',
    'sum_s1':
        'आपने देखा कि एक ही मेज दीपा के लिए 15 बालिश्त और हरदीप के लिए 11 बालिश्त लंबी थी। मानक SI मात्रक इस समस्या को हल करते हैं!',
    'sum_s2':
        'खेत की सीमा की तुलना: 40 वयस्क पैर बनाम 65 बच्चे के पैर। अमानक भूमि मात्रक भारी व्यापारिक असंगति पैदा करते हैं।',
    'popup_sc1_title': 'परिदृश्य 1 पूर्ण हुआ!',
    'popup_sc2_title': 'सभी परिदृश्य सफलतापूर्वक पूर्ण हुए!',
    'popup_sc2_done': 'परिदृश्य 2 पूर्ण हुआ!',
    'btn_deepa': 'दीपा चुनें (बच्चे का हाथ)',
    'btn_stamp_hand': 'बालिश्त लगाएं (+1)',
    'btn_hardeep': 'हरदीप चुनें (बड़ा हाथ)',
    'btn_conclude_sc1': 'मेज का अध्ययन समाप्त करें',
    'btn_farmer': 'किसान चुनें (वयस्क जूते)',
    'btn_stamp_foot': 'कदम लगाएं (+{n})',
    'btn_child': 'बच्चा चुनें (छोटे जूते)',
    'btn_conclude_sc2': 'खेत का अध्ययन समाप्त करें',
    'toast_sel_deepa': 'दीपा चुनी गई! बालिश्त लगाने के लिए तैयार',
    'toast_sel_hardeep': 'हरदीप चुना गया! बालिश्त लगाने के लिए तैयार',
    'toast_sel_farmer': 'किसान चुना गया! कदम लगाने के लिए तैयार',
    'toast_sel_child': 'बच्चा चुना गया! कदम लगाने के लिए तैयार',
    'toast_done_deepa': 'मेज नापी गई: 15 बालिश्त',
    'toast_done_hardeep': 'मेज नापी गई: 11 बालिश्त!',
    'toast_done_farmer': 'सीमा नापी गई: 40 पैर',
    'toast_done_child': 'सीमा नापी गई: 65 कदम!',
    'stamp_count': 'स्टाम्प संख्या:',
    'name_deepa': 'दीपा',
    'name_hardeep': 'हरदीप',
    'name_farmer': 'किसान',
    'name_child': 'बच्चा',
    'lbl_table': 'कक्षा की मेज',
    'lbl_field': 'खेत की सीमा',
    'findings': 'माप के परिणाम',
    'tbl_who': 'किसने नापा',
    'tbl_len': 'लंबाई',
    'who_deepa': 'दीपा (बच्चे का हाथ)',
    'who_hardeep': 'हरदीप (बड़ा हाथ)',
    'who_farmer': 'किसान (वयस्क जूते)',
    'who_child': 'बच्चा (छोटे जूते)',
    'len_deepa': '{n} बालिश्त',
    'len_hardeep': '{n} बालिश्त',
    'len_farmer': '{n} पैर',
    'len_child': '{n} पैर',
    'measuring': 'नापा जा रहा है… {n}',
    'not_measured': 'अभी नापा नहीं गया',
    'observations': 'अवलोकन',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML
/// `ScenariosData[lang][n].steps`).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      List<LabStep> steps(int scenario, int count) => [
        for (var i = 1; i <= count; i++)
          LabStep(
            concept: t('s${scenario}_c$i'),
            action: t('s${scenario}_a$i'),
            observation: t('s${scenario}_o$i'),
          ),
      ];
      return [
        LabScenarioData(
          title: t('scen_1_opt'),
          objective: t('s1_desc'),
          steps: steps(1, _s1Steps),
        ),
        LabScenarioData(
          title: t('scen_2_opt'),
          objective: t('s2_desc'),
          steps: steps(2, _s2Steps),
        ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Steps per scenario (HTML `steps` arrays).
const int _s1Steps = 5, _s2Steps = 4;

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// HTML camera: PerspectiveCamera(45°) at (0, 10, 22) looking at
/// controls.target (0, 1, 0), the same in both scenarios (resetCamera()).
const _V _eye = _V(0, 10, 22);
const _V _lookAt = _V(0, 1, 0);

/// While the sidebar is collapsed the scene slides down this far (design
/// px), so the shell's floating mission card (top left; on phones at most
/// 55 % of the screen height) leaves the table, hands and field in view.
const double _collapsedDrop = 140;

/// The slide takes as long as the sidebar's (380 ms).
const double _framingTime = 0.38;

// ------------------------------------------------- scenario 1: the classroom
// HTML buildScenario1().

/// Floor: CylinderGeometry(16, 16, 0.4) at y −0.2.
const double _floorR = 16, _floorDepth = 0.4;
const int _floorSegments = 64;

/// Table top: BoxGeometry(15, 0.5, 6) at y 3.5, so x runs −7.5 … 7.5.
const double _tableHalfX = 7.5, _tableY = 3.5;
const double _tableHalfY = 0.25, _tableHalfZ = 3;

/// Legs: CylinderGeometry(0.25, 0.25, 3.5) at (±7, 1.75, ±2.5).
const double _legX = 7, _legZ = 2.5, _legR = 0.25;

/// The hand rests at y 3.8, z 2 on the table top and is lifted to y 4.6
/// on its way to the next spot.
const double _handRestY = 3.8, _handLiftY = 4.6, _handZ = 2;

/// Stamp tween (HTML): 380 ms; wobble rotation.z −0.18 and rotation.x −0.1.
const double _stampTime = 0.38, _wobbleZ = -0.18, _wobbleX = -0.1;

/// Ghost imprints: 35 % opacity.
const double _ghostOpacity = 0.35;

// ----------------------------------------------- scenario 2: the crop field
// HTML buildScenario2().

/// Grass: BoxGeometry(20, 0.4, 10) at y −0.2.
const double _grassHalfX = 10, _grassHalfZ = 5, _grassDepth = 0.4;

/// Crop rows: BoxGeometry(18, 0.25, 0.8) at y 0.1, z = −3, −1, 1, 3.
const double _rowHalfX = 9, _rowY = 0.1, _rowHalfY = 0.125, _rowHalfZ = 0.4;
const List<double> _rowZ = [-3, -1, 1, 3];

/// The bottom boundary measured heel-to-toe: x −9 … 9 at z 4.2 (18 units).
const double _boundaryStartX = -9, _boundaryEndX = 9, _boundaryZ = 4.2;

/// Boot imprints: BoxGeometry(0.9 × step, 0.08, 0.35) at y 0.04, 50 %
/// opacity.
const double _printFill = 0.9, _printTopY = 0.08, _printHalfZ = 0.175;
const double _printOpacity = 0.5;

/// The figure walks to its new spot (the HTML moves it in one jump).
const double _walkTime = 0.25;

// ---------------------------------------------------------- canvas overlays

/// The stamp counter sits just below the top-centre toast (logical px at
/// UI scale 1).
const double _counterTop = 40;

/// The canvas copy of the action button sits above the HUD card.
const double _actionAboveHud = 66;

/// Who measures (HTML `State.activeChar`): the unit length (HTML
/// `stepLen`, world units), how many units cover the length (HTML
/// `target`), units added per button press (HTML S2 batches), the model
/// scale and the colour of the hand / boot imprints.
enum _Who {
  /// Deepa's child-sized hand: 15 × 1.0 covers the 15-unit table.
  deepa(scenario: 0, unit: 1, target: 15, batch: 1, scale: 1),

  /// Hardeep's larger hand (scale 1.36): 11 × 1.36 = 14.96.
  hardeep(scenario: 0, unit: 1.36, target: 11, batch: 1, scale: 1.36),

  /// The farmer's boots: 40 × 0.45 covers the 18-unit boundary, 5 a press.
  farmer(scenario: 1, unit: 0.45, target: 40, batch: 5, scale: 1),

  /// The child's shoes (figure scale 0.615): 65 × 0.277 = 18.0, 10 a press.
  child(scenario: 1, unit: 0.277, target: 65, batch: 10, scale: 0.615);

  const _Who({
    required this.scenario,
    required this.unit,
    required this.target,
    required this.batch,
    required this.scale,
  });

  final int scenario;
  final double unit;
  final int target;
  final int batch;
  final double scale;

  /// Hand colour (HTML 0xfda4af / 0xfde047) or boot imprint colour (HTML
  /// 0x3b82f6 / 0xec4899).
  Color get color => switch (this) {
    _Who.deepa => _Colors.rose300,
    _Who.hardeep => _Colors.yellow300,
    _Who.farmer => _Colors.blue500,
    _Who.child => _Colors.pink500,
  };
}

/// Centre x of handspan [slot] (0-based) of [who] laid end to end from the
/// table's left edge. The HTML put the hand's own origin there, half a
/// span to the left; here the thumb tip starts at the edge.
double _slotCentre(_Who who, int slot) =>
    -_tableHalfX + (slot + 0.5) * who.unit;

class _Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPageState
    extends State<Ch5A1NonStandardUnitsOfLengthAndTheirLimitationsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Canvas text and the recorded static scene, reused every frame.
  final _TextCache _texts = _TextCache();
  final _PictureCache _pictures = _PictureCache();

  /// UI scale of the last build (popup table).
  double _uiScale = 1;

  /// Last feedback toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.load(0, collapsed: false);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _texts.dispose();
    _pictures.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update(); the scene also slides with the
  /// sidebar. Only the canvas repaints.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = math.max(0.0, now - s.time);
    s.time = now;
    s.updateTweens();
    final target = _lab.isSidebarOpen ? 0.0 : 1.0;
    if (s.framing != target) {
      final move = dt / _framingTime;
      s.framing = target > s.framing
          ? math.min(target, s.framing + move)
          : math.max(target, s.framing - move);
    }
    _frame.value = now;
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(msg)`; the tones are played by the callers, as in the
  /// HTML ('pop' on selection, 'success' when a length is measured).
  void _toast(String key) {
    _toastKey = key;
    _lab.showToast(_t(key), sound: false);
  }

  /// Re-shows the visible toast (this lab's or the shell's "Scenario
  /// Complete") in the new language after a switch from [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    if (shown == null || shown.isError) return;
    final key = _toastKey;
    final String translated;
    if (key != null && shown.text == labTr(_i18n, previous, key)) {
      translated = _t(key);
    } else if (shown.text ==
        labTr(kLabCommonStrings, previous, 'msg_scenario_complete')) {
      translated = _lab.t('msg_scenario_complete');
    } else {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, sound: false);
    });
  }

  /// HTML `changeScenario(id)` / `resetApp()`: clears the imprints and the
  /// measurer and starts [index] at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index, collapsed: !_lab.isSidebarOpen));
    _lab.resetView(sound: false);
  }

  /// Whether the current step offers [who]'s "Select" button.
  bool _canSelect(_Who who) {
    final s = _scene;
    return switch (who) {
      _Who.deepa => s.scenario == 0 && s.step == 1,
      _Who.hardeep => s.scenario == 0 && s.step == 4 && s.who == _Who.deepa,
      _Who.farmer => s.scenario == 1 && s.step == 1,
      _Who.child => s.scenario == 1 && s.step == 3 && s.who == _Who.farmer,
    };
  }

  /// Whether the current step offers the Stamp button.
  bool get _canStamp {
    final s = _scene;
    final who = s.who;
    if (who == null || s.count >= who.target) return false;
    return switch (who) {
      _Who.deepa => s.step == 2 || s.step == 3,
      _Who.hardeep => s.step == 4,
      _Who.farmer => s.step == 2,
      _Who.child => s.step == 3,
    };
  }

  /// HTML `selectChar(name)`: the hand / figure appears at the start with
  /// a fresh count.
  void _select(_Who who) {
    if (!_canSelect(who)) return;
    _Sound.pop.play();
    setState(() => _scene.select(who));
    _toast('toast_sel_${who.name}');
  }

  /// HTML `stampAction()` (S2: a batch of 5 or 10 per press).
  void _stamp() {
    if (!_canStamp) return;
    final who = _scene.who!;
    _Sound.stamp.play();
    setState(_scene.stamp);
    if (_scene.count >= who.target) {
      _Sound.success.play();
      _toast('toast_done_${who.name}');
    }
  }

  /// HTML "Conclude Table Study" / "Conclude Land Study"
  /// (`validateInvestigation()`): opens the summary; it stays available to
  /// re-open it after the popup is closed.
  void _conclude() {
    final s = _scene;
    final last = _data.steps.length;
    if (s.step < last) return;
    setState(() {
      s
        ..concluded = true
        ..step = last + 1;
    });
    _showConclusion(s.scenario);
  }

  /// HTML conclusion popup: title, the scenario name and its summary, with
  /// the measurement findings below.
  void _showConclusion(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t(
        scenario == 0
            ? 'popup_sc1_title'
            : (_lab.completedScenarios.length >= 2
                  ? 'popup_sc2_title'
                  : 'popup_sc2_done'),
      ),
      heading: () => _scenarioData(_lab.lang)[scenario].title,
      body: () => _t('sum_s${scenario + 1}'),
      extra: () =>
          _findings(_lab.palette, _uiScale * _lab.fontScale.clamp(0.9, 1.4)),
    );
  }

  // ------------------------------------------------------------------- UI

  /// The canvas HUD line (HTML `hud[step - 1]`), with its own line while
  /// Hardeep or the child is stamping.
  String get _hudKey {
    final s = _scene;
    if (s.scenario == 0 && s.step == 4 && s.who == _Who.hardeep) {
      return 's1_hud_4b';
    }
    if (s.scenario == 1 && s.step == 3 && s.who == _Who.child) {
      return 's2_hud_3b';
    }
    final steps = s.scenario == 0 ? _s1Steps : _s2Steps;
    return 's${s.scenario + 1}_hud_${s.step.clamp(1, steps)}';
  }

  /// HTML `#hud-action-box`: the one button the current step needs.
  List<LabAction> _actions() {
    final s = _scene;
    LabAction select(_Who who, String key, Color fill, Color text) => LabAction(
      label: _t(key),
      icon: Icons.person,
      color: fill,
      foreground: text,
      highlight: true,
      silent: true,
      onTap: () => _select(who),
    );
    final stamp = LabAction(
      label: s.scenario == 0
          ? _t('btn_stamp_hand')
          : labFormat(_t('btn_stamp_foot'), {'n': s.who?.batch ?? 0}),
      icon: s.scenario == 0 ? Icons.back_hand : Icons.directions_walk,
      silent: true,
      onTap: _stamp,
    );
    final conclude = LabAction(
      label: _t('btn_conclude_sc${s.scenario + 1}'),
      icon: Icons.check_circle,
      color: _Colors.green500,
      foreground: _Colors.slate950,
      highlight: !s.concluded,
      silent: true,
      onTap: _conclude,
    );
    final last = s.scenario == 0 ? _s1Steps : _s2Steps;
    return [
      if (_canSelect(_Who.deepa))
        select(_Who.deepa, 'btn_deepa', _Colors.indigo500, _Colors.white)
      else if (_canSelect(_Who.hardeep))
        select(_Who.hardeep, 'btn_hardeep', _Colors.amber500, _Colors.slate950)
      else if (_canSelect(_Who.farmer))
        select(_Who.farmer, 'btn_farmer', _Colors.blue500, _Colors.white)
      else if (_canSelect(_Who.child))
        select(_Who.child, 'btn_child', _Colors.pink500, _Colors.white)
      else if (_canStamp)
        stamp
      else if (s.step >= last)
        conclude,
    ];
  }

  /// Length found by [who]: the result, the running count, or not yet.
  String _lengthText(_Who who) {
    final s = _scene;
    final result = s.results[who];
    if (result != null) return labFormat(_t('len_${who.name}'), {'n': result});
    if (s.who == who) return labFormat(_t('measuring'), {'n': s.count});
    return _t('not_measured');
  }

  /// The two measurements of the current scenario, side by side.
  Widget _findings(LabPalette p, double scale) {
    final s = _scene;
    final pair = s.scenario == 0
        ? const [_Who.deepa, _Who.hardeep]
        : const [_Who.farmer, _Who.child];
    return _FindingsTable(
      palette: p,
      scale: scale,
      headLeft: _t('tbl_who'),
      headRight: _t('tbl_len'),
      rows: [
        for (final who in pair)
          _FindingRow(
            _t('who_${who.name}'),
            _lengthText(who),
            swatch: who.color,
            state: s.results.containsKey(who)
                ? _RowState.done
                : (s.who == who ? _RowState.measuring : _RowState.pending),
          ),
      ],
    );
  }

  /// Sidebar extra: the findings table, then the observation of every step
  /// done so far (the HTML accordion's "Observation" lines, shown once
  /// observed).
  Widget _sidebarPanel(LabPalette p, double s, LabScenarioData data) {
    final f = s * _lab.fontScale;
    final done = math.min(_scene.step - 1, data.steps.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _findings(p, f),
        if (done > 0) ...[
          SizedBox(height: 12 * s),
          LabSectionLabel(
            _t('observations'),
            size: 10.5 * s,
            icon: Icons.visibility,
          ),
          SizedBox(height: 6 * s),
          for (var i = 1; i <= done; i++)
            _ObservationLine(
              number: i,
              text: data.steps[i - 1].observation,
              palette: p,
              scale: f,
            ),
        ],
      ],
    );
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
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final who = _scene.who;
        return LabShell(
          controller: _lab,
          icon: Icons.back_hand,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: actions,
          onReset: () => _loadScenario(0),
          // The last task no longer applies once the summary is open.
          showHud: _scene.step <= data.steps.length,
          hud: _t(_hudKey),
          sidebarExtraTitle: _t('findings'),
          sidebarExtra: _sidebarPanel(p, s, data),
          overlays: [
            // HTML `#counter-banner` (top centre, under the toast).
            if (who != null && _lab.isLabActive)
              Positioned(
                top: inset.top + _counterTop * s,
                left: inset.left,
                right: inset.right,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _StampCounter(
                    name: _t('name_${who.name}'),
                    label: _t('stamp_count'),
                    count: _scene.count,
                    palette: p,
                    scale: s,
                  ),
                ),
              ),
            // HTML `#hud-action-box` on the canvas. While the sidebar is
            // collapsed the floating mission card carries the button.
            if (actions.isNotEmpty && _lab.isSidebarOpen && _lab.popup == null)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + _actionAboveHud * s,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(
                      action: actions.first,
                      scale: s,
                      expand: false,
                    ),
                  ),
                ),
              ),
          ],
          stage: _buildStage(p),
        );
      },
    );
  }

  Widget _buildStage(LabPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        // Canvas labels stay readable when the stage is scaled down.
        final labelScale = fit > 0 ? (0.85 / fit).clamp(1.0, 1.8) : 1.0;
        return LabStage(
          designSize: _design,
          child: RepaintBoundary(
            child: CustomPaint(
              size: _design,
              painter: _ScenePainter(
                scene: _scene,
                texts: _texts,
                pictures: _pictures,
                repaint: _frame,
                palette: p,
                showLabels: _lab.showLabels,
                lang: _lab.lang,
                labelScale: labelScale,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------ canvas cards

/// HTML `#counter-banner`: who is measuring and the stamp count.
class _StampCounter extends StatelessWidget {
  const _StampCounter({
    required this.name,
    required this.label,
    required this.count,
    required this.palette,
    required this.scale,
  });

  final String name;
  final String label;
  final int count;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.accent.withValues(alpha: 0.4)),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowSoft,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                color: p.accentInk,
                fontSize: 12 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * s),
              child: Container(width: 1, height: 14 * s, color: p.cardBorder),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
                letterSpacing: labLetterSpacing(label, 0.8),
              ),
            ),
            SizedBox(width: 6 * s),
            Text(
              '$count',
              style: TextStyle(
                color: p.accentInk,
                fontSize: 19 * s,
                fontWeight: FontWeight.w900,
                // HTML `font-mono`: fixed-width digits in the app font.
                fontFeatures: const [ui.FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- sidebar tables

/// Measurement state of a findings row.
enum _RowState { pending, measuring, done }

/// One measurer and the length they found.
@immutable
class _FindingRow {
  const _FindingRow(
    this.label,
    this.value, {
    required this.swatch,
    required this.state,
  });

  final String label;
  final String value;
  final Color swatch;
  final _RowState state;
}

/// The two measurements of a scenario (sidebar and conclusion popup).
class _FindingsTable extends StatelessWidget {
  const _FindingsTable({
    required this.palette,
    required this.scale,
    required this.headLeft,
    required this.headRight,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String headLeft;
  final String headRight;
  final List<_FindingRow> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    TextStyle style(Color color, FontWeight weight, {bool italic = false}) =>
        TextStyle(
          color: color,
          fontSize: 11.5 * f,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          height: 1.3,
        );

    Widget line(Widget left, Widget right, {Color? fill, bool last = false}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 6 * f),
        decoration: BoxDecoration(
          color: fill,
          border: last ? null : Border(bottom: BorderSide(color: p.cardBorder)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: 8 * f),
            Expanded(child: right),
          ],
        ),
      );
    }

    Widget who(_FindingRow r) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9 * f,
          height: 9 * f,
          margin: EdgeInsets.only(top: 3 * f, right: 5 * f),
          decoration: BoxDecoration(
            color: r.swatch,
            shape: BoxShape.circle,
            border: Border.all(color: p.cardBorder),
          ),
        ),
        Flexible(child: Text(r.label, style: style(p.text, FontWeight.w600))),
      ],
    );

    Widget value(_FindingRow r) => switch (r.state) {
      _RowState.done => Text(
        r.value,
        style: style(p.accentInk, FontWeight.w800),
      ),
      _RowState.measuring => Text(
        r.value,
        style: style(p.textStrong, FontWeight.w600),
      ),
      _RowState.pending => Text(
        r.value,
        style: style(p.textMuted, FontWeight.w500, italic: true),
      ),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            Text(headLeft, style: style(p.textMuted, FontWeight.w800)),
            Text(headRight, style: style(p.textMuted, FontWeight.w800)),
            fill: p.bg.withValues(alpha: 0.6),
          ),
          for (var i = 0; i < rows.length; i++)
            line(who(rows[i]), value(rows[i]), last: i == rows.length - 1),
        ],
      ),
    );
  }
}

/// One observed result in the sidebar (HTML accordion "Observation").
class _ObservationLine extends StatelessWidget {
  const _ObservationLine({
    required this.number,
    required this.text,
    required this.palette,
    required this.scale,
  });

  final int number;
  final String text;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * f),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18 * f,
            height: 18 * f,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.info.withValues(alpha: 0.18),
              border: Border.all(color: p.info.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: p.info,
                fontSize: 9.5 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 7 * f),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

// ------------------------------------------------------------- scene model

/// TWEEN.js easings used by the HTML.
typedef _Ease = double Function(double t);

/// TWEEN.Easing.Quadratic.InOut.
double _quadInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;

/// TWEEN.Easing.Sinusoidal.InOut.
double _sineInOut(double t) => 0.5 * (1 - math.cos(math.pi * t));

/// Ease of the sidebar slide (Curves.easeInOutCubic).
double _cubicInOut(double t) =>
    t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

/// TWEEN.Interpolation.Linear through [a] → [b] → [c] at eased [k] (the
/// HTML's `y: [4.6, 3.8]` style array tweens).
double _through(double a, double b, double c, double k) {
  final f = 2 * k;
  return f < 1 ? a + (b - a) * f : b + (c - b) * (f - 1);
}

/// A TWEEN.js tween of one number.
@immutable
class _NumTween {
  const _NumTween(this.from, this.to, this.start, this.duration, this.ease);

  final double from;
  final double to;
  final double start;
  final double duration;
  final _Ease ease;

  double at(double now) =>
      from + (to - from) * ease(((now - start) / duration).clamp(0.0, 1.0));

  bool isDone(double now) => now >= start + duration;
}

/// The HTML stamp tweens of the live hand: x (Quadratic.InOut) to the next
/// spot, y lifted and set down again, and a small wobble
/// (Sinusoidal.InOut), all from wherever the hand was.
@immutable
class _HandTween {
  const _HandTween({
    required this.fromX,
    required this.toX,
    required this.fromY,
    required this.fromRotZ,
    required this.fromRotX,
    required this.start,
  });

  final double fromX;
  final double toX;
  final double fromY;
  final double fromRotZ;
  final double fromRotX;
  final double start;
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based step; steps + 1 once the conclusion was opened.
  int step = 1;

  /// Who is measuring (HTML `State.activeChar`) and their stamp count.
  _Who? who;
  int count = 0;

  /// Lengths measured so far in this scenario.
  final Map<_Who, int> results = {};
  bool concluded = false;

  // Live hand (S1): centre x, height and rotation, and its stamp tween.
  double handX = _slotCentre(_Who.deepa, 0);
  double handY = _handRestY;
  double handRotZ = 0, handRotX = 0;
  _HandTween? handTween;

  // Farmer / child figure (S2) and its walk.
  double farmerX = _boundaryStartX;
  _NumTween? farmerTween;

  /// Scene slide: 0 with the sidebar open, 1 collapsed (linear).
  double framing = 0;

  /// What the recorded static picture shows (see [_PictureCache]).
  Object get pictureKey => (scenario, who, count, farmerX);

  /// HTML `changeScenario(id)`: back to step 1 with no measurer.
  void load(int index, {required bool collapsed}) {
    scenario = index;
    step = 1;
    who = null;
    count = 0;
    results.clear();
    concluded = false;
    handX = _slotCentre(_Who.deepa, 0);
    handY = _handRestY;
    handRotZ = 0;
    handRotX = 0;
    handTween = null;
    farmerX = _boundaryStartX;
    farmerTween = null;
    framing = collapsed ? 1 : 0;
  }

  /// HTML `selectChar(name)`: count 0, imprints cleared, the hand / figure
  /// at the start. Step 1 → 2; selecting Hardeep (S1 step 4) or the child
  /// (S2 step 3) keeps the step (the HTML sent it back to step 2, showing
  /// Deepa's / the farmer's texts during the second measurement).
  void select(_Who w) {
    who = w;
    count = 0;
    if (w.scenario == 0) {
      handX = _slotCentre(w, 0);
      handY = _handRestY;
      handRotZ = 0;
      handRotX = 0;
      handTween = null;
    } else {
      farmerX = _boundaryStartX;
      farmerTween = null;
    }
    if (step == 1) step = 2;
  }

  /// HTML `stampAction()`: one more unit end to end (S2: a batch, stopped
  /// at the end of the boundary; the HTML's last child batch ran on to 70).
  /// The live hand moves on to the next spot, the figure walks on. When the
  /// length is covered: S1 Deepa → step 4, Hardeep → step 5; S2 farmer →
  /// step 3, child → step 4 (the HTML's S2 ladder pointed one step ahead
  /// and ended on a step 5 that does not exist).
  void stamp() {
    final w = who!;
    count = math.min(w.target, count + w.batch);
    if (w.scenario == 0) {
      handTween = _HandTween(
        fromX: handX,
        // The next spot; after the last stamp the hand rests on the last
        // one, at the table's right edge.
        toX: math.min(_slotCentre(w, count), _tableHalfX - w.unit / 2),
        fromY: handY,
        fromRotZ: handRotZ,
        fromRotX: handRotX,
        start: time,
      );
      if (step == 2) step = 3;
    } else {
      farmerTween = _NumTween(
        farmerX,
        math.min(_boundaryStartX + count * w.unit, _boundaryEndX),
        time,
        _walkTime,
        _quadInOut,
      );
    }
    if (count >= w.target) {
      results[w] = count;
      step = switch (w) {
        _Who.deepa => 4,
        _Who.hardeep => 5,
        _Who.farmer => 3,
        _Who.child => 4,
      };
    }
  }

  /// TWEEN.update().
  void updateTweens() {
    final h = handTween;
    if (h != null) {
      final k = ((time - h.start) / _stampTime).clamp(0.0, 1.0);
      final move = _quadInOut(k);
      handX = h.fromX + (h.toX - h.fromX) * move;
      handY = _through(h.fromY, _handLiftY, _handRestY, move);
      final turn = _sineInOut(k);
      handRotZ = _through(h.fromRotZ, _wobbleZ, 0, turn);
      handRotX = _through(h.fromRotX, _wobbleX, 0, turn);
      if (k >= 1) handTween = null;
    }
    final f = farmerTween;
    if (f != null) {
      farmerX = f.at(time);
      if (f.isDone(time)) farmerTween = null;
    }
  }
}

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// Three.js `rotation.x = a` applied to this vector.
  _V rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x, y * c - z * s, y * s + z * c);
  }

  /// Three.js `rotation.z = a` applied to this vector.
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }
}

/// The HTML PerspectiveCamera (45° vertical field of view) at [eye]
/// looking at the OrbitControls target, projected onto the design stage.
@immutable
class _Proj {
  factory _Proj(_V eye, _V target) {
    final f = (target - eye).unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Proj._(eye, f, r, r.cross(f));
  }

  const _Proj._(this.eye, this.f, this.r, this.u);

  /// 280 / tan(22.5°): the 45° fov over the 560 px stage height.
  static const double focal = 675.96;
  static const Offset center = Offset(500, 280);

  final _V eye;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  bool inFront(_V w) => depth(w) > 0.1;

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }
}

/// The lab's only camera (the HTML never moves it outside OrbitControls,
/// which start locked; the shell's zoom tools scale the canvas instead).
final _Proj _proj = _Proj(_eye, _lookAt);

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (10, 20, 15)).
const _V _light = _V(0.3714, 0.7428, 0.5571);
const _V _up = _V(0, 1, 0);
const _V _front = _V(0, 0, 1);

/// Box faces: outward normal, then the bottom-left, bottom-right and
/// top-left corners of the face, in units of the half size.
const List<(_V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(1, 1, -1)),
];

/// HTML hand model (hand-local units, scaled by [_Who.scale]): palm box
/// 0.64 × 0.16 × 0.5 at (0.18, 0.12, −0.05); thumb along −x, four fingers
/// along +z, each a 0.08-radius rod with a round tip. The thumb is 0.08
/// shorter than in the HTML so the span runs exactly from the thumb tip
/// (x −0.5) to the little finger's outer edge (x +0.5): one unit.
const _V _palmCentre = _V(0.18, 0.12, -0.05);
const _V _palmHalf = _V(0.32, 0.08, 0.25);
const double _fingerR = 0.08;
const List<(_V, _V)> _fingers = [
  (_V(-0.14, 0.12, -0.05), _V(-0.42, 0.12, -0.05)), // thumb
  (_V(-0.06, 0.12, 0.2), _V(-0.06, 0.12, 0.66)), // index
  (_V(0.1, 0.12, 0.2), _V(0.1, 0.12, 0.72)), // middle
  (_V(0.26, 0.12, 0.2), _V(0.26, 0.12, 0.68)), // ring
  (_V(0.42, 0.12, 0.2), _V(0.42, 0.12, 0.62)), // little finger
];

/// Anchor of the field label: above the back edge of the field, clear of
/// the figure walking along the front boundary.
const _V _fieldLabelAt = _V(0, 2.6, -_grassHalfZ);

/// Label chip padding (HTML `px-3 py-1.5`, at the 12 px label size).
const double _labelPadX = 12, _labelPadY = 6;

/// Paints the HTML Three.js scene: the classroom floor, table, ghost
/// imprints and live hand (S1); the crop field, boot imprints and the
/// farmer / child figure (S2); then the floating labels. Everything but
/// the moving hand and the labels is recorded once per change
/// ([_PictureCache]) and replayed every frame.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required this.pictures,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final _PictureCache pictures;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    canvas.drawRect(labBleed(size), _fill);
    canvas.save();
    canvas.translate(0, _collapsedDrop * _cubicInOut(s.framing));
    canvas.drawPicture(pictures.get(s.pictureKey, _record));
    final who = s.who;
    if (s.scenario == 0 && who != null) {
      _hand(canvas, s.handX, s.handY, who, s.handRotZ, s.handRotX);
    }
    if (showLabels) {
      if (s.scenario == 0) {
        // HTML lbl-table at (0, 4.5, 0), above the middle of the table.
        _label(canvas, 'lbl_table', const _V(0, 4.5, 0));
      } else {
        // HTML lbl-field sat at (0, 1.8, 0), mid-field, where the walking
        // figure's head passes under it; here it floats above the back edge.
        _label(canvas, 'lbl_field', _fieldLabelAt);
      }
    }
    canvas.restore();
  }

  /// The static part of the scene for [_Scene.pictureKey].
  void _record(Canvas c) {
    if (scene.scenario == 0) {
      _classroom(c);
    } else {
      _field(c);
    }
  }

  // ------------------------------------------------------------ scenario 1

  void _classroom(Canvas c) {
    // Floor disc: its side, then its top.
    _disc(c, -_floorDepth, labShade(_Colors.slate700, -0.4));
    _disc(c, 0, _lit(_Colors.slate700, _up));
    // The table's shadow on the floor (cast by the key light).
    _shadowHull(c, [
      for (final x in const [-_tableHalfX, _tableHalfX])
        for (final z in const [-_tableHalfZ, _tableHalfZ])
          _proj.p(_onFloor(_V(x, _tableY, z))),
    ], 0.3);
    // Legs: the back pair, then the front pair; then the table top.
    for (final z in const [-_legZ, _legZ]) {
      for (final x in const [-_legX, _legX]) {
        _cylinder(c, _V(x, 0, z), _legR, _tableY, _Colors.amber900);
      }
    }
    _box(
      c,
      const _V(0, _tableY, 0),
      const _V(_tableHalfX, _tableHalfY, _tableHalfZ),
      _Colors.amber700,
    );
    // Ghost imprints, laid end to end from the left edge. They lie on the
    // table top only, so their 35 % opacity is mixed with its colour.
    final who = scene.who;
    if (who != null) {
      final table = _lit(_Colors.amber700, _up);
      for (var i = 0; i < scene.count; i++) {
        _hand(c, _slotCentre(who, i), _handRestY, who, 0, 0, over: table);
      }
    }
  }

  /// A hand at centre x [cx], height [y], turned by [rotZ] / [rotX]. With
  /// [over], it is a ghost imprint mixed into that surface colour.
  void _hand(
    Canvas c,
    double cx,
    double y,
    _Who who,
    double rotZ,
    double rotX, {
    Color? over,
  }) {
    final k = who.scale;
    final origin = _V(cx, y, _handZ);
    _V turn(_V v) => v.rotZ(rotZ).rotX(rotX);
    _V world(_V v) => turn(v * k) + origin;
    Color tone(Color lit) =>
        over == null ? lit : Color.lerp(over, lit, _ghostOpacity)!;
    _boxWith(c, world, turn, _palmCentre, _palmHalf, who.color, tone: tone);
    for (final (a, b) in _fingers) {
      final wa = world(a), wb = world(b);
      final width = 2 * _fingerR * k * _proj.scaleAt((wa + wb) * 0.5);
      final pa = _proj.p(wa), pb = _proj.p(wb);
      _stroke
        ..strokeWidth = width + 1.2
        ..color = tone(labShade(who.color, -0.45));
      c.drawLine(pa, pb, _stroke);
      _stroke
        ..strokeWidth = width
        ..color = tone(_lit(who.color, _up));
      c.drawLine(pa, pb, _stroke);
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _field(Canvas c) {
    _box(
      c,
      const _V(0, -_grassDepth / 2, 0),
      const _V(_grassHalfX, _grassDepth / 2, _grassHalfZ),
      _Colors.green700,
    );
    for (final z in _rowZ) {
      _box(
        c,
        _V(0, _rowY, z),
        const _V(_rowHalfX, _rowHalfY, _rowHalfZ),
        _Colors.amber950,
      );
    }
    // The bottom boundary being measured (x −9 … 9 at z 4.2).
    _stroke
      ..strokeWidth = 1.5
      ..color = _Colors.zslYellow.withValues(alpha: 0.45);
    labDashedLine(
      c,
      _proj.p(const _V(_boundaryStartX, 0.01, _boundaryZ)),
      _proj.p(const _V(_boundaryEndX, 0.01, _boundaryZ)),
      _stroke,
      dash: 6,
      gap: 5,
    );
    final who = scene.who;
    if (who == null) return;
    // Boot imprints heel-to-toe from the start of the boundary, mixed into
    // the grass colour (50 % opacity).
    final grass = _lit(_Colors.green700, _up);
    final print = Color.lerp(grass, who.color, _printOpacity)!;
    _fill
      ..shader = null
      ..color = print;
    // A thin darker edge keeps the units countable where they meet.
    _stroke
      ..strokeWidth = 0.8
      ..color = labShade(print, -0.45);
    final half = who.unit * _printFill / 2;
    for (var i = 0; i < scene.count; i++) {
      final x = _boundaryStartX + (i + 0.5) * who.unit;
      final a = _proj.p(_V(x - half, _printTopY, _boundaryZ + _printHalfZ));
      final b = _proj.p(_V(x + half, _printTopY, _boundaryZ + _printHalfZ));
      final d = _proj.p(_V(x + half, _printTopY, _boundaryZ - _printHalfZ));
      final e = _proj.p(_V(x - half, _printTopY, _boundaryZ - _printHalfZ));
      _path
        ..reset()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(d.dx, d.dy)
        ..lineTo(e.dx, e.dy)
        ..close();
      c
        ..drawPath(_path, _fill)
        ..drawPath(_path, _stroke);
    }
    _farmer(c, scene.farmerX, who.scale);
  }

  /// HTML farmerGroup (the child is the same figure at scale 0.615): boots,
  /// trousers, shirt and arms, head and straw hat.
  void _farmer(Canvas c, double x, double k) {
    _V world(_V v) => _V(x + v.x * k, v.y * k, _boundaryZ + v.z * k);
    _V same(_V v) => v;
    final feet = world(const _V(0, 0, 0.05));
    final px = _proj.scaleAt(feet);
    labGroundShadow(
      c,
      _proj.p(feet),
      1.3 * k * px,
      0.45 * k * px,
      opacity: 0.35,
    );
    for (final side in const [-0.25, 0.25]) {
      _boxWith(
        c,
        world,
        same,
        _V(side, 0.125, 0.1),
        const _V(0.175, 0.125, 0.25),
        _Colors.amber950,
      );
    }
    for (final side in const [-0.25, 0.25]) {
      _rod(c, world(_V(side, 0.3, 0)), world(_V(side, 1.6, 0)), 0.18 * k);
    }
    _boxWith(
      c,
      world,
      same,
      const _V(0, 2.3, 0),
      const _V(0.45, 0.65, 0.275),
      _Colors.green700,
    );
    for (final side in const [-0.58, 0.58]) {
      _rod(
        c,
        world(_V(side, 1.76, 0)),
        world(_V(side, 2.84, 0)),
        0.14 * k,
        color: _Colors.green700,
      );
    }
    final head = world(const _V(0, 3.3, 0));
    labSphere(
      c,
      _proj.p(head),
      0.38 * k * _proj.scaleAt(head),
      _Colors.rose300,
    );
    // Straw hat: brim (r 0.7, seen from above) and dome.
    final brim = world(const _V(0, 3.6, 0));
    final squash = (brim - _proj.eye).unit.y.abs();
    final brimW = 2 * 0.7 * k * _proj.scaleAt(brim);
    final brimRect = Rect.fromCenter(
      center: _proj.p(brim),
      width: brimW,
      height: brimW * squash,
    );
    _fill
      ..shader = null
      ..color = _lit(_Colors.yellow400, _up);
    c.drawOval(brimRect, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.yellow400, -0.4);
    c.drawOval(brimRect, _stroke);
    final dome = world(const _V(0, 3.7, 0));
    labSphere(
      c,
      _proj.p(dome),
      0.35 * k * _proj.scaleAt(dome),
      _Colors.zslYellow,
    );
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.8 + directional 0.9, toned down to keep the colours).
  Color _lit(Color c, _V n) {
    final i = 0.62 + 0.5 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Axis-aligned box centred at [centre] with half sizes [half].
  void _box(Canvas c, _V centre, _V half, Color color) {
    _V same(_V v) => v;
    _boxWith(c, same, same, centre, half, color);
  }

  /// Box in a local frame: [world] maps local points, [turn] local
  /// directions; faces turned away from the camera are skipped. [tone]
  /// adjusts each lit face colour (ghost imprints).
  void _boxWith(
    Canvas c,
    _V Function(_V) world,
    _V Function(_V) turn,
    _V centre,
    _V half,
    Color color, {
    Color Function(Color)? tone,
  }) {
    _V corner(_V s) =>
        world(centre + _V(s.x * half.x, s.y * half.y, s.z * half.z));
    for (final (n, bl, br, tl) in _boxFaces) {
      final normal = turn(n);
      if (normal.dot(_proj.eye - corner(n)) <= 0) continue;
      final pBL = _proj.p(corner(bl)), pBR = _proj.p(corner(br));
      final pTL = _proj.p(corner(tl)), pTR = _proj.p(corner(br + tl - bl));
      _path
        ..reset()
        ..moveTo(pBL.dx, pBL.dy)
        ..lineTo(pBR.dx, pBR.dy)
        ..lineTo(pTR.dx, pTR.dy)
        ..lineTo(pTL.dx, pTL.dy)
        ..close();
      final lit = _lit(color, normal);
      _fill
        ..shader = null
        ..color = tone == null ? lit : tone(lit);
      c.drawPath(_path, _fill);
      final edge = labShade(color, -0.5).withValues(alpha: 0.35);
      _stroke
        ..strokeWidth = 0.8
        ..color = tone == null ? edge : tone(edge);
      c.drawPath(_path, _stroke);
    }
  }

  /// Upright rod (cylinder seen from the front) from [a] to [b], radius
  /// [r] world units: a rounded bar with a darker outline.
  void _rod(Canvas c, _V a, _V b, double r, {Color color = _Colors.blue800}) {
    final width = 2 * r * _proj.scaleAt((a + b) * 0.5);
    final pa = _proj.p(a), pb = _proj.p(b);
    _stroke
      ..strokeWidth = width + 1.2
      ..color = labShade(color, -0.5);
    c.drawLine(pa, pb, _stroke);
    _stroke
      ..strokeWidth = width
      ..color = _lit(color, _front);
    c.drawLine(pa, pb, _stroke);
  }

  /// Horizontal disc of the floor (radius 16) at height [y].
  void _disc(Canvas c, double y, Color color) {
    _path.reset();
    for (var i = 0; i < _floorSegments; i++) {
      final a = i / _floorSegments * math.pi * 2;
      final o = _proj.p(_V(math.cos(a) * _floorR, y, math.sin(a) * _floorR));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    _fill
      ..shader = null
      ..color = color;
    c.drawPath(_path, _fill);
  }

  /// Upright cylinder standing at [base] (CylinderGeometry look): side
  /// silhouette with a lit gradient and its top cap.
  void _cylinder(Canvas c, _V base, double r, double len, Color color) {
    final top = base + _up * len;
    final pts = <Offset>[];
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final rim = _V(math.cos(a) * r, 0, math.sin(a) * r);
      pts
        ..add(_proj.p(base + rim))
        ..add(_proj.p(top + rim));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    final mid = _proj.p(base + _up * (len / 2));
    final half = r * _proj.scaleAt(base + _up * (len / 2)) * 1.1;
    _fill.shader = ui.Gradient.linear(
      mid - Offset(half, 0),
      mid + Offset(half, 0),
      [
        labShade(color, -0.4),
        labShade(color, 0.3),
        color,
        labShade(color, -0.45),
      ],
      const [0, 0.35, 0.62, 1],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    c.drawPath(_path, _fill);
    _fill.shader = null;
  }

  /// Where the key light casts [w] onto the floor (y = 0).
  _V _onFloor(_V w) => _V(w.x - w.y * 10 / 20, 0.01, w.z - w.y * 15 / 20);

  void _shadowHull(Canvas c, List<Offset> pts, double opacity) {
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _shadow.color = LabInk.black.withValues(alpha: opacity);
    c.drawPath(_path, _shadow);
  }

  // ---------------------------------------------------------------- labels

  /// HTML floating label (`#lbl-table` / `#lbl-field`): dark chip with
  /// yellow text, its bottom centre on the projected point.
  void _label(Canvas c, String key, _V at) {
    if (!_proj.inFront(at)) return;
    final k = labelScale;
    final text = labTr(_i18n, lang, key);
    final tp = texts.get(
      text,
      size: 12 * k,
      color: palette.labelText,
      weight: FontWeight.w800,
      letterSpacing: labLetterSpacing(text, 0.3 * k),
    );
    final o = _proj.p(at);
    final w = tp.width + 2 * _labelPadX * k;
    final h = tp.height + 2 * _labelPadY * k;
    final rect = Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * k));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = palette.labelText.withValues(alpha: 0.5);
    c.drawRRect(rr, _stroke);
    tp.paint(c, Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// The recorded static scene, re-recorded only when its key changes (a
/// stamp, a new measurer, the figure walking). Owned (and disposed) by the
/// page State.
class _PictureCache {
  ui.Picture? _picture;
  Object? _key;

  ui.Picture get(Object key, void Function(Canvas canvas) record) {
    final cached = _picture;
    if (cached != null && key == _key) return cached;
    final recorder = ui.PictureRecorder();
    record(Canvas(recorder));
    cached?.dispose();
    _key = key;
    return _picture = recorder.endRecording();
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
    _key = null;
  }
}

/// TextPainters for the canvas text, laid out once and reused every frame.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final key =
        '$text|$size|${color.toARGB32()}|${weight.value}|$letterSpacing';
    return _painters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            letterSpacing: letterSpacing,
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
