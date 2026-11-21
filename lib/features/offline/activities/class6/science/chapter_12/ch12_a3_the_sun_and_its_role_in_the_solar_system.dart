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

/// Class 6 Science • Chapter 12 (Beyond Earth) • Activity 3
/// The Sun and its Role in the Solar System.
///
/// Native Flutter port of
/// `Cl6S-Ch12-A3-The_Sun_and_its_Role_in_the_Solar_System.html` (Three.js
/// r128 + Tween.js). The HTML scenes are redrawn in 2D by [_ScenePainter]
/// through the HTML cameras (54° field of view): the starfield, the glowing
/// stars with their turning corona rings, the lit planets, the orbits and
/// the floating labels. The HTML canvas cards (the step HUD with its Next
/// button, the vertical distance slider, the temperature probe and the
/// thermometers) are cards on the canvas.
///
/// Scenario 1 (The Star Next Door: Why the Sun Looks So Big): the Earth on
/// the left, the Sun nearby (1 au) and the much larger star Sirius far away
/// (50,000 au). The vertical slider (or a sideways drag on the scene) pushes
/// the Sun out into deep space, where it shrinks to a bright dot, then
/// brings Sirius in from 50,000 au to 1 au, where it shows its real size
/// (twice the Sun). In step 4 the Sun and Sirius labels pick which star the
/// slider moves, and 'Observe Conclusion' opens the summary.
///
/// Scenario 2 (The Sun's Embrace: The Habitable Zone): the Solar System
/// from above, with the Sun, the green habitable zone, the orbiting Earth
/// (1 au) and Mars (1.5 au). The temperature probe (tap 'Drop on Earth' /
/// 'Drop on Mars', or drag it onto a planet) reads +15°C on Earth and -65°C
/// on Mars; the orbit slider then moves the Earth close to the Sun (its
/// oceans boil away, +460°C) and out past Mars (it freezes into a snowball,
/// -100°C). 'Observe Conclusion' opens the summary and 'Mastery Achieved!'.
class Ch12A3TheSunAndItsRoleInTheSolarSystemPage extends StatefulWidget {
  const Ch12A3TheSunAndItsRoleInTheSolarSystemPage({super.key});

  @override
  State<Ch12A3TheSunAndItsRoleInTheSolarSystemPage> createState() =>
      _SunLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises five Web Audio tones; here they are click (HTML `click`,
/// `science/click.mp3`: a temperature probe dropped), pop (HTML `pop`,
/// `science/click.mp3`: the Next step button, a star label picked, a step
/// card opened or closed), success (HTML `success`, `math/success.mp3`: the
/// conclusion popups), boil (HTML `boil`, `science/error.mp3`: the Earth's
/// oceans start to boil) and freeze (HTML `freeze`,
/// `science/dropdown.mp3`: the Earth starts to freeze). The shell plays
/// toggle (`science/dropdown.mp3`: sidebar), correct (`math/success.mp3`),
/// wrong (`science/error.mp3`), scenario (`science/page_open.mp3`) and
/// curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML `click`: a temperature probe dropped on a planet.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast.
  correct('audio/class6/math/success.mp3'),

  /// Shell feedback for an error toast (this lab shows none of its own).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the summary and the mastery popups.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: the Next step button, a star label picked, a step card.
  pop('audio/class6/science/click.mp3'),

  /// HTML `boil` (a sawtooth buzz): the Earth's oceans start to boil.
  boil('audio/class6/science/error.mp3'),

  /// HTML `freeze` (a falling triangle tone): the Earth starts to freeze.
  freeze('audio/class6/science/dropdown.mp3');

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
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color orange500 = Color(0xFFF97316);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color cyan200 = Color(0xFFA5F3FC);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  /// The space backdrop (HTML `#canvas-wrapper` bg-[#03071e]).
  static const Color space = Color(0xFF03071E);

  /// Glass panels: `--glass-bg` dark rgba(15, 23, 42, 0.94) and light
  /// rgba(255, 255, 255, 0.95), and `bg-slate-900/95` (probe card and
  /// thermometers, dark in both themes).
  static const Color glassDark = Color(0xF00F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color glassNight = Color(0xF20F172A);

  // --------------------------------------------------------------- scene
  /// The 2200 background stars (PointsMaterial 0xcbd5e1, opacity 0.7).
  static const Color skyStar = slate300;

  /// s1SunMesh / s2SunMesh (MeshBasicMaterial 0xf59e0b); Scenario 1 coronas
  /// 0xfab005 (opacity 0.55) and 0xf59e0b (0.25), the core dot 0xfffbeb.
  static const Color sun = amber500;
  static const Color sunCorona1 = Color(0xFFFAB005);
  static const Color sunCorona2 = amber500;
  static const Color sunCore = Color(0xFFFFFBEB);

  /// s1SiriusMesh (0x38bdf8), coronas 0x7dd3fc (0.6) and 0x0284c7 (0.3),
  /// the core dot white.
  static const Color sirius = sky400;
  static const Color siriusCorona1 = Color(0xFF7DD3FC);
  static const Color siriusCorona2 = Color(0xFF0284C7);
  static const Color siriusCore = white;

  /// The Earth (MeshLambertMaterial 0x2563eb) under its white cloud shell;
  /// the continents (added) are green 0x16a34a.
  static const Color ocean = blue600;
  static const Color land = Color(0xFF16A34A);

  /// Scorched Earth (added): dry sea beds, brown land, cracks and a hot
  /// glow; the steam particles are 0xffedd5.
  static const Color seaBed = Color(0xFF7C2D12);
  static const Color dryLand = Color(0xFFA16207);
  static const Color crack = Color(0xFF431407);
  static const Color heatGlow = orange500;
  static const Color steam = Color(0xFFFFEDD5);

  /// Snowball Earth (added): white ice and snow with an icy glow.
  static const Color ice = Color(0xFFE0F2FE);
  static const Color snow = white;
  static const Color frost = Color(0xFFBAE6FD);

  /// Mars (MeshLambertMaterial 0xef4444) with its white polar cap.
  static const Color mars = red500;
  static const Color marsCap = white;

  /// The habitable ring (0x10b981, opacity 0.22) and its edges (0.55), the
  /// Earth orbit (0x60a5fa, 0.6) and the Mars orbit (0xef4444, 0.45).
  static const Color zone = emerald500;
  static const Color earthOrbit = blue400;
  static const Color marsOrbit = red500;

  /// `.planet-label`: rgba(15, 23, 42, 0.96) with an amber, sky (Sirius),
  /// blue (Earth) or red (Mars) border at 0.85.
  static const Color labelBg = Color(0xF50F172A);

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
/// space scene stays dark in both themes.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: _Colors.glassDark, // --glass-bg rgba(15, 23, 42, 0.94)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.space,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500, // amber-500 accents
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // done steps dark:text-emerald-400
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.amber400,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.amber500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: _Colors.glassLight, // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border rgba(0, 0, 0, 0.15)
    card: _Colors.slate100, // bg-slate-100
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.space,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.amber600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // done steps text-emerald-600
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.amber400,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.amber600,
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
// the settings, the canvas-tool names and the footer) come from the shell's
// `kLabCommonStrings`. Changes:
// * "Click" / "CLICK" read "Tap" / "TAP" (the Hindi texts say "दबाएं");
// * each summary keeps the HTML's bold heading as `heading|text`
//   ([_SummaryCard] draws the heading on its own line);
// * the HTML's canvas texts that are English literals in its JavaScript
//   (step titles, the live guidance lines of `setupStepUI()`, the Next
//   button labels, the thermometer cards, the toasts and the summary note)
//   are kept word for word and get a Hindi translation, marked
//   "HTML literal"; `{au}` / `{target}` are filled in as the HTML did;
// * the HTML's start-up placeholders (overwritten before they are shown)
//   are left out;
// * keys marked "Added." are new texts: the thermometer states of a
//   scorched or frozen Earth, the probe drag hint and scene descriptions
//   for screen readers.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Sun and its Role in the Solar System',
    'app_subtitle': 'Class 6 . Beyond Earth',
    // ScenariosData[en][1].
    'scen_1_title': 'Scenario 1: The Star Next Door: Why the Sun Looks So Big',
    's1_obj':
        "To visually understand that the Sun's large apparent size is due to its proximity to Earth, not necessarily its actual size compared to other stars.",
    's1_hud_1':
        'Step 1: Observe Earth, nearby Sun (1 au), and distant Sirius on right (50,000 au | 2x Sun Size). Tap Sirius label to move Sirius or tap Sun to move Sun!',
    's1_hud_2':
        'Step 2: Drag the Sun smoothly into deep space up to 50,000 au (or use slider on right) and watch its apparent size shrink continuously into a tiny dot.',
    's1_hud_3':
        'Step 3: Now drag the star Sirius on the right smoothly from deep space toward Earth (down to 1 au) to observe its enormous actual size (2x Sun)!',
    's1_hud_4':
        "Step 4: Freely drag both stars using the vertical slider to verify distance vs apparent size. Tap 'Observe Conclusion' when ready!",
    's1_c1': 'Initial Proximity Setup',
    's1_a1':
        'Observe the initial scene. You can see the Earth on left, the Sun nearby (1 au), and a very distant, much larger star named Sirius on the right side, which appears as a small, bright dot.',
    's1_o1':
        'The user recognizes the initial setup: a large-looking Sun, a small-looking Sirius on the right, and the Earth.',
    's1_c2': 'Sun Distance vs Apparent Size',
    's1_a2':
        'TAP and DRAG the tall vertical slider on the right side up (or drag 3D Sun) to smoothly move the Sun away into deep space (> 15,000 au). Watch what happens to its size from our viewpoint.',
    's1_o2':
        'As the Sun moves farther along the Z-axis, its apparent size shrinks smoothly and continuously, and the distance counter increases to 50,000 au where it becomes a bright dot.',
    's1_c3': 'Sirius Distance vs Apparent Size',
    's1_a3':
        'Now, TAP and DRAG the vertical slider on the right side down to smoothly bring the star Sirius from its distant position towards the Earth (down to 1 au).',
    's1_o3':
        'As Sirius approaches 1 au right next to the Sun, its apparent size increases continuously, revealing it to be a massive blue-white star that is 2x larger than the Sun!',
    's1_c4': 'Comparative Experimentation',
    's1_a4':
        'DRAG the Sun and Sirius back and forth smoothly using the vertical slider to confirm how distance affects the size we see.',
    's1_o4':
        'The user internalizes the direct relationship between distance and apparent size by manipulating both stars cleanly right next to each other.',
    's1_summary':
        'Observation Complete!|'
        'The Sun looks big only because it is very, very close to us (~1 astronomical unit). Many stars in the night sky like Sirius are much bigger and brighter than our Sun, but they appear as tiny dots because they are trillions of kilometers farther away!',
    // ScenariosData[en][2].
    'scen_2_title': "Scenario 2: The Sun's Embrace: The Habitable Zone",
    's2_obj':
        "To understand how the Sun's energy creates a 'habitable zone' where a planet like Earth can sustain liquid water and life.",
    's2_hud_1':
        "Step 1: Observe Sun, Earth (1 au), and Mars (1.5 au). Tap 'Drop on Earth' and 'Drop on Mars' to probe temperatures!",
    's2_hud_2':
        'Step 2: DRAG and DROP the Temperature Probe onto Earth (+15°C) and onto Mars (-65°C) to measure their surface conditions.',
    's2_hud_3':
        "Step 3: DRAG Earth's orbit slider on the right side closer to the Sun (~0.4 au) to see oceans boil away (+460°C 🔥) and steam rise!",
    's2_hud_4':
        "Step 4: DRAG Earth's orbit slider on the right side farther away past Mars (~2.2 au) to see Earth freeze into a snowball (-100°C ❄️)!",
    's2_c1': 'Habitable Zone & Planets Setup',
    's2_a1':
        "Observe the Solar System model. You can see the Sun at the center, Earth in its green habitable orbit (1.0 au), and Mars in its red orbit (1.5 au). A 'Temperature Probe' tool is available.",
    's2_o1':
        'The user identifies the Sun, a vibrant blue-and-green Earth, and a reddish Mars in their respective orbits.',
    's2_c2': 'Measuring Surface Temperatures',
    's2_a2':
        "DRAG the Temperature Probe and DROP it onto the Earth (or tap 'Drop on Earth'). Observe the reading (+15°C). Now DRAG and DROP the probe onto Mars (-65°C).",
    's2_o2':
        'When dropped on Earth, the thermometer shows +15°C with a water droplet icon 💧. When dropped on Mars, it shows -65°C with a snowflake icon ❄️.',
    's2_c3': 'Orbit Too Close (Scorched Earth)',
    's2_a3':
        "Now, let's experiment. TAP and DRAG the right vertical orbit slider closer to the Sun (~0.4 au), halfway between its original position and the Sun.",
    's2_o3':
        'Earth moves closer. The blue oceans boil away to steam and continents turn dry, brown, and cracked! The thermometer shoots up to +460°C with a fire icon 🔥.',
    's2_c4': 'Orbit Too Far (Snowball Earth)',
    's2_a4':
        'Now, DRAG the right vertical orbit slider farther away from the Sun, past the orbit of Mars (~2.2 au).',
    's2_o4':
        'Earth moves outward past Mars. The oceans freeze solid into white ice and continents get covered in snow (-100°C with snowflake icon ❄️)!',
    's2_summary':
        'Observation Complete!|'
        'The Sun provides the perfect amount of heat and light to Earth because of our exact distance of 1 au. Too close to the Sun, and our oceans would boil away into steam. Too far away, and our entire planet would freeze solid into a snowball!',
    // i18n: the sidebar steps, the popups, the labels and the probe.
    'concept_exp': 'Observation Steps',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Instructions',
    'observation': 'Expected Outcome',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'success': 'Success!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete_desc':
        'You now understand why our Sun appears so massive and bright—because it is our cosmic neighbor—and how its precise distance creates the perfect habitable zone where water flows and life thrives on Earth!',
    'btn_conclude': 'Observe Conclusion',
    'earth_observer': 'Earth (Observer)',
    'sun_label': 'Sun',
    'sirius_label': 'Sirius',
    'sirius_desc': '2x Sun Size',
    'mars_label': 'Mars',
    'probe_tool': 'Temperature Probe:',
    'drop_earth': 'Drop on Earth',
    'drop_mars': 'Drop on Mars',
    // HTML literal: the Scenario 2 Earth label.
    'earth_label': 'Earth',
    // HTML literal: setupStepUI() step titles, status and guidance lines.
    'status_active': 'Active',
    's1_title_1': 'Step 1: Setup & Observation',
    's1_title_2': 'Step 2: Sun Distance vs Apparent Size',
    's1_title_3': 'Step 3: Sirius Distance vs Apparent Size',
    's1_title_4': 'Step 4: Comparative Experimentation ({target})',
    's1_target_sun': 'Target: Sun',
    's1_target_sirius': 'Target: Sirius on Right',
    's1_guide_1':
        'Observe Earth on left, Sun nearby (1 au), and Sirius on right (50,000 au). Tap Sirius label or drag right screen half to move Sirius!',
    's1_guide_2':
        'Drag the Sun into deep space (or drag right slider up to 50,000 au) and watch it shrink into a tiny star dot!',
    's1_guide_3':
        'Now drag the star Sirius on the right from deep space (50,000 au) down to Earth (1 au) to reveal its massive 2x Sun size!',
    's1_guide_4':
        "Tap Sun or Sirius label above to switch slider target, drag them side-by-side to compare, then tap 'Observe Conclusion'!",
    's2_title_1': 'Step 1: Habitable Zone & Planets Setup',
    's2_title_2': 'Step 2: Measuring Surface Temperatures',
    's2_title_3': 'Step 3: Orbit Too Close (Scorched Earth)',
    's2_title_4': 'Step 4: Orbit Too Far (Snowball Earth)',
    's2_guide_1':
        "Observe Sun, Earth (1 au), and Mars (1.5 au). Tap 'Drop on Earth' and 'Drop on Mars' to probe temperatures!",
    's2_guide_2':
        'Drop the Probe onto both Earth (+15°C) and Mars (-65°C) to compare their temperatures!',
    's2_guide_3':
        'Drag right vertical slider smoothly down to bring Earth closer (~0.4 au) to see oceans boil away (+460°C 🔥)!',
    's2_guide_4':
        'Drag right vertical slider smoothly up past Mars (~2.2 au) to observe Earth freeze solid into a snowball (-100°C ❄️)!',
    // HTML literal: the Next button labels.
    'next_s1_2': 'Start Step 2 (Drag Sun)',
    'next_s1_3': 'Start Step 3 (Sirius)',
    'next_s1_4': 'Start Step 4 (Experiment)',
    'next_s2_3': 'Start Step 3 (Boil Earth)',
    'next_s2_4': 'Start Step 4 (Freeze Earth)',
    // HTML literal: the slider's Scenario 2 target.
    'slider_orbit': 'Orbit',
    // HTML literal: useProbeOn() toasts and the thermometer cards.
    'toast_earth': 'Measured Earth: +15°C',
    'toast_mars': 'Measured Mars: -65°C',
    'therm_earth': 'Earth Status',
    'therm_mars': 'Mars Status',
    'cond_water': 'Liquid Water',
    'cond_freezing': 'Freezing Cold',
    'zone_habitable': 'Habitable Zone ({au} au)',
    'zone_beyond': 'Beyond Habitable ({au} au)',
    // HTML literal: the summary modal's note.
    'summary_note':
        'Scenario complete! Select the next scenario from the sidebar to continue your scientific journey.',
    // Added: a scorched and a frozen Earth on the thermometer.
    'cond_scorched': 'Scorched Earth',
    'cond_snowball': 'Snowball Earth',
    'zone_close': 'Too Close to the Sun ({au} au)',
    // Added: the probe's drag handle.
    'probe_hint': 'Drag the probe onto Earth or Mars',
    // Added: scene descriptions for screen readers.
    'scene_s1':
        'Space: the Earth on the left, the Sun nearby and the star Sirius far away on the right',
    'scene_s2':
        'The Solar System from above: the Sun, the green habitable zone, the Earth and Mars on their orbits',
  },
  'hi': {
    'app_title': 'सूर्य और सौरमंडल में उसकी भूमिका',
    'app_subtitle': 'कक्षा 6 . पृथ्वी के पार (Beyond Earth)',
    'scen_1_title':
        'परिदृश्य 1: पड़ोस का तारा - सूर्य इतना बड़ा क्यों दिखता है',
    's1_obj':
        'यह दृष्टिगत रूप से समझना कि सूर्य का बड़ा आकार पृथ्वी से उसकी निकटता के कारण है, न कि अन्य तारों की तुलना में उसके वास्तविक आकार के कारण।',
    's1_hud_1':
        'चरण 1: प्रारंभिक स्थिति देखें। पृथ्वी, निकट स्थित सूर्य (1 au), और दाईं ओर दूर स्थित सीरियस (50,000 au)। जांच शुरू करने के लिए दायां स्लाइडर या सूर्य को दूर खींचें!',
    's1_hud_2':
        'चरण 2: सूर्य को पृथ्वी से दूर अंतरिक्ष की ओर खींचें (50,000 au तक) और देखें कि उसका आकार कैसे छोटा होता है।',
    's1_hud_3':
        'चरण 3: अब दाईं ओर स्थित सीरियस (Sirius) तारे को उसकी दूर की स्थिति से पृथ्वी की ओर (1 au तक) खींचें और उसका विशाल आकार देखें!',
    's1_hud_4':
        "चरण 4: दोनों तारों की दूरी बदलकर प्रयोग करें और अंत में निष्कर्ष देखने के लिए 'निष्कर्ष देखें' बटन दबाएं।",
    's1_c1': 'प्रारंभिक स्थिति का अवलोकन',
    's1_a1':
        "प्रारंभिक दृश्य का अवलोकन करें। आप बाईं ओर पृथ्वी, निकट स्थित सूर्य (1 au), और दाईं ओर बहुत दूर स्थित एक बहुत बड़ा तारा 'सीरियस' (वास्तविक आकार: सूर्य से 2 गुना) देख सकते हैं, जो एक छोटे चमकीले बिंदु जैसा दिखता है।",
    's1_o1':
        'उपयोगकर्ता प्रारंभिक स्थिति को समझता है: बड़ा दिखने वाला सूर्य, दाईं ओर छोटा दिखने वाला सीरियस तारा, और पृथ्वी।',
    's1_c2': 'सूर्य की दूरी और आभासी आकार',
    's1_a2':
        'दाईं ओर स्थित वर्टिकल स्लाइडर को ऊपर खींचें (या सूर्य के 3D मॉडल को खींचें) और सूर्य को सीधे दूर गहरे अंतरिक्ष की ओर ले जाएं (> 15,000 au)। देखें कि हमारे दृष्टिकोण से उसके आकार में क्या परिवर्तन होता है।',
    's1_o2':
        'जैसे-जैसे सूर्य दूर जाता है, उसका आभासी आकार तेजी से छोटा होता जाता है और 50,000 au पर पहुँचकर वह एक छोटे चमकीले बिंदु जैसा हो जाता है।',
    's1_c3': 'सीरियस तारे की दूरी और आभासी आकार',
    's1_a3':
        'अब, दाईं ओर स्थित वर्टिकल स्लाइडर को नीचे खींचें और सीरियस (Sirius) तारे को उसकी दूर की स्थिति से पृथ्वी की ओर (1 au तक) लाएं।',
    's1_o3':
        'जैसे ही सीरियस सूर्य के ठीक दाईं ओर 1 au की दूरी पर आता है, उसका आकार अत्यधिक बड़ा दिखता है, जिससे स्पष्ट होता है कि वह सूर्य से दोगुना बड़ा नीला-श्वेत तारा है!',
    's1_c4': 'तुलनात्मक प्रयोग',
    's1_a4':
        'यह पुष्टि करने के लिए कि दूरी हमारे द्वारा देखे जाने वाले आकार को कैसे प्रभावित करती है, दाईं ओर के वर्टिकल स्लाइडर का उपयोग कर सूर्य और सीरियस को आगे-पीछे खींचें।',
    's1_o4':
        'उपयोगकर्ता अंतरिक्ष में दोनों तारों को पास-पास खींचकर दूरी और आभासी आकार के बीच के सीधे संबंध को भली-भांति समझता है।',
    's1_summary':
        'अवलोकन पूर्ण!|'
        'सूर्य केवल इसलिए इतना बड़ा दिखता है क्योंकि यह हमारे बहुत, बहुत निकट (~1 खगोलीय इकाई) है। रात के आकाश में सीरियस जैसे कई तारे हमारे सूर्य से बहुत बड़े और चमकीले हैं, लेकिन वे छोटे बिंदुओं की तरह दिखते हैं क्योंकि वे हमसे खरबों किलोमीटर दूर हैं!',
    'scen_2_title':
        'परिदृश्य 2: सूर्य का आलिंगन - रहने योग्य क्षेत्र (Habitable Zone)',
    's2_obj':
        "यह समझना कि सूर्य की ऊर्जा किस प्रकार एक 'रहने योग्य क्षेत्र (Habitable Zone)' का निर्माण करती है जहाँ पृथ्वी जैसा ग्रह तरल जल और जीवन को बनाए रख सकता है।",
    's2_hud_1':
        "चरण 1: सूर्य, पृथ्वी (1 au) और मंगल (1.5 au) के मॉडल को देखें। तापमान जांचने के लिए 'Drop on Earth' और 'Drop on Mars' दबाएं!",
    's2_hud_2':
        'चरण 2: तापमान जांच (Probe) को खींचकर पृथ्वी (+15°C) और मंगल (-65°C) पर छोड़ें और तापमान मापें।',
    's2_hud_3':
        'चरण 3: दाईं ओर के स्लाइडर से पृथ्वी की कक्षा को सूर्य के करीब (~0.4 au) लाएं और देखें कि अत्यधिक गर्मी से भाप उठती है (+460°C 🔥)!',
    's2_hud_4':
        'चरण 4: दाईं ओर के स्लाइडर से पृथ्वी की कक्षा को मंगल के पार (~2.2 au) खींचें और देखें कि पृथ्वी बर्फ का गोला (-100°C ❄️) बन जाती है!',
    's2_c1': 'रहने योग्य क्षेत्र और ग्रहों की स्थिति',
    's2_a1':
        "सौरमंडल के मॉडल का अवलोकन करें। आप केंद्र में सूर्य, अपनी कक्षा में पृथ्वी (1 au) और मंगल (1.5 au) को देख सकते हैं। एक 'तापमान जांच (Temperature Probe)' उपकरण उपलब्ध है।",
    's2_o1':
        'उपयोगकर्ता अपनी कक्षाओं में स्थित सूर्य, हरी-भरी पृथ्वी और लाल रंग के मंगल ग्रह की पहचान करता है।',
    's2_c2': 'सतह का तापमान मापना',
    's2_a2':
        "तापमान जांच (Probe) को खींचकर (Drag करके) पृथ्वी पर छोड़ें (या 'Drop on Earth' दबाएं) और तापमान नोट करें (+15°C)। अब, जांच को मंगल ग्रह पर छोड़ें (-65°C)।",
    's2_o2':
        'पृथ्वी पर छोड़ने पर थर्मामीटर +15°C और पानी की बूंद 💧 दिखाता है। मंगल पर छोड़ने पर यह -65°C और बर्फ का निशान ❄️ दिखाता है।',
    's2_c3': 'कक्षा बहुत करीब (झुलसी पृथ्वी)',
    's2_a3':
        'अब प्रयोग करते हैं। दाईं ओर स्थित वर्टिकल स्लाइडर से पृथ्वी की पूरी कक्षा को सूर्य के करीब लाएं (~0.4 au पर)।',
    's2_o3':
        'पृथ्वी करीब आती है। समुद्र उबलकर भाप बन जाते हैं और धरती सूखी, भूरी और फटी हुई हो जाती है! थर्मामीटर +460°C और आग का निशान 🔥 दिखाता है।',
    's2_c4': 'कक्षा बहुत दूर (बर्फीली पृथ्वी)',
    's2_a4':
        'अब दाईं ओर स्थित वर्टिकल स्लाइडर से पृथ्वी की कक्षा को सूर्य से दूर, मंगल ग्रह की कक्षा के पार खींचें (~2.2 au पर)।',
    's2_o4':
        'पृथ्वी मंगल के पार जाती है। समुद्र जमकर ठोस बर्फ बन जाते हैं और पूरी धरती बर्फ की चादर (-100°C ❄️) से ढक जाती है!',
    's2_summary':
        'अवलोकन पूर्ण!|'
        'सूर्य हमारी सटीक दूरी (1 au) के कारण पृथ्वी को ऊष्मा और प्रकाश की सही मात्रा प्रदान करता है। यदि हम सूर्य के बहुत पास होते, तो समुद्र उबलकर भाप बन जाते। यदि हम बहुत दूर होते, तो पूरी पृथ्वी बर्फ का गोला बन जाती!',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'निर्देश',
    'observation': 'अपेक्षित परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'success': 'सफलता!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete_desc':
        'अब आप समझ चुके हैं कि सूर्य इतना विशाल और चमकीला क्यों दिखता है—क्योंकि वह हमारा निकटतम तारा है—और उसकी सटीक दूरी कैसे एक रहने योग्य क्षेत्र (Habitable Zone) बनाती है जहाँ पृथ्वी पर तरल जल और जीवन संभव है!',
    'btn_conclude': 'निष्कर्ष देखें',
    'earth_observer': 'पृथ्वी (प्रेक्षक)',
    'sun_label': 'सूर्य',
    'sirius_label': 'सीरियस तारा',
    'sirius_desc': 'सूर्य से 2 गुना बड़ा',
    'mars_label': 'मंगल ग्रह',
    'probe_tool': 'तापमान जांच:',
    'drop_earth': 'पृथ्वी पर डालें',
    'drop_mars': 'मंगल पर डालें',
    'earth_label': 'पृथ्वी',
    // Hindi for the HTML literals.
    'status_active': 'सक्रिय',
    's1_title_1': 'चरण 1: प्रारंभिक स्थिति और अवलोकन',
    's1_title_2': 'चरण 2: सूर्य की दूरी और आभासी आकार',
    's1_title_3': 'चरण 3: सीरियस की दूरी और आभासी आकार',
    's1_title_4': 'चरण 4: तुलनात्मक प्रयोग ({target})',
    's1_target_sun': 'लक्ष्य: सूर्य',
    's1_target_sirius': 'लक्ष्य: दाईं ओर सीरियस',
    's1_guide_1':
        'बाईं ओर पृथ्वी, निकट सूर्य (1 au) और दाईं ओर सीरियस (50,000 au) देखें। सीरियस को खिसकाने के लिए उसके लेबल पर टैप करें या स्क्रीन के दाएं आधे भाग पर खींचें!',
    's1_guide_2':
        'सूर्य को गहरे अंतरिक्ष में खींचें (या दाएं स्लाइडर को 50,000 au तक ऊपर खींचें) और उसे एक छोटे तारे जैसे बिंदु में सिकुड़ते देखें!',
    's1_guide_3':
        'अब दाईं ओर के सीरियस तारे को गहरे अंतरिक्ष (50,000 au) से नीचे पृथ्वी (1 au) तक खींचें और सूर्य से 2 गुना बड़ा उसका विशाल आकार देखें!',
    's1_guide_4':
        "स्लाइडर का लक्ष्य बदलने के लिए ऊपर सूर्य या सीरियस के लेबल पर टैप करें, तुलना के लिए दोनों को पास-पास खींचें, फिर 'निष्कर्ष देखें' पर टैप करें!",
    's2_title_1': 'चरण 1: रहने योग्य क्षेत्र और ग्रहों की स्थिति',
    's2_title_2': 'चरण 2: सतह का तापमान मापना',
    's2_title_3': 'चरण 3: कक्षा बहुत करीब (झुलसी पृथ्वी)',
    's2_title_4': 'चरण 4: कक्षा बहुत दूर (बर्फीली पृथ्वी)',
    's2_guide_1':
        "सूर्य, पृथ्वी (1 au) और मंगल (1.5 au) को देखें। तापमान जांचने के लिए 'पृथ्वी पर डालें' और 'मंगल पर डालें' पर टैप करें!",
    's2_guide_2':
        'तापमान की तुलना करने के लिए जांच (Probe) को पृथ्वी (+15°C) और मंगल (-65°C) दोनों पर छोड़ें!',
    's2_guide_3':
        'पृथ्वी को करीब (~0.4 au) लाने के लिए दाएं वर्टिकल स्लाइडर को धीरे-धीरे नीचे खींचें और महासागरों को उबलते देखें (+460°C 🔥)!',
    's2_guide_4':
        'दाएं वर्टिकल स्लाइडर को धीरे-धीरे ऊपर मंगल के पार (~2.2 au) खींचें और पृथ्वी को बर्फ के गोले (-100°C ❄️) में जमते देखें!',
    'next_s1_2': 'चरण 2 शुरू करें (सूर्य खींचें)',
    'next_s1_3': 'चरण 3 शुरू करें (सीरियस)',
    'next_s1_4': 'चरण 4 शुरू करें (प्रयोग)',
    'next_s2_3': 'चरण 3 शुरू करें (पृथ्वी उबालें)',
    'next_s2_4': 'चरण 4 शुरू करें (पृथ्वी जमाएं)',
    'slider_orbit': 'कक्षा',
    'toast_earth': 'पृथ्वी का तापमान मापा गया: +15°C',
    'toast_mars': 'मंगल का तापमान मापा गया: -65°C',
    'therm_earth': 'पृथ्वी की स्थिति',
    'therm_mars': 'मंगल की स्थिति',
    'cond_water': 'तरल जल',
    'cond_freezing': 'कड़ाके की ठंड',
    'zone_habitable': 'रहने योग्य क्षेत्र ({au} au)',
    'zone_beyond': 'रहने योग्य क्षेत्र से परे ({au} au)',
    'summary_note':
        'परिदृश्य पूर्ण! अपनी वैज्ञानिक यात्रा जारी रखने के लिए साइडबार से अगला परिदृश्य चुनें।',
    // Added.
    'cond_scorched': 'झुलसी पृथ्वी',
    'cond_snowball': 'बर्फीली पृथ्वी',
    'zone_close': 'सूर्य के बहुत करीब ({au} au)',
    'probe_hint': 'जांच को पृथ्वी या मंगल पर खींचें',
    'scene_s1':
        'अंतरिक्ष: बाईं ओर पृथ्वी, पास में सूर्य और दाईं ओर बहुत दूर सीरियस तारा',
    'scene_s2':
        'ऊपर से सौरमंडल: सूर्य, हरा रहने योग्य क्षेत्र, और अपनी कक्षाओं में पृथ्वी और मंगल',
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
    title: t('scen_${n}_title'),
    objective: t('s${n}_obj'),
    steps: [
      for (var i = 1; i <= _stepCount; i++)
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

/// The HTML animates its scene per frame at 60 frames per second.
const double _fps = 60;

/// Longest step (s) the animation takes in one frame, so a stalled frame
/// does not make the orbits jump.
const double _maxFrameStep = 0.05;

/// Screens shorter than this (phones in landscape) get the compact cards.
const double _compactBelow = 480;

/// Narrower screens get the HTML's small probe card (`w-[170px]`).
const double _narrowBelow = 640;

/// Smallest touch target on the scene (logical px).
const double _minTouch = 48;

// ------------------------------------------------------------------ cameras
// HTML `init3D()` / `resetCamera()`: PerspectiveCamera(54°) at (0, 6, 60)
// looking at (0, 1, -20) in Scenario 1 and at (0, -10, 110) looking at
// (0, -10, 0) in Scenario 2 (straight down on the orbits).

const double _fovDegrees = 54;
const _V _eyeS1 = _V(0, 6, 60);
const _V _lookS1 = _V(0, 1, -20);
const _V _eyeS2 = _V(0, -10, 110);
const _V _lookS2 = _V(0, -10, 0);

/// Design px per world unit at depth 1 for the stage height.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees / 2 * math.pi / 180);

/// Zoom of the HTML camera and the stage point the look-at point is drawn
/// at, so the scene stays clear of the cards on the canvas: the slider or
/// probe card (right), the step card (bottom) and, with the sidebar
/// collapsed, the floating mission card (top left).
@immutable
class _Frame {
  const _Frame(this.zoom, this.center);

  final double zoom;
  final Offset center;

  static _Frame lerp(_Frame a, _Frame b, double t) => _Frame(
    a.zoom + (b.zoom - a.zoom) * t,
    Offset.lerp(a.center, b.center, t)!,
  );
}

/// Framing per scenario with the sidebar open and collapsed.
const List<_Frame> _framesOpen = [
  _Frame(1, Offset(470, 280)),
  _Frame(0.9, Offset(470, 290)),
];
const List<_Frame> _framesClosed = [
  _Frame(0.92, Offset(590, 290)),
  _Frame(0.82, Offset(600, 295)),
];

/// On phones (see [_compactBelow]) the scene is drawn this much higher,
/// clear of the step card at the bottom.
const double _compactRise = 40;

/// The scene glides to the other framing in this time (s) when the sidebar
/// opens or closes.
const double _reframeSeconds = 0.38;

// ------------------------------------------------------------------- labels
// HTML `.planet-label`: 11.5 px extra-bold text, a 14 px icon 6 px before
// it, 5 × 13 px padding, 12 px corners and a 1.5 px border; its bottom
// sits `offsetY` px above the body's centre.

const double _labelPx = 11.5;
const double _labelIconPx = 14;
const double _labelGap = 6;
const double _labelPadX = 13;
const double _labelPadY = 5;
const double _labelRadius = 12;

/// Canvas labels are enlarged up to [_labelMaxBoost] when the stage is
/// drawn smaller than [_labelFullScale].
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// `updateLabelDOM(…, offsetY)` per label.
const double _liftEarthS1 = -22;
const double _liftSunS1 = -28;
const double _liftSirius = -32;
const double _liftSunS2 = -28;
const double _liftEarthS2 = -24;
const double _liftMars = -22;

// --------------------------------------------------------------- background
// HTML `init3D()`: 2200 points on a shell of radius 180–240 around the
// origin, PointsMaterial 0xcbd5e1, size 0.85 (size-attenuated: 0.85 ×
// canvas height / 2 / depth px, about 1.2 px), opacity 0.7.

const int _skyCount = 2200;
const double _skyInner = 180;
const double _skySpan = 60;
const double _skyPointPx = 1.25;
const double _skyOpacity = 0.7;

final List<_V> _skyStars = () {
  final rnd = math.Random(2200);
  return [
    for (var i = 0; i < _skyCount; i++)
      () {
        final theta = rnd.nextDouble() * 2 * math.pi;
        final phi = math.acos(2 * rnd.nextDouble() - 1);
        final r = _skyInner + rnd.nextDouble() * _skySpan;
        return _V(
          r * math.sin(phi) * math.cos(theta),
          r * math.sin(phi) * math.sin(theta),
          r * math.cos(phi),
        );
      }(),
  ];
}();

// --------------------------------------------------------------- scenario 1
// HTML `setupScenario1Objects()`.

/// The Earth (radius 3.8 at (-15, -2, 14)) under its white cloud shell
/// (radius 3.96, opacity 0.45), turning 0.006 rad a frame.
const _V _earthAt = _V(-15, -2, 14);
const double _earthR = 3.8;
const double _earthShellR = 3.96;
const double _earthVeil = 0.45;
const double _earthSpinS1 = 0.006 * _fps;

/// The Sun: radius 6.2 at (-3, 1, z), z = 0 at 1 au to -380 at 50,000 au;
/// corona rings 6.5–12 and 12–19; the core dot (radius 2.4) grows by
/// 1 + au / 50,000 × 12 so the far Sun stays a bright dot. It turns
/// 0.003 rad a frame (its rings with it).
const double _sunX = -3;
const double _sunY = 1;
const double _sunR = 6.2;
const double _sunCoreR = 2.4;
const double _sunCoreGrow = 12;
const double _sunSpin = 0.003 * _fps;

/// Sirius: radius 12.4 at (16, 3, z), z = -380 at 50,000 au to 0 at 1 au;
/// corona rings 12.9–24 and 24–36; the core dot (radius 4.5) grows by
/// 1 + au / 50,000 × 10. It turns -0.004 rad a frame.
const double _siriusX = 16;
const double _siriusY = 3;
const double _siriusR = 12.4;
const double _siriusCoreR = 4.5;
const double _siriusCoreGrow = 10;
const double _siriusSpin = -0.004 * _fps;

/// The depth of 50,000 au (`-380`).
const double _farZ = -380;

/// Distance range of both stars (au) and the slider's scale.
const double _minAu = 1;
const double _maxAu = 50000;

/// Step 2's Next button shows once the Sun is this far (au); step 3's once
/// Sirius is this close.
const double _sunFarAu = 35000;
const double _siriusNearAu = 3500;

/// A sideways drag on the scene moves the star by this much per px.
const double _auPerPx = 100;

/// Point lights: the Sun (0xfffbeb, 2.6, range 600) and Sirius (0xe0f2fe,
/// 3.5, range 800), which light the Earth.
const double _sunLight = 2.6;
const double _sunLightRange = 600;
const double _siriusLight = 3.5;
const double _siriusLightRange = 800;

/// A corona ring: inner and outer radius, colour and opacity.
typedef _Ring = (double inner, double outer, Color color, double opacity);

const List<_Ring> _sunRings = [
  (6.5, 12, _Colors.sunCorona1, 0.55),
  (12, 19, _Colors.sunCorona2, 0.25),
];
const List<_Ring> _siriusRings = [
  (12.9, 24, _Colors.siriusCorona1, 0.6),
  (24, 36, _Colors.siriusCorona2, 0.3),
];

// --------------------------------------------------------------- scenario 2
// HTML `setupScenario2Objects()`: the orbits lie in the XY plane.

/// The Sun (radius 5.2) with its corona ring 5.5–9.5 (opacity 0.4),
/// turning 0.004 rad a frame.
const double _s2SunR = 5.2;
const List<_Ring> _s2SunRings = [(5.5, 9.5, _Colors.sun, 0.4)];
const double _s2SunSpin = 0.004 * _fps;

/// Its point light (2.2, range 400).
const double _s2SunLight = 2.2;
const double _s2SunLightRange = 400;

/// The habitable ring (19–29) and the Earth's orbit radius per au (24).
const double _zoneInner = 19;
const double _zoneOuter = 29;
const double _auUnits = 24;

/// The Earth (radius 3.1) under its cloud shell (3.25, opacity 0.38),
/// turning 0.01 rad a frame; its group orbits 0.015 / √au rad a frame.
const double _s2EarthR = 3.1;
const double _s2EarthShellR = 3.25;
const double _s2EarthVeil = 0.38;
const double _earthSpinS2 = 0.01 * _fps;
const double _orbitRate = 0.015 * _fps;

/// Orbit slider range (au), step 3's Next threshold and the drag rate.
const double _minOrbitAu = 0.3;
const double _maxOrbitAu = 2.5;
const double _closeAu = 0.65;
const double _orbitAuPerPx = 0.005;

/// Mars (radius 2.2) on its orbit (36) at `time × 0.0003` rad, with a
/// white polar cap 0.5 rad wide.
const double _marsR = 2.2;
const double _marsOrbit = 36;
const double _marsRate = 0.3;
const double _marsCap = 0.5;
const double _marsAu = 1.5;

/// The eight steam puffs (radius 0.8, 0xffedd5) the HTML attaches to the
/// Earth: here they rise and fade over 1.4 s (its `steamRise` animation:
/// up 28 px, scale 0.6 → 1.5, opacity 0.9 → 0) while the Earth is hot.
const int _steamCount = 8;
const double _steamR = 0.8;
const double _steamSeconds = 1.4;

final List<Offset> _steamAt = () {
  final rnd = math.Random(8);
  return [
    for (var i = 0; i < _steamCount; i++)
      Offset(
        (rnd.nextDouble() - 0.5) * 4 / _s2EarthR,
        (rnd.nextDouble() - 0.5) * 4 / _s2EarthR,
      ),
  ];
}();

// ------------------------------------------------------------ temperatures
// The thermometer reads +15°C at 1 au, +460°C at about 0.4 au, -65°C at
// Mars' 1.5 au and -100°C at about 2.2 au (the HTML step texts), and no
// further beyond them. In between it follows straight lines through 100°C
// (water boils) at the inner edge of the habitable ring and 0°C (water
// freezes) at its outer edge.

const List<(double, double)> _tempCurve = [
  (0.4, 460),
  (_zoneInner / _auUnits, 100),
  (1, 15),
  (_zoneOuter / _auUnits, 0),
  (1.5, -65),
  (2.2, -100),
];

/// Surface temperature (°C) of the Earth at [au].
double _surfaceTemp(double au) {
  final c = _tempCurve;
  if (au <= c.first.$1) return c.first.$2;
  for (var i = 1; i < c.length; i++) {
    final (a1, t1) = c[i];
    if (au <= a1) {
      final (a0, t0) = c[i - 1];
      return t0 + (t1 - t0) * (au - a0) / (a1 - a0);
    }
  }
  return c.last.$2;
}

/// The thermometer's reading: [_surfaceTemp] to the nearest 5°C.
int _shownTemp(double au) => (_surfaceTemp(au) / 5).round() * 5;

/// '+15°C' / '-65°C', as the HTML badges.
String _tempText(int celsius) => celsius > 0 ? '+$celsius°C' : '$celsius°C';

/// How scorched (0–1) and how frozen (0–1) the Earth looks at [celsius].
double _heatOf(double celsius) => ((celsius - 60) / 300).clamp(0.0, 1.0);
double _coldOf(double celsius) => ((5 - celsius) / 105).clamp(0.0, 1.0);

/// The Earth's state on the thermometer: its title and zone texts, icon
/// and colours (badge text, icon box).
enum _Climate {
  scorched(
    'cond_scorched',
    'zone_close',
    Icons.local_fire_department,
    _Colors.red400,
    _Colors.red500,
  ),
  water(
    'cond_water',
    'zone_habitable',
    Icons.water_drop,
    _Colors.emerald400,
    _Colors.blue500,
  ),
  freezing(
    'cond_freezing',
    'zone_beyond',
    Icons.ac_unit,
    _Colors.cyan400,
    _Colors.cyan500,
  ),
  snowball(
    'cond_snowball',
    'zone_beyond',
    Icons.ac_unit,
    _Colors.cyan400,
    _Colors.cyan500,
  );

  const _Climate(this.titleKey, this.zoneKey, this.icon, this.tone, this.box);

  final String titleKey;
  final String zoneKey;
  final IconData icon;
  final Color tone;
  final Color box;

  /// 100°C and up: the oceans boil; 0°C and below: they freeze; -90°C and
  /// below: a snowball.
  static _Climate of(double celsius) {
    if (celsius >= 100) return scorched;
    if (celsius > 0) return water;
    if (celsius > -90) return freezing;
    return snowball;
  }
}

// ------------------------------------------------------------------- Earth
// Added continents (longitude, latitude, angular radius) so the Earth reads
// as blue-and-green (the HTML step texts); the cracks of a scorched Earth
// are polylines in longitude / latitude.

const List<(double, double, double)> _continents = [
  (0.2, 0.55, 0.42),
  (0.55, -0.35, 0.36),
  (1.9, 0.2, 0.5),
  (2.7, -0.5, 0.3),
  (3.9, 0.45, 0.55),
  (4.4, -0.25, 0.28),
  (5.4, 0.05, 0.32),
];
const int _continentPoints = 16;

final List<List<double>> _continentWobble = () {
  final rnd = math.Random(7);
  return [
    for (var i = 0; i < _continents.length; i++)
      [
        for (var j = 0; j < _continentPoints; j++)
          0.72 + rnd.nextDouble() * 0.38,
      ],
  ];
}();

final List<List<(double, double)>> _cracks = () {
  final rnd = math.Random(11);
  return [
    for (var i = 0; i < 9; i++)
      () {
        var lon = rnd.nextDouble() * 2 * math.pi;
        var lat = (rnd.nextDouble() - 0.5) * 1.6;
        final heading = rnd.nextDouble() * 2 * math.pi;
        return [
          for (var j = 0; j < 6; j++)
            () {
              final point = (lon, lat);
              final turn = heading + (rnd.nextDouble() - 0.5) * 1.6;
              lon += math.cos(turn) * 0.22;
              lat += math.sin(turn) * 0.18;
              return point;
            }(),
        ];
      }(),
  ];
}();

// ------------------------------------------------------------------ confetti
// canvas-confetti in `triggerConclusion()` for Scenario 2: 150 pieces,
// spread 70°, origin y 0.3; start velocity 45, decay 0.9 per tick, gravity
// 3 px per tick, 200 ticks of 1/60 s.

const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;
const int _confettiCount = 150;
const double _confettiSpread = 70;
const Offset _confettiOrigin = Offset(0.5, 0.3);

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
  _V get unit {
    final l = length;
    return l > 0 ? this * (1 / l) : this;
  }
}

/// The HTML PerspectiveCamera projected onto the design stage: [eye]
/// looking at the look-at point, zoomed and centred by a [_Frame].
@immutable
class _Cam {
  factory _Cam(_V eye, _V look, _Frame frame) {
    final f = (look - eye).unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Cam._(eye, f, r, r.cross(f), _focal * frame.zoom, frame.center);
  }

  const _Cam._(this.eye, this.f, this.r, this.u, this.focal, this.center);

  final _V eye;
  final _V f;
  final _V r;
  final _V u;
  final double focal;
  final Offset center;

  double depth(_V w) => (w - eye).dot(f);
  bool inFront(_V w) => depth(w) > 0.1;

  /// Design px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// A world direction in camera space: x right, y up, z towards the
  /// camera.
  _V view(_V dir) => _V(dir.dot(r), dir.dot(u), -dir.dot(f));
}

// ------------------------------------------------------------------ easing

typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = t - 1;
  return k * k * k + 1;
}

/// A number eased from [from] to [to], read at the scene time.
@immutable
class _Ramp {
  const _Ramp(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.ease = _linear,
  ]);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0,
      ease = _linear;

  final double from;
  final double to;
  final double start;
  final double seconds;
  final _Ease ease;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * ease((t - start) / seconds);
  }

  /// A new ramp from the value at [now] to [target].
  _Ramp toward(double target, double now, double secs, [_Ease e = _linear]) =>
      _Ramp(at(now), target, now, secs, e);
}

// ------------------------------------------------------------------- model

/// The Scenario 1 stars the slider and scene drags move (HTML
/// `State.s1.activeDragTarget`).
enum _Star { sun, sirius }

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

/// canvas-confetti for the mastery popup: pieces fly, slow down, fall and
/// fade over 200 ticks.
class _Confetti {
  final List<_Confetto> pieces = [];
  final math.Random _rnd = math.Random(5);

  /// Canvas size the pieces are placed in (logical px).
  Size size = _design;
  double _ticks = 0;

  /// `confetti({particleCount, angle, spread, origin})`.
  void fire(int count, double angle, double spread, Offset origin) {
    final a = angle * math.pi / 180;
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

  void clear() {
    pieces.clear();
    _ticks = 0;
  }
}

/// Mutable scene read by the painter every frame (HTML `State` plus the
/// Three.js objects' animated values).
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1–4).
  int step = 1;

  /// The step card shows the HTML `setupStepUI()` guidance line instead of
  /// the step's HUD text once the learner moves something (the HTML
  /// rewrote the line on every slider or drag update).
  bool guideLive = false;

  // Scenario 1 (HTML `State.s1`).
  double sunAu = _minAu;
  double siriusAu = _maxAu;
  _Star target = _Star.sun;

  // Scenario 2 (HTML `State.s2`).
  double earthAu = 1;
  bool probedEarth = false;
  bool probedMars = false;

  /// `s2EarthGroup.rotation.z` (kept across scenario changes, as the HTML).
  double earthAngle = 0;
  _Climate climate = _Climate.water;

  /// 0 = framed for the open sidebar, 1 = for the collapsed one.
  _Ramp frame = const _Ramp.still(0);

  /// How much higher the scene is drawn (design px; see [_compactRise]).
  double rise = 0;
  final _Confetti confetti = _Confetti();

  /// The Scenario 1 star labels as last painted (design px; null when
  /// hidden). The HTML labels pick the slider's star when tapped.
  Rect? sunLabel;
  Rect? siriusLabel;

  /// Starfield projected for [skyKey], reused while the camera stays put.
  Float32List? skyPoints;
  Object? skyKey;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    guideLive = false;
    sunAu = _minAu;
    siriusAu = _maxAu;
    target = _Star.sun;
    earthAu = 1;
    probedEarth = false;
    probedMars = false;
    climate = _Climate.water;
    sunLabel = null;
    siriusLabel = null;
  }

  /// The camera for the current scenario and framing.
  _Cam get cam {
    final t = frame.at(time);
    final lerp = _Frame.lerp(_framesOpen[scenario], _framesClosed[scenario], t);
    final f = _Frame(lerp.zoom, lerp.center.translate(0, -rise));
    return scenario == 0 ? _Cam(_eyeS1, _lookS1, f) : _Cam(_eyeS2, _lookS2, f);
  }

  // ----------------------------------------------------------- scenario 1

  /// `updateSunDistanceS1()`: z from 0 (1 au) to -380 (50,000 au).
  _V get sunPos =>
      _V(_sunX, _sunY, (sunAu - _minAu) / (_maxAu - _minAu) * _farZ);

  /// `updateSiriusDistanceS1()`: z from -380 (50,000 au) to 0 (1 au).
  _V get siriusPos => _V(
    _siriusX,
    _siriusY,
    _farZ - (_maxAu - siriusAu) / (_maxAu - _minAu) * _farZ,
  );

  /// The core dots' radii.
  double get sunCore => _sunCoreR * (1 + sunAu / _maxAu * _sunCoreGrow);
  double get siriusCore =>
      _siriusCoreR * (1 + siriusAu / _maxAu * _siriusCoreGrow);

  // ----------------------------------------------------------- scenario 2

  _V get earthPos {
    final r = _auUnits * earthAu;
    return _V(math.cos(earthAngle) * r, math.sin(earthAngle) * r, 0);
  }

  _V get marsPos {
    final a = time * _marsRate;
    return _V(math.cos(a) * _marsOrbit, math.sin(a) * _marsOrbit, 0);
  }

  // ------------------------------------------------------------- the HUD

  /// The HTML `#hud-next-btn` label key, or null while it is hidden.
  String? get nextKey {
    if (scenario == 0) {
      return switch (step) {
        1 => 'next_s1_2',
        2 => sunAu >= _sunFarAu ? 'next_s1_3' : null,
        3 => siriusAu <= _siriusNearAu ? 'next_s1_4' : null,
        _ => null,
      };
    }
    return switch (step) {
      2 => probedEarth || probedMars ? 'next_s2_3' : null,
      3 => earthAu <= _closeAu ? 'next_s2_4' : null,
      _ => null,
    };
  }

  /// HTML `#compare-btn-container`: 'Observe Conclusion' in step 4.
  bool get canConclude => step == _stepCount;

  /// The vertical slider's position (0 bottom … 1 top).
  double get sliderValue {
    if (scenario == 1) {
      return (earthAu - _minOrbitAu) / (_maxOrbitAu - _minOrbitAu);
    }
    final au = target == _Star.sun ? sunAu : siriusAu;
    return (au - _minAu) / (_maxAu - _minAu);
  }
}

/// "50,000": a whole number of au with thousands separators (the HTML
/// `toLocaleString()`).
String _auText(double au) {
  final digits = au.round().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// "1.0": the Scenario 2 distances (`toFixed(1)`).
String _orbitText(double au) => au.toStringAsFixed(1);

class _SunLabState extends State<Ch12A3TheSunAndItsRoleInTheSolarSystemPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The probe under the finger while it is dragged (canvas px).
  final ValueNotifier<Offset?> _ghost = ValueNotifier(null);
  final _TextCache _texts = _TextCache();

  /// The design-size scene (drops are hit-tested in its coordinates) and
  /// the full-canvas overlay layer (the probe ghost and the confetti).
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout.
  double _fit = 1;

  /// The sidebar state the scene is framed for.
  bool _framedOpen = true;

  /// A probe drag in progress and the finger's last global position.
  bool _probing = false;
  Offset _probeGlobal = Offset.zero;

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
    _ghost.dispose();
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: the Earth's orbit (Scenario 2 only, as the HTML),
  /// the confetti, then a repaint; the turning rings, Mars and the steam
  /// are read from the scene time.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    if (s.scenario == 1) {
      s.earthAngle += _orbitRate / math.sqrt(s.earthAu) * dt;
    }
    s.confetti.update(dt);
    _frame.value = now;
  }

  /// Re-frames the scene when the sidebar opens or closes.
  void _syncFrame() {
    final open = _lab.isSidebarOpen;
    if (open == _framedOpen) return;
    _framedOpen = open;
    final s = _scene;
    s.frame = s.frame.toward(open ? 0 : 1, s.time, _reframeSeconds, _cubicOut);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------- logic

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

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: step 1, the
  /// stars back at 1 au and 50,000 au, the Earth back at 1 au, the
  /// thermometers hidden and the camera reset.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _cancelProbe();
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `resetApp()`: Scenario 1 from scratch (the shell restores the
  /// language, theme, sidebar and curtain).
  void _reset() {
    _scene.confetti.clear();
    _loadScenario(0);
  }

  /// HTML `advanceToNextStep()`: the Next button.
  void _advance() {
    if (!_lab.isLabActive) return;
    _Sound.pop.play();
    if (_scene.step < _stepCount) {
      _progressStep();
    } else {
      _triggerConclusion();
    }
  }

  /// HTML `progressStep()`; its `setupStepUI()` makes the slider move the
  /// Sun in step 2 and Sirius in step 3.
  void _progressStep() {
    final s = _scene;
    if (s.step >= _stepCount) return;
    s
      ..step = s.step + 1
      ..guideLive = false;
    if (s.scenario == 0 && s.step == 2) s.target = _Star.sun;
    if (s.scenario == 0 && s.step == 3) s.target = _Star.sirius;
    _refresh();
  }

  /// The star labels' `selectSliderTarget(id)` (called by the HTML but
  /// missing from it): the slider and scene drags move that star. Steps 2
  /// and 3 keep their own star (HTML `setupStepUI()`).
  void _selectStar(_Star star) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step == 2 || s.step == 3) return;
    _Sound.pop.play();
    setState(() => s.target = star);
  }

  /// HTML `updateSunDistanceS1(au)` / `updateSiriusDistanceS1(au)`.
  void _moveStar(_Star star, double au) {
    final s = _scene;
    final v = au.clamp(_minAu, _maxAu).roundToDouble();
    if (star == _Star.sun) {
      s.sunAu = v;
    } else {
      s.siriusAu = v;
    }
    s.guideLive = true;
    _refresh();
  }

  /// HTML `updateEarthOrbitS2(au)`. The boil / freeze tones (defined but
  /// never played by the HTML) mark the Earth starting to boil or freeze.
  void _moveEarth(double au) {
    final s = _scene;
    s
      ..earthAu = au.clamp(_minOrbitAu, _maxOrbitAu)
      ..guideLive = true;
    final climate = _Climate.of(_surfaceTemp(s.earthAu));
    if (climate != s.climate) {
      if (climate == _Climate.scorched) {
        _Sound.boil.play();
      } else if (climate.index > s.climate.index && climate != _Climate.water) {
        _Sound.freeze.play();
      }
      s.climate = climate;
    }
    _refresh();
  }

  /// HTML `slider.oninput`: 0 (bottom) … 1 (top). Both stars read 1 au at
  /// the bottom and 50,000 au at the top, as the slider's labels say (the
  /// HTML ran Sirius the other way round).
  void _onSlider(double v) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    if (s.scenario == 1) {
      _moveEarth(_minOrbitAu + v * (_maxOrbitAu - _minOrbitAu));
    } else {
      _moveStar(s.target, _minAu + v * (_maxAu - _minAu));
    }
  }

  /// HTML `useProbeOn(target)`: the reading's toast and thermometer card;
  /// both planets measured moves the step on.
  void _useProbe({required bool earth}) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.step > 2) return;
    _Sound.click.play();
    if (earth) {
      s.probedEarth = true;
    } else {
      s.probedMars = true;
    }
    s.guideLive = true;
    final key = earth ? 'toast_earth' : 'toast_mars';
    _toastKey = key;
    _lab.showToast(_t(key), sound: false);
    if (s.probedEarth && s.probedMars) _progressStep();
    _refresh();
  }

  // ---------------------------------------------------------------- popups

  /// HTML `triggerConclusion()`: the summary (Scenario 1), or the mastery
  /// popup with confetti (Scenario 2).
  void _triggerConclusion() {
    if (!mounted || !_lab.isLabActive) return;
    final s = _scene;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    if (sc == 1) {
      s.confetti
        ..size = _canvasSize
        ..fire(_confettiCount, 90, _confettiSpread, _confettiOrigin);
    }
    _lab.showPopup(() => sc == 0 ? _summaryPopup() : _masteryPopup());
    _refresh();
  }

  /// HTML `#summary-modal`: "Success!", "Scenario 1 Complete!", the
  /// summary and the note. 'Next Scenario' (the HTML's unused `next_sc`)
  /// opens Scenario 2, also when the sidebar is collapsed.
  LabPopupContent _summaryPopup() {
    return LabPopupContent(
      title: _t('success'),
      icon: Icons.check_circle,
      accent: _Colors.amber500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          title: labFormat(_t('sc_complete'), {'n': 1}),
          summary: _t('s1_summary'),
          heading: _Colors.amber400,
          note: _t('summary_note'),
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        LabAction(
          label: _t('next_sc'),
          icon: Icons.arrow_forward,
          color: _Colors.amber500,
          foreground: _Colors.slate950,
          sound: _Sound.scenario,
          onTap: () => _loadScenario(1),
        ),
      ],
    );
  }

  /// HTML `#success-modal`: "Mastery Achieved!" and 'Restart Entire Lab'.
  /// Scenario 2's summary (which the HTML never showed) comes first.
  LabPopupContent _masteryPopup() {
    return LabPopupContent(
      title: _t('success'),
      icon: Icons.emoji_events,
      accent: _Colors.amber500,
      extra: Builder(
        builder: (context) {
          final s = context.labScale;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryCard(
                title: labFormat(_t('sc_complete'), {'n': 2}),
                summary: _t('s2_summary'),
                heading: _Colors.emerald400,
                palette: _lab.palette,
                scale: s,
                fontScale: _lab.fontScale,
              ),
              SizedBox(height: 16 * s),
              _MasteryCard(
                title: _t('all_complete'),
                text: _t('all_complete_desc'),
                palette: _lab.palette,
                scale: s,
                fontScale: _lab.fontScale,
              ),
            ],
          );
        },
      ),
      actions: [
        LabAction(
          label: _t('restart_lab'),
          icon: Icons.restart_alt,
          color: _Colors.amber600,
          foreground: _Colors.white,
          onTap: _lab.requestFullReset,
        ),
      ],
    );
  }

  /// 'Observe Conclusion' for the sidebar's action list.
  LabAction _concludeAction() => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.amber500,
    foreground: _Colors.slate950,
    highlight: true,
    silent: true,
    onTap: _triggerConclusion,
  );

  // ------------------------------------------------------------- gestures

  /// Size of the canvas (for the confetti).
  Size get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : _design;
  }

  /// [global] in canvas coordinates, or null before layout.
  Offset? _canvasLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  /// The Scenario 1 star under a stage point: its label first (drawn on
  /// top, Sirius' last), then the nearer star's disc.
  _Star? _starAt(Offset at) {
    final s = _scene;
    if (s.scenario != 0) return null;
    final pad = 4 / _fit;
    if (s.siriusLabel?.inflate(pad).contains(at) ?? false) return _Star.sirius;
    if (s.sunLabel?.inflate(pad).contains(at) ?? false) return _Star.sun;
    final cam = s.cam;
    _Star? hit;
    var nearest = double.infinity;
    for (final star in _Star.values) {
      final pos = star == _Star.sun ? s.sunPos : s.siriusPos;
      final r = star == _Star.sun
          ? math.max(_sunR, s.sunCore)
          : math.max(_siriusR, s.siriusCore);
      final reach = math.max(r * cam.scaleAt(pos), _minTouch / 2 / _fit);
      final depth = cam.depth(pos);
      if ((at - cam.p(pos)).distance <= reach && depth < nearest) {
        hit = star;
        nearest = depth;
      }
    }
    return hit;
  }

  /// HTML label `onclick`: a tap on a star label (or the star) picks it.
  void _onStageTap(Offset at) {
    if (!_lab.isLabActive) return;
    final star = _starAt(at);
    if (star != null) _selectStar(star);
  }

  /// HTML `pointerdown` on the canvas. In steps 1 and 4, where the labels
  /// pick the star, a drag that starts on a star moves that star, and in
  /// step 1 a drag on the right half moves Sirius (the step's guidance).
  void _dragStart(DragStartDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step != 1 && s.step != 4) return;
    final at = d.localPosition;
    final star =
        _starAt(at) ??
        (s.step == 1 && at.dx > s.cam.center.dx ? _Star.sirius : null);
    if (star != null && star != s.target) setState(() => s.target = star);
  }

  /// HTML `pointermove`: a sideways drag moves the star 100 au per px
  /// (right: the Sun farther, Sirius nearer) or, in Scenario 2, the
  /// Earth's orbit 0.005 au per px; the orbit only moves in steps 3 and 4,
  /// where its slider is shown (the HTML let a drag move it during the
  /// probe readings too).
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    final dx = d.delta.dx;
    if (dx == 0) return;
    if (s.scenario == 0) {
      if (s.target == _Star.sun) {
        _moveStar(_Star.sun, s.sunAu + dx * _auPerPx);
      } else {
        _moveStar(_Star.sirius, s.siriusAu - dx * _auPerPx);
      }
    } else if (s.step >= 3) {
      _moveEarth(s.earthAu + dx * _orbitAuPerPx);
    }
  }

  /// The planet (true = Earth, false = Mars) under a stage point.
  bool? _planetAt(Offset at) {
    final s = _scene;
    if (s.scenario != 1) return null;
    final cam = s.cam;
    final reach = _minTouch / 2 / _fit;
    for (final (earth, pos, r) in [
      (true, s.earthPos, _s2EarthR),
      (false, s.marsPos, _marsR),
    ]) {
      final hit = math.max(r * 1.4 * cam.scaleAt(pos), reach);
      if ((at - cam.p(pos)).distance <= hit) return earth;
    }
    return null;
  }

  /// The probe's drag handle (the HTML step texts: "DRAG the Temperature
  /// Probe and DROP it onto the Earth").
  void _probeStart(DragStartDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1 || s.step > 2) return;
    _probing = true;
    _probeGlobal = d.globalPosition;
    _ghost.value = _canvasLocal(d.globalPosition);
  }

  void _probeUpdate(DragUpdateDetails d) {
    if (!_probing) return;
    _probeGlobal = d.globalPosition;
    _ghost.value = _canvasLocal(d.globalPosition);
  }

  /// Dropped on the Earth or Mars, the probe takes its reading.
  void _probeEnd() {
    if (!_probing) return;
    final at = labGlobalToLocal(_stageKey, _probeGlobal);
    _cancelProbe();
    if (at == null) return;
    final earth = _planetAt(at);
    if (earth != null) _useProbe(earth: earth);
  }

  void _cancelProbe() {
    _probing = false;
    _ghost.value = null;
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
        _syncFrame();
        final p = _lab.palette;
        final s = context.labScale;
        final scene = _scene;
        final data = _data;
        scene.rise = MediaQuery.sizeOf(context).height < _compactBelow
            ? _compactRise
            : 0;
        return LabShell(
          controller: _lab,
          icon: Icons.wb_sunny,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // The HTML step card (`#main-hud-box`) is on the canvas; it
          // replaces the shell's HUD line.
          showHud: false,
          actions: [if (scene.canConclude) _concludeAction()],
          onReset: _reset,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch12a3-steps-${scene.scenario}'),
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

  /// The step card's title and icon (HTML `setupStepUI()`).
  (String, IconData, Color) _stepTitle() {
    final s = _scene;
    if (s.scenario == 0) {
      final title = s.step == 4
          ? labFormat(_t('s1_title_4'), {
              'target': _t(
                s.target == _Star.sun ? 's1_target_sun' : 's1_target_sirius',
              ),
            })
          : _t('s1_title_${s.step}');
      return switch (s.step) {
        1 => (title, Icons.explore, _Colors.amber500),
        2 => (title, Icons.wb_sunny, _Colors.amber500),
        3 => (title, Icons.star, _Colors.cyan400),
        _ => (title, Icons.tune, _Colors.amber400),
      };
    }
    final title = _t('s2_title_${s.step}');
    return switch (s.step) {
      1 || 2 => (title, Icons.thermostat, _Colors.blue400),
      3 => (title, Icons.local_fire_department, _Colors.red500),
      _ => (title, Icons.ac_unit, _Colors.cyan400),
    };
  }

  /// Canvas cards: the slider or probe card (right), the thermometers
  /// (top), the step card with 'Observe Conclusion' above it, or in it on
  /// phones (bottom), the confetti and the probe ghost.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < _compactBelow;
    final scene = _scene;
    final n = scene.scenario + 1;
    final probe = scene.scenario == 1 && scene.step <= 2;
    final panelWidth = probe
        ? (size.width < _narrowBelow ? 170.0 : 190.0) * s
        : _sliderCardWidth * s;
    final nextKey = scene.nextKey;
    final (title, icon, iconColor) = _stepTitle();
    final line = _t(
      scene.guideLive ? 's${n}_guide_${scene.step}' : 's${n}_hud_${scene.step}',
    );
    final showThermometers =
        scene.scenario == 1 && (scene.probedEarth || scene.probedMars);
    final conclude = scene.canConclude && _lab.popup == null;
    return [
      Positioned(
        key: ValueKey(probe ? 'ch12a3-probe' : 'ch12a3-slider'),
        right: inset.right,
        top: inset.top,
        bottom: inset.bottom,
        child: Align(
          alignment: Alignment.centerRight,
          child: probe
              ? _ProbeCard(
                  title: _t('probe_tool'),
                  hint: _t('probe_hint'),
                  earthLabel: _t('drop_earth'),
                  marsLabel: _t('drop_mars'),
                  width: panelWidth,
                  scale: s,
                  onEarth: () => _useProbe(earth: true),
                  onMars: () => _useProbe(earth: false),
                  onDragStart: _probeStart,
                  onDragUpdate: _probeUpdate,
                  onDragEnd: _probeEnd,
                  onDragCancel: _cancelProbe,
                )
              : LayoutBuilder(
                  builder: (context, box) => _sliderCard(p, s, box.maxHeight),
                ),
        ),
      ),
      if (showThermometers)
        Positioned(
          key: const ValueKey('ch12a3-thermometers'),
          // Below the shell's toast.
          top: inset.top + 46 * s,
          left: inset.left,
          right: inset.right + panelWidth + 8,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _thermometers(s, compact),
            ),
          ),
        ),
      Positioned(
        key: const ValueKey('ch12a3-hud'),
        // The whole canvas width: the floating mission card stays at the
        // top left.
        left: 8 + MediaQuery.paddingOf(context).left,
        right: inset.right + panelWidth + 8,
        bottom: inset.bottom,
        child: Center(
          child: _Narrowable(
            least: _hudLeast * s,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HTML `#compare-btn-container`, above the step card; on
                // phones it takes the Next button's place in the card.
                if (conclude && !compact) ...[
                  _GlowButton(
                    label: _t('btn_conclude'),
                    icon: Icons.lightbulb,
                    colors: const [_Colors.amber600, _Colors.yellow500],
                    leadingIcon: true,
                    bordered: true,
                    fontSize: 15,
                    scale: s,
                    clock: _frame,
                    onTap: _triggerConclusion,
                  ),
                  SizedBox(height: 10 * s),
                ],
                _HudCard(
                  icon: icon,
                  iconColor: iconColor,
                  title: title,
                  status: _t('status_active'),
                  text: line,
                  palette: p,
                  scale: s,
                  compact: compact,
                  clock: _frame,
                  next: nextKey != null
                      ? _GlowButton(
                          label: _t(nextKey),
                          icon: Icons.arrow_forward,
                          colors: const [_Colors.amber500, _Colors.yellow500],
                          fontSize: 12,
                          scale: s,
                          clock: _frame,
                          onTap: _advance,
                        )
                      : (conclude && compact
                            ? _GlowButton(
                                label: _t('btn_conclude'),
                                icon: Icons.lightbulb,
                                colors: const [
                                  _Colors.amber600,
                                  _Colors.yellow500,
                                ],
                                leadingIcon: true,
                                fontSize: 12,
                                scale: s,
                                clock: _frame,
                                onTap: _triggerConclusion,
                              )
                            : null),
                ),
              ],
            ),
          ),
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
        child: IgnorePointer(
          child: SizedBox.expand(
            key: _canvasKey,
            child: ValueListenableBuilder<Offset?>(
              valueListenable: _ghost,
              builder: (context, at, _) {
                if (at == null) return const SizedBox.shrink();
                return Stack(
                  children: [
                    Positioned(
                      left: at.dx,
                      top: at.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: _ProbeGhost(scale: s),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ];
  }

  /// HTML `#vertical-slider-box` for the current target, its track as long
  /// as [height] allows (at most 260 px).
  Widget _sliderCard(LabPalette p, double s, double height) {
    final scene = _scene;
    final String name, top, bottom, value;
    final IconData icon;
    final Color iconColor;
    if (scene.scenario == 0) {
      final sun = scene.target == _Star.sun;
      name = _t(sun ? 'sun_label' : 'sirius_label');
      icon = sun ? Icons.wb_sunny : Icons.star;
      iconColor = sun ? _Colors.amber400 : _Colors.cyan400;
      top = '${_auText(_maxAu)} au';
      bottom = '${_auText(_minAu)} au';
      value = '${_auText(sun ? scene.sunAu : scene.siriusAu)} au';
    } else {
      name = _t('slider_orbit');
      icon = Icons.public;
      iconColor = _Colors.blue400;
      top = '${_orbitText(_maxOrbitAu)} au';
      bottom = '${_orbitText(_minOrbitAu)} au';
      value = '${_orbitText(scene.earthAu)} au';
    }
    final chrome = _sliderChrome * s;
    final track = height.isFinite
        ? (height - chrome).clamp(_sliderMinTrack, _sliderMaxTrack * s)
        : _sliderMaxTrack * s;
    return _SliderCard(
      palette: p,
      scale: s,
      track: track,
      name: name,
      icon: icon,
      iconColor: iconColor,
      maxLabel: top,
      minLabel: bottom,
      valueText: value,
      value: scene.sliderValue,
      onChanged: _onSlider,
    );
  }

  /// HTML `#thermometer-earth` / `#thermometer-mars`, once the probe has
  /// read each planet (the HTML never showed them); the Earth's card
  /// follows its orbit.
  Widget _thermometers(double s, bool compact) {
    final scene = _scene;
    final celsius = _shownTemp(scene.earthAu);
    final climate = _Climate.of(_surfaceTemp(scene.earthAu));
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scene.probedEarth)
          _ThermometerCard(
            heading: _t('therm_earth'),
            headingColor: _Colors.blue400,
            border: _Colors.blue500,
            temp: _tempText(celsius),
            tone: climate.tone,
            box: climate.box,
            icon: climate.icon,
            title: _t(climate.titleKey),
            detail: labFormat(_t(climate.zoneKey), {
              'au': _orbitText(scene.earthAu),
            }),
            scale: s,
            compact: compact,
          ),
        if (scene.probedEarth && scene.probedMars) SizedBox(width: 12 * s),
        if (scene.probedMars)
          _ThermometerCard(
            heading: _t('therm_mars'),
            headingColor: _Colors.red400,
            border: _Colors.red500,
            temp: _tempText(-65),
            tone: _Climate.freezing.tone,
            box: _Climate.freezing.box,
            icon: _Climate.freezing.icon,
            title: _t('cond_freezing'),
            detail: labFormat(_t('zone_beyond'), {'au': _orbitText(_marsAu)}),
            scale: s,
            compact: compact,
          ),
      ],
    );
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        // Canvas labels stay readable when the stage is drawn small.
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        final locked = _lab.camLocked;
        return LabStage(
          designSize: _design,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The stars and planets have their own nodes ([_targets]).
            excludeFromSemantics: true,
            onTapUp: (d) => _onStageTap(d.localPosition),
            // Unlocked, drags move the canvas instead (HTML OrbitControls).
            onPanStart: locked ? _dragStart : null,
            onPanUpdate: locked ? _dragUpdate : null,
            child: SizedBox.expand(
              key: _stageKey,
              child: Stack(
                children: [
                  Semantics(
                    image: true,
                    label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: _design,
                        painter: _ScenePainter(
                          scene: _scene,
                          texts: _texts,
                          repaint: _frame,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelScale: labelScale,
                        ),
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
          ),
        );
      },
    );
  }

  /// The label text of a Scenario 1 star (HTML `updatePlanetLabelsUI()`).
  String _starName(_Star star) {
    final s = _scene;
    return star == _Star.sun
        ? '${_t('sun_label')} (${_auText(s.sunAu)} au)'
        : '${_t('sirius_label')} (${_auText(s.siriusAu)} au | ${_t('sirius_desc')})';
  }

  /// Screen-reader nodes over the stars (Scenario 1; a tap picks the star,
  /// as its HTML label) and the planets (Scenario 2), where they are
  /// drawn. They take no touches themselves: taps reach the scene below.
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive) return const SizedBox.shrink();
    final cam = s.cam;
    final reach = _minTouch / 2 / _fit;
    Rect disc(_V pos, double r) => Rect.fromCircle(
      center: cam.p(pos),
      radius: math.max(r * cam.scaleAt(pos), reach),
    );
    final nodes = <Widget>[];
    if (s.scenario == 0) {
      for (final star in _Star.values) {
        final sun = star == _Star.sun;
        final rect =
            (sun ? s.sunLabel : s.siriusLabel) ??
            (sun
                ? disc(s.sunPos, math.max(_sunR, s.sunCore))
                : disc(s.siriusPos, math.max(_siriusR, s.siriusCore)));
        nodes.add(
          Positioned.fromRect(
            rect: rect,
            child: Semantics(
              key: ValueKey('ch12a3-${star.name}'),
              container: true,
              button: s.step == 1 || s.step == 4,
              selected: s.target == star,
              label: _starName(star),
              onTap: () => _selectStar(star),
              child: const SizedBox.expand(),
            ),
          ),
        );
      }
    } else {
      final planets = [
        (
          'earth',
          disc(s.earthPos, _s2EarthR),
          '${_t('earth_label')} (${_orbitText(s.earthAu)} au)',
        ),
        (
          'mars',
          disc(s.marsPos, _marsR),
          '${_t('mars_label')} (${_orbitText(_marsAu)} au)',
        ),
      ];
      for (final (id, rect, label) in planets) {
        nodes.add(
          Positioned.fromRect(
            rect: rect,
            child: Semantics(
              key: ValueKey('ch12a3-$id'),
              container: true,
              label: label,
              child: const SizedBox.expand(),
            ),
          ),
        );
      }
    }
    return Stack(children: nodes);
  }
}

// ================================================================ CANVAS UI

/// HTML `#vertical-slider-box`: 76 px wide, with the target badge, the
/// distance labels, the track (at most 260 px) and the readout, which take
/// [_sliderChrome] px around the track.
const double _sliderCardWidth = 76;
const double _sliderMaxTrack = 260;
const double _sliderMinTrack = 90;
const double _sliderChrome = 124;

/// The step card is laid out in two rows below this width (its Next button
/// gets a row of its own).
const double _hudWideFrom = 440;

/// Narrower than this (while the sidebar slides) the step card is scaled
/// down instead of squeezed.
const double _hudLeast = 300;

/// HTML `#main-hud-box`: the step's icon and title with the 'Active'
/// badge, then the instruction line and the Next button.
class _HudCard extends StatelessWidget {
  const _HudCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.text,
    required this.palette,
    required this.scale,
    required this.compact,
    required this.clock,
    this.next,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final String text;
  final LabPalette palette;
  final double scale;
  final bool compact;

  /// Scene time, for the info icon's pulse.
  final ValueListenable<double> clock;
  final Widget? next;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final dark = p.isDark;
    final info = ValueListenableBuilder<double>(
      valueListenable: clock,
      // HTML `animate-pulse` on the info icon.
      builder: (context, t, child) =>
          Opacity(opacity: 0.75 + 0.25 * math.cos(t * math.pi), child: child),
      child: Icon(Icons.info, size: 17 * s, color: p.ink(_Colors.amber500)),
    );
    final line = Text(
      text,
      maxLines: compact ? 4 : 5,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: dark ? _Colors.slate200 : _Colors.slate700,
        fontSize: (compact ? 10.5 : 12) * s,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 560 * s),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (compact ? 12 : 18) * s,
          vertical: (compact ? 7 : 10) * s,
        ),
        decoration: BoxDecoration(
          color: dark ? _Colors.glassNight : _Colors.glassLight,
          borderRadius: BorderRadius.circular(22 * s),
          border: Border.all(
            color: _Colors.amber500.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowStrong,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= _hudWideFrom * s;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 17 * s, color: p.ink(iconColor)),
                    SizedBox(width: 7 * s),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.ink(_Colors.amber500),
                          fontSize: (compact ? 11 : 12.5) * s,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: labLetterSpacing(title, 0.8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 2 * s,
                      ),
                      decoration: BoxDecoration(
                        color: _Colors.emerald500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _Colors.emerald500.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: p.ink(_Colors.emerald400),
                          fontFamily: 'monospace',
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(vertical: (compact ? 5 : 7) * s),
                  color: dark ? _Colors.slate800 : _Colors.slate200,
                ),
                Row(
                  children: [
                    info,
                    SizedBox(width: 9 * s),
                    Expanded(child: line),
                    if (next != null && wide) ...[
                      SizedBox(width: 10 * s),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: box.maxWidth * 0.48,
                        ),
                        child: next,
                      ),
                    ],
                  ],
                ),
                if (next != null && !wide) ...[
                  SizedBox(height: 6 * s),
                  Align(alignment: Alignment.centerRight, child: next),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lays [child] out at the available width, or at [least] scaled down to
/// fit when the space is narrower (the canvas while the sidebar slides).
class _Narrowable extends StatelessWidget {
  const _Narrowable({required this.least, required this.child});

  final double least;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= least) return child;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: least, child: child),
        );
      },
    );
  }
}

/// The HTML's pulsing gradient buttons ('Start Step …' and 'Observe
/// Conclusion', `animate-pulse-glow`: opacity 0.85 ↔ 1 and scale 1 ↔ 1.04
/// every 2 s).
class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.scale,
    required this.clock,
    required this.onTap,
    this.fontSize = 12,
    this.leadingIcon = false,
    this.bordered = false,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final double scale;
  final ValueListenable<double> clock;
  final VoidCallback onTap;
  final double fontSize;
  final bool leadingIcon;

  /// The large 'Observe Conclusion' button (white/40 border).
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular((bordered ? 16 : 12) * s);
    final iconWidget = Icon(
      icon,
      size: (fontSize + 4) * s,
      color: _Colors.slate950,
    );
    final button = Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: LabInk.clear,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: radius,
              border: bordered
                  ? Border.all(
                      color: _Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    )
                  : null,
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (bordered ? 24 : 14) * s,
                    vertical: 6 * s,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon) ...[iconWidget, SizedBox(width: 8 * s)],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _Colors.slate950,
                            fontSize: fontSize * s,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (!leadingIcon) ...[SizedBox(width: 6 * s), iconWidget],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, t, child) {
        final k = 0.5 - 0.5 * math.cos(t * math.pi);
        return Opacity(
          opacity: 0.85 + 0.15 * k,
          child: Transform.scale(scale: 1 + 0.04 * k, child: child),
        );
      },
      child: button,
    );
  }
}

/// HTML `#vertical-slider-box`: the target badge, the far / near distance
/// labels, the thick gradient track with its white thumb and the readout.
/// The track runs from 1 au (bottom) to 50,000 au or 2.5 au (top).
class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.palette,
    required this.scale,
    required this.track,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.maxLabel,
    required this.minLabel,
    required this.valueText,
    required this.value,
    required this.onChanged,
  });

  final LabPalette palette;
  final double scale;

  /// Length of the slider (dp).
  final double track;
  final String name;
  final IconData icon;
  final Color iconColor;
  final String maxLabel;
  final String minLabel;
  final String valueText;

  /// 0 (bottom) … 1 (top).
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final amber = p.ink(_Colors.amber400);
    final mono = TextStyle(
      color: p.isDark ? _Colors.slate400 : _Colors.slate500,
      fontFamily: 'monospace',
      fontSize: 9 * s,
      fontWeight: FontWeight.w700,
    );
    return Container(
      width: _sliderCardWidth * s,
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.glassNight : _Colors.glassLight,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: _Colors.amber500.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 3 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 11 * s, color: p.ink(iconColor)),
                SizedBox(width: 3 * s),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: amber,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(maxLabel, style: mono),
          ),
          SizedBox(
            key: const ValueKey('ch12a3-slider-track'),
            height: track,
            width: double.infinity,
            child: Semantics(
              label: name,
              value: valueText,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12 * s,
                    trackShape: const _GradientTrack(),
                    thumbShape: _RingThumb(14 * s, 4 * s),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 20 * s,
                    ),
                    overlayColor: _Colors.amber500.withValues(alpha: 0.2),
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Slider(
                    value: value.clamp(0.0, 1.0),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(minLabel, style: mono),
          ),
          SizedBox(height: 5 * s),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.3),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valueText,
                maxLines: 1,
                style: TextStyle(
                  color: amber,
                  fontFamily: 'monospace',
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The HTML range track: 14 px, a sky-to-amber gradient along its whole
/// length, with an inset shadow.
class _GradientTrack extends SliderTrackShape with BaseSliderTrackShape {
  const _GradientTrack();

  @override
  bool get isRounded => true;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    context.canvas
      ..drawRRect(
        rr,
        Paint()
          ..shader = const LinearGradient(
            colors: [_Colors.sky400, _Colors.amber500],
          ).createShader(rect),
      )
      ..drawRRect(
        rr.deflate(0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = LabInk.black.withValues(alpha: 0.3),
      );
  }
}

/// The HTML range thumb: white, 32 px, a 4 px amber border and a shadow.
class _RingThumb extends SliderComponentShape {
  const _RingThumb(this.radius, this.ring);

  final double radius;
  final double ring;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final grow = 1 + 0.08 * activationAnimation.value;
    final r = radius * grow;
    context.canvas
      ..drawCircle(
        center + const Offset(0, 2),
        r,
        Paint()
          ..color = LabInk.black.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(
        center,
        r,
        Paint()
          ..color = Color.lerp(
            _Colors.white,
            const Color(0xFFFEF08A),
            activationAnimation.value,
          )!,
      )
      ..drawCircle(
        center,
        r - ring / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring
          ..color = _Colors.amber500,
      );
  }
}

/// HTML `#hud-probe-actions` (Scenario 2, steps 1 and 2): the Temperature
/// Probe, dragged by its header onto a planet, and the 'Drop on Earth' /
/// 'Drop on Mars' buttons.
class _ProbeCard extends StatelessWidget {
  const _ProbeCard({
    required this.title,
    required this.hint,
    required this.earthLabel,
    required this.marsLabel,
    required this.width,
    required this.scale,
    required this.onEarth,
    required this.onMars,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final String title;
  final String hint;
  final String earthLabel;
  final String marsLabel;
  final double width;
  final double scale;
  final VoidCallback onEarth;
  final VoidCallback onMars;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: width,
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: _Colors.glassNight,
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(
          color: _Colors.indigo500.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: onDragStart,
            onPanUpdate: onDragUpdate,
            onPanEnd: (_) => onDragEnd(),
            onPanCancel: onDragCancel,
            child: Semantics(
              hint: hint,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5 * s),
                      decoration: BoxDecoration(
                        color: _Colors.indigo500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _Colors.indigo500.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.thermostat,
                        size: 17 * s,
                        color: _Colors.indigo500,
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _Colors.white,
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Icon(
                      Icons.open_with,
                      size: 15 * s,
                      color: _Colors.slate400,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            margin: EdgeInsets.only(top: 4 * s, bottom: 10 * s),
            color: _Colors.slate700.withValues(alpha: 0.8),
          ),
          _button(earthLabel, _Colors.blue600, Icons.water_drop, onEarth),
          SizedBox(height: 8 * s),
          _button(marsLabel, _Colors.red600, Icons.ac_unit, onMars),
        ],
      ),
    );
  }

  Widget _button(String label, Color color, IconData icon, VoidCallback tap) {
    final s = scale;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: tap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _Colors.white,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: 6 * s),
                Icon(icon, size: 17 * s, color: _Colors.cyan200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The probe under the finger while it is dragged.
class _ProbeGhost extends StatelessWidget {
  const _ProbeGhost({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final d = 46 * scale;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: _Colors.indigo500.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: _Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 14),
        ],
      ),
      child: Icon(Icons.thermostat, size: 26 * scale, color: _Colors.white),
    );
  }
}

/// HTML `#thermometer-earth` / `#thermometer-mars`: a dark card with the
/// planet's status and reading, the weather icon, the condition and the
/// zone. On phones ([compact]) the icon box is left out and the condition
/// and zone share a line, so the card covers less of the scene.
class _ThermometerCard extends StatelessWidget {
  const _ThermometerCard({
    required this.heading,
    required this.headingColor,
    required this.border,
    required this.temp,
    required this.tone,
    required this.box,
    required this.icon,
    required this.title,
    required this.detail,
    required this.scale,
    required this.compact,
  });

  final String heading;
  final Color headingColor;
  final Color border;
  final String temp;

  /// Reading badge colour and the icon box colour.
  final Color tone;
  final Color box;
  final IconData icon;
  final String title;
  final String detail;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final condition = compact
        ? Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4 * s),
                    child: Icon(icon, size: 14 * s, color: tone),
                  ),
                ),
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: _Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ' • $detail'),
              ],
            ),
            style: TextStyle(
              color: _Colors.slate300,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          )
        : Row(
            children: [
              Container(
                width: 40 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  color: box.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: box.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, size: 21 * s, color: tone),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      detail,
                      style: TextStyle(
                        color: _Colors.slate300,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
    return Container(
      width: 224 * s,
      padding: EdgeInsets.all((compact ? 8 : 12) * s),
      decoration: BoxDecoration(
        color: _Colors.glassNight,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: border.withValues(alpha: 0.8), width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 13 * s, color: headingColor),
              SizedBox(width: 4 * s),
              Expanded(
                child: Text(
                  heading.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: headingColor,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w900,
                    letterSpacing: labLetterSpacing(heading, 0.4),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 7 * s,
                  vertical: 2 * s,
                ),
                decoration: BoxDecoration(
                  color: box.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  temp,
                  style: TextStyle(
                    color: tone,
                    fontFamily: 'monospace',
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: (compact ? 5 : 7) * s),
            color: _Colors.slate700,
          ),
          condition,
        ],
      ),
    );
  }
}

// ================================================================== SIDEBAR

/// HTML `#teacher-content` "Observation Steps": a card per step with its
/// task, instructions and expected outcome. The current step is open (and
/// amber), done steps show a tick; a tap opens or closes any step (HTML
/// `toggleAccordion`).
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
  /// Steps the learner opened or closed since the step changed (the HTML
  /// redrew the list, current step open, on every step change).
  final Set<int> _toggled = {};

  bool _isOpen(int i) => (i == widget.current) != _toggled.contains(i);

  @override
  void didUpdateWidget(covariant _StepsAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) _toggled.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * widget.scale),
            child: _tile(i),
          ),
      ],
    );
  }

  Widget _tile(int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final dark = p.isDark;
    final past = i < w.current;
    final current = i == w.current;
    final open = _isOpen(i);
    final step = w.steps[i - 1];
    final amber = p.ink(_Colors.amber400);
    final border = current
        ? _Colors.amber500
        : (past
              ? _Colors.emerald500.withValues(alpha: 0.5)
              : (dark ? _Colors.slate800 : _Colors.slate300));
    final head = current
        ? (dark ? _Colors.slate800 : _Colors.amber500.withValues(alpha: 0.1))
        : (dark ? const Color(0x800F172A) : _Colors.slate100);
    final tone = current
        ? amber
        : (past
              ? (dark ? _Colors.emerald400 : _Colors.emerald600)
              : (dark ? _Colors.slate400 : _Colors.slate500));
    final radius = BorderRadius.circular(12);
    final body = TextStyle(
      color: dark ? _Colors.slate300 : _Colors.slate700,
      fontSize: 12 * f,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
    final strong = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: border),
        boxShadow: current
            ? const [
                BoxShadow(color: Color(0x4DF59E0B), spreadRadius: 1),
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: head,
              child: InkWell(
                onTap: () {
                  _Sound.pop.play();
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
                          width: 22 * s,
                          height: 22 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: past
                                ? _Colors.emerald500.withValues(alpha: 0.2)
                                : (current
                                      ? _Colors.amber500
                                      : (dark
                                            ? _Colors.slate800
                                            : _Colors.slate200)),
                            border: Border.all(
                              color: past
                                  ? _Colors.emerald500.withValues(alpha: 0.4)
                                  : (current
                                        ? _Colors.amber400
                                        : (dark
                                              ? _Colors.slate600
                                              : _Colors.slate300)),
                            ),
                          ),
                          child: past
                              ? Icon(
                                  Icons.check,
                                  size: 13 * s,
                                  color: _Colors.emerald500,
                                )
                              : Text(
                                  '$i',
                                  style: TextStyle(
                                    color: current
                                        ? _Colors.slate950
                                        : (dark
                                              ? _Colors.slate400
                                              : _Colors.slate500),
                                    fontSize: 11 * s,
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
                              fontWeight: current
                                  ? FontWeight.w800
                                  : FontWeight.w700,
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
                  color: dark ? const Color(0x660F172A) : _Colors.white,
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
                        color: p.ink(_Colors.amber500),
                        fontSize: 10 * f,
                        fontWeight: FontWeight.w900,
                        letterSpacing: labLetterSpacing(w.conceptLabel, 0.8),
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      step.concept,
                      style: body.copyWith(
                        color: dark ? _Colors.slate200 : _Colors.slate800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${w.actionLabel}: ', style: strong),
                          TextSpan(text: step.action),
                        ],
                      ),
                      style: body,
                    ),
                    SizedBox(height: 8 * s),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${w.observationLabel}: ',
                            style: strong,
                          ),
                          TextSpan(text: step.observation),
                        ],
                      ),
                      style: body.copyWith(
                        color: dark ? _Colors.slate400 : _Colors.slate600,
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
}

// ==================================================================== POPUPS

/// HTML `#summary-modal` body: the lightbulb badge, "Scenario N Complete!",
/// the summary's bold heading and text (`heading|text`, see STRINGS) and,
/// for Scenario 1, the note to pick the next scenario.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.summary,
    required this.heading,
    required this.palette,
    required this.scale,
    required this.fontScale,
    this.note,
  });

  final String title;
  final String summary;

  /// The heading's colour (amber in Scenario 1, emerald in Scenario 2).
  final Color heading;
  final String? note;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final split = summary.indexOf('|');
    final head = split < 0 ? '' : summary.substring(0, split);
    final text = split < 0 ? summary : summary.substring(split + 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.lightbulb,
              size: 28 * s,
              color: p.ink(_Colors.amber400),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 20 * f,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10 * s),
        if (head.isNotEmpty) ...[
          Text(
            head,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.ink(heading),
              fontSize: 16 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
        ],
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
        if (note != null) ...[
          SizedBox(height: 14 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: _Colors.amber500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.amber500.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 16 * s, color: p.ink(_Colors.amber400)),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    note!,
                    style: TextStyle(
                      color: p.ink(_Colors.amber300),
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
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: _Colors.yellow500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Colors.yellow500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56 * s,
              height: 56 * s,
              decoration: BoxDecoration(
                color: _Colors.yellow500.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _Colors.yellow500.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.emoji_events,
                size: 28 * s,
                color: p.ink(_Colors.yellow400),
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textStrong,
              fontSize: 20 * f,
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
      ),
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

/// Three.js lines (the orbits and the habitable ring's edges) are 1 px.
const double _lineWidth = 1.2;

/// Night side of a planet: ambient light only (AmbientLight 0x64748b,
/// 0.75), drawn as a black veil of this opacity.
const double _nightShade = 0.62;

/// Summed point-light strength that fully lights a planet's day side.
const double _fullLight = 1.2;

/// TextPainters for the canvas labels, laid out once and reused every
/// frame. At most [_capacity] are kept (a dragged star's distance changes
/// its label every frame). Owned (and disposed) by the page State.
class _TextCache {
  static const int _capacity = 96;
  final Map<Object, TextPainter> _painters = {};

  TextPainter get(Object key, InlineSpan Function() span) {
    final hit = _painters.remove(key);
    if (hit != null) {
      _painters[key] = hit;
      return hit;
    }
    final painter = TextPainter(text: span(), textDirection: TextDirection.ltr)
      ..layout();
    _painters[key] = painter;
    while (_painters.length > _capacity) {
      _painters.remove(_painters.keys.first)!.dispose();
    }
    return painter;
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
  }
}

/// A floating label (HTML `.planet-label`): its icon, name and distance,
/// the text and border colours and, on the star the slider moves, the
/// highlight ring (`ring-2 scale-105`).
@immutable
class _Chip {
  const _Chip({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.color,
    required this.border,
    this.detail,
    this.detailColor = _Colors.white,
    this.ring,
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final Color color;
  final Color border;
  final String? detail;
  final Color detailColor;
  final Color? ring;
}

/// A chip laid out: its icon and text painters, rect and size factor.
typedef _ChipBox = ({TextPainter icon, TextPainter text, Rect rect, double k});

/// A planet's surface: ocean and land colours (Mars has no land), how
/// cracked it is (0–1), its turn, the white cloud shell (opacity and
/// radius as a multiple of the planet's) and Mars' polar cap.
@immutable
class _Surface {
  const _Surface({
    required this.ocean,
    this.land,
    this.spin = 0,
    this.cracks = 0,
    this.veil = 0,
    this.shell = 1,
    this.cap = false,
  });

  final Color ocean;
  final Color? land;
  final double spin;
  final double cracks;
  final double veil;
  final double shell;
  final bool cap;
}

/// The light on a body: its direction in camera space and its strength
/// (0–1).
typedef _Light = (_V dir, double power);

/// A point light: position, intensity and range.
typedef _Lamp = (_V at, double intensity, double range);

/// Paints the HTML Three.js scenes: the starfield, then Scenario 1's
/// Earth, Sun and Sirius (farthest first) or Scenario 2's habitable ring,
/// orbits, Sun, Mars and Earth, then the floating labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final bool showLabels;
  final LabLang lang;

  /// Label size relative to the HTML's (enlarged on a small stage).
  final double labelScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()..style = PaintingStyle.stroke;
  final Paint _soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.cam;
    // HTML `#canvas-wrapper` (#03071e), over the letterbox too.
    canvas.drawRect(labBleed(size), Paint()..color = _Colors.space);
    _starfield(canvas, cam, size);
    if (scene.scenario == 0) {
      _neighbours(canvas, cam);
    } else {
      _system(canvas, cam);
    }
  }

  // ------------------------------------------------------------ background

  /// The 2200 background stars, projected once per camera framing.
  void _starfield(Canvas canvas, _Cam cam, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    final key = Object.hash(s.scenario, cam.center, cam.focal, size);
    var points = s.skyPoints;
    if (points == null || s.skyKey != key) {
      final list = <double>[];
      for (final v in _skyStars) {
        if (!cam.inFront(v)) continue;
        final o = cam.p(v);
        if (bleed.contains(o)) list.addAll([o.dx, o.dy]);
      }
      points = s.skyPoints = Float32List.fromList(list);
      s.skyKey = key;
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      points,
      Paint()
        ..color = _Colors.skyStar.withValues(alpha: _skyOpacity)
        ..strokeWidth = _skyPointPx
        ..strokeCap = StrokeCap.round,
    );
  }

  // ------------------------------------------------------------ scenario 1

  /// HTML Scenario 1: the Earth, the Sun and Sirius, farthest first, then
  /// their labels (Sirius' on top).
  void _neighbours(Canvas canvas, _Cam cam) {
    final s = scene;
    final t = s.time;
    final sun = s.sunPos;
    final sirius = s.siriusPos;
    final bodies = <(double, void Function())>[
      (cam.depth(_earthAt), () => _earthS1(canvas, cam)),
      (
        cam.depth(sun),
        () => _star(
          canvas,
          cam,
          sun,
          _sunR,
          _Colors.sun,
          s.sunCore,
          _Colors.sunCore,
          _sunRings,
          t * _sunSpin,
          additive: true,
        ),
      ),
      (
        cam.depth(sirius),
        () => _star(
          canvas,
          cam,
          sirius,
          _siriusR,
          _Colors.sirius,
          s.siriusCore,
          _Colors.siriusCore,
          _siriusRings,
          t * _siriusSpin,
          additive: true,
        ),
      ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, draw) in bodies) {
      draw();
    }
    s
      ..sunLabel = null
      ..siriusLabel = null;
    if (!showLabels) return;
    final earthAt = cam.p(_earthAt);
    final earth = _Chip(
      icon: Icons.public,
      iconColor: _Colors.blue400,
      name: _t('earth_observer'),
      color: _Colors.blue400,
      border: _Colors.blue500,
    );
    final sunAt = cam.p(sun);
    final sunChip = _Chip(
      icon: Icons.wb_sunny,
      iconColor: _Colors.amber400,
      name: _t('sun_label'),
      detail: '(${_auText(s.sunAu)} au)',
      detailColor: _Colors.amber300,
      color: _Colors.white,
      border: _Colors.amber500,
      ring: s.target == _Star.sun ? _Colors.amber400 : null,
    );
    final siriusAt = cam.p(sirius);
    final siriusChip = _Chip(
      icon: Icons.star,
      iconColor: const Color(0xFF67E8F9),
      name: _t('sirius_label'),
      detail: '(${_auText(s.siriusAu)} au | ${_t('sirius_desc')})',
      detailColor: _Colors.cyan200,
      color: _Colors.sky400,
      border: _Colors.sky400,
      ring: s.target == _Star.sirius ? _Colors.cyan400 : null,
    );
    // Sirius' chip is drawn last (on top, as the HTML); the others step
    // aside when they would hide under it.
    final siriusBox = _layoutChip(siriusAt, _liftSirius, siriusChip);
    final sunBox = _clear(
      _layoutChip(sunAt, _liftSunS1, sunChip),
      sunAt,
      _liftSunS1,
      [siriusBox.rect],
    );
    final earthBox = _clear(
      _layoutChip(earthAt, _liftEarthS1, earth),
      earthAt,
      _liftEarthS1,
      [siriusBox.rect, sunBox.rect],
    );
    _drawChip(canvas, earthBox, earth);
    s
      ..sunLabel = _drawChip(canvas, sunBox, sunChip)
      ..siriusLabel = _drawChip(canvas, siriusBox, siriusChip);
  }

  /// s1Earth: blue under its white cloud shell, lit by the Sun's and
  /// Sirius' point lights.
  void _earthS1(Canvas canvas, _Cam cam) {
    final s = scene;
    final light = _lightOn(cam, _earthAt, [
      (s.sunPos, _sunLight, _sunLightRange),
      (s.siriusPos, _siriusLight, _siriusLightRange),
    ]);
    _planet(
      canvas,
      cam.p(_earthAt),
      _earthR * cam.scaleAt(_earthAt),
      light,
      _Surface(
        ocean: _Colors.ocean,
        land: _Colors.land,
        spin: s.time * _earthSpinS1,
        veil: _earthVeil,
        shell: _earthShellR / _earthR,
      ),
    );
  }

  // ------------------------------------------------------------ scenario 2

  /// HTML Scenario 2 from above: the habitable ring and its edges, the
  /// Earth's and Mars' orbits, the Sun, Mars and the Earth, then the
  /// labels.
  void _system(Canvas canvas, _Cam cam) {
    final s = scene;
    final o = cam.p(_V.zero);
    final k = cam.scaleAt(_V.zero);
    _fill
      ..shader = null
      ..color = _Colors.zone.withValues(alpha: 0.22);
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCircle(center: o, radius: _zoneOuter * k))
        ..addOval(Rect.fromCircle(center: o, radius: _zoneInner * k)),
      _fill,
    );
    _stroke
      ..strokeWidth = _lineWidth
      ..color = _Colors.zone.withValues(alpha: 0.55);
    canvas
      ..drawCircle(o, _zoneInner * k, _stroke)
      ..drawCircle(o, _zoneOuter * k, _stroke);
    _stroke.color = _Colors.earthOrbit.withValues(alpha: 0.6);
    canvas.drawCircle(o, _auUnits * s.earthAu * k, _stroke);
    _stroke.color = _Colors.marsOrbit.withValues(alpha: 0.45);
    canvas.drawCircle(o, _marsOrbit * k, _stroke);

    _star(
      canvas,
      cam,
      _V.zero,
      _s2SunR,
      _Colors.sun,
      0,
      _Colors.sun,
      _s2SunRings,
      s.time * _s2SunSpin,
      additive: false,
    );
    final mars = s.marsPos;
    _planet(
      canvas,
      cam.p(mars),
      _marsR * cam.scaleAt(mars),
      _lightOn(cam, mars, const [(_V.zero, _s2SunLight, _s2SunLightRange)]),
      const _Surface(ocean: _Colors.mars, cap: true),
    );
    _earthS2(canvas, cam);

    if (!showLabels) return;
    final sunChip = _Chip(
      icon: Icons.wb_sunny,
      iconColor: _Colors.amber400,
      name: _t('sun_label'),
      color: _Colors.white,
      border: _Colors.amber500,
    );
    final earthAt = cam.p(s.earthPos);
    final earthChip = _Chip(
      icon: Icons.public,
      iconColor: _Colors.blue400,
      name: _t('earth_label'),
      detail: '(${_orbitText(s.earthAu)} au)',
      detailColor: _Colors.blue300,
      color: _Colors.blue400,
      border: _Colors.blue500,
    );
    final marsAt = cam.p(mars);
    final marsChip = _Chip(
      icon: Icons.public,
      iconColor: _Colors.red400,
      name: _t('mars_label'),
      detail: '(${_orbitText(_marsAu)} au)',
      detailColor: _Colors.red300,
      color: _Colors.red400,
      border: _Colors.red500,
    );
    final sunBox = _layoutChip(o, _liftSunS2, sunChip);
    final earthBox = _clear(
      _layoutChip(earthAt, _liftEarthS2, earthChip),
      earthAt,
      _liftEarthS2,
      [sunBox.rect],
    );
    final marsBox = _clear(
      _layoutChip(marsAt, _liftMars, marsChip),
      marsAt,
      _liftMars,
      [sunBox.rect, earthBox.rect],
    );
    _drawChip(canvas, sunBox, sunChip);
    _drawChip(canvas, earthBox, earthChip);
    _drawChip(canvas, marsBox, marsChip);
  }

  /// s2EarthMesh with the HTML's described climates (its JavaScript never
  /// changed the Earth): close to the Sun the oceans dry to brown sea beds,
  /// the land browns and cracks, the Earth glows hot and steam rises; far
  /// away the oceans freeze white and the land is snowed over.
  void _earthS2(Canvas canvas, _Cam cam) {
    final s = scene;
    final at = s.earthPos;
    final c = cam.p(at);
    final k = cam.scaleAt(at);
    final r = _s2EarthR * k;
    final celsius = _surfaceTemp(s.earthAu);
    final heat = _heatOf(celsius);
    final cold = _coldOf(celsius);
    if (heat > 0) {
      labGlow(canvas, c, r * 2.3, _Colors.heatGlow, intensity: 0.75 * heat);
    }
    if (cold > 0) {
      labGlow(canvas, c, r * 1.9, _Colors.frost, intensity: 0.5 * cold);
    }
    final ocean = Color.lerp(
      Color.lerp(_Colors.ocean, _Colors.seaBed, heat),
      _Colors.ice,
      cold,
    )!;
    final land = Color.lerp(
      Color.lerp(_Colors.land, _Colors.dryLand, heat),
      _Colors.snow,
      cold,
    )!;
    _planet(
      canvas,
      c,
      r,
      _lightOn(cam, at, const [(_V.zero, _s2SunLight, _s2SunLightRange)]),
      _Surface(
        ocean: ocean,
        land: land,
        spin: s.time * _earthSpinS2,
        cracks: heat,
        veil: _s2EarthVeil * (1 - 0.6 * heat),
        shell: _s2EarthShellR / _s2EarthR,
      ),
    );
    if (heat > 0) _steam(canvas, c, r, k, heat);
  }

  /// The eight steam puffs rising off a hot Earth.
  void _steam(Canvas canvas, Offset c, double r, double k, double heat) {
    final t = scene.time;
    for (var i = 0; i < _steamCount; i++) {
      final p = (t / _steamSeconds + i / _steamCount) % 1;
      final at = c + _steamAt[i] * r + Offset(0, -p * r * 1.9);
      _soft.color = _Colors.steam.withValues(alpha: 0.9 * (1 - p) * heat);
      canvas.drawCircle(at, _steamR * k * (0.6 + 0.9 * p), _soft);
    }
  }

  // ---------------------------------------------------------------- bodies

  /// A star (MeshBasicMaterial sphere, flat colour) with its corona rings,
  /// which turn with it about the vertical axis: the half behind the star
  /// is drawn first, the near half over it. The core dot hides the sphere
  /// and the rings inside it once it outgrows the sphere (the far stars'
  /// bright dots).
  void _star(
    Canvas canvas,
    _Cam cam,
    _V pos,
    double sphereR,
    Color color,
    double coreR,
    Color core,
    List<_Ring> rings,
    double spin, {
    required bool additive,
  }) {
    final c = cam.p(pos);
    final k = cam.scaleAt(pos);
    final body = math.max(sphereR, coreR);
    var outer = body;
    for (final ring in rings) {
      outer = math.max(outer, ring.$2);
    }
    // Added: a soft halo (the HTML's glow is its coronas alone).
    labGlow(
      canvas,
      c,
      math.max(outer, body * 1.8) * k * 1.05,
      color,
      intensity: 0.3,
    );
    final squash = math.cos(spin).abs();
    final rightNear = math.sin(2 * spin) < 0;
    _rings(canvas, c, k, rings, body, squash, !rightNear, additive);
    _fill
      ..shader = null
      ..blendMode = BlendMode.srcOver
      ..color = coreR > sphereR ? core : color;
    canvas.drawCircle(c, body * k, _fill);
    _rings(canvas, c, k, rings, body, squash, rightNear, additive);
  }

  /// One half (screen right or left) of each corona ring, outside the
  /// radius [hidden] (inside it the star hides the ring). [squash] is the
  /// ring's width on screen as a share of its height.
  void _rings(
    Canvas canvas,
    Offset c,
    double k,
    List<_Ring> rings,
    double hidden,
    double squash,
    bool right,
    bool additive,
  ) {
    if (squash < 0.01) return;
    for (final (inner, outer, color, opacity) in rings) {
      final from = math.max(inner, hidden);
      if (from >= outer) continue;
      _fill
        ..shader = null
        ..color = color.withValues(alpha: opacity)
        ..blendMode = additive ? BlendMode.plus : BlendMode.srcOver;
      canvas.drawPath(
        _halfAnnulus(c, from * k, outer * k, squash, right: right),
        _fill,
      );
    }
    _fill.blendMode = BlendMode.srcOver;
  }

  /// The point lights on a body at [at]: their directions in camera space
  /// weighted by intensity × the HTML's distance fall-off (1 − distance /
  /// range), summed.
  _Light _lightOn(_Cam cam, _V at, List<_Lamp> lamps) {
    var sum = _V.zero;
    for (final (pos, intensity, range) in lamps) {
      final d = pos - at;
      final fall = (1 - d.length / range).clamp(0.0, 1.0);
      sum = sum + cam.view(d.unit) * (intensity * fall);
    }
    return (sum.unit, (sum.length / _fullLight).clamp(0.0, 1.0));
  }

  /// A lit planet (MeshLambertMaterial): its surface, Lambert shading from
  /// [light], Mars' cap and the white cloud shell (MeshBasicMaterial, over
  /// the night side too).
  void _planet(
    Canvas canvas,
    Offset c,
    double r,
    _Light light,
    _Surface surface,
  ) {
    if (r < 0.5) return;
    final disc = Rect.fromCircle(center: c, radius: r);
    canvas
      ..save()
      ..clipPath(Path()..addOval(disc));
    _fill
      ..shader = null
      ..blendMode = BlendMode.srcOver
      ..color = surface.ocean;
    canvas.drawRect(disc, _fill);
    final land = surface.land;
    if (land != null) {
      _fill.color = land;
      for (var i = 0; i < _continents.length; i++) {
        final blob = _continent(c, r, i, surface.spin);
        if (blob != null) canvas.drawPath(blob, _fill);
      }
    }
    if (surface.cracks > 0) _crackLines(canvas, c, r, surface);
    _shade(canvas, c, r, light);
    if (surface.cap) {
      _fill.color = _Colors.marsCap;
      canvas.drawPath(
        Path()
          ..arcTo(disc, -math.pi / 2 - _marsCap, 2 * _marsCap, true)
          ..close(),
        _fill,
      );
    }
    canvas.restore();
    if (surface.veil > 0) {
      _fill.color = _Colors.white.withValues(alpha: surface.veil);
      canvas.drawCircle(c, r * surface.shell, _fill);
    }
  }

  /// Continent [i] on a sphere turned by [spin], or null on the far side.
  Path? _continent(Offset c, double r, int i, double spin) {
    final (lon0, lat0, size) = _continents[i];
    final wobble = _continentWobble[i];
    final path = Path();
    var near = false;
    for (var j = 0; j < _continentPoints; j++) {
      final a = j / _continentPoints * 2 * math.pi;
      final d = size * wobble[j];
      final lat = lat0 + d * math.sin(a);
      final lon = lon0 + d * math.cos(a) / math.cos(lat0);
      final (o, front) = _onSphere(c, r, lon + spin, lat);
      near |= front;
      if (j == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    return near ? (path..close()) : null;
  }

  /// A point on a sphere: projected (flattened onto the rim when it is on
  /// the far side) and whether it faces the camera.
  (Offset, bool) _onSphere(Offset c, double r, double lon, double lat) {
    var x = math.cos(lat) * math.sin(lon);
    var y = math.sin(lat);
    final z = math.cos(lat) * math.cos(lon);
    if (z < 0) {
      final m = math.sqrt(x * x + y * y);
      if (m > 0) {
        x /= m;
        y /= m;
      }
    }
    return (Offset(c.dx + x * r, c.dy - y * r), z >= 0);
  }

  /// The cracks of a scorched Earth.
  void _crackLines(Canvas canvas, Offset c, double r, _Surface surface) {
    _stroke
      ..strokeWidth = math.max(0.8, r * 0.05)
      ..strokeCap = StrokeCap.round
      ..color = _Colors.crack.withValues(alpha: 0.85 * surface.cracks);
    for (final crack in _cracks) {
      for (var j = 1; j < crack.length; j++) {
        final (a, aFront) = _onSphere(
          c,
          r,
          crack[j - 1].$1 + surface.spin,
          crack[j - 1].$2,
        );
        final (b, bFront) = _onSphere(
          c,
          r,
          crack[j].$1 + surface.spin,
          crack[j].$2,
        );
        if (aFront && bFront) canvas.drawLine(a, b, _stroke);
      }
    }
  }

  /// Lambert shading: the night side keeps the ambient light only; the day
  /// side, beyond the terminator (a half ellipse as wide as the light's
  /// pull towards or away from the camera), brightens towards the light.
  void _shade(Canvas canvas, Offset c, double r, _Light light) {
    final (dir, power) = light;
    final lz = dir.z.clamp(-1.0, 1.0);
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(math.atan2(-dir.y, dir.x));
    final disc = Rect.fromCircle(center: Offset.zero, radius: r);
    final terminator = Rect.fromCenter(
      center: Offset.zero,
      width: math.max(2 * lz.abs() * r, 0.01),
      height: 2 * r,
    );
    final day = Path()
      ..arcTo(disc, -math.pi / 2, math.pi, true)
      ..arcTo(terminator, math.pi / 2, lz < 0 ? -math.pi : math.pi, false)
      ..close();
    _fill
      ..shader = null
      ..color = LabInk.black.withValues(alpha: _nightShade);
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addOval(disc), day),
      _fill,
    );
    final span = Rect.fromLTRB(-lz * r, -r, r, r);
    if (span.width > 0.5) {
      _fill.shader = LinearGradient(
        colors: [
          LabInk.black.withValues(alpha: _nightShade),
          LabInk.black.withValues(alpha: _nightShade * (1 - power) * 0.5),
          LabInk.white.withValues(alpha: 0.14 * power),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(span);
      canvas.drawPath(day, _fill);
      _fill.shader = null;
    }
    canvas.restore();
  }

  // ---------------------------------------------------------------- labels

  /// HTML `updateLabelDOM()`: lays out a `.planet-label` chip whose bottom
  /// centre sits [lift] px above [at] (`translate(-50%, -100%)`).
  _ChipBox _layoutChip(Offset at, double lift, _Chip chip) {
    final k = labelScale * (chip.ring != null ? 1.05 : 1);
    final icon = texts.get(
      ('icon', chip.icon.codePoint, chip.iconColor.toARGB32(), k),
      () => TextSpan(
        text: String.fromCharCode(chip.icon.codePoint),
        style: TextStyle(
          fontFamily: chip.icon.fontFamily,
          package: chip.icon.fontPackage,
          fontSize: _labelIconPx * k,
          color: chip.iconColor,
          height: 1,
        ),
      ),
    );
    final text = texts.get(
      (
        'text',
        chip.name,
        chip.detail,
        chip.color.toARGB32(),
        chip.detailColor.toARGB32(),
        k,
        LabFont.active.family,
      ),
      () => TextSpan(
        style: TextStyle(
          color: chip.color,
          fontSize: _labelPx * k,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
        children: [
          TextSpan(text: chip.name),
          if (chip.detail != null)
            TextSpan(
              text: ' ${chip.detail}',
              style: TextStyle(
                color: chip.detailColor,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
    final w = icon.width + _labelGap * k + text.width + 2 * _labelPadX * k;
    final h = math.max(icon.height, text.height) + 2 * _labelPadY * k;
    final bottom = at.dy + lift * labelScale;
    return (
      icon: icon,
      text: text,
      rect: Rect.fromLTWH(at.dx - w / 2, bottom - h, w, h),
      k: k,
    );
  }

  /// Moves a chip that would cover one of [others] below its anchor [at]
  /// (as far below as it was above), or further down past them. The HTML's
  /// chips piled up where the far Sun and Sirius meet.
  _ChipBox _clear(_ChipBox box, Offset at, double lift, List<Rect> others) {
    bool covers(Rect r) => others.any(r.overlaps);
    if (!covers(box.rect)) return box;
    var rect = Rect.fromLTWH(
      box.rect.left,
      at.dy - lift * labelScale,
      box.rect.width,
      box.rect.height,
    );
    for (final other in others) {
      if (rect.overlaps(other)) {
        rect = rect.translate(0, other.bottom + 4 * labelScale - rect.top);
      }
    }
    return (icon: box.icon, text: box.text, rect: rect, k: box.k);
  }

  /// Paints a chip laid out by [_layoutChip]; returns its rect.
  Rect _drawChip(Canvas canvas, _ChipBox box, _Chip chip) {
    final (:icon, :text, :rect, :k) = box;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(_labelRadius * k));
    // box-shadow: 0 6px 20px rgba(0, 0, 0, 0.7), 0 0 12px (border, 0.35).
    canvas
      ..drawRRect(
        rr.shift(Offset(0, 6 * k)),
        Paint()
          ..color = LabInk.black.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * k),
      )
      ..drawRRect(
        rr,
        Paint()
          ..color = chip.border.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * k),
      );
    _fill
      ..shader = null
      ..color = _Colors.labelBg;
    canvas.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.5 * k
      ..color = chip.border.withValues(alpha: 0.85);
    canvas.drawRRect(rr.deflate(0.75 * k), _stroke);
    final ring = chip.ring;
    if (ring != null) {
      _stroke
        ..strokeWidth = 2 * k
        ..color = ring;
      canvas.drawRRect(rr.inflate(1 * k), _stroke);
    }
    icon.paint(
      canvas,
      Offset(rect.left + _labelPadX * k, rect.center.dy - icon.height / 2),
    );
    text.paint(
      canvas,
      Offset(
        rect.left + _labelPadX * k + icon.width + _labelGap * k,
        rect.center.dy - text.height / 2,
      ),
    );
    return rect;
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.texts != texts ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// One half (screen [right] or left) of a ring between [inner] and [outer]
/// px, its width squashed to [squash] of its height.
Path _halfAnnulus(
  Offset c,
  double inner,
  double outer,
  double squash, {
  required bool right,
}) {
  final o = Rect.fromCenter(
    center: c,
    width: 2 * outer * squash,
    height: 2 * outer,
  );
  final i = Rect.fromCenter(
    center: c,
    width: 2 * inner * squash,
    height: 2 * inner,
  );
  final start = right ? -math.pi / 2 : math.pi / 2;
  return Path()
    ..arcTo(o, start, math.pi, true)
    ..arcTo(i, start + math.pi, -math.pi, false)
    ..close();
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
