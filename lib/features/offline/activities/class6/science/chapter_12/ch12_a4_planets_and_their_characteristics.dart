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

/// Class 6 Science • Chapter 12 (Beyond Earth) • Activity 4
/// Planets and their Characteristics.
///
/// Native Flutter port of `Cl6S-Ch12-A4-Planets_and_their_Characteristics.html`
/// (Three.js r128 + Tween.js + canvas-confetti). The Three.js scene (a 60°
/// camera over the Sun, the eight planets with their orbit lines and the
/// background starfield) is redrawn in 2D by [_ScenePainter]. The planets
/// are lit spheres with painted surfaces (craters, oceans and clouds,
/// bands, storms) that turn as the HTML meshes do, and Saturn's ring is
/// drawn round its globe. The camera keeps each HTML viewing angle and
/// glides between the HTML positions, standing back as far as needed so the
/// step's orbits fit the free part of the canvas (the HTML cut off their
/// near arcs). The HTML overlays (the planet pool and the two tubs, the
/// orbit target chips and the pill tray, the Finish button, the beige clue
/// card with its magnifying glass, the Target Lineup and the Detective Case
/// File) are Flutter widgets over the canvas; every drag is a [Draggable]
/// and every tap-then-tap pair works as in the HTML.
///
/// Scenario 1 (Solar System Line-Up): drag each of the eight planets from
/// the Unsorted Planets Pool into the green Rocky Planets tub or the red Gas
/// Giants tub (or tap a planet, then a tub); a wrong tub shakes and the
/// planet snaps back. Then drag Mercury, Venus, Earth and Mars from the pill
/// tray onto Orbits 1–4 (the orbit chips at the top, or the glowing orbit
/// lines themselves) and Jupiter, Saturn, Uranus and Neptune onto Orbits
/// 5–8: each orbit turns green and its planet starts revolving round the
/// Sun. 'Finish' pulls the camera back over the whole Solar System, the two
/// groups parted by the asteroid zone, and opens the summary.
///
/// Scenario 2 (Planet Detective): Mars, Earth, Venus and Saturn stand in a
/// row. The beige clue card reads one clue at a time; drag the magnifying
/// glass onto the planet it describes (or onto its chip in the Target
/// Lineup, or tap the planet). The planet glows and the camera zooms in on
/// its surface; 'Record Findings & Next Clue' ticks the clue off in the
/// Detective Case File. After the fourth clue the summary opens and 'View
/// Final Success Trophies' shows 'Mastery Achieved!'.
///
/// Changes from the HTML: the planet labels sit above their planets (the
/// HTML's `localToWorld` doubled their positions) and are translated, and
/// the Sun has one; the camera always looks at its target while it glides
/// (the HTML moved it without turning it, as its OrbitControls were off);
/// in Scenario 2 the Sun is not drawn (at the origin it swallowed half of
/// Earth at x = −7) and the row is lit from the front; a pill also goes onto
/// an orbit line it is dropped on (the HUD says so; the HTML took only the
/// chips); the lens must land on a planet or its chip (the HTML's touch
/// fallback counted a drop anywhere on the canvas as the right planet); the
/// closeup card stands beside the zoomed planet instead of over it. Added:
/// the planet surfaces and atmospheres, the asteroid zone of step 4, a facts
/// card for a tapped planet and facts in the closeup card (the HTML's unused
/// `planetDetailsMulti` and fact labels), 'Next Scenario' in the Scenario 1
/// summary, 'Observe Conclusion' once Scenario 2 is solved, and on short
/// screens a Case File that folds to ticks while a planet is zoomed in on.
class Ch12A4PlanetsAndTheirCharacteristicsPage extends StatefulWidget {
  const Ch12A4PlanetsAndTheirCharacteristicsPage({super.key});

  @override
  State<Ch12A4PlanetsAndTheirCharacteristicsPage> createState() =>
      _PlanetsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises four Web Audio tones in `playSound(type)`; each maps to the
/// closest bundled file: `click` (a planet, a pill or the lens picked, a
/// planet tapped on the canvas) → click (`science/click.mp3`); `pop` (Enter
/// Lab, a planet in the right tub or on the right orbit, a planet verified,
/// the next clue) → pop (`science/click.mp3`); `error` / `buzz` (the wrong
/// tub, orbit or planet) → wrong (`science/error.mp3`); `success` (Finish,
/// the last clue) → success (`math/success.mp3`). The shell plays toggle
/// (`science/dropdown.mp3`: sidebar), correct (`math/success.mp3`: its own
/// positive toasts; this lab's toasts are silent, as the HTML plays the
/// action's tone instead), scenario (`science/page_open.mp3`) and curtain
/// (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML `click`: a planet, a pill or the lens picked; a planet tapped.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast ('Scenario Complete!').
  correct('audio/class6/math/success.mp3'),

  /// HTML `error` / `buzz`: the wrong tub, orbit or planet.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: Finish and the last clue (the summary popups).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: a planet in the right tub or on the right orbit, a planet
  /// verified, the next clue.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // tailwind `zsl.dark`
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green600 = Color(0xFF16A34A);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose700 = Color(0xFFBE123C);
  static const Color rose900 = Color(0xFF881337);
  static const Color rose950 = Color(0xFF4C0519);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color blue600 = Color(0xFF2563EB);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background `bg-[#03071e]`, in both themes.
  static const Color night = Color(0xFF03071E);

  /// Background starfield: `PointsMaterial` 0x94a3b8, opacity 0.6.
  static const Color star = Color(0x9994A3B8);

  /// The Sun: `MeshBasicMaterial` 0xf59e0b, and its glow (added).
  static const Color sun = amber500;
  static const Color sunGlow = Color(0xFFFBBF24);

  /// AmbientLight 0x334155 at 0.6: the night side of the planets.
  static const Color ambient = Color(0xFF141A24);

  /// Orbit lines (`LineBasicMaterial`): 0x475569 at 0.4 when made, 0x6366f1
  /// at 0.8 for the step's orbits, 0x334155 at 0.3 for the others, 0x10b981
  /// at 0.8 once a planet is on it (0.6 for all in step 4).
  static const Color orbitIdle = slate700;
  static const Color orbitTarget = indigo500;
  static const Color orbitDone = emerald500;

  /// Saturn's ring (`MeshLambertMaterial` 0xfde047, opacity 0.7).
  static const Color ring = yellow300;

  /// The asteroid zone between Mars and Jupiter (added, step 4).
  static const Color asteroid = Color(0xFF8A8F98);

  /// `.planet-label`: rgba(15, 23, 42, 0.85) with a rgba(99, 102, 241, 0.5)
  /// border and white text.
  static const Color labelBg = Color(0xD90F172A);
  static const Color labelBorder = Color(0x806366F1);

  /// `.clue-bubble`: linear-gradient(135deg, #fef08a, #fde047) in the dark
  /// theme, #fef9c3 → #fef08a in the light one, with a #ca8a04 border.
  static const Color clueBorder = yellow600;

  /// `.zoom-beam-popup`: radial-gradient(rgba(30, 41, 59, 0.95),
  /// rgba(15, 23, 42, 0.98)), #6366f1 border.
  static const Color beamInner = Color(0xF21E293B);
  static const Color beamOuter = Color(0xFA0F172A);

  /// Floating panels (`glass-panel bg-slate-900/95`).
  static const Color panel = Color(0xF20F172A);

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
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// canvas is the night sky in both themes, as in the HTML.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800 step cards
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.night, // #canvas-wrapper bg-[#03071e]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500, // indigo-500 accents
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A), // toast bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // subtitle text-indigo-300/80
    curtainIcon: _Colors.indigo400,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x806366F1),
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
    canvasBg: _Colors.night,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo600,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.indigo400,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.slate300,
    readoutBg: _Colors.slate950,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font size (`--sidebar-font-size: 15px`), adjustable 12–22 px.
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
// Copied from the HTML `i18n` table, `ScenariosData` and `planetDetailsMulti`
// (Telugu dropped). The shell-generic texts (Enter Lab, Select Scenario,
// Mission Objective, Current Task, Step, Success!, the settings and canvas
// tool names and the footer) come from the shell's `kLabCommonStrings`.
// "Click" became "Tap" (क्लिक → टैप). The summaries keep their bold
// heading before a '|' and mark the HTML's <strong> words with '*'. The
// feedback toasts and messages written as literals in the HTML script are
// marked "HTML literal"; keys marked "Added." are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Planets and their Characteristics',
    'app_subtitle': 'Class 6 . Beyond Earth',
    // Sidebar accordion and popups.
    'concept_exp': 'Observation Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete_desc':
        'You classified all 8 planets into Inner Rocky and Outer Gas Giants, placed them precisely in their orbits around the Sun, and identified planetary wonders like Mars and Saturn like a true Planet Detective!',
    'btn_conclude': 'Observe Conclusion',
    // The HTML's stage headings (its top instruction boxes were removed);
    // read out by screen readers on the tubs and the Finish button.
    'stage_1_step_1_label': 'Scenario 1 • Step 1: Classify Planets',
    'stage_1_step_1_desc':
        "Drag and drop each floating planet into the 'Rocky Planets' green tub or the 'Gas Giants' red tub.",
    'stage_1_step_4_label': 'Scenario 1 • Step 4: Finish & View',
    'stage_1_step_4_desc':
        "All 8 planets are arranged in sequence! Tap the 'Finish' button below to confirm your line-up.",
    // Scenario 1 overlays.
    'unsorted_planets': 'Unsorted Planets Pool',
    'drag_or_click_hint': '💡 Drag over a tub or Tap planet + Tap tub',
    'basket_rocky': 'Rocky Planets',
    'basket_rocky_sub': 'Small, dense, solid crust',
    'basket_gas': 'Gas Giants',
    'basket_gas_sub': 'Large, swirling gas & rings',
    'orbit_drag_hint': 'Drag onto orbit target or Tap planet then Tap orbit #',
    'btn_finish_solar': 'Finish',
    'drop_inner': 'Drop Inner Planets (Mercury to Mars) inside!',
    'drop_outer': 'Drop Outer Planets (Jupiter to Neptune) inside!',
    'drop_badge': 'Drop',
    'snap_badge': 'snap-back',
    // Scenario 2 overlays.
    'drag_lens':
        '👉 Drag & Drop Magnifying Glass onto the target planet below!',
    'surf_label': 'Surface / Atmosphere:',
    'dist_label': 'Dist from Sun:',
    'feat_label': 'Key Feature:',
    'suspect_planets': 'Target Lineup',
    'clue_mars': 'Red Planet clue',
    'clue_earth': 'Blue Planet clue',
    'clue_venus': 'Venus clue (Brightest)',
    'clue_saturn': 'Neptune/Saturn ring clue',
    'locked': 'Locked',
    'verified': '{p} Verified!',
    'magnifying_active':
        '🔎 Magnifying Glass active! Now tap directly on the matching planet below!',
    // Planet names (HTML `planet_*`).
    'planet_sun': 'The Sun',
    'planet_mercury': 'Mercury',
    'planet_venus': 'Venus',
    'planet_earth': 'Earth',
    'planet_mars': 'Mars',
    'planet_jupiter': 'Jupiter',
    'planet_saturn': 'Saturn',
    'planet_uranus': 'Uranus',
    'planet_neptune': 'Neptune',
    // ScenariosData[en][1].
    'sc1_title': 'Scenario 1: Solar System Line-Up',
    's1_obj':
        'To correctly classify the eight planets as either inner rocky planets or outer gas giants, and then arrange them in the correct order from the Sun.',
    's1_h1':
        "Step 1: DRAG & DROP each planet into the 'Rocky Planets' green tub or 'Gas Giants' red tub.",
    's1_h2':
        'Step 2: DRAG each inner Rocky planet from the bottom pill tray onto its glowing orbit line (Orbits 1–4).',
    's1_h3':
        'Step 3: DRAG each outer Gas Giant from the bottom pill tray onto its glowing orbit line (Orbits 5–8).',
    's1_h4':
        "Step 4: All planets are revolving in order! Tap 'Finish' button to view the completed system.",
    's1_t1_c': 'Sort Planets by Appearance & Composition',
    's1_t1_a':
        "DRAG each floating planet from the left space pool into the 'Rocky Planets' green tub or 'Gas Giants' red tub.",
    's1_t1_o':
        "All four small solid planets (Mercury, Venus, Earth, Mars) go into 'Rocky Planets'. All four large swirly planets (Jupiter, Saturn, Uranus, Neptune) fit inside 'Gas Giants' with a satisfying pop!",
    's1_t2_c': 'Arrange Inner Rocky Planets (Orbits 1 to 4)',
    's1_t2_a':
        "DRAG Mercury, Venus, Earth, and Mars from the bottom 'Rocky Planets' pill tray onto the first four orbital paths around the Sun.",
    's1_t2_o':
        'When dropped onto the correct orbital path, the orbit lights up brightly and the planet locks on and begins slowly revolving around the Sun!',
    's1_t3_c': 'Arrange Outer Gas Giants (Orbits 5 to 8)',
    's1_t3_a':
        "DRAG Jupiter, Saturn, Uranus, and Neptune from the bottom 'Gas Giants' pill tray onto the 5th, 6th, 7th, and 8th orbital paths around the Sun.",
    's1_t3_o':
        'As each gas giant is placed correctly on its orbit, it locks into path and starts revolving with majestic ring and storm details.',
    's1_t4_c': 'Complete Solar System Sequence',
    's1_t4_a': "TAP on the green 'Finish' button at the bottom right.",
    's1_t4_o':
        'The view displays our complete Solar System with all 8 planets revolving in two distinct groups divided by the asteroid zone!',
    's1_summary':
        'Scenario 1 Complete!|You sorted all 8 planets into two distinct groups: the four inner *Rocky Planets* (Mercury, Venus, Earth, Mars) and the four outer *Gas & Ice Giants* (Jupiter, Saturn, Uranus, Neptune). As described on textbook page 241, their distance from the Sun determines their composition and size!',
    // ScenariosData[en][2].
    'sc2_title': 'Scenario 2: Planet Detective',
    's2_obj':
        'To identify specific planets (Mars, Earth, Venus, Saturn) based on their unique visual characteristics as described in the textbook.',
    's2_h1':
        "Step 1: Clue: 'Called the Red Planet because of reddish soil.' DRAG the magnifying glass onto Mars.",
    's2_h2':
        "Step 2: Clue: 'Looks blue from space because of water (Blue Planet).' DRAG the magnifying glass onto Earth.",
    's2_h3':
        "Step 3: Clue: 'Brightest object after Sun & Moon (Morning/Evening Star).' DRAG the magnifying glass onto Venus.",
    's2_h4':
        "Step 4: Clue: 'Giant gaseous planet known for large, flat rings.' DRAG the magnifying glass onto Saturn.",
    's2_t1_c': 'Identify the Red Planet (Mars)',
    's2_t1_a':
        "Read the beige clue bubble: 'I am called the Red Planet because my soil is reddish.' DRAG the blue magnifying glass and DROP it onto Mars.",
    's2_t1_o':
        'Mars glows warmly and the closeup projection reveals its reddish iron-oxide cratered desert surface!',
    's2_t2_c': 'Identify the Blue Planet (Earth)',
    's2_t2_a':
        "Read the beige clue bubble: 'From space, I look blue because of all my water. I am called the Blue Planet.' DRAG the magnifying glass onto Earth.",
    's2_t2_o':
        'Earth glows softly and the closeup projection showcases vibrant liquid blue oceans covered by swirling white clouds.',
    's2_t3_c': 'Identify the Bright Star (Venus)',
    's2_t3_a':
        "Read the beige clue bubble: 'I am the brightest object after the Sun and Moon (Morning/Evening Star).' DRAG the magnifying glass onto Venus.",
    's2_t3_o':
        'Venus glows intensely with bright white-yellow light, visually representing how its thick clouds reflect intense sunlight!',
    's2_t4_c': 'Identify the Ringed Giant (Saturn)',
    's2_t4_a':
        "Read the beige clue bubble: 'I am a giant gaseous planet known for the large, flat rings around me.' DRAG the magnifying glass onto Saturn.",
    's2_t4_o':
        "Saturn's ring system glows as the right-side Scorecard Drawer slides in showing all 4 solved detective clues!",
    's2_summary':
        'Scenario 2 Complete!|You solved all 4 planetary clues like a master detective! You discovered why Mars is red (iron-oxide soil), why Earth is blue (oceans of water), why Venus shines so brightly (cloud reflection), and why Saturn is famed for its flat, majestic rings!',
    // planetDetailsMulti[en]: type, surface, distance, feature, description.
    'pd_mercury_type': 'Terrestrial (Rocky)',
    'pd_mercury_surf': 'Heavily Cratered Rock',
    'pd_mercury_dist': '0.39 AU from Sun',
    'pd_mercury_feat': 'Extreme Temp (-180°C to 430°C)',
    'pd_mercury_desc':
        'Smallest planet and closest to the Sun. Has no atmosphere to retain heat, leading to wild temperature swings.',
    'pd_venus_type': 'Terrestrial (Rocky)',
    'pd_venus_surf': 'Volcanic Crust & Toxic Clouds',
    'pd_venus_dist': '0.72 AU from Sun',
    'pd_venus_feat': 'Hottest Planet (470°C)',
    'pd_venus_desc':
        'Enshrouded in a thick carbon dioxide atmosphere that traps heat via runaway greenhouse effect.',
    'pd_earth_type': 'Terrestrial (Rocky)',
    'pd_earth_surf': '71% Liquid Oceans & Crust',
    'pd_earth_dist': '1.00 AU from Sun',
    'pd_earth_feat': 'Supports Abundant Life',
    'pd_earth_desc':
        'Our home world! Exactly situated in the habitable Goldilocks zone with breathable oxygen atmosphere.',
    'pd_mars_type': 'Terrestrial (Rocky)',
    'pd_mars_surf': 'Red Iron-Oxide Desert & Canyons',
    'pd_mars_dist': '1.52 AU from Sun',
    'pd_mars_feat': 'Olympus Mons & Ice Caps',
    'pd_mars_desc':
        'The Red Planet. Known for polar ice caps, ancient dried riverbeds, and its distinct reddish soil.',
    'pd_jupiter_type': 'Gas Giant',
    'pd_jupiter_surf': 'Dense Swirling Gas Clouds',
    'pd_jupiter_dist': '5.20 AU from Sun',
    'pd_jupiter_feat': 'The Great Red Spot Storm',
    'pd_jupiter_desc':
        'The largest planet in our Solar System! More massive than all other planets combined, with swirling bands of gas.',
    'pd_saturn_type': 'Gas Giant',
    'pd_saturn_surf': 'Banded Hydrogen Envelope',
    'pd_saturn_dist': '9.58 AU from Sun',
    'pd_saturn_feat': 'Majestic Ring System',
    'pd_saturn_desc':
        'Famed for its complex and dazzling system of icy, flat rings stretching hundreds of thousands of kilometers.',
    'pd_uranus_type': 'Ice Giant',
    'pd_uranus_surf': 'Icy Methane-Ammonia Mantle',
    'pd_uranus_dist': '19.2 AU from Sun',
    'pd_uranus_feat': 'Tilted on its Side (98° Axis)',
    'pd_uranus_desc':
        'Rotates sideways like a rolling barrel. Its atmospheric methane absorbs red light, giving it a cyan glow.',
    'pd_neptune_type': 'Ice Giant',
    'pd_neptune_surf': 'Deep Frozen Methane Ocean',
    'pd_neptune_dist': '30.1 AU from Sun',
    'pd_neptune_feat': 'Supersonic 2,100 km/h Winds',
    'pd_neptune_desc':
        'The outermost major planet. A dark, frigid blue world whipped by the fastest wind storms across our Solar System.',
    // HTML literals: the pool, tray and orbit chips, the toasts, the
    // summary message and the clue card.
    'sort_done':
        '🎉 All 8 planets classified correctly! Advancing to Orbit Placement...',
    'toast_sort_ok': '✅ Correct! {p} goes into the {tub} tub!',
    'tub_rocky': 'green Rocky Planets',
    'tub_gas': 'red Gas Giants',
    'toast_sort_bad':
        '❌ Snap back! {p} does not belong in {tub}. Look closely at its size!',
    'orbit_n': 'Orbit {n}',
    'tray_done': '🎉 All 4 placed! Continuing...',
    'toast_orbit_hint': "Orbit #{n}: Drag or Tap '{p}' onto this slot!",
    'toast_orbit_ok':
        '🎉 Spot on! {p} locked into Orbit #{n} and is now revolving!',
    'toast_orbit_bad': '❌ Not quite! {p} belongs on Orbit #{m}, not #{n}.',
    // 'right panel' → 'left panel': the sidebar is on the left here.
    'next_msg_s1':
        '✨ Scenario 1 Complete! Tap on *Next Scenario* (Scenario 2) from the left panel to proceed.',
    'clue_badge': 'Planet Detective Clue {n} of 4',
    'toast_verified': '🔍 Spot on! You verified {p} under the magnifying lens!',
    'toast_wrong_planet':
        "❌ That is '{p}'. Check the beige clue card and try dragging the lens again!",
    's2_popup_title': 'Planet Detective Mastery!',
    'btn_trophies': 'View Final Success Trophies',
    'btn_record': 'Record Findings & Next Clue',
    'case_file': 'Detective Case File',
    'lens_tip': 'Drag me onto Mars, Earth, Venus, or Saturn below!',
    // Added: screen-reader names of the scene and the lens.
    'scene_s1': 'The Sun and the orbits of the eight planets in a starry sky',
    'scene_s2': 'Mars, Earth, Venus and Saturn in a row in a starry sky',
    'lens_label': 'Magnifying Glass',
  },
  'hi': {
    'app_title': 'ग्रह और उनकी विशेषताएं',
    'app_subtitle': 'कक्षा 6 . पृथ्वी के पार (Beyond Earth)',
    'concept_exp': 'अवलोकन चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete_desc':
        'आपने सभी 8 ग्रहों को भीतरी चट्टानी और बाहरी गैस विशालकाय समूहों में वर्गीकृत किया, उन्हें सूर्य के चारों ओर सही कक्षाओं में व्यवस्थित किया और मंगल व शनि जैसे ग्रहों की पहचान की!',
    'btn_conclude': 'निष्कर्ष देखें',
    'stage_1_step_1_label': 'परिदृश्य 1 • चरण 1: ग्रहों का वर्गीकरण',
    'stage_1_step_1_desc':
        "बाईं ओर तैरते ग्रहों को खींचकर हरी 'चट्टानी ग्रह' टोकरी या लाल 'गैस जायंट्स' टोकरी में डालें।",
    'stage_1_step_4_label': 'परिदृश्य 1 • चरण 4: संपूर्ण सौरमंडल',
    'stage_1_step_4_desc':
        "सभी 8 ग्रह अपनी सही कक्षाओं में हैं! पूरा सौरमंडल देखने के लिए नीचे दिए गए 'पूर्ण करें' बटन पर टैप करें।",
    'unsorted_planets': 'अवर्गीकृत ग्रह समूह',
    'drag_or_click_hint':
        '💡 खींचकर टोकरी में डालें या ग्रह पर टैप करें फिर टोकरी पर टैप करें',
    'basket_rocky': 'चट्टानी ग्रह',
    'basket_rocky_sub': 'छोटे, सघन, ठोस सतह',
    'basket_gas': 'गैस विशालकाय ग्रह',
    'basket_gas_sub': 'विशाल, तूफानी वातावरण और वलय',
    'orbit_drag_hint':
        'कक्षा के लक्ष्य पर खींचें या ग्रह पर टैप करें फिर कक्षा पर टैप करें',
    'btn_finish_solar': 'पूर्ण करें',
    'drop_inner': 'भीतरी ग्रहों (बुध से मंगल) को यहाँ डालें!',
    'drop_outer': 'बाहरी ग्रहों (बृहस्पति से वरुण) को यहाँ डालें!',
    'drop_badge': 'डालें',
    'snap_badge': 'वापस भेजें',
    'drag_lens':
        '👉 ऊपर दिए गए मैग्नीफाइंग ग्लास को खींचकर नीचे सही ग्रह पर छोड़ें!',
    'surf_label': 'सतह / वायुमंडल:',
    'dist_label': 'सूर्य से दूरी:',
    'feat_label': 'मुख्य विशेषता:',
    'suspect_planets': 'ग्रहों की पंक्ति',
    'clue_mars': 'लाल ग्रह का सुराग',
    'clue_earth': 'नीले ग्रह का सुराग',
    'clue_venus': 'शुक्र का सुराग (सबसे चमकीला)',
    'clue_saturn': 'शनि के वलयों का सुराग',
    'locked': 'लॉक किया हुआ',
    'verified': '{p} सत्यापित!',
    // HTML literal of the lens toast (its i18n entry words it a little
    // differently).
    'magnifying_active':
        '🔎 आवर्धक लेंस सक्रिय! अब नीचे दिए गए सही ग्रह पर सीधे टैप करें!',
    'planet_sun': 'सूर्य',
    'planet_mercury': 'बुध',
    'planet_venus': 'शुक्र',
    'planet_earth': 'पृथ्वी',
    'planet_mars': 'मंगल',
    'planet_jupiter': 'बृहस्पति',
    'planet_saturn': 'शनि',
    'planet_uranus': 'अरुण (यूरेनस)',
    'planet_neptune': 'वरुण (नेपच्यून)',
    'sc1_title': 'परिदृश्य 1: सौरमंडल का क्रम',
    's1_obj':
        'आठों ग्रहों को भीतरी चट्टानी ग्रह या बाहरी गैस विशालकाय ग्रहों में वर्गीकृत करना, और उन्हें सूर्य से सही क्रम में व्यवस्थित करना।',
    's1_h1':
        "चरण 1: प्रत्येक ग्रह को खींचकर हरी 'चट्टानी ग्रह' टोकरी या लाल 'गैस विशालकाय ग्रह' टोकरी में डालें।",
    's1_h2':
        'चरण 2: 4 चट्टानी ग्रहों (बुध, शुक्र, पृथ्वी, मंगल) को नीचे की ट्रे से सूर्य के निकट 1 से 4 वीं कक्षा में रखें।',
    's1_h3':
        'चरण 3: 4 गैस विशालकाय ग्रहों (बृहस्पति, शनि, अरुण, वरुण) को नीचे की ट्रे से 5 से 8 वीं कक्षा में रखें।',
    's1_h4':
        "चरण 4: सभी ग्रह सही कक्षाओं में चक्कर लगा रहे हैं! नीचे दाएं 'पूर्ण करें' बटन पर टैप करें।",
    's1_t1_c': 'बनावट के आधार पर ग्रहों का वर्गीकरण',
    's1_t1_a':
        "बाईं ओर के अंतरिक्ष समूह से प्रत्येक ग्रह को खींचकर हरी 'चट्टानी ग्रह' या लाल 'गैस विशालकाय ग्रह' टोकरी में डालें।",
    's1_t1_o':
        'चारों छोटे ठोस ग्रह (बुध, शुक्र, पृथ्वी, मंगल) हरी टोकरी में तथा चारों विशाल ग्रह (बृहस्पति, शनि, अरुण, वरुण) लाल टोकरी में आ जाते हैं!',
    's1_t2_c': 'भीतरी चट्टानी ग्रह (कक्षा 1 से 4)',
    's1_t2_a':
        'बुध, शुक्र, पृथ्वी और मंगल को नीचे की ट्रे से सूर्य के नीचे दी गई पहली चार कक्षाओं में सही क्रम में खींचकर छोड़ें।',
    's1_t2_o':
        'सही कक्षा में छोड़ने पर कक्षा चमक उठती है और ग्रह अपने पथ पर सूर्य की परिक्रमा करने लगता है!',
    's1_t3_c': 'बाहरी गैस विशालकाय ग्रह (कक्षा 5 से 8)',
    's1_t3_a':
        'बृहस्पति, शनि, अरुण और वरुण को नीचे की ट्रे से सूर्य के चारों ओर 5वें, 6ठें, 7वें और 8वें कक्षीय पथ पर रखें।',
    's1_t3_o':
        'जैसे ही प्रत्येक बाहरी ग्रह को सही कक्षा में रखा जाता है, वह अपने वलयों और तूफानों के साथ परिक्रमा शुरू कर देता है।',
    's1_t4_c': 'संपूर्ण सौरमंडल का दृश्य',
    's1_t4_a': "नीचे दाएं दिए गए हरे 'पूर्ण करें' बटन पर टैप करें।",
    's1_t4_o':
        'कैमरा संपूर्ण सौरमंडल के सभी 8 ग्रह अपनी कक्षाओं में एक साथ चक्कर लगाते हुए दिखाता है!',
    's1_summary':
        'परिदृश्य 1 पूर्ण!|आपने सभी 8 ग्रहों को दो समूहों में वर्गीकृत किया: 4 भीतरी *चट्टानी ग्रह* (बुध, शुक्र, पृथ्वी, मंगल) और 4 बाहरी *गैस विशालकाय ग्रह* (बृहस्पति, शनि, अरुण, वरुण)। पाठ्यपुस्तक के पृष्ठ 241 के अनुसार सूर्य से उनकी दूरी ही उनकी संरचना तय करती है!',
    'sc2_title': 'परिदृश्य 2: ग्रह जासूस',
    's2_obj':
        'पाठ्यपुस्तक में दी गई अनूठी विशेषताओं के आधार पर विशिष्ट ग्रहों (मंगल, पृथ्वी, शुक्र, शनि) की पहचान करना।',
    's2_h1':
        "चरण 1: सुराग: 'लाल मिट्टी के कारण लाल ग्रह कहलाता हूँ।' मैग्नीफाइंग ग्लास को मंगल ग्रह पर छोड़ें।",
    's2_h2':
        "चरण 2: सुराग: 'पानी के कारण अंतरिक्ष से नीला दिखता हूँ (नीला ग्रह)।' मैग्नीफाइंग ग्लास को पृथ्वी पर छोड़ें।",
    's2_h3':
        "चरण 3: सुराग: 'सूर्य व चंद्रमा के बाद सबसे चमकीला (भोर/सांझ का तारा)।' मैग्नीफाइंग ग्लास को शुक्र पर छोड़ें।",
    's2_h4':
        "चरण 4: सुराग: 'अपने चारों ओर विशाल चपटे वलयों के लिए प्रसिद्ध।' मैग्नीफाइंग ग्लास को शनि पर छोड़ें।",
    's2_t1_c': 'लाल ग्रह की पहचान (मंगल)',
    's2_t1_a':
        "बेज सुराग बबल पढ़ें: 'मेरी मिट्टी लाल है इसलिए मुझे लाल ग्रह कहा जाता है।' मैग्नीफाइंग ग्लास को खींचकर मंगल पर छोड़ें।",
    's2_t1_o':
        'मंगल ग्रह चमक उठता है और क्लोज़अप उसकी लाल आयरन-ऑक्साइड मिट्टी और गड्ढों वाली सतह को दिखाता है!',
    's2_t2_c': 'नीले ग्रह की पहचान (पृथ्वी)',
    's2_t2_a':
        "सुराग बबल पढ़ें: 'पानी की उपस्थिति के कारण मैं अंतरिक्ष से नीला दिखता हूँ।' मैग्नीफाइंग ग्लास को पृथ्वी पर छोड़ें।",
    's2_t2_o':
        'पृथ्वी चमक उठती है और क्लोज़अप नीले महासागरों और सफेद बादलों को दिखाता है।',
    's2_t3_c': 'चमकीले तारे की पहचान (शुक्र)',
    's2_t3_a':
        "सुराग बबल पढ़ें: 'मैं सूर्य और चंद्रमा के बाद आकाश का सबसे चमकीला पिंड हूँ।' मैग्नीफाइंग ग्लास को शुक्र पर छोड़ें।",
    's2_t3_o':
        'शुक्र ग्रह अत्यधिक चमकीले पीले-सफेद प्रकाश के साथ चमकता है, जो उसके घने बादलों द्वारा सूर्य के प्रकाश के परावर्तन को दर्शाता है!',
    's2_t4_c': 'वलयदार ग्रह की पहचान (शनि)',
    's2_t4_a':
        "सुराग बबल पढ़ें: 'मैं एक विशाल गैस का ग्रह हूँ जो अपने चारों ओर बड़े चपटे वलयों के लिए प्रसिद्ध है।' मैग्नीफाइंग ग्लास को शनि पर छोड़ें।",
    's2_t4_o':
        'शनि ग्रह और उसके वलय चमक उठते हैं और दाईं ओर का डिटेक्टिव स्कोरकार्ड सभी 4 हल किए गए सुराग दिखाता है!',
    's2_summary':
        'परिदृश्य 2 पूर्ण!|आपने एक कुशल जासूस की तरह चारों सुरागों को हल किया! आपने जाना कि मंगल लाल क्यों है (आयरन-ऑक्साइड), पृथ्वी नीली क्यों है (जल), शुक्र इतना क्यों चमकता है (बादलों का परावर्तन) और शनि अपने सुंदर वलयों के लिए क्यों प्रसिद्ध है!',
    'pd_mercury_type': 'चट्टानी ग्रह',
    'pd_mercury_surf': 'गड्ढों से भरी चट्टानी सतह',
    'pd_mercury_dist': 'सूर्य से 0.39 AU',
    'pd_mercury_feat': 'अत्यधिक तापमान (-180°C से 430°C)',
    'pd_mercury_desc':
        'सबसे छोटा और सूर्य के सबसे निकट का ग्रह। इसमें ऊष्मा रोकने के लिए कोई वायुमंडल नहीं है, जिससे तापमान में भारी बदलाव होता है।',
    'pd_venus_type': 'चट्टानी ग्रह',
    'pd_venus_surf': 'ज्वालामुखी पर्पटी और जहरीले बादल',
    'pd_venus_dist': 'सूर्य से 0.72 AU',
    'pd_venus_feat': 'सबसे गर्म ग्रह (470°C)',
    'pd_venus_desc':
        'घने कार्बन डाइऑक्साइड वायुमंडल से घिरा हुआ है जो ग्रीनहाउस प्रभाव के माध्यम से अत्यधिक गर्मी पैदा करता है।',
    'pd_earth_type': 'चट्टानी ग्रह',
    'pd_earth_surf': '71% तरल महासागर और पर्पटी',
    'pd_earth_dist': 'सूर्य से 1.00 AU',
    'pd_earth_feat': 'जीवन का एकमात्र आश्रय',
    'pd_earth_desc':
        'हमारी मातृभूमि! सांस लेने योग्य ऑक्सीजन वायुमंडल के साथ रहने योग्य गोल्डीलॉक्स क्षेत्र में स्थित है।',
    'pd_mars_type': 'चट्टानी ग्रह',
    'pd_mars_surf': 'लाल आयरन-ऑक्साइड रेगिस्तान व घाटियाँ',
    'pd_mars_dist': 'सूर्य से 1.52 AU',
    'pd_mars_feat': 'ओलंपस मॉन्स व बर्फीली चोटियाँ',
    'pd_mars_desc':
        'लाल ग्रह। ध्रुवीय बर्फीली चोटियों, प्राचीन सूखी नदी के रास्तों और अपनी विशिष्ट लाल मिट्टी के लिए जाना जाता है।',
    'pd_jupiter_type': 'गैस विशालकाय ग्रह',
    'pd_jupiter_surf': 'घने घूमते हुए गैस के बादल',
    'pd_jupiter_dist': 'सूर्य से 5.20 AU',
    'pd_jupiter_feat': 'विशाल लाल तूफानी धब्बा',
    'pd_jupiter_desc':
        'हमारे सौरमंडल का सबसे बड़ा ग्रह! अन्य सभी ग्रहों के संयुक्त द्रव्यमान से भी अधिक भारी, जिसमें गैस की घूमती हुई पट्टियाँ हैं।',
    'pd_saturn_type': 'गैस विशालकाय ग्रह',
    'pd_saturn_surf': 'हाइड्रोजन गैस का आवरण',
    'pd_saturn_dist': 'सूर्य से 9.58 AU',
    'pd_saturn_feat': 'भव्य वलय प्रणाली',
    'pd_saturn_desc':
        'लाखों किलोमीटर तक फैले बर्फीले और चपटे वलयों की अपनी जटिल और चमकदार प्रणाली के लिए प्रसिद्ध है।',
    'pd_uranus_type': 'बर्फीला विशालकाय ग्रह',
    'pd_uranus_surf': 'बर्फीला मीथेन-अमोनिया आवरण',
    'pd_uranus_dist': 'सूर्य से 19.2 AU',
    'pd_uranus_feat': 'एक करवट झुका हुआ (98° अक्ष)',
    'pd_uranus_desc':
        'लुढ़कते हुए बैरल की तरह करवट पर घूमता है। वायुमंडलीय मीथेन लाल प्रकाश को अवशोषित करती है, जिससे यह नीला-हरा चमकता है।',
    'pd_neptune_type': 'बर्फीला विशालकाय ग्रह',
    'pd_neptune_surf': 'गहरा जमा हुआ मीथेन महासागर',
    'pd_neptune_dist': 'सूर्य से 30.1 AU',
    'pd_neptune_feat': '2,100 किमी/घंटा की सुपरसोनिक हवाएँ',
    'pd_neptune_desc':
        'सबसे बाहरी प्रमुख ग्रह। हमारे सौरमंडल में सबसे तेज़ तूफानी हवाओं से घिरा एक गहरा, अत्यधिक ठंडा नीला ग्रह।',
    'sort_done':
        '🎉 सभी 8 ग्रह सही ढंग से वर्गीकृत! कक्षीय निर्धारण की ओर बढ़ते हुए...',
    'toast_sort_ok': '✅ सही! {p} सही टोकरी में आ गया है!',
    'toast_sort_bad': '❌ वापस! {p} सही टोकरी में नहीं है। उसके आकार को देखें!',
    'orbit_n': 'कक्षा {n}',
    'tray_done': '🎉 सभी 4 सही कक्षा में! आगे बढ़ रहे हैं...',
    'toast_orbit_hint': "कक्षा #{n}: '{p}' को यहाँ खींचकर या टैप करके छोड़ें!",
    'toast_orbit_ok': '🎉 बिल्कुल सही! {p} कक्षा #{n} में परिक्रमा कर रहा है!',
    'toast_orbit_bad': '❌ सही नहीं! {p} की कक्षा #{m} है, #{n} नहीं।',
    'next_msg_s1':
        '✨ परिदृश्य 1 पूर्ण! आगे बढ़ने के लिए बाएं पैनल से *अगला परिदृश्य* (परिदृश्य 2) चुनें।',
    'clue_badge': 'ग्रह जासूस सुराग {n} / 4',
    'toast_verified':
        '🔍 बिल्कुल सही! आपने आवर्धक लेंस के नीचे {p} की पहचान की!',
    'toast_wrong_planet':
        "❌ वह '{p}' है। सुराग कार्ड की जाँच करें और लेंस को फिर से खींचने का प्रयास करें!",
    's2_popup_title': 'ग्रह जासूस महारत!',
    'btn_trophies': 'अंतिम सफलता ट्रॉफी देखें',
    // Added: Hindi for the HTML's English-only literals.
    'btn_record': 'निष्कर्ष दर्ज करें और अगला सुराग',
    'case_file': 'जासूसी केस फ़ाइल',
    'lens_tip': 'मुझे नीचे मंगल, पृथ्वी, शुक्र या शनि पर खींचें!',
    // Added.
    'scene_s1': 'तारों भरे आकाश में सूर्य और आठ ग्रहों की कक्षाएँ',
    'scene_s2': 'तारों भरे आकाश में एक पंक्ति में मंगल, पृथ्वी, शुक्र और शनि',
    'lens_label': 'आवर्धक लेंस',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 4;

/// Scenario [index] in [lang], built from the string table.
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('sc${n}_title'),
    objective: t('s${n}_obj'),
    steps: [
      for (var i = 1; i <= _stepCount; i++)
        LabStep(
          concept: t('s${n}_t${i}_c'),
          action: t('s${n}_t${i}_a'),
          observation: t('s${n}_t${i}_o'),
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
const Offset _designCenter = Offset(500, 280);

/// Screens shorter than this (phones in landscape) get the compact cards.
const double _compactBelow = 480;

/// Room added around a planet or an orbit line for a finger (logical px).
const double _touchDp = 24;

/// Longest step (s) of one frame, so a stalled frame does not make the
/// planets or the confetti jump.
const double _maxFrameStep = 0.05;

/// Room kept free above the canvas bottom for the shell's HUD chip while
/// the sidebar is open (logical px × UI scale), and the gap between cards.
const double _hudBand = 58;
const double _cardGap = 8;

// ------------------------------------------------------------------ camera
// HTML init3D(): PerspectiveCamera(60°) at (0, 24, 48) looking at the
// origin; progressScenario1Step() moves it to (-4, 18, 34) for step 2 and to
// (-6, 28, 62) for step 3; onFinishScenario1() to (0, 48, 88);
// setupScenario2Stage() to (2, 16, 42) looking at (2, 0, 0); a verified
// planet brings it to (x, 5, z + 9), or z + 14 for Saturn.

const double _fovDegrees = 60;
final double _tanHalfFov = math.tan(_fovDegrees * math.pi / 360);

/// Nothing closer to the camera than this is drawn (the near plane).
const double _near = 0.5;

const _V _eyeStart = _V(0, 24, 48);
const _V _eyeInner = _V(-4, 18, 34);
const _V _eyeOuter = _V(-6, 28, 62);
const _V _eyeFinish = _V(0, 48, 88);
const _V _eyeDetective = _V(2, 16, 42);
const _V _lookDetective = _V(2, 0, 0);
const double _closeupY = 5;
const double _closeupZ = 9;
const double _closeupZRinged = 14;

/// The camera keeps each HTML viewing angle but stands at least this many
/// times the outermost framed orbit radius away, so that the whole orbit is
/// in front of it (the HTML camera cut off the orbits' near arcs).
const double _standBack = 1.8;

/// Tween.js durations (s): resetCamera() 600 ms, a new step 800 ms, Finish
/// 1200 ms, a verified planet 900 ms (all `Quadratic.Out`).
const double _resetSeconds = 0.6;
const double _stepSeconds = 0.8;
const double _finishSeconds = 1.2;
const double _verifySeconds = 0.9;

/// The framed picture follows a new framing with this rate (1/s): a new
/// step, or the canvas changing size (the sidebar opening or closing).
const double _viewRate = 6;

/// Room kept around the framed objects (design px) and the zoom range of
/// the framing, as a factor of the HTML picture.
const double _framePad = 10;
const double _minFrameZoom = 0.3;
const double _maxFrameZoom = 4.5;

/// Canvas label size (design px), enlarged up to [_labelMaxBoost] when the
/// stage is drawn smaller than [_labelFullScale]; the label's gap above its
/// planet (HTML `top: y - 16px`, here above the sphere).
const double _labelPx = 11;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.9;
const double _labelGap = 6;

// ------------------------------------------------------------------- scene

/// The Sun: `SphereGeometry(6.5)`.
const double _sunRadius = 6.5;

/// Saturn's ring: `RingGeometry(size * 1.3, size * 2.3)`, turned by
/// `rotation.x = PI / 3` and carried round by the planet's spin.
const double _ringInner = 1.3;
const double _ringOuter = 2.3;
const double _ringTilt = math.pi / 3;

/// Background starfield: 1600 points on a sphere (HTML radius 90; drawn
/// here at infinity, so the farther camera does not leave the sphere).
const int _starCount = 1600;
const int _starSeed = 90;

/// The asteroid zone between Mars (29) and Jupiter (42), shown once every
/// planet revolves (added: the step 4 observation describes it).
const int _asteroidCount = 260;
const double _asteroidInner = 33;
const double _asteroidOuter = 38;
const double _asteroidSpeed = 0.0085;
const int _asteroidSeed = 4;

/// HTML animate(): `rotation.y += 0.015` and, while revolving,
/// `(0.012 - idx * 0.001) || 0.003` radians a frame at 60 fps.
const double _fps = 60;
const double _spinPerFrame = 0.015;
const double _orbitBaseSpeed = 0.012;
const double _orbitSpeedStep = 0.001;
const double _orbitMinSpeed = 0.003;

/// HTML handlePlanetClick() `scale.set(1.35)`, onDetectivePlanetSelect()
/// `scale.set(1.55)`; eased here over [_scaleSeconds].
const double _pickedScale = 1.35;
const double _verifiedScale = 1.55;
const double _scaleSeconds = 0.25;

/// The planets of Scenario 2 stand in a row (HTML `detectivePositions`).
const Map<_Planet, double> _lineupX = {
  _Planet.mars: -22,
  _Planet.earth: -7,
  _Planet.venus: 8,
  _Planet.saturn: 26,
};

/// HTML `detectiveCluesOrder`.
const List<_Planet> _clueOrder = [
  _Planet.mars,
  _Planet.earth,
  _Planet.venus,
  _Planet.saturn,
];

/// HTML `setTimeout`s: the next step 1200 ms after the last tub drop and
/// 1400 ms after the last orbit drop.
const Duration _sortAdvance = Duration(milliseconds: 1200);
const Duration _orbitAdvance = Duration(milliseconds: 1400);

/// A wrong tub shakes (`.shake-error`, 0.4 s, ±8 px); a filled orbit flashes
/// (added: "the orbit lights up brightly").
const double _shakeSeconds = 0.4;
const double _shakePx = 8;
const double _flashSeconds = 1.4;

// --------------------------------------------------------------- confetti
// canvas-confetti defaults: startVelocity 45, decay 0.9, gravity 1 (× 3),
// ticks 200; each call sets particleCount, spread and origin.y.

const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;

/// One `confetti({particleCount, spread, origin: {y}})` call.
typedef _Burst = ({int count, double spread, double originY});

/// onFinishScenario1(), onDetectiveNextStep() (last clue) and the success
/// modal of onSummaryNext().
const _Burst _finishBurst = (count: 120, spread: 70, originY: 0.4);
const _Burst _detectiveBurst = (count: 140, spread: 75, originY: 0.3);
const _Burst _trophyBurst = (count: 150, spread: 80, originY: 0.3);

// ---------------------------------------------------------------- planets

/// A tub of Scenario 1 (HTML `group`).
enum _Group {
  rocky('basket_rocky', 'basket_rocky_sub', 'drop_inner', 'tub_rocky'),
  gas('basket_gas', 'basket_gas_sub', 'drop_outer', 'tub_gas');

  const _Group(this.labelKey, this.subKey, this.promptKey, this.tubKey);

  final String labelKey;
  final String subKey;
  final String promptKey;

  /// The tub's name in the 'Correct!' toast ('green Rocky Planets').
  final String tubKey;
}

/// HTML `allPlanetsData`: orbit radius, sphere size, material colour, tub
/// and orbit number.
enum _Planet {
  mercury(11, 0.7, Color(0xFFA8A29E), _Group.rocky, 1),
  venus(16, 1.1, Color(0xFFFDE047), _Group.rocky, 2),
  earth(22, 1.25, Color(0xFF3B82F6), _Group.rocky, 3),
  mars(29, 0.85, Color(0xFFEF4444), _Group.rocky, 4),
  jupiter(42, 3.2, Color(0xFFF97316), _Group.gas, 5),
  saturn(55, 2.6, Color(0xFFFACC15), _Group.gas, 6),
  uranus(67, 1.9, Color(0xFF22D3EE), _Group.gas, 7),
  neptune(78, 1.85, Color(0xFF3B82F6), _Group.gas, 8);

  const _Planet(this.dist, this.size, this.color, this.group, this.orbit);

  final double dist;
  final double size;
  final Color color;
  final _Group group;
  final int orbit;

  /// HTML `ring: true`.
  bool get ringed => this == saturn;

  /// HTML pool sphere: `w-16` when `size < 1.5`, else `w-20`.
  bool get small => size < 1.5;

  String get nameKey => 'planet_$name';

  /// `planetDetailsMulti` field ('type', 'surf', 'dist', 'feat', 'desc').
  String detailKey(String field) => 'pd_${name}_$field';

  /// HTML animate(): radians a frame while revolving.
  double get orbitSpeed {
    final v = _orbitBaseSpeed - index * _orbitSpeedStep;
    return v.abs() < 1e-9 ? _orbitMinSpeed : v;
  }

  static _Planet ofOrbit(int n) => values[n - 1];
}

// ------------------------------------------------------------------- math

/// A point or direction in the Three.js world (y up).
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
    return l < 1e-12 ? this : this * (1 / l);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Tween.js `Easing.Quadratic.Out`.
double _easeOutQuad(double t) => t * (2 - t);

/// A camera looking from [eye] at [target] (Three.js `lookAt` with y up):
/// its right, up and forward axes.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target) {
    final f = (target - eye).unit;
    final side = f.cross(_V.up);
    final r = side.length < 1e-9 ? const _V(1, 0, 0) : side.unit;
    return _Cam._(eye, target, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.target, this.f, this.r, this.u);

  final _V eye;
  final _V target;
  final _V f;
  final _V r;
  final _V u;

  /// Depth of [p] along the view axis.
  double depth(_V p) => (p - eye).dot(f);

  /// [p] on the image plane (1 = half the HTML canvas height, y up), or null
  /// behind the near plane.
  Offset? uv(_V p) {
    final d = p - eye;
    final z = d.dot(f);
    if (z < _near) return null;
    final k = 1 / (z * _tanHalfFov);
    return Offset(d.dot(r) * k, d.dot(u) * k);
  }

  /// A direction at infinity (the starfield) on the image plane.
  Offset? sky(_V dir) {
    final z = dir.dot(f);
    if (z <= 0.05) return null;
    final k = 1 / (z * _tanHalfFov);
    return Offset(dir.dot(r) * k, dir.dot(u) * k);
  }

  /// Radius on the image plane of a sphere of [radius] at depth [z].
  static double radiusAt(double radius, double z) => radius / (z * _tanHalfFov);

  static _Cam lerp(_Cam a, _Cam b, double t) =>
      _Cam(_V.lerp(a.eye, b.eye, t), _V.lerp(a.target, b.target, t));
}

/// A camera glide (Tween.js on `camera.position`, the target moving with
/// it).
class _CamMove {
  _CamMove(this.from, this.to, this.start, this.seconds);

  _CamMove.still(_Cam cam) : from = cam, to = cam, start = 0, seconds = 0;

  final _Cam from;
  final _Cam to;
  final double start;
  final double seconds;

  _Cam at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _Cam.lerp(from, to, _easeOutQuad((t - start) / seconds));
  }
}

/// Where the image plane lands on the stage: `uv → c + (u, -v) × k` in
/// design px. The HTML picture is [k] = half the canvas height about the
/// canvas centre; the framing moves and zooms it.
@immutable
class _View {
  const _View(this.k, this.c);

  final double k;
  final Offset c;

  Offset map(Offset uv) => Offset(c.dx + uv.dx * k, c.dy - uv.dy * k);

  _View towards(_View o, double t) =>
      _View(k + (o.k - k) * t, Offset.lerp(c, o.c, t)!);

  bool near(_View o) => (k - o.k).abs() < 0.05 && (c - o.c).distance < 0.05;
}

/// A value easing from [from] to [to] over [seconds] from [start] (the
/// HTML's instant scale changes, eased).
@immutable
class _Ramp {
  const _Ramp(this.from, this.to, this.start, this.seconds);

  const _Ramp.fixed(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0;

  final double from;
  final double to;
  final double start;
  final double seconds;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * _easeOutQuad((t - start) / seconds);
  }
}

// ------------------------------------------------------------------ model

/// One planet mesh (HTML `planetMeshes[id]` and its `userData`).
class _Body {
  _Body(this.planet);

  final _Planet planet;

  /// Angle round the Sun (`atan2(z, x)`); 0 is the HTML start (dist, 0, 0).
  double angle = 0;

  /// `rotation.y`, which also carries Saturn's ring round.
  double spin = 0;
  bool visible = false;
  bool orbiting = false;

  /// Scenario 2: the planet stands in the row (HTML `detectivePositions`).
  bool lineup = false;
  _Ramp scale = const _Ramp.fixed(1);

  /// When its orbit lit up (scene time).
  double flashAt = -100;

  /// HTML `mesh.position`.
  _V get position => lineup
      ? _V(_lineupX[planet] ?? 0, 0, 0)
      : _V(math.cos(angle) * planet.dist, 0, math.sin(angle) * planet.dist);

  /// HTML resetScenarioState(): scale 1, not revolving, back at (dist, 0, 0).
  void reset() {
    angle = 0;
    visible = false;
    orbiting = false;
    lineup = false;
    scale = const _Ramp.fixed(1);
    flashAt = -100;
  }

  void scaleTo(double value, double t) {
    final now = scale.at(t);
    if ((now - value).abs() < 1e-6 && scale.to == value) return;
    scale = _Ramp(now, value, t, _scaleSeconds);
  }
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

/// canvas-confetti for the summary and success popups: pieces fly, slow
/// down, fall and fade over 200 ticks.
class _Confetti {
  final List<_Confetto> pieces = [];
  final math.Random _rnd = math.Random(5);

  /// Canvas size the pieces are placed in (logical px).
  Size size = _design;
  double _ticks = 0;

  /// `confetti({particleCount, spread, origin})`, fired upwards from the
  /// middle of the canvas.
  void burst(_Burst b) {
    const a = math.pi / 2;
    final s = b.spread * math.pi / 180;
    for (var k = 0; k < b.count; k++) {
      pieces.add(
        _Confetto(
          x: 0.5 * size.width,
          y: b.originY * size.height,
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

  void clear() {
    pieces.clear();
    _ticks = 0;
  }
}

/// The starfield directions (HTML `bgStarsPos`, uniform on the sphere) and
/// a brightness for each.
final List<(_V, double)> _starDirs = () {
  final rnd = math.Random(_starSeed);
  return [
    for (var i = 0; i < _starCount; i++)
      () {
        final theta = rnd.nextDouble() * 2 * math.pi;
        final phi = math.acos(2 * rnd.nextDouble() - 1);
        return (
          _V(
            math.sin(phi) * math.cos(theta),
            math.sin(phi) * math.sin(theta),
            math.cos(phi),
          ),
          0.45 + 0.55 * rnd.nextDouble(),
        );
      }(),
  ];
}();

/// The asteroid zone: angle, radius, height and size of each rock.
final List<(double, double, double, double)> _asteroids = () {
  final rnd = math.Random(_asteroidSeed);
  return [
    for (var i = 0; i < _asteroidCount; i++)
      (
        rnd.nextDouble() * 2 * math.pi,
        _asteroidInner +
            (_asteroidOuter - _asteroidInner) *
                (0.5 + 0.5 * (rnd.nextDouble() - rnd.nextDouble())),
        (rnd.nextDouble() - 0.5) * 1.2,
        0.5 + rnd.nextDouble(),
      ),
  ];
}();

/// Mutable scene read by the painter every frame (HTML `State` plus the
/// Three.js objects' animated values).
class _Scene {
  double time = 0;
  int scenario = 0;
  int step = 1;

  final List<_Body> bodies = [for (final p in _Planet.values) _Body(p)];

  _Body body(_Planet p) => bodies[p.index];

  // ------------------------------------------------------------ scenario 1

  /// HTML `State.sortedPlanets`.
  final List<_Planet> rocky = [];
  final List<_Planet> gas = [];

  /// HTML `State.placedOrbits`: orbit number → planet.
  final Map<int, _Planet> placed = {};

  /// HTML `State.selectedItemForClickDrop` (a pool planet or a tray pill).
  _Planet? selected;

  /// The planet whose facts card is open (added; HTML handlePlanetClick()).
  _Planet? info;

  /// 'Finish' was tapped: the camera stands over the whole system.
  bool finished = false;

  /// The tub that shakes (`.shake-error`) and since when.
  _Group? shake;
  double shakeAt = -100;

  /// The orbit under a dragged pill.
  int? hoverOrbit;

  /// The asteroid zone's turn and when it appeared (added).
  double beltAngle = 0;
  double beltSince = -100;

  // ------------------------------------------------------------ scenario 2

  /// HTML `State.detectiveSolved`.
  final List<_Planet> solved = [];

  /// The lens was tapped (HTML `selectedItemForClickDrop = {type: 'lens'}`).
  bool lens = false;

  /// `#detective-closeup-popup` is shown.
  bool closeup = false;

  /// The fourth clue was recorded and the summary shown.
  bool detectiveDone = false;

  /// The planet under the dragged lens.
  _Planet? hoverPlanet;

  // --------------------------------------------------------------- camera

  _CamMove move = _CamMove.still(_Cam(_eyeStart, _V.zero));
  _Cam cam = _Cam(_eyeStart, _V.zero);

  /// The picture on the stage (it glides to each new framing).
  _View view = const _View(280, _designCenter);

  /// Jump to the next framing (entering the lab) instead of gliding.
  bool snapView = true;

  /// The HTML picture's scale (half the canvas height, design px), for the
  /// starfield.
  double htmlK = 280;

  final _Confetti confetti = _Confetti();

  List<_Planet> group(_Group g) => g == _Group.rocky ? rocky : gas;
  bool isSorted(_Planet p) => rocky.contains(p) || gas.contains(p);

  /// HTML renderSortingPool(): the planets not in a tub yet.
  List<_Planet> get unsorted => [
    for (final p in _Planet.values)
      if (!isSorted(p)) p,
  ];

  /// The orbits of step 2 (1–4) or step 3 (5–8).
  List<int> get stepOrbits =>
      step == 2 ? const [1, 2, 3, 4] : const [5, 6, 7, 8];

  /// HTML renderOrbitPlacementTray(): the step's planets not on an orbit.
  List<_Planet> get tray => [
    for (final n in stepOrbits)
      if (!placed.containsKey(n)) _Planet.ofOrbit(n),
  ];

  /// HTML `detectiveCluesOrder[State.step - 1]`.
  _Planet get clue => _clueOrder[(step - 1).clamp(0, _clueOrder.length - 1)];

  /// HTML resetScenarioState(sc).
  void load(int index) {
    scenario = index;
    step = 1;
    selected = null;
    info = null;
    hoverOrbit = null;
    hoverPlanet = null;
    shake = null;
    for (final b in bodies) {
      b.reset();
    }
    rocky.clear();
    gas.clear();
    placed.clear();
    finished = false;
    solved.clear();
    lens = false;
    closeup = false;
    detectiveDone = false;
    if (index == 0) {
      setupSolarStep(1);
    } else {
      setupDetectiveStep(1);
    }
  }

  /// HTML setupScenario1Stage(step): which planets show and revolve.
  void setupSolarStep(int s) {
    if (s == 4 && step != 4) beltSince = time;
    step = s;
    for (final b in bodies) {
      if (s == 1) {
        b.visible = false;
      } else if (s < 4) {
        b.visible = placed.containsValue(b.planet);
      } else {
        b
          ..visible = true
          ..orbiting = true;
      }
    }
  }

  /// HTML setupScenario2Stage(step): Mars, Earth, Venus and Saturn in a
  /// row, not revolving (the scale of a verified planet stays, as in the
  /// HTML, until the next one is verified).
  void setupDetectiveStep(int s) {
    step = s;
    closeup = false;
    lens = false;
    for (final b in bodies) {
      final inRow = _lineupX.containsKey(b.planet);
      b
        ..visible = inRow
        ..orbiting = false
        ..lineup = inRow;
    }
  }

  /// HTML orbit line material for orbit [n]: colour and opacity, or null
  /// while hidden.
  (Color, double)? orbitLook(int n) {
    if (scenario != 0 || step == 1) return null;
    if (step == 4) return (_Colors.orbitDone, 0.6);
    final target = step == 2 ? n <= 4 : n > 4;
    if (!target) return (_Colors.orbitIdle, 0.3);
    return placed.containsKey(n)
        ? (_Colors.orbitDone, 0.8)
        : (_Colors.orbitTarget, 0.8);
  }

  /// HTML animate(): every mesh spins; revolving ones move round the Sun.
  void update(double dt) {
    final frames = dt * _fps;
    for (final b in bodies) {
      b.spin += _spinPerFrame * frames;
      if (b.orbiting && !b.lineup) {
        b.angle += b.planet.orbitSpeed * frames;
      }
    }
    if (scenario == 0 && step == 4) beltAngle += _asteroidSpeed * frames;
    confetti.update(dt);
  }

  /// The planet whose surface the Scenario 2 camera looks at, if any.
  _Planet? get closeupPlanet {
    if (scenario != 1) return null;
    if (closeup) return clue;
    if (detectiveDone && solved.isNotEmpty) return solved.last;
    return null;
  }

  /// Where the camera stands for the current phase (the HTML positions,
  /// moved back along their line of sight when they stood too close).
  _Cam aim() {
    if (scenario == 1) {
      final p = closeupPlanet;
      if (p == null) return _Cam(_eyeDetective, _lookDetective);
      final at = body(p).position;
      return _Cam(
        _V(at.x, _closeupY, at.z + (p.ringed ? _closeupZRinged : _closeupZ)),
        _V(at.x, 0, at.z),
      );
    }
    final (eye, reach) = switch (step) {
      1 => (_eyeStart, 0.0),
      2 => (_eyeInner, _Planet.mars.dist),
      _ => (finished ? _eyeFinish : _eyeOuter, _Planet.neptune.dist),
    };
    final away = eye.length;
    final need = reach * _standBack;
    return _Cam(away < need ? eye * (need / away) : eye, _V.zero);
  }

  /// Starts the camera glide to [aim] over [seconds].
  void glide(double seconds) {
    final to = aim();
    move = _CamMove(cam, to, time, seconds);
  }

  /// Jumps the camera to [aim].
  void jump() {
    cam = aim();
    move = _CamMove.still(cam);
  }
}

/// The canvas cards the framing keeps the planets clear of.
enum _Card { bar, tray, finish, info, clue, dock, score, closeup, conclude }

/// The magnifying glass being dragged (HTML `'magnifying_glass'`).
enum _Lens { glass }

class _PlanetsLabState extends State<Ch12A4PlanetsAndTheirCharacteristicsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();

  /// The design-size scene inside the stage (finger positions in design
  /// px) and the full-canvas measuring layer (canvas px).
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final Map<_Card, GlobalKey> _cardKeys = {
    for (final c in _Card.values) c: GlobalKey(debugLabel: 'ch12a4-${c.name}'),
  };
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout and the
  /// canvas label size for it.
  double _fit = 1;
  double _labelSize = _labelPx;

  /// The canvas area the cards live in (insets from the canvas edges: the
  /// shell's tool column, the mission card and the HUD chip).
  EdgeInsets _area = EdgeInsets.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  String _name(_Planet p) => _t(p.nameKey);
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
    _scene
      ..load(0)
      ..jump();
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

  /// HTML `animate()`: TWEEN.update() (the camera glide), the spinning and
  /// revolving planets and the confetti, then the framing and a repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s
      ..time = now
      ..update(dt)
      ..cam = s.move.at(now);
    _reframe(dt);
    _frame.value = now;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// HTML `showToast(msg)`. Silent: the HTML plays the action's own tone.
  void _toast(String text, {bool error = false}) =>
      _lab.showToast(text, isError: error, sound: false);

  void _burst(_Burst burst) {
    final box = _box(_canvasKey);
    _scene.confetti
      ..size = box?.size ?? _design
      ..burst(burst);
  }

  // --------------------------------------------------------------- loading

  /// HTML `changeScenario(sc)` → resetScenarioState(sc): the scenario's
  /// first step and the camera back (resetCamera()).
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    final s = _scene;
    s
      ..load(index)
      ..glide(index == 0 ? _resetSeconds : _stepSeconds);
    _lab.resetView(sound: false);
    _refresh();
  }

  /// HTML `enterLab()` → resetScenarioState(1); the shell's full reset
  /// does the same behind the curtain.
  void _startLab() {
    _scene
      ..confetti.clear()
      ..snapView = true;
    _loadScenario(0);
    _scene.jump();
  }

  // ------------------------------------------------- scenario 1: the tubs

  bool get _solarStep1 =>
      _lab.isLabActive && _scene.scenario == 0 && _scene.step == 1;

  bool get _orbitStep =>
      _lab.isLabActive &&
      _scene.scenario == 0 &&
      (_scene.step == 2 || _scene.step == 3);

  /// A pool planet tapped (HTML `div.onclick`): picked, or put back.
  void _pickPoolPlanet(_Planet p) {
    final s = _scene;
    if (!_solarStep1 || s.isSorted(p)) return;
    _Sound.click.play();
    s.selected = s.selected == p ? null : p;
    _refresh();
  }

  /// HTML `onBasketClick(type)`: the picked planet goes into the tub.
  void _tapTub(_Group g) {
    final s = _scene;
    final p = s.selected;
    if (!_solarStep1 || p == null) return;
    _sortDrop(p, g);
    s.selected = null;
    _refresh();
  }

  /// HTML `handleSortDrop(pid, tub)`: the right tub keeps the planet; the
  /// wrong one shakes and sends it back to the pool.
  void _sortDrop(_Planet p, _Group g) {
    final s = _scene;
    if (!_solarStep1 || s.isSorted(p)) return;
    if (p.group == g) {
      _Sound.pop.play();
      s.group(g).add(p);
      if (s.selected == p) s.selected = null;
      _toast(
        labFormat(_t('toast_sort_ok'), {'p': _name(p), 'tub': _t(g.tubKey)}),
      );
      if (s.rocky.length == 4 && s.gas.length == 4) {
        _lab.after(_sortAdvance, () {
          if (s.scenario == 0 && s.step == 1) _advanceSolar();
        });
      }
    } else {
      _Sound.wrong.play();
      s
        ..shake = g
        ..shakeAt = s.time;
      _toast(
        labFormat(_t('toast_sort_bad'), {'p': _name(p), 'tub': _t(g.labelKey)}),
        error: true,
      );
    }
    _refresh();
  }

  /// HTML `progressScenario1Step()`: the next stage, with the camera moving
  /// in for the inner orbits (step 2) and out for the outer ones (step 3).
  void _advanceSolar() {
    final s = _scene;
    s
      ..setupSolarStep(math.min(s.step + 1, _stepCount))
      ..selected = null
      ..info = null
      ..hoverOrbit = null;
    if (s.step == 2 || s.step == 3) s.glide(_stepSeconds);
    _refresh();
  }

  // ----------------------------------------------- scenario 1: the orbits

  /// A tray pill tapped (HTML `btn.onclick`): picked, or put back.
  void _pickTrayPlanet(_Planet p) {
    final s = _scene;
    if (!_orbitStep || s.placed.containsValue(p)) return;
    _Sound.click.play();
    s.selected = s.selected == p ? null : p;
    _refresh();
  }

  /// HTML `onOrbitTargetClick(n)`: the picked pill goes onto orbit [n];
  /// with nothing picked, a hint names the planet that belongs there.
  void _tapOrbit(int n) {
    final s = _scene;
    if (!_orbitStep) return;
    final p = s.selected;
    if (p != null) {
      _orbitDrop(p, n);
      s.selected = null;
      _refresh();
      return;
    }
    _toast(
      labFormat(_t('toast_orbit_hint'), {
        'n': n,
        'p': _name(_Planet.ofOrbit(n)),
      }),
    );
  }

  /// HTML `handleOrbitDrop(pid, n)`: on its own orbit the planet appears,
  /// the orbit turns green and the planet starts revolving.
  void _orbitDrop(_Planet p, int n) {
    final s = _scene;
    if (!_orbitStep || s.placed.containsValue(p)) return;
    if (p.orbit == n) {
      _Sound.pop.play();
      s.placed[n] = p;
      s.body(p)
        ..visible = true
        ..orbiting = true
        ..flashAt = s.time;
      if (s.selected == p) s.selected = null;
      _toast(labFormat(_t('toast_orbit_ok'), {'p': _name(p), 'n': n}));
      if (s.stepOrbits.every(s.placed.containsKey)) {
        final step = s.step;
        _lab.after(_orbitAdvance, () {
          if (s.scenario == 0 && s.step == step) _advanceSolar();
        });
      }
    } else {
      _Sound.wrong.play();
      _toast(
        labFormat(_t('toast_orbit_bad'), {'p': _name(p), 'm': p.orbit, 'n': n}),
        error: true,
      );
    }
    _refresh();
  }

  /// HTML `onFinishScenario1()`: every planet revolves, the camera pulls
  /// back over the whole system and the summary opens.
  void _finish() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.step != _stepCount) return;
    s
      ..setupSolarStep(_stepCount)
      ..finished = true
      ..info = null
      ..glide(_finishSeconds);
    _lab.completedScenarios.add(0);
    _burst(_finishBurst);
    // showPopup() plays the HTML `success` tone.
    _lab.showPopup(_solarSummary);
    _refresh();
  }

  /// HTML `handlePlanetClick(mesh)` in Scenario 1: the planet grows to
  /// 1.35 and (added) its facts card opens.
  void _tapSolarPlanet(_Planet p) {
    final s = _scene;
    _Sound.click.play();
    for (final b in s.bodies) {
      b.scaleTo(b.planet == p ? _pickedScale : 1, s.time);
    }
    s.info = p;
    _refresh();
  }

  void _closeInfo() {
    final s = _scene;
    _Sound.click.play();
    for (final b in s.bodies) {
      b.scaleTo(1, s.time);
    }
    s.info = null;
    _refresh();
  }

  // ------------------------------------------------- scenario 2: detective

  bool get _detective => _lab.isLabActive && _scene.scenario == 1;

  /// HTML `lens.onclick`: the magnifying glass is ready; a tap on a planet
  /// (which works with or without it, as in the HTML) checks it.
  void _activateLens() {
    if (!_detective) return;
    _Sound.click.play();
    _scene.lens = true;
    _toast(_t('magnifying_active'));
    _refresh();
  }

  /// HTML `onDetectivePlanetSelect(pid)`: the planet of the clue grows,
  /// glows and the camera zooms in on it; any other planet buzzes.
  void _selectDetective(_Planet p) {
    final s = _scene;
    if (!_detective || !_lineupX.containsKey(p)) return;
    if (p == s.clue) {
      _Sound.pop.play();
      for (final b in s.bodies) {
        b.scaleTo(b.planet == p ? _verifiedScale : 1, s.time);
      }
      if (!s.solved.contains(p)) s.solved.add(p);
      s
        ..closeup = true
        ..lens = false
        ..glide(_verifySeconds);
      _toast(labFormat(_t('toast_verified'), {'p': _name(p)}));
    } else {
      _Sound.wrong.play();
      _toast(labFormat(_t('toast_wrong_planet'), {'p': _name(p)}), error: true);
    }
    _refresh();
  }

  /// HTML `onDetectiveNextStep()`: the next clue, or after the fourth the
  /// summary (the camera stays on Saturn).
  void _nextClue() {
    final s = _scene;
    if (!_detective || !s.closeup) return;
    _Sound.pop.play();
    s.closeup = false;
    if (s.step < _stepCount) {
      s
        ..setupDetectiveStep(s.step + 1)
        ..glide(_stepSeconds);
    } else {
      s.detectiveDone = true;
      _showDetectiveSummary();
    }
    _refresh();
  }

  void _showDetectiveSummary() {
    _lab.completedScenarios.add(1);
    _burst(_detectiveBurst);
    _lab.showPopup(_detectiveSummary);
    _refresh();
  }

  // ---------------------------------------------------------------- popups

  /// HTML `#summary-modal` after Finish: 'Scenario 1 Complete!', the
  /// summary and the message to go on to Scenario 2. Added: a 'Next
  /// Scenario' button (the HTML hid it and pointed at the side panel).
  LabPopupContent _solarSummary() {
    final allDone = _lab.completedScenarios.length >= _scenarioCount;
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.check_circle,
      accent: _Colors.indigo500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          icon: Icons.lightbulb,
          iconColor: _Colors.indigo400,
          title: labFormat(_t('sc_complete'), {'n': 1}),
          summary: _t('s1_summary'),
          headingColor: _Colors.emerald400,
          next: _t('next_msg_s1'),
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        LabAction(
          label: _t('next_sc'),
          icon: Icons.arrow_forward,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          onTap: _nextScenario,
        ),
        if (allDone)
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.blue600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
      ],
    );
  }

  /// HTML `#summary-modal` after the last clue: 'Planet Detective
  /// Mastery!', the summary and 'View Final Success Trophies'.
  LabPopupContent _detectiveSummary() {
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.check_circle,
      accent: _Colors.indigo500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          icon: Icons.lightbulb,
          iconColor: _Colors.indigo400,
          title: _t('s2_popup_title'),
          summary: _t('s2_summary'),
          headingColor: _Colors.indigo400,
          next: null,
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        LabAction(
          label: _t('btn_trophies'),
          icon: Icons.arrow_forward,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          onTap: _showTrophies,
        ),
      ],
    );
  }

  /// HTML `onSummaryNext()` in Scenario 2: the summary closes and, 350 ms
  /// later, the `#success-modal` trophy opens with confetti.
  void _showTrophies() {
    _lab.hidePopup(sound: false);
    _lab.after(const Duration(milliseconds: 350), () {
      _burst(_trophyBurst);
      _lab.showPopup(_trophyPopup, silent: true);
    });
  }

  /// HTML `#success-modal`: 'Mastery Achieved!' and 'Restart Entire Lab'
  /// (HTML `restartApp()` = `resetApp()`, the curtain comes down).
  LabPopupContent _trophyPopup() {
    return LabPopupContent(
      title: _lab.t('success'),
      icon: Icons.check_circle,
      accent: _Colors.indigo500,
      extra: Builder(
        builder: (context) => _MasteryCard(
          title: _t('all_complete'),
          text: _t('all_complete_desc'),
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
          clock: _frame,
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
    );
  }

  /// 'Next Scenario' (HTML `onSummaryNext()` in Scenario 1).
  void _nextScenario() {
    _Sound.scenario.play();
    _loadScenario(1);
  }

  /// Sidebar buttons: 'Finish' (step 4), 'Record Findings & Next Clue'
  /// while a planet is verified, and (added) 'Observe Conclusion' to open
  /// the Scenario 2 summary again.
  List<LabAction> _actions() {
    final s = _scene;
    if (!_lab.isLabActive) return const [];
    if (s.scenario == 0 && s.step == _stepCount) {
      return [
        LabAction(
          label: _t('btn_finish_solar'),
          icon: Icons.check_circle,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _finish,
        ),
      ];
    }
    if (s.scenario == 1 && s.closeup) {
      return [
        LabAction(
          label: _t('btn_record'),
          icon: Icons.arrow_forward,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          silent: true,
          onTap: _nextClue,
        ),
      ];
    }
    if (s.scenario == 1 && s.detectiveDone) {
      return [
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _showDetectiveSummary,
        ),
      ];
    }
    return const [];
  }

  // ------------------------------------------------------------- gestures

  RenderBox? _box(GlobalKey key) {
    final o = key.currentContext?.findRenderObject();
    return o is RenderBox && o.attached && o.hasSize ? o : null;
  }

  /// The cards on the canvas, in global coordinates.
  Iterable<Rect> _globalCards() sync* {
    for (final key in _cardKeys.values) {
      final box = _box(key);
      if (box == null) continue;
      yield box.localToGlobal(Offset.zero) & box.size;
    }
  }

  bool _overCard(Offset global) =>
      _globalCards().any((r) => r.contains(global));

  /// [global] on the stage (design px), if it is over the free canvas.
  Offset? _stageAt(Offset global) {
    final canvas = _box(_canvasKey);
    if (canvas == null) return null;
    final local = canvas.globalToLocal(global);
    if (!(Offset.zero & canvas.size).contains(local) || _overCard(global)) {
      return null;
    }
    return labGlobalToLocal(_stageKey, global);
  }

  /// A finger's reach on the stage (design px).
  double get _reach => _touchDp / _fit;

  /// Where body [b] is drawn: centre and radius (design px).
  (Offset, double)? _disc(_Body b) {
    final s = _scene;
    final at = b.position;
    final uv = s.cam.uv(at);
    if (uv == null) return null;
    final r =
        _Cam.radiusAt(b.planet.size * b.scale.at(s.time), s.cam.depth(at)) *
        s.view.k;
    return (s.view.map(uv), r);
  }

  /// HTML raycast: the visible planet under [at] (design px), with a
  /// finger's reach around small planets.
  _Planet? _planetAt(Offset at) {
    _Planet? best;
    var bestD = double.infinity;
    for (final b in _scene.bodies) {
      if (!b.visible) continue;
      final disc = _disc(b);
      if (disc == null) continue;
      final (c, r) = disc;
      final hit = (b.planet.ringed ? r * 1.6 : r) + _reach;
      final d = (at - c).distance;
      if (d <= hit && d - r < bestD) {
        bestD = d - r;
        best = b.planet;
      }
    }
    return best;
  }

  /// The step's orbit line nearest to [at] (design px), within a finger's
  /// reach (added: the HTML only took drops on the orbit chips).
  int? _orbitAt(Offset at) {
    final s = _scene;
    int? best;
    var bestD = _reach;
    for (final n in s.stepOrbits) {
      final d = _Planet.ofOrbit(n).dist;
      Offset? last;
      for (var i = 0; i <= 96; i++) {
        final a = i / 96 * 2 * math.pi;
        final uv = s.cam.uv(_V(math.cos(a) * d, 0, math.sin(a) * d));
        if (uv == null) {
          last = null;
          continue;
        }
        final p = s.view.map(uv);
        if (last != null) {
          final dist = _segmentDistance(at, last, p);
          if (dist < bestD) {
            bestD = dist;
            best = n;
          }
        }
        last = p;
      }
    }
    return best;
  }

  static double _segmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 < 1e-9) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(
      0.0,
      1.0,
    );
    return (p - (a + ab * t)).distance;
  }

  /// HTML `onCanvasClick` (camera locked): a picked pill goes onto the
  /// orbit line under the finger (added); otherwise the planet under it is
  /// clicked.
  void _onStageTap(Offset at) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    if (_orbitStep && s.selected != null) {
      final n = _orbitAt(at);
      if (n != null) {
        _orbitDrop(s.selected!, n);
        s.selected = null;
        _refresh();
        return;
      }
    }
    final p = _planetAt(at);
    if (p == null) return;
    if (s.scenario == 0) {
      _tapSolarPlanet(p);
    } else {
      _selectDetective(p);
    }
  }

  /// A pill dragged over the canvas lights the orbit line under it.
  void _pillDragUpdate(DragUpdateDetails d) {
    if (!_orbitStep) return;
    final at = _stageAt(d.globalPosition);
    _scene.hoverOrbit = at == null ? null : _orbitAt(at);
  }

  /// A pill let go over an orbit line goes onto that orbit (drops on the
  /// orbit chips are taken by their [DragTarget]s).
  void _pillDragEnd(_Planet p, DraggableDetails d) {
    final s = _scene;
    final n = s.hoverOrbit;
    s.hoverOrbit = null;
    if (d.wasAccepted || n == null) return;
    _orbitDrop(p, n);
  }

  /// The lens dragged over the canvas rings the planet under it.
  void _lensDragUpdate(DragUpdateDetails d) {
    if (!_detective) return;
    final at = _stageAt(d.globalPosition);
    _scene.hoverPlanet = at == null ? null : _planetAt(at);
  }

  /// HTML lens `touchend` / drop: on a planet (or its chip, through the
  /// chip's [DragTarget]) that planet is checked.
  void _lensDragEnd(DraggableDetails d) {
    final s = _scene;
    final p = s.hoverPlanet;
    s.hoverPlanet = null;
    if (d.wasAccepted || p == null) return;
    _selectDetective(p);
  }

  // -------------------------------------------------------------- framing

  /// Moves the picture towards the framing of the current phase.
  void _reframe(double dt) {
    final s = _scene;
    final goal = _frameGoal();
    if (goal == null) return;
    if (s.snapView) {
      s
        ..view = goal
        ..snapView = false;
    } else if (!s.view.near(goal)) {
      s.view = s.view.towards(goal, 1 - math.exp(-dt * _viewRate));
    }
  }

  /// The framing: the step's orbits, the row of planets or the verified
  /// planet, as large as fits in the biggest free part of the canvas (the
  /// canvas cards kept clear). Scenario 1 step 1 keeps the HTML picture.
  _View? _frameGoal() {
    final s = _scene;
    final canvas = _box(_canvasKey);
    if (canvas == null) return null;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return null;
    final html = _View(size.height / 2 / fit, _designCenter);
    s.htmlK = html.k;
    final focus = _focus(s.move.to);
    if (focus == null || focus.isEmpty) return html;
    final origin = Offset(
      (size.width - _design.width * fit) / 2,
      (size.height - _design.height * fit) / 2,
    );
    final a = _area;
    final area = Rect.fromLTRB(
      a.left,
      a.top,
      size.width - a.right,
      size.height - a.bottom,
    );
    if (area.width < 20 || area.height < 20) return html;
    // The facts card floats over the scene (it does not reframe it).
    final blocks = <Rect>[
      for (final MapEntry(key: card, value: key) in _cardKeys.entries)
        if (card != _Card.info)
          if (_box(key) case final box?)
            canvas.globalToLocal(box.localToGlobal(Offset.zero)) & box.size,
    ];
    final free = _bestFree(area, blocks, focus.size);
    var d = Rect.fromLTRB(
      (free.left - origin.dx) / fit,
      (free.top - origin.dy) / fit,
      (free.right - origin.dx) / fit,
      (free.bottom - origin.dy) / fit,
    ).deflate(_framePad);
    if (_lab.showLabels) {
      // Room for the labels above the top planets.
      d = Rect.fromLTRB(d.left, d.top + _labelSize * 1.6, d.right, d.bottom);
    }
    if (d.width < 4 || d.height < 4) return html;
    final k = math
        .min(d.width / focus.width, d.height / focus.height)
        .clamp(html.k * _minFrameZoom, html.k * _maxFrameZoom);
    final fc = focus.center;
    return _View(k, d.center - Offset(fc.dx * k, -fc.dy * k));
  }

  /// What the framing shows, on the image plane of [cam] (v up), or null
  /// for the HTML picture.
  Rect? _focus(_Cam cam) {
    final s = _scene;
    final pts = <Offset>[];
    void sphere(_V at, double radius) {
      final uv = cam.uv(at);
      if (uv == null) return;
      final r = _Cam.radiusAt(radius, cam.depth(at));
      pts
        ..add(uv - Offset(r, r))
        ..add(uv + Offset(r, r));
    }

    if (s.scenario == 0) {
      if (s.step == 1) return null;
      final last = s.step == 2 ? 4 : 8;
      for (var n = 1; n <= last; n++) {
        final d = _Planet.ofOrbit(n).dist;
        for (var i = 0; i < 48; i++) {
          final a = i / 48 * 2 * math.pi;
          final uv = cam.uv(_V(math.cos(a) * d, 0, math.sin(a) * d));
          if (uv != null) pts.add(uv);
        }
      }
      sphere(_V.zero, _sunRadius);
    } else {
      final p = s.closeupPlanet;
      if (p != null) {
        sphere(
          s.body(p).position,
          p.size * _verifiedScale * (p.ringed ? _ringOuter : 1.3),
        );
      } else {
        for (final b in s.bodies) {
          if (!b.lineup) continue;
          sphere(
            b.position,
            b.planet.size * (b.planet.ringed ? _ringOuter : 1.4),
          );
        }
      }
    }
    if (pts.isEmpty) return null;
    var l = pts.first.dx, r = l, t = pts.first.dy, btm = t;
    for (final p in pts) {
      l = math.min(l, p.dx);
      r = math.max(r, p.dx);
      btm = math.min(btm, p.dy);
      t = math.max(t, p.dy);
    }
    return Rect.fromLTRB(l, btm, r, t);
  }

  /// The free rectangle of [area] (bounded by the edges of [blocks]) in
  /// which a box of [focus]'s shape can be drawn largest.
  static Rect _bestFree(Rect area, List<Rect> blocks, Size focus) {
    final inside = [
      for (final b in blocks)
        if (b.overlaps(area)) b.intersect(area),
    ];
    final lefts = {area.left, for (final b in inside) b.right + _cardGap};
    final rights = {area.right, for (final b in inside) b.left - _cardGap};
    final tops = {area.top, for (final b in inside) b.bottom + _cardGap};
    final bottoms = {area.bottom, for (final b in inside) b.top - _cardGap};
    var best = area;
    var bestScore = -1.0;
    final fw = math.max(focus.width, 1e-6);
    final fh = math.max(focus.height, 1e-6);
    for (final l in lefts) {
      for (final r in rights) {
        if (r - l < 24) continue;
        for (final t in tops) {
          for (final b in bottoms) {
            if (b - t < 24) continue;
            final rect = Rect.fromLTRB(l, t, r, b);
            if (inside.any((o) => o.deflate(0.5).overlaps(rect))) continue;
            final score = math.min(rect.width / fw, rect.height / fh);
            if (score > bestScore) {
              bestScore = score;
              best = rect;
            }
          }
        }
      }
    }
    return best;
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final scene = _scene;
        final data = _data;
        final n = scene.scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.public,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // HTML updateTeacherBoard(): `hud[State.step]`.
          hud: _t('s${n}_h${scene.step}'),
          actions: _actions(),
          onEnterLab: _startLab,
          onReset: _startLab,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepAccordion(
            key: ValueKey('ch12a4-steps-${scene.scenario}-${scene.step}'),
            steps: data.steps,
            current: scene.step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            taskLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            resultLabel: _t('observation'),
          ),
          overlays: _overlays(context, p, s),
          stage: _buildStage(),
        );
      },
    );
  }

  /// The canvas cards of the current stage (HTML `#stage-sorting`,
  /// `#stage-orbits`, `#stage-finish`, `#stage-detective`), the confetti and
  /// the measuring layer.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final hud = _lab.isSidebarOpen ? _hudBand * s : 0.0;
    _area = EdgeInsets.fromLTRB(
      inset.left,
      inset.top,
      inset.right,
      inset.bottom + hud,
    );
    final scene = _scene;
    final active = _lab.isLabActive;
    return [
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      if (active && scene.scenario == 0)
        ..._solarCards(s, compact)
      else if (active)
        _detectiveCards(s, compact),
      Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ConfettiPainter(scene.confetti, repaint: _frame),
            ),
          ),
        ),
      ),
    ];
  }

  /// Scenario 1's cards: the pool and the tubs (step 1), the orbit chips
  /// and the pill tray (steps 2–3), 'Finish' (step 4) and the facts card.
  List<Widget> _solarCards(double s, bool compact) {
    final scene = _scene;
    final step = scene.step;
    return [
      if (step == 1)
        Positioned.fill(
          child: Padding(
            padding: _area,
            child: _SortingBoard(
              pool: scene.unsorted,
              rocky: scene.rocky,
              gas: scene.gas,
              selected: scene.selected,
              shake: scene.shake,
              shakeAt: scene.shakeAt,
              clock: _frame,
              t: _t,
              scale: s,
              onPick: _pickPoolPlanet,
              onTub: _tapTub,
              onDrop: _sortDrop,
            ),
          ),
        ),
      if (step == 2 || step == 3)
        Positioned.fill(
          child: Padding(
            padding: _area,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: _OrbitBar(
                    key: _cardKeys[_Card.bar],
                    orbits: scene.stepOrbits,
                    placed: scene.placed,
                    clock: _frame,
                    t: _t,
                    scale: s,
                    onTap: _tapOrbit,
                    onDrop: _orbitDrop,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _PillTray(
                    key: _cardKeys[_Card.tray],
                    title: _t(step == 2 ? 'basket_rocky' : 'basket_gas'),
                    hint: _t('orbit_drag_hint'),
                    done: _t('tray_done'),
                    pills: scene.tray,
                    selected: scene.selected,
                    clock: _frame,
                    t: _t,
                    scale: s,
                    compact: compact,
                    onPick: _pickTrayPlanet,
                    onDragUpdate: _pillDragUpdate,
                    onDragEnd: _pillDragEnd,
                  ),
                ),
              ],
            ),
          ),
        ),
      if (step == _stepCount)
        Positioned.fill(
          child: Padding(
            padding: _area,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Semantics(
                container: true,
                label: _t('stage_1_step_4_label'),
                hint: _t('stage_1_step_4_desc'),
                child: _GlowButton(
                  key: _cardKeys[_Card.finish],
                  label: _t('btn_finish_solar'),
                  icon: Icons.check_circle,
                  colors: const [_Colors.emerald500, _Colors.green600],
                  shadow: const Color(0x9910B981),
                  big: true,
                  scale: s,
                  clock: _frame,
                  onTap: _finish,
                ),
              ),
            ),
          ),
        ),
      if (step >= 2 && scene.info != null && _lab.popup == null)
        Positioned.fill(
          child: Padding(
            padding: _area,
            child: Align(
              alignment: step == _stepCount
                  ? Alignment.topLeft
                  : Alignment.centerLeft,
              child: _PlanetCard(
                key: _cardKeys[_Card.info],
                planet: scene.info!,
                t: _t,
                scale: s,
                compact: compact,
                closeLabel: _lab.t('close'),
                onClose: _closeInfo,
              ),
            ),
          ),
        ),
    ];
  }

  /// Scenario 2's cards: the clue card with the lens (top), the Target
  /// Lineup (bottom left), the Detective Case File (bottom right) and the
  /// closeup card or, once solved, 'Observe Conclusion'.
  Widget _detectiveCards(double s, bool compact) {
    final scene = _scene;
    final clue = scene.clue;
    return Positioned.fill(
      child: Padding(
        padding: _area,
        child: Column(
          children: [
            _ClueCard(
              key: _cardKeys[_Card.clue],
              badge: labFormat(_t('clue_badge'), {'n': scene.step}),
              hint: _t('drag_lens'),
              text: _data.steps[scene.step - 1].action,
              lensLabel: _t('lens_label'),
              lensTip: _t('lens_tip'),
              lensActive: scene.lens,
              scale: s,
              compact: compact,
              onLensTap: _activateLens,
              onLensDragUpdate: _lensDragUpdate,
              onLensDragEnd: _lensDragEnd,
            ),
            SizedBox(height: _cardGap * s),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final fileWidth = math.min(
                    box.maxWidth * (compact ? 0.38 : 0.34),
                    (compact ? 210 : 280) * s,
                  );
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: _TargetDock(
                          key: _cardKeys[_Card.dock],
                          label: _t('suspect_planets'),
                          solved: scene.solved,
                          names: {for (final p in _clueOrder) p: _name(p)},
                          scale: s,
                          compact: compact,
                          maxWidth: box.maxWidth - fileWidth - 2 * _cardGap * s,
                          onTap: _selectDetective,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _CaseFile(
                          key: _cardKeys[_Card.score],
                          title: _t('case_file'),
                          solved: scene.solved,
                          t: _t,
                          scale: s,
                          compact: compact,
                          width: fileWidth,
                          folded: compact && scene.closeup,
                        ),
                      ),
                      if (scene.closeup)
                        Align(
                          alignment: Alignment.topLeft,
                          child: _CloseupCard(
                            key: _cardKeys[_Card.closeup],
                            planet: clue,
                            title: labFormat(_t('verified'), {
                              'p': _name(clue),
                            }),
                            text: _data.steps[scene.step - 1].observation,
                            button: _t('btn_record'),
                            t: _t,
                            scale: s,
                            compact: compact,
                            maxWidth: box.maxWidth * (compact ? 0.5 : 0.44),
                            maxHeight: box.maxHeight,
                            onNext: _nextClue,
                          ),
                        )
                      else if (scene.detectiveDone && _lab.popup == null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: _GlowButton(
                            key: _cardKeys[_Card.conclude],
                            label: _t('btn_conclude'),
                            icon: Icons.lightbulb,
                            colors: const [
                              _Colors.indigo600,
                              _Colors.indigo500,
                            ],
                            scale: s,
                            clock: _frame,
                            onTap: _showDetectiveSummary,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          // Canvas labels stay readable when the stage is drawn small.
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        final scene = _scene;
        return LabStage(
          designSize: _design,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The planets have their own semantics nodes ([_bodyNodes]).
            excludeFromSemantics: true,
            onTapUp: (d) => _onStageTap(d.localPosition),
            child: Stack(
              key: _stageKey,
              fit: StackFit.expand,
              children: [
                Semantics(
                  image: true,
                  label: _t(scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: _design,
                      painter: _ScenePainter(
                        scene: scene,
                        cache: _cache,
                        repaint: _frame,
                        showLabels: _lab.showLabels,
                        names: {for (final p in _Planet.values) p: _name(p)},
                        sunName: _t('planet_sun'),
                        labelSize: _labelSize,
                        onePx: 1 / _fit,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, _, _) => _bodyNodes(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// One screen-reader node per planet where it is drawn, so a screen
  /// reader can find and tap it. They take no touches: those reach the
  /// stage below.
  Widget _bodyNodes() {
    final s = _scene;
    if (!_lab.isLabActive) return const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final b in s.bodies)
          if (b.visible)
            if (_disc(b) case (final c, final r))
              Positioned.fromRect(
                rect: Rect.fromCircle(center: c, radius: math.max(r, 6)),
                child: Semantics(
                  container: true,
                  button: true,
                  label: _name(b.planet),
                  onTap: () => s.scenario == 0
                      ? _tapSolarPlanet(b.planet)
                      : _selectDetective(b.planet),
                  child: const SizedBox.expand(),
                ),
              ),
      ],
    );
  }
}

// ================================================================= WIDGETS

// ---------------------------------------------------------------- motion

/// Tailwind `animate-pulse`: opacity 1 → 0.5 → 1 every 2 s.
double _pulse(double t) => 0.75 + 0.25 * math.cos(t * math.pi);

/// Tailwind `animate-bounce`: up by a quarter of the height and back down
/// every second.
double _bounce(double t) {
  final phase = t - t.floorToDouble();
  return -0.25 * (1 - math.sin(phase * math.pi));
}

/// `.shake-error` (0.4 s): 0 → −8 → 8 → −8 → 8 → 0 px at every 20 %.
double _shakeOffset(double since) {
  if (since < 0 || since >= _shakeSeconds) return 0;
  const keys = [0.0, -1.0, 1.0, -1.0, 1.0, 0.0];
  final f = since / _shakeSeconds * 5;
  final i = f.floor().clamp(0, 4);
  final k = f - i;
  return (keys[i] + (keys[i + 1] - keys[i]) * k) * _shakePx;
}

/// Splits `*bold*` words (the HTML's `<strong>` / `<b>`) out of [text].
List<TextSpan> _rich(String text, TextStyle bold) {
  final parts = text.split('*');
  return [
    for (var i = 0; i < parts.length; i++)
      if (parts[i].isNotEmpty)
        TextSpan(text: parts[i], style: i.isOdd ? bold : null),
  ];
}

/// The HTML's coloured planet dot (`rounded-full` with the mesh colour).
class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size, this.mark = false});

  final Color color;
  final double size;

  /// The tray's and the case file's '●' inside the dot.
  final bool mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3)],
      ),
      child: mark
          ? Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: const BoxDecoration(
                color: _Colors.white,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

// ------------------------------------------------------------ sorting board

/// HTML `#stage-sorting`: the Unsorted Planets Pool on the left, a dashed
/// divider and the green Rocky Planets tub over the red Gas Giants tub.
class _SortingBoard extends StatelessWidget {
  const _SortingBoard({
    required this.pool,
    required this.rocky,
    required this.gas,
    required this.selected,
    required this.shake,
    required this.shakeAt,
    required this.clock,
    required this.t,
    required this.scale,
    required this.onPick,
    required this.onTub,
    required this.onDrop,
  });

  final List<_Planet> pool;
  final List<_Planet> rocky;
  final List<_Planet> gas;
  final _Planet? selected;
  final _Group? shake;
  final double shakeAt;
  final ValueListenable<double> clock;
  final String Function(String key) t;
  final double scale;
  final ValueChanged<_Planet> onPick;
  final ValueChanged<_Group> onTub;
  final void Function(_Planet planet, _Group group) onDrop;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final board = LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        if (w < 120 || h < 120) return const SizedBox.shrink();
        final wide = w >= 560;
        final gap = (wide ? 28 : 10) * s;
        final tubsW = (w * 0.42)
            .clamp(math.min(150 * s, w * 0.5), 410 * s)
            .toDouble();
        final poolW = w - tubsW - gap;
        final tubH = math.min((h - 24 * s) / 2, 190 * s);
        return Row(
          children: [
            SizedBox(width: poolW, height: h, child: _pool(poolW, h)),
            SizedBox(
              width: gap,
              height: h * 0.8,
              child: wide
                  ? const CustomPaint(painter: _DashedDividerPainter())
                  : null,
            ),
            Container(
              width: tubsW,
              height: h,
              padding: EdgeInsets.only(top: 14 * s),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final g in _Group.values)
                    _tubTarget(g, tubsW - 10 * s, tubH),
                ],
              ),
            ),
          ],
        );
      },
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: t('stage_1_step_1_label'),
      hint: t('stage_1_step_1_desc'),
      child: board,
    );
  }

  Widget _pool(double w, double h) {
    final s = scale;
    final pad = 10 * s;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: const Color(0x40020617), // bg-slate-950/25
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: const Color(0x4D1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 6 * s),
            margin: EdgeInsets.only(bottom: 6 * s),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x801E293B))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8 * s,
              runSpacing: 2 * s,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, size: 14 * s, color: _Colors.indigo400),
                    SizedBox(width: 5 * s),
                    Flexible(
                      child: Text(
                        t('unsorted_planets').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _Colors.indigo300,
                          fontSize: 10.5 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(
                            t('unsorted_planets'),
                            1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  t('drag_or_click_hint'),
                  style: TextStyle(
                    color: _Colors.slate300,
                    fontSize: 9.5 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => _grid(box.maxWidth, box.maxHeight),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#sorting-planets-pool` (`flex-wrap justify-around`): the
  /// planets in a grid sized for all eight, so they keep their size as
  /// they leave.
  Widget _grid(double w, double h) {
    final s = scale;
    if (pool.isEmpty) {
      return Center(
        child: ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, time, child) => Transform.translate(
            offset: Offset(0, _bounce(time) * 24 * s),
            child: child,
          ),
          child: Text(
            t('sort_done'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Colors.emerald400,
              fontSize: 14 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }
    final nameH = 20 * s;
    var cols = 4;
    var big = 0.0;
    for (final c in const [2, 3, 4]) {
      final rows = (_Planet.values.length / c).ceil();
      final d = math.min(
        math.min(w / c - 10 * s, h / rows - nameH - 14 * s),
        80 * s,
      );
      if (d > big) {
        big = d;
        cols = c;
      }
    }
    big = math.max(big, 26);
    final rows = (_Planet.values.length / cols).ceil();
    final cellW = (w / cols).floorToDouble() - 0.5;
    final cellH = (h / rows).floorToDouble() - 0.5;
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runAlignment: WrapAlignment.spaceAround,
      children: [
        for (final p in pool)
          SizedBox(
            width: cellW,
            height: cellH,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _PoolPlanet(
                planet: p,
                name: t(p.nameKey),
                diameter: p.small ? big * 0.8 : big,
                selected: selected == p,
                scale: s,
                onPick: () => onPick(p),
              ),
            ),
          ),
      ],
    );
  }

  Widget _tubTarget(_Group g, double w, double h) {
    final s = scale;
    final planets = g == _Group.rocky ? rocky : gas;
    return Semantics(
      container: true,
      button: true,
      label: t(g.labelKey),
      excludeSemantics: true,
      onTap: () => onTub(g),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTub(g),
        child: DragTarget<_Planet>(
          onAcceptWithDetails: (d) => onDrop(d.data, g),
          builder: (context, candidates, _) => ValueListenableBuilder<double>(
            valueListenable: clock,
            builder: (context, time, _) => Transform.translate(
              offset: Offset(
                shake == g ? _shakeOffset(time - shakeAt) * s : 0,
                0,
              ),
              child: _Tub(
                group: g,
                planets: planets,
                names: {for (final p in planets) p: t(p.nameKey)},
                label: t(g.labelKey),
                sub: t(g.subKey),
                prompt: t(g.promptKey),
                badge: t(g == _Group.rocky ? 'drop_badge' : 'snap_badge'),
                width: w,
                height: h,
                hot: candidates.isNotEmpty,
                time: time,
                scale: s,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pool's vertical dashed divider (`border-r-2 border-dashed
/// border-slate-500/60`).
class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    labDashedLine(
      canvas,
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = const Color(0x9964748B)
        ..strokeWidth = 2,
      dash: 6,
      gap: 5,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter old) => false;
}

/// A pool planet (HTML `.draggable-item`): the illustrated sphere and its
/// name. Tap to pick it (it grows with an amber glow), or drag it onto a
/// tub.
class _PoolPlanet extends StatelessWidget {
  const _PoolPlanet({
    required this.planet,
    required this.name,
    required this.diameter,
    required this.selected,
    required this.scale,
    required this.onPick,
  });

  final _Planet planet;
  final String name;
  final double diameter;
  final bool selected;
  final double scale;
  final VoidCallback onPick;

  Widget _tile({bool glow = false}) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(diameter),
          painter: _PoolSpherePainter(planet, glow: glow),
        ),
        SizedBox(height: 6 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 2 * s),
          decoration: BoxDecoration(
            color: const Color(0xBF0F172A),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0x99334155)),
          ),
          child: Text(
            name,
            maxLines: 1,
            style: TextStyle(
              color: _Colors.slate100,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w800,
              height: 1.1,
              shadows: const [Shadow(color: Color(0xF2000000), blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      onTap: onPick,
      child: Draggable<_Planet>(
        data: planet,
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        // The HTML touch ghost: 85 % opaque, 1.15 times, indigo glow.
        feedback: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Material(
            type: MaterialType.transparency,
            child: Transform.scale(
              scale: 1.15,
              child: Opacity(opacity: 0.85, child: _tile(glow: true)),
            ),
          ),
        ),
        // `.dragging`: the planet left behind fades.
        childWhenDragging: Opacity(opacity: 0.4, child: _tile()),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPick,
          child: AnimatedScale(
            scale: selected ? 1.25 : 1,
            duration: const Duration(milliseconds: 200),
            child: _tile(glow: selected),
          ),
        ),
      ),
    );
  }
}

/// The pool sphere: `radial-gradient(circle at 35% 35%, colour, #020617)`
/// with an inner shadow, the Phosphor planet glyph and Saturn's ring.
class _PoolSpherePainter extends CustomPainter {
  const _PoolSpherePainter(this.planet, {this.glow = false});

  final _Planet planet;

  /// Selected (`drop-shadow(0 0 18px rgba(251, 191, 36, 0.85))`) or
  /// dragged (indigo).
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final c = size.center(Offset.zero);
    final r = d / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    if (glow) {
      canvas.drawCircle(
        c,
        r * 1.05,
        Paint()
          ..color = const Color(0xD9FBBF24)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35),
      );
    }
    // shadow-[0_8px_20px_rgba(0,0,0,0.7)].
    canvas.drawCircle(
      c + Offset(0, d * 0.1),
      r,
      Paint()
        ..color = const Color(0xB3000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, d * 0.12),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.92,
          colors: [planet.color, _Colors.slate950],
        ).createShader(rect),
    );
    // shadow-[inset_-6px_-6px_14px_rgba(0,0,0,0.7)].
    canvas
      ..save()
      ..clipPath(Path()..addOval(rect));
    canvas.drawCircle(
      c,
      r + d * 0.2,
      Paint()
        ..color = const Color(0xB3000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = d * 0.3
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, d * 0.1),
    );
    canvas.restore();
    // ph-fill ph-planet, white at 85 %.
    final glyph = Paint()..color = const Color(0xD9FFFFFF);
    canvas.drawCircle(c, d * 0.13, glyph);
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(-0.45);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: d * 0.44, height: d * 0.13),
      Paint()
        ..color = const Color(0xD9FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = d * 0.035,
    );
    canvas.restore();
    if (planet.ringed) {
      // w-[145%] h-3.5 border-[3px] border-yellow-300/80 rotate-12.
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(12 * math.pi / 180);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: d * 1.45, height: d * 0.18),
        Paint()
          ..color = const Color(0xCCFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = d * 0.04,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PoolSpherePainter old) =>
      old.planet != planet || old.glow != glow;
}

/// One flared tub (HTML `.basket-tub`): the dark oval mouth holding the
/// sorted planets (or the drop prompt), its 'Drop' / 'snap-back' badge and
/// the sloped body with the tub's name and count.
class _Tub extends StatelessWidget {
  const _Tub({
    required this.group,
    required this.planets,
    required this.names,
    required this.label,
    required this.sub,
    required this.prompt,
    required this.badge,
    required this.width,
    required this.height,
    required this.hot,
    required this.time,
    required this.scale,
  });

  final _Group group;
  final List<_Planet> planets;
  final Map<_Planet, String> names;
  final String label;
  final String sub;
  final String prompt;
  final String badge;
  final double width;
  final double height;

  /// A planet is dragged over it (`.over-correct`).
  final bool hot;
  final double time;
  final double scale;

  bool get _rocky => group == _Group.rocky;

  Color get _rim => _rocky ? _Colors.green400 : _Colors.rose400;
  Color get _soft => _rocky ? _Colors.emerald300 : _Colors.rose300;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final mouthH = height * 0.56;
    final overlap = math.min(24 * s, mouthH * 0.3);
    final bodyW = width * 0.9;
    final tub = SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (width - bodyW) / 2,
            width: bodyW,
            top: mouthH - overlap,
            bottom: 0,
            child: CustomPaint(
              painter: _TubBodyPainter(group, radius: 14 * s),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  bodyW * 0.1,
                  overlap + 4 * s,
                  bodyW * 0.1,
                  8 * s,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FittedBox(fit: BoxFit.scaleDown, child: _plate()),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: mouthH,
            child: _mouth(mouthH),
          ),
          Positioned(
            right: -8 * s,
            top: -12 * s + (_rocky ? _bounce(time) * 20 * s : 0),
            child: _badge(),
          ),
        ],
      ),
    );
    return AnimatedScale(
      scale: hot ? 1.04 : 1,
      duration: const Duration(milliseconds: 250),
      child: tub,
    );
  }

  /// `.basket-rim-mouth`: radial dark interior, 4 px rim, glow and a dark
  /// inner shadow at the top.
  Widget _mouth(double h) {
    final s = scale;
    final radius = BorderRadius.circular(math.min(46 * s, h / 2));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: RadialGradient(
          colors: [
            _rocky ? _Colors.emerald950 : _Colors.rose950,
            _Colors.slate950,
          ],
          stops: const [0, 0.88],
          radius: 0.9,
        ),
        border: Border.all(color: _rim, width: 4 * math.min(s, 1)),
        boxShadow: [
          BoxShadow(
            color: (_rocky ? _Colors.green400 : _Colors.rose400).withValues(
              alpha: hot ? 0.95 : 0.5,
            ),
            blurRadius: hot ? 30 : 25,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE6000000), Color(0x00000000)],
                  stops: [0, 0.45],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14 * s,
                vertical: 8 * s,
              ),
              child: LayoutBuilder(
                builder: (context, box) => Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: box.maxWidth,
                      child: planets.isEmpty
                          ? Text(
                              prompt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _soft.withValues(alpha: 0.7),
                                fontSize: 11 * s,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6 * s,
                              runSpacing: 5 * s,
                              children: [for (final p in planets) _chip(p)],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A sorted planet's chip (`animate-fade-in-up`).
  Widget _chip(_Planet p) {
    final s = scale;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 10 * s),
          child: child,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
        decoration: BoxDecoration(
          color: _rocky ? const Color(0xF2022C22) : const Color(0xF24C0519),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: _rocky ? _Colors.emerald400 : _Colors.rose400,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (_rocky ? _Colors.emerald400 : _Colors.rose400).withValues(
                alpha: 0.35,
              ),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: p.color, size: 13 * s),
            SizedBox(width: 5 * s),
            Text(
              names[p] ?? '',
              style: TextStyle(
                color: _rocky ? _Colors.emerald200 : _Colors.rose200,
                fontSize: 11 * s,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 'Drop' (bouncing) or 'snap-back' badge on the rim.
  Widget _badge() {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: _rocky ? const Color(0xF2022C22) : const Color(0xF24C0519),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: _rocky ? _Colors.emerald400 : _Colors.rose400,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _rocky ? Icons.subdirectory_arrow_left : Icons.undo,
            size: 12 * s,
            color: _rocky ? _Colors.emerald400 : _Colors.rose400,
          ),
          SizedBox(width: 3 * s),
          Text(
            badge,
            style: TextStyle(
              color: _soft,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  /// The name plate on the body: icon, name, description and count.
  Widget _plate() {
    final s = scale;
    final accent = _rocky ? _Colors.emerald400 : _Colors.rose400;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: _pulse(time),
            child: Icon(
              _rocky ? Icons.public : Icons.bubble_chart,
              size: 22 * s,
              color: accent,
            ),
          ),
          SizedBox(width: 9 * s),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: _Colors.white,
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: labLetterSpacing(label, 0.8),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                sub,
                style: TextStyle(
                  color: _soft,
                  fontSize: 9.5 * s,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(width: 9 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: accent),
            ),
            child: Text(
              '${planets.length}/4',
              style: TextStyle(
                color: _soft,
                fontSize: 11 * s,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `.basket-outer-body`: the sloped body (`clip-path` trapezoid, 92 % wide
/// at the bottom) with its vertical gradient and the 3 px bottom rim.
class _TubBodyPainter extends CustomPainter {
  const _TubBodyPainter(this.group, {required this.radius});

  final _Group group;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = math.min(radius, h * 0.3);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.92 + r * 0.08, h - r)
      ..quadraticBezierTo(w * 0.92, h, w * 0.92 - r, h)
      ..lineTo(w * 0.08 + r, h)
      ..quadraticBezierTo(w * 0.08, h, w * 0.08 - r * 0.08, h - r)
      ..close();
    final rocky = group == _Group.rocky;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: rocky
              ? const [
                  _Colors.emerald500,
                  _Colors.emerald700,
                  _Colors.emerald900,
                ]
              : const [_Colors.rose500, _Colors.rose700, _Colors.rose900],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = rocky ? _Colors.emerald400 : _Colors.rose400,
    );
  }

  @override
  bool shouldRepaint(covariant _TubBodyPainter old) =>
      old.group != group || old.radius != radius;
}

// -------------------------------------------------------------- orbits UI

/// HTML `#orbit-targets-bar`: one chip per orbit of the step ('#1 Orbit 1',
/// or 'Mercury ✓' once filled). Tap it with a pill picked, or drop a pill
/// on it.
class _OrbitBar extends StatelessWidget {
  const _OrbitBar({
    super.key,
    required this.orbits,
    required this.placed,
    required this.clock,
    required this.t,
    required this.scale,
    required this.onTap,
    required this.onDrop,
  });

  final List<int> orbits;
  final Map<int, _Planet> placed;
  final ValueListenable<double> clock;
  final String Function(String key) t;
  final double scale;
  final ValueChanged<int> onTap;
  final void Function(_Planet planet, int orbit) onDrop;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topRight,
      child: Container(
        padding: EdgeInsets.all(7 * s),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: _Colors.slate700),
          boxShadow: const [BoxShadow(color: LabInk.shadow, blurRadius: 16)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < orbits.length; i++) ...[
              if (i > 0) SizedBox(width: 6 * s),
              _chip(orbits[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(int n) {
    final s = scale;
    final planet = placed[n];
    final text = planet != null
        ? '${t(planet.nameKey)} ✓'
        : labFormat(t('orbit_n'), {'n': n});
    return Semantics(
      container: true,
      button: true,
      label: '#$n $text',
      excludeSemantics: true,
      onTap: () => onTap(n),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(n),
        child: DragTarget<_Planet>(
          onAcceptWithDetails: (d) => onDrop(d.data, n),
          builder: (context, candidates, _) {
            final hot = candidates.isNotEmpty;
            final chip = Container(
              constraints: BoxConstraints(minHeight: 34 * s),
              padding: EdgeInsets.symmetric(
                horizontal: 11 * s,
                vertical: 5 * s,
              ),
              decoration: BoxDecoration(
                color: planet != null
                    ? const Color(0x3310B981)
                    : const Color(0xE61E293B),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: hot
                      ? _Colors.emerald400
                      : (planet != null
                            ? const Color(0x6610B981)
                            : const Color(0x666366F1)),
                  width: hot ? 2.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * s,
                      vertical: 1 * s,
                    ),
                    decoration: BoxDecoration(
                      color: _Colors.slate900,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '#$n',
                      style: TextStyle(
                        color: _Colors.indigo300,
                        fontSize: 9.5 * s,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                  Text(
                    text,
                    style: TextStyle(
                      color: planet != null
                          ? _Colors.emerald400
                          : _Colors.white,
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
            if (planet != null) return chip;
            // `animate-pulse` on the chips still to fill.
            return ValueListenableBuilder<double>(
              valueListenable: clock,
              builder: (context, time, child) =>
                  Opacity(opacity: hot ? 1 : _pulse(time), child: child),
              child: chip,
            );
          },
        ),
      ),
    );
  }
}

/// HTML bottom pill tray: a pinging dot and the group's name ('ROCKY
/// PLANETS'), then a pill per planet still to place. The orbit hint (an
/// unused HTML text) is shown under the pills on larger screens.
class _PillTray extends StatelessWidget {
  const _PillTray({
    super.key,
    required this.title,
    required this.hint,
    required this.done,
    required this.pills,
    required this.selected,
    required this.clock,
    required this.t,
    required this.scale,
    required this.compact,
    required this.onPick,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final String title;
  final String hint;
  final String done;
  final List<_Planet> pills;
  final _Planet? selected;
  final ValueListenable<double> clock;
  final String Function(String key) t;
  final double scale;
  final bool compact;
  final ValueChanged<_Planet> onPick;
  final GestureDragUpdateCallback onDragUpdate;
  final void Function(_Planet planet, DraggableDetails details) onDragEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final heading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: (compact ? 10 : 12) * s,
          child: ValueListenableBuilder<double>(
            valueListenable: clock,
            builder: (context, time, _) =>
                CustomPaint(painter: _PingPainter(time)),
          ),
        ),
        SizedBox(width: 8 * s),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: _Colors.white,
            fontSize: (compact ? 11 : 12.5) * s,
            fontWeight: FontWeight.w900,
            letterSpacing: labLetterSpacing(title, 0.8),
          ),
        ),
      ],
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pills.isEmpty)
          Text(
            done,
            style: TextStyle(
              color: _Colors.emerald400,
              fontSize: 11.5 * s,
              fontWeight: FontWeight.w800,
            ),
          )
        else
          Wrap(
            spacing: (compact ? 6 : 8) * s,
            runSpacing: 6 * s,
            children: [for (final p in pills) _pill(p)],
          ),
        if (!compact && pills.isNotEmpty) ...[
          SizedBox(height: 5 * s),
          Text(
            hint,
            style: TextStyle(
              color: _Colors.slate400,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (compact ? 10 : 18) * s,
        vertical: (compact ? 6 : 12) * s,
      ),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular((compact ? 16 : 22) * s),
        border: Border.all(color: const Color(0xCC6366F1), width: 2),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 24),
        ],
      ),
      child: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                SizedBox(height: 5 * s),
                content,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 12 * s),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: _Colors.slate700)),
                  ),
                  child: heading,
                ),
                SizedBox(width: 12 * s),
                Flexible(child: content),
              ],
            ),
    );
  }

  Widget _pill(_Planet p) {
    final s = scale;
    final name = t(p.nameKey);
    final on = selected == p;
    Widget body({bool ghost = false}) => Container(
      constraints: BoxConstraints(minHeight: (compact ? 34 : 36) * s),
      padding: EdgeInsets.symmetric(
        horizontal: (compact ? 9 : 12) * s,
        vertical: (compact ? 3 : 5) * s,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF21E293B),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: on || ghost ? _Colors.amber400 : _Colors.slate600,
          width: 2,
        ),
        boxShadow: [
          if (on || ghost)
            const BoxShadow(color: Color(0x99FBBF24), blurRadius: 15)
          else
            const BoxShadow(color: LabInk.shadowSoft, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: p.color, size: 18 * s, mark: true),
          SizedBox(width: 7 * s),
          Text(
            name,
            style: TextStyle(
              color: _Colors.white,
              fontSize: 12 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: true,
      selected: on,
      label: name,
      excludeSemantics: true,
      onTap: () => onPick(p),
      child: Draggable<_Planet>(
        data: p,
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragUpdate: onDragUpdate,
        onDragEnd: (d) => onDragEnd(p, d),
        feedback: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Material(
            type: MaterialType.transparency,
            child: Transform.scale(
              scale: 1.15,
              child: Opacity(opacity: 0.9, child: body(ghost: true)),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: body()),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onPick(p),
          child: AnimatedScale(
            scale: on ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            child: body(),
          ),
        ),
      ),
    );
  }
}

/// Tailwind `animate-ping` behind a solid indigo dot.
class _PingPainter extends CustomPainter {
  const _PingPainter(this.time);

  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final phase = time - time.floorToDouble();
    canvas
      ..drawCircle(
        c,
        r * (1 + phase),
        Paint()
          ..color = _Colors.indigo500.withValues(alpha: 0.75 * (1 - phase)),
      )
      ..drawCircle(c, r, Paint()..color = _Colors.indigo500);
  }

  @override
  bool shouldRepaint(covariant _PingPainter old) => old.time != time;
}

/// A big gradient button with the HTML `animate-pulse-glow` (an indigo
/// glow of 15 px at 0.4 → 30 px at 0.8, every 2 s): HTML `#btn-finish-sc1`
/// ('Finish', green, [big]) and, added, 'Observe Conclusion' once the four
/// clues are solved (the HTML summary, once closed, could not be opened
/// again).
class _GlowButton extends StatelessWidget {
  const _GlowButton({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    required this.scale,
    required this.clock,
    required this.onTap,
    this.shadow,
    this.big = false,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final double scale;
  final ValueListenable<double> clock;
  final VoidCallback onTap;

  /// Coloured drop shadow (`shadow-emerald-500/60`).
  final Color? shadow;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (big ? 30 : 22) * s,
        vertical: (big ? 12 : 10) * s,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: (big ? 22 : 20) * s, color: _Colors.white),
          SizedBox(width: (big ? 10 : 8) * s),
          Text(
            label,
            style: TextStyle(
              color: _Colors.white,
              fontSize: (big ? 17 : 14) * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, t, child) {
            final glow = 0.5 - 0.5 * math.cos(t * math.pi);
            return Container(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(16 * s),
                border: Border.all(
                  color: big
                      ? const Color(0x4DFFFFFF)
                      : const Color(0x33FFFFFF),
                  width: 2,
                ),
                boxShadow: [
                  if (shadow != null)
                    BoxShadow(
                      color: shadow!,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  BoxShadow(
                    color: _Colors.indigo500.withValues(
                      alpha: 0.4 + 0.4 * glow,
                    ),
                    blurRadius: 15 + 15 * glow,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: content,
        ),
      ),
    );
  }
}

/// A planet's facts (`planetDetailsMulti`, unused by the HTML; added): the
/// HTML's 'Surface / Atmosphere:', 'Dist from Sun:' and 'Key Feature:'
/// rows.
class _FactRows extends StatelessWidget {
  const _FactRows({
    required this.planet,
    required this.t,
    required this.scale,
    this.center = false,
  });

  final _Planet planet;
  final String Function(String key) t;
  final double scale;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget row(String label, String value) => Padding(
      padding: EdgeInsets.only(top: 4 * s),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: _Colors.indigo300,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: _Colors.slate100,
          fontSize: 11 * s,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        row(t('surf_label'), t(planet.detailKey('surf'))),
        row(t('dist_label'), t(planet.detailKey('dist'))),
        row(t('feat_label'), t(planet.detailKey('feat'))),
      ],
    );
  }
}

/// The facts card of a tapped planet in Scenario 1 (added; the HTML only
/// enlarged the planet): name, type, the three fact rows and the
/// description.
class _PlanetCard extends StatelessWidget {
  const _PlanetCard({
    super.key,
    required this.planet,
    required this.t,
    required this.scale,
    required this.compact,
    required this.closeLabel,
    required this.onClose,
  });

  final _Planet planet;
  final String Function(String key) t;
  final double scale;
  final bool compact;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: (compact ? 220 : 270) * s,
      padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 6 * s, 12 * s),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0x996366F1), width: 1.5),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Dot(color: planet.color, size: 14 * s),
              SizedBox(width: 7 * s),
              Expanded(
                child: Text(
                  t(planet.nameKey),
                  style: TextStyle(
                    color: _Colors.white,
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: closeLabel,
                onPressed: onClose,
                icon: Icon(Icons.close, size: 18 * s, color: _Colors.slate300),
              ),
            ],
          ),
          Text(
            t(planet.detailKey('type')).toUpperCase(),
            style: TextStyle(
              color: _Colors.indigo300,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(t(planet.detailKey('type')), 1),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 6 * s),
            child: _FactRows(planet: planet, t: t, scale: s),
          ),
          if (!compact) ...[
            SizedBox(height: 6 * s),
            Padding(
              padding: EdgeInsets.only(right: 6 * s),
              child: Text(
                t(planet.detailKey('desc')),
                style: TextStyle(
                  color: _Colors.slate300,
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- detective UI

/// The beige clue card (HTML `.clue-bubble`): the draggable magnifying
/// glass, 'PLANET DETECTIVE CLUE 1 OF 4', the drag hint and the clue (the
/// step's action), with a pointer down to the planets.
class _ClueCard extends StatelessWidget {
  const _ClueCard({
    super.key,
    required this.badge,
    required this.hint,
    required this.text,
    required this.lensLabel,
    required this.lensTip,
    required this.lensActive,
    required this.scale,
    required this.compact,
    required this.onLensTap,
    required this.onLensDragUpdate,
    required this.onLensDragEnd,
  });

  final String badge;
  final String hint;
  final String text;
  final String lensLabel;
  final String lensTip;
  final bool lensActive;
  final double scale;
  final bool compact;
  final VoidCallback onLensTap;
  final GestureDragUpdateCallback onLensDragUpdate;
  final ValueChanged<DraggableDetails> onLensDragEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final dark = LabStyleScope.maybeOf(context)?.palette.isDark ?? true;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 720 * s),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (compact ? 9 : 13) * s,
              vertical: (compact ? 7 : 11) * s,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [_Colors.yellow200, _Colors.yellow300]
                    : const [_Colors.yellow100, _Colors.yellow200],
              ),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: _Colors.clueBorder, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _LensButton(
                  label: lensLabel,
                  tip: lensTip,
                  active: lensActive,
                  size: (compact ? 42 : 48) * s,
                  onTap: onLensTap,
                  onDragUpdate: onLensDragUpdate,
                  onDragEnd: onLensDragEnd,
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 3 * s),
                        margin: EdgeInsets.only(bottom: 4 * s),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0x4D000000)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                badge.toUpperCase(),
                                style: TextStyle(
                                  color: _Colors.black,
                                  fontSize: 10.5 * s,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: labLetterSpacing(badge, 0.8),
                                ),
                              ),
                            ),
                            if (!compact)
                              Flexible(
                                child: Text(
                                  hint,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: _Colors.black,
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        text,
                        style: TextStyle(
                          color: _Colors.black,
                          fontSize: (compact ? 11.5 : 13) * s,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // The small triangle pointing down to the planets.
          Positioned(
            left: 0,
            right: 0,
            bottom: -9 * s,
            child: Center(
              child: CustomPaint(
                size: Size(20 * s, 10 * s),
                painter: const _PointerPainter(_Colors.clueBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A downward triangle (`border-t-[10px] border-t-[#ca8a04]`).
class _PointerPainter extends CustomPainter {
  const _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PointerPainter old) => old.color != color;
}

/// HTML `#detective-lens`: the indigo magnifying glass. Tap it to make it
/// active (it gets an amber ring), or drag it onto a planet or its chip.
class _LensButton extends StatelessWidget {
  const _LensButton({
    required this.label,
    required this.tip,
    required this.active,
    required this.size,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final String label;
  final String tip;
  final bool active;
  final double size;
  final VoidCallback onTap;
  final GestureDragUpdateCallback onDragUpdate;
  final ValueChanged<DraggableDetails> onDragEnd;

  Widget _lens({bool lifted = false}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _Colors.indigo600,
      shape: BoxShape.circle,
      border: Border.all(
        color: active && !lifted ? _Colors.amber400 : _Colors.indigo300,
        width: active && !lifted ? 3 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: lifted
              ? const Color(0xCC6366F1)
              : (active ? const Color(0x99FBBF24) : const Color(0x666366F1)),
          blurRadius: lifted ? 25 : 12,
        ),
      ],
    ),
    child: CustomPaint(painter: const _LensIconPainter()),
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      hint: tip,
      excludeSemantics: true,
      onTap: onTap,
      child: Draggable<_Lens>(
        data: _Lens.glass,
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        feedback: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Transform.scale(
            scale: 1.15,
            child: Opacity(opacity: 0.9, child: _lens(lifted: true)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: _lens()),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _lens(),
        ),
      ),
    );
  }
}

/// The lens SVG: a white ring and a grey handle.
class _LensIconPainter extends CustomPainter {
  const _LensIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24 * 0.62;
    final o = Offset(size.width * 0.19, size.height * 0.19);
    final c = o + Offset(10 * u, 10 * u);
    canvas
      ..drawCircle(
        c,
        7 * u,
        Paint()
          ..color = _Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * u,
      )
      ..drawCircle(c, 5.6 * u, Paint()..color = const Color(0x33FFFFFF))
      ..drawLine(
        o + Offset(16.5 * u, 16.5 * u),
        o + Offset(21 * u, 21 * u),
        Paint()
          ..color = _Colors.slate300
          ..strokeWidth = 2.6 * u
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(covariant _LensIconPainter old) => false;
}

/// HTML Target Lineup dock: a chip per suspect planet (ticked once
/// solved). Tap a chip, or drop the lens on it.
class _TargetDock extends StatelessWidget {
  const _TargetDock({
    super.key,
    required this.label,
    required this.solved,
    required this.names,
    required this.scale,
    required this.compact,
    required this.maxWidth,
    required this.onTap,
  });

  final String label;
  final List<_Planet> solved;
  final Map<_Planet, String> names;
  final double scale;
  final bool compact;
  final double maxWidth;
  final ValueChanged<_Planet> onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search, size: 14 * s, color: _Colors.indigo400),
        SizedBox(width: 5 * s),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: _Colors.slate300,
            fontSize: 10.5 * s,
            fontWeight: FontWeight.w900,
            letterSpacing: labLetterSpacing(label, 1),
          ),
        ),
      ],
    );
    final chips = Wrap(
      spacing: (compact ? 5 : 8) * s,
      runSpacing: 6 * s,
      children: [for (final p in _clueOrder) _chip(p)],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (compact ? 8 : 16) * s,
          vertical: (compact ? 6 : 10) * s,
        ),
        decoration: BoxDecoration(
          color: _Colors.panel,
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(color: _Colors.slate700),
          boxShadow: const [
            BoxShadow(color: LabInk.shadowStrong, blurRadius: 24),
          ],
        ),
        child: compact || maxWidth < 640 * s
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  SizedBox(height: 5 * s),
                  chips,
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 12 * s),
                    margin: EdgeInsets.only(right: 12 * s),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: _Colors.slate800),
                      ),
                    ),
                    child: title,
                  ),
                  Flexible(child: chips),
                ],
              ),
      ),
    );
  }

  Widget _chip(_Planet p) {
    final s = scale;
    final done = solved.contains(p);
    final name = names[p] ?? '';
    return Semantics(
      container: true,
      button: true,
      label: name,
      excludeSemantics: true,
      onTap: () => onTap(p),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(p),
        child: DragTarget<_Lens>(
          onAcceptWithDetails: (_) => onTap(p),
          builder: (context, candidates, _) {
            final hot = candidates.isNotEmpty;
            return Container(
              constraints: BoxConstraints(minHeight: 34 * s),
              padding: EdgeInsets.symmetric(
                horizontal: (compact ? 7 : 11) * s,
                vertical: 5 * s,
              ),
              decoration: BoxDecoration(
                color: done ? const Color(0x3310B981) : _Colors.slate800,
                borderRadius: BorderRadius.circular(14 * s),
                border: Border.all(
                  color: hot
                      ? _Colors.indigo400
                      : (done ? const Color(0x8010B981) : _Colors.slate600),
                  width: hot ? 2.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(color: p.color, size: 13 * s),
                  SizedBox(width: 6 * s),
                  Text(
                    name,
                    style: TextStyle(
                      color: done ? _Colors.emerald400 : _Colors.white,
                      fontSize: 11.5 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (done) ...[
                    SizedBox(width: 4 * s),
                    Icon(Icons.check, size: 13 * s, color: _Colors.emerald400),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// HTML `#detective-scorecard` (Detective Case File): a row per clue,
/// 'Locked' until its planet is verified. On a short screen it folds to a
/// row of ticks while a planet is zoomed in on (so the planet has room).
class _CaseFile extends StatelessWidget {
  const _CaseFile({
    super.key,
    required this.title,
    required this.solved,
    required this.t,
    required this.scale,
    required this.compact,
    required this.width,
    required this.folded,
  });

  final String title;
  final List<_Planet> solved;
  final String Function(String key) t;
  final double scale;
  final bool compact;
  final double width;
  final bool folded;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final gap = (compact ? 3 : 6) * s;
    return Container(
      width: width,
      padding: EdgeInsets.all((compact ? 8 : 12) * s),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular((compact ? 16 : 22) * s),
        border: Border.all(color: const Color(0xCC6366F1), width: 2),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 4 * s),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _Colors.slate800)),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment, size: 13 * s, color: _Colors.indigo400),
                SizedBox(width: 5 * s),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _Colors.indigo400,
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title, 0.6),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * s,
                    vertical: 1 * s,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x336366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${solved.length}/4',
                    style: TextStyle(
                      color: _Colors.indigo300,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (folded) ...[
            SizedBox(height: 6 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [for (final p in _clueOrder) _tick(p)],
            ),
          ] else
            for (final p in _clueOrder) ...[SizedBox(height: gap), _row(p)],
        ],
      ),
    );
  }

  /// A folded clue: its planet's dot, with a tick once solved.
  Widget _tick(_Planet p) {
    final s = scale;
    final done = solved.contains(p);
    final clue = t('clue_${p.name}');
    return Semantics(
      label: done ? clue : '$clue, ${t('locked')}',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: done ? 1 : 0.45,
            child: _Dot(color: p.color, size: 18 * s, mark: true),
          ),
          if (done)
            Positioned(
              right: -5 * s,
              bottom: -4 * s,
              child: Icon(
                Icons.check_circle,
                size: 12 * s,
                color: _Colors.emerald400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(_Planet p) {
    final s = scale;
    final done = solved.contains(p);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: 7 * s,
        vertical: (compact ? 3 : 6) * s,
      ),
      decoration: BoxDecoration(
        color: done ? const Color(0x336366F1) : const Color(0x801E293B),
        borderRadius: BorderRadius.circular(11 * s),
        border: Border.all(
          color: done ? const Color(0x666366F1) : _Colors.slate800,
        ),
      ),
      child: Row(
        children: [
          _Dot(color: p.color, size: (compact ? 14 : 18) * s, mark: true),
          SizedBox(width: 7 * s),
          Expanded(
            child: Text(
              t('clue_${p.name}'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: done ? _Colors.white : _Colors.slate400,
                fontSize: (compact ? 10 : 11) * s,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 4 * s),
          if (done)
            Icon(Icons.check_circle, size: 14 * s, color: _Colors.emerald400)
          else
            Opacity(
              opacity: 0.5,
              child: Text(
                t('locked'),
                style: TextStyle(
                  color: _Colors.slate400,
                  fontSize: 9.5 * s,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#detective-closeup-popup` (the magnifier beam): '{p} Verified!',
/// the step's observation, the planet's facts (added) and 'Record Findings
/// & Next Clue'. Placed beside the zoomed planet (the HTML centred it over
/// the planet); its text scrolls and the button always shows.
class _CloseupCard extends StatelessWidget {
  const _CloseupCard({
    super.key,
    required this.planet,
    required this.title,
    required this.text,
    required this.button,
    required this.t,
    required this.scale,
    required this.compact,
    required this.maxWidth,
    required this.maxHeight,
    required this.onNext,
  });

  final _Planet planet;
  final String title;
  final String text;
  final String button;
  final String Function(String key) t;
  final double scale;
  final bool compact;
  final double maxWidth;
  final double maxHeight;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return TweenAnimationBuilder<double>(
      key: ValueKey('ch12a4-closeup-${planet.name}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 10 * s),
          child: child,
        ),
      ),
      child: Container(
        width: math.min(maxWidth, 400 * s),
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: EdgeInsets.all((compact ? 10 : 18) * s),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [_Colors.beamInner, _Colors.beamOuter],
            radius: 0.9,
          ),
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(color: _Colors.indigo500, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x996366F1), blurRadius: 40),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!compact) ...[
                      Container(
                        width: 52 * s,
                        height: 52 * s,
                        decoration: BoxDecoration(
                          color: const Color(0x336366F1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x666366F1)),
                        ),
                        child: Icon(
                          Icons.zoom_in,
                          size: 28 * s,
                          color: _Colors.indigo400,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                    ],
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.indigo300,
                        fontSize: (compact ? 14 : 17) * s,
                        fontWeight: FontWeight.w900,
                        letterSpacing: labLetterSpacing(title, 0.6),
                      ),
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.slate200,
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    _FactRows(planet: planet, t: t, scale: s, center: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            Semantics(
              button: true,
              label: button,
              excludeSemantics: true,
              onTap: onNext,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onNext,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: kMinInteractiveDimension,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 8 * s,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_Colors.indigo600, _Colors.indigo500],
                    ),
                    borderRadius: BorderRadius.circular(12 * s),
                    boxShadow: const [
                      BoxShadow(color: LabInk.shadow, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          button,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _Colors.white,
                            fontSize: 12.5 * s,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 6 * s),
                      Icon(
                        Icons.arrow_forward,
                        size: 16 * s,
                        color: _Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ sidebar

/// HTML `#teacher-content` steps: an accordion card per step ('Step N'
/// with a number or a tick), its Task, Action and Result when open. The
/// current step is indigo and open, done steps green; a tap opens or
/// closes a card (HTML `toggleAccordion`).
class _StepAccordion extends StatefulWidget {
  const _StepAccordion({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.taskLabel,
    required this.actionLabel,
    required this.resultLabel,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String taskLabel;
  final String actionLabel;
  final String resultLabel;

  @override
  State<_StepAccordion> createState() => _StepAccordionState();
}

class _StepAccordionState extends State<_StepAccordion> {
  /// The open cards; the widget is keyed by the step, so a new step opens
  /// just the current card again (HTML updateTeacherBoard()).
  late final Set<int> _open = {widget.current};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 9 * widget.scale),
            child: _card(i),
          ),
      ],
    );
  }

  Widget _card(int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final dark = p.isDark;
    final current = i == w.current;
    final past = i < w.current;
    final open = _open.contains(i);
    final step = w.steps[i - 1];
    final border = current
        ? _Colors.indigo500
        : (past
              ? const Color(0x8010B981)
              : (dark ? _Colors.slate800 : _Colors.slate300));
    final fill = current
        ? (dark ? _Colors.slate800 : const Color(0x1A6366F1))
        : (dark ? const Color(0x800F172A) : _Colors.slate100);
    final headColor = current
        ? p.ink(_Colors.indigo400)
        : (past
              ? (dark ? _Colors.emerald400 : _Colors.emerald600)
              : (dark ? _Colors.slate400 : _Colors.slate500));
    final badgeFill = past
        ? const Color(0x3310B981)
        : (current ? _Colors.indigo500 : _Colors.slate800);
    final badgeBorder = past
        ? const Color(0x6610B981)
        : (current ? _Colors.indigo400 : _Colors.slate600);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: current
            ? const [
                BoxShadow(color: Color(0x4D6366F1), spreadRadius: 1),
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: fill,
            child: InkWell(
              onTap: () {
                _Sound.pop.play();
                setState(() => open ? _open.remove(i) : _open.add(i));
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * s,
                    vertical: 8 * s,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20 * s,
                        height: 20 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeFill,
                          shape: BoxShape.circle,
                          border: Border.all(color: badgeBorder),
                        ),
                        child: past
                            ? Icon(
                                Icons.check,
                                size: 12 * s,
                                color: _Colors.emerald500,
                              )
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: current
                                      ? _Colors.slate950
                                      : _Colors.slate400,
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
                            color: headColor,
                            fontSize: 12 * f,
                            fontWeight: current
                                ? FontWeight.w800
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        open
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18 * s,
                        color: headColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Container(
              padding: EdgeInsets.fromLTRB(13 * s, 10 * s, 13 * s, 12 * s),
              decoration: BoxDecoration(
                color: dark ? const Color(0x660F172A) : const Color(0xFFF8FAFC),
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
                    '${w.taskLabel}:'.toUpperCase(),
                    style: TextStyle(
                      color: p.ink(_Colors.indigo500),
                      fontSize: 9.5 * f,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(w.taskLabel, 0.8),
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    step.concept,
                    style: TextStyle(
                      color: dark ? _Colors.slate200 : _Colors.slate800,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 7 * s),
                  _labelled(w.actionLabel, step.action, dark, f, muted: false),
                  SizedBox(height: 7 * s),
                  _labelled(
                    w.resultLabel,
                    step.observation,
                    dark,
                    f,
                    muted: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _labelled(
    String label,
    String text,
    bool dark,
    double f, {
    required bool muted,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: dark ? _Colors.white : _Colors.slate900,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text),
        ],
      ),
      style: TextStyle(
        color: muted
            ? (dark ? _Colors.slate400 : _Colors.slate600)
            : (dark ? _Colors.slate300 : _Colors.slate700),
        fontSize: 11.5 * f,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }
}

// ------------------------------------------------------------------- popups

/// HTML `#summary-modal` body: the lightbulb, the title, the summary's
/// bold heading and text, and (Scenario 1) the next-scenario message.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.summary,
    required this.headingColor,
    required this.next,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  /// 'Heading|text with *bold* words'.
  final String summary;
  final Color headingColor;
  final String? next;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final cut = summary.indexOf('|');
    final heading = cut < 0 ? '' : summary.substring(0, cut);
    final body = cut < 0 ? summary : summary.substring(cut + 1);
    final strong = TextStyle(color: p.textStrong, fontWeight: FontWeight.w900);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60 * s,
            height: 60 * s,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, size: 30 * s, color: p.ink(iconColor)),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 20 * s,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * s),
        if (heading.isNotEmpty) ...[
          Text(
            heading,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(headingColor),
              fontSize: 16 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
        ],
        Text.rich(
          TextSpan(children: _rich(body, strong)),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 13 * f,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
        if (next != null) ...[
          SizedBox(height: 14 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: p.isDark
                  ? const Color(0x991E1B4B)
                  : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x806366F1)),
            ),
            child: Text.rich(
              TextSpan(
                children: _rich(
                  next!,
                  const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.isDark ? _Colors.indigo200 : _Colors.indigo600,
                fontSize: 12 * f,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// HTML `#success-modal`: the bouncing trophy, 'Mastery Achieved!' and
/// its text.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.title,
    required this.text,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.clock,
  });

  final String title;
  final String text;
  final LabPalette palette;
  final double scale;
  final double fontScale;
  final ValueListenable<double> clock;

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
              color: const Color(0x33EAB308),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4DEAB308)),
            ),
            child: ValueListenableBuilder<double>(
              valueListenable: clock,
              builder: (context, t, child) => Transform.translate(
                offset: Offset(0, _bounce(t) * 30 * s),
                child: child,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 30 * s,
                color: p.ink(_Colors.yellow400),
              ),
            ),
          ),
        ),
        SizedBox(height: 14 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 20 * s,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
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

/// Size of a planet's surface map (equirectangular: longitude across,
/// latitude down).
const double _texW = 512;
const double _texH = 256;

/// The planets' surface maps (painted once, see [_SurfaceArt]) and the
/// canvas labels, laid out once and reused every frame. Owned (and
/// disposed) by the page State.
class _PaintCache {
  final Map<_Planet, ImageShader> _surfaces = {};
  final List<ui.Image> _images = [];
  final Map<String, TextPainter> _labels = {};

  /// The surface of [p] as a shader in map pixels.
  ImageShader surface(_Planet p) => _surfaces[p] ??= _paintSurface(p);

  ImageShader _paintSurface(_Planet p) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _texW, _texH));
    _SurfaceArt.paint(canvas, p);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(_texW.toInt(), _texH.toInt());
    picture.dispose();
    _images.add(image);
    return ImageShader(
      image,
      TileMode.repeated,
      TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: FilterQuality.medium,
    );
  }

  /// A `.planet-label` text (11 px, extra bold, white) at [size].
  TextPainter label(String text, double size) {
    final key = '$text|${size.toStringAsFixed(2)}';
    return _labels[key] ??= TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void dispose() {
    for (final image in _images) {
      image.dispose();
    }
    _images.clear();
    _surfaces.clear();
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }
}

/// The planets' surfaces. The HTML meshes are flat-coloured spheres
/// (`MeshLambertMaterial`); each map keeps that colour as its base and adds
/// what the lab's texts describe: Mercury's craters, Venus's thick cloud
/// bands, Earth's oceans, land, ice caps and swirling white clouds, Mars's
/// red iron-oxide deserts, dark plains, craters, canyon, Olympus Mons and
/// ice caps, Jupiter's bands and Great Red Spot, Saturn's soft bands,
/// Uranus's pale haze and Neptune's dark storm and white clouds.
abstract final class _SurfaceArt {
  static const Rect _all = Rect.fromLTWH(0, 0, _texW, _texH);

  static void paint(Canvas c, _Planet p) {
    final rnd = math.Random(17 + p.index * 31);
    c.drawRect(_all, Paint()..color = p.color);
    switch (p) {
      case _Planet.mercury:
        _mercury(c, rnd);
      case _Planet.venus:
        _venus(c, rnd);
      case _Planet.earth:
        _earth(c, rnd);
      case _Planet.mars:
        _mars(c, rnd);
      case _Planet.jupiter:
        _jupiter(c, rnd);
      case _Planet.saturn:
        _saturn(c, rnd);
      case _Planet.uranus:
        _uranus(c, rnd);
      case _Planet.neptune:
        _neptune(c, rnd);
    }
  }

  static Paint _fill(Color color, [double blur = 0]) {
    final paint = Paint()..color = color;
    if (blur > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    return paint;
  }

  /// An oval at ([x], [y]) drawn again across the map's seam, widened by
  /// 1 / cos(latitude) so it looks round on the globe.
  static void _spot(
    Canvas c,
    double x,
    double y,
    double rx,
    double ry,
    Paint paint,
  ) {
    final lat = (0.5 - y / _texH) * math.pi;
    final k = 1 / math.max(math.cos(lat), 0.3);
    for (final dx in const [-_texW, 0.0, _texW]) {
      c.drawOval(
        Rect.fromCenter(
          center: Offset(x + dx, y),
          width: 2 * rx * k,
          height: 2 * ry,
        ),
        paint,
      );
    }
  }

  /// A crater: dark floor, bright rim on the upper left.
  static void _crater(Canvas c, double x, double y, double r, Color floor) {
    _spot(c, x + r * 0.12, y + r * 0.12, r * 0.8, r * 0.8, _fill(floor, 1));
    final lat = (0.5 - y / _texH) * math.pi;
    final k = 1 / math.max(math.cos(lat), 0.3);
    for (final dx in const [-_texW, 0.0, _texW]) {
      c.drawArc(
        Rect.fromCenter(
          center: Offset(x + dx, y),
          width: 2 * r * k,
          height: 2 * r,
        ),
        math.pi * 0.8,
        math.pi * 1.1,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, r * 0.3)
          ..color = const Color(0x55FFF7ED)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
      );
    }
  }

  /// A band of latitude between [y0] and [y1] with wavy edges that meet
  /// across the seam.
  static void _band(
    Canvas c,
    double y0,
    double y1,
    Paint paint, {
    double wave = 3,
    int cycles = 3,
    double phase = 0,
  }) {
    final path = Path();
    const step = 8.0;
    path.moveTo(-step, y0);
    for (var x = -step; x <= _texW + step; x += step) {
      final a = 2 * math.pi * cycles * x / _texW + phase;
      path.lineTo(x, y0 + wave * math.sin(a));
    }
    for (var x = _texW + step; x >= -step; x -= step) {
      final a = 2 * math.pi * (cycles + 1) * x / _texW + phase * 1.7;
      path.lineTo(x, y1 + wave * math.sin(a));
    }
    path.close();
    c.drawPath(path, paint);
  }

  /// An irregular blob (land, dark plains) round ([cx], [cy]).
  static Path _blob(
    math.Random rnd,
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    final path = Path();
    const n = 20;
    final wobble = [for (var i = 0; i < n; i++) 0.72 + 0.5 * rnd.nextDouble()];
    for (var i = 0; i <= n; i++) {
      final a = i / n * 2 * math.pi;
      final k = (wobble[i % n] + wobble[(i + 1) % n]) / 2;
      final p = Offset(cx + math.cos(a) * rx * k, cy + math.sin(a) * ry * k);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  static void _blobs(
    Canvas c,
    math.Random rnd,
    double cx,
    double cy,
    double rx,
    double ry,
    Paint paint,
  ) {
    for (final dx in const [-_texW, 0.0, _texW]) {
      c.drawPath(_blob(rnd, cx + dx, cy, rx, ry), paint);
    }
  }

  /// Ice cap: the map's top (or bottom) rows to a wavy edge.
  static void _cap(Canvas c, double depth, {required bool north}) {
    final path = Path();
    final edge = north ? depth : _texH - depth;
    path.moveTo(0, north ? 0 : _texH);
    for (var x = 0.0; x <= _texW; x += 8) {
      final a = 2 * math.pi * 5 * x / _texW;
      path.lineTo(x, edge + depth * 0.22 * math.sin(a) * (north ? 1 : -1));
    }
    path
      ..lineTo(_texW, north ? 0 : _texH)
      ..close();
    c.drawPath(path, _fill(const Color(0xF2F8FAFC), 2));
  }

  static void _mercury(Canvas c, math.Random rnd) {
    for (var i = 0; i < 150; i++) {
      final dark = rnd.nextBool();
      _spot(
        c,
        rnd.nextDouble() * _texW,
        rnd.nextDouble() * _texH,
        8 + rnd.nextDouble() * 30,
        8 + rnd.nextDouble() * 22,
        _fill(dark ? const Color(0x2E57534E) : const Color(0x33E7E5E4), 7),
      );
    }
    for (var i = 0; i < 120; i++) {
      final r = 2 + math.pow(rnd.nextDouble(), 2) * 13;
      _crater(
        c,
        rnd.nextDouble() * _texW,
        _texH * (0.08 + 0.84 * rnd.nextDouble()),
        r.toDouble(),
        const Color(0x6629241F),
      );
    }
  }

  static void _venus(Canvas c, math.Random rnd) {
    c.drawRect(
      _all,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99CA8A04), Color(0x00000000), Color(0x99CA8A04)],
        ).createShader(_all),
    );
    for (var i = 0; i < 70; i++) {
      final light = rnd.nextBool();
      final y = rnd.nextDouble() * _texH;
      final h = 3 + rnd.nextDouble() * 10;
      _band(
        c,
        y,
        y + h,
        _fill(light ? const Color(0x73FEF9C3) : const Color(0x40CA8A04), 4),
        wave: 2 + rnd.nextDouble() * 6,
        cycles: 1 + rnd.nextInt(3),
        phase: rnd.nextDouble() * 6,
      );
    }
    // The 'Y' shaped cloud pattern of the upper atmosphere.
    for (var i = 0; i < 4; i++) {
      final x = (i + rnd.nextDouble() * 0.5) * _texW / 4;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x4DFFFBEB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      c
        ..drawLine(Offset(x, _texH * 0.5), Offset(x + 70, _texH * 0.3), paint)
        ..drawLine(Offset(x, _texH * 0.5), Offset(x + 70, _texH * 0.7), paint);
    }
  }

  static void _earth(Canvas c, math.Random rnd) {
    c.drawRect(
      _all,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ).createShader(_all),
    );
    for (var i = 0; i < 40; i++) {
      _spot(
        c,
        rnd.nextDouble() * _texW,
        rnd.nextDouble() * _texH,
        12 + rnd.nextDouble() * 30,
        8 + rnd.nextDouble() * 16,
        _fill(
          rnd.nextBool() ? const Color(0x332563EB) : const Color(0x2660A5FA),
          8,
        ),
      );
    }
    const land = Color(0xFF15803D);
    const lands = [
      (0.20, 0.30, 0.085, 0.12), // North America
      (0.29, 0.63, 0.045, 0.13), // South America
      (0.37, 0.12, 0.04, 0.05), // Greenland
      (0.52, 0.27, 0.05, 0.06), // Europe
      (0.54, 0.53, 0.065, 0.13), // Africa
      (0.70, 0.29, 0.14, 0.11), // Asia
      (0.69, 0.43, 0.03, 0.05), // India
      (0.86, 0.66, 0.055, 0.05), // Australia
    ];
    for (final (x, y, rx, ry) in lands) {
      _blobs(
        c,
        rnd,
        x * _texW,
        y * _texH,
        rx * _texW,
        ry * _texH,
        _fill(land, 1.5),
      );
    }
    const deserts = [
      (0.53, 0.41, 0.05, 0.04),
      (0.60, 0.42, 0.02, 0.03),
      (0.86, 0.66, 0.03, 0.025),
      (0.72, 0.32, 0.04, 0.02),
      (0.20, 0.36, 0.025, 0.03),
    ];
    for (final (x, y, rx, ry) in deserts) {
      _blobs(
        c,
        rnd,
        x * _texW,
        y * _texH,
        rx * _texW,
        ry * _texH,
        _fill(const Color(0xB3CA8A04), 3),
      );
    }
    for (var i = 0; i < 20; i++) {
      _spot(
        c,
        rnd.nextDouble() * _texW,
        _texH * (0.2 + 0.5 * rnd.nextDouble()),
        6 + rnd.nextDouble() * 10,
        4 + rnd.nextDouble() * 6,
        _fill(const Color(0x40166534), 4),
      );
    }
    _cap(c, _texH * 0.07, north: true);
    _cap(c, _texH * 0.09, north: false);
    // Swirling white clouds.
    for (var i = 0; i < 60; i++) {
      final y = rnd.nextDouble() * _texH;
      final x = rnd.nextDouble() * _texW;
      final len = 30 + rnd.nextDouble() * 90;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2 + rnd.nextDouble() * 6
        ..color = Color.fromARGB((110 + rnd.nextInt(110)), 255, 255, 255)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      for (final dx in const [-_texW, 0.0, _texW]) {
        final path = Path()..moveTo(x + dx, y);
        for (var k = 1; k <= 8; k++) {
          final px = x + dx + len * k / 8;
          path.lineTo(px, y + 6 * math.sin(k / 8 * math.pi * 2 + y));
        }
        c.drawPath(path, paint);
      }
    }
    // Cyclones.
    for (var i = 0; i < 3; i++) {
      final x = rnd.nextDouble() * _texW;
      final y = _texH * (0.25 + 0.5 * rnd.nextDouble());
      for (var k = 0; k < 4; k++) {
        final r = 5.0 + k * 5;
        for (final dx in const [-_texW, 0.0, _texW]) {
          c.drawArc(
            Rect.fromCircle(center: Offset(x + dx, y), radius: r),
            k * 1.3,
            math.pi * 1.2,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color(0xB3FFFFFF)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
          );
        }
      }
    }
  }

  static void _mars(Canvas c, math.Random rnd) {
    for (var i = 0; i < 70; i++) {
      final orange = rnd.nextDouble() < 0.45;
      _spot(
        c,
        rnd.nextDouble() * _texW,
        rnd.nextDouble() * _texH,
        14 + rnd.nextDouble() * 40,
        10 + rnd.nextDouble() * 24,
        _fill(orange ? const Color(0x40F97316) : const Color(0x40B91C1C), 12),
      );
    }
    // Dark plains (Syrtis Major and the southern highlands).
    const plains = [
      (0.62, 0.45, 0.06, 0.09),
      (0.28, 0.58, 0.13, 0.05),
      (0.80, 0.62, 0.09, 0.05),
      (0.05, 0.52, 0.05, 0.06),
    ];
    for (final (x, y, rx, ry) in plains) {
      _blobs(
        c,
        rnd,
        x * _texW,
        y * _texH,
        rx * _texW,
        ry * _texH,
        _fill(const Color(0x737F1D1D), 7),
      );
    }
    for (var i = 0; i < 70; i++) {
      final r = 1.5 + math.pow(rnd.nextDouble(), 2) * 9;
      _crater(
        c,
        rnd.nextDouble() * _texW,
        _texH * (0.12 + 0.76 * rnd.nextDouble()),
        r.toDouble(),
        const Color(0x597F1D1D),
      );
    }
    // Valles Marineris.
    final canyon = Path()..moveTo(_texW * 0.30, _texH * 0.53);
    for (var k = 1; k <= 12; k++) {
      canyon.lineTo(
        _texW * (0.30 + 0.18 * k / 12),
        _texH * (0.53 + 0.02 * math.sin(k * 1.7)),
      );
    }
    c
      ..drawPath(
        canyon,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0x40FCA5A5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..drawPath(
        canyon,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xCC7F1D1D),
      );
    // Olympus Mons.
    _spot(
      c,
      _texW * 0.14,
      _texH * 0.42,
      11,
      11,
      _fill(const Color(0x66FCA5A5), 2),
    );
    _spot(
      c,
      _texW * 0.14,
      _texH * 0.42,
      4,
      4,
      _fill(const Color(0x997F1D1D), 1),
    );
    _cap(c, _texH * 0.085, north: true);
    _cap(c, _texH * 0.055, north: false);
  }

  static void _jupiter(Canvas c, math.Random rnd) {
    const bands = [
      (0.00, 0.08, Color(0xFF9A3412)),
      (0.08, 0.18, Color(0xFFFDBA74)),
      (0.18, 0.26, Color(0xFFC2410C)),
      (0.26, 0.40, Color(0xFFFED7AA)),
      (0.40, 0.47, Color(0xFFC2410C)),
      (0.47, 0.54, Color(0xFFFFEDD5)),
      (0.54, 0.62, Color(0xFFB45309)),
      (0.62, 0.72, Color(0xFFFDBA74)),
      (0.72, 0.80, Color(0xFFC2410C)),
      (0.80, 0.92, Color(0xFFFB923C)),
      (0.92, 1.00, Color(0xFF9A3412)),
    ];
    for (final (y0, y1, color) in bands) {
      _band(
        c,
        y0 * _texH,
        y1 * _texH,
        _fill(color.withValues(alpha: 0.8), 2.5),
        wave: 2.5,
        cycles: 4 + rnd.nextInt(3),
        phase: rnd.nextDouble() * 6,
      );
    }
    // Turbulence along the belts.
    for (var i = 0; i < 90; i++) {
      final y = bands[1 + rnd.nextInt(bands.length - 2)].$1 * _texH;
      _spot(
        c,
        rnd.nextDouble() * _texW,
        y + (rnd.nextDouble() - 0.5) * 6,
        4 + rnd.nextDouble() * 9,
        1.5 + rnd.nextDouble() * 2.5,
        _fill(
          rnd.nextBool() ? const Color(0x59FFF7ED) : const Color(0x597C2D12),
          1.5,
        ),
      );
    }
    // The Great Red Spot (22° south).
    final gx = _texW * 0.30;
    final gy = _texH * 0.622;
    _spot(c, gx, gy, 30, 15, _fill(const Color(0x80FECACA), 3));
    _spot(c, gx, gy, 25, 12, _fill(const Color(0xFFB91C1C), 2));
    _spot(c, gx + 2, gy, 13, 6, _fill(const Color(0x997F1D1D), 2));
  }

  static void _saturn(Canvas c, math.Random rnd) {
    const bands = [
      (0.00, 0.10, Color(0x8CA16207)),
      (0.10, 0.20, Color(0x59CA8A04)),
      (0.20, 0.30, Color(0x59FDE047)),
      (0.30, 0.38, Color(0x59EAB308)),
      (0.38, 0.62, Color(0x40FEF08A)),
      (0.62, 0.70, Color(0x59EAB308)),
      (0.70, 0.80, Color(0x4DFDE047)),
      (0.80, 0.90, Color(0x59CA8A04)),
      (0.90, 1.00, Color(0x80A16207)),
    ];
    for (final (y0, y1, color) in bands) {
      _band(
        c,
        y0 * _texH,
        y1 * _texH,
        _fill(color, 4),
        wave: 1.5,
        cycles: 2 + rnd.nextInt(3),
        phase: rnd.nextDouble() * 6,
      );
    }
  }

  static void _uranus(Canvas c, math.Random rnd) {
    const bands = [
      (0.00, 0.16, Color(0x66A5F3FC)),
      (0.30, 0.44, Color(0x2606B6D4)),
      (0.56, 0.70, Color(0x2606B6D4)),
      (0.84, 1.00, Color(0x400891B2)),
    ];
    for (final (y0, y1, color) in bands) {
      _band(c, y0 * _texH, y1 * _texH, _fill(color, 8), wave: 1);
    }
    for (var i = 0; i < 6; i++) {
      _spot(
        c,
        rnd.nextDouble() * _texW,
        _texH * (0.2 + 0.3 * rnd.nextDouble()),
        8 + rnd.nextDouble() * 10,
        2,
        _fill(const Color(0x40ECFEFF), 2),
      );
    }
  }

  static void _neptune(Canvas c, math.Random rnd) {
    const bands = [
      (0.00, 0.12, Color(0x801E3A8A)),
      (0.20, 0.30, Color(0x591D4ED8)),
      (0.45, 0.55, Color(0x3360A5FA)),
      (0.65, 0.75, Color(0x591D4ED8)),
      (0.88, 1.00, Color(0x801E3A8A)),
    ];
    for (final (y0, y1, color) in bands) {
      _band(
        c,
        y0 * _texH,
        y1 * _texH,
        _fill(color, 5),
        wave: 2,
        phase: rnd.nextDouble() * 6,
      );
    }
    // The Great Dark Spot and its white companion clouds.
    _spot(
      c,
      _texW * 0.40,
      _texH * 0.61,
      22,
      12,
      _fill(const Color(0xD91E3A8A), 2),
    );
    _spot(
      c,
      _texW * 0.45,
      _texH * 0.565,
      16,
      2.5,
      _fill(const Color(0xCCE0F2FE), 1.5),
    );
    _spot(
      c,
      _texW * 0.60,
      _texH * 0.72,
      10,
      2.5,
      _fill(const Color(0xB3E0F2FE), 1.5),
    );
    _spot(
      c,
      _texW * 0.66,
      _texH * 0.78,
      7,
      4,
      _fill(const Color(0xB31E3A8A), 1.5),
    );
    for (var i = 0; i < 8; i++) {
      _spot(
        c,
        rnd.nextDouble() * _texW,
        _texH * (0.25 + 0.5 * rnd.nextDouble()),
        10 + rnd.nextDouble() * 18,
        1.8,
        _fill(const Color(0x80F0F9FF), 1.5),
      );
    }
  }
}

/// The Three.js scene, redrawn in 2D through the camera and the framed
/// picture: starfield, orbit lines, the asteroid zone, the Sun, the lit and
/// turning planets with Saturn's ring, their glows, and the planet labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.showLabels,
    required this.names,
    required this.sunName,
    required this.labelSize,
    required this.onePx,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool showLabels;
  final Map<_Planet, String> names;
  final String sunName;

  /// Label text size (design px) and one screen pixel in design px.
  final double labelSize;
  final double onePx;

  /// Scenario 2 light: the Sun is not drawn there, so the planets are lit
  /// from the front-left (added).
  static final _V _frontLight = const _V(-0.45, 0.4, 0.8).unit;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    canvas.drawRect(labBleed(size), Paint()..color = _Colors.night);
    _stars(canvas, size);
    if (s.scenario == 0) {
      _solarSystem(canvas);
    } else {
      _lineup(canvas);
    }
  }

  // ------------------------------------------------------------- starfield

  /// HTML `bgStarsGeom`: 1600 points (0x94a3b8 at 0.6), drawn at infinity
  /// through the camera's turn, about the size of the HTML points.
  void _stars(Canvas canvas, Size size) {
    final s = scene;
    final cam = s.cam;
    final k = s.htmlK;
    final bleed = labBleed(size);
    final bright = <double>[];
    final dim = <double>[];
    for (final (dir, glow) in _starDirs) {
      final uv = cam.sky(dir);
      if (uv == null) continue;
      final p = Offset(
        _designCenter.dx + uv.dx * k,
        _designCenter.dy - uv.dy * k,
      );
      if (!bleed.contains(p)) continue;
      (glow > 0.72 ? bright : dim)
        ..add(p.dx)
        ..add(p.dy);
    }
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = _Colors.star;
    canvas
      ..drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(dim),
        paint..strokeWidth = 1.5 * onePx,
      )
      ..drawRawPoints(
        ui.PointMode.points,
        Float32List.fromList(bright),
        paint
          ..strokeWidth = 2.2 * onePx
          ..color = const Color(0xB3CBD5E1),
      );
  }

  // ------------------------------------------------------------ scenario 1

  void _solarSystem(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    final view = s.view;
    final sunDepth = cam.depth(_V.zero);
    final bodies = [
      for (final b in s.bodies)
        if (b.visible) (b, cam.depth(b.position)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    _orbits(canvas, front: false);
    _belt(canvas, front: false);
    for (final (b, d) in bodies) {
      if (d > sunDepth) _planet(canvas, b);
    }
    final sunUv = cam.uv(_V.zero);
    if (sunUv != null) {
      final r = _Cam.radiusAt(_sunRadius, sunDepth) * view.k;
      _sun(canvas, view.map(sunUv), r);
    }
    _orbits(canvas, front: true);
    _belt(canvas, front: true);
    for (final (b, d) in bodies) {
      if (d <= sunDepth) _planet(canvas, b);
    }
    if (!showLabels) return;
    if (sunUv != null && s.step > 1) {
      final r = _Cam.radiusAt(_sunRadius, sunDepth) * view.k;
      _label(
        canvas,
        sunName,
        view.map(sunUv) - Offset(0, r + _labelGap * onePx),
      );
    }
    _planetLabels(canvas);
  }

  /// The orbit lines (HTML `THREE.Line`, 64 segments): the back half
  /// behind the Sun, the front half over it. The step's orbits glow; the
  /// one under a dragged pill turns green; a filled one flashes.
  void _orbits(Canvas canvas, {required bool front}) {
    final s = scene;
    final cam = s.cam;
    final view = s.view;
    final sunDepth = cam.depth(_V.zero);
    for (var n = 1; n <= 8; n++) {
      final look = s.orbitLook(n);
      if (look == null) continue;
      final (color, opacity) = look;
      final d = _Planet.ofOrbit(n).dist;
      final path = Path();
      Offset? last;
      for (var i = 0; i <= 128; i++) {
        final a = i / 128 * 2 * math.pi;
        final at = _V(math.cos(a) * d, 0, math.sin(a) * d);
        final uv = cam.uv(at);
        if (uv == null) {
          last = null;
          continue;
        }
        final p = view.map(uv);
        final mid = i == 0 ? 0 : (i - 0.5) / 128 * 2 * math.pi;
        final midDepth = cam.depth(_V(math.cos(mid) * d, 0, math.sin(mid) * d));
        final isFront = midDepth <= sunDepth;
        if (last != null && isFront == front) {
          path
            ..moveTo(last.dx, last.dy)
            ..lineTo(p.dx, p.dy);
        }
        last = p;
      }
      final hover = s.hoverOrbit == n;
      final target = color == _Colors.orbitTarget;
      final flash = s.placed.containsKey(n)
          ? 1 - (s.time - s.body(_Planet.ofOrbit(n)).flashAt) / _flashSeconds
          : 0.0;
      if (hover || target || flash > 0) {
        final glowColor = hover || flash > 0
            ? _Colors.emerald400
            : _Colors.indigo500;
        final glow = hover ? 0.5 : (flash > 0 ? 0.7 * flash : 0.22);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth =
                (hover ? 9 : (flash > 0 ? 6 + 6 * flash : 6)) * onePx
            ..color = glowColor.withValues(alpha: glow)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * onePx),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (hover ? 2.6 : 1.4) * onePx
          ..color = hover
              ? _Colors.emerald400
              : color.withValues(alpha: opacity),
      );
    }
  }

  /// The asteroid zone between Mars and Jupiter (added, step 4).
  void _belt(Canvas canvas, {required bool front}) {
    final s = scene;
    if (s.step != _stepCount) return;
    final fade = ((s.time - s.beltSince) / 1.2).clamp(0.0, 1.0);
    if (fade <= 0) return;
    final cam = s.cam;
    final view = s.view;
    final sunDepth = cam.depth(_V.zero);
    final paint = Paint()
      ..color = _Colors.asteroid.withValues(alpha: 0.85 * fade);
    for (final (a0, r, y, size) in _asteroids) {
      final a = a0 + s.beltAngle;
      final at = _V(math.cos(a) * r, y, math.sin(a) * r);
      final depth = cam.depth(at);
      if ((depth <= sunDepth) != front) continue;
      final uv = cam.uv(at);
      if (uv == null) continue;
      final px = (_Cam.radiusAt(0.16 * size, depth) * view.k).clamp(
        0.6 * onePx,
        2.4 * onePx,
      );
      canvas.drawCircle(view.map(uv), px, paint);
    }
  }

  /// The Sun (`MeshBasicMaterial` 0xf59e0b, unlit) with a soft glow
  /// (added).
  void _sun(Canvas canvas, Offset c, double r) {
    if (r <= 0.2) return;
    labGlow(canvas, c, r * 2.3, _Colors.sunGlow, intensity: 0.5);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFCD34D), _Colors.sun, Color(0xFFEA8A07)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  // ------------------------------------------------------------ scenario 2

  void _lineup(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    final bodies = [
      for (final b in s.bodies)
        if (b.visible) (b, cam.depth(b.position)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final (b, _) in bodies) {
      _planet(canvas, b);
    }
    if (showLabels) _planetLabels(canvas);
  }

  // --------------------------------------------------------------- planets

  /// One planet: its glow, the back of Saturn's ring, the lit and turning
  /// globe, the front of the ring and the lens ring.
  void _planet(Canvas canvas, _Body b) {
    final s = scene;
    final cam = s.cam;
    final view = s.view;
    final p = b.planet;
    final at = b.position;
    final uv = cam.uv(at);
    if (uv == null) return;
    final depth = cam.depth(at);
    final r = _Cam.radiusAt(p.size * b.scale.at(s.time), depth) * view.k;
    if (r < 0.25) return;
    final c = view.map(uv);
    // The planet's own view axes (the HTML perspective, per planet).
    final w = (cam.eye - at).unit;
    final side = _V.up.cross(w);
    final right = side.length < 1e-6 ? cam.r : side.unit;
    final up = w.cross(right);
    final light = s.scenario == 0 ? (at * -1).unit : _frontLight;

    final verified = s.scenario == 1 && b.scale.to == _verifiedScale;
    final pulse = 0.85 + 0.15 * math.sin(s.time * 3);
    if (verified) {
      final (color, size, strength) = switch (p) {
        _Planet.venus => (const Color(0xFFFEF9C3), 3.2, 1.25),
        _Planet.mars => (const Color(0xFFFB923C), 2.4, 0.9),
        _Planet.earth => (const Color(0xFF60A5FA), 2.2, 0.75),
        _ => (const Color(0xFFFDE047), 2.0, 0.7),
      };
      labGlow(canvas, c, r * size, color, intensity: strength * pulse);
    }
    final flash = s.scenario == 0
        ? 1 - (s.time - b.flashAt) / _flashSeconds
        : 0.0;
    if (flash > 0) {
      labGlow(canvas, c, r * 3, _Colors.emerald400, intensity: flash);
    }
    final ringGlow = verified && p.ringed ? pulse : 0.0;
    if (p.ringed) {
      _ring(
        canvas,
        c,
        r,
        b.spin,
        w,
        right,
        up,
        light,
        front: false,
        glow: ringGlow,
      );
    }
    _globe(canvas, p, c, r, b.spin, w, right, up, light);
    if (p.ringed) {
      _ring(
        canvas,
        c,
        r,
        b.spin,
        w,
        right,
        up,
        light,
        front: true,
        glow: ringGlow,
      );
    }
    if (s.hoverPlanet == p) {
      canvas
        ..drawCircle(
          c,
          r * (p.ringed ? 2.4 : 1.35) + 4 * onePx,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6 * onePx
            ..color = const Color(0x666366F1)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * onePx),
        )
        ..drawCircle(
          c,
          r * (p.ringed ? 2.4 : 1.35) + 4 * onePx,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * onePx
            ..color = _Colors.indigo400,
        );
    }
  }

  /// The globe: the surface map wrapped on a sphere mesh (turned by the
  /// mesh's `rotation.y`), then Lambert shading from [light] (the Sun's
  /// PointLight, with the 0x334155 ambient on the night side).
  void _globe(
    Canvas canvas,
    _Planet p,
    Offset c,
    double r,
    double spin,
    _V w,
    _V right,
    _V up,
    _V light,
  ) {
    final circle = Rect.fromCircle(center: c, radius: r);
    if (r < 1.2) {
      canvas.drawCircle(c, r, Paint()..color = p.color);
      return;
    }
    final cols = r > 90 ? 64 : (r > 40 ? 44 : (r > 14 ? 28 : 16));
    final rows = cols ~/ 2;
    final n = (rows + 1) * (cols + 1);
    final pos = List<Offset>.filled(n, Offset.zero);
    final tex = List<Offset>.filled(n, Offset.zero);
    final shade = List<Color>.filled(n, LabInk.clear);
    final facing = List<double>.filled(n, 0);
    final ambient = scene.scenario == 0 ? 0.14 : 0.3;
    final diffuse = scene.scenario == 0 ? 1.55 : 1.05;
    var k = 0;
    for (var j = 0; j <= rows; j++) {
      final lat = math.pi / 2 - math.pi * j / rows;
      final cl = math.cos(lat);
      final sl = math.sin(lat);
      for (var i = 0; i <= cols; i++, k++) {
        final lon = 2 * math.pi * i / cols + spin;
        final nx = cl * math.sin(lon);
        final ny = sl;
        final nz = cl * math.cos(lon);
        var x = nx * right.x + ny * right.y + nz * right.z;
        var y = nx * up.x + ny * up.y + nz * up.z;
        final f = nx * w.x + ny * w.y + nz * w.z;
        if (f < 0) {
          // Behind the limb: pinned to the outline.
          final l = math.sqrt(x * x + y * y);
          if (l > 1e-6) {
            x /= l;
            y /= l;
          }
        }
        pos[k] = Offset(c.dx + x * r, c.dy - y * r);
        tex[k] = Offset(i / cols * _texW, j / rows * _texH);
        facing[k] = f;
        final lambert = math.max(
          0.0,
          nx * light.x + ny * light.y + nz * light.z,
        );
        final lit = (ambient + diffuse * lambert).clamp(0.0, 1.0);
        shade[k] = Color.fromARGB(((1 - lit) * 236).round(), 2, 4, 12);
      }
    }
    final idx = <int>[];
    for (var j = 0; j < rows; j++) {
      for (var i = 0; i < cols; i++) {
        final a = j * (cols + 1) + i;
        final b = a + 1;
        final d = a + cols + 1;
        final e = d + 1;
        final most = math.max(
          math.max(facing[a], facing[b]),
          math.max(facing[d], facing[e]),
        );
        if (most < -0.02) continue;
        idx.addAll([a, b, e, a, e, d]);
      }
    }
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle));
    canvas.drawCircle(c, r, Paint()..color = _Colors.ambient);
    final surface = ui.Vertices(
      ui.VertexMode.triangles,
      pos,
      textureCoordinates: tex,
      indices: idx,
    );
    canvas.drawVertices(
      surface,
      BlendMode.srcOver,
      Paint()..shader = cache.surface(p),
    );
    surface.dispose();
    final shadow = ui.Vertices(
      ui.VertexMode.triangles,
      pos,
      colors: shade,
      indices: idx,
    );
    canvas.drawVertices(shadow, BlendMode.dst, Paint());
    shadow.dispose();
    canvas.restore();
    // Thin atmospheres (added): Earth's blue rim, Venus's pale haze.
    final haze = switch (p) {
      _Planet.earth => const Color(0x7360A5FA),
      _Planet.venus => const Color(0x59FEF9C3),
      _ => null,
    };
    if (haze != null && r > 3) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2 * onePx, r * 0.06)
          ..color = haze
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04 + onePx),
      );
    }
  }

  /// Half of Saturn's ring (`RingGeometry(1.3, 2.3)` × size, opacity 0.7,
  /// lit on both sides): its C, B and A rings and the Cassini division,
  /// turned by `rotation.x = PI / 3` and the planet's spin. [front] picks
  /// the half nearer the camera.
  void _ring(
    Canvas canvas,
    Offset c,
    double r,
    double spin,
    _V w,
    _V right,
    _V up,
    _V light, {
    required bool front,
    double glow = 0,
  }) {
    final st = math.sin(_ringTilt);
    final ct = math.cos(_ringTilt);
    final cs = math.cos(spin);
    final sn = math.sin(spin);
    final uR = _V(cs, 0, -sn);
    final vR = _V(st * sn, ct, st * cs);
    final normal = _V(ct * sn, -st, ct * cs);
    final beta = math.atan2(vR.dot(w), uR.dot(w));
    final from = front ? beta - math.pi / 2 : beta + math.pi / 2;
    final lit = (0.32 + 0.95 * normal.dot(light).abs()).clamp(0.0, 1.0);
    Offset at(double rho, double phi) {
      final p = uR * (rho * math.cos(phi)) + vR * (rho * math.sin(phi));
      return Offset(c.dx + p.dot(right) * r, c.dy - p.dot(up) * r);
    }

    Path band(double inner, double outer) {
      final path = Path();
      const steps = 28;
      for (var i = 0; i <= steps; i++) {
        final p = at(outer, from + math.pi * i / steps);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      for (var i = steps; i >= 0; i--) {
        final p = at(inner, from + math.pi * i / steps);
        path.lineTo(p.dx, p.dy);
      }
      return path..close();
    }

    final base = Color.lerp(_Colors.slate950, _Colors.ring, lit)!;
    if (glow > 0) {
      canvas.drawPath(
        band(_ringInner, _ringOuter),
        Paint()
          ..color = _Colors.yellow300.withValues(alpha: 0.55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25 + onePx),
      );
    }
    const bands = [
      (1.30, 1.52, 0.38),
      (1.52, 1.95, 0.78),
      (1.95, 2.02, 0.12),
      (2.02, 2.30, 0.62),
    ];
    for (final (inner, outer, alpha) in bands) {
      canvas.drawPath(
        band(inner, outer),
        Paint()
          ..color = base.withValues(
            alpha: (alpha + 0.25 * glow).clamp(0.0, 1.0),
          ),
      );
    }
  }

  // ---------------------------------------------------------------- labels

  /// HTML `updatePlanetLabelsUI()`: a label over each visible planet (the
  /// HTML placed them at twice the planet's position, a bug).
  void _planetLabels(Canvas canvas) {
    final s = scene;
    for (final b in s.bodies) {
      if (!b.visible) continue;
      final at = b.position;
      final uv = s.cam.uv(at);
      if (uv == null) continue;
      final r =
          _Cam.radiusAt(b.planet.size * b.scale.at(s.time), s.cam.depth(at)) *
          s.view.k;
      final top = r * (b.planet.ringed ? 1.35 : 1);
      _label(
        canvas,
        names[b.planet] ?? '',
        s.view.map(uv) - Offset(0, top + _labelGap * onePx),
      );
    }
  }

  /// `.planet-label`: a dark pill with an indigo border, its bottom centre
  /// at [at].
  void _label(Canvas canvas, String text, Offset at) {
    if (text.isEmpty) return;
    final tp = cache.label(text, labelSize);
    final k = labelSize / _labelPx;
    final w = tp.width + 16 * k;
    final h = tp.height + 4 * k;
    final rect = Rect.fromLTWH(at.dx - w / 2, at.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * k));
    canvas
      ..drawRRect(rr, Paint()..color = _Colors.labelBg)
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = onePx
          ..color = _Colors.labelBorder,
      );
    tp.paint(canvas, Offset(rect.left + 8 * k, rect.top + 2 * k));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.showLabels != showLabels ||
      old.sunName != sunName ||
      old.labelSize != labelSize ||
      old.onePx != onePx ||
      !mapEquals(old.names, names);
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
