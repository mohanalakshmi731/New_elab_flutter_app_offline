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

/// Class 6 Science • Chapter 9 • Activity 5
/// Sedimentation, Decantation and Filtration.
///
/// Native Flutter port of
/// `Cl6S-Ch9-A5-Sedimentation__Decantation__and_Filtration.html`.
///
/// Scenario 1 (The Perfect Cup of Tea): the tea leaves in a saucepan of tea
/// settle (sedimentation); the learner pours the upper tea into Cup 1 without
/// a strainer (decantation: a few leaves get into the cup), puts the tea
/// strainer on Cup 2, pours the rest of the tea through it (filtration) and
/// picks the cup without leaves.
///
/// Scenario 2 (From Muddy to Clear): the learner pours mud into a beaker of
/// water and stirs it, lets the soil settle, decants the cloudy upper water,
/// folds a filter paper into a cone, sets it in a funnel on a conical flask
/// and filters the cloudy water: the mud stays on the paper (residue) and
/// clear water drips into the flask (filtrate).
///
/// The Three.js table scene is redrawn by a CustomPainter through a
/// perspective projection of the same camera (fov 45°, position (0, 15, 24),
/// looking at (0, 3, 0)).
class Ch9A5SedimentationDecantationAndFiltrationPage extends StatefulWidget {
  const Ch9A5SedimentationDecantationAndFiltrationPage({super.key});

  @override
  State<Ch9A5SedimentationDecantationAndFiltrationPage> createState() =>
      _SeparationLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises four Web Audio tones: `click`
/// (buttons, picking up an object, an object sliding back, the filter paper
/// folding), `stir` (a short rising blip for the wait buttons and the stirring
/// rod), mapped to pop.mp3, `pour` (a falling triangle tone while a vessel
/// pours), mapped to drop.mp3, and `ding` (the summary), mapped to
/// success.mp3. correct.mp3 / error.mp3 are the shell's feedback tones for
/// the toasts this port adds.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// pickup → `science/pickup.mp3`, stir → `science/pop.mp3`,
/// pour → `science/drop.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `click` when an object is picked up.
  pickup('audio/class6/science/pickup.mp3'),

  /// HTML `stir`.
  stir('audio/class6/science/pop.mp3'),

  /// HTML `pour`.
  pour('audio/class6/science/drop.mp3'),

  /// Added feedback: a right action (toasts).
  correct('audio/class6/science/correct.mp3'),

  /// Added feedback: an object let go in the wrong place.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `ding`: the summary popup.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (`materials`).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = Color(0xFFF8FAFC);

  /// `tableMat` 0x334155 and `tableEdgeMat` 0x1f2937.
  static const Color table = slate700;
  static const Color tableEdge = Color(0xFF1F2937);

  /// `metalMat` 0x94a3b8 (saucepan, strainer, stand) and `darkMetalMat`
  /// 0x334155 (burner, saucepan handle), drawn a shade darker than the table
  /// so the burner stands out on it.
  static const Color metal = slate400;
  static const Color darkMetal = Color(0xFF263244);

  /// `glassMat` 0xdbeafe (opacity 0.28) and `glassRimMat` 0x38bdf8.
  static const Color glass = Color(0xFFDBEAFE);
  static const Color glassRim = Color(0xFF38BDF8);

  /// `teaLiquidMat` 0x854d0e (saucepan, pour stream) and `teaClearMat`
  /// 0xa16207 (the cups).
  static const Color tea = Color(0xFF854D0E);
  static const Color teaClear = Color(0xFFA16207);

  /// `leafMat` 0x3f1d0b.
  static const Color leaf = Color(0xFF3F1D0B);

  /// `cleanWaterMat` 0x0ea5e9, `muddyWaterMat` 0x78350f, `cloudyWaterMat`
  /// 0xca8a04 and `mudMat` 0x451a03.
  static const Color cleanWater = Color(0xFF0EA5E9);
  static const Color muddyWater = Color(0xFF78350F);
  static const Color cloudyWater = Color(0xFFCA8A04);
  static const Color mud = Color(0xFF451A03);

  /// `paperMat` 0xf8fafc.
  static const Color paper = Color(0xFFF8FAFC);

  /// `glowMat` 0x3b82f6 (opacity 0.35): the drop zones.
  static const Color zone = blue500;

  /// `update3DHighlight()` pulse colour 0x60a5fa.
  static const Color pulse = blue400;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// `createStdLabel`: glass chip (slate-900/85 or white/85), blue border,
  /// slate-200 / slate-700 text.
  static const Color labelDark = Color(0xD90F172A);
  static const Color labelLight = Color(0xD9FFFFFF);
  static const Color labelBorderDark = blue600;
  static const Color labelBorderLight = blue400;
  static const Color labelTextDark = slate200;
  static const Color labelTextLight = slate700;

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
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500, // text-blue-500 headings, blue buttons
    onAccent: _Colors.white,
    primary: _Colors.blue600, // summary button from-blue-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary bg-slate-900
    // The HTML header is blue-600 with white text; the shell draws the
    // title in the accent colour, so the header is a dark panel instead.
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // subtitle text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // tools panel dark:bg-slate-900/90
    buttonIcon: _Colors.blue400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelDark,
    labelText: _Colors.labelTextDark,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // --glass-bg white/95
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
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
    curtainMuted: _Colors.blue300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue400,
    buttonBorder: _Colors.slate700,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelLight,
    labelText: _Colors.labelTextLight,
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
/// curtain.
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
// say exactly what to do on a touch screen ("tap" instead of "click", drag
// over the target and let go, press and hold the stirring rod). The Hindi
// lines quote the Hindi button labels (the HTML quoted the English ones).
// Science edits (NCERT Curiosity, Chapter 9): the strainer does not trap
// "100 %" of anything and filtered water is "clear", not "pure"; Step 5 of
// Scenario 1 lets the learner find the cup without leaves instead of naming
// it. Keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title':
        'Methods of Separation: Sedimentation, Decantation & Filtration',
    'app_subtitle': 'Class 6 • Methods of Separation in Everyday Life',
    'scen_1_opt': 'Scenario 1: The Perfect Cup of Tea',
    'scen_2_opt': 'Scenario 2: From Muddy to Clear',
    's1_desc':
        'To separate tea leaves from prepared tea using two different methods, decantation and filtration, and compare their effectiveness.',
    's2_desc':
        'To separate mud from water using sedimentation, decantation, and a formal laboratory filtration setup.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Sedimentation',
    's1_a1':
        "TAP the 'Wait for Tea Leaves to Settle' button and watch the tea leaves in the saucepan.",
    's1_o1':
        'Swirling tea leaves slowly sink to the bottom of the saucepan by gravity (Sedimentation).',
    's1_c2': 'Decantation',
    's1_a2':
        'DRAG the saucepan over Cup 1 and let go: it TILTS and POURS the upper tea into the cup, without a strainer.',
    's1_o2':
        'Upper tea liquid pours into Cup 1, but some settled leaves also escape into the cup (Decantation is incomplete).',
    's1_c3': 'Place Strainer',
    's1_a3':
        'DRAG the tea strainer over Cup 2 and let go to place it on the cup.',
    's1_o3': 'The tea strainer sits snugly on the rim of the second teacup.',
    's1_c4': 'Filtration',
    's1_a4':
        'DRAG the saucepan over the strainer on Cup 2 and let go to POUR the remaining tea through the strainer.',
    's1_o4':
        'The strainer mesh holds back all the solid tea leaves, while tea without any leaves flows into Cup 2 (Filtration).',
    's1_c5': 'Compare Effectiveness',
    's1_a5':
        'Compare both cups, then TAP the cup that has no tea leaves in it.',
    's1_o5':
        'Decantation lets some sediment into the cup, while filtration gives clear tea with no leaves at all!',
    // Scenario 2 steps.
    's2_c1': 'Mix Mud & Water',
    's2_a1':
        'DRAG the small mud beaker over the water beaker and let go to POUR the mud in. Then PRESS AND HOLD the glass rod in the beaker to STIR the mixture.',
    's2_o1':
        'Mud mixes with water, forming a turbid, heterogeneous brown mixture.',
    's2_c2': 'Sedimentation',
    's2_a2':
        "TAP 'Wait 5 Minutes (Sedimentation)' and watch the heavier soil settle.",
    's2_o2':
        'Heavier mud particles settle at the bottom over time. Upper water becomes lighter but remains cloudy.',
    's2_c3': 'Decantation',
    's2_a3':
        'DRAG the beaker with the settled mud over the empty beaker and let go to DECANT (pour off) the upper cloudy water.',
    's2_o3':
        'Upper cloudy water is poured off, leaving thick bottom mud in the first beaker.',
    's2_c4': 'Fold Filter Paper',
    's2_a4':
        'DRAG the circular filter paper onto the glowing folding area and let go to FOLD it into a cone.',
    's2_o4':
        'The filter paper folds in half, then into a quarter, and opens into a cone.',
    's2_c5': 'Assemble Apparatus',
    's2_a5':
        'DRAG the filter paper cone over the glass funnel and let go to put it inside. Then DRAG the funnel over the conical flask and let go to set it in the flask.',
    's2_o5': 'The laboratory filtration apparatus is assembled securely.',
    's2_c6': 'Laboratory Filtration',
    's2_a6':
        'DRAG the beaker of cloudy decanted water over the filter funnel and let go to POUR it through the filter paper.',
    's2_o6':
        'Mud particles are trapped on the filter paper (Residue), while clear water drips into the flask (Filtrate)!',
    's2_c7': 'Residue & Filtrate',
    's2_a7':
        "Compare the clear filtrate in the flask with the mud residue on the filter paper, then TAP 'Finish Observation'.",
    's2_o7':
        'Laboratory filtration separates even the fine suspended mud particles that did not settle.',
    // HTML `hud` lines ("click" → "tap").
    's1_hud_1':
        "Step 1: TAP the 'Wait for Tea Leaves to Settle' button and observe the tea leaves settling.",
    's1_hud_2':
        'Step 2: DRAG the saucepan over Cup 1 and let go to TILT it and pour the tea without a strainer.',
    's1_hud_3': 'Step 3: DRAG the tea strainer and DROP it on top of Cup 2.',
    's1_hud_4':
        'Step 4: DRAG the saucepan over the strainer and let go to POUR the remaining tea into Cup 2.',
    's1_hud_5':
        'Step 5: Compare both cups! TAP the cup with no tea leaves in it.',
    's2_hud_1':
        'Step 1: DRAG the small mud beaker into the water beaker, then PRESS AND HOLD the glass rod to stir the mixture.',
    's2_hud_2':
        "Step 2: TAP 'Wait 5 Minutes (Sedimentation)' and watch the heavier soil settle.",
    's2_hud_3':
        'Step 3: DRAG the settled water beaker over the empty beaker to decant the upper cloudy liquid.',
    's2_hud_4':
        'Step 4: DRAG the filter paper to the folding area to fold it into a laboratory cone.',
    's2_hud_5':
        'Step 5: DRAG the filter paper cone into the funnel, then DRAG the funnel into the conical flask.',
    's2_hud_6':
        'Step 6: DRAG the beaker of cloudy decanted water and pour it through the filter funnel.',
    's2_hud_7':
        "Step 7: Observe the clear Filtrate and the mud Residue! TAP 'Finish Observation'.",
    // HTML buttons.
    'btn_wait_s1': 'Wait for Tea Leaves to Settle',
    'btn_wait_s2': 'Wait 5 Minutes (Sedimentation)',
    'btn_finish': 'Finish Observation',
    // HTML canvas labels.
    'lbl_pan': 'Saucepan (Tea & Leaves)',
    'lbl_cup1': 'Cup 1 (Decantation)',
    'lbl_cup2': 'Cup 2 (Filtration)',
    'lbl_strainer': 'Tea Strainer',
    'lbl_water_beaker': 'Large Beaker (Water)',
    'lbl_mud_beaker': 'Mud Beaker',
    'lbl_rod': 'Stirring Rod',
    'lbl_decant_beaker': 'Empty Beaker',
    'lbl_paper': 'Filter Paper',
    'lbl_funnel': 'Glass Funnel',
    'lbl_flask': 'Conical Flask',
    // Added labels: the emptied saucepan, the filled beaker, the folding
    // area and the two products of filtration.
    'lbl_pan_empty': 'Saucepan (Empty)',
    'lbl_decanted': 'Beaker (Decanted Water)',
    'lbl_fold': 'Folding Area',
    'lbl_residue': 'Residue',
    'lbl_filtrate': 'Filtrate',
    // HTML summary popup.
    'success': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1_title': 'Tea Separation Complete!',
    'sum_s1':
        'You observed that Decantation is quick but lets some sediment into the cup, whereas Filtration uses a porous filter (the strainer) to trap all the solid leaves, giving clear tea!',
    'sum_s2_title': 'Muddy Water Made Clear!',
    'sum_s2':
        'Through Sedimentation, Decantation & Filtration, you separated the heavy mud sediment and filtered out the fine suspended particles to obtain a clear Filtrate!',
    // Added: feedback where the HTML silently sent the object back.
    'e_pan_cup1': 'Let go of the saucepan over Cup 1 to pour the tea.',
    'e_strainer':
        'Let go of the tea strainer over Cup 2 to place it on the cup.',
    'e_pan_strainer':
        'Let go of the saucepan over the strainer on Cup 2 to pour the tea.',
    'e_cup1':
        'Look again: Cup 1 has tea leaves at its bottom. Tap the cup with no leaves in it.',
    'e_mud':
        'Let go of the mud beaker over the large water beaker to pour the mud in.',
    't_stir': 'Now PRESS AND HOLD the glass rod to stir the mixture.',
    't_hold': 'Keep holding the glass rod to stir the mud into the water.',
    'e_decant':
        'Let go of the water beaker over the empty beaker to decant the upper water.',
    'e_fold': 'Let go of the filter paper on the glowing folding area.',
    'e_paper_funnel': 'Let go of the filter paper cone over the glass funnel.',
    'e_funnel_flask': 'Let go of the funnel over the conical flask.',
    'e_filter':
        'Let go of the beaker over the filter funnel to pour the water through it.',
    // Added: the sidebar's observation list.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Table with a saucepan of tea and tea leaves on a burner, two glass cups and a tea strainer',
    'scene_s2':
        'Lab table with a beaker of water, a small beaker of mud, an empty beaker, filter paper, a glass funnel and a conical flask on a stand',
  },
  'hi': {
    'app_title': 'पृथक्करण की विधियाँ: अवसादन, निस्तारण और निस्यंदन',
    'app_subtitle': 'कक्षा 6 • दैनिक जीवन में पृथक्करण की विधियाँ',
    'scen_1_opt': 'परिदृश्य 1: चाय की पत्ती अलग करना',
    'scen_2_opt': 'परिदृश्य 2: मटमैले पानी को साफ करना',
    's1_desc':
        'तैयार चाय से चाय की पत्तियों को दो अलग-अलग विधियों (निस्तारण और निस्यंदन) द्वारा अलग करना और उनकी प्रभावशीलता की तुलना करना।',
    's2_desc':
        'अवसादन, निस्तारण और प्रयोगशाला निस्यंदन द्वारा पानी से मिट्टी को अलग करना।',
    's1_c1': 'अवसादन',
    's1_a1':
        "'चाय की पत्ती बैठने की प्रतीक्षा करें' बटन पर टैप करें और सॉसपैन में चाय की पत्तियों को देखें।",
    's1_o1':
        'घूमती हुई चाय की पत्तियाँ गुरुत्वाकर्षण के कारण धीरे-धीरे सॉसपैन की तली में बैठ जाती हैं (अवसादन)।',
    's1_c2': 'निस्तारण',
    's1_a2':
        'सॉसपैन को कप 1 के ऊपर खींचें और छोड़ दें: वह झुककर ऊपरी चाय को बिना छलनी के कप में उड़ेल देगा।',
    's1_o2':
        'ऊपरी चाय कप 1 में चली जाती है, लेकिन तली में बैठी कुछ पत्तियाँ भी कप में चली जाती हैं (निस्तारण अधूरा है)।',
    's1_c3': 'छलनी रखना',
    's1_a3':
        'चाय की छलनी को कप 2 के ऊपर खींचें और छोड़ दें, ताकि वह कप पर रख दी जाए।',
    's1_o3': 'चाय की छलनी दूसरे कप के किनारे पर ठीक से टिक जाती है।',
    's1_c4': 'निस्यंदन',
    's1_a4':
        'सॉसपैन को कप 2 पर रखी छलनी के ऊपर खींचें और छोड़ दें, ताकि बची हुई चाय छलनी से होकर कप में जाए।',
    's1_o4':
        'छलनी की जाली चाय की सभी ठोस पत्तियों को रोक लेती है, जबकि बिना पत्तियों वाली चाय कप 2 में चली जाती है (निस्यंदन)।',
    's1_c5': 'प्रभावशीलता की तुलना',
    's1_a5':
        'दोनों कपों की तुलना करें, फिर उस कप पर टैप करें जिसमें चाय की कोई पत्ती नहीं है।',
    's1_o5':
        'निस्तारण में कुछ पत्तियाँ कप में चली जाती हैं, जबकि निस्यंदन से बिना पत्तियों वाली साफ चाय मिलती है!',
    's2_c1': 'मिट्टी और पानी मिलाना',
    's2_a1':
        'मिट्टी के छोटे बीकर को पानी के बीकर के ऊपर खींचें और छोड़ दें, ताकि मिट्टी पानी में चली जाए। फिर मिश्रण हिलाने के लिए बीकर में रखी काँच की छड़ को दबाए रखें।',
    's2_o1':
        'मिट्टी पानी के साथ मिलकर एक धुंधला, भूरा विषमांगी मिश्रण बनाती है।',
    's2_c2': 'अवसादन',
    's2_a2':
        "'5 मिनट प्रतीक्षा करें (अवसादन)' पर टैप करें और भारी मिट्टी को तली में बैठते हुए देखें।",
    's2_o2':
        'भारी मिट्टी के कण समय के साथ तली में बैठ जाते हैं। ऊपरी पानी हल्का हो जाता है, लेकिन धुंधला रहता है।',
    's2_c3': 'निस्तारण',
    's2_a3':
        'बैठी हुई मिट्टी वाले बीकर को खाली बीकर के ऊपर खींचें और छोड़ दें, ताकि ऊपरी धुंधला पानी उसमें निथर जाए (निस्तारण)।',
    's2_o3':
        'ऊपरी धुंधला पानी अलग हो जाता है, जबकि गाढ़ी मिट्टी पहले बीकर की तली में ही रह जाती है।',
    's2_c4': 'फिल्टर पेपर मोड़ना',
    's2_a4':
        'गोल फिल्टर पेपर को चमकते हुए मोड़ने वाले क्षेत्र पर खींचें और छोड़ दें, ताकि वह मुड़कर शंकु बन जाए।',
    's2_o4':
        'फिल्टर पेपर पहले आधा, फिर चौथाई मुड़ता है और खुलकर एक शंकु बन जाता है।',
    's2_c5': 'उपकरण तैयार करना',
    's2_a5':
        'फिल्टर पेपर के शंकु को काँच की कीप के ऊपर खींचें और छोड़ दें, ताकि वह कीप में रख दिया जाए। फिर कीप को शंक्वाकार फ्लास्क के ऊपर खींचें और छोड़ दें, ताकि वह फ्लास्क में लग जाए।',
    's2_o5': 'प्रयोगशाला में निस्यंदन का उपकरण अच्छी तरह तैयार हो जाता है।',
    's2_c6': 'प्रयोगशाला निस्यंदन',
    's2_a6':
        'निथारे गए धुंधले पानी वाले बीकर को फिल्टर कीप के ऊपर खींचें और छोड़ दें, ताकि पानी फिल्टर पेपर से छनकर जाए।',
    's2_o6':
        'मिट्टी के कण फिल्टर पेपर पर रुक जाते हैं (अवशेष), जबकि साफ पानी बूंद-बूंद करके फ्लास्क में गिरता है (निस्यंद)!',
    's2_c7': 'अवशेष और निस्यंद',
    's2_a7':
        "फ्लास्क में साफ निस्यंद और फिल्टर पेपर पर मिट्टी के अवशेष की तुलना करें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o7':
        'प्रयोगशाला निस्यंदन से वे बारीक निलंबित मिट्टी के कण भी अलग हो जाते हैं जो तली में नहीं बैठे थे।',
    's1_hud_1':
        "चरण 1: 'चाय की पत्ती बैठने की प्रतीक्षा करें' बटन पर टैप करें और चाय की पत्तियों को तली में बैठते हुए देखें।",
    's1_hud_2':
        'चरण 2: सॉसपैन को कप 1 के ऊपर खींचें और छोड़ दें, ताकि वह झुककर बिना छलनी के चाय उड़ेल दे।',
    's1_hud_3': 'चरण 3: चाय की छलनी को खींचकर कप 2 के ऊपर छोड़ें।',
    's1_hud_4':
        'चरण 4: सॉसपैन को छलनी के ऊपर खींचें और छोड़ दें, ताकि बची हुई चाय छनकर कप 2 में जाए।',
    's1_hud_5':
        'चरण 5: दोनों कपों की तुलना करें! उस कप पर टैप करें जिसमें चाय की कोई पत्ती नहीं है।',
    's2_hud_1':
        'चरण 1: मिट्टी के छोटे बीकर को पानी के बीकर में उड़ेलें, फिर मिश्रण हिलाने के लिए काँच की छड़ को दबाए रखें।',
    's2_hud_2':
        "चरण 2: '5 मिनट प्रतीक्षा करें (अवसादन)' पर टैप करें और भारी मिट्टी को बैठते हुए देखें।",
    's2_hud_3':
        'चरण 3: ऊपरी धुंधले पानी को निथारने के लिए पानी वाले बीकर को खाली बीकर के ऊपर खींचकर छोड़ें।',
    's2_hud_4':
        'चरण 4: फिल्टर पेपर को शंकु बनाने के लिए मोड़ने वाले क्षेत्र पर खींचकर छोड़ें।',
    's2_hud_5':
        'चरण 5: फिल्टर पेपर के शंकु को कीप में डालें, फिर कीप को शंक्वाकार फ्लास्क में रखें।',
    's2_hud_6':
        'चरण 6: धुंधले पानी वाले बीकर को खींचकर फिल्टर कीप में उड़ेलें।',
    's2_hud_7':
        "चरण 7: साफ निस्यंद और मिट्टी के अवशेष को देखें! 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_wait_s1': 'चाय की पत्ती बैठने की प्रतीक्षा करें',
    'btn_wait_s2': '5 मिनट प्रतीक्षा करें (अवसादन)',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_pan': 'सॉसपैन (चाय और पत्तियाँ)',
    'lbl_cup1': 'कप 1 (निस्तारण)',
    'lbl_cup2': 'कप 2 (निस्यंदन)',
    'lbl_strainer': 'चाय की छलनी',
    'lbl_water_beaker': 'बड़ा बीकर (पानी)',
    'lbl_mud_beaker': 'मिट्टी का बीकर',
    'lbl_rod': 'काँच की छड़',
    'lbl_decant_beaker': 'खाली बीकर',
    'lbl_paper': 'फिल्टर पेपर',
    'lbl_funnel': 'कीप (फ़नल)',
    'lbl_flask': 'शंक्वाकार फ्लास्क',
    'lbl_pan_empty': 'सॉसपैन (खाली)',
    'lbl_decanted': 'बीकर (निथारा हुआ पानी)',
    'lbl_fold': 'मोड़ने का क्षेत्र',
    'lbl_residue': 'अवशेष',
    'lbl_filtrate': 'निस्यंद',
    'success': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1_title': 'चाय पृथक्करण पूर्ण!',
    'sum_s1':
        'आपने देखा कि निस्तारण तेज है, लेकिन इसमें कुछ पत्तियाँ कप में चली जाती हैं, जबकि निस्यंदन में छिद्रों वाला फिल्टर (छलनी) सभी ठोस पत्तियों को रोककर साफ चाय देता है!',
    'sum_s2_title': 'मटमैला पानी साफ हुआ!',
    'sum_s2':
        'अवसादन, निस्तारण और निस्यंदन के माध्यम से आपने भारी मिट्टी के अवसाद और बारीक निलंबित कणों को अलग करके साफ निस्यंद प्राप्त किया!',
    'e_pan_cup1': 'चाय उड़ेलने के लिए सॉसपैन को कप 1 के ऊपर छोड़ें।',
    'e_strainer': 'चाय की छलनी को कप 2 के ऊपर छोड़ें, ताकि वह कप पर रखी जाए।',
    'e_pan_strainer':
        'चाय उड़ेलने के लिए सॉसपैन को कप 2 पर रखी छलनी के ऊपर छोड़ें।',
    'e_cup1':
        'फिर से देखें: कप 1 की तली में चाय की पत्तियाँ हैं। उस कप पर टैप करें जिसमें पत्तियाँ नहीं हैं।',
    'e_mud':
        'मिट्टी डालने के लिए मिट्टी के बीकर को पानी के बड़े बीकर के ऊपर छोड़ें।',
    't_stir': 'अब मिश्रण हिलाने के लिए काँच की छड़ को दबाए रखें।',
    't_hold': 'मिट्टी को पानी में मिलाने के लिए काँच की छड़ को दबाए रखें।',
    'e_decant':
        'ऊपरी पानी निथारने के लिए पानी वाले बीकर को खाली बीकर के ऊपर छोड़ें।',
    'e_fold': 'फिल्टर पेपर को चमकते हुए मोड़ने वाले क्षेत्र पर छोड़ें।',
    'e_paper_funnel': 'फिल्टर पेपर के शंकु को काँच की कीप के ऊपर छोड़ें।',
    'e_funnel_flask': 'कीप को शंक्वाकार फ्लास्क के ऊपर छोड़ें।',
    'e_filter': 'पानी छानने के लिए बीकर को फिल्टर कीप के ऊपर छोड़ें।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1':
        'मेज जिस पर बर्नर पर रखा चाय और पत्तियों वाला सॉसपैन, काँच के दो कप और चाय की छलनी है',
    'scene_s2':
        'प्रयोगशाला की मेज जिस पर पानी का बीकर, मिट्टी का छोटा बीकर, खाली बीकर, फिल्टर पेपर, काँच की कीप और स्टैंड पर शंक्वाकार फ्लास्क है',
  },
};

/// Scenarios and their step counts (HTML `ScenariosData`).
const List<int> _stepCounts = [5, 7];

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

/// HTML `resetCamera()`: `camera.position.set(0, 15, 24)` looking at
/// `controls.target` (0, 3, 0), in both scenarios. (The HTML moves the
/// camera back to (0, 24, 34) only in windows narrower than 640 px; the lab
/// always runs in landscape.)
const _V _eye = _V(0, 15, 24);
const _V _lookAt = _V(0, 3, 0);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make the stirring jump.
const double _maxFrameStep = 0.1;

/// Scene labels: 12 design px, enlarged up to 1.7x on small stages so the
/// HTML's 10 px label chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.7;

/// The scene slides and shrinks with the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the framed scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the framing.
const ValueKey<String> _sceneKey = ValueKey('ch9-a5-scene');

/// LAB FRAMEWORK geometry the framing keeps clear of (dp): the floating
/// mission card's top-left corner, the tool column, the HUD chip's height
/// (two text lines at UI scale 1), and the gap kept from each.
const double _missionCardLeft = 76;
const double _missionCardTop = 12;
const double _toolClearance = 72;
const double _hudHeight = 56;
const double _frameGap = 8;

/// Smallest scale the framing may use for the scene (on the smallest
/// phones with the sidebar collapsed) and its search steps.
const double _minFrameScale = 0.6;
const double _seenSlack = 0.1;
const double _frameScaleStep = 0.02;
const double _frameShiftStep = 4;
const int _frameShiftSteps = 200;

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

  /// Horizontal (xz) distance to [o] (the HTML `Math.hypot(dx, dz)`).
  double flat(_V o) => math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
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

  /// Forward, right and up directions of the camera.
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

  /// Where the ray through [s] meets the plane `n · x = d` (HTML
  /// `raycaster.ray.intersectPlane(dragPlane, …)`).
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// The lab's camera; the look-at point is drawn at the stage centre.
final _Cam _cam = _Cam(_eye, _lookAt, const Offset(500, 280));

/// HTML `DirectionalLight(0xffffff, 0.85)` at (12, 25, 15), normalised.
const _V _light = _V(0.3806, 0.7929, 0.4757);

/// HTML `AmbientLight(0xffffff, 0.75)` plus the key light; both are toned
/// down so the lit faces do not all clip to white.
const double _ambient = 0.6;
const double _diffuse = 0.55;

/// Inside surfaces (seen through a vessel's mouth) are in shade.
const double _innerShade = 0.62;

/// HTML `update3DHighlight()` on the object to drag: emissive 0x60a5fa at
/// up to 85 % (here 50 %, a colour blend is stronger than an emissive
/// glow), `(sin(Date.now() * 0.008) + 1) / 2`.
const double _pulseMax = 0.5;
const double _pulseRate = 8;

/// The table top: `BoxGeometry(36, 1.5, 20)` with its top at y = 0. Dragged
/// objects stay above it.
const double _tableHalfX = 18;
const double _tableHalfZ = 10;
const double _tableThick = 1.5;
const double _keepOnTableX = 16;
const double _keepOnTableZ = 8.5;

/// Orientation of a lathe or box: its axis [ey] and the two directions
/// [ex], [ez] across it.
@immutable
class _Frame {
  const _Frame(this.ex, this.ey, this.ez);

  /// Turned by [a] radians about z (Three.js `rotation.z`).
  factory _Frame.rollZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _Frame(_V(c, s, 0), _V(-s, c, 0), _V.front);
  }

  static const upright = _Frame(_V.right, _V.up, _V.front);

  final _V ex;
  final _V ey;
  final _V ez;

  /// The point (x, y, z) of this frame placed at [o].
  _V at(_V o, double x, double y, double z) => o + ex * x + ey * y + ez * z;

  /// Direction across the axis at angle [a] (0 = +x, π/2 = +z, the front).
  _V across(double a) => ex * math.cos(a) + ez * math.sin(a);
}

// ------------------------------------------------------- scenario 1: tea

/// `burner`: `CylinderGeometry(3.5, 3.8, 0.4)` at (-8, 0.2, 0).
const _V _burnerAt = _V(-8, 0, 0);
const List<(double, double)> _burnerProfile = [(3.8, 0), (3.5, 0.4)];
const double _burnerTop = 0.4;

/// `panS1` at (-8, 0.4, 0): open body `CylinderGeometry(3.0, 2.8, 3.5)`, a
/// base disc and a handle `CylinderGeometry(0.3, 0.3, 4.5)` along -x at
/// height 2.8. (The HTML handle started inside the pan; here it starts at
/// the wall.)
const _V _panHome = _V(-8, 0.4, 0);
const double _panTopR = 3.0;
const double _panBottomR = 2.8;
const double _panH = 3.5;
const double _panFloor = 0.2;
const List<(double, double)> _panProfile = [
  (_panBottomR, 0),
  (_panTopR, _panH),
];
const double _panHandleY = 2.8;
const double _panHandleIn = 2.97;
const double _panHandleOut = 6.75;
const double _panHandleR = 0.3;

/// The pan's metal front wall is drawn see-through (this alpha) while it
/// stands upright, so the leaves can be seen settling; the HTML's opaque
/// steel hid them.
const double _panSeeThrough = 0.42;

/// `panTeaWaterS1`: `CylinderGeometry(2.8, 2.7, 2.6)` from the floor up to
/// 2.7. The HTML scaled it about its middle, so the tea floated up from the
/// floor as it was poured out; here its surface goes down (half after the
/// decantation, `scale.y` 0.5, almost empty after the filtration, 0.05).
const double _teaTop = 2.7;
const double _teaHalf = 0.5;
const double _teaLast = 0.05;

/// 30 tea leaves (`BoxGeometry(0.25, 0.08, 0.18)`) swirl in the tea
/// (x, z within ±1.9, y 0.5 … 2.3) and settle to the floor (x, z within
/// ±1.25) in 1.2 s + 30 ms per leaf (Quadratic.Out). 8 of them escape into
/// Cup 1 during the decantation.
const int _leafCount = 30;
const int _escapeCount = 8;
const int _strainLeafCount = 18;

/// Leaves are drawn 1.6 times the HTML's 0.25 x 0.18 so they can be seen
/// on a phone.
const double _leafHalfL = 0.2;
const double _leafHalfW = 0.14;
const double _swirlRate = 0.5;
const int _settleStepMs = 1800;

/// `cup1S1` (0, 0, 2) and `cup2S1` (7, 0, 2): glass `CylinderGeometry(2.2,
/// 1.8, 3.2)`, base, rim torus (2.2, tube 0.08); the tea
/// `CylinderGeometry(2.0, 1.75, 2.3)` fills from the floor to 2.4.
const _V _cup1At = _V(0, 0, 2);
const _V _cup2At = _V(7, 0, 2);
const List<(double, double)> _cupProfile = [(1.8, 0), (2.2, 3.2)];
const double _cupTopR = 2.2;
const double _cupH = 3.2;
const double _cupFloor = 0.15;
const double _cupRimTube = 0.08;
const double _cupTeaTop = 2.4;
const double _cupTeaR0 = 1.75;
const double _cupTeaR1 = 2.0;

/// `strainerS1`: rim torus (2.4, tube 0.15), a mesh bowl and a handle along
/// -x (`CylinderGeometry(0.2, 0.2, 4)` from -2 to -6). The HTML's mesh was
/// flipped into a dome above the rim; here it is a bowl hanging below it.
/// At home it rests on the table (HTML y 0.2, its bowl in the table); on
/// Cup 2 its rim sits on the cup's rim (HTML (7, 3.2, 2)).
const _V _strainerHome = _V(7, 1.4, -3);
const _V _strainerOn = _V(7, _cupH + 0.15, 2);
const double _strainerR = 2.4;
const double _strainerTube = 0.15;
const double _bowlR = 2.3;
const double _bowlDepth = 1.25;
const double _strainerHandleIn = 2.45;
const double _strainerHandleOut = 6;
const double _strainerHandleR = 0.2;

/// On Cup 2 the strainer turns (0.93 rad) so its handle points back left:
/// pointing left (HTML) it ran into Cup 1's rim.
const double _strainerTurn = 0.93;

/// The pan tilts `rotation.z → -π/3` about its base to pour; its pour
/// positions put its lip over the cup's centre (the HTML's (-2, 5.5, 2)
/// and (5, 6.5, 2) put the lip over the rim).
const double _panTilt = math.pi / 3;
const double _panPourY = 5.5;
final _V _panLip = _Frame.rollZ(-_panTilt).at(_V.zero, _panTopR, _panH, 0);
final _V _panPour1 = _V(_cup1At.x - _panLip.x, _panPourY, _cup1At.z);
final _V _panPour2 = _V(_cup2At.x - _panLip.x, _panPourY, _cup2At.z);

/// Drag heights (HTML `position.y` forced while dragging): the saucepan
/// 5.5; the strainer 4.0, here 4.6 because its bowl hangs below the rim.
const double _carryPan = 5.5;
const double _carryStrainer = 4.6;

/// HTML `checkDrop()` reach (xz distance to the target). The strainer's
/// 4.5 accepted it 0.5 units from home, so it must reach Cup 2's rim (3).
const double _reachCup1 = 4.5;
const double _reachStrainer = 3;
const double _reachCup2 = 5;

/// HTML drop zones (`RingGeometry`, `glowMat`): over Cup 1 (2 … 4 at
/// y 4.5), on Cup 2 for the strainer (2 … 4 at y 3.8) and for the pan
/// (2 … 4.5 at y 4.8).
const _V _zoneCup1 = _V(0, 4.5, 2);
const _V _zoneStrainer = _V(7, 3.8, 2);
const _V _zonePan2 = _V(7, 4.8, 2);

// ------------------------------------------------- scenario 2: mud water

/// `waterBeakerS2` (-6, 0, 0) and `decantBeakerS2` (2, 0, 2): glass
/// `CylinderGeometry(3.2, 3.2, 5.5)`; the water `CylinderGeometry(3, 3,
/// 4.2)` from the floor to 4.3, the decanted water up to 3.3.
const _V _waterHome = _V(-6, 0, 0);
const _V _decantHome = _V(2, 0, 2);
const double _beakerR = 3.2;
const double _beakerH = 5.5;
const List<(double, double)> _beakerProfile = [
  (_beakerR, 0),
  (_beakerR, _beakerH),
];
const double _beakerFloor = 0.15;
const double _waterR = 3;
const double _waterTop = 4.3;
const double _decantTop = 3.3;

/// After the decantation the water left in the first beaker is 0.35 of it
/// (`waterInBeakerS2.scale.y`; the HTML scaled it about its middle).
const double _decantKeep = 0.35;

/// `mudSedimentS2`: a 0.6-thick layer of mud on the floor.
const double _sedimentTop = 0.65;

/// `mudBeakerS2` (-11, 0, 3): `CylinderGeometry(2, 2, 3.5)` holding muddy
/// water (`CylinderGeometry(1.85, 1.85, 2.5)`, up to 2.6).
const _V _mudHome = _V(-11, 0, 3);
const double _mudBeakerR = 2;
const double _mudBeakerH = 3.5;
const List<(double, double)> _mudProfile = [
  (_mudBeakerR, 0),
  (_mudBeakerR, _mudBeakerH),
];
const double _mudR = 1.85;
const double _mudTop = 2.6;

/// `rodS2`: a glass rod (radius 0.15, 7.5 long) centred at (-6, 4.5, 0),
/// tilted π/8; while stirring it turns 0.25 rad per frame and the mixing
/// progresses 1.8 % per frame (60 fps).
const _V _rodCentre = _V(-6, 4.5, 0);
const double _rodHalf = 3.75;
const double _rodR = 0.15;
const double _rodTilt = math.pi / 8;
const double _stirSpin = 15;
const double _stirRate = 108;
const double _stirFull = 100;

/// Mud specks that swirl while the mixture is stirred and sink during the
/// sedimentation (added: the HTML showed only a colour change).
const int _speckCount = 26;

/// `paperS2` at (6, 0.1, -3): a flat disc of radius 2.2 that becomes a cone
/// (`ConeGeometry(2.2, 2.6)`, point down). The HTML folding zone (6, 0.2,
/// 2, ring 1.5 … 3.5) lay under the empty beaker and the flask stand; it
/// sits on the free front of the table here (ring 1 … 2.5). The folded
/// cone stands on its point.
const _V _paperHome = _V(6, 0.1, -3);
const double _paperR = 2.2;
const double _coneHalfH = 1.3;
const _V _foldAt = _V(5.6, 0.05, 6.6);
const double _foldIn = 1;
const double _foldOut = 2.5;
final _V _paperFolded = _foldAt.atY(_coneHalfH);

/// The folding: half (300 ms), quarter (300 ms), opened into a cone
/// (300 ms); the HTML swapped the disc for the cone at once.
const int _foldStageMs = 300;
const int _foldStages = 3;

/// `funnelS2`: glass cone (2.4, 2.8, point down from 3.4 to 0.6) and stem
/// (0.3, from -1.25 to 1.25). Home (12, 0.2, -3) put its stem in the
/// table and stood it behind the flask's neck, where the two were hard to
/// tell apart; here it stands on the stem's tip at the back left of the
/// table. In use it rests in the flask's mouth (the HTML hung it 7.2 up, in
/// a ring around its stem).
const _V _funnelHome = _V(-13, 1.25, -3.5);
const List<(double, double)> _funnelProfile = [
  (0.3, -1.25),
  (0.3, 0.6),
  (_funnelR, _funnelRimY),
];
const double _funnelR = 2.4;
const double _funnelRimY = 3.4;
const double _stemTip = -1.25;

/// The paper sits 2 above the funnel's origin (HTML `funnel.y + 2.0`).
const double _paperInFunnel = 2;

/// `flaskS2` at (10.5, 0.4, 2): a conical body of radius 3.5 narrowing to
/// a 1.2-wide neck up to 6.0, rim torus (1.2, tube 0.1).
const _V _flaskAt = _V(10.5, 0.4, 2);
const List<(double, double)> _flaskProfile = [
  (3.5, 0),
  (_flaskNeckR, 3.4),
  (_flaskNeckR, _flaskH),
];
const double _flaskNeckR = 1.2;
const double _flaskH = 6;
const double _flaskShoulder = 3.4;
const double _flaskBodyR = 3.5;
const double _flaskRimTube = 0.1;

/// The funnel in the flask: its cone rests on the flask's rim.
final _V _funnelIn = _V(
  _flaskAt.x,
  _flaskAt.y + _flaskH - 0.6 - _flaskNeckR * (_funnelRimY - 0.6) / _funnelR,
  _flaskAt.z,
);

/// `filtrateS2`: clear water rising in the flask to 2.55.
const double _filtrateTop = 2.55;

/// `funnelStandS2` at (10, 0, 2): base `BoxGeometry(6, 0.4, 5)`, pole
/// (radius 0.2, 10 high) at (8, 5, 2) and a ring around the funnel just
/// below its rim (HTML ring 2.5, tube 0.2, at 7.5).
const _V _standAt = _V(10, 0, 2);
const _V _poleAt = _V(8, 0.4, 2);
const double _poleTop = 10;
const double _poleR = 0.2;
const double _ringR = 2.3;
const double _ringTube = 0.15;
final _V _ringAt = _funnelIn + const _V(0, _funnelRimY - 0.5, 0);

/// Pour poses: each vessel tilts about its base and its lip is over the
/// target's centre. Mud beaker `rotation.z → -π/3` (HTML (-8.5, 5.5, 0));
/// water beaker `-π/3.5` (HTML (-0.5, 5.8, 2)); decanted beaker `-π/4`
/// (HTML `-π/3.5` at (8.5, 10.5, 2), which lifted it off the top of the
/// view).
const double _mudTilt = math.pi / 3;
const double _waterTilt = math.pi / 3.5;
const double _filterTilt = math.pi / 4;
final _V _mudPour = _pourAt(
  _mudBeakerR,
  _mudBeakerH,
  _mudTilt,
  _waterHome,
  6.3,
);
final _V _waterPour = _pourAt(_beakerR, _beakerH, _waterTilt, _decantHome, 6.3);
final _V _filterPour = _pourAt(
  _beakerR,
  _beakerH,
  _filterTilt,
  _funnelIn,
  _funnelIn.y + _funnelRimY + 0.8,
);

/// Where a vessel (radius [r], height [h]) tilted by [tilt] stands so that
/// its lip is over [over] at height [lipY].
_V _pourAt(double r, double h, double tilt, _V over, double lipY) {
  final lip = _Frame.rollZ(-tilt).at(_V.zero, r, h, 0);
  return _V(over.x - lip.x, lipY - lip.y, over.z);
}

/// Drag heights (HTML): mud beaker and water beaker 5.5, flat paper 1.0,
/// paper cone and funnel 7.5, decanted beaker 8.5 (here 8, so it stays in
/// view above the funnel).
const double _carryBeaker = 5.5;
const double _carryPaper = 1;
const double _carryKit = 7.5;
const double _carryDecant = 8;

/// HTML `checkDrop()` reach (xz distance). Mud 4.5, folding 7.5, paper to
/// funnel 6.5 and funnel to flask 6.5 accepted an object let go at (or
/// near) its home, so they must reach the target: 3.5, 2.5, 3, 4.
const double _reachMud = 3.5;
const double _reachDecant = 5;
const double _reachFold = 2.5;
const double _reachFunnel = 3;
const double _reachFlask = 4;
const double _reachFilter = 5;

/// HTML drop zones: over the water beaker (2.5 … 4.5 at y 6.5), over the
/// empty beaker (2.5 … 4.5 at y 6.5), over the flask (2 … 4 at y 8.5);
/// added: over the funnel for the paper cone.
const _V _zoneWater = _V(-6, 6.5, 0);
const _V _zoneDecant = _V(2, 6.5, 2);
const _V _zoneFlask = _V(10.5, 8.5, 2);
final _V _zoneFunnel = _funnelHome + const _V(0, 4.6, 0);

// ------------------------------------------------------------- timings

/// HTML pours (ms): move to the pour position 400, tilt 300, the stream
/// runs (S1 1200, mud 1000, decanting 1200, filtering 1400), then the
/// vessel tilts back (300) and returns home (400).
const int _moveMs = 400;
const int _tiltMs = 300;
const int _streamS1Ms = 1200;
const int _streamMudMs = 1000;
const int _streamDecantMs = 1200;
const int _streamFilterMs = 1400;
const int _returnMs = 400;

/// Fills (s): cups 1.0, mud colour 0.8, decanted beaker 1.0, filtrate 1.2,
/// residue 1.0, strainer leaves 0.8; sedimentation 1.5 (step after 1.6).
const double _cupFillS = 1;
const double _mudMixS = 0.8;
const double _decantFillS = 1;
const double _filtrateS = 1.2;
const double _residueS = 1;
const double _strainS = 0.8;
const double _sedimentS = 1.5;
const int _sedimentStepMs = 1600;

/// Objects placed (strainer on the cup, paper on the folding area) glide
/// for 400 ms; the paper into the funnel and the funnel into the flask
/// for 300 ms (the HTML set them at once); a miss slides home in 400 ms.
const int _placeMs = 400;
const int _snapMs = 300;
const int _homeMs = 400;

/// Water dripping from the funnel's stem into the flask during and just
/// after the filtering pour (added; the observation says it "drips").
const double _dripGap = 0.18;
const double _dripEvery = 0.12;
const double _dripFall = 0.45;
const double _dripTail = 0.8;

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

/// Every object the scene draws and the learner can touch.
enum _Item {
  pan,
  cup1,
  cup2,
  strainer,
  mudBeaker,
  waterBeaker,
  decantBeaker,
  paper,
  funnel,
  flask,
  rod,
}

/// A straight move between two points over [seconds] from [start] (scene
/// time): a TWEEN.js tween on `position` (the HTML uses its default linear
/// easing).
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

/// A number eased linearly from [from] to [to] (a TWEEN.js tween on a
/// scalar).
@immutable
class _Ramp {
  const _Ramp(this.from, this.to, this.start, this.seconds);

  const _Ramp.still(double value)
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

/// A colour eased from [from] to [to] (HTML tween on `material.color`).
@immutable
class _Tint {
  const _Tint(this.from, this.to, this.start, this.seconds);

  const _Tint.still(Color c) : from = c, to = c, start = 0, seconds = 0;

  final Color from;
  final Color to;
  final double start;
  final double seconds;

  Color at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return Color.lerp(from, to, (t - start) / seconds)!;
  }
}

/// One tea leaf: where it floats in the tea and where it settles (both in
/// the vessel's frame), its settling time and its turn.
@immutable
class _Leaf {
  const _Leaf(this.home, this.rest, this.seconds, this.yaw, this.pitch);

  final _V home;
  final _V rest;
  final double seconds;
  final double yaw;
  final double pitch;
}

/// One mud speck in the mixture (cylindrical coordinates in the beaker).
@immutable
class _Speck {
  const _Speck(this.r, this.y, this.a, this.size);

  final double r;
  final double y;
  final double a;
  final double size;
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
    final rnd = math.Random(95);
    double spread(double half) => (rnd.nextDouble() - 0.5) * 2 * half;
    for (var i = 0; i < _leafCount; i++) {
      leaves.add(
        _Leaf(
          _V(spread(1.9), 0.5 + rnd.nextDouble() * 1.8, spread(1.9)),
          _V(spread(1.25), _panFloor + 0.06, spread(1.25)),
          1.2 + i * 0.03,
          rnd.nextDouble() * math.pi,
          spread(0.6),
        ),
      );
    }
    for (var i = 0; i < _escapeCount; i++) {
      cupLeaves.add(
        _Leaf(
          _V.zero,
          _V(spread(1.0), _cupFloor + 0.06, spread(1.0)),
          0,
          rnd.nextDouble() * math.pi,
          spread(0.2),
        ),
      );
    }
    for (var i = 0; i < _strainLeafCount; i++) {
      final a = rnd.nextDouble() * 2 * math.pi;
      final r = math.sqrt(rnd.nextDouble()) * 1.3;
      // On the bowl's curved floor.
      final y = -_bowlDepth * math.sqrt(1 - math.pow(r / _bowlR, 2)) + 0.1;
      strainLeaves.add(
        _Leaf(
          _V.zero,
          _V(math.cos(a) * r, y, math.sin(a) * r),
          0,
          rnd.nextDouble() * math.pi,
          spread(0.3),
        ),
      );
    }
    for (var i = 0; i < _speckCount; i++) {
      specks.add(
        _Speck(
          math.sqrt(rnd.nextDouble()) * (_waterR - 0.4),
          0.5 + rnd.nextDouble() * 3.4,
          rnd.nextDouble() * 2 * math.pi,
          0.09 + rnd.nextDouble() * 0.08,
        ),
      );
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

  final List<_Leaf> leaves = [];
  final List<_Leaf> cupLeaves = [];
  final List<_Leaf> strainLeaves = [];
  final List<_Speck> specks = [];
  final List<_Confetto> confetti = [];

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// HTML `State.isAnimating`: something moves and touches are ignored.
  bool busy = false;

  /// The summary has been opened.
  bool done = false;

  /// The object the learner is dragging.
  _Item? held;

  // ---------------------------------------------------------- movers
  _Move pan = const _Move.still(_panHome);
  _Move strainer = const _Move.still(_strainerHome);
  _Move mudBeaker = const _Move.still(_mudHome);
  _Move waterBeaker = const _Move.still(_waterHome);
  _Move decantBeaker = const _Move.still(_decantHome);
  _Move paper = const _Move.still(_paperHome);
  _Move funnel = const _Move.still(_funnelHome);

  /// The pour under way: vessel, target, tilt and stream times.
  _Item? pourTool;
  _Item? pourInto;
  _Ramp tilt = const _Ramp.still(0);
  double streamOn = -10;
  double streamOff = -10;

  // ------------------------------------------------------ scenario 1
  /// The leaves started to settle (-10: not yet).
  double settleAt = -10;
  _Ramp panTea = const _Ramp.still(1);

  /// 8 leaves went into Cup 1; the rest went into the strainer.
  bool escaped = false;
  bool panEmpty = false;
  _Ramp cup1Tea = const _Ramp.still(0);
  _Ramp cup2Tea = const _Ramp.still(0);
  bool strainerOn = false;
  _Ramp strainerYaw = const _Ramp.still(0);
  _Ramp strainLeavesK = const _Ramp.still(0);

  // ------------------------------------------------------ scenario 2
  _Tint water = const _Tint.still(_Colors.cleanWater);
  _Ramp mudLevel = const _Ramp.still(1);
  bool mudPoured = false;
  bool rodShown = false;
  bool stirring = false;
  bool stirred = false;
  double stirProgress = 0;
  double stirAngle = 0;
  double sedimentAt = -10;
  _Ramp sediment = const _Ramp.still(0);
  _Ramp waterLevel = const _Ramp.still(1);
  _Ramp decantLevel = const _Ramp.still(0);
  double foldAt = -10;
  bool folded = false;
  bool paperInFunnel = false;
  bool funnelIn = false;
  _Ramp filtrate = const _Ramp.still(0);
  _Ramp residue = const _Ramp.still(0);
  double dripFrom = -10;
  double dripTo = -10;

  /// The confetti started (-10: none).
  double confettiAt = -10;

  /// HTML `getNextStepDraggable()`: what the current step lets the
  /// learner drag.
  _Item? get dragItem {
    if (done || busy) return null;
    if (scenario == 0) {
      return switch (step) {
        2 || 4 => _Item.pan,
        3 => _Item.strainer,
        _ => null,
      };
    }
    return switch (step) {
      1 => mudPoured ? null : _Item.mudBeaker,
      3 => _Item.waterBeaker,
      4 => _Item.paper,
      5 => paperInFunnel ? _Item.funnel : _Item.paper,
      6 => _Item.decantBeaker,
      _ => null,
    };
  }

  /// The 'Wait…' button is shown (HTML `btn-wait-s1` / `btn-wait-s2`).
  bool get canWait =>
      !done &&
      ((scenario == 0 && step == 1 && settleAt < 0) ||
          (scenario == 1 && step == 2 && sedimentAt < 0));

  /// The 'Finish Observation' button is shown (HTML `btn-action-main`):
  /// Scenario 2 step 7, and afterwards in both scenarios to re-open the
  /// summary.
  bool get canFinish => done || (scenario == 1 && step == 7);

  /// The stirring rod can be held.
  bool get canStir => scenario == 1 && step == 1 && rodShown && !busy;

  _V posOf(_Item item) => switch (item) {
    _Item.pan => pan.at(time),
    _Item.strainer => strainer.at(time),
    _Item.mudBeaker => mudBeaker.at(time),
    _Item.waterBeaker => waterBeaker.at(time),
    _Item.decantBeaker => decantBeaker.at(time),
    _Item.paper =>
      paperInFunnel
          ? funnel.at(time) + const _V(0, _paperInFunnel, 0)
          : paper.at(time),
    _Item.funnel => funnel.at(time),
    _Item.cup1 => _cup1At,
    _Item.cup2 => _cup2At,
    _Item.flask => _flaskAt,
    _Item.rod => _rodCentre,
  };

  /// HTML `userData.homePos` (the folded paper goes back to the folding
  /// area, as in the HTML).
  _V homeOf(_Item item) => switch (item) {
    _Item.pan => _panHome,
    _Item.strainer => _strainerHome,
    _Item.mudBeaker => _mudHome,
    _Item.waterBeaker => _waterHome,
    _Item.decantBeaker => _decantHome,
    _Item.paper => folded ? _paperFolded : _paperHome,
    _Item.funnel => _funnelHome,
    _ => posOf(item),
  };

  void setMove(_Item item, _Move move) {
    switch (item) {
      case _Item.pan:
        pan = move;
      case _Item.strainer:
        strainer = move;
      case _Item.mudBeaker:
        mudBeaker = move;
      case _Item.waterBeaker:
        waterBeaker = move;
      case _Item.decantBeaker:
        decantBeaker = move;
      case _Item.paper:
        paper = move;
      case _Item.funnel:
        funnel = move;
      default:
        break;
    }
  }

  /// The tilt of [item] now (0 unless it is pouring).
  double tiltOf(_Item item) => pourTool == item ? tilt.at(time) : 0;

  /// Where a leaf of the saucepan is (pan frame): swirling in the tea, then
  /// sinking to the floor (HTML tween, Quadratic.Out).
  _V leafAt(_Leaf leaf, int index) {
    _V swirl(double t) {
      final a = t * _swirlRate + index * 0.37;
      final c = math.cos(a), s = math.sin(a);
      final h = leaf.home;
      return _V(
        h.x * c - h.z * s,
        h.y + 0.08 * math.sin(t * 1.7 + index),
        h.x * s + h.z * c,
      );
    }

    if (settleAt < 0) return swirl(time);
    final k = ((time - settleAt) / leaf.seconds).clamp(0.0, 1.0);
    return _V.lerp(swirl(settleAt), leaf.rest, Curves.easeOutQuad.transform(k));
  }

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = null;
    pan = const _Move.still(_panHome);
    strainer = const _Move.still(_strainerHome);
    mudBeaker = const _Move.still(_mudHome);
    waterBeaker = const _Move.still(_waterHome);
    decantBeaker = const _Move.still(_decantHome);
    paper = const _Move.still(_paperHome);
    funnel = const _Move.still(_funnelHome);
    pourTool = null;
    pourInto = null;
    tilt = const _Ramp.still(0);
    streamOn = -10;
    streamOff = -10;
    settleAt = -10;
    panTea = const _Ramp.still(1);
    escaped = false;
    panEmpty = false;
    cup1Tea = const _Ramp.still(0);
    cup2Tea = const _Ramp.still(0);
    strainerOn = false;
    strainerYaw = const _Ramp.still(0);
    strainLeavesK = const _Ramp.still(0);
    water = const _Tint.still(_Colors.cleanWater);
    mudLevel = const _Ramp.still(1);
    mudPoured = false;
    rodShown = false;
    stirring = false;
    stirred = false;
    stirProgress = 0;
    stirAngle = 0;
    sedimentAt = -10;
    sediment = const _Ramp.still(0);
    waterLevel = const _Ramp.still(1);
    decantLevel = const _Ramp.still(0);
    foldAt = -10;
    folded = false;
    paperInFunnel = false;
    funnelIn = false;
    filtrate = const _Ramp.still(0);
    residue = const _Ramp.still(0);
    dripFrom = -10;
    dripTo = -10;
    confettiAt = -10;
  }
}

// --------------------------------------------------- picking and framing

/// Screen rectangle of a box seen through the camera: corners at [c] +
/// (x0 … x1, y0 … y1, z0 … z1).
Rect _boxRect(
  _V c,
  double x0,
  double x1,
  double y0,
  double y1,
  double z0,
  double z1,
) {
  var rect = Rect.zero;
  var first = true;
  for (final x in [x0, x1]) {
    for (final y in [y0, y1]) {
      for (final z in [z0, z1]) {
        final o = _cam.p(c + _V(x, y, z));
        final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
        rect = first ? r : rect.expandToInclude(r);
        first = false;
      }
    }
  }
  return rect;
}

/// Screen rectangle of a vessel (x0 … x1, 0 … h, ±hz about its base)
/// standing at [at] and tilted by [tilt] about z.
Rect _poseRect(_V at, double tilt, double x0, double x1, double h, double hz) {
  final fr = _Frame.rollZ(-tilt);
  var rect = Rect.zero;
  var first = true;
  for (final x in [x0, x1]) {
    for (final y in [0.0, h]) {
      for (final z in [-hz, hz]) {
        final o = _cam.p(fr.at(at, x, y, z));
        final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
        rect = first ? r : rect.expandToInclude(r);
        first = false;
      }
    }
  }
  return rect;
}

/// Rectangles (design px, scene unframed) the framing keeps clear of the
/// floating mission card and inside the free canvas: every object the
/// learner drags or taps, at home and where it goes.
final List<List<Rect>> _keepRects = [
  [
    _boxRect(_panHome, -_panHandleOut, _panTopR, 0, _panH, -3, 3),
    _boxRect(_burnerAt, -3.8, 3.8, 0, _burnerTop, -3.8, 3.8),
    _boxRect(_cup1At, -2.2, 2.2, 0, _cupH, -2.2, 2.2),
    _boxRect(_cup2At, -2.2, 2.2, 0, _cupH, -2.2, 2.2),
    _boxRect(_strainerOn, -4.2, 2.4, -1.25, 0.15, -5.2, 2.4),
    _boxRect(_strainerHome, -_strainerHandleOut, 2.4, -1.25, 0.15, -2.4, 2.4),
  ],
  [
    _boxRect(_mudHome, -2, 2, 0, _mudBeakerH, -2, 2),
    _boxRect(_waterHome, -3.2, 3.2, 0, _beakerH, -3.2, 3.2),
    _boxRect(_rodCentre, -1.6, 1.6, -_rodHalf, _rodHalf, -1.6, 1.6),
    _boxRect(_decantHome, -3.2, 3.2, 0, _beakerH, -3.2, 3.2),
    _boxRect(_paperHome, -_paperR, _paperR, 0, 0.1, -_paperR, _paperR),
    _boxRect(_foldAt, -_foldOut, _foldOut, 0, 2.6, -_foldOut, _foldOut),
    _boxRect(_funnelHome, -2.4, 2.4, _stemTip, _funnelRimY, -2.4, 2.4),
    _boxRect(_flaskAt, -3.5, 3.5, 0, _flaskH, -3.5, 3.5),
    _boxRect(_standAt, -3, 3, 0, _poleTop, -2.5, 2.5),
  ],
];

/// Rectangles that only have to stay on the canvas (the vessels while they
/// pour).
final List<List<Rect>> _seenRects = [
  [
    _poseRect(_panPour1, _panTilt, -_panHandleOut, _panTopR, _panH, 3),
    _poseRect(_panPour2, _panTilt, -_panHandleOut, _panTopR, _panH, 3),
  ],
  [
    _poseRect(_mudPour, _mudTilt, -2, 2, _mudBeakerH, 2),
    _poseRect(_waterPour, _waterTilt, -3.2, 3.2, _beakerH, 3.2),
    _poseRect(_filterPour, _filterTilt, -3.2, 3.2, _beakerH, 3.2),
  ],
];

/// How the scene layer is scaled and shifted on the stage (design px) so
/// what the learner works with stays clear of the shell's tool column,
/// HUD chip and floating mission card; and where scene labels may go
/// (scene coordinates).
@immutable
class _Framing {
  const _Framing(
    this.k,
    this.dx,
    this.dy, {
    this.labelLeft = 0,
    this.labelRight = 1000,
    this.labelTop = 0,
    this.labelBottom = 560,
  });

  static const identity = _Framing(1, 0, 0);

  final double k;
  final double dx;
  final double dy;
  final double labelLeft;
  final double labelRight;
  final double labelTop;
  final double labelBottom;

  Matrix4 get matrix =>
      Matrix4(k, 0, 0, 0, 0, k, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
}

/// Finds the largest scale (1 down to [_minFrameScale]) and the smallest
/// shift that keep every [keep] and [seen] rectangle inside [free] and
/// every [keep] rectangle off [card] (right of it or below it).
(double, double, double)? _solveFraming(
  List<Rect> keep,
  List<Rect> seen,
  Rect free,
  Rect? card,
) {
  final all = [...keep, ...seen];
  for (var k = 1.0; k >= _minFrameScale - 1e-9; k -= _frameScaleStep) {
    (double, double, double)? best;
    var bestCost = double.infinity;
    for (var i = 0; i <= _frameShiftSteps; i++) {
      final dx = (i.isOdd ? -1 : 1) * ((i + 1) ~/ 2) * _frameShiftStep;
      if (dx.abs() >= bestCost) break;
      var lo = -double.infinity;
      var hi = double.infinity;
      var fits = true;
      for (final r in all) {
        final l = r.left * k + dx;
        final rt = r.right * k + dx;
        if (l < free.left || rt > free.right) {
          fits = false;
          break;
        }
        lo = math.max(lo, free.top - r.top * k);
        hi = math.min(hi, free.bottom - r.bottom * k);
      }
      if (!fits) continue;
      if (card != null) {
        for (final r in keep) {
          final l = r.left * k + dx;
          final rt = r.right * k + dx;
          if (l < card.right && rt > card.left) {
            lo = math.max(lo, card.bottom - r.top * k);
          }
        }
      }
      if (lo > hi) continue;
      final dy = 0.0.clamp(lo, hi);
      final cost = dx.abs() + dy.abs();
      if (cost < bestCost) {
        bestCost = cost;
        best = (k, dx, dy);
      }
    }
    if (best != null) return best;
  }
  return null;
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

class _SeparationLabState
    extends State<Ch9A5SedimentationDecantationAndFiltrationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in scene design pixels for the current
  /// stage scale and framing.
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  /// HTML `dragPlane` (horizontal, through the object when it was picked
  /// up) and `dragOffset`.
  double _planeY = 0;
  _V _grabOffset = _V.zero;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// The pointer holding the stirring rod (null: none), and whether it was
  /// lifted in this frame (its tap is part of the hold, not a new tap).
  int? _stirPointer;
  bool _stirLifted = false;

  /// Measured height of the shell's floating mission card (dp), and a
  /// pending measurement.
  double? _cardHeight;
  bool _cardCheck = false;

  /// The last framing and what it was computed for.
  Object? _framingKey;
  _Framing _framing = _Framing.identity;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  int get _stepCount => _stepCounts[_scene.scenario];

  /// HTML `hud-instruction`: `hud[step]`.
  String get _hudKey =>
      's${_scene.scenario + 1}_hud_${math.min(_scene.step, _stepCount)}';

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

  /// HTML `animate()`: every motion is a function of the scene time; the
  /// frame advances the clock, turns the stirring rod while it is held
  /// (0.25 rad and 1.8 % per 60 fps frame) and repaints the canvas.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    _stirLifted = false;
    if (s.stirring) {
      s
        ..stirAngle += _stirSpin * dt
        ..stirProgress += _stirRate * dt;
      if (s.stirProgress >= _stirFull) _stirDone();
    }
    _frame.value = now;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _stirPointer = null;
    setState(() {
      _scene.load(index);
      _moved = false;
    });
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

  /// HTML `triggerMainAction()`: the summary popup ('Observation Complete!',
  /// 'Scenario n Complete!', the summary), with the ding.
  void _conclude() {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => _t('success'),
      heading: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      body: () => '${_t('sum_s${sc + 1}_title')}\n\n${_t('sum_s${sc + 1}')}',
    );
  }

  // ------------------------------------------------------- the actions

  /// HTML `triggerWaitS1()`: the leaves sink to the floor of the saucepan;
  /// the step moves on after 1.8 s.
  void _waitSettle() {
    final s = _scene;
    if (s.scenario != 0 || !s.canWait || s.busy) return;
    _Sound.stir.play();
    setState(() {
      s
        ..busy = true
        ..settleAt = s.time;
    });
    _lab.after(const Duration(milliseconds: _settleStepMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 2;
      });
    });
  }

  /// HTML `triggerWaitS2()`: the mud settles into a layer and the water
  /// above turns from muddy to a lighter cloudy colour (1.5 s); the step
  /// moves on after 1.6 s.
  void _waitSediment() {
    final s = _scene;
    if (s.scenario != 1 || !s.canWait || s.busy) return;
    _Sound.stir.play();
    final t = s.time;
    setState(() {
      s
        ..busy = true
        ..sedimentAt = t
        ..sediment = _Ramp(0, 1, t, _sedimentS)
        ..water = _Tint(s.water.at(t), _Colors.cloudyWater, t, _sedimentS);
    });
    _lab.after(const Duration(milliseconds: _sedimentStepMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 3;
      });
    });
  }

  /// HTML 'Finish Observation' (`triggerMainAction`): opens the summary
  /// (with confetti, as the HTML did after the last scenario); afterwards
  /// it opens it again.
  void _finish() {
    final s = _scene;
    if (!s.canFinish || s.busy) return;
    setState(() {
      s.done = true;
      if (s.scenario == 1) s.confettiAt = s.time;
    });
    _conclude();
  }

  /// HTML click on Cup 2 in step 5: ding, confetti and the summary.
  void _pickCup2() {
    final s = _scene;
    setState(() {
      s
        ..done = true
        ..confettiAt = s.time;
    });
    _conclude();
  }

  /// The stirring rod is held long enough: the mud is mixed in (HTML
  /// `processProgress >= 100`).
  void _stirDone() {
    final s = _scene;
    setState(() {
      s
        ..stirring = false
        ..stirred = true
        ..rodShown = false
        ..stirProgress = 0
        ..step = 2;
    });
  }

  /// Press on the stirring rod (HTML `startStirS2`, on the rod instead of
  /// a 'Hold to Stir Mixture' button).
  void _onPointerDown(PointerDownEvent e) {
    final s = _scene;
    if (!_lab.isLabActive || _stirPointer != null || !s.canStir) return;
    if (!_hitRect(_Item.rod).contains(e.localPosition)) return;
    _stirPointer = e.pointer;
    _Sound.stir.play();
    setState(() => s.stirring = true);
  }

  /// Release (HTML `stopStirS2`): the mixing so far is kept.
  void _onPointerEnd(PointerEvent e) {
    if (e.pointer != _stirPointer) return;
    _stirPointer = null;
    _stirLifted = true;
    if (_scene.stirring) setState(() => _scene.stirring = false);
  }

  /// HTML pour (`checkDrop()` hit): the vessel glides to its pour position
  /// (400 ms) and tilts (300 ms); the stream runs while [onStream]'s fills
  /// rise; then the vessel tilts back and returns home (400 ms) and
  /// [onDone] moves the lab on.
  void _pour({
    required _Item tool,
    required _V from,
    required _V pose,
    required double tilt,
    required int streamMs,
    required _Item into,
    required VoidCallback onStream,
    required VoidCallback onDone,
  }) {
    final s = _scene;
    final home = s.homeOf(tool);
    _Sound.pour.play();
    setState(() {
      s
        ..busy = true
        ..pourTool = tool
        ..pourInto = into
        ..streamOn = -10
        ..streamOff = -10
        ..tilt = const _Ramp.still(0)
        ..setMove(tool, _Move(from, pose, s.time, _moveMs / 1000));
    });
    _lab.after(const Duration(milliseconds: _moveMs), () {
      if (!mounted) return;
      s.tilt = _Ramp(0, tilt, s.time, _tiltMs / 1000);
    });
    _lab.after(const Duration(milliseconds: _moveMs + _tiltMs), () {
      if (!mounted) return;
      s.streamOn = s.time;
      onStream();
    });
    _lab.after(Duration(milliseconds: _moveMs + _tiltMs + streamMs), () {
      if (!mounted) return;
      s
        ..streamOff = s.time
        ..tilt = _Ramp(s.tilt.at(s.time), 0, s.time, _tiltMs / 1000)
        ..setMove(tool, _Move(pose, home, s.time, _returnMs / 1000));
    });
    _lab.after(
      Duration(milliseconds: _moveMs + _tiltMs + streamMs + _returnMs),
      () {
        if (!mounted) return;
        setState(() {
          s
            ..busy = false
            ..pourTool = null
            ..pourInto = null;
          onDone();
        });
      },
    );
  }

  /// S1 steps 2 and 4: the saucepan pours into Cup 1 (decantation) or
  /// through the strainer into Cup 2 (filtration).
  void _pourTea(_V from, {required bool filter}) {
    final s = _scene;
    _pour(
      tool: _Item.pan,
      from: from,
      pose: filter ? _panPour2 : _panPour1,
      tilt: _panTilt,
      streamMs: _streamS1Ms,
      into: filter ? _Item.cup2 : _Item.cup1,
      onStream: () {
        final t = s.time;
        if (!filter) {
          s
            ..cup1Tea = _Ramp(0, 1, t, _cupFillS)
            ..panTea = _Ramp(1, _teaHalf, t, _cupFillS)
            ..escaped = true;
          return;
        }
        s
          ..cup2Tea = _Ramp(0, 1, t, _cupFillS)
          ..strainLeavesK = _Ramp(0.1, 1, t, _strainS)
          ..panTea = _Ramp(_teaHalf, _teaLast, t, _cupFillS);
        // HTML: the pan's tea and leaves vanish when its tea tween ends.
        _lab.after(Duration(milliseconds: (_cupFillS * 1000).round()), () {
          if (mounted) s.panEmpty = true;
        });
      },
      onDone: () => s.step = filter ? 5 : 3,
    );
  }

  /// S2 step 1: the mud is poured into the water, which turns muddy.
  void _pourMud(_V from) {
    final s = _scene;
    _pour(
      tool: _Item.mudBeaker,
      from: from,
      pose: _mudPour,
      tilt: _mudTilt,
      streamMs: _streamMudMs,
      into: _Item.waterBeaker,
      onStream: () {
        final t = s.time;
        s
          ..mudPoured = true
          ..water = _Tint(_Colors.cleanWater, _Colors.muddyWater, t, _mudMixS)
          ..mudLevel = _Ramp(1, 0, t, _mudMixS);
      },
      onDone: () {
        s.rodShown = true;
        _toast('t_stir');
      },
    );
  }

  /// S2 step 3: the upper cloudy water is poured off into the empty beaker.
  void _decant(_V from) {
    final s = _scene;
    _pour(
      tool: _Item.waterBeaker,
      from: from,
      pose: _waterPour,
      tilt: _waterTilt,
      streamMs: _streamDecantMs,
      into: _Item.decantBeaker,
      onStream: () {
        final t = s.time;
        s
          ..decantLevel = _Ramp(0, 1, t, _decantFillS)
          ..waterLevel = _Ramp(1, _decantKeep, t, _decantFillS);
      },
      onDone: () => s.step = 4,
    );
  }

  /// S2 step 6: the cloudy water is poured through the filter paper; the mud
  /// stays on the paper and clear water drips into the flask.
  void _filter(_V from) {
    final s = _scene;
    _pour(
      tool: _Item.decantBeaker,
      from: from,
      pose: _filterPour,
      tilt: _filterTilt,
      streamMs: _streamFilterMs,
      into: _Item.funnel,
      onStream: () {
        final t = s.time;
        s
          ..filtrate = _Ramp(0, 1, t, _filtrateS)
          ..residue = _Ramp(0.1, 1, t, _residueS)
          ..decantLevel = _Ramp(1, _teaLast, t, _filtrateS)
          ..dripFrom = t + _dripGap
          ..dripTo = t + _streamFilterMs / 1000 + _dripTail;
      },
      onDone: () => s.step = 7,
    );
  }

  /// An object put in place: it glides there in [ms], then [then].
  void _place(_Item item, _V from, _V to, int ms, VoidCallback then) {
    final s = _scene;
    _Sound.click.play();
    setState(() {
      s
        ..busy = true
        ..setMove(item, _Move(from, to, s.time, ms / 1000));
    });
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() {
        s.busy = false;
        then();
      });
    });
  }

  /// S2 step 4: the paper glides onto the folding area (400 ms), folds in
  /// half, into a quarter and opens into a cone.
  void _fold(_V from) {
    final s = _scene;
    final flat = _foldAt.atY(_paperHome.y);
    _Sound.click.play();
    setState(() {
      s
        ..busy = true
        ..paper = _Move(from, flat, s.time, _placeMs / 1000);
    });
    _lab.after(const Duration(milliseconds: _placeMs), () {
      if (!mounted) return;
      s.foldAt = s.time;
      _Sound.click.play();
    });
    for (var i = 1; i < _foldStages; i++) {
      _lab.after(Duration(milliseconds: _placeMs + i * _foldStageMs), () {
        if (mounted) _Sound.click.play();
      });
    }
    const foldEnd = _placeMs + _foldStages * _foldStageMs;
    _lab.after(const Duration(milliseconds: foldEnd), () {
      if (!mounted) return;
      setState(() {
        s
          ..folded = true
          ..paper = _Move.still(_paperFolded);
      });
    });
    _lab.after(const Duration(milliseconds: foldEnd + _snapMs), () {
      if (!mounted) return;
      setState(() {
        s
          ..busy = false
          ..step = 5;
      });
    });
  }

  /// HTML `checkDrop()` miss: the object slides home (400 ms). The HTML
  /// only clicked; the toast [key] says where it belongs.
  void _sendHome(_Item item, _V from, String key) {
    final s = _scene;
    _toast(key, error: true, sound: true);
    setState(() {
      s
        ..busy = true
        ..setMove(item, _Move(from, s.homeOf(item), s.time, _homeMs / 1000));
    });
    _lab.after(const Duration(milliseconds: _homeMs), () => _setBusy(false));
  }

  // -------------------------------------------------------------- gestures

  /// Where an object is carried from (its body's centre).
  _V _carryPoint(_Item item, _V pos) => switch (item) {
    _Item.pan => pos + const _V(0, _panH / 2, 0),
    _Item.mudBeaker => pos + const _V(0, _mudBeakerH / 2, 0),
    _Item.waterBeaker ||
    _Item.decantBeaker => pos + const _V(0, _beakerH / 2, 0),
    _Item.funnel => pos + const _V(0, 1.5, 0),
    _Item.cup1 || _Item.cup2 => pos + const _V(0, _cupH / 2, 0),
    _Item.flask => pos + const _V(0, 2, 0),
    _ => pos,
  };

  /// The object's outline on screen, at least a 48 dp target around its
  /// centre.
  Rect _hitRect(_Item item) {
    final s = _scene;
    final p = s.posOf(item);
    final rect = switch (item) {
      _Item.pan => _boxRect(
        p,
        -_panHandleOut,
        _panTopR,
        0,
        _panH,
        -_panTopR,
        _panTopR,
      ),
      _Item.cup1 || _Item.cup2 => _boxRect(
        p,
        -_cupTopR,
        _cupTopR,
        0,
        _cupH + 0.3,
        -_cupTopR,
        _cupTopR,
      ),
      _Item.strainer => _boxRect(
        p,
        -_strainerHandleOut,
        _strainerR,
        -_bowlDepth,
        0.15,
        -_strainerR,
        _strainerR,
      ),
      _Item.mudBeaker => _boxRect(p, -2, 2, 0, _mudBeakerH, -2, 2),
      _Item.waterBeaker || _Item.decantBeaker => _boxRect(
        p,
        -_beakerR,
        _beakerR,
        0,
        _beakerH,
        -_beakerR,
        _beakerR,
      ),
      _Item.paper =>
        s.folded
            ? _boxRect(
                p,
                -_paperR,
                _paperR,
                -_coneHalfH,
                _coneHalfH,
                -_paperR,
                _paperR,
              )
            : _boxRect(p, -_paperR, _paperR, 0, 0.1, -_paperR, _paperR),
      _Item.funnel => _boxRect(
        p,
        -_funnelR,
        _funnelR,
        _stemTip,
        _funnelRimY,
        -_funnelR,
        _funnelR,
      ),
      _Item.flask => _boxRect(p, -3.5, 3.5, 0, _flaskH, -3.5, 3.5),
      _Item.rod =>
        _boxRect(
          _waterHome,
          -_beakerR,
          _beakerR,
          0,
          _beakerH,
          -_beakerR,
          _beakerR,
        ).expandToInclude(
          _boxRect(_rodCentre, -1.6, 1.6, -_rodHalf, _rodHalf, -1.6, 1.6),
        ),
    };
    return rect.expandToInclude(
      Rect.fromCircle(center: _cam.p(_carryPoint(item, p)), radius: _touch),
    );
  }

  /// The object under [at], nearest first.
  _Item? _itemAt(Offset at) {
    final s = _scene;
    final drag = s.dragItem;
    if (drag != null && _hitRect(drag).contains(at)) return drag;
    final items = s.scenario == 0
        ? const [_Item.strainer, _Item.pan, _Item.cup1, _Item.cup2]
        : const [
            _Item.funnel,
            _Item.paper,
            _Item.mudBeaker,
            _Item.decantBeaker,
            _Item.waterBeaker,
            _Item.flask,
          ];
    for (final item in items) {
      if (_hitRect(item).contains(at)) return item;
    }
    return null;
  }

  /// HTML `pointerdown`: only the step's object can be picked up.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.held != null || s.stirring) return false;
    final item = s.dragItem;
    return item != null && _hitRect(item).contains(event.localPosition);
  }

  /// HTML `startDrag`: the drag plane is horizontal through the object.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final item = s.dragItem;
    if (item == null || !_hitRect(item).contains(d.localPosition)) return;
    final pos = s.posOf(item);
    _planeY = pos.y;
    final hit = _cam.onPlane(d.localPosition, _V.up, _planeY);
    _grabOffset = hit == null ? _V.zero : (hit - pos).atY(0);
    _moved = false;
    setState(() => s.held = item);
  }

  void _onDragStart(DragStartDetails _) {
    if (_scene.held == null) return;
    _moved = true;
    _Sound.pickup.play();
  }

  /// The height the HTML lifts the held object to while it is dragged.
  double _carryY(_Item item) => switch (item) {
    _Item.pan => _carryPan,
    _Item.strainer => _carryStrainer,
    _Item.mudBeaker || _Item.waterBeaker => _carryBeaker,
    _Item.paper => _scene.step == 4 ? _carryPaper : _carryKit,
    _Item.funnel => _carryKit,
    _Item.decantBeaker => _carryDecant,
    _ => 0,
  };

  /// HTML `pointermove`: the object follows the finger across its plane,
  /// lifted to its carrying height, and stays over the table.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    final hit = _cam.onPlane(d.localPosition, _V.up, _planeY);
    if (hit == null) return;
    final p = hit - _grabOffset;
    s.setMove(
      item,
      _Move.still(
        _V(
          p.x.clamp(-_keepOnTableX, _keepOnTableX),
          _carryY(item),
          p.z.clamp(-_keepOnTableZ, _keepOnTableZ),
        ),
      ),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup`: a dragged object is checked against the step's
  /// target; a mere tap leaves it where it was.
  void _release() {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    setState(() => s.held = null);
    if (!_moved) return;
    _moved = false;
    _checkDrop(item);
  }

  /// HTML `checkDrop()`: the object must be let go within reach (xz
  /// distance) of the step's target.
  void _checkDrop(_Item item) {
    final s = _scene;
    final from = s.posOf(item);
    if (s.scenario == 0) {
      switch (s.step) {
        case 2:
          if (from.flat(_cup1At) < _reachCup1) {
            _pourTea(from, filter: false);
          } else {
            _sendHome(item, from, 'e_pan_cup1');
          }
        case 3:
          if (from.flat(_cup2At) < _reachStrainer) {
            s.strainerYaw = _Ramp(0, _strainerTurn, s.time, _placeMs / 1000);
            _place(item, from, _strainerOn, _placeMs, () {
              s
                ..strainerOn = true
                ..step = 4;
            });
          } else {
            _sendHome(item, from, 'e_strainer');
          }
        default:
          if (from.flat(_cup2At) < _reachCup2) {
            _pourTea(from, filter: true);
          } else {
            _sendHome(item, from, 'e_pan_strainer');
          }
      }
      return;
    }
    switch (s.step) {
      case 1:
        if (from.flat(_waterHome) < _reachMud) {
          _pourMud(from);
        } else {
          _sendHome(item, from, 'e_mud');
        }
      case 3:
        if (from.flat(_decantHome) < _reachDecant) {
          _decant(from);
        } else {
          _sendHome(item, from, 'e_decant');
        }
      case 4:
        if (from.flat(_foldAt) < _reachFold) {
          _fold(from);
        } else {
          _sendHome(item, from, 'e_fold');
        }
      case 5:
        if (item == _Item.paper) {
          final funnel = s.posOf(_Item.funnel);
          if (from.flat(funnel) < _reachFunnel) {
            _place(
              item,
              from,
              funnel + const _V(0, _paperInFunnel, 0),
              _snapMs,
              () => s.paperInFunnel = true,
            );
          } else {
            _sendHome(item, from, 'e_paper_funnel');
          }
        } else if (from.flat(_flaskAt) < _reachFlask) {
          _place(item, from, _funnelIn, _snapMs, () {
            s
              ..funnelIn = true
              ..step = 6;
          });
        } else {
          _sendHome(item, from, 'e_funnel_flask');
        }
      default:
        if (from.flat(_flaskAt) < _reachFilter) {
          _filter(from);
        } else {
          _sendHome(item, from, 'e_filter');
        }
    }
  }

  /// Taps: Step 5 of Scenario 1 compares the cups; a quick tap on the
  /// stirring rod asks for a longer hold; on another object the step's
  /// instruction is shown (as an error when it is the wrong object; the
  /// HTML ignored those taps).
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null) return;
    final at = d.localPosition;
    if (_stirLifted) {
      // The end of a hold on the stirring rod.
      _stirLifted = false;
      if (s.canStir) _toast('t_hold');
      return;
    }
    if (s.scenario == 0 && s.step == 5 && !s.done) {
      if (_hitRect(_Item.cup2).contains(at)) {
        _pickCup2();
        return;
      }
      if (_hitRect(_Item.cup1).contains(at)) {
        _toast('e_cup1', error: true, sound: true);
        return;
      }
    }
    if (s.done) return;
    if (s.canStir && _hitRect(_Item.rod).contains(at)) {
      _toast('t_hold');
      return;
    }
    final item = _itemAt(at);
    if (item == null) return;
    if (item == s.dragItem) {
      _toast(_hudKey);
    } else {
      _toast(_hudKey, error: true, sound: true);
    }
  }

  // -------------------------------------------------------------- framing

  /// The framing for the screen as it will be once the sidebar has settled:
  /// the scene shifts (and on small phones shrinks) so the objects stay
  /// left of the tool column, above the HUD chip and, with the sidebar
  /// collapsed, off the floating mission card at the top left.
  _Framing _framingFor(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final uiScale = context.labScale;
    final open = _lab.isSidebarOpen;
    final cardOn = !open && _lab.isLabActive;
    final cardH = cardOn
        ? (_cardHeight ?? size.height * (size.height < 480 ? 0.55 : 0.45))
        : 0.0;
    final key = (
      _scene.scenario,
      open,
      size,
      pad,
      _lab.sidebarFraction,
      cardH.round(),
      cardOn,
    );
    if (key == _framingKey) return _framing;
    _framingKey = key;

    // The shell's sidebar rule: 20 % … 50 % of the screen, at least 180 dp.
    final sideMin = math.max(180.0, size.width * 0.2);
    final sideMax = math.max(sideMin, size.width * 0.5);
    final canvasW = open
        ? size.width -
              (size.width * _lab.sidebarFraction).clamp(sideMin, sideMax)
        : size.width;
    final fit = math.min(canvasW / _design.width, size.height / _design.height);
    if (!(fit > 0 && fit.isFinite)) return _framing = _Framing.identity;
    final stageLeft = (canvasW - _design.width * fit) / 2;
    final stageTop = (size.height - _design.height * fit) / 2;
    double dx(double x) => (x - stageLeft) / fit;
    double dy(double y) => (y - stageTop) / fit;
    final gap = _frameGap / fit;
    // Touches only reach the design box, so the scene stays inside it.
    final free = Rect.fromLTRB(
      math.max(0.0, dx(open ? 0 : pad.left)) + gap,
      math.max(0.0, dy(pad.top)) + gap,
      math.min(_design.width, dx(canvasW - _toolClearance - pad.right)) - gap,
      math.min(
            _design.height,
            dy(
              size.height - pad.bottom - (open ? 8 + _hudHeight * uiScale : 0),
            ),
          ) -
          gap,
    );
    Rect? card;
    if (cardOn) {
      final left = _missionCardLeft + pad.left;
      final top = _missionCardTop + pad.top;
      card = Rect.fromLTRB(
        dx(left) - gap,
        dy(top) - gap,
        dx(left + _missionCardWidth(size, uiScale)) + gap,
        dy(top + cardH) + gap,
      );
    }
    final sc = _scene.scenario;
    final keep = _keepRects[sc];
    final seen = _seenRects[sc];
    // Best: the vessels pouring also stay clear of the card, unless that
    // would shrink the scene much more than keeping only what the learner
    // touches clear of it.
    final clearKeep = _solveFraming(keep, seen, free, card);
    final clearAll = card == null || clearKeep == null
        ? null
        : _solveFraming([...keep, ...seen], const [], free, card);
    final solved = clearAll != null && clearAll.$1 >= clearKeep!.$1 - _seenSlack
        ? clearAll
        : clearKeep ?? _solveFraming(keep, seen, free, null);
    if (solved == null) return _framing = _Framing.identity;
    final (k, ox, oy) = solved;
    return _framing = _Framing(
      k,
      ox,
      oy,
      labelLeft: (free.left - ox) / k,
      labelRight: (free.right - ox) / k,
      labelTop: (free.top - oy) / k,
      labelBottom: (free.bottom - oy) / k,
    );
  }

  /// Measures the shell's floating mission card after the frame, so the
  /// framing keeps the scene clear of the card as it really is.
  void _scheduleCardCheck() {
    if (_cardCheck) return;
    _cardCheck = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardCheck = false;
      if (!mounted || _lab.isSidebarOpen) return;
      final h = _missionCardHeight();
      if (h == null) return;
      if (_cardHeight == null || (h - _cardHeight!).abs() > 1) {
        setState(() => _cardHeight = h);
      }
    });
  }

  /// Height of the LAB FRAMEWORK's floating mission card as laid out.
  double? _missionCardHeight() {
    double? height;
    void visit(Element e) {
      if (height != null) return;
      if (e.widget is _FloatingMissionCard) {
        final box = e.renderObject;
        if (box is RenderBox && box.hasSize) height = box.size.height;
        return;
      }
      e.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return height;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-wait-s1` / `#btn-wait-s2` and `#btn-action-main` ('Finish
  /// Observation'); the last one stays to re-open the summary.
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.canWait)
        LabAction(
          label: _t(s.scenario == 0 ? 'btn_wait_s1' : 'btn_wait_s2'),
          icon: s.scenario == 0
              ? Icons.hourglass_top_rounded
              : Icons.schedule_rounded,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          enabled: !s.busy,
          // The wait plays the HTML `stir` tone.
          silent: true,
          onTap: s.scenario == 0 ? _waitSettle : _waitSediment,
        ),
      if (s.canFinish)
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.arrow_forward_rounded,
          color: _Colors.blue500,
          foreground: _Colors.white,
          highlight: !s.done,
          enabled: !s.busy,
          // The summary plays the HTML `ding`.
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
        if (!_lab.isSidebarOpen && _lab.isLabActive) _scheduleCardCheck();
        final p = _lab.palette;
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        final n = data.steps.length;
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
          currentStep: s.done ? n + 1 : math.min(s.step, n),
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the summary
          // has been opened.
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

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final framing = _framingFor(context);
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / (fit * framing.k);
          _labelSize =
              _labelPx *
              (_labelFullScale / fit).clamp(1.0, _labelMaxBoost) /
              framing.k;
        }
        return LabStage(
          designSize: _design,
          // The framing moves the whole scene layer (painting and hit
          // tests), so gestures arrive in the scene's own coordinates.
          child: AnimatedContainer(
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            transform: framing.matrix,
            child: KeyedSubtree(
              key: _sceneKey,
              // The stirring rod is pressed and held (raw pointer events,
              // outside the gesture arena).
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerEnd,
                onPointerCancel: _onPointerEnd,
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
                          framing: framing,
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

/// Segments around lathes (vessels, cones) and rings.
const int _sides = 24;
const int _ringSides = 28;

/// Glass (`glassMat`, opacity 0.28): its far wall, seen through the near
/// one, and the near wall; the outline gives the glass an edge.
const double _glassBack = 0.16;
const double _glassFront = 0.22;
const double _glassEdge = 0.55;

/// Liquids: the near side is lighter so what is inside shows through.
const double _liquidBack = 0.85;
const double _liquidFront = 0.6;

/// The strainer's mesh bowl is see-through.
const double _meshBack = 0.65;
const double _meshFront = 0.45;

/// Pour stream: grows from the lip / shrinks back in 0.2 s (HTML
/// `pourStream.visible`).
const double _streamGrow = 0.2;

/// HTML stand-in labels: the chips sit on the table in front of each
/// object (the HTML put them 3 units below the object's origin).
const double _labelFront = 0.9;

/// The stirring progress ring (design px at label size 12).
const double _stirRingR = 13;

/// One quad of a lathe, reused from frame to frame.
class _Facet {
  final List<Offset> pts = List.filled(4, Offset.zero);
  double depth = 0;
  Color color = const Color(0x00000000);
  bool seam = true;
}

int _farFirst(_Facet a, _Facet b) => b.depth.compareTo(a.depth);

/// Paints, paths and facets reused by every frame (no allocation per
/// frame beyond the projected points).
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

  /// Round-ended thick lines (rims, handles, streams, rods).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// Even-odd path for flat rings (the drop zones).
  final Path ringPath = Path()..fillType = PathFillType.evenOdd;

  final List<_Facet> _pool = [];
  int _used = 0;
  final List<_Facet> facets = [];

  /// Starts a new list of facets (the previous list has been drawn).
  void beginFacets() {
    _used = 0;
    facets.clear();
  }

  _Facet takeFacet() {
    if (_used == _pool.length) _pool.add(_Facet());
    final f = _pool[_used++];
    facets.add(f);
    return f;
  }
}

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background and table) and the label text painters. Owned by the page
/// state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool? _labelsDark;
  ui.Picture? _backdrop;
  bool _backdropDark = true;

  double get labelSize => _labelSize;

  /// Drops the text painters when the language, label size or theme
  /// changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _labelsDark) {
      return;
    }
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _labelsDark = dark;
  }

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: (_labelsDark ?? true)
            ? _Colors.labelTextDark
            : _Colors.labelTextLight,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: labLetterSpacing(text, 0.2),
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// The static part of the scene (background and table), recorded once.
  ui.Picture backdrop(bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null && dark == _backdropDark) return cached;
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), dark, size, pens);
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
/// term on a face with normal [n]; [shine] adds a specular highlight
/// towards the camera from [at] (metal).
Color _lit(Color c, _V n, {double shine = 0, _V? at}) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  var out = Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
  if (shine > 0 && at != null) {
    final h = (_light + (_eye - at).unit).unit;
    final spec = math.pow(math.max(0.0, n.dot(h)), 24).toDouble() * shine;
    out = Color.lerp(
      out,
      _Colors.white.withValues(alpha: c.a),
      spec.clamp(0.0, 1.0),
    )!;
  }
  return out;
}

/// The inside of a surface with outward normal [n]: lit from the other
/// side and in shade.
Color _litInside(Color c, _V n) {
  final i =
      (_ambient + _diffuse * 0.5 * math.max(0.0, -n.dot(_light))) * _innerShade;
  return Color.from(
    alpha: c.a,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// HTML highlight: [c] pulled towards the pulse colour by [glow].
Color _glowing(Color c, double glow) =>
    glow <= 0 ? c : Color.lerp(c, _Colors.pulse.withValues(alpha: c.a), glow)!;

/// [c] with its alpha scaled by [k].
Color _fade(Color c, double k) => c.withValues(alpha: c.a * k);

/// Which part of a rim torus to draw.
enum _RimPart { near, far }

/// One face of an oriented box: its axis and the two axes across it.
enum _BoxFace { x, y, z }

/// Mesh drawing in the lab's camera.
class _Gfx {
  _Gfx(this.canvas, this.pens);

  final Canvas canvas;
  final _Pens pens;

  _Cam get cam => _cam;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// A surface of revolution (Three.js Cylinder / Cone / Sphere geometry):
  /// the [prof] (radius, height) points turned about the frame's axis at
  /// [base]. Drawn in two passes so contents sit inside it: first the
  /// inside of the far wall (and a floor disc, the far half of a rim), then
  /// [inside], then the outside facing the camera, a cap, the near half of
  /// the rim and an outline. [back] and [front] scale the walls' alpha
  /// (glass, see-through); [colors] gives each profile segment its own
  /// colour.
  void lathe(
    _V base,
    List<(double, double)> prof,
    Color color, {
    _Frame frame = _Frame.upright,
    double back = 1,
    double front = 1,
    double shine = 0,
    double glow = 0,
    List<Color>? colors,
    double? floorR,
    double floorY = 0,
    double? capR,
    double capY = 0,
    Color? capColor,
    double? rimR,
    double rimY = 0,
    double rimTube = 0,
    Color? rimColor,
    Color? outline,
    VoidCallback? inside,
    int sides = _sides,
  }) {
    if (floorR != null) {
      // The floor is seen from inside the vessel, in its shade.
      disc(
        frame.at(base, 0, floorY, 0),
        floorR,
        _fade(_glowing(_litInside(color, frame.ey * -1), glow), back),
        frame,
      );
    }
    _facets(
      base,
      prof,
      color,
      colors,
      frame,
      shine,
      glow,
      sides,
      back,
      front: false,
    );
    if (rimR != null) {
      rim(
        frame.at(base, 0, rimY, 0),
        rimR,
        rimTube,
        rimColor ?? _glowing(color, glow),
        frame,
        _RimPart.far,
      );
    }
    inside?.call();
    _facets(
      base,
      prof,
      color,
      colors,
      frame,
      shine,
      glow,
      sides,
      front,
      front: true,
    );
    if (capR != null) {
      final c = frame.at(base, 0, capY, 0);
      if (frame.ey.dot(cam.eye - c) > 0) {
        disc(
          c,
          capR,
          capColor ?? _fade(_glowing(_lit(color, frame.ey), glow), front),
          frame,
        );
      }
    }
    if (rimR != null) {
      rim(
        frame.at(base, 0, rimY, 0),
        rimR,
        rimTube,
        rimColor ?? _glowing(color, glow),
        frame,
        _RimPart.near,
      );
    }
    if (outline != null) _outline(base, prof, frame, outline, sides);
  }

  /// One pass of [lathe]: the facets turned away from the camera (seen
  /// from inside) or towards it, far ones first.
  void _facets(
    _V base,
    List<(double, double)> prof,
    Color color,
    List<Color>? colors,
    _Frame fr,
    double shine,
    double glow,
    int sides,
    double alpha, {
    required bool front,
  }) {
    if (alpha <= 0) return;
    pens.beginFacets();
    final step = 2 * math.pi / sides;
    for (var i = 0; i < prof.length - 1; i++) {
      final (r0, y0) = prof[i];
      final (r1, y1) = prof[i + 1];
      final dr = r1 - r0, dy = y1 - y0;
      final len = math.sqrt(dr * dr + dy * dy);
      if (len < 1e-9) continue;
      final nr = dy / len, ny = -dr / len;
      final base0 = colors != null && i < colors.length ? colors[i] : color;
      for (var j = 0; j < sides; j++) {
        final a0 = j * step, a1 = (j + 1) * step, am = (a0 + a1) / 2;
        final dm = fr.across(am);
        final n = dm * nr + fr.ey * ny;
        final mid = base + dm * ((r0 + r1) / 2) + fr.ey * ((y0 + y1) / 2);
        final facing = n.dot(cam.eye - mid) > 0;
        if (facing != front) continue;
        final d0 = fr.across(a0), d1 = fr.across(a1);
        final c = _fade(
          _glowing(
            facing
                ? _lit(base0, n, shine: shine, at: mid)
                : _litInside(base0, n),
            glow,
          ),
          alpha,
        );
        final f = pens.takeFacet()
          ..depth = cam.depth(mid)
          ..color = c
          ..seam = c.a > 0.99;
        f.pts[0] = cam.p(base + d0 * r0 + fr.ey * y0);
        f.pts[1] = cam.p(base + d1 * r0 + fr.ey * y0);
        f.pts[2] = cam.p(base + d1 * r1 + fr.ey * y1);
        f.pts[3] = cam.p(base + d0 * r1 + fr.ey * y1);
      }
    }
    pens.facets.sort(_farFirst);
    for (final f in pens.facets) {
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        _to(path, i, f.pts[i]);
      }
      path.close();
      canvas.drawPath(path, pens.fill..color = f.color);
      if (f.seam) canvas.drawPath(path, pens.seam..color = f.color);
    }
  }

  /// The silhouette of a lathe (its left and right edges and its top ring):
  /// the edge of a glass vessel.
  void _outline(
    _V base,
    List<(double, double)> prof,
    _Frame fr,
    Color color,
    int sides,
  ) {
    final left = pens.path..reset();
    final right = Path();
    for (var i = 0; i < prof.length; i++) {
      final (r, y) = prof[i];
      var lo = Offset.infinite;
      var hi = -Offset.infinite;
      for (var j = 0; j < sides; j++) {
        final o = cam.p(
          base + fr.across(j * 2 * math.pi / sides) * r + fr.ey * y,
        );
        if (lo == Offset.infinite || o.dx < lo.dx) lo = o;
        if (hi == -Offset.infinite || o.dx > hi.dx) hi = o;
      }
      _to(left, i, lo);
      _to(right, i, hi);
    }
    final edge = pens.stroke
      ..strokeWidth = 1.1
      ..color = color;
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);
    final (rTop, yTop) = prof.last;
    final top = Path();
    for (var j = 0; j <= _ringSides; j++) {
      _to(
        top,
        j,
        cam.p(
          base + fr.across(j * 2 * math.pi / _ringSides) * rTop + fr.ey * yTop,
        ),
      );
    }
    canvas.drawPath(top, edge);
  }

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A flat disc of radius [r] at [c] across the frame's axis.
  void disc(_V c, double r, Color color, [_Frame fr = _Frame.upright]) {
    final path = pens.path..reset();
    for (var i = 0; i <= _ringSides; i++) {
      _to(path, i, cam.p(c + fr.across(i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// A flat horizontal ring between [rIn] and [rOut] at [c] (the HTML
  /// `RingGeometry` drop zones).
  void ring(_V c, double rIn, double rOut, Color color) {
    final path = pens.ringPath..reset();
    for (final r in [rOut, rIn]) {
      for (var i = 0; i <= _ringSides; i++) {
        final o = cam.p(
          c + _Frame.upright.across(i * 2 * math.pi / _ringSides) * r,
        );
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

  /// TorusGeometry rim of radius [r] and tube [tube] at [c] across the
  /// frame's axis: the [part] nearer to / farther from the camera.
  void rim(_V c, double r, double tube, Color color, _Frame fr, _RimPart part) {
    final path = pens.path..reset();
    final toEye = cam.eye - c;
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      final d = fr.across(a);
      final keep = part == _RimPart.near ? d.dot(toEye) > 0 : d.dot(toEye) <= 0;
      if (!keep) {
        open = false;
        continue;
      }
      final o = cam.p(c + d * r);
      if (open) {
        path.lineTo(o.dx, o.dy);
      } else {
        path.moveTo(o.dx, o.dy);
        open = true;
      }
    }
    _tube(path, tube * cam.scaleAt(c), color, fr.ey);
  }

  /// Strokes [path] as a lit round tube of radius [r] (design px).
  void _tube(Path path, double r, Color color, _V n) {
    final w = math.max(1.2, 2 * r);
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w
        ..color = _lit(labShade(color, -0.1), n),
    );
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w * 0.35
        ..color = _lit(labShade(color, 0.3), n),
    );
  }

  /// A round rod (CylinderGeometry) from [a] to [b]: body, shaded
  /// underside and highlight.
  void rod(_V a, _V b, double radius, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    final len = d.distance;
    final w = math.max(1.5, 2 * radius * cam.scaleAt((a + b) * 0.5));
    if (len < 0.5) {
      canvas.drawCircle(pa, w / 2, pens.fill..color = color);
      return;
    }
    var n = Offset(-d.dy / len, d.dx / len);
    if (n.dy > 0) n = -n; // towards the top of the screen (lit side)
    canvas.drawLine(
      pa,
      pb,
      pens.limb
        ..strokeWidth = w
        ..color = color,
    );
    canvas.drawLine(
      pa - n * (w * 0.3),
      pb - n * (w * 0.3),
      pens.limb
        ..strokeWidth = w * 0.36
        ..color = labShade(color, -0.35),
    );
    canvas.drawLine(
      pa + n * (w * 0.24),
      pb + n * (w * 0.24),
      pens.limb
        ..strokeWidth = w * 0.22
        ..color = labShade(color, 0.45),
    );
  }

  /// BoxGeometry at [c] with half sizes [hx], [hy], [hz] along the frame's
  /// axes: the faces seen by the camera, lit.
  void box(
    _V c,
    _Frame fr,
    double hx,
    double hy,
    double hz,
    Color color, {
    double edge = 0.35,
  }) {
    for (final face in _BoxFace.values) {
      final (axis, h, u, hu, v, hv) = switch (face) {
        _BoxFace.x => (fr.ex, hx, fr.ey, hy, fr.ez, hz),
        _BoxFace.y => (fr.ey, hy, fr.ex, hx, fr.ez, hz),
        _BoxFace.z => (fr.ez, hz, fr.ex, hx, fr.ey, hy),
      };
      for (final sign in const [-1.0, 1.0]) {
        final n = axis * sign;
        final mid = c + n * h;
        if (n.dot(cam.eye - mid) <= 0) continue;
        final path = pens.path..reset();
        _to(path, 0, cam.p(mid - u * hu - v * hv));
        _to(path, 1, cam.p(mid + u * hu - v * hv));
        _to(path, 2, cam.p(mid + u * hu + v * hv));
        _to(path, 3, cam.p(mid - u * hu + v * hv));
        path.close();
        canvas.drawPath(path, pens.fill..color = _lit(color, n));
        if (edge > 0) {
          canvas.drawPath(
            path,
            pens.stroke
              ..strokeWidth = 0.8
              ..color = labShade(color, -0.5).withValues(alpha: edge),
          );
        }
      }
    }
  }

  /// A tea leaf (`BoxGeometry(0.25, 0.08, 0.18)`) at [c]: a small dark
  /// flake turned by [yaw] and tipped by [pitch].
  void leaf(_V c, double yaw, double pitch, double alpha) {
    final u = _V(math.cos(yaw), 0, math.sin(yaw)) * _leafHalfL;
    final v =
        _V(
          -math.sin(yaw) * math.cos(pitch),
          math.sin(pitch),
          math.cos(yaw) * math.cos(pitch),
        ) *
        _leafHalfW;
    final path = pens.path..reset();
    _to(path, 0, cam.p(c - u - v));
    _to(path, 1, cam.p(c + u - v));
    _to(path, 2, cam.p(c + u + v));
    _to(path, 3, cam.p(c - u + v));
    path.close();
    final color = _fade(_lit(_Colors.leaf, u.cross(v).unit * -1), alpha);
    canvas.drawPath(path, pens.fill..color = color);
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  /// A round dot of radius [r] (world units) at [c].
  void dot(_V c, double r, Color color) {
    canvas.drawCircle(
      cam.p(c),
      math.max(1.2, r * cam.scaleAt(c)),
      pens.fill..color = color,
    );
  }

  /// A falling stream (the HTML `pourStream` cylinders) from [top]
  /// straight down to [bottomY], [r0] wide at the top and [r1] at the
  /// bottom.
  void stream(_V top, double bottomY, double r0, double r1, Color color) {
    if (bottomY >= top.y) return;
    final a = cam.p(top);
    final b = cam.p(top.atY(bottomY));
    final k = cam.scaleAt(top);
    final w0 = math.max(1.5, 2 * r0 * k), w1 = math.max(1.2, 2 * r1 * k);
    final path = pens.path
      ..reset()
      ..moveTo(a.dx - w0 / 2, a.dy)
      ..lineTo(a.dx + w0 / 2, a.dy)
      ..lineTo(b.dx + w1 / 2, b.dy)
      ..lineTo(b.dx - w1 / 2, b.dy)
      ..close();
    canvas.drawPath(path, pens.fill..color = color);
    canvas.drawLine(
      a + Offset(w0 * 0.15, 0),
      b + Offset(w1 * 0.15, 0),
      pens.limb
        ..strokeWidth = math.max(1.0, w1 * 0.25)
        ..color = _Colors.white.withValues(alpha: 0.3),
    );
  }

  /// Soft blurred shadow of an elliptic footprint on the table.
  void shadow(double x, double z, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, 0.003, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }
}

/// The scene's static layer: background and the table
/// (`BoxGeometry(36, 1.5, 20)` with its top at 0, `tableMat`) with its
/// edge trim (`BoxGeometry(36.2, 0.2, 20.2)`, `tableEdgeMat`).
void _paintBackdrop(Canvas canvas, bool dark, Size size, _Pens pens) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final g = _Gfx(canvas, pens);
  g.box(
    const _V(0, -_tableThick / 2, 0),
    _Frame.upright,
    _tableHalfX,
    _tableThick / 2,
    _tableHalfZ,
    _Colors.table,
    edge: 0.4,
  );
  g.box(
    const _V(0, -0.1, 0),
    _Frame.upright,
    _tableHalfX + 0.1,
    0.1,
    _tableHalfZ + 0.1,
    _Colors.tableEdge,
    edge: 0,
  );
}

/// The strainer's bowl: a spherical cap from its rim (radius 2.3) down to
/// 1.25 below it.
final List<(double, double)> _bowlProfile = [
  for (var i = 6; i >= 0; i--)
    (
      math.max(0.04, _bowlR * math.sin(i * math.pi / 12)),
      -_bowlDepth * math.cos(i * math.pi / 12),
    ),
];

/// Radius of the flask's inside at height [y] above its base.
double _flaskInner(double y) {
  final r = y >= _flaskShoulder
      ? _flaskNeckR
      : _flaskBodyR - (_flaskBodyR - _flaskNeckR) * y / _flaskShoulder;
  return math.max(0.05, r - 0.12);
}

/// Paints the HTML Three.js scene of the current scenario: S1 the burner,
/// the saucepan of tea, the two cups and the tea strainer; S2 the beakers,
/// the filter paper, the funnel, the conical flask and its stand.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.framing,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Where labels may go (scene coordinates).
  final _Framing framing;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  /// The glass outline colour for the theme.
  Color get _edge =>
      (isDark ? _Colors.glass : _Colors.slate500).withValues(alpha: _glassEdge);

  /// HTML `update3DHighlight()` on the object to drag or hold (none while
  /// something moves).
  double _glowOf(_Item item) {
    final s = scene;
    final target = s.held ?? s.dragItem ?? (s.canStir ? _Item.rod : null);
    if (target != item) return 0;
    return _pulseMax * (math.sin(s.time * _pulseRate) + 1) / 2;
  }

  /// The object lifted above the others (held or pouring).
  _Item? get _lifted => scene.held ?? scene.pourTool;

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    canvas.drawPicture(cache.backdrop(isDark, size));
    final g = _Gfx(canvas, _pens);
    if (scene.scenario == 0) {
      _paintScenario1(g);
    } else {
      _paintScenario2(g);
    }
    _paintLabels(canvas);
    _paintStirRing(canvas);
    _paintConfetti(canvas);
  }

  /// Depth of [item] for painting far to near.
  double _depthOf(_Item item) {
    final lift = switch (item) {
      _Item.pan || _Item.mudBeaker => 1.75,
      _Item.cup1 || _Item.cup2 => 1.6,
      _Item.waterBeaker || _Item.decantBeaker => 2.75,
      _Item.funnel => 1.5,
      _Item.flask => 3.0,
      _ => 0.0,
    };
    return _cam.depth(scene.posOf(item) + _V(0, lift, 0));
  }

  /// Paints [items] far to near; the lifted object comes last, above the
  /// drop zones.
  void _paintInOrder(_Gfx g, List<_Item> items, void Function(_Item) paint) {
    final lifted = _lifted;
    final order = [
      for (final item in items)
        if (item != lifted) (item, _depthOf(item)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final (item, _) in order) {
      paint(item);
    }
    _paintZones(g);
    if (lifted != null && items.contains(lifted)) paint(lifted);
  }

  /// HTML drop zones (`glowMat` rings, opacity 0.35) of the current step
  /// (the folding area lies on the table and is drawn with it).
  void _paintZones(_Gfx g) {
    final s = scene;
    if (s.busy || s.done) return;
    final color = _Colors.zone.withValues(alpha: 0.35);
    if (s.scenario == 0) {
      switch (s.step) {
        case 2:
          g.ring(_zoneCup1, 2, 4, color);
        case 3:
          g.ring(_zoneStrainer, 2, 4, color);
        case 4:
          g.ring(_zonePan2, 2, 4.5, color);
      }
      return;
    }
    switch (s.step) {
      case 1:
        if (!s.mudPoured) g.ring(_zoneWater, 2.5, 4.5, color);
      case 3:
        g.ring(_zoneDecant, 2.5, 4.5, color);
      case 5:
        if (s.paperInFunnel) {
          g.ring(_zoneFlask, 2, 4, color);
        } else {
          g.ring(_zoneFunnel, 1.5, 3.2, color);
        }
      case 6:
        g.ring(_zoneFlask, 2, 4, color);
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _paintScenario1(_Gfx g) {
    final s = scene;
    g.shadow(_burnerAt.x - 0.6, _burnerAt.z - 0.5, 4.0, 3.6);
    for (final c in const [_cup1At, _cup2At]) {
      g.shadow(c.x - 0.4, c.z - 0.3, 2.0, 1.8);
    }
    final strainer = s.posOf(_Item.strainer);
    if (!s.strainerOn && strainer.y < 2) {
      g.shadow(strainer.x - 0.4, strainer.z - 0.3, 2.3, 2.0);
    }
    _paintBurner(g);
    _paintInOrder(
      g,
      [_Item.pan, _Item.cup1, _Item.cup2, if (!s.strainerOn) _Item.strainer],
      (item) {
        switch (item) {
          case _Item.pan:
            _paintPan(g);
          case _Item.cup1 || _Item.cup2:
            _paintCup(g, item);
          default:
            _paintStrainer(g, s.posOf(_Item.strainer));
        }
      },
    );
  }

  /// `burner`: a dark metal disc with two burner rings on top.
  void _paintBurner(_Gfx g) {
    g.lathe(
      _burnerAt,
      _burnerProfile,
      _Colors.darkMetal,
      shine: 0.3,
      capR: 3.5,
      capY: _burnerTop,
      capColor: labShade(_lit(_Colors.darkMetal, _V.up), 0.12),
    );
    final ring = labShade(_Colors.darkMetal, -0.45);
    for (final r in const [1.3, 2.5]) {
      g.ring(_burnerAt.atY(_burnerTop + 0.01), r - 0.08, r + 0.08, ring);
    }
  }

  /// `panS1`: the steel saucepan with its tea and leaves; it tilts about its
  /// base while pouring. Upright, its front wall is see-through.
  void _paintPan(_Gfx g) {
    final s = scene;
    final pos = s.posOf(_Item.pan);
    final tilt = s.tiltOf(_Item.pan);
    final fr = _Frame.rollZ(-tilt);
    final upright = tilt.abs() < 0.02;
    final glow = _glowOf(_Item.pan);
    g.lathe(
      pos,
      _panProfile,
      _Colors.metal,
      frame: fr,
      front: upright ? _panSeeThrough : 1,
      shine: 0.45,
      glow: glow,
      floorR: _panBottomR - 0.05,
      floorY: _panFloor,
      rimR: _panTopR,
      rimY: _panH,
      rimTube: 0.07,
      inside: upright ? () => _paintPanTea(g, pos) : null,
    );
    g.rod(
      fr.at(pos, -_panHandleIn, _panHandleY, 0),
      fr.at(pos, -_panHandleOut, _panHandleY, 0),
      _panHandleR,
      _lit(_glowing(_Colors.darkMetal, glow), _V.up),
    );
  }

  /// The tea in the saucepan and the leaves in it (swirling, then
  /// settled).
  void _paintPanTea(_Gfx g, _V pos) {
    final s = scene;
    if (s.panEmpty) return;
    final level = s.panTea.at(s.time);
    final top = _panFloor + (_teaTop - _panFloor) * level;
    const r0 = _panBottomR - 0.08;
    final r1 = _panBottomR + (_panTopR - _panBottomR) * top / _panH - 0.08;
    g.lathe(
      pos,
      [(r0, _panFloor), (r1, top)],
      _Colors.tea.withValues(alpha: 0.85),
      back: _liquidBack,
      front: _liquidFront,
      capR: r1,
      capY: top,
      capColor: labShade(_Colors.tea, 0.12).withValues(alpha: 0.55),
    );
    // The leaves are drawn over the tea so they stay visible through it.
    final spin = (s.settleAt < 0 ? s.time : s.settleAt) * _swirlRate;
    for (var i = 0; i < s.leaves.length; i++) {
      if (s.escaped && i < _escapeCount) continue;
      final leaf = s.leaves[i];
      final p = s.leafAt(leaf, i);
      if (p.y > top - 0.05) continue;
      g.leaf(pos + p, leaf.yaw + spin, leaf.pitch, 1);
    }
  }

  /// `cup1S1` / `cup2S1`: a glass cup with its tea; Cup 1 gets the leaves
  /// that escaped the decantation, Cup 2 holds the strainer.
  void _paintCup(_Gfx g, _Item item) {
    final s = scene;
    final cup1 = item == _Item.cup1;
    final at = cup1 ? _cup1At : _cup2At;
    final tea = (cup1 ? s.cup1Tea : s.cup2Tea).at(s.time);
    final top = _cupFloor + (_cupTeaTop - _cupFloor) * tea;
    g.lathe(
      at,
      _cupProfile,
      _Colors.glass,
      back: _glassBack,
      front: _glassFront,
      floorR: 1.75,
      floorY: _cupFloor,
      rimR: _cupTopR,
      rimY: _cupH,
      rimTube: _cupRimTube,
      rimColor: _Colors.glassRim.withValues(alpha: 0.85),
      outline: _edge,
      inside: () {
        if (tea > 0.002) {
          final r1 =
              _cupTeaR0 +
              (_cupTeaR1 - _cupTeaR0) *
                  (top - _cupFloor) /
                  (_cupTeaTop - _cupFloor);
          g.lathe(
            at,
            [(_cupTeaR0, _cupFloor), (r1, top)],
            _Colors.teaClear.withValues(alpha: 0.82),
            back: _liquidBack,
            front: _liquidFront,
            capR: r1,
            capY: top,
            capColor: labShade(_Colors.teaClear, 0.15).withValues(alpha: 0.55),
          );
        }
        if (cup1) {
          // Over the tea, so they stay visible through it.
          _paintCupLeaves(g, top);
          _paintStream(g, _Item.cup1);
          return;
        }
        _paintTrickle(g, top);
        if (s.strainerOn) {
          _paintStrainer(
            g,
            s.posOf(_Item.strainer),
            inside: () => _paintStream(g, _Item.cup2),
          );
        }
      },
    );
  }

  /// The leaves that escaped into Cup 1 sink one after another to its
  /// floor while the tea pours in.
  void _paintCupLeaves(_Gfx g, double teaTop) {
    final s = scene;
    if (!s.escaped) return;
    final t0 = s.cup1Tea.start;
    for (var i = 0; i < s.cupLeaves.length; i++) {
      final leaf = s.cupLeaves[i];
      final k = ((s.time - t0 - i * 0.1) / 0.35).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final from = math.max(teaTop, leaf.rest.y);
      final y = from + (leaf.rest.y - from) * Curves.easeIn.transform(k);
      g.leaf(_cup1At + leaf.rest.atY(y), leaf.yaw, leaf.pitch, 1);
    }
  }

  /// Tea running through the strainer's mesh into Cup 2.
  void _paintTrickle(_Gfx g, double teaTop) {
    final s = scene;
    if (s.pourInto != _Item.cup2 || s.streamOn < 0 || !s.strainerOn) return;
    final end = s.streamOff >= 0 ? s.streamOff + _streamGrow : double.infinity;
    if (s.time < s.streamOn + _streamGrow || s.time > end) return;
    final bowl = _strainerOn.y - _bowlDepth;
    if (teaTop >= bowl) return;
    g.stream(
      _strainerOn.atY(bowl),
      teaTop,
      0.1,
      0.08,
      _Colors.teaClear.withValues(alpha: 0.8),
    );
  }

  /// `strainerS1`: rim, mesh bowl (with the leaves it caught) and handle.
  void _paintStrainer(_Gfx g, _V pos, {VoidCallback? inside}) {
    final s = scene;
    final glow = _glowOf(_Item.strainer);
    final metal = _glowing(_Colors.metal, glow);
    g.rim(pos, _strainerR, _strainerTube, metal, _Frame.upright, _RimPart.far);
    g.lathe(
      pos,
      _bowlProfile,
      _Colors.metal,
      back: _meshBack,
      front: _meshFront,
      glow: glow,
      inside: () {
        final shown = (s.strainLeavesK.at(s.time) * s.strainLeaves.length)
            .floor();
        for (var i = 0; i < shown; i++) {
          final leaf = s.strainLeaves[i];
          g.leaf(pos + leaf.rest, leaf.yaw, leaf.pitch, 1);
        }
        inside?.call();
      },
    );
    // The mesh: two wire rings across the bowl.
    final wire = labShade(_Colors.metal, -0.3).withValues(alpha: 0.8);
    for (final d in const [0.45, 0.9]) {
      final r = _bowlR * math.sqrt(1 - math.pow(d / _bowlDepth, 2));
      final c = pos - _V(0, d, 0);
      g.rim(c, r, 0.025, wire, _Frame.upright, _RimPart.far);
      g.rim(c, r, 0.025, wire, _Frame.upright, _RimPart.near);
    }
    g.rim(pos, _strainerR, _strainerTube, metal, _Frame.upright, _RimPart.near);
    final yaw = s.strainerYaw.at(s.time);
    final handle = _V(-math.cos(yaw), 0, -math.sin(yaw));
    g.rod(
      pos + handle * _strainerHandleIn,
      pos + handle * _strainerHandleOut,
      _strainerHandleR,
      _lit(metal, _V.up),
    );
  }

  /// The stream of the pour going into [into], from the vessel's lip
  /// straight down to the surface it lands on. It grows down from the lip
  /// in 0.2 s and is drawn back up in 0.2 s.
  void _paintStream(_Gfx g, _Item into) {
    final s = scene;
    final tool = s.pourTool;
    if (tool == null || s.pourInto != into || s.streamOn < 0) return;
    final t = s.time;
    final scale =
        (s.streamOff >= 0
                ? 1 - (t - s.streamOff) / _streamGrow
                : (t - s.streamOn) / _streamGrow)
            .clamp(0.0, 1.0);
    if (scale <= 0.01) return;
    final pos = s.posOf(tool);
    final fr = _Frame.rollZ(-s.tilt.at(t));
    final (r, h) = switch (tool) {
      _Item.pan => (_panTopR, _panH),
      _Item.mudBeaker => (_mudBeakerR, _mudBeakerH),
      _ => (_beakerR, _beakerH),
    };
    final lip = fr.at(pos, r, h, 0);
    final double surface = switch (into) {
      _Item.cup1 =>
        _cup1At.y + _cupFloor + (_cupTeaTop - _cupFloor) * s.cup1Tea.at(t),
      _Item.cup2 => _strainerOn.y - _bowlDepth + 0.2,
      _Item.waterBeaker => _waterHome.y + _waterTopAt(t),
      _Item.decantBeaker =>
        _decantHome.y +
            _beakerFloor +
            (_decantTop - _beakerFloor) * s.decantLevel.at(t),
      _ => s.posOf(_Item.paper).y - _coneHalfH + 0.5,
    };
    final bottom = lip.y - (lip.y - surface) * scale;
    final (color, r0, r1) = switch (tool) {
      _Item.pan => (_Colors.tea, 0.35, 0.18),
      _Item.mudBeaker => (_Colors.muddyWater, 0.25, 0.2),
      _ => (_Colors.cloudyWater, 0.25, 0.2),
    };
    g.stream(lip, bottom, r0, r1, color.withValues(alpha: 0.85));
  }

  /// Height of the water in the first beaker of Scenario 2 above its base.
  double _waterTopAt(double t) =>
      _beakerFloor + (_waterTop - _beakerFloor) * scene.waterLevel.at(t);

  // ---------------------------------------------------------- scenario 2

  void _paintScenario2(_Gfx g) {
    final s = scene;
    for (final item in const [
      _Item.mudBeaker,
      _Item.waterBeaker,
      _Item.decantBeaker,
    ]) {
      final p = s.posOf(item);
      final r = item == _Item.mudBeaker ? _mudBeakerR : _beakerR;
      if (p.y < 0.5) g.shadow(p.x - 0.4, p.z - 0.3, r, r * 0.9);
    }
    final funnel = s.posOf(_Item.funnel);
    if (!s.funnelIn && funnel.y < 2) {
      g.shadow(funnel.x - 0.3, funnel.z - 0.2, 0.7, 0.6);
    }
    g.shadow(_standAt.x - 0.4, _standAt.z - 0.3, 3.4, 2.9);
    _paintStandBase(g);
    if (s.step == 4 && !s.busy && !s.done) {
      g.ring(_foldAt, _foldIn, _foldOut, _Colors.zone.withValues(alpha: 0.35));
    }
    _paintInOrder(
      g,
      [
        _Item.mudBeaker,
        _Item.waterBeaker,
        _Item.decantBeaker,
        if (!s.paperInFunnel) _Item.paper,
        if (!s.funnelIn) _Item.funnel,
        _Item.flask,
      ],
      (item) {
        switch (item) {
          case _Item.mudBeaker:
            _paintMudBeaker(g);
          case _Item.waterBeaker || _Item.decantBeaker:
            _paintBeaker(g, item);
          case _Item.paper:
            _paintPaper(g);
          case _Item.funnel:
            _paintFunnel(g, s.posOf(_Item.funnel));
          default:
            _paintFlask(g);
        }
      },
    );
  }

  /// `funnelStandS2`: its base and pole (the pole stands at the back of the
  /// base; the HTML's pole went through the flask).
  void _paintStandBase(_Gfx g) {
    g.box(
      _standAt + const _V(0, 0.2, 0),
      _Frame.upright,
      3,
      0.2,
      2.5,
      _Colors.darkMetal,
      edge: 0.4,
    );
    g.rod(
      _poleAt,
      _poleAt.atY(_poleTop),
      _poleR,
      _lit(_Colors.metal, _V.right),
    );
  }

  /// `mudBeakerS2`: the small beaker of muddy water (empty once poured).
  void _paintMudBeaker(_Gfx g) {
    final s = scene;
    final pos = s.posOf(_Item.mudBeaker);
    final fr = _Frame.rollZ(-s.tiltOf(_Item.mudBeaker));
    g.lathe(
      pos,
      _mudProfile,
      _Colors.glass,
      frame: fr,
      back: _glassBack,
      front: _glassFront,
      glow: _glowOf(_Item.mudBeaker),
      floorR: _mudBeakerR - 0.05,
      floorY: _beakerFloor,
      rimR: _mudBeakerR,
      rimY: _mudBeakerH,
      rimTube: 0.04,
      rimColor: _edge,
      outline: _edge,
      inside: () {
        final k = s.mudLevel.at(s.time);
        if (k <= 0.02) return;
        final top = _beakerFloor + (_mudTop - _beakerFloor) * k;
        const color = _Colors.muddyWater;
        g.lathe(
          pos,
          [(_mudR, _beakerFloor), (_mudR, top)],
          color.withValues(alpha: 0.9),
          frame: fr,
          back: _liquidBack,
          front: 0.85,
          capR: _mudR,
          capY: top,
          capColor: labShade(color, 0.12).withValues(alpha: 0.85),
        );
      },
    );
  }

  /// `waterBeakerS2` / `decantBeakerS2`: glass beakers with their water.
  void _paintBeaker(_Gfx g, _Item item) {
    final s = scene;
    final pos = s.posOf(item);
    final fr = _Frame.rollZ(-s.tiltOf(item));
    final first = item == _Item.waterBeaker;
    g.lathe(
      pos,
      _beakerProfile,
      _Colors.glass,
      frame: fr,
      back: _glassBack,
      front: _glassFront,
      glow: _glowOf(item),
      floorR: _beakerR - 0.05,
      floorY: _beakerFloor,
      rimR: _beakerR,
      rimY: _beakerH,
      rimTube: 0.04,
      rimColor: _edge,
      outline: _edge,
      inside: () {
        if (first) {
          _paintWaterContents(g, pos, fr);
        } else {
          _paintDecanted(g, pos, fr);
        }
        _paintStream(g, item);
      },
    );
    if (first && s.rodShown) _paintRod(g, below: false);
  }

  /// The first beaker's water (clean, muddy, then cloudy), the mud layer
  /// that settles in it, the mud specks and the stirring rod.
  void _paintWaterContents(_Gfx g, _V pos, _Frame fr) {
    final s = scene;
    final t = s.time;
    final top = _waterTopAt(t);
    final color = s.water.at(t).withValues(alpha: 0.8);
    g.lathe(
      pos,
      [(_waterR, _beakerFloor), (_waterR, top)],
      color,
      frame: fr,
      back: _liquidBack,
      front: _liquidFront,
      capR: _waterR,
      capY: top,
      capColor: labShade(color, 0.15).withValues(alpha: 0.6),
      inside: () {
        final k = s.sediment.at(t);
        if (k > 0.001) {
          final sTop = _beakerFloor + (_sedimentTop - _beakerFloor) * k;
          g.lathe(
            pos,
            [(_waterR, _beakerFloor), (_waterR, sTop)],
            _Colors.mud,
            frame: fr,
            capR: _waterR,
            capY: sTop,
          );
        }
        _paintSpecks(g, pos, fr, top);
        if (s.rodShown) _paintRod(g, below: true);
      },
    );
  }

  /// Mud specks: clumped low after the mud is poured in, spread through
  /// the water by the stirring, then sinking into the mud layer.
  void _paintSpecks(_Gfx g, _V pos, _Frame fr, double top) {
    final s = scene;
    if (!s.mudPoured) return;
    final t = s.time;
    final settle = s.sediment.at(t);
    if (settle >= 1) return;
    final appear = 1 - s.mudLevel.at(t);
    final mixed = s.stirred
        ? 1.0
        : (s.stirProgress / _stirFull).clamp(0.0, 1.0);
    final sink = Curves.easeIn.transform(settle);
    for (final sp in s.specks) {
      final low = _beakerFloor + 0.25 + (sp.y - 0.5) * 0.2;
      var y = low + (sp.y - low) * mixed;
      y += (_sedimentTop - y) * sink;
      if (y > top - 0.1) continue;
      final a = sp.a + s.stirAngle * 0.35;
      g.dot(
        fr.at(pos, math.cos(a) * sp.r, y, math.sin(a) * sp.r),
        sp.size,
        _Colors.mud.withValues(alpha: 0.9 * appear * (1 - settle)),
      );
    }
  }

  /// `rodS2`: the glass rod, tilted π/8 and turning about the vertical while
  /// it is held; drawn in two parts, under the water ([below]) and above it.
  void _paintRod(_Gfx g, {required bool below}) {
    final s = scene;
    final a = s.stirAngle;
    final dir = _V(
      -math.sin(_rodTilt) * math.cos(a),
      math.cos(_rodTilt),
      math.sin(_rodTilt) * math.sin(a),
    );
    final bottom = _rodCentre - dir * _rodHalf;
    final top = _rodCentre + dir * _rodHalf;
    final surface = _waterHome.y + _waterTopAt(s.time);
    final u = ((surface - bottom.y) / (top.y - bottom.y)).clamp(0.0, 1.0);
    final mid = _V.lerp(bottom, top, u);
    final color = _glowing(_Colors.glassRim, _glowOf(_Item.rod));
    if (below) {
      g.rod(bottom, mid, _rodR, color.withValues(alpha: 0.75));
    } else {
      g.rod(mid, top, _rodR, color);
    }
  }

  /// The top end of the stirring rod.
  _V get _rodTop {
    final a = scene.stirAngle;
    return _rodCentre +
        _V(
              -math.sin(_rodTilt) * math.cos(a),
              math.cos(_rodTilt),
              math.sin(_rodTilt) * math.sin(a),
            ) *
            _rodHalf;
  }

  /// The decanted cloudy water (emptied again by the filtering pour).
  void _paintDecanted(_Gfx g, _V pos, _Frame fr) {
    final s = scene;
    final t = s.time;
    final k = s.decantLevel.at(t);
    if (k <= 0.002) return;
    if (k <= _teaLast + 0.001 && s.filtrate.at(t) >= 1) return;
    final top = _beakerFloor + (_decantTop - _beakerFloor) * k;
    const color = _Colors.cloudyWater;
    g.lathe(
      pos,
      [(_waterR, _beakerFloor), (_waterR, top)],
      color.withValues(alpha: 0.68),
      frame: fr,
      back: _liquidBack,
      front: _liquidFront,
      capR: _waterR,
      capY: top,
      capColor: labShade(color, 0.15).withValues(alpha: 0.55),
    );
  }

  /// `paperS2`: the flat filter paper, the folding, or the cone (with the
  /// mud residue staining its point).
  void _paintPaper(_Gfx g) {
    final s = scene;
    final pos = s.posOf(_Item.paper);
    final glow = _glowOf(_Item.paper);
    if (s.folded) {
      _paintCone(g, pos, glow: glow);
      return;
    }
    if (s.foldAt >= 0) {
      _paintFolding(g, pos, (s.time - s.foldAt) * 1000 / _foldStageMs);
      return;
    }
    g.disc(
      pos.atY(pos.y - 0.01),
      _paperR + 0.06,
      labShade(_Colors.paper, -0.3),
    );
    g.disc(pos, _paperR, _glowing(_lit(_Colors.paper, _V.up), glow));
  }

  /// The filter paper folding on the folding area: [f] 0 … 1 folds it in
  /// half, 1 … 2 into a quarter, 2 … 3 opens it into a cone.
  void _paintFolding(_Gfx g, _V c, double f) {
    const n = 12;
    final top = _lit(_Colors.paper, _V.up);
    _V at(double a, double r) => c + _V(math.cos(a) * r, 0, math.sin(a) * r);
    if (f < 1) {
      final th = math.pi * Curves.easeInOut.transform(f.clamp(0.0, 1.0));
      g.poly([
        for (var i = 0; i <= n; i++) at(math.pi + i * math.pi / n, _paperR),
      ], top);
      g.poly([
        for (var i = 0; i <= n; i++)
          c +
              _V(
                math.cos(i * math.pi / n) * _paperR,
                math.sin(i * math.pi / n) * _paperR * math.sin(th),
                math.sin(i * math.pi / n) * _paperR * math.cos(th),
              ),
      ], labShade(top, -0.18 * math.sin(th)));
      return;
    }
    if (f < 2) {
      final ph = math.pi * Curves.easeInOut.transform((f - 1).clamp(0.0, 1.0));
      const q = n ~/ 2;
      g.poly([
        c,
        for (var i = 0; i <= q; i++) at(math.pi + i * math.pi / 2 / q, _paperR),
      ], labShade(top, -0.06));
      g.poly([
        c,
        for (var i = 0; i <= q; i++)
          c +
              _V(
                math.cos(1.5 * math.pi + i * math.pi / 2 / q) *
                    _paperR *
                    math.cos(ph),
                math.cos(1.5 * math.pi + i * math.pi / 2 / q) *
                    _paperR *
                    math.sin(ph),
                math.sin(1.5 * math.pi + i * math.pi / 2 / q) * _paperR,
              ),
      ], labShade(top, -0.2 * math.sin(ph)));
      return;
    }
    final k = Curves.easeOut.transform((f - 2).clamp(0.0, 1.0));
    if (k < 0.5) {
      const q = n ~/ 2;
      g.poly([
        c,
        for (var i = 0; i <= q; i++) at(math.pi + i * math.pi / 2 / q, _paperR),
      ], _fade(labShade(top, -0.06), 1 - 2 * k));
    }
    g.lathe(c, [
      (0.03, 0),
      (_paperR * (0.4 + 0.6 * k), 2 * _coneHalfH * math.max(0.05, k)),
    ], _Colors.paper);
  }

  /// The filter paper cone (point down) centred at [pos]; the mud residue
  /// stains its lower part.
  void _paintCone(_Gfx g, _V pos, {double glow = 0, VoidCallback? inside}) {
    final s = scene;
    final k = s.residue.at(s.time);
    const apex = -_coneHalfH;
    if (k <= 0.001) {
      g.lathe(
        pos,
        const [(0.03, apex), (_paperR, _coneHalfH)],
        _Colors.paper,
        glow: glow,
        inside: inside,
      );
      return;
    }
    final yr = apex + 1.1 * k;
    final rr = _paperR * (yr - apex) / (2 * _coneHalfH);
    final stained = Color.lerp(_Colors.paper, _Colors.mud, 0.8)!;
    g.lathe(
      pos,
      [(0.03, apex), (rr, yr), (_paperR, _coneHalfH)],
      _Colors.paper,
      colors: [stained, _Colors.paper],
      glow: glow,
      inside: inside,
    );
  }

  /// `funnelS2`: the glass funnel, with the paper cone (and the pour into
  /// it) once the paper is inside.
  void _paintFunnel(_Gfx g, _V pos) {
    final s = scene;
    g.lathe(
      pos,
      _funnelProfile,
      _Colors.glass,
      back: _glassBack,
      front: _glassFront,
      glow: _glowOf(_Item.funnel),
      rimR: _funnelR,
      rimY: _funnelRimY,
      rimTube: 0.06,
      rimColor: _Colors.glassRim.withValues(alpha: 0.85),
      outline: _edge,
      inside: s.paperInFunnel
          ? () => _paintCone(
              g,
              s.posOf(_Item.paper),
              glow: _glowOf(_Item.paper),
              inside: () => _paintStream(g, _Item.funnel),
            )
          : null,
    );
  }

  /// `flaskS2` with the filtrate and the drips, the funnel set in its mouth
  /// and the stand's ring around the funnel.
  void _paintFlask(_Gfx g) {
    final s = scene;
    const metal = _Colors.metal;
    // The clamp from the pole to the ring.
    final toPole = (_poleAt.atY(_ringAt.y) - _ringAt).atY(0).unit;
    g.rod(
      _poleAt.atY(_ringAt.y),
      _ringAt + toPole * _ringR,
      0.12,
      _lit(metal, _V.up),
    );
    g.rim(_ringAt, _ringR, _ringTube, metal, _Frame.upright, _RimPart.far);
    g.lathe(
      _flaskAt,
      _flaskProfile,
      _Colors.glass,
      back: _glassBack,
      front: _glassFront,
      floorR: _flaskBodyR - 0.1,
      floorY: 0.1,
      rimR: _flaskNeckR,
      rimY: _flaskH,
      rimTube: _flaskRimTube,
      rimColor: _Colors.glassRim.withValues(alpha: 0.85),
      outline: _edge,
      inside: () {
        _paintFiltrate(g);
        _paintDrips(g);
      },
    );
    if (s.funnelIn) _paintFunnel(g, s.posOf(_Item.funnel));
    g.rim(_ringAt, _ringR, _ringTube, metal, _Frame.upright, _RimPart.near);
  }

  /// `filtrateS2`: clear water rising in the flask.
  void _paintFiltrate(_Gfx g) {
    final s = scene;
    final k = s.filtrate.at(s.time);
    if (k <= 0.002) return;
    const y0 = 0.12;
    final y1 = y0 + (_filtrateTop - y0) * k;
    final r1 = _flaskInner(y1);
    const color = _Colors.cleanWater;
    g.lathe(
      _flaskAt,
      [(_flaskInner(y0), y0), (r1, y1)],
      color.withValues(alpha: 0.75),
      back: _liquidBack,
      front: _liquidFront,
      capR: r1,
      capY: y1,
      capColor: labShade(color, 0.2).withValues(alpha: 0.6),
    );
  }

  /// Clear water dripping from the funnel's stem into the flask.
  void _paintDrips(_Gfx g) {
    final s = scene;
    final t = s.time;
    if (s.dripFrom < 0 || t < s.dripFrom || t > s.dripTo + _dripFall) return;
    final tip = _funnelIn + const _V(0, _stemTip, 0);
    final surface =
        _flaskAt.y + 0.12 + (_filtrateTop - 0.12) * s.filtrate.at(t);
    final color = _Colors.cleanWater.withValues(alpha: 0.9);
    for (var i = 0; ; i++) {
      final start = s.dripFrom + i * _dripEvery;
      if (start > s.dripTo || start > t) break;
      final k = (t - start) / _dripFall;
      if (k > 1) continue;
      g.dot(tip.atY(tip.y + (surface - tip.y) * k * k), 0.12, color);
    }
  }

  // ------------------------------------------------------------ overlays

  /// HTML `createStdLabel` chips (in front of each object on the table)
  /// and, after the filtration, the residue and the filtrate; kept inside
  /// the free canvas and clear of each other.
  void _paintLabels(Canvas canvas) {
    if (!showLabels) return;
    final s = scene;
    final t = s.time;
    final lifted = _lifted;
    final labels = <(String, _V)>[];
    _V front(_Item item, double r) {
      final p = s.posOf(item);
      return _V(p.x, 0, p.z + r + _labelFront);
    }

    if (s.scenario == 0) {
      if (lifted != _Item.pan) {
        labels.add((
          s.panEmpty ? 'lbl_pan_empty' : 'lbl_pan',
          _V(_panHome.x, 0, _panHome.z + 3.8 + _labelFront),
        ));
      }
      labels
        ..add(('lbl_cup1', front(_Item.cup1, _cupTopR)))
        ..add(('lbl_cup2', front(_Item.cup2, _cupTopR)));
      if (lifted != _Item.strainer) {
        labels.add((
          'lbl_strainer',
          s.posOf(_Item.strainer) + const _V(0, 0.8, -_strainerR - 0.4),
        ));
      }
    } else {
      if (lifted != _Item.mudBeaker) {
        labels.add(('lbl_mud_beaker', front(_Item.mudBeaker, _mudBeakerR)));
      }
      if (lifted != _Item.waterBeaker) {
        labels.add(('lbl_water_beaker', front(_Item.waterBeaker, _beakerR)));
      }
      if (s.rodShown) {
        labels.add(('lbl_rod', _rodTop + const _V(0, 0.8, 0)));
      }
      if (lifted != _Item.decantBeaker) {
        final full = s.decantLevel.at(t) > _teaLast + 0.01;
        labels.add((
          full ? 'lbl_decanted' : 'lbl_decant_beaker',
          front(_Item.decantBeaker, _beakerR),
        ));
      }
      if (!s.paperInFunnel && lifted != _Item.paper) {
        final p = s.posOf(_Item.paper);
        labels.add(('lbl_paper', _V(p.x, 0, p.z + _paperR + _labelFront)));
      }
      if (s.step == 4 && !s.busy && !s.done) {
        labels.add((
          'lbl_fold',
          _V(_foldAt.x, 0, _foldAt.z + _foldOut + _labelFront),
        ));
      }
      if (lifted != _Item.funnel) {
        labels.add((
          'lbl_funnel',
          s.posOf(_Item.funnel) + const _V(0, _funnelRimY + 0.7, -_funnelR),
        ));
      }
      labels.add(('lbl_flask', front(_Item.flask, _flaskBodyR)));
      if (s.filtrate.at(t) >= 1 && s.residue.at(t) >= 1) {
        labels
          ..add((
            'lbl_residue',
            _funnelIn + const _V(-_funnelR - 0.9, _paperInFunnel - 0.4, 0),
          ))
          ..add((
            'lbl_filtrate',
            _flaskAt + const _V(-_flaskBodyR - 0.6, 0.8, 1),
          ));
      }
    }
    final placed = <Rect>[];
    for (final (key, at) in labels) {
      _chip(canvas, _cam.p(at), _t(key), placed);
    }
  }

  /// Places a [w] x [h] box centred near [at]: inside the free canvas and
  /// pushed down below any box already [placed].
  Rect _place(Offset at, double w, double h, List<Rect> placed) {
    final minX = framing.labelLeft + w / 2 + 2;
    final maxX = math.max(minX, framing.labelRight - w / 2 - 2);
    var rect = Rect.fromCenter(
      center: Offset(at.dx.clamp(minX, maxX), at.dy),
      width: w,
      height: h,
    );
    for (var guard = 0; guard < placed.length + 1; guard++) {
      final hit = placed.where((r) => r.overlaps(rect)).toList();
      if (hit.isEmpty) break;
      final down = hit.map((r) => r.bottom).reduce(math.max) + 2;
      rect = rect.translate(0, down - rect.top);
    }
    final maxBottom = framing.labelBottom - 2;
    if (rect.bottom > maxBottom) {
      rect = rect.translate(0, maxBottom - rect.bottom);
    }
    final minTop = framing.labelTop + 2;
    if (rect.top < minTop) rect = rect.translate(0, minTop - rect.top);
    placed.add(rect);
    return rect;
  }

  /// HTML label chip: glass background, blue border, bold text.
  void _chip(Canvas canvas, Offset at, String text, List<Rect> placed) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final rect = _place(at, tp.width + 2 * padX, tp.height + 2 * padY, placed);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.45));
    canvas.drawRRect(
      rr,
      _pens.fill..color = isDark ? _Colors.labelDark : _Colors.labelLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
        ..color = isDark ? _Colors.labelBorderDark : _Colors.labelBorderLight,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
  }

  /// How far the stirring has got: a ring that fills beside the rod's top
  /// while the rod is held (added; the HTML showed no progress).
  void _paintStirRing(Canvas canvas) {
    final s = scene;
    if (!s.canStir || s.stirProgress <= 0) return;
    final r = _stirRingR * cache.labelSize / _labelPx;
    final c = _cam.p(_rodTop) + Offset(r * 2.4, 0);
    final w = r * 0.32;
    canvas.drawCircle(
      c,
      r,
      _pens.stroke
        ..strokeWidth = w
        ..color = (isDark ? _Colors.white : _Colors.slate500).withValues(
          alpha: 0.3,
        ),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * (s.stirProgress / _stirFull).clamp(0.0, 1.0),
      false,
      _pens.stroke
        ..strokeWidth = w
        ..color = _Colors.blue400,
    );
  }

  /// HTML `confetti(...)` when a scenario is completed.
  void _paintConfetti(Canvas canvas) {
    final s = scene;
    final t0 = s.confettiAt;
    if (t0 < 0) return;
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
      old.framing != framing;
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
