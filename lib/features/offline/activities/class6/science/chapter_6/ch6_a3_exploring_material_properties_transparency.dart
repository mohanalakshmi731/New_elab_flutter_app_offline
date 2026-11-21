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

/// Class 6 Science • Chapter 6 • Activity 3
/// Exploring Material Properties: Transparency.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A3-Exploring_Material_Properties__Transparency.html` (Three.js
/// r128 + TWEEN). The 3D scenes are redrawn by a small painter's-algorithm
/// renderer that reproduces the HTML PerspectiveCamera (position, look-at,
/// 45° field of view).
///
/// Scenario 1 (The Hide and Seek Game, 5 steps): 'Start Hide & Seek' sends
/// three friends running (800 ms, Quadratic.Out) behind a brick wall, a
/// frosted glass door and a tree seen through a clear window. The learner
/// inspects the wall, the frosted glass and the window in turn (the camera
/// glides to each, 600 ms), then sorts the three tags into the Opaque,
/// Translucent and Transparent bins (drag a tag onto a bin, or tap the tag
/// and then the bin).
///
/// Scenario 2 (The Light Box Classifier, 6 steps): a torch shines a beam
/// at a white screen. The learner taps the glass tumbler, the wooden board
/// and the butter paper on the shelf in turn; each flies into the beam
/// (600 ms, Quadratic.Out) and the screen shows a bright sharp spot, a dark
/// shadow or a dim diffused spot. After each test the item is dragged from
/// the beam into its bin (or the bin is tapped).
class Ch6A3ExploringMaterialPropertiesTransparencyPage extends StatefulWidget {
  const Ch6A3ExploringMaterialPropertiesTransparencyPage({super.key});

  @override
  State<Ch6A3ExploringMaterialPropertiesTransparencyPage> createState() =>
      _TransparencyLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises three tones (Web
/// Audio): 'pop' (sine 400 → 800 Hz) → pop.mp3, 'success' (C–E–G
/// arpeggio) → success.mp3 and 'error' (sawtooth 200 → 100 Hz) →
/// error.mp3. Its 'measure' tone (start, inspect, test) is not defined in
/// the HTML's `playSound`, so it is silent there; here it is the 'pop'.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action (shell feedback toasts).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action (HTML 'error'; error toasts).
  wrong('audio/class6/science/error.mp3'),

  /// Correct sort and conclusion popup (HTML 'success').
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// Start, inspect, test, tag picked (HTML 'pop' / 'measure').
  pop('audio/class6/science/pop.mp3');

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

/// Tailwind colours used by the HTML (UI and Three.js materials).
abstract final class _Colors {
  /// ZSL yellow (`zsl.yellow`): Enter Lab, label borders, highlights.
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color amber400 = Color(0xFFFBBF24); // bin hover border
  static const Color amber500 = Color(0xFFF59E0B); // Start button, wall tag
  static const Color amber700 = Color(0xFFB45309); // wooden board 0xb45309
  static const Color amber900 = Color(0xFF78350F); // tree 0x78350f
  static const Color yellow200 = Color(0xFFFEF08A); // beam, lens, paper
  static const Color yellow400 = Color(0xFFFACC15); // friend 1, light spot
  static const Color rose500 = Color(0xFFF43F5E); // friend 2 0xf43f5e
  static const Color red500 = Color(0xFFEF4444); // Inspect Brick Wall
  static const Color red800 = Color(0xFF991B1B); // brick wall 0x991b1b
  static const Color sky100 = Color(0xFFE0F2FE); // frosted door 0xe0f2fe
  static const Color cyan200 = Color(0xFFA5F3FC); // glass tumbler 0xa5f3fc
  static const Color cyan500 = Color(0xFF06B6D4); // Inspect Frosted Glass
  static const Color blue500 = Color(0xFF3B82F6); // friend 3, Inspect Window
  static const Color blue600 = Color(0xFF2563EB); // popup buttons
  static const Color green700 = Color(0xFF15803D); // tree crown
  static const Color green800 = Color(0xFF166534); // lawn 0x166534
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981); // sorted tags
  static const Color emerald600 = Color(0xFF059669);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color slate50 = Color(0xFFF8FAFC); // white screen 0xf8fafc
  static const Color slate100 = Color(0xFFF1F5F9); // light scene background
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155); // torch, shelf 0x334155
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A); // dark room, shadow spot
  static const Color slate950 = Color(0xFF020617); // `zsl.dark`, scene bg
  static const Color white = Color(0xFFFFFFFF);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Sprite labels: `rgba(15, 23, 42, 0.9)` with white text; toast
  /// `bg-slate-900/80`.
  static const Color labelBg = Color(0xE60F172A);
  static const Color toastBg = Color(0xCC0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The scene background is `0x020617` in the dark theme and
/// `0xf1f5f9` in the light one (HTML `setTheme`); labels and toasts stay
/// dark in both themes, as in the HTML.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate600,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // completed steps (dark:text-emerald-400)
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.toastBg,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66EAB308),
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // completed steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.toastBg,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66EAB308),
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting (px): HTML default 15 px, slider 12 … 22 px.
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// HTML's toasts, tags and button labels were English only; they are
// translated here. Changes, all in English and Hindi:
// * Step instructions name the button or the object exactly, say "Tap"
//   (touch) and say that step 5 of Scenario 1 needs all three tags.
// * The scene labels above the wall, door and window no longer give the
//   answer away: the HTML labelled them 'Opaque' / 'Translucent' /
//   'Transparent' from the start; here they show the object's name, and
//   its category is added once the object has been inspected.
// * Scenario 2 steps 2, 4 and 6 no longer name the target bin (the HTML
//   said e.g. 'Glass is transparent. Sort tumbler to Transparent bin.'):
//   the learner classifies each item from what the screen showed. The
//   wrong-bin toasts still name the right bin after a wrong drop.
// * One toast per object where the Hindi verb must agree with the noun
//   (दीवार / खिड़की feminine, काँच / गिलास / बोर्ड masculine).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Material Properties: Transparency',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1': 'Scenario 1: The Hide and Seek Game',
    'scen_2': 'Scenario 2: The Light Box Classifier',
    's1_obj':
        'To understand differences between transparent, translucent, and opaque materials.',
    's2_obj':
        'To classify materials by observing how they interact with a direct light beam.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Light interaction defines visibility.',
    's1_a1': "Tap the 'Start Hide & Seek' button and watch your friends hide.",
    's1_o1': 'Characters hide behind brick wall, tree, and frosted glass door.',
    's1_c2': 'Opaque objects block all light.',
    's1_a2':
        "Tap the 'Inspect Brick Wall' button and look for the friend hiding behind the wall.",
    's1_o2': 'Nothing visible behind solid wall. Opaque!',
    's1_c3': 'Translucent objects scatter passing light.',
    's1_a3':
        "Tap the 'Inspect Frosted Glass' button and look through the frosted glass door.",
    's1_o3': 'Blurry silhouette seen behind glass. Translucent!',
    's1_c4': 'Transparent objects transmit light without scattering.',
    's1_a4':
        "Tap the 'Inspect Clear Window' button and look through the clear window pane.",
    's1_o4': 'Crystal clear view of garden. Transparent!',
    's1_c5': 'Classify materials based on visibility.',
    's1_a5':
        'Drag each of the three tags onto its matching category bin (or tap a tag, then tap the bin).',
    's1_o5': 'Hide and seek classification complete!',
    // Scenario 2 steps.
    's2_c1': 'Transparent materials pass sharp light beam.',
    's2_a1':
        'Tap the Glass Tumbler on the shelf to place it in the light beam.',
    's2_o1': 'Bright sharp circle projected on white screen!',
    's2_c2': 'Classify each material by how much light passes through it.',
    's2_a2':
        'Sort the Glass Tumbler: drag it from the light beam into the bin that matches what you saw on the screen (or tap that bin).',
    's2_o2': 'Tumbler stored correctly.',
    's2_c3': 'Opaque objects cast dark shadows.',
    's2_a3': 'Tap the Wooden Board on the shelf to place it in the light beam.',
    's2_o3': 'Light completely obstructed, dark shadow on screen.',
    's2_c4': 'Use what the screen showed to decide the class.',
    's2_a4':
        'Sort the Wooden Board: drag it from the light beam into the bin that matches what you saw on the screen (or tap that bin).',
    's2_o4': 'Board stored correctly.',
    's2_c5': 'Translucent materials diffuse light.',
    's2_a5': 'Tap the Butter Paper on the shelf to place it in the light beam.',
    's2_o5': 'Dim diffused circle projected.',
    's2_c6': 'Each material is sorted by how light passes through it.',
    's2_a6':
        'Sort the Butter Paper: drag it from the light beam into the bin that matches what you saw on the screen (or tap that bin).',
    's2_o6': 'Light classification complete!',
    // Canvas HUD ("Current Task") lines.
    's1_hud_1': "Step 1: Tap 'Start Hide & Seek' to watch friends hide.",
    's1_hud_2':
        "Step 2: Tap 'Inspect Brick Wall' to look for the hidden character.",
    's1_hud_3': "Step 3: Tap 'Inspect Frosted Glass' to investigate the door.",
    's1_hud_4':
        "Step 4: Tap 'Inspect Clear Window' to notice baseline clarity.",
    's1_hud_5':
        'Step 5: Drag & drop the item tags into the matching category bins!',
    's2_hud_1':
        'Step 1: Tap the Glass Tumbler on the shelf to test it in the beam.',
    's2_hud_2':
        'Step 2: Sort the Glass Tumbler into the bin that matches the screen.',
    's2_hud_3': 'Step 3: Tap the Wooden Board on the shelf to test it.',
    's2_hud_4':
        'Step 4: Sort the Wooden Board into the bin that matches the screen.',
    's2_hud_5': 'Step 5: Tap the Butter Paper on the shelf to test it.',
    's2_hud_6':
        'Step 6: Sort the Butter Paper into the bin that matches the screen.',
    // Action buttons.
    'btn_start': 'Start Hide & Seek',
    'btn_wall': 'Inspect Brick Wall',
    'btn_door': 'Inspect Frosted Glass',
    'btn_window': 'Inspect Clear Window',
    // Scenario 1 tags (drag sources) and scene labels.
    'tray_title': 'Drag each tag onto its matching bin',
    'tag_wall': '🧱 Brick Wall',
    'tag_door': '🌫️ Frosted Glass',
    'tag_window': '🪟 Clear Window',
    'name_wall': 'Brick Wall',
    'name_door': 'Frosted Glass Door',
    'name_window': 'Clear Window',
    'cat_opaque': 'Opaque',
    'cat_translucent': 'Translucent',
    'cat_transparent': 'Transparent',
    // Bins: Scenario 1 (HTML `cat_*`) and Scenario 2 (HTML `bin_*`),
    // without the HTML's emoji: they matched the tags (🧱 🌫️ 🪟) or showed
    // the item that belongs in the bin (🥛 🪵 📄).
    'bin1_opaque': 'Opaque',
    'bin1_translucent': 'Translucent',
    'bin1_transparent': 'Transparent',
    'bin2_transparent': 'Transparent Bin',
    'bin2_opaque': 'Opaque Bin',
    'bin2_translucent': 'Translucent Bin',
    // Scenario 2 objects.
    'obj_tumbler': 'Glass Tumbler',
    'obj_board': 'Wooden Board',
    'obj_paper': 'Butter Paper',
    // Scenario 1 toasts.
    'toast_start':
        'Friends ran and hid! Now inspect Wall, Frosted Glass, and Clear Window.',
    'obs_wall':
        '🧱 Opaque Brick Wall! The character hiding behind the brick wall is entirely invisible! Opaque materials block 100% of light rays.',
    'obs_door':
        '🌫️ Translucent Frosted Glass! You see a blurry silhouette of the character! Translucent materials allow some light through but scatter the rays.',
    'obs_window':
        '🪟 Transparent Clear Window! You see the entire garden with crystal clarity! Transparent materials allow light rays to pass directly without scattering.',
    'toast_sel_wall': 'Brick Wall picked: now tap its matching bin.',
    'toast_sel_door': 'Frosted Glass picked: now tap its matching bin.',
    'toast_sel_window': 'Clear Window picked: now tap its matching bin.',
    'toast_ok_wall': 'Correct! Sorted into Opaque category! ({n}/3)',
    'toast_ok_door': 'Correct! Sorted into Translucent category! ({n}/3)',
    'toast_ok_window': 'Correct! Sorted into Transparent category! ({n}/3)',
    'toast_bad_wall':
        '❌ Brick Wall blocks light completely, so drag it to the Opaque bin!',
    'toast_bad_door':
        '❌ Frosted Glass lets some light through, so drag it to the Translucent bin!',
    'toast_bad_window':
        '❌ Clear Window lets all light through, so drag it to the Transparent bin!',
    'toast_already_wall': 'Already sorted Opaque!',
    'toast_already_door': 'Already sorted Translucent!',
    'toast_already_window': 'Already sorted Transparent!',
    'hint_drop_on_bin': 'Drop the tag onto one of the bins.',
    'hint_pick_tag':
        'Tap a tag first, then tap its bin (or drag the tag onto the bin).',
    // Scenario 2 toasts.
    'obs_beam':
        '🔦 Light Projection Result! Notice how the projected light beam behaves on the white screen behind the object!',
    'toast_tested_tumbler':
        'Glass Tumbler tested! Sharp bright light circle projected.',
    'toast_tested_board':
        'Wooden Board tested! Light completely blocked. Dark shadow!',
    'toast_tested_paper':
        'Butter Paper tested! Diffused dim soft circle projected.',
    'err_first_tumbler': 'Please test the Glass Tumbler first!',
    'err_next_board': 'Please test the Wooden Board next!',
    'err_next_paper': 'Please test the Butter Paper next!',
    'err_sort_first': 'Please sort the current item into a bin first!',
    'hint_place_first': 'Please place an item in the light beam first!',
    'hint_test_first': 'Please test an item in the light beam first!',
    'toast_bad_tumbler':
        '❌ Glass Tumbler lets light pass clearly! Drop into Transparent bin.',
    'toast_bad_board': '❌ Wooden Board blocks all light! Drop into Opaque bin.',
    'toast_bad_paper':
        '❌ Butter Paper scatters light! Drop into Translucent bin.',
    'toast_ok_tumbler': 'Correct! Stored into Transparent bin! ({n}/3)',
    'toast_ok_board': 'Correct! Stored into Opaque bin! ({n}/3)',
    'toast_ok_paper': 'Correct! Stored into Translucent bin! ({n}/3)',
    // Conclusion popups.
    'sc1_title': 'Scenario 1 Complete!',
    'all_title': 'Mastery Achieved!',
    'sum_s1':
        'You learned: Opaque blocks all light (Wall), Translucent blurs light (Frosted Glass), Transparent allows clear light (Window)!',
    'sum_s2':
        'You proved: Transparent creates sharp light spot, Opaque casts dark shadow, Translucent creates diffused soft spot!',
    'all_desc':
        'You mastered light interactions and classified materials into Transparent (clear light), Translucent (diffused light), and Opaque (blocked light)!',
    // Observation table and observations.
    'results': 'Observation Table',
    'col_object': 'Object',
    'col_seen': 'Seen through it',
    'col_spot': 'Spot on screen',
    'col_bin': 'Bin',
    'seen_wall': 'Nothing: the friend is hidden',
    'seen_door': 'A blurry silhouette',
    'seen_window': 'A clear view of the garden',
    'spot_tumbler': 'Bright, sharp circle',
    'spot_board': 'Dark shadow',
    'spot_paper': 'Dim, diffused circle',
    'pending': '—',
    'observations': 'Observations',
    // Screen-reader descriptions of the scene.
    'scene_garden':
        'A garden with a brick wall, a frosted glass door, a tree behind a clear window and three friends.',
    'scene_lightbox':
        'A dark room with a torch, a white screen, a shelf with a glass tumbler, a wooden board and butter paper, and three bins.',
  },
  'hi': {
    'app_title': 'सामग्री के गुणों की खोज: पारदर्शिता',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर की सामग्री',
    'scen_1': 'परिदृश्य 1: लुका-छिपी का खेल',
    'scen_2': 'परिदृश्य 2: प्रकाश बॉक्स वर्गीकरण',
    's1_obj': 'पारदर्शी, पारभासी और अपारदर्शी के बीच अंतर समझना।',
    's2_obj': 'प्रकाश किरण के साथ व्यवहार देखकर सामग्रियों को वर्गीकृत करना।',
    's1_c1': 'प्रकाश की परस्पर क्रिया दृश्यता तय करती है।',
    's1_a1': "'लुका-छिपी शुरू करें' बटन दबाएँ और दोस्तों को छिपते देखें।",
    's1_o1': 'पात्र दीवार, पेड़ और दरवाजे के पीछे छिपते हैं।',
    's1_c2': 'अपारदर्शी वस्तुएं प्रकाश रोक देती हैं।',
    's1_a2':
        "'ईंट की दीवार जांचें' बटन दबाएँ और दीवार के पीछे छिपे दोस्त को खोजें।",
    's1_o2': 'दीवार के पीछे कुछ नहीं दिखता। अपारदर्शी!',
    's1_c3': 'पारभासी वस्तुएं प्रकाश को बिखेर देती हैं।',
    's1_a3':
        "'धुंधला काँच जांचें' बटन दबाएँ और धुंधले काँच के दरवाज़े के पार देखें।",
    's1_o3': 'धुंधली परछाई दिखती है। पारभासी!',
    's1_c4': 'पारदर्शी वस्तुएं प्रकाश को सीधे जाने देती हैं।',
    's1_a4': "'साफ खिड़की जांचें' बटन दबाएँ और साफ खिड़की के पार देखें।",
    's1_o4': 'बगीचा बिल्कुल स्पष्ट दिखता है। पारदर्शी!',
    's1_c5': 'दृश्यता के आधार पर वर्गीकरण करें।',
    's1_a5':
        'तीनों टैग में से हर एक को उसकी सही श्रेणी वाले डिब्बे पर खींचें (या पहले टैग दबाएँ, फिर डिब्बा)।',
    's1_o5': 'वर्गीकरण पूरा हुआ!',
    's2_c1': 'पारदर्शी वस्तुएं तेज प्रकाश जाने देती हैं।',
    's2_a1':
        'शेल्फ पर रखे काँच के गिलास को दबाएँ ताकि वह प्रकाश किरण में आ जाए।',
    's2_o1': 'सफेद पर्दे पर चमकीला गोला बनता है!',
    's2_c2':
        'हर पदार्थ को इस आधार पर वर्गीकृत करें कि उससे कितना प्रकाश पार जाता है।',
    's2_a2':
        'काँच के गिलास को छाँटें: उसे प्रकाश किरण से खींचकर उस डिब्बे में डालें जो पर्दे पर दिखे परिणाम से मेल खाता है (या उस डिब्बे को दबाएँ)।',
    's2_o2': 'गिलास सही डिब्बे में रखा गया।',
    's2_c3': 'अपारदर्शी वस्तुएं गहरी परछाई बनाती हैं।',
    's2_a3':
        'शेल्फ पर रखे लकड़ी के बोर्ड को दबाएँ ताकि वह प्रकाश किरण में आ जाए।',
    's2_o3': 'प्रकाश रुका, पर्दे पर गहरी परछाई बनी।',
    's2_c4': 'पर्दे पर जो दिखा, उसी से श्रेणी तय करें।',
    's2_a4':
        'लकड़ी के बोर्ड को छाँटें: उसे प्रकाश किरण से खींचकर उस डिब्बे में डालें जो पर्दे पर दिखे परिणाम से मेल खाता है (या उस डिब्बे को दबाएँ)।',
    's2_o4': 'बोर्ड सही डिब्बे में रखा गया।',
    's2_c5': 'पारभासी वस्तुएं प्रकाश फैला देती हैं।',
    's2_a5': 'शेल्फ पर रखे बटर पेपर को दबाएँ ताकि वह प्रकाश किरण में आ जाए।',
    's2_o5': 'धुंधला प्रकाश पर्दे पर बना।',
    's2_c6':
        'हर पदार्थ इस आधार पर छाँटा जाता है कि प्रकाश उससे कैसे पार जाता है।',
    's2_a6':
        'बटर पेपर को छाँटें: उसे प्रकाश किरण से खींचकर उस डिब्बे में डालें जो पर्दे पर दिखे परिणाम से मेल खाता है (या उस डिब्बे को दबाएँ)।',
    's2_o6': 'परीक्षण पूर्ण!',
    's1_hud_1':
        "चरण 1: दोस्तों को छिपते देखने के लिए 'लुका-छिपी शुरू करें' दबाएँ।",
    's1_hud_2':
        "चरण 2: छिपे पात्र को खोजने के लिए 'ईंट की दीवार जांचें' दबाएँ।",
    's1_hud_3': "चरण 3: दरवाजे की जाँच के लिए 'धुंधला काँच जांचें' दबाएँ।",
    's1_hud_4': "चरण 4: स्पष्टता देखने के लिए 'साफ खिड़की जांचें' दबाएँ।",
    's1_hud_5': 'चरण 5: नीचे के टैग को उनकी सही श्रेणी वाले डिब्बों में डालें!',
    's2_hud_1': 'चरण 1: प्रकाश किरण में काँच का गिलास रखें।',
    's2_hud_2': 'चरण 2: गिलास को पर्दे के परिणाम से मेल खाते डिब्बे में डालें।',
    's2_hud_3': 'चरण 3: प्रकाश किरण में लकड़ी का बोर्ड रखें।',
    's2_hud_4': 'चरण 4: बोर्ड को पर्दे के परिणाम से मेल खाते डिब्बे में डालें।',
    's2_hud_5': 'चरण 5: प्रकाश किरण में बटर पेपर रखें।',
    's2_hud_6':
        'चरण 6: बटर पेपर को पर्दे के परिणाम से मेल खाते डिब्बे में डालें।',
    'btn_start': 'लुका-छिपी शुरू करें',
    'btn_wall': 'ईंट की दीवार जांचें',
    'btn_door': 'धुंधला काँच जांचें',
    'btn_window': 'साफ खिड़की जांचें',
    'tray_title': 'हर टैग को उसके सही डिब्बे पर खींचें',
    'tag_wall': '🧱 ईंट की दीवार',
    'tag_door': '🌫️ धुंधला काँच',
    'tag_window': '🪟 साफ खिड़की',
    'name_wall': 'ईंट की दीवार',
    'name_door': 'धुंधले काँच का दरवाज़ा',
    'name_window': 'साफ खिड़की',
    'cat_opaque': 'अपारदर्शी',
    'cat_translucent': 'पारभासी',
    'cat_transparent': 'पारदर्शी',
    'bin1_opaque': 'अपारदर्शी',
    'bin1_translucent': 'पारभासी',
    'bin1_transparent': 'पारदर्शी',
    'bin2_transparent': 'पारदर्शी डिब्बा',
    'bin2_opaque': 'अपारदर्शी डिब्बा',
    'bin2_translucent': 'पारभासी डिब्बा',
    'obj_tumbler': 'काँच का गिलास',
    'obj_board': 'लकड़ी का बोर्ड',
    'obj_paper': 'बटर पेपर',
    'toast_start':
        'दोस्त दौड़कर छिप गए! अब दीवार, धुंधला काँच और साफ खिड़की जांचें।',
    'obs_wall':
        '🧱 अपारदर्शी ईंट की दीवार! दीवार के पीछे छिपा पात्र बिल्कुल दिखाई नहीं देता! अपारदर्शी वस्तुएं प्रकाश को पूरी तरह रोक देती हैं।',
    'obs_door':
        '🌫️ पारभासी धुंधला काँच! पात्र की धुंधली परछाई दिखाई देती है! पारभासी वस्तुएं कुछ प्रकाश जाने देती हैं पर उसे बिखेर देती हैं।',
    'obs_window':
        '🪟 पारदर्शी साफ खिड़की! बगीचा बिल्कुल स्पष्ट दिखाई देता है! पारदर्शी वस्तुएं प्रकाश को बिना बिखेरे सीधे जाने देती हैं।',
    'toast_sel_wall': 'ईंट की दीवार चुनी गई: अब उसका सही डिब्बा दबाएँ।',
    'toast_sel_door': 'धुंधला काँच चुना गया: अब उसका सही डिब्बा दबाएँ।',
    'toast_sel_window': 'साफ खिड़की चुनी गई: अब उसका सही डिब्बा दबाएँ।',
    'toast_ok_wall': 'सही! ईंट की दीवार अपारदर्शी श्रेणी में रखी गई! ({n}/3)',
    'toast_ok_door': 'सही! धुंधला काँच पारभासी श्रेणी में रखा गया! ({n}/3)',
    'toast_ok_window': 'सही! साफ खिड़की पारदर्शी श्रेणी में रखी गई! ({n}/3)',
    'toast_bad_wall':
        '❌ ईंट की दीवार प्रकाश को पूरी तरह रोकती है, इसलिए इसे अपारदर्शी डिब्बे में डालें!',
    'toast_bad_door':
        '❌ धुंधला काँच कुछ प्रकाश जाने देता है, इसलिए इसे पारभासी डिब्बे में डालें!',
    'toast_bad_window':
        '❌ साफ खिड़की सारा प्रकाश जाने देती है, इसलिए इसे पारदर्शी डिब्बे में डालें!',
    'toast_already_wall': 'ईंट की दीवार पहले ही छाँटी जा चुकी है!',
    'toast_already_door': 'धुंधला काँच पहले ही छाँटा जा चुका है!',
    'toast_already_window': 'साफ खिड़की पहले ही छाँटी जा चुकी है!',
    'hint_drop_on_bin': 'टैग को किसी एक डिब्बे पर छोड़ें।',
    'hint_pick_tag':
        'पहले कोई टैग दबाएँ, फिर उसका डिब्बा दबाएँ (या टैग को डिब्बे पर खींचें)।',
    'obs_beam':
        '🔦 प्रकाश प्रक्षेपण परिणाम! देखें कि वस्तु के पीछे सफेद पर्दे पर प्रकाश किरण कैसा व्यवहार करती है!',
    'toast_tested_tumbler':
        'काँच के गिलास का परीक्षण हुआ! पर्दे पर तेज चमकीला गोला बना।',
    'toast_tested_board':
        'लकड़ी के बोर्ड का परीक्षण हुआ! प्रकाश पूरी तरह रुक गया। गहरी परछाई!',
    'toast_tested_paper':
        'बटर पेपर का परीक्षण हुआ! पर्दे पर धुंधला, फैला हुआ हल्का गोला बना।',
    'err_first_tumbler': 'कृपया पहले काँच के गिलास का परीक्षण करें!',
    'err_next_board': 'कृपया अब लकड़ी के बोर्ड का परीक्षण करें!',
    'err_next_paper': 'कृपया अब बटर पेपर का परीक्षण करें!',
    'err_sort_first': 'कृपया पहले वर्तमान वस्तु को डिब्बे में डालें!',
    'hint_place_first': 'कृपया पहले कोई वस्तु प्रकाश किरण में रखें!',
    'hint_test_first': 'कृपया पहले प्रकाश किरण में किसी वस्तु का परीक्षण करें!',
    'toast_bad_tumbler':
        '❌ काँच का गिलास प्रकाश को साफ-साफ जाने देता है! इसे पारदर्शी डिब्बे में डालें।',
    'toast_bad_board':
        '❌ लकड़ी का बोर्ड सारा प्रकाश रोक देता है! इसे अपारदर्शी डिब्बे में डालें।',
    'toast_bad_paper':
        '❌ बटर पेपर प्रकाश को बिखेर देता है! इसे पारभासी डिब्बे में डालें।',
    'toast_ok_tumbler':
        'सही! काँच का गिलास पारदर्शी डिब्बे में रखा गया! ({n}/3)',
    'toast_ok_board':
        'सही! लकड़ी का बोर्ड अपारदर्शी डिब्बे में रखा गया! ({n}/3)',
    'toast_ok_paper': 'सही! बटर पेपर पारभासी डिब्बे में रखा गया! ({n}/3)',
    'sc1_title': 'परिदृश्य 1 पूर्ण!',
    'all_title': 'महारत हासिल की!',
    'sum_s1':
        'आपने जाना: अपारदर्शी प्रकाश रोकता है (दीवार), पारभासी प्रकाश बिखेरता है (धुंधला काँच), पारदर्शी साफ प्रकाश जाने देता है (खिड़की)!',
    'sum_s2':
        'आपने सिद्ध किया: पारदर्शी चमकीला निशान बनाता है, अपारदर्शी गहरी परछाई बनाता है, पारभासी धुंधला निशान बनाता है!',
    'all_desc':
        'आपने प्रकाश की परस्पर क्रिया को समझा और सामग्रियों को पारदर्शी, पारभासी और अपारदर्शी में सफलतापूर्वक वर्गीकृत किया!',
    'results': 'अवलोकन तालिका',
    'col_object': 'वस्तु',
    'col_seen': 'इसके पार क्या दिखा',
    'col_spot': 'पर्दे पर प्रकाश',
    'col_bin': 'डिब्बा',
    'seen_wall': 'कुछ नहीं: दोस्त छिपा है',
    'seen_door': 'धुंधली परछाई',
    'seen_window': 'बगीचे का साफ दृश्य',
    'spot_tumbler': 'चमकीला, साफ गोला',
    'spot_board': 'गहरी परछाई',
    'spot_paper': 'धुंधला, फैला हुआ गोला',
    'pending': '—',
    'observations': 'अवलोकन',
    'scene_garden':
        'ईंट की दीवार, धुंधले काँच का दरवाज़ा, साफ खिड़की के पीछे पेड़ और तीन दोस्तों वाला बगीचा।',
    'scene_lightbox':
        'टॉर्च, सफेद पर्दे, शेल्फ पर रखे काँच के गिलास, लकड़ी के बोर्ड और बटर पेपर तथा तीन डिब्बों वाला अंधेरा कमरा।',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML
/// `ScenariosData[lang][n].steps`).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      List<LabStep> steps(int scenario, int count) => [
        for (var i = 1; i <= count; i++)
          LabStep(
            concept: t('s${scenario}_c$i'),
            action: t('s${scenario}_a$i'),
            observation: t('s${scenario}_o$i'),
          ),
      ];
      return [
        LabScenarioData(
          title: t('scen_1'),
          objective: t('s1_obj'),
          steps: steps(1, _s1Steps),
        ),
        LabScenarioData(
          title: t('scen_2'),
          objective: t('s2_obj'),
          steps: steps(2, _s2Steps),
        ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Steps per scenario (HTML `steps` arrays).
const int _s1Steps = 5, _s2Steps = 6;

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);
const Rect _stageRect = Rect.fromLTWH(0, 0, 1000, 560);

/// 280 / tan(22.5°): the HTML PerspectiveCamera's 45° vertical field of
/// view over the 560 px stage height.
const double _focal = 675.96;

/// Points closer to the camera plane than this (world units) are clipped.
const double _near = 0.3;

/// HTML `resetCamera()`: `camera.position.set(0, 10, 24)`,
/// `controls.target.set(0, 2, 0)`, both scenarios.
const _View _overview = _View(_V(0, 10, 24), _V(0, 2, 0));

/// HTML `inspectWall()` / `inspectDoor()` / `inspectWindow()` tween the
/// camera to (−8, 3, 6), (0, 3, 6) and (8, 3, 6). The HTML kept looking at
/// the centre (0, 2, 0), which left the wall at the edge of the view; here
/// each close-up looks at the object it inspects.
const _View _wallView = _View(_V(-8, 3, 6), _V(-8, 2, -4));
const _View _doorView = _View(_V(0, 3, 6), _V(0, 2.5, -4));
const _View _windowView = _View(_V(8, 3, 6), _V(8, 2.5, -1.5));

/// HTML tween timings (s): the friends run for 800 ms (Quadratic.Out), the
/// camera tween takes 600 ms. The close-up is held for [_shotHold] and then
/// glides back (the HTML jumped back after 1 s, 0.4 s after arriving).
const double _hideTime = 0.8;
const double _shotIn = 0.6;
const double _shotHold = 1.8;
const double _shotOut = 0.6;

/// HTML `showObsCard` callback: the camera goes back to the overview, the
/// next inspect button (or the sort tray) appears and the step moves on.
/// Here that happens when the close-up ends (the HTML: after 1 s).
const Duration _nextDelay = Duration(milliseconds: 2400);

/// HTML item tween into the beam: 600 ms, Quadratic.Out.
const double _flyTime = 0.6;
const Duration _flyDuration = Duration(milliseconds: 600);

/// HTML `setTimeout(() => window.showObservationPopup(), 1000)`.
const Duration _conclusionDelay = Duration(milliseconds: 1000);

/// Longest frame step used by the simulation (s).
const double _maxFrameStep = 0.1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// The scene is never drawn larger than the HTML camera shows it.
const double _maxZoom = 1;

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

/// Canvas cards sit this far above the bottom edge while the HUD chip is
/// shown (its height plus a gap, logical px at UI scale 1).
const double _hudReserve = 66;

/// Widest the tag tray gets (logical px at UI scale 1).
const double _trayMaxWidth = 470;

/// Touch reach (dp) around scene objects, converted to design px.
const double _touchDp = 24;

/// Pan slop for grabbing a scene object (logical px).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.6x on small stages so the
/// HTML sprite text stays readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.6;
const double _labelPadX = 7, _labelPadY = 4;

/// Room (design px) reserved above label anchors and below the bins for
/// their labels when the scene is fitted.
const double _labelHeadroom = 40;
const double _binLabelRoom = 46;

/// Bins accept a tap or drop this far (design px) outside their outline.
const double _zonePad = 8;

/// Reach (world units) of a scene item for taps and drags.
const double _itemReach = 1.2;

// ----------------------------------------------- scenario 1: the garden
// HTML buildS1().

/// Lawn: BoxGeometry(40, 0.5, 30) at y −0.25.
const _V _lawnCentre = _V(0, -0.25, 0), _lawnHalf = _V(20, 0.25, 15);

/// Brick wall: BoxGeometry(6, 4, 1.5) at (−8, 2, −4).
const _V _wallCentre = _V(-8, 2, -4), _wallHalf = _V(3, 2, 0.75);

/// Frosted glass door: BoxGeometry(4, 5, 0.5) at (0, 2.5, −4), opacity 0.6.
const _V _doorCentre = _V(0, 2.5, -4), _doorHalf = _V(2, 2.5, 0.25);
const double _doorOpacity = 0.6;

/// Tree: CylinderGeometry(1, 1.5, 6) at (8, 3, −4); the crown is drawn on
/// top so it reads as a tree (the HTML showed the trunk only).
const _V _treeBase = _V(8, 0, -4);
const double _treeTopR = 1, _treeBottomR = 1.5, _treeHeight = 6;
const _V _crownCentre = _V(8, 6.6, -4);
const double _crownR = 2.2;

/// Clear window pane: BoxGeometry(4, 4, 0.2) at (8, 2.5, −1.5), opacity
/// 0.15.
const _V _windowCentre = _V(8, 2.5, -1.5), _windowHalf = _V(2, 2, 0.1);
const double _windowOpacity = 0.15;

/// Label sprites: 2.8 above the wall, 3.2 above the door, 2.8 above the
/// window (HTML `lbl*.position`).
const _V _wallLabel = _V(-8, 4.8, -4);
const _V _doorLabel = _V(0, 5.7, -4);
const _V _windowLabel = _V(8, 5.3, -1.5);

/// Friends: SphereGeometry(1.2) at (−4 | 0 | 4, 1.2, 4); they run to
/// (−8 | 0 | 8, 1.2, −6), behind the wall, the door and the tree.
const double _friendR = 1.2;
const List<_V> _friendStart = [_V(-4, 1.2, 4), _V(0, 1.2, 4), _V(4, 1.2, 4)];
const List<_V> _friendHide = [_V(-8, 1.2, -6), _V(0, 1.2, -6), _V(8, 1.2, -6)];
const List<Color> _friendColors = [
  _Colors.yellow400, // 0xfacc15
  _Colors.rose500, // 0xf43f5e
  _Colors.blue500, // 0x3b82f6
];

/// Scenario 1 bins (the HTML's sort banner as crates on the lawn, shown at
/// step 5): Opaque, Translucent, Transparent from left to right.
const double _bin1Z = 7;
const _V _bin1Half = _V(1.6, 0.7, 1.1);

// -------------------------------------------- scenario 2: the light box
// HTML buildS2().

/// Dark room floor: BoxGeometry(30, 0.5, 20) at y −0.25.
const _V _floorCentre = _V(0, -0.25, 0), _floorHalf = _V(15, 0.25, 10);

/// Torch: CylinderGeometry(0.8, 1, 3) along x at (−10, 3, 0): its back
/// (r 1) at x −11.5, its front (r 0.8) at x −8.5; lens CircleGeometry(0.75)
/// at x −8.48.
const double _torchBackX = -11.5, _torchFrontX = -8.5;
const double _torchBackR = 1, _torchFrontR = 0.8;
const double _lensX = -8.48, _lensR = 0.75;
const double _beamY = 3;

/// Beam before the object: CylinderGeometry(1.1, 0.5, 8) from the lens
/// (r 0.5) to x −0.5 (r 1.1), opacity 0.45. Beam after it:
/// CylinderGeometry(1.6, 1.1, 10.2) from x −0.5 (r 1.1) to the screen at
/// x 9.7 (r 1.6), opacity 0.35 empty, 0.4 glass, 0.2 butter paper (wider:
/// HTML scale 1.6), hidden behind the board.
const double _beamStartR = 0.5, _beamMidX = -0.5, _beamMidR = 1.1;
const double _beamEndX = 9.7, _beamEndR = 1.6, _beamWideR = 2.4;
const double _beamBeforeOpacity = 0.45;

/// White screen: BoxGeometry(0.5, 8, 10) at (10, 4, 0).
const _V _screenCentre = _V(10, 4, 0), _screenHalf = _V(0.25, 4, 5);

/// Light spot: CircleGeometry(2) at (9.7, 3, 0); scale 1.2 for the shadow,
/// 1.6 for the diffused spot.
const double _spotR = 2;

/// Shelf: BoxGeometry(16, 0.4, 3) at (0, 7, −5).
const _V _shelfCentre = _V(0, 7, -5), _shelfHalf = _V(8, 0.2, 1.5);

/// An item in the beam (HTML tween target (−0.5, 3, 0)); labels float 1.6
/// above their item.
const _V _beamSpot = _V(-0.5, 3, 0);
const _V _labelLift = _V(0, 1.6, 0);

/// Scenario 2 bins (the HTML's bin banner as crates on the floor in front
/// of the beam): Transparent, Opaque, Translucent from left to right.
const double _bin2Z = 3.2;
const _V _bin2Half = _V(1.5, 0.6, 1);

/// The three kinds of material (HTML bin types).
enum _Kind { opaque, translucent, transparent }

/// Scenario 1 objects and their tags.
enum _Tag {
  wall(_Kind.opaque),
  door(_Kind.translucent),
  window(_Kind.transparent);

  const _Tag(this.kind);
  final _Kind kind;

  /// The step whose button inspects this object (HTML steps 2 / 3 / 4).
  int get inspectStep => index + 2;

  _View get closeUp => switch (this) {
    _Tag.wall => _wallView,
    _Tag.door => _doorView,
    _Tag.window => _windowView,
  };

  _V get labelAt => switch (this) {
    _Tag.wall => _wallLabel,
    _Tag.door => _doorLabel,
    _Tag.window => _windowLabel,
  };

  /// Swatch / tag colour (HTML tag borders: amber, cyan, blue).
  Color get color => switch (this) {
    _Tag.wall => _Colors.amber500,
    _Tag.door => _Colors.cyan500,
    _Tag.window => _Colors.blue500,
  };
}

/// Scenario 2 items: kind, the step that tests it (1 / 3 / 5) and its place
/// on the shelf (HTML `*Mesh.position.set(x, 8.2, -5)`).
enum _Item {
  tumbler(_Kind.transparent, 1, _V(-5, 8.2, -5)),
  board(_Kind.opaque, 3, _V(0, 8.2, -5)),
  paper(_Kind.translucent, 5, _V(5, 8.2, -5));

  const _Item(this.kind, this.testStep, this.shelf);
  final _Kind kind;
  final int testStep;
  final _V shelf;

  /// Swatch colour (HTML materials).
  Color get color => switch (this) {
    _Item.tumbler => _Colors.cyan200,
    _Item.board => _Colors.amber700,
    _Item.paper => _Colors.yellow200,
  };
}

/// Bin centres: Scenario 1 left to right Opaque, Translucent, Transparent
/// (HTML S1 banner); Scenario 2 Transparent, Opaque, Translucent (HTML S2
/// banner).
double _binX(int scenario, _Kind k) => scenario == 0
    ? switch (k) {
        _Kind.opaque => -6,
        _Kind.translucent => 0,
        _Kind.transparent => 6,
      }
    : switch (k) {
        _Kind.transparent => -5,
        _Kind.opaque => 0,
        _Kind.translucent => 5,
      };

/// Bin body and rim colour, the same for every bin (`bg-slate-800`,
/// `border-slate-400`). The HTML coloured the bins (Transparent blue,
/// S2 Translucent amber), which matched the blue Clear Window tag and the
/// bluish glass tumbler and so hinted at the answer.
const (Color, Color) _binColors = (_Colors.slate800, _Colors.slate400);

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => 1 - (1 - t) * (1 - t);

/// TWEEN.Easing.Quadratic.InOut.
double _quadInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;

/// Bit mask of a set of enum values (part of the picture cache key).
int _mask(Iterable<Enum> values) =>
    values.fold(0, (m, e) => m | (1 << e.index));

/// An item moving into the beam (HTML TWEEN to (−0.5, 3, 0)).
@immutable
class _Fly {
  const _Fly(this.from, this.to, this.start);

  final _V from;
  final _V to;
  final double start;
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based step; steps + 1 once the scenario is done.
  int step = 1;

  // ------------------------------------------------------------ scenario 1

  /// When the friends started running (HTML `startHideSeek`), if they have.
  double? hideStart;

  /// The object being inspected (until its next button appears).
  _Tag? inspecting;
  final Set<_Tag> inspected = {};
  final Set<_Tag> sorted = {};

  /// A tag tapped in the tray, waiting for a tap on a bin.
  _Tag? selectedTag;

  /// Camera close-up: from where it started, the close-up view and when.
  _View shotFrom = _overview;
  _View? shotClose;
  double shotStart = 0;

  // ------------------------------------------------------------ scenario 2

  /// The item in (or flying into) the beam (HTML `State.currentBeamItem`).
  _Item? beamItem;

  /// Items whose screen result has been shown, and items in their bins.
  final Set<_Item> tested = {};
  final Set<_Item> stored = {};
  final Map<_Item, _V> itemPos = {for (final i in _Item.values) i: i.shelf};
  final Map<_Item, _Fly> flights = {};

  /// The item held by the finger, where the drag started and where the
  /// finger is now (design px).
  _Item? dragging;
  Offset dragFrom = Offset.zero;
  Offset dragAt = Offset.zero;

  // ------------------------------------------------------------------ both

  /// The bin under a dragged tag or item.
  _Kind? hoverBin;

  /// Label chips drawn last time, by object (tags, items, bins): taps on a
  /// label count as taps on its object (the HTML raycast hit the sprites).
  final Map<Object, Rect> labelRects = {};

  /// Visible stage strip (design x) labels are kept inside: the canvas
  /// edge on the left, the tool column on the right.
  double labelMinX = 0;
  double labelMaxX = _design.width;

  // --------------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// The view has come to rest: framing done and no camera close-up under
  /// way (the flows read scene positions only then).
  bool get framingSettled => _framingT >= 1 && shotClose == null;

  bool get s1Done => sorted.length == _Tag.values.length;
  bool get s2Done => stored.length == _Item.values.length;
  bool get binsVisible => scenario == 1 || step >= _s1Steps;

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    hideStart = null;
    inspecting = null;
    inspected.clear();
    sorted.clear();
    selectedTag = null;
    shotFrom = _overview;
    shotClose = null;
    beamItem = null;
    tested.clear();
    stored.clear();
    for (final i in _Item.values) {
      itemPos[i] = i.shelf;
    }
    flights.clear();
    dragging = null;
    hoverBin = null;
    labelRects.clear();
  }

  /// Friend [i] (HTML char1 … char3), running from the front of the lawn
  /// to its hiding place.
  _V friend(int i) {
    final start = hideStart;
    if (start == null) return _friendStart[i];
    final k = _quadOut(((time - start) / _hideTime).clamp(0.0, 1.0));
    return _V.lerp(_friendStart[i], _friendHide[i], k);
  }

  /// The camera view now: the overview, or a close-up on its way in, held
  /// or on its way back.
  _View get view {
    final close = shotClose;
    if (scenario != 0 || close == null) return _overview;
    final k = time - shotStart;
    if (k < _shotIn) return shotFrom.lerpTo(close, _quadInOut(k / _shotIn));
    if (k < _shotIn + _shotHold) return close;
    final back = (k - _shotIn - _shotHold) / _shotOut;
    if (back < 1) return close.lerpTo(_overview, _quadInOut(back));
    return _overview;
  }

  void startShot(_View close) {
    shotFrom = view;
    shotClose = close;
    shotStart = time;
  }

  _Cam camera() => _Cam(view, framing);

  /// Sends [item] to [to] (HTML 600 ms Quadratic.Out tween).
  void flyTo(_Item item, _V to) {
    flights[item] = _Fly(itemPos[item]!, to, time);
  }

  /// What the screen shows: the kind of the item that sits in the beam, or
  /// null for the empty beam (also while the item is still flying or is
  /// being dragged away).
  _Kind? get beamKind {
    final item = beamItem;
    if (item == null || flights.containsKey(item) || dragging == item) {
      return null;
    }
    return item.kind;
  }

  /// HTML `animate()`: TWEEN.update() for the items and the camera, then
  /// the framing.
  void advance(double dt) {
    flights.removeWhere((item, f) {
      final k = ((time - f.start) / _flyTime).clamp(0.0, 1.0);
      itemPos[item] = _V.lerp(f.from, f.to, _quadOut(k));
      return k >= 1;
    });
    if (shotClose != null &&
        time - shotStart >= _shotIn + _shotHold + _shotOut) {
      shotClose = null;
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

  /// Everything the recorded picture shows (see [_PictureCache]); the
  /// dragged item and the pulsing bin rings are drawn live on top.
  Object get pictureKey => (
    scenario,
    step,
    view,
    framing,
    hideStart == null ? 0.0 : ((time - hideStart!) / _hideTime).clamp(0, 1),
    _mask(inspected),
    _mask(sorted),
    beamItem,
    beamKind,
    _mask(stored),
    (itemPos[_Item.tumbler], itemPos[_Item.board], itemPos[_Item.paper]),
    dragging,
    hoverBin,
    (labelMinX, labelMaxX),
  );

  // ------------------------------------------------------------ hit tests

  _V binCentre(_Kind k) => scenario == 0
      ? _V(_binX(0, k), _bin1Half.y, _bin1Z)
      : _V(_binX(1, k), _bin2Half.y, _bin2Z);

  _V get binHalf => scenario == 0 ? _bin1Half : _bin2Half;

  /// Screen box of bin [k] in the current view.
  Rect binRect(_Kind k, [_Cam? cam]) {
    final c = cam ?? camera();
    final centre = binCentre(k);
    final h = binHalf;
    var left = double.infinity, top = double.infinity;
    var right = -double.infinity, bottom = -double.infinity;
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final o = c.project(centre + _V(sx * h.x, sy * h.y, sz * h.z));
          left = math.min(left, o.dx);
          right = math.max(right, o.dx);
          top = math.min(top, o.dy);
          bottom = math.max(bottom, o.dy);
        }
      }
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// The bin under [p] (design px), counting its label, if bins are shown.
  _Kind? binAt(Offset p) {
    if (!binsVisible) return null;
    final cam = camera();
    _Kind? best;
    var bestD = double.infinity;
    for (final k in _Kind.values) {
      final zone = binRect(k, cam).inflate(_zonePad);
      final label = labelRects[k];
      if (!zone.contains(p) && !(label?.inflate(4).contains(p) ?? false)) {
        continue;
      }
      final d = (zone.center - p).distance;
      if (d < bestD) {
        bestD = d;
        best = k;
      }
    }
    return best;
  }

  /// The Scenario 2 item under [p] (design px), counting its label, within
  /// [touch] design px of its centre.
  _Item? itemAt(Offset p, double touch) {
    if (scenario != 1) return null;
    final cam = camera();
    _Item? best;
    var bestD = double.infinity;
    for (final it in _Item.values) {
      if (stored.contains(it)) continue;
      final w = itemPos[it]!;
      final reach = math.max(touch, _itemReach * cam.scaleAt(w));
      var d = (p - cam.project(w)).distance;
      if (labelRects[it]?.inflate(4).contains(p) ?? false) {
        d = math.min(d, reach / 2);
      }
      if (d <= reach && d < bestD) {
        bestD = d;
        best = it;
      }
    }
    return best;
  }

  /// Design point of a named place in the scene, in the current view (used
  /// by the instruction-flow tests): an item name, `bin_<kind>`, 'lawn'
  /// (empty lawn between the hiding places and the bins) or 'beam'.
  Offset anchor(String id) {
    final cam = camera();
    for (final it in _Item.values) {
      if (id == it.name) return cam.project(itemPos[it]!);
    }
    for (final k in _Kind.values) {
      if (id == 'bin_${k.name}') return binRect(k, cam).center;
    }
    return switch (id) {
      'lawn' => cam.project(const _V(0, 0, 1)),
      'beam' => cam.project(_beamSpot),
      _ => _designCenter,
    };
  }

  /// What the framing keeps in view (base projection, design px).
  Rect focusBounds() {
    final cam = _Cam(_overview, _Framing.base);
    final List<_V> points;
    var below = 0.0;
    if (scenario == 0) {
      points = step >= _s1Steps ? _gardenSortPoints : _gardenPoints;
      if (step >= _s1Steps) below = _binLabelRoom;
    } else {
      points = _lightBoxPoints;
      below = _binLabelRoom;
    }
    var left = double.infinity, top = double.infinity;
    var right = -double.infinity, bottom = -double.infinity;
    for (final w in points) {
      final o = cam.project(w);
      left = math.min(left, o.dx);
      right = math.max(right, o.dx);
      top = math.min(top, o.dy);
      bottom = math.max(bottom, o.dy);
    }
    return Rect.fromLTRB(left, top - _labelHeadroom, right, bottom + below);
  }
}

/// Points the Scenario 1 framing keeps in view: the wall, door, tree,
/// window, their labels and the friends at the start.
const List<_V> _gardenPoints = [
  _V(-11, 4, -3.25),
  _V(-11, 0, -3.25),
  _V(-5, 0, -3.25),
  _V(0, 5, -3.75),
  _V(8, 8.8, -4),
  _V(5.8, 6.6, -4),
  _V(10.2, 6.6, -4),
  _V(6, 0.5, -1.4),
  _V(10, 0.5, -1.4),
  _V(10, 4.5, -1.4),
  _wallLabel,
  _doorLabel,
  _windowLabel,
  _V(-5.2, 0, 4),
  _V(5.2, 0, 4),
  _V(0, 0, 5.2),
];

/// Scenario 1 at step 5: also the bins on the lawn.
const List<_V> _gardenSortPoints = [
  ..._gardenPoints,
  _V(-7.6, 0, 8.1),
  _V(7.6, 0, 8.1),
  _V(-7.6, 1.4, 5.9),
  _V(7.6, 1.4, 5.9),
];

/// Points the Scenario 2 framing keeps in view: the torch's front and
/// lens, the shelf, the items and their labels, the beam, the light spot
/// and the middle of the screen, and the bins.
const List<_V> _lightBoxPoints = [
  _V(-9.6, 4, 0),
  _V(-9.6, 2, 0),
  _V(-8, 7.2, -6.5),
  _V(8, 7.2, -6.5),
  _V(-8, 6.8, -3.5),
  _V(8, 6.8, -3.5),
  _V(-5, 9.8, -5),
  _V(5, 9.8, -5),
  _V(9.7, 3, 2.2),
  _V(9.7, 3, -2.2),
  _V(9.75, 8, 2.5),
  _V(9.75, 0, 2.5),
  _V(-6.5, 0, 4.2),
  _V(6.5, 0, 4.2),
  _V(-6.5, 1.2, 2.2),
  _V(6.5, 1.2, 2.2),
];

/// Best framing for [bounds] (base projection) inside [free], clear of the
/// [hard] obstacles (all in design coordinates).
_Framing _fitFraming(Rect bounds, Rect free, List<Rect> hard) {
  if (free.width <= 1 || free.height <= 1 || bounds.isEmpty) {
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
  Rect? best;
  var bestZoom = 0.0;
  for (final r in rects) {
    final z = math.min(
      _maxZoom,
      math.min(r.width / bounds.width, r.height / bounds.height),
    );
    if (best == null ||
        z > bestZoom + 1e-6 ||
        ((z - bestZoom).abs() <= 1e-6 &&
            r.width * r.height > best.width * best.height)) {
      best = r;
      bestZoom = z;
    }
  }
  if (best == null || bestZoom <= 0) return _Framing.base;
  return _Framing(
    best.center - (bounds.center - _designCenter) * bestZoom,
    bestZoom,
  );
}

/// Grabs a scene object only when the touch starts on one, so drags
/// elsewhere still pan / zoom the canvas when the camera is unlocked.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _TransparencyLabState
    extends State<Ch6A3ExploringMaterialPropertiesTransparencyPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _TextCache _texts = _TextCache();
  final _PictureCache _pictures = _PictureCache();
  late final Ticker _ticker;

  /// The canvas area (framing), the design box (drops), the tag tray and
  /// the canvas action button (framing obstacles).
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch6-a3-canvas');
  final GlobalKey _designKey = GlobalKey(debugLabel: 'ch6-a3-design');
  final GlobalKey _trayKey = GlobalKey(debugLabel: 'ch6-a3-tray');
  final GlobalKey _actionKey = GlobalKey(debugLabel: 'ch6-a3-action');

  /// Touch reach and label size for the current stage scale (design px).
  double _touch = _touchDp;
  double _labelScale = 1;

  /// UI scale of the last build (popup table).
  double _uiScale = 1;

  bool _framingQueued = false;
  bool _snapFraming = true;

  /// Last feedback toast (key and values) and the language of the last
  /// build, so a toast still on screen after a language switch is shown
  /// again translated.
  String? _toastKey;
  Map<String, Object> _toastArgs = const {};
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.load(0);
    _ticker = createTicker(_onTick)..start();
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
    _pictures.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update(). Only the canvas repaints.
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

  /// Fits the current scene into the part of the canvas no card covers:
  /// the tool column, the HUD (sidebar open), the floating mission card
  /// (sidebar collapsed), the canvas action button and the tag tray.
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
    for (final key in [_trayKey, _actionKey]) {
      final r = measured(key);
      if (r != null) hard.add(r);
    }
    final s = _scene;
    s.labelMinX = math.max(0.0, (4 - stage.dx) / fit);
    s.labelMaxX = math.min(
      _design.width,
      (size.width - insets.right - stage.dx) / fit,
    );
    final target = _fitFraming(
      s.focusBounds(),
      toDesign(free).intersect(_stageRect),
      [for (final r in hard) toDesign(r.inflate(_cardGap))],
    );
    s.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
  }

  // ---------------------------------------------------------------- toasts

  /// HTML `showToast(msg)` with [key] (and [args]) from [_i18n]. Error
  /// toasts play the wrong tone (HTML 'error'); the others are silent here
  /// because the callers play their own tone, as in the HTML.
  void _toast(
    String key, {
    bool error = false,
    Map<String, Object> args = const {},
  }) {
    _toastKey = key;
    _toastArgs = args;
    _lab.showToast(labFormat(_t(key), args), isError: error, sound: error);
  }

  /// Re-shows the visible toast in the new language after a switch from
  /// [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null) return;
    if (shown.text != labFormat(labTr(_i18n, previous, key), _toastArgs)) {
      return;
    }
    final translated = labFormat(_t(key), _toastArgs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(sc)` / `resetApp()`: cancels pending callbacks and
  /// starts scenario [index] at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
    _scheduleFraming(snap: true);
  }

  /// HTML `startHideSeek()`: the friends run and hide; step 2.
  void _startHideSeek() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 1) return;
    _Sound.pop.play();
    setState(() {
      s.hideStart = s.time;
      s.step = 2;
    });
    _toast('toast_start');
  }

  /// HTML `inspectWall()` / `inspectDoor()` / `inspectWindow()`: the camera
  /// glides to the object and the observation is shown; when the close-up
  /// ends the camera glides back, the next button appears and the step
  /// moves on.
  void _inspect(_Tag tag) {
    final s = _scene;
    if (s.scenario != 0 || s.inspecting != null || s.step != tag.inspectStep) {
      return;
    }
    _Sound.pop.play();
    setState(() {
      s.inspecting = tag;
      s.startShot(tag.closeUp);
    });
    _toast('obs_${tag.name}');
    _lab.after(_nextDelay, () {
      if (!mounted || s.inspecting != tag) return;
      setState(() {
        s.inspected.add(tag);
        s.inspecting = null;
        s.step = tag.inspectStep + 1;
      });
    });
  }

  bool _canSortTag(_Tag tag) {
    final s = _scene;
    return _lab.isLabActive &&
        _lab.popup == null &&
        s.scenario == 0 &&
        s.step == _s1Steps &&
        !s.sorted.contains(tag);
  }

  /// A tap on a tag picks it for a tap on a bin (or drops the pick).
  void _onTagTap(_Tag tag) {
    final s = _scene;
    if (s.scenario != 0 || s.step != _s1Steps) return;
    if (s.sorted.contains(tag)) {
      _toast('toast_already_${tag.name}');
      return;
    }
    _Sound.pop.play();
    final pick = s.selectedTag != tag;
    setState(() => s.selectedTag = pick ? tag : null);
    if (pick) _toast('toast_sel_${tag.name}');
  }

  /// A tag dropped on the stage (HTML `onDropBin`): sorted into the bin
  /// under the finger; dropped anywhere else it is refused (the HTML sorted
  /// it into its own category).
  void _onTagDrop(_Tag tag, Offset global) {
    final s = _scene;
    s.hoverBin = null;
    if (!_canSortTag(tag)) return;
    final local = labGlobalToLocal(_designKey, global);
    final bin = local == null ? null : s.binAt(local);
    if (bin == null) {
      _toast('hint_drop_on_bin');
      return;
    }
    _sortTag(tag, bin);
  }

  void _onTagHover(Offset global) {
    final local = labGlobalToLocal(_designKey, global);
    _scene.hoverBin = local == null ? null : _scene.binAt(local);
  }

  /// HTML `onDropBin` → `sortS1(type)`.
  void _sortTag(_Tag tag, _Kind bin) {
    final s = _scene;
    if (s.sorted.contains(tag)) {
      _toast('toast_already_${tag.name}');
      return;
    }
    if (tag.kind != bin) {
      _toast('toast_bad_${tag.name}', error: true);
      return;
    }
    _Sound.success.play();
    setState(() {
      s.sorted.add(tag);
      s.selectedTag = null;
    });
    _toast('toast_ok_${tag.name}', args: {'n': s.sorted.length});
    if (s.s1Done) _finish();
  }

  /// HTML `testLightBeam(item)`: the steps are kept in order; the item
  /// flies into the beam and the screen shows its result.
  void _testItem(_Item item) {
    final s = _scene;
    if (s.scenario != 1 || s.stored.contains(item) || s.beamItem == item) {
      return;
    }
    final step = s.step;
    final String? error;
    if (step.isEven) {
      error = 'err_sort_first';
    } else if (item.testStep != step) {
      error = switch (step) {
        1 => 'err_first_tumbler',
        3 => 'err_next_board',
        _ => 'err_next_paper',
      };
    } else {
      error = null;
    }
    if (error != null) {
      _toast(error, error: true);
      return;
    }
    _Sound.pop.play();
    setState(() {
      s.beamItem = item;
      s.flyTo(item, _beamSpot);
      s.step = step + 1;
    });
    // The HTML showed the result toast and replaced it in the same tick by
    // the "Light Projection Result" prompt; here the prompt comes first and
    // the result once the item sits in the beam.
    _toast('obs_beam');
    _lab.after(_flyDuration, () {
      if (!mounted || s.beamItem != item) return;
      setState(() => s.tested.add(item));
      _toast('toast_tested_${item.name}');
    });
  }

  /// HTML `onDropBin` in Scenario 2: only the item in the beam can be
  /// sorted (the HTML sorted the item in the beam whatever was dragged).
  void _dropItemOnBin(_Item item, _Kind bin) {
    final s = _scene;
    if (item != s.beamItem) {
      if (s.beamItem == null) {
        _toast('hint_test_first');
      } else {
        _toast('err_sort_first', error: true);
      }
      return;
    }
    _sortItem(bin);
  }

  /// HTML `onClickBin` in Scenario 2: sorts the item in the beam.
  void _onBinTapS2(_Kind bin) {
    if (_scene.beamItem == null) {
      _toast('hint_place_first');
      return;
    }
    _sortItem(bin);
  }

  /// HTML `sortS2(binType)`.
  void _sortItem(_Kind bin) {
    final s = _scene;
    final item = s.beamItem;
    if (item == null) return;
    if (item.kind != bin) {
      _toast('toast_bad_${item.name}', error: true);
      return;
    }
    _Sound.success.play();
    setState(() {
      s.stored.add(item);
      s.tested.add(item);
      s.flights.remove(item);
      s.beamItem = null;
      s.step = item.testStep + 2;
    });
    _toast('toast_ok_${item.name}', args: {'n': s.stored.length});
    if (s.s2Done) _finish();
  }

  /// The scenario's last action: every step done, the conclusion a second
  /// later (HTML `showObservationPopup`).
  void _finish() {
    final s = _scene;
    final sc = s.scenario;
    setState(() => s.step = (sc == 0 ? _s1Steps : _s2Steps) + 1);
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: _conclusionDelay,
      title: () => _t(sc == 0 ? 'sc1_title' : 'all_title'),
      heading: () => _scenarioData(_lab.lang)[sc].title,
      // The HTML's last popup showed only the mastery text; the Scenario 2
      // summary it defined is shown too.
      body: () =>
          sc == 0 ? _t('sum_s1') : '${_t('sum_s2')}\n\n${_t('all_desc')}',
      extra: () =>
          _results(_lab.palette, _uiScale * _lab.fontScale.clamp(0.9, 1.4), sc),
    );
  }

  // -------------------------------------------------------------- gestures

  void _onStageTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || _lab.popup != null) return;
    final p = d.localPosition;
    if (s.scenario == 0) {
      if (s.step != _s1Steps) return;
      final bin = s.binAt(p);
      if (bin == null) return;
      final tag = s.selectedTag;
      if (tag == null) {
        _toast('hint_pick_tag');
      } else {
        _sortTag(tag, bin);
      }
      return;
    }
    final item = s.itemAt(p, _touch);
    if (item != null) {
      _testItem(item);
      return;
    }
    final bin = s.binAt(p);
    if (bin != null) _onBinTapS2(bin);
  }

  bool _canGrab(PointerDownEvent e) {
    final s = _scene;
    return _lab.isLabActive &&
        _lab.popup == null &&
        s.scenario == 1 &&
        s.dragging == null &&
        s.itemAt(e.localPosition, _touch) != null;
  }

  void _onDragStart(DragStartDetails d) {
    final s = _scene;
    final item = s.itemAt(d.localPosition, _touch);
    if (item == null) return;
    s
      ..dragging = item
      ..dragFrom = d.localPosition
      ..dragAt = d.localPosition
      ..hoverBin = null;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (s.dragging == null) return;
    s
      ..dragAt = d.localPosition
      ..hoverBin = s.binAt(d.localPosition);
  }

  /// Released over a bin: sorted (HTML `onDropBin`). Released anywhere
  /// else: a shelf item is tested, like a tap (HTML `testLightBeam`); the
  /// item in the beam goes back.
  void _onDragEnd(DragEndDetails d) {
    final s = _scene;
    final item = s.dragging;
    if (item == null) return;
    final bin = s.binAt(s.dragAt);
    s
      ..dragging = null
      ..hoverBin = null;
    if (bin != null) {
      _dropItemOnBin(item, bin);
    } else if (item != s.beamItem) {
      _testItem(item);
    }
    setState(() {});
  }

  void _onDragCancel() {
    _scene
      ..dragging = null
      ..hoverBin = null;
  }

  // ------------------------------------------------------------------- UI

  /// The canvas HUD line (HTML `hud[step]`).
  String get _hudKey {
    final s = _scene;
    final steps = s.scenario == 0 ? _s1Steps : _s2Steps;
    return 's${s.scenario + 1}_hud_${s.step.clamp(1, steps)}';
  }

  /// HTML `#s1-action-buttons`: the one button the current step needs
  /// (Scenario 2 is played in the scene). While the camera looks at an
  /// object its button stays, greyed, until the next one replaces it.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario != 0) return const [];
    final busy = s.inspecting != null;
    LabAction inspect(_Tag tag, Color fill, Color text) => LabAction(
      label: _t('btn_${tag.name}'),
      icon: Icons.search,
      color: fill,
      foreground: text,
      highlight: !busy,
      enabled: !busy,
      silent: true,
      onTap: () => _inspect(tag),
    );
    return switch (s.step) {
      1 => [
        LabAction(
          label: _t('btn_start'),
          icon: Icons.play_arrow_rounded,
          color: _Colors.amber500,
          foreground: _Colors.slate950,
          highlight: true,
          silent: true,
          onTap: _startHideSeek,
        ),
      ],
      2 => [inspect(_Tag.wall, _Colors.red500, _Colors.white)],
      3 => [inspect(_Tag.door, _Colors.cyan500, _Colors.slate950)],
      4 => [inspect(_Tag.window, _Colors.blue500, _Colors.white)],
      _ => const [],
    };
  }

  /// The observation table of scenario [sc]: what was seen and where each
  /// object was sorted, filled in as the learner goes.
  Widget _results(LabPalette p, double scale, int sc) {
    final s = _scene;
    final pending = _t('pending');
    return _ResultsTable(
      palette: p,
      scale: scale,
      headers: [
        _t('col_object'),
        _t(sc == 0 ? 'col_seen' : 'col_spot'),
        _t('col_bin'),
      ],
      rows: sc == 0
          ? [
              for (final tag in _Tag.values)
                _ResultRow(
                  name: _t('name_${tag.name}'),
                  swatch: tag.color,
                  seen: s.inspected.contains(tag)
                      ? _t('seen_${tag.name}')
                      : pending,
                  bin: s.sorted.contains(tag)
                      ? _t('cat_${tag.kind.name}')
                      : pending,
                  done: s.sorted.contains(tag),
                ),
            ]
          : [
              for (final item in _Item.values)
                _ResultRow(
                  name: _t('obj_${item.name}'),
                  swatch: item.color,
                  seen: s.tested.contains(item)
                      ? _t('spot_${item.name}')
                      : pending,
                  bin: s.stored.contains(item)
                      ? _t('cat_${item.kind.name}')
                      : pending,
                  done: s.stored.contains(item),
                ),
            ],
    );
  }

  /// Sidebar extra: the observation table, then the observation of every
  /// step done so far (the HTML accordion's "Observation" lines).
  Widget _sidebarPanel(LabPalette p, double s, LabScenarioData data) {
    final f = s * _lab.fontScale;
    final done = math.min(_scene.step - 1, data.steps.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _results(p, f, _scene.scenario),
        if (done > 0) ...[
          SizedBox(height: 12 * s),
          LabSectionLabel(
            _t('observations'),
            size: 10.5 * s,
            icon: Icons.visibility,
          ),
          SizedBox(height: 6 * s),
          for (var i = 1; i <= done; i++)
            _ObservationLine(
              number: i,
              text: data.steps[i - 1].observation,
              palette: p,
              scale: f,
            ),
        ],
      ],
    );
  }

  /// HTML `#s1-sort-area`: the three tags, dragged onto the bins in the
  /// scene (or tapped, then the bin tapped).
  Widget _tray(LabPalette p, double s) {
    final title = _t('tray_title');
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(box.maxWidth, _trayMaxWidth * s);
        final gap = 6 * s;
        final chipW = (width - 20 * s - 2 * gap) / 3;
        return SizedBox(
          key: _trayKey,
          width: width,
          child: LabGlassCard(
            palette: p,
            padding: EdgeInsets.all(10 * s),
            radius: 16,
            borderColor: _Colors.amber500.withValues(alpha: 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pan_tool_alt,
                      size: 14 * s,
                      color: p.ink(_Colors.amber500),
                    ),
                    SizedBox(width: 5 * s),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.ink(_Colors.amber500),
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: labLetterSpacing(title, 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7 * s),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final tag in _Tag.values) ...[
                        if (tag.index > 0) SizedBox(width: gap),
                        Expanded(child: _tagItem(tag, p, s, chipW)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tagItem(_Tag tag, LabPalette p, double s, double width) {
    final scene = _scene;
    final label = _t('tag_${tag.name}');
    final state = scene.sorted.contains(tag)
        ? _TagState.sorted
        : (scene.selectedTag == tag ? _TagState.selected : _TagState.idle);
    Widget chip(_TagState st, {bool lifted = false}) => _TagChip(
      tag: tag,
      label: label,
      state: st,
      palette: p,
      scale: s,
      lifted: lifted,
    );
    return Draggable<_Tag>(
      data: tag,
      maxSimultaneousDrags: _canSortTag(tag) ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => setState(() => scene.selectedTag = null),
      onDragEnd: (_) => scene.hoverBin = null,
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: width,
            child: chip(_TagState.selected, lifted: true),
          ),
        ),
      ),
      childWhenDragging: chip(_TagState.ghost),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          key: ValueKey('ch6a3-tag-${tag.name}'),
          borderRadius: BorderRadius.circular(12 * s),
          onTap: () => _onTagTap(tag),
          child: chip(state),
        ),
      ),
    );
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
        final s = context.labScale;
        _uiScale = s;
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final sc = _scene;
        final showTray =
            _lab.isLabActive && sc.scenario == 0 && sc.step == _s1Steps;
        return LabShell(
          controller: _lab,
          icon: Icons.visibility,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          actions: actions,
          onReset: () => _loadScenario(0),
          showHud: sc.step <= data.steps.length,
          hud: _t(_hudKey),
          sidebarExtraTitle: _t('results'),
          sidebarExtra: _sidebarPanel(p, s, data),
          overlays: [
            // Measures the canvas area for the framing.
            Positioned.fill(
              child: IgnorePointer(child: SizedBox.expand(key: _canvasKey)),
            ),
            // HTML `#controls-banner` buttons on the canvas, above the HUD.
            // While the sidebar is collapsed the mission card carries them.
            if (actions.isNotEmpty &&
                _lab.isLabActive &&
                _lab.isSidebarOpen &&
                _lab.popup == null)
              Positioned(
                key: const ValueKey('ch6a3-action'),
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + _hudReserve * s,
                child: Center(
                  child: FittedBox(
                    key: _actionKey,
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(
                      action: actions.first,
                      scale: s,
                      expand: false,
                    ),
                  ),
                ),
              ),
            // HTML `#s1-sort-area`: the tags, above the HUD.
            if (showTray)
              Positioned(
                key: const ValueKey('ch6a3-tray'),
                left: inset.left,
                right: inset.right,
                bottom: _lab.isSidebarOpen
                    ? inset.bottom + _hudReserve * s
                    : inset.bottom,
                child: Center(child: _tray(p, s)),
              ),
          ],
          stage: _stage(p),
        );
      },
    );
  }

  Widget _stage(LabPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / fit;
          _labelScale = (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
        }
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: DragTarget<_Tag>(
            onWillAcceptWithDetails: (d) => _canSortTag(d.data),
            onMove: (d) => _onTagHover(d.offset),
            onLeave: (_) => _scene.hoverBin = null,
            onAcceptWithDetails: (d) => _onTagDrop(d.data, d.offset),
            builder: (context, candidates, rejected) => RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              // Drags and taps on the scene are not screen-reader actions;
              // the scene is announced by its label instead.
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
                        ..onStart = _onDragStart
                        ..onUpdate = _onDragUpdate
                        ..onEnd = _onDragEnd
                        ..onCancel = _onDragCancel,
                    ),
                TapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                      () => TapGestureRecognizer(debugOwner: this),
                      (r) => r.onTapUp = _onStageTap,
                    ),
              },
              child: Semantics(
                image: true,
                label: _t(
                  _scene.scenario == 0 ? 'scene_garden' : 'scene_lightbox',
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: _designKey,
                    size: _design,
                    painter: _ScenePainter(
                      scene: _scene,
                      texts: _texts,
                      pictures: _pictures,
                      repaint: _frame,
                      palette: p,
                      showLabels: _lab.showLabels,
                      lang: _lab.lang,
                      labelScale: _labelScale,
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
}

// ------------------------------------------------------------- tag chips

/// How a tag in the tray looks.
enum _TagState { idle, selected, sorted, ghost }

/// One tag of the tray (HTML `.draggable-item`): its object's colour while
/// waiting, highlighted when picked, emerald with a tick once sorted. Built
/// without the shell's style scope so it can also be the drag feedback.
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.label,
    required this.state,
    required this.palette,
    required this.scale,
    this.lifted = false,
  });

  final _Tag tag;
  final String label;
  final _TagState state;
  final LabPalette palette;
  final double scale;

  /// Shown under the finger while dragged.
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final sorted = state == _TagState.sorted;
    final base = sorted ? _Colors.emerald500 : tag.color;
    final ink = p.ink(sorted ? _Colors.emerald400 : base);
    final border = switch (state) {
      _TagState.selected => p.isDark ? _Colors.white : _Colors.slate900,
      _ => base,
    };
    final dim = switch (state) {
      _TagState.sorted => 0.6,
      _TagState.ghost => 0.35,
      _ => 1.0,
    };
    return Opacity(
      opacity: dim,
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            base.withValues(alpha: sorted ? 0.3 : 0.2),
            p.isDark ? _Colors.slate900 : _Colors.white,
          ),
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(
            color: border,
            width: state == _TagState.selected ? 2.5 : 1.2,
          ),
          boxShadow: [
            if (lifted || state == _TagState.selected)
              BoxShadow(
                color: base.withValues(alpha: 0.55),
                blurRadius: 12 * s,
              ),
          ],
        ),
        child: Text(
          sorted ? '✅ $label' : label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ink,
            fontSize: 11 * s,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- sidebar tables

/// One object of the observation table.
@immutable
class _ResultRow {
  const _ResultRow({
    required this.name,
    required this.swatch,
    required this.seen,
    required this.bin,
    required this.done,
  });

  final String name;
  final Color swatch;
  final String seen;
  final String bin;
  final bool done;
}

/// Object, what was observed and its bin (sidebar and conclusion popup).
class _ResultsTable extends StatelessWidget {
  const _ResultsTable({
    required this.palette,
    required this.scale,
    required this.headers,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final List<String> headers;
  final List<_ResultRow> rows;

  /// Column widths (object, observation, bin).
  static const List<int> _flex = [4, 4, 3];

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    TextStyle style(Color color, FontWeight weight) => TextStyle(
      color: color,
      fontSize: 11 * f,
      fontWeight: weight,
      height: 1.3,
    );

    Widget line(List<Widget> cells, {Color? fill, bool last = false}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 7 * f, vertical: 6 * f),
        decoration: BoxDecoration(
          color: fill,
          border: last ? null : Border(bottom: BorderSide(color: p.cardBorder)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) SizedBox(width: 6 * f),
              Expanded(flex: _flex[i], child: cells[i]),
            ],
          ],
        ),
      );
    }

    Widget name(_ResultRow r) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9 * f,
          height: 9 * f,
          margin: EdgeInsets.only(top: 3 * f, right: 5 * f),
          decoration: BoxDecoration(
            color: r.swatch,
            shape: BoxShape.circle,
            border: Border.all(color: p.cardBorder),
          ),
        ),
        Flexible(child: Text(r.name, style: style(p.text, FontWeight.w700))),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line([
            for (final h in headers)
              Text(h, style: style(p.textMuted, FontWeight.w800)),
          ], fill: p.bg.withValues(alpha: 0.6)),
          for (var i = 0; i < rows.length; i++)
            line([
              name(rows[i]),
              Text(rows[i].seen, style: style(p.textStrong, FontWeight.w600)),
              Text(
                rows[i].bin,
                style: style(
                  rows[i].done ? p.info : p.textMuted,
                  FontWeight.w800,
                ),
              ),
            ], last: i == rows.length - 1),
        ],
      ),
    );
  }
}

/// One observed result in the sidebar (HTML accordion "Observation").
class _ObservationLine extends StatelessWidget {
  const _ObservationLine({
    required this.number,
    required this.text,
    required this.palette,
    required this.scale,
  });

  final int number;
  final String text;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * f),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18 * f,
            height: 18 * f,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.info.withValues(alpha: 0.18),
              border: Border.all(color: p.info.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: p.info,
                fontSize: 9.5 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 7 * f),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

// ------------------------------------------------------------------ 3D math

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

  /// Component-wise product.
  _V mul(_V o) => _V(x * o.x, y * o.y, z * o.z);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      other is _V && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// A camera position and its OrbitControls target.
@immutable
class _View {
  const _View(this.eye, this.target);

  final _V eye;
  final _V target;

  _View lerpTo(_View o, double t) =>
      _View(_V.lerp(eye, o.eye, t), _V.lerp(target, o.target, t));

  @override
  bool operator ==(Object other) =>
      other is _View && other.eye == eye && other.target == target;

  @override
  int get hashCode => Object.hash(eye, target);
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

  _Framing lerpTo(_Framing o, double t) =>
      _Framing(Offset.lerp(center, o.center, t)!, zoom + (o.zoom - zoom) * t);

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (zoom - o.zoom).abs() < 0.002;

  @override
  bool operator ==(Object other) =>
      other is _Framing && other.center == center && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(center, zoom);
}

const _V _up = _V(0, 1, 0);

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage, in a [_Framing].
@immutable
class _Cam {
  factory _Cam(_View view, _Framing framing) {
    final f = (view.target - view.eye).unit;
    final r = f.cross(_up).unit;
    return _Cam._(
      view.eye,
      f,
      r,
      r.cross(f),
      framing.center,
      _focal * framing.zoom,
    );
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

  bool inFront(_V w) => depth(w) > _near;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => scale / math.max(_near, depth(w));

  Offset project(_V w) {
    final d = w - eye;
    final k = scale / math.max(_near, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// [pts] (a convex polygon) clipped to the part in front of the camera
  /// and projected; null when less than a triangle is left.
  List<Offset>? clipProject(List<_V> pts) {
    final kept = <_V>[];
    for (var i = 0; i < pts.length; i++) {
      final a = pts[i], b = pts[(i + 1) % pts.length];
      final da = depth(a) - _near, db = depth(b) - _near;
      if (da >= 0) kept.add(a);
      if ((da >= 0) != (db >= 0)) kept.add(_V.lerp(a, b, da / (da - db)));
    }
    if (kept.length < 3) return null;
    return [for (final w in kept) project(w)];
  }
}

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (15, 30, 20)).
const _V _light = _V(0.3841, 0.7682, 0.5121);

/// Segments of the drawn cylinders, discs and spots.
const int _segments = 20;

/// Design px per world unit at the overview camera's distance (about 25
/// units): detail strokes (bricks, frames, glints) are this many times
/// thinner per unit, so they grow with the close-ups.
const double _strokeRef = 24;

/// Friend eyes (visual only, the HTML spheres are plain): offset from the
/// centre (x, y, front), eye and pupil radii, in world units.
const double _eyeX = 0.42, _eyeY = 0.3, _eyeFront = 1.02;
const double _eyeR = 0.24, _pupilR = 0.12;

/// Box faces: outward normal, then the bottom-left, bottom-right and
/// top-left corners of the face, in units of the half size.
const List<(_V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(1, 1, -1)),
];

/// Paints the HTML Three.js scenes: the garden with the wall, frosted door,
/// tree, window, friends and (step 5) bins; the dark room with the torch,
/// beam, screen, shelf, items and bins; then the floating labels. Everything
/// but the dragged item and the pulsing bin rings is recorded once per
/// change ([_PictureCache]) and replayed every frame.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required this.pictures,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final _PictureCache pictures;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _soft = Paint();
  final Path _path = Path();

  /// The camera of the frame being painted.
  _Cam _cam = _Cam(_overview, _Framing.base);

  String _tr(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    _cam = s.camera();
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    canvas.drawRect(labBleed(size), _fill);
    final key = (s.pictureKey, palette.isDark, showLabels, lang, labelScale);
    canvas.drawPicture(pictures.get(key, _record));
    _rings(canvas);
    final item = s.dragging;
    if (item != null) {
      canvas.save();
      canvas.translate(
        s.dragAt.dx - s.dragFrom.dx,
        s.dragAt.dy - s.dragFrom.dy,
      );
      final at = s.itemPos[item]!;
      _item(canvas, item, at);
      if (showLabels) _itemLabel(canvas, item, at, record: false);
      canvas.restore();
    }
  }

  void _record(Canvas c) {
    scene.labelRects.clear();
    if (scene.scenario == 0) {
      _garden(c);
    } else {
      _lightBox(c);
    }
  }

  // ------------------------------------------------------------ scenario 1

  void _garden(Canvas c) {
    final s = scene;
    _box(c, _lawnCentre, _lawnHalf, _Colors.green800);
    final drawables = <(double, VoidCallback)>[
      (_cam.depth(_wallCentre), () => _wall(c)),
      (_cam.depth(_doorCentre), () => _door(c)),
      (_cam.depth(_treeBase + const _V(0, 3, 0)), () => _tree(c)),
      (_cam.depth(_windowCentre), () => _window(c)),
      for (var i = 0; i < _friendStart.length; i++)
        (_cam.depth(s.friend(i)), () => _friend(c, i)),
      if (s.binsVisible)
        for (final k in _Kind.values)
          (_cam.depth(s.binCentre(k)), () => _bin(c, k)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final d in drawables) {
      d.$2();
    }
    if (showLabels) {
      for (final tag in _Tag.values) {
        final at = tag.labelAt;
        if (!_cam.inFront(at)) continue;
        _chip(
          c,
          _cam.project(at),
          _tr('name_${tag.name}'),
          sub: s.inspected.contains(tag) ? _tr('cat_${tag.kind.name}') : null,
          maxWidth: math.min(7 * _cam.scaleAt(at), 220 * labelScale),
          id: tag,
        );
      }
    }
    if (s.binsVisible) _binLabels(c);
  }

  /// HTML wall: a red box, with brick courses on its front face.
  void _wall(Canvas c) {
    _box(c, _wallCentre, _wallHalf, _Colors.red800);
    final z = _wallCentre.z + _wallHalf.z;
    final x0 = _wallCentre.x - _wallHalf.x, x1 = _wallCentre.x + _wallHalf.x;
    if (!_cam.inFront(_V(x0, 0, z)) || !_cam.inFront(_V(x1, 0, z))) return;
    _stroke
      ..strokeWidth = 0.9 * _cam.scaleAt(_wallCentre) / _strokeRef
      ..color = labShade(_Colors.red800, -0.5).withValues(alpha: 0.6);
    const course = 0.5, brick = 1.0;
    for (var j = 1; j * course < 2 * _wallHalf.y; j++) {
      final y = j * course;
      c.drawLine(
        _cam.project(_V(x0, y, z)),
        _cam.project(_V(x1, y, z)),
        _stroke,
      );
    }
    for (var j = 0; j * course < 2 * _wallHalf.y; j++) {
      final y0 = j * course, y1 = y0 + course;
      for (
        var x = x0 + (j.isOdd ? brick / 2 : brick);
        x < x1 - 0.01;
        x += brick
      ) {
        c.drawLine(
          _cam.project(_V(x, y0, z)),
          _cam.project(_V(x, y1, z)),
          _stroke,
        );
      }
    }
  }

  /// HTML door: a frosted (60 % opaque) pale-blue box, with a frame and a
  /// handle.
  void _door(Canvas c) {
    _box(c, _doorCentre, _doorHalf, _Colors.sky100, opacity: _doorOpacity);
    final z = _doorCentre.z + _doorHalf.z + 0.01;
    final h = _doorHalf;
    final frame = _cam.clipProject([
      _V(-h.x, 0, z),
      _V(h.x, 0, z),
      _V(h.x, 2 * h.y, z),
      _V(-h.x, 2 * h.y, z),
    ]);
    if (frame != null) {
      _path
        ..reset()
        ..addPolygon(frame, true);
      _stroke
        ..strokeWidth = 2.2 * _cam.scaleAt(_doorCentre) / _strokeRef
        ..color = _Colors.white.withValues(alpha: 0.75);
      c.drawPath(_path, _stroke);
    }
    final knob = _V(h.x - 0.45, 2.3, z);
    if (_cam.inFront(knob)) {
      _fill
        ..shader = null
        ..color = _Colors.slate500;
      c.drawCircle(_cam.project(knob), 0.13 * _cam.scaleAt(knob), _fill);
    }
  }

  /// HTML tree trunk (CylinderGeometry(1, 1.5, 6)) and a round crown.
  void _tree(Canvas c) {
    _cylinderY(
      c,
      _treeBase,
      _treeBottomR,
      _treeTopR,
      _treeHeight,
      _Colors.amber900,
    );
    if (_cam.inFront(_crownCentre)) {
      labSphere(
        c,
        _cam.project(_crownCentre),
        _crownR * _cam.scaleAt(_crownCentre),
        _Colors.green700,
      );
    }
  }

  /// HTML clear window: a 15 % white pane with a frame and two glints.
  void _window(Canvas c) {
    _box(
      c,
      _windowCentre,
      _windowHalf,
      _Colors.white,
      opacity: _windowOpacity,
      edge: _Colors.slate300.withValues(alpha: 0.9),
    );
    final z = _windowCentre.z + _windowHalf.z + 0.01;
    final cx = _windowCentre.x, cy = _windowCentre.y;
    _stroke
      ..strokeWidth = 1.6 * _cam.scaleAt(_windowCentre) / _strokeRef
      ..color = _Colors.white.withValues(alpha: 0.4);
    for (final (a, b) in const [
      (_V(-1.4, 0.6, 0), _V(-0.6, 1.4, 0)),
      (_V(-1.4, -0.2, 0), _V(0.2, 1.4, 0)),
    ]) {
      final wa = _V(cx + a.x, cy + a.y, z), wb = _V(cx + b.x, cy + b.y, z);
      if (_cam.inFront(wa) && _cam.inFront(wb)) {
        c.drawLine(_cam.project(wa), _cam.project(wb), _stroke);
      }
    }
  }

  /// A friend (HTML SphereGeometry(1.2)): a shaded ball with eyes and a
  /// shadow on the lawn. Seen through the frosted door it is blurred.
  void _friend(Canvas c, int i) {
    final p = scene.friend(i);
    if (!_cam.inFront(p)) return;
    final o = _cam.project(p);
    final r = _friendR * _cam.scaleAt(p);
    final color = _friendColors[i];
    labGroundShadow(
      c,
      _cam.project(_V(p.x, 0.02, p.z)),
      r * 1.6,
      r * 0.5,
      opacity: 0.35,
    );
    final behindDoor =
        p.z < _doorCentre.z - _doorHalf.z &&
        p.x.abs() < _doorHalf.x + _friendR / 2;
    if (behindDoor) {
      _soft
        ..shader = ui.Gradient.radial(
          o + Offset(-0.3 * r, -0.35 * r),
          r * 1.3,
          [labShade(color, 0.3), color, labShade(color, -0.4)],
          const [0, 0.5, 1],
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35);
      c.drawCircle(o, r, _soft);
      _soft
        ..shader = null
        ..maskFilter = null;
      return;
    }
    labSphere(c, o, r, color);
    for (final side in const [-1.0, 1.0]) {
      final e = p + _V(_eyeX * side, _eyeY, _eyeFront);
      final eo = _cam.project(e);
      final k = _cam.scaleAt(e);
      _fill
        ..shader = null
        ..color = _Colors.white;
      c.drawCircle(eo, _eyeR * k, _fill);
      _fill.color = _Colors.slate900;
      c.drawCircle(eo, _pupilR * k, _fill);
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _lightBox(Canvas c) {
    final s = scene;
    _box(c, _floorCentre, _floorHalf, _Colors.slate900);
    _box(c, _shelfCentre, _shelfHalf, _Colors.slate700);
    for (final it in _Item.values) {
      if (s.stored.contains(it) || it == s.beamItem || it == s.dragging) {
        continue;
      }
      _item(c, it, s.itemPos[it]!);
    }
    _screen(c);
    _torch(c);
    _beamBefore(c);
    final inBeam = s.beamItem;
    if (inBeam != null && inBeam != s.dragging) {
      _item(c, inBeam, s.itemPos[inBeam]!);
    }
    _beamAfter(c);
    for (final k in _Kind.values) {
      _bin(c, k);
    }
    if (showLabels) {
      for (final it in _Item.values) {
        if (s.stored.contains(it) || it == s.dragging) continue;
        _itemLabel(c, it, s.itemPos[it]!);
      }
    }
    _binLabels(c);
  }

  /// HTML tumbler (CylinderGeometry(0.8, 0.8, 2), 40 % glass), board
  /// (BoxGeometry(2, 2, 0.4)) or butter paper (BoxGeometry(2, 2, 0.1)),
  /// centred at [at], scaled by [k] (smaller inside a bin).
  void _item(Canvas c, _Item item, _V at, {double k = 1}) {
    switch (item) {
      case _Item.tumbler:
        _cylinderY(
          c,
          at - _V(0, k, 0),
          0.8 * k,
          0.8 * k,
          2 * k,
          _Colors.cyan200,
          opacity: 0.45,
          rim: _Colors.white.withValues(alpha: 0.7),
        );
      case _Item.board:
        _box(c, at, _V(k, k, 0.2 * k), _Colors.amber700);
      case _Item.paper:
        _box(c, at, _V(k, k, 0.05 * k), _Colors.yellow200, opacity: 0.92);
    }
  }

  /// The item's name label (HTML sprite 1.6 above it); on the shelf it is
  /// kept narrower than the gap to the next item.
  void _itemLabel(Canvas c, _Item it, _V at, {bool record = true}) {
    final w = at + _labelLift;
    if (!_cam.inFront(w)) return;
    final onShelf = at.z < -2;
    _chip(
      c,
      _cam.project(w),
      _tr('obj_${it.name}'),
      maxWidth: onShelf
          ? 5 * _cam.scaleAt(w) - 8
          : math.max(5 * _cam.scaleAt(w) - 8, 150.0),
      id: record ? it : null,
    );
  }

  /// HTML screen (BoxGeometry(0.5, 8, 10)) and the light spot on its face:
  /// bright and sharp (empty beam, glass), a dark shadow (board) or dim and
  /// diffused (butter paper).
  void _screen(Canvas c) {
    _box(c, _screenCentre, _screenHalf, _Colors.slate50);
    final x = _screenCentre.x - _screenHalf.x;
    final h = _screenHalf;
    final face = _cam.clipProject([
      _V(x, 0, -h.z),
      _V(x, 0, h.z),
      _V(x, 2 * h.y, h.z),
      _V(x, 2 * h.y, -h.z),
    ]);
    if (face == null) return;
    final kind = scene.beamKind;
    final (
      Color color,
      double scale,
      double alpha,
      double blur,
    ) = switch (kind) {
      _Kind.opaque => (_Colors.slate900, 1.2, 0.9, 0.04),
      _Kind.translucent => (_Colors.yellow200, 1.6, 0.6, 0.3),
      _ => (_Colors.yellow400, 1.0, 1.0, 0.05),
    };
    final spot = _discX(_beamEndX, _V(_beamEndX, _beamY, 0), _spotR * scale);
    if (spot.length < 3) return;
    final centre = _cam.project(const _V(_beamEndX, _beamY, 0));
    final radius =
        _spotR * scale * _cam.scaleAt(const _V(_beamEndX, _beamY, 0));
    c.save();
    _path
      ..reset()
      ..addPolygon(face, true);
    c.clipPath(_path);
    if (kind != _Kind.opaque) {
      labGlow(
        c,
        centre,
        radius * 1.5,
        color,
        intensity: kind == null ? 0.5 : alpha,
      );
    }
    _path
      ..reset()
      ..addPolygon(spot, true);
    _soft
      ..shader = null
      ..color = color.withValues(alpha: alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * blur + 0.5);
    c.drawPath(_path, _soft);
    _soft.maskFilter = null;
    c.restore();
  }

  /// HTML torch: a slate cylinder along x with a yellow lens disc.
  void _torch(Canvas c) {
    final body = _cylinderX(
      _torchBackX,
      _torchBackR,
      _torchFrontX,
      _torchFrontR,
    );
    if (body.length >= 3) {
      final top = _cam.project(const _V(-10, _beamY + _torchBackR, 0));
      final bottom = _cam.project(const _V(-10, _beamY - _torchBackR, 0));
      _fill.shader = ui.Gradient.linear(
        top,
        bottom,
        [
          labShade(_Colors.slate700, 0.35),
          _Colors.slate700,
          labShade(_Colors.slate700, -0.5),
        ],
        const [0, 0.45, 1],
      );
      _path
        ..reset()
        ..addPolygon(body, true);
      c.drawPath(_path, _fill);
      _fill.shader = null;
    }
    final lens = _discX(_lensX, const _V(_lensX, _beamY, 0), _lensR);
    if (lens.length >= 3) {
      final centre = _cam.project(const _V(_lensX, _beamY, 0));
      labGlow(
        c,
        centre,
        _lensR * 2.2 * _cam.scaleAt(const _V(_lensX, 3, 0)),
        _Colors.yellow200,
      );
      _path
        ..reset()
        ..addPolygon(lens, true);
      _fill
        ..shader = null
        ..color = _Colors.yellow200;
      c.drawPath(_path, _fill);
    }
  }

  /// HTML beamBefore: the cone from the lens to the object.
  void _beamBefore(Canvas c) {
    _beam(
      c,
      _torchFrontX,
      _beamStartR,
      _beamMidX,
      _beamMidR,
      _beamBeforeOpacity,
    );
  }

  /// HTML beamAfter: from the object to the screen; none behind the board,
  /// fainter and wider behind the butter paper.
  void _beamAfter(Canvas c) {
    final (double? opacity, double end) = switch (scene.beamKind) {
      _Kind.opaque => (null, _beamEndR),
      _Kind.translucent => (0.2, _beamWideR),
      _Kind.transparent => (0.4, _beamEndR),
      null => (0.35, _beamEndR),
    };
    if (opacity == null) return;
    _beam(c, _beamMidX, _beamMidR, _beamEndX, end, opacity);
  }

  void _beam(Canvas c, double x0, double r0, double x1, double r1, double a) {
    final hull = _cylinderX(x0, r0, x1, r1);
    if (hull.length < 3) return;
    _fill.shader = ui.Gradient.linear(
      _cam.project(_V(x0, _beamY, 0)),
      _cam.project(_V(x1, _beamY, 0)),
      [
        _Colors.yellow200.withValues(alpha: a),
        _Colors.yellow200.withValues(alpha: a * 0.7),
      ],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    c.drawPath(_path, _fill);
    _fill.shader = null;
  }

  // ----------------------------------------------------------------- bins

  /// A bin (HTML drop zone) as an open crate: its opening, what was sorted
  /// into it, then its sides; the rim glows while something is dragged
  /// over it.
  void _bin(Canvas c, _Kind k) {
    final s = scene;
    final centre = s.binCentre(k);
    final h = s.binHalf;
    final (body, rim) = _binColors;
    final top = _cam.clipProject([
      centre + _V(-h.x, h.y, h.z),
      centre + _V(h.x, h.y, h.z),
      centre + _V(h.x, h.y, -h.z),
      centre + _V(-h.x, h.y, -h.z),
    ]);
    if (top != null) {
      _path
        ..reset()
        ..addPolygon(top, true);
      _fill
        ..shader = null
        ..color = labShade(body, -0.55);
      c.drawPath(_path, _fill);
    }
    _binContents(c, k, centre);
    _box(c, centre, h, body, skipTop: true, edge: rim.withValues(alpha: 0.7));
    if (top != null) {
      final hover = s.hoverBin == k;
      _path
        ..reset()
        ..addPolygon(top, true);
      _stroke
        ..strokeWidth = hover ? 3 : 1.6
        ..color = hover ? _Colors.amber400 : rim;
      c.drawPath(_path, _stroke);
    }
  }

  /// A small copy of what was sorted into bin [k], sticking out of it.
  void _binContents(Canvas c, _Kind k, _V centre) {
    final s = scene;
    if (s.scenario == 0) {
      final tag = _Tag.values.firstWhere((t) => t.kind == k);
      if (!s.sorted.contains(tag)) return;
      final at = centre + const _V(0, 0.75, 0);
      switch (tag) {
        case _Tag.wall:
          _box(c, at, const _V(0.7, 0.4, 0.25), _Colors.red800);
        case _Tag.door:
          _box(c, at, const _V(0.5, 0.6, 0.07), _Colors.sky100, opacity: 0.8);
        case _Tag.window:
          _box(
            c,
            at,
            const _V(0.55, 0.55, 0.04),
            _Colors.white,
            opacity: 0.35,
            edge: _Colors.slate300,
          );
      }
      return;
    }
    final item = _Item.values.firstWhere((i) => i.kind == k);
    if (!s.stored.contains(item)) return;
    _item(c, item, centre + const _V(0, 0.65, 0), k: 0.5);
  }

  /// Bin names on chips below the bins (always shown, like the HTML's bin
  /// buttons).
  void _binLabels(Canvas c) {
    final s = scene;
    for (final k in _Kind.values) {
      final centre = s.binCentre(k);
      final front = _V(centre.x, 0, centre.z + s.binHalf.z);
      if (!_cam.inFront(front)) continue;
      final (body, rim) = _binColors;
      final spacing = s.scenario == 0 ? 6.0 : 5.0;
      _chip(
        c,
        _cam.project(front) + const Offset(0, 4),
        _tr('bin${s.scenario + 1}_${k.name}'),
        maxWidth: spacing * _cam.scaleAt(front) - 10,
        above: false,
        fill: body,
        border: rim,
        id: k,
      );
    }
  }

  /// Pulsing rings around every bin while a tag is picked (Scenario 1).
  /// The bin an item belongs in is not highlighted (the HTML's
  /// `updateStepHighlights` bounced it): the learner decides.
  void _rings(Canvas c) {
    final s = scene;
    if (s.scenario != 0 || s.step != _s1Steps || s.selectedTag == null) {
      return;
    }
    const targets = _Kind.values;
    final pulse = 0.5 + 0.5 * math.sin(s.time * 2 * math.pi / 1.2);
    _stroke
      ..strokeWidth = 2.5
      ..color = _Colors.amber400.withValues(alpha: 0.3 + 0.5 * pulse);
    for (final k in targets) {
      final r = s.binRect(k, _cam).inflate(5 + 5 * pulse);
      c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(10)),
        _stroke,
      );
    }
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.75 + directional 0.95, toned down to keep the colours).
  Color _lit(Color c, _V n, {double opacity = 1}) {
    final i = 0.62 + 0.5 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a * opacity,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Axis-aligned box centred at [centre] with half sizes [half]; faces
  /// turned away from the camera are skipped, faces crossing the camera
  /// plane are clipped.
  void _box(
    Canvas c,
    _V centre,
    _V half,
    Color color, {
    double opacity = 1,
    Color? edge,
    bool skipTop = false,
  }) {
    for (final (n, bl, br, tl) in _boxFaces) {
      if (skipTop && n.y > 0) continue;
      final faceCentre = centre + n.mul(half);
      if (n.dot(_cam.eye - faceCentre) <= 0) continue;
      final poly = _cam.clipProject([
        centre + bl.mul(half),
        centre + br.mul(half),
        centre + (br + tl - bl).mul(half),
        centre + tl.mul(half),
      ]);
      if (poly == null) continue;
      _path
        ..reset()
        ..addPolygon(poly, true);
      _fill
        ..shader = null
        ..color = _lit(color, n, opacity: opacity);
      c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color =
            edge ?? labShade(color, -0.5).withValues(alpha: 0.35 * opacity);
      c.drawPath(_path, _stroke);
    }
  }

  /// Upright cylinder standing at [base] (CylinderGeometry look): its
  /// silhouette with a lit gradient and its top cap.
  void _cylinderY(
    Canvas c,
    _V base,
    double rBottom,
    double rTop,
    double height,
    Color color, {
    double opacity = 1,
    Color? rim,
  }) {
    final top = base + _V(0, height, 0);
    if (!_cam.inFront(base) || !_cam.inFront(top)) return;
    final pts = <Offset>[];
    final cap = <Offset>[];
    for (var i = 0; i < _segments; i++) {
      final a = i * 2 * math.pi / _segments;
      final cx = math.cos(a), sz = math.sin(a);
      final t = _cam.project(top + _V(cx * rTop, 0, sz * rTop));
      pts
        ..add(_cam.project(base + _V(cx * rBottom, 0, sz * rBottom)))
        ..add(t);
      cap.add(t);
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    var minX = double.infinity, maxX = -double.infinity;
    for (final o in hull) {
      minX = math.min(minX, o.dx);
      maxX = math.max(maxX, o.dx);
    }
    final y = hull.first.dy;
    Color a(Color col) => col.withValues(alpha: col.a * opacity);
    _fill.shader = ui.Gradient.linear(
      Offset(minX, y),
      Offset(maxX, y),
      [
        a(labShade(color, -0.4)),
        a(labShade(color, 0.3)),
        a(color),
        a(labShade(color, -0.45)),
      ],
      const [0, 0.35, 0.62, 1],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    c.drawPath(_path, _fill);
    _fill.shader = null;
    if (rim != null) {
      _stroke
        ..strokeWidth = 1
        ..color = rim;
      c.drawPath(_path, _stroke);
    }
    if (_cam.eye.y > top.y) {
      _path
        ..reset()
        ..addPolygon(cap, true);
      _fill.color = _lit(color, _up, opacity: opacity);
      c.drawPath(_path, _fill);
      if (rim != null) c.drawPath(_path, _stroke);
    }
  }

  /// Silhouette of a cylinder / cone lying along x at the beam's height
  /// (torch, beams): from x [x0] (radius [r0]) to [x1] (radius [r1]).
  List<Offset> _cylinderX(double x0, double r0, double x1, double r1) {
    final pts = <Offset>[];
    for (var i = 0; i < _segments; i++) {
      final a = i * 2 * math.pi / _segments;
      final cy = math.cos(a), sz = math.sin(a);
      pts
        ..add(_cam.project(_V(x0, _beamY + cy * r0, sz * r0)))
        ..add(_cam.project(_V(x1, _beamY + cy * r1, sz * r1)));
    }
    return _hull(pts);
  }

  /// A disc of radius [r] in the plane x = [x] around [centre], projected.
  List<Offset> _discX(double x, _V centre, double r) => [
    for (var i = 0; i < _segments * 2; i++)
      _cam.project(
        _V(
          x,
          centre.y + math.cos(i * math.pi / _segments) * r,
          centre.z + math.sin(i * math.pi / _segments) * r,
        ),
      ),
  ];

  // ---------------------------------------------------------------- labels

  /// HTML sprite label: a dark chip with a yellow border and white text
  /// (wrapped to [maxWidth], at most two lines), its bottom centre on [at]
  /// ([above]) or its top centre ([above] false); [sub] is a second line in
  /// yellow. Kept inside the visible strip of the stage. Its box is kept
  /// for hit tests under [id].
  void _chip(
    Canvas c,
    Offset at,
    String text, {
    String? sub,
    required double maxWidth,
    bool above = true,
    Color? fill,
    Color? border,
    Object? id,
  }) {
    // A label whose object is out of view (camera close-ups) is not drawn;
    // only labels of visible objects are pushed back inside the strip.
    if (at.dx < scene.labelMinX ||
        at.dx > scene.labelMaxX ||
        at.dy < 0 ||
        at.dy > _design.height) {
      return;
    }
    final k = labelScale;
    final size = _labelPx * k;
    final limit = math.max(40.0, maxWidth - 2 * _labelPadX * k);
    final tp = texts.get(
      text,
      size: size,
      color: _Colors.white,
      maxWidth: limit,
    );
    final sp = sub == null
        ? null
        : texts.get(
            sub,
            size: size * 0.92,
            color: _Colors.zslYellow,
            maxWidth: limit,
          );
    final w = math.max(tp.width, sp?.width ?? 0) + 2 * _labelPadX * k;
    final h = tp.height + (sp == null ? 0 : sp.height + k) + 2 * _labelPadY * k;
    final lo = scene.labelMinX + 2;
    final hi = math.max(lo, scene.labelMaxX - w - 2);
    final left = (at.dx - w / 2).clamp(lo, hi);
    final rect = Rect.fromLTWH(left, above ? at.dy - h : at.dy, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(7 * k));
    _fill
      ..shader = null
      ..color = fill ?? palette.labelBg;
    c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.4
      ..color = border ?? _Colors.zslYellow;
    c.drawRRect(rr, _stroke);
    tp.paint(
      c,
      Offset(rect.center.dx - tp.width / 2, rect.top + _labelPadY * k),
    );
    if (sp != null) {
      sp.paint(
        c,
        Offset(
          rect.center.dx - sp.width / 2,
          rect.top + _labelPadY * k + tp.height + k,
        ),
      );
    }
    if (id != null) scene.labelRects[id] = rect;
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// The recorded static scene, re-recorded only when its key changes (a
/// step, a tween, the camera, the framing). Owned (and disposed) by the
/// page State.
class _PictureCache {
  ui.Picture? _picture;
  Object? _key;

  ui.Picture get(Object key, void Function(Canvas canvas) record) {
    final cached = _picture;
    if (cached != null && key == _key) return cached;
    final recorder = ui.PictureRecorder();
    record(Canvas(recorder));
    cached?.dispose();
    _key = key;
    return _picture = recorder.endRecording();
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
    _key = null;
  }
}

/// TextPainters for the canvas labels, laid out once and reused every
/// frame. A label wider than its room is wrapped (two lines at most) at a
/// width rounded to [_widthStep] px, so camera moves reuse a few layouts.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  static const double _widthStep = 8;
  static const int _maxEntries = 240;

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required double maxWidth,
  }) {
    final single = _painter(text, size, color, null);
    if (single.width <= maxWidth) return single;
    final w = math.max(
      _widthStep,
      (maxWidth / _widthStep).floor() * _widthStep,
    );
    return _painter(text, size, color, w);
  }

  TextPainter _painter(String text, double size, Color color, double? width) {
    final key = '$text|$size|${color.toARGB32()}|${width ?? '-'}';
    final hit = _painters[key];
    if (hit != null) return hit;
    if (_painters.length >= _maxEntries) dispose();
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: width == null ? null : 2,
      ellipsis: width == null ? null : '…',
    )..layout(maxWidth: width ?? double.infinity);
    return _painters[key] = tp;
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
  }
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
