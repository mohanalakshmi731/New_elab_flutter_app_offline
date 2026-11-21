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

/// Class 6 Science • Chapter 8 • Activity 4
/// Interconversion of Water's States: Melting and Freezing.
///
/// Native Flutter port of
/// `Cl6S-Ch8-A4-Interconversion_of_Water_s_States__Melting___Freezing.html`
/// ("A Journey Through States: Melting and Freezing").
///
/// Scenario 1 (From Puddle to Cube): a glass of water is dragged into the
/// freezer and a time-lapse turns the water into ice; the glass is taken
/// back out to the kitchen counter and a second time-lapse melts the ice.
///
/// Scenario 2 (The Coconut Oil Conundrum): the Season Controller turns
/// summer into winter and back; time-lapses show a jar of coconut oil
/// turning solid in the cold and liquid again in the warmth.
///
/// The Three.js kitchen and room are redrawn by a CustomPainter through a
/// perspective projection of the same camera (fov 45°, looking from the
/// HTML position (0, 20, 35) at (0, 5, 0)), pulled back along its line of
/// sight so the whole refrigerator fits the stage.
class Ch8A4InterconversionOfWatersStatesMeltingFreezingPage
    extends StatefulWidget {
  const Ch8A4InterconversionOfWatersStatesMeltingFreezingPage({super.key});

  @override
  State<Ch8A4InterconversionOfWatersStatesMeltingFreezingPage> createState() =>
      _MeltFreezeLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three Web Audio tones: `click`
/// (buttons, the sidebar, scenario change, Enter Lab, picking up and
/// placing the glass, the door opening, Time-Lapse), `thud` (the freezer
/// door shutting, mapped to drop.mp3) and `ding` (the summary, mapped to
/// success.mp3). correct.mp3 / error.mp3 are the shell's feedback tones.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// thud → `science/drop.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `click`.
  click('audio/class6/science/click.mp3'),

  /// HTML `thud`: the freezer door shuts.
  thud('audio/class6/science/drop.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// A hint after a wrong action (added: the HTML stayed silent).
  wrong('audio/class6/science/error.mp3'),

  /// HTML `ding`: the summary.
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
  static const Color slate600 = Color(0xFF475569);
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
  static const Color yellow500 = Color(0xFFEAB308);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark), 0xf8fafc (light, `setTheme`).
  static const Color sceneDark = slate900;
  static const Color sceneLight = slate50;

  /// `materials.wood` 0xc28e5c (counter base, table); counter top 0x475569.
  static const Color wood = Color(0xFFC28E5C);
  static const Color counterTop = slate600;

  /// `materials.fridgeBody` 0xf1f5f9 with `addEdge(…, 0x94a3b8, 0.5)`.
  static const Color fridge = slate100;
  static const Color fridgeEdge = Color(0x8094A3B8);

  /// Handles 0x94a3b8 (metal), the freezer's inner back panel 0x64748b,
  /// its shelf 0x334155, the door gasket 0x475569 and the freezer light
  /// `PointLight(0x38bdf8, 0.35)`.
  static const Color handle = slate400;
  static const Color cavity = slate500;
  static const Color freezerShelf = slate700;
  static const Color gasket = slate600;
  static const Color freezerLight = Color(0x1F38BDF8);

  /// `glassMat` 0xe0f2fe (opacity 0.25), `waterMat` 0x38bdf8 (0.7),
  /// `iceMat` white (0.85 → 1) with white edges.
  static const Color glass = Color(0xFFE0F2FE);
  static const Color water = Color(0xFF38BDF8);
  static const Color ice = white;

  /// `update3DHighlight()`: emissive pulse towards 0x38bdf8.
  static const Color highlight = Color(0xFF38BDF8);

  /// `oilLiquidMat` 0xfef08a (opacity 0.7), `oilSolidMat` white.
  static const Color oilLiquid = Color(0xFFFEF08A);
  static const Color oilSolid = white;

  /// Room walls 0x475569, window frame 0x94a3b8, sky 0xbae6fd (summer) →
  /// 0x64748b (winter), sun 0xfacc15, snow white, jar lid 0x94a3b8.
  static const Color roomWall = slate600;
  static const Color windowFrame = slate400;
  static const Color skySummer = Color(0xFFBAE6FD);
  static const Color skyWinter = slate500;
  static const Color sun = Color(0xFFFACC15);
  static const Color snow = white;
  static const Color lid = slate400;

  /// `updateThermometer()`: #3b82f6 at or below 0 °C, #ef4444 above.
  static const Color thermoCold = blue500;
  static const Color thermoHot = red500;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// `.label-3d` chips: glass panel rgba(15, 23, 42, 0.92), border
  /// blue-400, white bold text.
  static const Color labelBg = Color(0xEB0F172A);
  static const Color labelBorder = blue400;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: Color(0xF20F172A), // teacher board dark:bg-slate-900
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500, // text-blue-500 headings, border-blue-500
    onAccent: _Colors.white,
    primary: _Colors.blue600, // summary button from-blue-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900, // summary body bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // subtitle text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // header buttons dark:bg-slate-900/90
    buttonIcon: _Colors.blue500,
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
    panel: Color(0xF2FFFFFF), // teacher board bg-white
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600,
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
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.blue300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.blue500,
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
/// curtain, and `ding` for the summary.
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
// say exactly what to do on a touch screen ("tap" instead of "click"); the
// concepts that named a result before it was seen ("Freeze Water", "Melt
// Ice", "Freeze Oil", "Melt Oil") are neutral; the observations describe
// what is seen instead of "The user observes …". Keys marked "added" are
// new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'A Journey Through States: Melting and Freezing',
    'app_subtitle': 'Class 6 • A Journey through States of Water',
    'scen_1_opt':
        'Scenario 1: From Puddle to Cube: The Water-Ice Transformation',
    'scen_2_opt': 'Scenario 2: The Coconut Oil Conundrum: A Seasonal Change',
    's1_desc':
        'To observe and cause the processes of freezing and melting by changing the temperature of water.',
    's2_desc':
        'To understand that changes in ambient environmental temperature can cause substances other than water to change between liquid and solid states.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Place in Freezer',
    's1_a1':
        "Drag the glass of liquid water from the kitchen counter and drop it inside the refrigerator's freezer. The door will close automatically.",
    's1_o1': 'The glass of water is inside the freezer, and the door is shut.',
    's1_c2': 'Water in the Freezer',
    's1_a2':
        "Tap the 'Time-Lapse' button to see what happens to the water inside the freezer over time.",
    's1_o2': 'The liquid water changes into a solid block of ice.',
    's1_c3': 'Move to Counter',
    's1_a3':
        'Tap the freezer door to open it. Then drag the glass, which now contains a solid ice cube, and drop it onto the kitchen counter.',
    's1_o3':
        'The glass of ice is out of the freezer, at room temperature on the counter.',
    's1_c4': 'Ice at Room Temperature',
    's1_a4':
        "Tap the 'Time-Lapse' button again to see what happens to the ice on the counter.",
    's1_o4': 'The solid ice changes back into liquid water.',
    's1_c5': 'Final Observation',
    's1_a5':
        "Observe the final state of the water, then tap 'Finish Observation'.",
    's1_o5': 'The water is liquid again: freezing and melting can be reversed.',
    // Scenario 2 steps.
    's2_c1': 'Summer Observation',
    's2_a1':
        "Observe the jar of coconut oil on the table. Notice the 'Season Controller' slider on the right, which is set to 'Summer'.",
    's2_o1':
        'In summer the coconut oil is a liquid. The slider is the control you will use.',
    's2_c2': 'Change to Winter',
    's2_a2':
        "Drag the 'Season Controller' slider all the way to the top, to the 'Winter' setting.",
    's2_o2': 'The surroundings change from hot to cold.',
    's2_c3': 'Oil in the Cold',
    's2_a3':
        "Tap the 'Time-Lapse' button to see how the cold weather affects the coconut oil.",
    's2_o3': 'The liquid coconut oil turns solid.',
    's2_c4': 'Change to Summer',
    's2_a4':
        "Drag the 'Season Controller' slider back down to the 'Summer' setting.",
    's2_o4': 'The surroundings become warm again.',
    's2_c5': 'Oil in the Warmth',
    's2_a5':
        "Tap the 'Time-Lapse' button one more time to see what happens to the solid coconut oil.",
    's2_o5': 'The solid coconut oil melts back into a liquid.',
    // HTML `hud-instruction` lines (Scenario 2 has a sixth, after step 5).
    's1_hud_1':
        "Step 1: Drag the glass of water and drop it into the refrigerator's freezer.",
    's1_hud_2':
        "Step 2: Tap 'Time-Lapse' to see what happens to the water over time.",
    's1_hud_3':
        'Step 3: Tap the freezer door to open it. Drag the glass out onto the counter.',
    's1_hud_4':
        "Step 4: Tap 'Time-Lapse' to see what happens to the ice at room temperature.",
    's1_hud_5':
        "Step 5: Observe the final state of the water. Tap 'Finish Observation'.",
    's2_hud_1':
        "Step 1: Observe the jar of coconut oil on the table and the 'Season Controller'.",
    's2_hud_2':
        "Step 2: Drag the 'Season Controller' slider all the way up, to the 'Winter' setting.",
    's2_hud_3':
        "Step 3: Tap the 'Time-Lapse' button to see how the cold weather affects the coconut oil.",
    's2_hud_4':
        "Step 4: Drag the 'Season Controller' slider back down, to the 'Summer' setting.",
    's2_hud_5':
        "Step 5: Tap the 'Time-Lapse' button one more time to see what happens to the solid coconut oil.",
    's2_hud_6': "Observation complete! Tap 'Finish Observation'.",
    // Buttons and canvas cards.
    'btn_timelapse': 'Time-Lapse',
    'btn_finish': 'Finish Observation',
    'temp': 'Temperature',
    'unit_c': '{v}°C',
    'season_ctrl': 'Season Controller',
    'summer': 'Summer',
    'winter': 'Winter',
    // Canvas labels (HTML `createLabel`).
    'lbl_glass_water': 'Glass (Liquid Water)',
    'lbl_glass_ice': 'Glass (Solid Ice)',
    'lbl_freezer': 'Freezer',
    'lbl_jar_oil': 'Jar of Coconut Oil',
    // Added: hints where the HTML silently refused the action.
    'e_drop_freezer': 'Drop the glass inside the freezer.',
    'e_drop_counter': 'Drop the glass on the kitchen counter.',
    'e_open_door': 'The freezer door is shut. Tap the door to open it first.',
    'e_slide_winter': 'Drag the slider all the way up to Winter.',
    'e_slide_summer': 'Drag the slider all the way down to Summer.',
    // Summary popup (HTML `triggerMainAction`).
    'success_title': 'Observation Complete!',
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1':
        'Reversible Physical Change!\nBy cooling, liquid water freezes into solid ice. By heating (warming to room temperature), solid ice melts back into liquid water. The substance is still water!',
    'sum_s2':
        "Freezing isn't just for water!\nCooling causes liquid coconut oil to solidify. Melting happens when it warms up again. This confirms that change of state is a reversible physical change.",
    // Added: the sidebar's observation list and the scene descriptions.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Kitchen with a counter, a glass of water and a refrigerator with a freezer',
    'scene_s2': 'Room with a window, a table and a jar of coconut oil',
  },
  'hi': {
    'app_title': 'अवस्थाओं के माध्यम से यात्रा: पिघलना और जमना',
    'app_subtitle': 'कक्षा 6 • पानी की अवस्थाओं की यात्रा',
    'scen_1_opt': 'परिदृश्य 1: पोखर से घन तक: जल-बर्फ परिवर्तन',
    'scen_2_opt': 'परिदृश्य 2: नारियल तेल की पहेली: एक मौसमी परिवर्तन',
    's1_desc':
        'पानी के तापमान को बदलकर जमने और पिघलने की प्रक्रियाओं को करना और उनका अवलोकन करना।',
    's2_desc':
        'यह समझना कि परिवेश के तापमान में परिवर्तन से पानी के अलावा अन्य पदार्थ भी तरल और ठोस अवस्थाओं के बीच बदल सकते हैं।',
    's1_c1': 'फ्रीज़र में रखना',
    's1_a1':
        'किचन काउंटर से तरल पानी के गिलास को खींचें और उसे फ्रिज के फ्रीज़र के अंदर छोड़ दें। दरवाज़ा अपने आप बंद हो जाएगा।',
    's1_o1': 'पानी का गिलास फ्रीज़र के अंदर है, और दरवाज़ा बंद है।',
    's1_c2': 'फ्रीज़र में पानी',
    's1_a2':
        "समय के साथ फ्रीज़र के अंदर पानी का क्या होता है, यह देखने के लिए 'टाइम-लैप्स' बटन पर टैप करें।",
    's1_o2': 'तरल पानी बर्फ के एक ठोस टुकड़े में बदल जाता है।',
    's1_c3': 'काउंटर पर निकालना',
    's1_a3':
        'दरवाज़ा खोलने के लिए फ्रीज़र के दरवाज़े पर टैप करें। फिर गिलास को, जिसमें अब बर्फ का एक ठोस टुकड़ा है, खींचकर किचन काउंटर पर छोड़ दें।',
    's1_o3':
        'बर्फ का गिलास फ्रीज़र से बाहर, काउंटर पर कमरे के तापमान में रखा है।',
    's1_c4': 'कमरे के तापमान पर बर्फ',
    's1_a4':
        "काउंटर पर बर्फ का क्या होता है, यह देखने के लिए फिर से 'टाइम-लैप्स' बटन पर टैप करें।",
    's1_o4': 'ठोस बर्फ वापस तरल पानी में बदल जाती है।',
    's1_c5': 'अंतिम अवलोकन',
    's1_a5':
        "पानी की अंतिम अवस्था का अवलोकन करें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o5': 'पानी फिर से तरल है: जमने और पिघलने को उलटा जा सकता है।',
    's2_c1': 'गर्मी का अवलोकन',
    's2_a1':
        "मेज़ पर नारियल तेल के जार का अवलोकन करें। दाईं ओर 'मौसम नियंत्रक' स्लाइडर पर ध्यान दें, जो अभी 'गर्मी' पर सेट है।",
    's2_o1':
        'गर्मी में नारियल का तेल तरल है। यह स्लाइडर वह नियंत्रण है जिसका आप उपयोग करेंगे।',
    's2_c2': 'सर्दी में बदलना',
    's2_a2':
        "'मौसम नियंत्रक' स्लाइडर को पूरी तरह ऊपर, 'सर्दी' सेटिंग तक खींचें।",
    's2_o2': 'परिवेश का तापमान गर्म से ठंडा हो जाता है।',
    's2_c3': 'ठंड में तेल',
    's2_a3':
        "ठंड का नारियल तेल पर क्या प्रभाव पड़ता है, यह देखने के लिए 'टाइम-लैप्स' बटन पर टैप करें।",
    's2_o3': 'तरल नारियल तेल ठोस हो जाता है।',
    's2_c4': 'गर्मी में बदलना',
    's2_a4': "'मौसम नियंत्रक' स्लाइडर को वापस नीचे, 'गर्मी' सेटिंग तक खींचें।",
    's2_o4': 'परिवेश फिर से गर्म हो जाता है।',
    's2_c5': 'गर्मी में तेल',
    's2_a5':
        "ठोस नारियल तेल का क्या होता है, यह देखने के लिए एक बार फिर 'टाइम-लैप्स' बटन पर टैप करें।",
    's2_o5': 'ठोस नारियल तेल पिघलकर फिर से तरल बन जाता है।',
    's1_hud_1':
        'चरण 1: पानी के गिलास को खींचें और फ्रिज के फ्रीज़र में छोड़ दें।',
    's1_hud_2':
        "चरण 2: समय के साथ पानी का क्या होता है, यह देखने के लिए 'टाइम-लैप्स' पर टैप करें।",
    's1_hud_3':
        'चरण 3: दरवाज़ा खोलने के लिए फ्रीज़र पर टैप करें। गिलास को बाहर काउंटर पर खींचें।',
    's1_hud_4':
        "चरण 4: कमरे के तापमान पर बर्फ का क्या होता है, यह देखने के लिए 'टाइम-लैप्स' पर टैप करें।",
    's1_hud_5':
        "चरण 5: पानी की अंतिम अवस्था का अवलोकन करें। 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_hud_1':
        "चरण 1: मेज़ पर नारियल तेल के जार और 'मौसम नियंत्रक' का अवलोकन करें।",
    's2_hud_2':
        "चरण 2: 'मौसम नियंत्रक' स्लाइडर को पूरी तरह ऊपर, 'सर्दी' सेटिंग तक खींचें।",
    's2_hud_3':
        "चरण 3: ठंड का तेल पर क्या प्रभाव पड़ता है, यह देखने के लिए 'टाइम-लैप्स' पर टैप करें।",
    's2_hud_4':
        "चरण 4: 'मौसम नियंत्रक' स्लाइडर को वापस नीचे, 'गर्मी' सेटिंग तक खींचें।",
    's2_hud_5':
        "चरण 5: ठोस नारियल तेल का क्या होता है, यह देखने के लिए एक बार फिर 'टाइम-लैप्स' बटन पर टैप करें।",
    's2_hud_6': "अवलोकन पूर्ण! 'अवलोकन समाप्त करें' पर टैप करें।",
    'btn_timelapse': 'टाइम-लैप्स',
    'btn_finish': 'अवलोकन समाप्त करें',
    'temp': 'तापमान',
    'unit_c': '{v}°C',
    'season_ctrl': 'मौसम नियंत्रक',
    'summer': 'गर्मी',
    'winter': 'सर्दी',
    'lbl_glass_water': 'गिलास (तरल पानी)',
    'lbl_glass_ice': 'गिलास (ठोस बर्फ)',
    'lbl_freezer': 'फ्रीज़र',
    'lbl_jar_oil': 'नारियल तेल का जार',
    'e_drop_freezer': 'गिलास को फ्रीज़र के अंदर छोड़ें।',
    'e_drop_counter': 'गिलास को किचन काउंटर पर छोड़ें।',
    'e_open_door':
        'फ्रीज़र का दरवाज़ा बंद है। पहले दरवाज़े पर टैप करके उसे खोलें।',
    'e_slide_winter': 'स्लाइडर को पूरी तरह ऊपर, सर्दी तक खींचें।',
    'e_slide_summer': 'स्लाइडर को पूरी तरह नीचे, गर्मी तक खींचें।',
    'success_title': 'अवलोकन पूर्ण!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1':
        'उलटने योग्य भौतिक परिवर्तन!\nठंडा करने से तरल पानी जमकर ठोस बर्फ बन जाता है। गर्म करने से (कमरे के तापमान तक), ठोस बर्फ पिघलकर वापस तरल पानी बन जाती है। पदार्थ अभी भी पानी ही है!',
    'sum_s2':
        'जमना सिर्फ पानी के लिए नहीं है!\nठंडा होने से तरल नारियल का तेल जम जाता है। फिर से गर्म होने पर यह पिघल जाता है। इससे पुष्टि होती है कि अवस्था में परिवर्तन एक उलटने योग्य भौतिक परिवर्तन है।',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1': 'काउंटर, पानी के गिलास और फ्रीज़र वाले फ्रिज के साथ एक रसोई',
    'scene_s2': 'खिड़की, मेज़ और नारियल तेल के जार वाला एक कमरा',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 5;

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

/// HTML `controls.target.set(0, 5, 0)`.
const _V _target = _V(0, 5, 0);

/// HTML `camera.position.set(0, 20, 35)` (`resetCamera()`), pulled back
/// 1.25× from the target along the same line of sight: from the HTML
/// position the top of the refrigerator and its label are above the
/// picture.
const _V _eye = _V(0, 23.75, 43.75);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing the glass (short drags must pick it up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's labels stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// While the sidebar is collapsed the Scenario 2 room slides right by this
/// much (design px), so the jar is clear of the floating mission card at
/// the top left. The kitchen needs no slide: it is drawn low enough that
/// the card stays above the glass, and the freezer is right of the card.
const double _roomShift = 170;

/// The slide follows the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the sliding scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the slide.
const ValueKey<String> _sceneKey = ValueKey('ch8-a4-scene');

/// Canvas cards (thermometer, Season Controller): their top edge, below the
/// toast band; the band kept free for the HUD while the sidebar is open;
/// width and gap; the tallest / shortest thermometer tube and slider track
/// (dp, the largest scaled by the UI scale); the space the rest of a card
/// takes (labels, icons, padding, at UI scale 1).
const double _cardTop = 56;
const double _hudBand = 80;
const double _cardWidth = 60;
const double _cardMinWidth = 56;
const double _cardGap = 6;
const double _columnMax = 132;
const double _columnMin = 56;
const double _cardChrome = 104;

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

  /// Forward (`camera.getWorldDirection`), right and up.
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

  /// Where the ray through [s] meets the plane through [point] facing the
  /// camera (HTML `dragPlane.setFromNormalAndCoplanarPoint(
  /// camera.getWorldDirection(), target.position)`).
  _V? onPlane(Offset s, _V point) {
    final dir = ray(s);
    final denom = dir.dot(f);
    if (denom.abs() < 1e-6) return null;
    final t = (point - eye).dot(f) / denom;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// Scenario 1 camera. The kitchen is drawn low and left of centre: the
/// floating mission card (top left, sidebar collapsed) stays above the
/// glass on the counter, and the thermometer card (top right) and the tool
/// column stay right of the refrigerator.
final _Cam _camKitchen = _Cam(_eye, _target, const Offset(420, 400));

/// Scenario 2 camera: the window and the jar, left of the canvas cards.
final _Cam _camRoom = _Cam(_eye, _target, const Offset(440, 300));

/// HTML `DirectionalLight(0xffffff, 0.7)` at (10, 20, 15), normalised.
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// HTML `AmbientLight(0xffffff, 0.8)` plus the key light, toned down so the
/// lit faces do not all clip to white.
const double _ambient = 0.62;
const double _diffuse = 0.5;

// ---------------------------------------------------- scenario 1: kitchen

/// `counterGrp` at (-10, 0, 0): base `BoxGeometry(16, 4, 12)` at y 2, top
/// `BoxGeometry(17, 0.5, 13)` at y 4.25 (its surface at y 4.5).
const _V _counterAt = _V(-10, 0, 0);
const double _counterTopY = 4.5;

/// `fridgeGroup` at (10, 0, -2); the hollow freezer body (`fTopBody`) 16
/// above it.
const _V _fridgeAt = _V(10, 0, -2);
const _V _freezerAt = _V(10, 16, -2);

/// The glass: at the start (`glassS1.position` (-10, 7.35, 2)), on the
/// freezer shelf (`freezerShelf` (10, 13.6, -1) + 2.85) and back on the
/// counter (`counterShelf` (-10, 4.5, 0) + 2.85).
const _V _glassHome = _V(-10, 7.35, 2);
const _V _glassInFreezer = _V(10, 16.45, -1);
const _V _glassOnCounter = _V(-10, 7.35, 0);

/// Glass body `CylinderGeometry(2.5, 2.0, 6)`: half its height and its
/// radii; the label sits 4 below its centre (`createLabel(…, -4)`).
const double _glassHalf = 3;
const double _glassTopR = 2.5;
const double _glassBottomR = 2.0;
const double _glassLabelDrop = 4;

/// `fDoorPivot` at the freezer's left front edge ((-5, 16, 5) in the
/// fridge); the door opens to π / 1.5 (120°).
const _V _doorPivot = _V(5, 16, 3);
const double _doorOpenAngle = math.pi / 1.5;

/// Where the glass centre must be let go (on its drag plane, which faces
/// the camera) to count as inside the freezer (its opening x 5.5–14.5,
/// y 12.5–19.5, with a margin) or on the counter (top x -18.5 to -1.5,
/// up to 8 above the top). The HTML accepted any drop within 15 units of
/// the target, which included the middle of the room.
const double _freezerMinX = 4;
const double _freezerMaxX = 16;
const double _freezerMinY = 11;
const double _freezerMaxY = 21.5;
const double _counterMinX = -19;
const double _counterMaxX = -1;
const double _counterMinY = 4.5;
const double _counterMaxY = 12.5;

/// The dragged glass stays in the kitchen.
const double _dragMinX = -22;
const double _dragMaxX = 20;
const double _dragMinY = 3;
const double _dragMaxY = 24;

/// Opacities: water `waterMat` 0.7; ice shrinks to (0.8, 0.1, 0.8) while
/// melting.
const double _waterAlpha = 0.7;
const double _meltWidth = 0.2;
const double _meltHeight = 0.9;

/// Temperatures (°C): room (`updateThermometer(25)`) and freezer (-18);
/// Scenario 2: summer 30 → winter 5 (`30 - v * 25`). The thermometer maps
/// -20 … 40 °C to 5–95 % of its tube.
const double _roomTemp = 25;
const double _freezerTemp = -18;
const double _summerTemp = 30;
const double _seasonSpan = 25;
const double _thermoMin = -20;
const double _thermoRange = 60;

/// CSS `transition: height 0.5s ease-out` of the thermometer liquid,
/// approximated by an exponential approach with this time constant (s).
const double _thermoLag = 0.12;

/// HTML timings (ms): the glass glides to the shelf / counter (500,
/// Linear) or back (500, Quadratic.Out); the door swings (600); the
/// thermometer tween (1000); the time-lapses (water → ice 2000, ice →
/// water 3000, coconut oil 2000); the Scenario 2 look step (3000).
const int _glideMs = 500;
const int _doorMs = 600;
const int _tempMs = 1000;
const int _freezeMs = 2000;
const int _meltMs = 3000;
const int _oilMs = 2000;
const int _lookMs = 3000;

/// Added: during the freezer time-lapse the shut door turns see-through
/// (to 25 % in 0.3 s), so the learner can watch the water freeze; 0.6 s
/// after the ice has formed it fades back in 0.5 s.
const double _xrayIn = 0.3;
const double _xrayHold = 0.6;
const double _xrayOut = 0.5;
const double _xrayMinAlpha = 0.25;

/// HTML `update3DHighlight()`: `(sin(Date.now() * 0.005) + 1) / 2`, mixed
/// in at half strength.
const double _pulseRate = 5;
const double _pulseStrength = 0.5;

// ------------------------------------------------------ scenario 2: room

/// `jarS2` at (0, 4.85, 0) on the table (`BoxGeometry(40, 2, 15)`, top at
/// y 2); its label 5 above (`createLabel(…, 5)`).
const _V _jarAt = _V(0, 4.85, 0);
const double _jarLabelRise = 5;

/// `windowSnowGrp` at (0, 12, -11): 50 flakes spread over 24 × 16, falling
/// 0.05–0.1 per frame (at 60 fps), back to the top below -7.
const int _flakeCount = 50;
const _V _snowAt = _V(0, 12, -11);
const double _flakeSpreadX = 24;
const double _flakeSpreadY = 16;
const double _flakeRespawnX = 20;
const double _flakeTop = 7;
const double _flakeBottom = -7;
const double _flakeMinSpeed = 0.05;
const double _flakeSpeedRange = 0.05;
const double _framesPerSecond = 60;
const double _flakeRadius = 0.2;
const double _flakeAlpha = 0.8;

/// A straight move between two points over [seconds] from [start] (scene
/// time), eased by [curve] (a TWEEN.js tween on `position`).
@immutable
class _Move {
  const _Move(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Move.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, curve.transform((t - start) / seconds));
  }
}

/// A number eased from [from] to [to] (a TWEEN.js tween on a scalar,
/// default Linear easing).
@immutable
class _Ramp {
  const _Ramp(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final double from;
  final double to;
  final double start;
  final double seconds;
  final Curve curve;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * curve.transform((t - start) / seconds);
  }
}

/// One snowflake (HTML `windowSnowGrp` child), in the snow group's frame.
class _Flake {
  double x = 0;
  double y = 0;

  /// Units per frame at 60 fps (`userData.speed`).
  double speed = _flakeMinSpeed;
}

/// Thermometer fill (0.05 … 0.95 of the tube) for [temp] °C
/// (`updateThermometer`).
double _column(double temp) =>
    ((temp - _thermoMin) / _thermoRange).clamp(0.05, 0.95).toDouble();

/// Mutable scene read by the painters every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based; Scenario 2 reaches 6 after its fifth step).
  int step = 1;

  /// HTML `State.isAnimating`: something glides or a time-lapse runs, and
  /// the scene ignores touches meanwhile.
  bool busy = false;

  /// 'Finish Observation' was tapped: the summary is open.
  bool done = false;

  /// The learner holds the glass (HTML `isDragging`).
  bool held = false;

  // ------------------------------------------------------------ scenario 1
  _Move glass = const _Move.still(_glassHome);

  /// The glass rests on the freezer shelf.
  bool inFreezer = false;

  /// Door angle about its hinge (HTML `fDoorPivot.rotation.y`) and the
  /// HTML `State.freezerDoorOpen` flag (open at the start).
  _Ramp door = const _Ramp.still(_doorOpenAngle);
  bool doorOpen = true;

  /// Water and ice opacity, and how far the ice has melted (0 … 1).
  _Ramp water = const _Ramp.still(_waterAlpha);
  _Ramp ice = const _Ramp.still(0);
  _Ramp melt = const _Ramp.still(0);

  /// The glass holds ice (from the end of the freezing time-lapse to the
  /// end of the melting one): its label reads "Solid Ice".
  bool frozen = false;

  /// HTML `State.currentTemp` in Scenario 1.
  _Ramp kitchenTemp = const _Ramp.still(_roomTemp);

  /// See-through freezer door (0 … 1), added.
  _Ramp xray = const _Ramp.still(0);

  // ------------------------------------------------------------ scenario 2
  /// Season Controller: 0 summer (bottom) … 1 winter (top).
  double season = 0;

  /// Coconut oil: 0 liquid … 1 solid.
  _Ramp oil = const _Ramp.still(0);
  final List<_Flake> flakes = [for (var i = 0; i < _flakeCount; i++) _Flake()];

  // ----------------------------------------------------------- thermometer
  /// Shown fill of the thermometer tube (0 … 1) and how blue its liquid
  /// is (0 red … 1 blue), both following the temperature with the CSS lag.
  double column = _column(_roomTemp);
  double cold = 0;

  /// The temperature on the thermometer (°C).
  double get temperature =>
      scenario == 0 ? kitchenTemp.at(time) : _summerTemp - _seasonSpan * season;

  _V get glassPos => glass.at(time);
  double get doorAngle => door.at(time);
  double get waterOpacity => water.at(time);
  double get iceOpacity => ice.at(time);
  double get oilSolid => oil.at(time);

  /// Snow falls behind the window once past half way to winter.
  bool get snowing => scenario == 1 && season > 0.5;

  /// HTML `State.activeDragTarget`: the glass can be picked up in step 1,
  /// and in step 3 once the door is open.
  bool get canDragGlass =>
      scenario == 0 && !busy && !done && (step == 1 || (step == 3 && doorOpen));

  /// HTML highlight: the shut door pulses in step 3, the glass while it
  /// can be dragged.
  bool get doorPulse => scenario == 0 && step == 3 && !doorOpen && !busy;
  bool get glassPulse => canDragGlass && !held;

  /// The scenario's last step: Scenario 1 step 5, Scenario 2 step 6.
  int get finishStep => scenario == 0 ? _stepCount : _stepCount + 1;

  // ------------------------------------- Scenario 1 points (design space)
  // Where the learner touches the kitchen; the QA flows read them.

  /// Centre of the glass.
  Offset get glassPoint => _camKitchen.p(glassPos);

  /// Middle of the freezer door's front at its current angle.
  Offset get doorPoint =>
      _camKitchen.p(_doorPivot + _yawed(const _V(5, 0, 1), doorAngle));

  /// The glass centre on the freezer shelf and on the counter.
  Offset get freezerPoint => _camKitchen.p(_glassInFreezer);
  Offset get counterPoint => _camKitchen.p(_glassOnCounter);

  /// The middle of the refrigerator's lower part, and the floor between the
  /// counter and the refrigerator.
  Offset get fridgePoint => _camKitchen.p(_fridgeAt + const _V(0, 6, 4));
  Offset get floorPoint => _camKitchen.p(const _V(0, 5, 2));

  /// HTML `resetScenarioState(sc)`.
  void load(int index, math.Random rnd) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = false;
    glass = const _Move.still(_glassHome);
    inFreezer = false;
    door = const _Ramp.still(_doorOpenAngle);
    doorOpen = true;
    water = const _Ramp.still(_waterAlpha);
    ice = const _Ramp.still(0);
    melt = const _Ramp.still(0);
    frozen = false;
    kitchenTemp = const _Ramp.still(_roomTemp);
    xray = const _Ramp.still(0);
    season = 0;
    oil = const _Ramp.still(0);
    for (final f in flakes) {
      f
        ..x = (rnd.nextDouble() - 0.5) * _flakeSpreadX
        ..y = (rnd.nextDouble() - 0.5) * _flakeSpreadY
        ..speed = _flakeMinSpeed + rnd.nextDouble() * _flakeSpeedRange;
    }
    column = _column(temperature);
    cold = temperature <= 0 ? 1 : 0;
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the glass while it can be dragged ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _MeltFreezeLabState
    extends State<Ch8A4InterconversionOfWatersStatesMeltingFreezingPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// The thermometer's text (whole degrees) and the Season Controller's
  /// value (0 … 100): only their cards rebuild when they change.
  final ValueNotifier<int> _tempShown = ValueNotifier(_roomTemp.round());
  final ValueNotifier<double> _seasonValue = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in design pixels for the current stage
  /// scale, and the tool column's left edge (set while laying out).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// HTML `dragPlane` point and `dragOffset` of the held glass.
  _V _planePoint = _V.zero;
  _V _grabOffset = _V.zero;

  /// The held glass has actually been dragged (past the slop).
  bool _moved = false;

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
    _scene.load(0, _rnd);
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
    _tempShown.dispose();
    _seasonValue.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame advances the clock, the snow and the thermometer, and repaints.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (t - s.time).clamp(0.0, 0.1);
    s.time = t;
    _tickSnow(dt);
    _tickThermometer(dt);
    _frame.value = t;
  }

  /// HTML snow loop: each flake falls by its speed every frame and starts
  /// again at the top, at a new x, once it is below the window.
  void _tickSnow(double dt) {
    final s = _scene;
    if (!s.snowing) return;
    for (final f in s.flakes) {
      f.y -= f.speed * _framesPerSecond * dt;
      if (f.y < _flakeBottom) {
        f
          ..y = _flakeTop
          ..x = (_rnd.nextDouble() - 0.5) * _flakeRespawnX;
      }
    }
  }

  /// HTML `updateThermometer(temp)`: the text follows at once, the liquid
  /// (height and colour) with the CSS transition's lag.
  void _tickThermometer(double dt) {
    final s = _scene;
    final temp = s.temperature;
    final k = 1 - math.exp(-dt / _thermoLag);
    s
      ..column += (_column(temp) - s.column) * k
      ..cold += ((temp <= 0 ? 1.0 : 0.0) - s.cold) * k;
    final shown = temp.round();
    if (_tempShown.value != shown) _tempShown.value = shown;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index, _rnd);
      _moved = false;
    });
    _seasonValue.value = 0;
    _tempShown.value = _scene.temperature.round();
    _lab.resetView(sound: false);
    // HTML `setTimeout(advanceStep, 3000)`: Scenario 2 step 1 is looked
    // at. The HTML never cancelled it, so a quick switch to Scenario 1
    // skipped a step there.
    if (index == 1) {
      _lab.after(const Duration(milliseconds: _lookMs), () {
        if (!mounted) return;
        final s = _scene;
        if (s.scenario == 1 && s.step == 1) setState(() => s.step = 2);
      });
    }
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

  /// The summary popup (HTML `triggerMainAction()`: header "Observation
  /// Complete!", title "Scenario n Complete!", the summary).
  void _conclude(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: Duration.zero,
      title: () => _t('success_title'),
      heading: () => labFormat(_t('sc_complete'), {'n': scenario + 1}),
      body: () => _t('sum_s${scenario + 1}'),
    );
  }

  /// Runs [then] after [ms] if the page is still open.
  void _after(int ms, VoidCallback then) {
    _lab.after(Duration(milliseconds: ms), () {
      if (mounted) then();
    });
  }

  // ------------------------------------------------- scenario 1 actions

  /// HTML `executeStepAction()` step 1: the glass glides onto the freezer
  /// shelf, the door swings shut (thud), the thermometer drops to -18 °C,
  /// then step 2.
  void _placeInFreezer(_V from) {
    final s = _scene;
    _setBusy(true);
    _Sound.click.play();
    s.glass = _Move(from, _glassInFreezer, s.time, _glideMs / 1000);
    _after(_glideMs, () {
      setState(() {
        s
          ..inFreezer = true
          ..door = _Ramp(
            s.doorAngle,
            0,
            s.time,
            _doorMs / 1000,
            Curves.easeInQuad,
          );
      });
      _after(_doorMs, () {
        _Sound.thud.play();
        setState(() {
          s
            ..doorOpen = false
            ..kitchenTemp = _Ramp(
              _roomTemp,
              _freezerTemp,
              s.time,
              _tempMs / 1000,
            );
        });
        _after(_tempMs, () {
          setState(() {
            s
              ..busy = false
              ..step = 2;
          });
        });
      });
    });
  }

  /// HTML `executeStepAction()` step 3: the glass glides onto the counter,
  /// the thermometer rises to 25 °C, then step 4.
  void _placeOnCounter(_V from) {
    final s = _scene;
    _setBusy(true);
    _Sound.click.play();
    setState(() {
      s
        ..inFreezer = false
        ..glass = _Move(from, _glassOnCounter, s.time, _glideMs / 1000);
    });
    _after(_glideMs, () {
      setState(() {
        s.kitchenTemp = _Ramp(_freezerTemp, _roomTemp, s.time, _tempMs / 1000);
      });
      _after(_tempMs, () {
        setState(() {
          s
            ..busy = false
            ..step = 4;
        });
      });
    });
  }

  /// HTML revert (`TWEEN … to(homePos, 500)`, Quadratic.Out): the glass goes
  /// back where it was. The HTML only clicked; the toast [key] now says
  /// where the glass belongs.
  void _revert(_V from, _V to, String key) {
    final s = _scene;
    _toast(key, error: true, sound: true);
    _setBusy(true);
    s.glass = _Move(from, to, s.time, _glideMs / 1000, Curves.easeOutQuad);
    _after(_glideMs, () => _setBusy(false));
  }

  /// HTML door click (step 3): the door swings open (600 ms, Quadratic.Out).
  void _openDoor() {
    final s = _scene;
    _setBusy(true);
    _Sound.click.play();
    s.door = _Ramp(
      0,
      _doorOpenAngle,
      s.time,
      _doorMs / 1000,
      Curves.easeOutQuad,
    );
    _after(_doorMs, () {
      setState(() {
        s
          ..doorOpen = true
          ..busy = false;
      });
    });
  }

  /// HTML `triggerTimeLapse()`.
  void _timeLapse() {
    final s = _scene;
    if (s.busy || s.done) return;
    _setBusy(true);
    final t = s.time;
    if (s.scenario == 0 && s.step == 2) {
      // Water → ice (2 s), watched through the see-through door.
      s
        ..water = _Ramp(_waterAlpha, 0, t, _freezeMs / 1000)
        ..ice = _Ramp(0, 1, t, _freezeMs / 1000)
        ..xray = _Ramp(0, 1, t, _xrayIn);
      _after(_freezeMs, () {
        setState(() {
          s
            ..frozen = true
            ..busy = false
            ..step = 3
            ..xray = _Ramp(1, 0, s.time + _xrayHold, _xrayOut);
        });
      });
    } else if (s.scenario == 0 && s.step == 4) {
      // Ice → water (3 s): the ice shrinks and fades as the water returns.
      s
        ..water = _Ramp(0, _waterAlpha, t, _meltMs / 1000)
        ..ice = _Ramp(1, 0, t, _meltMs / 1000)
        ..melt = _Ramp(0, 1, t, _meltMs / 1000);
      _after(_meltMs, () {
        setState(() {
          s
            ..frozen = false
            ..busy = false
            ..step = 5;
        });
      });
    } else if (s.scenario == 1 && (s.step == 3 || s.step == 5)) {
      // Coconut oil: liquid → solid in the cold, solid → liquid in summer.
      final solidify = s.step == 3;
      s.oil = _Ramp(solidify ? 0 : 1, solidify ? 1 : 0, t, _oilMs / 1000);
      _after(_oilMs, () {
        setState(() {
          s
            ..busy = false
            ..step = solidify ? 4 : 6;
        });
      });
    } else {
      _setBusy(false);
    }
  }

  /// HTML `triggerMainAction()` ('Finish Observation'): the summary. Once
  /// done, the button re-opens it.
  void _finish() {
    final s = _scene;
    if (s.busy || (!s.done && s.step != s.finishStep)) return;
    setState(() => s.done = true);
    _conclude(s.scenario);
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `onSeasonSliderMove(val)`: temperature, sky, sun and snow follow
  /// the slider; the top (winter) ends step 2, the bottom (summer) step 4.
  void _onSeason(double value) {
    final s = _scene;
    if (!_seasonEnabled) return;
    s.season = value / 100;
    _seasonValue.value = value;
    if (s.step == 2 && value >= 100) {
      setState(() => s.step = 3);
    } else if (s.step == 4 && value <= 0) {
      setState(() => s.step = 5);
    }
  }

  /// Added: letting go of the slider before the end says how far to go
  /// (the HTML waited silently).
  void _onSeasonEnd(double value) {
    final s = _scene;
    if (s.scenario != 1 || s.busy || s.done) return;
    if (s.step == 2 && value < 100) {
      _toast('e_slide_winter', error: true, sound: true);
    } else if (s.step == 4 && value > 0) {
      _toast('e_slide_summer', error: true, sound: true);
    }
  }

  /// HTML `season-slider.disabled`: it moves only in steps 2 and 4.
  bool get _seasonEnabled {
    final s = _scene;
    return _lab.isLabActive &&
        s.scenario == 1 &&
        !s.busy &&
        !s.done &&
        (s.step == 2 || s.step == 4);
  }

  // -------------------------------------------------------------- gestures

  /// Screen rectangle around the projected corners of the box centred at
  /// [c] with half sizes [h].
  Rect _boxRect(_Cam cam, _V c, _V h) {
    Rect? rect;
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final o = cam.p(c + _V(sx * h.x, sy * h.y, sz * h.z));
          final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
          rect = rect == null ? r : rect.expandToInclude(r);
        }
      }
    }
    return rect!;
  }

  /// The glass (HTML: a hit on its meshes or within 80 px of its centre),
  /// at least a 48 dp target.
  Rect _glassRect() {
    final p = _scene.glassPos;
    final box = _boxRect(
      _camKitchen,
      p,
      const _V(_glassTopR, _glassHalf, _glassTopR),
    );
    return box.expandToInclude(
      Rect.fromCircle(center: _camKitchen.p(p), radius: _touch),
    );
  }

  /// The freezer door at its current angle.
  Rect _doorRect() {
    final yaw = _scene.doorAngle;
    Rect? rect;
    for (final x in const [0.0, 10.0]) {
      for (final y in const [-3.9, 3.9]) {
        for (final z in const [0.0, 1.2]) {
          final o = _camKitchen.p(_doorPivot + _yawed(_V(x, y, z), yaw));
          final r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
          rect = rect == null ? r : rect.expandToInclude(r);
        }
      }
    }
    return rect!;
  }

  /// The refrigerator and the counter (for the "open the door first" hint).
  Rect _fridgeRect() => _boxRect(
    _camKitchen,
    _fridgeAt + const _V(0, 10, -1.4),
    const _V(5, 10, 5.6),
  );

  Rect _counterRect() => _boxRect(
    _camKitchen,
    _counterAt + const _V(0, 2.25, 0),
    const _V(8.5, 2.25, 6.5),
  );

  /// HTML `pointerdown`: only the glass can be held, and only when the
  /// step lets it move.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || !_scene.canDragGlass || _scene.held) return false;
    return _glassRect().contains(event.localPosition);
  }

  /// HTML `startDrag`: the drag plane faces the camera through the glass;
  /// the grab offset keeps the glass under the finger.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    if (!s.canDragGlass || !_glassRect().contains(d.localPosition)) return;
    final pos = s.glassPos;
    final hit = _camKitchen.onPlane(d.localPosition, pos);
    _planePoint = pos;
    _grabOffset = hit == null ? _V.zero : hit - pos;
    _moved = false;
    _Sound.click.play();
    setState(() => s.held = true);
  }

  void _onDragStart(DragStartDetails d) {
    if (_scene.held) _moved = true;
  }

  /// HTML `pointermove`: the glass follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (!s.held) return;
    final hit = _camKitchen.onPlane(d.localPosition, _planePoint);
    if (hit == null) return;
    final p = hit - _grabOffset;
    s.glass = _Move.still(
      _V(p.x.clamp(_dragMinX, _dragMaxX), p.y.clamp(_dragMinY, _dragMaxY), p.z),
    );
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `pointerup` → `checkDrop()`; a mere tap leaves the glass alone.
  void _release() {
    final s = _scene;
    if (!s.held) return;
    setState(() => s.held = false);
    if (!_moved) return;
    _moved = false;
    _checkDrop();
  }

  /// HTML `checkDrop()`, with the drop zones of the freezer and the counter.
  void _checkDrop() {
    final s = _scene;
    final p = s.glassPos;
    if (s.step == 1) {
      final inside =
          p.x >= _freezerMinX &&
          p.x <= _freezerMaxX &&
          p.y >= _freezerMinY &&
          p.y <= _freezerMaxY;
      if (inside) {
        _placeInFreezer(p);
      } else {
        _revert(p, _glassHome, 'e_drop_freezer');
      }
    } else if (s.step == 3) {
      final onCounter =
          p.x >= _counterMinX &&
          p.x <= _counterMaxX &&
          p.y >= _counterMinY &&
          p.y <= _counterMaxY;
      if (onCounter) {
        _placeOnCounter(p);
      } else {
        _revert(p, _glassInFreezer, 'e_drop_counter');
      }
    }
  }

  /// Taps: the shut freezer door opens (step 3). A tap elsewhere on the
  /// refrigerator or the counter while it is shut says to open it; a tap on
  /// the glass while it has to be dragged repeats the task. The HTML
  /// ignored those taps.
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.scenario != 0 || s.busy || s.held || s.done) {
      return;
    }
    final at = d.localPosition;
    if (s.step == 3 && !s.doorOpen) {
      if (_doorRect().contains(at)) {
        _openDoor();
      } else if (_fridgeRect().contains(at) || _counterRect().contains(at)) {
        _toast('e_open_door', error: true, sound: true);
      }
      return;
    }
    if (s.canDragGlass && _glassRect().contains(at)) _toast(_hudKey);
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#btn-action-timelapse` and `#btn-action-main`.
  List<LabAction> _actions() {
    final s = _scene;
    final timeLapse =
        !s.done &&
        !s.busy &&
        (s.scenario == 0
            ? (s.step == 2 || s.step == 4)
            : (s.step == 3 || s.step == 5));
    final finish = s.done || (!s.busy && s.step == s.finishStep);
    return [
      if (timeLapse)
        LabAction(
          label: _t('btn_timelapse'),
          icon: Icons.fast_forward,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: _timeLapse,
        ),
      if (finish)
        LabAction(
          label: _t('btn_finish'),
          icon: Icons.task_alt,
          color: _Colors.emerald500,
          foreground: _Colors.white,
          highlight: !s.done,
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
        final p = _lab.palette;
        final f = context.labScale * _lab.fontScale;
        final data = _scenarioData;
        final s = _scene;
        // Scenario 2's sixth HTML step ("Observation Complete! Click
        // 'Finish'.") is not in its step list; it is shown as the current
        // objective.
        final pastSteps = !s.done && s.step > data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.ac_unit,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          instruction: pastSteps ? _t(_hudKey) : null,
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
          overlays: _overlays(context, p),
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#thermometer-overlay` (both scenarios) and
  /// `#season-slider-overlay` (Scenario 2): cards at the top right of the
  /// canvas, below the toast band and left of the tool column, above the
  /// HUD band. The Season Controller sits beside the thermometer (the HTML
  /// stacked it below, which does not fit a phone's height).
  List<Widget> _overlays(BuildContext context, LabPalette p) {
    if (!_lab.isLabActive) return const [];
    final s = context.labScale;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final height = MediaQuery.sizeOf(context).height;
    final top = _cardTop + pad.top;
    final band = _lab.isSidebarOpen ? _hudBand : inset.bottom;
    final column = (height - top - band - pad.bottom - _cardChrome * s)
        .clamp(_columnMin, math.max(_columnMin, _columnMax * s))
        .toDouble();
    final width = math.max(_cardMinWidth, _cardWidth * s);
    return [
      Positioned(
        key: const ValueKey('ch8a4-thermometer'),
        top: top,
        right: inset.right,
        child: _ThermoCard(
          palette: p,
          scale: s,
          width: width,
          column: column,
          label: _t('temp'),
          unit: _t('unit_c'),
          temperature: _tempShown,
          scene: _scene,
          frame: _frame,
        ),
      ),
      if (_scene.scenario == 1)
        Positioned(
          key: const ValueKey('ch8a4-season'),
          top: top,
          right: inset.right + width + _cardGap,
          child: _SeasonCard(
            palette: p,
            scale: s,
            width: width,
            column: column,
            label: _t('season_ctrl'),
            winter: _t('winter'),
            summer: _t('summer'),
            value: _seasonValue,
            enabled: _seasonEnabled,
            onChanged: _onSeason,
            onChangeEnd: _onSeasonEnd,
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
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / fit;
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          _labelRight = math.min(
            _design.width,
            (box.maxWidth - tools - stageLeft) / fit,
          );
        }
        final shift = !_lab.isSidebarOpen && _scene.scenario == 1
            ? _roomShift
            : 0.0;
        return LabStage(
          designSize: _design,
          // The slide moves the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(shift / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
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

/// HTML `#thermometer-overlay`: "Temperature", the tube with its liquid
/// and the reading.
class _ThermoCard extends StatelessWidget {
  const _ThermoCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.column,
    required this.label,
    required this.unit,
    required this.temperature,
    required this.scene,
    required this.frame,
  });

  final LabPalette palette;
  final double scale;
  final double width;

  /// Height of the tube (dp).
  final double column;
  final String label;

  /// `{v}°C`.
  final String unit;
  final ValueListenable<int> temperature;
  final _Scene scene;
  final Listenable frame;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    return LabGlassCard(
      palette: p,
      radius: 14,
      padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 7 * s),
      child: SizedBox(
        width: width - 8 * s,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: labLetterSpacing(label, 0.8),
                ),
              ),
            ),
            SizedBox(height: 6 * s),
            SizedBox(
              width: 24 * s,
              height: column,
              child: CustomPaint(
                painter: _ThermoPainter(
                  scene: scene,
                  palette: p,
                  repaint: frame,
                ),
              ),
            ),
            SizedBox(height: 5 * s),
            ValueListenableBuilder<int>(
              valueListenable: temperature,
              builder: (context, v, _) => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labFormat(unit, {'v': v}),
                  maxLines: 1,
                  style: TextStyle(
                    color: _Colors.blue500,
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w900,
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

/// HTML `#season-slider-overlay`: a vertical slider, winter (snowflake) at
/// the top, summer (sun) at the bottom.
class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.column,
    required this.label,
    required this.winter,
    required this.summer,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final LabPalette palette;
  final double scale;
  final double width;

  /// Length of the slider track (dp).
  final double column;
  final String label;
  final String winter;
  final String summer;

  /// 0 (summer) … 100 (winter), HTML `<input type="range" min="0" max="100">`.
  final ValueListenable<double> value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    final inner = width - 4 * s;
    final small = TextStyle(
      color: p.text,
      fontSize: 8.5 * s,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    Widget caption(String text) => SizedBox(
      width: inner,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, style: small),
      ),
    );
    // HTML: the overlay stays fully visible while the slider is disabled;
    // only the slider shows that it is locked.
    return LabGlassCard(
      palette: p,
      radius: 14,
      padding: EdgeInsets.symmetric(horizontal: 2 * s, vertical: 7 * s),
      child: SizedBox(
        width: inner,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 9 * s,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 4 * s),
            Icon(Icons.ac_unit, size: 18 * s, color: _Colors.blue400),
            caption(winter),
            Semantics(
              label: label,
              child: SizedBox(
                key: const ValueKey('ch8a4-season-slider'),
                width: inner,
                height: column,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6 * s,
                      activeTrackColor: _Colors.blue500,
                      inactiveTrackColor: p.isDark
                          ? _Colors.slate700
                          : _Colors.slate300,
                      thumbColor: _Colors.blue500,
                      disabledActiveTrackColor: _Colors.blue500.withValues(
                        alpha: 0.6,
                      ),
                      disabledInactiveTrackColor: p.isDark
                          ? _Colors.slate700
                          : _Colors.slate300,
                      disabledThumbColor: _Colors.blue400,
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 16 * s,
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
                        value: v,
                        max: 100,
                        divisions: 100,
                        onChanged: enabled ? onChanged : null,
                        onChangeEnd: onChangeEnd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            caption(summer),
            Icon(Icons.wb_sunny, size: 18 * s, color: _Colors.yellow500),
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
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the static parts of each
/// scene and the label text painters. Owned by the page state and disposed
/// with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;
  ui.Picture? _room;

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

  /// What lies behind everything that moves: Scenario 1 the background, the
  /// counter and the refrigerator; Scenario 2 the background only (the
  /// sky behind the window changes with the season).
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
    canvas.drawRect(
      labBleed(size),
      pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
    );
    if (scenario == 0) _paintKitchenBackdrop(canvas, pens);
    _backdropScenario = scenario;
    _backdropDark = dark;
    return _backdrop = recorder.endRecording();
  }

  /// Scenario 2's walls, window frame and table, drawn over the sky.
  ui.Picture room() {
    final cached = _room;
    if (cached != null) return cached;
    final recorder = ui.PictureRecorder();
    _paintRoomFront(Canvas(recorder), pens);
    return _room = recorder.endRecording();
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
    _room?.dispose();
    _room = null;
  }
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
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// [v] turned by [yaw] about the y axis (Three.js `rotation.y`).
_V _yawed(_V v, double yaw) {
  if (yaw == 0) return v;
  final c = math.cos(yaw), s = math.sin(yaw);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

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

/// Segments of rims and discs (smooth enough at this size).
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

  /// Filled polygon through the projected [pts] (MeshBasicMaterial: not
  /// lit).
  void poly(List<_V> pts, Color color) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// BoxGeometry centred at [c], turned by [yaw]: the faces seen by the
  /// camera, lit; [edge] darkens (or [edgeColor] colours) the rims
  /// (HTML `addEdge`).
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
    double yaw = 0,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final f = face.normal;
      final n = _yawed(f, yaw);
      final mid = c + _yawed(_V(f.x * hx, f.y * hy, f.z * hz), yaw);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _yawed(_V(k.x * hx, k.y * hy, k.z * hz), yaw)));
      }
      path.close();
      final fill = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = fill);
      final rim =
          edgeColor ??
          (edge > 0
              ? labShade(color, -0.5).withValues(alpha: edge * opacity)
              : null);
      if (rim != null) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = rim,
        );
      } else if (opacity >= 1) {
        canvas.drawPath(path, pens.seam..color = fill);
      }
    }
  }

  /// Cross-section direction at [a] radians in the frame ([ex], [ez]).
  static _V _dir(_V ex, _V ez, double a) => ex * math.cos(a) + ez * math.sin(a);

  /// Upright CylinderGeometry: radius [r0] at [base], [r1] at the top,
  /// [h] high. The facets turned to the camera are lit one by one; the top
  /// is closed when it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    double opacity = 1,
    bool cap = true,
    int sides = 24,
  }) {
    if (h <= 0) return;
    final top = base + _V.up * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(_V.right, _V.front, (a0 + a1) / 2);
      final n = (m + _V.up * slope).unit;
      final mid = base + _V.up * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final d0 = _dir(_V.right, _V.front, a0);
      final d1 = _dir(_V.right, _V.front, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = c);
      if (opacity >= 1) canvas.drawPath(path, pens.seam..color = c);
    }
    if (cap && _V.up.dot(_eyeAt - top) > 0) {
      disc(top, r1, _lit(color, _V.up, opacity: opacity));
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

  /// Rim of a cylinder end: the ring of radius [r] at [c].
  List<Offset> _rim(_V c, double r) => [
    for (var i = 0; i < _ringSides; i++)
      cam.p(c + _dir(_V.right, _V.front, i * 2 * math.pi / _ringSides) * r),
  ];

  /// Clear glass (`glassMat`, opacity 0.25), back part: the faint body and
  /// the far halves of its rims. Draw the contents next and [glassFront]
  /// last.
  void glassBack(
    _V base,
    double r0,
    double r1,
    double h, {
    Color tint = _Colors.glass,
    double body = 0.08,
  }) {
    final top = base + _V.up * h;
    final hull = _hull([..._rim(base, r0), ..._rim(top, r1)]);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = tint.withValues(alpha: body));
    _halfRim(base, r0, near: false, alpha: 0.25, tint: tint);
    _halfRim(top, r1, near: false, alpha: 0.35, tint: tint);
  }

  /// Clear glass, front part: the near rims, the silhouette edges and a
  /// highlight stripe.
  void glassFront(
    _V base,
    double r0,
    double r1,
    double h, {
    Color tint = _Colors.glass,
  }) {
    final top = base + _V.up * h;
    _halfRim(base, r0, near: true, alpha: 0.45, tint: tint);
    _halfRim(top, r1, near: true, alpha: 0.6, tint: tint);
    // Silhouette lines where the side turns away from the camera.
    final v = _eyeAt - (base + _V.up * (h / 2));
    final a = math.atan2(-v.x, v.z);
    final edge = pens.stroke
      ..strokeWidth = 1.2
      ..color = tint.withValues(alpha: 0.45);
    for (final s in [a, a + math.pi]) {
      final d = _dir(_V.right, _V.front, s);
      canvas.drawLine(cam.p(base + d * r0), cam.p(top + d * r1), edge);
    }
    // Highlight towards the key light.
    final hl = _dir(_V.right, _V.front, a + math.pi * 0.72);
    canvas.drawLine(
      cam.p(base + _V.up * (h * 0.12) + hl * (r0 * 0.8)),
      cam.p(base + _V.up * (h * 0.88) + hl * (r1 * 0.8)),
      pens.limb
        ..strokeWidth = math.max(1.5, 0.12 * cam.scaleAt(base))
        ..color = tint.withValues(alpha: 0.3),
    );
  }

  /// The near or far half of a rim (seen from the camera).
  void _halfRim(
    _V c,
    double r, {
    required bool near,
    required double alpha,
    required Color tint,
  }) {
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
        ..color = tint.withValues(alpha: alpha),
    );
  }
}

/// Scenario 1's static kitchen: the counter (`counterGrp`) and the
/// refrigerator (`fridgeGroup`) with its hollow freezer, shelf and lower
/// door. The freezer door and the glass are drawn every frame.
void _paintKitchenBackdrop(Canvas canvas, _Pens pens) {
  final g = _Gfx(canvas, _camKitchen, pens);
  const edge = _Colors.fridgeEdge;
  // Counter: wood base 16 × 4 × 12, dark slate top 17 × 0.5 × 13.
  g.box(_counterAt + const _V(0, 2, 0), const _V(16, 4, 12), _Colors.wood);
  g.box(
    _counterAt + const _V(0, 4.25, 0),
    const _V(17, 0.5, 13),
    _Colors.counterTop,
  );
  // Lower body 10 × 12 × 10.
  g.box(
    _fridgeAt + const _V(0, 6, 0),
    const _V(10, 12, 10),
    _Colors.fridge,
    edgeColor: edge,
  );
  // Freezer, far to near: back wall, the inner back panel with the
  // freezer light's glow, right wall, bottom, shelf, top, left wall.
  const fz = _freezerAt;
  g.box(
    fz + const _V(0, 0, -4.75),
    const _V(9, 7, 0.5),
    _Colors.fridge,
    edgeColor: edge,
  );
  g.box(fz + const _V(0, 0, -4.4), const _V(8.9, 6.9, 0.2), _Colors.cavity);
  g.poly([
    fz + const _V(-4.45, -3.45, -4.29),
    fz + const _V(4.45, -3.45, -4.29),
    fz + const _V(4.45, 3.45, -4.29),
    fz + const _V(-4.45, 3.45, -4.29),
  ], _Colors.freezerLight);
  g.box(
    fz + const _V(4.75, 0, 0),
    const _V(0.5, 8, 10),
    _Colors.fridge,
    edgeColor: edge,
  );
  g.box(
    fz + const _V(0, -3.75, 0),
    const _V(9, 0.5, 10),
    _Colors.fridge,
    edgeColor: edge,
  );
  g.box(
    _fridgeAt + const _V(0, 13.5, 0.5),
    const _V(8.9, 0.2, 9),
    _Colors.freezerShelf,
  );
  g.box(
    fz + const _V(0, 3.75, 0),
    const _V(9, 0.5, 10),
    _Colors.fridge,
    edgeColor: edge,
  );
  g.box(
    fz + const _V(-4.75, 0, 0),
    const _V(0.5, 8, 10),
    _Colors.fridge,
    edgeColor: edge,
  );
  // Lower door 10 × 11.8 × 1 and its handle (radius 0.2, 5 long).
  g.box(
    _fridgeAt + const _V(0, 6, 5.5),
    const _V(10, 11.8, 1),
    _Colors.fridge,
    edgeColor: edge,
  );
  g.cylinder(_fridgeAt + const _V(4, 3.5, 6.2), 0.2, 0.2, 5, _Colors.handle);
}

/// Scenario 2's room in front of the sky: the walls round the window
/// (0x475569), the window frame (0x94a3b8) and the wooden table.
void _paintRoomFront(Canvas canvas, _Pens pens) {
  final g = _Gfx(canvas, _camRoom, pens);
  for (final (c, size) in const [
    (_V(0, 30, -10.1), _V(60, 20, 1)),
    (_V(0, -1, -10.1), _V(60, 10, 1)),
    (_V(-22, 12, -10.1), _V(20, 16, 1)),
    (_V(22, 12, -10.1), _V(20, 16, 1)),
  ]) {
    g.box(c, size, _Colors.roomWall, edge: 0.2);
  }
  for (final (c, size) in const [
    (_V(0, 20.5, -10), _V(25, 1, 1.2)),
    (_V(0, 3.5, -10), _V(25, 1, 1.2)),
    (_V(-12.5, 12, -10), _V(1, 18, 1.2)),
    (_V(12.5, 12, -10), _V(1, 18, 1.2)),
  ]) {
    g.box(c, size, _Colors.windowFrame);
  }
  g.box(const _V(0, 1, 0), const _V(40, 2, 15), _Colors.wood);
}

/// Paints the HTML Three.js scene of the current scenario: S1 the kitchen
/// with the glass and the freezer door, S2 the room with the window, the
/// snow and the jar of coconut oil.
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
      _paintKitchen(canvas);
    } else {
      _paintRoom(canvas);
    }
  }

  /// HTML highlight strength now (0 … 0.5).
  double get _pulse =>
      (math.sin(scene.time * _pulseRate) + 1) / 2 * _pulseStrength;

  // ---------------------------------------------------------- scenario 1

  void _paintKitchen(Canvas canvas) {
    final g = _Gfx(canvas, _camKitchen, _pens);
    final s = scene;
    final glass = s.glassPos;
    final glow = s.glassPulse ? _pulse : 0.0;
    // Inside the freezer the glass is drawn before the door, which shuts
    // over it; anywhere else (and while held) after it.
    final inside = s.inFreezer && !s.held;
    final onCounter =
        !s.inFreezer &&
        !s.held &&
        (glass.y - _glassOnCounter.y).abs() < 0.01 &&
        glass.x < _counterMaxX;
    if (onCounter) {
      g.shadow(glass.x - 0.4, glass.z - 0.4, 2.4, 2.2, y: _counterTopY);
    }
    if (inside) _paintGlass(g, glass, glow);
    _paintDoor(g);
    if (!inside) _paintGlass(g, glass, glow);

    if (!showLabels) return;
    _chip(
      canvas,
      _camKitchen.p(_freezerAt + const _V(0, 5, 0)),
      _t('lbl_freezer'),
    );
    _chip(
      canvas,
      _camKitchen.p(glass + const _V(0, -_glassLabelDrop, 0)),
      _t(s.frozen ? 'lbl_glass_ice' : 'lbl_glass_water'),
    );
  }

  /// `glassS1`: the tumbler (`CylinderGeometry(2.5, 2.0, 6)`, open, with a
  /// 0.3 base), the water (`CylinderGeometry(2.3, 1.95, 4.5)`) and the ice
  /// cube (2.8 × 4 × 2.8, shrinking to (0.8, 0.1, 0.8) as it melts). [glow]
  /// is the HTML highlight pulse.
  void _paintGlass(_Gfx g, _V p, double glow) {
    final s = scene;
    final base = p - const _V(0, _glassHalf, 0);
    final tint = glow > 0
        ? Color.lerp(_Colors.glass, _Colors.highlight, glow * 2)!
        : _Colors.glass;
    g.glassBack(
      base,
      _glassBottomR,
      _glassTopR,
      2 * _glassHalf,
      tint: tint,
      body: 0.08 + 0.3 * glow,
    );
    g.cylinder(base, 2, 2, 0.3, _Colors.glass, opacity: 0.35);
    final water = s.waterOpacity;
    if (water > 0.01) {
      g.cylinder(
        p + const _V(0, -2.7, 0),
        1.95,
        2.3,
        4.5,
        _Colors.water,
        opacity: water,
      );
    }
    final ice = s.iceOpacity;
    if (ice > 0.01) {
      final m = s.melt.at(s.time);
      final w = 1 - _meltWidth * m;
      g.box(
        p + const _V(0, -0.7, 0),
        _V(2.8 * w, 4 * (1 - _meltHeight * m), 2.8 * w),
        _Colors.ice,
        opacity: ice,
        edgeColor: _Colors.white.withValues(alpha: 0.8 * ice),
      );
    }
    g.glassFront(base, _glassBottomR, _glassTopR, 2 * _glassHalf, tint: tint);
  }

  /// The freezer door (`freezerDoor` 10 × 7.8 × 1, its gasket and handle)
  /// turned about its hinge. Seen from inside once it swings open; pulsing
  /// while it has to be tapped; see-through during the freezer time-lapse.
  void _paintDoor(_Gfx g) {
    final s = scene;
    final yaw = s.doorAngle;
    final alpha = 1 - (1 - _xrayMinAlpha) * s.xray.at(s.time);
    final glow = s.doorPulse ? _pulse : 0.0;
    final color = glow > 0
        ? Color.lerp(_Colors.fridge, _Colors.highlight, glow)!
        : _Colors.fridge;
    _V at(_V local) => _doorPivot + _yawed(local, yaw);
    final inner = _yawed(const _V(0, 0, -1), yaw);
    final insideSeen = inner.dot(_eye - at(const _V(5, 0, 0))) > 0;
    void handle() => g.cylinder(
      at(const _V(9, -1.5, 1.2)),
      0.2,
      0.2,
      3,
      _Colors.handle,
      opacity: alpha,
    );
    void gasket() => g.box(
      at(const _V(5, 0, -0.05)),
      const _V(9.6, 7.4, 0.2),
      _Colors.gasket,
      yaw: yaw,
      opacity: alpha,
    );
    void panel() => g.box(
      at(const _V(5, 0, 0.5)),
      const _V(10, 7.8, 1),
      color,
      yaw: yaw,
      opacity: alpha,
      edgeColor: _Colors.fridgeEdge.withValues(alpha: 0.5 * alpha),
    );
    if (insideSeen) {
      handle();
      panel();
      gasket();
    } else {
      gasket();
      panel();
      handle();
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintRoom(Canvas canvas) {
    final g = _Gfx(canvas, _camRoom, _pens);
    final s = scene;
    final v = s.season;
    // Sky behind the window: `PlaneGeometry(28, 18)` at (0, 12, -11.5),
    // summer blue → winter grey.
    g.poly(const [
      _V(-14, 3, -11.5),
      _V(14, 3, -11.5),
      _V(14, 21, -11.5),
      _V(-14, 21, -11.5),
    ], Color.lerp(_Colors.skySummer, _Colors.skyWinter, v)!);
    // Sun `CircleGeometry(2)` at (-8, 16, -11), fading out with winter.
    if (v < 1) {
      g.disc(
        const _V(-8, 16, -11),
        2,
        _Colors.sun.withValues(alpha: 1 - v),
        _V.right,
        _V.up,
      );
    }
    // Snow, past half way to winter: opacity (v - 0.5) × 2 × 0.8.
    if (s.snowing) {
      final paint = _pens.fill
        ..color = _Colors.snow.withValues(alpha: (v - 0.5) * 2 * _flakeAlpha);
      for (final f in s.flakes) {
        final w = _snowAt + _V(f.x, f.y, 0);
        g.canvas.drawCircle(
          _camRoom.p(w),
          math.max(1.2, _flakeRadius * _camRoom.scaleAt(w)),
          paint,
        );
      }
    }
    canvas.drawPicture(cache.room());
    _paintJar(g);
    if (!showLabels) return;
    _chip(
      canvas,
      _camRoom.p(_jarAt + const _V(0, _jarLabelRise, 0)),
      _t('lbl_jar_oil'),
    );
  }

  /// `jarS2`: glass body `CylinderGeometry(3, 3, 6)` with a 0.3 base, the
  /// coconut oil (`CylinderGeometry(2.9, 2.9, 4.5)`, liquid 0xfef08a at
  /// 0.7 cross-fading to solid white), the neck (3 → 2.5, 1 high) and the
  /// metal lid (radius 2.6, 0.5 high).
  void _paintJar(_Gfx g) {
    final s = scene;
    const j = _jarAt;
    g.shadow(j.x - 0.5, j.z - 0.5, 3.4, 3.2, y: 2);
    final body = j + const _V(0, -3, 0);
    g.glassBack(body, 3, 3, 6);
    g.cylinder(body, 3, 3, 0.3, _Colors.glass, opacity: 0.35);
    final solid = s.oilSolid;
    final oilBase = j + const _V(0, -2.85, 0);
    if (solid < 0.99) {
      g.cylinder(
        oilBase,
        2.9,
        2.9,
        4.5,
        _Colors.oilLiquid,
        opacity: _waterAlpha * (1 - solid),
      );
    }
    if (solid > 0.01) {
      g.cylinder(oilBase, 2.9, 2.9, 4.5, _Colors.oilSolid, opacity: solid);
    }
    g.glassFront(body, 3, 3, 6);
    final neck = j + const _V(0, 3, 0);
    g.glassBack(neck, 3, 2.5, 1);
    g.glassFront(neck, 3, 2.5, 1);
    g.cylinder(j + const _V(0, 4, 0), 2.6, 2.6, 0.5, _Colors.lid);
  }

  // ------------------------------------------------------------ labels

  /// HTML `.label-3d`: a rounded glass chip with a blue-400 border and white
  /// bold text centred on [at], kept left of the tool column.
  void _chip(Canvas canvas, Offset at, String text) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.7, padY = size * 0.35;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final minX = w / 2 + 4;
    final cx = at.dx
        .clamp(minX, math.max(minX, labelRight - w / 2 - 4))
        .toDouble();
    final rect = Rect.fromCenter(
      center: Offset(cx, at.dy),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.labelBg);
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1
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

/// HTML thermometer tube: a rounded tube (slate, 2 px border) with the
/// liquid rising from the bottom, red above 0 °C and blue at or below it,
/// and a tick every 10 °C (the longer one at 0 °C).
class _ThermoPainter extends CustomPainter {
  _ThermoPainter({
    required this.scene,
    required this.palette,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _Scene scene;
  final LabPalette palette;
  final Paint _fill = Paint();
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// Tube border width and the inner padding (HTML `border-2 p-0.5 pb-1`).
  static const double _border = 2;
  static const double _pad = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width / 2),
    );
    canvas.drawRRect(
      tube,
      _fill..color = palette.isDark ? _Colors.slate800 : _Colors.slate200,
    );
    final inner = Rect.fromLTRB(
      _pad,
      _pad,
      size.width - _pad,
      size.height - _pad - 1,
    );
    // Ticks every 10 °C on both sides.
    _line
      ..strokeWidth = 1
      ..color = _Colors.slate400.withValues(alpha: 0.8);
    for (var t = _thermoMin; t <= _thermoMin + _thermoRange; t += 10) {
      final y = inner.bottom - inner.height * (t - _thermoMin) / _thermoRange;
      final len = t == 0 ? size.width * 0.32 : size.width * 0.18;
      canvas.drawLine(Offset(_border, y), Offset(_border + len, y), _line);
      canvas.drawLine(
        Offset(size.width - _border, y),
        Offset(size.width - _border - len, y),
        _line,
      );
    }
    final h = inner.height * scene.column;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(inner.left, inner.bottom - h, inner.right, inner.bottom),
        Radius.circular(inner.width / 2),
      ),
      _fill
        ..color = Color.lerp(
          _Colors.thermoHot,
          _Colors.thermoCold,
          scene.cold,
        )!,
    );
    canvas.drawRRect(
      tube,
      _line
        ..strokeWidth = _border
        ..color = _Colors.slate400,
    );
  }

  @override
  bool shouldRepaint(covariant _ThermoPainter old) =>
      old.scene != scene || old.palette != palette;
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
