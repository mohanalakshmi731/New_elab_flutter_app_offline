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

/// Class 6 Science • Chapter 12 • Activity 5
/// Moons, Asteroids, and Comets (Beyond Earth).
///
/// Native Flutter port of `Cl6S-Ch12-A5-Moons_Asteroids_and_Comets.html`
/// (Three.js r128 + Tween.js). The HTML scenes are redrawn in 2D by
/// [_ScenePainter] through the HTML camera (60° field of view): the Moon is
/// seen from (0, 8, 22) as in the HTML; the comet's orbit is seen from
/// higher up and further back so that the whole orbit fits the stage (in
/// the HTML most of it lay outside the view). The starfield, the lit
/// Lambert Moon, its crater decals, the asteroids, the debris, the weather
/// particles, the Sun, the faceted icy comet with its coma and tail and the
/// orbit line keep the HTML's sizes, colours and motion.
///
/// Scenario 1 (The Moon's Scarred Surface): pick the Small asteroid in the
/// Asteroid Tray and tap the Moon: it flies in, hits, throws up dust and
/// leaves a bowl-shaped crater where it landed. A Large asteroid leaves a
/// much larger crater. The Weather Tools then appear: Wind and Water,
/// tapped or dragged across the craters, only blow and evaporate away and
/// leave the craters unchanged, because the Moon has no atmosphere or
/// liquid water. The Summary button opens the scenario summary.
///
/// Scenario 2 (The Comet's Solar Journey): drag the icy comet (or the
/// orbit slider) along its blue elliptical orbit towards the Sun. Closer
/// than 18 units its ice sublimates: the coma brightens and a growing tail
/// streams away from the Sun, while the Comet Telemetry panel switches to
/// 'Perihelion (Hot)'. Dragged back to the cold outer orbit, the tail
/// shrinks and disappears. The Summary button opens the scenario summary
/// and then 'Mastery Achieved!' with confetti and a full restart.
class Ch12A5MoonsAsteroidsAndCometsPage extends StatefulWidget {
  const Ch12A5MoonsAsteroidsAndCometsPage({super.key});

  @override
  State<Ch12A5MoonsAsteroidsAndCometsPage> createState() =>
      _MoonsCometsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises four Web Audio tones; here they are click (HTML `click`,
/// `science/click.mp3`: an asteroid size or a weather tool picked, a
/// weather tool used on the Moon in step 3), pop (HTML `pop`,
/// `science/click.mp3`: an asteroid launched, the Weather Tools appearing,
/// a step card opened or closed), boom (HTML `boom`, `science/curtain.mp3`:
/// an asteroid hitting the Moon) and success (HTML `success`,
/// `math/success.mp3`: a step done, the summary and mastery popups). The
/// shell plays toggle (`science/dropdown.mp3`: sidebar), correct
/// (`math/success.mp3`), wrong (`science/error.mp3`; this lab shows no
/// error toasts), scenario (`science/page_open.mp3`, the HTML `pop` of
/// `changeScenario()`) and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML `click`: an asteroid size or weather tool picked, a weather tool
  /// used on the Moon in step 3.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast (this lab shows none).
  correct('audio/class6/math/success.mp3'),

  /// Shell feedback for an error toast (this lab shows none).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: a step done, the summary and mastery popups.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: an asteroid launched, the Weather Tools appearing, a step
  /// card opened or closed.
  pop('audio/class6/science/click.mp3'),

  /// HTML `boom`: an asteroid hitting the Moon.
  boom('audio/class6/science/curtain.mp3');

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
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky700 = Color(0xFF0369A1);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color cyan300 = Color(0xFF67E8F9);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` behind the WebGL canvas (bg-[#03071e]).
  static const Color space = Color(0xFF03071E);

  /// Starfield points: 0x94a3b8 at opacity 0.6.
  static const Color star = slate400;

  /// The Moon: MeshLambertMaterial 0xcbe5fe, lit by a DirectionalLight
  /// 0xfffbeb (2.2) and an AmbientLight 0x475569 (0.5).
  static const Color moon = Color(0xFFCBE5FE);
  static const Color moonLight = Color(0xFFFFFBEB);
  static const Color moonAmbient = slate600;

  /// The twelve old crater rings (0x475569) and the impact craters: rim
  /// ring 0x334155, floor 0x0f172a.
  static const Color oldCrater = slate600;
  static const Color craterRim = slate700;
  static const Color craterFloor = slate900;

  /// The asteroid (Lambert 0x64748b) and its debris (0x94a3b8).
  static const Color asteroid = slate500;
  static const Color debris = slate400;

  /// Weather particles: wind 0x67e8f9, water 0x60a5fa.
  static const Color wind = cyan300;
  static const Color water = blue400;

  /// Scenario 2: the Sun (MeshBasic 0xf59e0b) with its PointLight 0xfffbeb
  /// (2.5, reach 200) and an AmbientLight 0x334155 (0.4).
  static const Color sun = amber500;
  static const Color sunLight = Color(0xFFFFFBEB);
  static const Color cometAmbient = slate700;

  /// Soft halo around the Sun (added: the HTML Sun is a flat disc).
  static const Color sunHalo = amber400;

  /// The comet: icy core (Lambert 0xe0f2fe), coma 0x38bdf8, tail 0x7dd3fc.
  static const Color comet = sky100;
  static const Color coma = sky400;
  static const Color tail = sky300;

  /// Orbit line 0x0284c7 at opacity 0.5.
  static const Color orbit = sky600;

  /// HTML `.object-label`: rgba(15, 23, 42, 0.88) with a
  /// rgba(56, 189, 248, 0.5) border.
  static const Color labelBg = Color(0xE00F172A);
  static const Color labelBorder = Color(0x8038BDF8);

  /// The overlay panels (`bg-slate-900/95`, `border-sky-500/50`).
  static const Color panel = Color(0xF20F172A);
  static const Color panelBorder = Color(0x800EA5E9);

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
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: _Colors.slate900, // step cards dark:bg-slate-900/50
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.space, // #canvas-wrapper bg-[#03071e]
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.sky500, // sky-500 accents
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.sky400,
    popupBg: _Colors.slate900, // modals bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A), // toast bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x660C4A6E), // from-sky-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC7DD3FC), // subtitle text-sky-300/80
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.sky500,
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
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border rgba(0, 0, 0, 0.15)
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.space,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.sky500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.sky600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x660C4A6E),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC7DD3FC),
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.sky600,
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
// the HUD heading (the HTML's 'Current Task', the shell's 'Current
// Objective'), Step, Success!, the settings and canvas-tool names and the
// footer) come from the shell's `kLabCommonStrings`. Changes:
// * "Click" / "CLICK" read "Tap" / "TAP" ('टैप' for 'क्लिक');
// * each summary keeps the HTML's parts as separate keys (heading,
//   paragraph, boxed notes); `*text*` marks the HTML's bold words and
//   `_text_` its bold underlined words ([_RichLine] draws them);
// * the HTML's 'Step 3 Tool' badge is an English literal; it gets a Hindi
//   translation, marked "HTML literal";
// * keys marked "Added." are new texts (scene descriptions for screen
//   readers).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Moons, Asteroids, and Comets',
    'app_subtitle': 'Class 6 . Beyond Earth',
    // ScenariosData[en][1].
    's1_title': "Scenario 1: The Moon's Scarred Surface",
    's1_obj':
        "To understand how craters are formed on the Moon's surface by asteroid impacts and why they remain for a long time without disappearing.",
    's1_hud_1':
        "Step 1: Select the 'Small' asteroid from the tray on the right and TAP anywhere on the 3D Moon to drop it.",
    's1_hud_2':
        "Step 2: Observe the small crater! Now select the 'Large' asteroid from the tray and DROP it on a different part of the Moon.",
    's1_hud_3':
        "Step 3: A Weather Tools panel has appeared! TAP 'Wind' and 'Water' buttons, then drag over your craters to test weather effects.",
    's1_hud_4':
        'Step 4: Observe why craters never fade on the Moon, and TAP the Summary button!',
    's1_c1': 'Small Asteroid Impact',
    's1_a1':
        "Select the 'Small' asteroid from the right panel and DROP it onto the Moon's surface.",
    's1_o1':
        'The small asteroid travels and collides with the Moon, creating a bowl-shaped crater at the exact point of impact.',
    's1_c2': 'Proportional Crater Size',
    's1_a2':
        "Select the 'Large' asteroid from the tray and DROP it onto a new spot on the Moon.",
    's1_o2':
        'The large asteroid creates a significantly larger and deeper crater with massive dust debris than the small one!',
    's1_c3': 'Testing Wind & Water Effects',
    's1_a3':
        "Tap the 'Wind' and 'Water' weather tools and drag them over the craters you formed.",
    's1_o3':
        'Neither wind nor water has any effect on the craters! Craters remain completely unchanged because the Moon lacks atmosphere and liquid water.',
    's1_c4': 'Scenario Summary',
    's1_a4': 'Tap the Summary button to review your findings.',
    's1_o4':
        'Because the Moon has no atmosphere or liquid water, craters from ancient asteroid impacts last for millions of years, unlike on Earth!',
    's1_sum_head': "The Moon's Scarred Surface (p. 244-245)",
    's1_sum_p':
        'When asteroids collide with the Moon, they create permanent bowl-shaped holes called *craters*. Larger asteroids create much larger craters!',
    's1_sum_box':
        'Because the Moon has *no atmosphere or water*, there is no wind or rainfall to erode or wash holes away. These craters last for billions of years!',
    // ScenariosData[en][2].
    's2_title': "Scenario 2: The Comet's Solar Journey",
    's2_obj':
        "To understand how a comet's tail is formed by its interaction with the Sun's intense heat and solar wind.",
    's2_hud_1':
        'Step 1: Observe the icy comet far from the Sun on its blue orbital path. Drag the comet along its orbit towards the Sun.',
    's2_hud_2':
        'Step 2: Continue dragging the comet very close to the Sun and observe what happens to its ice and tail orientation!',
    's2_hud_3':
        'Step 3: Now drag the comet away from the Sun back towards the outer cold reaches of its orbit and watch its tail shrink.',
    's2_hud_4':
        'Step 4: Review your observation of comet sublimation and TAP the Summary button!',
    's2_c1': 'Comet at Outer Orbit',
    's2_a1':
        'Observe the icy rock at the farthest point of its orbit, then DRAG it along the blue path towards the Sun.',
    's2_o1':
        'When far from the Sun, the comet is just a frozen, irregular icy-rocky body with zero tail.',
    's2_c2': 'Solar Sublimation & Tail Formation',
    's2_a2':
        'Continue dragging the comet so it gets very close to the hot Sun.',
    's2_o2':
        'As the comet nears the Sun, solar heat vaporizes its ice into gas and dust, forming a long, bright tail that always points directly AWAY from the Sun!',
    's2_c3': 'Fading Tail in Outer Space',
    's2_a3':
        'Drag the comet away from the Sun, moving back towards the outer part of its orbit.',
    's2_o3':
        "As the comet moves far from the Sun's heat, sublimation stops. The tail shrinks, dims, and completely disappears!",
    's2_c4': 'Scenario Summary',
    's2_a4': 'Tap the Summary button to complete your learning of comets.',
    's2_o4':
        'Comets are icy visitors whose magnificent tails only form when solar radiation and solar wind push vaporized gas and dust away near the Sun!',
    's2_sum_head': "The Comet's Solar Journey (p. 245-246)",
    's2_sum_p':
        'Comets are icy-rocky visitors originating from the outer edges of the Solar System.',
    's2_sum_near':
        "*Near the Sun:* The Sun's intense heat turns the frozen ice directly into glowing gas and dust (sublimation), forming a brilliant head (coma) and a long tail.",
    's2_sum_away':
        "*Always Pointing Away:* Because of the solar wind pushing outward from the Sun, a comet's tail _always streams directly away from the Sun_, regardless of which direction the comet is travelling!",
    // i18n: sidebar steps, popups, trays and labels.
    'concept_exp': 'Observation Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'next_sc': 'Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'sc_complete': 'Scenario {n} Summary',
    'all_complete_desc':
        "You have explored how craters form on the Moon's scarred surface due to asteroid impacts and last indefinitely due to lack of atmosphere/water, AND how comets develop blazing gas and dust tails when approaching the Sun's heat!",
    'btn_conclude': 'Summary',
    'asteroid_tray': 'Asteroid Tray',
    'drag_or_click': 'Select & Tap Moon',
    'size_small': 'Small',
    'size_medium': 'Medium',
    'size_large': 'Large',
    'tray_tip':
        'Select an asteroid size, then tap anywhere on the Moon to form a crater!',
    'weather_tools': 'Weather Tools',
    'tool_wind': 'Wind',
    'tool_water': 'Water',
    // HTML literal: the Weather Tools badge.
    'step3_tool': 'Step 3 Tool',
    'comet_telemetry': 'Comet Telemetry',
    'dist_to_sun': 'Distance to Sun:',
    'tail_status': 'Tail Formation:',
    'drag_orbit': 'Drag Comet / Slider',
    'sc1_complete_msg':
        'Scenario 1 Complete! Please select the next scenario from the sidebar.',
    'sc2_complete_msg':
        'Scenario 2 Complete! Please select any scenario from the sidebar.',
    'lbl_moon': 'The Moon (No Atmosphere / Water)',
    'lbl_sun': 'The Sun (Solar Radiation)',
    'lbl_comet': 'Comet (Tail Streams Away From Sun)',
    'summary_header': 'Observation Summary',
    'mastery_achieved': 'Mastery Achieved!',
    'weather_tip': 'Tap Wind or Water, then tap/drag over the Moon craters!',
    'comet_desc':
        'Icy-rocky celestial body travelling along an elongated orbit around the Sun. Currently far away with no tail.',
    'tail_glowing': 'Glowing Dual Tail (Sublimation)',
    'tail_none': 'None (Frozen Ice)',
    'badge_hot': 'Perihelion (Hot)',
    'badge_cold': 'Outer Orbit (Cold)',
    'selected_ast_tip':
        'Selected {size} asteroid! Tap anywhere on the Moon to drop it!',
    'crater_created_msg': '{size} asteroid crater created on Moon!',
    'selected_tool_tip':
        'Selected {tool} tool! Tap / drag across your Moon craters to see the effect!',
    'wind_effect_msg': 'Wind has zero effect! Craters unchanged!',
    'water_effect_msg': 'Water evaporates! Craters remain intact!',
    // Added: scene descriptions for screen readers.
    'scene_s1': 'The Moon in starry space, its surface marked with craters',
    'scene_s2':
        'The Sun in starry space with an icy comet on a blue elliptical orbit around it',
  },
  'hi': {
    'app_title': 'उपग्रह, क्षुद्रग्रह और धूमकेतु',
    'app_subtitle': 'कक्षा 6 . पृथ्वी के पार (Beyond Earth)',
    's1_title': 'परिदृश्य 1: चंद्रमा की क्रेटरयुक्त सतह',
    's1_obj':
        'यह समझना कि क्षुद्रग्रहों (Asteroids) की टक्कर से चंद्रमा की सतह पर क्रेटर कैसे बनते हैं और वे लंबे समय तक बिना मिटे क्यों बने रहते हैं।',
    's1_hud_1':
        "चरण 1: दाईं ओर की ट्रे से 'छोटा (Small)' क्षुद्रग्रह चुनें और चंद्रमा पर कहीं भी टैप करके गिराएं।",
    's1_hud_2':
        "चरण 2: छोटा क्रेटर देखें! अब ट्रे से 'बड़ा (Large)' क्षुद्रग्रह चुनें और चंद्रमा के किसी दूसरे हिस्से पर गिराएं।",
    's1_hud_3':
        "चरण 3: मौसम के उपकरण (Weather Tools) खुल गए हैं! 'हवा' और 'पानी' बटन दबाकर क्रेटर के ऊपर माउस से खींचें।",
    's1_hud_4':
        'चरण 4: समझें कि चंद्रमा पर क्रेटर क्यों नहीं मिटते, और सारांश (Summary) बटन पर टैप करें!',
    's1_c1': 'छोटे क्षुद्रग्रह की टक्कर',
    's1_a1':
        "दाएं पैनल से 'छोटा' क्षुद्रग्रह चुनें और चंद्रमा की सतह पर गिराएं।",
    's1_o1':
        'छोटा क्षुद्रग्रह तेजी से आकर चंद्रमा से टकराता है, जिससे टक्कर के स्थान पर एक कटोरे जैसा क्रेटर बन जाता है।',
    's1_c2': 'आकार के अनुसार क्रेटर',
    's1_a2': "ट्रे से 'बड़ा' क्षुद्रग्रह चुनें और चंद्रमा की नई जगह पर गिराएं।",
    's1_o2':
        'बड़ा क्षुद्रग्रह छोटे की तुलना में बहुत बड़ा और गहरा क्रेटर बनाता है तथा चारों ओर धूल व मलबा फैलाता है!',
    's1_c3': 'हवा और पानी का प्रभाव जांचना',
    's1_a3':
        "'हवा (Wind)' और 'पानी (Water)' उपकरण चुनें और उन्हें बनाए गए क्रेटरों के ऊपर खींचें।",
    's1_o3':
        'हवा या पानी का क्रेटरों पर कोई प्रभाव नहीं पड़ता! चंद्रमा पर वायुमंडल और पानी न होने के कारण क्रेटर ज्यों के त्यों बने रहते हैं।',
    's1_c4': 'परिदृश्य सारांश',
    's1_a4': 'अपने अवलोकन को समझने के लिए सारांश बटन पर टैप करें।',
    's1_o4':
        'चूँकि चंद्रमा पर कोई वायुमंडल या पानी नहीं है, इसलिए प्राचीन क्षुद्रग्रहों की टक्कर से बने क्रेटर पृथ्वी के विपरीत करोड़ों वर्षों तक वैसे ही बने रहते हैं!',
    's1_sum_head': 'चंद्रमा की क्रेटरयुक्त सतह (पृष्ठ 244-245)',
    's1_sum_p':
        'जब क्षुद्रग्रह चंद्रमा से टकराते हैं, तो वे सतह पर कटोरे जैसे स्थायी गड्ढे बना देते हैं जिन्हें *क्रेटर (Craters)* कहते हैं। बड़े क्षुद्रग्रह बड़े क्रेटर बनाते हैं!',
    's1_sum_box':
        'क्योंकि चंद्रमा पर *कोई वायुमंडल या पानी नहीं है*, इसलिए हवा या बारिश क्रेटरों को मिटा नहीं सकती। ये गड्ढे अरबों सालों तक बने रहते हैं!',
    's2_title': 'परिदृश्य 2: धूमकेतु की सौर यात्रा',
    's2_obj':
        'यह समझना कि सूर्य की अत्यधिक गर्मी और सौर हवा के संपर्क से धूमकेतु (Comet) की चमकीली पूंछ कैसे बनती है।',
    's2_hud_1':
        'चरण 1: सूर्य से दूर नीली कक्षा पर बर्फीले धूमकेतु को देखें। धूमकेतु को माउस या स्लाइडर से सूर्य की ओर खींचें।',
    's2_hud_2':
        'चरण 2: धूमकेतु को सूर्य के बहुत करीब खींचना जारी रखें और देखें कि बर्फ और पूंछ की दिशा में क्या बदलाव आता है!',
    's2_hud_3':
        'चरण 3: अब धूमकेतु को सूर्य से दूर कक्षा के बाहरी ठंडे हिस्से में ले जाएं और पूंछ को सिकुड़ते व गायब होते देखें।',
    's2_hud_4':
        'चरण 4: धूमकेतु के वाष्पीकरण को समझें और सारांश (Summary) बटन पर टैप करें!',
    's2_c1': 'बाहरी कक्षा में धूमकेतु',
    's2_a1':
        'कक्षा के सबसे दूरस्थ बिंदु पर बर्फीले चट्टानी पिंड को देखें, फिर उसे नीले रास्ते पर सूर्य की ओर खींचें।',
    's2_o1':
        'सूर्य से दूर रहने पर धूमकेतु केवल बर्फ और चट्टान का एक अनियमित पिंड होता है जिसकी कोई पूंछ नहीं होती।',
    's2_c2': 'सूर्य की गर्मी से पूंछ का निर्माण',
    's2_a2': 'धूमकेतु को सूर्य के बहुत निकट लाएं और अवलोकन करें।',
    's2_o2':
        'जैसे ही धूमकेतु सूर्य के पास आता है, सूर्य की गर्मी से बर्फ गैस और धूल में बदल जाती है, जिससे एक लंबी चमकीली पूंछ बनती है जो हमेशा सूर्य से विपरीत दिशा में होती है!',
    's2_c3': 'दूर जाने पर पूंछ का लुप्त होना',
    's2_a3': 'धूमकेतु को सूर्य से दूर, कक्षा के बाहरी भाग की ओर खींचें।',
    's2_o3':
        'जैसे ही धूमकेतु सूर्य की गर्मी से दूर जाता है, वाष्पीकरण रुक जाता है। पूंछ छोटी होती है, धुंधली पड़ती है और पूरी तरह गायब हो जाती है!',
    's2_c4': 'परिदृश्य सारांश',
    's2_a4': 'धूमकेतु के बारे में सीखने के लिए सारांश बटन दबाएं।',
    's2_o4':
        'धूमकेतु बर्फीले यात्री हैं जिनकी सुंदर चमकीली पूंछ केवल तब बनती है जब वे सूर्य के निकट आते हैं और सौर हवा गैस व धूल को पीछे ढकेलती है!',
    's2_sum_head': 'धूमकेतु की सौर यात्रा (पृष्ठ 245-246)',
    's2_sum_p':
        'धूमकेतु सौरमंडल के बाहरी किनारों से आने वाले बर्फीले-चट्टानी यात्री हैं।',
    's2_sum_near':
        '*सूर्य के निकट:* सूर्य की अत्यधिक गर्मी बर्फ को सीधे गैस और धूल (Sublimation) में बदल देती है, जिससे चमकीला सिर (Coma) और लंबी पूंछ बनती है।',
    's2_sum_away':
        '*हमेशा सूर्य से विपरीत:* सूर्य से बाहर की ओर बहने वाली सौर हवा के कारण धूमकेतु की पूंछ _हमेशा सूर्य से विपरीत दिशा की ओर होती है_!',
    'concept_exp': 'अवलोकन चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'next_sc': 'अगला परिदृश्य',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'sc_complete': 'परिदृश्य {n} सारांश',
    'all_complete_desc':
        'आपने जाना कि क्षुद्रग्रहों की टक्कर से चंद्रमा की सतह पर क्रेटर कैसे बनते हैं और वायुमंडल/पानी न होने के कारण लंबे समय तक बने रहते हैं, और यह भी समझा कि सूर्य के पास आने पर धूमकेतु में गैस और धूल की चमकीली पूंछ कैसे बनती है!',
    'btn_conclude': 'सारांश देखें',
    'asteroid_tray': 'क्षुद्रग्रह ट्रे (Asteroid Tray)',
    'drag_or_click': 'चुनें और चंद्रमा पर टैप करें',
    'size_small': 'छोटा',
    'size_medium': 'मध्यम',
    'size_large': 'बड़ा',
    'tray_tip':
        'क्षुद्रग्रह का आकार चुनें, फिर क्रेटर बनाने के लिए चंद्रमा पर कहीं भी टैप करें!',
    'weather_tools': 'मौसम के उपकरण (Weather Tools)',
    'tool_wind': 'हवा (Wind)',
    'tool_water': 'पानी (Water)',
    // Added: Hindi for the HTML literal badge.
    'step3_tool': 'चरण 3 उपकरण',
    'comet_telemetry': 'धूमकेतु डेटा',
    'dist_to_sun': 'सूर्य से दूरी:',
    'tail_status': 'पूंछ का निर्माण:',
    'drag_orbit': 'धूमकेतु खींचें / स्लाइडर',
    'sc1_complete_msg':
        'परिदृश्य 1 पूरा हुआ! कृपया साइडबार से अगला परिदृश्य चुनें।',
    'sc2_complete_msg':
        'परिदृश्य 2 पूरा हुआ! कृपया साइडबार से कोई भी परिदृश्य चुनें।',
    'lbl_moon': 'चंद्रमा (कोई वायुमंडल / पानी नहीं)',
    'lbl_sun': 'सूर्य (सौर विकिरण)',
    'lbl_comet': 'धूमकेतु (पूंछ सूर्य से विपरीत दिशा में)',
    'summary_header': 'अवलोकन सारांश',
    'mastery_achieved': 'महारत हासिल की!',
    'weather_tip':
        'हवा या पानी पर टैप करें, फिर चंद्रमा के क्रेटरों पर खींचें!',
    'comet_desc':
        'बर्फीला-चट्टानी खगोलीय पिंड जो सूर्य के चारों ओर एक लंबी कक्षा में यात्रा करता है। वर्तमान में दूर है और कोई पूंछ नहीं है।',
    'tail_glowing': 'चमकीली दोहरी पूंछ (वाष्पीकरण)',
    'tail_none': 'कोई नहीं (जमी हुई बर्फ)',
    'badge_hot': 'सूर्य के निकट (गर्म)',
    'badge_cold': 'बाहरी कक्षा (ठंडा)',
    'selected_ast_tip':
        '{size} क्षुद्रग्रह चुना गया! गिराने के लिए चंद्रमा पर कहीं भी टैप करें!',
    'crater_created_msg': 'चंद्रमा पर {size} क्षुद्रग्रह क्रेटर बना!',
    'selected_tool_tip':
        '{tool} उपकरण चुना गया! प्रभाव देखने के लिए क्रेटरों पर खींचें!',
    'wind_effect_msg': 'हवा का कोई प्रभाव नहीं! क्रेटर अपरिवर्तित!',
    'water_effect_msg': 'पानी भाप बन गया! क्रेटर सुरक्षित हैं!',
    // Added.
    'scene_s1': 'तारों भरे अंतरिक्ष में चंद्रमा, जिसकी सतह पर क्रेटर हैं',
    'scene_s2':
        'तारों भरे अंतरिक्ष में सूर्य, और उसके चारों ओर नीली दीर्घवृत्ताकार कक्षा पर एक बर्फीला धूमकेतु',
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
    title: t('s${n}_title'),
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

/// Smallest touch target for the Moon and the comet (logical px).
const double _minTouch = 48;

/// Slop before a press on the scene becomes a drag (RawGestureDetector
/// does not apply MediaQuery's gesture settings).
const double _dragSlop = 8;

/// Longest step (s) the particles take in one frame, so a stalled frame
/// does not make them jump.
const double _maxFrameStep = 0.05;

/// The HTML animates its particles per frame at 60 frames per second.
const double _fps = 60;

/// Screens shorter than this (phones in landscape) get the compact panels
/// and keep them clear of the HUD.
const double _compactBelow = 480;

// ------------------------------------------------------------------ cameras
// HTML init3D() / resetCamera(): PerspectiveCamera(60°) at (0, 8, 22)
// looking at the origin, for both scenarios.

const double _fovDegrees = 60;
const _V _eyeS1 = _V(0, 8, 22);
const _V _lookS1 = _V(0, 0, 0);

/// Scenario 2 camera (changed). From the HTML camera only the arc of the
/// orbit next to the Sun was in view (the comet started 82 units off to
/// the left); this one looks down on the whole ellipse at about 35° from
/// above its centre, still from the +z side, so the Sun stays on the right
/// and the comet starts on the far left as in the HTML.
const _V _eyeS2 = _V(-32, 46, 66);
const _V _lookS2 = _V(-32, 0, 0);

/// Zoom of the camera and the stage point its look-at point is drawn at,
/// so the scene stays clear of the trays (top right) and, with the
/// sidebar collapsed, of the floating mission card (top left).
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
/// Scenario 1 keeps the Moon left of the tray (sidebar open) or between
/// the mission card and the tray (collapsed); Scenario 2 puts the Sun
/// (212 px right of the look-at point) below the telemetry card and the
/// orbit above the HUD.
const List<_Frame> _framesOpen = [
  _Frame(1, Offset(232, 292)),
  _Frame(1.1, Offset(428, 410)),
];
const List<_Frame> _framesClosed = [
  _Frame(1, Offset(572, 290)),
  _Frame(1.1, Offset(488, 420)),
];

/// The scene glides to the other framing in this time (s) when the sidebar
/// opens or closes.
const double _reframeSeconds = 0.38;

// ------------------------------------------------------------------- labels
// HTML `.object-label`: 11 px extra-bold white text, padding 3 × 10 px,
// radius 8, on rgba(15, 23, 42, 0.88) with a sky border. The HTML centred
// each label just above the body's centre; here it sits above the body so
// it never hides the craters or the comet.

const double _labelPx = 11;
const double _labelPadX = 10;
const double _labelPadY = 3;
const double _labelRadius = 8;
const double _labelGap = 8;

/// Labels are enlarged up to [_labelMaxBoost] when the stage is drawn
/// smaller than [_labelFullScale].
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

// ---------------------------------------------------------------- starfield
// 1800 points on a sphere of radius 90 (PointsMaterial 0x94a3b8, size 0.6,
// opacity 0.6). They are drawn as seen from far away (directions only), so
// they stay a backdrop behind both scenarios' cameras.

const int _starCount = 1800;
const double _starOpacity = 0.6;

/// Size 0.6 at about 90 units: 0.6 × 280 / 90 design px.
const double _starPx = 1.9;

// --------------------------------------------------------------------- moon
// SphereGeometry(6.5, 48, 48) with MeshLambertMaterial 0xcbe5fe (lit per
// vertex), DirectionalLight 0xfffbeb (2.2) at (30, 20, 20) and an
// AmbientLight 0x475569 (0.5). It turns 0.003 rad per frame about its axis
// while the camera is unlocked.

const double _moonR = 6.5;
const int _moonSegments = 48;
const _V _moonLightAt = _V(30, 20, 20);
const double _moonDirect = 2.2;
const double _moonAmbientLevel = 0.5;
const double _moonSpinRate = 0.003 * _fps;

/// Twelve old crater rings: RingGeometry(0.2, 0.5 + random × 0.4, 16) at
/// radius 6.51 facing the centre.
const int _oldCraterCount = 12;
const double _oldCraterAt = 6.51;
const double _oldCraterInner = 0.2;
const double _oldCraterOuter = 0.5;
const double _oldCraterSpread = 0.4;
const int _oldCraterSides = 16;

// ---------------------------------------------------------------- asteroids
// launchAsteroidImpact(): the asteroid starts 15 units out along the
// surface normal and falls onto the hit point in 380 ms (Quadratic.In);
// the crater (a 24-sided rim ring from 0.6 R to R and a floor disc of
// 0.6 R) sits 0.04 above the surface.

const double _launchFrom = 15;
const double _flightSeconds = 0.38;
const double _craterLift = 0.04;
const double _rimInner = 0.6;
const int _craterSides = 24;

/// Debris: DodecahedronGeometry(0.1 + random × 0.1) thrown out at 0.15 to
/// 0.5 units per frame along the normal (× 0.5) plus a random tangent,
/// pulled back at 0.015 units per frame², fading by 0.025 per frame.
const double _debrisMinR = 0.1;
const double _debrisSpanR = 0.1;
const double _debrisMinSpeed = 0.15;
const double _debrisSpanSpeed = 0.35;
const double _debrisLift = 0.5;
const double _debrisGravity = 0.015;
const double _debrisFade = 0.025;

// ------------------------------------------------------------------ weather
// spawnWeatherVFX(): a sphere 0.2 above the hit point (wind 0.2 across the
// surface at 0.12 units per frame, water 0.15 rising at 0.06), fading by
// 0.035 per frame.

const double _puffLift = 0.2;
const double _puffFade = 0.035;

/// The feedback banner (HTML `#vfx-feedback-banner`) stays 2.8 s.
const Duration _bannerTime = Duration(milliseconds: 2800);

// --------------------------------------------------------------- scenario 2
// Sun: SphereGeometry(5) MeshBasic 0xf59e0b with a PointLight 0xfffbeb
// (2.5, distance 200). Comet: DodecahedronGeometry(1.1, 1), its coma a
// SphereGeometry(2) and its tail a ConeGeometry(3, 20) from the core
// outwards. Orbit: r = 11 / (1 + 0.65 cos θ), x = 2.6 r cos θ,
// z = 1.7 r sin θ (121 points, 0x0284c7 at opacity 0.5).

const double _sunR = 5;
const double _sunPower = 2.5;
const double _sunReach = 200;
const double _cometAmbientLevel = 0.4;
const double _cometR = 1.1;
const double _comaR = 2;

/// The core and the coma are drawn this much larger (added): seen from the
/// whole orbit the 1.1-unit core would be a dot a few pixels wide.
const double _cometBoost = 1.6;
const double _tailLength = 20;
const double _tailRadius = 3;
const double _orbitL = 11;
const double _orbitE = 0.65;
const double _orbitSx = 2.6;
const double _orbitSz = 1.7;
const int _orbitSamples = 120;
const double _orbitOpacity = 0.5;

/// Start angle (HTML `State.s2.cometAngle` and the slider's value).
const int _startAngle = 180;

/// The comet warms up closer than 18 units (HTML `distFromSun < 18`); the
/// telemetry shows the distance × 1.3 in AU.
const double _hotBelow = 18;
const double _auPerUnit = 1.3;

/// Coma opacity 0.1 when cold, up to 0.85 when hot; tail opacity up to
/// 0.9 and scale (1 + i, 1 + 2.2 i, 1 + i); a cold tail is 0.1 in size.
const double _comaCold = 0.1;
const double _comaMax = 0.85;
const double _tailMax = 0.9;
const double _tailGrowSide = 1;
const double _tailGrowUp = 2.2;
const double _tailGrowLength = 1;

/// Opacity of the tail's far end relative to its head (added: the HTML
/// cone has one flat opacity; the 2D tail fades out like a glow).
const double _tailFade = 0.2;

/// Soft halo around the Sun (added), in Sun radii.
const double _sunHaloR = 2.2;

/// Closest approach of the orbit to the Sun (about 16.3 units, near
/// θ = ±60°). The HTML's heat `(18 − d) / 10` never passes 0.17 on this
/// orbit, which left only a faint tail; the heat is measured from 18
/// units down to this distance instead, so the tail reaches the HTML's
/// opacity caps at the closest approach.
final double _closest = () {
  var best = double.infinity;
  for (var k = 0; k < 3600; k++) {
    best = math.min(best, _orbitAt(k / 10).length);
  }
  return best;
}();

// ----------------------------------------------------------------- confetti
// canvas-confetti: start velocity 45, decay 0.9 per tick, gravity 3 px per
// tick, 200 ticks of 1/60 s. The mastery popup fires 150 pieces upwards
// (spread 70°) from 30 % down the canvas.

const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;
const int _burstCount = 150;
const double _burstSpread = 70;
const double _burstOriginY = 0.3;

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
  _V operator -() => _V(-x, -y, -z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  /// This vector turned by [angle] about the y axis (Three.js
  /// `rotation.y`).
  _V turnY(double angle) {
    final c = math.cos(angle), s = math.sin(angle);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      other is _V && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// A position on the comet's orbit at [degrees] (HTML `animate()`).
_V _orbitAt(double degrees) {
  final th = degrees * math.pi / 180;
  final r = _orbitL / (1 + _orbitE * math.cos(th));
  return _V(math.cos(th) * r * _orbitSx, 0, math.sin(th) * r * _orbitSz);
}

/// Two unit vectors at right angles to the unit vector [n] (a frame for
/// the flat crater decals and the tail's base).
(_V, _V) _basis(_V n) {
  final a = n.y.abs() < 0.9 ? _V.up : const _V(1, 0, 0);
  final e1 = a.cross(n).unit;
  return (e1, n.cross(e1));
}

/// HTML `new Vector3(normal.y, -normal.x, 0).normalize()` (with its
/// (1, 0, 0) fallback): the tangent the debris and the wind use.
_V _tangent(_V n) {
  final t = _V(n.y, -n.x, 0);
  return t.length < 1e-6 ? const _V(1, 0, 0) : t.unit;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 60°) as a
/// pinhole projection onto the design stage, zoomed by [_Frame.zoom] with
/// the look-at point drawn at [_Frame.center].
@immutable
class _Cam {
  factory _Cam(_V eye, _V look, _Frame frame) {
    final f = (look - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(
      eye,
      look,
      frame.center,
      _focal * frame.zoom,
      f,
      r,
      r.cross(f),
    );
  }

  const _Cam._(
    this.eye,
    this.look,
    this.center,
    this.focal,
    this.f,
    this.r,
    this.u,
  );

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double _focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final _V look;
  final Offset center;
  final double focal;

  /// Forward, right and up.
  final _V f;
  final _V r;
  final _V u;

  /// Identifies the projection (for cached drawings).
  Object get key => (eye, center, focal);

  /// Distance of [w] in front of the camera.
  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  /// Where [w] is drawn on the stage.
  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// Where the direction [d] (a point at infinity) is drawn, or null when
  /// it is behind the camera.
  Offset? toward(_V d) {
    final z = d.dot(f);
    if (z <= 1e-3) return null;
    final k = focal / z;
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// Unit direction of the ray from the eye through the stage point [s]
  /// (HTML `raycaster.setFromCamera`).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) - u * ((s.dy - center.dy) / focal))
          .unit;

  /// Radius on the stage of a sphere of radius [radius] centred on the
  /// look-at point (its outline is a circle there).
  double sphereRadius(double radius) {
    final d = (look - eye).length;
    return focal * radius / math.sqrt(math.max(1e-6, d * d - radius * radius));
  }
}

/// First point where the ray from [from] along the unit [dir] meets the
/// sphere of radius [radius] at the origin, as a distance (null: none
/// ahead).
double? _hitSphere(_V from, _V dir, double radius) {
  final b = from.dot(dir);
  final c = from.dot(from) - radius * radius;
  final disc = b * b - c;
  if (disc < 0) return null;
  final t = -b - math.sqrt(disc);
  return t > 0 ? t : null;
}

/// Whether the Moon hides [w] from the camera at [eye] (in WebGL the depth
/// test).
bool _behindMoon(_V eye, _V w) {
  final v = w - eye;
  final dist = v.length;
  if (dist < 1e-6) return false;
  final t = _hitSphere(eye, v * (1 / dist), _moonR);
  return t != null && t < dist - 1e-3;
}

// ------------------------------------------------------------------ easing
// Tween.js easing used by the HTML.

typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// `TWEEN.Easing.Quadratic.In` (the asteroid's fall).
double _quadIn(double t) => t * t;

/// `TWEEN.Easing.Cubic.Out` (the reframing when the sidebar slides).
double _cubicOut(double t) {
  final k = t - 1;
  return k * k * k + 1;
}

/// A number eased from [from] to [to] (a Tween.js tween on a scalar), read
/// at the scene time.
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

  /// A new tween from the value at [now] to [target] (`new TWEEN.Tween(o)
  /// .to(…)` starts from the current value).
  _Ramp toward(double target, double now, double secs, [_Ease e = _linear]) =>
      _Ramp(at(now), target, now, secs, e);
}

// --------------------------------------------------------------- polyhedra

/// Three.js DodecahedronGeometry on the unit sphere as triangles (three
/// corners in a row): [rock] has the flat pentagons (detail 0: the
/// asteroids and their debris), [icy] splits every triangle in four and
/// pushes the new corners onto the sphere (detail 1: the comet's core).
class _Poly {
  _Poly._(this.triangles, this.corners);

  /// Corners of the triangles, three per triangle.
  final List<_V> triangles;

  /// Every distinct corner (for the outline).
  final List<_V> corners;

  int get triangleCount => triangles.length ~/ 3;

  static final _Poly rock = _build(0);
  static final _Poly icy = _build(1);

  static _Poly _build(int detail) {
    const t = 1.618033988749895;
    const r = 1 / t;
    final points = <_V>[
      for (final x in const [-1.0, 1.0])
        for (final y in const [-1.0, 1.0])
          for (final z in const [-1.0, 1.0]) _V(x, y, z).unit,
      for (final a in const [-r, r])
        for (final b in const [-t, t]) ...[
          _V(0, a, b).unit,
          _V(a, b, 0).unit,
          _V(b, 0, a).unit,
        ],
    ];
    // Each pentagon faces one of the twelve directions (0, ±φ, ±1),
    // (±φ, ±1, 0), (±1, 0, ±φ); its corners are the five nearest points.
    final faces = <List<_V>>[];
    for (final a in const [-1.0, 1.0]) {
      for (final b in const [-t, t]) {
        for (final d in [_V(0, b, a), _V(b, a, 0), _V(a, 0, b)]) {
          final n = d.unit;
          final near = [...points]
            ..sort((p, q) => q.dot(n).compareTo(p.dot(n)));
          final (e1, e2) = _basis(n);
          final face = near.take(5).toList()
            ..sort(
              (p, q) => math
                  .atan2(p.dot(e2), p.dot(e1))
                  .compareTo(math.atan2(q.dot(e2), q.dot(e1))),
            );
          faces.add(face);
        }
      }
    }
    final tris = <_V>[];
    for (final face in faces) {
      for (var k = 1; k < 4; k++) {
        tris.addAll([face[0], face[k], face[k + 1]]);
      }
    }
    if (detail == 0) return _Poly._(tris, points);
    final fine = <_V>[];
    final corners = <_V>[...points];
    for (var k = 0; k < tris.length; k += 3) {
      final a = tris[k], b = tris[k + 1], c = tris[k + 2];
      final ab = ((a + b) * 0.5).unit;
      final bc = ((b + c) * 0.5).unit;
      final ca = ((c + a) * 0.5).unit;
      fine.addAll([a, ab, ca, ab, b, bc, ca, bc, c, ab, bc, ca]);
      corners.addAll([ab, bc, ca]);
    }
    return _Poly._(fine, corners);
  }
}

/// MeshLambertMaterial: [base] × (ambient + light × power × max(0, n · l)),
/// each channel clamped (the HTML renders without colour management, so the
/// sums are the shown sRGB values).
Color _lambert(
  Color base,
  Color ambient,
  double ambientLevel,
  Color light,
  double power,
  double ndl, {
  double opacity = 1,
}) {
  final k = math.max(0.0, ndl) * power;
  double ch(double b, double a, double l) =>
      (b * (a * ambientLevel + l * k)).clamp(0.0, 1.0);
  return Color.from(
    alpha: base.a * opacity,
    red: ch(base.r, ambient.r, light.r),
    green: ch(base.g, ambient.g, light.g),
    blue: ch(base.b, ambient.b, light.b),
  );
}

// -------------------------------------------------------------- scene model

/// The Asteroid Tray's sizes (HTML `selectAsteroidSize(size)`): the rock's
/// radius, its crater's radius, the debris count and the tray dot.
enum _Size {
  small(
    'size_small',
    rock: 0.35,
    crater: 0.55,
    debris: 18,
    dot: 12,
    dotColor: _Colors.slate300,
    dotGlow: Color(0x99FFFFFF),
    glowBlur: 8,
  ),
  medium(
    'size_medium',
    rock: 0.65,
    crater: 0.95,
    debris: 30,
    dot: 16,
    dotColor: _Colors.slate400,
    dotGlow: Color(0x99FFFFFF),
    glowBlur: 8,
  ),
  large(
    'size_large',
    rock: 1.1,
    crater: 1.6,
    debris: 50,
    dot: 24,
    dotColor: _Colors.indigo300,
    dotGlow: Color(0xCCA5B4FC),
    glowBlur: 10,
  );

  const _Size(
    this.key, {
    required this.rock,
    required this.crater,
    required this.debris,
    required this.dot,
    required this.dotColor,
    required this.dotGlow,
    required this.glowBlur,
  });

  /// String key of the size's name.
  final String key;
  final double rock;
  final double crater;
  final int debris;

  /// The tray's dot: diameter (px), colour and glow.
  final double dot;
  final Color dotColor;
  final Color dotGlow;
  final double glowBlur;
}

/// The Weather Tools (HTML `selectWeatherTool(tool)`) and their particles.
enum _Tool {
  wind(
    'tool_wind',
    'wind_effect_msg',
    Icons.air,
    _Colors.cyan400,
    _Colors.wind,
    radius: 0.2,
    speed: 0.12,
  ),
  water(
    'tool_water',
    'water_effect_msg',
    Icons.water_drop,
    _Colors.blue400,
    _Colors.water,
    radius: 0.15,
    speed: 0.06,
  );

  const _Tool(
    this.key,
    this.effectKey,
    this.icon,
    this.iconColor,
    this.particle, {
    required this.radius,
    required this.speed,
  });

  final String key;

  /// The feedback banner of a test in step 3.
  final String effectKey;
  final IconData icon;
  final Color iconColor;
  final Color particle;
  final double radius;
  final double speed;
}

/// A crater on the Moon in the Moon's own frame (it turns with the Moon):
/// an old ring decal or an impact crater (rim ring and dark floor).
@immutable
class _Crater {
  const _Crater(this.normal, this.radius, {this.hole = 0, this.impact = true});

  /// Unit direction of its centre from the Moon's centre.
  final _V normal;
  final double radius;

  /// Radius of an old ring's hole.
  final double hole;
  final bool impact;
}

/// The twelve old crater rings (HTML `init3D()`), at fixed random places.
final List<_Crater> _oldCraters = () {
  final r = math.Random(12);
  return [
    for (var k = 0; k < _oldCraterCount; k++)
      () {
        final phi = math.acos(2 * r.nextDouble() - 1);
        final theta = r.nextDouble() * 2 * math.pi;
        return _Crater(
          _V(
            math.sin(phi) * math.cos(theta),
            math.sin(phi) * math.sin(theta),
            math.cos(phi),
          ),
          _oldCraterOuter + r.nextDouble() * _oldCraterSpread,
          hole: _oldCraterInner,
          impact: false,
        );
      }(),
  ];
}();

/// An asteroid on its way to the Moon (HTML `launchAsteroidImpact()`).
@immutable
class _Flight {
  const _Flight(this.size, this.target, this.start);

  final _Size size;

  /// The hit point on the Moon (world).
  final _V target;
  final double start;

  _V get normal => target.unit;

  /// Where the asteroid is at [time] (Quadratic.In from 15 units out).
  _V at(double time) {
    final k = ((time - start) / _flightSeconds).clamp(0.0, 1.0);
    return _V.lerp(target + normal * _launchFrom, target, _quadIn(k));
  }

  bool landedAt(double time) => time >= start + _flightSeconds;
}

/// A piece of impact debris (HTML `activeDebrisParticles`).
class _Debris {
  _Debris(this.pos, this.vel, this.gravity, this.radius);

  _V pos;
  _V vel;
  final _V gravity;
  final double radius;
  double life = 1;
}

/// A wind or water particle (HTML `weatherParticles`).
class _Puff {
  _Puff(this.pos, this.vel, this.tool);

  _V pos;
  final _V vel;
  final _Tool tool;
  double life = 1;
}

/// The feedback banner's message: an impact (with its size) or a weather
/// test. [id] restarts its timer.
@immutable
class _Banner {
  const _Banner.crater(_Size this.size, this.id) : tool = null;
  const _Banner.weather(_Tool this.tool, this.id) : size = null;

  final _Size? size;
  final _Tool? tool;
  final int id;
}

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

  /// The mastery burst: 150 pieces upwards from 30 % down the canvas.
  void burst() =>
      fire(_burstCount, 90, _burstSpread, const Offset(0.5, _burstOriginY));

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

  /// HTML `State.step` (1-based); one past the last step once the summary
  /// has been opened.
  int step = 1;

  /// Mirrors the shell's camera lock (the Moon turns while unlocked).
  bool camLocked = true;

  // ------------------------------------------------- HTML State.s1
  /// `selectedAsteroidSize`.
  _Size asteroid = _Size.small;

  /// `selectedWeatherTool` (a picked tool wins over the asteroid).
  _Tool? tool;

  /// `weatherTested`: the tools tried on the Moon in step 3.
  final Set<_Tool> tested = {};

  /// The Weather Tools section is shown (from step 3).
  bool toolsShown = false;

  /// `moonMesh.rotation.y`.
  double spin = 0;

  /// Impact craters (Moon frame), asteroids in flight and particles.
  final List<_Crater> craters = [];
  final List<_Flight> flights = [];
  final List<_Debris> debris = [];
  final List<_Puff> puffs = [];

  // ------------------------------------------------- HTML State.s2
  /// `cometAngle` in whole degrees (0 … 359).
  int cometAngle = _startAngle;

  /// `isDraggingComet`.
  bool dragging = false;

  /// 0 sidebar open … 1 sidebar collapsed (kept across scenarios).
  _Ramp frame = const _Ramp.still(0);

  final _Confetti confetti = _Confetti();
  final math.Random _rnd = math.Random(29);

  bool get done => step > _stepCount;

  /// The camera of the current scenario for the sidebar state.
  _Cam get cam {
    final k = frame.at(time);
    final framing = _Frame.lerp(
      _framesOpen[scenario],
      _framesClosed[scenario],
      k,
    );
    return scenario == 0
        ? _Cam(_eyeS1, _lookS1, framing)
        : _Cam(_eyeS2, _lookS2, framing);
  }

  /// The comet's position on its orbit.
  _V get cometPos => _orbitAt(cometAngle.toDouble());

  /// HTML `distFromSun`.
  double get sunDistance => cometPos.length;

  /// HTML `distFromSun < 18`: the ice sublimates.
  bool get hot => sunDistance < _hotBelow;

  /// 0 cold … 1 at the closest approach (see [_closest]).
  double get heat => hot
      ? ((_hotBelow - sunDistance) / (_hotBelow - _closest)).clamp(0.0, 1.0)
      : 0.0;

  /// HTML `changeScenario()` / `resetScenarioState()`. (The HTML kept the
  /// craters and the wind / water test across scenario changes; each run
  /// starts afresh here.)
  void load(int index) {
    scenario = index;
    step = 1;
    asteroid = _Size.small;
    tool = null;
    tested.clear();
    toolsShown = false;
    spin = 0;
    craters.clear();
    flights.clear();
    debris.clear();
    puffs.clear();
    cometAngle = _startAngle;
    dragging = false;
  }

  /// World position of the Moon-frame direction [local] (and back).
  _V toWorld(_V local) => local.turnY(spin);
  _V toMoon(_V world) => world.turnY(-spin);

  /// Asteroids that reach the Moon at this moment; they leave the sky.
  List<_Flight> takeLandings() {
    final landed = [
      for (final f in flights)
        if (f.landedAt(time)) f,
    ];
    if (landed.isNotEmpty) flights.removeWhere(landed.contains);
    return landed;
  }

  /// HTML impact debris: [_Size.debris] pieces thrown out of the crater.
  void spawnDebris(_Flight f) {
    final n = f.normal;
    final r = _rnd;
    for (var k = 0; k < f.size.debris; k++) {
      final angle = r.nextDouble() * 2 * math.pi;
      final speed = _debrisMinSpeed + r.nextDouble() * _debrisSpanSpeed;
      final t1 = _tangent(n);
      final t2 = n.cross(t1).unit;
      final dir =
          (n * _debrisLift + t1 * math.cos(angle) + t2 * math.sin(angle)).unit;
      debris.add(
        _Debris(
          f.target,
          dir * speed,
          n * -_debrisGravity,
          _debrisMinR + r.nextDouble() * _debrisSpanR,
        ),
      );
    }
  }

  /// HTML `spawnWeatherVFX()`: one particle at the hit point [hit].
  void spawnPuff(_V hit, _Tool t) {
    final n = hit.unit;
    final vel = t == _Tool.wind ? _tangent(n) * t.speed : n * t.speed;
    puffs.add(_Puff(hit + n * _puffLift, vel, t));
  }

  /// HTML `animate()`: the Moon's turn and the particles, [dt] seconds on.
  void tick(double dt) {
    final frames = dt * _fps;
    if (scenario == 0 && !camLocked) spin += _moonSpinRate * dt;
    for (final d in debris) {
      d
        ..pos += d.vel * frames
        ..vel += d.gravity * frames
        ..life -= _debrisFade * frames;
    }
    debris.removeWhere((d) => d.life <= 0);
    for (final p in puffs) {
      p
        ..pos += p.vel * frames
        ..life -= _puffFade * frames;
    }
    puffs.removeWhere((p) => p.life <= 0);
  }
}

/// Pan recogniser that only claims pointers [canGrab] accepts (a weather
/// tool on the Moon, the comet), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _MoonsCometsLabState extends State<Ch12A5MoonsAsteroidsAndCometsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _TextCache _texts = _TextCache();
  final _MoonMesh _moonMesh = _MoonMesh();
  final _StarCache _stars = _StarCache();

  /// The full-canvas overlay layer (the confetti's size).
  final GlobalKey _canvasKey = GlobalKey();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout.
  double _fit = 1;

  /// The sidebar state the scene is framed for.
  bool _framedOpen = true;

  /// The feedback banner (HTML `showVFXBanner()`): its message and whether
  /// it is showing (it fades out keeping its text).
  _Banner? _banner;
  bool _bannerShown = false;
  int _bannerId = 0;

  /// Sidebar step cards that are open (HTML accordion); the current step
  /// opens on its own when the step changes.
  final Set<int> _openSteps = {1};
  int _openFor = 1;

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
    _texts.dispose();
    _moonMesh.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update() (the asteroids land), the Moon's
  /// turn, the particles and the confetti, then a repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s
      ..time = now
      ..camLocked = _lab.camLocked
      ..tick(dt);
    for (final flight in s.takeLandings()) {
      _impact(flight);
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

  /// HTML `changeScenario(sc)`: resets the scenario's objects, the step,
  /// the trays and the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _bannerShown = false;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `resetApp()`: Scenario 1 from scratch (the shell restores the
  /// language, theme, sidebar and curtain).
  void _reset() {
    _scene.confetti.clear();
    _loadScenario(0);
  }

  /// HTML `playSound('success'); progressStep()`: the next step, and
  /// `setupStepUI()` (the Weather Tools appear from step 3).
  void _progressStep() {
    final s = _scene;
    _Sound.success.play();
    s.step = math.min(s.step + 1, _stepCount);
    if (s.scenario == 0 && s.step >= 3 && !s.toolsShown) {
      s.toolsShown = true;
      _Sound.pop.play();
    }
    _refresh();
  }

  /// HTML `showVFXBanner(msg, icon)`: the banner shows for 2.8 s.
  void _showBanner(_Banner Function(int id) make) {
    final banner = make(++_bannerId);
    _banner = banner;
    _bannerShown = true;
    _lab.after(_bannerTime, () {
      if (_banner?.id != banner.id) return;
      _bannerShown = false;
      _refresh();
    });
    _refresh();
  }

  /// HTML `toggleAccordion(id)`: opens or closes a step card.
  void _toggleStep(int id) {
    _Sound.pop.play();
    setState(() {
      if (!_openSteps.remove(id)) _openSteps.add(id);
    });
  }

  /// The current step's card opens when the step changes (HTML
  /// `updateTeacherBoard()` redraws the accordion).
  void _syncOpenSteps() {
    final step = _scene.step;
    if (step == _openFor) return;
    _openFor = step;
    _openSteps
      ..clear()
      ..add(step);
  }

  // ------------------------------------------------------- scenario 1

  /// HTML `selectAsteroidSize(size)`.
  void _pickSize(_Size size) {
    if (!_lab.isLabActive) return;
    _Sound.click.play();
    setState(() {
      _scene
        ..asteroid = size
        ..tool = null;
    });
  }

  /// HTML `selectWeatherTool(tool)`.
  void _pickTool(_Tool tool) {
    if (!_lab.isLabActive) return;
    _Sound.click.play();
    setState(() => _scene.tool = tool);
  }

  /// Where the ray through the stage point [at] meets the Moon (world), or
  /// null (HTML `raycaster.intersectObject(moonMesh)`).
  _V? _moonHit(Offset at) {
    final cam = _scene.cam;
    final dir = cam.ray(at);
    final t = _hitSphere(cam.eye, dir, _moonR);
    return t == null ? null : cam.eye + dir * t;
  }

  /// A tap on the Moon with an asteroid picked (HTML `onCanvasPointerDown`).
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.tool != null) return;
    final hit = _moonHit(d.localPosition);
    if (hit != null) _launch(hit);
  }

  /// HTML `launchAsteroidImpact(hit, normal, size)`: the asteroid falls in.
  void _launch(_V hit) {
    final s = _scene;
    _Sound.pop.play();
    s.flights.add(_Flight(s.asteroid, hit, s.time));
    _refresh();
  }

  /// The asteroid lands: the boom, the crater where it hit (in the Moon's
  /// frame, so it turns with the Moon), the debris, the banner and the
  /// step check (a Small one in step 1, a Large one in step 2).
  void _impact(_Flight f) {
    final s = _scene;
    _Sound.boom.play();
    s
      ..craters.add(_Crater(s.toMoon(f.normal), f.size.crater))
      ..spawnDebris(f);
    _showBanner((id) => _Banner.crater(f.size, id));
    if (s.step == 1 && f.size == _Size.small) {
      _progressStep();
    } else if (s.step == 2 && f.size == _Size.large) {
      _progressStep();
    }
  }

  /// Screen-reader tap on the Moon: drops the picked asteroid on the
  /// Moon's visible face (a little apart from the craters already made),
  /// or tries the picked weather tool there.
  void _tapMoonNode() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    final cam = s.cam;
    final r = cam.sphereRadius(_moonR) * 0.5;
    final k = s.craters.length + s.flights.length;
    final angle = k * 2.4;
    final at = cam.center + Offset(math.cos(angle), math.sin(angle)) * r;
    if (s.tool != null) {
      _weatherDown(at);
      return;
    }
    final hit = _moonHit(at);
    if (hit != null) _launch(hit);
  }

  /// HTML pointerdown with a weather tool on the Moon: a particle and, in
  /// step 3, the banner and the test (both tools tried: the next step).
  void _weatherDown(Offset at) {
    final s = _scene;
    final tool = s.tool;
    final hit = _moonHit(at);
    if (tool == null || hit == null) return;
    s.spawnPuff(hit, tool);
    if (s.step == 3) {
      _showBanner((id) => _Banner.weather(tool, id));
      _Sound.click.play();
      s.tested.add(tool);
      if (s.tested.length == _Tool.values.length) _progressStep();
    }
  }

  /// HTML pointermove with a weather tool held on the Moon: a trail of
  /// particles.
  void _weatherMove(Offset at) {
    final s = _scene;
    final tool = s.tool;
    final hit = _moonHit(at);
    if (tool != null && hit != null) s.spawnPuff(hit, tool);
  }

  // ------------------------------------------------------- scenario 2

  /// The orbit angle (whole degrees) under the stage point [at]: the
  /// pointer's ray meets the orbital plane y = 0 (HTML
  /// `raycaster.ray.intersectPlane`).
  int? _planeAngle(Offset at) {
    final cam = _scene.cam;
    final dir = cam.ray(at);
    if (dir.y > -1e-6) return null;
    final t = -cam.eye.y / dir.y;
    final p = cam.eye + dir * t;
    var deg = math.atan2(p.z, p.x) * 180 / math.pi;
    if (deg < 0) deg += 360;
    return deg.round() % 360;
  }

  /// HTML step checks when the comet moves (drag or slider): towards the
  /// Sun (step 1), at perihelion (step 2), back at the far end (step 3).
  void _setAngle(int angle) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1) return;
    s.cometAngle = angle;
    if (s.step == 1 && (angle > 280 || angle < 80)) {
      _progressStep();
    } else if (s.step == 2 && (angle > 340 || angle < 20)) {
      _progressStep();
    } else if (s.step == 3 && angle > 140 && angle < 220) {
      _progressStep();
    }
    _refresh();
  }

  /// Whether the stage point [at] is on the comet (with its coma, at
  /// least a finger wide).
  bool _onComet(Offset at) {
    final cam = _scene.cam;
    final pos = _scene.cometPos;
    final reach = math.max(
      _minTouch / 2 / _fit,
      _comaR * _cometBoost * cam.scaleAt(pos),
    );
    return (cam.p(pos) - at).distance <= reach;
  }

  // ---------------------------------------------------------------- popups

  /// HTML `triggerConclusion()`: the scenario's summary (Scenario 2 then
  /// leads to the mastery popup). The step is marked done.
  void _triggerConclusion() {
    final s = _scene;
    if (!_lab.isLabActive || s.step < _stepCount) return;
    s.step = _stepCount + 1;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    _lab.showPopup(() => _summaryPopup(sc));
    _refresh();
  }

  /// HTML `#summary-modal`: 'Observation Summary', the illustration,
  /// 'Scenario N Summary', the summary and the next-step note. Scenario 1
  /// offers 'Next Scenario' (HTML `proceedToNextScenario()`); Scenario 2
  /// continues to the mastery popup (the HTML jumped straight to it, so
  /// its summary was never seen).
  LabPopupContent _summaryPopup(int sc) {
    final n = sc + 1;
    return LabPopupContent(
      title: _t('summary_header'),
      icon: Icons.check_circle,
      accent: _Colors.sky500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          scenario: sc,
          title: labFormat(_t('sc_complete'), {'n': n}),
          heading: _t('s${n}_sum_head'),
          paragraph: _t('s${n}_sum_p'),
          notes: sc == 0
              ? [_t('s1_sum_box')]
              : [_t('s2_sum_near'), _t('s2_sum_away')],
          next: _t('sc${n}_complete_msg'),
          windLabel: _t('tool_wind'),
          waterLabel: _t('tool_water'),
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        if (sc == 0)
          LabAction(
            label: _t('next_sc'),
            icon: Icons.arrow_forward,
            color: _Colors.sky600,
            foreground: _Colors.white,
            silent: true,
            onTap: _nextScenario,
          )
        else
          LabAction(
            label: _lab.t('btn_continue'),
            icon: Icons.emoji_events,
            color: _Colors.sky600,
            foreground: _Colors.white,
            silent: true,
            onTap: _showMastery,
          ),
      ],
    );
  }

  /// HTML `proceedToNextScenario()`: Scenario 2.
  void _nextScenario() {
    _Sound.scenario.play();
    _loadScenario(1);
  }

  /// HTML `#success-modal` with `confetti({particleCount: 150, spread: 70,
  /// origin: {y: 0.3}})`: 'Mastery Achieved!' and 'Restart Entire Lab'.
  void _showMastery() {
    _scene.confetti
      ..size = _canvasSize
      ..burst();
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('mastery_achieved'),
        icon: Icons.stars,
        accent: _Colors.yellow500,
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
            color: _Colors.sky600,
            foreground: _Colors.white,
            onTap: _lab.requestFullReset,
          ),
        ],
      ),
    );
  }

  /// HTML `#compare-btn-container` 'Summary' (from step 4; it stays to open
  /// the summary again).
  LabAction _summaryAction({bool highlight = false}) => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.check_circle,
    color: _Colors.sky500,
    foreground: _Colors.white,
    highlight: highlight,
    silent: true,
    onTap: _triggerConclusion,
  );

  // ------------------------------------------------------------- gestures

  /// Size of the canvas (for the confetti).
  Size get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : _design;
  }

  /// Which presses the scene takes as drags: a weather tool on the Moon;
  /// the comet, or (camera locked, as in the HTML) anywhere in
  /// Scenario 2. Other drags pan the canvas when it is unlocked.
  bool _canGrab(PointerDownEvent e) {
    final s = _scene;
    if (!_lab.isLabActive || _lab.popup != null) return false;
    if (s.scenario == 0) {
      return s.tool != null && _moonHit(e.localPosition) != null;
    }
    return _lab.camLocked || _onComet(e.localPosition);
  }

  /// HTML `onCanvasPointerDown`.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (s.scenario == 0) {
      _weatherDown(d.localPosition);
      return;
    }
    s.dragging = true;
    final angle = _planeAngle(d.localPosition);
    if (angle != null) _setAngle(angle);
  }

  /// HTML `onCanvasPointerMove`.
  void _onDrag(DragUpdateDetails d) {
    final s = _scene;
    if (s.scenario == 0) {
      _weatherMove(d.localPosition);
      return;
    }
    if (!s.dragging) return;
    final angle = _planeAngle(d.localPosition);
    if (angle != null) _setAngle(angle);
  }

  void _onDragEnd(DragEndDetails d) => _release();

  /// HTML `onCanvasPointerUp`.
  void _release() {
    if (!_scene.dragging) return;
    _scene.dragging = false;
    _refresh();
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        _syncFrame();
        _syncOpenSteps();
        final p = _lab.palette;
        final s = context.labScale;
        final scene = _scene;
        final data = _data;
        final n = scene.scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.nightlight_round,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: scene.step,
          // HTML `updateTeacherBoard()`: `hud[step]`.
          hud: _t('s${n}_hud_${scene.step.clamp(1, _stepCount)}'),
          actions: [if (scene.step >= _stepCount) _summaryAction()],
          onReset: _reset,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepAccordion(
            steps: data.steps,
            current: scene.step,
            open: _openSteps,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            taskLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            resultLabel: _t('observation'),
            onToggle: _toggleStep,
          ),
          overlays: _overlays(context, s),
          stage: _buildStage(p),
        );
      },
    );
  }

  /// Canvas cards: the Asteroid Tray / Weather Tools (Scenario 1) or the
  /// Comet Telemetry (Scenario 2) on the right, the feedback banner, the
  /// 'Summary' button from step 4 and the confetti.
  List<Widget> _overlays(BuildContext context, double s) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final scene = _scene;
    // On phones the cards keep clear of the HUD at the bottom.
    final hudRoom = _lab.isSidebarOpen ? (compact ? 64 : 76) * s : 0.0;
    final banner = _banner;
    return [
      Positioned(
        key: ValueKey('ch12a5-panel-${scene.scenario}'),
        right: inset.right,
        top: inset.top,
        bottom: inset.bottom + (compact ? hudRoom : 8),
        child: Align(
          alignment: Alignment.topRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topRight,
            child: scene.scenario == 0
                ? _trayPanel(s, compact)
                : _cometPanel(s, compact),
          ),
        ),
      ),
      // The summary on the canvas (above the HUD) so it is in reach on
      // phones too.
      if (scene.step >= _stepCount && _lab.popup == null)
        Positioned(
          key: const ValueKey('ch12a5-summary'),
          bottom: inset.bottom + hudRoom + (compact ? 0 : 12) * s,
          left: inset.left,
          right: inset.right + (compact ? 200 : 0) * s,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LabActionButton(
                action: _summaryAction(highlight: true),
                scale: s,
                expand: false,
              ),
            ),
          ),
        ),
      if (banner != null)
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(
                left: inset.left,
                right: inset.right + (compact ? 210 : 300) * s,
                top: inset.top + (compact ? 44 : 64) * s,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: _VfxBanner(
                  key: const ValueKey('ch12a5-banner'),
                  text: _bannerText(banner),
                  icon: _bannerIcon(banner),
                  shown: _bannerShown,
                  scale: s,
                ),
              ),
            ),
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(
          child: SizedBox.expand(
            key: _canvasKey,
            child: CustomPaint(
              painter: _ConfettiPainter(scene.confetti, repaint: _frame),
            ),
          ),
        ),
      ),
    ];
  }

  /// HTML: the size's name (`size_small` …) in the current language.
  String _sizeName(_Size size) => _t(size.key);

  String _bannerText(_Banner b) {
    final size = b.size;
    if (size != null) {
      return labFormat(_t('crater_created_msg'), {
        'size': _sizeName(size).toUpperCase(),
      });
    }
    return _t(b.tool!.effectKey);
  }

  /// HTML banner icons: a meteor for an impact, wind or a drop.
  IconData _bannerIcon(_Banner b) =>
      b.tool?.icon ?? Icons.local_fire_department;

  /// HTML `#scenario1-ui-panel`: the Asteroid Tray and, from step 3, the
  /// Weather Tools.
  Widget _trayPanel(double s, bool compact) {
    final scene = _scene;
    final tool = scene.tool;
    return _AsteroidTray(
      scale: s,
      compact: compact,
      title: _t('asteroid_tray'),
      hint: _t('drag_or_click'),
      sizes: {for (final size in _Size.values) size: _sizeName(size)},
      selected: tool == null ? scene.asteroid : null,
      onSize: _pickSize,
      // HTML `selectAsteroidSize()` tip; the general tip once a weather
      // tool is picked (the HTML kept naming the last size).
      tip: tool == null
          ? labFormat(_t('selected_ast_tip'), {
              'size': _sizeName(scene.asteroid),
            })
          : _t('tray_tip'),
      showTools: scene.toolsShown,
      toolsTitle: _t('weather_tools'),
      toolsBadge: _t('step3_tool'),
      tools: {for (final t in _Tool.values) t: _t(t.key)},
      tool: tool,
      onTool: _pickTool,
      toolTip: tool == null
          ? _t('weather_tip')
          : labFormat(_t('selected_tool_tip'), {'tool': _t(tool.key)}),
    );
  }

  /// HTML `#scenario2-ui-panel`: the Comet Telemetry with the orbit slider.
  Widget _cometPanel(double s, bool compact) {
    final scene = _scene;
    final hot = scene.hot;
    return _CometPanel(
      scale: s,
      compact: compact,
      title: _t('comet_telemetry'),
      badge: _t(hot ? 'badge_hot' : 'badge_cold'),
      hot: hot,
      description: _t('comet_desc'),
      distanceLabel: _t('dist_to_sun'),
      distance: '${(scene.sunDistance * _auPerUnit).toStringAsFixed(1)} AU',
      tailLabel: _t('tail_status'),
      tail: _t(hot ? 'tail_glowing' : 'tail_none'),
      sliderLabel: _t('drag_orbit'),
      angle: scene.cometAngle,
      onAngle: _setAngle,
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
        // Canvas labels stay readable when the stage is drawn small.
        final labelSize =
            _labelPx * (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // The Moon and the comet have their own nodes ([_targets]).
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _dragSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onDown = _onDown
                      ..onUpdate = _onDrag
                      ..onEnd = _onDragEnd
                      ..onCancel = _release,
                  ),
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
                  ),
            },
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
                        moonMesh: _moonMesh,
                        stars: _stars,
                        repaint: _frame,
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        labelSize: labelSize,
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
        );
      },
    );
  }

  /// Screen-reader nodes over the Moon (Scenario 1) and the comet
  /// (Scenario 2), where they are drawn. They take no touches themselves:
  /// taps reach the scene below.
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive) return const SizedBox.shrink();
    final cam = s.cam;
    final min = _minTouch / _fit;
    if (s.scenario == 0) {
      final r = cam.sphereRadius(_moonR);
      return Stack(
        children: [
          Positioned.fromRect(
            rect: Rect.fromCircle(center: cam.center, radius: r * 0.72),
            child: Semantics(
              key: const ValueKey('ch12a5-moon'),
              container: true,
              button: true,
              label: _t('lbl_moon'),
              onTap: _tapMoonNode,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      );
    }
    final pos = s.cometPos;
    final reach = math.max(min / 2, _comaR * _cometBoost * cam.scaleAt(pos));
    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.fromCircle(center: cam.p(pos), radius: reach),
          child: Semantics(
            key: const ValueKey('ch12a5-comet'),
            container: true,
            label: _t('lbl_comet'),
            value: '${s.cometAngle}°',
            increasedValue: '${(s.cometAngle + 10) % 360}°',
            decreasedValue: '${(s.cometAngle + 350) % 360}°',
            onIncrease: () => _setAngle((s.cometAngle + 10) % 360),
            onDecrease: () => _setAngle((s.cometAngle + 350) % 360),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- canvas UI

/// The HTML's dark overlay card (`glass-panel rounded-3xl border-2
/// border-sky-500/50 bg-slate-900/95 shadow-2xl`), dark in both themes.
class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.width,
    required this.scale,
    required this.child,
    this.padding = 16,
  });

  final double width;
  final double scale;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: width * s,
      padding: EdgeInsets.all(padding * s),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: _Colors.panelBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: LabInk.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A heading row of an overlay card: icon and uppercase title on the left,
/// a small badge on the right.
class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.icon,
    required this.title,
    required this.color,
    required this.badge,
    required this.badgeColor,
    required this.badgeText,
    required this.scale,
    this.badgeSize = 10,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String badge;
  final Color badgeColor;
  final Color badgeText;
  final double scale;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Icon(icon, size: 14 * s, color: color),
        SizedBox(width: 6 * s),
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 2,
            style: TextStyle(
              color: color,
              fontSize: 12 * s,
              fontWeight: FontWeight.w900,
              letterSpacing: labLetterSpacing(title, 0.4),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: 6 * s),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4 * s),
            ),
            child: Text(
              badge,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: badgeText,
                fontSize: badgeSize * s,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                fontFamilyFallback: LabFont.active.fallback,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// HTML `.tray-item`: a rounded tile with a thick border; `.selected`
/// turns it sky blue with a glow. It lifts a little while pressed.
class _TrayTile extends StatefulWidget {
  const _TrayTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scale,
    required this.child,
    this.fill = const Color(0xCC1E293B),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scale;
  final Color fill;
  final Widget child;

  @override
  State<_TrayTile> createState() => _TrayTileState();
}

class _TrayTileState extends State<_TrayTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            constraints: BoxConstraints(minHeight: 44 * s),
            decoration: BoxDecoration(
              color: selected ? const Color(0x3338BDF8) : widget.fill,
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(
                color: selected ? _Colors.sky400 : _Colors.slate700,
                width: 2,
              ),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x6638BDF8), blurRadius: 16)]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Fades a section in while it rises 10 px (HTML `animate-fade-in-up`).
class _FadeInUp extends StatelessWidget {
  const _FadeInUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, k, child) => Opacity(
        opacity: k,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - k)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// HTML `#scenario1-ui-panel`: the Asteroid Tray (Small, Medium, Large)
/// with its tip and, from step 3, the Weather Tools (Wind, Water).
class _AsteroidTray extends StatelessWidget {
  const _AsteroidTray({
    required this.scale,
    required this.compact,
    required this.title,
    required this.hint,
    required this.sizes,
    required this.selected,
    required this.onSize,
    required this.tip,
    required this.showTools,
    required this.toolsTitle,
    required this.toolsBadge,
    required this.tools,
    required this.tool,
    required this.onTool,
    required this.toolTip,
  });

  final double scale;
  final bool compact;
  final String title;
  final String hint;
  final Map<_Size, String> sizes;

  /// The highlighted size (none while a weather tool is picked).
  final _Size? selected;
  final ValueChanged<_Size> onSize;
  final String tip;
  final bool showTools;
  final String toolsTitle;
  final String toolsBadge;
  final Map<_Tool, String> tools;
  final _Tool? tool;
  final ValueChanged<_Tool> onTool;
  final String toolTip;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final gap = (compact ? 8 : 12) * s;
    return _PanelCard(
      width: compact ? 248 : 288,
      padding: compact ? 12 : 16,
      scale: s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            icon: Icons.bubble_chart,
            title: title,
            color: _Colors.sky400,
            badge: hint,
            badgeColor: const Color(0x330EA5E9),
            badgeText: _Colors.sky300,
            scale: s,
          ),
          SizedBox(height: 8 * s),
          const Divider(height: 1, thickness: 1, color: _Colors.slate700),
          SizedBox(height: 8 * s),
          Row(
            children: [
              for (final size in _Size.values) ...[
                if (size != _Size.small) SizedBox(width: 8 * s),
                Expanded(
                  child: _TrayTile(
                    label: sizes[size]!,
                    selected: selected == size,
                    onTap: () => onSize(size),
                    scale: s,
                    child: Padding(
                      padding: EdgeInsets.all((compact ? 6 : 10) * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SizeDot(size: size, scale: s),
                          SizedBox(height: 4 * s),
                          Text(
                            sizes[size]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _Colors.slate200,
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6 * s),
          Text(
            tip,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Colors.slate300,
              fontSize: 11 * s,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          if (showTools) ...[
            SizedBox(height: gap),
            _FadeInUp(child: _toolsSection(s)),
          ],
        ],
      ),
    );
  }

  /// HTML `#weather-tools-section`.
  Widget _toolsSection(double s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: _Colors.slate800),
        SizedBox(height: 8 * s),
        _PanelHeading(
          icon: Icons.thunderstorm,
          title: toolsTitle,
          color: _Colors.amber400,
          badge: toolsBadge,
          badgeColor: const Color(0x33F59E0B),
          badgeText: _Colors.amber300,
          scale: s,
        ),
        SizedBox(height: 8 * s),
        Row(
          children: [
            for (final t in _Tool.values) ...[
              if (t != _Tool.wind) SizedBox(width: 8 * s),
              Expanded(
                child: _TrayTile(
                  label: tools[t]!,
                  selected: tool == t,
                  onTap: () => onTool(t),
                  scale: s,
                  fill: const Color(0xE61E293B),
                  child: Padding(
                    padding: EdgeInsets.all((compact ? 6 : 10) * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.icon, size: 22 * s, color: t.iconColor),
                        SizedBox(width: 6 * s),
                        Flexible(
                          child: Text(
                            tools[t]!,
                            maxLines: 2,
                            style: TextStyle(
                              color: _Colors.white,
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6 * s),
        Text(
          toolTip,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xE6FDE68A),
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// The tray's asteroid dot inside its dark round well (HTML `w-8 h-8
/// rounded-full bg-slate-700/60` with a glowing dot).
class _SizeDot extends StatelessWidget {
  const _SizeDot({required this.size, required this.scale});

  final _Size size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 32 * s,
      height: 32 * s,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0x99334155),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size.dot * s,
        height: size.dot * s,
        decoration: BoxDecoration(
          color: size.dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: size.dotGlow, blurRadius: size.glowBlur),
          ],
        ),
      ),
    );
  }
}

/// HTML `#scenario2-ui-panel`: Comet Telemetry with the status badge, the
/// description, the distance and tail rows and the orbit slider.
class _CometPanel extends StatelessWidget {
  const _CometPanel({
    required this.scale,
    required this.compact,
    required this.title,
    required this.badge,
    required this.hot,
    required this.description,
    required this.distanceLabel,
    required this.distance,
    required this.tailLabel,
    required this.tail,
    required this.sliderLabel,
    required this.angle,
    required this.onAngle,
  });

  final double scale;
  final bool compact;
  final String title;
  final String badge;
  final bool hot;
  final String description;
  final String distanceLabel;
  final String distance;
  final String tailLabel;
  final String tail;
  final String sliderLabel;
  final int angle;
  final ValueChanged<int> onAngle;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rowStyle = TextStyle(
      color: _Colors.slate400,
      fontSize: 12 * s,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
    return _PanelCard(
      width: compact ? 248 : 288,
      padding: compact ? 12 : 16,
      scale: s,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            icon: Icons.local_fire_department,
            title: title,
            color: _Colors.sky400,
            badge: badge,
            badgeColor: hot ? const Color(0x33F59E0B) : const Color(0x330EA5E9),
            badgeText: hot ? _Colors.amber300 : _Colors.sky300,
            badgeSize: 11,
            scale: s,
          ),
          SizedBox(height: 8 * s),
          const Divider(height: 1, thickness: 1, color: _Colors.slate700),
          SizedBox(height: 8 * s),
          if (!compact) ...[
            Text(
              description,
              style: TextStyle(
                color: _Colors.slate300,
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                height: 1.55,
              ),
            ),
            SizedBox(height: 8 * s),
            const Divider(height: 1, thickness: 1, color: _Colors.slate800),
            SizedBox(height: 8 * s),
          ],
          _row(
            distanceLabel,
            distance,
            rowStyle,
            rowStyle.copyWith(color: _Colors.sky400, fontFamily: 'monospace'),
            s,
          ),
          SizedBox(height: 6 * s),
          _row(
            tailLabel,
            tail,
            rowStyle,
            hot
                ? rowStyle.copyWith(
                    color: _Colors.emerald400,
                    fontFamily: 'monospace',
                  )
                : rowStyle,
            s,
          ),
          SizedBox(height: 8 * s),
          const Divider(height: 1, thickness: 1, color: _Colors.slate800),
          SizedBox(height: 8 * s),
          Row(
            children: [
              Icon(Icons.swap_horiz, size: 14 * s, color: _Colors.amber400),
              SizedBox(width: 4 * s),
              Expanded(
                child: Text(
                  sliderLabel.toUpperCase(),
                  style: TextStyle(
                    color: _Colors.amber400,
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w900,
                    letterSpacing: labLetterSpacing(sliderLabel, 0.3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8 * s,
              activeTrackColor: _Colors.sky400,
              inactiveTrackColor: _Colors.sky400,
              thumbColor: _Colors.white,
              overlayColor: const Color(0x3338BDF8),
              thumbShape: _RingThumb(radius: 12 * s),
              trackShape: const RoundedRectSliderTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: angle.toDouble(),
              max: 360,
              divisions: 360,
              semanticFormatterCallback: (v) => '${v.round()}°',
              onChanged: (v) => onAngle(v.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
    double s,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Text(label, style: labelStyle)),
        SizedBox(width: 8 * s),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: valueStyle),
        ),
      ],
    );
  }
}

/// HTML range thumb: a white 24 px disc with a 2 px sky border and a soft
/// shadow.
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
    canvas
      ..drawCircle(
        center + const Offset(0, 2),
        radius,
        Paint()
          ..color = const Color(0x4D000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(center, radius, Paint()..color = _Colors.white)
      ..drawCircle(
        center,
        radius - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _Colors.sky400,
      );
  }
}

/// HTML `#vfx-feedback-banner`: the impact or weather message with its
/// icon, fading in and out.
class _VfxBanner extends StatelessWidget {
  const _VfxBanner({
    super.key,
    required this.text,
    required this.icon,
    required this.shown,
    required this.scale,
  });

  final String text;
  final IconData icon;
  final bool shown;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return AnimatedSlide(
      offset: shown ? Offset.zero : const Offset(0, -0.2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          constraints: BoxConstraints(maxWidth: 420 * s),
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 9 * s),
          decoration: BoxDecoration(
            color: const Color(0xF20F172A),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: const Color(0xCC38BDF8), width: 2),
            boxShadow: const [
              BoxShadow(
                color: LabInk.shadowStrong,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18 * s, color: _Colors.sky400),
              SizedBox(width: 8 * s),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _Colors.white,
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
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

// ------------------------------------------------------------------ sidebar

/// HTML `#teacher-content` "Observation Step" accordion: a card per step
/// ('Step N' with a number or a tick) that opens to its Task, Action and
/// Result. The current step is sky blue and open; done steps are green.
class _StepAccordion extends StatelessWidget {
  const _StepAccordion({
    required this.steps,
    required this.current,
    required this.open,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.taskLabel,
    required this.actionLabel,
    required this.resultLabel,
    required this.onToggle,
  });

  final List<LabStep> steps;
  final int current;
  final Set<int> open;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String taskLabel;
  final String actionLabel;
  final String resultLabel;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * scale),
            child: _card(i),
          ),
      ],
    );
  }

  Widget _card(int i) {
    final p = palette;
    final s = scale;
    final f = fontScale;
    final dark = p.isDark;
    final now = i == current;
    final done = i < current;
    final expanded = open.contains(i);
    final step = steps[i - 1];
    final Color border, header, text, badge, badgeText, badgeBorder;
    if (now) {
      border = _Colors.sky500;
      header = dark ? _Colors.slate800 : const Color(0x1A0EA5E9);
      text = dark ? _Colors.sky400 : _Colors.sky600;
      badge = _Colors.sky500;
      badgeText = _Colors.slate950;
      badgeBorder = _Colors.sky400;
    } else if (done) {
      border = const Color(0x8010B981);
      header = dark ? const Color(0x800F172A) : _Colors.slate100;
      text = dark ? _Colors.emerald400 : _Colors.emerald600;
      badge = const Color(0x3310B981);
      badgeText = _Colors.emerald500;
      badgeBorder = const Color(0x6610B981);
    } else {
      border = dark ? _Colors.slate800 : _Colors.slate300;
      header = dark ? const Color(0x800F172A) : _Colors.slate100;
      text = dark ? _Colors.slate400 : _Colors.slate500;
      badge = _Colors.slate800;
      badgeText = _Colors.slate400;
      badgeBorder = _Colors.slate600;
    }
    final radius = BorderRadius.circular(12);
    final strong = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);
    final body = TextStyle(
      color: dark ? _Colors.slate300 : _Colors.slate700,
      fontSize: 12 * f,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: border),
        boxShadow: now
            ? const [
                BoxShadow(color: Color(0x4D0EA5E9), spreadRadius: 1),
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
              color: header,
              child: InkWell(
                onTap: () => onToggle(i),
                child: Padding(
                  padding: EdgeInsets.all(12 * s),
                  child: Row(
                    children: [
                      Container(
                        width: 20 * s,
                        height: 20 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badge,
                          shape: BoxShape.circle,
                          border: Border.all(color: badgeBorder),
                        ),
                        child: done
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
                          '$stepLabel $i',
                          style: TextStyle(
                            color: text,
                            fontSize: 12 * f,
                            fontWeight: now ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18 * s,
                        color: text.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded)
              _FadeInUp(
                child: Container(
                  padding: EdgeInsets.all(14 * s),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0x660F172A) : _Colors.slate50,
                    border: Border(
                      top: BorderSide(
                        color: dark ? _Colors.slate800 : _Colors.slate200,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$taskLabel:'.toUpperCase(),
                        style: TextStyle(
                          color: _Colors.sky500,
                          fontSize: 10 * f,
                          fontWeight: FontWeight.w800,
                          letterSpacing: labLetterSpacing(taskLabel, 0.8),
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        step.concept,
                        style: body.copyWith(
                          color: dark ? _Colors.slate200 : _Colors.slate800,
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$actionLabel: ', style: strong),
                            TextSpan(text: step.action),
                          ],
                        ),
                        style: body,
                      ),
                      SizedBox(height: 8 * s),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$resultLabel: ', style: strong),
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
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- popups

/// A summary line with the STRINGS markup: `*text*` bold (the first one,
/// a lead such as 'Near the Sun:', in [leadColor]) and `_text_` bold and
/// underlined.
TextSpan _rich(String text, TextStyle strong, {Color? leadColor}) {
  final spans = <InlineSpan>[];
  final plain = StringBuffer();
  void flush() {
    if (plain.isEmpty) return;
    spans.add(TextSpan(text: plain.toString()));
    plain.clear();
  }

  var i = 0;
  while (i < text.length) {
    final ch = text[i];
    final end = ch == '*' || ch == '_' ? text.indexOf(ch, i + 1) : -1;
    if (end > i) {
      flush();
      final lead = i == 0 && ch == '*' && leadColor != null;
      spans.add(
        TextSpan(
          text: text.substring(i + 1, end),
          style: lead
              ? strong.copyWith(color: leadColor)
              : ch == '_'
              ? strong.copyWith(decoration: TextDecoration.underline)
              : strong,
        ),
      );
      i = end + 1;
      continue;
    }
    plain.write(ch);
    i++;
  }
  flush();
  return TextSpan(children: spans);
}

/// HTML `#summary-modal` body: the illustration, 'Scenario N Summary', the
/// summary (heading, paragraph, boxed notes) and the next-step note.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.scenario,
    required this.title,
    required this.heading,
    required this.paragraph,
    required this.notes,
    required this.next,
    required this.windLabel,
    required this.waterLabel,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final int scenario;
  final String title;
  final String heading;
  final String paragraph;
  final List<String> notes;
  final String next;
  final String windLabel;
  final String waterLabel;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final dark = p.isDark;
    final strong = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);
    final body = TextStyle(
      color: dark ? _Colors.slate200 : _Colors.slate700,
      fontSize: 13 * f,
      fontWeight: FontWeight.w500,
      height: 1.6,
    );
    final headColor = scenario == 0
        ? (dark ? _Colors.sky400 : _Colors.sky600)
        : (dark ? _Colors.amber400 : _Colors.amber600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 320 * s),
            height: 150 * s,
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: const Color(0xCC020617),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _Colors.slate800),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: _SummaryArtPainter(
                scenario: scenario,
                windLabel: windLabel,
                waterLabel: waterLabel,
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
            fontSize: 19 * f,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: dark ? const Color(0x801E293B) : _Colors.slate100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0x99334155) : _Colors.slate200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                heading,
                style: TextStyle(
                  color: headColor,
                  fontSize: 15 * f,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8 * s),
              Text.rich(_rich(paragraph, strong), style: body),
              SizedBox(height: 12 * s),
              if (scenario == 0)
                _weatherNote(notes.first, strong, body, s, f)
              else
                _cometNotes(strong, body, s, f),
            ],
          ),
        ),
        SizedBox(height: 14 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0x330EA5E9), Color(0x332563EB)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x9938BDF8), width: 2),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20 * s, color: _Colors.sky400),
              SizedBox(width: 10 * s),
              Expanded(
                child: Text(
                  next,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dark ? _Colors.sky300 : _Colors.sky700,
                    fontSize: 12.5 * f,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// HTML: the red-bordered box with wind + drop '= X' and the note.
  Widget _weatherNote(
    String note,
    TextStyle strong,
    TextStyle body,
    double s,
    double f,
  ) {
    final dark = palette.isDark;
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: dark ? const Color(0xCC0F172A) : _Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66EF4444)),
      ),
      child: Row(
        children: [
          Icon(Icons.air, size: 18 * s, color: _Colors.cyan400),
          SizedBox(width: 4 * s),
          Icon(Icons.water_drop_outlined, size: 18 * s, color: _Colors.blue400),
          SizedBox(width: 6 * s),
          Text(
            '=',
            style: TextStyle(
              color: _Colors.red400,
              fontSize: 14 * f,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 6 * s),
          Text(
            'X',
            style: TextStyle(
              color: _Colors.red500,
              fontSize: 18 * f,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text.rich(
              _rich(note, strong),
              style: body.copyWith(
                fontSize: 12 * f,
                color: dark ? _Colors.slate300 : _Colors.slate600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML: the sky-bordered box with 'Near the Sun:' and 'Always Pointing
  /// Away:'.
  Widget _cometNotes(TextStyle strong, TextStyle body, double s, double f) {
    final dark = palette.isDark;
    final leads = [
      dark ? _Colors.sky400 : _Colors.sky600,
      dark ? _Colors.amber300 : _Colors.amber600,
    ];
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: dark ? const Color(0xCC0F172A) : _Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x660EA5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var k = 0; k < notes.length; k++) ...[
            if (k > 0) SizedBox(height: 8 * s),
            Text.rich(
              _rich(notes[k], strong, leadColor: leads[k % leads.length]),
              style: body.copyWith(fontSize: 12 * f),
            ),
          ],
        ],
      ),
    );
  }
}

/// The summary popup's SVG illustrations (viewBox 320 × 140, scaled to
/// fit): Scenario 1 a cratered Moon with an incoming asteroid next to a
/// 'Wind / Water' card crossed out in red; Scenario 2 the Sun's rays and a
/// comet whose tail points away from it.
class _SummaryArtPainter extends CustomPainter {
  _SummaryArtPainter({
    required this.scenario,
    required this.windLabel,
    required this.waterLabel,
  });

  final int scenario;
  final String windLabel;
  final String waterLabel;

  static const Size _box = Size(320, 140);

  @override
  void paint(Canvas canvas, Size size) {
    final k = math.min(size.width / _box.width, size.height / _box.height);
    canvas
      ..save()
      ..translate(
        (size.width - _box.width * k) / 2,
        (size.height - _box.height * k) / 2,
      )
      ..scale(k);
    if (scenario == 0) {
      _moon(canvas);
    } else {
      _comet(canvas);
    }
    canvas.restore();
  }

  void _moon(Canvas canvas) {
    final fill = Paint();
    canvas
      ..drawCircle(const Offset(90, 70), 50, fill..color = _Colors.slate400)
      ..drawCircle(const Offset(75, 55), 10, fill..color = _Colors.slate500)
      ..drawCircle(const Offset(105, 85), 15, fill)
      ..drawCircle(const Offset(70, 90), 8, fill)
      // The asteroid and its dashed path.
      ..drawCircle(const Offset(30, 25), 7, fill..color = _Colors.slate300);
    labDashedLine(
      canvas,
      const Offset(37, 28),
      const Offset(68, 48),
      Paint()
        ..strokeWidth = 2
        ..color = _Colors.slate50,
      dash: 3,
      gap: 3,
    );
    // The 'Wind / Water' card, crossed out.
    canvas
      ..save()
      ..translate(190, 35);
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 110, 70),
      const Radius.circular(12),
    );
    canvas
      ..drawRRect(card, Paint()..color = _Colors.slate800)
      ..drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _Colors.sky400,
      );
    _word(canvas, windLabel, const Offset(35, 32), _Colors.cyan300);
    _word(canvas, waterLabel, const Offset(35, 55), _Colors.blue400);
    final cross = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = _Colors.red500;
    canvas
      ..drawLine(const Offset(15, 20), const Offset(85, 60), cross)
      ..drawLine(const Offset(85, 20), const Offset(15, 60), cross)
      ..restore();
  }

  /// SVG `<text x y font-size="16" font-weight="bold">`: [at] is the
  /// baseline start; long (Hindi) words are squeezed into the card.
  void _word(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const room = 70.0;
    final squeeze = math.min(1.0, room / math.max(1, tp.width));
    final baseline = tp.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(squeeze);
    tp.paint(canvas, Offset(0, -baseline));
    canvas.restore();
    tp.dispose();
  }

  void _comet(Canvas canvas) {
    canvas.drawCircle(const Offset(60, 70), 40, Paint()..color = _Colors.sun);
    final ray = Paint()
      ..strokeWidth = 3
      ..color = _Colors.amber400;
    for (final (a, b) in const [
      (Offset(110, 70), Offset(140, 70)),
      (Offset(95, 35), Offset(120, 20)),
      (Offset(95, 105), Offset(120, 120)),
    ]) {
      labDashedLine(canvas, a, b, ray, dash: 4, gap: 4);
    }
    canvas
      ..save()
      ..translate(180, 70);
    final tail = Path()
      ..moveTo(0, 0)
      ..lineTo(110, -25)
      ..lineTo(110, 25)
      ..close();
    canvas
      ..drawPath(
        tail,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xE638BDF8), Color(0x000284C7)],
          ).createShader(const Rect.fromLTWH(0, -25, 110, 50))
          ..color = const Color(0xCC000000),
      )
      ..drawCircle(Offset.zero, 14, Paint()..color = _Colors.sky100)
      ..drawCircle(
        Offset.zero,
        14,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _Colors.sky400,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _SummaryArtPainter old) =>
      old.scenario != scenario ||
      old.windLabel != windLabel ||
      old.waterLabel != waterLabel;
}

/// Bounces its child (HTML `animate-bounce`, 1 s).
class _Bounce extends StatefulWidget {
  const _Bounce({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  State<_Bounce> createState() => _BounceState();
}

class _BounceState extends State<_Bounce> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Up with ease-out for the first half, down with ease-in.
        final t = _c.value;
        final k = t < 0.5
            ? Curves.easeOut.transform(t * 2)
            : 1 - Curves.easeIn.transform((t - 0.5) * 2);
        return Transform.translate(
          offset: Offset(0, -widget.height * k),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// HTML `#success-modal` body: the trophy, 'Mastery Achieved!' and the
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
            width: 72 * s,
            height: 72 * s,
            decoration: BoxDecoration(
              color: const Color(0x33EAB308),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4DEAB308)),
            ),
            child: _Bounce(
              height: 6 * s,
              child: Icon(
                Icons.emoji_events,
                size: 36 * s,
                color: p.isDark ? _Colors.yellow400 : _Colors.yellow500,
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

/// TextPainters for the canvas labels, laid out once and reused every
/// frame. Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  /// Painters kept before the cache starts over (language or size
  /// changes add new ones).
  static const int _limit = 24;

  TextPainter get(String text, double size) {
    final key = '$size|$text';
    final cached = _painters[key];
    if (cached != null) return cached;
    if (_painters.length >= _limit) dispose();
    return _painters[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
  }
}

/// The DirectionalLight's direction (towards the light).
final _V _moonLight = _moonLightAt.unit;

/// The Moon's 48 × 48 SphereGeometry lit per vertex (MeshLambertMaterial
/// is shaded per vertex in Three.js), built for one projection and reused
/// until the camera's framing changes. The Moon is evenly coloured, so its
/// shading does not change while it turns; only its craters move.
class _MoonMesh {
  ui.Vertices? _vertices;
  Object? _key;

  ui.Vertices get(_Cam cam) {
    final cached = _vertices;
    if (cached != null && cam.key == _key) return cached;
    cached?.dispose();
    const n = _moonSegments;
    final positions = <Offset>[];
    final colors = <Color>[];
    final front = <bool>[];
    for (var iy = 0; iy <= n; iy++) {
      final phi = iy / n * math.pi;
      for (var ix = 0; ix <= n; ix++) {
        final theta = ix / n * 2 * math.pi;
        final normal = _V(
          -math.cos(theta) * math.sin(phi),
          math.cos(phi),
          math.sin(theta) * math.sin(phi),
        );
        final w = normal * _moonR;
        positions.add(cam.p(w));
        colors.add(_moonShade(normal));
        front.add(normal.dot(cam.eye - w) > 0);
      }
    }
    final indices = <int>[];
    for (var iy = 0; iy < n; iy++) {
      for (var ix = 0; ix < n; ix++) {
        final a = iy * (n + 1) + ix;
        final b = a + n + 1;
        final c = b + 1;
        final d = a + 1;
        // Quads facing away are left out; the outline is clipped to the
        // Moon's disc, so the limb stays round.
        if (!(front[a] || front[b] || front[c] || front[d])) continue;
        indices.addAll([a, b, d, b, c, d]);
      }
    }
    _key = cam.key;
    return _vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );
  }

  void dispose() {
    _vertices?.dispose();
    _vertices = null;
  }
}

/// MeshLambertMaterial 0xcbe5fe under the Moon's lights at normal [n].
Color _moonShade(_V n) => _lambert(
  _Colors.moon,
  _Colors.moonAmbient,
  _moonAmbientLevel,
  _Colors.moonLight,
  _moonDirect,
  n.dot(_moonLight),
);

/// The Moon's night side (ambient light only), under its mesh.
final Color _moonNight = _moonShade(-_moonLight);

/// The 1800 background stars (HTML `bgStarsGeom`) as directions, and their
/// stage points for the last projection.
class _StarCache {
  final List<_V> _dirs = () {
    final r = math.Random(1800);
    return [
      for (var k = 0; k < _starCount; k++)
        () {
          final theta = r.nextDouble() * 2 * math.pi;
          final phi = math.acos(2 * r.nextDouble() - 1);
          return _V(
            math.sin(phi) * math.cos(theta),
            math.sin(phi) * math.sin(theta),
            math.cos(phi),
          );
        }(),
    ];
  }();

  Float32List? _points;
  Object? _key;

  Float32List points(_Cam cam, Rect bleed) {
    final key = (cam.key, cam.f, bleed);
    final cached = _points;
    if (cached != null && key == _key) return cached;
    final list = <double>[];
    for (final d in _dirs) {
      final o = cam.toward(d);
      if (o != null && bleed.contains(o)) list.addAll([o.dx, o.dy]);
    }
    _key = key;
    return _points = Float32List.fromList(list);
  }
}

/// Convex hull of [points] (monotone chain), counter-clockwise.
List<Offset> _hull(List<Offset> points) {
  if (points.length < 3) return points;
  final pts = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in pts) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in pts.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  return [...lower..removeLast(), ...upper..removeLast()];
}

/// A scene label (HTML `.object-label`): where its bottom centre goes and
/// its text.
typedef _Label = (Offset at, String text);

/// Paints the HTML Three.js scenes: the starfield; in Scenario 1 the lit
/// Moon with its old and new craters, the falling asteroids, the debris
/// and the weather particles; in Scenario 2 the orbit, the Sun and the
/// comet with its coma and tail; then the labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required this.moonMesh,
    required this.stars,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final _MoonMesh moonMesh;
  final _StarCache stars;
  final bool showLabels;
  final LabLang lang;

  /// Label text size in design px.
  final double labelSize;

  final Paint _fill = Paint();

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final cam = s.cam;
    final bleed = labBleed(size);
    // `#canvas-wrapper`, over the letterbox too.
    canvas.drawRect(bleed, _fill..color = _Colors.space);
    _paintStars(canvas, cam, bleed);
    final labels = <_Label>[];
    if (s.scenario == 0) {
      _paintMoonScene(canvas, cam, labels);
    } else {
      _paintCometScene(canvas, size, cam, labels);
    }
    if (!showLabels) return;
    for (final (at, text) in labels) {
      _label(canvas, size, at, text);
    }
  }

  /// HTML starfield: square points of 0x94a3b8 at opacity 0.6.
  void _paintStars(Canvas canvas, _Cam cam, Rect bleed) {
    final points = stars.points(cam, bleed);
    canvas.drawRawPoints(
      ui.PointMode.points,
      points,
      Paint()
        ..color = _Colors.star.withValues(alpha: _starOpacity)
        ..strokeCap = StrokeCap.square
        ..strokeWidth = _starPx * cam.focal / _Cam._focal,
    );
  }

  /// HTML `.object-label`: a dark rounded chip with white extra-bold text
  /// and a sky border; [at] is its bottom centre, kept on the stage.
  void _label(Canvas canvas, Size size, Offset at, String text) {
    final tp = texts.get(text, labelSize);
    final k = labelSize / _labelPx;
    final rect = _labelRect(size, at, text);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(_labelRadius * k));
    canvas
      ..drawRRect(
        rr.shift(Offset(0, 4 * k)),
        Paint()
          ..color = const Color(0x80000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawRRect(rr, Paint()..color = _Colors.labelBg)
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _Colors.labelBorder,
      );
    tp.paint(
      canvas,
      Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k),
    );
  }

  /// Where the label [text] with its bottom centre at [at] is drawn.
  Rect _labelRect(Size size, Offset at, String text) {
    final tp = texts.get(text, labelSize);
    final k = labelSize / _labelPx;
    final w = tp.width + 2 * _labelPadX * k;
    final h = tp.height + 2 * _labelPadY * k;
    final left = math.max(4.0, math.min(at.dx - w / 2, size.width - w - 4));
    final top = math.max(4.0, math.min(at.dy - h, size.height - h - 4));
    return Rect.fromLTWH(left, top, w, h);
  }

  // --------------------------------------------------------- scenario 1

  /// init3D() Scenario 1 group: the Moon (Lambert, per vertex), its twelve
  /// old crater rings and the impact craters (turning with it), the
  /// asteroids on their way, the debris and the weather particles.
  void _paintMoonScene(Canvas canvas, _Cam cam, List<_Label> labels) {
    final s = scene;
    final c = cam.center;
    final r = cam.sphereRadius(_moonR);
    final disc = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    canvas
      ..save()
      ..clipPath(disc)
      ..drawCircle(c, r + 1, _fill..color = _moonNight)
      ..drawVertices(moonMesh.get(cam), BlendMode.dst, Paint());
    for (final crater in _oldCraters) {
      _paintCrater(canvas, cam, crater);
    }
    for (final crater in s.craters) {
      _paintCrater(canvas, cam, crater);
    }
    canvas.restore();
    for (final f in s.flights) {
      final at = f.at(s.time);
      if (cam.depth(at) < 0.5 || _behindMoon(cam.eye, at)) continue;
      _paintRock(canvas, cam, at, f.size.rock);
    }
    _fill.color = _Colors.debris;
    for (final d in s.debris) {
      if (_behindMoon(cam.eye, d.pos)) continue;
      final radius = d.radius * math.max(0.01, d.life);
      final outline = _hull([
        for (final corner in _Poly.rock.corners) cam.p(d.pos + corner * radius),
      ]);
      canvas.drawPath(Path()..addPolygon(outline, true), _fill);
    }
    for (final p in s.puffs) {
      if (_behindMoon(cam.eye, p.pos)) continue;
      canvas.drawCircle(
        cam.p(p.pos),
        p.tool.radius * cam.scaleAt(p.pos),
        _fill..color = p.tool.particle.withValues(alpha: p.life.clamp(0, 1)),
      );
    }
    labels.add((Offset(c.dx, c.dy - r - _labelGap), _t('lbl_moon')));
  }

  /// A crater decal facing out of the Moon: an old ring (0x475569 with a
  /// hole) or an impact crater (rim ring 0x334155 round a 0x0f172a floor).
  void _paintCrater(Canvas canvas, _Cam cam, _Crater crater) {
    final n = scene.toWorld(crater.normal);
    final centre = n * (crater.impact ? _moonR + _craterLift : _oldCraterAt);
    if (n.dot(cam.eye - centre) <= 0) return;
    final (e1, e2) = _basis(n);
    final sides = crater.impact ? _craterSides : _oldCraterSides;
    List<Offset> ring(double radius) => [
      for (var k = 0; k < sides; k++)
        cam.p(
          centre +
              e1 * (radius * math.cos(k / sides * 2 * math.pi)) +
              e2 * (radius * math.sin(k / sides * 2 * math.pi)),
        ),
    ];
    if (crater.impact) {
      canvas
        ..drawPath(
          Path()..addPolygon(ring(crater.radius), true),
          _fill..color = _Colors.craterRim,
        )
        ..drawPath(
          Path()..addPolygon(ring(crater.radius * _rimInner), true),
          _fill..color = _Colors.craterFloor,
        );
      return;
    }
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addPolygon(ring(crater.radius), true)
      ..addPolygon(ring(crater.hole), true);
    canvas.drawPath(path, _fill..color = _Colors.oldCrater);
  }

  /// An asteroid: the flat-faced DodecahedronGeometry (Lambert 0x64748b)
  /// under the Moon's lights.
  void _paintRock(Canvas canvas, _Cam cam, _V at, double radius) {
    final tris = _Poly.rock.triangles;
    final positions = <Offset>[];
    final colors = <Color>[];
    for (var k = 0; k < tris.length; k += 3) {
      final a = tris[k], b = tris[k + 1], c = tris[k + 2];
      var n = (b - a).cross(c - a).unit;
      if (n.dot(a + b + c) < 0) n = -n;
      final mid = at + (a + b + c) * (radius / 3);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final color = _lambert(
        _Colors.asteroid,
        _Colors.moonAmbient,
        _moonAmbientLevel,
        _Colors.moonLight,
        _moonDirect,
        n.dot(_moonLight),
      );
      positions.addAll([
        cam.p(at + a * radius),
        cam.p(at + b * radius),
        cam.p(at + c * radius),
      ]);
      colors.addAll([color, color, color]);
    }
    if (positions.isEmpty) return;
    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
    );
    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
  }

  // --------------------------------------------------------- scenario 2

  /// init3D() Scenario 2 group: the orbit line, then the Sun and the comet,
  /// the farther one first.
  void _paintCometScene(
    Canvas canvas,
    Size size,
    _Cam cam,
    List<_Label> labels,
  ) {
    final s = scene;
    _paintOrbit(canvas, cam);
    final comet = s.cometPos;
    final sunPx = _sunR * cam.scaleAt(_V.zero);
    final sunAt = cam.p(_V.zero);
    if (cam.depth(comet) > cam.depth(_V.zero)) {
      _paintComet(canvas, cam);
      _paintSun(canvas, sunAt, sunPx);
    } else {
      _paintSun(canvas, sunAt, sunPx);
      _paintComet(canvas, cam);
    }
    final sunText = _t('lbl_sun');
    final cometText = _t('lbl_comet');
    final sunLabel = sunAt - Offset(0, sunPx + _labelGap);
    // The comet's label goes above it, or below, right or left of it when
    // it would cover the Sun or the Sun's label.
    final head = cam.p(comet);
    final r = _comaR * _cometBoost * cam.scaleAt(comet) + _labelGap;
    final box = _labelRect(size, Offset.zero, cometText).size;
    final taken = [
      _labelRect(size, sunLabel, sunText).inflate(2),
      Rect.fromCircle(center: sunAt, radius: sunPx + 2),
    ];
    final spots = [
      head - Offset(0, r),
      head + Offset(0, r + box.height),
      head + Offset(r + box.width / 2, box.height / 2),
      head - Offset(r + box.width / 2, -box.height / 2),
    ];
    var cometLabel = spots.first;
    for (final spot in spots) {
      final rect = _labelRect(size, spot, cometText);
      if (!taken.any(rect.overlaps)) {
        cometLabel = spot;
        break;
      }
    }
    labels
      ..add((sunLabel, sunText))
      ..add((cometLabel, cometText));
  }

  /// The comet's orbit (121 points, 0x0284c7 at opacity 0.5).
  void _paintOrbit(Canvas canvas, _Cam cam) {
    final path = Path();
    for (var i = 0; i <= _orbitSamples; i++) {
      final o = cam.p(_orbitAt(i / _orbitSamples * 360));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.orbit.withValues(alpha: _orbitOpacity),
    );
  }

  /// The Sun (MeshBasic 0xf59e0b) with a soft halo.
  void _paintSun(Canvas canvas, Offset at, double radius) {
    labGlow(canvas, at, radius * _sunHaloR, _Colors.sunHalo, intensity: 0.5);
    canvas.drawCircle(at, radius, _fill..color = _Colors.sun);
  }

  /// HTML `animate()` Scenario 2: the tail (a cone from the core, pointing
  /// away from the Sun) and the coma brighten and grow with the heat; the
  /// icy core (DodecahedronGeometry(1.1, 1), smooth Lambert 0xe0f2fe lit by
  /// the Sun's PointLight) turns with the orbit.
  void _paintComet(Canvas canvas, _Cam cam) {
    final s = scene;
    final c = s.cometPos;
    final away = c.unit;
    final heat = s.heat;
    final head = cam.p(c);
    if (s.hot) {
      final opacity = math.min(_tailMax, heat * _tailMax);
      if (opacity > 0.005) {
        final length = _tailLength * (1 + heat * _tailGrowLength);
        final side = _tailRadius * (1 + heat * _tailGrowSide);
        final rise = _tailRadius * (1 + heat * _tailGrowUp);
        final across = away.cross(_V.up).unit;
        final base = c + away * length;
        const sides = 24;
        final outline = _hull([
          head,
          for (var k = 0; k < sides; k++)
            cam.p(
              base +
                  across * (side * math.cos(k / sides * 2 * math.pi)) +
                  _V.up * (rise * math.sin(k / sides * 2 * math.pi)),
            ),
        ]);
        canvas.drawPath(
          Path()..addPolygon(outline, true),
          Paint()
            ..shader = ui.Gradient.linear(head, cam.p(base), [
              _Colors.tail.withValues(alpha: opacity),
              _Colors.tail.withValues(alpha: opacity * _tailFade),
            ]),
        );
      }
    }
    final comaPx = _comaR * _cometBoost * cam.scaleAt(c);
    final coma = s.hot ? math.min(_comaMax, heat * _comaMax) : _comaCold;
    if (coma > 0.005) {
      canvas.drawCircle(
        head,
        comaPx,
        Paint()
          ..shader = ui.Gradient.radial(
            head,
            comaPx,
            [
              _Colors.coma.withValues(alpha: coma),
              _Colors.coma.withValues(alpha: coma * 0.7),
              _Colors.coma.withValues(alpha: 0),
            ],
            const [0, 0.55, 1],
          ),
      );
    }
    _paintCore(canvas, cam, c, away);
  }

  void _paintCore(Canvas canvas, _Cam cam, _V c, _V away) {
    // The HTML turns the comet by −atan2(z, x); here its tail end (local
    // +z) faces away from the Sun.
    final turn = math.pi / 2 - math.atan2(away.z, away.x);
    const core = _cometR * _cometBoost;
    final tris = _Poly.icy.triangles;
    final positions = <Offset>[];
    final colors = <Color>[];
    Color shade(_V v) {
      final w = c + v * _cometR;
      final dist = w.length;
      final reach = math.max(0.0, 1 - dist / _sunReach);
      return _lambert(
        _Colors.comet,
        _Colors.cometAmbient,
        _cometAmbientLevel,
        _Colors.sunLight,
        _sunPower * reach,
        v.dot(-w * (1 / dist)),
      );
    }

    for (var k = 0; k < tris.length; k += 3) {
      final a = tris[k].turnY(turn);
      final b = tris[k + 1].turnY(turn);
      final d = tris[k + 2].turnY(turn);
      var n = (b - a).cross(d - a).unit;
      if (n.dot(a + b + d) < 0) n = -n;
      final mid = c + (a + b + d) * (core / 3);
      if (n.dot(cam.eye - mid) <= 0) continue;
      positions.addAll([
        cam.p(c + a * core),
        cam.p(c + b * core),
        cam.p(c + d * core),
      ]);
      colors.addAll([shade(a), shade(b), shade(d)]);
    }
    if (positions.isEmpty) return;
    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
    );
    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
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
