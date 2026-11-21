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

/// Class 6 Science • Chapter 3 • Activity 5
/// Designing a Balanced Diet.
///
/// Native Flutter port of `Cl6S-Ch03-A5-Designing_a_Balanced_Diet.html`
/// (Three.js r128). The Three.js scenes are redrawn by a small painter
/// ([_Gfx]) that reproduces the HTML cameras: Scenario 1 from (0, 7, 18)
/// looking at (0, 3, -1), pushing in to (0, 6, 12) after the first
/// analysis; Scenario 2 from (0, 10, 20) looking at (0, 3, 0); 45° field
/// of view.
///
/// Scenario 1 (Medu's Meal Makeover): analyse Medu's lunch of noodles,
/// biscuits and white bread (stomach ache, roughage meter red), drag the
/// three foods into the Compost Bin, drag the chapati, dal, vegetables and
/// apple from the Pantry onto his plate, and analyse again (Medu happy,
/// roughage meter green).
///
/// Scenario 2 (Gourav's Healing Bone): drag the Calcium bottle onto the
/// X-ray of Gourav's fractured leg (healing stops at 25%), then the Vitamin
/// D bottle (sunbeam, healing completes to 100%).
class Ch3A5DesigningABalancedDietPage extends StatefulWidget {
  const Ch3A5DesigningABalancedDietPage({super.key});

  @override
  State<Ch3A5DesigningABalancedDietPage> createState() =>
      _BalancedDietLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, pickup → `science/pickup.mp3`,
/// drop → `science/drop.mp3`.
///
/// The HTML synthesises its tones in `playSound(type)`; each is played with
/// the closest bundled file: `pop` / `click` (buttons, a food or bottle
/// dropped where it belongs) -> pop.mp3 and drop.mp3, `error` (a drop that
/// misses) -> error.mp3, `magic` (the rising 1 s sweep when the calcium
/// starts working) and `chime` (the 'Review Learning' button appears) ->
/// correct.mp3, `success` (Medu happy, Vitamin D healing, summary) ->
/// success.mp3. Picking a food or bottle up plays pickup.mp3 (the HTML is
/// silent there).
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// HTML `magic` and `chime`; positive feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// HTML `error`: a food or bottle let go in the wrong place.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`: Medu happy, Vitamin D healing, summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `pop`: the 'Analyze Meal' button.
  pop('audio/class6/science/pop.mp3'),

  /// A food or bottle picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML `click` on a good drop: into the bin, onto the plate or the X-ray.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scenes
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange800 = Color(0xFF9A3412);
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

  // ------------------------------------------------- scenario 1: kitchen
  /// `scene.background`: 0x020617 (dark) / 0xf3f4f6 (light).
  static const Color sceneBg = slate950;
  static const Color sceneBgLight = Color(0xFFF3F4F6);
  static const Color floor = Color(0xFFDCD5C6);
  static const Color wall = Color(0xFFECE8DD);
  static const Color table = Color(0xFFC89F7A);
  static const Color skin = Color(0xFFFFCCAA);
  static const Color shirt = Color(0xFF3876C1);
  static const Color pants = Color(0xFF1E293B);
  static const Color hair = Color(0xFF1F2937);
  static const Color pupil = Color(0xFF111827);
  static const Color nose = Color(0xFFD99A77);
  static const Color plate = Color(0xFFFFFFFF);
  static const Color bin = Color(0xFF22C55E);
  static const Color noodles = Color(0xFFFDE047);
  static const Color biscuit = Color(0xFFD97706);
  static const Color bread = Color(0xFFFFEDD5);
  static const Color crust = Color(0xFF8B5A2B);
  static const Color chapati = Color(0xFFDEB887);
  static const Color dal = Color(0xFFEAB308);
  static const Color steel = Color(0xFFD1D5DB);
  static const Color carrot = Color(0xFFF97316);
  static const Color pea = Color(0xFF22C55E);
  static const Color potato = Color(0xFFEAB308);
  static const Color apple = Color(0xFFEF4444);
  static const Color stem = Color(0xFF4ADE80);
  static const Color leaf = Color(0xFF22C55E);

  /// Stomach-ache glow on Medu's tummy (added; the HTML only frowns).
  static const Color ache = red500;

  /// Meter fills (`bg-cyan-400`, `bg-blue-500`, `bg-yellow-400`,
  /// `bg-orange-500`, roughage `bg-red-500` / `bg-green-500`).
  static const List<Color> meters = [
    cyan400,
    blue500,
    yellow400,
    orange500,
    red500,
  ];

  // --------------------------------------------------- scenario 2: X-ray
  /// X-ray backdrop: radial gradient #1e3a8a (centre) -> #020617 (edges).
  static const Color xrayInner = Color(0xFF1E3A8A);
  static const Color xrayOuter = slate950;

  /// Leg silhouette (0x3b82f6, opacity 0.25) and the bones (0xe2e8f0).
  static const Color legXray = blue500;
  static const Color bone = slate200;
  static const Color shelf = Color(0xFF8B5A2B);
  static const Color calcium = blue600;
  static const Color vitD = Color(0xFFEAB308);
  static const Color iron = red600;
  static const Color cap = white;

  /// Fracture glow: red, then blue (calcium), then green (Vitamin D).
  static const Color glowRed = red500;
  static const Color glowBlue = Color(0xFF0EA5E9);
  static const Color glowGreen = green500;

  /// Particles: 0x38bdf8 by default, 0x0ea5e9 with calcium, 0xfef08a with
  /// Vitamin D.
  static const Color particleCalcium = glowBlue;
  static const Color particleSun = Color(0xFFFEF08A);
  static const Color sunCore = Color(0xFFFFEDD5);
  static const Color sunGlow = particleSun;

  /// Soft contact shadows.
  static const Color shadow = Color(0x40000000);

  /// `createTextSprite` defaults: #1e293b chip, #06b6d4 border, white text.
  static const Color labelBg = Color(0xF21E293B);
  static const Color labelBorder = cyan500;

  /// Summary infographic (`bg-slate-950`, `bg-slate-800`, borders).
  static const Color infoBg = slate950;
  static const Color infoPanel = slate800;
  static const Color gutWall = slate600;
  static const Color gutLine = slate500;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate600,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.cyan500,
    onAccent: _Colors.slate950,
    primary: _Colors.cyan600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.cyan400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66155E75), // cyan-800/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC67E8F9), // cyan-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // slate-900/90
    buttonIcon: _Colors.cyan400,
    buttonBorder: Color(0x9906B6D4), // cyan-500/60
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneBgLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.cyan500,
    onAccent: _Colors.slate950,
    primary: _Colors.cyan600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.cyan600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66155E75),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC67E8F9),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xF2FFFFFF),
    buttonIcon: _Colors.cyan600,
    buttonBorder: _Colors.slate300,
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
/// are the HTML sidebar font setting: 15 px, slider 12–22 px.
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
// From the HTML `i18n`, `ScenariosData` and `labelDict` tables (Telugu
// dropped). Changes from the HTML (see the report): every step's action
// says exactly what to drag or tap and how many ("all three foods on
// Medu's plate", "all four foods from the Pantry"); "CLICK" is "TAP"; the
// Hindi HUD lines lose their English "(DRAG)" / "(DROP)"; the S1 step 2
// explanation no longer says processed foods have no nutritional value
// (they give energy, as the meters show) and the step 4 result says the
// roughage meter is nearly full (it shows 90%). The HTML's English-only
// healing texts ('Calcium Absorbing...', 'Healing Complete!') are
// translated. Each step's explanation (`_e`) is shown with its result once
// the step is done. Keys marked "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Designing a Balanced Diet',
    'app_subtitle': 'Class 6 • Mindful Eating: A Path to a Healthy Body',
    'scen_1_opt': "Scenario 1: Medu's Meal Makeover",
    'scen_2_opt': "Scenario 2: Gourav's Healing Bone",
    's1_desc':
        'Help Medu overcome his stomach ache and constipation by changing his unbalanced diet to a balanced one rich in dietary fibre.',
    's2_desc':
        'Understand the importance of Calcium for bones and the synergistic role of Vitamin D in helping the body absorb Calcium for effective healing.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Unbalanced Diet Analysis',
    'step_1_1_a':
        "Look at Medu's lunch, then tap 'Analyze Meal' to see its effect on his body.",
    'step_1_1_o':
        'Medu gets a stomach ache. Roughage meter is critically low (red).',
    'step_1_1_e':
        'A diet consisting only of refined carbs (noodles, biscuits) lacks essential dietary fibre, leading to digestive issues like constipation.',
    'step_1_2_c': 'Removing Unhealthy Choices',
    'step_1_2_a':
        "Drag each of the three foods on Medu's plate (noodles, biscuits, white bread) into the Compost Bin.",
    'step_1_2_o': 'Plate is cleared. Meters reset.',
    'step_1_2_e':
        'The first step to a healthy body is removing excess processed foods that give energy (calories) but few other nutrients and little fibre.',
    'step_1_3_c': 'Building a Balanced Plate',
    'step_1_3_a':
        "Drag all four foods from the Pantry shelf (chapati, dal, vegetables, apple) onto Medu's plate, one by one.",
    'step_1_3_o': 'Nutrient meters increase as items are added.',
    'step_1_3_e':
        'Different foods provide different nutrients. We need a mix of grains (carbs), pulses (proteins), and veggies/fruits (vitamins, minerals, and roughage).',
    'step_1_4_c': 'Balanced Diet Verification',
    'step_1_4_a': "Tap 'Analyze Meal' again to check the new nutrient levels.",
    'step_1_4_o':
        'Medu is happy and energetic. Roughage meter is nearly full (green).',
    'step_1_4_e':
        'A balanced diet provides all necessary nutrients. The added roughage ensures smooth digestion, curing the stomach ache.',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Calcium for Bones',
    'step_2_1_a':
        "Drag the 'Calcium' bottle from the shelf and drop it onto the X-ray of Gourav's leg.",
    'step_2_1_o': 'Healing starts but is very slow and incomplete (25%).',
    'step_2_1_e':
        "Calcium is the primary building block for strong bones and teeth. However, just taking calcium isn't always enough if the body can't absorb it.",
    'step_2_2_c': 'Vitamin D Synergy',
    'step_2_2_a':
        "Drag the 'Vitamin D' bottle from the shelf and drop it onto the X-ray of Gourav's leg.",
    'step_2_2_o':
        'Sunbeam appears. Calcium is absorbed rapidly. Healing completes (100%).',
    'step_2_2_e':
        "Vitamin D acts as a 'key' that allows the body to absorb calcium from our diet. Without Vitamin D, the calcium cannot be effectively used to build or heal bones.",
    // Added: the sidebar instruction once every step is done.
    'done_s1': "Tap 'Review Learning' to understand why Medu feels better.",
    'done_s2':
        "Tap 'Review Learning' to see how Calcium and Vitamin D work together.",
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1':
        "OBSERVE Medu's current lunch. TAP the 'Analyze Meal' button to see its effect on his body.",
    's1_hud_2':
        'Medu has a stomach ache! His Roughage (fibre) is too low. DRAG all unhealthy food from his plate and DROP them into the Compost Bin.',
    's1_hud_3':
        'Now, DRAG all four healthy foods from the pantry and DROP them onto the plate to create a balanced meal (grains, dal, veggies and fruit).',
    's1_hud_4':
        "Great! TAP the 'Analyze Meal' button again to check the new nutrient levels.",
    's1_hud_5':
        "Medu feels much better! TAP 'Review Learning' to understand why.",
    's2_hud_1':
        "Gourav has a fractured leg. DRAG the 'Calcium' supplement bottle and DROP it onto the X-ray to help it heal.",
    's2_hud_2':
        "The healing is very slow (stops at 25%). The body needs help absorbing the Calcium. DRAG the 'Vitamin D' bottle and DROP it onto the X-ray.",
    's2_hud_3':
        "The bone knitted together rapidly! TAP 'Review Learning' to see how these nutrients work together.",
    // ----------------------------------------------------------- summary
    'success': 'Discovery Complete!',
    'discovery_complete': 'Exploration Complete!',
    's1_summary':
        "You successfully designed a balanced diet! Adding fruits, vegetables, and whole grains provided dietary fibre (roughage). While roughage doesn't provide nutrients, it is essential to ensure smooth movement of food through the digestive tract, preventing constipation.",
    's2_summary':
        "You helped Gourav's bone heal! While Calcium is the essential building block for bones, Vitamin D is crucial because it helps the body absorb and use that Calcium. This shows how some nutrients must work together (synergy) to keep us healthy.",
    'info_healthy': 'HEALTHY (With Roughage)',
    'info_unhealthy': 'UNHEALTHY (No Roughage)',
    'info_smooth': 'Smooth Digestion',
    'info_stuck': 'Stuck! (Constipation)',
    'info_no_vitd': 'Calcium Cannot Enter',
    'info_vitd': 'Vitamin D Unlocks Absorption',
    // ----------------------------------------------- buttons, teacher board
    'btn_analyze': 'Analyze Meal',
    'btn_conclude': 'Review Learning',
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Focus',
    'action': 'Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'Complete this step to see the result.',
    // ------------------------------------------------ meters and healing
    'nutrients': 'Nutrients',
    'carbs': 'Carbs',
    'proteins': 'Protein',
    'fats': 'Fats',
    'vit_min': 'Vit/Min',
    'roughage': 'Roughage',
    'bone_healing': 'Bone Healing',
    'heal_calcium': 'Calcium Absorbing...',
    'heal_vitd': 'Vitamin D Synergy...',
    'heal_slow': 'Healing is very slow... Needs Vitamin D!',
    'heal_done': 'Healing Complete!',
    // ------------------------------------------------------ scene labels
    'lbl_bin': 'Compost Bin',
    'lbl_pantry': 'Pantry',
    'food_noodles': 'Noodles',
    'food_biscuits': 'Biscuits',
    'food_bread': 'White Bread',
    'food_chapati': 'Chapati',
    'food_dal': 'Dal',
    'food_veg': 'Vegetables',
    'food_apple': 'Apple',
    'lbl_calcium': 'Calcium',
    'lbl_vitd': 'Vitamin D',
    'lbl_iron': 'Iron',
    // Added.
    'lbl_xray': "X-ray of Gourav's leg",
    // ------------------------------------------------------ toasts (added)
    'first_analyze':
        "First tap 'Analyze Meal' to see what this lunch does to Medu.",
    'first_clear':
        "First clear Medu's plate: drag its three foods into the Compost Bin.",
    'first_analyze_again': "Tap 'Analyze Meal' to check Medu's new meal.",
    'miss_bin': 'Drop the {food} into the Compost Bin.',
    'miss_plate': "Drop the {food} onto Medu's plate.",
    'healthy_in_bin':
        "Healthy food! Put the {food} on Medu's plate, not in the Compost Bin.",
    'first_calcium':
        "First give the Calcium: drag the 'Calcium' bottle onto the X-ray.",
    'iron_hint':
        'Iron is needed to make blood; it does not heal this bone. Follow the task.',
    'miss_xray': "Drop the {bottle} bottle onto the X-ray of Gourav's leg.",
    'wait_heal': 'Wait: the bone is healing.',
    'scene_s1':
        'Medu at a table with his lunch plate, a green Compost Bin on the right and a Pantry shelf of foods on the left',
    'scene_s2':
        "X-ray of Gourav's fractured leg and a shelf with Calcium, Vitamin D and Iron bottles",
  },
  'hi': {
    'app_title': 'संतुलित आहार डिजाइन करना',
    'app_subtitle': 'कक्षा 6 • सचेत भोजन: स्वस्थ शरीर का मार्ग',
    'scen_1_opt': 'परिदृश्य 1: मेदु के भोजन में सुधार',
    'scen_2_opt': 'परिदृश्य 2: गौरव की हड्डी का जुड़ना',
    's1_desc':
        'मेदु के असंतुलित आहार को आहार फाइबर (रूक्षांश) से भरपूर संतुलित आहार में बदलकर उसके पेट दर्द और कब्ज को दूर करने में मदद करें।',
    's2_desc':
        'हड्डियों के लिए कैल्शियम के महत्व और प्रभावी उपचार के लिए शरीर को कैल्शियम को अवशोषित करने में मदद करने में विटामिन डी की सहक्रियात्मक भूमिका को समझें।',
    'step_1_1_c': 'असंतुलित आहार विश्लेषण',
    'step_1_1_a':
        "मेदु के दोपहर के भोजन को देखें, फिर उसके शरीर पर इसका प्रभाव देखने के लिए 'भोजन का विश्लेषण करें' दबाएँ।",
    'step_1_1_o':
        'मेदु के पेट में दर्द होता है। रूक्षांश मीटर गंभीर रूप से कम (लाल) है।',
    'step_1_1_e':
        'केवल रिफाइंड कार्ब्स (नूडल्स, बिस्कुट) वाले आहार में आवश्यक आहार फाइबर का अभाव होता है, जिससे कब्ज जैसी पाचन संबंधी समस्याएं होती हैं।',
    'step_1_2_c': 'अस्वास्थ्यकर विकल्पों को हटाना',
    'step_1_2_a':
        'मेदु की प्लेट के तीनों खाद्य पदार्थों (नूडल्स, बिस्कुट, सफेद ब्रेड) को एक-एक करके कम्पोस्ट बिन में खींचें।',
    'step_1_2_o': 'प्लेट साफ हो जाती है। मीटर रीसेट हो जाते हैं।',
    'step_1_2_e':
        'स्वस्थ शरीर की ओर पहला कदम उन अतिरिक्त प्रसंस्कृत खाद्य पदार्थों को हटाना है जो ऊर्जा (कैलोरी) तो देते हैं, पर अन्य पोषक तत्व और रेशे बहुत कम देते हैं।',
    'step_1_3_c': 'संतुलित प्लेट बनाना',
    'step_1_3_a':
        'पैंट्री की शेल्फ से चारों खाद्य पदार्थों (चपाती, दाल, सब्जियां, सेब) को एक-एक करके मेदु की प्लेट पर खींचें।',
    'step_1_3_o': 'जैसे-जैसे आइटम जोड़े जाते हैं, पोषक तत्व मीटर बढ़ते हैं।',
    'step_1_3_e':
        'विभिन्न खाद्य पदार्थ अलग-अलग पोषक तत्व प्रदान करते हैं। हमें अनाज (कार्ब्स), दालें (प्रोटीन), और सब्जियों/फलों (विटामिन, खनिज, और रूक्षांश) के मिश्रण की आवश्यकता होती है।',
    'step_1_4_c': 'संतुलित आहार सत्यापन',
    'step_1_4_a':
        "नए पोषक तत्वों के स्तर की जांच के लिए फिर से 'भोजन का विश्लेषण करें' दबाएँ।",
    'step_1_4_o':
        'मेदु खुश और ऊर्जावान है। रूक्षांश मीटर लगभग भरा हुआ (हरा) है।',
    'step_1_4_e':
        'एक संतुलित आहार सभी आवश्यक पोषक तत्व प्रदान करता है। अतिरिक्त रूक्षांश सुचारू पाचन सुनिश्चित करता है, जिससे पेट दर्द ठीक हो जाता है।',
    'step_2_1_c': 'हड्डियों के लिए कैल्शियम',
    'step_2_1_a':
        "शेल्फ से 'कैल्शियम' की बोतल खींचें और उसे गौरव के पैर के एक्स-रे पर छोड़ें।",
    'step_2_1_o': 'उपचार शुरू होता है लेकिन बहुत धीमा और अधूरा (25%) है।',
    'step_2_1_e':
        'मजबूत हड्डियों और दांतों के लिए कैल्शियम प्राथमिक निर्माण खंड है। हालांकि, केवल कैल्शियम लेना हमेशा पर्याप्त नहीं होता है यदि शरीर इसे अवशोषित नहीं कर सकता है।',
    'step_2_2_c': 'विटामिन डी तालमेल',
    'step_2_2_a':
        "शेल्फ से 'विटामिन डी' की बोतल खींचें और उसे गौरव के पैर के एक्स-रे पर छोड़ें।",
    'step_2_2_o':
        'सूरज की किरण दिखाई देती है। कैल्शियम तेजी से अवशोषित होता है। उपचार पूरा (100%)।',
    'step_2_2_e':
        "विटामिन डी एक 'कुंजी' के रूप में कार्य करता है जो शरीर को हमारे आहार से कैल्शियम को अवशोषित करने की अनुमति देता है। विटामिन डी के बिना, हड्डियों के निर्माण या उपचार के लिए कैल्शियम का प्रभावी ढंग से उपयोग नहीं किया जा सकता है।",
    'done_s1':
        "मेदु अब बेहतर क्यों महसूस कर रहा है, यह समझने के लिए 'निष्कर्ष की समीक्षा करें' दबाएँ।",
    'done_s2':
        "कैल्शियम और विटामिन डी एक साथ कैसे काम करते हैं, यह देखने के लिए 'निष्कर्ष की समीक्षा करें' दबाएँ।",
    's1_hud_1':
        "मेदु के वर्तमान दोपहर के भोजन का निरीक्षण करें। उसके शरीर पर इसका प्रभाव देखने के लिए 'भोजन का विश्लेषण करें' बटन दबाएँ।",
    's1_hud_2':
        'मेदु के पेट में दर्द है! उसका रूक्षांश (रेशा) बहुत कम है। उसकी प्लेट से सारा अस्वास्थ्यकर भोजन खींचें और कम्पोस्ट बिन में छोड़ें।',
    's1_hud_3':
        'अब, पैंट्री से चारों स्वस्थ खाद्य पदार्थों को खींचें और संतुलित भोजन बनाने के लिए उन्हें प्लेट पर छोड़ें (अनाज, दाल, सब्जियां और फल)।',
    's1_hud_4':
        "बहुत बढ़िया! नए पोषक तत्वों के स्तर की जांच करने के लिए फिर से 'भोजन का विश्लेषण करें' बटन दबाएँ।",
    's1_hud_5':
        "मेदु अब बहुत बेहतर महसूस कर रहा है! ऐसा क्यों हुआ, यह समझने के लिए 'निष्कर्ष की समीक्षा करें' दबाएँ।",
    's2_hud_1':
        "गौरव के पैर में फ्रैक्चर है। 'कैल्शियम' सप्लीमेंट की बोतल को खींचें और इसे ठीक होने में मदद करने के लिए एक्स-रे पर छोड़ें।",
    's2_hud_2':
        "उपचार बहुत धीमा है (25% पर रुक जाता है)। शरीर को कैल्शियम अवशोषित करने में मदद की ज़रूरत है। 'विटामिन डी' की बोतल को खींचें और एक्स-रे पर छोड़ें।",
    's2_hud_3':
        "हड्डी तेजी से जुड़ गई! ये पोषक तत्व एक साथ कैसे काम करते हैं, यह देखने के लिए 'निष्कर्ष की समीक्षा करें' दबाएँ।",
    'success': 'खोज पूर्ण!',
    'discovery_complete': 'अन्वेषण पूर्ण!',
    's1_summary':
        'आपने सफलतापूर्वक एक संतुलित आहार डिजाइन किया है! फल, सब्जियां और साबुत अनाज शामिल करने से आहार फाइबर (रूक्षांश) मिला। हालांकि रूक्षांश पोषक तत्व प्रदान नहीं करता है, यह पाचन तंत्र के माध्यम से भोजन की सुचारू गति सुनिश्चित करने, कब्ज को रोकने के लिए आवश्यक है।',
    's2_summary':
        'आपने गौरव की हड्डी को ठीक करने में मदद की! जबकि कैल्शियम हड्डियों के लिए आवश्यक निर्माण खंड है, विटामिन डी महत्वपूर्ण है क्योंकि यह शरीर को उस कैल्शियम को अवशोषित करने और उपयोग करने में मदद करता है। यह दर्शाता है कि हमें स्वस्थ रखने के लिए कुछ पोषक तत्वों को एक साथ (तालमेल) काम करना चाहिए।',
    'info_healthy': 'स्वस्थ (रूक्षांश के साथ)',
    'info_unhealthy': 'अस्वस्थ (बिना रूक्षांश)',
    'info_smooth': 'सुचारू पाचन',
    'info_stuck': 'फंस गया! (कब्ज)',
    'info_no_vitd': 'कैल्शियम प्रवेश नहीं कर सकता',
    'info_vitd': 'विटामिन डी अवशोषण को खोलता है',
    'btn_analyze': 'भोजन का विश्लेषण करें',
    'btn_conclude': 'निष्कर्ष की समीक्षा करें',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'ध्यान दें',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    'nutrients': 'पोषक तत्व',
    'carbs': 'कार्ब्स',
    'proteins': 'प्रोटीन',
    'fats': 'वसा',
    'vit_min': 'विट/मिन',
    'roughage': 'रूक्षांश',
    'bone_healing': 'हड्डी का जुड़ना',
    'heal_calcium': 'कैल्शियम अवशोषित हो रहा है...',
    'heal_vitd': 'विटामिन डी का तालमेल...',
    'heal_slow': 'उपचार बहुत धीमा है... विटामिन डी चाहिए!',
    'heal_done': 'उपचार पूरा!',
    'lbl_bin': 'कम्पोस्ट बिन',
    'lbl_pantry': 'पैंट्री (भंडार)',
    'food_noodles': 'नूडल्स',
    'food_biscuits': 'बिस्कुट',
    'food_bread': 'सफेद ब्रेड',
    'food_chapati': 'चपाती',
    'food_dal': 'दाल',
    'food_veg': 'सब्जियां',
    'food_apple': 'सेब',
    'lbl_calcium': 'कैल्शियम',
    'lbl_vitd': 'विटामिन डी',
    'lbl_iron': 'आयरन',
    'lbl_xray': 'गौरव के पैर का एक्स-रे',
    'first_analyze':
        "पहले 'भोजन का विश्लेषण करें' दबाकर देखें कि यह भोजन मेदु पर क्या असर डालता है।",
    'first_clear':
        'पहले मेदु की प्लेट खाली करें: उसके तीनों खाद्य पदार्थ कम्पोस्ट बिन में खींचें।',
    'first_analyze_again':
        "मेदु के नए भोजन की जांच के लिए 'भोजन का विश्लेषण करें' दबाएँ।",
    'miss_bin': '{food} को कम्पोस्ट बिन में डालें।',
    'miss_plate': '{food} को मेदु की प्लेट पर रखें।',
    'healthy_in_bin':
        'यह स्वास्थ्यवर्धक भोजन है! {food} को कम्पोस्ट बिन में नहीं, मेदु की प्लेट पर रखें।',
    'first_calcium':
        "पहले कैल्शियम दें: 'कैल्शियम' की बोतल को एक्स-रे पर खींचें।",
    'iron_hint':
        'आयरन रक्त बनाने के लिए ज़रूरी है; यह इस हड्डी को नहीं जोड़ता। दिए गए कार्य का पालन करें।',
    'miss_xray': '{bottle} की बोतल को गौरव के पैर के एक्स-रे पर छोड़ें।',
    'wait_heal': 'रुकिए: हड्डी जुड़ रही है।',
    'scene_s1':
        'मेज पर दोपहर के भोजन की प्लेट के साथ मेदु, दाईं ओर हरा कम्पोस्ट बिन और बाईं ओर खाद्य पदार्थों वाली पैंट्री की शेल्फ',
    'scene_s2':
        'गौरव के टूटे पैर का एक्स-रे और कैल्शियम, विटामिन डी तथा आयरन की बोतलों वाली शेल्फ',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [4, 2];

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

/// Scenario 1 `resetCamera()`: position (0, 7, 18), target (0, 3, -1). The
/// first analysis pushes the camera in to (0, 6, 12) in 800 ms
/// (`TWEEN.Easing.Cubic.Out`).
const _V _s1Eye = _V(0, 7, 18);
const _V _s1EyeNear = _V(0, 6, 12);
const _V _s1LookAt = _V(0, 3, -1);
const double _pushSeconds = 0.8;

/// Scenario 2 `resetCamera()`: position (0, 10, 20), target (0, 3, 0).
const _V _s2Eye = _V(0, 10, 20);
const _V _s2LookAt = _V(0, 3, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.7)` and `DirectionalLight(
/// 0xffffff, 0.8)` at (10, 20, 10). Three.js adds them and clips at white,
/// which washes every lit face out; both are scaled by [_lightScale].
const double _lightScale = 0.65;
const double _ambient = 0.7 * _lightScale;
const double _diffuse = 0.8 * _lightScale;

/// (10, 20, 10) normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

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

/// Time constant (s) of the stage framing as it follows the shell's cards.
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

/// This lab's canvas cards (dp x UI scale): the HTML `#meters-panel`
/// (top right of the canvas), the healing progress (HTML
/// `#progress-overlay`, here at the top right too, since the bottom belongs
/// to the HUD chip) and the band of the canvas copy of the action button
/// just above the HUD chip (HTML `bottom-24`).
const Size _metersCardSize = Size(128, 164);
const Size _healCardSize = Size(232, 86);
const Size _actionBandSize = Size(330, 54);

/// Gap between the HUD chip and the canvas action button.
const double _actionGap = 4;

/// Drop zones reach this many design px (x framing scale) past the object
/// that catches the drop.
const double _catchPad = 18;

// ------------------------------------------------- scenario 1: the kitchen

/// `setTimeout(progressStep, 2500)` after the first analysis.
const double _analysisSeconds = 2.5;

/// `setTimeout(progressStep, 500)` after the fourth food is on the plate.
const double _plateFullSeconds = 0.5;

/// `setTimeout(triggerConclusionState, 2000)` after the second analysis.
const double _reactSeconds = 2.0;

/// TWEEN 300 ms: a food shrinking into the bin, sliding onto its plate
/// spot, or going back where it came from.
const double _tweenSeconds = 0.3;

/// `.meter-fill { transition: height 0.5s cubic-bezier(0.4, 0, 0.2, 1) }`.
const double _meterSeconds = 0.5;

/// `vals.rough < 30`: the roughage meter is red (and pulses), else green.
const double _roughLow = 30;

/// Pulse of the low roughage meter (`animate-pulse`: 2 s).
const double _pulseSeconds = 2;

/// Medu: `medu.position.set(0, 1.5, -4.5)`, `scale 1.25`; slouches to
/// y = 1.3 with a stomach ache; jumps to y = 2.5 (300 ms Quadratic.Out up,
/// 300 ms Quadratic.In down) when he feels better.
const _V _meduAt = _V(0, 1.5, -4.5);
const double _meduScale = 1.25;
const double _meduSlouch = 1.3;
const double _meduJumpTop = 2.5;
const double _jumpHalfSeconds = 0.3;

/// Table `BoxGeometry(14, 0.5, 6)` at (0, 3, 0), legs `CylinderGeometry(
/// 0.2, 0.2, 3)` at (±6, 1.5, ±2.5).
const _V _tableAt = _V(0, 3, 0);
const _V _tableSize = _V(14, 0.5, 6);
const double _tableLegX = 6;
const double _tableLegZ = 2.5;
const double _tableLegR = 0.2;

/// Room: floor `PlaneGeometry(30, 30)` at y = 0, wall `PlaneGeometry(30,
/// 15)` at z = -8. Both are painted wider and the wall taller
/// ([_roomPaintHalf], [_wallHeight]): the HTML's edges showed the dark
/// scene background beside and above the room once the scene is framed
/// clear of the shell's cards.
const double _roomHalf = 15;
const double _roomPaintHalf = 45;
const double _wallZ = -8;
const double _wallHeight = 30;

/// Plate `CylinderGeometry(2, 1.5, 0.2)` at (0, 3.35, -1).
const _V _plateAt = _V(0, 3.35, -1);
const double _plateTopR = 2;
const double _plateBottomR = 1.5;
const double _plateHeight = 0.2;

/// Where the foods stand on the plate (HTML y = 3.45).
const double _onPlateY = 3.45;

/// `plateItems` spots: x = -0.5 / 0.5 (even / odd), z = -1.5 / -0.5 (first
/// two / last two).
const List<_V> _plateSlots = [
  _V(-0.5, _onPlateY, -1.5),
  _V(0.5, _onPlateY, -1.5),
  _V(-0.5, _onPlateY, -0.5),
  _V(0.5, _onPlateY, -0.5),
];

/// Compost bin: `CylinderGeometry(1.2, 0.9, 2.5)` standing at (5, 3.25, 1);
/// its label sprite 3 units above its base.
const _V _binAt = _V(5, 3.25, 1);
const double _binTopR = 1.2;
const double _binBottomR = 0.9;
const double _binHeight = 2.5;
const _V _binLabelAt = _V(5, 6.25, 1);

/// Pantry shelf `BoxGeometry(5, 0.3, 2)` at (-6, 5, -6), label at
/// (-6, 6, -6).
const _V _pantryAt = _V(-6, 5, -6);
const _V _pantrySize = _V(5, 0.3, 2);
const _V _pantryLabelAt = _V(-6, 6, -6);

/// A free spot on the table (nothing there): used by the flows for a drop
/// that misses.
const _V _openKitchen = _V(-4.5, _onPlateY, 1.5);

/// The foods of `buildS1Scene()`: three on Medu's plate (`isHealthy`
/// false) and four on the Pantry shelf. [lift] is the height of the
/// food's middle above its base, [radius] its size (world units). The
/// nutrients (carbs, protein, fats, vitamins / minerals, roughage, in % of
/// the meters) add up to the HTML's meter readings: the plate of noodles,
/// biscuits and white bread reads 90 / 10 / 40 / 5 / 5 (first analysis),
/// the balanced plate 60 / 60 / 30 / 80 / 90 (second analysis). Each food
/// gives what the HTML's `updateMeters` gave it (chapati carbs + roughage,
/// dal protein, vegetables vitamins + roughage, apple vitamins + roughage);
/// the dal and the vegetables are cooked with a little oil or ghee (fats).
enum _Food {
  noodles(
    nameKey: 'food_noodles',
    healthy: false,
    home: _V(-0.5, _onPlateY, -1),
    lift: 0.3,
    radius: 0.5,
    nutrients: [35, 5, 20, 0, 0],
  ),
  biscuits(
    nameKey: 'food_biscuits',
    healthy: false,
    home: _V(0.5, _onPlateY, -1.5),
    lift: 0.1,
    radius: 0.35,
    nutrients: [30, 0, 15, 0, 0],
  ),
  bread(
    nameKey: 'food_bread',
    healthy: false,
    home: _V(0.5, _onPlateY, -0.5),
    lift: 0.1,
    radius: 0.4,
    nutrients: [25, 5, 5, 5, 5],
  ),
  chapati(
    nameKey: 'food_chapati',
    healthy: true,
    home: _V(-8, 5.15, -6),
    lift: 0.03,
    radius: 0.7,
    nutrients: [40, 10, 0, 0, 20],
  ),
  dal(
    nameKey: 'food_dal',
    healthy: true,
    home: _V(-6.6, 5.15, -6),
    lift: 0.15,
    radius: 0.5,
    nutrients: [0, 50, 15, 10, 10],
  ),
  veg(
    nameKey: 'food_veg',
    healthy: true,
    home: _V(-5.2, 5.15, -6),
    lift: 0.2,
    radius: 0.55,
    nutrients: [10, 0, 15, 40, 30],
  ),
  apple(
    nameKey: 'food_apple',
    healthy: true,
    home: _V(-4, 5.15, -5.5),
    lift: 0.4,
    radius: 0.4,
    nutrients: [10, 0, 0, 30, 30],
  );

  const _Food({
    required this.nameKey,
    required this.healthy,
    required this.home,
    required this.lift,
    required this.radius,
    required this.nutrients,
  });

  final String nameKey;

  /// HTML `userData.isHealthy`.
  final bool healthy;
  final _V home;
  final double lift;
  final double radius;
  final List<double> nutrients;
}

/// What a food is doing.
enum _FoodPhase { idle, held, returning, toBin, binned, toPlate, onPlate }

class _FoodState {
  _FoodState(this.kind) : pos = kind.home;

  final _Food kind;

  /// Base of the food (HTML group position).
  _V pos;
  _FoodPhase phase = _FoodPhase.idle;
  double phaseStart = 0;
  _V from = _V.zero;
  _V to = _V.zero;

  /// HTML `scale` (shrinks to 0 into the bin).
  double scale = 1;

  /// Middle of the food (hit tests, drop tests, labels).
  _V get centre => pos + _V(0, kind.lift, 0);

  /// Counted on Medu's plate by the nutrient meters.
  bool get onPlate => kind.healthy
      ? phase == _FoodPhase.toPlate || phase == _FoodPhase.onPlate
      : phase != _FoodPhase.toBin && phase != _FoodPhase.binned;
}

// -------------------------------------------------- scenario 2: the X-ray

/// X-ray backdrop `PlaneGeometry(40, 25)` at (0, 5, -5); the radial
/// gradient reaches its edges (20 units across, 12.5 up).
const _V _xrayAt = _V(0, 5, -5);
const double _xrayHalfW = 20;
const double _xrayHalfH = 12.5;

/// Leg silhouette `CylinderGeometry(1.6, 1.3, 7)` at (-1.5, 4.5, 0),
/// opacity 0.25.
const _V _legAt = _V(-1.5, 4.5, 0);
const double _legTopR = 1.6;
const double _legBottomR = 1.3;
const double _legLength = 7;

/// Fractured tibia: upper piece `CylinderGeometry(0.5, 0.4, 4)` at
/// (-1.5, 7, 0) with the knee (spheres r 0.8 and 0.7 at (-0.2, 2) and
/// (0.4, 2)); lower piece `CylinderGeometry(0.4, 0.6, 4)` at (-1.3, 2.5, 0)
/// with the ankle (the same spheres at y = -2). Healing closes the gap in
/// 1 s (the HTML moved the pieces to y 5.5 / 4.0, which pushes them 2.5
/// units into each other; here they meet at the break).
const _V _boneTopBroken = _V(-1.5, 7, 0);
const _V _boneTopHealed = _V(-1.4, 6.75, 0);
const _V _boneBottomBroken = _V(-1.3, 2.5, 0);
const _V _boneBottomHealed = _V(-1.4, 2.75, 0);
const double _boneLength = 4;
const double _closeSeconds = 1;

/// Fracture glow `SphereGeometry(1.2)` at (-1.4, 4.8, 0), opacity 0.6.
const _V _fractureAt = _V(-1.4, 4.8, 0);
const double _glowRadius = 1.2;
const double _glowOpacity = 0.6;

/// The drop target `BoxGeometry(4, 8, 4)` at (-1.5, 5, 0) (`isBoneTarget`).
const _V _xrayTargetAt = _V(-1.5, 5, 0);
const _V _xrayTargetHalf = _V(2, 4, 2);

/// "X-ray of Gourav's leg" label, above the knee (added).
const _V _xrayLabelAt = _V(-1.5, 10, 0);

/// Shelf `BoxGeometry(6, 0.2, 1.5)` at (4.5, 3, -1) with two brackets
/// `BoxGeometry(0.1, 1, 1)` at (±2.5, -0.6, -0.25).
const _V _shelfAt = _V(4.5, 3, -1);
const _V _shelfSize = _V(6, 0.2, 1.5);
const _V _bracketSize = _V(0.1, 1, 1);
const double _bracketX = 2.5;
const _V _bracketOffset = _V(0, -0.6, -0.25);

/// A free spot on the X-ray, right of the leg: used by the flows for a
/// drop that misses.
const _V _openXray = _V(3.5, 7.5, 0);

/// Bottle parts (`createBottle`): body `CylinderGeometry(0.4, 0.4, 1)`,
/// neck `CylinderGeometry(0.2, 0.4, 0.3)`, cap `CylinderGeometry(0.25,
/// 0.25, 0.2)`, label band from 0.25 to 0.75 up the body.
const double _bottleR = 0.4;
const double _bottleBody = 1;
const double _neckTopR = 0.2;
const double _neckHeight = 0.3;
const double _capR = 0.25;
const double _capHeight = 0.2;
const double _bottleHeight = _bottleBody + _neckHeight + _capHeight;

/// The supplements on the shelf (`calcBottle`, `vitDBottle`,
/// `ironBottle`). Only Calcium (step 1) and Vitamin D (step 2) can be
/// moved; Iron is a distractor.
enum _Bottle {
  calcium(
    nameKey: 'lbl_calcium',
    color: _Colors.calcium,
    home: _V(2.5, 3.1, -1),
    labelAt: _V(0, -1.1, 0.75),
  ),
  vitD(
    nameKey: 'lbl_vitd',
    color: _Colors.vitD,
    home: _V(4.5, 3.1, -1),
    labelAt: _V(0, 2.0, 0),
  ),
  iron(
    nameKey: 'lbl_iron',
    color: _Colors.iron,
    home: _V(6.5, 3.1, -1),
    labelAt: _V(0, -1.1, 0.75),
  );

  const _Bottle({
    required this.nameKey,
    required this.color,
    required this.home,
    required this.labelAt,
  });

  final String nameKey;
  final Color color;
  final _V home;

  /// Name label relative to the bottle's base: the middle bottle's above
  /// its cap, the outer two under the shelf, so the three never overlap.
  final _V labelAt;
}

/// What a bottle is doing.
enum _BottlePhase { idle, held, returning, applying, gone }

class _BottleState {
  _BottleState(this.kind) : pos = kind.home;

  final _Bottle kind;

  /// Base of the bottle.
  _V pos;
  _BottlePhase phase = _BottlePhase.idle;
  double phaseStart = 0;
  _V from = _V.zero;
  double scale = 1;

  _V get centre => pos + const _V(0, _bottleHeight / 2, 0);
}

/// Where the healing is (`startS2Progress`).
enum _Heal {
  /// Nothing applied yet.
  none,

  /// Calcium: 0 -> 25% in 3 s (`'magic'`).
  calcium,

  /// Stopped at 25%: "Healing is very slow... Needs Vitamin D!".
  slow,

  /// Vitamin D: 25 -> 100% in 2 s (`'success'`), sunbeam on.
  vitD,

  /// 100%: "Healing Complete!", the bone closes.
  healed,
}

/// Healing targets and durations (`startS2Progress(…, 3000, 25)` and
/// `(…, 2000, 100)`).
const double _calciumPercent = 25;
const double _calciumSeconds = 3;
const double _vitDSeconds = 2;

/// `setTimeout(triggerConclusionState, 1000)` after the bone closes.
const double _healedDoneSeconds = 1;

/// Particles: 100 points in a 3-unit cube around the fracture, falling
/// 0.02 per frame (1.2 units/s), wrapping from -1 back to 1; they swirl
/// 0.05 rad per frame (3 rad/s) about the vertical once Vitamin D is on.
const int _particleCount = 100;
const double _particleSpread = 1.5;
const double _particleFall = 1.2;
const double _particleSwirl = 3;
const double _particleSize = 0.25;

/// Sun `SphereGeometry(1.5)` and glow `SphereGeometry(2.5)` at (6, 12, 0).
/// The beam runs from the sun to the fracture (the HTML cone was tipped
/// the other way, away from the leg).
const _V _sunAt = _V(6, 12, 0);
const double _sunR = 1.5;
const double _sunGlowR = 2.5;
const double _beamSunHalf = 0.5;
const double _beamLegHalf = 2.4;

// ------------------------------------------------------------ math, camera

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

  static _View lerp(_View a, _View b, double t) => _View(
    a.dx + (b.dx - a.dx) * t,
    a.dy + (b.dy - a.dy) * t,
    a.k + (b.k - a.k) * t,
  );

  _View toward(_View t, double a) {
    final v = lerp(this, t, a);
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
  _Camera(_V eye, _V target) {
    aim(eye, target);
  }

  _V eye = _V.zero;
  _V f = const _V(0, 0, -1);
  _V r = const _V(1, 0, 0);
  _V u = _V.up;

  /// Where the look-at point lands and the pixels per unit at depth 1.
  Offset center = _designCenter;
  double focal = _focal;

  /// Points the camera from [eye] at [target].
  void aim(_V eye, _V target) {
    this.eye = eye;
    f = (target - eye).unit;
    r = f.cross(_V.up).unit;
    u = r.cross(f);
  }

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

  /// Where the ray through [s] meets the plane `n · x = d` (HTML
  /// `raycaster.intersectObjects([dragPlane])`).
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (p(c + _V(0, 0, radius)).dy - p(c - _V(0, 0, radius)).dy).abs() / 2;
}

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

/// Medu's body point [local] (HTML `buildMedu()` coordinates) with his
/// feet at height [y].
_V _medu(_V local, double y) =>
    _V(_meduAt.x, y, _meduAt.z) + local * _meduScale;

/// Bounds (unframed design px) of a food at its home.
Rect _foodBounds(_Camera cam, _Food k) {
  final c = k.home + _V(0, k.lift, 0);
  return _boxBounds(cam, c, _V(k.radius, math.max(k.lift, 0.15), k.radius));
}

// ------------------------------------------------------------- the scene

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    // Particle positions (HTML `Math.random() - 0.5) * 3`), fixed per lab.
    final rnd = math.Random(5);
    for (var i = 0; i < _particleCount; i++) {
      particles.add(
        _V(
          (rnd.nextDouble() - 0.5) * 2 * _particleSpread,
          (rnd.nextDouble() - 0.5) * 2 * _particleSpread,
          (rnd.nextDouble() - 0.5) * 2 * _particleSpread,
        ),
      );
    }
  }

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; steps + 1 once the scenario is done and
  /// 'Review Learning' is offered).
  int step = 1;

  /// Bumped on every load, so a gesture from before cannot touch the new
  /// scene.
  int generation = 0;

  final _Camera cam = _Camera(_s1Eye, _s1LookAt);
  _View view = _View.identity;

  /// Framings for the scenario's camera (Scenario 1: before and after the
  /// push-in).
  _View viewFar = _View.identity;
  _View viewNear = _View.identity;

  /// The next framing jumps to its target instead of sliding.
  bool snapView = true;

  // ------------------------------------------------------------ scenario 1
  final List<_FoodState> foods = [];

  /// Scene times of the first and second analysis and of the fourth food
  /// reaching the plate (-1: not yet).
  double analyze1At = -1;
  double analyze2At = -1;
  double fullAt = -1;

  /// HTML `#meters-panel` shown (from the first analysis).
  bool metersShown = false;
  final List<double> meterFrom = List.filled(5, 0);
  final List<double> meterTo = List.filled(5, 0);
  double meterStart = -10;

  /// Medu frowns, slouches and holds a sore tummy.
  bool meduSad = false;

  // ------------------------------------------------------------ scenario 2
  final List<_BottleState> bottles = [];
  _Heal heal = _Heal.none;
  double healFrom = 0;
  double healTo = 0;
  double healStart = -10;
  double healSeconds = 1;

  /// When Vitamin D went on (particles swirl from then) and when the
  /// healing reached 100% (the bone closes from then).
  double vitDAt = -1;
  double healedAt = -1;
  final List<_V> particles = [];

  bool get done => step > _stepCounts[scenario];

  // ---------------------------------------------------------- scenario 1

  /// Progress of the camera push-in (0 … 1, eased).
  double get push => analyze1At < 0
      ? 0
      : Curves.easeOutCubic.transform(
          ((time - analyze1At) / _pushSeconds).clamp(0.0, 1.0),
        );

  _V get s1Eye => _V.lerp(_s1Eye, _s1EyeNear, push);

  /// Meter [i] now (animated towards its target).
  double meter(int i) {
    final k = ((time - meterStart) / _meterSeconds).clamp(0.0, 1.0);
    return meterFrom[i] +
        (meterTo[i] - meterFrom[i]) * Curves.fastOutSlowIn.transform(k);
  }

  /// HTML `setMeters(vals)`.
  void setMeters(List<double> values) {
    for (var i = 0; i < 5; i++) {
      meterFrom[i] = meter(i);
      meterTo[i] = values[i];
    }
    meterStart = time;
  }

  /// What the food on Medu's plate adds up to (HTML `updateMeters`).
  List<double> plateNutrients() {
    final sum = List<double>.filled(5, 0);
    for (final f in foods) {
      if (!f.onPlate) continue;
      for (var i = 0; i < 5; i++) {
        sum[i] += f.kind.nutrients[i];
      }
    }
    return sum;
  }

  int get binned => foods
      .where(
        (f) =>
            !f.kind.healthy &&
            (f.phase == _FoodPhase.toBin || f.phase == _FoodPhase.binned),
      )
      .length;

  int get plated => foods.where((f) => f.kind.healthy && f.onPlate).length;

  /// Height of Medu's feet: slouched while his tummy hurts, jumping once
  /// he feels better.
  double get meduY {
    if (analyze2At >= 0) {
      final t = time - analyze2At;
      if (t < _jumpHalfSeconds) {
        return _meduAt.y +
            (_meduJumpTop - _meduAt.y) *
                Curves.easeOutQuad.transform(t / _jumpHalfSeconds);
      }
      if (t < 2 * _jumpHalfSeconds) {
        return _meduJumpTop -
            (_meduJumpTop - _meduAt.y) *
                Curves.easeInQuad.transform(
                  (t - _jumpHalfSeconds) / _jumpHalfSeconds,
                );
      }
    }
    return meduSad ? _meduSlouch : _meduAt.y;
  }

  // ---------------------------------------------------------- scenario 2

  /// Healing progress in % (linear, as `animateFill`).
  double get healProgress =>
      healFrom +
      (healTo - healFrom) * ((time - healStart) / healSeconds).clamp(0.0, 1.0);

  double get _closing =>
      healedAt < 0 ? 0 : ((time - healedAt) / _closeSeconds).clamp(0.0, 1.0);

  _V get boneTop => _V.lerp(_boneTopBroken, _boneTopHealed, _closing);
  _V get boneBottom => _V.lerp(_boneBottomBroken, _boneBottomHealed, _closing);

  bool get sunbeam => heal == _Heal.vitD || heal == _Heal.healed;

  /// Particles and the fracture glow (hidden once healed).
  bool get particlesOn => heal != _Heal.none && heal != _Heal.healed;

  Color get glowColor => switch (heal) {
    _Heal.none => _Colors.glowRed,
    _Heal.calcium || _Heal.slow => _Colors.glowBlue,
    _ => _Colors.glowGreen,
  };

  _FoodState food(_Food k) => foods.firstWhere((f) => f.kind == k);
  _BottleState bottle(_Bottle k) => bottles.firstWhere((b) => b.kind == k);

  /// Design-space position of a named scene point (used by the flows):
  /// foods, bottles, `bin`, `plate`, `xray` and `open` (a free spot).
  Offset anchor(String id) {
    for (final f in foods) {
      if (f.kind.name == id) return cam.p(f.centre);
    }
    for (final b in bottles) {
      if (b.kind.name == id) return cam.p(b.centre);
    }
    return switch (id) {
      'bin' => cam.p(_binAt + const _V(0, _binHeight / 2, 0)),
      'plate' => cam.p(_plateAt + const _V(0, 0.3, 0)),
      'xray' => cam.p(_fractureAt),
      'open' => cam.p(scenario == 0 ? _openKitchen : _openXray),
      _ => cam.p(scenario == 0 ? _s1LookAt : _s2LookAt),
    };
  }

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    generation++;
    scenario = index;
    step = 1;
    foods
      ..clear()
      ..addAll([for (final k in _Food.values) _FoodState(k)]);
    analyze1At = -1;
    analyze2At = -1;
    fullAt = -1;
    metersShown = false;
    meterFrom.fillRange(0, 5, 0);
    meterTo.fillRange(0, 5, 0);
    meterStart = -10;
    meduSad = false;
    bottles
      ..clear()
      ..addAll([for (final k in _Bottle.values) _BottleState(k)]);
    heal = _Heal.none;
    healFrom = 0;
    healTo = 0;
    healStart = -10;
    healSeconds = 1;
    vitDAt = -1;
    healedAt = -1;
    if (index == 0) {
      cam.aim(_s1Eye, _s1LookAt);
    } else {
      cam.aim(_s2Eye, _s2LookAt);
    }
    snapView = true;
  }
}

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

/// What the current pointer holds: a food or a bottle, dragged on the
/// plane through it that faces the camera (HTML: `dragPlane` aligned with
/// the camera, through the object).
class _Grab {
  _Grab(this.item, this.offset, this.normal, this.d, this.generation);

  /// A [_FoodState] or a [_BottleState].
  final Object item;

  /// Drag-plane hit minus the object's position at pointer-down.
  final _V offset;
  final _V normal;
  final double d;
  final int generation;
}

class _BalancedDietLabState extends State<Ch3A5DesigningABalancedDietPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  _Grab? _grab;

  /// The held object has actually been dragged (past the slop); a plain
  /// tap puts it back without a hint.
  bool _moved = false;

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

  /// HTML `animate()` (`TWEEN.update()`, particles), then one repaint of
  /// the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    if (s.scenario == 0) s.cam.aim(s.s1Eye, _s1LookAt);
    final target = s.scenario == 0 && s.analyze1At >= 0
        ? _View.lerp(s.viewFar, s.viewNear, s.push)
        : s.viewFar;
    s.view = s.view.toward(target, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    final before = s.step;
    final heal = s.heal;
    if (s.scenario == 0) {
      _advanceFoods();
      _advanceKitchen();
    } else {
      _advanceBottles();
      _advanceHealing();
    }
    if (s.step != before || s.heal != heal) _refresh();
    _frame.value = now;
  }

  /// TWEEN moves of the foods (300 ms, linear).
  void _advanceFoods() {
    final s = _scene;
    for (final f in s.foods) {
      final k = ((s.time - f.phaseStart) / _tweenSeconds).clamp(0.0, 1.0);
      switch (f.phase) {
        case _FoodPhase.returning:
          f.pos = _V.lerp(f.from, f.to, k);
          if (k >= 1) f.phase = _FoodPhase.idle;
        case _FoodPhase.toBin:
          f
            ..pos = _V.lerp(f.from, f.to, k)
            ..scale = 1 - k;
          if (k >= 1) f.phase = _FoodPhase.binned;
        case _FoodPhase.toPlate:
          f.pos = _V.lerp(f.from, f.to, k);
          if (k >= 1) f.phase = _FoodPhase.onPlate;
        case _FoodPhase.idle:
        case _FoodPhase.held:
        case _FoodPhase.binned:
        case _FoodPhase.onPlate:
          break;
      }
    }
  }

  /// The HTML's timed step changes of Scenario 1.
  void _advanceKitchen() {
    final s = _scene;
    if (s.step == 1 &&
        s.analyze1At >= 0 &&
        s.time - s.analyze1At >= _analysisSeconds) {
      s.step = 2;
    }
    if (s.step == 3 &&
        s.fullAt >= 0 &&
        s.time - s.fullAt >= _plateFullSeconds) {
      s.step = 4;
    }
    if (s.step == 4 &&
        s.analyze2At >= 0 &&
        s.time - s.analyze2At >= _reactSeconds) {
      // HTML `triggerConclusionState()`: 'Review Learning' with a chime.
      s.step = 5;
      _Sound.correct.play();
    }
  }

  /// Bottles going home after a miss, or shrinking into the X-ray.
  void _advanceBottles() {
    final s = _scene;
    for (final b in s.bottles) {
      final k = ((s.time - b.phaseStart) / _tweenSeconds).clamp(0.0, 1.0);
      switch (b.phase) {
        case _BottlePhase.returning:
          b.pos = _V.lerp(b.from, b.kind.home, k);
          if (k >= 1) b.phase = _BottlePhase.idle;
        case _BottlePhase.applying:
          b.scale = 1 - k;
          if (k >= 1) b.phase = _BottlePhase.gone;
        case _BottlePhase.idle:
        case _BottlePhase.held:
        case _BottlePhase.gone:
          break;
      }
    }
  }

  /// HTML `startS2Progress` callbacks.
  void _advanceHealing() {
    final s = _scene;
    final t = s.time - s.healStart;
    switch (s.heal) {
      case _Heal.calcium when t >= s.healSeconds:
        // "Healing is very slow... Needs Vitamin D!", step 2.
        s
          ..heal = _Heal.slow
          ..step = 2;
      case _Heal.vitD when t >= s.healSeconds:
        // "Healing Complete!": the bone closes, glow and particles go.
        s
          ..heal = _Heal.healed
          ..healedAt = s.time;
      case _Heal.healed
          when s.step == 2 && s.time - s.healedAt >= _healedDoneSeconds:
        s.step = 3;
        _Sound.correct.play();
      default:
        break;
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

  /// HTML `triggerAnalyze()`: the first time the meters show the junk
  /// lunch and Medu gets a stomach ache (the camera pushes in); the second
  /// time Medu feels better and jumps.
  void _analyze() {
    final s = _scene;
    if (s.scenario != 0) return;
    if (s.step == 1 && s.analyze1At < 0) {
      setState(() {
        s
          ..analyze1At = s.time
          ..metersShown = true
          ..meduSad = true
          ..setMeters(s.plateNutrients());
      });
    } else if (s.step == 4 && s.analyze2At < 0) {
      _Sound.success.play();
      setState(() {
        s
          ..analyze2At = s.time
          ..meduSad = false
          ..setMeters(s.plateNutrients());
      });
    }
  }

  /// HTML `triggerConclusion()`: the summary with its infographic.
  void _review() {
    final s = _scene;
    if (!s.done) return;
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: const Duration(milliseconds: 150),
      title: () => _t('success'),
      heading: () => _t('discovery_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () => Builder(
        builder: (context) => sc == 0
            ? _DigestionInfo(
                scale: context.labScale,
                healthy: _t('info_healthy'),
                unhealthy: _t('info_unhealthy'),
                smooth: _t('info_smooth'),
                stuck: _t('info_stuck'),
              )
            : _CalciumInfo(
                scale: context.labScale,
                without: _t('info_no_vitd'),
                withVitD: _t('info_vitd'),
              ),
      ),
    );
  }

  // -------------------------------------------------------------- gestures

  /// Foods the current step lets the learner move (HTML `handleDown`
  /// `activeObjects`): the plate's foods at step 2, the Pantry's at step 3.
  /// A food already on the plate stays there (the HTML let it be dragged
  /// again and counted twice).
  bool _foodUnlocked(_FoodState f) {
    final s = _scene;
    if (f.phase != _FoodPhase.idle) return false;
    return f.kind.healthy ? s.step == 3 : s.step == 2;
  }

  /// Hint for a food touched before its turn (null: nothing to say).
  String? _foodHint(_FoodState f) {
    final s = _scene;
    return switch (s.step) {
      1 => s.analyze1At < 0 ? 'first_analyze' : null,
      2 => f.kind.healthy ? 'first_clear' : null,
      4 => s.analyze2At < 0 ? 'first_analyze_again' : null,
      _ => null,
    };
  }

  /// The food under [at] (design px): one actually touched first, then
  /// one the step lets move, then the nearest (a 48 dp touch area reaches
  /// past small foods).
  _FoodState? _foodAt(Offset at) {
    final s = _scene;
    _FoodState? best;
    var bestScore = double.infinity;
    for (final f in s.foods) {
      if (f.phase != _FoodPhase.idle) continue;
      final c = s.cam.p(f.centre);
      final size = f.kind.radius * s.cam.scaleAt(f.centre);
      final d = (at - c).distance;
      if (d > math.max(size, _touch)) continue;
      final score = (d <= size ? 0 : 1000) + (_foodUnlocked(f) ? 0 : 100) + d;
      if (score < bestScore) {
        best = f;
        bestScore = score;
      }
    }
    return best;
  }

  /// HTML `activeObjects` of Scenario 2: Calcium at step 1, Vitamin D at
  /// step 2, never while the bone is healing.
  bool _bottleUnlocked(_BottleState b) {
    final s = _scene;
    if (b.phase != _BottlePhase.idle) return false;
    return switch (b.kind) {
      _Bottle.calcium => s.heal == _Heal.none,
      _Bottle.vitD => s.heal == _Heal.slow,
      _Bottle.iron => false,
    };
  }

  String? _bottleHint(_BottleState b) {
    final s = _scene;
    if (s.heal == _Heal.calcium || s.heal == _Heal.vitD) return 'wait_heal';
    if (s.heal == _Heal.healed) return null;
    if (b.kind == _Bottle.iron) return 'iron_hint';
    if (b.kind == _Bottle.vitD && s.heal == _Heal.none) return 'first_calcium';
    return null;
  }

  Rect _bottleBounds(_Camera cam, _V base) => _boxBounds(
    cam,
    base + const _V(0, _bottleHeight / 2, 0),
    const _V(_bottleR, _bottleHeight / 2, _bottleR),
  );

  _BottleState? _bottleAt(Offset at) {
    final s = _scene;
    _BottleState? best;
    var bestScore = double.infinity;
    for (final b in s.bottles) {
      if (b.phase != _BottlePhase.idle) continue;
      final r = _bottleBounds(s.cam, b.pos);
      final box = Rect.fromCenter(
        center: r.center,
        width: math.max(r.width, 2 * _touch),
        height: math.max(r.height, 2 * _touch),
      );
      if (!box.contains(at)) continue;
      final score =
          (r.contains(at) ? 0 : 1000) +
          (_bottleUnlocked(b) ? 0 : 100) +
          (at - r.center).distance;
      if (score < bestScore) {
        best = b;
        bestScore = score;
      }
    }
    return best;
  }

  /// HTML `pointerdown` raycast against the active objects.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null) return false;
    final at = event.localPosition;
    if (_scene.scenario == 0) {
      final f = _foodAt(at);
      return f != null && (_foodUnlocked(f) || _foodHint(f) != null);
    }
    final b = _bottleAt(at);
    return b != null && (_bottleUnlocked(b) || _bottleHint(b) != null);
  }

  /// HTML `handleDown`: the drag plane faces the camera through the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final at = d.localPosition;
    final Object item;
    final _V pos;
    if (s.scenario == 0) {
      final f = _foodAt(at);
      if (f == null) return;
      if (!_foodUnlocked(f)) {
        final hint = _foodHint(f);
        if (hint != null) _lab.showToast(_t(hint), isError: true);
        return;
      }
      f.phase = _FoodPhase.held;
      item = f;
      pos = f.pos;
    } else {
      final b = _bottleAt(at);
      if (b == null) return;
      if (!_bottleUnlocked(b)) {
        final hint = _bottleHint(b);
        if (hint != null) _lab.showToast(_t(hint), isError: true);
        return;
      }
      b.phase = _BottlePhase.held;
      item = b;
      pos = b.pos;
    }
    final n = s.cam.f;
    final plane = n.dot(pos);
    final hit = s.cam.onPlane(at, n, plane);
    _grab = _Grab(
      item,
      hit == null ? _V.zero : hit - pos,
      n,
      plane,
      s.generation,
    );
    _moved = false;
    _Sound.pickup.play();
  }

  void _onDragStart(DragStartDetails _) => _moved = true;

  /// HTML `handleMove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    final hit = s.cam.onPlane(d.localPosition, g.normal, g.d);
    if (hit == null) return;
    final pos = hit - g.offset;
    switch (g.item) {
      case _FoodState f:
        f.pos = pos;
      case _BottleState b:
        b.pos = pos;
    }
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `handleUp`.
  void _release() {
    final s = _scene;
    final g = _grab;
    final moved = _moved;
    _grab = null;
    _moved = false;
    if (g == null || g.generation != s.generation) return;
    switch (g.item) {
      case _FoodState f when !moved:
        if (f.phase == _FoodPhase.held) f.phase = _FoodPhase.idle;
      case _BottleState b when !moved:
        if (b.phase == _BottlePhase.held) b.phase = _BottlePhase.idle;
      case _FoodState f:
        _dropFood(f);
      case _BottleState b:
        _dropBottle(b);
    }
  }

  /// Where a food counts as in the Compost Bin: over its opening or body.
  Rect _binZone() => _boxBounds(
    _scene.cam,
    _binAt + const _V(0, _binHeight / 2, 0),
    const _V(_binTopR, _binHeight / 2, _binTopR),
  ).inflate(_catchPad * _scene.view.k);

  /// Where a food counts as on the plate: over it, up to a food's height.
  Rect _plateZone() => _boxBounds(
    _scene.cam,
    _plateAt + const _V(0, 0.6, 0),
    const _V(_plateTopR, 0.7, _plateTopR),
  ).inflate(_catchPad * _scene.view.k);

  /// Where a bottle counts as on the X-ray: over the leg (HTML
  /// `boneTarget`, 4 x 8 units).
  Rect _xrayZone() => _boxBounds(
    _scene.cam,
    _xrayTargetAt,
    _V(_xrayTargetHalf.x, _xrayTargetHalf.y, 0.5),
  ).inflate(_catchPad * _scene.view.k);

  void _sendFoodBack(_FoodState f) {
    f
      ..phase = _FoodPhase.returning
      ..from = f.pos
      ..to = f.kind.home
      ..phaseStart = _scene.time;
  }

  /// HTML `handleUp` for a food: into the bin at step 2, onto the plate at
  /// step 3, otherwise back with a hint. The drop is judged by where the
  /// food is on screen (the HTML measured 5 units to the bin and 6 to the
  /// plate in 3D, so a food let go beside the plate went into the bin and a
  /// healthy food let go on the bin landed on the plate).
  void _dropFood(_FoodState f) {
    final s = _scene;
    if (f.phase != _FoodPhase.held) return;
    final c = s.cam.p(f.centre);
    final bin = _binZone();
    final plate = _plateZone();
    final inBin = bin.contains(c);
    final inPlate = plate.contains(c);
    final toBin =
        inBin &&
        (!inPlate || (c - bin.center).distance <= (c - plate.center).distance);
    final toPlate = inPlate && !toBin;
    final name = _t(f.kind.nameKey);
    if (!f.kind.healthy) {
      if (!toBin) {
        _sendFoodBack(f);
        _lab.showToast(
          labFormat(_t('miss_bin'), {'food': name}),
          isError: true,
        );
        return;
      }
      f
        ..phase = _FoodPhase.toBin
        ..from = f.pos
        ..to = _binAt + const _V(0, _binHeight, 0)
        ..phaseStart = s.time;
      _Sound.drop.play();
      s.setMeters(s.plateNutrients());
      // HTML: `if (itemsInBin === 3) progressStep()`.
      if (s.binned == _Food.values.where((k) => !k.healthy).length) s.step = 3;
      _refresh();
      return;
    }
    if (!toPlate) {
      _sendFoodBack(f);
      _lab.showToast(
        labFormat(_t(toBin ? 'healthy_in_bin' : 'miss_plate'), {'food': name}),
        isError: true,
      );
      return;
    }
    final slot = s.plated;
    f
      ..phase = _FoodPhase.toPlate
      ..from = f.pos
      ..to = _plateSlots[slot]
      ..phaseStart = s.time;
    _Sound.drop.play();
    s.setMeters(s.plateNutrients());
    // HTML: `if (plateItems.length === 4) setTimeout(progressStep, 500)`.
    if (s.plated == _plateSlots.length) s.fullAt = s.time;
    _refresh();
  }

  /// HTML `handleUp` for a bottle: dropped on the X-ray it shrinks away and
  /// the healing runs; anywhere else it goes back with a hint.
  void _dropBottle(_BottleState b) {
    final s = _scene;
    if (b.phase != _BottlePhase.held) return;
    b
      ..from = b.pos
      ..phaseStart = s.time;
    if (!_xrayZone().contains(s.cam.p(b.centre))) {
      b.phase = _BottlePhase.returning;
      _lab.showToast(
        labFormat(_t('miss_xray'), {'bottle': _t(b.kind.nameKey)}),
        isError: true,
      );
      return;
    }
    b.phase = _BottlePhase.applying;
    _Sound.drop.play();
    if (b.kind == _Bottle.calcium) {
      // `startS2Progress('magic', 3000, 25, …, 'Calcium Absorbing...')`.
      _Sound.correct.play();
      s
        ..heal = _Heal.calcium
        ..healFrom = 0
        ..healTo = _calciumPercent
        ..healStart = s.time
        ..healSeconds = _calciumSeconds;
    } else {
      // `startS2Progress('success', 2000, 100, …, 'Vitamin D Synergy...')`.
      _Sound.success.play();
      s
        ..heal = _Heal.vitD
        ..healFrom = _calciumPercent
        ..healTo = 100
        ..healStart = s.time
        ..healSeconds = _vitDSeconds
        ..vitDAt = s.time;
    }
    _refresh();
  }

  // --------------------------------------------------------------- framing

  /// The canvas cards of this lab (canvas coordinates): the meters or the
  /// healing card at the top right and the action button above the HUD.
  List<Rect> _cardRects(BuildContext context, Size canvas) {
    final s = context.labScale;
    final insets = labOverlayInsets(context, _lab);
    final sc = _scene;
    final out = <Rect>[];
    final card = sc.scenario == 0
        ? (sc.metersShown ? _metersCardSize * s : null)
        : (sc.heal != _Heal.none ? _healCardSize * s : null);
    if (card != null) {
      out.add(
        Rect.fromLTWH(
          canvas.width - insets.right - card.width,
          insets.top,
          card.width,
          card.height,
        ),
      );
    }
    if (_showCanvasAction) {
      final bottom =
          canvas.height - insets.bottom - _hudBand * s - _actionGap * s;
      final cx = (insets.left + canvas.width - insets.right) / 2;
      final half = _actionBandSize.width * s / 2;
      out.add(
        Rect.fromLTRB(
          cx - half,
          bottom - _actionBandSize.height * s,
          cx + half,
          bottom,
        ),
      );
    }
    return out;
  }

  /// The action button floats on the canvas too while the sidebar is open
  /// (its sidebar copy can be below the fold on a phone).
  bool get _showCanvasAction =>
      _lab.isLabActive &&
      _lab.isSidebarOpen &&
      _lab.popup == null &&
      _actions().isNotEmpty;

  /// Fits [focus] into the part of the canvas no shell or lab card covers:
  /// the tool column, the HUD chip (sidebar open), the floating mission
  /// card (sidebar collapsed), this lab's cards. Returns the framing in
  /// design px for a canvas of [canvas] dp at stage scale [fit].
  _View _framing(BuildContext context, Size canvas, double fit, Rect focus) {
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
    final uiScale = context.labScale;
    final open = _lab.isSidebarOpen;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _cardGap + pad.top,
      canvas.width - insets.right,
      canvas.height -
          (open ? _hudBand * uiScale + _cardGap : _cardGap) -
          pad.bottom,
    );
    final obstacles = [
      for (final r in _cardRects(context, canvas)) r.inflate(_cardGap),
      if (!open && _lab.isLabActive)
        Rect.fromLTRB(
          0,
          0,
          insets.left,
          size.height < _compactBelow
              ? _missionTop + pad.top + size.height * _compactCardMax + _cardGap
              : canvas.height,
        ),
    ];
    final stageRect = (Offset.zero & _design).deflate(_cardGap);
    return _fitView(focus, [
      for (final r in _freeRects(base, obstacles))
        toDesign(r).intersect(stageRect),
    ]);
  }

  /// Every rectangle inside [base] bounded by the edges of [base] and of
  /// [obstacles] that no obstacle overlaps.
  static List<Rect> _freeRects(Rect base, List<Rect> obstacles) {
    final xs = <double>{base.left, base.right};
    final ys = <double>{base.top, base.bottom};
    for (final o in obstacles) {
      for (final x in [o.left, o.right]) {
        if (x > base.left && x < base.right) xs.add(x);
      }
      for (final y in [o.top, o.bottom]) {
        if (y > base.top && y < base.bottom) ys.add(y);
      }
    }
    final sx = xs.toList()..sort();
    final sy = ys.toList()..sort();
    final out = <Rect>[];
    for (var i = 0; i < sx.length; i++) {
      for (var j = i + 1; j < sx.length; j++) {
        for (var k = 0; k < sy.length; k++) {
          for (var l = k + 1; l < sy.length; l++) {
            final r = Rect.fromLTRB(sx[i], sy[k], sx[j], sy[l]);
            if (obstacles.every((o) => !o.overlaps(r))) out.add(r);
          }
        }
      }
    }
    return out;
  }

  /// Bounds (unframed design px, camera [cam]) of what the learner touches
  /// and reads in the current scenario: objects and their labels.
  Rect _focusRect(_Camera cam) {
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    void chip(_V at, String key) {
      final tp = _cache.text(_Ink.chip, _t(key));
      add(
        Rect.fromCenter(
          center: cam.p(at),
          width: tp.width + _labelSize * 1.2,
          height: tp.height + _labelSize * 0.6,
        ),
      );
    }

    if (_scene.scenario == 0) {
      for (final k in _Food.values) {
        add(_foodBounds(cam, k));
      }
      add(_boxBounds(cam, _pantryAt, _pantrySize * 0.5));
      add(_boxBounds(cam, _plateAt, const _V(_plateTopR, 0.1, _plateTopR)));
      add(
        _boxBounds(
          cam,
          _binAt + const _V(0, _binHeight / 2, 0),
          const _V(_binTopR, _binHeight / 2, _binTopR),
        ),
      );
      // Medu's head, also at the top of his jump.
      for (final y in const [_meduSlouch, _meduJumpTop]) {
        add(
          _boxBounds(
            cam,
            _medu(const _V(0, 2.8, 0), y),
            const _V(0.8, 0.8, 0.8),
          ),
        );
      }
      chip(_pantryLabelAt, 'lbl_pantry');
      chip(_binLabelAt, 'lbl_bin');
    } else {
      add(_boxBounds(cam, _xrayTargetAt, const _V(2.1, 4.6, 0.5)));
      add(_boxBounds(cam, _shelfAt, _shelfSize * 0.5));
      for (final k in _Bottle.values) {
        add(_bottleBounds(cam, k.home));
        chip(k.home + k.labelAt, k.nameKey);
      }
      chip(_xrayLabelAt, 'lbl_xray');
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

  LabAction _analyzeAction() => LabAction(
    label: _t('btn_analyze'),
    icon: Icons.monitor_heart,
    color: _Colors.blue600,
    foreground: _Colors.white,
    highlight: true,
    sound: _Sound.pop,
    onTap: _analyze,
  );

  /// HTML `#compare-btn-container` ('Review Learning'): offered once the
  /// scenario is done; it opens (and re-opens) the summary.
  LabAction _reviewAction() => LabAction(
    label: _t('btn_conclude'),
    icon: Icons.check_circle,
    color: _Colors.emerald600,
    foreground: _Colors.white,
    highlight: _lab.popup == null,
    silent: true,
    onTap: _review,
  );

  /// HTML `#btn-analyze-container` (steps 1 and 4 until tapped) and the
  /// 'Review Learning' button.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.done) return [_reviewAction()];
    final analyze =
        s.scenario == 0 &&
        ((s.step == 1 && s.analyze1At < 0) ||
            (s.step == 4 && s.analyze2At < 0));
    return analyze ? [_analyzeAction()] : const [];
  }

  List<Widget> _overlays(BuildContext context, double s) {
    final sc = _scene;
    if (!_lab.isLabActive) return const [];
    final inset = labOverlayInsets(context, _lab);
    final p = _lab.palette;
    final actions = _actions();
    return [
      // HTML `#meters-panel` (top right of the canvas, from the first
      // analysis).
      if (sc.scenario == 0 && sc.metersShown)
        Positioned(
          key: const ValueKey('ch3a5-meters'),
          top: inset.top,
          right: inset.right,
          child: _MetersCard(
            scene: sc,
            repaint: _frame,
            palette: p,
            scale: s,
            title: _t('nutrients'),
            labels: [
              _t('carbs'),
              _t('proteins'),
              _t('fats'),
              _t('vit_min'),
              _t('roughage'),
            ],
          ),
        ),
      // HTML `#progress-overlay` (from the first supplement).
      if (sc.scenario == 1 && sc.heal != _Heal.none)
        Positioned(
          key: const ValueKey('ch3a5-heal'),
          top: inset.top,
          right: inset.right,
          child: _HealCard(
            scene: sc,
            cache: _cache,
            repaint: _frame,
            palette: p,
            scale: s,
            title: _t('bone_healing'),
            status: _t(switch (sc.heal) {
              _Heal.calcium => 'heal_calcium',
              _Heal.slow => 'heal_slow',
              _Heal.vitD => 'heal_vitd',
              _ => 'heal_done',
            }),
            healed: sc.heal == _Heal.healed,
          ),
        ),
      if (_showCanvasAction)
        Positioned(
          key: const ValueKey('ch3a5-action'),
          left: inset.left,
          right: inset.right,
          bottom: inset.bottom + (_hudBand + _actionGap) * s,
          child: Center(
            child: LabActionButton(
              action: actions.first,
              scale: s,
              expand: false,
            ),
          ),
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
        final n = data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.restaurant,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          instruction: _scene.done ? _t('done_s${sc + 1}') : null,
          // HTML `#hud-instruction` (`hud[State.step]`, and the 'Review
          // Learning' line once the scenario is done).
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, n + 1)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch3a5-steps-$sc-${_scene.step}'),
            steps: data.steps,
            explanations: [
              for (var i = 1; i <= n; i++) _t('step_${sc + 1}_${i}_e'),
            ],
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
          overlays: _overlays(context, s),
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
          _cache.prepare(_lab.lang, _labelSize);
          final s = _scene;
          final canvas = box.biggest;
          if (s.scenario == 0) {
            s
              ..viewFar = _framing(
                context,
                canvas,
                fit,
                _focusRect(_Camera(_s1Eye, _s1LookAt)),
              )
              ..viewNear = _framing(
                context,
                canvas,
                fit,
                _focusRect(_Camera(_s1EyeNear, _s1LookAt)),
              );
          } else {
            s.viewFar = _framing(
              context,
              canvas,
              fit,
              _focusRect(_Camera(_s2Eye, _s2LookAt)),
            );
            s.viewNear = s.viewFar;
          }
          if (s.snapView) {
            s
              ..view = s.viewFar
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

/// HTML `#meters-panel`: "NUTRIENTS" and five meters (carbohydrates,
/// protein, fats, vitamins / minerals, roughage) with their names turned
/// on their side under them. The fills are painted every frame
/// ([_MetersPainter]).
class _MetersCard extends StatelessWidget {
  const _MetersCard({
    required this.scene,
    required this.repaint,
    required this.palette,
    required this.scale,
    required this.title,
    required this.labels,
  });

  final _Scene scene;
  final Listenable repaint;
  final LabPalette palette;
  final double scale;
  final String title;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    return SizedBox(
      width: _metersCardSize.width * s,
      height: _metersCardSize.height * s,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.fromLTRB(8 * s, 7 * s, 8 * s, 6 * s),
        borderColor: _Colors.cyan500.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 14 * s,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    color: p.textStrong,
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: labLetterSpacing(title, 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * s),
            Expanded(
              flex: 5,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _MetersPainter(
                    scene: scene,
                    repaint: repaint,
                    track: p.isDark ? _Colors.slate700 : _Colors.slate200,
                    trackBorder: p.isDark ? _Colors.slate600 : _Colors.slate300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4 * s),
            Expanded(
              flex: 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final label in labels)
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: TextStyle(
                                color: p.textMuted,
                                fontSize: 9 * s,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
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

/// HTML `#progress-overlay`: "BONE HEALING", the percentage and the bar
/// (painted every frame while the bone heals), then what is happening
/// ('Calcium Absorbing...', 'Healing is very slow... Needs Vitamin D!',
/// 'Vitamin D Synergy...', 'Healing Complete!' in green).
class _HealCard extends StatelessWidget {
  const _HealCard({
    required this.scene,
    required this.cache,
    required this.repaint,
    required this.palette,
    required this.scale,
    required this.title,
    required this.status,
    required this.healed,
  });

  final _Scene scene;
  final _PaintCache cache;
  final Listenable repaint;
  final LabPalette palette;
  final double scale;
  final String title;
  final String status;
  final bool healed;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    return SizedBox(
      width: _healCardSize.width * s,
      height: _healCardSize.height * s,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.fromLTRB(10 * s, 7 * s, 10 * s, 6 * s),
        borderColor: _Colors.cyan500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 16 * s,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: labLetterSpacing(title, 1),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44 * s,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _PercentPainter(
                        scene: scene,
                        cache: cache,
                        repaint: repaint,
                        color: p.ink(_Colors.cyan500),
                        fontSize: 12 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5 * s),
            SizedBox(
              height: 12 * s,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _HealBarPainter(
                    scene: scene,
                    repaint: repaint,
                    track: p.isDark ? _Colors.slate700 : _Colors.slate200,
                    trackBorder: p.isDark ? _Colors.slate600 : _Colors.slate300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5 * s),
            Expanded(
              child: Center(
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: healed ? p.success : p.text,
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

/// HTML teacher-board "Observation Step" accordion: one card per step with
/// its focus, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed and closed. A
/// step's result and explanation are shown once the step is done (the
/// HTML showed them before the learner had seen anything).
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
    super.key,
    required this.steps,
    required this.explanations,
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
  final List<String> explanations;
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
    final tone = current ? accent : (past ? p.info : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.info.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];
    final body = TextStyle(
      color: p.text,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );

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
                                    ? p.info.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
                                : (past
                                      ? p.info.withValues(alpha: 0.5)
                                      : p.cardBorder.withValues(alpha: dim)),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.info)
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
                    style: body.copyWith(
                      color: p.textStrong,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(step.action, style: body),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    past ? step.observation : w.pendingText,
                    style: body.copyWith(
                      color: past ? p.text : p.textMuted,
                      fontWeight: past ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: past ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  if (past) ...[
                    SizedBox(height: 8 * s),
                    Container(
                      padding: EdgeInsets.only(top: 8 * s),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: p.cardBorder)),
                      ),
                      child: Text(
                        w.explanations[i - 1],
                        style: body.copyWith(
                          color: p.textMuted,
                          fontSize: 11 * f,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Scenario 1 summary infographic (HTML `summary-visual-area`): a gut with
/// roughage, food moving through it (green), and one without, food stuck
/// in it (red, constipation).
class _DigestionInfo extends StatefulWidget {
  const _DigestionInfo({
    required this.scale,
    required this.healthy,
    required this.unhealthy,
    required this.smooth,
    required this.stuck,
  });

  final double scale;
  final String healthy;
  final String unhealthy;
  final String smooth;
  final String stuck;

  @override
  State<_DigestionInfo> createState() => _DigestionInfoState();
}

class _DigestionInfoState extends State<_DigestionInfo>
    with SingleTickerProviderStateMixin {
  /// HTML `animate-[bounce_2s_infinite]` of the food balls.
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  Widget _panel(bool healthy) {
    final s = widget.scale;
    final edge = healthy ? _Colors.green500 : _Colors.red500;
    return Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: _Colors.infoBg,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: edge, width: 2),
        boxShadow: [
          BoxShadow(color: edge.withValues(alpha: 0.3), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Text(
            healthy ? widget.healthy : widget.unhealthy,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: healthy ? _Colors.green400 : _Colors.red400,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6 * s),
          SizedBox(
            width: 56 * s,
            height: 92 * s,
            child: CustomPaint(
              painter: _GutPainter(healthy: healthy, flow: _flow),
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            healthy ? widget.smooth : widget.stuck,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: healthy ? _Colors.green300 : _Colors.red300,
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _panel(true)),
        SizedBox(width: 10 * s),
        Expanded(child: _panel(false)),
      ],
    );
  }
}

/// Scenario 2 summary infographic: without Vitamin D the calcium bounces
/// off a locked bone; with Vitamin D (the sun and a key) the lock is open
/// and the calcium goes in.
class _CalciumInfo extends StatefulWidget {
  const _CalciumInfo({
    required this.scale,
    required this.without,
    required this.withVitD,
  });

  final double scale;
  final String without;
  final String withVitD;

  @override
  State<_CalciumInfo> createState() => _CalciumInfoState();
}

class _CalciumInfoState extends State<_CalciumInfo>
    with SingleTickerProviderStateMixin {
  /// HTML `animate-[bounce_1s_infinite]` of the calcium dots.
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Widget _panel(bool vitD) {
    final s = widget.scale;
    return Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: _Colors.infoPanel,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: vitD ? _Colors.cyan500 : _Colors.slate600),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 76 * s,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CalciumPainter(vitD: vitD, bounce: _bounce),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.72),
                  child: Icon(
                    vitD ? Icons.lock_open : Icons.lock,
                    size: 24 * s,
                    color: vitD ? _Colors.green400 : _Colors.slate500,
                  ),
                ),
                if (vitD)
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 18 * s,
                          color: _Colors.yellow400,
                        ),
                        Icon(
                          Icons.vpn_key,
                          size: 15 * s,
                          color: _Colors.yellow400,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            vitD ? widget.withVitD : widget.without,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: vitD ? _Colors.cyan400 : _Colors.slate400,
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _panel(false)),
        SizedBox(width: 10 * s),
        Expanded(child: _panel(true)),
      ],
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

  /// Round-capped thick lines (Medu's limbs, the carrot, stems).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// Soft glows: the held object, Medu's sore tummy, the sun.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  /// HTML `AdditiveBlending`: the fracture glow, the particles, the beam.
  final Paint additive = Paint()..blendMode = BlendMode.plus;
  final Paint additiveGlow = Paint()
    ..blendMode = BlendMode.plus
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  /// X-ray backdrop: a unit radial gradient, scaled to the plane's size.
  final Paint xray = Paint()
    ..shader = ui.Gradient.radial(Offset.zero, 1, const [
      _Colors.xrayInner,
      _Colors.xrayOuter,
    ]);

  /// Outline of the bone pieces.
  final Paint boneOutline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..color = _Colors.slate400;
  final Path path = Path();
  final Path aux = Path();
}

/// Kinds of scene text.
enum _Ink {
  /// Object names: white bold on the dark sprite chip.
  chip;

  TextStyle style(double size) => TextStyle(
    color: _Colors.white,
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: LabFont.active.family,
    fontFamilyFallback: LabFont.active.fallback,
  );
}

/// What the painters make once and reuse: pens, text painters and the
/// draw-order list. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _texts = {};

  /// Foods in drawing order (refilled every frame).
  final List<_FoodState> order = [];

  LabLang? _lang;
  double _labelSize = _labelPx;

  /// Most text painters kept; the cache is emptied past that.
  static const int _maxTexts = 300;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeTexts();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter text(_Ink ink, String text) =>
      styled(text, ink.style(_labelSize));

  /// [text] laid out in [style] (labels, the healing percentage).
  TextPainter styled(String text, TextStyle style) {
    final key = '${style.hashCode}|$text';
    final cached = _texts[key];
    if (cached != null) return cached;
    if (_texts.length >= _maxTexts) _disposeTexts();
    return _texts[key] = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
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

/// Normal of a surface facing the viewer, a little upward (spheres).
const _V _towardViewer = _V(0, 0.45, 0.89);

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

  /// Flat quad (a floor, a wall, a label band) lit with normal [n].
  void quad(_V a, _V b, _V c, _V d, Color color, _V n) {
    final path = pens.path..reset();
    _move(path, 0, cam.p(a));
    _move(path, 1, cam.p(b));
    _move(path, 2, cam.p(c));
    _move(path, 3, cam.p(d));
    path.close();
    canvas.drawPath(path, pens.fill..color = _lit(color, n));
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
  /// cap, or the opening of an [open] bowl or bin.
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
        pens.fill..color = labShade(color, -0.45).withValues(alpha: opacity),
      );
      canvas.drawOval(
        topOval,
        pens.stroke
          ..strokeWidth = 1.4
          ..color = labShade(color, 0.2).withValues(alpha: opacity),
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

  /// Round-capped rod of [radius] between two world points.
  void limb(_V a, _V b, double radius, Color color) {
    final w = 2 * radius * cam.scaleAt(_V.lerp(a, b, 0.5));
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      pens.limb
        ..strokeWidth = math.max(1.0, w)
        ..color = _lit(color, _towardViewer),
    );
  }

  /// SphereGeometry: a lit disc with a soft highlight.
  void ball(_V c, double radius, Color color) {
    final o = cam.p(c);
    final r = radius * cam.scaleAt(c);
    canvas.drawCircle(o, r, pens.fill..color = _lit(color, _towardViewer));
    canvas.drawCircle(
      o + Offset(-0.3 * r, -0.35 * r),
      r * 0.42,
      pens.fill..color = labShade(color, 0.4).withValues(alpha: 0.5),
    );
  }

  /// Horizontal disc of [radius] at [c] (a dal surface, a plate rim).
  void disc(_V c, double radius, Color color) {
    canvas.drawOval(
      Rect.fromCenter(
        center: cam.p(c),
        width: 2 * radius * cam.scaleAt(c),
        height: 2 * cam.ellipseHalf(c, radius),
      ),
      pens.fill..color = _lit(color, _V.up),
    );
  }

  /// Tapered rod from [a] (half width [ra]) to [b] (half width [rb]) in
  /// screen space, drawn with [paint].
  void taper(_V a, double ra, _V b, double rb, Paint paint) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    final len = d.distance;
    if (len < 1e-6) return;
    final n = Offset(-d.dy / len, d.dx / len);
    final wa = ra * cam.scaleAt(a), wb = rb * cam.scaleAt(b);
    final path = pens.path
      ..reset()
      ..moveTo(pa.dx + n.dx * wa, pa.dy + n.dy * wa)
      ..lineTo(pb.dx + n.dx * wb, pb.dy + n.dy * wb)
      ..lineTo(pb.dx - n.dx * wb, pb.dy - n.dy * wb)
      ..lineTo(pa.dx - n.dx * wa, pa.dy - n.dy * wa)
      ..close();
    canvas.drawPath(path, paint);
  }

  /// Soft blurred shadow of a round footprint of [radius] at [at].
  void shadow(_V at, double radius) {
    final c = _V(at.x + 0.2, at.y + 0.01, at.z - 0.2);
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

/// Paints the HTML Three.js scene of the current scenario: S1 the kitchen
/// (room, Pantry, Medu, table, plate, foods, Compost Bin), S2 the X-ray
/// (leg, fractured bone, glow, particles, shelf of bottles, sun); then the
/// sprite labels.
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
    final g = _Gfx(canvas, scene.cam, _pens);
    if (scene.scenario == 0) {
      _paintKitchen(canvas, size, g);
    } else {
      _paintXray(canvas, size, g);
    }
  }

  // --------------------------------------------------------- scenario 1

  void _paintKitchen(Canvas canvas, Size size, _Gfx g) {
    final s = scene;
    final cam = s.cam;
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneBg : _Colors.sceneBgLight,
    );
    // Floor (up to just in front of the camera) and wall.
    final near = math.min(_roomHalf, cam.eye.z - 1.5);
    g.quad(
      const _V(-_roomPaintHalf, 0, _wallZ),
      const _V(_roomPaintHalf, 0, _wallZ),
      _V(_roomPaintHalf, 0, near),
      _V(-_roomPaintHalf, 0, near),
      _Colors.floor,
      _V.up,
    );
    g.quad(
      const _V(-_roomPaintHalf, 0, _wallZ),
      const _V(_roomPaintHalf, 0, _wallZ),
      const _V(_roomPaintHalf, _wallHeight, _wallZ),
      const _V(-_roomPaintHalf, _wallHeight, _wallZ),
      _Colors.wall,
      const _V(0, 0, 1),
    );
    // The Pantry and the foods still on it.
    g.box(_pantryAt, _pantrySize, _Colors.table);
    for (final f in s.foods) {
      if (f.kind.healthy && f.phase == _FoodPhase.idle) _paintFood(g, f);
    }
    _paintMedu(g);
    // Table: legs (back, then front) and top.
    for (final z in const [-_tableLegZ, _tableLegZ]) {
      for (final x in const [-_tableLegX, _tableLegX]) {
        g.frustum(
          _V(x, 0, z),
          _tableLegR,
          _tableLegR,
          _tableAt.y - _tableSize.y / 2,
          _Colors.table,
        );
      }
    }
    g.box(_tableAt, _tableSize, _Colors.table, edge: 0.25);
    // The plate and what is on it, far to near.
    g.shadow(_plateAt - const _V(0, _plateHeight / 2, 0), _plateBottomR * 1.2);
    g.frustum(
      _plateAt - const _V(0, _plateHeight / 2, 0),
      _plateBottomR,
      _plateTopR,
      _plateHeight,
      _Colors.plate,
    );
    g.disc(
      _plateAt + const _V(0, _plateHeight / 2 + 0.005, 0),
      _plateBottomR,
      labShade(_Colors.plate, -0.06),
    );
    final order = cache.order..clear();
    for (final f in s.foods) {
      final onPlate = f.kind.healthy
          ? f.phase == _FoodPhase.toPlate || f.phase == _FoodPhase.onPlate
          : f.phase == _FoodPhase.idle;
      if (onPlate) order.add(f);
    }
    order.sort((a, b) => cam.depth(b.pos).compareTo(cam.depth(a.pos)));
    for (final f in order) {
      _paintFood(g, f);
    }
    _paintBin(g);
    // Foods on the move, the held one last.
    for (final f in s.foods) {
      if (f.phase == _FoodPhase.returning || f.phase == _FoodPhase.toBin) {
        _paintFood(g, f);
      }
    }
    for (final f in s.foods) {
      if (f.phase == _FoodPhase.held) _paintFood(g, f);
    }
    if (!showLabels) return;
    _chip(canvas, cam.p(_pantryLabelAt), _t('lbl_pantry'));
    _chip(canvas, cam.p(_binLabelAt), _t('lbl_bin'));
    for (final f in s.foods) {
      if (f.phase != _FoodPhase.held) continue;
      _chip(
        canvas,
        cam.p(f.centre + _V(0, f.kind.radius + 0.45, 0)),
        _t(f.kind.nameKey),
      );
    }
  }

  /// HTML `buildMedu()`: legs, arms, torso, head with short hair, eyes,
  /// nose and a smile (or a frown with a sore tummy). The face is drawn at
  /// least a few px large so the mood reads on a phone.
  void _paintMedu(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final canvas = g.canvas;
    final y = s.meduY;
    _V at(double x, double yy, double z) => _medu(_V(x, yy, z), y);
    const k = _meduScale;
    g.limb(at(-0.25, -0.2, 0), at(-0.25, 1, 0), 0.2 * k, _Colors.pants);
    g.limb(at(0.25, -0.2, 0), at(0.25, 1, 0), 0.2 * k, _Colors.pants);
    // Arms: CylinderGeometry(0.15, 0.15, 1.2) at (±0.7, 1.8), tilted ±π/8.
    for (final sx in const [-1.0, 1.0]) {
      g.limb(
        at(0.47 * sx, 1.246, 0),
        at(0.93 * sx, 2.354, 0),
        0.15 * k,
        _Colors.skin,
      );
    }
    g.frustum(at(0, 0.85, 0), 0.5 * k, 0.5 * k, 1.5 * k, _Colors.shirt);
    if (s.meduSad) {
      // Stomach ache (added): a pulsing red glow on his tummy.
      final tummy = at(0, 1.4, 0.5);
      final pulse = 0.5 + 0.5 * math.sin(s.time * 2 * math.pi / 1.2);
      canvas.drawCircle(
        cam.p(tummy),
        0.42 * k * cam.scaleAt(tummy),
        _pens.glow..color = _Colors.ache.withValues(alpha: 0.35 + 0.4 * pulse),
      );
    }
    final hc = at(0, 2.8, 0);
    final ho = cam.p(hc);
    final hr = 0.6 * k * cam.scaleAt(hc);
    canvas.drawCircle(
      ho,
      hr,
      _pens.fill..color = _lit(_Colors.skin, _towardViewer),
    );
    // Hair: the top of the head (cut short, above the eyes) and tufts.
    canvas.save();
    canvas.clipPath(
      _pens.aux
        ..reset()
        ..addOval(Rect.fromCircle(center: ho, radius: hr)),
    );
    canvas.drawRect(
      Rect.fromLTRB(ho.dx - hr, ho.dy - hr, ho.dx + hr, ho.dy - hr * 0.34),
      _pens.fill..color = _Colors.hair,
    );
    canvas.restore();
    for (final (x, yy, z, r) in const [
      (0.0, 3.3, 0.3, 0.15),
      (0.15, 3.25, 0.35, 0.12),
      (-0.15, 3.25, 0.35, 0.12),
    ]) {
      final c = at(x, yy, z);
      canvas.drawCircle(
        cam.p(c),
        r * k * cam.scaleAt(c),
        _pens.fill..color = _Colors.hair,
      );
    }
    // Eyes, nose and mouth (HTML sizes, but never smaller than a share of
    // the head).
    for (final sx in const [-1.0, 1.0]) {
      final e = cam.p(at(0.2 * sx, 2.9, 0.55));
      final er = math.max(0.07 * k * cam.scaleAt(hc), hr * 0.14);
      canvas.drawCircle(e, er, _pens.fill..color = _Colors.white);
      canvas.drawCircle(
        e + Offset(0, er * 0.15),
        er * 0.58,
        _pens.fill..color = _Colors.pupil,
      );
    }
    canvas.drawCircle(
      cam.p(at(0, 2.78, 0.59)),
      math.max(0.06 * k * cam.scaleAt(hc), hr * 0.09),
      _pens.fill..color = _Colors.nose,
    );
    final m = cam.p(at(0, 2.65, 0.58));
    final mr = math.max(0.1 * k * cam.scaleAt(hc), hr * 0.27);
    final mouth = _pens.limb
      ..strokeWidth = math.max(1.2, hr * 0.08)
      ..color = _Colors.pupil;
    if (s.meduSad) {
      // Frown (HTML `meduFace.rotation.z = 0`).
      canvas.drawArc(
        Rect.fromCircle(center: m + Offset(0, mr * 0.75), radius: mr),
        1.15 * math.pi,
        0.7 * math.pi,
        false,
        mouth,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: m - Offset(0, mr * 0.45), radius: mr),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        mouth,
      );
    }
  }

  /// The green Compost Bin with its trash-can icon card on the front (HTML
  /// `createIconSprite('trash')`).
  void _paintBin(_Gfx g) {
    final canvas = g.canvas;
    g.shadow(_binAt, _binBottomR);
    g.frustum(
      _binAt,
      _binBottomR,
      _binTopR,
      _binHeight,
      _Colors.bin,
      open: true,
    );
    final c = _binAt + const _V(0, 1.25, 1.3);
    final o = g.cam.p(c);
    final side = 0.9 * g.cam.scaleAt(c);
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: side, height: side),
      Radius.circular(side * 0.125),
    );
    canvas.drawRRect(card, _pens.fill..color = _Colors.white);
    canvas.drawRRect(
      card,
      _pens.stroke
        ..strokeWidth = math.max(1.0, side * 0.03)
        ..color = _Colors.glowBlue,
    );
    // The trash can (Phosphor `trash`, a 256-unit drawing).
    final box = Rect.fromCenter(
      center: o,
      width: side * 0.62,
      height: side * 0.62,
    );
    Offset q(double x, double y) =>
        Offset(box.left + x / 256 * box.width, box.top + y / 256 * box.height);
    final path = _pens.aux
      ..reset()
      ..moveTo(q(216, 56).dx, q(216, 56).dy)
      ..lineTo(q(40, 56).dx, q(40, 56).dy)
      ..moveTo(q(104, 104).dx, q(104, 104).dy)
      ..lineTo(q(104, 168).dx, q(104, 168).dy)
      ..moveTo(q(152, 104).dx, q(152, 104).dy)
      ..lineTo(q(152, 168).dx, q(152, 168).dy)
      ..moveTo(q(200, 56).dx, q(200, 56).dy)
      ..lineTo(q(200, 216).dx, q(200, 216).dy)
      ..lineTo(q(56, 216).dx, q(56, 216).dy)
      ..lineTo(q(56, 56).dx, q(56, 56).dy)
      ..moveTo(q(168, 56).dx, q(168, 56).dy)
      ..lineTo(q(168, 24).dx, q(168, 24).dy)
      ..lineTo(q(88, 24).dx, q(88, 24).dy)
      ..lineTo(q(88, 56).dx, q(88, 56).dy);
    canvas.drawPath(
      path,
      _pens.stroke
        ..strokeWidth = math.max(1.0, box.width * 16 / 256)
        ..color = _Colors.bin,
    );
  }

  /// HTML `createFoodItem(type)`, drawn at the food's base.
  void _paintFood(_Gfx g, _FoodState f) {
    if (f.scale <= 0.01) return;
    final canvas = g.canvas;
    final cam = g.cam;
    final b = f.pos;
    final k = f.kind;
    final mid = cam.p(f.centre);
    final scaled = f.scale < 1;
    if (scaled) {
      canvas.save();
      canvas.translate(mid.dx, mid.dy);
      canvas.scale(f.scale);
      canvas.translate(-mid.dx, -mid.dy);
    }
    if (f.phase == _FoodPhase.held) {
      canvas.drawCircle(
        mid,
        (k.radius + 0.2) * cam.scaleAt(f.centre),
        _pens.glow..color = _Colors.cyan400.withValues(alpha: 0.55),
      );
    }
    switch (k) {
      case _Food.noodles:
        // TorusKnotGeometry(0.35, 0.12): a yellow tangle.
        final c = b + const _V(0, 0.3, 0);
        final o = cam.p(c);
        final r = 0.47 * cam.scaleAt(c);
        canvas.drawOval(
          Rect.fromCenter(center: o, width: 2 * r, height: 1.3 * r),
          _pens.fill..color = _lit(_Colors.noodles, _towardViewer),
        );
        final loop = _pens.stroke
          ..strokeWidth = math.max(1.0, r * 0.13)
          ..color = labShade(_Colors.noodles, -0.3);
        for (final (dx, dy) in const [
          (-0.35, -0.12),
          (0.3, -0.18),
          (-0.05, 0.12),
          (0.38, 0.14),
        ]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: o + Offset(dx * r, dy * r),
              width: 0.75 * r,
              height: 0.45 * r,
            ),
            loop,
          );
        }
      case _Food.biscuits:
        // Two CylinderGeometry(0.25, 0.25, 0.1) discs.
        g.frustum(b + const _V(-0.1, 0, 0), 0.25, 0.25, 0.1, _Colors.biscuit);
        g.frustum(
          b + const _V(0.1, 0.05, 0.1),
          0.25,
          0.25,
          0.1,
          _Colors.biscuit,
        );
        final top = b + const _V(0.1, 0.16, 0.1);
        final o = cam.p(top);
        final dot = 0.035 * cam.scaleAt(top);
        for (final dx in const [-0.1, 0.0, 0.1]) {
          canvas.drawCircle(
            o + Offset(dx * cam.scaleAt(top), 0),
            math.max(0.6, dot),
            _pens.fill..color = labShade(_Colors.biscuit, -0.45),
          );
        }
      case _Food.bread:
        // Crust BoxGeometry(0.55, 0.12, 0.55) and crumb (0.5, 0.15, 0.5).
        g.box(
          b + const _V(0, 0.06, 0),
          const _V(0.55, 0.12, 0.55),
          _Colors.crust,
        );
        g.box(
          b + const _V(0, 0.075, 0),
          const _V(0.5, 0.15, 0.5),
          _Colors.bread,
        );
      case _Food.chapati:
        // CylinderGeometry(0.7, 0.7, 0.05) with a few brown spots.
        g.frustum(b, 0.7, 0.7, 0.05, _Colors.chapati);
        final top = b + const _V(0, 0.05, 0);
        final sc = cam.scaleAt(top);
        final h = cam.ellipseHalf(top, 1);
        final o = cam.p(top);
        for (final (dx, dz) in const [
          (-0.3, -0.2),
          (0.25, 0.1),
          (0, 0.35),
          (0.35, -0.3),
        ]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: o + Offset(dx * sc, dz * h),
              width: 0.12 * sc,
              height: 0.08 * h,
            ),
            _pens.fill..color = labShade(_Colors.chapati, -0.35),
          );
        }
      case _Food.dal:
        // Steel bowl CylinderGeometry(0.5, 0.35, 0.3) and the dal in it.
        g.frustum(b, 0.35, 0.5, 0.3, _Colors.steel, open: true);
        g.disc(b + const _V(0, 0.27, 0), 0.44, _Colors.dal);
      case _Food.veg:
        // Carrot, potato and two peas (the HTML group, scaled 1.5).
        g.limb(
          b + const _V(-0.375, 0.12, -0.22),
          b + const _V(0.375, 0.12, -0.22),
          0.1,
          _Colors.carrot,
        );
        g.ball(b + const _V(0, 0.3, 0.075), 0.3, _Colors.potato);
        g.ball(b + const _V(0.3, 0.15, 0.3), 0.15, _Colors.pea);
        g.ball(b + const _V(-0.3, 0.15, 0.15), 0.15, _Colors.pea);
      case _Food.apple:
        // SphereGeometry(0.35), stem and leaf.
        g.ball(b + const _V(0, 0.35, 0), 0.35, _Colors.apple);
        g.limb(
          b + const _V(0, 0.66, 0),
          b + const _V(0, 0.82, 0),
          0.03,
          _Colors.stem,
        );
        final leaf = b + const _V(0.13, 0.8, 0);
        final sc = cam.scaleAt(leaf);
        canvas.drawOval(
          Rect.fromCenter(
            center: cam.p(leaf),
            width: 0.22 * sc,
            height: 0.11 * sc,
          ),
          _pens.fill..color = _lit(_Colors.leaf, _towardViewer),
        );
    }
    if (scaled) canvas.restore();
  }

  // --------------------------------------------------------- scenario 2

  void _paintXray(Canvas canvas, Size size, _Gfx g) {
    final s = scene;
    final cam = s.cam;
    // X-ray backdrop: radial gradient over the 40 x 25 plane, and beyond.
    final c = cam.p(_xrayAt);
    final rx = (cam.p(_xrayAt + const _V(_xrayHalfW, 0, 0)).dx - c.dx).abs();
    final ry = (c.dy - cam.p(_xrayAt + const _V(0, _xrayHalfH, 0)).dy).abs();
    final bleed = labBleed(size);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(rx, ry);
    canvas.drawRect(
      Rect.fromLTRB(
        (bleed.left - c.dx) / rx,
        (bleed.top - c.dy) / ry,
        (bleed.right - c.dx) / rx,
        (bleed.bottom - c.dy) / ry,
      ),
      _pens.xray,
    );
    canvas.restore();
    if (s.sunbeam) _paintBeam(g);
    // Leg silhouette (CylinderGeometry(1.6, 1.3, 7), tilted -0.05).
    final legDir = const _V(0.05, 1, 0) * (_legLength / 2);
    final legBottom = _legAt - legDir;
    final legTop = _legAt + legDir;
    g.taper(
      legBottom,
      _legBottomR,
      legTop,
      _legTopR,
      _pens.fill..color = _Colors.legXray.withValues(alpha: 0.25),
    );
    for (final (at, r) in [(legBottom, _legBottomR), (legTop, _legTopR)]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: cam.p(at),
          width: 2 * r * cam.scaleAt(at),
          height: 2 * cam.ellipseHalf(at, r),
        ),
        _pens.fill..color = _Colors.legXray.withValues(alpha: 0.18),
      );
    }
    _paintBones(g);
    if (s.heal != _Heal.healed) {
      canvas.drawCircle(
        cam.p(_fractureAt),
        _glowRadius * cam.scaleAt(_fractureAt),
        _pens.additiveGlow..color = s.glowColor.withValues(alpha: _glowOpacity),
      );
    }
    if (s.particlesOn) _paintParticles(g);
    // Shelf: brackets, then the board.
    for (final sx in const [-1.0, 1.0]) {
      g.box(
        _shelfAt + _bracketOffset + _V(sx * _bracketX, 0, 0),
        _bracketSize,
        _Colors.shelf,
      );
    }
    g.box(_shelfAt, _shelfSize, _Colors.shelf);
    for (final b in s.bottles) {
      if (b.phase == _BottlePhase.idle) _paintBottle(g, b);
    }
    for (final b in s.bottles) {
      if (b.phase == _BottlePhase.returning ||
          b.phase == _BottlePhase.applying) {
        _paintBottle(g, b);
      }
    }
    for (final b in s.bottles) {
      if (b.phase == _BottlePhase.held) _paintBottle(g, b);
    }
    if (s.sunbeam) {
      // Sun core and glow (HTML `sunbeamGroup`).
      final o = cam.p(_sunAt);
      final sc = cam.scaleAt(_sunAt);
      canvas.drawCircle(
        o,
        _sunGlowR * sc,
        _pens.glow..color = _Colors.sunGlow.withValues(alpha: 0.4),
      );
      canvas.drawCircle(o, _sunR * sc, _pens.fill..color = _Colors.sunCore);
    }
    if (!showLabels) return;
    _chip(canvas, cam.p(_xrayLabelAt), _t('lbl_xray'));
    for (final b in s.bottles) {
      if (b.phase == _BottlePhase.applying || b.phase == _BottlePhase.gone) {
        continue;
      }
      _chip(canvas, cam.p(b.pos + b.kind.labelAt), _t(b.kind.nameKey));
    }
  }

  /// The sunbeam from the sun down to the fracture.
  void _paintBeam(_Gfx g) {
    final cam = g.cam;
    final a = cam.p(_sunAt);
    final f = cam.p(_fractureAt);
    final d = f - a;
    final len = d.distance;
    if (len < 1e-6) return;
    final u = Offset(d.dx / len, d.dy / len);
    final n = Offset(-u.dy, u.dx);
    final ws = _beamSunHalf * cam.scaleAt(_sunAt);
    final wf = _beamLegHalf * cam.scaleAt(_fractureAt);
    final end = f + u * (wf * 0.6);
    final path = _pens.path
      ..reset()
      ..moveTo(a.dx + n.dx * ws, a.dy + n.dy * ws)
      ..lineTo(end.dx + n.dx * wf, end.dy + n.dy * wf)
      ..lineTo(end.dx - n.dx * wf, end.dy - n.dy * wf)
      ..lineTo(a.dx - n.dx * ws, a.dy - n.dy * ws)
      ..close();
    g.canvas.drawPath(
      path,
      _pens.additive..color = _Colors.sunGlow.withValues(alpha: 0.15),
    );
  }

  /// The two pieces of the tibia, each with its joint (knee / ankle): a
  /// darker outline pass, then the bone.
  void _paintBones(_Gfx g) {
    final s = scene;
    const dir = _V(0.05, 1, 0);
    final top = s.boneTop;
    final bottom = s.boneBottom;
    final half = dir * (_boneLength / 2);
    void shapes(Paint paint) {
      // Upper piece: CylinderGeometry(0.5, 0.4, 4); lower piece
      // CylinderGeometry(0.4, 0.6, 4); then the knee and ankle spheres.
      g.taper(top - half, 0.4, top + half, 0.5, paint);
      g.taper(bottom - half, 0.6, bottom + half, 0.4, paint);
      for (final (c, r) in [
        (top + const _V(-0.2, 2, 0), 0.8),
        (top + const _V(0.4, 2, 0), 0.7),
        (bottom + const _V(-0.2, -2, 0), 0.8),
        (bottom + const _V(0.4, -2, 0), 0.7),
      ]) {
        g.canvas.drawCircle(g.cam.p(c), r * g.cam.scaleAt(c), paint);
      }
    }

    shapes(_pens.boneOutline);
    shapes(_pens.fill..color = _Colors.bone);
  }

  /// HTML `particles`: calcium (blue) falling through the fracture; with
  /// Vitamin D they turn sunny yellow and swirl.
  void _paintParticles(_Gfx g) {
    final s = scene;
    final cam = g.cam;
    final color = s.vitDAt >= 0 ? _Colors.particleSun : _Colors.particleCalcium;
    final angle = s.vitDAt >= 0 ? (s.time - s.vitDAt) * _particleSwirl : 0.0;
    final cosA = math.cos(angle), sinA = math.sin(angle);
    final paint = _pens.additive..color = color.withValues(alpha: 0.9);
    final r = math.max(1.2, _particleSize / 2 * cam.scaleAt(_fractureAt));
    final fall = _particleFall * s.time;
    for (final p in s.particles) {
      var y = p.y - fall;
      if (y < -1) y = 1 - ((-1 - y) % 2);
      final w =
          _fractureAt +
          _V(p.x * cosA + p.z * sinA, y, -p.x * sinA + p.z * cosA);
      g.canvas.drawCircle(cam.p(w), r, paint);
    }
  }

  /// HTML `createBottle`: body, white label band with a stripe of the
  /// bottle's colour, neck and white cap.
  void _paintBottle(_Gfx g, _BottleState b) {
    if (b.scale <= 0.01) return;
    final canvas = g.canvas;
    final cam = g.cam;
    final mid = cam.p(b.centre);
    final scaled = b.scale < 1;
    if (scaled) {
      canvas.save();
      canvas.translate(mid.dx, mid.dy);
      canvas.scale(b.scale);
      canvas.translate(-mid.dx, -mid.dy);
    }
    if (b.phase == _BottlePhase.held) {
      canvas.drawCircle(
        mid,
        0.9 * cam.scaleAt(b.centre),
        _pens.glow..color = _Colors.cyan400.withValues(alpha: 0.55),
      );
    }
    final color = b.kind.color;
    final p = b.pos;
    g.shadow(p, _bottleR);
    g.frustum(p, _bottleR, _bottleR, _bottleBody, color);
    const front = _bottleR * 0.55;
    const side = _bottleR * 0.85;
    g.quad(
      p + const _V(-side, 0.25, front),
      p + const _V(side, 0.25, front),
      p + const _V(side, 0.75, front),
      p + const _V(-side, 0.75, front),
      _Colors.white,
      const _V(0, 0, 1),
    );
    g.quad(
      p + const _V(-side, 0.45, front),
      p + const _V(side, 0.45, front),
      p + const _V(side, 0.55, front),
      p + const _V(-side, 0.55, front),
      color,
      const _V(0, 0, 1),
    );
    g.frustum(
      p + const _V(0, _bottleBody, 0),
      _bottleR,
      _neckTopR,
      _neckHeight,
      color,
    );
    g.frustum(
      p + const _V(0, _bottleBody + _neckHeight, 0),
      _capR,
      _capR,
      _capHeight,
      _Colors.cap,
    );
    if (scaled) canvas.restore();
  }

  // -------------------------------------------------------------- texts

  /// HTML text sprite: dark chip with a cyan border and white bold text
  /// centred on [at]; chips are kept left of the tool column.
  void _chip(Canvas canvas, Offset at, String text) {
    final tp = cache.text(_Ink.chip, text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final left = math.min(at.dx - w / 2, labelRight - 4 - w);
    final rect = Rect.fromLTWH(left, at.dy - h / 2, w, h);
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(h / 2, size * 0.8)),
    );
    canvas.drawRRect(rr, _pens.fill..color = _Colors.labelBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.labelBorder,
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

/// The five meters of the meters card: tracks and fills (the roughage fill
/// red and pulsing below 30 %, green above).
class _MetersPainter extends CustomPainter {
  _MetersPainter({
    required this.scene,
    required Listenable repaint,
    required this.track,
    required this.trackBorder,
  }) : super(repaint: repaint);

  final _Scene scene;
  final Color track;
  final Color trackBorder;
  final Paint _fill = Paint();
  final Paint _border = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final col = size.width / _Colors.meters.length;
    final w = math.min(col * 0.62, size.height * 0.22);
    // `animate-pulse`: opacity 1 -> 0.5 -> 1 over 2 s.
    final pulse =
        0.75 + 0.25 * math.cos(2 * math.pi * scene.time / _pulseSeconds);
    for (var i = 0; i < _Colors.meters.length; i++) {
      final cx = col * (i + 0.5);
      final rect = Rect.fromLTWH(cx - w / 2, 0, w, size.height);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(w / 2));
      canvas.drawRRect(rr, _fill..color = track);
      final v = scene.meter(i).clamp(0.0, 100.0) / 100;
      if (v > 0) {
        var color = _Colors.meters[i];
        if (i == _Colors.meters.length - 1) {
          color = scene.meterTo[i] < _roughLow
              ? _Colors.red500.withValues(alpha: pulse)
              : _Colors.green500;
        }
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(
          Rect.fromLTRB(
            rect.left,
            rect.bottom - rect.height * v,
            rect.right,
            rect.bottom,
          ),
          _fill..color = color,
        );
        canvas.restore();
      }
      canvas.drawRRect(rr, _border..color = trackBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _MetersPainter old) =>
      old.scene != scene ||
      old.track != track ||
      old.trackBorder != trackBorder;
}

/// The healing bar (`bg-gradient-to-r from-cyan-400 to-blue-500`).
class _HealBarPainter extends CustomPainter {
  _HealBarPainter({
    required this.scene,
    required Listenable repaint,
    required this.track,
    required this.trackBorder,
  }) : super(repaint: repaint);

  final _Scene scene;
  final Color track;
  final Color trackBorder;
  final Paint _fill = Paint();
  final Paint _border = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _bar = Paint();
  Size? _barSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (_barSize != size) {
      _barSize = size;
      _bar.shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        const [_Colors.cyan400, _Colors.blue500],
      );
    }
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(rr, _fill..color = track);
    final v = scene.healProgress.clamp(0.0, 100.0) / 100;
    if (v > 0) {
      canvas.save();
      canvas.clipRRect(rr);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width * v, size.height), _bar);
      canvas.restore();
    }
    canvas.drawRRect(rr, _border..color = trackBorder);
  }

  @override
  bool shouldRepaint(covariant _HealBarPainter old) =>
      old.scene != scene ||
      old.track != track ||
      old.trackBorder != trackBorder;
}

/// The healing percentage (`#progress-percent`), right-aligned.
class _PercentPainter extends CustomPainter {
  _PercentPainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.color,
    required this.fontSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final Color color;
  final double fontSize;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = cache.styled(
      '${scene.healProgress.round()}%',
      TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    );
    tp.paint(
      canvas,
      Offset(size.width - tp.width, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PercentPainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.color != color ||
      old.fontSize != fontSize;
}

/// A gut in the summary: the tube, its channel, and food balls flowing
/// down (with roughage) or a lump stuck in it (constipation).
class _GutPainter extends CustomPainter {
  _GutPainter({required this.healthy, required Animation<double> flow})
    : _flow = flow,
      super(repaint: flow);

  final bool healthy;
  final Animation<double> _flow;
  final Paint _fill = Paint();
  final Paint _line = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final k = w / 96; // HTML w-24 (96 px) x h-40 (160 px), border-4.
    final tube = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: Radius.circular(w / 2),
      topRight: Radius.circular(w / 2),
      bottomLeft: Radius.circular(w * 0.25),
      bottomRight: Radius.circular(w * 0.25),
    );
    canvas.drawRRect(tube, _fill..color = _Colors.slate800);
    canvas.drawRRect(
      tube.deflate(2 * k),
      _line
        ..strokeWidth = 4 * k
        ..color = _Colors.gutWall,
    );
    _line
      ..strokeWidth = 2 * k
      ..color = _Colors.gutLine;
    for (final sx in const [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(w / 2 + sx * 8 * k, 6 * k),
        Offset(w / 2 + sx * 8 * k, h - 6 * k),
        _line,
      );
    }
    if (healthy) {
      final r = 12 * k;
      for (var i = 0; i < 3; i++) {
        final t = (_flow.value + i / 3) % 1;
        final y = r + 4 * k + t * (h - 2 * r - 8 * k);
        canvas.drawCircle(Offset(w / 2, y), r, _fill..color = _Colors.green400);
      }
      return;
    }
    // A lump stuck a third of the way down, with a warning sign.
    final c = Offset(w / 2, h / 3 + 16 * k);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(12 * math.pi / 180);
    final lump = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 32 * k, height: 32 * k),
      Radius.circular(5 * k),
    );
    canvas.drawRRect(lump, _fill..color = _Colors.orange800);
    canvas.drawRRect(
      lump,
      _line
        ..strokeWidth = 2 * k
        ..color = labShade(_Colors.orange800, -0.5),
    );
    _fill.color = _Colors.white;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -3 * k), width: 4 * k, height: 12 * k),
      _fill,
    );
    canvas.drawCircle(Offset(0, 7 * k), 2.2 * k, _fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GutPainter old) =>
      old.healthy != healthy || old._flow != _flow;
}

/// The bone bar and the calcium dots of the Scenario 2 summary: bouncing
/// off above the bone (no Vitamin D) or resting in it (Vitamin D).
class _CalciumPainter extends CustomPainter {
  _CalciumPainter({required this.vitD, required Animation<double> bounce})
    : _bounce = bounce,
      super(repaint: bounce);

  final bool vitD;
  final Animation<double> _bounce;
  final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bone = Rect.fromCenter(
      center: Offset(w / 2, h * 0.78),
      width: math.min(w * 0.7, h * 1.3),
      height: h * 0.24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bone, Radius.circular(bone.height / 2)),
      _fill..color = _Colors.slate300,
    );
    final r = math.max(3.0, h * 0.075);
    _fill.color = _Colors.blue400.withValues(alpha: vitD ? 0.8 : 1);
    if (vitD) {
      for (final fx in const [1 / 3, 2 / 3]) {
        canvas.drawCircle(
          Offset(bone.left + bone.width * fx, bone.center.dy),
          r,
          _fill,
        );
      }
      return;
    }
    for (final (fx, phase) in const [(0.25, 0.0), (0.75, 0.4)]) {
      final t = (_bounce.value + phase) % 1;
      final lift = math.sin(t * math.pi).abs();
      canvas.drawCircle(
        Offset(w * fx, bone.top - r - 2 - lift * h * 0.35),
        r,
        _fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalciumPainter old) =>
      old.vitD != vitD || old._bounce != _bounce;
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
