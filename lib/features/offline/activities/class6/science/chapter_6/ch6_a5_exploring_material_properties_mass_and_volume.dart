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

/// Class 6 Science • Chapter 6 • Activity 5
/// Exploring Material Properties: Mass and Volume.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A5-Exploring_Material_Properties__Mass_and_Volume.html`
/// (Three.js r128). The Three.js scene is redrawn by a small painter that
/// reproduces the HTML camera (position (0, 10, 28), look-at (0, 2, 0),
/// 45° field of view).
///
/// Scenario 1 (How Heavy or Light?): drag the water pitcher, the sand scoop
/// and the pebble scoop over cups A, B and C to fill each cup to the same
/// level, then drag each cup onto the digital balance (100 g, 160 g and
/// 210 g) and compare: equal volumes of different materials have
/// different masses.
///
/// Scenario 2 (How Much Space?): look at two identical empty tumblers, pour
/// the 200 mL bottle into Tumbler 1 and the 500 mL bottle into Tumbler 2,
/// and compare: more water takes up more space (a larger volume).
class Ch6A5ExploringMaterialPropertiesMassAndVolumePage extends StatefulWidget {
  const Ch6A5ExploringMaterialPropertiesMassAndVolumePage({super.key});

  @override
  State<Ch6A5ExploringMaterialPropertiesMassAndVolumePage> createState() =>
      _MassVolumeLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises four tones with the
/// Web Audio API; each is played with the closest bundled file: `pop`
/// (buttons, Compare Outcomes) -> pop.mp3, `pour` -> drop.mp3, `measure`
/// (the balance starts weighing) -> click.mp3 and `success` (summary
/// popup) -> success.mp3. Picking an object up plays pickup.mp3 (the HTML
/// is silent there).
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, pickup → `science/pickup.mp3`,
/// drop → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click; also the HTML `measure` beep of the balance.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// Wrong drop, object touched before its turn.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / summary popup (HTML `success`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: Compare Outcomes.
  pop('audio/class6/science/pop.mp3'),

  /// A pitcher, scoop, bottle or cup picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML `pour`: water, sand or pebbles poured.
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
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B); // headings, borders
  static const Color amber600 = Color(0xFFD97706);
  static const Color zslYellow = Color(0xFFEAB308); // tailwind `zsl.yellow`
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB); // Compare / Next buttons
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
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
  static const Color slate950 = Color(0xFF020617); // tailwind `zsl.dark`
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617, 0xf1f5f9 in the light theme.
  static const Color sceneBg = slate950;
  static const Color sceneBgLight = slate100;

  /// Tables: S1 0x334155, S2 0x1e293b.
  static const Color tableMass = slate700;
  static const Color tableVolume = slate800;

  /// Cups (0xf8fafc) and what fills them: water 0x3b82f6, sand 0xd97706,
  /// pebbles 0x475569.
  static const Color cup = slate50;
  static const Color water = blue500;
  static const Color sand = amber600;
  static const Color pebbles = slate600;

  /// Pitcher 0x38bdf8, sand scoop 0xf59e0b, pebble scoop 0x64748b.
  static const Color pitcher = sky400;
  static const Color sandScoop = amber500;
  static const Color pebbleScoop = slate500;

  /// Digital balance: base 0x1e293b, pan 0x94a3b8, display 0x0f172a and
  /// its green LED digits (#10b981).
  static const Color scaleBase = slate800;
  static const Color pan = slate400;
  static const Color display = slate900;
  static const Color led = emerald500;
  static const Color ledPanel = Color(0xFF000000);

  /// Tumbler glass 0xe2e8f0 (opacity 0.35); bottles and tumbler water
  /// 0x38bdf8.
  static const Color glass = slate200;
  static const Color bottle = sky400;

  /// Bottle caps (added: the HTML bottles are plain cylinders).
  static const Color bottleCap = blue600;

  /// Pulsing highlight of the object to move (emissive 0xeab308).
  static const Color glow = zslYellow;

  /// Text sprites: `rgba(15, 23, 42, 0.9)` with a #eab308 border; cup
  /// letters #020617.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = zslYellow;
  static const Color ink = slate950;

  /// Mass sprites of the comparison: `rgba(0, 0, 0, 0.8)`, the heaviest
  /// `rgba(245, 158, 11, 0.9)`.
  static const Color massBg = Color(0xCC000000);
  static const Color heavyBg = Color(0xE6F59E0B);

  /// `#compare-text-box`: `bg-slate-900/90`, `border-amber-500`.
  static const Color compareBg = Color(0xE60F172A);

  /// Soft contact shadows on the table.
  static const Color shadow = Color(0x59000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
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
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.amber300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: Color(0x80F59E0B),
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
    canvasBg: _Colors.sceneBgLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
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
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: _Colors.amber300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: Color(0x80F59E0B),
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
// from the HTML (see the report): each step's action says exactly what to
// drag or tap ("Fill Cup A with water: drag the Water Pitcher over Cup A
// and let go to pour."); "CLICK" is "TAP"; the HUD says "Digital Balance"
// like the scene label (the HTML mixed in "Digital Scale"); the step 1-4
// concept also says that mass is the amount of matter (NCERT); the Hindi
// readings use पाठ्यांक so no verb has to agree with तराजू. Keys marked
// "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Material Properties: Mass and Volume',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1_opt': 'Scenario 1: How Heavy or Light? Comparing Mass',
    'scen_2_opt': 'Scenario 2: How Much Space? Exploring Volume',
    's1_desc':
        'To visually discover that different materials can have different masses even when they occupy the same amount of space (volume).',
    's2_desc':
        'To visually understand that volume is the amount of space a substance occupies.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Equal volumes can be filled with different materials.',
    'step_1_1_a':
        'Fill Cup A with water: drag the Water Pitcher over Cup A and let go to pour.',
    'step_1_1_o': 'Cup A fills halfway with water.',
    'step_1_2_c': 'Equal volumes can be filled with different materials.',
    'step_1_2_a':
        'Fill Cup B with sand: drag the Sand Scoop over Cup B and let go to pour.',
    'step_1_2_o': 'Cup B fills halfway with sand.',
    'step_1_3_c': 'Equal volumes can be filled with different materials.',
    'step_1_3_a':
        'Fill Cup C with pebbles: drag the Pebble Scoop over Cup C and let go to pour.',
    'step_1_3_o': 'Cup C fills halfway with pebbles.',
    'step_1_4_c': "Mass is the amount of matter in an object, its 'heaviness'.",
    'step_1_4_a':
        'Weigh Cup A (water): drag Cup A onto the pan of the Digital Balance.',
    'step_1_4_o': 'Scale displays 100 g.',
    'step_1_5_c': 'Different materials have different masses.',
    'step_1_5_a':
        'Weigh Cup B (sand): drag Cup B onto the pan of the Digital Balance.',
    'step_1_5_o': 'Scale displays 160 g.',
    'step_1_6_c': 'Dense materials pack more mass into the same space.',
    'step_1_6_a':
        'Weigh Cup C (pebbles): drag Cup C onto the pan of the Digital Balance.',
    'step_1_6_o': 'Scale displays 210 g.',
    'step_1_7_c': 'Compare mass of equal volumes.',
    'step_1_7_a': "Compare all cups: tap the 'Compare Outcomes' button.",
    'step_1_7_o': 'Pebbles have the most mass, water the least.',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Containers can hold liquid.',
    'step_2_1_a':
        'Observe the setup: two identical empty tumblers, a small (200 mL) and a large (500 mL) water bottle.',
    'step_2_1_o': 'Identical tumblers, different bottles.',
    'step_2_2_c': 'A small amount of liquid occupies a small volume.',
    'step_2_2_a':
        'Pour the small bottle into Tumbler 1: drag the small water bottle (200 mL) over Tumbler 1 and let go.',
    'step_2_2_o': 'Water level is low.',
    'step_2_3_c': 'A larger amount of liquid occupies a larger volume.',
    'step_2_3_a':
        'Pour the large bottle into Tumbler 2: drag the large water bottle (500 mL) over Tumbler 2 and let go.',
    'step_2_3_o': 'Water level is high.',
    'step_2_4_c': 'Volume is the space occupied by matter.',
    'step_2_4_a': "Compare the tumblers: tap the 'Compare Outcomes' button.",
    'step_2_4_o': 'More liquid takes up more space.',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1': 'Step 1: DRAG the Pitcher over Cup A to pour water.',
    's1_hud_2': 'Step 2: DRAG the Sand Scoop over Cup B to pour sand.',
    's1_hud_3': 'Step 3: DRAG the Pebble Scoop over Cup C to pour pebbles.',
    's1_hud_4': 'Step 4: DRAG Cup A (water) onto the Digital Balance.',
    's1_hud_5':
        'Step 5: DRAG Cup B (sand) onto the Digital Balance to replace Cup A.',
    's1_hud_6':
        'Step 6: DRAG Cup C (pebbles) onto the Digital Balance to replace Cup B.',
    's1_hud_7': "Step 7: TAP the 'Compare Outcomes' button.",
    's1_hud_8': 'Exploration Complete! Well done.',
    's2_hud_1':
        'Step 1: Observe the empty identical tumblers and water bottles.',
    's2_hud_2':
        'Step 2: DRAG the small water bottle (200 mL) over Tumbler 1 to pour.',
    's2_hud_3':
        'Step 3: DRAG the large water bottle (500 mL) over Tumbler 2 to pour.',
    's2_hud_4': "Step 4: TAP the 'Compare Outcomes' button.",
    's2_hud_5': 'Exploration Complete! Well done.',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration Step',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    // Added.
    'obs_pending': 'Complete this step to see what happens.',
    // ------------------------------------------------- compare / summary
    'btn_compare': 'Compare Outcomes',
    'compare_s1':
        "Even though all three cups were filled to the same level (same volume), they have different 'heaviness' (mass). Pebbles have the most mass, and water has the least.",
    'compare_s2':
        'The water from the bigger bottle took up more space in the glass. This means it has a larger volume.',
    'sc_complete': 'Scenario {n} Complete!',
    's1_summary':
        "You proved: Even though all three cups were filled to the same level (same volume), they have different 'heaviness' (mass). Pebbles have the most mass, and water has the least.",
    's2_summary':
        'You proved: The water from the bigger bottle took up more space in the glass. This means it has a larger volume.',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You differentiated between mass and volume! Objects of the same size (volume) can have completely different masses.',
    // ------------------------------------------------------ scene labels
    'lbl_cupA': 'Cup A (Water)',
    'lbl_cupB': 'Cup B (Sand)',
    'lbl_cupC': 'Cup C (Pebbles)',
    'lbl_pitcher': 'Water Pitcher',
    'lbl_sand': 'Sand Scoop',
    'lbl_pebbles': 'Pebble Scoop',
    'lbl_scale': 'Digital Balance',
    'lbl_tumbler1': 'Tumbler 1',
    'lbl_tumbler2': 'Tumbler 2',
    'lbl_bot_small': 'Small Bottle (200 mL)',
    'lbl_bot_large': 'Large Bottle (500 mL)',
    'unit_g': 'g',
    'unit_ml': 'mL',
    // ---------------------------------------------------- toasts (added)
    'cup_a': 'Cup A',
    'cup_b': 'Cup B',
    'cup_c': 'Cup C',
    'first_1_1': 'First fill Cup A with water.',
    'first_1_2': 'First fill Cup B with sand.',
    'first_1_3': 'First fill Cup C with pebbles.',
    'first_1_4': 'First weigh Cup A.',
    'first_1_5': 'First weigh Cup B.',
    'first_1_6': 'First weigh Cup C.',
    'first_1_7': "Tap the 'Compare Outcomes' button.",
    'first_2_2': 'First pour the small bottle into Tumbler 1.',
    'wrong_pitcher': 'That is not Cup A! Pour the water into Cup A.',
    'wrong_sand': 'That is not Cup B! Pour the sand into Cup B.',
    'wrong_pebbles': 'That is not Cup C! Pour the pebbles into Cup C.',
    'wrong_small':
        'That is not Tumbler 1! Pour the small bottle into Tumbler 1.',
    'wrong_large':
        'That is not Tumbler 2! Pour the large bottle into Tumbler 2.',
    'miss_pitcher': 'Let go of the Water Pitcher right over Cup A.',
    'miss_sand': 'Let go of the Sand Scoop right over Cup B.',
    'miss_pebbles': 'Let go of the Pebble Scoop right over Cup C.',
    'miss_small': 'Let go of the small bottle right over Tumbler 1.',
    'miss_large': 'Let go of the large bottle right over Tumbler 2.',
    'miss_scale': 'Put {cup} on the pan of the Digital Balance.',
    'scene_s1':
        'Table with three empty cups (A, B and C), a water pitcher, a sand scoop and a pebble scoop; a digital balance appears for weighing.',
    'scene_s2':
        'Table with two identical empty tumblers and two water bottles, 200 mL and 500 mL.',
  },
  'hi': {
    'app_title': 'सामग्री के गुणों की खोज: द्रव्यमान और आयतन',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर की सामग्री',
    'scen_1_opt': 'परिदृश्य 1: कितना भारी या हल्का? द्रव्यमान की तुलना',
    'scen_2_opt': 'परिदृश्य 2: कितना स्थान? आयतन की खोज',
    's1_desc':
        'यह देखना कि विभिन्न सामग्रियों का द्रव्यमान अलग-अलग हो सकता है, भले ही वे समान स्थान (आयतन) घेरती हों।',
    's2_desc': 'यह समझना कि आयतन वह स्थान है जो कोई पदार्थ घेरता है।',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'समान आयतन विभिन्न सामग्रियों से भरा जा सकता है।',
    'step_1_1_a':
        'कप A में पानी भरें: पानी के घड़े को कप A के ऊपर खींचकर छोड़ें।',
    'step_1_1_o': 'कप A आधा पानी से भर गया है।',
    'step_1_2_c': 'समान आयतन विभिन्न सामग्रियों से भरा जा सकता है।',
    'step_1_2_a':
        'कप B में रेत भरें: रेत के स्कूप को कप B के ऊपर खींचकर छोड़ें।',
    'step_1_2_o': 'कप B आधा रेत से भर गया है।',
    'step_1_3_c': 'समान आयतन विभिन्न सामग्रियों से भरा जा सकता है।',
    'step_1_3_a':
        'कप C में कंकड़ भरें: कंकड़ के स्कूप को कप C के ऊपर खींचकर छोड़ें।',
    'step_1_3_o': 'कप C आधा कंकड़ से भर गया है।',
    'step_1_4_c':
        "द्रव्यमान किसी वस्तु में पदार्थ की मात्रा है, यानी उसका 'भारीपन'।",
    'step_1_4_a':
        'कप A (पानी) को तौलें: कप A को खींचकर डिजिटल तराजू के पलड़े पर रखें।',
    'step_1_4_o': 'तराजू का पाठ्यांक 100 g है।',
    'step_1_5_c': 'विभिन्न सामग्रियों का द्रव्यमान अलग-अलग होता है।',
    'step_1_5_a':
        'कप B (रेत) को तौलें: कप B को खींचकर डिजिटल तराजू के पलड़े पर रखें।',
    'step_1_5_o': 'तराजू का पाठ्यांक 160 g है।',
    'step_1_6_c':
        'सघन सामग्रियाँ समान स्थान में अधिक द्रव्यमान समेटे रहती हैं।',
    'step_1_6_a':
        'कप C (कंकड़) को तौलें: कप C को खींचकर डिजिटल तराजू के पलड़े पर रखें।',
    'step_1_6_o': 'तराजू का पाठ्यांक 210 g है।',
    'step_1_7_c': 'समान आयतन के द्रव्यमान की तुलना करें।',
    'step_1_7_a': "सभी कपों की तुलना करें: 'परिणामों की तुलना करें' बटन दबाएँ।",
    'step_1_7_o': 'कंकड़ का द्रव्यमान सबसे अधिक है, पानी का सबसे कम।',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'कंटेनर तरल रख सकते हैं।',
    'step_2_1_a':
        'सेटअप देखें: दो एक जैसे खाली गिलास, एक छोटी (200 mL) और एक बड़ी (500 mL) पानी की बोतल।',
    'step_2_1_o': 'समान गिलास, अलग-अलग बोतलें।',
    'step_2_2_c': 'थोड़ी मात्रा में तरल कम आयतन घेरता है।',
    'step_2_2_a':
        'छोटी बोतल का पानी गिलास 1 में डालें: छोटी पानी की बोतल (200 mL) को गिलास 1 के ऊपर खींचकर छोड़ें।',
    'step_2_2_o': 'पानी का स्तर कम है।',
    'step_2_3_c': 'बड़ी मात्रा में तरल अधिक आयतन घेरता है।',
    'step_2_3_a':
        'बड़ी बोतल का पानी गिलास 2 में डालें: बड़ी पानी की बोतल (500 mL) को गिलास 2 के ऊपर खींचकर छोड़ें।',
    'step_2_3_o': 'पानी का स्तर ऊँचा है।',
    'step_2_4_c': 'आयतन पदार्थ द्वारा घेरा गया स्थान है।',
    'step_2_4_a': "गिलासों की तुलना करें: 'परिणामों की तुलना करें' बटन दबाएँ।",
    'step_2_4_o': 'अधिक तरल अधिक स्थान लेता है।',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1': 'चरण 1: पानी के घड़े को कप A के ऊपर खींचकर छोड़ें।',
    's1_hud_2': 'चरण 2: रेत के स्कूप को कप B के ऊपर खींचकर छोड़ें।',
    's1_hud_3': 'चरण 3: कंकड़ के स्कूप को कप C के ऊपर खींचकर छोड़ें।',
    's1_hud_4': 'चरण 4: कप A (पानी) को डिजिटल तराजू पर खींचें।',
    's1_hud_5': 'चरण 5: कप A की जगह कप B (रेत) को डिजिटल तराजू पर खींचें।',
    's1_hud_6': 'चरण 6: कप B की जगह कप C (कंकड़) को डिजिटल तराजू पर खींचें।',
    's1_hud_7': "चरण 7: 'परिणामों की तुलना करें' बटन दबाएँ।",
    's1_hud_8': 'अन्वेषण पूर्ण! बहुत बढ़िया।',
    's2_hud_1': 'चरण 1: खाली गिलासों और पानी की बोतलों को देखें।',
    's2_hud_2':
        'चरण 2: छोटी पानी की बोतल (200 mL) को गिलास 1 के ऊपर खींचकर छोड़ें।',
    's2_hud_3':
        'चरण 3: बड़ी पानी की बोतल (500 mL) को गिलास 2 के ऊपर खींचकर छोड़ें।',
    's2_hud_4': "चरण 4: 'परिणामों की तुलना करें' बटन दबाएँ।",
    's2_hud_5': 'अन्वेषण पूर्ण! बहुत बढ़िया।',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण चरण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'obs_pending': 'यह चरण पूरा करें, फिर देखें कि क्या होता है।',
    // ------------------------------------------------- compare / summary
    'btn_compare': 'परिणामों की तुलना करें',
    'compare_s1':
        "भले ही तीनों कप समान स्तर (समान आयतन) तक भरे गए थे, उनका 'भारीपन' (द्रव्यमान) अलग-अलग है। कंकड़ का द्रव्यमान सबसे अधिक है, और पानी का सबसे कम।",
    'compare_s2':
        'बड़ी बोतल के पानी ने गिलास में अधिक जगह ले ली। इसका अर्थ है कि इसका आयतन बड़ा है।',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_summary':
        "भले ही तीनों कप समान स्तर (समान आयतन) तक भरे गए थे, उनका 'भारीपन' (द्रव्यमान) अलग-अलग है। कंकड़ का द्रव्यमान सबसे अधिक है, और पानी का सबसे कम।",
    's2_summary':
        'बड़ी बोतल के पानी ने गिलास में अधिक जगह ले ली। इसका अर्थ है कि इसका आयतन बड़ा है।',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने द्रव्यमान और आयतन के बीच अंतर किया! समान आकार (आयतन) की वस्तुओं का द्रव्यमान पूरी तरह से अलग हो सकता है।',
    // ------------------------------------------------------ scene labels
    'lbl_cupA': 'कप A (पानी)',
    'lbl_cupB': 'कप B (रेत)',
    'lbl_cupC': 'कप C (कंकड़)',
    'lbl_pitcher': 'पानी का घड़ा',
    'lbl_sand': 'रेत का स्कूप',
    'lbl_pebbles': 'कंकड़ का स्कूप',
    'lbl_scale': 'डिजिटल तराजू',
    'lbl_tumbler1': 'गिलास 1',
    'lbl_tumbler2': 'गिलास 2',
    'lbl_bot_small': 'छोटी बोतल (200 mL)',
    'lbl_bot_large': 'बड़ी बोतल (500 mL)',
    // SI symbols, as in the NCERT Hindi textbooks.
    'unit_g': 'g',
    'unit_ml': 'mL',
    // ------------------------------------------------------------- toasts
    'cup_a': 'कप A',
    'cup_b': 'कप B',
    'cup_c': 'कप C',
    'first_1_1': 'पहले कप A में पानी भरें।',
    'first_1_2': 'पहले कप B में रेत भरें।',
    'first_1_3': 'पहले कप C में कंकड़ भरें।',
    'first_1_4': 'पहले कप A को तौलें।',
    'first_1_5': 'पहले कप B को तौलें।',
    'first_1_6': 'पहले कप C को तौलें।',
    'first_1_7': "'परिणामों की तुलना करें' बटन दबाएँ।",
    'first_2_2': 'पहले छोटी बोतल का पानी गिलास 1 में डालें।',
    'wrong_pitcher': 'यह कप A नहीं है! पानी कप A में डालें।',
    'wrong_sand': 'यह कप B नहीं है! रेत कप B में डालें।',
    'wrong_pebbles': 'यह कप C नहीं है! कंकड़ कप C में डालें।',
    'wrong_small': 'यह गिलास 1 नहीं है! छोटी बोतल का पानी गिलास 1 में डालें।',
    'wrong_large': 'यह गिलास 2 नहीं है! बड़ी बोतल का पानी गिलास 2 में डालें।',
    'miss_pitcher': 'पानी के घड़े को ठीक कप A के ऊपर छोड़ें।',
    'miss_sand': 'रेत के स्कूप को ठीक कप B के ऊपर छोड़ें।',
    'miss_pebbles': 'कंकड़ के स्कूप को ठीक कप C के ऊपर छोड़ें।',
    'miss_small': 'छोटी बोतल को ठीक गिलास 1 के ऊपर छोड़ें।',
    'miss_large': 'बड़ी बोतल को ठीक गिलास 2 के ऊपर छोड़ें।',
    'miss_scale': '{cup} को डिजिटल तराजू के पलड़े पर रखें।',
    'scene_s1':
        'तीन खाली कप (A, B और C), पानी का घड़ा, रेत का स्कूप और कंकड़ का स्कूप वाली मेज; तौलने के लिए डिजिटल तराजू आता है।',
    'scene_s2':
        'दो एक जैसे खाली गिलास और पानी की दो बोतलों (200 mL और 500 mL) वाली मेज।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [7, 4];

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

/// HTML `camera.position.set(0, 10, 28)` and `controls.target.set(0, 2, 0)`
/// (`resetCamera()`), the same in both scenarios.
const _V _eye = _V(0, 10, 28);
const _V _lookAt = _V(0, 2, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.8)` and `DirectionalLight(
/// 0xfff8e7, 1.2)` at (10, 30, 20). Three.js r128 adds them linearly and
/// clips at white, which washes every lit face out; both are scaled by
/// [_lightScale].
const double _lightScale = 0.6;
const double _ambient = 0.8 * _lightScale;
const double _diffuse = 1.2 * _lightScale;

/// (10, 30, 20) normalised, and the key light's warm tint (0xfff8e7).
const _V _light = _V(0.2673, 0.8018, 0.5345);
const double _lightG = 0xF8 / 0xFF;
const double _lightB = 0xE7 / 0xFF;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking objects up (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's sprite text stays readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

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
/// scale): the canvas Compare button sits below it.
const double _toastBand = 52;

// ------------------------------------------------------------ animations

/// `checkDrop`: hover snap above the target (and the way back after a
/// miss), 400 ms Quadratic.Out.
const double _snapSeconds = 0.4;

/// The container hovers this far above its target (`targetPos.y + 5`).
const double _hoverLift = 5;

/// `triggerPourAnimation`: tip to -π / 2.5 in 500 ms; the target fills for
/// 1000 ms after a 200 ms delay; then the container turns upright (400 ms)
/// and goes home (600 ms) before it is hidden.
const double _tiltAngle = math.pi / 2.5;
const double _tiltSeconds = 0.5;
const double _fillDelay = 0.2;
const double _fillSeconds = 1.0;
const double _untiltSeconds = 0.4;
const double _putAwaySeconds = 0.6;

/// `checkDrop` + `weighCup`: the cup slides onto the pan (400 ms), the pan
/// dips 0.2 and comes back (300 ms each way), the readout climbs for
/// 1000 ms (Quadratic.Out) and is held for 1.5 s; then the cup goes home
/// (500 ms).
const double _toPanSeconds = 0.4;
const double _dipSeconds = 0.3;
const double _dip = 0.2;
const double _climbSeconds = 1.0;
const double _holdSeconds = 1.5;
const double _cupHomeSeconds = 0.5;

/// `triggerCompare`: everything moves into line in 1000 ms; then the
/// heaviest cup / fullest tumbler bounces (500 ms up, 500 ms down).
const double _compareSeconds = 1.0;
const double _bounceSeconds = 0.5;

/// `setHighlightGlow`: emissive 0 … 0.5 and back, 500 ms each way.
const double _glowHalfPeriod = 0.5;
const double _glowMax = 0.5;

/// Scenario 2 step 1 ("Observe the setup") lasts this long, or until the
/// small bottle is picked up (the HTML skipped the step at once).
const double _lookSeconds = 3;

/// Popup after Compare Outcomes (`setTimeout(showObservationPopup, 3000)`).
const Duration _summaryDelay = Duration(milliseconds: 3000);

// -------------------------------------------------------------- geometry

/// Scenario 1 step at which the first cup is weighed (`State.step === 4`).
const int _weighFirstStep = 4;

/// The cups are see-through in the port (the HTML cups are opaque white,
/// which hid the fill level the observations talk about).
const double _cupOpacity = 0.32;

/// `s1Scale.position.set(-13, 0, 4)`; `triggerCompare` moves it to z = -10.
const _V _scaleHome = _V(-13, 0, 4);
const _V _scaleAway = _V(-13, 0, -10);

/// Balance parts relative to the scale group: base `BoxGeometry(6, 1, 6)`
/// at y 0.5, pan `CylinderGeometry(2.5, 2.5, 0.2)` from y 1.0 to 1.2,
/// display `BoxGeometry(4, 0.8, 1)` at (0, 1, 3).
const _V _baseSize = _V(6, 1, 6);
const double _panRadius = 2.5;
const double _panBottom = 1.0;
const double _panHeight = 0.2;
const _V _displayAt = _V(0, 1, 3);
const _V _displaySize = _V(4, 0.8, 1);

/// Objects slide on the table-parallel plane at their own height, kept on
/// the visible part of the table.
const double _dragHalfX = 14;
const double _dragMinZ = -8;
const double _dragMaxZ = 8;

/// A container counts as "over" a vessel (or a cup as "on" the pan) when
/// its centre is this many design px from the vessel's column (x the
/// framing scale), past the vessel's rim.
const double _catchPad = 20;

/// Free spots on the table (nothing there): used by the flows for a drop
/// that misses.
const _V _openMass = _V(-8, 1.75, 7.5);
const _V _openVolume = _V(0, 2, 7);

/// Heights of the comparison bounce: cup C 1.75 -> 2.2, Tumbler 2 3 -> 3.5.
const double _cupBounce = 0.45;
const double _tumblerBounce = 0.5;

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

  /// Where the ray through [s] meets the horizontal plane at height [y].
  _V? onPlaneY(Offset s, double y) {
    final dir = ray(s);
    if (dir.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (p(c + _V(0, 0, radius)).dy - p(c - _V(0, 0, radius)).dy).abs() / 2;
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

/// The vessels: cups A, B, C (`createLabeledCup`) and the two tumblers.
enum _Vessel {
  /// `createLabeledCup(-5, 'A', 0x3b82f6, "100 g")`: open
  /// `CylinderGeometry(1.6, 1.2, 3.5)` at (x, 1.75, 5), fill
  /// `CylinderGeometry(1.5, 1.15, 3.4)`.
  cupA(
    scenario: 0,
    home: _V(-5, 1.75, 5),
    rTop: 1.6,
    rBottom: 1.2,
    height: 3.5,
    fillRTop: 1.5,
    fillRBottom: 1.15,
    fillHeight: 3.4,
    color: _Colors.cup,
    opacity: _cupOpacity,
    fillColor: _Colors.water,
    fillOpacity: 1,
    mass: 100,
    labelKey: 'lbl_cupA',
    nameKey: 'cup_a',
    mark: 'A',
    comparePos: _V(-5, 1.75, 0),
    bounce: 0,
  ),
  cupB(
    scenario: 0,
    home: _V(0, 1.75, 5),
    rTop: 1.6,
    rBottom: 1.2,
    height: 3.5,
    fillRTop: 1.5,
    fillRBottom: 1.15,
    fillHeight: 3.4,
    color: _Colors.cup,
    opacity: _cupOpacity,
    fillColor: _Colors.sand,
    fillOpacity: 1,
    mass: 160,
    labelKey: 'lbl_cupB',
    nameKey: 'cup_b',
    mark: 'B',
    comparePos: _V(0, 1.75, 0),
    bounce: 0,
  ),
  cupC(
    scenario: 0,
    home: _V(5, 1.75, 5),
    rTop: 1.6,
    rBottom: 1.2,
    height: 3.5,
    fillRTop: 1.5,
    fillRBottom: 1.15,
    fillHeight: 3.4,
    color: _Colors.cup,
    opacity: _cupOpacity,
    fillColor: _Colors.pebbles,
    fillOpacity: 1,
    mass: 210,
    labelKey: 'lbl_cupC',
    nameKey: 'cup_c',
    mark: 'C',
    comparePos: _V(5, 1.75, 0),
    bounce: _cupBounce,
  ),

  /// Glass `CylinderGeometry(2, 1.8, 6)` (0xe2e8f0, opacity 0.35) at
  /// (∓4, 3, 4), water `CylinderGeometry(1.9, 1.7, 5.8)` (0x38bdf8, 0.7).
  tumbler1(
    scenario: 1,
    home: _V(-4, 3, 4),
    rTop: 2,
    rBottom: 1.8,
    height: 6,
    fillRTop: 1.9,
    fillRBottom: 1.7,
    fillHeight: 5.8,
    color: _Colors.glass,
    opacity: 0.35,
    fillColor: _Colors.bottle,
    fillOpacity: 0.7,
    mass: 0,
    labelKey: 'lbl_tumbler1',
    nameKey: 'lbl_tumbler1',
    mark: '1',
    comparePos: _V(-3, 3, 0),
    bounce: 0,
  ),
  tumbler2(
    scenario: 1,
    home: _V(4, 3, 4),
    rTop: 2,
    rBottom: 1.8,
    height: 6,
    fillRTop: 1.9,
    fillRBottom: 1.7,
    fillHeight: 5.8,
    color: _Colors.glass,
    opacity: 0.35,
    fillColor: _Colors.bottle,
    fillOpacity: 0.7,
    mass: 0,
    labelKey: 'lbl_tumbler2',
    nameKey: 'lbl_tumbler2',
    mark: '2',
    comparePos: _V(3, 3, 0),
    bounce: _tumblerBounce,
  );

  const _Vessel({
    required this.scenario,
    required this.home,
    required this.rTop,
    required this.rBottom,
    required this.height,
    required this.fillRTop,
    required this.fillRBottom,
    required this.fillHeight,
    required this.color,
    required this.opacity,
    required this.fillColor,
    required this.fillOpacity,
    required this.mass,
    required this.labelKey,
    required this.nameKey,
    required this.mark,
    required this.comparePos,
    required this.bounce,
  });

  final int scenario;
  final _V home;
  final double rTop;
  final double rBottom;
  final double height;
  final double fillRTop;
  final double fillRBottom;
  final double fillHeight;
  final Color color;
  final double opacity;
  final Color fillColor;
  final double fillOpacity;

  /// HTML `targetMass` (g); 0 for the tumblers.
  final int mass;
  final String labelKey;

  /// Short name in messages ("Cup A").
  final String nameKey;

  /// The big letter / number on its front.
  final String mark;

  /// Where `triggerCompare` moves it, and how high it then bounces.
  final _V comparePos;
  final double bounce;

  bool get isCup => scenario == 0;
  _V get half => _V(rTop, height / 2, rTop);
}

/// The containers poured into a vessel (HTML `pitcher`, `sandScoop`,
/// `pebbleScoop`, `bottleSmall`, `bottleLarge`).
enum _Pour {
  /// `CylinderGeometry(1.5, 1.5, 4)`, 0x38bdf8, opacity 0.8, at (-10, 2,
  /// -2); fills Cup A halfway (`finalYScale = 0.5`).
  pitcher(
    scenario: 0,
    step: 1,
    home: _V(-10, 2, -2),
    isBox: false,
    width: 1.5,
    height: 4,
    color: _Colors.pitcher,
    opacity: 0.8,
    target: _Vessel.cupA,
    fill: 0.5,
    labelKey: 'lbl_pitcher',
  ),

  /// `BoxGeometry(2.5, 3, 2.5)`, 0xf59e0b, at (0, 1.5, -2); Cup B.
  sand(
    scenario: 0,
    step: 2,
    home: _V(0, 1.5, -2),
    isBox: true,
    width: 2.5,
    height: 3,
    color: _Colors.sandScoop,
    opacity: 1,
    target: _Vessel.cupB,
    fill: 0.5,
    labelKey: 'lbl_sand',
  ),

  /// `BoxGeometry(2.5, 3, 2.5)`, 0x64748b, at (10, 1.5, -2); Cup C.
  pebbles(
    scenario: 0,
    step: 3,
    home: _V(10, 1.5, -2),
    isBox: true,
    width: 2.5,
    height: 3,
    color: _Colors.pebbleScoop,
    opacity: 1,
    target: _Vessel.cupC,
    fill: 0.5,
    labelKey: 'lbl_pebbles',
  ),

  /// `CylinderGeometry(1.2, 1.2, 4)`, 0x38bdf8, opacity 0.85, at (-10, 2,
  /// -2); fills Tumbler 1 to 0.4 of its height.
  small(
    scenario: 1,
    step: 2,
    home: _V(-10, 2, -2),
    isBox: false,
    width: 1.2,
    height: 4,
    color: _Colors.bottle,
    opacity: 0.85,
    target: _Vessel.tumbler1,
    fill: 0.4,
    labelKey: 'lbl_bot_small',
  ),

  /// `CylinderGeometry(1.6, 1.6, 6)` at (10, 3, -2); Tumbler 2 to 0.9.
  large(
    scenario: 1,
    step: 3,
    home: _V(10, 3, -2),
    isBox: false,
    width: 1.6,
    height: 6,
    color: _Colors.bottle,
    opacity: 0.85,
    target: _Vessel.tumbler2,
    fill: 0.9,
    labelKey: 'lbl_bot_large',
  );

  const _Pour({
    required this.scenario,
    required this.step,
    required this.home,
    required this.isBox,
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
    required this.target,
    required this.fill,
    required this.labelKey,
  });

  final int scenario;

  /// The step that pours it.
  final int step;
  final _V home;
  final bool isBox;

  /// Cylinder radius or box edge.
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final _Vessel target;

  /// Share of the target's fill height it pours (`finalYScale`).
  final double fill;
  final String labelKey;

  _V get half => isBox
      ? _V(width / 2, height / 2, width / 2)
      : _V(width, height / 2, width);

  /// Volume printed on a bottle (mL), 0 for the others.
  int get millilitres => switch (this) {
    _Pour.small => 200,
    _Pour.large => 500,
    _ => 0,
  };
}

/// What a container is doing.
enum _PourPhase { idle, held, returning, snapping, pouring, putAway }

/// What a cup is doing.
enum _CupPhase { idle, held, returning, toPan, weighing, homing }

class _PourerState {
  _PourerState(this.kind) : pos = kind.home;

  final _Pour kind;
  _V pos;

  /// Share of the tip angle (0 upright … 1 at -π / 2.5).
  double tilt = 0;

  /// HTML `userData.used`: poured, put away and hidden.
  bool used = false;
  _PourPhase phase = _PourPhase.idle;
  double phaseStart = 0;

  /// Start of the current move.
  _V from = _V.zero;
}

class _VesselState {
  _VesselState(this.kind) : pos = kind.home;

  final _Vessel kind;
  _V pos;

  /// Share of the fill height (HTML `fill.scale.y`).
  double fill = 0;

  /// Weighed on the balance (cups).
  bool weighed = false;
  _CupPhase phase = _CupPhase.idle;
  double phaseStart = 0;
  _V from = _V.zero;

  /// Where it was when Compare Outcomes was tapped.
  _V compareFrom = _V.zero;

  _V get bottom => pos - _V(0, kind.height / 2, 0);
  _V get top => pos + _V(0, kind.height / 2, 0);
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; steps + 1 once compared).
  int step = 1;

  /// Scene time when the scenario was loaded.
  double startTime = 0;

  /// Bumped on every load, so a gesture from before cannot touch the new
  /// scene.
  int generation = 0;

  final List<_PourerState> pourers = [];
  final List<_VesselState> vessels = [];

  /// The digital balance (HTML `s1Scale.visible`, from step 4).
  bool scaleShown = false;
  _V scalePos = _scaleHome;
  double panDip = 0;

  /// Grams on the readout.
  int readout = 0;

  bool compared = false;
  double compareStart = 0;

  final _Camera cam = _Camera(_eye, _lookAt);
  _View view = _View.identity;
  _View viewTarget = _View.identity;

  /// The next framing jumps to its target instead of sliding.
  bool snapView = true;

  _VesselState vesselOf(_Vessel kind) =>
      vessels.firstWhere((v) => v.kind == kind);

  /// Centre of a cup standing on the pan.
  _V get panSeat => _V(
    scalePos.x,
    _panBottom + _panHeight + panDip + _Vessel.cupA.height / 2,
    scalePos.z,
  );
  _V get panCenter => scalePos + _V(0, _panBottom + _panHeight / 2 + panDip, 0);

  /// A pour or a weighing is running: nothing else can be picked up.
  bool get busy =>
      pourers.any(
        (p) =>
            p.phase == _PourPhase.snapping ||
            p.phase == _PourPhase.pouring ||
            p.phase == _PourPhase.putAway,
      ) ||
      vessels.any(
        (v) => v.phase == _CupPhase.toPan || v.phase == _CupPhase.weighing,
      );

  /// The object the current step asks for (HTML `updateHighlights`).
  Object? get active {
    if (compared) return null;
    for (final p in pourers) {
      if (!p.used && p.kind.step == step) return p;
    }
    if (scenario == 0 &&
        step >= _weighFirstStep &&
        step < _weighFirstStep + 3) {
      return vessels[step - _weighFirstStep];
    }
    return null;
  }

  /// The container pouring into [v] right now, if any.
  _PourerState? pouringInto(_VesselState v) {
    for (final p in pourers) {
      if (p.phase == _PourPhase.pouring && p.kind.target == v.kind) return p;
    }
    return null;
  }

  /// Design-space position of a named scene point (used by the flows):
  /// containers, vessels, `pan` (where a cup's centre goes on the pan) and
  /// `open` (a free spot on the table).
  Offset anchor(String id) {
    for (final p in pourers) {
      if (p.kind.name == id) {
        // The scoops are partly behind their cups: their upper part.
        return cam.p(p.kind.isBox ? p.pos + const _V(0, 1, 0) : p.pos);
      }
    }
    for (final v in vessels) {
      if (v.kind.name == id) return cam.p(v.pos);
    }
    return switch (id) {
      'pan' => cam.p(panSeat),
      'open' => cam.p(scenario == 0 ? _openMass : _openVolume),
      _ => cam.p(_lookAt),
    };
  }

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    generation++;
    scenario = index;
    step = 1;
    startTime = time;
    pourers
      ..clear()
      ..addAll([
        for (final k in _Pour.values)
          if (k.scenario == index) _PourerState(k),
      ]);
    vessels
      ..clear()
      ..addAll([
        for (final k in _Vessel.values)
          if (k.scenario == index) _VesselState(k),
      ]);
    scaleShown = false;
    scalePos = _scaleHome;
    panDip = 0;
    readout = 0;
    compared = false;
    compareStart = 0;
    snapView = true;
  }
}

/// World anchor of a container's name label: above it (HTML `+3`); the
/// small bottle's sits on its left (the chip's right edge), clear of
/// Tumbler 1.
_V _pourLabelAt(_Pour k, _V pos) => switch (k) {
  _Pour.small => pos + _V(-k.width - 0.4, 0, 0),
  _Pour.large => pos + _V(0, k.height / 2 + 1.3, 0),
  _ => pos + const _V(0, 3, 0),
};

/// Name label under a vessel (the HTML put it under the table top, where
/// it could not be seen).
_V _vesselLabelAt(_Vessel k, _V pos) =>
    pos - _V(0, k.height / 2 + (k.isCup ? 0.9 : 0.8), 0);

/// Printed text fills at most this share of a bottle's width.
const double _printFit = 0.8;

/// "Digital Balance" under the balance's front and the readout on its
/// display.
_V _scaleLabelAt(_V scale) => scale + const _V(0, -0.6, 3.6);
_V _readoutAt(_V scale) => scale + const _V(0, 1, 3.5);

/// Wraps label lines at this many label sizes.
const double _chipWrap = 11;
const double _bottleWrap = 7;

/// Design px kept between neighbouring vessel labels.
const double _labelGap = 6;

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
  _Grab(this.item, this.offset, this.planeY, this.generation);

  /// A [_PourerState] or a [_VesselState].
  final Object item;

  /// Drag-plane hit minus the object's position at pointer-down.
  final _V offset;
  final double planeY;
  final int generation;
}

class _MassVolumeLabState
    extends State<Ch6A5ExploringMaterialPropertiesMassAndVolumePage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  _Grab? _grab;

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
    final before = s.step;
    _advancePourers();
    _advanceVessels();
    // Scenario 2 step 1 is a look at the setup.
    if (s.scenario == 1 && s.step == 1 && now - s.startTime >= _lookSeconds) {
      s.step = 2;
    }
    if (s.step != before) _refresh();
    _frame.value = now;
  }

  /// `checkDrop` / `triggerPourAnimation` tweens of the containers.
  void _advancePourers() {
    final s = _scene;
    for (final p in s.pourers) {
      final t = s.time - p.phaseStart;
      switch (p.phase) {
        case _PourPhase.idle:
        case _PourPhase.held:
          break;
        case _PourPhase.returning:
          final k = (t / _snapSeconds).clamp(0.0, 1.0);
          p.pos = _V.lerp(p.from, p.kind.home, Curves.easeOutQuad.transform(k));
          if (k >= 1) p.phase = _PourPhase.idle;
        case _PourPhase.snapping:
          final k = (t / _snapSeconds).clamp(0.0, 1.0);
          final hover =
              s.vesselOf(p.kind.target).pos + const _V(0, _hoverLift, 0);
          p.pos = _V.lerp(p.from, hover, Curves.easeOutQuad.transform(k));
          if (k >= 1) {
            p
              ..phase = _PourPhase.pouring
              ..phaseStart = s.time;
            _Sound.drop.play();
          }
        case _PourPhase.pouring:
          final v = s.vesselOf(p.kind.target);
          p.tilt = (t / _tiltSeconds).clamp(0.0, 1.0);
          v.fill =
              p.kind.fill * ((t - _fillDelay) / _fillSeconds).clamp(0.0, 1.0);
          if (t >= _fillDelay + _fillSeconds) {
            p
              ..phase = _PourPhase.putAway
              ..phaseStart = s.time
              ..from = p.pos;
          }
        case _PourPhase.putAway:
          p.tilt = 1 - (t / _untiltSeconds).clamp(0.0, 1.0);
          final k = (t / _putAwaySeconds).clamp(0.0, 1.0);
          p.pos = _V.lerp(p.from, p.kind.home, k);
          if (k >= 1) {
            // HTML: hidden after use, then `progressStep()`.
            p
              ..used = true
              ..phase = _PourPhase.idle
              ..tilt = 0;
            s.step++;
            if (s.scenario == 0 && s.step == _weighFirstStep) {
              s.scaleShown = true;
            }
          }
      }
    }
  }

  /// Cup moves, the weighing (`weighCup`) and the comparison line-up.
  void _advanceVessels() {
    final s = _scene;
    if (s.compared) {
      final tc = s.time - s.compareStart;
      final k = (tc / _compareSeconds).clamp(0.0, 1.0);
      for (final v in s.vessels) {
        var pos = _V.lerp(v.compareFrom, v.kind.comparePos, k);
        if (v.kind.bounce > 0 && tc > _compareSeconds) {
          final phase = ((tc - _compareSeconds) / _bounceSeconds) % 2;
          pos = pos + _V(0, v.kind.bounce * (phase < 1 ? phase : 2 - phase), 0);
        }
        v.pos = pos;
      }
      if (s.scenario == 0) s.scalePos = _V.lerp(_scaleHome, _scaleAway, k);
      return;
    }
    for (final v in s.vessels) {
      final t = s.time - v.phaseStart;
      switch (v.phase) {
        case _CupPhase.idle:
        case _CupPhase.held:
          break;
        case _CupPhase.returning:
          final k = (t / _snapSeconds).clamp(0.0, 1.0);
          v.pos = _V.lerp(v.from, v.kind.home, Curves.easeOutQuad.transform(k));
          if (k >= 1) v.phase = _CupPhase.idle;
        case _CupPhase.toPan:
          final k = (t / _toPanSeconds).clamp(0.0, 1.0);
          v.pos = _V.lerp(v.from, s.panSeat, k);
          if (k >= 1) {
            v
              ..phase = _CupPhase.weighing
              ..phaseStart = s.time;
            s.readout = 0;
            _Sound.click.play();
          }
        case _CupPhase.weighing:
          // The pan (and the cup on it) dips 0.2 and comes back.
          s.panDip = t < _dipSeconds
              ? -_dip * t / _dipSeconds
              : (t < 2 * _dipSeconds ? -_dip * (2 - t / _dipSeconds) : 0);
          v.pos = s.panSeat;
          final climb = Curves.easeOutQuad.transform(
            (t / _climbSeconds).clamp(0.0, 1.0),
          );
          s.readout = (v.kind.mass * climb).round();
          if (t >= _climbSeconds + _holdSeconds) {
            // `progressStep()`: the cup goes home, the readout back to 0.
            v
              ..weighed = true
              ..phase = _CupPhase.homing
              ..phaseStart = s.time
              ..from = v.pos;
            s
              ..readout = 0
              ..panDip = 0
              ..step += 1;
          }
        case _CupPhase.homing:
          final k = (t / _cupHomeSeconds).clamp(0.0, 1.0);
          v.pos = _V.lerp(v.from, v.kind.home, k);
          if (k >= 1) v.phase = _CupPhase.idle;
      }
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `triggerCompare()`: everything moves into line, the result text
  /// appears and the summary follows 3 s later.
  void _compare() {
    final s = _scene;
    final n = _stepCounts[s.scenario];
    if (s.compared || s.step != n || s.busy) return;
    _Sound.pop.play();
    setState(() {
      s
        ..compared = true
        ..compareStart = s.time
        ..step = n + 1;
      for (final v in s.vessels) {
        v
          ..compareFrom = v.pos
          ..phase = _CupPhase.idle;
      }
    });
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: _summaryDelay,
      // HTML: S1 "Scenario 1 Complete!" with its summary; S2 the trophy
      // popup "Mastery Achieved!" (its own summary was never shown).
      heading: () =>
          sc == 0 ? labFormat(_t('sc_complete'), {'n': 1}) : _t('all_complete'),
      body: () => sc == 0
          ? _t('s1_summary')
          : '${_t('s2_summary')}\n\n${_t('all_complete_desc')}',
    );
  }

  // -------------------------------------------------------------- gestures

  bool _unlocked(Object o) {
    final s = _scene;
    if (s.compared) return false;
    return switch (o) {
      _PourerState p =>
        s.step == p.kind.step || (p.kind == _Pour.small && s.step == 1),
      _VesselState v =>
        v.kind.isCup && !v.weighed && s.step == _weighFirstStep + v.kind.index,
      _ => false,
    };
  }

  /// The scene object under [at] (design px): the one the step asks for
  /// first, otherwise the nearest.
  Object? _hitTest(Offset at) {
    final s = _scene;
    if (s.compared) return null;
    Object? best;
    var bestScore = double.infinity;
    void consider(Object o, Rect bounds, _V centre) {
      final box = Rect.fromCenter(
        center: bounds.center,
        width: math.max(bounds.width, 2 * _touch),
        height: math.max(bounds.height, 2 * _touch),
      );
      if (!box.contains(at)) return;
      final score = (_unlocked(o) ? 0 : 1000) + s.cam.depth(centre);
      if (score < bestScore) {
        best = o;
        bestScore = score;
      }
    }

    for (final p in s.pourers) {
      if (p.used || p.phase != _PourPhase.idle) continue;
      consider(p, _boxBounds(s.cam, p.pos, p.kind.half), p.pos);
    }
    for (final v in s.vessels) {
      // The tumblers are never moved (HTML interactables: the bottles).
      if (!v.kind.isCup || v.phase != _CupPhase.idle) continue;
      consider(v, _boxBounds(s.cam, v.pos, v.kind.half), v.pos);
    }
    return best;
  }

  /// HTML `pointerdown` raycast against the interactables.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null || _scene.busy) return false;
    return _hitTest(event.localPosition) != null;
  }

  /// What the current step asks for, for an object touched too early.
  String _notYetKey() {
    final s = _scene;
    return s.scenario == 0
        ? 'first_1_${s.step.clamp(1, _stepCounts[0])}'
        : 'first_2_2';
  }

  /// HTML `pointerdown` on a draggable object: drag plane and offset.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final hit = _hitTest(d.localPosition);
    if (hit == null) return;
    if (!_unlocked(hit)) {
      _lab.showToast(_t(_notYetKey()), isError: true);
      return;
    }
    final _V pos;
    switch (hit) {
      case _PourerState p:
        p.phase = _PourPhase.held;
        pos = p.pos;
      case _VesselState v:
        v.phase = _CupPhase.held;
        pos = v.pos;
      default:
        return;
    }
    final at = s.cam.onPlaneY(d.localPosition, pos.y);
    _grab = _Grab(
      hit,
      at == null ? _V.zero : _V(at.x - pos.x, 0, at.z - pos.z),
      pos.y,
      s.generation,
    );
    _Sound.pickup.play();
  }

  void _onDragStart(DragStartDetails _) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    // Picking up the small bottle ends the look at the setup.
    if (s.scenario == 1 && s.step == 1) {
      s.step = 2;
      _refresh();
    }
  }

  /// HTML `pointermove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    final hit = s.cam.onPlaneY(d.localPosition, g.planeY);
    if (hit == null) return;
    final pos = _V(
      (hit.x - g.offset.x).clamp(-_dragHalfX, _dragHalfX),
      g.planeY,
      (hit.z - g.offset.z).clamp(_dragMinZ, _dragMaxZ),
    );
    switch (g.item) {
      case _PourerState p:
        p.pos = pos;
      case _VesselState v:
        v.pos = pos;
    }
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` + `checkDrop(obj)`.
  void _release() {
    final s = _scene;
    final g = _grab;
    _grab = null;
    if (g == null || g.generation != s.generation) return;
    switch (g.item) {
      case _PourerState p:
        _dropPourer(p);
      case _VesselState v:
        _dropCup(v);
    }
  }

  /// The vessel whose column (from its base to the hover point above it)
  /// the container's centre is over, if any (nearest first).
  _VesselState? _vesselUnder(_PourerState p) {
    final s = _scene;
    final c = s.cam.p(p.pos);
    _VesselState? best;
    var bestD = double.infinity;
    for (final v in s.vessels) {
      final a = s.cam.p(v.bottom);
      final b = s.cam.p(v.pos + const _V(0, _hoverLift, 0));
      final reach = v.kind.rTop * s.cam.scaleAt(v.top) + _catchPad * s.view.k;
      final d = _segmentDistance(c, a, b);
      if (d <= reach && d < bestD) {
        best = v;
        bestD = d;
      }
    }
    return best;
  }

  /// A container let go: poured over its own vessel, otherwise it goes
  /// back home with a hint (the HTML poured into the target from anywhere
  /// within 8 units, even over another cup, and said nothing on a miss).
  void _dropPourer(_PourerState p) {
    final s = _scene;
    if (p.phase != _PourPhase.held) return;
    final target = s.vesselOf(p.kind.target);
    final over = _vesselUnder(p);
    p
      ..phaseStart = s.time
      ..from = p.pos;
    if (over == target && target.fill == 0) {
      p.phase = _PourPhase.snapping;
      return;
    }
    p.phase = _PourPhase.returning;
    _lab.showToast(
      _t(over != null ? 'wrong_${p.kind.name}' : 'miss_${p.kind.name}'),
      isError: true,
    );
  }

  /// A cup let go: weighed when it is on the pan, otherwise back home.
  void _dropCup(_VesselState v) {
    final s = _scene;
    if (v.phase != _CupPhase.held) return;
    final c = s.cam.p(v.pos);
    final a = s.cam.p(s.panCenter);
    final b = s.cam.p(s.panCenter + const _V(0, 4, 0));
    final reach =
        _panRadius * s.cam.scaleAt(s.panCenter) + _catchPad * s.view.k;
    v
      ..phaseStart = s.time
      ..from = v.pos;
    if (s.scaleShown && _segmentDistance(c, a, b) <= reach) {
      v.phase = _CupPhase.toPan;
      return;
    }
    v.phase = _CupPhase.returning;
    _lab.showToast(
      labFormat(_t('miss_scale'), {'cup': _t(v.kind.nameKey)}),
      isError: true,
    );
  }

  // --------------------------------------------------------------- framing

  /// Fits the scenario's objects and labels into the part of the canvas no
  /// shell card covers: the tool column, the HUD chip (sidebar open) and
  /// the floating mission card (sidebar collapsed: the scene moves below
  /// it or, if that would shrink it more, to its right). Returns the
  /// framing in design px for a canvas of [canvas] dp at stage scale [fit].
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
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _cardGap + pad.top,
      canvas.width - insets.right,
      canvas.height -
          (open ? _hudBand * context.labScale + _cardGap : _cardGap) -
          pad.bottom,
    );
    final frees = <Rect>[
      if (open || !_lab.isLabActive)
        base
      else ...[
        Rect.fromLTRB(insets.left, base.top, base.right, base.bottom),
        Rect.fromLTRB(
          base.left,
          size.height < _compactBelow
              ? _missionTop + pad.top + size.height * _compactCardMax + _cardGap
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
  /// the current scenario: objects, their labels and the balance.
  Rect _focusRect() {
    final l = _labelSize / _labelPx;
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    void label(_V at, double halfW, double halfH, {double edge = 0}) {
      final c = _baseCam.p(at);
      final w = 2 * halfW * l;
      add(
        Rect.fromCenter(
          center: c.translate(-edge * w / 2, 0),
          width: w,
          height: 2 * halfH * l,
        ),
      );
    }

    final sc = _scene.scenario;
    for (final k in _Pour.values.where((k) => k.scenario == sc)) {
      add(_boxBounds(_baseCam, k.home, k.half));
      if (k == _Pour.small) {
        label(_pourLabelAt(k, k.home), 45, 24, edge: 1);
      } else {
        label(_pourLabelAt(k, k.home), 55, k == _Pour.large ? 24 : 12);
      }
    }
    for (final k in _Vessel.values.where((k) => k.scenario == sc)) {
      add(_boxBounds(_baseCam, k.home, k.half));
      label(_vesselLabelAt(k, k.home), 45, k.isCup ? 24 : 12);
    }
    if (sc == 0) {
      add(
        _boxBounds(
          _baseCam,
          _scaleHome + const _V(0, 0.6, 0.5),
          const _V(3, 0.6, 3.5),
        ),
      );
      label(_scaleLabelAt(_scaleHome), 55, 12);
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

  /// HTML `#compare-btn-container` (shown at the last step).
  List<LabAction> _actions() {
    final s = _scene;
    if (s.compared || s.step != _stepCounts[s.scenario]) return const [];
    return [
      LabAction(
        label: _t('btn_compare'),
        icon: Icons.compare_arrows,
        color: _Colors.blue600,
        foreground: _Colors.white,
        highlight: true,
        silent: true,
        onTap: _compare,
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
        final sc = _scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final n = data.steps.length;
        final actions = _actions();
        return LabShell(
          controller: _lab,
          icon: Icons.scale,
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
            key: ValueKey('ch6a5-steps-$sc-${_scene.step}'),
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
            // HTML `#compare-btn-container`: the button also floats on the
            // canvas while the sidebar is open (its sidebar copy can be
            // below the fold on a phone). At the top, under the toast band;
            // the HUD chip has the bottom.
            if (_lab.isLabActive && _lab.isSidebarOpen && actions.isNotEmpty)
              Positioned(
                key: const ValueKey('ch6a5-compare-button'),
                top: inset.top + _toastBand * s,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: actions.first,
                    scale: s,
                    expand: false,
                  ),
                ),
              ),
            // HTML `#compare-overlay` text box, at the top of the canvas
            // (the HUD chip is at the bottom).
            if (_lab.isLabActive && _scene.compared)
              Positioned(
                key: const ValueKey('ch6a5-compare'),
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: _CompareCard(
                    text: _t(sc == 0 ? 'compare_s1' : 'compare_s2'),
                    scale: s,
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

/// HTML `#compare-text-box`: the comparison result (`compareText`), dark
/// with an amber border in both themes, as in the HTML.
class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.text, required this.scale});

  final String text;
  final double scale;

  /// HTML `max-w-2xl` at the HTML text size, x UI scale.
  static const double _maxWidth = 460;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxWidth * s),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 9 * s),
        decoration: BoxDecoration(
          color: _Colors.compareBg,
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(color: _Colors.amber500, width: 2),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowStrong,
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _Colors.white,
            fontSize: 11.5 * s,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// HTML teacher-board "Conceptual Exploration" accordion: one card per
/// step with its concept, action and observation. The current step is
/// open, done steps show a tick and can be re-opened, future steps are
/// dimmed. A step's observation is shown once the step is done (the HTML
/// showed it before the learner had seen it).
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
    // Future steps: HTML `opacity-50`.
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

  /// Thick butt-ended lines (cylinder shading bands).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// The poured stream and the pitcher handle.
  final Paint stream = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  /// Pulsing highlight of the object to move.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  final Path path = Path();
  final Path aux = Path();
}

/// Kinds of scene text.
enum _Ink {
  /// Object names: white bold on the dark sprite chip.
  chip,

  /// Comparison masses: white on black, dark on amber for the heaviest.
  mass,
  massDark,

  /// Big letters on the cups (dark) and numbers on the tumblers (white).
  markDark,
  markLight,

  /// "200 mL" printed on a bottle.
  volume,

  /// Green LED digits of the balance.
  readout;

  TextStyle style(double size) {
    final family = LabFont.active.family;
    final fallback = LabFont.active.fallback;
    return switch (this) {
      _Ink.chip => TextStyle(
        color: _Colors.white,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.mass || _Ink.massDark => TextStyle(
        color: this == _Ink.mass ? _Colors.white : _Colors.ink,
        fontSize: size * 1.1,
        fontWeight: FontWeight.w800,
        height: 1.2,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.markDark || _Ink.markLight => TextStyle(
        color: this == _Ink.markDark ? _Colors.ink : _Colors.white,
        fontSize: size * 1.7,
        fontWeight: FontWeight.w900,
        height: 1,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.volume => TextStyle(
        color: _Colors.ink,
        fontSize: size * 0.95,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.readout => TextStyle(
        color: _Colors.led,
        fontSize: size * 1.2,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: family,
        fontFamilyFallback: fallback,
        // Digits keep their width while the reading climbs.
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    };
  }
}

/// What the painter makes once and reuses: pens, the text painters of the
/// labels and readout digits, and the draw-order list. Owned by the page
/// state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _texts = {};

  /// Scene objects in drawing order (refilled every frame).
  final List<Object> order = [];

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

/// MeshStandardMaterial look: ambient light plus the warm key light's
/// Lambert term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final d = _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * (_ambient + d)),
    green: math.min(1.0, c.g * (_ambient + d * _lightG)),
    blue: math.min(1.0, c.b * (_ambient + d * _lightB)),
  );
}

/// [c] lit by the pulsing amber highlight ([amount] 0 … 0.5).
/// The HTML adds the amber as emissive light, so the colour brightens
/// towards amber instead of mixing with it.
Color _tint(Color c, double amount) => amount <= 0
    ? c
    : Color.from(
        alpha: c.a,
        red: math.min(1.0, c.r + _Colors.glow.r * amount),
        green: math.min(1.0, c.g + _Colors.glow.g * amount),
        blue: math.min(1.0, c.b + _Colors.glow.b * amount),
      );

/// HTML highlight pulse: 0 -> 0.5 -> 0, 500 ms each way.
double _pulse(double t) {
  final phase = (t / _glowHalfPeriod) % 2;
  return _glowMax * (phase < 1 ? phase : 2 - phase);
}

/// Sand grains and pebbles on a surface, as fractions of its half sizes.
const List<Offset> _grains = [
  Offset(-0.55, -0.2),
  Offset(-0.15, 0.35),
  Offset(0.3, -0.35),
  Offset(0.6, 0.15),
  Offset(0.05, -0.05),
  Offset(-0.4, 0.5),
  Offset(0.35, 0.55),
];

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

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _move(
          path,
          i,
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        );
      }
      path.close();
      canvas.drawPath(
        path,
        pens.fill..color = _lit(color, n, opacity: opacity),
      );
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// Upright CylinderGeometry(rt, rb, h) standing on [bottom]: side with
  /// shading bands (lit from +x, like the HTML key light), then the top
  /// cap, or the opening of an [open] cup or glass.
  void frustum(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 1,
    bool open = false,
  }) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final bottomOval = Rect.fromCenter(
      center: pb,
      width: 2 * wb,
      height: 2 * cam.ellipseHalf(bottom, rb),
    );
    final topOval = Rect.fromCenter(
      center: pt,
      width: 2 * wt,
      height: 2 * cam.ellipseHalf(top, rt),
    );
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    final side = _lit(color, const _V(0, 0, 1), opacity: opacity);
    canvas.drawPath(path, pens.fill..color = side);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx + wt * 0.4, pt.dy),
      Offset(pb.dx + wb * 0.4, bottomOval.bottom),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.34)
        ..color = labShade(side, 0.28),
    );
    canvas.drawLine(
      Offset(pt.dx - wt * 0.8, pt.dy),
      Offset(pb.dx - wb * 0.8, bottomOval.bottom),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.4)
        ..color = labShade(side, -0.3),
    );
    canvas.restore();
    if (open) {
      // The inside seen through the opening, and the rim.
      canvas.drawOval(
        topOval,
        pens.fill
          ..color = labShade(
            color,
            -0.35,
          ).withValues(alpha: 0.55 * opacity + 0.2),
      );
      canvas.drawOval(
        topOval,
        pens.stroke
          ..strokeWidth = 1.4
          ..color = labShade(
            color,
            0.2,
          ).withValues(alpha: math.min(1.0, opacity + 0.4)),
      );
      return;
    }
    canvas.drawOval(
      topOval,
      pens.fill..color = _lit(color, _V.up, opacity: opacity),
    );
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = 1
        ..color = labShade(color, -0.35).withValues(alpha: opacity),
    );
  }

  /// Grains (sand) or stones (pebbles) on the horizontal circle of
  /// [radius] at [c].
  void grains(_V c, double radius, Color color, double size) {
    final w = radius * cam.scaleAt(c);
    final h = cam.ellipseHalf(c, radius);
    final o = cam.p(c);
    for (final g in _grains) {
      canvas.drawOval(
        Rect.fromCenter(
          center: o + Offset(g.dx * w * 0.8, g.dy * h * 0.8),
          width: size,
          height: size * 0.7,
        ),
        pens.fill..color = color,
      );
    }
  }

  /// Soft blurred shadow of a round footprint of [radius] on the table.
  void shadow(_V at, double radius) {
    final c = _V(at.x + 0.2, 0.01, at.z - 0.2);
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

/// Paints the HTML Three.js scene of the current scenario: S1 the cups,
/// the pitcher, the scoops and the digital balance; S2 the tumblers and
/// the bottles; then the sprite labels.
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

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    final s = scene;
    final g = _Gfx(canvas, s.cam, _pens);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneBg : _Colors.sceneBgLight,
    );
    // `BoxGeometry(40, 0.5, 20)` table at y = -0.25.
    g.box(
      const _V(0, -0.25, 0),
      const _V(40, 0.5, 20),
      s.scenario == 0 ? _Colors.tableMass : _Colors.tableVolume,
      edge: 0,
    );
    for (final v in s.vessels) {
      g.shadow(v.pos, v.kind.rBottom);
    }
    for (final p in s.pourers) {
      if (p.used) continue;
      g.shadow(p.pos, p.kind.isBox ? p.kind.width * 0.6 : p.kind.width);
    }

    // Far to near; whatever is held or pouring on top.
    final order = cache.order..clear();
    for (final p in s.pourers) {
      if (!p.used) order.add(p);
    }
    order.addAll(s.vessels);
    if (s.scaleShown) order.add(s);
    order.sort((a, b) {
      final la = _layer(a), lb = _layer(b);
      if (la != lb) return la.compareTo(lb);
      return s.cam.depth(_centre(b)).compareTo(s.cam.depth(_centre(a)));
    });
    final active = s.active;
    final glow = active == null ? 0.0 : _pulse(s.time);
    for (final o in order) {
      switch (o) {
        case _PourerState p:
          _paintPourer(g, p, identical(p, active) ? glow : 0);
        case _VesselState v:
          _paintVessel(g, v, identical(v, active) ? glow : 0);
        case _Scene _:
          _paintScale(g);
      }
    }
    _paintTexts(canvas, g);
  }

  int _layer(Object o) => switch (o) {
    _PourerState p => p.phase == _PourPhase.idle ? 0 : 1,
    _VesselState v => v.phase == _CupPhase.held ? 1 : 0,
    _ => 0,
  };

  _V _centre(Object o) => switch (o) {
    _PourerState p => p.pos,
    _VesselState v => v.pos,
    _ => scene.scalePos + const _V(0, 0.5, 0),
  };

  /// The pulsing amber glow behind an object (HTML emissive highlight).
  void _glow(_Gfx g, Rect bounds, double amount) {
    if (amount <= 0) return;
    g.canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.inflate(6), const Radius.circular(14)),
      _pens.glow..color = _Colors.glow.withValues(alpha: amount * 1.4),
    );
  }

  // --------------------------------------------------------- containers

  void _paintPourer(_Gfx g, _PourerState p, double glow) {
    final k = p.kind;
    final canvas = g.canvas;
    final c = g.cam.p(p.pos);
    final angle = p.tilt * _tiltAngle;
    canvas.save();
    if (angle != 0) {
      // Tipped about the view axis (HTML `rotation.z`, clockwise on screen).
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      canvas.translate(-c.dx, -c.dy);
    }
    _glow(g, _boxBounds(g.cam, p.pos, k.half), glow);
    final color = _tint(k.color, glow);
    if (k.isBox) {
      g.box(p.pos, _V(k.width, k.height, k.width), color);
      // What the scoop holds, on its top face.
      final grain = labShade(k.color, k == _Pour.sand ? 0.35 : -0.35);
      g.grains(
        p.pos + _V(0, k.height / 2 + 0.01, 0),
        k.width * 0.45,
        grain,
        (k == _Pour.sand ? 0.18 : 0.42) * g.cam.scaleAt(p.pos),
      );
    } else {
      final bottom = p.pos - _V(0, k.height / 2, 0);
      if (k == _Pour.pitcher) _paintHandle(g, p, color);
      g.frustum(bottom, k.width, k.width, k.height, color, opacity: k.opacity);
      if (k != _Pour.pitcher) {
        // Neck and cap (added; the HTML bottles are plain cylinders).
        final top = bottom + _V(0, k.height, 0);
        g.frustum(
          top,
          k.width * 0.45,
          k.width * 0.35,
          0.5,
          color,
          opacity: k.opacity,
        );
        g.frustum(
          top + const _V(0, 0.5, 0),
          k.width * 0.4,
          k.width * 0.4,
          0.35,
          _Colors.bottleCap,
        );
      }
    }
    canvas.restore();
  }

  /// The pitcher's handle on its right side (added for recognition).
  void _paintHandle(_Gfx g, _PourerState p, Color color) {
    final k = p.kind;
    final a = g.cam.p(p.pos + _V(k.width * 0.9, k.height * 0.3, 0));
    final b = g.cam.p(p.pos + _V(k.width * 0.9, -k.height * 0.25, 0));
    final out = g.cam.p(p.pos + _V(k.width * 1.55, k.height * 0.05, 0));
    final path = _pens.aux
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(2 * out.dx - (a.dx + b.dx) / 2, out.dy, b.dx, b.dy);
    g.canvas.drawPath(
      path,
      _pens.stream
        ..strokeWidth = 0.35 * g.cam.scaleAt(p.pos)
        ..color = labShade(color, -0.15).withValues(alpha: k.opacity),
    );
  }

  /// The water, sand or pebbles falling from the tipped container's mouth
  /// into the vessel (added: the HTML only raised the fill level).
  void _paintStream(_Gfx g, _PourerState p, _VesselState v) {
    final t = scene.time - p.phaseStart;
    if (t < _fillDelay || t > _fillDelay + _fillSeconds) return;
    final c = g.cam.p(p.pos);
    final a = p.tilt * _tiltAngle;
    final d = g.cam.p(p.pos + _V(0, p.kind.height / 2, 0)) - c;
    final mouth =
        c +
        Offset(
          d.dx * math.cos(a) - d.dy * math.sin(a),
          d.dx * math.sin(a) + d.dy * math.cos(a),
        );
    final k = v.kind;
    final surface = g.cam.p(
      v.bottom +
          _V(0, (k.height - k.fillHeight) / 2 + k.fillHeight * v.fill, 0),
    );
    final path = _pens.aux
      ..reset()
      ..moveTo(mouth.dx, mouth.dy)
      ..quadraticBezierTo(surface.dx, mouth.dy, surface.dx, surface.dy);
    g.canvas.drawPath(
      path,
      _pens.stream
        ..strokeWidth = 0.35 * g.cam.scaleAt(v.top)
        ..color = k.fillColor.withValues(alpha: 0.9),
    );
  }

  // ------------------------------------------------------------ vessels

  void _paintVessel(_Gfx g, _VesselState v, double glow) {
    final k = v.kind;
    final pouring = scene.pouringInto(v);
    if (pouring != null) _paintStream(g, pouring, v);
    _glow(g, _boxBounds(g.cam, v.pos, k.half), glow);
    final bottom = v.bottom;
    if (v.fill > 0.001) {
      // HTML fill mesh, from just above the vessel's bottom.
      final h = k.fillHeight * v.fill;
      final fillBottom = bottom + _V(0, (k.height - k.fillHeight) / 2, 0);
      g.frustum(
        fillBottom,
        k.fillRBottom,
        k.fillRBottom + (k.fillRTop - k.fillRBottom) * v.fill,
        h,
        k.fillColor,
        opacity: k.fillOpacity,
      );
      if (k == _Vessel.cupB || k == _Vessel.cupC) {
        final cupB = k == _Vessel.cupB;
        g.grains(
          fillBottom + _V(0, h + 0.01, 0),
          k.fillRBottom + (k.fillRTop - k.fillRBottom) * v.fill,
          labShade(k.fillColor, cupB ? 0.3 : -0.45),
          (cupB ? 0.16 : 0.45) * g.cam.scaleAt(v.pos),
        );
      }
    }
    g.frustum(
      bottom,
      k.rBottom,
      k.rTop,
      k.height,
      _tint(k.color, glow),
      opacity: k.opacity,
      open: true,
    );
  }

  // ------------------------------------------------------------ balance

  /// `s1Scale`: base, pan (dipping while it weighs) and display box.
  void _paintScale(_Gfx g) {
    final o = scene.scalePos;
    g.box(o + _V(0, _baseSize.y / 2, 0), _baseSize, _Colors.scaleBase);
    g.frustum(
      o + _V(0, _panBottom + scene.panDip, 0),
      _panRadius,
      _panRadius,
      _panHeight,
      _Colors.pan,
    );
    g.box(o + _displayAt, _displaySize, _Colors.display);
  }

  // -------------------------------------------------------------- texts

  void _paintTexts(Canvas canvas, _Gfx g) {
    final s = scene;
    final cam = s.cam;
    final g0 = _t('unit_g');
    // Always shown (not sprite labels in the HTML): the readout (until the
    // balance is moved away for the comparison) and the comparison masses.
    if (s.scenario == 0 && s.scaleShown && !s.compared) {
      _readout(canvas, cam.p(_readoutAt(s.scalePos)), '${s.readout} $g0');
    }
    if (s.scenario == 0 && s.compared) {
      for (final v in s.vessels) {
        final heavy = v.kind == _Vessel.cupC;
        _chip(
          canvas,
          cam.p(v.top + const _V(0, 1.1, 0)),
          '${v.kind.mass} $g0',
          ink: heavy ? _Ink.massDark : _Ink.mass,
          background: heavy ? _Colors.heavyBg : _Colors.massBg,
        );
      }
    }
    if (!showLabels) return;
    final size = cache.labelSize;
    // Vessel labels wrap within the gap between neighbours.
    final spacing = s.vessels.length < 2
        ? double.infinity
        : (cam.p(s.vessels[1].pos) - cam.p(s.vessels[0].pos)).distance;
    for (final v in s.vessels) {
      final k = v.kind;
      _mark(
        canvas,
        // The big letter / number on its front, drawn at its axis, which
        // projects to the middle of its picture.
        cam.p(v.pos),
        k.mark,
        k.isCup ? _Ink.markDark : _Ink.markLight,
      );
      // Under the vessel while it stands in its place (on the pan the
      // balance's own label and readout are there).
      final atRest =
          v.phase == _CupPhase.idle &&
          (s.compared || (v.pos - k.home).length < 0.01);
      if (atRest) {
        _chip(
          canvas,
          cam.p(_vesselLabelAt(k, v.pos)),
          _t(k.labelKey),
          maxWidth: math.min(size * _chipWrap, spacing),
          fit: spacing - _labelGap,
        );
      }
    }
    for (final p in s.pourers) {
      final k = p.kind;
      final still = p.phase == _PourPhase.idle || p.phase == _PourPhase.held;
      if (p.used || !still) continue;
      if (k.millilitres > 0) {
        _volume(
          canvas,
          cam.p(p.pos),
          '${k.millilitres} ${_t('unit_ml')}',
          2 * k.width * cam.scaleAt(p.pos),
        );
      }
      final small = k == _Pour.small;
      _chip(
        canvas,
        cam.p(_pourLabelAt(k, p.pos)),
        _t(k.labelKey),
        maxWidth: size * (k.millilitres > 0 ? _bottleWrap : _chipWrap),
        edge: small ? 1 : 0,
      );
    }
    if (s.scenario == 0 && s.scaleShown && !s.compared) {
      _chip(canvas, cam.p(_scaleLabelAt(s.scalePos)), _t('lbl_scale'));
    }
  }

  /// HTML text sprite: dark chip with an amber border and white bold text
  /// centred on [at]; with [edge] 1 its right edge sits on [at]. Lines wrap
  /// at [maxWidth]; chips are kept left of the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    double maxWidth = double.infinity,
    double edge = 0,
    double fit = double.infinity,
    _Ink ink = _Ink.chip,
    Color background = _Colors.labelBg,
  }) {
    final tp = cache.text(ink, text, maxWidth: maxWidth);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    // A chip wider than [fit] is shrunk about [at] until it fits.
    final shrink = w > fit && fit > 0 ? fit / w : 1.0;
    if (shrink < 1) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.scale(shrink);
      canvas.translate(-at.dx, -at.dy);
    }
    final left = math.min(at.dx - (edge + 1) / 2 * w, labelRight - 4 - w);
    final rect = Rect.fromLTWH(left, at.dy - h / 2, w, h);
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(h / 2, size * 0.8)),
    );
    canvas.drawRRect(rr, _pens.fill..color = background);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.labelBorder,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
    if (shrink < 1) canvas.restore();
  }

  /// Big letter / number on a vessel (transparent sprite).
  void _mark(Canvas canvas, Offset at, String text, _Ink ink) {
    final tp = cache.text(ink, text);
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  /// "200 mL" printed across a bottle [width] design px wide (shrunk to
  /// fit inside it).
  void _volume(Canvas canvas, Offset at, String text, double width) {
    final tp = cache.text(_Ink.volume, text);
    final k = math.min(1.0, width * _printFit / tp.width);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(k);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  /// HTML `updateDigitalReadout`: green LED digits on black.
  void _readout(Canvas canvas, Offset at, String text) {
    final tp = cache.text(_Ink.readout, text);
    final size = cache.labelSize;
    final rect = Rect.fromCenter(
      center: at,
      width: math.max(tp.width + size * 1.2, size * 5),
      height: tp.height + size * 0.5,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.3));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.ledPanel);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.slate600,
    );
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
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
