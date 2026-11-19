// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 1 • Activity 1
/// Properties of Materials & Chemical Changes.
///
/// Native Flutter port of
/// `Cl7S-Ch1-A1-Properties_of_Materials_and_Chemical_Changes.html`.
/// Scenario 1: a turmeric stain on a school shirt turns red with soap (base),
/// back to yellow with lemon (acid) and is washed away under the tap.
/// Scenario 2: materials are dropped into the gap of a battery-bulb circuit
/// and sorted into "Conductors" / "Insulators" containers, then free play.
///
/// The Three.js tabletop is redrawn with a small perspective projector that
/// uses the HTML camera (eye (0, 11, 16), target origin, 45° FOV), so object
/// layout, drag planes and drop distances match the original exactly.
class Ch1A1PropertiesOfMaterialsAndChemicalChangesPage extends StatefulWidget {
  const Ch1A1PropertiesOfMaterialsAndChemicalChangesPage({super.key});

  @override
  State<Ch1A1PropertiesOfMaterialsAndChemicalChangesPage> createState() =>
      _Ch1A1PropertiesOfMaterialsAndChemicalChangesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, bubble 732,
/// splash 1311, spark 2365, switchTap 2585.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),
  pop('pop.mp3'),
  drop('drop.mp3'),
  pickup('pickup.mp3'),
  bubble('bubble.mp3'),
  splash('splash.mp3'),
  spark('spark.mp3'),
  switchTap('switch.mp3');

  const _Sound(this.file);
  final String file;

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
        AssetSource('audio/class7/${sound.file}'),
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
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
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

/// Brand and Tailwind colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static LabPalette of(bool isDark) => isDark ? dark : light;
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 24,
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

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'title': 'Properties of Materials & Chemical Changes',
    'subtitle': 'Class 7 • The Ever-Evolving World of Science',
    's1_title': '1. Turmeric Stain Mystery',
    's2_title': '2. Conductor & Insulator',
    'startExp': 'Start Experiment',
    'setupCircuit': 'Setup Circuit',
    'sciObs': 'Scientific Observation',
    'conclusion': 'Conclusion',
    // Conclusion popups.
    's1_conc_main':
        'This color change is a chemical reaction! Turmeric is a natural indicator that tells us if something is an acid or a base.',
    's1_conc_1a': '(1) Turmeric + Base (Soap)',
    's1_conc_1b': 'Red Color',
    's1_conc_2a': '(2) Turmeric + Acid (Lemon)',
    's1_conc_2b': 'Yellow Color',
    's2_conc_main':
        'Materials that let electricity pass through are called Conductors. Materials that block electricity are called Insulators. This is a physical property!',
    's2_conc_cond': 'Conductors',
    's2_conc_cond_items': 'Paperclip, Coin',
    's2_conc_ins': 'Insulators',
    's2_conc_ins_items': 'Ruler, Pencil, Eraser',
    's2_free_play': 'FREE PLAY: You can now freely drag any item back into the circuit gap to test it again!',
    // 3D labels.
    'l_stain': 'Turmeric Stain',
    'l_soap': 'Soap Bar (Base)',
    'l_lemon': 'Lemon Wedge (Acid)',
    'l_tap': 'Water Tap',
    'l_shirt': 'School Shirt',
    'l_sink': 'Wash Basin',
    'l_battery': 'Battery',
    'l_bulb': 'Light Bulb',
    'l_gap': 'Circuit Gap',
    'l_tray': 'Materials Tray',
    'l_paperclip': 'Metal Paperclip',
    'l_ruler': 'Solid Plastic Ruler',
    'l_pencil': 'Wooden Pencil',
    'l_coin': 'Copper Coin',
    'l_eraser': 'Rubber Eraser',
    'l_conductors': 'CONDUCTORS',
    'l_insulators': 'INSULATORS',
    'l_conductor': 'CONDUCTOR',
    'l_insulator': 'INSULATOR',
    'coin_value': '1',
    // Feedback.
    'f_chem': 'Chemical Change! Turmeric + Base -> Red',
    'f_neut': 'Neutralization! Acid reverses the color.',
    'f_wash': 'Washing complete! Stain removed.',
    'f_err_tap': 'Turn on the tap first!',
    'f_err_sub': 'Use the right substance for this step.',
    'f_cond': 'Conductor! Circuit completed.',
    'f_ins': 'Insulator! Circuit blocked.',
    'f_brk': 'Circuit broken.',
    'f_cond_id': 'Conductor identified.',
    'f_ins_id': 'Insulator identified.',
    'f_err_clip': 'Use the metal PAPERCLIP first.',
    'f_err_ruler': 'Test the solid blue plastic RULER now.',
    's2_st2_h': 'Drag the PAPERCLIP out of the circuit',
    's2_st4_h': 'Test remaining items (Pencil, Coin, Eraser).',
  },
  'hi': {
    'title': 'पदार्थों के गुण और रासायनिक परिवर्तन',
    'subtitle': 'कक्षा 7 • विज्ञान की निरंतर विकसित होती दुनिया',
    's1_title': '1. हल्दी के दाग का रहस्य',
    's2_title': '2. सुचालक और कुचालक',
    'startExp': 'प्रयोग शुरू करें',
    'setupCircuit': 'सर्किट सेटअप करें',
    'sciObs': 'वैज्ञानिक अवलोकन',
    'conclusion': 'निष्कर्ष',
    's1_conc_main':
        'यह रंग परिवर्तन एक रासायनिक प्रतिक्रिया है! हल्दी एक प्राकृतिक सूचक है जो हमें बताता है कि कोई चीज अम्ल है या क्षार।',
    's1_conc_1a': '(1) हल्दी + क्षारक (साबुन)',
    's1_conc_1b': 'लाल रंग',
    's1_conc_2a': '(2) हल्दी + अम्ल (नींबू)',
    's1_conc_2b': 'पीला रंग',
    's2_conc_main':
        'जिन पदार्थों से बिजली गुजर सकती है, उन्हें सुचालक (Conductors) कहा जाता है। जो पदार्थ बिजली को रोकते हैं उन्हें कुचालक (Insulators) कहा जाता है। यह एक भौतिक गुण है!',
    's2_conc_cond': 'सुचालक',
    's2_conc_cond_items': 'पेपरक्लिप, सिक्का',
    's2_conc_ins': 'कुचालक',
    's2_conc_ins_items': 'रूलर, पेंसिल, इरेज़र',
    's2_free_play':
        'फ्री प्ले: अब आप किसी भी आइटम का परीक्षण करने के लिए उसे स्वतंत्र रूप से सर्किट गैप में वापस खींच सकते हैं!',
    'l_stain': 'हल्दी का दाग',
    'l_soap': 'साबुन (क्षारक)',
    'l_lemon': 'नींबू (अम्ल)',
    'l_tap': 'पानी का नल',
    'l_shirt': 'स्कूल शर्ट',
    'l_sink': 'वाश बेसिन',
    'l_battery': 'बैटरी',
    'l_bulb': 'लाइट बल्ब',
    'l_gap': 'सर्किट गैप',
    'l_tray': 'सामग्री ट्रे',
    'l_paperclip': 'धातु पेपरक्लिप',
    'l_ruler': 'प्लास्टिक रूलर',
    'l_pencil': 'लकड़ी की पेंसिल',
    'l_coin': 'तांबे का सिक्का',
    'l_eraser': 'रबर इरेज़र',
    'l_conductors': 'सुचालक',
    'l_insulators': 'कुचालक',
    'l_conductor': 'सुचालक',
    'l_insulator': 'कुचालक',
    'coin_value': '1',
    'f_chem': 'रासायनिक परिवर्तन! हल्दी + क्षारक -> लाल',
    'f_neut': 'उदासीनीकरण! अम्ल रंग को उलट देता है।',
    'f_wash': 'धुलाई पूरी! दाग हट गया।',
    'f_err_tap': 'पहले नल चालू करें!',
    'f_err_sub': 'इस चरण के लिए सही पदार्थ का उपयोग करें।',
    'f_cond': 'सुचालक! सर्किट पूरा हुआ।',
    'f_ins': 'कुचालक! सर्किट अवरुद्ध।',
    'f_brk': 'सर्किट टूट गया।',
    'f_cond_id': 'सुचालक की पहचान हुई।',
    'f_ins_id': 'कुचालक की पहचान हुई।',
    'f_err_clip': 'पहले धातु के पेपरक्लिप का उपयोग करें।',
    'f_err_ruler': 'अब नीले प्लास्टिक रूलर का परीक्षण करें।',
    's2_st2_h': 'पेपरक्लिप को सर्किट से बाहर खींचें',
    's2_st4_h': 'शेष वस्तुओं का परीक्षण करें (पेंसिल, सिक्का, इरेज़र)।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: '1. Turmeric Stain Mystery',
      objective:
          'To investigate how a turmeric stain reacts with different household substances and observe a chemical change.',
      steps: [
        LabStep(
          concept: 'Mission Objective',
          action: 'Read the Mission Objective and click Start Experiment.',
          observation:
              'Welcome to the lab! We will observe how chemical reactions can completely change the properties and color of a substance. In this module, we will be acting as chemists investigating how indicators react to different pH levels.',
        ),
        LabStep(
          concept: 'Apply Soap',
          action: 'Drag the SOAP onto the STAIN',
          observation:
              'Task Instructions: A white school shirt with a bright yellow turmeric stain is on the table. DRAG the bar of soap from the side tray and DROP it exactly onto the yellow stain.\n\nTheory: Soap is a mild Base. Mixing a basic substance with natural turmeric causes a strong chemical reaction, altering its molecular structure immediately.',
        ),
        LabStep(
          concept: 'Apply Acid',
          action: 'Drag the LEMON onto the STAIN',
          observation:
              'Task Instructions: Now that the stain is reddish-brown, DRAG the lemon wedge from the tray and DROP it onto the same stain.\n\nTheory: Lemon contains citric acid. When an Acid mixes with a base, they neutralize each other. This neutralization can reverse the previous visual effect.',
        ),
        LabStep(
          concept: 'Wash it off',
          action: 'Click TAP to toggle water, drag SHIRT under it.',
          observation:
              'Task Instructions: The stain is yellow again. CLICK on the water tap to toggle the water flow. Then DRAG the shirt exactly under the animated stream of water.\n\nInfo: Water is a neutral solvent. It simply washes away the loose organic particles of the turmeric without triggering a new chemical reaction.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Investigation Complete! See Observation.',
          observation:
              'This color change is a chemical reaction! Turmeric is a natural indicator that tells us if something is an acid or a base.\n(1) Turmeric + Base (Soap) → Red Color\n(2) Turmeric + Acid (Lemon) → Yellow Color',
        ),
      ],
    ),
    LabScenarioData(
      title: '2. Conductor & Insulator',
      objective:
          'To test various materials and classify them as electrical conductors or insulators by building a simple circuit.',
      steps: [
        LabStep(
          concept: 'Mission Objective',
          action: 'Read the Mission Objective and click Setup Circuit.',
          observation:
              "We will observe the physical property of electrical conductivity to classify materials. Conductivity determines if an object allows electricity to flow freely. Let's build a circuit to find out!",
        ),
        LabStep(
          concept: 'Test a Metal',
          action: 'Drag the metal PAPERCLIP into the GAP',
          observation:
              'Task Instructions: On the screen is an open circuit. DRAG the metal paperclip from the materials tray and DROP it exactly into the gap between the two alligator clips.\n\nTheory: Metals have free electrons that allow electric current to pass through them seamlessly. Materials that do this are called Conductors.',
        ),
        LabStep(
          concept: 'Break Circuit',
          action: 'Drag the PAPERCLIP out of the circuit',
          observation:
              'Task Instructions: Excellent! The bulb glows. Now, DRAG the metal paperclip out of the circuit and DROP it back into the materials tray to safely break the circuit.',
        ),
        LabStep(
          concept: 'Test a Plastic',
          action: 'Drag the plastic RULER into the GAP',
          observation:
              'Task Instructions: DRAG the solid blue plastic ruler from the tray and DROP it into the gap between the clips.\n\nTheory: Plastics hold tightly onto their electrons, completely blocking the flow of the electrical current. Materials that do this are called Insulators.',
        ),
        LabStep(
          concept: 'Classification',
          action: 'Test remaining items (Pencil, Coin, Eraser).',
          observation:
              'Task Instructions: Test all the remaining items from the tray: a wooden pencil, a copper coin, and a rubber eraser. DRAG and DROP each one into the circuit gap to sort them automatically into their containers.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Challenge Complete! Free Play enabled.',
          observation:
              'Materials that let electricity pass through are called Conductors. Materials that block electricity are called Insulators. This is a physical property!\nConductors: Paperclip, Coin\nInsulators: Ruler, Pencil, Eraser\nFREE PLAY: You can now freely drag any item back into the circuit gap to test it again!',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: '1. हल्दी के दाग का रहस्य',
      objective:
          'यह जांचने के लिए कि हल्दी का दाग विभिन्न घरेलू पदार्थों के साथ कैसे प्रतिक्रिया करता है और एक रासायनिक परिवर्तन का निरीक्षण करें।',
      steps: [
        LabStep(
          concept: 'मिशन का उद्देश्य',
          action: "मिशन का उद्देश्य पढ़ें और 'प्रयोग शुरू करें' पर क्लिक करें।",
          observation:
              'लैब में आपका स्वागत है! हम देखेंगे कि कैसे रासायनिक प्रतिक्रियाएं किसी पदार्थ के गुणों और रंग को पूरी तरह से बदल सकती हैं। इस मॉड्यूल में, हम केमिस्ट के रूप में जांच करेंगे कि संकेतक विभिन्न पीएच स्तरों पर कैसे प्रतिक्रिया करते हैं।',
        ),
        LabStep(
          concept: 'साबुन लगाएं',
          action: 'साबुन को दाग पर खींचें',
          observation:
              'कार्य निर्देश: मेज पर एक चमकीले पीले हल्दी के दाग वाली सफेद स्कूल शर्ट है। साइड ट्रे से साबुन को खींचें (DRAG) और इसे ठीक पीले दाग पर छोड़ दें (DROP)।\n\nसिद्धांत: साबुन एक हल्का क्षारक (Base) है। प्राकृतिक हल्दी के साथ क्षारीय पदार्थ मिलाने से एक तीव्र रासायनिक प्रतिक्रिया होती है, जिससे इसकी आणविक संरचना तुरंत बदल जाती है।',
        ),
        LabStep(
          concept: 'अम्ल (Acid) लगाएं',
          action: 'नींबू को दाग पर खींचें',
          observation:
              'कार्य निर्देश: अब जब दाग लाल-भूरा हो गया है, ट्रे से नींबू के टुकड़े को खींचें और उसी दाग पर छोड़ दें।\n\nसिद्धांत: नींबू में साइट्रिक एसिड होता है। जब कोई अम्ल (Acid) किसी क्षारक (Base) के साथ मिलता है, तो वे एक-दूसरे को बेअसर (neutralize) कर देते हैं। यह पिछले दृश्य प्रभाव को उलट सकता है।',
        ),
        LabStep(
          concept: 'इसे धो लें',
          action: 'पानी चालू करने के लिए नल पर क्लिक करें, शर्ट को उसके नीचे खींचें।',
          observation:
              'कार्य निर्देश: दाग फिर से पीला हो गया है। पानी का प्रवाह चालू करने के लिए पानी के नल पर क्लिक करें। फिर शर्ट को बहते पानी के ठीक नीचे खींचें।\n\nजानकारी: पानी एक तटस्थ विलायक (neutral solvent) है। यह किसी नई रासायनिक प्रतिक्रिया को ट्रिगर किए बिना बस हल्दी के ढीले कार्बनिक कणों को धो देता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'जांच पूरी हुई! अवलोकन देखें।',
          observation:
              'यह रंग परिवर्तन एक रासायनिक प्रतिक्रिया है! हल्दी एक प्राकृतिक सूचक है जो हमें बताता है कि कोई चीज अम्ल है या क्षार।\n(1) हल्दी + क्षारक (साबुन) → लाल रंग\n(2) हल्दी + अम्ल (नींबू) → पीला रंग',
        ),
      ],
    ),
    LabScenarioData(
      title: '2. सुचालक और कुचालक',
      objective:
          'विभिन्न सामग्रियों का परीक्षण करने और एक साधारण सर्किट बनाकर उन्हें विद्युत सुचालक या कुचालक के रूप में वर्गीकृत करने के लिए।',
      steps: [
        LabStep(
          concept: 'मिशन का उद्देश्य',
          action: "मिशन का उद्देश्य पढ़ें और 'सर्किट सेटअप करें' पर क्लिक करें।",
          observation:
              'हम सामग्रियों को वर्गीकृत करने के लिए विद्युत चालकता के भौतिक गुण का निरीक्षण करेंगे। चालकता यह निर्धारित करती है कि कोई वस्तु बिजली को स्वतंत्र रूप से प्रवाहित होने देती है या नहीं। आइए पता लगाने के लिए एक सर्किट बनाएं!',
        ),
        LabStep(
          concept: 'धातु का परीक्षण करें',
          action: 'धातु के पेपरक्लिप को गैप में खींचें',
          observation:
              'कार्य निर्देश: स्क्रीन पर एक खुला सर्किट है। सामग्री ट्रे से धातु के पेपरक्लिप को खींचें और इसे दो एलीगेटर क्लिप के बीच के गैप में ठीक से छोड़ दें।\n\nसिद्धांत: धातुओं में मुक्त इलेक्ट्रॉन होते हैं जो विद्युत प्रवाह को उनके माध्यम से निर्बाध रूप से गुजरने देते हैं। ऐसा करने वाले पदार्थों को सुचालक (Conductors) कहा जाता है।',
        ),
        LabStep(
          concept: 'सर्किट तोड़ें',
          action: 'पेपरक्लिप को सर्किट से बाहर खींचें',
          observation:
              'कार्य निर्देश: बहुत बढ़िया! बल्ब चमकता है। अब, सर्किट को सुरक्षित रूप से तोड़ने के लिए धातु के पेपरक्लिप को सर्किट से बाहर निकालें और इसे वापस सामग्री ट्रे में छोड़ दें।',
        ),
        LabStep(
          concept: 'प्लास्टिक का परीक्षण करें',
          action: 'प्लास्टिक रूलर को गैप में खींचें',
          observation:
              'कार्य निर्देश: ट्रे से ठोस नीले प्लास्टिक रूलर को खींचें और इसे क्लिप के बीच के गैप में छोड़ दें।\n\nसिद्धांत: प्लास्टिक अपने इलेक्ट्रॉनों को कसकर पकड़ कर रखते हैं, जिससे विद्युत प्रवाह पूरी तरह से अवरुद्ध हो जाता है। ऐसा करने वाले पदार्थों को कुचालक (Insulators) कहा जाता है।',
        ),
        LabStep(
          concept: 'वर्गीकरण',
          action: 'शेष वस्तुओं का परीक्षण करें (पेंसिल, सिक्का, इरेज़र)।',
          observation:
              'कार्य निर्देश: ट्रे से शेष सभी वस्तुओं का परीक्षण करें: एक लकड़ी की पेंसिल, एक तांबे का सिक्का और एक रबर इरेज़र। प्रत्येक को सर्किट गैप में खींचें और छोड़ें ताकि वे स्वचालित रूप से अपने कंटेनरों में क्रमबद्ध हो जाएं।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'चुनौती पूरी हुई! फ्री प्ले सक्षम।',
          observation:
              'जिन पदार्थों से बिजली गुजर सकती है, उन्हें सुचालक (Conductors) कहा जाता है। जो पदार्थ बिजली को रोकते हैं उन्हें कुचालक (Insulators) कहा जाता है। यह एक भौतिक गुण है!\nसुचालक: पेपरक्लिप, सिक्का\nकुचालक: रूलर, पेंसिल, इरेज़र\nफ्री प्ले: अब आप किसी भी आइटम का परीक्षण करने के लिए उसे स्वतंत्र रूप से सर्किट गैप में वापस खींच सकते हैं!',
        ),
      ],
    ),
  ],
};

/// Keys of every string the painter needs (resolved on each build).
const List<String> _labelKeys = [
  'l_stain', 'l_soap', 'l_lemon', 'l_tap', 'l_shirt', 'l_sink', //
  'l_battery', 'l_bulb', 'l_gap', 'l_tray', 'l_paperclip', 'l_ruler',
  'l_pencil', 'l_coin', 'l_eraser', 'l_conductors', 'l_insulators',
  'l_conductor', 'l_insulator', 'coin_value',
];

// ======================================================== SCENE MODEL

const Color _stainYellow = Color(0xFFEAB308);
const Color _stainRed = Color(0xFF991B1B);

/// Gap between the two alligator clips (HTML `gapTarget.position`).
const _V3 _gapPos = _V3(0, 0.05, 1.5);

/// Spout outlet / water stream origin (HTML `waterParticles.position`).
const _V3 _spout = _V3(-4.05, 1.3, -1.0);
const _V3 _boxConductor = _V3(-6.5, 0.1, 4.0);
const _V3 _boxInsulator = _V3(6.5, 0.1, 4.0);

/// HTML `getBoxOffset()`: resting spots inside the sorting containers.
const Map<String, _V3> _boxOffsets = {
  'paperclip': _V3(-1.0, 0.1, -0.6),
  'coin': _V3(1.0, 0.15, 0.6),
  'ruler': _V3(0, 0.1, 0.6),
  'pencil': _V3(-1.0, 0.15, -0.8),
  'eraser': _V3(1.2, 0.15, -0.6),
};

/// A draggable object (HTML mesh + `userData`).
class _Obj {
  _Obj(this.id, this.home, {this.conductor = false}) : pos = home;

  final String id;

  /// HTML `userData.originalPos`.
  final _V3 home;
  _V3 pos;
  bool draggable = true;
  bool inGap = false;
  final bool conductor;
  _Move? move;
}

/// Frame-based lerp from the HTML (`returnToOrigin`, `animateToTarget`).
class _Move {
  _Move(this.from, this.to, this.duration, {this.arc = 0});

  final _V3 from;
  final _V3 to;
  final double duration;
  final double arc;
  double t = 0;
}

class _Particle {
  _Particle(this.pos, this.vel, this.color);
  _V3 pos;
  _V3 vel;
  final Color color;
  double scale = 1;
}

class _Droplet {
  _Droplet(this.x, this.y, this.z, this.v);
  double x, y, z;
  final double v;
}

class _Spark {
  _Spark(this.pts);
  final List<_V3> pts;
  double life = 1;
}

class _World {
  final math.Random rnd = math.Random();
  int scenario = 0;
  int step = 0;
  double time = 0;

  // ---- Scenario 1 (turmeric stain)
  final _Obj soap = _Obj('soap', const _V3(5.5, 0.15, 1.5));
  final _Obj lemon = _Obj('lemon', const _V3(5.5, 0.1, -1.5));
  final _Obj shirt = _Obj('shirt', const _V3(1.5, 0.025, 1.0))..draggable = false;
  Color stainFrom = _stainYellow;
  Color stainTo = _stainYellow;
  double stainT = 1;
  double stainOpacity = 0.9;
  bool stainVisible = true;
  bool stainFading = false;
  bool waterOn = false;
  final List<_Droplet> droplets = [];
  final List<_Particle> particles = [];

  // ---- Scenario 2 (conductors & insulators)
  final _Obj clip = _Obj('paperclip', const _V3(-3.0, 0.2, -2.0), conductor: true);
  final _Obj ruler = _Obj('ruler', const _V3(0, 0.15, -2.0));
  final _Obj pencil = _Obj('pencil', const _V3(3.0, 0.2, -2.0));
  final _Obj coin = _Obj('coin', const _V3(-1.5, 0.15, -2.0), conductor: true);
  final _Obj eraser = _Obj('eraser', const _V3(1.5, 0.2, -2.0));
  bool bulbOn = false;
  double bulbGlow = 0;
  bool condLabel = false;
  bool insLabel = false;
  int itemsTested = 0;
  final List<_Spark> sparks = [];

  _Obj? dragging;

  List<_Obj> get items => [clip, ruler, pencil, coin, eraser];
  List<_Obj> get all => [soap, lemon, shirt, ...items];

  Color get stainColor => Color.lerp(stainFrom, stainTo, stainT)!;

  /// World position of the stain (shirt-local (-0.2, 0.03, 0.2)).
  _V3 get stainPos => shirt.pos + const _V3(-0.2, 0.03, 0.2);

  _V3 boxSpot(_Obj o) => (o.conductor ? _boxConductor : _boxInsulator) + (_boxOffsets[o.id] ?? const _V3(0, 0.15, 0));

  void setStain(Color c, {bool animate = true}) {
    stainFrom = animate ? stainColor : c;
    stainTo = c;
    stainT = animate ? 0 : 1;
  }

  void spawnDroplets() {
    droplets
      ..clear()
      ..addAll([
        for (var i = 0; i < 15; i++)
          _Droplet(
            (rnd.nextDouble() - 0.5) * 0.1,
            -rnd.nextDouble() * 1.5,
            (rnd.nextDouble() - 0.5) * 0.1,
            -0.05 - rnd.nextDouble() * 0.05,
          ),
      ]);
  }

  /// HTML `createActionParticles()`.
  void burst(_V3 at, Color color) {
    for (var i = 0; i < 12; i++) {
      particles.add(
        _Particle(
          at + _V3((rnd.nextDouble() - 0.5) * 0.5, rnd.nextDouble() * 0.2 + 0.1, (rnd.nextDouble() - 0.5) * 0.5),
          _V3((rnd.nextDouble() - 0.5) * 0.06, rnd.nextDouble() * 0.06 + 0.02, (rnd.nextDouble() - 0.5) * 0.06),
          color,
        ),
      );
    }
  }

  /// HTML `createLightningSparks()`.
  void spark(_V3 boxPos) {
    var cur = _V3(boxPos.x - 0.5, boxPos.y + 0.3, boxPos.z);
    final pts = [cur];
    for (var i = 0; i < 5; i++) {
      cur = cur + _V3(0.2, (rnd.nextDouble() - 0.5) * 0.3, (rnd.nextDouble() - 0.5) * 0.3);
      pts.add(cur);
    }
    sparks.add(_Spark(pts));
  }

  /// Advances every frame-based animation (the HTML ran them at ~60 fps).
  void update(double dt) {
    time += dt;
    final f = dt * 60;
    for (final o in all) {
      final m = o.move;
      if (m == null) continue;
      m.t += dt / m.duration;
      if (m.t >= 1) {
        o.pos = m.to;
        o.move = null;
      } else {
        o.pos = _V3.lerp(m.from, m.to, m.t) + _V3(0, math.sin(m.t * math.pi) * m.arc, 0);
      }
    }
    for (var i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.pos = p.pos + p.vel * f;
      p.vel = _V3(p.vel.x, p.vel.y - 0.005 * f, p.vel.z);
      p.scale *= math.pow(0.92, f).toDouble();
      if (p.scale < 0.1) particles.removeAt(i);
    }
    if (waterOn) {
      for (final d in droplets) {
        d.y += d.v * f;
        if (d.y < -1.5) {
          d
            ..y = 0
            ..x = (rnd.nextDouble() - 0.5) * 0.1
            ..z = (rnd.nextDouble() - 0.5) * 0.1;
        }
      }
    }
    for (var i = sparks.length - 1; i >= 0; i--) {
      sparks[i].life -= 0.05 * f;
      if (sparks[i].life <= 0) sparks.removeAt(i);
    }
    if (stainFading) {
      stainOpacity -= 0.03 * f;
      if (stainOpacity <= 0) {
        stainOpacity = 0;
        stainVisible = false;
        stainFading = false;
      }
    }
    if (stainT < 1) stainT = math.min(1, stainT + dt / 0.35);
    final target = bulbOn ? 1.0 : 0.0;
    bulbGlow += (target - bulbGlow) * math.min(1, dt * 14);
  }
}

// ============================================================== STATE

class _Ch1A1PropertiesOfMaterialsAndChemicalChangesPageState
    extends State<Ch1A1PropertiesOfMaterialsAndChemicalChangesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _World _w = _World();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  Timer? _waterTimer;

  /// A step advance is scheduled (HTML setTimeout before `nextStep()`);
  /// blocks double triggers while it is pending.
  bool _pending = false;
  _V3 _dragOffset = _V3.zero;
  double _dragPlaneY = 0;

  String _t(String key) => _lab.tr(_i18n, key);
  _Cam get _cam => _cams[_w.scenario];
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_w.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
      _last = elapsed;
      _w.update(dt);
      _frame.value = _w.time;
    })..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _waterTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic

  /// HTML `loadScenario(id)`.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _pending = false;
    _setWater(false, sound: false);
    final w = _w
      ..scenario = index
      ..step = 0
      ..dragging = null;
    if (index == 0) {
      w.shirt
        ..move = null
        ..pos = w.shirt.home
        ..draggable = false;
      w
        ..stainVisible = true
        ..stainFading = false
        ..stainOpacity = 0.9
        ..setStain(_stainYellow, animate: false);
      _returnToOrigin(w.soap);
      _returnToOrigin(w.lemon);
      w.particles.clear();
      w.droplets.clear();
    } else {
      w
        ..bulbOn = false
        ..bulbGlow = 0
        ..itemsTested = 0
        ..condLabel = false
        ..insLabel = false;
      w.sparks.clear();
      for (final o in w.items) {
        o
          ..move = null
          ..inGap = false
          ..draggable = true
          ..pos = o.home;
      }
    }
    _lab.hidePopup(sound: false);
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `nextStep()`: advances and runs the step's `setupScene`; the
  /// conclusion step opens the observation popup after 2 s.
  void _nextStep() {
    _pending = false;
    final n = _data.steps.length;
    if (_w.step >= n - 1) return;
    setState(() {
      _w.step++;
      if (_w.scenario == 1 && _w.step == 4) {
        _w.clip.draggable = false;
        _w.ruler.draggable = false;
      } else if (_w.scenario == 1 && _w.step == 5) {
        for (final o in _w.items) {
          o.draggable = true;
        }
      }
    });
    if (_w.step == n - 1) _showConclusion();
  }

  void _advanceAfter(int ms, [VoidCallback? before]) {
    _pending = true;
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      before?.call();
      _nextStep();
    });
  }

  void _showConclusion() {
    final scenario = _w.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 2000),
      title: () => _t('sciObs'),
      heading: () => _t('conclusion'),
      body: () => scenario == 0 ? _t('s1_conc_main') : _t('s2_conc_main'),
      extra: () => scenario == 0 ? _s1ConclusionExtra() : _s2ConclusionExtra(),
    );
  }

  void _returnToOrigin(_Obj o) {
    final target = (_w.scenario == 1 && _w.step == 5 && _w.items.contains(o)) ? _w.boxSpot(o) : o.home;
    o.move = _Move(o.pos, target, 10 / 60);
  }

  void _animateToTarget(_Obj o, _V3 target) {
    o.move = _Move(o.pos, target, 20 / 60, arc: 1.5);
  }

  void _setWater(bool on, {bool sound = true}) {
    _w.waterOn = on;
    _waterTimer?.cancel();
    _waterTimer = null;
    if (on) {
      _w.spawnDroplets();
      if (sound) _Audio.play(_Sound.splash, volume: 0.45);
      // The HTML looped a filtered-noise "water" sound while the tap ran.
      _waterTimer = Timer.periodic(const Duration(milliseconds: 2300), (_) {
        if (mounted && _w.waterOn) _Audio.play(_Sound.splash, volume: 0.3);
      });
    } else {
      _w.droplets.clear();
    }
  }

  // ---------------------------------------------------------- gestures

  _Obj? _hitObject(Offset p) {
    final w = _w;
    final candidates = w.scenario == 0
        ? [w.soap, w.lemon, if (w.shirt.draggable) w.shirt]
        : [
            for (final o in w.items)
              if (o.draggable) o,
          ];
    _Obj? best;
    var bestScore = double.infinity;
    for (final o in candidates) {
      final b = _hitBounds[o.id]!;
      final r = _cam.screenRect(o.pos + b.$1, b.$2).inflate(8);
      final c = r.center;
      final rr = Rect.fromCenter(center: c, width: math.max(r.width, 46), height: math.max(r.height, 46));
      if (!rr.contains(p)) continue;
      final score = (p - c).distance + _cam.depth(o.pos) * 0.5;
      if (score < bestScore) {
        bestScore = score;
        best = o;
      }
    }
    return best;
  }

  bool _hitTap(Offset p) {
    final r = _cam.screenRect(const _V3(-4.75, 1.05, -1.0), const _V3(0.85, 0.85, 0.4)).inflate(14);
    return r.contains(p);
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive || _w.scenario != 0) return;
    if (_hitTap(d.localPosition)) {
      _Audio.play(_Sound.switchTap);
      setState(() => _setWater(!_w.waterOn));
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (!_lab.isLabActive || _w.dragging != null) return;
    final o = _hitObject(d.localPosition);
    if (o == null) return;
    o.move = null;
    _w.dragging = o;
    _dragPlaneY = o.pos.y;
    final ip = _cam.onPlaneY(d.localPosition, _dragPlaneY);
    _dragOffset = ip == null ? _V3.zero : ip - o.pos;
    _Audio.play(_Sound.pickup, volume: 0.4);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _w.dragging;
    if (o == null) return;
    final ip = _cam.onPlaneY(d.localPosition, _dragPlaneY);
    if (ip == null) return;
    final p = ip - _dragOffset;
    // Shirt is lifted to 0.5 (clears the sink walls); others float +0.4.
    final y = o == _w.shirt ? 0.5 : o.home.y + 0.4;
    o.pos = _V3(p.x.clamp(-11.0, 11.0), y, p.z.clamp(-7.0, 8.0));
  }

  void _onPanEnd() {
    final o = _w.dragging;
    if (o == null) return;
    _w.dragging = null;
    setState(() => _drop(o));
  }

  /// HTML `onPointerUp()` drop rules.
  void _drop(_Obj obj) {
    final w = _w;
    var dropped = false;
    var feedback = false;

    if (w.scenario == 0) {
      final stain = w.stainPos;
      final dist = (obj.pos - stain).length;
      if (dist < 1.5 && obj != w.shirt && !_pending) {
        if (w.step == 1) {
          if (obj == w.soap) {
            w.setStain(_stainRed);
            w.burst(stain, Colors.white);
            _Audio.play(_Sound.bubble);
            _lab.showToast(_t('f_chem'));
            dropped = true;
            w.soap.draggable = false;
            _advanceAfter(1500, () {
              w.soap.draggable = true;
              _returnToOrigin(w.soap);
            });
          } else {
            _lab.showToast(_t('f_err_sub'), isError: true);
          }
          feedback = true;
        } else if (w.step == 2) {
          if (obj == w.lemon) {
            w.setStain(_stainYellow);
            w.burst(stain, const Color(0xFFFEF08A));
            _Audio.play(_Sound.pop);
            _lab.showToast(_t('f_neut'));
            dropped = true;
            w.shirt.draggable = true;
            w.lemon.draggable = false;
            _advanceAfter(1500, () {
              w.lemon.draggable = true;
              _returnToOrigin(w.lemon);
            });
          } else {
            _lab.showToast(_t('f_err_sub'), isError: true);
          }
          feedback = true;
        }
      }
      if (w.step == 3 && obj == w.shirt && !_pending) {
        final dx = obj.pos.x - _spout.x, dz = obj.pos.z - _spout.z;
        if (math.sqrt(dx * dx + dz * dz) < 2.0) {
          if (w.waterOn) {
            dropped = true;
            obj.pos = const _V3(-4.05, 0.1, -1.0); // inside the sink
            w.stainFading = true;
            _Audio.play(_Sound.success);
            _lab.showToast(_t('f_wash'), sound: false);
            _advanceAfter(2000);
          } else {
            _lab.showToast(_t('f_err_tap'), isError: true);
          }
          feedback = true;
        }
      }
    } else {
      final dist = (obj.pos - _gapPos).length;
      if (dist < 1.5) {
        feedback = true;
        if (w.step == 1 && obj == w.clip && !_pending) {
          _snapToGap(obj);
          dropped = true;
          _lab.showToast(_t('f_cond'));
          obj.draggable = false;
          _advanceAfter(1500, () => obj.draggable = true);
        } else if (w.step == 2 && obj == w.clip) {
          _lab.showToast(_t('s2_st2_h'), isError: true);
          // Still connected: it settles back between the clips.
          if (obj.inGap) {
            obj.move = _Move(obj.pos, _gapPos + const _V3(0, 0.05, 0), 10 / 60);
            dropped = true;
          }
        } else if (w.step == 3 && obj == w.ruler && !_pending) {
          _snapToGap(obj);
          dropped = true;
          _lab.showToast(_t('f_ins'));
          obj.draggable = false;
          _advanceAfter(1500, () {
            obj
              ..inGap = false
              ..draggable = true;
            w.insLabel = false;
            _returnToOrigin(obj);
          });
        } else if (w.step == 4 && obj != w.clip && obj != w.ruler) {
          _snapToGap(obj);
          dropped = true;
          final isConductor = obj.conductor;
          _lab.showToast(isConductor ? _t('f_cond_id') : _t('f_ins_id'));
          obj.draggable = false;
          _lab.after(const Duration(milliseconds: 1200), () {
            if (!mounted || w.scenario != 1) return;
            setState(() {
              w
                ..bulbOn = false
                ..condLabel = false
                ..insLabel = false;
              obj.inGap = false;
              _animateToTarget(obj, w.boxSpot(obj));
              _Audio.play(_Sound.success);
              if (isConductor) w.spark(_boxConductor);
              w.itemsTested++;
              if (w.itemsTested >= 3) _advanceAfter(1500);
            });
          });
        } else if (w.step == 5) {
          _snapToGap(obj, freePlay: true);
          dropped = true;
        } else {
          if (w.step == 1) {
            _lab.showToast(_t('f_err_clip'), isError: true);
          } else if (w.step == 3) {
            _lab.showToast(_t('f_err_ruler'), isError: true);
          } else if (w.step == 4) {
            _lab.showToast(_t('s2_st4_h'), isError: true);
          } else {
            _Audio.play(_Sound.wrong);
          }
        }
      } else if (obj.inGap) {
        obj.inGap = false;
        w
          ..bulbOn = false
          ..condLabel = false
          ..insLabel = false;
        _Audio.play(_Sound.pop);
        feedback = true;
        if (w.step == 2 && obj == w.clip) {
          _lab.showToast(_t('f_brk'));
          dropped = true;
          _returnToOrigin(obj);
          obj.draggable = false;
          _advanceAfter(1000, () => obj.draggable = true);
        }
      }
    }

    if (!feedback) _Audio.play(_Sound.drop, volume: 0.5);
    if (!dropped) _returnToOrigin(obj);
  }

  /// HTML `snapToGap()`: item sits between the clips, bulb follows its
  /// conductivity and the big status label appears.
  void _snapToGap(_Obj o, {bool freePlay = false}) {
    final w = _w;
    if (freePlay) {
      // Only one item can bridge the clips: any other returns to its box.
      for (final other in w.items) {
        if (other != o && other.inGap) {
          other.inGap = false;
          _returnToOrigin(other);
        }
      }
      w
        ..condLabel = false
        ..insLabel = false;
    }
    o
      ..move = null
      ..pos = _gapPos + const _V3(0, 0.05, 0)
      ..inGap = true;
    _Audio.play(_Sound.pop);
    w.bulbOn = o.conductor;
    if (o.conductor) {
      w.condLabel = true;
      _Audio.play(_Sound.spark, volume: 0.35);
    } else {
      w.insLabel = true;
    }
  }

  List<LabAction> _actions() {
    if (_w.step == 0) {
      return [
        LabAction(
          label: _w.scenario == 0 ? _t('startExp') : _t('setupCircuit'),
          icon: Icons.arrow_forward,
          onTap: _nextStep,
        ),
      ];
    }
    return const [];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('title'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: _w.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _w.step + 1,
          actions: _actions(),
          onReset: _fullReset,
          stage: LabStage(
            designSize: _design,
            // The default 36 px pan slop would swallow short drags; the
            // HTML picked objects up on pointer-down.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: _onTapUp,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: _A1Painter(
                    world: _w,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    text: {for (final k in _labelKeys) k: _t(k)},
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _s1ConclusionExtra() {
    final dark = _lab.isDark;
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(dark);
        // "(1) Turmeric + Base (Soap) → Red Color" with an arrow icon.
        Widget line(String a, String b, Color c) {
          final st = TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12.5 * s, height: 1.35);
          return Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$a '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.arrow_forward_rounded, size: 14 * s, color: c),
                ),
                TextSpan(text: ' $b'),
              ],
            ),
            textAlign: TextAlign.center,
            style: st,
          );
        }

        return Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              line(_t('s1_conc_1a'), _t('s1_conc_1b'), dark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
              SizedBox(height: 8 * s),
              line(_t('s1_conc_2a'), _t('s1_conc_2b'), dark ? const Color(0xFFFACC15) : const Color(0xFFB45309)),
            ],
          ),
        );
      },
    );
  }

  Widget _s2ConclusionExtra() {
    final dark = _lab.isDark;
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(dark);
        Widget card(String title, String items, Color c) => Expanded(
          child: Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12.5 * s),
                ),
                SizedBox(height: 4 * s),
                Text(
                  items,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w600, fontSize: 12 * s, height: 1.3),
                ),
              ],
            ),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  card(
                    _t('s2_conc_cond'),
                    _t('s2_conc_cond_items'),
                    dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                  ),
                  SizedBox(width: 8 * s),
                  card(
                    _t('s2_conc_ins'),
                    _t('s2_conc_ins_items'),
                    dark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * s),
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: _Colors.zslYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_esports,
                    size: 16 * s,
                    color: dark ? const Color(0xFFFDE047) : const Color(0xFFA16207),
                  ),
                  SizedBox(width: 6 * s),
                  Expanded(
                    child: Text(
                      _t('s2_free_play'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark ? const Color(0xFFFDE047) : const Color(0xFFA16207),
                        fontWeight: FontWeight.w800,
                        fontSize: 11 * s,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Screen hit boxes (centre offset, half extents) per draggable object.
const Map<String, (_V3, _V3)> _hitBounds = {
  'soap': (_V3.zero, _V3(0.6, 0.15, 0.35)),
  'lemon': (_V3(0, 0.25, 0), _V3(0.5, 0.25, 0.5)),
  'shirt': (_V3(0, 0, -0.1), _V3(1.9, 0.05, 1.5)),
  'paperclip': (_V3(0.075, 0, 0.225), _V3(0.98, 0.06, 0.29)),
  'ruler': (_V3.zero, _V3(1.3, 0.05, 0.25)),
  'pencil': (_V3(-0.05, 0, 0), _V3(0.95, 0.06, 0.08)),
  'coin': (_V3.zero, _V3(0.3, 0.03, 0.3)),
  'eraser': (_V3(0.05, 0, 0), _V3(0.35, 0.1, 0.2)),
};

// ====================================================== 3D PROJECTION

/// Design size of the stage. The projector below reproduces the HTML
/// camera (45° FOV, eye (0, 11, 16) looking at the origin) on a 1000x560
/// viewport and crops it slightly so the tabletop fills the canvas.
const Size _design = Size(860, 480);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);

  static const _V3 zero = _V3(0, 0, 0);

  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);

  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);

  _V3 get unit {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }

  /// Rotation about Y with the Three.js sign convention.
  _V3 rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V3(x * c + z * s, y, -x * s + z * c);
  }

  _V3 withY(double ny) => _V3(x, ny, z);

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Pinhole camera matching a Three.js PerspectiveCamera.
class _Cam {
  _Cam({
    required this.eye,
    required _V3 target,
    required double fovDeg,
    required this.center,
    required double viewHeight,
  }) {
    f = (target - eye).unit;
    r = f.cross(const _V3(0, 1, 0)).unit;
    u = r.cross(f);
    focal = viewHeight / 2 / math.tan(fovDeg * math.pi / 360);
  }

  final _V3 eye;
  final Offset center;
  late final _V3 f, r, u;
  late final double focal;

  double depth(_V3 w) => (w - eye).dot(f);

  /// Pixels per world unit at the depth of [w].
  double k(_V3 w) => focal / math.max(depth(w), 0.05);

  Offset p(_V3 w) {
    final d = w - eye;
    final z = math.max(d.dot(f), 0.05);
    return Offset(center.dx + d.dot(r) / z * focal, center.dy - d.dot(u) / z * focal);
  }

  /// Ray through screen point [s] intersected with the plane y = [y]
  /// (HTML `raycaster.ray.intersectPlane(dragPlane)`).
  _V3? onPlaneY(Offset s, double y) {
    final dir = f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal);
    if (dir.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }

  /// Screen bounding box of an axis-aligned world box.
  Rect screenRect(_V3 c, _V3 h) {
    var l = double.infinity, t = double.infinity, rr = -double.infinity, b = -double.infinity;
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final q = p(c + _V3(sx * h.x, sy * h.y, sz * h.z));
          l = math.min(l, q.dx);
          rr = math.max(rr, q.dx);
          t = math.min(t, q.dy);
          b = math.max(b, q.dy);
        }
      }
    }
    return Rect.fromLTRB(l, t, rr, b);
  }
}

/// One framing per scenario of the same HTML camera: the stain bench is
/// shown closer (its objects are small), the circuit bench wider (the
/// sorting boxes sit at the table edges).
final List<_Cam> _cams = [
  _Cam(
    eye: const _V3(0, 11, 16),
    target: _V3.zero,
    fovDeg: 45,
    center: const Offset(375, 187.5),
    viewHeight: 560 * 1.5,
  ),
  _Cam(
    eye: const _V3(0, 11, 16),
    target: _V3.zero,
    fovDeg: 45,
    center: const Offset(405, 225),
    viewHeight: 560,
  ),
];

/// HTML directional light (4, 10, 6), normalised.
final _V3 _lightDir = const _V3(4, 10, 6).unit;

/// Ambient 0.7 + directional 0.8 (Lambert), like the HTML lights.
Color _lit(Color c, _V3 n) => _mul(c, 0.7 + 0.8 * math.max(0.0, n.dot(_lightDir)));

Color _mul(Color c, double k) => Color.from(
      alpha: c.a,
      red: (c.r * k).clamp(0.0, 1.0),
      green: (c.g * k).clamp(0.0, 1.0),
      blue: (c.b * k).clamp(0.0, 1.0),
    );

/// Uniform Catmull-Rom spline through [pts] (THREE.CatmullRomCurve3).
List<_V3> _catmull(List<_V3> pts, {int seg = 8}) {
  final out = <_V3>[];
  final n = pts.length;
  for (var i = 0; i < n - 1; i++) {
    final p0 = pts[math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[math.min(i + 2, n - 1)];
    for (var s = 0; s < seg; s++) {
      final t = s / seg, t2 = t * t, t3 = t2 * t;
      final v = p0 * (-0.5 * t3 + t2 - 0.5 * t) +
          p1 * (1.5 * t3 - 2.5 * t2 + 1) +
          p2 * (-1.5 * t3 + 2 * t2 + 0.5 * t) +
          p3 * (0.5 * t3 - 0.5 * t2);
      out.add(v);
    }
  }
  out.add(pts.last);
  return out;
}

/// Quadratic Bezier (HTML `CustomCurve`).
List<_V3> _bezier(_V3 a, _V3 b, _V3 c, {int n = 30}) => [
      for (var i = 0; i <= n; i++)
        a * ((1 - i / n) * (1 - i / n)) + b * (2 * (1 - i / n) * (i / n)) + c * ((i / n) * (i / n)),
    ];

class _Poly {
  _Poly(this.pts, this.n, this.color, {this.opacity = 1, this.cull = true, this.lit = true});

  final List<_V3> pts;
  final _V3 n;
  final Color color;
  final double opacity;
  final bool cull;
  final bool lit;
}

/// Collects faces, culls back faces, depth-sorts (painter's algorithm) and
/// fills them with Lambert shading. Also hosts direct primitives.
class _R3 {
  _R3(this.canvas, this.cam);

  final Canvas canvas;
  final _Cam cam;
  final List<_Poly> _buf = [];

  void quad(List<_V3> pts, _V3 n, Color color, {double opacity = 1, bool cull = true, bool lit = true}) =>
      _buf.add(_Poly(pts, n, color, opacity: opacity, cull: cull, lit: lit));

  /// Axis-aligned box (optionally rotated about Y) with half extents [h].
  void box(_V3 c, _V3 h, Color color, {double ry = 0, double opacity = 1, bool cull = true}) {
    _V3 pt(double sx, double sy, double sz) => c + _V3(sx * h.x, sy * h.y, sz * h.z).rotY(ry);
    _V3 nn(double x, double y, double z) => _V3(x, y, z).rotY(ry);
    void f(List<_V3> pts, _V3 n) => _buf.add(_Poly(pts, n, color, opacity: opacity, cull: cull));
    f([pt(1, -1, -1), pt(1, 1, -1), pt(1, 1, 1), pt(1, -1, 1)], nn(1, 0, 0));
    f([pt(-1, -1, -1), pt(-1, -1, 1), pt(-1, 1, 1), pt(-1, 1, -1)], nn(-1, 0, 0));
    f([pt(-1, 1, -1), pt(-1, 1, 1), pt(1, 1, 1), pt(1, 1, -1)], nn(0, 1, 0));
    f([pt(-1, -1, -1), pt(1, -1, -1), pt(1, -1, 1), pt(-1, -1, 1)], nn(0, -1, 0));
    f([pt(-1, -1, 1), pt(1, -1, 1), pt(1, 1, 1), pt(-1, 1, 1)], nn(0, 0, 1));
    f([pt(-1, -1, -1), pt(-1, 1, -1), pt(1, 1, -1), pt(1, -1, -1)], nn(0, 0, -1));
  }

  /// Cylinder / cone frustum between world points [a] (radius [ra]) and
  /// [b] (radius [rb]).
  void frustum(
    _V3 a,
    _V3 b,
    double ra,
    double rb,
    Color color, {
    int seg = 20,
    double opacity = 1,
    bool capA = true,
    bool capB = true,
    double phase = 0,
  }) {
    final axis = b - a;
    final len = axis.length;
    if (len < 1e-6) return;
    final w = axis * (1 / len);
    final ref = w.y.abs() < 0.95 ? const _V3(0, 1, 0) : const _V3(1, 0, 0);
    final u = w.cross(ref).unit;
    final v = w.cross(u);
    final slope = (ra - rb) / len;
    final ringA = <_V3>[], ringB = <_V3>[], dirs = <_V3>[];
    for (var i = 0; i < seg; i++) {
      final ang = phase + i / seg * 2 * math.pi;
      final d = u * math.cos(ang) + v * math.sin(ang);
      dirs.add(d);
      ringA.add(a + d * ra);
      ringB.add(b + d * rb);
    }
    for (var i = 0; i < seg; i++) {
      final j = (i + 1) % seg;
      final n = ((dirs[i] + dirs[j]).unit + w * slope).unit;
      _buf.add(_Poly([ringA[i], ringA[j], ringB[j], ringB[i]], n, color, opacity: opacity));
    }
    if (capA && ra > 0) _buf.add(_Poly(ringA.reversed.toList(), w * -1, color, opacity: opacity));
    if (capB && rb > 0) _buf.add(_Poly(ringB, w, color, opacity: opacity));
  }

  void flush() {
    final eye = cam.eye;
    final items = <(_Poly, double, _V3)>[];
    for (final p in _buf) {
      var cx = 0.0, cy = 0.0, cz = 0.0;
      for (final v in p.pts) {
        cx += v.x;
        cy += v.y;
        cz += v.z;
      }
      final n = p.pts.length;
      final c = _V3(cx / n, cy / n, cz / n);
      final facing = p.n.dot(eye - c) > 0;
      if (p.cull && !facing) continue;
      items.add((p, cam.depth(c), facing ? p.n : p.n * -1));
    }
    _buf.clear();
    items.sort((a, b) => b.$2.compareTo(a.$2));
    for (final (p, _, n) in items) {
      final path = Path()..addPolygon([for (final v in p.pts) cam.p(v)], true);
      final base = p.lit ? _lit(p.color, n) : p.color;
      final col = base.withValues(alpha: base.a * p.opacity);
      canvas.drawPath(path, Paint()..color = col);
      if (p.opacity >= 0.99) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7
            ..strokeJoin = StrokeJoin.round
            ..color = col,
        );
      }
    }
  }

  /// Projected horizontal ellipse of radii [rx] (x) and [rz] (z) at [c].
  Rect hEllipse(_V3 c, double rx, [double? rz]) {
    final z = rz ?? rx;
    final l = cam.p(c - _V3(rx, 0, 0)), r = cam.p(c + _V3(rx, 0, 0));
    final b = cam.p(c - _V3(0, 0, z)), f = cam.p(c + _V3(0, 0, z));
    return Rect.fromLTRB(l.dx, b.dy, r.dx, f.dy);
  }

  /// Horizontal ellipse (as a path) of radii [rx] / [rz], rotated [ry].
  Path hPath(_V3 c, double rx, double rz, {double ry = 0, int n = 24}) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a = i / n * 2 * math.pi;
      final q = cam.p(c + _V3(math.cos(a) * rx, 0, math.sin(a) * rz).rotY(ry));
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    return path..close();
  }

  void sphere(_V3 c, double r, Color color, {double opacity = 1}) {
    labSphere(canvas, cam.p(c), r * cam.k(c), color,
        light: const Offset(0.3, -0.45), highlight: 0.5, shade: 0.5, opacity: opacity);
  }

  /// Hemisphere resting on its flat face (the lemon wedge).
  void dome(_V3 base, double r, Color color) {
    final c = cam.p(base);
    final rad = r * cam.k(base);
    final ell = hEllipse(base, r);
    final half = Path()
      ..addArc(Rect.fromCircle(center: c, radius: rad), math.pi, math.pi)
      ..close();
    final shape = Path.combine(PathOperation.union, half, Path()..addOval(ell));
    final bounds = shape.getBounds();
    canvas.drawPath(
      shape,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.3, -0.55),
          radius: 0.95,
          colors: [labShade(color, 0.55), color, labShade(color, -0.35)],
          stops: const [0, 0.45, 1],
        ).createShader(bounds),
    );
    // Pale cut edge of the wedge and a dotted peel texture.
    canvas.drawArc(ell, 0, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, rad * 0.08)
          ..color = const Color(0xFFFFFDE7).withValues(alpha: 0.85));
    final dot = Paint()..color = labShade(color, -0.18).withValues(alpha: 0.5);
    for (var i = 0; i < 9; i++) {
      final a = math.pi + 0.35 + i * 0.3;
      final q = c + Offset(math.cos(a), math.sin(a)) * rad * (0.45 + 0.2 * (i % 3));
      canvas.drawCircle(q, math.max(0.6, rad * 0.035), dot);
    }
  }

  /// Tube along [pts] (wires, paperclip, filament).
  void tube(List<_V3> pts, double r, Color color,
      {double opacity = 1, double outline = 0.45, double highlight = 0.4, Color? outlineColor}) {
    if (pts.length < 2) return;
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = cam.p(pts[i]);
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    final w = 2 * r * cam.k(pts[pts.length ~/ 2]);
    Paint st(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c.withValues(alpha: c.a * opacity);
    if (outline > 0) canvas.drawPath(path, st(w + 1.6, outlineColor ?? labShade(color, -outline)));
    canvas.drawPath(path, st(w, color));
    if (highlight > 0) {
      canvas.drawPath(path.shift(Offset(-w * 0.1, -w * 0.2)), st(w * 0.35, Colors.white.withValues(alpha: highlight)));
    }
  }

  /// Soft contact shadow on the plane y = [y]; [lift] offsets it away from
  /// the light like the HTML directional shadow.
  void shadow(_V3 base, double rx, double rz, {double opacity = 0.3, double lift = 0, double y = 0, double ry = 0}) {
    final c = _V3(base.x - 0.4 * lift, y + 0.003, base.z - 0.6 * lift);
    final k = cam.k(c);
    canvas.drawPath(
      hPath(c, rx, rz, ry: ry),
      Paint()
        ..color = Colors.black.withValues(alpha: opacity / (1 + lift * 0.8))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (0.1 + lift * 0.25) * k),
    );
  }

  void line(_V3 a, _V3 b, Color color, double width) {
    canvas.drawLine(
      cam.p(a),
      cam.p(b),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }
}

/// A sprite label (HTML `createDynamicLabel`), drawn in a final pass.
class _Label {
  const _Label(this.text, this.at, this.mult,
      {this.color = const Color(0xFFF8FAFC),
      this.bg = const Color(0xD90F172A),
      this.border = const Color(0x80EAB308)});

  final String text;
  final _V3 at;
  final double mult;
  final Color color;
  final Color bg;
  final Color border;
}

/// Draws sprite labels. Nearer labels keep their anchor; farther ones that
/// would collide are nudged upwards (the HTML staggered its labels by hand
/// to avoid overlaps).
void _drawLabels(Canvas canvas, _Cam cam, List<_Label> labels) {
  final placed = <(_Label, Rect, double)>[];
  final order = [...labels]..sort((a, b) {
      if (a.mult >= 1.5 || b.mult >= 1.5) return b.mult.compareTo(a.mult);
      return cam.depth(a.at).compareTo(cam.depth(b.at));
    });
  for (final l in order) {
    final size = (0.656 * l.mult * cam.k(l.at) * 1.1).clamp(11.0, 30.0);
    final tp = TextPainter(
      text: TextSpan(
        text: l.text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + size * 1.2, h = tp.height + size * 0.4;
    var rect = Rect.fromCenter(center: cam.p(l.at), width: w, height: h);
    // Keep the pill inside the stage (Hindi labels are wider).
    if (rect.left < 4) rect = rect.translate(4 - rect.left, 0);
    if (rect.right > _design.width - 4) rect = rect.translate(_design.width - 4 - rect.right, 0);
    for (var guard = 0; guard < 12; guard++) {
      Rect? hit;
      for (final q in placed) {
        if (q.$2.overlaps(rect.deflate(1))) {
          hit = q.$2;
          break;
        }
      }
      if (hit == null) break;
      rect = rect.translate(0, hit.top - rect.bottom - 2);
    }
    placed.add((l, rect, size));
  }
  placed.sort((a, b) => cam.depth(b.$1.at).compareTo(cam.depth(a.$1.at)));
  for (final (l, rect, size) in placed) {
    labText(
      canvas,
      l.text,
      rect.center,
      size: size,
      color: l.color,
      weight: FontWeight.w800,
      background: l.bg,
      border: l.border,
      borderWidth: math.max(1.5, size * 0.1),
      radius: size * 0.6,
      padding: EdgeInsets.symmetric(horizontal: size * 0.6, vertical: size * 0.2),
    );
  }
}

// ============================================================ PAINTER

const Color _tableWood = Color(0xFFA1663A);
const Color _sinkSteel = Color(0xFF94A3B8);
const Color _tapMetal = Color(0xFF4B5563);
const Color _sleeveRed = Color(0xFFCF2027);
const Color _soapPink = Color(0xFFF472B6);
const Color _lemonYellow = Color(0xFFFFEA00);
const Color _water = Color(0xFF38BDF8);
const Color _metal = Color(0xFFDDDDDD);
const Color _copper = Color(0xFFC86542);
const Color _wireRed = Color(0xFFEF4444);
const Color _green400 = Color(0xFF4ADE80);
const Color _red400 = Color(0xFFF87171);

class _A1Painter extends CustomPainter {
  _A1Painter({
    required this.world,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
  }) : super(repaint: repaint);

  final _World world;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> text;

  String _s(String key) => text[key] ?? key;

  _Cam get cam => _cams[world.scenario];

  double _key(_V3 a) => cam.depth(a) - 2.5 * a.y;

  @override
  void paint(Canvas canvas, Size size) {
    final r = _R3(canvas, cam);
    _background(canvas, size);
    _table(r);
    if (world.scenario == 0) {
      _paintS1(r);
    } else {
      _paintS2(r);
    }
  }

  void _background(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE));
    final c = Offset(size.width / 2, size.height * 0.38);
    final rad = size.width * 0.8;
    canvas.drawCircle(
      c,
      rad,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? const [Color(0x332563EB), Color(0x000F172A)]
              : const [Color(0xCCFFFFFF), Color(0x00E0F2FE)],
        ).createShader(Rect.fromCircle(center: c, radius: rad)),
    );
  }

  /// 20 x 12 wooden table with four legs (both scenarios).
  void _table(_R3 r) {
    final canvas = r.canvas;
    r.shadow(const _V3(0, 0, 0), 10.5, 6.5, opacity: isDark ? 0.45 : 0.22, y: -3.1);
    for (final p in const [_V3(-9.5, 0, -5.5), _V3(9.5, 0, -5.5), _V3(-9.5, 0, 5.5), _V3(9.5, 0, 5.5)]) {
      r.frustum(_V3(p.x, -3.1, p.z), _V3(p.x, -0.1, p.z), 0.1, 0.15, _tableWood, seg: 14);
    }
    r.flush();
    r.box(const _V3(0, -0.1, 0), const _V3(10, 0.1, 6), _tableWood);
    r.flush();
    // Planks and grain on the table top.
    final seam = Paint()
      ..color = const Color(0xFF5B3415).withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF6B3E1C).withValues(alpha: 0.12);
    for (var z = -4.0; z <= 4.0; z += 2) {
      canvas.drawLine(cam.p(_V3(-10, 0.001, z)), cam.p(_V3(10, 0.001, z)), seam);
    }
    for (var i = 0; i < 18; i++) {
      final z0 = -5.7 + i * 0.66;
      final path = Path();
      for (var x = -10.0; x <= 10.0; x += 1) {
        final q = cam.p(_V3(x, 0.001, z0 + 0.08 * math.sin(x * 0.7 + i * 1.7)));
        x == -10 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
      }
      canvas.drawPath(path, grain);
    }
    // Bevel highlight on the front edge.
    r.line(const _V3(-10, 0, 6), const _V3(10, 0, 6), Colors.white.withValues(alpha: 0.25), 1.5);
  }

  // ------------------------------------------------------- Scenario 1

  void _paintS1(_R3 r) {
    final w = world;
    final shirtInSink = w.shirt.pos.y < 0.3 && (w.shirt.pos.x - _spout.x).abs() < 0.2;
    // Contact shadows.
    r.shadow(const _V3(-3.5, 0, -1), 1.9, 1.5, opacity: 0.25);
    if (!shirtInSink) {
      r.shadow(w.shirt.pos.withY(0), 1.5, 1.6, opacity: 0.16, lift: w.shirt.pos.y - 0.025);
    }
    r.shadow(w.soap.pos.withY(0), 0.68, 0.42, opacity: 0.3, lift: w.soap.pos.y - 0.15);
    r.shadow(w.lemon.pos.withY(0), 0.55, 0.55, opacity: 0.3, lift: w.lemon.pos.y - 0.1);

    _sinkBack(r);
    final list = <(double, VoidCallback)>[
      (_key(const _V3(-3.5, 0, 0.3)), () => _sinkFront(r)),
      (_key(const _V3(-5.2, 0.25, -1)), () => _tap(r)),
      if (w.waterOn) (_key(const _V3(-4.05, 0.15, -1)), () => _waterStream(r, shirtInSink)),
      (_key(w.shirt.pos) + (w.dragging == w.shirt ? 0 : 0.5), () => _shirt(r)),
      (_key(w.soap.pos), () => _soap(r)),
      (_key(w.lemon.pos), () => _lemon(r)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final e in list) {
      e.$2();
    }
    for (final p in w.particles) {
      r.sphere(p.pos, 0.04 * p.scale + 0.012, p.color);
    }

    if (showLabels) {
      _drawLabels(r.canvas, r.cam, [
        _Label(_s('l_sink'), const _V3(-3.5, 0.8, 0.5), 0.4),
        // Hidden while soap / lemon rests on the stain (it would cover it).
        if (w.stainVisible &&
            (w.soap.pos - w.stainPos).length > 1.5 &&
            (w.lemon.pos - w.stainPos).length > 1.5)
          _Label(_s('l_stain'), w.stainPos + const _V3(0, 0.4, 0), 0.4),
        _Label(_s('l_soap'), w.soap.pos + const _V3(0, 0.6, 0), 0.4),
        _Label(_s('l_lemon'), w.lemon.pos + const _V3(0, 0.6, 0), 0.4),
        _Label(_s('l_tap'), const _V3(-5.2, 2.25, -1), 0.5),
        _Label(_s('l_shirt'), w.shirt.pos + const _V3(1.2, 0.4, 1.0), 0.4),
      ]);
    }
  }

  /// Wash basin (open steel box at (-3.5, 0, -1)): bottom + back/side walls.
  void _sinkBack(_R3 r) {
    const g = _V3(-3.5, 0, -1);
    r.box(g + const _V3(0, 0.05, 0), const _V3(1.7, 0.05, 1.3), _sinkSteel);
    r.box(g + const _V3(0, 0.25, -1.3), const _V3(1.7, 0.25, 0.05), _sinkSteel);
    r.box(g + const _V3(-1.7, 0.25, 0), const _V3(0.05, 0.25, 1.3), _sinkSteel);
    r.box(g + const _V3(1.7, 0.25, 0), const _V3(0.05, 0.25, 1.3), _sinkSteel);
    r.flush();
    // Brushed inner floor + drain.
    final floor = r.hEllipse(g + const _V3(0, 0.101, 0), 1.35, 1.0);
    r.canvas.drawOval(
      floor,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ]).createShader(floor),
    );
    final d = r.hEllipse(g + const _V3(0, 0.102, 0.2), 0.2);
    r.canvas.drawOval(d, Paint()..color = const Color(0xFF64748B));
    r.canvas.drawOval(d.deflate(d.width * 0.18), Paint()..color = const Color(0xFF1E293B));
  }

  void _sinkFront(_R3 r) {
    r.box(const _V3(-3.5, 0.25, 0.3), const _V3(1.7, 0.25, 0.05), _sinkSteel);
    r.flush();
  }

  /// Tap: pipe, arm, spout and the red cross handle (clickable).
  void _tap(_R3 r) {
    const b = _V3(-5.2, 0.25, -1);
    r.frustum(b, b + const _V3(0, 1.4, 0), 0.15, 0.12, _tapMetal, seg: 16);
    r.frustum(b + const _V3(0, 1.2, 0), b + const _V3(1.2, 1.2, 0), 0.1, 0.1, _tapMetal, seg: 16);
    r.frustum(b + const _V3(1.15, 0.9, 0), b + const _V3(1.15, 1.2, 0), 0.1, 0.08, _tapMetal, seg: 16);
    r.flush();
    const h = _V3(-5.2, 1.75, -1);
    final w = world;
    // Hint: the handle glows while the water still needs turning on.
    if (w.step == 3 && !w.waterOn) {
      labGlow(r.canvas, cam.p(h), 0.9 * cam.k(h), const Color(0xFFFACC15),
          intensity: 0.45 + 0.3 * math.sin(w.time * 4));
    }
    const red = Color(0xFFEF4444);
    r.sphere(h + const _V3(0, 0, -0.3), 0.15, red);
    r.box(h, const _V3(0.3, 0.075, 0.1), red);
    r.box(h, const _V3(0.1, 0.075, 0.3), red);
    r.flush();
    r.sphere(h + const _V3(-0.3, 0, 0), 0.15, red);
    r.sphere(h + const _V3(0.3, 0, 0), 0.15, red);
    r.sphere(h + const _V3(0, 0, 0.3), 0.15, red);
  }

  /// Animated water stream + droplets + ripples (HTML `toggleWater`).
  void _waterStream(_R3 r, bool shirtInSink) {
    final canvas = r.canvas;
    final w = world;
    final bottomY = shirtInSink ? 0.13 : 0.1;
    final top = cam.p(_spout);
    final bot = cam.p(_spout.withY(bottomY));
    final k = cam.k(_spout);
    final wt = 0.06 * k, wb = 0.05 * k;
    final stream = Path()
      ..moveTo(top.dx - wt, top.dy)
      ..lineTo(top.dx + wt, top.dy)
      ..lineTo(bot.dx + wb, bot.dy)
      ..lineTo(bot.dx - wb, bot.dy)
      ..close();
    canvas.drawPath(
      stream,
      Paint()
        ..shader = LinearGradient(colors: [
          _water.withValues(alpha: 0.75),
          const Color(0xFFBAE6FD).withValues(alpha: 0.95),
          _water.withValues(alpha: 0.8),
        ]).createShader(Rect.fromLTRB(top.dx - wt, top.dy, top.dx + wt, bot.dy)),
    );
    // Flowing streaks.
    final streak = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = math.max(1, wt * 0.5)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final ph = (w.time * 1.6 + i / 4) % 1;
      final y0 = top.dy + (bot.dy - top.dy) * ph;
      final y1 = math.min(bot.dy, y0 + (bot.dy - top.dy) * 0.12);
      canvas.drawLine(Offset(top.dx - wt * 0.2, y0), Offset(top.dx - wt * 0.2, y1), streak);
    }
    for (final d in w.droplets) {
      final p = _spout + _V3(d.x, d.y, d.z);
      if (p.y < bottomY) continue;
      r.sphere(p, 0.05, _water, opacity: 0.9);
    }
    // Splash ripples.
    for (var i = 0; i < 3; i++) {
      final ph = (w.time * 1.3 + i / 3) % 1;
      canvas.drawOval(
        r.hEllipse(_spout.withY(bottomY + 0.005), 0.12 + 0.55 * ph),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.7 * (1 - ph)),
      );
    }
  }

  /// School shirt with red sleeves and collar, plus the turmeric stain.
  void _shirt(_R3 r) {
    final canvas = r.canvas;
    final w = world;
    final p = w.shirt.pos;
    r.box(p + const _V3(-1.4, -0.005, -0.6), const _V3(0.6, 0.02, 0.7), _sleeveRed, ry: math.pi / 6);
    r.box(p + const _V3(1.4, -0.005, -0.6), const _V3(0.6, 0.02, 0.7), _sleeveRed, ry: -math.pi / 6);
    r.box(p, const _V3(1.2, 0.025, 1.5), Colors.white);
    r.flush();
    final top = p.y + 0.026;
    // Placket and buttons.
    r.line(_V3(p.x, top, p.z - 0.75), _V3(p.x, top, p.z + 1.45), const Color(0xFFCBD5E1), 1.2);
    for (final z in const [-0.4, 0.25, 0.9]) {
      final b = r.hEllipse(_V3(p.x, top, p.z + z), 0.06);
      canvas.drawOval(b, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawOval(
        b,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0xFF94A3B8),
      );
    }
    // Collar (torus r 0.45, tube 0.06).
    final collarC = _V3(p.x, p.y + 0.05, p.z - 1.2);
    final ck = cam.k(collarC);
    final collar = r.hEllipse(collarC, 0.45);
    canvas.drawOval(
      collar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.12 * ck + 1.2
        ..color = labShade(_sleeveRed, -0.35),
    );
    canvas.drawOval(
      collar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.12 * ck
        ..color = _sleeveRed,
    );
    canvas.drawArc(
      collar.translate(0, -0.03 * ck),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.04 * ck
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    if (w.stainVisible && w.stainOpacity > 0) _stain(r);
  }

  /// HTML `changeStainColor()`: a circle with 8 petal ellipses.
  void _stain(_R3 r) {
    final w = world;
    final c = w.stainPos;
    final path = Path()..addPath(r.hPath(c, 0.264, 0.264), Offset.zero);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final pc = c + _V3(math.cos(a) * 0.234, 0, math.sin(a) * 0.234);
      final petal = Path();
      for (var j = 0; j < 20; j++) {
        final t = j / 20 * 2 * math.pi;
        final lx = 0.176 * math.cos(t), lz = 0.088 * math.sin(t);
        final q = cam.p(pc + _V3(lx * math.cos(a) - lz * math.sin(a), 0, lx * math.sin(a) + lz * math.cos(a)));
        j == 0 ? petal.moveTo(q.dx, q.dy) : petal.lineTo(q.dx, q.dy);
      }
      path.addPath(petal..close(), Offset.zero);
    }
    final col = w.stainColor;
    r.canvas.drawPath(
      path,
      Paint()
        ..color = col.withValues(alpha: w.stainOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
    r.canvas.drawPath(
      r.hPath(c, 0.14, 0.14),
      Paint()
        ..color = labShade(col, -0.2).withValues(alpha: w.stainOpacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _soap(_R3 r) {
    final p = world.soap.pos;
    r.box(p, const _V3(0.6, 0.15, 0.35), _soapPink);
    r.flush();
    final top = r.hEllipse(p + const _V3(0, 0.151, 0), 0.42, 0.2);
    r.canvas.drawOval(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _lemon(_R3 r) => r.dome(world.lemon.pos, 0.5, _lemonYellow);

  // ------------------------------------------------------- Scenario 2

  void _paintS2(_R3 r) {
    final canvas = r.canvas;
    final w = world;
    final glow = w.bulbGlow;

    // Light pool from the bulb's point light.
    if (glow > 0.01) {
      final pool = r.hEllipse(const _V3(7, 0.002, -1), 7.5, 6);
      canvas.drawOval(
        pool,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFEA00).withValues(alpha: 0.38 * glow),
            const Color(0xFFFFEA00).withValues(alpha: 0.12 * glow),
            const Color(0x00FFEA00),
          ], stops: const [0, 0.45, 1]).createShader(pool),
      );
    }

    // Materials tray and the circuit gap target.
    r.box(const _V3(0, 0.05, -2), const _V3(4, 0.05, 1.5), const Color(0xFF475569));
    r.flush();
    r.box(_gapPos, const _V3(1.5, 0.05, 0.6), _water, opacity: 0.2);
    r.flush();
    final gapTop = Path()
      ..addPolygon([
        cam.p(const _V3(-1.5, 0.101, 0.9)),
        cam.p(const _V3(1.5, 0.101, 0.9)),
        cam.p(const _V3(1.5, 0.101, 2.1)),
        cam.p(const _V3(-1.5, 0.101, 2.1)),
      ], true);
    labDashedPath(
      canvas,
      gapTop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _water.withValues(alpha: 0.75),
      dash: 7,
      gap: 5,
      phase: w.time * 12,
    );

    // Wires (red: battery -> bulb, battery -> clip; black: bulb -> clip).
    r.tube(_bezier(const _V3(-7, 0.4, -2), const _V3(0, 0.4, -4), const _V3(6.5, 0.4, -1.5)), 0.08, _wireRed);
    r.tube(_bezier(const _V3(-7, 0.4, 0), const _V3(-4.5, 0.4, 1.5), const _V3(-1.7, 0.2, 1.5)), 0.08, _wireRed);
    r.tube(_bezier(const _V3(7.5, 0.4, -1), const _V3(5.5, 0.4, 1.5), const _V3(1.7, 0.2, 1.5)), 0.08,
        const Color(0xFF111111),
        outline: 0, highlight: 0.25);

    // Shadows.
    r.shadow(const _V3(-7, 0, -1), 0.6, 1.05, opacity: 0.3);
    r.shadow(const _V3(7, 0, -1), 0.45, 0.45, opacity: 0.3);
    r.shadow(const _V3(-1.9, 0, 1.5), 0.5, 0.2, opacity: 0.25);
    r.shadow(const _V3(1.9, 0, 1.5), 0.5, 0.2, opacity: 0.25);
    for (final o in w.items) {
      final b = _hitBounds[o.id]!;
      final inBox = o.pos.z > 2.3 && o.pos.x.abs() > 4.2 && o.pos.y < 0.5;
      r.shadow(o.pos + b.$1, b.$2.x * 0.95, b.$2.z * 1.2 + 0.05,
          opacity: 0.25, lift: math.max(0, o.pos.y - o.home.y), y: inBox ? 0.15 : 0);
    }

    final list = <(double, VoidCallback)>[
      (_key(const _V3(-7, 0, -1)), () => _battery(r)),
      (_key(const _V3(7, 0, -1)), () => _bulb(r)),
      (_key(const _V3(-1.9, 0.2, 1.5)), () => _clip(r, left: true)),
      (_key(const _V3(1.9, 0.2, 1.5)), () => _clip(r, left: false)),
      (_key(_boxConductor + const _V3(0, 0, -1.75)) + 1, () => _boxBack(r, _boxConductor, _green400)),
      (_key(_boxInsulator + const _V3(0, 0, -1.75)) + 1, () => _boxBack(r, _boxInsulator, _red400)),
      (_key(_boxConductor + const _V3(0, 0, 1.75)), () => _boxFront(r, _boxConductor, _green400)),
      (_key(_boxInsulator + const _V3(0, 0, 1.75)), () => _boxFront(r, _boxInsulator, _red400)),
      for (final o in w.items) (_key(o.pos), () => _item(r, o)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final e in list) {
      e.$2();
    }

    // Bulb glow (PointLight 0xffea00) over everything near it.
    if (glow > 0.01) {
      const fc = _V3(7, 1.15, -1);
      final c = cam.p(fc);
      final k = cam.k(fc);
      labGlow(canvas, c, 3.4 * k, const Color(0xFFFFEA00), intensity: 0.7 * glow);
      labGlow(canvas, c, 0.9 * k, Colors.white, intensity: 0.8 * glow);
    }

    // Lightning sparks over the conductor box.
    for (final s in w.sparks) {
      final path = Path();
      for (var i = 0; i < s.pts.length; i++) {
        final q = cam.p(s.pts[i]);
        i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
      }
      final a = s.life.clamp(0.0, 1.0);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFFFEA00).withValues(alpha: 0.35 * a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFFFEA00).withValues(alpha: a),
      );
    }

    final labels = <_Label>[
      if (showLabels) ...[
        _Label(_s('l_battery'), const _V3(-7, 2.2, -1), 0.5),
        _Label(_s('l_bulb'), const _V3(7, 2.4, -1), 0.5),
        _Label(_s('l_gap'), const _V3(0, -0.55, 2.5), 0.5),
        _Label(_s('l_tray'), const _V3(0, 0.25, -4.5), 0.5),
        _Label(_s('l_paperclip'), w.clip.pos + const _V3(0, 0.4, 0.4), 0.3),
        _Label(_s('l_coin'), w.coin.pos + const _V3(0, 0.8, -0.4), 0.3),
        _Label(_s('l_ruler'), w.ruler.pos + const _V3(0, 0.4, 0.4), 0.3),
        _Label(_s('l_eraser'), w.eraser.pos + const _V3(0, 0.8, -0.4), 0.3),
        _Label(_s('l_pencil'), w.pencil.pos + const _V3(0, 0.4, 0.4), 0.3),
        _Label(_s('l_conductors'), _boxConductor + const _V3(0, 1.6, 0), 0.7,
            color: _green400, border: _green400, bg: const Color(0xD90F172A)),
        _Label(_s('l_insulators'), _boxInsulator + const _V3(0, 1.6, 0), 0.7,
            color: _red400, border: _red400, bg: const Color(0xD90F172A)),
      ],
      if (w.condLabel)
        _Label(_s('l_conductor'), const _V3(0, 3.5, -1.5), 1.5,
            color: _green400, border: _green400, bg: const Color(0xF20F172A)),
      if (w.insLabel)
        _Label(_s('l_insulator'), const _V3(0, 3.5, -1.5), 1.5,
            color: _red400, border: _red400, bg: const Color(0xF20F172A)),
    ];
    _drawLabels(canvas, r.cam, labels);
  }

  /// D-cell lying along z (HTML `battery` group at (-7, 0.4, -1)).
  void _battery(_R3 r) {
    const c = _V3(-7, 0.4, -1);
    const black = Color(0xFF111111);
    r.frustum(c + const _V3(0, 0, -0.9), c + const _V3(0, 0, -0.8), 0.4, 0.4, _metal, seg: 24);
    r.frustum(c + const _V3(0, 0, -0.8), c + const _V3(0, 0, -0.6), 0.46, 0.46, black, seg: 28, capB: false);
    r.frustum(c + const _V3(0, 0, -0.6), c + const _V3(0, 0, 0.6), 0.45, 0.45, const Color(0xFFEAB308),
        seg: 28, capA: false, capB: false);
    r.frustum(c + const _V3(0, 0, 0.6), c + const _V3(0, 0, 0.8), 0.46, 0.46, black, seg: 28, capA: false);
    r.frustum(c + const _V3(0, 0, 0.8), c + const _V3(0, 0, 1.0), 0.15, 0.15, _metal, seg: 16);
    r.flush();
  }

  /// Light bulb: metal base with rings, lathe glass, supports and the
  /// M-shaped filament; glows when the circuit is closed.
  void _bulb(_R3 r) {
    final canvas = r.canvas;
    const g = _V3(7, 0.2, -1);
    final glow = world.bulbGlow;
    r.frustum(g, g + const _V3(0, 0.4, 0), 0.28, 0.28, _metal, seg: 24);
    r.flush();
    for (var i = 0; i < 3; i++) {
      final y = 0.12 + i * 0.1;
      r.frustum(g + _V3(0, y - 0.02, 0), g + _V3(0, y + 0.02, 0), 0.3, 0.3, const Color(0xFF444444), seg: 24);
      r.flush();
    }
    // Supports.
    final k = cam.k(g + const _V3(0, 0.8, 0));
    for (final sx in const [-0.15, 0.15]) {
      r.line(g + _V3(sx, 0.35, 0), g + _V3(sx, 0.85, 0), const Color(0xFF555555), math.max(1, 0.03 * k));
    }
    final fil = _catmull(const [
      _V3(-0.15, 0.85, 0),
      _V3(-0.25, 1.05, 0),
      _V3(0, 0.9, 0),
      _V3(0.25, 1.05, 0),
      _V3(0.15, 0.85, 0),
    ]).map((v) => v + g).toList();
    final filOff = Color.lerp(const Color(0xFF444444), const Color(0xFFFFF59D), glow)!;
    r.tube(fil, 0.015, filOff, outline: 0, highlight: 0);

    // Glass shell (LatheGeometry profile).
    const prof = [
      _V3(0.27, 0, 0),
      _V3(0.27, 0.15, 0),
      _V3(0.35, 0.3, 0),
      _V3(0.55, 0.55, 0),
      _V3(0.65, 0.8, 0),
      _V3(0.55, 1.1, 0),
      _V3(0.3, 1.3, 0),
      _V3(0.0, 1.35, 0),
    ];
    final smooth = _catmull(prof, seg: 4);
    final left = <Offset>[], right = <Offset>[];
    for (final s in smooth) {
      final e = r.hEllipse(g + _V3(0, 0.4 + s.y, 0), math.max(s.x, 0.001));
      left.add(Offset(e.left, e.center.dy));
      right.add(Offset(e.right, e.center.dy));
    }
    final shell = Path()..addPolygon([...left, ...right.reversed], true);
    final neck = Path()..addOval(r.hEllipse(g + const _V3(0, 0.4, 0), 0.27));
    final glass = Path.combine(PathOperation.union, shell, neck);
    final gb = glass.getBounds();
    final offCol = const Color(0xFFDDDDDD).withValues(alpha: 0.9);
    final onCol = const Color(0xFFFFFDE7).withValues(alpha: 0.42);
    canvas.drawPath(
      glass,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.35, -0.4),
          radius: 0.9,
          colors: [
            Color.lerp(Colors.white.withValues(alpha: 0.95), const Color(0xFFFFFFFF).withValues(alpha: 0.7), glow)!,
            Color.lerp(offCol, onCol, glow)!,
            Color.lerp(const Color(0xFF9CA3AF).withValues(alpha: 0.9), const Color(0xFFFDE047).withValues(alpha: 0.4), glow)!,
          ],
          stops: const [0, 0.5, 1],
        ).createShader(gb),
    );
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    if (glow > 0.01) {
      // Emissive filament shows through the clear glass.
      r.tube(fil, 0.03, const Color(0xFFFFF176).withValues(alpha: glow), outline: 0, highlight: 0.6 * glow);
    }
  }

  /// Alligator clip: sleeve + pyramidal metal jaw pointing at the gap.
  void _clip(_R3 r, {required bool left}) {
    final s = left ? -1.0 : 1.0;
    final base = _V3(1.5 * s, 0.2, 1.5);
    r.frustum(base, base + _V3(0.8 * s, 0, 0), 0.15, 0.15, left ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
        seg: 16);
    r.frustum(base + _V3(0.05 * s, 0, 0), base + _V3(-0.45 * s, 0, 0), 0.1, 0, _metal, seg: 4);
    r.flush();
  }

  /// Translucent sorting container (HTML `createOpenBox`), back half.
  void _boxBack(_R3 r, _V3 p, Color c) {
    const hw = 2.25, h = 1.0, hd = 1.75;
    final y0 = p.y, y1 = p.y + h;
    r.quad([_V3(p.x - hw, y0 + 0.05, p.z - hd), _V3(p.x + hw, y0 + 0.05, p.z - hd), _V3(p.x + hw, y0 + 0.05, p.z + hd), _V3(p.x - hw, y0 + 0.05, p.z + hd)],
        const _V3(0, 1, 0), c, opacity: 0.32, cull: false);
    r.quad([_V3(p.x - hw, y0, p.z - hd), _V3(p.x + hw, y0, p.z - hd), _V3(p.x + hw, y1, p.z - hd), _V3(p.x - hw, y1, p.z - hd)],
        const _V3(0, 0, 1), c, opacity: 0.28, cull: false, lit: false);
    r.quad([_V3(p.x - hw, y0, p.z - hd), _V3(p.x - hw, y0, p.z + hd), _V3(p.x - hw, y1, p.z + hd), _V3(p.x - hw, y1, p.z - hd)],
        const _V3(1, 0, 0), c, opacity: 0.26, cull: false, lit: false);
    r.quad([_V3(p.x + hw, y0, p.z - hd), _V3(p.x + hw, y0, p.z + hd), _V3(p.x + hw, y1, p.z + hd), _V3(p.x + hw, y1, p.z - hd)],
        const _V3(-1, 0, 0), c, opacity: 0.26, cull: false, lit: false);
    r.flush();
    final rim = Paint()
      ..color = c.withValues(alpha: 0.9)
      ..strokeWidth = math.max(1.5, 0.05 * cam.k(p))
      ..strokeCap = StrokeCap.round;
    final c0 = cam.p(_V3(p.x - hw, y1, p.z + hd)), c1 = cam.p(_V3(p.x - hw, y1, p.z - hd));
    final c2 = cam.p(_V3(p.x + hw, y1, p.z - hd)), c3 = cam.p(_V3(p.x + hw, y1, p.z + hd));
    r.canvas
      ..drawLine(c0, c1, rim)
      ..drawLine(c1, c2, rim)
      ..drawLine(c2, c3, rim);
    for (final x in [p.x - hw, p.x + hw]) {
      r.canvas.drawLine(cam.p(_V3(x, y0, p.z - hd)), cam.p(_V3(x, y1, p.z - hd)), rim..strokeWidth = 1);
    }
  }

  void _boxFront(_R3 r, _V3 p, Color c) {
    const hw = 2.25, h = 1.0, hd = 1.75;
    final y0 = p.y, y1 = p.y + h;
    r.quad([_V3(p.x - hw, y0, p.z + hd), _V3(p.x + hw, y0, p.z + hd), _V3(p.x + hw, y1, p.z + hd), _V3(p.x - hw, y1, p.z + hd)],
        const _V3(0, 0, 1), c, opacity: 0.3, cull: false, lit: false);
    r.flush();
    final rim = Paint()
      ..color = c.withValues(alpha: 0.95)
      ..strokeWidth = math.max(1.5, 0.05 * cam.k(p))
      ..strokeCap = StrokeCap.round;
    r.canvas.drawLine(cam.p(_V3(p.x - hw, y1, p.z + hd)), cam.p(_V3(p.x + hw, y1, p.z + hd)), rim);
    for (final x in [p.x - hw, p.x + hw]) {
      r.canvas.drawLine(cam.p(_V3(x, y0, p.z + hd)), cam.p(_V3(x, y1, p.z + hd)), rim..strokeWidth = 1.2);
    }
    // Glass sheen.
    final a = cam.p(_V3(p.x - hw + 0.4, y1 - 0.15, p.z + hd)), b = cam.p(_V3(p.x - hw + 1.2, y0 + 0.2, p.z + hd));
    r.canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
  }

  void _item(_R3 r, _Obj o) {
    switch (o.id) {
      case 'paperclip':
        _paperclip(r, o.pos);
      case 'ruler':
        _ruler(r, o.pos);
      case 'pencil':
        _pencil(r, o.pos);
      case 'coin':
        _coin(r, o.pos);
      case 'eraser':
        _eraser(r, o.pos);
    }
  }

  void _paperclip(_R3 r, _V3 p) {
    final pts = _catmull(const [
      _V3(-0.9, 0, 0),
      _V3(-0.9, 0, 0.45),
      _V3(0.9, 0, 0.45),
      _V3(1.05, 0, 0.225),
      _V3(0.9, 0, 0),
      _V3(-0.6, 0, 0),
      _V3(-0.75, 0, 0.15),
      _V3(-0.6, 0, 0.3),
      _V3(0.6, 0, 0.3),
    ]).map((v) => v + p).toList();
    r.tube(pts, 0.06, const Color(0xFFE2E8F0), outlineColor: const Color(0xFF475569), highlight: 0.75);
  }

  void _ruler(_R3 r, _V3 p) {
    r.box(p, const _V3(1.3, 0.05, 0.25), const Color(0xFF38BDF8));
    r.flush();
    final top = p.y + 0.051;
    final k = cam.k(p);
    for (var i = 0; i <= 20; i++) {
      final x = p.x - 1.3 + 2.6 * (20 + i * 23.6 + 2) / 512;
      final len = (i % 5 == 0 ? 24 : 12) / 64 * 0.5;
      r.line(_V3(x, top, p.z - 0.25), _V3(x, top, p.z - 0.25 + len), const Color(0xFF0F172A),
          math.max(0.9, 0.018 * k));
    }
  }

  /// Pencil lying along x: eraser (left), ferrule, hexagonal body, wood
  /// cone and graphite tip (right).
  void _pencil(_R3 r, _V3 p) {
    _V3 at(double x) => p + _V3(x, 0, 0);
    r.frustum(at(-1.0), at(-0.8), 0.06, 0.06, _soapPink, seg: 14);
    r.frustum(at(-0.8), at(-0.6), 0.062, 0.062, _metal, seg: 14);
    r.frustum(at(-0.6), at(0.6), 0.06, 0.06, const Color(0xFFEAB308), seg: 6, capA: false);
    r.frustum(at(0.6), at(0.8), 0.06, 0.02, const Color(0xFF8B5A2B), seg: 12, capA: false);
    r.frustum(at(0.8), at(0.9), 0.02, 0, const Color(0xFF222222), seg: 10, capA: false);
    r.flush();
  }

  void _coin(_R3 r, _V3 p) {
    final canvas = r.canvas;
    r.frustum(p - const _V3(0, 0.025, 0), p + const _V3(0, 0.025, 0), 0.3, 0.3, _copper, seg: 28);
    r.flush();
    final topC = p + const _V3(0, 0.026, 0);
    final face = r.hEllipse(topC, 0.3);
    canvas.drawOval(
      face,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_copper, 0.35),
          _copper,
          labShade(_copper, -0.2),
        ]).createShader(face),
    );
    canvas.drawOval(
      r.hEllipse(topC, 0.234),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, 0.012 * cam.k(p))
        ..color = const Color(0xFFA04D2E),
    );
    canvas.save();
    canvas.translate(face.center.dx, face.center.dy);
    canvas.scale(1, face.height / face.width);
    labText(canvas, _s('coin_value'), Offset.zero,
        size: face.width * 0.42, color: const Color(0xFFA04D2E), weight: FontWeight.w900);
    canvas.restore();
  }

  /// Extruded trapezoid rubber eraser.
  void _eraser(_R3 r, _V3 p) {
    const shape = [Offset(-0.3, -0.2), Offset(0.3, -0.2), Offset(0.4, 0.2), Offset(-0.2, 0.2)];
    final y1 = p.y, y0 = p.y - 0.2;
    final topPts = [for (final s in shape) _V3(p.x + s.dx, y1, p.z + s.dy)];
    final botPts = [for (final s in shape) _V3(p.x + s.dx, y0, p.z + s.dy)];
    r.quad(topPts.reversed.toList(), const _V3(0, 1, 0), _soapPink);
    for (var i = 0; i < 4; i++) {
      final j = (i + 1) % 4;
      final e = shape[j] - shape[i];
      final n = _V3(e.dy, 0, -e.dx).unit;
      r.quad([botPts[i], botPts[j], topPts[j], topPts[i]], n, _soapPink);
    }
    r.flush();
  }

  @override
  bool shouldRepaint(covariant _A1Painter old) =>
      old.world != world ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      !mapEquals(old.text, text);
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups, settings), controller, widgets, painting helpers and shell
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

  /// Success popup body and header, settings dialog.
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
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          thumbColor: accent,
        ),
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
    assert(scope != null, 'No LabStyleScope: build lab widgets inside a LabShell.');
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

/// Strings used by the shared lab shell (header, sidebar, tools, settings,
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
    'settings': 'Settings',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'font_size': 'Font Size',
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
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
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
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'light_mode': 'लाइट मोड',
    'dark_mode': 'डार्क मोड',
    'font_size': 'फ़ॉन्ट का आकार',
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
  bool settingsOpen = false;

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

  // ---------------------------------------------------------------- settings

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

  void toggleSettings() {
    style.click.play();
    settingsOpen = !settingsOpen;
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
  void showPopup(LabPopupBuilder builder, {LabTone? sound, bool silent = false}) {
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
  /// conclusion popup. When every scenario is done the popup offers
  /// "Restart Lab"; otherwise "Continue" closes it and shows the
  /// "Scenario Complete" toast.
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
    final allDone = completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(() => LabPopupContent(
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
          ));
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
    settingsOpen = false;
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

  // ignore: use_setters_to_change_properties
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

  // ignore: use_setters_to_change_properties
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
Rect labBleed(Size size) =>
    Rect.fromLTRB(-size.width * 1.5, -size.height * 1.5, size.width * 2.5, size.height * 2.5);

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
  const LabZoomViewer({super.key, required this.controller, required this.child});

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
    widget.controller.transform.value =
        tween.transform(Curves.easeOutCubic.transform(_anim.value));
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
    final target =
        (scale * factor).clamp(LabController.minZoom, LabController.maxZoom);
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
  if (amount >= 0) return Color.lerp(c, Colors.white, amount.clamp(0, 1))!;
  return Color.lerp(c, Colors.black, (-amount).clamp(0, 1))!;
}

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = Colors.white,
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
        letterSpacing: letterSpacing,
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
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, h / 2)));
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(rr, Paint()..color = background.withValues(alpha: background.a * opacity));
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
  Color color = Colors.white,
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
  Color color = Colors.white,
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
void labDashedPath(Canvas canvas, Path path, Paint paint,
    {double dash = 8, double gap = 6, double phase = 0}) {
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
void labGlow(Canvas canvas, Offset c, double r, Color color, {double intensity = 1}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
        color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.35, 1]).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(Canvas canvas, Offset c, double w, double h, {double opacity = 0.3}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
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
    canvas.drawRRect(RRect.fromRectAndRadius(front, Radius.circular(radius)), frontPaint);
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
    ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh), math.pi, -math.pi, false)
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        a(labShade(color, -0.35)),
        a(labShade(color, 0.25)),
        a(color),
        a(labShade(color, -0.45)),
      ], stops: const [0, 0.3, 0.6, 1]).createShader(rect),
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
    final lr = Rect.fromLTRB(inner.left, inner.bottom - h, inner.right, inner.bottom);
    canvas.drawRRect(
      RRect.fromRectAndCorners(lr, bottomLeft: Radius.circular(r), bottomRight: Radius.circular(r)),
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
      Rect.fromCenter(center: Offset(lr.center.dx, lr.top), width: lr.width, height: lr.width * 0.12),
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
      ..color = Colors.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(Offset(rect.right - rect.width * 0.25, y), Offset(rect.right - 3, y), g);
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
    ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r), clockwise: false)
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(Path()..addPath(path, Offset.zero)..close());
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
void labFlame(Canvas canvas, Offset base, double height, double t, {double intensity = 1}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(canvas, base.translate(0, -h * 0.45), h * 1.1, const Color(0xFFF97316), intensity: 0.55 * intensity);
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(base.dx + w * sx, base.dy - h * sy * 0.55, base.dx + w * sx * 0.9, base.dy,
        base.dx, base.dy)
    ..cubicTo(base.dx - w * sx * 0.9, base.dy, base.dx - w * sx, base.dy - h * sy * 0.55,
        base.dx, base.dy - h * sy)
    ..close();
  canvas.drawPath(flame(1, 1), Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9));
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(flame(0.35, 0.4), Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9));
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(Canvas canvas, Offset from, Offset to, double t,
    {Color color = const Color(0xFFF97316), double amp = 6, double width = 3}) {
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
  labArrow(canvas, from + u * (len - 14), to, color: color, width: width, head: 11);
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
    fill.computeLuminance() > 0.45 ? palette.onAccent : Colors.white;

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a.icon != null) ...[
                Icon(a.icon, size: 16 * s, color: fg.withValues(alpha: enabled ? 1 : 0.6)),
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

/// Lays out a list of actions as full-width buttons (sidebar) or a wrap.
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(height: 8 * scale),
          LabActionButton(action: actions[i], scale: scale, dense: dense),
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
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) & card.size
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
        _keepInside(offset.dx, home.left, home.right, bounds.left, bounds.right),
        _keepInside(offset.dy, home.top, home.bottom, bounds.top, bounds.bottom),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(double shift, double start, double end, double lo, double hi) {
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

    if (w.left == null && w.top == null && w.right == null && w.bottom == null) {
      return Center(child: Transform.translate(offset: o, child: placed));
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
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(this.text, {super.key, this.color, this.size = 11, this.icon});

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LabStyleScope.of(context).palette.accent;
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
              letterSpacing: 1.1,
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
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              style: TextStyle(color: palette.textMuted, fontSize: 12 * scale, fontWeight: FontWeight.w600),
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
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
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
              letterSpacing: 2,
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
///   header (title, language, reset, settings), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup and the settings dialog.
///
/// Every floating card (popup, settings, mission card, HUD objective and the
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
  EdgeInsets _canvasMargin(EdgeInsets pad) =>
      EdgeInsets.fromLTRB(4, 4, widget.showTools ? 56 + pad.right : 4, 4);

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 && overlay.top == 0 && overlay.right == 0 && overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        id: 'overlay-$index-${overlay.child.runtimeType}',
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
        final font = c.style.font.orAmbient(Theme.of(context).textTheme.bodyMedium);
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
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
                          duration: _resizing ? Duration.zero : const Duration(milliseconds: 380),
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
                                    child: _Sidebar(shell: widget, palette: p, scale: s),
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
                          child: _FloatingMissionCard(shell: widget, palette: p, scale: s),
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
                    if (c.popup != null) _PopupLayer(controller: c, palette: p, scale: s),
                    if (c.settingsOpen) _SettingsLayer(controller: c, palette: p, scale: s),
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

  Widget _buildCanvas(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    final w = widget;
    final instruction = _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++) _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: 60 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(text: instruction, palette: p, scale: s, label: c.t('curr_obj')),
                ),
              ),
            ),
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ToolsPanel(controller: c, palette: p, scale: s),
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

  Widget _buildCurtain(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
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
                gradient: RadialGradient(colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)], radius: 0.9),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32 * s, vertical: 24 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(begin: 0.55, end: 1.0).animate(_iconPulse),
                            child: Icon(widget.icon, size: 56 * s, color: p.accent),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.curtainMuted, fontSize: 15 * s, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                              textStyle: TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w800),
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
                label: Text(c.lang.badge, style: const TextStyle(fontWeight: FontWeight.w800)),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) => (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen ? 8.0 : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(left, 8 + pad.top, 56 + pad.right, 8 + pad.bottom);
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.shell, required this.palette, required this.scale});

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
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(4, 0))],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12 * s + pad.left, 12 + pad.top, 12 * s, 8 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _header(context, p, s),
                SizedBox(height: 12 * s),
                if (shell.scenarioNames.length > 1) ...[_scenarioSelector(p, s, f), SizedBox(height: 12 * s)],
                _targetOutput(p, s, f),
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(c.t('actions'), size: 10.5 * s, icon: Icons.touch_app),
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s),
                ],
                if (shell.sidebarExtra != null) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(shell.sidebarExtraTitle ?? c.t('controls'), size: 10.5 * s, icon: Icons.tune),
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
                padding: EdgeInsets.fromLTRB(10 * s + pad.left, 10 * s, 10 * s, 10 * s + pad.bottom),
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
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(IconData icon, String tip, VoidCallback onTap, {String? text}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17 * s, color: p.textStrong),
                if (text != null) ...[
                  SizedBox(width: 4 * s),
                  Text(
                    text,
                    style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * s),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Leaves room for the fixed menu button at top-left.
        Padding(
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
                  child: Icon(shell.icon, color: p.accent, size: 20 * s),
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
                        style: TextStyle(color: p.textMuted, fontSize: 10 * s, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          alignment: WrapAlignment.center,
          children: [
            headerBtn(Icons.translate, c.t('toggle_language'), c.toggleLanguage, text: c.lang.badge),
            headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
              c.style.click.play();
              c.requestFullReset();
            }),
            headerBtn(Icons.settings, c.t('settings'), c.toggleSettings),
          ],
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
            style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
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
      color: selected ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
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
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : (selected ? Icons.menu_book : Icons.radio_button_unchecked),
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
          LabSectionLabel(c.t('target_output'), size: 10.5 * s, icon: Icons.track_changes),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(color: p.text, fontSize: 12.5 * f, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                Text(
                  '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                  style: TextStyle(color: p.textStrong, fontSize: 11 * f, fontWeight: FontWeight.w800),
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
                                : (i == cur ? p.accent : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(color: i < cur ? p.info : (i == cur ? p.accent : p.cardBorder)),
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
                      Icon(Icons.info, size: 14 * s, color: p.accent),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null && step.concept.isNotEmpty && shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(color: p.textStrong, fontSize: 12.5 * f, fontWeight: FontWeight.w700, height: 1.4),
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
  const _FloatingMissionCard({required this.shell, required this.palette, required this.scale});

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

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: size.height - 24),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, size: 15 * s, color: p.accent),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: Text(
                      c.t('mission_obj').toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      c.style.click.play();
                      setState(() => _minimized = !_minimized);
                    },
                    child: Tooltip(
                      message: _minimized ? c.t('expand') : c.t('minimize'),
                      child: Icon(_minimized ? Icons.expand_more : Icons.expand_less, size: 20 * s, color: p.textMuted),
                    ),
                  ),
                ],
              ),
              if (!_minimized) ...[
                if (shell.objective.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Text(
                    shell.objective,
                    style: TextStyle(color: p.text, fontSize: 11.5 * s, height: 1.35, fontWeight: FontWeight.w500),
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
                          if (steps.isNotEmpty)
                            TextSpan(
                              text: '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
                              style: TextStyle(color: p.accent, fontWeight: FontWeight.w800),
                            ),
                          TextSpan(text: instruction),
                        ],
                      ),
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s, dense: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({required this.text, required this.palette, required this.scale, required this.label});

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
                Icon(Icons.info, size: 12 * s, color: palette.accent),
                SizedBox(width: 4 * s),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 9 * s,
                    letterSpacing: 1,
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
              style: TextStyle(color: palette.textStrong, fontWeight: FontWeight.w700, fontSize: 11 * s, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    Widget tool(IconData icon, String tip, VoidCallback onTap, {bool active = false}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 34 * s,
            height: 34 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: active ? p.accent.withValues(alpha: 0.18) : Colors.transparent,
            ),
            child: Icon(icon, size: 19 * s, color: active ? p.accent : p.textMuted),
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
          tool(c.showLabels ? Icons.label : Icons.label_off, c.t('tool_labels'), c.toggleLabels, active: c.showLabels),
          divider,
          tool(c.camLocked ? Icons.lock : Icons.lock_open, c.t('tool_lock'), c.toggleCamLock, active: c.camLocked),
          tool(Icons.pan_tool_alt, c.t('tool_pan'), c.togglePanMode, active: c.panMode),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.toast, required this.palette, required this.scale});

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
            position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 12)],
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
                          color: t.isError ? palette.onDanger : palette.toastText,
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
  const _PopupLayer({required this.controller, required this.palette, required this.scale});

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
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: v, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accent, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14 * s),
                          ),
                        ),
                        Icon(Icons.drag_indicator, size: 18 * s, color: p.textMuted),
                        IconButton(
                          visualDensity: VisualDensity.compact,
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
                                border: Border(bottom: BorderSide(color: p.cardBorder)),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: 1,
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
                          if (content.extra != null) ...[SizedBox(height: 10 * s), content.extra!],
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

// ================================================================= SETTINGS

class _SettingsLayer extends StatelessWidget {
  const _SettingsLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final label = TextStyle(color: p.textStrong, fontSize: 13 * s, fontWeight: FontWeight.w600);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: c.toggleSettings,
              child: const ColoredBox(color: Color(0x80000000)),
            ),
          ),
          Positioned.fill(
            child: LabMovable(
              controller: c,
              id: 'settings',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: (size.width * 0.5).clamp(260.0, 360.0 * s),
                  constraints: BoxConstraints(maxHeight: size.height * 0.88),
                  decoration: BoxDecoration(
                    color: p.dialogBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(18 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.t('settings'),
                                style: TextStyle(color: p.textStrong, fontSize: 17 * s, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: c.toggleSettings,
                              tooltip: c.t('close'),
                              icon: Icon(Icons.close, color: p.text),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('theme'), style: label)),
                            FilledButton.tonalIcon(
                              onPressed: c.toggleTheme,
                              icon: Icon(c.isDark ? Icons.dark_mode : Icons.light_mode, size: 18 * s),
                              label: Text(c.isDark ? c.t('light_mode') : c.t('dark_mode')),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('font_size'), style: label)),
                            Text(
                              '${c.fontSize.round()}px',
                              style: TextStyle(color: p.textMuted, fontSize: 12 * s),
                            ),
                          ],
                        ),
                        Slider(
                          value: c.fontSize,
                          min: c.style.font.minSize,
                          max: c.style.font.maxSize,
                          divisions: (c.style.font.maxSize - c.style.font.minSize).round(),
                          onChanged: c.setFontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
