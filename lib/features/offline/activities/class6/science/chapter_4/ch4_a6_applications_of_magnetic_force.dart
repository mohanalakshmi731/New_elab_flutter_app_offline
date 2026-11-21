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

// Class 6 Science • Chapter 4 • Activity 6 — Applications of Magnetic Force.
// Native Flutter port of `Cl6S-Ch4-A6-Applications_of_Magnetic_Force.html`
// (Three.js r128 + tween.js). The page class is at the top of STATE.

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// snap → `science/drop.mp3`, clink → `science/pop.mp3`,
/// clack → `science/pop.mp3`.
///
/// The HTML synthesises four Web-Audio tones in `playSound(type)`; each is
/// mapped onto the closest Mixkit file: `snap` (a short falling square-wave
/// thud) → drop, `clink` / `clack` (the same rising 700 → 1400 Hz chirp) →
/// pop, `success` (rising C-E-G-C arpeggio) → success.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action / right answer.
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action / invalid move.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario solved (HTML `playSound('success')`) / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `playSound('snap')`: maze, magnet or car snaps into place.
  snap('audio/class6/science/drop.mp3'),

  /// HTML `playSound('clink')`: steel ball lands on Start.
  clink('audio/class6/science/pop.mp3'),

  /// HTML `playSound('clack')`: red car lands behind the blue car.
  clack('audio/class6/science/pop.mp3');

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

  /// The HTML plays its success chime once when a scenario is solved. The
  /// shell's conclusion popup, which opens right after (S2) or 1.2 s later
  /// (S1), plays the same tone again; a repeat inside this gap is skipped.
  static const Duration _successGap = Duration(milliseconds: 2500);
  static final Stopwatch _sinceSuccess = Stopwatch();

  /// Plays [sound] without blocking. Silent under `flutter test`, which has
  /// no audio plugin. Errors (missing plugin, unsupported platform) are
  /// swallowed so audio never breaks the lab.
  static void play(_Sound sound, {double volume = 0.6}) {
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    if (sound == _Sound.success) {
      if (_sinceSuccess.isRunning && _sinceSuccess.elapsed < _successGap) {
        return;
      }
      _sinceSuccess
        ..reset()
        ..start();
    }
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

/// Tailwind and Three.js colours used by this lab (HTML values).
abstract final class _Colors {
  // ---------------------------------------------------------------- UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  /// "Enter Lab" button `bg-[#eab308] text-slate-900` (ZSL yellow).
  static const Color zslYellow = Color(0xFFEAB308);

  /// Tailwind config `primary` (#6366f1) and its shades.
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color red400 = Color(0xFFF87171);
  static const Color red600 = Color(0xFFDC2626);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan700 = Color(0xFF0E7490);

  /// `ph-lightning text-amber-500` in the "Expected Outcome" boxes.
  static const Color amber500 = Color(0xFFF59E0B);

  // ------------------------------------------------------------- scene
  /// `#canvas-wrapper` background (dark in both themes) and its grid.
  static const Color canvas = Color(0xFF0F172A);
  static const Color grid = Color(0x08FFFFFF); // rgba(255,255,255,0.03)

  /// Floating object labels: `bg-slate-900/90`, `border-indigo-500/40`.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = Color(0x666366F1);

  static const Color wood = Color(0xFF855E42); // workbench
  static const Color legs = Color(0xFF1E293B);
  static const Color mazeShelf = Color(0xFF475569);
  static const Color cardboard = Color(0xFFDEB887);
  static const Color mazeWall = Color(0xFFBC8F8F);
  static const Color startRing = Color(0xFF3B82F6);
  static const Color finishRing = Color(0xFFEAB308); // emissive #ca8a04
  static const Color finishDone = Color(0xFF22C55E);
  static const Color steel = Color(0xFF94A3B8);
  static const Color steelLight = Color(0xFFF8FAFC);
  static const Color steelDark = Color(0xFF1E293B);
  static const Color north = Color(0xFFE53E3E); // N half (red)
  static const Color south = Color(0xFF3182CE); // S half (blue)
  static const Color field = Color(0xFF06B6D4); // field lines / beams
  static const Color glow = Color(0xFF6366F1); // selection glow meshes
  static const Color track = Color(0xFF1E293B);
  static const Color dash = Color(0xFFFFFFFF);
  static const Color curb = Color(0xFFEAB308);
  static const Color raceShelf = Color(0xFF334155);
  static const Color blueCar = Color(0xFF3B82F6);
  static const Color redCar = Color(0xFFEF4444);
  static const Color cabin = Color(0xFF1E293B);
  static const Color wheel = Color(0xFF0F172A);
  static const Color hub = Color(0xFF64748B);
  static const Color wave = Color(0xFFEF4444); // repulsion ring
  static const Color shadow = Color(0xFF000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900, // --bg-primary
    panel: Color(0xF20F172A), // bg-slate-900/95
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B), // bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvas,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.green500,
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.indigo900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE61E293B),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0x806366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2F8FAFC), // bg-slate-50/95
    border: Color(0x26000000), // --glass-border
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvas, // the HTML canvas stays dark
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.green600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.indigo900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE61E293B),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0x806366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font (the HTML's Plus
/// Jakarta Sans is not bundled), which includes Devanagari for Hindi. Sizes
/// are the HTML sidebar text size slider (15 px default, from 12 px); the
/// shell's standard 24 px maximum replaces the HTML's 32 px.
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
// Copied from the HTML `i18n` table (Telugu dropped; `app_subtitle` keeps
// the later "Exploring Magnets" value, which overrides the first one in the
// JS object). Native changes, all listed in the conversion report:
// * step_1_3 / step_1_5 / step_2_3 / step_2_4 / step_2_5 say exactly what
//   the learner does on a touch screen (DROP, TAP, which way to drag, and
//   that step 5 of S1 needs no action);
// * the Hindi texts quote the Hindi canvas labels ('प्रारंभ', 'समाप्ति')
//   and the Hindi Flip button instead of the English 'Start' / 'Finish' /
//   'FLIP';
// * the blue car's North pole faces the red car (the HTML text says the
//   cars repel with N facing N), so `lbl_blue_car` / `out_2_1` say "left";
// * 'task_instruction' / 'expected_outcome' were hard-coded English in the
//   HTML accordion; `btn_flip_mag` drops the 🔄 emoji (the button has an
//   icon).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Applications of Magnetic Force',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'scen_1_opt': 'Scenario 1: The Maze Challenge',
    'scen_2_opt': 'Scenario 2: Magnetic Car Race',
    'concept_exp': 'Procedural Steps',
    'step_lbl': 'Step',
    'task_instruction': 'Task Instruction',
    'expected_outcome': 'Expected Outcome',
    'obs_table': 'Observation Table',
    'tbl_obj': 'Condition / Objects',
    'tbl_attract': 'Observed Effect',
    'tbl_pending': '--',
    's1_desc':
        'To guide a steel ball through a cardboard maze using a magnet from underneath, demonstrating that magnetic force can act through a non-magnetic material.',
    's2_desc':
        'To explore magnetic attraction and repulsion between toy cars equipped with bar magnets, demonstrating how high-speed Maglev propulsion works.',
    's1_hud':
        'Drag the cardboard maze from the side shelf onto the center of the workbench.',
    's2_hud':
        'Drag the blue toy car from the shelf onto the right side of the racetrack.',
    'step_1_1':
        'DRAG the cardboard maze from the shelf and DROP it onto the center of the workbench.',
    'step_1_2':
        "DRAG the steel ball from the shelf tray and DROP it onto the 'Start' position of the maze.",
    'step_1_3':
        'DRAG the bar magnet and DROP it underneath the workbench, directly below the steel ball.',
    'step_1_4':
        "While keeping the magnet under the workbench, DRAG it along the maze path from 'Start' to 'Finish'.",
    'step_1_5':
        "No action needed: WATCH the steel ball settle in the green 'Finish' area of the maze.",
    'step_1_6':
        "Summary: The magnet's force passes right through the wooden table and cardboard maze to move the steel ball without touching it!",
    'step_2_1':
        'DRAG the blue toy car and DROP it onto the right side of the racetrack.',
    'step_2_2':
        'DRAG the red toy car and DROP it onto the track behind (left of) the blue car.',
    'step_2_3':
        'DRAG the red car towards the blue car and keep pushing until magnetic repulsion slides the blue car forward.',
    'step_2_4':
        "TAP the 'Flip Magnet (N ↔ S)' button to rotate the red car's magnet 180 degrees.",
    'step_2_5':
        'DRAG the red car backwards (to the left) along the track to pull the blue car along via magnetic attraction.',
    'step_2_6':
        'Summary: Like poles PUSH (repel), and unlike poles PULL (attract). This non-contact magnetic force propels modern Maglev trains!',
    'out_1_1':
        'The maze is correctly positioned on the workbench, ready for the experiment.',
    'out_1_2':
        'The metallic steel ball rests at the beginning Start position of the maze.',
    'out_1_3':
        'Magnet positioned below table. Magnetic field lines penetrate wood and cardboard, causing the steel ball to jiggle.',
    'out_1_4':
        'As you drag the magnet underneath, the steel ball on top moves smoothly, perfectly mirroring the trajectory.',
    'out_1_5':
        'The steel ball reaches the green Finish zone. A success chime triggers, proving non-contact magnetic force!',
    'out_1_6':
        'Verified that magnetic force acts through distances and non-magnetic materials to pull objects without contact.',
    'out_2_1':
        "The blue car rests on the racetrack with its North pole (N) facing left, towards the red car's side.",
    'out_2_2':
        'The red car is placed behind. Like poles (N-N) face each other and immediately push apart via magnetic repulsion.',
    'out_2_3':
        'Dragging the red car closer intensifies the repulsive force field, pushing the blue car forward along the track.',
    'out_2_4':
        "The red car's magnet flips 180°. Now South (S) faces North (N). Opposite poles pull together and snap!",
    'out_2_5':
        'As you drag the red car away, magnetic attraction pulls the blue car along behind it smoothly.',
    'out_2_6':
        'Conclusion verified: Like poles PUSH (repel) and unlike poles PULL (attract). This drives frictionless Maglev trains.',
    'lbl_workbench': 'Workbench',
    'lbl_maze': 'Cardboard Maze',
    'lbl_ball': 'Steel Ball',
    'lbl_magnet': 'Bar Magnet',
    'lbl_start': 'Start',
    'lbl_finish': 'Finish',
    'lbl_blue_car': 'Blue Car (N Pole Left)',
    'lbl_red_car': 'Red Car',
    'lbl_racetrack': 'Maglev Racetrack',
    'pole_n': 'N',
    'pole_s': 'S',
    'btn_flip_mag': 'Flip Magnet (N ↔ S)',
    'btn_validate': 'Record Observation',
    'complete_maze_first': 'Please complete the maze challenge first!',
    'complete_race_first': 'Please complete the car race challenge first!',
    // Added: the ball is only held while the magnet is close below it.
    'toast_s1_far':
        'The steel ball is too far from the magnet. Move the magnet back under '
        'the ball.',
    'toast_s1_maze': 'Cardboard maze placed on workbench.',
    'toast_s1_ball': 'Steel ball placed at Start position.',
    'toast_s1_mag': 'Magnet connected underneath workbench!',
    'toast_s1_finish': 'Maze Challenge Completed!',
    'toast_s2_blue': 'Blue car placed on racetrack.',
    'toast_s2_red': 'Like poles (N-N) repel! Blue car pushed ahead.',
    'toast_s2_push': 'Magnetic repulsion pushes the car forward!',
    'toast_s2_flip': 'Magnet flipped (S-N)! Opposite poles attract.',
    'sum_s1_title': 'Maze Challenge Complete!',
    'sum_s1_desc':
        'Amazing! You proved that magnetic force can act at a distance and pass through non-magnetic materials like wood and cardboard.',
    'sum_s2_title': 'Car Race Complete!',
    'sum_s2_desc':
        'Great discovery! Like poles PUSH (repel) and unlike poles PULL (attract). This principle eliminates friction and drives modern Maglev trains.',
    'tbl_s1_o1': 'Steel Ball + Magnet',
    'tbl_s1_r1': 'Attracted (Moved)',
    'tbl_s1_o2': 'Cardboard Barrier',
    'tbl_s1_r2': 'Force Passed Through',
    'tbl_s2_o1': 'North (N) facing North (N)',
    'tbl_s2_r1': 'Repulsion (Push)',
    'tbl_s2_o2': 'South (S) facing North (N)',
    'tbl_s2_r2': 'Attraction (Pull)',
  },
  'hi': {
    'app_title': 'चुंबकीय बल के अनुप्रयोग',
    'app_subtitle': 'कक्षा 6 • चुंबकों का अन्वेषण',
    'scen_1_opt': 'परिदृश्य 1: भूलभुलैया चुनौती',
    'scen_2_opt': 'परिदृश्य 2: चुंबकीय कार दौड़',
    'concept_exp': 'प्रक्रियात्मक चरण',
    'step_lbl': 'चरण',
    'task_instruction': 'कार्य निर्देश',
    'expected_outcome': 'अपेक्षित परिणाम',
    'obs_table': 'अवलोकन तालिका',
    'tbl_obj': 'स्थिति / वस्तुएं',
    'tbl_attract': 'प्रेक्षित प्रभाव',
    'tbl_pending': '--',
    's1_desc':
        'मेज के नीचे से चुंबक का उपयोग करके स्टील की गेंद को कार्डबोर्ड भूलभुलैया के पार ले जाना, यह दर्शाता है कि चुंबकीय बल अचुंबकीय पदार्थों के आर-पार कार्य कर सकता है।',
    's2_desc':
        'छड़ चुंबकों से सुसज्जित खिलौना कारों के बीच चुंबकीय आकर्षण और प्रतिकर्षण का अन्वेषण करना, जिससे मैग्लेव ट्रेन की गति का पता चलता है।',
    's1_hud':
        'साइड शेल्फ से कार्डबोर्ड भूलभुलैया को खींचकर मेज के केंद्र पर रखें।',
    's2_hud': 'नीली कार को शेल्फ से खींचकर रेसट्रैक के दाईं ओर रखें।',
    'step_1_1':
        'कार्डबोर्ड भूलभुलैया को शेल्फ से खींचें और मेज के केंद्र में रखें।',
    'step_1_2':
        "स्टील की गेंद को शेल्फ ट्रे से खींचें और भूलभुलैया के 'प्रारंभ' स्थान पर छोड़ें।",
    'step_1_3':
        'छड़ चुंबक को खींचें और मेज के नीचे, ठीक स्टील की गेंद के नीचे छोड़ें।',
    'step_1_4':
        "चुंबक को मेज के नीचे रखते हुए, उसे 'प्रारंभ' से 'समाप्ति' तक भूलभुलैया के पथ पर खींचें।",
    'step_1_5':
        "कोई कार्य आवश्यक नहीं: स्टील की गेंद को भूलभुलैया के हरे 'समाप्ति' क्षेत्र में रुकते हुए देखें।",
    'step_1_6':
        'सारांश: चुंबक का बल लकड़ी की मेज और कार्डबोर्ड के पार होकर स्टील की गेंद को बिना छुए चलाता है!',
    'step_2_1': 'नीली कार को खींचें और रेसट्रैक के दाईं ओर रखें।',
    'step_2_2':
        'लाल कार को खींचें और नीली कार के पीछे (बाईं ओर) ट्रैक पर रखें।',
    'step_2_3':
        'लाल कार को नीली कार की ओर खींचें और तब तक धकेलते रहें जब तक चुंबकीय प्रतिकर्षण नीली कार को आगे न खिसका दे।',
    'step_2_4':
        "लाल कार के चुंबक को 180 डिग्री घुमाने के लिए 'चुंबक पलटें (N ↔ S)' बटन पर टैप करें।",
    'step_2_5':
        'चुंबकीय आकर्षण द्वारा नीली कार को साथ खींचने के लिए लाल कार को ट्रैक पर पीछे (बाईं ओर) खींचें।',
    'step_2_6':
        'सारांश: समान ध्रुव प्रतिकर्षित (धकेलते) हैं, और विपरीत ध्रुव आकर्षित (खींचते) हैं। यही आधुनिक मैग्लेव ट्रेनों का आधार है!',
    'out_1_1':
        'भूलभुलैया सही ढंग से मेज पर स्थापित हो जाती है, प्रयोग के लिए तैयार।',
    'out_1_2':
        "धात्विक स्टील की गेंद भूलभुलैया के 'प्रारंभ' स्थान पर स्थिर हो जाती है।",
    'out_1_3':
        'चुंबक मेज के नीचे है। चुंबकीय बल रेखाएं लकड़ी और कार्डबोर्ड के पार होकर गेंद को प्रभावित करती हैं।',
    'out_1_4':
        'जैसे ही आप नीचे चुंबक खींचते हैं, ऊपर स्टील की गेंद उसी पथ का अनुसरण करती हुई आसानी से चलती है।',
    'out_1_5':
        "गेंद 'समाप्ति' क्षेत्र में पहुंचती है। सफल ध्वनि बजती है, जो संपर्क-रहित चुंबकीय बल को सिद्ध करती है!",
    'out_1_6':
        'सत्यापित हुआ कि चुंबकीय बल दूरी से और अचुंबकीय पदार्थों के आर-पार बिना छुए वस्तुओं को खींच सकता है।',
    'out_2_1':
        'नीली कार ट्रैक पर खड़ी है जिसका उत्तरी ध्रुव (N) बाईं ओर, लाल कार की तरफ है।',
    'out_2_2':
        'लाल कार पीछे रखी गई। समान ध्रुव (N-N) आमने-सामने आते ही चुंबकीय प्रतिकर्षण द्वारा एक-दूसरे को धकेलते हैं।',
    'out_2_3':
        'लाल कार को पास लाने पर प्रतिकर्षण बल बढ़ता है, जिससे नीली कार बिना छुए ट्रैक पर आगे बढ़ती है।',
    'out_2_4':
        'चुंबक 180° घूमता है। अब दक्षिण (S) ध्रुव उत्तर (N) के सामने है। विपरीत ध्रुव आपस में जुड़ जाते हैं!',
    'out_2_5':
        'जैसे ही आप लाल कार को दूर खींचते हैं, चुंबकीय आकर्षण नीली कार को साथ खींचता है।',
    'out_2_6':
        'निष्कर्ष सत्यापित: समान ध्रुव धकेलते हैं और विपरीत ध्रुव खींचते हैं। यही आधुनिक मैग्लेव ट्रेनों को गति देता है।',
    'lbl_workbench': 'कार्य मेज',
    'lbl_maze': 'कार्डबोर्ड भूलभुलैया',
    'lbl_ball': 'स्टील की गेंद',
    'lbl_magnet': 'छड़ चुंबक',
    'lbl_start': 'प्रारंभ',
    'lbl_finish': 'समाप्ति',
    'lbl_blue_car': 'नीली कार (N ध्रुव बाएं)',
    'lbl_red_car': 'लाल कार',
    'lbl_racetrack': 'मैग्लेव ट्रैक',
    'pole_n': 'N',
    'pole_s': 'S',
    'btn_flip_mag': 'चुंबक पलटें (N ↔ S)',
    'btn_validate': 'अवलोकन दर्ज करें',
    'complete_maze_first': 'कृपया पहले भूलभुलैया चुनौती पूरी करें!',
    'complete_race_first': 'कृपया पहले कार दौड़ चुनौती पूरी करें!',
    'toast_s1_far':
        'स्टील की गेंद चुंबक से बहुत दूर है। चुंबक को वापस गेंद के नीचे लाएं।',
    'toast_s1_maze': 'कार्डबोर्ड भूलभुलैया मेज पर रखी गई।',
    'toast_s1_ball': 'स्टील की गेंद प्रारंभ स्थिति पर तैयार है।',
    'toast_s1_mag': 'चुंबक मेज के नीचे सक्रिय हो गया!',
    'toast_s1_finish': 'भूलभुलैया चुनौती पूरी हुई!',
    'toast_s2_blue': 'नीली कार ट्रैक पर रखी गई।',
    'toast_s2_red': 'समान ध्रुव (N-N) प्रतिकर्षित करते हैं! नीली कार आगे बढ़ी।',
    'toast_s2_push': 'चुंबकीय प्रतिकर्षण कार को आगे धकेलता है!',
    'toast_s2_flip': 'चुंबक पलट गया (S-N)! विपरीत ध्रुव आकर्षित करते हैं।',
    'sum_s1_title': 'भूलभुलैया चुनौती पूरी हुई!',
    'sum_s1_desc':
        'अद्भुत! आपने सिद्ध किया कि चुंबकीय बल दूरी से और लकड़ी तथा कार्डबोर्ड जैसे अचुंबकीय पदार्थों के आर-पार कार्य कर सकता है।',
    'sum_s2_title': 'कार दौड़ पूरी हुई!',
    'sum_s2_desc':
        'शानदार खोज! समान ध्रुव धकेलते हैं और विपरीत ध्रुव खींचते हैं। यह घर्षण समाप्त करता है और मैग्लेव ट्रेनों को चलाता है।',
    'tbl_s1_o1': 'स्टील गेंद + चुंबक',
    'tbl_s1_r1': 'आकर्षित (गतिमान)',
    'tbl_s1_o2': 'कार्डबोर्ड अवरोध',
    'tbl_s1_r2': 'बल आर-पार हुआ',
    'tbl_s2_o1': 'उत्तर (N) के सामने उत्तर (N)',
    'tbl_s2_r1': 'प्रतिकर्षण (धक्का)',
    'tbl_s2_o2': 'दक्षिण (S) के सामने उत्तर (N)',
    'tbl_s2_r2': 'आकर्षण (खिंचाव)',
  },
};

/// Steps per scenario (HTML `updateUI()` renders steps 1..6).
const int _stepCount = 6;

/// Scenarios in the HTML `#scenario-selector`.
const int _scenarioCount = 2;

/// HTML `step_s_n` (action) and `out_s_n` (expected outcome) of scenario
/// [index] in [lang]. The HTML steps have no concept text.
LabScenarioData _buildScenario(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return LabScenarioData(
    title: t('scen_${n}_opt'),
    objective: t('s${n}_desc'),
    steps: [
      for (var i = 1; i <= _stepCount; i++)
        LabStep(
          concept: '',
          action: t('step_${n}_$i'),
          observation: t('out_${n}_$i'),
        ),
    ],
  );
}

/// Both scenarios in both languages, built once from [_i18n].
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values)
    lang: [for (var i = 0; i < _scenarioCount; i++) _buildScenario(lang, i)],
};

// ===================================================================== STATE

/// Class 6 Science • Chapter 4 • Activity 6
/// Applications of Magnetic Force.
///
/// Native Flutter port of `Cl6S-Ch4-A6-Applications_of_Magnetic_Force.html`.
///
/// Scenario 1 (The Maze Challenge): drag the cardboard maze onto the
/// workbench, the steel ball onto Start and the bar magnet under the table,
/// then drag the hidden magnet along the maze path. Its force acts through
/// the wood and the cardboard and the ball follows it to Finish.
///
/// Scenario 2 (Magnetic Car Race): put the blue and the red toy car on the
/// track, push the blue car without touching it (like poles repel), flip
/// the red car's magnet and pull the blue car along (unlike poles attract).
class Ch4A6ApplicationsOfMagneticForcePage extends StatefulWidget {
  const Ch4A6ApplicationsOfMagneticForcePage({super.key});

  @override
  State<Ch4A6ApplicationsOfMagneticForcePage> createState() =>
      _Ch4A6ApplicationsOfMagneticForcePageState();
}

/// Design size of the stage: the scene is painted and hit-tested in it.
const Size _design = Size(1000, 560);

/// Touch slop of the scene drags (Flutter's default is 18 px).
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

// ------------------------------------------------------------ HTML numbers

/// S1 drag planes (HTML `intersectPlane.setComponents(0, 1, 0, -y)`).
const double _mazePlaneY = 0.45;
const double _ballPlaneY = 0.55;
const double _magnetPlaneY = 0.5;

/// S1 step ≥ 4: the magnet slides on this plane under the table top.
const double _underTableY = -1.2;

/// S2 drag plane of the cars.
const double _carPlaneY = 0.4;

/// Where things snap to (HTML `onPointerUp` tweens).
const _V _mazeOnBench = _V(0, 0.15, 0);
const _V _ballOnStart = _V(-3.4, 0.42, -1.8);
const _V _magnetUnderStart = _V(-3.4, -1.2, -1.8);
const _V _blueOnTrack = _V(2.5, 0.4, 0);
const _V _redOnTrack = _V(-2.0, 0.4, 0);

/// The blue car settles a little closer when the red car arrives (500 ms).
const _V _blueNudged = _V(2.2, 0.4, 0);

/// Table opacity once the magnet is under it (600 ms tween).
const double _tableSeeThrough = 0.45;

/// The ball jiggles up to this height (140 ms, yoyo, repeat 3).
const double _jiggleY = 0.65;

/// Per-frame lerp factors at 60 fps: ball → magnet, blue car → red car.
const double _ballFollow = 0.35;
const double _blueFollow = 0.4;

/// Finish zone test (ball.x > 2.8 && ball.z > 1.0).
const double _finishX = 2.8;
const double _finishZ = 1.0;

/// The magnet under the table holds the ball only within this horizontal
/// distance. The HTML pulled the ball from anywhere, straight through the
/// walls, so a single tap on Finish solved the maze.
const double _pullRange = 2.5;

/// Steel ball radius (SphereGeometry 0.35).
const double _ballRadius = 0.35;

/// Maze walls in maze-local coordinates, (x, z, width, depth): far and near
/// walls, the two sides and the two inner barriers (the boxes the painter
/// draws). The ball cannot pass through them.
const List<(double, double, double, double)> _mazeWalls = [
  (0, -3.1, 9.6, 0.2),
  (0, 3.1, 9.6, 0.2),
  (-4.7, 0, 0.2, 6.4),
  (4.7, 0, 0.2, 6.4),
  (-1.5, 1.2, 0.2, 3.8),
  (1.5, -1.2, 0.2, 3.8),
];

/// Largest move of the ball per collision sub-step.
const double _ballSubStep = 0.05;

/// S2: like poles keep the cars 4.2 apart; unlike poles hold them 2.6
/// apart; the push moves on once the blue car passes x = 3.0; the pull
/// finishes once the learner has dragged the red car 1.5 units from where
/// it was at the flip. (The HTML finished once the red car left
/// -3.0 < x < 1.0, so after a long push the pull completed by itself.)
const double _repelGap = 4.2;
const double _attractGap = 2.6;
const double _pushDoneX = 3.0;
const double _pullDistance = 1.5;

/// S2 step 2: the red car is accepted only behind (left of) the blue car,
/// at least this far behind its centre; otherwise it goes back to its shelf.
const double _redBehindBlue = 1.0;
const _V _redShelf = _V(-14, 0.7, 2);

/// HTML `rotateWheels(car, diffX * 2)`.
const double _wheelSpin = 2;

/// S1 summary appears 1.2 s after the ball reaches Finish.
const Duration _summaryDelay = Duration(milliseconds: 1200);

// ------------------------------------------------------------------ camera

/// HTML `PerspectiveCamera(45, …)`: focal length in design px for a 45°
/// vertical field of view over the 560 px stage (280 / tan 22.5°).
const double _focal = 675.98;

/// Principal point. The HTML camera looks at the origin; the scene sits
/// 60 px right of the stage centre so the side shelf is not cut off.
const Offset _viewCenter = Offset(560, 280);

/// While the sidebar is collapsed the floating mission card covers the
/// top-left of the canvas, so the scene eases this far down (380 ms, like
/// the sidebar animation).
const double _collapsedDrop = 140;
const double _framingSeconds = 0.38;

/// HTML camera positions (`changeScenario`), both looking at the origin.
const _V _eyeMaze = _V(0, 14, 16);
const _V _eyeRace = _V(0, 12, 24);

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);
  final double x, y, z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);
  double distanceTo(_V o) => (this - o).length;
  _V withX(double v) => _V(v, y, z);
  _V withY(double v) => _V(x, v, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML camera: perspective projection, picking rays and drag planes,
/// all in design coordinates.
class _Camera {
  _Camera(this.eye, this.center) {
    f = (_V.zero - eye).unit;
    r = f.cross(_V.up).unit;
    u = r.cross(f);
  }

  final _V eye;
  final Offset center;
  late final _V f, r, u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design px per world unit at [w].
  double scaleAt(_V w) => _focal / math.max(0.05, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = _focal / math.max(0.05, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World ray through a design point (HTML `raycaster.setFromCamera`).
  _V ray(Offset s) =>
      (f +
              r * ((s.dx - center.dx) / _focal) +
              u * (-(s.dy - center.dy) / _focal))
          .unit;

  /// Where that ray meets the horizontal plane y = [planeY]
  /// (HTML `ray.intersectPlane`), or null.
  _V? onPlane(Offset s, double planeY) {
    final d = ray(s);
    if (d.y.abs() < 1e-9) return null;
    final t = (planeY - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Ray distance to an axis-aligned box (slab test), or null.
  double? hitBox(Offset s, _V c, _V size) {
    final d = ray(s);
    var tMin = 0.0, tMax = double.infinity;
    final o = [eye.x, eye.y, eye.z];
    final dir = [d.x, d.y, d.z];
    final lo = [c.x - size.x / 2, c.y - size.y / 2, c.z - size.z / 2];
    final hi = [c.x + size.x / 2, c.y + size.y / 2, c.z + size.z / 2];
    for (var i = 0; i < 3; i++) {
      if (dir[i].abs() < 1e-12) {
        if (o[i] < lo[i] || o[i] > hi[i]) return null;
        continue;
      }
      var t1 = (lo[i] - o[i]) / dir[i], t2 = (hi[i] - o[i]) / dir[i];
      if (t1 > t2) (t1, t2) = (t2, t1);
      tMin = math.max(tMin, t1);
      tMax = math.min(tMax, t2);
      if (tMin > tMax) return null;
    }
    return tMin;
  }

  /// Ray distance to a sphere, or null.
  double? hitSphere(Offset s, _V c, double radius) {
    final d = ray(s);
    final oc = eye - c;
    final b = oc.dot(d);
    final disc = b * b - (oc.dot(oc) - radius * radius);
    if (disc < 0) return null;
    final t = -b - math.sqrt(disc);
    return t > 0 ? t : null;
  }
}

// ------------------------------------------------------------------ tweens

/// TWEEN.Easing.Linear.None.
double _linear(double t) => t;

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => t * (2 - t);

/// TWEEN.Easing.Back.Out (overshoot s = 1.70158).
double _backOut(double t) {
  const s = 1.70158;
  final u = t - 1;
  return u * u * ((s + 1) * u + s) + 1;
}

/// HTML per-frame `lerp(a, b, factor)` at 60 fps, made frame-rate
/// independent: the fraction covered in [dt] seconds.
double _follow(double factor, double dt) =>
    1 - math.pow(1 - factor, dt * 60).toDouble();

/// One tween.js tween: [apply] receives the eased progress 0..1.
class _Tween {
  _Tween({
    required this.start,
    required this.duration,
    required this.apply,
    this.ease = _linear,
    this.repeat = 0,
    this.yoyo = false,
    this.onComplete,
  });

  final double start;
  final double duration;
  final void Function(double k) apply;
  final double Function(double t) ease;
  final int repeat;
  final bool yoyo;
  final VoidCallback? onComplete;

  /// Applies the tween at [now] (seconds); true once it has finished.
  bool update(double now) {
    final runs = repeat + 1;
    final e = math.max(0.0, (now - start) / duration);
    if (e >= runs) {
      apply(yoyo && repeat.isOdd ? 0 : 1);
      return true;
    }
    final cycle = e.floor();
    var t = e - cycle;
    if (yoyo && cycle.isOdd) t = 1 - t;
    apply(ease(t));
    return false;
  }
}

// ------------------------------------------------------------- scene model

/// The draggable objects (HTML `interactables`).
enum _Obj { maze, ball, magnet, blueCar, redCar }

/// One draggable object.
class _Body {
  _Body(this.id, _V home) : pos = home;

  final _Obj id;
  _V pos;

  /// HTML `userData.draggable` (false once placed for good).
  bool draggable = true;

  bool get isCar => id == _Obj.blueCar || id == _Obj.redCar;

  /// Hit volume: the HTML invisible glow mesh, which the raycaster also
  /// hits (the magnet's is a little taller for fingers).
  _V get hitCenter => isCar ? pos + const _V(0, 0.8, 0) : pos;
  _V get hitSize => switch (id) {
    _Obj.maze => const _V(10, 0.6, 6.8),
    _Obj.magnet => const _V(3.4, 1.0, 1.2),
    _ => const _V(3.6, 1.8, 2.0),
  };

  /// Glow sphere radius 0.5, enlarged for fingers.
  static const double ballHitRadius = 0.7;
}

/// All mutable simulation state; the painter reads it every frame.
class _Scene {
  _Scene() {
    load(0, collapsed: false);
  }

  int scenario = 0;
  int step = 1;

  /// Ticker time in seconds.
  double time = 0;

  /// Bumped whenever something visible changes (drives repaints).
  int version = 0;

  late _Body maze, ball, magnet, blueCar, redCar;

  /// HTML `selectedObject`, its drag plane and grab offset.
  _Body? selected;
  double planeY = 0;
  _V offset = _V.zero;

  final List<_Tween> tweens = [];

  // S1
  double tableOpacity = 1;
  bool fieldLines = false;
  _V fieldPos = _V.zero;
  bool finishGreen = false;

  /// The magnet was moved too far from the ball (the hint was shown).
  bool ballLost = false;

  // S2
  bool waves = false;
  _V wavesPos = _V.zero;
  bool beams = false;
  _V beamsPos = _V.zero;
  double redMagnetYaw = 0;

  /// HTML `#flip-button-container` is visible.
  bool flipShown = false;

  /// The flip has started (the push stops, the pull takes over).
  bool flipped = false;
  bool s2Done = false;

  /// Red car's x when the pull (step 5) began.
  double pullStartX = 0;
  double prevRedX = 0;
  double redRoll = 0;
  double blueRoll = 0;

  /// 0 = sidebar open, 1 = collapsed (linear; eased in [framing]).
  double framingT = 0;

  double get framing => Curves.easeInOutCubic.transform(framingT);

  List<_Body> get interactables =>
      scenario == 0 ? [maze, ball, magnet] : [blueCar, redCar];

  _Camera get camera => _Camera(
    scenario == 0 ? _eyeMaze : _eyeRace,
    _viewCenter.translate(0, _collapsedDrop * framing),
  );

  void touch() => version++;

  /// HTML `changeScenario(id)`: clears the scene and builds [index] at
  /// step 1 with every object back on its shelf.
  void load(int index, {required bool collapsed}) {
    scenario = index;
    step = 1;
    tweens.clear();
    selected = null;
    offset = _V.zero;
    maze = _Body(_Obj.maze, const _V(-11.5, 0.45, -2.2));
    ball = _Body(_Obj.ball, const _V(-11.5, 0.55, 1.5));
    magnet = _Body(_Obj.magnet, const _V(-11.5, 0.5, 3.5));
    blueCar = _Body(_Obj.blueCar, const _V(-14, 0.7, -2));
    redCar = _Body(_Obj.redCar, _redShelf);
    tableOpacity = 1;
    fieldLines = false;
    fieldPos = _magnetUnderStart;
    finishGreen = false;
    ballLost = false;
    waves = false;
    beams = false;
    redMagnetYaw = 0;
    flipShown = false;
    flipped = false;
    s2Done = false;
    pullStartX = 0;
    prevRedX = redCar.pos.x;
    redRoll = 0;
    blueRoll = 0;
    framingT = collapsed ? 1 : 0;
    touch();
  }

  void tween(
    double seconds,
    void Function(double k) apply, {
    double Function(double t) ease = _linear,
    int repeat = 0,
    bool yoyo = false,
    VoidCallback? onComplete,
  }) {
    tweens.add(
      _Tween(
        start: time,
        duration: seconds,
        apply: apply,
        ease: ease,
        repeat: repeat,
        yoyo: yoyo,
        onComplete: onComplete,
      ),
    );
  }

  /// Tween of a whole position (`new TWEEN.Tween(obj.position).to(...)`).
  void tweenPos(
    _Body body,
    _V to,
    double seconds, {
    double Function(double t) ease = _linear,
  }) {
    final from = body.pos;
    tween(seconds, (k) => body.pos = _V.lerp(from, to, k), ease: ease);
  }
}

/// Pan recognizer that only joins the gesture arena when [canGrab] picks up
/// a scene object at pointer-down (HTML `onPointerDown`), so every other
/// drag still reaches the zoom viewer.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(Offset localPosition)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event.localPosition) ?? false) {
      super.addAllowedPointer(event);
    }
  }
}

/// One row of the HTML observation table.
@immutable
class _ObsRow {
  const _ObsRow(this.condition, this.effect, this.color);
  final String condition;
  final String effect;

  /// Result colour, or null while the row is still "--".
  final Color? color;
}

class _Ch4A6ApplicationsOfMagneticForcePageState
    extends State<Ch4A6ApplicationsOfMagneticForcePage>
    with SingleTickerProviderStateMixin {
  // HTML `cameraLocked = true`: drags interact with the scene.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final _TextCache _texts = _TextCache();
  late final Ticker _ticker;

  /// The last toast this lab showed (key and shown text), so it can be
  /// re-translated when the language changes while it is visible.
  String? _toastKey;
  String? _toastText;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

  /// Shows the toast for [key] (see [LabController.showToast]).
  void _toast(String key, {bool isError = false, bool sound = true}) {
    _toastKey = key;
    _toastText = _t(key);
    _lab.showToast(_toastText!, isError: isError, sound: sound);
  }

  /// Language switched while a toast is up: show it in the new language
  /// (this lab's toasts and the shell's "Scenario Complete" toast).
  void _onLabChanged() {
    final shown = _lab.toast;
    if (shown == null) return;
    String? text;
    if (_toastKey != null && shown.text == _toastText) {
      text = _t(_toastKey!);
      if (text == _toastText) return;
      _toastText = text;
    } else {
      for (final key in const ['msg_scenario_complete', 'msg_all_complete']) {
        final other = labTr(kLabCommonStrings, _lab.lang.next, key);
        if (shown.text == other && _lab.t(key) != other) text = _lab.t(key);
      }
    }
    if (text != null) {
      _lab.showToast(text, isError: shown.isError, sound: false);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_onLabChanged);
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
    _lab
      ..removeListener(_onLabChanged)
      ..dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- animation

  /// HTML `animate()`: TWEEN.update, then the continuous physics of the
  /// open scenario. Repaints only the canvas, and only when something moved.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;

    final target = _lab.isSidebarOpen ? 0.0 : 1.0;
    if (s.framingT != target) {
      final step = dt / _framingSeconds;
      s.framingT = target > s.framingT
          ? math.min(target, s.framingT + step)
          : math.max(target, s.framingT - step);
      s.touch();
    }

    if (s.tweens.isNotEmpty) {
      final finished = <_Tween>[];
      for (final tw in List.of(s.tweens)) {
        if (tw.update(now)) finished.add(tw);
      }
      s.tweens.removeWhere(finished.contains);
      s.touch();
      for (final tw in finished) {
        tw.onComplete?.call();
      }
    }

    if (s.scenario == 0) {
      _mazePhysics(dt);
    } else {
      _racePhysics(dt);
    }
    _frame.value = s.version;
  }

  /// HTML "Scenario 1 continuous guiding": from step 4 the ball lerps to
  /// the magnet under the table; reaching Finish solves the maze. Unlike the
  /// HTML, the ball follows only while the magnet is close below it, and
  /// the maze walls stop it.
  void _mazePhysics(double dt) {
    final s = _scene;
    if (s.step < 4) return;
    final m = s.magnet.pos;
    s.fieldPos = _V(m.x, -0.3, m.z);
    final b = s.ball.pos;
    final dx = m.x - b.x, dz = m.z - b.z;
    if (dx * dx + dz * dz > _pullRange * _pullRange) {
      if (s.step == 4 && !s.ballLost && s.selected == s.magnet) {
        s.ballLost = true;
        _toast('toast_s1_far', isError: true);
      }
      return;
    }
    s.ballLost = false;
    final k = _follow(_ballFollow, dt);
    final to = _moveBall(b, b.x + dx * k, b.z + dz * k);
    if ((to.x - b.x).abs() + (to.z - b.z).abs() > 1e-5) {
      s.ball.pos = to;
      s.touch();
    }
    if (s.step == 4 && s.ball.pos.x > _finishX && s.ball.pos.z > _finishZ) {
      _finishMaze();
    }
  }

  /// Moves the ball towards (x1, z1) in small sub-steps; a maze wall stops
  /// the blocked direction only, so the ball slides along it.
  _V _moveBall(_V from, double x1, double z1) {
    final m = _scene.maze.pos;
    bool hits(double x, double z) {
      for (final (cx, cz, w, d) in _mazeWalls) {
        if ((x - m.x - cx).abs() < w / 2 + _ballRadius &&
            (z - m.z - cz).abs() < d / 2 + _ballRadius) {
          return true;
        }
      }
      return false;
    }

    final dx = x1 - from.x, dz = z1 - from.z;
    final n = math.max(1, (math.max(dx.abs(), dz.abs()) / _ballSubStep).ceil());
    var x = from.x, z = from.z;
    for (var i = 0; i < n; i++) {
      if (!hits(x + dx / n, z)) x += dx / n;
      if (!hits(x, z + dz / n)) z += dz / n;
    }
    return _V(x, from.y, z);
  }

  /// HTML finish trigger: step 5, success chime, green Finish ring; the
  /// summary follows 1.2 s later (step 6).
  void _finishMaze() {
    final s = _scene;
    setState(() {
      s.step = 5;
      s.finishGreen = true;
      s.touch();
    });
    _Sound.success.play();
    _toast('toast_s1_finish', sound: false);
    _lab.after(_summaryDelay, () {
      if (!mounted || s.scenario != 0 || s.step != 5) return;
      setState(() => s.step = 6);
      _showSummary();
    });
  }

  /// HTML "Scenario 2 continuous maglev race": wheels roll with the red
  /// car; like poles keep the blue car at least 4.2 ahead of it, unlike
  /// poles pull the blue car to 2.6 ahead of it.
  void _racePhysics(double dt) {
    final s = _scene;
    final red = s.redCar, blue = s.blueCar;
    final diffX = red.pos.x - s.prevRedX;
    s.prevRedX = red.pos.x;
    if (diffX != 0) {
      s.redRoll += diffX * _wheelSpin;
      s.touch();
    }
    // The HTML pushes only during step 3; the push is kept until the flip
    // so a learner still dragging when the Flip button appears cannot drive
    // the red car into the blue one.
    final pushing = s.step == 3 || (s.step == 4 && !s.flipped);
    if (pushing) {
      if (red.pos.x + _repelGap - blue.pos.x > 1e-9) {
        blue.pos = blue.pos.withX(red.pos.x + _repelGap);
        s.blueRoll += diffX * _wheelSpin;
        s.touch();
      }
      s.wavesPos = _V((red.pos.x + blue.pos.x) / 2, 0.6, 0);
      if (s.step == 3 && blue.pos.x > _pushDoneX && !s.flipShown) {
        setState(() {
          s.step = 4;
          s.flipShown = true;
        });
        _toast('toast_s2_push');
      }
    } else if (s.step == 5) {
      final goal = red.pos.x + _attractGap;
      final x = blue.pos.x + (goal - blue.pos.x) * _follow(_blueFollow, dt);
      if ((x - blue.pos.x).abs() > 1e-5) {
        blue.pos = blue.pos.withX(x);
        s.touch();
      }
      s.blueRoll += diffX * _wheelSpin;
      s.beamsPos = _V((red.pos.x + blue.pos.x) / 2, 0.7, 0);
      if ((red.pos.x - s.pullStartX).abs() >= _pullDistance && !s.s2Done) {
        setState(() {
          s.s2Done = true;
          s.step = 6;
        });
        _Sound.success.play();
        _showSummary();
      }
    }
  }

  // ------------------------------------------------------------------ logic

  /// HTML `changeScenario(id)` (scenario selector) and `resetApp()`: stops
  /// every timer and tween and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index, collapsed: !_lab.isSidebarOpen));
    _lab.resetView(sound: false);
  }

  /// HTML "Record Observation" (`validateInvestigation()`): re-opens the
  /// summary once the challenge is done, otherwise asks the learner to
  /// finish it first. Scenario 2 counts as done after the pull (the HTML
  /// accepted it from step 5, which would skip the pull).
  void _validate() {
    final s = _scene;
    final done = s.scenario == 0 ? s.step >= 5 : s.s2Done;
    if (!done) {
      _toast(
        s.scenario == 0 ? 'complete_maze_first' : 'complete_race_first',
        isError: true,
      );
      return;
    }
    _lab.style.click.play();
    _showSummary();
  }

  /// HTML `validateInvestigation()` at the end of a scenario: the summary
  /// popup ("Success!" + summary title + text).
  void _showSummary() {
    final index = _scene.scenario;
    final n = index + 1;
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('sum_s${n}_title'),
      body: () => _t('sum_s${n}_desc'),
    );
  }

  /// Moves to [step] with the HTML snap sound and toast.
  void _advance(int step, _Sound sound, String toast) {
    setState(() => _scene.step = step);
    sound.play();
    _toast(toast, sound: false);
  }

  /// HTML raycast: the nearest object under [p] (non-draggable ones block).
  _Body? _pick(Offset p) {
    final cam = _scene.camera;
    _Body? best;
    var bestT = double.infinity;
    for (final b in _scene.interactables) {
      final t = b.id == _Obj.ball
          ? cam.hitSphere(p, b.pos, _Body.ballHitRadius)
          : cam.hitBox(p, b.hitCenter, b.hitSize);
      if (t != null && t < bestT) {
        bestT = t;
        best = b;
      }
    }
    return best;
  }

  /// HTML `onPointerDown` step check: the toast key when [id] is not what
  /// the current step asks for, else null.
  String? _wrongObject(_Obj id) {
    final s = _scene;
    if (s.scenario == 0) {
      if (s.step == 1 && id != _Obj.maze) return 's1_hud';
      if (s.step == 2 && id != _Obj.ball) return 'step_1_2';
      if (s.step == 3 && id != _Obj.magnet) return 'step_1_3';
      return null;
    }
    if (s.step == 1 && id != _Obj.blueCar) return 's2_hud';
    if (s.step == 2 && id != _Obj.redCar) return 'step_2_2';
    return null;
  }

  double _planeFor(_Obj id) => switch (id) {
    _Obj.maze => _mazePlaneY,
    _Obj.ball => _ballPlaneY,
    _Obj.magnet => _scene.step >= 4 ? _underTableY : _magnetPlaneY,
    _Obj.blueCar || _Obj.redCar => _carPlaneY,
  };

  /// HTML `onPointerDown`: picks up the object under the finger (true =
  /// this gesture drags it). From S1 step 4 any touch grabs the magnet
  /// under the table and moves it to the touch point.
  bool _pointerDown(Offset p) {
    final s = _scene;
    if (s.selected != null) return false;
    if (s.scenario == 0 && s.step >= 4) {
      final m = s.magnet;
      s
        ..selected = m
        ..planeY = _underTableY
        ..offset = _V.zero;
      final q = s.camera.onPlane(p, _underTableY);
      if (q != null) {
        m.pos = _V(q.x.clamp(-4.2, 4.2), m.pos.y, q.z.clamp(-2.6, 2.6));
      }
      s.touch();
      return true;
    }
    final hit = _pick(p);
    if (hit == null || !hit.draggable) return false;
    final error = _wrongObject(hit.id);
    if (error != null) {
      _toast(error, isError: true);
      return false;
    }
    s
      ..selected = hit
      ..planeY = _planeFor(hit.id);
    final q = s.camera.onPlane(p, s.planeY);
    s.offset = q == null ? _V.zero : q - hit.pos;
    s.touch();
    return true;
  }

  /// HTML `onPointerMove`: the object follows the finger on its plane,
  /// inside the HTML clamps.
  void _pointerMove(Offset p) {
    final s = _scene;
    final o = s.selected;
    if (o == null) return;
    final q = s.camera.onPlane(p, s.planeY);
    if (q == null) return;
    final pt = q - s.offset;
    switch (o.id) {
      case _Obj.maze:
      case _Obj.ball:
        o.pos = _V(pt.x.clamp(-6.0, 6.0), o.pos.y, pt.z.clamp(-3.5, 3.5));
      case _Obj.magnet:
        final under = (s.step == 3 && pt.y < -0.1) || s.step >= 4;
        o.pos = _V(
          pt.x.clamp(-4.2, 4.2),
          under ? _underTableY : math.max(0.4, pt.y),
          pt.z.clamp(-2.6, 2.6),
        );
      case _Obj.blueCar:
      case _Obj.redCar:
        o.pos = _V(pt.x.clamp(-14.0, 9.0), o.pos.y, 0);
    }
    s.touch();
  }

  /// HTML `onPointerUp`: drops the object and runs the step's snap rule.
  void _pointerUp() {
    final s = _scene;
    final o = s.selected;
    if (o == null) return;
    s
      ..selected = null
      ..touch();
    final p = o.pos;
    switch (o.id) {
      case _Obj.maze when s.step == 1:
        if (p.x.abs() < 6 && p.z.abs() < 5) _placeMaze(o);
      case _Obj.ball when s.step == 2:
        if (p.distanceTo(_ballOnStart) < 5.0) _placeBall(o);
      case _Obj.magnet when s.step == 3:
        if (p.x > -9 || p.y < -0.1 || p.distanceTo(_magnetUnderStart) < 6.0) {
          _placeMagnet(o);
        }
      case _Obj.blueCar when s.step == 1:
        if (p.x > -12 && p.z.abs() < 6) _placeBlueCar(o);
      case _Obj.redCar when s.step == 2:
        if (p.x > -12 && p.z.abs() < 6) {
          if (p.x < s.blueCar.pos.x - _redBehindBlue) {
            _placeRedCar(o);
          } else {
            // In front of the blue car: back to the shelf.
            s.tweenPos(o, _redShelf, 0.3);
            _toast('step_2_2', isError: true);
          }
        }
      default:
        break;
    }
  }

  /// S1 step 1: the maze snaps to the bench centre (300 ms).
  void _placeMaze(_Body maze) {
    _scene.tweenPos(maze, _mazeOnBench, 0.3);
    maze.draggable = false;
    _advance(2, _Sound.snap, 'toast_s1_maze');
  }

  /// S1 step 2: the ball rolls onto Start (300 ms).
  void _placeBall(_Body ball) {
    _scene.tweenPos(ball, _ballOnStart, 0.3);
    ball.draggable = false;
    _advance(3, _Sound.clink, 'toast_s1_ball');
  }

  /// S1 step 3: the magnet slides under the ball (400 ms); the table turns
  /// see-through (600 ms), the field lines appear and the ball jiggles.
  void _placeMagnet(_Body magnet) {
    final s = _scene;
    s.tweenPos(magnet, _magnetUnderStart, 0.4);
    final from = s.tableOpacity;
    s.tween(0.6, (k) => s.tableOpacity = from + (_tableSeeThrough - from) * k);
    s.fieldLines = true;
    final ball = s.ball;
    final y0 = ball.pos.y;
    s.tween(
      0.14,
      (k) => ball.pos = ball.pos.withY(y0 + (_jiggleY - y0) * k),
      repeat: 3,
      yoyo: true,
    );
    _advance(4, _Sound.snap, 'toast_s1_mag');
  }

  /// S2 step 1: the blue car snaps to the right side of the track.
  void _placeBlueCar(_Body car) {
    _scene.tweenPos(car, _blueOnTrack, 0.3);
    car.draggable = false;
    _advance(2, _Sound.snap, 'toast_s2_blue');
  }

  /// S2 step 2: the red car lands behind the blue one; the repulsion ring
  /// appears and the blue car settles (500 ms, Quadratic.Out).
  void _placeRedCar(_Body car) {
    final s = _scene;
    s.tweenPos(car, _redOnTrack, 0.3);
    s.waves = true;
    s.tweenPos(s.blueCar, _blueNudged, 0.5, ease: _quadOut);
    _advance(3, _Sound.clack, 'toast_s2_red');
  }

  /// HTML `flipRedMagnet()`: the red car's magnet turns 180° (650 ms,
  /// Back.Out) and the blue car is pulled in (500 ms); then step 5.
  void _flip() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4 || !s.flipShown) return;
    setState(() {
      s
        ..flipShown = false
        ..flipped = true
        ..waves = false
        ..beams = true
        ..beamsPos = _V((s.redCar.pos.x + s.blueCar.pos.x) / 2, 0.7, 0);
    });
    s.tween(0.65, (k) => s.redMagnetYaw = math.pi * k, ease: _backOut);
    final blue = s.blueCar;
    final x0 = blue.pos.x;
    final x1 = s.redCar.pos.x + _attractGap;
    s.tween(
      0.5,
      (k) => blue.pos = blue.pos.withX(x0 + (x1 - x0) * k),
      ease: _quadOut,
      onComplete: () {
        if (!mounted || s.scenario != 1) return;
        s.pullStartX = s.redCar.pos.x;
        _advance(5, _Sound.snap, 'toast_s2_flip');
      },
    );
  }

  // --------------------------------------------------------------------- UI

  /// The HTML Flip button (shown at S2 step 4 only).
  List<LabAction> _actions() => [
    if (_scene.flipShown)
      LabAction(
        label: _t('btn_flip_mag'),
        icon: Icons.autorenew,
        // HTML: red → indigo → blue gradient pill; indigo is `primary`.
        color: _lab.palette.primary,
        foreground: _lab.palette.onPrimary,
        highlight: true,
        onTap: _flip,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.precision_manufacturing,
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
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _sidebarPanels(data, s),
          overlays: [
            // HTML `#flip-button-container`: floating button at the top
            // centre of the canvas (the sidebar / mission card carry it too).
            if (actions.isNotEmpty && _lab.popup == null)
              Positioned(
                top: inset.top + 48 * s,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: actions.first,
                    scale: s * 1.1,
                    expand: false,
                  ),
                ),
              ),
          ],
          stage: _buildStage(),
        );
      },
    );
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        // Canvas labels stay readable when the stage is scaled down.
        final uiScale = fit <= 0 ? 1.0 : (0.85 / fit).clamp(1.0, 1.9);
        return LabStage(
          designSize: _design,
          background: const ColoredBox(color: _Colors.canvas),
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..canGrab = _pointerDown
                      // Short drags must move objects: 8 px touch slop
                      // (16 px pan slop) instead of 18 / 36 px. A
                      // RawGestureDetector does not take MediaQuery's
                      // gesture settings, so they are set here.
                      ..gestureSettings = _dragSettings
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onUpdate = (d) {
                        _pointerMove(d.localPosition);
                      }
                      ..onEnd = (_) {
                        _pointerUp();
                      }
                      ..onCancel = _pointerUp,
                  ),
            },
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  repaint: _frame,
                  texts: _texts,
                  lang: _lab.lang,
                  showLabels: _lab.showLabels,
                  uiScale: uiScale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML teacher-board "Procedural Steps" accordion and the floating
  /// "Observation Table", both moved into the sidebar.
  Widget _sidebarPanels(LabScenarioData data, double s) {
    final p = _lab.palette;
    final f = s * _lab.fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepsAccordion(
          key: ValueKey('steps-${_scene.scenario}-${_scene.step}'),
          steps: data.steps,
          current: _scene.step,
          palette: p,
          scale: s,
          fontScale: f,
          stepLabel: _t('step_lbl'),
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
        _ObservationTable(
          header: (_t('tbl_obj'), _t('tbl_attract')),
          rows: _obsRows(p.isDark),
          palette: p,
          scale: s,
          fontScale: f,
        ),
        // HTML "Record Observation" under the table.
        SizedBox(height: 8 * s),
        LabActionButton(
          action: LabAction(
            label: _t('btn_validate'),
            icon: Icons.check_circle,
            silent: true,
            onTap: _validate,
          ),
          scale: s,
        ),
      ],
    );
  }

  /// HTML `updateUI()` observation table rows for the current step.
  List<_ObsRow> _obsRows(bool dark) {
    final s = _scene;
    final pending = _t('tbl_pending');
    if (s.scenario == 0) {
      final on = s.step >= 4;
      return [
        _ObsRow(
          _t('tbl_s1_o1'),
          on ? _t('tbl_s1_r1') : pending,
          on ? (dark ? _Colors.green500 : _Colors.green600) : null,
        ),
        _ObsRow(
          _t('tbl_s1_o2'),
          on ? _t('tbl_s1_r2') : pending,
          on ? (dark ? _Colors.indigo400 : _Colors.indigo600) : null,
        ),
      ];
    }
    final push = s.step >= 3, pull = s.step >= 5;
    return [
      _ObsRow(
        _t('tbl_s2_o1'),
        push ? _t('tbl_s2_r1') : pending,
        push ? (dark ? _Colors.red400 : _Colors.red600) : null,
      ),
      _ObsRow(
        _t('tbl_s2_o2'),
        pull ? _t('tbl_s2_r2') : pending,
        pull ? (dark ? _Colors.cyan400 : _Colors.cyan700) : null,
      ),
    ];
  }
}

/// HTML `#steps-container`: one card per step; the current step is open,
/// done steps show a tick and can be re-opened, future steps are dimmed.
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
    // Future steps: HTML `opacity-50 pointer-events-none`.
    final dim = future ? 0.5 : 1.0;
    final tone = current ? p.primary : (past ? p.success : p.textMuted);
    final border = current
        ? p.primary
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
                              ? p.primary
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.primary
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
                                      ? p.onPrimary
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
                  Text(
                    w.taskLabel.toUpperCase(),
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 9.5 * f,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    step.action,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: p.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: p.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 13 * f,
                              color: p.ink(_Colors.amber500),
                            ),
                            SizedBox(width: 4 * s),
                            Expanded(
                              child: Text(
                                w.outcomeLabel.toUpperCase(),
                                style: TextStyle(
                                  color: p.primary,
                                  fontSize: 9.5 * f,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * s),
                        Text(
                          step.observation,
                          style: TextStyle(
                            color: p.textStrong,
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
            ),
        ],
      ),
    );
  }
}

/// HTML `#results-table-container`: conditions and the effect observed so
/// far ("--" until the step that shows it).
class _ObservationTable extends StatelessWidget {
  const _ObservationTable({
    required this.header,
    required this.rows,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final (String, String) header;
  final List<_ObsRow> rows;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = fontScale;
    Widget row(Widget a, Widget b, {Color? fill, bool line = true}) =>
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            color: fill,
            border: line ? Border(top: BorderSide(color: p.cardBorder)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              SizedBox(width: 8 * s),
              Expanded(child: b),
            ],
          ),
        );
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Text(header.$1, style: head),
            Text(header.$2, style: head),
            fill: p.cardBorder.withValues(alpha: 0.35),
            line: false,
          ),
          for (final r in rows)
            row(
              Text(
                r.condition,
                style: TextStyle(
                  color: p.textStrong,
                  fontSize: 11 * f,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                r.effect,
                style: TextStyle(
                  color: r.color ?? p.textMuted,
                  fontSize: 11 * f,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// HTML lights: ambient 0.65, key light 0.85 from (12, 25, 15) and an
/// indigo fill light 0.3 from (-10, -10, -10). Toned down a little (there
/// is no tone mapping here) so lit faces do not burn out.
const _V _keyLight = _V(0.3806, 0.7929, 0.4757);
const _V _fillLight = _V(-0.5774, -0.5774, -0.5774);
const double _ambient = 0.6;
const double _keyStrength = 0.55;
const double _fillStrength = 0.12;

/// MeshStandardMaterial metals look darker without an environment map.
const double _metalDarkening = 0.45;

/// Shadows fall away from the key light: per unit of height they move
/// 12/25 along -x and 15/25 along -z.
const double _shadowSlopeX = 12 / 25;
const double _shadowSlopeZ = 15 / 25;

/// HTML `.canvas-grid`: 50 px cells.
const double _gridStep = 50;

/// Floating labels: HTML `text-[11px]` chips (scaled with the stage).
const double _labelFont = 11.5;

/// Height of the pole letters (HTML 80 px glyph on a 128 px sprite of
/// 0.6 world units) and of the letters on the car magnets.
const double _poleHeight = 0.375;
const double _carPoleHeight = 0.3;

/// Unit sine / cosine tables for the cylinder and ring outlines.
List<(double, double)> _circle(int n) => [
  for (var i = 0; i <= n; i++)
    (math.cos(2 * math.pi * i / n), math.sin(2 * math.pi * i / n)),
];
final List<(double, double)> _circle12 = _circle(12);
final List<(double, double)> _circle16 = _circle(16);
final List<(double, double)> _circle24 = _circle(24);
final List<(double, double)> _circle32 = _circle(32);

List<(double, double)> _circleOf(int n) => switch (n) {
  12 => _circle12,
  16 => _circle16,
  24 => _circle24,
  _ => _circle32,
};

/// Steel ball shading (MeshStandardMaterial metalness 0.95): a radial
/// gradient on a unit circle, scaled into place.
final Paint _steelPaint = Paint()
  ..shader = const RadialGradient(
    center: Alignment(-0.35, -0.45),
    radius: 1.05,
    colors: [
      _Colors.steelLight,
      _Colors.slate300,
      _Colors.steel,
      _Colors.steelDark,
    ],
    stops: [0, 0.22, 0.55, 1],
  ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));

/// Laid-out text for the canvas (labels and pole letters), kept between
/// frames and rebuilt when the language or the font changes.
class _TextCache {
  final Map<String, TextPainter> _cache = {};
  LabLang? _lang;
  String? _family;

  /// Size the pole letters are laid out at (then scaled into place).
  static const double poleSize = 40;

  void sync(LabLang lang) {
    final family = LabFont.active.family;
    if (lang == _lang && family == _family && _cache.length < 64) return;
    _clear();
    _lang = lang;
    _family = family;
  }

  TextPainter label(String text, double size) =>
      _cache['l|$size|$text'] ??= _layout(text, size, FontWeight.w700);

  TextPainter pole(String letter) =>
      _cache['p|$letter'] ??= _layout(letter, poleSize, FontWeight.w900);

  TextPainter _layout(String text, double size, FontWeight weight) =>
      TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: _Colors.white,
            fontSize: size,
            fontWeight: weight,
            letterSpacing: 0.3,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  void _clear() {
    for (final tp in _cache.values) {
      tp.dispose();
    }
    _cache.clear();
  }

  void dispose() => _clear();
}

/// Paints the HTML Three.js scenes: the workbench with the cardboard maze,
/// steel ball and bar magnet (S1) and the maglev racetrack with the two toy
/// cars (S2), plus the floating labels. Faces are flat-shaded with the HTML
/// lights and drawn far to near.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.texts,
    required this.lang,
    required this.showLabels,
    required this.uiScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final LabLang lang;
  final bool showLabels;

  /// Canvas text scale so labels stay readable on small screens.
  final double uiScale;

  static const List<_V> _normals = [
    _V(1, 0, 0),
    _V(-1, 0, 0),
    _V(0, 1, 0),
    _V(0, -1, 0),
    _V(0, 0, 1),
    _V(0, 0, -1),
  ];

  // Reused every frame.
  final Path _path = Path();
  final Paint _fill = Paint();
  final Paint _seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..strokeJoin = StrokeJoin.round;
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round;
  final Paint _grid = Paint()
    ..color = _Colors.grid
    ..strokeWidth = 1;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Label chips already drawn this frame.
  final List<Rect> _placed = [];

  late Canvas _canvas;
  late _Camera _cam;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _cam = scene.camera;
    texts.sync(lang);
    _paintBackground(size);
    if (scene.scenario == 0) {
      _paintMazeScene();
    } else {
      _paintRaceScene();
    }
    if (showLabels) _paintLabels();
  }

  // ------------------------------------------------------------- primitives

  /// Lambert shading of [c] for a face with world normal [n].
  Color _lit(Color c, _V n, {double opacity = 1, double metal = 0}) {
    final key = math.max(0.0, n.dot(_keyLight));
    final fill = math.max(0.0, n.dot(_fillLight)) * _fillStrength;
    final i = (_ambient + _keyStrength * key) * (1 - _metalDarkening * metal);
    const tint = _Colors.glow;
    return Color.from(
      alpha: (c.a * opacity).clamp(0.0, 1.0),
      red: (c.r * i + tint.r * fill).clamp(0.0, 1.0),
      green: (c.g * i + tint.g * fill).clamp(0.0, 1.0),
      blue: (c.b * i + tint.b * fill).clamp(0.0, 1.0),
    );
  }

  bool _faces(_V n, _V at) => n.dot(_cam.eye - at) > 0;

  /// Fills a projected polygon; opaque faces get a hairline of their own
  /// colour so neighbouring faces meet without seams.
  void _poly(List<_V> pts, Color color) {
    _path.reset();
    for (var i = 0; i < pts.length; i++) {
      final o = _cam.p(pts[i]);
      i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
    }
    _path.close();
    _fill.color = color;
    _canvas.drawPath(_path, _fill);
    if (color.a >= 1) {
      _seam.color = color;
      _canvas.drawPath(_path, _seam);
    }
  }

  /// Box (Three.js BoxGeometry) centred at [c], turned by [yaw] about the
  /// vertical axis: the faces turned towards the camera, lit. With [back]
  /// only the far faces, unlit (the HTML BackSide glow meshes).
  void _box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double metal = 0,
    double yaw = 0,
    bool back = false,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    final cy = math.cos(yaw), sy = math.sin(yaw);
    _V rot(_V v) =>
        yaw == 0 ? v : _V(v.x * cy + v.z * sy, v.y, -v.x * sy + v.z * cy);
    for (final n in _normals) {
      final _V a, b;
      if (n.x != 0) {
        a = _V(0, hy, 0);
        b = _V(0, 0, hz);
      } else if (n.y != 0) {
        a = _V(hx, 0, 0);
        b = _V(0, 0, hz);
      } else {
        a = _V(hx, 0, 0);
        b = _V(0, hy, 0);
      }
      final wn = rot(n);
      final fc = c + rot(_V(n.x * hx, n.y * hy, n.z * hz));
      if (_faces(wn, fc) == back) continue;
      final ra = rot(a), rb = rot(b);
      _poly(
        [fc + ra + rb, fc + ra - rb, fc - ra - rb, fc - ra + rb],
        back
            ? color.withValues(alpha: opacity)
            : _lit(color, wn, opacity: opacity, metal: metal),
      );
    }
  }

  /// Two unit vectors at right angles to [axis].
  (_V, _V) _basis(_V axis) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : _V.up;
    final a1 = axis.cross(helper).unit;
    return (a1, axis.cross(a1).unit);
  }

  /// Solid cylinder (CylinderGeometry) from [base] along unit [axis]:
  /// lit side strips facing the camera, then the visible end cap. Returns
  /// the centre of the visible cap (or null).
  _V? _cylinder(
    _V base,
    _V axis,
    double radius,
    double length,
    Color color, {
    int segments = 16,
    double metal = 0,
    double emissive = 0,
  }) {
    final (a1, a2) = _basis(axis);
    final top = base + axis * length;
    final ring = _circleOf(segments);
    _V dir(int i) => a1 * ring[i].$1 + a2 * ring[i].$2;
    final glowColor = emissive > 0 ? labShade(color, emissive) : color;
    for (var i = 0; i < segments; i++) {
      final d0 = dir(i), d1 = dir(i + 1);
      final n = (d0 + d1).unit;
      final mid = base + axis * (length / 2) + n * radius;
      if (!_faces(n, mid)) continue;
      _poly([
        base + d0 * radius,
        base + d1 * radius,
        top + d1 * radius,
        top + d0 * radius,
      ], _lit(glowColor, n, metal: metal));
    }
    final _V capCenter;
    final _V capNormal;
    if (_faces(axis, top)) {
      capCenter = top;
      capNormal = axis;
    } else if (_faces(axis * -1, base)) {
      capCenter = base;
      capNormal = axis * -1;
    } else {
      return null;
    }
    _poly([
      for (var i = 0; i < segments; i++) capCenter + dir(i) * radius,
    ], _lit(glowColor, capNormal, metal: metal));
    return capCenter;
  }

  /// Wireframe cylinder (MeshBasicMaterial `wireframe: true`): rings, side
  /// lines, the triangle diagonals and, with [caps], the end fans.
  void _wireCylinder(
    _V base,
    _V axis,
    double radius,
    double length,
    Color color, {
    int radial = 16,
    int rings = 1,
    bool caps = false,
  }) {
    final (a1, a2) = _basis(axis);
    final ring = _circleOf(radial);
    Offset at(int i, int j) => _cam.p(
      base +
          axis * (length * j / rings) +
          (a1 * ring[i].$1 + a2 * ring[i].$2) * radius,
    );
    _path.reset();
    for (var j = 0; j <= rings; j++) {
      for (var i = 0; i <= radial; i++) {
        final o = at(i, j);
        i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
      }
    }
    for (var i = 0; i < radial; i++) {
      for (var j = 0; j < rings; j++) {
        final a = at(i, j), b = at(i, j + 1), c = at(i + 1, j + 1);
        _path
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..moveTo(a.dx, a.dy)
          ..lineTo(c.dx, c.dy);
      }
    }
    if (caps) {
      for (final j in [0, rings]) {
        final c = _cam.p(base + axis * (length * j / rings));
        for (var i = 0; i < radial; i++) {
          final o = at(i, j);
          _path
            ..moveTo(c.dx, c.dy)
            ..lineTo(o.dx, o.dy);
        }
      }
    }
    _line
      ..color = color
      ..strokeWidth = 1;
    _canvas.drawPath(_path, _line);
  }

  /// Soft shadow of a [sx] × [sz] footprint centred at ([cx], [cz]) on the
  /// surface at [surfaceY], [height] below the object.
  void _dropShadow(
    double cx,
    double cz,
    double sx,
    double sz,
    double surfaceY,
    double height, {
    double opacity = 0.3,
  }) {
    final h = math.max(0.0, height);
    final x = cx - _shadowSlopeX * h, z = cz - _shadowSlopeZ * h;
    final y = surfaceY + 0.002;
    _path.reset();
    final corners = [
      _V(x - sx / 2, y, z - sz / 2),
      _V(x + sx / 2, y, z - sz / 2),
      _V(x + sx / 2, y, z + sz / 2),
      _V(x - sx / 2, y, z + sz / 2),
    ];
    for (var i = 0; i < 4; i++) {
      final o = _cam.p(corners[i]);
      i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
    }
    _path.close();
    _shadow.color = _Colors.shadow.withValues(alpha: opacity);
    _canvas.drawPath(_path, _shadow);
  }

  /// Pole letter sprite (HTML `makeTextSprite`): white bold glyph,
  /// [height] world units tall, always facing the camera.
  void _poleLetter(String key, _V at, double height) {
    final tp = texts.pole(labTr(_i18n, lang, key));
    final o = _cam.p(at);
    final k = height * _cam.scaleAt(at) / tp.height;
    _canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(k);
    tp.paint(_canvas, Offset(-tp.width / 2, -tp.height / 2));
    _canvas.restore();
  }

  // ------------------------------------------------------------- background

  void _paintBackground(Size size) {
    final bleed = labBleed(size);
    _fill.color = _Colors.canvas;
    _canvas.drawRect(bleed, _fill);
    for (
      var x = (bleed.left / _gridStep).floorToDouble() * _gridStep;
      x <= bleed.right;
      x += _gridStep
    ) {
      _canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), _grid);
    }
    for (
      var y = (bleed.top / _gridStep).floorToDouble() * _gridStep;
      y <= bleed.bottom;
      y += _gridStep
    ) {
      _canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), _grid);
    }
  }

  // -------------------------------------------------------------- scenario 1

  /// Top of the workbench (y 0) or of the side shelf (y 0.4) under [x].
  static double _surfaceS1(double x) => x < -8.5 ? 0.4 : 0.0;

  void _paintMazeScene() {
    final s = scene;
    final selected = s.selected;
    final magnetBelow = s.magnet.pos.y < -0.05;

    // Table legs (CylinderGeometry 0.3 × 6 at (±7.5, -3.3, ±4.5)).
    for (final z in const [-4.5, 4.5]) {
      for (final x in const [-7.5, 7.5]) {
        _cylinder(_V(x, -6.3, z), _V.up, 0.3, 6, _Colors.legs, segments: 12);
      }
    }
    // Under the table: the magnet and its field lines, seen through the
    // see-through table top.
    if (magnetBelow) _paintMagnet(glow: selected == s.magnet);
    if (s.fieldLines) {
      _wireCylinder(
        s.fieldPos - const _V(0, 0.6, 0),
        _V.up,
        0.4,
        1.2,
        _Colors.field.withValues(alpha: 0.6),
        rings: 8,
      );
    }
    _box(
      const _V(0, -0.3, 0),
      const _V(16, 0.6, 10),
      _Colors.wood,
      opacity: s.tableOpacity,
    );
    _box(const _V(-11.5, 0.2, 0), const _V(5, 0.4, 10), _Colors.mazeShelf);

    // Contact shadows (key light casts them towards -x / -z).
    final m = s.maze.pos;
    _dropShadow(m.x, m.z, 9.6, 6.4, _surfaceS1(m.x), m.y - 0.075);
    final b = s.ball.pos;
    final onMaze = _ballInMaze;
    _dropShadow(
      b.x,
      b.z,
      0.6,
      0.6,
      onMaze ? m.y + 0.075 : _surfaceS1(b.x),
      b.y - 0.35 - (onMaze ? m.y + 0.075 : _surfaceS1(b.x)),
      opacity: 0.4,
    );
    if (!magnetBelow) {
      final g = s.magnet.pos;
      _dropShadow(
        g.x,
        g.z,
        3.2,
        0.8,
        _surfaceS1(g.x),
        g.y - 0.3 - _surfaceS1(g.x),
      );
    }

    final mazeHeld = selected == s.maze;
    final ballHeld = selected == s.ball;
    final magnetHeld = selected == s.magnet && !magnetBelow;
    if (!mazeHeld) _paintMaze(withBall: onMaze && !ballHeld, glow: false);
    if (!onMaze && !ballHeld) _paintBall(glow: false);
    if (!magnetBelow && !magnetHeld) _paintMagnet(glow: false);
    // The object in the hand is drawn on top, with its glow mesh.
    if (mazeHeld) _paintMaze(withBall: false, glow: true);
    if (ballHeld) _paintBall(glow: true);
    if (magnetHeld) _paintMagnet(glow: true);
  }

  /// The ball rests inside the maze footprint (drawn among its walls).
  bool get _ballInMaze {
    final m = scene.maze.pos, b = scene.ball.pos;
    return (b.x - m.x).abs() < 4.8 && (b.z - m.z).abs() < 3.2 && b.y < 0.9;
  }

  /// Cardboard maze: base, Start / Finish discs and walls. The ball goes
  /// in front of the z-walls it is in front of (seen from the camera).
  void _paintMaze({required bool withBall, required bool glow}) {
    final s = scene;
    final m = s.maze.pos;
    if (glow) {
      _box(m, const _V(10, 0.6, 6.8), _Colors.glow, opacity: 0.35, back: true);
    }
    _box(m, const _V(9.6, 0.15, 6.4), _Colors.cardboard);
    _cylinder(
      m + const _V(-3.4, -0.01, -1.8),
      _V.up,
      0.6,
      0.18,
      _Colors.startRing,
      segments: 24,
    );
    _cylinder(
      m + const _V(3.4, -0.01, 1.8),
      _V.up,
      0.7,
      0.18,
      s.finishGreen ? _Colors.finishDone : _Colors.finishRing,
      segments: 24,
      emissive: s.finishGreen ? 0 : 0.15,
    );
    void wall(_V c, _V size) => _box(m + c, size, _Colors.mazeWall);
    const outer = _V(9.6, 0.4, 0.2);
    const side = _V(0.2, 0.4, 6.4);
    const inner = _V(0.2, 0.4, 3.8);
    wall(const _V(0, 0.2, -3.1), outer); // far wall
    // Walls along z, far from the camera's x first.
    final ex = _cam.eye.x;
    final zWalls =
        <(_V, _V)>[
          (const _V(-4.7, 0.2, 0), side),
          (const _V(4.7, 0.2, 0), side),
          (const _V(-1.5, 0.2, 1.2), inner),
          (const _V(1.5, 0.2, -1.2), inner),
        ]..sort(
          (a, b) =>
              (m.x + b.$1.x - ex).abs().compareTo((m.x + a.$1.x - ex).abs()),
        );
    var ballDrawn = !withBall;
    final bx = s.ball.pos.x;
    for (final (c, size) in zWalls) {
      final wx = m.x + c.x;
      if (!ballDrawn && (wx - bx) * (wx - ex) < 0) {
        _paintBall(glow: false);
        ballDrawn = true;
      }
      wall(c, size);
    }
    if (!ballDrawn) _paintBall(glow: false);
    wall(const _V(0, 0.2, 3.1), outer); // near wall
  }

  /// Steel ball (SphereGeometry r 0.35); held: indigo wireframe glow r 0.5.
  void _paintBall({required bool glow}) {
    final c = scene.ball.pos;
    final o = _cam.p(c);
    final r = 0.35 * _cam.scaleAt(c);
    _canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(r);
    _canvas.drawCircle(Offset.zero, 1, _steelPaint);
    _canvas.restore();
    if (glow) _wireSphere(c, 0.5, _Colors.glow);
  }

  /// Wireframe sphere (HTML ball glow: SphereGeometry(0.5, 16, 16),
  /// `wireframe: true`): latitude rings and meridians.
  void _wireSphere(_V c, double radius, Color color) {
    final ring = _circle16;
    _path.reset();
    for (var lat = -2; lat <= 2; lat++) {
      final phi = lat * math.pi / 6;
      final y = radius * math.sin(phi), rr = radius * math.cos(phi);
      for (var i = 0; i < ring.length; i++) {
        final o = _cam.p(c + _V(rr * ring[i].$1, y, rr * ring[i].$2));
        i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
      }
    }
    for (var m = 0; m < 8; m++) {
      final th = m * math.pi / 8;
      for (var i = 0; i < ring.length; i++) {
        final (cs, sn) = ring[i];
        final o = _cam.p(
          c +
              _V(
                radius * cs * math.cos(th),
                radius * sn,
                radius * cs * math.sin(th),
              ),
        );
        i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
      }
    }
    _line
      ..color = color
      ..strokeWidth = 1;
    _canvas.drawPath(_path, _line);
  }

  /// Bar magnet: N half (red, -x) and S half (blue, +x) with the HTML
  /// "N" / "S" sprites; held: indigo glow mesh.
  void _paintMagnet({required bool glow}) {
    final c = scene.magnet.pos;
    if (glow) {
      _box(c, const _V(3.4, 0.8, 1.0), _Colors.glow, opacity: 0.35, back: true);
    }
    final ex = _cam.eye.x;
    final halves = [
      (c + const _V(-0.8, 0, 0), _Colors.north),
      (c + const _V(0.8, 0, 0), _Colors.south),
    ]..sort((a, b) => (b.$1.x - ex).abs().compareTo((a.$1.x - ex).abs()));
    for (final (at, color) in halves) {
      _box(at, const _V(1.6, 0.6, 0.8), color, metal: 0.6);
    }
    _poleLetter('pole_n', c + const _V(-0.8, 0.45, 0), _poleHeight);
    _poleLetter('pole_s', c + const _V(0.8, 0.45, 0), _poleHeight);
  }

  // -------------------------------------------------------------- scenario 2

  /// Top of the racetrack (y 0) or of the side shelf (y 0.4) under [x].
  static double _surfaceS2(double x) => x < -11 ? 0.4 : 0.0;

  void _paintRaceScene() {
    final s = scene;
    _box(const _V(0, -0.2, 0), const _V(22, 0.4, 6), _Colors.track);
    // Centre line: 1 × 0.1 white dashes at x = -9, -7, … 9.
    for (var x = -9.0; x <= 9; x += 2) {
      _poly([
        _V(x - 0.5, 0.01, -0.05),
        _V(x + 0.5, 0.01, -0.05),
        _V(x + 0.5, 0.01, 0.05),
        _V(x - 0.5, 0.01, 0.05),
      ], _Colors.dash);
    }
    _box(const _V(0, 0.05, -3.15), const _V(22, 0.5, 0.3), _Colors.curb);
    _box(const _V(0, 0.05, 3.15), const _V(22, 0.5, 0.3), _Colors.curb);
    _box(const _V(-14, 0.2, 0), const _V(6, 0.4, 8), _Colors.raceShelf);

    for (final car in [s.blueCar, s.redCar]) {
      final surface = _surfaceS2(car.pos.x);
      _dropShadow(
        car.pos.x,
        car.pos.z,
        3.3,
        1.8,
        surface,
        car.pos.y - surface,
        opacity: 0.35,
      );
    }
    // Far car first; side by side, the one farther from the camera's x.
    final ex = _cam.eye.x;
    final cars = [s.blueCar, s.redCar]
      ..sort((a, b) {
        final da = _cam.depth(a.pos), db = _cam.depth(b.pos);
        if ((da - db).abs() > 0.01) return db.compareTo(da);
        return (b.pos.x - ex).abs().compareTo((a.pos.x - ex).abs());
      });
    for (final car in cars) {
      _paintCar(car, glow: s.selected == car);
    }
    if (s.waves) _paintWaves(s.wavesPos);
    if (s.beams) {
      // CylinderGeometry(0.6, 0.6, 3, 16) turned along x, wireframe.
      _wireCylinder(
        s.beamsPos - const _V(1.5, 0, 0),
        const _V(1, 0, 0),
        0.6,
        3,
        _Colors.field.withValues(alpha: 0.8),
        caps: true,
      );
    }
  }

  /// Toy car (HTML `createToyCarMesh`): chassis, cabin, four wheels and
  /// the bar magnet on the roof.
  void _paintCar(_Body car, {required bool glow}) {
    final s = scene;
    final isRed = car.id == _Obj.redCar;
    final c = car.pos;
    if (glow) {
      _box(
        c + const _V(0, 0.8, 0),
        const _V(3.6, 1.8, 2.0),
        _Colors.glow,
        opacity: 0.35,
        back: true,
      );
    }
    final roll = isRed ? s.redRoll : s.blueRoll;
    for (final x in const [-1.0, 1.0]) {
      _wheel(c + _V(x, 0.35, -0.85), roll);
    }
    _box(
      c + const _V(0, 0.4, 0),
      const _V(3.2, 0.6, 1.6),
      isRed ? _Colors.redCar : _Colors.blueCar,
      metal: 0.8,
    );
    _box(
      c + const _V(-0.2, 0.85, 0),
      const _V(1.8, 0.5, 1.4),
      _Colors.cabin,
      metal: 0.9,
    );
    for (final x in const [-1.0, 1.0]) {
      _wheel(c + _V(x, 0.35, 0.85), roll);
    }
    // Roof magnet. Red car: N at its front (+x), facing the blue car; blue
    // car: N at its back (-x), facing the red car (like poles repel). The
    // red car's magnet turns about y when flipped.
    _carMagnet(
      c + const _V(0, 1.3, 0),
      yaw: isRed ? s.redMagnetYaw : 0,
      northAtFront: isRed,
    );
  }

  /// Wheel (CylinderGeometry r 0.35 × 0.3 along z) with a hub mark that
  /// rolls with the car.
  void _wheel(_V center, double roll) {
    const axis = _V(0, 0, 1);
    final cap = _cylinder(
      center - const _V(0, 0, 0.15),
      axis,
      0.35,
      0.3,
      _Colors.wheel,
      segments: 12,
    );
    if (cap == null) return;
    final rim = cap + _V(math.cos(roll), math.sin(roll), 0) * 0.26;
    _line
      ..color = _Colors.hub
      ..strokeWidth = math.max(1.0, 0.07 * _cam.scaleAt(cap));
    _canvas.drawLine(_cam.p(cap), _cam.p(rim), _line);
    _fill.color = _Colors.hub;
    _canvas.drawCircle(_cam.p(cap), 0.08 * _cam.scaleAt(cap), _fill);
  }

  void _carMagnet(
    _V center, {
    required double yaw,
    required bool northAtFront,
  }) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    _V half(double lx) => center + _V(lx * cy, 0, -lx * sy);
    final ex = _cam.eye.x;
    final parts = [(half(0.6), northAtFront), (half(-0.6), !northAtFront)]
      ..sort((a, b) {
        final da = _cam.depth(a.$1), db = _cam.depth(b.$1);
        if ((da - db).abs() > 0.01) return db.compareTo(da);
        return (b.$1.x - ex).abs().compareTo((a.$1.x - ex).abs());
      });
    for (final (at, north) in parts) {
      _box(
        at,
        const _V(1.2, 0.4, 0.6),
        north ? _Colors.north : _Colors.south,
        metal: 0.5,
        yaw: yaw,
      );
    }
    for (final (at, north) in parts) {
      _poleLetter(
        north ? 'pole_n' : 'pole_s',
        at + const _V(0, 0.36, 0),
        _carPoleHeight,
      );
    }
  }

  /// Repulsion waves: RingGeometry(0.8, 2.5, 32) turned to face ±x.
  void _paintWaves(_V c) {
    final ring = _circle32;
    _path.reset();
    for (final r in const [2.5, 0.8]) {
      for (var i = 0; i < ring.length; i++) {
        final o = _cam.p(c + _V(0, r * ring[i].$2, -r * ring[i].$1));
        i == 0 ? _path.moveTo(o.dx, o.dy) : _path.lineTo(o.dx, o.dy);
      }
      _path.close();
    }
    _path.fillType = PathFillType.evenOdd;
    _fill.color = _Colors.wave.withValues(alpha: 0.7);
    _canvas.drawPath(_path, _fill);
    _path.fillType = PathFillType.nonZero;
  }

  // ------------------------------------------------------------------ labels

  /// HTML `.html-label` chip at the projected point. The HTML centres it
  /// there; on a phone-sized stage a centred chip would hide the object
  /// (e.g. the cars' roof magnets), so object labels sit just [above] the
  /// point. A chip that would overlap one already drawn moves clear of it
  /// (up, or down when its point is lower on screen).
  void _label(String key, _V at, {bool above = true}) {
    final tp = texts.label(labTr(_i18n, lang, key), _labelFont * uiScale);
    final o = _cam.p(at);
    final padH = 8 * uiScale, padV = 3 * uiScale;
    final w = tp.width + 2 * padH, h = tp.height + 2 * padV;
    var rect = above
        ? Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h)
        : Rect.fromCenter(center: o, width: w, height: h);
    final gap = 2 * uiScale;
    // The first chip it hits decides the way (up, or down when this point
    // is lower on screen); it then keeps going that way until it is clear.
    bool? down;
    for (var pass = 0; pass < _placed.length + 1; pass++) {
      var moved = false;
      for (final r in _placed) {
        if (!rect.overlaps(r)) continue;
        down ??= rect.center.dy > r.center.dy + 1;
        rect = rect.shift(
          Offset(
            0,
            down ? r.bottom + gap - rect.top : r.top - gap - rect.bottom,
          ),
        );
        moved = true;
      }
      if (!moved) break;
    }
    _placed.add(rect);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(4 * uiScale));
    _fill.color = _Colors.labelBg;
    _canvas.drawRRect(rr, _fill);
    _line
      ..color = _Colors.labelBorder
      ..strokeWidth = 1;
    _canvas.drawRRect(rr, _line);
    tp.paint(_canvas, Offset(rect.left + padH, rect.top + padV));
  }

  /// Label positions = object + HTML `labelOffset` (creation order, so the
  /// later chips sit on top as in the HTML).
  void _paintLabels() {
    final s = scene;
    _placed.clear();
    if (s.scenario == 0) {
      final m = s.maze.pos;
      _label('lbl_workbench', const _V(-6.5, -0.4, 4.5), above: false);
      // Start sits just below its circle and the magnet's label goes once
      // the magnet is under the workbench: above the circle they stacked up
      // on the steel ball waiting there.
      _label('lbl_start', m + const _V(-3.4, 0.2, -0.95), above: false);
      _label('lbl_finish', m + const _V(3.4, 0.58, 1.8));
      _label('lbl_maze', m + const _V(0, 0.8, -3.5));
      _label('lbl_ball', s.ball.pos + const _V(0, 0.6, 0));
      if (s.step < 4) {
        _label('lbl_magnet', s.magnet.pos + const _V(0, 0.7, 0));
      }
    } else {
      _label('lbl_racetrack', const _V(-8, -0.3, 3.2), above: false);
      _label('lbl_blue_car', s.blueCar.pos + const _V(0, 1.8, 0));
      _label('lbl_red_car', s.redCar.pos + const _V(0, 1.8, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.texts != texts ||
      old.lang != lang ||
      old.showLabels != showLabels ||
      old.uiScale != uiScale;
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
