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

/// Class 6 Science • Chapter 8 • Activity 2
/// Evaporation and Factors Affecting Its Rate.
///
/// Native Flutter port of
/// `Cl6S-Ch8-A2-Evaporation_and_Factors_Affecting_Its_Rate.html`.
///
/// Scenario 1 (Surface Area Showdown): drag the beaker of water onto a small
/// bottle cap and then onto a large steel plate (the same amount of water
/// each time), start the time-lapse and watch which container dries first.
///
/// Scenario 2 (Sun vs. Shade): drag one bottle cap into the sunny area and
/// the other into the shady area, fill each from the beaker, start the
/// time-lapse and watch which cap dries first.
class Ch8A2EvaporationAndFactorsAffectingItsRatePage extends StatefulWidget {
  const Ch8A2EvaporationAndFactorsAffectingItsRatePage({super.key});

  @override
  State<Ch8A2EvaporationAndFactorsAffectingItsRatePage> createState() =>
      _EvaporationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises two tones with the Web Audio
/// API; they map to the closest bundled file: 'click' (buttons, picking an
/// object up, dropping it) -> click / pickup / drop, 'ding' (a container
/// has dried, the summary) -> correct / success.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML 'ding': the water in a container has evaporated completely.
  correct('audio/class6/science/correct.mp3'),

  /// A refused drop (with its hint toast).
  wrong('audio/class6/science/error.mp3'),

  /// Scenario summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A drop accepted: water poured, bottle cap put down.
  drop('audio/class6/science/drop.mp3'),

  /// The beaker or a bottle cap picked up.
  pickup('audio/class6/science/pickup.mp3');

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

/// Colours of this lab: the HTML's Tailwind UI colours and the Three.js
/// material colours of the two scenes.
abstract final class _Colors {
  // ---- UI (Tailwind classes used by the HTML).
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8); // labels, highlight
  static const Color indigo500 = Color(0xFF6366F1); // Enter Lab, HUD
  static const Color indigo600 = Color(0xFF4F46E5); // Start Time-Lapse
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669); // Finish Observation
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color green400 = Color(0xFF4ADE80); // timer digits
  static const Color orange400 = Color(0xFFFB923C); // timer, water gone
  static const Color yellow500 = Color(0xFFEAB308); // sun icon
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

  // ---- Scenes (Three.js materials).
  static const Color sceneDark = slate900; // scene.background 0x0f172a
  static const Color sceneLight = Color(0xFFF8FAFC); // light 0xf8fafc
  static const Color wood = Color(0xFF854D0E); // materials.wood
  static const Color water = Color(0xFF38BDF8); // materials.water
  static const Color capRed = red500; // materials.plasticRed 0xef4444
  static const Color steel = slate300; // materials.steel 0xcbd5e1
  static const Color glass = white; // materials.glass
  static const Color deskSun = Color(0xFFFACC15);
  static const Color deskShade = Color(0xFF5C2B11);
  static const Color grassSun = Color(0xFF4ADE80);
  static const Color grassShade = Color(0xFF14532D);
  static const Color skySun = Color(0xFFBAE6FD);
  static const Color skyShade = slate700; // 0x334155
  static const Color sunCore = Color(0xFFFAB105);
  static const Color sunOuter = Color(0xFFFDE047);
  static const Color trunk = Color(0xFF451A03);
  static const Color leaves = Color(0xFF166534);
  static const Color divider = slate800; // 0x1e293b

  /// Sunlit patch on the sunny bench and the tree's shadow on the shady one
  /// (added: they show where the drop areas are).
  static const Color sunPatch = Color(0x66FEF9C3);
  static const Color shadePatch = Color(0x4D000000);

  /// Vapour wisps (HTML white spheres, opacity 0.6) and their faint rim, so
  /// they also show over the light steel plate and the yellow bench.
  static const Color vapour = Color(0xFFF8FAFC);
  static const Color vapourRim = Color(0xFF64748B);

  /// `.label-3d` chips: dark glass panel, indigo-400 border, white text.
  static const Color labelBg = Color(0xE60F172A);

  /// `.timer-3d`: `bg-black/80 border-indigo-500 text-green-400`.
  static const Color timerBg = Color(0xCC000000);

  /// Pulsing highlight of the object to drag (HTML emissive 0x818cf8).
  static const Color highlight = indigo400;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML's buttons, HUD and highlights are indigo, so the
/// accent is indigo-500 with white text.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF),
    card: Color(0xCC0F172A),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald400,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate950,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF21E293B),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // rgba(255, 255, 255, 0.95)
    border: Color(0x26000000),
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
    popupHeader: _Colors.indigo50,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
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
    labelBg: _Colors.labelBg,
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
// numbers come from the shell ("Step n of N"); the HUD lines (`sN_hud_M`)
// keep theirs, as in the HTML. "CLICK" reads "TAP" on a touch screen.
// Changes from the HTML:
// - The mission objectives stated the result ("conclude that water
//   evaporates faster when ..."); they now state what is investigated.
// - S2 step 3 fills each cap with its own drop, as the HUD line says (the
//   HTML filled both caps from one drop); its action says so.
// - The last step of each scenario ends with 'Finish Observation', the
//   HTML's own button; the action and the last HUD line name it.
// - The time-lapse timers count hours : minutes (5 mL of water does not
//   evaporate from a cap in 20 minutes); the summaries say so.
// Keys marked "added" are not in the HTML.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Evaporation and Factors Affecting Its Rate',
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt': 'Scenario 1: Surface Area Showdown',
    'scen_2_opt': 'Scenario 2: Sun vs. Shade: The Temperature Race',
    's1_desc':
        'To visually investigate how the exposed surface area of water '
        'affects how fast it evaporates.',
    's2_desc':
        'To visually investigate how temperature affects how fast water '
        'evaporates.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Filling the Bottle Cap',
    's1_a1': 'DRAG the beaker of water and DROP it onto the small bottle cap.',
    's1_o1':
        'A fixed amount of water (e.g., 5 mL) is poured into the bottle cap.',
    's1_c2': 'Filling the Steel Plate',
    's1_a2':
        'DRAG the same beaker of water and DROP it onto the large steel '
        'plate.',
    's1_o2':
        'The exact same amount of water (5 mL) is poured onto the plate, '
        'spreading out into a thin layer.',
    's1_c3': 'Starting the Time-Lapse',
    's1_a3': "TAP the 'Start Time-Lapse' button.",
    's1_o3':
        'A timer starts, and the evaporation process begins for both setups.',
    's1_c4': 'The Result',
    's1_a4':
        'Observe the experiment until all water has evaporated, then tap '
        "'Finish Observation'.",
    's1_o4':
        'The water on the plate disappears completely much faster than the '
        'water in the bottle cap.',
    // Scenario 2 steps.
    's2_c1': 'Placing Cap in Sun',
    's2_a1': 'DRAG one bottle cap and DROP it into the sunny area.',
    's2_o1':
        'The bottle cap is placed in a brightly lit area (higher '
        'temperature).',
    's2_c2': 'Placing Cap in Shade',
    's2_a2': 'DRAG the second bottle cap and DROP it into the shady area.',
    's2_o2':
        'The second bottle cap is placed in the darker, shaded area (lower '
        'temperature).',
    's2_c3': 'Filling Both Caps',
    's2_a3':
        'DRAG the beaker of water and DROP it onto each bottle cap, one '
        'after the other, to fill both caps.',
    's2_o3': 'Both bottle caps are filled with an equal amount of water.',
    's2_c4': 'Starting the Time-Lapse',
    's2_a4': "TAP the 'Start Time-Lapse' button.",
    's2_o4':
        'Timers start. Evaporation lines are faster and denser for the cap '
        'in the sun.',
    's2_c5': 'The Result',
    's2_a5':
        'Observe the experiment until all water has evaporated, then tap '
        "'Finish Observation'.",
    's2_o5':
        'Water in the sunny cap disappears completely long before the water '
        'in the shady cap.',
    // HUD "Current Task" lines.
    's1_hud_1':
        'Step 1: DRAG the beaker of water and DROP it onto the small bottle '
        'cap on the lab bench.',
    's1_hud_2':
        'Step 2: DRAG the same beaker of water and DROP it onto the large '
        'steel plate on the lab bench.',
    's1_hud_3':
        "Step 3: TAP the 'Start Time-Lapse' button to begin the experiment.",
    's1_hud_4':
        'Step 4: Observe the experiment until all the water has evaporated '
        'from both containers.',
    's1_hud_5': "Observation Complete! Tap 'Finish Observation'.",
    's2_hud_1':
        'Step 1: DRAG one bottle cap and DROP it into the sunny area on the '
        'screen.',
    's2_hud_2':
        'Step 2: DRAG the second bottle cap and DROP it into the shady area '
        'on the screen.',
    's2_hud_3':
        'Step 3: DRAG the beaker of water and DROP it onto each of the two '
        'bottle caps to fill them with an equal amount of water.',
    's2_hud_4':
        "Step 4: TAP the 'Start Time-Lapse' button to begin the experiment.",
    's2_hud_5':
        'Step 5: Observe the experiment until all the water has evaporated.',
    's2_hud_6': "Observation Complete! Tap 'Finish Observation'.",
    // Summaries.
    'sc_complete': 'Scenario {n} Complete!',
    'sum_1_head': 'Larger Surface Area = Faster Evaporation!',
    'sum_1_body':
        "The water on the plate evaporated at 04:30 (4 h 30 min) compared to "
        "the cap's 20:15 (20 h 15 min). The larger surface area allowed more "
        'water molecules to escape into the air simultaneously.',
    'sum_2_head': 'Higher Temperature = Faster Evaporation!',
    'sum_2_body':
        "The water in the sun evaporated at 03:45 (3 h 45 min) compared to "
        "the shade's 18:30 (18 h 30 min). Higher temperature gives water "
        'molecules more kinetic energy to change into water vapour!',
    // Teacher board accordion ("Observation Step").
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'obs_pending': 'Complete this step to see what happens.', // added
    // Buttons and canvas labels.
    'btn_lapse': 'Start Time-Lapse',
    'btn_finish': 'Finish Observation',
    'lbl_beaker': 'Beaker (Water)',
    'lbl_cap': 'Bottle Cap',
    'lbl_plate': 'Steel Plate',
    'lbl_sun': 'Sunny Area',
    'lbl_shade': 'Shady Area',
    // Added: timer unit, results card, refused drops, scene descriptions.
    'unit_h': 'h',
    'timers_title': 'Time-Lapse Timers',
    'timers_hint': 'Time taken for the water to evaporate (hours : minutes).',
    'col_container': 'Container',
    'col_time': 'Time',
    'row_sun': 'Bottle cap in the sun',
    'row_shade': 'Bottle cap in the shade',
    'status_wait': 'Not started',
    'status_run': 'Evaporating…',
    'toast_need_cap': 'Drop the beaker onto the small bottle cap.',
    'toast_need_plate': 'Drop the beaker onto the large steel plate.',
    'toast_need_sun': 'Drop the bottle cap into the sunny area, under the sun.',
    'toast_need_shade':
        'Drop the second bottle cap into the shady area, under the tree.',
    'toast_need_caps': 'Drop the beaker onto a bottle cap to fill it.',
    'toast_cap_full':
        'This bottle cap is already filled. Fill the other bottle cap.',
    'scene_s1':
        'Lab bench with a beaker of water, a small bottle cap and a large '
        'steel plate',
    'scene_s2':
        'Bench split into a sunny area and a shady area, with two bottle caps '
        'and a beaker of water',
  },
  'hi': {
    'app_title': 'वाष्पीकरण और इसकी दर को प्रभावित करने वाले कारक',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: सतह क्षेत्र',
    'scen_2_opt': 'परिदृश्य 2: धूप बनाम छाया (तापमान)',
    's1_desc':
        'देखकर जांच करना कि पानी के खुले सतह क्षेत्र का उसके वाष्पित होने की '
        'गति पर क्या प्रभाव पड़ता है।',
    's2_desc':
        'देखकर जांच करना कि तापमान का पानी के वाष्पित होने की गति पर क्या '
        'प्रभाव पड़ता है।',
    's1_c1': 'ढक्कन भरना',
    's1_a1': 'पानी के बीकर को खींचें और छोटे बोतल के ढक्कन पर छोड़ें।',
    's1_o1':
        'बोतल के ढक्कन में एक निश्चित मात्रा (जैसे, 5 mL) पानी डाला जाता है।',
    's1_c2': 'स्टील की प्लेट भरना',
    's1_a2': 'उसी पानी के बीकर को खींचें और बड़ी स्टील की प्लेट पर छोड़ें।',
    's1_o2':
        'पानी की बिल्कुल समान मात्रा (5 mL) प्लेट पर डाली जाती है, जो एक पतली '
        'परत में फैल जाती है।',
    's1_c3': 'टाइम-लैप्स शुरू करना',
    's1_a3': "'टाइम-लैप्स शुरू करें' बटन पर टैप करें।",
    's1_o3':
        'टाइमर शुरू होता है, और दोनों सेटअप में वाष्पीकरण की प्रक्रिया शुरू होती है।',
    's1_c4': 'परिणाम',
    's1_a4':
        'जब तक सारा पानी वाष्पित न हो जाए, तब तक प्रयोग का निरीक्षण करें, फिर '
        "'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o4':
        'प्लेट पर रखा पानी, ढक्कन के पानी की तुलना में बहुत जल्दी पूरी तरह गायब '
        'हो जाता है।',
    's2_c1': 'धूप में ढक्कन रखना',
    's2_a1': 'एक बोतल के ढक्कन को खींचें और धूप वाले क्षेत्र में छोड़ें।',
    's2_o1':
        'बोतल का ढक्कन तेज रोशनी वाले क्षेत्र (उच्च तापमान) में रखा गया है।',
    's2_c2': 'छाया में ढक्कन रखना',
    's2_a2': 'दूसरे बोतल के ढक्कन को खींचें और छायादार क्षेत्र में छोड़ें।',
    's2_o2': 'दूसरा ढक्कन गहरे, छायादार क्षेत्र (कम तापमान) में रखा गया है।',
    's2_c3': 'दोनों ढक्कन भरना',
    's2_a3':
        'पानी के बीकर को खींचें और एक-एक करके दोनों बोतल के ढक्कनों पर छोड़ें, '
        'ताकि दोनों ढक्कन भर जाएँ।',
    's2_o3': 'दोनों बोतल के ढक्कनों में समान मात्रा में पानी भरा जाता है।',
    's2_c4': 'टाइम-लैप्स शुरू करना',
    's2_a4': "'टाइम-लैप्स शुरू करें' बटन पर टैप करें।",
    's2_o4':
        'टाइमर शुरू होते हैं। धूप वाले ढक्कन से वाष्पीकरण की रेखाएँ तेज़ और घनी '
        'होती हैं।',
    's2_c5': 'परिणाम',
    's2_a5':
        'जब तक सारा पानी वाष्पित न हो जाए, तब तक प्रयोग का निरीक्षण करें, फिर '
        "'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o5':
        'धूप वाले ढक्कन का पानी, छायादार ढक्कन के पानी से बहुत पहले पूरी तरह '
        'गायब हो जाता है।',
    's1_hud_1':
        'चरण 1: पानी के बीकर को खींचें और लैब बेंच पर रखे छोटे बोतल के ढक्कन पर '
        'छोड़ें।',
    's1_hud_2':
        'चरण 2: उसी पानी के बीकर को खींचें और बड़ी स्टील की प्लेट पर छोड़ें।',
    's1_hud_3':
        "चरण 3: प्रयोग शुरू करने के लिए 'टाइम-लैप्स शुरू करें' बटन पर टैप करें।",
    's1_hud_4':
        'चरण 4: प्रयोग का निरीक्षण करें जब तक कि दोनों बर्तनों से सारा पानी वाष्पित '
        'न हो जाए।',
    's1_hud_5': "अवलोकन पूर्ण! 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1':
        'चरण 1: एक बोतल के ढक्कन को खींचें और धूप वाले क्षेत्र में छोड़ें।',
    's2_hud_2': 'चरण 2: दूसरे ढक्कन को खींचें और छायादार क्षेत्र में छोड़ें।',
    's2_hud_3':
        'चरण 3: बीकर को खींचकर दोनों ढक्कनों पर एक-एक करके छोड़ें, ताकि दोनों में '
        'समान मात्रा में पानी भर जाए।',
    's2_hud_4':
        "चरण 4: प्रयोग शुरू करने के लिए 'टाइम-लैप्स शुरू करें' बटन पर टैप करें।",
    's2_hud_5':
        'चरण 5: प्रयोग का निरीक्षण करें जब तक कि सारा पानी वाष्पित न हो जाए।',
    's2_hud_6': "अवलोकन पूर्ण! 'अवलोकन समाप्त करें' पर टैप करें।",
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_1_head': 'बड़ा सतह क्षेत्र = तेज वाष्पीकरण!',
    'sum_1_body':
        'प्लेट पर पानी 04:30 (4 घंटे 30 मिनट) में वाष्पित हो गया, जबकि ढक्कन '
        'में 20:15 (20 घंटे 15 मिनट) लगे। बड़े सतह क्षेत्र के कारण एक साथ अधिक '
        'पानी के अणु हवा में जा सके।',
    'sum_2_head': 'उच्च तापमान = तेज वाष्पीकरण!',
    'sum_2_body':
        'धूप में पानी 03:45 (3 घंटे 45 मिनट) में वाष्पित हो गया, जबकि छाया में '
        '18:30 (18 घंटे 30 मिनट) लगे। उच्च तापमान पानी के अणुओं को जलवाष्प में '
        'बदलने के लिए अधिक गतिज ऊर्जा देता है!',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'क्या होता है, यह देखने के लिए यह चरण पूरा करें।',
    'btn_lapse': 'टाइम-लैप्स शुरू करें',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_beaker': 'बीकर (पानी)',
    'lbl_cap': 'बोतल का ढक्कन',
    'lbl_plate': 'स्टील की प्लेट',
    'lbl_sun': 'धूप वाला क्षेत्र',
    'lbl_shade': 'छायादार क्षेत्र',
    'unit_h': 'घंटे',
    'timers_title': 'टाइम-लैप्स टाइमर',
    'timers_hint': 'पानी के वाष्पित होने में लगा समय (घंटे : मिनट)।',
    'col_container': 'बर्तन',
    'col_time': 'समय',
    'row_sun': 'धूप में रखा ढक्कन',
    'row_shade': 'छाया में रखा ढक्कन',
    'status_wait': 'शुरू नहीं हुआ',
    'status_run': 'वाष्पीकरण जारी…',
    'toast_need_cap': 'बीकर को छोटे बोतल के ढक्कन पर छोड़ें।',
    'toast_need_plate': 'बीकर को बड़ी स्टील की प्लेट पर छोड़ें।',
    'toast_need_sun':
        'बोतल के ढक्कन को सूरज के नीचे, धूप वाले क्षेत्र में छोड़ें।',
    'toast_need_shade':
        'दूसरे बोतल के ढक्कन को पेड़ के नीचे, छायादार क्षेत्र में छोड़ें।',
    'toast_need_caps':
        'ढक्कन भरने के लिए बीकर को किसी बोतल के ढक्कन पर छोड़ें।',
    'toast_cap_full': 'यह ढक्कन पहले से भरा है। अब दूसरे ढक्कन को भरें।',
    'scene_s1':
        'पानी के बीकर, छोटे बोतल के ढक्कन और बड़ी स्टील की प्लेट वाली लैब बेंच',
    'scene_s2':
        'धूप वाले और छायादार क्षेत्र में बँटी बेंच, दो बोतल के ढक्कन और पानी का '
        'बीकर',
  },
};

/// Steps per scenario (HTML `ScenariosData[...].steps`: 4 and 5).
const List<int> _stepCounts = [4, 5];

/// The two scenarios for [lang] (HTML `ScenariosData`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var sc = 1; sc <= _stepCounts.length; sc++)
      LabScenarioData(
        title: t('scen_${sc}_opt'),
        objective: t('s${sc}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[sc - 1]; i++)
            LabStep(
              concept: t('s${sc}_c$i'),
              action: t('s${sc}_a$i'),
              observation: t('s${sc}_o$i'),
            ),
        ],
      ),
  ];
}

/// Scenario data per language, built once.
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the scene (stage coordinates).
const Size _design = Size(1000, 560);

/// Short drags must pick an object up before the zoom viewer claims them.
const double _touchSlop = 8;

/// Smallest touch target (objects in the scene, accordion rows), in dp.
const double _minTouch = 48;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make particles jump.
const double _maxFrameStep = 0.1;

/// Part of the base projection (design px at zoom 1) holding everything the
/// learner handles and watches, per scenario, up to where the scene labels
/// are pinned: S1 from the beaker label's centre (beaker at home) to the
/// centre of the cap's label and timer, and from the beaker's rim while it
/// pours into the cap to the top of the plate's label; S2 the caps at their
/// start and in both areas, the beaker, the area labels and the sun's disc.
/// The scene is framed so that this box, plus [_labelRoom], fills the free
/// part of the canvas ([_EvaporationLabState._frameFor]).
const List<Rect> _content = [
  Rect.fromLTRB(295, 108, 738, 334),
  Rect.fromLTRB(175, -25, 825, 400),
];

/// Room the labels need around [_content], in label text sizes: in S1 half
/// a label's width at the sides and a label's height below (the labels grow
/// on small screens, so this room grows with them); S2's labels lie inside
/// its box.
const List<EdgeInsets> _labelRoom = [
  EdgeInsets.fromLTRB(4, 0, 4, 1.8),
  EdgeInsets.zero,
];
const double _maxZoom = 1.3;
const double _minZoom = 0.6;

/// Canvas bands kept free of the scene (dp, times the UI scale): the toast
/// row at the top (below its 10 dp margin) and the HUD chip at the bottom.
const double _toastTop = 10;
const double _toastBand = 40;
const double _hudBand = 58;
const double _edge = 8;

/// The shell's floating mission card (sidebar collapsed): 76 dp from the
/// left, 12 dp from the top; on phones (screens under 480 dp tall) at most
/// 55 % of the screen tall.
const double _missionLeft = 76;
const double _missionTop = 12;
const double _missionMaxHeight = 0.55;
const double _compactBelow = 480;

/// Room the shell's tool column takes on the right of the canvas.
const double _toolColumn = 72;

/// The view re-frames like the sidebar slides (380 ms).
const double _frameSeconds = 0.38;

/// Scene labels and timers keep a readable on-screen size on small phones
/// (HTML: 10–12 px labels, 18–20 px timers).
const double _labelPx = 12;
const double _timerPx = 15;
const double _labelFullScale = 0.9;
const double _labelMaxBoost = 2.2;

/// Rounds of [_EvaporationLabState._frameFor]'s zoom / label-size search.
const int _frameIterations = 6;

/// How much labels and timers are enlarged when one base px is [k] screen
/// px.
double _labelBoost(double k) =>
    (_labelFullScale / math.max(0.01, k)).clamp(1.0, _labelMaxBoost);

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
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }

  /// Three.js `rotation.z` by [a].
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  /// Horizontal (xz) distance to [o].
  double flatTo(_V o) {
    final dx = x - o.x, dz = z - o.z;
    return math.sqrt(dx * dx + dz * dz);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Pinhole projection of the HTML `PerspectiveCamera(45°)` at (0, 20, 30)
/// looking at `controls.target` (0, 0, 0) (`resetCamera()`, landscape; the
/// HTML's (0, 35, 50) is for portrait screens under 640 px). These are the
/// base coordinates; [_Frame] scales and moves them onto the stage.
class _Proj {
  _Proj(this.eye, _V target) : f = (target - eye).unit {
    r = f.cross(_V.up).unit;
    u = r.cross(f);
  }

  /// Focal length for the 45° vertical field of view over the stage height.
  static final double focal = _design.height / 2 / math.tan(math.pi / 8);

  /// Where the look-at point lands at zoom 1.
  static const Offset center = Offset(500, 280);

  final _V eye;
  final _V f;
  late final _V r;
  late final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Base px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a base point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray meets the horizontal plane y = [py], or null.
  _V? onPlaneY(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    return t <= 0 ? null : eye + d * t;
  }
}

final _Proj _proj = _Proj(const _V(0, 20, 30), _V.zero);

/// A Three.js group transform: position plus `rotation.z`.
@immutable
class _Xf {
  const _Xf(this.pos, [this.rotZ = 0]);

  final _V pos;
  final double rotZ;

  _V call(_V local) => pos + (rotZ == 0 ? local : local.rotZ(rotZ));
}

/// How the base projection sits on the stage: `design = offset + base *
/// zoom`. Painting and hit tests both go through it, so the scene can be
/// re-framed beside the shell's cards without moving any world position.
@immutable
class _Frame {
  const _Frame(this.zoom, this.offset);

  static const _Frame identity = _Frame(1, Offset.zero);

  final double zoom;
  final Offset offset;

  Offset toDesign(Offset base) => offset + base * zoom;
  Offset toBase(Offset design) => (design - offset) / zoom;

  static _Frame lerp(_Frame a, _Frame b, double t) => _Frame(
    a.zoom + (b.zoom - a.zoom) * t,
    Offset.lerp(a.offset, b.offset, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is _Frame && other.zoom == zoom && other.offset == offset;

  @override
  int get hashCode => Object.hash(zoom, offset);
}

// ---- Scene layout (HTML buildCommonObjects / buildScenario1Scene /
// buildScenario2Scene), world units.

/// Beaker: open `CylinderGeometry(2, 2, 5)` (centred on the group), water
/// `CylinderGeometry(1.9, 1.9, 4)` from local y -2.4. The HTML beaker
/// hovered 1 unit above the bench (y 3.5); here it stands on it.
const double _beakerR = 2;
const double _beakerHalfH = 2.5;
const double _beakerWaterR = 1.9;
const double _beakerWaterBottom = -2.4;
const double _beakerWaterH = 4;
const double _beakerRestY = 2.5;

/// Distance (world units) within which the beaker counts as at home.
const double _atHome = 1e-3;

/// The beaker is drawn this much higher while it is held (lifted).
const double _liftY = 0.8;

/// `beaker.userData.homePos`: (-10, y, 0) in Scenario 1, (0, y, 8) in 2.
const _V _beakerHomeS1 = _V(-10, _beakerRestY, 0);
const _V _beakerHomeS2 = _V(0, _beakerRestY, 8);

/// `pourAnimation`: the beaker moves to the target + (-3, 6, 0) and tilts
/// to `rotation.z = -π/3`; water leaves from its lip, local (2, 2.5, 0).
/// Each pour uses a quarter of the beaker's water (`scale.y - 0.25`).
const _V _pourOffset = _V(-3, 6, 0);
const double _pourTilt = -math.pi / 3;
const _V _lip = _V(2, 2.5, 0);
const double _pourUse = 0.25;
const double _beakerMinWater = 0.01;

/// Bottle cap: open `CylinderGeometry(1.5, 1.5, 0.6)` with a base at local
/// y -0.25, group at y 0.3; water `CylinderGeometry(1.4, 1.4, 0.4)`. The
/// water rises from the cap's floor (local -0.2).
const double _capR = 1.5;
const double _capH = 0.6;
const double _capY = 0.3;
const double _capWaterR = 1.4;
const double _capFloor = -0.2;
const double _capWaterH = 0.4;

/// Scenario 1: `s1Cap` at (12, 0.3, 0); `s1Plate` `BoxGeometry(8, 0.4, 8)`
/// at (2, 0.2, 0) with a water layer `BoxGeometry(7.6, 0.1, 7.6)` on top.
const _V _capS1 = _V(12, _capY, 0);
const _V _plateS1 = _V(2, 0.2, 0);
const double _plateHalf = 4;
const double _plateH = 0.4;
const double _plateWaterHalf = 3.8;

/// Scenario 2: `s2CapSun` / `s2CapShade` start at (∓4, 0.3, 8) and are
/// moved to (∓10, 0.3, 0) in the sunny / shady area.
const _V _capStartA = _V(-4, _capY, 8);
const _V _capStartB = _V(4, _capY, 8);
const _V _sunSpot = _V(-10, _capY, 0);
const _V _shadeSpot = _V(10, _capY, 0);

/// A cap counts as put into an area when it is dropped on the sunlit patch
/// under the sun or the tree's shadow (radius around the HTML spots). The
/// HTML accepted any drop within 18 units of the area's centre, including
/// the other area and the cap's start, which already lies on that bench.
const double _patchR = 6.5;

/// The beaker pours when it is released over a container: footprints
/// overlapping a cap (2 + 1.5), or within the plate plus the beaker's
/// half width. (HTML: any release within 18 units, so a drop on the plate
/// filled the cap.)
const double _capCatch = 3.5;
const double _plateCatch = 5.5;

/// What can be carried stays on the bench (40 x 20; 20 x 20 halves in S2).
const double _carryX = 18;
const double _carryBack = -8;
const double _carryFront = 8.5;

/// Lighting (HTML: AmbientLight 0.8, DirectionalLight 0.6 at (10, 20, 15)),
/// toned down so lit colours are not washed out without tone mapping.
const _V _keyDir = _V(0.3714, 0.7428, 0.5571);
const double _ambient = 0.62;
const double _keyGain = 0.5;

// ---- Timing (HTML TWEEN durations and setTimeouts), seconds.

const double _pourMove = 0.5; // to the target + tilt, 500 ms
const double _pourTime = 1.0; // water scale tweens, 1000 ms
const double _pourBack = 0.5; // tilt back + home, 500 ms
const double _returnTime = 0.5; // refused drop: home, Quadratic.Out
const double _snapTime = 0.5; // cap into its area, 500 ms
const double _dropEvery = 0.03; // pour particles: setInterval 30 ms
const int _dropsPerTick = 2;
const double _dropFall = 0.3; // each falls in 300 ms, Quadratic.In
const double _dropJitter = 0.2; // (Math.random() - 0.5) * 0.4
const double _lapseSettle = 1.5; // setTimeout(advanceStep, 1500)

/// The plate's water spreads out from a quarter of its size while poured
/// (added: the observation says it spreads into a thin layer).
const double _spreadStart = 0.25;

/// One container's time-lapse: tween duration (s) and the timer reading at
/// the end (HTML `targetSecs`), shown as hours : minutes.
@immutable
class _Lapse {
  const _Lapse(this.seconds, this.minutes);

  final double seconds;
  final int minutes;
}

const _Lapse _lapsePlate = _Lapse(3, 270); // 04:30
const _Lapse _lapseCap = _Lapse(6, 1215); // 20:15
const _Lapse _lapseSun = _Lapse(2.5, 225); // 03:45
const _Lapse _lapseShade = _Lapse(6, 1110); // 18:30

/// Vapour (`emitParticle`): spheres rise 4–6 units in 1.5–2.5 s and fade
/// out in 1.5 s. The HTML emitted at the same rate for both containers;
/// here the rate and speed grow with how fast the water evaporates, so the
/// faster setup shows faster, denser vapour (as its observation says).
const double _puffRate = 10; // per second, for a 6 s time-lapse
const double _puffRefSeconds = 6;
const double _puffRiseMin = 4;
const double _puffRiseSpan = 2;
const double _puffFade = 1.5;
const double _puffTravelMin = 1.5;
const double _puffSpread = 0.8; // of the water's width
const double _puffRadius = 0.16;
const double _puffAlpha = 0.6;
const int _puffPool = 96;
const int _dropPool = 48;

/// The pulsing highlight of the object to drag (HTML `pulse` at 5 rad/s).
const double _pulseRate = 5;

enum _PotKind { cap, plate }

enum _Zone { none, sun, shade }

/// A container: Scenario 1's bottle cap and steel plate, Scenario 2's two
/// bottle caps.
class _Pot {
  _Pot(this.kind, this.home) : pos = home;

  final _PotKind kind;

  /// Where it stands (a cap moves to its area in Scenario 2).
  _V home;
  _V pos;
  _Zone zone = _Zone.none;

  /// Water in it: 0 empty, 1 full (rises while poured, falls while it
  /// evaporates).
  double level = 0;

  /// The plate's water spreads out while it is poured.
  double spread = 0;
  bool filled = false;
  _Lapse? lapse;

  /// Timer reading (HTML `curSec`), in time-lapse minutes.
  int minutes = 0;
  bool dry = false;

  /// Vapour particles owed (fractional emission).
  double puffDebt = 0;

  bool get isCap => kind == _PotKind.cap;

  /// Height of the water surface.
  double get surfaceY => isCap
      ? pos.y + _capFloor + _capWaterH * level
      : pos.y + _plateH / 2 + 0.05;

  /// Half width of the water (vapour comes off all of it).
  double get waterHalf =>
      isCap ? _capWaterR : _plateWaterHalf * spread * math.sqrt(level);
}

/// One falling drop of the pouring stream.
class _Drop {
  bool on = false;
  double x = 0;
  double z = 0;
  double y0 = 0;
  double y1 = 0;
  double t0 = 0;
}

/// One rising vapour particle.
class _Puff {
  bool on = false;
  double x = 0;
  double z = 0;
  double y0 = 0;
  double rise = 0;
  double travel = 1;
  double fade = 1;
  double t0 = 0;
}

/// One running animation (HTML TWEEN / setTimeout), on the scene clock.
class _Tween {
  _Tween(this.start, this.duration, this.apply, this.curve, this.onDone);

  final double start;
  final double duration;
  final void Function(double t)? apply;
  final Curve curve;
  final VoidCallback? onDone;
}

enum _Held { beaker, pot }

/// Mutable simulation state read by the painter every frame.
class _Sim {
  int scenario = 0;

  /// 1-based current step; [stepCount] + 1 once the scenario is done.
  int step = 1;
  double time = 0;

  /// An animation is running (pour, snap, return); drags and buttons wait.
  bool busy = false;
  final List<_Tween> _tweens = [];
  final math.Random rnd = math.Random(8);

  // ---- Beaker.
  _V beaker = _beakerHomeS1;
  double tilt = 0;

  /// HTML `beaker.userData.water.scale.y`.
  double beakerWater = 1;

  // ---- Containers (S1: cap, plate; S2: the left and the right cap).
  final List<_Pot> pots = [];

  // ---- Pouring stream.
  bool pouring = false;
  _V pourFrom = _V.zero;
  double pourToY = 0;
  double nextDrop = 0;
  final List<_Drop> drops = List.generate(_dropPool, (_) => _Drop());

  // ---- Time-lapse.
  bool lapseOn = false;
  double lapseStart = 0;
  double allDryAt = -1;
  bool lapseDone = false;
  final List<_Puff> puffs = List.generate(_puffPool, (_) => _Puff());

  // ---- Dragging.
  _Held? held;
  int heldPot = -1;
  double dragY = 0;
  _V grabOffset = _V.zero;

  // ---- Framing.
  _Frame frame = _Frame.identity;
  _Frame frameTarget = _Frame.identity;
  _Frame _frameFrom = _Frame.identity;
  double _frameStart = -1;
  bool _framed = false;

  // ---- Painting resources, created once and reused every frame.
  final _Pictures pictures = _Pictures();
  final _TextCache text = _TextCache();
  final _Draw draw = _Draw();

  int get stepCount => _stepCounts[scenario];
  bool get finished => step > stepCount;

  /// The step with the 'Start Time-Lapse' button (S1 step 3, S2 step 4).
  int get lapseStep => scenario == 0 ? 3 : 4;
  _V get beakerHome => scenario == 0 ? _beakerHomeS1 : _beakerHomeS2;
  bool get animating => _tweens.isNotEmpty;

  /// The beaker stands at its place: not held, pouring or sliding back.
  bool get beakerAtHome =>
      held != _Held.beaker && (beaker - beakerHome).length < _atHome;

  /// Where the beaker is drawn (lifted while held).
  _V get beakerDrawn =>
      held == _Held.beaker ? beaker + const _V(0, _liftY, 0) : beaker;

  /// Where cap [i] is drawn (lifted while held).
  _V potDrawn(int i) => held == _Held.pot && heldPot == i
      ? pots[i].pos + const _V(0, _liftY / 2, 0)
      : pots[i].pos;

  /// The view has reached its framing (flows read [anchor] only then).
  bool get framingSettled => _framed && _frameStart < 0;

  /// The S1 cap / plate and the S2 caps by area (null before placing).
  _Pot? potIn(_Zone zone) {
    for (final p in pots) {
      if (p.zone == zone) return p;
    }
    return null;
  }

  void tween(
    double seconds,
    void Function(double t)? apply, {
    Curve curve = Curves.linear,
    VoidCallback? onDone,
  }) => _tweens.add(_Tween(time, seconds, apply, curve, onDone));

  /// Advances every tween to [time]; finished ones run their callback,
  /// which may start new tweens (they run from the next frame).
  void runTweens() {
    if (_tweens.isEmpty) return;
    for (final tw in List.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final t = tw.duration <= 0
          ? 1.0
          : ((time - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.apply?.call(tw.curve.transform(t));
      if (t >= 1) {
        _tweens.remove(tw);
        tw.onDone?.call();
      }
    }
  }

  /// Sets where the view should be framed; the first one is taken at once,
  /// later ones slide in over [_frameSeconds].
  void setFrameTarget(_Frame f) {
    if (!_framed) {
      frame = frameTarget = f;
      _framed = true;
      return;
    }
    if (f == frameTarget) return;
    _frameFrom = frame;
    frameTarget = f;
    _frameStart = time;
  }

  /// Moves the view towards its target.
  void stepFrame() {
    if (_frameStart < 0) return;
    final t = ((time - _frameStart) / _frameSeconds).clamp(0.0, 1.0);
    frame = _Frame.lerp(
      _frameFrom,
      frameTarget,
      Curves.easeInOutCubic.transform(t),
    );
    if (t >= 1) {
      frame = frameTarget;
      _frameStart = -1;
    }
  }

  /// HTML `resetScenarioState(sc)`: the bench of [sc] at step 1.
  void reset(int sc) {
    scenario = sc;
    step = 1;
    busy = false;
    _tweens.clear();
    beaker = beakerHome;
    tilt = 0;
    beakerWater = 1;
    pots
      ..clear()
      ..addAll(
        sc == 0
            ? [_Pot(_PotKind.cap, _capS1), _Pot(_PotKind.plate, _plateS1)]
            : [_Pot(_PotKind.cap, _capStartA), _Pot(_PotKind.cap, _capStartB)],
      );
    pouring = false;
    for (final d in drops) {
      d.on = false;
    }
    for (final p in puffs) {
      p.on = false;
    }
    lapseOn = false;
    lapseStart = 0;
    allDryAt = -1;
    lapseDone = false;
    held = null;
    heldPot = -1;
    grabOffset = _V.zero;
  }

  /// Starts a pour drop at the lip, falling to the target's surface.
  void emitDrop() {
    for (final d in drops) {
      if (d.on) continue;
      d
        ..on = true
        ..x = pourFrom.x + (rnd.nextDouble() - 0.5) * 2 * _dropJitter
        ..z = pourFrom.z + (rnd.nextDouble() - 0.5) * 2 * _dropJitter
        ..y0 = pourFrom.y
        ..y1 = pourToY
        ..t0 = time;
      return;
    }
  }

  /// HTML `emitParticle(parent, spread)`: a vapour particle over [pot],
  /// [speed] times as fast and frequent as the slowest setup.
  void emitPuff(_Pot pot, double speed) {
    for (final p in puffs) {
      if (p.on) continue;
      final half = pot.waterHalf * _puffSpread;
      final double dx, dz;
      if (pot.isCap) {
        final a = rnd.nextDouble() * 2 * math.pi;
        final r = half * math.sqrt(rnd.nextDouble());
        dx = r * math.cos(a);
        dz = r * math.sin(a);
      } else {
        dx = (rnd.nextDouble() * 2 - 1) * half;
        dz = (rnd.nextDouble() * 2 - 1) * half;
      }
      final k = math.sqrt(speed);
      p
        ..on = true
        ..x = pot.pos.x + dx
        ..z = pot.pos.z + dz
        ..y0 = pot.surfaceY + 0.15
        ..rise = _puffRiseMin + rnd.nextDouble() * _puffRiseSpan
        ..travel = (_puffTravelMin + rnd.nextDouble()) / k
        ..fade = _puffFade / k
        ..t0 = time;
      return;
    }
  }

  /// Retires drops that have landed and vapour that has faded.
  void tickParticles() {
    for (final d in drops) {
      if (d.on && time - d.t0 >= _dropFall) d.on = false;
    }
    for (final p in puffs) {
      if (p.on && time - p.t0 >= p.fade) p.on = false;
    }
  }

  /// Design point of a named place, for the flow tests:
  /// - 'beaker': the beaker's middle (where to grab it);
  /// - 'cap' / 'plate' (S1), 'over_pot0' / 'over_pot1' (S2): where the
  ///   beaker's middle goes to be over that container;
  /// - 'pot0' / 'pot1' (S2): the left / right bottle cap (grab point);
  /// - 'sun' / 'shade' (S2): a spot in the sunlit patch / the tree's
  ///   shadow;
  /// - 'bench_empty': free bench, over no container.
  Offset anchor(String id) {
    _V over(_V p) => _V(p.x, _beakerRestY, p.z);
    final w = switch (id) {
      'beaker' => beaker,
      'cap' => over(pots[0].pos),
      'plate' => over(pots[1].pos),
      'over_pot0' => over(pots[0].pos),
      'over_pot1' => over(pots[1].pos),
      'pot0' => pots[0].pos,
      'pot1' => pots[1].pos,
      'sun' => _sunSpot + const _V(0, 0, 2),
      'shade' => _shadeSpot + const _V(0, 0, 2),
      'bench_empty' =>
        scenario == 0
            ? const _V(-5, _beakerRestY, 7)
            : const _V(0, _beakerRestY, -4),
      _ => throw ArgumentError.value(id, 'id'),
    };
    return frame.toDesign(_proj.p(w));
  }

  void dispose() {
    pictures.dispose();
    text.dispose();
  }
}

/// Pan recognizer that only claims pointers that start on something the
/// learner can drag (decided by [canGrab]), so other drags still pan the
/// zoomed canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _EvaporationLabState
    extends State<Ch8A2EvaporationAndFactorsAffectingItsRatePage>
    with SingleTickerProviderStateMixin {
  /// The HTML starts with the camera locked (`isCamLocked: true`).
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Sim _sim = _Sim();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Stage scale (screen px per design px) from the last layout.
  double _fit = 1;

  /// Scene label and timer text sizes in base px.
  double _labelSize = _labelPx;
  double _timerSize = _timerPx;

  /// What the pointer landed on when a drag may start.
  _Held? _pending;
  int _pendingPot = -1;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_sim.scenario];

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
    _sim.reset(0);
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
    _sim.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()` + `TWEEN.update()`: tweens, the pouring stream, the
  /// time-lapse and its vapour, the view's re-framing; then one repaint.
  void _onTick(Duration elapsed) {
    final s = _sim;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.stepFrame();
    s.runTweens();
    if (s.pouring) {
      while (s.nextDrop <= s.time) {
        for (var i = 0; i < _dropsPerTick; i++) {
          s.emitDrop();
        }
        s.nextDrop += _dropEvery;
      }
    }
    _tickLapse(dt);
    s.tickParticles();
    _frame.value = now;
  }

  /// HTML `runEvaporationTween`: each container's water shrinks and its
  /// timer counts up; a container that has dried 'dings' and its timer
  /// turns orange. 1.5 s after the last one the observation is complete.
  void _tickLapse(double dt) {
    final s = _sim;
    if (!s.lapseOn || s.lapseDone) return;
    var changed = false;
    final elapsed = s.time - s.lapseStart;
    for (final pot in s.pots) {
      final lapse = pot.lapse;
      if (lapse == null || pot.dry) continue;
      final p = (elapsed / lapse.seconds).clamp(0.0, 1.0);
      pot
        ..minutes = (p * lapse.minutes).floor()
        ..level = 1 - p;
      final speed = _puffRefSeconds / lapse.seconds;
      pot.puffDebt += _puffRate * speed * dt;
      while (pot.puffDebt >= 1) {
        pot.puffDebt -= 1;
        s.emitPuff(pot, speed);
      }
      if (p >= 1) {
        pot
          ..dry = true
          ..level = 0
          ..minutes = lapse.minutes;
        _Sound.correct.play();
        changed = true;
      }
    }
    if (s.allDryAt < 0 && s.pots.every((p) => p.dry)) s.allDryAt = s.time;
    if (s.allDryAt >= 0 && s.time - s.allDryAt >= _lapseSettle) {
      s
        ..lapseDone = true
        ..step = s.stepCount + 1;
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(sc)` / Restart: cancels pending timers and
  /// rebuilds the bench for [scenario] at step 1.
  void _loadScenario(int scenario) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _pending = null;
    setState(() => _sim.reset(scenario));
    _lab.resetView(sound: false);
  }

  /// HUD line of the current step (HTML `hud[step]`; the last line once the
  /// observation is complete).
  String get _hud {
    final s = _sim;
    return _t('s${s.scenario + 1}_hud_${s.step.clamp(1, s.stepCount + 1)}');
  }

  /// HTML `pourAnimation(target)`: the beaker moves above [index] and
  /// tilts, water streams from its lip for a second while the container
  /// fills and the beaker empties by a quarter, then it goes back home.
  void _pour(int index) {
    final s = _sim;
    final pot = s.pots[index];
    final from = s.beaker;
    final at = pot.pos + _pourOffset;
    setState(() => s.busy = true);
    _Sound.drop.play();
    s.tween(
      _pourMove,
      (t) {
        s
          ..beaker = _V.lerp(from, at, t)
          ..tilt = _pourTilt * t;
      },
      onDone: () {
        pot.filled = true;
        s
          ..pouring = true
          ..pourFrom = at + _lip.rotZ(_pourTilt)
          ..pourToY = pot.isCap
              ? pot.pos.y + _capFloor + _capWaterH
              : pot.pos.y + _plateH / 2
          ..nextDrop = s.time;
        final water = s.beakerWater;
        s.tween(
          _pourTime,
          (t) {
            pot
              ..level = t
              ..spread = pot.isCap ? 1 : _spreadStart + (1 - _spreadStart) * t;
            s.beakerWater = math.max(_beakerMinWater, water - _pourUse * t);
          },
          onDone: () {
            s.pouring = false;
            final home = s.beakerHome;
            s.tween(_pourBack, (t) {
              s
                ..beaker = _V.lerp(at, home, t)
                ..tilt = _pourTilt * (1 - t);
            }, onDone: () => _afterPour());
          },
        );
      },
    );
  }

  /// The pour is over: Scenario 1 moves on; Scenario 2 moves on once both
  /// caps hold water.
  void _afterPour() {
    if (!mounted) return;
    final s = _sim;
    setState(() {
      s
        ..beaker = s.beakerHome
        ..tilt = 0
        ..busy = false;
      if (s.scenario == 0) {
        s.step++;
      } else if (s.pots.every((p) => p.filled)) {
        s.step = s.lapseStep;
      }
    });
  }

  /// HTML step 1 / 2 of Scenario 2: the cap glides to its spot in [zone].
  void _placeCap(int index, _Zone zone) {
    final s = _sim;
    final pot = s.pots[index];
    final from = pot.pos;
    final to = zone == _Zone.sun ? _sunSpot : _shadeSpot;
    pot.zone = zone;
    setState(() => s.busy = true);
    _Sound.drop.play();
    s.tween(
      _snapTime,
      (t) => pot.pos = _V.lerp(from, to, t),
      onDone: () {
        if (!mounted) return;
        setState(() {
          pot
            ..pos = to
            ..home = to;
          s.busy = false;
          s.step++;
        });
      },
    );
  }

  /// HTML `checkDrop()` refusal: the object slides back home (500 ms,
  /// Quadratic.Out) and a hint says where it belongs (added).
  void _refuse(_Held what, int index, String? toastKey) {
    final s = _sim;
    if (toastKey != null) _lab.showToast(_t(toastKey), isError: true);
    final from = what == _Held.beaker ? s.beaker : s.pots[index].pos;
    final home = what == _Held.beaker ? s.beakerHome : s.pots[index].home;
    setState(() => s.busy = true);
    s.tween(
      _returnTime,
      (t) {
        final p = _V.lerp(from, home, t);
        if (what == _Held.beaker) {
          s.beaker = p;
        } else {
          s.pots[index].pos = p;
        }
      },
      curve: Curves.easeOutQuad,
      onDone: () {
        if (mounted) setState(() => s.busy = false);
      },
    );
  }

  /// HTML `triggerTimeLapse()`: both timers start, the water begins to
  /// evaporate and the observation step is current while it does.
  void _startLapse() {
    final s = _sim;
    if (s.busy || s.lapseOn || s.step != s.lapseStep) return;
    setState(() {
      for (final pot in s.pots) {
        pot.lapse = s.scenario == 0
            ? (pot.isCap ? _lapseCap : _lapsePlate)
            : (pot.zone == _Zone.sun ? _lapseSun : _lapseShade);
      }
      s
        ..lapseOn = true
        ..lapseStart = s.time;
      s.step++;
    });
  }

  /// HTML 'Finish Observation' (`triggerMainAction()`): the summary.
  void _finish() {
    final s = _sim;
    if (!s.lapseDone) return;
    final sc = s.scenario;
    final n = sc + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => labFormat(_t('sc_complete'), {'n': n}),
      heading: () => _t('sum_${n}_head'),
      body: () => _t('sum_${n}_body'),
    );
  }

  // ------------------------------------------------------------- gestures

  /// Can the beaker be picked up now (HTML `activeDragTarget`)?
  bool get _beakerActive {
    final s = _sim;
    if (s.busy || s.finished) return false;
    return s.scenario == 0 ? s.step <= 2 : s.step == 3;
  }

  /// Can cap [i] be picked up now (Scenario 2, steps 1–2, not yet placed)?
  /// Either cap may go into the sunny area first (HTML: only the left one).
  bool _potActive(int i) {
    final s = _sim;
    return s.scenario == 1 &&
        !s.busy &&
        s.step <= 2 &&
        s.pots[i].zone == _Zone.none;
  }

  /// Screen dp per base px (stage scale, canvas zoom and framing).
  double get _dpPerBase =>
      _fit * _lab.transform.value.getMaxScaleOnAxis() * _sim.frame.zoom;

  /// [rect] grown to at least [_minTouch] dp each way.
  Rect _touchRect(Rect rect) {
    final min = _minTouch / math.max(0.01, _dpPerBase);
    final gx = math.max(0.0, min - rect.width) / 2;
    final gy = math.max(0.0, min - rect.height) / 2;
    return Rect.fromLTRB(
      rect.left - gx,
      rect.top - gy,
      rect.right + gx,
      rect.bottom + gy,
    );
  }

  bool _onBeaker(Offset base) => _touchRect(
    _projBox(_sim.beaker, _beakerR, -_beakerHalfH, _beakerHalfH, _beakerR),
  ).contains(base);

  bool _onPot(int i, Offset base) => _touchRect(
    _projBox(_sim.pots[i].pos, _capR, -_capH / 2, _capH / 2, _capR),
  ).contains(base);

  bool _canGrab(PointerDownEvent event) {
    final s = _sim;
    _pending = null;
    if (!_lab.isLabActive || s.busy || s.held != null || _lab.popup != null) {
      return false;
    }
    final base = s.frame.toBase(event.localPosition);
    if (_beakerActive && _onBeaker(base)) {
      _pending = _Held.beaker;
      return true;
    }
    for (var i = 0; i < s.pots.length; i++) {
      if (_potActive(i) && _onPot(i, base)) {
        _pending = _Held.pot;
        _pendingPot = i;
        return true;
      }
    }
    return false;
  }

  /// HTML `startDrag`: the object is held at the point grabbed and moves
  /// over the bench (ray–plane intersection with its own height; the HTML
  /// dragged it in a plane facing the camera, so it rose and sank).
  void _dragStart(DragStartDetails d) {
    final s = _sim;
    final what = _pending;
    if (what == null || s.busy) return;
    final pos = what == _Held.beaker ? s.beaker : s.pots[_pendingPot].pos;
    final hit = _proj.onPlaneY(s.frame.toBase(d.localPosition), pos.y) ?? pos;
    setState(() {
      s
        ..held = what
        ..heldPot = what == _Held.pot ? _pendingPot : -1
        ..dragY = pos.y
        ..grabOffset = _V(pos.x - hit.x, 0, pos.z - hit.z);
    });
    _Sound.pickup.play();
  }

  void _dragUpdate(DragUpdateDetails d) {
    final s = _sim;
    final what = s.held;
    if (what == null) return;
    final hit = _proj.onPlaneY(s.frame.toBase(d.localPosition), s.dragY);
    if (hit == null) return;
    final p = _V(
      (hit.x + s.grabOffset.x).clamp(-_carryX, _carryX),
      s.dragY,
      (hit.z + s.grabOffset.z).clamp(_carryBack, _carryFront),
    );
    if (what == _Held.beaker) {
      s.beaker = p;
    } else {
      s.pots[s.heldPot].pos = p;
    }
  }

  void _dragEnd(DragEndDetails _) => _release(cancelled: false);

  void _dragCancel() => _release(cancelled: true);

  /// HTML `pointerup` + `checkDrop()`, on the right target only.
  void _release({required bool cancelled}) {
    final s = _sim;
    final what = s.held;
    if (what == null) return;
    final index = s.heldPot;
    setState(() {
      s
        ..held = null
        ..heldPot = -1;
    });
    if (what == _Held.beaker) {
      _dropBeaker(cancelled);
    } else {
      _dropCap(index, cancelled);
    }
  }

  /// The beaker released: it pours into the container under it if that is
  /// the step's container, otherwise it slides back with a hint.
  void _dropBeaker(bool cancelled) {
    final s = _sim;
    if (cancelled) {
      _refuse(_Held.beaker, -1, null);
      return;
    }
    final b = s.beaker;
    if (s.scenario == 0) {
      final cap = s.pots[0], plate = s.pots[1];
      if (s.step == 1) {
        if (b.flatTo(cap.pos) < _capCatch) {
          _pour(0);
        } else {
          _refuse(_Held.beaker, -1, 'toast_need_cap');
        }
        return;
      }
      final overPlate =
          (b.x - plate.pos.x).abs() < _plateCatch &&
          (b.z - plate.pos.z).abs() < _plateCatch;
      if (overPlate) {
        _pour(1);
      } else {
        _refuse(_Held.beaker, -1, 'toast_need_plate');
      }
      return;
    }
    var target = -1;
    for (var i = 0; i < s.pots.length; i++) {
      final d = b.flatTo(s.pots[i].pos);
      if (d < _capCatch && (target < 0 || d < b.flatTo(s.pots[target].pos))) {
        target = i;
      }
    }
    if (target < 0) {
      _refuse(_Held.beaker, -1, 'toast_need_caps');
    } else if (s.pots[target].filled) {
      _refuse(_Held.beaker, -1, 'toast_cap_full');
    } else {
      _pour(target);
    }
  }

  /// A cap released (Scenario 2): it goes into the step's area only when
  /// dropped on that area's patch.
  void _dropCap(int index, bool cancelled) {
    final s = _sim;
    if (cancelled) {
      _refuse(_Held.pot, index, null);
      return;
    }
    final pos = s.pots[index].pos;
    final sun = s.step == 1;
    if (pos.flatTo(sun ? _sunSpot : _shadeSpot) < _patchR) {
      _placeCap(index, sun ? _Zone.sun : _Zone.shade);
    } else {
      _refuse(_Held.pot, index, sun ? 'toast_need_sun' : 'toast_need_shade');
    }
  }

  // ------------------------------------------------------------------- UI

  /// The HTML HUD buttons for the current state: 'Start Time-Lapse' on its
  /// step, 'Finish Observation' once all the water has evaporated (it also
  /// re-opens the summary later).
  List<LabAction> _actions() {
    final s = _sim;
    if (!s.lapseOn && s.step == s.lapseStep) {
      return [
        LabAction(
          label: _t('btn_lapse'),
          icon: Icons.play_circle_fill,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          enabled: !s.busy,
          highlight: !s.busy,
          onTap: _startLapse,
        ),
      ];
    }
    if (s.lapseDone) {
      return [
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.task_alt,
          color: _Colors.emerald600,
          foreground: _Colors.white,
          highlight: _lab.popup == null,
          // The summary popup plays the success tone (HTML 'ding').
          silent: true,
          onTap: _finish,
        ),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final sim = _sim;
        final data = _data;
        return LabShell(
          controller: _lab,
          // HTML curtain icon: `ph-wind`.
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sim.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sim.step,
          hud: _hud,
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepsAccordion(
                key: ValueKey('steps-${sim.scenario}-${sim.step}'),
                steps: data.steps,
                current: sim.step,
                palette: p,
                scale: s,
                fontScale: s * _lab.fontScale,
                stepLabel: _t('exploration'),
                conceptLabel: _t('concept_focus'),
                actionLabel: _t('action'),
                observationLabel: _t('observation'),
                pendingText: _t('obs_pending'),
              ),
              SizedBox(height: 8 * s),
              LabSectionLabel(
                _t('timers_title'),
                size: 10.5 * s,
                icon: Icons.timer,
              ),
              SizedBox(height: 8 * s),
              _results(p, s * _lab.fontScale),
            ],
          ),
          stage: _buildStage(),
        );
      },
    );
  }

  /// The time-lapse results in the sidebar: how long each
  /// container took to dry, once it has.
  Widget _results(LabPalette p, double scale) {
    final s = _sim;
    final _Pot? first;
    final _Pot? second;
    final List<String> names;
    if (s.scenario == 0) {
      first = s.pots[1];
      second = s.pots[0];
      names = [_t('lbl_plate'), _t('lbl_cap')];
    } else {
      first = s.potIn(_Zone.sun);
      second = s.potIn(_Zone.shade);
      names = [_t('row_sun'), _t('row_shade')];
    }
    String value(_Pot? pot) {
      if (!s.lapseOn || pot == null) return _t('status_wait');
      if (!pot.dry) return _t('status_run');
      return '${_clock(pot.minutes)} ${_t('unit_h')}';
    }

    return _ResultsTable(
      palette: p,
      scale: scale,
      hint: _t('timers_hint'),
      header: (_t('col_container'), _t('col_time')),
      rows: [
        (names[0], value(first), first?.dry ?? false),
        (names[1], value(second), second?.dry ?? false),
      ],
    );
  }

  /// Where the base projection goes on the stage: the scenario's content
  /// box fits into the part of the canvas left free by the toast row, the
  /// HUD chip, the tool column and (sidebar collapsed) the floating mission
  /// card, beside it or (phones) below it, whichever gives the bigger view.
  _Frame _frameFor(BuildContext context, Size canvas, double fit) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final s = context.labScale;
    final content = _content[_sim.scenario];
    final stage = Offset(
      (canvas.width - _design.width * fit) / 2,
      (canvas.height - _design.height * fit) / 2,
    );
    final right = canvas.width - _toolColumn - pad.right;
    final top = _toastTop + pad.top + _toastBand * s;
    final bottom =
        canvas.height -
        pad.bottom -
        _edge -
        (_lab.isSidebarOpen ? _hudBand * s : 0);
    final regions = <Rect>[
      if (_lab.isSidebarOpen)
        Rect.fromLTRB(_edge, top, right, bottom)
      else ...[
        Rect.fromLTRB(
          _missionLeft + pad.left + _missionCardWidth(size, s) + _edge,
          top,
          right,
          bottom,
        ),
        if (size.height < _compactBelow)
          Rect.fromLTRB(
            _edge,
            math.max(
              top,
              _missionTop + pad.top + size.height * _missionMaxHeight + _edge,
            ),
            right,
            bottom,
          ),
      ],
    ];
    final room = _labelRoom[_sim.scenario];
    _Frame? best;
    for (final r in regions) {
      final d = Rect.fromLTRB(
        (r.left - stage.dx) / fit,
        (r.top - stage.dy) / fit,
        (r.right - stage.dx) / fit,
        (r.bottom - stage.dy) / fit,
      ).intersect(Offset.zero & _design);
      if (d.width <= 0 || d.height <= 0) continue;
      // The labels grow as the view shrinks: settle the zoom and the room
      // the labels need together, starting from the largest view.
      var zoom = _maxZoom;
      var box = content;
      for (var i = 0; i < _frameIterations; i++) {
        final size = _labelPx * _labelBoost(fit * zoom);
        box = Rect.fromLTRB(
          content.left - room.left * size,
          content.top - room.top * size,
          content.right + room.right * size,
          content.bottom + room.bottom * size,
        );
        zoom = math
            .min(d.width / box.width, d.height / box.height)
            .clamp(_minZoom, _maxZoom);
      }
      if (best == null || zoom > best.zoom) {
        best = _Frame(zoom, d.center - box.center * zoom);
      }
    }
    return best ?? _Frame.identity;
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _fit = fit;
          _sim.setFrameTarget(_frameFor(context, box.biggest, fit));
          final boost = _labelBoost(fit * _sim.frameTarget.zoom);
          _labelSize = _labelPx * boost;
          _timerSize = _timerPx * boost;
        }
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags on the scene are not screen-reader actions; the scene is
            // announced by its label instead.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      // Small slop: a short drag grabs the object before the
                      // zoom viewer claims it (RawGestureDetector ignores
                      // MediaQuery's gesture settings).
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _touchSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _dragStart
                      ..onUpdate = _dragUpdate
                      ..onEnd = _dragEnd
                      ..onCancel = _dragCancel,
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
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    labelSize: _labelSize,
                    timerSize: _timerSize,
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

/// A timer reading in time-lapse minutes as the HTML shows it: "04:30"
/// (here hours : minutes).
String _clock(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Time-lapse results: one row per container with the time its water took
/// to evaporate (or its state while the time-lapse runs).
class _ResultsTable extends StatelessWidget {
  const _ResultsTable({
    required this.palette,
    required this.scale,
    required this.hint,
    required this.header,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String hint;
  final (String, String) header;

  /// Name, value, and whether the water is gone (value highlighted).
  final List<(String, String, bool)> rows;

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
    Widget cell(String text, TextStyle style, {bool end = false}) => Text(
      text,
      style: style,
      textAlign: end ? TextAlign.end : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    Widget row(Widget a, Widget b, {Color? fill, bool divider = true}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: fill,
          border: divider ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: a),
            SizedBox(width: 6 * f),
            Expanded(flex: 2, child: b),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hint,
          style: TextStyle(
            color: p.textMuted,
            fontSize: 10.5 * f,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        SizedBox(height: 6 * f),
        Container(
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
                cell(header.$1, head),
                cell(header.$2, head, end: true),
                fill: p.cardBorder.withValues(alpha: 0.3),
                divider: false,
              ),
              for (final (name, value, done) in rows)
                row(
                  cell(name, body),
                  cell(
                    value,
                    done
                        ? body.copyWith(
                            color: p.textStrong,
                            fontWeight: FontWeight.w800,
                          )
                        : body.copyWith(color: p.textMuted),
                    end: true,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed. A step's result is
/// shown once the step is done (the HTML showed it before the learner had
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
    final future = i > w.current;
    final open = !future && _isOpen(i);
    // Future steps: dimmed, not openable.
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
                constraints: const BoxConstraints(minHeight: _minTouch),
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
                  _body(step.concept, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(past ? step.observation : w.pendingText, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Segments of a projected circle.
const int _ringSegments = 28;

/// A rect far larger than any canvas, in base px (scene background).
const Rect _bleed = Rect.fromLTRB(-4000, -4000, 5000, 5000);

/// Scenario 2's sun (HTML `sunGrp` at (-10, 13, -9.9), a disc of radius 3
/// with eight rays; it sat at the top edge of the view, so it is drawn a
/// little lower and further left to show above the sunny area).
const _V _sunCentre = _V(-14, 10.5, -9.9);
const double _sunR = 3;
const double _sunCoreR = 2.5;
const double _sunRayDist = 4.2;
const double _sunRayHalfW = 0.4;
const double _sunRayHalfL = 1.25;

/// The soft glow around the sun, in sun radii (added).
const double _sunGlow = 1.3;

/// HTML `treeGrp` at (12, 0, -8): trunk `CylinderGeometry(1.5, 2.5, 12)`
/// and four leaf spheres (centre offset, radius).
const _V _treeBase = _V(12, 0, -8);
const List<(_V, double)> _leaves = [
  (_V(0, 12, 0), 4.5),
  (_V(-3, 10, 1), 3.5),
  (_V(3, 11, -1), 3.5),
  (_V(0, 15, 0), 3),
];

/// HTML `createDashedLine(dividerPts, 0.8, 0.6, 0.15, 0x1e293b)`.
const List<_V> _dividerPts = [
  _V(0, 0.1, 10),
  _V(0, 0.1, -9.8),
  _V(0, 20, -9.8),
];
const double _dash = 0.8;
const double _dashGap = 0.6;
const double _dashThickness = 0.15;

/// Where the area labels sit (HTML: the sky planes' centres, 8 down).
const _V _sunLabelAt = _V(-10, 5, -10);
const _V _shadeLabelAt = _V(10, 5, -10);

/// Timers float this far above a container's centre; labels sit just in
/// front of a container (HTML: both at +3, on top of each other).
const double _capTimerUp = 3.3;
const double _plateTimerUp = 2.4;
const double _labelGapUp = 0.6;

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n) {
  final i = _ambient + _keyGain * math.max(0.0, n.dot(_keyDir));
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// One face of a unit box: outward normal and corners (signs of x, y, z).
@immutable
class _Face {
  const _Face(this.n, this.corners);

  final _V n;
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

/// Bounding box of the projected box of half sizes [hx], [hz] around [c],
/// from [y0] to [y1] above it (base px).
Rect _projBox(_V c, double hx, double y0, double y1, double hz) {
  var rect = Rect.zero;
  var first = true;
  for (final x in [-hx, hx]) {
    for (final y in [y0, y1]) {
      for (final z in [-hz, hz]) {
        final o = _proj.p(c + _V(x, y, z));
        final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
        rect = first ? r : rect.expandToInclude(r);
        first = false;
      }
    }
  }
  return rect;
}

/// Convex hull of [pts] (sorted in place) into [out] (monotone chain), so
/// a tilted beaker's outline needs no new lists per frame.
void _hullInto(List<Offset> pts, List<Offset> out) {
  out.clear();
  if (pts.length < 3) {
    out.addAll(pts);
    return;
  }
  pts.sort(
    (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
  );
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  for (final q in pts) {
    while (out.length >= 2 && cross(out[out.length - 2], out.last, q) <= 0) {
      out.removeLast();
    }
    out.add(q);
  }
  final lower = out.length + 1;
  for (var i = pts.length - 2; i >= 0; i--) {
    final q = pts[i];
    while (out.length >= lower &&
        cross(out[out.length - 2], out.last, q) <= 0) {
      out.removeLast();
    }
    out.add(q);
  }
  out.removeLast();
}

/// The static benches (Scenario 1 desk; Scenario 2 split bench with sky,
/// grass, sun and tree), recorded once per theme in base coordinates and
/// replayed every frame under the current framing.
class _Pictures {
  final Map<int, ui.Picture> _map = {};

  ui.Picture get(int scenario, bool dark) {
    final key = scenario * 2 + (dark ? 1 : 0);
    final cached = _map[key];
    if (cached != null) return cached;
    final recorder = ui.PictureRecorder();
    final d = _Draw()..canvas = Canvas(recorder);
    if (scenario == 0) {
      _paintBenchS1(d, dark);
    } else {
      _paintBenchS2(d, dark);
    }
    return _map[key] = recorder.endRecording();
  }

  void dispose() {
    for (final p in _map.values) {
      p.dispose();
    }
    _map.clear();
  }
}

/// Laid-out canvas text (labels, timer digits) reused across frames.
class _TextCache {
  final Map<String, TextPainter> _map = {};
  static const int _maxEntries = 96;

  /// Monospace digits for the timers (HTML 'Courier New').
  static const String mono = 'monospace';
  static const List<String> _monoFallback = ['Courier', 'Menlo'];

  /// Called before a frame is painted: drops the cache once it has grown
  /// (old sizes, languages). Never during a frame, because painters handed
  /// out earlier in the frame are still in use.
  void beginFrame() {
    if (_map.length >= _maxEntries) dispose();
  }

  TextPainter get(
    String text,
    double size, {
    Color color = _Colors.white,
    bool monospace = false,
    IconData? icon,
    Color? iconColor,
  }) {
    final key =
        '$text|${size.toStringAsFixed(1)}|${color.toARGB32()}|$monospace|'
        '${icon?.codePoint}';
    final cached = _map[key];
    if (cached != null) return cached;
    final style = TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w700,
      fontFamily: monospace ? mono : LabFont.active.family,
      fontFamilyFallback: monospace ? _monoFallback : LabFont.active.fallback,
      height: 1.2,
    );
    return _map[key] = TextPainter(
      text: TextSpan(
        style: style,
        children: [
          if (icon != null)
            TextSpan(
              text: String.fromCharCode(icon.codePoint),
              style: TextStyle(
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                color: iconColor ?? color,
                fontSize: size * 1.15,
              ),
            ),
          TextSpan(text: icon == null ? text : ' $text'),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void dispose() {
    for (final tp in _map.values) {
      tp.dispose();
    }
    _map.clear();
  }
}

/// Mesh drawing in the base projection with reused Paints, Paths and lists.
class _Draw {
  late Canvas canvas;

  final Paint fill = Paint();
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Thick butt-ended shading bands.
  final Paint band = Paint()..style = PaintingStyle.stroke;

  /// The pulsing highlight around the object to drag.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  /// Soft patches (sunlight, shadow, the sun's glow).
  final Paint soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Path path = Path();
  final Path outer = Path();
  final Path clip = Path();
  final List<Offset> _pts = [];
  final List<Offset> _hull = [];

  Offset p(_V w) => _proj.p(w);

  void fillPath(Color c) {
    fill
      ..shader = null
      ..color = c;
    canvas.drawPath(path, fill);
  }

  void strokePath(Color c, double width) {
    line
      ..color = c
      ..strokeWidth = width;
    canvas.drawPath(path, line);
  }

  /// [target] = closed polygon through [pts].
  static void polygon(Path target, List<Offset> pts) {
    target.reset();
    for (var i = 0; i < pts.length; i++) {
      final o = pts[i];
      if (i == 0) {
        target.moveTo(o.dx, o.dy);
      } else {
        target.lineTo(o.dx, o.dy);
      }
    }
    target.close();
  }

  /// The projected horizontal circle of radius [r] at [c], as an
  /// axis-aligned oval (front and back points give its height).
  Rect oval(_V c, double r) {
    final front = p(c + _V(0, 0, r));
    final back = p(c - _V(0, 0, r));
    final hw = r * _proj.scaleAt(c);
    final cx = p(c).dx;
    return Rect.fromLTRB(cx - hw, back.dy, cx + hw, front.dy);
  }

  /// [path] = projected ring of radius [r] around local [c] of [xf]
  /// (horizontal in the group's own space).
  void ring(_Xf xf, _V c, double r) {
    path.reset();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final o = p(xf(_V(c.x + r * math.cos(a), c.y, c.z + r * math.sin(a))));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    path.close();
  }

  /// Flat quad through four world points.
  void quad(_V a, _V b, _V c, _V e, Color color) {
    final pa = p(a), pb = p(b), pc = p(c), pe = p(e);
    path
      ..reset()
      ..moveTo(pa.dx, pa.dy)
      ..lineTo(pb.dx, pb.dy)
      ..lineTo(pc.dx, pc.dy)
      ..lineTo(pe.dx, pe.dy)
      ..close();
    fillPath(color);
  }

  /// Three.js BoxGeometry centred at [c]: visible faces, flat shaded, with
  /// light edges.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.n;
      final fc = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(_proj.eye - fc) <= 0) continue;
      path.reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        final o = p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
      fillPath(_lit(color, n));
      if (edge > 0) {
        strokePath(labShade(color, 0.3).withValues(alpha: edge), 1);
      }
    }
  }

  /// Side of an upright CylinderGeometry standing on [base] (radii at the
  /// bottom and top, height [h]): silhouette with a lit and a shaded band.
  void cylinderSide(_V base, double rBottom, double rTop, double h, Color c) {
    final b = oval(base, rBottom);
    final t = oval(base + _V(0, h, 0), rTop);
    path
      ..reset()
      ..moveTo(t.left, t.center.dy)
      ..lineTo(b.left, b.center.dy)
      ..arcTo(b, math.pi, -math.pi, false)
      ..lineTo(t.right, t.center.dy)
      ..arcTo(t, 0, -math.pi, false)
      ..close();
    fillPath(_lit(c, const _V(0, 0, 1)));
    canvas.save();
    canvas.clipPath(path);
    band
      ..strokeWidth = b.width * 0.18
      ..color = labShade(c, 0.2);
    canvas.drawLine(
      Offset(t.center.dx - t.width * 0.24, t.top),
      Offset(b.center.dx - b.width * 0.24, b.bottom),
      band,
    );
    band
      ..strokeWidth = b.width * 0.22
      ..color = labShade(c, -0.35);
    canvas.drawLine(
      Offset(t.center.dx + t.width * 0.38, t.top),
      Offset(b.center.dx + b.width * 0.38, b.bottom),
      band,
    );
    canvas.restore();
  }

  /// HTML `createBeaker()` under [xf]: clear glass (open cylinder r 2,
  /// 5 tall) holding [water] (0..1 of its 4-unit column). The water keeps
  /// a level surface when the beaker tilts to pour.
  void beaker(_Xf xf, double water) {
    _pts.clear();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final cx = _beakerR * math.cos(a), cz = _beakerR * math.sin(a);
      _pts
        ..add(p(xf(_V(cx, -_beakerHalfH, cz))))
        ..add(p(xf(_V(cx, _beakerHalfH, cz))));
    }
    _hullInto(_pts, _hull);
    polygon(outer, _hull);
    fill
      ..shader = null
      ..color = _Colors.glass.withValues(alpha: 0.13);
    canvas.drawPath(outer, fill);
    if (water > 0.004) {
      _pts.clear();
      const inner = _beakerHalfH - 0.1;
      for (var i = 0; i < _ringSegments; i++) {
        final a = i * 2 * math.pi / _ringSegments;
        final cx = _beakerWaterR * math.cos(a);
        final cz = _beakerWaterR * math.sin(a);
        _pts
          ..add(p(xf(_V(cx, -inner, cz))))
          ..add(p(xf(_V(cx, inner, cz))));
      }
      _hullInto(_pts, _hull);
      polygon(clip, _hull);
      // The water column's axis point at its height: a level plane through
      // it holds the same volume however the beaker tilts.
      final axis = xf(_V(0, _beakerWaterBottom + _beakerWaterH * water, 0));
      final level = p(axis).dy;
      canvas.save();
      canvas.clipPath(clip);
      fill.color = _Colors.water.withValues(alpha: 0.7);
      canvas.drawRect(
        Rect.fromLTRB(_bleed.left, level, _bleed.right, _bleed.bottom),
        fill,
      );
      // Level surface: the horizontal section of the (tilted) column.
      final stretch = 1 / math.cos(xf.rotZ).abs().clamp(0.35, 1.0);
      path.reset();
      for (var i = 0; i < _ringSegments; i++) {
        final a = i * 2 * math.pi / _ringSegments;
        final o = p(
          _V(
            axis.x + _beakerWaterR * stretch * math.cos(a),
            axis.y,
            axis.z + _beakerWaterR * math.sin(a),
          ),
        );
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
      fillPath(labShade(_Colors.water, 0.3).withValues(alpha: 0.8));
      canvas.restore();
    }
    line
      ..color = _Colors.glass.withValues(alpha: 0.6)
      ..strokeWidth = 1.4;
    canvas.drawPath(outer, line);
    ring(xf, const _V(0, _beakerHalfH, 0), _beakerR);
    strokePath(_Colors.glass.withValues(alpha: 0.85), 1.6);
    line
      ..color = _Colors.glass.withValues(alpha: 0.3)
      ..strokeWidth = 3;
    canvas.drawLine(
      p(xf(const _V(-_beakerR * 0.6, -_beakerHalfH + 0.4, _beakerR * 0.8))),
      p(xf(const _V(-_beakerR * 0.6, _beakerHalfH - 0.4, _beakerR * 0.8))),
      line,
    );
  }

  /// HTML `createBottleCap()` centred at [c]: red open cylinder with its
  /// floor; the water surface sits [level] (0..1) up its 0.4-unit depth.
  void cap(_V c, double level) {
    cylinderSide(
      c - const _V(0, _capH / 2, 0),
      _capR,
      _capR,
      _capH,
      _Colors.capRed,
    );
    final rim = oval(c + const _V(0, _capH / 2, 0), _capR);
    fill
      ..shader = null
      ..color = labShade(_Colors.capRed, -0.45);
    canvas.drawOval(rim, fill);
    clip
      ..reset()
      ..addOval(rim);
    canvas.save();
    canvas.clipPath(clip);
    fill.color = labShade(_Colors.capRed, -0.15);
    canvas.drawOval(oval(c + const _V(0, _capFloor, 0), _capR), fill);
    if (level > 0.003) {
      fill.color = _Colors.water.withValues(
        alpha: 0.85 * math.min(1.0, level * 6),
      );
      canvas.drawOval(
        oval(c + _V(0, _capFloor + _capWaterH * level, 0), _capWaterR),
        fill,
      );
    }
    canvas.restore();
    line
      ..color = labShade(_Colors.capRed, 0.35)
      ..strokeWidth = 1.2;
    canvas.drawOval(rim, line);
  }

  /// HTML `s1Plate`: steel box with its thin water layer (spreading out
  /// while poured, shrinking as it evaporates).
  void plate(_Pot pot) {
    box(
      pot.pos,
      const _V(_plateHalf * 2, _plateH, _plateHalf * 2),
      _Colors.steel,
      edge: 0.7,
    );
    if (!pot.filled || pot.level <= 0.003) return;
    final half = _plateWaterHalf * pot.spread * math.sqrt(pot.level);
    final y = pot.pos.y + _plateH / 2 + 0.01;
    // A rounded puddle (superellipse) rather than a hard square.
    path.reset();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final ca = math.cos(a), sa = math.sin(a);
      final x = half * ca.sign * math.sqrt(ca.abs());
      final z = half * sa.sign * math.sqrt(sa.abs());
      final o = p(_V(pot.pos.x + x, y, pot.pos.z + z));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    path.close();
    fillPath(_Colors.water.withValues(alpha: 0.7));
    strokePath(labShade(_Colors.water, 0.4).withValues(alpha: 0.8), 1);
  }

  /// The pulsing highlight around [r] (HTML emissive pulse, 0x818cf8).
  void halo(Rect r, double pulse) {
    glow.color = _Colors.highlight.withValues(alpha: 0.3 + 0.4 * pulse);
    canvas.drawOval(r.inflate(5 + 4 * pulse), glow);
  }
}

/// Scenario 1's bench: `BoxGeometry(40, 2, 20)` of wood at y -1, with a
/// faint grain.
void _paintBenchS1(_Draw d, bool dark) {
  d.fill
    ..shader = null
    ..color = dark ? _Colors.sceneDark : _Colors.sceneLight;
  d.canvas.drawRect(_bleed, d.fill);
  d.box(const _V(0, -1, 0), const _V(40, 2, 20), _Colors.wood, edge: 0.45);
  d.line
    ..strokeWidth = 1
    ..color = labShade(_Colors.wood, -0.35).withValues(alpha: 0.35);
  for (var z = -9.6; z < 10; z += 0.8) {
    final wobble = math.sin(z * 2.3) * 0.15;
    d.canvas.drawLine(
      d.p(_V(-19.8, 0.002, z)),
      d.p(_V(19.8, 0.002, z + wobble)),
      d.line,
    );
  }
}

/// Scenario 2's diorama: sky and grass backdrops, the sun, the split bench
/// (yellow sunny half, dark shady half), the sunlit patch and the tree's
/// shadow, the dashed divider and the tree.
void _paintBenchS2(_Draw d, bool dark) {
  d.fill
    ..shader = null
    ..color = dark ? _Colors.sceneDark : _Colors.sceneLight;
  d.canvas.drawRect(_bleed, d.fill);
  // Sky (20 x 14 planes at y 13) and grass (20 x 6 at y 3), z = -10.
  d.quad(
    const _V(-20, 6, -10),
    const _V(0, 6, -10),
    const _V(0, 20, -10),
    const _V(-20, 20, -10),
    _Colors.skySun,
  );
  d.quad(
    const _V(0, 6, -10),
    const _V(20, 6, -10),
    const _V(20, 20, -10),
    const _V(0, 20, -10),
    _Colors.skyShade,
  );
  d.quad(
    const _V(-20, 0, -10),
    const _V(0, 0, -10),
    const _V(0, 6, -10),
    const _V(-20, 6, -10),
    _Colors.grassSun,
  );
  d.quad(
    const _V(0, 0, -10),
    const _V(20, 0, -10),
    const _V(20, 6, -10),
    const _V(0, 6, -10),
    _Colors.grassShade,
  );
  _paintSun(d);
  d.box(const _V(-10, -1, 0), const _V(20, 2, 20), _Colors.deskSun, edge: 0.4);
  d.box(const _V(10, -1, 0), const _V(20, 2, 20), _Colors.deskShade, edge: 0.4);
  d.ring(const _Xf(_V.zero), const _V(-10, 0.01, 0), _patchR);
  d.soft.color = _Colors.sunPatch;
  d.canvas.drawPath(d.path, d.soft);
  d.ring(const _Xf(_V.zero), const _V(10, 0.01, 0), _patchR);
  d.soft.color = _Colors.shadePatch;
  d.canvas.drawPath(d.path, d.soft);
  _paintDivider(d);
  _paintTree(d);
}

/// The sun disc (outer #fde047 r 3, core #fab105 r 2.5) with eight rays.
/// It faces the viewer (a flat disc this far off-centre would project as a
/// skewed ellipse), sized by the perspective scale at its centre.
void _paintSun(_Draw d) {
  final c = d.p(_sunCentre);
  final k = _proj.scaleAt(_sunCentre);
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    final ca = math.cos(a), sa = math.sin(a);
    // HTML: a ray at local y 4.2 on a pivot turned by `rotation.z = a`.
    Offset at(double lx, double ly) =>
        c + Offset((lx * ca - ly * sa) * k, -(lx * sa + ly * ca) * k);
    _Draw.polygon(d.path, [
      at(-_sunRayHalfW, _sunRayDist - _sunRayHalfL),
      at(_sunRayHalfW, _sunRayDist - _sunRayHalfL),
      at(_sunRayHalfW, _sunRayDist + _sunRayHalfL),
      at(-_sunRayHalfW, _sunRayDist + _sunRayHalfL),
    ]);
    d.fillPath(_Colors.sunOuter);
  }
  d.soft.color = _Colors.sunOuter.withValues(alpha: 0.6);
  d.canvas.drawCircle(c, _sunR * _sunGlow * k, d.soft);
  d.fill
    ..shader = null
    ..color = _Colors.sunOuter;
  d.canvas.drawCircle(c, _sunR * k, d.fill);
  d.fill.color = _Colors.sunCore;
  d.canvas.drawCircle(c, _sunCoreR * k, d.fill);
}

/// The dashed divider along the bench's middle and up the backdrop.
void _paintDivider(_Draw d) {
  d.line.color = _Colors.divider;
  for (var i = 0; i + 1 < _dividerPts.length; i++) {
    final a = _dividerPts[i], b = _dividerPts[i + 1];
    final len = (b - a).length;
    final dir = (b - a) * (1 / len);
    for (var at = 0.0; at < len; at += _dash + _dashGap) {
      final s = a + dir * at;
      final e = a + dir * math.min(at + _dash, len);
      d.line.strokeWidth = math.max(
        1.2,
        _dashThickness * _proj.scaleAt(_V.lerp(s, e, 0.5)),
      );
      d.canvas.drawLine(d.p(s), d.p(e), d.line);
    }
  }
}

/// The tree: brown trunk and four shaded leaf spheres, far to near.
void _paintTree(_Draw d) {
  d.cylinderSide(_treeBase, 2.5, 1.5, 12, _Colors.trunk);
  final order = [..._leaves]
    ..sort(
      (a, b) => _proj
          .depth(_treeBase + b.$1)
          .compareTo(_proj.depth(_treeBase + a.$1)),
    );
  for (final (offset, r) in order) {
    final w = _treeBase + offset;
    final c = d.p(w);
    final radius = r * _proj.scaleAt(w);
    d.fill.shader = ui.Gradient.radial(
      c + Offset(-0.35 * radius, -0.4 * radius),
      radius * 1.4,
      [
        labShade(_Colors.leaves, 0.25),
        _Colors.leaves,
        labShade(_Colors.leaves, -0.45),
      ],
      const [0, 0.5, 1],
    );
    d.canvas.drawCircle(c, radius, d.fill);
    d.fill.shader = null;
  }
}

/// Paints the HTML's two Three.js scenes under the current framing: the
/// bench, the containers and the beaker (far to near), the pouring stream,
/// the vapour, the labels and the time-lapse timers.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.sim,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.timerSize,
  }) : super(repaint: repaint);

  final _Sim sim;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  /// Label and timer text sizes in base px.
  final double labelSize;
  final double timerSize;

  static final Paint _chipFill = Paint();
  static final Paint _chipBorder = Paint()..style = PaintingStyle.stroke;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = sim;
    final d = s.draw..canvas = canvas;
    final f = s.frame;
    s.text.beginFrame();
    canvas.save();
    canvas.translate(f.offset.dx, f.offset.dy);
    canvas.scale(f.zoom);
    canvas.drawPicture(s.pictures.get(s.scenario, isDark));
    _paintObjects(d);
    _paintStream(d);
    _paintVapour(d);
    if (showLabels) _paintLabels(d);
    if (s.lapseOn) _paintTimers(d);
    canvas.restore();
  }

  /// The object(s) the current step asks the learner to drag pulse.
  bool get _beakerHot {
    final s = sim;
    if (s.busy || s.held != null || s.finished) return false;
    return s.scenario == 0 ? s.step <= 2 : s.step == 3;
  }

  bool _potHot(int i) {
    final s = sim;
    return s.scenario == 1 &&
        !s.busy &&
        s.held == null &&
        s.step <= 2 &&
        s.pots[i].zone == _Zone.none;
  }

  void _paintObjects(_Draw d) {
    final s = sim;
    final pulse = (math.sin(s.time * _pulseRate) + 1) / 2;
    // -1 is the beaker; far to near.
    final order = [for (var i = 0; i < s.pots.length; i++) i, -1]
      ..sort((a, b) {
        double depth(int i) =>
            _proj.depth(i < 0 ? s.beakerDrawn : s.potDrawn(i));
        return depth(b).compareTo(depth(a));
      });
    for (final i in order) {
      if (i < 0) {
        final b = s.beakerDrawn;
        if (_beakerHot) {
          d.halo(
            _projBox(b, _beakerR, -_beakerHalfH, _beakerHalfH, _beakerR),
            pulse,
          );
        }
        d.beaker(_Xf(b, s.tilt), s.beakerWater);
        continue;
      }
      final pot = s.pots[i];
      final at = s.potDrawn(i);
      if (_potHot(i)) {
        d.halo(_projBox(at, _capR, -_capH / 2, _capH / 2, _capR), pulse);
      }
      if (pot.isCap) {
        d.cap(at, pot.filled ? pot.level : 0);
      } else {
        d.plate(pot);
      }
    }
  }

  /// HTML `emitPourParticle`: drops (spheres r 0.2 scaled 0.5 x 1.5) fall
  /// from the lip with Quadratic.In.
  void _paintStream(_Draw d) {
    final s = sim;
    d.fill
      ..shader = null
      ..color = _Colors.water.withValues(alpha: 0.75);
    for (final drop in s.drops) {
      if (!drop.on) continue;
      final t = ((s.time - drop.t0) / _dropFall).clamp(0.0, 1.0);
      final w = _V(drop.x, drop.y0 + (drop.y1 - drop.y0) * t * t, drop.z);
      final k = _proj.scaleAt(w);
      d.canvas.drawOval(
        Rect.fromCenter(center: d.p(w), width: 0.2 * k, height: 0.6 * k),
        d.fill,
      );
    }
  }

  /// HTML `emitParticle`: white vapour rising and fading.
  void _paintVapour(_Draw d) {
    final s = sim;
    for (final puff in s.puffs) {
      if (!puff.on) continue;
      final age = s.time - puff.t0;
      final a = _puffAlpha * (1 - age / puff.fade).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final w = _V(
        puff.x,
        puff.y0 + puff.rise * math.min(1.0, age / puff.travel),
        puff.z,
      );
      final c = d.p(w);
      final r = math.max(1.2, _puffRadius * _proj.scaleAt(w));
      d.fill
        ..shader = null
        ..color = _Colors.vapour.withValues(alpha: a);
      d.canvas.drawCircle(c, r, d.fill);
      d.line
        ..color = _Colors.vapourRim.withValues(alpha: a * 0.5)
        ..strokeWidth = 0.6;
      d.canvas.drawCircle(c, r, d.line);
    }
  }

  /// HTML `createLabel`: beaker, cap and plate (S1); beaker and the two
  /// areas (S2). The beaker's label shows while it stands at its place (the
  /// HTML label followed it while held and pouring, where it ran into the
  /// other labels on phones).
  void _paintLabels(_Draw d) {
    final s = sim;
    if (s.beakerAtHome) {
      _label(
        d,
        _t('lbl_beaker'),
        d.p(s.beaker + const _V(0, _beakerHalfH + _labelGapUp, 0)),
        Alignment.bottomCenter,
      );
    }
    if (s.scenario == 0) {
      final cap = s.pots[0], plate = s.pots[1];
      _label(
        d,
        _t('lbl_cap'),
        d.p(cap.pos + const _V(0, -_capH / 2, _capR + _labelGapUp)),
        Alignment.topCenter,
      );
      _label(
        d,
        _t('lbl_plate'),
        d.p(plate.pos + const _V(0, -_plateH / 2, _plateHalf + _labelGapUp)),
        Alignment.topCenter,
      );
      return;
    }
    _label(
      d,
      _t('lbl_sun'),
      d.p(_sunLabelAt),
      Alignment.center,
      icon: Icons.wb_sunny,
      iconColor: _Colors.yellow500,
    );
    _label(
      d,
      _t('lbl_shade'),
      d.p(_shadeLabelAt),
      Alignment.center,
      icon: Icons.park,
      iconColor: _Colors.emerald500,
    );
  }

  /// HTML `.label-3d` chip: dark glass, indigo border, white text; [anchor]
  /// picks which point of the chip sits on [at].
  void _label(
    _Draw d,
    String text,
    Offset at,
    Alignment anchor, {
    IconData? icon,
    Color? iconColor,
  }) {
    final tp = sim.text.get(text, labelSize, icon: icon, iconColor: iconColor);
    final padH = labelSize * 0.6, padV = labelSize * 0.3;
    final w = tp.width + 2 * padH, h = tp.height + 2 * padV;
    final left = at.dx - (anchor.x + 1) / 2 * w;
    final top = at.dy - (anchor.y + 1) / 2 * h;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      Radius.circular(h * 0.35),
    );
    _chipFill.color = _Colors.labelBg;
    _chipBorder
      ..color = _Colors.indigo400
      ..strokeWidth = 1.2;
    d.canvas
      ..drawRRect(rr, _chipFill)
      ..drawRRect(rr, _chipBorder);
    tp.paint(d.canvas, Offset(left + padH, top + padV));
  }

  /// HTML `.timer-3d`: black chip, indigo border, green monospace digits
  /// that turn orange once the container's water has gone.
  void _paintTimers(_Draw d) {
    final s = sim;
    for (final pot in s.pots) {
      if (pot.lapse == null) continue;
      final up = pot.isCap ? _capTimerUp : _plateTimerUp;
      _timer(d, d.p(pot.pos + _V(0, up, 0)), pot);
    }
  }

  void _timer(_Draw d, Offset at, _Pot pot) {
    final text = sim.text;
    final digits = _clock(pot.minutes);
    final color = pot.dry ? _Colors.orange400 : _Colors.green400;
    final zero = text.get('0', timerSize, color: color, monospace: true);
    final advance = zero.width;
    final unit = text.get(_t('unit_h'), timerSize * 0.62, color: color);
    final padX = timerSize * 0.5, padY = timerSize * 0.2, gap = timerSize * 0.3;
    final w = advance * digits.length + gap + unit.width + 2 * padX;
    final h = zero.height + 2 * padY;
    final rect = Rect.fromLTWH(at.dx - w / 2, at.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(h * 0.25));
    _chipFill.color = _Colors.timerBg;
    _chipBorder
      ..color = _Colors.indigo500
      ..strokeWidth = 2;
    d.canvas
      ..drawRRect(rr, _chipFill)
      ..drawRRect(rr, _chipBorder);
    var x = rect.left + padX;
    for (var i = 0; i < digits.length; i++) {
      final tp = text.get(digits[i], timerSize, color: color, monospace: true);
      tp.paint(d.canvas, Offset(x + (advance - tp.width) / 2, rect.top + padY));
      x += advance;
    }
    unit.paint(
      d.canvas,
      Offset(x + gap, rect.top + padY + (zero.height - unit.height) * 0.75),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.sim != sim ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.timerSize != timerSize;
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
