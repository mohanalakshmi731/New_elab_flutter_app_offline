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

/// Class 6 Science • Chapter 8 • Activity 6
/// The Water Cycle and Cloud Formation.
///
/// Native Flutter port of
/// `Cl6S-Ch8-A6-The_Water_Cycle_and_Cloud_Formation.html`.
///
/// Scenario 1 (The Cloud in a Bottle Experiment, 8 steps): a plastic bottle
/// is put on the workbench, a cup of water is poured into it and it is
/// capped. Squeezing and releasing it makes no cloud. Smoke from burning
/// paper is let into the bottle, it is capped again, and now a hazy cloud
/// forms each time the squeezed bottle is released: water vapour condenses
/// on the smoke particles.
///
/// Scenario 2 (Build the Water Cycle, 5 steps): the Sun goes into the Heat
/// Source slot (evaporation from the ocean), dust particles into the rising
/// vapour (a cloud condenses), cool air onto the cloud (it turns grey and
/// rains) and a river segment into the riverbed (the water flows back to
/// the ocean); the cycle then runs on its own.
///
/// The Three.js scenes are redrawn by a CustomPainter through a perspective
/// projection of the HTML cameras (fov 45°); objects are dragged on a plane
/// facing the camera, as the HTML `dragPlane` does.
class Ch8A6TheWaterCycleAndCloudFormationPage extends StatefulWidget {
  const Ch8A6TheWaterCycleAndCloudFormationPage({super.key});

  @override
  State<Ch8A6TheWaterCycleAndCloudFormationPage> createState() =>
      _WaterCycleLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with the Web Audio
/// API; they map to the closest bundled file: 'click' (buttons, the match
/// lighting the paper, dust and cool air dropped) -> click, 'click' when an
/// object is picked up -> pickup, 'pour' (the cup poured, the river laid)
/// and 'thud' (the bottle put on the bench; never defined in the HTML, so
/// silent there) -> drop, 'snap' (the cap closing the bottle) -> pop, 'ding'
/// -> correct (the Sun in its slot) or success (the summary). A drop away
/// from the target, silent in the HTML, now plays wrong with its hint.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`,
/// pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// HTML 'click'.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML 'ding' when the Sun reaches its slot; the shell's right tone.
  correct('audio/class6/science/correct.mp3'),

  /// An object dropped away from its target (added hint toast).
  wrong('audio/class6/science/error.mp3'),

  /// HTML 'ding' with the summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'pour' and 'thud'.
  drop('audio/class6/science/drop.mp3'),

  /// HTML 'click' when an object is picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML 'snap': the cap closes the bottle.
  pop('audio/class6/science/pop.mp3');

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
  static const Color white = Color(0xFFFFFFFF);
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
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue950 = Color(0xFF172554);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// `materials.tableMat` 0x64748b and `shelfMat` 0x94a3b8.
  static const Color bench = slate500;
  static const Color shelf = slate400;

  /// `plasticMat` 0xbae6fd (opacity 0.25), `glassMat` 0xe0f2fe (0.3).
  static const Color plastic = Color(0xFFBAE6FD);
  static const Color glass = Color(0xFFE0F2FE);

  /// `waterMat` 0x38bdf8 (opacity 0.8).
  static const Color water = Color(0xFF38BDF8);

  /// `capMat` 0x1d4ed8.
  static const Color cap = Color(0xFF1D4ED8);

  /// `paperMat` 0xf8fafc, burnt to 0x555555.
  static const Color paper = slate50;
  static const Color paperBurnt = Color(0xFF555555);

  /// `matchMat` 0xfcd34d stick, `matchTip` 0xef4444.
  static const Color matchStick = Color(0xFFFCD34D);
  static const Color matchTip = Color(0xFFEF4444);

  /// Match and paper flame (added: the HTML match is "lit" only in words).
  static const Color flame = Color(0xFFF97316);
  static const Color flameCore = Color(0xFFFACC15);

  /// `smokeMat` 0x333333 (opacity 0.7). On the dark scene that colour is
  /// lost against the background, so the dark theme draws smoke light grey.
  static const Color smoke = Color(0xFF333333);
  static const Color smokeOnDark = slate300;

  /// `cloudInnerMat` white (opacity 0.8).
  static const Color cloud = white;

  /// `glowMat` 0x3b82f6 (opacity 0.4): drop zones.
  static const Color glow = Color(0x663B82F6);

  /// `update3DHighlight` pulse colour 0x38bdf8.
  static const Color highlight = water;

  /// Scenario 2: `deepWaterMat` 0x0284c7 (0.8), `dirtMat` 0x5c4033,
  /// `grassMat` 0x4ade80.
  static const Color ocean = Color(0xFF0284C7);
  static const Color dirt = Color(0xFF5C4033);
  static const Color grass = Color(0xFF4ADE80);

  /// `sunCore` 0xffea00, `sunRay` 0xffb700.
  static const Color sunCore = Color(0xFFFFEA00);
  static const Color sunRay = Color(0xFFFFB700);

  /// Dust tile 0x334155 (0.8) with white specks; snow tile 0xbae6fd (0.6)
  /// with a white snowflake.
  static const Color dustTile = Color(0xCC334155);
  static const Color snowTile = Color(0x99BAE6FD);

  /// The rain cloud's colour (`to(new THREE.Color(0x556677))`).
  static const Color rainCloud = Color(0xFF556677);

  /// Rising vapour streaks (`glassMat`): faint in the dark scene, a little
  /// stronger on the light background.
  static const Color vapourDark = Color(0x80E0F2FE);
  static const Color vapourLight = Color(0x997DD3FC);

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x4D000000);

  /// `.label-3d` glass chips: dark `rgba(15,23,42,0.92)` / light white,
  /// `border-blue-400`; action labels `bg-emerald-100 text-emerald-800
  /// border-emerald-400`.
  static const Color labelDark = Color(0xEB0F172A);
  static const Color labelLight = Color(0xF2FFFFFF);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML's brand colour is blue (Enter Lab, the sidebar tab,
/// the HUD border): blue-400 on the dark panels, blue-600 on the light ones.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue400, // dark:text-blue-400
    onAccent: _Colors.slate950, // badge text-slate-950
    primary: _Colors.blue600, // summary button from-blue-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.blue950, // header bg-blue-600 (dark enough for text)
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // subtitle text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600, // text-blue-600
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.blue50,
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
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// say exactly what to do on a touch screen ("tap" instead of "click"; the
// squeeze is a press and hold on the bottle or a tap on 'Squeeze Bottle').
// The HTML's Hindi steps were shortened versions of the English ones; they
// now say the same as the English. Toasts, the slot label, the observation
// list and the scene descriptions are added (the HTML had no toasts).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Water Cycle and Cloud Formation',
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt': 'Scenario 1: The Cloud in a Bottle Experiment',
    'scen_2_opt': 'Scenario 2: Build the Water Cycle',
    's1_desc':
        'To investigate the role of dust particles in the formation of clouds by recreating the experiment from Activity 8.10.',
    's2_desc':
        "To construct a working model of the Earth's water cycle by correctly sequencing the processes of evaporation, condensation, and precipitation.",
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Setup',
    's1_a1':
        'DRAG the plastic bottle from the shelf and DROP it onto the glowing ring on the workbench.',
    's1_o1':
        'The plastic bottle is now centered on the workbench, ready for the experiment.',
    's1_c2': 'Add Moisture',
    's1_a2':
        'DRAG the cup of water to the bottle and DROP it there to POUR the water in.',
    's1_o2':
        'The bottle is now filled with about one cup of water at the bottom.',
    's1_c3': 'Seal System',
    's1_a3':
        'DRAG the bottle cap and DROP it onto the bottle to close it tightly.',
    's1_o3': 'The bottle is sealed.',
    's1_c4': 'Test Pressure',
    's1_a4':
        "Squeeze the bottle at least 3 times: PRESS and HOLD the bottle, then let go (or tap 'Squeeze Bottle'). Observe the space above the water.",
    's1_o4':
        'The bottle deforms, but no cloud appears. The water vapor has nothing to condense on.',
    's1_c5': 'Add Particles',
    's1_a5':
        'DRAG the cap off the bottle onto the glowing ring. Then DRAG the lit match to the paper in the dish to light it. Then quickly DRAG the smoking dish to the mouth of the bottle.',
    's1_o5':
        'A small amount of visible smoke (representing dust particles) enters the bottle.',
    's1_c6': 'Reseal System',
    's1_a6':
        'DRAG the bottle cap and DROP it back onto the bottle to seal it again.',
    's1_o6': 'The bottle, now containing water and smoke particles, is sealed.',
    's1_c7': 'Observe Condensation',
    's1_a7':
        "Squeeze the bottle at least 3 times again: PRESS and HOLD the bottle, then let go (or tap 'Squeeze Bottle'). Watch the space inside carefully.",
    's1_o7':
        'A visible, hazy cloud forms inside the bottle each time the pressure is released.',
    's1_c8': 'Conclusion',
    's1_a8':
        "Review your observations, then tap 'Finish Observation' to see the experiment summary.",
    's1_o8':
        "You've made a cloud! Water vapor condensed around smoke particles.",
    // Scenario 2 steps.
    's2_c1': 'Evaporation',
    's2_a1':
        "DRAG the Sun from the sky and DROP it into the glowing 'Heat Source' slot to start the cycle.",
    // The HTML also named a lake; the scene has only the ocean.
    's2_o1':
        'The sun brightens, and water from the ocean begins to evaporate as invisible vapor.',
    's2_c2': 'Condensation',
    's2_a2':
        "DRAG the 'Dust Particles' icon and DROP it into the glowing area with the rising water vapor.",
    's2_o2':
        'The invisible water vapor condenses around the dust particles to form a visible cloud.',
    's2_c3': 'Precipitation',
    's2_a3':
        "DRAG the 'Cool Air' snowflake and DROP it onto the cloud to trigger rain.",
    's2_o3': 'The cloud turns grey, becomes heavy, and releases rain.',
    's2_c4': 'Collection',
    's2_a4':
        'The rain forms a river. CONNECT the river back to the ocean: DRAG the river segment and DROP it into the glowing riverbed.',
    's2_o4':
        'The water flows from the land, through the river, and back into the ocean.',
    's2_c5': 'Cycle Complete',
    's2_a5':
        "Observe the continuous animation of the water cycle, then tap 'Finish Observation'.",
    's2_o5':
        'The cycle runs continuously: Evaporation → Condensation → Precipitation → Collection.',
    // HTML `hud` lines (the canvas "Current Task").
    's1_hud_1':
        'Step 1: DRAG the plastic bottle from the shelf and DROP it onto the glowing workbench area.',
    's1_hud_2': 'Step 2: DRAG the cup of water and POUR it into the bottle.',
    's1_hud_3':
        'Step 3: DRAG the bottle cap and DROP it onto the bottle to close it tightly.',
    's1_hud_4':
        "Step 4: PRESS and HOLD the bottle (or tap 'Squeeze Bottle'), then let go, at least 3 times. Observe the space inside.",
    's1_hud_5':
        'Step 5: DRAG the cap off. DRAG the lit match to the paper in the dish. Then DRAG the smoking dish to the bottle mouth.',
    's1_hud_6': 'Step 6: DRAG the bottle cap and DROP it back to seal it.',
    's1_hud_7':
        "Step 7: PRESS and HOLD the bottle (or tap 'Squeeze Bottle') again, at least 3 times. Watch carefully!",
    's1_hud_8':
        "Step 8: Observation complete. Review your observations and tap 'Finish Observation'.",
    's2_hud_1':
        "Step 1: DRAG the Sun icon and DROP it into the 'Heat Source' slot in the sky.",
    's2_hud_2':
        "Step 2: DRAG the 'Dust Particles' icon and DROP it into the area with the rising water vapor.",
    's2_hud_3':
        "Step 3: DRAG the 'Cool Air' (snowflake) icon onto the full cloud to trigger rain.",
    's2_hud_4':
        'Step 4: CONNECT the river. DRAG the river segment and drop it into the glowing riverbed.',
    's2_hud_5':
        "Step 5: The cycle is complete! Observe the continuous animation, then tap 'Finish Observation'.",
    // Buttons.
    'btn_squeeze': 'Squeeze Bottle',
    'btn_finish': 'Finish Observation',
    // Canvas labels (HTML `createStdLabel` / `createActionLabel`).
    'lbl_bottle': 'Plastic Bottle',
    'lbl_water_cup': 'Water Cup',
    'lbl_cap': 'Bottle Cap',
    'lbl_match': 'Matchstick',
    'lbl_paper': 'Paper in Dish',
    'lbl_sun': 'Sun (Heat Source)',
    'lbl_dust': 'Dust Particles',
    'lbl_snow': 'Cool Air',
    'lbl_river': 'River Segment',
    'lbl_evap': 'EVAPORATION',
    'lbl_cond': 'CONDENSATION',
    'lbl_precip': 'PRECIPITATION',
    'lbl_collect': 'COLLECTION',
    'lbl_slot': 'Heat Source',
    // Added: hints when an object is dropped away from its target (the
    // HTML sent it back without a word), and the two turns inside step 5.
    'e_bottle': 'Drop the plastic bottle on the glowing ring on the workbench.',
    'e_cup': 'Bring the cup of water over the bottle to pour it in.',
    'e_cap_on': 'Drop the cap on top of the bottle.',
    'e_cap_off': 'Put the cap down on the glowing ring on the workbench.',
    'e_match': 'Touch the lit match to the paper in the dish.',
    'e_dish': 'Hold the smoking dish at the mouth of the bottle.',
    'e_sun': "Drop the Sun into the glowing 'Heat Source' slot in the sky.",
    'e_dust':
        'Drop the dust particles into the glowing area of rising water vapor.',
    'e_snow': 'Drop the Cool Air onto the cloud.',
    'e_river': 'Drop the river segment into the glowing riverbed.',
    't_cap_off':
        'Cap removed. Now DRAG the lit match to the paper in the dish.',
    't_paper_lit':
        'The paper is smoking! Quickly DRAG the dish to the mouth of the bottle.',
    // Summary popup (HTML `summary-modal`).
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1':
        "You've made a cloud! Water vapor in the air condensed into tiny liquid droplets around the smoke particles when the pressure dropped as the bottle was released. In the real atmosphere, water vapor condenses around tiny dust particles to form the clouds we see in the sky.",
    'sum_s2':
        "Cycle Complete! The sun's heat causes evaporation. The water vapor cools and forms clouds through condensation around dust. When clouds get heavy, water falls as precipitation and is collected back in oceans.",
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Workbench with a plastic bottle, a cup of water, a bottle cap, a matchstick and paper in a dish',
    'scene_s2':
        'Landscape with the ocean and a mountain, a Heat Source slot in the sky and the Sun, Dust Particles, Cool Air and River Segment icons',
  },
  'hi': {
    'app_title': 'जल चक्र और बादल निर्माण',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: एक बोतल में बादल का प्रयोग',
    'scen_2_opt': 'परिदृश्य 2: जल चक्र बनाएँ',
    's1_desc':
        'गतिविधि 8.10 का प्रयोग फिर से करके बादलों के बनने में धूल के कणों की भूमिका की जाँच करना।',
    's2_desc':
        'वाष्पीकरण, संघनन और वर्षा की प्रक्रियाओं को सही क्रम में लगाकर पृथ्वी के जल चक्र का एक चालू मॉडल बनाना।',
    's1_c1': 'तैयारी',
    's1_a1':
        'प्लास्टिक की बोतल को शेल्फ से खींचें और वर्कबेंच पर चमकते घेरे पर छोड़ें।',
    's1_o1':
        'प्लास्टिक की बोतल अब वर्कबेंच के बीच में रखी है और प्रयोग के लिए तैयार है।',
    's1_c2': 'नमी जोड़ें',
    's1_a2':
        'पानी के कप को बोतल तक खींचें और वहीं छोड़ें, ताकि पानी बोतल में डल जाए।',
    's1_o2': 'बोतल में नीचे लगभग एक कप पानी भर गया है।',
    's1_c3': 'सील करें',
    's1_a3':
        'बोतल के ढक्कन को खींचें और बोतल पर छोड़ें, ताकि बोतल कसकर बंद हो जाए।',
    's1_o3': 'बोतल सील हो गई है।',
    's1_c4': 'दबाव परीक्षण',
    's1_a4':
        "बोतल को कम से कम 3 बार दबाएँ: बोतल को दबाकर रखें, फिर छोड़ दें (या 'बोतल दबाएँ' पर टैप करें)। पानी के ऊपर की जगह को देखें।",
    's1_o4':
        'बोतल दबती है, लेकिन कोई बादल नहीं बनता, क्योंकि जलवाष्प के संघनन के लिए कोई कण नहीं है।',
    's1_c5': 'कण जोड़ें',
    's1_a5':
        'बोतल का ढक्कन खींचकर उतारें और चमकते घेरे पर रखें। फिर जलती माचिस को डिश में रखे कागज़ तक खींचें, ताकि कागज़ जल उठे। फिर धुआँ देती डिश को जल्दी से बोतल के मुँह तक खींचें।',
    's1_o5':
        'थोड़ा-सा दिखाई देने वाला धुआँ (जो धूल के कणों को दर्शाता है) बोतल में चला जाता है।',
    's1_c6': 'फिर से सील करें',
    's1_a6':
        'बोतल के ढक्कन को खींचें और वापस बोतल पर छोड़ें, ताकि बोतल फिर से सील हो जाए।',
    's1_o6': 'पानी और धुएँ के कणों वाली बोतल अब सील है।',
    's1_c7': 'संघनन देखें',
    's1_a7':
        "बोतल को फिर से कम से कम 3 बार दबाएँ: बोतल को दबाकर रखें, फिर छोड़ दें (या 'बोतल दबाएँ' पर टैप करें)। बोतल के अंदर की जगह को ध्यान से देखें।",
    's1_o7':
        'हर बार दबाव हटने पर बोतल के अंदर एक धुंधला बादल बनता दिखाई देता है।',
    's1_c8': 'निष्कर्ष',
    's1_a8':
        "अपने अवलोकन पढ़ें, फिर प्रयोग का सारांश देखने के लिए 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o8':
        'आपने बादल बना दिया! जलवाष्प धुएँ के कणों के चारों ओर संघनित हो गया।',
    's2_c1': 'वाष्पीकरण',
    's2_a1':
        "सूरज को आकाश से खींचें और चमकते 'गर्मी का स्रोत' स्लॉट में छोड़ें, ताकि चक्र शुरू हो।",
    's2_o1':
        'सूरज चमक उठता है, और समुद्र का पानी अदृश्य वाष्प बनकर उड़ने लगता है।',
    's2_c2': 'संघनन',
    's2_a2':
        "'धूल के कण' आइकन को खींचें और उठते हुए जलवाष्प वाले चमकते क्षेत्र में छोड़ें।",
    's2_o2':
        'अदृश्य जलवाष्प धूल के कणों के चारों ओर संघनित होकर एक दिखाई देने वाला बादल बनाता है।',
    's2_c3': 'वर्षा',
    's2_a3':
        "'ठंडी हवा' (बर्फ़ का फाहा) आइकन को खींचें और बादल पर छोड़ें, ताकि बारिश शुरू हो।",
    's2_o3': 'बादल धूसर और भारी हो जाता है, और बारिश होने लगती है।',
    's2_c4': 'संग्रह',
    's2_a4':
        'बारिश से एक नदी बनती है। उसे वापस समुद्र से जोड़ें: नदी के हिस्से को खींचें और चमकते नदी-तल में छोड़ें।',
    's2_o4': 'पानी ज़मीन से नदी के रास्ते बहकर वापस समुद्र में पहुँचता है।',
    's2_c5': 'चक्र पूर्ण',
    's2_a5':
        "जल चक्र के लगातार चलते एनीमेशन को देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o5': 'चक्र लगातार चलता रहता है: वाष्पीकरण → संघनन → वर्षा → संग्रह।',
    's1_hud_1':
        'चरण 1: प्लास्टिक की बोतल को शेल्फ से खींचें और चमकते हुए वर्कबेंच पर छोड़ दें।',
    's1_hud_2': 'चरण 2: पानी का कप खींचें और उसे बोतल में डालें।',
    's1_hud_3':
        'चरण 3: बोतल को कसकर बंद करने के लिए ढक्कन खींचें और उस पर छोड़ दें।',
    's1_hud_4':
        "चरण 4: बोतल को दबाकर रखें (या 'बोतल दबाएँ' पर टैप करें), फिर छोड़ दें, कम से कम 3 बार। अंदर देखें।",
    's1_hud_5':
        'चरण 5: ढक्कन हटाएँ। जलती माचिस से कागज़ जलाएँ। फिर धुएँ वाली डिश को बोतल के मुँह पर खींचें।',
    's1_hud_6': 'चरण 6: सील करने के लिए ढक्कन को वापस बोतल पर खींचें।',
    's1_hud_7':
        "चरण 7: बोतल को फिर से दबाकर रखें (या 'बोतल दबाएँ' पर टैप करें), कम से कम 3 बार। ध्यान से देखें!",
    's1_hud_8':
        "चरण 8: अवलोकन पूर्ण। अपने अवलोकन पढ़ें और 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1':
        "चरण 1: सूरज आइकन को खींचें और आकाश में 'गर्मी का स्रोत' स्लॉट में छोड़ दें।",
    's2_hud_2':
        "चरण 2: 'धूल के कण' आइकन खींचें और उठते हुए वाष्प में छोड़ दें।",
    's2_hud_3':
        "चरण 3: बारिश शुरू करने के लिए 'ठंडी हवा' आइकन को भरे हुए बादल पर खींचें।",
    's2_hud_4':
        'चरण 4: नदी को जोड़ें। नदी के हिस्से को खींचकर चमकते हुए नदी-तल में छोड़ दें।',
    's2_hud_5':
        "चरण 5: चक्र पूरा हो गया है! लगातार चलता एनीमेशन देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_squeeze': 'बोतल दबाएँ',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_bottle': 'प्लास्टिक की बोतल',
    'lbl_water_cup': 'पानी का कप',
    'lbl_cap': 'बोतल का ढक्कन',
    'lbl_match': 'माचिस की तीली',
    'lbl_paper': 'डिश में कागज़',
    'lbl_sun': 'सूरज (गर्मी का स्रोत)',
    'lbl_dust': 'धूल के कण',
    'lbl_snow': 'ठंडी हवा',
    'lbl_river': 'नदी का हिस्सा',
    'lbl_evap': 'वाष्पीकरण',
    'lbl_cond': 'संघनन',
    'lbl_precip': 'वर्षा',
    'lbl_collect': 'संग्रह',
    'lbl_slot': 'गर्मी का स्रोत',
    'e_bottle': 'प्लास्टिक की बोतल को वर्कबेंच पर चमकते घेरे पर छोड़ें।',
    'e_cup': 'पानी डालने के लिए कप को बोतल के ऊपर लाएँ।',
    'e_cap_on': 'ढक्कन को बोतल के ऊपर छोड़ें।',
    'e_cap_off': 'ढक्कन को वर्कबेंच पर चमकते घेरे पर रखें।',
    'e_match': 'जलती माचिस को डिश में रखे कागज़ से छुआएँ।',
    'e_dish': 'धुआँ देती डिश को बोतल के मुँह पर लाएँ।',
    'e_sun': "सूरज को आकाश में चमकते 'गर्मी का स्रोत' स्लॉट में छोड़ें।",
    'e_dust': 'धूल के कणों को उठते हुए जलवाष्प वाले चमकते क्षेत्र में छोड़ें।',
    'e_snow': 'ठंडी हवा को बादल पर छोड़ें।',
    'e_river': 'नदी के हिस्से को चमकते नदी-तल में छोड़ें।',
    't_cap_off': 'ढक्कन हट गया। अब जलती माचिस को डिश में रखे कागज़ तक खींचें।',
    't_paper_lit':
        'कागज़ से धुआँ उठ रहा है! डिश को जल्दी से बोतल के मुँह तक खींचें।',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1':
        'आपने बादल बना दिया! बोतल छोड़ने पर दबाव कम हुआ, और हवा में मौजूद जलवाष्प धुएँ के कणों के चारों ओर संघनित हो गया, जिससे पानी की छोटी-छोटी बूँदें बनीं। असली वायुमंडल में भी जलवाष्प धूल के छोटे कणों के चारों ओर संघनित होकर वे बादल बनाता है जो हमें आकाश में दिखते हैं।',
    'sum_s2':
        'चक्र पूर्ण! सूरज की गर्मी से वाष्पीकरण होता है। जलवाष्प ठंडा होकर धूल के कणों के चारों ओर संघनित होता है और बादल बनाता है। बादल भारी होने पर पानी वर्षा के रूप में गिरता है और वापस समुद्र में इकट्ठा (संग्रहित) हो जाता है।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'वर्कबेंच, जिस पर प्लास्टिक की बोतल, पानी का कप, बोतल का ढक्कन, माचिस की तीली और डिश में कागज़ है',
    'scene_s2':
        'समुद्र और पहाड़ वाला दृश्य, आकाश में गर्मी के स्रोत का स्लॉट, और सूरज, धूल के कण, ठंडी हवा व नदी के हिस्से के आइकन',
  },
};

/// Scenarios and the number of steps of each (HTML `ScenariosData`).
const int _scenarioCount = 2;
const List<int> _stepCounts = [8, 5];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
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

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10–12 px label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Below this height (world units) the cap and the dish count as lying on
/// the bench, which moves their labels beside them.
const double _benchLabelY = 1;

/// Gap (world units) between a Scenario 2 icon's centre and the near edge
/// of its label, and between the Heat Source slot's centre and its label.
const double _iconLabelGap = 1.6;
const double _slotLabelGap = 2.7;

/// The Sun's label sits left of its rays (radius 2.4 in the HTML).
const double _sunLabelGap = 2.7;

/// While the sidebar is collapsed the scene slides right (and on small
/// screens shrinks) so the floating mission card at the top left leaves
/// everything the learner taps, drags or reads in view; the move follows
/// the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Gap (design px) kept between the scene and the mission card / tools.
const double _cardGap = 16;

/// Smallest scale the collapsed-sidebar fit may use.
const double _minFit = 0.6;

/// Design x extent of what the learner taps, drags or reads (objects and
/// their labels): Scenario 1 from the bottle's label under the shelf to the
/// dish's label, Scenario 2 from the EVAPORATION label to the river's top.
const (double, double) _benchExtent = (262, 712);
const (double, double) _landExtent = (200, 770);

/// Key of the scene layer. Flows map scene design coordinates to the screen
/// through it, so they follow the collapsed-sidebar move.
const ValueKey<String> _sceneKey = ValueKey('ch8-a6-scene');

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

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

/// Horizontal (x / z) distance between two points.
double _flat(_V a, _V b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z));

/// Distance from [p] to the segment [a]–[b] (screen space).
double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
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

  /// Where the ray through [s] meets the plane through [at] with normal
  /// [normal] (HTML `raycaster.ray.intersectPlane(dragPlane)`).
  _V? onPlane(Offset s, _V normal, _V at) {
    final dir = ray(s);
    final den = dir.dot(normal);
    if (den.abs() < 1e-6) return null;
    final t = (at - eye).dot(normal) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Where the ray through [s] meets the horizontal plane y = [h].
  _V? onPlaneY(Offset s, double h) => onPlane(s, _V.up, _V(0, h, 0));
}

/// Scenario 1 camera. The HTML uses (0, 15, 30) on wide screens, which cuts
/// off the bottle on the shelf, and (0, 25, 40) on narrow ones, which makes
/// the bench tiny on a phone; this sits between them, looking at (0, 6, 0)
/// instead of (0, 5, 0) so the shelf and the bench both fit above the HUD.
/// The look-at point is drawn 30 px left of the stage centre, clear of the
/// tool column.
final _Cam _camBench = _Cam(
  const _V(0, 20, 36),
  const _V(0, 6, 0),
  const Offset(470, 290),
);

/// Scenario 2 camera: the HTML's wide-screen `camera.position.set(0, 20,
/// 48)` looking at (0, 8, 0), drawn 20 px left of the stage centre.
final _Cam _camLand = _Cam(
  const _V(0, 20, 48),
  const _V(0, 8, 0),
  const Offset(480, 280),
);

/// HTML `DirectionalLight(0xffffff, 0.6)` at (10, 20, 15), normalised.
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// HTML `AmbientLight(0xffffff, 0.8)` plus the key light, toned down so the
/// lit faces do not all clip to white.
const double _ambient = 0.62;
const double _diffuse = 0.5;

// ----------------------------------------------- scenario 1: cloud in bottle

/// HTML positions: the bottle on the shelf and on the bench, the cup, the
/// cap on the shelf / on the bottle / put aside, the match and the dish.
const _V _bottleShelf = _V(-10, 10.5, -8);
const _V _bottleBench = _V.zero;
const _V _cupHome = _V(2, 10.5, -8);
const _V _capShelf = _V(-6, 10.8, -8);
const _V _capOnBottle = _V(0, 9.3, 0);
const _V _capAside = _V(-6, 0.3, 5);
const _V _dishHome = _V(10, 0, 5);
const _V _dishAtMouth = _V(2, 9, 0);

/// The match lies on the bench (the HTML centred the 0.1-thick stick at
/// y 0, half inside the bench). It lights the paper with its tip on the
/// paper (the HTML moved its far end to (10, 2, 5), 2 units past the paper).
const _V _matchHome = _V(5, 0.05, 5);
const _V _matchAtPaper = _V(8.2, 0.75, 5);

/// Where the cup pours from, tilted towards the bottle so its lip is over
/// the mouth. The HTML moved it to (-2, 10, 0) and tilted it π/4 away from
/// the bottle, so the water stream missed the mouth.
const _V _pourBase = _V(-3.4, 10.4, 0);
const double _pourTilt = math.pi / 3;

/// `dropZoneS1Glow`: RingGeometry(2.5, 3) on the bench at (0, 0.1, 0) for
/// the bottle and at (-6, 0.1, 5) for the cap taken off.
const _V _ringBottle = _V(0, 0.02, 0);
const _V _ringCap = _V(-6, 0.02, 5);
const double _ringIn = 2.5;
const double _ringOut = 3;

/// Bottle: body `CylinderGeometry(2, 2, 6)`, shoulder (2 → 0.8, y 6–8),
/// mouth (0.8, y 8–9); water `CylinderGeometry(1.9, 1.9, 1.5)`.
const double _bodyR = 2;
const double _bodyTop = 6;
const double _shoulderTop = 8;
const double _neckR = 0.8;
const double _mouthTop = 9;
const double _waterR = 1.9;
const double _waterH = 1.5;

/// A squeeze pinches the bottle to 0.8 of its width (`scale.x / z` 0.8).
const double _squeezeDepth = 0.2;

/// Cap `CylinderGeometry(0.9, 0.9, 0.6)`; cup `CylinderGeometry(1.5, 1.2,
/// 3)` with water (1.4 / 1.15, 2 high, from y 0.1); dish
/// `CylinderGeometry(2, 1.5, 0.5)` with the paper (1.5 x 0.1 x 1.5, y 0.6).
const double _capR = 0.9;
const double _capH = 0.6;
const double _cupR0 = 1.2;
const double _cupR1 = 1.5;
const double _cupH = 3;
const double _dishR0 = 1.5;
const double _dishR1 = 2;
const double _dishH = 0.5;
const double _paperY = 0.6;
const double _paperSize = 1.5;

/// Match: a 2-unit stick with a 0.2 tip at its far end.
const double _matchLen = 2;

/// The workbench `BoxGeometry(40, 2, 20)`: objects slide on it.
const double _benchHalfX = 19;
const double _benchHalfZ = 9.5;

/// Drop ranges in world units, measured where the learner sees the object
/// (the HTML accepted anything within 8 units of the bench centre or the
/// bottle's base, which let the match light the paper and the cap reseal
/// the bottle without moving, and refused a cap dropped on the bottle's
/// mouth or on the glowing ring).
const double _ringRange = 4;
const double _cupRange = 4;
const double _capRange = 3;
const double _matchRange = 2.5;
const double _dishRange = 3.5;

/// HTML squeeze tweens (ms): press 200 (Linear), release 300 (Elastic.Out);
/// the step moves on 1200 ms after the third release. A tap on 'Squeeze
/// Bottle' holds the squeeze for 350 ms.
const int _squeezeMs = 200;
const int _releaseMs = 300;
const int _squeezeAdvanceMs = 1200;
const int _buttonHoldMs = 350;
const int _squeezesNeeded = 3;

/// HTML timings (ms): bottle to the bench 600 (Quadratic.Out), cap 400,
/// a refused object back home 500 (Quadratic.Out); the pour (move 500,
/// tilt 300, water 1000 while the cup stays tilted 1200, tilt back 300,
/// home 500); the match (400, back 500 later, 400); the dish (500, smoke,
/// back 1500 later, 500).
const int _bottleMs = 600;
const int _capMs = 400;
const int _returnMs = 500;
const int _pourMoveMs = 500;
const int _tiltMs = 300;
const int _streamMs = 200;
const int _fillMs = 1000;
const int _pourHoldMs = 1200;
const int _matchMs = 400;
const int _matchWaitMs = 500;
const int _dishMs = 500;
const int _smokeWaitMs = 1500;

/// `generateSmokeParticles`: 40 particles 50 ms apart, each rising to the
/// mouth in 800 ms and settling inside the bottle in 1000 ms.
const int _smokeCount = 40;
const double _smokeR = 0.16;
const double _smokeGap = 0.05;
const double _smokeRise = 0.8;
const double _smokeSettle = 1.0;

/// The paper burns with a small flame for this long after the match
/// touches it (added), then smokes until the smoke goes into the bottle.
const double _paperFlameSeconds = 1.2;

// ----------------------------------------------- scenario 2: the water cycle

/// HTML positions: the four icons in the sky, the Heat Source slot, the
/// vapour zone `BoxGeometry(10, 8, 8)`, where the dust settles, the
/// riverbed `BoxGeometry(16, 1, 2)` turned π / 9.5 along the slope.
const _V _sunHome = _V(-13, 19, -9);
const _V _dustHome = _V(-4, 19, -9);
const _V _snowHome = _V(4, 19, -9);
const _V _riverHome = _V(13, 19, -9);
const _V _slot = _V(-12, 14, -5);
const double _slotIn = 2;
const double _slotOut = 2.5;
const _V _zone = _V(-10, 8, 0);
const _V _zoneHalf = _V(5, 4, 4);
const _V _dustInZone = _V(-10, 12, 0);
const _V _bed = _V(10, 4.5, 0);
const double _bedHalfLength = 8;

/// The landscape: ocean (x -22…0, top y 1), shore (top y 1.4) and the
/// mountain rising to y 9 at x 22, 15 deep; grass 0.2 on top.
const double _landHalfX = 22;
const double _landHalfZ = 7.5;
const double _oceanTop = 1;
const double _shoreTop = 1.4;
const double _peakY = 9;
const double _grassSkin = 0.2;

/// The cloud forms at (-8, 12, 0) (12 puffs). When it turns grey it drifts
/// over the shore and spreads out (added), so the rain falls on the land
/// where the river starts; the HTML rained from a clear sky over the land.
const _V _cloudStart = _V(-8, 12, 0);
const _V _cloudRaining = _V(1, 12, 0);
const double _cloudSpread = 0.2;
const double _cloudDriftSeconds = 1.5;

/// Drop ranges in world units (the HTML accepted 15 units, so the Sun and
/// the dust were accepted almost where they started).
const double _slotRange = 3.5;
const double _cloudRange = 5.5;
const double _bedRange = 2.5;

/// HTML timings (ms): every icon flies to its target in 500
/// (Quadratic.Out); the cloud grows in 2000 (Elastic.Out); it greys in
/// 1000 and the step moves on 1500 after the cool air; the river flows
/// down in 1500.
const int _iconMs = 500;
const int _cloudGrowMs = 2000;
const int _greyMs = 1000;
const int _rainAdvanceMs = 1500;
const int _riverMs = 1500;

/// `startEvaporation` (40 streaks over the ocean, x -20…-4, rising 0.04 to
/// 0.08 per frame from y 1 to 11) and `startRain` (70 drops falling 0.15 to
/// 0.3 per frame from y 11, drifting 0.01 per frame), at 60 frames / s.
const int _vapourCount = 40;
const int _rainCount = 70;
const double _framesPerSecond = 60;
const double _vapourTop = 11;
const double _rainTop = 11;

/// HTML `update3DHighlight`: the object to drag pulses towards light blue,
/// `(sin(Date.now() * 0.005) + 1) / 2 * 0.5`.
const double _pulseRate = 5;
const double _pulseMax = 0.5;

/// The scene objects the learner drags.
enum _Obj { bottle, cup, cap, match, dish, sun, dust, snow, river }

/// A straight move between two points over [seconds] from [start] (scene
/// time), eased by [curve] (a TWEEN.js tween on `position`).
@immutable
class _Move {
  const _Move(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Move.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, curve.transform((t - start) / seconds));
  }
}

/// A number eased from [from] to [to] (a TWEEN.js tween on a scalar).
@immutable
class _Anim {
  const _Anim(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Anim.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final double from;
  final double to;
  final double start;
  final double seconds;
  final Curve curve;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * curve.transform((t - start) / seconds);
  }
}

/// One smoke particle (HTML `s1SmokeParticles`): from the dish up to the
/// mouth, then down into the bottle.
@immutable
class _Smoke {
  const _Smoke(this.start, this.from, this.mid, this.end);

  final double start;
  final _V from;
  final _V mid;
  final _V end;

  _V? at(double t) {
    final e = t - start;
    if (e < 0) return null;
    if (e < _smokeRise) return _V.lerp(from, mid, e / _smokeRise);
    return _V.lerp(mid, end, ((e - _smokeRise) / _smokeSettle).clamp(0, 1));
  }
}

/// A rising vapour streak (HTML `s2EvapParticles`).
class _Vapour {
  _Vapour(this.x0, this.z, this.speed);

  final double x0;
  final double z;

  /// World units per second.
  final double speed;
  double y = 1;
}

/// A raindrop (HTML `s2RainParticles`): [u] places it across the cloud.
class _Drop {
  _Drop(this.u, this.z, this.speed);

  double u;
  double z;

  /// World units per second.
  double speed;
  double y = _rainTop;

  /// Wind drift since the drop started (HTML `x += 0.01` per frame).
  double drift = 0;
}

/// A puff of a cloud: offset from the cloud's centre and radius.
@immutable
class _Puff {
  const _Puff(this.offset, this.radius);

  final _V offset;
  final double radius;
}

/// HTML `bottleCloudS1`: 15 spheres of radius 0.5–1.3 at x / z ±1.25,
/// y 2–6 inside the bottle (fixed, so every run looks the same).
final List<_Puff> _bottlePuffs = () {
  final rnd = math.Random(3);
  return [
    for (var i = 0; i < 15; i++)
      _Puff(
        _V(
          (rnd.nextDouble() - 0.5) * 2.5,
          rnd.nextDouble() * 4 + 2,
          (rnd.nextDouble() - 0.5) * 2.5,
        ),
        rnd.nextDouble() * 0.8 + 0.5,
      ),
  ];
}();

/// HTML `cloudGrpS2`: 12 spheres of radius 1.5–4 within x ±3.5, y / z ±1.5.
final List<_Puff> _skyPuffs = () {
  final rnd = math.Random(7);
  return [
    for (var i = 0; i < 12; i++)
      _Puff(
        _V(
          (rnd.nextDouble() - 0.5) * 7,
          (rnd.nextDouble() - 0.5) * 3,
          (rnd.nextDouble() - 0.5) * 3,
        ),
        1.5 + rnd.nextDouble() * 2.5,
      ),
  ];
}();

/// Dust tile specks: 15 spheres of radius 0.15 within ±0.9.
final List<Offset> _dustSpecks = () {
  final rnd = math.Random(5);
  return [
    for (var i = 0; i < 15; i++)
      Offset((rnd.nextDouble() - 0.5) * 1.8, (rnd.nextDouble() - 0.5) * 1.8),
  ];
}();

/// Height of the land (grass top) at [x]; the ocean's surface left of the
/// shore.
double _groundAt(double x) {
  if (x < 0) return _oceanTop;
  return _shoreTop +
      _grassSkin +
      (_peakY - _shoreTop) * (x.clamp(0, _landHalfX) / _landHalfX);
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// Scenario 1 step 5 has three drags: cap off (0), match (1), dish (2).
  int sub = 0;

  /// HTML `State.isAnimating`: an object glides or an animation runs, and
  /// the scene ignores drags meanwhile.
  bool busy = false;

  /// 'Finish Observation' was tapped: the scenario is complete.
  bool done = false;

  /// The object being dragged.
  _Obj? held;

  /// Where each object is, and where a refused drop sends it back
  /// (`userData.homePos`).
  final Map<_Obj, _Move> pos = {};
  final Map<_Obj, _V> home = {};

  // ------------------------------------------------------------ scenario 1
  bool capOn = false;
  _Anim cupTilt = const _Anim.still(0);
  _Anim stream = const _Anim.still(0);
  _Anim water = const _Anim.still(0);
  _Anim cupWater = const _Anim.still(1);

  /// 0 relaxed … 1 squeezed (bottle width 1 → 0.8).
  _Anim squeeze = const _Anim.still(0);
  bool pressed = false;
  int squeezes = 0;
  bool squeezeLocked = false;

  /// The cloud in the bottle (step 7): shown after the first release; it
  /// shrinks and fades while squeezed.
  bool cloudOn = false;
  _Anim cloudScale = const _Anim.still(0.5);
  _Anim cloudAlpha = const _Anim.still(0.2);

  /// The paper was lit at [burnAt]; the smoke particles started at
  /// [smokeAt] (-1: not yet).
  bool paperBurnt = false;
  double burnAt = -10;
  double smokeAt = -1;
  final List<_Smoke> smoke = [];

  // ------------------------------------------------------------ scenario 2
  bool sunPlaced = false;
  double sunAt = -10;
  bool dustShown = true;
  bool snowShown = true;
  bool riverShown = true;
  bool cloudShown = false;
  _Anim cloudGrow = const _Anim.still(0.01);
  _Anim cloudGrey = const _Anim.still(0);
  _Anim cloudDrift = const _Anim.still(0);
  _Anim riverFlow = const _Anim.still(0);
  final List<_Vapour> vapour = [];
  final List<_Drop> rain = [];

  /// HTML `createActionLabel` labels shown so far.
  bool lblEvap = false;
  bool lblCond = false;
  bool lblPrecip = false;
  bool lblCollect = false;

  _V posOf(_Obj obj) => pos[obj]!.at(time);

  /// HTML `State.activeDragTarget` of the current step.
  _Obj? get target {
    if (done || busy) return null;
    if (scenario == 0) {
      return switch (step) {
        1 => _Obj.bottle,
        2 => _Obj.cup,
        3 || 6 => _Obj.cap,
        5 => const [_Obj.cap, _Obj.match, _Obj.dish][sub],
        _ => null,
      };
    }
    return switch (step) {
      1 => _Obj.sun,
      2 => _Obj.dust,
      3 => _Obj.snow,
      4 => _Obj.river,
      _ => null,
    };
  }

  /// The object that pulses (HTML `update3DHighlight`).
  _Obj? get glowing => held ?? target;

  /// Steps 4 and 7 of Scenario 1: squeeze the bottle.
  bool get squeezeStep => scenario == 0 && (step == 4 || step == 7) && !done;

  /// The last step: 'Finish Observation' opens the summary.
  bool get finishStep => step == _stepCounts[scenario] || done;

  /// The visible objects of the scenario (in hit-test order).
  List<_Obj> get objects => scenario == 0
      ? const [_Obj.cap, _Obj.match, _Obj.cup, _Obj.dish, _Obj.bottle]
      : [
          _Obj.sun,
          if (dustShown) _Obj.dust,
          if (snowShown) _Obj.snow,
          if (riverShown) _Obj.river,
        ];

  /// The cloud's centre and its horizontal spread (1 → 1.2) as it drifts.
  _V get cloudCentre =>
      _V.lerp(_cloudStart, _cloudRaining, cloudDrift.at(time));
  double get cloudWidth => 1 + _cloudSpread * cloudDrift.at(time);

  /// The rain falls across this half-width around the cloud's centre.
  double get rainHalfWidth => 6 * cloudWidth;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    sub = 0;
    busy = false;
    done = false;
    held = null;
    pos.clear();
    home
      ..clear()
      ..addAll({
        _Obj.bottle: _bottleShelf,
        _Obj.cup: _cupHome,
        _Obj.cap: _capShelf,
        _Obj.match: _matchHome,
        _Obj.dish: _dishHome,
        _Obj.sun: _sunHome,
        _Obj.dust: _dustHome,
        _Obj.snow: _snowHome,
        _Obj.river: _riverHome,
      });
    home.forEach((obj, at) => pos[obj] = _Move.still(at));
    capOn = false;
    cupTilt = const _Anim.still(0);
    stream = const _Anim.still(0);
    water = const _Anim.still(0);
    cupWater = const _Anim.still(1);
    squeeze = const _Anim.still(0);
    pressed = false;
    squeezes = 0;
    squeezeLocked = false;
    cloudOn = false;
    cloudScale = const _Anim.still(0.5);
    cloudAlpha = const _Anim.still(0.2);
    paperBurnt = false;
    burnAt = -10;
    smokeAt = -1;
    smoke.clear();
    sunPlaced = false;
    sunAt = -10;
    dustShown = true;
    snowShown = true;
    riverShown = true;
    cloudShown = false;
    cloudGrow = const _Anim.still(0.01);
    cloudGrey = const _Anim.still(0);
    cloudDrift = const _Anim.still(0);
    riverFlow = const _Anim.still(0);
    vapour.clear();
    rain.clear();
    lblEvap = false;
    lblCond = false;
    lblPrecip = false;
    lblCollect = false;
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the object the current step lets the learner drag ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

/// How the scene layer is placed while the sidebar is collapsed: scale [k]
/// and offset ([dx], [dy]) in design pixels.
typedef _Fit = ({double k, double dx, double dy});

const _Fit _noFit = (k: 1, dx: 0, dy: 0);

Duration _ms(int ms) => Duration(milliseconds: ms);

class _WaterCycleLabState extends State<Ch8A6TheWaterCycleAndCloudFormationPage>
    with SingleTickerProviderStateMixin {
  /// HTML `State.isCamLocked: true`.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in scene pixels for the current stage
  /// scale, and the tool column's left edge in scene pixels (set while
  /// laying out).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// Where the finger holds the object relative to its anchor (screen), and
  /// the anchor's position when it was picked up (the drag plane faces the
  /// camera through it, HTML `dragPlane.setFromNormalAndCoplanarPoint`).
  Offset _grabShift = Offset.zero;
  _V _grabAt = _V.zero;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// The pointer pressing the bottle, and whether 'Squeeze Bottle' is
  /// holding the squeeze.
  int? _squeezePointer;
  bool _buttonSqueeze = false;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `sN_hud_M` of the current step.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

  _Cam get _cam => _scene.scenario == 0 ? _camBench : _camLand;

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

  /// HTML `animate()`: tweens are functions of the scene time; the vapour
  /// streaks and raindrops move every frame. Repaints the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    if (s.scenario == 1) _tickWeather(dt);
    _frame.value = now;
  }

  void _tickWeather(double dt) {
    final s = _scene;
    for (final v in s.vapour) {
      v.y += v.speed * dt;
      if (v.y > _vapourTop) v.y = 1;
    }
    if (s.rain.isEmpty) return;
    final centre = s.cloudCentre;
    final half = s.rainHalfWidth;
    for (final d in s.rain) {
      d.y -= d.speed * dt;
      d.drift += 0.01 * _framesPerSecond * dt;
      final x = centre.x + d.u * half + d.drift;
      if (d.y < _groundAt(x)) {
        d
          ..y = _rainTop
          ..u = _rnd.nextDouble() * 2 - 1
          ..drift = 0;
      }
    }
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _squeezePointer = null;
    _buttonSqueeze = false;
    _moved = false;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  void _setBusy(bool busy) {
    if (!mounted || _scene.busy == busy) return;
    setState(() => _scene.busy = busy);
  }

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone.
  void _toast(String key, {bool error = false, bool sound = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: sound);
    _toastId = _lab.toast?.id;
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null || shown.id != _toastId) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(_t(key), isError: shown.isError, sound: false);
      _toastId = _lab.toast?.id;
    });
  }

  /// HTML `triggerMainAction()` ('Finish Observation'): the scenario is
  /// done and its summary opens (again, if the learner closed it).
  void _finish() {
    final s = _scene;
    if (!_lab.isLabActive || !s.finishStep) return;
    if (!s.done) setState(() => s.done = true);
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () => _t('sum_s${sc + 1}'),
    );
  }

  /// The object glides to [to] (default Quadratic.Out); drags are ignored
  /// until it arrives, then [then] runs.
  void _snap(
    _Obj obj,
    _V to, {
    required int ms,
    Curve curve = Curves.easeOutQuad,
    VoidCallback? then,
  }) {
    final s = _scene;
    _setBusy(true);
    s.pos[obj] = _Move(s.posOf(obj), to, s.time, ms / 1000, curve);
    _lab.after(_ms(ms), () {
      if (!mounted) return;
      _setBusy(false);
      then?.call();
    });
  }

  /// A refused drop: the object goes back to where it belongs in 500 ms
  /// (Quadratic.Out). The HTML said nothing; the toast [key] now says where
  /// it goes.
  void _revert(_Obj obj, String key) {
    _toast(key, error: true, sound: true);
    _snap(obj, _scene.home[obj]!, ms: _returnMs);
  }

  // ------------------------------------------------- scenario 1 actions

  /// Step 1 done: the bottle stands on the bench (HTML 'thud').
  void _bottlePlaced() {
    _Sound.drop.play();
    setState(() {
      _scene
        ..home[_Obj.bottle] = _bottleBench
        ..step = 2;
    });
  }

  /// HTML `animatePour(cup, …, bottleWater)`: the cup goes over the bottle,
  /// tilts, pours (the bottle fills as the cup empties), tilts back and
  /// goes home; then step 3.
  void _pour() {
    final s = _scene;
    _setBusy(true);
    s.pos[_Obj.cup] = _Move(
      s.posOf(_Obj.cup),
      _pourBase,
      s.time,
      _pourMoveMs / 1000,
      Curves.easeOutQuad,
    );
    const tiltAt = _pourMoveMs;
    const pourAt = tiltAt + _tiltMs;
    const backAt = pourAt + _pourHoldMs;
    const homeAt = backAt + _tiltMs;
    const doneAt = homeAt + _pourMoveMs;
    _lab.after(_ms(tiltAt), () {
      if (!mounted) return;
      _Sound.drop.play();
      s.cupTilt = _Anim(0, _pourTilt, s.time, _tiltMs / 1000);
    });
    _lab.after(_ms(pourAt), () {
      if (!mounted) return;
      s
        ..stream = _Anim(0, 1, s.time, _streamMs / 1000)
        ..water = _Anim(0, 1, s.time, _fillMs / 1000)
        ..cupWater = _Anim(1, 0, s.time, _fillMs / 1000);
    });
    _lab.after(_ms(backAt), () {
      if (!mounted) return;
      s
        ..stream = _Anim(1, 0, s.time, _streamMs / 1000)
        ..cupTilt = _Anim(_pourTilt, 0, s.time, _tiltMs / 1000);
    });
    _lab.after(_ms(homeAt), () {
      if (!mounted) return;
      s.pos[_Obj.cup] = _Move(_pourBase, _cupHome, s.time, _pourMoveMs / 1000);
    });
    _lab.after(_ms(doneAt), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 3;
      });
    });
  }

  /// Steps 3 and 6 done: the cap closes the bottle (HTML 'snap').
  void _capClosed() {
    _Sound.pop.play();
    setState(() {
      _scene
        ..home[_Obj.cap] = _capOnBottle
        ..capOn = true
        ..step += 1;
    });
  }

  /// Step 5, first drag: the cap is off; the match is next.
  void _capRemoved() {
    setState(() {
      _scene
        ..home[_Obj.cap] = _capAside
        ..capOn = false
        ..sub = 1;
    });
    _toast('t_cap_off');
  }

  /// Step 5, second drag: the match lights the paper (HTML: the paper turns
  /// 0x555555 with a 'click'); 500 ms later the match goes back.
  void _lightPaper() {
    final s = _scene;
    _Sound.click.play();
    _setBusy(true);
    setState(() {
      s
        ..paperBurnt = true
        ..burnAt = s.time;
    });
    _toast('t_paper_lit');
    _lab.after(_ms(_matchWaitMs), () {
      if (!mounted) return;
      s.pos[_Obj.match] = _Move(
        s.posOf(_Obj.match),
        _matchHome,
        s.time,
        _matchMs / 1000,
      );
      setState(() {
        s
          ..busy = false
          ..sub = 2;
      });
    });
  }

  /// Step 5, third drag: HTML `generateSmokeParticles()` at the mouth; the
  /// dish goes back 1500 ms later; then step 6.
  void _deliverSmoke() {
    final s = _scene;
    _setBusy(true);
    final from = _dishAtMouth + const _V(0, 1, 0);
    s
      ..smokeAt = s.time
      ..smoke.clear();
    for (var i = 0; i < _smokeCount; i++) {
      final mid = _V(_rnd.nextDouble() - 0.5, 10, _rnd.nextDouble() - 0.5);
      s.smoke.add(
        _Smoke(
          s.time + i * _smokeGap,
          from,
          mid,
          mid.atY(3 + _rnd.nextDouble() * 5),
        ),
      );
    }
    _lab.after(_ms(_smokeWaitMs), () {
      if (!mounted) return;
      s.pos[_Obj.dish] = _Move(_dishAtMouth, _dishHome, s.time, _dishMs / 1000);
      _lab.after(_ms(_dishMs), () {
        if (!mounted) return;
        setState(() {
          s
            ..busy = false
            ..step = 6;
        });
      });
    });
  }

  /// HTML `pressDown` on 'SQUEEZE BOTTLE' (here also a press on the
  /// bottle): counts the squeeze and pinches the bottle; in step 7 the cloud
  /// shrinks and fades while the bottle is squeezed.
  void _press() {
    final s = _scene;
    if (!_lab.isLabActive || !s.squeezeStep) return;
    if (s.squeezeLocked || s.pressed || s.busy) return;
    final t = s.time;
    setState(() {
      s
        ..pressed = true
        ..squeezes += 1
        ..squeeze = _Anim(s.squeeze.at(t), 1, t, _squeezeMs / 1000);
      if (s.step == 7 && s.cloudOn) {
        s
          ..cloudScale = _Anim(s.cloudScale.at(t), 0.5, t, _squeezeMs / 1000)
          ..cloudAlpha = _Anim(s.cloudAlpha.at(t), 0.2, t, _squeezeMs / 1000);
      }
    });
  }

  /// HTML `releaseUp`: the bottle springs back (Elastic.Out); in step 7 the
  /// cloud forms as the pressure drops. After the third squeeze the step
  /// moves on 1200 ms later.
  void _releaseSqueeze() {
    final s = _scene;
    if (!s.pressed) return;
    final t = s.time;
    setState(() {
      s
        ..pressed = false
        ..squeeze = _Anim(
          s.squeeze.at(t),
          0,
          t,
          _releaseMs / 1000,
          Curves.elasticOut,
        );
      if (s.step == 7) {
        final scale = s.cloudOn ? s.cloudScale.at(t) : 0.5;
        final alpha = s.cloudOn ? s.cloudAlpha.at(t) : 0.2;
        s
          ..cloudOn = true
          ..cloudScale = _Anim(
            scale,
            1,
            t,
            _releaseMs / 1000,
            Curves.elasticOut,
          )
          ..cloudAlpha = _Anim(alpha, 0.8, t, _releaseMs / 1000);
      }
      if (s.squeezes >= _squeezesNeeded) s.squeezeLocked = true;
    });
    if (!s.squeezeLocked) return;
    final step = s.step;
    _lab.after(_ms(_squeezeAdvanceMs), () {
      if (!mounted || s.step != step) return;
      setState(() {
        s
          ..squeezeLocked = false
          ..squeezes = 0
          ..step = step + 1;
      });
    });
  }

  /// 'Squeeze Bottle': one squeeze held for 350 ms, then released.
  void _squeezeButton() {
    if (_scene.pressed) return;
    _press();
    if (!_scene.pressed) return;
    _buttonSqueeze = true;
    _lab.after(_ms(_buttonHoldMs), () {
      if (!mounted || !_buttonSqueeze) return;
      _buttonSqueeze = false;
      _releaseSqueeze();
    });
  }

  // ------------------------------------------------- scenario 2 actions

  /// Step 1 done: HTML 'ding', the slot hides, EVAPORATION, the vapour
  /// starts rising (`startEvaporation`).
  void _sunPlaced() {
    final s = _scene;
    _Sound.correct.play();
    setState(() {
      s
        ..home[_Obj.sun] = _slot
        ..sunPlaced = true
        ..sunAt = s.time
        ..lblEvap = true
        ..step = 2;
      s.vapour
        ..clear()
        ..addAll([
          for (var i = 0; i < _vapourCount; i++)
            _Vapour(
              -20 + _rnd.nextDouble() * 16,
              (_rnd.nextDouble() - 0.5) * 10,
              (0.04 + _rnd.nextDouble() * 0.04) * _framesPerSecond,
            ),
        ]);
    });
  }

  /// Step 2 done: the dust disappears into the vapour and the cloud grows
  /// (2000 ms, Elastic.Out); then step 3.
  void _dustDropped() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..dustShown = false
        ..cloudShown = true
        ..lblCond = true
        ..busy = true
        ..cloudGrow = _Anim(
          0.01,
          1,
          s.time,
          _cloudGrowMs / 1000,
          Curves.elasticOut,
        );
    });
    _lab.after(_ms(_cloudGrowMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 3;
      });
    });
  }

  /// Step 3 done: the cloud turns grey (1000 ms), drifts over the shore and
  /// rains (`startRain`); the step moves on 1500 ms later.
  void _coolAirDropped() {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..snowShown = false
        ..lblPrecip = true
        ..busy = true
        ..cloudGrey = _Anim(0, 1, s.time, _greyMs / 1000)
        ..cloudDrift = _Anim(
          0,
          1,
          s.time,
          _cloudDriftSeconds,
          Curves.easeInOutQuad,
        );
      s.rain
        ..clear()
        ..addAll([
          for (var i = 0; i < _rainCount; i++)
            _Drop(
              _rnd.nextDouble() * 2 - 1,
              (_rnd.nextDouble() - 0.5) * 10,
              (0.15 + _rnd.nextDouble() * 0.15) * _framesPerSecond,
            ),
        ]);
    });
    _lab.after(_ms(_rainAdvanceMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 4;
      });
    });
  }

  /// Step 4 done: HTML 'pour'; the river flows from the mountain top down
  /// to the ocean in 1500 ms, then COLLECTION and step 5.
  void _riverLaid() {
    final s = _scene;
    _Sound.drop.play();
    setState(() {
      s
        ..riverShown = false
        ..busy = true
        ..riverFlow = _Anim(0, 1, s.time, _riverMs / 1000);
    });
    _lab.after(_ms(_riverMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..lblCollect = true
          ..step = 5;
      });
    });
  }

  // -------------------------------------------------------------- gestures

  /// HTML meshes and invisible hit boxes (`matchHit` 6 x 4 x 4, `sunHit`
  /// 4 x 4 x 2, …) as screen rectangles, at least a 48 dp target around
  /// the object's anchor.
  Rect _hitRect(_Obj obj) {
    final s = _scene;
    final pos = s.posOf(obj);
    final (centre, half) = switch (obj) {
      _Obj.bottle => (pos + const _V(0, 4.5, 0), const _V(2, 4.5, 2)),
      _Obj.cup => (pos + const _V(0, 1.5, 0), const _V(1.5, 1.5, 1.5)),
      _Obj.cap => (pos, const _V(_capR, _capH / 2, _capR)),
      _Obj.match => (pos + const _V(1, 0, 0), const _V(1.6, 0.6, 0.6)),
      _Obj.dish => (pos + const _V(0, 0.3, 0), const _V(2, 0.5, 2)),
      _Obj.river => (pos, const _V(3, 2, 1)),
      _ => (pos, const _V(2, 2, 1)),
    };
    final cam = _cam;
    var rect = Rect.fromCircle(center: cam.p(centre), radius: _touch);
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final c = cam.p(centre + _V(sx * half.x, sy * half.y, sz * half.z));
          rect = rect.expandToInclude(Rect.fromLTWH(c.dx, c.dy, 0, 0));
        }
      }
    }
    return rect;
  }

  /// The object under [at]: the step's object first (the HTML raycast only
  /// tested the active object), then the others.
  _Obj? _objAt(Offset at) {
    final s = _scene;
    final target = s.target;
    if (target != null && _hitRect(target).contains(at)) return target;
    for (final obj in s.objects) {
      if (_hitRect(obj).contains(at)) return obj;
    }
    return null;
  }

  /// HTML `pointerdown`: only the step's object can be picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null) return false;
    final target = s.target;
    return target != null && _hitRect(target).contains(event.localPosition);
  }

  /// HTML `startDrag`: the drag plane faces the camera through the object;
  /// the finger keeps its offset from the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final target = s.target;
    if (target == null || !_hitRect(target).contains(d.localPosition)) return;
    final pos = s.posOf(target);
    _grabAt = pos;
    _grabShift = d.localPosition - _cam.p(pos);
    _moved = false;
    setState(() => s.held = target);
  }

  void _onDragStart(DragStartDetails d) {
    if (_scene.held == null) return;
    _moved = true;
    _Sound.pickup.play();
  }

  /// Resting height of a Scenario 1 object on the bench (its anchor).
  double _restY(_Obj obj) => switch (obj) {
    _Obj.cap => _capH / 2,
    _Obj.match => _matchHome.y,
    _ => 0,
  };

  /// HTML `pointermove`: the object follows the finger on its drag plane.
  /// On the workbench (Scenario 1) it slides along the bench top instead of
  /// sinking into it (the HTML only kept y above 1).
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    final cam = _cam;
    final at = d.localPosition - _grabShift;
    var p = cam.onPlane(at, cam.f, _grabAt);
    if (p == null) return;
    if (s.scenario == 0) {
      final rest = _restY(obj);
      if (p.y < rest) {
        final onBench = cam.onPlaneY(at, rest) ?? p.atY(rest);
        p = _V(
          onBench.x.clamp(-_benchHalfX, _benchHalfX),
          rest,
          onBench.z.clamp(-_benchHalfZ, _benchHalfZ),
        );
      }
    }
    s.pos[obj] = _Move.still(p);
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` / `pointercancel`: a dragged object is checked against
  /// the step's target; a mere press leaves it where it was.
  void _release() {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    setState(() => s.held = null);
    if (!_moved) return;
    _moved = false;
    _checkDrop(obj);
  }

  /// Is [screen] over the bench within [_ringRange] of [centre] (the ray
  /// through it meets the bench plane at height [y] there)?
  bool _onRing(Offset screen, _V centre, double y) {
    final hit = _cam.onPlaneY(screen, y);
    return hit != null && _flat(hit, centre) <= _ringRange;
  }

  /// Is [screen] within [range] world units of the segment [a]–[b] as the
  /// learner sees it?
  bool _nearSegment(Offset screen, _V a, _V b, double range) {
    final cam = _cam;
    return _segDist(screen, cam.p(a), cam.p(b)) <=
        range * cam.scaleAt((a + b) * 0.5);
  }

  bool _near(Offset screen, _V target, double range) =>
      (screen - _cam.p(target)).distance <= range * _cam.scaleAt(target);

  /// Is [screen] inside the vapour zone's outline on screen?
  bool _inZone(Offset screen) {
    final cam = _cam;
    var rect = Rect.fromCenter(center: cam.p(_zone), width: 0, height: 0);
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final c = cam.p(
            _zone + _V(sx * _zoneHalf.x, sy * _zoneHalf.y, sz * _zoneHalf.z),
          );
          rect = rect.expandToInclude(Rect.fromLTWH(c.dx, c.dy, 0, 0));
        }
      }
    }
    return rect.contains(screen);
  }

  /// HTML `checkDrop()` → `executeStepAction()`, with each target tested
  /// where the learner sees it.
  void _checkDrop(_Obj obj) {
    final s = _scene;
    final cam = _cam;
    final p = s.posOf(obj);
    switch (obj) {
      case _Obj.bottle:
        if (_onRing(cam.p(p), _ringBottle, 0)) {
          _snap(obj, _bottleBench, ms: _bottleMs, then: _bottlePlaced);
        } else {
          _revert(obj, 'e_bottle');
        }
      case _Obj.cup:
        final centre = cam.p(p + const _V(0, _cupH / 2, 0));
        if (_nearSegment(
          centre,
          _V.zero,
          const _V(0, _mouthTop, 0),
          _cupRange,
        )) {
          _pour();
        } else {
          _revert(obj, 'e_cup');
        }
      case _Obj.cap when s.step == 5:
        if (_onRing(cam.p(p), _ringCap, _capAside.y)) {
          _snap(
            obj,
            _capAside,
            ms: _capMs,
            curve: Curves.linear,
            then: _capRemoved,
          );
        } else {
          _revert(obj, 'e_cap_off');
        }
      case _Obj.cap:
        if (_nearSegment(
          cam.p(p),
          const _V(0, 4, 0),
          _capOnBottle,
          _capRange,
        )) {
          _snap(
            obj,
            _capOnBottle,
            ms: _capMs,
            curve: Curves.linear,
            then: _capClosed,
          );
        } else {
          _revert(obj, 'e_cap_on');
        }
      case _Obj.match:
        final tip = cam.p(p + const _V(_matchLen, 0, 0));
        if (_near(tip, _dishHome.atY(_paperY), _matchRange)) {
          _snap(
            obj,
            _matchAtPaper,
            ms: _matchMs,
            curve: Curves.linear,
            then: _lightPaper,
          );
        } else {
          _revert(obj, 'e_match');
        }
      case _Obj.dish:
        final centre = cam.p(p + const _V(0, _dishH / 2, 0));
        if (_nearSegment(
          centre,
          const _V(0, 7, 0),
          const _V(0, 10, 0),
          _dishRange,
        )) {
          _snap(
            obj,
            _dishAtMouth,
            ms: _dishMs,
            curve: Curves.linear,
            then: _deliverSmoke,
          );
        } else {
          _revert(obj, 'e_dish');
        }
      case _Obj.sun:
        if (_near(cam.p(p), _slot, _slotRange)) {
          _snap(obj, _slot, ms: _iconMs, then: _sunPlaced);
        } else {
          _revert(obj, 'e_sun');
        }
      case _Obj.dust:
        if (_inZone(cam.p(p))) {
          _snap(obj, _dustInZone, ms: _iconMs, then: _dustDropped);
        } else {
          _revert(obj, 'e_dust');
        }
      case _Obj.snow:
        if (_near(cam.p(p), s.cloudCentre, _cloudRange)) {
          _snap(obj, s.cloudCentre, ms: _iconMs, then: _coolAirDropped);
        } else {
          _revert(obj, 'e_snow');
        }
      case _Obj.river:
        final c = math.cos(math.pi / 9.5) * _bedHalfLength;
        final h = math.sin(math.pi / 9.5) * _bedHalfLength;
        if (_nearSegment(
          cam.p(p),
          _bed - _V(c, h, 0),
          _bed + _V(c, h, 0),
          _bedRange,
        )) {
          _snap(obj, _bed, ms: _iconMs, then: _riverLaid);
        } else {
          _revert(obj, 'e_river');
        }
    }
  }

  /// Taps: the object to drag or another one repeats the current task (the
  /// HTML ignored them). A press on the bottle in steps 4 / 7 squeezes it.
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null || s.done) return;
    final obj = _objAt(d.localPosition);
    if (obj == null) return;
    if (obj == _Obj.bottle && s.squeezeStep) return;
    if (obj == s.target) {
      _toast(_hudKey);
    } else {
      _toast(_hudKey, error: true, sound: true);
    }
  }

  /// Press and hold on the bottle squeezes it (steps 4 and 7).
  void _onPointerDown(PointerDownEvent e) {
    final s = _scene;
    if (!s.squeezeStep || _squeezePointer != null || s.pressed) return;
    if (!_hitRect(_Obj.bottle).contains(e.localPosition)) return;
    _squeezePointer = e.pointer;
    _press();
    if (!s.pressed) _squeezePointer = null;
  }

  void _onPointerUp(PointerEvent e) {
    if (e.pointer != _squeezePointer) return;
    _squeezePointer = null;
    _releaseSqueeze();
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-squeeze` (steps 4 and 7) and `#btn-action-main` 'Finish
  /// Observation' (the last step; afterwards it re-opens the summary).
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.squeezeStep)
        LabAction(
          label: _t('btn_squeeze'),
          icon: Icons.compress,
          color: _Colors.blue600,
          foreground: _Colors.white,
          enabled: !s.squeezeLocked && !s.pressed && !s.busy,
          silent: true,
          onTap: _squeezeButton,
        ),
      if (s.finishStep)
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.arrow_forward,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: !s.done,
          // The summary plays the HTML 'ding'.
          silent: true,
          onTap: _finish,
        ),
    ];
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
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.cloud,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the scenario
          // is done.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          stage: _stage(),
        );
      },
    );
  }

  /// While the sidebar is collapsed: moves (and on small screens shrinks)
  /// the scene so everything the learner needs lies between the floating
  /// mission card and the tool column.
  _Fit _collapsedFit(BuildContext context) {
    if (_lab.isSidebarOpen) return _noFit;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return _noFit;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = _missionCardWidth(size, context.labScale);
    // The shell puts the mission card 76 px from the left edge.
    final freeLeft = (76 + pad.left + card - stageLeft) / fit + _cardGap;
    final tools = labOverlayInsets(context, _lab).right;
    final freeRight =
        math.min((size.width - tools - stageLeft) / fit, _design.width) -
        _cardGap;
    final (left, right) = _scene.scenario == 0 ? _benchExtent : _landExtent;
    final k = ((freeRight - freeLeft) / (right - left)).clamp(_minFit, 1.0);
    return (
      k: k,
      dx: (freeLeft + freeRight) / 2 - k * (left + right) / 2,
      dy: (1 - k) * _design.height / 2,
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final view = _collapsedFit(context);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          final px = fit * view.k;
          _touch = _touchDp / px;
          _labelSize =
              _labelPx * (_labelFullScale / px).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          final toolsLeft = math.min(
            (box.maxWidth - tools - stageLeft) / fit,
            _design.width,
          );
          _labelRight = (toolsLeft - view.dx) / view.k;
        }
        return LabStage(
          designSize: _design,
          // The move transforms the whole scene layer (painting and hit
          // tests), so gestures arrive in the scene's own coordinates.
          child: AnimatedContainer(
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            transform: Matrix4(
              view.k,
              0,
              0,
              0, //
              0,
              view.k,
              0,
              0, //
              0,
              0,
              1,
              0, //
              view.dx,
              view.dy,
              0,
              1,
            ),
            child: KeyedSubtree(
              key: _sceneKey,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags and taps on the scene are not screen-reader
                  // actions; the scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
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
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
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

/// The sidebar's observation list: one line per step done.
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

// ================================================================== PAINTING

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Round-ended thick lines (the match, streaks, raindrops, the river
  /// icon).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Soft-edged fills: the cloud in the bottle, smoke, the Sun's glow.
  final Paint soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  final Path path = Path();

  /// The bottle's silhouette (also the clip of the cloud inside it).
  final Path hull = Path();

  /// Even-odd path for rings (the glowing drop zones).
  final Path ringPath = Path();
}

/// Label chip styles: glass chip in the dark / light theme, green action
/// label (HTML `createActionLabel`).
enum _Chip { dark, light, action }

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background, bench and shelf, or the landscape) and the label text
/// painters. Owned by the page state and disposed with it.
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

  TextPainter label(
    String text,
    _Chip chip,
  ) => _labels['${chip.index}|$text'] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: switch (chip) {
          _Chip.dark => _Colors.white,
          _Chip.light => _Colors.slate800,
          _Chip.action => _Colors.emerald800,
        },
        fontSize: _labelSize,
        fontWeight: chip == _Chip.action ? FontWeight.w900 : FontWeight.w700,
        height: 1.2,
        letterSpacing: labLetterSpacing(text, chip == _Chip.action ? 0.6 : 0),
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
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// [c] pulsing towards the HTML highlight colour by [amount] (0 … 0.5).
Color _pulsed(Color c, double amount) => amount <= 0
    ? c
    : Color.lerp(c, _Colors.highlight.withValues(alpha: c.a), amount)!;

/// [v] turned by [yaw] about the y axis (Three.js `rotation.y`).
_V _yawed(_V v, double yaw) {
  if (yaw == 0) return v;
  final c = math.cos(yaw), s = math.sin(yaw);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

/// Convex hull of [pts] (monotone chain), for glass silhouettes.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  pts.sort(
    (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
  );
  double turn(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in pts) {
    while (lower.length >= 2 &&
        turn(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in pts.reversed) {
    while (upper.length >= 2 &&
        turn(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Segments of rims and rings (smooth enough at this size).
const int _ringSides = 28;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  _V get _eyeAt => cam.eye;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color, {Color? edge, double edgeWidth = 1}) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = edgeWidth
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c], turned by [yaw]: the faces seen by the
  /// camera, lit; [edge] darkens (or [edgeColor] colours) the rims.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
    double yaw = 0,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final f = face.normal;
      final n = _yawed(f, yaw);
      final mid = c + _yawed(_V(f.x * hx, f.y * hy, f.z * hz), yaw);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _yawed(_V(k.x * hx, k.y * hy, k.z * hz), yaw)));
      }
      path.close();
      canvas.drawPath(
        path,
        pens.fill..color = _lit(color, n, opacity: opacity),
      );
      final rim =
          edgeColor ??
          (edge > 0
              ? labShade(color, -0.5).withValues(alpha: edge * opacity)
              : null);
      if (rim != null) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = rim,
        );
      }
    }
  }

  /// Cross-section direction at [a] radians in the frame ([ex], [ez]).
  static _V _dir(_V ex, _V ez, double a) => ex * math.cos(a) + ez * math.sin(a);

  /// CylinderGeometry: radius [r0] at [base], [r1] at the far end, [h]
  /// long along [axis]; [ex] / [ez] span its cross-section. The facets
  /// turned to the camera are lit one by one; [cap] closes the far end when
  /// it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    double opacity = 1,
    bool cap = true,
    int sides = 24,
  }) {
    if (h <= 0) return;
    final top = base + axis * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(ex, ez, (a0 + a1) / 2);
      final n = (m + axis * slope).unit;
      final mid = base + axis * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final d0 = _dir(ex, ez, a0), d1 = _dir(ex, ez, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = c);
      if (opacity >= 1) canvas.drawPath(path, pens.seam..color = c);
    }
    if (cap && axis.dot(_eyeAt - top) > 0) {
      disc(top, r1, _lit(color, axis, opacity: opacity), ex, ez);
    }
  }

  /// A flat disc of radius [r] centred at [c] in the plane ([ex], [ez]).
  void disc(_V c, double r, Color color, [_V ex = _V.right, _V ez = _V.front]) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// RingGeometry at [c] in the plane ([ex], [ez]) (MeshBasicMaterial: not
  /// lit); flat on the ground by default.
  void ring(
    _V c,
    double rIn,
    double rOut,
    Color color, [
    _V ex = _V.right,
    _V ez = _V.front,
  ]) {
    // `reset()` also resets the fill type, so set it again each time.
    final path = pens.ringPath
      ..reset()
      ..fillType = PathFillType.evenOdd;
    for (final r in [rOut, rIn]) {
      for (var i = 0; i < _ringSides; i++) {
        final o = cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
    }
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A round limb from [a] to [b] (a thin CylinderGeometry of radius [r]).
  void limb(_V a, _V b, double r, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final w = math.max(1.2, 2 * r * cam.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      pa,
      pb,
      pens.limb
        ..strokeWidth = w
        ..color = color,
    );
  }

  /// SphereGeometry: a lit disc with its shaded side away from the key
  /// light and a highlight (no gradient, so nothing is allocated).
  void sphere(_V c, double r, Color color, {bool shine = true}) {
    final o = cam.p(c);
    final rr = r * cam.scaleAt(c);
    canvas.drawCircle(o, rr, pens.fill..color = labShade(color, -0.25));
    canvas.drawCircle(
      o + Offset(rr * 0.12, -rr * 0.14),
      rr * 0.84,
      pens.fill..color = color,
    );
    if (shine) {
      canvas.drawCircle(
        o + Offset(rr * 0.3, -rr * 0.34),
        rr * 0.24,
        pens.fill..color = labShade(color, 0.4),
      );
    }
  }

  /// Soft blurred shadow of an elliptic footprint on the surface at height
  /// [y].
  void shadow(double x, double y, double z, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, y + 0.003, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// Points of the rim of radius [r] around [c] in the plane ([ex], [ez]).
  List<Offset> rim(_V c, double r, [_V ex = _V.right, _V ez = _V.front]) => [
    for (var i = 0; i < _ringSides; i++)
      cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r),
  ];

  /// Clear glass (transparent MeshPhongMaterial), back part: the faint body
  /// and the far halves of its rims. Draw the contents next and
  /// [glassFront] last.
  void glassBack(
    _V base,
    double r0,
    double r1,
    double h, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    Color tint = _Colors.glass,
    double body = 0.1,
  }) {
    final top = base + axis * h;
    final hull = _hull([...rim(base, r0, ex, ez), ...rim(top, r1, ex, ez)]);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = tint.withValues(alpha: body));
    halfRim(base, r0, ex, ez, near: false, alpha: 0.25, tint: tint);
    halfRim(top, r1, ex, ez, near: false, alpha: 0.35, tint: tint);
  }

  /// Clear glass, front part: the near rims, the silhouette edges and a
  /// highlight stripe.
  void glassFront(
    _V base,
    double r0,
    double r1,
    double h, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    Color tint = _Colors.glass,
  }) {
    final top = base + axis * h;
    halfRim(base, r0, ex, ez, near: true, alpha: 0.45, tint: tint);
    halfRim(top, r1, ex, ez, near: true, alpha: 0.6, tint: tint);
    final v = _eyeAt - (base + axis * (h / 2));
    final a = math.atan2(-ex.dot(v), ez.dot(v));
    final edge = pens.stroke
      ..strokeWidth = 1.2
      ..color = tint.withValues(alpha: 0.5);
    for (final s in [a, a + math.pi]) {
      final d = _dir(ex, ez, s);
      canvas.drawLine(cam.p(base + d * r0), cam.p(top + d * r1), edge);
    }
    final hl = _dir(ex, ez, a + math.pi * 0.72);
    canvas.drawLine(
      cam.p(base + axis * (h * 0.12) + hl * (r0 * 0.8)),
      cam.p(base + axis * (h * 0.88) + hl * (r1 * 0.8)),
      pens.limb
        ..strokeWidth = math.max(1.5, 0.12 * cam.scaleAt(base))
        ..color = tint.withValues(alpha: 0.3),
    );
  }

  /// The near or far half of a rim (seen from the camera).
  void halfRim(
    _V c,
    double r,
    _V ex,
    _V ez, {
    required bool near,
    required double alpha,
    required Color tint,
  }) {
    final v = _eyeAt - c;
    final path = pens.path..reset();
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final d = _dir(ex, ez, i * 2 * math.pi / _ringSides);
      final isNear = d.dot(v) > 0;
      final o = cam.p(c + d * r);
      if (isNear == near) {
        if (open) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          open = true;
        }
      } else {
        open = false;
      }
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 1.4
        ..color = tint.withValues(alpha: alpha),
    );
  }

  /// A small flickering flame standing on [base] ([height] world units;
  /// [t] is the scene time).
  void flame(_V base, double height, double t, {double intensity = 1}) {
    if (intensity <= 0) return;
    final o = cam.p(base);
    final k = cam.scaleAt(base);
    final flick = 1 + 0.1 * math.sin(t * 17) + 0.06 * math.sin(t * 29 + 1.3);
    final h = height * k * flick * intensity;
    final w = h * 0.42;
    void drop(double sx, double sy, Color color) {
      final path = pens.path
        ..reset()
        ..moveTo(o.dx, o.dy - h * sy)
        ..cubicTo(
          o.dx + w * sx,
          o.dy - h * sy * 0.55,
          o.dx + w * sx * 0.9,
          o.dy,
          o.dx,
          o.dy,
        )
        ..cubicTo(
          o.dx - w * sx * 0.9,
          o.dy,
          o.dx - w * sx,
          o.dy - h * sy * 0.55,
          o.dx,
          o.dy - h * sy,
        )
        ..close();
      canvas.drawPath(path, pens.fill..color = color);
    }

    canvas.drawCircle(
      o.translate(0, -h * 0.4),
      h * 0.9,
      pens.soft..color = _Colors.flame.withValues(alpha: 0.3 * intensity),
    );
    drop(1, 1, _Colors.flame.withValues(alpha: 0.95));
    drop(0.6, 0.65, _Colors.flameCore);
  }
}

/// The scene's static layer: background and the bench with the shelf (S1)
/// or the ocean and the land (S2).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  if (scenario == 0) {
    // `workbenchS1` BoxGeometry(40, 2, 20) at y -1, `shelfS1`
    // BoxGeometry(30, 1, 6) at (0, 10, -8).
    _Gfx(canvas, _camBench, pens)
      ..box(const _V(0, -1, 0), const _V(40, 2, 20), _Colors.bench, edge: 0.4)
      ..box(const _V(0, 10, -8), const _V(30, 1, 6), _Colors.shelf, edge: 0.4);
    return;
  }
  final g = _Gfx(canvas, _camLand, pens)
    // Deep ocean (left) and the land's soil (right): BoxGeometry(22, 5,
    // 15) at (∓11, -1.5, 0); the shore's grass (22 x 0.4 x 15) at y 1.2.
    ..box(
      const _V(-11, -1.5, 0),
      const _V(22, 5, 15),
      _Colors.ocean,
      opacity: 0.85,
      edge: 0.3,
    )
    ..box(const _V(11, -1.5, 0), const _V(22, 5, 15), _Colors.dirt, edge: 0.4)
    ..box(
      const _V(11, 1.2, 0),
      const _V(22, 0.4, 15),
      _Colors.grass,
      edge: 0.3,
    );
  // The mountain: a wedge rising from the shore (y 1.4 at x 0) to y 9 at
  // x 22, under a 0.2 grass skin; its front shows soil under a grass band.
  const top = _shoreTop + _grassSkin;
  const peak = _peakY + _grassSkin;
  const slopeN = _V(-0.3264, 0.9452, 0); // (-7.6, 22, 0) normalised
  g
    ..poly([
      const _V(0, top, _landHalfZ),
      const _V(_landHalfX, peak, _landHalfZ),
      const _V(_landHalfX, peak, -_landHalfZ),
      const _V(0, top, -_landHalfZ),
    ], _lit(_Colors.grass, slopeN))
    ..poly([
      const _V(0, _shoreTop, _landHalfZ),
      const _V(_landHalfX, _shoreTop, _landHalfZ),
      const _V(_landHalfX, peak, _landHalfZ),
    ], _lit(_Colors.dirt, _V.front))
    ..poly([
      const _V(0, _shoreTop, _landHalfZ),
      const _V(0, top, _landHalfZ),
      const _V(_landHalfX, peak, _landHalfZ),
      const _V(_landHalfX, peak - 0.8, _landHalfZ),
      const _V(1.74, _shoreTop, _landHalfZ),
    ], _lit(_Colors.grass, _V.front));
}

/// Paints the HTML Three.js scene of the current scenario: S1 the bench and
/// shelf with the bottle, cup, cap, match and dish, S2 the landscape with
/// the Sun, the cloud, the rain, the river and the four icons.
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

  /// Scene x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  /// Smoke over the bench and against the scene's background.
  Color get _smokeColor => isDark ? _Colors.smokeOnDark : _Colors.smoke;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintBench(canvas);
    } else {
      _paintLand(canvas);
    }
  }

  /// HTML `update3DHighlight`: how far [obj] pulses towards light blue now.
  double _pulse(_Obj obj) {
    final s = scene;
    if (s.glowing != obj) return 0;
    return (math.sin(s.time * _pulseRate) + 1) / 2 * _pulseMax;
  }

  // ---------------------------------------------------------- scenario 1

  void _paintBench(Canvas canvas) {
    final g = _Gfx(canvas, _camBench, _pens);
    final s = scene;
    final t = s.time;

    // `dropZoneS1Glow`: where the bottle goes (step 1) and where the cap is
    // put down (step 5).
    if (!s.done && s.step == 1) {
      g.ring(_ringBottle, _ringIn, _ringOut, _Colors.glow);
    } else if (!s.done && s.step == 5 && s.sub == 0) {
      g.ring(_ringCap, _ringIn, _ringOut, _Colors.glow);
    }

    // Contact shadows on the bench or the shelf.
    for (final obj in const [
      _Obj.bottle,
      _Obj.cup,
      _Obj.cap,
      _Obj.match,
      _Obj.dish,
    ]) {
      if (obj == _Obj.cap && s.capOn) continue;
      final p = s.posOf(obj);
      final r = switch (obj) {
        _Obj.bottle => 2.2,
        _Obj.cup => 1.4,
        _Obj.cap => 0.95,
        _Obj.match => 0.5,
        _ => 2.0,
      };
      final rest = obj == _Obj.cap ? p.y - _capH / 2 : p.y;
      final shelf = p.z < -5 && (rest - 10.5).abs() < 0.3;
      final bench = rest.abs() < 0.3;
      if (!shelf && !bench) continue;
      final x = obj == _Obj.match ? p.x + 1 : p.x;
      g.shadow(x - 0.3, shelf ? 10.5 : 0, p.z - 0.3, r, r * 0.8);
    }

    // Bodies far to near; the held object in front of everything.
    final parts = <_Obj>[
      _Obj.bottle,
      _Obj.cup,
      if (!s.capOn) _Obj.cap,
      _Obj.match,
      _Obj.dish,
    ];
    double depth(_Obj obj) {
      if (s.held == obj) return double.negativeInfinity;
      final p = s.posOf(obj);
      return _camBench.depth(switch (obj) {
        _Obj.bottle => p + const _V(0, 4.5, 0),
        _Obj.cup => p + const _V(0, 1.5, 0),
        _Obj.dish => p + const _V(0, 0.25, 0),
        _Obj.match => p + const _V(1, 0, 0),
        _ => p,
      });
    }

    parts.sort((a, b) => depth(b).compareTo(depth(a)));
    for (final obj in parts) {
      switch (obj) {
        case _Obj.bottle:
          _paintBottle(g, s.posOf(obj));
          if (s.capOn) _paintCap(g, s.posOf(_Obj.cap));
        case _Obj.cup:
          _paintCup(g, s.posOf(obj), s.cupTilt.at(t), s.cupWater.at(t));
        case _Obj.cap:
          _paintCap(g, s.posOf(obj));
        case _Obj.match:
          _paintMatch(g, s.posOf(obj));
        default:
          _paintDish(g, s.posOf(obj));
      }
    }

    if (showLabels) _benchLabels(canvas);
  }

  /// The bottle (`bottleGrpS1`): plastic body, shoulder and mouth around
  /// the water, the smoke and the cloud; a squeeze pinches its width (the
  /// HTML scaled only the plastic, so the water poked through it).
  void _paintBottle(_Gfx g, _V at) {
    final s = scene;
    final t = s.time;
    final cam = g.cam;
    final canvas = g.canvas;
    final k = 1 - _squeezeDepth * s.squeeze.at(t);
    final tint = _pulsed(_Colors.plastic, _pulse(_Obj.bottle));
    final rims = [
      (0.0, _bodyR * k),
      (_bodyTop, _bodyR * k),
      (_shoulderTop, _neckR * k),
      (_mouthTop, _neckR * k),
    ];
    final pts = <Offset>[
      for (final (y, r) in rims) ...g.rim(at + _V(0, y, 0), r),
    ];
    final outline = _hull(pts);
    final hull = _pens.hull..reset();
    for (var i = 0; i < outline.length; i++) {
      if (i == 0) {
        hull.moveTo(outline[i].dx, outline[i].dy);
      } else {
        hull.lineTo(outline[i].dx, outline[i].dy);
      }
    }
    hull.close();
    canvas.drawPath(hull, _pens.fill..color = tint.withValues(alpha: 0.14));
    for (final (y, r) in rims) {
      g.halfRim(
        at + _V(0, y, 0),
        r,
        _V.right,
        _V.front,
        near: false,
        alpha: 0.3,
        tint: tint,
      );
    }

    // Water (`bottleWaterS1`, filled from the bottom up by the pour).
    final fill = s.water.at(t);
    if (fill > 0) {
      g.cylinder(
        at,
        _waterR * k,
        _waterR * k,
        _waterH * fill,
        _Colors.water,
        opacity: 0.8,
      );
    }

    // The cup's stream, from its lip through the mouth to the water.
    final stream = s.stream.at(t);
    if (stream > 0) {
      final tilt = s.cupTilt.at(t);
      final cup = s.posOf(_Obj.cup);
      final lip =
          cup +
          _V(math.cos(tilt), -math.sin(tilt), 0) * _cupR1 +
          _V(math.sin(tilt), math.cos(tilt), 0) * _cupH;
      final bottom = at.y + math.max(0.1, _waterH * fill);
      final end = lip.atY(lip.y - (lip.y - bottom) * stream);
      canvas.drawLine(
        cam.p(lip),
        cam.p(end),
        _pens.limb
          ..strokeWidth = math.max(1.5, 0.4 * cam.scaleAt(lip))
          ..color = _Colors.water.withValues(alpha: 0.85),
      );
    }

    // Smoke particles (HTML `smokeMat` spheres of radius 0.1, drawn a little
    // larger so they stay visible on a phone).
    for (final sm in s.smoke) {
      final p = sm.at(t);
      if (p == null) continue;
      final q = _V(at.x + (p.x - at.x) * k, p.y, at.z + (p.z - at.z) * k);
      canvas.drawCircle(
        cam.p(q),
        math.max(1.2, _smokeR * cam.scaleAt(q)),
        _pens.fill..color = _smokeColor.withValues(alpha: 0.75),
      );
    }

    // The cloud (step 7), kept inside the plastic.
    if (s.cloudOn) {
      final cs = s.cloudScale.at(t);
      final alpha = s.cloudAlpha.at(t);
      canvas.save();
      canvas.clipPath(hull);
      final paint = _pens.soft
        ..color = _Colors.cloud.withValues(alpha: alpha * 0.6);
      for (final puff in _bottlePuffs) {
        final o = puff.offset;
        final c = at + _V(o.x * k * cs, 4 + (o.y - 4) * cs, o.z * k * cs);
        canvas.drawCircle(cam.p(c), puff.radius * cs * cam.scaleAt(c), paint);
      }
      canvas.restore();
    }

    for (final (y, r) in rims) {
      g.halfRim(
        at + _V(0, y, 0),
        r,
        _V.right,
        _V.front,
        near: true,
        alpha: 0.55,
        tint: tint,
      );
    }
    canvas.drawPath(
      hull,
      _pens.stroke
        ..strokeWidth = 1.4
        ..color = tint.withValues(alpha: 0.6),
    );
    // Highlight towards the key light.
    canvas.drawLine(
      cam.p(at + _V(1.1 * k, 0.5, 1.2 * k)),
      cam.p(at + _V(1.1 * k, _bodyTop - 0.3, 1.2 * k)),
      _pens.limb
        ..strokeWidth = math.max(1.5, 0.18 * cam.scaleAt(at))
        ..color = _Colors.white.withValues(alpha: 0.3),
    );
  }

  /// `capS1`: a blue cylinder centred on [at].
  void _paintCap(_Gfx g, _V at) {
    g.cylinder(
      at - const _V(0, _capH / 2, 0),
      _capR,
      _capR,
      _capH,
      _pulsed(_Colors.cap, _pulse(_Obj.cap)),
    );
  }

  /// `cupS1`: a glass tumbler with water, tilted by [tilt] towards the
  /// bottle about its base; [level] empties as it pours.
  void _paintCup(_Gfx g, _V at, double tilt, double level) {
    final axis = _V(math.sin(tilt), math.cos(tilt), 0);
    final ex = _V(math.cos(tilt), -math.sin(tilt), 0);
    final tint = _pulsed(_Colors.glass, _pulse(_Obj.cup));
    g.glassBack(at, _cupR0, _cupR1, _cupH, axis: axis, ex: ex, tint: tint);
    if (level > 0) {
      final h = 2 * level;
      g.cylinder(
        at + axis * 0.1,
        1.15,
        1.15 + 0.25 * level,
        h,
        _Colors.water,
        axis: axis,
        ex: ex,
        opacity: 0.8,
      );
    }
    g.glassFront(at, _cupR0, _cupR1, _cupH, axis: axis, ex: ex, tint: tint);
  }

  /// `matchS1`: the stick and its red tip; lit (step 5) it burns at the tip
  /// until it lights the paper, then the burnt tip is dark.
  void _paintMatch(_Gfx g, _V at) {
    final s = scene;
    final tip = at + const _V(_matchLen, 0, 0);
    g.limb(at, tip, 0.06, _pulsed(_Colors.matchStick, _pulse(_Obj.match)));
    final lit = s.step == 5 && s.sub == 1 && !s.paperBurnt;
    g.sphere(
      tip,
      0.2,
      s.paperBurnt ? _Colors.slate700 : _Colors.matchTip,
      shine: false,
    );
    if (lit) g.flame(tip + const _V(0.05, 0.1, 0), 0.9, s.time);
  }

  /// `dishS1`: a shallow glass dish with the paper; once lit the paper
  /// burns briefly and smokes until the smoke goes into the bottle.
  void _paintDish(_Gfx g, _V at) {
    final s = scene;
    final t = s.time;
    final tint = _pulsed(_Colors.glass, _pulse(_Obj.dish));
    g.glassBack(at, _dishR0, _dishR1, _dishH, tint: tint, body: 0.18);
    g.box(
      at + const _V(0, _paperY, 0),
      const _V(_paperSize, 0.1, _paperSize),
      s.paperBurnt ? _Colors.paperBurnt : _Colors.paper,
      yaw: math.pi / 4,
    );
    g.glassFront(at, _dishR0, _dishR1, _dishH, tint: tint);
    if (!s.paperBurnt) return;
    final burning = t - s.burnAt;
    final paper = at + const _V(0, _paperY + 0.05, 0);
    if (burning < _paperFlameSeconds) {
      g.flame(paper, 1.1, t, intensity: 1 - burning / _paperFlameSeconds);
    }
    if (s.smokeAt >= 0) return;
    final cam = g.cam;
    for (var i = 0; i < 6; i++) {
      final ph = (burning * 0.7 + i / 6) % 1;
      final p = paper + _V(math.sin(t * 2 + i) * 0.3, 0.3 + ph * 3, 0);
      g.canvas.drawCircle(
        cam.p(p),
        (0.2 + ph * 0.45) * cam.scaleAt(p),
        _pens.soft..color = _smokeColor.withValues(alpha: 0.6 * (1 - ph)),
      );
    }
  }

  /// HTML `createStdLabel`s. The bottle's label hangs under the shelf / its
  /// base, the dish's and the cap's under them and the match's above it, as
  /// in the HTML; the cup's goes above the cup (under it, the HTML label
  /// covered the neck of the bottle on the bench) and the cap's beside it
  /// on the bottle (it covered the space where the cloud forms).
  void _benchLabels(Canvas canvas) {
    final s = scene;
    final cam = _camBench;
    final t = s.time;
    _chip(
      canvas,
      cam.p(s.posOf(_Obj.bottle) + const _V(0, -4, 0)),
      _t('lbl_bottle'),
    );
    final cup = s.posOf(_Obj.cup);
    final tilt = s.cupTilt.at(t);
    _chip(
      canvas,
      cam.p(cup + _V(math.sin(tilt), math.cos(tilt), 0) * (_cupH + 0.9)),
      _t('lbl_water_cup'),
    );
    final cap = s.posOf(_Obj.cap);
    if (s.capOn) {
      _chip(
        canvas,
        cam.p(cap + const _V(_capR + 0.4, 0, 0)),
        _t('lbl_cap'),
        anchor: Alignment.centerLeft,
      );
    } else if (cap.y < _benchLabelY) {
      // Put aside on the bench: left of the cap, clear of the bottle's
      // label.
      _chip(
        canvas,
        cam.p(cap + const _V(-_capR - 0.5, 0, 0)),
        _t('lbl_cap'),
        anchor: Alignment.centerRight,
      );
    } else {
      _chip(canvas, cam.p(cap + const _V(0, -2, 0)), _t('lbl_cap'));
    }
    _chip(
      canvas,
      cam.p(s.posOf(_Obj.match) + const _V(1, 3, 0)),
      _t('lbl_match'),
    );
    final dish = s.posOf(_Obj.dish);
    if (dish.y > _benchLabelY) {
      // Lifted to the bottle: right of the dish, clear of the bottle's
      // mouth where the smoke goes in.
      _chip(
        canvas,
        cam.p(dish + const _V(_dishR1 + 0.4, _dishH / 2, 0)),
        _t('lbl_paper'),
        anchor: Alignment.centerLeft,
      );
    } else {
      _chip(canvas, cam.p(dish + const _V(0, -2, 0)), _t('lbl_paper'));
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintLand(Canvas canvas) {
    final g = _Gfx(canvas, _camLand, _pens);
    final s = scene;

    _paintRiver(g);
    // The glowing riverbed (step 4).
    if (s.step == 4 && s.riverShown) {
      _riverStrip(g, 2.43, 17.57, 1, 0.3, _Colors.glow);
      _riverStrip(
        g,
        2.43,
        17.57,
        1,
        0.3,
        _Colors.blue500.withValues(alpha: 0.8),
        outline: true,
      );
    }
    _paintVapour(g);
    // The glowing vapour zone (step 2).
    if (s.step == 2 && s.dustShown) {
      g.box(
        _zone,
        _zoneHalf * 2,
        _Colors.blue500,
        opacity: 0.16,
        edgeColor: _Colors.blue400.withValues(alpha: 0.7),
      );
    }
    // The Heat Source slot (step 1): a glowing ring facing the camera.
    if (!s.sunPlaced) {
      g.ring(
        _slot,
        _slotIn,
        _slotOut,
        _Colors.blue500.withValues(alpha: 0.6),
        _V.right,
        _V.up,
      );
    }
    // The Sun in its slot, behind the cloud.
    if (s.sunPlaced && s.held != _Obj.sun) _paintSun(g, s.posOf(_Obj.sun));
    _paintRain(g);
    if (s.cloudShown) _paintCloud(g);

    // The icons still to use; the held one in front.
    final icons = <_Obj>[
      if (!s.sunPlaced || s.held == _Obj.sun) _Obj.sun,
      if (s.dustShown) _Obj.dust,
      if (s.snowShown) _Obj.snow,
      if (s.riverShown) _Obj.river,
    ];
    final held = s.held;
    if (held != null && icons.remove(held)) icons.add(held);
    for (final obj in icons) {
      final p = s.posOf(obj);
      switch (obj) {
        case _Obj.sun:
          _paintSun(g, p);
        case _Obj.dust:
          _paintDust(g, p);
        case _Obj.snow:
          _paintSnow(g, p);
        default:
          _paintRiverIcon(g, p);
      }
    }

    _landLabels(canvas);
  }

  /// A strip along the slope from x [x0] to [x1], [half] wide in z, lifted
  /// [lift] above the ground (the river, or the glowing riverbed).
  void _riverStrip(
    _Gfx g,
    double x0,
    double x1,
    double half,
    double lift,
    Color color, {
    bool outline = false,
  }) {
    final cam = g.cam;
    final path = _pens.path..reset();
    final xs = <double>[x0, if (x0 < 0 && x1 > 0) 0, x1];
    for (var i = 0; i < xs.length; i++) {
      final o = cam.p(_V(xs[i], _groundAt(xs[i]) + lift, half));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    for (final x in xs.reversed) {
      final o = cam.p(_V(x, _groundAt(x) + lift, -half));
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    if (outline) {
      g.canvas.drawPath(
        path,
        _pens.stroke
          ..strokeWidth = 1.5
          ..color = color,
      );
    } else {
      g.canvas.drawPath(path, _pens.fill..color = color);
    }
  }

  /// `finalRiverS2`: the river runs down the slope from the mountain top
  /// to the ocean, then keeps flowing (moving highlights).
  void _paintRiver(_Gfx g) {
    final s = scene;
    final f = s.riverFlow.at(s.time);
    if (f <= 0) return;
    const x1 = 21.0;
    const xEnd = -0.6;
    final x0 = x1 - (x1 - xEnd) * f;
    _riverStrip(g, x0, x1, 1, 0.08, _Colors.water.withValues(alpha: 0.9));
    final cam = g.cam;
    final paint = _pens.limb
      ..strokeWidth = math.max(1.2, 0.12 * cam.scaleAt(_bed))
      ..color = _Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 7; i++) {
      final u = (s.time * 0.3 + i / 7) % 1;
      final x = x1 - u * (x1 - x0);
      final z = (i.isEven ? 0.4 : -0.4);
      final a = _V(x, _groundAt(x) + 0.1, z);
      final bx = math.max(x0, x - 1.4);
      final b = _V(bx, _groundAt(bx) + 0.1, z);
      g.canvas.drawLine(cam.p(a), cam.p(b), paint);
    }
  }

  /// `s2EvapParticles`: thin streaks rising and swaying over the ocean.
  void _paintVapour(_Gfx g) {
    final s = scene;
    if (s.vapour.isEmpty) return;
    final cam = g.cam;
    final ms = s.time * 1000;
    final paint = _pens.limb
      ..strokeWidth = math.max(1.0, 0.1 * cam.scaleAt(_zone))
      ..color = isDark ? _Colors.vapourDark : _Colors.vapourLight;
    for (final v in s.vapour) {
      final x = v.x0 + math.sin(ms * 0.005 + v.y) * 0.4;
      g.canvas.drawLine(
        cam.p(_V(x, v.y, v.z)),
        cam.p(_V(x, v.y + 1.5, v.z)),
        paint,
      );
    }
  }

  /// `s2RainParticles`: short streaks falling from the cloud.
  void _paintRain(_Gfx g) {
    final s = scene;
    if (s.rain.isEmpty) return;
    final cam = g.cam;
    final centre = s.cloudCentre;
    final half = s.rainHalfWidth;
    final paint = _pens.limb
      ..strokeWidth = math.max(1.0, 0.12 * cam.scaleAt(centre))
      ..color = _Colors.water.withValues(alpha: 0.85);
    for (final d in s.rain) {
      final p = _V(centre.x + d.u * half + d.drift, d.y, d.z);
      g.canvas.drawLine(cam.p(p), cam.p(p - const _V(0, 0.45, 0)), paint);
    }
  }

  /// `cloudGrpS2`: white puffs growing in (Elastic.Out); grey and spread
  /// out once it rains.
  void _paintCloud(_Gfx g) {
    final s = scene;
    final t = s.time;
    final grow = s.cloudGrow.at(t);
    if (grow <= 0.01) return;
    final c = s.cloudCentre;
    final wide = s.cloudWidth;
    final color = Color.lerp(
      _Colors.cloud,
      _Colors.rainCloud,
      s.cloudGrey.at(t),
    )!;
    for (final puff in _skyPuffsByDepth) {
      final o = puff.offset;
      g.sphere(
        c + _V(o.x * grow * wide, o.y * grow, o.z * grow),
        puff.radius * grow,
        color,
        shine: false,
      );
    }
  }

  /// `sunS2`: the core and eight rays; once in its slot it glows (the
  /// observation says it brightens). While it is the object to drag, a
  /// light blue halo pulses behind it (tinting the yellow Sun blue turned
  /// it green).
  void _paintSun(_Gfx g, _V at) {
    final s = scene;
    final cam = g.cam;
    final k = cam.scaleAt(at);
    final o = cam.p(at);
    final amount = _pulse(_Obj.sun);
    if (amount > 0) {
      g.canvas.drawCircle(
        o,
        2.8 * k,
        _pens.soft..color = _Colors.highlight.withValues(alpha: amount),
      );
    }
    if (s.sunPlaced) {
      final on = ((s.time - s.sunAt) / 0.5).clamp(0.0, 1.0);
      final glow = on * (0.85 + 0.15 * math.sin(s.time * 3));
      for (final (r, a) in const [(4.2, 0.12), (3.2, 0.18), (2.4, 0.25)]) {
        g.canvas.drawCircle(
          o,
          r * k,
          _pens.soft..color = _Colors.sunRay.withValues(alpha: a * glow),
        );
      }
    }
    const ray = _Colors.sunRay;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dir = Offset(math.cos(a), -math.sin(a));
      final side = Offset(-dir.dy, dir.dx);
      final path = _pens.path
        ..reset()
        ..moveTo(o.dx + dir.dx * 2.4 * k, o.dy + dir.dy * 2.4 * k)
        ..lineTo(
          o.dx + dir.dx * 1.2 * k + side.dx * 0.3 * k,
          o.dy + dir.dy * 1.2 * k + side.dy * 0.3 * k,
        )
        ..lineTo(
          o.dx + dir.dx * 1.2 * k - side.dx * 0.3 * k,
          o.dy + dir.dy * 1.2 * k - side.dy * 0.3 * k,
        )
        ..close();
      g.canvas.drawPath(path, _pens.fill..color = ray);
    }
    g.canvas.drawCircle(o, 1.2 * k, _pens.fill..color = _Colors.sunCore);
  }

  /// A flat 2.5 x 2.5 icon tile facing the camera.
  void _tile(_Gfx g, _V at, Color color) {
    g.poly([
      at + const _V(-1.25, -1.25, 0),
      at + const _V(1.25, -1.25, 0),
      at + const _V(1.25, 1.25, 0),
      at + const _V(-1.25, 1.25, 0),
    ], color);
  }

  /// `dustS2`: a dark tile with white dust specks.
  void _paintDust(_Gfx g, _V at) {
    _tile(g, at, _pulsed(_Colors.dustTile, _pulse(_Obj.dust)));
    final cam = g.cam;
    final r = math.max(1.0, 0.15 * cam.scaleAt(at));
    final paint = _pens.fill..color = _Colors.white;
    for (final d in _dustSpecks) {
      g.canvas.drawCircle(cam.p(at + _V(d.dx, d.dy, 0.15)), r, paint);
    }
  }

  /// `snowS2`: a light blue tile with a white snowflake (three bars).
  void _paintSnow(_Gfx g, _V at) {
    _tile(g, at, _pulsed(_Colors.snowTile, _pulse(_Obj.snow)));
    for (var i = 0; i < 3; i++) {
      final a = math.pi / 2 + i * math.pi / 3;
      final d = _V(math.cos(a), math.sin(a), 0);
      g.limb(at + d, at - d, 0.1, _Colors.white);
    }
  }

  /// `riverS2`: a short stretch of water ending in an arrow head pointing
  /// down to the left (towards the ocean).
  void _paintRiverIcon(_Gfx g, _V at) {
    final color = _pulsed(_Colors.water, _pulse(_Obj.river));
    const a = math.pi / 8;
    final d = _V(math.cos(a), math.sin(a), 0);
    g.limb(at + d * 2, at - d * 1.4, 0.3, color);
    final cam = g.cam;
    final k = cam.scaleAt(at);
    final tip = cam.p(at - d * 2.4);
    final base = cam.p(at - d * 1.3);
    final n = Offset(-math.sin(a), -math.cos(a)) * (0.8 * k);
    final path = _pens.path
      ..reset()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + n.dx, base.dy + n.dy)
      ..lineTo(base.dx - n.dx, base.dy - n.dy)
      ..close();
    g.canvas.drawPath(path, _pens.fill..color = color);
  }

  /// HTML `createStdLabel`s ('Heat Source' added under its slot) and
  /// `createActionLabel`s. The HTML hung every icon's label under it; on a
  /// phone the four labels ran into each other and the Sun's covered the
  /// slot, so the Sun's label sits left of it (also clear of the cloud once
  /// the Sun is in its slot), Dust Particles and River Segment above their
  /// icons and Cool Air under it. The HTML attached EVAPORATION to the
  /// hidden slot, so it never showed, and put PRECIPITATION on top of it;
  /// it now sits on the ocean where the vapour rises.
  void _landLabels(Canvas canvas) {
    final s = scene;
    final cam = _camLand;
    if (showLabels) {
      if (!s.sunPlaced) {
        _chip(
          canvas,
          cam.p(_slot - const _V(0, _slotLabelGap, 0)),
          _t('lbl_slot'),
          anchor: Alignment.topCenter,
        );
      }
      _chip(
        canvas,
        cam.p(s.posOf(_Obj.sun) - const _V(_sunLabelGap, 0, 0)),
        _t('lbl_sun'),
        anchor: Alignment.centerRight,
      );
      if (s.dustShown) {
        _chip(
          canvas,
          cam.p(s.posOf(_Obj.dust) + const _V(0, _iconLabelGap, 0)),
          _t('lbl_dust'),
          anchor: Alignment.bottomCenter,
        );
      }
      if (s.snowShown) {
        _chip(
          canvas,
          cam.p(s.posOf(_Obj.snow) - const _V(0, _iconLabelGap, 0)),
          _t('lbl_snow'),
          anchor: Alignment.topCenter,
        );
      }
      if (s.riverShown) {
        _chip(
          canvas,
          cam.p(s.posOf(_Obj.river) + const _V(0, _iconLabelGap, 0)),
          _t('lbl_river'),
          anchor: Alignment.bottomCenter,
        );
      }
    }
    // Action labels stay visible with the labels toggled off, as in the
    // HTML (`thermometer-label`).
    if (s.lblEvap) {
      _chip(canvas, cam.p(const _V(-16, 2.5, 3)), _t('lbl_evap'), action: true);
    }
    if (s.lblCond) {
      _chip(
        canvas,
        cam.p(s.cloudCentre + const _V(0, 4, 0)),
        _t('lbl_cond'),
        action: true,
      );
    }
    if (s.lblPrecip) {
      _chip(
        canvas,
        cam.p(s.cloudCentre + const _V(-1, -8, 0)),
        _t('lbl_precip'),
        action: true,
      );
    }
    if (s.lblCollect) {
      _chip(
        canvas,
        cam.p(const _V(10, 1.5, 0.1)),
        _t('lbl_collect'),
        action: true,
      );
    }
  }

  // ------------------------------------------------------------ labels

  /// A label chip (HTML `.label-3d`) placed by [anchor] at [at], kept left
  /// of the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    bool action = false,
    Alignment anchor = Alignment.center,
  }) {
    final chip = action ? _Chip.action : (isDark ? _Chip.dark : _Chip.light);
    final tp = cache.label(text, chip);
    final size = cache.labelSize;
    final padX = size * 0.65, padY = size * 0.32;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final cx = at.dx - anchor.x * w / 2;
    final minX = w / 2 + 4;
    final x = cx.clamp(minX, math.max(minX, labelRight - w / 2 - 4)).toDouble();
    final rect = Rect.fromCenter(
      center: Offset(x, at.dy - anchor.y * h / 2),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(action ? h / 2 : size * 0.5),
    );
    canvas.drawRRect(
      rr,
      _pens.fill
        ..color = switch (chip) {
          _Chip.dark => _Colors.labelDark,
          _Chip.light => _Colors.labelLight,
          _Chip.action => _Colors.emerald100,
        },
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = action ? _Colors.emerald400 : _Colors.blue400,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
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

/// The sky cloud's puffs, far to near (drawn in this order).
final List<_Puff> _skyPuffsByDepth = [..._skyPuffs]
  ..sort((a, b) => a.offset.z.compareTo(b.offset.z));

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
