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

/// Class 6 Science • Chapter 10 • Activity 1
/// Characteristics of Living Beings.
///
/// Native Flutter port of `Cl6S-Ch10-A1-Characteristics_of_Living_Beings.html`.
///
/// Scenario 1 (The Life Test Chamber): on a round test platform a pigeon, a
/// pencil, a potted plant and a toy car are tested one after the other for
/// the characteristics of living things: food (a pellet is dropped), response
/// to a touch, reproduction (a one-month time-lapse) and growth (water and
/// sunlight). Step 8 reviews the summary table.
///
/// Scenario 2 (The Movement Misconception): a car drives along a road, then a
/// 'Time-Lapse' slider moves the sun across the sky while a sunflower's head
/// turns to follow it, and a 7-day time-lapse makes the sunflower grow while
/// the parked car only gathers dust.
///
/// The Three.js scenes are redrawn by a CustomPainter through a perspective
/// projection of the HTML cameras (fov 45°): Scenario 1 looks from the HTML
/// direction (0, 16, 38) at the platform from 0.6 of the HTML distance, so
/// the objects are large enough on a phone; Scenario 2 is framed so that the
/// road, the sunflower (also after it has grown) and the sun's whole path
/// are in the picture (in the HTML the sun was above the top edge for most of
/// its path).
class Ch10A1CharacteristicsOfLivingBeingsPage extends StatefulWidget {
  const Ch10A1CharacteristicsOfLivingBeingsPage({super.key});

  @override
  State<Ch10A1CharacteristicsOfLivingBeingsPage> createState() =>
      _LivingBeingsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises Web Audio tones: `click`
/// (buttons, Enter Lab, scenario change, Go, Touch Pencil), `flap` (Touch
/// Pigeon, mapped to pickup.mp3), `pop` (the time-lapses) and `success` (the
/// summary). It also asks for a `woosh` (the food pellet, water and
/// sunlight) that its `playSound` never synthesised, so the HTML stayed
/// silent there; it is mapped to drop.mp3. correct.mp3 / error.mp3 are the
/// shell's feedback tones.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// woosh → `science/drop.mp3`, flap → `science/pickup.mp3`,
/// pop → `science/pop.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `woosh`: the pellet drops, the water and sunlight pour down.
  woosh('audio/class6/science/drop.mp3'),

  /// HTML `flap`: the startled pigeon flaps its wings.
  flap('audio/class6/science/pickup.mp3'),

  /// HTML `pop`: the time-lapses.
  pop('audio/class6/science/pop.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// A hint after a wrong slider move (added: the HTML stayed silent).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: the summary.
  success('audio/class6/math/success.mp3');

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
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color indigo400 = Color(0xFF818CF8);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background: #1e293b (dark), #e2e8f0 (light).
  static const Color canvasDark = slate800;
  static const Color canvasLight = slate200;

  /// Scenario 1 platform `CylinderGeometry(5.5, 6.0, 1.2)` 0x1e293b and its
  /// glow ring 0x10b981 (opacity 0.5).
  static const Color platform = slate800;
  static const Color platformGlow = Color(0x8010B981);

  /// `buildPigeon(false)`: body 0x64748b, wings 0x475569, neck 0x14b8a6,
  /// beak 0xd97706, legs 0xe11d48, tail 0x334155, cere white, eyes 0x0f172a
  /// with 0xfacc15 rims.
  static const Color pigeonBody = slate500;
  static const Color pigeonWing = slate600;
  static const Color pigeonNeck = Color(0xFF14B8A6);
  static const Color beak = Color(0xFFD97706);
  static const Color pigeonLegs = Color(0xFFE11D48);
  static const Color pigeonTail = slate700;
  static const Color cere = white;
  static const Color eye = slate900;
  static const Color eyeRim = Color(0xFFFACC15);

  /// `buildPigeon(true)` (the chick): body / neck 0xfcd34d, wings / tail
  /// 0xfbbf24, legs 0xd97706.
  static const Color chickBody = Color(0xFFFCD34D);
  static const Color chickWing = Color(0xFFFBBF24);
  static const Color chickLegs = beak;

  /// Added: the egg the chick hatches from.
  static const Color egg = Color(0xFFF5F5F4);

  /// Food pellets `MeshStandardMaterial(0xd97706)`.
  static const Color pellet = beak;

  /// `buildPencil()`: body 0xf59e0b, sharpened wood 0xffedd5, lead 0x334155.
  static const Color pencil = amber500;
  static const Color pencilWood = Color(0xFFFFEDD5);
  static const Color lead = slate700;

  /// `buildPottedPlant()`: pot 0x9a3412, stem 0x22c55e, leaves 0x16a34a,
  /// flower centre 0xca8a04, red petals 0xef4444; soil (added) 0x451a03.
  static const Color pot = Color(0xFF9A3412);
  static const Color soil = Color(0xFF451A03);
  static const Color stem = Color(0xFF22C55E);
  static const Color leaf = Color(0xFF16A34A);
  static const Color flowerCentre = Color(0xFFCA8A04);
  static const Color petal = red500;

  /// `buildToyCar()`: body 0xef4444, cabin 0xdc2626, tyres 0x0f172a, rims
  /// 0xe2e8f0, glass 0x93c5fd.
  static const Color carBody = red500;
  static const Color carRoof = red600;
  static const Color tyre = slate900;
  static const Color rim = slate200;
  static const Color carGlass = Color(0xFF93C5FD);

  /// `playWaterSunEffect`: sunbeam 0xfacc15 (opacity up to 0.35), drops
  /// 0x3b82f6 (opacity 0.8).
  static const Color sunbeam = Color(0xFFFACC15);
  static const Color drop = Color(0xFF3B82F6);

  /// Added: the wet shine on the toy car and the dust on the parked car.
  static const Color wetShine = Color(0xFFBFDBFE);
  static const Color dust = Color(0xFFA8A29E);

  /// Added: a hand (skin, outline, sleeve) touches the pigeon and the pencil.
  static const Color skin = Color(0xFFF1C27D);
  static const Color skinLine = Color(0xFFB45309);
  static const Color sleeve = Color(0xFF2563EB);

  /// Scenario 2: road 0x334155, grass 0x16a34a, sunflower stem 0x16a34a,
  /// leaves 0x15803d, disc 0x451a03, petals 0xfacc15, sun 0xfbbf24 (emissive
  /// 0xf59e0b).
  static const Color road = slate700;
  static const Color roadEdge = slate500;
  static const Color grass = leaf;
  static const Color grassFar = Color(0xFF4ADE80);
  static const Color sfStem = leaf;
  static const Color sfLeaf = Color(0xFF15803D);
  static const Color sfDisc = soil;
  static const Color sfDiscRing = Color(0xFF78350F);
  static const Color sfPetal = sunbeam;
  static const Color sun = Color(0xFFFBBF24);
  static const Color sunGlow = Color(0x99F59E0B);

  /// Added: a day sky behind Scenario 2 (the HTML showed the canvas colour).
  static const Color skyTopDark = Color(0xFF0C4A6E);
  static const Color skyLowDark = Color(0xFF0369A1);
  static const Color skyTopLight = Color(0xFF7DD3FC);
  static const Color skyLowLight = Color(0xFFE0F2FE);

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// HTML `createTextSprite`: speech bubble rgba(15, 23, 42, 0.9), emerald
  /// 0x10b981 border, white bold text.
  static const Color labelBg = Color(0xE60F172A);
  static const Color labelBorder = emerald500;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xF20F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvasDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.emerald500, // text-emerald-500 headings, buttons
    onAccent: _Colors.slate950, // Enter Lab: text-slate-950 on emerald
    primary: _Colors.teal600, // summary buttons to-teal
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66064E3B), // from-emerald-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC6EE7B7), // subtitle text-emerald-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.emerald500,
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
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvasLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald600, // text-emerald-600 headings (light)
    onAccent: _Colors.white,
    primary: _Colors.teal600,
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
    curtainGlow: Color(0x66064E3B),
    curtainText: _Colors.white,
    curtainMuted: _Colors.emerald300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.emerald500,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
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

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays its `click` tone for buttons, the sidebar, scenario changes and the
/// curtain, and `success` for the summary.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.click,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.click,
  curtain: _Sound.click,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// and HUD lines say "tap" instead of "click" and name the buttons as they
// are labelled. Texts that stated a result before it was observed (concepts
// such as "Needs Food (Pencil)", HUD lines such as "observe purely physical
// rolling", labels such as "Pencil (Non-Living)") are neutral until the
// result has been seen. The HTML's Hindi texts were shorter than the English
// ones; they are completed here. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Characteristics of Living Beings',
    'app_subtitle':
        'Class 6 • Living Creatures: Exploring their Characteristics',
    'scen_1_opt': 'Scenario 1: The Life Test Chamber',
    'scen_2_opt': 'Scenario 2: The Movement Misconception',
    's1_desc':
        'To test various objects against the fundamental characteristics of living things (nutrition, response to stimuli, reproduction, growth) and visually determine if they are living or non-living.',
    's2_desc':
        "To understand that 'movement' in living things is not just about changing location (locomotion) but also includes growth and internal response to the environment (like turning towards light).",
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Nutrition (Pigeon)',
    's1_a1': "Tap 'Feed Pigeon' to drop a food pellet near the pigeon.",
    's1_o1':
        'The pigeon bends its head down and eats the pellet. Living things need food for energy!',
    's1_c2': 'Nutrition (Pencil)',
    's1_a2': "Tap 'Feed Pencil' to drop a food pellet onto the pencil.",
    's1_o2':
        'The pellet bounces off the pencil and rolls away. Non-living objects do not eat or need food.',
    's1_c3': 'Response to Stimuli (Pigeon)',
    's1_a3': "Tap 'Touch Pigeon' to touch the pigeon with a hand.",
    's1_o3':
        'The pigeon gets startled, flaps its wings, flies up briefly and lands. Living beings respond to stimuli!',
    's1_c4': 'Response to Stimuli (Pencil)',
    's1_a4': "Tap 'Touch Pencil' to push the pencil with a hand.",
    's1_o4':
        'The pencil simply rolls away because of the push (a physical force). It shows no reaction or reflex of its own.',
    's1_c5': 'Growth & Reproduction (Pigeon)',
    's1_a5': "Tap 'Time-Lapse (Reproduction)' to fast-forward time.",
    's1_o5':
        'Time fast-forwards by a month. The pigeon lays an egg, and a baby pigeon (chick) hatches beside the adult!',
    's1_c6': 'Growth (Plant)',
    's1_a6': "Tap 'Water & Sun' to give the plant water and sunlight.",
    's1_o6':
        'The potted plant grows taller and a fresh flower blooms. Living things grow!',
    's1_c7': 'Growth (Toy Car)',
    's1_a7': "Tap 'Water & Sun' to give the toy car water and sunlight.",
    's1_o7':
        'The toy car gets wet and lit up, but it does not grow or change. Non-living things do not grow.',
    's1_c8': 'Conclusion',
    's1_a8':
        "Tap 'Observe Summary & Conclusion' to review the summary table of all the characteristics checked.",
    's1_o8':
        'Living things need food, grow, respond and reproduce. Non-living things show none of these.',
    // Scenario 2 steps.
    's2_c1': 'Car Locomotion',
    's2_a1': "Tap 'Go' to move the car.",
    's2_o1':
        'The car drives from left to right along the road. But is it alive? No! Its movement is powered by an engine and fuel.',
    's2_c2': 'Sunflower and the Sun',
    's2_a2': "Drag the 'Time-Lapse' slider to move the sun across the sky.",
    's2_o2':
        'As the sun moves across the sky, the head of the sunflower turns smoothly to follow the light!',
    's2_c3': 'Across the Sky',
    's2_a3': "Keep dragging the 'Time-Lapse' slider all the way to one end.",
    's2_o3':
        'The sunflower keeps tracking the sun all the way. This is an internal biological response.',
    's2_c4': 'Seven Days Later',
    's2_a4': "Tap 'Time-Lapse: 7 Days' to fast-forward a week.",
    's2_o4':
        'The sunflower grows taller, its stem gets stronger and its leaves get bigger. Meanwhile, the car just sits still and gathers dust.',
    's2_c5': 'Lab Conclusion',
    's2_a5': "Tap 'Observe Summary & Conclusion'.",
    's2_o5':
        "Both can 'move', but the car's locomotion is external and mechanical, while the sunflower's movement is an internal biological response and growth.",
    // HTML `hud-instruction` lines.
    's1_hud_1':
        "Step 1: Tap 'Feed Pigeon' to drop a food pellet near the pigeon and watch what it does.",
    's1_hud_2':
        "Step 2: Tap 'Feed Pencil' to drop a food pellet onto the pencil and observe what happens.",
    's1_hud_3':
        "Step 3: Tap 'Touch Pigeon' to touch the pigeon and observe what happens.",
    's1_hud_4':
        "Step 4: Tap 'Touch Pencil' to push the pencil and observe what happens.",
    's1_hud_5':
        "Step 5: Tap 'Time-Lapse (Reproduction)' to fast-forward time and watch the pigeon.",
    's1_hud_6':
        "Step 6: Tap 'Water & Sun' to give the plant water and sunlight.",
    's1_hud_7':
        "Step 7: Tap 'Water & Sun' to give the toy car water and sunlight.",
    's1_hud_8':
        "Step 8: Tap 'Observe Summary & Conclusion' to review all the characteristics checked.",
    's2_hud_1':
        "Step 1: Tap 'Go' to watch the car move along the road. Does movement alone make it living?",
    's2_hud_2':
        "Step 2: Drag the 'Time-Lapse' slider to move the sun and watch the sunflower's head.",
    's2_hud_3':
        'Step 3: Keep dragging the slider all the way to one end and keep watching the sunflower.',
    's2_hud_4':
        "Step 4: Tap 'Time-Lapse: 7 Days' to fast-forward a week and compare the sunflower with the car.",
    's2_hud_5':
        "Step 5: Tap 'Observe Summary & Conclusion' to see the difference between locomotion and living movement.",
    // Buttons (the HTML action bars and `#compare-btn-container`).
    'btn_feed_pigeon': 'Feed Pigeon',
    'btn_feed_pencil': 'Feed Pencil',
    'btn_touch_pigeon': 'Touch Pigeon',
    'btn_touch_pencil': 'Touch Pencil',
    'btn_timelapse': 'Time-Lapse (Reproduction)',
    'btn_water': 'Water & Sun',
    'btn_go': 'Go',
    'btn_7days': 'Time-Lapse: 7 Days',
    'btn_conclude': 'Observe Summary & Conclusion',
    'slider': 'Time-Lapse',
    // Toasts.
    'toast_month': 'Time passing... 1 Month later!',
    'toast_water': 'Water and sunlight applied!',
    'toast_7days': '7 Days Fast-Forwarding...',
    // Added: hints where the HTML waited silently.
    'hint_slide_more': 'Drag the slider further to move the sun.',
    'hint_slide_end': 'Keep dragging the slider all the way to one end.',
    // Canvas labels (HTML `createTextSprite`); the class is added once the
    // object's tests are done.
    'lbl_pigeon': 'Pigeon',
    'lbl_pigeon_done': 'Pigeon (Living)',
    'lbl_pencil': 'Pencil',
    'lbl_pencil_done': 'Pencil (Non-Living)',
    'lbl_plant': 'Potted Plant',
    'lbl_plant_done': 'Potted Plant (Living)',
    'lbl_car': 'Toy Car',
    'lbl_car_done': 'Toy Car (Non-Living)',
    'lbl_sunflower': 'Sunflower',
    'lbl_sunflower_done': 'Sunflower (Living)',
    // Summary popups (HTML `triggerConclusion`).
    'sum_title_1': 'Life Test Complete!',
    'sum_1':
        'We observed that living things (like pigeons and plants) need food for energy, respond to stimuli, grow and reproduce. Non-living things (like pencils and toy cars) show none of these life processes.',
    'next_1':
        'Scenario 1 Complete! Please select Scenario 2 from the sidebar to continue.',
    'sum_title_2': 'Misconception Cleared!',
    'sum_2':
        'Movement does not always mean moving from one place to another (locomotion). A car moves because of an engine (a machine), but it is non-living. A sunflower stays rooted, yet it moves by turning towards the sun and by growing (internal life processes).',
    'next_2':
        'Scenario 2 Complete! You have explored both scenarios in this activity.',
    // Summary table (HTML step 8 accordion).
    'tbl_title': 'Summary Table',
    'tbl_living': 'LIVING',
    'tbl_nonliving': 'NON-LIVING',
    'tbl_pigeon': 'Pigeon',
    'tbl_plant': 'Plant',
    'tbl_pencil': 'Pencil',
    'tbl_car': 'Car',
    'tbl_food': 'Needs Food',
    'tbl_responds': 'Responds',
    'tbl_grows': 'Grows / Reproduces',
    'tbl_yes': 'Yes',
    'tbl_no': 'No',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Round test platform where a pigeon, a pencil, a potted plant and a toy car are tested',
    'scene_s2': 'A road with a car, and a sunflower under the sky',
  },
  'hi': {
    'app_title': 'सजीवों के लक्षण',
    'app_subtitle': 'कक्षा 6 • सजीव प्राणी: उनकी विशेषताओं की खोज',
    'scen_1_opt': 'परिदृश्य 1: जीवन परीक्षण कक्ष',
    'scen_2_opt': 'परिदृश्य 2: गति की भ्रांति',
    's1_desc':
        'विभिन्न वस्तुओं को सजीवों के मौलिक लक्षणों (पोषण, उत्तेजना के प्रति प्रतिक्रिया, प्रजनन, वृद्धि) पर परखना और देखकर पहचानना कि कौन-सी वस्तुएँ सजीव हैं और कौन-सी निर्जीव।',
    's2_desc':
        "यह समझना कि सजीवों में 'गति' का अर्थ केवल स्थान बदलना (चलन) नहीं है, बल्कि इसमें वृद्धि और वातावरण के प्रति आंतरिक प्रतिक्रिया (जैसे प्रकाश की ओर मुड़ना) भी शामिल है।",
    's1_c1': 'पोषण (कबूतर)',
    's1_a1': "कबूतर के पास दाना गिराने के लिए 'कबूतर को दाना दें' पर टैप करें।",
    's1_o1':
        'कबूतर सिर झुकाकर दाना चुग लेता है। सजीवों को ऊर्जा के लिए भोजन चाहिए!',
    's1_c2': 'पोषण (पेंसिल)',
    's1_a2': "पेंसिल पर दाना गिराने के लिए 'पेंसिल को दाना दें' पर टैप करें।",
    's1_o2':
        'दाना पेंसिल से टकराकर लुढ़क जाता है। निर्जीव वस्तुएँ न खाती हैं, न उन्हें भोजन चाहिए।',
    's1_c3': 'उत्तेजना पर प्रतिक्रिया (कबूतर)',
    's1_a3': "हाथ से कबूतर को छूने के लिए 'कबूतर को छुएँ' पर टैप करें।",
    's1_o3':
        'कबूतर चौंक जाता है, पंख फड़फड़ाता है, थोड़ा ऊपर उड़कर फिर बैठ जाता है। सजीव उत्तेजना पर प्रतिक्रिया देते हैं!',
    's1_c4': 'उत्तेजना पर प्रतिक्रिया (पेंसिल)',
    's1_a4': "हाथ से पेंसिल को धकेलने के लिए 'पेंसिल को छुएँ' पर टैप करें।",
    's1_o4':
        'पेंसिल केवल धक्के (एक भौतिक बल) के कारण लुढ़क जाती है। उसमें अपनी कोई प्रतिक्रिया नहीं होती।',
    's1_c5': 'वृद्धि और प्रजनन (कबूतर)',
    's1_a5': "समय को आगे बढ़ाने के लिए 'टाइम-लैप्स (प्रजनन)' पर टैप करें।",
    's1_o5':
        'समय एक महीना आगे बढ़ता है। कबूतर अंडा देता है और अंडे से कबूतर का बच्चा निकलकर बड़े कबूतर के पास आ जाता है!',
    's1_c6': 'वृद्धि (पौधा)',
    's1_a6': "पौधे को पानी और धूप देने के लिए 'पानी और धूप' पर टैप करें।",
    's1_o6':
        'गमले का पौधा लंबा हो जाता है और उस पर एक नया फूल खिलता है। सजीवों में वृद्धि होती है!',
    's1_c7': 'वृद्धि (खिलौना कार)',
    's1_a7': "खिलौना कार को पानी और धूप देने के लिए 'पानी और धूप' पर टैप करें।",
    's1_o7':
        'खिलौना कार भीग जाती है और उस पर धूप पड़ती है, पर उसमें न वृद्धि होती है, न कोई बदलाव। निर्जीवों में वृद्धि नहीं होती।',
    's1_c8': 'निष्कर्ष',
    's1_a8':
        "जाँचे गए सभी लक्षणों की सारांश तालिका देखने के लिए 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's1_o8':
        'सजीवों को भोजन चाहिए, उनमें वृद्धि होती है, वे प्रतिक्रिया देते हैं और प्रजनन करते हैं। निर्जीवों में इनमें से कोई लक्षण नहीं होता।',
    's2_c1': 'कार की गति',
    's2_a1': "कार चलाने के लिए 'चलाएँ' पर टैप करें।",
    's2_o1':
        'कार सड़क पर बाएँ से दाएँ चलती है। पर क्या वह सजीव है? नहीं! उसकी गति इंजन और ईंधन से होती है।',
    's2_c2': 'सूरजमुखी और सूरज',
    's2_a2': "सूरज को आकाश में आगे बढ़ाने के लिए 'टाइम-लैप्स' स्लाइडर खींचें।",
    's2_o2':
        'जैसे-जैसे सूरज आकाश में आगे बढ़ता है, सूरजमुखी का सिर धीरे-धीरे प्रकाश की ओर मुड़ता जाता है!',
    's2_c3': 'पूरे आकाश में',
    's2_a3': "'टाइम-लैप्स' स्लाइडर को एक सिरे तक पूरा खींचते रहें।",
    's2_o3':
        'सूरजमुखी पूरे समय सूरज की दिशा में मुड़ता रहता है। यह एक आंतरिक जैविक प्रतिक्रिया है।',
    's2_c4': 'सात दिन बाद',
    's2_a4': "एक सप्ताह आगे बढ़ने के लिए 'टाइम-लैप्स: 7 दिन' पर टैप करें।",
    's2_o4':
        'सूरजमुखी लंबा हो जाता है, उसका तना मज़बूत होता है और पत्तियाँ बड़ी होती हैं। इस बीच कार वैसे ही खड़ी रहती है और उस पर धूल जम जाती है।',
    's2_c5': 'निष्कर्ष',
    's2_a5': "'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_o5':
        "दोनों 'गति' कर सकते हैं, पर कार की गति बाहरी और यांत्रिक है, जबकि सूरजमुखी की गति एक आंतरिक जैविक प्रतिक्रिया और वृद्धि है।",
    's1_hud_1':
        "चरण 1: 'कबूतर को दाना दें' पर टैप करें और देखें कि कबूतर क्या करता है।",
    's1_hud_2':
        "चरण 2: 'पेंसिल को दाना दें' पर टैप करें और देखें कि क्या होता है।",
    's1_hud_3': "चरण 3: 'कबूतर को छुएँ' पर टैप करें और देखें कि क्या होता है।",
    's1_hud_4': "चरण 4: 'पेंसिल को छुएँ' पर टैप करें और देखें कि क्या होता है।",
    's1_hud_5': "चरण 5: 'टाइम-लैप्स (प्रजनन)' पर टैप करें और कबूतर को देखें।",
    's1_hud_6':
        "चरण 6: पौधे को पानी और धूप देने के लिए 'पानी और धूप' पर टैप करें।",
    's1_hud_7':
        "चरण 7: खिलौना कार को पानी और धूप देने के लिए 'पानी और धूप' पर टैप करें।",
    's1_hud_8':
        "चरण 8: जाँचे गए सभी लक्षण देखने के लिए 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    's2_hud_1':
        "चरण 1: कार को चलते देखने के लिए 'चलाएँ' पर टैप करें। क्या केवल चलने से वह सजीव हो जाती है?",
    's2_hud_2':
        "चरण 2: सूरज को आगे बढ़ाने के लिए 'टाइम-लैप्स' स्लाइडर खींचें और सूरजमुखी का सिर देखें।",
    's2_hud_3':
        'चरण 3: स्लाइडर को एक सिरे तक पूरा खींचें और सूरजमुखी को देखते रहें।',
    's2_hud_4':
        "चरण 4: एक सप्ताह आगे बढ़ने के लिए 'टाइम-लैप्स: 7 दिन' पर टैप करें और सूरजमुखी की तुलना कार से करें।",
    's2_hud_5':
        "चरण 5: चलन और जैविक गति का अंतर समझने के लिए 'निष्कर्ष और सारांश देखें' पर टैप करें।",
    'btn_feed_pigeon': 'कबूतर को दाना दें',
    'btn_feed_pencil': 'पेंसिल को दाना दें',
    'btn_touch_pigeon': 'कबूतर को छुएँ',
    'btn_touch_pencil': 'पेंसिल को छुएँ',
    'btn_timelapse': 'टाइम-लैप्स (प्रजनन)',
    'btn_water': 'पानी और धूप',
    'btn_go': 'चलाएँ',
    'btn_7days': 'टाइम-लैप्स: 7 दिन',
    'btn_conclude': 'निष्कर्ष और सारांश देखें',
    'slider': 'टाइम-लैप्स',
    'toast_month': 'समय बीत रहा है... 1 महीने बाद!',
    'toast_water': 'पानी और धूप दी गई!',
    'toast_7days': '7 दिन तेज़ी से आगे बढ़ रहे हैं...',
    'hint_slide_more': 'सूरज को आगे बढ़ाने के लिए स्लाइडर को और खींचें।',
    'hint_slide_end': 'स्लाइडर को एक सिरे तक पूरा खींचते रहें।',
    'lbl_pigeon': 'कबूतर',
    'lbl_pigeon_done': 'कबूतर (सजीव)',
    'lbl_pencil': 'पेंसिल',
    'lbl_pencil_done': 'पेंसिल (निर्जीव)',
    'lbl_plant': 'गमले का पौधा',
    'lbl_plant_done': 'गमले का पौधा (सजीव)',
    'lbl_car': 'खिलौना कार',
    'lbl_car_done': 'खिलौना कार (निर्जीव)',
    'lbl_sunflower': 'सूरजमुखी',
    'lbl_sunflower_done': 'सूरजमुखी (सजीव)',
    'sum_title_1': 'जीवन परीक्षण पूर्ण!',
    'sum_1':
        'हमने देखा कि सजीवों (जैसे कबूतर और पौधे) को ऊर्जा के लिए भोजन चाहिए, वे उत्तेजना पर प्रतिक्रिया देते हैं, उनमें वृद्धि होती है और वे प्रजनन करते हैं। निर्जीवों (जैसे पेंसिल और खिलौना कार) में ये जैविक प्रक्रियाएँ नहीं होतीं।',
    'next_1':
        'परिदृश्य 1 पूर्ण! आगे बढ़ने के लिए कृपया साइडबार से परिदृश्य 2 चुनें।',
    'sum_title_2': 'भ्रांति दूर हुई!',
    'sum_2':
        'गति का अर्थ हमेशा एक स्थान से दूसरे स्थान पर जाना (चलन) नहीं होता। कार इंजन (एक मशीन) से चलती है, पर वह निर्जीव है। सूरजमुखी जड़ों से ज़मीन में टिका रहता है, फिर भी सूरज की ओर मुड़कर और बढ़कर गति करता है (आंतरिक जैविक प्रक्रियाएँ)।',
    'next_2':
        'परिदृश्य 2 पूर्ण! आपने इस गतिविधि के दोनों परिदृश्यों का अवलोकन कर लिया है।',
    'tbl_title': 'सारांश तालिका',
    'tbl_living': 'सजीव',
    'tbl_nonliving': 'निर्जीव',
    'tbl_pigeon': 'कबूतर',
    'tbl_plant': 'पौधा',
    'tbl_pencil': 'पेंसिल',
    'tbl_car': 'कार',
    'tbl_food': 'भोजन चाहिए',
    'tbl_responds': 'प्रतिक्रिया',
    'tbl_grows': 'वृद्धि / प्रजनन',
    'tbl_yes': 'हाँ',
    'tbl_no': 'नहीं',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'गोल परीक्षण मंच, जिस पर कबूतर, पेंसिल, गमले के पौधे और खिलौना कार का परीक्षण होता है',
    'scene_s2': 'कार वाली एक सड़क, और आकाश के नीचे एक सूरजमुखी',
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

/// Scene labels: 13 design px, enlarged up to 1.8x on small stages so the
/// HTML's labels stay readable.
const double _labelPx = 13;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// While the sidebar is collapsed the scene slides right by this much
/// (design px), so the floating mission card at the top left leaves the
/// objects, their labels and the sun's path free.
const double _shiftS1 = 160;
const double _shiftS2 = 200;

/// The slide follows the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the sliding scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the slide.
const ValueKey<String> _sceneKey = ValueKey('ch10-a1-scene');

/// The Scenario 2 'Time-Lapse' card: its width (dp at UI scale 1) and the
/// band kept free for the HUD at the bottom while the sidebar is open (the
/// HUD chip is 8 dp from the bottom and about 56 dp tall at UI scale 1;
/// 12 + 58 dp per unit of UI scale leaves a small gap above it).
const double _sunCardWidth = 240;
const double _hudBandBase = 12;
const double _hudBandPerScale = 58;

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator -() => _V(-x, -y, -z);
  _V operator *(double k) => _V(x * k, y * k, z * k);

  /// Component-wise product (a non-uniform Three.js `scale`).
  _V mul(_V k) => _V(x * k.x, y * k.y, z * k.z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// Turned by [a] about the z axis (Three.js `rotation.z`).
  _V rotZ(double a) {
    if (a == 0) return this;
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  /// Turned by [a] about the x axis (Three.js `rotation.x`).
  _V rotX(double a) {
    if (a == 0) return this;
    final c = math.cos(a), s = math.sin(a);
    return _V(x, y * c - z * s, y * s + z * c);
  }

  /// Turned by [a] about the y axis (Three.js `rotation.y`).
  _V rotY(double a) {
    if (a == 0) return this;
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }
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

  /// Forward (`camera.getWorldDirection`), right and up.
  final _V f;
  final _V r;
  final _V u;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, (w - eye).dot(f));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }
}

/// Scenario 1 camera: the HTML `camera.position.set(0, 16, 38)` direction,
/// at 0.6 of its distance, looking at the middle of the platform scene
/// (0, 5.2, 0) instead of its floor, so the platform, the objects and the
/// highest effect (the sunbeam, 12.6 high) fill the stage.
final _Cam _camS1 = _Cam(
  const _V(0, 14.8, 22.8),
  const _V(0, 5.2, 0),
  const Offset(500, 290),
);

/// Scenario 2 camera: from the HTML side (0, 14, 45), set back and raised so
/// the road, the car's path, the grown sunflower and the sky above it fit
/// the picture, with the road clear of the 'Time-Lapse' card at the bottom
/// left.
final _Cam _camS2 = _Cam(
  const _V(0, 16, 64),
  const _V(0, 7, 0),
  const Offset(470, 215),
);

/// HTML `DirectionalLight(0xffffff, 0.9)` at (20, 40, 20), normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// HTML `AmbientLight(0xffffff, 0.65)` plus the key light, toned down so the
/// lit faces do not all clip to white.
const double _ambient = 0.62;
const double _diffuse = 0.5;

// ------------------------------------------------ scenario 1: test chamber

/// Platform `CylinderGeometry(5.5, 6.0, 1.2)` at the origin: top at y 0.6.
const double _platformTop = 0.6;

/// `pigeonGrp` stands on the platform: its feet are 0.4 above its origin,
/// so the origin is at 0.2 (the HTML put it at 0.6, floating). Idle
/// breathing (`sin(Date.now() * 0.005) * 0.1`): 5 rad/s, 0.1 high.
const double _pigeonY = _platformTop - 0.4;
const double _breathRate = 5;
const double _breathHeight = 0.1;

/// The chick (`buildPigeon(true)` at (2.5, 0.6, 1.5), `rotation.y` -0.5)
/// grows to `scale` 0.55; its feet stand on the platform.
const _V _chickAt = _V(2.5, _platformTop, 1.5);
const double _chickYaw = -0.5;
const double _chickScale = 0.55;

/// Added: the egg (0.35 × 0.45 × 0.35) the chick hatches from.
const _V _eggAt = _V(2.5, _platformTop + 0.45, 1.5);

/// Feeding the pigeon: the pellet falls from y 8 (HTML pellet1) onto the
/// platform in front of the pigeon, where its beak reaches when it bends.
/// The HTML turned the pigeon about its x axis (it rolled sideways); here
/// it pitches forward about its feet and lowers its head.
const _V _pellet1At = _V(4.4, _platformTop + 0.4, 0.2);
const double _pelletRadius = 0.4;
const double _pelletDropFrom = 8;
const double _peckPitch = 0.42;
const _V _peckHead = _V(0.5, -1.3, 0);
const _V _peckPivot = _V(0.5, 0.45, 0);

/// Feeding the pencil: the pellet falls from (0, 8, 0) onto the top of the
/// pencil, bounces and rolls off it to (-2, 1.0, 1.4) (HTML: to x -2).
const double _pencilY = _platformTop + 0.4;
const double _pencilRadius = 0.4;
const double _pencilHalf = 3;
const double _pellet2Top = _pencilY + _pencilRadius + _pelletRadius;
const _V _pellet2End = _V(-2, _platformTop + _pelletRadius, 1.4);

/// Touching the pigeon: it jumps 3.9 up (HTML y 0.6 → 4.5) and flaps
/// (HTML wings ±π/3 in 150 ms legs, six of them). The HTML turned the wings
/// about z, which tipped them like a seesaw; here they open about the
/// shoulder line.
const double _hopHeight = 3.9;
const double _flapMax = 2.2;
const double _flapLeg = 0.15;

/// Touching the pencil: it rolls 2.5 towards the viewer (the HTML stood it
/// on end and back, which is not rolling).
const double _pencilRollDistance = 2.5;

/// The potted plant: the pot (`CylinderGeometry(1.8, 1.2, 2.5)`) stands on
/// the platform; the stem, leaves and flower grow from the soil at its top
/// to (1.3, 1.4, 1.3) (the HTML scaled the pot as well).
const double _potHeight = 2.5;
const _V _soilAt = _V(0, _platformTop + _potHeight, 0);
const _V _plantGrowth = _V(0.3, 0.4, 0.3);

/// The toy car on the platform (`toyCarGrp` at (0, 0.6, 0)); its cabin
/// roof is 3.9 above its base.
const _V _toyCarAt = _V(0, _platformTop, 0);
const double _carRoof = 3.9;

/// `playWaterSunEffect`: the sunbeam `CylinderGeometry(1.5, 3.5, 12)` and
/// 20 drops starting 8–12 above the target, spread over 3 × 3.
const double _beamHeight = 12;
const double _beamTopRadius = 1.5;
const double _beamBottomRadius = 3.5;
const double _beamAlpha = 0.35;
const int _dropCount = 20;
const double _dropSpread = 3;
const double _dropRise = 8;
const double _dropRiseRange = 4;

/// Label anchors (world, the tip of the speech bubble's pointer). The HTML
/// put every label straight above its object; the pencil's, the plant's
/// and the car's are moved aside so the falling pellet and drops stay in
/// view.
const double _pigeonLabelRise = 7.9;
const _V _pencilLabelAt = _V(-2.2, 3.4, 0);
const _V _plantLabelAt = _V(-4.4, 6.4, 0);
const _V _carLabelAt = _V(-4.4, 5.4, 0);

// ------------------------------------------------- scenario 2: the road

/// `s2CarGrp` drives along the road (z 8) from x -8 to 17 and stays parked
/// there (the HTML drove it from -25 out of the picture and put it back).
const double _roadZ = 8;
const double _roadDepth = 16;
const double _carStartX = -8;
const double _carEndX = 17;
const double _wheelRadius = 0.9;

/// `s2SunflowerGrp` at (5, 0, -6): drawn at 0.8 of the HTML size so it
/// still fits the picture after growing to (1.4, 1.5, 1.4).
const _V _sunflowerAt = _V(5, 0, -6);
const double _sfModel = 0.8;
const _V _sfGrowth = _V(0.4, 0.5, 0.4);

/// HTML `updateSunPosition(val)`: slider -80 … 80, sun angle
/// `val / 80 * π / 2.5` from the zenith; the head turns by 0.75 of it
/// (`rotation.z = -angle * 0.75`) and, added, faces it by 0.8 of it.
const double _sunRange = 80;
const double _sunMaxAngle = math.pi / 2.5;
const double _leanFactor = 0.75;
const double _yawFactor = 0.8;

/// The sun's path in the sky, in design px: an arc round (470, 150), 200
/// wide and 105 high on each side (the HTML's 40-unit circle put the sun
/// above the picture for most of the way); sun radius 22.
const Offset _sunCentre = Offset(470, 150);
const double _sunRx = 200;
const double _sunRy = 105;
const double _sunPx = 22;

/// HTML steps: Scenario 2 step 2 ends past |30|, step 3 past |75|.
const double _sunStep2 = 30;
const double _sunStep3 = 75;

/// HTML `grow_7days`: `cycles` 0 → 14π in 2.5 s (seven days of the sun
/// swinging), then the sunflower grows (1 s, Elastic.Out).
const double _weekCycles = 14 * math.pi;

// ---------------------------------------------------------------- timings

/// Seconds. HTML values where it has them: pellet drop 600 (Bounce.Out),
/// bend 500 (Quadratic.Out), hold 1000, rise 500 (Quadratic.In); pencil
/// pellet roll 500; flap 6 × 150; jump 300 + 300; pencil roll 600
/// (Quadratic.Out); chick 1200 (Elastic.Out); sunbeam 400 / 600 / 800, drops
/// 700–1000 (Cubic.In), growth after 1200: plant 1500 (Quadratic.Out),
/// flower 1500 after 600 (Elastic.Out); car drive 2000 (Quadratic.InOut);
/// seven days 2500, sunflower 1000 (Elastic.Out). The hand's approach
/// (0.35 s), the egg, and the holds before the next step are added so each
/// result can be seen before the scene changes.
const double _dropSec = 0.6;
const double _bendStart = 0.25;
const double _bendSec = 0.5;
const double _bendHold = 1.0;
const double _riseSec = 0.5;
const double _biteStart = 1.25;
const double _biteSec = 0.3;
const double _feedPigeonEnd = 2.3;
const double _rollOffSec = 0.5;
const double _feedPencilEnd = 1.8;
const double _handIn = 0.35;
const double _handOut = 0.35;
const double _handHold = 0.15;
const double _hopSec = 0.3;
const double _touchPigeonEnd = 1.7;
const double _pencilRollSec = 0.6;
const double _touchPencilEnd = 1.6;
const double _eggSec = 0.35;
const double _hatchStart = 0.75;
const double _chickSec = 1.2;
const double _shellSec = 0.6;
const double _hatchEnd = 3.0;
const double _beamIn = 0.4;
const double _beamHold = 0.6;
const double _beamOut = 0.8;
const double _dropMinSec = 0.7;
const double _dropSecRange = 0.3;
const double _growStart = 1.2;
const double _plantGrowSec = 1.5;
const double _flowerDelay = 0.6;
const double _flowerSec = 1.5;
const double _waterPlantEnd = 4.2;
const double _wetStart = 0.7;
const double _wetSec = 0.5;
const double _waterCarEnd = 2.0;
const double _driveSec = 2.0;
const double _weekSec = 2.5;
const double _sfGrowSec = 1.0;

/// Progress 0 … 1 of the segment [start, start + seconds] at elapsed [e].
double _seg(double e, double start, double seconds) =>
    ((e - start) / seconds).clamp(0.0, 1.0).toDouble();

/// One falling drop of the Water & Sun effect (offsets from the target,
/// start height above the surface, fall time).
class _Drop {
  double dx = 0;
  double dz = 0;
  double rise = _dropRise;
  double seconds = _dropMinSec;
}

/// Mutable scene read by the painter every frame. Every animation is a
/// function of the scene time and of when its action started, so a reset
/// only clears those start times.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// An action's animation is running; the buttons wait.
  bool busy = false;

  /// 'Observe Summary & Conclusion' was tapped: the summary is open.
  bool done = false;

  // ---------------------------------------------- scenario 1 start times
  double? feedPigeonAt;
  double? feedPencilAt;
  double? touchPigeonAt;
  double? touchPencilAt;
  double? hatchAt;
  double? waterPlantAt;
  double? waterCarAt;
  final List<_Drop> drops = [for (var i = 0; i < _dropCount; i++) _Drop()];

  // ---------------------------------------------- scenario 2
  double? driveAt;
  double? weekAt;

  /// HTML `sun-slider` value (-80 … 80).
  double sunValue = 0;

  /// Seconds since [at], or -1 before it.
  double since(double? at) => at == null ? -1 : time - at;

  /// HTML `resetApp` / `changeScenario`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    feedPigeonAt = null;
    feedPencilAt = null;
    touchPigeonAt = null;
    touchPencilAt = null;
    hatchAt = null;
    waterPlantAt = null;
    waterCarAt = null;
    driveAt = null;
    weekAt = null;
    sunValue = 0;
  }

  /// New random drops for a Water & Sun effect.
  void scatterDrops(math.Random rnd) {
    for (final d in drops) {
      d
        ..dx = (rnd.nextDouble() - 0.5) * _dropSpread
        ..dz = (rnd.nextDouble() - 0.5) * _dropSpread
        ..rise = _dropRise + rnd.nextDouble() * _dropRiseRange
        ..seconds = _dropMinSec + rnd.nextDouble() * _dropSecRange;
    }
  }

  // --------------------------------------------- what is on the platform
  // HTML `updateSceneVisibility()`.

  bool get pigeonShown =>
      scenario == 0 && (step == 1 || step == 3 || step == 5);
  bool get pencilShown => scenario == 0 && (step == 2 || step == 4);
  bool get plantShown => scenario == 0 && step == 6;
  bool get toyCarShown => scenario == 0 && step >= 7;

  // ------------------------------------------------------- pigeon poses

  /// Idle breathing (HTML `animate()`), plus the jump when touched.
  double get pigeonY =>
      _pigeonY + (math.sin(time * _breathRate) + 1) / 2 * _breathHeight + hop;

  /// How far the pigeon is bent to the pellet: 0 upright … 1 eating.
  double get peck {
    final e = since(feedPigeonAt);
    if (e < 0) return 0;
    if (e < _bendStart + _bendSec) {
      return Curves.easeOutQuad.transform(_seg(e, _bendStart, _bendSec));
    }
    final rise = _bendStart + _bendSec + _bendHold;
    return 1 - Curves.easeInQuad.transform(_seg(e, rise, _riseSec));
  }

  /// The first pellet has been eaten.
  bool get pelletEaten => since(feedPigeonAt) >= _biteStart + _biteSec;

  /// First pellet: centre and size (0 when not shown).
  _V get pellet1 {
    final e = since(feedPigeonAt);
    final fall = Curves.bounceOut.transform(_seg(e, 0, _dropSec));
    return _V(
      _pellet1At.x,
      _pelletDropFrom + (_pellet1At.y - _pelletDropFrom) * fall,
      _pellet1At.z,
    );
  }

  double get pellet1Size {
    final e = since(feedPigeonAt);
    if (e < 0) return 0;
    return 1 - _seg(e, _biteStart, _biteSec);
  }

  /// Second pellet: lands on the pencil, then rolls off it.
  _V? get pellet2 {
    final e = since(feedPencilAt);
    if (e < 0) return null;
    if (e < _dropSec) {
      final fall = Curves.bounceOut.transform(_seg(e, 0, _dropSec));
      return _V(0, _pelletDropFrom + (_pellet2Top - _pelletDropFrom) * fall, 0);
    }
    final u = _seg(e, _dropSec, _rollOffSec);
    return _V(
      _pellet2End.x * u,
      _pellet2Top +
          (_pellet2End.y - _pellet2Top) * Curves.easeInQuad.transform(u),
      _pellet2End.z * u,
    );
  }

  double get pellet2Z => pellet2?.z ?? 0;
  double get pellet2Y => pellet2?.y ?? 0;

  /// The jump when touched (world units above the resting height).
  double get hop {
    final e = since(touchPigeonAt);
    if (e < _handIn) return 0;
    if (e < _handIn + _hopSec) {
      return _hopHeight *
          Curves.easeOutQuad.transform(_seg(e, _handIn, _hopSec));
    }
    return _hopHeight *
        (1 - Curves.easeInQuad.transform(_seg(e, _handIn + _hopSec, _hopSec)));
  }

  /// Wings open (0 folded … 1 fully open): three flaps after the touch.
  double get flap {
    final e = since(touchPigeonAt) - _handIn;
    if (e < 0 || e > 6 * _flapLeg) return 0;
    return (1 - math.cos(math.pi * e / _flapLeg)) / 2;
  }

  /// Added: the hand reaching in (0 … 1 = touching) for a touch action
  /// started at [at]; it stays [hold] seconds after the touch.
  double handReach(double? at, double hold) {
    final e = since(at);
    if (e < 0) return 0;
    if (e < _handIn) return Curves.easeOutCubic.transform(e / _handIn);
    return 1 - Curves.easeInCubic.transform(_seg(e, _handIn + hold, _handOut));
  }

  // --------------------------------------------------------- the pencil

  /// How far the pushed pencil has rolled towards the viewer.
  double get pencilZ {
    final e = since(touchPencilAt);
    if (e < 0) return 0;
    return _pencilRollDistance *
        Curves.easeOutQuad.transform(_seg(e, _handIn, _pencilRollSec));
  }

  /// Its turn about its own axis (rolling without slipping).
  double get pencilTurn => pencilZ / _pencilRadius;

  // --------------------------------------------------- the egg and chick

  /// Added: the egg grows in, wobbles, and hatches (0 when not shown).
  double get eggSize {
    final e = since(hatchAt);
    if (e < 0 || e >= _hatchStart) return 0;
    return Curves.easeOutBack.transform(_seg(e, 0, _eggSec));
  }

  double get eggWobble {
    final e = since(hatchAt);
    if (e < _eggSec || e >= _hatchStart) return 0;
    return 0.25 * math.sin((e - _eggSec) * 40);
  }

  /// The broken shell fades out after the hatching (1 … 0).
  double get shellAlpha {
    final e = since(hatchAt);
    if (e < _hatchStart) return 0;
    return 1 - _seg(e, _hatchStart, _shellSec);
  }

  /// HTML `chickGrp.scale` 0.01 → 0.55 (Elastic.Out), after the hatching.
  double get chickSize {
    final e = since(hatchAt);
    if (e < _hatchStart) return 0;
    return 0.01 +
        (_chickScale - 0.01) *
            Curves.elasticOut.transform(_seg(e, _hatchStart, _chickSec));
  }

  bool get hatched => since(hatchAt) >= _hatchStart + _chickSec;

  // ------------------------------------------------ water and sunlight

  /// Start of the Water & Sun effect on show (the plant in step 6, the toy
  /// car from step 7).
  double? get waterAt => step == 6 ? waterPlantAt : waterCarAt;

  /// Sunbeam opacity (0 … 0.35).
  double get beam {
    final e = since(waterAt);
    if (e < 0) return 0;
    if (e < _beamIn) {
      return _beamAlpha * Curves.easeOutQuad.transform(e / _beamIn);
    }
    return _beamAlpha * (1 - _seg(e, _beamIn + _beamHold, _beamOut));
  }

  /// Plant growth 0 … 1 (the stem part grows to (1.3, 1.4, 1.3)).
  double get plantGrowth {
    final e = since(waterPlantAt);
    if (e < 0) return 0;
    return Curves.easeOutQuad.transform(_seg(e, _growStart, _plantGrowSec));
  }

  /// HTML `plantFlower.scale` 0.001 → 1 (Elastic.Out).
  double get flowerSize {
    final e = since(waterPlantAt);
    if (e < 0) return 0.001;
    return 0.001 +
        0.999 *
            Curves.elasticOut.transform(
              _seg(e, _growStart + _flowerDelay, _flowerSec),
            );
  }

  /// Added: how wet the toy car is (0 … 1).
  double get wet => _seg(since(waterCarAt), _wetStart, _wetSec);

  // ---------------------------------------------------------- scenario 2

  /// HTML `s2CarGrp.position.x` (Quadratic.InOut drive).
  double get carX {
    final e = since(driveAt);
    if (e < 0) return _carStartX;
    return _carStartX +
        (_carEndX - _carStartX) *
            Curves.easeInOutQuad.transform(_seg(e, 0, _driveSec));
  }

  /// Wheel turn while driving (rolling without slipping).
  double get wheelTurn => (carX - _carStartX) / _wheelRadius;

  /// Added: dust settling on the parked car during the seven days (0 … 1).
  double get dust => _seg(since(weekAt), 0, _weekSec);

  /// HTML `s2SunflowerGrp.scale` → (1.4, 1.5, 1.4) (Elastic.Out), 0 … 1.
  double get sunflowerGrowth {
    final e = since(weekAt);
    if (e < _weekSec) return 0;
    return Curves.elasticOut.transform(_seg(e, _weekSec, _sfGrowSec));
  }

  /// The sun's angle from the zenith (HTML `updateSunPosition`).
  double get sunAngle => sunValue / _sunRange * _sunMaxAngle;

  /// The sunflower head's lean towards the sun (HTML `rotation.z`).
  double get flowerLean => _leanFactor * sunAngle;

  /// Added: the head also faces round towards the sun.
  double get flowerYaw => _yawFactor * sunAngle;

  /// The sun on the stage (design px, scene layer).
  Offset get sunPoint => Offset(
    _sunCentre.dx + _sunRx * math.sin(sunAngle),
    _sunCentre.dy - _sunRy * math.cos(sunAngle),
  );

  // ------------------------------------------------------- touch targets
  // Where the learner may tap the scene (design space); the QA flows read
  // them.

  /// The object the current step is about, or null.
  Offset? get focusPoint {
    if (scenario == 1) {
      return _camS2.p(_V(carX, 2, _roadZ));
    }
    if (pigeonShown) return _camS1.p(_V(0, pigeonY + 2.6, 0));
    if (pencilShown) return _camS1.p(_V(0, _pencilY, pencilZ));
    if (plantShown) return _camS1.p(_soilAt + const _V(0, 1.5, 0));
    if (toyCarShown) return _camS1.p(_toyCarAt + const _V(0, 2, 0));
    return null;
  }
}

class _LivingBeingsLabState
    extends State<Ch10A1CharacteristicsOfLivingBeingsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The 'Time-Lapse' slider's value: only its card rebuilds when it moves.
  final ValueNotifier<double> _sunShown = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Label size in design pixels for the current stage scale, and the tool
  /// column's left edge (set while laying out).
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// The step in which the current slider drag started.
  int _slideFromStep = 0;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]` of the current scenario.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

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
    _sunShown.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame advances the clock (and the sun during the seven days) and
  /// repaints the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    s.time = t;
    final week = s.since(s.weekAt);
    if (week >= 0) {
      // HTML `updateSunPosition(Math.sin(cycles.val) * 80)`.
      s.sunValue = week < _weekSec
          ? math.sin(_weekCycles * week / _weekSec) * _sunRange
          : 0;
      if (_sunShown.value != s.sunValue) _sunShown.value = s.sunValue;
    }
    _frame.value = t;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetApp()`: cancels every timer and
  /// animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _sunShown.value = 0;
    _lab.resetView(sound: false);
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

  /// Starts an action of step [step]: busy until [seconds] have passed,
  /// then the next step (HTML `checkS1Progress()` / `setStep`).
  void _run(int step, double seconds, VoidCallback start) {
    final s = _scene;
    if (s.busy || s.done || s.step != step) return;
    setState(() {
      s.busy = true;
      start();
    });
    _lab.after(Duration(milliseconds: (seconds * 1000).round()), () {
      if (!mounted || s.step != step) return;
      setState(() {
        s
          ..busy = false
          ..step = step + 1;
      });
    });
  }

  /// HTML `triggerConclusion()`: the summary popup (header "Success!", the
  /// scenario's summary and what comes next; Scenario 1 adds the table).
  void _conclude() {
    final s = _scene;
    final last = _stepCounts[s.scenario];
    if (s.busy || (!s.done && s.step != last)) return;
    setState(() => s.done = true);
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      heading: () => _t('sum_title_${sc + 1}'),
      body: () => '${_t('sum_${sc + 1}')}\n\n${_t('next_${sc + 1}')}',
      extra: sc == 0 ? () => _summaryTable(_lab.palette, 1) : null,
    );
  }

  // ------------------------------------------------- scenario 1 actions

  /// HTML `feed_pigeon`: the pellet drops, the pigeon bends and eats it.
  void _feedPigeon() => _run(1, _feedPigeonEnd, () {
    _Sound.woosh.play();
    _scene.feedPigeonAt = _scene.time;
  });

  /// HTML `feed_pencil`: the pellet bounces off the pencil and rolls away.
  void _feedPencil() => _run(2, _feedPencilEnd, () {
    _Sound.woosh.play();
    _scene.feedPencilAt = _scene.time;
  });

  /// HTML `touch_pigeon`: a hand touches the pigeon; it flaps and jumps.
  void _touchPigeon() => _run(3, _touchPigeonEnd, () {
    _Sound.flap.play();
    _scene.touchPigeonAt = _scene.time;
  });

  /// HTML `touch_pencil`: a hand pushes the pencil; it only rolls.
  void _touchPencil() => _run(4, _touchPencilEnd, () {
    _Sound.click.play();
    _scene.touchPencilAt = _scene.time;
  });

  /// HTML `timelapse_s1`: a month passes; an egg is laid and a chick hatches.
  void _timeLapse() => _run(5, _hatchEnd, () {
    _Sound.pop.play();
    _toast('toast_month');
    _scene.hatchAt = _scene.time;
  });

  /// HTML `water_plant` / `water_car`: the Water & Sun effect.
  void _water() {
    final s = _scene;
    final plant = s.step == 6;
    _run(s.step, plant ? _waterPlantEnd : _waterCarEnd, () {
      _Sound.woosh.play();
      _toast('toast_water');
      s.scatterDrops(_rnd);
      if (plant) {
        s.waterPlantAt = s.time;
      } else {
        s.waterCarAt = s.time;
      }
    });
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `drive_car`: the car drives along the road.
  void _drive() => _run(1, _driveSec, () {
    _Sound.click.play();
    _scene.driveAt = _scene.time;
  });

  /// HTML `grow_7days`: seven days pass; the sunflower grows.
  void _sevenDays() => _run(4, _weekSec + _sfGrowSec, () {
    _Sound.pop.play();
    _toast('toast_7days');
    _scene.weekAt = _scene.time;
  });

  /// HTML `#s2-slider-container`: the slider moves only in steps 2 and 3.
  bool get _sunEnabled {
    final s = _scene;
    return _lab.isLabActive &&
        s.scenario == 1 &&
        !s.busy &&
        !s.done &&
        (s.step == 2 || s.step == 3);
  }

  /// HTML `updateSunPosition(val)`: the sun and the sunflower's head follow
  /// the slider; past |30| ends step 2, past |75| step 3.
  void _onSun(double value) {
    final s = _scene;
    if (!_sunEnabled) return;
    s.sunValue = value;
    _sunShown.value = value;
    if (s.step == 2 && value.abs() > _sunStep2) {
      setState(() => s.step = 3);
    }
    if (s.step == 3 && value.abs() > _sunStep3) {
      setState(() => s.step = 4);
    }
  }

  void _onSunStart(double _) => _slideFromStep = _scene.step;

  /// Added: letting go of the slider too early says how far to go (the
  /// HTML waited silently).
  void _onSunEnd(double value) {
    final s = _scene;
    if (s.scenario != 1 || s.done || s.step != _slideFromStep) return;
    if (s.step == 2) {
      _toast('hint_slide_more', error: true, sound: true);
    } else if (s.step == 3) {
      _toast('hint_slide_end', error: true, sound: true);
    }
  }

  // -------------------------------------------------------------- gestures

  /// Added: a tap on the object of the current step repeats the step's task
  /// (the HTML scene ignored taps).
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done) return;
    final at = s.focusPoint;
    if (at == null) return;
    final cam = s.scenario == 0 ? _camS1 : _camS2;
    final reach = 3.2 * cam.scaleAt(const _V(0, 2, 0));
    if ((d.localPosition - at).distance <= math.max(reach, 40)) {
      _toast(_hudKey);
    }
  }

  // -------------------------------------------------------------------- UI

  /// The step's button (HTML `#ui-s1-controls`, `#ui-s2-controls` and the
  /// 'Observe Summary & Conclusion' button). The HTML showed all its tool
  /// buttons with only the current one lit and ignored taps on the others;
  /// here the current step's button is shown, labelled as its
  /// instruction names it.
  List<LabAction> _actions() {
    final s = _scene;
    LabAction tool(String key, IconData icon, VoidCallback onTap) => LabAction(
      label: _t(key),
      icon: icon,
      enabled: !s.busy,
      highlight: !s.busy,
      silent: true,
      onTap: onTap,
    );
    final conclude = LabAction(
      label: _t('btn_conclude'),
      icon: Icons.lightbulb,
      color: _Colors.teal600,
      foreground: _Colors.white,
      highlight: !s.done,
      // The summary plays the HTML `success` tone.
      silent: true,
      onTap: _conclude,
    );
    if (s.done || s.step == _stepCounts[s.scenario]) return [conclude];
    if (s.scenario == 0) {
      return [
        switch (s.step) {
          1 => tool('btn_feed_pigeon', Icons.grain, _feedPigeon),
          2 => tool('btn_feed_pencil', Icons.grain, _feedPencil),
          3 => tool('btn_touch_pigeon', Icons.back_hand, _touchPigeon),
          4 => tool('btn_touch_pencil', Icons.back_hand, _touchPencil),
          5 => tool('btn_timelapse', Icons.schedule, _timeLapse),
          _ => tool('btn_water', Icons.water_drop, _water),
        },
      ];
    }
    return [
      if (s.step == 1) tool('btn_go', Icons.play_arrow, _drive),
      if (s.step == 4) tool('btn_7days', Icons.schedule, _sevenDays),
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
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the summary
          // has been opened.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _sidebarExtra(p, f),
          overlays: _overlays(context, p),
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#ui-s2-controls` slider row: the 'Time-Lapse' card at the bottom
  /// left of the canvas (above the HUD while the sidebar is open), clear of
  /// the road, the sunflower and the sun's path.
  List<Widget> _overlays(BuildContext context, LabPalette p) {
    if (!_lab.isLabActive || _scene.scenario != 1) return const [];
    final s = context.labScale;
    final pad = MediaQuery.paddingOf(context);
    final inset = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    return [
      Positioned(
        key: const ValueKey('ch10a1-sun-card'),
        left: open ? inset.left : 8 + pad.left,
        bottom: open
            ? _hudBandBase + _hudBandPerScale * s + pad.bottom
            : inset.bottom,
        child: _SunCard(
          palette: p,
          scale: s,
          width: _sunCardWidth * s,
          label: _t('slider'),
          value: _sunShown,
          enabled: _sunEnabled,
          onChanged: _onSun,
          onChangeStart: _onSunStart,
          onChangeEnd: _onSunEnd,
        ),
      ),
    ];
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        final shift = _lab.isSidebarOpen
            ? 0.0
            : (_scene.scenario == 0 ? _shiftS1 : _shiftS2);
        if (fit > 0 && fit.isFinite) {
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          _labelRight =
              math.min(
                _design.width,
                (box.maxWidth - tools - stageLeft) / fit,
              ) -
              shift;
        }
        return LabStage(
          designSize: _design,
          // The slide moves the whole scene layer (painting and hit tests),
          // so taps arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(shift / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Taps on the scene are not screen-reader actions; the scene
                // is announced by its label instead.
                excludeFromSemantics: true,
                onTapUp: _onTap,
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
        );
      },
    );
  }

  /// Sidebar: the observations of the steps done so far (the HTML accordion
  /// showed each step's result before it was made) and, from Scenario 1
  /// step 8, the summary table (HTML step 8 accordion).
  Widget _sidebarExtra(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
    final table = s.scenario == 0 && (s.done || s.step == _stepCounts[0]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ObservationList(
          palette: p,
          scale: f,
          empty: _t('obs_empty'),
          entries: [
            for (var i = 1; i <= done; i++)
              (labFormat(_t('obs_step'), {'n': i}), steps[i - 1].observation),
          ],
        ),
        if (table) ...[SizedBox(height: 10 * f), _summaryTable(p, f)],
      ],
    );
  }

  /// HTML step 8 table: Needs Food / Responds / Grows-Reproduces for the
  /// pigeon and plant (living) and the pencil and car (non-living).
  Widget _summaryTable(LabPalette p, double f) => _SummaryTable(
    palette: p,
    scale: f,
    title: _t('tbl_title'),
    living: _t('tbl_living'),
    nonLiving: _t('tbl_nonliving'),
    columns: [
      _t('tbl_pigeon'),
      _t('tbl_plant'),
      _t('tbl_pencil'),
      _t('tbl_car'),
    ],
    rows: [_t('tbl_food'), _t('tbl_responds'), _t('tbl_grows')],
    yes: _t('tbl_yes'),
    no: _t('tbl_no'),
  );
}

/// HTML `#s2-slider-container`: sun icon, 'TIME-LAPSE', the slider
/// (-80 … 80, 0 = noon) and a moon icon. Faded while it is locked.
class _SunCard extends StatelessWidget {
  const _SunCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onChangeStart,
    required this.onChangeEnd,
  });

  final LabPalette palette;
  final double scale;
  final double width;
  final String label;
  final ValueListenable<double> value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    final fade = enabled ? 1.0 : 0.55;
    return LabGlassCard(
      palette: p,
      radius: 14,
      borderColor: p.accent.withValues(alpha: 0.4 * fade),
      padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 2 * s),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 13 * s,
                  color: p.accentInk.withValues(alpha: fade),
                ),
                SizedBox(width: 4 * s),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textMuted.withValues(alpha: fade),
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: labLetterSpacing(label, 0.8),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  size: 18 * s,
                  color: _Colors.amber500.withValues(alpha: fade),
                ),
                Expanded(
                  child: Semantics(
                    label: label,
                    child: SizedBox(
                      key: const ValueKey('ch10a1-sun-slider'),
                      height: kMinInteractiveDimension,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6 * s,
                          activeTrackColor: _Colors.amber500,
                          inactiveTrackColor: p.isDark
                              ? _Colors.slate700
                              : _Colors.slate300,
                          thumbColor: _Colors.white,
                          disabledActiveTrackColor: _Colors.amber500.withValues(
                            alpha: 0.4,
                          ),
                          disabledInactiveTrackColor: p.isDark
                              ? _Colors.slate700
                              : _Colors.slate300,
                          disabledThumbColor: _Colors.slate400,
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 18 * s,
                          ),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10 * s,
                            disabledThumbRadius: 9 * s,
                          ),
                          showValueIndicator: ShowValueIndicator.never,
                        ),
                        child: ValueListenableBuilder<double>(
                          valueListenable: value,
                          builder: (context, v, _) => Slider(
                            value: v.clamp(-_sunRange, _sunRange).toDouble(),
                            min: -_sunRange,
                            max: _sunRange,
                            onChanged: enabled ? onChanged : null,
                            onChangeStart: onChangeStart,
                            onChangeEnd: onChangeEnd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.nightlight_round,
                  size: 18 * s,
                  color: _Colors.indigo400.withValues(alpha: fade),
                ),
              ],
            ),
          ],
        ),
      ),
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

/// HTML step 8 summary table: a LIVING group (pigeon, plant) and a
/// NON-LIVING group (pencil, car), and a tick or a cross per characteristic.
class _SummaryTable extends StatelessWidget {
  const _SummaryTable({
    required this.palette,
    required this.scale,
    required this.title,
    required this.living,
    required this.nonLiving,
    required this.columns,
    required this.rows,
    required this.yes,
    required this.no,
  });

  final LabPalette palette;
  final double scale;
  final String title;
  final String living;
  final String nonLiving;

  /// Pigeon, plant (living), pencil, car (non-living).
  final List<String> columns;

  /// Needs food, responds, grows / reproduces.
  final List<String> rows;

  /// Screen-reader words for the tick and the cross.
  final String yes;
  final String no;

  /// Flex of the row-name column and of each object column.
  static const int _nameFlex = 3;
  static const int _cellFlex = 2;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final line = BorderSide(color: p.cardBorder);
    Widget cell(Widget child, {int flex = _cellFlex, Color? color}) => Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: color,
          border: Border(left: line),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
    Widget head(String text, Color color) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: 10 * f,
          fontWeight: FontWeight.w900,
          letterSpacing: labLetterSpacing(text, 0.8),
        ),
      ),
    );
    Widget mark(bool ok) => Semantics(
      label: ok ? yes : no,
      child: Container(
        width: 20 * f,
        height: 20 * f,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ok
              ? p.success.withValues(alpha: 0.2)
              : p.textMuted.withValues(alpha: 0.2),
        ),
        child: Icon(
          ok ? Icons.check : Icons.close,
          size: 13 * f,
          color: ok ? p.success : p.textMuted,
        ),
      ),
    );
    final livingInk = p.ink(_Colors.emerald600);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8 * f, 6 * f, 8 * f, 4 * f),
            child: Text(
              title,
              style: TextStyle(
                color: p.textStrong,
                fontSize: 11.5 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(border: Border(top: line)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: _nameFlex),
                  cell(
                    head(living, livingInk),
                    flex: 2 * _cellFlex,
                    color: _Colors.emerald500.withValues(alpha: 0.15),
                  ),
                  cell(
                    head(nonLiving, p.text),
                    flex: 2 * _cellFlex,
                    color: p.textMuted.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(border: Border(top: line)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: _nameFlex),
                  for (final c in columns)
                    cell(
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          c,
                          maxLines: 1,
                          style: TextStyle(
                            color: p.textStrong,
                            fontSize: 10.5 * f,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final r in rows)
            DecoratedBox(
              decoration: BoxDecoration(border: Border(top: line)),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: _nameFlex,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * f,
                          vertical: 5 * f,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            r,
                            style: TextStyle(
                              color: p.textStrong,
                              fontSize: 10.5 * f,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < columns.length; i++) cell(mark(i < 2)),
                  ],
                ),
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
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the static backdrop of
/// each scenario and the label text painters. Owned by the page state and
/// disposed with it.
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

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// What lies behind everything that moves: Scenario 1 the background and
  /// the platform, Scenario 2 the sky, the grass and the road.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (scenario == 0) {
      canvas.drawRect(
        labBleed(size),
        pens.fill..color = dark ? _Colors.canvasDark : _Colors.canvasLight,
      );
      _paintPlatform(canvas, pens);
    } else {
      _paintRoadBackdrop(canvas, pens, dark, size);
    }
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

/// Convex hull of [pts] (monotone chain), for the sunbeam's silhouette.
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

/// Segments of rims and discs (smooth enough at this size).
const int _ringSides = 24;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  _V get _eye => cam.eye;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Filled polygon through the projected [pts] (not lit).
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A thick line between two world points ([width] in world units).
  void line(_V a, _V b, double width, Color color) {
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      pens.stroke
        ..strokeWidth = math.max(1.0, width * cam.scaleAt(a))
        ..color = color,
    );
  }

  /// BoxGeometry centred at [c] with [size]: the faces seen by the camera,
  /// lit, with darker rims.
  void box(_V c, _V size, Color color, {double opacity = 1}) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = c + _V(n.x * hx, n.y * hy, n.z * hz);
      if (n.dot(_eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _V(k.x * hx, k.y * hy, k.z * hz)));
      }
      path.close();
      final fill = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = fill);
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: 0.35 * opacity),
      );
    }
  }

  /// A direction of the cross-section at [a] radians in the frame ([e1],
  /// [e2]).
  static _V _dir(_V e1, _V e2, double a) => e1 * math.cos(a) + e2 * math.sin(a);

  /// Two unit vectors at right angles to the unit vector [u].
  static (_V, _V) _frame(_V u) {
    final helper = u.y.abs() < 0.9 ? _V.up : _V.right;
    final e1 = u.cross(helper).unit;
    return (e1, u.cross(e1));
  }

  /// CylinderGeometry from [a] (radius [r0]) to [b] (radius [r1]); a cone
  /// when [r1] is 0. The facets turned to the camera are lit one by one,
  /// turned by [phase] about the axis; the ends are closed when they face
  /// the camera.
  void cylinder(
    _V a,
    _V b,
    double r0,
    double r1,
    Color color, {
    int sides = _ringSides,
    double phase = 0,
    double opacity = 1,
    bool caps = true,
    Color? capColor,
  }) {
    final axis = b - a;
    final h = axis.length;
    if (h < 1e-6) return;
    final u = axis * (1 / h);
    final (e1, e2) = _frame(u);
    final slope = (r0 - r1) / h;
    final step = 2 * math.pi / sides;
    for (var i = 0; i < sides; i++) {
      final a0 = phase + i * step;
      final a1 = a0 + step;
      final m = _dir(e1, e2, a0 + step / 2);
      final n = (m + u * slope).unit;
      final mid = a + u * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(_eye - mid) <= 0) continue;
      final d0 = _dir(e1, e2, a0);
      final d1 = _dir(e1, e2, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(a + d0 * r0));
      _to(path, 1, cam.p(a + d1 * r0));
      _to(path, 2, cam.p(b + d1 * r1));
      _to(path, 3, cam.p(b + d0 * r1));
      path.close();
      final c = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = c);
      if (opacity >= 1) canvas.drawPath(path, pens.seam..color = c);
    }
    if (!caps) return;
    final cap = capColor ?? color;
    if (r1 > 0 && u.dot(_eye - b) > 0) {
      _ring(b, r1, e1, e2, _lit(cap, u, opacity: opacity), sides, phase);
    }
    if (r0 > 0 && (-u).dot(_eye - a) > 0) {
      _ring(a, r0, e1, e2, _lit(cap, -u, opacity: opacity), sides, phase);
    }
  }

  void _ring(
    _V c,
    double r,
    _V e1,
    _V e2,
    Color color,
    int sides,
    double phase,
  ) {
    final path = pens.path..reset();
    for (var i = 0; i < sides; i++) {
      _to(
        path,
        i,
        cam.p(c + _dir(e1, e2, phase + i * 2 * math.pi / sides) * r),
      );
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A flat disc of radius [r] centred at [c], facing [normal] (not lit).
  void disc(_V c, double r, _V normal, Color color) {
    final (e1, e2) = _frame(normal.unit);
    _ring(c, r, e1, e2, color, _ringSides, 0);
  }

  /// Soft blurred shadow of an elliptic footprint on a surface at height
  /// [y].
  void shadow(double x, double z, double rx, double rz, {double y = 0}) {
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

  /// Ellipsoid (a scaled SphereGeometry) centred at [c] with semi-axes
  /// [a], [b], [d]: the projected outline (the image of the sphere under
  /// the projection's local linear map) filled in its lit colour, with a
  /// soft highlight towards the light.
  void ellipsoid(
    _V c,
    _V a,
    _V b,
    _V d,
    Color color, {
    double opacity = 1,
    bool highlight = true,
  }) {
    if (opacity <= 0) return;
    final p0 = cam.p(c);
    Offset img(_V v) => (cam.p(c + v) - cam.p(c - v)) / 2;
    final ia = img(a), ib = img(b), id = img(d);
    final sxx = ia.dx * ia.dx + ib.dx * ib.dx + id.dx * id.dx;
    final syy = ia.dy * ia.dy + ib.dy * ib.dy + id.dy * id.dy;
    final sxy = ia.dx * ia.dy + ib.dx * ib.dy + id.dx * id.dy;
    final half = (sxx - syy) / 2;
    final root = math.sqrt(half * half + sxy * sxy);
    final r1 = math.sqrt(math.max(0.0, (sxx + syy) / 2 + root));
    final r2 = math.sqrt(math.max(0.0, (sxx + syy) / 2 - root));
    if (r1 < 0.2) return;
    final theta = 0.5 * math.atan2(2 * sxy, sxx - syy);
    canvas.save();
    canvas.translate(p0.dx, p0.dy);
    canvas.rotate(theta);
    final oval = Rect.fromCenter(
      center: Offset.zero,
      width: 2 * r1,
      height: 2 * math.max(r2, 0.6),
    );
    canvas.drawOval(
      oval,
      pens.fill..color = _lit(color, const _V(0, 0.55, 0.84), opacity: opacity),
    );
    if (highlight) {
      // The light's direction on screen (up and to the left), in the
      // ellipse's own frame.
      final ct = math.cos(theta), st = math.sin(theta);
      const lx = -0.45, ly = -0.89;
      final hx = (lx * ct + ly * st) * 0.3 * r1;
      final hy = (-lx * st + ly * ct) * 0.3 * r2;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(hx, hy), width: r1, height: r2),
        pens.fill
          ..color = labShade(color, 0.35).withValues(alpha: 0.45 * opacity),
      );
    }
    canvas.drawOval(
      oval,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.45).withValues(alpha: 0.5 * opacity),
    );
    canvas.restore();
  }

  /// A sphere of radius [r] (an ellipsoid with equal axes).
  void sphere(_V c, double r, Color color, {double opacity = 1}) => ellipsoid(
    c,
    _V(r, 0, 0),
    _V(0, r, 0),
    _V(0, 0, r),
    color,
    opacity: opacity,
  );
}

/// Scenario 1's static platform: `CylinderGeometry(5.5, 6.0, 1.2)` and its
/// emerald glow ring (radius 5.6, 0.2 high, at y 0.5).
void _paintPlatform(Canvas canvas, _Pens pens) {
  final g = _Gfx(canvas, _camS1, pens);
  g.shadow(0, 0.4, 6.4, 6.2, y: -0.6);
  g.cylinder(
    const _V(0, -0.6, 0),
    const _V(0, _platformTop, 0),
    6,
    5.5,
    _Colors.platform,
    sides: 48,
    capColor: labShade(_Colors.platform, 0.12),
  );
  g.cylinder(
    const _V(0, 0.4, 0),
    const _V(0, _platformTop, 0),
    5.6,
    5.6,
    _Colors.platformGlow,
    sides: 48,
    caps: false,
  );
}

/// Scenario 2's static backdrop: a day sky, the grass to the horizon
/// (`PlaneGeometry(120, 60)`, extended) and the road (`PlaneGeometry(120,
/// 16)` at z 8, extended to the picture's edges).
void _paintRoadBackdrop(Canvas canvas, _Pens pens, bool dark, Size size) {
  final g = _Gfx(canvas, _camS2, pens);
  final bleed = labBleed(size);
  final horizon = _camS2.p(const _V(0, 0, -4000)).dy;
  // Sky: its top colour above the stage, then a gradient down to the
  // horizon.
  final skyTop = dark ? _Colors.skyTopDark : _Colors.skyTopLight;
  final skyLow = dark ? _Colors.skyLowDark : _Colors.skyLowLight;
  canvas.drawRect(
    Rect.fromLTRB(bleed.left, bleed.top, bleed.right, 1),
    pens.fill..color = skyTop,
  );
  final sky = Rect.fromLTRB(bleed.left, 0, bleed.right, horizon + 1);
  canvas.drawRect(
    sky,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyLow],
      ).createShader(sky),
  );
  // Grass: hazy at the horizon, its own colour from the sunflower forwards.
  final near = _camS2.p(_sunflowerAt).dy;
  final haze = Rect.fromLTRB(bleed.left, horizon, bleed.right, near);
  canvas.drawRect(
    haze,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_lit(_Colors.grassFar, _V.up), _lit(_Colors.grass, _V.up)],
      ).createShader(haze),
  );
  canvas.drawRect(
    Rect.fromLTRB(bleed.left, near - 1, bleed.right, bleed.bottom),
    pens.fill..color = _lit(_Colors.grass, _V.up),
  );
  const far = 300.0;
  const z0 = _roadZ - _roadDepth / 2, z1 = _roadZ + _roadDepth / 2;
  g.poly(const [
    _V(-far, 0, z0),
    _V(far, 0, z0),
    _V(far, 0, z1),
    _V(-far, 0, z1),
  ], _lit(_Colors.road, _V.up));
  for (final z in const [z0 + 0.3, z1 - 0.3]) {
    g.line(_V(-far, 0, z), _V(far, 0, z), 0.15, _Colors.roadEdge);
  }
}

/// How a bird (the pigeon or the chick) stands and moves: where its origin
/// is, how it is turned and scaled, how far it bends to peck and how far
/// its wings are open.
@immutable
class _BirdPose {
  const _BirdPose({
    required this.at,
    this.yaw = 0,
    this.scale = 1,
    this.peck = 0,
    this.flap = 0,
    this.chick = false,
  });

  final _V at;
  final double yaw;
  final double scale;
  final double peck;
  final double flap;
  final bool chick;

  /// The head's offset when bent (head parts only).
  _V get _headShift => _peckHead * peck;

  /// A bird-space point in the world. [head] points follow the lowered
  /// head; [neck] points follow it half way.
  _V point(_V p, {double head = 0}) {
    final q = p + _headShift * head;
    final pitched = (q - _peckPivot).rotZ(-_peckPitch * peck) + _peckPivot;
    return at + (pitched * scale).rotY(yaw);
  }

  /// A bird-space direction (semi-axis) in the world.
  _V vec(_V v) => (v.rotZ(-_peckPitch * peck) * scale).rotY(yaw);
}

/// Paints the HTML Three.js scene of the current scenario: S1 the test
/// platform with the object of the step, S2 the road, the car, the
/// sunflower and the sun.
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
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintChamber(canvas);
    } else {
      _paintRoad(canvas);
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _paintChamber(Canvas canvas) {
    final g = _Gfx(canvas, _camS1, _pens);
    final s = scene;
    if (s.pigeonShown) {
      _paintPigeonStep(g);
    } else if (s.pencilShown) {
      _paintPencilStep(g);
    } else if (s.plantShown) {
      _paintPlant(g);
      _paintWaterSun(g, _soilAt.y);
    } else if (s.toyCarShown) {
      _paintCar(g, _toyCarAt, wet: s.wet);
      _paintWaterSun(g, _toyCarAt.y + _carRoof);
    }
    if (!showLabels) return;
    if (s.pigeonShown) {
      _chip(
        canvas,
        _camS1.p(_V(0, s.pigeonY + _pigeonLabelRise, 0)),
        _t(s.hatched ? 'lbl_pigeon_done' : 'lbl_pigeon'),
      );
    } else if (s.pencilShown) {
      final rolled = s.since(s.touchPencilAt) >= _handIn + _pencilRollSec;
      _chip(
        canvas,
        _camS1.p(_pencilLabelAt),
        _t(rolled ? 'lbl_pencil_done' : 'lbl_pencil'),
      );
    } else if (s.plantShown) {
      final grown = s.plantGrowth >= 1;
      _chip(
        canvas,
        _camS1.p(_plantLabelAt),
        _t(grown ? 'lbl_plant_done' : 'lbl_plant'),
      );
    } else if (s.toyCarShown) {
      _chip(
        canvas,
        _camS1.p(_carLabelAt),
        _t(s.step >= 8 ? 'lbl_car_done' : 'lbl_car'),
      );
    }
  }

  /// Steps 1, 3 and 5: the pigeon (with the pellet, the hand, or the egg
  /// and the chick).
  void _paintPigeonStep(_Gfx g) {
    final s = scene;
    final lift = s.hop;
    g.shadow(0.3, 0, 2.6 - 0.25 * lift, 1.5 - 0.15 * lift, y: _platformTop);
    final pelletSize = s.pellet1Size;
    if (pelletSize > 0) {
      g.shadow(_pellet1At.x, _pellet1At.z, 0.45, 0.35, y: _platformTop);
      g.sphere(s.pellet1, _pelletRadius * pelletSize, _Colors.pellet);
    }
    _paintBird(
      g,
      _BirdPose(at: _V(0, s.pigeonY, 0), peck: s.peck, flap: s.flap),
    );
    final eggSize = s.eggSize;
    if (eggSize > 0) {
      g.shadow(
        _eggAt.x,
        _eggAt.z,
        0.4 * eggSize,
        0.3 * eggSize,
        y: _platformTop,
      );
      final w = s.eggWobble;
      g.ellipsoid(
        _eggAt + const _V(0, -0.45, 0) + _V(0, 0.45, 0) * eggSize,
        const _V(0.35, 0, 0).rotZ(w) * eggSize,
        const _V(0, 0.45, 0).rotZ(w) * eggSize,
        const _V(0, 0, 0.35) * eggSize,
        _Colors.egg,
      );
    }
    final chick = s.chickSize;
    if (chick > 0.02) {
      g.shadow(
        _chickAt.x,
        _chickAt.z,
        1.4 * chick,
        0.9 * chick,
        y: _platformTop,
      );
      // Its feet stay on the platform while it grows.
      _paintBird(
        g,
        _BirdPose(
          at: _V(_chickAt.x, _platformTop - 0.4 * chick, _chickAt.z),
          yaw: _chickYaw,
          scale: chick,
          chick: true,
        ),
      );
    }
    final shell = s.shellAlpha;
    if (shell > 0) _paintShell(g, shell);
    final reach = s.handReach(s.touchPigeonAt, _handHold);
    if (reach > 0) {
      final tip = _camS1.p(_V(-0.6, _pigeonY + 3.9, 0.9));
      _paintHand(g.canvas, tip, const Offset(0.75, 0.66), 28, reach);
    }
  }

  /// Added: the broken eggshell at the chick's feet, fading out.
  void _paintShell(_Gfx g, double alpha) {
    final c = _camS1.p(_eggAt + const _V(0.6, -0.25, 0.4));
    final k = _camS1.scaleAt(_eggAt);
    final rx = 0.35 * k, ry = 0.3 * k;
    final path = _pens.path..reset();
    path.moveTo(c.dx - rx, c.dy);
    path.arcToPoint(
      Offset(c.dx + rx, c.dy),
      radius: Radius.elliptical(rx, ry),
      clockwise: false,
    );
    const teeth = 5;
    for (var i = 1; i <= teeth; i++) {
      final x = c.dx + rx - 2 * rx * i / teeth;
      path.lineTo(x, c.dy - (i.isOdd ? ry * 0.45 : 0));
    }
    path.close();
    g.canvas.drawPath(
      path,
      _pens.fill..color = _Colors.egg.withValues(alpha: alpha),
    );
    g.canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate400.withValues(alpha: alpha),
    );
  }

  /// `buildPigeon(isSmall)`: body, tail, neck, head with beak, cere and
  /// eyes, wings and legs, drawn far to near.
  void _paintBird(_Gfx g, _BirdPose b) {
    final chick = b.chick;
    final body = chick ? _Colors.chickBody : _Colors.pigeonBody;
    final wing = chick ? _Colors.chickWing : _Colors.pigeonWing;
    final neck = chick ? _Colors.chickBody : _Colors.pigeonNeck;
    final legs = chick ? _Colors.chickLegs : _Colors.pigeonLegs;
    final tail = chick ? _Colors.chickWing : _Colors.pigeonTail;

    _paintWing(g, b, -1, wing);
    // Tail: the HTML cone (radius 1, 2.5 long, turned π / 2.5, flattened)
    // as a flat fan from the body backwards.
    const along = _V(-0.951, 0.309, 0);
    const across = _V(0.309, 0.951, 0);
    const tailMid = _V(-2.2, 2.3, 0);
    final root = tailMid - along * 1.25;
    final end = tailMid + along * 1.25;
    g.poly([
      b.point(root + across * 0.45),
      b.point(end + across * 0.75),
      b.point(end - across * 0.75),
      b.point(root - across * 0.45),
    ], _lit(tail, _V.front));
    _paintLeg(g, b, -0.4, legs);
    g.ellipsoid(
      b.point(const _V(0, 2.5, 0)),
      b.vec(const _V(2.24, 0, 0)),
      b.vec(const _V(0, 1.6, 0)),
      b.vec(const _V(0, 0, 1.6)),
      body,
    );
    _paintLeg(g, b, 0.4, legs);
    // Neck `CylinderGeometry(0.8, 1.2, 1.5)` turned -0.3 about z.
    const neckAxis = _V(0.2955, 0.9553, 0);
    g.cylinder(
      b.point(const _V(1.6, 3.2, 0) - neckAxis * 0.75, head: 0.15),
      b.point(const _V(1.6, 3.2, 0) + neckAxis * 0.75, head: 0.6),
      1.2 * b.scale,
      0.8 * b.scale,
      neck,
      sides: 16,
    );
    const head = _V(2.2, 4.0, 0);
    g.sphere(b.point(head, head: 1), 0.9 * b.scale, body);
    if (!chick) {
      g.ellipsoid(
        b.point(head + const _V(0.7, 0.1, 0), head: 1),
        b.vec(const _V(0.2, 0, 0)),
        b.vec(const _V(0, 0.2, 0)),
        b.vec(const _V(0, 0, 0.24)),
        _Colors.cere,
        highlight: false,
      );
    }
    // Beak `ConeGeometry(0.25, 0.8)` pointing forwards.
    g.cylinder(
      b.point(head + const _V(0.6, -0.1, 0), head: 1),
      b.point(head + const _V(1.4, -0.1, 0), head: 1),
      0.25 * b.scale,
      0,
      _Colors.beak,
      sides: 12,
    );
    // The near eye (the far one is behind the head) and its yellow rim.
    final eye = b.point(head + const _V(0.4, 0.2, 0.45), head: 1);
    final eyeAt = _camS1.p(eye);
    final k = _camS1.scaleAt(eye) * b.scale;
    if (!chick) {
      g.canvas.drawCircle(eyeAt, 0.17 * k, _pens.fill..color = _Colors.eyeRim);
    }
    g.canvas.drawCircle(eyeAt, 0.12 * k, _pens.fill..color = _Colors.eye);
    _paintWing(g, b, 1, wing);
  }

  /// A leg (`CylinderGeometry(0.08, 0.08, 1.2)` at (0.4, 1.0, ±0.4)) and
  /// its foot (0.6 × 0.1 × 0.4 at (0.6, 0.45, ±0.4)).
  void _paintLeg(_Gfx g, _BirdPose b, double z, Color color) {
    g.line(
      b.point(_V(0.4, 0.4, z)),
      b.point(_V(0.4, 1.6, z)),
      0.16 * b.scale,
      _lit(color, _V.front),
    );
    g.line(
      b.point(_V(0.3, 0.45, z)),
      b.point(_V(0.9, 0.45, z)),
      0.14 * b.scale,
      _lit(color, _V.up),
    );
  }

  /// A wing (`SphereGeometry(1.6)` scaled (1.3, 0.4, 0.2) hanging from the
  /// shoulder at (−0.2, 3.1, ±1)); [side] −1 far, 1 near. It opens outwards
  /// and upwards about the shoulder line as the pigeon flaps.
  void _paintWing(_Gfx g, _BirdPose b, double side, Color color) {
    final open = -side * _flapMax * b.flap;
    final hinge = _V(-0.2, 3.1, side);
    final spread = 1 + 0.6 * b.flap;
    final centre = hinge + const _V(0, -0.5, 0).rotX(open);
    g.ellipsoid(
      b.point(centre),
      b.vec(const _V(2.08, 0, 0).rotZ(-0.1)),
      b.vec(_V(0, 0.64 * spread, 0).rotX(open)),
      b.vec(const _V(0, 0, 0.32).rotX(open)),
      color,
    );
  }

  /// Added: a hand whose fingertip reaches [tip] along [dir] (design px,
  /// [size] the finger's length); [reach] 0 … 1 slides it in.
  void _paintHand(
    Canvas canvas,
    Offset tip,
    Offset dir,
    double size,
    double reach,
  ) {
    final d = dir / dir.distance;
    final at = tip - d * (size * 4 * (1 - reach));
    final alpha = reach.clamp(0.0, 1.0).toDouble();
    final skinColor = _Colors.skin.withValues(alpha: alpha);
    Paint skin() => _pens.fill..color = skinColor;
    final outline = _pens.stroke
      ..strokeWidth = 1.4
      ..color = _Colors.skinLine.withValues(alpha: alpha);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(math.atan2(d.dy, d.dx));
    // Sleeve, palm, curled fingers, thumb and the pointing finger.
    final sleeve = Rect.fromLTWH(-size * 3.1, -size * 0.55, size, size * 1.15);
    canvas.drawRect(
      sleeve,
      _pens.fill..color = _Colors.sleeve.withValues(alpha: alpha),
    );
    final palm = RRect.fromRectAndRadius(
      Rect.fromLTWH(-size * 2.2, -size * 0.5, size * 1.35, size * 1.05),
      Radius.circular(size * 0.35),
    );
    canvas.drawRRect(palm, skin());
    canvas.drawRRect(palm, outline);
    for (var i = 0; i < 3; i++) {
      final knuckle = Rect.fromCenter(
        center: Offset(-size * 0.95, size * (0.05 + 0.2 * i)),
        width: size * 0.42,
        height: size * 0.24,
      );
      canvas.drawOval(knuckle, skin());
      canvas.drawOval(knuckle, outline);
    }
    final thumb = Rect.fromCenter(
      center: Offset(-size * 1.2, -size * 0.55),
      width: size * 0.7,
      height: size * 0.28,
    );
    canvas.drawOval(thumb, skin());
    canvas.drawOval(thumb, outline);
    final finger = RRect.fromRectAndRadius(
      Rect.fromLTWH(-size * 1.05, -size * 0.32, size * 1.05, size * 0.3),
      Radius.circular(size * 0.15),
    );
    canvas.drawRRect(finger, skin());
    canvas.drawRRect(finger, outline);
    canvas.restore();
  }

  /// Steps 2 and 4: `buildPencil()` (a hexagonal body, the sharpened wood
  /// and the lead), the pellet and the hand.
  void _paintPencilStep(_Gfx g) {
    final s = scene;
    final z = s.pencilZ;
    final turn = s.pencilTurn;
    g.shadow(0.5, z, 3.9, 0.55, y: _platformTop);
    final pellet = s.pellet2;
    g.cylinder(
      _V(-_pencilHalf, _pencilY, z),
      _V(_pencilHalf, _pencilY, z),
      _pencilRadius,
      _pencilRadius,
      _Colors.pencil,
      sides: 6,
      phase: turn + math.pi / 6,
    );
    g.cylinder(
      _V(_pencilHalf, _pencilY, z),
      _V(_pencilHalf + 1.2, _pencilY, z),
      _pencilRadius,
      0,
      _Colors.pencilWood,
      sides: 6,
      phase: turn + math.pi / 6,
    );
    g.cylinder(
      _V(_pencilHalf + 0.8, _pencilY, z),
      _V(_pencilHalf + 1.2, _pencilY, z),
      0.13,
      0,
      _Colors.lead,
      sides: 6,
      phase: turn + math.pi / 6,
    );
    // The pellet falls onto the pencil and rolls off towards the viewer, so
    // it is always in front of it.
    if (pellet != null) {
      if (pellet.z > 1) {
        g.shadow(pellet.x, pellet.z, 0.45, 0.35, y: _platformTop);
      }
      g.sphere(pellet, _pelletRadius, _Colors.pellet);
    }
    final reach = s.handReach(s.touchPencilAt, _pencilRollSec);
    if (reach > 0) {
      final tip = _camS1.p(_V(0.6, _pencilY + _pencilRadius, z - 0.2));
      _paintHand(g.canvas, tip, const Offset(0.25, 1), 28, reach);
    }
  }

  /// Step 6: `buildPottedPlant()`: the pot, the soil, and the stem, leaves
  /// and flower growing from the soil.
  void _paintPlant(_Gfx g) {
    final s = scene;
    g.shadow(0, 0, 1.6, 1.3, y: _platformTop);
    g.cylinder(
      const _V(0, _platformTop, 0),
      _soilAt,
      1.2,
      1.8,
      _Colors.pot,
      sides: 28,
      capColor: _Colors.soil,
    );
    final k = const _V(1, 1, 1) + _plantGrowth * s.plantGrowth;
    _V at(_V local) => _soilAt + local.mul(k);
    g.cylinder(
      _soilAt,
      at(const _V(0, 4, 0)),
      0.2 * k.x,
      0.15 * k.x,
      _Colors.stem,
      sides: 12,
    );
    for (final (x, y, turn) in const [(1.0, 1.0, -0.4), (-1.0, 2.5, 0.4)]) {
      g.ellipsoid(
        at(_V(x, y, 0)),
        const _V(1.5, 0, 0).rotZ(turn).mul(k),
        const _V(0, 0.1, 0).rotZ(turn).mul(k),
        const _V(0, 0, 0.6).mul(k),
        _Colors.leaf,
      );
    }
    final f = s.flowerSize * k.x;
    if (f > 0.01) {
      final c = at(const _V(0, 4, 0));
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final r = _V(math.cos(a), math.sin(a), 0);
        g.ellipsoid(
          c + r * (0.7 * f),
          r * (0.5 * f),
          _V(-r.y, r.x, 0) * (0.25 * f),
          const _V(0, 0, 0.05) * f,
          _Colors.petal,
        );
      }
      g.cylinder(
        c,
        c + const _V(0, 0, 0.2) * f,
        0.5 * f,
        0.5 * f,
        _Colors.flowerCentre,
        sides: 16,
      );
    }
  }

  /// `buildToyCar()` at [at]: tyres and rims, the body, the cabin with its
  /// windows; [wet] adds a wet shine (Scenario 1), [dust] dust (Scenario
  /// 2), [wheelTurn] turns the rims.
  void _paintCar(
    _Gfx g,
    _V at, {
    double wet = 0,
    double dust = 0,
    double wheelTurn = 0,
  }) {
    final cam = g.cam;
    g.shadow(at.x, at.z, 3.9, 2.1, y: at.y);
    void wheel(double x, double z) {
      final near = z > 0;
      final inner = at + _V(x, _wheelRadius, z - (near ? 0.3 : -0.3));
      final outer = at + _V(x, _wheelRadius, z + (near ? 0.3 : -0.3));
      g.cylinder(
        inner,
        outer,
        _wheelRadius,
        _wheelRadius,
        _Colors.tyre,
        sides: 20,
      );
      if (!near) return;
      final hub = outer + const _V(0, 0, 0.02);
      g.disc(hub, 0.5, _V.front, _lit(_Colors.rim, _V.front));
      final k = cam.scaleAt(hub);
      final c = cam.p(hub);
      final spoke = _pens.stroke
        ..strokeWidth = math.max(1.0, 0.08 * k)
        ..color = _Colors.slate500;
      for (var i = 0; i < 2; i++) {
        final a = -wheelTurn + i * math.pi / 2;
        final o = Offset(math.cos(a), math.sin(a)) * (0.45 * k);
        g.canvas.drawLine(c - o, c + o, spoke);
      }
    }

    wheel(-2.2, -1.8);
    wheel(2.2, -1.8);
    final body = Color.lerp(_Colors.carBody, _Colors.dust, 0.45 * dust)!;
    final roof = Color.lerp(_Colors.carRoof, _Colors.dust, 0.45 * dust)!;
    g.box(at + const _V(0, 1.6, 0), const _V(7, 1.8, 3.4), body);
    g.box(at + const _V(-0.4, 3.2, 0), const _V(3.6, 1.4, 3), roof);
    // Windscreen on the cabin's front (seen when the car is left of the
    // camera) and, added, the near side window.
    if (cam.eye.x > at.x + 1.4) {
      g.poly([
        at + const _V(1.41, 2.65, -1.3),
        at + const _V(1.41, 2.65, 1.3),
        at + const _V(1.41, 3.75, 1.3),
        at + const _V(1.41, 3.75, -1.3),
      ], _lit(_Colors.carGlass, _V.right));
    }
    g.poly([
      at + const _V(-1.9, 2.75, 1.51),
      at + const _V(1.1, 2.75, 1.51),
      at + const _V(1.1, 3.7, 1.51),
      at + const _V(-1.9, 3.7, 1.51),
    ], _lit(_Colors.carGlass, _V.front));
    wheel(-2.2, 1.8);
    wheel(2.2, 1.8);
    if (wet > 0) {
      final shine = _pens.stroke
        ..strokeWidth = math.max(1.5, 0.12 * cam.scaleAt(at))
        ..color = _Colors.wetShine.withValues(alpha: 0.7 * wet);
      for (final (y, z) in const [(2.45, 1.71), (3.9, 0.9), (3.9, -0.6)]) {
        g.canvas.drawLine(
          cam.p(at + _V(-3.0, y, z)),
          cam.p(at + _V(2.8, y, z)),
          shine,
        );
      }
      final bead = _pens.fill
        ..color = _Colors.drop.withValues(alpha: 0.8 * wet);
      for (var i = 0; i < 9; i++) {
        final p = cam.p(at + _V(-2 + 0.45 * i, 3.91, -1 + 0.25 * (i % 4)));
        g.canvas.drawCircle(p, math.max(1.2, 0.1 * cam.scaleAt(at)), bead);
      }
    }
    if (dust > 0) {
      final speck = _pens.fill
        ..color = _Colors.dust.withValues(alpha: 0.85 * dust);
      final r = math.max(1.0, 0.09 * cam.scaleAt(at));
      for (var i = 0; i < _dustSpecks.length; i++) {
        final (u, v) = _dustSpecks[i];
        final p = i.isEven
            ? at + _V(u * 3.4, 1.6 + v * 0.8, 1.72)
            : at + _V(u * 3.4, 2.51, v * 1.6);
        g.canvas.drawCircle(cam.p(p), r, speck);
      }
    }
  }

  /// `playWaterSunEffect`: the sunbeam over the object and the falling
  /// drops, which stop on the surface at [surface] (the soil, the roof).
  void _paintWaterSun(_Gfx g, double surface) {
    final s = scene;
    final e = s.since(s.waterAt);
    if (e < 0) return;
    final beam = s.beam;
    if (beam > 0.005) {
      final bottom = <Offset>[];
      for (var i = 0; i < _ringSides; i++) {
        final a = i * 2 * math.pi / _ringSides;
        bottom
          ..add(
            _camS1.p(
              _V(
                math.cos(a) * _beamBottomRadius,
                _platformTop,
                math.sin(a) * _beamBottomRadius,
              ),
            ),
          )
          ..add(
            _camS1.p(
              _V(
                math.cos(a) * _beamTopRadius,
                _platformTop + _beamHeight,
                math.sin(a) * _beamTopRadius,
              ),
            ),
          );
      }
      final hull = _hull(bottom);
      final path = _pens.path..reset();
      for (var i = 0; i < hull.length; i++) {
        if (i == 0) {
          path.moveTo(hull[i].dx, hull[i].dy);
        } else {
          path.lineTo(hull[i].dx, hull[i].dy);
        }
      }
      path.close();
      g.canvas.drawPath(
        path,
        _pens.fill..color = _Colors.sunbeam.withValues(alpha: beam),
      );
    }
    final paint = _pens.fill..color = _Colors.drop.withValues(alpha: 0.8);
    for (final d in s.drops) {
      if (e >= d.seconds) continue;
      final u = Curves.easeInCubic.transform(e / d.seconds);
      final y = surface + d.rise * (1 - u);
      final w = _V(d.dx, y, d.dz);
      final k = _camS1.scaleAt(w);
      g.canvas.drawOval(
        Rect.fromCenter(
          center: _camS1.p(w),
          width: math.max(2.0, 0.24 * k),
          height: math.max(3.5, 0.5 * k),
        ),
        paint,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintRoad(Canvas canvas) {
    final g = _Gfx(canvas, _camS2, _pens);
    final s = scene;
    // The sun (`SphereGeometry(3.5)`, emissive) and its glow; the moon of
    // the HTML always stayed below the ground and is not drawn.
    final sun = s.sunPoint;
    canvas.drawCircle(sun, _sunPx * 1.7, _pens.glow..color = _Colors.sunGlow);
    canvas.drawCircle(sun, _sunPx, _pens.fill..color = _Colors.sun);
    canvas.drawCircle(
      sun + const Offset(-_sunPx * 0.25, -_sunPx * 0.25),
      _sunPx * 0.55,
      _pens.fill..color = labShade(_Colors.sun, 0.45).withValues(alpha: 0.7),
    );
    _paintSunflower(g);
    _paintCar(g, _V(s.carX, 0, _roadZ), dust: s.dust, wheelTurn: s.wheelTurn);
    if (!showLabels) return;
    final rise = 1 + _sfGrowth.y * s.sunflowerGrowth;
    _chip(
      canvas,
      _camS2.p(_sunflowerAt + _V(-7 * _sfModel, 4 * _sfModel * rise, 0)),
      _t(s.step >= 5 || s.done ? 'lbl_sunflower_done' : 'lbl_sunflower'),
    );
  }

  /// `buildSunflower()` at 0.8 size: the stem, two leaves and the head (a
  /// brown disc in a ring of 16 yellow petals), which leans and turns
  /// towards the sun and grows in the seven days.
  void _paintSunflower(_Gfx g) {
    final s = scene;
    final k = (const _V(1, 1, 1) + _sfGrowth * s.sunflowerGrowth) * _sfModel;
    _V at(_V local) => _sunflowerAt + local.mul(k);
    g.shadow(_sunflowerAt.x, _sunflowerAt.z, 2.2 * k.x, 1.4 * k.z);
    final top = at(const _V(0, 11, 0));
    g.cylinder(
      _sunflowerAt,
      top,
      0.45 * k.x,
      0.35 * k.x,
      _Colors.sfStem,
      sides: 14,
    );
    for (final (x, y, turn) in const [(2.0, 4.0, -0.3), (-2.0, 7.0, 0.3)]) {
      g.ellipsoid(
        at(_V(x, y, 0)),
        const _V(3, 0, 0).rotZ(turn).mul(k),
        const _V(0, 0.2, 0).rotZ(turn).mul(k),
        const _V(0, 0, 1.6).mul(k),
        _Colors.sfLeaf,
      );
    }
    // The head: centred a short neck above the stem, turned by the lean
    // (about z) and the yaw (about y) towards the sun.
    final lean = s.flowerLean;
    final yaw = s.flowerYaw;
    final h = k.x;
    _V turned(_V v) => v.rotZ(-lean).rotY(yaw);
    final ex = turned(_V.right);
    final ey = turned(_V.up);
    final nrm = turned(_V.front);
    final centre = top + const _V(0, 1.1, 0).rotZ(-lean) * h;
    final facing = nrm.dot(_camS2.eye - centre) > 0;
    void petals() {
      for (var i = 0; i < 16; i++) {
        final a = i * 2 * math.pi / 16;
        final r = ex * math.cos(a) + ey * math.sin(a);
        final t = ex * -math.sin(a) + ey * math.cos(a);
        g.ellipsoid(
          centre + r * (3.2 * h) - nrm * (0.2 * h),
          r * (2.16 * h),
          t * (0.72 * h),
          nrm * (0.18 * h),
          _Colors.sfPetal,
        );
      }
    }

    void disc() {
      g.cylinder(
        centre - nrm * (0.3 * h),
        centre + nrm * (0.3 * h),
        2.4 * h,
        2.4 * h,
        _Colors.sfDisc,
        sides: 24,
      );
      if (facing) {
        g.disc(centre + nrm * (0.31 * h), 1.5 * h, nrm, _Colors.sfDiscRing);
        g.disc(centre + nrm * (0.32 * h), 0.9 * h, nrm, _Colors.sfDisc);
      }
    }

    if (facing) {
      petals();
      disc();
    } else {
      disc();
      petals();
    }
  }

  // ------------------------------------------------------------ labels

  /// HTML `createTextSprite`: a dark speech bubble with an emerald border
  /// and white bold text, its pointer on [at], kept left of the tool column.
  void _chip(Canvas canvas, Offset at, String text) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.75, padY = size * 0.4;
    final pointer = size * 0.5;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final minX = w / 2 + 4;
    final cx = at.dx
        .clamp(minX, math.max(minX, labelRight - w / 2 - 4))
        .toDouble();
    final rect = Rect.fromCenter(
      center: Offset(cx, at.dy - pointer - h / 2),
      width: w,
      height: h,
    );
    final px = at.dx
        .clamp(rect.left + pointer * 1.5, rect.right - pointer * 1.5)
        .toDouble();
    final path = _pens.path
      ..reset()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(size * 0.6)))
      ..moveTo(px - pointer, rect.bottom - 0.5)
      ..lineTo(px, rect.bottom + pointer)
      ..lineTo(px + pointer, rect.bottom - 0.5)
      ..close();
    canvas.drawPath(path, _pens.fill..color = _Colors.labelBg);
    canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.labelBorder,
    );
    // Hide the border inside the joint of the bubble and its pointer.
    canvas.drawLine(
      Offset(px - pointer + 1.2, rect.bottom),
      Offset(px + pointer - 1.2, rect.bottom),
      _pens.stroke
        ..strokeWidth = 2
        ..color = _Colors.labelBg,
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

/// Where the dust settles on the parked car (fixed, so it does not flicker):
/// (u, v) across the near side (even) and the roof of the body (odd).
const List<(double, double)> _dustSpecks = [
  (-0.82, 0.31),
  (-0.6, -0.4),
  (-0.45, 0.62),
  (-0.31, -0.12),
  (-0.18, 0.44),
  (-0.05, -0.71),
  (0.08, 0.15),
  (0.21, 0.58),
  (0.33, -0.33),
  (0.47, 0.05),
  (0.6, -0.55),
  (0.74, 0.37),
  (0.86, -0.18),
  (-0.71, -0.66),
  (-0.38, 0.12),
  (0.14, -0.48),
  (0.41, 0.71),
  (0.69, -0.02),
  (-0.92, 0.0),
  (0.93, 0.52),
];

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
