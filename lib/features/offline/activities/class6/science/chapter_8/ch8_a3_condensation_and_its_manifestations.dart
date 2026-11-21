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

/// Class 6 Science • Chapter 8 • Activity 3
/// Condensation and its Manifestations.
///
/// Native Flutter port of
/// `Cl6S-Ch8-A3-Condensation_and_its_Manifestations.html` (Three.js r128).
/// The Three.js scene is redrawn by a small painter that reproduces the
/// HTML camera (position (0, 15, 25), look-at (0, 0, 0), 45° field of
/// view).
///
/// Scenario 1 (The Mystery of the Sweating Glass): drop the ice cubes into
/// a glass of water, tap Observe to watch water vapour from the air turn
/// into droplets on the cold glass, inspect them with a magnifying glass
/// and check that the water level inside has not gone down.
///
/// Scenario 2 (Proving It with Weight): put a glass of ice water on a
/// digital balance (280.0 g), cover it with a steel plate (295.0 g), run
/// the 30-minute timer (a time-lapse) and read the mass rise to 298.5 g on
/// the balance and on a mass–time graph.
class Ch8A3CondensationAndItsManifestationsPage extends StatefulWidget {
  const Ch8A3CondensationAndItsManifestationsPage({super.key});

  @override
  State<Ch8A3CondensationAndItsManifestationsPage> createState() =>
      _CondensationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises two tones with the
/// Web Audio API; each is played with the closest bundled file: `click`
/// (buttons, picking up, letting go) -> click.mp3 / pickup.mp3 / drop.mp3
/// and `ding` (droplets appear, the timer ends) -> correct.mp3; its `ding`
/// for the summary is the shell's success.mp3.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pickup → `science/pickup.mp3`, drop → `science/drop.mp3`.
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback; also the HTML `ding` when the droplets appear and
  /// when the timer ends.
  correct('audio/class6/science/correct.mp3'),

  /// Wrong drop, object touched before its turn.
  wrong('audio/class6/science/error.mp3'),

  /// Summary popup (HTML `ding` in `triggerMainAction`).
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An object picked up (HTML `click` in `startDrag`).
  pickup('audio/class6/science/pickup.mp3'),

  /// An object let go on its target (HTML `click` in `executeStepAction`).
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
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // headings, accents
  static const Color blue600 = Color(0xFF2563EB); // Observe / Timer buttons
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky200 = Color(0xFFBAE6FD);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9); // tailwind `water`
  static const Color emerald500 = Color(0xFF10B981); // Finish button
  static const Color emerald600 = Color(0xFF059669);
  static const Color green400 = Color(0xFF4ADE80); // balance digits
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
  static const Color black = Color(0xFF000000);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a, 0xf8fafc in the light theme.
  static const Color sceneBg = slate900;
  static const Color sceneBgLight = slate50;

  /// `materials.wood` (desk) 0x854d0e, `materials.tray` 0x38bdf8,
  /// `materials.plastic` (balance) 0x334155, `materials.steel` 0xcbd5e1.
  static const Color wood = Color(0xFF854D0E);
  static const Color tray = sky400;
  static const Color plastic = slate700;
  static const Color steel = slate300;

  /// `materials.glass` 0xe0f2fe (opacity 0.25) with 0x94a3b8 edges; the
  /// cold glass turns a pale icy blue (0xbae6fd).
  static const Color glass = sky100;
  static const Color glassEdge = slate400;
  static const Color glassCold = sky200;

  /// `materials.water` 0x0ea5e9 (opacity 0.7), `materials.ice` 0xe0f2fe
  /// (opacity 0.85) with white edges.
  static const Color water = sky500;
  static const Color ice = sky100;

  /// Water level marker: `MeshBasicMaterial({color: 0xef4444})`.
  static const Color marker = red500;

  /// Magnifier ring 0x1e293b, lens 0xbae6fd (opacity 0.3), handle
  /// 0x475569.
  static const Color ring = slate800;
  static const Color lens = sky200;
  static const Color handle = slate600;

  /// Water vapour particles: 0x60a5fa, opacity 0.6.
  static const Color vapour = blue400;

  /// Balance screen 0x000000 and its `text-green-400` reading.
  static const Color screen = black;
  static const Color led = green400;

  /// `#scale-display` text-shadow: rgba(74, 222, 128, 0.5).
  static const Color ledGlow = Color(0x804ADE80);

  /// Pulsing highlight of the object to move (emissive 0x38bdf8).
  static const Color glow = sky400;

  /// `.label-3d` glass chips: `--glass-bg` with a blue-400 border.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBgLight = Color(0xF2FFFFFF);
  static const Color labelBorder = blue400;

  /// `#scale-overlay`: `bg-black/80`, `border-slate-600`.
  static const Color readoutBg = Color(0xCC000000);

  /// Magnifier view (`#magnifier-view`): slate-200 / dark slate-700 fill,
  /// slate-300 / dark slate-600 border; drop gradient white (0.8) to
  /// #38bdf8 (0.6), stroke #0ea5e9.
  static const Color viewBg = slate200;
  static const Color viewBgDark = slate700;
  static const Color viewBorder = slate300;
  static const Color viewBorderDark = slate600;
  static const Color dropLight = Color(0xCCFFFFFF);
  static const Color dropDeep = Color(0x9938BDF8);
  static const Color viewChip = Color(0xB3000000); // bg-black/70

  /// Graph overlay: axes `text-slate-500`, line #3b82f6.
  static const Color axis = slate500;
  static const Color graphLine = blue500;
  static const Color graphBg = Color(0xF2FFFFFF); // bg-white/95
  static const Color graphBgDark = Color(0xF20F172A); // bg-slate-900/95

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

  /// Soft contact shadows on the desk.
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
    card: Color(0xCC0F172A), // bg-slate-900/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x803B82F6),
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
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneBgLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue500,
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
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: Color(0x803B82F6),
    readoutBg: _Colors.slate950,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
    labelText: _Colors.slate800,
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
// drag or tap; "CLICK" is "TAP" and "hover" is "let go over" (touch); the
// HUD names the 'Finish Observation' button by its label; the step 1
// observation describes the cold tint the port draws (the HTML's "frost
// effect" was never visible) and the water rising a little; the S2
// observations give the masses the balance shows instead of "e.g."; the
// Hindi texts avoid verbs that must agree with जल वाष्प. Keys marked
// "added" are texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Condensation and its Manifestations',
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt': 'Scenario 1: The Mystery of the Sweating Glass',
    'scen_2_opt': 'Scenario 2: Proving It with Weight',
    's1_desc':
        'To visually demonstrate that water droplets on a cold glass surface are formed by the condensation of water vapour from the surrounding air.',
    's2_desc':
        'To use a digital weighing balance to provide quantitative evidence that the water from condensation comes from the air, increasing the total mass.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Adding Ice',
    'step_1_1_a':
        'Drag the ice cubes from the ice tray and drop them into the glass tumbler of water.',
    'step_1_1_o':
        'The glass becomes cold, shown by a pale, icy tint on the glass. The ice pushes the water level up a little, just above the red marker.',
    'step_1_2_c': 'Condensation',
    'step_1_2_a':
        "Tap 'Observe' and watch the water vapour in the air around the cold glass.",
    'step_1_2_o':
        'Water vapour particles from the air hit the cold glass, slow down, and form water droplets on its outside.',
    'step_1_3_c': 'Magnification',
    'step_1_3_a':
        'Drag the magnifying glass over the glass tumbler and let go to inspect the droplets.',
    'step_1_3_o': 'Droplets are clearly visible on the outside of the glass.',
    'step_1_4_c': 'Check Inside',
    'step_1_4_a':
        "Compare the water level inside the glass with the red marker, then tap 'Finish Observation'.",
    'step_1_4_o':
        "The internal water level hasn't gone down, proving water didn't seep through the glass.",
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Place on Scale',
    'step_2_1_a': 'Drag the glass of ice water onto the digital balance.',
    'step_2_1_o': 'The balance shows the starting mass: 280.0 g.',
    'step_2_2_c': 'Add Lid',
    'step_2_2_a':
        'Drag the steel plate (lid) onto the top of the glass to cover it.',
    'step_2_2_o':
        'The mass increases to include the lid: 295.0 g. The lid prevents evaporation from inside.',
    'step_2_3_c': 'Observe Timer & Mass',
    'step_2_3_a':
        "Tap 'Start 30-Minute Timer' and watch the timer and the mass on the balance.",
    'step_2_3_o':
        'As condensation forms on the outside, the mass on the balance steadily increases.',
    'step_2_4_c': 'Analyze Results',
    'step_2_4_a':
        "Read the final mass and the graph, then tap 'Finish Observation'.",
    'step_2_4_o':
        'The graph shows a steady increase in mass over time due to condensation.',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1':
        'Step 1: DRAG the ice cubes from the tray and DROP them into the glass tumbler.',
    's1_hud_2': "Step 2: TAP the 'Observe' button to watch what happens.",
    's1_hud_3':
        'Step 3: DRAG the magnifying glass and let go over the glass tumbler.',
    's1_hud_4':
        "Step 4: Observe the water level marker. TAP 'Finish Observation'.",
    's1_hud_5':
        "Observation Complete! TAP 'Finish Observation' to see the summary.",
    's2_hud_1':
        'Step 1: DRAG the glass tumbler and DROP it onto the digital balance.',
    's2_hud_2':
        'Step 2: DRAG the steel plate (lid) and DROP it on top of the glass.',
    's2_hud_3': "Step 3: TAP the 'Start 30-Minute Timer' button.",
    's2_hud_4':
        "Step 4: Analyze the final mass and graph. TAP 'Finish Observation'.",
    's2_hud_5':
        "Observation Complete! TAP 'Finish Observation' to see the summary.",
    // ------------------------------------------------------------ buttons
    'btn_observe': 'Observe',
    'btn_timer': 'Start 30-Minute Timer',
    'btn_finish': 'Finish Observation',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'Complete this step to see the result.',
    // ------------------------------------------------------------ summary
    'success_title': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    's1_summary_head': 'Condensation in Action!',
    's1_summary':
        "The water level inside did not drop, proving water didn't leak out. The droplets on the outside are formed when invisible water vapour from the air hits the cold glass and turns into liquid water.",
    's2_summary_head': 'Mass Proves It!',
    's2_summary':
        'The total mass increased from 295.0 g to 298.5 g. Since the glass was sealed, this proves that matter (water) was added to the outside of the glass from the surrounding air!',
    // ------------------------------------------------------ scene labels
    'lbl_glass': 'Glass Tumbler',
    'lbl_ice': 'Ice Tray',
    'lbl_mag': 'Magnifying Glass',
    'lbl_bal': 'Digital Balance',
    'lbl_lid': 'Steel Plate (Lid)',
    'txt_marker': 'Water Level Marker',
    // Added: the dots are a model of the invisible vapour.
    'lbl_vapour': 'Water vapour in air',
    'magnifier_label': 'Condensation Droplets',
    'graph_title': 'Mass vs Time',
    'graph_y': 'Mass (g)',
    'graph_x': 'Time (min)',
    'unit_g': 'g',
    // Added: the HTML ran its "30-minute timer" without showing it.
    'timer_lbl': 'Timer: {m} min',
    // ---------------------------------------------------- toasts (added)
    'miss_ice': 'Let go of the ice cubes right over the glass tumbler.',
    'miss_mag': 'Let go of the magnifying glass right over the glass tumbler.',
    'miss_glass': 'Let go of the glass right over the digital balance.',
    'miss_lid': 'Let go of the steel plate right on top of the glass.',
    'first_s1_1': 'First drop the ice cubes into the glass tumbler.',
    'first_s1_2': "First tap 'Observe' and watch what happens.",
    'first_s2_1': 'First put the glass on the digital balance.',
    'scene_s1':
        'Desk with a tray of ice cubes, a glass tumbler of water with a red water level marker and a magnifying glass; dots show water vapour in the air.',
    'scene_s2':
        'Desk with a glass of ice water, a digital balance and a steel plate lid.',
  },
  'hi': {
    'app_title': 'संघनन और इसके रूप',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: पसीने से तर गिलास का रहस्य',
    'scen_2_opt': 'परिदृश्य 2: वजन से इसे साबित करना',
    's1_desc':
        'यह दिखाना कि ठंडे कांच की सतह पर पानी की बूंदें आसपास की हवा में मौजूद जल वाष्प के संघनन से बनती हैं।',
    's2_desc':
        'डिजिटल तराजू की सहायता से यह मात्रात्मक प्रमाण देना कि संघनन का पानी हवा से आता है और इससे कुल द्रव्यमान बढ़ता है।',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'बर्फ डालना',
    'step_1_1_a':
        'बर्फ की ट्रे से बर्फ के टुकड़ों को खींचकर पानी वाले कांच के गिलास में छोड़ें।',
    'step_1_1_o':
        'गिलास ठंडा हो जाता है, जो उस पर हल्की बर्फीली आभा से दिखता है। बर्फ के कारण पानी का स्तर थोड़ा ऊपर उठकर लाल मार्कर से ज़रा ऊपर पहुँच जाता है।',
    'step_1_2_c': 'संघनन',
    'step_1_2_a':
        "'निरीक्षण करें' दबाएँ और ठंडे गिलास के आसपास हवा में जल वाष्प को देखें।",
    'step_1_2_o':
        'हवा से जल वाष्प के कण ठंडे कांच से टकराते हैं, धीमे हो जाते हैं और उसकी बाहरी सतह पर पानी की बूंदें बनाते हैं।',
    'step_1_3_c': 'आवर्धन',
    'step_1_3_a':
        'बूंदों का निरीक्षण करने के लिए आवर्धक कांच को खींचकर कांच के गिलास के ऊपर छोड़ें।',
    'step_1_3_o': 'गिलास के बाहर बूंदें स्पष्ट रूप से दिखाई देती हैं।',
    'step_1_4_c': 'अंदर की जाँच करें',
    'step_1_4_a':
        "गिलास के अंदर के जल स्तर की तुलना लाल मार्कर से करें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    'step_1_4_o':
        'अंदर का जल स्तर नीचे नहीं गया है। इससे सिद्ध होता है कि पानी कांच से रिसकर बाहर नहीं आया।',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'तराजू पर रखें',
    'step_2_1_a': 'बर्फ वाले पानी के गिलास को खींचकर डिजिटल तराजू पर रखें।',
    'step_2_1_o': 'तराजू पर प्रारंभिक द्रव्यमान दिखता है: 280.0 g।',
    'step_2_2_c': 'ढक्कन लगाएँ',
    'step_2_2_a':
        'स्टील की प्लेट (ढक्कन) को खींचकर गिलास के ऊपर रखें, ताकि गिलास ढक जाए।',
    'step_2_2_o':
        'ढक्कन जुड़ने से द्रव्यमान बढ़कर 295.0 g हो जाता है। ढक्कन अंदर के पानी को वाष्पित होने से रोकता है।',
    'step_2_3_c': 'टाइमर और द्रव्यमान देखें',
    'step_2_3_a':
        "'30-मिनट टाइमर शुरू करें' दबाएँ और तराजू पर टाइमर तथा द्रव्यमान को देखें।",
    'step_2_3_o':
        'जैसे-जैसे बाहर संघनन होता है, तराजू पर द्रव्यमान लगातार बढ़ता है।',
    'step_2_4_c': 'परिणामों का विश्लेषण करें',
    'step_2_4_a':
        "अंतिम द्रव्यमान और ग्राफ को पढ़ें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    'step_2_4_o':
        'ग्राफ दिखाता है कि संघनन के कारण समय के साथ द्रव्यमान लगातार बढ़ता है।',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1':
        'चरण 1: बर्फ की ट्रे से बर्फ के टुकड़ों को खींचें और कांच के गिलास में छोड़ दें।',
    's1_hud_2':
        "चरण 2: क्या होता है यह देखने के लिए 'निरीक्षण करें' बटन दबाएँ।",
    's1_hud_3': 'चरण 3: आवर्धक कांच को खींचकर कांच के गिलास के ऊपर छोड़ें।',
    's1_hud_4': "चरण 4: जल स्तर मार्कर को देखें। 'अवलोकन समाप्त करें' दबाएँ।",
    's1_hud_5': "अवलोकन पूर्ण! सारांश देखने के लिए 'अवलोकन समाप्त करें' दबाएँ।",
    's2_hud_1': 'चरण 1: कांच के गिलास को खींचें और डिजिटल तराजू पर छोड़ दें।',
    's2_hud_2':
        'चरण 2: स्टील की प्लेट (ढक्कन) को खींचें और गिलास के ऊपर छोड़ दें।',
    's2_hud_3': "चरण 3: '30-मिनट टाइमर शुरू करें' बटन दबाएँ।",
    's2_hud_4':
        "चरण 4: अंतिम द्रव्यमान और ग्राफ का विश्लेषण करें। 'अवलोकन समाप्त करें' दबाएँ।",
    's2_hud_5': "अवलोकन पूर्ण! सारांश देखने के लिए 'अवलोकन समाप्त करें' दबाएँ।",
    // ------------------------------------------------------------ buttons
    'btn_observe': 'निरीक्षण करें',
    'btn_timer': '30-मिनट टाइमर शुरू करें',
    'btn_finish': 'अवलोकन समाप्त करें',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    // ------------------------------------------------------------ summary
    'success_title': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_summary_head': 'यह है संघनन!',
    's1_summary':
        'अंदर का जल स्तर नहीं गिरा, इससे सिद्ध होता है कि पानी बाहर नहीं रिसा। हवा की अदृश्य जल वाष्प के ठंडे कांच पर तरल पानी में बदलने से गिलास के बाहर बूंदें बनती हैं।',
    's2_summary_head': 'द्रव्यमान ने सिद्ध किया!',
    's2_summary':
        'कुल द्रव्यमान 295.0 g से बढ़कर 298.5 g हो गया। गिलास ढका हुआ था, इसलिए इससे सिद्ध होता है कि आसपास की हवा से गिलास के बाहर पदार्थ (पानी) जुड़ा!',
    // ------------------------------------------------------ scene labels
    'lbl_glass': 'कांच का गिलास',
    'lbl_ice': 'बर्फ की ट्रे',
    'lbl_mag': 'आवर्धक कांच',
    'lbl_bal': 'डिजिटल तराजू',
    'lbl_lid': 'स्टील की प्लेट (ढक्कन)',
    'txt_marker': 'जल स्तर मार्कर',
    'lbl_vapour': 'हवा में जल वाष्प',
    'magnifier_label': 'संघनन की बूंदें',
    'graph_title': 'द्रव्यमान बनाम समय',
    'graph_y': 'द्रव्यमान (g)',
    'graph_x': 'समय (मिनट)',
    // SI symbol, as in the NCERT Hindi textbooks.
    'unit_g': 'g',
    'timer_lbl': 'टाइमर: {m} मिनट',
    // ------------------------------------------------------------- toasts
    'miss_ice': 'बर्फ के टुकड़ों को ठीक कांच के गिलास के ऊपर छोड़ें।',
    'miss_mag': 'आवर्धक कांच को ठीक कांच के गिलास के ऊपर छोड़ें।',
    'miss_glass': 'गिलास को ठीक डिजिटल तराजू के ऊपर छोड़ें।',
    'miss_lid': 'स्टील की प्लेट को ठीक गिलास के ऊपर छोड़ें।',
    'first_s1_1': 'पहले बर्फ के टुकड़ों को कांच के गिलास में डालें।',
    'first_s1_2': "पहले 'निरीक्षण करें' दबाएँ और देखें कि क्या होता है।",
    'first_s2_1': 'पहले गिलास को डिजिटल तराजू पर रखें।',
    'scene_s1':
        'मेज़ पर बर्फ के टुकड़ों वाली ट्रे, लाल जल स्तर मार्कर वाला पानी का कांच का गिलास और आवर्धक कांच; बिंदु हवा में जल वाष्प दिखाते हैं।',
    'scene_s2':
        'मेज़ पर बर्फ वाले पानी का गिलास, डिजिटल तराजू और स्टील की प्लेट का ढक्कन।',
  },
};

/// Number of steps of each scenario (HTML `steps` arrays).
const List<int> _stepCounts = [4, 4];

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

/// HTML `resetCamera()` on screens wider than 640 px: camera at
/// (0, 15, 25) looking at the origin. (On narrower screens the HTML pulls
/// back to (0, 40, 50); the stage framing below keeps the scene clear of
/// the shell's cards instead.)
const _V _eye = _V(0, 15, 25);
const _V _lookAt = _V(0, 0, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.8)` and `DirectionalLight(
/// 0xffffff, 0.6)` at (10, 20, 15). Three.js r128 adds them linearly and
/// clips at white, which washes the lit faces out; both are scaled by
/// [_lightScale].
const double _lightScale = 0.75;
const double _ambient = 0.8 * _lightScale;
const double _diffuse = 0.6 * _lightScale;

/// (10, 20, 15) normalised.
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for picking objects up (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make anything jump.
const double _maxFrameStep = 0.1;

/// Time constant (s) of the stage framing as it follows the shell.
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
/// scale).
const double _toastBand = 52;

/// The canvas copy of the action button: its text line and padding (x UI
/// scale), never under the 48 dp tap target.
const double _buttonLine = 36;

/// Height kept free for the canvas copy of the action button, with a gap.
double _buttonBand(double sc) =>
    math.max(kMinInteractiveDimension, _buttonLine * sc) + _cardGap;

/// Smallest framing scale tried when the scene and its labels must fit a
/// small free area (labels keep their size while the scene shrinks).
const double _minViewK = 0.3;
const double _viewKStep = 0.025;

/// Result cards on the right of the canvas (x UI scale): the magnifier
/// view (HTML `w-40` … `w-56`, 160–224 px) and the graph overlay (HTML
/// 200 × 120 SVG plus title and padding).
const double _magCard = 150;
const double _graphCardW = 232;
const double _graphCardH = 176;

// ------------------------------------------------------------ animations

/// `executeStepAction`: the object glides to its place in 500 ms (TWEEN's
/// default Linear easing).
const double _placeSeconds = 0.5;

/// `checkDrop` miss: back home in 500 ms, Quadratic.Out.
const double _returnSeconds = 0.5;

/// Added: the ice cubes drop from above the glass into the water, then the
/// water rises (HTML `s1Water.scale.y = 1.1`) and the glass turns cold.
const double _iceFallSeconds = 0.3;
const double _riseDelay = 0.15;
const double _riseSeconds = 0.35;
const double _coldSeconds = 0.8;

/// `triggerObserve`: particle i leaves after i x 10 ms and reaches the
/// glass in 1500 ms (Quadratic.Out); the droplets start after 1000 ms,
/// droplet i after a further i x 15 ms, each growing for 500 ms; the step
/// moves on 1500 ms after that.
const double _vapourStagger = 0.010;
const double _vapourFlight = 1.5;
const double _dropsDelay = 1.0;
const double _dropStagger = 0.015;
const double _dropGrow = 0.5;
const double _observeSeconds = 2.5;

/// `triggerTimer`: 30 minutes shown in 3000 ms.
const double _timerSeconds = 3.0;
const int _timerMinutes = 30;

/// HTML highlight: emissive 0 … 0.5 of 0x38bdf8, `sin(Date.now() *
/// 0.005)`.
const double _glowRate = 5;
const double _glowMax = 0.5;

/// Summary popup after Finish Observation (the HTML opened it at once;
/// a short pause lets the tap sound finish).
const Duration _summaryDelay = Duration(milliseconds: 300);

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks of 1/60 s, velocity x 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

// -------------------------------------------------------------- geometry

/// `BoxGeometry(40, 2, 20)` desk at y = -1.
const _V _deskCentre = _V(0, -1, 0);
const _V _deskSize = _V(40, 2, 20);

/// `iceTray`: `BoxGeometry(7, 1.5, 5)` at (-10, 0.75, 0).
const _V _trayCentre = _V(-10, 0.75, 0);
const _V _traySize = _V(7, 1.5, 5);

/// Three `BoxGeometry(1.5, 1.5, 1.5)` ice cubes, 2 apart (x -2, 0, 2).
const double _cube = 1.5;
const List<double> _trayCubeX = [-2, 0, 2];
const _V _iceHalf = _V(2.75, 0.75, 0.75);

/// `createTumbler()`: open `CylinderGeometry(3.5, 3.0, 9)` and a base
/// `CylinderGeometry(3.0, 3.0, 0.4)` at y = -4.3. Scenario 1's glass
/// stands at (2, 4.5, 0).
const double _glass1X = 2;
const double _glass1Y = 4.5;
const _V _glass1 = _V(_glass1X, _glass1Y, 0);
const double _glassRBottom = 3.0;
const double _glassRTop = 3.5;
const double _glassHeight = 9;
const double _baseHeight = 0.4;
const _V _glassHalf = _V(_glassRTop, _glassHeight / 2, _glassRTop);

/// Water `CylinderGeometry(3.3, 3.05, 4.5)` centred at y = -2 in the glass
/// (drawn from the base up); the ice raises it to 1.1x its height.
const double _waterRBottom = 3.05;
const double _waterRTop = 3.3;
const double _waterCentre = -2;
const double _waterHeight = 4.5;
const double _waterFloor = -4.1;
const double _iceRise = 1.1;

/// Water level marker: `TorusGeometry(3.3, 0.05)` at y = 0.3 in the glass
/// (just above the water before the ice goes in).
const double _markerY = 0.3;
const double _markerR = 3.3;

/// Ice cubes inside the glass sit at y = 0 (HTML) and fall in from the
/// height the ice was carried to (`s1Tumbler.position.y + 6`).
const double _iceDropHeight = 6;

/// Magnifier: `TorusGeometry(2, 0.3)` ring, `CylinderGeometry(1.9, …)`
/// lens, `CylinderGeometry(0.3, 0.3, 4)` handle centred 3.5 from the ring
/// centre (1.5 … 5.5).
const double _ringR = 2;
const double _ringTube = 0.3;
const double _handleR = 0.3;
const double _handleFrom = 1.5;
const double _handleTo = 5.5;
const int _ringSegments = 32;

/// Through the lens the glass and its droplets look this much bigger.
const double _lensZoom = 1.8;

/// The point of the glass's outside that faces the magnifier (the HTML
/// held it at the glass + (3, 0, 5)): the lens shows it enlarged. That
/// direction, (3, 0, 5) / |(3, 0, 5)|, times the droplets' radius 3.25.
const _V _lensFocus = _V(_glass1X + 1.672, _glass1Y, 2.787);

/// Balance: `BoxGeometry(10, 1, 10)` body at (0, 0.5, 0), pad
/// `CylinderGeometry(4, 4, 0.2)` from y 1.0 to 1.2 and the black screen on
/// its front (z = 5.01; 0.8 high so it stays on the body; the HTML's
/// 1.5-high plane stuck out of it).
const _V _balanceCentre = _V(0, 0.5, 0);
const _V _bodySize = _V(10, 1, 10);
const double _padR = 4;
const double _padBottom = 1.0;
const double _padH = 0.2;
const _V _screenAt = _V(0, 0.5, 5.01);
const _V _screenSize = _V(4, 0.8, 0.04);

/// Lid: `CylinderGeometry(3.6, 3.6, 0.2)`.
const double _lidR = 3.6;
const double _lidH = 0.2;
const _V _lidHalf = _V(_lidR, _lidH / 2, _lidR);

/// Masses on the balance (g): glass of ice water, with the lid, and the
/// water condensed in 30 minutes.
const double _massGlass = 280.0;
const double _massLid = 15.0;
const double _massGain = 3.5;

/// Vapour particles (`SphereGeometry(0.1)`, 150 of them in x ±10,
/// y 2 … 12, z ±7.5) and droplets (`SphereGeometry(0.15)`, 80, scale
/// 0.5 … 1.5).
const int _vapourCount = 150;
const double _vapourR = 0.1;
const int _dropCount = 80;
const double _dropR = 0.15;

/// HTML vapour drift per frame (`sin(...) * 0.02`, `cos(...) * 0.01` at
/// 60 fps), as speeds in units per second; kept inside this box.
const double _driftY = 0.02 * 60;
const double _driftX = 0.01 * 60;
const double _vapourMinY = 1.2;
const double _vapourMaxY = 13;
const double _vapourMaxX = 15;

/// A held object moves on the camera-facing plane through where it was
/// picked up (HTML `dragPlane`), kept inside this box.
const double _dragX = 18;
const double _dragMinY = -1;
const double _dragMaxY = 15;
const double _dragZ = 10;

/// An object counts as over its target when its centre is within this
/// many design px (x the framing scale) of the target's picture.
const double _catchPad = 20;

/// Free spots on the desk (nothing there): used by the flows for a drop
/// that misses.
const _V _openS1 = _V(-6, 0.5, 7);
const _V _openS2 = _V(-7, 0.5, 7);

/// Label anchors.
/// The tray's label sits on the desk in front of the tray (the HTML put
/// it above, where on a phone it ran into the marker's label).
const _V _trayLabelAt = _V(-10, 0, 4.6);
const _V _vapourLabelAt = _V(-8, 9, -2);
const _V _markerLabelAt = _V(
  _glass1X - _waterRTop - 0.35,
  _glass1Y + _markerY,
  0,
);

/// The balance's label hangs this many label sizes below its readout.
const double _balanceLabelGap = 0.3;

/// The timer chip stands this many label sizes above the lid on the glass.
const double _timerLift = 0.4;

/// Below this framing scale the names of the glass and the lid are left
/// out beside the graph card (a small phone), rather than shrink the scene
/// further.
const double _compactK = 0.5;

/// Glass labels sit this far above the glass centre (the HTML's +5 put
/// them over the rim).
const double _glassLabelLift = 6;

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

/// Rotation from Euler angles (Three.js order 'XYZ': Rx · Ry · Rz).
@immutable
class _Rot {
  factory _Rot(double x, double y, double z) {
    final a = math.cos(x), b = math.sin(x);
    final c = math.cos(y), d = math.sin(y);
    final e = math.cos(z), f = math.sin(z);
    final ae = a * e, af = a * f, be = b * e, bf = b * f;
    return _Rot._(
      _V(c * e, -c * f, d),
      _V(af + be * d, ae - bf * d, -b * c),
      _V(bf - ae * d, be + af * d, a * c),
    );
  }

  const _Rot._(this.r0, this.r1, this.r2);

  final _V r0;
  final _V r1;
  final _V r2;

  _V apply(_V v) => _V(r0.dot(v), r1.dot(v), r2.dot(v));
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

  /// Forward, right and up unit vectors.
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

  /// Where the ray through [s] meets the plane through [point] with
  /// [normal] (HTML `raycaster.ray.intersectPlane(dragPlane)`).
  _V? onPlane(Offset s, _V point, _V normal) {
    final dir = ray(s);
    final denom = dir.dot(normal);
    if (denom.abs() < 1e-6) return null;
    final t = (point - eye).dot(normal) / denom;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double ellipseHalf(_V c, double radius) =>
      (p(c + _V(0, 0, radius)).dy - p(c - _V(0, 0, radius)).dy).abs() / 2;

  /// The horizontal circle of [radius] at [c] as a screen rect.
  Rect oval(_V c, double radius) => Rect.fromCenter(
    center: p(c),
    width: 2 * radius * scaleAt(c),
    height: 2 * ellipseHalf(c, radius),
  );
}

/// The unframed HTML camera (scene layout, framing).
final _Camera _baseCam = _Camera(_eye, _lookAt);

/// Tilt (about x) that turns the magnifier from lying flat (handle away
/// from the viewer) to facing the camera (handle down).
final double _uprightAngle = math.atan2(_baseCam.u.y, _baseCam.u.z);

/// The magnifier's ring plane axes at [tilt] (0 flat … 1 facing the
/// camera): x, and the axis the handle points against.
(_V, _V) _magAxes(double tilt) {
  final a = tilt * _uprightAngle;
  return (const _V(1, 0, 0), _V(0, math.sin(a), math.cos(a)));
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

/// Projected bounding box of the magnifier (ring and handle) at [c].
Rect _magnifierBounds(_Camera cam, _V c, double tilt) {
  final (ex, ey) = _magAxes(tilt);
  final first = cam.p(c - ey * _handleTo);
  var r = Rect.fromLTRB(first.dx, first.dy, first.dx, first.dy);
  const outer = _ringR + _ringTube;
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    final o = cam.p(
      c + ex * (math.cos(a) * outer) + ey * (math.sin(a) * outer),
    );
    r = r.expandToInclude(Rect.fromLTRB(o.dx, o.dy, o.dx, o.dy));
  }
  return r;
}

/// A scene label chip: the box of text [text] (laid out) at [at]; with
/// [edge] 1 its right edge, with -1 its left edge sits on [at]; with
/// [above] 1 its bottom edge does.
Rect _chipBox(
  Offset at,
  Size text,
  double labelSize,
  double edge, {
  double above = 0,
}) {
  final w = text.width + 1.2 * labelSize;
  final h = text.height + 0.6 * labelSize;
  return Rect.fromLTWH(
    at.dx - (edge + 1) / 2 * w,
    at.dy - (above + 1) / 2 * h,
    w,
    h,
  );
}

/// The objects the learner drags (the HTML `activeDragTarget`s).
enum _Item {
  /// `iceCubes` from the tray into the glass (S1 step 1); carried to
  /// `s1Tumbler.position.y + 6` above the glass.
  ice(
    scenario: 0,
    step: 1,
    home: _V(-10, 1.5, 0),
    place: _V(2, 10.5, 0),
    missKey: 'miss_ice',
  ),

  /// `magnifier` over the glass (S1 step 3): the HTML moved it to the
  /// glass + (3, 0, 5); it lay flat on the desk at (12, 1, 6) (here on the
  /// desk top).
  magnifier(
    scenario: 0,
    step: 3,
    home: _V(12, 0.35, 6),
    place: _V(5, 4.5, 5),
    missKey: 'miss_mag',
  ),

  /// `s2Tumbler` onto the balance (S2 step 1); it stands on the pad
  /// (the HTML sank it 0.7 into the balance at y = 5).
  tumbler(
    scenario: 1,
    step: 1,
    home: _V(-12, 4.5, 0),
    place: _V(0, _padBottom + _padH + _glassHeight / 2, 0),
    missKey: 'miss_glass',
  ),

  /// `lid` onto the glass (S2 step 2): on its rim.
  lid(
    scenario: 1,
    step: 2,
    home: _V(12, 0.1, 0),
    place: _V(0, _padBottom + _padH + _glassHeight + _lidH / 2, 0),
    missKey: 'miss_lid',
  );

  const _Item({
    required this.scenario,
    required this.step,
    required this.home,
    required this.place,
    required this.missKey,
  });

  final int scenario;

  /// The step that moves it.
  final int step;
  final _V home;

  /// Where it ends up when the step is done.
  final _V place;

  /// Hint when it is let go away from its target.
  final String missKey;
}

/// What a draggable object is doing.
enum _Phase { idle, held, returning, placing, placed }

class _Mover {
  _Mover(this.item) : pos = item.home;

  final _Item item;
  _V pos;
  _Phase phase = _Phase.idle;
  double phaseStart = 0;

  /// Start of the current move.
  _V from = _V.zero;

  /// Magnifier: 0 lying flat … 1 held up to the glass.
  double tilt = 0;

  bool get moving =>
      phase == _Phase.held ||
      phase == _Phase.returning ||
      phase == _Phase.placing;
}

/// One water vapour particle (HTML `vapourParticles` child).
class _Vapour {
  _Vapour(this.base, this.speed, this.offset, this.target)
    : pos = base,
      from = base;

  final _V base;
  final double speed;
  final double offset;

  /// Where it lands on the outside of the glass (the HTML picks a random
  /// point on Observe).
  final _V target;
  _V pos;
  _V from;
  bool visible = true;
}

/// One droplet on the outside of a glass (HTML `s1Droplets` /
/// `s2Droplets`), relative to the glass centre.
@immutable
class _Drop {
  const _Drop(this.local, this.maxScale, {required this.behind});

  final _V local;
  final double maxScale;

  /// On the far side of the glass.
  final bool behind;
}

/// An ice cube inside a glass (relative to the glass centre).
@immutable
class _Cube {
  const _Cube(this.offset, this.rot);

  final _V offset;
  final _Rot rot;
}

/// One confetti piece.
@immutable
class _Confetto {
  const _Confetto(this.angle, this.velocity, this.color, this.spin);

  final double angle;
  final double velocity;
  final Color color;
  final double spin;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    final rnd = math.Random(83);
    final glassC = _glass1;
    for (var i = 0; i < _vapourCount; i++) {
      final base = _V(
        (rnd.nextDouble() - 0.5) * 20,
        2 + rnd.nextDouble() * 10,
        (rnd.nextDouble() - 0.5) * 15,
      );
      final a = rnd.nextDouble() * math.pi * 2;
      final target =
          glassC +
          _V(
            math.cos(a) * _markerR,
            (rnd.nextDouble() - 0.5) * 8,
            math.sin(a) * _markerR,
          );
      vapour.add(
        _Vapour(
          base,
          0.02 + rnd.nextDouble() * 0.03,
          rnd.nextDouble() * math.pi * 2,
          target,
        ),
      );
    }
    for (var i = 0; i < _dropCount; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final h = (rnd.nextDouble() - 0.5) * 8;
      final r = 3.25 + (h / 9) * 0.25;
      drops.add(
        _Drop(
          _V(math.cos(a) * r, h, math.sin(a) * r),
          0.5 + rnd.nextDouble(),
          behind: math.sin(a) < 0,
        ),
      );
    }
    _Cube cube() => _Cube(
      _V((rnd.nextDouble() - 0.5) * 2, 0, (rnd.nextDouble() - 0.5) * 2),
      _Rot(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble()),
    );
    for (var i = 0; i < 3; i++) {
      cubes1.add(cube());
    }
    for (var i = 0; i < 3; i++) {
      cubes2.add(cube());
    }
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          _Colors.confetti[i % _Colors.confetti.length],
          (rnd.nextDouble() - 0.5) * 0.4,
        ),
      );
    }
  }

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; steps + 1 once Finish was tapped).
  int step = 1;

  /// Bumped on every load, so a gesture from before cannot touch the new
  /// scene.
  int generation = 0;

  final List<_Mover> movers = [];
  final List<_Vapour> vapour = [];
  final List<_Drop> drops = [];
  final List<_Cube> cubes1 = [];
  final List<_Cube> cubes2 = [];
  final List<_Confetto> confetti = [];

  // ----------------------------------------------------------- scenario 1

  /// The ice is in the glass (the HTML hid the tray's cubes and added three
  /// inside the glass).
  bool iceInGlass = false;
  double iceInStart = 0;

  /// Scene time Observe was tapped.
  double? observeStart;
  bool dinged = false;

  /// The magnifier view card (HTML `#magnifier-view`).
  bool magView = false;

  // ----------------------------------------------------------- scenario 2

  /// Grams on the balance (HTML `#scale-display`).
  double readout = 0;

  /// Scene time the timer was started, and its progress (0 … 1).
  double? timerStart;
  double timerP = 0;

  /// The graph card (HTML `#graph-overlay`).
  bool graph = false;

  double? confettiStart;

  final _Camera cam = _Camera(_eye, _lookAt);
  _View view = _View.identity;
  _View viewTarget = _View.identity;

  /// The next framing jumps to its target instead of sliding.
  bool snapView = true;

  /// The names beside the glass and the lid on the balance are left out:
  /// on a small phone they do not fit beside the graph card.
  bool compactLabels = false;

  _Mover mover(_Item item) => movers.firstWhere((m) => m.item == item);

  /// An object glides into place, the vapour is moving to the glass or the
  /// timer runs (HTML `State.isAnimating`).
  bool get busy =>
      movers.any((m) => m.phase == _Phase.placing) ||
      (scenario == 0 && step == 2 && observeStart != null) ||
      (scenario == 1 && step == 3 && timerStart != null);

  /// The object the current step asks the learner to move (HTML
  /// `activeDragTarget`), glowing while it waits.
  _Mover? get activeMover {
    if (busy) return null;
    for (final m in movers) {
      if (m.item.step == step &&
          (m.phase == _Phase.idle || m.phase == _Phase.held)) {
        return m;
      }
    }
    return null;
  }

  // ------------------------------------------ derived (also read by tests)

  double get _sinceIce => time - iceInStart;

  /// Share of the cold tint on the glass (0 … 1).
  double get frost => scenario == 1
      ? 1
      : (iceInGlass ? (_sinceIce / _coldSeconds).clamp(0.0, 1.0) : 0);

  /// Height of the water in Scenario 1's glass (HTML `s1Water.scale.y`).
  double get waterScale => iceInGlass
      ? 1 +
            (_iceRise - 1) *
                ((_sinceIce - _riseDelay) / _riseSeconds).clamp(0.0, 1.0)
      : 1;

  /// Top of the water, relative to the glass centre.
  double get waterTop => _waterCentre + _waterHeight / 2 * waterScale;

  /// The water level marker, relative to the glass centre.
  double get markerY => _markerY;

  /// How far above their resting place the ice cubes in the glass are.
  double get cubeLift {
    if (!iceInGlass) return 0;
    final k = (_sinceIce / _iceFallSeconds).clamp(0.0, 1.0);
    return _iceDropHeight * (1 - k * k);
  }

  /// Droplet [i]'s size (0 … its HTML `maxScale`).
  double dropScale(int i) {
    final d = drops[i];
    if (scenario == 1) return timerP * d.maxScale;
    final t0 = observeStart;
    if (t0 == null) return 0;
    final k = ((time - t0 - _dropsDelay - i * _dropStagger) / _dropGrow).clamp(
      0.0,
      1.0,
    );
    return k * d.maxScale;
  }

  /// Share of the droplets that have appeared.
  double get dropletsShown {
    var n = 0;
    for (var i = 0; i < drops.length; i++) {
      if (dropScale(i) > 0) n++;
    }
    return n / drops.length;
  }

  /// Vapour particles still in the air.
  int get vapourLeft => vapour.where((p) => p.visible).length;

  /// Minutes on the timer.
  int get timerMinutes => (_timerMinutes * timerP).floor();

  /// Design-space position of a named scene point (used by the flows):
  /// the objects, `glass` (Scenario 1's glass), `balance` (where the
  /// glass's centre goes on the balance), `glassTop` (where the lid goes)
  /// and `open` (a free spot on the desk).
  Offset anchor(String id) {
    for (final m in movers) {
      if (m.item.name == id) return cam.p(m.pos);
    }
    return switch (id) {
      'glass' => cam.p(_glass1),
      'balance' => cam.p(_Item.tumbler.place),
      'glassTop' => cam.p(_Item.lid.place),
      'open' => cam.p(scenario == 0 ? _openS1 : _openS2),
      _ => cam.p(_lookAt),
    };
  }

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    generation++;
    scenario = index;
    step = 1;
    movers
      ..clear()
      ..addAll([
        for (final k in _Item.values)
          if (k.scenario == index) _Mover(k),
      ]);
    iceInGlass = false;
    iceInStart = 0;
    observeStart = null;
    dinged = false;
    magView = false;
    for (final p in vapour) {
      p
        ..pos = p.base
        ..from = p.base
        ..visible = true;
    }
    readout = 0;
    timerStart = null;
    timerP = 0;
    graph = false;
    confettiStart = null;
    snapView = true;
    compactLabels = false;
  }

  /// HTML `triggerObserve()`: every particle heads for the glass from where
  /// it is.
  void startObserve() {
    observeStart = time;
    for (final p in vapour) {
      p.from = p.pos;
    }
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

/// What the current pointer holds.
class _Grab {
  _Grab(this.mover, this.offset, this.plane, this.generation);

  final _Mover mover;

  /// Drag-plane hit minus the object's position at pointer-down.
  final _V offset;

  /// A point of the camera-facing drag plane (the object at pointer-down).
  final _V plane;
  final int generation;
}

/// The result card on the right of the canvas.
enum _Card { magnifier, graph }

class _CondensationLabState
    extends State<Ch8A3CondensationAndItsManifestationsPage>
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

  /// HTML `animate()` (`TWEEN.update()`, vapour drift), then one repaint of
  /// the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.view = s.view.toward(s.viewTarget, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    final before = s.step;
    final hadCard = s.magView || s.graph;
    _advanceMovers();
    if (s.scenario == 0) {
      _advanceVapour(dt);
    } else {
      _advanceTimer();
    }
    if (s.step != before || (s.magView || s.graph) != hadCard) _refresh();
    _frame.value = now;
  }

  /// `executeStepAction` / `checkDrop` tweens of the dragged objects.
  void _advanceMovers() {
    final s = _scene;
    for (final m in s.movers) {
      final t = s.time - m.phaseStart;
      switch (m.phase) {
        case _Phase.idle:
        case _Phase.held:
        case _Phase.placed:
          break;
        case _Phase.returning:
          final k = (t / _returnSeconds).clamp(0.0, 1.0);
          m.pos = _V.lerp(m.from, m.item.home, Curves.easeOutQuad.transform(k));
          if (k >= 1) m.phase = _Phase.idle;
        case _Phase.placing:
          final k = (t / _placeSeconds).clamp(0.0, 1.0);
          m.pos = _V.lerp(m.from, m.item.place, k);
          if (m.item == _Item.magnifier) m.tilt = k;
          if (k >= 1) {
            m.phase = _Phase.placed;
            _placed(m.item);
          }
      }
    }
  }

  /// The rest of `executeStepAction` once the tween is done.
  void _placed(_Item item) {
    final s = _scene;
    switch (item) {
      case _Item.ice:
        s
          ..iceInGlass = true
          ..iceInStart = s.time
          ..step = 2;
      case _Item.magnifier:
        s
          ..magView = true
          ..step = 4;
      case _Item.tumbler:
        s
          ..readout = _massGlass
          ..step = 2;
      case _Item.lid:
        s
          ..readout = _massGlass + _massLid
          ..step = 3;
    }
  }

  /// Scenario 1: the vapour drifts (HTML `animate()`, paused while
  /// something animates), then `triggerObserve` sends it to the glass and
  /// the droplets appear.
  void _advanceVapour(double dt) {
    final s = _scene;
    final t0 = s.observeStart;
    if (t0 == null) {
      if (s.busy) return;
      for (final p in s.vapour) {
        final y =
            p.pos.y + math.sin(s.time * p.speed * 10 + p.offset) * _driftY * dt;
        final x =
            p.pos.x + math.cos(s.time * p.speed * 5 + p.offset) * _driftX * dt;
        p.pos = _V(
          x.clamp(-_vapourMaxX, _vapourMaxX),
          y.clamp(_vapourMinY, _vapourMaxY),
          p.pos.z,
        );
      }
      return;
    }
    final since = s.time - t0;
    for (var i = 0; i < s.vapour.length; i++) {
      final p = s.vapour[i];
      if (!p.visible) continue;
      final k = ((since - i * _vapourStagger) / _vapourFlight).clamp(0.0, 1.0);
      p.pos = _V.lerp(p.from, p.target, Curves.easeOutQuad.transform(k));
      if (k >= 1) p.visible = false;
    }
    if (!s.dinged && since >= _dropsDelay) {
      s.dinged = true;
      _Sound.correct.play();
    }
    if (s.step == 2 && since >= _observeSeconds) s.step = 3;
  }

  /// Scenario 2: `triggerTimer` (mass 295.0 → 298.5 g, droplets grow).
  void _advanceTimer() {
    final s = _scene;
    final t0 = s.timerStart;
    if (t0 == null || s.step != 3) return;
    final p = ((s.time - t0) / _timerSeconds).clamp(0.0, 1.0);
    s
      ..timerP = p
      ..readout = _massGlass + _massLid + _massGain * p;
    if (p >= 1) {
      _Sound.correct.play();
      s
        ..graph = true
        ..step = 4;
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

  /// HTML `triggerObserve()`.
  void _observe() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 2 || s.observeStart != null) return;
    setState(s.startObserve);
  }

  /// HTML `triggerTimer()`.
  void _startTimer() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || s.timerStart != null) return;
    setState(() => s.timerStart = s.time);
  }

  /// HTML `triggerMainAction()`: the summary popup (and confetti after the
  /// last scenario). Tapped again later, it re-opens the summary.
  void _finish() {
    final s = _scene;
    final sc = s.scenario;
    final n = _stepCounts[sc];
    if (s.step < n || s.busy) return;
    if (s.step == n) {
      setState(() {
        s.step = n + 1;
        if (sc == _stepCounts.length - 1) s.confettiStart = s.time;
      });
    }
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: _summaryDelay,
      title: () => _t('success_title'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () =>
          '${_t('s${sc + 1}_summary_head')}\n\n${_t('s${sc + 1}_summary')}',
    );
  }

  // -------------------------------------------------------------- gestures

  bool _unlocked(_Mover m) {
    final s = _scene;
    return !s.busy &&
        m.phase == _Phase.idle &&
        m.item.scenario == s.scenario &&
        m.item.step == s.step;
  }

  /// Projected bounds of a draggable object.
  Rect _bounds(_Camera cam, _Mover m) => switch (m.item) {
    _Item.ice => _boxBounds(cam, m.pos, _iceHalf),
    _Item.magnifier => _magnifierBounds(cam, m.pos, m.tilt),
    _Item.tumbler => _boxBounds(cam, m.pos, _glassHalf),
    _Item.lid => _boxBounds(cam, m.pos, _lidHalf),
  };

  /// The draggable object under [at] (design px): the one the step asks
  /// for first, otherwise the nearest.
  _Mover? _hitTest(Offset at) {
    final s = _scene;
    _Mover? best;
    var bestScore = double.infinity;
    for (final m in s.movers) {
      if (m.phase != _Phase.idle) continue;
      final b = _bounds(s.cam, m);
      final box = Rect.fromCenter(
        center: b.center,
        width: math.max(b.width, 2 * _touch),
        height: math.max(b.height, 2 * _touch),
      );
      if (!box.contains(at)) continue;
      final score = (_unlocked(m) ? 0 : 1000) + s.cam.depth(m.pos);
      if (score < bestScore) {
        best = m;
        bestScore = score;
      }
    }
    return best;
  }

  /// HTML `pointerdown`: only on a draggable object.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null || _scene.busy) return false;
    return _hitTest(event.localPosition) != null;
  }

  /// What the current step asks for, for an object touched too early
  /// (added; the HTML ignored such touches).
  String? _notYetKey() {
    final s = _scene;
    if (s.scenario == 0) {
      return switch (s.step) {
        1 => 'first_s1_1',
        2 => 'first_s1_2',
        _ => null,
      };
    }
    return s.step == 1 ? 'first_s2_1' : null;
  }

  /// HTML `startDrag`: the drag plane faces the camera through the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final m = _hitTest(d.localPosition);
    if (m == null) return;
    if (!_unlocked(m)) {
      final key = _notYetKey();
      if (key != null) _lab.showToast(_t(key), isError: true);
      return;
    }
    m.phase = _Phase.held;
    final at = s.cam.onPlane(d.localPosition, m.pos, s.cam.f);
    _grab = _Grab(m, at == null ? _V.zero : at - m.pos, m.pos, s.generation);
    _Sound.pickup.play();
  }

  /// HTML `pointermove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    final hit = s.cam.onPlane(d.localPosition, g.plane, s.cam.f);
    if (hit == null) return;
    final p = hit - g.offset;
    g.mover.pos = _V(
      p.x.clamp(-_dragX, _dragX),
      p.y.clamp(_dragMinY, _dragMaxY),
      p.z.clamp(-_dragZ, _dragZ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` + `checkDrop()`: on its target the object glides
  /// into place; anywhere else it goes back home with a hint.
  void _release() {
    final s = _scene;
    final g = _grab;
    _grab = null;
    if (g == null || g.generation != s.generation) return;
    final m = g.mover;
    if (m.phase != _Phase.held) return;
    m
      ..phaseStart = s.time
      ..from = m.pos;
    if (_overTarget(m)) {
      m.phase = _Phase.placing;
      _Sound.drop.play();
      return;
    }
    m.phase = _Phase.returning;
    _lab.showToast(_t(m.item.missKey), isError: true);
  }

  /// Is the let-go object over its target on screen? (The HTML accepted
  /// anything within 8 units, a radius wider than the glass.)
  bool _overTarget(_Mover m) {
    final s = _scene;
    final cam = s.cam;
    final pad = _catchPad * s.view.k;
    switch (m.item) {
      case _Item.ice:
      case _Item.magnifier:
        return _boxBounds(
          cam,
          _glass1,
          _glassHalf,
        ).inflate(pad).contains(cam.p(m.pos));
      case _Item.tumbler:
        final r = _boxBounds(
          cam,
          _V(0, (_padBottom + _padH) / 2, 0),
          _V(_bodySize.x / 2, (_padBottom + _padH) / 2, _bodySize.z / 2),
        ).inflate(pad);
        return r.contains(cam.p(m.pos)) ||
            r.contains(cam.p(m.pos - const _V(0, _glassHeight / 2, 0)));
      case _Item.lid:
        final glass = s.mover(_Item.tumbler);
        return glass.phase == _Phase.placed &&
            _boxBounds(
              cam,
              glass.pos,
              _glassHalf,
            ).inflate(pad).contains(cam.p(m.pos));
    }
  }

  // --------------------------------------------------------------- framing

  bool _showCanvasButton(List<LabAction> actions) =>
      _lab.isLabActive && _lab.isSidebarOpen && actions.isNotEmpty;

  /// Top of the free canvas: below the canvas action button (and the toast
  /// band above it) while that button is shown.
  double _topClear(BuildContext context, List<LabAction> actions) {
    if (_showCanvasButton(actions)) {
      return labOverlayInsets(context, _lab).top +
          _toastBand * context.labScale +
          _buttonBand(context.labScale);
    }
    return _cardGap + MediaQuery.paddingOf(context).top;
  }

  /// Bottom of the free canvas: above the HUD chip while the sidebar is
  /// open.
  double _bottomClear(BuildContext context, double canvasHeight) =>
      canvasHeight -
      (_lab.isSidebarOpen ? _hudBand * context.labScale + _cardGap : _cardGap) -
      MediaQuery.paddingOf(context).bottom;

  /// The result card on the right (magnifier view or graph): which, its
  /// top in the canvas and its size; null when none is shown.
  ({_Card kind, double top, Size size})? _card(
    BuildContext context,
    double canvasHeight,
    List<LabAction> actions,
  ) {
    final s = _scene;
    if (!_lab.isLabActive) return null;
    final _Card kind;
    if (s.scenario == 0 && s.magView) {
      kind = _Card.magnifier;
    } else if (s.scenario == 1 && s.graph) {
      kind = _Card.graph;
    } else {
      return null;
    }
    final sc = context.labScale;
    final size = kind == _Card.magnifier
        ? Size.square(_magCard * sc)
        : Size(_graphCardW * sc, _graphCardH * sc);
    final top = math.max(
      _topClear(context, actions),
      labOverlayInsets(context, _lab).top + _toastBand * sc,
    );
    final bottom = _bottomClear(context, canvasHeight);
    return (
      kind: kind,
      top: math.max(top, (top + bottom - size.height) / 2),
      size: size,
    );
  }

  /// Fits what the learner needs now (objects and labels) into the part of
  /// the canvas no shell card covers: the tool column, the HUD chip
  /// (sidebar open), the canvas action button, the result card and the
  /// floating mission card (sidebar collapsed: the scene moves below it or,
  /// if that would shrink it more, to its right). Returns the framing in
  /// design px for a canvas of [canvas] dp at stage scale [fit].
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
    final actions = _actions();
    final card = _card(context, canvas.height, actions);
    final right = canvas.width - insets.right;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _topClear(context, actions),
      card == null ? right : right - _cardGap - card.size.width - _cardGap,
      _bottomClear(context, canvas.height),
    );
    final frees = <Rect>[
      if (open || !_lab.isLabActive)
        base
      else ...[
        Rect.fromLTRB(insets.left, base.top, base.right, base.bottom),
        Rect.fromLTRB(
          base.left,
          size.height < _compactBelow
              ? math.max(
                  base.top,
                  _missionTop +
                      pad.top +
                      size.height * _compactCardMax +
                      _cardGap,
                )
              : canvas.height,
          base.right,
          base.bottom,
        ),
      ],
    ];
    final stageRect = (Offset.zero & _design).deflate(_cardGap);
    final areas = [for (final r in frees) toDesign(r).intersect(stageRect)];
    var view = _fit(areas, sideLabels: true);
    // Beside the graph card on a small phone the names of the glass and
    // the lid do not fit: they are left out rather than shrink the scene.
    final compact = _scene.scenario == 1 && card != null && view.k < _compactK;
    if (compact) view = _fit(areas, sideLabels: false);
    _scene.compactLabels = compact;
    return view;
  }

  /// The largest framing that fits the focus into one of [areas]. Labels
  /// keep their size while the scene is scaled by k, so they are measured
  /// 1 / k larger.
  _View _fit(List<Rect> areas, {required bool sideLabels}) {
    Rect focus(double grow) => _focusRect(grow, sideLabels: sideLabels);
    final whole = _fitView(focus(1), areas, 1);
    if (whole.k >= 1) return whole;
    for (var k = 1 - _viewKStep; k > _minViewK; k -= _viewKStep) {
      final view = _fitView(focus(1 / k), areas, k);
      if (view.k >= k - 1e-6) return view;
    }
    return _fitView(focus(1 / _minViewK), areas, _minViewK);
  }

  /// Bounds (unframed design px) of what the learner touches and reads at
  /// the current step: the objects, their labels and the readouts, the
  /// labels [grow] times their size (the names beside the glass and the
  /// lid on the balance only with [sideLabels]). Once the objects have
  /// been moved, only where they are now counts.
  Rect _focusRect(double grow, {required bool sideLabels}) {
    final s = _scene;
    final cam = _baseCam;
    final size = _labelSize;
    _cache.prepare(_lab.lang, size);
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    Rect box(
      Offset at,
      String text,
      double edge,
      _Ink ink, {
      double above = 0,
    }) {
      final tp = _cache.text(ink, text);
      return _chipBox(at, tp.size * grow, size * grow, edge, above: above);
    }

    void chip(_V at, String text, {double edge = 0}) =>
        add(box(cam.p(at), text, edge, _Ink.chip));

    if (s.scenario == 0) {
      add(_boxBounds(cam, _glass1, _glassHalf));
      chip(_glassLabelAt(_glass1), _t('lbl_glass'));
      chip(_markerLabelAt, _t('txt_marker'), edge: 1);
      if (s.step < 4) {
        add(_boxBounds(cam, _trayCentre, _traySize * 0.5));
        add(_boxBounds(cam, _Item.ice.home, _iceHalf));
        chip(_trayLabelAt, _t('lbl_ice'));
        add(_magnifierBounds(cam, _Item.magnifier.home, 0));
        chip(_magLabelAt(_Item.magnifier.home), _t('lbl_mag'));
        chip(_vapourLabelAt, _t('lbl_vapour'));
      } else {
        add(_magnifierBounds(cam, _Item.magnifier.place, 1));
      }
    } else {
      const glass = _Item.tumbler;
      const lid = _Item.lid;
      add(
        _boxBounds(
          cam,
          _balanceCentre,
          _V(_bodySize.x / 2, (_padBottom + _padH) / 2, _bodySize.z / 2),
        ),
      );
      add(_boxBounds(cam, glass.place, _glassHalf));
      add(_boxBounds(cam, lid.place, _lidHalf));
      if (sideLabels) {
        chip(_tumblerSideLabelAt(glass.place), _t('lbl_glass'), edge: 1);
        chip(_lidSideLabelAt(lid.place), _t('lbl_lid'), edge: -1);
      }
      final readout = box(
        cam.p(_screenAt),
        _readoutText(_massGlass + _massLid + _massGain),
        0,
        _Ink.readout,
      );
      add(readout);
      add(
        box(
          Offset(
            readout.center.dx,
            readout.bottom + _balanceLabelGap * size * grow,
          ),
          _t('lbl_bal'),
          0,
          _Ink.chip,
          above: -1,
        ),
      );
      add(
        box(
          _boxBounds(cam, lid.place, _lidHalf).topCenter -
              Offset(0, _timerLift * size * grow),
          labFormat(_t('timer_lbl'), {'m': _timerMinutes}),
          0,
          _Ink.chip,
          above: 1,
        ),
      );
      if (s.step < 3) {
        add(_boxBounds(cam, glass.home, _glassHalf));
        chip(_glassLabelAt(glass.home), _t('lbl_glass'));
        add(_boxBounds(cam, lid.home, _lidHalf));
        chip(_lidLabelAt(lid.home), _t('lbl_lid'));
      }
    }
    return r ?? Offset.zero & _design;
  }

  String _readoutText(double grams) =>
      '${grams.toStringAsFixed(1)} ${_t('unit_g')}';

  /// The framing that shows [focus] inside one of [frees] as large as
  /// possible (never above the HTML size, nor above [maxK]) and moved as
  /// little as possible.
  static _View _fitView(Rect focus, List<Rect> frees, double maxK) {
    _View? best;
    var bestK = -1.0;
    var bestMove = double.infinity;
    for (final free in frees) {
      if (free.width <= 0 || free.height <= 0) continue;
      if (maxK >= 1 &&
          free.left <= focus.left &&
          free.top <= focus.top &&
          free.right >= focus.right &&
          free.bottom >= focus.bottom) {
        return _View.identity;
      }
      final k = math.min(
        maxK,
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

  /// HTML `#btn-action-observe`, `#btn-action-timer` and
  /// `#btn-action-main` (Finish Observation), each shown at its step.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 0 && s.step == 2 && s.observeStart == null) {
      return [
        LabAction(
          label: _t('btn_observe'),
          icon: Icons.visibility,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _observe,
        ),
      ];
    }
    if (s.scenario == 1 && s.step == 3 && s.timerStart == null) {
      return [
        LabAction(
          label: _t('btn_timer'),
          icon: Icons.timer,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _startTimer,
        ),
      ];
    }
    if (s.step >= _stepCounts[s.scenario]) {
      return [
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.task_alt,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: s.step == _stepCounts[s.scenario],
          silent: true,
          onTap: _finish,
        ),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final sc = context.labScale;
        final data = _scenarioData;
        final s = _scene;
        final n = data.steps.length;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final card = _card(context, MediaQuery.sizeOf(context).height, actions);
        return LabShell(
          controller: _lab,
          icon: Icons.water_drop,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          // HTML `#hud-instruction` (`hud[State.step]`).
          hud: _t('s${s.scenario + 1}_hud_${s.step.clamp(1, n + 1)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch8a3-steps-${s.scenario}-${s.step}'),
            steps: data.steps,
            current: s.step,
            palette: _lab.palette,
            scale: sc,
            fontScale: sc * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
            pendingText: _t('obs_pending'),
          ),
          overlays: [
            // The HTML's buttons sit in the canvas HUD; while the sidebar
            // is open their copy floats at the top of the canvas (the
            // sidebar copy can be below the fold on a phone), under the
            // toast band; the HUD chip has the bottom.
            if (_showCanvasButton(actions))
              Positioned(
                key: const ValueKey('ch8a3-action-button'),
                top: inset.top + _toastBand * sc,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabActionButton(
                    action: actions.first,
                    scale: sc,
                    expand: false,
                  ),
                ),
              ),
            // HTML `#magnifier-view` / `#graph-overlay`, on the right of
            // the canvas (the framing keeps the scene clear of it).
            if (card != null)
              Positioned(
                key: ValueKey('ch8a3-card-${card.kind.name}'),
                top: card.top,
                right: inset.right + _cardGap,
                width: card.size.width,
                height: card.size.height,
                child: card.kind == _Card.magnifier
                    ? _MagnifierCard(
                        label: _t('magnifier_label'),
                        isDark: _lab.isDark,
                        scale: sc,
                      )
                    : _GraphCard(
                        title: _t('graph_title'),
                        yLabel: _t('graph_y'),
                        xLabel: _t('graph_x'),
                        startMass: (_massGlass + _massLid).toStringAsFixed(1),
                        endMass: (_massGlass + _massLid + _massGain)
                            .toStringAsFixed(1),
                        endTime: '$_timerMinutes',
                        isDark: _lab.isDark,
                        scale: sc,
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

/// Label anchors that follow the objects.
_V _glassLabelAt(_V glass) => glass + const _V(0, _glassLabelLift, 0);
_V _magLabelAt(_V magnifier) => magnifier + const _V(0, 3, 0);
_V _lidLabelAt(_V lid) => lid + const _V(0, 2, 0);

/// On the balance the glass's label moves to its left and the lid's to
/// its right (above the glass they would leave the stage).
_V _tumblerSideLabelAt(_V glass) => glass + const _V(-_glassRTop - 0.4, 1.8, 0);
_V _lidSideLabelAt(_V lid) => lid + const _V(_lidR + 0.3, 0, 0);

/// HTML `#magnifier-view`: a round close-up of the droplets with its label
/// (it scales up from 0.5, like the HTML's 0.3 s transition).
class _MagnifierCard extends StatelessWidget {
  const _MagnifierCard({
    required this.label,
    required this.isDark,
    required this.scale,
  });

  final String label;
  final bool isDark;
  final double scale;

  /// HTML `transition: opacity 0.3s, transform 0.3s` from `scale-50`.
  static const Duration _grow = Duration(milliseconds: 300);

  /// The label chip's bottom and widest size (x UI scale) in the
  /// [_magCard] circle.
  static const double _chipBottom = 20;
  static const double _chipWidth = 96;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1),
      duration: _grow,
      curve: Curves.easeOut,
      builder: (context, k, child) => Transform.scale(scale: k, child: child),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? _Colors.viewBorderDark : _Colors.viewBorder,
            width: 4,
          ),
          boxShadow: const [
            BoxShadow(color: LabInk.shadowStrong, blurRadius: 30),
          ],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _DropletsViewPainter(isDark: isDark)),
              // Kept inside the round card: at most two lines, narrower
              // than the circle at that height.
              Positioned(
                left: 0,
                right: 0,
                bottom: _chipBottom * s,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: _chipWidth * s),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * s,
                      vertical: 3 * s,
                    ),
                    decoration: BoxDecoration(
                      color: _Colors.viewChip,
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _Colors.white,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
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

/// HTML `#graph-overlay`: "Mass vs Time" with its axes and the straight
/// rise of the mass (tick values added at both ends).
class _GraphCard extends StatelessWidget {
  const _GraphCard({
    required this.title,
    required this.yLabel,
    required this.xLabel,
    required this.startMass,
    required this.endMass,
    required this.endTime,
    required this.isDark,
    required this.scale,
  });

  final String title;
  final String yLabel;
  final String xLabel;
  final String startMass;
  final String endMass;
  final String endTime;
  final bool isDark;
  final double scale;

  static const Duration _grow = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final muted = isDark ? _Colors.slate400 : _Colors.slate500;
    TextStyle small(Color c) =>
        TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700);
    Widget at(double left, double top, Widget child, {double width = 40}) =>
        Positioned(left: left, top: top, width: width, child: child);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: _grow,
      curve: Curves.easeOut,
      builder: (context, k, child) => Transform.scale(scale: k, child: child),
      child: Container(
        padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 6 * s),
        decoration: BoxDecoration(
          color: isDark ? _Colors.graphBgDark : _Colors.graphBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? _Colors.slate700 : _Colors.slate300,
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
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? _Colors.white : _Colors.slate800,
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4 * s),
            Expanded(
              child: FittedBox(
                child: SizedBox(
                  width: _GraphPainter.width,
                  height: _GraphPainter.height,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _GraphPainter()),
                      ),
                      // Rotated "Mass (g)" along the y axis.
                      Positioned(
                        left: 0,
                        top: _GraphPainter.top,
                        bottom: _GraphPainter.height - _GraphPainter.originY,
                        width: 14,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Center(
                            child: Text(
                              yLabel,
                              maxLines: 1,
                              style: small(muted),
                            ),
                          ),
                        ),
                      ),
                      at(
                        _GraphPainter.originX - 44,
                        _GraphPainter.startY - 6,
                        Text(
                          startMass,
                          textAlign: TextAlign.right,
                          style: small(_Colors.graphLine),
                        ),
                      ),
                      at(
                        _GraphPainter.originX - 44,
                        _GraphPainter.endY - 6,
                        Text(
                          endMass,
                          textAlign: TextAlign.right,
                          style: small(_Colors.graphLine),
                        ),
                      ),
                      at(
                        _GraphPainter.originX - 20,
                        _GraphPainter.originY + 2,
                        Text(
                          '0',
                          textAlign: TextAlign.center,
                          style: small(muted),
                        ),
                      ),
                      at(
                        _GraphPainter.endX - 20,
                        _GraphPainter.originY + 2,
                        Text(
                          endTime,
                          textAlign: TextAlign.center,
                          style: small(muted),
                        ),
                      ),
                      Positioned(
                        left: _GraphPainter.originX,
                        right: 0,
                        top: _GraphPainter.originY + 14,
                        child: Text(
                          xLabel,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: small(muted),
                        ),
                      ),
                    ],
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
/// its task, action and result. The current step is open, done steps show
/// a tick and can be re-opened, future steps are dimmed. A step's result
/// is shown once the step is done (the HTML showed it before the learner
/// had seen it).
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
    // Future steps: dimmed.
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

  /// Thick butt-ended lines (glass shine).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// Round-capped lines (magnifier handle).
  final Paint line = Paint()
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
  /// Object names: bold text on the glass chip (dark / light theme).
  chip,
  chipLight,

  /// Green digits of the balance (HTML `#scale-display`).
  readout;

  TextStyle style(double size) {
    final family = LabFont.active.family;
    final fallback = LabFont.active.fallback;
    return switch (this) {
      _Ink.chip || _Ink.chipLight => TextStyle(
        color: this == _Ink.chip ? _Colors.white : _Colors.slate800,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: family,
        fontFamilyFallback: fallback,
      ),
      _Ink.readout => TextStyle(
        color: _Colors.led,
        fontSize: size * 1.25,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFamily: family,
        fontFamilyFallback: fallback,
        // Digits keep their width while the reading climbs.
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: const [Shadow(color: _Colors.ledGlow, blurRadius: 5)],
      ),
    };
  }
}

/// What the painter makes once and reuses: pens and the text painters of
/// the labels and readouts. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _texts = {};

  LabLang? _lang;
  double _labelSize = _labelPx;

  /// Most text painters kept; the cache is emptied past that.
  static const int _maxTexts = 400;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeTexts();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter text(_Ink ink, String text) {
    final key = '${ink.index}|$text';
    final cached = _texts[key];
    if (cached != null) return cached;
    if (_texts.length >= _maxTexts) _disposeTexts();
    return _texts[key] = TextPainter(
      text: TextSpan(text: text, style: ink.style(_labelSize)),
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

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final k = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * k),
    green: math.min(1.0, c.g * k),
    blue: math.min(1.0, c.b * k),
  );
}

/// [c] lit by the pulsing blue highlight ([amount] 0 … 0.5). The HTML adds
/// it as emissive light, so the colour brightens towards it.
Color _tint(Color c, double amount) => amount <= 0
    ? c
    : Color.from(
        alpha: c.a,
        red: math.min(1.0, c.r + _Colors.glow.r * amount),
        green: math.min(1.0, c.g + _Colors.glow.g * amount),
        blue: math.min(1.0, c.b + _Colors.glow.b * amount),
      );

/// HTML highlight pulse: `(sin(t * 5) + 1) / 2 * 0.5`.
double _pulse(double t) => _glowMax * (math.sin(t * _glowRate) + 1) / 2;

/// Mesh drawing in the scene camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Camera cam;
  final _Pens pens;

  /// BoxGeometry centred at [c], optionally rotated: the faces turned to
  /// the camera (only the +z face with [frontOnly]).
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
    _Rot? rot,
    bool frontOnly = false,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      if (frontOnly && face.normal.z <= 0) continue;
      final n = rot == null ? face.normal : rot.apply(face.normal);
      final mid0 = _V(
        face.normal.x * hx,
        face.normal.y * hy,
        face.normal.z * hz,
      );
      final mid = c + (rot == null ? mid0 : rot.apply(mid0));
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        final local = _V(k.x * hx, k.y * hy, k.z * hz);
        final o = cam.p(c + (rot == null ? local : rot.apply(local)));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
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
            ..color = (edgeColor ?? labShade(color, -0.5)).withValues(
              alpha: edge * opacity,
            ),
        );
      }
    }
  }

  /// The silhouette of an upright CylinderGeometry(rt, rb, h) standing on
  /// [bottom], into [pens.path].
  Path _side(_V bottom, double rb, double rt, double h) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final bottomOval = cam.oval(bottom, rb);
    final topOval = cam.oval(top, rt);
    return pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
  }

  /// Upright closed CylinderGeometry(rt, rb, h) on [bottom]: side lit from
  /// the front, shading bands and the top cap.
  void frustum(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    double opacity = 1,
  }) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final path = _side(bottom, rb, rt, h);
    final side = _lit(color, const _V(0, 0, 1), opacity: opacity);
    canvas.drawPath(path, pens.fill..color = side);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx + wt * 0.45, pt.dy),
      Offset(pb.dx + wb * 0.45, pb.dy + wb),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.34)
        ..color = labShade(side, 0.22),
    );
    canvas.drawLine(
      Offset(pt.dx - wt * 0.8, pt.dy),
      Offset(pb.dx - wb * 0.8, pb.dy + wb),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.4)
        ..color = labShade(side, -0.25),
    );
    canvas.restore();
    final topOval = cam.oval(top, rt);
    canvas.drawOval(
      topOval,
      pens.fill..color = labShade(_lit(color, _V.up, opacity: opacity), 0.12),
    );
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.35).withValues(alpha: 0.6 * opacity),
    );
  }

  /// A see-through glass wall (open CylinderGeometry): tinted fill and, for
  /// the front layer, a shine band and the HTML's edge lines (sides, rim,
  /// front of the bottom).
  void glass(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color,
    double opacity, {
    bool edges = true,
  }) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final path = _side(bottom, rb, rt, h);
    canvas.drawPath(path, pens.fill..color = color.withValues(alpha: opacity));
    if (!edges) return;
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx - wt * 0.55, pt.dy),
      Offset(pb.dx - wb * 0.55, pb.dy + wb),
      pens.bar
        ..strokeWidth = math.max(1.0, wb * 0.16)
        ..color = _Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
    pens.stroke
      ..strokeWidth = 1.2
      ..color = _Colors.glassEdge.withValues(alpha: 0.6);
    canvas.drawLine(
      Offset(pt.dx - wt, pt.dy),
      Offset(pb.dx - wb, pb.dy),
      pens.stroke,
    );
    canvas.drawLine(
      Offset(pt.dx + wt, pt.dy),
      Offset(pb.dx + wb, pb.dy),
      pens.stroke,
    );
    canvas.drawOval(cam.oval(top, rt), pens.stroke);
    canvas.drawArc(cam.oval(bottom, rb), 0, math.pi, false, pens.stroke);
  }

  /// Soft blurred shadow of a round footprint of [radius] on the desk.
  void shadow(_V at, double radius) {
    final c = _V(at.x + 0.3, 0.01, at.z - 0.3);
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

/// Paints the HTML Three.js scene of the current scenario: S1 the ice
/// tray, the glass, the vapour, the droplets and the magnifier; S2 the
/// balance, the glass of ice water and the lid; then the labels, the
/// readouts and the confetti.
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
    g.box(_deskCentre, _deskSize, _Colors.wood, edge: 0);
    if (s.scenario == 0) {
      _paintSweatingGlass(g);
    } else {
      _paintWeighing(g);
    }
    _paintTexts(canvas);
    _paintConfetti(canvas);
  }

  /// Glow amount for [m] (HTML: the active drag target pulses).
  double _glowOf(_Mover m) =>
      identical(scene.activeMover, m) ? _pulse(scene.time) : 0;

  /// The pulsing glow behind an object (HTML emissive highlight).
  void _glow(Canvas canvas, Rect bounds, double amount) {
    if (amount <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.inflate(6), const Radius.circular(14)),
      _pens.glow..color = _Colors.glow.withValues(alpha: amount * 1.2),
    );
  }

  // ------------------------------------------------------------ scenario 1

  void _paintSweatingGlass(_Gfx g) {
    final s = scene;
    final ice = s.mover(_Item.ice);
    final mag = s.mover(_Item.magnifier);
    g.shadow(_V(_glass1.x, 0, _glass1.z), _glassRBottom);
    g.shadow(_V(_trayCentre.x, 0, _trayCentre.z), _traySize.x / 2);
    if (!mag.moving && mag.phase != _Phase.placed) {
      g.shadow(mag.pos, _ringR + _ringTube);
    }
    g.box(_trayCentre, _traySize, _Colors.tray);
    if (!s.iceInGlass && !ice.moving) {
      _paintIceGroup(g, ice.pos, _glowOf(ice));
      // The tray's front wall in front of the cubes sitting in it.
      g.box(_trayCentre, _traySize, _Colors.tray, frontOnly: true);
    }
    final glassDepth = s.cam.depth(_glass1);
    _paintVapour(g, glassDepth, behind: true);
    _paintTumbler(
      g,
      _glass1,
      waterTop: s.waterTop,
      cubes: s.iceInGlass ? s.cubes1 : const [],
      cubeLift: s.cubeLift,
      frost: s.frost,
      glow: 0,
      marker: true,
    );
    if (!mag.moving) _paintMagnifier(g, mag, _glowOf(mag));
    _paintVapour(g, glassDepth, behind: false);
    if (!s.iceInGlass && ice.moving) _paintIceGroup(g, ice.pos, _glowOf(ice));
    if (mag.moving) _paintMagnifier(g, mag, _glowOf(mag));
  }

  /// The three ice cubes of the tray (HTML `iceCubes` group).
  void _paintIceGroup(_Gfx g, _V pos, double glow) {
    _glow(g.canvas, _boxBounds(g.cam, pos, _iceHalf), glow);
    for (final x in _trayCubeX) {
      g.box(
        pos + _V(x, 0, 0),
        const _V(_cube, _cube, _cube),
        _tint(_Colors.ice, glow),
        opacity: 0.85,
        edge: 0.8,
        edgeColor: _Colors.white,
      );
    }
  }

  /// HTML `vapourParticles`, split around the glass so the ones behind it
  /// are drawn first.
  void _paintVapour(_Gfx g, double glassDepth, {required bool behind}) {
    final s = scene;
    final cam = g.cam;
    final paint = _pens.fill..color = _Colors.vapour.withValues(alpha: 0.6);
    for (final p in s.vapour) {
      if (!p.visible) continue;
      if ((cam.depth(p.pos) > glassDepth) != behind) continue;
      g.canvas.drawCircle(
        cam.p(p.pos),
        math.max(1.2, _vapourR * cam.scaleAt(p.pos)),
        paint,
      );
    }
  }

  /// HTML `createTumbler()` with its water, ice cubes, droplets and (S1)
  /// the red water level marker.
  void _paintTumbler(
    _Gfx g,
    _V pos, {
    required double waterTop,
    required List<_Cube> cubes,
    required double cubeLift,
    required double frost,
    required double glow,
    required bool marker,
  }) {
    final canvas = g.canvas;
    final cam = g.cam;
    final bottom = pos - const _V(0, _glassHeight / 2, 0);
    final tint = _tint(
      Color.lerp(_Colors.glass, _Colors.glassCold, frost)!,
      glow,
    );
    final opacity = 0.25 + 0.17 * frost;
    _glow(canvas, _boxBounds(cam, pos, _glassHalf), glow);
    _paintDrops(g, pos, front: false);
    // The far wall, seen through the near one.
    g.glass(
      bottom,
      _glassRBottom,
      _glassRTop,
      _glassHeight,
      tint,
      opacity * 0.5,
      edges: false,
    );
    if (marker) _markerArc(g, pos, front: false);
    final floor = pos + const _V(0, _waterFloor, 0);
    final top = pos.y + waterTop;
    g.frustum(
      floor,
      _waterRBottom,
      _waterRTop,
      top - floor.y,
      _Colors.water,
      opacity: 0.7,
    );
    for (final c in cubes) {
      g.box(
        pos + c.offset + _V(0, cubeLift, 0),
        const _V(_cube, _cube, _cube),
        _Colors.ice,
        opacity: 0.85,
        edge: 0.8,
        edgeColor: _Colors.white,
        rot: c.rot,
      );
    }
    g.frustum(
      bottom,
      _glassRBottom,
      _glassRBottom,
      _baseHeight,
      tint,
      opacity: 0.35,
    );
    g.glass(bottom, _glassRBottom, _glassRTop, _glassHeight, tint, opacity);
    if (marker) _markerArc(g, pos, front: true);
    _paintDrops(g, pos, front: true);
  }

  /// The droplets on the outside of the glass at [pos] (one side).
  void _paintDrops(_Gfx g, _V pos, {required bool front}) {
    final s = scene;
    final cam = g.cam;
    for (var i = 0; i < s.drops.length; i++) {
      final d = s.drops[i];
      if (d.behind == front) continue;
      final k = s.dropScale(i);
      if (k <= 0.001) continue;
      final w = pos + d.local;
      final c = cam.p(w);
      final r = _dropR * k * cam.scaleAt(w);
      g.canvas.drawCircle(
        c,
        r,
        _pens.fill..color = _Colors.water.withValues(alpha: front ? 0.9 : 0.45),
      );
      if (front && r > 1.4) {
        g.canvas.drawCircle(
          c - Offset(r * 0.35, r * 0.35),
          r * 0.35,
          _pens.fill..color = _Colors.white.withValues(alpha: 0.75),
        );
      }
    }
  }

  /// The red marker ring around the glass (its far or near half).
  void _markerArc(_Gfx g, _V pos, {required bool front}) {
    final c = pos + const _V(0, _markerY, 0);
    final oval = g.cam.oval(c, _markerR);
    g.canvas.drawArc(
      oval,
      front ? 0 : math.pi,
      math.pi,
      false,
      _pens.stroke
        ..strokeWidth = math.max(1.6, 0.12 * g.cam.scaleAt(c))
        ..color = _Colors.marker.withValues(alpha: front ? 1 : 0.55),
    );
  }

  /// HTML `magnifier`: ring, lens and handle; lying flat at home, held up
  /// to the glass once placed, where the lens shows the glass and its
  /// droplets enlarged.
  void _paintMagnifier(_Gfx g, _Mover m, double glow) {
    final canvas = g.canvas;
    final cam = g.cam;
    final c = m.pos;
    final (ex, ey) = _magAxes(m.tilt);
    final scale = cam.scaleAt(c);
    final h0 = cam.p(c - ey * _handleFrom);
    final h1 = cam.p(c - ey * _handleTo);
    void handle() => canvas.drawLine(
      h0,
      h1,
      _pens.line
        ..strokeWidth = 2 * _handleR * scale
        ..color = _tint(_lit(_Colors.handle, _V.up), glow),
    );
    final lens = _pens.aux..reset();
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final o = cam.p(
        c + ex * (math.cos(a) * _ringR) + ey * (math.sin(a) * _ringR),
      );
      if (i == 0) {
        lens.moveTo(o.dx, o.dy);
      } else {
        lens.lineTo(o.dx, o.dy);
      }
    }
    lens.close();
    _glow(canvas, _magnifierBounds(cam, c, m.tilt), glow);
    if (m.tilt < 0.5) handle();
    if (m.phase == _Phase.placed) {
      // Through the lens: the side of the glass facing it, with its
      // droplets, the water level and the marker, enlarged over the desk
      // behind it.
      final s = scene;
      final o = cam.p(c);
      final q = cam.p(_lensFocus);
      canvas.save();
      canvas.clipPath(lens);
      canvas.drawPath(lens, _pens.fill..color = _lit(_Colors.wood, _V.up));
      canvas.translate(o.dx, o.dy);
      canvas.scale(_lensZoom);
      canvas.translate(-q.dx, -q.dy);
      _paintTumbler(
        g,
        _glass1,
        waterTop: s.waterTop,
        cubes: s.cubes1,
        cubeLift: s.cubeLift,
        frost: s.frost,
        glow: 0,
        marker: true,
      );
      canvas.restore();
    }
    canvas.drawPath(
      lens,
      _pens.fill..color = _Colors.lens.withValues(alpha: 0.3),
    );
    canvas.drawPath(
      lens,
      _pens.stroke
        ..strokeWidth = 2 * _ringTube * scale
        ..color = _tint(_lit(_Colors.ring, _V.up), glow),
    );
    // Lens shine.
    canvas.drawPath(
      lens,
      _pens.stroke
        ..strokeWidth = 1
        ..color = _Colors.white.withValues(alpha: 0.35),
    );
    if (m.tilt >= 0.5) handle();
  }

  // ------------------------------------------------------------ scenario 2

  void _paintWeighing(_Gfx g) {
    final s = scene;
    final glass = s.mover(_Item.tumbler);
    final lid = s.mover(_Item.lid);
    g.shadow(_V(_balanceCentre.x, 0, _balanceCentre.z), _bodySize.x * 0.55);
    if (glass.phase == _Phase.idle) {
      g.shadow(_V(glass.pos.x, 0, glass.pos.z), _glassRBottom);
    }
    if (lid.phase == _Phase.idle) g.shadow(lid.pos, _lidR);
    // Balance: body, pad and screen.
    g.box(_balanceCentre, _bodySize, _Colors.plastic);
    g.frustum(const _V(0, _padBottom, 0), _padR, _padR, _padH, _Colors.steel);
    g.box(_screenAt, _screenSize, _Colors.screen, edge: 0.6);
    void tumbler() => _paintTumbler(
      g,
      glass.pos,
      waterTop: _waterCentre + _waterHeight / 2,
      cubes: s.cubes2,
      cubeLift: 0,
      frost: s.frost,
      glow: _glowOf(glass),
      marker: false,
    );
    void plate() {
      final glow = _glowOf(lid);
      _glow(g.canvas, _boxBounds(g.cam, lid.pos, _lidHalf), glow);
      g.frustum(
        lid.pos - const _V(0, _lidH / 2, 0),
        _lidR,
        _lidR,
        _lidH,
        _tint(_Colors.steel, glow),
      );
    }

    if (!glass.moving) tumbler();
    if (!lid.moving) plate();
    if (glass.moving) tumbler();
    if (lid.moving) plate();
  }

  // ------------------------------------------------------------------ text

  void _paintTexts(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    var readout = Rect.zero;
    if (s.scenario == 1) {
      // HTML `#scale-overlay` (not a label: always shown). The port shows
      // 0.0 g on the empty balance.
      readout = _readout(
        canvas,
        cam.p(_screenAt),
        '${s.readout.toStringAsFixed(1)} ${_t('unit_g')}',
      );
      if (s.timerStart != null) {
        _chip(
          canvas,
          _boxBounds(cam, s.mover(_Item.lid).pos, _lidHalf).topCenter -
              Offset(0, _timerLift * cache.labelSize),
          labFormat(_t('timer_lbl'), {'m': s.timerMinutes}),
          above: 1,
        );
      }
    }
    if (!showLabels) return;
    if (s.scenario == 0) {
      _chip(canvas, cam.p(_trayLabelAt), _t('lbl_ice'));
      if (s.observeStart == null) {
        _chip(canvas, cam.p(_vapourLabelAt), _t('lbl_vapour'));
      }
      _chip(canvas, cam.p(_glassLabelAt(_glass1)), _t('lbl_glass'));
      _chip(canvas, cam.p(_markerLabelAt), _t('txt_marker'), edge: 1);
      final mag = s.mover(_Item.magnifier);
      if (mag.phase != _Phase.placing && mag.phase != _Phase.placed) {
        _chip(canvas, cam.p(_magLabelAt(mag.pos)), _t('lbl_mag'));
      }
      return;
    }
    final glass = s.mover(_Item.tumbler);
    final lid = s.mover(_Item.lid);
    // On a small phone the names beside the glass and the lid make room
    // for the graph card (see `compactLabels`).
    final side = !s.compactLabels;
    if (glass.phase == _Phase.placed) {
      if (side) {
        _chip(
          canvas,
          cam.p(_tumblerSideLabelAt(glass.pos)),
          _t('lbl_glass'),
          edge: 1,
        );
      }
    } else if (glass.phase != _Phase.placing) {
      _chip(canvas, cam.p(_glassLabelAt(glass.pos)), _t('lbl_glass'));
    }
    if (lid.phase == _Phase.placed) {
      if (side) {
        _chip(canvas, cam.p(_lidSideLabelAt(lid.pos)), _t('lbl_lid'), edge: -1);
      }
    } else if (lid.phase != _Phase.placing) {
      _chip(canvas, cam.p(_lidLabelAt(lid.pos)), _t('lbl_lid'));
    }
    _chip(
      canvas,
      Offset(
        readout.center.dx,
        readout.bottom + _balanceLabelGap * cache.labelSize,
      ),
      _t('lbl_bal'),
      above: -1,
    );
  }

  /// HTML `.label-3d` chip: glass panel with a blue border and bold text
  /// centred on [at]; with [edge] 1 its right edge, with -1 its left edge
  /// sits on [at]; with [above] 1 its bottom edge. Chips are kept left of
  /// the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    double edge = 0,
    double above = 0,
  }) {
    final tp = cache.text(isDark ? _Ink.chip : _Ink.chipLight, text);
    final size = cache.labelSize;
    var rect = _chipBox(at, tp.size, size, edge, above: above);
    if (rect.right > labelRight - 4) {
      rect = rect.shift(Offset(labelRight - 4 - rect.right, 0));
    }
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.labelBg : _Colors.labelBgLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.labelBorder,
    );
    tp.paint(canvas, Offset(rect.left + 0.6 * size, rect.top + 0.3 * size));
  }

  /// HTML `#scale-overlay`: green digits on black with a slate border.
  /// Returns its box.
  Rect _readout(Canvas canvas, Offset at, String text) {
    final tp = cache.text(_Ink.readout, text);
    final size = cache.labelSize;
    final rect = _chipBox(at, tp.size, size, 0);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.3));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.readoutBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.6
        ..color = _Colors.slate600,
    );
    tp.paint(canvas, Offset(rect.left + 0.6 * size, rect.top + 0.3 * size));
    return rect;
  }

  /// HTML `confetti(...)` after the last scenario's Finish.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiStart;
    if (t0 == null) return;
    final ticks = (s.time - t0) * 60;
    if (ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      final x = _confettiOrigin.dx + math.cos(c.angle) * d;
      final y = _confettiOrigin.dy + math.sin(c.angle) * d + fall;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.spin * ticks);
      canvas.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        _pens.fill..color = c.color.withValues(alpha: fade),
      );
      canvas.restore();
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
      old.labelRight != labelRight;
}

/// The SVG of `#magnifier-view` (viewBox 100 × 100): five drop shapes and
/// three round drops with a white-to-blue gradient. Paths and paints are
/// made once; the picture changes only with the theme.
class _DropletsViewPainter extends CustomPainter {
  const _DropletsViewPainter({required this.isDark});

  final bool isDark;

  /// `<path d="M50 10 C50 10, 45 25, 45 30 A 5 5 0 0 0 55 30 C55 25, 50
  /// 10, 50 10 Z" transform="scale(s) translate(tx, ty)">`.
  static final List<Path> _drops = [
    for (final (s, tx, ty) in const [
      (0.8, 10.0, 10.0),
      (1.2, 10.0, 30.0),
      (0.6, 80.0, 50.0),
      (0.9, 60.0, 5.0),
      (1.1, 40.0, 55.0),
    ])
      (Path()
            ..moveTo(50, 10)
            ..cubicTo(50, 10, 45, 25, 45, 30)
            ..arcToPoint(
              const Offset(55, 30),
              radius: const Radius.circular(5),
              clockwise: false,
            )
            ..cubicTo(55, 25, 50, 10, 50, 10)
            ..close())
          .transform(
            (Matrix4.identity()
                  ..scaleByDouble(s, s, 1, 1)
                  ..translateByDouble(tx, ty, 0, 1))
                .storage,
          ),
    for (final (x, y, r) in const [
      (20.0, 40.0, 3.0),
      (80.0, 30.0, 4.0),
      (30.0, 70.0, 2.5),
    ])
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r)),
  ];

  /// `radialGradient cx 30% cy 30% r 70%` over each shape's box.
  static final List<Paint> _fills = [
    for (final p in _drops)
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 0.7,
          colors: [_Colors.dropLight, _Colors.dropDeep],
        ).createShader(p.getBounds()),
  ];

  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5
    ..color = _Colors.sky500;

  static final Paint _bgLight = Paint()..color = _Colors.viewBg;
  static final Paint _bgDark = Paint()..color = _Colors.viewBgDark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, isDark ? _bgDark : _bgLight);
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    for (var i = 0; i < _drops.length; i++) {
      canvas.drawPath(_drops[i], _fills[i]);
      canvas.drawPath(_drops[i], _stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DropletsViewPainter old) =>
      old.isDark != isDark;
}

/// The SVG of `#graph-overlay` (axes and the rising line), widened to make
/// room for the tick values: [width] × [height] px.
class _GraphPainter extends CustomPainter {
  const _GraphPainter();

  static const double width = 230;
  static const double height = 136;

  /// Axes (HTML x 30 … 190, y 10 … 100) and the line (HTML (30, 80) to
  /// (180, 20)).
  static const double originX = 52;
  static const double originY = 104;
  static const double top = 8;
  static const double right = 222;
  static const double startY = 84;
  static const double endX = 206;
  static const double endY = 22;

  static final Paint _axis = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = _Colors.axis;
  static final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..color = _Colors.graphLine;
  static final Paint _dot = Paint()..color = _Colors.graphLine;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      const Offset(originX, top),
      const Offset(originX, originY),
      _axis,
    );
    canvas.drawLine(
      const Offset(originX, originY),
      const Offset(right, originY),
      _axis,
    );
    canvas.drawLine(
      const Offset(originX, startY),
      const Offset(endX, endY),
      _line,
    );
    canvas.drawCircle(const Offset(originX, startY), 3, _dot);
    canvas.drawCircle(const Offset(endX, endY), 3, _dot);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) => false;
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
