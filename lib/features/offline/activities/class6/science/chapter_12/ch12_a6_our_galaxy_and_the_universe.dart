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

/// Class 6 Science • Chapter 12 (Beyond Earth) • Activity 6
/// Our Galaxy and the Universe ("Our Place in the Cosmos").
///
/// Native Flutter port of `Cl6S-Ch12-A6-Our_Galaxy_and_the_Universe.html`
/// (Three.js r128 + Tween.js). The Three.js scenes are redrawn by
/// [_ScenePainter] through the HTML's 60° perspective cameras; the star
/// clouds (the Milky Way band, the local spiral arm, the barred spiral
/// galaxy and the universe of galaxies) are projected every frame into
/// colour-binned point batches, and the static city skyline is recorded
/// once into two pictures (lights off / lights on) that are blended by the
/// slider.
///
/// Scenario 1 (The Hidden River of Stars): a city skyline at night with
/// glowing windows, street lamps and red beacons under a hazy, light-polluted
/// sky. Dragging the 'Light Pollution' slider from High towards Low dims the
/// city's lights and darkens the sky; below 60 the step is done ('City
/// lights dimming!'), and at 8 or less (the slider title reads 'Dark Sky
/// Reserve') thousands of faint stars and the glowing band of the Milky Way
/// (Ākāśha Gangā) with its golden core fade in across the sky, as in the
/// dark sky of Nubra in Ladakh. 'Observe Conclusion' opens the summary.
///
/// Scenario 2 (Our Cosmic Address): the Solar System, the Sun with its
/// corona and a ring of glowing prominences and the eight planets on their
/// orbits. Each tap on 'ZOOM OUT' swaps in the next, larger level while the
/// camera pulls back further and faster (1.2 s, 1.4 s, 1.8 s, Cubic.Out):
/// our Solar System as one point in the Orion Spiral Arm, the full barred
/// spiral Milky Way Galaxy, and finally hundreds of galaxies scattered
/// across the Universe with the banner 'There are many galaxies in the outer
/// space beyond the Milky Way Galaxy'. 'Observe Conclusion' shows the
/// summary and then 'Mastery Achieved!' with 'Restart Entire Lab'.
///
/// Changes from the HTML: its default (locked) camera looked down at the
/// city, so the Milky Way arch (16 to 241 units above the ground) and the
/// dome's stars (generated in the z > 0 half of the dome, behind the
/// camera) were never on screen; here the dome is drawn as a backdrop seen
/// from further back ([_skyView]) so the band arches over the skyline, the
/// stars fill the upper half of the dome, and the band's slow spin
/// (`rotation.y += 0.0004` a frame, which turned the arch edge-on after a
/// minute) streams its stars along the arch at the same rate. The ground
/// plane runs across the whole stage. The street lamps and beacons fade
/// with the windows (the HTML set their opacity, which Three.js ignores on
/// opaque materials). The cameras keep looking at their targets during the
/// zoom tweens (the locked HTML camera kept its old direction, so the view
/// drifted off the new level), the levels cross-fade for 0.35 s instead of
/// swapping in one frame, and the local arm turns about our Solar System's
/// dot (the HTML turned it about the galactic centre, so the dot left its
/// label and the arm drifted out of view). The corona is drawn as round
/// glows (the HTML mapped its radial glow texture onto sphere UVs). The
/// scene labels fade in once (the HTML rebuilt them every frame, restarting
/// their fade-in). The HTML never showed Scenario 2's summary; it is shown
/// before 'Mastery Achieved!'. The Scenario 1 summary offers 'Next Scenario'
/// (HTML `next_sc`) besides its note to pick the next scenario.
class Ch12A6OurGalaxyAndTheUniversePage extends StatefulWidget {
  const Ch12A6OurGalaxyAndTheUniversePage({super.key});

  @override
  State<Ch12A6OurGalaxyAndTheUniversePage> createState() => _GalaxyLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises three Web Audio tones: `pop` (Enter Lab, the scenario
/// selector, every 'ZOOM OUT', the step accordion, the sidebar, settings
/// and closing a popup) → `science/click.mp3` (and the shell's curtain,
/// scenario and toggle tones), `success` (the conclusion and mastery
/// popups) → `math/success.mp3`, and `click` (defined, never played). The
/// HTML's toasts are silent, and so are they here; the shell's correct /
/// wrong tones (`math/success.mp3` / `science/error.mp3`) are kept for its
/// own feedback.
enum _Sound implements LabTone {
  /// Generic button click; a step card opened or closed (HTML `pop`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse (HTML `pop`).
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast (this lab's toasts are silent).
  correct('audio/class6/math/success.mp3'),

  /// Shell feedback for an error toast (this lab shows none).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the conclusion and 'Mastery Achieved!' popups.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed (HTML `pop`).
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing (HTML `pop`).
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: a tap on 'ZOOM OUT'.
  pop('audio/class6/science/click.mp3');

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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scenes
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color slate50 = Color(0xFFF8FAFC);
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
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange600 = Color(0xFFEA580C);

  // ------------------------------------------------------------- scene 1
  /// `s1CityLightsGroup` window texture: '#fef08a', '#fde047', '#fbbf24',
  /// '#fdba74' and 'rgba(254,240,138,0.2)'.
  static const List<Color> windows = [
    yellow200,
    yellow300,
    amber400,
    orange300,
    Color(0x33FEF08A),
  ];

  /// The dark building texture (#0f172a) times the material colour
  /// (0x1e293b), the top tier's colour (0x334155), the roof caps (0x334155,
  /// untextured), the spire (0x475569) and the ground plane (0x090d16).
  static const Color buildingTexel = slate900;
  static const Color buildingTint = slate800;
  static const Color topTierTint = slate700;
  static const Color roofCap = slate700;
  static const Color spire = slate600;
  static const Color ground = Color(0xFF090D16);

  /// Antennas (MeshBasic 0x94a3b8), the red beacons (0xef4444) and the
  /// street lamps (0xfbbf24); the lamps' point lights are 0xf59e0b.
  static const Color antenna = slate400;
  static const Color beacon = red500;
  static const Color lamp = amber400;
  static const Color lampLight = amber500;

  /// Lights: ambient 0x1e293b (0.9) and the city's directional light
  /// 0xfbbf24 (1.4 × the pollution level).
  static const Color cityAmbient = slate800;
  static const Color cityLight = amber400;

  /// Dome stars: bright (white, 0.95) and faint (0xe2e8f0).
  static const Color brightStar = white;
  static const Color faintStar = slate200;

  /// The Milky Way band: core 0xfef08a, arm 0x93c5fd, dust 0x38bdf8; the
  /// core cloud 0xfef08a.
  static const Color bandCore = yellow200;
  static const Color bandArm = blue300;
  static const Color bandDust = sky400;
  static const Color coreCloud = yellow200;

  // ------------------------------------------------------------- scene 2
  /// The renderer's clear colour behind Scenario 2 (no scene background).
  static const Color space = black;

  /// Background stars (0x94a3b8, 0.65).
  static const Color spaceStar = slate400;

  /// `createSunSurfaceTexture()`: #fffbeb → #fde047 → #f59e0b → #ea580c,
  /// with light (rgba(255,251,235,0.25)) and dark (rgba(194,65,12,0.3))
  /// blotches.
  static const Color sunWhite = Color(0xFFFFFBEB);
  static const Color sunYellow = yellow300;
  static const Color sunAmber = amber500;
  static const Color sunOrange = orange600;
  static const Color sunBlotchLight = Color(0x40FFFBEB);
  static const Color sunBlotchDark = Color(0x4DC2410C);

  /// `createSunGlowTexture()`: rgba(254,240,138,1) → rgba(245,158,11,0.75)
  /// → rgba(234,88,12,0.25) → transparent.
  static const Color glowCore = yellow200;
  static const Color glowMid = amber500;
  static const Color glowEdge = orange600;

  /// Ambient light of the Solar System (0x475569 × 0.85).
  static const Color solarAmbient = slate600;

  /// Orbit lines (0x334155, 0.55) and Saturn's ring (0xd97706, 0.75).
  static const Color orbit = Color(0x8C334155);
  static const Color saturnRing = Color(0xBFD97706);

  /// Level 2: 'Our Solar System' dot (0xf59e0b) and its ring (0xfde047).
  static const Color solarDot = amber500;
  static const Color solarDotRing = yellow300;

  /// Level 3: bulge 0xfef08a, arms 0x3b82f6, edges 0x93c5fd; the bulge
  /// sphere 0xfef08a (0.5).
  static const Color galaxyBulge = yellow200;
  static const Color galaxyArm = blue500;
  static const Color galaxyEdge = blue300;

  /// Level 4: galaxy colours (`galTypesColors`) and the Milky Way at the
  /// centre (0xfef08a).
  static const List<Color> galaxyTypes = [
    yellow200,
    blue500,
    sky400,
    blue300,
    slate50,
  ];
  static const Color centreGalaxy = yellow200;

  // -------------------------------------------------------------- labels
  /// `.cosmic-label`: rgba(15, 23, 42, 0.92) with a rgba(59, 130, 246, 0.6)
  /// border.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBorder = Color(0x993B82F6);

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
    panel: Color(0xF00F172A), // --glass-bg rgba(15, 23, 42, 0.94)
    border: Color(0x593B82F6), // --glass-border rgba(59, 130, 246, 0.35)
    card: _Colors.slate900, // dark:bg-slate-900/80 cards
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.slate950, // #canvas-wrapper bg-[#020617]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500, // blue-500 accents
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A), // toast bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate950, // #shutter-screen bg-slate-950
    curtainGlow: Color(0x731E3A8A), // from-blue-900/45
    curtainText: _Colors.white,
    curtainMuted: Color(0xF293C5FD), // subtitle text-blue-300/95
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.blue500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100, // --bg-primary #f1f5f9
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x403B82F6), // --glass-border rgba(59, 130, 246, 0.25)
    card: _Colors.slate100, // bg-slate-100 cards
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate950,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x731E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xF293C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF0FFFFFF),
    buttonIcon: _Colors.blue600,
    buttonBorder: _Colors.slate300,
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
/// sidebar font size slider (15 px default, 12–22 px).
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
// Copied from the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// The shell-generic texts (Enter Lab, Select Scenario, Mission Objective,
// Current Task, the settings, theme and canvas-tool names and the footer)
// come from the shell's `kLabCommonStrings`. Changes:
// * "Click" / "CLICK" read "Tap" / "TAP" ('टैप करें' for 'क्लिक करें');
// * each summary keeps the HTML's bold heading, line breaks and bold
//   address line in a small markup: `heading|paragraph|*bold*…`
//   ([_SummaryCard] draws it);
// * the HTML's toasts and the 'Level 2: Orion Spiral Arm' badge were
//   inline `en / hi / te` literals; they are marked "HTML literal";
// * keys marked "Added." are new texts (scene descriptions for screen
//   readers).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Our Place in the Cosmos',
    'app_subtitle': 'Class 6 . Beyond Earth',
    // ScenariosData[en][1].
    'scen_1_title': 'Scenario 1: The Hidden River of Stars',
    's1_obj':
        'To understand how light pollution affects our ability to see the Milky Way galaxy.',
    's1_hud_1':
        'Step 1: DRAG the Light Pollution slider from High (right) towards Low (left) to dim city skyline lights.',
    's1_hud_2':
        'Step 2: Continue dragging the slider all the way to Low (Dark Sky Reserve) to reveal the majestic Milky Way Galaxy!',
    's1_hud_3':
        "Observation Complete! Tap the 'Observe Conclusion' button below to review what you discovered.",
    's1_c1': 'Dimming Artificial Light Pollution',
    's1_a1':
        "The scene shows a city skyline at night with bright lights. A slider at the bottom is labeled 'Light Pollution' and is set to 'High'. DRAG the slider handle from 'High' towards 'Low'.",
    's1_o1':
        "The 3D city model's emissive lights (windows, streetlights) fade as the slider is moved to the left. The skybox begins to reveal more fainter stars.",
    's1_c2': 'Revealing the Milky Way Galaxy',
    's1_a2':
        "Continue to DRAG the slider all the way to the 'Low' position, which is labeled 'Dark Sky Reserve'.",
    's1_o2':
        "When the slider hits the 'Low' mark, a faint, glowing, milky band of light fades into view, stretching across the entire sky. This is the Milky Way Galaxy (Ākāśha Gangā), resembling the dark sky of Nubra in Ladakh!",
    's1_summary':
        'Observation Complete!|'
        "Our Sun is part of a giant spiral galaxy called the Milky Way (Ākāśha Gangā). Artificial light pollution in modern cities brightens the night sky and hides this breathtaking view. When we visit or protect 'Dark Sky Reserves' (like Nubra Valley in Ladakh), the glowing band of billions of stars in our home galaxy becomes clearly visible across the night sky!",
    // ScenariosData[en][2].
    'scen_2_title': 'Scenario 2: Our Cosmic Address',
    's2_obj':
        'To visualize the scale of the Solar System, the Milky Way Galaxy, and the Universe.',
    's2_hud_1':
        "Step 1: The scene shows our Solar System with the Sun and planets. TAP the 'ZOOM OUT' button below.",
    's2_hud_2':
        "Step 2: TAP the 'ZOOM OUT' button again to pull back into our full barred spiral Milky Way Galaxy.",
    's2_hud_3':
        "Step 3: TAP the 'ZOOM OUT' button one last time to witness many galaxies across the outer space beyond the Milky Way Galaxy!",
    's2_hud_4':
        "Cosmic Journey Complete! Tap the 'Observe Conclusion' button below to review your Cosmic Address.",
    's2_c1': 'Our Solar System',
    's2_a1':
        "The scene shows our Solar System, with the Sun in the center and planets orbiting it, as in Figure 12.7. TAP the 'ZOOM OUT' button.",
    's2_o1':
        "The camera smoothly zooms out. The Solar System model shrinks rapidly until it is just a single point of light among thousands of other star-points inside our local spiral arm, labeled 'Our Solar System'.",
    's2_c2': 'The Full Milky Way Galaxy',
    's2_a2':
        "The 'ZOOM OUT' button is still visible. TAP the 'ZOOM OUT' button again.",
    's2_o2':
        "The camera zooms out further at a faster rate, revealing the full, majestic spiral structure of our entire galaxy. The stars blend into the glowing arms of the galaxy labeled 'Milky Way Galaxy'. Our Solar System is now invisibly small!",
    's2_c3': 'The Vast Universe of Galaxies',
    's2_a3': "TAP the 'ZOOM OUT' button one last time.",
    's2_o3':
        'The camera pulls back at an exponential rate. The Milky Way galaxy shrinks and is joined by hundreds of other galaxies of various shapes (spirals, ellipticals, irregulars) scattered across black space, demonstrating that there are many galaxies beyond the Milky Way!',
    's2_summary':
        'Cosmic Journey Complete!|'
        'You have explored the true hierarchy and scale of our Cosmic Address:|'
        '*Earth → Solar System → Milky Way Galaxy → The Universe*.|'
        'Our Sun is just one of over 100 billion stars inside the Milky Way Galaxy, and our Milky Way is just one of hundreds of billions of galaxies across the vast Outer Universe!',
    // i18n: sidebar, popups and canvas controls.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'success': 'Success!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete_desc':
        'You discovered the hidden Milky Way Galaxy in the dark skies and explored the majestic cosmic scale from our Solar System all the way out to the vast Outer Universe!',
    'btn_conclude': 'Observe Conclusion',
    'select_next_msg':
        'Scenario complete! Please select the next scenario from the sidebar to continue.',
    'slider_title_light': 'Light Pollution',
    'slider_title_dark': 'Dark Sky Reserve',
    'low_lbl': 'Low',
    'high_lbl': 'High',
    'btn_zoom_out_lbl': 'ZOOM OUT',
    'many_galaxies_msg':
        'There are many galaxies in the outer space beyond the Milky Way Galaxy',
    'level1_lbl': 'Level 1: Our Solar System',
    // HTML literal: the badge of the Orion Spiral Arm level.
    'level_arm_lbl': 'Level 2: Orion Spiral Arm',
    'level2_lbl': 'Level 2: Milky Way Galaxy',
    'level3_lbl': 'Level 3: The Universe',
    // Scene labels.
    'lbl_3d_solarsystem': 'Our Solar System',
    'lbl_3d_milkyway': 'Milky Way Galaxy (Ākāśha Gangā)',
    'lbl_3d_universe': 'The Universe',
    'lbl_3d_city': 'City Skyline (Light Pollution)',
    // HTML literal: the toasts of applyLightPollutionLevel() and
    // handleZoomOutClick().
    'toast_dimming':
        'City lights dimming! Continue pulling all the way to Low (Dark Sky Reserve).',
    'toast_revealed':
        'Breathtaking! The Milky Way Galaxy (Ākāśha Gangā) is now revealed across the dark sky!',
    'toast_arm': 'Zoomed out to our local section inside the Orion Spiral Arm!',
    'toast_galaxy':
        'Zoomed out to reveal our entire barred spiral Milky Way Galaxy!',
    'toast_universe':
        'Exponential Zoom Out! Witnessing many galaxies across outer space beyond the Milky Way!',
    // Added: scene descriptions for screen readers.
    'scene_s1':
        'A city skyline at night with lit windows and street lamps under the night sky',
    'scene_s2': 'Space: the current level of our cosmic address',
  },
  'hi': {
    'app_title': 'ब्रह्मांड में हमारा स्थान',
    'app_subtitle': 'कक्षा 6 . पृथ्वी के परे (Beyond Earth)',
    'scen_1_title':
        'परिदृश्य 1: तारों की छिपी हुई नदी (The Hidden River of Stars)',
    's1_obj':
        'यह समझना कि प्रकाश प्रदूषण (Light Pollution) हमारी आकाशगंगा (Milky Way) को देखने की क्षमता को कैसे प्रभावित करता है।',
    's1_hud_1':
        "चरण 1: नीचे दिए गए 'Light Pollution' स्लाइडर को 'High' से 'Low' की ओर खींचकर शहर की रोशनी कम करें।",
    's1_hud_2':
        "चरण 2: आकाशगंगा (Milky Way) को स्पष्ट रूप से देखने के लिए स्लाइडर को पूरी तरह से 'Low' (Dark Sky Reserve) तक खींचें!",
    's1_hud_3':
        "अवलोकन पूर्ण हुआ! आपने क्या खोजा, यह जानने के लिए नीचे दिए गए 'निष्कर्ष देखें' बटन पर टैप करें।",
    's1_c1': 'कृत्रिम प्रकाश प्रदूषण को कम करना',
    's1_a1':
        "दृश्य में रात के समय तेज रोशनी वाला शहर दिखता है। नीचे स्लाइडर 'High' पर सेट है। स्लाइडर को 'High' से 'Low' की ओर खींचें (DRAG करें)।",
    's1_o1':
        'जैसे ही स्लाइडर बाईं ओर खिसकता है, 3D शहर की खिड़कियों और स्ट्रीटलाइट्स की चमक कम होने लगती है और आकाश में अधिक तारे दिखाई देने लगते हैं।',
    's1_c2': 'आकाशगंगा (Milky Way) के दर्शन',
    's1_a2':
        "स्लाइडर को लगातार खींचते हुए पूरी तरह से 'Low' स्थिति (Dark Sky Reserve) पर ले जाएं।",
    's1_o2':
        "जब स्लाइडर 'Low' पर पहुँचता है, तो पूरे आकाश में तारों की एक सफेद, दूधिया चमकदार पट्टी उभर आती है। यह हमारी आकाशगंगा (Ākāśha Gangā) है, जो लद्दाख की नुब्रा घाटी के रात के आकाश जैसी दिखती है!",
    's1_summary':
        'अवलोकन पूर्ण!|'
        "हमारा सूर्य 'आकाशगंगा' (Milky Way) नामक एक विशाल सर्पिलाकार तारों के समूह का हिस्सा है। आधुनिक शहरों का तेज प्रकाश प्रदूषण रात के आकाश को चमका देता है जिससे यह सुंदर दृश्य छिप जाता है। जब हम लद्दाख जैसी कम रोशनी वाली जगहों (Dark Sky Reserves) पर जाते हैं, तो अरबों तारों की यह चमकदार नदी स्पष्ट दिखाई देती है!",
    'scen_2_title': 'परिदृश्य 2: हमारा ब्रह्मांडीय पता (Our Cosmic Address)',
    's2_obj':
        'सौरमंडल, आकाशगंगा (Milky Way Galaxy) और संपूर्ण ब्रह्मांड के विशाल पैमाने (Scale) को समझना।',
    's2_hud_1':
        "चरण 1: स्क्रीन पर सूर्य और ग्रहों के साथ हमारा सौरमंडल दिख रहा है। नीचे दिए गए 'ZOOM OUT' बटन पर टैप करें।",
    's2_hud_2':
        "चरण 2: संपूर्ण आकाशगंगा (Milky Way Galaxy) को देखने के लिए फिर से 'ZOOM OUT' बटन पर टैप करें।",
    's2_hud_3':
        "चरण 3: अंतरिक्ष में बिखरी अन्य कई आकाशगंगाओं और संपूर्ण ब्रह्मांड को देखने के लिए अंतिम बार 'ZOOM OUT' टैप करें!",
    's2_hud_4':
        "ब्रह्मांडीय यात्रा पूर्ण! अपने ब्रह्मांडीय पते की समीक्षा के लिए नीचे दिए गए 'निष्कर्ष देखें' बटन पर टैप करें।",
    's2_c1': 'सर्पिल भुजा में हमारा सौरमंडल',
    's2_a1':
        "स्क्रीन पर सूर्य और ग्रहों के साथ हमारा सौरमंडल दिख रहा है। 'ZOOM OUT' बटन पर टैप करें।",
    's2_o1':
        "कैमरा सुचारू रूप से पीछे हटता है। सौरमंडल तेजी से छोटा होता है जब तक कि वह सर्पिल भुजा के हजारों तारों के बीच केवल एक चमकदार बिंदु नहीं बन जाता, जिस पर 'Our Solar System' का लेबल होता है।",
    's2_c2': 'विशाल आकाशगंगा (Milky Way)',
    's2_a2':
        "'ZOOM OUT' बटन अभी भी दिखाई दे रहा है। फिर से 'ZOOM OUT' बटन पर टैप करें।",
    's2_o2':
        'कैमरा और तेज गति से पीछे हटता है, जिससे हमारी संपूर्ण आकाशगंगा की भव्य सर्पिल संरचना (Spiral Structure) दिखाई देती है। हमारा सौरमंडल अब इतना छोटा हो जाता है कि दिखाई भी नहीं देता!',
    's2_c3': 'आकाशगंगाओं का अनंत ब्रह्मांड',
    's2_a3': "अंतिम बार 'ZOOM OUT' बटन पर टैप करें।",
    's2_o3':
        'कैमरा अत्यंत तेजी से पीछे हटता है। हमारी आकाशगंगा छोटी हो जाती है और उसके चारों ओर विभिन्न आकृतियों (सर्पिल, दीर्घवृत्ताकार, अनियमित) की सैकड़ों अन्य आकाशगंगाएं दिखाई देती हैं, जो यह सिद्ध करता है कि अंतरिक्ष में आकाशगंगा के बाहर भी कई आकाशगंगाएँ हैं!',
    's2_summary':
        'ब्रह्मांडीय यात्रा पूर्ण!|'
        'आपने हमारे ब्रह्मांडीय पते (Cosmic Address) के सही पैमाने को समझ लिया है:|'
        '*पृथ्वी → सौरमंडल → आकाशगंगा (Milky Way) → ब्रह्मांड (The Universe)*।|'
        'हमारा सूर्य आकाशगंगा के 100 अरब से अधिक तारों में से केवल एक है, और हमारी आकाशगंगा विशाल अंतरिक्ष की अरबों आकाशगंगाओं में से केवल एक है!',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'success': 'सफलता!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete_desc':
        'आपने प्रकाश प्रदूषण को कम करके आकाशगंगा (Milky Way) के दर्शन किए और हमारे सौरमंडल से लेकर संपूर्ण बाहरी ब्रह्मांड (Universe) के विशाल पैमाने को समझा!',
    'btn_conclude': 'निष्कर्ष देखें',
    'select_next_msg':
        'परिदृश्य पूर्ण हुआ! आगे बढ़ने के लिए कृपया साइडबार से अगला परिदृश्य चुनें।',
    'slider_title_light': 'प्रकाश प्रदूषण (Light Pollution)',
    'slider_title_dark': 'डार्क स्काई रिज़र्व (Dark Sky Reserve)',
    'low_lbl': 'कम (Low)',
    'high_lbl': 'अधिक (High)',
    'btn_zoom_out_lbl': 'ज़ूम आउट (ZOOM OUT)',
    'many_galaxies_msg': 'आकाशगंगा के बाहर अंतरिक्ष में कई अन्य आकाशगंगाएँ हैं',
    'level1_lbl': 'स्तर 1: हमारा सौरमंडल',
    'level_arm_lbl': 'स्तर 2: ओरियन सर्पिल भुजा',
    'level2_lbl': 'स्तर 2: आकाशगंगा (Milky Way Galaxy)',
    'level3_lbl': 'स्तर 3: ब्रह्मांड (The Universe)',
    'lbl_3d_solarsystem': 'हमारा सौरमंडल (Our Solar System)',
    'lbl_3d_milkyway': 'आकाशगंगा (Milky Way Galaxy)',
    'lbl_3d_universe': 'ब्रह्मांड (The Universe)',
    'lbl_3d_city': 'शहरी रोशनी (प्रकाश प्रदूषण)',
    'toast_dimming':
        'शहर की रोशनी कम हो रही है! पूरी तरह से Low (Dark Sky Reserve) तक खींचें।',
    'toast_revealed':
        'अद्भुत! पूरे आकाश में हमारी आकाशगंगा (Ākāśha Gangā) स्पष्ट दिखाई दे रही है!',
    'toast_arm':
        'ओरियन सर्पिल भुजा में हमारे सौरमंडल के स्थान पर ज़ूम आउट किया गया!',
    'toast_galaxy':
        'हमारी संपूर्ण भव्य आकाशगंगा (Milky Way Galaxy) को देखने के लिए ज़ूम आउट किया गया!',
    'toast_universe':
        'अत्यंत तीव्र ज़ूम आउट! अंतरिक्ष में कई अन्य आकाशगंगाओं के दर्शन!',
    // Added.
    'scene_s1':
        'रात के आकाश के नीचे जगमगाती खिड़कियों और स्ट्रीटलाइट्स वाला शहर',
    'scene_s2': 'अंतरिक्ष: हमारे ब्रह्मांडीय पते का वर्तमान स्तर',
  },
};

/// Scenarios and their step counts (HTML `ScenariosData`).
const int _scenarioCount = 2;
const List<int> _stepCounts = [2, 3];

/// HUD lines per scenario (HTML `hud[min(step, 4)]`; `hud[0]` repeats
/// `hud[1]` and Scenario 1's `hud[4]` repeats `hud[3]`).
const List<int> _hudCounts = [3, 4];

/// Scenario [index] in [lang], built from the string table.
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('scen_${n}_title'),
    objective: t('s${n}_obj'),
    steps: [
      for (var i = 1; i <= _stepCounts[index]; i++)
        LabStep(
          concept: t('s${n}_c$i'),
          action: t('s${n}_a$i'),
          observation: t('s${n}_o$i'),
        ),
    ],
  );
}

/// The two scenarios in both languages, built once from [_i18n].
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values)
    lang: [for (var i = 0; i < _scenarioCount; i++) _buildScenario(lang, i)],
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// The HTML cameras: `PerspectiveCamera(60, aspect, 0.1, 4500)`.
const double _fovDegrees = 60;
const double _near = 0.1;

/// Design pixels per world unit at depth 1 (half the stage height over
/// tan(fov / 2), as in Three.js).
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Three.js point sprites are `size × (canvas height / 2) / depth` px.
const double _pointScale = 280;

/// Smallest point drawn (design px), so far points still show.
const double _minPoint = 0.9;

/// Longest step (s) one frame may advance the scene, so a stalled frame
/// does not make things jump.
const double _maxFrameStep = 0.05;

/// The HTML animates per frame at 60 frames per second.
const double _fps = 60;

/// Screens shorter than this (phones in landscape) get the compact cards.
const double _compactBelow = 480;

/// Points this far outside the stage are skipped. The stage is letterboxed
/// and nothing clips the painter there, so the margin covers the letterbox.
const Rect _cull = Rect.fromLTRB(-520, -340, 1520, 900);

/// Scene labels: text size (design px), boosted up to [_labelMaxBoost]
/// times when the stage is drawn small; they fade in over
/// [_labelFadeSeconds] (HTML `animate-fade-in-up`, 0.3 s, 10 px rise).
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.9;
const double _labelFadeSeconds = 0.3;
const double _labelRise = 10;

/// `add3DLabelToScreen()`: the label's bottom sits 16 px above the point.
const double _labelLift = 16;

// --------------------------------------------------------------- scenario 1
// HTML `resetCamera()`: (0, 30, 65) looking at (0, 15, 0).

const _View _cityView = _View(_V(0, 30, 65), _V(0, 15, 0));

/// The city camera at 0.62 of the HTML zoom with its target low on the
/// stage, so the skyline fills the lower half and leaves the sky above.
const _Framing _cityFraming = _Framing(Offset(500, 360), 0.62);

/// The dome seen from further back, so the Milky Way arch (x ±250, y 16 to
/// 241) spans the sky above the skyline. Dome stars are directions.
const _View _skyView = _View(_V(0, 20, 290), _V(0, 115, 0));
const _Framing _skyFraming = _Framing(Offset(500, 205), 1);

/// `State.s1.lightPollution` starts at 100 (High). Step 1 ends below 60,
/// step 2 at 8 or less. At 35 or less the slider title reads 'Dark Sky
/// Reserve' and the city label hides; at 55 or less the Milky Way label
/// shows.
const double _pollutionHigh = 100;
const double _dimBelow = 60;
const double _revealAtMost = 8;
const double _cityLabelAbove = 35;
const double _milkyLabelAtMost = 55;

/// `material.opacity = factor × 0.88` for the city lights and
/// `intensity = factor × 1.4` for its light sources.
const double _lightsOpacity = 0.88;
const double _lightsIntensity = 1.4;

/// Sky dome (MeshBasic, BackSide): `setRGB(0.01 + 0.11 f, 0.02 + 0.14 f,
/// 0.09 + 0.19 f)` for the pollution factor f.
Color _domeColor(double f) => Color.from(
  alpha: 1,
  red: 0.01 + 0.11 * f,
  green: 0.02 + 0.14 * f,
  blue: 0.09 + 0.19 * f,
);

/// `cityPlane`: 450 × 450 at y = 0 with its far edge at z = -225; it is
/// drawn across the whole stage ([_groundSide]) up to [_groundNear].
const double _groundFar = -225;
const double _groundNear = 60;
const double _groundSide = 4000;

/// Ambient light 0x1e293b × 0.9 and the directional light 0xfbbf24 from
/// (20, 50, 30).
const double _cityAmbient = 0.9;
const _V _cityLightAt = _V(20, 50, 30);

/// `buildScenario1Scene()` buildings: 75 tries, w and d 5–13, h 10–38,
/// x within ±105, z within -90…30, none within 15 of the tower. Taller
/// than 22 gets a roof cap (60% × 3.5 × 60%) and, 40% of the time, an
/// antenna (5 tall) with a red light (0.4) on top.
const int _buildingTries = 75;
const double _buildingSpanX = 210;
const double _buildingSpanZ = 120;
const double _buildingShiftZ = -30;
const double _towerClear = 15;
const double _roofAbove = 22;
const double _roofScale = 0.6;
const double _roofH = 3.5;
const double _antennaChance = 0.6;
const double _antennaBase = 3;
const double _antennaTop = 8;
const double _redLightR = 0.4;

/// The lit window boxes: 0.15 wider and deeper than the building, 88% of
/// its height, centred 1 above its middle; the window texture repeats
/// floor(w / 4) × floor(h / 5) times.
const double _windowPad = 0.15;
const double _windowHeight = 0.88;

/// The landmark tower at (-6, -20): podium 14 × 12 × 14, shaft 10 × 26 ×
/// 10, top tier 6.5 × 12 × 6.5, spire (cone r 1.8, 14 tall) from y 50, red
/// beacon (0.8) at 64.5 and a 10.15 × 36 × 10.15 window box.
const double _towerX = -6;
const double _towerZ = -20;
const _V _cityLabelAt = _V(-6, 38, -20);

/// Street lamps: spheres (1.6) at x = -80…80 every 16, y 3.2, z 14, with
/// point lights (0xf59e0b, reach 25) at y 6.
const double _lampFirst = -80;
const double _lampLast = 80;
const double _lampStep = 16;
const double _lampY = 3.2;
const double _lampZ = 14;
const double _lampR = 1.6;
const double _lampReach = 25;

/// `createBuildingTexture(true)`: a 64 × 128 canvas of 6 × 7 windows every
/// 10 px (6 columns, 12 rows), each lit 72% of the time in a random window
/// colour. Drawn [_windowTexScale] times larger for a sharp texture.
const int _windowTexW = 64;
const int _windowTexH = 128;
const int _windowTexScale = 4;
const double _windowLitChance = 0.28;

/// Dome stars (HTML: 90 bright at r 300, 4200 faint; points whose polar
/// angle is above 0.47π are dropped, i.e. the upper hemisphere is kept).
const int _brightTries = 90;
const int _faintTries = 4200;
const double _hemisphereCut = 0.47 * math.pi;
const double _brightSize = 2;
const double _brightOpacity = 0.95;
const double _faintSize = 1.2;
const double _faintOpacity = 0.95;

/// The Milky Way band: 9500 points of size 1.7 on an arch of radius 250
/// (angle within ±0.9π; spread (18 - 6|angle|), depth ±7.5, y × 0.9 + 16);
/// core colour below |angle| 0.28, then arm → dust over 1.5. Its spin
/// (`rotation.y += 0.0004` a frame) streams the stars along the arch.
const int _bandCount = 9500;
const double _bandR = 250;
const double _bandSpan = 0.9 * math.pi;
const double _bandSpread = 18;
const double _bandSpreadSlope = 6;
const double _bandDepth = 15;
const double _bandFlatten = 0.9;
const double _bandLift = 16;
const double _bandZSpread = 3.5;
const double _bandCoreAngle = 0.28;
const double _bandDustSpan = 1.5;
const double _bandSize = 1.7;
const double _bandDrift = 0.0004 * _fps;
const int _bandBins = 16;

/// `mwCoreCloud`: a sphere (28) at (0, 160, -30) scaled (1.9, 0.7, 0.7);
/// the Milky Way label sits at (0, 150, -30).
const _V _coreCloudAt = _V(0, 160, -30);
const double _coreCloudR = 28;
const double _coreCloudScaleX = 1.9;
const double _coreCloudScaleY = 0.7;
const _V _milkyLabelAt = _V(0, 150, -30);

/// Faint stars fade in as `(1 - f)^1.5 × 0.95`, the band and its core as
/// `(1 - f)^1.8 × 0.95`.
const double _faintFade = 1.5;
const double _bandFade = 1.8;
const double _bandOpacity = 0.95;

// --------------------------------------------------------------- scenario 2
// HTML `handleZoomOutClick()` / `resetCamera()`: the camera of each level
// and the tween that reaches it.

const _View _level1View = _View(_V(0, 30, 50), _V.zero);
const _View _level2View = _View(_V(60, 50, 120), _V(60, 0, 0));
const _View _level3View = _View(_V(0, 220, 280), _V.zero);
const _View _level4View = _View(_V(0, 700, 1100), _V.zero);
const List<_View> _levelViews = [
  _level1View,
  _level2View,
  _level3View,
  _level4View,
];

/// Zoom-out tweens to levels 2, 3 and 4 (Cubic.Out) and the scenario's
/// opening `resetCamera()` tween (600 ms, Quadratic.Out).
const List<double> _zoomSeconds = [1.2, 1.4, 1.8];
const double _resetSeconds = 0.6;

/// The levels cross-fade (the HTML swapped them in one frame).
const double _levelFadeSeconds = 0.35;

/// Background stars: 2500 on a sphere of 1400 (0x94a3b8, size 1.3, 0.65).
const int _spaceStarCount = 2500;
const double _spaceStarR = 1400;
const double _spaceStarSize = 1.3;
const double _spaceStarOpacity = 0.65;

/// The Sun: core 6.4; coronas 7.2, 8.4, 10.5, 13 (opacity 0.9, 0.65, 0.4,
/// 0.2, additive); 450 prominence points (size 0.55, 0.85, additive) at
/// 6.6–8.8 from the centre, ±1.75 high; 350 surface blotches (2–14 px of
/// the 256 px texture).
const double _sunR = 6.4;
const List<double> _coronaRadii = [7.2, 8.4, 10.5, 13];
const List<double> _coronaOpacities = [0.9, 0.65, 0.4, 0.2];
const int _prominenceCount = 450;
const double _prominenceIn = 6.6;
const double _prominenceSpan = 2.2;
const double _prominenceHeight = 3.5;
const double _prominenceSize = 0.55;
const double _prominenceOpacity = 0.85;
const int _prominenceBins = 3;
const int _blotchCount = 350;
const double _sunTex = 256;

/// The cached Sun disc is recorded at this radius.
const double _sunDiscR = 100;
const _V _solarLabelAt = _V(0, 8, 0);

/// Ambient light 0x475569 × 0.85 on the planets' night side.
const double _solarAmbient = 0.85;

/// Orbit lines: 64 segments.
const int _orbitSegments = 64;

/// Saturn's ring: inner 2.8, outer 5.2, tilted π / 2.3 about x.
const double _ringIn = 2.8;
const double _ringOut = 5.2;
const double _ringTilt = math.pi / 2.3;
const int _ringSegments = 48;

/// Level 2: 5000 points of the Orion arm (size 1.1, 0.88), turning 0.001 a
/// frame; the 'Our Solar System' dot (2) at (60, 0.5, 0) with its ring
/// (2.8–4.8).
const int _armCount = 5000;
const double _armSize = 1.1;
const double _armOpacity = 0.88;
const double _armSpin = 0.001 * _fps;
const _V _solarDotAt = _V(60, 0.5, 0);
const double _solarDotR = 2;
const double _solarDotRingIn = 2.8;
const double _solarDotRingOut = 4.8;
const _V _armLabelAt = _V(60, 5, 0);
const int _armColorSteps = 3;

/// Level 3: 18000 points (size 1.2, 0.92) in 4 arms out to 145, wound 2.6π,
/// turning 0.0015 a frame; the bulge sphere (16, 0.5).
const int _galaxyCount = 18000;
const double _galaxyR = 145;
const int _galaxyArms = 4;
const double _galaxyTwist = 2.6 * math.pi;
const double _galaxyScatter = 0.35;
const double _galaxyThickness = 18;
const double _galaxyBulgeR = 24;
const double _galaxySize = 1.2;
const double _galaxyOpacity = 0.92;
const double _galaxySpin = 0.0015 * _fps;
const double _bulgeSphereR = 16;
const double _bulgeOpacity = 0.5;
const _V _galaxyLabelAt = _V(0, 22, 0);
const int _bulgeBins = 4;
const int _discBins = 6;

/// Level 4: 650 galaxies in a 1700 × 950 × 1700 box, each 20–43 points
/// (size 3, 0.92) within 12–40, flattened to 0.4; turning 0.0004 a frame;
/// the Milky Way at the centre (14).
const int _universeCount = 650;
const _V _universeBox = _V(1700, 950, 1700);
const double _clusterMin = 12;
const double _clusterSpan = 28;
const int _clusterMinPoints = 20;
const int _clusterSpanPoints = 24;
const double _clusterFlatten = 0.4;
const double _universeSize = 3;
const double _universeOpacity = 0.92;
const double _universeSpin = 0.0004 * _fps;
const double _centreGalaxyR = 14;
const _V _universeLabelAt = _V(0, -25, 0);

/// Galaxies are drawn in three size bands by their depth.
const List<double> _universeDepthBands = [1000, 1600];

/// The eight planets (`planetsData`): orbit radius, size, colour, turn per
/// frame and Saturn's ring.
const List<_Planet> _planets = [
  _Planet(11, 0.65, Color(0xFF94A3B8), 0.04),
  _Planet(15.5, 1.05, Color(0xFFFCD34D), 0.025),
  _Planet(21, 1.3, Color(0xFF2563EB), 0.018),
  _Planet(26.5, 0.85, Color(0xFFEA580C), 0.012),
  _Planet(35.5, 2.8, Color(0xFFFACC15), 0.007),
  _Planet(46, 2.3, Color(0xFFFDE047), 0.005, ringed: true),
  _Planet(56, 1.6, Color(0xFF38BDF8), 0.003),
  _Planet(65, 1.5, Color(0xFF4F46E5), 0.002),
];

// ----------------------------------------------------------------- confetti
// canvas-confetti: start velocity 45, decay 0.9 per tick, gravity 3 px per
// tick, 200 ticks of 1/60 s. The summary fires 100 pieces (spread 65°,
// origin y 0.4); 'Mastery Achieved!' fires 160 (spread 80°, origin y 0.35).

const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;
const int _summaryConfetti = 100;
const double _summarySpread = 65;
const double _summaryOriginY = 0.4;
const int _masteryConfetti = 160;
const double _masterySpread = 80;
const double _masteryOriginY = 0.35;

// ------------------------------------------------------------------ 3D math

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
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  /// This point turned by [angle] about the vertical axis through
  /// [centre] (Three.js `rotation.y`: +x turns towards -z).
  _V turnY(double angle, [_V centre = zero]) {
    final c = math.cos(angle), s = math.sin(angle);
    final dx = x - centre.x, dz = z - centre.z;
    return _V(centre.x + dx * c + dz * s, y, centre.z - dx * s + dz * c);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A camera: where it is and what it looks at (`controls.target`).
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;

  /// Distance from the eye to the target.
  double get reach => (target - eye).length;

  static _View lerp(_View a, _View b, double t) =>
      _View(_V.lerp(a.eye, b.eye, t), _V.lerp(a.target, b.target, t));
}

/// Where the camera's look-at point is drawn on the stage and how much the
/// view is enlarged (1 = the HTML camera on the design stage).
@immutable
class _Framing {
  const _Framing(this.center, this.zoom);

  final Offset center;
  final double zoom;

  static const _Framing base = _Framing(Offset(500, 280), 1);
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 60°) as a
/// pinhole projection onto the design stage. The basis is kept as plain
/// numbers for the point-cloud loops.
@immutable
class _Cam {
  factory _Cam(_View view, [_Framing framing = _Framing.base]) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_V.up).unit;
    final u = r.cross(f);
    final e = view.eye;
    return _Cam._(
      e.x,
      e.y,
      e.z,
      f.x,
      f.y,
      f.z,
      r.x,
      r.y,
      r.z,
      u.x,
      u.y,
      u.z,
      framing.center.dx,
      framing.center.dy,
      _focal * framing.zoom,
    );
  }

  const _Cam._(
    this.ex,
    this.ey,
    this.ez,
    this.fx,
    this.fy,
    this.fz,
    this.rx,
    this.ry,
    this.rz,
    this.ux,
    this.uy,
    this.uz,
    this.cx,
    this.cy,
    this.k,
  );

  /// Eye, forward, right and up.
  final double ex, ey, ez;
  final double fx, fy, fz;
  final double rx, ry, rz;
  final double ux, uy, uz;

  /// Stage point of the view axis and design pixels per unit at depth 1.
  final double cx, cy, k;

  _V get eye => _V(ex, ey, ez);

  /// Distance of [w] in front of the camera.
  double depth(_V w) => (w.x - ex) * fx + (w.y - ey) * fy + (w.z - ez) * fz;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => k / math.max(_near, depth(w));

  /// Where [w] is drawn on the stage.
  Offset p(_V w) {
    final dx = w.x - ex, dy = w.y - ey, dz = w.z - ez;
    final s = k / math.max(_near, dx * fx + dy * fy + dz * fz);
    return Offset(
      cx + (dx * rx + dy * ry + dz * rz) * s,
      cy - (dx * ux + dy * uy + dz * uz) * s,
    );
  }

  /// Where the direction ([x], [y], [z]) (a point at infinity, like the
  /// dome stars) is drawn, or null when it points away from the view.
  Offset? dir(double x, double y, double z) {
    final d = x * fx + y * fy + z * fz;
    if (d < 0.05) return null;
    final s = k / d;
    return Offset(
      cx + (x * rx + y * ry + z * rz) * s,
      cy - (x * ux + y * uy + z * uz) * s,
    );
  }

  /// Screen components of the unit world direction [v]: right, down and
  /// towards the viewer.
  (double, double, double) screenDir(_V v) => (
    v.x * rx + v.y * ry + v.z * rz,
    -(v.x * ux + v.y * uy + v.z * uz),
    -(v.x * fx + v.y * fy + v.z * fz),
  );
}

// ------------------------------------------------------------------ easing
// Tween.js easing functions used by the HTML.

typedef _Ease = double Function(double t);

/// `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => t * (2 - t);

/// `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = t - 1;
  return k * k * k + 1;
}

/// A camera tween (`new TWEEN.Tween(camera.position).to(…)` with the
/// controls' target moved to the new level), read at the scene time.
@immutable
class _CamMove {
  const _CamMove(this.from, this.to, this.start, this.seconds, this.ease);

  const _CamMove.still(_View view)
    : from = view,
      to = view,
      start = 0,
      seconds = 0,
      ease = _quadOut;

  final _View from;
  final _View to;
  final double start;
  final double seconds;
  final _Ease ease;

  _View at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _View.lerp(from, to, ease((t - start) / seconds));
  }

  /// A new tween from the view at [now] to [target].
  _CamMove toward(_View target, double now, double secs, _Ease e) =>
      _CamMove(at(now), target, now, secs, e);
}

// ------------------------------------------------------------------- models

/// One of the eight planets: orbit radius, size, colour, turn per frame.
@immutable
class _Planet {
  const _Planet(
    this.orbit,
    this.size,
    this.color,
    this.turn, {
    this.ringed = false,
  });

  final double orbit;
  final double size;
  final Color color;
  final double turn;
  final bool ringed;
}

/// A city building (HTML loop in `buildScenario1Scene()`): footprint,
/// height, window texture repeats, roof cap and antenna.
@immutable
class _Building {
  const _Building({
    required this.x,
    required this.z,
    required this.w,
    required this.d,
    required this.h,
    required this.antenna,
  });

  final double x;
  final double z;
  final double w;
  final double d;
  final double h;
  final bool antenna;

  bool get roofed => h > _roofAbove;

  /// `winRepeat.repeat.set(max(1, floor(w / 4)), max(1, floor(h / 5)))`.
  int get repeatX => math.max(1, (w / 4).floor());
  int get repeatY => math.max(1, (h / 5).floor());
}

/// A light or dark blotch on the Sun's surface texture (texture px).
@immutable
class _Blotch {
  const _Blotch(this.u, this.v, this.r, {required this.light});

  final double u;
  final double v;
  final double r;
  final bool light;
}

/// One lit cell of the window texture: column, row and colour index.
typedef _WindowCell = (int col, int row, int color);

/// Everything the HTML builds with `Math.random()`, generated once from
/// fixed seeds so the scenes look the same every time. Point clouds are
/// kept as flat x, y, z arrays with a colour bin per point.
class _Cosmos {
  _Cosmos._();

  static final _Cosmos instance = _Cosmos._().._build();

  // ------------------------------------------------------------ scenario 1
  /// The window texture's lit cells.
  final List<_WindowCell> windowCells = [];

  /// The random buildings (the tower is drawn on its own).
  final List<_Building> buildings = [];

  /// Dome stars, projected once through the sky camera (x, y pairs).
  late final Float32List brightStars;
  late final Float32List faintStars;

  /// Band stars: start angle, spread factor (-0.5…0.5) and depth offset.
  late final Float32List bandAngle;
  late final Float32List bandSpread;
  late final Float32List bandDepth;

  /// The band colour of each bin (by |angle|).
  late final List<Color> bandColors;

  // ------------------------------------------------------------ scenario 2
  late final Float32List spaceStars;
  late final Float32List prominences;
  late final Uint8List prominenceBin;
  late final List<Color> prominenceColors;
  final List<_Blotch> blotches = [];

  late final Float32List arm;
  late final Uint8List armBin;
  late final List<Color> armColors;

  late final Float32List galaxy;
  late final Uint8List galaxyBin;
  late final List<Color> galaxyColors;

  /// Universe points, the galaxy each belongs to and the galaxies'
  /// centres and colour types.
  late final Float32List universe;
  late final Int32List universeOwner;
  late final Float32List clusterCentres;
  late final Uint8List clusterType;

  /// Points per colour bin, for the batches' buffers.
  static List<int> binSizes(Uint8List bins, int count) {
    final sizes = List<int>.filled(count, 0);
    for (final b in bins) {
      sizes[b]++;
    }
    return sizes;
  }

  void _build() {
    _buildScenario1();
    _buildScenario2();
  }

  void _buildScenario1() {
    final rnd = math.Random(612);
    final sky = _Cam(_skyView, _skyFraming);

    // Dome stars: the HTML's sphere points with polar angle up to 0.47π,
    // taken about the vertical axis (the HTML measured it from +z).
    Float32List stars(int tries, {required bool jitter}) {
      final out = <double>[];
      for (var i = 0; i < tries; i++) {
        final u = rnd.nextDouble(), v = rnd.nextDouble();
        final th = u * math.pi * 2, ph = math.acos(2 * v - 1);
        if (ph > _hemisphereCut) continue;
        if (jitter) rnd.nextDouble(); // `r = 280 + (random - 0.5) × 20`.
        final at = sky.dir(
          math.sin(ph) * math.cos(th),
          math.cos(ph),
          math.sin(ph) * math.sin(th),
        );
        if (at == null || !_cull.contains(at)) continue;
        out
          ..add(at.dx)
          ..add(at.dy);
      }
      return Float32List.fromList(out);
    }

    brightStars = stars(_brightTries, jitter: false);
    faintStars = stars(_faintTries, jitter: true);

    bandAngle = Float32List(_bandCount);
    bandSpread = Float32List(_bandCount);
    bandDepth = Float32List(_bandCount);
    for (var i = 0; i < _bandCount; i++) {
      bandAngle[i] = (rnd.nextDouble() - 0.5) * 2 * _bandSpan;
      bandSpread[i] = rnd.nextDouble() - 0.5;
      bandDepth[i] = (rnd.nextDouble() - 0.5) * _bandDepth;
    }
    bandColors = [
      for (var b = 0; b < _bandBins; b++) _bandColor((b + 0.5) / _bandBins),
    ];

    // createBuildingTexture(true).
    for (var row = 0; row < 12; row++) {
      for (var col = 0; col < 6; col++) {
        if (rnd.nextDouble() > _windowLitChance) {
          windowCells.add((col, row, rnd.nextInt(_Colors.windows.length)));
        }
      }
    }

    for (var i = 0; i < _buildingTries; i++) {
      final w = 5 + rnd.nextDouble() * 8;
      final d = 5 + rnd.nextDouble() * 8;
      final h = 10 + rnd.nextDouble() * 28;
      final x = (rnd.nextDouble() - 0.5) * _buildingSpanX;
      final z = (rnd.nextDouble() - 0.5) * _buildingSpanZ + _buildingShiftZ;
      if ((x - _towerX).abs() < _towerClear &&
          (z - _towerZ).abs() < _towerClear) {
        continue;
      }
      final antenna = h > _roofAbove && rnd.nextDouble() > _antennaChance;
      buildings.add(_Building(x: x, z: z, w: w, d: d, h: h, antenna: antenna));
    }
  }

  /// Band colour at [k] = |angle| / 0.9π: core → arm below 0.28, then arm
  /// → dust over 1.5 (Three.js `lerpColors` extrapolates past dust).
  static Color _bandColor(double k) {
    final a = k * _bandSpan;
    if (a < _bandCoreAngle) {
      return Color.lerp(_Colors.bandCore, _Colors.bandArm, a / _bandCoreAngle)!;
    }
    final t = (a - _bandCoreAngle) / _bandDustSpan;
    double ch(double from, double to) => (from + (to - from) * t).clamp(0, 1);
    return Color.from(
      alpha: 1,
      red: ch(_Colors.bandArm.r, _Colors.bandDust.r),
      green: ch(_Colors.bandArm.g, _Colors.bandDust.g),
      blue: ch(_Colors.bandArm.b, _Colors.bandDust.b),
    );
  }

  void _buildScenario2() {
    final rnd = math.Random(1206);

    spaceStars = Float32List(_spaceStarCount * 3);
    for (var i = 0; i < _spaceStarCount; i++) {
      final th = rnd.nextDouble() * math.pi * 2;
      final ph = math.acos(2 * rnd.nextDouble() - 1);
      spaceStars
        ..[3 * i] = _spaceStarR * math.sin(ph) * math.cos(th)
        ..[3 * i + 1] = _spaceStarR * math.sin(ph) * math.sin(th)
        ..[3 * i + 2] = _spaceStarR * math.cos(ph);
    }

    // createSunSurfaceTexture(): blotches over the 256 px texture.
    for (var i = 0; i < _blotchCount; i++) {
      blotches.add(
        _Blotch(
          rnd.nextDouble() * _sunTex,
          rnd.nextDouble() * _sunTex,
          2 + rnd.nextDouble() * 12,
          light: rnd.nextDouble() > 0.5,
        ),
      );
    }

    prominences = Float32List(_prominenceCount * 3);
    prominenceBin = Uint8List(_prominenceCount);
    for (var i = 0; i < _prominenceCount; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final dist = _prominenceIn + rnd.nextDouble() * _prominenceSpan;
      final h = (rnd.nextDouble() - 0.5) * _prominenceHeight;
      prominences
        ..[3 * i] = math.cos(a) * dist
        ..[3 * i + 1] = h
        ..[3 * i + 2] = math.sin(a) * dist;
      prominenceBin[i] = math.min(
        _prominenceBins - 1,
        (rnd.nextDouble() * _prominenceBins).floor(),
      );
    }
    prominenceColors = [
      for (var b = 0; b < _prominenceBins; b++)
        Color.from(
          alpha: 1,
          red: 1,
          green: 0.6 + 0.3 * (b + 0.5) / _prominenceBins,
          blue: 0.05,
        ),
    ];

    // Level 2: the Orion arm.
    arm = Float32List(_armCount * 3);
    armBin = Uint8List(_armCount);
    for (var i = 0; i < _armCount; i++) {
      final arc = (rnd.nextDouble() - 0.5) * 1.3;
      final r = 60 + arc * 32 + (rnd.nextDouble() - 0.5) * 16;
      final z = r * math.sin(arc) + (rnd.nextDouble() - 0.5) * 18;
      final y = (rnd.nextDouble() - 0.5) * 9;
      arm
        ..[3 * i] = r * math.cos(arc)
        ..[3 * i + 1] = y
        ..[3 * i + 2] = z;
      final red = math.min(
        _armColorSteps - 1,
        (rnd.nextDouble() * _armColorSteps).floor(),
      );
      final green = math.min(
        _armColorSteps - 1,
        (rnd.nextDouble() * _armColorSteps).floor(),
      );
      armBin[i] = red * _armColorSteps + green;
    }
    armColors = [
      for (var red = 0; red < _armColorSteps; red++)
        for (var green = 0; green < _armColorSteps; green++)
          Color.from(
            alpha: 1,
            red: 0.6 + 0.4 * (red + 0.5) / _armColorSteps,
            green: 0.7 + 0.3 * (green + 0.5) / _armColorSteps,
            blue: 1,
          ),
    ];

    // Level 3: the barred spiral Milky Way.
    galaxy = Float32List(_galaxyCount * 3);
    galaxyBin = Uint8List(_galaxyCount);
    for (var i = 0; i < _galaxyCount; i++) {
      final r = math.pow(rnd.nextDouble(), 1.4) * _galaxyR;
      final armAngle = (i % _galaxyArms) * (math.pi / 2);
      final angle =
          armAngle +
          (r / _galaxyR) * _galaxyTwist +
          (rnd.nextDouble() - 0.5) * _galaxyScatter;
      galaxy
        ..[3 * i] = math.cos(angle) * r
        ..[3 * i + 1] =
            (rnd.nextDouble() - 0.5) * (_galaxyThickness / (1 + r * 0.08))
        ..[3 * i + 2] = math.sin(angle) * r;
      galaxyBin[i] = r < _galaxyBulgeR
          ? math.min(_bulgeBins - 1, (r / _galaxyBulgeR * _bulgeBins).floor())
          : _bulgeBins +
                math.min(
                  _discBins - 1,
                  ((r - _galaxyBulgeR) / (_galaxyR - _galaxyBulgeR) * _discBins)
                      .floor(),
                );
    }
    galaxyColors = [
      for (var b = 0; b < _bulgeBins; b++)
        Color.lerp(
          _Colors.galaxyBulge,
          _Colors.galaxyArm,
          (b + 0.5) / _bulgeBins,
        )!,
      for (var b = 0; b < _discBins; b++)
        Color.lerp(
          _Colors.galaxyArm,
          _Colors.galaxyEdge,
          (b + 0.5) / _discBins,
        )!,
    ];

    // Level 4: the universe of galaxies.
    final points = <double>[];
    final owners = <int>[];
    clusterCentres = Float32List(_universeCount * 3);
    clusterType = Uint8List(_universeCount);
    for (var g = 0; g < _universeCount; g++) {
      final gx = (rnd.nextDouble() - 0.5) * _universeBox.x;
      final gy = (rnd.nextDouble() - 0.5) * _universeBox.y;
      final gz = (rnd.nextDouble() - 0.5) * _universeBox.z;
      clusterCentres
        ..[3 * g] = gx
        ..[3 * g + 1] = gy
        ..[3 * g + 2] = gz;
      clusterType[g] = g % _Colors.galaxyTypes.length;
      final size = _clusterMin + rnd.nextDouble() * _clusterSpan;
      final count =
          _clusterMinPoints + (rnd.nextDouble() * _clusterSpanPoints).floor();
      for (var p = 0; p < count; p++) {
        final ang = rnd.nextDouble() * math.pi * 2;
        final rad = rnd.nextDouble() * size;
        points
          ..add(gx + math.cos(ang) * rad)
          ..add(gy + (rnd.nextDouble() - 0.5) * size * _clusterFlatten)
          ..add(gz + math.sin(ang) * rad);
        owners.add(g);
      }
    }
    universe = Float32List.fromList(points);
    universeOwner = Int32List.fromList(owners);
  }
}

// -------------------------------------------------------------- animations

/// When a scene label became visible, for its fade-in.
class _Appear {
  double _since = -1;
  Object? _key;

  /// Marks the label shown (with [key]) or hidden at [now]; a new key
  /// restarts the fade-in.
  void update(bool visible, double now, [Object? key]) {
    if (!visible) {
      _since = -1;
      _key = null;
    } else if (_since < 0 || key != _key) {
      _since = now;
      _key = key;
    }
  }

  /// 0 hidden … 1 fully faded in.
  double alpha(double now) => _since < 0
      ? 0
      : ((now - _since) / _labelFadeSeconds).clamp(0.0, 1.0).toDouble();
}

/// One confetti piece (canvas-confetti `fetti`), in canvas pixels.
class _Confetto {
  _Confetto({
    required this.x,
    required this.y,
    required this.angle,
    required this.velocity,
    required this.color,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tilt,
  });

  double x;
  double y;
  final double angle;
  double velocity;
  final Color color;
  double wobble;
  final double wobbleSpeed;
  double tilt;
  double tick = 0;
}

/// canvas-confetti for the summary and mastery popups: pieces fly, slow
/// down, fall and fade over 200 ticks.
class _Confetti {
  final List<_Confetto> pieces = [];
  final math.Random _rnd = math.Random(5);

  /// Canvas size the pieces are placed in (logical px).
  Size size = _design;
  double _ticks = 0;

  /// `confetti({particleCount, spread, origin})` (angle 90°).
  void fire(int count, double spread, Offset origin) {
    const a = math.pi / 2;
    final s = spread * math.pi / 180;
    for (var k = 0; k < count; k++) {
      pieces.add(
        _Confetto(
          x: origin.dx * size.width,
          y: origin.dy * size.height,
          angle: -a + 0.5 * s - _rnd.nextDouble() * s,
          velocity: _confettiStart * 0.5 + _rnd.nextDouble() * _confettiStart,
          color: _Colors.confetti[_rnd.nextInt(_Colors.confetti.length)],
          wobble: _rnd.nextDouble() * 10,
          wobbleSpeed: math.min(0.11, _rnd.nextDouble() * 0.1 + 0.05),
          tilt: (_rnd.nextDouble() * 0.5 + 0.25) * math.pi,
        ),
      );
    }
  }

  /// Advances the pieces by [dt] seconds (60 ticks a second).
  void update(double dt) {
    if (pieces.isEmpty) return;
    _ticks += dt * _fps;
    while (_ticks >= 1) {
      _ticks -= 1;
      for (final c in pieces) {
        c
          ..x += math.cos(c.angle) * c.velocity
          ..y += math.sin(c.angle) * c.velocity + _confettiGravity
          ..velocity *= _confettiDecay
          ..wobble += c.wobbleSpeed
          ..tilt += 0.1
          ..tick += 1;
      }
      pieces.removeWhere((c) => c.tick >= _confettiTicks);
    }
  }

  void clear() => pieces.clear();
}

/// Mutable scene read by the painter every frame (HTML `State` plus the
/// Three.js objects' animated values).
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based); one past the last step once done.
  int step = 1;

  // ------------------------------------------------------- HTML State.s1
  /// `State.s1.lightPollution`, 0 (Low) … 100 (High).
  double pollution = _pollutionHigh;

  /// How far the band stars have streamed along the arch (radians).
  double bandDrift = 0;

  // ------------------------------------------------------- HTML State.s2
  /// `State.s2.level`, 1 … 4, and the level fading out.
  int level = 1;
  int fadingLevel = 0;
  double levelAt = -100;

  /// The camera and its tween.
  _CamMove camera = const _CamMove.still(_level1View);

  /// `orbitGroup.rotation.y` per planet and the turns of levels 2–4.
  final List<double> planetTurns = List.filled(_planets.length, 0);
  double armTurn = 0;
  double galaxyTurn = 0;
  double universeTurn = 0;

  // -------------------------------------------------------------- labels
  final _Appear cityLabel = _Appear();
  final _Appear milkyLabel = _Appear();
  final _Appear levelLabel = _Appear();

  final _Confetti confetti = _Confetti();

  int get stepCount => _stepCounts[scenario];
  bool get done => step > stepCount;

  /// The pollution factor (1 High … 0 Low).
  double get factor => pollution / 100;

  /// HTML `slider_title`: 'Light Pollution' above 35, else 'Dark Sky
  /// Reserve'.
  bool get darkSky => pollution <= _cityLabelAbove;

  /// The camera at this moment (Scenario 2).
  _Cam get cam => _Cam(camera.at(time));

  /// Opacity of level [n] (1 … 4) during the cross-fade.
  double levelAlpha(int n) {
    final k = ((time - levelAt) / _levelFadeSeconds).clamp(0.0, 1.0);
    if (n == level) return k.toDouble();
    if (n == fadingLevel) return 1 - k.toDouble();
    return 0;
  }

  /// HTML `changeScenario()` / `resetScenarioState()`. Entering Scenario 2
  /// the camera tweens from [from] to the Solar System view (600 ms).
  void load(int index, {_View? from}) {
    scenario = index;
    step = 1;
    pollution = _pollutionHigh;
    level = 1;
    fadingLevel = 0;
    levelAt = time - _levelFadeSeconds;
    camera = from == null
        ? const _CamMove.still(_level1View)
        : _CamMove(from, _level1View, time, _resetSeconds, _quadOut);
    cityLabel.update(false, time);
    milkyLabel.update(false, time);
    levelLabel.update(false, time);
  }

  /// HTML `handleZoomOutClick()`: the next level appears and the camera
  /// pulls back to it.
  void zoomOut() {
    final next = level + 1;
    fadingLevel = level;
    level = next;
    levelAt = time;
    camera = camera.toward(
      _levelViews[next - 1],
      time,
      _zoomSeconds[next - 2],
      _cubicOut,
    );
  }

  /// HTML `animate()`, [dt] seconds on: the band streams, the planets
  /// orbit, the visible level turns and the labels appear or hide.
  void tick(double dt) {
    final frames = dt * _fps;
    if (scenario == 0) {
      bandDrift = (bandDrift + _bandDrift * dt) % (2 * _bandSpan);
      cityLabel.update(pollution > _cityLabelAbove, time);
      milkyLabel.update(pollution <= _milkyLabelAtMost, time);
    } else {
      switch (level) {
        case 1:
          for (var i = 0; i < _planets.length; i++) {
            planetTurns[i] =
                (planetTurns[i] + _planets[i].turn * frames) % (2 * math.pi);
          }
        case 2:
          armTurn = (armTurn + _armSpin * dt) % (2 * math.pi);
        case 3:
          galaxyTurn = (galaxyTurn + _galaxySpin * dt) % (2 * math.pi);
        default:
          universeTurn = (universeTurn + _universeSpin * dt) % (2 * math.pi);
      }
      levelLabel.update(true, time, level);
    }
  }
}

class _GalaxyLabState extends State<Ch12A6OurGalaxyAndTheUniversePage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();

  /// The full-canvas overlay layer (the confetti's size).
  final GlobalKey _canvasKey = GlobalKey();
  late final Ticker _ticker;

  /// Last toast and the language of the last build, so a toast still on
  /// screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

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

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update() (the camera reads the scene time),
  /// the band, planets and galaxies, the confetti, then a repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s
      ..time = now
      ..tick(dt);
    s.confetti.update(dt);
    _frame.value = now;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(msg)`; its toasts make no sound.
  void _toast(String key) {
    _toastKey = key;
    _lab.showToast(_t(key), sound: false);
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

  /// HTML `changeScenario(sc)`: resets the scenario's state and camera.
  /// Scenario 2's camera tweens in from where the last view was.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    final s = _scene;
    final from = s.scenario == 0 ? _cityView : s.camera.at(s.time);
    setState(() => s.load(index, from: index == 1 ? from : null));
    _lab.resetView(sound: false);
  }

  /// HTML `resetApp()`: Scenario 1 from scratch (the shell restores the
  /// language, theme, sidebar and curtain).
  void _reset() {
    _scene.confetti.clear();
    _loadScenario(0);
  }

  /// HTML `progressStep()`.
  void _progressStep() => setState(() => _scene.step++);

  /// HTML `light-slider` `oninput` → `applyLightPollutionLevel(val)`: the
  /// city lights, sky, faint stars and Milky Way follow the slider; below
  /// 60 step 1 is done, at 8 or less step 2.
  void _setPollution(double value) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    final v = value.roundToDouble().clamp(0.0, _pollutionHigh);
    if (v == s.pollution) return;
    setState(() => s.pollution = v);
    if (s.step == 1 && v < _dimBelow) {
      _progressStep();
      _toast('toast_dimming');
    } else if (s.step == 2 && v <= _revealAtMost) {
      _progressStep();
      _toast('toast_revealed');
    }
  }

  /// The slider let go: a jump straight to Low (one HTML `input` event that
  /// only finished step 1) finishes step 2 as well.
  void _pollutionSettled() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step == 2 && s.pollution <= _revealAtMost) {
      _progressStep();
      _toast('toast_revealed');
    }
  }

  /// HTML `handleZoomOutClick()`: the next level, the camera pulls back
  /// and the step moves on.
  void _zoomOut() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.level >= 4) return;
    _Sound.pop.play();
    s.zoomOut();
    _toast(switch (s.level) {
      2 => 'toast_arm',
      3 => 'toast_galaxy',
      _ => 'toast_universe',
    });
    if (s.step == s.level - 1) {
      _progressStep();
    } else {
      _refresh();
    }
  }

  /// The level badge (HTML `updateScenario2LevelDisplay()`).
  String _levelBadge() => _t(switch (_scene.level) {
    1 => 'level1_lbl',
    2 => 'level_arm_lbl',
    3 => 'level2_lbl',
    _ => 'level3_lbl',
  });

  // ---------------------------------------------------------------- popups

  /// HTML `triggerConclusion()`: the scenario's summary with confetti.
  void _triggerConclusion() {
    if (!mounted) return;
    final s = _scene;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    s.confetti
      ..size = _canvasSize
      ..fire(
        _summaryConfetti,
        _summarySpread,
        const Offset(0.5, _summaryOriginY),
      );
    _lab.showPopup(() => _summaryPopup(sc));
    _refresh();
  }

  /// HTML `#summary-modal`: "Success!", "Scenario N Complete!" and the
  /// summary. Scenario 1 keeps the note to pick the next scenario and
  /// offers it; Scenario 2 continues to 'Mastery Achieved!'.
  LabPopupContent _summaryPopup(int sc) {
    final first = sc == 0;
    return LabPopupContent(
      title: _t('success'),
      icon: Icons.check_circle,
      accent: _Colors.blue500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          title: labFormat(_t('sc_complete'), {'n': sc + 1}),
          summary: _t('s${sc + 1}_summary'),
          note: first ? _t('select_next_msg') : null,
          amber: !first,
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        if (first)
          LabAction(
            label: _t('next_sc'),
            icon: Icons.arrow_forward,
            color: _Colors.blue600,
            foreground: _Colors.white,
            silent: true,
            onTap: () {
              _Sound.scenario.play();
              _loadScenario(1);
            },
          )
        else
          LabAction(
            label: _lab.t('btn_continue'),
            icon: Icons.emoji_events,
            color: _Colors.blue600,
            foreground: _Colors.white,
            silent: true,
            onTap: _showMastery,
          ),
      ],
    );
  }

  /// HTML `#success-modal`: "Mastery Achieved!" with confetti and 'Restart
  /// Entire Lab' (HTML `restartApp()` = `resetApp()`).
  void _showMastery() {
    final s = _scene;
    s.confetti
      ..size = _canvasSize
      ..fire(
        _masteryConfetti,
        _masterySpread,
        const Offset(0.5, _masteryOriginY),
      );
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('success'),
        icon: Icons.stars,
        accent: _Colors.blue500,
        extra: Builder(
          builder: (context) => _MasteryCard(
            title: _t('all_complete'),
            text: _t('all_complete_desc'),
            palette: _lab.palette,
            scale: context.labScale,
            fontScale: _lab.fontScale,
          ),
        ),
        actions: [
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.blue600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
        ],
      ),
    );
  }

  /// HTML 'Observe Conclusion' (`#compare-btn-container`), in the sidebar
  /// and the mission card.
  LabAction _concludeAction() => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.blue600,
    foreground: _Colors.white,
    highlight: true,
    // showPopup() plays HTML `success`.
    silent: true,
    onTap: _triggerConclusion,
  );

  /// Size of the canvas (for the confetti).
  Size get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : _design;
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
        final scene = _scene;
        final data = _data;
        final n = scene.scenario + 1;
        final hud = math.min(scene.step, _hudCounts[scene.scenario]);
        return LabShell(
          controller: _lab,
          icon: Icons.public,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // HTML `updateTeacherBoard()`: `hud[min(step, hud.length - 1)]`.
          hud: _t('s${n}_hud_$hud'),
          actions: [if (scene.done) _concludeAction()],
          onReset: _reset,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch12a6-steps-${scene.scenario}-${scene.step}'),
            steps: data.steps,
            current: scene.step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
          overlays: _overlays(context, p, s),
          stage: _buildStage(),
        );
      },
    );
  }

  /// Canvas cards: the light-pollution slider (Scenario 1) or the level
  /// badge and 'ZOOM OUT' (Scenario 2) above the HUD, 'Observe Conclusion'
  /// above them once the scenario is done, the galaxies banner (top right)
  /// and the confetti.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final scene = _scene;
    // The shell's HUD sits at the bottom while the sidebar is open.
    final hudRoom = _lab.isSidebarOpen ? (compact ? 58 : 70) * s : 0.0;
    final conclude = scene.done && _lab.popup == null;
    return [
      Positioned(
        key: ValueKey('ch12a6-controls-${scene.scenario}'),
        left: inset.left,
        right: inset.right,
        bottom: inset.bottom + hudRoom,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (conclude) ...[
                  _ConcludeButton(
                    label: _t('btn_conclude'),
                    onTap: _triggerConclusion,
                    clock: _frame,
                    scale: s,
                    compact: compact,
                  ),
                  SizedBox(height: (compact ? 8 : 14) * s),
                ],
                if (scene.scenario == 0)
                  _PollutionCard(
                    title: _t(
                      scene.darkSky
                          ? 'slider_title_dark'
                          : 'slider_title_light',
                    ),
                    low: _t('low_lbl'),
                    high: _t('high_lbl'),
                    value: scene.pollution,
                    onChanged: _setPollution,
                    onChangeEnd: _pollutionSettled,
                    palette: p,
                    scale: s,
                    compact: compact,
                  )
                else
                  _ZoomControl(
                    badge: _levelBadge(),
                    label: _t('btn_zoom_out_lbl'),
                    showButton: scene.level < 4,
                    onZoomOut: _zoomOut,
                    palette: p,
                    scale: s,
                    compact: compact,
                  ),
              ],
            ),
          ),
        ),
      ),
      if (scene.scenario == 1 && scene.level == 4)
        Positioned(
          key: const ValueKey('ch12a6-banner'),
          // Below the shell's toast, which shows the zoom-out message.
          top: inset.top + (compact ? 48 : 64) * s,
          right: inset.right,
          child: _GalaxiesBanner(
            text: _t('many_galaxies_msg'),
            scale: s,
            compact: compact,
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(scene.confetti, repaint: _frame),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
    ];
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        final scale = fit > 0 && fit.isFinite ? fit : 1.0;
        // Canvas labels stay readable when the stage is drawn small.
        final labelSize =
            _labelPx * (_labelFullScale / scale).clamp(1.0, _labelMaxBoost);
        final scene = _scene;
        final description = scene.scenario == 0
            ? _t('scene_s1')
            : '${_t('scene_s2')}: ${_levelBadge()}';
        return LabStage(
          designSize: _design,
          child: Semantics(
            image: true,
            label: description,
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: scene,
                  cache: _cache,
                  repaint: _frame,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  labelSize: labelSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------- canvas cards

/// The HTML `.white-card-ui` look: white in the light theme, slate-900 in
/// the dark one, with a blue border and a deep shadow.
BoxDecoration _whiteCard(LabPalette p, double radius) => BoxDecoration(
  color: p.isDark ? const Color(0xF20F172A) : const Color(0xF5FFFFFF),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(
    color: p.isDark ? const Color(0x803B82F6) : const Color(0x4D3B82F6),
    width: 2,
  ),
  boxShadow: const [
    BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 10)),
  ],
);

/// HTML `#s1-controls-box`: the 'Light Pollution' / 'Dark Sky Reserve'
/// title, the slider and the "Low ───→─── High" scale.
class _PollutionCard extends StatelessWidget {
  const _PollutionCard({
    required this.title,
    required this.low,
    required this.high,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    required this.palette,
    required this.scale,
    required this.compact,
  });

  final String title;
  final String low;
  final String high;

  /// Pollution level, 0 (Low) … 100 (High).
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;
  final LabPalette palette;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final strong = p.isDark ? _Colors.white : _Colors.slate900;
    final muted = p.isDark ? _Colors.slate300 : _Colors.slate700;
    return Container(
      width: (compact ? 330 : 400) * s,
      padding: EdgeInsets.symmetric(
        horizontal: 22 * s,
        vertical: (compact ? 7 : 12) * s,
      ),
      decoration: _whiteCard(p, 24 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: strong,
                fontSize: 13 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: labLetterSpacing(title, 1.4),
              ),
            ),
          ),
          SizedBox(height: (compact ? 0 : 3) * s),
          _LightSlider(
            value: value,
            label: title,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            scale: s,
            compact: compact,
          ),
          ExcludeSemantics(
            child: Row(
              children: [
                Text(
                  low,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // HTML "───→───" (drawn: not every font has the
                    // box-drawing glyph).
                    children: [
                      Container(
                        width: 26 * s,
                        height: 1.5 * s,
                        color: _Colors.blue500,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 13 * s,
                        color: _Colors.blue500,
                      ),
                      Container(
                        width: 26 * s,
                        height: 1.5 * s,
                        color: _Colors.blue500,
                      ),
                    ],
                  ),
                ),
                Text(
                  high,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w900,
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

/// HTML `#light-slider` (`<input type="range" min 0 max 100 step 1>`): a
/// blue gradient track and a white-ringed blue thumb. Drag the thumb or tap
/// the track; screen readers adjust it in steps of 5.
class _LightSlider extends StatelessWidget {
  const _LightSlider({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.onChangeEnd,
    required this.scale,
    required this.compact,
  });

  final double value;
  final String label;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;
  final double scale;
  final bool compact;

  /// Thumb radius (the HTML 24 px thumb) and the screen-reader step.
  static const double _thumbR = 12;
  static const double _step = 5;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final v = value.round();
    void nudge(double by) {
      onChanged((value + by).clamp(0.0, _pollutionHigh));
      onChangeEnd();
    }

    // Its own node: the card around it is a drag handle (LabMovable).
    return Semantics(
      container: true,
      slider: true,
      label: label,
      value: '$v',
      increasedValue: '${math.min(100, v + _step.round())}',
      decreasedValue: '${math.max(0, v - _step.round())}',
      onIncrease: () => nudge(_step),
      onDecrease: () => nudge(-_step),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final inset = _thumbR * s + 2;
          double at(Offset local) =>
              ((local.dx - inset) / math.max(1, w - 2 * inset) * 100).clamp(
                0.0,
                _pollutionHigh,
              );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapDown: (d) => onChanged(at(d.localPosition)),
            onTapUp: (_) => onChangeEnd(),
            onHorizontalDragStart: (d) => onChanged(at(d.localPosition)),
            onHorizontalDragUpdate: (d) => onChanged(at(d.localPosition)),
            onHorizontalDragEnd: (_) => onChangeEnd(),
            onHorizontalDragCancel: onChangeEnd,
            child: SizedBox(
              width: w,
              height: (compact ? 34 : 40) * s,
              child: CustomPaint(
                painter: _SliderPainter(
                  value: value / _pollutionHigh,
                  scale: s,
                  inset: inset,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The slider's track (#1d4ed8 → #3b82f6 → #93c5fd, 8 px) and thumb
/// (#3b82f6 with a 3 px white ring and a shadow).
class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.value,
    required this.scale,
    required this.inset,
  });

  final double value;
  final double scale;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final cy = size.height / 2;
    final track = Rect.fromLTRB(
      inset,
      cy - 4 * s,
      size.width - inset,
      cy + 4 * s,
    );
    final rr = RRect.fromRectAndRadius(track, Radius.circular(4 * s));
    canvas
      ..drawRRect(
        rr,
        Paint()
          ..shader = const LinearGradient(
            colors: [_Colors.blue700, _Colors.blue500, _Colors.blue300],
          ).createShader(track),
      )
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x4D000000),
      );
    final x = inset + value * (size.width - 2 * inset);
    final c = Offset(x, cy);
    final r = _LightSlider._thumbR * s;
    canvas
      ..drawCircle(
        c + Offset(0, 2 * s),
        r + 1,
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * s),
      )
      ..drawCircle(c, r, Paint()..color = _Colors.white)
      ..drawCircle(c, r - 3 * s, Paint()..color = _Colors.blue500);
  }

  @override
  bool shouldRepaint(covariant _SliderPainter old) =>
      old.value != value || old.scale != scale || old.inset != inset;
}

/// HTML `#s2-controls-box`: the level badge and, until the last level, the
/// 'ZOOM OUT' button.
class _ZoomControl extends StatelessWidget {
  const _ZoomControl({
    required this.badge,
    required this.label,
    required this.showButton,
    required this.onZoomOut,
    required this.palette,
    required this.scale,
    required this.compact,
  });

  final String badge;
  final String label;
  final bool showButton;
  final VoidCallback onZoomOut;
  final LabPalette palette;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HTML `#s2-level-badge`.
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: const Color(0xE60F172A),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x803B82F6)),
            boxShadow: const [
              BoxShadow(
                color: LabInk.shadowSoft,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.layers, size: 14 * s, color: _Colors.blue400),
              SizedBox(width: 8 * s),
              Text(
                badge,
                style: TextStyle(
                  color: _Colors.blue300,
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (showButton) ...[
          SizedBox(height: (compact ? 6 : 10) * s),
          _ZoomOutButton(
            label: label,
            onTap: onZoomOut,
            palette: palette,
            scale: s,
            compact: compact,
          ),
        ],
      ],
    );
  }
}

/// HTML `#btn-main-zoom-out`: a white card with a circled minus and 'ZOOM
/// OUT'; blue with white text while hovered or pressed.
class _ZoomOutButton extends StatefulWidget {
  const _ZoomOutButton({
    required this.label,
    required this.onTap,
    required this.palette,
    required this.scale,
    required this.compact,
  });

  final String label;
  final VoidCallback onTap;
  final LabPalette palette;
  final double scale;
  final bool compact;

  @override
  State<_ZoomOutButton> createState() => _ZoomOutButtonState();
}

class _ZoomOutButtonState extends State<_ZoomOutButton> {
  bool _hot = false;

  void _setHot(bool hot) {
    if (hot != _hot) setState(() => _hot = hot);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final ink = _hot
        ? _Colors.white
        : (p.isDark ? _Colors.blue300 : _Colors.blue600);
    final card = _whiteCard(p, 16 * s);
    // A button node of its own (the card around it is a drag handle).
    return AnimatedScale(
      scale: _hot ? 1.05 : 1,
      duration: const Duration(milliseconds: 150),
      child: Semantics(
        container: true,
        button: true,
        child: Material(
          color: LabInk.clear,
          child: Ink(
            decoration: card.copyWith(
              color: _hot ? _Colors.blue600 : card.color,
              border: Border.all(color: const Color(0x993B82F6), width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16 * s),
              onTap: w.onTap,
              onHover: _setHot,
              onHighlightChanged: _setHot,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30 * s,
                    vertical: (w.compact ? 8 : 13) * s,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26 * s,
                        height: 26 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ink, width: 2 * s),
                        ),
                        child: Icon(Icons.remove, size: 16 * s, color: ink),
                      ),
                      SizedBox(width: 12 * s),
                      Text(
                        w.label,
                        style: TextStyle(
                          color: ink,
                          fontSize: 17 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(w.label, 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HTML `#s2-step3-banner`: "There are many galaxies in the outer space
/// beyond the Milky Way Galaxy", top right.
class _GalaxiesBanner extends StatelessWidget {
  const _GalaxiesBanner({
    required this.text,
    required this.scale,
    required this.compact,
  });

  final String text;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(maxWidth: (compact ? 260 : 384) * s),
      padding: EdgeInsets.symmetric(
        horizontal: (compact ? 14 : 20) * s,
        vertical: (compact ? 8 : 12) * s,
      ),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0x803B82F6), width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 6 * s),
                child: Icon(
                  Icons.auto_awesome,
                  size: 15 * s,
                  color: _Colors.sky400,
                ),
              ),
            ),
            TextSpan(text: text),
          ],
        ),
        textAlign: TextAlign.right,
        style: TextStyle(
          color: _Colors.white,
          fontSize: (compact ? 11.5 : 13) * s,
          fontWeight: FontWeight.w800,
          height: 1.35,
          letterSpacing: labLetterSpacing(text, 0.3),
        ),
      ),
    );
  }
}

/// HTML 'Observe Conclusion' (`#compare-btn-container`): a blue → sky
/// gradient button with a lightbulb that bounces (`animate-bounce`).
class _ConcludeButton extends StatelessWidget {
  const _ConcludeButton({
    required this.label,
    required this.onTap,
    required this.clock,
    required this.scale,
    required this.compact,
  });

  final String label;
  final VoidCallback onTap;

  /// Scene time (s), for the bounce.
  final ValueListenable<double> clock;
  final double scale;
  final bool compact;

  /// `animate-bounce`: up 25% of the height at 0 s and 1 s (ease-in fall),
  /// at rest at 0.5 s (ease-out rise).
  static double _lift(double t) {
    final k = t % 1;
    if (k < 0.5) {
      final x = k / 0.5;
      return 1 - x * x * x;
    }
    final x = (k - 0.5) / 0.5;
    return 1 - (1 - x) * (1 - x) * (1 - x);
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final height = (compact ? 40 : 50) * s;
    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -0.25 * height * _lift(clock.value)),
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: const LinearGradient(
            colors: [_Colors.blue600, _Colors.sky600],
          ),
          border: Border.all(color: const Color(0x4DFFFFFF), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x663B82F6),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        // A button node of its own (the card around it is a drag handle).
        child: Semantics(
          container: true,
          button: true,
          child: Material(
            color: LabInk.clear,
            child: InkWell(
              borderRadius: BorderRadius.circular(16 * s),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(kMinInteractiveDimension, height),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28 * s),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb, size: 20 * s, color: _Colors.white),
                      SizedBox(width: 10 * s),
                      Text(
                        label,
                        style: TextStyle(
                          color: _Colors.white,
                          fontSize: (compact ? 13.5 : 15) * s,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- sidebar

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task, action and result. The current step is open (blue), done
/// steps show a green tick; a tap on a card's header opens or closes it
/// (HTML `toggleAccordion`). The HTML rebuilt the cards on every step, so
/// the state resets with the step (the widget is keyed by it).
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
        for (var i = 1; i <= widget.steps.length; i++) _card(context, i),
      ],
    );
  }

  Widget _card(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final dark = p.isDark;
    final past = i < w.current;
    final now = i == w.current;
    final open = _isOpen(i);
    final step = w.steps[i - 1];
    final Color border, header, tone, badge, badgeText, badgeBorder;
    if (now) {
      border = _Colors.blue500;
      header = dark ? _Colors.slate800 : const Color(0x1A3B82F6);
      tone = _Colors.blue400;
      badge = _Colors.blue600;
      badgeText = _Colors.white;
      badgeBorder = _Colors.blue400;
    } else if (past) {
      border = const Color(0x8010B981);
      header = dark ? const Color(0x800F172A) : _Colors.slate100;
      tone = dark ? _Colors.emerald400 : _Colors.emerald600;
      badge = const Color(0x3310B981);
      badgeText = _Colors.emerald500;
      badgeBorder = const Color(0x6610B981);
    } else {
      border = dark ? _Colors.slate800 : _Colors.slate300;
      header = dark ? const Color(0x800F172A) : _Colors.slate100;
      tone = dark ? _Colors.slate400 : _Colors.slate500;
      badge = _Colors.slate800;
      badgeText = _Colors.slate400;
      badgeBorder = _Colors.slate600;
    }
    final strong = dark ? _Colors.white : _Colors.slate900;
    final body = dark ? _Colors.slate300 : _Colors.slate700;
    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: now
            ? const [
                BoxShadow(color: Color(0x4D3B82F6), spreadRadius: 1),
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: header,
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
                  padding: EdgeInsets.symmetric(horizontal: 12 * s),
                  child: Row(
                    children: [
                      Container(
                        width: 20 * s,
                        height: 20 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badge,
                          border: Border.all(color: badgeBorder),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 12 * s, color: badgeText)
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: badgeText,
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w900,
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
                            fontWeight: now || past
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
          if (open)
            Container(
              padding: EdgeInsets.all(12 * s),
              decoration: BoxDecoration(
                color: dark ? const Color(0x660F172A) : _Colors.slate50,
                border: Border(
                  top: BorderSide(
                    color: dark ? _Colors.slate800 : _Colors.slate200,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${w.conceptLabel}:'.toUpperCase(),
                    style: TextStyle(
                      color: _Colors.blue500,
                      fontSize: 9.5 * f,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(w.conceptLabel, 0.9),
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    step.concept,
                    style: TextStyle(
                      color: dark ? _Colors.slate200 : _Colors.slate800,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _labelled(w.actionLabel, step.action, strong, body, f),
                  SizedBox(height: 8 * s),
                  _labelled(
                    w.observationLabel,
                    step.observation,
                    strong,
                    dark ? _Colors.slate400 : _Colors.slate600,
                    f,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// `<strong>Label:</strong> text`.
  Widget _labelled(
    String label,
    String text,
    Color strong,
    Color body,
    double f,
  ) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: strong, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text),
        ],
      ),
      style: TextStyle(
        color: body,
        fontSize: 11.5 * f,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }
}

// ------------------------------------------------------------------- popups

/// HTML `#summary-modal` body: the lightbulb badge, "Scenario N Complete!",
/// the summary (bold heading, paragraphs, `*bold*` runs; see the STRINGS
/// markup) and, for Scenario 1, the note to pick the next scenario.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.summary,
    required this.note,
    required this.amber,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String title;
  final String summary;
  final String? note;

  /// Heading in amber (Scenario 2) instead of blue (Scenario 1).
  final bool amber;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final dark = p.isDark;
    final parts = summary.split('|');
    final heading = amber
        ? (dark ? _Colors.amber400 : const Color(0xFFB45309))
        : (dark ? _Colors.blue400 : _Colors.blue600);
    final body = TextStyle(
      color: dark ? _Colors.slate300 : _Colors.slate700,
      fontSize: 13 * f,
      fontWeight: FontWeight.w500,
      height: 1.55,
    );
    final note = this.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              color: const Color(0x333B82F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4D3B82F6)),
            ),
            child: Icon(Icons.lightbulb, size: 28 * s, color: _Colors.blue400),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 21 * f,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          parts.first,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: heading,
            fontSize: 16 * f,
            fontWeight: FontWeight.w900,
          ),
        ),
        for (final paragraph in parts.skip(1)) ...[
          SizedBox(height: 6 * s),
          Text.rich(
            _rich(paragraph, p.textStrong),
            textAlign: TextAlign.center,
            style: body,
          ),
        ],
        if (note != null) ...[
          SizedBox(height: 14 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: const Color(0x1A3B82F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4D3B82F6)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 17 * s,
                  color: dark ? _Colors.blue400 : _Colors.blue600,
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      color: dark ? _Colors.blue300 : _Colors.blue700,
                      fontSize: 12 * f,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// A paragraph with its `*bold*` runs in [strong].
  static TextSpan _rich(String text, Color strong) {
    final runs = text.split('*');
    return TextSpan(
      children: [
        for (var i = 0; i < runs.length; i++)
          if (runs[i].isNotEmpty)
            TextSpan(
              text: runs[i],
              style: i.isOdd
                  ? TextStyle(color: strong, fontWeight: FontWeight.w800)
                  : null,
            ),
      ],
    );
  }
}

/// HTML `#success-modal` body: the trophy, "Mastery Achieved!" and the
/// closing text.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.title,
    required this.text,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String title;
  final String text;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60 * s,
            height: 60 * s,
            decoration: BoxDecoration(
              color: const Color(0x333B82F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4D3B82F6)),
            ),
            child: Icon(
              Icons.emoji_events,
              size: 30 * s,
              color: _Colors.blue400,
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 21 * f,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.isDark ? _Colors.slate300 : _Colors.slate700,
            fontSize: 13 * f,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

/// canvas-confetti pieces: each a small wobbling quad (its `square`
/// shape), fading over its 200 ticks; drawn as one vertex batch.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.confetti, {required Listenable repaint})
    : super(repaint: repaint);

  final _Confetti confetti;

  /// canvas-confetti's `fetti.random` (2 … 3), fixed here.
  static const double _skew = 2.5;

  /// Wobble radius (10 × `scalar`).
  static const double _wobbleR = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final pieces = confetti.pieces;
    if (pieces.isEmpty) return;
    final positions = <Offset>[];
    final colors = <Color>[];
    for (final c in pieces) {
      final color = c.color.withValues(
        alpha: (1 - c.tick / _confettiTicks).clamp(0.0, 1.0),
      );
      final wx = c.x + _wobbleR * math.cos(c.wobble);
      final wy = c.y + _wobbleR * math.sin(c.wobble);
      final tc = _skew * math.cos(c.tilt);
      final ts = _skew * math.sin(c.tilt);
      final a = Offset(c.x, c.y);
      final b = Offset(wx, c.y + ts);
      final d = Offset(wx + tc, wy + ts);
      final e = Offset(c.x + tc, wy);
      positions.addAll([a, b, d, a, d, e]);
      for (var k = 0; k < 6; k++) {
        colors.add(color);
      }
    }
    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
    );
    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.confetti != confetti;
}

// ================================================================== PAINTING

/// Points of one cloud sorted into colour bins, projected every frame into
/// reusable buffers and drawn with one `drawRawPoints` call per bin.
class _PointBatch {
  _PointBatch(this.colors, List<int> capacity)
    : _xy = [for (final n in capacity) Float32List(n * 2)],
      _count = List.filled(capacity.length, 0);

  final List<Color> colors;
  final List<Float32List> _xy;
  final List<int> _count;

  void clear() => _count.fillRange(0, _count.length, 0);

  void add(int bin, double x, double y) {
    final i = _count[bin];
    _xy[bin]
      ..[2 * i] = x
      ..[2 * i + 1] = y;
    _count[bin] = i + 1;
  }

  /// Draws bins [from] … [to] (all by default) as round dots of [size].
  void draw(
    Canvas canvas,
    Paint paint, {
    required double opacity,
    required double size,
    int from = 0,
    int? to,
  }) {
    paint.strokeWidth = size;
    for (var b = from; b < (to ?? colors.length); b++) {
      final n = _count[b];
      if (n == 0) continue;
      final c = colors[b];
      paint.color = c.withValues(alpha: c.a * opacity);
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(_xy[b], 0, n * 2),
        paint,
      );
    }
  }
}

/// Projects the x, y, z cloud [xyz] turned by [turn] about the vertical
/// axis through ([ox], [oz]) (Three.js `group.rotation.y`) into [batch],
/// binned by [bins]; points behind the camera or far off the stage are
/// skipped.
void _projectCloud(
  _Cam cam,
  Float32List xyz,
  Uint8List bins,
  _PointBatch batch, {
  double turn = 0,
  double ox = 0,
  double oz = 0,
}) {
  batch.clear();
  final c = math.cos(turn), s = math.sin(turn);
  for (var i = 0; i < bins.length; i++) {
    final px = xyz[3 * i] - ox, pz = xyz[3 * i + 2] - oz;
    final dx = ox + px * c + pz * s - cam.ex;
    final dy = xyz[3 * i + 1] - cam.ey;
    final dz = oz - px * s + pz * c - cam.ez;
    final depth = dx * cam.fx + dy * cam.fy + dz * cam.fz;
    if (depth < 1) continue;
    final k = cam.k / depth;
    final sx = cam.cx + (dx * cam.rx + dy * cam.ry + dz * cam.rz) * k;
    final sy = cam.cy - (dx * cam.ux + dy * cam.uy + dz * cam.uz) * k;
    if (sx < _cull.left || sx > _cull.right) continue;
    if (sy < _cull.top || sy > _cull.bottom) continue;
    batch.add(bins[i], sx, sy);
  }
}

/// One face of a unit box: outward normal and its corners (signs of x, y,
/// z) as seen from outside: top-left, top-right, bottom-right, bottom-left.
@immutable
class _Face {
  const _Face(this.normal, this.corners);

  final _V normal;
  final List<_V> corners;
}

const List<_Face> _boxFaces = [
  _Face(_V(0, 0, 1), [_V(-1, 1, 1), _V(1, 1, 1), _V(1, -1, 1), _V(-1, -1, 1)]),
  _Face(_V(0, 0, -1), [
    _V(1, 1, -1),
    _V(-1, 1, -1),
    _V(-1, -1, -1),
    _V(1, -1, -1),
  ]),
  _Face(_V(1, 0, 0), [_V(1, 1, 1), _V(1, 1, -1), _V(1, -1, -1), _V(1, -1, 1)]),
  _Face(_V(-1, 0, 0), [
    _V(-1, 1, -1),
    _V(-1, 1, 1),
    _V(-1, -1, 1),
    _V(-1, -1, -1),
  ]),
  _Face(_V(0, 1, 0), [_V(-1, 1, -1), _V(1, 1, -1), _V(1, 1, 1), _V(-1, 1, 1)]),
];

/// The directional light's direction (towards (20, 50, 30)).
final _V _cityLightDir = _cityLightAt.unit;

/// Texture colour times material colour (Three.js `map` × `color`).
Color _times(Color a, Color b) =>
    Color.from(alpha: 1, red: a.r * b.r, green: a.g * b.g, blue: a.b * b.b);

/// The building texture (#0f172a) under the material colours 0x1e293b
/// (podium, shaft, buildings) and 0x334155 (the tower's top tier).
final Color _buildingAlbedo = _times(
  _Colors.buildingTexel,
  _Colors.buildingTint,
);
final Color _topTierAlbedo = _times(_Colors.buildingTexel, _Colors.topTierTint);

/// MeshLambertMaterial under the city lights (r128, no output encoding):
/// albedo × (ambient × 0.9 + n·l × directional × 1.4), the directional
/// light off ([lit] false) or at full strength.
Color _cityLit(Color albedo, _V normal, {required bool lit}) {
  final k = lit
      ? math.max(0.0, normal.dot(_cityLightDir)) * _lightsIntensity
      : 0.0;
  double ch(double a, double ambient, double light) =>
      (a * (ambient * _cityAmbient + light * k)).clamp(0.0, 1.0);
  return Color.from(
    alpha: 1,
    red: ch(albedo.r, _Colors.cityAmbient.r, _Colors.cityLight.r),
    green: ch(albedo.g, _Colors.cityAmbient.g, _Colors.cityLight.g),
    blue: ch(albedo.b, _Colors.cityAmbient.b, _Colors.cityLight.b),
  );
}

/// HTML `createBuildingTexture(true)`, drawn [_windowTexScale] times larger
/// into an image the window faces tile.
ui.Image _windowTexture() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  const k = _windowTexScale;
  for (final (col, row, color) in _Cosmos.instance.windowCells) {
    paint.color = _Colors.windows[color];
    canvas.drawRect(
      Rect.fromLTWH(
        (4 + 10 * col) * k.toDouble(),
        (4 + 10 * row) * k.toDouble(),
        6.0 * k,
        7.0 * k,
      ),
      paint,
    );
  }
  final picture = recorder.endRecording();
  final image = picture.toImageSync(
    _windowTexW * _windowTexScale,
    _windowTexH * _windowTexScale,
  );
  picture.dispose();
  return image;
}

/// Draws the city through the city camera: the ground, the buildings and
/// the tower (Lambert-lit boxes), their window boxes (the window texture),
/// roof caps, antennas, beacons and the street lamps.
class _CityGfx {
  _CityGfx(this.canvas, this.windows, {required this.lit});

  final Canvas canvas;
  final ui.Image windows;

  /// The city lights on (windows, lamps and beacons at 0.88, the
  /// directional and lamp lights at full strength) or off.
  final bool lit;
  final _Cam cam = _Cam(_cityView, _cityFraming);
  final Paint _fill = Paint();
  final Paint _seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..color = const Color(0x591E293B);

  /// The ground plane (0x090d16) and, lit, the warm pools of the lamps'
  /// point lights.
  void ground() {
    final corners = [
      const _V(-_groundSide, 0, _groundFar),
      const _V(_groundSide, 0, _groundFar),
      const _V(_groundSide, 0, _groundNear),
      const _V(-_groundSide, 0, _groundNear),
    ];
    canvas.drawPath(
      Path()..addPolygon([for (final c in corners) cam.p(c)], true),
      _fill..color = _cityLit(_Colors.ground, _V.up, lit: lit),
    );
    if (!lit) return;
    for (var x = _lampFirst; x <= _lampLast; x += _lampStep) {
      final c = cam.p(_V(x, 0, _lampZ));
      final rx = (cam.p(_V(x + _lampReach, 0, _lampZ)) - c).dx;
      final ry =
          (cam.p(_V(x, 0, _lampZ + _lampReach * 0.7)) -
                  cam.p(_V(x, 0, _lampZ - _lampReach * 0.7)))
              .dy
              .abs() /
          2;
      final rect = Rect.fromCenter(center: c, width: 2 * rx, height: 2 * ry);
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _Colors.lampLight.withValues(alpha: 0.16),
              _Colors.lampLight.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
  }

  /// The corners of [face] of the box at [c] with half sizes [h].
  List<Offset> _corners(_Face face, _V c, _V h) => [
    for (final k in face.corners)
      cam.p(_V(c.x + k.x * h.x, c.y + k.y * h.y, c.z + k.z * h.z)),
  ];

  /// Whether [face] of the box at [c] with half sizes [h] faces the eye.
  bool _facing(_Face face, _V c, _V h) {
    final n = face.normal;
    final centre = _V(c.x + n.x * h.x, c.y + n.y * h.y, c.z + n.z * h.z);
    return n.dot(cam.eye - centre) > 0;
  }

  /// A Lambert box (BoxGeometry) of [albedo].
  void box(_V c, _V h, Color albedo) {
    for (final face in _boxFaces) {
      if (!_facing(face, c, h)) continue;
      final path = Path()..addPolygon(_corners(face, c, h), true);
      canvas
        ..drawPath(path, _fill..color = _cityLit(albedo, face.normal, lit: lit))
        ..drawPath(path, _seam);
    }
  }

  /// A window box at [c] with half sizes [h], its texture repeated
  /// [rx] × [ry] times on every face; only the part above [floor] is drawn
  /// (the rest is inside the building below it). Its top is drawn when
  /// [top] is set.
  void windowBox(
    _V c,
    _V h,
    int rx,
    int ry, {
    required bool top,
    double floor = -1,
  }) {
    if (!lit) return;
    final texW = (_windowTexW * _windowTexScale * rx).toDouble();
    final texH = (_windowTexH * _windowTexScale * ry).toDouble();
    for (final face in _boxFaces) {
      if (face.normal.y > 0 && !top) continue;
      if (!_facing(face, c, h)) continue;
      final full = _corners(face, c, h);
      final tl = full[0], tr = full[1], bl = full[3];
      final a = (tr - tl) / texW;
      final b = (bl - tl) / texH;
      final matrix = Float64List.fromList([
        a.dx,
        a.dy,
        0,
        0,
        b.dx,
        b.dy,
        0,
        0,
        0,
        0,
        1,
        0,
        tl.dx,
        tl.dy,
        0,
        1,
      ]);
      var outline = full;
      if (face.normal.y == 0 && floor > c.y - h.y) {
        // Cut at the floor: the lower corners move up to it.
        final cut = _V(h.x, (c.y + h.y - floor) / 2, h.z);
        final mid = _V(c.x, floor + cut.y, c.z);
        outline = _corners(face, mid, cut);
      }
      canvas.drawPath(
        Path()..addPolygon(outline, true),
        Paint()
          ..color = const Color.fromRGBO(0, 0, 0, _lightsOpacity)
          ..shader = ui.ImageShader(
            windows,
            TileMode.repeated,
            TileMode.repeated,
            matrix,
            filterQuality: FilterQuality.medium,
          ),
      );
    }
  }

  /// A MeshBasic sphere: a flat disc of [color] at [at], radius [r].
  void ball(_V at, double r, Color color) {
    canvas.drawCircle(cam.p(at), r * cam.scaleAt(at), _fill..color = color);
  }

  /// A random building: its Lambert body, the lit window box, the roof cap
  /// and the antenna with its red light.
  void building(_Building b) {
    box(_V(b.x, b.h / 2, b.z), _V(b.w / 2, b.h / 2, b.d / 2), _buildingAlbedo);
    final winH = b.h * _windowHeight;
    final winY = b.h / 2 + 1;
    windowBox(
      _V(b.x, winY, b.z),
      _V((b.w + _windowPad) / 2, winH / 2, (b.d + _windowPad) / 2),
      b.repeatX,
      b.repeatY,
      top: winY + winH / 2 > b.h,
    );
    if (!b.roofed) return;
    box(
      _V(b.x, b.h + _roofH / 2, b.z),
      _V(b.w * _roofScale / 2, _roofH / 2, b.d * _roofScale / 2),
      _Colors.roofCap,
    );
    if (!b.antenna) return;
    final base = cam.p(_V(b.x, b.h + _antennaBase, b.z));
    final tip = _V(b.x, b.h + _antennaTop, b.z);
    canvas.drawLine(
      base,
      cam.p(tip),
      Paint()
        ..strokeWidth = math.max(0.8, 0.3 * cam.scaleAt(tip))
        ..color = _Colors.antenna,
    );
    if (lit) {
      ball(tip, _redLightR, _Colors.beacon.withValues(alpha: _lightsOpacity));
    }
  }

  /// The landmark tower: podium, shaft, window box (from the podium's top),
  /// top tier, spire and red beacon.
  void tower() {
    const x = _towerX, z = _towerZ;
    box(const _V(x, 25, z), const _V(5, 13, 5), _buildingAlbedo);
    windowBox(
      const _V(x, 25, z),
      const _V(5.075, 18, 5.075),
      1,
      1,
      top: false,
      floor: 12,
    );
    box(const _V(x, 6, z), const _V(7, 6, 7), _buildingAlbedo);
    box(const _V(x, 44, z), const _V(3.25, 6, 3.25), _topTierAlbedo);
    // The spire: a cone (r 1.8, 14 tall) from y 50.
    final apex = cam.p(const _V(x, 64, z));
    final base = [
      for (var k = 0; k <= 12; k++)
        cam.p(
          _V(
            x - 1.8 * math.cos(k / 12 * math.pi),
            50,
            z + 1.8 * math.sin(k / 12 * math.pi),
          ),
        ),
    ];
    canvas.drawPath(
      Path()..addPolygon([apex, ...base], true),
      _fill..color = _cityLit(_Colors.spire, const _V(0, 0.13, 0.99), lit: lit),
    );
    if (lit) {
      ball(
        const _V(x, 64.5, z),
        0.8,
        _Colors.beacon.withValues(alpha: _lightsOpacity),
      );
    }
  }

  /// A street lamp (sphere 1.6, 0xfbbf24), lit only.
  void lamp(_V at) {
    if (lit) ball(at, _lampR, _Colors.lamp.withValues(alpha: _lightsOpacity));
  }
}

/// Records the city with its lights off or on. The HTML's lighting and
/// opacities are linear in the pollution factor, so the slider blends the
/// two recordings.
ui.Picture _recordCity(ui.Image windows, {required bool lit}) {
  final recorder = ui.PictureRecorder();
  final g = _CityGfx(Canvas(recorder), windows, lit: lit)..ground();
  final cam = g.cam;
  final items = <(double, VoidCallback)>[
    for (final b in _Cosmos.instance.buildings)
      (cam.depth(_V(b.x, b.h / 2, b.z)), () => g.building(b)),
    (cam.depth(const _V(_towerX, 25, _towerZ)), g.tower),
    for (var x = _lampFirst; x <= _lampLast; x += _lampStep)
      (cam.depth(_V(x, _lampY, _lampZ)), () => g.lamp(_V(x, _lampY, _lampZ))),
  ]..sort((a, b) => b.$1.compareTo(a.$1));
  for (final (_, paint) in items) {
    paint();
  }
  return recorder.endRecording();
}

/// `createSunSurfaceTexture()` wrapped on the Sun's visible hemisphere, at
/// radius [_sunDiscR]: the radial gradient's white centre falls on the
/// right limb (texture u = 0.5), its orange rim on the left limb and the
/// poles; the blotches on the near half show.
ui.Picture _recordSunDisc() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const r = _sunDiscR;
  final rect = Rect.fromCircle(center: Offset.zero, radius: r);
  canvas
    ..save()
    ..clipPath(Path()..addOval(rect))
    ..drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.centerRight,
          radius: 1,
          colors: [
            _Colors.sunWhite,
            _Colors.sunWhite,
            _Colors.sunYellow,
            _Colors.sunAmber,
            _Colors.sunOrange,
          ],
          stops: [0, 0.078, 0.4, 0.72, 1],
        ).createShader(rect),
    );
  final paint = Paint();
  for (final b in _Cosmos.instance.blotches) {
    final u = b.u / _sunTex, v = b.v / _sunTex;
    final phi = u * 2 * math.pi, theta = v * math.pi;
    final z = math.sin(phi) * math.sin(theta);
    if (z <= 0) continue;
    final x = -math.cos(phi) * math.sin(theta);
    final y = math.cos(theta);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x * r, -y * r),
        width: 2 * b.r / _sunTex * 2 * math.pi * r * math.sqrt(z),
        height: 2 * b.r / _sunTex * math.pi * r,
      ),
      paint..color = b.light ? _Colors.sunBlotchLight : _Colors.sunBlotchDark,
    );
  }
  canvas.restore();
  return recorder.endRecording();
}

/// The planets' night side: their colour under the ambient light
/// (0x475569 × 0.85).
Color _nightSide(Color c) => Color.from(
  alpha: 1,
  red: c.r * _Colors.solarAmbient.r * _solarAmbient,
  green: c.g * _Colors.solarAmbient.g * _solarAmbient,
  blue: c.b * _Colors.solarAmbient.b * _solarAmbient,
);

/// Paints, buffers, recordings and label text reused by every frame. Owned
/// (and disposed) by the page State.
class _PaintCache {
  final _Cosmos cosmos = _Cosmos.instance;
  final _Cam cityCam = _Cam(_cityView, _cityFraming);
  final _Cam skyCam = _Cam(_skyView, _skyFraming);

  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint points = Paint()..strokeCap = StrokeCap.round;

  late final _PointBatch band = _PointBatch(
    cosmos.bandColors,
    List.filled(_bandBins, _bandCount),
  );
  late final _PointBatch arm = _PointBatch(
    cosmos.armColors,
    _Cosmos.binSizes(cosmos.armBin, cosmos.armColors.length),
  );
  late final _PointBatch galaxy = _PointBatch(
    cosmos.galaxyColors,
    _Cosmos.binSizes(cosmos.galaxyBin, cosmos.galaxyColors.length),
  );
  late final _PointBatch prominenceBack = _PointBatch(
    cosmos.prominenceColors,
    _Cosmos.binSizes(cosmos.prominenceBin, _prominenceBins),
  );
  late final _PointBatch prominenceFront = _PointBatch(
    cosmos.prominenceColors,
    _Cosmos.binSizes(cosmos.prominenceBin, _prominenceBins),
  );
  late final _PointBatch spaceStars = _PointBatch(
    const [_Colors.spaceStar],
    const [_spaceStarCount],
  );
  late final Uint8List spaceStarBins = Uint8List(_spaceStarCount);

  /// The universe in [_universeDepthBands] + 1 depth bands × the galaxy
  /// colours (bin = band × colours + colour).
  late final _PointBatch universe = () {
    final types = _Colors.galaxyTypes.length;
    final perType = List<int>.filled(types, 0);
    for (final owner in cosmos.universeOwner) {
      perType[cosmos.clusterType[owner]]++;
    }
    final bands = _universeDepthBands.length + 1;
    return _PointBatch(
      [for (var b = 0; b < bands; b++) ..._Colors.galaxyTypes],
      [for (var b = 0; b < bands; b++) ...perType],
    );
  }();

  /// Each galaxy's depth band this frame.
  late final Uint8List clusterBand = Uint8List(_universeCount);

  ui.Image? _windows;
  ui.Picture? _cityDark;
  ui.Picture? _cityLit;
  ui.Picture? _sunDisc;

  /// The city recorded with its lights off or on.
  ui.Picture city({required bool lit}) {
    final windows = _windows ??= _windowTexture();
    return lit
        ? _cityLit ??= _recordCity(windows, lit: true)
        : _cityDark ??= _recordCity(windows, lit: false);
  }

  ui.Picture get sunDisc => _sunDisc ??= _recordSunDisc();

  /// Label text and icon glyphs, laid out once.
  final Map<(String, Color, double, FontWeight), TextPainter> _texts = {};
  final Map<(IconData, Color, double), TextPainter> _icons = {};
  String? _family;

  /// Painters kept before the caches start over.
  static const int _limit = 32;

  TextPainter text(String text, Color color, double size, FontWeight weight) {
    final family = LabFont.active.family;
    if (family != _family || _texts.length >= _limit) {
      _clear(_texts);
      _family = family;
    }
    return _texts.putIfAbsent(
      (text, color, size, weight),
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            height: 1.2,
            fontFamily: family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(),
    );
  }

  TextPainter icon(IconData icon, Color color, double size) {
    if (_icons.length >= _limit) _clear(_icons);
    return _icons.putIfAbsent(
      (icon, color, size),
      () => TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: color,
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  static void _clear(Map<Object, TextPainter> painters) {
    for (final p in painters.values) {
      p.dispose();
    }
    painters.clear();
  }

  void dispose() {
    _clear(_texts);
    _clear(_icons);
    _cityDark?.dispose();
    _cityLit?.dispose();
    _sunDisc?.dispose();
    _windows?.dispose();
  }
}

/// Paints the current scenario: Scenario 1's sky dome, stars, Milky Way
/// and city; Scenario 2's background stars and the visible zoom levels;
/// then the scene labels. Repaints every frame through [repaint].
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

  /// Label text size in design px.
  final double labelSize;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintNightSky(canvas, size);
    } else {
      _paintSpace(canvas, size);
    }
  }

  // ------------------------------------------------------------ scenario 1

  /// HTML `applyLightPollutionLevel()` on screen: the dome's colour, the
  /// bright stars, the faint stars and the Milky Way fading in, the city
  /// lights fading out.
  void _paintNightSky(Canvas canvas, Size size) {
    final s = scene;
    final c = cache;
    final f = s.factor;
    canvas.drawRect(labBleed(size), c.fill..color = _domeColor(f));
    _points(
      canvas,
      c.cosmos.brightStars,
      _Colors.brightStar,
      _brightOpacity,
      _brightSize * _pointScale / _skyView.reach,
    );
    final faint = math.pow(1 - f, _faintFade).toDouble() * _faintOpacity;
    if (faint > 0.004) {
      _points(
        canvas,
        c.cosmos.faintStars,
        _Colors.faintStar,
        faint,
        _faintSize * _pointScale / _skyView.reach,
      );
    }
    final band = math.pow(1 - f, _bandFade).toDouble() * _bandOpacity;
    if (band > 0.004) {
      _paintCoreCloud(canvas, band);
      _paintBand(canvas, band);
    }
    canvas.drawPicture(c.city(lit: false));
    if (f > 0.002) {
      canvas
        ..saveLayer(labBleed(size), Paint()..color = Color.fromRGBO(0, 0, 0, f))
        ..drawPicture(c.city(lit: true))
        ..restore();
    }
    if (!showLabels) return;
    final t = s.time;
    _label(
      canvas,
      c.cityCam.p(_cityLabelAt),
      _t('lbl_3d_city'),
      Icons.location_city,
      _Colors.amber400,
      _Colors.white,
      FontWeight.w800,
      s.cityLabel.alpha(t),
    );
    _label(
      canvas,
      c.skyCam.p(_milkyLabelAt),
      _t('lbl_3d_milkyway'),
      Icons.auto_awesome,
      _Colors.blue400,
      _Colors.blue200,
      FontWeight.w900,
      s.milkyLabel.alpha(t),
    );
  }

  /// A static point list (x, y pairs) as round dots.
  void _points(
    Canvas canvas,
    Float32List xy,
    Color color,
    double opacity,
    double size,
  ) {
    final p = cache.points
      ..strokeWidth = math.max(_minPoint, size)
      ..color = color.withValues(alpha: opacity);
    canvas.drawRawPoints(ui.PointMode.points, xy, p);
  }

  /// `mwCoreCloud`: the Milky Way's glowing golden core.
  void _paintCoreCloud(Canvas canvas, double opacity) {
    final cam = cache.skyCam;
    final o = cam.p(_coreCloudAt);
    final k = cam.scaleAt(_coreCloudAt);
    final rect = Rect.fromCenter(
      center: o,
      width: 2 * _coreCloudR * _coreCloudScaleX * k,
      height: 2 * _coreCloudR * _coreCloudScaleY * k,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = _Colors.coreCloud.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rect.height * 0.3),
    );
  }

  /// The band's 9500 stars streaming along the arch, coloured by how far
  /// they are from the core end.
  void _paintBand(Canvas canvas, double opacity) {
    final c = cache;
    final cam = c.skyCam;
    final cosmos = c.cosmos;
    final batch = c.band..clear();
    final drift = scene.bandDrift;
    const span = 2 * _bandSpan;
    for (var i = 0; i < _bandCount; i++) {
      final a = (cosmos.bandAngle[i] + drift + _bandSpan) % span - _bandSpan;
      final abs = a.abs();
      final spread =
          cosmos.bandSpread[i] * (_bandSpread - abs * _bandSpreadSlope);
      final dx = _bandR * math.cos(a) - cam.ex;
      final dy =
          (_bandR * math.sin(a)).abs() * _bandFlatten +
          spread * 0.5 +
          _bandLift -
          cam.ey;
      final dz = spread * _bandZSpread + cosmos.bandDepth[i] - cam.ez;
      final depth = dx * cam.fx + dy * cam.fy + dz * cam.fz;
      if (depth < 1) continue;
      final k = cam.k / depth;
      batch.add(
        math.min(_bandBins - 1, (abs / _bandSpan * _bandBins).floor()),
        cam.cx + (dx * cam.rx + dy * cam.ry + dz * cam.rz) * k,
        cam.cy - (dx * cam.ux + dy * cam.uy + dz * cam.uz) * k,
      );
    }
    batch.draw(
      canvas,
      c.points,
      opacity: opacity,
      size: math.max(_minPoint, _bandSize * _pointScale / _skyView.reach),
    );
  }

  // ------------------------------------------------------------ scenario 2

  /// The background stars, the level fading out, the current level and its
  /// label.
  void _paintSpace(Canvas canvas, Size size) {
    final s = scene;
    final c = cache;
    final cam = s.cam;
    canvas.drawRect(labBleed(size), c.fill..color = _Colors.space);
    _projectCloud(cam, c.cosmos.spaceStars, c.spaceStarBins, c.spaceStars);
    c.spaceStars.draw(
      canvas,
      c.points,
      opacity: _spaceStarOpacity,
      size: math.max(_minPoint, _spaceStarSize * _pointScale / _spaceStarR),
    );
    for (final n in [s.fadingLevel, s.level]) {
      final alpha = s.levelAlpha(n);
      if (n == 0 || alpha <= 0.004) continue;
      switch (n) {
        case 1:
          _paintSolarSystem(canvas, cam, alpha);
        case 2:
          _paintArm(canvas, cam, alpha);
        case 3:
          _paintGalaxy(canvas, cam, alpha);
        default:
          _paintUniverse(canvas, cam, alpha);
      }
    }
    if (!showLabels) return;
    final alpha = s.levelLabel.alpha(s.time) * s.levelAlpha(s.level);
    final (at, key, icon, iconColor, textColor, weight) = switch (s.level) {
      1 => (
        _solarLabelAt,
        'lbl_3d_solarsystem',
        Icons.wb_sunny,
        _Colors.amber400,
        _Colors.white,
        FontWeight.w800,
      ),
      2 => (
        _armLabelAt,
        'lbl_3d_solarsystem',
        Icons.place,
        _Colors.amber400,
        _Colors.amber300,
        FontWeight.w700,
      ),
      3 => (
        _galaxyLabelAt,
        'lbl_3d_milkyway',
        Icons.cyclone,
        _Colors.blue400,
        _Colors.blue300,
        FontWeight.w900,
      ),
      _ => (
        _universeLabelAt,
        'lbl_3d_universe',
        Icons.public,
        _Colors.sky400,
        _Colors.sky300,
        FontWeight.w900,
      ),
    };
    if (cam.depth(at) < 1) return;
    _label(
      canvas,
      cam.p(at),
      _t(key),
      icon,
      iconColor,
      textColor,
      weight,
      alpha,
    );
  }

  /// Level 1: the orbit lines, the planets on the far side of the Sun, the
  /// Sun, then the near planets.
  void _paintSolarSystem(Canvas canvas, _Cam cam, double alpha) {
    final c = cache;
    c.stroke
      ..strokeWidth = 1
      ..color = _Colors.orbit.withValues(alpha: _Colors.orbit.a * alpha);
    for (final planet in _planets) {
      final path = Path();
      var open = false;
      for (var k = 0; k <= _orbitSegments; k++) {
        final a = k / _orbitSegments * 2 * math.pi;
        final w = _V(math.cos(a) * planet.orbit, 0, math.sin(a) * planet.orbit);
        if (cam.depth(w) < 1) {
          open = false;
          continue;
        }
        final o = cam.p(w);
        if (open) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          open = true;
        }
      }
      canvas.drawPath(path, c.stroke);
    }
    final s = scene;
    final at = [
      for (var i = 0; i < _planets.length; i++)
        _V(_planets[i].orbit, 0, 0).turnY(s.planetTurns[i]),
    ];
    final order = [for (var i = 0; i < _planets.length; i++) i]
      ..sort((a, b) => cam.depth(at[b]).compareTo(cam.depth(at[a])));
    final sunDepth = cam.depth(_V.zero);
    for (final i in order.where((i) => cam.depth(at[i]) > sunDepth)) {
      _paintPlanet(canvas, cam, i, at[i], alpha);
    }
    _paintSun(canvas, cam, alpha);
    for (final i in order.where((i) => cam.depth(at[i]) <= sunDepth)) {
      _paintPlanet(canvas, cam, i, at[i], alpha);
    }
  }

  /// The Sun: the prominences behind it, the surface, the prominences in
  /// front, then the four additive corona glows.
  void _paintSun(Canvas canvas, _Cam cam, double alpha) {
    final c = cache;
    final cosmos = c.cosmos;
    final sunDepth = cam.depth(_V.zero);
    if (sunDepth < 1) return;
    final o = cam.p(_V.zero);
    final px = cam.scaleAt(_V.zero);
    c.prominenceBack.clear();
    c.prominenceFront.clear();
    final xyz = cosmos.prominences;
    for (var i = 0; i < _prominenceCount; i++) {
      final w = _V(xyz[3 * i], xyz[3 * i + 1], xyz[3 * i + 2]);
      final p = cam.p(w);
      (cam.depth(w) > sunDepth ? c.prominenceBack : c.prominenceFront).add(
        cosmos.prominenceBin[i],
        p.dx,
        p.dy,
      );
    }
    final dot = math.max(_minPoint, _prominenceSize * _pointScale / sunDepth);
    c.points.blendMode = BlendMode.plus;
    c.prominenceBack.draw(
      canvas,
      c.points,
      opacity: _prominenceOpacity * alpha,
      size: dot,
    );
    c.points.blendMode = BlendMode.srcOver;
    canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(_sunR * px / _sunDiscR);
    if (alpha < 1) {
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: _sunDiscR),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
    canvas.drawPicture(c.sunDisc);
    if (alpha < 1) canvas.restore();
    canvas.restore();
    c.points.blendMode = BlendMode.plus;
    c.prominenceFront.draw(
      canvas,
      c.points,
      opacity: _prominenceOpacity * alpha,
      size: dot,
    );
    c.points.blendMode = BlendMode.srcOver;
    for (var i = 0; i < _coronaRadii.length; i++) {
      final r = _coronaRadii[i] * px;
      final k = _coronaOpacities[i] * alpha;
      final rect = Rect.fromCircle(center: o, radius: r);
      canvas.drawCircle(
        o,
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              _Colors.glowCore.withValues(alpha: 0.5 * k),
              _Colors.glowMid.withValues(alpha: 0.45 * k),
              _Colors.glowEdge.withValues(alpha: 0.18 * k),
              _Colors.glowEdge.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 0.75, 1],
          ).createShader(rect),
      );
    }
  }

  /// A planet lit by the Sun, with Saturn's ring around it.
  void _paintPlanet(Canvas canvas, _Cam cam, int i, _V at, double alpha) {
    final planet = _planets[i];
    final depth = cam.depth(at);
    if (depth < 1) return;
    final o = cam.p(at);
    final r = planet.size * cam.scaleAt(at);
    final light = cam.screenDir((_V.zero - at).unit);
    if (!planet.ringed) {
      _ball(canvas, o, r, planet.color, light, alpha);
      return;
    }
    // The ring: RingGeometry in the planet's xy plane turned π / 2.3
    // about x, carried round by the orbit group.
    final turn = scene.planetTurns[i];
    _V ring(double radius, double angle) =>
        at +
        _V(
          radius * math.cos(angle),
          radius * math.sin(angle) * math.cos(_ringTilt),
          radius * math.sin(angle) * math.sin(_ringTilt),
        ).turnY(turn);
    final back = Path(), front = Path();
    for (var k = 0; k < _ringSegments; k++) {
      final a0 = k / _ringSegments * 2 * math.pi;
      final a1 = (k + 1) / _ringSegments * 2 * math.pi;
      final mid = ring(_ringOut, (a0 + a1) / 2);
      (cam.depth(mid) > depth ? back : front).addPolygon([
        cam.p(ring(_ringIn, a0)),
        cam.p(ring(_ringOut, a0)),
        cam.p(ring(_ringOut, a1)),
        cam.p(ring(_ringIn, a1)),
      ], true);
    }
    final paint = Paint()
      ..color = _Colors.saturnRing.withValues(
        alpha: _Colors.saturnRing.a * alpha,
      );
    canvas.drawPath(back, paint);
    _ball(canvas, o, r, planet.color, light, alpha);
    canvas.drawPath(front, paint);
  }

  /// A Lambert sphere lit from [light] (screen right, down, towards the
  /// viewer): its night side in the ambient light and the lit part (a
  /// crescent or gibbous phase) with a soft highlight.
  void _ball(
    Canvas canvas,
    Offset o,
    double r,
    Color color,
    (double, double, double) light,
    double alpha,
  ) {
    final (lx, ly, lz) = light;
    canvas.drawCircle(
      o,
      r,
      Paint()..color = _nightSide(color).withValues(alpha: alpha),
    );
    final side = math.sqrt(lx * lx + ly * ly);
    final lit = Path();
    final circle = Rect.fromCircle(center: Offset.zero, radius: r);
    if (side < 1e-3) {
      if (lz <= 0) return;
      lit.addOval(circle);
    } else {
      final ellipse = Rect.fromCenter(
        center: Offset.zero,
        width: 2 * r * lz.abs(),
        height: 2 * r,
      );
      lit
        ..moveTo(0, -r)
        ..arcTo(circle, -math.pi / 2, math.pi, false)
        ..arcTo(ellipse, math.pi / 2, lz >= 0 ? math.pi : -math.pi, false)
        ..close();
    }
    canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..rotate(side < 1e-3 ? 0 : math.atan2(ly, lx))
      ..drawPath(
        lit,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.55, 0),
            radius: 0.75,
            colors: [
              labShade(color, 0.3).withValues(alpha: alpha),
              color.withValues(alpha: alpha),
              labShade(color, -0.15).withValues(alpha: alpha),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(circle),
      )
      ..restore();
  }

  /// Level 2: the Orion arm turning about our Solar System's dot, the dot
  /// and its ring.
  void _paintArm(Canvas canvas, _Cam cam, double alpha) {
    final c = cache;
    _projectCloud(
      cam,
      c.cosmos.arm,
      c.cosmos.armBin,
      c.arm,
      turn: scene.armTurn,
      ox: _solarDotAt.x,
      oz: _solarDotAt.z,
    );
    final depth = cam.depth(_solarDotAt);
    if (depth < 1) return;
    c.arm.draw(
      canvas,
      c.points,
      opacity: _armOpacity * alpha,
      size: math.max(_minPoint, _armSize * _pointScale / depth),
    );
    _V ring(double radius, double angle) =>
        _solarDotAt + _V(radius * math.cos(angle), 0, radius * math.sin(angle));
    final back = Path(), front = Path();
    for (var k = 0; k < _ringSegments; k++) {
      final a0 = k / _ringSegments * 2 * math.pi;
      final a1 = (k + 1) / _ringSegments * 2 * math.pi;
      (cam.depth(ring(_solarDotRingOut, (a0 + a1) / 2)) > depth ? back : front)
          .addPolygon([
            cam.p(ring(_solarDotRingIn, a0)),
            cam.p(ring(_solarDotRingOut, a0)),
            cam.p(ring(_solarDotRingOut, a1)),
            cam.p(ring(_solarDotRingIn, a1)),
          ], true);
    }
    final ringPaint = Paint()
      ..color = _Colors.solarDotRing.withValues(alpha: alpha);
    canvas
      ..drawPath(back, ringPaint)
      ..drawCircle(
        cam.p(_solarDotAt),
        _solarDotR * cam.scaleAt(_solarDotAt),
        Paint()..color = _Colors.solarDot.withValues(alpha: alpha),
      )
      ..drawPath(front, ringPaint);
  }

  /// Level 3: the barred spiral galaxy turning and its bulge.
  void _paintGalaxy(Canvas canvas, _Cam cam, double alpha) {
    final c = cache;
    _projectCloud(
      cam,
      c.cosmos.galaxy,
      c.cosmos.galaxyBin,
      c.galaxy,
      turn: scene.galaxyTurn,
    );
    final depth = cam.depth(_V.zero);
    if (depth < 1) return;
    c.galaxy.draw(
      canvas,
      c.points,
      opacity: _galaxyOpacity * alpha,
      size: math.max(_minPoint, _galaxySize * _pointScale / depth),
    );
    canvas.drawCircle(
      cam.p(_V.zero),
      _bulgeSphereR * cam.scaleAt(_V.zero),
      Paint()
        ..color = _Colors.galaxyBulge.withValues(alpha: _bulgeOpacity * alpha),
    );
  }

  /// Level 4: the galaxies, nearer ones drawn larger, and the Milky Way at
  /// the centre.
  void _paintUniverse(Canvas canvas, _Cam cam, double alpha) {
    final c = cache;
    final cosmos = c.cosmos;
    final turn = scene.universeTurn;
    final cs = math.cos(turn), sn = math.sin(turn);
    final centres = cosmos.clusterCentres;
    for (var g = 0; g < _universeCount; g++) {
      final x = centres[3 * g], z = centres[3 * g + 2];
      final depth = cam.depth(
        _V(x * cs + z * sn, centres[3 * g + 1], -x * sn + z * cs),
      );
      var band = 0;
      while (band < _universeDepthBands.length &&
          depth > _universeDepthBands[band]) {
        band++;
      }
      c.clusterBand[g] = band;
    }
    final batch = c.universe..clear();
    final types = _Colors.galaxyTypes.length;
    final xyz = cosmos.universe;
    for (var i = 0; i < cosmos.universeOwner.length; i++) {
      final owner = cosmos.universeOwner[i];
      final px = xyz[3 * i], pz = xyz[3 * i + 2];
      final dx = px * cs + pz * sn - cam.ex;
      final dy = xyz[3 * i + 1] - cam.ey;
      final dz = -px * sn + pz * cs - cam.ez;
      final depth = dx * cam.fx + dy * cam.fy + dz * cam.fz;
      if (depth < 1) continue;
      final k = cam.k / depth;
      final sx = cam.cx + (dx * cam.rx + dy * cam.ry + dz * cam.rz) * k;
      final sy = cam.cy - (dx * cam.ux + dy * cam.uy + dz * cam.uz) * k;
      if (sx < _cull.left || sx > _cull.right) continue;
      if (sy < _cull.top || sy > _cull.bottom) continue;
      batch.add(
        c.clusterBand[owner] * types + cosmos.clusterType[owner],
        sx,
        sy,
      );
    }
    // Three.js sprites shrink with depth: size 3 at the bands' mid depths.
    const mids = [800.0, 1300.0, 1900.0];
    for (var band = 0; band < mids.length; band++) {
      batch.draw(
        canvas,
        c.points,
        opacity: _universeOpacity * alpha,
        size: math.max(_minPoint, _universeSize * _pointScale / mids[band]),
        from: band * types,
        to: (band + 1) * types,
      );
    }
    if (cam.depth(_V.zero) < 1) return;
    canvas.drawCircle(
      cam.p(_V.zero),
      math.max(1.5, _centreGalaxyR * cam.scaleAt(_V.zero)),
      Paint()..color = _Colors.centreGalaxy.withValues(alpha: alpha),
    );
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.cosmic-label`: a dark pill with a blue border, an icon and the
  /// text, with a pointer below; its bottom sits 16 px above [at]. It
  /// rises 10 px into place as it fades in.
  void _label(
    Canvas canvas,
    Offset at,
    String text,
    IconData icon,
    Color iconColor,
    Color textColor,
    FontWeight weight,
    double alpha,
  ) {
    if (alpha <= 0) return;
    final c = cache;
    final k = labelSize / 11;
    final tp = c.text(text, textColor, labelSize, weight);
    final ip = c.icon(icon, iconColor, labelSize * 1.2);
    final padX = 12 * k, padY = 5 * k, gap = 6 * k;
    final w = ip.width + gap + tp.width + 2 * padX;
    final h = math.max(ip.height, tp.height) + 2 * padY;
    final bottom = at.dy - _labelLift + (1 - alpha) * _labelRise;
    final rect = Rect.fromLTWH(at.dx - w / 2, bottom - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(10 * k));
    final fading = alpha < 1;
    if (fading) {
      canvas.saveLayer(
        rect.inflate(24 * k),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
    canvas
      ..drawRRect(
        rr.shift(Offset(0, 4 * k)),
        Paint()
          ..color = const Color(0x99000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * k),
      )
      ..drawPath(
        Path()
          ..moveTo(at.dx - 6 * k, bottom - 1)
          ..lineTo(at.dx + 6 * k, bottom - 1)
          ..lineTo(at.dx, bottom + 6 * k)
          ..close(),
        c.fill..color = _Colors.labelBg,
      )
      ..drawRRect(rr, c.fill..color = _Colors.labelBg)
      ..drawRRect(
        rr,
        c.stroke
          ..strokeWidth = 1
          ..color = _Colors.labelBorder,
      );
    ip.paint(canvas, Offset(rect.left + padX, rect.center.dy - ip.height / 2));
    tp.paint(
      canvas,
      Offset(rect.left + padX + ip.width + gap, rect.center.dy - tp.height / 2),
    );
    if (fading) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
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
