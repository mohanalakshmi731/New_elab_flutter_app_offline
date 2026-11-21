// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 5 • Activity 6
/// Motion, Rest, and Classification of Motion.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A6-Motion__Rest__and_Classification_of_Motion.html` (Three.js
/// r128). The Three.js scene is redrawn by a small painter's-algorithm
/// renderer ([_R3]) that reproduces the HTML cameras (position, look-at,
/// 45° field of view).
///
/// Scenario 1 (The Moving Bus): start the bus, ride inside it, then test
/// Deepa against two reference points from the Reference Toolbox: the
/// roadside tree (a laser shows the distance keeps changing, so she is in
/// motion) and her bus seat (a ring shows the distance stays 0 m, so she is
/// at rest).
///
/// Scenario 2 (Fun in the Park): watch the slide (linear), the swing
/// (oscillatory) and the merry-go-round (circular), then put each motion
/// label from the toolbox on its equipment.
class Ch5A6MotionRestAndClassificationOfMotionPage extends StatefulWidget {
  const Ch5A6MotionRestAndClassificationOfMotionPage({super.key});

  @override
  State<Ch5A6MotionRestAndClassificationOfMotionPage> createState() =>
      _MotionLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, measure → `science/pickup.mp3`.
///
/// The HTML synthesises three Web-Audio tones in `playSound(type)`; each is
/// mapped onto the closest file: `pop` (short 400 → 800 Hz blip) → pop,
/// `measure` (rising 300 → 600 Hz sweep) → pickup, `success` (C-E-G
/// arpeggio) → success.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Right action (shell feedback).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action: locked seat, wrong label, drop beside the equipment.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `playSound('success')`: reference tested, label matched, summary.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `playSound('pop')`: ride the bus, toolbox drag, result card.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('measure')`: bus starts, playground equipment moves.
  measure('audio/class6/science/pickup.mp3');

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
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  /// `#observation-card`: `bg-slate-900/95`, `border-blue-500`.
  static const Color resultCardBg = Color(0xF20F172A);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617 (dark) / 0xf1f5f9 (light theme).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate100;

  // Scenario 1: road, tree, bus.
  static const Color ground = Color(0xFF334155);
  static const Color road = Color(0xFF0F172A);
  static const Color roadLine = white;
  static const Color roadDash = Color(0xFFFACC15);
  static const Color grass = Color(0xFF14532D);
  static const Color trunk = Color(0xFF78350F);
  static const Color leaves1 = Color(0xFF15803D);
  static const Color leaves2 = Color(0xFF16A34A);
  static const Color leaves3 = Color(0xFF22C55E);
  static const Color apple = Color(0xFFEF4444);
  static const Color busYellow = Color(0xFFFACC15);
  static const Color busRoof = white;
  static const Color steering = Color(0xFF0F172A);
  static const Color glass = Color(0xFF38BDF8);
  static const Color headlight = Color(0xFFFEF08A);
  static const Color tyre = Color(0xFF0F172A);
  static const Color rim = Color(0xFF94A3B8);
  static const Color seatBack = Color(0xFF1E3A8A);
  static const Color seatBottom = Color(0xFF1E40AF);
  static const Color laser = Color(0xFF38BDF8);
  static const Color ring = Color(0xFF10B981);

  // People (`createDetailedPerson`).
  static const Color skin = Color(0xFFFFD1B3);
  static const Color shoe = Color(0xFF0F172A);
  static const Color eye = Color(0xFF000000);
  static const Color smile = Color(0xFFE11D48);
  static const Color darkHair = Color(0xFF1E293B);
  static const Color brownHair = Color(0xFF451A03);
  static const Color deepaShirt = Color(0xFF6366F1);
  static const Color deepaJeans = Color(0xFF1E3A8A);
  static const Color rahulShirt = Color(0xFFEF4444);
  static const Color slateJeans = Color(0xFF334155);
  static const Color sliderShirt = Color(0xFFF59E0B);
  static const Color sliderShorts = Color(0xFF0284C7);
  static const Color swingShirt = Color(0xFFEC4899);
  static const Color swingPants = Color(0xFF475569);
  static const Color rider1Shirt = Color(0xFF06B6D4);
  static const Color rider2Shirt = Color(0xFF10B981);

  // Scenario 2: playground.
  static const Color lawn = Color(0xFF14532D);
  static const Color ladder = Color(0xFF64748B);
  static const Color slideBoard = Color(0xFF10B981);
  static const Color swingPole = Color(0xFFE2E8F0);
  static const Color swingBar = Color(0xFFF43F5E);
  static const Color rope = white;
  static const Color plank = Color(0xFFD97706);
  static const Color carouselPole = Color(0xFF475569);
  static const Color carouselDisc = Color(0xFF06B6D4);
  static const Color carouselHandle = Color(0xFFFACC15);
  static const Color slidePath = Color(0xFFFACC15);
  static const Color swingPath = Color(0xFFF43F5E);
  static const Color carouselPath = Color(0xFF06B6D4);

  /// `createTextSprite`: rgba(15, 23, 42, 0.9) badge, #eab308 border.
  static const Color spriteBg = Color(0xE60F172A);
  static const Color spriteBorder = Color(0xFFEAB308);
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
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
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
    popupHeader: _Colors.blue600,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xCC0F172A), // bg-slate-900/80
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
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
    popupHeader: _Colors.blue600,
    dialogBg: _Colors.white,
    toastBg: Color(0xCC0F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.spriteBg,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Step
// numbers ("Step 1: ") are dropped from the HUD lines because the shell
// shows "Step n of N". Changes from the HTML (see the report): "Click" is
// "Tap"; steps 1-4 / 1-5 / 2-5 say that the result card's button must be
// tapped; the S1 tree text says the distance keeps CHANGING (the bus loops,
// so it does not only increase); "and street lamps" (absent from the scene)
// is dropped; Hindi oscillatory motion is दोलन गति (the HTML's आवर्ती means
// periodic); emoji arrows / trophies in button labels are icons instead.
// Keys marked "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Motion, Rest, and Classification of Motion',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1_opt': 'Scenario 1: The Moving Bus: Is Anyone Really Sitting Still?',
    'scen_2_opt': 'Scenario 2: Fun in the Park: A Motion Playground',
    's1_desc':
        'To understand that motion and rest are relative and depend entirely on the chosen reference point.',
    's2_desc':
        'To identify and classify linear, circular, and oscillatory motion by interacting with playground equipment.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c':
        'An object is in motion if its position changes relative to a fixed surrounding point.',
    'step_1_1_a': "Tap the 'Play Bus Motion' button.",
    'step_1_1_o':
        'The school bus rolls along the highway past the stationary roadside tree.',
    'step_1_2_c':
        'Changing our observation perspective changes how we perceive movement.',
    'step_1_2_a': "Tap the 'Ride the Bus' button.",
    'step_1_2_o':
        'Camera shifts inside the bus aisle looking clearly at passenger Deepa sitting by the window.',
    'step_1_3_c':
        'Relative to external objects on the ground, passengers inside a vehicle are moving.',
    'step_1_3_a':
        "Drag the 'Tree' icon from the Reference Toolbox onto the scene, or tap it.",
    'step_1_3_o':
        'VISUAL CHANGE: A thick glowing laser cylinder connects Deepa to the tree! As the bus moves, the distance between Deepa and the Tree keeps CHANGING. Therefore, relative to the tree, Deepa is IN MOTION!',
    'step_1_4_c':
        'Relative to objects moving along with them, passengers inside a vehicle are at rest.',
    'step_1_4_a':
        "Tap 'Test Next Reference Point (Bus Seat)' on the result card, then drag the 'Bus Seat' icon from the Reference Toolbox onto the scene, or tap it.",
    'step_1_4_o':
        'VISUAL CHANGE: A glowing green ring wraps around Deepa and her seat! Even while the bus drives fast, the distance between Deepa and her seat remains exactly 0 meters. Therefore, relative to her seat, Deepa is AT REST!',
    'step_1_5_c':
        'Motion is purely relative. There is no absolute rest or motion.',
    'step_1_5_a':
        "Review the findings on the result card, then tap 'Conclude Investigation & View Summary'.",
    'step_1_5_o':
        'You discovered that Deepa is both moving (vs Tree) and stationary (vs Seat) simultaneously!',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c':
        'Linear (Rectilinear) motion occurs when an object moves along a straight line path.',
    'step_2_1_a':
        "Tap the Slide in the playground or the 'Slide (Linear)' button.",
    'step_2_1_o':
        'Child slides straight down the inclined board. The straight line trajectory glows bright yellow.',
    'step_2_2_c':
        'Oscillatory motion is a repeating to-and-fro movement along the same path.',
    'step_2_2_a':
        "Tap the Swing in the playground or the 'Swing (Oscillatory)' button.",
    'step_2_2_o':
        'Swing moves harmonically back and forth. The curved pendulum arc glows pink.',
    'step_2_3_c':
        'Circular motion occurs when an object revolves around a fixed central rotation axis.',
    'step_2_3_a':
        "Tap the Merry-go-round in the playground or the 'Merry-go-round (Circular)' button.",
    'step_2_3_o':
        'Platform spins smoothly around the center pole. The circular orbit trajectory glows cyan.',
    'step_2_4_c':
        'Real-world physical actions can be categorized by analyzing their geometric trajectory.',
    'step_2_4_a':
        'Drag each motion label from the Reference Toolbox onto its matching playground equipment (or tap a label, then tap the equipment).',
    'step_2_4_o':
        'Each label snaps onto its corresponding playground structure with confirmation glow.',
    'step_2_5_c': 'Mastery of primary kinematic motions achieved.',
    'step_2_5_a':
        "Review the classified equipment on the result card, then tap 'View Final Trophy'.",
    'step_2_5_o':
        'Linear = Slide, Oscillatory = Swing, Circular = Merry-go-round!',
    // ---------------------------------------------------- HUD (Current Task)
    's1_hud_1':
        "Tap 'Play Bus Motion' to watch the detailed school bus drive past a roadside tree.",
    's1_hud_2':
        "Tap 'Ride the Bus' to shift the camera inside the bus, across the aisle, looking directly at Deepa.",
    's1_hud_3':
        "Drag or tap the 'Tree' icon from the Reference Toolbox to test the Tree reference.",
    's1_hud_4':
        "Tap 'Test Next Reference Point' on the result card, then drag or tap the 'Bus Seat' icon to test the seat reference.",
    's1_hud_5':
        "Investigation Complete! Read the result card and tap 'Conclude Investigation & View Summary'.",
    's2_hud_1':
        'Tap the Slide (or its button) to observe Linear motion straight down.',
    's2_hud_2':
        'Tap the Swing set to observe Oscillatory (to-and-fro pendulum) motion.',
    's2_hud_3':
        'Tap the Merry-go-round to observe Circular spinning motion around an axis.',
    's2_hud_4':
        'Drag motion labels from the Reference Toolbox onto the matching playground equipment.',
    's2_hud_5':
        "Classification Complete! Read the result card and tap 'View Final Trophy'.",
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration Step',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    // Added.
    'obs_pending': 'Complete this step to see what happens.',
    // ------------------------------------------------------------ buttons
    'btn_play_bus': 'Play Bus Motion',
    'btn_ride_bus': 'Ride the Bus (Interior View)',
    'slide_linear': 'Slide (Linear)',
    'swing_osc': 'Swing (Oscillatory)',
    'carousel_circ': 'Merry-go-round (Circular)',
    // ------------------------------------------------------------ toolbox
    'toolbox_title': 'Reference Toolbox',
    'toolbox_s1_desc': 'Drag icon or tap to test relativity:',
    'toolbox_s2_desc':
        'Drag a label onto its equipment, or tap a label and then the equipment:',
    'icon_tree': 'Tree (Ground Ref)',
    'icon_seat': 'Bus Seat (Moving Ref)',
    'lbl_linear': 'Linear Motion',
    'lbl_osc': 'Oscillatory Motion',
    'lbl_circ': 'Circular Motion',
    // ------------------------------------------------------------- toasts
    'toast_bus_moving':
        'Bus is moving! Notice position changing relative to stationary tree.',
    'toast_inside_view':
        'Inside Interior View! Reference Toolbox opened on top-right.',
    'toast_slide_linear': 'Slide demonstrates LINEAR (straight line) motion!',
    'toast_swing_osc': 'Swing demonstrates OSCILLATORY (to-and-fro) motion!',
    'toast_carousel_circ':
        'Merry-go-round demonstrates CIRCULAR spinning motion!',
    'toast_drag_seat_next':
        "Now drag or tap the 'Bus Seat' icon to check motion relative to the bus interior!",
    'toast_linear_matched': 'Linear Motion matched to Slide!',
    'toast_osc_matched': 'Oscillatory Motion matched to Swing!',
    'toast_circ_matched': 'Circular Motion matched to Merry-go-round!',
    // Added.
    'toast_seat_locked':
        "First drag or tap the 'Tree' icon to test the ground reference.",
    'toast_wrong_slide':
        'Not a match! On the Slide, the child moves along a straight line.',
    'toast_wrong_swing':
        'Not a match! The Swing moves to and fro along the same path.',
    'toast_wrong_carousel':
        'Not a match! The Merry-go-round spins in a circle around its centre.',
    'toast_drop_on_equipment':
        'Drop the label onto one of the playground equipment.',
    'toast_label_selected':
        'Now tap the playground equipment that shows {label}.',
    // ------------------------------------------------------- result cards
    'obs_tree_title': 'Reference Point: Ground Tree',
    'obs_tree_desc':
        'VISUAL CHANGE: A thick blue laser beam now connects Deepa to the roadside Tree! As the bus rolls forward, watch how the distance between Deepa and the tree keeps CHANGING. Because her position changes relative to the tree, Deepa is IN MOTION!',
    'obs_tree_btn': 'Test Next Reference Point (Bus Seat)',
    'obs_seat_title': 'Reference Point: Bus Seat',
    'obs_seat_desc':
        'VISUAL CHANGE: A glowing green ring wraps around Deepa and her seat! Notice that even while the bus drives fast, Deepa remains glued to her seat. The distance between them stays exactly 0 meters. Because her position does NOT change relative to her seat, Deepa is AT REST!',
    'obs_seat_btn': 'Conclude Investigation & View Summary',
    'obs_s2_title': 'All Equipment Classified!',
    'obs_s2_desc':
        'You successfully matched all motion labels! Slide demonstrates Linear Motion (straight line), Swing demonstrates Oscillatory Motion (to-and-fro), and Merry-go-round demonstrates Circular Motion.',
    'obs_s2_btn': 'View Final Trophy',
    // --------------------------------------------------- canvas (sprites)
    'sprite_tree': 'Roadside Tree',
    'sprite_bus': 'School Bus',
    'sprite_deepa': 'Deepa',
    'sprite_slide': 'Slide (Linear)',
    'sprite_swing': 'Swing (Oscillatory)',
    'sprite_carousel': 'Merry-go-round (Circular)',
    // Added: distance readouts beside the laser and the ring.
    'dist_tree': 'Deepa to Tree: {d} m',
    'dist_seat': 'Deepa to Seat: 0 m',
    // --------------------------------------------------------- conclusion
    'sc_complete': 'Scenario {n} Complete!',
    's1_summary':
        'You clearly demonstrated that Motion and Rest are relative! Relative to the roadside Tree, the bus passenger is in MOTION. But relative to the Bus Seat, the exact same passenger is at REST!',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You have successfully classified Motion and Rest! You explored relative motion from different reference points and mastered Linear, Circular, and Oscillatory motion.',
    // Added (screen readers).
    'scene_bus':
        'A road with a school bus driving past a roadside tree; passenger Deepa sits inside the bus.',
    'scene_park': 'A playground with a slide, a swing and a merry-go-round.',
  },
  'hi': {
    'app_title': 'विराम, गति और गति का वर्गीकरण',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: चलती बस - क्या कोई सच में स्थिर है?',
    'scen_2_opt': 'परिदृश्य 2: पार्क में खेल - गति का मैदान',
    's1_desc':
        'यह समझना कि गति और विराम सापेक्ष हैं और पूरी तरह से चुने गए संदर्भ बिंदु पर निर्भर करते हैं।',
    's2_desc':
        'झूलों के साथ बातचीत करके सरल रेखीय, वर्तुल और दोलन गति को पहचानना और वर्गीकृत करना।',
    'step_1_1_c':
        'यदि किसी स्थिर बिंदु के सापेक्ष स्थिति बदले, तो वस्तु गति में होती है।',
    'step_1_1_a': "'बस चलाएं' बटन दबाएं।",
    'step_1_1_o':
        'पीली स्कूल बस सड़क पर बाहर खड़े स्थिर हरे पेड़ के पास से आगे बढ़ती है।',
    'step_1_2_c': 'देखने का नजरिया बदलने से गति का अनुभव बदल जाता है।',
    'step_1_2_a': "'बस के अंदर बैठें' बटन दबाएं।",
    'step_1_2_o':
        'कैमरा बस के अंदर गलियारे में आकर दीपा को स्पष्ट रूप से दिखाता है।',
    'step_1_3_c':
        'बाहरी वस्तुओं के सापेक्ष वाहन के अंदर बैठे यात्री गति में होते हैं।',
    'step_1_3_a': "टूलबॉक्स से 'पेड़' आइकन को दृश्य पर खींचें, या उसे दबाएं।",
    'step_1_3_o':
        'दृश्य परिवर्तन: दीपा और पेड़ के बीच एक चमकती लेजर किरण जुड़ जाती है! जैसे-जैसे बस चलती है, दीपा और पेड़ के बीच की दूरी लगातार बदलती रहती है। इसलिए पेड़ के सापेक्ष दीपा गति में है!',
    'step_1_4_c':
        'साथ चल रही वस्तुओं के सापेक्ष वाहन के अंदर बैठे यात्री विराम में होते हैं।',
    'step_1_4_a':
        "परिणाम कार्ड पर 'अगला संदर्भ बिंदु जांचें (बस सीट)' दबाएं, फिर टूलबॉक्स से 'बस सीट' आइकन को दृश्य पर खींचें, या उसे दबाएं।",
    'step_1_4_o':
        'दृश्य परिवर्तन: दीपा और सीट के चारों ओर एक हरा सुरक्षा चक्र बन जाता है! बस के तेज चलने पर भी दीपा और सीट के बीच की दूरी 0 मीटर ही रहती है। इसलिए सीट के सापेक्ष दीपा विराम (स्थिर) में है!',
    'step_1_5_c':
        'गति पूरी तरह सापेक्ष है। ब्रह्मांड में कोई निरपेक्ष विराम नहीं है।',
    'step_1_5_a':
        "परिणाम कार्ड पर जांच के परिणामों की समीक्षा करें, फिर 'जांच समाप्त करें और निष्कर्ष देखें' दबाएं।",
    'step_1_5_o':
        'आपने पाया कि दीपा एक ही समय में गति में (पेड़ के सापेक्ष) और स्थिर (सीट के सापेक्ष) है!',
    'step_2_1_c': 'सीधी रेखा में होने वाली गति को सरल रेखीय गति कहते हैं।',
    'step_2_1_a':
        "खेल के मैदान में फिसलन पट्टी या 'फिसलन पट्टी (सरल रेखीय)' बटन दबाएं।",
    'step_2_1_o':
        'बच्चा सीधे नीचे फिसलता है। सीधी रेखा का मार्ग पीले रंग में चमकता है।',
    'step_2_2_c':
        'एक निश्चित पथ पर बार-बार आगे-पीछे होने वाली गति दोलन गति है।',
    'step_2_2_a': "खेल के मैदान में झूला या 'झूला (दोलन)' बटन दबाएं।",
    'step_2_2_o':
        'झूला आगे-पीछे झूलता है। वक्राकार मार्ग गुलाबी रंग में चमकता है।',
    'step_2_3_c':
        'किसी निश्चित अक्ष के चारों ओर गोल घूमने वाली गति वर्तुल गति है।',
    'step_2_3_a':
        "खेल के मैदान में चक्र झूला या 'चक्र झूला (वर्तुल)' बटन दबाएं।",
    'step_2_3_o': 'झूला गोल घूमता है। वृत्ताकार मार्ग नीले रंग में चमकता है।',
    'step_2_4_c': 'रास्ते के आकार के आधार पर गति का वर्गीकरण किया जा सकता है।',
    'step_2_4_a':
        'टूलबॉक्स से हर गति लेबल को खेल के मैदान के सही उपकरण पर खींचें (या लेबल दबाएं, फिर उपकरण दबाएं)।',
    'step_2_4_o': 'प्रत्येक लेबल अपने सही झूले पर जुड़कर चमकने लगता है।',
    'step_2_5_c': 'गति के प्रमुख प्रकारों में महारत हासिल हुई।',
    'step_2_5_a':
        "परिणाम कार्ड पर वर्गीकृत उपकरणों की समीक्षा करें, फिर 'अंतिम ट्रॉफी देखें' दबाएं।",
    'step_2_5_o': 'सरल रेखीय = फिसलन पट्टी, दोलन = झूला, वर्तुल = चक्र झूला!',
    's1_hud_1': "बस को पेड़ के पास से गुजरते देखने के लिए 'बस चलाएं' दबाएं।",
    's1_hud_2':
        "बस के अंदर दीपा के बगल में बैठने के लिए 'बस के अंदर बैठें' दबाएं।",
    's1_hud_3':
        "पेड़ के सापेक्ष गति जांचने के लिए टूलबॉक्स से 'पेड़' का आइकन खींचें या दबाएं।",
    's1_hud_4':
        "परिणाम कार्ड पर 'अगला संदर्भ बिंदु जांचें' दबाएं, फिर सीट के सापेक्ष गति जांचने के लिए 'बस सीट' का आइकन खींचें या दबाएं।",
    's1_hud_5':
        "अन्वेषण पूर्ण! परिणाम कार्ड पढ़ें और 'जांच समाप्त करें और निष्कर्ष देखें' दबाएं।",
    's2_hud_1':
        'सीधी रेखा में गति देखने के लिए फिसलन पट्टी (या उसका बटन) दबाएं।',
    's2_hud_2': 'आगे-पीछे होने वाली दोलन गति देखने के लिए झूला दबाएं।',
    's2_hud_3': 'गोल घूमने वाली वर्तुल गति देखने के लिए चक्र झूला दबाएं।',
    's2_hud_4':
        'टूलबॉक्स से गति के लेबल खेल के मैदान के सही उपकरणों पर खींचें।',
    's2_hud_5':
        "वर्गीकरण पूर्ण! परिणाम कार्ड पढ़ें और 'अंतिम ट्रॉफी देखें' दबाएं।",
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण चरण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'obs_pending': 'क्या होता है, यह देखने के लिए यह चरण पूरा करें।',
    'btn_play_bus': 'बस चलाएं',
    'btn_ride_bus': 'बस के अंदर बैठें',
    'slide_linear': 'फिसलन पट्टी (सरल रेखीय)',
    'swing_osc': 'झूला (दोलन)',
    'carousel_circ': 'चक्र झूला (वर्तुल)',
    'toolbox_title': 'संदर्भ टूलबॉक्स',
    'toolbox_s1_desc': 'जांचने के लिए खींचें या दबाएं:',
    'toolbox_s2_desc':
        'लेबल को उसके उपकरण पर खींचें, या लेबल दबाएं और फिर उपकरण दबाएं:',
    'icon_tree': 'पेड़ (स्थिर संदर्भ)',
    'icon_seat': 'बस सीट (गतिशील संदर्भ)',
    'lbl_linear': 'सरल रेखीय गति',
    'lbl_osc': 'दोलन गति',
    'lbl_circ': 'वर्तुल गति',
    'toast_bus_moving':
        'बस चल रही है! स्थिर पेड़ के सापेक्ष बदलती स्थिति को देखें।',
    'toast_inside_view':
        'बस के अंदर का दृश्य! दाईं ओर ऊपर संदर्भ टूलबॉक्स खुल गया है।',
    'toast_slide_linear': 'फिसलन पट्टी सरल रेखीय (सीधी रेखा) गति दर्शाती है!',
    'toast_swing_osc': 'झूला दोलन (आगे-पीछे) गति दर्शाता है!',
    'toast_carousel_circ': 'चक्र झूला वर्तुल (गोल घूमने वाली) गति दर्शाता है!',
    'toast_drag_seat_next':
        "अब बस के अंदर के सापेक्ष गति जांचने के लिए 'बस सीट' आइकन खींचें या दबाएं!",
    'toast_linear_matched': 'सरल रेखीय गति का फिसलन पट्टी से मिलान हुआ!',
    'toast_osc_matched': 'दोलन गति का झूले से मिलान हुआ!',
    'toast_circ_matched': 'वर्तुल गति का चक्र झूले से मिलान हुआ!',
    'toast_seat_locked':
        "पहले जमीन के संदर्भ की जांच के लिए 'पेड़' आइकन खींचें या दबाएं।",
    'toast_wrong_slide':
        'सही मिलान नहीं! फिसलन पट्टी पर बच्चा सीधी रेखा में चलता है।',
    'toast_wrong_swing': 'सही मिलान नहीं! झूला एक ही पथ पर आगे-पीछे चलता है।',
    'toast_wrong_carousel':
        'सही मिलान नहीं! चक्र झूला अपने केंद्र के चारों ओर गोल घूमता है।',
    'toast_drop_on_equipment': 'लेबल को खेल के मैदान के किसी उपकरण पर छोड़ें।',
    'toast_label_selected':
        'अब खेल के मैदान में वह उपकरण दबाएं जो {label} दर्शाता है।',
    'obs_tree_title': 'संदर्भ बिंदु: जमीन का पेड़',
    'obs_tree_desc':
        'दृश्य परिवर्तन: दीपा और पेड़ के बीच एक नीली लेजर किरण जुड़ गई है! जैसे-जैसे बस आगे बढ़ती है, दीपा और पेड़ के बीच की दूरी लगातार बदलती रहती है। इसलिए पेड़ के सापेक्ष दीपा गति में है!',
    'obs_tree_btn': 'अगला संदर्भ बिंदु जांचें (बस सीट)',
    'obs_seat_title': 'संदर्भ बिंदु: बस की सीट',
    'obs_seat_desc':
        'दृश्य परिवर्तन: दीपा और सीट के चारों ओर एक हरा सुरक्षा चक्र बन गया है! ध्यान दें कि बस के तेज चलने पर भी दीपा अपनी सीट से जुड़ी है। उनके बीच की दूरी 0 मीटर ही रहती है। इसलिए सीट के सापेक्ष दीपा विराम (स्थिर) में है!',
    'obs_seat_btn': 'जांच समाप्त करें और निष्कर्ष देखें',
    'obs_s2_title': 'सभी उपकरण वर्गीकृत!',
    'obs_s2_desc':
        'आपने सभी गति लेबलों का सफलतापूर्वक मिलान किया! फिसलन पट्टी सरल रेखीय गति, झूला दोलन गति, और चक्र झूला वर्तुल गति दर्शाता है।',
    'obs_s2_btn': 'अंतिम ट्रॉफी देखें',
    'sprite_tree': 'सड़क किनारे पेड़',
    'sprite_bus': 'स्कूल बस',
    'sprite_deepa': 'दीपा',
    'sprite_slide': 'फिसलन पट्टी',
    'sprite_swing': 'झूला',
    'sprite_carousel': 'चक्र झूला',
    'dist_tree': 'दीपा से पेड़: {d} मी',
    'dist_seat': 'दीपा से सीट: 0 मी',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_summary':
        'आपने स्पष्ट रूप से सिद्ध किया कि गति और विराम सापेक्ष हैं! सड़क किनारे खड़े पेड़ के सापेक्ष यात्री गति में है, लेकिन बस की सीट के सापेक्ष वही यात्री विराम में है!',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने गति और विराम को सफलतापूर्वक समझ लिया है! आपने जाना कि गति देखने वाले के नजरिए पर निर्भर करती है और गति के तीनों प्रकारों को वर्गीकृत किया।',
    'scene_bus':
        'सड़क पर एक स्कूल बस सड़क किनारे पेड़ के पास से गुजर रही है; यात्री दीपा बस के अंदर बैठी है।',
    'scene_park': 'फिसलन पट्टी, झूले और चक्र झूले वाला खेल का मैदान।',
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

/// The part of the design box the scene's touch targets are kept in (the
/// stage only hit-tests inside its design box).
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// HTML `new THREE.PerspectiveCamera(45, aspect, 0.1, 1000)`.
const double _fovDegrees = 45;
const double _near = 0.1;

/// Design pixels per world unit at depth 1: half the stage height over
/// tan(fov / 2), as in Three.js.
final double _focal =
    _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

/// HTML lights: `AmbientLight(0xffffff, 0.75)` and `DirectionalLight(
/// 0xfff8e7, 0.95)` at (15, 30, 20). Three.js r128 adds them linearly and
/// clips at white, which washes the lit faces out on a phone; both are
/// scaled by [_lightScale].
const double _lightScale = 0.75;
const double _ambient = 0.75 * _lightScale;
const double _diffuse = 0.95 * _lightScale;

/// (15, 30, 20) normalised.
const _V _light = _V(0.3841, 0.7682, 0.5121);
const _V _up = _V(0, 1, 0);

/// Equipment drop / tap zones reach this far (design px) past the
/// equipment's outline and labels.
const double _zonePad = 6;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML sprite text stays readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Room (design px) a label chip takes around its anchor, for zones and
/// framing; a placed motion label sits [_placedDy] below the name label.
const double _labelHalfW = 60;
const double _labelHalfH = 14;
const double _placedDy = 30;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make the bus jump.
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// The scene is never drawn larger than the HTML camera shows it.
const double _maxZoom = 1;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// The result card is avoided when the scene can still be drawn at least
/// this share of the size it would have on top of the card.
const double _softShare = 0.6;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; x UI scale) and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

// ------------------------------------------------------- scenario 1: bus

/// Scenario 1 outside camera and Scenario 2 camera:
/// `camera.position.set(0, 12, 28)`, `controls.target.set(0, 2, 0)`.
const _V _outsideEye = _V(0, 12, 28);
const _V _outsideTarget = _V(0, 2, 0);

/// Inside camera, relative to the bus: `camera.position.set(busPos - 0.5,
/// 3.8, -1.2)`, `controls.target.set(busPos + 2.0, 3.2, 1.2)`.
const _V _insideEye = _V(-0.5, 3.8, -1.2);
const _V _insideTarget = _V(2.0, 3.2, 1.2);

/// `let busPos = -18`; `busPos += 0.2` per frame (60 fps); wraps at ±35.
const double _busStartX = -18;
const double _busSpeed = 12;
const double _busWrapX = 35;

/// `passengerDeepa.position.set(1.2, 0, 1.1)` in the bus; the figure stands
/// 0.85 higher (`deepaFigure.position.y`).
const _V _deepaSeat = _V(1.2, 0, 1.1);
const double _figureLift = 0.85;

/// Deepa's head (`head.position.y = 1.95`) and hair top, bus-relative.
const _V _deepaHead = _V(1.2, _figureLift + 1.95, 1.1);
const double _headRadius = 0.38;

/// Laser: from Deepa's world position + 2.6 up (`pWorld.y += 2.6`) to the
/// tree at (0, 6, -9); `CylinderGeometry(0.15, 0.15, 1)`.
const double _laserLift = 2.6;
const _V _laserTreePoint = _V(0, 6, -9);
const double _laserRadius = 0.15;

/// The laser is drawn at most this wide (design px) where it passes the
/// camera.
const double _laserMaxWidth = 26;

/// `TorusGeometry(1.5, 0.12)` around Deepa's seat at (0, 2, 0) in her group.
const double _ringRadius = 1.5;
const double _ringTube = 0.12;
const double _ringHeight = 2;

/// Where the ring passes close to the camera its tube is drawn at most this
/// wide (design px), so it does not hide Deepa.
const double _ringMaxWidth = 9;

/// Sprite anchors: tree label at (0, 11.5, 0) on the tree at (0, 0, -9),
/// bus label at (0, 5.8, 0), Deepa's label at (0, 3.4, 0) on her figure.
const _V _treeLabel = _V(0, 11.5, -9);
const _V _busLabel = _V(0, 5.8, 0);
const _V _deepaLabel = _V(1.2, _figureLift + 3.4, 1.1);

// -------------------------------------------------- scenario 2: playground

/// `swingAngle += 0.06` and `carouselAngle += 0.04` per frame (60 fps);
/// `swingSeat.rotation.x = Math.sin(swingAngle) * 0.65`.
const double _swingRate = 3.6;
const double _swingAmplitude = 0.65;
const double _carouselRate = 2.4;

/// `slideProgress += 0.025` per frame: the slide takes 40 frames.
const double _slideSeconds = 1 / (0.025 * 60);

/// `sliderChild` slides from (-3, 4.8, 0) to (4, 0.2, 0) in the slide group
/// at (-14, 0, 0).
const double _slideGroupX = -14;
const _V _slideFrom = _V(-3, 4.8, 0);
const _V _slideTo = _V(4, 0.2, 0);

/// `swingSeat.position.set(0, 7.2, 0)`; the rope is 5.5 long.
const double _swingPivotY = 7.2;
const double _ropeLength = 5.5;

/// `carouselGroup.position.set(14, 0, 0)`, platform at y = 1.
const double _carouselX = 14;
const double _platformY = 1;

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
  double distanceTo(_V o) => (this - o).length;

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// A Three.js object's position and rotation (Euler XYZ) as one rigid
/// transform: a row-major 3x3 rotation plus a translation.
@immutable
class _Xf {
  const _Xf(
    this.m00,
    this.m01,
    this.m02,
    this.m10,
    this.m11,
    this.m12,
    this.m20,
    this.m21,
    this.m22,
    this.tx,
    this.ty,
    this.tz,
  );

  /// `object.position.set(x, y, z)` and `object.rotation.set(rx, ry, rz)`
  /// (Three.js `makeRotationFromEuler`, order XYZ).
  factory _Xf.at(
    double x,
    double y,
    double z, {
    double rx = 0,
    double ry = 0,
    double rz = 0,
  }) {
    final a = math.cos(rx), b = math.sin(rx);
    final c = math.cos(ry), d = math.sin(ry);
    final e = math.cos(rz), f = math.sin(rz);
    final ae = a * e, af = a * f, be = b * e, bf = b * f;
    return _Xf(
      c * e,
      -c * f,
      d,
      af + be * d,
      ae - bf * d,
      -b * c,
      bf - ae * d,
      be + af * d,
      a * c,
      x,
      y,
      z,
    );
  }

  final double m00, m01, m02, m10, m11, m12, m20, m21, m22;
  final double tx, ty, tz;

  /// This transform applied after [o] (`parent.matrix * child.matrix`).
  _Xf operator *(_Xf o) => _Xf(
    m00 * o.m00 + m01 * o.m10 + m02 * o.m20,
    m00 * o.m01 + m01 * o.m11 + m02 * o.m21,
    m00 * o.m02 + m01 * o.m12 + m02 * o.m22,
    m10 * o.m00 + m11 * o.m10 + m12 * o.m20,
    m10 * o.m01 + m11 * o.m11 + m12 * o.m21,
    m10 * o.m02 + m11 * o.m12 + m12 * o.m22,
    m20 * o.m00 + m21 * o.m10 + m22 * o.m20,
    m20 * o.m01 + m21 * o.m11 + m22 * o.m21,
    m20 * o.m02 + m21 * o.m12 + m22 * o.m22,
    m00 * o.tx + m01 * o.ty + m02 * o.tz + tx,
    m10 * o.tx + m11 * o.ty + m12 * o.tz + ty,
    m20 * o.tx + m21 * o.ty + m22 * o.tz + tz,
  );

  _V get origin => _V(tx, ty, tz);

  _V point(double x, double y, double z) => _V(
    m00 * x + m01 * y + m02 * z + tx,
    m10 * x + m11 * y + m12 * z + ty,
    m20 * x + m21 * y + m22 * z + tz,
  );

  /// Writes the transformed point (x, y, z) into [out] at [i].
  void apply(Float64List out, int i, double x, double y, double z) {
    out[i] = m00 * x + m01 * y + m02 * z + tx;
    out[i + 1] = m10 * x + m11 * y + m12 * z + ty;
    out[i + 2] = m20 * x + m21 * y + m22 * z + tz;
  }
}

/// Where the scene is drawn: the camera's look-at point lands on [center]
/// and the projection is scaled by [zoom] (1 = the HTML camera). The lab
/// fits the scene beside the cards with it.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom);

  final Offset center;
  final double zoom;

  static const _Framing base = _Framing(_designCenter, 1);

  /// A point projected with [base] as it lands in this framing.
  Offset map(Offset p) => center + (p - _designCenter) * zoom;

  Rect mapRect(Rect r) => Rect.fromPoints(map(r.topLeft), map(r.bottomRight));

  _Framing lerpTo(_Framing o, double t) =>
      _Framing(Offset.lerp(center, o.center, t)!, zoom + (o.zoom - zoom) * t);

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, _Framing framing) {
    final f = (target - eye).unit;
    final r = f.cross(_up).unit;
    return _Cam._(eye, f, r, r.cross(f), framing.center, _focal * framing.zoom);
  }

  const _Cam._(this.eye, this.f, this.r, this.u, this.center, this.scale);

  final _V eye;

  /// Forward, right and up axes.
  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  /// Design pixels per world unit at depth 1.
  final double scale;

  double depth(_V w) => (w - eye).dot(f);

  /// The design point of [w], or null behind the near plane.
  Offset? project(_V w) {
    final d = w - eye;
    final z = d.dot(f);
    if (z < _near) return null;
    return Offset(
      center.dx + scale * d.dot(r) / z,
      center.dy - scale * d.dot(u) / z,
    );
  }

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));
}

/// The base (HTML) projection of the outside / playground camera.
final _Cam _baseOutside = _Cam(_outsideEye, _outsideTarget, _Framing.base);

/// The base inside camera with the bus at x = 0 (the view moves with it).
final _Cam _baseInside = _Cam(_insideEye, _insideTarget, _Framing.base);

/// Bounding box of [points] in [cam], plus a label chip around each of
/// [labels].
Rect _bounds(_Cam cam, List<_V> points, {List<_V> labels = const []}) {
  Rect? r;
  void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
  for (final p in points) {
    final o = cam.project(p);
    if (o != null) add(Rect.fromCircle(center: o, radius: 0.5));
  }
  for (final l in labels) {
    final o = cam.project(l);
    if (o != null) {
      add(
        Rect.fromCenter(
          center: o,
          width: 2 * _labelHalfW,
          height: 2 * _labelHalfH,
        ),
      );
    }
  }
  return r ?? Rect.zero;
}

/// What the learner must see in the outside view: the bus where it starts
/// (x = -23 … -11), the tree with its label and the road on both sides of
/// it, at bus height.
final Rect _outsideBounds = _bounds(
  _baseOutside,
  const [
    _V(0, 0, -9),
    _V(_busStartX - 5, 0, 1.9),
    _V(_busStartX - 5, 4.7, 1.9),
    _V(-14, 0, 6),
    _V(14, 0, 6),
    _V(-14, 0, -6),
    _V(14, 0, -6),
    _V(-14, 4.7, 0),
    _V(14, 4.7, 0),
  ],
  labels: const [
    _treeLabel,
    _V(_busStartX, 5.8, 0),
    _V(-14, 5.8, 0),
    _V(14, 5.8, 0),
  ],
);

/// The inside view: Deepa's head, her label and the far side of the ring
/// around her seat (so the ring shows when it appears; its near side
/// passes beside the camera).
final Rect _insideBounds = () {
  final head = _baseInside.project(_deepaHead)!;
  final rr = _headRadius * _baseInside.scaleAt(_deepaHead);
  final ring = [
    for (var i = -1; i <= 7; i++)
      _V(
        _deepaSeat.x + _ringRadius * math.cos(i * math.pi / 8),
        _ringHeight,
        _deepaSeat.z + _ringRadius * math.sin(i * math.pi / 8),
      ),
  ];
  return _bounds(
    _baseInside,
    ring,
    labels: const [_deepaLabel],
  ).expandToInclude(Rect.fromCircle(center: head, radius: rr));
}();

/// The playground's three pieces of equipment.
enum _Equip {
  slide('slide_linear', 'sprite_slide', 'toast_slide_linear', Icons.south_east),
  swing('swing_osc', 'sprite_swing', 'toast_swing_osc', Icons.swap_horiz),
  carousel(
    'carousel_circ',
    'sprite_carousel',
    'toast_carousel_circ',
    Icons.autorenew,
  );

  const _Equip(this.buttonKey, this.spriteKey, this.toastKey, this.icon);

  /// HTML control-banner button, scene sprite and toast.
  final String buttonKey;
  final String spriteKey;
  final String toastKey;
  final IconData icon;

  /// HTML button colours: emerald (slide), pink (swing), cyan (carousel).
  Color get color => switch (this) {
    _Equip.slide => _Colors.emerald600,
    _Equip.swing => _Colors.pink600,
    _Equip.carousel => _Colors.cyan600,
  };

  /// Error toast for a label dropped on this equipment by mistake (added).
  String get wrongKey => 'toast_wrong_$name';

  /// Sprite label position (`lblSlide`, `lblSwing`, `lblCar`).
  _V get label => switch (this) {
    _Equip.slide => const _V(_slideGroupX + 0.5, 6.8, 0),
    _Equip.swing => const _V(0, 8.8, 0),
    _Equip.carousel => const _V(_carouselX, 5.5, 0),
  };
}

/// Outline points of each piece of equipment (world), for its tap / drop
/// zone: the slide's ladder and board, the swing's frame and the extremes of
/// the seat and child, the merry-go-round's disc, pole and riders.
final Map<_Equip, List<_V>> _equipOutline = {
  _Equip.slide: [
    const _V(_slideGroupX - 3.75, 0, 0),
    const _V(_slideGroupX - 3.75, 6, 0),
    for (final z in const [-0.75, 0.75]) ...[
      _V(_slideGroupX + 0.5 - 3.3, 5.26, z),
      _V(_slideGroupX + 0.5 + 3.3, 0.74, z),
    ],
    const _V(_slideGroupX + 4, 0.5, 0),
  ],
  _Equip.swing: [
    const _V(-2.8, 0, 0),
    const _V(2.8, 0, 0),
    const _V(-2.8, 7.5, 0),
    const _V(2.8, 7.5, 0),
    for (final s in const [-1.0, 1.0])
      _V(
        0,
        _swingPivotY - (_ropeLength + 0.65) * math.cos(_swingAmplitude),
        s * (_ropeLength + 0.65) * math.sin(_swingAmplitude),
      ),
  ],
  _Equip.carousel: [
    for (final (x, z) in const [
      (-3.8, 0.0),
      (3.8, 0.0),
      (0.0, -3.8),
      (0.0, 3.8),
    ])
      _V(_carouselX + x, _platformY, z),
    const _V(_carouselX, 0, 0),
    const _V(_carouselX, 3.3, 0),
    const _V(_carouselX - 3, 3, 0),
    const _V(_carouselX + 3, 3, 0),
  ],
};

/// Tap / drop zone of each piece of equipment in the base projection: its
/// outline plus its name label and the place a matched label goes.
final Map<_Equip, Rect> _baseZones = {
  for (final e in _Equip.values)
    e: _bounds(_baseOutside, _equipOutline[e]!, labels: [e.label])
        .expandToInclude(
          Rect.fromCenter(
            center: _baseOutside.project(e.label)! + const Offset(0, _placedDy),
            width: 2 * _labelHalfW,
            height: 2 * _labelHalfH,
          ),
        ),
};

/// The playground view: all three zones.
final Rect _parkBounds = _baseZones.values.reduce(
  (a, b) => a.expandToInclude(b),
);

/// Points the flows (and the learner) can use in the base projection: on
/// each piece of equipment, and the empty lawn between slide and swing.
final Map<String, Offset> _baseAnchors = {
  'slide': _baseOutside.project(const _V(_slideGroupX - 0.5, 3.4, 0))!,
  'swing': _baseOutside.project(const _V(0, 4, 0))!,
  'carousel': _baseOutside.project(const _V(_carouselX, 1.2, 0))!,
  'lawn': _baseOutside.project(const _V(-7, 0, 0))!,
};

/// The result card on the canvas (HTML `#observation-card`).
enum _Obs { none, tree, seat, park }

/// Items of the Reference Toolbox.
enum _Tool {
  tree('icon_tree', Icons.park),
  seat('icon_seat', Icons.event_seat),
  linear('lbl_linear', Icons.touch_app),
  osc('lbl_osc', Icons.touch_app),
  circ('lbl_circ', Icons.touch_app);

  const _Tool(this.key, this.icon);
  final String key;
  final IconData icon;

  bool get isReference => this == _Tool.tree || this == _Tool.seat;

  /// The equipment a motion label belongs on.
  _Equip? get equip => switch (this) {
    _Tool.linear => _Equip.slide,
    _Tool.osc => _Equip.swing,
    _Tool.circ => _Equip.carousel,
    _ => null,
  };

  /// HTML label colours (`bg-emerald-600`, `bg-pink-600`, `bg-cyan-600`).
  Color get fill => equip?.color ?? _Colors.indigo500;
}

/// How a toolbox item is shown.
enum _ToolState { ready, locked, done, selected }

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based step; steps.length + 1 once the scenario is concluded.
  int step = 1;
  _Obs obs = _Obs.none;

  // ------------------------------------------------------------ scenario 1
  double busX = _busStartX;

  /// HTML `s1State`: isPlaying, isInside, treeRef, seatRef.
  bool playing = false;
  bool inside = false;
  bool treeRef = false;
  bool seatRef = false;

  /// The seat icon is enabled (HTML: after the tree card's button).
  bool seatUnlocked = false;

  // ------------------------------------------------------------ scenario 2
  final Set<_Equip> pathShown = {};
  double swingAngle = 0;
  double carouselAngle = 0;
  bool sliding = false;
  double slideProgress = 0;

  /// Motion labels put on their equipment, and when.
  final Map<_Tool, double> placed = {};

  /// A label tapped in the toolbox, waiting for a tap on the equipment.
  _Tool? selected;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  bool get framingSettled => _framingT >= 1;

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    obs = _Obs.none;
    busX = _busStartX;
    playing = false;
    inside = false;
    treeRef = false;
    seatRef = false;
    seatUnlocked = false;
    pathShown.clear();
    sliding = false;
    slideProgress = 0;
    placed.clear();
    selected = null;
  }

  /// HTML `animate()`: bus, swing, merry-go-round, slide; then the framing.
  void advance(double dt) {
    if (scenario == 0) {
      if (playing) {
        busX += _busSpeed * dt;
        if (busX > _busWrapX) busX = -_busWrapX;
      }
    } else {
      swingAngle += _swingRate * dt;
      carouselAngle += _carouselRate * dt;
      if (sliding) {
        slideProgress += dt / _slideSeconds;
        if (slideProgress > 1) {
          slideProgress = 0;
          sliding = false;
        }
      }
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
    }
  }

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  /// HTML `#floating-toolbox`: S1 once inside the bus, S2 at step 4 until
  /// every label is placed; hidden while the result card is up.
  bool get toolboxVisible =>
      obs == _Obs.none &&
      (scenario == 0 ? inside : step == 4 && placed.length < 3);

  List<_Tool> get tools => scenario == 0
      ? const [_Tool.tree, _Tool.seat]
      : [
          for (final t in const [_Tool.linear, _Tool.osc, _Tool.circ])
            if (!placed.containsKey(t)) t,
        ];

  _ToolState toolState(_Tool t) {
    if (scenario == 0) {
      if (t == _Tool.tree) return treeRef ? _ToolState.done : _ToolState.ready;
      if (seatRef) return _ToolState.done;
      return seatUnlocked ? _ToolState.ready : _ToolState.locked;
    }
    return selected == t ? _ToolState.selected : _ToolState.ready;
  }

  /// Can [t] be dropped (or used) now?
  bool canUse(_Tool t) {
    if (scenario == 0) {
      return t == _Tool.tree
          ? step == 3 && !treeRef
          : step == 4 && seatUnlocked && !seatRef;
    }
    return step == 4 && t.equip != null && !placed.containsKey(t);
  }

  /// The camera of the current view (HTML `resetCamera()`), in [framing].
  _Cam camera() {
    if (scenario == 0 && inside) {
      final b = _V(busX, 0, 0);
      return _Cam(b + _insideEye, b + _insideTarget, framing);
    }
    return _Cam(_outsideEye, _outsideTarget, framing);
  }

  /// What the framing keeps in view for the current state.
  Rect focusBounds() {
    if (scenario == 1) return _parkBounds;
    return inside ? _insideBounds : _outsideBounds;
  }

  /// Tap / drop zone of [e] in the current framing.
  Rect zone(_Equip e) => framing.mapRect(_baseZones[e]!).inflate(_zonePad);

  /// The equipment under [p] (design coordinates), if any.
  _Equip? equipAt(Offset p) {
    _Equip? best;
    var bestD = double.infinity;
    for (final e in _Equip.values) {
      final z = zone(e);
      if (!z.contains(p)) continue;
      final d = (z.center - p).distance;
      if (d < bestD) {
        bestD = d;
        best = e;
      }
    }
    return best;
  }

  /// Design point of a named place in the scene, in the current framing
  /// (used by the instruction-flow tests): 'deepa', 'slide', 'swing',
  /// 'carousel' or 'lawn'.
  Offset anchor(String id) {
    if (id == 'deepa') {
      return camera().project(_V(busX, 0, 0) + _deepaHead) ?? _designCenter;
    }
    return framing.map(_baseAnchors[id] ?? _designCenter);
  }
}

/// Best framing for [bounds] (base projection) inside [free], clear of the
/// [hard] obstacles and, when that costs little, of the [soft] one (all in
/// design coordinates).
_Framing _fitFraming(Rect bounds, Rect free, List<Rect> hard, Rect? soft) {
  if (free.width <= 1 || free.height <= 1 || bounds.isEmpty) {
    return _Framing.base;
  }
  (Rect, double)? best(List<Rect> obstacles) {
    var rects = [free];
    for (final o in obstacles) {
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
    (Rect, double)? pick;
    for (final r in rects) {
      final z = math.min(
        _maxZoom,
        math.min(r.width / bounds.width, r.height / bounds.height),
      );
      if (pick == null ||
          z > pick.$2 + 1e-6 ||
          ((z - pick.$2).abs() <= 1e-6 &&
              r.width * r.height > pick.$1.width * pick.$1.height)) {
        pick = (r, z);
      }
    }
    return pick;
  }

  var choice = best(hard);
  if (soft != null) {
    final avoid = best([...hard, soft]);
    if (avoid != null &&
        (choice == null || avoid.$2 >= _softShare * choice.$2)) {
      choice = avoid;
    }
  }
  if (choice == null || choice.$2 <= 0) return _Framing.base;
  final (rect, zoom) = choice;
  return _Framing(rect.center - (bounds.center - _designCenter) * zoom, zoom);
}

class _MotionLabState
    extends State<Ch5A6MotionRestAndClassificationOfMotionPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// The canvas area (an invisible full-size overlay), the toolbox, the
  /// result card and the scene's design box: measured to fit the scene
  /// beside the cards and to map drops into the scene.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch5-a6-canvas');
  final GlobalKey _toolboxKey = GlobalKey(debugLabel: 'ch5-a6-toolbox');
  final GlobalKey _resultKey = GlobalKey(debugLabel: 'ch5-a6-result');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch5-a6-design');

  /// Scene label size, and the canvas's left edge and the tool column's
  /// left edge (design px): labels are kept between them.
  double _labelSize = _labelPx;
  double _labelLeft = 0;
  double _labelRight = _design.width;

  /// Where the toolbox has been in this scenario (canvas px, at its
  /// tallest): the scene keeps clear of it while the toolbox or the result
  /// card in its place is up, so it does not jump when a label leaves the
  /// toolbox or the card replaces it.
  Rect? _toolboxRect;
  bool _framingQueued = false;
  bool _snapFraming = true;

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

  /// HTML `animate()`; then one repaint of the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.advance(dt);
    _frame.value = now;
  }

  // -------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (cards and canvas are laid out by
  /// then). [snap] jumps there instead of sliding (new scenario or camera).
  void _scheduleFraming({bool snap = false}) {
    if (snap) _snapFraming = true;
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the current view's focus into the part of the canvas no card
  /// covers: the tool column, the HUD (sidebar open), the floating mission
  /// card (sidebar collapsed), the toolbox and, when that costs little, the
  /// result card.
  void _updateFraming() {
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
    if (!open && _lab.isLabActive) {
      final bottom = screen.height < _compactBelow
          ? _missionTop + pad.top + screen.height * _compactCardMax
          : size.height;
      hard.add(Rect.fromLTRB(0, 0, insets.left, bottom));
    }
    if (_scene.toolboxVisible) {
      final box = measured(_toolboxKey);
      if (box != null) {
        final kept = _toolboxRect;
        _toolboxRect = Rect.fromLTWH(
          box.left,
          box.top,
          box.width,
          math.max(box.height, kept?.height ?? 0),
        );
      }
    }
    final toolbox = _toolboxRect;
    if (toolbox != null && (_scene.toolboxVisible || _scene.obs != _Obs.none)) {
      hard.add(toolbox);
    }
    final card = _scene.obs == _Obs.none ? null : measured(_resultKey);
    _labelLeft = (4 - stage.dx) / fit;
    _labelRight = (size.width - insets.right - stage.dx) / fit;
    final target = _fitFraming(
      _scene.focusBounds(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
      card == null ? null : toDesign(card.inflate(_cardGap)),
    );
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _toolboxRect = null;
    });
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// HTML `playBusAnimation()`.
  void _playBus() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 1) return;
    _Sound.measure.play();
    setState(() {
      s.playing = true;
      s.step = 2;
    });
    _lab.showToast(_t('toast_bus_moving'), sound: false);
  }

  /// HTML `rideBusView()`: the camera moves inside the bus and the
  /// Reference Toolbox opens.
  void _rideBus() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 2) return;
    _Sound.pop.play();
    setState(() {
      s.inside = true;
      s.step = 3;
    });
    _lab.showToast(_t('toast_inside_view'), sound: false);
    _scheduleFraming(snap: true);
  }

  /// HTML `triggerDropItem('tree' | 'seat')`. The tree counts only at
  /// step 3 (the HTML re-ran it at any time and sent step 5 back to 4).
  void _testReference(_Tool t) {
    final s = _scene;
    if (!s.canUse(t)) return;
    _Sound.success.play();
    setState(() {
      if (t == _Tool.tree) {
        s
          ..treeRef = true
          ..playing = true
          ..step = 4
          ..obs = _Obs.tree;
      } else {
        s
          ..seatRef = true
          ..step = 5
          ..obs = _Obs.seat;
      }
    });
  }

  /// HTML `closeObsCard()` and its callback.
  void _onResultButton() {
    final s = _scene;
    final obs = s.obs;
    if (obs == _Obs.none) return;
    _Sound.pop.play();
    setState(() {
      s.obs = _Obs.none;
      if (obs == _Obs.tree) s.seatUnlocked = true;
    });
    switch (obs) {
      case _Obs.tree:
        _lab.showToast(_t('toast_drag_seat_next'), sound: false);
      case _Obs.seat:
        _conclude(0);
      case _Obs.park:
        _conclude(1);
      case _Obs.none:
        break;
    }
  }

  /// HTML `showObservationPopup()`: S1 summary ("Scenario 1 Complete!"),
  /// S2 trophy ("Mastery Achieved!").
  void _conclude(int scenario) {
    setState(() => _scene.step = _stepCounts[scenario] + 1);
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      heading: () => scenario == 0
          ? labFormat(_t('sc_complete'), {'n': 1})
          : _t('all_complete'),
      body: () => _t(scenario == 0 ? 's1_summary' : 'all_complete_desc'),
    );
  }

  /// HTML `triggerParkMotion(type)`. Each step counts only its own
  /// equipment (the HTML jumped to step 4 and opened the toolbox when the
  /// merry-go-round was clicked first).
  void _parkMotion(_Equip e) {
    final s = _scene;
    if (s.scenario != 1) return;
    _Sound.measure.play();
    setState(() {
      s.pathShown.add(e);
      if (e == _Equip.slide) {
        s
          ..sliding = true
          ..slideProgress = 0;
      }
      if (s.step == e.index + 1) s.step++;
    });
    _lab.showToast(_t(e.toastKey), sound: false);
  }

  /// A motion label dropped (or placed by tap) on [e]. The HTML accepted
  /// every label wherever it was dropped; here it must be the matching
  /// equipment.
  void _placeLabel(_Tool t, _Equip? e) {
    final s = _scene;
    if (!s.canUse(t)) return;
    if (e == null) {
      _lab.showToast(_t('toast_drop_on_equipment'), isError: true);
      return;
    }
    if (e != t.equip) {
      _lab.showToast(_t(e.wrongKey), isError: true);
      return;
    }
    _Sound.success.play();
    setState(() {
      s.placed[t] = s.time;
      s.selected = null;
      if (s.placed.length == 3) {
        s
          ..step = 5
          ..obs = _Obs.park;
      }
    });
    _lab.showToast(_t('toast_${t.name}_matched'), sound: false);
  }

  // -------------------------------------------------------------- gestures

  /// Toolbox item tapped (HTML `onclick="triggerDropItem(...)"`). A tapped
  /// motion label is selected; the next tap on the equipment places it.
  void _onToolTap(_Tool t) {
    final s = _scene;
    if (s.scenario == 0) {
      if (s.canUse(t)) {
        _testReference(t);
      } else if (t == _Tool.seat && !s.seatRef) {
        _lab.showToast(_t('toast_seat_locked'), isError: true);
      }
      return;
    }
    if (!s.canUse(t)) return;
    _Sound.pop.play();
    final select = s.selected != t;
    setState(() => s.selected = select ? t : null);
    if (select) {
      _lab.showToast(
        labFormat(_t('toast_label_selected'), {'label': _t(t.key)}),
        sound: false,
      );
    }
  }

  /// A toolbox item dropped on the scene at [global] (HTML `onDropItem`;
  /// S1 accepts a drop anywhere on the scene, as the HTML drop zone did).
  void _onDrop(_Tool t, Offset global) {
    final s = _scene;
    if (s.scenario == 0) {
      _testReference(t);
      return;
    }
    final local = labGlobalToLocal(_designKey, global);
    _placeLabel(t, local == null ? null : s.equipAt(local));
  }

  /// A tap on the playground: places the selected label, or sets the
  /// tapped equipment moving (the HTML promised "Click Equipment in 3D or
  /// below" but had no 3D click handler).
  void _onStageTap(Offset p) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 1) return;
    final e = s.equipAt(p);
    final sel = s.selected;
    if (sel != null && s.canUse(sel)) {
      _placeLabel(sel, e);
      return;
    }
    if (e != null) _parkMotion(e);
  }

  // -------------------------------------------------------------------- UI

  /// HTML bottom control banner: S1 Play / Ride, S2 the three equipment
  /// buttons.
  List<LabAction> _actions() {
    final s = _scene;
    final p = _lab.palette;
    // The result card's button, also offered with the other actions.
    final result = s.obs == _Obs.none
        ? null
        : LabAction(
            label: _t('${_resultKeys.$2}_btn'),
            icon: _resultButtonIcon,
            color: _Colors.blue600,
            foreground: _Colors.white,
            highlight: true,
            silent: true,
            onTap: _onResultButton,
          );
    if (s.scenario == 0) {
      if (s.step > 2) return [?result];
      return [
        LabAction(
          label: _t('btn_play_bus'),
          icon: Icons.play_arrow_rounded,
          color: p.accent,
          foreground: p.onAccent,
          enabled: s.step == 1,
          highlight: s.step == 1,
          silent: true,
          onTap: _playBus,
        ),
        if (s.step == 2)
          LabAction(
            label: _t('btn_ride_bus'),
            icon: Icons.visibility,
            color: _Colors.indigo600,
            foreground: _Colors.white,
            highlight: true,
            silent: true,
            onTap: _rideBus,
          ),
      ];
    }
    return [
      ?result,
      for (final e in _Equip.values)
        LabAction(
          label: _t(e.buttonKey),
          icon: e.icon,
          color: e.color,
          foreground: _Colors.white,
          highlight: s.step == e.index + 1,
          silent: true,
          onTap: () => _parkMotion(e),
        ),
    ];
  }

  /// Width of the canvas (screen minus the sidebar, as the shell sizes it).
  double _canvasWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (!_lab.isSidebarOpen) return w;
    final min = math.max(180.0, w * 0.2);
    final max = math.max(min, w * 0.5);
    return w - (w * _lab.sidebarFraction).clamp(min, max);
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
        final room = math.max(
          0.0,
          _canvasWidth(context) - inset.left - inset.right,
        );
        final screenH = MediaQuery.sizeOf(context).height;
        // The HUD chip at the bottom of the canvas is drawn above the
        // overlays, so the result card stops above it.
        final hud = _lab.isSidebarOpen ? _hudBand * s + 8 : 0.0;
        // Landscape phones get the toolbox strip (see [_toolbox]).
        final wideToolbox = screenH < _compactBelow;
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.directions_run,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, data.steps.length)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('steps-$sc-${_scene.step}'),
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
            // Measures the canvas (full size, not movable).
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#floating-toolbox` (top right of the canvas).
            if (_lab.isLabActive && _scene.toolboxVisible)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: wideToolbox
                    ? _toolbox(s, math.min(room, 470 * s), wide: true)
                    : _toolbox(
                        s,
                        math.min((room * 0.55).clamp(150.0, 230 * s), room),
                        wide: false,
                      ),
              ),
            // HTML `#observation-card`, in the toolbox's place.
            if (_lab.isLabActive && _scene.obs != _Obs.none)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _resultCard(
                  s,
                  math.min((room * 0.62).clamp(200.0, 360 * s), room),
                  math.max(120.0, screenH - inset.top - inset.bottom - hud - 8),
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: DragTarget<_Tool>(
            onWillAcceptWithDetails: (d) => _scene.canUse(d.data),
            onAcceptWithDetails: (d) => _onDrop(d.data, d.offset),
            builder: (context, candidates, rejected) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              // The scene is announced by its label instead.
              excludeFromSemantics: true,
              onTapUp: (d) => _onStageTap(d.localPosition),
              child: Semantics(
                image: true,
                label: _t(_scene.scenario == 0 ? 'scene_bus' : 'scene_park'),
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
                      labelLeft: _labelLeft,
                      labelRight: _labelRight,
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

  /// HTML `#floating-toolbox`: "Reference Toolbox" with the S1 reference
  /// icons or the S2 motion labels; each can be dragged onto the scene or
  /// tapped.
  ///
  /// On landscape phones ([wide]) it is a strip with the items side by
  /// side, so the scene fits below it at almost full size; elsewhere a
  /// narrow card with the items stacked, as in the HTML.
  Widget _toolbox(double s, double width, {required bool wide}) {
    final p = _lab.palette;
    final sc = _scene.scenario;
    final title = _t('toolbox_title');
    final tools = _scene.tools;
    final gap = 6 * s;
    final itemWidth = wide
        ? (width - 20 * s - gap * (tools.length - 1)) / tools.length
        : width - 20 * s;
    return SizedBox(
      key: _toolboxKey,
      width: width,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        radius: 16,
        borderColor: _Colors.indigo500.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.back_hand,
                  size: 15 * s,
                  color: p.ink(_Colors.indigo500),
                ),
                SizedBox(width: 6 * s),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w900,
                      letterSpacing: labLetterSpacing(title, 0.8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5 * s),
            Text(
              _t(sc == 0 ? 'toolbox_s1_desc' : 'toolbox_s2_desc'),
              maxLines: wide ? 2 : null,
              overflow: wide ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * s,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            if (wide) ...[
              SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < tools.length; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      Expanded(
                        child: _toolItem(tools[i], s, itemWidth, wide: true),
                      ),
                    ],
                  ],
                ),
              ),
            ] else
              for (final t in tools) ...[
                SizedBox(height: gap),
                _toolItem(t, s, itemWidth, wide: false),
              ],
          ],
        ),
      ),
    );
  }

  Widget _toolItem(_Tool t, double s, double width, {required bool wide}) {
    final p = _lab.palette;
    final label = _t(t.key);
    final state = _scene.toolState(t);
    Widget chip(_ToolState st, {bool lifted = false}) => _ToolChip(
      tool: t,
      label: label,
      state: st,
      palette: p,
      scale: s,
      lifted: lifted,
      compact: wide,
    );
    return Draggable<_Tool>(
      data: t,
      maxSimultaneousDrags: _scene.canUse(t) ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: _Sound.pop.play,
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(width: width, child: chip(state, lifted: true)),
        ),
      ),
      childWhenDragging: chip(_ToolState.locked),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          key: ValueKey('ch5a6-tool-${t.name}'),
          borderRadius: BorderRadius.circular(12 * s),
          onTap: () => _onToolTap(t),
          child: chip(state),
        ),
      ),
    );
  }

  /// Icon and string-key prefix of the open result card.
  (IconData, String) get _resultKeys => switch (_scene.obs) {
    _Obs.tree => (Icons.park, 'obs_tree'),
    _Obs.seat => (Icons.event_seat, 'obs_seat'),
    _ => (Icons.gps_fixed, 'obs_s2'),
  };

  IconData get _resultButtonIcon =>
      _scene.obs == _Obs.tree ? Icons.arrow_forward : Icons.emoji_events;

  /// HTML `#observation-card`: icon, title, description and the button
  /// that moves the investigation on.
  Widget _resultCard(double s, double width, double maxHeight) {
    final (icon, key) = _resultKeys;
    return _ResultCard(
      key: _resultKey,
      icon: icon,
      title: _t('${key}_title'),
      body: _t('${key}_desc'),
      button: _t('${key}_btn'),
      buttonIcon: _resultButtonIcon,
      onPressed: _onResultButton,
      scale: s,
      width: width,
      maxHeight: maxHeight,
    );
  }
}

/// One Reference Toolbox item: an S1 reference icon (tree / seat) or an S2
/// motion label. Built without the shell's style scope so it can also be
/// the drag feedback.
class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.tool,
    required this.label,
    required this.state,
    required this.palette,
    required this.scale,
    this.lifted = false,
    this.compact = false,
  });

  final _Tool tool;
  final String label;
  final _ToolState state;
  final LabPalette palette;
  final double scale;

  /// Shown under the finger while dragged.
  final bool lifted;

  /// Narrow item in the toolbox strip: no hand icon (only the done tick).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final dim = state == _ToolState.locked ? 0.45 : 1.0;
    final reference = tool.isReference;
    final ink = reference
        ? p.ink(p.isDark ? _Colors.indigo400 : _Colors.indigo600)
        : _Colors.white;
    final fill = reference ? p.card : tool.fill;
    final border = state == _ToolState.selected
        ? _Colors.white
        : (reference
              ? _Colors.indigo500.withValues(alpha: lifted ? 1 : 0.45)
              : tool.fill);
    return Container(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: fill.a * dim),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: border.withValues(alpha: border.a * dim),
          width: state == _ToolState.selected ? 2 : 1,
        ),
        boxShadow: [
          if (lifted || state == _ToolState.selected)
            BoxShadow(
              color: tool.fill.withValues(alpha: 0.55),
              blurRadius: 14 * s,
            ),
        ],
      ),
      child: Row(
        children: [
          if (reference) ...[
            Icon(
              tool.icon,
              size: 18 * s,
              color: ink.withValues(alpha: dim),
            ),
            SizedBox(width: 8 * s),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ink.withValues(alpha: dim),
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          if (!compact || state == _ToolState.done) ...[
            SizedBox(width: 6 * s),
            Icon(
              state == _ToolState.done ? Icons.check_circle : Icons.touch_app,
              size: 16 * s,
              color: (state == _ToolState.done ? p.success : ink).withValues(
                alpha: 0.85 * dim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// HTML `#observation-card` (`bg-slate-900/95`, `border-blue-500`, blue
/// title and button) in both themes, as in the HTML.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.button,
    required this.buttonIcon,
    required this.onPressed,
    required this.scale,
    required this.width,
    required this.maxHeight,
  });

  final IconData icon;
  final String title;
  final String body;
  final String button;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final double scale;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: _Colors.resultCardBg,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: _Colors.blue500, width: 2),
          boxShadow: const [
            BoxShadow(
              color: LabInk.shadowStrong,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34 * s,
                    height: 34 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _Colors.blue500.withValues(alpha: 0.2),
                      border: Border.all(
                        color: _Colors.blue500.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(icon, size: 19 * s, color: _Colors.blue400),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: _Colors.blue400,
                        fontSize: 13.5 * s,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * s),
              Text(
                body,
                style: TextStyle(
                  color: _Colors.slate200,
                  fontSize: 11.5 * s,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 10 * s),
              LabActionButton(
                key: const ValueKey('ch5a6-result-button'),
                action: LabAction(
                  label: button,
                  icon: buttonIcon,
                  color: _Colors.blue600,
                  foreground: _Colors.white,
                  silent: true,
                  onTap: onPressed,
                ),
                scale: s,
                dense: true,
              ),
            ],
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
    // Future steps: HTML `opacity-50 pointer-events-none`.
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

/// Three.js geometry kinds the scene uses.
enum _Shape { box, cylinder, sphere, cap, rod, torus }

/// One mesh of a model: a Three.js geometry at a local transform.
@immutable
class _Part {
  const _Part(
    this.shape,
    this.xf,
    this.color, {
    this.a = 0,
    this.b = 0,
    this.c = 0,
    this.seg = 12,
    this.layer = 2,
    this.opacity = 1,
    this.lit = true,
    this.edge = 0,
    this.interior = false,
    this.exterior = false,
    this.minPx = 0,
    this.bias = 0,
  });

  final _Shape shape;
  final _Xf xf;
  final Color color;

  /// box: width, height, depth; cylinder: top radius, bottom radius,
  /// height; sphere / cap: radius; rod: radius, -, length; torus: radius,
  /// tube.
  final double a;
  final double b;
  final double c;

  /// Radial segments of a cylinder.
  final int seg;

  /// Draw layer (0 ground, 1 platforms / bus shell, 2 objects, 3 overlays).
  final int layer;
  final double opacity;

  /// MeshStandardMaterial (lit) or MeshBasicMaterial.
  final bool lit;

  /// Outline strength of a box's faces.
  final double edge;

  /// Inside the bus (drawn only in the interior view, hidden by the
  /// opaque body outside, as in the HTML).
  final bool interior;

  /// Below, in front of or beside the body (wheels, headlights, the aisle
  /// window): left out of the interior view, where the HTML camera never
  /// shows them but the wider framing would (through the see-through
  /// floor, or right beside the camera).
  final bool exterior;

  /// Skipped when smaller than this (design px): eyes, smile.
  final double minPx;

  /// Added to the distance used for depth sorting.
  final double bias;

  /// This part placed in a group at [parent].
  _Part within(_Xf parent, {bool? interior, int? layer}) => _Part(
    shape,
    parent * xf,
    color,
    a: a,
    b: b,
    c: c,
    seg: seg,
    layer: layer ?? this.layer,
    opacity: opacity,
    lit: lit,
    edge: edge,
    interior: interior ?? this.interior,
    exterior: exterior,
    minPx: minPx,
    bias: bias,
  );
}

/// `createDetailedPerson(posture)` arm / leg poses.
enum _Posture { sitting, holding, sliding }

/// HTML `createDetailedPerson(shirt, pants, hair, posture)`, in the
/// person's own frame (feet at y = 0, facing +z).
List<_Part> _person(Color shirt, Color pants, Color hair, _Posture posture) {
  // Sitting and holding hold the arms forward; sliding lets them hang.
  final forward = posture != _Posture.sliding;
  return [
    _Part(_Shape.sphere, _Xf.at(0, 1.95, 0), _Colors.skin, a: _headRadius),
    // Hair: the top half of a 0.40 sphere, drawn over the head.
    _Part(_Shape.cap, _Xf.at(0, 1.98, 0), hair, a: 0.40, bias: -0.01),
    for (final x in const [0.14, -0.14])
      _Part(
        _Shape.sphere,
        _Xf.at(x, 1.98, 0.34),
        _Colors.eye,
        a: 0.04,
        lit: false,
        minPx: 1.2,
      ),
    _Part(
      _Shape.box,
      _Xf.at(0, 1.84, 0.36),
      _Colors.smile,
      a: 0.16,
      b: 0.03,
      c: 0.03,
      lit: false,
      minPx: 4,
    ),
    _Part(
      _Shape.cylinder,
      _Xf.at(0, 1.65, 0),
      _Colors.skin,
      a: 0.12,
      b: 0.14,
      c: 0.18,
      seg: 8,
    ),
    _Part(_Shape.box, _Xf.at(0, 1.15, 0), shirt, a: 0.7, b: 0.85, c: 0.5),
    for (final x in const [0.44, -0.44]) ...[
      _Part(
        _Shape.cylinder,
        forward ? _Xf.at(x, 1.1, 0.25, rx: math.pi / 3) : _Xf.at(x, 1.1, 0),
        shirt,
        a: 0.12,
        b: 0.12,
        c: 0.7,
        seg: 8,
      ),
      _Part(
        _Shape.sphere,
        forward ? _Xf.at(x, 0.8, 0.55) : _Xf.at(x, 0.7, 0),
        _Colors.skin,
        a: 0.12,
      ),
    ],
    // Sitting, holding and sliding all bend the legs forward.
    for (final x in const [0.2, -0.2]) ...[
      _Part(
        _Shape.cylinder,
        _Xf.at(x, 0.65, 0.4, rx: math.pi / 2),
        pants,
        a: 0.15,
        b: 0.14,
        c: 0.75,
        seg: 8,
      ),
      _Part(
        _Shape.box,
        _Xf.at(x, 0.65, 0.8),
        _Colors.shoe,
        a: 0.2,
        b: 0.16,
        c: 0.38,
      ),
    ],
  ];
}

/// The HTML ground (90 x 35, S1) and lawn (70 x 35, S2) end just outside
/// the HTML camera's view. When the scene is re-framed beside the cards
/// their ends and front edge would show, so both reach further: the far
/// edge stays at z = -17.5 (the horizon), the rest is extended.
const double _groundWidth = 300;
const double _groundBack = 17.5;
const double _groundFront = 45;

/// Road dashes every 6 along x (the HTML drew them for x = -40 … 40).
const double _dashReach = 64;

/// `buildScenario1()` ground layer, back to front: ground, grass curb,
/// road, edge lines, yellow dashes.
final List<_Part> _roadParts = [
  _Part(
    _Shape.box,
    _Xf.at(0, -0.2, _groundFront / 2 - _groundBack / 2),
    _Colors.ground,
    a: _groundWidth,
    b: 0.4,
    c: _groundFront + _groundBack,
    layer: 0,
  ),
  _Part(
    _Shape.box,
    _Xf.at(0, -0.1, -13),
    _Colors.grass,
    a: _groundWidth,
    b: 0.6,
    c: 12,
    layer: 0,
  ),
  _Part(
    _Shape.box,
    _Xf.at(0, -0.15, 0),
    _Colors.road,
    a: _groundWidth,
    b: 0.45,
    c: 14,
    layer: 0,
  ),
  for (final z in const [6.0, -6.0])
    _Part(
      _Shape.box,
      _Xf.at(0, -0.14, z),
      _Colors.roadLine,
      a: _groundWidth,
      b: 0.48,
      c: 0.4,
      layer: 0,
    ),
  for (var x = -_dashReach; x <= _dashReach; x += 6)
    _Part(
      _Shape.box,
      _Xf.at(x, -0.14, 0),
      _Colors.roadDash,
      a: 3.5,
      b: 0.48,
      c: 0.35,
      layer: 0,
    ),
];

/// The roadside tree at (0, 0, -9): trunk, three leaf cones, four apples.
final List<_Part> _treeParts = [
  for (final p in [
    _Part(
      _Shape.cylinder,
      _Xf.at(0, 2.5, 0),
      _Colors.trunk,
      a: 0.6,
      b: 0.9,
      c: 5,
      seg: 14,
    ),
    _Part(
      _Shape.cylinder,
      _Xf.at(0, 5.5, 0),
      _Colors.leaves1,
      a: 0,
      b: 3.5,
      c: 4.5,
      seg: 16,
    ),
    _Part(
      _Shape.cylinder,
      _Xf.at(0, 7.5, 0),
      _Colors.leaves2,
      a: 0,
      b: 2.6,
      c: 3.8,
      seg: 16,
    ),
    _Part(
      _Shape.cylinder,
      _Xf.at(0, 9.2, 0),
      _Colors.leaves3,
      a: 0,
      b: 1.8,
      c: 3,
      seg: 16,
    ),
    for (final (x, y, z) in const [
      (-1.5, 5.0, 1.5),
      (1.5, 5.5, -1.0),
      (0.0, 7.0, 1.8),
      (-1.0, 7.2, -1.2),
    ])
      _Part(_Shape.sphere, _Xf.at(x, y, z), _Colors.apple, a: 0.3),
  ])
    p.within(_Xf.at(0, 0, -9), layer: 1),
];

/// The school bus (bus frame; the bus moves along x): body, hood, roof,
/// windows, headlights, wheels, and inside it Deepa and Rahul on their
/// seats and the steering wheel.
final List<_Part> _busParts = () {
  List<_Part> seated(_Xf group, List<_Part> figure) => [
    for (final p in figure)
      p.within(group * _Xf.at(0, _figureLift, 0), interior: true),
    _Part(
      _Shape.box,
      group * _Xf.at(-0.4, 2.1, 0),
      _Colors.seatBack,
      a: 0.3,
      b: 1.6,
      c: 1.2,
      edge: 0.2,
      interior: true,
    ),
    _Part(
      _Shape.box,
      group * _Xf.at(0, 1.35, 0),
      _Colors.seatBottom,
      a: 1.2,
      b: 0.3,
      c: 1.2,
      edge: 0.2,
      interior: true,
    ),
  ];
  const wheels = [(-3.2, 1.95), (3.5, 1.95), (-3.2, -1.95), (3.5, -1.95)];
  return [
    _Part(
      _Shape.box,
      _Xf.at(0, 2.5, 0),
      _Colors.busYellow,
      a: 10,
      b: 3.6,
      c: 3.8,
      layer: 1,
      edge: 0.3,
    ),
    _Part(
      _Shape.box,
      _Xf.at(5.8, 1.8, 0),
      _Colors.busYellow,
      a: 2.2,
      b: 2.2,
      c: 3.6,
      layer: 1,
      edge: 0.3,
    ),
    _Part(
      _Shape.box,
      _Xf.at(0, 4.5, 0),
      _Colors.busRoof,
      a: 9.8,
      b: 0.4,
      c: 3.6,
      layer: 1,
      edge: 0.25,
    ),
    // Blue transparent glass (opacity 0.65).
    _Part(
      _Shape.box,
      _Xf.at(5.02, 3.2, 0),
      _Colors.glass,
      a: 0.1,
      b: 1.5,
      c: 3.2,
      layer: 1,
      opacity: 0.65,
    ),
    // The window on the aisle side (z = -1.92) is beside the inside
    // camera; it is drawn only from outside.
    for (final z in const [1.92, -1.92])
      _Part(
        _Shape.box,
        _Xf.at(-0.2, 3.2, z),
        _Colors.glass,
        a: 8.5,
        b: 1.4,
        c: 0.1,
        layer: 1,
        opacity: 0.65,
        exterior: z < 0,
      ),
    // Headlights glow (emissive): unlit.
    for (final z in const [1.2, -1.2])
      _Part(
        _Shape.cylinder,
        _Xf.at(6.9, 1.8, z, rz: math.pi / 2),
        _Colors.headlight,
        a: 0.3,
        b: 0.3,
        c: 0.2,
        seg: 12,
        layer: 1,
        lit: false,
        exterior: true,
      ),
    for (final (x, z) in wheels) ...[
      _Part(
        _Shape.cylinder,
        _Xf.at(x, 0.85, z, rx: math.pi / 2),
        _Colors.tyre,
        a: 0.85,
        b: 0.85,
        c: 0.6,
        seg: 16,
        layer: 1,
        exterior: true,
      ),
      _Part(
        _Shape.cylinder,
        _Xf.at(x, 0.85, z, rx: math.pi / 2),
        _Colors.rim,
        a: 0.4,
        b: 0.4,
        c: 0.65,
        seg: 12,
        layer: 1,
        bias: -0.01,
        exterior: true,
      ),
    ],
    _Part(
      _Shape.torus,
      _Xf.at(4.5, 2.6, 1.0, ry: math.pi / 2),
      _Colors.steering,
      a: 0.35,
      b: 0.06,
      interior: true,
    ),
    ...seated(
      _Xf.at(_deepaSeat.x, 0, _deepaSeat.z),
      _person(
        _Colors.deepaShirt,
        _Colors.deepaJeans,
        _Colors.darkHair,
        _Posture.sitting,
      ),
    ),
    ...seated(
      _Xf.at(3.5, 0, 1.1),
      _person(
        _Colors.rahulShirt,
        _Colors.slateJeans,
        _Colors.brownHair,
        _Posture.sitting,
      ),
    ),
  ];
}();

/// `buildScenario2()` lawn.
final List<_Part> _lawnParts = [
  _Part(
    _Shape.box,
    _Xf.at(0, -0.2, _groundFront / 2 - _groundBack / 2),
    _Colors.lawn,
    a: _groundWidth,
    b: 0.4,
    c: _groundFront + _groundBack,
    layer: 0,
  ),
];

/// The slide at (-14, 0, 0): ladder and the board tilted by -0.6 rad.
final List<_Part> _slideParts = [
  _Part(
    _Shape.box,
    _Xf.at(_slideGroupX - 3, 3, 0),
    _Colors.ladder,
    a: 1.5,
    b: 6,
    c: 0.3,
    layer: 1,
    edge: 0.25,
  ),
  _Part(
    _Shape.box,
    _Xf.at(_slideGroupX + 0.5, 3, 0, rz: -0.6),
    _Colors.slideBoard,
    a: 8,
    b: 0.3,
    c: 1.5,
    layer: 1,
    edge: 0.25,
  ),
];

/// The child on the slide, facing down the slope.
final List<_Part> _sliderChild = _person(
  _Colors.sliderShirt,
  _Colors.sliderShorts,
  _Colors.darkHair,
  _Posture.sliding,
);

/// HTML `sliderChild.rotation.y = π/2; rotation.z = -0.6` ("angle with
/// slope"). In Euler order XYZ that rolls the child sideways; the child is
/// tilted along the slope instead (turned to face +x, then pitched).
final _Xf _sliderTilt =
    _Xf.at(0, 0, 0, rz: -0.6) * _Xf.at(0, 0, 0, ry: math.pi / 2);

/// The swing frame at the origin: two poles and the top bar.
final List<_Part> _swingFrame = [
  for (final x in const [-2.8, 2.8])
    _Part(
      _Shape.cylinder,
      _Xf.at(x, 3.75, 0),
      _Colors.swingPole,
      a: 0.18,
      b: 0.25,
      c: 7.5,
      seg: 10,
    ),
  _Part(
    _Shape.cylinder,
    _Xf.at(0, _swingPivotY, 0, rz: math.pi / 2),
    _Colors.swingBar,
    a: 0.2,
    b: 0.2,
    c: 6,
    seg: 10,
  ),
];

/// The swing seat (in its pivot frame at (0, 7.2, 0)): ropes, plank and the
/// child (`rotation.y = π/2`).
final List<_Part> _swingSeat = [
  for (final x in const [-0.7, 0.7])
    _Part(
      _Shape.rod,
      _Xf.at(x, -_ropeLength / 2, 0),
      _Colors.rope,
      a: 0.04,
      c: _ropeLength,
      lit: false,
    ),
  _Part(
    _Shape.box,
    _Xf.at(0, -_ropeLength, 0),
    _Colors.plank,
    a: 1.8,
    b: 0.2,
    c: 0.8,
    edge: 0.3,
  ),
  for (final p in _person(
    _Colors.swingShirt,
    _Colors.swingPants,
    _Colors.brownHair,
    _Posture.holding,
  ))
    p.within(_Xf.at(0, -6.15, 0, ry: math.pi / 2)),
];

/// The merry-go-round's fixed base pole (y 0 … 2) at (14, 0, 0), split
/// where the disc cuts it: the lower part is drawn before the disc, the
/// upper part after it.
final List<_Part> _carouselBase = [
  _Part(
    _Shape.cylinder,
    _Xf.at(_carouselX, 0.425, 0),
    _Colors.carouselPole,
    a: 0.4075,
    b: 0.45,
    c: 0.85,
    seg: 12,
    layer: 1,
  ),
  _Part(
    _Shape.cylinder,
    _Xf.at(_carouselX, 1.575, 0),
    _Colors.carouselPole,
    a: 0.35,
    b: 0.3925,
    c: 0.85,
    seg: 12,
  ),
];

/// The turning platform (in its frame at (14, 1, 0)): disc, centre handle
/// and two riders.
final List<_Part> _carouselPlatform = [
  _Part(
    _Shape.cylinder,
    _Xf.at(0, 0, 0),
    _Colors.carouselDisc,
    a: 3.8,
    b: 3.8,
    c: 0.3,
    seg: 24,
    layer: 1,
  ),
  _Part(
    _Shape.cylinder,
    _Xf.at(0, 1.1, 0),
    _Colors.carouselHandle,
    a: 0.18,
    b: 0.18,
    c: 2.2,
    seg: 10,
  ),
  for (final p in _person(
    _Colors.rider1Shirt,
    _Colors.deepaJeans,
    _Colors.darkHair,
    _Posture.holding,
  ))
    p.within(_Xf.at(2.2, -0.5, 0, ry: math.pi)),
  for (final p in _person(
    _Colors.rider2Shirt,
    _Colors.slateJeans,
    _Colors.brownHair,
    _Posture.holding,
  ))
    p.within(_Xf.at(-2.2, -0.5, 0)),
];

/// HTML trajectory lines: the slide's straight line, the swing's arc
/// (a = -0.65 … 0.65) and the merry-go-round's circle (r 2.7 at y 1.5).
const List<_V> _slidePath = [
  _V(_slideGroupX - 3, 5.5, 0),
  _V(_slideGroupX + 4, 0.5, 0),
];
final List<_V> _swingPath = [
  for (var a = -0.65; a <= 0.6501; a += 0.05)
    _V(0, _swingPivotY - math.cos(a) * _ropeLength, math.sin(a) * _ropeLength),
];
final List<_V> _carouselPath = [
  for (var th = 0.0; th <= math.pi * 2.05; th += 0.1)
    _V(_carouselX + math.cos(th) * 2.7, 1.5, math.sin(th) * 2.7),
];

/// The swing seat's frame for the current angle.
_Xf _swingXf(double angle) =>
    _Xf.at(0, _swingPivotY, 0, rx: math.sin(angle) * _swingAmplitude);

/// Most points one drawn item can have (a cylinder cap or a path).
const int _maxPoints = 96;

/// What a draw item is.
enum _Kind { poly, circle, cap, stroke }

/// One projected primitive waiting to be drawn (reused every frame).
class _Item {
  _Kind kind = _Kind.poly;
  int layer = 0;
  double depth = 0;
  int seq = 0;
  final Float64List xy = Float64List(2 * _maxPoints);
  int n = 0;
  Color color = _Colors.white;
  Color? edge;
  Color? glow;
  double x = 0;
  double y = 0;
  double r = 0;
  double width = 1;
  bool closed = false;
}

/// Layer first, then far to near, then emission order.
int _compareItems(_Item a, _Item b) {
  if (a.layer != b.layer) return a.layer - b.layer;
  final d = b.depth.compareTo(a.depth);
  return d != 0 ? d : a.seq - b.seq;
}

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal (nx, ny, nz).
Color _lit(Color c, double nx, double ny, double nz) {
  final i =
      _ambient +
      _diffuse * math.max(0.0, nx * _light.x + ny * _light.y + nz * _light.z);
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Box corners: bit 0 = +x, bit 1 = +y, bit 2 = +z. Faces as corner indices
/// and their outward normals.
const List<int> _boxCorners = [
  1, 3, 7, 5, // +x
  0, 4, 6, 2, // -x
  2, 6, 7, 3, // +y
  0, 1, 5, 4, // -y
  4, 5, 7, 6, // +z
  0, 2, 3, 1, // -z
];
const List<double> _boxNormals = [
  1, 0, 0, //
  -1, 0, 0, //
  0, 1, 0, //
  0, -1, 0, //
  0, 0, 1, //
  0, 0, -1, //
];

/// A tiny painter's-algorithm renderer for the HTML's Three.js meshes: each
/// primitive is transformed, back-face culled, clipped at the near plane,
/// projected and queued; [flush] sorts the queue (layer, then distance from
/// the camera) and paints it. Buffers and items are reused every frame.
class _R3 {
  late _Cam cam;

  /// Layer of the primitives emitted next.
  int layer = 2;
  double _depth = 0;
  int _seq = 0;
  int _used = 0;
  final List<_Item> _pool = [];
  final List<_Item> _order = [];

  /// World vertices of the face being emitted, camera-space vertices and
  /// the near-clipped polygon.
  final Float64List _w = Float64List(3 * _maxPoints);
  final Float64List _c = Float64List(3 * _maxPoints);
  final Float64List _k = Float64List(3 * _maxPoints);
  final Float64List _corners = Float64List(24);
  final Float64List _rings = Float64List(6 * _maxPoints);
  final Map<int, Float64List> _trig = {};

  void begin(_Cam camera) {
    cam = camera;
    _used = 0;
    _seq = 0;
    _order.clear();
  }

  _Item _take(_Kind kind) {
    if (_used == _pool.length) _pool.add(_Item());
    final it = _pool[_used++]
      ..kind = kind
      ..layer = layer
      // The ground layer is stacked in emission order, not by distance.
      ..depth = layer == 0 ? 0 : _depth
      ..seq = _seq++
      ..edge = null
      ..glow = null
      ..closed = false;
    _order.add(it);
    return it;
  }

  double _distance(double x, double y, double z) {
    final e = cam.eye;
    final dx = x - e.x, dy = y - e.y, dz = z - e.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// cos / sin of [seg] equal steps round a circle.
  Float64List _trigFor(int seg) => _trig[seg] ??= Float64List.fromList([
    for (var i = 0; i < seg; i++) ...[
      math.cos(2 * math.pi * i / seg),
      math.sin(2 * math.pi * i / seg),
    ],
  ]);

  /// Clips the camera-space polygon `_c[0 .. 3n)` to the near plane into
  /// `_k`; returns its vertex count.
  int _clip(int n) {
    var m = 0;
    for (var i = 0; i < n; i++) {
      final j = i + 1 == n ? 0 : i + 1;
      final az = _c[3 * i + 2], bz = _c[3 * j + 2];
      final aIn = az >= _near, bIn = bz >= _near;
      if (aIn) {
        _k[3 * m] = _c[3 * i];
        _k[3 * m + 1] = _c[3 * i + 1];
        _k[3 * m + 2] = az;
        m++;
      }
      if (aIn != bIn) {
        final t = (_near - az) / (bz - az);
        _k[3 * m] = _c[3 * i] + (_c[3 * j] - _c[3 * i]) * t;
        _k[3 * m + 1] = _c[3 * i + 1] + (_c[3 * j + 1] - _c[3 * i + 1]) * t;
        _k[3 * m + 2] = _near;
        m++;
      }
    }
    return m;
  }

  /// Queues the world polygon `_w[0 .. 3n)` with normal (nx, ny, nz).
  void _face(
    int n,
    double nx,
    double ny,
    double nz,
    Color color, {
    required bool lit,
    double opacity = 1,
    double edge = 0,
  }) {
    final e = cam.eye;
    if ((e.x - _w[0]) * nx + (e.y - _w[1]) * ny + (e.z - _w[2]) * nz <= 0) {
      return;
    }
    final f = cam.f, r = cam.r, u = cam.u;
    for (var i = 0; i < n; i++) {
      final dx = _w[3 * i] - e.x;
      final dy = _w[3 * i + 1] - e.y;
      final dz = _w[3 * i + 2] - e.z;
      _c[3 * i] = dx * r.x + dy * r.y + dz * r.z;
      _c[3 * i + 1] = dx * u.x + dy * u.y + dz * u.z;
      _c[3 * i + 2] = dx * f.x + dy * f.y + dz * f.z;
    }
    final m = _clip(n);
    if (m < 3) return;
    final it = _take(_Kind.poly);
    final s = cam.scale, cx = cam.center.dx, cy = cam.center.dy;
    for (var i = 0; i < m; i++) {
      final z = _k[3 * i + 2];
      it.xy[2 * i] = cx + s * _k[3 * i] / z;
      it.xy[2 * i + 1] = cy - s * _k[3 * i + 1] / z;
    }
    it.n = m;
    final base = lit ? _lit(color, nx, ny, nz) : color;
    it.color = opacity < 1 ? base.withValues(alpha: base.a * opacity) : base;
    if (edge > 0) {
      it.edge = labShade(color, -0.5).withValues(alpha: edge * opacity);
    }
  }

  /// `BoxGeometry(w, h, d)` at [xf].
  void box(
    _Xf xf,
    double w,
    double h,
    double d,
    Color color, {
    bool lit = true,
    double opacity = 1,
    double edge = 0,
    double minPx = 0,
    double bias = 0,
  }) {
    if (minPx > 0 && cam.scaleAt(xf.origin) * math.max(w, h) < minPx) return;
    final hx = w / 2, hy = h / 2, hz = d / 2;
    for (var i = 0; i < 8; i++) {
      xf.apply(
        _corners,
        3 * i,
        (i & 1) == 0 ? -hx : hx,
        (i & 2) == 0 ? -hy : hy,
        (i & 4) == 0 ? -hz : hz,
      );
    }
    _depth = _distance(xf.tx, xf.ty, xf.tz) + bias;
    for (var f = 0; f < 6; f++) {
      for (var v = 0; v < 4; v++) {
        final c = _boxCorners[4 * f + v];
        _w[3 * v] = _corners[3 * c];
        _w[3 * v + 1] = _corners[3 * c + 1];
        _w[3 * v + 2] = _corners[3 * c + 2];
      }
      final lx = _boxNormals[3 * f];
      final ly = _boxNormals[3 * f + 1];
      final lz = _boxNormals[3 * f + 2];
      _face(
        4,
        xf.m00 * lx + xf.m01 * ly + xf.m02 * lz,
        xf.m10 * lx + xf.m11 * ly + xf.m12 * lz,
        xf.m20 * lx + xf.m21 * ly + xf.m22 * lz,
        color,
        lit: lit,
        opacity: opacity,
        edge: edge,
      );
    }
  }

  /// `CylinderGeometry(rTop, rBot, h, seg)` at [xf] (a cone when rTop is 0).
  void cylinder(
    _Xf xf,
    double rTop,
    double rBot,
    double h,
    int seg,
    Color color, {
    bool lit = true,
    double opacity = 1,
    double bias = 0,
  }) {
    final t = _trigFor(seg);
    final hy = h / 2;
    for (var i = 0; i < seg; i++) {
      final cs = t[2 * i], sn = t[2 * i + 1];
      xf.apply(_rings, 3 * i, rBot * cs, -hy, rBot * sn);
      xf.apply(_rings, 3 * (seg + i), rTop * cs, hy, rTop * sn);
    }
    _depth = _distance(xf.tx, xf.ty, xf.tz) + bias;
    // Side normal: radial, tilted up by the taper.
    final slope = (rBot - rTop) / h;
    final inv = 1 / math.sqrt(1 + slope * slope);
    for (var i = 0; i < seg; i++) {
      final j = i + 1 == seg ? 0 : i + 1;
      var n = 0;
      void put(int idx) {
        _w[3 * n] = _rings[3 * idx];
        _w[3 * n + 1] = _rings[3 * idx + 1];
        _w[3 * n + 2] = _rings[3 * idx + 2];
        n++;
      }

      put(i);
      put(j);
      if (rTop > 0) put(seg + j);
      put(seg + i);
      var mx = t[2 * i] + t[2 * j], mz = t[2 * i + 1] + t[2 * j + 1];
      final ml = math.sqrt(mx * mx + mz * mz);
      if (ml > 0) {
        mx /= ml;
        mz /= ml;
      }
      final lx = mx * inv, ly = slope * inv, lz = mz * inv;
      _face(
        n,
        xf.m00 * lx + xf.m01 * ly + xf.m02 * lz,
        xf.m10 * lx + xf.m11 * ly + xf.m12 * lz,
        xf.m20 * lx + xf.m21 * ly + xf.m22 * lz,
        color,
        lit: lit,
        opacity: opacity,
      );
    }
    for (final top in const [true, false]) {
      if (top && rTop <= 0) continue;
      for (var i = 0; i < seg; i++) {
        final idx = top ? seg + i : i;
        _w[3 * i] = _rings[3 * idx];
        _w[3 * i + 1] = _rings[3 * idx + 1];
        _w[3 * i + 2] = _rings[3 * idx + 2];
      }
      final ly = top ? 1.0 : -1.0;
      _face(
        seg,
        xf.m01 * ly,
        xf.m11 * ly,
        xf.m21 * ly,
        color,
        lit: lit,
        opacity: opacity,
      );
    }
  }

  /// `SphereGeometry(radius)` at [xf]; [top] draws only its upper half
  /// (the hair cap).
  void sphere(
    _Xf xf,
    double radius,
    Color color, {
    bool lit = true,
    bool top = false,
    double minPx = 0,
    double bias = 0,
  }) {
    final e = cam.eye;
    final dx = xf.tx - e.x, dy = xf.ty - e.y, dz = xf.tz - e.z;
    final f = cam.f;
    final z = dx * f.x + dy * f.y + dz * f.z;
    if (z < _near + radius) return;
    final rr = cam.scale * radius / z;
    if (rr < minPx) return;
    final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
    _depth = dist + bias;
    final it = _take(top ? _Kind.cap : _Kind.circle);
    final r = cam.r, u = cam.u;
    it
      ..x = cam.center.dx + cam.scale * (dx * r.x + dy * r.y + dz * r.z) / z
      ..y = cam.center.dy - cam.scale * (dx * u.x + dy * u.y + dz * u.z) / z
      ..r = rr
      ..color = lit ? _lit(color, -dx / dist, -dy / dist, -dz / dist) : color;
  }

  /// A thin `CylinderGeometry` (ropes) as a line.
  void rod(_Xf xf, double radius, double length, Color color) {
    final a = cam.project(xf.point(0, -length / 2, 0));
    final b = cam.project(xf.point(0, length / 2, 0));
    if (a == null || b == null) return;
    _depth = _distance(xf.tx, xf.ty, xf.tz);
    final it = _take(_Kind.stroke)
      ..n = 2
      ..color = color
      ..width = math.max(1.2, 2 * radius * cam.scaleAt(xf.origin));
    it.xy
      ..[0] = a.dx
      ..[1] = a.dy
      ..[2] = b.dx
      ..[3] = b.dy;
  }

  /// `TorusGeometry(radius, tube)` at [xf] (its ring lies in the local xy
  /// plane) as [arcs] stroked arcs, each sorted on its own so the ring
  /// passes in front of and behind what it wraps.
  void torus(
    _Xf xf,
    double radius,
    double tube,
    Color color, {
    bool lit = true,
    Color? glow,
    int arcs = 8,
    int arcSteps = 4,
    double maxWidth = double.infinity,
  }) {
    final shade = lit ? _lit(color, 0, 1, 0) : color;
    for (var k = 0; k < arcs; k++) {
      var n = 0;
      var sx = 0.0, sy = 0.0, sz = 0.0, sw = 0.0;
      for (var j = 0; j <= arcSteps; j++) {
        final a = 2 * math.pi * (k * arcSteps + j) / (arcs * arcSteps);
        final w = xf.point(radius * math.cos(a), radius * math.sin(a), 0);
        final d = cam.depth(w);
        if (d < _near) continue;
        final p = cam.project(w)!;
        _w[2 * n] = p.dx;
        _w[2 * n + 1] = p.dy;
        n++;
        sx += w.x;
        sy += w.y;
        sz += w.z;
        sw += 2 * tube * cam.scale / d;
      }
      if (n < 2) continue;
      _depth = _distance(sx / n, sy / n, sz / n);
      final it = _take(_Kind.stroke)
        ..n = n
        ..color = shade
        ..glow = glow
        ..width = (sw / n).clamp(1.2, maxWidth);
      for (var i = 0; i < 2 * n; i++) {
        it.xy[i] = _w[i];
      }
    }
  }

  /// The laser cylinder from [a] to [b] (radius [radius]), clipped at the
  /// near plane, as a tapered band with a glow.
  void tube(_V a, _V b, double radius, Color color) {
    var za = cam.depth(a), zb = cam.depth(b);
    if (za < _near && zb < _near) return;
    var pa = a, pb = b;
    if (za < _near) {
      pa = _V.lerp(a, b, (_near - za) / (zb - za));
      za = _near;
    } else if (zb < _near) {
      pb = _V.lerp(a, b, (_near - za) / (zb - za));
      zb = _near;
    }
    final sa = cam.project(pa), sb = cam.project(pb);
    if (sa == null || sb == null) return;
    final dir = sb - sa;
    final len = dir.distance;
    if (len < 0.5) return;
    final nrm = Offset(-dir.dy / len, dir.dx / len);
    final wa = math.min(_laserMaxWidth, 2 * radius * cam.scale / za);
    final wb = math.min(_laserMaxWidth, 2 * radius * cam.scale / zb);
    _depth = _distance((pa.x + pb.x) / 2, (pa.y + pb.y) / 2, (pa.z + pb.z) / 2);
    for (final (k, c) in [(2.6, color.withValues(alpha: 0.3)), (1.0, color)]) {
      final it = _take(_Kind.poly)
        ..n = 4
        ..color = c;
      final q = [
        sa + nrm * (wa * k / 2),
        sb + nrm * (wb * k / 2),
        sb - nrm * (wb * k / 2),
        sa - nrm * (wa * k / 2),
      ];
      for (var i = 0; i < 4; i++) {
        it.xy[2 * i] = q[i].dx;
        it.xy[2 * i + 1] = q[i].dy;
      }
    }
  }

  /// A glowing trajectory line through [points] (HTML `THREE.Line`).
  void line(List<_V> points, Color color, double width) {
    var n = 0;
    final it = _take(_Kind.stroke);
    for (final p in points) {
      final o = cam.project(p);
      if (o == null || n == _maxPoints) continue;
      it.xy[2 * n] = o.dx;
      it.xy[2 * n + 1] = o.dy;
      n++;
    }
    // A light core in the line's colour (the cyan circle lies on the cyan
    // disc) inside a glow of the colour itself.
    it
      ..n = n
      ..color = labShade(color, 0.55)
      ..width = width
      ..glow = color.withValues(alpha: 0.6);
  }

  /// Every mesh of [parts], placed at [world] (null: parts are in world
  /// space); interior parts only when [interior].
  void model(List<_Part> parts, _Xf? world, {bool interior = false}) {
    for (final p in parts) {
      if (p.interior != interior && (p.interior || p.exterior)) continue;
      final xf = world == null ? p.xf : world * p.xf;
      layer = p.layer;
      switch (p.shape) {
        case _Shape.box:
          box(
            xf,
            p.a,
            p.b,
            p.c,
            p.color,
            lit: p.lit,
            opacity: p.opacity,
            edge: p.edge,
            minPx: p.minPx,
            bias: p.bias,
          );
        case _Shape.cylinder:
          cylinder(
            xf,
            p.a,
            p.b,
            p.c,
            p.seg,
            p.color,
            lit: p.lit,
            opacity: p.opacity,
            bias: p.bias,
          );
        case _Shape.sphere:
          sphere(xf, p.a, p.color, lit: p.lit, minPx: p.minPx, bias: p.bias);
        case _Shape.cap:
          sphere(xf, p.a, p.color, lit: p.lit, top: true, bias: p.bias);
        case _Shape.rod:
          rod(xf, p.a, p.c, p.color);
        case _Shape.torus:
          torus(xf, p.a, p.b, p.color, lit: p.lit);
      }
    }
  }

  /// Sorts the queue and paints it.
  void flush(Canvas canvas, _Pens pens) {
    _order.sort(_compareItems);
    final path = pens.path;
    for (final it in _order) {
      switch (it.kind) {
        case _Kind.poly:
          if (it.n < 3) continue;
          path
            ..reset()
            ..moveTo(it.xy[0], it.xy[1]);
          for (var i = 1; i < it.n; i++) {
            path.lineTo(it.xy[2 * i], it.xy[2 * i + 1]);
          }
          path.close();
          canvas.drawPath(path, pens.fill..color = it.color);
          final edge = it.edge;
          if (edge != null) canvas.drawPath(path, pens.edge..color = edge);
        case _Kind.circle:
          final c = Offset(it.x, it.y);
          canvas.drawCircle(c, it.r, pens.fill..color = it.color);
          if (it.r > 2.5) {
            canvas.drawCircle(
              c + Offset(-0.32 * it.r, -0.36 * it.r),
              it.r * 0.36,
              pens.fill..color = labShade(it.color, 0.3),
            );
            canvas.drawCircle(
              c,
              it.r,
              pens.edge
                ..color = labShade(it.color, -0.45).withValues(alpha: 0.6),
            );
          }
        case _Kind.cap:
          path
            ..reset()
            ..addArc(
              Rect.fromCircle(center: Offset(it.x, it.y), radius: it.r),
              math.pi,
              math.pi,
            )
            ..close();
          canvas.drawPath(path, pens.fill..color = it.color);
        case _Kind.stroke:
          if (it.n < 2) continue;
          path
            ..reset()
            ..moveTo(it.xy[0], it.xy[1]);
          for (var i = 1; i < it.n; i++) {
            path.lineTo(it.xy[2 * i], it.xy[2 * i + 1]);
          }
          if (it.closed) path.close();
          final glow = it.glow;
          if (glow != null) {
            canvas.drawPath(
              path,
              pens.line
                ..strokeWidth = it.width * 2.8
                ..color = glow,
            );
          }
          canvas.drawPath(
            path,
            pens.line
              ..strokeWidth = it.width
              ..color = it.color,
          );
      }
    }
  }
}

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..strokeJoin = StrokeJoin.round;
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Soft halo behind matched labels.
  final Paint halo = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the renderer and the
/// label text painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final _R3 renderer = _R3();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;

  /// The distance readout changes as the bus moves (whole metres, so the
  /// cache stays small); it is emptied past this many painters.
  static const int _maxLabels = 120;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text, double scale) {
    if (_labels.length > _maxLabels) _disposeLabels();
    return _labels['$scale|$text'] ??= TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: _labelSize * scale,
          fontWeight: FontWeight.w700,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() => _disposeLabels();
}

/// Paints the HTML Three.js scene of the current scenario: S1 the road with
/// the tree and the bus (outside or inside view, laser and ring), S2 the
/// playground with its moving equipment and trajectory lines; then the
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
    required this.labelLeft,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Design x of the canvas's left edge and of the tool column's left
  /// edge (labels stay between them).
  final double labelLeft;
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    cache.prepare(lang, labelSize);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    final cam = s.camera();
    final r = cache.renderer..begin(cam);
    if (s.scenario == 0) {
      _emitRoad(r);
    } else {
      _emitPark(r);
    }
    r.flush(canvas, _pens);
    if (s.scenario == 0) {
      _labelsRoad(canvas, cam);
    } else {
      _labelsPark(canvas, cam);
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _emitRoad(_R3 r) {
    final s = scene;
    final bus = _Xf.at(s.busX, 0, 0);
    r
      ..model(_roadParts, null)
      ..model(_treeParts, null)
      ..model(_busParts, bus, interior: s.inside);
    if (!s.inside) return;
    if (s.seatRef) {
      r
        ..layer = 2
        ..torus(
          bus *
              _Xf.at(_deepaSeat.x, _ringHeight, _deepaSeat.z, rx: math.pi / 2),
          _ringRadius,
          _ringTube,
          _Colors.ring,
          lit: false,
          glow: _Colors.ring.withValues(alpha: 0.35),
          maxWidth: _ringMaxWidth,
        );
    }
    if (s.treeRef) {
      r
        ..layer = 3
        ..tube(
          _V(s.busX + _deepaSeat.x, _laserLift, _deepaSeat.z),
          _laserTreePoint,
          _laserRadius,
          _Colors.laser,
        );
    }
  }

  void _labelsRoad(Canvas canvas, _Cam cam) {
    final s = scene;
    if (!s.inside) {
      if (!showLabels) return;
      _sprite(canvas, cam, _treeLabel, _t('sprite_tree'));
      _sprite(canvas, cam, _busLabel + _V(s.busX, 0, 0), _t('sprite_bus'));
      return;
    }
    final head = _V(s.busX, 0, 0) + _deepaHead;
    if (showLabels) {
      _sprite(canvas, cam, _deepaLabel + _V(s.busX, 0, 0), _t('sprite_deepa'));
    }
    final h = cam.project(head);
    if (h == null) return;
    final rr = _headRadius * cam.scaleAt(head);
    if (s.treeRef) {
      final d = _V(
        s.busX + _deepaSeat.x,
        _laserLift,
        _deepaSeat.z,
      ).distanceTo(_laserTreePoint);
      _chip(
        canvas,
        Offset(h.dx - rr - 6, h.dy - rr * 0.35),
        labFormat(_t('dist_tree'), {'d': d.round()}),
        bg: _Colors.slate900.withValues(alpha: 0.88),
        border: _Colors.laser,
        anchor: 1,
      );
    }
    if (s.seatRef) {
      _chip(
        canvas,
        Offset(h.dx + rr + 6, h.dy + rr * 0.35),
        _t('dist_seat'),
        bg: _Colors.slate900.withValues(alpha: 0.88),
        border: _Colors.ring,
        anchor: -1,
      );
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _emitPark(_R3 r) {
    final s = scene;
    final slid = _V.lerp(_slideFrom, _slideTo, s.slideProgress);
    r
      ..model(_lawnParts, null)
      ..model(_slideParts, null)
      ..model(
        _sliderChild,
        _Xf.at(_slideGroupX + slid.x, slid.y, slid.z) * _sliderTilt,
      )
      ..model(_swingFrame, null)
      ..model(_swingSeat, _swingXf(s.swingAngle))
      ..model(_carouselBase, null)
      ..model(
        _carouselPlatform,
        _Xf.at(_carouselX, _platformY, 0, ry: s.carouselAngle),
      )
      ..layer = 3;
    if (s.pathShown.contains(_Equip.slide)) {
      r.line(_slidePath, _Colors.slidePath, 3);
    }
    if (s.pathShown.contains(_Equip.swing)) {
      r.line(_swingPath, _Colors.swingPath, 3);
    }
    if (s.pathShown.contains(_Equip.carousel)) {
      r.line(_carouselPath, _Colors.carouselPath, 3);
    }
  }

  void _labelsPark(Canvas canvas, _Cam cam) {
    final s = scene;
    for (final e in _Equip.values) {
      final at = cam.project(e.label);
      if (at == null) continue;
      if (showLabels) _chip(canvas, at, _t(e.spriteKey));
      // A matched label snaps on below the name, with a glow (HTML step 4
      // observation "with confirmation glow").
      for (final entry in s.placed.entries) {
        if (entry.key.equip != e) continue;
        final age = s.time - entry.value;
        _chip(
          canvas,
          showLabels ? at.translate(0, _placedDy) : at,
          _t(entry.key.key),
          bg: entry.key.fill,
          border: _Colors.white,
          halo: entry.key.fill.withValues(
            alpha: 0.45 + 0.4 * math.max(0.0, 1 - age),
          ),
        );
      }
    }
  }

  // ------------------------------------------------------------ labels

  /// HTML `createTextSprite`: a dark badge with a yellow border, centred on
  /// the sprite's position; not drawn behind the camera.
  void _sprite(Canvas canvas, _Cam cam, _V at, String text) {
    final o = cam.project(at);
    if (o == null || cam.depth(at) < 1) return;
    _chip(canvas, o, text);
  }

  /// A label chip at [at]: centred ([anchor] 0), or with its right (1) /
  /// left (-1) edge on [at]. Kept on the canvas, left of the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    Color bg = _Colors.spriteBg,
    Color? border = _Colors.spriteBorder,
    Color? halo,
    double anchor = 0,
  }) {
    final tp = cache.label(text, 1);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    var cx = at.dx - anchor * w / 2;
    cx = math.max(math.min(cx, labelRight - w / 2 - 4), labelLeft + w / 2);
    final rect = Rect.fromCenter(
      center: Offset(cx, at.dy),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.6));
    if (halo != null) {
      canvas.drawRRect(rr.inflate(size * 0.3), _pens.halo..color = halo);
    }
    canvas.drawRRect(rr, _pens.fill..color = bg);
    if (border != null) {
      canvas.drawRRect(
        rr,
        _pens.edge
          ..strokeWidth = 1.5
          ..color = border,
      );
      _pens.edge.strokeWidth = 0.8;
    }
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
      old.labelLeft != labelLeft ||
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
