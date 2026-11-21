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

/// Class 6 Science • Chapter 5 • Activity 3
/// Accurate Measurement Techniques with Standard Scales.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A3-Accurate_Measurement_Techniques_with_Standard_Scales.html`.
/// The Three.js bench is redrawn by a CustomPainter through a perspective
/// projection of the same camera (fov 45°, same positions).
///
/// Scenario 1 (The Wandering Eye): a pencil lies along a 15-cm scale with its
/// tip at the 8.4 cm mark. Move the eye to Position A (left), C (right) and B
/// (directly above the mark): the magnifier shows the apparent reading 8.3,
/// 8.5 and 8.4 cm, so only the perpendicular view is correct (parallax error).
///
/// Scenario 2 (The Broken Scale Challenge): the zero end of the scale is
/// chipped. Align the crayon at the broken zero (unreliable start), then at
/// the clean 1.0 cm mark, and compute its true length 10.4 − 1.0 = 9.4 cm.
class Ch5A3AccurateMeasurementTechniquesWithStandardScalesPage
    extends StatefulWidget {
  const Ch5A3AccurateMeasurementTechniquesWithStandardScalesPage({super.key});

  @override
  State<Ch5A3AccurateMeasurementTechniquesWithStandardScalesPage>
  createState() => _Ch5A3PageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML synthesises two tones with the Web
/// Audio API: 'pop' (a short 400 → 800 Hz chirp on every button, the
/// curtain, scenario change and sidebar toggle) and 'success' (a C–E–G
/// arpeggio for the correct answer and the conclusion). They map to
/// pop.mp3 and success.mp3; error.mp3 marks the error toasts and
/// correct.mp3 the shell's own "Scenario Complete" toast.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// success → `math/success.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('success')`.
  success('audio/class6/math/success.mp3'),

  /// Shell feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// Error toast (an action done out of order, a wrong answer).
  wrong('audio/class6/science/error.mp3');

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
  /// ZSL yellow (`zsl.yellow`): Enter Lab, labels, magnifier ring.
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color yellow400 = Color(0xFFFACC15); // pencil body
  static const Color amber600 = Color(0xFFD97706); // sharpened wood
  static const Color teal300 = Color(0xFF5EEAD4); // object label text
  static const Color teal500 = Color(0xFF14B8A6); // selected eye / 1.0 cm
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E); // crayon, broken-0 button
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // eye iris
  static const Color indigo600 = Color(0xFF4F46E5); // answer buttons
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // correct sight line
  static const Color green600 = Color(0xFF16A34A);
  static const Color red500 = Color(0xFFEF4444); // parallax sight line
  static const Color slate50 = Color(0xFFF8FAFC); // scale face
  static const Color slate100 = Color(0xFFF1F5F9); // scale sides (S1)
  static const Color slate200 = Color(0xFFE2E8F0); // scale sides (S2)
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569); // chipped zero end
  static const Color slate700 = Color(0xFF334155); // lab table
  static const Color slate800 = Color(0xFF1E293B); // pencil lead
  static const Color slate900 = Color(0xFF0F172A); // graduations, pupil
  static const Color slate950 = Color(0xFF020617); // dark canvas
  static const Color white = Color(0xFFFFFFFF);

  /// Scene label chips and magnifier (`bg-slate-950/90`, `bg-slate-900/90`).
  static const Color labelBg = Color(0xE6020617);
  static const Color magnifierBg = Color(0xE60F172A);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: Color(0xF2020617), // sidebar dark:bg-slate-950/95
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate600,
    canvasBg: _Colors.slate950, // dark:bg-[#020617]
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600, // popup buttons bg-indigo-600
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate800, // dark:bg-slate-800
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: Color(0xF2020617), // bg-slate-950/95
    toastText: _Colors.zslYellow, // text-zsl-yellow
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66134E4A), // from-teal-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100, // --bg-primary #f1f5f9
    panel: Color(0xF2F8FAFC), // sidebar bg-slate-50
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate200, // bg-slate-200
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // completed steps (text-green-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xF2020617),
    toastText: _Colors.zslYellow,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66134E4A),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting in px (HTML `--sidebar-font-size`: 15 px, slider
/// 12–22 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The
/// HTML plays its 'pop' for the curtain, scenario change and sidebar too.
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
// From the HTML `i18n` / `ScenariosData` tables (Telugu dropped). Changes:
// * step actions say "TAP the '…' button" (touch) instead of naming the
//   HTML's top action bar; S1 step 4 and S2 step 4 say the conclusion opens
//   by itself (the HTML opens it 1.5 s after the step is reached);
// * S2 step 3 asks for the correct answer from three choices (the HTML's
//   only button was the answer itself, '9.4 cm');
// * the HUD lines (sN_hud_M) say 'Tap' and lose "at the top bar";
// * S2 observation 4 no longer claims "any damaged instrument";
// * strings marked "added" were hard-coded English in the HTML (toasts,
//   canvas labels, the magnifier) or are new (tables, error toasts).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Accurate Measurement Techniques with Standard Scales',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1_title': 'Scenario 1: The Wandering Eye: Avoiding Parallax Error',
    'scen_2_title': 'Scenario 2: The Broken Scale Challenge',
    'scen_1_obj':
        'To understand how the viewing angle affects measurement accuracy and learn the correct perpendicular eye position for reading a scale.',
    'scen_2_obj':
        "To master taking accurate length measurements when a ruler's zero graduation is broken, chipped, or frayed.",
    // Scenario 1 steps.
    's1_c1':
        "Parallax Error occurs when the observer's line of sight is not perpendicular to the scale graduation.",
    's1_a1': "TAP the 'Position A (Left)' button.",
    's1_o1':
        'Viewing obliquely from the left shifts the apparent reading to 8.3 cm instead of the true 8.4 cm mark! A red X warning indicates error.',
    's1_c2':
        'Viewing obliquely from the opposite side flips the optical error in the reverse direction.',
    's1_a2': "TAP the 'Position C (Right)' button.",
    's1_o2':
        'Now the object tip appears falsely aligned with 8.5 cm. This optical displacement is Parallax Error.',
    's1_c3':
        'Always place your eye directly above the scale graduation where measurement is taken.',
    's1_a3':
        "TAP the 'Position B (Center)' button to place the eye directly above the mark.",
    's1_o3':
        'Perpendicular line of sight shows the exact true reading of 8.4 cm. Green checkmark confirms accuracy.',
    's1_c4':
        'Standard measurement protocols require perpendicular line of sight to eliminate human error.',
    's1_a4':
        'COMPARE the three readings in the Apparent Readings table (you may tap A, B and C again). The conclusion opens by itself.',
    's1_o4':
        'The physical pencil never moves; only optical perspective causes the shift. Always view vertically!',
    's1_msg':
        'Viewing a scale obliquely shifts the apparent reading, causing Parallax Error. Always place your line of sight vertically directly above the scale graduation mark for accurate measurements.',
    // Scenario 2 steps.
    's2_c1':
        'Using a broken or worn-out zero end leads to uncertain and inaccurate initial alignment.',
    's2_a1': "TAP the 'Align at Broken 0' button.",
    's2_o1':
        'The crayon aligns against the jagged chipped end. Starting point is unclear, making reliable reading impossible.',
    's2_c2':
        'Aligning the object against a clear integer mark like 1.0 cm eliminates initial zero uncertainty.',
    's2_a2': "TAP the 'Align at 1.0 cm Mark' button.",
    's2_o2':
        'The crayon cleanly snaps with its left edge at exactly 1.0 cm and right edge at 10.4 cm mark.',
    's2_c3':
        'True length is calculated by subtracting initial starting reading from final reading.',
    's2_a3':
        'COMPUTE the subtraction 10.4 cm - 1.0 cm and TAP the correct answer.',
    's2_o3':
        'Subtracting the 1.0 cm offset gives the true crayon length: exactly 9.4 cm!',
    's2_c4':
        'Universal calibration formula: True Length = Final Reading - Initial Reading.',
    's2_a4':
        'REVIEW the subtraction rule: True Length = Final Reading - Initial Reading. The conclusion opens by itself.',
    's2_o4':
        'You can reliably measure with a scale whose zero end is damaged by using this subtraction rule.',
    's2_msg':
        "When a ruler's zero graduation is chipped or frayed, align the object at a clean integer mark (like 1.0 cm) and subtract the initial offset from the final reading to determine true length.",
    // HUD ("Current Task").
    's1_hud_1':
        "Step 1: Tap 'Position A (Left)' to observe the false reading from the left oblique angle.",
    's1_hud_2':
        "Step 2: Tap 'Position C (Right)' to observe the false reading flipped to the right.",
    's1_hud_3':
        "Step 3: Tap 'Position B (Center)' directly above the 8.4 cm mark to get the accurate reading.",
    's1_hud_4':
        'Step 4: Compare all positions. Notice how oblique angles shift apparent alignment (Parallax Error).',
    's2_hud_1':
        "Step 1: Tap 'Align at Broken 0' to see why frayed edges cause unreliable measurements.",
    's2_hud_2':
        "Step 2: Tap 'Align at 1.0 cm Mark' to start measuring from a clean integer graduation.",
    's2_hud_3':
        'Step 3: Compute Final Reading (10.4 cm) - Initial Reading (1.0 cm) and tap the correct answer.',
    's2_hud_4':
        'Step 4: Calibration verified! True Length = Final Reading - Initial Reading.',
    // Buttons and their captions.
    'eye_angle': 'Eye Angle:',
    'btn_pos_a': 'Position A (Left)',
    'btn_pos_b': 'Position B (Center)',
    'btn_pos_c': 'Position C (Right)',
    'broken_step': 'Damaged Zero Alignment:',
    'btn_align_0': 'Align at Broken 0',
    'btn_align_1': 'Align at 1.0 cm Mark',
    'ans_9_4': '9.4 cm',
    'ans_10_4': '10.4 cm',
    'ans_11_4': '11.4 cm',
    'math_q': '10.4 - 1.0 = ?',
    'math_done': '10.4 - 1.0 = 9.4 cm',
    'math_rule': 'True Length = Final - Initial', // added
    // Toasts (added: hard-coded English in the HTML).
    'toast_eye_left': 'Eye Angle: LEFT',
    'toast_eye_center': 'Eye Angle: CENTER',
    'toast_eye_right': 'Eye Angle: RIGHT',
    'toast_frayed': 'Frayed Zero: Unreliable Start!',
    'toast_aligned': 'Aligned at Clean 1.0 cm Mark!',
    'toast_verified': 'Verified! True Length = 10.4 - 1.0 = 9.4 cm',
    'err_order': "First see the problem: tap 'Align at Broken 0'.",
    'err_compute':
        'Not quite! Subtract: Final Reading (10.4 cm) - Initial Reading (1.0 cm).',
    // Canvas labels and magnifier.
    'lbl_ruler': 'Standard 15-cm Scale',
    'lbl_object': 'Object Tip (8.4 cm mark)',
    'lbl_broken': 'Chipped / Damaged Zero End',
    'lbl_crayon': 'Crayon', // added
    'lbl_tip_broken': 'Tip (9.4 cm? Unreliable!)',
    'lbl_tip_aligned': 'Aligned Tip (10.4 cm mark)',
    'apparent_reading': 'Apparent Reading',
    'status_correct': 'Correct (Perpendicular)!',
    'status_error': 'Parallax Error!',
    // Sidebar.
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
    'obs_pending': 'The observation appears once you complete this step.',
    'tbl_readings': 'Apparent Readings', // added
    'col_position': 'Eye Position',
    'col_reading': 'Apparent Reading',
    'tbl_measure': 'Measurement Record', // added
    'col_method': 'Alignment',
    'col_result': 'Reading',
    'row_broken': 'At broken 0',
    'row_one': 'At 1.0 cm mark',
    'row_length': 'True length (10.4 - 1.0)',
    'val_unclear': 'Start unclear',
    'val_one': '1.0 cm to 10.4 cm',
    'pending': '—',
    // Conclusion popups.
    'popup_sc1_title': 'Success!',
    'popup_sc2_title': 'Success!',
  },
  'hi': {
    'app_title': 'मानक पैमानों से सटीक मापन की तकनीकें',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1_title': 'परिदृश्य 1: लंबन त्रुटि से बचना',
    'scen_2_title': 'परिदृश्य 2: टूटे पैमाने की चुनौती',
    'scen_1_obj':
        'यह समझना कि देखने का कोण मापन सटीकता को कैसे प्रभावित करता है और सही लंबवत दृष्टि सीखना।',
    'scen_2_obj':
        'पैमाने का शून्य सिरा टूटा होने पर सही लंबाई ज्ञात करने की विधि सीखना।',
    's1_c1':
        'लंबन त्रुटि तब होती है जब दृष्टि रेखा पैमाने के निशान पर लंबवत नहीं होती।',
    's1_a1': "'स्थिति A (बायां)' बटन दबाएँ।",
    's1_o1':
        'बाईं ओर से देखने पर पेंसिल का सिरा सही 8.4 cm के बजाय 8.3 cm पर प्रतीत होता है! लाल X त्रुटि दर्शाता है।',
    's1_c2': 'विपरीत दिशा से तिरछा देखने पर त्रुटि दूसरी ओर पलट जाती है।',
    's1_a2': "'स्थिति C (दायां)' बटन दबाएँ।",
    's1_o2':
        'अब सिरा 8.5 cm पर प्रतीत होता है। यह दृष्टि का भ्रम लंबन त्रुटि है।',
    's1_c3': 'हमेशा अपनी आंख मापे जाने वाले निशान के ठीक ऊपर लंबवत रखें।',
    's1_a3': "आंख को निशान के ठीक ऊपर लाने के लिए 'स्थिति B (मध्य)' बटन दबाएँ।",
    's1_o3':
        'लंबवत दृष्टि सही 8.4 cm पाठ्यांक दिखाती है। हरा सही निशान सटीकता की पुष्टि करता है।',
    's1_c4': 'मानक मापन नियमों के अनुसार लंबवत देखना अनिवार्य है।',
    's1_a4':
        'प्रतीत पाठ्यांक तालिका में तीनों पाठ्यांकों की तुलना करें (आप A, B और C फिर से दबा सकते हैं)। निष्कर्ष अपने आप खुलेगा।',
    's1_o4':
        'पेंसिल अपनी जगह से नहीं हिलती, केवल दृष्टि कोण बदलने से त्रुटि होती है।',
    's1_msg':
        'पैमाने को तिरछे देखने पर पाठ्यांक विस्थापित प्रतीत होता है, जिससे लंबन त्रुटि होती है। सटीक मापन के लिए दृष्टि रेखा हमेशा पैमाने के निशान के ठीक ऊपर (लंबवत) होनी चाहिए।',
    's2_c1':
        'टूटे या घिसे हुए शून्य सिरे का उपयोग करने से मापन अनिश्चित हो जाता है।',
    's2_a1': "'टूटे शून्य पर रखें' बटन दबाएँ।",
    's2_o1':
        'क्रेयॉन टूटे सिरे पर सट जाता है। प्रारंभिक बिंदु स्पष्ट न होने से सही माप असंभव है।',
    's2_c2':
        '1.0 cm जैसे स्पष्ट निशान से शुरुआत करने पर शून्य की अनिश्चितता समाप्त हो जाती है।',
    's2_a2': "'1.0 cm निशान पर रखें' बटन दबाएँ।",
    's2_o2':
        'क्रेयॉन का बायां सिरा ठीक 1.0 cm और दायां सिरा 10.4 cm निशान पर संरेखित होता है।',
    's2_c3':
        'वास्तविक लंबाई अंतिम पाठ्यांक में से प्रारंभिक पाठ्यांक घटाकर प्राप्त होती है।',
    's2_a3': 'घटाव 10.4 cm - 1.0 cm की गणना करें और सही उत्तर वाला बटन दबाएँ।',
    's2_o3': '1.0 cm घटाने पर क्रेयॉन की सही लंबाई 9.4 cm प्राप्त होती है!',
    's2_c4':
        'सार्वभौमिक सूत्र: वास्तविक लंबाई = अंतिम पाठ्यांक - प्रारंभिक पाठ्यांक।',
    's2_a4':
        'घटाव का नियम दोहराएँ: वास्तविक लंबाई = अंतिम पाठ्यांक - प्रारंभिक पाठ्यांक। निष्कर्ष अपने आप खुलेगा।',
    's2_o4':
        'इस घटाव नियम से टूटे शून्य सिरे वाले पैमाने से भी सटीक मापन किया जा सकता है।',
    's2_msg':
        'जब पैमाने का शून्य सिरा टूटा या घिसा हो, तो किसी स्पष्ट निशान (जैसे 1.0 cm) से मापना और अंतिम पाठ्यांक में से प्रारंभिक पाठ्यांक घटाना पूर्ण सटीकता सुनिश्चित करता है।',
    's1_hud_1':
        "चरण 1: बाईं ओर से गलत पाठ्यांक देखने के लिए 'स्थिति A (बायां)' दबाएँ।",
    's1_hud_2':
        "चरण 2: दाईं ओर से त्रुटि देखने के लिए 'स्थिति C (दायां)' दबाएँ।",
    's1_hud_3':
        "चरण 3: सटीक 8.4 cm माप पाने के लिए ठीक ऊपर 'स्थिति B (मध्य)' दबाएँ।",
    's1_hud_4':
        'चरण 4: तुलना करें। ध्यान दें कि तिरछी दृष्टि से मापन गलत (लंबन त्रुटि) क्यों होता है।',
    's2_hud_1':
        "चरण 1: टूटे सिरे से मापन की समस्या देखने के लिए 'टूटे शून्य पर रखें' दबाएँ।",
    's2_hud_2':
        "चरण 2: स्पष्ट 1.0 cm निशान से मापने के लिए '1.0 cm निशान पर रखें' दबाएँ।",
    's2_hud_3':
        'चरण 3: अंतिम पाठ्यांक (10.4 cm) - प्रारंभिक पाठ्यांक (1.0 cm) की गणना करें और सही उत्तर दबाएँ।',
    's2_hud_4':
        'चरण 4: सत्यापन सफल! वास्तविक लंबाई = अंतिम पाठ्यांक - प्रारंभिक पाठ्यांक।',
    'eye_angle': 'दृष्टि कोण:',
    'btn_pos_a': 'स्थिति A (बायां)',
    'btn_pos_b': 'स्थिति B (मध्य)',
    'btn_pos_c': 'स्थिति C (दायां)',
    'broken_step': 'क्षतिग्रस्त शून्य संरेखण:',
    'btn_align_0': 'टूटे शून्य पर रखें',
    'btn_align_1': '1.0 cm निशान पर रखें',
    'ans_9_4': '9.4 cm',
    'ans_10_4': '10.4 cm',
    'ans_11_4': '11.4 cm',
    'math_q': '10.4 - 1.0 = ?',
    'math_done': '10.4 - 1.0 = 9.4 cm',
    'math_rule': 'वास्तविक लंबाई = अंतिम - प्रारंभिक',
    'toast_eye_left': 'दृष्टि कोण: बायां',
    'toast_eye_center': 'दृष्टि कोण: मध्य',
    'toast_eye_right': 'दृष्टि कोण: दायां',
    'toast_frayed': 'घिसा हुआ शून्य: प्रारंभ बिंदु अविश्वसनीय!',
    'toast_aligned': 'स्पष्ट 1.0 cm निशान पर संरेखित!',
    'toast_verified': 'सत्यापित! वास्तविक लंबाई = 10.4 - 1.0 = 9.4 cm',
    'err_order': "पहले समस्या देखें: 'टूटे शून्य पर रखें' दबाएँ।",
    'err_compute':
        'सही नहीं! घटाएँ: अंतिम पाठ्यांक (10.4 cm) - प्रारंभिक पाठ्यांक (1.0 cm)।',
    'lbl_ruler': 'मानक 15-cm पैमाना',
    'lbl_object': 'वस्तु का सिरा (8.4 cm निशान)',
    'lbl_broken': 'टूटा / क्षतिग्रस्त शून्य सिरा',
    'lbl_crayon': 'क्रेयॉन',
    'lbl_tip_broken': 'सिरा (9.4 cm? अविश्वसनीय!)',
    'lbl_tip_aligned': 'संरेखित सिरा (10.4 cm निशान)',
    'apparent_reading': 'प्रतीत होने वाला पाठ्यांक',
    'status_correct': 'सही (लंबवत)!',
    'status_error': 'लंबन त्रुटि!',
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'obs_pending': 'यह चरण पूरा करने पर अवलोकन दिखेगा।',
    'tbl_readings': 'प्रतीत पाठ्यांक',
    'col_position': 'दृष्टि की स्थिति',
    'col_reading': 'प्रतीत पाठ्यांक',
    'tbl_measure': 'मापन रिकॉर्ड',
    'col_method': 'संरेखण',
    'col_result': 'पाठ्यांक',
    'row_broken': 'टूटे शून्य पर',
    'row_one': '1.0 cm निशान पर',
    'row_length': 'वास्तविक लंबाई (10.4 - 1.0)',
    'val_unclear': 'प्रारंभ अस्पष्ट',
    'val_one': '1.0 cm से 10.4 cm',
    'pending': '—',
    'popup_sc1_title': 'सफल!',
    'popup_sc2_title': 'सभी परिदृश्य पूर्ण!',
  },
};

/// Steps per scenario.
const int _stepCount = 4;
const int _scenarioCount = 2;

/// Scenarios and steps for [lang] (HTML `ScenariosData`: concept, action,
/// observation per step).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_title'),
        objective: t('scen_${n}_obj'),
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

final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

// World units: 1 unit = 1 cm, the HTML's own scale (its pencil is 8.4 units
// long, its crayon 9.4, its ruler 16 for a 15-cm scale). The HTML ruler
// texture drew 0 cm at x = −7.06 with 0.906 units per cm, so neither the
// pencil tip nor the crayon ends sat on the marks they were said to be at;
// here the 0 cm graduation is at x = −7.5, where both objects start.
const double _zeroX = -7.5;
double _cmX(double cm) => _zeroX + cm;

// The scale: BoxGeometry(16, 0.25, 2.6) at (0, 0.125, 0.5). Its graduations
// start at the back edge (the texture's top row maps to z = −0.8).
const _V _rulerCenter = _V(0, 0.125, 0.5);
const _V _rulerHalf = _V(8, 0.125, 1.3);
const double _rulerTop = 0.25;
const double _gradEdgeZ = -0.8;
const double _cmCount = 15;

/// Tick lengths and widths: texture 42 / 26 / 15 px of 128 over 2.6 units,
/// 3 px / 2 px of 1024 over 16 units.
const double _tickCm = 0.853, _tickHalf = 0.528, _tickMm = 0.305;
const double _tickCmWidth = 0.047, _tickMmWidth = 0.031;

/// Numbers: HTML 'bold 22px' with their top at texture y = 48 px; one layout
/// px is 2.6 / 128 world units.
const double _numberFont = 22;
const double _numberTopZ = 0.175;
const double _numberUnit = 0.0203;

/// Chipped zero end (S2): HTML jag `38 + sin(y) × 12` px for y = 0, 16 …
/// 128; here it runs about 0.4 cm into the scale, so the 0 mark and the
/// first half-centimetre of millimetre marks are broken off.
const double _jagX = -7.1;
const double _jagAmplitude = 0.12;
const int _jagPoints = 9;
const double _firstIntactMm = 6;

/// Lab table: BoxGeometry(26, 0.4, 14) at (0, −0.2, 0).
const _V _tableCenter = _V(0, -0.2, 0);
const _V _tableHalf = _V(13, 0.2, 7);

// Scenario 1: the pencil (hexagonal body r 0.28, sharpened cone, lead) lies
// behind the scale's graduated edge, its axis at y 0.28, z −1.2. The HTML
// body alone was 8.4 long with the tip beyond it; here body + cone + lead
// span 0 → 8.4 cm (body to 7.5, wood cone 7.5 → 8.3, lead 8.1 → 8.4).
const double _pencilY = 0.28, _pencilZ = -1.2, _pencilR = 0.28;
const double _pencilBodyEndCm = 7.5;
const double _pencilConeEndCm = 8.3;
const double _leadStartCm = 8.1, _leadR = 0.1;
const double _tipCm = 8.4;

/// Where the reading is taken: the graduated edge beside the pencil tip
/// (end of the HTML sight line).
final _V _readPoint = _V(_cmX(_tipCm), _rulerTop, _gradEdgeZ);

/// The observer's eye (HTML eyeGroup): a 0.65 sphere at y 6.5, z −0.3.
const double _eyeY = 6.5, _eyeZ = -0.3, _eyeR = 0.65;

/// HTML camera: (eyeX × 0.8, 9, 14) in S1 (tweened with the eye), (0, 10, 16)
/// in S2, fov 45°. The S1 camera looks at (0, 2.2, 0) instead of the origin:
/// at the origin the eye (y 6.5) was cut off at the top of the view.
const _V _camStart = _V(0, 10, 16);
const double _camEyeFactor = 0.8, _camY1 = 9, _camZ1 = 14;
const _V _lookS1 = _V(0, 2.2, 0);
const _V _camS2 = _V(0, 10, 16);
const _V _lookS2 = _V(0, 0, 0);

/// With the sidebar collapsed, the floating mission card covers the top
/// left of the stage: the camera then looks further left so the bench moves
/// right, clear of the card. In S2 it also looks higher, so the scale and
/// the crayon move down below the card, which is tall on step 3 (five
/// buttons); there is no HUD at the bottom while the sidebar is collapsed.
const _V _collapsedLookS1 = _V(-1.6, 0, 0);
const _V _collapsedLookS2 = _V(-1.6, 3.6, 0);

/// Rate (1/s) at which the view follows the sidebar state.
const double _lookFollowRate = 8;

/// HTML tweens: eye + camera 600 ms Cubic.Out, crayon 600 ms Back.Out.
const double _tweenS = 0.6;

/// HTML `setTimeout(validateInvestigation, 1500)` after the last step.
const Duration _reviewDelay = Duration(milliseconds: 1500);

/// Scenario 2 crayon: CylinderGeometry(0.35, 0.35, 9.4) along x at y 0.35.
/// It now starts beside the scale, not touching it (the HTML started it
/// already aligned at 1.0 cm with the '9.4 cm' answer showing).
const double _crayonR = 0.35, _crayonHalfLen = 4.7, _crayonY = 0.35;
const double _crayonAlignedZ = -1.2;
const _V _crayonStart = _V(-1.0, _crayonY, -2.9);

/// Crayon centre when its left end is at the broken 0 / the 1.0 cm mark.
const double _crayonBrokenX = -2.8, _crayonOneX = -1.8;

/// Magnifier ("Apparent Reading" inset) and the S2 equation box: anchored to
/// world points so they move with the bench; their radius / text scale with
/// the canvas labels, capped so they stay clear of the tool column.
const _V _magnifierAnchor = _V(5.9, 3.3, -0.3);
const double _magnifierRadius = 64;
const double _magnifierMaxScale = 1.25;
const _V _mathAnchor = _V(0.2, 3.0, -1.2);

/// Scale label on the scale's blank front strip (HTML: under its centre)
/// and the chipped-end label in front of the zero end (S2).
const _V _rulerLabelAt = _V(0, _rulerTop, 1.35);
const _V _brokenLabelAt = _V(-6.6, 0, 2.05);

/// The iris faces along the line of sight, turned this much towards the
/// viewer so it can be seen from the camera (1 = halfway).
const double _gazeTowardsViewer = 1.2;

/// Canvas label chips (HTML `px-3 py-1.5`, 12 px extrabold).
const double _chipFont = 12, _chipPadX = 9, _chipPadY = 4.5;

/// The pencil-tip label ends this far (design px, plus a part that grows
/// with the label scale) left of the tip, and sits this high (world units)
/// above the pencil.
const double _tipLabelGap = 16, _tipLabelGapPerScale = 14;
const double _tipLabelLift = 0.25;

/// The control card on the canvas needs this much screen height to fit
/// above the bench (smaller screens use the sidebar / mission card).
const double _controlCardMinHeight = 360;

/// Eye positions (HTML `setEyeAngle`): x of the eye, the apparent reading
/// the magnifier shows, the button, the toast and the step that asks for it.
enum _Eye {
  left(-2.5, 8.3, 'btn_pos_a', 'toast_eye_left', 1),
  center(0.9, 8.4, 'btn_pos_b', 'toast_eye_center', 3),
  right(4.3, 8.5, 'btn_pos_c', 'toast_eye_right', 2);

  const _Eye(this.x, this.reading, this.button, this.toast, this.step);

  final double x;
  final double reading;
  final String button;
  final String toast;
  final int step;

  bool get correct => this == center;
}

/// Where the crayon is (HTML `brokenAlign`, plus "not yet placed").
enum _Align { none, broken, one }

/// Answer choices for S2 step 3 (the HTML had only the answer, '9.4 cm').
enum _Answer {
  a94('ans_9_4', correct: true),
  a104('ans_10_4'),
  a114('ans_11_4');

  const _Answer(this.key, {this.correct = false});
  final String key;
  final bool correct;
}

// tween.js easing functions (exact, not Flutter's bezier approximations).
typedef _Ease = double Function(double t);

double _cubicOut(double k) {
  final u = 1 - k;
  return 1 - u * u * u;
}

double _backOut(double k) {
  const s = 1.70158;
  final t = k - 1;
  return t * t * ((s + 1) * t + s) + 1;
}

/// A TWEEN.js tween of a position.
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

/// A TWEEN.js tween of one number.
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
  _Scene() {
    load(0, now: 0);
  }

  double time = 0;
  int scenario = 0;

  /// 1-based step; [_stepCount] + 1 once the conclusion is open.
  int step = 1;

  // Camera position, look-at point and the sidebar-collapsed look offset.
  _V cam = _camStart;
  _Tween? camTween;
  _V look = _lookS1;
  _V lookOffset = _V.zero;

  // -------------------------------------------------- scenario 1
  _Eye eye = _Eye.center;

  /// False until a position button is pressed (the HTML shows every button
  /// unselected after a scenario change).
  bool eyeChosen = false;
  double eyeX = _Eye.center.x;
  _NumTween? eyeTween;
  final Set<_Eye> visited = {};
  bool s1Done = false;

  // -------------------------------------------------- scenario 2
  _Align align = _Align.none;
  _V crayon = _crayonStart;
  _NumTween? crayonXTween, crayonZTween;
  bool brokenTried = false;
  bool alignedOne = false;
  bool computed = false;

  /// Camera of the current scenario at the centre eye position (the
  /// magnifier keeps its place while the S1 camera follows the eye).
  _Proj get proj => _Proj(cam, look + lookOffset);
  _Proj get anchorProj => _Proj(
    scenario == 0 ? _V(_Eye.center.x * _camEyeFactor, _camY1, _camZ1) : _camS2,
    look + lookOffset,
  );

  /// HTML `changeScenario(id)`: everything back to its start, step 1.
  void load(int index, {required double now}) {
    scenario = index;
    step = 1;
    look = index == 0 ? _lookS1 : _lookS2;
    if (index == 0) {
      // HTML: the camera starts at (0, 10, 16) and glides to the centre eye.
      cam = _camStart;
      camTween = _Tween(
        _camStart,
        _V(_Eye.center.x * _camEyeFactor, _camY1, _camZ1),
        now,
        _tweenS,
        _cubicOut,
      );
    } else {
      cam = _camS2;
      camTween = null;
    }
    eye = _Eye.center;
    eyeChosen = false;
    eyeX = _Eye.center.x;
    eyeTween = null;
    visited.clear();
    s1Done = false;
    align = _Align.none;
    crayon = _crayonStart;
    crayonXTween = crayonZTween = null;
    brokenTried = false;
    alignedOne = false;
    computed = false;
  }

  /// HTML `setEyeAngle(ang)`: eye and camera glide over 600 ms.
  void moveEye(_Eye to) {
    eye = to;
    eyeChosen = true;
    eyeTween = _NumTween(eyeX, to.x, time, _tweenS, _cubicOut);
    camTween = _Tween(
      cam,
      _V(to.x * _camEyeFactor, _camY1, _camZ1),
      time,
      _tweenS,
      _cubicOut,
    );
  }

  /// HTML `alignCrayon(mode)`: 600 ms Back.Out along x (and onto the scale).
  void moveCrayon(_Align to) {
    align = to;
    final x = to == _Align.broken ? _crayonBrokenX : _crayonOneX;
    crayonXTween = _NumTween(crayon.x, x, time, _tweenS, _backOut);
    crayonZTween = _NumTween(
      crayon.z,
      _crayonAlignedZ,
      time,
      _tweenS,
      _cubicOut,
    );
  }

  /// TWEEN.update() plus the view following the sidebar. True while
  /// anything moves.
  bool advance(double dt, {required bool sidebarOpen}) {
    final now = time;
    var moving = false;
    if (camTween case final t?) {
      cam = t.at(now);
      if (t.isDone(now)) camTween = null;
      moving = true;
    }
    if (eyeTween case final t?) {
      eyeX = t.at(now);
      if (t.isDone(now)) eyeTween = null;
      moving = true;
    }
    if (crayonXTween case final t?) {
      crayon = _V(t.at(now), crayon.y, crayon.z);
      if (t.isDone(now)) crayonXTween = null;
      moving = true;
    }
    if (crayonZTween case final t?) {
      crayon = _V(crayon.x, crayon.y, t.at(now));
      if (t.isDone(now)) crayonZTween = null;
      moving = true;
    }
    final goal = sidebarOpen
        ? _V.zero
        : (scenario == 0 ? _collapsedLookS1 : _collapsedLookS2);
    final gap = goal - lookOffset;
    if (gap.length > 0.002) {
      lookOffset = lookOffset + gap * math.min(1.0, dt * _lookFollowRate);
      moving = true;
    } else if (gap.length > 0) {
      lookOffset = goal;
      moving = true;
    }
    return moving;
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

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (45° vertical field of view) at [eye]
/// looking at [target], projected onto the design stage.
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

  final _V eye;
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

// ------------------------------------------------------------- page state

class _Ch5A3PageState
    extends State<Ch5A3AccurateMeasurementTechniquesWithStandardScalesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final _TextCache _text = _TextCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px) of the last layout.
  double _fit = 1;

  /// Accordion cards the learner opened or closed by hand (step numbers).
  final Set<int> _toggledSteps = {};

  /// The scene changed outside a running tween: repaint on the next tick.
  bool _dirty = true;

  /// Key, style and language of the lab's last toast: a language switch
  /// re-shows it translated (the shell keeps a toast's text as shown).
  String? _toastKey;
  String _toastText = '';
  bool _toastError = false;
  LabLang _toastLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_retranslateToast);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _lab.removeListener(_retranslateToast);
    _ticker.dispose();
    _frame.dispose();
    _text.dispose();
    _lab.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- animation

  /// HTML `animate()` + `TWEEN.update()`. Repaints only the canvas, and only
  /// while something moves.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = math.max(0.0, now - s.time);
    s.time = now;
    final moving = s.advance(dt, sidebarOpen: _lab.isSidebarOpen);
    if (moving || _dirty) {
      _dirty = false;
      _frame.value++;
    }
  }

  /// Every state change also redraws the canvas: the painter reads the
  /// mutable scene, so `shouldRepaint` cannot see it change.
  @override
  void setState(VoidCallback fn) {
    _dirty = true;
    super.setState(fn);
  }

  void _goToStep(int step) {
    _scene.step = step;
    _toggledSteps.clear();
  }

  // ------------------------------------------------------------------ toasts

  /// Shows the toast [key] in the current language. Normal toasts are
  /// silent (the button already played the HTML 'pop'); errors play the
  /// wrong tone.
  void _toast(String key, {bool error = false}) {
    _toastKey = key;
    _toastError = error;
    _toastLang = _lab.lang;
    _toastText = _t(key);
    _lab.showToast(_toastText, isError: error, sound: error);
  }

  /// After a language switch, the toast still on screen is shown again in
  /// the new language (silently, after the current frame).
  void _retranslateToast() {
    final key = _toastKey;
    if (key == null || _lab.lang == _toastLang) return;
    _toastLang = _lab.lang;
    final shown = _lab.toast;
    if (shown == null || shown.text != _toastText) return;
    final error = _toastError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _toastKey = key;
      _toastText = _t(key);
      _lab.showToast(_toastText, isError: error, sound: false);
    });
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` (also Restart Lab and Reset Lab).
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index, now: _scene.time);
      _toggledSteps.clear();
    });
    _lab.resetView(sound: false);
  }

  /// HTML `setEyeAngle(ang)`. The step ladder is the HTML's: A on step 1,
  /// C on step 2, B on step 3, or all three positions seen. Other presses
  /// still move the eye and update the magnifier.
  void _setEye(_Eye to) {
    final s = _scene;
    if (s.scenario != 0) return;
    setState(() {
      s
        ..moveEye(to)
        ..visited.add(to);
      if (!s.s1Done) {
        if (s.step == to.step) {
          _goToStep(s.step + 1);
        } else if (s.visited.length == _Eye.values.length) {
          _goToStep(_stepCount);
        }
      }
    });
    _toast(to.toast);
    if (s.step == _stepCount && !s.s1Done) {
      s.s1Done = true;
      _showConclusion();
    }
  }

  /// HTML `alignCrayon(0)`: the crayon against the chipped zero end.
  void _alignBroken() {
    final s = _scene;
    if (s.scenario != 1) return;
    setState(() {
      s
        ..moveCrayon(_Align.broken)
        ..brokenTried = true;
      // HTML: step 2, also back from step 3 (the equation is hidden again).
      if (!s.computed) _goToStep(2);
    });
    _toast('toast_frayed');
  }

  /// HTML `alignCrayon(1)`: the crayon from the clean 1.0 cm mark. On step 1
  /// the HTML jumped to step 3 and skipped the broken-zero observation; here
  /// it asks for that step first.
  void _alignOne() {
    final s = _scene;
    if (s.scenario != 1) return;
    if (!s.brokenTried) {
      _toast('err_order', error: true);
      return;
    }
    setState(() {
      s
        ..moveCrayon(_Align.one)
        ..alignedOne = true;
      if (!s.computed) _goToStep(3);
    });
    _toast('toast_aligned');
  }

  /// HTML `computeBroken()` for the correct answer; a wrong one explains the
  /// subtraction again.
  void _answer(_Answer a) {
    final s = _scene;
    if (s.scenario != 1 || s.step != 3 || s.computed) return;
    if (!a.correct) {
      _Sound.pop.play();
      _toast('err_compute', error: true);
      return;
    }
    _Sound.success.play();
    setState(() {
      s.computed = true;
      _goToStep(_stepCount);
    });
    _toast('toast_verified');
    _showConclusion();
  }

  /// HTML `validateInvestigation()` 1.5 s after the last step: the scenario
  /// title, its conclusion and the table of what was observed.
  void _showConclusion() {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: _reviewDelay,
      title: () => _t('popup_sc${sc + 1}_title'),
      heading: () => _t('scen_${sc + 1}_title'),
      body: () => _t('s${sc + 1}_msg'),
      extra: () => _RecordTable(
        rows: _rows(),
        headLeft: _t(sc == 0 ? 'col_position' : 'col_method'),
        headRight: _t(sc == 0 ? 'col_reading' : 'col_result'),
        fontScale: _lab.fontScale.clamp(0.9, 1.4),
      ),
    );
    _lab.after(_reviewDelay, () {
      if (!mounted || _scene.scenario != sc) return;
      setState(() => _goToStep(_stepCount + 1));
    });
  }

  void _toggleStep(int i) {
    _Sound.pop.play();
    setState(() {
      if (!_toggledSteps.remove(i)) _toggledSteps.add(i);
    });
  }

  // -------------------------------------------------------------------- UI

  /// Rows of the scenario's record table (only what was observed so far).
  List<_RecordRow> _rows() {
    final s = _scene;
    if (s.scenario == 0) {
      return [
        for (final e in [_Eye.left, _Eye.center, _Eye.right])
          s.visited.contains(e)
              ? _RecordRow(
                  label: _t(e.button),
                  value: '${e.reading.toStringAsFixed(1)} cm',
                  tone: e.correct ? _Tone.good : _Tone.bad,
                )
              : _RecordRow(label: _t(e.button), value: _t('pending')),
      ];
    }
    return [
      s.brokenTried
          ? _RecordRow(
              label: _t('row_broken'),
              value: _t('val_unclear'),
              tone: _Tone.bad,
            )
          : _RecordRow(label: _t('row_broken'), value: _t('pending')),
      s.alignedOne
          ? _RecordRow(
              label: _t('row_one'),
              value: _t('val_one'),
              tone: _Tone.neutral,
            )
          : _RecordRow(label: _t('row_one'), value: _t('pending')),
      s.computed
          ? _RecordRow(
              label: _t('row_length'),
              value: _t('ans_9_4'),
              tone: _Tone.good,
            )
          : _RecordRow(label: _t('row_length'), value: _t('pending')),
    ];
  }

  /// The HTML top action bar: eye positions (S1), the two alignments (S2)
  /// and, on S2 step 3, the answer choices.
  List<LabAction> _actions(LabPalette p) {
    final s = _scene;
    if (s.scenario == 0) {
      return [for (final e in _Eye.values) _eyeAction(p, e)];
    }
    return [..._alignActions(p), if (_answersShown) ..._answerActions()];
  }

  bool get _answersShown {
    final s = _scene;
    return s.scenario == 1 && s.step == 3 && s.alignedOne && !s.computed;
  }

  LabAction _eyeAction(LabPalette p, _Eye e) {
    final s = _scene;
    final selected = s.eyeChosen && s.eye == e;
    return LabAction(
      label: _t(e.button),
      icon: Icons.visibility,
      // HTML: selected bg-teal-500 text-slate-950; others slate.
      color: selected ? _Colors.teal500 : p.cardBorder,
      foreground: selected ? _Colors.slate950 : p.textStrong,
      // The button the current step asks for pulses.
      highlight: !s.s1Done && s.step == e.step,
      onTap: () => _setEye(e),
    );
  }

  List<LabAction> _alignActions(LabPalette p) {
    final s = _scene;
    final broken = s.align == _Align.broken;
    final one = s.align == _Align.one;
    return [
      LabAction(
        label: _t('btn_align_0'),
        icon: Icons.content_cut,
        // HTML rose: selected bg-rose-500 text-white; else rose tint.
        color: broken
            ? _Colors.rose500
            : _Colors.rose500.withValues(alpha: 0.2),
        foreground: broken ? _Colors.white : p.ink(_Colors.rose400),
        highlight: !s.computed && s.step == 1,
        onTap: _alignBroken,
      ),
      LabAction(
        label: _t('btn_align_1'),
        icon: Icons.straighten,
        // HTML teal: selected bg-teal-500 text-slate-950; else teal tint.
        color: one ? _Colors.teal500 : _Colors.teal500.withValues(alpha: 0.2),
        foreground: one ? _Colors.slate950 : p.ink(_Colors.teal300),
        highlight: !s.computed && s.step == 2,
        onTap: _alignOne,
      ),
    ];
  }

  /// The HTML math box button (bg-indigo-600, white text), now one of three.
  List<LabAction> _answerActions() => [
    for (final a in _Answer.values)
      LabAction(
        label: _t(a.key),
        icon: Icons.calculate,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        silent: true,
        onTap: () => _answer(a),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        final s = _scene;
        final sc = s.scenario;
        final p = _lab.palette;
        final scale = context.labScale;
        return LabShell(
          controller: _lab,
          icon: Icons.straighten,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          hud: _t('s${sc + 1}_hud_${s.step.clamp(1, _stepCount)}'),
          // The last task line no longer applies once the conclusion opens.
          showHud: s.step <= _stepCount,
          actions: _actions(p),
          sidebarExtraTitle: _t(sc == 0 ? 'tbl_readings' : 'tbl_measure'),
          sidebarExtra: _Notebook(
            rows: _rows(),
            headLeft: _t(sc == 0 ? 'col_position' : 'col_method'),
            headRight: _t(sc == 0 ? 'col_reading' : 'col_result'),
            steps: data.steps,
            currentStep: s.step,
            toggled: Set.of(_toggledSteps),
            onToggle: _toggleStep,
            t: _t,
            fontScale: _lab.fontScale,
          ),
          overlays: _overlays(context, p, scale),
          // HTML enterLab(): the bench is set up again, so the camera glides
          // to the eye as the curtain lifts.
          onEnterLab: () => _loadScenario(_scene.scenario),
          onReset: () => _loadScenario(0),
          stage: _stage(p),
        );
      },
    );
  }

  /// The HTML top action bar on the canvas while the sidebar is open: the
  /// buttons in a card at the top left (above the bench) and, on S2 step 3,
  /// the answer choices above the HUD. While the sidebar is collapsed the
  /// floating mission card carries the buttons.
  List<Widget> _overlays(BuildContext context, LabPalette p, double scale) {
    if (!_lab.isSidebarOpen || _lab.popup != null || !_lab.isLabActive) {
      return const [];
    }
    final inset = labOverlayInsets(context, _lab);
    final s = _scene;
    final roomy = MediaQuery.sizeOf(context).height >= _controlCardMinHeight;
    return [
      if (roomy)
        Positioned(
          left: inset.left,
          top: inset.top,
          child: _ControlCard(
            caption: _t(s.scenario == 0 ? 'eye_angle' : 'broken_step'),
            actions: s.scenario == 0
                ? [for (final e in _Eye.values) _eyeAction(p, e)]
                : _alignActions(p),
            palette: p,
            scale: scale,
          ),
        ),
      if (_answersShown)
        Positioned(
          left: inset.left,
          right: inset.right,
          bottom: inset.bottom + _answerRowLift * scale,
          child: Center(
            child: _AnswerRow(
              caption: _t('math_q'),
              actions: _answerActions(),
              palette: p,
              scale: scale,
            ),
          ),
        ),
    ];
  }

  Widget _stage(LabPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit > 0 ? fit : 1;
        // Canvas labels stay readable when the stage is scaled down.
        final labelScale = (0.85 / _fit).clamp(1.0, 1.8);
        return LabStage(
          designSize: _design,
          child: RepaintBoundary(
            child: CustomPaint(
              size: _design,
              painter: _ScenePainter(
                scene: _scene,
                text: _text,
                repaint: _frame,
                palette: p,
                showLabels: _lab.showLabels,
                lang: _lab.lang,
                labelScale: labelScale,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Height of the HUD chip plus a gap: the answer row sits above it.
const double _answerRowLift = 66;

// ------------------------------------------------------------ canvas cards

/// The HTML top action bar as a card on the canvas: caption and buttons in
/// a column (finger-sized, at least 48 dp each).
class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.caption,
    required this.actions,
    required this.palette,
    required this.scale,
  });

  final String caption;
  final List<LabAction> actions;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200 * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.all(8 * s),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final a in actions) ...[
                SizedBox(height: 6 * s),
                LabActionButton(action: a, scale: s, dense: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The HTML math box: the subtraction and the answer choices in one row.
class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.caption,
    required this.actions,
    required this.palette,
    required this.scale,
  });

  final String caption;
  final List<LabAction> actions;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
        borderColor: palette.accent.withValues(alpha: 0.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              caption,
              style: TextStyle(
                color: palette.accentInk,
                fontSize: 13 * s,
                fontWeight: FontWeight.w900,
              ),
            ),
            for (final a in actions) ...[
              SizedBox(width: 6 * s),
              LabActionButton(action: a, scale: s, expand: false, dense: true),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ sidebar extra

/// How a recorded reading reads: correct, wrong / unreliable, or plain.
enum _Tone { good, bad, neutral }

/// One row of the record table; a null [tone] means "not observed yet".
@immutable
class _RecordRow {
  const _RecordRow({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final _Tone? tone;
}

/// Sidebar extra: the scenario's record table and the HTML "Conceptual
/// Exploration" accordion (concept, action and, once the step is done,
/// its observation).
class _Notebook extends StatelessWidget {
  const _Notebook({
    required this.rows,
    required this.headLeft,
    required this.headRight,
    required this.steps,
    required this.currentStep,
    required this.toggled,
    required this.onToggle,
    required this.t,
    required this.fontScale,
  });

  final List<_RecordRow> rows;
  final String headLeft;
  final String headRight;
  final List<LabStep> steps;
  final int currentStep;
  final Set<int> toggled;
  final ValueChanged<int> onToggle;
  final String Function(String key) t;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecordTable(
          rows: rows,
          headLeft: headLeft,
          headRight: headRight,
          fontScale: fontScale,
        ),
        SizedBox(height: 14 * s),
        LabSectionLabel(
          t('concept_exp'),
          size: 10.5 * s,
          icon: Icons.format_list_numbered,
        ),
        SizedBox(height: 8 * s),
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 6 * s),
          _stepCard(p, s, f, i),
        ],
      ],
    );
  }

  /// One accordion card: past steps green with a check, the current one
  /// open, future ones greyed out and closed (HTML `updateTeacherBoard`).
  Widget _stepCard(LabPalette p, double s, double f, int i) {
    final past = i < currentStep;
    final current = i == currentStep;
    final future = i > currentStep;
    final open = !future && (current != toggled.contains(i));
    final tint = current ? p.accentInk : (past ? p.info : p.textMuted);
    final step = steps[i - 1];
    TextStyle body(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    TextStyle head(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.4,
    );
    // Future steps are dimmed (HTML opacity-50) through their colours.
    return Container(
      decoration: BoxDecoration(
        color: future ? p.card.withValues(alpha: p.card.a * 0.5) : p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? p.accent
              : (past ? p.info.withValues(alpha: 0.5) : p.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: future ? null : () => onToggle(i),
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
                                  ? p.info.withValues(alpha: 0.2)
                                  : p.cardBorder.withValues(alpha: 0.5)),
                        border: Border.all(color: current ? p.accent : tint),
                      ),
                      child: past
                          ? Icon(Icons.check, size: 13 * s, color: p.info)
                          : Text(
                              '$i',
                              style: TextStyle(
                                color: current ? p.onAccent : p.textMuted,
                                fontSize: 10.5 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        '${t('exploration')} $i',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tint,
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
                      color: p.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: EdgeInsets.fromLTRB(10 * s, 0, 10 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${t('concept_focus')}: ',
                          style: head(p.accentInk),
                        ),
                        TextSpan(text: step.concept),
                      ],
                    ),
                    style: body(p.text),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${t('action')}: ',
                          style: head(p.textStrong),
                        ),
                        TextSpan(text: step.action),
                      ],
                    ),
                    style: body(p.text),
                  ),
                  SizedBox(height: 6 * s),
                  // The observation is shown once it has been made (the
                  // HTML showed it before the learner acted).
                  if (past)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${t('observation')}: ',
                            style: head(p.textStrong),
                          ),
                          TextSpan(text: step.observation),
                        ],
                      ),
                      style: body(p.textMuted),
                    )
                  else
                    Text(
                      t('obs_pending'),
                      style: body(
                        p.textMuted,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The record table (sidebar and conclusion popup): what each eye position
/// or alignment showed.
class _RecordTable extends StatelessWidget {
  const _RecordTable({
    required this.rows,
    required this.headLeft,
    required this.headRight,
    required this.fontScale,
  });

  final List<_RecordRow> rows;
  final String headLeft;
  final String headRight;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.3,
    );
    TextStyle body(Color color, FontWeight weight) => TextStyle(
      color: color,
      fontSize: 11 * f,
      fontWeight: weight,
      height: 1.3,
    );
    Widget cell(Widget child) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
      child: child,
    );
    Widget value(_RecordRow r) {
      final tone = r.tone;
      if (tone == null) {
        return Text(r.value, style: body(p.textMuted, FontWeight.w500));
      }
      final color = switch (tone) {
        _Tone.good => p.success,
        _Tone.bad => p.ink(_Colors.rose500),
        _Tone.neutral => p.textStrong,
      };
      final icon = switch (tone) {
        _Tone.good => Icons.check_circle,
        _Tone.bad => Icons.cancel,
        _Tone.neutral => Icons.straighten,
      };
      return Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 4 * s),
                child: Icon(icon, size: 13 * f, color: color),
              ),
            ),
            TextSpan(text: r.value),
          ],
        ),
        style: body(color, FontWeight.w800),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.cardBorder),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.15), 1: FlexColumnWidth()},
        border: TableBorder(horizontalInside: BorderSide(color: p.cardBorder)),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: p.cardBorder.withValues(alpha: 0.35),
            ),
            children: [
              cell(Text(headLeft, style: head)),
              cell(Text(headRight, style: head)),
            ],
          ),
          for (final r in rows)
            TableRow(
              children: [
                cell(Text(r.label, style: body(p.text, FontWeight.w600))),
                cell(value(r)),
              ],
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (12, 25, 18)).
const _V _light = _V(0.3630, 0.7562, 0.5445);

/// Box faces: outward normal and four corners (in units of the half size),
/// listed so that edges 0→1 and 0→3 run along the face.
const List<(_V, _V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(1, -1, 1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(-1, 1, -1), _V(1, 1, -1)),
];

/// Paints the HTML Three.js scene: lab table, 15-cm scale (with a chipped
/// zero end in S2), pencil, eye and line of sight (S1), crayon (S2), the
/// floating labels, the "Apparent Reading" magnifier (S1) and the
/// subtraction box (S2).
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.text,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache text;
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
  final Path _path = Path();
  final Float64List _matrix = Float64List(16);

  /// Projected tick end points, refilled each frame (cm / half-cm ticks and
  /// millimetre ticks are drawn with their own widths).
  final Float32List _majorTicks = Float32List((_cmCount.toInt() * 2 + 1) * 4);
  final Float32List _minorTicks = Float32List(_cmCount.toInt() * 8 * 4);

  late Canvas _c;
  late _Proj _p;

  String _s(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(labBleed(size), _fill);
    _box(_tableCenter, _tableHalf, _Colors.slate700, edge: 0.2);
    if (scene.scenario == 0) {
      _paintScenario1();
    } else {
      _paintScenario2();
    }
    if (showLabels) _paintLabels();
    if (scene.scenario == 0) {
      _paintMagnifier();
    } else {
      _paintMathBox();
    }
  }

  // ------------------------------------------------------------ scenario 1

  void _paintScenario1() {
    _boxShadow(_rulerCenter, _rulerHalf);
    // The pencil lies behind the scale's graduated edge: drawn first, the
    // scale covers its lower side.
    _pencil();
    _ruler(broken: false);
    _sightLine();
    _eye();
  }

  /// HTML pencilGroup: hexagonal yellow body (CylinderGeometry, 6 sides),
  /// amber sharpened cone and dark lead.
  void _pencil() {
    final x0 = _cmX(0), x1 = _cmX(_pencilBodyEndCm);
    final eye = _p.eye;
    // Side faces between the hexagon corners k and k + 1 (corner 0 faces
    // +z, like the HTML cylinder turned onto its side).
    for (var k = 0; k < 6; k++) {
      final a0 = k * math.pi / 3, a1 = (k + 1) * math.pi / 3;
      final mid = (a0 + a1) / 2;
      final n = _V(0, math.sin(mid), math.cos(mid));
      final c0 = _V(0, _pencilY + _pencilR * math.sin(a0), _pencilZ);
      final c1 = _V(0, _pencilY + _pencilR * math.sin(a1), _pencilZ);
      final z0 = _pencilR * math.cos(a0), z1 = _pencilR * math.cos(a1);
      final centre = _V((x0 + x1) / 2, _pencilY, _pencilZ) + n * _pencilR;
      if (n.dot(eye - centre) <= 0) continue;
      _quad(
        _V(x0, c0.y, c0.z + z0),
        _V(x1, c0.y, c0.z + z0),
        _V(x1, c1.y, c1.z + z1),
        _V(x0, c1.y, c1.z + z1),
        _lit(_Colors.yellow400, n),
        edge: 0.35,
        edgeColor: _Colors.amber600,
      );
    }
    final tipBase = _V(x1, _pencilY, _pencilZ);
    _cone(
      tipBase,
      _V(_cmX(_pencilConeEndCm), _pencilY, _pencilZ),
      _pencilR,
      _Colors.amber600,
    );
    _cone(
      _V(_cmX(_leadStartCm), _pencilY, _pencilZ),
      _V(_cmX(_tipCm), _pencilY, _pencilZ),
      _leadR,
      _Colors.slate800,
    );
  }

  /// HTML sightLine: from the eye to the reading point; green when the eye
  /// is directly above it, red otherwise.
  void _sightLine() {
    final s = scene;
    final eye = _V(s.eyeX, _eyeY, _eyeZ);
    final dir = (_readPoint - eye).unit;
    final from = _p.p(eye + dir * _eyeR);
    final to = _p.p(_readPoint);
    final color = s.eye.correct ? _Colors.green500 : _Colors.red500;
    _stroke
      ..strokeWidth = 5
      ..color = color.withValues(alpha: 0.25);
    _c.drawLine(from, to, _stroke);
    _stroke
      ..strokeWidth = 2.4
      ..color = color;
    _c.drawLine(from, to, _stroke);
    _fill
      ..shader = null
      ..color = color;
    _c.drawCircle(to, 3.5, _fill);
  }

  /// HTML eyeGroup: white globe with an indigo iris and dark pupil. In the
  /// HTML the iris and pupil sat inside the globe and never showed; here
  /// they face along the line of sight, turned towards the viewer enough to
  /// be seen.
  void _eye() {
    final s = scene;
    final eye = _V(s.eyeX, _eyeY, _eyeZ);
    final o = _p.p(eye);
    final k = _p.scaleAt(eye);
    final radius = _eyeR * k;
    final view = (_p.eye - eye).unit;
    final sight = (_readPoint - eye).unit;
    final gaze = (sight + view * _gazeTowardsViewer).unit;
    // Lit globe: highlight towards the key light (up and to the right).
    final lightOnScreen = _p.p(eye + _light * _eyeR) - o;
    _fill.shader = ui.Gradient.radial(
      o + lightOnScreen * 0.45,
      radius * 1.25,
      const [_Colors.white, _Colors.slate100, _Colors.slate400],
      const [0, 0.5, 1],
    );
    _c.drawCircle(o, radius, _fill);
    _fill.shader = null;
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.slate500.withValues(alpha: 0.7);
    _c.drawCircle(o, radius, _stroke);

    final facing = gaze.dot(view);
    if (facing <= 0.05) return;
    final iris = _p.p(eye + gaze * _eyeR);
    final along = iris - o;
    final angle = along.distance < 0.5 ? 0.0 : along.direction;
    const irisR = 0.33, pupilR = 0.15;
    _c
      ..save()
      ..translate(iris.dx, iris.dy)
      ..rotate(angle);
    _fill.color = _Colors.indigo500;
    _c.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 2 * irisR * k * facing,
        height: 2 * irisR * k,
      ),
      _fill,
    );
    _fill.color = _Colors.slate900;
    _c.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 2 * pupilR * k * facing,
        height: 2 * pupilR * k,
      ),
      _fill,
    );
    _c.restore();
    _fill.color = _Colors.white.withValues(alpha: 0.85);
    _c.drawCircle(iris + lightOnScreen * 0.12, math.max(1.2, 0.05 * k), _fill);
  }

  // ------------------------------------------------------------ scenario 2

  void _paintScenario2() {
    final s = scene;
    _boxShadow(_rulerCenter, _rulerHalf);
    _crayonShadow(s.crayon);
    // The crayon is always behind the scale's back edge.
    _crayon(s.crayon);
    _ruler(broken: true);
  }

  /// HTML crayonMesh: rose CylinderGeometry(0.35, 0.35, 9.4) along x.
  void _crayon(_V c) {
    _cylinder(
      c - const _V(_crayonHalfLen, 0, 0),
      const _V(1, 0, 0),
      _crayonR,
      _crayonHalfLen * 2,
      _Colors.rose500,
    );
  }

  void _crayonShadow(_V c) {
    final pts = <Offset>[];
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final rim = _V(0, math.sin(a) * _crayonR, math.cos(a) * _crayonR);
      pts
        ..add(_p.p(_onTable(c + rim - const _V(_crayonHalfLen, 0, 0))))
        ..add(_p.p(_onTable(c + rim + const _V(_crayonHalfLen, 0, 0))));
    }
    _shadowHull(pts, 0.32);
  }

  // ---------------------------------------------------------------- scale

  /// The 15-cm scale (HTML createRulerTexture on a 16 × 0.25 × 2.6 box):
  /// cm marks with numbers, half-cm and mm marks from the back edge. The
  /// broken scale has its zero end chipped off.
  void _ruler({required bool broken}) {
    _box(
      _rulerCenter,
      _rulerHalf,
      broken ? _Colors.slate200 : _Colors.slate100,
      top: _Colors.slate50,
      edge: 0.25,
    );
    if (broken) _chippedEnd();
    var major = 0, minor = 0;
    for (var cm = 0; cm <= _cmCount; cm++) {
      final x = _cmX(cm.toDouble());
      if (!(broken && cm == 0)) {
        major = _tick(_majorTicks, major, x, _tickCm);
      }
      if (cm == _cmCount) break;
      for (var mm = 1; mm < 10; mm++) {
        if (broken && cm == 0 && mm < _firstIntactMm) continue;
        final mx = x + mm / 10;
        if (mm == 5) {
          major = _tick(_majorTicks, major, mx, _tickHalf);
        } else {
          minor = _tick(_minorTicks, minor, mx, _tickMm);
        }
      }
    }
    final k = _p.scaleAt(_readPoint);
    _stroke
      ..color = _Colors.slate900
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = math.max(1.2, _tickCmWidth * k);
    _c.drawRawPoints(
      ui.PointMode.lines,
      Float32List.sublistView(_majorTicks, 0, major),
      _stroke,
    );
    _stroke.strokeWidth = math.max(0.8, _tickMmWidth * k);
    _c.drawRawPoints(
      ui.PointMode.lines,
      Float32List.sublistView(_minorTicks, 0, minor),
      _stroke,
    );
    _stroke.strokeCap = StrokeCap.round;
    for (var cm = broken ? 1 : 0; cm <= _cmCount; cm++) {
      _rulerNumber(cm);
    }
  }

  /// Adds one tick (x, from the back edge, [length] long) to [list].
  int _tick(Float32List list, int at, double x, double length) {
    final a = _p.p(_V(x, _rulerTop, _gradEdgeZ));
    final b = _p.p(_V(x, _rulerTop, _gradEdgeZ + length));
    list[at] = a.dx;
    list[at + 1] = a.dy;
    list[at + 2] = b.dx;
    list[at + 3] = b.dy;
    return at + 4;
  }

  /// A centimetre number lying on the scale's face (affine mapping of the
  /// text onto the face, like the HTML canvas texture).
  void _rulerNumber(int cm) {
    final tp = text.get(
      '$cm',
      size: _numberFont,
      color: _Colors.slate900,
      weight: FontWeight.w800,
    );
    final anchor = _V(_cmX(cm.toDouble()), _rulerTop, _numberTopZ);
    final o = _p.p(anchor);
    final ax = _p.p(anchor + const _V(_numberUnit, 0, 0)) - o;
    final ay = _p.p(anchor + const _V(0, 0, _numberUnit)) - o;
    final tl = o - ax * (tp.width / 2);
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
    tp.paint(_c, Offset.zero);
    _c.restore();
  }

  /// HTML broken texture: a dark jagged patch over the zero end.
  void _chippedEnd() {
    _path.reset();
    final start = _p.p(_V(-_rulerHalf.x, _rulerTop, _gradEdgeZ));
    _path.moveTo(start.dx, start.dy);
    for (var i = 0; i < _jagPoints; i++) {
      // HTML: x = 38 + sin(y) × 12 for texture rows y = 0, 16 … 128.
      final z = _gradEdgeZ + i * (2 * _rulerHalf.z) / (_jagPoints - 1);
      final x = _jagX + math.sin(16.0 * i) * _jagAmplitude;
      final o = _p.p(_V(x, _rulerTop, z));
      _path.lineTo(o.dx, o.dy);
    }
    final end = _p.p(
      _V(-_rulerHalf.x, _rulerTop, _gradEdgeZ + 2 * _rulerHalf.z),
    );
    _path
      ..lineTo(end.dx, end.dy)
      ..close();
    _fill
      ..shader = null
      ..color = _Colors.slate600;
    _c.drawPath(_path, _fill);
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (ambient 0.85 +
  /// directional 0.8 in the HTML, toned down to keep colours).
  Color _lit(Color c, _V n) {
    final i = 0.58 + 0.55 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Box centred at [c] with half sizes [h]; [top] colours its top face.
  void _box(_V c, _V h, Color color, {Color? top, double edge = 0.35}) {
    _V corner(_V s) => c + _V(s.x * h.x, s.y * h.y, s.z * h.z);
    for (final (n, a, b, cc, d) in _boxFaces) {
      if (n.dot(_p.eye - corner(n)) <= 0) continue;
      final face = n.y > 0 && top != null ? top : color;
      _quad(
        corner(a),
        corner(b),
        corner(cc),
        corner(d),
        _lit(face, n),
        edge: edge,
        edgeColor: face,
      );
    }
  }

  /// A flat quad with an optional darker outline.
  void _quad(
    _V a,
    _V b,
    _V c,
    _V d,
    Color fill, {
    double edge = 0,
    Color? edgeColor,
  }) {
    final pa = _p.p(a), pb = _p.p(b), pc = _p.p(c), pd = _p.p(d);
    _path
      ..reset()
      ..moveTo(pa.dx, pa.dy)
      ..lineTo(pb.dx, pb.dy)
      ..lineTo(pc.dx, pc.dy)
      ..lineTo(pd.dx, pd.dy)
      ..close();
    _fill
      ..shader = null
      ..color = fill;
    _c.drawPath(_path, _fill);
    if (edge > 0) {
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(edgeColor ?? fill, -0.5).withValues(alpha: edge);
      _c.drawPath(_path, _stroke);
    }
  }

  (_V, _V) _ringAxes(_V axis) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : const _V(0, 1, 0);
    final a1 = axis.cross(helper).unit;
    return (a1, axis.cross(a1).unit);
  }

  /// Fill for a round body seen side-on: lit gradient across its axis.
  void _roundShader(_V mid, _V base, _V top, double r, Color color) {
    final pm = _p.p(mid), along = _p.p(top) - _p.p(base);
    final l = along.distance;
    final perp = l < 0.001
        ? const Offset(1, 0)
        : Offset(-along.dy / l, along.dx / l);
    final half = math.max(1.0, r * _p.scaleAt(mid) * 1.1);
    _fill.shader = ui.Gradient.linear(
      pm - perp * half,
      pm + perp * half,
      [
        labShade(color, -0.4),
        labShade(color, 0.3),
        color,
        labShade(color, -0.45),
      ],
      const [0, 0.35, 0.62, 1],
    );
  }

  /// Cylinder from [base] along unit [axis] (CylinderGeometry look): side
  /// silhouette with a lit gradient and the cap that faces the camera.
  void _cylinder(_V base, _V axis, double r, double len, Color color) {
    final (a1, a2) = _ringAxes(axis);
    final top = base + axis * len;
    final pts = <Offset>[];
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final rim = (a1 * math.cos(angle) + a2 * math.sin(angle)) * r;
      pts
        ..add(_p.p(base + rim))
        ..add(_p.p(top + rim));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _roundShader(base + axis * (len / 2), base, top, r, color);
    _path
      ..reset()
      ..addPolygon(hull, true);
    _c.drawPath(_path, _fill);
    _fill.shader = null;

    final capAt = axis.dot(_p.eye - top) > 0
        ? top
        : ((axis * -1).dot(_p.eye - base) > 0 ? base : null);
    if (capAt == null) return;
    _path.reset();
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final o = _p.p(capAt + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    _fill.color = labShade(color, 0.22);
    _c.drawPath(_path, _fill);
  }

  /// Cone (ConeGeometry) from a round [base] of radius [r] to [apex].
  void _cone(_V base, _V apex, double r, Color color) {
    final axis = (apex - base).unit;
    final (a1, a2) = _ringAxes(axis);
    final pts = <Offset>[_p.p(apex)];
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      pts.add(_p.p(base + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _roundShader(_V.lerp(base, apex, 0.35), base, apex, r * 0.7, color);
    _path
      ..reset()
      ..addPolygon(hull, true);
    _c.drawPath(_path, _fill);
    _fill.shader = null;
  }

  /// Where the key light casts point [w] onto the table (y = 0).
  _V _onTable(_V w) => _V(w.x - w.y * 12 / 25, 0.002, w.z - w.y * 18 / 25);

  /// Soft shadow of a box on the table (the HTML ruler casts one).
  void _boxShadow(_V c, _V h) {
    _shadowHull([
      for (var i = 0; i < 8; i++)
        _p.p(
          _onTable(
            c +
                _V(
                  i & 1 == 0 ? -h.x : h.x,
                  i & 2 == 0 ? -h.y : h.y,
                  i & 4 == 0 ? -h.z : h.z,
                ),
          ),
        ),
    ], 0.3);
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

  // ---------------------------------------------------------------- labels

  /// HTML floating labels (`lbl-ruler`, `lbl-object`), plus the chipped-end
  /// label the HTML defined but never showed.
  void _paintLabels() {
    final s = scene;
    // HTML: below the scale's centre; here on its blank front strip.
    _chip(
      'lbl_ruler',
      _p.p(_rulerLabelAt),
      Alignment.center,
      _Colors.zslYellow,
    );
    if (s.scenario == 0) {
      // Just above the pencil, ending a little left of its tip: clear of
      // the magnifier and of every line of sight (they all end at the tip;
      // the steepest from the left, from Position A, passes right of it).
      final above = _p.p(
        _V(_cmX(_tipCm), _pencilY + _pencilR + _tipLabelLift, _pencilZ),
      );
      _chip(
        'lbl_object',
        above - Offset(_tipLabelGap + _tipLabelGapPerScale * labelScale, 0),
        Alignment.bottomRight,
        _Colors.teal300,
      );
      return;
    }
    _chip(
      'lbl_broken',
      _p.p(_brokenLabelAt),
      Alignment.topCenter,
      _Colors.rose300,
    );
    final c = s.crayon;
    final (key, ink) = switch (s.align) {
      _Align.none => ('lbl_crayon', _Colors.teal300),
      _Align.broken => ('lbl_tip_broken', _Colors.rose300),
      _Align.one => ('lbl_tip_aligned', _Colors.teal300),
    };
    _chip(
      key,
      _p.p(_V(c.x + _crayonHalfLen, c.y + 0.5, c.z)),
      Alignment.bottomCenter,
      ink,
    );
  }

  /// A label chip (HTML: bg-slate-950/90, coloured text and border) placed
  /// with [anchor] on [at].
  void _chip(String key, Offset at, Alignment anchor, Color ink) {
    final k = labelScale;
    final label = _s(key);
    final tp = text.get(
      label,
      size: _chipFont * k,
      color: ink,
      weight: FontWeight.w800,
      letterSpacing: labLetterSpacing(label, 0.3),
    );
    final w = tp.width + 2 * _chipPadX * k, h = tp.height + 2 * _chipPadY * k;
    final rect = Rect.fromLTWH(
      at.dx - (anchor.x + 1) / 2 * w,
      at.dy - (anchor.y + 1) / 2 * h,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(7 * k));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.5);
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + _chipPadX * k, rect.top + _chipPadY * k));
  }

  // ------------------------------------------------------------- magnifier

  /// HTML `#magnifier-inset`: "Apparent Reading", the reading the eye sees
  /// and its status. A strip of millimetre marks shows where the pencil
  /// tip appears to point.
  void _paintMagnifier() {
    final s = scene;
    final m = math.min(labelScale, _magnifierMaxScale);
    final r = _magnifierRadius * m;
    final c = s.anchorProj.p(_magnifierAnchor);
    final eye = s.eye;
    final ok = eye.correct;
    _shadow.color = LabInk.black.withValues(alpha: 0.45);
    _c.drawCircle(c + Offset(0, 4 * m), r, _shadow);
    _fill
      ..shader = null
      ..color = _Colors.magnifierBg;
    _c.drawCircle(c, r, _fill);

    // Title (two lines at most).
    final title = _s('apparent_reading');
    final english = lang == LabLang.en;
    final titleTp = text.get(
      english ? title.toUpperCase() : title,
      size: 9.5 * m,
      color: _Colors.slate400,
      weight: FontWeight.w800,
      letterSpacing: labLetterSpacing(title, 0.6),
      maxWidth: 1.45 * r,
    );
    titleTp.paint(
      _c,
      Offset(c.dx - titleTp.width / 2, c.dy - 0.5 * r - titleTp.height / 2),
    );

    // Millimetre strip: 8.0 … 8.8 cm, the tip apparently at the reading.
    final y0 = c.dy - 0.22 * r;
    final half = 0.62 * r;
    final step = 2 * half / 8;
    _stroke
      ..color = _Colors.slate300
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = math.max(1, 1.2 * m);
    for (var i = 0; i <= 8; i++) {
      final x = c.dx - half + i * step;
      final len = (i == 0 || i == 5 || i == 8 ? 0.16 : 0.09) * r;
      _c.drawLine(Offset(x, y0), Offset(x, y0 + len), _stroke);
    }
    _stroke.strokeCap = StrokeCap.round;
    final tipX = c.dx - half + (eye.reading - 8.0) * 10 * step;
    final py = y0 + 0.24 * r, ph = 0.075 * r;
    final coneStart = tipX - 0.2 * r;
    _fill.color = _Colors.yellow400;
    _c.drawRect(
      Rect.fromLTRB(c.dx - 0.75 * r, py - ph, coneStart, py + ph),
      _fill,
    );
    _path
      ..reset()
      ..moveTo(coneStart, py - ph)
      ..lineTo(tipX, py)
      ..lineTo(coneStart, py + ph)
      ..close();
    _fill.color = _Colors.amber600;
    _c.drawPath(_path, _fill);
    _path
      ..reset()
      ..moveTo(tipX - 0.07 * r, py - ph * 0.35)
      ..lineTo(tipX, py)
      ..lineTo(tipX - 0.07 * r, py + ph * 0.35)
      ..close();
    _fill.color = _Colors.slate900;
    _c.drawPath(_path, _fill);
    // Guide line from the tip up to the mark it appears to touch.
    _stroke
      ..strokeWidth = math.max(1, m)
      ..color = (ok ? _Colors.green400 : _Colors.red500).withValues(alpha: 0.9);
    _c.drawLine(Offset(tipX, y0 - 0.04 * r), Offset(tipX, py - ph), _stroke);

    // Reading.
    final reading = text.get(
      '${eye.reading.toStringAsFixed(1)} cm',
      size: 22 * m,
      color: ok ? _Colors.green500 : _Colors.red500,
      weight: FontWeight.w900,
    );
    reading.paint(
      _c,
      Offset(c.dx - reading.width / 2, c.dy + 0.2 * r - reading.height / 2),
    );

    // Status: check / X icon and text.
    final status = text.get(
      _s(ok ? 'status_correct' : 'status_error'),
      size: 9 * m,
      color: ok ? _Colors.green400 : _Colors.rose400,
      weight: FontWeight.w800,
      maxWidth: 1.25 * r,
    );
    final iconR = 5.5 * m;
    final total = iconR * 2 + 4 * m + status.width;
    final sx = c.dx - total / 2;
    final sy = c.dy + 0.56 * r;
    _statusIcon(Offset(sx + iconR, sy), iconR, ok);
    status.paint(_c, Offset(sx + iconR * 2 + 4 * m, sy - status.height / 2));

    // Ring (HTML border-4 border-zsl-yellow).
    _stroke
      ..strokeWidth = 4 * m
      ..color = _Colors.zslYellow;
    _c.drawCircle(c, r, _stroke);
  }

  /// HTML `ph-check-circle` / `ph-x-circle`.
  void _statusIcon(Offset at, double r, bool ok) {
    final color = ok ? _Colors.green400 : _Colors.rose400;
    _stroke
      ..strokeWidth = math.max(1.2, r * 0.28)
      ..color = color;
    _c.drawCircle(at, r, _stroke);
    final q = r * 0.45;
    if (ok) {
      _path
        ..reset()
        ..moveTo(at.dx - q, at.dy)
        ..lineTo(at.dx - q * 0.2, at.dy + q * 0.75)
        ..lineTo(at.dx + q, at.dy - q * 0.6);
      _c.drawPath(_path, _stroke);
    } else {
      _c
        ..drawLine(at + Offset(-q, -q), at + Offset(q, q), _stroke)
        ..drawLine(at + Offset(-q, q), at + Offset(q, -q), _stroke);
    }
  }

  // -------------------------------------------------------------- math box

  /// HTML `#s2-math-box` "10.4 - 1.0 = ?" (shown from step 3 while the
  /// crayon is aligned at 1.0 cm), with the rule above it; once solved it
  /// shows the answer.
  void _paintMathBox() {
    final s = scene;
    if (!s.alignedOne || s.step < 3 || s.align != _Align.one) return;
    final m = math.min(labelScale, _magnifierMaxScale);
    final rule = text.get(
      _s('math_rule'),
      size: 10.5 * m,
      color: _Colors.slate300,
      weight: FontWeight.w700,
    );
    final sum = text.get(
      _s(s.computed ? 'math_done' : 'math_q'),
      size: 16 * m,
      color: _Colors.zslYellow,
      weight: FontWeight.w900,
    );
    final padX = 12 * m, padY = 7 * m, gap = 3 * m;
    final iconR = s.computed ? 7 * m : 0.0;
    final sumW = sum.width + (s.computed ? 2 * iconR + 6 * m : 0);
    final w = math.max(rule.width, sumW) + 2 * padX;
    final h = rule.height + gap + sum.height + 2 * padY;
    final at = s.anchorProj.p(_mathAnchor);
    final rect = Rect.fromLTWH(at.dx - w / 2, at.dy - h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(10 * m));
    _shadow.color = LabInk.black.withValues(alpha: 0.4);
    _c.drawRRect(rr.shift(Offset(0, 3 * m)), _shadow);
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.zslYellow.withValues(alpha: 0.5);
    _c.drawRRect(rr, _stroke);
    rule.paint(_c, Offset(rect.center.dx - rule.width / 2, rect.top + padY));
    final sumLeft = rect.center.dx - sumW / 2;
    final sumTop = rect.top + padY + rule.height + gap;
    sum.paint(_c, Offset(sumLeft, sumTop));
    if (s.computed) {
      _statusIcon(
        Offset(sumLeft + sum.width + 6 * m + iconR, sumTop + sum.height / 2),
        iconR,
        true,
      );
    }
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
    String? family,
    double? maxWidth,
  }) {
    final key =
        '$text|$size|${color.toARGB32()}|${weight.value}|$letterSpacing|$family|$maxWidth';
    return _painters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            letterSpacing: letterSpacing,
            height: 1.2,
            fontFamily: family ?? LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: maxWidth == null ? 1 : 2,
        ellipsis: maxWidth == null ? null : '…',
      )..layout(maxWidth: maxWidth ?? double.infinity),
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
