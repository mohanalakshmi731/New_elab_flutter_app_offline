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

/// Class 6 Science • Chapter 5 • Activity 5
/// Understanding Reference Points and Relative Position.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A5-Understanding_Reference_Points_and_Relative_Position.html`.
///
/// Scenario 1 (The School and The Garden): measure from Deepa's house to the
/// school and to the garden; the reference point then moves to Tasneem's
/// house and the learner measures again. Compare Results shows that which
/// place is "closer" depends on the reference point.
///
/// Scenario 2 (Drawing the Kabaddi Court): Hardeep and Padma each place a
/// cone 7 steps from where they stand, and the cones land in different
/// places. Measured from one shared central flag, two cones (7 steps North,
/// 10 steps East) mark out the court.
///
/// The Three.js town and playground are redrawn by a CustomPainter through
/// a perspective projection of the same camera (fov 45°, same position and
/// look-at).
class Ch5A5UnderstandingReferencePointsAndRelativePositionPage
    extends StatefulWidget {
  const Ch5A5UnderstandingReferencePointsAndRelativePositionPage({super.key});

  @override
  State<Ch5A5UnderstandingReferencePointsAndRelativePositionPage>
  createState() => _ReferenceLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three Web Audio tones: `pop`
/// (every UI click, the sidebar, scenario change, Enter Lab), `measure` (a
/// rising 300 → 600 Hz sweep on every measuring button) and `success`
/// (Compare Results, the last cone and the summary). `measure` is mapped to
/// the closest bundled tone, the rising pickup.mp3; correct.mp3 and
/// error.mp3 are the shell's feedback tones (wrong actions only).
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`, measure → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// HTML `pop`: clicks, sidebar, scenario change, curtain.
  pop('audio/class6/science/pop.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// Rope let go in the wrong place, wrong person tapped.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: Compare Results, the east cone, the summary popup.
  success('audio/class6/math/success.mp3'),

  /// HTML `measure`: a measuring line or a cone is placed, a reference
  /// point is selected.
  measure('audio/class6/science/pickup.mp3');

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
  static const Color zslYellow = Color(0xFFEAB308); // tailwind `zsl.yellow`
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color purple300 = Color(0xFFD8B4FE);
  static const Color cyan300 = Color(0xFF67E8F9);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color pink300 = Color(0xFFF9A8D4);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// Scene background: `#canvas-wrapper` `dark:bg-[#020617]` / `bg-slate-100`
  /// (`scene.background` 0x020617 / 0xf1f5f9 in `setTheme`).
  static const Color skyDark = slate950;
  static const Color skyLight = slate100;

  /// `PlaneGeometry(30, 30)`: town 0x0f172a, playground 0x064e3b.
  static const Color groundTown = slate900;
  static const Color groundField = Color(0xFF064E3B);

  /// `GridHelper(30, 30, centre, 0x1e293b)`: town centre lines 0x6366f1,
  /// playground 0x06b6d4.
  static const Color gridLine = slate800;
  static const Color gridTown = indigo500;
  static const Color gridField = Color(0xFF06B6D4);

  /// `createHouse`: wall 0xe2e8f0; roofs 0xf59e0b (Deepa), 0xa855f7
  /// (Tasneem). The girls wear their house colours.
  static const Color houseWall = slate200;
  static const Color deepa = amber500;
  static const Color tasneem = Color(0xFFA855F7);

  /// `createSchool`: block 0xc7d2fe, tower 0x818cf8, roof 0x4f46e5.
  static const Color schoolBlock = Color(0xFFC7D2FE);
  static const Color schoolTower = indigo400;
  static const Color schoolRoof = indigo600;

  /// `createGarden`: fence 0xb45309, cone tree 0x10b981, round tree
  /// 0x059669.
  static const Color fence = Color(0xFFB45309);
  static const Color coneTree = emerald500;
  static const Color roundTree = emerald600;

  /// `createCharacter`: head 0xfde047; Hardeep 0x06b6d4, Padma 0xec4899.
  static const Color head = Color(0xFFFDE047);
  static const Color hardeep = gridField;
  static const Color padma = Color(0xFFEC4899);

  /// `createFlag`: pole 0x94a3b8, cloth 0xeab308. `createCone3D` 0xf97316.
  static const Color pole = slate400;
  static const Color cloth = zslYellow;
  static const Color cone = Color(0xFFF97316);

  /// Reference ring (`RingGeometry`, 0xeab308).
  static const Color ring = zslYellow;

  /// Dashed measuring lines: to the school 0x6366f1, to the garden
  /// 0x10b981, cone lines 0xf97316.
  static const Color lineSchool = indigo500;
  static const Color lineGarden = emerald500;
  static const Color lineCone = cone;

  /// Badge sprites: check #10b981, cross #ef4444.
  static const Color badgeCheck = emerald500;
  static const Color badgeCross = red500;

  /// Chalk of the court outline (added).
  static const Color chalk = Color(0xCCFFFFFF);

  // ----------------------------------------------- `#labels-container` chips
  static const Color chipDark = Color(0xE60F172A); // bg-slate-900/90
  static const Color chipIndigo = Color(0xE6312E81); // bg-indigo-900/90
  static const Color chipEmerald = Color(0xE6064E3B); // bg-emerald-900/90
  static const Color chipAmber = Color(0xE6D97706); // bg-amber-600/90
  static const Color amberEdge = Color(0x80F59E0B); // border-amber-500/50
  static const Color purpleEdge = Color(0x80A855F7);
  static const Color cyanEdge = Color(0x8006B6D4);
  static const Color pinkEdge = Color(0x80EC4899);
  static const Color orangeEdge = Color(0x80F97316);

  // ------------------------------------------------ `#bargraph-panel` card
  static const Color graphBg = Color(0xE60F172A); // bg-slate-900/90
  static const Color graphEdge = Color(0x4D6366F1); // border-indigo-500/30
  static const Color graphTrack = slate800;
  static const Color graphTrackEdge = slate700;
  static const Color badgeBg = Color(0x33F59E0B); // bg-amber-500/20
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xF2020617), // teacher board dark:bg-slate-950/95
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.skyDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // #toast bg-slate-900/80 + blur
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300, // subtitle text-indigo-300
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2F8FAFC), // bg-slate-50
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.skyLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipDark,
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

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays its `pop` tone for clicks, the sidebar, scenario changes and the
/// curtain.
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.pop,
  curtain: _Sound.pop,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// HTML's English-only texts (button labels set in `updateS1Buttons`,
// toasts, bar graph, 3D labels) are translated here. Step instructions and
// HUD lines quote the buttons exactly as they are labelled and name the
// touch alternatives (drag the rope, tap a person); distances are in
// metres throughout (the HTML mixed "units" and "m"). Keys marked "added"
// are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Understanding Reference Points & Relative Position',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1_opt': 'Scenario 1: The School and The Garden',
    'scen_2_opt': 'Scenario 2: Drawing the Kabaddi Court',
    's1_desc':
        'To visually demonstrate that the distance to objects, and therefore which one is ‘closer’, depends entirely on the starting point of measurement (the reference point).',
    's2_desc':
        'To understand the necessity of a single, shared reference point for accurate and consistent measurement between multiple people.',
    // Scenario 1 steps.
    's1_concept_1':
        'Measuring distance requires a starting point (reference point). Here, Deepa’s house is our reference point.',
    's1_action_1':
        'Drag the measuring rope from Deepa’s house to the School, or tap ‘Measure Deepa → School’.',
    's1_obs_1':
        'A glowing line connects Deepa’s house to the School. The bar graph records a distance of 5 m.',
    's1_concept_2':
        'Comparing distances from the same reference point tells us which object is closer.',
    's1_action_2':
        'Drag the rope from Deepa’s house to the Garden, or tap ‘Measure Deepa → Garden’.',
    's1_obs_2':
        'The Garden is 9 m away. A green checkmark appears over the School (closer) and a red X over the Garden (farther).',
    's1_concept_3':
        'Changing the observer changes the reference point. Now we observe from Tasneem’s house.',
    's1_action_3':
        'Tap ‘Measure Tasneem → School’ (or drag the rope from Tasneem’s house to the School).',
    's1_obs_3':
        'A glowing line connects Tasneem’s house to the School, showing a distance of 8 m.',
    's1_concept_4':
        'From a different reference point, relative position and distance change completely.',
    's1_action_4':
        'Tap ‘Measure Tasneem → Garden’ (or drag the rope from Tasneem’s house to the Garden).',
    's1_obs_4':
        'The Garden is only 4 m away from Tasneem! For Tasneem, the Garden is closer (checkmark) and the School is farther (X).',
    's1_concept_5':
        'Terms like ‘closer’ or ‘farther’ are meaningless without defining the Reference Point.',
    's1_action_5': 'Tap the ‘Compare Results’ button.',
    's1_obs_5':
        'The glowing text ‘REFERENCE POINT’ appears at both houses, concluding that position is strictly relative.',
    's1_hud_1':
        'Step 1: Deepa’s House is the active reference point. Tap ‘Measure Deepa → School’ or drag the rope to the School.',
    's1_hud_2':
        'Step 2: Now measure from Deepa’s House to the Garden by tapping ‘Measure Deepa → Garden’.',
    's1_hud_3':
        'Step 3: Reference point changed to Tasneem’s House! Tap ‘Measure Tasneem → School’.',
    's1_hud_4': 'Step 4: Now measure from Tasneem’s House to the Garden.',
    's1_hud_5':
        'Step 5: Tap ‘Compare Results’ to analyse how the reference point changes which place is closer.',
    // Scenario 2 steps.
    's2_concept_1':
        'Without an agreed starting point, people measure from wherever they are standing.',
    's2_action_1':
        'Tap Hardeep (or ‘Select Hardeep’) to choose him as the starting reference point.',
    's2_obs_1': 'A glowing ring appears at Hardeep’s feet.',
    's2_concept_2':
        'Distance alone is not enough if the starting point is individual.',
    's2_action_2':
        'Tap ‘Place Cone (7 Steps)’ to place a cone 7 steps away from Hardeep.',
    's2_obs_2':
        'A line with step markers appears, and the cone snaps at the 7-step mark from Hardeep.',
    's2_concept_3':
        'If two people use different reference points, identical measurements lead to completely different locations.',
    's2_action_3':
        'Tap Padma (or ‘Select Padma’), then tap ‘Place Cone (7 Steps)’ to place a cone 7 steps away from her.',
    's2_obs_3':
        'Padma’s cone ends up in a completely different location than Hardeep’s cone!',
    's2_concept_4':
        'To coordinate and build an accurate Kabaddi court, everyone must agree on one fixed Reference Point.',
    's2_action_4':
        'Tap ‘Cone 7 Steps North’ to measure 7 steps North from the official central Reference Flag.',
    's2_obs_4':
        'Measuring from the shared central flag places the first cone at an exact, agreed position.',
    's2_concept_5':
        'A shared reference point allows precise spatial communication and teamwork.',
    's2_action_5':
        'Tap ‘Cone 10 Steps East’ to measure 10 steps East from the central flag.',
    's2_obs_5':
        'Both Hardeep and Padma use the shared central flag to place cones accurately, outlining the Kabaddi court!',
    's2_hud_1':
        'Step 1: Tap Hardeep or ‘Select Hardeep’ to set him as the starting point.',
    's2_hud_2':
        'Step 2: Tap ‘Place Cone (7 Steps)’ to drop a cone 7 steps away from Hardeep.',
    's2_hud_3':
        'Step 3: Tap ‘Select Padma’, then tap ‘Place Cone (7 Steps)’ from her position.',
    's2_hud_4':
        'Step 4: Field reset! A central Reference Flag is placed. Tap ‘Cone 7 Steps North’.',
    's2_hud_5':
        'Step 5: Tap ‘Cone 10 Steps East’ to measure from the shared flag and complete the court outline.',
    // Summaries.
    'sc_complete': 'Scenario {n} Complete!',
    'summary_title': 'Investigation Summary',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You have mastered the concept of Reference Points! You learned that position and distance are relative, and that shared reference points are essential for accurate communication.',
    's1_summary':
        'You clearly proved that ‘which is closer’ depends on the Reference Point! For Deepa, the School was closer (5 m vs 9 m). But for Tasneem, the Garden was closer (4 m vs 8 m).',
    's2_summary':
        'You demonstrated that when Hardeep and Padma measured from their own positions, the cones ended up scattered. But measuring from a shared Reference Flag created an accurate court!',
    // 3D labels (HTML `#labels-container`).
    'lbl_deepa_house': 'Deepa’s House',
    'lbl_tasneem_house': 'Tasneem’s House',
    'school': 'School',
    'garden': 'Garden',
    'lbl_hardeep': 'Hardeep',
    'lbl_padma': 'Padma',
    'lbl_flag': 'Reference Flag (0,0)',
    'lbl_ref_point': 'REFERENCE POINT',
    // Added: compass rose and step counts on the cone lines.
    'lbl_north': 'N',
    'lbl_east': 'E',
    'lbl_steps': '{n} steps',
    // HTML `#bargraph-panel`.
    'bg_title': 'Distance Comparison',
    'bg_ref_deepa': 'Ref: Deepa’s House',
    'bg_ref_tasneem': 'Ref: Tasneem’s House',
    'bg_closer_deepa': 'School is closer for Deepa!',
    'bg_closer_tasneem': 'Garden is closer for Tasneem!',
    'unit_m': '{n} m',
    'no_value': '--',
    // Buttons (HTML `updateS1Buttons` labels, Scenario 2 buttons).
    'btn_deepaSchool': 'Measure Deepa → School',
    'btn_deepaGarden': 'Measure Deepa → Garden',
    'btn_tasneemSchool': 'Measure Tasneem → School',
    'btn_tasneemGarden': 'Measure Tasneem → Garden',
    'btn_compare': 'Compare Results',
    'btn_hardeep': 'Select Hardeep',
    'btn_cone': 'Place Cone (7 Steps)',
    'btn_padma': 'Select Padma',
    'btn_north': 'Cone 7 Steps North',
    'btn_east': 'Cone 10 Steps East',
    // Toasts.
    't_deepaSchool': 'Measured: Deepa to School = 5 m',
    't_deepaGarden': 'Measured: Deepa to Garden = 9 m (School is Closer!)',
    't_shift': 'Reference Point shifted to Tasneem’s House!',
    't_tasneemSchool': 'Measured: Tasneem to School = 8 m',
    't_tasneemGarden': 'Measured: Tasneem to Garden = 4 m (Garden is Closer!)',
    't_compare':
        'Conclusion: ‘Closer’ depends entirely on the Reference Point!',
    't_hardeep': 'Hardeep selected as Reference Point.',
    't_cone_hardeep': 'Cone placed 7 steps from Hardeep!',
    't_padma': 'Padma selected as Reference Point.',
    't_cone_padma':
        'Cone placed 7 steps from Padma — notice it’s in a completely different spot!',
    't_field_reset':
        'Field reset! Official Central Reference Flag planted at (0,0).',
    't_north': 'Cone placed exactly 7 steps North of Reference Flag!',
    't_east': 'Kabaddi Court outline established accurately from shared flag!',
    // Added: wrong actions on the touch alternatives.
    't_school_first': 'First measure the distance to the School.',
    't_school_done':
        'The School is already measured. Now measure to the Garden.',
    't_rope_miss': 'Let go of the rope on the School or the Garden.',
    't_pick_hardeep': 'Start with Hardeep: select Hardeep first.',
    't_place_first': 'First place the cone 7 steps from Hardeep.',
    't_pick_padma': 'Hardeep’s cone is placed. Now select Padma.',
    // Added: sidebar observations, summary table, scene descriptions.
    'obs_title': 'Observations',
    'obs_empty': 'Your observations appear here after each step.',
    'obs_step': 'Step {n}',
    'tbl_ref': 'Reference point',
    'tbl_closer': 'Closer',
    'scene_s1':
        'Town map with Deepa’s house, Tasneem’s house, a school and a garden',
    'scene_s2':
        'Playground with Hardeep, Padma and the ground for a Kabaddi court',
  },
  'hi': {
    'app_title': 'संदर्भ बिंदु और सापेक्ष स्थिति को समझना',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: स्कूल और बगीचा',
    'scen_2_opt': 'परिदृश्य 2: कबड्डी का मैदान बनाना',
    's1_desc':
        "यह प्रदर्शित करना कि किसी वस्तु की दूरी और कौन सी वस्तु 'पास' है, यह पूरी तरह से मापन के प्रारंभिक बिंदु (संदर्भ बिंदु) पर निर्भर करता है।",
    's2_desc':
        'यह समझना कि कई लोगों के बीच सटीक और समान मापन के लिए एक ही साझा संदर्भ बिंदु होना आवश्यक है।',
    's1_concept_1':
        'दूरी मापने के लिए एक प्रारंभिक बिंदु (संदर्भ बिंदु) की आवश्यकता होती है। यहाँ दीपा का घर हमारा संदर्भ बिंदु है।',
    's1_action_1':
        "मापने वाली रस्सी को दीपा के घर से स्कूल तक खींचें, या 'मापें: दीपा → स्कूल' दबाएं।",
    's1_obs_1':
        'दीपा के घर से स्कूल तक एक चमकती रेखा बनती है। बार ग्राफ में दूरी 5 मी दर्ज होती है।',
    's1_concept_2':
        'एक ही संदर्भ बिंदु से तुलना करने पर पता चलता है कि कौन पास है।',
    's1_action_2':
        "रस्सी को दीपा के घर से बगीचे तक खींचें, या 'मापें: दीपा → बगीचा' दबाएं।",
    's1_obs_2':
        'बगीचा 9 मी दूर है। स्कूल पर हरा निशान (पास) और बगीचे पर लाल क्रॉस (दूर) आता है।',
    's1_concept_3':
        'प्रेक्षक बदलने से संदर्भ बिंदु बदल जाता है। अब हम तस्नीम के घर से देखते हैं।',
    's1_action_3':
        "'मापें: तस्नीम → स्कूल' दबाएं (या रस्सी को तस्नीम के घर से स्कूल तक खींचें)।",
    's1_obs_3':
        'तस्नीम के घर से स्कूल तक एक चमकती रेखा बनती है, जो 8 मी की दूरी दिखाती है।',
    's1_concept_4': 'अलग संदर्भ बिंदु से स्थिति और दूरी पूरी तरह बदल जाती है।',
    's1_action_4':
        "'मापें: तस्नीम → बगीचा' दबाएं (या रस्सी को तस्नीम के घर से बगीचे तक खींचें)।",
    's1_obs_4':
        'तस्नीम के घर से बगीचा केवल 4 मी दूर है! तस्नीम के लिए बगीचा पास (हरा निशान) है और स्कूल दूर (लाल क्रॉस)।',
    's1_concept_5':
        "'पास' या 'दूर' जैसे शब्द बिना संदर्भ बिंदु के अर्थहीन हैं।",
    's1_action_5': "'परिणामों की तुलना करें' बटन दबाएं।",
    's1_obs_5':
        "दोनों घरों पर चमकता हुआ 'संदर्भ बिंदु' लेबल दिखता है, जो स्पष्ट करता है कि स्थिति पूरी तरह सापेक्ष है।",
    's1_hud_1':
        "चरण 1: दीपा का घर संदर्भ बिंदु है। 'मापें: दीपा → स्कूल' दबाएं या रस्सी को स्कूल तक खींचें।",
    's1_hud_2':
        "चरण 2: अब 'मापें: दीपा → बगीचा' दबाकर दीपा के घर से बगीचे तक मापें।",
    's1_hud_3':
        "चरण 3: संदर्भ बिंदु बदलकर तस्नीम का घर हो गया है! 'मापें: तस्नीम → स्कूल' दबाएं।",
    's1_hud_4': 'चरण 4: अब तस्नीम के घर से बगीचे तक दूरी मापें।',
    's1_hud_5':
        "चरण 5: दोनों दृष्टिकोणों की तुलना करने के लिए 'परिणामों की तुलना करें' दबाएं।",
    's2_concept_1':
        'बिना किसी तय बिंदु के, लोग वहीं से नापते हैं जहाँ वे खड़े होते हैं।',
    's2_action_1':
        "हरदीप पर टैप करें (या 'हरदीप को चुनें' दबाएं) ताकि हरदीप शुरुआती संदर्भ बिंदु बने।",
    's2_obs_1': 'हरदीप के पैरों के पास एक चमकता हुआ घेरा दिखाई देता है।',
    's2_concept_2': 'यदि शुरुआती बिंदु अलग हो तो केवल दूरी बताना काफी नहीं है।',
    's2_action_2':
        "हरदीप से 7 कदम की दूरी पर कोन रखने के लिए 'कोन रखें (7 कदम)' दबाएं।",
    's2_obs_2':
        'कदमों के निशान वाली एक रेखा बनती है, और कोन हरदीप से ठीक 7 कदम के निशान पर टिक जाता है।',
    's2_concept_3':
        'यदि दो लोग अलग-अलग संदर्भ बिंदुओं का उपयोग करते हैं, तो समान दूरी भी अलग-अलग स्थानों पर ले जाती है।',
    's2_action_3':
        "पद्मा पर टैप करें (या 'पद्मा को चुनें' दबाएं), फिर पद्मा से 7 कदम दूर कोन रखने के लिए 'कोन रखें (7 कदम)' दबाएं।",
    's2_obs_3':
        'पद्मा का कोन हरदीप के कोन से बिल्कुल अलग स्थान पर पहुंच जाता है!',
    's2_concept_4':
        'सही मैदान बनाने के लिए सभी को एक निश्चित संदर्भ बिंदु पर सहमत होना होगा।',
    's2_action_4':
        "बीच वाले संदर्भ झंडे से 7 कदम उत्तर में मापने के लिए 'उत्तर में 7 कदम पर कोन' दबाएं।",
    's2_obs_4':
        'साझा झंडे से नापने पर पहला कोन एक सटीक और तय स्थान पर रखा जाता है।',
    's2_concept_5':
        'एक साझा संदर्भ बिंदु सटीक तालमेल और टीम वर्क को संभव बनाता है।',
    's2_action_5':
        "झंडे से 10 कदम पूर्व में मापने के लिए 'पूर्व में 10 कदम पर कोन' दबाएं।",
    's2_obs_5':
        'हरदीप और पद्मा दोनों साझा झंडे से सही नाप लेकर कोन रखते हैं, और कबड्डी कोर्ट की रूपरेखा बन जाती है!',
    's2_hud_1':
        "चरण 1: हरदीप को शुरुआती बिंदु बनाने के लिए हरदीप पर टैप करें या 'हरदीप को चुनें' दबाएं।",
    's2_hud_2':
        "चरण 2: हरदीप से 7 कदम दूर कोन रखने के लिए 'कोन रखें (7 कदम)' दबाएं।",
    's2_hud_3':
        "चरण 3: 'पद्मा को चुनें' दबाएं, फिर पद्मा की जगह से 'कोन रखें (7 कदम)' दबाएं।",
    's2_hud_4':
        "चरण 4: मैदान रीसेट! बीच में संदर्भ झंडा लगा है। 'उत्तर में 7 कदम पर कोन' दबाएं।",
    's2_hud_5':
        "चरण 5: साझा झंडे से मापकर कोर्ट की रूपरेखा पूरी करने के लिए 'पूर्व में 10 कदम पर कोन' दबाएं।",
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'summary_title': 'जांच का सारांश',
    'all_complete': 'महारत हासिल हुई!',
    'all_complete_desc':
        'आपने संदर्भ बिंदु की अवधारणा को सफलतापूर्वक समझ लिया है! आपने जाना कि स्थान और दूरी सापेक्ष होती हैं, और सटीक संवाद के लिए एक साझा संदर्भ बिंदु आवश्यक है।',
    's1_summary':
        "आपने सिद्ध किया कि 'कौन पास है' यह संदर्भ बिंदु पर निर्भर करता है! दीपा के लिए स्कूल पास था (5 मी बनाम 9 मी), जबकि तस्नीम के लिए बगीचा पास था (4 मी बनाम 8 मी)।",
    's2_summary':
        'आपने देखा कि जब हरदीप और पद्मा ने अपनी-अपनी जगह से नापा तो कोन अलग-अलग जगह बिखर गए। लेकिन साझा झंडे से नापने पर सटीक मैदान बना!',
    'lbl_deepa_house': 'दीपा का घर',
    'lbl_tasneem_house': 'तस्नीम का घर',
    'school': 'स्कूल',
    'garden': 'बगीचा',
    'lbl_hardeep': 'हरदीप',
    'lbl_padma': 'पद्मा',
    'lbl_flag': 'संदर्भ झंडा (0,0)',
    'lbl_ref_point': 'संदर्भ बिंदु',
    'lbl_north': 'उ',
    'lbl_east': 'पू',
    'lbl_steps': '{n} कदम',
    'bg_title': 'दूरी की तुलना',
    'bg_ref_deepa': 'संदर्भ: दीपा का घर',
    'bg_ref_tasneem': 'संदर्भ: तस्नीम का घर',
    'bg_closer_deepa': 'दीपा के लिए स्कूल पास है!',
    'bg_closer_tasneem': 'तस्नीम के लिए बगीचा पास है!',
    'unit_m': '{n} मी',
    'no_value': '--',
    'btn_deepaSchool': 'मापें: दीपा → स्कूल',
    'btn_deepaGarden': 'मापें: दीपा → बगीचा',
    'btn_tasneemSchool': 'मापें: तस्नीम → स्कूल',
    'btn_tasneemGarden': 'मापें: तस्नीम → बगीचा',
    'btn_compare': 'परिणामों की तुलना करें',
    'btn_hardeep': 'हरदीप को चुनें',
    'btn_cone': 'कोन रखें (7 कदम)',
    'btn_padma': 'पद्मा को चुनें',
    'btn_north': 'उत्तर में 7 कदम पर कोन',
    'btn_east': 'पूर्व में 10 कदम पर कोन',
    't_deepaSchool': 'मापा गया: दीपा → स्कूल = 5 मी',
    't_deepaGarden': 'मापा गया: दीपा → बगीचा = 9 मी (स्कूल पास है!)',
    't_shift': 'संदर्भ बिंदु बदलकर तस्नीम का घर हो गया!',
    't_tasneemSchool': 'मापा गया: तस्नीम → स्कूल = 8 मी',
    't_tasneemGarden': 'मापा गया: तस्नीम → बगीचा = 4 मी (बगीचा पास है!)',
    't_compare':
        "निष्कर्ष: कौन 'पास' है, यह पूरी तरह संदर्भ बिंदु पर निर्भर करता है!",
    't_hardeep': 'हरदीप को संदर्भ बिंदु चुना गया।',
    't_cone_hardeep': 'हरदीप से 7 कदम पर कोन रखा गया!',
    't_padma': 'पद्मा को संदर्भ बिंदु चुना गया।',
    't_cone_padma':
        'पद्मा से 7 कदम पर कोन रखा गया — देखिए, यह बिल्कुल अलग जगह पर है!',
    't_field_reset': 'मैदान रीसेट! केंद्रीय संदर्भ झंडा (0,0) पर लगाया गया।',
    't_north': 'संदर्भ झंडे से ठीक 7 कदम उत्तर में कोन रखा गया!',
    't_east': 'साझा झंडे से कबड्डी कोर्ट की रूपरेखा सटीक बन गई!',
    't_school_first': 'पहले स्कूल तक की दूरी मापें।',
    't_school_done': 'स्कूल तक की दूरी मापी जा चुकी है। अब बगीचे तक मापें।',
    't_rope_miss': 'रस्सी को स्कूल या बगीचे पर छोड़ें।',
    't_pick_hardeep': 'पहले हरदीप को चुनें।',
    't_place_first': 'पहले हरदीप से 7 कदम पर कोन रखें।',
    't_pick_padma': 'हरदीप का कोन रखा जा चुका है। अब पद्मा को चुनें।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण के बाद आपके अवलोकन यहाँ दिखाई देंगे।',
    'obs_step': 'चरण {n}',
    'tbl_ref': 'संदर्भ बिंदु',
    'tbl_closer': 'पास',
    'scene_s1': 'दीपा का घर, तस्नीम का घर, स्कूल और बगीचे वाला नक्शा',
    'scene_s2': 'हरदीप, पद्मा और कबड्डी के मैदान की जगह वाला खेल का मैदान',
  },
};

/// Steps per scenario (HTML `ScenariosData[...][n].steps`).
const int _stepCount = 5;
const int _scenarioCount = 2;

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_concept_$i'),
              action: t('s${n}_action_$i'),
              observation: t('s${n}_obs_$i'),
            ),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas. A
/// little narrower than the usual 1000 × 560: with the sidebar open, a
/// landscape phone's canvas is about 1.5 : 1, so the town fills more of it.
/// The camera's vertical field of view (and so its framing) is unchanged.
const Size _design = Size(840, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// HTML `camera.position.set(0, 18, 26)` looking at
/// `controls.target.set(0, 0, 0)` (both scenarios, `resetScenarioState`).
const _V _eye = _V(0, 18, 26);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing the rope (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px (HTML `text-xs`), enlarged up to 1.6x on
/// small stages so they stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.6;

/// While the sidebar is collapsed the view pans right so the scene clears
/// the shell's floating mission card at the top left. The shell places that
/// card 76 px from the left, 36 % of the screen wide (200 … 380 px x UI
/// scale); [_cardGap] design px are kept free on each side.
const double _missionCardLeft = 76;
const double _missionCardFraction = 0.36;
const double _missionCardMin = 200;
const double _missionCardMax = 380;
const double _cardGap = 8;

/// The pan slides like the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the panned scene layer. Flows map scene design coordinates to the
/// screen through it, so they follow the pan.
const ValueKey<String> _sceneKey = ValueKey('ch5-a5-scene');

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

  /// The same point at height [h].
  _V atY(double h) => _V(x, h, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage. [center] is where the look-at
/// point lands on the stage.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, Offset center) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, center, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the horizontal plane y = [h].
  _V? onPlaneY(Offset s, double h) {
    final dir = ray(s);
    if (dir.y.abs() < 1e-6) return null;
    final t = (h - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// The scene camera, its look-at point at the stage centre.
final _Cam _cam = _Cam(
  _eye,
  _V.zero,
  Offset(_design.width / 2, _design.height / 2),
);

/// HTML key light `DirectionalLight` at (15, 25, 15), normalised.
const _V _light = _V(0.4575, 0.7625, 0.4575);

/// Face brightness. The HTML's AmbientLight 0.75 plus DirectionalLight 0.85
/// add up to 1.6 and wash every lit face out to its full colour; they are
/// scaled into 0.62 … 1.0 so the faces of a box keep visible shading.
const double _ambient = 0.62;
const double _diffuse = 0.45;

/// MeshStandardMaterial look: ambient plus the key light's Lambert term on a
/// face with unit normal [n].
Color _lit(Color c, _V n) {
  final i = math.min(1.0, _ambient + _diffuse * math.max(0.0, n.dot(_light)));
  return Color.from(alpha: c.a, red: c.r * i, green: c.g * i, blue: c.b * i);
}

// ------------------------------------------------- scenario 1: the town

/// Deepa's and Tasneem's houses (`createHouse`) and the girls standing
/// beside them (`createCharacter`), as in the HTML.
const _V _deepaHouse = _V(-7, 0, 6);
const _V _deepaSpot = _V(-5.5, 0, 6);
const _V _tasneemHouse = _V(7, 0, 6);
const _V _tasneemSpot = _V(5.5, 0, 6);

/// World units per metre of the HTML's distances. The HTML reports Deepa →
/// School 5, Deepa → Garden 9, Tasneem → School 8 and Tasneem → Garden 4,
/// but its school (-4, 0, -5) and garden (6, 0, -4) were 11.1, 15.2, 14.5
/// and 10.0 units from the girls, so the drawn distances contradicted the
/// numbers. The school and the garden are placed where the reported
/// distances are true at 1.5 units per metre (close to the HTML's x
/// positions), and the town's grid has one square per metre.
const double _unitsPerMetre = 1.5;

/// The town's grid: `GridHelper(30, …)` with one line per metre.
const int _townGridDivisions = 20;

/// The playground keeps `GridHelper(30, 30)`: one square per step.
const int _fieldGridDivisions = 30;

/// Half the side of `PlaneGeometry(30, 30)`.
const double _groundHalf = 15;

/// Height of the measuring lines (HTML `createDottedLine` at y = 0.5) and of
/// the cone lines (y = 0.3).
const double _lineY = 0.5;
const double _coneLineY = 0.3;

/// `RingGeometry(1.2, 1.5, 32)` at y = 0.05.
const double _ringInner = 1.2;
const double _ringOuter = 1.5;
const double _ringY = 0.05;

/// Whose house is the reference point.
enum _Ref { deepa, tasneem }

/// What is measured to.
enum _Place { school, garden }

/// The four measurements of Scenario 1 and their HTML distances (m).
enum _Leg {
  deepaSchool(_Ref.deepa, _Place.school, 5),
  deepaGarden(_Ref.deepa, _Place.garden, 9),
  tasneemSchool(_Ref.tasneem, _Place.school, 8),
  tasneemGarden(_Ref.tasneem, _Place.garden, 4);

  const _Leg(this.ref, this.place, this.metres);

  final _Ref ref;
  final _Place place;
  final int metres;

  static _Leg of(_Ref ref, _Place place) =>
      values.firstWhere((l) => l.ref == ref && l.place == place);
}

/// The longest distance; the bar graph is scaled to it (HTML widths 55 %,
/// 100 %, 88 % and 44 %).
const double _graphMaxMetres = 9;

/// The point behind the girls (towards -z) that is [ma] metres from [a] and
/// [mb] metres from [b] (intersection of two circles on the ground).
_V _placeBehind(_V a, int ma, _V b, int mb) {
  final ra = ma * _unitsPerMetre;
  final rb = mb * _unitsPerMetre;
  final d = b - a;
  final len = d.length;
  final u = d * (1 / len);
  final along = (ra * ra - rb * rb + len * len) / (2 * len);
  final across = math.sqrt(math.max(0, ra * ra - along * along));
  var n = _V(-u.z, 0, u.x);
  if (n.z > 0) n = n * -1;
  return a + u * along + n * across;
}

final _V _schoolPos = _placeBehind(
  _deepaSpot,
  _Leg.deepaSchool.metres,
  _tasneemSpot,
  _Leg.tasneemSchool.metres,
);
final _V _gardenPos = _placeBehind(
  _deepaSpot,
  _Leg.deepaGarden.metres,
  _tasneemSpot,
  _Leg.tasneemGarden.metres,
);

_V _spotOf(_Ref r) => r == _Ref.deepa ? _deepaSpot : _tasneemSpot;
_V _houseOf(_Ref r) => r == _Ref.deepa ? _deepaHouse : _tasneemHouse;
_V _placePos(_Place p) => p == _Place.school ? _schoolPos : _gardenPos;

/// Heights of the labels and badges above the school (roof tip 5.6) and the
/// garden (cone tree tip 2.75); each badge sits above its label (the HTML
/// drew them over each other).
const double _schoolLabelY = 6.2;
const double _schoolBadgeY = 7.7;
const double _gardenLabelY = 3.4;
const double _gardenBadgeY = 4.8;

/// The house names stand on the ground in front of the houses (the HTML's
/// labels on the walls covered the girls and touched the school).
const double _houseLabelAhead = 2.4;

/// `createBadge`: sprite 1.8 units wide.
const double _badgeRadius = 0.9;

/// Opacity of the measuring lines' second pass over the buildings.
const double _seeThrough = 0.8;

/// The bar graph card sits below the toast row (design: 44 dp x UI scale).
const double _graphBelowToast = 44;

/// The reference ring's pulse reaches this far past its outer edge.
const double _ringPulse = 0.25;

/// Ring drawn round the place under the held rope (just outside the
/// school's and the garden's footprints), and the rope's end knob (px).
const double _hoverInner = 3.1;
const double _hoverOuter = 3.4;
const double _ropeKnob = 5;

/// Step markers on the cone lines (radius, world units).
const double _stepDot = 0.14;

/// Compass rose: dial radius, arrow length and letter distance.
const double _compassDial = 1.3;
const double _compassArrow = 2;
const double _compassLetter = 2.9;

/// The eight corners of a box centred at [c] with half sizes [h].
List<_V> _boxCorners(_V c, _V h) => [
  for (final sx in const [-1.0, 1.0])
    for (final sy in const [-1.0, 1.0])
      for (final sz in const [-1.0, 1.0])
        _V(c.x + sx * h.x, c.y + sy * h.y, c.z + sz * h.z),
];

/// Screen bounds (design px) of [points].
Rect _boundsOf(List<_V> points) {
  var left = double.infinity, top = double.infinity;
  var right = -double.infinity, bottom = -double.infinity;
  for (final w in points) {
    final o = _cam.p(w);
    left = math.min(left, o.dx);
    right = math.max(right, o.dx);
    top = math.min(top, o.dy);
    bottom = math.max(bottom, o.dy);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

/// Screen areas of the houses (wall box and roof eaves, 0 … 3.5 high), the
/// school (block, tower and roof, 0 … 5.6) and the garden (fence and trees,
/// 0 … 2.75): where the rope is grabbed and where it is let go.
Rect _houseRect(_V house) => _boundsOf(
  _boxCorners(house + const _V(0, 1.75, 0), const _V(1.56, 1.75, 1.56)),
);
final Rect _deepaHouseRect = _houseRect(_deepaHouse);
final Rect _tasneemHouseRect = _houseRect(_tasneemHouse);
final Rect _schoolRect = _boundsOf(
  _boxCorners(_schoolPos + const _V(0, 2.8, 0), const _V(2.5, 2.8, 1.5)),
);
final Rect _gardenRect = _boundsOf(
  _boxCorners(_gardenPos + const _V(0, 1.4, 0), const _V(2.25, 1.4, 2.25)),
);

// ------------------------------------------- scenario 2: the playground

/// `hardeepChar.position.set(-6, 0, 3)`, `padmaChar.position.set(5, 0, 4)`,
/// the flag at the origin.
const _V _hardeepHome = _V(-6, 0, 3);
const _V _padmaHome = _V(5, 0, 4);
const _V _flagPos = _V.zero;

/// Cones (one world unit per step, North = -z, East = +x): 7 steps North of
/// Hardeep and of Padma, then 7 steps North and 10 steps East of the flag.
const _V _hardeepCone = _V(-6, 0, -4);
const _V _padmaCone = _V(5, 0, -3);
const _V _northCone = _V(0, 0, -7);
const _V _eastCone = _V(10, 0, 0);

/// Where Hardeep and Padma walk at the end (HTML tweens, 1000 ms).
const _V _hardeepEnd = _V(-1, 0, 1);
const _V _padmaEnd = _V(1, 0, 1);

/// The court drawn at the end (added): centred on the central flag, its
/// sides through the two cones (half sizes 10 × 7 steps) and its mid line
/// through the north cone.
const double _courtHalfX = 10;
const double _courtHalfZ = 7;

/// A compass rose (added) in the playground's far right corner, so "North"
/// and "East" can be read off the field.
const _V _compassPos = _V(12, 0, -10);

/// Step counts float above the cones at this height.
const double _stepTagY = 1.9;

/// Person labels stand on the ground in front of the person; the flag
/// label floats left of the pole's top.
const double _personLabelAhead = 2.2;
const _V _flagLabelAt = _V(-0.7, 3.3, 0);

/// Scenario 2 progress: the HTML `State.step` plus the pause before the
/// field reset.
enum _Phase { start, hardeep, hardeepCone, padma, padmaCone, flag, north, east }

/// Who was tapped.
enum _Who { hardeep, padma }

// ------------------------------------------------------------------ timing

/// HTML `setTimeout(…, 2200)`: Deepa's result stays on screen, then the
/// reference point moves to Tasneem's house.
const Duration _shiftDelay = Duration(milliseconds: 2200);

/// HTML ring tween to Tasneem's house: 800 ms, `Quadratic.Out`.
const double _shiftSeconds = 0.8;

/// HTML `setTimeout(() => showObservationPopup(), 1500 / 1800)`.
const Duration _s1ConclusionDelay = Duration(milliseconds: 1500);
const Duration _s2ConclusionDelay = Duration(milliseconds: 1800);

/// HTML field reset 3000 ms after Padma's cone.
const Duration _fieldResetDelay = Duration(milliseconds: 3000);

/// HTML ring tweens to Hardeep / Padma (500 ms) and to the flag (600 ms).
const double _ringSelectSeconds = 0.5;
const double _ringFlagSeconds = 0.6;

/// HTML walk of Hardeep and Padma to the flag (1000 ms, linear).
const double _walkSeconds = 1;

/// A measuring line is drawn out over this time (the HTML showed it at
/// once; its `measure` tone is a 0.3 s sweep).
const double _growSeconds = 0.6;

/// Badges, the flag and cones pop in; the court outline fades in.
const double _popSeconds = 0.3;
const double _fadeSeconds = 0.8;

/// A position tween (HTML `TWEEN.Tween(position).to(…, ms)`).
@immutable
class _Motion {
  const _Motion.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  const _Motion(this.from, this.to, this.start, this.seconds, this.curve);

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double time) {
    if (seconds <= 0) return to;
    final t = ((time - start) / seconds).clamp(0.0, 1.0);
    return _V.lerp(from, to, curve.transform(t));
  }

  /// A new tween from wherever this one is at [now].
  _Motion moveTo(_V target, double now, double secs, Curve c) =>
      _Motion(at(now), target, now, secs, c);
}

/// One measured line of Scenario 2 with the cone at its end.
@immutable
class _Mark {
  const _Mark(this.from, this.to, this.steps, this.at);

  final _V from;
  final _V to;
  final int steps;

  /// Scene time it was placed (the line draws out from then).
  final double at;
}

/// Mutable scene read by the painter every frame.
class _Sim {
  double time = 0;
  int scenario = 0;

  /// The yellow reference ring (`refRingMesh`) and when it appeared.
  bool ringOn = true;
  double ringAt = 0;
  _Motion ring = const _Motion.still(_deepaSpot);

  // ------------------------------------------------------------ scenario 1
  /// HTML `State.s1Measurements.activeRef`.
  _Ref ref = _Ref.deepa;

  /// Measurements made, with the scene time of each.
  final Map<_Leg, double> legs = {};

  /// The 2.2 s between Deepa's second measurement and the shift.
  bool shifting = false;

  /// Scene time of Compare Results (-1: not yet).
  double comparedAt = -1;

  /// The measuring rope is held; its free end and the place under it.
  bool roping = false;
  _V ropeEnd = _V.zero;
  _Place? hover;

  // ------------------------------------------------------------ scenario 2
  _Phase phase = _Phase.start;
  _Motion hardeep = const _Motion.still(_hardeepHome);
  _Motion padma = const _Motion.still(_padmaHome);
  final List<_Mark> marks = [];

  /// Scene times the flag was planted and the court outlined (-1: not yet).
  double flagAt = -1;
  double courtAt = -1;

  bool get compared => comparedAt >= 0;
  bool measured(_Leg leg) => legs.containsKey(leg);

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    // Scenario 2 has no reference point until Hardeep is chosen (the HTML
    // parked the ring at his feet before he was selected).
    ringOn = index == 0;
    ringAt = time;
    ring = _Motion.still(index == 0 ? _deepaSpot : _hardeepHome);
    ref = _Ref.deepa;
    legs.clear();
    shifting = false;
    comparedAt = -1;
    roping = false;
    hover = null;
    phase = _Phase.start;
    hardeep = const _Motion.still(_hardeepHome);
    padma = const _Motion.still(_padmaHome);
    marks.clear();
    flagAt = -1;
    courtAt = -1;
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the reference house ([canGrab]), so other drags still pan / zoom the
/// canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _ReferenceLabState
    extends State<Ch5A5UnderstandingReferencePointsAndRelativePositionPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Sim _sim = _Sim();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// 1-based current step, derived from the scene ([_deriveStep]).
  int _step = 1;

  /// The current scenario's conclusion has been scheduled.
  bool _concluded = false;

  /// Touch radius and label size in design pixels for the current stage
  /// scale (set while laying out the stage).
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  /// Pan of the scene layer in design px (0 while the sidebar is open).
  double _shiftTarget = 0;

  /// Where the finger holding the rope is (design px).
  Offset? _ropePointer;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_sim.scenario];

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
    _sim.load(0);
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

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame only advances the clock and repaints the canvas.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _sim.time = now;
    _frame.value = now;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)`: clears timers and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _sim.load(index);
      _step = 1;
      _concluded = false;
      _ropePointer = null;
    });
    _lab.resetView(sound: false);
  }

  /// The step ladder: a step is current until the learner has done what it
  /// says. Scenario 1 stays on step 2 while Deepa's result is shown and
  /// Scenario 2 on step 3 until the field reset, so the instruction shown
  /// never runs ahead of the scene.
  int _deriveStep() {
    final s = _sim;
    if (s.scenario == 0) {
      if (!s.measured(_Leg.deepaSchool)) return 1;
      if (!s.measured(_Leg.deepaGarden) || s.ref == _Ref.deepa) return 2;
      if (!s.measured(_Leg.tasneemSchool)) return 3;
      if (!s.measured(_Leg.tasneemGarden)) return 4;
      return s.compared ? 6 : 5;
    }
    return switch (s.phase) {
      _Phase.start => 1,
      _Phase.hardeep => 2,
      _Phase.hardeepCone || _Phase.padma || _Phase.padmaCone => 3,
      _Phase.flag => 4,
      _Phase.north => 5,
      _Phase.east => 6,
    };
  }

  /// Steps whose action is done: their observations are shown in the
  /// sidebar (the HTML showed each observation before the learner acted).
  int _doneSteps() {
    final s = _sim;
    if (s.scenario == 0) {
      return [
        s.measured(_Leg.deepaSchool),
        s.measured(_Leg.deepaGarden),
        s.measured(_Leg.tasneemSchool),
        s.measured(_Leg.tasneemGarden),
        s.compared,
      ].where((d) => d).length;
    }
    return switch (s.phase) {
      _Phase.start => 0,
      _Phase.hardeep => 1,
      _Phase.hardeepCone || _Phase.padma => 2,
      _Phase.padmaCone || _Phase.flag => 3,
      _Phase.north => 4,
      _Phase.east => 5,
    };
  }

  /// Rebuilds after a scene event and schedules the conclusion when the
  /// scenario is done.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
    if (_concluded) return;
    final s = _sim;
    final done = s.scenario == 0 ? s.compared : s.phase == _Phase.east;
    if (!done) return;
    _concluded = true;
    final scenario = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: scenario == 0 ? _s1ConclusionDelay : _s2ConclusionDelay,
      // HTML `#summary-modal` ("Scenario 1 Complete!") and, after the last
      // scenario, `#success-modal` ("Mastery Achieved!"), which hid the
      // Scenario 2 summary; both texts are shown here.
      title: () => scenario == 0
          ? labFormat(_t('sc_complete'), {'n': 1})
          : _t('all_complete'),
      heading: () => _t('summary_title'),
      body: () => scenario == 0
          ? _t('s1_summary')
          : '${_t('s2_summary')}\n\n${_t('all_complete_desc')}',
      extra: scenario == 0
          ? () => Builder(
              builder: (context) => _CompareTable(
                palette: _lab.palette,
                scale: context.labScale * _lab.fontScale.clamp(0.9, 1.4),
                refHeader: _t('tbl_ref'),
                schoolHeader: _t('school'),
                gardenHeader: _t('garden'),
                closerHeader: _t('tbl_closer'),
                rows: [
                  for (final r in _Ref.values)
                    (
                      _t(
                        r == _Ref.deepa
                            ? 'lbl_deepa_house'
                            : 'lbl_tasneem_house',
                      ),
                      _metres(_Leg.of(r, _Place.school).metres),
                      _metres(_Leg.of(r, _Place.garden).metres),
                      _t(r == _Ref.deepa ? 'school' : 'garden'),
                    ),
                ],
              ),
            )
          : null,
    );
  }

  String _metres(int m) => labFormat(_t('unit_m'), {'n': m});

  // ------------------------------------------------- scenario 1 actions

  /// HTML `performS1Action('school' | 'garden')`: measures from the current
  /// reference house (button or rope).
  void _measure(_Place place) {
    final s = _sim;
    if (s.scenario != 0 || s.shifting || s.compared) return;
    final leg = _Leg.of(s.ref, place);
    if (s.measured(leg)) return;
    if (place == _Place.garden && !s.measured(_Leg.of(s.ref, _Place.school))) {
      return;
    }
    _Sound.measure.play();
    s.legs[leg] = s.time;
    _lab.showToast(_t('t_${leg.name}'), sound: false);
    if (leg == _Leg.deepaGarden) {
      s.shifting = true;
      _lab.after(_shiftDelay, _shiftToTasneem);
    }
    _refresh();
  }

  /// HTML timeout after Deepa → Garden: the ring glides to Tasneem's house
  /// and Deepa's lines and badges are cleared.
  void _shiftToTasneem() {
    final s = _sim;
    if (!mounted || s.scenario != 0 || !s.shifting) return;
    s
      ..ref = _Ref.tasneem
      ..shifting = false
      ..ring = s.ring.moveTo(
        _tasneemSpot,
        s.time,
        _shiftSeconds,
        Curves.easeOutQuad,
      );
    _lab.showToast(_t('t_shift'), sound: false);
    _refresh();
  }

  /// HTML `performS1Action('compare')`.
  void _compare() {
    final s = _sim;
    if (s.scenario != 0 || s.compared || _deriveStep() != 5) return;
    _Sound.success.play();
    s.comparedAt = s.time;
    _lab.showToast(_t('t_compare'), sound: false);
    _refresh();
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `performS2Action('hardeep')`: the ring appears at his feet.
  void _selectHardeep() {
    final s = _sim;
    if (s.scenario != 1 || s.phase != _Phase.start) return;
    _Sound.measure.play();
    s
      ..ringOn = true
      ..ringAt = s.time
      ..ring = _Motion.still(s.hardeep.at(s.time))
      ..phase = _Phase.hardeep;
    _lab.showToast(_t('t_hardeep'), sound: false);
    _refresh();
  }

  /// HTML `performS2Action('cone1' | 'cone2')`: a cone 7 steps North of the
  /// selected person. After Padma's cone the field resets 3 s later (the
  /// HTML placed Padma's cone by itself 1 s after she was selected and never
  /// showed its "Place Cone" button).
  void _placeCone() {
    final s = _sim;
    if (s.scenario != 1) return;
    if (s.phase == _Phase.hardeep) {
      _Sound.measure.play();
      s
        ..marks.add(_Mark(_hardeepHome, _hardeepCone, 7, s.time))
        ..phase = _Phase.hardeepCone;
      _lab.showToast(_t('t_cone_hardeep'), sound: false);
    } else if (s.phase == _Phase.padma) {
      _Sound.measure.play();
      s
        ..marks.add(_Mark(_padmaHome, _padmaCone, 7, s.time))
        ..phase = _Phase.padmaCone;
      _lab.showToast(_t('t_cone_padma'), sound: false);
      _lab.after(_fieldResetDelay, _fieldReset);
    } else {
      return;
    }
    _refresh();
  }

  /// HTML `performS2Action('padma')`: the ring glides to her.
  void _selectPadma() {
    final s = _sim;
    if (s.scenario != 1 || s.phase != _Phase.hardeepCone) return;
    _Sound.measure.play();
    s
      ..ring = s.ring.moveTo(
        s.padma.at(s.time),
        s.time,
        _ringSelectSeconds,
        Curves.linear,
      )
      ..phase = _Phase.padma;
    _lab.showToast(_t('t_padma'), sound: false);
    _refresh();
  }

  /// HTML timeout after Padma's cone: cones cleared, central flag planted,
  /// ring to the flag.
  void _fieldReset() {
    final s = _sim;
    if (!mounted || s.scenario != 1 || s.phase != _Phase.padmaCone) return;
    s
      ..marks.clear()
      ..flagAt = s.time
      ..ring = s.ring.moveTo(_flagPos, s.time, _ringFlagSeconds, Curves.linear)
      ..phase = _Phase.flag;
    _lab.showToast(_t('t_field_reset'), sound: false);
    _refresh();
  }

  /// HTML `performS2Action('flag_north')`.
  void _coneNorth() {
    final s = _sim;
    if (s.scenario != 1 || s.phase != _Phase.flag) return;
    _Sound.measure.play();
    s
      ..marks.add(_Mark(_flagPos, _northCone, 7, s.time))
      ..phase = _Phase.north;
    _lab.showToast(_t('t_north'), sound: false);
    _refresh();
  }

  /// HTML `performS2Action('flag_east')`: the last cone; Hardeep and Padma
  /// walk to the shared flag and the court is outlined.
  void _coneEast() {
    final s = _sim;
    if (s.scenario != 1 || s.phase != _Phase.north) return;
    _Sound.success.play();
    s
      ..marks.add(_Mark(_flagPos, _eastCone, 10, s.time))
      ..hardeep = s.hardeep.moveTo(
        _hardeepEnd,
        s.time,
        _walkSeconds,
        Curves.linear,
      )
      ..padma = s.padma.moveTo(_padmaEnd, s.time, _walkSeconds, Curves.linear)
      ..courtAt = s.time
      ..phase = _Phase.east;
    _lab.showToast(_t('t_east'), sound: false);
    _refresh();
  }

  // -------------------------------------------------------------- gestures

  /// HTML "click Hardeep in 3D" (Scenario 2): taps on the people. Tapping
  /// the person whose turn it is not gives feedback.
  void _onTap(TapUpDetails d) {
    final s = _sim;
    if (!_lab.isLabActive || s.scenario != 1) return;
    final who = _personAt(d.localPosition);
    if (who == null) return;
    switch ((who, s.phase)) {
      case (_Who.hardeep, _Phase.start):
        _selectHardeep();
      case (_Who.padma, _Phase.hardeepCone):
        _selectPadma();
      case (_Who.padma, _Phase.start):
        _lab.showToast(_t('t_pick_hardeep'), isError: true);
      case (_Who.padma, _Phase.hardeep):
        _lab.showToast(_t('t_place_first'), isError: true);
      case (_Who.hardeep, _Phase.hardeepCone):
        _lab.showToast(_t('t_pick_padma'), isError: true);
      default:
        break;
    }
  }

  /// The person under [at] (body and head, at least a 48 dp target).
  _Who? _personAt(Offset at) {
    final s = _sim;
    double gap(_V pos) => (at - _cam.p(pos.atY(1))).distance;
    double reach(_V pos) => math.max(1.3 * _cam.scaleAt(pos), _touch);
    final h = s.hardeep.at(s.time), p = s.padma.at(s.time);
    final dh = gap(h), dp = gap(p);
    if (dh <= reach(h) && dh <= dp) return _Who.hardeep;
    if (dp <= reach(p)) return _Who.padma;
    return null;
  }

  /// Is [at] on the current reference house or the girl beside it?
  bool _onReference(Offset at) {
    final ref = _sim.ref;
    final spot = _spotOf(ref);
    final girl = (at - _cam.p(spot.atY(1))).distance;
    if (girl <= math.max(1.4 * _cam.scaleAt(spot), _touch)) return true;
    final house = ref == _Ref.deepa ? _deepaHouseRect : _tasneemHouseRect;
    return house.inflate(4).contains(at);
  }

  /// The place (school or garden) under [at], if any.
  _Place? _placeAt(Offset at) {
    final margin = _touch * 0.25;
    final school = _schoolRect.inflate(margin).contains(at);
    final garden = _gardenRect.inflate(margin).contains(at);
    if (school && garden) {
      return (at - _schoolRect.center).distance <=
              (at - _gardenRect.center).distance
          ? _Place.school
          : _Place.garden;
    }
    if (school) return _Place.school;
    if (garden) return _Place.garden;
    return null;
  }

  /// The HTML's "drag measuring rope" (promised by its instructions but never
  /// implemented): only the current reference house holds the rope, and only
  /// while a measurement is due.
  bool _canGrab(PointerDownEvent event) {
    final s = _sim;
    if (!_lab.isLabActive || s.scenario != 0) return false;
    if (s.shifting || s.compared || s.roping || _deriveStep() > 4) return false;
    return _onReference(event.localPosition);
  }

  void _onRopeStart(DragStartDetails d) {
    _sim.roping = true;
    _ropeTo(d.localPosition);
  }

  void _onRopeUpdate(DragUpdateDetails d) => _ropeTo(d.localPosition);

  /// Moves the rope's free end along the ground plane under the finger.
  void _ropeTo(Offset at) {
    final s = _sim;
    _ropePointer = at;
    final hit = _cam.onPlaneY(at, _lineY);
    if (hit != null) {
      s.ropeEnd = _V(
        hit.x.clamp(-_groundHalf, _groundHalf),
        _lineY,
        hit.z.clamp(-_groundHalf, _groundHalf),
      );
    }
    s.hover = _placeAt(at);
  }

  /// Rope let go: measures to the place under it, or says what is wrong.
  void _onRopeEnd(DragEndDetails _) {
    final s = _sim;
    if (!s.roping) return;
    final at = _ropePointer;
    final target = at == null ? null : _placeAt(at);
    _dropRope();
    if (s.scenario != 0 || s.shifting || s.compared) return;
    final school = _Leg.of(s.ref, _Place.school);
    if (target == null) {
      _lab.showToast(_t('t_rope_miss'), isError: true);
    } else if (target == _Place.garden && !s.measured(school)) {
      _lab.showToast(_t('t_school_first'), isError: true);
    } else if (target == _Place.school && s.measured(school)) {
      _lab.showToast(_t('t_school_done'), isError: true);
    } else {
      _measure(target);
    }
  }

  void _dropRope() {
    _sim
      ..roping = false
      ..hover = null;
    _ropePointer = null;
  }

  /// Pan that moves the scene's interactive part clear of the floating
  /// mission card while the sidebar is collapsed, without pushing its right
  /// side under the tool column.
  double _collapsedShift(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return 0;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = (size.width * _missionCardFraction).clamp(
      _missionCardMin,
      _missionCardMax * context.labScale,
    );
    final cardRight = (_missionCardLeft + pad.left + card - stageLeft) / fit;
    // The shell's tool column (its right-hand clearance, padding included);
    // nothing interactive may go past the stage's own right edge either.
    final tools = labOverlayInsets(context, _lab).right;
    final toolsLeft = math.min(
      _design.width,
      (size.width - tools - stageLeft) / fit,
    );
    final (left, right) = _sim.scenario == 0
        ? (_deepaHouseRect.left, _tasneemHouseRect.right)
        : (
            _cam.p(_hardeepHome).dx - _touch,
            _cam.p(_eastCone + const _V(1, 0, 0)).dx,
          );
    final room = math.max(0.0, toolsLeft - _cardGap - right);
    return (cardRight + _cardGap - left).clamp(0.0, room);
  }

  // -------------------------------------------------------------------- UI

  /// The buttons of the current state (HTML `#s1-controls` /
  /// `#s2-controls`, one of which is visible at a time). They play the
  /// HTML `measure` / `success` tone themselves.
  List<LabAction> _actions() {
    final s = _sim;
    if (s.scenario == 0) {
      if (s.compared) return const [];
      if (_step == 5) {
        return [
          LabAction(
            label: _t('btn_compare'),
            icon: Icons.compare_arrows,
            color: _Colors.amber500,
            highlight: true,
            silent: true,
            onTap: _compare,
          ),
        ];
      }
      final school = _Leg.of(s.ref, _Place.school);
      final garden = _Leg.of(s.ref, _Place.garden);
      return [
        LabAction(
          label: _t('btn_${school.name}'),
          icon: Icons.school,
          color: _Colors.indigo600,
          enabled: !s.shifting && !s.measured(school),
          silent: true,
          onTap: () => _measure(_Place.school),
        ),
        LabAction(
          label: _t('btn_${garden.name}'),
          icon: Icons.park,
          color: _Colors.emerald600,
          enabled: !s.shifting && s.measured(school) && !s.measured(garden),
          silent: true,
          onTap: () => _measure(_Place.garden),
        ),
      ];
    }
    LabAction button(
      String key,
      IconData icon,
      Color color,
      VoidCallback on, {
      bool enabled = true,
    }) => LabAction(
      label: _t(key),
      icon: icon,
      color: color,
      enabled: enabled,
      silent: true,
      onTap: on,
    );
    // Step 3 has two taps: both buttons are shown, the next one enabled.
    final padmaTurn = s.phase == _Phase.hardeepCone;
    return switch (s.phase) {
      _Phase.start => [
        button('btn_hardeep', Icons.person, _Colors.cyan600, _selectHardeep),
      ],
      _Phase.hardeep => [
        button('btn_cone', Icons.change_history, _Colors.amber600, _placeCone),
      ],
      _Phase.hardeepCone || _Phase.padma => [
        button(
          'btn_padma',
          Icons.person,
          _Colors.pink600,
          _selectPadma,
          enabled: padmaTurn,
        ),
        button(
          'btn_cone',
          Icons.change_history,
          _Colors.amber600,
          _placeCone,
          enabled: !padmaTurn,
        ),
      ],
      _Phase.flag => [
        button('btn_north', Icons.north, _Colors.indigo600, _coneNorth),
      ],
      _Phase.north => [
        button('btn_east', Icons.east, _Colors.emerald600, _coneEast),
      ],
      _Phase.padmaCone || _Phase.east => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final inset = labOverlayInsets(context, _lab);
        final pad = MediaQuery.paddingOf(context);
        final town = _sim.scenario == 0;
        return LabShell(
          controller: _lab,
          icon: Icons.my_location,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _sim.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          // HTML `#hud-instruction` (`hud[State.step]`); the last
          // instruction no longer applies once the scenario is done.
          showHud: _step <= data.steps.length,
          hud: _t('s${_sim.scenario + 1}_hud_${_step.clamp(1, _stepCount)}'),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          overlays: [
            // HTML `#bargraph-panel` (Scenario 1 only): top left of the
            // canvas, clear of the town; while the sidebar is collapsed the
            // mission card is there, so it moves to the bottom left.
            if (town && _lab.isLabActive)
              _lab.isSidebarOpen
                  ? Positioned(
                      top: inset.top + _graphBelowToast * s,
                      left: inset.left,
                      child: _barGraph(s),
                    )
                  : Positioned(
                      bottom: inset.bottom,
                      left: _cardGap + pad.left,
                      child: _barGraph(s),
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
          _shiftTarget = _lab.isSidebarOpen ? 0 : _collapsedShift(context);
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        return LabStage(
          designSize: _design,
          // The pan slides the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(_shiftTarget / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags and taps on the scene are not screen-reader actions
                // (the buttons do the same); the scene is announced by its
                // label instead.
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
                          ..onStart = _onRopeStart
                          ..onUpdate = _onRopeUpdate
                          ..onEnd = _onRopeEnd
                          ..onCancel = _dropRope,
                      ),
                  TapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer
                      >(
                        () => TapGestureRecognizer(debugOwner: this),
                        (r) => r.onTapUp = _onTap,
                      ),
                },
                child: Semantics(
                  image: true,
                  label: _t(_sim.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: _design,
                      painter: _ScenePainter(
                        sim: _sim,
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
          ),
        );
      },
    );
  }

  /// HTML `#bargraph-panel`: distances from the current reference house
  /// (`updateBarGraphUI`).
  Widget _barGraph(double s) {
    final ref = _sim.ref;
    final school = _Leg.of(ref, _Place.school);
    final garden = _Leg.of(ref, _Place.garden);
    final sm = _sim.measured(school) ? school.metres : null;
    final gm = _sim.measured(garden) ? garden.metres : null;
    final deepa = ref == _Ref.deepa;
    return _BarGraphCard(
      scale: s,
      title: _t('bg_title'),
      refLabel: _t(deepa ? 'bg_ref_deepa' : 'bg_ref_tasneem'),
      schoolLabel: _t('school'),
      gardenLabel: _t('garden'),
      school: sm,
      garden: gm,
      schoolText: sm == null ? _t('no_value') : _metres(sm),
      gardenText: gm == null ? _t('no_value') : _metres(gm),
      conclusion: gm == null
          ? ''
          : _t(deepa ? 'bg_closer_deepa' : 'bg_closer_tasneem'),
    );
  }

  /// Sidebar list of the observations of the steps done so far.
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final done = _doneSteps().clamp(0, steps.length);
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

/// HTML `#bargraph-panel`: title, reference badge, one bar per place (scaled
/// to 9 m) and the "closer" line. Dark in both themes, as in the HTML.
class _BarGraphCard extends StatelessWidget {
  const _BarGraphCard({
    required this.scale,
    required this.title,
    required this.refLabel,
    required this.schoolLabel,
    required this.gardenLabel,
    required this.school,
    required this.garden,
    required this.schoolText,
    required this.gardenText,
    required this.conclusion,
  });

  final double scale;
  final String title;
  final String refLabel;
  final String schoolLabel;
  final String gardenLabel;

  /// Measured distances in metres (null: not measured yet).
  final int? school;
  final int? garden;
  final String schoolText;
  final String gardenText;
  final String conclusion;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget bar(String label, String value, int? metres, Color color) {
      return Padding(
        padding: EdgeInsets.only(top: 6 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _Colors.slate300,
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 6 * s),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3 * s),
            Container(
              height: 9 * s,
              padding: EdgeInsets.all(1.5 * s),
              decoration: BoxDecoration(
                color: _Colors.graphTrack,
                borderRadius: BorderRadius.circular(9 * s),
                border: Border.all(color: _Colors.graphTrackEdge),
              ),
              alignment: Alignment.centerLeft,
              // HTML `transition-all duration-700`.
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (metres ?? 0) / _graphMaxMetres),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, v, _) => FractionallySizedBox(
                  widthFactor: v.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(9 * s),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 168 * s,
      child: Container(
        padding: EdgeInsets.fromLTRB(9 * s, 7 * s, 9 * s, 8 * s),
        decoration: BoxDecoration(
          color: _Colors.graphBg,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: _Colors.graphEdge),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadow,
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 13 * s, color: _Colors.indigo400),
                SizedBox(width: 4 * s),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _Colors.indigo400,
                      fontSize: 9.5 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(title, 0.6),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * s),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5 * s,
                  vertical: 1.5 * s,
                ),
                decoration: BoxDecoration(
                  color: _Colors.badgeBg,
                  borderRadius: BorderRadius.circular(4 * s),
                  border: Border.all(color: _Colors.amberEdge),
                ),
                child: Text(
                  refLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _Colors.amber300,
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            bar(schoolLabel, schoolText, school, _Colors.indigo300),
            bar(gardenLabel, gardenText, garden, _Colors.emerald300),
            if (conclusion.isNotEmpty) ...[
              SizedBox(height: 5 * s),
              Text(
                '✓ $conclusion',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _Colors.amber300,
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sidebar list of the observations made so far, one per finished step.
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

/// Scenario 1 summary table (added to the conclusion popup): the distances
/// from each reference house and which place is closer.
class _CompareTable extends StatelessWidget {
  const _CompareTable({
    required this.palette,
    required this.scale,
    required this.refHeader,
    required this.schoolHeader,
    required this.gardenHeader,
    required this.closerHeader,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String refHeader;
  final String schoolHeader;
  final String gardenHeader;
  final String closerHeader;

  /// (reference house, to the school, to the garden, closer place).
  final List<(String, String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10 * f,
      fontWeight: FontWeight.w800,
    );
    final body = TextStyle(
      color: p.text,
      fontSize: 11 * f,
      fontWeight: FontWeight.w600,
    );
    Widget cell(String text, TextStyle style, int flex, {bool end = false}) =>
        Expanded(
          flex: flex,
          child: Text(
            text,
            style: style,
            textAlign: end ? TextAlign.end : TextAlign.start,
          ),
        );
    Widget row(
      List<Widget> cells, {
      Color? fill,
      bool divider = true,
    }) => Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
      decoration: BoxDecoration(
        color: fill,
        border: divider ? Border(top: BorderSide(color: p.cardBorder)) : null,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells),
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
            [
              cell(refHeader, head, 3),
              cell(schoolHeader, head, 2, end: true),
              cell(gardenHeader, head, 2, end: true),
              cell(closerHeader, head, 2, end: true),
            ],
            fill: p.cardBorder.withValues(alpha: 0.3),
            divider: false,
          ),
          for (final r in rows)
            row([
              cell(r.$1, body, 3),
              cell(r.$2, body, 2, end: true),
              cell(r.$3, body, 2, end: true),
              cell(
                r.$4,
                body.copyWith(color: p.success, fontWeight: FontWeight.w800),
                2,
                end: true,
              ),
            ]),
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

  /// Round-ended lines (grid, ropes, glyphs).
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// Soft glow under the measuring lines and around the reference ring.
  final Paint glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  /// HTML `animate-glow` behind the REFERENCE POINT tags.
  final Paint halo = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Path path = Path();
}

/// The colours of a scene label chip (HTML `#labels-container` children).
enum _ChipStyle {
  deepa(_Colors.amber300, _Colors.chipDark, _Colors.amberEdge),
  tasneem(_Colors.purple300, _Colors.chipDark, _Colors.purpleEdge),
  school(_Colors.white, _Colors.chipIndigo, _Colors.indigo400),
  garden(_Colors.white, _Colors.chipEmerald, _Colors.emerald400),
  hardeep(_Colors.cyan300, _Colors.chipDark, _Colors.cyanEdge),
  padma(_Colors.pink300, _Colors.chipDark, _Colors.pinkEdge),
  flag(_Colors.white, _Colors.chipAmber, _Colors.amber300),
  steps(_Colors.orange300, _Colors.chipDark, _Colors.orangeEdge),
  compass(_Colors.white, _Colors.chipDark, _Colors.slate500),
  refPoint(_Colors.slate950, _Colors.zslYellow, _Colors.white);

  const _ChipStyle(this.text, this.fill, this.border);

  final Color text;
  final Color fill;
  final Color border;
}

/// What the painter makes once and reuses: pens, the static backdrop (sky,
/// ground and grid) and the label text painters. Owned by the page state and
/// disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text, Color color, {double scale = 1}) =>
      _labels['${color.toARGB32()}|$scale|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: _labelSize * scale,
            fontWeight: FontWeight.w800,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// The static part of [scenario]'s scene, recorded once.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, size, pens);
    _backdropScenario = scenario;
    _backdropDark = dark;
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

/// The scene's static layer: sky, ground plane and grid
/// (`PlaneGeometry(30, 30)` + `GridHelper`).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.skyDark : _Colors.skyLight,
  );
  final g = _Gfx(canvas, pens);
  const h = _groundHalf;
  g.poly(const [
    _V(-h, 0, -h),
    _V(h, 0, -h),
    _V(h, 0, h),
    _V(-h, 0, h),
  ], _lit(scenario == 0 ? _Colors.groundTown : _Colors.groundField, _V.up));
  final divisions = scenario == 0 ? _townGridDivisions : _fieldGridDivisions;
  final centre = scenario == 0 ? _Colors.gridTown : _Colors.gridField;
  // Grid lines first, the two centre lines on top (`grid.position.y = 0.01`).
  for (final main in const [false, true]) {
    final paint = pens.line
      ..strokeWidth = main ? 1.4 : 1
      ..color = main ? centre : _Colors.gridLine;
    for (var i = 0; i <= divisions; i++) {
      if ((i * 2 == divisions) != main) continue;
      final v = -h + 2 * h * i / divisions;
      canvas.drawLine(_cam.p(_V(v, 0.01, -h)), _cam.p(_V(v, 0.01, h)), paint);
      canvas.drawLine(_cam.p(_V(-h, 0.01, v)), _cam.p(_V(h, 0.01, v)), paint);
    }
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
  _Face(_V(0, 0, 1), [_V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)]),
  _Face(_V(0, 0, -1), [
    _V(-1, -1, -1),
    _V(-1, 1, -1),
    _V(1, 1, -1),
    _V(1, -1, -1),
  ]),
];

/// Pop-in scale ([e] seconds after appearing).
double _pop(double e) {
  if (e < 0) return 0;
  if (e >= _popSeconds) return 1;
  return math.max(0.01, Curves.easeOutBack.transform(e / _popSeconds));
}

/// Mesh drawing in the scene camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.pens);

  final Canvas canvas;
  final _Pens pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat polygon (already lit [color]); optional rim [edge] colour.
  void poly(List<_V> pts, Color color, {Color? edge}) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _move(path, i, _cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.35}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(_cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _move(
          path,
          i,
          _cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        );
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = _lit(color, n));
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

  /// A 4-sided ConeGeometry turned 45° (a square roof): base square of half
  /// size [half] at [base], apex [height] above it.
  void pyramid(_V base, double half, double height, Color color) {
    final apex = base + _V(0, height, 0);
    final corners = [
      base + _V(-half, 0, -half),
      base + _V(half, 0, -half),
      base + _V(half, 0, half),
      base + _V(-half, 0, half),
    ];
    final pa = _cam.p(apex);
    for (var i = 0; i < 4; i++) {
      final a = corners[i], b = corners[(i + 1) % 4];
      final n = (apex - a).cross(b - a).unit;
      final mid = (a + b + apex) * (1 / 3);
      if (n.dot(_cam.eye - mid) <= 0) continue;
      final pA = _cam.p(a), pB = _cam.p(b);
      final path = pens.path
        ..reset()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pa.dx, pa.dy)
        ..close();
      canvas.drawPath(path, pens.fill..color = _lit(color, n));
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.45).withValues(alpha: 0.5),
      );
    }
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double _ellipseHalf(_V c, double radius) =>
      (_cam.p(c + _V(0, 0, radius)).dy - _cam.p(c - _V(0, 0, radius)).dy)
          .abs() /
      2;

  Rect _oval(_V c, double radius) => Rect.fromCenter(
    center: _cam.p(c),
    width: 2 * radius * _cam.scaleAt(c),
    height: 2 * _ellipseHalf(c, radius),
  );

  /// Round ConeGeometry standing on [base]: front half lit from the right
  /// (the key light is at +x).
  void cone(_V base, double radius, double height, Color color) {
    final pt = _cam.p(base + _V(0, height, 0));
    final oval = _oval(base, radius);
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx, pt.dy)
      ..lineTo(oval.left, oval.center.dy)
      ..arcTo(oval, math.pi, -math.pi, false)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(-0.6, 0.45, 0.66)),
    );
    path
      ..reset()
      ..moveTo(pt.dx, pt.dy)
      ..lineTo(oval.center.dx, oval.bottom)
      ..arcTo(oval, math.pi / 2, -math.pi / 2, false)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(0.6, 0.45, 0.66)),
    );
  }

  /// Upright (tapered) CylinderGeometry standing on [bottom]: side lit from
  /// the right, then the top cap.
  void cylinder(
    _V bottom,
    double rBottom,
    double rTop,
    double height,
    Color color,
  ) {
    final top = bottom + _V(0, height, 0);
    final bOval = _oval(bottom, rBottom);
    final tOval = _oval(top, rTop);
    final path = pens.path
      ..reset()
      ..moveTo(tOval.left, tOval.center.dy)
      ..lineTo(bOval.left, bOval.center.dy)
      ..arcTo(bOval, math.pi, -math.pi, false)
      ..lineTo(tOval.right, tOval.center.dy)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(-0.7, 0, 0.7)),
    );
    path
      ..reset()
      ..moveTo(tOval.center.dx, tOval.center.dy)
      ..lineTo(bOval.center.dx, bOval.bottom)
      ..arcTo(bOval, math.pi / 2, -math.pi / 2, false)
      ..lineTo(tOval.right, tOval.center.dy)
      ..close();
    canvas.drawPath(
      path,
      pens.fill..color = _lit(color, const _V(0.7, 0, 0.7)),
    );
    canvas.drawOval(tOval, pens.fill..color = _lit(color, _V.up));
  }

  /// SphereGeometry: shaded side, lit side towards the key light and a
  /// highlight.
  void sphere(_V c, double radius, Color color) {
    final o = _cam.p(c);
    final r = radius * _cam.scaleAt(c);
    canvas.drawCircle(
      o,
      r,
      pens.fill..color = _lit(color, const _V(-0.6, 0.2, 0.77)),
    );
    canvas.drawCircle(
      o + Offset(r * 0.15, -r * 0.15),
      r * 0.78,
      pens.fill..color = _lit(color, _light),
    );
    canvas.drawCircle(
      o + Offset(r * 0.32, -r * 0.34),
      r * 0.2,
      pens.fill..color = LabInk.white.withValues(alpha: 0.35),
    );
  }

  /// A flat ring on the ground between [inner] and [outer] radius.
  void groundRing(_V c, double inner, double outer, Color color) {
    final path = pens.path
      ..reset()
      ..fillType = PathFillType.evenOdd
      ..addOval(_oval(c, outer))
      ..addOval(_oval(c, inner));
    canvas.drawPath(path, pens.fill..color = color);
    path.fillType = PathFillType.nonZero;
  }

  /// `createCharacter(color)`: body `CylinderGeometry(0.4, 0.5, 1.4)` and a
  /// yellow head `SphereGeometry(0.45)` at 1.65.
  void person(_V at, Color color) {
    cylinder(at, 0.5, 0.4, 1.4, color);
    sphere(at + const _V(0, 1.65, 0), 0.45, _Colors.head);
  }

  /// HTML glowing dashed line (`LineDashedMaterial`, dash 0.5, gap 0.3)
  /// from [a] towards [b], drawn out to fraction [t].
  void dashed(_V a, _V b, double t, Color color, {double width = 2.5}) {
    if (t <= 0) return;
    final pa = _cam.p(a), pb = _cam.p(_V.lerp(a, b, t));
    canvas.drawLine(
      pa,
      pb,
      pens.glow
        ..strokeWidth = width * 2.6
        ..color = color.withValues(alpha: 0.45 * color.a),
    );
    final k = _cam.scaleAt(_V.lerp(a, b, t / 2));
    labDashedLine(
      canvas,
      pa,
      pb,
      pens.line
        ..strokeWidth = width
        ..color = color,
      dash: 0.5 * k,
      gap: 0.3 * k,
    );
  }

  /// `createBadge('check' | 'x')`: green / red disc with a white rim and
  /// mark, 1.8 units wide (sprites keep their world size), scaled by [k].
  void badge(_V c, bool check, double k) {
    if (k <= 0) return;
    final o = _cam.p(c);
    final r = _badgeRadius * _cam.scaleAt(c) * k;
    canvas.drawCircle(
      o,
      r,
      pens.fill..color = check ? _Colors.badgeCheck : _Colors.badgeCross,
    );
    canvas.drawCircle(
      o,
      r,
      pens.stroke
        ..strokeWidth = r * 0.12
        ..color = LabInk.white,
    );
    // The ✓ / ✗ glyph, in fractions of the badge radius.
    final path = pens.path..reset();
    if (check) {
      path
        ..moveTo(o.dx - r * 0.42, o.dy + r * 0.02)
        ..lineTo(o.dx - r * 0.1, o.dy + r * 0.34)
        ..lineTo(o.dx + r * 0.45, o.dy - r * 0.32);
    } else {
      path
        ..moveTo(o.dx - r * 0.32, o.dy - r * 0.32)
        ..lineTo(o.dx + r * 0.32, o.dy + r * 0.32)
        ..moveTo(o.dx + r * 0.32, o.dy - r * 0.32)
        ..lineTo(o.dx - r * 0.32, o.dy + r * 0.32);
    }
    canvas.drawPath(
      path,
      pens.line
        ..strokeWidth = r * 0.2
        ..color = LabInk.white,
    );
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the town with
/// the two houses, the school and the garden; S2 the playground with
/// Hardeep, Padma, the cones and the central flag. Static parts come from
/// [_PaintCache].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.sim,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Sim sim;
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
    canvas.drawPicture(cache.backdrop(sim.scenario, isDark, size));
    final g = _Gfx(canvas, _pens);
    if (sim.scenario == 0) {
      _paintTown(canvas, g);
    } else {
      _paintField(canvas, g);
    }
  }

  /// The yellow reference ring, pulsing, popped in from [sim.ringAt].
  void _ring(_Gfx g) {
    final t = sim.time;
    final k = _pop(t - sim.ringAt);
    if (k <= 0) return;
    final c = sim.ring.at(t).atY(_ringY);
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi);
    g.groundRing(
      c,
      _ringInner * k,
      (_ringOuter + _ringPulse * pulse) * k,
      _Colors.ring.withValues(alpha: 0.25),
    );
    g.groundRing(c, _ringInner * k, _ringOuter * k, _Colors.ring);
  }

  // ---------------------------------------------------------- scenario 1

  /// When the line of [leg] started drawing out, or null while it is hidden
  /// (HTML: Deepa's lines are cleared at the shift and shown again by
  /// Compare Results).
  double? _lineStart(_Leg leg) {
    final at = sim.legs[leg];
    if (at == null) return null;
    if (sim.compared) {
      return leg.ref == _Ref.deepa ? sim.comparedAt : at;
    }
    return leg.ref == sim.ref ? at : null;
  }

  void _paintTown(Canvas canvas, _Gfx g) {
    final s = sim;
    final t = s.time;

    // On the ground: the reference ring, the measuring lines and, while the
    // rope is held, a pulsing ring around the place under it.
    _ring(g);
    for (final leg in _Leg.values) {
      final start = _lineStart(leg);
      if (start == null) continue;
      g.dashed(
        _spotOf(leg.ref).atY(_lineY),
        _placePos(leg.place).atY(_lineY),
        ((t - start) / _growSeconds).clamp(0.0, 1.0),
        leg.place == _Place.school ? _Colors.lineSchool : _Colors.lineGarden,
      );
    }
    final hover = s.roping ? s.hover : null;
    if (hover != null) {
      final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
      g.groundRing(
        _placePos(hover).atY(_ringY),
        _hoverInner,
        _hoverOuter + 0.2 * pulse,
        _Colors.ring.withValues(alpha: 0.5 + 0.4 * pulse),
      );
    }

    // Buildings and girls, far to near (the order is fixed: nothing moves).
    _paintSchool(g);
    _paintGarden(g);
    _paintHouse(g, _deepaHouse, _Colors.deepa);
    _paintHouse(g, _tasneemHouse, _Colors.tasneem);
    g.person(_deepaSpot, _Colors.deepa);
    g.person(_tasneemSpot, _Colors.tasneem);

    // The lines again, faintly, over the buildings: the garden stands right
    // behind Tasneem's house, whose roof would hide her garden line.
    for (final leg in _Leg.values) {
      final start = _lineStart(leg);
      if (start == null) continue;
      g.dashed(
        _spotOf(leg.ref).atY(_lineY),
        _placePos(leg.place).atY(_lineY),
        ((t - start) / _growSeconds).clamp(0.0, 1.0),
        (leg.place == _Place.school ? _Colors.lineSchool : _Colors.lineGarden)
            .withValues(alpha: _seeThrough),
      );
    }

    // The rope in the learner's hand (over everything it crosses).
    if (s.roping) {
      final from = _spotOf(s.ref).atY(_lineY);
      g.dashed(from, s.ropeEnd, 1, _Colors.zslYellow, width: 3);
      canvas.drawCircle(
        _cam.p(s.ropeEnd),
        _ropeKnob,
        _pens.fill..color = _Colors.zslYellow,
      );
    }

    // HTML badge sprites: School ✓ / Garden ✗ after Deepa's second
    // measurement, the other way round after Tasneem's, both ✓ at Compare.
    final (bool, bool, double)? badges = s.compared
        ? (true, true, s.comparedAt)
        : s.ref == _Ref.deepa && s.measured(_Leg.deepaGarden)
        ? (true, false, s.legs[_Leg.deepaGarden]!)
        : s.ref == _Ref.tasneem && s.measured(_Leg.tasneemGarden)
        ? (false, true, s.legs[_Leg.tasneemGarden]!)
        : null;
    if (badges != null) {
      final k = _pop(t - badges.$3);
      g.badge(_schoolPos.atY(_schoolBadgeY), badges.$1, k);
      g.badge(_gardenPos.atY(_gardenBadgeY), badges.$2, k);
    }

    if (!showLabels) return;
    _chip(
      canvas,
      _cam.p(_schoolPos.atY(_schoolLabelY)),
      _t('school'),
      _ChipStyle.school,
    );
    _chip(
      canvas,
      _cam.p(_gardenPos.atY(_gardenLabelY)),
      _t('garden'),
      _ChipStyle.garden,
    );
    // House names in front of the houses, each reaching in towards the
    // middle; at Compare a glowing REFERENCE POINT tag under each (the
    // HTML's tag was never visible: it kept its `opacity-0` class).
    for (final ref in _Ref.values) {
      final deepa = ref == _Ref.deepa;
      final house = _houseOf(ref);
      final anchor = _cam.p(
        house + _V(deepa ? -1.25 : 1.25, 0, _houseLabelAhead),
      );
      final rect = _chip(
        canvas,
        anchor,
        _t(deepa ? 'lbl_deepa_house' : 'lbl_tasneem_house'),
        deepa ? _ChipStyle.deepa : _ChipStyle.tasneem,
        alignX: deepa ? -1 : 1,
      );
      if (s.compared) {
        final glow = 0.5 + 0.5 * math.sin(t * math.pi);
        _chip(
          canvas,
          Offset(deepa ? rect.left : rect.right, rect.bottom + 4),
          _t('lbl_ref_point'),
          _ChipStyle.refPoint,
          alignX: deepa ? -1 : 1,
          alignY: -1,
          halo: 0.5 + 0.5 * glow,
          pop: _pop(t - s.comparedAt),
        );
      }
    }
  }

  /// `createHouse(color)`: wall box 2.5 × 2 × 2.5 and a square roof
  /// (`ConeGeometry(2.2, 1.5, 4)` turned 45°, eaves 1.56 from the centre).
  void _paintHouse(_Gfx g, _V at, Color roof) {
    g.box(at + const _V(0, 1, 0), const _V(2.5, 2, 2.5), _Colors.houseWall);
    g.pyramid(at + const _V(0, 2, 0), 1.56, 1.5, roof);
  }

  /// `createSchool()`: block 5 × 3 × 3, tower 2 × 4.5 × 2 (only its part
  /// above the block is drawn after it) and a square roof
  /// (`ConeGeometry(1.8, 1.2, 4)` at 5).
  void _paintSchool(_Gfx g) {
    final c = _schoolPos;
    g.box(c + const _V(0, 1.5, 0), const _V(5, 3, 3), _Colors.schoolBlock);
    g.box(c + const _V(0, 3.75, 0), const _V(2, 1.5, 2), _Colors.schoolTower);
    g.pyramid(c + const _V(0, 4.4, 0), 1.27, 1.2, _Colors.schoolRoof);
  }

  /// `createGarden()`: fence slab 4.5 × 0.4 × 4.5, a cone tree at
  /// (-1, _, -1) and a round tree at (1, 1.2, 1).
  void _paintGarden(_Gfx g) {
    final c = _gardenPos;
    g.box(c + const _V(0, 0.2, 0), const _V(4.5, 0.4, 4.5), _Colors.fence);
    g.cone(c + const _V(-1, 0.25, -1), 1.2, 2.5, _Colors.coneTree);
    g.sphere(c + const _V(1, 1.2, 1), 1, _Colors.roundTree);
  }

  // ---------------------------------------------------------- scenario 2

  void _paintField(Canvas canvas, _Gfx g) {
    final s = sim;
    final t = s.time;

    _paintCompass(canvas, g);
    if (s.courtAt >= 0) {
      _paintCourt(canvas, g, ((t - s.courtAt) / _fadeSeconds).clamp(0.0, 1.0));
    }
    if (s.ringOn) _ring(g);
    for (final m in s.marks) {
      _paintMarkLine(canvas, g, m);
    }

    // People, the flag and the cones, far to near.
    final hardeep = s.hardeep.at(t);
    final padma = s.padma.at(t);
    final items = <(double, int)>[
      (_cam.depth(hardeep), -1),
      (_cam.depth(padma), -2),
      if (s.flagAt >= 0) (_cam.depth(_flagPos), -3),
      for (var i = 0; i < s.marks.length; i++)
        if (t - s.marks[i].at >= _growSeconds) (_cam.depth(s.marks[i].to), i),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, id) in items) {
      switch (id) {
        case -1:
          g.person(hardeep, _Colors.hardeep);
        case -2:
          g.person(padma, _Colors.padma);
        case -3:
          _paintFlag(g, _pop(t - s.flagAt));
        default:
          final m = s.marks[id];
          final k = _pop(t - m.at - _growSeconds);
          // `createCone3D()`: ConeGeometry(0.5, 1.2) on the ground.
          g.cone(m.to, 0.5 * k, 1.2 * k, _Colors.cone);
      }
    }

    if (!showLabels) return;
    // Names on the ground in front of the people, reaching away from each
    // other (they stand side by side at the end).
    _chip(
      canvas,
      _cam.p(hardeep + const _V(0.4, 0, _personLabelAhead)),
      _t('lbl_hardeep'),
      _ChipStyle.hardeep,
      alignX: 1,
    );
    _chip(
      canvas,
      _cam.p(padma + const _V(-0.4, 0, _personLabelAhead)),
      _t('lbl_padma'),
      _ChipStyle.padma,
      alignX: -1,
    );
    if (s.flagAt >= 0) {
      // HTML `animate-bounce`.
      final bounce = (math.sin(t * math.pi * 2)).abs() * 4;
      _chip(
        canvas,
        _cam.p(_flagLabelAt) - Offset(0, bounce),
        _t('lbl_flag'),
        _ChipStyle.flag,
        alignX: 1,
      );
    }
    for (final m in s.marks) {
      if (t - m.at < _growSeconds) continue;
      _chip(
        canvas,
        _cam.p(m.to.atY(_stepTagY)),
        labFormat(_t('lbl_steps'), {'n': m.steps}),
        _ChipStyle.steps,
        scale: 0.85,
      );
    }
  }

  /// A cone line drawn out from the person or flag, with a marker at every
  /// step (the HTML observation's "step markers").
  void _paintMarkLine(Canvas canvas, _Gfx g, _Mark m) {
    final grow = ((sim.time - m.at) / _growSeconds).clamp(0.0, 1.0);
    final a = m.from.atY(_coneLineY), b = m.to.atY(_coneLineY);
    g.dashed(a, b, grow, _Colors.lineCone);
    for (var i = 1; i < m.steps; i++) {
      final f = i / m.steps;
      if (f > grow) break;
      final w = _V.lerp(a, b, f);
      final r = _stepDot * _cam.scaleAt(w);
      final o = _cam.p(w);
      canvas.drawCircle(o, r, _pens.fill..color = _Colors.white);
      canvas.drawCircle(
        o,
        r,
        _pens.stroke
          ..strokeWidth = 1.2
          ..color = _Colors.lineCone,
      );
    }
  }

  /// `createFlag()`: pole `CylinderGeometry(0.08, 0.08, 3.5)` and cloth
  /// 1.2 × 0.8 at (0.6, 3, 0), popped in by [k].
  void _paintFlag(_Gfx g, double k) {
    if (k <= 0) return;
    g.cylinder(_flagPos, 0.08, 0.08, 3.5 * k, _Colors.pole);
    g.box(
      _flagPos + _V(0.6 * k, 3 * k, 0),
      _V(1.2 * k, 0.8 * k, 0.05),
      _Colors.cloth,
      edge: 0.4,
    );
  }

  /// The Kabaddi court (added): centred on the flag, through the two cones,
  /// with its mid line; chalk fading in by [a].
  void _paintCourt(Canvas canvas, _Gfx g, double a) {
    final paint = _pens.line
      ..strokeWidth = 2
      ..color = _Colors.chalk.withValues(alpha: _Colors.chalk.a * a);
    const x = _courtHalfX, z = _courtHalfZ, y = 0.02;
    const corners = [_V(-x, y, -z), _V(x, y, -z), _V(x, y, z), _V(-x, y, z)];
    for (var i = 0; i < 4; i++) {
      labDashedLine(
        canvas,
        _cam.p(corners[i]),
        _cam.p(corners[(i + 1) % 4]),
        paint,
        dash: 10,
        gap: 6,
      );
    }
    labDashedLine(
      canvas,
      _cam.p(const _V(0, y, -z)),
      _cam.p(const _V(0, y, z)),
      paint,
      dash: 10,
      gap: 6,
    );
  }

  /// Compass rose (added): North (-z) and East (+x) arrows on the ground.
  void _paintCompass(Canvas canvas, _Gfx g) {
    const c = _compassPos;
    final o = _cam.p(c);
    canvas.drawOval(
      g._oval(c, _compassDial),
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.white.withValues(alpha: 0.5),
    );
    labArrow(
      canvas,
      o,
      _cam.p(c + const _V(0, 0, -_compassArrow)),
      color: _Colors.red500,
      width: 2.5,
      head: 8,
    );
    labArrow(
      canvas,
      o,
      _cam.p(c + const _V(_compassArrow, 0, 0)),
      color: _Colors.white,
      width: 2.5,
      head: 8,
    );
    if (!showLabels) return;
    _chip(
      canvas,
      _cam.p(c + const _V(0, 0, -_compassLetter)),
      _t('lbl_north'),
      _ChipStyle.compass,
      scale: 0.8,
    );
    _chip(
      canvas,
      _cam.p(c + const _V(_compassLetter, 0, 0)),
      _t('lbl_east'),
      _ChipStyle.compass,
      scale: 0.8,
    );
  }

  // ------------------------------------------------------------ labels

  /// A label chip (HTML `#labels-container` child) placed by [alignX] /
  /// [alignY] (-1: the chip's left / top edge on [at], 1: its right /
  /// bottom edge, 0: centred). [halo] adds the HTML `animate-glow` behind
  /// it; [pop] scales it about [at] while it pops in. Returns the chip's
  /// rect (unscaled).
  Rect _chip(
    Canvas canvas,
    Offset at,
    String text,
    _ChipStyle style, {
    double alignX = 0,
    double alignY = 0,
    double scale = 1,
    double halo = 0,
    double pop = 1,
  }) {
    final tp = cache.label(text, style.text, scale: scale);
    final size = cache.labelSize * scale;
    final padX = size * 0.6, padY = size * 0.28;
    final w = tp.width + 2 * padX, h = tp.height + 2 * padY;
    final rect = Rect.fromLTWH(
      at.dx - (alignX + 1) / 2 * w,
      at.dy - (alignY + 1) / 2 * h,
      w,
      h,
    );
    if (pop <= 0) return rect;
    final scaled = pop < 1;
    if (scaled) {
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..scale(pop)
        ..translate(-at.dx, -at.dy);
    }
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.45));
    if (halo > 0) {
      canvas.drawRRect(
        rr.inflate(3),
        _pens.halo..color = style.fill.withValues(alpha: 0.8 * halo),
      );
    }
    canvas.drawRRect(rr, _pens.fill..color = style.fill);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = style == _ChipStyle.refPoint ? 2 : 1
        ..color = style.border,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
    if (scaled) canvas.restore();
    return rect;
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.sim != sim ||
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
