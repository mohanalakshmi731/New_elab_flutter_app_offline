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

/// Class 6 Science • Chapter 5 • Activity 2
/// Standard Units of Length (SI Units) and Conversions.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A2-Standard_Units_of_Length__SI_Units__and_Conversions.html`.
///
/// Scenario 1 (The Tailor's Shop): a customer wants 2 m of cloth. Drag two
/// 1 m metal rods from the toolbox onto the fabric (a chalk mark appears at
/// 1 m and at 2 m), drag the scissors to the 2 m mark to cut the piece off
/// the roll, then break each rod into 100 centimetre cubes: 2 m = 200 cm.
///
/// Scenario 2 (Road Trip and Coin Scale): a laser Metre-Counter counts the
/// metres along a 1 km highway (1 km = 1000 m); on a 15 cm ruler a coin is
/// 2 mm thick and a stack of five coins reaches the 1 cm mark (10 mm = 1 cm).
class Ch5A2StandardUnitsOfLengthSiUnitsAndConversionsPage
    extends StatefulWidget {
  const Ch5A2StandardUnitsOfLengthSiUnitsAndConversionsPage({super.key});

  @override
  State<Ch5A2StandardUnitsOfLengthSiUnitsAndConversionsPage> createState() =>
      _SiUnitsLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises four sounds with WebAudio; each
/// maps to the closest bundled tone: `pop` → pop, `stamp` (a low thud on
/// every step) → drop, `cut` (a short rising buzz) → click, `success` →
/// success. Correct / wrong (feedback toasts) and pickup (an object is
/// grabbed) are Dart additions.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// stamp → `science/drop.mp3`, cut → `science/click.mp3`,
/// success → `math/success.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, pickup → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`: buttons, sidebar, scenario change, curtain.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('stamp')`: every completed step.
  stamp('audio/class6/science/drop.mp3'),

  /// HTML `playSound('cut')`: the scissors cut the cloth.
  cut('audio/class6/science/click.mp3'),

  /// HTML `playSound('success')`: centimetre cubes complete, 1000 m
  /// counted, coin stack, conclusion popup.
  success('audio/class6/math/success.mp3'),

  /// Feedback toast (shell).
  correct('audio/class6/science/correct.mp3'),

  /// A rod or the scissors dropped in the wrong place.
  wrong('audio/class6/science/error.mp3'),

  /// A rod or the scissors picked up from the toolbox.
  pickup('audio/class6/science/pickup.mp3');

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
  /// ZSL yellow (`zsl.yellow`): brand, labels, toast text, cm cubes.
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color yellow700 = Color(0xFFA16207);
  static const Color yellow200 = Color(0xFFFEF08A); // chalk, cubes, ruler
  static const Color yellow400 = Color(0xFFFACC15); // road centre dashes
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color yellow800 = Color(0xFF854D0E); // tailor table
  static const Color amber950 = Color(0xFF451A03); // table legs
  static const Color red800 = Color(0xFF991B1B); // toolbox
  static const Color orange500 = Color(0xFFF97316); // scissors handles
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // rod glow, counter
  static const Color blue600 = Color(0xFF2563EB); // fabric, 1 cm tick
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5); // popup buttons
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color sky500 = Color(0xFF0EA5E9); // Metre-Counter body
  static const Color laser = Color(0xFF00FFFF); // lens and laser pulse
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // 2 mm glow, conclude
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D); // terrain
  static const Color green800 = Color(0xFF166534); // highway sign
  static const Color red500 = Color(0xFFEF4444);
  static const Color slate50 = Color(0xFFF8FAFC); // road markings
  static const Color slate100 = Color(0xFFF1F5F9); // scissor blades
  static const Color slate200 = Color(0xFFE2E8F0); // rods, coins
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8); // sign pole
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569); // desk, mm ticks
  static const Color slate700 = Color(0xFF334155); // counter base
  static const Color slate800 = Color(0xFF1E293B); // road asphalt
  static const Color slate900 = Color(0xFF0F172A); // cm ticks
  static const Color slate950 = Color(0xFF020617); // scene background
  static const Color white = Color(0xFFFFFFFF);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xE60F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Scene label chips and the toast (`bg-slate-950/90`, `/80`).
  static const Color chipBg = Color(0xE6020617);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The 3D scene background follows the theme like the HTML
/// `setTheme()` (#020617 dark, #e2e8f0 light).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.chipBg,
    toastText: _Colors.zslYellow,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x263B82F6), // rgba(59,130,246,0.15)
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.blue400,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.zslYellow,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.glassDark,
    readoutBorder: Color(0x663B82F6), // border-blue-500/40
    readoutIcon: _Colors.blue400,
    labelBg: _Colors.chipBg,
    labelText: _Colors.zslYellow,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate200,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // completed steps (text-green-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.chipBg,
    toastText: _Colors.zslYellow,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x263B82F6),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.blue400,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.yellow700,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.glassLight,
    readoutBorder: Color(0x663B82F6),
    readoutIcon: _Colors.blue600,
    labelBg: _Colors.chipBg,
    labelText: _Colors.zslYellow,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font-size slider (13–21 px, default 15 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 13,
  maxSize: 21,
);

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays `pop` for buttons, the sidebar, scenario changes and the curtain.
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.pop,
  curtain: _Sound.pop,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// From the HTML `i18n` / `ScenariosData` tables (Telugu dropped). The HTML
// toasts are English only; their Hindi is new. Changes from the HTML:
// - Every step `action` names exactly what to drag or click (the HTML lists
//   what happens, e.g. "Lay down 1m metallic rod on cloth roll.").
// - The tailor measures from the cloth's free (right) end and cuts at the
//   2 m mark next to the roll; the HTML cut at the free end, where there is
//   no cloth left to separate.
// - "Add cm Blocks (+10cm)" adds 100 cm: renamed "(+100 cm)".
// - Scenario 2 buttons drop the answers "(1000m)", "(2mm)" and "(1cm)"
//   from their labels, so the result is not stated before it is observed.
// - The Hindi HUD lines of steps 1-3 said "click"; those steps are drags.
// - New: the summary line after the last step of Scenario 2 (the HTML HUD
//   has none) and the hint to press the Conclude button.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Standard Units of Length (SI Units) and Conversions',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1': "Scenario 1: The Tailor's Shop",
    'scen_2': 'Scenario 2: Road Trip and Coin Scale',
    's1_mission':
        "To visually understand and verify the relationship between the metre (m) and the centimetre (cm) by fulfilling a customer's order for cloth.",
    's2_mission':
        'To visually understand kilometre to metre (km-m) for large travel distances and centimetre to millimetre (cm-mm) for tiny objects.',
    // Scenario 1 steps.
    's1_c1': 'Standard Metre Rod',
    's1_a1':
        "DRAG the glowing 1m metal rod out of the red toolbox and DROP it on the fabric, starting from the fabric's free (right) end.",
    's1_o1': 'A chalk mark automatically appears at exactly 1 metre.',
    's1_c2': 'Cumulative Length',
    's1_a2':
        'DRAG the glowing 2nd 1m rod out of the toolbox and DROP it end-to-end with the first rod, just past the first chalk mark.',
    's1_o2': 'The total measured length reaches exactly 2 metres.',
    's1_c3': 'Precise Detachment',
    's1_a3':
        'DRAG the glowing scissors out of the toolbox and DROP them on the 2m chalk mark to cut the fabric.',
    's1_o3': 'A clean 2-metre piece separates from the main fabric roll.',
    's1_c4': 'Unit Subdivision',
    's1_a4':
        "CLICK 'Explore 1m = 100cm' to break the first 1m rod into smaller standard units.",
    's1_o4': '1 metre rod visually breaks into 100 equal 1-centimetre cubes.',
    's1_c5': 'Centimetre Alignment',
    's1_a5':
        "CLICK 'Add cm Blocks (+100 cm)' to replace the second 1m rod with 100 more centimetre cubes.",
    's1_o5':
        '200 centimetre cubes perfectly align with the 2-metre fabric length.',
    // Scenario 1 HUD ("Current Task") lines.
    's1_hud_1':
        'Step 1: The customer wants a 2-metre cloth piece. Drag & Drop the glowing 1m Metal Rod out of the red toolbox onto the fabric.',
    's1_hud_2':
        'Step 2: You need 2 metres in total. Drag & Drop the glowing 2nd Metal Rod from the toolbox next to the first chalk mark.',
    's1_hud_3':
        'Step 3: Now cut the cloth. Drag & Drop the glowing Scissors out of the red toolbox onto the 2m chalk mark.',
    's1_hud_4':
        "Step 4: Let's see what a metre is made of! Click 'Explore 1m = 100cm' to watch the metallic scale segment into 100 tiny centimetre cubes.",
    's1_hud_5':
        "Step 5: Measure again using centimetres! Click 'Add cm Blocks' to lay down the next 100 centimetre cubes (200 in all) along the cut cloth.",
    's1_summary':
        'Investigation Summary: 2 metres is exactly equal to 200 centimetres (1 m = 100 cm).',
    's1_finish': "CLICK 'Conclude Tailor Study' to finish.",
    // Scenario 2 steps.
    's2_c1': 'Highway Corridor',
    's2_a1':
        "CLICK 'Explore 1km Highway' to explore the 1 km highway road segment.",
    's2_o1': '1 kilometre road segment prepared for measurement.',
    's2_c2': 'Deploy Counter Tool',
    's2_a2':
        "CLICK 'Deploy Metre-Counter Tool' to place the Metre-Counter at the road's starting line (0 m mark).",
    's2_o2': 'Counter initializes at 0 m ready to measure distance.',
    's2_c3': 'Kilometre to Metre',
    's2_a3':
        "CLICK 'Pulse Measure' to fire a laser pulse across the 1 km road and watch the counter.",
    's2_o3':
        'Counter rapidly counts up to exactly 1000 m. Therefore, 1 km = 1000 m.',
    's2_c4': 'Tabletop Precision Zoom',
    's2_a4':
        "CLICK 'Examine Coin on 15cm Ruler' to place the silver coin at the 0 mark of the 15 cm ruler.",
    's2_o4': 'Camera zooms in closely to reveal millimetre subdivisions.',
    's2_c5': 'Millimetre Reading',
    's2_a5':
        "CLICK 'Measure Coin Thickness' to examine the edge of the coin against the tick marks of the ruler.",
    's2_o5': 'Coin thickness aligns perfectly with the 2nd tick mark (2 mm).',
    's2_c6': 'Centimetre Conversion',
    's2_a6':
        "CLICK 'Place 5-Coin Stack' to place a stack of 5 coins (2 mm each) at the zero mark.",
    's2_o6': 'Total stack thickness equals 10 mm, aligning with the 1 cm mark!',
    // Scenario 2 HUD lines.
    's2_hud_1':
        "Step 1: You are on a road trip. A highway sign shows 1 km ahead. Click 'Explore 1km Highway' to explore.",
    's2_hud_2':
        "Step 2: Place the futuristic Metre-Counter device at the beginning of the road (0 m mark). Click 'Deploy Metre-Counter Tool'.",
    's2_hud_3':
        "Step 3: Click 'Pulse Measure' to fire a laser pulse down the highway and count the metres.",
    's2_hud_4':
        "Step 4: Now switch to tabletop view! Click 'Examine Coin on 15cm Ruler' to examine precision markings.",
    's2_hud_5':
        "Step 5: Examine the zoomed-in mm subdivisions. Click 'Measure Coin Thickness' to verify coin thickness.",
    's2_hud_6':
        "Step 6: Verify cm-to-mm conversion! Click 'Place 5-Coin Stack' to verify that 10 mm = 1 cm.",
    's2_summary':
        'Investigation Summary: 1 km = 1000 m for long distances and 1 cm = 10 mm for tiny objects.',
    's2_finish': "CLICK 'Conclude SI Study' to finish.",
    // Buttons.
    'btn_explore_m': 'Explore 1m = 100cm',
    'btn_add_cm': 'Add cm Blocks (+100 cm)',
    'btn_conclude_s1': 'Conclude Tailor Study',
    'btn_zoom_road': 'Explore 1km Highway',
    'btn_deploy': 'Deploy Metre-Counter Tool',
    'btn_pulse': 'Pulse Measure',
    'btn_place_coin': 'Examine Coin on 15cm Ruler',
    'btn_measure_mm': 'Measure Coin Thickness',
    'btn_stack': 'Place 5-Coin Stack',
    'btn_conclude_s2': 'Conclude SI Study',
    // Toasts (HTML showToast texts).
    'toast_rod1': '1 Metre Scale Placed (Chalk Mark at 1m boundary)',
    'toast_rod2': '2nd Metre Scale Placed (Chalk Mark at 2m boundary)',
    'toast_cut': 'Fabric Cut Exactly at 2m boundary!',
    'toast_explore': '1 Metre Rod Deconstructed: 1 m = exactly 100 cm blocks!',
    'toast_blocks': '2nd Metre Rod Deconstructed: 2 m = 200 cm blocks!',
    'toast_highway': 'Exploring 1km Highway Corridor',
    'toast_deploy': 'Metre-Counter Tool Deployed at 0 m Mark',
    'toast_pulse': '1 km = 1000 m Verified!',
    'toast_coin': 'Tabletop Zoomed: Examining Coin on 15cm Ruler',
    'toast_mm': 'Coin Thickness Measured: exactly 2 mm!',
    'toast_stack': '5 Coins × 2mm = 10 mm = 1 cm Verified!',
    'err_rod1': 'Drag the rod closer to the free (right) end of the fabric',
    'err_rod2': 'Drag the 2nd rod next to the first chalk mark',
    'err_scissors':
        'Drag the scissors near the 2m chalk line to cut the fabric',
    // Conclusion popups.
    'popup_s1_title': 'Success!',
    'popup_s1_heading': 'Scenario 1 Complete!',
    'popup_s1_desc': 'You have verified that 1 metre = 100 centimetres!',
    'popup_s2_title': 'Lab Mastered!',
    'popup_s2_heading': 'All Scenarios Completed!',
    'popup_s2_desc':
        'You have mastered SI Units of Length: Kilometre, Metre, Centimetre, and Millimetre!',
    // Length counter (HTML `#counter-banner`).
    'measure_counter': 'Length Measured:',
    'cnt_m': '{n} m',
    'cnt_cm': '{n} cm',
    'cnt_mm': '{n} mm',
    'cnt_km_done': '1000 m (1 km)',
    'cnt_cm_done': '10 mm (1 cm)',
    // Scene labels (HTML `#canvas-labels`) and canvas text.
    'lbl_cloth': 'Fabric Roll (8m)',
    'lbl_rod': '1m Metal Scale',
    'lbl_road': '1 km Highway Segment',
    'lbl_ruler': '15 cm Precision Ruler',
    'lbl_chalk_1': '1 m',
    'lbl_chalk_2': '2 m',
    'lbl_start': '0 m',
    'sign_km': '1 km',
  },
  'hi': {
    'app_title': 'लंबाई के मानक मात्रक (SI मात्रक) और रूपांतरण',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1': 'परिदृश्य 1: दर्जी की दुकान',
    'scen_2': 'परिदृश्य 2: सड़क यात्रा और सिक्का',
    's1_mission':
        'कपड़े के ऑर्डर को पूरा करके मीटर (m) और सेंटीमीटर (cm) के बीच के संबंध को दृश्य रूप से समझना।',
    's2_mission':
        'बड़ी दूरी के लिए किलोमीटर से मीटर (km-m) और छोटी वस्तुओं के लिए सेंटीमीटर से मिलीमीटर (cm-mm) समझना।',
    's1_c1': 'मानक मीटर छड़',
    's1_a1':
        'लाल टूलबॉक्स से चमकती 1m धातु की छड़ को खींचें और कपड़े के खुले (दाएँ) सिरे से शुरू करते हुए कपड़े पर छोड़ें।',
    's1_o1': 'ठीक 1 मीटर पर चाक का निशान स्वतः प्रकट होता है।',
    's1_c2': 'संचयी लंबाई',
    's1_a2':
        'टूलबॉक्स से चमकती दूसरी 1m छड़ को खींचें और पहली छड़ से सिरे से सिरा मिलाकर, पहले चाक निशान के ठीक आगे छोड़ें।',
    's1_o2': 'कुल मापी गई लंबाई ठीक 2 मीटर तक पहुँच जाती है।',
    's1_c3': 'सटीक कटाई',
    's1_a3':
        'टूलबॉक्स से चमकती कैंची को खींचें और कपड़ा काटने के लिए उसे 2m चाक निशान पर छोड़ें।',
    's1_o3': 'मुख्य रोल से 2-मीटर का एक साफ टुकड़ा अलग हो जाता है।',
    's1_c4': 'मात्रक उपविभाजन',
    's1_a4':
        "पहली 1m छड़ को छोटे मानक मात्रकों में बाँटने के लिए 'अन्वेषण करें 1m = 100cm' पर क्लिक करें।",
    's1_o4': '1 मीटर छड़ 100 बराबर 1-सेंटीमीटर घनों में बंट जाती है।',
    's1_c5': 'सेंटीमीटर संरेखण',
    's1_a5':
        "दूसरी 1m छड़ की जगह 100 और सेंटीमीटर घन रखने के लिए 'cm ब्लॉक जोड़ें (+100 cm)' पर क्लिक करें।",
    's1_o5': '200 सेंटीमीटर घन 2-मीटर कपड़े की लंबाई से पूरी तरह मेल खाते हैं।',
    's1_hud_1':
        'चरण 1: ग्राहक 2-मीटर कपड़ा चाहता है। चमकती 1m धातु की छड़ को लाल टूलबॉक्स से खींचकर कपड़े पर छोड़ें।',
    's1_hud_2':
        'चरण 2: कुल 2 मीटर चाहिए। चमकती दूसरी धातु की छड़ को टूलबॉक्स से खींचकर पहले चाक निशान के पास छोड़ें।',
    's1_hud_3':
        'चरण 3: अब कपड़ा काटें। चमकती कैंची को लाल टूलबॉक्स से खींचकर 2m चाक निशान पर छोड़ें।',
    's1_hud_4':
        "चरण 4: देखें 1 मीटर किससे बना है! धातु के पैमाने को 100 छोटे सेंटीमीटर घनों में बंटते देखने के लिए 'अन्वेषण करें 1m = 100cm' पर क्लिक करें।",
    's1_hud_5':
        "चरण 5: सेंटीमीटर से फिर नापें! कटे कपड़े पर अगले 100 सेंटीमीटर घन (कुल 200) रखने के लिए 'cm ब्लॉक जोड़ें' पर क्लिक करें।",
    's1_summary':
        'जांच का सारांश: 2 मीटर ठीक 200 सेंटीमीटर के बराबर है (1 m = 100 cm)।',
    's1_finish': "समाप्त करने के लिए 'दर्जी अध्ययन समाप्त करें' पर क्लिक करें।",
    's2_c1': 'राजमार्ग खंड',
    's2_a1':
        "1 km राजमार्ग खंड का अन्वेषण करने के लिए '1km राजमार्ग देखें' पर क्लिक करें।",
    's2_o1': 'मापन के लिए 1 किलोमीटर सड़क तैयार है।',
    's2_c2': 'उपकरण रखें',
    's2_a2':
        "मीटर-काउंटर को सड़क की शुरुआती रेखा (0 m निशान) पर रखने के लिए 'मीटर-काउंटर रखें' पर क्लिक करें।",
    's2_o2': 'काउंटर 0 m पर शुरू होकर दूरी मापने के लिए तैयार है।',
    's2_c3': 'किलोमीटर से मीटर',
    's2_a3':
        "1 km सड़क पर लेज़र किरण भेजने और काउंटर देखने के लिए 'लेज़र से मापें' पर क्लिक करें।",
    's2_o3': 'काउंटर तेजी से 1000 m तक बढ़ता है। अतः 1 km = 1000 m।',
    's2_c4': 'टेबलटॉप ज़ूम',
    's2_a4':
        "चाँदी के सिक्के को 15 cm स्केल के 0 निशान पर रखने के लिए 'सिक्का स्केल पर रखें' पर क्लिक करें।",
    's2_o4': 'कैमरा ज़ूम होकर छोटे मिलीमीटर निशान स्पष्ट दिखाता है।',
    's2_c5': 'मिलीमीटर पठन',
    's2_a5':
        "स्केल के निशानों के सामने सिक्के का किनारा जांचने के लिए 'सिक्के की मोटाई मापें' पर क्लिक करें।",
    's2_o5': 'सिक्के का किनारा दूसरे निशान (2 mm) से मिलता है।',
    's2_c6': 'सेंटीमीटर रूपांतरण',
    's2_a6':
        "5 सिक्कों का ढेर (प्रत्येक 2 mm) शून्य निशान पर रखने के लिए '5 सिक्कों का ढेर रखें' पर क्लिक करें।",
    's2_o6': 'कुल मोटाई 10 mm होती है, जो ठीक 1 cm निशान के बराबर है!',
    's2_hud_1':
        "चरण 1: आप सड़क यात्रा पर हैं। राजमार्ग का संकेत 1 km आगे दिखाता है। अन्वेषण के लिए '1km राजमार्ग देखें' पर क्लिक करें।",
    's2_hud_2':
        "चरण 2: सड़क की शुरुआत (0 m निशान) पर मीटर-काउंटर उपकरण रखें। 'मीटर-काउंटर रखें' पर क्लिक करें।",
    's2_hud_3':
        "चरण 3: लेज़र किरण भेजने और मीटर गिनने के लिए 'लेज़र से मापें' पर क्लिक करें।",
    's2_hud_4':
        "चरण 4: अब टेबलटॉप दृश्य! सटीक निशान देखने के लिए 'सिक्का स्केल पर रखें' पर क्लिक करें।",
    's2_hud_5':
        "चरण 5: ज़ूम किए गए mm निशानों को देखें। सिक्के की मोटाई जांचने के लिए 'सिक्के की मोटाई मापें' पर क्लिक करें।",
    's2_hud_6':
        "चरण 6: cm-mm रूपांतरण जांचें! 10 mm = 1 cm सत्यापित करने के लिए '5 सिक्कों का ढेर रखें' पर क्लिक करें।",
    's2_summary':
        'जांच का सारांश: लंबी दूरी के लिए 1 km = 1000 m और छोटी वस्तुओं के लिए 1 cm = 10 mm।',
    's2_finish': "समाप्त करने के लिए 'SI अध्ययन समाप्त करें' पर क्लिक करें।",
    'btn_explore_m': 'अन्वेषण करें 1m = 100cm',
    'btn_add_cm': 'cm ब्लॉक जोड़ें (+100 cm)',
    'btn_conclude_s1': 'दर्जी अध्ययन समाप्त करें',
    'btn_zoom_road': '1km राजमार्ग देखें',
    'btn_deploy': 'मीटर-काउंटर रखें',
    'btn_pulse': 'लेज़र से मापें',
    'btn_place_coin': 'सिक्का स्केल पर रखें',
    'btn_measure_mm': 'सिक्के की मोटाई मापें',
    'btn_stack': '5 सिक्कों का ढेर रखें',
    'btn_conclude_s2': 'SI अध्ययन समाप्त करें',
    'toast_rod1': '1 मीटर पैमाना रखा गया (1m सीमा पर चाक का निशान)',
    'toast_rod2': 'दूसरा मीटर पैमाना रखा गया (2m सीमा पर चाक का निशान)',
    'toast_cut': 'कपड़ा ठीक 2m सीमा पर कट गया!',
    'toast_explore': '1 मीटर छड़ बंट गई: 1 m = ठीक 100 cm घन!',
    'toast_blocks': 'दूसरी मीटर छड़ बंट गई: 2 m = 200 cm घन!',
    'toast_highway': '1km राजमार्ग खंड का अन्वेषण',
    'toast_deploy': 'मीटर-काउंटर उपकरण 0 m निशान पर रखा गया',
    'toast_pulse': '1 km = 1000 m सत्यापित!',
    'toast_coin': 'टेबलटॉप ज़ूम: 15cm स्केल पर सिक्के की जांच',
    'toast_mm': 'सिक्के की मोटाई मापी गई: ठीक 2 mm!',
    'toast_stack': '5 सिक्के × 2mm = 10 mm = 1 cm सत्यापित!',
    'err_rod1': 'छड़ को कपड़े के खुले (दाएँ) सिरे के पास खींचें',
    'err_rod2': 'दूसरी छड़ को पहले चाक निशान के पास खींचें',
    'err_scissors': 'कपड़ा काटने के लिए कैंची को 2m चाक रेखा के पास खींचें',
    'popup_s1_title': 'सफलता!',
    'popup_s1_heading': 'परिदृश्य 1 पूर्ण हुआ!',
    'popup_s1_desc': 'आपने सत्यापित किया है कि 1 मीटर = 100 सेंटीमीटर!',
    'popup_s2_title': 'लैब में महारत!',
    'popup_s2_heading': 'सभी परिदृश्य सफलतापूर्वक पूर्ण हुए!',
    'popup_s2_desc':
        'आपने लंबाई के SI मात्रकों में महारत हासिल की है: किलोमीटर, मीटर, सेंटीमीटर और मिलीमीटर!',
    'measure_counter': 'मापी गई लंबाई:',
    'cnt_m': '{n} m',
    'cnt_cm': '{n} cm',
    'cnt_mm': '{n} mm',
    'cnt_km_done': '1000 m (1 km)',
    'cnt_cm_done': '10 mm (1 cm)',
    'lbl_cloth': 'कपड़े का थान (8m)',
    'lbl_rod': '1m धातु पैमाना',
    'lbl_road': '1 km राजमार्ग खंड',
    'lbl_ruler': '15 cm सटीक स्केल',
    'lbl_chalk_1': '1 m',
    'lbl_chalk_2': '2 m',
    'lbl_start': '0 m',
    'sign_km': '1 km',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML `ScenariosData`
/// steps: concept / action / observation).
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
          objective: t('s1_mission'),
          steps: steps(1, _s1Steps),
        ),
        LabScenarioData(
          title: t('scen_2'),
          objective: t('s2_mission'),
          steps: steps(2, _s2Steps),
        ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

/// Steps per scenario (HTML `ScenariosData[*][n].steps`).
const int _s1Steps = 5, _s2Steps = 6;

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target for scene objects (logical px).
const double _minTouch = 48;

// ------------------------------------------------------------------ cameras
// HTML `resetCamera()` / `triggerScenarioStep()` (PerspectiveCamera fov 45,
// position + controls.target).

const _V _camTailor = _V(0, 8, 14), _tgtTailor = _V.zero;
const _V _camHighway = _V(0, 16, 28), _tgtHighway = _V.zero;

/// Tabletop overview. HTML (0, 7, 10); pulled back a little so the whole
/// 15 cm ruler fits (the HTML ruler had only 10 cm of ticks).
const _V _camRuler = _V(0, 8, 12), _tgtRuler = _V.zero;

/// Millimetre reading and coin-stack views. The HTML views ((−3, 4.5, 6) →
/// (−4, 0, −1) and (−2, 5, 7) → (−3, 0, −1), relative to its zero mark at
/// x = −5) are moved to the new zero mark and brought a little closer, so
/// the coin, the tick ends and the 0 / 1 cm numbers fit between the counter
/// and the canvas button row (1 mm ≈ 9 design px instead of 7).
const _V _camMm = _V(-6.0, 3.6, 3.4), _tgtMm = _V(-7.0, 0.25, -0.8);
const _V _camStack = _V(-5.5, 3.7, 4.6), _tgtStack = _V(-6.8, 0.4, -0.8);

/// Camera tween times (HTML 1000 ms / 800 ms, Cubic.Out).
const double _camTime = 1.0, _camTimeShort = 0.8;

// ----------------------------------------------------- scenario 1: tailor
// HTML buildScenario1(). One metre is 4 world units (the 1 m rod is 4 long).

/// Tailor table top (16 × 0.5 × 8, top at y = 0) and legs (r 0.3, h 3.5).
const _V _tableC = _V(0, -0.25, 0), _tableHalf = _V(8, 0.25, 4);
const List<(double, double)> _legSpots = [
  (-7.3, -3.3),
  (7.3, -3.3),
  (-7.3, 3.3),
  (7.3, 3.3),
];
const double _legR = 0.3, _legLen = 3.5, _legBottom = -3.75;

/// Fabric (HTML 8 × 0.15 × 3.5 at y 0.08). It now comes off the roll at the
/// left (x −5.6) and its free end is at x = 4, so the 2 m piece measured from
/// the free end (x −4 … 4) is cut off next to the roll.
const double _clothLeft = -5.6, _clothRight = 4, _clothHalfZ = 1.75;
const double _clothY = 0.08, _clothHalfY = 0.075;
const double _clothTop = _clothY + _clothHalfY;

/// The 1 m and 2 m marks (measured from the free end) and the cut line.
const double _mark1X = 0, _cutX = -4;

/// HTML: the cut piece slides 1.5 forward (400 ms, after the 300 ms snip).
const double _clothSlide = 1.5;

/// Chalk marks (HTML 0.06 × 0.17 × 3.52, colour #fef08a).
const double _chalkY = 0.09;
const _V _chalkHalf = _V(0.03, 0.085, 1.76);

/// Rolled-up cloth (HTML CylinderGeometry r 0.7, length 3.5, along z),
/// resting on the table.
const _V _rollC = _V(-5.6, 0.7, 0);
const double _rollR = 0.7;

/// Toolbox (HTML 3.5 × 1.2 × 2.5 at (5.5, 0.6, −2)) and the spot on its lid
/// where each rod and the scissors wait (HTML (5.5, 1.3, −2)).
const _V _toolboxC = _V(5.5, 0.6, -2), _toolboxHalf = _V(1.75, 0.6, 1.25);
const _V _itemHome = _V(5.5, 1.3, -2);

/// 1 m metal rod (HTML 4 × 0.1 × 0.3) and where it lies on the cloth.
const _V _rodHalf = _V(2, 0.05, 0.15);
const double _rodRestY = _clothTop + 0.055;
const _V _rod1Spot = _V(2, _rodRestY, 0), _rod2Spot = _V(-2, _rodRestY, 0);

/// Scissors hit box (HTML 1.6 × 0.5 × 2.4) and their place on the cut line.
const _V _scissorsHit = _V(0.8, 0.25, 1.2);
const _V _scissorsCut = _V(_cutX, 0.2, 0);

/// Blade half-angle (HTML half1/half2 rotation.y = ±0.18).
const double _bladeOpenAngle = 0.18;

/// Carried objects ride just above the toolbox lid; the drag plane is at
/// that height, so the object stays under the finger.
const double _carryY = 1.35;

/// Drops are accepted within these distances (xz) of the target. The HTML
/// radii (4.5 for the rods, 3.5 for the scissors) already contained the
/// toolbox spot of rod 2 and the scissors, so a plain tap passed the step.
const double _rodReach = 1.6, _scissorsReach = 1.4;

/// Carried objects stay over the table.
const double _dragMaxX = 7.6, _dragMaxZ = 3.6;

/// Centimetre cubes (HTML 0.038 × 0.12 × 0.3, every 0.04, every 5th darker).
const double _cmPitch = 0.04, _cmWidth = 0.038, _cmHalfY = 0.06;
const double _cmHalfZ = 0.15, _cmY = _clothTop + _cmHalfY + 0.005;
const int _cmPerMetre = 100;

/// Tween times (s): rod settles (450 ms Cubic.Out), wrong drop returns
/// (300 ms), blades close (280 ms), scissors move (300 ms), cloth slides
/// (400 ms).
const double _settleTime = 0.45, _returnTime = 0.3, _bladeTime = 0.28;
const double _snipTime = 0.3, _slideTime = 0.4;

/// Breathing highlight on the item to drag (HTML emissive glow:
/// (sin(Date.now() × 0.005) × 0.5 + 0.5) × 0.8).
const double _glowRate = 5, _glowMax = 0.8;

// ---------------------------------------------------- scenario 2: highway
// HTML buildScenario2() highwayGroup. The 1 km segment runs x −12 … 12.

const double _kmStartX = -12, _kmEndX = 12;

/// Metre-Counter (HTML group at (−12, 0, 3.5), dropped from y 5 with
/// Bounce.Out in 600 ms) and the laser pulse at the lens height. The HTML
/// beam ran along the road's centre line (z 0) while the device stood at
/// z 3.5; here it leaves the lens.
const _V _toolSpot = _V(_kmStartX, 0, 3.5);
const double _toolDropFrom = 5, _toolDropTime = 0.6;
const double _beamY = 0.8, _beamZ = 3.5, _beamHalf = 0.075;

/// Laser pulse (HTML 1000 ms) and the counter (HTML 0 → 1000 in 1200 ms).
const double _beamTime = 1.0, _countTime = 1.2;
const int _kmInMetres = 1000;

// --------------------------------------------------- scenario 2: tabletop
// HTML rulerGroup. One centimetre is 1 world unit.

/// 15 cm ruler: ticks every 1 mm from x −7.5 (0 cm) to 7.5 (15 cm). The HTML
/// drew 101 ticks (0 … 10 cm) on a 14-unit ruler labelled "15 cm".
const double _zeroX = -7.5, _mm = 0.1;
const int _rulerMm = 150;
const _V _rulerC = _V(0, 0.06, 0), _rulerHalf = _V(8, 0.06, 1.6);
const double _rulerTop = 0.12, _tickTop = 0.141, _tickBack = -1.6;
const double _tickHalfW = 0.02;

/// Tick lengths: cm 1.4, 5 mm 0.9, mm 0.5 (HTML).
const double _cmTick = 1.4, _halfCmTick = 0.9, _mmTick = 0.5;

/// Coin: r 0.7, 0.2 (2 mm) thick. It stands on its rim with its thickness
/// along the ruler (the HTML coin faced the camera, so its thickness ran
/// across the ticks). Placed with one face on the zero mark.
const double _coinR = 0.7, _coinT = 0.2;
const double _coinZ = -1.4; // HTML z −1.4
const _V _coinHome = _V(4, _coinR, 3);
const _V _coinSpot = _V(_zeroX + _coinT / 2, _rulerTop + _coinR, _coinZ);

/// Stack of five coins (10 mm) from the zero mark to the 1 cm mark.
const int _stackCoins = 5;
const _V _stackHome = _V(4, _coinR, -3);
const _V _stackSpot = _V(
  _zeroX + _stackCoins * _coinT / 2,
  _rulerTop + _coinR,
  _coinZ,
);

/// Coin / stack moves (HTML 600 ms Back.Out).
const double _coinTime = 0.6;

// ------------------------------------------------------------- stage pan
// While the sidebar is collapsed the shell's floating mission card sits at
// the top left: 76 px from the left, 36 % of the screen wide (200 … 380 px ×
// UI scale). The scene layer slides right so the part the learner works with
// stays clear of it ([_cardGap] design px), without going under the tool
// column.
const double _missionCardLeft = 76;
const double _missionCardFraction = 0.36;
const double _missionCardMin = 200;
const double _missionCardMax = 380;
const double _cardGap = 8;

/// The pan slides like the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the panned scene layer. Flows map scene design coordinates to the
/// screen through it, so they follow the pan (`ValueKey('ch5-a2-scene')`).
const ValueKey<String> _sceneKey = ValueKey('ch5-a2-scene');

/// Canvas labels grow when the stage is scaled down (up to 1.8×).
const double _labelFullScale = 0.85, _labelMaxBoost = 1.8;

/// Pan recogniser that only claims pointers that start on a draggable
/// object (decided by [canGrab]), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _SiUnitsLabState
    extends State<Ch5A2StandardUnitsOfLengthSiUnitsAndConversionsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// HTML `#counter-banner` value: a string key and its number, or null
  /// while the banner is hidden. Updated every frame only while counting.
  final ValueNotifier<(String, int)?> _counter = ValueNotifier(null);

  /// Canvas text (labels, ruler digits, sign), laid out once and reused.
  final _TextCache _texts = _TextCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for touch-sized hit areas.
  double _fit = 1;

  /// Object under the finger at pointer-down (not yet dragging).
  _Obj? _grab;

  /// Last feedback toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;
  String _t(String key) => _lab.tr(_i18n, key);
  int get _stepCount => _scenario == 0 ? _s1Steps : _s2Steps;

  /// Every step done: the HUD shows the summary and "Conclude" is offered.
  bool get _done => _step > _stepCount;

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
    _counter.dispose();
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update() (positions, camera, the counter).
  void _onTick(Duration elapsed) {
    final s = _scene;
    s.time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    s.updateTweens();
    if (s.countStart >= 0) _updateCount();
    _frame.value = s.time;
  }

  /// HTML counter tween: 0 → 1000 m in 1200 ms (linear).
  void _updateCount() {
    final s = _scene;
    final t = (s.time - s.countStart) / _countTime;
    if (t >= 1) {
      s.countStart = -1;
      _finishPulse();
      return;
    }
    _counter.value = ('cnt_m', (t * _kmInMetres).floor());
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(msg)`. The HTML toasts are silent (each step plays its
  /// own sound); a wrong drop plays the shell's "wrong" tone.
  void _toast(String key, {bool isError = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: isError, sound: isError);
  }

  /// Re-shows the visible toast (this lab's or the shell's "Scenario
  /// Complete") in the new language after a switch from [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    if (shown == null) return;
    final key = _toastKey;
    final String translated;
    if (key != null && shown.text == labTr(_i18n, previous, key)) {
      translated = _t(key);
    } else if (shown.text ==
        labTr(kLabCommonStrings, previous, 'msg_scenario_complete')) {
      translated = _lab.t('msg_scenario_complete');
    } else {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  /// HTML `changeScenario(id)` / `resetApp()`: resets every object of
  /// [index] to step 1 with its camera; cancels pending animations.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
    });
    _counter.value = null;
    _lab.resetView(sound: false);
  }

  // ------------------------------------------------- scenario 1: dragging

  /// The object the current step lets the learner drag (HTML pointerdown
  /// targets: rod 1 on step 1, rod 2 on step 2, the scissors on step 3).
  _Obj? get _draggable {
    final s = _scene;
    if (s.scenario != 0) return null;
    return switch (s.step) {
      1 => _Obj.rod1,
      2 => _Obj.rod2,
      3 => _Obj.scissors,
      _ => null,
    };
  }

  /// HTML raycast on pointer-down: the object's box, widened to a
  /// finger-sized target.
  bool _canGrab(PointerDownEvent event) {
    final obj = _draggable;
    final s = _scene;
    if (obj == null || s.dragging != null) return false;
    final half = obj == _Obj.scissors ? _scissorsHit : _rodHalf;
    var box = s.proj.bounds(s.positionOf(obj), half);
    final min = _minTouch / _fit;
    if (box.width < min || box.height < min) {
      box = Rect.fromCenter(
        center: box.center,
        width: math.max(box.width, min),
        height: math.max(box.height, min),
      );
    }
    if (!box.contains(event.localPosition)) return false;
    _grab = obj;
    return true;
  }

  /// HTML `pointerdown`: keep the drag-plane offset so the object does not
  /// jump to the finger; lift it to the carrying height.
  void _dragStart(DragStartDetails d) {
    final obj = _grab;
    if (obj == null) return;
    final s = _scene;
    final pos = s.positionOf(obj);
    final hit = s.proj.onPlane(d.localPosition, _carryY);
    _Sound.pickup.play();
    s
      ..dragging = obj
      ..dragOffset = hit == null ? _V.zero : _V(hit.x - pos.x, 0, hit.z - pos.z)
      ..setTween(obj, null)
      ..setPosition(obj, _V(pos.x, _carryY, pos.z));
  }

  /// HTML `pointermove`: the object follows the finger over the table.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.dragging;
    if (obj == null) return;
    final hit = s.proj.onPlane(d.localPosition, _carryY);
    if (hit == null) return;
    s.setPosition(
      obj,
      _V(
        (hit.x - s.dragOffset.x).clamp(-_dragMaxX, _dragMaxX),
        _carryY,
        (hit.z - s.dragOffset.z).clamp(-_dragMaxZ, _dragMaxZ),
      ),
    );
  }

  /// HTML `pointerup`: test the drop.
  void _dragEnd() {
    final s = _scene;
    final obj = s.dragging;
    _grab = null;
    if (obj == null) return;
    s.dragging = null;
    switch (obj) {
      case _Obj.rod1:
        _dropRod(obj, _rod1Spot);
      case _Obj.rod2:
        _dropRod(obj, _rod2Spot);
      case _Obj.scissors:
        _dropScissors();
    }
  }

  /// Rod dropped (HTML `triggerScenarioStep(2)` / `(3)`): close enough to
  /// its metre of cloth, it settles there (450 ms Cubic.Out), the chalk mark
  /// at its far end appears and the next tool is put on the toolbox;
  /// otherwise it slides back to the toolbox (300 ms) with a hint.
  void _dropRod(_Obj rod, _V spot) {
    final s = _scene;
    final pos = s.positionOf(rod);
    final first = rod == _Obj.rod1;
    final d = math.sqrt(
      math.pow(pos.x - spot.x, 2) + math.pow(pos.z - spot.z, 2),
    );
    if (d >= _rodReach) {
      s.setTween(rod, _Tween(pos, _itemHome, s.time, _returnTime, _linear));
      _toast(first ? 'err_rod1' : 'err_rod2', isError: true);
      return;
    }
    _Sound.stamp.play();
    setState(() {
      s.setTween(rod, _Tween(pos, spot, s.time, _settleTime, _cubicOut));
      if (first) {
        s
          ..chalk1 = true
          ..rod2Visible = true
          ..step = 2;
      } else {
        s
          ..chalk2 = true
          ..scissorsVisible = true
          ..step = 3;
      }
    });
    _counter.value = ('cnt_m', first ? 1 : 2);
    _toast(first ? 'toast_rod1' : 'toast_rod2');
  }

  /// Scissors dropped (HTML `triggerScenarioStep(4)`): on the 2 m mark the
  /// blades close (280 ms), the scissors snap to the cut (300 ms) and the
  /// 2 m piece slides away from the roll (400 ms); otherwise back to the
  /// toolbox with a hint.
  void _dropScissors() {
    final s = _scene;
    final pos = s.scissors;
    final d = math.sqrt(math.pow(pos.x - _cutX, 2) + math.pow(pos.z, 2));
    if (d >= _scissorsReach) {
      s.scissorsTween = _Tween(pos, _itemHome, s.time, _returnTime, _linear);
      _toast('err_scissors', isError: true);
      return;
    }
    _Sound.stamp.play();
    _Sound.cut.play();
    setState(() {
      s
        ..scissorsTween = _Tween(pos, _scissorsCut, s.time, _snipTime, _linear)
        ..bladeTween = _NumTween(s.bladeOpen, 0, s.time, _bladeTime, _linear)
        ..clothTween = _NumTween(
          0,
          _clothSlide,
          s.time + _snipTime,
          _slideTime,
          _linear,
        )
        ..cut = true
        ..step = 4;
    });
    _toast('toast_cut');
  }

  // -------------------------------------------------- scenario 1: buttons

  /// HTML "Explore 1m = 100cm" (`triggerScenarioStep(5)`): the first rod
  /// becomes 100 centimetre cubes. The HTML also hid the second rod here;
  /// it stays until it is broken up in the next step, as its toast says.
  void _exploreMetre() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 4) return;
    _Sound.stamp.play();
    setState(() {
      s
        ..rod1Visible = false
        ..scissorsVisible = false
        ..blocks = _cmPerMetre
        ..step = 5;
    });
    _counter.value = ('cnt_cm', _cmPerMetre);
    _toast('toast_explore');
  }

  /// HTML "Add cm Blocks" (`triggerScenarioStep(6)`): the second rod becomes
  /// 100 more cubes, 200 in all.
  void _addBlocks() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 5) return;
    _Sound.stamp.play();
    _Sound.success.play();
    setState(() {
      s
        ..rod2Visible = false
        ..blocks = 2 * _cmPerMetre
        ..step = 6;
    });
    _counter.value = ('cnt_cm', 2 * _cmPerMetre);
    _toast('toast_blocks');
  }

  // -------------------------------------------------- scenario 2: buttons
  // The HTML ran each step's effect from the previous step's button (its
  // "Explore 1km Highway" deployed the counter, "Deploy Metre-Counter Tool"
  // fired the laser, and "Pulse Measure" was never shown). Here every button
  // does what its label and step say.

  /// "Explore 1km Highway" (HTML stepNum 1): highway view, counter hidden.
  void _exploreHighway() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 1) return;
    _Sound.stamp.play();
    setState(() {
      s
        ..moveCamera(_camHighway, _tgtHighway, _camTime)
        ..step = 2;
    });
    _counter.value = null;
    _toast('toast_highway');
  }

  /// "Deploy Metre-Counter Tool" (HTML stepNum 2): the device drops onto
  /// the 0 m line; the counter reads 0 m.
  void _deployCounter() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 2) return;
    _Sound.stamp.play();
    setState(() {
      s
        ..toolVisible = true
        ..toolTween = _Tween(
          _toolSpot + const _V(0, _toolDropFrom, 0),
          _toolSpot,
          s.time,
          _toolDropTime,
          _bounceOut,
        )
        ..step = 3;
    });
    _counter.value = ('cnt_m', 0);
    _toast('toast_deploy');
  }

  /// "Pulse Measure" (HTML stepNum 3): the laser runs down the 1 km road
  /// while the counter counts the metres. The step ends when the count does
  /// (the HTML moved on at once, before the count was seen).
  void _pulse() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || s.countStart >= 0 || s.pulsed) {
      return;
    }
    _Sound.stamp.play();
    setState(() {
      s
        ..beamStart = s.time
        ..countStart = s.time;
    });
    _counter.value = ('cnt_m', 0);
  }

  /// End of the count: 1000 m (1 km).
  void _finishPulse() {
    final s = _scene;
    _Sound.success.play();
    setState(() {
      s
        ..pulsed = true
        ..step = 4;
    });
    _counter.value = ('cnt_km_done', _kmInMetres);
    _toast('toast_pulse');
  }

  /// "Examine Coin on 15cm Ruler" (HTML stepNum 4): tabletop view; the coin
  /// moves to the zero mark (600 ms Back.Out).
  void _examineCoin() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 4) return;
    _Sound.stamp.play();
    setState(() {
      s
        ..tabletop = true
        ..view = _View.ruler
        ..coinTween = _Tween(s.coin, _coinSpot, s.time, _coinTime, _backOut)
        ..moveCamera(_camRuler, _tgtRuler, _camTime)
        ..step = 5;
    });
    _counter.value = ('cnt_mm', 0);
    _toast('toast_coin');
  }

  /// "Measure Coin Thickness" (HTML stepNum 5): zoom on the coin; the 2 mm
  /// tick lights up green.
  void _measureCoin() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 5) return;
    _Sound.stamp.play();
    _Sound.pop.play();
    setState(() {
      s
        ..mmGlow = true
        ..view = _View.rulerMm
        ..moveCamera(_camMm, _tgtMm, _camTimeShort)
        ..step = 6;
    });
    _counter.value = ('cnt_mm', 2);
    _toast('toast_mm');
  }

  /// "Place 5-Coin Stack" (HTML stepNum 6): five coins from the zero mark
  /// reach the 1 cm mark. The single coin is put back (the HTML left it
  /// inside the stack).
  void _placeStack() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 6) return;
    _Sound.stamp.play();
    _Sound.success.play();
    setState(() {
      s
        ..stackVisible = true
        ..stackTween = _Tween(s.stack, _stackSpot, s.time, _coinTime, _backOut)
        ..coinTween = _Tween(s.coin, _coinHome, s.time, _coinTime, _linear)
        ..view = _View.rulerStack
        ..moveCamera(_camStack, _tgtStack, _camTimeShort)
        ..step = 7;
    });
    _counter.value = ('cnt_cm_done', 10);
    _toast('toast_stack');
  }

  /// HTML "Conclude Tailor Study" / "Conclude SI Study"
  /// (`validateInvestigation()`): the scenario's success popup.
  void _conclude() {
    if (!_done) return;
    final sc = _scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t('popup_s${sc + 1}_title'),
      heading: () => _t('popup_s${sc + 1}_heading'),
      body: () => _t('popup_s${sc + 1}_desc'),
    );
  }

  // ------------------------------------------------------------------- UI

  /// The HTML `#hud-action-box` button for the current step.
  List<LabAction> _actions() {
    final s = _scene;
    LabAction act(
      String key,
      IconData icon,
      Color color,
      Color foreground,
      VoidCallback onTap,
    ) => LabAction(
      label: _t(key),
      icon: icon,
      color: color,
      foreground: foreground,
      highlight: true,
      // Each handler plays the HTML's step sound.
      silent: true,
      onTap: onTap,
    );
    const dark = _Colors.slate950, light = _Colors.white;
    if (s.scenario == 0) {
      return switch (s.step) {
        4 => [
          act(
            'btn_explore_m',
            Icons.search,
            _Colors.amber500,
            dark,
            _exploreMetre,
          ),
        ],
        5 => [
          act(
            'btn_add_cm',
            Icons.view_week,
            _Colors.zslYellow,
            dark,
            _addBlocks,
          ),
        ],
        6 => [
          act(
            'btn_conclude_s1',
            Icons.check_circle,
            _Colors.green500,
            dark,
            _conclude,
          ),
        ],
        _ => const [],
      };
    }
    return switch (s.step) {
      1 => [
        act(
          'btn_zoom_road',
          Icons.travel_explore,
          _Colors.blue500,
          light,
          _exploreHighway,
        ),
      ],
      2 => [
        act(
          'btn_deploy',
          Icons.add_location_alt,
          _Colors.cyan500,
          dark,
          _deployCounter,
        ),
      ],
      3 when s.countStart < 0 => [
        act('btn_pulse', Icons.bolt, _Colors.cyan500, dark, _pulse),
      ],
      4 => [
        act(
          'btn_place_coin',
          Icons.monetization_on,
          _Colors.amber500,
          dark,
          _examineCoin,
        ),
      ],
      5 => [
        act(
          'btn_measure_mm',
          Icons.center_focus_strong,
          _Colors.green500,
          dark,
          _measureCoin,
        ),
      ],
      6 => [
        act('btn_stack', Icons.layers, _Colors.indigo500, light, _placeStack),
      ],
      7 => [
        act(
          'btn_conclude_s2',
          Icons.check_circle,
          _Colors.green500,
          dark,
          _conclude,
        ),
      ],
      _ => const [],
    };
  }

  /// HTML `renderHUD()`: the short "Current Task" line, or the summary once
  /// every step is done.
  String get _hud {
    final sc = _scenario + 1;
    return _done ? _t('s${sc}_summary') : _t('s${sc}_hud_$_step');
  }

  /// Scene design-x range the learner works with in the current view (kept
  /// clear of the floating mission card while the sidebar is collapsed).
  (double, double) get _focusExtent => switch (_scene.view) {
    _View.tailor => (225, 805), // cloth roll … toolbox
    _View.highway => (185, 790), // Metre-Counter … end of the 1 km
    _View.ruler => (130, 600), // zero mark and coin
    _View.rulerMm => (380, 600),
    _View.rulerStack => (360, 600),
  };

  /// Pan of the scene layer while the sidebar is collapsed (design px).
  double _collapsedShift(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return 0;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = (size.width * _missionCardFraction).clamp(
      _missionCardMin,
      _missionCardMax * context.labScale,
    );
    final cardRight = (_missionCardLeft + pad.left + card - stageLeft) / fit;
    final tools = labOverlayInsets(context, _lab).right;
    final toolsLeft = (size.width - tools - stageLeft) / fit;
    final (left, right) = _focusExtent;
    // Draggable objects must stay inside the stage box to be hit-tested.
    final room = math.max(
      0.0,
      math.min(toolsLeft - _cardGap - right, _design.width - right),
    );
    return (cardRight + _cardGap - left).clamp(0.0, room);
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
        final data = _scenarioData(_lab.lang)[_scenario];
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        final sc = _scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.straighten,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          // After the last step: the HTML summary line plus the button to
          // press (the sidebar would otherwise repeat the last step).
          instruction: _done
              ? '${_t('s${sc}_summary')} ${_t('s${sc}_finish')}'
              : null,
          hud: _hud,
          actions: actions,
          // HTML `resetApp()` starts again at Scenario 1.
          onReset: () => _loadScenario(0),
          overlays: [
            // HTML `#hud-action-box` on the canvas. While the sidebar is
            // collapsed the floating mission card carries the buttons.
            if (actions.isNotEmpty && _lab.isSidebarOpen && _lab.popup == null)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + 66 * s,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final a in actions)
                          LabActionButton(action: a, scale: s, expand: false),
                      ],
                    ),
                  ),
                ),
              ),
            // HTML `#counter-banner` ("Length Measured: …"), top right below
            // the toast row, left of the tool column.
            Positioned(
              top: inset.top + 52 * s,
              right: inset.right,
              child: ValueListenableBuilder<(String, int)?>(
                valueListenable: _counter,
                builder: (context, value, _) =>
                    value == null || !_lab.isLabActive
                    ? const SizedBox.shrink()
                    : _CounterBanner(
                        label: _t('measure_counter'),
                        value: labFormat(_t(value.$1), {'n': value.$2}),
                        palette: p,
                        scale: s,
                      ),
              ),
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
        if (fit > 0 && fit.isFinite) _fit = fit;
        final shift = _lab.isSidebarOpen ? 0.0 : _collapsedShift(context);
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        return LabStage(
          designSize: _design,
          // The pan slides the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(shift / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                gestures: <Type, GestureRecognizerFactory>{
                  _GrabPanRecognizer:
                      GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                        () => _GrabPanRecognizer(debugOwner: this),
                        (r) => r
                          // Small slop: a short drag picks the object up
                          // before the zoom viewer claims the pointer
                          // (RawGestureDetector ignores MediaQuery's).
                          ..gestureSettings = const DeviceGestureSettings(
                            touchSlop: 8,
                          )
                          ..canGrab = _canGrab
                          ..dragStartBehavior = DragStartBehavior.down
                          ..onStart = _dragStart
                          ..onUpdate = _dragUpdate
                          ..onEnd = ((_) => _dragEnd())
                          ..onCancel = _dragEnd,
                      ),
                },
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: _design,
                    painter: _ScenePainter(
                      scene: _scene,
                      texts: _texts,
                      repaint: _frame,
                      palette: p,
                      showLabels: _lab.showLabels,
                      lang: _lab.lang,
                      labelScale: labelScale,
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

// ------------------------------------------------------------ counter card

/// HTML `#counter-banner`: "LENGTH MEASURED: 2 m" on a glass pill.
class _CounterBanner extends StatelessWidget {
  const _CounterBanner({
    required this.label,
    required this.value,
    required this.palette,
    required this.scale,
  });

  final String label;
  final String value;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 260 * s),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: p.readoutBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.readoutBorder),
          boxShadow: const [BoxShadow(color: LabInk.shadow, blurRadius: 12)],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.straighten, size: 14 * s, color: p.readoutIcon),
              SizedBox(width: 6 * s),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: labLetterSpacing(label, 0.8),
                ),
              ),
              SizedBox(width: 8 * s),
              Text(
                value,
                style: TextStyle(
                  color: p.readoutIcon,
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- scene model

/// Objects the learner drags in Scenario 1.
enum _Obj { rod1, rod2, scissors }

/// Camera framings (each has its own focus range for the stage pan).
enum _View { tailor, highway, ruler, rulerMm, rulerStack }

/// TWEEN.js easings used by the HTML.
typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// TWEEN.Easing.Cubic.Out.
double _cubicOut(double t) {
  final u = 1 - t;
  return 1 - u * u * u;
}

/// TWEEN.Easing.Back.Out (overshoot s = 1.70158).
double _backOut(double t) {
  const s = 1.70158;
  final k = t - 1;
  return k * k * ((s + 1) * k + s) + 1;
}

/// TWEEN.Easing.Bounce.Out.
double _bounceOut(double t) {
  const n = 7.5625, d = 2.75;
  if (t < 1 / d) return n * t * t;
  if (t < 2 / d) {
    final k = t - 1.5 / d;
    return n * k * k + 0.75;
  }
  if (t < 2.5 / d) {
    final k = t - 2.25 / d;
    return n * k * k + 0.9375;
  }
  final k = t - 2.625 / d;
  return n * k * k + 0.984375;
}

/// A TWEEN.js tween of a position (it may start in the future).
@immutable
class _Tween {
  const _Tween(this.from, this.to, this.start, this.duration, this.ease);

  final _V from;
  final _V to;
  final double start;
  final double duration;
  final _Ease ease;

  _V at(double now) =>
      _V.lerp(from, to, ease(((now - start) / duration).clamp(0.0, 1.0)));

  bool isDone(double now) => now >= start + duration;
}

/// A TWEEN.js tween of one number (blade angle, cloth slide).
@immutable
class _NumTween {
  const _NumTween(this.from, this.to, this.start, this.duration, this.ease);

  final double from;
  final double to;
  final double start;
  final double duration;
  final _Ease ease;

  double at(double now) =>
      from + (to - from) * ease(((now - start) / duration).clamp(0.0, 1.0));

  bool isDone(double now) => now >= start + duration;
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;
  int step = 1;
  _View view = _View.tailor;

  // Camera (position + controls.target) and its tween.
  _V eye = _camTailor, target = _tgtTailor;
  _Tween? eyeTween, targetTween;

  // ---------------------------------------------------------- scenario 1
  _V rod1 = _itemHome, rod2 = _itemHome, scissors = _itemHome;
  _Tween? rod1Tween, rod2Tween, scissorsTween;
  bool rod1Visible = true, rod2Visible = false, scissorsVisible = false;

  /// Scissor blades' half-angle (HTML half1 / half2 rotation.y).
  double bladeOpen = _bladeOpenAngle;
  _NumTween? bladeTween;
  bool chalk1 = false, chalk2 = false, cut = false;

  /// How far the cut 2 m piece has slid forward (z).
  double clothShift = 0;
  _NumTween? clothTween;

  /// Centimetre cubes laid on the cloth (0, 100, 200).
  int blocks = 0;

  // ---------------------------------------------------------- scenario 2
  bool tabletop = false;
  bool toolVisible = false;
  _V tool = _toolSpot;
  _Tween? toolTween;

  /// Start time of the laser pulse and of the count (−1: not running).
  double beamStart = -1;
  double countStart = -1;
  bool pulsed = false;

  _V coin = _coinHome;
  _Tween? coinTween;
  bool mmGlow = false;
  bool stackVisible = false;
  _V stack = _stackHome;
  _Tween? stackTween;

  // ------------------------------------------------------------ dragging
  _Obj? dragging;
  _V dragOffset = _V.zero;

  _Proj get proj => _Proj(eye, target);

  _V positionOf(_Obj obj) => switch (obj) {
    _Obj.rod1 => rod1,
    _Obj.rod2 => rod2,
    _Obj.scissors => scissors,
  };

  void setPosition(_Obj obj, _V pos) {
    switch (obj) {
      case _Obj.rod1:
        rod1 = pos;
      case _Obj.rod2:
        rod2 = pos;
      case _Obj.scissors:
        scissors = pos;
    }
  }

  void setTween(_Obj obj, _Tween? tween) {
    switch (obj) {
      case _Obj.rod1:
        rod1Tween = tween;
      case _Obj.rod2:
        rod2Tween = tween;
      case _Obj.scissors:
        scissorsTween = tween;
    }
  }

  /// Where [obj] is drawn: a rod laid on the cloth moves with the cut piece
  /// (the HTML left the rods at z 0 while the piece slid away).
  _V drawnPositionOf(_Obj obj) {
    final pos = positionOf(obj);
    final onCloth = obj != _Obj.scissors && step > dragStep(obj);
    return onCloth ? pos + _V(0, 0, clothShift) : pos;
  }

  /// Step of Scenario 1 on which [obj] is dragged.
  static int dragStep(_Obj obj) => switch (obj) {
    _Obj.rod1 => 1,
    _Obj.rod2 => 2,
    _Obj.scissors => 3,
  };

  void moveCamera(_V toEye, _V toTarget, double duration) {
    eyeTween = _Tween(eye, toEye, time, duration, _cubicOut);
    targetTween = _Tween(target, toTarget, time, duration, _cubicOut);
  }

  /// HTML `changeScenario(id)`: every object back to its start, camera
  /// reset (`resetCamera()`), counter hidden.
  void load(int index) {
    scenario = index;
    step = 1;
    view = index == 0 ? _View.tailor : _View.highway;
    eye = index == 0 ? _camTailor : _camHighway;
    target = index == 0 ? _tgtTailor : _tgtHighway;
    eyeTween = targetTween = null;

    rod1 = rod2 = scissors = _itemHome;
    rod1Tween = rod2Tween = scissorsTween = null;
    rod1Visible = true;
    rod2Visible = false;
    scissorsVisible = false;
    bladeOpen = _bladeOpenAngle;
    bladeTween = null;
    chalk1 = chalk2 = cut = false;
    clothShift = 0;
    clothTween = null;
    blocks = 0;

    tabletop = false;
    toolVisible = false;
    tool = _toolSpot;
    toolTween = null;
    beamStart = -1;
    countStart = -1;
    pulsed = false;
    coin = _coinHome;
    coinTween = null;
    mmGlow = false;
    stackVisible = false;
    stack = _stackHome;
    stackTween = null;

    dragging = null;
    dragOffset = _V.zero;
  }

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    final now = time;
    if (eyeTween case final t?) {
      eye = t.at(now);
      if (t.isDone(now)) eyeTween = null;
    }
    if (targetTween case final t?) {
      target = t.at(now);
      if (t.isDone(now)) targetTween = null;
    }
    if (rod1Tween case final t?) {
      rod1 = t.at(now);
      if (t.isDone(now)) rod1Tween = null;
    }
    if (rod2Tween case final t?) {
      rod2 = t.at(now);
      if (t.isDone(now)) rod2Tween = null;
    }
    if (scissorsTween case final t?) {
      scissors = t.at(now);
      if (t.isDone(now)) scissorsTween = null;
    }
    if (bladeTween case final t?) {
      bladeOpen = t.at(now);
      if (t.isDone(now)) bladeTween = null;
    }
    if (clothTween case final t?) {
      clothShift = t.at(now);
      if (t.isDone(now)) clothTween = null;
    }
    if (toolTween case final t?) {
      tool = t.at(now);
      if (t.isDone(now)) toolTween = null;
    }
    if (coinTween case final t?) {
      coin = t.at(now);
      if (t.isDone(now)) coinTween = null;
    }
    if (stackTween case final t?) {
      stack = t.at(now);
      if (t.isDone(now)) stackTween = null;
    }
  }
}

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);

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

  /// Component-wise product (a box corner from its half size).
  _V scale(_V o) => _V(x * o.x, y * o.y, z * o.z);

  /// Three.js `rotation.y = a` applied to this vector.
  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (45° vertical field of view) at [eye] looking
/// at the OrbitControls target, projected onto the design stage.
@immutable
class _Proj {
  factory _Proj(_V eye, _V target) {
    final f = (target - eye).unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Proj._(eye, f, r, r.cross(f));
  }

  const _Proj._(this.eye, this.f, this.r, this.u);

  /// 280 / tan(22.5°): the 45° fov over the 560 px stage height.
  static const double focal = 675.96;
  static const Offset center = Offset(500, 280);

  /// Near plane (Three.js camera near is 0.1); faces are clipped to it.
  static const double near = 0.2;

  final _V eye;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(near, depth(w));

  bool inFront(_V w) => depth(w) > near;

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(near, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray direction through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray crosses the horizontal plane y = [py] (drag plane).
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the axis-aligned box centred at [c].
  Rect bounds(_V c, _V half) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final o = p(
        _V(
          c.x + (i & 1 == 0 ? -half.x : half.x),
          c.y + (i & 2 == 0 ? -half.y : half.y),
          c.z + (i & 4 == 0 ? -half.z : half.z),
        ),
      );
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
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

/// Key light direction (HTML DirectionalLight at (10, 20, 15)).
const _V _light = _V(0.3714, 0.7428, 0.5571);
const _V _up = _V(0, 1, 0);

/// Box faces: outward normal, then the bottom-left, bottom-right and
/// top-left corners of the face (Three.js BoxGeometry UVs), in units of the
/// half size.
const List<(_V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(1, 1, -1)),
];

/// Label chip padding (HTML `px-3 py-1.5`, at the 12 px label size).
const double _labelPadX = 10, _labelPadY = 4;

/// Highway sign face text box (3.1 × 1.2 inner panel, 100 px per unit).
const double _signTexW = 310, _signTexH = 120, _signFont = 64;

/// Ruler digits: drawn at this size, then scaled to 0.32 world units.
const double _digitFont = 40, _digitWorld = 0.32;

/// Paints the HTML Three.js scenes: the tailor's table (Scenario 1), the
/// highway and the tabletop ruler (Scenario 2), then the object labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
  final Path _path = Path();
  final Path _pathB = Path();
  final Path _pathC = Path();
  final List<_V> _poly = [];
  final List<Offset> _pts = [];
  final Float64List _matrix = Float64List(16);

  late Canvas _c;
  late _Proj _p;

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(labBleed(size), _fill);
    if (scene.scenario == 0) {
      _paintTailor();
    } else if (scene.tabletop) {
      _paintTabletop();
    } else {
      _paintHighway();
    }
    if (showLabels) _paintLabels();
  }

  // ------------------------------------------------------------ scenario 1

  void _paintTailor() {
    final s = scene;
    for (final (x, z) in _legSpots) {
      _cylinder(
        _V(x, _legBottom, z),
        _up,
        _legR,
        _legR,
        _legLen,
        _Colors.amber950,
      );
    }
    _box(_tableC, _tableHalf, _Colors.yellow800);
    _boxShadow(_toolboxC, _toolboxHalf);
    _shadowHull([
      for (final z in const [-_clothHalfZ, _clothHalfZ])
        for (final y in const [0.0, 2 * _rollR]) ...[
          _p.p(_onFloor(_V(_rollC.x - _rollR, y, z), 0)),
          _p.p(_onFloor(_V(_rollC.x + _rollR, y, z), 0)),
        ],
    ], 0.3);

    // Fabric: one sheet until it is cut, then the stub on the roll and the
    // 2 m piece sliding forward.
    final dz = s.clothShift;
    if (!s.cut) {
      _clothSheet(_clothLeft, _clothRight, 0);
    } else {
      _clothSheet(_clothLeft, _cutX, 0);
      _clothSheet(_cutX, _clothRight, dz);
    }
    if (s.chalk1) {
      _box(_V(_mark1X, _chalkY, dz), _chalkHalf, _Colors.yellow200, edge: 0);
    }
    if (s.chalk2) {
      _box(_V(_cutX, _chalkY, dz), _chalkHalf, _Colors.yellow200, edge: 0);
    }
    if (s.blocks >= _cmPerMetre) _cubes(_mark1X, dz);
    if (s.blocks >= 2 * _cmPerMetre) _cubes(_cutX, dz);

    // Roll (cylinder along z) with the rolled layers on its end.
    final rollBase = _V(_rollC.x, _rollC.y, -_clothHalfZ);
    _cylinder(
      rollBase,
      const _V(0, 0, 1),
      _rollR,
      _rollR,
      2 * _clothHalfZ,
      _Colors.blue600,
      sheen: 0.35,
    );
    _stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.blue600, -0.45).withValues(alpha: 0.7);
    for (final k in const [0.35, 0.6, 0.85]) {
      _ring(
        _V(_rollC.x, _rollC.y, _clothHalfZ + 0.001),
        const _V(0, 0, 1),
        _rollR * k,
      );
      _c.drawPath(_path, _stroke);
    }

    _box(_toolboxC, _toolboxHalf, _Colors.red800);

    // Rods and scissors, far ones first; the carried one on top.
    final items = <_Obj>[
      if (s.rod1Visible) _Obj.rod1,
      if (s.rod2Visible) _Obj.rod2,
      if (s.scissorsVisible) _Obj.scissors,
    ]..remove(s.dragging);
    items.sort(
      (a, b) => _p
          .depth(s.drawnPositionOf(b))
          .compareTo(_p.depth(s.drawnPositionOf(a))),
    );
    for (final obj in items) {
      _item(obj);
    }
    if (s.dragging case final obj?) _item(obj);
  }

  void _clothSheet(double x0, double x1, double dz) => _box(
    _V((x0 + x1) / 2, _clothY, dz),
    _V((x1 - x0) / 2, _clothHalfY, _clothHalfZ),
    _Colors.blue600,
    edge: 0.3,
  );

  /// Breathing highlight of the item the current step asks for while it is
  /// still at the toolbox (HTML: `position.x > 3`).
  double _glowOf(_Obj obj) {
    final s = scene;
    if (s.scenario != 0 || s.step != _Scene.dragStep(obj)) return 0;
    if (s.positionOf(obj).x <= 3) return 0;
    return (math.sin(s.time * _glowRate) * 0.5 + 0.5) * _glowMax;
  }

  void _item(_Obj obj) {
    final s = scene;
    final pos = s.drawnPositionOf(obj);
    final carried = s.dragging == obj;
    final overToolbox =
        (pos.x - _toolboxC.x).abs() < _toolboxHalf.x &&
        (pos.z - _toolboxC.z).abs() < _toolboxHalf.z;
    final glow = _glowOf(obj);
    if (obj == _Obj.scissors) {
      if (carried && !overToolbox) _boxShadow(pos, _scissorsHit * 0.6);
      if (glow > 0) {
        _halo(_p.bounds(pos, _scissorsHit * 0.8), _Colors.orange500, glow);
      }
      _scissors(pos, s.bladeOpen, glow);
      return;
    }
    if (carried && !overToolbox) _boxShadow(pos, _rodHalf);
    if (glow > 0) _halo(_p.bounds(pos, _rodHalf), _Colors.blue500, glow);
    _box(
      pos,
      _rodHalf,
      Color.lerp(_Colors.slate200, _Colors.blue500, glow * 0.6)!,
      edge: 0.4,
    );
  }

  /// HTML tailor scissors: two blades with cone tips, orange ring handles
  /// and a brass screw, opened by ±[open] about the screw.
  void _scissors(_V pos, double open, double glow) {
    final blade = Color.lerp(_Colors.slate100, _Colors.orange500, glow * 0.35)!;
    final handle = Color.lerp(
      _Colors.orange500,
      _Colors.zslYellow,
      glow * 0.5,
    )!;
    // Lower half (half2, y −0.03) first.
    for (final (sx, yaw, dy) in [(1.0, -open, -0.03), (-1.0, open, 0.0)]) {
      _V at(_V local) => pos + _V(local.x, local.y + dy, local.z).rotY(yaw);
      _box(
        at(const _V(0, 0, -0.6)),
        const _V(0.06, 0.02, 0.55),
        blade,
        yaw: yaw,
        edge: 0.5,
      );
      _poly
        ..clear()
        ..add(at(const _V(-0.06, 0.02, -1.15)))
        ..add(at(const _V(0.06, 0.02, -1.15)))
        ..add(at(const _V(0, 0.02, -1.42)));
      if (_polygon(_poly, _path)) {
        _fill
          ..shader = null
          ..color = _lit(blade, _up);
        _c.drawPath(_path, _fill);
      }
      _box(
        at(_V(sx * 0.08, 0, 0.15)),
        const _V(0.06, 0.02, 0.15),
        handle,
        yaw: yaw - sx * 0.2,
        edge: 0.4,
      );
      // Ring handle (torus r 0.22, tube 0.06) lying flat.
      final ringC = at(_V(sx * 0.25, 0, 0.5));
      _ring(ringC, _up, 0.22);
      _stroke
        ..strokeWidth = math.max(1.5, 0.12 * _p.scaleAt(ringC))
        ..color = _lit(handle, _up);
      _c.drawPath(_path, _stroke);
    }
    _ring(pos + const _V(0, 0.05, 0), _up, 0.08);
    _fill
      ..shader = null
      ..color = _Colors.zslYellow;
    _c.drawPath(_path, _fill);
  }

  /// HTML centimetre cubes: 100 cubes 0.038 wide every 0.04 from [x0] (one
  /// metre), every fifth one darker; tops and fronts drawn in three paths.
  /// They lie on the cut piece, [dz] forward (the HTML left them at z 0).
  void _cubes(double x0, double dz) {
    _path.reset();
    _pathB.reset();
    _pathC.reset();
    const yTop = _cmY + _cmHalfY, yBot = _cmY - _cmHalfY;
    for (var i = 0; i < _cmPerMetre; i++) {
      final xa = x0 + i * _cmPitch + (_cmPitch - _cmWidth) / 2;
      final xb = xa + _cmWidth;
      _addQuad(
        i % 5 == 0 ? _path : _pathB,
        _V(xa, yTop, dz + _cmHalfZ),
        _V(xb, yTop, dz + _cmHalfZ),
        _V(xb, yTop, dz - _cmHalfZ),
        _V(xa, yTop, dz - _cmHalfZ),
      );
      _addQuad(
        _pathC,
        _V(xa, yBot, dz + _cmHalfZ),
        _V(xb, yBot, dz + _cmHalfZ),
        _V(xb, yTop, dz + _cmHalfZ),
        _V(xa, yTop, dz + _cmHalfZ),
      );
    }
    _fill
      ..shader = null
      ..color = _lit(_Colors.yellow200, const _V(0, 0, 1));
    _c.drawPath(_pathC, _fill);
    _fill.color = _lit(_Colors.zslYellow, _up);
    _c.drawPath(_path, _fill);
    _fill.color = _lit(_Colors.yellow200, _up);
    _c.drawPath(_pathB, _fill);
  }

  // --------------------------------------------------- scenario 2: highway

  void _paintHighway() {
    final s = scene;
    _box(
      const _V(0, -0.3, 0),
      const _V(18, 0.2, 9),
      _Colors.green700,
      edge: 0.2,
    );
    _box(
      const _V(0, -0.05, 0),
      const _V(14, 0.1, 3.5),
      _Colors.slate800,
      edge: 0.2,
    );
    for (final z in const [-3.2, 3.2]) {
      _box(_V(0, 0, z), const _V(14, 0.11, 0.125), _Colors.slate50, edge: 0);
    }
    for (var x = -12.0; x <= 12; x += 3) {
      _box(_V(x, 0, 0), const _V(0.8, 0.11, 0.15), _Colors.yellow400, edge: 0);
    }
    // Start (0 m) and end of the 1 km segment, across the road.
    for (final x in const [_kmStartX, _kmEndX]) {
      _box(_V(x, 0, 0), const _V(0.1, 0.115, 3.3), _Colors.slate50, edge: 0);
    }

    // Roadside sign: pole, green board with a white frame and "1 km".
    _cylinder(
      const _V(_kmStartX, 0, -4.5),
      _up,
      0.12,
      0.12,
      4,
      _Colors.slate400,
      sheen: 0.5,
    );
    _box(
      const _V(_kmStartX, 3.5, -4.4),
      const _V(1.75, 0.8, 0.1),
      _Colors.green800,
    );
    _flatRect(const _V(_kmStartX, 3.5, -4.29), 1.65, 0.7, _Colors.white);
    _flatRect(const _V(_kmStartX, 3.5, -4.28), 1.55, 0.6, _Colors.green800);
    _faceText(
      texts.get(
        labTr(_i18n, lang, 'sign_km'),
        size: _signFont,
        color: _Colors.white,
        weight: FontWeight.w800,
      ),
      _p.p(const _V(_kmStartX - 1.55, 4.1, -4.27)),
      _p.p(const _V(_kmStartX + 1.55, 4.1, -4.27)),
      _p.p(const _V(_kmStartX - 1.55, 2.9, -4.27)),
      _signTexW,
      _signTexH,
    );

    // Laser pulse (HTML: scale.x 0.01 → 1 while position.x −12 → 0).
    if (s.beamStart >= 0) {
      final t = ((s.time - s.beamStart) / _beamTime).clamp(0.0, 1.0);
      final half = (_kmEndX - _kmStartX) / 2;
      final mid = _kmStartX + half * t;
      final w = half * (0.01 + 0.99 * t);
      final a = _p.p(_V(mid - w, _beamY, _beamZ));
      final b = _p.p(_V(mid + w, _beamY, _beamZ));
      _glow.color = _Colors.laser.withValues(alpha: 0.55);
      _glow.strokeWidth = 8;
      _glow.style = PaintingStyle.stroke;
      _c.drawLine(a, b, _glow);
      _box(
        _V(mid, _beamY, _beamZ),
        _V(w, _beamHalf, _beamHalf),
        _Colors.laser.withValues(alpha: 0.9),
        edge: 0,
      );
    }

    // Metre-Counter: base, body and the cyan lens facing down the road.
    if (s.toolVisible) {
      final t = s.tool;
      _boxShadow(t + const _V(0, 0.6, 0), const _V(0.9, 0.6, 0.9), floor: 0.05);
      _cylinder(t, _up, 1.0, 0.8, 0.4, _Colors.slate700, sheen: 0.45);
      _box(t + const _V(0, 0.8, 0), const _V(0.6, 0.4, 0.6), _Colors.sky500);
      _cylinder(
        t + const _V(0.6, 0.8, 0),
        const _V(1, 0, 0),
        0.3,
        0.3,
        0.1,
        _Colors.laser,
        sheen: 0.2,
      );
    }
  }

  // -------------------------------------------------- scenario 2: tabletop

  void _paintTabletop() {
    final s = scene;
    _box(
      const _V(0, -0.2, 0),
      const _V(10, 0.2, 7),
      _Colors.slate600,
      edge: 0.2,
    );
    _box(_rulerC, _rulerHalf, _Colors.yellow200, edge: 0.4);

    // Ticks every millimetre (cm ticks dark, the 1 cm tick blue).
    _path.reset();
    _pathB.reset();
    for (var i = 0; i <= _rulerMm; i++) {
      if (i == 10) continue;
      final cm = i % 10 == 0;
      _tick(
        cm ? _path : _pathB,
        i,
        cm ? _cmTick : (i % 5 == 0 ? _halfCmTick : _mmTick),
      );
    }
    _fill
      ..shader = null
      ..color = _Colors.slate900;
    _c.drawPath(_path, _fill);
    _fill.color = _Colors.slate600;
    _c.drawPath(_pathB, _fill);
    _oneCmTick();

    // Centimetre numbers 0 … 15 in front of the long ticks.
    for (var cm = 0; cm <= _rulerMm ~/ 10; cm++) {
      final at = _V(_zeroX + cm, _rulerTop + 0.01, _tickBack + _cmTick + 0.3);
      if (!_p.inFront(at)) continue;
      final o = _p.p(at);
      if (o.dx < -200 || o.dx > 1200 || o.dy < -200 || o.dy > 800) continue;
      final tp = texts.get(
        '$cm',
        size: _digitFont,
        color: _Colors.slate900,
        weight: FontWeight.w700,
      );
      final k = _digitWorld * _p.scaleAt(at) / _digitFont;
      _c
        ..save()
        ..translate(o.dx, o.dy)
        ..scale(k, k);
      tp.paint(_c, Offset(-tp.width / 2, -tp.height / 2));
      _c.restore();
    }

    // Coin and stack, far one first.
    final coinFirst = _p.depth(s.coin) > _p.depth(s.stack);
    if (coinFirst) _coin(s.coin, 1);
    if (s.stackVisible) _coin(s.stack, _stackCoins);
    if (!coinFirst) _coin(s.coin, 1);

    // Readings drawn over the coins: the green 2 mm bar (HTML mm2Glow) and,
    // with the stack, the 1 cm tick.
    if (s.mmGlow) {
      final c = _V(_zeroX + 2 * _mm, 0.08, -1.3);
      _halo(_p.bounds(c, const _V(0.04, 0.09, 0.4)), _Colors.green500, 0.7);
      _box(c, const _V(0.04, 0.09, 0.4), _Colors.green500, edge: 0);
    }
    if (s.stackVisible) _oneCmTick();
  }

  /// Top face of millimetre tick [i] (length [len] from the back edge),
  /// added to [path]. Ticks partly behind the camera are skipped.
  void _tick(Path path, int i, double len) {
    final x = _zeroX + i * _mm;
    final a = _V(x - _tickHalfW, _tickTop, _tickBack + len);
    final b = _V(x + _tickHalfW, _tickTop, _tickBack + len);
    final c = _V(x + _tickHalfW, _tickTop, _tickBack);
    final d = _V(x - _tickHalfW, _tickTop, _tickBack);
    if (!_p.inFront(a) || !_p.inFront(b) || !_p.inFront(c) || !_p.inFront(d)) {
      return;
    }
    _addQuad(path, a, b, c, d);
  }

  /// The 1 cm tick in blue (the HTML meant `i === 10` to be highlighted).
  void _oneCmTick() {
    _path.reset();
    _tick(_path, 10, _cmTick);
    _fill
      ..shader = null
      ..color = _Colors.blue600;
    _c.drawPath(_path, _fill);
  }

  /// [count] coins standing on their rims side by side along x, centred at
  /// [c] (HTML CylinderGeometry(0.7, 0.7, 0.2), silver).
  void _coin(_V c, int count) {
    final x0 = c.x - count * _coinT / 2;
    // Coins nearer the camera along x are drawn last.
    final ascending = _p.eye.x > c.x;
    for (var k = 0; k < count; k++) {
      final i = ascending ? k : count - 1 - k;
      final base = _V(x0 + i * _coinT, c.y, c.z);
      final tone = i.isEven ? _Colors.slate200 : _Colors.slate300;
      if (!_cylinder(
        base,
        const _V(1, 0, 0),
        _coinR,
        _coinR,
        _coinT,
        tone,
        sheen: 0.6,
      )) {
        continue;
      }
      // Raised rim on the face that shows.
      final face = _p.eye.x > base.x ? base + const _V(_coinT, 0, 0) : base;
      _ring(face, const _V(1, 0, 0), _coinR * 0.8);
      _stroke
        ..strokeWidth = 1.2
        ..color = labShade(tone, -0.35);
      _c.drawPath(_path, _stroke);
    }
  }

  // ---------------------------------------------------------------- labels

  /// HTML `#canvas-labels` chips (bottom-centre on the anchor point), plus
  /// the chalk-mark and 0 m chips.
  void _paintLabels() {
    final s = scene;
    if (s.scenario == 0) {
      // On the roll itself (the HTML anchored it at the cloth centre, where
      // the rods are laid).
      _label('lbl_cloth', _V(_rollC.x, _rollC.y + _rollR + 0.05, 0));
      if (s.rod1Visible) {
        _label('lbl_rod', s.drawnPositionOf(_Obj.rod1) + const _V(0, 0.6, 0));
      }
      final front = _clothHalfZ + s.clothShift + 0.2;
      if (s.chalk1) {
        _label('lbl_chalk_1', _V(_mark1X, _clothTop, front), below: true);
      }
      if (s.chalk2) {
        _label('lbl_chalk_2', _V(_cutX, _clothTop, front), below: true);
      }
    } else if (!s.tabletop) {
      _label('lbl_road', const _V(0, 2.2, 0));
      _label('lbl_start', const _V(_kmStartX, 0.15, 0));
    } else {
      // In front of the ruler (the HTML put it above the zero mark, where
      // the coins stand).
      _label('lbl_ruler', const _V(0, _rulerTop, 2.2));
    }
  }

  void _label(String key, _V at, {bool below = false}) {
    if (!_p.inFront(at)) return;
    final k = labelScale;
    final tp = texts.get(
      labTr(_i18n, lang, key),
      size: 12 * k,
      color: palette.labelText,
      weight: FontWeight.w800,
      letterSpacing: 0.3,
    );
    final o = _p.p(at);
    final w = tp.width + 2 * _labelPadX * k, h = tp.height + 2 * _labelPadY * k;
    final rect = Rect.fromLTWH(o.dx - w / 2, below ? o.dy : o.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * k));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = palette.accent.withValues(alpha: 0.5);
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k));
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.75 + directional 1.2, toned down to keep the colours).
  Color _lit(Color c, _V n) {
    final i = 0.62 + 0.5 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Builds [path] from the world polygon in [pts], clipped to the camera's
  /// near plane (big boxes reach behind the zoomed tabletop cameras). False
  /// when less than a triangle is left.
  bool _polygon(List<_V> pts, Path path) {
    path.reset();
    var count = 0;
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final a = pts[i], b = pts[(i + 1) % n];
      final da = _p.depth(a) - _Proj.near, db = _p.depth(b) - _Proj.near;
      for (final w in [
        if (da >= 0) a,
        if ((da >= 0) != (db >= 0)) _V.lerp(a, b, da / (da - db)),
      ]) {
        final o = _p.p(w);
        if (count++ == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
    }
    if (count < 3) return false;
    path.close();
    return true;
  }

  /// Adds the projected quad a-b-c-d to [path] (no clipping: callers make
  /// sure the points are in front of the camera).
  void _addQuad(Path path, _V a, _V b, _V c, _V d) {
    final pa = _p.p(a), pb = _p.p(b), pc = _p.p(c), pd = _p.p(d);
    path
      ..moveTo(pa.dx, pa.dy)
      ..lineTo(pb.dx, pb.dy)
      ..lineTo(pc.dx, pc.dy)
      ..lineTo(pd.dx, pd.dy)
      ..close();
  }

  /// Box centred at [c] with half sizes [h], turned by [yaw]; only the faces
  /// that look at the camera are drawn.
  void _box(_V c, _V h, Color color, {double yaw = 0, double edge = 0.35}) {
    for (final (n, bl, br, tl) in _boxFaces) {
      final normal = n.rotY(yaw);
      _V corner(_V k) => c + k.scale(h).rotY(yaw);
      if (normal.dot(_p.eye - corner(n)) <= 0) continue;
      _poly
        ..clear()
        ..add(corner(bl))
        ..add(corner(br))
        ..add(corner(br + tl - bl))
        ..add(corner(tl));
      if (!_polygon(_poly, _path)) continue;
      _fill
        ..shader = null
        ..color = _lit(color, normal);
      _c.drawPath(_path, _fill);
      if (edge > 0) {
        _stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: edge * color.a);
        _c.drawPath(_path, _stroke);
      }
    }
  }

  /// Flat rectangle facing +z, centred at [c] (half sizes [hx], [hy]).
  void _flatRect(_V c, double hx, double hy, Color color) {
    _poly
      ..clear()
      ..add(c + _V(-hx, -hy, 0))
      ..add(c + _V(hx, -hy, 0))
      ..add(c + _V(hx, hy, 0))
      ..add(c + _V(-hx, hy, 0));
    if (!_polygon(_poly, _path)) return;
    _fill
      ..shader = null
      ..color = _lit(color, const _V(0, 0, 1));
    _c.drawPath(_path, _fill);
  }

  (_V, _V) _ringAxes(_V axis) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : _up;
    final a1 = axis.cross(helper).unit;
    return (a1, axis.cross(a1).unit);
  }

  /// [_path] = circle of radius [r] around [c] in the plane normal to
  /// [axis] (handles, rims, rolled layers).
  void _ring(_V c, _V axis, double r) {
    final (a1, a2) = _ringAxes(axis);
    _path.reset();
    for (var i = 0; i <= 24; i++) {
      final angle = i * math.pi / 12;
      final o = _p.p(c + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
  }

  /// Cylinder (or frustum: radius [r0] at [base], [r1] at the far end) along
  /// unit [axis]: lit side silhouette and the cap facing the camera. Skipped
  /// (false) when any part is behind the camera.
  bool _cylinder(
    _V base,
    _V axis,
    double r0,
    double r1,
    double len,
    Color color, {
    double sheen = 0.3,
  }) {
    final (a1, a2) = _ringAxes(axis);
    final top = base + axis * len;
    _pts.clear();
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final dir = a1 * math.cos(angle) + a2 * math.sin(angle);
      final b = base + dir * r0, t = top + dir * r1;
      if (!_p.inFront(b) || !_p.inFront(t)) return false;
      _pts
        ..add(_p.p(b))
        ..add(_p.p(t));
    }
    final hull = _hull(_pts);
    if (hull.length < 3) return false;
    final mid = base + axis * (len / 2);
    final pm = _p.p(mid), along = _p.p(top) - _p.p(base);
    final l = along.distance;
    final perp = l < 0.001
        ? const Offset(1, 0)
        : Offset(-along.dy / l, along.dx / l);
    final half = math.max(r0, r1) * _p.scaleAt(mid) * 1.1;
    Color shade(double k) => labShade(color, k).withValues(alpha: color.a);
    _fill.shader = ui.Gradient.linear(
      pm - perp * half,
      pm + perp * half,
      [shade(-0.4), shade(sheen), shade(0), shade(-0.45)],
      const [0, 0.35, 0.62, 1],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    _c.drawPath(_path, _fill);
    _fill.shader = null;

    final topCap = axis.dot(_p.eye - top) > 0;
    final bottomCap = (axis * -1).dot(_p.eye - base) > 0;
    if (!topCap && !bottomCap) return true;
    _ring(topCap ? top : base, axis, topCap ? r1 : r0);
    _fill.color = labShade(color, 0.22).withValues(alpha: color.a);
    _c.drawPath(_path, _fill);
    return true;
  }

  /// Draws [tp] centred on a face whose texture corners project to [tl],
  /// [tr] and [bl] (affine mapping of a [texW] × [texH] texture).
  void _faceText(
    TextPainter tp,
    Offset tl,
    Offset tr,
    Offset bl,
    double texW,
    double texH,
  ) {
    final ax = (tr - tl) / texW, ay = (bl - tl) / texH;
    final area = (ax.dx * ay.dy - ax.dy * ay.dx).abs() * texW * texH;
    if (area < 40) return; // seen edge-on
    _matrix
      ..fillRange(0, 16, 0)
      ..[0] = ax.dx
      ..[1] = ax.dy
      ..[4] = ay.dx
      ..[5] = ay.dy
      ..[10] = 1
      ..[12] = tl.dx
      ..[13] = tl.dy
      ..[15] = 1;
    _c
      ..save()
      ..transform(_matrix);
    tp.paint(_c, Offset((texW - tp.width) / 2, (texH - tp.height) / 2));
    _c.restore();
  }

  /// Soft coloured glow behind [r] (HTML emissive highlight).
  void _halo(Rect r, Color color, double strength) {
    _glow
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: (strength * 1.2).clamp(0.0, 1.0));
    _c.drawRRect(
      RRect.fromRectAndRadius(r.inflate(9), const Radius.circular(10)),
      _glow,
    );
  }

  /// Where the key light casts [w] onto the plane y = [floor].
  _V _onFloor(_V w, double floor) {
    final h = w.y - floor;
    return _V(
      w.x - h * _light.x / _light.y,
      floor + 0.01,
      w.z - h * _light.z / _light.y,
    );
  }

  /// Soft shadow of a box on the floor.
  void _boxShadow(_V c, _V h, {double floor = 0}) {
    _pts.clear();
    for (var i = 0; i < 8; i++) {
      final corner = _V(
        c.x + (i & 1 == 0 ? -h.x : h.x),
        c.y + (i & 2 == 0 ? -h.y : h.y),
        c.z + (i & 4 == 0 ? -h.z : h.z),
      );
      _pts.add(_p.p(_onFloor(corner, floor)));
    }
    _shadowHull(_pts, 0.3);
  }

  void _shadowHull(List<Offset> pts, double opacity) {
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _shadow.color = LabInk.black.withValues(alpha: opacity);
    _c.drawPath(_path, _shadow);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// TextPainters for the canvas text, laid out once and reused every frame.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final key = '$text|$size|${color.toARGB32()}|${weight.value}';
    return _painters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            letterSpacing: labLetterSpacing(text, letterSpacing),
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
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
