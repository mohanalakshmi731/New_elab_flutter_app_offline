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

/// Class 6 Science • Chapter 8 • Activity 1
/// States of Water and their Properties.
///
/// Native Flutter port of
/// `Cl6S-Ch8-A1-States_of_Water_and_their_Properties.html` (Three.js r128).
/// The Three.js scene is redrawn by a painter that reproduces the HTML
/// camera (position (0, 20, 40), look-at (0, 4, 0), 45° field of view).
///
/// Scenario 1 (The Shape-Shifter): the ice cube keeps its square shape in a
/// square container, a round container and a glass tumbler; a time-lapse
/// slider melts it, and the water takes the shape of the square and then of
/// the round container it is poured into.
///
/// Scenario 2 (The Appearing Act): a glass tumbler on a digital balance is
/// tared, filled with water and ice and its water level is marked; after a
/// 30-minute time-lapse drops cover the outside, the level inside has not
/// dropped but the mass has gone up: the water came from the air.
class Ch8A1StatesOfWaterAndTheirPropertiesPage extends StatefulWidget {
  const Ch8A1StatesOfWaterAndTheirPropertiesPage({super.key});

  @override
  State<Ch8A1StatesOfWaterAndTheirPropertiesPage> createState() =>
      _StatesOfWaterLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three tones with the Web Audio
/// API; each is played with the closest bundled file: `click` (an object
/// picked up, TARE, Finish Observation) -> click.mp3, `pop` (an object
/// snapping back, Enter Lab, scenario change) -> pop.mp3 and `success` (a
/// correct drop) -> correct.mp3; the summary plays success.mp3. Pouring
/// plays drop.mp3 (the HTML is silent there).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, drop → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`: an object picked up, TARE, Finish Observation.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML `success` on a correct drop; positive toasts.
  correct('audio/class6/science/correct.mp3'),

  /// A wrong or missed drop, an object touched before its turn.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: an object let go away from its target snaps back.
  pop('audio/class6/science/pop.mp3'),

  /// Water (or ice) poured into a container.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // headings, accents
  static const Color blue600 = Color(0xFF2563EB); // TARE, Next buttons
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color sky200 = Color(0xFFBAE6FD);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9); // tailwind `water`
  static const Color emerald500 = Color(0xFF10B981); // Finish Observation
  static const Color emerald600 = Color(0xFF059669);
  static const Color green400 = Color(0xFF4ADE80); // balance digits
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color zslYellow = Color(0xFFEAB308); // slider sun icon
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // tailwind `zsl.dark`
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a, 0xf8fafc in the light theme.
  static const Color sceneBg = slate900;
  static const Color sceneBgLight = slate50;

  /// `materials.wood` (0xc28e5c): the desks.
  static const Color wood = Color(0xFFC28E5C);

  /// `materials.glass`: white, opacity 0.25, edges 0x94a3b8 at 0.5.
  static const Color glass = white;
  static const Color glassEdge = slate400;

  /// The tumbler's glass once ice has cooled it (added: the HTML only set
  /// a roughness its Phong material ignores).
  static const Color frost = sky200;

  /// `materials.water` (0x0ea5e9, opacity 0.75) and the droplets.
  static const Color water = sky500;

  /// `materials.ice`: white, opacity 0.85 (edges: see `_iceEdge`).
  static const Color ice = white;
  static const Color iceEdge = slate300;

  /// Digital balance: `materials.plastic` 0xcbd5e1, pad 0xe2e8f0, screen
  /// 0x000000.
  static const Color plastic = slate300;
  static const Color pad = slate200;
  static const Color screen = black;

  /// `materials.tray` 0x1e3a8a.
  static const Color tray = blue900;

  /// Marker pen: body 0xffffff, cap and line 0x3b82f6. The line gets a
  /// dark edge (added) so it stands out against the blue water.
  static const Color markerBody = white;
  static const Color markerCap = blue500;
  static const Color markerLine = blue500;
  static const Color markerEdge = blue900;

  /// Pulsing highlight of the object to drag (emissive 0x38bdf8).
  static const Color highlight = sky400;

  /// `.label-3d` chips: glass panel, `border-blue-400`, tag icon
  /// `text-blue-500`.
  static const Color labelBg = Color(0xEB0F172A); // rgba(15, 23, 42, 0.92)
  static const Color labelBgLight = Color(0xF2FFFFFF); // rgba(255,255,255,.95)
  static const Color labelBorder = blue400;
  static const Color labelIcon = blue500;
  static const Color labelText = white;
  static const Color labelTextLight = slate800;

  /// `#scale-overlay`: `bg-black/80`, `border-slate-700`, green digits,
  /// `text-slate-400` unit.
  static const Color readoutBg = Color(0xCC000000);
  static const Color readoutBorder = slate700;
  static const Color readoutDigits = green400;
  static const Color readoutUnit = slate400;

  /// Soft contact shadows on the desk.
  static const Color shadow = Color(0x59000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950, // #canvas-wrapper bg-[#020617]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300, // text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x803B82F6),
    readoutBg: _Colors.slate950,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
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
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x803B82F6),
    readoutBg: _Colors.slate950,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
    labelText: _Colors.slate800,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Changes
// from the HTML (see the report): each step's action says exactly what to
// drag, tap or slide; "Click" is "Tap"; the Hindi title translates the
// English one (the HTML repeated the chapter name) and the Hindi texts lose
// their English words in brackets ("(DRAG)", "TARE"); the HUD line of S1
// step 4 no longer says "below" (the slider card is at the top of the
// canvas) and the one of S2 step 6 names the water outside (the drops) and
// the button's full label. Keys marked "added" are texts the HTML did not
// have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'States of Water and their Properties',
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt': 'Scenario 1: The Shape-Shifter',
    'scen_2_opt': 'Scenario 2: The Appearing Act',
    's1_desc':
        'Investigate and compare the properties of water in its solid (ice) and liquid states, specifically focusing on shape.',
    's2_desc':
        "Investigate where water droplets on a cold glass come from, proving it's condensation from the air, not seepage.",
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Solid Shape (Square)',
    'step_1_1_a': 'Drag the ice cube into the square container.',
    'step_1_1_o': 'Ice retains its fixed square shape.',
    'step_1_2_c': 'Solid Shape (Round)',
    'step_1_2_a': 'Drag the ice cube into the round container.',
    'step_1_2_o': 'Ice does not change shape; it remains square.',
    'step_1_3_c': 'Prepare for Melting',
    'step_1_3_a': 'Drag the ice cube into the glass tumbler.',
    'step_1_3_o': 'Ice is ready for temperature change.',
    'step_1_4_c': 'Phase Change (Melting)',
    'step_1_4_a':
        "Drag the 'Melt Ice' time-lapse slider all the way to the end to melt the ice.",
    'step_1_4_o': 'Solid ice melts into liquid water.',
    'step_1_5_c': 'Liquid Shape (Square)',
    'step_1_5_a':
        'Drag the glass tumbler over the square container and let go to pour the water into it.',
    'step_1_5_o': 'Water flows and takes the square shape.',
    'step_1_6_c': 'Liquid Shape (Round)',
    'step_1_6_a':
        'Drag the square container over the round container and let go to pour the water into it.',
    'step_1_6_o': 'Water flows and takes the round shape.',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Setup Balance',
    'step_2_1_a':
        "Drag the glass tumbler onto the digital balance, then tap 'TARE to 0.00 g'.",
    'step_2_1_o': 'Scale reads 0.00 g with empty tumbler.',
    'step_2_2_c': 'Add Liquid Mass',
    'step_2_2_a':
        'Drag the water pitcher over the glass tumbler and let go to pour water into it.',
    'step_2_2_o': 'Mass increases to a stable value.',
    'step_2_3_c': 'Cool the System',
    'step_2_3_a':
        'Drag the tray of ice cubes over the glass tumbler and let go to drop the ice into the water.',
    'step_2_3_o': 'Mass increases further. Glass gets cold.',
    'step_2_4_c': 'Control Variable',
    'step_2_4_a':
        'Drag the marker pen to the glass tumbler and let go to draw a line at the water level.',
    'step_2_4_o': 'A permanent line marks the current volume.',
    'step_2_5_c': 'Condensation',
    'step_2_5_a':
        "Drag the 'Wait 30 Mins' time-lapse slider to the end, and watch the balance and the outside of the glass.",
    'step_2_5_o': 'Droplets form outside. Mass slowly increases!',
    'step_2_6_c': 'Final Analysis',
    'step_2_6_a':
        "Compare the water level inside with the marker line and read the balance, then tap 'Finish Observation'.",
    'step_2_6_o':
        "Internal level didn't drop, but mass went up. Water came from the air!",
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1': 'Step 1: DRAG the square ice cube into the square container.',
    's1_hud_2': 'Step 2: DRAG the ice cube into the round container.',
    's1_hud_3': 'Step 3: DRAG the ice cube into the glass tumbler.',
    's1_hud_4': 'Step 4: Use the time-lapse SLIDER to melt the ice.',
    's1_hud_5':
        'Step 5: DRAG the tumbler to pour water into the square container.',
    's1_hud_6':
        'Step 6: DRAG the square container to pour water into the round container.',
    's1_hud_7': 'Observation Complete! View Summary.',
    's2_hud_1':
        'Step 1: DRAG the glass tumbler to the digital balance. Tap TARE.',
    's2_hud_2':
        'Step 2: DRAG the water pitcher to pour water into the tumbler.',
    's2_hud_3':
        'Step 3: DRAG the ice cubes into the tumbler to cool the water.',
    's2_hud_4':
        'Step 4: DRAG the marker pen to draw a line at the water level.',
    's2_hud_5':
        'Step 5: Use the time SLIDER to wait 30 minutes. Watch the mass and glass.',
    's2_hud_6':
        "Step 6: Observe the final water level inside vs the water outside. Tap 'Finish Observation'.",
    's2_hud_7': 'Observation Complete! View Summary.',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'Complete this step to see the result.',
    // ---------------------------------------------------- buttons, slider
    'btn_tare': 'TARE to 0.00 g',
    'btn_finish': 'Finish Observation',
    'slider_start': 'Start',
    'slider_end': 'End',
    'melt_ice': 'Melt Ice',
    'wait_30_mins': 'Wait 30 Mins',
    // Added: minutes passed on the 30-minute time-lapse.
    'minutes': '{n} min',
    // ------------------------------------------------------------- toasts
    'toast_tare': 'Balance set to 0.00 g',
    'toast_marker': 'Water level marked!',
    // ------------------------------------------------------------ summary
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    's1_sum_head': 'Solids vs Liquids!',
    's1_summary':
        'You proved that Solids (Ice) have a fixed shape, regardless of where they are placed. However, Liquids (Water) have no fixed shape and always take the shape of their container!',
    's2_sum_head': 'Condensation Confirmed!',
    's2_summary':
        "The water level inside did not drop, proving water didn't leak out. The increase in mass proves that invisible water vapour from the air turned into liquid drops when it hit the cold glass!",
    // ------------------------------------------------------ scene labels
    'lbl_ice_cube': 'Ice Cube',
    // Added (the HTML labelled the tray of three cubes 'Ice Cube').
    'lbl_ice_cubes': 'Ice Cubes',
    'lbl_sq_container': 'Square Container',
    'lbl_rnd_container': 'Round Container',
    'lbl_tumbler': 'Glass Tumbler',
    'lbl_pitcher': 'Water Pitcher',
    'lbl_balance': 'Digital Balance',
    'lbl_marker': 'Marker Pen',
    'lbl_shape_fixed': 'Shape: Fixed',
    'lbl_shape_takes': 'Shape: Takes shape of container',
    'lbl_state_solid': 'State: Solid (Ice)',
    'lbl_state_liquid': 'State: Liquid (Water)',
    'unit_g': 'g',
    // ---------------------------------------------------- toasts (added)
    'first_1_1': 'First drag the ice cube into the square container.',
    'first_1_2': 'First drag the ice cube into the round container.',
    'first_1_3': 'First drag the ice cube into the glass tumbler.',
    'first_1_4': 'First melt the ice with the time-lapse slider.',
    'first_1_5':
        'First pour the water from the tumbler into the square container.',
    'first_1_6':
        'First pour the water from the square container into the round container.',
    'first_2_1': 'First put the glass tumbler on the digital balance.',
    'first_2_1b': "First tap 'TARE to 0.00 g'.",
    'first_2_2': 'First pour water into the tumbler with the water pitcher.',
    'first_2_3': 'First drop the ice cubes into the tumbler.',
    'first_2_4': 'First mark the water level with the marker pen.',
    'first_2_5': 'First move the time-lapse slider to the end.',
    'first_2_6': "Tap 'Finish Observation'.",
    'wrong_1_1':
        'That is not the square container! Drag the ice cube into the square container.',
    'wrong_1_2':
        'That is not the round container! Drag the ice cube into the round container.',
    'wrong_1_3':
        'That is not the glass tumbler! Drag the ice cube into the glass tumbler.',
    'wrong_1_5':
        'That is not the square container! Pour the water into the square container.',
    'wrong_1_6':
        'That is not the round container! Pour the water into the round container.',
    'miss_1_1': 'Let go of the ice cube right over the square container.',
    'miss_1_2': 'Let go of the ice cube right over the round container.',
    'miss_1_3': 'Let go of the ice cube right over the glass tumbler.',
    'miss_1_5': 'Let go of the tumbler right over the square container.',
    'miss_1_6':
        'Let go of the square container right over the round container.',
    'miss_2_1': 'Put the glass tumbler on the pan of the digital balance.',
    'miss_2_2': 'Let go of the water pitcher right over the glass tumbler.',
    'miss_2_3': 'Let go of the ice cubes right over the glass tumbler.',
    'miss_2_4': 'Let go of the marker pen right at the glass tumbler.',
    'scene_s1':
        'Desk with an ice cube, a square container, a round container and a glass tumbler.',
    'scene_s2':
        'Desk with a digital balance, a glass tumbler, a water pitcher, a tray of ice cubes and a marker pen.',
  },
  'hi': {
    'app_title': 'पानी की अवस्थाएँ और उनके गुण',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: रूप-परिवर्तक',
    'scen_2_opt': 'परिदृश्य 2: प्रकट होने का कार्य',
    's1_desc':
        'पानी की ठोस (बर्फ) और तरल अवस्थाओं के गुणों की जाँच और तुलना करें, विशेष रूप से उनके आकार पर ध्यान देते हुए।',
    's2_desc':
        'जाँच करें कि ठंडे गिलास पर पानी की बूँदें कहाँ से आती हैं, और साबित करें कि यह हवा से संघनन है, रिसाव नहीं।',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'ठोस आकार (चौकोर)',
    'step_1_1_a': 'बर्फ के टुकड़े को खींचकर चौकोर कंटेनर में डालें।',
    'step_1_1_o': 'बर्फ अपना निश्चित चौकोर आकार बनाए रखती है।',
    'step_1_2_c': 'ठोस आकार (गोल)',
    'step_1_2_a': 'बर्फ के टुकड़े को खींचकर गोल कंटेनर में डालें।',
    'step_1_2_o': 'बर्फ का आकार नहीं बदलता; यह चौकोर ही रहती है।',
    'step_1_3_c': 'पिघलने की तैयारी',
    'step_1_3_a': 'बर्फ के टुकड़े को खींचकर कांच के गिलास में डालें।',
    'step_1_3_o': 'बर्फ तापमान परिवर्तन के लिए तैयार है।',
    'step_1_4_c': 'अवस्था परिवर्तन (पिघलना)',
    'step_1_4_a':
        "बर्फ पिघलाने के लिए 'बर्फ पिघलाएँ' समय-व्यतीत स्लाइडर को खींचकर बिल्कुल अंत तक ले जाएँ।",
    'step_1_4_o': 'ठोस बर्फ पिघलकर तरल पानी बन जाती है।',
    'step_1_5_c': 'तरल आकार (चौकोर)',
    'step_1_5_a':
        'कांच के गिलास को खींचकर चौकोर कंटेनर के ऊपर छोड़ें, ताकि उसका पानी कंटेनर में गिर जाए।',
    'step_1_5_o': 'पानी बहता है और चौकोर आकार ले लेता है।',
    'step_1_6_c': 'तरल आकार (गोल)',
    'step_1_6_a':
        'चौकोर कंटेनर को खींचकर गोल कंटेनर के ऊपर छोड़ें, ताकि उसका पानी गोल कंटेनर में गिर जाए।',
    'step_1_6_o': 'पानी बहता है और गोल आकार ले लेता है।',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'तराजू सेट करें',
    'step_2_1_a':
        "कांच के गिलास को खींचकर डिजिटल तराजू पर रखें, फिर 'टेयर करें (0.00 g)' बटन दबाएँ।",
    'step_2_1_o': 'खाली गिलास रखे होने पर तराजू का पाठ्यांक 0.00 g है।',
    'step_2_2_c': 'तरल द्रव्यमान जोड़ें',
    'step_2_2_a':
        'पानी के जग को खींचकर कांच के गिलास के ऊपर छोड़ें, ताकि गिलास में पानी गिर जाए।',
    'step_2_2_o': 'द्रव्यमान बढ़कर एक स्थिर मान पर पहुँच जाता है।',
    'step_2_3_c': 'सिस्टम को ठंडा करें',
    'step_2_3_a':
        'बर्फ के टुकड़ों की ट्रे को खींचकर कांच के गिलास के ऊपर छोड़ें, ताकि बर्फ पानी में गिर जाए।',
    'step_2_3_o': 'द्रव्यमान और बढ़ जाता है। गिलास ठंडा हो जाता है।',
    'step_2_4_c': 'नियंत्रण चर',
    'step_2_4_a':
        'मार्कर पेन को खींचकर कांच के गिलास के पास छोड़ें, ताकि जल स्तर पर एक रेखा बन जाए।',
    'step_2_4_o': 'एक स्थायी रेखा वर्तमान मात्रा को चिह्नित करती है।',
    'step_2_5_c': 'संघनन',
    'step_2_5_a':
        "'30 मिनट प्रतीक्षा करें' समय-व्यतीत स्लाइडर को खींचकर अंत तक ले जाएँ, और तराजू तथा गिलास के बाहरी भाग को देखें।",
    'step_2_5_o': 'बाहर बूँदें बनती हैं। द्रव्यमान धीरे-धीरे बढ़ता है!',
    'step_2_6_c': 'अंतिम विश्लेषण',
    'step_2_6_a':
        "गिलास के अंदर के जल स्तर की तुलना मार्कर की रेखा से करें और तराजू का पाठ्यांक पढ़ें, फिर 'अवलोकन समाप्त करें' बटन दबाएँ।",
    'step_2_6_o':
        'अंदर का स्तर नहीं गिरा, लेकिन द्रव्यमान बढ़ गया। पानी हवा से आया!',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1': 'चरण 1: चौकोर बर्फ के टुकड़े को खींचकर चौकोर कंटेनर में डालें।',
    's1_hud_2': 'चरण 2: बर्फ के टुकड़े को खींचकर गोल कंटेनर में डालें।',
    's1_hud_3': 'चरण 3: बर्फ के टुकड़े को खींचकर कांच के गिलास में डालें।',
    's1_hud_4': 'चरण 4: बर्फ पिघलाने के लिए समय-व्यतीत स्लाइडर का उपयोग करें।',
    's1_hud_5': 'चरण 5: चौकोर कंटेनर में पानी डालने के लिए गिलास को खींचें।',
    's1_hud_6':
        'चरण 6: गोल कंटेनर में पानी डालने के लिए चौकोर कंटेनर को खींचें।',
    's1_hud_7': 'अवलोकन पूर्ण! सारांश देखें।',
    's2_hud_1':
        'चरण 1: कांच के गिलास को खींचकर डिजिटल तराजू पर रखें। टेयर दबाएँ।',
    's2_hud_2': 'चरण 2: गिलास में पानी डालने के लिए पानी के जग को खींचें।',
    's2_hud_3':
        'चरण 3: पानी को ठंडा करने के लिए बर्फ के टुकड़ों को खींचकर गिलास में डालें।',
    's2_hud_4': 'चरण 4: जल स्तर पर रेखा खींचने के लिए मार्कर पेन को खींचें।',
    's2_hud_5':
        'चरण 5: 30 मिनट प्रतीक्षा करने के लिए समय स्लाइडर का उपयोग करें। द्रव्यमान और गिलास देखें।',
    's2_hud_6':
        "चरण 6: अंदर के अंतिम जल स्तर और बाहर के पानी का निरीक्षण करें। 'अवलोकन समाप्त करें' दबाएँ।",
    's2_hud_7': 'अवलोकन पूर्ण! सारांश देखें।',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    // ---------------------------------------------------- buttons, slider
    'btn_tare': 'टेयर करें (0.00 g)',
    'btn_finish': 'अवलोकन समाप्त करें',
    'slider_start': 'शुरू',
    'slider_end': 'अंत',
    'melt_ice': 'बर्फ पिघलाएँ',
    'wait_30_mins': '30 मिनट प्रतीक्षा करें',
    'minutes': '{n} मिनट',
    // ------------------------------------------------------------- toasts
    'toast_tare': 'तराजू 0.00 g पर सेट',
    'toast_marker': 'जल स्तर चिह्नित!',
    // ------------------------------------------------------------ summary
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_sum_head': 'ठोस बनाम तरल!',
    's1_summary':
        'आपने साबित कर दिया है कि ठोस (बर्फ) का एक निश्चित आकार होता है, चाहे उसे कहीं भी रखा जाए। लेकिन तरल (पानी) का कोई निश्चित आकार नहीं होता और वह हमेशा अपने बर्तन का आकार ले लेता है!',
    's2_sum_head': 'संघनन की पुष्टि!',
    's2_summary':
        'अंदर का जल स्तर नहीं गिरा, यह साबित करता है कि पानी बाहर नहीं रिसा। द्रव्यमान में वृद्धि यह साबित करती है कि हवा में मौजूद अदृश्य जलवाष्प ठंडे कांच से टकराकर तरल बूँदों में बदल गई!',
    // ------------------------------------------------------ scene labels
    'lbl_ice_cube': 'बर्फ का टुकड़ा',
    'lbl_ice_cubes': 'बर्फ के टुकड़े',
    'lbl_sq_container': 'चौकोर कंटेनर',
    'lbl_rnd_container': 'गोल कंटेनर',
    'lbl_tumbler': 'कांच का गिलास',
    'lbl_pitcher': 'पानी का जग',
    'lbl_balance': 'डिजिटल तराजू',
    'lbl_marker': 'मार्कर पेन',
    'lbl_shape_fixed': 'आकार: निश्चित',
    'lbl_shape_takes': 'आकार: कंटेनर का आकार लेता है',
    'lbl_state_solid': 'अवस्था: ठोस (बर्फ)',
    'lbl_state_liquid': 'अवस्था: तरल (पानी)',
    // SI symbol, as in the NCERT Hindi textbooks.
    'unit_g': 'g',
    // ------------------------------------------------------------- toasts
    'first_1_1': 'पहले बर्फ के टुकड़े को चौकोर कंटेनर में डालें।',
    'first_1_2': 'पहले बर्फ के टुकड़े को गोल कंटेनर में डालें।',
    'first_1_3': 'पहले बर्फ के टुकड़े को कांच के गिलास में डालें।',
    'first_1_4': 'पहले समय-व्यतीत स्लाइडर से बर्फ पिघलाएँ।',
    'first_1_5': 'पहले गिलास का पानी चौकोर कंटेनर में डालें।',
    'first_1_6': 'पहले चौकोर कंटेनर का पानी गोल कंटेनर में डालें।',
    'first_2_1': 'पहले कांच के गिलास को डिजिटल तराजू पर रखें।',
    'first_2_1b': "पहले 'टेयर करें (0.00 g)' बटन दबाएँ।",
    'first_2_2': 'पहले पानी के जग से गिलास में पानी डालें।',
    'first_2_3': 'पहले बर्फ के टुकड़े गिलास में डालें।',
    'first_2_4': 'पहले मार्कर पेन से जल स्तर चिह्नित करें।',
    'first_2_5': 'पहले समय-व्यतीत स्लाइडर को अंत तक ले जाएँ।',
    'first_2_6': "'अवलोकन समाप्त करें' बटन दबाएँ।",
    'wrong_1_1':
        'यह चौकोर कंटेनर नहीं है! बर्फ के टुकड़े को चौकोर कंटेनर में डालें।',
    'wrong_1_2':
        'यह गोल कंटेनर नहीं है! बर्फ के टुकड़े को गोल कंटेनर में डालें।',
    'wrong_1_3':
        'यह कांच का गिलास नहीं है! बर्फ के टुकड़े को कांच के गिलास में डालें।',
    'wrong_1_5': 'यह चौकोर कंटेनर नहीं है! पानी चौकोर कंटेनर में डालें।',
    'wrong_1_6': 'यह गोल कंटेनर नहीं है! पानी गोल कंटेनर में डालें।',
    'miss_1_1': 'बर्फ के टुकड़े को ठीक चौकोर कंटेनर के ऊपर छोड़ें।',
    'miss_1_2': 'बर्फ के टुकड़े को ठीक गोल कंटेनर के ऊपर छोड़ें।',
    'miss_1_3': 'बर्फ के टुकड़े को ठीक कांच के गिलास के ऊपर छोड़ें।',
    'miss_1_5': 'गिलास को ठीक चौकोर कंटेनर के ऊपर छोड़ें।',
    'miss_1_6': 'चौकोर कंटेनर को ठीक गोल कंटेनर के ऊपर छोड़ें।',
    'miss_2_1': 'कांच के गिलास को डिजिटल तराजू के पलड़े पर रखें।',
    'miss_2_2': 'पानी के जग को ठीक कांच के गिलास के ऊपर छोड़ें।',
    'miss_2_3': 'बर्फ के टुकड़ों को ठीक कांच के गिलास के ऊपर छोड़ें।',
    'miss_2_4': 'मार्कर पेन को ठीक कांच के गिलास के पास छोड़ें।',
    'scene_s1':
        'मेज़ पर बर्फ का टुकड़ा, चौकोर कंटेनर, गोल कंटेनर और कांच का गिलास।',
    'scene_s2':
        'मेज़ पर डिजिटल तराजू, कांच का गिलास, पानी का जग, बर्फ के टुकड़ों की ट्रे और मार्कर पेन।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [6, 6];

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

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `resetCamera()`: `camera.position.set(0, 20, 40)` and
/// `controls.target.set(0, 4, 0)`, the same in both scenarios.
const _V _eye = _V(0, 20, 40);
const _V _lookAt = _V(0, 4, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.7)` and `DirectionalLight(
/// 0xffffff, 0.8)` at (10, 20, 15) (the weak back point light is left out).
/// Both are scaled by [_lightScale] so lit faces do not wash out.
const double _lightScale = 0.75;
const double _ambient = 0.7 * _lightScale;
const double _diffuse = 0.8 * _lightScale;

/// (10, 20, 15) normalised.
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking objects up (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's label text stays readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Design px between stacked label chips and between a chip and its object.
const double _labelGap = 5;

/// Label chips wrap at this many label sizes.
const double _chipWrap = 11;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make anything jump.
const double _maxFrameStep = 0.1;

/// Time constant (s) of the stage framing as it follows the sidebar.
const double _viewSmoothing = 0.06;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas while the sidebar is open (two lines, label row, padding;
/// x UI scale) and the compact floating mission card while it is
/// collapsed (phones in landscape: screens shorter than [_compactBelow],
/// at most [_compactCardMax] of the height, [_missionTop] from the top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Canvas / design px kept free around cards and stage edges.
const double _cardGap = 8;

/// Height kept free for the shell's toast at the top of the canvas (x UI
/// scale); the time-lapse / button card sits below it.
const double _toastBand = 52;

/// Height of that card: the 48 dp slider plus its label row and padding
/// (the scaled part, x UI scale). The framing always keeps this band free
/// so the scene does not jump when the card appears.
const double _controlFixed = 48;
const double _controlScaled = 34;
const double _controlMaxWidth = 420;

/// Key of the time-lapse slider (used by the flow test).
const ValueKey<String> _sliderKey = ValueKey('ch8a1-time-slider');

// ------------------------------------------------------------ animations

/// `executeStepAction`: the dropped object tweens into place in 500 ms
/// (Linear) and the step moves on 600 ms after the drop.
const double _dropSeconds = 0.5;
const double _dropStepDelay = 0.6;

/// `checkDrop` miss: back to its place in 500 ms, Quadratic.Out.
const double _snapSeconds = 0.5;

/// Pour: move over the target and tip to π / 3 in 500 ms, then the water
/// moves across in 1000 ms. The emptied container then goes back upright
/// to its place in 500 ms (added: the HTML hid it).
const double _tiltAngle = math.pi / 3;
const double _tiltSeconds = 0.5;
const double _transferSeconds = 1.0;
const double _homeSeconds = 0.5;

/// Scenario 2 step 1: TARE appears 600 ms after the drop and the step moves
/// on 1000 ms after TARE. The balance shows the empty tumbler's mass for
/// [_weighSeconds] before (added: the HTML display stayed hidden).
const double _tareShowDelay = 0.6;
const double _tareStepDelay = 1.0;
const double _weighSeconds = 0.5;

/// Pitcher: water and mass rise for 1500 ms; 1600 ms after the tip it turns
/// back upright in 500 ms, then the step moves on.
const double _pitcherFillSeconds = 1.5;
const double _pitcherHold = 1.6;

/// Ice: the tray reaches the tumbler in 500 ms; the cubes drop in and the
/// water rises in 300 ms, the mass in 800 ms; the step moves on 1000 ms
/// after the cubes drop.
const double _iceFallSeconds = 0.3;
const double _iceMassSeconds = 0.8;
const double _iceStepDelay = 1.0;

/// Marker: reaches the tumbler in 500 ms, draws for 1000 ms (the HTML spin).
const double _markerDrawSeconds = 1.0;

/// `if (v == 1) setTimeout(advanceStep, 500)`.
const double _sliderStepDelay = 0.5;

/// HTML highlight: `(sin(Date.now() * 0.005) + 1) / 2`, lerped by 0.45.
const double _pulseRate = 5;
const double _pulseMax = 0.45;

// -------------------------------------------------------------- geometry

/// `BoxGeometry(60, 2, 30)` desk at y = -1 (top at 0).
const _V _deskCenter = _V(0, -1, 0);
const _V _deskSize = _V(60, 2, 30);

/// Scenario 1 ice cube: `BoxGeometry(2.5, …)` in the HTML, enlarged to 3.5
/// so the water it melts into is visible in every container (see
/// [_meltRatio]).
const double _iceSide = 3.5;

/// `createHollowBox(7, 7, 7)` at (-4, 3.5, 0), walls 0.2; water
/// `BoxGeometry(6.6, …)`.
const double _boxSize = 7;
const double _boxWall = 0.2;
const double _boxInner = 6.6;

/// Fish bowl: `SphereGeometry(3.5)` at (7, 3.5, 0) on a
/// `CylinderGeometry(2, 2.5, 0.5)` base; water `SphereGeometry(3.3)`. The
/// HTML sphere was cut at the bottom; the port opens it at the top, at
/// [_bowlRim] above its centre.
const double _bowlRadius = 3.5;
const double _bowlInner = 3.3;
const double _bowlRim = 2.3;
const double _bowlBaseTop = 2;
const double _bowlBaseBottom = 2.5;
const double _bowlBaseHeight = 0.5;

/// Scenario 1 tumbler: open `CylinderGeometry(3.2, 2.8, 7)` at (18, 3.5, 0)
/// on a 0.3 base; water `CylinderGeometry(3.1, 2.75, …)`.
const double _cupTop = 3.2;
const double _cupBottom = 2.8;
const double _cupHeight = 7;
const double _cupBase = 0.3;
const double _cupInnerTop = 3.1;
const double _cupInnerBottom = 2.75;

/// The melted ice becomes water of 0.92 of its volume (ice is about 9 %
/// less dense than water). The HTML filled every container to the brim
/// from one small cube.
const double _meltRatio = 0.92;
const double _meltWater = _iceSide * _iceSide * _iceSide * _meltRatio;

/// Floating ice keeps this share of its height under water.
const double _iceDraft = 0.92;

/// The part of an ice cube under water is seen through the water: a water
/// tint of this opacity, drawn this much wider than the cube.
const double _underWater = 0.45;
const double _wetSkin = 1.01;

/// Where the pouring container is held: the tumbler at (sq.x + 3,
/// sq.y + 6), the square container at (rnd.x + 3, rnd.y + 5).
const _V _pourOverSquare = _V(-1, 9.5, 0);
const _V _pourOverRound = _V(10, 8.5, 0);

/// A container's drop zone is its column from its base to this far above
/// its rim, widened by [_catchPad] design px (x the framing scale).
const double _hoverReach = 6;
const double _catchPad = 20;

/// Scenario 2 tumbler: open `CylinderGeometry(3.5, 3.0, 8)` on a 0.4 base;
/// water `CylinderGeometry(3.4, 2.95, 7.6)`. Its centre is [_glassHalf]
/// above its base (the HTML stood it 0.6 into the desk).
const double _glassTop = 3.5;
const double _glassBottom = 3.0;
const double _glassHeight = 8;
const double _glassBase = 0.4;
const double _glassHalf = 4.1;
const double _glassInnerTop = 3.4;
const double _glassInnerBottom = 2.95;
const double _glassInnerHeight = 7.6;

/// Digital balance at (0, 0.5, 0): body `BoxGeometry(12, 1, 12)`, pad
/// `CylinderGeometry(4.5, 4.5, 0.2)` (top at 1.2), screen on the front.
const _V _bodySize = _V(12, 1, 12);
const double _padRadius = 4.5;
const double _padBottom = 1.0;
const double _padHeight = 0.2;
const double _padTop = _padBottom + _padHeight;
const _V _glassOnPad = _V(0, _padTop + _glassHalf, 0);

/// Readout centre on the balance's front face.
const _V _readoutAt = _V(0, 0.5, 6);

/// Masses (g): the empty tumbler before TARE (added), the poured water
/// (`animateMass(0, 150)`), the ice (`150 -> 175`) and the dew after 30
/// minutes (`175 + v * 1.5`).
const double _glassMass = 185.4;
const double _waterMass = 150;
const double _iceMass = 25;
const double _dewMass = 1.5;

/// Water level as a share of the inner height: `scale.y` 0.5 after the
/// pour, 0.55 with the ice.
const double _waterFill = 0.5;
const double _iceFill = 0.55;

/// Pitcher: open `CylinderGeometry(4, 4, 10)` on a 0.5 base, water
/// `CylinderGeometry(3.9, 3.9, 9)`, half-torus handle on its left.
const double _pitcherRadius = 4;
const double _pitcherHeight = 10;
const double _pitcherBase = 0.5;
const double _pitcherWaterRadius = 3.9;
const double _pitcherWaterHeight = 9;

/// The pitcher holds this much less water after pouring (added).
const double _pitcherPoured = 0.4;

/// Ice tray `BoxGeometry(6, 1, 6)` with three 1.5 cubes.
const _V _traySize = _V(6, 1, 6);
const double _cubeSide = 1.5;

/// Cubes on the tray, relative to its centre (`-1.5 + i * 1.5`, z ±1).
const List<_V> _trayCubes = [
  _V(-1.5, 1.25, -1),
  _V(0, 1.25, 1),
  _V(1.5, 1.25, -1),
];

/// The same cubes floating in the tumbler (x, z from its axis).
const List<_V> _floatCubes = [
  _V(-1.1, 0, -0.6),
  _V(0.2, 0, 0.8),
  _V(1.2, 0, -0.5),
];

/// The cubes shrink to this share of their size over the 30 minutes (added:
/// floating ice that melts leaves the water level where it was).
const double _cubeMelt = 0.6;

/// Marker pen: body `CylinderGeometry(0.5, 0.5, 6)`, cap
/// `CylinderGeometry(0.55, 0.55, 2)` 3 to its left, lying along x.
const double _markerRadius = 0.5;
const double _markerCapRadius = 0.55;

/// `dropletGroup`: 60 drops of radius 0.15, scale 0.5 … 1.5 at full
/// condensation (drawn 1.4x larger to stay visible on a phone).
const int _dropletCount = 60;
const double _dropletRadius = 0.15;
const double _dropletBoost = 1.4;

/// A held object stays over the 60 x 30 desk (x and z within these, less a
/// small border) and no higher than this above it.
const _V _reach = _V(26, 18, 12);

/// Free spots on the desk (used by the flows for a drop that misses).
const _V _openS1 = _V(-14, 1.75, 10);
const _V _openS2 = _V(-9, 1, 10);

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

/// How the scene is framed on the stage: the HTML camera's picture scaled
/// by [k] (never above 1) and shifted by ([dx], [dy]) design px, so the
/// interactive part stays clear of the shell's cards.
@immutable
class _View {
  const _View(this.dx, this.dy, this.k);

  static const _View identity = _View(0, 0, 1);

  final double dx;
  final double dy;
  final double k;

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

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the plane through [point] facing the
  /// camera (HTML `dragPlane.setFromNormalAndCoplanarPoint(camera
  /// direction, object)`).
  _V? onViewPlane(Offset s, _V point) {
    final dir = ray(s);
    final denom = dir.dot(f);
    if (denom.abs() < 1e-6) return null;
    final t = (point - eye).dot(f) / denom;
    if (t <= 0) return null;
    return eye + dir * t;
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
}

/// The unframed HTML camera (scene layout, framing).
final _Camera _baseCam = _Camera(_eye, _lookAt);

/// Projected bounding box of the world box centred at [c] with half sizes
/// [half].
Rect _boxBounds(_Camera cam, _V c, _V half) {
  var l = double.infinity, t = double.infinity;
  var r = -double.infinity, b = -double.infinity;
  for (final sx in const [-1.0, 1.0]) {
    for (final sy in const [-1.0, 1.0]) {
      for (final sz in const [-1.0, 1.0]) {
        final o = cam.p(
          _V(c.x + sx * half.x, c.y + sy * half.y, c.z + sz * half.z),
        );
        l = math.min(l, o.dx);
        t = math.min(t, o.dy);
        r = math.max(r, o.dx);
        b = math.max(b, o.dy);
      }
    }
  }
  return Rect.fromLTRB(l, t, r, b);
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

/// Solves `volume(h) == v` for h in [0, max] (volume rising with h).
double _solveLevel(double v, double max, double Function(double h) volume) {
  if (v <= 0) return 0;
  var lo = 0.0, hi = max;
  if (volume(hi) <= v) return hi;
  for (var i = 0; i < 32; i++) {
    final mid = (lo + hi) / 2;
    if (volume(mid) < v) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// Water height in the Scenario 1 tumbler for [v] cubic units (a frustum
/// from radius 2.75 at the floor to 3.1 at the rim).
double _cupLevel(double v) {
  const height = _cupHeight - _cupBase;
  const r0 = _cupInnerBottom;
  const dr = (_cupInnerTop - _cupInnerBottom) / height;
  return _solveLevel(v, height, (h) {
    final r1 = r0 + dr * h;
    return math.pi * h * (r0 * r0 + r0 * r1 + r1 * r1) / 3;
  });
}

/// Water height in the square container.
double _squareLevel(double v) =>
    math.min(_boxSize - _boxWall, v / (_boxInner * _boxInner));

/// Water height in the bowl, from the bottom of its inner sphere (a
/// spherical cap).
double _bowlLevel(double v) => _solveLevel(
  v,
  _bowlInner + _bowlRim,
  (h) => math.pi * h * h * (3 * _bowlInner - h) / 3,
);

/// The scene objects (HTML meshes the learner can see or move).
enum _Item {
  /// Scenario 1: `iceCube` at (-13, 1.25, 2).
  ice(0, 'lbl_ice_cube'),

  /// `sqContainer`.
  square(0, 'lbl_sq_container'),

  /// `rndContainer` (fish bowl).
  round(0, 'lbl_rnd_container'),

  /// Scenario 1 `tumbler`.
  cup(0, 'lbl_tumbler'),

  /// Scenario 2 tumbler at (15, 3.5, -5).
  glass(1, 'lbl_tumbler'),

  /// Digital balance.
  balance(1, 'lbl_balance'),

  /// `pitcher` at (-15, 5, -5).
  pitcher(1, 'lbl_pitcher'),

  /// `iceGroupS2` at (-15, 1.5, 5): the tray and its three cubes.
  tray(1, 'lbl_ice_cubes'),

  /// `marker` at (15, 1, 5).
  marker(1, 'lbl_marker');

  const _Item(this.scenario, this.labelKey);

  final int scenario;
  final String labelKey;

  /// Starting position (the HTML `position.set(...)`, standing on the
  /// desk where the HTML floated or sank them).
  _V get home => switch (this) {
    _Item.ice => const _V(-13, _iceSide / 2, 2),
    _Item.square => const _V(-4, 3.5, 0),
    _Item.round => const _V(7, 3.5, 0),
    _Item.cup => const _V(18, 3.5, 0),
    _Item.glass => const _V(15, _glassHalf, -5),
    _Item.balance => const _V(0, 0.5, 0),
    _Item.pitcher => const _V(-15, 5, -5),
    _Item.tray => const _V(-15, 0.5, 5),
    _Item.marker => const _V(15, _markerRadius, 5),
  };

  /// Half sizes of its bounding box (the ice at full size).
  _V get half => switch (this) {
    _Item.ice => const _V(_iceSide / 2, _iceSide / 2, _iceSide / 2),
    _Item.square => const _V(_boxSize / 2, _boxSize / 2, _boxSize / 2),
    _Item.round => const _V(_bowlRadius, _bowlRadius, _bowlRadius),
    _Item.cup => const _V(_cupTop, _cupHeight / 2, _cupTop),
    _Item.glass => const _V(_glassTop, _glassHalf, _glassTop),
    _Item.balance => const _V(6, 0.6, 6),
    _Item.pitcher => const _V(5.5, _pitcherHeight / 2, _pitcherRadius),
    _Item.tray => const _V(3, 1.25, 3),
    _Item.marker => const _V(3.5, _markerCapRadius, _markerCapRadius),
  };

  /// Centre of that box relative to the object's position.
  _V get boxOffset => switch (this) {
    _Item.balance => const _V(0, 0.1, 0),
    _Item.pitcher => const _V(-1.5, 0, 0),
    _Item.tray => const _V(0, 0.75, 0),
    _Item.marker => const _V(-0.5, 0, 0),
    _ => _V.zero,
  };

  /// Height of its base below its position.
  double get below => switch (this) {
    _Item.balance || _Item.tray => 0.5,
    _Item.marker => _markerRadius,
    _Item.glass => _glassHalf,
    _ => half.y,
  };

  /// Containers of Scenario 1 (drop targets of the ice and the water).
  bool get isContainer =>
      this == _Item.square || this == _Item.round || this == _Item.cup;
}

/// One scene object: where it is and what it is doing.
class _Body {
  _Body(this.item) : pos = item.home, rest = item.home;

  final _Item item;
  _V pos;

  /// Where it goes back to after a miss (its place when picked up).
  _V rest;

  /// HTML `rotation.z` (pouring).
  double tilt = 0;
  bool held = false;

  /// Tweening (snapping back, pouring, going home): not grabbable.
  bool moving = false;

  _V get boxCenter => pos + item.boxOffset;
}

/// One HTML `TWEEN.Tween` (or `setTimeout` when [apply] is null): runs
/// [apply] with the eased progress from [start] for [duration] seconds,
/// then [onDone].
class _Tween {
  _Tween(this.start, this.duration, this.apply, this.curve, this.onDone);

  final double start;
  final double duration;
  final void Function(double k)? apply;
  final Curve curve;
  final VoidCallback? onDone;
  bool done = false;
}

/// One condensation droplet on the Scenario 2 tumbler (HTML
/// `dropletGroup`): angle round the glass, height from its centre and its
/// size at full condensation.
@immutable
class _Drop {
  const _Drop(this.angle, this.h, this.maxScale);

  final double angle;
  final double h;
  final double maxScale;
}

/// The 60 droplets, placed once (the HTML used Math.random; a fixed seed
/// keeps them the same every run).
final List<_Drop> _drops = () {
  final rnd = math.Random(8);
  return [
    for (var i = 0; i < _dropletCount; i++)
      _Drop(
        rnd.nextDouble() * math.pi * 2,
        (rnd.nextDouble() - 0.5) * 7.5,
        0.5 + rnd.nextDouble(),
      ),
  ];
}();

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; 7 once the scenario is done).
  int step = 1;

  /// Bumped on every load, so a gesture from before cannot touch the new
  /// scene.
  int generation = 0;

  /// Bumped whenever the sidebar, HUD or cards must be rebuilt.
  int ui = 0;

  final List<_Body> bodies = [];
  final List<_Tween> tweens = [];

  /// A step's animation is running: nothing can be picked up.
  bool busy = false;

  // --------------------------------------------------------- scenario 1

  /// The container holding the ice (null: on the desk or in the hand).
  _Item? iceIn;

  /// Ice size share while it melts (HTML `iceCube.scale`).
  double iceScale = 1;

  /// Fully melted (HTML: the cube shrinks to 0.01; the port hides it).
  bool iceGone = false;

  /// Time-lapse slider share (S1 melting, S2 condensation).
  double slider = 0;

  /// HTML `State.s1.melted` (passed half way: the labels change).
  bool melted = false;

  /// Water (cubic units) in each Scenario 1 container.
  final Map<_Item, double> water = {};

  /// Property labels: 'Shape: Fixed' (steps 1-2), 'State: Solid (Ice)'
  /// (from step 3), 'State: Liquid (Water)' (melted, in the tumbler) and
  /// 'Shape: Takes shape of container' (the container that took the water).
  bool shapeFixed = false;
  bool solidLabel = false;
  bool liquidLabel = false;
  _Item? takesShape;

  /// The container pouring right now and the one it pours into.
  _Item? pourFrom;
  _Item? pourTo;

  // --------------------------------------------------------- scenario 2

  bool onBalance = false;
  bool tareShown = false;
  bool tared = false;

  /// Grams on the balance's display.
  double reading = 0;

  /// Water level in the tumbler, share of its inner height.
  double fill = 0;

  /// Water in the pitcher, share of its 9 units.
  double pitcherWater = 1;
  bool pitcherPouring = false;

  /// The cubes left the tray: where they started falling and how far.
  bool cubesIn = false;
  _V cubeFrom = _V.zero;
  double cubeFall = 0;
  double cubeScale = 1;

  /// Ice cooled the glass (frosty tint).
  bool cold = false;

  /// The marker line: drawn, at what height, how far round.
  bool lineDrawn = false;
  double lineY = 0;
  double lineSweep = 0;

  final _Camera cam = _Camera(_eye, _lookAt);
  _View view = _View.identity;
  _View viewTarget = _View.identity;

  /// The next framing jumps to its target instead of sliding.
  bool snapView = true;

  _Body body(_Item item) => bodies.firstWhere((b) => b.item == item);

  /// The object the current step asks the learner to drag (HTML
  /// `State.activeDragTarget`).
  _Item? get active {
    if (busy) return null;
    return switch ((scenario, step)) {
      (0, 1) || (0, 2) || (0, 3) => _Item.ice,
      (0, 5) => _Item.cup,
      (0, 6) => _Item.square,
      (1, 1) => onBalance ? null : _Item.glass,
      (1, 2) => _Item.pitcher,
      (1, 3) => _Item.tray,
      (1, 4) => _Item.marker,
      _ => null,
    };
  }

  /// The time-lapse slider is shown (S1 step 4, S2 step 5).
  bool get sliderShown =>
      (scenario == 0 && step == 4) || (scenario == 1 && step == 5);

  /// Current ice cube size.
  double get iceSide => _iceSide * iceScale;

  // ------------------------------------------------------------- tweens

  /// Adds a tween that starts after [delay] seconds.
  void tween(
    double duration,
    void Function(double k)? apply, {
    double delay = 0,
    Curve curve = Curves.linear,
    VoidCallback? onDone,
  }) {
    tweens.add(_Tween(time + delay, duration, apply, curve, onDone));
  }

  /// HTML `setTimeout(fn, seconds)`.
  void wait(double seconds, VoidCallback fn) =>
      tween(0, null, delay: seconds, onDone: fn);

  /// Moves [b] to [to] (from wherever it is when the move starts).
  void move(
    _Body b,
    _V to,
    double duration, {
    double delay = 0,
    Curve curve = Curves.linear,
    VoidCallback? onDone,
  }) {
    _V? from;
    tween(
      duration,
      (k) {
        from ??= b.pos;
        b.pos = _V.lerp(from!, to, k);
      },
      delay: delay,
      curve: curve,
      onDone: onDone,
    );
  }

  /// HTML `TWEEN.update()`.
  void advance() {
    for (final tw in List.of(tweens)) {
      if (tw.done || time < tw.start) continue;
      final k = tw.duration <= 0
          ? 1.0
          : ((time - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.apply?.call(tw.curve.transform(k));
      if (k >= 1) {
        tw.done = true;
        tw.onDone?.call();
      }
    }
    tweens.removeWhere((t) => t.done);
  }

  // ---------------------------------------------------------- geometry

  /// Floor (inner bottom) height of a Scenario 1 container at its place.
  double floorOf(_Body b) => switch (b.item) {
    _Item.square => b.pos.y - _boxSize / 2 + _boxWall,
    _Item.cup => b.pos.y - _cupHeight / 2 + _cupBase,
    _ => b.pos.y - _bowlInner,
  };

  /// Height of the water surface in a Scenario 1 container.
  double waterTop(_Body b) {
    final v = water[b.item] ?? 0;
    return floorOf(b) +
        switch (b.item) {
          _Item.square => _squareLevel(v),
          _Item.cup => _cupLevel(v),
          _ => _bowlLevel(v),
        };
  }

  /// Where the ice cube rests in container [c]: on its floor, floating once
  /// the water is deep enough; in the bowl where the curved glass holds its
  /// corners.
  _V iceSeat(_Item c) {
    final b = body(c);
    final s = iceSide;
    if (c == _Item.round) {
      final d = s / math.sqrt2;
      final bottom =
          b.pos.y - math.sqrt(math.max(0.0, _bowlInner * _bowlInner - d * d));
      return b.pos.withY(bottom + s / 2);
    }
    final rest = floorOf(b) + s / 2;
    final afloat = waterTop(b) + s * (0.5 - _iceDraft);
    return b.pos.withY(math.max(rest, afloat));
  }

  /// Inner floor of the Scenario 2 tumbler.
  double get glassFloor => body(_Item.glass).pos.y - _glassHalf + _glassBase;

  /// Height of the Scenario 2 water surface.
  double get glassWaterTop => glassFloor + _glassInnerHeight * fill;

  /// Outer radius of the Scenario 2 tumbler at height [y].
  double glassRadiusAt(double y) {
    final bottom = body(_Item.glass).pos.y - _glassHalf + 0.1;
    final k = ((y - bottom) / _glassHeight).clamp(0.0, 1.0);
    return _glassBottom + (_glassTop - _glassBottom) * k;
  }

  // ------------------------------------------------------ flow helpers

  /// Design-space position of a named scene point (used by the flows):
  /// the objects, `pan` (where the tumbler's centre goes on the balance)
  /// and `open` (a free spot on the desk).
  Offset anchor(String id) {
    for (final b in bodies) {
      if (b.item.name == id) {
        // The ice tray is grabbed by its cubes.
        return cam.p(b.item == _Item.tray ? b.boxCenter : b.pos);
      }
    }
    return switch (id) {
      'pan' => cam.p(_glassOnPad),
      'open' => cam.p(scenario == 0 ? _openS1 : _openS2),
      _ => cam.p(_lookAt),
    };
  }

  /// Name of the container holding the ice (flows).
  String? get iceInName => iceIn?.name;

  /// Water (cubic units) in a Scenario 1 container, by name (flows).
  double waterIn(String id) =>
      water[_Item.values.firstWhere((i) => i.name == id)] ?? 0;

  /// Total Scenario 1 water: the melted ice (flows).
  double get meltWater => _meltWater;

  /// The marker line sits at the water surface (flows).
  bool get lineAtWater => lineDrawn && (lineY - glassWaterTop).abs() < 0.05;

  /// Droplets large enough to see (flows).
  int get visibleDrops => scenario == 1
      ? _drops.where((d) => d.maxScale * slider > 0.05).length
      : 0;

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    generation++;
    ui++;
    scenario = index;
    step = 1;
    busy = false;
    tweens.clear();
    bodies
      ..clear()
      ..addAll([
        for (final i in _Item.values)
          if (i.scenario == index) _Body(i),
      ]);
    iceIn = null;
    iceScale = 1;
    iceGone = false;
    slider = 0;
    melted = false;
    water.clear();
    shapeFixed = false;
    solidLabel = false;
    liquidLabel = false;
    takesShape = null;
    pourFrom = null;
    pourTo = null;
    onBalance = false;
    tareShown = false;
    tared = false;
    reading = 0;
    fill = 0;
    pitcherWater = 1;
    pitcherPouring = false;
    cubesIn = false;
    cubeFrom = _V.zero;
    cubeFall = 0;
    cubeScale = 1;
    cold = false;
    lineDrawn = false;
    lineY = 0;
    lineSweep = 0;
    snapView = true;
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a scene object ([canGrab]), so other drags still pan / zoom the
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

/// What the current pointer holds.
class _Grab {
  _Grab(this.body, this.offset, this.plane, this.generation, this.restIn);

  final _Body body;

  /// Drag-plane hit minus the object's position at pointer-down.
  final _V offset;

  /// A point of the camera-facing drag plane.
  final _V plane;
  final int generation;

  /// The container the ice was in when picked up.
  final _Item? restIn;

  /// The finger moved past the slop (a plain tap puts it straight back).
  bool moved = false;
}

class _StatesOfWaterLabState
    extends State<Ch8A1StatesOfWaterAndTheirPropertiesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The time-lapse slider's value (its card rebuilds on its own).
  final ValueNotifier<double> _sliderValue = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  _Grab? _grab;
  int _seenUi = -1;

  /// Touch radius and label size in design px for the current stage scale,
  /// and the tool column's left edge (set while laying out the stage).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

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
    _sliderValue.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()` (`TWEEN.update()`), then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.view = s.view.toward(s.viewTarget, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    s.advance();
    if (s.ui != _seenUi) {
      _seenUi = s.ui;
      _refresh();
    }
    _frame.value = now;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `advanceStep()`.
  void _nextStep() {
    final s = _scene;
    s
      ..step += 1
      ..busy = false
      ..ui += 1;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and tween and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
      _sliderValue.value = 0;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `triggerMainAction()`: the summary popup of a finished scenario.
  void _conclude(int sc) {
    final n = sc + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': n}),
      body: () => '${_t('s${n}_sum_head')}\n\n${_t('s${n}_summary')}',
    );
  }

  // ------------------------------------------------- scenario 1 actions

  /// The container the step's object must be let go over (HTML
  /// `State.activeDropZone`).
  _Item? _s1Target(int step) => switch (step) {
    1 || 5 => _Item.square,
    2 || 6 => _Item.round,
    3 => _Item.cup,
    _ => null,
  };

  /// HTML `checkDrop()` for Scenario 1: the object counts as dropped into a
  /// container only when let go over that container (the HTML accepted any
  /// drop within 14 units of the target, so a tap passed steps 1-3 and 6
  /// and the round container passed for the square one in step 5). A miss
  /// puts the ice back into [restIn], the container it was taken from.
  void _dropS1(_Body b, _Item? restIn) {
    final s = _scene;
    final target = _s1Target(s.step);
    final over = _containerUnder(b);
    if (target != null && over == target) {
      _s1Success(b, target);
      return;
    }
    _snapBack(b, restIn: restIn);
    _lab.showToast(
      _t(over != null ? 'wrong_1_${s.step}' : 'miss_1_${s.step}'),
      isError: true,
    );
  }

  /// The Scenario 1 container whose column [b] is over (nearest first).
  _Item? _containerUnder(_Body b) {
    final s = _scene;
    final cam = s.cam;
    final c = cam.p(b.boxCenter);
    _Item? best;
    var bestD = double.infinity;
    for (final o in s.bodies) {
      if (!o.item.isContainer || o.item == b.item) continue;
      final half = o.item.half;
      final a = cam.p(o.pos - _V(0, half.y, 0));
      final top = o.pos + _V(0, half.y + _hoverReach, 0);
      final reach = half.x * cam.scaleAt(top) + _catchPad * s.view.k;
      final d = _segmentDistance(c, a, cam.p(top));
      if (d <= reach && d < bestD) {
        best = o.item;
        bestD = d;
      }
    }
    return best;
  }

  void _s1Success(_Body b, _Item target) {
    final s = _scene;
    _Sound.correct.play(); // HTML playSound('success')
    s
      ..busy = true
      ..ui += 1;
    switch (s.step) {
      case 1 || 2 || 3:
        s.iceIn = target;
        b.moving = true;
        s.move(
          b,
          s.iceSeat(target),
          _dropSeconds,
          onDone: () => b.moving = false,
        );
        s.wait(_dropStepDelay, () {
          if (s.step == 1) s.shapeFixed = true;
          if (s.step == 3) {
            s
              ..shapeFixed = false
              ..solidLabel = true;
          }
          _nextStep();
        });
      case 5:
        _pour(
          b,
          _Item.square,
          _pourOverSquare,
          then: () {
            s
              ..liquidLabel = false
              ..takesShape = _Item.square;
            _nextStep();
          },
        );
      case 6:
        s.takesShape = null;
        _pour(
          b,
          _Item.round,
          _pourOverRound,
          then: () {
            s
              ..takesShape = _Item.round
              ..step = 7
              ..busy = false
              ..ui += 1;
            _conclude(0);
          },
        );
    }
  }

  /// Steps 5 and 6: [b] moves over [to] and tips (500 ms), its water moves
  /// across (1000 ms), then it goes back upright to its place.
  void _pour(_Body b, _Item to, _V over, {required VoidCallback then}) {
    final s = _scene;
    b.moving = true;
    s.move(b, over, _tiltSeconds);
    s.tween(
      _tiltSeconds,
      (k) => b.tilt = _tiltAngle * k,
      onDone: () {
        _Sound.drop.play();
        s
          ..pourFrom = b.item
          ..pourTo = to;
        final total = s.water[b.item] ?? 0;
        final before = s.water[to] ?? 0;
        s.tween(
          _transferSeconds,
          (k) {
            s.water[b.item] = total * (1 - k);
            s.water[to] = before + total * k;
          },
          onDone: () {
            s
              ..pourFrom = null
              ..pourTo = null;
            then();
            s.move(
              b,
              b.item.home,
              _homeSeconds,
              onDone: () => b.moving = false,
            );
            s.tween(_homeSeconds, (k) => b.tilt = _tiltAngle * (1 - k));
          },
        );
      },
    );
  }

  /// HTML `onSliderMove(val)`: Scenario 1 step 4 melts the ice, Scenario 2
  /// step 5 lets 30 minutes pass. At the end of the slider the step moves
  /// on 500 ms later (once).
  void _onSlide(double v) {
    final s = _scene;
    if (!s.sliderShown || s.busy || !_lab.isLabActive) return;
    _sliderValue.value = v;
    s.slider = v;
    if (s.scenario == 0) {
      // Melting: the cube shrinks into the water it becomes.
      s
        ..iceScale = math.max(0.01, 1 - v)
        ..water[_Item.cup] = _meltWater * v;
      s.body(_Item.ice).pos = s.iceSeat(_Item.cup);
      if (v > 0.5 && !s.melted) {
        s
          ..melted = true
          ..solidLabel = false
          ..liquidLabel = true;
      }
    } else {
      // Condensation: drops grow on the cold glass, the mass creeps up and
      // the floating ice melts.
      s
        ..reading = _waterMass + _iceMass + _dewMass * v
        ..cubeScale = 1 - _cubeMelt * v;
    }
    if (v >= 1) {
      s
        ..busy = true
        ..ui += 1;
      s.wait(_sliderStepDelay, () {
        if (s.scenario == 0) s.iceGone = true;
        _nextStep();
      });
    }
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `checkDrop()` for Scenario 2: the tumbler must be let go on the
  /// balance pan, the pitcher, the ice and the marker at the tumbler (the
  /// HTML accepted anything within 14 units).
  void _dropS2(_Body b) {
    final s = _scene;
    final ok = switch (b.item) {
      _Item.glass => _overPan(b),
      _ => _overGlass(b),
    };
    if (!ok) {
      _snapBack(b);
      _lab.showToast(_t('miss_2_${s.step}'), isError: true);
      return;
    }
    _Sound.correct.play();
    s
      ..busy = true
      ..ui += 1;
    switch (b.item) {
      case _Item.glass:
        _placeGlass(b);
      case _Item.pitcher:
        _pourPitcher(b);
      case _Item.tray:
        _dropIce(b);
      case _Item.marker:
        _markLevel(b);
      default:
        s.busy = false;
    }
  }

  bool _overPan(_Body b) {
    final s = _scene;
    final cam = s.cam;
    const pan = _V(0, _padTop, 0);
    final reach = _padRadius * cam.scaleAt(pan) + _catchPad * s.view.k;
    return _segmentDistance(
          cam.p(b.boxCenter),
          cam.p(pan),
          cam.p(_glassOnPad + const _V(0, _glassHalf, 0)),
        ) <=
        reach;
  }

  bool _overGlass(_Body b) {
    final s = _scene;
    final cam = s.cam;
    final g = s.body(_Item.glass);
    final top = g.pos + const _V(0, _glassHalf + _hoverReach, 0);
    final reach = _glassTop * cam.scaleAt(top) + _catchPad * s.view.k;
    return _segmentDistance(
          cam.p(b.boxCenter),
          cam.p(g.pos - const _V(0, _glassHalf, 0)),
          cam.p(top),
        ) <=
        reach;
  }

  /// Step 1: the tumbler slides onto the pan (500 ms), the balance shows
  /// its mass, and TARE appears 600 ms after the drop.
  void _placeGlass(_Body b) {
    final s = _scene;
    b.moving = true;
    s.move(
      b,
      _glassOnPad,
      _dropSeconds,
      onDone: () {
        b.moving = false;
        s.onBalance = true;
        s.tween(
          _weighSeconds,
          // TARE can be tapped before the reading has settled.
          (k) => s.reading = s.tared ? 0 : _glassMass * k,
          curve: Curves.easeOutQuad,
        );
      },
    );
    s.wait(_tareShowDelay, () {
      s
        ..tareShown = true
        ..busy = false
        ..ui += 1;
    });
  }

  /// HTML `triggerTare()`.
  void _tare() {
    final s = _scene;
    if (s.scenario != 1 || !s.tareShown || s.tared) return;
    s
      ..tareShown = false
      ..tared = true
      ..reading = 0
      ..busy = true
      ..ui += 1;
    _lab.showToast(_t('toast_tare'), sound: false);
    s.wait(_tareStepDelay, _nextStep);
  }

  /// Step 2: the pitcher tips over the tumbler, water and mass rise for
  /// 1.5 s, and it turns back upright 1.6 s after the tip.
  void _pourPitcher(_Body b) {
    final s = _scene;
    final g = s.body(_Item.glass);
    b.moving = true;
    s.move(b, _V(g.pos.x - 5, 9, g.pos.z), _tiltSeconds);
    s.tween(
      _tiltSeconds,
      (k) => b.tilt = -_tiltAngle * k,
      onDone: () {
        _Sound.drop.play();
        s.pitcherPouring = true;
        s.tween(_pitcherFillSeconds, (k) {
          s
            ..fill = _waterFill * k
            ..reading = _waterMass * k
            ..pitcherWater = 1 - _pitcherPoured * k;
        }, onDone: () => s.pitcherPouring = false);
        s.wait(_pitcherHold, () {
          s.tween(
            _tiltSeconds,
            (k) => b.tilt = -_tiltAngle * (1 - k),
            onDone: () {
              _nextStep();
              s.move(
                b,
                b.item.home,
                _homeSeconds,
                onDone: () => b.moving = false,
              );
            },
          );
        });
      },
    );
  }

  /// Step 3: the tray reaches the tumbler (500 ms) and the cubes drop into
  /// the water (the HTML hid them); the empty tray goes back.
  void _dropIce(_Body b) {
    final s = _scene;
    final g = s.body(_Item.glass);
    b.moving = true;
    s.move(b, _V(g.pos.x, 9, g.pos.z), _dropSeconds);
    s.wait(_dropSeconds, () {
      _Sound.drop.play();
      s
        ..cubesIn = true
        ..cubeFrom = b.pos
        ..cold = true;
      s.tween(_iceFallSeconds, (k) {
        s
          ..cubeFall = k
          ..fill = _waterFill + (_iceFill - _waterFill) * k;
      });
      s.tween(_iceMassSeconds, (k) => s.reading = _waterMass + _iceMass * k);
      s.move(b, b.item.home, _homeSeconds, onDone: () => b.moving = false);
      s.wait(_iceStepDelay, _nextStep);
    });
  }

  /// Step 4: the marker's tip goes to the glass at the water surface and
  /// draws the line round it (the HTML put the line 1.9 below the water).
  void _markLevel(_Body b) {
    final s = _scene;
    final g = s.body(_Item.glass);
    final y = s.glassWaterTop;
    b.moving = true;
    s.move(b, _V(g.pos.x + s.glassRadiusAt(y) + 4, y, g.pos.z), _dropSeconds);
    s.wait(_dropSeconds, () {
      s
        ..lineDrawn = true
        ..lineY = y;
      _lab.showToast(_t('toast_marker'), sound: false);
      s.tween(
        _markerDrawSeconds,
        (k) => s.lineSweep = k,
        onDone: () {
          _nextStep();
          s.move(b, b.item.home, _homeSeconds, onDone: () => b.moving = false);
        },
      );
    });
  }

  /// HTML `triggerMainAction()` at Scenario 2 step 6.
  void _finish() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 6) return;
    s
      ..step = 7
      ..ui += 1;
    _conclude(1);
  }

  // -------------------------------------------------------------- gestures

  /// A missed drop: back to where it was picked up (500 ms, Quadratic.Out);
  /// the ice goes back into [restIn], the container it was taken from.
  void _snapBack(_Body b, {_Item? restIn}) {
    final s = _scene;
    _Sound.pop.play();
    b.moving = true;
    s.move(
      b,
      b.rest,
      _snapSeconds,
      curve: Curves.easeOutQuad,
      onDone: () {
        b.moving = false;
        if (b.item == _Item.ice && restIn != null) s.iceIn = restIn;
      },
    );
  }

  /// The scene object under [at] (design px): the one the step asks for
  /// first, otherwise the nearest.
  _Body? _hitTest(Offset at) {
    final s = _scene;
    final active = s.active;
    _Body? best;
    var bestScore = double.infinity;
    for (final b in s.bodies) {
      if (b.item == _Item.ice && s.iceGone) continue;
      final half = b.item == _Item.ice
          ? _V(s.iceSide / 2, s.iceSide / 2, s.iceSide / 2)
          : b.item.half;
      final bounds = _boxBounds(s.cam, b.boxCenter, half);
      final box = Rect.fromCenter(
        center: bounds.center,
        width: math.max(bounds.width, 2 * _touch),
        height: math.max(bounds.height, 2 * _touch),
      );
      if (!box.contains(at)) continue;
      final score = (b.item == active ? 0 : 1000) + s.cam.depth(b.boxCenter);
      if (score < bestScore) {
        best = b;
        bestScore = score;
      }
    }
    return best;
  }

  /// HTML `pointerdown` raycast against the scene.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null) return false;
    return _hitTest(event.localPosition) != null;
  }

  /// What the current step asks for, for an object touched out of turn.
  String? _hintKey() {
    final s = _scene;
    if (s.step > _stepCounts[s.scenario]) return null;
    if (s.scenario == 1 && s.step == 1 && s.onBalance) return 'first_2_1b';
    return 'first_${s.scenario + 1}_${s.step}';
  }

  /// HTML `pointerdown` on the active object: drag plane and offset.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final hit = _hitTest(d.localPosition);
    if (hit == null || s.busy) return;
    if (hit.item != s.active || hit.moving) {
      final key = _hintKey();
      if (key != null) _lab.showToast(_t(key), isError: true);
      return;
    }
    final at = s.cam.onViewPlane(d.localPosition, hit.pos);
    final restIn = hit.item == _Item.ice ? s.iceIn : null;
    hit
      ..rest = hit.pos
      ..held = true;
    if (hit.item == _Item.ice) s.iceIn = null;
    _grab = _Grab(
      hit,
      at == null ? _V.zero : at - hit.pos,
      hit.pos,
      s.generation,
      restIn,
    );
    _Sound.click.play(); // HTML startDrag: playSound('click')
  }

  void _onDragStart(DragStartDetails _) => _grab?.moved = true;

  /// HTML `pointermove`: the held object follows the finger on the plane
  /// facing the camera, kept above the desk.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    g.moved = true;
    final hit = s.cam.onViewPlane(d.localPosition, g.plane);
    if (hit == null) return;
    final p = hit - g.offset;
    final b = g.body;
    final below = b.item == _Item.ice ? s.iceSide / 2 : b.item.below;
    b.pos = _V(
      p.x.clamp(-_reach.x, _reach.x),
      p.y.clamp(below, _reach.y),
      p.z.clamp(-_reach.z, _reach.z),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` + `checkDrop()`. A tap that never moved puts the
  /// object straight back (the HTML ran checkDrop, and a tap passed).
  void _release() {
    final s = _scene;
    final g = _grab;
    _grab = null;
    if (g == null || g.generation != s.generation) return;
    final b = g.body..held = false;
    if (!g.moved) {
      b.pos = b.rest;
      if (b.item == _Item.ice) s.iceIn = g.restIn;
      return;
    }
    if (s.scenario == 0) {
      _dropS1(b, g.restIn);
    } else {
      _dropS2(b);
    }
  }

  // --------------------------------------------------------------- framing

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// shell card covers: the toast and time-lapse band at the top, the tool
  /// column, the HUD chip (sidebar open) and the floating mission card
  /// (sidebar collapsed: the scene moves below it or, if that would shrink
  /// it more, to its right). Returns the framing in design px for a canvas
  /// of [canvas] dp at stage scale [fit].
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
    final top =
        insets.top +
        _toastBand * s +
        _controlFixed +
        _controlScaled * s +
        _cardGap;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      top,
      canvas.width - insets.right,
      canvas.height - (open ? _hudBand * s + _cardGap : _cardGap) - pad.bottom,
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
  /// the current scenario: objects at their places and their labels.
  Rect _focusRect() {
    final l = _labelSize / _labelPx;
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    // A stack of [count] chips away from [at], about [halfW] wide.
    void chips(_V at, int count, {required bool up, double halfW = 55}) {
      final c = _baseCam.p(at);
      final h = count * (_labelPx * 2.2 * l + _labelGap) + _labelGap;
      add(
        Rect.fromLTWH(c.dx - halfW * l, up ? c.dy - h : c.dy, 2 * halfW * l, h),
      );
    }

    final sc = _scene.scenario;
    for (final i in _Item.values.where((i) => i.scenario == sc)) {
      add(_boxBounds(_baseCam, i.home + i.boxOffset, i.half));
    }
    if (sc == 0) {
      for (final i in const [_Item.square, _Item.round, _Item.cup]) {
        chips(_bottomFront(i, i.home), 1, up: false);
        chips(i.home + _V(0, i.half.y, 0), 2, up: true, halfW: 70);
      }
      chips(_bottomFront(_Item.ice, _Item.ice.home), 1, up: false, halfW: 45);
    } else {
      add(_boxBounds(_baseCam, _glassOnPad, _Item.glass.half));
      chips(_glassOnPad + const _V(0, _glassHalf, 0), 1, up: true);
      chips(_Item.glass.home + const _V(0, _glassHalf, 0), 1, up: true);
      chips(
        _Item.pitcher.home + const _V(0, _pitcherHeight / 2, 0),
        1,
        up: true,
      );
      chips(_bottomFront(_Item.tray, _Item.tray.home), 1, up: false);
      chips(_bottomFront(_Item.marker, _Item.marker.home), 1, up: false);
      chips(_readoutAt, 2, up: false);
    }
    return r ?? Offset.zero & _design;
  }

  /// The framing that shows [focus] inside one of [frees] as large as
  /// possible (never above the HTML size) and moved as little as possible.
  static _View _fitView(Rect focus, List<Rect> frees) {
    _View? best;
    var bestK = -1.0;
    var bestMove = double.infinity;
    for (final free in frees) {
      if (free.width <= 0 || free.height <= 0) continue;
      if (free.left <= focus.left &&
          free.top <= focus.top &&
          free.right >= focus.right &&
          free.bottom >= focus.bottom) {
        return _View.identity;
      }
      final k = math.min(
        1.0,
        math.min(free.width / focus.width, free.height / focus.height),
      );
      // Scaled about the focus centre, then pushed inside the free area.
      final c = focus.center;
      var dx = c.dx * (1 - k);
      var dy = c.dy * (1 - k);
      dx += _shiftInto(
        focus.left * k + dx,
        focus.right * k + dx,
        free.left,
        free.right,
      );
      dy += _shiftInto(
        focus.top * k + dy,
        focus.bottom * k + dy,
        free.top,
        free.bottom,
      );
      final move = (Offset(dx, dy) - c * (1 - k)).distance;
      if (k > bestK + 1e-6 || ((k - bestK).abs() <= 1e-6 && move < bestMove)) {
        best = _View(dx, dy, k);
        bestK = k;
        bestMove = move;
      }
    }
    return best ?? _View.identity;
  }

  /// Shift that moves [a, b] inside [lo, hi] (centred when it is wider).
  static double _shiftInto(double a, double b, double lo, double hi) {
    if (b - a > hi - lo) return (lo + hi - a - b) / 2;
    if (a < lo) return lo - a;
    if (b > hi) return hi - b;
    return 0;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-tare` (after the tumbler is on the balance) and
  /// `#btn-action-main` "Finish Observation" (Scenario 2 step 6).
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario != 1) return const [];
    if (s.step == 1 && s.tareShown && !s.tared) {
      return [
        LabAction(
          label: _t('btn_tare'),
          icon: Icons.scale,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _tare,
        ),
      ];
    }
    if (s.step == 6) {
      return [
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.check_circle,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: true,
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
        final s = context.labScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final n = data.steps.length;
        final actions = _actions();
        final slider = _scene.sliderShown && _lab.isLabActive;
        // The buttons also float on the canvas while the sidebar is open
        // (their sidebar copy can be below the fold on a phone); with the
        // sidebar collapsed the mission card carries them.
        final cardActions = _lab.isSidebarOpen ? actions : const <LabAction>[];
        final inset = labOverlayInsets(context, _lab);
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
          currentStep: _scene.step,
          // HTML `#hud-instruction` (`hud[State.step]`).
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, n + 1)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch8a1-steps-$sc-${_scene.step}'),
            steps: data.steps,
            current: _scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
            pendingText: _t('obs_pending'),
          ),
          overlays: [
            // HTML `#hud-container` controls: the time-lapse slider and the
            // TARE / Finish buttons, at the top of the canvas below the
            // toast (the HUD chip has the bottom).
            if (_lab.isLabActive && (slider || cardActions.isNotEmpty))
              Positioned(
                key: const ValueKey('ch8a1-controls'),
                top: inset.top + _toastBand * s,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: _ControlCard(
                    palette: _lab.palette,
                    scale: s,
                    slider: slider ? _sliderValue : null,
                    title: _t(sc == 0 ? 'melt_ice' : 'wait_30_mins'),
                    startLabel: _t('slider_start'),
                    endLabel: _t('slider_end'),
                    valueText: sc == 1
                        ? (v) =>
                              labFormat(_t('minutes'), {'n': (v * 30).round()})
                        : null,
                    onSlide: _onSlide,
                    actions: cardActions,
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
              ..snapView = false;
            s.cam.frame(s.view);
          }
        }
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Drags on the scene are not screen-reader actions; the scene
            // is announced by its label instead.
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
        );
      },
    );
  }
}

/// Bottom front edge of an object at [pos]: name labels go below it.
_V _bottomFront(_Item i, _V pos) =>
    pos + _V(0, -i.below, i == _Item.marker ? _markerRadius : i.half.z);

/// HTML `#hud-container` controls: the time-lapse slider (`#time-slider`:
/// Start / label / End, hourglass … sun) and the action buttons.
class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.palette,
    required this.scale,
    required this.slider,
    required this.title,
    required this.startLabel,
    required this.endLabel,
    required this.valueText,
    required this.onSlide,
    required this.actions,
  });

  final LabPalette palette;
  final double scale;

  /// The slider's value, or null when no slider is shown.
  final ValueListenable<double>? slider;
  final String title;
  final String startLabel;
  final String endLabel;

  /// Text for the time passed at a slider value, or null.
  final String Function(double v)? valueText;
  final ValueChanged<double> onSlide;
  final List<LabAction> actions;

  /// HTML slider: 8 px track, 24 px thumb; 48 dp tall to touch.
  static const double _trackHeight = 8;
  static const double _thumbRadius = 12;
  static const double _overlayRadius = 24;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final values = slider;
    final muted = TextStyle(
      color: p.textMuted,
      fontSize: 10 * s,
      fontWeight: FontWeight.w700,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _controlMaxWidth * s),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 4 * s),
        borderColor: _Colors.blue500.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (values != null)
              ValueListenableBuilder<double>(
                valueListenable: values,
                builder: (context, v, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(startLabel, style: muted),
                        Expanded(
                          child: Text(
                            valueText == null
                                ? title
                                : '$title • ${valueText!(v)}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.accentInk,
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(endLabel, style: muted),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_bottom,
                          size: 16 * s,
                          color: _Colors.slate400,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: _trackHeight * s,
                              activeTrackColor: _Colors.blue500,
                              inactiveTrackColor: p.isDark
                                  ? _Colors.slate700
                                  : _Colors.slate300,
                              thumbColor: _Colors.blue500,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: _thumbRadius * s,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: _overlayRadius,
                              ),
                            ),
                            child: Slider(
                              key: _sliderKey,
                              value: v.clamp(0.0, 1.0),
                              onChanged: onSlide,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.wb_sunny,
                          size: 18 * s,
                          color: _Colors.zslYellow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (actions.isNotEmpty) ...[
              if (values != null) SizedBox(height: 4 * s),
              for (final a in actions)
                Padding(
                  padding: EdgeInsets.only(bottom: 2 * s),
                  child: Center(
                    child: LabActionButton(action: a, scale: s, expand: false),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed. A step's result
/// is shown once the step is done (the HTML showed it before the learner
/// had seen it).
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
    // Future steps: dimmed.
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

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Thick round-ended lines (marker pen, poured stream, handle).
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// Thick butt-ended lines (glass shading bands).
  final Paint bar = Paint()..style = PaintingStyle.stroke;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Pulsing highlight of the object to drag.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  final Path path = Path();
  final Path aux = Path();
}

/// Kinds of scene text.
enum _Ink {
  /// Label chips: white (dark theme) or slate-800 (light theme) bold text.
  chip,
  chipLight,

  /// Green digits of the balance and its grey unit.
  readout,
  unit,

  /// The tag icon of the label chips.
  icon;

  TextStyle style(double size) {
    final family = LabFont.active.family;
    final fallback = LabFont.active.fallback;
    return switch (this) {
      _Ink.chip || _Ink.chipLight => TextStyle(
        color: this == _Ink.chip ? _Colors.labelText : _Colors.labelTextLight,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.readout => TextStyle(
        color: _Colors.readoutDigits,
        fontSize: size * 1.45,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: size * 0.08,
        fontFamily: family,
        fontFamilyFallback: fallback,
        // Digits keep their width while the reading climbs.
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      _Ink.unit => TextStyle(
        color: _Colors.readoutUnit,
        fontSize: size * 1.05,
        fontWeight: FontWeight.w700,
        height: 1.1,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.icon => TextStyle(
        color: _Colors.labelIcon,
        fontSize: size * 1.05,
        height: 1,
        fontFamily: Icons.sell.fontFamily,
        package: Icons.sell.fontPackage,
      ),
    };
  }
}

/// What the painter makes once and reuses: pens, the text painters of the
/// labels and readout, and the draw-order list. Owned by the page state and
/// disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _texts = {};

  /// Scene objects in drawing order (refilled every frame).
  final List<_Body> order = [];

  LabLang? _lang;
  double _labelSize = _labelPx;

  /// Most text painters kept; the cache is emptied past that.
  static const int _maxTexts = 400;

  /// Wrap widths are rounded to this many px, so a framing animation does
  /// not lay out a new painter every frame.
  static const double _wrapStep = 8;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeTexts();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter text(_Ink ink, String text, {double maxWidth = double.infinity}) {
    final wrap = maxWidth.isFinite
        ? (maxWidth / _wrapStep).floorToDouble() * _wrapStep
        : double.infinity;
    final key = '${ink.index}|$wrap|$text';
    final cached = _texts[key];
    if (cached != null) return cached;
    if (_texts.length >= _maxTexts) _disposeTexts();
    return _texts[key] = TextPainter(
      text: TextSpan(text: text, style: ink.style(_labelSize)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: wrap);
  }

  /// The tag glyph of the label chips.
  TextPainter get tag =>
      text(_Ink.icon, String.fromCharCode(Icons.sell.codePoint));

  void _disposeTexts() {
    for (final tp in _texts.values) {
      tp.dispose();
    }
    _texts.clear();
  }

  void dispose() => _disposeTexts();
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

/// Phong / Standard material look: ambient light plus the key light's
/// Lambert term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final k = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * k),
    green: math.min(1.0, c.g * k),
    blue: math.min(1.0, c.b * k),
  );
}

/// [c] lit by the pulsing cyan highlight ([amount] 0 … 0.45). The HTML
/// lerps the emissive colour to cyan, so the colour brightens towards it.
Color _tint(Color c, double amount) => amount <= 0
    ? c
    : Color.from(
        alpha: c.a,
        red: math.min(1.0, c.r + _Colors.highlight.r * amount),
        green: math.min(1.0, c.g + _Colors.highlight.g * amount),
        blue: math.min(1.0, c.b + _Colors.highlight.b * amount),
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
Offset _turn(Offset d, double tilt) {
  final a = -tilt;
  return Offset(
    d.dx * math.cos(a) - d.dy * math.sin(a),
    d.dx * math.sin(a) + d.dy * math.cos(a),
  );
}

/// Mesh drawing in the scene camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Camera cam;
  final _Pens pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  void _facePath(Path path, _V c, _V h, _Face face) {
    path.reset();
    for (var i = 0; i < 4; i++) {
      final k = face.corners[i];
      _move(
        path,
        i,
        cam.p(_V(c.x + k.x * h.x, c.y + k.y * h.y, c.z + k.z * h.z)),
      );
    }
    path.close();
  }

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
      final path = pens.path;
      _facePath(path, c, h, face);
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

  /// `createHollowBox`: the five faces of an open glass box, either the ones
  /// turned away from the camera (seen from inside, drawn before the
  /// contents) or the ones turned to it, then the rim.
  void glassBox(
    _V c,
    double size, {
    required bool front,
    required Color fill,
    required Color edge,
  }) {
    final h = _V(size / 2, size / 2, size / 2);
    for (final face in _boxFaces) {
      final n = face.normal;
      if (n.y > 0) continue; // open top
      final mid = c + _V(n.x * h.x, n.y * h.y, n.z * h.z);
      if ((n.dot(cam.eye - mid) > 0) != front) continue;
      final path = pens.path;
      _facePath(path, c, h, face);
      canvas.drawPath(path, pens.fill..color = fill);
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 1
          ..color = edge,
      );
    }
    if (front) {
      _facePath(pens.path, c, h, _boxFaces[2]);
      canvas.drawPath(
        pens.path,
        pens.stroke
          ..strokeWidth = 1.4
          ..color = edge,
      );
    }
  }

  /// Projected outline of an upright frustum (bottom radius [rb], top [rt],
  /// height [h]) standing on [bottom]: side plus the top ellipse.
  void frustumPath(Path path, _V bottom, double rb, double rt, double h) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(cam.oval(bottom, rb), math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(cam.oval(top, rt), 0, -math.pi, false)
      ..close();
  }

  /// A solid upright cylinder / frustum (bases, pads) with its top cap.
  void frustum(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 1,
  }) {
    frustumPath(pens.path, bottom, rb, rt, h);
    canvas.drawPath(
      pens.path,
      pens.fill..color = _lit(color, const _V(0, 0, 1), opacity: opacity),
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
        ..color = labShade(color, -0.4).withValues(alpha: 0.6 * opacity),
    );
  }

  /// The far half of an open glass cup: its outline filled faintly (both
  /// walls are seen through each other).
  void cupBack(_V bottom, double rb, double rt, double h, Color fill) {
    frustumPath(pens.path, bottom, rb, rt, h);
    canvas.drawPath(pens.path, pens.fill..color = fill);
  }

  /// The near half of an open glass cup: a faint front pane, its side
  /// lines, the front of its base, the rim and a highlight.
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
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(cam.oval(top, rt), 0, math.pi, false)
      ..close();
    canvas.drawPath(path, pens.fill..color = fill);
    final outline = pens.aux
      ..reset()
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
    canvas.drawOval(
      cam.oval(top, rt),
      pens.stroke
        ..strokeWidth = 1.4
        ..color = edge,
    );
    // Glass highlight on the left.
    canvas.drawLine(
      Offset(pt.dx - wt * 0.62, pt.dy + 4),
      Offset(pb.dx - wb * 0.62, pb.dy - 2),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.12)
        ..color = _Colors.white.withValues(alpha: 0.22),
    );
  }

  /// Water standing [h] high on [bottom] in a cup (radius [rb] at the floor,
  /// [rt] at the surface): the body and its lighter surface.
  void liquid(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 0.75,
  }) {
    if (h <= 0.01) return;
    frustumPath(pens.path, bottom, rb, rt, h);
    canvas.drawPath(
      pens.path,
      pens.fill..color = _lit(color, const _V(0, 0, 1), opacity: opacity),
    );
    canvas.drawOval(
      cam.oval(bottom + _V(0, h, 0), rt),
      pens.fill..color = labShade(color, 0.25).withValues(alpha: opacity),
    );
  }

  /// Soft blurred shadow of a round footprint of [radius] on the desk.
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

/// Paints the HTML Three.js scene of the current scenario: the desk, S1 the
/// ice cube and the three containers, S2 the balance, the tumbler, the
/// pitcher, the ice tray and the marker; then the labels and the balance's
/// display.
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

  /// Glass panes (white at 0.25 in the HTML; two panes overlap) and edges.
  Color get _glassFill => isDark
      ? _Colors.glass.withValues(alpha: 0.10)
      : _Colors.slate400.withValues(alpha: 0.12);
  Color get _glassEdge => isDark
      ? _Colors.glassEdge.withValues(alpha: 0.55)
      : _Colors.slate500.withValues(alpha: 0.75);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.cam, _pens);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneBg : _Colors.sceneBgLight,
    );
    g.box(_deskCenter, _deskSize, _Colors.wood, edge: 0);

    final active = s.active;
    final glow = active == null
        ? 0.0
        : _pulseMax * (math.sin(s.time * _pulseRate) + 1) / 2;
    for (final b in s.bodies) {
      if (b.item == _Item.ice && (s.iceIn != null || s.iceGone)) continue;
      g.shadow(b.pos, _shadowRadius(b.item));
    }
    // Far to near; whatever is held or moving on top.
    final order = cache.order..clear();
    for (final b in s.bodies) {
      if (b.item == _Item.ice && (s.iceIn != null || s.iceGone)) continue;
      order.add(b);
    }
    order.sort((a, b) {
      final la = _layer(a), lb = _layer(b);
      if (la != lb) return la.compareTo(lb);
      return s.cam.depth(b.pos).compareTo(s.cam.depth(a.pos));
    });
    for (final b in order) {
      final gl = b.item == active ? glow : (b.held ? _pulseMax * 0.5 : 0.0);
      switch (b.item) {
        case _Item.ice:
          _paintIce(g, b.pos, s.iceSide, gl);
        case _Item.square:
          _paintSquare(g, b, gl);
        case _Item.round:
          _paintBowl(g, b, gl);
        case _Item.cup:
          _paintCup(g, b, gl);
        case _Item.glass:
          _paintGlass(g, b, gl);
        case _Item.balance:
          _paintBalance(g, b);
        case _Item.pitcher:
          _paintPitcher(g, b, gl);
        case _Item.tray:
          _paintTray(g, b, gl);
        case _Item.marker:
          _paintMarker(g, b, gl);
      }
    }
    _paintStreams(g);
    _paintTexts(canvas);
  }

  int _layer(_Body b) => b.held || b.moving ? 1 : 0;

  double _shadowRadius(_Item i) => switch (i) {
    _Item.ice => _iceSide * 0.6,
    _Item.square => _boxSize * 0.55,
    _Item.round => _bowlBaseBottom,
    _Item.cup => _cupBottom,
    _Item.glass => _glassBottom,
    _Item.balance => 6.5,
    _Item.pitcher => _pitcherRadius,
    _Item.tray => 3.3,
    _Item.marker => 2.5,
  };

  /// The pulsing cyan glow behind the object to drag (HTML emissive
  /// highlight).
  void _glow(_Gfx g, Rect bounds, double amount) {
    if (amount <= 0) return;
    g.canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.inflate(6), const Radius.circular(14)),
      _pens.glow..color = _Colors.highlight.withValues(alpha: amount * 1.2),
    );
  }

  Rect _bounds(_Gfx g, _Body b) => _boxBounds(g.cam, b.boxCenter, b.item.half);

  // --------------------------------------------------------- scenario 1

  void _paintIce(_Gfx g, _V pos, double side, double glow) {
    if (side <= 0.02) return;
    _glow(g, _boxBounds(g.cam, pos, _V(side / 2, side / 2, side / 2)), glow);
    g.box(
      pos,
      _V(side, side, side),
      _tint(_Colors.ice, glow),
      opacity: 0.85,
      edge: 0.9,
      edgeColor: _Colors.iceEdge,
    );
  }

  /// Ice standing in water up to [waterTop]: the cube, then its part below
  /// the surface seen through the water, so a cube melting in its own water
  /// stays visible.
  void _paintWetIce(_Gfx g, _V pos, double side, double waterTop, double glow) {
    _paintIce(g, pos, side, glow);
    final bottom = pos.y - side / 2;
    final top = math.min(pos.y + side / 2, waterTop);
    if (side <= 0.02 || top <= bottom + 0.01) return;
    g.box(
      _V(pos.x, (bottom + top) / 2, pos.z),
      _V(side * _wetSkin, top - bottom, side * _wetSkin),
      _Colors.water,
      opacity: _underWater,
      edge: 0,
    );
  }

  /// The ice inside container [c], if it is there (drawn after the water).
  void _iceInside(_Gfx g, _Item c) {
    final s = scene;
    if (s.iceIn != c || s.iceGone) return;
    final ice = s.body(_Item.ice);
    _paintWetIce(
      g,
      ice.pos,
      s.iceSide,
      (s.water[c] ?? 0) > 0.01 ? s.waterTop(s.body(c)) : -double.infinity,
      s.active == _Item.ice
          ? _pulseMax * (math.sin(s.time * _pulseRate) + 1) / 2
          : 0,
    );
  }

  /// `createHollowBox(7, 7, 7)`: back panes, the ice or the water, front
  /// panes.
  void _paintSquare(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final c = b.pos;
    canvas.save();
    _tiltAbout(canvas, g.cam.p(c), b.tilt);
    _glow(g, _bounds(g, b), glow);
    final fill = _tint(_glassFill, glow);
    g.glassBox(c, _boxSize, front: false, fill: fill, edge: _glassEdge);
    final v = s.water[_Item.square] ?? 0;
    if (v > 0.01) {
      final h = _squareLevel(v);
      final floor = s.floorOf(b);
      g.box(
        _V(c.x, floor + h / 2, c.z),
        _V(_boxInner, h, _boxInner),
        _Colors.water,
        opacity: 0.75,
        edge: 0.4,
        edgeColor: labShade(_Colors.water, 0.4),
      );
    }
    _iceInside(g, _Item.square);
    g.glassBox(c, _boxSize, front: true, fill: fill, edge: _glassEdge);
    canvas.restore();
  }

  /// The fish bowl: glass sphere open at the top on a round base; the ice
  /// or the water inside.
  void _paintBowl(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final c = b.pos;
    final pc = cam.p(c);
    final r = _bowlRadius * cam.scaleAt(c);
    final rimC = c + const _V(0, _bowlRim, 0);
    final rimR = math.sqrt(_bowlRadius * _bowlRadius - _bowlRim * _bowlRim);
    final rim = cam.oval(rimC, rimR);
    final below = Rect.fromLTRB(
      pc.dx - r * 1.5,
      rim.center.dy,
      pc.dx + r * 1.5,
      pc.dy + r * 1.5,
    );
    final fill = _tint(_glassFill, glow);
    _glow(g, _bounds(g, b), glow);
    // Base: CylinderGeometry(2, 2.5, 0.5) on the desk.
    g.frustum(
      _V(c.x, 0, c.z),
      _bowlBaseBottom,
      _bowlBaseTop,
      _bowlBaseHeight,
      _Colors.glass,
      opacity: isDark ? 0.22 : 0.4,
    );
    canvas.save();
    canvas.clipRect(below);
    canvas.drawCircle(pc, r, _pens.fill..color = fill);
    canvas.restore();
    final v = s.water[_Item.round] ?? 0;
    if (v > 0.01) {
      final h = _bowlLevel(v);
      final y = -_bowlInner + h;
      final surface = c + _V(0, y, 0);
      final rho = math.sqrt(math.max(0.0, _bowlInner * _bowlInner - y * y));
      final oval = cam.oval(surface, rho);
      final ri = _bowlInner * cam.scaleAt(c);
      canvas.save();
      canvas.clipPath(
        _pens.aux
          ..reset()
          ..addOval(Rect.fromCircle(center: pc, radius: ri)),
      );
      canvas.clipRect(
        Rect.fromLTRB(pc.dx - ri, oval.center.dy, pc.dx + ri, pc.dy + ri),
      );
      canvas.drawCircle(
        pc,
        ri,
        _pens.fill
          ..color = _lit(_Colors.water, const _V(0, 0, 1), opacity: 0.75),
      );
      canvas.restore();
      canvas.drawOval(
        oval,
        _pens.fill
          ..color = labShade(_Colors.water, 0.25).withValues(alpha: 0.75),
      );
    }
    _iceInside(g, _Item.round);
    canvas.save();
    canvas.clipRect(below);
    canvas.drawCircle(pc, r, _pens.fill..color = fill);
    canvas.drawCircle(
      pc,
      r,
      _pens.stroke
        ..strokeWidth = 1.3
        ..color = _glassEdge,
    );
    canvas.drawArc(
      Rect.fromCircle(center: pc, radius: r * 0.8),
      math.pi * 1.05,
      math.pi * 0.35,
      false,
      _pens.line
        ..strokeWidth = math.max(1.0, r * 0.08)
        ..color = _Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
    canvas.drawOval(
      rim,
      _pens.stroke
        ..strokeWidth = 1.4
        ..color = _glassEdge,
    );
  }

  /// The Scenario 1 tumbler with the ice or the water inside.
  void _paintCup(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final c = b.pos;
    final bottom = c - const _V(0, _cupHeight / 2, 0);
    canvas.save();
    _tiltAbout(canvas, g.cam.p(c), b.tilt);
    _glow(g, _bounds(g, b), glow);
    final fill = _tint(_glassFill, glow);
    g.frustum(
      bottom,
      _cupBottom,
      _cupBottom,
      _cupBase,
      _Colors.glass,
      opacity: isDark ? 0.18 : 0.35,
    );
    g.cupBack(bottom, _cupBottom, _cupTop, _cupHeight, fill);
    final v = s.water[_Item.cup] ?? 0;
    if (v > 0.01) {
      final h = _cupLevel(v);
      const height = _cupHeight - _cupBase;
      g.liquid(
        bottom + const _V(0, _cupBase, 0),
        _cupInnerBottom,
        _cupInnerBottom + (_cupInnerTop - _cupInnerBottom) * h / height,
        h,
        _Colors.water,
      );
    }
    _iceInside(g, _Item.cup);
    g.cupFront(bottom, _cupBottom, _cupTop, _cupHeight, fill, _glassEdge);
    canvas.restore();
  }

  /// Water falling from the tipped container's lip into the container below
  /// (added: the HTML only changed the water levels).
  void _paintStreams(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    if (s.scenario == 0 && s.pourFrom != null && s.pourTo != null) {
      final from = s.body(s.pourFrom!);
      final to = s.body(s.pourTo!);
      final half = from.item == _Item.cup ? _cupHeight / 2 : _boxSize / 2;
      final rim = from.item == _Item.cup ? _cupTop : _boxSize / 2;
      final surface = to.item == _Item.round
          ? to.pos + _V(0, -_bowlInner + _bowlLevel(s.water[to.item] ?? 0), 0)
          : to.pos.withY(s.waterTop(to));
      _stream(g, from, half, rim, cam.p(surface), cam.scaleAt(surface));
    }
    if (s.scenario == 1 && s.pitcherPouring) {
      final p = s.body(_Item.pitcher);
      final surface = s.body(_Item.glass).pos.withY(s.glassWaterTop);
      _stream(
        g,
        p,
        _pitcherHeight / 2,
        _pitcherRadius,
        cam.p(surface),
        cam.scaleAt(surface),
      );
    }
  }

  void _stream(
    _Gfx g,
    _Body from,
    double half,
    double rim,
    Offset surface,
    double scale,
  ) {
    final cam = g.cam;
    final c = cam.p(from.pos);
    final side = from.tilt > 0 ? -1.0 : 1.0;
    final lip =
        c + _turn(cam.p(from.pos + _V(side * rim, half, 0)) - c, from.tilt);
    final path = _pens.aux
      ..reset()
      ..moveTo(lip.dx, lip.dy)
      ..quadraticBezierTo(surface.dx, lip.dy, surface.dx, surface.dy);
    g.canvas.drawPath(
      path,
      _pens.line
        ..strokeWidth = math.max(1.5, 0.45 * scale)
        ..color = _Colors.water.withValues(alpha: 0.85),
    );
  }

  // --------------------------------------------------------- scenario 2

  /// The Scenario 2 tumbler: droplets and the marker line round it, the
  /// water and the floating ice inside.
  void _paintGlass(_Gfx g, _Body b, double glow) {
    final s = scene;
    final c = b.pos;
    final bottom = c - const _V(0, _glassHalf, 0);
    final body = bottom + const _V(0, 0.1, 0);
    final pane = s.cold
        ? _Colors.frost.withValues(alpha: isDark ? 0.2 : 0.35)
        : _glassFill;
    final fill = _tint(pane, glow);
    _glow(g, _bounds(g, b), glow);
    g.frustum(
      bottom,
      _glassBottom,
      _glassBottom,
      _glassBase,
      _Colors.glass,
      opacity: isDark ? 0.18 : 0.35,
    );
    g.cupBack(body, _glassBottom, _glassTop, _glassHeight, fill);
    _paintDrops(g, c, front: false);
    _paintLine(g, front: false);
    if (s.fill > 0.001) {
      final h = _glassInnerHeight * s.fill;
      g.liquid(
        bottom + const _V(0, _glassBase, 0),
        _glassInnerBottom,
        _glassInnerBottom +
            (_glassInnerTop - _glassInnerBottom) * h / _glassInnerHeight,
        h,
        _Colors.water,
      );
    }
    if (s.cubesIn) {
      final top = s.glassWaterTop;
      final side = _cubeSide * s.cubeScale;
      final k = Curves.easeIn.transform(s.cubeFall);
      for (var i = 0; i < _floatCubes.length; i++) {
        final start = s.cubeFrom + _trayCubes[i];
        final end = c.withY(top + side * (0.5 - _iceDraft)) + _floatCubes[i];
        _paintWetIce(g, _V.lerp(start, end, k), side, top, 0);
      }
    }
    g.cupFront(body, _glassBottom, _glassTop, _glassHeight, fill, _glassEdge);
    _paintLine(g, front: true);
    _paintDrops(g, c, front: true);
  }

  /// HTML `dropletGroup`: drops on the glass growing with the time-lapse.
  void _paintDrops(_Gfx g, _V c, {required bool front}) {
    final s = scene;
    if (s.slider <= 0 || s.scenario != 1) return;
    final cam = g.cam;
    for (final d in _drops) {
      final facing = math.sin(d.angle) > 0;
      if (facing != front) continue;
      final scale = s.slider * d.maxScale;
      if (scale <= 0.05) continue;
      final r = 3.25 + d.h / 16 + 0.05;
      final at = c + _V(math.cos(d.angle) * r, d.h, math.sin(d.angle) * r);
      final p = cam.p(at);
      final radius = _dropletRadius * scale * _dropletBoost * cam.scaleAt(at);
      g.canvas.drawCircle(
        p,
        radius,
        _pens.fill
          ..color = _Colors.water.withValues(alpha: front ? 0.85 : 0.35),
      );
      if (front) {
        g.canvas.drawCircle(
          p.translate(-radius * 0.35, -radius * 0.35),
          radius * 0.35,
          _pens.fill..color = _Colors.white.withValues(alpha: 0.7),
        );
      }
    }
  }

  /// The marker line round the glass at the water level: the far half seen
  /// through the glass, the near half in front; it spreads from the marker's
  /// tip while it is drawn.
  void _paintLine(_Gfx g, {required bool front}) {
    final s = scene;
    if (!s.lineDrawn || s.lineSweep <= 0) return;
    final c = s.body(_Item.glass).pos;
    final at = c.withY(s.lineY);
    final oval = g.cam.oval(at, s.glassRadiusAt(s.lineY) + 0.04);
    final sweep = (front ? 1 : -1) * math.pi * s.lineSweep;
    final width = front ? _lineFront : _lineBack;
    g.canvas.drawArc(
      oval,
      0,
      sweep,
      false,
      _pens.line
        ..strokeWidth = width + _lineEdge
        ..color = _Colors.markerEdge.withValues(alpha: front ? 0.95 : 0.45),
    );
    g.canvas.drawArc(
      oval,
      0,
      sweep,
      false,
      _pens.line
        ..strokeWidth = width
        ..color = _Colors.markerLine.withValues(alpha: front ? 1 : 0.55),
    );
  }

  /// Marker line widths (design px): near half, far half, dark edge.
  static const double _lineFront = 2.6;
  static const double _lineBack = 1.6;
  static const double _lineEdge = 2.2;

  /// The digital balance: body, pan and display screen.
  void _paintBalance(_Gfx g, _Body b) {
    final c = b.pos;
    g.box(c, _bodySize, _Colors.plastic, edge: 0.4);
    g.frustum(
      _V(c.x, _padBottom, c.z),
      _padRadius,
      _padRadius,
      _padHeight,
      _Colors.pad,
    );
    final cam = g.cam;
    final z = c.z + _bodySize.z / 2 + 0.01;
    final path = _pens.path
      ..reset()
      ..moveTo(
        cam.p(_V(c.x - 2.5, 0.08, z)).dx,
        cam.p(_V(c.x - 2.5, 0.08, z)).dy,
      )
      ..lineTo(
        cam.p(_V(c.x + 2.5, 0.08, z)).dx,
        cam.p(_V(c.x + 2.5, 0.08, z)).dy,
      )
      ..lineTo(
        cam.p(_V(c.x + 2.5, 0.92, z)).dx,
        cam.p(_V(c.x + 2.5, 0.92, z)).dy,
      )
      ..lineTo(
        cam.p(_V(c.x - 2.5, 0.92, z)).dx,
        cam.p(_V(c.x - 2.5, 0.92, z)).dy,
      )
      ..close();
    g.canvas.drawPath(path, _pens.fill..color = _Colors.screen);
  }

  /// The water pitcher: handle on its left, glass body, water.
  void _paintPitcher(_Gfx g, _Body b, double glow) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final c = b.pos;
    final bottom = c - const _V(0, _pitcherHeight / 2, 0);
    canvas.save();
    _tiltAbout(canvas, cam.p(c), b.tilt);
    _glow(g, _bounds(g, b), glow);
    final fill = _tint(_glassFill, glow);
    // Half-torus handle (radius 3, tube 0.5) from (-4, ±3) out to -7.
    final a = cam.p(c + const _V(-4, 3, 0));
    final e = cam.p(c + const _V(-4, -3, 0));
    final ctl = cam.p(c + const _V(-10, 0, 0));
    canvas.drawPath(
      _pens.aux
        ..reset()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctl.dx, ctl.dy, e.dx, e.dy),
      _pens.line
        ..strokeWidth = math.max(2.0, 1.0 * cam.scaleAt(c))
        ..color = _tint(_glassEdge, glow),
    );
    g.frustum(
      bottom,
      _pitcherRadius,
      _pitcherRadius,
      _pitcherBase,
      _Colors.glass,
      opacity: isDark ? 0.18 : 0.35,
    );
    g.cupBack(bottom, _pitcherRadius, _pitcherRadius, _pitcherHeight, fill);
    g.liquid(
      bottom + const _V(0, _pitcherBase, 0),
      _pitcherWaterRadius,
      _pitcherWaterRadius,
      _pitcherWaterHeight * s.pitcherWater,
      _Colors.water,
    );
    g.cupFront(
      bottom,
      _pitcherRadius,
      _pitcherRadius,
      _pitcherHeight,
      fill,
      _glassEdge,
    );
    canvas.restore();
  }

  /// The ice tray and, until they go into the tumbler, its three cubes.
  void _paintTray(_Gfx g, _Body b, double glow) {
    final s = scene;
    _glow(g, _bounds(g, b), glow);
    g.box(b.pos, _traySize, _tint(_Colors.tray, glow), edge: 0.5);
    if (s.cubesIn) return;
    // Back cubes first.
    for (final i in const [0, 2, 1]) {
      _paintIce(g, b.pos + _trayCubes[i], _cubeSide, glow);
    }
  }

  /// The marker pen lying along x: white body, blue cap on its left end.
  void _paintMarker(_Gfx g, _Body b, double glow) {
    final cam = g.cam;
    final c = b.pos;
    final k = cam.scaleAt(c);
    _glow(g, _bounds(g, b), glow);
    final l = cam.p(c + const _V(-3, 0, 0));
    final r = cam.p(c + const _V(3, 0, 0));
    final w = 2 * _markerRadius * k;
    g.canvas.drawLine(
      l,
      r,
      _pens.line
        ..strokeWidth = w + 1.6
        ..color = _Colors.slate500,
    );
    g.canvas.drawLine(
      l,
      r,
      _pens.line
        ..strokeWidth = w
        ..color = _tint(_Colors.markerBody, glow),
    );
    g.canvas.drawLine(
      cam.p(c + const _V(-4, 0, 0)),
      cam.p(c + const _V(-2, 0, 0)),
      _pens.line
        ..strokeWidth = 2 * _markerCapRadius * k
        ..color = _tint(_Colors.markerCap, glow),
    );
  }

  // -------------------------------------------------------------- texts

  void _paintTexts(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    // The balance's display is an instrument, shown with or without labels.
    Rect? readout;
    if (s.scenario == 1) {
      readout = _readout(
        canvas,
        cam.p(_readoutAt),
        s.reading.toStringAsFixed(2),
      );
    }
    if (!showLabels) return;
    final size = cache.labelSize;
    if (s.scenario == 0) {
      final square = s.body(_Item.square);
      final round = s.body(_Item.round);
      final spacing =
          (cam.p(round.item.home) - cam.p(square.item.home)).distance;
      for (final item in const [_Item.square, _Item.round, _Item.cup]) {
        final b = s.body(item);
        if (b.held || b.moving) continue;
        _stack(
          canvas,
          cam.p(_bottomFront(item, b.pos)),
          [_t(item.labelKey)],
          up: false,
          maxWidth: math.min(size * _chipWrap, spacing - _labelGap),
          fit: spacing - _labelGap,
        );
        final iceHere = s.iceIn == item && !s.iceGone;
        _stack(
          canvas,
          cam.p(b.pos + _V(0, item.half.y, 0)),
          [
            if (iceHere && !s.melted) _t('lbl_ice_cube'),
            if (iceHere && s.shapeFixed) _t('lbl_shape_fixed'),
            if (iceHere && s.solidLabel) _t('lbl_state_solid'),
            if (item == _Item.cup && s.liquidLabel) _t('lbl_state_liquid'),
            if (s.takesShape == item) _t('lbl_shape_takes'),
          ],
          up: true,
          maxWidth: size * _chipWrap * 1.4,
        );
      }
      final ice = s.body(_Item.ice);
      if (s.iceIn == null && !s.iceGone && !ice.moving) {
        _stack(
          canvas,
          cam.p(_bottomFront(_Item.ice, ice.pos)),
          [_t('lbl_ice_cube')],
          up: false,
          maxWidth: size * _chipWrap,
        );
      }
      return;
    }
    for (final b in s.bodies) {
      if (b.held || b.moving) continue;
      final at = switch (b.item) {
        _Item.pitcher => b.pos + const _V(0, _pitcherHeight / 2, 0),
        _Item.glass => b.pos + const _V(0, _glassHalf, 0),
        _ => null,
      };
      if (b.item == _Item.tray && s.cubesIn) continue;
      if (at != null) {
        _stack(
          canvas,
          cam.p(at),
          [_t(b.item.labelKey)],
          up: true,
          maxWidth: size * _chipWrap,
        );
      } else if (b.item == _Item.marker || b.item == _Item.tray) {
        // Below the object: above the tray it would cover the pitcher.
        _stack(
          canvas,
          cam.p(_bottomFront(b.item, b.pos)),
          [_t(b.item.labelKey)],
          up: false,
          maxWidth: size * _chipWrap,
        );
      }
    }
    if (readout != null) {
      _stack(
        canvas,
        Offset(readout.center.dx, readout.bottom),
        [_t('lbl_balance')],
        up: false,
        maxWidth: size * _chipWrap,
      );
    }
  }

  /// Label chips stacked away from [at] (upwards or downwards), the first
  /// one nearest to it.
  void _stack(
    Canvas canvas,
    Offset at,
    List<String> texts, {
    required bool up,
    double maxWidth = double.infinity,
    double fit = double.infinity,
  }) {
    final dir = up ? -1.0 : 1.0;
    var y = at.dy + dir * _labelGap;
    for (final text in texts) {
      final h = _chip(
        canvas,
        Offset(at.dx, y),
        text,
        up: up,
        maxWidth: maxWidth,
        fit: fit,
      );
      y += dir * (h + _labelGap);
    }
  }

  /// HTML `.label-3d` chip: glass panel, blue border, tag icon and bold
  /// text, with its bottom ([up]) or top edge on [at]. Lines wrap at
  /// [maxWidth]; a chip wider than [fit] is shrunk; chips stay left of the
  /// tool column. Returns its height.
  double _chip(
    Canvas canvas,
    Offset at,
    String text, {
    required bool up,
    double maxWidth = double.infinity,
    double fit = double.infinity,
  }) {
    final size = cache.labelSize;
    final tp = cache.text(
      isDark ? _Ink.chip : _Ink.chipLight,
      text,
      maxWidth: maxWidth,
    );
    final icon = cache.tag;
    final padX = size * 0.6, padY = size * 0.32, gap = size * 0.35;
    final w = icon.width + gap + tp.width + 2 * padX;
    final h = math.max(tp.height, icon.height) + 2 * padY;
    final shrink = w > fit && fit > 0 ? fit / w : 1.0;
    final sw = w * shrink, sh = h * shrink;
    final left = (at.dx - sw / 2)
        .clamp(4.0, math.max(4.0, labelRight - 4 - sw))
        .toDouble();
    final top = up ? at.dy - sh : at.dy;
    canvas.save();
    canvas.translate(left, top);
    canvas.scale(shrink);
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(size * 0.55),
    );
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.labelBg : _Colors.labelBgLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.labelBorder,
    );
    icon.paint(canvas, Offset(padX, (h - icon.height) / 2));
    tp.paint(canvas, Offset(padX + icon.width + gap, (h - tp.height) / 2));
    canvas.restore();
    return sh;
  }

  /// HTML `#scale-overlay`: green digits and a grey "g" on black. Returns
  /// its rect.
  Rect _readout(Canvas canvas, Offset at, String digits) {
    final size = cache.labelSize;
    final tp = cache.text(_Ink.readout, digits);
    final unit = cache.text(_Ink.unit, _t('unit_g'));
    final padX = size * 0.6, padY = size * 0.25, gap = size * 0.3;
    final w = tp.width + gap + unit.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final rect = Rect.fromCenter(center: at, width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.3));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.readoutBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 2
        ..color = _Colors.readoutBorder,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
    unit.paint(
      canvas,
      Offset(
        rect.left + padX + tp.width + gap,
        rect.top + padY + tp.height - unit.height,
      ),
    );
    return rect;
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
