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

/// Class 6 Science • Chapter 1 • Activity 5
/// Exploring the Diverse Fields of Science (Observing Our World).
///
/// Native Flutter port of
/// `Cl6S-Ch1-A5-Exploring_the_Diverse_Fields_of_Science.html` (Three.js
/// r128). The Three.js scenes are redrawn by a small painter ([_Gfx]) that
/// reproduces the HTML camera: position (0, 8, 18), look-at (0, 0, 0), 45°
/// field of view.
///
/// Scenario 1 (Biology: The Life of a Butterfly): a caterpillar sits on a
/// large leaf beside a twig. A leaf dragged from the Food panel onto it is
/// eaten (the caterpillar wiggles and grows); after three leaves the twig
/// glows and the caterpillar, dragged onto the twig, turns into a green
/// chrysalis with golden spots. The time-lapse slider makes the chrysalis
/// wiggle until it cracks open and an orange butterfly pops out; tapped, the
/// butterfly flies away and 'Observe Conclusion' opens the Biology summary.
///
/// Scenario 2 (Physics: The States of Water): a beaker of water stands on a
/// hotplate beside a thermometer. The temperature slider (-20 to 120 °C)
/// drives the thermometer and the hotplate coil; at 0 °C and below ice cubes
/// form, above it they melt, at 100 °C the water boils (bubbles, steam, the
/// level drops) and back at room temperature it stops. 'Observe
/// Conclusion' then shows the summary and 'Mastery Achieved!'.
class Ch1A5ExploringDiverseFieldsPage extends StatefulWidget {
  const Ch1A5ExploringDiverseFieldsPage({super.key});

  @override
  State<Ch1A5ExploringDiverseFieldsPage> createState() => _FieldsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises its tones with Web Audio; they map to the closest files:
/// 'pop' / 'click' (buttons, the caterpillar turning into a chrysalis, the
/// ice melting) → click (`science/click.mp3`), 'eat' (a leaf eaten) → eat
/// (`science/click.mp3`), 'crack' (the chrysalis cracks open) and 'ice'
/// (the water freezes) → `science/dropdown.mp3`, 'hiss' (the water starts
/// to boil) → `science/page_open.mp3`, 'chime' / 'success' (the butterfly
/// takes off, 'Observe Conclusion' appears, the summary, the next-scenario
/// note) → success (`math/success.mp3`). A missed drop plays wrong
/// (`science/error.mp3`, added). The shell plays toggle
/// (`science/dropdown.mp3`), scenario (`science/page_open.mp3`) and
/// curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// Generic button click; HTML `pop` / `click`.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// A right answer (shell toasts).
  correct('audio/class6/math/success.mp3'),

  /// A leaf or the caterpillar dropped off target (added).
  wrong('audio/class6/science/error.mp3'),

  /// The butterfly takes off, 'Observe Conclusion' appears, the summary and
  /// the next-scenario note (HTML `success`, `chime`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// The caterpillar turns into a chrysalis, the ice melts, a popup closes
  /// (HTML `pop`).
  pop('audio/class6/science/click.mp3'),

  /// A leaf eaten (HTML `eat`).
  eat('audio/class6/science/click.mp3'),

  /// The chrysalis cracks open (HTML `crack`).
  crack('audio/class6/science/dropdown.mp3'),

  /// The water freezes into ice (HTML `ice`).
  freeze('audio/class6/science/dropdown.mp3'),

  /// The water starts to boil (HTML `hiss`, a noise burst).
  hiss('audio/class6/science/page_open.mp3');

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

/// Colours of the HTML page (Tailwind classes), of its Three.js scenes
/// (material colours) and of its canvas textures and SVG icons.
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color amber400 = Color(0xFFFBBF24);
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
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ------------------------------------------------- scenario 1: garden
  /// `scene.background` of Scenario 1 (0xe0f2fe, both themes).
  static const Color sky = Color(0xFFE0F2FE);

  /// Ground `PlaneGeometry(40, 30)` (0x4d7c0f).
  static const Color ground = Color(0xFF4D7C0F);

  /// `getLeafTexture()`: gradient #84cc16 → #4d7c0f, veins and edge
  /// #3f6212.
  static const Color leafLight = Color(0xFF84CC16);
  static const Color leafDark = Color(0xFF4D7C0F);
  static const Color leafVein = Color(0xFF3F6212);

  /// Twig `0x5c3a21` and its glowing aura `0xfef08a`.
  static const Color twig = Color(0xFF5C3A21);
  static const Color aura = Color(0xFFFEF08A);

  /// Caterpillar segments (`catColors`): green, dark, yellow, dark; legs,
  /// eyes and antennae.
  static const Color catGreen = Color(0xFF84CC16);
  static const Color catDark = slate800;
  static const Color catYellow = yellow400;
  static const Color eye = black;

  /// Chrysalis `0x84cc16`, golden spots `0xfbbf24`, stalk `0x334155`.
  static const Color chrysalis = Color(0xFF84CC16);
  static const Color gold = amber400;
  static const Color stalk = slate700;

  /// `getButterflyWingTexture()`: gradient #f97316 → #ea580c, veins and
  /// border #1e293b, white dots; body `0x1e293b`.
  static const Color wingLight = Color(0xFFF97316);
  static const Color wingDark = Color(0xFFEA580C);
  static const Color wingInk = slate800;
  static const Color body = slate800;

  // ---------------------------------------------------- scenario 2: lab
  /// `scene.background` of Scenario 2 (0xf1f5f9, both themes).
  static const Color labSky = slate100;

  /// Bench `0x475569`, hotplate base `0x1e293b`, plate `0x0f172a`, coil
  /// `0xff3300`, knob `0xef4444`.
  static const Color bench = slate600;
  static const Color hotplate = slate800;
  static const Color plate = slate900;
  static const Color coil = Color(0xFFFF3300);
  static const Color knob = red500;

  /// Beaker glass, its marks, water `0x38bdf8`, ice `0xe0f2fe`, bubbles
  /// and steam (white).
  static const Color glass = Color(0xFFE2E8F0);
  static const Color glassEdge = Color(0xFF94A3B8);
  static const Color water = Color(0xFF38BDF8);
  static const Color ice = Color(0xFFE0F2FE);
  static const Color iceEdge = Color(0xFFBAE6FD);
  static const Color mark = black;

  /// Thermometer liquid and bulb `0xef4444`.
  static const Color mercury = red500;

  // ---------------------------------------------------------- overlays
  /// Text sprites: `#1e293b` chip, `#6366f1` border, white text.
  static const Color chipBg = slate800;
  static const Color chipBorder = indigo500;
  static const Color chipText = white;

  /// `.dropzone-area`: rgba(99, 102, 241, 0.5) dashes; highlighted, a solid
  /// border and an rgba(99, 102, 241, 0.15) fill.
  static const Color zoneDash = Color(0x806366F1);
  static const Color zoneFill = Color(0x266366F1);

  /// `#drag-overlay` (`bg-black/10`).
  static const Color dragDim = Color(0x1A000000);

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
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border
    card: Color(0xCC1E293B),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900, // #canvas-wrapper dark:bg-[#0f172a]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // text-indigo-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100, // #canvas-wrapper bg-[#f1f5f9]
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo500,
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
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.chipText,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar font-size setting: 15 px, slider 12–22 px.
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// `sN_title` / `sN_obj` are the scenario titles and objectives, `sN_hud_M`
// the HTML "Current Task" lines, `sN_concept_M` / `sN_action_M` / `sN_obs_M`
// the steps' concept, action and observation. Each HTML summary is split
// into its bold first line (`sN_sum_head`) and the text (`sN_summary`);
// `sN_scientists` is the word the HTML set in bold. "CLICK" reads "TAP".
// Keys marked "Added." are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title':
        'Exploring the Diverse Fields of Science (Observing Our World)',
    'app_subtitle': 'Class 6. The Wonderful World of Science',
    's1_title': 'Biology: The Life of a Butterfly',
    's2_title': 'Physics: The States of Water',
    's1_obj':
        'To observe and facilitate the life cycle of a butterfly, understanding how biologists study living organisms and their transformations.',
    's2_obj':
        'To manipulate the temperature of water and observe its transformation between solid, liquid, and gas, understanding how physicists study matter and energy.',
    's1_hud_1':
        'Step 1: DRAG and DROP a smaller leaf from the side panel onto the caterpillar.',
    's1_hud_2': 'Step 2: DRAG and DROP two more leaves onto the caterpillar.',
    's1_hud_3':
        'Step 3: DRAG the caterpillar in 3D and DROP it onto the glowing twig.',
    's1_hud_4':
        'Step 4: TAP and DRAG the time-lapse slider from left to right.',
    's1_hud_5': 'Step 5: TAP on the fully formed butterfly to let it fly.',
    's2_hud_1': 'Step 1: DRAG the temperature slider to the far left (0°C).',
    's2_hud_2': 'Step 2: DRAG the slider handle to the right, above 0°C.',
    's2_hud_3':
        'Step 3: Continue to DRAG the slider handle all the way to the right (100°C).',
    's2_hud_4':
        'Step 4: DRAG the slider back to the middle position (room temperature).',
    's1_concept_1': 'Feeding & Growth',
    's1_action_1': 'Drag and drop the leaf onto the caterpillar.',
    's1_obs_1': 'The caterpillar eats the leaf and grows slightly larger.',
    's1_concept_2': 'Maturation',
    's1_action_2': 'Feed it two more times.',
    's1_obs_2':
        'It grows significantly and glows, indicating readiness to pupate.',
    's1_concept_3': 'Pupation',
    's1_action_3': 'Drag caterpillar to the twig.',
    's1_obs_3': 'It attaches to the twig and transforms into a chrysalis.',
    's1_concept_4': 'Metamorphosis',
    's1_action_4': 'Drag the time-lapse slider.',
    's1_obs_4': 'The chrysalis wiggles, cracks open, and a butterfly emerges.',
    's1_concept_5': 'Observation Complete',
    's1_action_5': 'Tap on the butterfly.',
    's1_obs_5': 'You have observed a biological life cycle.',
    's2_concept_1': 'Freezing (Liquid to Solid)',
    's2_action_1': 'Drag slider left to 0°C.',
    's2_obs_1': 'Temperature drops, water freezes into a solid block of ice.',
    's2_concept_2': 'Melting (Solid to Liquid)',
    's2_action_2': 'Drag slider right above 0°C.',
    's2_obs_2': 'Ice melts back into liquid water as heat is added.',
    's2_concept_3': 'Boiling & Evaporation (Liquid to Gas)',
    's2_action_3': 'Drag slider far right to 100°C.',
    's2_obs_3':
        'Water boils, bubbles form, steam rises, and water level decreases.',
    's2_concept_4': 'Condensation & Cooling',
    's2_action_4': 'Drag slider to middle.',
    's2_obs_4': 'Boiling stops, water returns to normal liquid state.',
    's1_sum_head': 'Life Cycle Observed!',
    's1_summary':
        'You have observed the complete life cycle of a butterfly. This is exactly what Biologists do—they study the structure, growth, origin, evolution, and distribution of living organisms!',
    's1_scientists': 'Biologists',
    's2_sum_head': 'State Change Observed!',
    's2_summary':
        'You successfully changed the state of water by manipulating temperature. This is what Physicists do—they study matter, energy, and how they interact to cause physical changes in the universe!',
    's2_scientists': 'Physicists',
    // Teacher board and popups.
    'steps_title': 'Observation Step',
    'step_word': 'Step',
    'task_lbl': 'Task',
    'action_lbl': 'Action',
    'result_lbl': 'Result',
    'sc_complete': '{n} Complete!',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You successfully explored Biology and Physics! You observed how living things grow and change, and how matter changes state with temperature.',
    'restart_lab': 'Restart Entire Lab',
    'select_next_sc_msg':
        'Biology module completed. Please select Physics from the sidebar!',
    // Canvas panels and scene labels.
    'food_supply': 'Food',
    'drop_leaf': 'Drop Leaf Here',
    'time_lapse': 'Time-Lapse',
    'cooling': 'Cooling',
    'heating': 'Heating',
    'btn_conclude': 'Observe Conclusion',
    'lbl_caterpillar': 'Caterpillar',
    'lbl_twig': 'Twig',
    'lbl_beaker': 'Water Beaker',
    'lbl_thermometer': 'Thermometer',
    // Added.
    's1_hud_done': "TAP 'Observe Conclusion' to see what you observed.",
    // Added.
    's2_hud_done': "TAP 'Observe Conclusion' to see what you observed.",
    // Added.
    'lbl_leaf': 'Leaf',
    // Added.
    'lbl_butterfly': 'Butterfly',
    // Added.
    'lbl_temperature': 'Temperature',
    // Added.
    'temp_value': '{t} °C',
    // Added.
    'miss_leaf': 'Missed! Drop the leaf right onto the caterpillar.',
    // Added.
    'miss_twig':
        'Not close enough! Drop the caterpillar onto the glowing twig.',
    // Added.
    'scene_s1':
        'A caterpillar on a large leaf beside a twig. It grows, becomes a chrysalis on the twig and then a butterfly.',
    // Added.
    'scene_s2':
        'A beaker of water on a hotplate and a thermometer on a lab bench.',
  },
  'hi': {
    'app_title': 'विज्ञान के विविध क्षेत्रों की खोज',
    'app_subtitle': 'कक्षा 6. हमारी दुनिया का अवलोकन',
    's1_title': 'जीव विज्ञान: तितली का जीवन',
    's2_title': 'भौतिकी: पानी की अवस्थाएं',
    's1_obj':
        'एक तितली के जीवन चक्र का निरीक्षण करना और उसे सुविधाजनक बनाना, यह समझना कि जीवविज्ञानी जीवित जीवों और उनके परिवर्तनों का अध्ययन कैसे करते हैं।',
    's2_obj':
        'पानी के तापमान में हेरफेर करना और ठोस, तरल और गैस के बीच इसके परिवर्तन का निरीक्षण करना, यह समझना कि भौतिक विज्ञानी पदार्थ और ऊर्जा का अध्ययन कैसे करते हैं।',
    's1_hud_1': 'चरण 1: साइड पैनल से इल्ली पर एक छोटी पत्ती खींचें और छोड़ें।',
    's1_hud_2': 'चरण 2: इल्ली पर दो और पत्तियां खींचें और छोड़ें।',
    's1_hud_3': 'चरण 3: इल्ली को 3D में खींचें और चमकती टहनी पर छोड़ें।',
    's1_hud_4': 'चरण 4: टाइम-लैप्स स्लाइडर को बाएं से दाएं खींचें।',
    's1_hud_5': 'चरण 5: उड़ने देने के लिए पूरी तरह से बनी तितली पर टैप करें।',
    's2_hud_1': 'चरण 1: तापमान स्लाइडर को सबसे बाईं ओर (0°C) खींचें।',
    's2_hud_2': 'चरण 2: स्लाइडर हैंडल को दाईं ओर, 0°C से ऊपर खींचें।',
    's2_hud_3': 'चरण 3: स्लाइडर हैंडल को दाईं ओर (100°C) खींचते रहें।',
    's2_hud_4':
        'चरण 4: स्लाइडर को वापस मध्य स्थिति (कमरे के तापमान) पर खींचें।',
    's1_concept_1': 'खिलाना और विकास',
    's1_action_1': 'पत्ती को इल्ली पर खींचें और छोड़ें।',
    's1_obs_1': 'इल्ली पत्ती खाती है और थोड़ी बड़ी हो जाती है।',
    's1_concept_2': 'परिपक्वता',
    's1_action_2': 'इसे दो बार और खिलाएं।',
    's1_obs_2':
        'यह काफी बढ़ता है और चमकता है, जो प्यूपा बनने की तैयारी का संकेत देता है।',
    's1_concept_3': 'प्यूपा बनना',
    's1_action_3': 'इल्ली को टहनी पर खींचें।',
    's1_obs_3': 'यह टहनी से जुड़ जाता है और क्रिसालिस में बदल जाता है।',
    's1_concept_4': 'कायांतरण',
    's1_action_4': 'टाइम-लैप्स स्लाइडर खींचें।',
    's1_obs_4': 'क्रिसालिस हिलता है, दरारें खुलती हैं, और एक तितली निकलती है।',
    's1_concept_5': 'अवलोकन पूर्ण',
    's1_action_5': 'तितली पर टैप करें।',
    's1_obs_5': 'आपने एक जैविक जीवन चक्र देखा है।',
    's2_concept_1': 'जमना (तरल से ठोस)',
    's2_action_1': 'स्लाइडर को 0°C पर बाईं ओर खींचें।',
    's2_obs_1': 'तापमान गिरता है, पानी बर्फ के एक ठोस ब्लॉक में जम जाता है।',
    's2_concept_2': 'पिघलना (ठोस से तरल)',
    's2_action_2': 'स्लाइडर को दाईं ओर 0°C से ऊपर खींचें।',
    's2_obs_2': 'गर्मी बढ़ने पर बर्फ वापस तरल पानी में पिघल जाती है।',
    's2_concept_3': 'उबलना और वाष्पीकरण (तरल से गैस)',
    's2_action_3': 'स्लाइडर को सबसे दाईं ओर 100°C पर खींचें।',
    's2_obs_3':
        'पानी उबलता है, बुलबुले बनते हैं, भाप उठती है, और पानी का स्तर कम हो जाता है।',
    's2_concept_4': 'संक्षेपण और शीतलन',
    's2_action_4': 'स्लाइडर को बीच में खींचें।',
    's2_obs_4': 'उबलना बंद हो जाता है, पानी सामान्य तरल अवस्था में लौट आता है।',
    's1_sum_head': 'जीवन चक्र देखा गया!',
    's1_summary':
        'आपने एक तितली का पूरा जीवन चक्र देखा है। ठीक यही जीवविज्ञानी करते हैं—वे जीवित जीवों की संरचना, विकास, उत्पत्ति, विकास और वितरण का अध्ययन करते हैं!',
    's1_scientists': 'जीवविज्ञानी',
    's2_sum_head': 'अवस्था परिवर्तन देखा गया!',
    's2_summary':
        'आपने तापमान में हेरफेर करके पानी की स्थिति को सफलतापूर्वक बदल दिया। यही भौतिक विज्ञानी करते हैं—वे पदार्थ, ऊर्जा और ब्रह्मांड में भौतिक परिवर्तन का कारण बनने के लिए वे कैसे बातचीत करते हैं, इसका अध्ययन करते हैं!',
    's2_scientists': 'भौतिक विज्ञानी',
    'steps_title': 'अवलोकन चरण',
    'step_word': 'चरण',
    'task_lbl': 'कार्य',
    'action_lbl': 'क्रिया',
    'result_lbl': 'परिणाम',
    'sc_complete': '{n} पूर्ण!',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने जीव विज्ञान और भौतिकी का सफलतापूर्वक पता लगाया! आपने देखा कि जीवित चीजें कैसे बढ़ती और बदलती हैं, और तापमान के साथ पदार्थ कैसे अवस्था बदलता है।',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'select_next_sc_msg':
        'जीव विज्ञान मॉड्यूल पूरा हुआ। कृपया साइडबार से भौतिकी चुनें!',
    'food_supply': 'भोजन',
    'drop_leaf': 'पत्ती यहाँ छोड़ें',
    'time_lapse': 'समय व्यतीत',
    'cooling': 'ठंडा करना',
    'heating': 'गर्म करना',
    'btn_conclude': 'निष्कर्ष देखें',
    'lbl_caterpillar': 'इल्ली',
    'lbl_twig': 'टहनी',
    'lbl_beaker': 'पानी का बीकर',
    'lbl_thermometer': 'थर्मामीटर',
    // Added.
    's1_hud_done':
        "आपने क्या देखा, यह जानने के लिए 'निष्कर्ष देखें' पर टैप करें।",
    's2_hud_done':
        "आपने क्या देखा, यह जानने के लिए 'निष्कर्ष देखें' पर टैप करें।",
    'lbl_leaf': 'पत्ती',
    'lbl_butterfly': 'तितली',
    'lbl_temperature': 'तापमान',
    'temp_value': '{t} °C',
    'miss_leaf': 'निशाना चूक गया! पत्ती को सीधे इल्ली पर छोड़ें।',
    'miss_twig': 'पर्याप्त पास नहीं! इल्ली को चमकती टहनी पर छोड़ें।',
    'scene_s1':
        'एक बड़ी पत्ती पर टहनी के पास एक इल्ली। यह बढ़ती है, टहनी पर क्रिसालिस बनती है और फिर तितली बन जाती है।',
    'scene_s2':
        'प्रयोगशाला की बेंच पर हॉटप्लेट पर रखा पानी का बीकर और एक थर्मामीटर।',
  },
};

/// Number of steps of each scenario (the HTML `steps` arrays).
const List<int> _stepCounts = [5, 4];

/// One step's texts for the sidebar accordion (HTML teacher-board card).
@immutable
class _StepInfo {
  const _StepInfo({
    required this.task,
    required this.action,
    required this.result,
  });

  final String task;
  final String action;
  final String result;
}

/// The steps of scenario [index] (0 or 1) in [lang].
List<_StepInfo> _stepInfos(LabLang lang, int index) {
  String t(String key) => labTr(_i18n, lang, key);
  final n = index + 1;
  return [
    for (var i = 1; i <= _stepCounts[index]; i++)
      _StepInfo(
        task: t('s${n}_concept_$i'),
        action: t('s${n}_action_$i'),
        result: t('s${n}_obs_$i'),
      ),
  ];
}

/// The two scenarios for [lang], built from the string table (HTML
/// `ScenariosData`).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('s${n}_title'),
        objective: t('s${n}_obj'),
        steps: [
          for (final s in _stepInfos(lang, n - 1))
            LabStep(concept: s.task, action: s.action, observation: s.result),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// HTML camera (`resetCamera()`): `PerspectiveCamera(45, …)` at (0, 8, 18)
/// looking at `controls.target` (0, 0, 0).
const double _fovDegrees = 45;
const _V _eye = _V(0, 8, 18);
const _V _lookAt = _V(0, 0, 0);
const double _near = 0.1;

/// Pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking up the caterpillar (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so they
/// stay readable on phones.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Chip padding as a share of the label size.
const double _chipPadX = 0.55;
const double _chipPadY = 0.3;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make an animation jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; x UI scale) and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// Largest zoom of the fitted scene in each scenario (the HTML camera is
/// zoom 1); it is never drawn smaller than [_minZoom].
const List<double> _maxZoom = [1.2, 1.45];
const double _minZoom = 0.3;

/// HTML `setTimeout(() => progressStepToLogic(1), 1000)`: a scenario's
/// panels appear one second after it loads.
const Duration _panelDelay = Duration(seconds: 1);

/// HTML lights: `AmbientLight(0xffffff, 0.8)` and `DirectionalLight(…,
/// 0.6)` at (5, 10, 5), normalised.
const double _ambient = 0.8;
const double _diffuse = 0.6;
const _V _light = _V(0.4082, 0.8165, 0.4082);

// ------------------------------------------------ scenario 1: the garden

/// Ground `PlaneGeometry(40, 30)` at y = -3.
const double _groundY = -3;
const double _groundHalfX = 20;
const double _groundHalfZ = 15;

/// Large leaf `PlaneGeometry(16, 16)` lying flat at (-4, -1.5, 0), its
/// sides drooping by `(x / 8)² · 1.5`; the 512 px leaf texture spans it
/// (32 px per unit).
const _V _leafCenter = _V(-4, -1.5, 0);
const double _leafHalf = 8;
const double _leafDroop = 1.5;
const double _texSize = 512;

/// Twig group at (5, 2, -2), `rotation.z = -π/4`; its label at (2, 4, 0).
const _V _twigPos = _V(5, 2, -2);
const double _twigTilt = -math.pi / 4;
const _V _twigLabelLocal = _V(2, 4, 0);

/// Caterpillar group at (-5, -0.5, 0): ten segments 0.35 apart from
/// x = -1.5 (the head), radius `0.4 - |i - 4| · 0.03`; label at (0, 2.5, 0);
/// hit box `BoxGeometry(6, 3, 3)`.
const _V _catHome = _V(-5, -0.5, 0);
const int _catSegments = 10;
const double _segGap = 0.35;
const double _segStart = -1.5;
const _V _catLabelLocal = _V(0, 2.5, 0);
const _V _catHitHalf = _V(3, 1.5, 1.5);

/// The caterpillar's body as drawn (local units), and its middle.
const _V _catBodyMin = _V(-1.9, -0.55, -0.45);
const _V _catBodyMax = _V(2.05, 0.45, 0.45);
const _V _catMiddle = _V(0.075, 0, 0);

/// Growth per leaf (`scale + 0.15`, 500 ms, `Back.Out`), the wiggle
/// (`y + 0.2`, 100 ms, yoyo, repeat 3, delay i · 50 ms) and the leaves it
/// eats before it pupates.
const double _growStep = 0.15;
const double _growSeconds = 0.5;
const double _wiggleRise = 0.2;
const double _wiggleLeg = 0.1;
const int _wiggleLegs = 4;
const double _wiggleDelay = 0.05;
const int _feedsToPupate = 3;

/// The leaf card (56 px; it counts once it overlaps the drop zone) and the
/// drop zone (`w-[300px] h-[300px]`, here centred on the caterpillar).
const double _leafCardDp = 56;
const double _dropZoneSide = 300;

/// Twig aura: opacity 0 → 0.6, 1000 ms, yoyo, forever.
const double _auraSeconds = 1;
const double _auraMax = 0.6;

/// HTML `end3DDrag`: on the twig if `distanceTo(twig) < 6`; the caterpillar
/// glides to (twig.x - 0.5, twig.y, twig.z) in 300 ms, or back home in
/// 400 ms.
const double _snapRange = 6;
const double _snapSeconds = 0.3;
const double _returnSeconds = 0.4;
const _V _snapTo = _V(4.5, 2, -2);

/// HTML `#drag-icon-container`: a 64 px badge 32 px above the finger.
const double _handDp = 64;

/// Chrysalis group at (4, 1.5, -2), `rotation.z = π/12`; body
/// `SphereGeometry(0.6)` scaled (1, 2, 1); six gold spots at y 0.5; stalk
/// `CylinderGeometry(0.05, 0.2, 0.6)` at y 1.4. It pops in from 0.1
/// (1000 ms, `Elastic.Out`); the time-lapse tilts it `π/8 + sin(v) · 0.1`.
const _V _chrysPos = _V(4, 1.5, -2);
const double _chrysRestTilt = math.pi / 12;
const double _chrysLapseTilt = math.pi / 8;
const double _chrysWiggle = 0.1;
const double _chrysR = 0.6;
const double _chrysStretch = 2;
const double _spotR = 0.08;
const double _popFrom = 0.1;
const double _popSeconds = 1;

/// Time-lapse slider (0–100 %): the butterfly emerges at 95 %.
const double _lapseMax = 100;
const double _emergeAt = 95;

/// Butterfly at the chrysalis + (0, 1, 0), popping to scale 1.5 (1000 ms,
/// `Elastic.Out`); its wings (`PlaneGeometry(4, 4)` on hinges 0.2 off the
/// body) flap `±sin(Date.now() · 0.01) · 0.5`; hit sphere radius 3.
const _V _flyHome = _V(4, 2.5, -2);
const double _flyScale = 1.5;
const double _flapRate = 10;
const double _flapAmp = 0.5;
const double _hingeX = 0.2;
const double _flyHitR = 3;

/// The flight: `CatmullRomCurve3` through these points, 4000 ms, looking
/// 0.05 ahead.
const List<_V> _flightPoints = [
  _V(3, 3, -2),
  _V(0, 5, 2),
  _V(-4, 4, -4),
  _V(-8, 8, -8),
];
const double _flightSeconds = 4;
const double _lookAhead = 0.05;

// ---------------------------------------------- scenario 2: the lab bench

/// Bench `BoxGeometry(25, 1, 12)` at y = -2 (top at -1.5).
const _V _benchPos = _V(0, -2, 0);
const _V _benchSize = _V(25, 1, 12);
const double _benchTop = -1.5;

/// Hotplate: base `BoxGeometry(6.5, 0.6, 6.5)` at y -1.2, plate
/// `CylinderGeometry(2.8, 2.8, 0.2)` at y -0.8, coil `RingGeometry(1.5,
/// 2.5)` at y -0.69 (opacity `(t - 40) / 60` above 40 °C), knob r 0.3 on
/// its front face at (2, -1.2, 3.25).
const _V _plateBasePos = _V(0, -1.2, 0);
const _V _plateBaseSize = _V(6.5, 0.6, 6.5);
const double _plateY = -0.8;
const double _plateR = 2.8;
const double _plateH = 0.2;
const double _coilY = -0.69;
const double _coilIn = 1.5;
const double _coilOut = 2.5;
const double _coilFrom = 40;
const double _coilSpan = 60;
const _V _knobPos = _V(2, -1.2, 3.35);
const double _knobR = 0.3;

/// Beaker group at (-2, 1.3, 0): open glass `CylinderGeometry(2, 2, 4)`,
/// base at y -1.9 (0.2 thick), three marks 0.5 wide at y -1, 0, 1 on the
/// front, label at (0, 3, 0).
const _V _beakerPos = _V(-2, 1.3, 0);
const double _beakerR = 2;
const double _beakerHalf = 2;
const double _baseTop = -1.8;
const double _markHalf = 0.25;
const _V _beakerLabelLocal = _V(0, 3, 0);

/// Water `CylinderGeometry(1.95, 1.95, 3.5)` at local y -0.5 (opacity 0.7,
/// 0.2 beside ice); boiling shrinks it to scale 0.6 at y -1 (3000 ms).
const double _waterR = 1.95;
const double _waterH = 3.5;
const double _waterY = -0.5;
const double _boiledY = -1;
const double _boiledScale = 0.6;
const double _boilSeconds = 3;
const double _waterAlpha = 0.7;
const double _iceWaterAlpha = 0.2;

/// Twelve ice cubes 0.8 wide; they grow from 0.01 to 1 (500 ms) at 0 °C.
const int _iceCount = 12;
const double _iceSide = 0.8;
const double _iceSeconds = 0.5;
const double _iceMin = 0.01;

/// Bubbles (20, r 0.1) rise from y -2 to 0.5 at 0.02–0.07 per frame; steam
/// puffs (30, 0.4 wide) rise from y 2 at 0.01–0.04 per frame and fade by
/// 0.01 per frame (60 frames a second); when boiling stops the steam fades
/// by 0.05 per frame. Both spawn within ±1.5 of the beaker's axis.
const int _bubbleCount = 20;
const double _bubbleR = 0.1;
const double _bubbleFrom = -2;
const double _bubbleTo = 0.5;
const double _bubbleAlpha = 0.6;
const int _puffCount = 30;
const double _puffSide = 0.4;
const double _puffY = 2;
const double _fps = 60;
const double _puffDecay = 0.01;
const double _puffFade = 0.05;
const double _spread = 1.5;

/// Thermometer group at (3, 1, 0): glass `CylinderGeometry(0.3, 0.3, 6)`
/// (its bulb sits below the bench top), liquid r 0.12 from y -2.8 with
/// height `0.5 + (t + 20) / 140 · 5` (200 ms tween), marks every 0.5 from
/// -2 to 2, label at (0, 4, 0).
const _V _thermoPos = _V(3, 1, 0);
const double _thermoR = 0.3;
const double _thermoHalf = 3;
const double _liquidR = 0.12;
const double _liquidFrom = -2.8;
const double _thermoSeconds = 0.2;
const _V _thermoLabelLocal = _V(0, 4, 0);

/// Temperature slider: -20 … 120 °C from 25 °C, with the HTML thresholds.
const double _tempMin = -20;
const double _tempMax = 120;
const double _tempStart = 25;

/// Ice forms at or below 0 °C; step 1 ends at or below -10 °C.
const double _freezeAt = 0;
const double _frozenStep = -10;

/// Step 2 ends above 20 °C.
const double _meltedStep = 20;

/// Boiling at or above 100 °C (step 3 ends there), stops below 90 °C.
const double _boilAt = 100;
const double _boilStep = 95;
const double _stopBoilBelow = 90;

/// Step 4 ends at or below 30 °C.
const double _roomStep = 30;

/// The slider panel's top border: blue below 0 °C, red above 80 °C,
/// emerald between.
const double _hotAbove = 80;

/// Thermometer liquid height for [temp] °C (`updateThermometer`).
double _liquidHeight(double temp) =>
    0.5 + (temp - _tempMin) / (_tempMax - _tempMin) * 5;

// ------------------------------------------------------------- summary

/// HTML `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})` with
/// 'Mastery Achieved!': canvas-confetti's 200 ticks of 1/60 s, velocity
/// x 0.9 per tick, gravity 3 px per tick and start velocity 45 (scaled for
/// the stage).
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);
const Rect _confettiPiece = Rect.fromLTWH(-5, -3, 10, 6);

/// HTML `showObservationPopup(…, 8000)`: the next-scenario note stays 8 s
/// and fades in and out in 0.5 s.
const double _bannerSeconds = 8;
const double _bannerFade = 0.5;

// ------------------------------------------------------------- labels

/// How a label chip sits on its anchor (x, y alignment: -1 left / top
/// edge, 0 centre, 1 right / bottom edge).
const (double, double) _centred = (0, 0);

// ---------------------------------------------------------------- models

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
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Rotations about the x, y and z axes (right-handed, as in Three.js).
_V _rotX(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x, v.y * c - v.z * s, v.y * s + v.z * c);
}

_V _rotY(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

_V _rotZ(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}

/// Three.js `Euler(x, y, z, 'XYZ')` applied to [v] (`Rx · Ry · Rz · v`).
_V _euler(_V v, _V r) => _rotX(_rotY(_rotZ(v, r.z), r.y), r.x);

/// A twig-local point in the world.
_V _twigWorld(_V local) => _twigPos + _rotZ(local, _twigTilt);

/// A tapered cylinder from [a] (radius [ra]) to [b] (radius [rb]) (HTML
/// `CylinderGeometry(rb, ra, …)`: Three.js lists the top radius first).
typedef _Rod = ({_V a, _V b, double ra, double rb});

/// A twig-local cylinder of [length] along [axis] around [center].
_Rod _twigRod(_V center, _V axis, double length, double bottom, double top) {
  final h = axis * (length / 2);
  return (
    a: _twigWorld(center - h),
    b: _twigWorld(center + h),
    ra: bottom,
    rb: top,
  );
}

/// The twig in world space (HTML `twigMesh`): the main stem
/// `CylinderGeometry(0.3, 0.4, 12)`, branch 1 `(0.1, 0.2, 4)` at (1.5, 1, 0)
/// turned -π/4 and branch 2 `(0.08, 0.15, 3)` at (-1.2, -2, 1) turned
/// (π/4, 0, π/3).
final List<_Rod> _twigRods = [
  _twigRod(_V.zero, _V.up, 12, 0.4, 0.3),
  _twigRod(const _V(1.5, 1, 0), _rotZ(_V.up, -math.pi / 4), 4, 0.2, 0.1),
  _twigRod(
    const _V(-1.2, -2, 1),
    _euler(_V.up, const _V(math.pi / 4, 0, math.pi / 3)),
    3,
    0.15,
    0.08,
  ),
];

/// The glowing aura around the stem (`CylinderGeometry(0.6, 0.7, 12.5)`,
/// `BackSide`).
final _Rod _twigAura = _twigRod(_V.zero, _V.up, 12.5, 0.7, 0.6);

/// Where the camera's look-at point lands on the stage and how much the
/// scene is enlarged (the HTML camera is [base]). The scene is fitted into
/// the part of the canvas no card covers.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom);

  final Offset center;
  final double zoom;

  static const _Framing base = _Framing(_designCenter, 1);

  _Framing lerpTo(_Framing o, double t) =>
      _Framing(Offset.lerp(center, o.center, t)!, zoom + (o.zoom - zoom) * t);

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_Framing framing) {
    final f = (_lookAt - _eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(f, r, r.cross(f), framing.center, _focal * framing.zoom);
  }

  const _Cam._(this.f, this.r, this.u, this.center, this.scale);

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  _V get eye => _eye;

  double depth(_V w) => (w - _eye).dot(f);

  /// The design point of [w] (everything in the scenes is in front of the
  /// camera).
  Offset p(_V w) {
    final d = w - _eye;
    final z = math.max(_near, d.dot(f));
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / scale) + u * (-(s.dy - center.dy) / scale))
          .unit;

  /// Where the ray through [s] meets the plane through [point] facing the
  /// camera (HTML `dragPlane.setFromNormalAndCoplanarPoint(camera
  /// direction, object)`).
  _V? onViewPlane(Offset s, _V point) {
    final dir = ray(s);
    final denom = dir.dot(f);
    if (denom.abs() < 1e-6) return null;
    final t = (point - _eye).dot(f) / denom;
    if (t <= 0) return null;
    return _eye + dir * t;
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

  /// Screen bounds of the box [min]–[max].
  Rect boxRect(_V min, _V max) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final q = p(
        _V(
          (i & 1) != 0 ? max.x : min.x,
          (i & 2) != 0 ? max.y : min.y,
          (i & 4) != 0 ? max.z : min.z,
        ),
      );
      l = math.min(l, q.dx);
      t = math.min(t, q.dy);
      r = math.max(r, q.dx);
      b = math.max(b, q.dy);
    }
    return Rect.fromLTRB(l, t, r, b);
  }
}

/// A value tweened from [from] to [to] over [seconds] from scene time
/// [start] (an HTML `TWEEN.Tween`).
@immutable
class _Ramp {
  const _Ramp(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  /// A value at rest.
  const _Ramp.fixed(double value) : this(value, value, 0, 0);

  final double from;
  final double to;
  final double start;
  final double seconds;
  final Curve curve;

  double at(double time) {
    if (seconds <= 0) return to;
    final e = ((time - start) / seconds).clamp(0.0, 1.0);
    return from + (to - from) * curve.transform(e);
  }
}

/// `TWEEN.Easing.Back.Out` (overshoots a little, then settles).
class _BackOut extends Curve {
  const _BackOut();

  @override
  double transformInternal(double t) {
    const s = 1.70158;
    final k = t - 1;
    return k * k * ((s + 1) * k + s) + 1;
  }
}

/// `THREE.CatmullRomCurve3` (centripetal) through [points], walked at an
/// even speed like `getPointAt` (200 arc-length divisions).
class _Flight {
  _Flight(this.points) {
    var sum = 0.0;
    var last = point(0);
    _lengths.add(0);
    for (var i = 1; i <= _divisions; i++) {
      final next = point(i / _divisions);
      sum += (next - last).length;
      _lengths.add(sum);
      last = next;
    }
  }

  static const int _divisions = 200;

  final List<_V> points;
  final List<double> _lengths = [];

  /// `getPoint(t)`.
  _V point(double t) {
    final l = points.length;
    final p = (l - 1) * t;
    var i = p.floor();
    var w = p - i;
    if (i >= l - 1) {
      i = l - 2;
      w = 1;
    }
    final p0 = i > 0 ? points[i - 1] : points[0] * 2 - points[1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < l ? points[i + 2] : points[l - 1] * 2 - points[l - 2];
    double gap(_V a, _V b) => math.pow((b - a).dot(b - a), 0.25).toDouble();
    var dt0 = gap(p0, p1), dt1 = gap(p1, p2), dt2 = gap(p2, p3);
    if (dt1 < 1e-4) dt1 = 1;
    if (dt0 < 1e-4) dt0 = dt1;
    if (dt2 < 1e-4) dt2 = dt1;
    double axis(double x0, double x1, double x2, double x3) {
      final t1 =
          ((x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1) * dt1;
      final t2 =
          ((x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2) * dt1;
      final c2 = -3 * x1 + 3 * x2 - 2 * t1 - t2;
      final c3 = 2 * x1 - 2 * x2 + t1 + t2;
      return x1 + t1 * w + c2 * w * w + c3 * w * w * w;
    }

    return _V(
      axis(p0.x, p1.x, p2.x, p3.x),
      axis(p0.y, p1.y, p2.y, p3.y),
      axis(p0.z, p1.z, p2.z, p3.z),
    );
  }

  /// `getPointAt(u)`: the point [u] of the way along the curve's length.
  _V pointAt(double u) {
    final target = u.clamp(0.0, 1.0) * _lengths.last;
    var lo = 0, hi = _lengths.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (_lengths[mid] <= target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final span = _lengths[hi] - _lengths[lo];
    final f = span <= 0 ? 0.0 : (target - _lengths[lo]) / span;
    return point((lo + f) / _divisions);
  }
}

/// The butterfly's flight path.
final _Flight _flight = _Flight(_flightPoints);

/// One bubble rising through the boiling water (beaker-local).
class _Bubble {
  _Bubble(this.x, this.y, this.z, this.speed);

  final double x;
  double y;
  final double z;

  /// Units per frame.
  final double speed;
}

/// One steam puff above the beaker (beaker-local, from the steam group at
/// y 2), its remaining life and its opacity.
class _Puff {
  _Puff(this.x, this.z, this.speed);

  double x;
  double y = 0;
  double z;

  /// Units per frame.
  final double speed;
  double life = 1;
  double alpha = 0;
}

/// One ice cube (beaker-local): centre, Euler rotation and the jitter of
/// its eight corners (HTML: every vertex moved by up to ±0.05).
@immutable
class _IceCube {
  const _IceCube(this.pos, this.rot, this.jitter);

  final _V pos;
  final _V rot;
  final List<_V> jitter;
}

/// The twelve ice cubes, the same every time (the HTML used Math.random).
final List<_IceCube> _iceCubes = () {
  final rnd = math.Random(7);
  double r() => rnd.nextDouble() - 0.5;
  return [
    for (var i = 0; i < _iceCount; i++)
      _IceCube(
        _V(r() * 2.5, r() * 2 - 0.2, r() * 2.5),
        _V(
          rnd.nextDouble() * math.pi,
          rnd.nextDouble() * math.pi,
          rnd.nextDouble() * math.pi,
        ),
        [for (var j = 0; j < 8; j++) _V(r() * 0.1, r() * 0.1, r() * 0.1)],
      ),
  ];
}();

/// One confetti piece (canvas-confetti): launch angle, speed, colour and
/// spin.
typedef _Confetto = ({double angle, double velocity, Color color, double spin});

/// Mutable scene read by the painter every frame (HTML `State` and the
/// Three.js objects).
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based); one past the last step once the
  /// scenario is done.
  int step = 1;

  /// The step's panels are up (one second after a scenario loads).
  bool panelsReady = false;

  /// 'Observe Conclusion' is offered (HTML `triggerConclusionState`), and
  /// was tapped.
  bool conclusionReady = false;
  bool concluded = false;

  /// Pending events in scene time (the HTML tween `onComplete` callbacks).
  final List<(double, VoidCallback)> _cues = [];

  /// The HTML's Math.random for bubbles and steam, seeded per scenario.
  math.Random _rnd = math.Random(5);

  /// Something came to rest since the last [takeSettled].
  bool _settled = true;

  // ------------------------------------------------------------ scenario 1
  /// HTML `State.s1`.
  int feedings = 0;
  bool onTwig = false;
  bool emerged = false;
  double lapse = 0;

  /// The caterpillar group: position, scale tween, wiggle start, label.
  _V catPos = _catHome;
  _Ramp catScale = const _Ramp.fixed(1);
  double wiggleAt = -1;
  bool catLabel = true;
  bool catVisible = true;

  /// The caterpillar is held (HTML `State.dragTarget`) and the finger's
  /// design point (the drag badge follows it).
  bool catHeld = false;
  Offset? handAt;

  /// A glide of the caterpillar (onto the twig or back home).
  _V _glideFrom = _catHome;
  _V _glideTo = _catHome;
  double _glideStart = -1;
  double _glideSeconds = 0;

  /// A leaf is being dragged (HTML `.dropzone-area.highlight`).
  bool leafDragging = false;

  /// Scene time the twig started to glow, or -1.
  double auraAt = -1;

  /// The chrysalis: shown, its pop-in and its tilt.
  bool chrysVisible = false;
  _Ramp chrysScale = const _Ramp.fixed(1);
  double chrysTilt = _chrysRestTilt;

  /// The butterfly: shown, its pop-in, the start of its flight and the
  /// direction it looks.
  bool flyVisible = false;
  _Ramp flyScale = const _Ramp.fixed(_flyScale);
  double flightAt = -1;
  _V _flyForward = const _V(0, 0, 1);

  // ------------------------------------------------------------ scenario 2
  /// HTML `State.s2`.
  double temp = _tempStart;
  bool isIce = false;
  bool isBoiling = false;

  /// Thermometer liquid height, ice scale and water opacity tweens; the
  /// scene time boiling began to lower the water, or -1.
  _Ramp thermo = _Ramp.fixed(_liquidHeight(_tempStart));
  _Ramp ice = const _Ramp.fixed(_iceMin);
  _Ramp waterAlpha = const _Ramp.fixed(_waterAlpha);
  double boilAt = -1;

  final List<_Bubble> bubbles = [];
  final List<_Puff> puffs = [];

  // -------------------------------------------------------------- summary
  double confettiAt = -1;
  final List<_Confetto> confetti = () {
    final rnd = math.Random(2);
    return [
      for (var i = 0; i < _confettiCount; i++)
        (
          angle: -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          velocity:
              (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          color: _Colors.confetti[i % _Colors.confetti.length],
          spin: (rnd.nextDouble() - 0.5) * 0.4,
        ),
    ];
  }();

  /// Scene time the next-scenario note appeared, or -1.
  double bannerAt = -1;

  /// Design x range the label chips are kept in (the visible canvas, left
  /// of the tool column).
  double labelLeft = 0;
  double labelRight = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    panelsReady = false;
    conclusionReady = false;
    concluded = false;
    _cues.clear();
    _rnd = math.Random(5);
    feedings = 0;
    onTwig = false;
    emerged = false;
    lapse = 0;
    catPos = _catHome;
    catScale = const _Ramp.fixed(1);
    wiggleAt = -1;
    catLabel = true;
    catVisible = true;
    catHeld = false;
    handAt = null;
    _glideStart = -1;
    leafDragging = false;
    auraAt = -1;
    chrysVisible = false;
    chrysScale = const _Ramp.fixed(1);
    chrysTilt = _chrysRestTilt;
    flyVisible = false;
    flyScale = const _Ramp.fixed(_flyScale);
    flightAt = -1;
    _flyForward = const _V(0, 0, 1);
    temp = _tempStart;
    isIce = false;
    isBoiling = false;
    thermo = _Ramp.fixed(_liquidHeight(_tempStart));
    ice = const _Ramp.fixed(_iceMin);
    waterAlpha = const _Ramp.fixed(_waterAlpha);
    boilAt = -1;
    double r() => (_rnd.nextDouble() - 0.5) * 2 * _spread;
    bubbles
      ..clear()
      ..addAll([
        for (var i = 0; i < _bubbleCount; i++)
          _Bubble(r(), _bubbleFrom, r(), _rnd.nextDouble() * 0.05 + 0.02),
      ]);
    puffs
      ..clear()
      ..addAll([
        for (var i = 0; i < _puffCount; i++)
          _Puff(r(), r(), _rnd.nextDouble() * 0.03 + 0.01),
      ]);
    confettiAt = -1;
    bannerAt = -1;
    _settled = true;
  }

  /// Runs [run] at scene time [at].
  void cue(double at, VoidCallback run) => _cues.add((at, run));

  /// Runs the cues that are due.
  void runCues() {
    if (!_cues.any((c) => c.$1 <= time)) return;
    final due = [
      for (final c in _cues)
        if (c.$1 <= time) c,
    ];
    _cues.removeWhere((c) => c.$1 <= time);
    for (final c in due) {
      c.$2();
    }
  }

  /// True once after something came to rest (the screen-reader nodes then
  /// follow the scene).
  bool takeSettled() {
    final s = _settled;
    _settled = false;
    return s;
  }

  void markSettled() => _settled = true;

  /// HTML `animate()`: the steam and bubbles, the butterfly's heading and
  /// the framing.
  void advance(double dt) {
    if (scenario == 1) _advanceWater(dt * _fps);
    if (flightAt >= 0) {
      final p = flightProgress;
      final ahead = _flight.pointAt(math.min(p + _lookAhead, 1)) - flyPos;
      if (ahead.length > 1e-4) _flyForward = ahead.unit;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      if (_framingT >= 1) _settled = true;
    }
  }

  /// [frames] HTML frames of bubbles and steam.
  void _advanceWater(double frames) {
    if (isBoiling) {
      for (final b in bubbles) {
        b.y += b.speed * frames;
        if (b.y > _bubbleTo) b.y = _bubbleFrom;
      }
      for (final p in puffs) {
        p
          ..y += p.speed * frames
          ..life -= _puffDecay * frames
          ..alpha = p.life.clamp(0.0, 1.0);
        if (p.life <= 0) {
          p
            ..x = (_rnd.nextDouble() - 0.5) * 2 * _spread
            ..y = 0
            ..z = (_rnd.nextDouble() - 0.5) * 2 * _spread
            ..life = 1;
        }
      }
    } else {
      for (final p in puffs) {
        if (p.alpha > 0) p.alpha = math.max(0, p.alpha - _puffFade * frames);
      }
    }
  }

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      _settled = true;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// The camera in the current framing.
  _Cam camera() => _Cam(framing);

  // ------------------------------------------------------- the caterpillar

  /// The caterpillar's scale (1, + 0.15 per leaf).
  double get catK => catScale.at(time);

  /// Where the caterpillar group is now (gliding, held or at rest).
  _V get catNow {
    if (_glideStart < 0) return catPos;
    final e = ((time - _glideStart) / _glideSeconds).clamp(0.0, 1.0);
    return _V.lerp(_glideFrom, _glideTo, e);
  }

  bool get gliding => _glideStart >= 0;

  /// Glides the caterpillar to [to] in [seconds] (linear, like the HTML
  /// position tweens); [endGlide] puts it there.
  void glide(_V to, double seconds) {
    _glideFrom = catNow;
    _glideTo = to;
    _glideStart = time;
    _glideSeconds = seconds;
  }

  void endGlide() {
    catPos = _glideTo;
    _glideStart = -1;
    _settled = true;
  }

  /// The middle of the caterpillar's body in the world.
  _V get catCenter => catNow + _catMiddle * catK;

  /// Height of segment [i] in its wiggle: up 0.2 and back twice, 100 ms a
  /// leg, segment i starting i · 50 ms after the leaf was eaten.
  double wiggle(int i) {
    if (wiggleAt < 0) return 0;
    final e = time - wiggleAt - i * _wiggleDelay;
    if (e <= 0 || e >= _wiggleLeg * _wiggleLegs) return 0;
    final leg = (e / _wiggleLeg).floor();
    final f = e / _wiggleLeg - leg;
    return _wiggleRise * (leg.isEven ? f : 1 - f);
  }

  /// Opacity of the twig's aura (0 … 0.6 and back every second).
  double get auraAlpha {
    if (auraAt < 0) return 0;
    final phase = ((time - auraAt) / _auraSeconds) % 2;
    return _auraMax * (phase < 1 ? phase : 2 - phase);
  }

  /// The caterpillar's body on screen.
  Rect catRect(_Cam cam) {
    final k = catK;
    final c = catNow;
    return cam.boxRect(c + _catBodyMin * k, c + _catBodyMax * k);
  }

  /// HTML raycast on the caterpillar's hit box (`BoxGeometry(6, 3, 3)`).
  bool onCaterpillar(Offset p, double touch) {
    final k = catK;
    final c = catNow;
    return camera()
        .boxRect(c - _catHitHalf * k, c + _catHitHalf * k)
        .inflate(touch * 0.25)
        .contains(p);
  }

  /// HTML `#s1-dropzone`: a 300 px square, centred on the caterpillar.
  Rect dropZone(_Cam cam) {
    final side = _dropZoneSide * framing.zoom;
    return Rect.fromCenter(center: cam.p(catCenter), width: side, height: side);
  }

  /// The twig's stem on screen.
  Rect twigRect(_Cam cam) {
    final stem = _twigRods.first;
    final a = cam.p(stem.a), b = cam.p(stem.b);
    return Rect.fromPoints(a, b).inflate(stem.ra * cam.scaleAt(_twigPos));
  }

  // -------------------------------------------------------- the butterfly

  /// The chrysalis's scale (pops in from 0.1).
  double get chrysK => chrysScale.at(time);

  /// The butterfly's scale (pops to 1.5).
  double get flyK => flyScale.at(time);

  /// 0 … 1 along the flight (0 before it starts).
  double get flightProgress =>
      flightAt < 0 ? 0 : ((time - flightAt) / _flightSeconds).clamp(0.0, 1.0);

  /// Where the butterfly is now.
  _V get flyPos => flightAt < 0 ? _flyHome : _flight.pointAt(flightProgress);

  /// The butterfly's right, up and forward axes (HTML `lookAt`: its +z
  /// looks along the flight).
  (_V, _V, _V) get flyAxes {
    final f = _flyForward;
    var r = _V.up.cross(f);
    r = r.length < 1e-6 ? const _V(1, 0, 0) : r.unit;
    return (r, f.cross(r), f);
  }

  /// The right hinge's `rotation.z` (the left one is mirrored).
  double get flap => -math.sin(time * _flapRate) * _flapAmp;

  /// HTML raycast on the butterfly's hit sphere (radius 3).
  bool onButterfly(Offset p, double touch) {
    final cam = camera();
    final c = flyPos;
    final reach = math.max(_flyHitR * flyK * cam.scaleAt(c), touch);
    return (p - cam.p(c)).distance <= reach;
  }

  /// The butterfly on screen (its body and the inner part of its wings).
  Rect flyRect(_Cam cam) {
    final c = flyPos;
    final r = math.max(1.6 * flyK * cam.scaleAt(c), 12.0);
    return Rect.fromCircle(center: cam.p(c), radius: r);
  }

  // ------------------------------------------------------------- the water

  double get thermoHeight => thermo.at(time);
  double get iceK => ice.at(time);
  double get waterOpacity => waterAlpha.at(time);

  /// 0 … 1 through the water level's 3 s drop once boiling began.
  double get _boilT =>
      boilAt < 0 ? 0 : ((time - boilAt) / _boilSeconds).clamp(0.0, 1.0);

  /// The water's centre (beaker-local) and its height scale.
  double get waterCenter => _waterY + (_boiledY - _waterY) * _boilT;
  double get waterScale => 1 + (_boiledScale - 1) * _boilT;

  /// HTML hotplate coil opacity.
  double get coilAlpha =>
      temp > _coilFrom ? math.min((temp - _coilFrom) / _coilSpan, 1.0) : 0;

  /// The beaker and the thermometer on screen.
  Rect beakerRect(_Cam cam) => cam.boxRect(
    _beakerPos - const _V(_beakerR, _beakerHalf, _beakerR),
    _beakerPos + const _V(_beakerR, _beakerHalf, _beakerR),
  );

  Rect thermoRect(_Cam cam) => cam.boxRect(
    _V(_thermoPos.x - _thermoR, _benchTop, -_thermoR),
    _V(_thermoPos.x + _thermoR, _thermoPos.y + _thermoHalf, _thermoR),
  );
}

/// What the framing keeps in view: a point of the base projection (the
/// HTML camera at zoom 1) and a rect around it that does not scale with the
/// zoom (a label chip; empty for a point of an object).
typedef _Focus = (Offset, Rect);

/// Best framing for [focus] inside [free], clear of the [hard] obstacles
/// (all in design coordinates), at most [maxZoom]. Objects scale with the
/// zoom, their label chips do not.
_Framing _fitFraming(
  List<_Focus> focus,
  Rect free,
  List<Rect> hard,
  double maxZoom,
) {
  if (free.width <= 1 || free.height <= 1 || focus.isEmpty) {
    return _Framing.base;
  }
  var rects = [free];
  for (final o in hard) {
    final next = <Rect>[];
    for (final r in rects) {
      if (!r.overlaps(o)) {
        next.add(r);
        continue;
      }
      if (o.left > r.left + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, o.left, r.bottom));
      }
      if (o.right < r.right - 1) {
        next.add(Rect.fromLTRB(o.right, r.top, r.right, r.bottom));
      }
      if (o.top > r.top + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, r.right, o.top));
      }
      if (o.bottom < r.bottom - 1) {
        next.add(Rect.fromLTRB(r.left, o.bottom, r.right, r.bottom));
      }
    }
    rects = next;
  }
  // Extent of the focus at zoom [z], relative to where the look-at point
  // lands.
  Rect extent(double z) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final (p, o) in focus) {
      final x = (p.dx - _designCenter.dx) * z;
      final y = (p.dy - _designCenter.dy) * z;
      l = math.min(l, x + o.left);
      t = math.min(t, y + o.top);
      r = math.max(r, x + o.right);
      b = math.max(b, y + o.bottom);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  bool fits(Rect r, double z) {
    final e = extent(z);
    return e.width <= r.width && e.height <= r.height;
  }

  /// Largest zoom at which the focus fits in [r] (0 if it never does).
  double zoomFor(Rect r) {
    if (fits(r, maxZoom)) return maxZoom;
    if (!fits(r, _minZoom)) return 0;
    var lo = _minZoom, hi = maxZoom;
    for (var i = 0; i < 16; i++) {
      final mid = (lo + hi) / 2;
      if (fits(r, mid)) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  (Rect, double)? pick;
  for (final r in rects) {
    final z = zoomFor(r);
    if (pick == null ||
        z > pick.$2 + 1e-6 ||
        ((z - pick.$2).abs() <= 1e-6 &&
            r.width * r.height > pick.$1.width * pick.$1.height)) {
      pick = (r, z);
    }
  }
  if (pick == null) return _Framing.base;
  final (rect, z) = pick;
  // Nothing fits (a tiny canvas): the smallest scene, centred in the
  // largest free part.
  final zoom = z > 0 ? z : _minZoom;
  return _Framing(rect.center - extent(zoom).center, zoom);
}

/// Top-left of a chip of [size] relative to its anchor (see [_centred]).
Offset _chipOffset(Size size, (double, double) align) =>
    Offset(-(align.$1 + 1) / 2 * size.width, -(align.$2 + 1) / 2 * size.height);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the caterpillar (step 3) or the butterfly (step 5) ([canGrab]), so
/// other drags still pan / zoom the canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _FieldsLabState extends State<Ch1A5ExploringDiverseFieldsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Bumped when the scene settles: the screen-reader nodes follow it.
  final ValueNotifier<int> _layout = ValueNotifier(0);

  /// The time-lapse (Scenario 1) or temperature (Scenario 2) slider's
  /// value: only the slider card rebuilds as it moves.
  final ValueNotifier<double> _slider = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  final Map<String, List<_StepInfo>> _infos = {};
  late final Ticker _ticker;

  /// The canvas area (framing), the design box (leaf drops) and the
  /// canvas cards (framing obstacles).
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch1-a5-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch1-a5-design');
  final GlobalKey _foodKey = GlobalKey(debugLabel: 'ch1-a5-food');
  final GlobalKey _bottomKey = GlobalKey(debugLabel: 'ch1-a5-bottom');

  /// Touch radius and label size in design px for the current stage
  /// scale, and the stage scale (screen px per design px).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _fit = 1;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// The floating mission card at its tallest in this scenario (its text
  /// changes with every step): the scene keeps clear of that, so it does
  /// not move each time the card shrinks again.
  Rect? _cardRect;

  /// The caterpillar is held by the current pointer: the scenario it was
  /// picked up in, the drag plane's point and the grab offset on it.
  bool _grabbing = false;
  int _grabScenario = -1;
  _V _planePoint = _V.zero;
  _V _grabOffset = _V.zero;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  /// The Biology summary is open: closing it shows the next-scenario note
  /// (HTML `closeSummary()`).
  bool _summaryOpen = false;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  List<_StepInfo> get _stepData =>
      _infos['${_lab.lang.code}${_scene.scenario}'] ??= _stepInfos(
        _lab.lang,
        _scene.scenario,
      );

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
    _lab.addListener(_onLabChanged);
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
    _lab.removeListener(_onLabChanged);
    _ticker.dispose();
    _frame.dispose();
    _layout.dispose();
    _slider.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()` + `TWEEN.update()`; then one repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
    s.runCues();
    if (s.takeSettled()) _layout.value++;
    _frame.value = now;
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (cards and canvas are laid out by
  /// then). [snap] jumps there instead of sliding (new scenario).
  void _scheduleFraming({bool snap = false}) {
    if (snap) _snapFraming = true;
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// card covers: the tool column, the HUD (sidebar open), the floating
  /// mission card (sidebar collapsed), the Food panel and the bottom card
  /// (slider, 'Observe Conclusion'). Never while the caterpillar is held,
  /// so the scene does not move under the finger.
  void _updateFraming() {
    if (_grabbing) return;
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
    final origin = canvas.localToGlobal(Offset.zero);
    final stage = Offset(
      (size.width - _design.width * fit) / 2,
      (size.height - _design.height * fit) / 2,
    );
    Rect toDesign(Rect r) => Rect.fromLTRB(
      (r.left - stage.dx) / fit,
      (r.top - stage.dy) / fit,
      (r.right - stage.dx) / fit,
      (r.bottom - stage.dy) / fit,
    );
    Rect? measured(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return null;
      return (box.localToGlobal(Offset.zero) - origin) & box.size;
    }

    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (open ? _hudBand * context.labScale + 8 : 8) - pad.bottom,
    );
    final hard = <Rect>[];
    if (open) _cardRect = null;
    if (!open && _lab.isLabActive) {
      // The floating mission card as it is laid out; before that, the room
      // the shell gives it.
      final card = _missionCardBox();
      if (card != null) {
        final now = (card.localToGlobal(Offset.zero) - origin) & card.size;
        final kept = _cardRect;
        _cardRect = kept == null
            ? now
            : Rect.fromLTWH(
                now.left,
                now.top,
                math.max(now.width, kept.width),
                math.max(now.height, kept.height),
              );
        hard.add(_cardRect!);
      } else {
        final bottom = screen.height < _compactBelow
            ? _missionTop + pad.top + screen.height * _compactCardMax
            : size.height;
        hard.add(Rect.fromLTRB(0, 0, insets.left, bottom));
      }
    }
    for (final key in [_foodKey, _bottomKey]) {
      final r = measured(key);
      if (r != null) hard.add(r);
    }
    _scene
      ..labelLeft = (4 - stage.dx) / fit
      ..labelRight = (size.width - insets.right - stage.dx) / fit;
    final target = _fitFraming(
      _focusItems(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      _maxZoom[_scene.scenario],
    );
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
  }

  /// The shell's floating mission card (sidebar collapsed), found in the
  /// lab's element tree.
  RenderBox? _missionCardBox() {
    RenderBox? found;
    void visit(Element e) {
      if (found != null) return;
      if (e.widget is _FloatingMissionCard) {
        final box = e.findRenderObject();
        if (box is RenderBox && box.hasSize && box.attached) found = box;
        return;
      }
      e.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return found;
  }

  /// What the learner must see (HTML camera, zoom 1): S1 the caterpillar
  /// at its largest, the twig, the chrysalis and, while leaves are fed,
  /// the drop zone; S2 the hotplate, the beaker and its steam and the
  /// thermometer; and the label chips at their painted size.
  List<_Focus> _focusItems() {
    final cam = _Cam(_Framing.base);
    _cache.prepare(_lab.lang, _labelSize);
    final items = <_Focus>[];
    void point(_V w) => items.add((cam.p(w), Rect.zero));
    void box(_V min, _V max) {
      for (var i = 0; i < 8; i++) {
        point(
          _V(
            (i & 1) != 0 ? max.x : min.x,
            (i & 2) != 0 ? max.y : min.y,
            (i & 4) != 0 ? max.z : min.z,
          ),
        );
      }
    }

    void chip(_V at, String text) {
      final size = _cache.chipSize(text);
      items.add((cam.p(at), _chipOffset(size, _centred) & size));
    }

    final s = _scene;
    if (s.scenario == 0) {
      const k = 1 + _growStep * _feedsToPupate;
      box(_catHome + _catBodyMin * k, _catHome + _catBodyMax * k);
      chip(_catHome + _catLabelLocal * k, _t('lbl_caterpillar'));
      for (final rod in _twigRods) {
        point(rod.a);
        point(rod.b);
      }
      chip(_twigWorld(_twigLabelLocal), _t('lbl_twig'));
      box(
        _chrysPos - const _V(0.8, 1.3, 0.8),
        _chrysPos + const _V(0.8, 1.8, 0.8),
      );
      if (s.panelsReady && s.step <= 2) {
        // The drop zone around the caterpillar (it scales with the zoom).
        final c = cam.p(_catHome + _catMiddle * s.catK);
        const h = _dropZoneSide / 2;
        for (final d in const [
          Offset(-h, -h),
          Offset(h, -h),
          Offset(-h, h),
          Offset(h, h),
        ]) {
          items.add((c + d, Rect.zero));
        }
      }
    } else {
      box(
        _V(-_plateBaseSize.x / 2, _benchTop, -_plateBaseSize.z / 2),
        _V(_plateBaseSize.x / 2, _plateY + _plateH / 2, _plateBaseSize.z / 2),
      );
      box(
        _beakerPos - const _V(_beakerR, _beakerHalf, _beakerR),
        _beakerPos + const _V(_beakerR, _beakerHalf, _beakerR),
      );
      // Steam rising above the beaker.
      box(
        _beakerPos + const _V(-_spread, _beakerHalf, -_spread),
        _beakerPos + const _V(_spread, _beakerHalf + 2.2, _spread),
      );
      box(
        _V(_thermoPos.x - _thermoR, _benchTop, -_thermoR),
        _V(_thermoPos.x + _thermoR, _thermoPos.y + _thermoHalf, _thermoR),
      );
      chip(_beakerPos + _beakerLabelLocal, _t('lbl_beaker'));
      chip(_thermoPos + _thermoLabelLocal, _t('lbl_thermometer'));
    }
    return items;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`: clears timers
  /// and tweens, rebuilds the scenario's scene and, a second later, shows
  /// the step's panels.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _summaryOpen = false;
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grabbing = false;
      _grabScenario = -1;
      _cardRect = null;
    });
    _slider.value = index == 0 ? 0 : _tempStart;
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
    _layout.value++;
    _lab.after(_panelDelay, () {
      if (!mounted) return;
      setState(() => _scene.panelsReady = true);
      _scheduleFraming();
      _layout.value++;
    });
  }

  /// Rebuilds after a scene event (step, panels, buttons).
  void _refresh() {
    if (!mounted) return;
    setState(() {});
    _scheduleFraming();
    _layout.value++;
  }

  /// Shows the toast [key] (with the lab's wrong tone for an error).
  void _toast(String key, {bool error = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error);
  }

  /// After a language switch, shows the toast on screen in the new language.
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

  /// The HUD line (HTML `hud[step]`); once 'Observe Conclusion' appears,
  /// what to do next (added); once it was tapped, the HTML's next-scenario
  /// note (Biology) or 'Mastery Achieved!' (Physics).
  String get _hud {
    final s = _scene;
    final n = s.scenario + 1;
    if (s.concluded) {
      return _t(s.scenario == 0 ? 'select_next_sc_msg' : 'all_complete');
    }
    if (s.conclusionReady) return _t('s${n}_hud_done');
    return _t('s${n}_hud_${s.step.clamp(1, _stepCounts[s.scenario])}');
  }

  // ------------------------------------------------- scenario 1: feeding

  /// The Food panel's leaf can be fed (HTML `#s1-feeding-panel`, steps
  /// 1–2).
  bool get _canFeed {
    final s = _scene;
    return _lab.isLabActive &&
        s.scenario == 0 &&
        s.panelsReady &&
        s.step <= 2 &&
        s.feedings < _feedsToPupate;
  }

  /// HTML `onStart`: the drop zone lights up while a leaf is dragged.
  void _onLeafDragStart() => _scene.leafDragging = true;

  void _onLeafDragEnd() => _scene.leafDragging = false;

  /// HTML `onEnd`: the leaf counts if its card overlaps the drop zone;
  /// otherwise it goes back to the panel (a hint says where, added).
  void _onLeafDrop(Offset global) {
    final s = _scene;
    s.leafDragging = false;
    if (!_canFeed) return;
    final p = labGlobalToLocal(_designKey, global);
    final half = _leafCardDp / 2 / _fit;
    if (p != null && s.dropZone(s.camera()).inflate(half).contains(p)) {
      _feed();
    } else {
      _toast('miss_leaf', error: true);
    }
  }

  /// A leaf let go off the canvas (on a card, the sidebar or a margin).
  void _onLeafMissed() {
    _scene.leafDragging = false;
    if (_canFeed) _toast('miss_leaf', error: true);
  }

  /// HTML drop: 'eat', the caterpillar grows (+0.15, 500 ms, `Back.Out`)
  /// and wiggles. The first leaf ends step 1; the third ends step 2: the
  /// twig glows and the caterpillar's label hides.
  void _feed() {
    final s = _scene;
    if (!_canFeed) return;
    _Sound.eat.play();
    final k = s.catK;
    s
      ..feedings += 1
      ..catScale = _Ramp(
        k,
        k + _growStep,
        s.time,
        _growSeconds,
        const _BackOut(),
      )
      ..wiggleAt = s.time;
    if (s.feedings == 1 && s.step == 1) {
      s.step = 2;
    } else if (s.feedings == _feedsToPupate && s.step == 2) {
      s
        ..auraAt = s.time
        ..catLabel = false
        ..step = 3;
    }
    s.cue(s.time + _growSeconds, s.markSettled);
    _refresh();
  }

  // ------------------------------------------ scenario 1: caterpillar drag

  /// HTML `pointerdown`: the caterpillar (step 3) or the butterfly (step 5)
  /// under the finger.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || _grabbing || s.scenario != 0) return false;
    final p = event.localPosition;
    if (s.step == 3 && s.catVisible && !s.onTwig && !s.gliding) {
      return s.onCaterpillar(p, _touch);
    }
    if (s.step == 5 && s.flyVisible && s.flightAt < 0) {
      return s.onButterfly(p, _touch);
    }
    return false;
  }

  /// HTML `start3DDrag`: the drag plane faces the camera through the
  /// caterpillar; the drag badge appears. At step 5 a press on the
  /// butterfly lets it fly.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final p = d.localPosition;
    if (s.scenario != 0) return;
    if (s.step == 5) {
      if (s.flyVisible && s.onButterfly(p, _touch)) _letFly();
      return;
    }
    if (s.step != 3 || s.onTwig || s.gliding || !s.onCaterpillar(p, _touch)) {
      return;
    }
    final at = s.catNow;
    final hit = s.camera().onViewPlane(p, at);
    _planePoint = at;
    _grabOffset = hit == null ? _V.zero : hit - at;
    _grabbing = true;
    _grabScenario = s.scenario;
    s
      ..catHeld = true
      ..handAt = p;
  }

  /// HTML `pointermove`: the caterpillar follows the finger on the drag
  /// plane.
  void _onDragUpdate(DragUpdateDetails d) {
    if (!_grabbing || _grabScenario != _scene.scenario) return;
    final s = _scene;
    s.handAt = d.localPosition;
    final hit = s.camera().onViewPlane(d.localPosition, _planePoint);
    if (hit != null) s.catPos = hit - _grabOffset;
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `end3DDrag`: within 6 units of the twig the caterpillar attaches
  /// to it; otherwise it glides back (400 ms) and a hint says where to drop
  /// it (added).
  void _release() {
    if (!_grabbing) return;
    final scenario = _grabScenario;
    _grabbing = false;
    _grabScenario = -1;
    final s = _scene;
    if (scenario != s.scenario) return;
    s
      ..catHeld = false
      ..handAt = null;
    if ((s.catPos - _twigPos).length < _snapRange) {
      _attach();
      return;
    }
    s
      ..glide(_catHome, _returnSeconds)
      ..cue(s.time + _returnSeconds, s.endGlide);
    _toast('miss_twig', error: true);
    _scheduleFraming();
  }

  /// HTML snap: the caterpillar glides onto the twig (300 ms), then 'pop':
  /// it is replaced by the chrysalis (popping in from 0.1, 1000 ms,
  /// `Elastic.Out`) and the twig stops glowing; step 4 shows the time-lapse
  /// slider at 0 %.
  void _attach() {
    final s = _scene;
    s
      ..onTwig = true
      ..glide(_snapTo, _snapSeconds);
    s.cue(s.time + _snapSeconds, () {
      _Sound.pop.play();
      s
        ..endGlide()
        ..catVisible = false
        ..chrysVisible = true
        ..auraAt = -1
        ..chrysScale = _Ramp(
          _popFrom,
          1,
          s.time,
          _popSeconds,
          Curves.elasticOut,
        )
        ..step = 4;
      s.cue(s.time + _popSeconds, s.markSettled);
      _slider.value = 0;
      _refresh();
    });
  }

  /// A screen-reader tap on the caterpillar (added): at step 3 it is put
  /// on the twig as if dropped there.
  void _activateCaterpillar() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step == 3 && !s.onTwig && !s.gliding && !_grabbing) _attach();
  }

  // ---------------------------------------- scenario 1: time-lapse, flight

  /// The time-lapse slider moves (HTML `updateTimeLapse(val)`, step 4 only).
  bool get _lapseEnabled {
    final s = _scene;
    return _lab.isLabActive && s.scenario == 0 && s.step == 4;
  }

  /// HTML `updateTimeLapse(val)`: the chrysalis wiggles
  /// (`π/8 + sin(val) · 0.1`); at 95 % it cracks open.
  void _onLapse(double v) {
    final s = _scene;
    if (!_lapseEnabled) return;
    final val = v.roundToDouble();
    _slider.value = val;
    s
      ..lapse = val
      ..chrysTilt = _chrysLapseTilt + math.sin(val) * _chrysWiggle;
    if (val >= _emergeAt && !s.emerged) _emerge();
  }

  /// HTML 'crack': the chrysalis gives way to the butterfly, which pops to
  /// scale 1.5 (1000 ms, `Elastic.Out`); step 5.
  void _emerge() {
    final s = _scene;
    _Sound.crack.play();
    s
      ..emerged = true
      ..chrysVisible = false
      ..flyVisible = true
      ..flyScale = _Ramp(
        _popFrom,
        _flyScale,
        s.time,
        _popSeconds,
        Curves.elasticOut,
      )
      ..step = 5;
    s.cue(s.time + _popSeconds, s.markSettled);
    _refresh();
  }

  /// HTML butterfly click: 'success' and the 4 s flight along the curve,
  /// then `triggerConclusionState()`.
  void _letFly() {
    final s = _scene;
    if (s.flightAt >= 0 || !s.flyVisible) return;
    _Sound.success.play();
    s.flightAt = s.time;
    s.cue(s.time + _flightSeconds, _offerConclusion);
    _layout.value++;
  }

  /// A screen-reader tap on the butterfly (added).
  void _activateButterfly() {
    final s = _scene;
    if (_lab.isLabActive && s.scenario == 0 && s.step == 5) _letFly();
  }

  /// HTML `triggerConclusionState()`: 'Observe Conclusion' appears with a
  /// chime and the last step is done.
  void _offerConclusion() {
    final s = _scene;
    if (s.conclusionReady) return;
    _Sound.success.play();
    s
      ..conclusionReady = true
      ..step += 1
      ..markSettled();
    _refresh();
  }

  // ----------------------------------------------- scenario 2: temperature

  /// The temperature slider moves (HTML `#s2-temp-slider`, steps 1–4).
  bool get _tempEnabled {
    final s = _scene;
    return _lab.isLabActive && s.scenario == 1 && s.step <= 4;
  }

  /// HTML `updateTemperature(val)`: the thermometer (200 ms), the coil, ice
  /// at 0 °C and below, melting above, boiling at 100 °C and above (bubbles,
  /// steam, the level drops over 3 s), stopping below 90 °C; and the step
  /// thresholds.
  void _onTemp(double v) {
    final s = _scene;
    if (!_tempEnabled) return;
    final t = v.roundToDouble();
    _slider.value = t;
    final step = s.step;
    s
      ..temp = t
      ..thermo = _Ramp(
        s.thermoHeight,
        _liquidHeight(t),
        s.time,
        _thermoSeconds,
      );
    if (t <= _freezeAt) {
      if (!s.isIce) {
        _Sound.freeze.play();
        s
          ..isIce = true
          ..ice = _Ramp(s.iceK, 1, s.time, _iceSeconds)
          ..waterAlpha = _Ramp(
            s.waterOpacity,
            _iceWaterAlpha,
            s.time,
            _iceSeconds,
          );
      }
      if (s.step == 1 && t <= _frozenStep) s.step = 2;
    } else {
      if (s.isIce) {
        _Sound.pop.play();
        s
          ..isIce = false
          ..ice = _Ramp(s.iceK, _iceMin, s.time, _iceSeconds)
          ..waterAlpha = _Ramp(
            s.waterOpacity,
            _waterAlpha,
            s.time,
            _iceSeconds,
          );
      }
      if (s.step == 2 && t > _meltedStep) s.step = 3;
    }
    if (t >= _boilAt) {
      if (!s.isBoiling) {
        _Sound.hiss.play();
        s.isBoiling = true;
        if (s.boilAt < 0) s.boilAt = s.time;
      }
      if (s.step == 3 && t >= _boilStep) s.step = 4;
    } else if (t < _stopBoilBelow) {
      s.isBoiling = false;
    }
    if (s.step == 4 && t <= _roomStep) {
      _offerConclusion();
      return;
    }
    if (s.step != step) _refresh();
  }

  // --------------------------------------------------------------- summary

  /// HTML `triggerConclusion()`: 'success', then Scenario 1's summary or,
  /// after Scenario 2, 'Mastery Achieved!' with confetti (here also with
  /// Scenario 2's summary, which the HTML never showed).
  void _conclude() {
    final s = _scene;
    if (!s.conclusionReady || s.concluded) return;
    final sc = s.scenario;
    s.concluded = true;
    if (sc == 1) s.confettiAt = s.time;
    _lab.completedScenarios.add(sc);
    _summaryOpen = sc == 0;
    _lab.showPopup(() => _summary(sc));
    _refresh();
  }

  LabPopupContent _summary(int sc) {
    final first = sc == 0;
    final field = _t('s${sc + 1}_title').split(':').first.trim();
    return LabPopupContent(
      title: _lab.t('success'),
      heading: first
          ? labFormat(_t('sc_complete'), {'n': field})
          : _t('all_complete'),
      icon: first ? Icons.lightbulb : Icons.emoji_events,
      accent: _Colors.indigo500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          scenario: sc,
          palette: _lab.palette,
          scale: context.labScale * _lab.fontScale.clamp(0.9, 1.4),
          head: _t('s${sc + 1}_sum_head'),
          text: _t('s${sc + 1}_summary'),
          bold: _t('s${sc + 1}_scientists'),
          note: first ? _t('select_next_sc_msg') : _t('all_complete_desc'),
        ),
      ),
      actions: [
        if (!first)
          LabAction(
            label: _t('restart_lab'),
            icon: Icons.restart_alt,
            color: _Colors.emerald600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
      ],
    );
  }

  /// HTML `closeSummary()`: once the Biology summary closes, the
  /// "select Physics" note shows for 8 s with a chime. Not after a full
  /// reset (which clears the completed scenarios).
  void _onLabChanged() {
    if (!_summaryOpen || _lab.popup != null) return;
    _summaryOpen = false;
    final s = _scene;
    if (_lab.isLabActive &&
        s.scenario == 0 &&
        _lab.completedScenarios.contains(0)) {
      _Sound.success.play();
      s.bannerAt = s.time;
    }
  }

  /// The HTML's own button: 'Observe Conclusion' (HTML
  /// `#compare-btn-container`) once the last step is done.
  List<LabAction> _actions() {
    final s = _scene;
    if (!s.conclusionReady || s.concluded) return const [];
    return [
      LabAction(
        label: _t('btn_conclude'),
        icon: Icons.lightbulb,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        highlight: true,
        silent: true,
        onTap: _conclude,
      ),
    ];
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
        final s = context.labScale;
        final p = _lab.palette;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final step = _scene.step;
        final actions = _actions();
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.biotech,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: step,
          hud: _hud,
          actions: actions,
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('steps_title'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-$step'),
            steps: _stepData,
            current: step,
            palette: p,
            scale: s,
            fontScale: f,
            stepLabel: _t('step_word'),
            taskLabel: _t('task_lbl'),
            actionLabel: _t('action_lbl'),
            resultLabel: _t('result_lbl'),
          ),
          overlays: _overlays(context, p, s, actions),
          stage: _stage(),
        );
      },
    );
  }

  /// The canvas cards: the Food panel (HTML `#s1-feeding-panel`, right),
  /// and at the bottom, above the HUD, 'Observe Conclusion' (HTML
  /// `#compare-btn-container`) and the time-lapse (HTML `#s1-time-slider`)
  /// or temperature slider (HTML `#s2-temp-slider`); at the top the
  /// next-scenario note (HTML `#observation-modal`).
  List<Widget> _overlays(
    BuildContext context,
    LabPalette p,
    double s,
    List<LabAction> actions,
  ) {
    final sc = _scene;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final open = _lab.isSidebarOpen;
    final active = _lab.isLabActive && sc.panelsReady;
    final above = open ? inset.bottom + _hudBand * s : inset.bottom;
    final showFood = active && sc.scenario == 0 && sc.step <= 2;
    final showLapse = active && sc.scenario == 0 && sc.step == 4;
    final showTemp = active && sc.scenario == 1 && sc.step <= 4;
    // While the sidebar is collapsed the mission card carries the button.
    final showButton =
        _lab.isLabActive && open && actions.isNotEmpty && _lab.popup == null;
    // On phones the collapsed mission card ends above the bottom panel, so
    // the panel may use the canvas's whole width.
    final bottomLeft = !open && screen.height < _compactBelow
        ? 8 + pad.left
        : inset.left;
    return [
      // Measures the canvas (full size, not movable).
      Positioned.fill(
        child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
      ),
      if (showFood)
        Positioned(
          key: const ValueKey('ch1a5-food'),
          right: inset.right,
          top: inset.top,
          bottom: above,
          child: Center(child: _foodPanel(p, s)),
        ),
      if (showButton || showLapse || showTemp)
        Positioned(
          key: const ValueKey('ch1a5-bottom'),
          left: bottomLeft,
          right: inset.right,
          bottom: above,
          child: Center(
            child: LayoutBuilder(
              builder: (context, box) => Column(
                key: _bottomKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showButton)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: showLapse || showTemp ? 8 * s : 0,
                      ),
                      child: _Bounce(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LabActionButton(
                            action: actions.first,
                            scale: s,
                            expand: false,
                          ),
                        ),
                      ),
                    ),
                  if (showLapse)
                    _lapseCard(p, s, math.min(box.maxWidth * 0.9, 448 * s)),
                  if (showTemp)
                    _tempCard(p, s, math.min(box.maxWidth * 0.92, 512 * s)),
                ],
              ),
            ),
          ),
        ),
      // HTML `#observation-modal` (the next-scenario note), below the top
      // edge; it takes no touches.
      Positioned.fill(
        child: IgnorePointer(
          child: ValueListenableBuilder<double>(
            valueListenable: _frame,
            builder: (context, time, _) {
              final at = sc.bannerAt;
              final e = at < 0 ? -1.0 : time - at;
              if (e < 0 || e >= _bannerSeconds) {
                return const SizedBox.shrink();
              }
              final show = math.min(e, _bannerSeconds - e) / _bannerFade;
              return Padding(
                padding: EdgeInsets.only(
                  top: inset.top + 48 * s,
                  left: inset.left,
                  right: inset.right,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _ObservationBanner(
                    heading: _lab.t('mission_obj'),
                    text: _t('select_next_sc_msg'),
                    palette: p,
                    scale: s,
                    progress: show.clamp(0.0, 1.0),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  /// HTML `#s1-feeding-panel`: "Food" over the leaf card the learner drags
  /// onto the caterpillar.
  Widget _foodPanel(LabPalette p, double s) {
    final title = _t('food_supply');
    final enabled = _canFeed;
    final card = _leafCardDp * s;
    Widget leaf({bool lifted = false, bool ghost = false}) =>
        _LeafCard(size: card, isDark: p.isDark, lifted: lifted, ghost: ghost);
    return LabGlassCard(
      key: _foodKey,
      palette: p,
      radius: 16,
      padding: EdgeInsets.all(12 * s),
      borderColor: _Colors.emerald500.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: labLetterSpacing(title, 1.1),
            ),
          ),
          SizedBox(height: 10 * s),
          Container(
            width: 80 * s,
            height: 80 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _Colors.emerald500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _Colors.emerald500.withValues(alpha: 0.2),
              ),
            ),
            child: Draggable<_LeafToken>(
              data: const _LeafToken(),
              maxSimultaneousDrags: enabled ? 1 : 0,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              onDragStarted: _onLeafDragStart,
              onDragEnd: (_) => _onLeafDragEnd(),
              onDraggableCanceled: (_, _) => _onLeafMissed(),
              // Centred on the finger (`.draggable-leaf:active` scale 1.1).
              feedback: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Material(
                  type: MaterialType.transparency,
                  child: leaf(lifted: true),
                ),
              ),
              // HTML: the leaf is back in the panel at once.
              childWhenDragging: leaf(ghost: true),
              child: Semantics(
                container: true,
                button: true,
                label: _t('lbl_leaf'),
                onTap: enabled ? _feed : null,
                child: leaf(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#s1-time-slider`: clock, "Time-Lapse", the percentage and the
  /// slider (0–100).
  Widget _lapseCard(LabPalette p, double s, double width) {
    final title = _t('time_lapse');
    final enabled = _lapseEnabled;
    return SizedBox(
      width: width,
      child: LabGlassCard(
        palette: p,
        radius: 16,
        padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 2 * s),
        child: ValueListenableBuilder<double>(
          valueListenable: _slider,
          builder: (context, v, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 15 * s, color: p.text),
                  SizedBox(width: 4 * s),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${v.round()}%',
                    style: TextStyle(
                      color: p.ink(_Colors.indigo500),
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              _RangeSlider(
                key: const ValueKey('ch1a5-lapse-slider'),
                label: title,
                value: v.clamp(0, _lapseMax).toDouble(),
                min: 0,
                max: _lapseMax,
                palette: p,
                scale: s,
                onChanged: enabled ? _onLapse : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HTML `#s2-temp-slider`: "Cooling" and "Heating" chips, the temperature
  /// (added) and the slider (-20 … 120 °C); the top border is blue below
  /// 0 °C, red above 80 °C, emerald between.
  Widget _tempCard(LabPalette p, double s, double width) {
    final enabled = _tempEnabled;
    return SizedBox(
      width: width,
      child: ValueListenableBuilder<double>(
        valueListenable: _slider,
        builder: (context, v, _) {
          final edge = v < _freezeAt
              ? _Colors.blue500
              : (v > _hotAbove ? _Colors.red500 : _Colors.emerald500);
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border),
              boxShadow: const [
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 4,
                  color: edge,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14 * s, 8 * s, 14 * s, 2 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: _TempChip(
                              text: _t('cooling'),
                              icon: _Glyph.cooling,
                              cold: true,
                              palette: p,
                              scale: s,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              labFormat(_t('temp_value'), {'t': v.round()}),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                color: p.ink(edge),
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Flexible(
                            child: _TempChip(
                              text: _t('heating'),
                              icon: _Glyph.heating,
                              cold: false,
                              palette: p,
                              scale: s,
                            ),
                          ),
                        ],
                      ),
                      _RangeSlider(
                        key: const ValueKey('ch1a5-temp-slider'),
                        label: _t('lbl_temperature'),
                        value: v.clamp(_tempMin, _tempMax).toDouble(),
                        min: _tempMin,
                        max: _tempMax,
                        palette: p,
                        scale: s,
                        onChanged: enabled ? _onTemp : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
          _fit = fit;
          _touch = _touchDp / fit;
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: DragTarget<_LeafToken>(
            onWillAcceptWithDetails: (_) => _canFeed,
            onAcceptWithDetails: (d) => _onLeafDrop(d.offset),
            builder: (context, _, _) => Stack(
              fit: StackFit.expand,
              children: [
                RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags on the scene are not screen-reader actions; the
                  // scene and its objects are announced instead.
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
                        key: _designKey,
                        size: _design,
                        painter: _ScenePainter(
                          scene: _scene,
                          cache: _cache,
                          repaint: _frame,
                          isDark: _lab.isDark,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelSize: _labelSize,
                          touch: _touch,
                        ),
                      ),
                    ),
                  ),
                ),
                // One semantics node for each object where it is drawn
                // (added), so a screen reader can find and tap them. They
                // take no touches: those reach the scene below.
                ValueListenableBuilder<int>(
                  valueListenable: _layout,
                  builder: (context, _, _) => _semanticsNodes(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _semanticsNodes() {
    final s = _scene;
    final cam = s.camera();
    Widget node(Rect rect, String label, {VoidCallback? onTap}) =>
        Positioned.fromRect(
          rect: rect,
          child: Semantics(
            container: true,
            button: onTap != null,
            label: label,
            onTap: onTap,
            child: const SizedBox.expand(),
          ),
        );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (s.scenario == 0) ...[
          node(s.twigRect(cam), _t('lbl_twig')),
          if (s.catVisible)
            node(
              s.catRect(cam),
              _t('lbl_caterpillar'),
              onTap: s.step == 3 ? _activateCaterpillar : null,
            ),
          if (s.flyVisible)
            node(
              s.flyRect(cam),
              _t('lbl_butterfly'),
              onTap: s.step == 5 && s.flightAt < 0 ? _activateButterfly : null,
            ),
        ] else ...[
          node(s.beakerRect(cam), _t('lbl_beaker')),
          node(s.thermoRect(cam), _t('lbl_thermometer')),
        ],
      ],
    );
  }
}

/// What a dragged leaf card carries (HTML `#draggable-leaf-1`).
@immutable
class _LeafToken {
  const _LeafToken();
}

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its task (concept), action and result (observation). The current step
/// is open, done steps show a tick and can be re-opened, future steps are
/// dimmed.
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
    required this.actionLabel,
    required this.resultLabel,
  });

  final List<_StepInfo> steps;
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
    // Future steps: dimmed, closed.
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  _heading(w.taskLabel, accent),
                  SizedBox(height: 3 * s),
                  _body(step.task, p.textStrong),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.action, p.text),
                  SizedBox(height: 8 * s),
                  _heading(w.resultLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  _body(step.result, p.textMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// HTML `#draggable-leaf-1`: a white (dark: slate-800) card with the
/// emerald leaf icon; lifted (`:active`) it grows 1.1x with a deeper
/// shadow; while it is dragged its place in the panel stays faint.
class _LeafCard extends StatelessWidget {
  const _LeafCard({
    required this.size,
    required this.isDark,
    this.lifted = false,
    this.ghost = false,
  });

  final double size;
  final bool isDark;
  final bool lifted;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: isDark ? _Colors.slate800 : _Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? _Colors.slate700 : _Colors.slate200),
        boxShadow: [
          BoxShadow(
            color: LabInk.black.withValues(alpha: lifted ? 0.3 : 0.12),
            blurRadius: lifted ? 25 : 6,
            offset: Offset(0, lifted ? 10 : 3),
          ),
        ],
      ),
      child: const CustomPaint(painter: _GlyphPainter(_Glyph.leaf)),
    );
    if (ghost) return Opacity(opacity: 0.25, child: card);
    return lifted ? Transform.scale(scale: 1.1, child: card) : card;
  }
}

/// The HTML's inline SVG icons (Material Design Icons, 24 x 24 view box).
enum _Glyph {
  /// The Food panel's leaf.
  leaf,

  /// 'Cooling' (a ring around a square).
  cooling,

  /// 'Heating' (a flame).
  heating,
}

/// Paths of the [_Glyph] icons in their 24 x 24 view box (made once).
abstract final class _GlyphArt {
  /// `M17,8C8,10 5.9,16.17 3.82,21.34L5.71,22L6.66,19.7C7.14,19.87 7.64,20
  /// 8,20C19,20 22,3 22,3C21,5 14,5.25 9,6.25C4,7.25 2,11.5 2,13.5C2,15.5
  /// 3.75,17.25 3.75,17.25C7,8 17,8 17,8Z`.
  static final Path leaf = Path()
    ..moveTo(17, 8)
    ..cubicTo(8, 10, 5.9, 16.17, 3.82, 21.34)
    ..lineTo(5.71, 22)
    ..lineTo(6.66, 19.7)
    ..cubicTo(7.14, 19.87, 7.64, 20, 8, 20)
    ..cubicTo(19, 20, 22, 3, 22, 3)
    ..cubicTo(21, 5, 14, 5.25, 9, 6.25)
    ..cubicTo(4, 7.25, 2, 11.5, 2, 13.5)
    ..cubicTo(2, 15.5, 3.75, 17.25, 3.75, 17.25)
    ..cubicTo(7, 8, 17, 8, 17, 8)
    ..close();

  /// A ring (r 10 / 8) around a 4 x 4 square.
  static final Path cooling = Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10))
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8))
    ..addRect(const Rect.fromLTRB(10, 10, 14, 14));

  /// `M17.5,11.39C16.09,10 14,8.69 13.5,5.69C12.55,10.19 8.5,10.69
  /// 7.5,14.69C6.88,17.19 8.81,19.5 11.25,19.93C14.06,20.44 16.5,18.5
  /// 17.5,15.81C18.25,13.75 18,12 17.5,11.39M12,18C10.5,18 9.5,16.5 10,15
  /// C10.36,13.88 11.66,13.06 12,11.5C12.69,13.84 14.5,14.41 14.5,16
  /// C14.5,17.1 13.3,18 12,18Z`.
  static final Path heating = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(17.5, 11.39)
    ..cubicTo(16.09, 10, 14, 8.69, 13.5, 5.69)
    ..cubicTo(12.55, 10.19, 8.5, 10.69, 7.5, 14.69)
    ..cubicTo(6.88, 17.19, 8.81, 19.5, 11.25, 19.93)
    ..cubicTo(14.06, 20.44, 16.5, 18.5, 17.5, 15.81)
    ..cubicTo(18.25, 13.75, 18, 12, 17.5, 11.39)
    ..close()
    ..moveTo(12, 18)
    ..cubicTo(10.5, 18, 9.5, 16.5, 10, 15)
    ..cubicTo(10.36, 13.88, 11.66, 13.06, 12, 11.5)
    ..cubicTo(12.69, 13.84, 14.5, 14.41, 14.5, 16)
    ..cubicTo(14.5, 17.1, 13.3, 18, 12, 18)
    ..close();
}

/// A [_Glyph] filling its box: the leaf in emerald-500 (`fill-emerald-500`),
/// the others in [color] (`fill-current`).
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph, [this.color = _Colors.emerald500]);

  final _Glyph glyph;
  final Color color;

  static final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final path = switch (glyph) {
      _Glyph.leaf => _GlyphArt.leaf,
      _Glyph.cooling => _GlyphArt.cooling,
      _Glyph.heating => _GlyphArt.heating,
    };
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(path, _fill..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}

/// The temperature panel's 'Cooling' (blue, icon first) and 'Heating'
/// (red, icon last) chips.
class _TempChip extends StatelessWidget {
  const _TempChip({
    required this.text,
    required this.icon,
    required this.cold,
    required this.palette,
    required this.scale,
  });

  final String text;
  final _Glyph icon;
  final bool cold;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final dark = palette.isDark;
    final ink = cold
        ? (dark ? _Colors.blue400 : _Colors.blue600)
        : (dark ? _Colors.red400 : _Colors.red600);
    final bg = cold
        ? (dark ? _Colors.blue900.withValues(alpha: 0.4) : _Colors.blue100)
        : (dark ? _Colors.red900.withValues(alpha: 0.4) : _Colors.red100);
    final glyph = SizedBox(
      width: 18 * s,
      height: 18 * s,
      child: CustomPaint(painter: _GlyphPainter(icon, ink)),
    );
    final label = Flexible(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ink,
          fontSize: 12.5 * s,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: cold
            ? [glyph, SizedBox(width: 6 * s), label]
            : [label, SizedBox(width: 6 * s), glyph],
      ),
    );
  }
}

/// HTML `input[type=range].custom-slider`: an 8 px slate track and a white
/// 32 px thumb with an indigo ring that grows 1.2x while held.
class _RangeSlider extends StatelessWidget {
  const _RangeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.palette,
    required this.scale,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final LabPalette palette;
  final double scale;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final track = palette.isDark ? _Colors.slate700 : _Colors.slate300;
    return Semantics(
      label: label,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 8 * s,
          activeTrackColor: track,
          inactiveTrackColor: track,
          disabledActiveTrackColor: track.withValues(alpha: 0.6),
          disabledInactiveTrackColor: track.withValues(alpha: 0.6),
          trackShape: const RoundedRectSliderTrackShape(),
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: _RingThumb(radius: 14 * s),
          overlayColor: _Colors.indigo500.withValues(alpha: 0.16),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 22 * s),
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// The custom slider's thumb: white disc, indigo-500 ring, soft shadow;
/// 1.2x while held (`:active`).
class _RingThumb extends SliderComponentShape {
  const _RingThumb({required this.radius});

  final double radius;

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
    final canvas = context.canvas;
    final r = radius * (1 + 0.2 * activationAnimation.value);
    final ring = Color.lerp(
      _Colors.slate400,
      _Colors.indigo500,
      enableAnimation.value,
    )!;
    canvas
      ..drawCircle(
        center + const Offset(0, 2),
        r,
        Paint()
          ..color = LabInk.shadow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(center, r, Paint()..color = _Colors.white)
      ..drawCircle(
        center,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ring,
      );
  }
}

/// Tailwind `animate-bounce` (HTML 'Observe Conclusion'): up a quarter of
/// its height and back every second.
class _Bounce extends StatefulWidget {
  const _Bounce({required this.child});

  final Widget child;

  @override
  State<_Bounce> createState() => _BounceState();
}

class _BounceState extends State<_Bounce> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  /// `translateY(-25%)` at 0 % and 100 % (`cubic-bezier(0.8, 0, 1, 1)`
  /// down), none at 50 % (`cubic-bezier(0, 0, 0.2, 1)` up).
  static const Cubic _down = Cubic(0.8, 0, 1, 1);
  static const Cubic _up = Cubic(0, 0, 0.2, 1);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        final rise = t < 0.5
            ? 1 - _down.transform(t * 2)
            : _up.transform(t * 2 - 1);
        return FractionalTranslation(
          translation: Offset(0, -0.25 * rise),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// HTML `#observation-modal`: an emerald-to-teal tab with an eye and the
/// heading over a card with a teal border and the note; [progress] fades
/// and slides it in and out.
class _ObservationBanner extends StatelessWidget {
  const _ObservationBanner({
    required this.heading,
    required this.text,
    required this.palette,
    required this.scale,
    required this.progress,
  });

  final String heading;
  final String text;
  final LabPalette palette;
  final double scale;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - progress)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 512 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * s,
                      vertical: 6 * s,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_Colors.emerald500, _Colors.teal500],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16 * s,
                          color: _Colors.white,
                        ),
                        SizedBox(width: 6 * s),
                        Flexible(
                          child: Text(
                            heading.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _Colors.white,
                              fontSize: 11.5 * s,
                              fontWeight: FontWeight.w900,
                              letterSpacing: labLetterSpacing(heading, 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * s,
                      vertical: 12 * s,
                    ),
                    decoration: BoxDecoration(
                      color: p.isDark ? _Colors.slate900 : _Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _Colors.teal500, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: LabInk.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.isDark ? _Colors.slate200 : _Colors.slate800,
                        fontSize: 13.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
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

/// The summary popup's body: the HTML `#summary-modal` (Scenario 1: a
/// lightbulb, "Life Cycle Observed!", the summary with "Biologists" in
/// bold, and the emerald "select Physics" note) or `#success-modal`
/// (Scenario 2: a trophy, "State Change Observed!", the summary with
/// "Physicists" in bold, and the mastery text).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.scenario,
    required this.palette,
    required this.scale,
    required this.head,
    required this.text,
    required this.bold,
    required this.note,
  });

  final int scenario;
  final LabPalette palette;
  final double scale;
  final String head;
  final String text;

  /// The word of [text] set in bold (the HTML `<b>`).
  final String bold;
  final String note;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final first = scenario == 0;
    final badge = first ? _Colors.indigo400 : _Colors.yellow400;
    final style = TextStyle(
      color: p.text,
      fontSize: 13 * s,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
    final at = bold.isEmpty ? -1 : text.indexOf(bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.withValues(alpha: 0.2),
              border: Border.all(color: badge.withValues(alpha: 0.3)),
            ),
            child: Icon(
              first ? Icons.lightbulb : Icons.emoji_events,
              size: 28 * s,
              color: p.ink(badge),
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          head,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.ink(first ? _Colors.emerald400 : _Colors.blue400),
            fontSize: 17 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6 * s),
        Text.rich(
          TextSpan(
            style: style,
            children: at < 0
                ? [TextSpan(text: text)]
                : [
                    TextSpan(text: text.substring(0, at)),
                    TextSpan(
                      text: bold,
                      style: TextStyle(
                        color: p.textStrong,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(text: text.substring(at + bold.length)),
                  ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: first ? _Colors.emerald500.withValues(alpha: 0.1) : p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: first
                  ? _Colors.emerald500.withValues(alpha: 0.2)
                  : p.cardBorder,
            ),
          ),
          child: Text(
            note,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: first ? p.ink(_Colors.emerald400) : p.text,
              fontSize: 13 * s,
              fontWeight: first ? FontWeight.w700 : FontWeight.w500,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================== PAINTING

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();

  /// Fills with a gradient (the leaf, the wings).
  final Paint shaded = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Butt-ended strokes: shading bands, dashes, outlines.
  final Paint band = Paint()..style = PaintingStyle.stroke;

  /// The coil's glow and the drag badge's shadow.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  /// Soft steam puffs.
  final Paint steam = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  final Path path = Path();
  final Path aux = Path();
}

/// [c] lit by [k] (ambient plus key light, MeshStandardMaterial look),
/// clamped.
Color _lum(Color c, double k) => Color.from(
  alpha: c.a,
  red: math.min(1.0, c.r * k),
  green: math.min(1.0, c.g * k),
  blue: math.min(1.0, c.b * k),
);

/// The HTML lights on a face with normal [n].
Color _lit(Color c, _V n) =>
    _lum(c, _ambient + _diffuse * math.max(0.0, n.dot(_light)));

/// What the painter makes once and reuses: pens, the shaded-ball shaders
/// (one per colour, drawn on a unit circle) and the text painters. Owned
/// by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  final Map<int, Paint> _balls = {};
  TextPainter? _pill;
  String _pillKey = '';
  TextPainter? _hand;
  double _handSize = 0;
  LabLang? _lang;
  double _labelSize = _labelPx;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeTexts();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.chipText,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Size of a label chip with [text].
  Size chipSize(String text) {
    final a = label(text);
    return Size(
      a.width + 2 * _chipPadX * _labelSize,
      a.height + 2 * _chipPadY * _labelSize,
    );
  }

  /// The drop zone's "Drop Leaf Here" text (indigo, bold).
  TextPainter pill(String text) {
    final key = '$text|$_labelSize';
    if (_pill == null || key != _pillKey) {
      _pill?.dispose();
      _pillKey = key;
      _pill = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: _Colors.indigo500,
            fontSize: _labelSize * 1.15,
            fontWeight: FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    return _pill!;
  }

  /// The drag badge's hand icon (`ph-hand-grabbing`) at [size].
  TextPainter hand(double size) {
    if (_hand == null || (size - _handSize).abs() > 0.5) {
      _hand?.dispose();
      _handSize = size;
      const icon = Icons.pan_tool;
      _hand = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: _Colors.indigo600,
            fontSize: size,
            height: 1,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    return _hand!;
  }

  /// MeshStandardMaterial look for a sphere of [c] under the HTML lights:
  /// a radial gradient on a unit circle (lit from the upper right).
  Paint ball(Color c) => _balls[c.toARGB32()] ??= Paint()
    ..shader = ui.Gradient.radial(
      const Offset(0.3, -0.4),
      1.4,
      [_lum(c, 1.4), _lum(c, 1.15), _lum(c, 0.75)],
      const [0, 0.45, 1],
    );

  void _disposeTexts() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
    _pill?.dispose();
    _pill = null;
  }

  void dispose() {
    _disposeTexts();
    _hand?.dispose();
    _hand = null;
    _balls.clear();
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

/// Index of a box corner with signs [c] (bit 0 x, bit 1 y, bit 2 z).
int _corner(_V c) => (c.x > 0 ? 1 : 0) | (c.y > 0 ? 2 : 0) | (c.z > 0 ? 4 : 0);

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Cam cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  void move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat polygon (already lit [color]).
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      move(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// Flat quad (already lit [color]).
  void quad(_V a, _V b, _V c, _V d, Color color) => poly([a, b, c, d], color);

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(_V c, _V size, Color color, {double edge = 0.3}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        move(
          path,
          i,
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
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

  /// A shaded ellipse of radii [rx] x [ry] design px at [p], turned by
  /// [angle] on screen.
  void blobPx(Offset p, double rx, double ry, Color color, {double angle = 0}) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    if (angle != 0) canvas.rotate(angle);
    canvas.scale(math.max(0.01, rx), math.max(0.01, ry));
    canvas.drawCircle(Offset.zero, 1, cache.ball(color));
    canvas.restore();
  }

  /// SphereGeometry of radius [r] at [c].
  void ball(_V c, double r, Color color) {
    final k = cam.scaleAt(c);
    blobPx(cam.p(c), r * k, r * k, color);
  }

  /// A small flat dot (MeshBasicMaterial: eyes, bubbles).
  void dot(_V c, double r, Color color) => canvas.drawCircle(
    cam.p(c),
    math.max(0.8, r * cam.scaleAt(c)),
    pens.fill..color = color,
  );

  /// A limb (tapered CylinderGeometry with rounded ends) from [a] to [b]
  /// with radii [ra] and [rb]: body, shaded side and highlight.
  void limb(_V a, _V b, double ra, double rb, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.6, ra * cam.scaleAt(a));
    final wb = math.max(0.6, rb * cam.scaleAt(b));
    final fill = pens.fill..color = color;
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) {
      canvas.drawCircle(pa, math.max(wa, wb), fill);
      return;
    }
    final n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawCircle(pa, wa, fill);
    canvas.drawCircle(pb, wb, fill);
    // The key light comes from the upper right of the screen.
    var lit = n;
    if (lit.dy > 0 || (lit.dy == 0 && lit.dx < 0)) lit = -lit;
    final w = (wa + wb) / 2;
    canvas.drawLine(
      pa - lit * (wa * 0.55),
      pb - lit * (wb * 0.55),
      pens.band
        ..strokeWidth = w * 0.7
        ..color = labShade(color, -0.2),
    );
    canvas.drawLine(
      pa + lit * (wa * 0.45),
      pb + lit * (wb * 0.45),
      pens.band
        ..strokeWidth = w * 0.3
        ..color = labShade(color, 0.28),
    );
  }

  /// A rod's silhouette without its ends, flat (MeshBasicMaterial).
  void flatRod(_Rod rod, Color color) {
    final pa = cam.p(rod.a), pb = cam.p(rod.b);
    final wa = rod.ra * cam.scaleAt(rod.a);
    final wb = rod.rb * cam.scaleAt(rod.b);
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    final n = Offset(-d.dy / len, d.dx / len);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A straight line [width] world units wide.
  void line(_V a, _V b, double width, Color color) => canvas.drawLine(
    cam.p(a),
    cam.p(b),
    pens.band
      ..strokeWidth = math.max(0.8, width * cam.scaleAt(a))
      ..color = color,
  );

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

  /// A solid upright cylinder of radius [r] and height [h] on [bottom]
  /// with its top cap.
  void cylinder(_V bottom, double r, double h, Color color) {
    frustumPath(pens.path, bottom, r, r, h);
    canvas.drawPath(
      pens.path,
      pens.fill..color = _lit(color, const _V(0, 0, 1)),
    );
    final top = cam.oval(bottom + _V(0, h, 0), r);
    canvas.drawOval(top, pens.fill..color = _lit(color, _V.up));
    canvas.drawOval(
      top,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.4).withValues(alpha: 0.6),
    );
  }

  /// `RingGeometry(inner, outer)` lying flat at [c].
  void ring(_V c, double inner, double outer, Color color) {
    final path = pens.path
      ..reset()
      ..fillType = PathFillType.evenOdd
      ..addOval(cam.oval(c, outer))
      ..addOval(cam.oval(c, inner));
    canvas.drawPath(path, pens.fill..color = color);
    path.fillType = PathFillType.nonZero;
  }

  /// A short cylinder of radius [r] whose axis is the z axis (a knob on a
  /// front face), front cap at [front].
  void disc(_V front, double r, double depth, Color color) {
    Rect cap(_V c) {
      final p = cam.p(c);
      final rx = (cam.p(c + _V(r, 0, 0)).dx - p.dx).abs();
      final ry = (cam.p(c + _V(0, r, 0)).dy - p.dy).abs();
      return Rect.fromCenter(center: p, width: 2 * rx, height: 2 * ry);
    }

    final back = cap(front - _V(0, 0, depth));
    final near = cap(front);
    canvas.drawOval(back, pens.fill..color = _lit(color, const _V(0, -1, 0)));
    canvas.drawRect(
      Rect.fromLTRB(near.left, back.center.dy, near.right, near.center.dy),
      pens.fill,
    );
    canvas.drawOval(near, pens.fill..color = _lit(color, const _V(0, 0, 1)));
  }

  /// Water standing [h] high on [bottom] in a cylinder of radius [r]: the
  /// body and its lighter surface.
  void liquid(_V bottom, double r, double h, Color color, double opacity) {
    if (h <= 0.01 || opacity <= 0.01) return;
    frustumPath(pens.path, bottom, r, r, h);
    canvas.drawPath(
      pens.path,
      pens.fill
        ..color = _lit(color, const _V(0, 0, 1)).withValues(alpha: opacity),
    );
    canvas.drawOval(
      cam.oval(bottom + _V(0, h, 0), r),
      pens.fill..color = labShade(color, 0.3).withValues(alpha: opacity),
    );
  }

  /// The far half of an open glass cylinder: its outline filled faintly
  /// (both walls are seen through each other) and its base.
  void glassBack(_V bottom, double r, double h, Color fill) {
    frustumPath(pens.path, bottom, r, r, h);
    canvas.drawPath(pens.path, pens.fill..color = fill);
  }

  /// The near half of an open glass cylinder: its side lines, the front of
  /// its base, the rim and a highlight.
  void glassFront(_V bottom, double r, double h, Color edge) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = r * cam.scaleAt(bottom), wt = r * cam.scaleAt(top);
    final outline = pens.aux
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(cam.oval(bottom, r), math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy);
    canvas.drawPath(
      outline,
      pens.stroke
        ..strokeWidth = 1.4
        ..color = edge,
    );
    canvas.drawOval(
      cam.oval(top, r),
      pens.stroke
        ..strokeWidth = 1.6
        ..color = edge,
    );
    // Glass highlight on the left.
    canvas.drawLine(
      Offset(pt.dx - wt * 0.62, pt.dy + 6),
      Offset(pb.dx - wb * 0.62, pb.dy - 4),
      pens.stroke
        ..strokeWidth = math.max(1.0, wb * 0.1)
        ..color = _Colors.white.withValues(alpha: 0.55),
    );
  }
}

/// The HTML `getButterflyWingTexture()` canvas (512 x 512): the wing
/// outline, its veins and the white dots along its black border (made
/// once).
abstract final class _WingArt {
  static final Path outline = Path()
    ..moveTo(20, 256)
    ..cubicTo(20, 20, 460, 20, 490, 200)
    ..cubicTo(500, 400, 300, 490, 100, 450)
    ..close();

  static final Path veins = () {
    final p = Path();
    for (final t in const [
      Offset(350, 50),
      Offset(450, 120),
      Offset(480, 220),
      Offset(420, 350),
      Offset(300, 450),
      Offset(150, 470),
    ]) {
      p
        ..moveTo(20, 256)
        ..lineTo(t.dx, t.dy);
    }
    return p
      ..moveTo(200, 120)
      ..lineTo(300, 250)
      ..moveTo(350, 180)
      ..lineTo(400, 300)
      ..moveTo(150, 350)
      ..lineTo(250, 420);
  }();

  /// `setLineDash([5, 25])` along the outline.
  static final Path dots = () {
    final p = Path();
    for (final m in outline.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 30) {
        p.addPath(m.extractPath(d, math.min(d + 5, m.length)), Offset.zero);
      }
    }
    return p;
  }();
}

/// The HTML `getLeafTexture()` canvas (512 x 512): the leaf outline (two
/// quadratic curves, sampled) and its veins (made once).
abstract final class _LeafArt {
  static final List<Offset> outline = () {
    Offset q(Offset a, Offset b, Offset c, double t) =>
        a * ((1 - t) * (1 - t)) + b * (2 * (1 - t) * t) + c * (t * t);
    const n = 24;
    return [
      for (var i = 0; i < n; i++)
        q(
          const Offset(256, 10),
          const Offset(500, 256),
          const Offset(256, 500),
          i / n,
        ),
      for (var i = 0; i < n; i++)
        q(
          const Offset(256, 500),
          const Offset(12, 256),
          const Offset(256, 10),
          i / n,
        ),
    ];
  }();

  /// The midrib and the pairs from (256, y) to (256 ± (150 - y / 4),
  /// y - 60), y = 50, 90 … 450.
  static final List<(Offset, Offset)> veins = [
    (const Offset(256, 10), const Offset(256, 500)),
    for (var y = 50.0; y < 480; y += 40) ...[
      (Offset(256, y), Offset(256 + 150 - y / 4, y - 60)),
      (Offset(256, y), Offset(256 - 150 + y / 4, y - 60)),
    ],
  ];

  /// The world point of texture px ([cx], [cy]) on the drooping leaf.
  static _V point(double cx, double cy) {
    final lx = cx / _texSize * 2 * _leafHalf - _leafHalf;
    final ly = _leafHalf - cy / _texSize * 2 * _leafHalf;
    final droop = (lx / _leafHalf) * (lx / _leafHalf) * _leafDroop;
    return _V(_leafCenter.x + lx, _leafCenter.y - droop, _leafCenter.z - ly);
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the garden
/// (ground, big leaf, twig, caterpillar, chrysalis, butterfly), S2 the lab
/// bench (hotplate, beaker of water, thermometer); then the labels, the
/// drop zone, the drag badge and the confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.touch,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// A touch radius in design px (24 screen px).
  final double touch;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.camera(), cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = s.scenario == 0 ? _Colors.sky : _Colors.labSky,
    );
    if (s.scenario == 0) {
      _paintGarden(g);
    } else {
      _paintBench(g);
    }
    if (showLabels) _paintLabels(g);
    if (s.scenario == 0 && s.panelsReady && s.step <= 2) _paintDropZone(g);
    if (s.catHeld) _paintDragBadge(g, size);
    _paintConfetti(canvas);
  }

  // ---------------------------------------------------------- scenario 1

  void _paintGarden(_Gfx g) {
    final s = scene;
    g.quad(
      const _V(-_groundHalfX, _groundY, -_groundHalfZ),
      const _V(_groundHalfX, _groundY, -_groundHalfZ),
      const _V(_groundHalfX, _groundY, _groundHalfZ),
      const _V(-_groundHalfX, _groundY, _groundHalfZ),
      _lit(_Colors.ground, _V.up),
    );
    _paintLeaf(g);
    _paintTwig(g);
    if (s.chrysVisible) _paintChrysalis(g);
    if (s.catVisible) _paintCaterpillar(g);
    if (s.flyVisible) _paintButterfly(g);
  }

  /// The big leaf platform: its texture (gradient, veins, dark edge) on the
  /// drooping plane.
  void _paintLeaf(_Gfx g) {
    final cam = g.cam;
    final canvas = g.canvas;
    final path = _pens.path..reset();
    final outline = _LeafArt.outline;
    for (var i = 0; i < outline.length; i++) {
      final o = outline[i];
      g.move(path, i, cam.p(_LeafArt.point(o.dx, o.dy)));
    }
    path.close();
    final light = _ambient + _diffuse * _light.y;
    canvas.drawPath(
      path,
      _pens.shaded
        ..shader = ui.Gradient.linear(
          cam.p(_LeafArt.point(256, 0)),
          cam.p(_LeafArt.point(256, _texSize)),
          [_lum(_Colors.leafLight, light), _lum(_Colors.leafDark, light)],
        ),
    );
    final ink = _lum(_Colors.leafVein, light);
    const unit = 2 * _leafHalf / _texSize; // world units per texture px
    canvas
      ..save()
      ..clipPath(path);
    final vein = _pens.aux;
    for (final (a, b) in _LeafArt.veins) {
      vein.reset();
      for (var j = 0; j <= 4; j++) {
        final o = Offset.lerp(a, b, j / 4)!;
        g.move(vein, j, cam.p(_LeafArt.point(o.dx, o.dy)));
      }
      final mid = Offset.lerp(a, b, 0.5)!;
      final k = cam.scaleAt(_LeafArt.point(mid.dx, mid.dy));
      canvas.drawPath(
        vein,
        _pens.band
          ..strokeWidth = math.max(0.8, 8 * unit * k)
          ..color = ink,
      );
    }
    canvas.restore();
    canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = math.max(1.0, 12 * unit * cam.scaleAt(_leafCenter))
        ..color = ink,
    );
  }

  /// `twigMesh`: the glowing aura (behind), the stem and two branches.
  void _paintTwig(_Gfx g) {
    final glow = scene.auraAlpha;
    if (glow > 0.01) {
      g.flatRod(_twigAura, _Colors.aura.withValues(alpha: glow));
    }
    final color = _lum(_Colors.twig, 1.15);
    for (final rod in _twigRods) {
      g.limb(rod.a, rod.b, rod.ra, rod.rb, color);
    }
  }

  /// `caterpillarGroup`: ten striped segments (the head on the left with
  /// eyes and antennae), six pairs of legs; it grows and wiggles.
  void _paintCaterpillar(_Gfx g) {
    final s = scene;
    final k = s.catK;
    final base = s.catNow;
    _V at(double x, double y, double z) => base + _V(x, y, z) * k;
    double radius(int i) => 0.4 - (i - 4).abs() * 0.03;
    double segX(int i) => _segStart + i * _segGap;
    const colors = [
      _Colors.catGreen,
      _Colors.catDark,
      _Colors.catYellow,
      _Colors.catDark,
    ];
    const legHalf = 0.15 * 0.7071;
    // Legs `CylinderGeometry(0.04, 0.02, 0.3)` at (0, -r, ±0.2), tilted
    // ±π/4: [side] -1 behind the body, 1 in front of it.
    void legs(double side) {
      for (var i = 2; i <= 7; i++) {
        final x = segX(i);
        final y = s.wiggle(i) - radius(i);
        final z = side * 0.2;
        g.limb(
          at(x, y - legHalf, z - side * legHalf),
          at(x, y + legHalf, z + side * legHalf),
          0.02 * k,
          0.04 * k,
          _Colors.catDark,
        );
      }
    }

    final headY = s.wiggle(0);
    // Antennae `CylinderGeometry(0.02, 0.02, 0.4)` at (-0.2, 0.4, ±0.15),
    // turned (±π/4, 0, π/4); eyes r 0.08 at (-0.3, 0.2, ±0.2).
    void antenna(double side) {
      const h = 0.2;
      g.limb(
        at(
          -1.5 - 0.2 + 0.7071 * h,
          headY + 0.4 - 0.5 * h,
          side * (0.15 - 0.5 * h),
        ),
        at(
          -1.5 - 0.2 - 0.7071 * h,
          headY + 0.4 + 0.5 * h,
          side * (0.15 + 0.5 * h),
        ),
        0.02 * k,
        0.02 * k,
        _Colors.catDark,
      );
    }

    void eye(double side) =>
        g.dot(at(-1.5 - 0.3, headY + 0.2, side * 0.2), 0.08 * k, _Colors.eye);

    legs(-1);
    antenna(-1);
    eye(-1);
    for (var i = _catSegments - 1; i >= 0; i--) {
      g.ball(at(segX(i), s.wiggle(i), 0), radius(i) * k, colors[i % 4]);
    }
    // The head: a green sphere 1.1x the first segment.
    g.ball(at(segX(0), headY, 0), radius(0) * 1.1 * k, _Colors.catGreen);
    legs(1);
    eye(1);
    antenna(1);
  }

  /// `chrysalisMesh`: the green, stretched body with its golden spots and
  /// the dark stalk that holds it to the twig; it pops in and wiggles.
  void _paintChrysalis(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final k = s.chrysK;
    final tilt = s.chrysTilt;
    _V at(_V local) => _chrysPos + _rotZ(local * k, tilt);
    final c = at(_V.zero);
    final pc = cam.p(c);
    final down = cam.p(at(const _V(0, -1, 0))) - pc;
    final angle = math.atan2(down.dy, down.dx) - math.pi / 2;
    final spots = [
      for (var i = 0; i < 6; i++)
        _V(
          math.cos(i * math.pi / 3) * _chrysR,
          0.5,
          math.sin(i * math.pi / 3) * _chrysR,
        ),
    ];
    for (final spot in spots) {
      if (spot.z < 0) g.ball(at(spot), _spotR * k, _Colors.gold);
    }
    g.blobPx(
      pc,
      _chrysR * k * cam.scaleAt(c),
      _chrysR * _chrysStretch * down.distance,
      _Colors.chrysalis,
      angle: angle,
    );
    for (final spot in spots) {
      if (spot.z >= 0) g.ball(at(spot), _spotR * k, _Colors.gold);
    }
    g.limb(
      at(const _V(0, 1.1, 0)),
      at(const _V(0, 1.7, 0)),
      0.2 * k,
      0.05 * k,
      _Colors.stalk,
    );
  }

  /// `butterflyGroup`: the dark body, head and antennae and the two
  /// textured wings flapping on their hinges, drawn far to near.
  void _paintButterfly(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final k = s.flyK;
    final pos = s.flyPos;
    final (right, up, forward) = s.flyAxes;
    _V at(double x, double y, double z) =>
        pos + (right * x + up * y + forward * z) * k;
    final a = s.flap;
    final ca = math.cos(a), sa = math.sin(a);
    // A wing's texture px ([cx], [cy]) on side [side] (-1 left, 1 right):
    // `PlaneGeometry(4, 4)` laid flat beside its hinge (the texture's top,
    // the wing tip, towards the head as on the HTML's left wing; the right
    // wing mirrors it), turned by the flap.
    _V wing(double side, double cx, double cy) {
      final u = cx / _texSize * 4;
      final v = 2 - cy / _texSize * 4;
      return at(side * (_hingeX + u * ca), u * sa, v);
    }

    void drawWing(double side) {
      final o = cam.p(wing(side, 0, 0));
      final ex = (cam.p(wing(side, _texSize, 0)) - o) / _texSize;
      final ey = (cam.p(wing(side, 0, _texSize)) - o) / _texSize;
      var n = (right * (side * ca) + up * sa).cross(forward);
      if (n.dot(cam.eye - pos) < 0) n = -n;
      final light = _ambient + _diffuse * math.max(0.0, n.unit.dot(_light));
      _paintWing(g.canvas, o, ex, ey, light);
    }

    void drawBody() {
      g.limb(at(0, 0, -0.75), at(0, 0, 0.75), 0.2 * k, 0.2 * k, _Colors.body);
      for (final side in const [-1.0, 1.0]) {
        // Antenna `CylinderGeometry(0.01, 0.02, 0.6)` on the head.
        const h = 0.3;
        g.limb(
          at(side * (0.1 - 0.5 * h), -0.2 + 0.433 * h, 1.2 - 0.75 * h),
          at(side * (0.1 + 0.5 * h), -0.2 - 0.433 * h, 1.2 + 0.75 * h),
          0.02 * k,
          0.01 * k,
          _Colors.body,
        );
      }
      g.ball(at(0, 0, 0.9), 0.3 * k, _Colors.body);
    }

    final parts = <(double, VoidCallback)>[
      (cam.depth(wing(-1, 256, 256)), () => drawWing(-1)),
      (cam.depth(wing(1, 256, 256)), () => drawWing(1)),
      (cam.depth(pos), drawBody),
    ]..sort((x, y) => y.$1.compareTo(x.$1));
    for (final (_, draw) in parts) {
      draw();
    }
  }

  /// One wing texture mapped by the affine frame [o], [ex], [ey] (screen
  /// offsets per texture px), lit by [light].
  void _paintWing(Canvas canvas, Offset o, Offset ex, Offset ey, double light) {
    if ((ex.dx * ey.dy - ex.dy * ey.dx).abs() < 1e-6) return;
    final frame = Matrix4(
      ex.dx,
      ex.dy,
      0,
      0, //
      ey.dx,
      ey.dy,
      0,
      0, //
      0,
      0,
      1,
      0, //
      o.dx,
      o.dy,
      0,
      1, //
    );
    final ink = _lum(_Colors.wingInk, light);
    canvas
      ..save()
      ..transform(frame.storage)
      ..drawPath(
        _WingArt.outline,
        _pens.shaded
          ..shader = ui.Gradient.linear(
            Offset.zero,
            const Offset(_texSize, _texSize),
            [_lum(_Colors.wingLight, light), _lum(_Colors.wingDark, light)],
          ),
      )
      ..save()
      ..clipPath(_WingArt.outline)
      ..drawPath(
        _WingArt.veins,
        _pens.stroke
          ..strokeWidth = 8
          ..color = ink,
      )
      ..restore()
      ..drawPath(
        _WingArt.outline,
        _pens.band
          ..strokeWidth = 35
          ..color = ink,
      )
      ..drawPath(
        _WingArt.dots,
        _pens.band
          ..strokeWidth = 6
          ..color = _Colors.white,
      )
      ..restore();
  }

  // ---------------------------------------------------------- scenario 2

  void _paintBench(_Gfx g) {
    final s = scene;
    g.box(_benchPos, _benchSize, _Colors.bench, edge: 0.4);
    g.box(_plateBasePos, _plateBaseSize, _Colors.hotplate, edge: 0.6);
    g.disc(_knobPos, _knobR, 0.2, _Colors.knob);
    g.cylinder(
      const _V(0, _plateY - _plateH / 2, 0),
      _plateR,
      _plateH,
      _Colors.plate,
    );
    final coil = s.coilAlpha;
    if (coil > 0.01) {
      const at = _V(0, _coilY, 0);
      g.canvas.drawOval(
        g.cam.oval(at, _coilOut + 0.3),
        _pens.glow..color = _Colors.coil.withValues(alpha: 0.35 * coil),
      );
      g.ring(at, _coilIn, _coilOut, _Colors.coil.withValues(alpha: coil));
    }
    _paintThermometer(g);
    _paintBeaker(g);
    _paintSteam(g);
  }

  /// `thermometerGroup`: the glass tube rising out of the bench (its bulb
  /// is below the bench top), the red liquid and the scale marks.
  void _paintThermometer(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final x = _thermoPos.x;
    final bottom = _V(x, _benchTop, 0);
    final topY = _thermoPos.y + _thermoHalf;
    g.glassBack(
      bottom,
      _thermoR,
      topY - _benchTop,
      _Colors.white.withValues(alpha: 0.35),
    );
    final liquidTop = _thermoPos.y + _liquidFrom + s.thermoHeight;
    if (liquidTop > _benchTop) {
      g.cylinder(bottom, _liquidR, liquidTop - _benchTop, _Colors.mercury);
    }
    for (var i = -2.0; i <= 2.0; i += 0.5) {
      final y = _thermoPos.y + i;
      g.line(_V(x, y, 0), _V(x + 0.4, y, 0), 0.03, _Colors.mark);
    }
    g.glassFront(
      bottom,
      _thermoR,
      topY - _benchTop,
      _Colors.glassEdge.withValues(alpha: 0.9),
    );
    // The flat top of the tube.
    g.canvas.drawOval(
      cam.oval(_V(x, topY, 0), _thermoR),
      _pens.fill..color = _Colors.white.withValues(alpha: 0.5),
    );
  }

  /// `beaker`: the glass (back, contents, front), the ice cubes, the water
  /// (lower once it boiled), the bubbles and the three marks.
  void _paintBeaker(_Gfx g) {
    final s = scene;
    const b = _beakerPos;
    final bottom = b - const _V(0, _beakerHalf, 0);
    g.glassBack(
      bottom,
      _beakerR,
      2 * _beakerHalf,
      _Colors.glass.withValues(alpha: 0.35),
    );
    // The glass base (0.2 thick) seen through the water.
    g.canvas.drawOval(
      g.cam.oval(b + const _V(0, _baseTop, 0), _beakerR),
      _pens.fill..color = _Colors.white.withValues(alpha: 0.45),
    );
    final ice = s.iceK;
    if (ice > 0.03) _paintIce(g, ice);
    final half = _waterH * s.waterScale / 2;
    final from = math.max(s.waterCenter - half, _baseTop);
    final to = s.waterCenter + half;
    if (to > from) {
      g.liquid(
        b + _V(0, from, 0),
        _waterR,
        to - from,
        _Colors.water,
        s.waterOpacity,
      );
    }
    if (s.isBoiling) {
      final bubble = _Colors.white.withValues(alpha: _bubbleAlpha);
      for (final p in s.bubbles) {
        g.dot(b + _V(p.x, p.y, p.z), _bubbleR, bubble);
      }
    }
    g.glassFront(
      bottom,
      _beakerR,
      2 * _beakerHalf,
      _Colors.glassEdge.withValues(alpha: 0.9),
    );
    for (final y in const [-1.0, 0.0, 1.0]) {
      g.line(
        b + _V(-_markHalf, y, _beakerR + 0.01),
        b + _V(_markHalf, y, _beakerR + 0.01),
        0.05,
        _Colors.mark,
      );
    }
  }

  /// `iceGroup`: twelve jagged cubes, scaled by [k] about the beaker's
  /// centre, drawn far to near with their faces turned to the camera.
  void _paintIce(_Gfx g, double k) {
    final cam = g.cam;
    final cubes = <(double, List<_V>, _V)>[];
    for (final cube in _iceCubes) {
      final corners = List<_V>.filled(8, _V.zero);
      for (var i = 0; i < 8; i++) {
        final sign = _V(
          (i & 1) != 0 ? 1.0 : -1.0,
          (i & 2) != 0 ? 1.0 : -1.0,
          (i & 4) != 0 ? 1.0 : -1.0,
        );
        final local = _euler(sign * (_iceSide / 2) + cube.jitter[i], cube.rot);
        corners[i] = _beakerPos + (cube.pos + local) * k;
      }
      final center = _beakerPos + cube.pos * k;
      cubes.add((cam.depth(center), corners, cube.rot));
    }
    cubes.sort((x, y) => y.$1.compareTo(x.$1));
    final edge = _pens.stroke
      ..strokeWidth = 1
      ..color = _Colors.iceEdge;
    for (final (_, corners, rot) in cubes) {
      for (final face in _boxFaces) {
        final n = _euler(face.normal, rot);
        final pts = [for (final c in face.corners) corners[_corner(c)]];
        final mid = (pts[0] + pts[2]) * 0.5;
        if (n.dot(cam.eye - mid) <= 0) continue;
        final path = _pens.path..reset();
        for (var i = 0; i < 4; i++) {
          g.move(path, i, cam.p(pts[i]));
        }
        path.close();
        g.canvas
          ..drawPath(
            path,
            _pens.fill..color = _lit(_Colors.ice, n).withValues(alpha: 0.88),
          )
          ..drawPath(path, edge);
      }
    }
  }

  /// `steamParticles`: white puffs rising from the rim and fading.
  void _paintSteam(_Gfx g) {
    final cam = g.cam;
    for (final p in scene.puffs) {
      if (p.alpha <= 0.01) continue;
      final c = _beakerPos + _V(p.x, _puffY + p.y, p.z);
      final half = _puffSide / 2 * cam.scaleAt(c);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: cam.p(c), width: 2 * half, height: 2 * half),
        Radius.circular(half * 0.6),
      );
      g.canvas
        ..drawRRect(
          rect.inflate(1.5),
          _pens.steam
            ..color = _Colors.slate400.withValues(alpha: 0.3 * p.alpha),
        )
        ..drawRRect(
          rect,
          _pens.steam..color = _Colors.white.withValues(alpha: p.alpha),
        );
    }
  }

  // ----------------------------------------------------------- overlays

  /// The scene's text sprites (HTML `createTextSprite`): S1 'Caterpillar'
  /// (until it has eaten three leaves) and 'Twig'; S2 'Water Beaker' and
  /// 'Thermometer'.
  void _paintLabels(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    if (s.scenario == 0) {
      if (s.catVisible && s.catLabel) {
        _chip(
          g,
          cam.p(s.catNow + _catLabelLocal * s.catK),
          _t('lbl_caterpillar'),
        );
      }
      _chip(g, cam.p(_twigWorld(_twigLabelLocal)), _t('lbl_twig'));
    } else {
      _chip(g, cam.p(_beakerPos + _beakerLabelLocal), _t('lbl_beaker'));
      _chip(g, cam.p(_thermoPos + _thermoLabelLocal), _t('lbl_thermometer'));
    }
  }

  /// HTML `createTextSprite`: dark chip with an indigo border and white
  /// bold text, centred on [at] and kept inside the visible canvas.
  void _chip(_Gfx g, Offset at, String text) {
    final size = cache.chipSize(text);
    var rect = (at + _chipOffset(size, _centred)) & size;
    final s = scene;
    if (rect.right > s.labelRight) {
      rect = rect.shift(Offset(s.labelRight - rect.right, 0));
    }
    if (rect.left < s.labelLeft) {
      rect = rect.shift(Offset(s.labelLeft - rect.left, 0));
    }
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cache.labelSize * 0.45),
    );
    g.canvas.drawRRect(rr, _pens.fill..color = _Colors.chipBg);
    g.canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.chipBorder,
    );
    final tp = cache.label(text);
    tp.paint(
      g.canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.top + _chipPadY * cache.labelSize,
      ),
    );
  }

  /// HTML `#s1-dropzone` around the caterpillar: indigo dashes, solid and
  /// tinted while a leaf is dragged, with the "Drop Leaf Here" pill at its
  /// top.
  void _paintDropZone(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final zone = s.dropZone(g.cam);
    final rr = RRect.fromRectAndRadius(
      zone,
      Radius.circular(16 * s.framing.zoom),
    );
    if (s.leafDragging) {
      canvas
        ..drawRRect(rr, _pens.fill..color = _Colors.zoneFill)
        ..drawRRect(
          rr,
          _pens.band
            ..strokeWidth = 3
            ..color = _Colors.indigo500,
        );
    } else {
      labDashedPath(
        canvas,
        _pens.aux
          ..reset()
          ..addRRect(rr),
        _pens.band
          ..strokeWidth = 3
          ..color = _Colors.zoneDash,
        dash: 9,
        gap: 6,
      );
    }
    final tp = cache.pill(_t('drop_leaf'));
    final pad = Offset(cache.labelSize * 1.2, cache.labelSize * 0.45);
    final pill = Rect.fromCenter(
      center: Offset(zone.center.dx, zone.top + tp.height / 2 + pad.dy + 10),
      width: tp.width + 2 * pad.dx,
      height: tp.height + 2 * pad.dy,
    );
    final round = RRect.fromRectAndRadius(
      pill,
      Radius.circular(pill.height / 2),
    );
    canvas
      ..drawRRect(
        round.shift(const Offset(0, 1)),
        _pens.fill..color = LabInk.shadowSoft,
      )
      ..drawRRect(
        round,
        _pens.fill
          ..color = (isDark ? _Colors.slate900 : _Colors.white).withValues(
            alpha: 0.8,
          ),
      );
    tp.paint(canvas, pill.topLeft + pad);
  }

  /// HTML `#drag-overlay` while the caterpillar is held: the canvas dims
  /// and a bouncing hand badge sits above the finger.
  void _paintDragBadge(_Gfx g, Size size) {
    final canvas = g.canvas;
    canvas.drawRect(labBleed(size), _pens.fill..color = _Colors.dragDim);
    final at = scene.handAt;
    if (at == null) return;
    final r = touch * _handDp / 2 / _touchDp;
    // Tailwind `animate-bounce`: up a quarter of its height every second.
    final t = scene.time % 1;
    final rise = t < 0.5
        ? 1 - const Cubic(0.8, 0, 1, 1).transform(t * 2)
        : const Cubic(0, 0, 0.2, 1).transform(t * 2 - 1);
    final c = at - Offset(0, r + 0.5 * r * rise);
    canvas
      ..drawCircle(
        c + const Offset(0, 4),
        r,
        _pens.glow..color = LabInk.shadowStrong,
      )
      ..drawCircle(
        c,
        r,
        _pens.fill..color = _Colors.white.withValues(alpha: 0.9),
      )
      ..drawCircle(
        c,
        r - 1,
        _pens.band
          ..strokeWidth = 2
          ..color = _Colors.indigo500,
      );
    final hand = cache.hand(r);
    hand.paint(canvas, c - Offset(hand.width / 2, hand.height / 2));
  }

  /// HTML `confetti(...)` with 'Mastery Achieved!'.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 < 0) return;
    final ticks = (s.time - t0) * 60;
    if (ticks < 0 || ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    final pen = _pens.fill;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      canvas
        ..save()
        ..translate(
          _confettiOrigin.dx + math.cos(c.angle) * d,
          _confettiOrigin.dy + math.sin(c.angle) * d + fall,
        )
        ..rotate(c.spin * ticks)
        ..drawRect(_confettiPiece, pen..color = c.color.withValues(alpha: fade))
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.touch != touch;
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
