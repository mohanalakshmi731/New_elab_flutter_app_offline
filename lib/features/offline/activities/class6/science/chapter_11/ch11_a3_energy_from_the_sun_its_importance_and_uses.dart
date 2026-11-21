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

/// Class 6 Science • Chapter 11 • Activity 3
/// Energy from the Sun: Its Importance and Uses ("Energy from the Sun: The
/// Ultimate Power Source").
///
/// Native Flutter port of
/// `Cl6S-Ch11-A3-Energy_from_the_Sun__Its_Importance_and_Uses.html`
/// (Three.js r128 + Tween.js). The floating-island scenes are redrawn in 2D
/// by [_ScenePainter] through the HTML cameras (45° field of view, looking
/// at (0, 3.5, 0) from (0, 11.5, 31) in Scenario 1 and from (0, 10.5, 28)
/// in Scenario 2). The HTML inventory bar is a panel on the right of the
/// canvas: tap an item, or drag it and drop it anywhere on the scene.
///
/// Scenario 1 (The Sun's energy in our food): place the Sun in the dim sky
/// (the scene brightens and golden energy particles stream down from it),
/// tap the barren soil patch to sprout glowing grass and place the cow on
/// it (green energy particles flow from the grass into the grazing cow,
/// which starts to glow). A cloud over the Sun wilts the grass and the cow
/// stops eating and droops its head; clearing the sky brings everything
/// back, and the summary popup follows.
///
/// Scenario 2 (Harnessing the Sun's power): mount the solar panel on the
/// house roof, connect the wire from the panel to the light-bulb stand and
/// place the Sun: blue electric pulses run down the wire and the bulb
/// lights up. A cloud over the Sun stops the pulses and the bulb goes dark;
/// clearing the sky lights it again and the summary popup follows. Once
/// both scenarios are done, 'Mastery Achieved!' offers a full restart.
class Ch11A3EnergyFromTheSunItsImportanceAndUsesPage extends StatefulWidget {
  const Ch11A3EnergyFromTheSunItsImportanceAndUsesPage({super.key});

  @override
  State<Ch11A3EnergyFromTheSunItsImportanceAndUsesPage> createState() =>
      _SunEnergyLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/`. The HTML
/// synthesises five Web Audio tones; here they are click (HTML `click`,
/// `science/click.mp3`: an inventory item used, a step card tapped),
/// success (HTML `success`, `math/success.mp3`: the Sun, the grass, the cow
/// or the panel placed, the summary and the mastery popup), pop (HTML
/// `pop`, `science/click.mp3`: a step done), electric (HTML `electric`,
/// `science/dropdown.mp3`: the wire connected, the bulb lighting up) and
/// cloud (HTML `cloud`, `science/dropdown.mp3`: the cloud moving in or
/// out). The shell plays toggle (`science/dropdown.mp3`: sidebar), correct
/// (`math/success.mp3`), wrong (`science/error.mp3`: the HTML's refusal
/// toasts, where the HTML only clicked), scenario (`science/page_open.mp3`)
/// and curtain (`science/curtain.mp3`).
enum _Sound implements LabTone {
  /// HTML `click`: an inventory item used, a step card, a popup closed.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Shell feedback for a positive toast (this lab shows none of its own).
  correct('audio/class6/math/success.mp3'),

  /// A refused inventory item ('Place the Sun first!' and the like).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: an object placed, the summary and mastery popups.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: a step done (`progressStep()`).
  pop('audio/class6/science/click.mp3'),

  /// HTML `electric`: the wire connected, the bulb lighting up.
  electric('audio/class6/science/dropdown.mp3'),

  /// HTML `cloud`: the cloud drifting in front of the Sun or away.
  cloud('audio/class6/science/dropdown.mp3');

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
  static const Color gray950 = Color(0xFF030712);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color red500 = Color(0xFFEF4444);

  // --------------------------------------------------------------- scene
  /// `scene.background`: `setLightingDim()` 0x051125 (dark) / 0xbae6fd
  /// (light), `setLightingBright()` 0x0c4a6e (dark) / 0x38bdf8 (light).
  static const Color skyDimDark = Color(0xFF051125);
  static const Color skyBrightDark = Color(0xFF0C4A6E);
  static const Color skyDimLight = Color(0xFFBAE6FD);
  static const Color skyBrightLight = Color(0xFF38BDF8);

  /// Directional light colour: 0x94a3b8 when dim, 0xfffbeb when bright.
  static const Color lightDim = slate400;
  static const Color lightBright = Color(0xFFFFFBEB);

  /// Scenario 1 plateau (0x472a18), its fertile soil (0x5c3818) and the
  /// rim rocks (0x64748b).
  static const Color plateau = Color(0xFF472A18);
  static const Color soil = Color(0xFF5C3818);
  static const Color rock = slate500;

  /// Grass blades (0x16a34a) and their energy glow (emissive 0x10b981).
  static const Color grass = Color(0xFF16A34A);
  static const Color grassGlow = emerald500;

  /// `buildHighFidelitySun()`: core 0xfacc15, coronas 0xfde047 (opacity
  /// 0.45) and 0xf59e0b (0.25), sunburst beams 0xfef08a (0.8).
  static const Color sunCore = Color(0xFFFACC15);
  static const Color sunCorona1 = Color(0x73FDE047);
  static const Color sunCorona2 = Color(0x40F59E0B);
  static const Color sunBeam = Color(0xCCFEF08A);

  /// Soft halo behind the Sun (added: the HTML relies on its coronas).
  static const Color sunHalo = Color(0xFFFDE047);

  /// `buildCloudMesh()`: white puffs.
  static const Color cloud = white;

  /// `buildHighFidelityCow()`: body 0xf8fafc, patches 0x0f172a, hooves
  /// 0x1e293b, snout 0xfca5a5, horns 0xe2e8f0, ears 0x0f172a; the energy
  /// glow is emissive 0x34d399.
  static const Color cowBody = Color(0xFFF8FAFC);
  static const Color cowPatch = slate900;
  static const Color cowHoof = slate800;
  static const Color cowSnout = Color(0xFFFCA5A5);
  static const Color cowHorn = slate200;
  static const Color cowEar = slate900;
  static const Color cowGlow = emerald400;

  /// Energy particles: Sun → grass 0xfacc15, grass → cow 0x34d399, the
  /// electric pulses 0x38bdf8.
  static const Color solarMote = sunCore;
  static const Color cowMote = emerald400;
  static const Color spark = Color(0xFF38BDF8);

  /// Scenario 2 plateau (0x1e293b) and lawn (0x15803d).
  static const Color plateau2 = slate800;
  static const Color lawn = Color(0xFF15803D);

  /// The house: walls 0xf8fafc, window 0x38bdf8 (metalness 0.8), roof
  /// 0xb91c1c.
  static const Color walls = Color(0xFFF8FAFC);
  static const Color window = Color(0xFF38BDF8);
  static const Color roof = Color(0xFFB91C1C);

  /// Solar panel: frame 0x0f172a, cells 0x2563eb.
  static const Color panelFrame = slate900;
  static const Color panelCell = blue600;

  /// Bulb stand: base 0x334155, pole 0x64748b, socket 0xd4d4d8.
  static const Color standBase = slate700;
  static const Color standPole = slate500;
  static const Color socket = Color(0xFFD4D4D8);

  /// The glass bulb: off white (opacity 0.4) with a 0x475569 filament; on
  /// 0xfffbeb with emissive 0xfef08a (×2) and a white filament.
  static const Color bulbOff = Color(0x66FFFFFF);
  static const Color bulbOn = Color(0xF2FFFBEB);
  static const Color bulbEmissive = Color(0xFFFEF08A);
  static const Color filamentOff = slate600;
  static const Color filamentOn = white;

  /// Bulb glow: coronas 0xfde047 (0.65), 0xfacc15 (0.35), 0xf59e0b (0.18)
  /// and rays 0xfef08a (0.45); the point light 0xfacc15.
  static const Color bulbCorona1 = Color(0xA6FDE047);
  static const Color bulbCorona2 = Color(0x59FACC15);
  static const Color bulbCorona3 = Color(0x2EF59E0B);
  static const Color bulbRay = Color(0x73FEF08A);
  static const Color bulbLight = sunCore;

  /// The wire (0x0284c7).
  static const Color wire = Color(0xFF0284C7);

  /// Scene label sprites: `rgba(30, 41, 59, 0.94)` with a #475569 border.
  static const Color labelBg = Color(0xF01E293B);
  static const Color labelBorder = slate600;

  /// The drag ghost (`bg-amber-500/90`, white border).
  static const Color ghost = Color(0xE6F59E0B);

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
    bg: _Colors.gray950, // --bg-primary #030712
    panel: Color(0xE60F172A), // --glass-bg rgba(15, 23, 42, 0.90)
    border: Color(0x24FFFFFF), // --glass-border white/14
    card: _Colors.slate800, // step cards dark:bg-slate-800
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950, // #canvas-wrapper bg-slate-950
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500, // amber-500 accents
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: _Colors.slate950,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900, // summary modal dark:bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A), // toast bg-slate-900/95
    toastText: _Colors.white,
    curtainBg: _Colors.slate950, // #shutter-screen bg-slate-950
    curtainGlow: Color(0x66F59E0B), // from-amber-500/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xE6FCD34D), // subtitle text-amber-300/90
    curtainIcon: _Colors.slate300,
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
    bg: _Colors.slate100, // --bg-primary #f1f5f9
    panel: Color(0xF0FFFFFF), // --glass-bg rgba(255, 255, 255, 0.94)
    border: Color(0x5994A3B8), // --glass-border rgba(148, 163, 184, 0.35)
    card: _Colors.white,
    cardBorder: _Colors.slate200,
    canvasBg: _Colors.slate950,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.emerald600,
    onPrimary: _Colors.slate950,
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
    curtainGlow: Color(0x66F59E0B),
    curtainText: _Colors.white,
    curtainMuted: Color(0xE6FCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF0FFFFFF),
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
/// sidebar font size slider (15 px default, 13–22 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 13,
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
// Current Objective, Step, Continue, the settings and canvas-tool names
// and the footer) come from the shell's `kLabCommonStrings`. Changes:
// * "Click" / "CLICK" read "Tap" / "TAP" ('टैप करें' for 'क्लिक करें');
// * each summary keeps the HTML's bold heading and bullet list in a small
//   markup: `heading|*Lead:* text|*Lead:* text…` ([_SummaryCard] draws it);
// * the HTML's toasts are English literals; they get a Hindi translation,
//   marked "HTML literal";
// * `shutter_desc` is not shown by the HTML and is left out;
// * keys marked "Added." are new texts (scene descriptions for screen
//   readers).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Energy from the Sun: The Ultimate Power Source',
    'app_subtitle': "Class 6 . Nature's Treasures",
    // ScenariosData[en][1].
    'scen_1_title': "Scenario 1: The Sun's Energy in Our Food",
    's1_obj':
        "To visually demonstrate how the Sun's energy is captured by plants via photosynthesis and transferred to a cow through the grass it eats (Based on Textbook Sec 11.3).",
    's1_hud_1':
        "Step 1: Tap or Drag 'Sun' from the Inventory to place the glowing Sun into the sky.",
    's1_hud_2':
        'Step 2: Tap on the barren soil patch to sprout grass and absorb golden solar particles.',
    's1_hud_3':
        "Step 3: Tap or Drag 'Cow' from the Inventory onto the glowing green grass.",
    's1_hud_4':
        "Step 4: Tap or Drag 'Cloud' from the Inventory to block the Sun and observe the wilting grass.",
    's1_hud_5':
        "Step 5: Tap 'Cloud' again to reveal the Sun, then tap 'Observe Conclusion & Summary'.",
    's1_c1': 'Deploying the Sun into Sky',
    's1_a1': "TAP or DRAG 'Sun' from the inventory into the sky box.",
    's1_o1':
        'The Sun appears in the sky! The dim scene brightens dramatically with radiating sunburst beams.',
    's1_c2': 'Photosynthesis & Plant Growth',
    's1_a2': 'TAP directly on the barren brown soil patch.',
    's1_o2':
        'Lush green grass sprouts! Golden energy particles stream from the Sun into the grass, giving it an energy aura.',
    's1_c3': 'Food Chain Energy Transfer',
    's1_a3': "TAP or DRAG 'Cow' onto the field of grass.",
    's1_o3':
        'The cow grazes peacefully. Golden energy particles transfer from the grass into the cow, filling it with glowing energy!',
    's1_c4': 'Blocking Solar Energy Source',
    's1_a4': "TAP or DRAG 'Cloud' to block the Sun.",
    's1_o4':
        'A dense cloud blocks the sunlight. The grass wilts and turns dark; the cow stops eating and droops its head.',
    's1_c5': 'Scientific Verification',
    's1_a5':
        "TAP 'Cloud' to clear the sky, then observe the conclusion & summary popup.",
    's1_o5':
        'Sunlight returns! The grass regrows and cow becomes energized again. All food energy originates from the Sun!',
    's1_summary':
        'Food Chain Energy Pathway Verified!|'
        '*Sun to Plants:* The Sun emits light and heat energy. Green grass absorbs this solar energy through photosynthesis to grow.|'
        '*Plants to Animals:* Cows and other animals consume plants. The energy stored inside the plant cells is transferred to the animals to power their movement and growth.|'
        '*Key Conclusion:* Every bite of food we eat (salads, grains, milk, or meat) contains energy that originally came from the Sun!',
    // ScenariosData[en][2].
    'scen_2_title': "Scenario 2: Harnessing the Sun's Power",
    's2_obj':
        'To visually demonstrate how a solar panel captures direct sunlight and converts it into clean, usable electricity to light up a bulb (Textbook Sec 11.3).',
    's2_hud_1':
        "Step 1: Tap or Drag 'Solar Panel' from the Inventory onto the house roof.",
    's2_hud_2':
        "Step 2: Tap 'Connect Wire' in the Inventory to link the solar panel to the light bulb stand.",
    's2_hud_3':
        "Step 3: Tap or Drag 'Sun' into the sky to shine solar beams onto the panel.",
    's2_hud_4':
        "Step 4: Tap or Drag 'Cloud' to block the Sun and observe the electric flow stop.",
    's2_hud_5':
        "Step 5: Tap 'Cloud' again to clear the sky, then tap 'Observe Conclusion & Summary'.",
    's2_c1': 'Mounting Solar Photovoltaic Panel',
    's2_a1': "TAP or DRAG 'Solar Panel' from inventory to the house roof.",
    's2_o1':
        'The silicon solar panel array snaps securely onto the angled roof structure.',
    's2_c2': 'Completing Electrical Circuit',
    's2_a2': "TAP 'Connect Wire' in the inventory.",
    's2_o2':
        'A high-conductivity wire connects the rooftop solar panel directly to the light bulb stand.',
    's2_c3': 'Generating Solar Electricity',
    's2_a3': "TAP or DRAG 'Sun' from the inventory.",
    's2_o3':
        'Sunlight hits the panel cells! Blue electrical pulse particles speed through the wire and the bulb lights up brightly!',
    's2_c4': 'Weather Impact on Solar Output',
    's2_a4': "TAP or DRAG 'Cloud' to obscure the Sun.",
    's2_o4':
        'The cloud blocks solar radiation. Electrical pulse flow ceases instantly and the light bulb flickers off.',
    's2_c5': 'Clean Energy Verification',
    's2_a5':
        "TAP 'Cloud' to clear the sky, then observe the conclusion & summary popup.",
    's2_o5':
        'Solar power generation resumes immediately! Solar panels provide clean, renewable electricity.',
    's2_summary':
        'Direct Solar Energy Conversion!|'
        '*Photovoltaic Effect:* Solar panels contain silicon cells that capture direct light energy from the Sun.|'
        '*Conversion to Electricity:* When sunlight hits these cells, it creates an electrical current that flows through wires.|'
        '*Real-World Importance:* Unlike fossil fuels, solar energy is clean, silent, and endless. It powers homes, schools, and satellites without air pollution!',
    // i18n: sidebar checklist, popups and the inventory.
    'concept_exp': 'Observation Checklist',
    'action_req': 'Action Required',
    'observation': 'Scientific Observation',
    'next_sc': 'Explore Next Scenario',
    'restart_lab': 'Restart Entire Lab',
    'all_complete': 'Mastery Achieved!',
    'success': 'Lab Complete!',
    'all_complete_desc':
        'You have mastered how the Sun is the ultimate power source on Earth! You traced the solar energy path through photosynthesis into our food chain, and demonstrated how solar technology captures light energy to produce clean electricity!',
    'btn_conclude': 'Observe Conclusion & Summary',
    'inventory': 'Inventory',
    'drag_hint': 'Tap or Drag & Drop onto scene',
    'item_sun': 'Sun',
    'item_cow': 'Cow',
    'item_cloud': 'Cloud',
    'item_panel': 'Solar Panel',
    'item_wire': 'Connect Wire',
    'cloud_block': 'Cover Sky',
    'cloud_clear': 'Clear Sky',
    // Scene label sprites.
    'lbl_sun': 'Sun',
    'lbl_soil': 'Soil Patch',
    'lbl_grass': 'Grass',
    'lbl_cow': 'Cow',
    'lbl_panel': 'Solar Panel',
    'lbl_bulb': 'Light Bulb',
    // HTML literal: the refusal toasts of useInventoryItem().
    'toast_sun_first': 'Please follow Step 1: Place the Sun first!',
    'toast_sun_placed': 'The Sun is already in the sky!',
    'toast_grass_first': 'Please sprout grass on the soil in Step 2 first!',
    'toast_cow_placed': 'The Cow is already grazing!',
    'toast_add_first': 'Add the Sun, Grass, and Cow first!',
    'toast_panel_placed': 'Solar panel is already mounted on the roof!',
    'toast_panel_first': 'Place the solar panel on the roof first!',
    'toast_wire_placed': 'The wire is already connected!',
    'toast_wire_first': 'Connect the wire to the light bulb first!',
    'toast_sun_shining': 'The Sun is already shining!',
    // Added: scene descriptions for screen readers.
    'scene_s1':
        'A floating island of brown soil with a rocky rim, under the sky',
    'scene_s2':
        'A floating island with a white house with a red roof and a light bulb on a stand, under the sky',
  },
  'hi': {
    'app_title': 'सूर्य से ऊर्जा: परम शक्ति का स्रोत',
    'app_subtitle': 'कक्षा 6 . प्रकृति का खजाना',
    'scen_1_title': 'परिदृश्य 1: हमारे भोजन में सूर्य की ऊर्जा',
    's1_obj':
        'यह समझना कि सूर्य की ऊर्जा प्रकाश संश्लेषण द्वारा पौधों में और वहां से घास खाने वाली गाय तक कैसे पहुँचती है।',
    's1_hud_1':
        "चरण 1: आकाश में सूर्य लाने के लिए सामग्री से 'सूर्य' पर टैप करें या ड्रैग करें।",
    's1_hud_2': 'चरण 2: घास उगाने के लिए उपजाऊ मिट्टी पर टैप करें।',
    's1_hud_3':
        "चरण 3: गाय को घास के मैदान में लाने के लिए 'गाय' पर टैप करें या ड्रैग करें।",
    's1_hud_4':
        "चरण 4: सूर्य को ढकने के लिए 'बादल' पर टैप करें और घास पर प्रभाव देखें।",
    's1_hud_5':
        "चरण 5: बादल हटाने के लिए फिर से टैप करें और 'निष्कर्ष देखें' पर टैप करें।",
    's1_c1': 'सूर्य का उदय',
    's1_a1': "सामग्री में 'सूर्य' पर टैप करें या आकाश में ड्रैग करें।",
    's1_o1':
        'आकाश में सुनहरा सूर्य चमकने लगता है! पूरा दृश्य सुनहरी किरणों से रोशन हो जाता है।',
    's1_c2': 'प्रकाश संश्लेषण और घास वृद्धि',
    's1_a2': 'मिट्टी के क्षेत्र पर सीधे टैप करें।',
    's1_o2':
        'हरी घास उगती है! सूर्य से ऊर्जा के कण घास में प्रवेश करते हैं और घास चमक उठती है।',
    's1_c3': 'खाद्य श्रृंखला में ऊर्जा का स्थानांतरण',
    's1_a3': "सामग्री में 'गाय' पर टैप करें या घास पर ड्रैग करें।",
    's1_o3':
        'गाय घास खाती है। घास से ऊर्जा के कण गाय के शरीर में स्थानांतरित होते हैं और गाय ऊर्जा से भर जाती है!',
    's1_c4': 'ऊर्जा स्रोत में रुकावट',
    's1_a4': "सामग्री में 'बादल' पर टैप करें या सूर्य के सामने लाएं।",
    's1_o4':
        'बादल सूर्य को ढक लेता है। घास मुरझा जाती है और गाय उदास होकर सिर झुका लेती है।',
    's1_c5': 'वैज्ञानिक पुष्टि',
    's1_a5': "बादल हटाएं और 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's1_o5':
        'धूप लौटते ही घास फिर से हरी हो जाती है! भोजन की सारी ऊर्जा मूल रूप से सूर्य से ही आती है!',
    's1_summary':
        'खाद्य श्रृंखला ऊर्जा पथ सत्यापित!|'
        '*सूर्य से पौधों तक:* सूर्य प्रकाश और ऊष्मा ऊर्जा देता है। हरी घास प्रकाश संश्लेषण के माध्यम से इस ऊर्जा को ग्रहण करती है।|'
        '*पौधों से जानवरों तक:* गाय और अन्य जानवर पौधों को खाते हैं, जिससे पौधों की ऊर्जा जानवरों को मिलती है।|'
        '*मुख्य निष्कर्ष:* हम जो भी भोजन करते हैं, उसकी ऊर्जा का मूल स्रोत सूर्य ही है!',
    'scen_2_title': 'परिदृश्य 2: सूर्य की शक्ति का उपयोग',
    's2_obj':
        'यह देखना कि सौर पैनल सूर्य के प्रकाश को सीधे विद्युत ऊर्जा में कैसे बदलते हैं और बल्ब को रोशन करते हैं।',
    's2_hud_1':
        "चरण 1: छत पर सौर पैनल लगाने के लिए 'सौर पैनल' पर टैप करें या ड्रैग करें।",
    's2_hud_2':
        "चरण 2: पैनल को बल्ब से जोड़ने के लिए 'तार जोड़ें' पर टैप करें।",
    's2_hud_3':
        "चरण 3: पैनल पर धूप डालने के लिए 'सूर्य' पर टैप करें या आकाश में ड्रैग करें।",
    's2_hud_4':
        "चरण 4: सूर्य को ढकने के लिए 'बादल' पर टैप करें और बिजली का रुकना देखें।",
    's2_hud_5': "चरण 5: बादल हटाएं और 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_c1': 'सौर पैनल की स्थापना',
    's2_a1': "सामग्री में 'सौर पैनल' पर टैप करें या छत पर ड्रैग करें।",
    's2_o1': 'सौर पैनल घर की छत पर मजबूती से लग जाता है।',
    's2_c2': 'विद्युत परिपथ पूरा करना',
    's2_a2': "सामग्री में 'तार जोड़ें' पर टैप करें।",
    's2_o2': 'एक तार सौर पैनल को सीधे बल्ब स्टैंड से जोड़ देता है।',
    's2_c3': 'सौर विद्युत उत्पादन',
    's2_a3': "सामग्री में 'सूर्य' पर टैप करें या आकाश में ड्रैग करें।",
    's2_o3':
        'धूप पैनल पर पड़ती है! नीले विद्युत कण तार से तेजी से बहते हैं और बल्ब तेज चमक उठता है!',
    's2_c4': 'मौसम का प्रभाव',
    's2_a4': "सामग्री में 'बादल' पर टैप करें।",
    's2_o4':
        'बादल के कारण धूप रुक जाती है। बिजली का प्रवाह तुरंत बंद हो जाता है और बल्ब बुझ जाता है।',
    's2_c5': 'स्वच्छ ऊर्जा की पुष्टि',
    's2_a5': 'बादल हटाएं और निष्कर्ष व सारांश देखें।',
    's2_o5':
        'धूप आते ही बिजली फिर से बनने लगती है! सौर ऊर्जा बिना प्रदूषण के बिजली देती है।',
    's2_summary':
        'सीधा सौर ऊर्जा रूपांतरण!|'
        '*फोटोवोल्टिक प्रभाव:* सौर पैनलों में सिलिकॉन सेल होते हैं जो धूप को सोखते हैं।|'
        '*विद्युत में परिवर्तन:* जब सूर्य की किरणें इन पर पड़ती हैं, तो विद्युत धारा उत्पन्न होती है जो तारों से बहती है।|'
        '*महत्व:* जीवाश्म ईंधन के विपरीत, सौर ऊर्जा स्वच्छ और अनंत है। यह प्रदूषण के बिना हमारे घरों को रोशन करती है!',
    'concept_exp': 'अवलोकन सूची',
    'action_req': 'आवश्यक क्रिया',
    'observation': 'वैज्ञानिक अवलोकन',
    'next_sc': 'अगला परिदृश्य देखें',
    'restart_lab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'all_complete': 'महारत हासिल की!',
    'success': 'सफलता!',
    'all_complete_desc':
        'आपने सीखा कि सूर्य पृथ्वी पर ऊर्जा का परम स्रोत है! आपने प्रकाश संश्लेषण के माध्यम से खाद्य श्रृंखला में ऊर्जा के प्रवाह को समझा, और देखा कि कैसे सौर तकनीक धूप को स्वच्छ बिजली में बदलती है!',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'inventory': 'सामग्री',
    'drag_hint': 'टैप करें या ड्रैग करके छोड़ें',
    'item_sun': 'सूर्य',
    'item_cow': 'गाय',
    'item_cloud': 'बादल',
    'item_panel': 'सौर पैनल',
    'item_wire': 'तार जोड़ें',
    'cloud_block': 'बादल लाएं',
    'cloud_clear': 'बादल हटाएं',
    'lbl_sun': 'सूर्य',
    'lbl_soil': 'मिट्टी',
    'lbl_grass': 'घास',
    'lbl_cow': 'गाय',
    'lbl_panel': 'सौर पैनल',
    'lbl_bulb': 'बिजली का बल्ब',
    // Added: Hindi for the HTML literal toasts.
    'toast_sun_first': 'कृपया चरण 1 का पालन करें: पहले सूर्य को रखें!',
    'toast_sun_placed': 'सूर्य पहले से ही आकाश में है!',
    'toast_grass_first': 'कृपया पहले चरण 2 में मिट्टी पर घास उगाएं!',
    'toast_cow_placed': 'गाय पहले से ही घास चर रही है!',
    'toast_add_first': 'पहले सूर्य, घास और गाय को जोड़ें!',
    'toast_panel_placed': 'सौर पैनल पहले से ही छत पर लगा है!',
    'toast_panel_first': 'पहले सौर पैनल को छत पर लगाएं!',
    'toast_wire_placed': 'तार पहले से ही जुड़ा हुआ है!',
    'toast_wire_first': 'पहले तार को बिजली के बल्ब से जोड़ें!',
    'toast_sun_shining': 'सूर्य पहले से ही चमक रहा है!',
    // Added.
    'scene_s1': 'आकाश के नीचे भूरी मिट्टी और पथरीले किनारे वाला एक तैरता द्वीप',
    'scene_s2':
        'आकाश के नीचे एक तैरता द्वीप, जिस पर लाल छत वाला सफ़ेद घर और स्टैंड पर लगा बिजली का बल्ब है',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 5;

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

/// Smallest touch target for the soil patch (logical px).
const double _minTouch = 48;

/// Longest step (s) the particles take in one frame, so a stalled frame
/// does not make them jump.
const double _maxFrameStep = 0.05;

/// The HTML animates its particles per frame at 60 frames per second.
const double _fps = 60;

/// Screens shorter than this (phones in landscape) get the compact
/// inventory and keep it clear of the HUD.
const double _compactBelow = 480;

// ------------------------------------------------------------------ cameras
// HTML `resetCamera()`: PerspectiveCamera(45°) at (0, 11.5, 31) in
// Scenario 1 and (0, 10.5, 28) in Scenario 2, `controls.target` (0, 3.5, 0).

const double _fovDegrees = 45;
const _V _eyeS1 = _V(0, 11.5, 31);
const _V _eyeS2 = _V(0, 10.5, 28);
const _V _lookAt = _V(0, 3.5, 0);

/// Zoom of the HTML camera and the stage point the look-at point is drawn
/// at, so the whole island and the Sun fit the stage and stay clear of the
/// inventory (right) and, with the sidebar collapsed, the floating mission
/// card (top left).
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
  _Frame(0.84, Offset(468, 292)),
  _Frame(0.78, Offset(468, 292)),
];
const List<_Frame> _framesClosed = [
  _Frame(0.72, Offset(605, 300)),
  _Frame(0.68, Offset(600, 300)),
];

/// The scene glides to the other framing in this time (s) when the sidebar
/// opens or closes.
const double _reframeSeconds = 0.38;

/// Canvas label text size (design px); enlarged up to [_labelMaxBoost]
/// when the stage is drawn smaller than [_labelFullScale].
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

// ----------------------------------------------------------------- lighting
// HTML `init3D()`: AmbientLight + DirectionalLight at (15, 35, 20);
// `setLightingDim()` 0.45 / 0.45 (colour 0x94a3b8), `setLightingBright()`
// 0.75 / 1.35 (colour 0xfffbeb, tweened over 800 ms).

/// Direction towards the directional light, normalised.
const _V _lightDir = _V(0.34874, 0.81373, 0.46499);
const double _ambientDim = 0.45, _ambientBright = 0.75;
const double _directDim = 0.45, _directBright = 1.35;
const double _lightSeconds = 0.8;

/// Diffuse share left by the metalness of the stand and panel materials
/// (Three.js darkens metals that have no environment map to reflect).
const double _metalDiffuse = 0.6;

// ---------------------------------------------------------- floating island
// HTML buildS1Scene() / buildS2Scene(): CylinderGeometry(14.5, 12, 3, 40)
// at y = −1.5, a CircleGeometry(14.4) top at y = 0.02.

const double _islandTopR = 14.5;
const double _islandBottomR = 12;
const double _islandDepth = 3;
const int _islandSides = 40;
const double _topR = 14.4;
const double _topY = 0.02;

/// 16 DodecahedronGeometry(1.1 + random × 0.5) rocks on a ring of 13.8 at
/// y = −0.3.
const int _rockCount = 16;
const double _rockRing = 13.8;
const double _rockY = -0.3;
const double _rockMinR = 1.1;
const double _rockSpanR = 0.5;
const int _rockCorners = 7;

// -------------------------------------------------------------------- grass
// 130 ConeGeometry(0.18, 1.4, 5) blades, pivot at the base, within a
// radius of 11.5, tilted by up to ±0.125 rad. Barren soil shows them at
// scale.y 0.08; a cloud wilts them to 0.25.

const int _bladeCount = 130;
const double _bladeR = 0.18;
const double _bladeH = 1.4;
const double _grassSpread = 11.5;
const double _bladeTilt = 0.25;
const double _stubScale = 0.08;

/// Strength of the grass's and the cow's emissive energy glow (the HTML's
/// full emissive washes them out to cyan in the 2D lighting).
const double _grassGlowStrength = 0.4;
const double _cowGlowStrength = 0.55;
const double _wiltScale = 0.25;
const double _grassSprout = 1.0; // grow, 1000 ms Bounce.Out
const double _grassSeconds = 0.9; // wilt / regrow, 900 ms

// ---------------------------------------------------------------------- sun
// buildHighFidelitySun() at (−8.5, 14, −6.5): core 2.8, coronas 3.3 and
// 3.8, twelve ConeGeometry(0.5, 2.5, 4) beams 4.2 from the centre that turn
// 0.01 rad per frame; the first corona pulses ±8 %.

const _V _sunAt = _V(-8.5, 14, -6.5);
const double _sunCoreR = 2.8;
const double _corona1R = 3.3;
const double _corona2R = 3.8;
const int _sunBeams = 12;
const double _beamAt = 4.2;
const double _beamLen = 2.5;
const double _beamR = 0.5;
const double _beamSpin = 0.01 * _fps;
const double _coronaPulse = 0.08;
const double _coronaRate = 2; // sin(time), time = Date.now() × 0.002

/// The Sun label, 4.5 above the Sun. (The HTML adds it to the Sun with the
/// Sun's own world position, which puts it far above the screen.)
const _V _sunLabelAt = _V(-8.5, 18.5, -6.5);

/// Scale-in of the Sun, the cow and the panel: 0.05 → 1, 900 ms Back.Out.
const double _popFrom = 0.05;
const double _popSeconds = 0.9;

// -------------------------------------------------------------------- cloud
// buildCloudMesh(): five white spheres. It drifts from (−18, 16, −4) to
// (−4.5, 13, −4) in 1100 ms (Quadratic.Out) and away to (22, 16, −4).

const List<(_V, double)> _puffs = [
  (_V(0, 0, 0), 2.0),
  (_V(-1.8, -0.3, 0.3), 1.6),
  (_V(1.8, -0.2, -0.2), 1.7),
  (_V(0.7, 0.9, 0.5), 1.4),
  (_V(-0.8, 0.8, -0.4), 1.3),
];
const _V _cloudStart = _V(-18, 16, -4);
const _V _cloudOver = _V(-4.5, 13, -4);
const _V _cloudAway = _V(22, 16, -4);
const double _cloudSeconds = 1.1;

// ---------------------------------------------------------------------- cow
// buildHighFidelityCow() at (2.8, 0.45, 1.8), turned −0.5 rad.

const _V _cowAt = _V(2.8, 0.45, 1.8);
const double _cowYaw = -0.5;
const _V _torsoAt = _V(0, 2.05, 0);
const _V _torsoSize = _V(3.6, 2.1, 1.9);

/// The two dark patches across the torso (x from … to, cow coordinates).
const List<(double, double)> _patches = [(-1.4, 0.2), (0.8, 1.6)];

/// Legs: CylinderGeometry(0.28, 0.25, 1.6) with 0.3 high hooves.
const List<(double, double)> _legSpots = [
  (-1.4, 0.6),
  (1.4, 0.6),
  (-1.4, -0.6),
  (1.4, -0.6),
];
const double _legTopR = 0.28;
const double _legBottomR = 0.25;
const double _legH = 1.6;
const double _hoofTopR = 0.26;
const double _hoofBottomR = 0.28;
const double _hoofH = 0.3;

/// The head group pivots at (1.8, 2.4, 0): head, snout, horns and ears.
const _V _neckAt = _V(1.8, 2.4, 0);
const _V _headAt = _V(0.8, 0.4, 0);
const _V _headSize = _V(1.5, 1.3, 1.3);
const _V _snoutAt = _V(1.5, 0.2, 0);
const _V _snoutSize = _V(0.9, 0.7, 1.1);
const _V _hornAt = _V(0.6, 1.2, 0.5);
const double _hornR = 0.12;
const double _hornH = 0.6;
const double _hornTilt = -0.3;
const _V _earAt = _V(0.4, 0.8, 0.8);
const _V _earSize = _V(0.6, 0.2, 0.4);

/// The tail group at (−1.8, 2.8, 0): a 1.6 long rod tilted 0.3 rad and a
/// brush at its tip.
const _V _tailAt = _V(-1.8, 2.8, 0);
const _V _tailRodAt = _V(-0.3, -0.7, 0);
const double _tailLen = 1.6;
const double _tailTilt = 0.3;
const double _tailTopR = 0.08;
const double _tailBottomR = 0.06;
const double _brushR = 0.2;
const _V _cowLabelAt = _V(0, 4.2, 0);

/// Grazing (HTML `sin(time × 2.5) × 0.15 + 0.1`, time in half seconds),
/// the droop under the cloud (0.35 rad, 800 ms) and the tail swish
/// (`sin(time × 4) × 0.3`). The head turns down here (see [_Scene]).
const double _grazeRate = 5;
const double _grazeAmp = 0.15;
const double _grazeBias = 0.1;
const double _droopAngle = 0.35;
const double _droopSeconds = 0.8;
const double _tailRate = 8;
const double _tailAmp = 0.3;

/// The Soil Patch / Grass label at (0, 2.8, 6.5).
const _V _soilLabelAt = _V(0, 2.8, 6.5);

/// The cow glows 1000 ms after it is placed (if no cloud came).
const Duration _cowGlowDelay = Duration(milliseconds: 1000);

// ------------------------------------------------------------------- house
// buildS2Scene(): walls BoxGeometry(6.5, 4.8, 6.5) at (−3, 2.4, 0), window
// band 2.2 × 1.8 × 6.6 at (−3, 2.6, 0), roof ConeGeometry(5.6, 2.8, 4)
// turned 45° at (−3, 6.2, 0).

const _V _wallsAt = _V(-3, 2.4, 0);
const _V _wallsSize = _V(6.5, 4.8, 6.5);
const _V _windowAt = _V(-3, 2.6, 0);
const _V _windowSize = _V(2.2, 1.8, 6.6);
const _V _roofApex = _V(-3, 7.6, 0);
const double _roofBaseY = 4.8;
const double _roofHalf = 3.9598; // 5.6 × cos 45°

/// Solar panel group at (−1.6, 6.3, 1.3), rotated (π/6, 0, −π/8): a
/// 4.2 × 0.25 × 2.8 frame and 5 × 3 cells of 0.72 × 0.27 × 0.92.
const _V _panelAt = _V(-1.6, 6.3, 1.3);
const double _panelTiltX = math.pi / 6;
const double _panelTiltZ = -math.pi / 8;
const _V _panelSize = _V(4.2, 0.25, 2.8);
const _V _cellSize = _V(0.72, 0.27, 0.92);
const List<double> _cellXs = [-1.6, -0.8, 0, 0.8, 1.6];
const List<double> _cellZs = [-1, 0, 1];
const _V _panelLabelAt = _V(0, 1.8, 0);

/// Bulb stand at (4.5, 0, 1.8): base CylinderGeometry(1.4, 1.6, 0.5), pole
/// (0.22, 3.2) centred at 1.85, socket (0.5, 0.4, 0.6) at 3.6, glass bulb
/// 0.95 at 4.5 with a TorusGeometry(0.3, 0.06) filament.
const _V _standAt = _V(4.5, 0, 1.8);
const double _baseTopR = 1.4;
const double _baseBottomR = 1.6;
const double _baseH = 0.5;
const double _poleR = 0.22;
const double _poleBottom = 0.25;
const double _poleH = 3.2;
const double _socketTopR = 0.5;
const double _socketBottomR = 0.4;
const double _socketBottom = 3.3;
const double _socketH = 0.6;
const double _bulbY = 4.5;
const double _bulbR = 0.95;
const double _filamentR = 0.3;
const double _filamentTube = 0.06;
const _V _bulbLabelAt = _V(4.5, 5.8, 1.8);

/// Bulb glow: coronas 1.25, 1.65, 2.1 and six ConeGeometry(0.4, 2.5, 4)
/// rays 1.2 from the centre turning 0.02 rad per frame; the whole glow
/// pulses ±8 % (`sin(time × 3.5)`).
const List<(double, Color)> _bulbCoronas = [
  (1.25, _Colors.bulbCorona1),
  (1.65, _Colors.bulbCorona2),
  (2.1, _Colors.bulbCorona3),
];
const int _bulbRays = 6;
const double _bulbRayAt = 1.2;
const double _bulbRayLen = 2.5;
const double _bulbRayR = 0.4;
const double _bulbRaySpin = 0.02 * _fps;
const double _bulbPulse = 0.08;
const double _bulbPulseRate = 7;

/// The point light: intensity 5 → 6.5 in 600 ms, lighting the lawn.
const double _bulbRampSeconds = 0.6;
const double _bulbPoolR = 9;

/// The bulb lights 400 ms after the Sun appears or the sky clears.
const Duration _bulbDelay = Duration(milliseconds: 400);

/// The wire: a CatmullRomCurve3 (centripetal) tube of radius 0.1 through
/// the panel, (1.2, 4, 2.2) and the stand; it scales in from the origin in
/// 700 ms.
const List<_V> _wireKnots = [
  _V(-1.6, 6.1, 1.3),
  _V(1.2, 4.0, 2.2),
  _V(4.5, 0.5, 1.8),
];
const double _wireR = 0.1;
const double _wireSeconds = 0.7;
const int _wireSamples = 64;

// ---------------------------------------------------------------- particles
// buildS1Particles() / buildS2Particles(): speeds are per frame at 60 fps.

/// 15 golden spheres (0.18) falling from the Sun at 0.08–0.13 per frame.
const int _solarCount = 15;
const double _solarR = 0.18;

/// 12 green spheres (0.15) rising from the grass into the cow.
const int _cowMoteCount = 12;
const double _cowMoteR = 0.15;

/// 18 blue spheres (0.18) along the wire, 0.008–0.012 of it per frame.
const int _sparkCount = 18;
const double _sparkR = 0.18;

// ------------------------------------------------------------------- popups

/// HTML `progressStep()`: the summary opens 600 ms after the last step.
const Duration _conclusionDelay = Duration(milliseconds: 600);

// ----------------------------------------------------------------- confetti
// canvas-confetti: start velocity 45, decay 0.9 per tick, gravity 3 px per
// tick, 200 ticks of 1/60 s. The summary fires 100 pieces (spread 80°,
// origin y 0.6); the mastery popup fires 6 + 6 pieces a frame for 3 s from
// both sides (angles 60° / 120°, spread 55°).

const double _confettiStart = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiTicks = 200;
const int _burstCount = 100;
const double _burstSpread = 80;
const double _burstOriginY = 0.6;
const int _cannonCount = 6;
const double _cannonSpread = 55;
const double _cannonSeconds = 3;

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

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// An object's world transform (Three.js `matrixWorld` without
/// perspective): a 3 × 3 rotation-and-scale matrix (rows `a b c`, `d e f`,
/// `g h i`) and a translation.
@immutable
class _Xf {
  const _Xf(
    this.a,
    this.b,
    this.c,
    this.d,
    this.e,
    this.f,
    this.g,
    this.h,
    this.i,
    this.t,
  );

  /// Position, Euler rotation (Three.js order 'XYZ': R = Rx · Ry · Rz) and
  /// uniform scale, as `object.position / rotation / scale`.
  factory _Xf.at(
    _V position, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
    double scale = 1,
  }) {
    final cx = math.cos(rx), sx = math.sin(rx);
    final cy = math.cos(ry), sy = math.sin(ry);
    final cz = math.cos(rz), sz = math.sin(rz);
    // Rx · Ry · Rz.
    return _Xf(
      cy * cz * scale,
      -cy * sz * scale,
      sy * scale,
      (sx * sy * cz + cx * sz) * scale,
      (-sx * sy * sz + cx * cz) * scale,
      -sx * cy * scale,
      (-cx * sy * cz + sx * sz) * scale,
      (cx * sy * sz + sx * cz) * scale,
      cx * cy * scale,
      position,
    );
  }

  static const _Xf identity = _Xf(1, 0, 0, 0, 1, 0, 0, 0, 1, _V.zero);

  final double a, b, c, d, e, f, g, h, i;
  final _V t;

  /// World position of the local point [v].
  _V apply(_V v) => _V(
    a * v.x + b * v.y + c * v.z + t.x,
    d * v.x + e * v.y + f * v.z + t.y,
    g * v.x + h * v.y + i * v.z + t.z,
  );

  /// World direction of the local direction [v] (not normalised).
  _V turn(_V v) => _V(
    a * v.x + b * v.y + c * v.z,
    d * v.x + e * v.y + f * v.z,
    g * v.x + h * v.y + i * v.z,
  );

  /// Uniform scale of the transform.
  double get scale => math.sqrt(a * a + d * d + g * g);

  /// This transform applied after [child] (a child object's world
  /// transform: `parent.matrixWorld × child.matrix`).
  _Xf operator *(_Xf child) => _Xf(
    a * child.a + b * child.d + c * child.g,
    a * child.b + b * child.e + c * child.h,
    a * child.c + b * child.f + c * child.i,
    d * child.a + e * child.d + f * child.g,
    d * child.b + e * child.e + f * child.h,
    d * child.c + e * child.f + f * child.i,
    g * child.a + h * child.d + i * child.g,
    g * child.b + h * child.e + i * child.h,
    g * child.c + h * child.f + i * child.i,
    apply(child.t),
  );
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45°) as a
/// pinhole projection onto the design stage, zoomed by [_Frame.zoom] with
/// the look-at point drawn at [_Frame.center].
@immutable
class _Cam {
  factory _Cam(_V eye, _Frame frame) {
    final f = (_lookAt - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, frame.center, _focal * frame.zoom, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.focal, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double _focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final double focal;

  /// Forward, right and up.
  final _V f;
  final _V r;
  final _V u;

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

  /// Faces with normal [n] at [at] turned towards the camera.
  bool facing(_V n, _V at) => n.dot(eye - at) > 0;
}

// ------------------------------------------------------------------ easing
// Tween.js easing functions used by the HTML.

typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// `TWEEN.Easing.Quadratic.Out`.
double _quadOut(double t) => t * (2 - t);

/// `TWEEN.Easing.Cubic.Out`.
double _cubicOut(double t) {
  final k = t - 1;
  return k * k * k + 1;
}

/// `TWEEN.Easing.Back.Out`.
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// `TWEEN.Easing.Bounce.Out`.
double _bounceOut(double t) {
  if (t < 1 / 2.75) return 7.5625 * t * t;
  if (t < 2 / 2.75) {
    final k = t - 1.5 / 2.75;
    return 7.5625 * k * k + 0.75;
  }
  if (t < 2.5 / 2.75) {
    final k = t - 2.25 / 2.75;
    return 7.5625 * k * k + 0.9375;
  }
  final k = t - 2.625 / 2.75;
  return 7.5625 * k * k + 0.984375;
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

  bool runningAt(double t) => seconds > 0 && t < start + seconds;

  /// A new tween from the value at [now] to [target] (`new TWEEN.Tween(o)
  /// .to(…)` starts from the current value).
  _Ramp toward(double target, double now, double secs, [_Ease e = _linear]) =>
      _Ramp(at(now), target, now, secs, e);
}

// ------------------------------------------------------------------- curve

/// THREE.CatmullRomCurve3 (centripetal) through [_wireKnots], sampled once
/// with its arc length so points can be taken by distance (`getPointAt`).
class _Wire {
  _Wire() {
    for (var k = 0; k <= _wireSamples; k++) {
      final p = _point(k / _wireSamples);
      if (k > 0) _total += (p - points.last).length;
      points.add(p);
      _lengths.add(_total);
    }
  }

  /// Points along the curve from the panel to the stand.
  final List<_V> points = [];
  final List<double> _lengths = [];
  double _total = 0;

  /// The point a fraction [u] of the way along the curve.
  _V pointAt(double u) {
    final target = u.clamp(0.0, 1.0) * _total;
    var lo = 0, hi = _lengths.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      if (_lengths[mid] < target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final span = _lengths[hi] - _lengths[lo];
    final k = span <= 0 ? 0.0 : (target - _lengths[lo]) / span;
    return _V.lerp(points[lo], points[hi], k);
  }

  /// `CatmullRomCurve3.getPoint(t)`, open curve: the end tangents use
  /// mirrored knots.
  static _V _point(double t) {
    const pts = _wireKnots;
    final l = pts.length;
    final p = (l - 1) * t;
    var seg = p.floor();
    var w = p - seg;
    if (seg >= l - 1) {
      seg = l - 2;
      w = 1;
    }
    final p1 = pts[seg];
    final p2 = pts[seg + 1];
    final p0 = seg > 0 ? pts[seg - 1] : pts[0] * 2 - pts[1];
    final p3 = seg + 2 < l ? pts[seg + 2] : pts[l - 1] * 2 - pts[l - 2];
    double dt(_V a, _V b) => math.pow((b - a).dot(b - a), 0.25).toDouble();
    var dt0 = dt(p0, p1);
    var dt1 = dt(p1, p2);
    var dt2 = dt(p2, p3);
    if (dt1 < 1e-4) dt1 = 1;
    if (dt0 < 1e-4) dt0 = dt1;
    if (dt2 < 1e-4) dt2 = dt1;
    double axis(double x0, double x1, double x2, double x3) {
      var t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1;
      var t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2;
      t1 *= dt1;
      t2 *= dt1;
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
}

/// The wire curve, built once.
final _Wire _wire = _Wire();

// -------------------------------------------------------------- scene model

/// The inventory items of both scenarios (HTML `#inv-s1` / `#inv-s2`).
enum _Item {
  sun('item_sun', Icons.wb_sunny),
  cow('item_cow', null),
  cloud('item_cloud', Icons.cloud),
  panel('item_panel', Icons.solar_power),
  wire('item_wire', Icons.electrical_services),
  sun2('item_sun', Icons.wb_sunny),
  cloud2('item_cloud', Icons.cloud);

  const _Item(this.labelKey, this.icon);

  /// HTML `item_*` text (the drag ghost; the cloud tile says 'Cover Sky' /
  /// 'Clear Sky').
  final String labelKey;

  /// Material icon for the Phosphor one; `null` draws the cow face.
  final IconData? icon;

  bool get isSun => this == sun || this == sun2;
  bool get isCloud => this == cloud || this == cloud2;

  static const List<_Item> s1 = [sun, cow, cloud];
  static const List<_Item> s2 = [panel, wire, sun2, cloud2];
}

/// One energy particle (a small sphere moved every frame). An electric
/// pulse keeps its place along the wire (HTML `userData.t`, 0 … 1) in [x].
class _Mote {
  _Mote(this.x, this.y, this.z, this.speed);

  double x;
  double y;
  double z;

  /// HTML `userData.speed`, world units (or curve fraction) per frame.
  final double speed;

  _V get pos => _V(x, y, z);
}

/// One grass blade: its base on the soil and the unit direction of its
/// axis (the blade's random tilt).
@immutable
class _Blade {
  const _Blade(this.base, this.axis);

  final _V base;
  final _V axis;
}

/// One rim rock: angle on the ring, radius and its outline jitter.
@immutable
class _Rock {
  const _Rock(this.at, this.radius, this.spin, this.jitter);

  final _V at;
  final double radius;
  final double spin;
  final List<double> jitter;
}

/// The grass blades and rim rocks, laid out once (the HTML uses
/// `Math.random()`; a fixed seed keeps the island the same every time).
final List<_Blade> _blades = () {
  final rnd = math.Random(7);
  return [
    for (var k = 0; k < _bladeCount; k++)
      () {
        final a = rnd.nextDouble() * 2 * math.pi;
        final r = rnd.nextDouble() * _grassSpread;
        final rx = (rnd.nextDouble() - 0.5) * _bladeTilt;
        final ry = rnd.nextDouble() * 2 * math.pi;
        final rz = (rnd.nextDouble() - 0.5) * _bladeTilt;
        final axis = _Xf.at(_V.zero, rx: rx, ry: ry, rz: rz).turn(_V.up);
        return _Blade(_V(math.cos(a) * r, _topY, math.sin(a) * r), axis);
      }(),
  ];
}();

final List<_Rock> _rocks = () {
  final rnd = math.Random(3);
  return [
    for (var k = 0; k < _rockCount; k++)
      () {
        final a = k / _rockCount * 2 * math.pi;
        return _Rock(
          _V(math.cos(a) * _rockRing, _rockY, math.sin(a) * _rockRing),
          _rockMinR + rnd.nextDouble() * _rockSpanR,
          rnd.nextDouble() * math.pi,
          [for (var j = 0; j < _rockCorners; j++) 0.8 + rnd.nextDouble() * 0.2],
        );
      }(),
  ];
}();

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
  Size size = const Size(1000, 560);

  /// The mastery side cannons fire until this time (s).
  double cannonsUntil = -1;
  double _ticks = 0;

  bool get isActive => pieces.isNotEmpty || cannonsUntil > 0;

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

  /// The summary's burst (100 pieces upwards from 60 % down the canvas).
  void burst() =>
      fire(_burstCount, 90, _burstSpread, const Offset(0.5, _burstOriginY));

  /// Starts the mastery popup's 3 s of side cannons.
  void cannons(double now) => cannonsUntil = now + _cannonSeconds;

  /// Advances the pieces by [dt] seconds (60 ticks a second).
  void update(double dt, double now) {
    if (!isActive) return;
    _ticks += dt * _fps;
    while (_ticks >= 1) {
      _ticks -= 1;
      if (cannonsUntil > 0) {
        if (now < cannonsUntil) {
          fire(_cannonCount, 60, _cannonSpread, const Offset(0, 0.5));
          fire(_cannonCount, 120, _cannonSpread, const Offset(1, 0.5));
        } else {
          cannonsUntil = -1;
        }
      }
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
    cannonsUntil = -1;
  }
}

/// Mutable scene read by the painter every frame (HTML `State` plus the
/// Three.js objects' animated values). Every tween is a [_Ramp] read at
/// [time].
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based); one past the last step once the last
  /// step is done.
  int step = 1;

  // ---------------------------------------------- HTML State.s1 / State.s2
  bool sunUp = false;
  bool cloudUp = false;
  bool hasGrass = false;
  bool hasCow = false;
  bool hasPanel = false;
  bool hasWire = false;

  /// Emissive energy glow of the grass (0x10b981) and of the cow (0x34d399).
  bool grassGlow = false;
  bool cowGlow = false;

  /// HTML `turnBulbOn()` / `turnBulbOff()`.
  bool bulbOn = false;

  // --------------------------------------------------------------- tweens
  _Ramp sunScale = const _Ramp.still(0);
  _Ramp cowScale = const _Ramp.still(0);
  _Ramp panelScale = const _Ramp.still(0);
  _Ramp wireScale = const _Ramp.still(0);
  _Ramp grass = const _Ramp.still(_stubScale);

  /// 0 dim … 1 bright lighting (and sky).
  _Ramp light = const _Ramp.still(0);

  /// 0 grazing … 1 head drooped under the cloud.
  _Ramp droop = const _Ramp.still(0);

  /// Point light 0 (off), 5 → 6.5 when lit, as 0 … 1.
  _Ramp bulbPower = const _Ramp.still(0);

  /// 0 sidebar open … 1 sidebar collapsed (kept across scenarios).
  _Ramp frame = const _Ramp.still(0);

  // ---------------------------------------------------------------- cloud
  _V _cloudFrom = _cloudStart;
  _V _cloudTo = _cloudStart;
  double _cloudAt = 0;
  _Ease _cloudEase = _linear;
  bool _cloudLeaving = false;

  /// Time the tail stopped swishing (the cloud came).
  double _tailStoppedAt = 0;

  // ------------------------------------------------------------ particles
  final List<_Mote> solar = [];
  final List<_Mote> cowMotes = [];
  final List<_Mote> sparks = [];
  final math.Random _rnd = math.Random(11);

  final _Confetti confetti = _Confetti();

  bool get done => step > _stepCount;

  /// The camera of the current scenario for the sidebar state.
  _Cam get cam => _Cam(
    scenario == 0 ? _eyeS1 : _eyeS2,
    _Frame.lerp(_framesOpen[scenario], _framesClosed[scenario], frame.at(time)),
  );

  /// Lighting at this moment.
  _Lighting get lighting => _Lighting(light.at(time));

  /// The cloud's position and whether it is drawn (HTML `cloudMesh.visible`
  /// stays on until it has drifted away).
  _V get cloudPos {
    final k = ((time - _cloudAt) / _cloudSeconds).clamp(0.0, 1.0);
    return _V.lerp(_cloudFrom, _cloudTo, _cloudEase(k));
  }

  bool get cloudShown =>
      cloudUp || (_cloudLeaving && time < _cloudAt + _cloudSeconds);

  /// Head turn of the cow: grazing (HTML `animate()`), blended into the
  /// droop under the cloud. Negative turns the head down (the HTML's
  /// positive angles lifted it).
  double get headAngle {
    final graze = hasCow && hasGrass
        ? math.sin(time * _grazeRate) * _grazeAmp + _grazeBias
        : 0.0;
    final d = droop.at(time);
    return -(graze * (1 - d) + _droopAngle * d);
  }

  /// Tail swish (`sin(time × 4) × 0.3`); it stops while the cloud is up.
  double get tailAngle =>
      math.sin((cloudUp ? _tailStoppedAt : time) * _tailRate) * _tailAmp;

  /// Golden particles fall while the Sun shines (Scenario 1).
  bool get solarFlow => scenario == 0 && sunUp && !cloudUp;

  /// Green particles rise into the cow while it grazes.
  bool get cowFlow => scenario == 0 && hasCow && hasGrass && !cloudUp;

  /// Electric pulses run while the circuit is lit (Scenario 2).
  bool get sparkFlow =>
      scenario == 1 && hasPanel && hasWire && sunUp && !cloudUp;

  /// HTML `changeScenario()` / `resetScenarioState()`.
  void load(int index) {
    scenario = index;
    step = 1;
    sunUp = false;
    cloudUp = false;
    hasGrass = false;
    hasCow = false;
    hasPanel = false;
    hasWire = false;
    grassGlow = false;
    cowGlow = false;
    bulbOn = false;
    sunScale = const _Ramp.still(0);
    cowScale = const _Ramp.still(0);
    panelScale = const _Ramp.still(0);
    wireScale = const _Ramp.still(0);
    grass = const _Ramp.still(_stubScale);
    light = const _Ramp.still(0);
    droop = const _Ramp.still(0);
    bulbPower = const _Ramp.still(0);
    _cloudFrom = _cloudStart;
    _cloudTo = _cloudStart;
    _cloudLeaving = false;
    _tailStoppedAt = 0;
    final r = _rnd;
    solar
      ..clear()
      ..addAll([
        for (var k = 0; k < _solarCount; k++)
          _Mote(
            _sunAt.x + r.nextDouble() * 2,
            13 - r.nextDouble() * 12,
            _sunAt.z + r.nextDouble() * 6,
            0.08 + r.nextDouble() * 0.05,
          ),
      ]);
    cowMotes
      ..clear()
      ..addAll([
        for (var k = 0; k < _cowMoteCount; k++)
          _Mote(
            r.nextDouble() * 4 - 2,
            0.5 + r.nextDouble() * 1.5,
            r.nextDouble() * 4 - 2,
            0.05 + r.nextDouble() * 0.03,
          ),
      ]);
    sparks
      ..clear()
      ..addAll([
        for (var k = 0; k < _sparkCount; k++)
          _Mote(k / _sparkCount, 0, 0, 0.008 + r.nextDouble() * 0.004),
      ]);
  }

  /// HTML: the cloud drifts in from the left (1100 ms Quadratic.Out).
  void cloudIn() {
    _cloudFrom = _cloudStart;
    _cloudTo = _cloudOver;
    _cloudAt = time;
    _cloudEase = _quadOut;
    _cloudLeaving = false;
    _tailStoppedAt = time;
  }

  /// HTML: the cloud drifts away to the right (1100 ms) and hides.
  void cloudOut() {
    _cloudFrom = cloudPos;
    _cloudTo = _cloudAway;
    _cloudAt = time;
    _cloudEase = _linear;
    _cloudLeaving = true;
  }

  /// HTML `animate()`: the particle systems, [dt] seconds on.
  void tick(double dt) {
    final frames = dt * _fps;
    final r = _rnd;
    if (solarFlow) {
      for (final p in solar) {
        p.y -= p.speed * frames;
        if (p.y < 0.2) {
          p
            ..x = _sunAt.x + (r.nextDouble() - 0.5) * 3
            ..y = 13
            ..z = _sunAt.z + (r.nextDouble() - 0.5) * 3;
        }
      }
    }
    if (cowFlow) {
      final pull = 1 - math.pow(0.95, frames).toDouble();
      for (final p in cowMotes) {
        p
          ..y += p.speed * frames
          ..x += (_cowAt.x - p.x) * pull
          ..z += (_cowAt.z - p.z) * pull;
        if (p.y > 2.5) {
          p
            ..x = (r.nextDouble() - 0.5) * 6
            ..y = 0.3
            ..z = (r.nextDouble() - 0.5) * 6;
        }
      }
    }
    if (sparkFlow) {
      for (final p in sparks) {
        // HTML `p.userData.t = (t + speed) % 1`.
        p.x = (p.x + p.speed * frames) % 1;
      }
    }
  }
}

/// The scene lighting between the HTML's dim and bright set-ups:
/// ambient white plus the directional light's Lambert term.
@immutable
class _Lighting {
  _Lighting(this.level)
    : ambient = _ambientDim + (_ambientBright - _ambientDim) * level,
      direct = _directDim + (_directBright - _directDim) * level,
      tint = Color.lerp(_Colors.lightDim, _Colors.lightBright, level)!;

  /// 0 dim … 1 bright.
  final double level;
  final double ambient;
  final double direct;
  final Color tint;

  /// MeshStandardMaterial look of [c] on a face with normal [n], plus an
  /// [emissive] colour (scaled by [glow]). The light is added in linear
  /// colour and shown in sRGB, so the bright set-up (up to 2.1 times the
  /// material colour) brightens colours instead of turning them neon.
  Color lit(
    Color c,
    _V n, {
    Color? emissive,
    double glow = 1,
    double opacity = 1,
  }) {
    final k = math.max(0.0, n.dot(_lightDir)) * direct;
    double ch(double base, double light, double? add) => _srgb(
      _linear(base) * (ambient + k * _linear(light)) +
          (add == null ? 0 : _linear(add) * glow),
    );
    return Color.from(
      alpha: c.a * opacity,
      red: ch(c.r, tint.r, emissive?.r),
      green: ch(c.g, tint.g, emissive?.g),
      blue: ch(c.b, tint.b, emissive?.b),
    );
  }

  static double _linear(double c) => math.pow(c, 2.2).toDouble();

  static double _srgb(double c) =>
      math.pow(c.clamp(0.0, 1.0), 1 / 2.2).toDouble();

  /// Sky colour (`scene.background`) for the theme.
  Color sky(bool isDark) => isDark
      ? Color.lerp(_Colors.skyDimDark, _Colors.skyBrightDark, level)!
      : Color.lerp(_Colors.skyDimLight, _Colors.skyBrightLight, level)!;
}

/// An inventory item being dragged (HTML `#drag-ghost`) and where it is
/// drawn, in canvas coordinates.
@immutable
class _Ghost {
  const _Ghost(this.item, this.at);

  final _Item item;
  final Offset at;
}

class _SunEnergyLabState
    extends State<Ch11A3EnergyFromTheSunItsImportanceAndUsesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final ValueNotifier<_Ghost?> _ghost = ValueNotifier(null);
  final _TextCache _texts = _TextCache();

  /// The full-canvas overlay layer (drop area and confetti size) and the
  /// inventory panel (drops back on it are cancelled).
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _inventoryKey = GlobalKey();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout.
  double _fit = 1;

  /// The sidebar state the scene is framed for.
  bool _framedOpen = true;

  /// The inventory item under the finger (HTML `draggedItem`), the
  /// scenario it belongs to and the finger's last global position.
  _Item? _dragItem;
  int _dragScenario = -1;
  Offset _dragGlobal = Offset.zero;

  /// Last refusal toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
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

  /// HTML `animate()`: TWEEN.update() (the ramps read the scene time), the
  /// particle systems and the confetti, then a repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s
      ..time = now
      ..tick(dt);
    s.confetti.update(dt, now);
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

  /// HTML `showToast(msg)` for a refused item; the refusal tone plays.
  void _refuse(String key) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: true);
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

  /// HTML `changeScenario(id)`: resets the scenario's objects, the step,
  /// the lighting, the inventory and the camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _cancelDrag();
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  /// HTML `resetApp()`: Scenario 1 from scratch (the shell restores the
  /// language, theme, sidebar and curtain).
  void _reset() {
    _scene.confetti.clear();
    _loadScenario(0);
  }

  /// HTML `setLightingBright()`: the lights rise over 800 ms.
  void _brighten() {
    final s = _scene;
    s.light = s.light.toward(1, s.time, _lightSeconds);
  }

  /// HTML `setLightingDim()`: the lights drop at once.
  void _dim() => _scene.light = const _Ramp.still(0);

  /// Scale-in of a placed object (0.05 → 1, 900 ms Back.Out).
  _Ramp _popIn() => _Ramp(_popFrom, 1, _scene.time, _popSeconds, _backOut);

  /// HTML `progressStep()`: the next step; after the last one the summary
  /// opens 600 ms later. (The HTML capped the step at 5 and opened the
  /// summary on reaching step 5 and again on finishing it.)
  void _progressStep() {
    final s = _scene;
    _Sound.pop.play();
    final finishing = s.step >= _stepCount;
    s.step = math.min(s.step + 1, _stepCount + 1);
    if (finishing) _lab.after(_conclusionDelay, _triggerConclusion);
  }

  /// HTML `jumpToStep(id)`: a step card makes that step the current one.
  void _jumpToStep(int id) {
    _Sound.click.play();
    setState(() => _scene.step = id);
  }

  /// Whether [item] is greyed out (HTML class `used`): placed already, or
  /// not yet unlocked by the step before.
  bool _dimmed(_Item item) {
    final s = _scene;
    return switch (item) {
      _Item.sun => s.sunUp,
      _Item.cow => !(s.hasGrass && !s.hasCow),
      _Item.cloud => !s.hasCow,
      _Item.panel => s.hasPanel,
      _Item.wire => !(s.hasPanel && !s.hasWire),
      _Item.sun2 => !(s.hasWire && !s.sunUp),
      _Item.cloud2 => !s.sunUp,
    };
  }

  /// HTML `glow-pulse`: the item the current step needs (the cloud keeps
  /// its glow once unlocked).
  bool _glows(_Item item) => !_dimmed(item);

  /// A tap on an item. A greyed-out item only explains itself with the
  /// HTML's own refusal toast (the HTML ignored clicks on it).
  void _tapItem(_Item item) {
    if (!_lab.isLabActive) return;
    if (!_dimmed(item)) {
      _useItem(item);
      return;
    }
    final s = _scene;
    final key = switch (item) {
      _Item.sun => 'toast_sun_placed',
      _Item.cow => s.hasCow ? 'toast_cow_placed' : 'toast_grass_first',
      _Item.cloud => 'toast_add_first',
      _Item.panel => 'toast_panel_placed',
      _Item.wire => s.hasWire ? 'toast_wire_placed' : 'toast_panel_first',
      _Item.sun2 => s.sunUp ? 'toast_sun_shining' : 'toast_wire_first',
      _Item.cloud2 => null,
    };
    if (key != null) _refuse(key);
  }

  /// HTML `useInventoryItem(item)`.
  void _useItem(_Item item) {
    if (!_lab.isLabActive) return;
    final inS1 = _Item.s1.contains(item);
    if (inS1 != (_scene.scenario == 0)) return;
    switch (item) {
      case _Item.sun:
        _placeSun();
      case _Item.cow:
        _placeCow();
      case _Item.cloud:
        _toggleFoodCloud();
      case _Item.panel:
        _placePanel();
      case _Item.wire:
        _connectWire();
      case _Item.sun2:
        _placeSolarSun();
      case _Item.cloud2:
        _togglePowerCloud();
    }
  }

  // ------------------------------------------------------- scenario 1 steps

  /// 'Sun': the Sun scales in, the scene brightens (step 1).
  void _placeSun() {
    final s = _scene;
    if (s.step != 1 && !s.sunUp) {
      _refuse('toast_sun_first');
      return;
    }
    if (s.sunUp) {
      _refuse('toast_sun_placed');
      return;
    }
    _Sound.click.play();
    s
      ..sunUp = true
      ..sunScale = _popIn();
    _brighten();
    _Sound.success.play();
    if (s.step == 1) _progressStep();
    _refresh();
  }

  /// HTML `onCanvasClick()`: a tap on the island at step 2 sprouts the
  /// grass (1000 ms Bounce.Out) and gives it its energy glow.
  void _onStageTap(Offset at) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step != 2 || s.hasGrass) return;
    if (!_islandHit(at)) return;
    _sproutGrass();
  }

  void _sproutGrass() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return;
    if (s.step != 2 || s.hasGrass) return;
    s
      ..hasGrass = true
      ..grass = _Ramp(s.grass.at(s.time), 1, s.time, _grassSprout, _bounceOut)
      ..grassGlow = true;
    _Sound.success.play();
    _progressStep();
    _refresh();
  }

  /// 'Cow': the cow scales in onto the grass and glows a second later
  /// (step 3).
  void _placeCow() {
    final s = _scene;
    if (s.step != 3 || !s.hasGrass) {
      _refuse('toast_grass_first');
      return;
    }
    if (s.hasCow) {
      _refuse('toast_cow_placed');
      return;
    }
    _Sound.click.play();
    s
      ..hasCow = true
      ..cowScale = _popIn();
    _Sound.success.play();
    _lab.after(_cowGlowDelay, () {
      if (s.cloudUp) return;
      s.cowGlow = true;
      _refresh();
    });
    if (s.step == 3) _progressStep();
    _refresh();
  }

  /// 'Cloud' / 'Cover Sky' / 'Clear Sky' (steps 4 and 5): the cloud dims
  /// the scene, wilts the grass and makes the cow droop; clearing it brings
  /// them back.
  void _toggleFoodCloud() {
    final s = _scene;
    if (!s.hasCow && !s.hasGrass) {
      _refuse('toast_add_first');
      return;
    }
    _Sound.click.play();
    s.cloudUp = !s.cloudUp;
    _Sound.cloud.play();
    final t = s.time;
    if (s.cloudUp) {
      s
        ..cloudIn()
        ..grass = s.grass.toward(_wiltScale, t, _grassSeconds)
        ..grassGlow = false
        ..cowGlow = false
        ..droop = s.droop.toward(1, t, _droopSeconds);
      _dim();
      if (s.step == 4) _progressStep();
    } else {
      s
        ..cloudOut()
        ..grass = s.grass.toward(1, t, _grassSeconds)
        ..grassGlow = true
        ..cowGlow = true
        ..droop = s.droop.toward(0, t, _droopSeconds);
      _brighten();
      if (s.step == 5) _progressStep();
    }
    _refresh();
  }

  // ------------------------------------------------------- scenario 2 steps

  /// 'Solar Panel': the panel scales in on the roof (step 1).
  void _placePanel() {
    final s = _scene;
    if (s.step != 1 && !s.hasPanel) return;
    if (s.hasPanel) {
      _refuse('toast_panel_placed');
      return;
    }
    _Sound.click.play();
    s
      ..hasPanel = true
      ..panelScale = _popIn();
    _Sound.success.play();
    if (s.step == 1) _progressStep();
    _refresh();
  }

  /// 'Connect Wire': the wire grows into place (700 ms, step 2).
  void _connectWire() {
    final s = _scene;
    if (!s.hasPanel) {
      _refuse('toast_panel_first');
      return;
    }
    if (s.hasWire) {
      _refuse('toast_wire_placed');
      return;
    }
    _Sound.click.play();
    s
      ..hasWire = true
      ..wireScale = _Ramp(_popFrom, 1, s.time, _wireSeconds);
    _Sound.electric.play();
    if (s.step == 2) _progressStep();
    _refresh();
  }

  /// 'Sun': the Sun scales in and the bulb lights 400 ms later (step 3).
  void _placeSolarSun() {
    final s = _scene;
    if (!s.hasWire) {
      _refuse('toast_wire_first');
      return;
    }
    if (s.sunUp) {
      _refuse('toast_sun_shining');
      return;
    }
    _Sound.click.play();
    s
      ..sunUp = true
      ..sunScale = _popIn();
    _brighten();
    _Sound.success.play();
    _lab.after(_bulbDelay, () {
      if (!s.cloudUp) _turnBulbOn();
    });
    if (s.step == 3) _progressStep();
    _refresh();
  }

  /// 'Cloud' (steps 4 and 5): the cloud stops the current and the bulb goes
  /// dark; clearing it lights the bulb again 400 ms later.
  void _togglePowerCloud() {
    final s = _scene;
    if (!s.sunUp) return;
    _Sound.click.play();
    s.cloudUp = !s.cloudUp;
    _Sound.cloud.play();
    if (s.cloudUp) {
      s.cloudIn();
      _dim();
      _turnBulbOff();
      if (s.step == 4) _progressStep();
    } else {
      s.cloudOut();
      _brighten();
      _lab.after(_bulbDelay, () {
        if (!s.cloudUp) _turnBulbOn();
      });
      if (s.step == 5) _progressStep();
    }
    _refresh();
  }

  /// HTML `turnBulbOn()`: the glass lights, its glow appears and the point
  /// light rises from 5 to 6.5 (600 ms).
  void _turnBulbOn() {
    final s = _scene;
    s
      ..bulbOn = true
      ..bulbPower = _Ramp(5 / 6.5, 1, s.time, _bulbRampSeconds);
    _Sound.electric.play();
    _refresh();
  }

  /// HTML `turnBulbOff()`.
  void _turnBulbOff() {
    _scene
      ..bulbOn = false
      ..bulbPower = const _Ramp.still(0);
  }

  // ---------------------------------------------------------------- popups

  /// HTML `triggerConclusion()`: the scenario's summary with confetti.
  void _triggerConclusion() {
    if (!mounted) return;
    final s = _scene;
    final sc = s.scenario;
    _lab.completedScenarios.add(sc);
    s.confetti
      ..size = _canvasSize
      ..burst();
    _lab.showPopup(() => _summaryPopup(sc));
    _refresh();
  }

  /// HTML `#summary-modal`: "Lab Complete!", the scenario title and its
  /// summary. Its button runs HTML `handleScenarioNext()`.
  LabPopupContent _summaryPopup(int sc) {
    final allDone = _lab.completedScenarios.length >= _scenarioCount;
    return LabPopupContent(
      title: _t('success'),
      icon: Icons.check_circle,
      accent: _Colors.amber500,
      extra: Builder(
        builder: (context) => _SummaryCard(
          title: _t('scen_${sc + 1}_title'),
          summary: _t('s${sc + 1}_summary'),
          palette: _lab.palette,
          scale: context.labScale,
          fontScale: _lab.fontScale,
        ),
      ),
      actions: [
        LabAction(
          label: allDone ? _lab.t('btn_continue') : _t('next_sc'),
          icon: allDone ? Icons.emoji_events : Icons.arrow_forward,
          color: _Colors.amber500,
          foreground: _Colors.slate950,
          silent: true,
          onTap: _handleScenarioNext,
        ),
      ],
    );
  }

  /// HTML `handleScenarioNext()`: the other scenario, or the mastery popup
  /// once both are done.
  void _handleScenarioNext() {
    if (_lab.completedScenarios.length >= _scenarioCount) {
      _showSuccess();
      return;
    }
    _Sound.scenario.play();
    _loadScenario(_scene.scenario == 0 ? 1 : 0);
  }

  /// HTML `showSuccess()`: "Mastery Achieved!" with 3 s of side cannons and
  /// 'Restart Entire Lab'.
  void _showSuccess() {
    final s = _scene;
    s.confetti
      ..size = _canvasSize
      ..cannons(s.time);
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('success'),
        icon: Icons.stars,
        accent: _Colors.emerald500,
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
            color: _Colors.emerald500,
            foreground: _Colors.slate950,
            onTap: _lab.requestFullReset,
          ),
        ],
      ),
    );
  }

  /// The HTML's hidden 'Observe Conclusion & Summary' button, offered once
  /// the scenario is done to open the summary again.
  LabAction _concludeAction({bool highlight = false}) => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.lightbulb,
    color: _Colors.amber500,
    foreground: _Colors.slate950,
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

  /// [global] in canvas coordinates, or null before layout.
  Offset? _canvasLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  /// HTML `startDrag()`: the ghost appears under the finger.
  void _dragStart(_Item item, DragStartDetails d) {
    if (!_lab.isLabActive || _dimmed(item)) return;
    _dragItem = item;
    _dragScenario = _scene.scenario;
    _dragGlobal = d.globalPosition;
    final at = _canvasLocal(d.globalPosition);
    if (at != null) _ghost.value = _Ghost(item, at);
  }

  /// HTML `onDragMove()`.
  void _dragUpdate(DragUpdateDetails d) {
    final item = _dragItem;
    if (item == null) return;
    _dragGlobal = d.globalPosition;
    final at = _canvasLocal(d.globalPosition);
    if (at != null) _ghost.value = _Ghost(item, at);
  }

  /// HTML `onDragEnd()`: dropped anywhere on the scene, the item is used
  /// (a drop back on the inventory or off the canvas does nothing).
  void _dragEnd() {
    final item = _dragItem;
    _cancelDrag();
    if (item == null || _dragScenario != _scene.scenario) return;
    if (_dropsOnScene(_dragGlobal)) _useItem(item);
  }

  void _cancelDrag() {
    _dragItem = null;
    _ghost.value = null;
  }

  bool _dropsOnScene(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return false;
    if (!(Offset.zero & box.size).contains(box.globalToLocal(global))) {
      return false;
    }
    final panel = _inventoryKey.currentContext?.findRenderObject();
    if (panel is RenderBox && panel.hasSize) {
      final rect = MatrixUtils.transformRect(
        panel.getTransformTo(null),
        Offset.zero & panel.size,
      );
      if (rect.contains(global)) return false;
    }
    return true;
  }

  /// The island under a stage point (HTML raycast against the Scenario 1
  /// group).
  bool _islandHit(Offset at) {
    final hull = _islandOutline(_scene.cam);
    return _insideConvex(hull, at);
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
        final n = scene.scenario + 1;
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
          // HTML `updateHUD()`: `hud[step] || hud[last]`.
          hud: _t('s${n}_hud_${scene.step.clamp(1, _stepCount)}'),
          actions: [if (scene.done) _concludeAction()],
          onReset: _reset,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepChecklist(
            steps: data.steps,
            current: scene.step,
            palette: p,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _lab.t('step'),
            actionLabel: _t('action_req'),
            observationLabel: _t('observation'),
            onJump: _jumpToStep,
          ),
          overlays: _overlays(context, p, s),
          stage: _buildStage(p),
        );
      },
    );
  }

  /// Canvas cards: the inventory (right), 'Observe Conclusion & Summary'
  /// once the scenario is done, the confetti and the drag ghost.
  List<Widget> _overlays(BuildContext context, LabPalette p, double s) {
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final compact = MediaQuery.sizeOf(context).height < _compactBelow;
    final scene = _scene;
    final items = scene.scenario == 0 ? _Item.s1 : _Item.s2;
    // On phones the inventory keeps clear of the HUD at the bottom.
    final hudRoom = _lab.isSidebarOpen ? (compact ? 64 : 76) * s : 0.0;
    return [
      Positioned(
        key: const ValueKey('ch11a3-inventory'),
        right: inset.right,
        top: inset.top + (compact ? 4 : 48) * s,
        bottom: inset.bottom + (compact ? hudRoom : 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: _InventoryPanel(
              key: _inventoryKey,
              title: _t('inventory'),
              hint: _t('drag_hint'),
              palette: p,
              scale: s,
              clock: _frame,
              tiles: [
                for (final item in items)
                  _TileData(
                    item: item,
                    label: item.isCloud
                        ? _t(scene.cloudUp ? 'cloud_clear' : 'cloud_block')
                        : _t(item.labelKey),
                    dimmed: _dimmed(item),
                    glow: _glows(item),
                    onTap: () => _tapItem(item),
                    onDragStart: (d) => _dragStart(item, d),
                    onDragUpdate: _dragUpdate,
                    onDragEnd: _dragEnd,
                  ),
              ],
            ),
          ),
        ),
      ),
      // The summary again, on the canvas (above the HUD) so it is in reach
      // on phones too.
      if (scene.done && _lab.popup == null)
        Positioned(
          key: const ValueKey('ch11a3-conclude'),
          bottom: inset.bottom + (_lab.isSidebarOpen ? hudRoom : 0),
          left: inset.left,
          right: inset.right + (compact ? 96 : 120) * s,
          // Scales down while the sidebar slides (the canvas is still
          // narrow when the mission card's room is already kept free).
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LabActionButton(
                action: _concludeAction(highlight: true),
                scale: s,
                expand: false,
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
            child: ValueListenableBuilder<_Ghost?>(
              valueListenable: _ghost,
              builder: (context, ghost, _) {
                if (ghost == null) return const SizedBox.shrink();
                return Stack(
                  children: [
                    Positioned(
                      left: ghost.at.dx,
                      top: ghost.at.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: _DragGhost(
                          item: ghost.item,
                          label: _t(ghost.item.labelKey),
                          scale: s,
                          clock: _frame,
                        ),
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The soil patch has its own node ([_targets]).
            excludeFromSemantics: true,
            onTapUp: (d) => _onStageTap(d.localPosition),
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
                        isDark: p.isDark,
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

  /// Screen-reader node over the soil patch (Scenario 1), where it is
  /// drawn. It takes no touches itself: taps reach the scene below.
  Widget _targets() {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0) return const SizedBox.shrink();
    var rect = _islandTopRect(s.cam);
    final min = _minTouch / _fit;
    if (rect.height < min) {
      rect = Rect.fromCenter(
        center: rect.center,
        width: rect.width,
        height: min,
      );
    }
    return Stack(
      children: [
        Positioned.fromRect(
          rect: rect,
          child: Semantics(
            key: const ValueKey('ch11a3-soil'),
            container: true,
            button: s.step == 2 && !s.hasGrass,
            label: _t(s.hasGrass ? 'lbl_grass' : 'lbl_soil'),
            onTap: _sproutGrass,
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

/// Outline of the floating island on the stage: the convex hull of its top
/// rim and its bottom rim.
List<Offset> _islandOutline(_Cam cam) {
  final pts = <Offset>[];
  for (var k = 0; k < _islandSides; k++) {
    final a = k / _islandSides * 2 * math.pi;
    final c = math.cos(a), s = math.sin(a);
    pts
      ..add(cam.p(_V(c * _islandTopR, 0, s * _islandTopR)))
      ..add(cam.p(_V(c * _islandBottomR, -_islandDepth, s * _islandBottomR)));
  }
  return _hull(pts);
}

/// Bounds of the island's top (the soil patch) on the stage.
Rect _islandTopRect(_Cam cam) {
  var rect = Rect.zero;
  for (var k = 0; k < _islandSides; k++) {
    final a = k / _islandSides * 2 * math.pi;
    final p = cam.p(_V(math.cos(a) * _topR, _topY, math.sin(a) * _topR));
    rect = k == 0
        ? Rect.fromLTWH(p.dx, p.dy, 0, 0)
        : rect.expandToInclude(Rect.fromLTWH(p.dx, p.dy, 0, 0));
  }
  return rect;
}

/// Convex hull (monotone chain), counter-clockwise on screen.
List<Offset> _hull(List<Offset> points) {
  final pts = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  if (pts.length < 3) return pts;
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
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

/// Whether [p] lies inside the convex polygon [poly] (either winding).
bool _insideConvex(List<Offset> poly, Offset p) {
  if (poly.length < 3) return false;
  var sign = 0;
  for (var k = 0; k < poly.length; k++) {
    final a = poly[k];
    final b = poly[(k + 1) % poly.length];
    final c = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
    final s = c > 0 ? 1 : (c < 0 ? -1 : 0);
    if (s == 0) continue;
    if (sign == 0) {
      sign = s;
    } else if (s != sign) {
      return false;
    }
  }
  return true;
}

// ----------------------------------------------------------------- inventory

/// One inventory tile: the item, its text and state, and its gestures.
@immutable
class _TileData {
  const _TileData({
    required this.item,
    required this.label,
    required this.dimmed,
    required this.glow,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final _Item item;
  final String label;
  final bool dimmed;
  final bool glow;
  final VoidCallback onTap;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;
}

/// Colours of an inventory tile (HTML `bg-*-100/90 dark:bg-*-500/10`,
/// `border-*-600/70 dark:border-*-500/40`, text and icon).
@immutable
class _Tone {
  const _Tone(this.fill, this.border, this.text, this.icon);

  final Color fill;
  final Color border;
  final Color text;
  final Color icon;

  static _Tone of(_Item item, bool dark) => switch (item) {
    _Item.sun || _Item.sun2 =>
      dark
          ? const _Tone(
              Color(0x1AF59E0B),
              Color(0x66F59E0B),
              _Colors.amber400,
              _Colors.amber400,
            )
          : const _Tone(
              Color(0xE6FEF3C7),
              Color(0xB3F59E0B),
              _Colors.slate900,
              _Colors.amber600,
            ),
    _Item.cow =>
      dark
          ? const _Tone(
              Color(0x1A10B981),
              Color(0x6610B981),
              _Colors.emerald400,
              _Colors.emerald400,
            )
          : const _Tone(
              Color(0xE6D1FAE5),
              Color(0xB3059669),
              _Colors.slate900,
              _Colors.emerald700,
            ),
    _Item.cloud || _Item.cloud2 =>
      dark
          ? const _Tone(
              Color(0x1A64748B),
              Color(0x6664748B),
              _Colors.slate300,
              _Colors.slate300,
            )
          : const _Tone(
              Color(0xE6E2E8F0),
              Color(0xB364748B),
              _Colors.slate900,
              _Colors.slate700,
            ),
    _Item.panel =>
      dark
          ? const _Tone(
              Color(0x1A3B82F6),
              Color(0x663B82F6),
              _Colors.blue400,
              _Colors.blue400,
            )
          : const _Tone(
              Color(0xE6DBEAFE),
              Color(0xB32563EB),
              _Colors.slate900,
              _Colors.blue600,
            ),
    _Item.wire =>
      dark
          ? const _Tone(
              Color(0x1A6366F1),
              Color(0x666366F1),
              _Colors.indigo400,
              _Colors.indigo400,
            )
          : const _Tone(
              Color(0xE6E0E7FF),
              Color(0xB34F46E5),
              _Colors.slate900,
              _Colors.indigo600,
            ),
  };
}

/// The inventory panel (`bg-white dark:bg-slate-900/95`).
Color _panelColor(bool dark) =>
    dark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF);

/// CSS `grayscale(0.65)` for greyed-out tiles.
const ColorFilter _grayscale = ColorFilter.matrix([
  0.48819, 0.46488, 0.04693, 0, 0, //
  0.13819, 0.81488, 0.04693, 0, 0, //
  0.13819, 0.46488, 0.39693, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// HTML `#inventory-panel`: "Inventory", the hint and the scenario's items.
class _InventoryPanel extends StatelessWidget {
  const _InventoryPanel({
    super.key,
    required this.title,
    required this.hint,
    required this.tiles,
    required this.palette,
    required this.scale,
    required this.clock,
  });

  final String title;
  final String hint;
  final List<_TileData> tiles;
  final LabPalette palette;
  final double scale;

  /// Scene time, for the spinning Sun and the glow pulse.
  final ValueListenable<double> clock;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final amber = p.isDark ? _Colors.amber400 : _Colors.amber600;
    return Container(
      width: 88 * s,
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: _panelColor(p.isDark),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0x66F59E0B)),
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.backpack, size: 12 * s, color: amber),
                SizedBox(width: 3 * s),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    color: amber,
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w900,
                    letterSpacing: labLetterSpacing(title, 0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.isDark ? _Colors.slate400 : _Colors.slate700,
              fontSize: 9 * s,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6 * s),
          Container(
            height: 1,
            color: p.isDark ? _Colors.slate700 : _Colors.slate300,
          ),
          for (final tile in tiles) ...[
            SizedBox(height: 8 * s),
            _InventoryTile(data: tile, palette: p, scale: s, clock: clock),
          ],
        ],
      ),
    );
  }
}

/// HTML `.inv-item`: icon and name; greyed out when used or locked, a
/// pulsing amber glow when it is the next item to use. Tap it, or drag it
/// onto the scene.
class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.data,
    required this.palette,
    required this.scale,
    required this.clock,
  });

  final _TileData data;
  final LabPalette palette;
  final double scale;
  final ValueListenable<double> clock;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final s = scale;
    final tone = _Tone.of(d.item, palette.isDark);
    final radius = BorderRadius.circular(12 * s);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ItemIcon(item: d.item, color: tone.icon, size: 24 * s, clock: clock),
        SizedBox(height: 2 * s),
        Text(
          d.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: tone.text,
            fontSize: 10 * s,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
      ],
    );
    // [pulse] 0 … 1 of the HTML `pulseGlow` (2 s ease-in-out): the amber
    // border brightens and the glow grows from 15 px to 28 px.
    Widget box(double pulse, Widget child) => Container(
      width: 64 * s,
      padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        // Opaque over the panel, so the glow does not show through.
        color: Color.alphaBlend(tone.fill, _panelColor(palette.isDark)),
        borderRadius: radius,
        border: Border.all(
          color: d.glow
              ? _Colors.yellow500.withValues(alpha: 0.8 + 0.2 * pulse)
              : tone.border,
          width: 2,
        ),
        boxShadow: d.glow
            ? [
                BoxShadow(
                  color: _Colors.yellow500.withValues(alpha: 0.5 + 0.4 * pulse),
                  blurRadius: (15 + 13 * pulse) * s * 0.6,
                  spreadRadius: (1 + 2 * pulse) * s,
                ),
              ]
            : null,
      ),
      child: child,
    );
    Widget tile = d.glow
        ? ValueListenableBuilder<double>(
            valueListenable: clock,
            builder: (context, t, child) =>
                box(0.5 - 0.5 * math.cos(t * math.pi), child!),
            child: content,
          )
        : box(0, content);
    if (d.dimmed) {
      tile = Opacity(
        opacity: 0.55,
        child: ColorFiltered(colorFilter: _grayscale, child: tile),
      );
    }
    return Semantics(
      button: true,
      enabled: !d.dimmed,
      label: d.label,
      excludeSemantics: true,
      onTap: d.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: d.onTap,
        onPanStart: d.dimmed ? null : d.onDragStart,
        onPanUpdate: d.dimmed ? null : d.onDragUpdate,
        onPanEnd: d.dimmed ? null : (_) => d.onDragEnd(),
        onPanCancel: d.dimmed ? null : d.onDragEnd,
        child: tile,
      ),
    );
  }
}

/// An item's icon (the Phosphor icons of the HTML); the Sun turns once in
/// 12 s (`animate-spin`).
class _ItemIcon extends StatelessWidget {
  const _ItemIcon({
    required this.item,
    required this.color,
    required this.size,
    required this.clock,
  });

  final _Item item;
  final Color color;
  final double size;
  final ValueListenable<double> clock;

  @override
  Widget build(BuildContext context) {
    final icon = item.icon;
    final Widget glyph = icon == null
        ? CustomPaint(size: Size.square(size), painter: _CowIconPainter(color))
        : Icon(icon, size: size, color: color);
    if (!item.isSun) return glyph;
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, t, child) =>
          Transform.rotate(angle: t / 12 * 2 * math.pi, child: child),
      child: glyph,
    );
  }
}

/// HTML `#drag-ghost`: an amber chip with the item's icon and name under
/// the finger (`scale(1.15)`).
class _DragGhost extends StatelessWidget {
  const _DragGhost({
    required this.item,
    required this.label,
    required this.scale,
    required this.clock,
  });

  final _Item item;
  final String label;
  final double scale;
  final ValueListenable<double> clock;

  @override
  Widget build(BuildContext context) {
    final s = scale * 1.15;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: _Colors.ghost,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: _Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 24),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ItemIcon(
            item: item,
            color: _Colors.slate950,
            size: 26 * s,
            clock: clock,
          ),
          SizedBox(width: 8 * s),
          Text(
            label,
            style: TextStyle(
              color: _Colors.slate950,
              fontSize: 13 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Phosphor `ph-cow` face (horns, ears, head and muzzle), painted.
class _CowIconPainter extends CustomPainter {
  const _CowIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..color = color;
    final hole = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(Offset.zero & size, Paint());
    final horn = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawPath(
        Path()
          ..moveTo(w * 0.32, h * 0.3)
          ..quadraticBezierTo(w * 0.2, h * 0.1, w * 0.07, h * 0.12),
        horn,
      )
      ..drawPath(
        Path()
          ..moveTo(w * 0.68, h * 0.3)
          ..quadraticBezierTo(w * 0.8, h * 0.1, w * 0.93, h * 0.12),
        horn,
      );
    for (final x in const [0.13, 0.87]) {
      canvas
        ..save()
        ..translate(w * x, h * 0.4)
        ..rotate(x < 0.5 ? 0.35 : -0.35)
        ..drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: w * 0.26,
            height: h * 0.15,
          ),
          fill,
        )
        ..restore();
    }
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.24, h * 0.22, w * 0.76, h * 0.72),
          Radius.circular(w * 0.18),
        ),
        fill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.2, h * 0.6, w * 0.8, h * 0.95),
          Radius.circular(w * 0.18),
        ),
        fill,
      )
      // Eyes, nostrils and the line above the muzzle.
      ..drawCircle(Offset(w * 0.38, h * 0.43), w * 0.055, hole)
      ..drawCircle(Offset(w * 0.62, h * 0.43), w * 0.055, hole)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.37, h * 0.78),
          width: w * 0.11,
          height: h * 0.08,
        ),
        hole,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.63, h * 0.78),
          width: w * 0.11,
          height: h * 0.08,
        ),
        hole,
      )
      ..drawLine(
        Offset(w * 0.27, h * 0.6),
        Offset(w * 0.73, h * 0.6),
        Paint()
          ..blendMode = BlendMode.clear
          ..strokeWidth = w * 0.045,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _CowIconPainter old) => old.color != color;
}

// ------------------------------------------------------------------ sidebar

/// HTML `#teacher-content` "Observation Checklist": a card per step with
/// its concept, the action required and the scientific observation. The
/// current step is amber, done steps are green with a tick; a tap makes
/// that step the current one (HTML `jumpToStep`).
class _StepChecklist extends StatelessWidget {
  const _StepChecklist({
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.actionLabel,
    required this.observationLabel,
    required this.onJump,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String actionLabel;
  final String observationLabel;
  final ValueChanged<int> onJump;

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
    final step = steps[i - 1];
    final Color fill, border, badge, badgeText, body;
    if (now) {
      fill = dark ? _Colors.slate800 : _Colors.white;
      border = _Colors.amber500;
      badge = _Colors.amber500;
      badgeText = _Colors.slate950;
      body = p.textStrong;
    } else if (done) {
      fill = dark ? const Color(0x4D022C22) : const Color(0xB3ECFDF5);
      border = const Color(0x8010B981);
      badge = _Colors.emerald500;
      badgeText = _Colors.slate950;
      body = dark ? _Colors.slate300 : _Colors.slate600;
    } else {
      fill = dark ? const Color(0x991E293B) : _Colors.slate100;
      border = dark ? const Color(0xCC334155) : _Colors.slate200;
      badge = dark ? _Colors.slate700 : _Colors.slate200;
      badgeText = dark ? _Colors.slate300 : _Colors.slate600;
      body = dark ? _Colors.slate400 : _Colors.slate600;
    }
    final radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: now
            ? const [
                BoxShadow(color: Color(0x33F59E0B), spreadRadius: 2),
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: now || done ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onJump(i),
          child: Padding(
            padding: EdgeInsets.all(12 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 3 * s,
                      ),
                      decoration: BoxDecoration(
                        color: badge,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$stepLabel $i'.toUpperCase(),
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 9.5 * f,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(stepLabel, 0.8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (done)
                      Icon(
                        Icons.check_circle,
                        size: 18 * s,
                        color: _Colors.emerald500,
                      ),
                  ],
                ),
                SizedBox(height: 6 * s),
                Text(
                  step.concept,
                  style: TextStyle(
                    color: p.textStrong,
                    fontSize: 12 * f,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$actionLabel: ',
                        style: TextStyle(
                          color: dark ? _Colors.indigo400 : _Colors.indigo600,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: step.action),
                    ],
                  ),
                  style: TextStyle(
                    color: body,
                    fontSize: 11.5 * f,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 8 * s),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(9 * s),
                  decoration: BoxDecoration(
                    color: const Color(0x26F59E0B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x4DF59E0B)),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$observationLabel: ',
                          style: TextStyle(
                            color: dark ? _Colors.white : _Colors.slate950,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(text: step.observation),
                      ],
                    ),
                    style: TextStyle(
                      color: dark ? _Colors.amber200 : _Colors.slate900,
                      fontSize: 11.5 * f,
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
    );
  }
}

// ------------------------------------------------------------------- popups

/// HTML `#summary-modal` body: the lightbulb badge, the scenario title and
/// the summary (bold heading and bullet list, see the STRINGS markup).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.summary,
    required this.palette,
    required this.scale,
    required this.fontScale,
  });

  final String title;
  final String summary;
  final LabPalette palette;
  final double scale;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final f = s * fontScale.clamp(0.9, 1.4);
    final parts = summary.split('|');
    final amber = p.isDark ? _Colors.amber400 : _Colors.amber600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 52 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              color: const Color(0x33F59E0B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x66F59E0B), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x4DF59E0B), blurRadius: 20),
              ],
            ),
            child: Icon(Icons.lightbulb, size: 28 * s, color: _Colors.amber500),
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 16 * f,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0x991E293B) : _Colors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.isDark ? const Color(0xCC334155) : _Colors.slate200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                parts.first,
                style: TextStyle(
                  color: amber,
                  fontSize: 14 * f,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              for (final bullet in parts.skip(1)) ...[
                SizedBox(height: 7 * s),
                _bullet(bullet, p, f),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// `<li><b>Lead:</b> text</li>` from `*Lead:* text`.
  Widget _bullet(String text, LabPalette p, double f) {
    var lead = '';
    var rest = text;
    if (text.startsWith('*')) {
      final end = text.indexOf('*', 1);
      if (end > 0) {
        lead = text.substring(1, end);
        rest = text.substring(end + 1).trimLeft();
      }
    }
    final style = TextStyle(
      color: p.isDark ? _Colors.slate200 : _Colors.slate800,
      fontSize: 12.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•  ', style: style.copyWith(fontWeight: FontWeight.w900)),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (lead.isNotEmpty)
                  TextSpan(
                    text: '$lead ',
                    style: TextStyle(
                      color: p.textStrong,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                TextSpan(text: rest),
              ],
            ),
            style: style,
          ),
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
            width: 58 * s,
            height: 58 * s,
            decoration: BoxDecoration(
              color: const Color(0x33EAB308),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x66EAB308), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x66EAB308), blurRadius: 25),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              size: 30 * s,
              color: p.isDark ? _Colors.amber300 : _Colors.yellow500,
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textStrong,
            fontSize: 19 * f,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0x991E293B) : _Colors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.isDark ? _Colors.slate700 : _Colors.slate200,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.isDark ? _Colors.slate300 : _Colors.slate700,
              fontSize: 12.5 * f,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
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
  static const int _limit = 48;

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

/// One drawable of a depth-sorted pass: its camera depth and how to paint
/// it (painter's algorithm in place of the WebGL depth buffer).
typedef _Drawable = (double depth, VoidCallback paint);

/// A scene label sprite: where it is drawn and its text.
typedef _Label = (Offset at, String text);

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

/// A stripe of a box along its x axis (from [x0] to [x1], box coordinates)
/// in its own colour: the cow's dark patches.
typedef _Stripe = (double x0, double x1, Color color);

/// Mesh drawing in one camera's projection under the scene lighting.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.light);

  final Canvas canvas;
  final _Cam cam;
  final _Lighting light;

  final Paint _fill = Paint();
  final Paint _seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..strokeJoin = StrokeJoin.round;
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Path _path = Path();

  /// Where the key light's highlight sits on a sphere, in radii from its
  /// centre on screen.
  Offset get _highlight =>
      Offset(_lightDir.dot(cam.r), -_lightDir.dot(cam.u)) * 0.42;

  /// Fills the polygon through [pts] with [color], with a same-colour
  /// hairline that hides anti-aliasing seams between neighbouring faces.
  void fill(List<Offset> pts, Color color, {bool seam = true}) {
    final path = _path..reset();
    for (var k = 0; k < pts.length; k++) {
      if (k == 0) {
        path.moveTo(pts[k].dx, pts[k].dy);
      } else {
        path.lineTo(pts[k].dx, pts[k].dy);
      }
    }
    path.close();
    canvas.drawPath(path, _fill..color = color);
    if (seam) canvas.drawPath(path, _seam..color = color);
  }

  /// A BoxGeometry centred at [center] in [xf]'s space: the faces turned
  /// to the camera, lit. [stripes] split the faces along x into coloured
  /// bands; [only] keeps the faces whose local normal it accepts.
  void box(
    _Xf xf,
    _V center,
    _V size,
    Color color, {
    Color? emissive,
    double glow = 1,
    List<_Stripe>? stripes,
    bool Function(_V normal)? only,
    double opacity = 1,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      if (only != null && !only(n)) continue;
      final normal = xf.turn(n).unit;
      final mid = xf.apply(center + _V(n.x * hx, n.y * hy, n.z * hz));
      if (!cam.facing(normal, mid)) continue;
      Offset corner(_V k, double x) =>
          cam.p(xf.apply(center + _V(x, k.y * hy, k.z * hz)));
      if (stripes == null || n.x != 0) {
        fill(
          [for (final k in face.corners) corner(k, k.x * hx)],
          light.lit(
            color,
            normal,
            emissive: emissive,
            glow: glow,
            opacity: opacity,
          ),
        );
        continue;
      }
      for (final (x0, x1, c) in stripes) {
        fill([
          for (final k in face.corners) corner(k, k.x < 0 ? x0 : x1),
        ], light.lit(c, normal, emissive: emissive, glow: glow));
      }
    }
  }

  /// Horizontal direction at [a] radians.
  static _V _dir(double a) => _V(math.cos(a), 0, math.sin(a));

  /// An upright CylinderGeometry: radius [rBottom] at [base], [rTop] at
  /// the top, [h] high. The facets turned to the camera are lit one by one
  /// and the top is closed when it faces the camera.
  void cylinder(
    _V base,
    double rBottom,
    double rTop,
    double h,
    Color color, {
    Color? emissive,
    double glow = 1,
    int sides = 20,
    bool cap = true,
  }) {
    if (h <= 0) return;
    final top = base + _V.up * h;
    final slope = (rBottom - rTop) / h;
    for (var k = 0; k < sides; k++) {
      final a0 = k * 2 * math.pi / sides;
      final a1 = (k + 1) * 2 * math.pi / sides;
      final m = _dir((a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((rBottom + rTop) / 2);
      if (!cam.facing(n, mid)) continue;
      final d0 = _dir(a0), d1 = _dir(a1);
      fill([
        cam.p(base + d0 * rBottom),
        cam.p(base + d1 * rBottom),
        cam.p(top + d1 * rTop),
        cam.p(top + d0 * rTop),
      ], light.lit(color, n, emissive: emissive, glow: glow));
    }
    if (cap && cam.facing(_V.up, top)) {
      disc(top, rTop, light.lit(color, _V.up, emissive: emissive, glow: glow));
    }
  }

  /// A flat horizontal disc of radius [r] centred at [c], already lit.
  void disc(_V c, double r, Color color, {int sides = _islandSides}) {
    fill([
      for (var k = 0; k < sides; k++)
        cam.p(c + _dir(k * 2 * math.pi / sides) * r),
    ], color);
  }

  /// A lit SphereGeometry (MeshStandardMaterial): a disc with the key
  /// light's highlight towards the upper right.
  void ball(
    _V c,
    double r,
    Color color, {
    Color? emissive,
    double glow = 1,
    double opacity = 1,
  }) {
    final o = cam.p(c);
    final radius = r * cam.scaleAt(c);
    if (radius < 0.3) return;
    final hi = light.lit(
      color,
      _lightDir,
      emissive: emissive,
      glow: glow,
      opacity: opacity,
    );
    final mid = light.lit(
      color,
      -cam.f,
      emissive: emissive,
      glow: glow,
      opacity: opacity,
    );
    final lo = light.lit(
      color,
      (-cam.f - _lightDir).unit,
      emissive: emissive,
      glow: glow,
      opacity: opacity,
    );
    canvas.drawCircle(
      o,
      radius,
      _fill
        ..shader = ui.Gradient.radial(
          o + _highlight * radius,
          radius * 1.35,
          [hi, mid, lo],
          const [0, 0.5, 1],
        ),
    );
    _fill.shader = null;
  }

  /// An unlit (MeshBasicMaterial) sphere of screen radius [radius].
  void flat(Offset at, double radius, Color color) {
    if (radius < 0.3) return;
    canvas.drawCircle(at, radius, _fill..color = color);
  }

  /// An energy particle: a small unlit sphere with a soft glow.
  void mote(_V c, double r, Color color) {
    final o = cam.p(c);
    final radius = math.max(1.2, r * cam.scaleAt(c));
    labGlow(canvas, o, radius * 3.5, color, intensity: 0.8);
    flat(o, radius, color);
  }

  /// A thin cylinder from [a] (radius [ra]) to [b] (radius [rb]): a
  /// tapered band, lit, with a highlight on the lit side.
  void rod(
    _V a,
    _V b,
    double ra,
    double rb,
    Color color, {
    Color? emissive,
    double glow = 1,
  }) {
    final pa = cam.p(a), pb = cam.p(b);
    final wa = math.max(0.5, ra * cam.scaleAt(a));
    final wb = math.max(0.3, rb * cam.scaleAt(b));
    final c = light.lit(color, -cam.f, emissive: emissive, glow: glow);
    final dir = pb - pa;
    final len = dir.distance;
    if (len < 0.01) {
      flat(pa, wa, c);
      return;
    }
    final n = Offset(-dir.dy, dir.dx) / len;
    fill([pa + n * wa, pb + n * wb, pb - n * wb, pa - n * wa], c);
    flat(pa, wa, c);
    final side = n.dx * _highlight.dx + n.dy * _highlight.dy > 0 ? 1.0 : -1.0;
    canvas.drawLine(
      pa + n * (wa * 0.4 * side),
      pb + n * (wb * 0.4 * side),
      _line
        ..strokeWidth = math.max(0.6, (wa + wb) * 0.3)
        ..color = labShade(c, 0.35).withValues(alpha: 0.6),
    );
  }

  /// A 4-sided ConeGeometry lying in the vertical x-y plane through [c]
  /// (the Sun's beams, the bulb's rays): its axis at [angle] from +x, its
  /// middle [at] from [c], [len] long and [r] wide at the base.
  void beam(_V c, double angle, double at, double len, double r, Color color) {
    final axis = _V(math.cos(angle), math.sin(angle), 0);
    final across = _V(-math.sin(angle), math.cos(angle), 0);
    final base = c + axis * (at - len / 2);
    final tip = c + axis * (at + len / 2);
    fill(
      [cam.p(base + across * r), cam.p(tip), cam.p(base - across * r)],
      color,
      seam: false,
    );
  }

  /// A horizontal TorusGeometry (the filament): a ring of radius [r] drawn
  /// [tube] thick.
  void ring(_V c, double r, double tube, Color color) {
    final path = _path..reset();
    const sides = 24;
    for (var k = 0; k <= sides; k++) {
      final p = cam.p(c + _dir(k * 2 * math.pi / sides) * r);
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      _line
        ..strokeWidth = math.max(0.8, 2 * tube * cam.scaleAt(c))
        ..color = color,
    );
  }

  /// A soft pool of light on the ground around [c] (a point light).
  void pool(_V c, double r, Color color, double strength) {
    if (strength <= 0) return;
    final o = cam.p(c);
    final rx = (cam.p(c + _V(r, 0, 0)) - o).distance;
    final ry = (cam.p(c + _V(0, 0, r)) - o).distance;
    if (rx < 1) return;
    canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(1, ry / rx)
      ..drawCircle(
        Offset.zero,
        rx,
        _fill
          ..shader = ui.Gradient.radial(
            Offset.zero,
            rx,
            [
              color.withValues(alpha: 0.5 * strength),
              color.withValues(alpha: 0.18 * strength),
              color.withValues(alpha: 0),
            ],
            const [0, 0.45, 1],
          ),
      )
      ..restore();
    _fill.shader = null;
  }
}

/// Paints the HTML Three.js scene of the current scenario.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  /// Label text size in design px.
  final double labelSize;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final light = s.lighting;
    // HTML `scene.background`, over the letterbox too.
    canvas.drawRect(labBleed(size), Paint()..color = light.sky(isDark));
    final g = _Gfx(canvas, s.cam, light);
    final labels = <_Label>[];
    if (s.scenario == 0) {
      _paintFoodChain(g, labels);
    } else {
      _paintSolarHome(g, labels);
    }
    if (!showLabels) return;
    for (final (at, text) in labels) {
      _label(canvas, at, text);
    }
  }

  // ------------------------------------------------------------- shared

  /// buildHighFidelitySun(): the core, the two coronas (the first pulses)
  /// and the twelve turning beams, scaled by its pop-in.
  void _paintSun(_Gfx g, List<_Label> labels) {
    final s = scene;
    final k = s.sunScale.at(s.time);
    if (!s.sunUp || k <= 0.001) return;
    final t = s.time;
    final o = g.cam.p(_sunAt);
    final px = g.cam.scaleAt(_sunAt) * k;
    labGlow(
      g.canvas,
      o,
      _corona2R * 2.1 * px,
      _Colors.sunHalo,
      intensity: 0.25 + 0.3 * s.lighting.level,
    );
    g.flat(o, _sunCoreR * px, _Colors.sunCore);
    final pulse = 1 + math.sin(t * _coronaRate) * _coronaPulse;
    g
      ..flat(o, _corona1R * pulse * px, _Colors.sunCorona1)
      ..flat(o, _corona2R * px, _Colors.sunCorona2);
    final spin = t * _beamSpin;
    for (var i = 0; i < _sunBeams; i++) {
      g.beam(
        _sunAt,
        i / _sunBeams * 2 * math.pi + spin,
        _beamAt * k,
        _beamLen * k,
        _beamR * k,
        _Colors.sunBeam,
      );
    }
    labels.add((g.cam.p(_sunLabelAt), _t('lbl_sun')));
  }

  /// buildCloudMesh(): five white puffs, the far ones first.
  void _paintCloud(_Gfx g) {
    final s = scene;
    if (!s.cloudShown) return;
    final at = s.cloudPos;
    final puffs = [for (final (o, r) in _puffs) (at + o, r)]
      ..sort((a, b) => g.cam.depth(b.$1).compareTo(g.cam.depth(a.$1)));
    for (final (c, r) in puffs) {
      g.ball(c, r, _Colors.cloud);
    }
  }

  /// The plateau: its side (CylinderGeometry 14.5 / 12, 3 high) and top
  /// rim; the scenario paints the top surface.
  void _paintPlateau(_Gfx g, Color color) {
    g.cylinder(
      const _V(0, -_islandDepth, 0),
      _islandBottomR,
      _islandTopR,
      _islandDepth,
      color,
      sides: _islandSides,
    );
  }

  /// A scene label sprite (HTML `createTextSprite`): a dark rounded chip
  /// with white bold text, centred on [at].
  void _label(Canvas canvas, Offset at, String text) {
    final tp = texts.get(text, labelSize);
    final padX = labelSize * 0.75, padY = labelSize * 0.3;
    final rect = Rect.fromCenter(
      center: at,
      width: tp.width + 2 * padX,
      height: tp.height + 2 * padY,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas
      ..drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = const Color(0x40000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawRRect(rr, Paint()..color = _Colors.labelBg)
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _Colors.labelBorder,
      );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  // --------------------------------------------------------- scenario 1

  /// buildS1Scene(): the Sun and the cloud in the sky, the plateau with
  /// its rocky rim and soil, the grass, the cow and the energy particles.
  void _paintFoodChain(_Gfx g, List<_Label> labels) {
    final s = scene;
    final cam = g.cam;
    final light = g.light;
    _paintSun(g, labels);
    _paintCloud(g);
    _paintPlateau(g, _Colors.plateau);
    // Rocks on the far rim sink behind the soil's edge; the near ones sit
    // in front of the grass.
    final far = <_Rock>[], near = <_Rock>[];
    for (final rock in _rocks) {
      (rock.at.z < 0 ? far : near).add(rock);
    }
    far.sort((a, b) => cam.depth(b.at).compareTo(cam.depth(a.at)));
    for (final rock in far) {
      _paintRock(g, rock);
    }
    g.disc(const _V(0, _topY, 0), _topR, light.lit(_Colors.soil, _V.up));

    final items = <_Drawable>[];
    // Grass blades: two lit halves of a cone (the cone's side normals turn
    // from sideways to upwards as a squashed blade gets flatter).
    final height = s.grass.at(s.time) * _bladeH;
    _V side(_V toward) {
      final flat = _V(toward.x, 0, toward.z).unit;
      return (flat * height + _V.up * _bladeR).unit;
    }

    final glow = s.grassGlow ? _Colors.grassGlow : null;
    final left = light.lit(
      _Colors.grass,
      side(-cam.r - cam.f),
      emissive: glow,
      glow: _grassGlowStrength,
    );
    final right = light.lit(
      _Colors.grass,
      side(cam.r - cam.f),
      emissive: glow,
      glow: _grassGlowStrength,
    );
    for (final blade in _blades) {
      items.add((
        cam.depth(blade.base),
        () => _paintBlade(g, blade, height, left, right),
      ));
    }
    for (final rock in near) {
      items.add((cam.depth(rock.at), () => _paintRock(g, rock)));
    }
    if (s.hasCow && s.cowScale.at(s.time) > 0.001) {
      items.add((
        cam.depth(_cowAt + const _V(0, 1.5, 0)),
        () => _paintCow(g, labels),
      ));
    }
    if (s.solarFlow) {
      for (final p in s.solar) {
        items.add((
          cam.depth(p.pos),
          () => g.mote(p.pos, _solarR, _Colors.solarMote),
        ));
      }
    }
    if (s.cowFlow) {
      for (final p in s.cowMotes) {
        items.add((
          cam.depth(p.pos),
          () => g.mote(p.pos, _cowMoteR, _Colors.cowMote),
        ));
      }
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, paint) in items) {
      paint();
    }
    // The soil label names the bare patch until grass grows (the HTML
    // label always read 'Grass').
    labels.add((
      cam.p(_soilLabelAt),
      _t(s.hasGrass ? 'lbl_grass' : 'lbl_soil'),
    ));
  }

  /// One blade: a thin triangle from its base to its tip, its left half
  /// [left] and its right half [right].
  void _paintBlade(
    _Gfx g,
    _Blade blade,
    double height,
    Color left,
    Color right,
  ) {
    final cam = g.cam;
    final pb = cam.p(blade.base);
    final pt = cam.p(blade.base + blade.axis * height);
    final w = _bladeR * cam.scaleAt(blade.base);
    final axis = pt - pb;
    final len = axis.distance;
    final across = len < w
        ? const Offset(1, 0)
        : Offset(-axis.dy, axis.dx) / len;
    g
      ..fill([pb - across * w, pt, pb], left)
      ..fill([pb, pt, pb + across * w], right);
  }

  /// A rim rock (DodecahedronGeometry): a faceted outline, lit from the
  /// upper right, with a facet edge.
  void _paintRock(_Gfx g, _Rock rock) {
    final cam = g.cam;
    final light = g.light;
    final o = cam.p(rock.at);
    final radius = rock.radius * cam.scaleAt(rock.at);
    final pts = [
      for (var j = 0; j < _rockCorners; j++)
        o +
            Offset(
                  math.cos(rock.spin + j * 2 * math.pi / _rockCorners),
                  math.sin(rock.spin + j * 2 * math.pi / _rockCorners) * 0.82,
                ) *
                (radius * rock.jitter[j]),
    ];
    final hi = light.lit(_Colors.rock, (_lightDir + _V.up).unit);
    final mid = light.lit(_Colors.rock, (-cam.f + _V.up).unit);
    final lo = light.lit(_Colors.rock, -cam.f);
    final path = Path()..addPolygon(pts, true);
    g.canvas
      ..drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.radial(
            o + g._highlight * radius,
            radius * 1.5,
            [hi, mid, labShade(lo, -0.25)],
            const [0, 0.45, 1],
          ),
      )
      ..drawLine(
        pts[1],
        o + Offset(radius * 0.1, radius * 0.05),
        Paint()
          ..strokeWidth = math.max(0.6, radius * 0.06)
          ..color = labShade(lo, -0.35).withValues(alpha: 0.6),
      )
      ..drawLine(
        o + Offset(radius * 0.1, radius * 0.05),
        pts[4],
        Paint()
          ..strokeWidth = math.max(0.6, radius * 0.06)
          ..color = labShade(lo, -0.35).withValues(alpha: 0.6),
      );
  }

  /// buildHighFidelityCow(): tail, legs and hooves, the torso with its
  /// patches, then the head group (far horn and ear, head, snout, near ear
  /// and horn), all scaled by its pop-in. When it glows (emissive
  /// 0x34d399) a faint green aura shows the stored energy.
  void _paintCow(_Gfx g, List<_Label> labels) {
    final s = scene;
    final k = s.cowScale.at(s.time);
    final cam = g.cam;
    final cow = _Xf.at(_cowAt, ry: _cowYaw, scale: k);
    final glow = s.cowGlow ? _Colors.cowGlow : null;
    final neck = cow * _Xf.at(_neckAt, rz: s.headAngle);
    final tail = cow * _Xf.at(_tailAt, ry: s.tailAngle);
    if (glow != null) {
      labGlow(
        g.canvas,
        cam.p(cow.apply(_torsoAt)),
        3.4 * k * cam.scaleAt(cow.apply(_torsoAt)),
        _Colors.cowGlow,
        intensity: 0.35,
      );
    }

    // Tail: a rod hanging from the rump, the brush at its tip.
    final tailAxis = _V(-math.sin(_tailTilt), math.cos(_tailTilt), 0);
    final rodTop = tail.apply(_tailRodAt + tailAxis * (_tailLen / 2));
    final rodTip = tail.apply(_tailRodAt - tailAxis * (_tailLen / 2));
    g
      ..rod(
        rodTop,
        rodTip,
        _tailTopR * k,
        _tailBottomR * k,
        _Colors.cowBody,
        emissive: glow,
        glow: _cowGlowStrength,
      )
      ..ball(
        rodTip,
        _brushR * k,
        _Colors.cowPatch,
        emissive: glow,
        glow: _cowGlowStrength,
      );

    // Legs and hooves, the far ones first.
    final legs = [for (final (x, z) in _legSpots) cow.apply(_V(x, 0, z))]
      ..sort((a, b) => cam.depth(b).compareTo(cam.depth(a)));
    for (final base in legs) {
      g
        ..cylinder(
          base,
          _legBottomR * k,
          _legTopR * k,
          _legH * k,
          _Colors.cowBody,
          emissive: glow,
          glow: _cowGlowStrength,
          sides: 12,
          cap: false,
        )
        ..cylinder(
          base,
          _hoofBottomR * k,
          _hoofTopR * k,
          _hoofH * k,
          _Colors.cowHoof,
          emissive: glow,
          glow: _cowGlowStrength,
          sides: 12,
          cap: false,
        );
    }

    // Torso with the two dark patches wrapped round it.
    final hx = _torsoSize.x / 2;
    final stripes = <_Stripe>[];
    var x = -hx;
    for (final (p0, p1) in _patches) {
      stripes
        ..add((x, p0, _Colors.cowBody))
        ..add((p0, p1, _Colors.cowPatch));
      x = p1;
    }
    stripes.add((x, hx, _Colors.cowBody));
    g.box(
      cow,
      _torsoAt,
      _torsoSize,
      _Colors.cowBody,
      emissive: glow,
      glow: _cowGlowStrength,
      stripes: stripes,
    );

    // Head group; its +z side faces the camera.
    final hornAxis = _V(-math.sin(_hornTilt), math.cos(_hornTilt), 0);
    void horn(double z) {
      final c = _V(_hornAt.x, _hornAt.y, z);
      g.rod(
        neck.apply(c - hornAxis * (_hornH / 2)),
        neck.apply(c + hornAxis * (_hornH / 2)),
        _hornR * k,
        0.015 * k,
        _Colors.cowHorn,
      );
    }

    void ear(double z) =>
        g.box(neck, _V(_earAt.x, _earAt.y, z), _earSize, _Colors.cowEar);

    horn(-_hornAt.z);
    ear(-_earAt.z);
    g
      ..box(
        neck,
        _headAt,
        _headSize,
        _Colors.cowBody,
        emissive: glow,
        glow: _cowGlowStrength,
      )
      ..box(neck, _snoutAt, _snoutSize, _Colors.cowSnout);
    // Eyes and nostrils (added; the HTML head is a plain box).
    final eye = neck.apply(_headAt + const _V(0.45, 0.25, 0.66));
    final nose = neck.apply(_snoutAt + const _V(0.46, 0, 0.25));
    g
      ..flat(cam.p(eye), 0.09 * k * cam.scaleAt(eye), _Colors.slate900)
      ..flat(cam.p(nose), 0.07 * k * cam.scaleAt(nose), _Colors.slate700);
    ear(_earAt.z);
    horn(_hornAt.z);
    labels.add((cam.p(cow.apply(_cowLabelAt)), _t('lbl_cow')));
  }

  // --------------------------------------------------------- scenario 2

  /// buildS2Scene(): the Sun and the cloud, the plateau with its lawn, the
  /// house with the solar panel, the wire with its pulses and the bulb
  /// stand.
  void _paintSolarHome(_Gfx g, List<_Label> labels) {
    final s = scene;
    final t = s.time;
    final cam = g.cam;
    final light = g.light;
    _paintSun(g, labels);
    _paintCloud(g);
    _paintPlateau(g, _Colors.plateau2);
    g.disc(const _V(0, _topY, 0), _topR, light.lit(_Colors.lawn, _V.up));
    // The bulb's point light on the lawn.
    if (s.bulbOn) {
      g.pool(
        _V(_standAt.x, _topY, _standAt.z),
        _bulbPoolR,
        _Colors.bulbLight,
        s.bulbPower.at(t),
      );
    }

    // The house: walls, the window band's front, the roof.
    g
      ..box(_Xf.identity, _wallsAt, _wallsSize, _Colors.walls)
      ..box(
        _Xf.identity,
        _windowAt,
        _windowSize,
        _metal(_Colors.window),
        only: (n) => n.z != 0,
      );
    _paintRoof(g);

    // The solar panel on the roof.
    final pk = s.panelScale.at(t);
    if (s.hasPanel && pk > 0.001) {
      final panel = _Xf.at(
        _panelAt,
        rx: _panelTiltX,
        rz: _panelTiltZ,
        scale: pk,
      );
      g.box(panel, _V.zero, _panelSize, _metal(_Colors.panelFrame));
      final cells =
          [
            for (final x in _cellXs)
              for (final z in _cellZs) _V(x, 0, z),
          ]..sort(
            (a, b) =>
                cam.depth(panel.apply(b)).compareTo(cam.depth(panel.apply(a))),
          );
      for (final c in cells) {
        g.box(
          panel,
          c,
          _cellSize,
          _metal(_Colors.panelCell),
          only: (n) => n.y > 0,
        );
      }
      labels.add((cam.p(panel.apply(_panelLabelAt)), _t('lbl_panel')));
    }

    // The wire (scaled in from the origin, as the HTML mesh) and the
    // electric pulses running down it.
    final wk = s.wireScale.at(t);
    if (s.hasWire && wk > 0.001) _paintWire(g, wk);
    if (s.sparkFlow) {
      for (final p in s.sparks) {
        g.mote(_wire.pointAt(p.x), _sparkR, _Colors.spark);
      }
    }

    _paintStand(g);
    labels.add((cam.p(_bulbLabelAt), _t('lbl_bulb')));
  }

  /// Colour of a metal part: Three.js lights little of a metal's own
  /// colour without an environment map to reflect.
  static Color _metal(Color c) => labShade(c, -(1 - _metalDiffuse));

  /// The four-sided roof (ConeGeometry turned 45°): its faces that look
  /// at the camera, with a darker ridge line.
  void _paintRoof(_Gfx g) {
    final cam = g.cam;
    const a = _roofApex;
    const y = _roofBaseY;
    const h = _roofHalf;
    final corners = [
      _V(a.x - h, y, a.z + h),
      _V(a.x + h, y, a.z + h),
      _V(a.x + h, y, a.z - h),
      _V(a.x - h, y, a.z - h),
    ];
    final ridge = <(Offset, Offset)>[];
    for (var k = 0; k < 4; k++) {
      final p0 = corners[k], p1 = corners[(k + 1) % 4];
      var n = (p1 - p0).cross(a - p0).unit;
      if (n.y < 0) n = -n;
      final mid = (p0 + p1 + a) * (1 / 3);
      if (!cam.facing(n, mid)) continue;
      g.fill([cam.p(p0), cam.p(p1), cam.p(a)], g.light.lit(_Colors.roof, n));
      ridge
        ..add((cam.p(p0), cam.p(a)))
        ..add((cam.p(p1), cam.p(a)));
    }
    final line = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = labShade(g.light.lit(_Colors.roof, _V.up), -0.35);
    for (final (p, q) in ridge) {
      g.canvas.drawLine(p, q, line);
    }
  }

  /// The wire: a tube along the curve, with a highlight.
  void _paintWire(_Gfx g, double scale) {
    final cam = g.cam;
    final pts = [for (final p in _wire.points) cam.p(p * scale)];
    final path = Path()..addPolygon(pts, false);
    final mid = _wire.pointAt(0.5) * scale;
    final width = math.max(2.5, 2 * _wireR * scale * cam.scaleAt(mid));
    final c = g.light.lit(_Colors.wire, -cam.f);
    g.canvas
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = c,
      )
      ..drawPath(
        path.shift(Offset(width * 0.15, -width * 0.18)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.3
          ..strokeCap = StrokeCap.round
          ..color = labShade(c, 0.4).withValues(alpha: 0.7),
      );
  }

  /// The bulb stand: base, pole and socket, the filament and the glass;
  /// when lit, the glass glows and the coronas and rays pulse round it.
  void _paintStand(_Gfx g) {
    final s = scene;
    final t = s.time;
    final cam = g.cam;
    const b = _standAt;
    g
      ..cylinder(b, _baseBottomR, _baseTopR, _baseH, _metal(_Colors.standBase))
      ..cylinder(
        b + const _V(0, _baseH, 0),
        _poleR,
        _poleR,
        _poleBottom + _poleH - _baseH,
        _metal(_Colors.standPole),
        sides: 14,
      )
      ..cylinder(
        b + const _V(0, _socketBottom, 0),
        _socketBottomR,
        _socketTopR,
        _socketH,
        _metal(_Colors.socket),
        sides: 16,
      );
    final c = b + const _V(0, _bulbY, 0);
    final on = s.bulbOn;
    g.ring(
      c,
      _filamentR,
      _filamentTube,
      on ? _Colors.filamentOn : _Colors.filamentOff,
    );
    if (!on) {
      g.ball(c, _bulbR, _Colors.bulbOff, opacity: 1);
      return;
    }
    g.ball(c, _bulbR, _Colors.bulbOn, emissive: _Colors.bulbEmissive, glow: 2);
    final o = cam.p(c);
    final px = cam.scaleAt(c);
    final pulse = 1 + math.sin(t * _bulbPulseRate) * _bulbPulse;
    for (final (r, color) in _bulbCoronas) {
      g.flat(o, r * pulse * px, color);
    }
    final spin = t * _bulbRaySpin;
    for (var i = 0; i < _bulbRays; i++) {
      g.beam(
        c,
        i * 2 * math.pi / _bulbRays + spin,
        _bulbRayAt * pulse,
        _bulbRayLen * pulse,
        _bulbRayR * pulse,
        _Colors.bulbRay,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.texts != texts ||
      old.isDark != isDark ||
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
