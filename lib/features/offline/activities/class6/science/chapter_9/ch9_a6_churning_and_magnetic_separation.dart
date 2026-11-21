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

/// Class 6 Science • Chapter 9 • Activity 6
/// Methods of Separation: Churning & Magnetic Separation.
///
/// Native Flutter port of
/// `Cl6S-Ch9-A6-Churning_and_Magnetic_Separation.html` (Three.js r128 +
/// tween.js). The Three.js scene is redrawn by a small painter that
/// reproduces the HTML camera (position (0, 16, 25), look-at (0, 3, 0),
/// 45° field of view).
///
/// Scenario 1 (The Butter Making of Bhopal): drop the wooden churner
/// (mathni) into the pot of curd, churn until small butter globules
/// appear and then join into lumps that float on the buttermilk, and
/// scoop the butter into a bowl.
///
/// Scenario 2 (The Carpenter's Clever Fix in Shillong): bring a bar magnet
/// to a pile of sawdust with iron nails in it, sweep it over the pile so
/// that every nail jumps onto the magnet, carry the nails over a metal tray
/// and release them there.
class Ch9A6ChurningAndMagneticSeparationPage extends StatefulWidget {
  const Ch9A6ChurningAndMagneticSeparationPage({super.key});

  @override
  State<Ch9A6ChurningAndMagneticSeparationPage> createState() =>
      _SeparationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises four Web-Audio tones
/// in `playSound(type)`; each is played with the closest bundled file:
/// `click` (buttons, picking up, letting go) -> click.mp3 / pickup.mp3 /
/// drop.mp3, `spin` (a short sawtooth buzz on every churning stroke) ->
/// a soft click.mp3 at most every [_spinSoundGap], `snap` (a nail jumps
/// onto the magnet) -> pop.mp3 and `ding` (nails released) ->
/// correct.mp3; its `ding` for the summary is the shell's success.mp3.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pickup → `science/pickup.mp3`, drop → `science/drop.mp3`,
/// spin → `science/click.mp3`, snap → `science/pop.mp3`,
/// ding → `science/correct.mp3`.
enum _Sound implements LabTone {
  /// Generic button click (HTML `click`).
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Positive feedback.
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

  /// An object let go on its target (HTML `click` in `checkDrop`).
  drop('audio/class6/science/drop.mp3'),

  /// HTML `spin`: the churner turning in the curd (quiet, throttled).
  spin('audio/class6/science/click.mp3', 0.3),

  /// HTML `snap`: an iron nail jumps onto the magnet.
  snap('audio/class6/science/pop.mp3', 0.5),

  /// HTML `ding` in `releaseNails()`.
  ding('audio/class6/science/correct.mp3');

  const _Sound(this.asset, [this.volume = 0.6]);
  final String asset;
  final double volume;

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
  static void play(_Sound sound) {
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    unawaited(_play(sound));
  }

  static Future<void> _play(_Sound sound) async {
    try {
      if (_players.isEmpty) await _createPlayers();
      final player = _players[_next];
      _next = (_next + 1) % _players.length;
      await player.stop();
      await player.play(
        AssetSource(sound.asset),
        volume: sound.volume,
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
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA); // highlight emissive
  static const Color blue500 = Color(0xFF3B82F6); // zsl blue, accents
  static const Color blue600 = Color(0xFF2563EB); // action buttons
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
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // tailwind `zsl.dark`
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a, 0xf8fafc in the light theme.
  static const Color sceneBg = slate900;
  static const Color sceneBgLight = slate50;

  /// `materials.tableMat` 0x334155 (Scenario 1) and
  /// `materials.woodBenchMat` 0x5c2b0b (Scenario 2's workbench).
  static const Color table = slate700;
  static const Color bench = Color(0xFF5C2B0B);

  /// `materials.clayMat` 0x9a3412 (earthen pot) and its dark inside.
  static const Color clay = Color(0xFF9A3412);
  static const Color clayInside = Color(0xFF431407);

  /// `materials.woodMat` 0x78350f (churner, scoop).
  static const Color wood = Color(0xFF78350F);

  /// `materials.curdMat` 0xf8fafc and `materials.buttermilkMat` 0xf1f5f9
  /// (opacity 0.85).
  static const Color curd = slate50;
  static const Color buttermilk = Color(0xD9F1F5F9);

  /// `materials.butterMat` 0xfacc15 and a lighter shine.
  static const Color butter = Color(0xFFFACC15);
  static const Color butterShine = Color(0xFFFEF08A);

  /// Bowl: `bowlCeramicMat` 0xf8fafc with `bowlRimMat` 0x3b82f6; the
  /// inside of the bowl is a little darker.
  static const Color ceramic = slate50;
  static const Color ceramicInside = slate200;
  static const Color bowlRim = blue500;

  /// `materials.sawdustMat` 0xd97706 and its grains.
  static const Color sawdust = Color(0xFFD97706);
  static const Color grainDark = Color(0xFF92400E);
  static const Color grainLight = Color(0xFFFBBF24);

  /// `materials.nailMat` 0x334155 (metalness 0.85) and its shine.
  static const Color nail = slate700;
  static const Color nailShine = slate300;

  /// `materials.trayMat` 0xf8fafc (metalness 0.35), drawn a little darker
  /// so it stays visible on the light background.
  static const Color tray = slate300;

  /// `magnetRedMat` 0xdc2626 (N half), `magnetBlueMat` 0x2563eb (S half),
  /// `magnetSilverMat` 0xe2e8f0 (end caps).
  static const Color north = red600;
  static const Color south = blue600;
  static const Color silver = slate200;

  /// Added: the toolbox the HTML text mentions (amber-800 wood).
  static const Color toolbox = Color(0xFF92400E);

  /// `materials.glowMat` 0x3b82f6 (opacity 0.35): the drop-zone rings.
  static const Color zone = blue500;

  /// Pulsing highlight of the object to move (emissive 0x60a5fa).
  static const Color glow = blue400;

  /// `.label-3d` glass chips: `--glass-bg` with a blue-400 border.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBgLight = Color(0xF2FFFFFF);
  static const Color labelBorder = blue400;

  /// Progress counters (the HTML's `counter-text` badge): blue-600 chip.
  static const Color counterBg = Color(0xE62563EB);
  static const Color counterBorder = blue300;

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
    popupHeader: _Colors.blue600,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x801E3A8A), // from-blue-900/50
    curtainText: _Colors.white,
    curtainMuted: Color(0xE693C5FD), // text-blue-300/90
    curtainIcon: _Colors.blue400,
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
    popupHeader: _Colors.blue600,
    dialogBg: _Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x801E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xE693C5FD),
    curtainIcon: _Colors.blue400,
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
/// are the HTML sidebar font size setting: 15 px, slider 12–22 px.
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
// drag, hold or tap on a touch screen and names the buttons by their
// labels; the HUD lines no longer state a result before the learner sees
// it; S2 step 4's result no longer says the magnetism "stops" (a bar
// magnet is permanent: the nails are pulled off it); the Hindi texts drop
// the English words in brackets and spell Malli as in the English text;
// the counters, labels after a change ("with Buttermilk", "Sawdust Pile",
// "Bowl of Butter"), hint toasts and button labels are added keys.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Methods of Separation: Churning & Magnetic Separation',
    'app_subtitle': 'Class 6 • Methods of Separation in Everyday Life',
    'scen_1_opt': 'Scenario 1: The Butter Making of Bhopal (Churning)',
    'scen_2_opt':
        "Scenario 2: The Carpenter's Clever Fix in Shillong (Magnetic Separation)",
    's1_desc':
        'To separate butter from curd using the traditional method of churning, as seen by Malli and Valli.',
    's2_desc':
        'To help the carpenter separate iron nails that have accidentally fallen into a pile of sawdust using a magnet.',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'Position Churner',
    'step_1_1_a':
        'DRAG the wooden churner (mathni) and DROP it into the center of the earthen pot filled with curd.',
    'step_1_1_o': 'The churner snaps into position in the center of the pot.',
    'step_1_2_c': 'Initial Churning',
    'step_1_2_a':
        "PRESS AND HOLD the churner handle (you can also drag it up and down), or tap 'Start Churning', until Churning Progress reaches 100%.",
    'step_1_2_o':
        'The curd swirls rapidly and small yellow globules of fat begin separating and rising slowly.',
    'step_1_3_c': 'Form Butter Lumps',
    'step_1_3_a':
        "Keep churning: keep holding the churner handle, or tap 'Keep Churning', until Churning Progress reaches 100%. Watch the small globules.",
    'step_1_3_o':
        'Small globules coalesce into large, visible yellow lumps of butter floating on the thinner whitish liquid (buttermilk).',
    'step_1_4_c': 'Collect Butter',
    'step_1_4_a':
        'DRAG the butter scoop and DROP it into the pot: it collects the floating butter lumps and carries them to the empty bowl.',
    'step_1_4_o':
        'Butter lumps attach to the scoop and are safely transferred, leaving fresh buttermilk in the pot.',
    'step_1_5_c': 'Principle of Churning',
    'step_1_5_a':
        "Look at the butter in the bowl and the buttermilk in the pot, then tap 'Finish Observation'.",
    'step_1_5_o':
        'Churning separates substances based on density. The lighter (less dense) butter floats to the top when the curd is churned.',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'Bring Magnet Close',
    'step_2_1_a':
        'DRAG the bar magnet from the toolbox and DROP it close to the pile of sawdust and iron nails.',
    'step_2_1_o':
        'The bar magnet moves close to the pile where iron nails are scattered inside the wood sawdust.',
    'step_2_2_c': 'Attract Nails',
    'step_2_2_a':
        'Slowly DRAG the bar magnet over the entire surface of the sawdust pile, until Nails Attracted reaches 100%.',
    'step_2_2_o':
        'As the magnet passes nearby, iron nails jump out of the sawdust and snap firmly onto the magnet!',
    'step_2_3_c': 'Move to Tray',
    'step_2_3_a':
        'DRAG the bar magnet with the attached nails and DROP it over the empty metal tray.',
    'step_2_3_o':
        'The nails remain held by magnetic attraction as you carry them above the collection tray.',
    'step_2_4_c': 'Release Nails',
    'step_2_4_a': "TAP the 'Release Nails into Tray' button.",
    'step_2_4_o':
        'The nails are pulled off the magnet and drop cleanly into the metal tray, leaving the sawdust pile free of nails!',
    'step_2_5_c': 'Principle of Magnetism',
    'step_2_5_a':
        "Look at the sawdust pile and the iron nails in the tray, then tap 'Finish Observation'.",
    'step_2_5_o':
        'Magnetic separation relies on differences in magnetic properties. Iron is attracted to magnets, sawdust is not.',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1':
        'Step 1: DRAG the wooden churner (mathni) from the side and DROP it into the center of the earthen pot.',
    's1_hud_2':
        "Step 2: PRESS AND HOLD the churner handle, or tap 'Start Churning', to churn the curd.",
    's1_hud_3':
        "Step 3: Keep churning (hold the churner or tap 'Keep Churning') until Churning Progress reaches 100%.",
    's1_hud_4':
        'Step 4: DRAG the scoop and DROP it into the pot to collect the floating butter and move it to the empty bowl.',
    's1_hud_5':
        "Step 5: Churning complete! Compare the butter in the bowl with the buttermilk in the pot, then TAP 'Finish Observation'.",
    's2_hud_1':
        'Step 1: DRAG the bar magnet from the toolbox and DROP it close to the pile of sawdust and iron nails.',
    's2_hud_2':
        'Step 2: Slowly DRAG the bar magnet over the entire surface of the sawdust pile to attract the iron nails.',
    's2_hud_3':
        'Step 3: All iron nails are stuck to the magnet! DRAG the magnet and DROP it over the empty metal tray.',
    's2_hud_4':
        "Step 4: TAP the 'Release Nails into Tray' button to drop the iron nails into the metal tray.",
    's2_hud_5':
        "Step 5: Magnetic separation complete! Compare the sawdust pile with the nails in the tray, then TAP 'Finish Observation'.",
    // ------------------------------------------------------------ buttons
    'btn_churn_start': 'Start Churning',
    'btn_churn_keep': 'Keep Churning',
    'btn_churn_stop': 'Stop Churning',
    'btn_release': 'Release Nails into Tray',
    'btn_finish': 'Finish Observation',
    // --------------------------------------- counters (HTML `cnt_*` keys)
    'cnt_churn': 'Churning Progress: {p}%',
    'cnt_iron': 'Nails Attracted: {p}%',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task Focus',
    'action': 'Task Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'Complete this step to see the result.',
    // ------------------------------------------------------------ summary
    'success_title': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    's1_summary_head': 'Butter Harvested Successfully!',
    's1_summary':
        'You performed Churning! Agitating curd causes lighter fat globules to coalesce and float on top of the heavier buttermilk.',
    's2_summary_head': 'Nails Recovered Successfully!',
    's2_summary':
        'You used Magnetic Separation! Bar magnets attract magnetic materials like iron nails while leaving non-magnetic sawdust behind.',
    // ------------------------------------------------------ scene labels
    'lbl_mathani': 'Wooden Churner (Mathni)',
    'lbl_matka': 'Earthen Pot with Curd',
    'lbl_matka_bm': 'Earthen Pot with Buttermilk',
    'lbl_spoon': 'Butter Scoop',
    'lbl_bowl': 'Empty Butter Bowl',
    'lbl_bowl_full': 'Bowl of Butter',
    'lbl_magnet': 'Bar Magnet',
    'lbl_tray': 'Metal Tray',
    'lbl_sawdust': 'Sawdust & Nails Pile',
    'lbl_sawdust_clean': 'Sawdust Pile',
    // ---------------------------------------------------- toasts (added)
    'miss_churner':
        'Let go of the churner right over the mouth of the earthen pot.',
    'miss_scoop':
        'Let go of the scoop right over the pot, where the butter floats.',
    'miss_pile':
        'Let go of the bar magnet close to the pile of sawdust and nails.',
    'miss_tray': 'Let go of the bar magnet right over the metal tray.',
    'first_churner': 'First drag the churner into the earthen pot.',
    'first_churn': 'First finish churning the curd.',
    'first_release':
        "Tap 'Release Nails into Tray' to drop the nails into the tray.",
    'scene_s1':
        'Table with an earthen pot of curd, a wooden churner, a butter scoop and an empty bowl.',
    'scene_s2':
        'Workbench with a pile of sawdust mixed with iron nails, a bar magnet on a toolbox and an empty metal tray.',
  },
  'hi': {
    'app_title': 'पृथक्करण की विधियाँ: मंथन और चुंबकीय पृथक्करण',
    'app_subtitle': 'कक्षा 6 • दैनिक जीवन में पृथक्करण की विधियाँ',
    'scen_1_opt': 'परिदृश्य 1: भोपाल में मक्खन बनाना (मंथन विधि)',
    'scen_2_opt': 'परिदृश्य 2: शिलांग में बढ़ई की समझदारी (चुंबकीय पृथक्करण)',
    's1_desc':
        'मल्ली और वल्ली द्वारा देखी गई पारंपरिक मंथन विधि का उपयोग करके दही से मक्खन को अलग करना।',
    's2_desc':
        'बढ़ई को लकड़ी के बुरादे में गिरी लोहे की कीलों को छड़ चुंबक की सहायता से अलग करने में मदद करना।',
    // ------------------------------------------------- scenario 1 steps
    'step_1_1_c': 'मथानी डालना',
    'step_1_1_a': 'लकड़ी की मथानी को खींचकर दही से भरे मटके के बीच में छोड़ें।',
    'step_1_1_o': 'मथानी मटके के बीच में सही स्थान पर सेट हो जाती है।',
    'step_1_2_c': 'प्रारंभिक मंथन',
    'step_1_2_a':
        "मथानी के हत्थे को दबाए रखें (आप उसे ऊपर-नीचे भी खींच सकते हैं) या 'मथना शुरू करें' दबाएँ, जब तक मंथन प्रगति 100% न हो जाए।",
    'step_1_2_o':
        'दही तेजी से घूमता है और पीले रंग के छोटे मक्खन कण अलग होकर धीरे-धीरे ऊपर आने लगते हैं।',
    'step_1_3_c': 'मक्खन के गोले बनना',
    'step_1_3_a':
        "मथते रहें: मथानी के हत्थे को दबाए रखें या 'मथना जारी रखें' दबाएँ, जब तक मंथन प्रगति 100% न हो जाए। छोटे कणों को ध्यान से देखें।",
    'step_1_3_o':
        'छोटे कण आपस में जुड़कर मक्खन के बड़े पीले गोले बन जाते हैं, जो पतले सफेद द्रव (छाछ) के ऊपर तैरते हैं।',
    'step_1_4_c': 'मक्खन इकट्ठा करना',
    'step_1_4_a':
        'मक्खन वाले चम्मच को खींचकर मटके में छोड़ें: यह तैरते मक्खन के गोलों को इकट्ठा करके खाली कटोरे में ले जाता है।',
    'step_1_4_o':
        'मक्खन के गोले चम्मच पर आकर कटोरे में पहुँच जाते हैं और मटके में ताज़ी छाछ बचती है।',
    'step_1_5_c': 'मंथन का सिद्धांत',
    'step_1_5_a':
        "कटोरे में मक्खन और मटके में छाछ को देखें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    'step_1_5_o':
        'मंथन घनत्व के अंतर पर आधारित है। मथने पर हल्का (कम घनत्व वाला) मक्खन ऊपर आकर तैरता है।',
    // ------------------------------------------------- scenario 2 steps
    'step_2_1_c': 'चुंबक पास लाना',
    'step_2_1_a':
        'टूलबॉक्स से छड़ चुंबक को खींचकर बुरादे और लोहे की कीलों के ढेर के पास छोड़ें।',
    'step_2_1_o':
        'चुंबक लकड़ी के बुरादे और लोहे की कीलों के मिश्रण के पास पहुँचता है।',
    'step_2_2_c': 'कीलों का आकर्षण',
    'step_2_2_a':
        "छड़ चुंबक को बुरादे के पूरे ढेर के ऊपर धीरे-धीरे खींचें, जब तक 'आकर्षित कीलें' 100% न हो जाए।",
    'step_2_2_o':
        'चुंबक के पास आते ही लोहे की कीलें बुरादे से उछलकर चुंबक से मजबूती से चिपक जाती हैं!',
    'step_2_3_c': 'ट्रे तक ले जाना',
    'step_2_3_a':
        'कीलों से चिपके छड़ चुंबक को खींचकर खाली धातु की ट्रे के ऊपर छोड़ें।',
    'step_2_3_o':
        'ट्रे के ऊपर ले जाते समय भी लोहे की कीलें चुंबकीय आकर्षण के कारण चुंबक से चिपकी रहती हैं।',
    'step_2_4_c': 'कीलें छोड़ना',
    'step_2_4_a': "'कीलों को ट्रे में छोड़ें' बटन दबाएँ।",
    'step_2_4_o':
        'कीलों को चुंबक से खींचकर अलग किया जाता है और वे धातु की ट्रे में गिर जाती हैं; बुरादे के ढेर में अब कोई कील नहीं बचती!',
    'step_2_5_c': 'चुंबकत्व का सिद्धांत',
    'step_2_5_a':
        "बुरादे के ढेर और ट्रे में रखी लोहे की कीलों को देखें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    'step_2_5_o':
        'चुंबकीय पृथक्करण चुंबकीय गुणों के अंतर पर काम करता है। चुंबक लोहे को आकर्षित करता है, बुरादे को नहीं।',
    // ---------------------------------------------- HUD ("Current Task")
    's1_hud_1': 'चरण 1: लकड़ी की मथानी को खींचकर मटके के बीच में छोड़ें।',
    's1_hud_2':
        "चरण 2: दही मथने के लिए मथानी के हत्थे को दबाए रखें या 'मथना शुरू करें' दबाएँ।",
    's1_hud_3':
        "चरण 3: मंथन प्रगति 100% होने तक मथते रहें (मथानी दबाए रखें या 'मथना जारी रखें' दबाएँ)।",
    's1_hud_4':
        'चरण 4: चम्मच को खींचकर मटके में छोड़ें, ताकि तैरता मक्खन खाली कटोरे में पहुँचे।',
    's1_hud_5':
        "चरण 5: मंथन पूर्ण! कटोरे के मक्खन और मटके की छाछ की तुलना करें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    's2_hud_1':
        'चरण 1: टूलबॉक्स से छड़ चुंबक को खींचकर बुरादे और कीलों के ढेर के पास छोड़ें।',
    's2_hud_2':
        'चरण 2: लोहे की कीलों को आकर्षित करने के लिए चुंबक को बुरादे के पूरे ढेर के ऊपर धीरे-धीरे खींचें।',
    's2_hud_3':
        'चरण 3: सभी कीलें चुंबक से चिपक गई हैं! चुंबक को खींचकर खाली धातु की ट्रे के ऊपर छोड़ें।',
    's2_hud_4':
        "चरण 4: कीलों को ट्रे में गिराने के लिए 'कीलों को ट्रे में छोड़ें' बटन दबाएँ।",
    's2_hud_5':
        "चरण 5: चुंबकीय पृथक्करण पूर्ण! बुरादे के ढेर और ट्रे की कीलों की तुलना करें, फिर 'अवलोकन समाप्त करें' दबाएँ।",
    // ------------------------------------------------------------ buttons
    'btn_churn_start': 'मथना शुरू करें',
    'btn_churn_keep': 'मथना जारी रखें',
    'btn_churn_stop': 'मथना रोकें',
    'btn_release': 'कीलों को ट्रे में छोड़ें',
    'btn_finish': 'अवलोकन समाप्त करें',
    // ----------------------------------------------------------- counters
    'cnt_churn': 'मंथन प्रगति: {p}%',
    'cnt_iron': 'आकर्षित कीलें: {p}%',
    // ------------------------------------------------------------ sidebar
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य फोकस',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'परिणाम देखने के लिए यह चरण पूरा करें।',
    // ------------------------------------------------------------ summary
    'success_title': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_summary_head': 'मक्खन तैयार!',
    's1_summary':
        'आपने मंथन विधि का उपयोग किया! दही को मथने से वसा (मक्खन) के हल्के कण आपस में जुड़कर भारी छाछ के ऊपर तैरने लगते हैं।',
    's2_summary_head': 'कीलें अलग हुईं!',
    's2_summary':
        'आपने चुंबकीय पृथक्करण का उपयोग किया! छड़ चुंबक लोहे की कीलों जैसी चुंबकीय वस्तुओं को आकर्षित करता है और अचुंबकीय बुरादे को पीछे छोड़ देता है।',
    // ------------------------------------------------------ scene labels
    'lbl_mathani': 'लकड़ी की मथानी',
    'lbl_matka': 'दही का मटका',
    'lbl_matka_bm': 'छाछ का मटका',
    'lbl_spoon': 'मक्खन चम्मच (स्कूप)',
    'lbl_bowl': 'मक्खन का खाली कटोरा',
    'lbl_bowl_full': 'मक्खन का कटोरा',
    'lbl_magnet': 'छड़ चुंबक',
    'lbl_tray': 'धातु की ट्रे',
    'lbl_sawdust': 'बुरादा व कीलों का ढेर',
    'lbl_sawdust_clean': 'बुरादे का ढेर',
    // ------------------------------------------------------------- toasts
    'miss_churner': 'मथानी को ठीक मटके के मुँह के ऊपर छोड़ें।',
    'miss_scoop': 'चम्मच को ठीक मटके के ऊपर छोड़ें, जहाँ मक्खन तैर रहा है।',
    'miss_pile': 'छड़ चुंबक को बुरादे और कीलों के ढेर के पास छोड़ें।',
    'miss_tray': 'छड़ चुंबक को ठीक धातु की ट्रे के ऊपर छोड़ें।',
    'first_churner': 'पहले मथानी को खींचकर मटके में डालें।',
    'first_churn': 'पहले दही को मथना पूरा करें।',
    'first_release':
        "कीलें ट्रे में गिराने के लिए 'कीलों को ट्रे में छोड़ें' दबाएँ।",
    'scene_s1':
        'मेज़ पर दही का मटका, लकड़ी की मथानी, मक्खन चम्मच और एक खाली कटोरा।',
    'scene_s2':
        'कार्य मेज़ पर लोहे की कीलों वाला बुरादे का ढेर, टूलबॉक्स पर रखा छड़ चुंबक और एक खाली धातु की ट्रे।',
  },
};

/// Steps of each scenario (HTML `steps` arrays: five each).
const int _stepCount = 5;
const int _scenarioCount = 2;

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
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
/// (0, 16, 25) looking at (0, 3, 0). (On narrower screens the HTML pulls
/// back to (0, 24, 34); the stage framing below fits the scene to the
/// free canvas instead.)
const _V _eye = _V(0, 16, 25);
const _V _lookAt = _V(0, 3, 0);

/// HTML lights: `AmbientLight(0xffffff, 0.85)` and `DirectionalLight(
/// 0xffffff, 0.7)` at (12, 28, 18). Three.js r128 adds them linearly and
/// clips at white, which washes the lit faces out; both are scaled by
/// [_lightScale].
const double _lightScale = 0.75;
const double _ambient = 0.85 * _lightScale;
const double _diffuse = 0.7 * _lightScale;

/// (12, 28, 18) normalised.
const _V _light = _V(0.3392, 0.7914, 0.5087);

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

// ------------------------------------------------------------ animations

/// HTML tweens: an object snaps into place in 400 ms (TWEEN's default
/// Linear easing); the scoop crosses to the bowl in 500 ms.
const double _placeSeconds = 0.4;
const double _toBowlSeconds = 0.5;

/// Churning speed in percent per second. The HTML adds 1.8 % per frame
/// (or per pointer move), so a step took 0.5–0.9 s depending on the
/// screen's frame rate; two seconds per step leave time to watch the
/// globules form.
const double _churnRate = 50;

/// HTML `animate()`: the churner turns 0.45 rad per frame (27 rad/s at
/// 60 fps) and bobs at `7.3 + |sin(t · 12)| · 1.5` around its resting
/// height of 7.5.
const double _churnSpin = 27;
const double _bobRate = 12;
const double _bobAmp = 1.5;
const double _bobBase = -0.2;

/// The HTML `spin` tone sounds on every churning increment; here at most
/// this often (s).
const double _spinSoundGap = 0.25;

/// Shortest gap (s) between two `snap` tones while nails jump onto the
/// magnet.
const double _snapSoundGap = 0.08;

/// HTML `checkMagnetAttraction`: an attracted nail sits on the magnet at
/// once; here it jumps there in 150 ms.
const double _nailJump = 0.15;

/// HTML `releaseNails()`: nail i leaves after i x 25 ms and lands in the
/// tray 400 ms later; the magnet goes home 300 ms after the last one
/// left, in 600 ms.
const double _nailStagger = 0.025;
const double _nailFall = 0.4;
const double _releasePause = 0.3;
const double _magnetHomeSeconds = 0.6;

/// HTML: the step moves on 400 ms after the last nail is attracted.
const Duration _allNailsDelay = Duration(milliseconds: 400);

/// HTML highlight: emissive towards 0x60a5fa by `pulse · 0.85`, `pulse =
/// (sin(Date.now() · 0.008) + 1) / 2`. Kept to half strength: added to a
/// 2D fill the full value washed the object out.
const double _glowRate = 8;
const double _glowMax = 0.5;

/// Drop-zone rings pulse between these opacities (HTML: a steady 0.35).
const double _zoneAlphaMin = 0.25;
const double _zoneAlphaMax = 0.45;

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

/// `BoxGeometry(36, 1.5, 20)` table / workbench with its top at y = 0.
const _V _tableCentre = _V(0, -0.75, 0);
const _V _tableSize = _V(36, 1.5, 20);

/// Objects stay on the table while dragged.
const double _tableX = 17;
const double _tableZ = 9;
const double _carryMaxY = 16;

// ------------------------------------------------------------ scenario 1

/// Earthen pot (`matkaS1` at x = -3): `SphereGeometry(4.5)` belly centred
/// at y 4.2 and an open `CylinderGeometry(3.5, 3.2, 1.2)` neck at y 8.5
/// (7.9 … 9.1). The HTML's closed sphere hid most of the curd; here the
/// pot is open and the curd fills its mouth.
const double _potX = -3;
const _V _bellyCentre = _V(_potX, 4.2, 0);
const double _bellyR = 4.5;
const double _neckBottom = 7.9;
const double _neckTop = 9.1;
const double _neckR = 3.2;
const double _mouthR = 3.5;

/// Curd: `CylinderGeometry(3.3, 3.3, 0.4)` at y 8.0 (its top at 8.2).
const double _curdY = 8.2;
const double _curdR = 3.3;

/// Wooden churner (`mathaniS1`): a pole of radius 0.25 and a
/// `BoxGeometry(2.4, 0.8, 2.4)` head 2.5 below the group origin. The HTML
/// pole ran from 3 below to 9 above the origin and stuck out of the top of
/// the view once in the pot; here it ends 7 above. At home it stands on
/// the table (the HTML floated it 1 unit above).
const double _poleBottom = -3;
const double _poleTop = 7;
const double _poleR = 0.25;
const double _headY = -2.5;
const _V _headSize = _V(2.4, 0.8, 2.4);
const _V _churnerHome = _V(-13.5, 3, 4);

/// The camera looks at the pot's mouth almost edge-on (15° above it), so
/// the curd and the butter forming on it would be a thin sliver; the
/// mouth, the curd and the ring over it are drawn opened up this much.
const double _mouthOpen = 1.8;

/// In the pot: the HTML tween to (-3, 7.5, 0) put the head 5 above the
/// table; here the head sits 3 above it, inside the belly.
const _V _churnerRest = _V(_potX, 5.5, 0);

/// Where the learner holds the churner: this far up the pole.
const double _churnerGrabY = 4.5;

/// While churning by hand the churner sways with the finger, damped as in
/// the HTML (x 0.2), at most this far from the centre of the pot.
const double _swayDamping = 0.2;
const double _swayMax = 0.6;

/// HTML `mathaniZoneS1`: `RingGeometry(2.0, 4.8)` at (-3, 9.3, 0). The
/// churner counts as in the pot when its foot is let go inside the ring.
const _V _churnerZone = _V(_potX, 9.3, 0);
const double _churnerZoneIn = 2.0;
const double _churnerZoneOut = 4.8;

/// Butter scoop (`spoonS1`): a `SphereGeometry(1.1)` scaled (1.4, 0.35,
/// 1.4) at the end of a 7.5-long handle tilted 60°. Positions here are
/// the scoop's own. The HTML laid it at (-7.8, 0.7, -5), right behind the
/// pot, where the pot hid it; here it lies further left and back, and the
/// churner stands a little further left so the two do not cross.
const _V _scoopHome = _V(-12, 0.4, -7.5);
const _V _scoopHandle = _V(-6.495, 3.75, 0);
const _V _scoopRadii = _V(1.54, 0.385, 1.54);
const double _handleR = 0.18;

/// The scoop dips into the butter beside the churner, then carries it
/// over the bowl (HTML tweens to (-3, 8.5, 0) and (7, 4.5, 0)).
const _V _scoopOverPot = _V(-1.6, 8.7, 0.8);
const _V _scoopOverBowl = _V(7, 4.3, 0);

/// HTML `spoonZoneS1`: `RingGeometry(2.5, 5.5)` at (-3, 9.6, 0).
const _V _scoopZone = _V(_potX, 9.6, 0);
const double _scoopZoneIn = 2.5;
const double _scoopZoneOut = 5.5;

/// Butter bowl (`butterBowlS1` at x = 7): blue `CylinderGeometry(3.0,
/// 3.2, 0.4)` foot, open white `CylinderGeometry(4.4, 3.0, 3.0)` wall from
/// y 0.2, blue `TorusGeometry(4.4, 0.22)` rim at 3.2 and the butter: a
/// `SphereGeometry(2.8)` scaled (1.25, 0.55, 1.25) at y 1.8.
const double _bowlX = 7;
const double _bowlFootR = 3.2;
const double _bowlFootH = 0.4;
const double _bowlBottomR = 3.0;
const double _bowlWallFrom = 0.2;
const double _bowlRimY = 3.2;
const double _bowlRimR = 4.4;
const double _bowlRimTube = 0.22;
const _V _bowlButter = _V(_bowlX, 1.8, 0);
const _V _bowlButterRadii = _V(3.5, 1.54, 3.5);

/// Butter: 25 small globules (`SphereGeometry(0.18 … 0.30)`, x / z within
/// ±2.1), globule i shown once the progress passes i x 4 %; 6 lumps
/// (`SphereGeometry(0.65 … 1.0)` scaled (1.3, 0.6, 1.2), x / z within
/// ±1.6), lump i once it passes i x 15 % in step 3.
const int _globuleCount = 25;
const double _globuleEvery = 4;
const double _globuleSpread = 2.1;
const int _lumpCount = 6;
const double _lumpEvery = 15;
const double _lumpSpread = 1.6;

/// A free spot on the table (used by the flows for a drop that misses).
const _V _openS1 = _V(6, 1, 7);

// ------------------------------------------------------------ scenario 2

/// Sawdust pile: `ConeGeometry(5.5, 2.4)` on the bench at (-4, 0, 0).
const _V _pileCentre = _V(-4, 0, 0);
const double _pileR = 5.5;
const double _pileH = 2.4;

/// Sawdust grains drawn on the pile (texture).
const int _grainCount = 70;

/// 32 iron nails (`CylinderGeometry(0.06, 0.02, 0.9)` shaft and a
/// `CylinderGeometry(0.16, 0.16, 0.08)` head) scattered within 3.8 of the
/// pile's centre, on its surface.
const int _nailCount = 32;
const double _nailHalf = 0.45;
const double _nailHeadR = 0.16;
const double _nailScatter = 3.8;

/// Bar magnet (`magnetS2`): red N half (+x) and blue S half
/// (`BoxGeometry(3.5, 1.2, 1.6)`), silver end caps (`BoxGeometry(0.4,
/// 1.22, 1.62)`) at x = ±3.5. At home it lies on the toolbox.
const _V _magnetHome = _V(-13, 3.5, 4);
const _V _halfSize = _V(3.5, 1.2, 1.6);
const _V _capSize = _V(0.4, 1.22, 1.62);
const double _magnetHalfLength = 3.5;
const _V _magnetHalf = _V(3.7, 0.61, 0.81);

/// HTML drag plane: horizontal through the magnet (y = 3.5); the magnet
/// is shown at 4.0 (step 1), 3.5 (step 2, over the pile) and 4.5 (step 3,
/// carrying the nails).
const double _magnetPlaneY = 3.5;
const double _carryY1 = 4.0;
const double _carryY2 = 3.5;
const double _carryY3 = 4.5;
const _V _magnetAtPile = _V(-4, 3.5, 0);
const _V _magnetOverTray = _V(8, 4.5, 0);

/// A nail jumps onto the magnet when the bar passes within this distance
/// of it (horizontally, from the bar's centre line). The HTML attracted
/// every nail within 4.5 of the magnet's centre, so the first touch over
/// the middle of the pile took all 32 at once.
const double _attractReach = 1.6;

/// Attracted nails hang from the bar's underside towards its ends, where
/// a bar magnet pulls hardest: 1.5 … 3.4 from the centre.
const double _attachMin = 1.5;
const double _attachSpan = 1.9;
const double _attachHang = -1.05;
const double _attachDepth = 1.2;

/// HTML drop tests, fixed: the magnet counts as close to the pile, or over
/// the tray, inside the HTML's glow rings (`RingGeometry(3, 7)` at the
/// pile and at the tray). The HTML also accepted anything right of
/// x = -11.5 (the pile) or x = 5 (the tray), and the magnet's home was
/// already within its 11.5 radius of the pile.
const double _zoneIn = 3.0;
const double _zoneOut = 7.0;

/// Height the Scenario 2 rings are drawn at (just above the bench).
const double _ringY = 0.02;

/// Added: the toolbox the HTML text names ("from the toolbox"); the
/// magnet lies on it.
const _V _toolboxCentre = _V(-13, 1.45, 4);
const _V _toolboxSize = _V(8.8, 2.9, 2.8);

/// Metal tray (`trayS2` at (8, 0.1, 0)): `BoxGeometry(11, 0.4, 10)` base
/// and 0.4-thick, 1.2-high walls.
const _V _trayCentre = _V(8, 0.1, 0);
const _V _trayBase = _V(11, 0.4, 10);
const double _trayWall = 0.4;
const double _trayWallH = 1.2;

/// Nails land in the tray within x ±4, z ±3.5 of its centre, 0.4 … 0.7
/// above it (HTML `(idx % 3) * 0.15`).
const double _trayScatterX = 8;
const double _trayScatterZ = 7;
const double _trayNailY = 0.4;
const double _trayNailStep = 0.15;

/// A free spot on the bench (used by the flows for a drop that misses).
const _V _openS2 = _V(-14, 3.5, -6);

/// Label anchors.
const _V _potLabelAt = _V(_potX + _mouthR + 0.6, _neckTop, 0);
const _V _bowlLabelAt = _V(_bowlX, 0, _bowlFootR + 1.2);
const _V _pileLabelAt = _V(-4, 0, 6.3);
const _V _trayLabelAt = _V(8, 0, 5.6);

/// Label chips sit this many label sizes from what they name.
const double _labelGap = 0.35;

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
  _V withY(double v) => _V(x, v, z);

  /// Horizontal (x, z) distance to [o].
  double xzTo(_V o) => math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Rotation about the vertical axis (the churner's head as it turns).
_V _yaw(_V v, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V(c * v.x + s * v.z, v.y, -s * v.x + c * v.z);
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

/// Bounds of the screen segment [a]–[b] widened by [half] on every side.
Rect _segmentBounds(Offset a, Offset b, double half) =>
    Rect.fromPoints(a, b).inflate(half);

/// Distance from [p] to the screen segment [a]–[b].
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

/// A scene label chip: the box of text [text] (laid out) at [at]; with
/// [edge] 1 its right edge, with -1 its left edge sits on [at]; with
/// [above] 1 its bottom edge, with -1 its top edge does.
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

// ------------------------------------------------------------------ tweens

/// One tween.js tween (Linear easing): [apply] receives the progress 0..1
/// from [start] (scene seconds) on.
class _Tween {
  _Tween({
    required this.start,
    required this.duration,
    required this.apply,
    this.onComplete,
  });

  final double start;
  final double duration;
  final void Function(double k) apply;
  final VoidCallback? onComplete;

  /// Applies the tween at [now]; true once it has finished.
  bool update(double now) {
    if (now < start) return false;
    final k = ((now - start) / duration).clamp(0.0, 1.0);
    apply(k);
    return k >= 1;
  }
}

// ------------------------------------------------------------- scene model

/// The objects the learner drags (HTML `activeDragTarget`s).
enum _Obj { churner, scoop, magnet }

/// Where an iron nail is.
enum _NailState { pile, jumping, held, falling, tray }

/// One iron nail (HTML `ironNailsS2` child).
class _Nail {
  _Nail({
    required this.pile,
    required this.pileAxis,
    required this.attachMag,
    required this.attachZ,
    required this.attachAxis,
    required this.tray,
    required this.trayAxis,
  });

  /// In the pile: centre and shaft direction (head end).
  final _V pile;
  final _V pileAxis;

  /// On the magnet: distance from the bar's centre, depth offset and
  /// direction (hanging, head up).
  final double attachMag;
  final double attachZ;
  final _V attachAxis;

  /// In the tray: centre and direction (lying flat).
  final _V tray;
  final _V trayAxis;

  _NailState state = _NailState.pile;

  /// Which end of the bar it hangs from (-1 S, +1 N).
  double side = 1;

  /// Scene time the jump or the fall began.
  double since = 0;

  /// Start of the fall.
  _V from = _V.zero;

  _V get attach => _V(side * attachMag, _attachHang, attachZ);
}

/// Mutable scene read by the painter every frame.
class _Scene {
  _Scene() {
    final rnd = math.Random(96);
    for (var i = 0; i < _globuleCount; i++) {
      globules.add((
        x: (rnd.nextDouble() - 0.5) * 2 * _globuleSpread,
        z: (rnd.nextDouble() - 0.5) * 2 * _globuleSpread,
        r: 0.18 + rnd.nextDouble() * 0.12,
      ));
    }
    for (var i = 0; i < _lumpCount; i++) {
      lumps.add((
        x: (rnd.nextDouble() - 0.5) * 2 * _lumpSpread,
        z: (rnd.nextDouble() - 0.5) * 2 * _lumpSpread,
        r: 0.65 + rnd.nextDouble() * 0.35,
      ));
    }
    for (var i = 0; i < _nailCount; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final radius = rnd.nextDouble() * _nailScatter;
      final h = math.max(
        0.2,
        2.2 - (radius / _pileR) * 2.2 + (rnd.nextDouble() - 0.5) * 0.3,
      );
      _V axis(double maxTilt) {
        final tilt = rnd.nextDouble() * maxTilt;
        final heading = rnd.nextDouble() * math.pi * 2;
        return _V(
          math.sin(tilt) * math.cos(heading),
          math.cos(tilt),
          math.sin(tilt) * math.sin(heading),
        );
      }

      final pileAxis = axis(1.2);
      final attachMag = _attachMin + rnd.nextDouble() * _attachSpan;
      final attachZ = (rnd.nextDouble() - 0.5) * _attachDepth;
      final attachAxis = axis(0.35);
      final trayX = (rnd.nextDouble() - 0.5) * _trayScatterX;
      final trayZ = (rnd.nextDouble() - 0.5) * _trayScatterZ;
      final flat = rnd.nextDouble() * math.pi;
      nails.add(
        _Nail(
          pile: _V(
            _pileCentre.x + math.cos(angle) * radius,
            h,
            math.sin(angle) * radius,
          ),
          pileAxis: pileAxis,
          attachMag: attachMag,
          attachZ: attachZ,
          attachAxis: attachAxis,
          tray:
              _trayCentre +
              _V(trayX, _trayNailY + (i % 3) * _trayNailStep, trayZ),
          trayAxis: _V(math.sin(flat), 0.08, math.cos(flat)).unit,
        ),
      );
    }
    // Far nails first (the camera never changes direction).
    pileOrder = List.generate(_nailCount, (i) => i)
      ..sort(
        (a, b) => _baseCam
            .depth(nails[b].pile)
            .compareTo(_baseCam.depth(nails[a].pile)),
      );
    for (var i = 0; i < _grainCount; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * _pileR * 0.95;
      grains.add((
        x: _pileCentre.x + math.cos(a) * d,
        z: math.sin(a) * d,
        dark: rnd.nextBool(),
      ));
    }
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add((
        angle: -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
        velocity:
            (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
            _confettiSpeed,
        color: _Colors.confetti[i % _Colors.confetti.length],
        spin: (rnd.nextDouble() - 0.5) * 0.4,
      ));
    }
  }

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; 6 once Finish Observation was tapped).
  int step = 1;

  /// Bumped on every load, so a gesture or timer from before cannot touch
  /// the new scene.
  int generation = 0;

  final List<_Tween> tweens = [];

  final List<({double x, double z, double r})> globules = [];
  final List<({double x, double z, double r})> lumps = [];
  final List<_Nail> nails = [];
  late final List<int> pileOrder;
  final List<({double x, double z, bool dark})> grains = [];
  final List<({double angle, double velocity, Color color, double spin})>
  confetti = [];

  // ----------------------------------------------------------- scenario 1

  _V churner = _churnerHome;
  _V scoop = _scoopHome;

  /// The churner stands in the pot (step 1 done).
  bool churnerIn = false;

  /// HTML `State.churnProgress` (0 … 100, reset when step 3 begins).
  double progress = 0;

  /// The churner is held on the canvas, or 'Start Churning' is on.
  bool churnHeld = false;
  bool churnToggle = false;

  /// The churner's turn (rad) and bob while churning.
  double spin = 0;
  double bob = 0;

  /// How far the finger sways the churner in the pot.
  _V sway = _V.zero;

  /// Visible globules and lumps (HTML `sp.visible` / `lb.visible`).
  final List<bool> globuleOn = List.filled(_globuleCount, false);
  final List<bool> lumpOn = List.filled(_lumpCount, false);

  /// The curd has turned into buttermilk (HTML `curdS1.material`).
  bool buttermilk = false;

  /// The butter rides on the scoop / sits in the bowl.
  bool butterOnScoop = false;
  bool butterInBowl = false;

  double lastSpinSound = -1;

  // ----------------------------------------------------------- scenario 2

  _V magnet = _magnetHome;

  /// The nails are being released (HTML `State.isAnimating`).
  bool releasing = false;
  double lastSnapSound = -1;

  /// The step-3 move is scheduled once every nail is on the magnet.
  bool allAttracted = false;

  double? confettiStart;

  final _Camera cam = _Camera(_eye, _lookAt);
  _View view = _View.identity;
  _View viewTarget = _View.identity;

  /// The next framing jumps to its target instead of sliding.
  bool snapView = true;

  /// An object glides somewhere or the nails fall (HTML
  /// `State.isAnimating`).
  bool get busy => tweens.isNotEmpty || releasing;

  /// The churner is turning (held or switched on, in step 2 or 3).
  bool get churning =>
      scenario == 0 &&
      churnerIn &&
      (step == 2 || step == 3) &&
      (churnHeld || churnToggle) &&
      !busy;

  /// The object the current step asks the learner to move (HTML
  /// `getNextStepDraggable`), glowing while it waits.
  _Obj? get active {
    if (busy) return null;
    if (scenario == 0) {
      if (step >= 1 && step <= 3) return _Obj.churner;
      if (step == 4) return _Obj.scoop;
      return null;
    }
    return step >= 1 && step <= 3 ? _Obj.magnet : null;
  }

  // ------------------------------------------ derived (also read by tests)

  int get globulesShown => globuleOn.where((v) => v).length;
  int get lumpsShown => lumpOn.where((v) => v).length;

  /// HTML counters: `Churning Progress` and `Nails Attracted` (percent).
  int get churnPercent => math.min(100, progress.floor());
  int get nailsOnMagnet => nails
      .where((n) => n.state == _NailState.jumping || n.state == _NailState.held)
      .length;
  int get nailsInPile => nails.where((n) => n.state == _NailState.pile).length;
  int get nailsInTray => nails.where((n) => n.state == _NailState.tray).length;
  int get attractedPercent =>
      ((_nailCount - nailsInPile) * 100 / _nailCount).floor();
  bool get magnetHome => magnet.xzTo(_magnetHome) < 0.01;

  /// World position of nail [n] now.
  _V nailPos(_Nail n) {
    switch (n.state) {
      case _NailState.pile:
        return n.pile;
      case _NailState.jumping:
        final k = ((time - n.since) / _nailJump).clamp(0.0, 1.0);
        return _V.lerp(n.pile, magnet + n.attach, k);
      case _NailState.held:
        return magnet + n.attach;
      case _NailState.falling:
        final k = ((time - n.since) / _nailFall).clamp(0.0, 1.0);
        return _V.lerp(n.from, n.tray, k);
      case _NailState.tray:
        return n.tray;
    }
  }

  /// Shaft direction of nail [n] now.
  _V nailAxis(_Nail n) => switch (n.state) {
    _NailState.pile => n.pileAxis,
    _NailState.jumping || _NailState.held => n.attachAxis,
    _NailState.falling =>
      time - n.since < _nailFall / 2 ? n.attachAxis : n.trayAxis,
    _NailState.tray => n.trayAxis,
  };

  /// The point of the churner the learner holds.
  _V get churnerGrab => churner + const _V(0, _churnerGrabY, 0);

  /// The churner's foot (bottom of the pole).
  _V get churnerFoot => churner + const _V(0, _poleBottom, 0);

  /// Design-space position of a named scene point (used by the flows):
  /// the objects ('churner', 'scoop', 'magnet'), where to drag the current
  /// object to drop it on its target ('pot', 'pile', 'tray') or on a free
  /// spot ('open'), and 'bowl'.
  Offset anchor(String id) {
    switch (id) {
      case 'churner':
        return cam.p(churnerGrab);
      case 'scoop':
        return cam.p(scoop);
      case 'magnet':
        return cam.p(magnet);
      case 'pot':
        return step == 4
            ? _dropAnchor(cam.p(scoop), scoop, scoop, _scoopZone)
            : _dropAnchor(
                cam.p(churnerGrab),
                churner,
                churnerFoot,
                _churnerZone,
              );
      case 'pile':
        return cam.p(_pileCentre.withY(_magnetPlaneY));
      case 'tray':
        return cam.p(_trayCentre.withY(_magnetPlaneY));
      case 'bowl':
        return cam.p(_bowlButter);
      case 'open':
        return cam.p(scenario == 0 ? _openS1 : _openS2);
    }
    return cam.p(_lookAt);
  }

  /// Where to move a finger that pressed [grab] on an object at [pos]
  /// (dragged on the camera-facing plane through it) so that its point
  /// [tip] lands on [target] on screen.
  Offset _dropAnchor(Offset grab, _V pos, _V tip, _V target) {
    final at = cam.onPlane(grab, pos, cam.f);
    final want = cam.onPlane(cam.p(target), tip, cam.f);
    if (at == null || want == null) return cam.p(target);
    return cam.p(at + (want - tip));
  }

  /// Design-space points for sweeping the magnet over the whole pile
  /// (used by the flows): rows across the pile from the magnet.
  List<Offset> sweep() => [
    cam.p(magnet.withY(_magnetPlaneY)),
    for (final (x0, x1, z) in const [
      (-1.0, -8.0, -2.6),
      (-8.0, 0.0, -2.6),
      (0.0, -8.0, 0.0),
      (-8.0, 0.0, 2.6),
      (0.0, -8.0, 2.6),
      (-8.0, -4.0, 0.0),
    ]) ...[
      cam.p(_V(x0, _magnetPlaneY, z)),
      cam.p(_V((x0 + x1) / 2, _magnetPlaneY, z)),
      cam.p(_V(x1, _magnetPlaneY, z)),
    ],
  ];

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    generation++;
    scenario = index;
    step = 1;
    tweens.clear();
    churner = _churnerHome;
    scoop = _scoopHome;
    churnerIn = false;
    progress = 0;
    churnHeld = false;
    churnToggle = false;
    spin = 0;
    bob = 0;
    sway = _V.zero;
    globuleOn.fillRange(0, _globuleCount, false);
    lumpOn.fillRange(0, _lumpCount, false);
    buttermilk = false;
    butterOnScoop = false;
    butterInBowl = false;
    lastSpinSound = -1;
    magnet = _magnetHome;
    releasing = false;
    lastSnapSound = -1;
    allAttracted = false;
    for (final n in nails) {
      n
        ..state = _NailState.pile
        ..since = 0
        ..from = _V.zero
        ..side = 1;
    }
    confettiStart = null;
    snapView = true;
  }

  /// Adds a tween that starts after [delay] seconds.
  void tween(
    double seconds,
    void Function(double k) apply, {
    double delay = 0,
    VoidCallback? onComplete,
  }) {
    tweens.add(
      _Tween(
        start: time + delay,
        duration: seconds,
        apply: apply,
        onComplete: onComplete,
      ),
    );
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
  _Grab({
    required this.obj,
    required this.offset,
    required this.plane,
    required this.normal,
    required this.generation,
    required this.step,
    this.churn = false,
  });

  final _Obj obj;

  /// Drag-plane hit minus the object's position at pointer-down.
  final _V offset;

  /// A point of the drag plane and its normal.
  final _V plane;
  final _V normal;
  final int generation;

  /// The step the object was picked up in.
  final int step;

  /// The churner is held to churn (steps 2 and 3).
  final bool churn;
}

class _SeparationLabState extends State<Ch9A6ChurningAndMagneticSeparationPage>
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

  /// HTML `animate()` (`TWEEN.update()`, the churning loop), then one
  /// repaint of the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    s.view = s.view.toward(s.viewTarget, 1 - math.exp(-dt / _viewSmoothing));
    s.cam.frame(s.view);
    final before = (s.step, s.busy, s.churnToggle);
    _advanceTweens();
    if (s.scenario == 0) {
      _advanceChurn(dt);
    } else {
      _advanceNails();
    }
    if ((s.step, s.busy, s.churnToggle) != before) _refresh();
    _frame.value = now;
  }

  void _advanceTweens() {
    final s = _scene;
    if (s.tweens.isEmpty) return;
    final finished = <_Tween>[];
    for (final tw in List.of(s.tweens)) {
      if (tw.update(s.time)) finished.add(tw);
    }
    s.tweens.removeWhere(finished.contains);
    for (final tw in finished) {
      tw.onComplete?.call();
    }
  }

  /// HTML `animate()` + `handleChurnProgress()`: while the churner is held
  /// or switched on it turns and bobs and the progress grows.
  void _advanceChurn(double dt) {
    final s = _scene;
    if (!s.churnerIn) return;
    if (s.churning) {
      s.spin += _churnSpin * dt;
      s.bob = _bobBase + (math.sin(s.time * _bobRate)).abs() * _bobAmp;
      if (s.time - s.lastSpinSound >= _spinSoundGap) {
        s.lastSpinSound = s.time;
        _Sound.spin.play();
      }
      _churn(_churnRate * dt);
    } else {
      // Settles back to rest (HTML: back to (-3, 7.5, 0) on pointer up).
      s.bob *= math.max(0.0, 1 - dt * 10);
    }
    if (_grab?.churn != true) {
      s.sway = s.sway * math.max(0.0, 1 - dt * 10);
    }
    s.churner = _churnerRest + s.sway + _V(0, s.bob, 0);
  }

  /// HTML `handleChurnProgress()`: step 2 shows the small globules, step 3
  /// turns the curd into buttermilk and joins the globules into lumps.
  void _churn(double add) {
    final s = _scene;
    s.progress += add;
    if (s.step == 2) {
      for (var i = 0; i < _globuleCount; i++) {
        if (s.progress > i * _globuleEvery) s.globuleOn[i] = true;
      }
      if (s.progress >= 100) {
        s
          ..progress = 0
          ..step = 3
          // The button stops so the learner sees the globules; holding the
          // churner keeps churning, as in the HTML.
          ..churnToggle = false;
        _Sound.correct.play();
      }
    } else if (s.step == 3) {
      s.buttermilk = true;
      for (var i = 0; i < _lumpCount; i++) {
        if (s.progress > i * _lumpEvery) {
          s.lumpOn[i] = true;
          if (i * 4 + 1 < _globuleCount) {
            s.globuleOn[i * 4] = false;
            s.globuleOn[i * 4 + 1] = false;
          }
        }
      }
      if (s.progress >= 100) {
        s.globuleOn.fillRange(0, _globuleCount, false);
        s
          ..progress = 100
          ..step = 4
          ..churnToggle = false
          ..churnHeld = false;
        _Sound.correct.play();
      }
    }
  }

  /// Nails that finished jumping or falling change state.
  void _advanceNails() {
    final s = _scene;
    for (final n in s.nails) {
      if (n.state == _NailState.jumping && s.time - n.since >= _nailJump) {
        n.state = _NailState.held;
      } else if (n.state == _NailState.falling &&
          s.time - n.since >= _nailFall) {
        n.state = _NailState.tray;
      }
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)` (selector, Enter Lab, Reset): stops every
  /// pending timer and tween and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `#btn-churn` (hold to churn): here a switch, since the shell's
  /// buttons are tapped; holding the churner on the canvas also churns.
  void _toggleChurn() {
    final s = _scene;
    if (s.scenario != 0 || !s.churnerIn || s.busy) return;
    if (s.step != 2 && s.step != 3) return;
    setState(() => s.churnToggle = !s.churnToggle);
  }

  /// HTML `releaseNails()`: the nails drop into the tray one after the
  /// other, then the magnet goes back to the toolbox.
  void _releaseNails() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4 || s.busy) return;
    _Sound.ding.play();
    setState(() {
      s.releasing = true;
      for (var i = 0; i < s.nails.length; i++) {
        final n = s.nails[i];
        n
          ..from = s.nailPos(n)
          ..since = s.time + i * _nailStagger
          ..state = _NailState.falling;
      }
      final from = s.magnet;
      s.tween(
        _magnetHomeSeconds,
        (k) => s.magnet = _V.lerp(from, _magnetHome, k),
        delay: _nailCount * _nailStagger + _releasePause,
        onComplete: () {
          s
            ..releasing = false
            ..step = 5;
        },
      );
    });
  }

  /// HTML `triggerMainAction()`: the summary popup (and confetti after the
  /// last scenario). Tapped again later, it re-opens the summary.
  void _finish() {
    final s = _scene;
    final sc = s.scenario;
    if (s.step < _stepCount || s.busy) return;
    if (s.step == _stepCount) {
      setState(() {
        s.step = _stepCount + 1;
        if (sc == _scenarioCount - 1) s.confettiStart = s.time;
      });
    }
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: _summaryDelay,
      title: () => _t('success_title'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () =>
          '${_t('s${sc + 1}_summary_head')}\n\n${_t('s${sc + 1}_summary')}',
    );
  }

  // -------------------------------------------------------------- gestures

  /// May [obj] be picked up (or, the churner in the pot, held) now?
  bool _unlocked(_Obj obj) {
    final s = _scene;
    if (s.busy) return false;
    return switch (obj) {
      _Obj.churner =>
        s.scenario == 0 &&
            ((s.step == 1 && !s.churnerIn) ||
                ((s.step == 2 || s.step == 3) && s.churnerIn)),
      _Obj.scoop => s.scenario == 0 && s.step == 4,
      _Obj.magnet => s.scenario == 1 && s.step >= 1 && s.step <= 3,
    };
  }

  /// Is [at] (design px) on [obj]?
  bool _hits(_Obj obj, Offset at) {
    final s = _scene;
    final cam = s.cam;
    switch (obj) {
      case _Obj.churner:
        if (s.scenario != 0) return false;
        final foot = s.churnerIn
            ? _potPoint(cam, s.churner.withY(_curdY))
            : cam.p(s.churnerFoot);
        final top = cam.p(s.churner + const _V(0, _poleTop, 0));
        final reach = math.max(_touch, _poleR * cam.scaleAt(s.churner) + 4);
        if (_segmentDistance(at, foot, top) <= reach) return true;
        if (s.churnerIn) return false;
        return _boxBounds(
          cam,
          s.churner + const _V(0, _headY, 0),
          _headSize * 0.5,
        ).inflate(4).contains(at);
      case _Obj.scoop:
        if (s.scenario != 0) return false;
        final a = cam.p(s.scoop), b = cam.p(s.scoop + _scoopHandle);
        if (_segmentDistance(at, a, b) <= _touch) return true;
        return cam
            .oval(s.scoop, _scoopRadii.x)
            .inflate(_touch / 2)
            .contains(at);
      case _Obj.magnet:
        if (s.scenario != 1) return false;
        final b = _boxBounds(cam, s.magnet, _magnetHalf);
        return Rect.fromCenter(
          center: b.center,
          width: math.max(b.width, 2 * _touch),
          height: math.max(b.height, 2 * _touch),
        ).contains(at);
    }
  }

  /// The object under [at]: the one the step asks for first.
  _Obj? _hitTest(Offset at) {
    _Obj? other;
    for (final obj in _Obj.values) {
      if (!_hits(obj, at)) continue;
      if (_unlocked(obj)) return obj;
      other ??= obj;
    }
    return other;
  }

  /// HTML `pointerdown`: only on a scene object.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grab != null || _scene.busy) return false;
    return _hitTest(event.localPosition) != null;
  }

  /// What the current step asks for, for an object touched before its
  /// turn (added; the HTML ignored such touches).
  String? _notYetKey(_Obj obj) {
    final s = _scene;
    if (obj == _Obj.scoop && s.step == 1) return 'first_churner';
    if (obj == _Obj.scoop && (s.step == 2 || s.step == 3)) {
      return 'first_churn';
    }
    if (obj == _Obj.magnet && s.step == 4) return 'first_release';
    return null;
  }

  /// HTML `startDrag`.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final obj = _hitTest(d.localPosition);
    if (obj == null) return;
    if (!_unlocked(obj)) {
      final key = _notYetKey(obj);
      if (key != null) _lab.showToast(_t(key), isError: true);
      return;
    }
    final cam = s.cam;
    switch (obj) {
      case _Obj.churner when s.churnerIn:
        // Steps 2 and 3: holding the churner churns (HTML drag mode).
        final at = cam.onPlane(d.localPosition, s.churnerGrab, _V.up);
        _grab = _Grab(
          obj: obj,
          offset: at == null ? _V.zero : at - _churnerRest,
          plane: s.churnerGrab,
          normal: _V.up,
          generation: s.generation,
          step: s.step,
          churn: true,
        );
        setState(() => s.churnHeld = true);
      case _Obj.churner:
      case _Obj.scoop:
        final pos = obj == _Obj.churner ? s.churner : s.scoop;
        final at = cam.onPlane(d.localPosition, pos, cam.f);
        _grab = _Grab(
          obj: obj,
          offset: at == null ? _V.zero : at - pos,
          plane: pos,
          normal: cam.f,
          generation: s.generation,
          step: s.step,
        );
        _Sound.pickup.play();
      case _Obj.magnet:
        final plane = s.magnet.withY(_magnetPlaneY);
        final at = cam.onPlane(d.localPosition, plane, _V.up);
        _grab = _Grab(
          obj: obj,
          offset: at == null ? _V.zero : (at - plane).withY(0),
          plane: plane,
          normal: _V.up,
          generation: s.generation,
          step: s.step,
        );
        _Sound.pickup.play();
    }
  }

  /// HTML `pointermove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final g = _grab;
    if (g == null || g.generation != s.generation) return;
    final hit = s.cam.onPlane(d.localPosition, g.plane, g.normal);
    if (hit == null) return;
    final p = hit - g.offset;
    switch (g.obj) {
      case _Obj.churner when g.churn:
        // HTML: the churner stays in the pot, swaying 0.2 of the drag.
        final dx = ((p.x - _churnerRest.x) * _swayDamping).clamp(
          -_swayMax,
          _swayMax,
        );
        final dz = ((p.z - _churnerRest.z) * _swayDamping).clamp(
          -_swayMax,
          _swayMax,
        );
        s.sway = _V(dx, 0, dz);
      case _Obj.churner:
        s.churner = _clampCarry(p);
      case _Obj.scoop:
        s.scoop = _clampCarry(p);
      case _Obj.magnet:
        final y = switch (s.step) {
          1 => _carryY1,
          2 => _carryY2,
          _ => _carryY3,
        };
        s.magnet = _V(
          p.x.clamp(-_tableX, _tableX),
          y,
          p.z.clamp(-_tableZ, _tableZ),
        );
        if (s.step == 2) _attract();
    }
  }

  _V _clampCarry(_V p) => _V(
    p.x.clamp(-_tableX, _tableX),
    p.y.clamp(0.0, _carryMaxY),
    p.z.clamp(-_tableZ, _tableZ),
  );

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` + `checkDrop()`.
  void _release() {
    final s = _scene;
    final g = _grab;
    _grab = null;
    if (g == null || g.generation != s.generation) return;
    switch (g.obj) {
      case _Obj.churner when g.churn:
        setState(() => s.churnHeld = false);
      case _Obj.churner:
        _dropChurner();
      case _Obj.scoop:
        _dropScoop();
      case _Obj.magnet:
        _dropMagnet(g.step);
    }
  }

  /// Is the screen point of [tip] inside the drop-zone ring at [zone]
  /// (outer radius [radius])?
  bool _inZone(_V tip, _V zone, double radius) {
    final cam = _scene.cam;
    final o = _openOval(cam, zone, radius, _mouthOpen);
    final q = cam.p(tip);
    final rx = o.width / 2, ry = o.height / 2;
    final dx = (q.dx - o.center.dx) / rx, dy = (q.dy - o.center.dy) / ry;
    return dx * dx + dy * dy <= 1;
  }

  /// S1 step 1: the churner's foot let go inside the ring over the pot
  /// slides into the pot; anywhere else it goes back with a hint.
  void _dropChurner() {
    final s = _scene;
    final from = s.churner;
    if (s.step == 1 && _inZone(s.churnerFoot, _churnerZone, _churnerZoneOut)) {
      _Sound.drop.play();
      setState(
        () => s.tween(
          _placeSeconds,
          (k) => s.churner = _V.lerp(from, _churnerRest, k),
          onComplete: () {
            s
              ..churnerIn = true
              ..step = 2;
          },
        ),
      );
      return;
    }
    _lab.showToast(_t('miss_churner'), isError: true);
    setState(
      () => s.tween(
        _placeSeconds,
        (k) => s.churner = _V.lerp(from, _churnerHome, k),
      ),
    );
  }

  /// S1 step 4: the scoop let go inside the ring over the pot collects the
  /// butter and carries it to the bowl (HTML tweens); anywhere else it
  /// goes back with a hint.
  void _dropScoop() {
    final s = _scene;
    final from = s.scoop;
    if (s.step == 4 && _inZone(s.scoop, _scoopZone, _scoopZoneOut)) {
      _Sound.drop.play();
      setState(
        () => s.tween(
          _placeSeconds,
          (k) => s.scoop = _V.lerp(from, _scoopOverPot, k),
          onComplete: () {
            s.lumpOn.fillRange(0, _lumpCount, false);
            s.butterOnScoop = true;
            s.tween(
              _toBowlSeconds,
              (k) => s.scoop = _V.lerp(_scoopOverPot, _scoopOverBowl, k),
              onComplete: () {
                s
                  ..butterOnScoop = false
                  ..butterInBowl = true;
                _Sound.snap.play();
                s.tween(
                  _placeSeconds,
                  (k) => s.scoop = _V.lerp(_scoopOverBowl, _scoopHome, k),
                  onComplete: () => s.step = 5,
                );
              },
            );
          },
        ),
      );
      return;
    }
    _lab.showToast(_t('miss_scoop'), isError: true);
    setState(
      () =>
          s.tween(_placeSeconds, (k) => s.scoop = _V.lerp(from, _scoopHome, k)),
    );
  }

  /// S2 steps 1 and 3: close to the pile / over the tray the magnet snaps
  /// into place; anywhere else it goes back (home / to the pile) with a
  /// hint. Let go during the sweep (step 2) it stays where it is.
  void _dropMagnet(int pickedUpIn) {
    final s = _scene;
    final from = s.magnet;
    void glide(_V to, {VoidCallback? then}) => setState(
      () => s.tween(
        _placeSeconds,
        (k) => s.magnet = _V.lerp(from, to, k),
        onComplete: then,
      ),
    );
    switch (s.step) {
      case 1:
        if (s.magnet.xzTo(_pileCentre) < _zoneOut) {
          _Sound.drop.play();
          glide(_magnetAtPile, then: () => s.step = 2);
        } else {
          _lab.showToast(_t('miss_pile'), isError: true);
          glide(_magnetHome);
        }
      case 3:
        if (s.magnet.xzTo(_trayCentre) < _zoneOut) {
          _Sound.drop.play();
          glide(_magnetOverTray, then: () => s.step = 4);
        } else if (pickedUpIn == 3) {
          _lab.showToast(_t('miss_tray'), isError: true);
          glide(_magnetAtPile);
        } else {
          // Still held from the sweep when the last nail jumped on.
          setState(() => s.magnet = s.magnet.withY(_carryY3));
        }
    }
  }

  /// HTML `checkMagnetAttraction()`: nails close to the bar jump onto it,
  /// at the nearer end; once all are on, step 3 follows 400 ms later.
  void _attract() {
    final s = _scene;
    final m = s.magnet;
    var any = false;
    for (final n in s.nails) {
      if (n.state != _NailState.pile) continue;
      final dx = math.max(0.0, (n.pile.x - m.x).abs() - _magnetHalfLength);
      final dz = n.pile.z - m.z;
      if (dx * dx + dz * dz > _attractReach * _attractReach) continue;
      n
        ..state = _NailState.jumping
        ..since = s.time
        ..side = n.pile.x >= m.x ? 1 : -1;
      any = true;
    }
    if (!any) return;
    if (s.time - s.lastSnapSound >= _snapSoundGap) {
      s.lastSnapSound = s.time;
      _Sound.snap.play();
    }
    if (s.nailsInPile == 0 && !s.allAttracted) {
      s.allAttracted = true;
      final gen = s.generation;
      _lab.after(_allNailsDelay, () {
        if (!mounted || s.generation != gen || s.step != 2) return;
        _Sound.correct.play();
        setState(() => s.step = 3);
      });
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

  /// Fits the scene (objects and labels) into the part of the canvas no
  /// shell card covers: the tool column, the HUD chip (sidebar open), the
  /// canvas action button and the floating mission card (sidebar
  /// collapsed: the scene moves below it or, if that would shrink it more,
  /// to its right). Returns the framing in design px for a canvas of
  /// [canvas] dp at stage scale [fit].
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
    final right = canvas.width - insets.right;
    final base = Rect.fromLTRB(
      _cardGap + (open ? 0 : pad.left),
      _topClear(context, actions),
      right,
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
    return _fit(areas);
  }

  /// The largest framing that fits the focus into one of [areas]. Labels
  /// keep their size while the scene is scaled by k, so they are measured
  /// 1 / k larger.
  _View _fit(List<Rect> areas) {
    final whole = _fitView(_focusRect(1), areas, 1);
    if (whole.k >= 1) return whole;
    for (var k = 1 - _viewKStep; k > _minViewK; k -= _viewKStep) {
      final view = _fitView(_focusRect(1 / k), areas, k);
      if (view.k >= k - 1e-6) return view;
    }
    return _fitView(_focusRect(1 / _minViewK), areas, _minViewK);
  }

  /// Bounds (unframed design px) of what the learner touches and reads in
  /// the current scenario: every place an object goes and the labels and
  /// counters, the labels [grow] times their size. The focus stays the same
  /// through a scenario, so the scene does not move between steps.
  Rect _focusRect(double grow) {
    final s = _scene;
    final cam = _baseCam;
    final size = _labelSize;
    _cache.prepare(_lab.lang, size);
    Rect? r;
    void add(Rect x) => r = r == null ? x : r!.expandToInclude(x);
    void chip(
      Offset at,
      String text, {
      double edge = 0,
      double above = 0,
      _Ink ink = _Ink.chip,
    }) {
      final tp = _cache.text(ink, text);
      add(_chipBox(at, tp.size * grow, size * grow, edge, above: above));
    }

    if (s.scenario == 0) {
      // The pot and the churner standing in it (at the top of its bob).
      add(_potBounds(cam));
      final inPot = _churnerRest + const _V(0, _bobBase + _bobAmp, 0);
      add(
        _segmentBounds(
          cam.p(inPot.withY(_curdY)),
          cam.p(inPot + const _V(0, _poleTop, 0)),
          _poleR * cam.scaleAt(inPot),
        ),
      );
      chip(_churnerPotLabelAt(cam, _churnerRest), _t('lbl_mathani'), edge: 1);
      // The churner at home.
      add(_churnerBounds(cam, _churnerHome));
      chip(_churnerHomeLabelAt(cam, _churnerHome), _t('lbl_mathani'), above: 1);
      // The pot's label and the counter under it.
      final potLabel = _chipBox(
        cam.p(_potLabelAt),
        _cache.text(_Ink.chip, _t('lbl_matka')).size * grow,
        size * grow,
        -1,
      );
      add(potLabel);
      chip(
        Offset(potLabel.left, potLabel.top - _labelGap * size * grow),
        labFormat(_t('cnt_churn'), {'p': 100}),
        edge: -1,
        above: 1,
        ink: _Ink.counter,
      );
      // The scoop at home and over the bowl, the bowl.
      add(_scoopBounds(cam, _scoopHome));
      chip(_scoopLabelAt(cam, _scoopHome), _t('lbl_spoon'), above: 1);
      add(_scoopBounds(cam, _scoopOverBowl));
      add(_bowlBounds(cam));
      chip(cam.p(_bowlLabelAt), _t('lbl_bowl'), above: -1);
    } else {
      add(_boxBounds(cam, _toolboxCentre, _toolboxSize * 0.5));
      add(_boxBounds(cam, _magnetHome, _magnetHalf));
      chip(_magnetLabelAt(cam, _magnetHome), _t('lbl_magnet'), above: 1);
      add(cam.oval(_pileCentre, _pileR));
      final pileLabel = _chipBox(
        cam.p(_pileLabelAt),
        _cache.text(_Ink.chip, _t('lbl_sawdust')).size * grow,
        size * grow,
        0,
        above: -1,
      );
      add(pileLabel);
      chip(
        Offset(pileLabel.center.dx, pileLabel.bottom + _labelGap * size * grow),
        labFormat(_t('cnt_iron'), {'p': 100}),
        above: -1,
        ink: _Ink.counter,
      );
      add(_boxBounds(cam, _trayCentre + const _V(0, 0.6, 0), _trayHalf));
      chip(cam.p(_trayLabelAt), _t('lbl_tray'), above: -1);
      // The magnet carrying the nails over the tray.
      add(
        _boxBounds(
          cam,
          _magnetOverTray + const _V(0, -0.8, 0),
          const _V(3.8, 1.5, 1.2),
        ),
      );
      chip(_magnetLabelAt(cam, _magnetOverTray), _t('lbl_magnet'), above: 1);
    }
    return r ?? Offset.zero & _design;
  }

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
      // Scaled about the focus centre, then pushed inside the free area;
      // a scene that had to shrink is centred in it.
      final c = focus.center;
      var dx = c.dx * (1 - k);
      var dy = c.dy * (1 - k);
      if (k < maxK) {
        dx = free.center.dx - c.dx * k;
        dy = free.center.dy - c.dy * k;
      } else {
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
      }
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

  /// HTML `#btn-churn`, `#btn-release-nails` and `#btn-action-main`
  /// (Finish Observation), each shown at its step.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 0 &&
        s.churnerIn &&
        (s.step == 2 || s.step == 3) &&
        !s.busy) {
      final on = s.churnToggle;
      return [
        LabAction(
          label: _t(
            on
                ? 'btn_churn_stop'
                : (s.step == 2 ? 'btn_churn_start' : 'btn_churn_keep'),
          ),
          icon: on ? Icons.stop_circle : Icons.autorenew,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: !on,
          onTap: _toggleChurn,
        ),
      ];
    }
    if (s.scenario == 1 && s.step == 4 && !s.busy) {
      return [
        LabAction(
          label: _t('btn_release'),
          icon: Icons.arrow_downward,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          silent: true,
          onTap: _releaseNails,
        ),
      ];
    }
    if (s.step >= _stepCount) {
      return [
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.arrow_forward,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: s.step == _stepCount,
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
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.blender,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          // HTML `#hud-instruction` (`hud[State.step]`).
          hud: _t('s${s.scenario + 1}_hud_${s.step.clamp(1, _stepCount)}'),
          actions: actions,
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch9a6-steps-${s.scenario}-${s.step}'),
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
                key: const ValueKey('ch9a6-action-button'),
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

// ------------------------------------------------- shared scene geometry

/// Half sizes of the tray with its walls.
const _V _trayHalf = _V(5.5, 0.6, 5);

/// Projected bounds of the pot (belly and neck).
Rect _potBounds(_Camera cam) {
  final c = cam.p(_bellyCentre);
  final r = _bellyR * cam.scaleAt(_bellyCentre);
  return Rect.fromCircle(
    center: c,
    radius: r,
  ).expandToInclude(_potOval(cam, _neckTop, _mouthR));
}

/// The horizontal circle of [radius] at [c] as a screen rect, its height
/// times [open].
Rect _openOval(_Camera cam, _V c, double radius, double open) {
  final o = cam.oval(c, radius);
  return Rect.fromCenter(
    center: o.center,
    width: o.width,
    height: o.height * open,
  );
}

/// A circle of [radius] at height [y] round the pot's axis, opened up.
Rect _potOval(_Camera cam, double y, double radius) =>
    _openOval(cam, _V(_potX, y, 0), radius, _mouthOpen);

/// A point at height [w.y] inside the pot, on the opened-up surface.
Offset _potPoint(_Camera cam, _V w) {
  final o = cam.p(w);
  final c = cam.p(_V(_potX, w.y, 0));
  return Offset(o.dx, c.dy + (o.dy - c.dy) * _mouthOpen);
}

/// Projected bounds of the churner standing at [pos] (pole and head).
Rect _churnerBounds(_Camera cam, _V pos) {
  final half = _poleR * cam.scaleAt(pos);
  return _segmentBounds(
    cam.p(pos + const _V(0, _poleBottom, 0)),
    cam.p(pos + const _V(0, _poleTop, 0)),
    half,
  ).expandToInclude(
    _boxBounds(cam, pos + const _V(0, _headY, 0), _headSize * 0.5),
  );
}

/// Projected bounds of the scoop at [pos] (bowl and handle).
Rect _scoopBounds(_Camera cam, _V pos) => cam
    .oval(pos, _scoopRadii.x)
    .expandToInclude(
      _segmentBounds(
        cam.p(pos),
        cam.p(pos + _scoopHandle),
        _handleR * cam.scaleAt(pos),
      ),
    );

/// Projected bounds of the butter bowl.
Rect _bowlBounds(_Camera cam) => cam
    .oval(const _V(_bowlX, _bowlRimY, 0), _bowlRimR + _bowlRimTube)
    .expandToInclude(cam.oval(const _V(_bowlX, 0, 0), _bowlFootR));

/// Label anchors that follow the objects (screen points).
Offset _churnerHomeLabelAt(_Camera cam, _V pos) =>
    cam.p(pos + const _V(0, _poleTop + 0.5, 0));

/// In the pot the churner's name sits left of its pole, near the top.
Offset _churnerPotLabelAt(_Camera cam, _V pos) =>
    cam.p(pos + const _V(-0.6, _poleTop - 0.8, 0));

Offset _scoopLabelAt(_Camera cam, _V pos) =>
    cam.p(pos + _scoopHandle * 0.5 + const _V(0, 1.2, 0));

Offset _magnetLabelAt(_Camera cam, _V pos) => cam.p(pos + const _V(0, 1.0, 0));

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

  /// Round-capped lines (poles, handles, nails).
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
  final Path aux = Path()..fillType = PathFillType.evenOdd;
}

/// Kinds of scene text.
enum _Ink {
  /// Object names: bold text on the glass chip (dark / light theme).
  chip,
  chipLight,

  /// The progress counters (white on a blue chip).
  counter;

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
      _Ink.counter => TextStyle(
        color: _Colors.white,
        fontSize: size * 1.05,
        fontWeight: FontWeight.w800,
        height: 1.2,
        fontFamily: family,
        fontFamilyFallback: fallback,
        // Digits keep their width while the count climbs.
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    };
  }
}

/// What the painter makes once and reuses: pens and the text painters of
/// the labels and counters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _texts = {};

  LabLang? _lang;
  double _labelSize = _labelPx;

  /// Most text painters kept; the cache is emptied past that.
  static const int _maxTexts = 400;

  double get labelSize => _labelSize;

  /// The last sphere gradient (it changes only while the framing moves).
  Shader? _sphere;
  Rect? _sphereRect;
  Color? _sphereColor;

  /// Radial shading of a sphere filling [rect]: shine towards the light
  /// (upper right), shade on the far side.
  Shader sphereShader(Rect rect, Color color) {
    final cached = _sphere;
    if (cached != null && rect == _sphereRect && color == _sphereColor) {
      return cached;
    }
    _sphereRect = rect;
    _sphereColor = color;
    return _sphere = RadialGradient(
      center: const Alignment(0.3, -0.45),
      radius: 0.95,
      colors: [labShade(color, 0.22), color, labShade(color, -0.4)],
      stops: const [0, 0.45, 1],
    ).createShader(rect);
  }

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

/// HTML highlight pulse: `(sin(t · 8) + 1) / 2`, here at most [_glowMax].
double _pulse(double t) => _glowMax * (math.sin(t * _glowRate) + 1) / 2;

/// Mesh drawing in the scene camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.cache);

  final Canvas canvas;
  final _Camera cam;
  final _PaintCache cache;

  _Pens get pens => cache.pens;

  /// BoxGeometry centred at [c], turned [yaw] about the vertical: the faces
  /// turned to the camera (only the top and the +z face with
  /// [frontOnly]).
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    double yaw = 0,
    bool frontOnly = false,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      if (frontOnly && face.normal.z <= 0) continue;
      final n = yaw == 0 ? face.normal : _yaw(face.normal, yaw);
      final mid0 = _V(
        face.normal.x * hx,
        face.normal.y * hy,
        face.normal.z * hz,
      );
      final mid = c + (yaw == 0 ? mid0 : _yaw(mid0, yaw));
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        final local = _V(k.x * hx, k.y * hy, k.z * hz);
        final o = cam.p(c + (yaw == 0 ? local : _yaw(local, yaw)));
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
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// The silhouette of an upright CylinderGeometry(rt, rb, h) standing on
  /// [bottom], into [pens.path].
  Path side(_V bottom, double rb, double rt, double h) {
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

  /// Side of an upright CylinderGeometry(rt, rb, h) on [bottom], lit from
  /// the front, with a light and a dark band; the top cap with [cap].
  void frustum(
    _V bottom,
    double rb,
    double rt,
    double h,
    Color color, {
    bool cap = true,
  }) {
    final top = bottom + _V(0, h, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = rb * cam.scaleAt(bottom), wt = rt * cam.scaleAt(top);
    final path = side(bottom, rb, rt, h);
    final sideColor = _lit(color, const _V(0, 0, 1));
    canvas.drawPath(path, pens.fill..color = sideColor);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx + wt * 0.45, pt.dy),
      Offset(pb.dx + wb * 0.45, pb.dy + wb),
      pens.line
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = math.max(1.0, wb * 0.34)
        ..color = labShade(sideColor, 0.2),
    );
    canvas.drawLine(
      Offset(pt.dx - wt * 0.8, pt.dy),
      Offset(pb.dx - wb * 0.8, pb.dy + wb),
      pens.line
        ..strokeWidth = math.max(1.0, wb * 0.4)
        ..color = labShade(sideColor, -0.25),
    );
    pens.line.strokeCap = StrokeCap.round;
    canvas.restore();
    if (!cap) return;
    final topOval = cam.oval(top, rt);
    canvas.drawOval(
      topOval,
      pens.fill..color = labShade(_lit(color, _V.up), 0.1),
    );
    canvas.drawOval(
      topOval,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.35).withValues(alpha: 0.6),
    );
  }

  /// A sphere (projected circle), lit from the upper right like the HTML
  /// key light.
  void sphere(_V c, double radius, Color color) {
    final rect = Rect.fromCircle(
      center: cam.p(c),
      radius: radius * cam.scaleAt(c),
    );
    canvas.drawOval(
      rect,
      pens.fill
        ..shader = cache.sphereShader(rect, _lit(color, const _V(0, 0, 1))),
    );
    pens.fill.shader = null;
  }

  /// A round rod (CylinderGeometry) from [a] to [b] of radius [radius].
  void rod(_V a, _V b, double radius, Color color, {Offset? from}) {
    final pa = from ?? cam.p(a), pb = cam.p(b);
    final w = math.max(1.2, 2 * radius * cam.scaleAt(_V.lerp(a, b, 0.5)));
    canvas.drawLine(
      pa,
      pb,
      pens.line
        ..strokeWidth = w
        ..color = _lit(color, const _V(0, 0, 1)),
    );
    // Shine along one side.
    final d = pb - pa;
    final len = d.distance;
    if (len < 1) return;
    final n = Offset(-d.dy / len, d.dx / len) * (w * 0.22);
    canvas.drawLine(
      pa - n,
      pb - n,
      pens.line
        ..strokeWidth = w * 0.25
        ..color = _Colors.white.withValues(alpha: 0.18),
    );
  }

  /// The drop-zone ring (HTML `RingGeometry` with the glow material).
  void ring(_V c, double inner, double outer, double alpha, {double open = 1}) {
    final o = _openOval(cam, c, outer, open);
    final path = pens.aux
      ..reset()
      ..addOval(o)
      ..addOval(_openOval(cam, c, inner, open));
    canvas.drawPath(
      path,
      pens.fill..color = _Colors.zone.withValues(alpha: alpha),
    );
    canvas.drawOval(
      o,
      pens.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.zone.withValues(alpha: math.min(1, alpha * 2)),
    );
  }

  /// Soft blurred shadow of a round footprint of [radius] on the table.
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

/// Paints the HTML Three.js scene of the current scenario: S1 the pot of
/// curd, the churner, the scoop and the bowl; S2 the toolbox, the bar
/// magnet, the pile of sawdust with its nails and the tray; then the
/// labels, the counters and the confetti.
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
    final g = _Gfx(canvas, s.cam, cache);
    canvas.drawRect(
      labBleed(size),
      _pens.fill..color = isDark ? _Colors.sceneBg : _Colors.sceneBgLight,
    );
    g.box(
      _tableCentre,
      _tableSize,
      s.scenario == 0 ? _Colors.table : _Colors.bench,
      edge: 0,
    );
    if (s.scenario == 0) {
      _paintChurning(g);
    } else {
      _paintMagnetic(g);
    }
    _paintTexts(canvas);
    _paintConfetti(canvas);
  }

  /// Glow amount for [obj] (HTML: the next object to move pulses).
  double _glowOf(_Obj obj) => scene.active == obj ? _pulse(scene.time) : 0;

  /// Drop-zone opacity (pulsing).
  double get _zoneAlpha =>
      _zoneAlphaMin +
      (_zoneAlphaMax - _zoneAlphaMin) * (math.sin(scene.time * 4) + 1) / 2;

  // ------------------------------------------------------------ scenario 1

  void _paintChurning(_Gfx g) {
    final s = scene;
    final held = s.active == _Obj.churner && !s.churnerIn;
    final churnerMoving = !s.churnerIn && s.churner != _churnerHome;
    final scoopMoving = s.scoop != _scoopHome;
    g.shadow(const _V(_potX, 0, 0), _bellyR * 0.8);
    g.shadow(const _V(_bowlX, 0, 0), _bowlFootR + 0.6);
    if (!churnerMoving && !s.churnerIn) g.shadow(_churnerHome, 1.4);
    if (!scoopMoving) g.shadow(_scoopHome, _scoopRadii.x);
    if (!scoopMoving) _paintScoop(g, s.scoop);
    _paintBowl(g);
    _paintPot(g);
    if (s.step == 1 && !s.churnerIn && !s.busy) {
      g.ring(
        _churnerZone,
        _churnerZoneIn,
        _churnerZoneOut,
        _zoneAlpha,
        open: _mouthOpen,
      );
    }
    if (s.step == 4 && !s.busy) {
      g.ring(
        _scoopZone,
        _scoopZoneIn,
        _scoopZoneOut,
        _zoneAlpha,
        open: _mouthOpen,
      );
    }
    if (!s.churnerIn) {
      _paintChurner(g, s.churner, held ? _glowOf(_Obj.churner) : 0);
    }
    if (scoopMoving) _paintScoop(g, s.scoop);
  }

  /// HTML `matkaS1`: the clay belly and neck, the curd (or buttermilk)
  /// with its globules and lumps, the churner standing in it. The mouth
  /// is drawn opened up by [_mouthOpen].
  void _paintPot(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    g.sphere(_bellyCentre, _bellyR, _Colors.clay);
    // The neck: an open CylinderGeometry(3.5, 3.2, 1.2).
    final mouth = _potOval(cam, _neckTop, _mouthR);
    final neck = _potOval(cam, _neckBottom, _neckR);
    final side = _pens.path
      ..reset()
      ..moveTo(mouth.left, mouth.center.dy)
      ..lineTo(neck.left, neck.center.dy)
      ..arcTo(neck, math.pi, -math.pi, false)
      ..lineTo(mouth.right, mouth.center.dy)
      ..arcTo(mouth, 0, -math.pi, false)
      ..close();
    final clay = _lit(_Colors.clay, const _V(0, 0, 1));
    canvas.drawPath(side, _pens.fill..color = clay);
    canvas.drawPath(
      side,
      _pens.stroke
        ..strokeWidth = 1
        ..color = labShade(clay, -0.35),
    );
    canvas.drawOval(mouth, _pens.fill..color = _Colors.clayInside);
    canvas.save();
    canvas.clipPath(
      _pens.path
        ..reset()
        ..addOval(mouth),
    );
    final curd = _potOval(cam, _curdY, _curdR);
    canvas.drawOval(
      curd,
      _pens.fill..color = s.buttermilk ? _Colors.buttermilk : _Colors.curd,
    );
    // Swirls while churning (HTML: "the curd swirls rapidly").
    if (s.churning) {
      for (var i = 0; i < 3; i++) {
        final k = 0.35 + i * 0.22;
        final r = Rect.fromCenter(
          center: curd.center,
          width: curd.width * k,
          height: curd.height * k,
        );
        canvas.drawArc(
          r,
          s.spin * (i.isEven ? 1 : -0.7) + i,
          math.pi * 0.8,
          false,
          _pens.stroke
            ..strokeWidth = 1.4
            ..color = _Colors.slate400.withValues(alpha: 0.6),
        );
      }
    }
    for (var i = 0; i < _globuleCount; i++) {
      if (!s.globuleOn[i]) continue;
      final gl = s.globules[i];
      final c = _V(_potX + gl.x, _curdY, gl.z);
      final o = _potPoint(cam, c);
      final r = math.max(1.6, gl.r * cam.scaleAt(c));
      canvas.drawCircle(o, r, _pens.fill..color = _Colors.butter);
      canvas.drawCircle(
        o - Offset(r * 0.3, r * 0.3),
        r * 0.4,
        _pens.fill..color = _Colors.butterShine,
      );
    }
    for (var i = 0; i < _lumpCount; i++) {
      if (!s.lumpOn[i]) continue;
      final l = s.lumps[i];
      final c = _V(_potX + l.x, _curdY, l.z);
      _paintButter(
        g,
        c,
        _V(l.r * 1.3, l.r * 0.6, l.r * 1.2),
        at: _potPoint(cam, c),
      );
    }
    canvas.restore();
    // The rim's front lip.
    canvas.drawArc(
      mouth,
      0,
      math.pi,
      false,
      _pens.stroke
        ..strokeWidth = math.max(1.2, 0.25 * cam.scaleAt(_bellyCentre))
        ..color = labShade(_lit(_Colors.clay, _V.up), 0.15),
    );
    if (s.churnerIn) {
      _paintChurnerInPot(
        g,
        s.active == _Obj.churner ? _glowOf(_Obj.churner) : 0,
      );
    }
  }

  /// A lump of butter: an ellipsoid with radii [radii] seen from above.
  void _paintButter(_Gfx g, _V c, _V radii, {Offset? at}) {
    final cam = g.cam;
    final o = at ?? cam.p(c);
    final sc = cam.scaleAt(c);
    final w = radii.x * 2 * sc;
    final h = cam.ellipseHalf(c, radii.z) * 2 + radii.y * sc;
    final r = Rect.fromCenter(center: o, width: w, height: h);
    g.canvas.drawOval(r, _pens.fill..color = labShade(_Colors.butter, -0.12));
    g.canvas.drawOval(
      r.deflate(math.min(w, h) * 0.12).shift(Offset(-w * 0.05, -h * 0.12)),
      _pens.fill..color = _Colors.butter,
    );
    g.canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(-w * 0.18, -h * 0.22),
        width: w * 0.3,
        height: h * 0.25,
      ),
      _pens.fill..color = _Colors.butterShine.withValues(alpha: 0.8),
    );
  }

  /// The churner standing in the pot: only the pole above the curd shows.
  void _paintChurnerInPot(_Gfx g, double glow) {
    final s = scene;
    final pos = s.churner;
    final bottom = pos.withY(_curdY);
    final top = pos + const _V(0, _poleTop, 0);
    _glowRod(g, bottom, top, glow, from: _potPoint(g.cam, bottom));
    g.rod(
      bottom,
      top,
      _poleR,
      _tint(_Colors.wood, glow),
      from: _potPoint(g.cam, bottom),
    );
  }

  /// HTML `mathaniS1` at [pos]: pole and head.
  void _paintChurner(_Gfx g, _V pos, double glow) {
    final head = pos + const _V(0, _headY, 0);
    _glowRod(
      g,
      pos + const _V(0, _poleBottom, 0),
      pos + const _V(0, _poleTop, 0),
      glow,
    );
    g.box(head, _headSize, _tint(_Colors.wood, glow), yaw: scene.spin);
    g.rod(
      pos + const _V(0, _poleBottom, 0),
      pos + const _V(0, _poleTop, 0),
      _poleR,
      _tint(_Colors.wood, glow),
    );
  }

  /// The pulsing glow behind a rod (HTML emissive highlight).
  void _glowRod(_Gfx g, _V a, _V b, double amount, {Offset? from}) {
    if (amount <= 0) return;
    g.canvas.drawLine(
      from ?? g.cam.p(a),
      g.cam.p(b),
      _pens.line
        ..strokeWidth = 18
        ..color = _Colors.glow.withValues(alpha: amount * 0.9),
    );
  }

  /// HTML `spoonS1` (the scoop at [pos]): handle and scoop, with the
  /// butter on it while it is carried to the bowl.
  void _paintScoop(_Gfx g, _V pos) {
    final s = scene;
    final glow = _glowOf(_Obj.scoop);
    final cam = g.cam;
    final end = pos + _scoopHandle;
    _glowRod(g, pos, end, glow);
    g.rod(pos, end, _handleR, _tint(_Colors.wood, glow));
    final o = cam.p(pos);
    final sc = cam.scaleAt(pos);
    final r = Rect.fromCenter(
      center: o,
      width: 2 * _scoopRadii.x * sc,
      height: 2 * cam.ellipseHalf(pos, _scoopRadii.z) + _scoopRadii.y * sc,
    );
    g.canvas.drawOval(
      r,
      _pens.fill..color = _tint(_lit(_Colors.wood, const _V(0, 0, 1)), glow),
    );
    g.canvas.drawOval(
      r.deflate(r.shortestSide * 0.18).shift(Offset(0, -r.height * 0.08)),
      _pens.fill..color = labShade(_lit(_Colors.wood, _V.up), -0.25),
    );
    if (s.butterOnScoop) {
      _paintButter(g, pos + const _V(0, 0.35, 0), const _V(1.3, 0.7, 1.2));
    }
  }

  /// HTML `butterBowlS1`: blue foot, white wall, the inside, the butter
  /// and the blue rim.
  void _paintBowl(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    g.frustum(
      const _V(_bowlX, 0, 0),
      _bowlFootR,
      _bowlBottomR,
      _bowlFootH,
      _Colors.bowlRim,
      cap: false,
    );
    g.frustum(
      const _V(_bowlX, _bowlWallFrom, 0),
      _bowlBottomR,
      _bowlRimR,
      _bowlRimY - _bowlWallFrom,
      _Colors.ceramic,
      cap: false,
    );
    final mouth = cam.oval(const _V(_bowlX, _bowlRimY, 0), _bowlRimR);
    canvas.drawOval(
      mouth,
      _pens.fill..color = _lit(_Colors.ceramicInside, _V.up),
    );
    if (s.butterInBowl) {
      canvas.save();
      canvas.clipPath(
        _pens.path
          ..reset()
          ..addOval(mouth.inflate(4)),
      );
      _paintButter(
        g,
        _bowlButter + const _V(0, 0.6, 0),
        _bowlButterRadii * 0.8,
      );
      canvas.restore();
    }
    canvas.drawOval(
      mouth,
      _pens.stroke
        ..strokeWidth = math.max(
          1.5,
          2 * _bowlRimTube * cam.scaleAt(_bowlButter),
        )
        ..color = _lit(_Colors.bowlRim, _V.up),
    );
  }

  // ------------------------------------------------------------ scenario 2

  void _paintMagnetic(_Gfx g) {
    final s = scene;
    final magnetMoving = !s.magnetHome;
    g.shadow(_trayCentre, 5.2);
    g.shadow(_toolboxCentre, 4.2);
    // Toolbox with the magnet lying on it.
    g.box(_toolboxCentre, _toolboxSize, _Colors.toolbox);
    if (!magnetMoving) _paintMagnet(g);
    // HTML glow rings (at y 3.5 over the pile and the tray): drawn on the
    // bench around them, where they do not hide the nails.
    if (s.step == 1 && !s.busy) {
      g.ring(_pileCentre.withY(_ringY), _zoneIn, _zoneOut, _zoneAlpha);
    }
    _paintPile(g);
    if (s.step == 3 && !s.busy) {
      g.ring(_trayCentre.withY(_ringY), _zoneIn, _zoneOut, _zoneAlpha);
    }
    _paintTray(g);
    // Nails in flight to the tray.
    for (final n in s.nails) {
      if (n.state == _NailState.falling && s.time >= n.since) {
        _paintNail(g, s.nailPos(n), s.nailAxis(n));
      }
    }
    if (magnetMoving) {
      // Nails hanging behind the bar, the bar, then those in front.
      for (final n in s.nails) {
        if (_onMagnet(n) && n.attachZ < 0) {
          _paintNail(g, s.nailPos(n), s.nailAxis(n));
        }
      }
      _paintMagnet(g);
      for (final n in s.nails) {
        if (_onMagnet(n) && n.attachZ >= 0) {
          _paintNail(g, s.nailPos(n), s.nailAxis(n));
        }
      }
    }
  }

  bool _onMagnet(_Nail n) =>
      n.state == _NailState.jumping ||
      n.state == _NailState.held ||
      (n.state == _NailState.falling && scene.time < n.since);

  /// The sawdust cone (seen from above: its whole surface shows), its
  /// grains and the nails still in it.
  void _paintPile(_Gfx g) {
    final s = scene;
    final canvas = g.canvas;
    final cam = g.cam;
    final base = cam.oval(_pileCentre, _pileR);
    final apex = cam.p(_pileCentre + const _V(0, _pileH, 0));
    final lit = _lit(_Colors.sawdust, const _V(0, 0.92, 0.39));
    canvas.drawOval(base, _pens.fill..color = labShade(lit, -0.15));
    canvas.save();
    canvas.clipPath(
      _pens.path
        ..reset()
        ..addOval(base),
    );
    // The slope facing the light, brighter towards the top.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.lerp(base.center, apex, 0.6)!,
        width: base.width * 0.8,
        height: base.height * 0.75,
      ),
      _pens.fill..color = lit,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: apex + Offset(-base.width * 0.04, base.height * 0.05),
        width: base.width * 0.35,
        height: base.height * 0.3,
      ),
      _pens.fill..color = labShade(lit, 0.12),
    );
    canvas.restore();
    // Grains of sawdust on the surface.
    for (final gr in s.grains) {
      final d = math.sqrt(
        (gr.x - _pileCentre.x) * (gr.x - _pileCentre.x) + gr.z * gr.z,
      );
      final h = _pileH * (1 - d / _pileR);
      final o = cam.p(_V(gr.x, h, gr.z));
      canvas.drawCircle(
        o,
        1.3,
        _pens.fill
          ..color = (gr.dark ? _Colors.grainDark : _Colors.grainLight)
              .withValues(alpha: 0.7),
      );
    }
    for (final i in s.pileOrder) {
      final n = s.nails[i];
      if (n.state == _NailState.pile) _paintNail(g, n.pile, n.pileAxis);
    }
  }

  /// One iron nail centred at [c] with its head towards [axis].
  void _paintNail(_Gfx g, _V c, _V axis) {
    final cam = g.cam;
    final head = cam.p(c + axis * _nailHalf);
    final tip = cam.p(c - axis * _nailHalf);
    final sc = cam.scaleAt(c);
    final w = math.max(1.6, 0.12 * sc);
    g.canvas.drawLine(
      head,
      tip,
      _pens.line
        ..strokeWidth = w
        ..color = _Colors.nail,
    );
    g.canvas.drawLine(
      head,
      Offset.lerp(head, tip, 0.6)!,
      _pens.line
        ..strokeWidth = w * 0.4
        ..color = _Colors.nailShine.withValues(alpha: 0.7),
    );
    g.canvas.drawCircle(
      head,
      math.max(1.6, _nailHeadR * sc),
      _pens.fill..color = labShade(_Colors.nail, 0.15),
    );
  }

  /// HTML `trayS2`: base, back and side walls, the nails in it, the front
  /// wall.
  void _paintTray(_Gfx g) {
    final s = scene;
    const c = _trayCentre;
    final base = c + _V(0, _trayBase.y / 2, 0);
    final wallY = c.y + _trayWallH / 2;
    final sideX = _trayBase.x / 2 - _trayWall / 2;
    final endZ = _trayBase.z / 2 - _trayWall / 2;
    g.box(base, _trayBase, _Colors.tray, edge: 0.5);
    g.box(
      _V(c.x, wallY, -endZ),
      _V(_trayBase.x, _trayWallH, _trayWall),
      _Colors.tray,
      edge: 0.5,
    );
    for (final x in [-sideX, sideX]) {
      g.box(
        _V(c.x + x, wallY, 0),
        _V(_trayWall, _trayWallH, _trayBase.z),
        _Colors.tray,
        edge: 0.5,
      );
    }
    for (final n in s.nails) {
      if (n.state == _NailState.tray) _paintNail(g, n.tray, n.trayAxis);
    }
    g.box(
      _V(c.x, wallY, endZ),
      _V(_trayBase.x, _trayWallH, _trayWall),
      _Colors.tray,
      edge: 0.5,
    );
  }

  /// HTML `magnetS2`: red N half (+x), blue S half, silver end caps.
  void _paintMagnet(_Gfx g) {
    final s = scene;
    final m = s.magnet;
    final glow = _glowOf(_Obj.magnet);
    if (glow > 0) {
      g.canvas.drawRRect(
        RRect.fromRectAndRadius(
          _boxBounds(g.cam, m, _magnetHalf).inflate(6),
          const Radius.circular(12),
        ),
        _pens.glow..color = _Colors.glow.withValues(alpha: glow * 1.2),
      );
    }
    const half = _magnetHalfLength / 2;
    // The farther half first.
    final halves = [
      (m + const _V(-half, 0, 0), _Colors.south),
      (m + const _V(half, 0, 0), _Colors.north),
    ];
    if (g.cam.depth(halves[1].$1) > g.cam.depth(halves[0].$1)) {
      halves.insert(0, halves.removeAt(1));
    }
    for (final (c, color) in halves) {
      g.box(c, _halfSize, _tint(color, glow));
    }
    for (final x in [-_magnetHalfLength, _magnetHalfLength]) {
      g.box(m + _V(x, 0, 0), _capSize, _tint(_Colors.silver, glow));
    }
  }

  // ------------------------------------------------------------------ text

  void _paintTexts(Canvas canvas) {
    final s = scene;
    final cam = s.cam;
    final size = cache.labelSize;
    if (s.scenario == 0) {
      final potLabel = _chip(
        canvas,
        cam.p(_potLabelAt),
        _t(s.step >= 5 ? 'lbl_matka_bm' : 'lbl_matka'),
        edge: -1,
        draw: showLabels,
      );
      // HTML `cnt_churn` (its badge was missing from the page).
      if (s.churnerIn && (s.step == 2 || s.step == 3)) {
        _chip(
          canvas,
          Offset(potLabel.left, potLabel.top - _labelGap * size),
          labFormat(_t('cnt_churn'), {'p': s.churnPercent}),
          edge: -1,
          above: 1,
          ink: _Ink.counter,
        );
      }
      if (!showLabels) return;
      if (s.churnerIn) {
        _chip(
          canvas,
          _churnerPotLabelAt(cam, s.churner),
          _t('lbl_mathani'),
          edge: 1,
        );
      } else {
        _chip(
          canvas,
          _churnerHomeLabelAt(cam, s.churner),
          _t('lbl_mathani'),
          above: 1,
        );
      }
      if (!s.busy || s.scoop == _scoopHome) {
        _chip(canvas, _scoopLabelAt(cam, s.scoop), _t('lbl_spoon'), above: 1);
      }
      _chip(
        canvas,
        cam.p(_bowlLabelAt),
        _t(s.butterInBowl ? 'lbl_bowl_full' : 'lbl_bowl'),
        above: -1,
      );
      return;
    }
    final pileLabel = _chip(
      canvas,
      cam.p(_pileLabelAt),
      _t(s.step >= 3 ? 'lbl_sawdust_clean' : 'lbl_sawdust'),
      above: -1,
      draw: showLabels,
    );
    // HTML `cnt_iron` (its badge was missing from the page).
    if (s.step == 2) {
      _chip(
        canvas,
        Offset(pileLabel.center.dx, pileLabel.bottom + _labelGap * size),
        labFormat(_t('cnt_iron'), {'p': s.attractedPercent}),
        above: -1,
        ink: _Ink.counter,
      );
    }
    if (!showLabels) return;
    _chip(canvas, cam.p(_trayLabelAt), _t('lbl_tray'), above: -1);
    _chip(canvas, _magnetLabelAt(cam, s.magnet), _t('lbl_magnet'), above: 1);
  }

  /// HTML `.label-3d` chip: glass panel with a blue border and bold text
  /// centred on [at]; with [edge] 1 its right edge, with -1 its left edge
  /// sits on [at]; with [above] 1 its bottom edge, with -1 its top edge.
  /// Chips are kept left of the tool column. Returns the chip's box (also
  /// when it is not drawn).
  Rect _chip(
    Canvas canvas,
    Offset at,
    String text, {
    double edge = 0,
    double above = 0,
    _Ink? ink,
    bool draw = true,
  }) {
    final style = ink ?? (isDark ? _Ink.chip : _Ink.chipLight);
    final tp = cache.text(style, text);
    final size = cache.labelSize;
    var rect = _chipBox(at, tp.size, size, edge, above: above);
    if (rect.right > labelRight - 4) {
      rect = rect.shift(Offset(labelRight - 4 - rect.right, 0));
    }
    if (!draw) return rect;
    final counter = style == _Ink.counter;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas.drawRRect(
      rr,
      _pens.fill
        ..color = counter
            ? _Colors.counterBg
            : (isDark ? _Colors.labelBg : _Colors.labelBgLight),
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = counter ? _Colors.counterBorder : _Colors.labelBorder,
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
