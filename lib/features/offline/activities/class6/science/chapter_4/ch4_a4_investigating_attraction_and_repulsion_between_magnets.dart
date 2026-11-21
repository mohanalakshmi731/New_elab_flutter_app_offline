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

/// Class 6 Science • Chapter 4 • Activity 4
/// Investigating Attraction & Repulsion between Magnets.
///
/// Native Flutter port of
/// `Cl6S-Ch4-A4-Investigating_Attraction_and_Repulsion_between_Magnets.html`
/// (Three.js r128 + Tween.js). The Three.js lab table is redrawn in 2D by
/// [_ScenePainter] with the HTML camera (45° field of view, looking at the
/// table centre from (0, 14, 18), (0, 12, 22) or (0, 15, 15)); the HTML
/// pointer handlers become a pan recogniser that only claims touches that
/// start on a draggable object.
///
/// Scenario 1 (Rolling Magnet Experiment): drag the six round pencils from
/// the shelf onto the highlighted drop zone and Bar Magnet A on top of them.
/// Bring Bar Magnet B's North pole to Magnet A's North pole (A rolls away),
/// tap 'Flip Magnet B' and bring its South pole (A rolls forward and snaps
/// on), then flip it back and test South against South (A rolls away again).
/// The observation table fills in and 'Validate Model' opens the summary.
///
/// Scenario 2 (Ring Magnet Levitation): drag Ring Magnet 1 onto the wooden
/// spindle (it slides to the base) and Ring Magnet 2, North pole down, onto
/// it: like poles repel and it floats. 'Flip Ring Magnet 2' lifts it off and
/// turns it over; dropped on the spindle again, unlike poles attract and it
/// snaps down onto Ring Magnet 1.
///
/// Scenario 3 (Compass Deflection Test): drag the brass compass onto the
/// centre of the table and watch its needle settle pointing North. Bring
/// the bar magnet's North pole near the needle (its North tip swings away),
/// then its South pole (the North tip swings towards it): the needle is a
/// small magnet itself.
class Ch4A4InvestigatingAttractionAndRepulsionBetweenMagnetsPage
    extends StatefulWidget {
  const Ch4A4InvestigatingAttractionAndRepulsionBetweenMagnetsPage({super.key});

  @override
  State<Ch4A4InvestigatingAttractionAndRepulsionBetweenMagnetsPage>
  createState() => _AttractionRepulsionLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML plays no
/// sounds of its own, so the lab uses the shell tones plus two for the
/// bench: put-down → drop (`science/click.mp3`, the closest short knock;
/// an object let go away from its zone, or a magnet snapping onto another)
/// and flip → flip (`science/dropdown.mp3`, a magnet turned over). The
/// shell plays click (`science/click.mp3`), toggle (`science/dropdown.mp3`),
/// correct (`math/success.mp3`: the placement, repulsion, attraction,
/// levitation and snap toasts), wrong (`science/error.mp3`: 'complete all
/// steps' and 'Ring Magnet 2 first'), success (`math/success.mp3`: the
/// summary popup), scenario (`science/page_open.mp3`) and curtain
/// (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toasts (objects placed, forces observed).
  correct('audio/class6/math/success.mp3'),

  /// Validate too early, flipping Ring Magnet 2 before it is on the spindle.
  wrong('audio/class6/science/error.mp3'),

  /// The summary popup ('Validate Model').
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An object put down away from its drop zone.
  drop('audio/class6/science/click.mp3'),

  /// 'Flip Magnet B' / 'Flip Ring Magnet 2': a magnet turned over.
  flip('audio/class6/science/dropdown.mp3');

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

/// Tailwind colours used by the HTML (UI and Three.js materials).
abstract final class _Colors {
  /// ZSL yellow: the HTML "Enter Lab" button (`bg-[#eab308] text-slate-900`).
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // tailwind `primary`
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color pink500 = Color(0xFFEC4899); // repulsion cells
  static const Color pink600 = Color(0xFFDB2777);
  static const Color rose500 = Color(0xFFF43F5E); // bar magnet glow box
  static const Color red500 = Color(0xFFEF4444); // North halves, needle tip
  static const Color blue500 = Color(0xFF3B82F6); // South halves
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // attraction cells
  static const Color green600 = Color(0xFF16A34A);
  static const Color amber100 = Color(0xFFFEF3C7); // spindle rod
  static const Color amber400 = Color(0xFFFBBF24); // active label chip
  static const Color amber500 = Color(0xFFF59E0B); // pencils, outcome bolt
  static const Color amber600 = Color(0xFFD97706); // brass compass
  static const Color amber700 = Color(0xFFB45309); // spindle base
  static const Color orange500 = Color(0xFFF97316); // active label chip
  static const Color purple500 = Color(0xFFA855F7); // ring glow
  static const Color sky400 = Color(0xFF38BDF8); // compass glow
  static const Color blue300 = Color(0xFF93C5FD); // compass glass
  static const Color slate50 = Color(0xFFF8FAFC); // compass dial
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8); // needle South tip
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569); // equipment shelf
  static const Color slate700 = Color(0xFF334155); // table top
  static const Color slate800 = Color(0xFF1E293B); // table border, tips
  static const Color slate900 = Color(0xFF0F172A); // canvas, ring holes
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  /// Scene label chip (`bg-slate-900/90`, `border-white/20`).
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = Color(0x33FFFFFF);

  /// Glow of the active label (`rgba(245, 158, 11, 0.8)`).
  static const Color labelGlow = Color(0xCCF59E0B);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xE00F172A);
  static const Color glassLight = Color(0xEBFFFFFF);
  static const Color borderDark = Color(0x1FFFFFFF);
  static const Color borderLight = Color(0x336366F1);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// HTML canvas (`#canvas-wrapper`, `bg-slate-900`) stays dark in both
/// themes.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: Color(0xFF0B0F19), // --bg-primary
    panel: Color(0xF20F172A), // sidebar dark:bg-slate-900/95
    border: _Colors.borderDark,
    card: Color(0xFF020617), // dark:bg-slate-950 cards
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.slate900,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    // Tailwind `primary` indigo; the HTML buttons are bg-indigo-600.
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A), // bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x99312E81), // from-indigo-900/60
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100, // --bg-primary
    panel: Color(0xF2F8FAFC), // sidebar bg-slate-50/95
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate200,
    canvasBg: _Colors.slate900,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // completed steps (text-green-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x99312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font size slider (15 px default, 12–24 px).
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
// Copied from the HTML `i18n` table (Telugu dropped). The shell-generic
// texts (Enter Lab, Select Scenario, Mission Objective, Current Task,
// Success!, Close, Restart Activity, the settings and canvas-tool names and
// 'Step') come from the shell's `kLabCommonStrings`. Changes:
// * the step texts lose their "1. " numbering (the shell numbers the
//   steps) and say TAP instead of CLICK ('टैप करें' for 'क्लिक करें');
// * step_1_5 drops "on the right" ('दाईं ओर'): the observation table is in
//   the sidebar here;
// * the texts the HTML hard-codes in English (scene labels, the Scenario 3
//   table headers, 'Task Instruction' / 'Expected Outcome', two toasts)
//   get a Hindi translation; they are marked "HTML literal";
// * the short canvas HUD lines `sN_hud_M` are added (the HTML HUD repeats
//   the full step text); `s1_hud` / `s3_hud` are the HTML's own step-1
//   lines. `s2_hud` ("Step 1: …") and the `*_short` titles are kept for
//   reference: the HTML starts Scenario 2 at step 2 (its HUD shows
//   `s2_hud_2`) and the shell has a single title.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Investigating Attraction & Repulsion between Magnets',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'app_title_short': 'Attraction & Repulsion between Magnets',
    'app_subtitle_short': 'Class 6 • Exploring Magnets',
    'scen_1_opt': 'Scenario 1: Rolling Magnet Experiment',
    'scen_2_opt': 'Scenario 2: Ring Magnet Levitation',
    'scen_3_opt': 'Scenario 3: Compass Deflection Test',
    'concept_exp': 'Procedural Steps',
    'btn_validate': 'Validate Model',
    'btn_next': 'Next Scenario',
    'obs_table': 'Observation Table',
    'tbl_pair': 'Pole Arrangement',
    'tbl_effect': 'Observed Effect',
    'tbl_type': 'Force Type',
    // HTML literal: Scenario 3 table headers and the empty cell.
    'tbl_pole': 'Approaching Pole',
    'tbl_response': 'Needle Response',
    'tbl_principle': 'Principle',
    'tbl_none': '---',
    // HTML literal: the accordion's two headings.
    'task_instruction': 'Task Instruction',
    'expected_outcome': 'Expected Outcome',
    's1_desc':
        'To visually demonstrate and understand the fundamental forces of attraction and repulsion between two bar magnets placed on low-friction rolling pencils.',
    's2_desc':
        'To stack permanent ring magnets on a vertical wooden spindle and observe magnetic levitation (due to repulsion) and magnetic snapping (due to attraction).',
    's3_desc':
        "To observe how a bar magnet's magnetic field influences the freely rotating needle of a compass, proving that the compass needle itself behaves as a small bar magnet.",
    's1_hud':
        'Step 1: Drag the 6 round pencils from the shelf to the table drop zone, then place Magnet A on top.',
    's2_hud':
        'Step 1: Drag Ring Magnet 1 from the shelf and place it at the bottom of the wooden spindle rod.',
    's3_hud':
        'Step 1: Drag the magnetic compass from the shelf and drop it onto the center of the lab table.',
    // Added: canvas HUD lines for the later steps.
    's1_hud_2':
        "Step 2: Drag Magnet B and bring its North (N) pole near Magnet A's North pole.",
    's1_hud_3':
        "Step 3: Tap 'Flip Magnet B', then bring its South (S) pole near Magnet A's North pole.",
    's1_hud_4':
        "Step 4: Tap 'Flip Magnet B' again and bring its South (S) pole to Magnet A's South pole.",
    's1_hud_5': 'Step 5: Review the observation table and tap Validate Model.',
    's2_hud_2':
        'Step 2: Drag Ring Magnet 1 from the shelf and drop it onto the wooden spindle rod.',
    's2_hud_3':
        'Step 3: Drag Ring Magnet 2 (North pole facing down) and drop it onto the spindle.',
    's2_hud_4':
        "Step 4: Tap 'Flip Ring Magnet 2' to turn it over (South pole facing down).",
    's2_hud_5': 'Step 5: Drop Ring Magnet 2 onto the spindle again.',
    's2_hud_6': 'Step 6: Review the observation table and tap Validate Model.',
    's3_hud_2':
        "Step 2: Drag the bar magnet's North pole (red) near the compass needle.",
    's3_hud_3':
        'Step 3: Move the bar magnet round and bring its South pole (blue) near the needle.',
    's3_hud_4': 'Step 4: Review the observation table and tap Validate Model.',
    'step_1_1':
        'DRAG the six round pencils from the shelf and DROP them onto the highlighted area on the table. Then DRAG Bar Magnet A and DROP it on top of the pencils.',
    'step_1_2':
        "DRAG Bar Magnet B. Bring its North (red N) pole close to Magnet A's North pole. Notice Magnet A rolls away (Repulsion)!",
    'step_1_3':
        "TAP 'Flip Magnet B' button. Bring its South (blue S) pole near Magnet A's North pole. Notice Magnet A rolls forward and snaps (Attraction)!",
    'step_1_4':
        "TAP 'Flip Magnet B' again to test the South-to-South pole interaction. Conclude that like poles repel each other!",
    'step_1_5':
        'Review your completed observation table and tap Validate Model to complete Scenario 1.',
    'step_2_1':
        'Observe the vertical wooden spindle stand securely mounted on the lab table.',
    'step_2_2':
        'DRAG Ring Magnet 1 (Base) from the equipment shelf and DROP it onto the spindle rod. It slides to the bottom.',
    'step_2_3':
        'DRAG Ring Magnet 2 (with North pole facing down) and DROP it onto the spindle. Like poles repel, causing Magnet 2 to float (Levitation)!',
    'step_2_4':
        "TAP 'Flip Ring Magnet 2' button at the top to invert its poles (South facing down).",
    'step_2_5':
        'DROP Ring Magnet 2 onto the spindle again. Unlike poles attract, causing it to snap down firmly onto Magnet 1!',
    'step_2_6': 'Review the summary observation table and tap Validate Model.',
    'step_3_1':
        'DRAG the brass magnetic compass from the shelf and DROP it onto the center of the lab table. Watch the needle settle pointing North.',
    'step_3_2':
        'DRAG the Bar Magnet and slowly bring its North pole (red) near the North tip (red diamond) of the compass needle. Watch it deflect away!',
    'step_3_3':
        "Move the bar magnet around and bring its South pole (blue) near the compass needle's North tip. Watch the needle swing directly towards it!",
    'step_3_4':
        'Conclude that the compass needle obeys the universal magnetic rule: Like poles repel and unlike poles attract. Tap Validate Model.',
    'out_1_1':
        'Magnet A rests on the round pencils, enabling smooth, frictionless rolling motion.',
    'out_1_2':
        'Magnet A rolls backward away from Magnet B, proving like poles (N-N) repel.',
    'out_1_3':
        'Magnet A rolls forward and snaps onto Magnet B, proving unlike poles (N-S) attract.',
    'out_1_4':
        'Magnet A rolls away again, confirming South-to-South (S-S) like poles repel.',
    'out_1_5':
        'All pole pair interactions are verified and logged in the observation table.',
    'out_2_1':
        'The vertical spindle stand is ready to hold the ring magnets securely.',
    'out_2_2': 'Ring Magnet 1 settles at the base of the spindle stand.',
    'out_2_3':
        'Ring Magnet 2 floats in mid-air (Levitation) due to repulsion between like poles.',
    'out_2_4':
        'Ring Magnet 2 is flipped 180°, facing its unlike pole downwards.',
    'out_2_5':
        'Ring Magnet 2 snaps down tightly onto Magnet 1 due to strong magnetic attraction.',
    'out_2_6': 'Levitation and attraction phenomena are verified and logged.',
    'out_3_1':
        'The magnetic compass needle settles with its North tip pointing to magnetic North.',
    'out_3_2':
        'The compass needle deflects away from the approaching North pole of the bar magnet.',
    'out_3_3':
        'The compass needle swings towards and aligns directly with the South pole.',
    'out_3_4':
        'You proved that the compass needle behaves as an independent permanent magnet.',
    'val_nn': 'North (N) - North (N)',
    'val_ns': 'North (N) - South (S)',
    'val_ss': 'South (S) - South (S)',
    'val_repel_roll': 'Rolls Away Backwards',
    'val_attract_roll': 'Snaps Together Tightly',
    'val_repel_force': 'Repulsion',
    'val_attract_force': 'Attraction',
    'val_ring_like': 'Ring Magnets (Like Poles)',
    'val_ring_unlike': 'Ring Magnets (Unlike Poles)',
    'val_levitate': 'Floats in Mid-Air',
    'val_snap': 'Snaps Down Firmly',
    'val_comp_n': 'Bar North -> Needle North',
    'val_comp_s': 'Bar South -> Needle North',
    'val_deflect': 'Needle Deflects Away',
    'val_align': 'Needle Points Towards',
    'btn_flip_b': 'Flip Magnet B',
    'btn_flip_ring': 'Flip Ring Magnet 2',
    'toast_repel': 'Repulsion! Like poles push each other away.',
    'toast_attract': 'Attraction! Unlike poles pull together.',
    'toast_levitate': 'Magnetic Levitation! Like poles repel vertically.',
    'toast_snap': 'Magnetic Snap! Unlike poles attract tightly.',
    'toast_flipped': 'Magnet orientation flipped 180°!',
    'toast_placed': 'Asset successfully placed on table.',
    // HTML literal toasts.
    'toast_ring2_first':
        'Please drag and drop Ring Magnet 2 onto the spindle first!',
    'toast_deflected': 'Needle deflected!',
    'err_test_all': 'Please complete all experimental steps before validating.',
    'sum_s1_title': 'Scenario 1 Mastered!',
    'sum_s1_desc':
        'You proved that magnets exert contactless forces: Like poles (N-N, S-S) repel, while unlike poles (N-S) attract each other.',
    'sum_s2_title': 'Scenario 2 Mastered!',
    'sum_s2_desc':
        'You demonstrated magnetic levitation (Maglev train principle) using repulsion between like poles of ring magnets.',
    'sum_s3_title': 'Investigation Complete!',
    'sum_s3_desc':
        'You confirmed that a magnetic compass needle is a small permanent magnet aligning with external magnetic fields. Excellent work!',
    // HTML literal: the floating scene labels.
    'lbl_pencils': 'Round Pencils (Rollers)',
    'lbl_magnet_a': 'Bar Magnet A',
    'lbl_magnet_b': 'Bar Magnet B',
    'lbl_ring_1': 'Ring Magnet 1 (Base)',
    'lbl_ring_2': 'Ring Magnet 2',
    'lbl_compass': 'Magnetic Compass',
    'lbl_bar_magnet': 'Bar Magnet',
    // Added: screen-reader names of the drop targets.
    'sem_drop_zone': 'Table drop zone',
    'sem_spindle': 'Wooden spindle stand',
    'sem_table_center': 'Center of the lab table',
    // Pole letters of the magnet sprites and the compass dial (HTML canvas
    // textures, the same in every language).
    'pole_n': 'N',
    'pole_s': 'S',
    'dial_n': 'N',
    'dial_s': 'S',
    'dial_e': 'E',
    'dial_w': 'W',
  },
  'hi': {
    'app_title': 'चुंबकों के बीच आकर्षण और प्रतिकर्षण की जांच',
    'app_subtitle': 'कक्षा 6 • चुंबकों की खोज',
    'app_title_short': 'चुंबकों में आकर्षण और प्रतिकर्षण',
    'app_subtitle_short': 'कक्षा 6 • चुंबकों की खोज',
    'scen_1_opt': 'परिदृश्य 1: लुढ़कते चुंबक का प्रयोग',
    'scen_2_opt': 'परिदृश्य 2: वलयाकार चुंबक (लेविटेशन)',
    'scen_3_opt': 'परिदृश्य 3: कम्पास सुई विक्षेपण परीक्षण',
    'concept_exp': 'प्रक्रियात्मक चरण',
    'btn_validate': 'मॉडल को मान्य करें',
    'btn_next': 'अगला परिदृश्य',
    'obs_table': 'अवलोकन तालिका',
    'tbl_pair': 'ध्रुव व्यवस्था',
    'tbl_effect': 'प्रेक्षित प्रभाव',
    'tbl_type': 'बल का प्रकार',
    // Added: Hindi for the HTML literals (English only in the HTML).
    'tbl_pole': 'निकट आता ध्रुव',
    'tbl_response': 'सुई की प्रतिक्रिया',
    'tbl_principle': 'सिद्धांत',
    'tbl_none': '---',
    'task_instruction': 'कार्य निर्देश',
    'expected_outcome': 'अपेक्षित परिणाम',
    's1_desc':
        'पेंसिल के रोलर्स पर रखे दो छड़ चुंबकों के बीच आकर्षण और प्रतिकर्षण के मौलिक बलों का अध्ययन और प्रदर्शन करना।',
    's2_desc':
        'ऊर्ध्वाधर स्पिंडल पर स्थायी रिंग चुंबकों को रखकर चुंबकीय लेविटेशन (प्रतिकर्षण के कारण) और स्नैपिंग (आकर्षण के कारण) का निरीक्षण करना।',
    's3_desc':
        'यह निरीक्षण करना कि छड़ चुंबक कम्पास की सुई को कैसे प्रभावित करता है, यह सिद्ध करते हुए कि कम्पास की सुई स्वयं एक छोटे चुंबक की तरह व्यवहार करती है।',
    's1_hud':
        'चरण 1: शेल्फ से 6 पेंसिलों को मेज पर खींचें, फिर उनके ऊपर चुंबक A रखें।',
    's2_hud':
        'चरण 1: शेल्फ से रिंग चुंबक 1 को खींचकर लकड़ी के स्पिंडल के नीचे रखें।',
    's3_hud': 'चरण 1: शेल्फ से चुंबकीय कम्पास को मेज के ठीक केंद्र में खींचें।',
    // Added.
    's1_hud_2':
        'चरण 2: चुंबक B को खींचें और उसके उत्तरी (N) ध्रुव को चुंबक A के उत्तरी ध्रुव के पास लाएं।',
    's1_hud_3':
        "चरण 3: 'चुंबक B पलटें' पर टैप करें, फिर उसके दक्षिणी (S) ध्रुव को चुंबक A के उत्तरी ध्रुव के पास लाएं।",
    's1_hud_4':
        "चरण 4: 'चुंबक B पलटें' पर फिर से टैप करें और उसके दक्षिणी (S) ध्रुव को चुंबक A के दक्षिणी ध्रुव के पास लाएं।",
    's1_hud_5':
        "चरण 5: अवलोकन तालिका की समीक्षा करें और 'मॉडल को मान्य करें' पर टैप करें।",
    's2_hud_2':
        'चरण 2: शेल्फ से रिंग चुंबक 1 को खींचकर लकड़ी के स्पिंडल रॉड पर गिराएं।',
    's2_hud_3':
        'चरण 3: रिंग चुंबक 2 (उत्तरी ध्रुव नीचे की ओर) को खींचकर स्पिंडल पर गिराएं।',
    's2_hud_4':
        "चरण 4: रिंग चुंबक 2 को उलटने (दक्षिणी ध्रुव नीचे) के लिए 'रिंग चुंबक 2 पलटें' पर टैप करें।",
    's2_hud_5': 'चरण 5: रिंग चुंबक 2 को फिर से स्पिंडल पर गिराएं।',
    's2_hud_6':
        "चरण 6: अवलोकन तालिका की समीक्षा करें और 'मॉडल को मान्य करें' पर टैप करें।",
    's3_hud_2':
        'चरण 2: छड़ चुंबक के उत्तरी ध्रुव (लाल) को कम्पास सुई के पास लाएं।',
    's3_hud_3':
        'चरण 3: छड़ चुंबक को घुमाकर उसके दक्षिणी ध्रुव (नीला) को सुई के पास लाएं।',
    's3_hud_4':
        "चरण 4: अवलोकन तालिका की समीक्षा करें और 'मॉडल को मान्य करें' पर टैप करें।",
    'step_1_1':
        'शेल्फ से 6 पेंसिलों को मेज के चिह्नित स्थान पर खींचें। फिर छड़ चुंबक A को पेंसिलों के ऊपर गिराएं।',
    'step_1_2':
        'चुंबक B को खींचें। इसके उत्तरी (लाल N) ध्रुव को चुंबक A के उत्तरी ध्रुव के पास लाएं। चुंबक A दूर लुढ़कता है (प्रतिकर्षण)!',
    'step_1_3':
        "'चुंबक B पलटें' बटन पर टैप करें। दक्षिणी (नीला S) ध्रुव को चुंबक A के उत्तरी ध्रुव के पास लाएं। चुंबक A चिपक जाता है (आकर्षण)!",
    'step_1_4':
        'दक्षिण-दक्षिण ध्रुव की जांच के लिए चुंबक B को फिर से पलटें। निष्कर्ष निकालें कि समान ध्रुव एक-दूसरे को प्रतिकर्षित करते हैं!',
    'step_1_5':
        "अपनी अवलोकन तालिका की समीक्षा करें और परिदृश्य 1 पूरा करने के लिए 'मॉडल को मान्य करें' पर टैप करें।",
    'step_2_1':
        'मेज पर मजबूती से लगे लकड़ी के ऊर्ध्वाधर स्पिंडल स्टैंड का निरीक्षण करें।',
    'step_2_2':
        'शेल्फ से रिंग चुंबक 1 को खींचें और स्पिंडल रॉड पर गिराएं। यह नीचे फिसल जाता है।',
    'step_2_3':
        'रिंग चुंबक 2 को स्पिंडल पर गिराएं। समान ध्रुवों में प्रतिकर्षण के कारण यह हवा में तैरता है (लेविटेशन)!',
    'step_2_4':
        "ध्रुवों को उलटने के लिए ऊपर दिए गए 'रिंग चुंबक 2 पलटें' बटन पर टैप करें।",
    'step_2_5':
        'रिंग चुंबक 2 को फिर से स्पिंडल पर गिराएं। विपरीत ध्रुव आकर्षित होकर मजबूती से चिपक जाते हैं!',
    'step_2_6':
        "सारांश अवलोकन तालिका की समीक्षा करें और 'मॉडल को मान्य करें' पर टैप करें।",
    'step_3_1':
        'पीतल के कम्पास को शेल्फ से मेज के केंद्र में रखें। सुई को उत्तर दिशा में स्थिर होते देखें।',
    'step_3_2':
        'छड़ चुंबक के उत्तरी ध्रुव (लाल) को कम्पास सुई के उत्तरी सिरे के पास लाएं। सुई दूर विक्षेपित होती है!',
    'step_3_3':
        'चुंबक के दक्षिणी ध्रुव (नीला) को कम्पास सुई के उत्तरी सिरे के पास लाएं। सुई तेजी से आकर्षित होती है!',
    'step_3_4':
        'निष्कर्ष निकालें कि कम्पास सुई चुंबकीय नियम का पालन करती है: समान ध्रुव प्रतिकर्षित, विपरीत ध्रुव आकर्षित।',
    'out_1_1':
        'चुंबक A पेंसिलों पर टिक जाता है, जिससे घर्षण रहित लुढ़कन संभव होती है।',
    'out_1_2':
        'चुंबक A दूर पीछे लुढ़कता है, सिद्ध करता है कि समान ध्रुव (N-N) प्रतिकर्षित करते हैं।',
    'out_1_3':
        'चुंबक A आगे बढ़कर चिपक जाता है, सिद्ध करता है कि विपरीत ध्रुव (N-S) आकर्षित करते हैं।',
    'out_1_4':
        'चुंबक A फिर दूर हटता है, पुष्टि करता है कि दक्षिण-दक्षिण (S-S) ध्रुव प्रतिकर्षित करते हैं।',
    'out_1_5':
        'अवलोकन तालिका में सभी ध्रुवीय अंतर्क्रियाएं सफलतापूर्वक दर्ज की गईं।',
    'out_2_1': 'ऊर्ध्वाधर स्पिंडल स्टैंड रिंग चुंबकों को रखने के लिए तैयार है।',
    'out_2_2': 'रिंग चुंबक 1 स्पिंडल स्टैंड के आधार पर टिक जाता है।',
    'out_2_3':
        'समान ध्रुवों के प्रतिकर्षण के कारण रिंग चुंबक 2 हवा में तैरता है (लेविटेशन)।',
    'out_2_4': 'रिंग चुंबक 2 को 180° पलट दिया गया है।',
    'out_2_5':
        'तीव्र आकर्षण के कारण रिंग चुंबक 2 तेजी से नीचे चुंबक 1 से चिपक जाता है।',
    'out_2_6': 'लेविटेशन और आकर्षण की परिघटना सत्यापित की गई।',
    'out_3_1': 'कम्पास की सुई उत्तर दिशा की ओर संकेत करते हुए स्थिर होती है।',
    'out_3_2':
        'छड़ चुंबक के उत्तरी ध्रुव के पास आने पर कम्पास की सुई दूर विक्षेपित होती है।',
    'out_3_3': 'कम्पास की सुई दक्षिणी ध्रुव की ओर मुड़कर सीधे संरेखित होती है।',
    'out_3_4':
        'सिद्ध हुआ कि कम्पास की सुई एक स्वतंत्र स्थायी चुंबक की तरह व्यवहार करती है।',
    'val_nn': 'उत्तर (N) - उत्तर (N)',
    'val_ns': 'उत्तर (N) - दक्षिण (S)',
    'val_ss': 'दक्षिण (S) - दक्षिण (S)',
    'val_repel_roll': 'पीछे दूर लुढ़कता है',
    'val_attract_roll': 'तेजी से चिपक जाता है',
    'val_repel_force': 'प्रतिकर्षण',
    'val_attract_force': 'आकर्षण',
    'val_ring_like': 'रिंग चुंबक (समान ध्रुव)',
    'val_ring_unlike': 'रिंग चुंबक (विपरीत ध्रुव)',
    'val_levitate': 'हवा में तैरता है',
    'val_snap': 'नीचे चिपक जाता है',
    'val_comp_n': 'छड़ उत्तर -> सुई उत्तर',
    'val_comp_s': 'छड़ दक्षिण -> सुई उत्तर',
    'val_deflect': 'सुई दूर मुड़ती है',
    'val_align': 'सुई चुंबक की ओर मुड़ती है',
    'btn_flip_b': 'चुंबक B पलटें',
    'btn_flip_ring': 'रिंग चुंबक 2 पलटें',
    'toast_repel': 'प्रतिकर्षण! समान ध्रुव एक-दूसरे को दूर ढकेलते हैं।',
    'toast_attract': 'आकर्षण! विपरीत ध्रुव एक-दूसरे को पास खींचते हैं।',
    'toast_levitate': 'चुंबकीय लेविटेशन! प्रतिकर्षण के कारण चुंबक तैर रहा है।',
    'toast_snap': 'चुंबकीय स्नैप! विपरीत ध्रुव मजबूती से चिपक गए।',
    'toast_flipped': 'चुंबक की दिशा 180° पलट दी गई!',
    'toast_placed': 'वस्तु मेज पर सफलतापूर्वक रखी गई।',
    // Added: Hindi for the HTML literal toasts.
    'toast_ring2_first': 'कृपया पहले रिंग चुंबक 2 को खींचकर स्पिंडल पर रखें!',
    'toast_deflected': 'सुई विक्षेपित हुई!',
    'err_test_all': 'कृपया मान्य करने से पहले सभी प्रयोगात्मक चरण पूरे करें।',
    'sum_s1_title': 'परिदृश्य 1 में महारत!',
    'sum_s1_desc':
        'आपने सिद्ध किया कि चुंबक बिना छुए बल लगाते हैं: समान ध्रुव प्रतिकर्षित, जबकि विपरीत ध्रुव आकर्षित करते हैं।',
    'sum_s2_title': 'परिदृश्य 2 में महारत!',
    'sum_s2_desc':
        'आपने रिंग चुंबकों के प्रतिकर्षण का उपयोग करके चुंबकीय लेविटेशन (मैग्लेव ट्रेन सिद्धांत) का प्रदर्शन किया।',
    'sum_s3_title': 'जांच पूरी हुई!',
    'sum_s3_desc':
        'आपने पुष्टि की कि कम्पास की सुई एक छोटा स्थायी चुंबक है जो बाहरी चुंबकीय क्षेत्रों के साथ संरेखित होता है। बेहतरीन काम!',
    // Added: Hindi for the HTML literal scene labels, and the screen-reader
    // names of the drop targets.
    'lbl_pencils': 'गोल पेंसिलें (रोलर्स)',
    'lbl_magnet_a': 'छड़ चुंबक A',
    'lbl_magnet_b': 'छड़ चुंबक B',
    'lbl_ring_1': 'रिंग चुंबक 1 (आधार)',
    'lbl_ring_2': 'रिंग चुंबक 2',
    'lbl_compass': 'चुंबकीय कम्पास',
    'lbl_bar_magnet': 'छड़ चुंबक',
    'sem_drop_zone': 'मेज़ पर रखने का स्थान',
    'sem_spindle': 'लकड़ी का स्पिंडल स्टैंड',
    'sem_table_center': 'प्रयोगशाला मेज़ का केंद्र',
    'pole_n': 'N',
    'pole_s': 'S',
    'dial_n': 'N',
    'dial_s': 'S',
    'dial_e': 'E',
    'dial_w': 'W',
  },
};

/// Steps per scenario (HTML `updateUI()`: 5, 6 and 4).
const List<int> _stepCounts = [5, 6, 4];

/// HTML `step_s_n` (task instruction) and `out_s_n` (expected outcome) of
/// scenario [index] in [lang]. The HTML steps have no concept text.
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('scen_${n}_opt'),
    objective: t('s${n}_desc'),
    steps: [
      for (var i = 1; i <= _stepCounts[index]; i++)
        LabStep(
          concept: '',
          action: t('step_${n}_$i'),
          observation: t('out_${n}_$i'),
        ),
    ],
  );
}

/// The three scenarios in both languages, built once from [_i18n].
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values)
    lang: [
      for (var i = 0; i < _stepCounts.length; i++) _buildScenario(lang, i),
    ],
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target for scene objects (logical px).
const double _minTouch = 48;

/// Short drags must move objects: 8 px touch slop instead of 18 px (a
/// RawGestureDetector does not take MediaQuery's gesture settings).
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

/// Longest frame step fed to the physics (s), so a stalled frame does not
/// fling the magnets.
const double _maxFrameStep = 0.05;

/// Canvases shorter than this (phones in landscape) get the compact
/// placement of the flip button (the shell's compact mission card limit).
const double _compactBelow = 480;

// ------------------------------------------------------------------ cameras
// HTML setupScenarioN(): camera.position; controls.target is (0, 0, 0).

const List<_V> _cameras = [_V(0, 14, 18), _V(0, 12, 22), _V(0, 15, 15)];

// ---------------------------------------------------------------- lab bench
// HTML createLabTable(): top 28 × 1 × 20 (y −1…0), border 28.4 × 0.3 ×
// 20.4; the equipment shelf 6 × 0.4 × 12 (Scenario 1) or 6 × 0.4 × 10 at
// (−10, 0.2, 0).

const double _tableHalfX = 14, _tableHalfZ = 10;
const double _rimHalfX = 14.2, _rimHalfZ = 10.2, _rimDepth = 0.3;

/// Dragged objects keep their centre on the table top.
const double _dragHalfX = 13, _dragHalfZ = 9;

const double _shelfX = -10, _shelfHalfX = 3, _shelfTop = 0.4;

/// Height of an object's base: on the shelf or on the table.
double _floorAt(int scenario, double x, double z) =>
    (x - _shelfX).abs() <= _shelfHalfX && z.abs() <= _shelfHalfZ(scenario)
    ? _shelfTop
    : 0;

double _shelfHalfZ(int scenario) => scenario == 0 ? 6 : 5;

/// Carried objects ride this much above their resting height (a picked-up
/// cue; the HTML kept the height it had when grabbed).
const double _carryLift = 0.3;

/// TWEEN.js timings: placement 400 ms Quadratic.Out, flip 500 ms Back.Out.
const double _placeTime = 0.4, _flipTime = 0.5;

/// Put down away from a drop zone (200 ms).
const double _settleTime = 0.2;

// --------------------------------------------------------------- scenario 1
// HTML setupScenario1() and checkPhysicsInteractions().

/// Six round pencils (r 0.2, 5 long along z with a 0.6 tip) 0.55 apart.
/// The HTML stacked them along one line (all at x = 0); here they lie side
/// by side as rollers under Magnet A.
const double _pencilR = 0.2, _pencilLen = 5, _pencilTip = 0.6;
const double _pencilGap = 0.55;
const _V _pencilsHome = _V(-10, _shelfTop + _pencilR, -3);
const _V _pencilsPlaced = _V(0, _pencilR, 0);

/// Bar magnet: two 2.5 × 0.9 × 1.3 halves, red North at local −x.
const double _halfLen = 1.25, _magnetHalfH = 0.45, _magnetHalfD = 0.65;

/// Glow box 5.3 × 1.1 × 1.5 (also the touch box).
const _V _magnetGlowHalf = _V(2.65, 0.55, 0.75);

/// Magnet A lies on the pencils with its North pole towards Magnet B (yaw
/// π); the HTML laid it the other way, which made its own step 2 (North to
/// North) impossible.
const double _magnetAYaw = math.pi;
const _V _magnetAHome = _V(-10, _shelfTop + _magnetHalfH, 3);
const _V _magnetAPlaced = _V(0, 2 * _pencilR + _magnetHalfH, 0);

/// Magnet B starts beside the drop zone, out of Magnet A's reach (HTML
/// x 2.5, which overlapped the drop zone and Magnet A).
const _V _magnetBHome = _V(7, _magnetHalfH, 3.5);

/// Drop zone (6 × 6) and the HTML snap tests (|x| < 4, |z| < 4 for the
/// pencils; |x| < 4, |z| < 3 for Magnet A).
const double _zoneHalf = 3;
const double _pencilsSnap = 4, _magnetSnapX = 4, _magnetSnapZ = 3;

/// HTML physics: the magnets touch with their centres 5.05 apart; B is
/// pushed out within 4.8 (x) and 3.0 (z); they interact within 6.5; like
/// poles push A to 7 away (never past ±5), unlike poles pull it to touch.
const double _contactGap = 5.05, _pushX = 4.8, _pushZ = 3.0;
const double _range = 6.5, _repelGap = 7.0, _repelLimit = 5.0;

/// Rolling speeds (per second) of Magnet A and the close-up of the
/// attracted magnets; the HTML moved them in one jump.
const double _repelRate = 6, _attractRate = 12, _closeUpRate = 8;

// --------------------------------------------------------------- scenario 2
// HTML setupScenario2(): wooden spindle stand, two ring magnets.

/// Ring magnet: red (North) half on top, blue (South) half below, each r 1.5
/// and 0.3 thick, with a 0.4 hole.
const double _ringR = 1.5, _ringHalfH = 0.3, _holeR = 0.4;
const _V _ring1Home = _V(-10, _shelfTop + _ringHalfH, -2);
const _V _ring2Home = _V(-10, _shelfTop + _ringHalfH, 2);

/// Ring Magnet 2 starts upside down (North pole facing down), as the step
/// text says; the HTML built both rings the same way up.
const double _ring2StartSpin = math.pi;

/// Stand: base 5 × 0.6 × 5, rod r 0.35 up to y 8.3.
const double _baseHalf = 2.5, _baseTop = 0.6, _rodR = 0.35, _rodTop = 8.3;

/// The HTML drop test (|x| < 5.5, |z| < 5.5 around the spindle).
const double _spindleSnap = 5.5;

/// Resting heights: Ring 1 on the base, Ring 2 snapped onto Ring 1, Ring 2
/// floating (HTML 3.6 ± 0.25, sin(time × 0.005) with time in ms).
const double _ring1RestY = _baseTop + _ringHalfH;
const double _ring2SnapY = _ring1RestY + 2 * _ringHalfH;
const double _levitateY = 3.6, _bobAmp = 0.25, _bobRate = 5;

/// Carried rings ride above the base and the shelf.
const double _ringLift = 0.9;

/// 'Flip Ring Magnet 2' at step 4 lifts the ring off the rod, turns it over
/// and puts it beside the stand for step 5 ("DROP … onto the spindle
/// again").
const _V _ring2Aside = _V(6.5, _ringHalfH, 2.5);
const double _liftTime = 0.35, _asideTime = 0.45;

/// Ring 2 snapping down (Quadratic.In) or rising to float (Quadratic.Out).
const double _snapTime = 0.35, _floatTime = 0.45;

// --------------------------------------------------------------- scenario 3
// HTML setupScenario3() and createCompassAsset().

const _V _compassHome = _V(-10, _shelfTop, -2);
const _V _compassPlaced = _V(0, 0, 0);
const double _compassSnap = 4;

/// The bar magnet lies with its North pole towards the compass (yaw π), so
/// it reaches the needle first, as the HTML's "Bar North" test expects.
const double _barYaw = math.pi;
const _V _barHome = _V(-10, _shelfTop + _magnetHalfH, 2);

/// Brass case r 2.2–2.3, 0.4 high; dial r 2.0 at y 0.41; needle at y 0.5
/// (two 4-sided cones r 0.35, 1.6 long, a brass cap r 0.25); glass r 2.1
/// at y 0.6.
const double _caseTopR = 2.2, _caseBottomR = 2.3, _caseH = 0.4;
const double _dialR = 2.0, _dialY = 0.41;
const double _needleY = 0.5, _needleLen = 1.6, _needleR = 0.35, _capR = 0.25;
const double _glassR = 2.1, _glassY = 0.6;

/// The magnet stays clear of the compass case.
const double _keepOut = 2.45;

/// Field model: the poles sit near the magnet's ends; each pole's field
/// falls off with the fourth power of the distance (steeper than a real
/// pole, so the needle stays within about 5° of North with the magnet on
/// the shelf yet swings round by 60–80° a few units from a pole), against
/// Earth's field of strength 1 towards −z.
const double _poleAt = 2.2, _poleStrength = 512, _poleSoften = 0.25;

/// Needle spring (rad/s²) and damping (1/s): it overshoots and settles.
const double _needleStiffness = 40, _needleDamping = 4;

/// A pole test is recorded when that pole is the nearer one, within 5
/// units of the needle, and the needle has turned more than 20° off North.
const double _testRange = 5, _testAngle = 20 * math.pi / 180;

/// The two pole pairs of Scenario 1 and which end of a magnet is meant.
enum _Pole { north, south }

enum _Pair { nn, ns, ss }

/// Pan recogniser that only claims pointers that start on a draggable
/// object (decided by [canGrab]), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _AttractionRepulsionLabState
    extends State<Ch4A4InvestigatingAttractionAndRepulsionBetweenMagnetsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _TextCache _texts = _TextCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for touch-sized hit areas.
  double _fit = 1;

  /// UI scale of the last build (popup table).
  double _uiScale = 1;

  /// Object under the finger at pointer-down (not yet dragging).
  _Body? _grab;

  /// Last feedback toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.load(0);
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
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update(), the scenario's physics, render.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.updateTweens();
    switch (s.scenario) {
      case 0:
        _rollingPhysics(dt);
      case 1:
        _levitationPhysics();
      default:
        _compassPhysics(dt);
    }
    _frame.value = now;
  }

  /// HTML Scenario 1 `checkPhysicsInteractions()`, run every frame: Magnet
  /// B is kept out of Magnet A; within 6.5 units like poles push Magnet A
  /// away (it rolls on its pencils) and unlike poles pull it up to touch.
  void _rollingPhysics(double dt) {
    final s = _scene;
    final a = s.magnetA, b = s.magnetB;
    if (!s.magAPlaced || a.move != null) return;
    var dx = b.pos.x - a.pos.x;
    final dz = b.pos.z - a.pos.z;
    if (dx.abs() < _pushX && dz.abs() < _pushZ) {
      b.pos = b.pos.withX(a.pos.x + (dx >= 0 ? _contactGap : -_contactGap));
      dx = b.pos.x - a.pos.x;
    }
    if ((b.pos - a.pos).length < _range) {
      final right = dx >= 0;
      // The ends that face each other: Magnet A's North end is on its right;
      // Magnet B's North end is on its left until it is flipped.
      final aEnd = right ? _Pole.north : _Pole.south;
      final bEnd = right != s.bFlipped ? _Pole.north : _Pole.south;
      if (aEnd == bEnd) {
        s
          ..attracting = false
          ..aTargetX = right
              ? math.max(-_repelLimit, b.pos.x - _repelGap)
              : math.min(_repelLimit, b.pos.x + _repelGap);
        _recordPair(aEnd == _Pole.north ? _Pair.nn : _Pair.ss);
      } else {
        s
          ..attracting = true
          ..aTargetX = b.pos.x + (right ? -_contactGap : _contactGap);
        _recordPair(_Pair.ns);
      }
    } else {
      s.attracting = false;
    }
    // Magnet A rolls towards its target, its pencils rolling under it.
    final target = s.aTargetX;
    if (target != null) {
      final rate = s.attracting ? _attractRate : _repelRate;
      final move = (target - a.pos.x) * math.min(1.0, dt * rate);
      if (move.abs() < 1e-4) {
        s.aTargetX = null;
      } else {
        a.pos = a.pos.withX(a.pos.x + move);
        s.pencils.pos = s.pencils.pos.withX(s.pencils.pos.x + move);
        s.pencilSpin -= move / _pencilR;
      }
    }
    // Attracted magnets close up end to end once Magnet B is let go.
    if (s.attracting && s.dragging != b) {
      final gap = a.pos.z - b.pos.z;
      if (gap.abs() > 1e-3) {
        b.pos = b.pos.withZ(b.pos.z + gap * math.min(1.0, dt * _closeUpRate));
      }
    }
  }

  /// HTML `animate()`: a floating Ring Magnet 2 bobs at 3.6 ± 0.25.
  void _levitationPhysics() {
    final s = _scene;
    final r2 = s.ring2;
    if (!s.ring2Floating || r2.move != null || s.dragging == r2) return;
    final t = s.time - s.bobStart;
    r2.pos = r2.pos.withY(_levitateY + math.sin(t * _bobRate) * _bobAmp);
  }

  /// HTML Scenario 3 needle: Earth's field turns it North; once the compass
  /// is on the table the bar magnet's poles pull its North tip towards South
  /// poles and push it away from North poles. The needle swings on a
  /// damped spring and the two pole tests are recorded from what it does.
  void _compassPhysics(double dt) {
    final s = _scene;
    var fx = 0.0, fz = -1.0;
    if (s.compassPlaced) {
      final at = s.compass.pos;
      final (north, south) = s.barPoles;
      final f = _poleField(at, north) - _poleField(at, south);
      fx += f.x;
      fz += f.z;
    }
    // rotation.y = θ points the North tip along (−sin θ, 0, −cos θ).
    final target = math.atan2(-fx, -fz);
    final pull = math.sin(_wrapAngle(target - s.needle));
    s.needleSpeed +=
        (_needleStiffness * pull - _needleDamping * s.needleSpeed) * dt;
    s.needle = _wrapAngle(s.needle + s.needleSpeed * dt);
    if (s.compassPlaced && s.compass.move == null) _checkNeedleTests();
  }

  /// Field of one magnet pole at [at] (pointing away from it).
  static _V _poleField(_V at, _V pole) {
    final r = _V(at.x - pole.x, 0, at.z - pole.z);
    final d2 = r.x * r.x + r.z * r.z + _poleSoften;
    return r * (_poleStrength / (d2 * d2 * math.sqrt(d2)));
  }

  /// HTML: "Needle deflected!" when the bar's North pole turns the needle
  /// away; the South-pole test (no toast in the HTML) when it swings the
  /// needle towards the bar.
  void _checkNeedleTests() {
    final s = _scene;
    final at = s.compass.pos;
    final (north, south) = s.barPoles;
    final dn = _flatDistance(at, north), ds = _flatDistance(at, south);
    if (math.min(dn, ds) > _testRange || s.needle.abs() < _testAngle) return;
    if (dn < ds) {
      if (s.nDeflect) return;
      setState(() {
        s.nDeflect = true;
        _updateStep();
      });
      _toast('toast_deflected');
    } else if (!s.sAttract) {
      setState(() {
        s.sAttract = true;
        _updateStep();
      });
    }
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(getText(key))`.
  void _toast(String key, {bool isError = false, bool sound = true}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: isError, sound: sound);
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

  /// HTML `updateUI()` step rules, never going back (`Math.max`).
  void _updateStep() {
    final s = _scene;
    var step = s.step;
    switch (s.scenario) {
      case 0:
        if (s.pencilsPlaced && s.magAPlaced) step = math.max(step, 2);
        // Here the pairs are taken in the order of the steps (the HTML
        // also moved on after an N–S pair or a flip without the N–N one).
        if (s.testedNN) step = math.max(step, 3);
        if (s.testedNN && s.testedNS) step = math.max(step, 4);
        if (s.testedNN && s.testedNS && s.testedSS) step = 5;
      case 1:
        step = math.max(step, 2);
        if (s.ring1Placed) step = math.max(step, 3);
        if (s.levitateTested) step = math.max(step, 4);
        if (s.r2Flipped && s.levitateTested) step = math.max(step, 5);
        if (s.snapTested) step = 6;
      default:
        if (s.compassPlaced) step = math.max(step, 2);
        if (s.nDeflect) step = math.max(step, 3);
        if (s.nDeflect && s.sAttract) step = 4;
    }
    s.step = step;
  }

  /// HTML `changeScenario(id)` / `resetApp()`: rebuilds the bench for
  /// [index] with its camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
    });
    _lab.resetView(sound: false);
  }

  /// Scenario 1: a pole pair seen for the first time fills its table row.
  void _recordPair(_Pair pair) {
    final s = _scene;
    final seen = switch (pair) {
      _Pair.nn => s.testedNN,
      _Pair.ns => s.testedNS,
      _Pair.ss => s.testedSS,
    };
    if (seen) return;
    setState(() {
      switch (pair) {
        case _Pair.nn:
          s.testedNN = true;
        case _Pair.ns:
          s.testedNS = true;
        case _Pair.ss:
          s.testedSS = true;
      }
      _updateStep();
    });
    _toast(pair == _Pair.ns ? 'toast_attract' : 'toast_repel');
  }

  /// HTML `onPointerUp`: the pencils snap onto the drop zone (400 ms
  /// Quadratic.Out) and the highlight goes.
  void _placePencils() {
    final s = _scene;
    s.pencils.moveTo(_pencilsPlaced, s.time, _placeTime, _quadOut);
    setState(() {
      s.pencilsPlaced = true;
      _updateStep();
    });
    _toast('toast_placed');
  }

  /// Magnet A snaps onto the pencils (400 ms Quadratic.Out).
  void _placeMagnetA() {
    final s = _scene;
    s.magnetA.moveTo(_magnetAPlaced, s.time, _placeTime, _quadOut);
    setState(() {
      s.magAPlaced = true;
      _updateStep();
    });
    _toast('toast_placed');
  }

  /// Ring Magnet 1 slides down the rod onto the base (400 ms).
  void _placeRing1() {
    final s = _scene;
    s.ring1.moveTo(const _V(0, _ring1RestY, 0), s.time, _placeTime, _quadOut);
    setState(() {
      s.ring1Placed = true;
      _updateStep();
    });
    _toast('toast_placed');
  }

  /// Ring Magnet 2 goes onto the spindle and comes to rest there.
  void _placeRing2() {
    final s = _scene;
    s.ring2Placed = true;
    _settleRing2(from: s.ring2.pos.withX(0).withZ(0));
  }

  /// Ring Magnet 2 on the spindle: facing like poles (it is still upside
  /// down) it rises and floats; facing unlike poles it snaps down onto Ring
  /// Magnet 1. The table row is filled when it gets there (the HTML waited
  /// for the next pointer move to record the levitation).
  void _settleRing2({_V? from}) {
    final s = _scene;
    final r2 = s.ring2;
    final like = !s.r2Flipped;
    s.ring2Floating = false;
    if (from != null) r2.pos = from;
    r2.moveTo(
      _V(0, like ? _levitateY : _ring2SnapY, 0),
      s.time,
      like ? _floatTime : _snapTime,
      like ? _quadOut : _quadIn,
      onDone: () {
        if (!mounted || !s.ring2Placed) return;
        if (like) {
          s
            ..ring2Floating = true
            ..bobStart = s.time;
        } else {
          _Sound.drop.play();
        }
        final seen = like ? s.levitateTested : s.snapTested;
        if (seen) return;
        setState(() {
          if (like) {
            s.levitateTested = true;
          } else {
            s.snapTested = true;
          }
          _updateStep();
        });
        _toast(like ? 'toast_levitate' : 'toast_snap');
      },
    );
  }

  /// The compass slides to the centre of the table (400 ms); a bar magnet
  /// left there moves out of its way.
  void _placeCompass() {
    final s = _scene;
    s.compass.moveTo(_compassPlaced, s.time, _placeTime, _quadOut);
    final bar = s.barMagnet;
    final (x, z) = s.clearOfCompass(bar.pos.x, bar.pos.z, at: _compassPlaced);
    if (x != bar.pos.x || z != bar.pos.z) {
      bar.moveTo(_V(x, s.restY(bar, x, z), z), s.time, _placeTime, _quadOut);
    }
    setState(() {
      s.compassPlaced = true;
      _updateStep();
    });
    _toast('toast_placed');
  }

  /// Puts [b] down where it was let go (on the table or the shelf). The
  /// sliding magnets are already there, and stay free for the physics.
  void _putDown(_Body b) {
    final s = _scene;
    _Sound.drop.play();
    final rest = b.pos.withY(s.restY(b, b.pos.x, b.pos.z));
    if ((rest.y - b.pos.y).abs() < 1e-3) {
      b.pos = rest;
    } else {
      b.moveTo(rest, s.time, _settleTime, _quadOut);
    }
  }

  /// HTML `flipActiveMagnet()`: Magnet B turns 180° (500 ms Back.Out); Ring
  /// Magnet 2 turns over, and at step 4 it is lifted off the spindle to be
  /// dropped on again.
  void _flip() {
    final s = _scene;
    if (s.scenario == 0) {
      final b = s.magnetB;
      setState(() => s.bFlipped = !s.bFlipped);
      b.turnTo(b.angle + math.pi, s.time, _flipTime);
      _Sound.flip.play();
      _toast('toast_flipped', sound: false);
      return;
    }
    if (s.scenario != 1) return;
    final r2 = s.ring2;
    if (!s.ring2Placed || r2.move != null || s.dragging == r2) {
      _toast('toast_ring2_first', isError: true);
      return;
    }
    _Sound.flip.play();
    _toast('toast_flipped', sound: false);
    setState(() {
      s.r2Flipped = !s.r2Flipped;
      if (s.step == 4 && !s.snapTested) {
        s
          ..ring2Placed = false
          ..ring2Floating = false;
        r2.moveAlong([
          const _Leg(_V(0, _rodTop + 0.6, 0), _liftTime, _quadOut),
          const _Leg(_ring2Aside, _asideTime, _quadInOut),
        ], s.time);
        r2.turnTo(r2.angle + math.pi, s.time + _liftTime, _flipTime);
      } else {
        r2.turnTo(r2.angle + math.pi, s.time, _flipTime);
        _settleRing2();
      }
      _updateStep();
    });
  }

  /// HTML `validateInvestigation()`: the summary once every pole test of
  /// the scenario is in the table; before that, a reminder. (The HTML
  /// accepted a single test in Scenarios 1–2 and none in Scenario 3.)
  void _validate() {
    final s = _scene;
    if (s.step < _stepCounts[s.scenario]) {
      _toast('err_test_all', isError: true);
      return;
    }
    _showSummary();
  }

  /// HTML `showPopup(sum_sN_title, sum_sN_desc)` with 'Next Scenario'
  /// (Scenarios 1–2) or the restart button (Scenario 3).
  void _showSummary() {
    final index = _scene.scenario;
    final n = index + 1;
    final last = index == _stepCounts.length - 1;
    _lab.completedScenarios.add(index);
    _lab.showPopup(
      () => LabPopupContent(
        title: _lab.t('success'),
        heading: _t('sum_s${n}_title'),
        body: _t('sum_s${n}_desc'),
        icon: Icons.emoji_events,
        extra: _table(
          _lab.palette,
          _uiScale,
          _uiScale * _lab.fontScale.clamp(0.9, 1.4),
        ),
        actions: [
          if (last)
            LabAction(
              label: _lab.t('btn_restart'),
              icon: Icons.restart_alt,
              onTap: _lab.requestFullReset,
            )
          else
            LabAction(
              label: _t('btn_next'),
              icon: Icons.arrow_forward,
              color: _lab.palette.primary,
              foreground: _lab.palette.onPrimary,
              sound: _Sound.scenario,
              onTap: () => _nextScenario(index),
            ),
        ],
      ),
    );
  }

  /// HTML `nextScenario()`: closes the popup and opens the next scenario
  /// 300 ms later.
  void _nextScenario(int from) {
    _lab.hidePopup(sound: false);
    _lab.after(const Duration(milliseconds: 300), () {
      if (mounted && _scene.scenario == from) _loadScenario(from + 1);
    });
  }

  // -------------------------------------------------------------- dragging

  /// HTML raycast on pointer-down: the front-most draggable object whose
  /// touch box (its glow box, widened to a finger-sized target) is hit.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.dragging != null) return false;
    _Body? best;
    var bestDepth = double.infinity;
    for (final b in s.draggables) {
      if (!_touchRect(b).contains(event.localPosition)) continue;
      final depth = s.proj.depth(b.pos);
      if (depth < bestDepth) {
        best = b;
        bestDepth = depth;
      }
    }
    _grab = best;
    return best != null;
  }

  /// Screen box of [b]'s glow mesh, at least [_minTouch] logical px.
  Rect _touchRect(_Body b) {
    final s = _scene;
    final (centre, half, yaw) = s.hitBox(b);
    var box = s.proj.bounds(centre, half, yaw: yaw);
    final min = _minTouch / _fit;
    if (box.width < min || box.height < min) {
      box = Rect.fromCenter(
        center: box.center,
        width: math.max(box.width, min),
        height: math.max(box.height, min),
      );
    }
    return box;
  }

  /// HTML `onPointerDown`: remembers where the table plane (y = 0) was hit
  /// relative to the object, so it keeps that offset under the finger.
  void _dragStart(DragStartDetails d) {
    final b = _grab;
    if (b == null) return;
    final s = _scene;
    final hit = s.proj.onPlane(d.localPosition, 0);
    s
      ..dragging = b
      ..dragOffset = hit == null ? _V.zero : hit - b.pos;
    b.move = null;
    if (b == s.ring2) {
      // Lifted off the spindle.
      s
        ..ring2Placed = false
        ..ring2Floating = false;
    }
  }

  /// HTML `onPointerMove`: the object follows the finger on the table.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final b = s.dragging;
    if (b == null) return;
    final hit = s.proj.onPlane(d.localPosition, 0);
    if (hit == null) return;
    var x = (hit.x - s.dragOffset.x).clamp(-_dragHalfX, _dragHalfX);
    var z = (hit.z - s.dragOffset.z).clamp(-_dragHalfZ, _dragHalfZ);
    if (b == s.magnetB && s.magAPlaced) {
      // HTML: Magnet B never comes within 5.05 of Magnet A along x; it
      // jumps to the other side when the finger passes Magnet A.
      final ax = s.magnetA.pos.x;
      x = x >= ax
          ? math.max(ax + _contactGap, x)
          : math.min(ax - _contactGap, x);
    } else if (b == s.barMagnet) {
      (x, z) = s.clearOfCompass(x, z);
    }
    b.pos = _V(x, s.restY(b, x, z) + s.lift(b), z);
  }

  /// HTML `onPointerUp` / `pointercancel`: the drop-zone snaps.
  void _dragEnd() {
    final s = _scene;
    final b = s.dragging;
    _grab = null;
    if (b == null) return;
    s.dragging = null;
    final p = b.pos;
    if (b == s.pencils &&
        p.x.abs() < _pencilsSnap &&
        p.z.abs() < _pencilsSnap) {
      _placePencils();
    } else if (b == s.magnetA &&
        s.pencilsPlaced &&
        p.x.abs() < _magnetSnapX &&
        p.z.abs() < _magnetSnapZ) {
      _placeMagnetA();
    } else if (b == s.ring1 && _onSpindle(p)) {
      _placeRing1();
    } else if (b == s.ring2 && s.ring1Placed && _onSpindle(p)) {
      _placeRing2();
    } else if (b == s.compass &&
        p.x.abs() < _compassSnap &&
        p.z.abs() < _compassSnap) {
      _placeCompass();
    } else {
      _putDown(b);
    }
  }

  bool _onSpindle(_V p) => p.x.abs() < _spindleSnap && p.z.abs() < _spindleSnap;

  // ------------------------------------------------------------------- UI

  /// HTML `#floating-controls`: 'Flip Magnet B' (Scenario 1) or 'Flip Ring
  /// Magnet 2' (Scenario 2); it bounces when the current step needs it.
  LabAction? _flipAction(LabPalette p) {
    final s = _scene;
    if (s.scenario == 2) return null;
    final needed = s.scenario == 0
        ? (s.step == 3 && !s.bFlipped) || (s.step == 4 && s.bFlipped)
        : s.step == 4;
    return LabAction(
      label: _t(s.scenario == 0 ? 'btn_flip_b' : 'btn_flip_ring'),
      icon: Icons.swap_horiz,
      color: p.primary,
      foreground: p.onPrimary,
      highlight: needed,
      silent: true,
      onTap: _flip,
    );
  }

  /// HTML `#validate-btn` (under the observation table).
  LabAction _validateAction(LabPalette p, {bool highlight = false}) =>
      LabAction(
        label: _t('btn_validate'),
        icon: Icons.check_circle,
        color: p.primary,
        foreground: p.onPrimary,
        highlight: highlight,
        silent: true,
        onTap: _validate,
      );

  /// Canvas HUD line for the current step.
  String get _hud {
    final s = _scene;
    final n = s.scenario + 1;
    final step = s.step.clamp(1, _stepCounts[s.scenario]);
    return step == 1 ? _t('s${n}_hud') : _t('s${n}_hud_$step');
  }

  /// HTML `#results-table-container` table for the current scenario.
  Widget _table(LabPalette p, double scale, double fontScale) {
    final s = _scene;
    final none = _t('tbl_none');
    final repel = p.isDark ? _Colors.pink500 : _Colors.pink600;
    final attract = p.success;
    _TableRow row(String pair, bool seen, String effect, bool attraction) =>
        _TableRow(
          pair: _t(pair),
          effect: seen ? _t(effect) : none,
          force: seen
              ? _t(attraction ? 'val_attract_force' : 'val_repel_force')
              : none,
          color: seen ? (attraction ? attract : repel) : null,
        );
    final (headers, rows) = switch (s.scenario) {
      0 => (
        (_t('tbl_pair'), _t('tbl_effect'), _t('tbl_type')),
        [
          row('val_nn', s.testedNN, 'val_repel_roll', false),
          row('val_ns', s.testedNS, 'val_attract_roll', true),
          row('val_ss', s.testedSS, 'val_repel_roll', false),
        ],
      ),
      1 => (
        (_t('tbl_pair'), _t('tbl_effect'), _t('tbl_type')),
        [
          row('val_ring_like', s.levitateTested, 'val_levitate', false),
          row('val_ring_unlike', s.snapTested, 'val_snap', true),
        ],
      ),
      _ => (
        (_t('tbl_pole'), _t('tbl_response'), _t('tbl_principle')),
        [
          row('val_comp_n', s.nDeflect, 'val_deflect', false),
          row('val_comp_s', s.sAttract, 'val_align', true),
        ],
      ),
    };
    return _ObservationTable(
      headers: headers,
      rows: rows,
      palette: p,
      scale: scale,
      fontScale: fontScale,
    );
  }

  /// HTML teacher-board "Procedural Steps" accordion, then the floating
  /// "Observation Table" with its 'Validate Model' button (moved into the
  /// sidebar; the canvas shows 'Validate Model' once the table is full).
  Widget _sidebarPanels(LabScenarioData data, LabPalette p, double s) {
    final f = s * _lab.fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepsAccordion(
          key: ValueKey('ch4a4-steps-${_scene.scenario}-${_scene.step}'),
          steps: data.steps,
          current: _scene.step,
          palette: p,
          scale: s,
          fontScale: f,
          stepLabel: _lab.t('step'),
          taskLabel: _t('task_instruction'),
          outcomeLabel: _t('expected_outcome'),
        ),
        SizedBox(height: 10 * s),
        LabSectionLabel(
          _t('obs_table'),
          size: 10.5 * s,
          icon: Icons.table_chart,
        ),
        SizedBox(height: 8 * s),
        _table(p, s, f),
        SizedBox(height: 8 * s),
        LabActionButton(action: _validateAction(p), scale: s),
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
        final scene = _scene;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final flip = _flipAction(p);
        final popupOpen = _lab.popup != null;
        final finished = scene.step >= _stepCounts[scene.scenario];
        return LabShell(
          controller: _lab,
          icon: Icons.sync_alt,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [
            for (var i = 1; i <= _stepCounts.length; i++) _t('scen_${i}_opt'),
          ],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          hud: _hud,
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _sidebarPanels(data, p, s),
          overlays: [
            // HTML `#floating-controls`: top centre of the canvas, below
            // the feedback toast; on short (phone) screens top right, clear
            // of the spindle's top.
            if (flip != null && !popupOpen)
              Positioned(
                key: const ValueKey('ch4a4-flip'),
                top: inset.top + 52 * s,
                left: inset.left,
                right: inset.right,
                child: Align(
                  alignment: MediaQuery.sizeOf(context).height < _compactBelow
                      ? Alignment.topRight
                      : Alignment.topCenter,
                  child: LabActionButton(action: flip, scale: s, expand: false),
                ),
              ),
            // The table's 'Validate Model', on the canvas (above the HUD)
            // once every test is done, so it is in reach on phones too.
            if (finished && !popupOpen)
              Positioned(
                key: const ValueKey('ch4a4-validate'),
                bottom: inset.bottom + (_lab.isSidebarOpen ? 66 * s : 0),
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: _validateAction(p, highlight: true),
                    scale: s,
                    expand: false,
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
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        // Canvas labels stay readable when the stage is scaled down.
        final labelScale = (0.85 / _fit).clamp(1.0, 1.8);
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Dragging is not a screen-reader action; the objects and drop
            // targets have their own nodes ([_targets]).
            excludeFromSemantics: true,
            gestures: {
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..gestureSettings = _dragSettings
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _dragStart
                      ..onUpdate = _dragUpdate
                      ..onEnd = ((_) => _dragEnd())
                      ..onCancel = _dragEnd,
                  ),
            },
            child: Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: _design,
                    painter: _ScenePainter(
                      scene: _scene,
                      texts: _texts,
                      repaint: _frame,
                      palette: p,
                      showLabels: _lab.showLabels,
                      lang: _lab.lang,
                      labelScale: labelScale,
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
        );
      },
    );
  }

  /// Screen-reader nodes over the draggable objects and their drop targets,
  /// where they are drawn. They follow the objects every frame and take no
  /// touches themselves (drags reach the scene below).
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive) return const SizedBox.shrink();
    final nodes = <(String, String, Rect)>[
      for (final b in s.bodies) (b.id.name, _t(b.id.labelKey), _touchRect(b)),
      if (s.scenario == 0 && !s.pencilsPlaced)
        (
          'zone',
          _t('sem_drop_zone'),
          s.proj.bounds(_V.zero, const _V(_zoneHalf, 0.01, _zoneHalf)),
        ),
      if (s.scenario == 1)
        (
          'spindle',
          _t('sem_spindle'),
          s.proj.bounds(
            const _V(0, _baseTop / 2, 0),
            const _V(_baseHalf, _baseTop / 2, _baseHalf),
          ),
        ),
      if (s.scenario == 2 && !s.compassPlaced)
        (
          'centre',
          _t('sem_table_center'),
          s.proj.bounds(_V.zero, const _V(_compassSnap, 0.01, _compassSnap)),
        ),
    ];
    return Stack(
      children: [
        for (final (id, label, rect) in nodes)
          Positioned.fromRect(
            rect: rect,
            child: Semantics(
              key: ValueKey('ch4a4-$id'),
              container: true,
              label: label,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------- observation table

/// One row of the HTML observation table: the pole arrangement, the effect
/// and the force ('---' until observed; [color] null while pending).
@immutable
class _TableRow {
  const _TableRow({
    required this.pair,
    required this.effect,
    required this.force,
    this.color,
  });

  final String pair;
  final String effect;
  final String force;
  final Color? color;
}

/// HTML `#results-table-container` table: three columns, the force in
/// pink (repulsion) or green (attraction). Used in the sidebar and in the
/// summary popup.
class _ObservationTable extends StatelessWidget {
  const _ObservationTable({
    required this.headers,
    required this.rows,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final (String, String, String) headers;
  final List<_TableRow> rows;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = fontScale;
    TextStyle style(Color color, FontWeight weight) => TextStyle(
      color: color,
      fontSize: 11 * f,
      fontWeight: weight,
      height: 1.3,
    );
    Widget line(List<Widget> cells, {Color? fill, bool top = true}) =>
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            color: fill,
            border: top ? Border(top: BorderSide(color: p.cardBorder)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) SizedBox(width: 6 * s),
                Expanded(flex: i == 0 ? 5 : 4, child: cells[i]),
              ],
            ],
          ),
        );
    final head = style(p.text, FontWeight.w800);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate950 : _Colors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            [
              Text(headers.$1, style: head),
              Text(headers.$2, style: head),
              Text(headers.$3, style: head),
            ],
            fill: p.isDark ? _Colors.slate900 : _Colors.slate200,
            top: false,
          ),
          for (final r in rows)
            line([
              Text(r.pair, style: style(p.textStrong, FontWeight.w700)),
              Text(r.effect, style: style(p.textMuted, FontWeight.w500)),
              Text(
                r.force,
                style: style(
                  r.color ?? p.textMuted,
                  r.color == null ? FontWeight.w500 : FontWeight.w800,
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- steps accordion

/// HTML `#steps-container`: one card per step; the current step is open,
/// done steps show a tick and can be re-opened, future steps are dimmed
/// (`opacity-60 pointer-events-none`).
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.taskLabel,
    required this.outcomeLabel,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String taskLabel;
  final String outcomeLabel;

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

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    final dim = future ? 0.6 : 1.0;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    final tone = current ? indigo : (past ? p.success : p.textMuted);
    final border = current
        ? _Colors.indigo500
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    return Opacity(
      opacity: dim,
      child: Container(
        margin: EdgeInsets.only(bottom: 8 * s),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: current ? 1.5 : 1),
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
                  constraints: const BoxConstraints(minHeight: 48),
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
                                ? _Colors.indigo600
                                : (past
                                      ? p.success.withValues(alpha: 0.18)
                                      : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(
                              color: current
                                  ? _Colors.indigo500
                                  : (past
                                        ? p.success.withValues(alpha: 0.5)
                                        : p.cardBorder),
                            ),
                          ),
                          child: past
                              ? Icon(
                                  Icons.check,
                                  size: 13 * s,
                                  color: p.success,
                                )
                              : Text(
                                  '$i',
                                  style: TextStyle(
                                    color: current
                                        ? _Colors.white
                                        : p.textMuted,
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
            if (open) _body(step, indigo),
          ],
        ),
      ),
    );
  }

  /// "Task Instruction" and the indigo "Expected Outcome" box.
  Widget _body(LabStep step, Color indigo) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0x66020617) : const Color(0x99F1F5F9),
        border: Border(top: BorderSide(color: p.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            w.taskLabel.toUpperCase(),
            style: TextStyle(
              color: p.textMuted,
              fontSize: 9.5 * f,
              fontWeight: FontWeight.w800,
              letterSpacing: labLetterSpacing(w.taskLabel, 1),
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            step.action,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 12 * f,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          SizedBox(height: 8 * s),
          Container(
            padding: EdgeInsets.all(9 * s),
            decoration: BoxDecoration(
              // bg-indigo-50 dark:bg-indigo-950/40, border-indigo-200 / 800.
              color: p.isDark
                  ? const Color(0x661E1B4B)
                  : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: p.isDark
                    ? const Color(0x993730A3)
                    : const Color(0xFFC7D2FE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, size: 13 * f, color: indigo),
                    SizedBox(width: 4 * s),
                    Expanded(
                      child: Text(
                        w.outcomeLabel.toUpperCase(),
                        style: TextStyle(
                          color: indigo,
                          fontSize: 9.5 * f,
                          fontWeight: FontWeight.w800,
                          letterSpacing: labLetterSpacing(w.outcomeLabel, 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * s),
                Text(
                  step.observation,
                  style: TextStyle(
                    // text-indigo-950 dark:text-indigo-200.
                    color: p.isDark
                        ? const Color(0xFFC7D2FE)
                        : const Color(0xFF1E1B4B),
                    fontSize: 11.5 * f,
                    fontWeight: FontWeight.w600,
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

// ------------------------------------------------------------- scene model

/// The draggable objects (HTML `userData.draggable` groups) and their
/// floating label.
enum _Obj {
  pencils('lbl_pencils'),
  magnetA('lbl_magnet_a'),
  magnetB('lbl_magnet_b'),
  ring1('lbl_ring_1'),
  ring2('lbl_ring_2'),
  compass('lbl_compass'),
  barMagnet('lbl_bar_magnet');

  const _Obj(this.labelKey);

  /// Key of the object's label in [_i18n].
  final String labelKey;
}

/// TWEEN.js easings used by the HTML (and the added moves).
typedef _Ease = double Function(double t);

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => t * (2 - t);

/// TWEEN.Easing.Quadratic.In.
double _quadIn(double t) => t * t;

/// TWEEN.Easing.Quadratic.InOut.
double _quadInOut(double t) => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

/// TWEEN.Easing.Back.Out.
double _backOut(double t) {
  const s = 1.70158;
  final u = t - 1;
  return u * u * ((s + 1) * u + s) + 1;
}

/// One leg of a position tween.
@immutable
class _Leg {
  const _Leg(this.to, this.duration, this.ease);

  final _V to;
  final double duration;
  final _Ease ease;
}

/// A TWEEN.js position tween, possibly chained over several legs.
class _Move {
  _Move(this.from, this.legs, this.start, this.onDone)
    : duration = legs.fold<double>(0, (sum, leg) => sum + leg.duration);

  final _V from;
  final List<_Leg> legs;
  final double start;
  final double duration;
  final VoidCallback? onDone;

  _V at(double now) {
    var t = now - start;
    var p = from;
    for (final leg in legs) {
      if (t < leg.duration) {
        return _V.lerp(p, leg.to, leg.ease((t / leg.duration).clamp(0.0, 1.0)));
      }
      t -= leg.duration;
      p = leg.to;
    }
    return p;
  }

  bool isDone(double now) => now >= start + duration;
}

/// A TWEEN.js tween of a rotation (Back.Out), which may start later.
@immutable
class _Turn {
  const _Turn(this.from, this.to, this.start, this.duration);

  final double from;
  final double to;
  final double start;
  final double duration;

  double at(double now) =>
      from + (to - from) * _backOut(((now - start) / duration).clamp(0.0, 1.0));

  bool isDone(double now) => now >= start + duration;
}

/// One object on the bench: its position, its turn (rotation.y of a bar
/// magnet, rotation.z of a ring magnet) and the tweens moving them.
class _Body {
  _Body(this.id, this.home, this.homeAngle) : pos = home, angle = homeAngle;

  final _Obj id;
  final _V home;
  final double homeAngle;
  _V pos;
  double angle;
  _Move? move;
  _Turn? turn;

  void reset() {
    pos = home;
    angle = homeAngle;
    move = null;
    turn = null;
  }

  void moveTo(
    _V to,
    double now,
    double duration,
    _Ease ease, {
    VoidCallback? onDone,
  }) => moveAlong([_Leg(to, duration, ease)], now, onDone: onDone);

  void moveAlong(List<_Leg> legs, double now, {VoidCallback? onDone}) =>
      move = _Move(pos, legs, now, onDone);

  void turnTo(double to, double start, double duration) =>
      turn = _Turn(angle, to, start, duration);

  /// TWEEN.update() for this body.
  void update(double now) {
    final m = move;
    if (m != null) {
      pos = m.at(now);
      if (m.isDone(now)) {
        move = null;
        m.onDone?.call();
      }
    }
    final t = turn;
    if (t != null) {
      angle = t.at(now);
      if (t.isDone(now)) turn = null;
    }
  }
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;
  int step = 1;
  _Proj proj = _Proj(_cameras[0], _V.zero);

  final _Body pencils = _Body(_Obj.pencils, _pencilsHome, 0);
  final _Body magnetA = _Body(_Obj.magnetA, _magnetAHome, _magnetAYaw);
  final _Body magnetB = _Body(_Obj.magnetB, _magnetBHome, 0);
  final _Body ring1 = _Body(_Obj.ring1, _ring1Home, 0);
  final _Body ring2 = _Body(_Obj.ring2, _ring2Home, _ring2StartSpin);
  final _Body compass = _Body(_Obj.compass, _compassHome, 0);
  final _Body barMagnet = _Body(_Obj.barMagnet, _barHome, _barYaw);

  // ---------------------------------------------------------- scenario 1
  bool pencilsPlaced = false;
  bool magAPlaced = false;
  bool testedNN = false, testedNS = false, testedSS = false;
  bool bFlipped = false;

  /// Where Magnet A is rolling to, and whether it is being attracted.
  double? aTargetX;
  bool attracting = false;

  /// Turn of the pencil rollers (radians), from Magnet A's rolling.
  double pencilSpin = 0;

  // ---------------------------------------------------------- scenario 2
  bool ring1Placed = false, ring2Placed = false;
  bool levitateTested = false, snapTested = false;

  /// Ring Magnet 2 turned the right way up (South pole facing down).
  bool r2Flipped = false;

  /// Ring Magnet 2 floats on the spindle (bobbing since [bobStart]).
  bool ring2Floating = false;
  double bobStart = 0;

  // ---------------------------------------------------------- scenario 3
  bool compassPlaced = false;
  bool nDeflect = false, sAttract = false;

  /// Needle rotation.y (0: North tip towards −z) and its angular speed.
  double needle = 0, needleSpeed = 0;

  // ---------------------------------------------------------- dragging
  _Body? dragging;
  _V dragOffset = _V.zero;

  List<_Body> get bodies => switch (scenario) {
    0 => [pencils, magnetA, magnetB],
    1 => [ring1, ring2],
    _ => [compass, barMagnet],
  };

  /// Objects the current state lets the learner pick up. Placed pencils,
  /// Magnet A, Ring Magnet 1 and the compass stay where they were put
  /// (the HTML let them be dragged off again, leaving its state behind);
  /// Ring Magnet 2 waits for Ring Magnet 1.
  Iterable<_Body> get draggables => bodies.where(
    (b) =>
        b.move == null &&
        switch (b.id) {
          _Obj.pencils => !pencilsPlaced,
          _Obj.magnetA => !magAPlaced,
          _Obj.ring1 => !ring1Placed,
          _Obj.ring2 => ring1Placed,
          _Obj.compass => !compassPlaced,
          _Obj.magnetB || _Obj.barMagnet => true,
        },
  );

  /// HTML `animate()` glow list: the object the current step is about.
  List<_Body> get glowing => switch (scenario) {
    0 when !pencilsPlaced => [pencils],
    0 when !magAPlaced => [magnetA],
    0 when step >= 2 && step <= 4 => [magnetB],
    1 when !ring1Placed => [ring1],
    1 when !ring2Placed => [ring2],
    2 when !compassPlaced => [compass],
    2 => [barMagnet],
    _ => const [],
  };

  /// Touch / glow box of [b]: centre, half sizes and yaw.
  (_V, _V, double) hitBox(_Body b) => switch (b.id) {
    _Obj.pencils => (
      b.pos + const _V(0, 0, _pencilTip / 2),
      const _V(1.6, _pencilR + 0.05, (_pencilLen + _pencilTip) / 2),
      0,
    ),
    _Obj.magnetA ||
    _Obj.magnetB ||
    _Obj.barMagnet => (b.pos, _magnetGlowHalf, b.angle),
    _Obj.ring1 || _Obj.ring2 => (
      b.pos,
      const _V(_ringR + 0.15, _ringHalfH + 0.08, _ringR + 0.15),
      0,
    ),
    _Obj.compass => (
      b.pos + const _V(0, 0.35, 0),
      const _V(_caseBottomR + 0.1, 0.35, _caseBottomR + 0.1),
      0,
    ),
  };

  /// Resting height of [b]'s centre at (x, z): on the shelf or the table.
  double restY(_Body b, double x, double z) {
    final floor = _floorAt(scenario, x, z);
    return floor +
        switch (b.id) {
          _Obj.pencils => _pencilR,
          _Obj.magnetA || _Obj.magnetB || _Obj.barMagnet => _magnetHalfH,
          _Obj.ring1 || _Obj.ring2 => _ringHalfH,
          _Obj.compass => 0,
        };
  }

  /// How far [b] rides above its rest while carried: magnets B and the
  /// Scenario 3 bar magnet slide on the table, the others are lifted.
  double lift(_Body b) => switch (b.id) {
    _Obj.magnetB || _Obj.barMagnet => 0,
    _Obj.ring1 || _Obj.ring2 => _ringLift,
    _ => _carryLift,
  };

  /// The bar magnet's North and South poles (Scenario 3).
  (_V, _V) get barPoles {
    final m = barMagnet;
    // The red North half is at local −x.
    final axis = const _V(-1, 0, 0).rotY(m.angle);
    return (m.pos + axis * _poleAt, m.pos - axis * _poleAt);
  }

  /// Moves a bar magnet centred at (x, z) out of the compass case (where
  /// the compass is, or [at]).
  (double, double) clearOfCompass(double x, double z, {_V? at}) {
    final c = at ?? compass.pos;
    final yaw = barMagnet.angle;
    // The compass centre in the magnet's frame, and the nearest point of
    // the magnet's 5 × 1.3 footprint to it.
    final local = _V(c.x - x, 0, c.z - z).rotY(-yaw);
    final qx = local.x.clamp(-2 * _halfLen, 2 * _halfLen);
    final qz = local.z.clamp(-_magnetHalfD, _magnetHalfD);
    final dx = local.x - qx, dz = local.z - qz;
    final d = math.sqrt(dx * dx + dz * dz);
    if (d >= _keepOut) return (x, z);
    final _V away;
    if (d < 1e-6) {
      // Centre inside the footprint: slide out sideways.
      final side = local.z >= 0 ? 1.0 : -1.0;
      away = _V(0, 0, side * (_keepOut + _magnetHalfD - local.z.abs()));
    } else {
      away = _V(dx, 0, dz) * ((_keepOut - d) / d);
    }
    final shift = away.rotY(yaw);
    return (x - shift.x, z - shift.z);
  }

  /// HTML `changeScenario(id)`: clearScene() + setupScenarioN(). Scenario 2
  /// starts at step 2 (its step 1 only asks to look at the stand).
  void load(int index) {
    scenario = index;
    step = index == 1 ? 2 : 1;
    proj = _Proj(_cameras[index], _V.zero);
    for (final b in [
      pencils,
      magnetA,
      magnetB,
      ring1,
      ring2,
      compass,
      barMagnet,
    ]) {
      b.reset();
    }
    pencilsPlaced = magAPlaced = false;
    testedNN = testedNS = testedSS = false;
    bFlipped = false;
    aTargetX = null;
    attracting = false;
    pencilSpin = 0;
    ring1Placed = ring2Placed = false;
    levitateTested = snapTested = false;
    r2Flipped = false;
    ring2Floating = false;
    bobStart = 0;
    compassPlaced = false;
    nDeflect = sAttract = false;
    needle = needleSpeed = 0;
    dragging = null;
    dragOffset = _V.zero;
  }

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    for (final b in bodies) {
      b.update(time);
    }
  }
}

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);

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

  _V withX(double v) => _V(v, y, z);
  _V withY(double v) => _V(x, v, z);
  _V withZ(double v) => _V(x, y, v);

  /// Three.js `rotation.y = a` applied to this vector.
  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  /// Three.js `rotation.z = a` applied to this vector.
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Angle wrapped into (−π, π].
double _wrapAngle(double a) {
  var r = (a + math.pi) % (2 * math.pi);
  if (r < 0) r += 2 * math.pi;
  return r - math.pi;
}

/// Distance between two points on the table plane.
double _flatDistance(_V a, _V b) {
  final dx = a.x - b.x, dz = a.z - b.z;
  return math.sqrt(dx * dx + dz * dz);
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

  /// World-space ray direction through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray crosses the horizontal plane y = [py] (drag plane).
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the box centred at [c] (half sizes [half], turned
  /// by [yaw]).
  Rect bounds(_V c, _V half, {double yaw = 0}) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final o = p(
        c +
            _V(
              i & 1 == 0 ? -half.x : half.x,
              i & 2 == 0 ? -half.y : half.y,
              i & 4 == 0 ? -half.z : half.z,
            ).rotY(yaw),
      );
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

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

/// Key light direction (HTML DirectionalLight at (15, 25, 15)).
const _V _light = _V(0.4575, 0.7625, 0.4575);

/// Shadow offset per unit of height for that light (15 / 25).
const double _shadowSlope = 0.6;

/// Box faces: outward normal and the four corners, in units of the half
/// size.
const List<(_V, List<_V>)> _boxFaces = [
  (_V(1, 0, 0), [_V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1), _V(1, -1, 1)]),
  (_V(-1, 0, 0), [_V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, 1), _V(-1, 1, -1)]),
  (_V(0, 1, 0), [_V(-1, 1, -1), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1)]),
  (_V(0, -1, 0), [_V(-1, -1, -1), _V(1, -1, -1), _V(1, -1, 1), _V(-1, -1, 1)]),
  (_V(0, 0, 1), [_V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)]),
  (_V(0, 0, -1), [_V(-1, -1, -1), _V(-1, 1, -1), _V(1, 1, -1), _V(1, -1, -1)]),
];

/// Font size the canvas letters are laid out at (then scaled).
const double _letterFont = 48;

/// World size of the magnet letters (64 px sprite canvas, bold 48 px,
/// sprite 0.8 units) and of the dial letters (256 px dial over 4 units,
/// bold 36 px).
const double _spriteEm = 0.6, _dialEm = 0.5625;

/// Dial letters sit 92 px from the centre of the 256 px texture.
const double _dialLetterAt = 1.4375;

/// HTML `labelOffsetY`: label anchors above each object.
const double _magnetLabelY = 1.0, _ringLabelY = 0.8, _compassLabelY = 1.0;

/// A drawable object and its distance from the camera (painter's order).
typedef _Drawable = (double depth, VoidCallback paint);

/// Paints the HTML Three.js scene: lab table and shelf; the pencils and two
/// bar magnets (S1), the spindle stand and ring magnets (S2) or the compass
/// and bar magnet (S3); then the floating object labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
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
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path _path = Path();
  final Float64List _matrix = Float64List(16);
  Float32List? _grid;
  Size? _gridSize;

  late Canvas _c;
  late _Proj _p;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _background(size);
    _table();
    switch (scene.scenario) {
      case 0:
        _paintRolling();
      case 1:
        _paintSpindle();
      default:
        _paintCompassBench();
    }
    if (showLabels) _paintLabels();
  }

  // ------------------------------------------------------------ background

  /// HTML `#canvas-wrapper` (`bg-slate-900`) with its `.canvas-grid`: an
  /// indigo glow in the middle and 40 px lines.
  void _background(Size size) {
    final bleed = labBleed(size);
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(bleed, _fill);
    final centre = size.center(Offset.zero);
    final radius = size.longestSide * 0.7;
    _fill.shader = ui.Gradient.radial(centre, radius, [
      _Colors.indigo500.withValues(alpha: palette.isDark ? 0.1 : 0.08),
      _Colors.indigo500.withValues(alpha: 0),
    ]);
    _c.drawRect(bleed, _fill);
    _fill.shader = null;
    if (_grid == null || _gridSize != size) {
      _gridSize = size;
      const step = 40.0;
      final pts = <double>[];
      for (
        var x = (bleed.left / step).ceil() * step;
        x < bleed.right;
        x += step
      ) {
        pts.addAll([x, bleed.top, x, bleed.bottom]);
      }
      for (
        var y = (bleed.top / step).ceil() * step;
        y < bleed.bottom;
        y += step
      ) {
        pts.addAll([bleed.left, y, bleed.right, y]);
      }
      _grid = Float32List.fromList(pts);
    }
    _stroke
      ..strokeWidth = 1
      ..color = palette.isDark
          ? LabInk.white.withValues(alpha: 0.03)
          : LabInk.black.withValues(alpha: 0.04);
    _c.drawRawPoints(ui.PointMode.lines, _grid!, _stroke);
  }

  /// HTML createLabTable() and the equipment shelf on the left.
  void _table() {
    _box(
      const _V(0, -0.5, 0),
      const _V(_tableHalfX, 0.5, _tableHalfZ),
      _Colors.slate700,
      top: false,
    );
    _box(
      const _V(0, -_rimDepth / 2, 0),
      const _V(_rimHalfX, _rimDepth / 2, _rimHalfZ),
      _Colors.slate800,
    );
    _flatQuad(0.001, _tableHalfX, _tableHalfZ, _lit(_Colors.slate700, _up));
    final shelfHalfZ = _shelfHalfZ(scene.scenario);
    _boxShadow(
      const _V(_shelfX, _shelfTop / 2, 0),
      _V(_shelfHalfX, _shelfTop / 2, shelfHalfZ),
      0,
    );
    _box(
      const _V(_shelfX, _shelfTop / 2, 0),
      _V(_shelfHalfX, _shelfTop / 2, shelfHalfZ),
      _Colors.slate600,
    );
  }

  /// Draws [items] far to near.
  void _drawSorted(List<_Drawable> items) {
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, paint) in items) {
      paint();
    }
  }

  /// Opacity of a glow mesh: 0.8 while dragged; pulsing (0.25 + |sin| ×
  /// 0.6) while it is the step's object and nothing is dragged; else hidden.
  double? _glowAlpha(_Body b) {
    final s = scene;
    if (s.dragging == b) return 0.8;
    if (s.dragging == null && s.glowing.contains(b)) {
      return 0.25 + math.sin(s.time * 6).abs() * 0.6;
    }
    return null;
  }

  // ------------------------------------------------------------ scenario 1

  void _paintRolling() {
    final s = scene;
    if (!s.pencilsPlaced) {
      // HTML dropZoneHighlight: 6 × 6 indigo plane, opacity 0.25.
      _flatQuad(
        0.02,
        _zoneHalf,
        _zoneHalf,
        _Colors.indigo500.withValues(alpha: 0.25),
      );
    }
    _pencilShadow(s.pencils);
    _magnetShadow(s.magnetA);
    _magnetShadow(s.magnetB);
    final items = <_Drawable>[
      (_p.depth(s.magnetB.pos), () => _barMagnet(s.magnetB)),
    ];
    if (s.magAPlaced) {
      // Magnet A lies on its pencils: drawn together, pencils first.
      items.add((
        _p.depth(s.magnetA.pos),
        () {
          _pencils(s.pencils);
          _barMagnet(s.magnetA);
        },
      ));
    } else {
      items
        ..add((_p.depth(s.pencils.pos), () => _pencils(s.pencils)))
        ..add((_p.depth(s.magnetA.pos), () => _barMagnet(s.magnetA)));
    }
    _drawSorted(items);
  }

  /// HTML createPencilsBundle(): six yellow pencils (r 0.2, 5 long along z)
  /// with dark tips, side by side as rollers; facet lines show them roll.
  void _pencils(_Body b) {
    const axis = _V(0, 0, 1);
    final c = b.pos;
    for (var i = 0; i < 6; i++) {
      final x = c.x + (i - 2.5) * _pencilGap;
      final base = _V(x, c.y, c.z - _pencilLen / 2);
      _cylinder(base, axis, _pencilR, _pencilLen, _Colors.amber500, sheen: 0.4);
      _stroke
        ..strokeWidth = 1
        ..color = labShade(_Colors.amber500, -0.45).withValues(alpha: 0.55);
      final mid = _V(x, c.y, c.z);
      for (var k = 0; k < 6; k++) {
        final angle = scene.pencilSpin + k * math.pi / 3;
        final radial = _V(math.cos(angle), math.sin(angle), 0);
        final edge = mid + radial * _pencilR;
        if (radial.dot(_p.eye - edge) <= 0) continue;
        _c.drawLine(
          _p.p(edge + const _V(0, 0, -_pencilLen / 2)),
          _p.p(edge + const _V(0, 0, _pencilLen / 2)),
          _stroke,
        );
      }
      _cone(
        _V(x, c.y, c.z + _pencilLen / 2),
        axis,
        _pencilR,
        _pencilTip,
        _Colors.slate800,
      );
    }
    final glow = _glowAlpha(b);
    if (glow != null) {
      final (centre, half, _) = scene.hitBox(b);
      _wireBox(centre, half, 0, _Colors.amber500.withValues(alpha: 1));
    }
  }

  void _pencilShadow(_Body b) {
    final c = b.pos;
    final pts = <Offset>[];
    for (final x in [c.x - 1.6, c.x + 1.6]) {
      for (final z in [c.z - _pencilLen / 2, c.z + _pencilLen / 2 + 0.6]) {
        for (final y in [c.y - _pencilR, c.y + _pencilR]) {
          pts.add(_p.p(_onTable(_V(x, y, z))));
        }
      }
    }
    _shadowHull(pts, 0.28);
  }

  // ---------------------------------------------------------- bar magnet

  /// HTML createBarMagnetMesh(): red North half at local x −1.25, blue
  /// South half at +1.25 (2.5 × 0.9 × 1.3 each), white N / S sprites on
  /// top, the rose wire box as its glow.
  void _barMagnet(_Body b) {
    final c = b.pos, yaw = b.angle;
    final axis = const _V(1, 0, 0).rotY(yaw); // N → S
    final northC = c - axis * _halfLen, southC = c + axis * _halfLen;
    const half = _V(_halfLen, _magnetHalfH, _magnetHalfD);
    // The half on the camera's side of the joint is drawn last.
    if (axis.dot(_p.eye - c) > 0) {
      _box(northC, half, _Colors.red500, yaw: yaw);
      _box(southC, half, _Colors.blue500, yaw: yaw);
    } else {
      _box(southC, half, _Colors.blue500, yaw: yaw);
      _box(northC, half, _Colors.red500, yaw: yaw);
    }
    const letterY = _magnetHalfH + 0.1;
    _sprite(_t('pole_n'), northC.withY(c.y + letterY));
    _sprite(_t('pole_s'), southC.withY(c.y + letterY));
    final glow = _glowAlpha(b);
    if (glow != null) {
      _wireBox(
        c,
        _magnetGlowHalf,
        yaw,
        _Colors.rose500.withValues(alpha: glow),
      );
    }
  }

  void _magnetShadow(_Body b) => _boxShadow(
    b.pos,
    const _V(2 * _halfLen, _magnetHalfH, _magnetHalfD),
    b.angle,
  );

  /// A white letter sprite (always facing the camera) at [at].
  void _sprite(String letter, _V at) {
    if (!_p.inFront(at)) return;
    final tp = texts.get(
      letter,
      size: _letterFont,
      color: _Colors.white,
      weight: FontWeight.w800,
    );
    final k = _spriteEm * _p.scaleAt(at) / _letterFont;
    final o = _p.p(at);
    _c
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(k);
    tp.paint(_c, Offset(-tp.width / 2, -tp.height / 2));
    _c.restore();
  }

  // ------------------------------------------------------------ scenario 2

  void _paintSpindle() {
    final s = scene;
    // Shadows: stand base and rod, then the rings.
    _boxShadow(
      const _V(0, _baseTop / 2, 0),
      const _V(_baseHalf, _baseTop / 2, _baseHalf),
      0,
    );
    _cylinderShadow(const _V(0, _baseTop, 0), _rodR, _rodTop - _baseTop);
    for (final r in [s.ring1, s.ring2]) {
      _cylinderShadow(r.pos - const _V(0, _ringHalfH, 0), _ringR, 0.6);
    }
    final onRod = <_Body>[];
    final items = <_Drawable>[];
    for (final r in [s.ring1, s.ring2]) {
      if (s.dragging != r && _flatDistance(r.pos, _V.zero) < 0.3) {
        onRod.add(r);
      } else {
        items.add((_p.depth(r.pos), () => _ring(r)));
      }
    }
    onRod.sort((a, b) => a.pos.y.compareTo(b.pos.y));
    items.add((_p.depth(const _V(0, 1.5, 0)), () => _stand(onRod)));
    _drawSorted(items);
  }

  /// HTML spindleStand: wooden base 5 × 0.6 × 5 and the 8-unit rod, with
  /// the rings threaded on it (each rod piece is drawn after the ring
  /// below it, so the rod comes out of the ring's hole).
  void _stand(List<_Body> rings) {
    _box(
      const _V(0, _baseTop / 2, 0),
      const _V(_baseHalf, _baseTop / 2, _baseHalf),
      _Colors.amber700,
    );
    var y = _baseTop;
    for (final r in rings) {
      final bottom = r.pos.y - _ringHalfH, top = r.pos.y + _ringHalfH;
      if (bottom > y) _rod(y, math.min(bottom, _rodTop));
      _ring(r);
      y = math.max(y, top);
    }
    if (y < _rodTop) _rod(y, _rodTop);
  }

  void _rod(double from, double to) {
    if (to - from < 0.01) return;
    _cylinder(
      _V(0, from, 0),
      _up,
      _rodR,
      to - from,
      _Colors.amber100,
      sheen: 0.35,
    );
  }

  /// HTML createRingMagnetMesh(): red (North) half on top, blue (South)
  /// half below, a dark hole; the purple wire cylinder as its glow. The
  /// ring turns over about z (rotation.z).
  void _ring(_Body b) {
    final c = b.pos;
    final axis = _up.rotZ(b.angle); // local +y: the red half's side
    final redOut = axis.dot(_p.eye - c) > 0;
    void red() => _cylinder(c, axis, _ringR, _ringHalfH, _Colors.red500);
    void blue() => _cylinder(
      c - axis * _ringHalfH,
      axis,
      _ringR,
      _ringHalfH,
      _Colors.blue500,
    );
    if (redOut) {
      blue();
      red();
    } else {
      red();
      blue();
    }
    // The hole on the face turned to the camera.
    final face = c + axis * (redOut ? _ringHalfH : -_ringHalfH);
    _ellipse(face, axis, _holeR, _Colors.slate900);
    final glow = _glowAlpha(b);
    if (glow != null) {
      _wireCylinder(
        c - axis * 0.375,
        axis,
        1.65,
        0.75,
        _Colors.purple500.withValues(alpha: 1),
      );
    }
  }

  // ------------------------------------------------------------ scenario 3

  void _paintCompassBench() {
    final s = scene;
    _cylinderShadow(s.compass.pos, _caseBottomR, _caseH);
    _magnetShadow(s.barMagnet);
    _drawSorted([
      (_p.depth(s.compass.pos), () => _compass(s.compass)),
      (_p.depth(s.barMagnet.pos), () => _barMagnet(s.barMagnet)),
    ]);
  }

  /// HTML createCompassAsset(): brass case, white dial with N / E / S / W,
  /// the pivoted needle (red North diamond, grey South diamond, brass cap)
  /// under a light-blue glass; the sky-blue wire cylinder as its glow.
  void _compass(_Body b) {
    final c = b.pos;
    _cylinder(
      c,
      _up,
      _caseBottomR,
      _caseH,
      _Colors.amber600,
      topR: _caseTopR,
      sheen: 0.6,
    );
    final dial = c + const _V(0, _dialY, 0);
    _ellipse(dial, _up, _dialR, _Colors.slate50);
    _ellipse(dial, _up, _dialR, _Colors.slate300, stroke: true);
    for (final (key, offset) in const [
      ('dial_n', _V(0, 0, -_dialLetterAt)),
      ('dial_s', _V(0, 0, _dialLetterAt)),
      ('dial_e', _V(_dialLetterAt, 0, 0)),
      ('dial_w', _V(-_dialLetterAt, 0, 0)),
    ]) {
      _planeLetter(_t(key), dial + offset + const _V(0, 0.005, 0));
    }
    final pivot = c + const _V(0, _needleY, 0);
    _needle(pivot, scene.needle);
    final cap = _p.p(pivot + const _V(0, _capR * 0.4, 0));
    labSphere(_c, cap, _capR * _p.scaleAt(pivot), _Colors.amber600);
    // Glass: rgba(147, 197, 253, 0.25).
    final glass = c + const _V(0, _glassY, 0);
    _ellipse(glass, _up, _glassR, _Colors.blue300.withValues(alpha: 0.25));
    _ellipse(
      glass,
      _up,
      _glassR,
      _Colors.white.withValues(alpha: 0.35),
      stroke: true,
    );
    final glow = _glowAlpha(b);
    if (glow != null) {
      _wireCylinder(c, _up, 2.4, 0.7, _Colors.sky400.withValues(alpha: 1));
    }
  }

  /// The needle: two 4-sided cones (r 0.35, 1.6 long) from the pivot, the
  /// red one towards the North tip direction (−sin θ, 0, −cos θ).
  void _needle(_V pivot, double angle) {
    final dir = const _V(0, 0, -1).rotY(angle);
    final side = const _V(1, 0, 0).rotY(angle);
    final rim = [
      pivot + _up * _needleR,
      pivot + side * _needleR,
      pivot - _up * _needleR,
      pivot - side * _needleR,
    ];
    final tips = [
      (pivot + dir * _needleLen, _Colors.red500),
      (pivot - dir * _needleLen, _Colors.slate400),
    ]..sort((a, b) => _p.depth(b.$1).compareTo(_p.depth(a.$1)));
    for (final (tip, color) in tips) {
      for (var k = 0; k < 4; k++) {
        final a = rim[k], b = rim[(k + 1) % 4];
        var n = (a - tip).cross(b - tip).unit;
        if (n.dot((a + b) * 0.5 - pivot) < 0) n = n * -1;
        if (n.dot(_p.eye - tip) <= 0) continue;
        final pt = _p.p(tip), pa = _p.p(a), pb = _p.p(b);
        _path
          ..reset()
          ..moveTo(pt.dx, pt.dy)
          ..lineTo(pa.dx, pa.dy)
          ..lineTo(pb.dx, pb.dy)
          ..close();
        _fill
          ..shader = null
          ..color = _lit(color, n);
        _c.drawPath(_path, _fill);
      }
    }
  }

  /// A dial letter lying on the dial (top of the letter towards −z).
  void _planeLetter(String letter, _V at) {
    if (!_p.inFront(at)) return;
    final tp = texts.get(
      letter,
      size: _letterFont,
      color: _Colors.slate900,
      weight: FontWeight.w800,
    );
    final o = _p.p(at);
    // Screen vectors of one world unit along +x (right) and +z (down).
    final ex =
        (_p.p(at + const _V(0.5, 0, 0)) - _p.p(at - const _V(0.5, 0, 0)));
    final ey =
        (_p.p(at + const _V(0, 0, 0.5)) - _p.p(at - const _V(0, 0, 0.5)));
    final k = _dialEm / _letterFont;
    final w = tp.width / 2, h = tp.height / 2;
    _matrix
      ..fillRange(0, 16, 0)
      ..[0] = ex.dx * k
      ..[1] = ex.dy * k
      ..[4] = ey.dx * k
      ..[5] = ey.dy * k
      ..[10] = 1
      ..[12] = o.dx - (ex.dx * w + ey.dx * h) * k
      ..[13] = o.dy - (ex.dy * w + ey.dy * h) * k
      ..[15] = 1;
    _c
      ..save()
      ..transform(_matrix);
    tp.paint(_c, Offset.zero);
    _c.restore();
  }

  // ------------------------------------------------------------ primitives

  static const _V _up = _V(0, 1, 0);

  /// Lambert-style shade of [c] for a face with normal [n] (ambient 0.65 +
  /// directional 0.85 in the HTML, toned down to keep colours).
  Color _lit(Color c, _V n) {
    final i = 0.58 + 0.55 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Box centred at [c] with half sizes [h], turned by [yaw]; [top] false
  /// leaves its top face out.
  void _box(_V c, _V h, Color color, {double yaw = 0, bool top = true}) {
    _V corner(_V s) => c + _V(s.x * h.x, s.y * h.y, s.z * h.z).rotY(yaw);
    for (final (n, corners) in _boxFaces) {
      if (!top && n.y > 0) continue;
      final normal = n.rotY(yaw);
      if (normal.dot(_p.eye - corner(corners.first)) <= 0) continue;
      _path.reset();
      for (var i = 0; i < 4; i++) {
        final o = _p.p(corner(corners[i]));
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _path.close();
      _fill
        ..shader = null
        ..color = _lit(color, normal);
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.35);
      _c.drawPath(_path, _stroke);
    }
  }

  /// Horizontal rectangle at height [y] (table top, drop zone).
  void _flatQuad(double y, double hx, double hz, Color color) {
    final a = _p.p(_V(-hx, y, -hz)), b = _p.p(_V(hx, y, -hz));
    final c = _p.p(_V(hx, y, hz)), d = _p.p(_V(-hx, y, hz));
    _path
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  (_V, _V) _ringAxes(_V axis) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : const _V(0, 1, 0);
    final a1 = axis.cross(helper).unit;
    return (a1, axis.cross(a1).unit);
  }

  /// Disc (or its rim with [stroke]) of radius [r] around [axis] at [c].
  void _ellipse(_V c, _V axis, double r, Color color, {bool stroke = false}) {
    final (a1, a2) = _ringAxes(axis);
    _path.reset();
    for (var i = 0; i < 28; i++) {
      final angle = i * math.pi / 14;
      final o = _p.p(c + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    if (stroke) {
      _stroke
        ..strokeWidth = 1
        ..color = color;
      _c.drawPath(_path, _stroke);
    } else {
      _fill
        ..shader = null
        ..color = color;
      _c.drawPath(_path, _fill);
    }
  }

  /// Cylinder (CylinderGeometry look) from [base] along unit [axis]: side
  /// silhouette with a lit gradient and the end that faces the camera.
  /// [topR] makes a frustum.
  void _cylinder(
    _V base,
    _V axis,
    double r,
    double len,
    Color color, {
    double? topR,
    double sheen = 0.3,
  }) {
    final (a1, a2) = _ringAxes(axis);
    final top = base + axis * len;
    final rt = topR ?? r;
    final pts = <Offset>[];
    for (var i = 0; i < 20; i++) {
      final angle = i * math.pi / 10;
      final dir = a1 * math.cos(angle) + a2 * math.sin(angle);
      pts
        ..add(_p.p(base + dir * r))
        ..add(_p.p(top + dir * rt));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    final mid = base + axis * (len / 2);
    final pm = _p.p(mid), along = _p.p(top) - _p.p(base);
    final l = along.distance;
    final perp = l < 0.001
        ? const Offset(1, 0)
        : Offset(-along.dy / l, along.dx / l);
    final half = math.max(r, rt) * _p.scaleAt(mid) * 1.1;
    _fill.shader = ui.Gradient.linear(
      pm - perp * half,
      pm + perp * half,
      [
        labShade(color, -0.4),
        labShade(color, sheen),
        color,
        labShade(color, -0.45),
      ],
      const [0, 0.35, 0.62, 1],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    _c.drawPath(_path, _fill);
    _fill.shader = null;
    if (axis.dot(_p.eye - top) > 0) {
      _ellipse(top, axis, rt, labShade(color, 0.22));
    } else if (axis.dot(_p.eye - base) < 0) {
      _ellipse(base, axis, r, labShade(color, 0.1));
    }
  }

  /// Cone from [base] (radius [r]) to its tip [len] along [axis] (the
  /// pencil tips).
  void _cone(_V base, _V axis, double r, double len, Color color) {
    final (a1, a2) = _ringAxes(axis);
    final pts = <Offset>[_p.p(base + axis * len)];
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      pts.add(_p.p(base + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _fill
      ..shader = null
      ..color = _lit(color, _up);
    _c.drawPath(_path, _fill);
  }

  /// Wireframe box (an HTML glowMesh, MeshBasicMaterial wireframe).
  void _wireBox(_V c, _V h, double yaw, Color color) {
    final pts = [
      for (var i = 0; i < 8; i++)
        _p.p(
          c +
              _V(
                i & 1 == 0 ? -h.x : h.x,
                i & 2 == 0 ? -h.y : h.y,
                i & 4 == 0 ? -h.z : h.z,
              ).rotY(yaw),
        ),
    ];
    _stroke
      ..strokeWidth = 1.4
      ..color = color;
    for (var i = 0; i < 8; i++) {
      for (final bit in const [1, 2, 4]) {
        if (i & bit == 0) _c.drawLine(pts[i], pts[i | bit], _stroke);
      }
    }
  }

  /// Wireframe cylinder (the ring and compass glowMesh).
  void _wireCylinder(_V base, _V axis, double r, double len, Color color) {
    final (a1, a2) = _ringAxes(axis);
    _stroke
      ..strokeWidth = 1.2
      ..color = color;
    for (final y in [0.0, len]) {
      _path.reset();
      for (var i = 0; i <= 32; i++) {
        final angle = i * math.pi / 16;
        final o = _p.p(
          base + axis * y + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r,
        );
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _c.drawPath(_path, _stroke);
    }
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final rim = (a1 * math.cos(angle) + a2 * math.sin(angle)) * r;
      _c.drawLine(_p.p(base + rim), _p.p(base + axis * len + rim), _stroke);
    }
  }

  /// Where the key light casts point [w] onto the table (y ≈ 0).
  _V _onTable(_V w) =>
      _V(w.x - w.y * _shadowSlope, 0.01, w.z - w.y * _shadowSlope);

  /// Soft shadow of a box on the table.
  void _boxShadow(_V c, _V h, double yaw) {
    _shadowHull([
      for (var i = 0; i < 8; i++)
        _p.p(
          _onTable(
            c +
                _V(
                  i & 1 == 0 ? -h.x : h.x,
                  i & 2 == 0 ? -h.y : h.y,
                  i & 4 == 0 ? -h.z : h.z,
                ).rotY(yaw),
          ),
        ),
    ], 0.3);
  }

  /// Soft shadow of an upright cylinder standing at [base].
  void _cylinderShadow(_V base, double r, double len) {
    final pts = <Offset>[];
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final rim = _V(math.cos(angle) * r, 0, math.sin(angle) * r);
      pts
        ..add(_p.p(_onTable(base + rim)))
        ..add(_p.p(_onTable(base + rim + _V(0, len, 0))));
    }
    _shadowHull(pts, 0.26);
  }

  void _shadowHull(List<Offset> pts, double opacity) {
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _shadow.color = LabInk.black.withValues(alpha: opacity);
    _c.drawPath(_path, _shadow);
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.html-label` chips, bottom-centre on each object's label point;
  /// the step's object gets the bouncing amber chip (`animate-bounce`).
  void _paintLabels() {
    final s = scene;
    final glowing = s.glowing;
    final labels = <_Label>[];
    for (final b in s.bodies) {
      final anchor = switch (b.id) {
        // In front of the pencils once Magnet A lies on them (the HTML
        // anchor, their centre, is where Magnet A's label goes).
        _Obj.pencils when s.magAPlaced =>
          b.pos + const _V(0, 0.4, _pencilLen / 2 + _pencilTip + 0.3),
        _Obj.ring1 || _Obj.ring2 => b.pos + const _V(0, _ringLabelY, 0),
        // Behind the case, so the chip does not hide the needle's North
        // tip (the HTML anchor is 1.0 above the dial centre).
        _Obj.compass =>
          b.pos + const _V(0, _compassLabelY, -_caseBottomR - 0.2),
        _ => b.pos + const _V(0, _magnetLabelY, 0),
      };
      final label = _layoutLabel(
        _t(b.id.labelKey),
        anchor,
        glowing.contains(b),
      );
      if (label != null) labels.add(label);
    }
    // Labels that would overlap are pushed apart vertically.
    labels.sort((a, b) => a.rect.top.compareTo(b.rect.top));
    for (var i = 1; i < labels.length; i++) {
      for (var j = 0; j < i; j++) {
        final a = labels[j].rect, b = labels[i].rect;
        if (!a.overlaps(b)) continue;
        labels[i] = labels[i].shifted(Offset(0, a.bottom + 3 - b.top));
      }
    }
    for (final hot in [false, true]) {
      for (final l in labels) {
        if (l.hot == hot) _label(l);
      }
    }
  }

  /// Text and chip rect of a label anchored at [at], or null when the
  /// point is behind the camera.
  _Label? _layoutLabel(String text, _V at, bool hot) {
    if (!_p.inFront(at)) return null;
    final k = labelScale * (hot ? 1.1 : 1);
    final tp = texts.get(
      text,
      size: (hot ? 12 : 11) * k,
      color: hot ? _Colors.slate950 : palette.labelText,
      weight: FontWeight.w800,
    );
    final o = _p.p(at);
    final padX = (hot ? 12 : 10) * k, padY = 4 * k;
    final w = tp.width + 2 * padX, h = tp.height + 2 * padY;
    // animate-bounce: up by a quarter of its height and back, once a second.
    final bounce = hot ? -0.25 * h * math.cos(scene.time * math.pi).abs() : 0.0;
    return _Label(
      tp,
      Rect.fromLTWH(o.dx - w / 2, o.dy - h + bounce, w, h),
      Offset(padX, padY),
      hot,
    );
  }

  void _label(_Label l) {
    final k = labelScale;
    final rr = RRect.fromRectAndRadius(
      l.rect,
      Radius.circular((l.hot ? 12 : 8) * k),
    );
    if (l.hot) {
      _shadow.color = _Colors.labelGlow;
      _c.drawRRect(rr.inflate(2 * k), _shadow);
      _fill.shader = ui.Gradient.linear(l.rect.centerLeft, l.rect.centerRight, [
        _Colors.amber400,
        _Colors.orange500,
      ]);
      _c.drawRRect(rr, _fill);
      _fill.shader = null;
      _stroke
        ..strokeWidth = 2
        ..color = _Colors.white;
    } else {
      _fill
        ..shader = null
        ..color = palette.labelBg;
      _c.drawRRect(rr, _fill);
      _stroke
        ..strokeWidth = 1
        ..color = _Colors.labelBorder;
    }
    _c.drawRRect(rr, _stroke);
    l.text.paint(_c, l.rect.topLeft + l.padding);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// A laid-out scene label: its text, chip rect, text padding and whether it
/// is the highlighted (step) label.
@immutable
class _Label {
  const _Label(this.text, this.rect, this.padding, this.hot);

  final TextPainter text;
  final Rect rect;
  final Offset padding;
  final bool hot;

  _Label shifted(Offset by) => _Label(text, rect.shift(by), padding, hot);
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
