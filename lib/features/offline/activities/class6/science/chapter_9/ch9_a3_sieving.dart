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

/// Class 6 Science • Chapter 9 • Activity 3
/// Methods of Separation: Sieving.
///
/// Native Flutter port of `Cl6S-Ch9-A3-Sieving.html`.
///
/// Scenario 1 (Sieving Flour in the Kitchen, 4 steps): a cup of flour and
/// bran mixture is poured onto a wire mesh sieve standing on a glass bowl.
/// Shaking the sieve lets the fine flour fall through into the bowl while
/// the coarse bran stays on the mesh; the bran is then emptied into a waste
/// bin.
///
/// Scenario 2 (Separating Sand at a Construction Site, 5 steps): a shovel
/// scoops sand and pebbles from a pile and tips them onto a slanted wire
/// screen above a wheelbarrow. Shaking the screen sifts the fine sand into
/// the wheelbarrow; the pebbles left on the screen are then tipped off its
/// lower end into a separate heap.
///
/// The Three.js scenes are redrawn by a CustomPainter through a perspective
/// projection of the HTML camera (position (0, 15, 24), target (0, 3, 0),
/// fov 45°). Objects are dragged on a plane facing the camera, and every
/// drop is tested where the learner sees it on the screen.
class Ch9A3SievingPage extends StatefulWidget {
  const Ch9A3SievingPage({super.key});

  @override
  State<Ch9A3SievingPage> createState() => _SievingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises its tones with the Web Audio
/// API; they map to the closest bundled file: 'click' (buttons) -> click,
/// 'click' when an object is picked up -> pickup, 'pour' (a good drop, the
/// pebbles dumped) -> drop, 'shake' (a shake starts) -> pop and 'ding' (the
/// summary) -> success. A drop away from the target, a silent 'click' in
/// the HTML, now plays wrong with its hint.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`,
/// pop → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// HTML 'click'.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// The shell's right tone.
  correct('audio/class6/science/correct.mp3'),

  /// An object dropped away from its target (added hint toast).
  wrong('audio/class6/science/error.mp3'),

  /// HTML 'ding' with the summary popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML 'pour'.
  drop('audio/class6/science/drop.mp3'),

  /// HTML 'click' when an object is picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML 'shake' when the sieve starts shaking.
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
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky950 = Color(0xFF082F49);
  static const Color amber600 = Color(0xFFD97706);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// `materials.tableMat` 0x334155: the kitchen table and the site ground.
  static const Color table = slate700;

  /// `woodMat` 0x78350f: the screen's frame and posts, the shovel handle.
  static const Color wood = Color(0xFF78350F);

  /// `metalMat` 0x94a3b8: sieve rim, cup, wheelbarrow, shovel blade.
  static const Color metal = slate400;

  /// `wireMeshMat` 0xcbd5e1 (wireframe).
  static const Color wire = slate300;

  /// `flourMat` 0xffffff and `branMat` 0x92400e.
  static const Color flour = white;
  static const Color bran = Color(0xFF92400E);

  /// `glassMat` white, opacity 0.4: the bowl.
  static const Color glass = white;

  /// `sandMat` 0xfacc15 and `pebbleMat` 0x64748b.
  static const Color sand = Color(0xFFFACC15);
  static const Color pebble = slate500;

  /// Waste bin: body 0x334155, inside 0x090d16, rim and ribs 0x64748b.
  static const Color bin = slate700;
  static const Color binInside = Color(0xFF090D16);
  static const Color binRim = slate500;

  /// Wheelbarrow tyre (added: the HTML barrow is a plain box).
  static const Color tyre = slate800;

  /// `glowMat` 0x0ea5e9, opacity 0.35: drop zones.
  static const Color glow = Color(0x590EA5E9);

  /// `update3DHighlight` pulse colour 0x38bdf8.
  static const Color highlight = sky400;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x4D000000);

  /// `.label-3d` glass chips: dark `rgba(15,23,42,0.92)` / light white,
  /// `border-sky-400`.
  static const Color labelDark = Color(0xEB0F172A);
  static const Color labelLight = Color(0xF2FFFFFF);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML's brand colour is sky blue (Enter Lab, the sidebar
/// tab, the HUD border): sky-400 on the dark panels, sky-600 on the light
/// ones.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xEB0F172A), // --glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.sky400, // dark:text-sky-400
    onAccent: _Colors.slate950, // badge text-slate-950
    primary: _Colors.sky600, // summary button from-sky-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.sky950, // header bg-sky-600 (dark enough for text)
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x660C4A6E), // from-sky-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC7DD3FC), // subtitle text-sky-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.sky400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.sky600, // text-sky-600
    onAccent: _Colors.white,
    primary: _Colors.sky600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.sky50,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x660C4A6E),
    curtainText: _Colors.white,
    curtainMuted: _Colors.sky300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.sky400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Steps
// say exactly what to do on a touch screen ("tap" instead of "click"; the
// HTML's 'Hold to Shake Sieve' button becomes a press and hold on the sieve
// or the screen in the scene, or taps on 'Shake Sieve'). The HTML's Hindi
// steps were shortened versions of the English ones and quoted the English
// button names; they now say the same as the English, in Hindi. The hint
// toasts, the progress readout's second label, the observation list and the
// scene descriptions are added.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Methods of Separation: Sieving',
    'app_subtitle': 'Class 6 • Methods of Separation in Everyday Life',
    'scen_1_opt': 'Scenario 1: Sieving Flour in the Kitchen',
    'scen_2_opt': 'Scenario 2: Separating Sand at a Construction Site',
    's1_desc':
        'To separate fine wheat flour from coarse wheat bran (chokar) using a wire mesh kitchen sieve.',
    's2_desc':
        'To separate fine building sand from pebbles and stones using a slanted construction screen sieve.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Pour Mixture',
    's1_a1':
        'DRAG the cup containing the flour and bran mixture and DROP it onto the kitchen sieve.',
    's1_o1':
        'Whole wheat flour contains fine powdery flour mixed with coarse fibrous bran.',
    's1_c2': 'Agitate Sieve',
    's1_a2':
        "PRESS and HOLD the sieve to shake it side to side (or tap 'Shake Sieve' a few times) until sifting reaches 100%.",
    's1_o2':
        'Fine flour passes through the tiny mesh pores into the bowl, while larger bran flakes stay trapped above.',
    's1_c3': 'Discard Bran',
    's1_a3':
        'DRAG the sieve with the trapped coarse bran to the waste bin and DROP it there to empty it.',
    's1_o3':
        'Separating bran leaves fine, smooth flour ready for preparing soft dough.',
    's1_c4': 'Sieving Principle',
    's1_a4':
        "Review the refined flour in the bowl, then tap 'Finish Observation'.",
    's1_o4':
        'Sieving works when components of a mixture have different particle sizes relative to mesh holes.',
    // Scenario 2 steps.
    's2_c1': 'Scoop Mixture',
    's2_a1':
        'DRAG the shovel to the pile of mixed sand and pebbles and DROP it there to scoop up a shovelful.',
    's2_o1':
        'Unrefined river sand contains large stones and pebbles that would weaken mortar.',
    's2_c2': 'Load Screen',
    's2_a2':
        'DRAG the loaded shovel and DROP its contents onto the upper slope of the slanted construction screen.',
    's2_o2':
        'Placing the mixture on the mesh screen prepares it for particle size separation.',
    's2_c3': 'Screen Sifting',
    's2_a3':
        "PRESS and HOLD the construction screen to shake it (or tap 'Shake Sieve' a few times) until sifting reaches 100%.",
    's2_o3':
        'Fine sand grains fall straight through the mesh into the wheelbarrow below.',
    's2_c4': 'Clear Pebbles',
    's2_a4': "Tap 'Dump Pebbles' to tip the trapped stones off the screen.",
    's2_o4':
        'Larger stones slide down the slanted mesh slope and collect separately.',
    's2_c5': 'Conclusion',
    's2_a5':
        "Observe the clean sand in the wheelbarrow, then tap 'Finish Observation'.",
    's2_o5':
        'Sieving is essential in construction to ensure cement paste is uniform and strong.',
    // HTML `hud` lines (the canvas "Current Task").
    's1_hud_1':
        'Step 1: DRAG the cup containing the flour and bran mixture and DROP it onto the kitchen sieve.',
    's1_hud_2':
        "Step 2: PRESS and HOLD the sieve (or tap 'Shake Sieve') to shake it side to side.",
    's1_hud_3':
        'Step 3: DRAG the sieve containing trapped coarse bran over to the waste bin to discard.',
    's1_hud_4':
        "Step 4: Observation complete! Notice pure flour in the bowl and tap 'Finish Observation'.",
    's2_hud_1':
        'Step 1: DRAG the shovel to the pile of mixed sand and pebbles to scoop up a shovelful.',
    's2_hud_2':
        'Step 2: DRAG the loaded shovel and DROP its contents onto the upper slope of the construction screen.',
    's2_hud_3':
        "Step 3: PRESS and HOLD the screen (or tap 'Shake Sieve') to sift fine sand into the wheelbarrow.",
    's2_hud_4':
        "Step 4: Tap 'Dump Pebbles' to clear accumulated rocks off the screen.",
    's2_hud_5':
        "Step 5: Observation complete! Review clean building sand and tap 'Finish Observation'.",
    // Buttons.
    'btn_shake': 'Shake Sieve',
    'btn_dump': 'Dump Pebbles',
    'btn_finish': 'Finish Observation',
    // Canvas labels (HTML `createStdLabel`).
    'lbl_cup': 'Flour Mixture Cup',
    'lbl_sieve': 'Kitchen Mesh Sieve',
    'lbl_bin': 'Waste Bin',
    'lbl_shovel': 'Sand Shovel',
    'lbl_screen': 'Construction Screen',
    'lbl_barrow': 'Wheelbarrow',
    'lbl_pile': 'Sand & Pebble Pile',
    // HTML `cnt_sift` / `cnt_filter` (its badge element never existed, so
    // the HTML never showed it); the second one said "Filtering", which is
    // a different method of separation.
    'cnt_sift': 'Sifting Progress: {p}%',
    'cnt_screen': 'Sieving Progress: {p}%',
    // Added: hints when an object is dropped away from its target (the
    // HTML sent it back without a word).
    'e_cup': 'Drop the cup onto the kitchen sieve to pour in the mixture.',
    'e_sieve': 'Drop the sieve over the waste bin to empty out the bran.',
    'e_pile':
        'Bring the shovel onto the sand and pebble pile to scoop up the mixture.',
    'e_screen':
        'Drop the mixture onto the upper slope of the construction screen.',
    // Summary popup (HTML `summary-modal`).
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1':
        'Flour Sifted! You used sieving. The wire mesh lets the tiny flour particles pass through its holes, but the larger bran flakes remain trapped above.',
    'sum_s2':
        'Sand Refined! This is sieving on a large scale. Whether in the kitchen or at a construction site, sieving relies on differences in particle size to separate mixtures efficiently.',
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Kitchen table with a cup of flour and bran mixture, a wire mesh sieve on a glass bowl, and a waste bin',
    'scene_s2':
        'Construction site with a pile of sand and pebbles, a shovel, and a slanted wire screen above a wheelbarrow',
  },
  'hi': {
    'app_title': 'पृथक्करण की विधियाँ: चालन (छानना)',
    'app_subtitle': 'कक्षा 6 • दैनिक जीवन में पृथक्करण की विधियाँ',
    'scen_1_opt': 'परिदृश्य 1: रसोई में आटा छानना (चालन)',
    'scen_2_opt': 'परिदृश्य 2: निर्माण स्थल पर रेत छानना',
    's1_desc': 'छलनी के बारीक छिद्रों द्वारा आटे से चोकर (भूसी) को अलग करना।',
    's2_desc': 'तिरछी जाली द्वारा रेत से कंकड़-पत्थर अलग करना।',
    's1_c1': 'मिश्रण डालना',
    's1_a1':
        'आटे और चोकर के मिश्रण वाले कप को खींचें और रसोई की छलनी पर छोड़ें।',
    's1_o1': 'गेहूँ के आटे में बारीक कणों के साथ चोकर के मोटे कण होते हैं।',
    's1_c2': 'चालन (छानना)',
    's1_a2':
        "छलनी को दबाकर रखें, ताकि वह दाएँ-बाएँ हिले (या 'छलनी हिलाएँ' पर कुछ बार टैप करें), जब तक चालन 100% न हो जाए।",
    's1_o2':
        'बारीक आटा छिद्रों से नीचे कटोरे में गिरता है जबकि मोटा चोकर ऊपर रह जाता है।',
    's1_c3': 'चोकर फेंकना',
    's1_a3':
        'फँसे हुए मोटे चोकर वाली छलनी को खींचें और कचरे के डिब्बे के ऊपर छोड़ें, ताकि वह खाली हो जाए।',
    's1_o3': 'चोकर अलग होने से आटा गूंधने के लिए मुलायम हो जाता है।',
    's1_c4': 'सिद्धांत',
    's1_a4':
        "कटोरे में छने हुए आटे को देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o4':
        'चालन विधि तब काम करती है जब मिश्रण के घटकों के कणों का आकार छलनी के छिद्रों की तुलना में अलग-अलग हो।',
    's2_c1': 'मिश्रण उठाना',
    's2_a1':
        'फावड़े को खींचें और रेत और कंकड़ के ढेर पर छोड़ें, ताकि एक फावड़ा भर मिश्रण उठ जाए।',
    's2_o1':
        'नदी की रेत में कंकड़-पत्थर होते हैं जो प्लास्टर को कमजोर कर सकते हैं।',
    's2_c2': 'रेत डालना',
    's2_a2':
        'भरे हुए फावड़े को खींचें और उसका मिश्रण तिरछी निर्माण छलनी की ऊपरी ढलान पर छोड़ें।',
    's2_o2':
        'मिश्रण को जाली पर डालने से कणों के आकार के अनुसार छानना आसान होता है।',
    's2_c3': 'छानना',
    's2_a3':
        "निर्माण छलनी को दबाकर रखें, ताकि वह हिले (या 'छलनी हिलाएँ' पर कुछ बार टैप करें), जब तक चालन 100% न हो जाए।",
    's2_o3': 'बारीक रेत जाली से छनकर नीचे ठेला गाड़ी में एकत्र होती है।',
    's2_c4': 'पत्थर हटाना',
    's2_a4':
        "जाली पर फँसे पत्थरों को गिराने के लिए 'कंकड़ गिराएँ' पर टैप करें।",
    's2_o4': 'मोटे पत्थर जाली की ढलान से फिसलकर अलग ढेर बना लेते हैं।',
    's2_c5': 'निष्कर्ष',
    's2_a5':
        "ठेला गाड़ी में साफ़ रेत देखें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o5':
        'निर्माण में चालन ज़रूरी है, ताकि सीमेंट का मसाला एक-समान और मज़बूत बने।',
    's1_hud_1': 'चरण 1: आटे और चोकर के कप को खींचकर रसोई की छलनी पर डालें।',
    's1_hud_2':
        "चरण 2: छलनी को दबाकर रखें (या 'छलनी हिलाएँ' पर टैप करें), ताकि वह दाएँ-बाएँ हिले।",
    's1_hud_3': 'चरण 3: चोकर वाली छलनी को खींचकर कचरे के डिब्बे में खाली करें।',
    's1_hud_4':
        "चरण 4: अवलोकन पूर्ण! कटोरे में शुद्ध आटा देखें और 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1': 'चरण 1: फावड़े को खींचकर रेत और कंकड़ के ढेर से मिश्रण उठाएँ।',
    's2_hud_2':
        'चरण 2: भरे फावड़े को खींचकर मिश्रण को निर्माण छलनी की ऊपरी ढलान पर डालें।',
    's2_hud_3':
        "चरण 3: छलनी को दबाकर रखें (या 'छलनी हिलाएँ' पर टैप करें), ताकि बारीक रेत छनकर ठेले में जाए।",
    's2_hud_4': "चरण 4: कंकड़ हटाने के लिए 'कंकड़ गिराएँ' पर टैप करें।",
    's2_hud_5':
        "चरण 5: अवलोकन पूर्ण! साफ़ रेत देखें और 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_shake': 'छलनी हिलाएँ',
    'btn_dump': 'कंकड़ गिराएँ',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_cup': 'मिश्रण का कप',
    'lbl_sieve': 'रसोई की छलनी',
    'lbl_bin': 'कचरे का डिब्बा',
    'lbl_shovel': 'रेत का फावड़ा',
    'lbl_screen': 'निर्माण छलनी (चालना)',
    'lbl_barrow': 'ठेला गाड़ी',
    'lbl_pile': 'रेत और कंकड़ का ढेर',
    'cnt_sift': 'चालन प्रगति: {p}%',
    'cnt_screen': 'छानने की प्रगति: {p}%',
    'e_cup': 'मिश्रण डालने के लिए कप को रसोई की छलनी पर छोड़ें।',
    'e_sieve': 'चोकर खाली करने के लिए छलनी को कचरे के डिब्बे के ऊपर छोड़ें।',
    'e_pile': 'मिश्रण उठाने के लिए फावड़े को रेत और कंकड़ के ढेर पर ले जाएँ।',
    'e_screen': 'मिश्रण को निर्माण छलनी की ऊपरी ढलान पर छोड़ें।',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1':
        'चालन सफल! आपने चालन विधि का उपयोग किया। आटे के बारीक कण छलनी के छिद्रों से नीचे निकल जाते हैं, जबकि चोकर के बड़े कण ऊपर ही फँसे रह जाते हैं।',
    'sum_s2':
        'रेत शुद्ध! यह बड़े पैमाने पर चालन है। रसोई हो या निर्माण स्थल, चालन मिश्रण के घटकों को उनके कणों के आकार के अंतर से कुशलता से अलग करता है।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'रसोई की मेज़, जिस पर आटे और चोकर के मिश्रण का कप, काँच के कटोरे पर रखी तार की छलनी और कचरे का डिब्बा है',
    'scene_s2':
        'निर्माण स्थल, जहाँ रेत और कंकड़ का ढेर, फावड़ा, और ठेला गाड़ी के ऊपर रखी तिरछी तार की जाली है',
  },
};

/// Scenarios and the number of steps of each (HTML `ScenariosData`).
const int _scenarioCount = 2;
const List<int> _stepCounts = [4, 5];

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

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10–12 px label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// While the sidebar is collapsed the scene slides right (and on small
/// screens shrinks) so the floating mission card at the top left leaves
/// everything the learner taps, drags or reads in view; the move follows
/// the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Gap (design px) kept between the scene and the mission card / tools.
const double _cardGap = 16;

/// Smallest scale the collapsed-sidebar fit may use.
const double _minFit = 0.6;

/// Design x extent of what the learner taps, drags or reads (objects and
/// their labels): Scenario 1 from the cup's label to the bin's right side,
/// Scenario 2 from the shovel's label to the heap of pebbles.
const (double, double) _kitchenExtent = (165, 835);
const (double, double) _siteExtent = (160, 725);

/// Key of the scene layer. Flows map scene design coordinates to the screen
/// through it, so they follow the collapsed-sidebar move.
const ValueKey<String> _sceneKey = ValueKey('ch9-a3-scene');

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// The same point at height [h].
  _V atY(double h) => _V(x, h, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Distance from [p] to the segment [a]–[b] (screen space).
double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// Is [p] inside the convex polygon [q] (screen space)?
bool _inConvex(List<Offset> q, Offset p) {
  var sign = 0;
  for (var i = 0; i < q.length; i++) {
    final a = q[i];
    final b = q[(i + 1) % q.length];
    final c = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
    final side = c > 0 ? 1 : (c < 0 ? -1 : 0);
    if (side == 0) continue;
    if (sign == 0) {
      sign = side;
    } else if (side != sign) {
      return false;
    }
  }
  return true;
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
  final _V f;
  final _V r;
  final _V u;

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

  /// Where the ray through [s] meets the plane through [at] with normal
  /// [normal] (HTML `raycaster.ray.intersectPlane(dragPlane)`).
  _V? onPlane(Offset s, _V normal, _V at) {
    final dir = ray(s);
    final den = dir.dot(normal);
    if (den.abs() < 1e-6) return null;
    final t = (at - eye).dot(normal) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Where the ray through [s] meets the horizontal plane y = [h].
  _V? onPlaneY(Offset s, double h) => onPlane(s, _V.up, _V(0, h, 0));
}

/// HTML `resetCamera()` on screens wider than 640 px: position (0, 15, 24)
/// looking at (0, 3, 0), in both scenarios. The look-at point is drawn
/// 30 px left of the stage centre in Scenario 1 (its bin is near the tool
/// column) and at the centre in Scenario 2, whose objects lie further left.
final _Cam _camKitchen = _Cam(
  const _V(0, 15, 24),
  const _V(0, 3, 0),
  const Offset(470, 280),
);
final _Cam _camSite = _Cam(
  const _V(0, 15, 24),
  const _V(0, 3, 0),
  const Offset(500, 280),
);

/// HTML `DirectionalLight(0xffffff, 0.65)` at (10, 25, 15), normalised.
const _V _light = _V(0.3244, 0.8111, 0.4867);

/// HTML `AmbientLight(0xffffff, 0.85)` plus the key light, toned down so the
/// lit faces do not all clip to white.
const double _ambient = 0.62;
const double _diffuse = 0.5;

/// The bright sand pile gets less ambient light, so its cone shows its
/// shape.
const double _pileAmbient = 0.42;
const double _pileDiffuse = 0.75;

// ------------------------------------------------- scenario 1: the kitchen

/// Table `BoxGeometry(36, 1.5, 20)` with its top at y 0.
const double _tableHalfX = 18;
const double _tableHalfZ = 10;
const double _tableThick = 1.5;

/// Bowl at (0, 0.1, 0): open glass `CylinderGeometry(5, 3.5, 3)` on a
/// 0.3-thick base of radius 3.5.
const _V _bowlBase = _V(0, 0.1, 0);
const double _bowlR0 = 3.5;
const double _bowlR1 = 5;
const double _bowlH = 3;
const double _bowlFloor = 0.3;

/// The sifted flour (`flourMoundS1`, ConeGeometry(3.8, 2) scaled with the
/// progress): a heap on the bowl's floor, narrower than 3.8 so it stays
/// inside the glass.
const double _moundR = 3.6;
const double _moundH = 2;

/// Sieve at (0, 3.3, 0): the mesh (radius 5.2) at its anchor, the open rim
/// `CylinderGeometry(5.3, 5.3, 0.8)` above it. Grid wires 0.65 apart.
const _V _sieveHome = _V(0, 3.3, 0);
const double _sieveR = 5.3;
const double _sieveRimH = 0.8;
const double _meshR = 5.2;
const double _meshGap = 0.65;
const int _meshLines = 7;

/// The flour powder under the bran flakes on the mesh.
const double _powderR = 4;

/// HTML dump: the sieve goes to (10, 6.5, 0) over the bin; it now also
/// tips (0.6 rad) to empty the bran.
const _V _sieveOverBin = _V(10, 6.5, 0);
const double _dumpTilt = 0.6;

/// Cup at (-8, 1.5, 4): open `CylinderGeometry(2, 1.5, 3)`, its mixture a
/// `SphereGeometry(1.8)` 1.2 above the cup's centre.
const _V _cupHome = _V(-8, 1.5, 4);
const double _cupR0 = 1.5;
const double _cupR1 = 2;
const double _cupH = 3;
const double _mixR = 1.8;
const double _mixY = 1.2;

/// HTML pour: the cup goes to (0, 6, 0). It now tips 1.1 rad towards the
/// sieve as it goes, so it stops a little to the left, its mouth over the
/// middle of the sieve.
const _V _cupPour = _V(-1.5, 6.5, 0);
const double _pourTilt = 1.1;

/// Waste bin at (10, 2.5, 0): `CylinderGeometry(3.6, 2.6, 5)`, rim
/// `TorusGeometry(3.6, 0.25)`, eight ribs 4.4 tall.
const _V _binPos = _V(10, 2.5, 0);
const double _binR0 = 2.6;
const double _binR1 = 3.6;
const double _binH = 5;
const double _binTube = 0.25;
const int _binRibs = 8;
const double _ribLow = 0.3;
const double _ribHigh = 4.7;

/// Glowing drop zones: `sieveZoneS1` RingGeometry(3, 5.5) at (0, 4.2, 0)
/// (step 1) and `binZoneS1` RingGeometry(2.2, 5) at (10, 5.2, 0) (step 3).
const _V _sieveZone = _V(0, 4.2, 0);
const _V _binZone = _V(10, 5.2, 0);

/// Drop tests, where the learner sees the object: the cup's centre within
/// 4.5 units (HTML: 4.5 from the sieve's axis) of the axis above the sieve,
/// the sieve's centre within 4.5 units (HTML: 5) of the axis above the bin.
const _V _sieveAxisLow = _V(0, 4.1, 0);
const _V _sieveAxisHigh = _V(0, 8, 0);
const _V _binAxisLow = _V(10, 5, 0);
const _V _binAxisHigh = _V(10, 9, 0);
const double _cupRange = 4.5;
const double _binRange = 4.5;

// --------------------------------------- scenario 2: the construction site

/// Ground `CylinderGeometry(25, 25, 1)` with its top at y 0.
const double _groundR = 25;

/// Sand and pebble pile at (-8, 0, -3): `ConeGeometry(4.2, 3.2)` with 35
/// pebbles; `pileZoneS2` RingGeometry(2, 5.5) around it (step 1).
const _V _pilePos = _V(-8, 0, -3);
const double _pileR = 4.2;
const double _pileH = 3.2;
const _V _pileZone = _V(-8, 0.02, -3);

/// The shovel scoops when its blade is dropped on the middle of the pile
/// (within 3 units on screen). The HTML accepted it 6.5 units from the
/// pile's centre, which the shovel already almost was (7.1) before it
/// moved.
const _V _pileTarget = _V(-8, 1.3, -3);
const double _pileRange = 3;

/// Shovel at (-9, 2.5, 4). The HTML stood it on its handle with the blade
/// on top; it now stands on its blade (2.2 × 2.5, `BoxGeometry(2.2, 2.5,
/// 0.3)`) with the handle (6 long, radius 0.15) and a grip above.
const _V _shovelHome = _V(-9, 2.5, 4);
const double _bladeDrop = 1.2;
const double _bladeW = 2.2;
const double _bladeH = 2.5;
const double _bladeZ = 0.2;
const double _handleLen = 5.5;
const double _handleR = 0.15;
const double _gripHalf = 0.45;

/// HTML scoop: the shovel dips to (-7, 3.5, -2) and comes back.
const _V _scoopPos = _V(-7, 3.5, -2);

/// HTML load: the shovel goes over the upper slope (HTML (-2, 7.5, 0)); it
/// now tips 0.5 rad there.
const _V _loadPos = _V(-0.4, 8.7, 0.5);
const double _tipLean = 0.5;

/// The construction screen. The HTML stood a 9.6 × 8 wire mesh upright and
/// turned it -π/6 in its own plane, so it cut through the wheelbarrow and
/// one corner went below the ground. It is now a slanted ramp of the same
/// size: its lower end at (4.66, 2.8, 0) just past the wheelbarrow, 9.6
/// long up the slope at π/6, 8 wide, on four posts. 'Dump Pebbles' tips it
/// to π/3 about its lower end and back (HTML: rotation.z to -π/3, yoyo).
const _V _rampLow = _V(4.66, 2.8, 0);
const double _rampLen = 9.6;
const double _rampHalfW = 4;
const double _rampAngle = math.pi / 6;
const double _tipExtra = math.pi / 6;
const double _railR = 0.3;
const double _postR = 0.22;
const double _postLowU = 0.25;
const double _postHighU = 9.3;
const double _wireGap = 0.6;

/// The mixture on the screen (HTML `pebblesOnScreenS2`): around 6.1 along
/// the slope, its sand a patch of radius 2.4.
const double _mixU = 6.1;
const double _sandPatchR = 2.4;

/// `screenZoneS2` (step 2): a glowing ring on the upper slope.
const double _zoneU = 6.6;
const double _zoneIn = 1.6;
const double _zoneOut = 2.8;

/// The shovel's load counts as on the upper slope when its blade is, on
/// screen, within 3 units of the slope's upper half (HTML: 5.5 units from
/// (-2, 0)).
const double _upperFrom = 0.45;
const double _screenRange = 3;

/// Wheelbarrow at (0, 1.2, 0), `BoxGeometry(8, 2.5, 6)`: an open tray (top
/// 8 × 6 at y 2.45, floor 6.4 × 4.8 at y 0.55) with a wheel, two handles
/// and two legs (added, so it reads as a wheelbarrow).
const double _trayTop = 2.45;
const double _trayFloor = 0.55;
const double _trayTopX = 4;
const double _trayTopZ = 3;
const double _trayFloorX = 3.2;
const double _trayFloorZ = 2.4;
const _V _wheelAt = _V(4.6, 0.65, 0);
const double _wheelR = 0.65;

/// The sifted sand (`sandInBarrowS2`, ConeGeometry(3.5, 2) scaled with the
/// progress): a heap on the tray's floor.
const double _heapR = 3;
const double _heapH = 2.1;

/// Gap (design px) between the shovel's handle and the pile's label.
const double _labelGap = 10;

/// Where the barrow's label hangs: on the ground in front of it.
const _V _barrowLabelAt = _V(0, 0, 3.6);

/// HTML `stoneRubbleS2` at (7, 0.8, 0): 30 stones within ±2.
const _V _rubbleAt = _V(7, 0, 0);

// ------------------------------------------------------------- animation

/// HTML `animate()` while shaking: `siftProgress += 1.5` per frame (60 fps)
/// and `position.x = sin(Date.now() * 0.05) * 0.4` (0.05 rad per ms).
const double _siftPerSecond = 90;
const double _shakeRate = 50;
const double _shakeAmp = 0.4;

/// A tap on 'Shake Sieve' shakes for 0.4 s (added: the HTML button worked
/// only while held, which a sidebar button cannot sense).
const double _burstSeconds = 0.4;

/// HTML tweens (ms, TWEEN.js default Linear): the cup to the sieve 400; the
/// sieve to the bin 400 and back 500; the shovel into the pile 300 and back
/// 300; the shovel to the screen 400; the screen tipping 500 and back 500;
/// a refused object back home 400. Added: the empty cup and shovel go back
/// home (400 each; the HTML hid them).
const int _pourMs = 400;
const int _cupBackMs = 400;
const int _dumpMoveMs = 400;
const int _sieveBackMs = 500;
const int _scoopMs = 300;
const int _loadMs = 400;
const int _shovelBackMs = 400;
const int _tipMs = 500;
const int _returnMs = 400;

/// The mixture drops onto the sieve / screen, and the bran into the bin,
/// in 0.3 s (added: the HTML swapped them in at once).
const double _fallSeconds = 0.3;

/// Flour and sand fall through the mesh while it shakes (added).
const double _fallRate = 2.2;

/// 'Dump Pebbles': each pebble slides down the tipping screen in 0.35 s,
/// then drops onto the heap in 0.3 s, up to 0.3 s after the first.
const double _slideSeconds = 0.35;
const double _flySeconds = 0.3;

/// HTML `update3DHighlight`: the object to use pulses towards light blue,
/// `(sin(Date.now() * 0.008) + 1) / 2`, lerped by up to 0.85 into its
/// emissive colour (here: up to half way to the highlight colour).
const double _pulseRate = 8;
const double _pulseMax = 0.5;

/// The scene objects. The learner drags the cup, the sieve and the shovel,
/// and presses and holds the sieve and the screen to shake them.
enum _Obj { cup, sieve, bowl, bin, shovel, screen, barrow, pile }

/// A straight move between two points over [seconds] from [start] (scene
/// time): a TWEEN.js tween on `position` with its default Linear easing.
@immutable
class _Move {
  const _Move(this.from, this.to, this.start, this.seconds);

  const _Move.still(_V at) : from = at, to = at, start = 0, seconds = 0;

  final _V from;
  final _V to;
  final double start;
  final double seconds;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, (t - start) / seconds);
  }
}

/// A number eased from [from] to [to] (a TWEEN.js tween on a scalar).
@immutable
class _Anim {
  const _Anim(this.from, this.to, this.start, this.seconds);

  const _Anim.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0;

  final double from;
  final double to;
  final double start;
  final double seconds;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * (t - start) / seconds;
  }
}

/// A bit of the mixture on the sieve (HTML `branOnSieveS1`): [a] / [b]
/// across the mesh, [h] above it, radius [r]; [fine] is flour (every third
/// one in the HTML), the rest bran.
@immutable
class _Grain {
  const _Grain(this.a, this.b, this.h, this.r, {this.fine = false});

  final double a;
  final double b;
  final double h;
  final double r;
  final bool fine;
}

/// HTML loop: 60 tries at x / z ±3.5, y 0–0.4, kept within 4.2 of the
/// centre; radius 0.25 (fixed seed, so every run looks the same).
final List<_Grain> _branGrains = () {
  final rnd = math.Random(11);
  final out = <_Grain>[];
  for (var i = 0; i < 60; i++) {
    final x = (rnd.nextDouble() - 0.5) * 7;
    final y = rnd.nextDouble() * 0.4;
    final z = (rnd.nextDouble() - 0.5) * 7;
    if (math.sqrt(x * x + y * y + z * z) < 4.2) {
      out.add(_Grain(x, z, 0.2 + y, 0.25, fine: i % 3 == 0));
    }
  }
  // Far to near.
  out.sort((p, q) => p.b.compareTo(q.b));
  return out;
}();

/// White flecks of flour on the cup's heaped mixture (offsets in world
/// units from the heap's centre, as seen on screen).
final List<Offset> _mixFlecks = () {
  final rnd = math.Random(19);
  final out = <Offset>[];
  while (out.length < 12) {
    final o = Offset(
      (rnd.nextDouble() - 0.5) * 2.8,
      -rnd.nextDouble() * 1.6 + 0.1,
    );
    if (o.distance < 1.5) out.add(o);
  }
  return out;
}();

/// A falling bit (flour or sand going through the mesh): where it leaves
/// the mesh ([a], [b]), when in its cycle ([phase]) and how fast.
@immutable
class _Fall {
  const _Fall(this.a, this.b, this.phase, this.speed);

  final double a;
  final double b;
  final double phase;
  final double speed;
}

/// Flour falling into the bowl: from anywhere within 3.6 of the middle.
final List<_Fall> _flourFalls = () {
  final rnd = math.Random(13);
  return [
    for (var i = 0; i < 36; i++)
      () {
        final r = 3.6 * math.sqrt(rnd.nextDouble());
        final a = rnd.nextDouble() * 2 * math.pi;
        return _Fall(
          r * math.cos(a),
          r * math.sin(a),
          rnd.nextDouble(),
          0.8 + rnd.nextDouble() * 0.5,
        );
      }(),
  ];
}();

/// Sand falling into the wheelbarrow: from under the mixture on the screen
/// ([a] along the slope, [b] across it).
final List<_Fall> _sandFalls = () {
  final rnd = math.Random(17);
  return [
    for (var i = 0; i < 36; i++)
      _Fall(
        _mixU + (rnd.nextDouble() - 0.5) * 3.6,
        (rnd.nextDouble() - 0.5) * 4.4,
        rnd.nextDouble(),
        0.8 + rnd.nextDouble() * 0.5,
      ),
  ];
}();

/// Sand grains on the screen's mixture (along / across the slope).
final List<Offset> _sandDots = () {
  final rnd = math.Random(23);
  return [
    for (var i = 0; i < 40; i++)
      Offset(
        _mixU + (rnd.nextDouble() - 0.5) * 3.8,
        (rnd.nextDouble() - 0.5) * 4.4,
      ),
  ];
}();

/// A pebble on the screen (HTML `pebblesOnScreenS2`: 50 bits, half of them
/// pebbles): [u] along the slope, [v] across, radius [r]; where it lands on
/// the heap (HTML `stoneRubbleS2`) and how long after the first it slides.
@immutable
class _Pebble {
  const _Pebble(this.u, this.v, this.r, this.heap, this.delay);

  final double u;
  final double v;
  final double r;
  final _V heap;
  final double delay;
}

final List<_Pebble> _screenPebbles = () {
  final rnd = math.Random(29);
  return [
    for (var i = 0; i < 30; i++)
      () {
        final r = 0.38 + rnd.nextDouble() * 0.17;
        return _Pebble(
          _mixU + (rnd.nextDouble() - 0.5) * 3.8,
          (rnd.nextDouble() - 0.5) * 4.6,
          r,
          _rubbleAt +
              _V(
                (rnd.nextDouble() - 0.5) * 4,
                r + rnd.nextDouble() * 0.5,
                (rnd.nextDouble() - 0.5) * 4,
              ),
          rnd.nextDouble() * 0.3,
        );
      }(),
  ];
}();

/// The pebbles on the heap, far to near.
final List<_Pebble> _heapOrder = [..._screenPebbles]
  ..sort((a, b) => a.heap.z.compareTo(b.heap.z));

/// The pile's pebbles (HTML: 35, radius 0.4–0.7, within 3.5 of the middle)
/// on the cone's surface, those the camera sees, far to near.
final List<({_V at, double r})> _pilePebbles = () {
  final rnd = math.Random(31);
  final out = <({_V at, double r})>[];
  for (var i = 0; i < 35; i++) {
    final a = rnd.nextDouble() * 2 * math.pi;
    final rad = rnd.nextDouble() * 3.5;
    final r = 0.4 + rnd.nextDouble() * 0.3;
    if (math.sin(a) < -0.2 && rad > 1.2) continue;
    final y = _pileH * (1 - rad / _pileR) - r * 0.3;
    out.add((at: _pilePos + _V(math.cos(a) * rad, y, math.sin(a) * rad), r: r));
  }
  out.sort((p, q) => p.at.z.compareTo(q.at.z));
  return out;
}();

/// Darker sand grains on the side of the pile the camera sees.
final List<_V> _pileGrains = () {
  final rnd = math.Random(37);
  final out = <_V>[];
  while (out.length < 70) {
    final a = rnd.nextDouble() * 2 * math.pi;
    final rad = 0.4 + rnd.nextDouble() * 3.7;
    if (math.sin(a) < -0.3) continue;
    out.add(
      _pilePos +
          _V(
            math.cos(a) * rad,
            _pileH * (1 - rad / _pileR) + 0.03,
            math.sin(a) * rad,
          ),
    );
  }
  return out;
}();

/// A point on the screen: [u] up the slope from its lower end, [v] across,
/// [h] above the mesh, with the screen at [angle] and moved [shakeX]
/// sideways.
_V _rampPoint(double angle, double shakeX, double u, double v, [double h = 0]) {
  final c = math.cos(angle), s = math.sin(angle);
  return _V(_rampLow.x + shakeX - c * u + s * h, _rampLow.y + s * u + c * h, v);
}

/// The shovel's handle direction, leaning [lean] radians towards +x.
_V _shovelUp(double lean) => _V(math.sin(lean), math.cos(lean), 0);

/// The middle of the shovel's blade, below its anchor along the handle.
_V _bladeCentre(_V anchor, double lean) =>
    anchor - _shovelUp(lean) * _bladeDrop;

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// HTML `State.isAnimating`: an object glides or an animation runs, and
  /// the scene ignores drags meanwhile.
  bool busy = false;

  /// 'Finish Observation' was tapped: the scenario is complete.
  bool done = false;

  /// The object being dragged.
  _Obj? held;

  /// Where the cup, the sieve and the shovel are, and where a refused drop
  /// sends them back (`userData.homePos`).
  final Map<_Obj, _Move> pos = {};
  final Map<_Obj, _V> home = {};

  /// HTML `State.siftProgress` (0–100) and `State.isShaking`; the shaken
  /// sieve / screen's sideways offset (`position.x`).
  double progress = 0;
  bool shaking = false;
  double shakeX = 0;

  // ------------------------------------------------------------ scenario 1
  bool cupFull = true;
  _Anim cupTilt = const _Anim.still(0);

  /// HTML `branOnSieveS1.visible`: the mixture is on the sieve (poured at
  /// [pourAt]).
  bool branOn = false;
  double pourAt = -10;
  _Anim sieveTilt = const _Anim.still(0);

  /// The bran was emptied into the bin at [branDumpAt].
  double branDumpAt = -10;

  // ------------------------------------------------------------ scenario 2
  bool shovelLoaded = false;
  _Anim shovelLean = const _Anim.still(0);

  /// HTML `pebblesOnScreenS2.visible`: the mixture is on the screen (tipped
  /// there at [loadAt]).
  bool mixOnScreen = false;
  double loadAt = -10;

  /// 'Dump Pebbles': the screen's extra tilt, and when it started.
  _Anim screenTip = const _Anim.still(0);
  double dumpAt = -10;

  /// HTML `stoneRubbleS2.visible`.
  bool rubbleShown = false;

  _V posOf(_Obj obj) => pos[obj]!.at(time);

  /// Sifting done so far, 0 … 1.
  double get sifted => progress / 100;

  /// HTML `getNextStepDraggable()`: the object the current step drags.
  _Obj? get target {
    if (done || busy) return null;
    if (scenario == 0) {
      return switch (step) {
        1 => _Obj.cup,
        3 => _Obj.sieve,
        _ => null,
      };
    }
    return step <= 2 ? _Obj.shovel : null;
  }

  /// The object pressed and held to shake it (HTML 'Hold to Shake Sieve'
  /// in Scenario 1 step 2 and Scenario 2 step 3).
  _Obj? get holdTarget {
    if (done || busy) return null;
    if (scenario == 0) return step == 2 ? _Obj.sieve : null;
    return step == 3 ? _Obj.screen : null;
  }

  /// The sieve / screen may be shaken now.
  bool get shakeStep => holdTarget != null;

  /// The progress readout shows during the shaking step.
  bool get showProgress =>
      !done && step == (scenario == 0 ? 2 : 3) && progress < 100;

  /// The object that pulses (HTML `update3DHighlight`; the object to shake
  /// pulses too, as the HTML's shake button did).
  _Obj? get glowing => held ?? target ?? holdTarget;

  /// The last step: 'Finish Observation' opens the summary.
  bool get finishStep => step == _stepCounts[scenario] || done;

  /// Scenario 2 step 4: 'Dump Pebbles'.
  bool get dumpStep => scenario == 1 && step == 4 && !done;

  /// The scene's objects in tap-test order (front first).
  List<_Obj> get objects => scenario == 0
      ? const [_Obj.cup, _Obj.sieve, _Obj.bin]
      : const [_Obj.shovel, _Obj.screen, _Obj.barrow, _Obj.pile];

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = null;
    progress = 0;
    shaking = false;
    shakeX = 0;
    pos.clear();
    home
      ..clear()
      ..addAll({
        _Obj.cup: _cupHome,
        _Obj.sieve: _sieveHome,
        _Obj.shovel: _shovelHome,
      });
    home.forEach((obj, at) => pos[obj] = _Move.still(at));
    cupFull = true;
    cupTilt = const _Anim.still(0);
    branOn = false;
    pourAt = -10;
    sieveTilt = const _Anim.still(0);
    branDumpAt = -10;
    shovelLoaded = false;
    shovelLean = const _Anim.still(0);
    mixOnScreen = false;
    loadAt = -10;
    screenTip = const _Anim.still(0);
    dumpAt = -10;
    rubbleShown = false;
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the object the current step lets the learner drag ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

/// How the scene layer is placed while the sidebar is collapsed: scale [k]
/// and offset ([dx], [dy]) in design pixels.
typedef _Fit = ({double k, double dx, double dy});

const _Fit _noFit = (k: 1, dx: 0, dy: 0);

Duration _ms(int ms) => Duration(milliseconds: ms);

class _SievingLabState extends State<Ch9A3SievingPage>
    with SingleTickerProviderStateMixin {
  /// HTML `State.isCamLocked: true`.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in scene pixels for the current stage
  /// scale, and the tool column's left edge in scene pixels (set while
  /// laying out).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// Where the finger holds the object relative to its anchor (screen), and
  /// the anchor's position when it was picked up (the drag plane faces the
  /// camera through it, HTML `dragPlane.setFromNormalAndCoplanarPoint`).
  Offset _grabShift = Offset.zero;
  _V _grabAt = _V.zero;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// The pointer pressing and holding the sieve / screen, and the scene
  /// time until which taps on 'Shake Sieve' keep it shaking.
  int? _holdPointer;
  double _burstUntil = -1;

  /// The press that started shaking also ends as a tap (when the sifting
  /// finishes before the finger lifts); that tap is not a new request.
  bool _swallowTap = false;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `sN_hud_M` of the current step.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

  _Cam get _cam => _scene.scenario == 0 ? _camKitchen : _camSite;

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

  /// HTML `animate()`: tweens are functions of the scene time; the shaking
  /// sieve / screen sifts every frame. Repaints the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    _tickShake(dt);
    _frame.value = now;
  }

  /// While the sieve / screen is held (or a tap's shake lasts): it moves
  /// side to side and the sifting progress rises by 90% a second.
  void _tickShake(double dt) {
    final s = _scene;
    final on = s.shakeStep && (_holdPointer != null || s.time < _burstUntil);
    s.shaking = on;
    if (!on) {
      s.shakeX = 0;
      return;
    }
    s.shakeX = math.sin(s.time * _shakeRate) * _shakeAmp;
    s.progress = math.min(100, s.progress + _siftPerSecond * dt);
    if (s.progress >= 100) _siftDone();
  }

  /// HTML: at 100% the sieve stops in the middle and the step moves on.
  void _siftDone() {
    final s = _scene;
    _holdPointer = null;
    _burstUntil = -1;
    setState(() {
      s
        ..shaking = false
        ..shakeX = 0
        ..step += 1;
    });
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _holdPointer = null;
    _burstUntil = -1;
    _moved = false;
    setState(() => _scene.load(index));
    _lab.resetView(sound: false);
  }

  void _setBusy(bool busy) {
    if (!mounted || _scene.busy == busy) return;
    setState(() => _scene.busy = busy);
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

  /// HTML `triggerMainAction()` ('Finish Observation'): the scenario is
  /// done and its summary opens (again, if the learner closed it).
  void _finish() {
    final s = _scene;
    if (!_lab.isLabActive || !s.finishStep) return;
    if (!s.done) setState(() => s.done = true);
    final sc = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () => _t('sum_s${sc + 1}'),
    );
  }

  /// [obj] glides to [to] in [ms] (TWEEN.js default: linear).
  void _glide(_Obj obj, _V to, int ms) {
    final s = _scene;
    s.pos[obj] = _Move(s.posOf(obj), to, s.time, ms / 1000);
  }

  /// A refused drop: the object goes back home in 400 ms. The HTML said
  /// nothing; the toast [key] now says where it goes.
  void _revert(_Obj obj, String key) {
    _toast(key, error: true, sound: true);
    _setBusy(true);
    _glide(obj, _scene.home[obj]!, _returnMs);
    _lab.after(_ms(_returnMs), () {
      if (!mounted) return;
      _setBusy(false);
    });
  }

  // ------------------------------------------------- scenario 1 actions

  /// Step 1 done (HTML 'pour'): the cup goes over the sieve tipping its
  /// mixture out, and the mixture lands on the mesh; the empty cup goes
  /// back to its place (the HTML hid it).
  void _pour() {
    final s = _scene;
    _Sound.drop.play();
    _setBusy(true);
    _glide(_Obj.cup, _cupPour, _pourMs);
    s.cupTilt = _Anim(0, _pourTilt, s.time, _pourMs / 1000);
    _lab.after(_ms(_pourMs), () {
      if (!mounted) return;
      _glide(_Obj.cup, _cupHome, _cupBackMs);
      s.cupTilt = _Anim(_pourTilt, 0, s.time, _cupBackMs / 1000);
      setState(() {
        s
          ..cupFull = false
          ..branOn = true
          ..pourAt = s.time
          ..progress = 0
          ..busy = false
          ..step = 2;
      });
    });
  }

  /// Step 3 done (HTML 'pour'): the sieve goes over the bin (tipping, so
  /// the bran falls in) and back home over the bowl.
  void _dumpBran() {
    final s = _scene;
    _Sound.drop.play();
    _setBusy(true);
    _glide(_Obj.sieve, _sieveOverBin, _dumpMoveMs);
    s.sieveTilt = _Anim(0, _dumpTilt, s.time, _dumpMoveMs / 1000);
    _lab.after(_ms(_dumpMoveMs), () {
      if (!mounted) return;
      _glide(_Obj.sieve, _sieveHome, _sieveBackMs);
      s.sieveTilt = _Anim(_dumpTilt, 0, s.time, _sieveBackMs / 1000);
      setState(() {
        s
          ..branOn = false
          ..branDumpAt = s.time;
      });
    });
    _lab.after(_ms(_dumpMoveMs + _sieveBackMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 4;
      });
    });
  }

  // ------------------------------------------------- scenario 2 actions

  /// Step 1 done (HTML 'pour'): the shovel dips into the pile, comes back
  /// loaded with sand and pebbles.
  void _scoop() {
    final s = _scene;
    _Sound.drop.play();
    _setBusy(true);
    _glide(_Obj.shovel, _scoopPos, _scoopMs);
    _lab.after(_ms(_scoopMs), () {
      if (!mounted) return;
      _glide(_Obj.shovel, _shovelHome, _scoopMs);
      setState(() => s.shovelLoaded = true);
    });
    _lab.after(_ms(2 * _scoopMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 2;
      });
    });
  }

  /// Step 2 done (HTML 'pour'): the shovel goes over the upper slope and
  /// tips its load onto the screen, then goes back empty (the HTML hid it).
  void _loadScreen() {
    final s = _scene;
    _Sound.drop.play();
    _setBusy(true);
    _glide(_Obj.shovel, _loadPos, _loadMs);
    s.shovelLean = _Anim(0, _tipLean, s.time, _loadMs / 1000);
    _lab.after(_ms(_loadMs), () {
      if (!mounted) return;
      _glide(_Obj.shovel, _shovelHome, _shovelBackMs);
      s.shovelLean = _Anim(_tipLean, 0, s.time, _shovelBackMs / 1000);
      setState(() {
        s
          ..shovelLoaded = false
          ..mixOnScreen = true
          ..loadAt = s.time
          ..progress = 0
          ..busy = false
          ..step = 3;
      });
    });
  }

  /// HTML `dumpPebbles()` ('Dump Pebbles', step 4): the screen tips to
  /// π/3 and back (500 ms each way); the pebbles slide off its lower end
  /// onto a heap of their own; then step 5.
  void _dumpPebbles() {
    final s = _scene;
    if (!_lab.isLabActive || !s.dumpStep || s.busy) return;
    _Sound.drop.play();
    setState(() {
      s
        ..busy = true
        ..dumpAt = s.time
        ..screenTip = _Anim(0, _tipExtra, s.time, _tipMs / 1000);
    });
    _lab.after(_ms(_tipMs), () {
      if (!mounted) return;
      s.screenTip = _Anim(_tipExtra, 0, s.time, _tipMs / 1000);
    });
    _lab.after(_ms(2 * _tipMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..mixOnScreen = false
          ..rubbleShown = true
          ..busy = false
          ..step = 5;
      });
    });
  }

  // -------------------------------------------------------------- shaking

  /// HTML `startShake()` plays 'shake' when the shaking starts.
  void _startShake() {
    if (!_scene.shaking) _Sound.pop.play();
  }

  /// 'Shake Sieve': each tap shakes the sieve / screen 0.4 s longer.
  void _shakeTap() {
    final s = _scene;
    if (!_lab.isLabActive || !s.shakeStep) return;
    _startShake();
    _burstUntil = math.max(_burstUntil, s.time) + _burstSeconds;
  }

  /// HTML `onpointerdown="startShake()"`: pressing the sieve (step 2) or the
  /// screen (Scenario 2 step 3) shakes it until the finger lifts.
  void _onPointerDown(PointerDownEvent e) {
    _swallowTap = false;
    final obj = _scene.holdTarget;
    if (!_lab.isLabActive || obj == null || _holdPointer != null) return;
    if (!_holdArea(obj, e.localPosition)) return;
    _holdPointer = e.pointer;
    _swallowTap = true;
    _startShake();
  }

  /// HTML `onpointerup="stopShake()"` (a cancelled touch stops it too).
  void _onPointerUp(PointerEvent e) {
    if (e.pointer == _holdPointer) _holdPointer = null;
  }

  // -------------------------------------------------------------- gestures

  /// The box [centre] ± [half] on screen, at least a 48 dp target.
  Rect _box(_V centre, _V half) {
    final cam = _cam;
    var rect = Rect.fromCircle(center: cam.p(centre), radius: _touch);
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final c = cam.p(centre + _V(sx * half.x, sy * half.y, sz * half.z));
          rect = rect.expandToInclude(Rect.fromLTWH(c.dx, c.dy, 0, 0));
        }
      }
    }
    return rect;
  }

  /// The screen's mesh on screen (its four corners).
  List<Offset> _rampQuad() {
    final s = _scene;
    final angle = _rampAngle + s.screenTip.at(s.time);
    return [
      for (final (u, v) in const [
        (0.0, -_rampHalfW),
        (_rampLen, -_rampHalfW),
        (_rampLen, _rampHalfW),
        (0.0, _rampHalfW),
      ])
        _camSite.p(_rampPoint(angle, s.shakeX, u, v)),
    ];
  }

  /// HTML meshes as screen rectangles, at least a 48 dp target.
  Rect _hitRect(_Obj obj) {
    final s = _scene;
    switch (obj) {
      case _Obj.cup:
        return _box(
          s.posOf(obj) + const _V(0, 0.75, 0),
          const _V(_cupR1, 2.25, _cupR1),
        );
      case _Obj.sieve:
        return _box(
          s.posOf(obj) + _V(s.shakeX, _sieveRimH / 2, 0),
          const _V(_sieveR, 0.6, _sieveR),
        );
      case _Obj.bowl:
        return _box(
          _bowlBase + const _V(0, _bowlH / 2, 0),
          const _V(_bowlR1, _bowlH / 2, _bowlR1),
        );
      case _Obj.bin:
        return _box(_binPos, const _V(_binR1, _binH / 2, _binR1));
      case _Obj.shovel:
        return _box(s.posOf(obj) + const _V(0, 1.5, 0), const _V(1.1, 4, 0.4));
      case _Obj.pile:
        return _box(
          _pilePos + const _V(0, _pileH / 2, 0),
          const _V(_pileR, _pileH / 2, _pileR),
        );
      case _Obj.barrow:
        return _box(const _V(0, 1.5, 0), const _V(_trayTopX, 1, _trayTopZ));
      case _Obj.screen:
        final q = _rampQuad();
        var rect = Rect.fromPoints(q[0], q[1]);
        for (final o in q) {
          rect = rect.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0));
        }
        return rect;
    }
  }

  /// Is [at] on the sieve / screen that the learner presses to shake it?
  bool _holdArea(_Obj obj, Offset at) => obj == _Obj.screen
      ? _inConvex(_rampQuad(), at)
      : _hitRect(obj).contains(at);

  /// The object under [at]: the step's object first, then the others.
  _Obj? _objAt(Offset at) {
    final s = _scene;
    final target = s.target;
    if (target != null && _hitRect(target).contains(at)) return target;
    for (final obj in s.objects) {
      if (obj == _Obj.screen
          ? _inConvex(_rampQuad(), at)
          : _hitRect(obj).contains(at)) {
        return obj;
      }
    }
    return null;
  }

  /// HTML `pointerdown`: only the step's object can be picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null) return false;
    final target = s.target;
    return target != null && _hitRect(target).contains(event.localPosition);
  }

  /// HTML `startDrag`: the drag plane faces the camera through the object;
  /// the finger keeps its offset from the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final target = s.target;
    if (target == null || !_hitRect(target).contains(d.localPosition)) return;
    final pos = s.posOf(target);
    _grabAt = pos;
    _grabShift = d.localPosition - _cam.p(pos);
    _moved = false;
    setState(() => s.held = target);
  }

  void _onDragStart(DragStartDetails d) {
    if (_scene.held == null) return;
    _moved = true;
    _Sound.pickup.play();
  }

  /// Lowest the anchor of a dragged object may go: the cup standing on the
  /// table, the sieve lying on it, the shovel standing on the ground.
  double _restY(_Obj obj) => switch (obj) {
    _Obj.cup => _cupH / 2,
    _Obj.sieve => 0.05,
    _ => _shovelHome.y,
  };

  /// HTML `pointermove`: the object follows the finger on its drag plane;
  /// it slides along the table or the ground instead of sinking into it
  /// (the HTML lifted it to y 5.5 away from the finger).
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    final cam = _cam;
    final at = d.localPosition - _grabShift;
    var p = cam.onPlane(at, cam.f, _grabAt);
    if (p == null) return;
    final rest = _restY(obj);
    if (p.y < rest) p = cam.onPlaneY(at, rest) ?? p.atY(rest);
    if (s.scenario == 0) {
      p = _V(
        p.x.clamp(-_tableHalfX, _tableHalfX),
        p.y,
        p.z.clamp(-_tableHalfZ, _tableHalfZ),
      );
    } else {
      final r = math.sqrt(p.x * p.x + p.z * p.z);
      final edge = _groundR - 1;
      if (r > edge) p = _V(p.x * edge / r, p.y, p.z * edge / r);
    }
    s.pos[obj] = _Move.still(p);
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup`: a dragged object is checked against the step's
  /// target; a mere press leaves it where it was.
  void _release() {
    final s = _scene;
    final obj = s.held;
    if (obj == null) return;
    setState(() => s.held = null);
    if (!_moved) return;
    _moved = false;
    _checkDrop(obj);
  }

  /// Is [screen] within [range] world units of the segment [a]–[b] as the
  /// learner sees it?
  bool _nearSegment(Offset screen, _V a, _V b, double range) {
    final cam = _cam;
    return _segDist(screen, cam.p(a), cam.p(b)) <=
        range * cam.scaleAt((a + b) * 0.5);
  }

  bool _near(Offset screen, _V target, double range) =>
      (screen - _cam.p(target)).distance <= range * _cam.scaleAt(target);

  /// HTML `checkDrop()`, with each target tested where the learner sees it.
  void _checkDrop(_Obj obj) {
    final s = _scene;
    final cam = _cam;
    final p = s.posOf(obj);
    switch (obj) {
      case _Obj.cup:
        if (_nearSegment(cam.p(p), _sieveAxisLow, _sieveAxisHigh, _cupRange)) {
          _pour();
        } else {
          _revert(obj, 'e_cup');
        }
      case _Obj.sieve:
        final centre = cam.p(p + const _V(0, _sieveRimH / 2, 0));
        if (_nearSegment(centre, _binAxisLow, _binAxisHigh, _binRange)) {
          _dumpBran();
        } else {
          _revert(obj, 'e_sieve');
        }
      case _Obj.shovel when s.step == 1:
        if (_near(cam.p(_bladeCentre(p, 0)), _pileTarget, _pileRange)) {
          _scoop();
        } else {
          _revert(obj, 'e_pile');
        }
      case _Obj.shovel:
        final top = _rampPoint(_rampAngle, 0, _rampLen, 0, 0.5);
        final mid = _rampPoint(_rampAngle, 0, _rampLen * _upperFrom, 0, 0.5);
        if (_nearSegment(cam.p(_bladeCentre(p, 0)), mid, top, _screenRange)) {
          _loadScreen();
        } else {
          _revert(obj, 'e_screen');
        }
      default:
        break;
    }
  }

  /// Taps on the scene repeat the current task (the HTML ignored them): as
  /// a hint on the step's object, as an error on another object. Presses
  /// on the sieve / screen to shake are handled by [_onPointerDown].
  void _onTap(TapUpDetails d) {
    if (_swallowTap) {
      _swallowTap = false;
      return;
    }
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null || s.done) return;
    final hold = s.holdTarget;
    if (hold != null && _holdArea(hold, d.localPosition)) return;
    final obj = _objAt(d.localPosition);
    if (obj == null) return;
    final interactive = s.target != null || hold != null;
    if (!interactive || obj == s.target) {
      _toast(_hudKey);
    } else {
      _toast(_hudKey, error: true, sound: true);
    }
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-shake` (the shaking steps), `#btn-dump` (Scenario 2 step 4)
  /// and `#btn-action-main` 'Finish Observation' (the last step; afterwards
  /// it re-opens the summary).
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.shakeStep)
        LabAction(
          label: _t('btn_shake'),
          icon: Icons.filter_alt,
          color: _Colors.sky600,
          foreground: _Colors.white,
          highlight: true,
          // Plays the HTML 'shake' tone itself.
          silent: true,
          onTap: _shakeTap,
        ),
      if (s.dumpStep)
        LabAction(
          label: _t('btn_dump'),
          icon: Icons.delete_outline,
          color: _Colors.amber600,
          foreground: _Colors.white,
          highlight: !s.busy,
          enabled: !s.busy,
          // Plays the HTML 'pour' tone itself.
          silent: true,
          onTap: _dumpPebbles,
        ),
      if (s.finishStep)
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.arrow_forward,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: !s.done,
          // The summary plays the HTML 'ding'.
          silent: true,
          onTap: _finish,
        ),
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
          icon: Icons.filter_alt,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the scenario
          // is done.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          stage: _stage(),
        );
      },
    );
  }

  /// While the sidebar is collapsed: moves (and on small screens shrinks)
  /// the scene so everything the learner needs lies between the floating
  /// mission card and the tool column.
  _Fit _collapsedFit(BuildContext context) {
    if (_lab.isSidebarOpen) return _noFit;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return _noFit;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = _missionCardWidth(size, context.labScale);
    // The shell puts the mission card 76 px from the left edge.
    final freeLeft = (76 + pad.left + card - stageLeft) / fit + _cardGap;
    final tools = labOverlayInsets(context, _lab).right;
    final freeRight =
        math.min((size.width - tools - stageLeft) / fit, _design.width) -
        _cardGap;
    final (left, right) = _scene.scenario == 0 ? _kitchenExtent : _siteExtent;
    final k = ((freeRight - freeLeft) / (right - left)).clamp(_minFit, 1.0);
    return (
      k: k,
      dx: (freeLeft + freeRight) / 2 - k * (left + right) / 2,
      dy: (1 - k) * _design.height / 2,
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final view = _collapsedFit(context);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          final px = fit * view.k;
          _touch = _touchDp / px;
          _labelSize =
              _labelPx * (_labelFullScale / px).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          final toolsLeft = math.min(
            (box.maxWidth - tools - stageLeft) / fit,
            _design.width,
          );
          _labelRight = (toolsLeft - view.dx) / view.k;
        }
        return LabStage(
          designSize: _design,
          // The move transforms the whole scene layer (painting and hit
          // tests), so gestures arrive in the scene's own coordinates.
          child: AnimatedContainer(
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            transform: Matrix4(
              view.k,
              0,
              0,
              0, //
              0,
              view.k,
              0,
              0, //
              0,
              0,
              1,
              0, //
              view.dx,
              view.dy,
              0,
              1,
            ),
            child: KeyedSubtree(
              key: _sceneKey,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags and taps on the scene are not screen-reader
                  // actions; the scene is announced by its label instead.
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
                            ..onStart = _onDragStart
                            ..onUpdate = _onDragUpdate
                            ..onEnd = _onDragEnd
                            ..onCancel = _release,
                        ),
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TapGestureRecognizer
                        >(
                          () => TapGestureRecognizer(debugOwner: this),
                          (r) => r.onTapUp = _onTap,
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
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
    return _ObservationList(
      palette: p,
      scale: f,
      empty: _t('obs_empty'),
      entries: [
        for (var i = 1; i <= done; i++)
          (labFormat(_t('obs_step'), {'n': i}), steps[i - 1].observation),
      ],
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

  /// Round-ended thick lines (handles, rails, posts, ribs).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// Even-odd path for rings (the glowing drop zones).
  final Path ringPath = Path();
}

/// Label chip styles: glass chip in the dark / light theme.
enum _Chip { dark, light }

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background with the table or the ground) and the label text painters.
/// Owned by the page state and disposed with it.
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

  TextPainter label(String text, _Chip chip) =>
      _labels['${chip.index}|$text'] ??= TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: chip == _Chip.dark ? _Colors.white : _Colors.slate800,
            fontSize: _labelSize,
            fontWeight: FontWeight.w700,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// The static part of [scenario]'s scene, recorded once.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, size, pens);
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

/// The scene background (bleeding past the letterbox) with the kitchen
/// table (`BoxGeometry(36, 1.5, 20)`) or the site's ground (`Cylinder
/// Geometry(25, 25, 1)`: its far half, then down past the stage).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  final bleed = labBleed(size);
  canvas.drawRect(
    bleed,
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  if (scenario == 0) {
    _Gfx(canvas, _camKitchen, pens).box(
      const _V(0, -_tableThick / 2, 0),
      const _V(2 * _tableHalfX, _tableThick, 2 * _tableHalfZ),
      _Colors.table,
    );
    return;
  }
  final path = pens.path..reset();
  for (var i = 0; i <= _ringSides; i++) {
    final a = math.pi + i * math.pi / _ringSides;
    final o = _camSite.p(_V(_groundR * math.cos(a), 0, _groundR * math.sin(a)));
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }
  path
    ..lineTo(bleed.right, bleed.bottom)
    ..lineTo(bleed.left, bleed.bottom)
    ..close();
  canvas.drawPath(path, pens.fill..color = _lit(_Colors.table, _V.up));
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
Color _lit(
  Color c,
  _V n, {
  double opacity = 1,
  double ambient = _ambient,
  double diffuse = _diffuse,
}) {
  final i = ambient + diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// [c] pulsing towards the HTML highlight colour by [amount] (0 … 0.5).
Color _pulsed(Color c, double amount) => amount <= 0
    ? c
    : Color.lerp(c, _Colors.highlight.withValues(alpha: c.a), amount)!;

/// Radius of the bin's tapered body [y] above its base.
double _binRadiusAt(double y) => _binR0 + (_binR1 - _binR0) * y / _binH;

/// The outward normal of the wheelbarrow's front wall (it leans outwards).
const _V _frontWallNormal = _V(0, -0.301, 0.954);

/// Convex hull of [pts] (monotone chain), for glass silhouettes.
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

/// Segments of rims and rings (smooth enough at this size).
const int _ringSides = 28;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  _V get _eyeAt => cam.eye;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color, {Color? edge, double edgeWidth = 1}) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = edgeWidth
          ..color = edge,
      );
    }
  }

  /// Closed outline through the projected [pts], [width] design px wide.
  void outline(List<_V> pts, Color color, double width) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  /// A straight line between two points.
  void line(_V a, _V b, Paint paint) =>
      canvas.drawLine(cam.p(a), cam.p(b), paint);

  /// BoxGeometry centred at [c]: the faces seen by the camera, lit, with
  /// darker rims.
  void box(_V c, _V size, Color color) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = c + _V(n.x * hx, n.y * hy, n.z * hz);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _V(k.x * hx, k.y * hy, k.z * hz)));
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = _lit(color, n));
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: 0.35),
      );
    }
  }

  /// Cross-section direction at [a] radians in the frame ([ex], [ez]).
  static _V _dir(_V ex, _V ez, double a) => ex * math.cos(a) + ez * math.sin(a);

  /// CylinderGeometry: radius [r0] at [base], [r1] at the far end, [h]
  /// long along [axis]; [ex] / [ez] span its cross-section. The facets
  /// turned to the camera are lit one by one; [cap] closes the far end when
  /// it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    bool cap = true,
    int sides = 24,
    double ambient = _ambient,
    double diffuse = _diffuse,
  }) {
    if (h <= 0) return;
    final top = base + axis * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(ex, ez, (a0 + a1) / 2);
      final n = (m + axis * slope).unit;
      final mid = base + axis * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final d0 = _dir(ex, ez, a0), d1 = _dir(ex, ez, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = _lit(color, n, ambient: ambient, diffuse: diffuse);
      canvas.drawPath(path, pens.fill..color = c);
      canvas.drawPath(path, pens.seam..color = c);
    }
    if (cap && axis.dot(_eyeAt - top) > 0) {
      disc(top, r1, _lit(color, axis), ex, ez);
    }
  }

  /// Open CylinderGeometry (no ends, like the sieve's rim or the cup). With
  /// [inner] it draws the wall seen from inside, behind the contents;
  /// otherwise the outside facing the camera, in front of them.
  void tube(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    required bool inner,
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    int sides = 28,
  }) {
    final top = base + axis * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(ex, ez, (a0 + a1) / 2);
      final n = (m + axis * slope).unit;
      final mid = base + axis * (h / 2) + m * ((r0 + r1) / 2);
      final outside = n.dot(_eyeAt - mid) > 0;
      if (outside == inner) continue;
      final d0 = _dir(ex, ez, a0), d1 = _dir(ex, ez, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = inner ? labShade(_lit(color, n * -1), -0.25) : _lit(color, n);
      canvas.drawPath(path, pens.fill..color = c);
      canvas.drawPath(path, pens.seam..color = c);
    }
  }

  /// A flat disc of radius [r] centred at [c] in the plane ([ex], [ez]).
  void disc(_V c, double r, Color color, [_V ex = _V.right, _V ez = _V.front]) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// The rim of radius [r] around [c] as a line [width] world units thick
  /// (a torus or a metal edge).
  void rimLine(
    _V c,
    double r,
    Color color,
    double width, [
    _V ex = _V.right,
    _V ez = _V.front,
  ]) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = math.max(1.0, width * cam.scaleAt(c))
        ..color = color,
    );
  }

  /// RingGeometry at [c] in the plane ([ex], [ez]) (MeshBasicMaterial: not
  /// lit); flat on the ground by default.
  void ring(
    _V c,
    double rIn,
    double rOut,
    Color color, [
    _V ex = _V.right,
    _V ez = _V.front,
  ]) {
    // `reset()` also resets the fill type, so set it again each time.
    final path = pens.ringPath
      ..reset()
      ..fillType = PathFillType.evenOdd;
    for (final r in [rOut, rIn]) {
      for (var i = 0; i < _ringSides; i++) {
        final o = cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
    }
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A round limb from [a] to [b] (a thin CylinderGeometry of radius [r]).
  void limb(_V a, _V b, double r, Color color) {
    final w = math.max(1.2, 2 * r * cam.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      pens.limb
        ..strokeWidth = w
        ..color = color,
    );
  }

  /// SphereGeometry / DodecahedronGeometry: a lit disc with its shaded side
  /// away from the key light and a highlight (no gradient, so nothing is
  /// allocated).
  void sphere(_V c, double r, Color color) {
    final o = cam.p(c);
    final rr = r * cam.scaleAt(c);
    canvas.drawCircle(o, rr, pens.fill..color = labShade(color, -0.25));
    canvas.drawCircle(
      o + Offset(rr * 0.12, -rr * 0.14),
      rr * 0.84,
      pens.fill..color = color,
    );
    canvas.drawCircle(
      o + Offset(rr * 0.3, -rr * 0.34),
      rr * 0.24,
      pens.fill..color = labShade(color, 0.4),
    );
  }

  /// A small flat round bit (flour, a sand grain).
  void dot(_V c, double r, Color color) => canvas.drawCircle(
    cam.p(c),
    math.max(0.8, r * cam.scaleAt(c)),
    pens.fill..color = color,
  );

  /// A bran flake: a small flat oval with a lighter top.
  void flake(_V c, double r, Color color) {
    final o = cam.p(c);
    final k = r * cam.scaleAt(c);
    canvas.drawOval(
      Rect.fromCenter(center: o, width: 2.6 * k, height: 1.5 * k),
      pens.fill..color = color,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(0, -0.25 * k),
        width: 1.6 * k,
        height: 0.6 * k,
      ),
      pens.fill..color = labShade(color, 0.3).withValues(alpha: color.a),
    );
  }

  /// Soft blurred shadow of an elliptic footprint on the surface at height
  /// [y].
  void shadow(double x, double y, double z, double rx, double rz) {
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

  /// Points of the rim of radius [r] around [c] in the plane ([ex], [ez]).
  List<Offset> rim(_V c, double r, [_V ex = _V.right, _V ez = _V.front]) => [
    for (var i = 0; i < _ringSides; i++)
      cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r),
  ];

  /// Clear glass (`glassMat`), back part: the faint body and the far halves
  /// of its rims. Draw the contents next and [glassFront] last.
  void glassBack(_V base, double r0, double r1, double h) {
    final top = base + _V.up * h;
    final hull = _hull([...rim(base, r0), ...rim(top, r1)]);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(
      path,
      pens.fill..color = _Colors.glass.withValues(alpha: 0.08),
    );
    halfRim(base, r0, near: false, alpha: 0.25);
    halfRim(top, r1, near: false, alpha: 0.35);
  }

  /// Clear glass, front part: the near rims, the silhouette edges and a
  /// highlight stripe.
  void glassFront(_V base, double r0, double r1, double h) {
    final top = base + _V.up * h;
    halfRim(base, r0, near: true, alpha: 0.45);
    halfRim(top, r1, near: true, alpha: 0.6);
    final v = _eyeAt - (base + _V.up * (h / 2));
    final a = math.atan2(-v.x, v.z);
    final edge = pens.stroke
      ..strokeWidth = 1.2
      ..color = _Colors.glass.withValues(alpha: 0.5);
    for (final s in [a, a + math.pi]) {
      final d = _dir(_V.right, _V.front, s);
      canvas.drawLine(cam.p(base + d * r0), cam.p(top + d * r1), edge);
    }
    final hl = _dir(_V.right, _V.front, a + math.pi * 0.72);
    canvas.drawLine(
      cam.p(base + _V.up * (h * 0.15) + hl * (r0 * 0.85)),
      cam.p(base + _V.up * (h * 0.85) + hl * (r1 * 0.85)),
      pens.limb
        ..strokeWidth = math.max(1.5, 0.12 * cam.scaleAt(base))
        ..color = _Colors.glass.withValues(alpha: 0.3),
    );
  }

  /// The near or far half of a horizontal rim (seen from the camera).
  void halfRim(_V c, double r, {required bool near, required double alpha}) {
    final v = _eyeAt - c;
    final path = pens.path..reset();
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final d = _dir(_V.right, _V.front, i * 2 * math.pi / _ringSides);
      final isNear = d.dot(v) > 0;
      final o = cam.p(c + d * r);
      if (isNear == near) {
        if (open) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          open = true;
        }
      } else {
        open = false;
      }
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 1.4
        ..color = _Colors.glass.withValues(alpha: alpha),
    );
  }
}

/// Draws the scene from [scene] every frame ([repaint] ticks with the lab's
/// ticker): the kitchen (Scenario 1) or the construction site (Scenario 2),
/// then the labels and the sifting progress.
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

  /// Scene x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintKitchen(canvas);
    } else {
      _paintSite(canvas);
    }
  }

  /// HTML `update3DHighlight`: how far [obj] pulses towards light blue now.
  double _pulse(_Obj obj) {
    final s = scene;
    if (s.glowing != obj) return 0;
    return (math.sin(s.time * _pulseRate) + 1) / 2 * _pulseMax;
  }

  /// How far a mixture tipped out at [since] has dropped into place (0 … 1).
  double _landed(double since) =>
      ((scene.time - since) / _fallSeconds).clamp(0.0, 1.0);

  // ---------------------------------------------------------- scenario 1

  void _paintKitchen(Canvas canvas) {
    final g = _Gfx(canvas, _camKitchen, _pens);
    final s = scene;
    final cup = s.posOf(_Obj.cup);
    final sieve = s.posOf(_Obj.sieve) + _V(s.shakeX, 0, 0);

    // Contact shadows on the table.
    g.shadow(0.3, 0, -0.3, _bowlR0 + 0.6, _bowlR0 + 0.3);
    g.shadow(_binPos.x + 0.3, 0, -0.3, _binR0 + 0.5, _binR0 + 0.3);
    if ((cup.y - _cupHome.y).abs() < 0.3) {
      g.shadow(cup.x + 0.2, 0, cup.z - 0.2, _cupR0 + 0.3, _cupR0);
    }
    if (sieve.y < 0.5) g.shadow(sieve.x, 0, sieve.z, _sieveR, _sieveR * 0.9);

    // Bodies far to near; the held object in front of everything.
    double depth(_Obj obj) {
      if (s.held == obj) return double.negativeInfinity;
      return _camKitchen.depth(switch (obj) {
        _Obj.bowl => _bowlBase + const _V(0, _bowlH / 2, 0),
        _Obj.sieve => sieve + const _V(0, _sieveRimH / 2, 0),
        _Obj.bin => _binPos,
        _ => cup,
      });
    }

    final parts = [_Obj.bowl, _Obj.sieve, _Obj.bin, _Obj.cup]
      ..sort((a, b) => depth(b).compareTo(depth(a)));
    for (final obj in parts) {
      switch (obj) {
        case _Obj.bowl:
          _paintBowl(g, sieve);
        case _Obj.sieve:
          _paintSieve(g, sieve);
          // `sieveZoneS1`: where the cup goes (step 1).
          if (!s.done && !s.busy && s.step == 1) {
            g.ring(_sieveZone, 3, 5.5, _Colors.glow);
          }
        case _Obj.bin:
          _paintBin(g);
          // `binZoneS1`: where the sieve goes (step 3).
          if (!s.done && !s.busy && s.step == 3) {
            g.ring(_binZone, 2.2, 5, _Colors.glow);
          }
        default:
          _paintCup(g, cup);
      }
    }
    _paintBranFall(g);

    if (showLabels) {
      final cam = _camKitchen;
      _chip(canvas, cam.p(cup + const _V(0, 4, 0)), _t('lbl_cup'));
      _chip(canvas, cam.p(sieve + const _V(0, 4, 0)), _t('lbl_sieve'));
      _chip(canvas, cam.p(_binPos + const _V(0, 5.5, 0)), _t('lbl_bin'));
    }
    if (s.showProgress) {
      _progressChip(
        canvas,
        _camKitchen.p(_sieveHome + const _V(0, 4, 0)),
        labFormat(_t('cnt_sift'), {'p': s.progress.floor()}),
      );
    }
  }

  /// The glass bowl (`bowlS1`) with the flour sifted into it so far.
  void _paintBowl(_Gfx g, _V sieve) {
    final s = scene;
    g.glassBack(_bowlBase, _bowlR0, _bowlR1, _bowlH);
    final floor = _bowlBase + const _V(0, _bowlFloor, 0);
    g.disc(floor, _bowlR0, _Colors.glass.withValues(alpha: 0.14));
    final k = s.sifted;
    final top = floor.y + _moundH * k;
    if (k > 0.01) {
      final r = _moundR * (0.45 + 0.55 * k);
      g.cylinder(floor, r, r * 0.15, _moundH * k, _Colors.flour);
    }
    if (s.shaking) {
      // Flour falling through the mesh while the sieve shakes (added).
      final t = s.time;
      final from = sieve.y - 0.05;
      for (final f in _flourFalls) {
        final u = (t * _fallRate * f.speed + f.phase) % 1.0;
        final squeeze = 1 - 0.25 * u;
        g.dot(
          _V(sieve.x + f.a * squeeze, from - u * (from - top), f.b * squeeze),
          0.09,
          _Colors.flour.withValues(alpha: 0.9 - 0.3 * u),
        );
      }
    }
    g.glassFront(_bowlBase, _bowlR0, _bowlR1, _bowlH);
  }

  /// The sieve (`sieveS1`): rim, wire mesh and the mixture on it; it tips
  /// over the bin to empty the bran.
  void _paintSieve(_Gfx g, _V at) {
    final s = scene;
    final tilt = s.sieveTilt.at(s.time);
    final axis = _V(math.sin(tilt), math.cos(tilt), 0);
    final ex = _V(math.cos(tilt), -math.sin(tilt), 0);
    final pulse = _pulse(_Obj.sieve);
    final metal = _pulsed(_Colors.metal, pulse);
    g.tube(
      at,
      _sieveR,
      _sieveR,
      _sieveRimH,
      metal,
      inner: true,
      axis: axis,
      ex: ex,
    );
    final wire = _pulsed(_Colors.wire, pulse);
    g.disc(at, _meshR, wire.withValues(alpha: 0.12), ex);
    final pen = _pens.stroke
      ..strokeWidth = 0.9
      ..color = wire.withValues(alpha: 0.55);
    for (var k = -_meshLines; k <= _meshLines; k++) {
      final o = k * _meshGap;
      final half = math.sqrt(math.max(0.0, _meshR * _meshR - o * o));
      g.line(at + ex * o - _V.front * half, at + ex * o + _V.front * half, pen);
      g.line(at + _V.front * o - ex * half, at + _V.front * o + ex * half, pen);
    }
    if (s.branOn) _paintMixOnMesh(g, at, axis, ex);
    g.tube(
      at,
      _sieveR,
      _sieveR,
      _sieveRimH,
      metal,
      inner: false,
      axis: axis,
      ex: ex,
    );
    g.rimLine(at + axis * _sieveRimH, _sieveR, labShade(metal, 0.35), 0.08, ex);
  }

  /// HTML `branOnSieveS1`: bran flakes on a layer of flour. The flour goes
  /// through the mesh as it is sifted (the HTML left its white bits on the
  /// sieve); the bran stays.
  void _paintMixOnMesh(_Gfx g, _V at, _V axis, _V ex) {
    final s = scene;
    final landed = _landed(s.pourAt);
    final drop = (1 - landed) * 2.5;
    final fine = 1 - s.sifted;
    if (fine > 0.01) {
      g.disc(
        at + axis * (0.12 + drop),
        _powderR * (0.6 + 0.4 * landed),
        _Colors.flour.withValues(alpha: 0.8 * fine),
        ex,
      );
    }
    for (final b in _branGrains) {
      final p = at + ex * b.a + _V.front * b.b + axis * (b.h + drop);
      if (!b.fine) {
        g.flake(p, b.r, _Colors.bran);
      } else if (fine > 0.01) {
        g.dot(p, b.r * 0.8, _Colors.flour.withValues(alpha: fine));
      }
    }
  }

  /// The cup (`cupS1`) with its heaped mixture; it tips to pour.
  void _paintCup(_Gfx g, _V at) {
    final s = scene;
    final tilt = s.cupTilt.at(s.time);
    final axis = _V(math.sin(tilt), math.cos(tilt), 0);
    final ex = _V(math.cos(tilt), -math.sin(tilt), 0);
    final base = at - axis * (_cupH / 2);
    final metal = _pulsed(_Colors.metal, _pulse(_Obj.cup));
    g.disc(base, _cupR0, labShade(metal, -0.4), ex);
    g.tube(base, _cupR0, _cupR1, _cupH, metal, inner: true, axis: axis, ex: ex);
    if (s.cupFull) {
      final c = at + axis * _mixY;
      g.sphere(c, _mixR, _Colors.bran);
      final o = g.cam.p(c);
      final k = g.cam.scaleAt(c);
      final pen = _pens.fill..color = _Colors.flour;
      for (final f in _mixFlecks) {
        g.canvas.drawCircle(o + f * k, 0.17 * k, pen);
      }
    }
    g.tube(
      base,
      _cupR0,
      _cupR1,
      _cupH,
      metal,
      inner: false,
      axis: axis,
      ex: ex,
    );
    g.rimLine(base + axis * _cupH, _cupR1, labShade(metal, 0.35), 0.06, ex);
  }

  /// The waste bin (`binS1`): tapered body, dark inside, ribs and rim.
  void _paintBin(_Gfx g) {
    final base = _binPos - const _V(0, _binH / 2, 0);
    final top = base + const _V(0, _binH, 0);
    g.cylinder(base, _binR0, _binR1, _binH, _Colors.bin, cap: false);
    g.disc(top, _binR1 - _binTube, _Colors.binInside);
    final eye = g.cam.eye;
    for (var i = 0; i < _binRibs; i++) {
      final a = i * 2 * math.pi / _binRibs;
      final d = _V(math.cos(a), 0, math.sin(a));
      final lo =
          base + d * (_binRadiusAt(_ribLow) + 0.08) + const _V(0, _ribLow, 0);
      final hi =
          base + d * (_binRadiusAt(_ribHigh) + 0.08) + const _V(0, _ribHigh, 0);
      if (d.dot(eye - (lo + hi) * 0.5) <= 0) continue;
      g.limb(lo, hi, 0.1, _lit(_Colors.binRim, d));
    }
    g.rimLine(top, _binR1, _lit(_Colors.binRim, _V.up), 2 * _binTube);
  }

  /// The bran falling from the tipped sieve into the bin (added).
  void _paintBranFall(_Gfx g) {
    final s = scene;
    final e = s.time - s.branDumpAt;
    if (e < 0 || e >= _fallSeconds) return;
    final f = e / _fallSeconds;
    final axis = _V(math.sin(_dumpTilt), math.cos(_dumpTilt), 0);
    final ex = _V(math.cos(_dumpTilt), -math.sin(_dumpTilt), 0);
    final rim = _binPos.y + _binH / 2;
    for (final b in _branGrains) {
      if (b.fine) continue;
      final from = _sieveOverBin + ex * b.a + _V.front * b.b + axis * b.h;
      final y = from.y - 5 * f;
      if (y < rim) continue;
      final x = _binPos.x + (from.x - _binPos.x) * (1 - 0.5 * f);
      g.flake(_V(x, y, from.z * (1 - 0.5 * f)), b.r, _Colors.bran);
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintSite(Canvas canvas) {
    final g = _Gfx(canvas, _camSite, _pens);
    final s = scene;
    final angle = _rampAngle + s.screenTip.at(s.time);
    final shovel = s.posOf(_Obj.shovel);

    // `pileZoneS2`: where the shovel goes (step 1).
    if (!s.done && !s.busy && s.step == 1) {
      g.ring(_pileZone, 2, 5.5, _Colors.glow);
    }
    g.shadow(0.2, 0, -0.2, _trayTopX + 0.4, _trayTopZ + 0.2);
    if ((shovel.y - _shovelHome.y).abs() < 0.3) {
      g.shadow(shovel.x + 0.3, 0, shovel.z, 1.4, 0.6);
    }
    _paintPile(g);
    _paintPosts(g, near: false);
    _paintBarrow(g, angle);
    _paintPosts(g, near: true);
    _paintScreen(g, angle);
    _paintHeap(g);
    // `screenZoneS2`: where the load goes (step 2), on the upper slope.
    if (!s.done && !s.busy && s.step == 2) {
      g.ring(
        _rampPoint(angle, s.shakeX, _zoneU, 0, 0.15),
        _zoneIn,
        _zoneOut,
        _Colors.glow,
        _V(-math.cos(angle), math.sin(angle), 0),
      );
    }
    _paintShovel(g, shovel);

    final cam = _camSite;
    final upper =
        _rampPoint(angle, s.shakeX, _rampLen, 0) + const _V(0, 1.5, 0);
    if (showLabels) {
      // Right of the shovel standing at home, so the label (enlarged on
      // small screens) never covers its handle.
      _chip(
        canvas,
        cam.p(_pilePos + const _V(0, 4, 0)),
        _t('lbl_pile'),
        minLeft: cam.p(_shovelHome + const _V(0, 3, 0)).dx + _labelGap,
      );
      _chip(canvas, cam.p(upper), _t('lbl_screen'));
      _chip(
        canvas,
        cam.p(_barrowLabelAt),
        _t('lbl_barrow'),
        anchor: Alignment.topCenter,
      );
      _chip(
        canvas,
        cam.p(shovel + const _V(0, _handleLen + 1, 0)),
        _t('lbl_shovel'),
      );
    }
    if (s.showProgress) {
      _progressChip(
        canvas,
        cam.p(upper),
        labFormat(_t('cnt_screen'), {'p': s.progress.floor()}),
      );
    }
  }

  /// The sand and pebble pile (`sandPileS2`).
  void _paintPile(_Gfx g) {
    g.cylinder(
      _pilePos,
      _pileR,
      0.05,
      _pileH,
      _Colors.sand,
      cap: false,
      sides: 32,
      ambient: _pileAmbient,
      diffuse: _pileDiffuse,
    );
    final grain = labShade(_Colors.sand, -0.35);
    for (final p in _pileGrains) {
      g.dot(p, 0.07, grain);
    }
    for (final p in _pilePebbles) {
      g.sphere(p.at, p.r, _Colors.pebble);
    }
  }

  /// The screen's posts (added: the HTML screen floated): two under each
  /// end, behind ([near] false) or in front of the wheelbarrow.
  void _paintPosts(_Gfx g, {required bool near}) {
    final v = near ? _rampHalfW : -_rampHalfW;
    final wood = _lit(_Colors.wood, _V.front);
    for (final u in const [_postLowU, _postHighU]) {
      final top = _rampPoint(_rampAngle, 0, u, v, -_railR);
      g.limb(top.atY(0), top, _postR, wood);
    }
  }

  /// The wheelbarrow (`wheelbarrowS2`): an open tray with the sifted sand
  /// heap, a wheel, handles and legs.
  void _paintBarrow(_Gfx g, double angle) {
    final s = scene;
    const metal = _Colors.metal;
    _V top(double sx, double sz) =>
        _V(sx * _trayTopX, _trayTop, sz * _trayTopZ);
    _V low(double sx, double sz) =>
        _V(sx * _trayFloorX, _trayFloor, sz * _trayFloorZ);
    _paintBarrowFrame(g, -1);
    g
      ..poly([
        top(-1, -1),
        top(1, -1),
        low(1, -1),
        low(-1, -1),
      ], labShade(metal, -0.2))
      ..poly([
        top(-1, -1),
        top(-1, 1),
        low(-1, 1),
        low(-1, -1),
      ], labShade(metal, -0.3))
      ..poly([
        top(1, -1),
        top(1, 1),
        low(1, 1),
        low(1, -1),
      ], labShade(metal, -0.38))
      ..poly([
        low(-1, -1),
        low(1, -1),
        low(1, 1),
        low(-1, 1),
      ], labShade(metal, -0.42));
    final k = s.sifted;
    final heapTop = _trayFloor + _heapH * k;
    if (k > 0.01) {
      g.cylinder(
        const _V(0, _trayFloor, 0),
        _heapR * (0.55 + 0.45 * k),
        0.35 * k,
        _heapH * k,
        _Colors.sand,
        ez: const _V(0, 0, 0.75),
      );
    }
    if (s.shaking) {
      // Sand falling through the mesh while the screen shakes (added).
      for (final f in _sandFalls) {
        final from = _rampPoint(angle, s.shakeX, f.a, f.b, -0.1);
        final u = (s.time * _fallRate * f.speed + f.phase) % 1.0;
        g.dot(
          from.atY(from.y - u * (from.y - heapTop)),
          0.09,
          _Colors.sand.withValues(alpha: 0.95 - 0.3 * u),
        );
      }
    }
    g
      ..disc(_wheelAt, _wheelR, _Colors.tyre, _V.right, _V.up)
      ..disc(
        _wheelAt + const _V(0, 0, 0.05),
        _wheelR * 0.35,
        labShade(metal, -0.1),
        _V.right,
        _V.up,
      )
      ..poly([
        top(-1, 1),
        top(1, 1),
        low(1, 1),
        low(-1, 1),
      ], _lit(metal, _frontWallNormal))
      ..outline(
        [top(-1, -1), top(1, -1), top(1, 1), top(-1, 1)],
        labShade(metal, 0.25),
        1.6,
      );
    _paintBarrowFrame(g, 1);
  }

  /// One side's handle and leg ([side] -1 behind, 1 in front).
  void _paintBarrowFrame(_Gfx g, double side) {
    final z = side * 1.9;
    g
      ..limb(
        _V(-_trayTopX, 2.2, z),
        _V(-6.4, 1.7, z * 1.1),
        0.14,
        _lit(_Colors.wood, _V.front),
      )
      ..limb(
        _V(-_trayFloorX - 0.1, 0.7, z),
        _V(-3.5, 0, z),
        0.12,
        labShade(_Colors.metal, -0.2),
      );
  }

  /// The construction screen (`screenS2`): wooden frame, wire mesh and the
  /// mixture on it. It shakes sideways and tips about its lower end.
  void _paintScreen(_Gfx g, double angle) {
    final s = scene;
    final sx = s.shakeX;
    _V at(double u, double v) => _rampPoint(angle, sx, u, v);
    final pulse = _pulse(_Obj.screen);
    final rail = _lit(_pulsed(_Colors.wood, pulse), _V.up);
    final wire = _pulsed(_Colors.wire, pulse);
    const w = _rampHalfW;
    g
      ..limb(at(0, -w), at(_rampLen, -w), _railR, rail)
      ..poly([
        at(0, -w),
        at(_rampLen, -w),
        at(_rampLen, w),
        at(0, w),
      ], wire.withValues(alpha: 0.1));
    final pen = _pens.stroke
      ..strokeWidth = 0.9
      ..color = wire.withValues(alpha: 0.55);
    for (var v = -w + _wireGap; v < w - 0.01; v += _wireGap) {
      g.line(at(0, v), at(_rampLen, v), pen);
    }
    for (var u = _wireGap; u < _rampLen - 0.01; u += _wireGap) {
      g.line(at(u, -w), at(u, w), pen);
    }
    g
      ..limb(at(0, -w), at(0, w), _railR, rail)
      ..limb(at(_rampLen, -w), at(_rampLen, w), _railR, rail);
    if (s.mixOnScreen) _paintMixOnScreen(g, angle);
    g.limb(at(0, w), at(_rampLen, w), _railR, rail);
  }

  /// HTML `pebblesOnScreenS2`: pebbles on a layer of sand. The sand goes
  /// through the mesh as it is sifted; the pebbles stay until they are
  /// dumped, then slide off the lower end.
  void _paintMixOnScreen(_Gfx g, double angle) {
    final s = scene;
    final sx = s.shakeX;
    final landed = _landed(s.loadAt);
    final drop = (1 - landed) * 2.5;
    final sand = 1 - s.sifted;
    if (sand > 0.01) {
      g.disc(
        _rampPoint(angle, sx, _mixU, 0, 0.1 + drop),
        _sandPatchR * (0.6 + 0.4 * landed),
        _Colors.sand.withValues(alpha: 0.85 * sand),
        _V(-math.cos(angle), math.sin(angle), 0),
      );
      final grain = labShade(_Colors.sand, -0.25).withValues(alpha: sand);
      for (final d in _sandDots) {
        g.dot(_rampPoint(angle, sx, d.dx, d.dy, 0.18 + drop), 0.11, grain);
      }
    }
    for (final p in _screenPebbles) {
      final at = _pebbleAt(p, angle, sx, drop);
      if (at != null) g.sphere(at, p.r, _Colors.pebble);
    }
  }

  /// Where pebble [p] is: on the screen, sliding down it as it tips, or
  /// dropping onto the heap; null once it lies on the heap.
  _V? _pebbleAt(_Pebble p, double angle, double sx, double drop) {
    final s = scene;
    if (s.dumpAt < 0) return _rampPoint(angle, sx, p.u, p.v, p.r + drop);
    final e = s.time - s.dumpAt - p.delay;
    if (e < 0) return _rampPoint(angle, sx, p.u, p.v, p.r);
    if (e < _slideSeconds) {
      final f = e / _slideSeconds;
      return _rampPoint(angle, sx, p.u * (1 - f * f), p.v, p.r);
    }
    final f = (e - _slideSeconds) / _flySeconds;
    if (f >= 1) return null;
    final from = _rampPoint(angle, sx, 0, p.v, p.r);
    return _V.lerp(from, p.heap, f) + _V(0, 1.6 * f * (1 - f), 0);
  }

  /// HTML `stoneRubbleS2`: the pebbles that have landed on their own heap.
  void _paintHeap(_Gfx g) {
    final s = scene;
    if (!s.rubbleShown && s.dumpAt < 0) return;
    for (final p in _heapOrder) {
      final e = s.time - s.dumpAt - p.delay;
      if (s.rubbleShown || e >= _slideSeconds + _flySeconds) {
        g.sphere(p.heap, p.r, _Colors.pebble);
      }
    }
  }

  /// The shovel (`shovelS2`): handle with a grip, the blade and its load.
  void _paintShovel(_Gfx g, _V at) {
    final s = scene;
    final lean = s.shovelLean.at(s.time);
    final up = _shovelUp(lean);
    final side = _V(math.cos(lean), -math.sin(lean), 0);
    final pulse = _pulse(_Obj.shovel);
    final wood = _lit(_pulsed(_Colors.wood, pulse), _V.front);
    final metal = _pulsed(_Colors.metal, pulse);
    final top = at + up * _handleLen;
    g
      ..limb(at, top, _handleR, wood)
      ..limb(top - side * _gripHalf, top + side * _gripHalf, _handleR, wood);
    final c = _bladeCentre(at, lean) + const _V(0, 0, _bladeZ);
    const hw = _bladeW / 2, hh = _bladeH / 2;
    g.poly(
      [
        c - side * hw + up * hh,
        c + side * hw + up * hh,
        c + side * hw - up * (hh * 0.4),
        c - up * hh,
        c - side * hw - up * (hh * 0.4),
      ],
      _lit(metal, _V.front),
      edge: labShade(metal, -0.45),
    );
    if (s.shovelLoaded) {
      // HTML `shovelSandTopS2`: a shovelful of sand and pebbles.
      final load = c + up * 0.15 + const _V(0, 0, 0.55);
      g.sphere(load, 1.05, _Colors.sand);
      final o = g.cam.p(load);
      final k = g.cam.scaleAt(load);
      for (var i = 0; i < 6; i++) {
        final r = 0.2 * k;
        final q = o + _mixFlecks[i] * (0.55 * k);
        g.canvas
          ..drawCircle(q, r, _pens.fill..color = labShade(_Colors.pebble, -0.2))
          ..drawCircle(
            q + Offset(-r * 0.2, -r * 0.25),
            r * 0.6,
            _pens.fill..color = _Colors.pebble,
          );
      }
    }
  }

  // ------------------------------------------------------------ labels

  /// A label chip (HTML `.label-3d`) placed by [anchor] at [at], kept left
  /// of the tool column.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    Alignment anchor = Alignment.center,
    double? minLeft,
  }) {
    final chip = isDark ? _Chip.dark : _Chip.light;
    final tp = cache.label(text, chip);
    final size = cache.labelSize;
    final padX = size * 0.65, padY = size * 0.32;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final cx = at.dx - anchor.x * w / 2;
    final minX = w / 2 + 4;
    var x = cx.clamp(minX, math.max(minX, labelRight - w / 2 - 4)).toDouble();
    if (minLeft != null) x = math.max(x, minLeft + w / 2);
    final rect = Rect.fromCenter(
      center: Offset(x, at.dy - anchor.y * h / 2),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas
      ..drawRRect(
        rr,
        _pens.fill..color = isDark ? _Colors.labelDark : _Colors.labelLight,
      )
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1
          ..color = _Colors.sky400,
      );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  /// HTML `cnt_sift` / `cnt_filter` readout (its element never existed in
  /// the HTML, so the percentage the step asks for was never shown): the
  /// percentage and a bar, above the label at [labelAt].
  void _progressChip(Canvas canvas, Offset labelAt, String text) {
    final tp = cache.label(text, isDark ? _Chip.dark : _Chip.light);
    final size = cache.labelSize;
    final padX = size * 0.75, padY = size * 0.35;
    final bar = size * 0.32;
    final w = math.max(tp.width, size * 9) + 2 * padX;
    final h = tp.height + bar + 3 * padY;
    final minX = w / 2 + 4;
    final x = labelAt.dx
        .clamp(minX, math.max(minX, labelRight - w / 2 - 4))
        .toDouble();
    final rect = Rect.fromCenter(
      center: Offset(x, labelAt.dy - size * 1.9 - h / 2),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.6));
    canvas
      ..drawRRect(
        rr,
        _pens.fill..color = isDark ? _Colors.labelDark : _Colors.labelLight,
      )
      ..drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1.5
          ..color = _Colors.sky500,
      );
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.top + padY));
    final track = Rect.fromLTWH(
      rect.left + padX,
      rect.top + 2 * padY + tp.height,
      w - 2 * padX,
      bar,
    );
    final round = Radius.circular(bar / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, round),
      _pens.fill..color = _Colors.slate500.withValues(alpha: 0.45),
    );
    final done = scene.sifted.clamp(0.0, 1.0);
    if (done > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(track.left, track.top, track.width * done, bar),
          round,
        ),
        _pens.fill..color = _Colors.sky400,
      );
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
