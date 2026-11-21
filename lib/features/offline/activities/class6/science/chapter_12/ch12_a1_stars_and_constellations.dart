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

/// Class 6 Science • Chapter 12 (Beyond Earth) • Activity 1
/// Stars and Constellations: Navigating the Night Sky.
///
/// Native Flutter port of `Cl6S-Ch12-A1-Stars_and_Constellations.html`
/// (Three.js r128). The Three.js scene is redrawn by a painter that
/// reproduces the HTML camera: a 60° PerspectiveCamera at the origin that
/// `OrbitControls.update()` turns towards (0, 10, -40) in Scenario 1 and
/// towards (-10, 0, -40) in Scenario 2 (lowered to -2 here, see below).
///
/// HTML analysis (spec §1), in short:
/// - Scenario 1 (The Northern Guide), 5 steps: click the 7 Big Dipper stars
///   (a gold line appears), click the pointer stars Dubhe and Merak (blue
///   line), drag the "Distance Meter" slider 1x → 5x (the dashed red line
///   to Polaris fades in; the step ends at 4.8), click Polaris (flash,
///   label, North compass badge), drag the "Time-Lapse" slider 0 → 5
///   (`celestialSphere.rotation.z += speed * 0.015` per frame, dashed star
///   trails); from speed 2 an "Observe Conclusion" button opens the summary.
/// - Scenario 2 (The Hunter's Companion), 5 steps: click the 3 belt stars,
///   click the 4 corner stars (Orion stick figure + hunter artwork), drag the
///   Distance Meter 1x → 5x (dashed amber line to Sirius), click Sirius
///   (Canis Major and the dog artwork appear), "Observe Conclusion".
/// - Interactions: click a star, or press on a star and drag to another one
///   (a dashed guide line follows the finger; both stars count as clicked).
///   Target stars pulse (`sin(time * 0.005)`): scale ±0.12, glow ring
///   ±0.15, lightness ±0.1.
/// - Sounds (Web Audio): `click` (star, slider done), `pop` (enter, menus),
///   `success` (Polaris / Sirius found, conclusion).
/// - Text drawn over the scene: star names, "Big Dipper (Ladle)", "Orion
///   (The Hunter)", "Canis Major (The Great Dog)", "N . POLE STAR (NORTH)".
///
/// Changes from the HTML (see the report): Polaris lies exactly 5 pointer
/// distances beyond Dubhe on the pointer line and the Dipper is tilted so
/// that it fits (the HTML star was 2.9x away and off the line); the Distance
/// Meter line really grows with the slider and has a tick at every 1x; the
/// time-lapse turns the sky about the Pole Star (the HTML turned it about
/// the view axis, so Polaris moved too), the view pulls back in that step so
/// the Dipper's whole circle stays on screen, and the Dipper's star names
/// are hidden while the sky spins; Orion's belt slopes down to the
/// left and Sirius and Canis Major lie below-left of it as in the sky, with
/// Sirius exactly 5 belt lengths from Mintaka; a pointer star counts once;
/// a step's lines and labels appear as the learner finds the stars, not
/// before; a wrong star gets a hint toast.
class Ch12A1StarsAndConstellationsPage extends StatefulWidget {
  const Ch12A1StarsAndConstellationsPage({super.key});

  @override
  State<Ch12A1StarsAndConstellationsPage> createState() => _StarsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three tones with the Web Audio
/// API; each is played with the closest bundled file: `click` (a star
/// clicked, the Distance Meter reaching 5x) -> click.mp3, `pop` (Enter Lab,
/// scenario change, menus) -> the shell's curtain / scenario / toggle tones,
/// `success` (Polaris or Sirius found) -> correct.mp3; the conclusion popup
/// plays success.mp3. A wrong star plays error.mp3 with its hint (added).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`: a star clicked, the Distance Meter at 5x.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse (HTML `pop`).
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML `success` when Polaris / Sirius is found; positive toasts.
  correct('audio/class6/science/correct.mp3'),

  /// A star that is not the one the step asks for (added hint).
  wrong('audio/class6/science/error.mp3'),

  /// Conclusion popup (HTML `triggerConclusion`: `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed (HTML `pop`).
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing (HTML `pop`).
  curtain('audio/class6/science/curtain.mp3');

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
  static const Color indigo300 = Color(0xFFA5B4FC); // curtain subtitle
  static const Color indigo400 = Color(0xFF818CF8); // curtain icon
  static const Color indigo500 = Color(0xFF6366F1); // accents
  static const Color indigo600 = Color(0xFF4F46E5); // Observe Conclusion
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
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

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background `bg-[#03071e]` (the night sky, in both
  /// themes).
  static const Color night = Color(0xFF03071E);

  /// Background starfield: `PointsMaterial` 0x94a3b8, opacity 0.6.
  static const Color fieldStar = Color(0x9994A3B8);

  /// Star materials.
  static const Color yellow200 = Color(0xFFFEF08A); // Big Dipper
  static const Color blue200 = Color(0xFFBFDBFE); // Canis Major
  static const Color blue300 = Color(0xFF93C5FD); // belt, lines
  static const Color blue400 = Color(0xFF60A5FA); // Polaris, trails
  static const Color sky100 = Color(0xFFE0F2FE); // Orion corners
  static const Color sky400 = Color(0xFF38BDF8); // clicked stars, lines
  static const Color red300 = Color(0xFFFCA5A5); // Betelgeuse, club
  static const Color purple500 = Color(0xFFA855F7); // pointer / corner set
  static const Color gold = Color(0xFFEAB308); // Big Dipper line
  static const Color laserRed = Color(0xFFEF4444); // Polaris guide
  static const Color amber500 = Color(0xFFF59E0B); // Sirius guide
  static const Color faint = Color(0xFF94A3B8); // faint outlines

  /// `.star-label`: rgba(15, 23, 42, 0.85), border rgba(99, 102, 241, 0.5).
  static const Color labelBg = Color(0xD90F172A);
  static const Color labelBorder = Color(0x806366F1);

  /// Floating constellation badges (`bg-amber-900/90 border-amber-400
  /// text-amber-200` and the blue / cyan ones).
  static const Color amberBg = Color(0xE678350F);
  static const Color amberBorder = Color(0xFFFBBF24);
  static const Color amberText = Color(0xFFFDE68A);
  static const Color blueBg = Color(0xE61E3A8A);
  static const Color blueBorder = Color(0xFF60A5FA);
  static const Color blueText = Color(0xFFBFDBFE);
  static const Color cyanBg = Color(0xE6164E63);
  static const Color cyanBorder = Color(0xFF22D3EE);
  static const Color cyanText = Color(0xFFA5F3FC);

  /// `#compass-badge`: `bg-slate-900/90 border-indigo-500/40`, red compass.
  static const Color compassBg = Color(0xE60F172A);
  static const Color compassBorder = Color(0x666366F1);
  static const Color compassIcon = red500;

  /// Horizon silhouettes (inline SVGs). Ladakh mountains: three ridges and
  /// two moonlit rims; winter: two snow slopes and pine trees.
  static const Color ridgeFar = Color(0xFF0B1329);
  static const Color ridgeMid = Color(0xFF080E1F);
  static const Color ridgeNear = Color(0xFF030712);
  static const Color rimFar = Color(0x4060A5FA); // rgba(96,165,250,0.25)
  static const Color rimNear = Color(0x4D93C5FD); // rgba(147,197,253,0.3)
  static const Color snowFar = Color(0xFF081828);
  static const Color snowNear = Color(0xFF030D18);
  static const Color pine = Color(0xFF020813);
  static const Color pineEdge = Color(0x26BAE6FD); // rgba(186,230,253,0.15)
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
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.night,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
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
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300, // text-indigo-300/80
    curtainIcon: _Colors.indigo400,
    buttonBg: Color(0xE60F172A),
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
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.indigo300,
    curtainIcon: _Colors.indigo400,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x806366F1),
    readoutBg: _Colors.slate950,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Changes
// from the HTML (see the report): "Click" is "Tap"; each step's action says
// exactly what to tap, drag or slide (step 2 of Scenario 1 also offers the
// HTML's drag from star to star; step 5 says the button appears from 2x);
// the Hindi texts lose their English words in brackets ("(Big Dipper)",
// "(Dubhe & Merak)", "(Hunter)"); the Hindi Big Dipper stars carry their
// Saptarishi names (the HTML had them only for the two pointers) and Rigel
// is राजन्य; the Scenario 1 objective says the Big Dipper is part of Ursa
// Major (the HTML equated the two); the Sirius label says it is the
// brightest star (as the step's result promises); the Scenario 2 summary
// says "the brightest star in the night sky" (the HTML said "brighter than
// any other star visible from Earth", which the Sun is). Keys marked
// "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Stars and Constellations: Navigating the Night Sky',
    'app_subtitle': 'Class 6 • Beyond Earth',
    'scen_1_opt': 'Scenario 1: The Northern Guide (Finding the Pole Star)',
    'scen_2_opt': "Scenario 2: The Hunter's Companion (Finding Sirius)",
    's1_desc':
        "To learn how to identify the Big Dipper (Saptarshi, part of Ursa Major) and use its two 'pointer stars' to locate the Pole Star (Polaris).",
    's2_desc':
        'To identify the constellation Orion and use its belt to locate Sirius, the brightest star in the night sky.',
    // ------------------------------------------------------- canvas HUD
    's1_hud_1':
        'Step 1: Tap the 7 bright stars forming the ladle shape of the Big Dipper.',
    's1_hud_2':
        'Step 2: Tap the two pointer stars (Dubhe & Merak) at the end of the ladle cup to connect them.',
    's1_hud_3':
        'Step 3: Drag the Distance Meter slider to extend the line 5x its length to locate the Pole Star.',
    's1_hud_4':
        'Step 4: Tap the bright star at the tip of the line (Pole Star / Polaris).',
    's1_hud_5':
        'Step 5: Drag the Time-Lapse slider to 2x or faster to watch how all stars rotate around the fixed Pole Star, then tap Observe Conclusion.',
    's2_hud_1': "Step 1: Tap the 3 bright diagonal stars of Orion's Belt.",
    's2_hud_2':
        'Step 2: Tap the remaining 4 pulsing corner stars of Orion (Betelgeuse, Rigel, shoulders/feet) to complete the Hunter shape.',
    's2_hud_3':
        "Step 3: Drag the Distance Meter slider to extend the line from Orion's Belt eastward (left).",
    's2_hud_4':
        'Step 4: Tap the brilliant shimmering star pointed to by the belt line (Sirius).',
    's2_hud_5':
        'Step 5: Observe Canis Major (The Great Dog) appearing around Sirius, then tap Observe Conclusion.',
    // ------------------------------------------------------ S1 steps
    'step_1_1_c': 'Identifying Big Dipper',
    'step_1_1_a':
        'Look around the northern night sky and TAP each of the 7 main stars of the Big Dipper ladle.',
    'step_1_1_o':
        'The 7 stars glow brightly and connect with glowing constellation lines to reveal the Big Dipper asterism.',
    'step_1_2_c': 'Pointer Stars',
    'step_1_2_a':
        'TAP the two pulsing outer cup stars (Dubhe and Merak), or drag from one to the other.',
    'step_1_2_o': 'A straight laser guide connects the two pointer stars.',
    'step_1_3_c': '5x Distance Rule',
    'step_1_3_a':
        'DRAG the Distance Meter slider from 1x up to 5x cup lengths to extend the line straight outwards.',
    'step_1_3_o':
        'A dashed guide extends across the sky. At exactly 5x length, it points directly to a prominent star.',
    'step_1_4_c': 'Locating Polaris',
    'step_1_4_a': 'TAP the target star at the end of the extended line.',
    'step_1_4_o':
        "The star flashes brilliantly! Labels 'Pole Star (Polaris)' appear along with a North compass icon.",
    'step_1_5_c': 'Fixed North Star',
    'step_1_5_a':
        "DRAG the Time-Lapse slider to 2x or faster to fast-forward the night sky rotation, then tap 'Observe Conclusion'.",
    'step_1_5_o':
        'The entire celestial sphere revolves in circles, but the Pole Star remains completely stationary in the North!',
    // ------------------------------------------------------ S2 steps
    'step_2_1_c': "Orion's Belt",
    'step_2_1_a':
        'TAP the three bright stars aligned in a short diagonal line.',
    'step_2_1_o':
        "The three stars of Orion's Belt (Alnitak, Alnilam, Mintaka) glow and connect.",
    'step_2_2_c': 'Orion the Hunter',
    'step_2_2_a':
        'TAP the remaining 4 pulsing corner stars of Orion to connect the stick figure.',
    'step_2_2_o':
        "Constellation lines draw out the Hunter's body and a majestic artistic silhouette appears.",
    'step_2_3_c': 'Pointing to Sirius',
    'step_2_3_a':
        "DRAG the Distance Meter slider up to 5x belt lengths to extend a line from Orion's Belt towards the left (east).",
    'step_2_3_o':
        'A laser guide shoots out from the belt straight across the starry sky.',
    'step_2_4_c': 'Brightest Star Sirius',
    'step_2_4_a': 'TAP the dazzling blue-white star at the tip of the line.',
    'step_2_4_o':
        'Sirius flares with a brilliant lens flare effect! A label confirms it as the brightest star in the night sky.',
    'step_2_5_c': 'Canis Major Constellation',
    'step_2_5_a':
        "Observe the companion dog constellation, then tap 'Observe Conclusion'.",
    'step_2_5_o':
        'Canis Major (The Great Dog) connects around Sirius, showing how celestial figures relate in storytelling.',
    // ------------------------------------------------------ sidebar
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'obs_pending': 'Complete this step to see the result.', // added
    // ------------------------------------------------- buttons, slider
    'btn_conclude': 'Observe Conclusion',
    'slider_dist': 'Distance',
    'slider_speed': 'Speed',
    'unit_cup': 'Cup',
    'unit_speed': 'Spd',
    'unit_belt': 'Belt',
    'slider_value': '{v}x {u}',
    'slide': 'Slide',
    // ------------------------------------------------- canvas labels
    'compass_north': 'N • POLE STAR (NORTH)',
    'badge_dipper': 'Big Dipper (Ladle)',
    'badge_orion': 'Orion (The Hunter)',
    'badge_canis': 'Canis Major (The Great Dog)',
    'bd_alkaid': 'Alkaid',
    'bd_mizar': 'Mizar',
    'bd_alioth': 'Alioth',
    'bd_megrez': 'Megrez',
    'bd_phecda': 'Phecda',
    'bd_merak': 'Merak (Pointer)',
    'bd_dubhe': 'Dubhe (Pointer)',
    'polaris': 'Pole Star (Polaris)',
    'or_alnitak': 'Alnitak',
    'or_alnilam': 'Alnilam',
    'or_mintaka': 'Mintaka',
    'or_betelgeuse': 'Betelgeuse',
    'or_bellatrix': 'Bellatrix',
    'or_saiph': 'Saiph',
    'or_rigel': 'Rigel',
    'sirius': 'Sirius (Brightest Star)',
    'cm_mirzam': 'Mirzam',
    'cm_wezen': 'Wezen',
    'cm_adhara': 'Adhara',
    'cm_aludra': 'Aludra',
    // -------------------------------------------- hint toasts (added)
    'hint_1_1':
        'That star is not part of the Big Dipper. Tap the 7 pulsing stars of the ladle.',
    'hint_1_2':
        'That is not a pointer star. Tap the two pulsing stars at the end of the cup.',
    'hint_slider': 'First extend the line with the Distance Meter slider.',
    'hint_1_4': 'Tap the star at the tip of the dashed line.',
    'hint_2_1':
        "That star is not in Orion's Belt. Tap the 3 pulsing stars in a short diagonal line.",
    'hint_2_2': 'Tap the 4 pulsing corner stars of Orion.',
    'hint_2_4': 'Tap the bright star at the tip of the line.',
    // ------------------------------------------------------- summary
    'success': 'Success!',
    'sc_complete': 'Scenario {n} Complete!',
    's1_sum_head': 'Observation Complete!',
    's1_summary':
        'The Big Dipper (Saptarshi) serves as a reliable compass in the night sky. By extending a line 5 times the distance through its two pointer stars, you can always find the Pole Star (Polaris), which stays fixed in the true North direction.',
    's2_sum_head': 'Exploration Complete!',
    's2_summary':
        "Orion the Hunter is one of the most recognizable winter constellations. Following the straight line of Orion's Belt eastward leads you straight to Sirius in Canis Major, the brightest star in the night sky.",
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You learned how ancient navigators and astronomers identified the Big Dipper and Orion to reliably locate the North Pole Star and Sirius across the cosmos!',
    // ---------------------------------------------- screen reader (added)
    'scene_s1':
        'Night sky to the north over the Ladakh mountains, with the Big Dipper and the Pole Star.',
    'scene_s2':
        'Winter night sky over snowy pine trees, with Orion, Sirius and Canis Major.',
  },
  'hi': {
    'app_title': 'तारे और तारामंडल: रात्रि आकाश का नेविगेशन',
    'app_subtitle': 'कक्षा 6 • पृथ्वी के पार',
    'scen_1_opt': 'परिदृश्य 1: उत्तरी मार्गदर्शक (ध्रुव तारे की खोज)',
    'scen_2_opt': 'परिदृश्य 2: शिकारी का साथी (सीरियस की खोज)',
    's1_desc':
        "सप्तर्षि की पहचान करना और इसके दो 'संकेतक तारों' का उपयोग करके ध्रुव तारे को खोजना।",
    's2_desc':
        'ओरियन (मृगशीर्ष) तारामंडल की पहचान करना और उसकी बेल्ट से सीरियस (लुब्धक) तारे को खोजना।',
    // ------------------------------------------------------- canvas HUD
    's1_hud_1':
        'चरण 1: सप्तर्षि के चम्मच के आकार वाले 7 चमकीले तारों पर टैप करें।',
    's1_hud_2':
        'चरण 2: चम्मच के किनारे पर मौजूद दो संकेतक तारों (क्रतु और पुलह) पर टैप करें।',
    's1_hud_3':
        'चरण 3: ध्रुव तारे तक रेखा को 5 गुना बढ़ाने के लिए दूरी मीटर स्लाइडर खींचें।',
    's1_hud_4':
        'चरण 4: रेखा के अंत में स्थित चमकीले तारे (ध्रुव तारा) पर टैप करें।',
    's1_hud_5':
        "चरण 5: तारों का घूमना देखने के लिए समय-गति स्लाइडर को 2x या उससे अधिक तक खींचें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_1': 'चरण 1: ओरियन बेल्ट के 3 विकर्ण तारों पर टैप करें।',
    's2_hud_2':
        'चरण 2: ओरियन शिकारी का आकार पूरा करने के लिए बाकी 4 चमकते कोनों के तारों पर टैप करें।',
    's2_hud_3':
        'चरण 3: बेल्ट से बाईं ओर (पूर्व) रेखा बढ़ाने के लिए दूरी मीटर स्लाइडर खींचें।',
    's2_hud_4':
        'चरण 4: रेखा द्वारा दर्शाए गए अत्यंत चमकीले तारे (सीरियस) पर टैप करें।',
    's2_hud_5':
        "चरण 5: सीरियस के चारों ओर केनिस मेजर (बड़ा कुत्ता) तारामंडल देखें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    // ------------------------------------------------------ S1 steps
    'step_1_1_c': 'सप्तर्षि की पहचान',
    'step_1_1_a':
        'उत्तरी रात्रि आकाश में देखें और सप्तर्षि के चम्मच के 7 मुख्य तारों में से हर एक पर टैप करें।',
    'step_1_1_o':
        'सातों तारे चमकते हैं और रेखाओं से जुड़कर सप्तर्षि तारामंडल का आकार दिखाते हैं।',
    'step_1_2_c': 'संकेतक तारे',
    'step_1_2_a':
        'चम्मच के किनारे के दो चमकते संकेतक तारों (क्रतु और पुलह) पर टैप करें, या एक से दूसरे तक खींचें।',
    'step_1_2_o': 'दोनों तारों को जोड़ने वाली एक सीधी लेज़र रेखा बनती है।',
    'step_1_3_c': '5 गुना दूरी का नियम',
    'step_1_3_a':
        'दूरी मीटर स्लाइडर को 1x से 5x कप-लंबाई तक खींचकर रेखा को सीधा आगे बढ़ाएँ।',
    'step_1_3_o':
        'रेखा आगे बढ़ती है और ठीक 5 गुना दूरी पर एक विशेष तारे की ओर इशारा करती है।',
    'step_1_4_c': 'ध्रुव तारा खोजना',
    'step_1_4_a': 'बढ़ाई गई रेखा के सिरे पर स्थित लक्षित तारे पर टैप करें।',
    'step_1_4_o':
        "तारा चमकीला हो जाता है! 'ध्रुव तारा' लेबल और उत्तर दिशा का कंपास दिखाई देता है।",
    'step_1_5_c': 'स्थिर उत्तर तारा',
    'step_1_5_a':
        "रात्रि आकाश के घूर्णन को तेज़ी से देखने के लिए समय-गति स्लाइडर को 2x या उससे अधिक तक खींचें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    'step_1_5_o':
        'पूरा आकाश गोल घूमता है, लेकिन ध्रुव तारा उत्तर दिशा में बिल्कुल स्थिर रहता है!',
    // ------------------------------------------------------ S2 steps
    'step_2_1_c': 'ओरियन की बेल्ट',
    'step_2_1_a':
        'एक छोटी तिरछी सीधी रेखा में स्थित तीन चमकीले तारों पर टैप करें।',
    'step_2_1_o':
        'ओरियन बेल्ट के तीनों तारे (अलनिताक, अलनीलम, मिन्टाका) चमकते हैं और जुड़ जाते हैं।',
    'step_2_2_c': 'ओरियन शिकारी',
    'step_2_2_a':
        'शिकारी की रेखा-आकृति पूरी करने के लिए ओरियन के बाकी 4 चमकते कोनों के तारों पर टैप करें।',
    'step_2_2_o': 'तारामंडल की रेखाएं और शिकारी की सुंदर आकृति दिखाई देती है।',
    'step_2_3_c': 'सीरियस की ओर संकेत',
    'step_2_3_a':
        'दूरी मीटर स्लाइडर को 5x बेल्ट-लंबाई तक खींचकर ओरियन बेल्ट से बाईं ओर (पूर्व) रेखा बढ़ाएँ।',
    'step_2_3_o':
        'बेल्ट के तीनों तारों से होती हुई एक सीधी रेखा आकाश में आगे बढ़ती है।',
    'step_2_4_c': 'सबसे चमकीला तारा सीरियस',
    'step_2_4_a': 'रेखा के सिरे पर चमकते हुए नीले-सफेद तारे पर टैप करें।',
    'step_2_4_o':
        'सीरियस तीव्र प्रकाश से चमकता है! एक लेबल बताता है कि यह रात्रि आकाश का सबसे चमकीला तारा है।',
    'step_2_5_c': 'केनिस मेजर तारामंडल',
    'step_2_5_a':
        "साथी कुत्ता तारामंडल देखें, फिर 'निष्कर्ष देखें' पर टैप करें।",
    'step_2_5_o':
        'सीरियस के चारों ओर केनिस मेजर तारामंडल बनता है, जो ओरियन का साथी है।',
    // ------------------------------------------------------ sidebar
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    // ------------------------------------------------- buttons, slider
    'btn_conclude': 'निष्कर्ष देखें',
    'slider_dist': 'दूरी',
    'slider_speed': 'गति',
    'unit_cup': 'कप',
    'unit_speed': 'गति',
    'unit_belt': 'बेल्ट',
    'slider_value': '{v}x {u}',
    'slide': 'खिसकाएँ',
    // ------------------------------------------------- canvas labels
    'compass_north': 'उ • ध्रुव तारा (उत्तर)',
    'badge_dipper': 'सप्तर्षि (बड़ा चम्मच)',
    'badge_orion': 'ओरियन (शिकारी)',
    'badge_canis': 'केनिस मेजर (बड़ा कुत्ता)',
    'bd_alkaid': 'मरीचि',
    'bd_mizar': 'वशिष्ठ',
    'bd_alioth': 'अंगिरा',
    'bd_megrez': 'अत्रि',
    'bd_phecda': 'पुलस्त्य',
    'bd_merak': 'पुलह (संकेतक)',
    'bd_dubhe': 'क्रतु (संकेतक)',
    'polaris': 'ध्रुव तारा',
    'or_alnitak': 'अलनिताक',
    'or_alnilam': 'अलनीलम',
    'or_mintaka': 'मिन्टाका',
    'or_betelgeuse': 'आर्द्रा',
    'or_bellatrix': 'बेलाट्रिक्स',
    'or_saiph': 'सैफ़',
    'or_rigel': 'राजन्य',
    'sirius': 'सीरियस (सबसे चमकीला तारा)',
    'cm_mirzam': 'मिर्ज़ाम',
    'cm_wezen': 'वेज़न',
    'cm_adhara': 'अधारा',
    'cm_aludra': 'अलुद्रा',
    // ---------------------------------------------------- hint toasts
    'hint_1_1':
        'यह तारा सप्तर्षि का भाग नहीं है। चम्मच के 7 चमकते तारों पर टैप करें।',
    'hint_1_2':
        'यह संकेतक तारा नहीं है। चम्मच के सिरे के दो चमकते तारों पर टैप करें।',
    'hint_slider': 'पहले दूरी मीटर स्लाइडर से रेखा को आगे बढ़ाएँ।',
    'hint_1_4': 'बढ़ाई गई रेखा के सिरे पर स्थित तारे पर टैप करें।',
    'hint_2_1':
        'यह तारा ओरियन की बेल्ट में नहीं है। छोटी तिरछी रेखा में चमकते 3 तारों पर टैप करें।',
    'hint_2_2': 'ओरियन के कोनों के 4 चमकते तारों पर टैप करें।',
    'hint_2_4': 'रेखा के सिरे पर स्थित चमकीले तारे पर टैप करें।',
    // ------------------------------------------------------- summary
    'success': 'सफलता!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_sum_head': 'अवलोकन पूर्ण!',
    's1_summary':
        'सप्तर्षि तारामंडल रात्रि आकाश में एक प्राकृतिक दिशा-सूचक का काम करता है। इसके दो संकेतक तारों से 5 गुना दूरी पर रेखा बढ़ाने से हमेशा ध्रुव तारा मिलता है, जो उत्तर दिशा को सटीक रूप से दर्शाता है।',
    's2_sum_head': 'अन्वेषण पूर्ण!',
    's2_summary':
        'ओरियन शिकारी सर्दियों के आकाश का प्रमुख तारामंडल है। इसकी बेल्ट की सीध में पूर्व की ओर देखने पर केनिस मेजर का सीरियस तारा मिलता है, जो रात्रि आकाश का सबसे चमकीला तारा है।',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने सीखा कि कैसे प्राचीन नाविकों और खगोलविदों ने ध्रुव तारा और सीरियस का पता लगाने के लिए सप्तर्षि और ओरियन की पहचान की!',
    // ----------------------------------------------------- screen reader
    'scene_s1':
        'लद्दाख के पहाड़ों के ऊपर उत्तर दिशा का रात्रि आकाश, जिसमें सप्तर्षि और ध्रुव तारा हैं।',
    'scene_s2':
        'बर्फ़ से ढके चीड़ के पेड़ों के ऊपर सर्दियों का रात्रि आकाश, जिसमें ओरियन, सीरियस और केनिस मेजर हैं।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [5, 5];

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

/// HTML `new THREE.PerspectiveCamera(60, …)`: vertical field of view.
const double _fovDegrees = 60;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML `resetCamera()`: the camera stays at the origin and
/// `controls.target` is (0, 10, -40) in Scenario 1 and (-10, 0, -40) in
/// Scenario 2. The Scenario 2 target is lowered to y = -2 because Sirius and
/// Canis Major now lie below Orion's belt, as in the sky.
const List<_V> _lookAt = [_V(0, 10, -40), _V(-10, -2, -40)];

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for a drag from a star (short drags must still count).
const double _dragSlop = 8;

/// `.star-label`: 11 px, enlarged up to 1.9x on small stages so the names
/// stay readable on a phone.
const double _labelPx = 11;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.9;

/// Design px between a label chip and its star (HTML `top: y - 12`).
const double _labelGap = 5;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make anything jump.
const double _maxFrameStep = 0.1;

/// Time constant (s) of the stage framing as it follows the shell's cards.
const double _viewSmoothing = 0.06;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas while the sidebar is open, the toast at the top, and the
/// compact floating mission card while the sidebar is collapsed (phones in
/// landscape: screens shorter than [_compactBelow], at most
/// [_compactCardMax] of the height, [_missionTop] from the top).
const double _hudBand = 54;
const double _toastBand = 52;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Canvas / design px kept free around cards and stage edges.
const double _cardGap = 8;

/// Horizon silhouette (`h-40 sm:h-52 md:h-64` at the canvas bottom): this
/// share of the canvas height; the stars are framed above the lower
/// [_horizonClear] of it (only the highest peaks rise above that).
const double _horizonShare = 0.3;
const double _horizonClear = 0.55;

/// SVG viewBox of the horizon silhouettes (`0 0 1440 320`).
const double _svgW = 1440;
const double _svgH = 320;

/// Control card (HTML `#s1-slider-box`, `w-[64px] sm:w-[76px]`, and the
/// "Observe Conclusion" button) at the right of the canvas: its width with
/// only the slider and with the button (x UI scale), the slider's longest
/// and shortest track and the card's own rows (title, value, hint, button).
const double _sliderCardWidth = 84;
const double _buttonCardWidth = 176;
const double _sliderMaxLength = 170;
const double _sliderMinLength = 64;
const double _cardChrome = 80;
const double _buttonBlock = 58;

/// Key of the Distance Meter / Time-Lapse slider (flow tests).
const ValueKey<String> _sliderKey = ValueKey('ch12a1-slider');

// -------------------------------------------------------- simulation values

/// HTML pulse of the target stars: `sin(time * 0.005)` (time in ms), scale
/// ±0.12, glow ring scale 1.05 ±0.15 and opacity 0.22 ±0.12, lightness ±0.1.
const double _pulseRate = 5;
const double _pulseScale = 0.12;
const double _pulseRing = 0.15;

/// Artwork shimmer: Orion fill 0.16 ±0.06 at 3.5 rad/s, dog fill 0.24
/// ±0.08 at 4 rad/s (`time * 0.0035`, `time * 0.004`).
const double _orionFill = 0.16;
const double _orionShimmer = 0.06;
const double _orionRate = 3.5;
const double _dogFill = 0.24;
const double _dogShimmer = 0.08;
const double _dogRate = 4;

/// Distance Meter: `min 1, max 5, step 0.1`; the step ends at 4.8 (HTML),
/// where the line is completed to 5x.
const double _extMin = 1;
const double _extMax = 5;
const int _extDivisions = 40;
const double _extDone = 4.8;

/// Time-Lapse: `min 0, max 5, step 0.5`; the sky turns
/// `speed * 0.015` rad per frame (at 60 frames/s) and "Observe Conclusion"
/// appears from speed 2.
const double _speedMax = 5;
const int _speedDivisions = 10;
const double _spinPerSpeed = 0.015 * 60;
const double _speedForConclusion = 2;

/// Star trails: dashed rings round the Pole Star, radius 4 … 50 every 3.5
/// units, dash `3 + r * 0.2`, gap `2 + r * 0.1`, opacity
/// `max(0.15, 0.75 - r * 0.012)`, 0x60a5fa.
const double _trailFirst = 4;
const double _trailLast = 50;
const double _trailStep = 3.5;

/// HTML starfield: 1500 points on a sphere of radius 80 (fixed seed here).
const int _fieldCount = 1500;
const double _fieldRadius = 80;
const int _fieldSeed = 12;

/// Polaris / Sirius flash when found: a glow that grows to this many star
/// radii and settles in this many seconds.
const double _flashRadius = 5;
const double _flashSeconds = 1.2;

/// Points sampled round the circle each star sweeps about the Pole Star,
/// to frame the whole time-lapse (Scenario 1 step 5).
const int _sweepSamples = 24;

/// Room (label sizes) kept round each sampled point of that circle.
const double _sweepRoom = 1.5;

// ------------------------------------------------------------ star chart

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
}

/// A point of the star chart (a star or an artwork point).
abstract interface class _Point {
  _V get pos;
}

/// What a star is in its scenario.
enum _Kind { dipper, pole, belt, corner, sirius, dog }

/// The stars of both scenarios (HTML `bigDipperCoords`, `polarisCoord`,
/// `orionBeltCoords`, `orionBodyCoords`, `siriusCoord`, `canisMajorCoords`
/// with their sphere sizes and material colours).
///
/// Big Dipper: the HTML stars turned 30° clockwise, scaled by 0.9 and moved
/// so that Polaris, which the HTML put 2.9 pointer distances from Dubhe and
/// off the pointer line, lies exactly at Dubhe + 5 × (Dubhe − Merak) (NCERT:
/// "about five times the distance between the pointer stars").
///
/// Orion: the corner stars as in the HTML; the belt (HTML 8 units wide,
/// sloping up to the left, which mirrors the sky) is 6 units wide and slopes
/// 20° down to the left about Alnilam, and Sirius lies on its line exactly 5
/// belt lengths from Mintaka, below-left of Orion as in the sky. Canis
/// Major: Mirzam, Wezen, Adhara and Aludra at their sky positions relative
/// to Sirius (scaled; the HTML had them mirrored).
enum _Star implements _Point {
  alkaid('bd_alkaid', 0, _Kind.dipper, _V(-17.57, 19.38, -40), 0.8),
  mizar('bd_mizar', 0, _Kind.dipper, _V(-13.34, 15.90, -42), 0.8),
  alioth('bd_alioth', 0, _Kind.dipper, _V(-9.56, 11.64, -43), 0.8),
  megrez('bd_megrez', 0, _Kind.dipper, _V(-7.02, 7.05, -44), 0.8),
  phecda('bd_phecda', 0, _Kind.dipper, _V(-9.72, 2.37, -44), 0.8),
  merak('bd_merak', 0, _Kind.dipper, _V(-3.93, -2.01, -43), 0.8),
  dubhe('bd_dubhe', 0, _Kind.dipper, _V(0, 3, -43), 0.8),

  /// Dubhe + 5 × (Dubhe − Merak).
  polaris('polaris', 0, _Kind.pole, _V(19.65, 28.05, -43), 1.3),

  alnitak('or_alnitak', 1, _Kind.belt, _V(-2.819, -2.026, -42), 0.9),
  alnilam('or_alnilam', 1, _Kind.belt, _V(0, -1, -42), 0.9),
  mintaka('or_mintaka', 1, _Kind.belt, _V(2.819, 0.026, -42), 0.9),
  betelgeuse('or_betelgeuse', 1, _Kind.corner, _V(-5, 8, -41), 1.0),
  bellatrix('or_bellatrix', 1, _Kind.corner, _V(6, 6, -41), 1.0),
  saiph('or_saiph', 1, _Kind.corner, _V(-7, -9, -41), 1.0),
  rigel('or_rigel', 1, _Kind.corner, _V(5, -11, -41), 1.0),

  /// Mintaka + 5 × (Alnitak − Mintaka).
  sirius('sirius', 1, _Kind.sirius, _V(-25.371, -10.234, -42), 1.7),

  mirzam('cm_mirzam', 1, _Kind.dog, _V(-20.871, -11.034, -42), 0.7),
  wezen('cm_wezen', 1, _Kind.dog, _V(-29.971, -16.534, -42), 0.7),
  adhara('cm_adhara', 1, _Kind.dog, _V(-27.921, -18.234, -42), 0.7),
  aludra('cm_aludra', 1, _Kind.dog, _V(-32.671, -18.434, -42), 0.7);

  const _Star(this.id, this.scenario, this.kind, this.pos, this.size);

  /// HTML star id; also its name key in [_i18n].
  final String id;
  final int scenario;
  final _Kind kind;
  @override
  final _V pos;

  /// `SphereGeometry(size)`.
  final double size;

  /// Material colour (`createStarObject` colour argument).
  Color get color => switch (kind) {
    _Kind.dipper => _Colors.yellow200,
    _Kind.pole => _Colors.blue400,
    _Kind.belt => _Colors.blue300,
    _Kind.corner => this == _Star.betelgeuse ? _Colors.red300 : _Colors.sky100,
    _Kind.sirius => _Colors.white,
    _Kind.dog => _Colors.blue200,
  };
}

/// HTML `orionArtCoords` / `canisArtCoords`: unlabelled points of the
/// artwork lines (not drawn as stars). The dog's points are placed for the
/// new Canis Major, facing Orion.
enum _Art implements _Point {
  head(_V(0.5, 14, -41)),
  bowTop(_V(12, 11, -41)),
  bowMid(_V(13.5, 1, -41)),
  bowBottom(_V(11, -8, -41)),
  clubTop(_V(-12, 17, -41)),
  swordTip(_V(0.5, -6.5, -42)),
  nose(_V(-21.371, -6.234, -42)),
  ear(_V(-25.871, -4.434, -42)),
  frontPaw(_V(-18.871, -12.734, -42)),
  backPaw(_V(-26.871, -20.734, -42)),
  tail(_V(-34.371, -19.734, -42));

  const _Art(this.pos);
  @override
  final _V pos;
}

/// HTML `dipperOrder`: the ladle, closed back to Megrez.
const List<_Star> _dipperOrder = [
  _Star.alkaid,
  _Star.mizar,
  _Star.alioth,
  _Star.megrez,
  _Star.phecda,
  _Star.merak,
  _Star.dubhe,
  _Star.megrez,
];

/// HTML `orion_belt_line` and `orionMainOrder`.
const List<_Star> _beltOrder = [_Star.alnitak, _Star.alnilam, _Star.mintaka];
const List<_Star> _orionOrder = [
  _Star.betelgeuse,
  _Star.bellatrix,
  _Star.mintaka,
  _Star.rigel,
  _Star.saiph,
  _Star.alnitak,
  _Star.betelgeuse,
];

/// A polyline of the artwork and its colour (HTML `createConstellationLine`
/// calls for the hunter and the dog).
typedef _ArtLine = (List<_Point>, Color);

/// Orion artwork: bow, club, head and sword lines.
const List<_ArtLine> _orionArt = [
  ([_Art.bowTop, _Star.bellatrix, _Art.bowMid, _Art.bowBottom], _Colors.sky400),
  ([_Star.betelgeuse, _Art.clubTop], _Colors.red300),
  ([_Star.betelgeuse, _Art.head, _Star.bellatrix], _Colors.blue300),
  ([_Star.alnilam, _Art.swordTip], _Colors.blue300),
];

/// Canis Major: the stick figure (`canis_line`) and the dog artwork (head,
/// legs, chest glow, tail), redrawn for the stars' new places.
const List<_ArtLine> _dogLines = [
  ([_Star.mirzam, _Star.sirius, _Star.wezen, _Star.aludra], _Colors.blue300),
  ([_Star.wezen, _Star.adhara], _Colors.blue300),
];
const List<_ArtLine> _dogArt = [
  ([_Star.sirius, _Art.nose, _Art.ear, _Star.sirius], _Colors.sky400),
  ([_Star.mirzam, _Art.frontPaw], _Colors.blue300),
  ([_Star.adhara, _Art.backPaw], _Colors.blue300),
  ([_Star.sirius, _Star.mirzam, _Star.wezen, _Star.sirius], _Colors.blue400),
  ([_Star.aludra, _Art.tail], _Colors.sky400),
];

/// HTML `orionPolygon`: the hunter's silhouette (fill 0x60a5fa at 0.16,
/// outline 0x38bdf8).
const List<_V> _orionShape = [
  _V(0.5, 15.5, -41),
  _V(2.5, 13.5, -41),
  _V(6.0, 6.0, -41),
  _V(12.0, 11.0, -41),
  _V(13.5, 1.0, -41),
  _V(11.0, -8.0, -41),
  _V(6.5, 1.0, -41),
  _V(4.5, -3.0, -41),
  _V(5.0, -11.0, -41),
  _V(2.0, -11.0, -41),
  _V(0.0, -5.0, -41),
  _V(-4.0, -9.0, -41),
  _V(-7.0, -9.0, -41),
  _V(-5.5, -3.0, -41),
  _V(-5.0, 4.0, -41),
  _V(-10.0, 11.0, -41),
  _V(-12.0, 17.0, -41),
  _V(-8.5, 17.0, -41),
  _V(-5.0, 8.0, -41),
  _V(-1.5, 13.5, -41),
];

/// The dog's silhouette (HTML `canisPolygon`, redrawn round the new Canis
/// Major: facing right towards Orion, Sirius at its chest, Mirzam at the
/// front paw, Adhara at the hind leg, Aludra at the tail; fill 0x38bdf8 at
/// 0.25).
const List<_V> _dogShape = [
  _V(-20.771, -6.034, -42),
  _V(-20.971, -7.234, -42),
  _V(-23.371, -8.034, -42),
  _V(-23.771, -9.434, -42),
  _V(-20.371, -10.434, -42),
  _V(-18.371, -12.234, -42),
  _V(-19.071, -13.334, -42),
  _V(-21.771, -12.134, -42),
  _V(-24.571, -12.634, -42),
  _V(-26.871, -14.834, -42),
  _V(-26.371, -20.034, -42),
  _V(-25.971, -21.234, -42),
  _V(-27.871, -21.434, -42),
  _V(-28.971, -18.634, -42),
  _V(-30.771, -17.434, -42),
  _V(-33.971, -20.434, -42),
  _V(-34.971, -20.034, -42),
  _V(-31.371, -15.234, -42),
  _V(-29.371, -12.234, -42),
  _V(-26.971, -7.634, -42),
  _V(-26.571, -4.834, -42),
  _V(-25.971, -3.634, -42),
  _V(-24.771, -5.234, -42),
  _V(-22.771, -5.034, -42),
];

/// Anchors of the floating constellation badges: HTML (-6, 16, -42) above
/// the Dipper's handle (moved with the Dipper), (0, 15.5, -41) above Orion
/// and above the dog's head.
const _V _dipperBadge = _V(-8, 18, -42);
const _V _orionBadge = _V(0, 15.5, -41);
const _V _dogBadge = _V(-28.371, -1.734, -42);

/// How the scene is framed on the stage: the HTML camera's picture scaled
/// by [k] (never above 1) and shifted by ([dx], [dy]) design px, so the
/// stars stay clear of the shell's cards.
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

/// The HTML PerspectiveCamera (at the origin, looking at [target], fov 60)
/// as a pinhole projection onto the design stage, with the stage framing
/// applied ([frame]).
class _Camera {
  factory _Camera(_V target) {
    final f = target.unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Camera._(f, r, r.cross(f));
  }

  _Camera._(this.f, this.r, this.u);

  /// Forward, right and up unit vectors (the eye is at the origin).
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

  double depth(_V w) => w.dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final k = focal / math.max(0.1, w.dot(f));
    return Offset(center.dx + w.dot(r) * k, center.dy - w.dot(u) * k);
  }
}

/// The unframed HTML cameras (layout, framing).
final List<_Camera> _baseCams = [_Camera(_lookAt[0]), _Camera(_lookAt[1])];

/// The Pole Star's direction from the observer: the axis the sky turns
/// about in the time-lapse.
final _V _poleAxis = _Star.polaris.pos.unit;

/// Two unit vectors across [_poleAxis] (`_trailV == axis × _trailU`), for
/// the star-trail rings.
final _V _trailU = _poleAxis.cross(const _V(0, 1, 0)).unit;
final _V _trailV = _poleAxis.cross(_trailU);

/// [w] turned by [angle] about [_poleAxis] (Rodrigues' rotation formula).
_V _aboutPole(_V w, double angle) {
  final k = _poleAxis;
  final c = math.cos(angle);
  final s = math.sin(angle);
  return w * c + k.cross(w) * s + k * (k.dot(w) * (1 - c));
}

/// HTML background starfield: points spread evenly over a sphere.
final List<_V> _field = () {
  final rnd = math.Random(_fieldSeed);
  return [
    for (var i = 0; i < _fieldCount; i++)
      () {
        final theta = rnd.nextDouble() * 2 * math.pi;
        final phi = math.acos(2 * rnd.nextDouble() - 1);
        return _V(
          _fieldRadius * math.sin(phi) * math.cos(theta),
          _fieldRadius * math.sin(phi) * math.sin(theta),
          _fieldRadius * math.cos(phi),
        );
      }(),
  ];
}();

/// The simulation: scenario, step and what the learner has found (HTML
/// `State`, `State.s1`, `State.s2`), the sky's turn and the framing.
class _Sky {
  int scenario = 0;
  int step = 1;

  /// Stars tapped in the scenario's identification steps (HTML
  /// `clickedStars`, `beltClicked`, `bodyClicked`).
  final Set<_Star> tapped = {};

  /// Pointer stars tapped in Scenario 1 step 2 (HTML `pointerClicked`,
  /// which counted the same star twice).
  final Set<_Star> pointers = {};

  /// Distance Meter value (HTML `lineExtension`, 1 … 5).
  double extension = _extMin;

  /// Polaris (Scenario 1) or Sirius (Scenario 2) found.
  bool found = false;

  /// [time] when it was found (flash).
  double foundAt = 0;

  /// Time-Lapse speed (HTML `timeLapseSpeed`) and how far the sky has
  /// turned (rad).
  double speed = 0;
  double turn = 0;

  /// "Observe Conclusion" is shown (HTML `#compare-btn-container`).
  bool conclusionReady = false;

  /// Seconds since the page opened (ticker).
  double time = 0;

  /// The star a drag started on and where the finger is (HTML
  /// `dragStartStar`, `dragGuideLine`).
  _Star? dragFrom;
  Offset? dragTo;

  /// Framing of the camera picture (eased towards [viewTarget]).
  _View view = _View.identity;
  _View viewTarget = _View.identity;
  bool snapView = true;

  /// Stage px per design px, the visible canvas in design px, the canvas
  /// part no card covers (design px) and the label size (set by the page
  /// while laying out the stage).
  double fit = 1;
  Rect visible = Offset.zero & _design;
  Rect free = Offset.zero & _design;
  double labelSize = _labelPx;
  double touch = _touchDp;

  final _Camera _cam0 = _Camera(_lookAt[0]);
  final _Camera _cam1 = _Camera(_lookAt[1]);
  _Camera get cam => scenario == 0 ? _cam0 : _cam1;

  /// Rotation of the sky this frame: cos / sin of `-turn` about
  /// [_poleAxis] (counter-clockwise on screen, as stars turn round the Pole
  /// Star seen from the northern hemisphere).
  double _cos = 1;
  double _sin = 0;

  void updateTurn() {
    _cos = math.cos(-turn);
    _sin = math.sin(-turn);
  }

  bool get turning => scenario == 0 && turn != 0;

  /// The time-lapse is running (Scenario 1 step 5, speed above 0).
  bool get spinning => scenario == 0 && step >= 5 && speed > 0;

  /// [w] as it is in the turned sky (Rodrigues' rotation formula).
  _V sky(_V w) {
    if (!turning) return w;
    final k = _poleAxis;
    return w * _cos + k.cross(w) * _sin + k * (k.dot(w) * (1 - _cos));
  }

  Iterable<_Star> get stars =>
      _Star.values.where((s) => s.scenario == scenario);

  /// Where [p] is on the stage now (turned sky, framing).
  Offset at(_Point p) => cam.p(sky(p.pos));

  /// Drawn radius of [star] (its sphere at its distance).
  double radius(_Star star) => star.size * cam.scaleAt(star.pos);

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    tapped.clear();
    pointers.clear();
    extension = _extMin;
    found = false;
    foundAt = 0;
    speed = 0;
    turn = 0;
    updateTurn();
    conclusionReady = false;
    dragFrom = null;
    dragTo = null;
    snapView = true;
  }

  // ------------------------------------------------------- read by flows

  /// Design-space position of a named point (flows): a star id
  /// ('bd_dubhe', 'or_rigel', 'sirius', …) or 'sky', an open spot of the
  /// sky away from every star.
  Offset anchor(String id) {
    if (id == 'sky') return _openSky();
    return at(_Star.values.firstWhere((s) => s.id == id));
  }

  /// Ids of the stars tapped so far.
  List<String> get tappedIds => [for (final s in tapped) s.id];
  List<String> get pointerIds => [for (final s in pointers) s.id];

  /// The Distance Meter line: how far its tip is from the star it points
  /// to (world units; 0 when it reaches it).
  double get lineGap {
    final (from, dir, unit, target) = scenario == 0
        ? (_Star.dubhe, _pointerDir, _pointerLength, _Star.polaris)
        : (_Star.mintaka, _beltDir, _beltLength, _Star.sirius);
    final tip = from.pos + dir * (unit * extension);
    return (tip - target.pos).length;
  }

  /// Ids of the stars that carry a name label now (see [labelled]).
  List<String> get labelIds => [
    for (final s in stars)
      if (labelled(s)) s.id,
  ];

  /// Does [star] show its name? HTML `updateStarLabelsUI`: Scenario 1 the
  /// tapped Dipper stars, Merak and Dubhe, Polaris once found; Scenario 2
  /// the tapped Orion stars, Sirius and Canis Major once Sirius is found.
  /// (The HTML also named Polaris / Sirius in step 4, before the learner
  /// had found them.)
  bool labelled(_Star s) => switch (s.kind) {
    _Kind.dipper => tapped.contains(s) || s == _Star.merak || s == _Star.dubhe,
    _Kind.pole || _Kind.sirius || _Kind.dog => found,
    _Kind.belt || _Kind.corner => tapped.contains(s),
  };

  /// An open spot of the free sky, as far as possible from every star.
  Offset _openSky() {
    var best = free.center;
    var bestD = -1.0;
    for (var i = 1; i < 12; i++) {
      for (var j = 1; j < 8; j++) {
        final p = Offset(
          free.left + free.width * i / 12,
          free.top + free.height * j / 8,
        );
        var d = double.infinity;
        for (final s in stars) {
          d = math.min(d, (at(s) - p).distance);
        }
        if (d > bestD) {
          bestD = d;
          best = p;
        }
      }
    }
    return best;
  }
}

/// Scenario 1 Distance Meter: from Dubhe away from Merak, in pointer
/// distances. Scenario 2: from Mintaka through Alnitak, in belt lengths.
final _V _pointerDir = (_Star.dubhe.pos - _Star.merak.pos).unit;
final double _pointerLength = (_Star.dubhe.pos - _Star.merak.pos).length;
final _V _beltDir = (_Star.alnitak.pos - _Star.mintaka.pos).unit;
final double _beltLength = (_Star.alnitak.pos - _Star.mintaka.pos).length;

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a star ([canGrab]), so other drags still pan / zoom the canvas.
class _StarPanRecognizer extends PanGestureRecognizer {
  _StarPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _StarsLabState extends State<Ch12A1StarsAndConstellationsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Sky _sky = _Sky();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The slider's value (its card rebuilds on its own).
  final ValueNotifier<double> _sliderValue = ValueNotifier(_extMin);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_sky.scenario];

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
    _sky.load(0);
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

  /// HTML `animate()`: the sky's turn and the framing, then one repaint of
  /// the canvas (never a rebuild).
  void _onTick(Duration elapsed) {
    final s = _sky;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.view = s.view.toward(s.viewTarget, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    // HTML: `celestialSphere.rotation.z += speed * 0.015` while Scenario 1
    // step 5 runs (kept turning after the conclusion, as in the HTML).
    if (s.scenario == 0 && s.step >= 5 && s.speed > 0) {
      s.turn += s.speed * _spinPerSpeed * dt;
      s.updateTurn();
    }
    _frame.value = now;
  }

  /// HTML `progressStep()`, with what the next step starts with
  /// (`setupStepUI`).
  void _nextStep() {
    setState(() {
      final s = _sky;
      s.step += 1;
      if (s.step == 3) {
        s.extension = _extMin;
        _sliderValue.value = _extMin;
      } else if (s.step == 5 && s.scenario == 0) {
        s.speed = 0;
        _sliderValue.value = 0;
      } else if (s.step == 5 && s.scenario == 1) {
        // HTML: the button appears as soon as Scenario 2 step 5 starts.
        s.conclusionReady = true;
      }
    });
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending callback and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _sky.load(index);
      _sliderValue.value = _extMin;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `triggerConclusion()` ("Observe Conclusion").
  void _conclude() {
    final s = _sky;
    if (s.step != 5 || !s.conclusionReady) return;
    final sc = s.scenario;
    final n = sc + 1;
    setState(() => s.step = _stepCounts[sc] + 1);
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      title: () => _t('success'),
      // Scenario 1: the summary modal; Scenario 2: the HTML's "Mastery
      // Achieved!" modal, with the scenario's own summary added.
      heading: () =>
          sc == 0 ? labFormat(_t('sc_complete'), {'n': n}) : _t('all_complete'),
      body: () => sc == 0
          ? '${_t('s1_sum_head')}\n\n${_t('s1_summary')}'
          : '${_t('s2_sum_head')}\n\n${_t('s2_summary')}\n\n'
                '${_t('all_complete_desc')}',
    );
  }

  // ---------------------------------------------------------------- stars

  /// HTML `handleStarClick(mesh)` for the current step.
  void _clickStar(_Star star) {
    if (_sky.scenario == 0) {
      _clickS1(star);
    } else {
      _clickS2(star);
    }
  }

  void _hint(String key) => _lab.showToast(_t(key), isError: true);

  void _clickS1(_Star star) {
    final s = _sky;
    switch (s.step) {
      case 1:
        if (star.kind != _Kind.dipper) return _hint('hint_1_1');
        _Sound.click.play();
        if (s.tapped.add(star)) {
          if (s.tapped.length == 7) {
            _nextStep();
          } else {
            setState(() {});
          }
        }
      case 2:
        if (star != _Star.merak && star != _Star.dubhe) {
          return _hint('hint_1_2');
        }
        _Sound.click.play();
        if (s.pointers.add(star)) {
          if (s.pointers.length == 2) {
            _nextStep();
          } else {
            setState(() {});
          }
        }
      case 3:
        _hint('hint_slider');
      case 4:
        if (star != _Star.polaris) return _hint('hint_1_4');
        _found();
      default:
        _Sound.click.play();
    }
  }

  void _clickS2(_Star star) {
    final s = _sky;
    switch (s.step) {
      case 1:
        if (star.kind != _Kind.belt) return _hint('hint_2_1');
        _Sound.click.play();
        if (s.tapped.add(star)) {
          if (s.tapped.where((t) => t.kind == _Kind.belt).length == 3) {
            _nextStep();
          } else {
            setState(() {});
          }
        }
      case 2:
        if (star.kind != _Kind.corner) return _hint('hint_2_2');
        _Sound.click.play();
        if (s.tapped.add(star)) {
          if (s.tapped.where((t) => t.kind == _Kind.corner).length == 4) {
            _nextStep();
          } else {
            setState(() {});
          }
        }
      case 3:
        _hint('hint_slider');
      case 4:
        if (star != _Star.sirius) return _hint('hint_2_4');
        _found();
      default:
        _Sound.click.play();
    }
  }

  /// Step 4: Polaris / Sirius found (HTML: flash, label, compass badge or
  /// Canis Major, `success`).
  void _found() {
    final s = _sky;
    s
      ..found = true
      ..foundAt = s.time;
    _Sound.correct.play();
    _nextStep();
  }

  // --------------------------------------------------------------- slider

  /// HTML `slider.oninput` of the Distance Meter (step 3) and the
  /// Time-Lapse (Scenario 1 step 5).
  void _onSlide(double v) {
    final s = _sky;
    _sliderValue.value = v;
    if (s.step == 3) {
      s.extension = v;
      if (v >= _extDone) {
        s.extension = _extMax;
        _sliderValue.value = _extMax;
        _Sound.click.play();
        _nextStep();
      }
    } else if (s.scenario == 0 && s.step >= 5) {
      s.speed = v;
      if (v >= _speedForConclusion && !s.conclusionReady) {
        setState(() => s.conclusionReady = true);
      }
    }
  }

  /// Is the slider shown (HTML `#s1-slider-box`)?
  bool get _sliderShown =>
      _lab.isLabActive &&
      (_sky.step == 3 || (_sky.scenario == 0 && _sky.step >= 5));

  // ------------------------------------------------------------- gestures

  /// The star under [at] (design px): the nearest one within its touch
  /// radius (HTML Raycaster against the visible star spheres).
  _Star? _starAt(Offset at) {
    final s = _sky;
    _Star? best;
    var bestD = double.infinity;
    for (final star in s.stars) {
      final d = (s.at(star) - at).distance;
      final reach = math.max(s.radius(star) * 1.6, s.touch);
      if (d <= reach && d < bestD) {
        best = star;
        bestD = d;
      }
    }
    return best;
  }

  /// HTML `pointerdown`: only on a star (other drags pan the canvas).
  bool _canGrab(PointerDownEvent event) =>
      _lab.isLabActive &&
      _sky.dragFrom == null &&
      _starAt(event.localPosition) != null;

  /// A press on a star clicks it (the HTML clicked it on release; a press
  /// counts at once here so a tap always works whatever gesture wins).
  void _onDown(DragDownDetails d) {
    final star = _starAt(d.localPosition);
    if (star == null) return;
    _sky
      ..dragFrom = star
      ..dragTo = null;
    _clickStar(star);
  }

  /// HTML `pointermove`: the dashed guide line follows the finger.
  void _onDragUpdate(DragUpdateDetails d) {
    if (_sky.dragFrom == null) return;
    _sky.dragTo = d.localPosition;
  }

  /// HTML `pointerup`: released on another star, that star is clicked too.
  void _onDragEnd(DragEndDetails _) {
    final s = _sky;
    final from = s.dragFrom;
    final to = s.dragTo;
    s
      ..dragFrom = null
      ..dragTo = null;
    if (from == null || to == null) return;
    final end = _starAt(to);
    if (end != null && end != from) _clickStar(end);
  }

  void _onDragCancel() {
    _sky
      ..dragFrom = null
      ..dragTo = null;
  }

  // -------------------------------------------------------------- framing

  /// Width (dp) of the control card on the right of the canvas, 0 when it
  /// is hidden.
  double _controlWidth(double s, bool withButton) {
    if (withButton) return _buttonCardWidth * s;
    return _sliderShown ? _sliderCardWidth * s : 0;
  }

  /// Height (dp) of the horizon silhouette at the bottom of a canvas
  /// [height] dp tall.
  static double _horizonHeight(double height) => height * _horizonShare;

  /// Fits the scenario's stars and labels into the part of the canvas no
  /// shell card covers: the toast band at the top, the tool column and the
  /// control card on the right, the HUD chip and the horizon at the bottom
  /// and the floating mission card (sidebar collapsed: the scene moves below
  /// it or, if that would shrink it more, to its right). Returns the framing
  /// in design px for a canvas of [canvas] dp at stage scale [fit], and
  /// stores the main free area (design px) in the scene.
  _View _framing(BuildContext context, Size canvas, double fit, double card) {
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
    final top = insets.top + _toastBand * s;
    final bottom = math.max(
      open ? _hudBand * s + _cardGap : _cardGap,
      _horizonHeight(canvas.height) * _horizonClear,
    );
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      top,
      canvas.width - insets.right - (card > 0 ? card + _cardGap : 0),
      canvas.height - bottom - pad.bottom,
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
    final designFrees = [
      for (final r in frees) toDesign(r).intersect(stageRect),
    ];
    var (view, free) = _fitView(_focusRect(1), designFrees);
    // Labels keep their size when the picture is scaled down, so they need
    // relatively more room: fit once more with that room.
    if (view.k < 1) {
      (view, free) = _fitView(_focusRect(1 / view.k), designFrees);
    }
    _sky.free = free;
    return view;
  }

  /// Bounds (unframed design px) of what the learner taps and reads in the
  /// current scenario: its stars, their labels, the badges and the artwork;
  /// the room for labels is [grow] times their size.
  Rect _focusRect(double grow) {
    final sky = _sky;
    final cam = _baseCams[sky.scenario];
    final l = sky.labelSize * grow;
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    // A star (or badge anchor) with room for a label chip around it.
    void around(_V w, {double halfW = 5, double up = 2.6, double down = 2.6}) {
      final c = cam.p(w);
      add(
        Rect.fromLTRB(
          c.dx - halfW * l,
          c.dy - up * l,
          c.dx + halfW * l,
          c.dy + down * l,
        ),
      );
    }

    for (final star in sky.stars) {
      around(star.pos);
    }
    if (sky.scenario == 0) {
      around(_dipperBadge, halfW: 6);
      // Room for the compass badge beside the Pole Star.
      around(_Star.polaris.pos, halfW: 9, up: 4.5);
      // Time-lapse: the whole circle the Dipper sweeps round the fixed Pole
      // Star stays in view, so the camera pulls back as step 5 starts.
      if (sky.step >= 5) {
        for (var i = 0; i < _sweepSamples; i++) {
          final a = 2 * math.pi * i / _sweepSamples;
          for (final w in [
            for (final star in sky.stars) star.pos,
            _dipperBadge,
          ]) {
            around(
              _aboutPole(w, a),
              halfW: _sweepRoom,
              up: _sweepRoom,
              down: _sweepRoom,
            );
          }
        }
      }
    } else {
      around(_orionBadge, halfW: 6);
      around(_dogBadge, halfW: 8);
      // The hunter's bow and club and the dog's outline.
      for (final w in [
        for (final a in _Art.values) a.pos,
        ..._orionShape,
        ..._dogShape,
      ]) {
        add(Rect.fromCircle(center: cam.p(w), radius: _cardGap));
      }
    }
    return r ?? Offset.zero & _design;
  }

  /// The framing that shows [focus] inside one of [frees] as large as
  /// possible (never above the HTML size) and moved as little as possible;
  /// also returns the free area it uses.
  static (_View, Rect) _fitView(Rect focus, List<Rect> frees) {
    _View? best;
    Rect? bestFree;
    var bestK = -1.0;
    var bestMove = double.infinity;
    for (final free in frees) {
      if (free.width <= 0 || free.height <= 0) continue;
      if (free.left <= focus.left &&
          free.top <= focus.top &&
          free.right >= focus.right &&
          free.bottom >= focus.bottom) {
        return (_View.identity, free);
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
        bestFree = free;
        bestK = k;
        bestMove = move;
      }
    }
    return (best ?? _View.identity, bestFree ?? Offset.zero & _design);
  }

  /// Shift that moves [a, b] inside [lo, hi] (centred when it is wider).
  static double _shiftInto(double a, double b, double lo, double hi) {
    if (b - a > hi - lo) return (lo + hi - a - b) / 2;
    if (a < lo) return lo - a;
    if (b > hi) return hi - b;
    return 0;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#compare-btn-container` "Observe Conclusion".
  List<LabAction> _actions() {
    final s = _sky;
    if (s.step != 5 || !s.conclusionReady) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        highlight: true,
        onTap: _conclude,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _scenarioData;
        final sky = _sky;
        final sc = sky.scenario;
        final n = data.steps.length;
        final actions = _actions();
        // The button also floats on the canvas while the sidebar is open
        // (its sidebar copy can be below the fold on a phone); with the
        // sidebar collapsed the mission card carries it.
        final cardActions = _lab.isSidebarOpen && _lab.isLabActive
            ? actions
            : const <LabAction>[];
        final slider = _sliderShown;
        final inset = labOverlayInsets(context, _lab);
        final screen = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final top = inset.top + _toastBand * s;
        final bottom =
            (_lab.isSidebarOpen ? _hudBand * s + _cardGap : _cardGap) +
            pad.bottom;
        final length =
            (screen.height -
                    pad.top -
                    top -
                    bottom -
                    _cardChrome * s -
                    (cardActions.isEmpty ? 0 : _buttonBlock * s))
                .clamp(_sliderMinLength, _sliderMaxLength * s)
                .toDouble();
        final speedMode = sc == 0 && sky.step >= 5;
        return LabShell(
          controller: _lab,
          icon: Icons.auto_awesome,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sky.step,
          // HTML `#hud-instruction` (`hud[State.step]`).
          hud: _t('s${sc + 1}_hud_${sky.step.clamp(1, n)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch12a1-steps-$sc-${sky.step}'),
            steps: data.steps,
            current: sky.step,
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
            // HTML `#s1-slider-box` (right of the canvas, vertically
            // centred) and `#compare-btn-container`.
            if (_lab.isLabActive && (slider || cardActions.isNotEmpty))
              Positioned(
                key: const ValueKey('ch12a1-controls'),
                top: top,
                bottom: bottom,
                right: inset.right,
                child: Center(
                  child: _ControlCard(
                    palette: _lab.palette,
                    scale: s,
                    width: _controlWidth(s, cardActions.isNotEmpty),
                    sliderLength: length,
                    value: slider ? _sliderValue : null,
                    min: speedMode ? 0 : _extMin,
                    max: speedMode ? _speedMax : _extMax,
                    divisions: speedMode ? _speedDivisions : _extDivisions,
                    title: _t(speedMode ? 'slider_speed' : 'slider_dist'),
                    unit: _t(
                      speedMode
                          ? 'unit_speed'
                          : (sc == 0 ? 'unit_cup' : 'unit_belt'),
                    ),
                    format: _t('slider_value'),
                    slideLabel: _t('slide'),
                    onChanged: _onSlide,
                    actions: cardActions,
                  ),
                ),
              ),
          ],
          stage: _stage(cardActions.isNotEmpty),
        );
      },
    );
  }

  Widget _stage(bool cardButton) {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        final sky = _sky;
        var labelRight = _design.width;
        var horizon = 0.0;
        if (fit > 0 && fit.isFinite) {
          final s = context.labScale;
          final card = _controlWidth(s, cardButton);
          sky
            ..fit = fit
            ..touch = _touchDp / fit
            ..labelSize =
                _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final stageTop = (box.maxHeight - _design.height * fit) / 2;
          sky.visible = Rect.fromLTWH(
            -stageLeft / fit,
            -stageTop / fit,
            box.maxWidth / fit,
            box.maxHeight / fit,
          );
          final right =
              labOverlayInsets(context, _lab).right +
              (card > 0 ? card + _cardGap : 0);
          labelRight = (box.maxWidth - right - stageLeft) / fit;
          horizon = _horizonHeight(box.maxHeight) / fit;
          sky.viewTarget = _framing(context, box.biggest, fit, card);
          if (sky.snapView) {
            sky
              ..view = sky.viewTarget
              ..snapView = false;
            sky.cam.frame(sky.view);
          }
        }
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Taps on the stars are not screen-reader actions; the scene is
            // announced by its label instead.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              _StarPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_StarPanRecognizer>(
                    () => _StarPanRecognizer(debugOwner: this),
                    (r) => r
                      // RawGestureDetector does not apply MediaQuery's
                      // gesture settings; short drags must count.
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _dragSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onDown = _onDown
                      ..onUpdate = _onDragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = _onDragCancel,
                  ),
            },
            child: Semantics(
              image: true,
              label: _t(sky.scenario == 0 ? 'scene_s1' : 'scene_s2'),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: _design,
                  painter: _SkyPainter(
                    sky: sky,
                    cache: _cache,
                    repaint: _frame,
                    lang: _lab.lang,
                    showLabels: _lab.showLabels,
                    labelSize: sky.labelSize,
                    labelRight: labelRight,
                    horizon: horizon,
                    visible: sky.visible,
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

/// HTML `#s1-slider-box` (vertical Distance Meter / Time-Lapse slider: title,
/// value chip, slider, "Slide" hint) and the "Observe Conclusion" button.
class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.sliderLength,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.title,
    required this.unit,
    required this.format,
    required this.slideLabel,
    required this.onChanged,
    required this.actions,
  });

  final LabPalette palette;
  final double scale;
  final double width;
  final double sliderLength;

  /// The slider's value, or null when no slider is shown.
  final ValueListenable<double>? value;
  final double min;
  final double max;
  final int divisions;
  final String title;
  final String unit;

  /// `{v}x {u}` (HTML `v + "x " + unit`).
  final String format;
  final String slideLabel;
  final ValueChanged<double> onChanged;
  final List<LabAction> actions;

  /// HTML slider: 8 px track, 24 px thumb (indigo); 48 dp wide to touch.
  static const double _trackHeight = 8;
  static const double _thumbRadius = 12;
  static const double _overlayRadius = 24;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final values = value;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: width,
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.fromLTRB(6 * s, 8 * s, 6 * s, 6 * s),
          borderColor: _Colors.indigo500.withValues(alpha: 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (values != null)
                ValueListenableBuilder<double>(
                  valueListenable: values,
                  builder: (context, v, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.textStrong,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(title, 0.4),
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4 * s,
                          vertical: 2 * s,
                        ),
                        decoration: BoxDecoration(
                          color: _Colors.indigo500.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labFormat(format, {
                              'v': v.toStringAsFixed(1),
                              'u': unit,
                            }),
                            maxLines: 1,
                            style: TextStyle(
                              color: p.accentInk,
                              fontSize: 10.5 * s,
                              fontWeight: FontWeight.w900,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: sliderLength,
                        width: 2 * _overlayRadius,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: _trackHeight * s,
                              activeTrackColor: _Colors.indigo500,
                              inactiveTrackColor: p.isDark
                                  ? _Colors.slate700
                                  : _Colors.slate200,
                              thumbColor: _Colors.white,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: _thumbRadius * s,
                                elevation: 3,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: _overlayRadius,
                              ),
                              overlayColor: _Colors.indigo500.withValues(
                                alpha: 0.2,
                              ),
                              showValueIndicator: ShowValueIndicator.never,
                            ),
                            child: Semantics(
                              label: title,
                              child: Slider(
                                key: _sliderKey,
                                value: v.clamp(min, max),
                                min: min,
                                max: max,
                                divisions: divisions,
                                onChanged: onChanged,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.swap_vert,
                        size: 14 * s,
                        color: _Colors.indigo400,
                      ),
                      Text(
                        slideLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 9 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (actions.isNotEmpty) ...[
                if (values != null) SizedBox(height: 6 * s),
                for (final a in actions)
                  LabActionButton(action: a, scale: s, dense: true),
              ],
            ],
          ),
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

/// The look of a floating text chip.
enum _Chip {
  /// `.star-label`.
  star,

  /// Constellation badges (amber / blue / cyan).
  dipper,
  orion,
  canis,

  /// `#compass-badge`.
  compass,
}

/// A chip to place this frame: its text, the point it labels and the
/// radius kept clear round that point.
typedef _LabelSpec = (_Chip chip, String text, Offset at, double clear);

/// Paints, paths and text reused by every frame (no allocation per frame).
class _PaintCache {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint ring = Paint()..style = PaintingStyle.stroke;
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Paint softGlow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
  final Paint points = Paint()
    ..strokeCap = StrokeCap.round
    ..color = _Colors.fieldStar;
  final Path shape = Path();
  final Path trail = Path();

  /// Projected starfield (x, y pairs; hidden points far off the stage).
  final Float32List field = Float32List(_fieldCount * 2);

  /// Horizon silhouettes for one canvas, rebuilt when it changes.
  Object? horizonKey;
  final List<(Path, Paint)> horizon = [];

  /// Chip text, by chip kind and text, for [lang] at [size].
  final Map<(_Chip, String), TextPainter> _texts = {};
  LabLang? _textLang;
  double _textSize = 0;
  String? _textFamily;

  TextPainter text(_Chip chip, String text, LabLang lang, double size) {
    final family = LabFont.active.family;
    if (lang != _textLang || size != _textSize || family != _textFamily) {
      _clearTexts();
      _textLang = lang;
      _textSize = size;
      _textFamily = family;
    }
    return _texts.putIfAbsent((chip, text), () {
      final (color, fontSize, weight, spacing) = switch (chip) {
        _Chip.star => (_Colors.white, size, FontWeight.w800, 0.0),
        _Chip.dipper => (_Colors.amberText, size * 1.05, FontWeight.w700, 0.0),
        _Chip.orion => (_Colors.blueText, size * 1.05, FontWeight.w700, 0.0),
        _Chip.canis => (_Colors.cyanText, size * 1.05, FontWeight.w700, 0.0),
        _Chip.compass => (_Colors.white, size, FontWeight.w900, 1.2),
      };
      return TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: weight,
            fontFamily: family,
            fontFamilyFallback: LabFont.active.fallback,
            letterSpacing: labLetterSpacing(text, spacing),
            height: 1.15,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
    });
  }

  /// Material icon glyphs drawn inside the badges (HTML Phosphor icons).
  final Map<(IconData, Color), TextPainter> _icons = {};
  double _iconSize = 0;

  TextPainter icon(IconData data, Color color, double size) {
    if (size != _iconSize) {
      for (final p in _icons.values) {
        p.dispose();
      }
      _icons.clear();
      _iconSize = size;
    }
    return _icons.putIfAbsent(
      (data, color),
      () => TextPainter(
        text: TextSpan(
          text: String.fromCharCode(data.codePoint),
          style: TextStyle(
            color: color,
            fontSize: size,
            fontFamily: data.fontFamily,
            package: data.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  void _clearTexts() {
    for (final p in _texts.values) {
      p.dispose();
    }
    _texts.clear();
  }

  void dispose() {
    _clearTexts();
    for (final p in _icons.values) {
      p.dispose();
    }
    _icons.clear();
  }
}

/// Paints the night sky: starfield, horizon, star trails, artwork and
/// constellation lines, the Distance Meter line, the stars and their
/// labels. Repaints every frame through [repaint].
class _SkyPainter extends CustomPainter {
  _SkyPainter({
    required this.sky,
    required this.cache,
    required Listenable repaint,
    required this.lang,
    required this.showLabels,
    required this.labelSize,
    required this.labelRight,
    required this.horizon,
    required this.visible,
  }) : super(repaint: repaint);

  /// The simulation (also read by the flow tests through the painter).
  final _Sky sky;
  final _PaintCache cache;
  final LabLang lang;
  final bool showLabels;

  /// Label text size (design px), the left edge of the tool column /
  /// control card (labels stay left of it), the horizon height and the
  /// visible canvas (design px).
  final double labelSize;
  final double labelRight;
  final double horizon;
  final Rect visible;

  /// Line widths and star sizes grow with the labels on small stages.
  double get _boost => labelSize / _labelPx;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = sky;
    final c = cache;
    canvas.drawRect(labBleed(size), c.fill..color = _Colors.night);
    _paintField(canvas);
    _paintHorizon(canvas);
    if (s.scenario == 0) {
      _paintNorth(canvas);
    } else {
      _paintWinter(canvas);
    }
    _paintGuide(canvas);
    for (final star in s.stars) {
      _paintStar(canvas, star);
    }
    _paintLabels(canvas);
  }

  // -------------------------------------------------------------- backdrop

  /// HTML `bgStarsGeom`: 1500 points (0.6 units at 80 → about 2 px), turning
  /// with the sky.
  void _paintField(Canvas canvas) {
    final s = sky;
    final cam = s.cam;
    final list = cache.field;
    for (var i = 0; i < _fieldCount; i++) {
      final w = s.sky(_field[i]);
      if (cam.depth(w) < 1) {
        list[2 * i] = -1e5;
        list[2 * i + 1] = -1e5;
        continue;
      }
      final p = cam.p(w);
      list[2 * i] = p.dx;
      list[2 * i + 1] = p.dy;
    }
    cache.points.strokeWidth = 2.1 * math.max(1, _boost * 0.8);
    canvas.drawRawPoints(ui.PointMode.points, list, cache.points);
  }

  /// HTML `#horizon-s1` (Ladakh mountains) / `#horizon-s2` (winter trees):
  /// the inline SVGs (viewBox 1440 × 320, stretched) along the bottom of the
  /// visible canvas, [horizon] design px tall.
  void _paintHorizon(Canvas canvas) {
    final c = cache;
    final key = (sky.scenario, visible, horizon);
    if (c.horizonKey != key) {
      c.horizonKey = key;
      c.horizon
        ..clear()
        ..addAll(_horizonPaths(sky.scenario, visible, horizon));
    }
    for (final (path, paint) in c.horizon) {
      canvas.drawPath(path, paint);
    }
  }

  static List<(Path, Paint)> _horizonPaths(int scenario, Rect area, double h) {
    // Bleeds well past the visible canvas so a zoomed-out canvas has no
    // seams.
    final left = area.left - area.width;
    final width = area.width;
    final bottom = area.bottom;
    Offset p(double x, double y) =>
        Offset(area.left + x / _svgW * width, bottom - (_svgH - y) / _svgH * h);
    Path ridge(List<double> xy) {
      final path = Path()..moveTo(left, p(0, xy[1]).dy);
      for (var i = 0; i < xy.length; i += 2) {
        final o = p(xy[i], xy[i + 1]);
        path.lineTo(o.dx, o.dy);
      }
      path
        ..lineTo(area.right + width, p(_svgW, xy[xy.length - 1]).dy)
        ..lineTo(area.right + width, bottom + area.height)
        ..lineTo(left, bottom + area.height)
        ..close();
      return path;
    }

    Path line(List<double> xy) {
      final path = Path();
      for (var i = 0; i < xy.length; i += 2) {
        final o = p(xy[i], xy[i + 1]);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      return path;
    }

    Paint fill(Color color) => Paint()..color = color;
    Paint edge(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round;

    if (scenario == 0) {
      return [
        // Distant, mid and foreground ridges, then the moonlit rims.
        (
          ridge(const [
            0, 220, 120, 160, 240, 190, 380, 120, 500, 170, 640, //
            90, 780, 150, 920, 100, 1060, 160, 1200, 110, 1340, 180, 1440,
            140,
          ]),
          fill(_Colors.ridgeFar),
        ),
        (
          ridge(const [
            0, 250, 160, 180, 300, 220, 450, 140, 600, 200, 740, //
            130, 880, 190, 1020, 140, 1180, 210, 1320, 160, 1440, 200,
          ]),
          fill(_Colors.ridgeMid),
        ),
        (
          ridge(const [
            0, 280, 140, 210, 260, 250, 400, 170, 540, 230, 680, //
            160, 820, 220, 960, 170, 1100, 240, 1260, 180, 1440, 230,
          ]),
          fill(_Colors.ridgeNear),
        ),
        (
          line(const [
            380, 120, 500, 170, 640, 90, 780, 150, 920, 100, 1060, //
            160,
          ]),
          edge(_Colors.rimFar, 2),
        ),
        (
          line(const [400, 170, 540, 230, 680, 160, 820, 220, 960, 170]),
          edge(_Colors.rimNear, 1.5),
        ),
      ];
    }
    // Snow slopes: `M0,240 Q360,180 720,230 T1440,210` and `M0,270
    // Q400,210 800,260 Q1200,220 1440,250`.
    Path slope(List<double> q) {
      final a = p(q[0], q[1]);
      final path = Path()
        ..moveTo(left, a.dy)
        ..lineTo(a.dx, a.dy);
      for (var i = 2; i + 3 < q.length; i += 4) {
        final c = p(q[i], q[i + 1]);
        final e = p(q[i + 2], q[i + 3]);
        path.quadraticBezierTo(c.dx, c.dy, e.dx, e.dy);
      }
      final end = p(q[q.length - 2], q[q.length - 1]);
      path
        ..lineTo(area.right + width, end.dy)
        ..lineTo(area.right + width, bottom + area.height)
        ..lineTo(left, bottom + area.height)
        ..close();
      return path;
    }

    // Pine trees: each SVG path, as (base x, base y, top y, half widths)
    // read from its points (`M x,base L x,… L x-12,… …`).
    const trees = [
      (120.0, 270.0, 185.0, 10.0),
      (150.0, 265.0, 160.0, 12.0),
      (220.0, 250.0, 150.0, 12.0),
      (380.0, 260.0, 160.0, 12.0),
      (420.0, 255.0, 145.0, 12.0),
      (680.0, 265.0, 165.0, 12.0),
      (720.0, 250.0, 152.0, 12.0),
      (980.0, 260.0, 162.0, 12.0),
      (1030.0, 255.0, 155.0, 12.0),
      (1250.0, 265.0, 165.0, 12.0),
      (1310.0, 255.0, 155.0, 12.0),
    ];
    final pines = Path();
    for (final (x, base, tip, half) in trees) {
      // Three stacked tiers like the SVG zig-zag outline.
      final hgt = base - tip;
      final pts = <Offset>[
        p(x, base),
        p(x - half * 0.15, base - hgt * 0.25),
        p(x - half, base - hgt * 0.25),
        p(x - half * 0.2, base - hgt * 0.55),
        p(x - half * 0.8, base - hgt * 0.55),
        p(x, tip),
        p(x + half * 0.8, base - hgt * 0.55),
        p(x + half * 0.2, base - hgt * 0.55),
        p(x + half, base - hgt * 0.25),
        p(x + half * 0.15, base - hgt * 0.25),
      ];
      pines.addPolygon(pts, true);
    }
    return [
      (
        slope(const [0, 240, 360, 180, 720, 230, 1080, 280, 1440, 210]),
        fill(_Colors.snowFar),
      ),
      (
        slope(const [0, 270, 400, 210, 800, 260, 1200, 220, 1440, 250]),
        fill(_Colors.snowNear),
      ),
      (pines, fill(_Colors.pine)),
      (pines, edge(_Colors.pineEdge, 0.8)),
    ];
  }

  // ------------------------------------------------------------ scenario 1

  void _paintNorth(Canvas canvas) {
    final s = sky;
    // Star trails while the sky turns (HTML `starTrailsGroup`).
    if (s.step >= 5 && s.speed > 0) _paintTrails(canvas);
    // Faint ladle outline from the start of step 1 (HTML
    // `big_dipper_faint`, opacity 0.35), gone once the ladle is found.
    if (s.step == 1) {
      _polyline(
        canvas,
        _dipperOrder,
        _Colors.faint.withValues(alpha: 0.35),
        width: 1.4,
        dashed: true,
      );
    }
    // The gold ladle line: each segment once both its stars are tapped
    // (the HTML drew the whole ladle after 4 taps).
    _segments(
      canvas,
      _dipperOrder,
      _Colors.gold.withValues(alpha: 0.95),
      (a, b) => s.step > 1 || (s.tapped.contains(a) && s.tapped.contains(b)),
    );
    // Pointer line (HTML `pointer_line`, 0x38bdf8).
    if (s.step > 2) {
      _polyline(
        canvas,
        const [_Star.merak, _Star.dubhe],
        _Colors.sky400.withValues(alpha: 0.95),
        width: 2.2,
      );
    }
    // Distance Meter line to Polaris (HTML `polaris_ext_line`, dashed red).
    if (s.step >= 3) {
      _meter(
        canvas,
        _Star.dubhe,
        _pointerDir,
        _pointerLength,
        _Colors.laserRed,
      );
    }
  }

  /// Concentric dashed rings round the Pole Star, turning with the sky.
  void _paintTrails(Canvas canvas) {
    final s = sky;
    final cam = s.cam;
    final c = cache;
    final centre = _Star.polaris.pos;
    final paint = c.stroke..strokeWidth = 1.3 * _boost;
    for (var r = _trailFirst; r <= _trailLast; r += _trailStep) {
      final dash = (3 + r * 0.2) / r;
      final gap = (2 + r * 0.1) / r;
      final path = c.trail..reset();
      for (var a = 0.0; a < 2 * math.pi - 1e-6; a += dash + gap) {
        for (var k = 0; k <= 4; k++) {
          final phi = a + dash * k / 4 + s.turn;
          final w =
              centre +
              _trailU * (r * math.cos(phi)) +
              _trailV * (r * math.sin(phi));
          if (cam.depth(w) < 1) continue;
          final o = cam.p(w);
          if (k == 0) {
            path.moveTo(o.dx, o.dy);
          } else {
            path.lineTo(o.dx, o.dy);
          }
        }
      }
      paint.color = _Colors.blue400.withValues(
        alpha: math.max(0.15, 0.75 - r * 0.012),
      );
      canvas.drawPath(path, paint);
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _paintWinter(Canvas canvas) {
    final s = sky;
    final t = s.time;
    // Hunter artwork (step 3 on): shimmering fill, outline and lines.
    if (s.step >= 3) {
      _shape(
        canvas,
        _orionShape,
        _Colors.blue400.withValues(
          alpha: _orionFill + math.sin(t * _orionRate) * _orionShimmer,
        ),
        _Colors.sky400.withValues(alpha: 0.6),
      );
      for (final (pts, color) in _orionArt) {
        _polyline(canvas, pts, color.withValues(alpha: 0.9), width: 1.8);
      }
    }
    // Dog artwork and Canis Major once Sirius is found.
    if (s.found) {
      _shape(
        canvas,
        _dogShape,
        _Colors.sky400.withValues(
          alpha: _dogFill + math.sin(t * _dogRate) * _dogShimmer,
        ),
        _Colors.sky400.withValues(alpha: 0.6),
      );
      for (final (pts, color) in _dogArt) {
        _polyline(canvas, pts, color.withValues(alpha: 0.75), width: 1.6);
      }
      for (final (pts, color) in _dogLines) {
        _polyline(canvas, pts, color.withValues(alpha: 0.95), width: 2.2);
      }
    }
    // Faint Orion outline until the hunter is complete (HTML
    // `orion_faint`, opacity 0.35).
    if (s.step <= 2) {
      _polyline(
        canvas,
        _orionOrder,
        _Colors.faint.withValues(alpha: 0.35),
        width: 1.4,
        dashed: true,
      );
    }
    bool tapped(_Star a, _Star b) =>
        s.tapped.contains(a) && s.tapped.contains(b);
    // Belt (0x60a5fa) and body (0x93c5fd) lines, segment by segment.
    _segments(
      canvas,
      _beltOrder,
      _Colors.blue400.withValues(alpha: 0.95),
      tapped,
    );
    _segments(
      canvas,
      _orionOrder,
      _Colors.blue300.withValues(alpha: 0.95),
      tapped,
    );
    // Distance Meter line to Sirius (HTML `sirius_ext_line`, dashed amber).
    if (s.step >= 3) {
      _meter(canvas, _Star.mintaka, _beltDir, _beltLength, _Colors.amber500);
    }
  }

  // --------------------------------------------------------- line helpers

  /// The Distance Meter line: from [from] along [dir], [unit] world units
  /// per 1x, as long as the slider says, with a tick at every 1x and a ring
  /// at its tip while it grows.
  void _meter(Canvas canvas, _Star from, _V dir, double unit, Color color) {
    final s = sky;
    final c = cache;
    final a = s.at(from);
    final len = unit * s.extension;
    final b = s.cam.p(s.sky(from.pos + dir * len));
    final alpha = (0.55 + (s.extension - _extMin) / 8).clamp(0.55, 1.0);
    final paint = c.stroke
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 2.2 * _boost;
    final scale = s.cam.scaleAt(from.pos);
    labDashedLine(canvas, a, b, paint, dash: 1.5 * scale, gap: 0.8 * scale);
    // Ticks across the line at 1x, 2x, … (the Distance Meter's marks).
    final along = b - a;
    final n = along.distance;
    if (n > 1) {
      final across = Offset(-along.dy / n, along.dx / n) * (5 * _boost);
      paint
        ..strokeWidth = 1.6 * _boost
        ..color = color.withValues(alpha: 0.9);
      for (var k = 1; k <= s.extension.floor(); k++) {
        final m = s.cam.p(s.sky(from.pos + dir * (unit * k)));
        canvas.drawLine(m - across, m + across, paint);
      }
    }
    if (s.step == 3) {
      canvas.drawCircle(
        b,
        4 * _boost,
        c.stroke
          ..strokeWidth = 1.5 * _boost
          ..color = color,
      );
    }
  }

  /// A polyline through [pts] (stars or artwork points), solid or dashed
  /// (HTML `LineDashedMaterial` dash 1.5, gap 0.8 units).
  void _polyline(
    Canvas canvas,
    List<_Point> pts,
    Color color, {
    double width = 2,
    bool dashed = false,
  }) {
    final s = sky;
    final paint = cache.stroke
      ..color = color
      ..strokeWidth = width * _boost;
    for (var i = 0; i + 1 < pts.length; i++) {
      final a = s.at(pts[i]);
      final b = s.at(pts[i + 1]);
      if (dashed) {
        final scale = s.cam.scaleAt(pts[i].pos);
        labDashedLine(canvas, a, b, paint, dash: 1.5 * scale, gap: 0.8 * scale);
      } else {
        canvas.drawLine(a, b, paint);
      }
    }
  }

  /// The segments of [order] for which [show] holds.
  void _segments(
    Canvas canvas,
    List<_Star> order,
    Color color,
    bool Function(_Star a, _Star b) show,
  ) {
    final s = sky;
    final paint = cache.stroke
      ..color = color
      ..strokeWidth = 2.2 * _boost;
    for (var i = 0; i + 1 < order.length; i++) {
      final a = order[i];
      final b = order[i + 1];
      if (show(a, b)) canvas.drawLine(s.at(a), s.at(b), paint);
    }
  }

  /// An artwork silhouette (HTML `createArtworkFigure`): filled, outlined.
  void _shape(Canvas canvas, List<_V> pts, Color fill, Color outline) {
    final s = sky;
    final path = cache.shape..reset();
    for (var i = 0; i < pts.length; i++) {
      final o = s.cam.p(s.sky(pts[i]));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    path.close();
    canvas.drawPath(path, cache.fill..color = fill);
    canvas.drawPath(
      path,
      cache.stroke
        ..color = outline
        ..strokeWidth = 2 * _boost,
    );
  }

  /// HTML `dragGuideLine`: dashed 0x38bdf8 from the pressed star to the
  /// finger.
  void _paintGuide(Canvas canvas) {
    final s = sky;
    final from = s.dragFrom;
    final to = s.dragTo;
    if (from == null || to == null) return;
    final scale = s.cam.scaleAt(from.pos);
    labDashedLine(
      canvas,
      s.at(from),
      to,
      cache.stroke
        ..color = _Colors.sky400
        ..strokeWidth = 2.2 * _boost,
      dash: 1.0 * scale,
      gap: 0.5 * scale,
    );
  }

  // ----------------------------------------------------------------- stars

  /// Is [star] pulsing (a target of the current step not yet found)?
  bool _pulsing(_Star star) {
    final s = sky;
    return switch ((s.scenario, s.step, star.kind)) {
      (0, 1, _Kind.dipper) => !s.tapped.contains(star),
      (0, 2, _) =>
        (star == _Star.merak || star == _Star.dubhe) &&
            !s.pointers.contains(star),
      (0, 4, _Kind.pole) => !s.found,
      (1, 1, _Kind.belt) => !s.tapped.contains(star),
      (1, 2, _Kind.corner) => !s.tapped.contains(star),
      (1, 4, _Kind.sirius) => !s.found,
      _ => false,
    };
  }

  /// HTML `pulseRing` hue / lightness of a pulsing star.
  (double, double) _pulseHue(_Star star) => switch (star.kind) {
    _Kind.dipper when sky.step == 2 => (0.85, 0.65),
    _Kind.dipper || _Kind.belt => (0.55, 0.65),
    _Kind.corner => (0.85, 0.65),
    _Kind.pole => (0.15, 0.75),
    _ => (0.55, 0.75),
  };

  /// HTML `pulseRing` base scale.
  double _pulseBase(_Star star) => switch (star.kind) {
    _Kind.dipper => sky.step == 2 ? 1.12 : 1.05,
    _Kind.belt => 1.06,
    _Kind.corner => 1.08,
    _Kind.pole => 1.18,
    _ => 1.22,
  };

  /// Colour and scale of [star] now (HTML `handleStarClick` /
  /// `resetScenarioState` material changes).
  (Color, double, double) _look(_Star star) {
    final s = sky;
    if (_pulsing(star)) {
      final wave = math.sin(s.time * _pulseRate);
      final (h, l) = _pulseHue(star);
      final color = HSLColor.fromAHSL(
        1,
        h * 360,
        0.9,
        (l + wave * 0.1).clamp(0, 1),
      ).toColor();
      return (color, _pulseBase(star) + wave * _pulseScale, wave);
    }
    if (s.pointers.contains(star)) return (_Colors.purple500, 1.22, 0);
    return switch (star.kind) {
      _Kind.dipper ||
      _Kind.belt when s.tapped.contains(star) => (_Colors.sky400, 1.18, 0),
      _Kind.corner when s.tapped.contains(star) => (_Colors.purple500, 1.2, 0),
      _Kind.pole when s.found => (_Colors.white, 1.35, 0),
      _Kind.sirius when s.found => (_Colors.sky400, 1.38, 0),
      _ => (star.color, 1.0, 0),
    };
  }

  void _paintStar(Canvas canvas, _Star star) {
    final s = sky;
    final c = cache;
    final at = s.at(star);
    final (color, scale, wave) = _look(star);
    final pulsing = _pulsing(star);
    final r = s.radius(star) * scale * (1 + (_boost - 1) * 0.5);
    // Flash of a found Polaris / Sirius (added glow; HTML "flashes
    // brilliantly", "lens flare").
    if (s.found && (star.kind == _Kind.pole || star.kind == _Kind.sirius)) {
      final k = ((s.time - s.foundAt) / _flashSeconds).clamp(0.0, 1.0);
      final flash = 1 - k;
      final steady = 0.5 + 0.15 * math.sin(s.time * 3);
      canvas.drawCircle(
        at,
        r * (2 + (_flashRadius - 2) * flash),
        c.softGlow..color = color.withValues(alpha: steady + 0.4 * flash),
      );
      if (star.kind == _Kind.sirius) {
        final spike = r * (3.2 + 0.4 * math.sin(s.time * 4));
        final paint = c.stroke
          ..strokeWidth = 1.6 * _boost
          ..color = _Colors.white.withValues(alpha: 0.7);
        canvas
          ..drawLine(at - Offset(spike, 0), at + Offset(spike, 0), paint)
          ..drawLine(at - Offset(0, spike), at + Offset(0, spike), paint);
        paint.color = _Colors.white.withValues(alpha: 0.35);
        final d = spike * 0.5;
        canvas
          ..drawLine(at - Offset(d, d), at + Offset(d, d), paint)
          ..drawLine(at - Offset(d, -d), at + Offset(d, -d), paint);
      }
    }
    // Soft halo and the glow ring (`RingGeometry(1.15 r, 1.55 r)`,
    // opacity 0.18; pulsing: scale 1.05 ±0.15, opacity 0.22 ±0.12).
    canvas.drawCircle(
      at,
      r * 1.5,
      c.glow..color = color.withValues(alpha: 0.3),
    );
    final ringScale = pulsing ? 1.05 + wave * _pulseRing : 1.0;
    final ringAlpha = pulsing ? 0.22 + wave * 0.12 : 0.18;
    final ringColor = pulsing
        ? HSLColor.fromColor(color).withLightness(0.75).toColor()
        : color;
    canvas.drawCircle(
      at,
      r * 1.35 * ringScale,
      c.ring
        ..strokeWidth = r * 0.4 * ringScale
        ..color = ringColor.withValues(alpha: (ringAlpha * 2).clamp(0, 1)),
    );
    canvas.drawCircle(at, r, c.fill..color = color);
  }

  // ---------------------------------------------------------------- labels

  /// Star names, constellation badges and the compass badge, placed so
  /// that they cover neither each other nor a star.
  void _paintLabels(Canvas canvas) {
    final s = sky;
    final specs = <_LabelSpec>[];
    if (s.scenario == 0 && s.found) {
      specs.add((
        _Chip.compass,
        _t('compass_north'),
        s.at(_Star.polaris),
        s.radius(_Star.polaris) * 2,
      ));
    }
    if (showLabels) {
      for (final star in s.stars) {
        if (!s.labelled(star)) continue;
        // While the time-lapse spins, only the fixed Pole Star keeps its
        // name (the Dipper's names would race round and pile up).
        if (s.spinning && star.kind == _Kind.dipper) continue;
        specs.add((_Chip.star, _t(star.id), s.at(star), s.radius(star) * 1.6));
      }
      Offset badge(_V w) => s.cam.p(s.sky(w));
      if (s.scenario == 0 && s.step >= 2) {
        specs.add((_Chip.dipper, _t('badge_dipper'), badge(_dipperBadge), 0));
      }
      if (s.scenario == 1 && s.step >= 3) {
        specs.add((_Chip.orion, _t('badge_orion'), badge(_orionBadge), 0));
      }
      if (s.scenario == 1 && s.found) {
        specs.add((_Chip.canis, _t('badge_canis'), badge(_dogBadge), 0));
      }
    }
    if (specs.isEmpty) return;
    // Every star of the scenario is an obstacle for the chips.
    final taken = <Rect>[
      for (final star in s.stars)
        Rect.fromCircle(center: s.at(star), radius: s.radius(star) * 1.6 + 2),
    ];
    // Chips stay in the part of the canvas no card covers (not under the
    // toast band, the HUD chip, the mission card or the tool column).
    final bounds = Rect.fromLTRB(
      math.max(visible.left + _cardGap, s.free.left),
      math.max(visible.top + _cardGap, s.free.top),
      math.min(math.min(visible.right, labelRight) - _cardGap, s.free.right),
      math.min(visible.bottom - _cardGap, s.free.bottom),
    );
    for (final spec in specs) {
      final (chip, text, at, clear) = spec;
      // A point outside the free canvas (under a card, off the stage) gets
      // no chip: pushed inside, it would label the wrong place.
      if (!bounds.contains(at)) continue;
      final size = _chipSize(chip, text);
      final rect = _place(size, at, clear, taken, bounds);
      taken.add(rect);
      _drawChip(canvas, chip, text, rect);
    }
  }

  /// Padding of each chip kind (HTML `px-2 py-0.5` labels, `px-3 py-1`
  /// badges) and the icon size of the badges.
  EdgeInsets _chipPad(_Chip chip) => chip == _Chip.star
      ? EdgeInsets.symmetric(
          horizontal: 0.7 * labelSize,
          vertical: 0.2 * labelSize,
        )
      : EdgeInsets.symmetric(
          horizontal: 0.9 * labelSize,
          vertical: 0.35 * labelSize,
        );

  double get _iconPx => labelSize * 1.25;

  IconData? _chipIcon(_Chip chip) => switch (chip) {
    _Chip.star => null,
    _Chip.dipper => Icons.auto_awesome,
    _Chip.orion => Icons.directions_walk,
    _Chip.canis => Icons.pets,
    _Chip.compass => Icons.explore,
  };

  Size _chipSize(_Chip chip, String text) {
    final tp = cache.text(chip, text, lang, labelSize);
    final pad = _chipPad(chip);
    final icon = _chipIcon(chip) == null ? 0 : _iconPx + 0.4 * labelSize;
    return Size(
      tp.width + pad.horizontal + icon,
      math.max(tp.height, icon == 0 ? 0 : _iconPx) + pad.vertical,
    );
  }

  /// The first spot round [at] (above, below, right, left, then the
  /// corners) where a chip of [size] covers nothing in [taken]; else the
  /// spot that covers least. Always inside [bounds].
  Rect _place(
    Size size,
    Offset at,
    double clear,
    List<Rect> taken,
    Rect bounds,
  ) {
    final w = size.width;
    final h = size.height;
    final g = _labelGap + clear;
    final spots = [
      Offset(at.dx - w / 2, at.dy - g - h),
      Offset(at.dx - w / 2, at.dy + g),
      Offset(at.dx + g, at.dy - h / 2),
      Offset(at.dx - g - w, at.dy - h / 2),
      Offset(at.dx + g * 0.7, at.dy - g * 0.7 - h),
      Offset(at.dx - g * 0.7 - w, at.dy - g * 0.7 - h),
      Offset(at.dx + g * 0.7, at.dy + g * 0.7),
      Offset(at.dx - g * 0.7 - w, at.dy + g * 0.7),
      Offset(at.dx - w / 2, at.dy - g - 2 * h - _labelGap),
      Offset(at.dx - w / 2, at.dy + g + h + _labelGap),
    ];
    Rect? best;
    var bestCover = double.infinity;
    for (final o in spots) {
      final r = _inside(o & size, bounds);
      var cover = 0.0;
      for (final t in taken) {
        final x = r.intersect(t);
        if (x.width > 0 && x.height > 0) cover += x.width * x.height;
      }
      if (cover == 0) return r;
      if (cover < bestCover) {
        bestCover = cover;
        best = r;
      }
    }
    return best!;
  }

  static Rect _inside(Rect r, Rect bounds) {
    var dx = 0.0;
    var dy = 0.0;
    if (r.right > bounds.right) dx = bounds.right - r.right;
    if (r.left + dx < bounds.left) dx = bounds.left - r.left;
    if (r.bottom > bounds.bottom) dy = bounds.bottom - r.bottom;
    if (r.top + dy < bounds.top) dy = bounds.top - r.top;
    return r.shift(Offset(dx, dy));
  }

  void _drawChip(Canvas canvas, _Chip chip, String text, Rect rect) {
    final c = cache;
    final (bg, border, iconColor) = switch (chip) {
      _Chip.star => (_Colors.labelBg, _Colors.labelBorder, _Colors.white),
      _Chip.dipper => (
        _Colors.amberBg,
        _Colors.amberBorder,
        _Colors.amberBorder,
      ),
      _Chip.orion => (_Colors.blueBg, _Colors.blueBorder, _Colors.blueBorder),
      _Chip.canis => (_Colors.cyanBg, _Colors.cyanBorder, _Colors.cyanBorder),
      _Chip.compass => (
        _Colors.compassBg,
        _Colors.compassBorder,
        _Colors.compassIcon,
      ),
    };
    // The compass badge bounces (HTML `animate-bounce`).
    final bounce = chip == _Chip.compass
        ? -(math.sin(sky.time * math.pi).abs()) * 0.35 * rect.height
        : 0.0;
    final box = rect.shift(Offset(0, bounce));
    final radius = chip == _Chip.star ? 0.7 * labelSize : box.height / 2;
    final rr = RRect.fromRectAndRadius(box, Radius.circular(radius));
    canvas.drawRRect(rr, c.fill..color = bg);
    canvas.drawRRect(
      rr,
      c.stroke
        ..color = border
        ..strokeWidth = 1.1 * _boost,
    );
    final pad = _chipPad(chip);
    var x = box.left + pad.left;
    final icon = _chipIcon(chip);
    if (icon != null) {
      final ip = c.icon(icon, iconColor, _iconPx);
      ip.paint(canvas, Offset(x, box.center.dy - ip.height / 2));
      x += _iconPx + 0.4 * labelSize;
    }
    final tp = c.text(chip, text, lang, labelSize);
    tp.paint(canvas, Offset(x, box.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.sky != sky ||
      old.lang != lang ||
      old.showLabels != showLabels ||
      old.labelSize != labelSize ||
      old.labelRight != labelRight ||
      old.horizon != horizon ||
      old.visible != visible;
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
