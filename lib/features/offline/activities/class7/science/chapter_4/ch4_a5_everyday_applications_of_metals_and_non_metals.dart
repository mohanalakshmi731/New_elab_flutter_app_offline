// Imported from new-elab-app-7; Class 7 local activity.
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

/// Class 7 Science • Chapter 4 • Activity 5
/// Everyday Applications of Metals and Non-metals.
///
/// Native Flutter port of
/// `Cl7S-Ch4-A5-Everyday_Applications_of_Metals_and_Non_metals.html`.
///
/// Scenario 1 (Kitchen Conundrum): drag a material onto the crafting station
/// to make the pan body, drag a material onto the handle slot, put the pan on
/// the stove, switch the stove ON, drop butter into the pan (metal pans melt
/// it, non-metal pans char and smoke) and finally drag the hand onto the
/// handle (metal handles ZAP, insulating handles are safe).
///
/// Scenario 2 (The Circuit Challenge): drop each test item into the circuit
/// gap, watch whether the bulb glows (electrons flow for metals) and sort
/// the item into the Good / Poor conductor bin until the tray is empty.
class Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPage extends StatefulWidget {
  const Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPage({super.key});

  @override
  State<Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPage> createState() =>
      _Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, spark 2365,
/// switchTap 2585, fire 1348, magic 871.
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
  spark('spark.mp3'),
  switchTap('switch.mp3'),
  fire('fire.mp3'),
  magic('magic.mp3');

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
  static const Color slate600 = Color(0xFF475569);
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
    'appTitle': 'Everyday Applications of Metals and Non-metals',
    'appSubtitle': 'Class 7 • The World of Metals and Non-metals',
    'scen1Opt': 'Scenario 1: Kitchen Conundrum',
    'scen2Opt': 'Scenario 2: The Circuit Challenge',
    'hudDefault': 'Interact with objects to begin.',
    'analysisTitle': 'Analysis & Outcomes',

    // 3D labels
    'lblDropPan': 'DROP PAN MATERIAL',
    'lblAvail': 'AVAILABLE MATERIALS',
    'lblCopper': 'COPPER',
    'lblIron': 'IRON',
    'lblWood': 'WOOD',
    'lblCoal': 'COAL',
    'lblRubber': 'RUBBER',
    'lblAttachHandle': 'ATTACH HANDLE',
    'lblHandleMats': 'HANDLE MATERIALS',
    'lblDragStove': 'DRAG PAN TO STOVE',
    'lblButter': 'BUTTER',
    'lblIngred': 'INGREDIENTS',
    'lblDragHandle': 'DRAG TO HANDLE',
    'lblPanBody': 'PAN BODY MATERIAL',
    'lblHandle': 'HANDLE MATERIAL',
    'lblPower': 'POWER',
    'lblOn': 'ON',
    'lblOff': 'OFF',
    'lblDropConn': 'DROP TO CONNECT',
    'lblTestMats': 'TEST MATERIALS',
    'lblCopWire': 'COPPER WIRE',
    'lblIrnNail': 'IRON NAIL',
    'lblWdStick': 'WOOD STICK',
    'lblRubEraser': 'RUBBER',
    'lblGoodCond': 'Good Conductors\n(Makes Bulb Glow)',
    'lblPoorCond': 'Poor Conductors\n(Bulb Stays Dark)',
    'lblConductor': 'Conductor',
    'lblCondSub': '(Metal, completes path)',
    'lblInsulator': 'Insulator',
    'lblInsSub': '(Plastic, safety coating)',

    // Scenario titles (teacher board headings)
    's1_title': 'Kitchen Conundrum: Crafting the Perfect Cooking Pan',
    's2_title': 'The Circuit Challenge: Let There Be Light!',

    // HUD hints for every step
    's1s1_h': 'Drag Copper, Iron, Wood, or Coal to the Drop Zone to craft the pan body.',
    's1s2_h': 'Drag Wood, Rubber, or Iron to the Handle Slot to assemble the pan.',
    's1s3_h': 'Drag Pan to Stove -> Click ON -> Drag Butter into Pan.',
    's1s4_h': "Drag the Hand icon to the pan's handle to test its temperature.",
    's1s5_h': 'Scenario Complete! Review your specific observations.',
    's2s1_h': 'Drag any item from the tray to bridge the circuit gap.',
    's2s2_h': 'Observe the bulb to see if the material conducts electricity.',
    's2s3_h': 'Drag the tested item to the correct bin.',
    's2s4_h': 'Scenario Complete! Review your observations.',

    // Outcomes and HUD flashes
    'scenComp': 'Scenario Complete!',
    'hudBody': 'Crafted pan body using material.',
    'hudHandle': 'Attached handle.',
    'hudStove': "Pan placed! Now CLICK the 'ON' button on the stove.",
    'hudInsulBurn': "The pan is an insulator! It's not conducting heat, but it is burning!",
    'hudMetHeat': 'Notice how fast heat transfers through metal!',
    'hudZap': 'ZAP! SIZZLE! Metals conduct heat directly to your hand.',
    'hudSafe': 'Safe! Insulators protect you from thermal energy.',
    'hudCircComp': 'The circuit is complete! Electricity is flowing.',
    'hudCircBlock': 'The circuit is blocked. Electricity cannot flow.',
    'hudBinCorr': "Correct! Let's test the next item.",
    'hudBinErr': 'Incorrect bin! Try again.',
    'hudStoveFirst': 'Place the pan on the stove first!',
    'hudTurnOn': 'Turn ON the stove before adding butter!',
    'hudNoPanBurn': 'Oh no! The non-metal pan is burning!',
    'hudDragButter': 'Stove ON. Now drag the butter into the pan.',

    // Outcome popup text
    's1_perf_title': 'Perfect Assembly!',
    's1_perf_d1':
        '<strong>Success!</strong> Metals are good <strong>conductors</strong> of heat, which is great for cooking.',
    's1_perf_d2': 'Non-metals are poor conductors (or <strong>insulators</strong>), which makes them safe for handles.',
    'btn_try_again': 'Try Another Combination',
    's1_fail_title': 'Flawed Design!',
    's1_fail_d1': 'Your pan design failed the safety or cooking test.',
    's1_fail_rem': 'Remember: Metals = Good Conductors. Non-Metals = Insulators.',
    's1_fail_r1':
        'The non-metal body charred and didn\'t transfer heat, while the metal handle would quickly burn your hand!',
    's1_fail_r2': 'The non-metal body acted as an insulator. It charred instead of transferring heat to the food.',
    's1_fail_r3':
        'The metal handle acted as a conductor. It rapidly transferred the dangerous heat straight to your hand!',
    's2_done_title': 'Well done!',
    's2_done_d1': 'Metals like copper and iron are <strong>good conductors</strong> of electricity.',
    's2_done_d2': 'Non-metals like wood and rubber are <strong>poor conductors</strong> (insulators).',
    's2_done_d3': "That's why electrical wires are made of metal and coated with plastic for safety!",

    // Strings that were hard-coded in the HTML effects / added readouts.
    'fxGlow': 'GLOW!',
    'fxThud': 'THUD!',
    'fxZap': 'ZAP!',
    'labRecord': 'Lab Record',
    'notChosen': 'Not chosen yet',
    'noneYet': 'None yet',
    'itemsLeft': '{n} of 5 left',
  },
  'hi': {
    'appTitle': 'धातुओं और अधातुओं के दैनिक उपयोग',
    'appSubtitle': 'कक्षा 7 • धातु और अधातु की दुनिया',
    'scen1Opt': 'परिदृश्य 1: रसोई की पहेली',
    'scen2Opt': 'परिदृश्य 2: सर्किट चुनौती',
    'hudDefault': 'शुरू करने के लिए वस्तुओं के साथ बातचीत करें।',
    'analysisTitle': 'विश्लेषण और परिणाम',

    'lblDropPan': 'पैन की सामग्री यहाँ रखें',
    'lblAvail': 'उपलब्ध सामग्री',
    'lblCopper': 'तांबा',
    'lblIron': 'लोहा',
    'lblWood': 'लकड़ी',
    'lblCoal': 'कोयला',
    'lblRubber': 'रबर',
    'lblAttachHandle': 'हैंडल लगाएँ',
    'lblHandleMats': 'हैंडल की सामग्री',
    'lblDragStove': 'पैन को स्टोव पर खींचें',
    'lblButter': 'मक्खन',
    'lblIngred': 'सामग्री',
    'lblDragHandle': 'हैंडल को छूने के लिए खींचें',
    'lblPanBody': 'पैन की सामग्री',
    'lblHandle': 'हैंडल की सामग्री',
    'lblPower': 'पावर',
    'lblOn': 'चालू',
    'lblOff': 'बंद',
    'lblDropConn': 'जोड़ने के लिए यहाँ छोड़ें',
    'lblTestMats': 'परीक्षण सामग्री',
    'lblCopWire': 'तांबे का तार',
    'lblIrnNail': 'लोहे की कील',
    'lblWdStick': 'लकड़ी की छड़ी',
    'lblRubEraser': 'रबर',
    'lblGoodCond': 'सुचालक\n(बल्ब को जलाता है)',
    'lblPoorCond': 'कुचालक\n(बल्ब नहीं जलता)',
    'lblConductor': 'सुचालक',
    'lblCondSub': '(धातु, पथ पूरा करता है)',
    'lblInsulator': 'कुचालक',
    'lblInsSub': '(प्लास्टिक, सुरक्षा कोटिंग)',

    's1_title': 'रसोई की पहेली: उत्तम कुकिंग पैन बनाना',
    's2_title': 'सर्किट चुनौती: प्रकाश होने दो!',

    's1s1_h': 'पैन बनाने के लिए सामग्री को ड्रॉप ज़ोन में खींचें।',
    's1s2_h': 'हैंडल स्लॉट पर सामग्री को खींचें।',
    's1s3_h': 'पैन को स्टोव पर खींचें -> ON करें -> मक्खन को पैन में खींचें।',
    's1s4_h': 'हाथ के आइकन को पैन के हैंडल तक खींचें।',
    's1s5_h': 'परिदृश्य पूर्ण! अपने अवलोकन की समीक्षा करें।',
    's2s1_h': 'सर्किट गैप को पाटने के लिए ट्रे से कोई भी वस्तु खींचें।',
    's2s2_h': 'जांचें कि क्या सामग्री बिजली का संचालन करती है।',
    's2s3_h': 'परीक्षण की गई वस्तु को सही बिन में खींचें।',
    's2s4_h': 'परिदृश्य पूर्ण! अपने अवलोकन की समीक्षा करें।',

    'scenComp': 'परिदृश्य पूर्ण!',
    'hudBody': 'पैन का मुख्य भाग बनाया गया।',
    'hudHandle': 'हैंडल लगाया गया।',
    'hudStove': "पैन रखा गया! अब स्टोव पर 'ON' बटन दबाएं।",
    'hudInsulBurn': 'पैन एक कुचालक है! यह जल रहा है!',
    'hudMetHeat': 'ध्यान दें कि धातु के माध्यम से ऊष्मा कितनी तेजी से स्थानांतरित होती है!',
    'hudZap': 'ज़ैप! धातुएं ऊष्मा को सीधे आपके हाथ में संचालित करती हैं।',
    'hudSafe': 'सुरक्षित! कुचालक आपको थर्मल ऊर्जा से बचाते हैं।',
    'hudCircComp': 'सर्किट पूरा हो गया है! बिजली प्रवाहित हो रही है।',
    'hudCircBlock': 'सर्किट अवरुद्ध है। बिजली प्रवाहित नहीं हो सकती।',
    'hudBinCorr': 'सही! आइए अगली वस्तु का परीक्षण करें।',
    'hudBinErr': 'गलत बिन! पुन: प्रयास करें।',
    'hudStoveFirst': 'पहले पैन को स्टोव पर रखें!',
    'hudTurnOn': 'मक्खन डालने से पहले स्टोव चालू (ON) करें!',
    'hudNoPanBurn': 'अरे नहीं! अधातु का पैन जल रहा है!',
    'hudDragButter': 'स्टोव चालू है। अब मक्खन को पैन में खींचें।',

    's1_perf_title': 'उत्तम निर्माण!',
    's1_perf_d1':
        '<strong>सफलता!</strong> धातुएं ऊष्मा की <strong>सुचालक</strong> होती हैं, जो खाना पकाने के लिए बहुत अच्छा है।',
    's1_perf_d2': 'अधातुएं कुचालक (<strong>इन्सुलेटर</strong>) होती हैं, जो उन्हें हैंडल के लिए सुरक्षित बनाती हैं।',
    'btn_try_again': 'दूसरा संयोजन आज़माएं',
    's1_fail_title': 'त्रुटिपूर्ण डिज़ाइन!',
    's1_fail_d1': 'आपका पैन डिज़ाइन सुरक्षा या कुकिंग परीक्षण में विफल रहा।',
    's1_fail_rem': 'याद रखें: धातु = सुचालक। अधातु = कुचालक।',
    's1_fail_r1': 'अधातु शरीर जल गया और ऊष्मा स्थानांतरित नहीं हुई, जबकि धातु का हैंडल आपके हाथ को जला देगा!',
    's1_fail_r2': 'अधातु शरीर ने एक कुचालक के रूप में काम किया और भोजन को पकाने के बजाय जल गया।',
    's1_fail_r3': 'धातु के हैंडल ने सुचालक के रूप में काम किया और ऊष्मा को सीधे आपके हाथ में स्थानांतरित कर दिया!',
    's2_done_title': 'शाबाश!',
    's2_done_d1': 'तांबा और लोहा जैसी धातुएं बिजली की <strong>अच्छी सुचालक</strong> हैं।',
    's2_done_d2': 'लकड़ी और रबर जैसी अधातुएं <strong>कुचालक</strong> (इन्सुलेटर) हैं।',
    's2_done_d3': 'यही कारण है कि बिजली के तार धातु से बने होते हैं और सुरक्षा के लिए प्लास्टिक से ढके होते हैं!',

    'fxGlow': 'चमक!',
    'fxThud': 'धप!',
    'fxZap': 'ज़ैप!',
    'labRecord': 'प्रयोग रिकॉर्ड',
    'notChosen': 'अभी नहीं चुना',
    'noneYet': 'अभी कोई नहीं',
    'itemsLeft': '5 में से {n} बाकी',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'Kitchen Conundrum: Crafting the Perfect Cooking Pan',
      objective:
          'To build a functional cooking pan by selecting the correct materials for the pan body and handle based on their heat conductivity.',
      steps: [
        LabStep(
          concept: 'Build a pan body.',
          action:
              'You are presented with a "Pan Body" crafting station and a selection of material blocks. DRAG your chosen material for the pan body and DROP it onto the crafting station.',
          observation:
              'Mission Objective: To build a functional cooking pan by selecting the correct materials for the pan body and handle based on their heat conductivity.',
        ),
        LabStep(
          concept: 'Attach a handle.',
          action:
              'Choose a material for the handle. You have blocks of Wood, Rubber, and Iron. DRAG your chosen material and DROP it onto the handle slot.',
          observation: 'The pan body is shaped. Now it needs a secure handle to be functional.',
        ),
        LabStep(
          concept: 'Test heat conductivity.',
          action:
              "DRAG the completed pan and DROP it onto the virtual stovetop. CLICK the red 'OFF' button to turn it 'ON'. Now, DRAG the stick of butter into the pan.",
          observation: "Let's test your pan! We will observe the conduction of heat in action.",
        ),
        LabStep(
          concept: 'Test handle safety.',
          action: "Is the handle safe to touch? DRAG the hand icon to touch the end of the pan's handle.",
          observation: 'Safety check! The pan is extremely hot. Will the handle protect the user from burns?',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Review the observation popup to solidify your understanding of material properties.',
          observation: "Let's review the outcome of your material selections.",
        ),
      ],
    ),
    LabScenarioData(
      title: 'The Circuit Challenge: Let There Be Light!',
      objective:
          'To test various materials and classify them as good or poor conductors of electricity by using them to complete a circuit.',
      steps: [
        LabStep(
          concept: 'Complete the circuit.',
          action:
              'Here is a simple electrical circuit with a battery, a light bulb, and a gap. DRAG an item from the tray and DROP it into the gap between the two wire ends.',
          observation:
              'Mission Objective: To test various materials and classify them as good or poor conductors of electricity by using them to complete a circuit.',
        ),
        LabStep(
          concept: 'Observe the light bulb.',
          action:
              'Observe the light bulb carefully. Does it glow? Identify if the material conducts electricity based on whether the bulb lights up.',
          observation:
              'If a conductor is placed in the gap, electricity flows from the battery, through the item, to the bulb. If a poor conductor is used, nothing happens.',
        ),
        LabStep(
          concept: 'Sort Material.',
          action:
              'Based on your observation, DRAG the item you just tested from the circuit to one of the two bins. Test and sort all the items from the tray.',
          observation: 'Sorting time! Metals are typically good conductors, while non-metals act as insulators.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'A summary screen appears. Review the learning outcome.',
          observation: 'Understanding electrical conductivity is essential for designing safe electrical wiring.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'रसोई की पहेली: उत्तम कुकिंग पैन बनाना',
      objective: 'ऊष्मा चालकता के आधार पर पैन और हैंडल के लिए सही सामग्री चुनकर एक उपयोगी पैन बनाना।',
      steps: [
        LabStep(
          concept: 'पैन का मुख्य भाग बनाएं।',
          action: 'पैन के लिए अपनी चुनी हुई सामग्री को खींचें (DRAG) और स्टेशन पर छोड़ें (DROP)।',
          observation: 'उद्देश्य: ऊष्मा चालकता के आधार पर पैन और हैंडल के लिए सही सामग्री चुनकर एक उपयोगी पैन बनाना।',
        ),
        LabStep(
          concept: 'हैंडल लगाएँ।',
          action: 'हैंडल के लिए सामग्री चुनें। इसे खींचकर हैंडल स्लॉट पर छोड़ें।',
          observation: 'पैन को एक सुरक्षित हैंडल की आवश्यकता है।',
        ),
        LabStep(
          concept: 'उष्मा चालकता का परीक्षण करें।',
          action: "पैन को स्टोव पर रखें और 'ON' बटन दबाएं। फिर मक्खन को पैन में खींचें।",
          observation: 'अब हम उष्मा के संचालन का परीक्षण करेंगे।',
        ),
        LabStep(
          concept: 'सुरक्षा का परीक्षण करें।',
          action: 'पैन के हैंडल का तापमान जांचने के लिए हाथ के आइकन को खींचें।',
          observation: 'सुरक्षा जांच! क्या हैंडल उपयोगकर्ता को जलने से बचाएगा?',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'पदार्थों के गुणों को समझने के लिए अवलोकन पॉपअप की समीक्षा करें।',
          observation: 'आइए आपके चयन के परिणाम की समीक्षा करें।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'सर्किट चुनौती: प्रकाश होने दो!',
      objective:
          'सर्किट को पूरा करके विभिन्न सामग्रियों का परीक्षण करना और उन्हें सुचालक या कुचालक के रूप में वर्गीकृत करना।',
      steps: [
        LabStep(
          concept: 'सर्किट पूरा करें।',
          action: 'ट्रे से किसी वस्तु को खींचें और उसे दो तारों के बीच के गैप में छोड़ें।',
          observation:
              'उद्देश्य: सर्किट को पूरा करके विभिन्न सामग्रियों का परीक्षण करना और उन्हें सुचालक या कुचालक के रूप में वर्गीकृत करना।',
        ),
        LabStep(
          concept: 'बल्ब का निरीक्षण करें।',
          action: 'क्या बल्ब जलता है? पहचानें कि क्या सामग्री बिजली का संचालन करती है।',
          observation: 'सुचालक से बिजली प्रवाहित होती है और बल्ब जलता है, कुचालक से नहीं।',
        ),
        LabStep(
          concept: 'सामग्री को क्रमित करें।',
          action: 'परीक्षण की गई वस्तु को सर्किट से सही बिन (डिब्बे) में खींचें।',
          observation: 'वर्गीकरण का समय! धातुएँ अच्छी सुचालक होती हैं, अधातुएँ कुचालक।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश स्क्रीन दिखाई देती है। सीखने के परिणाम की समीक्षा करें।',
          observation: 'सुरक्षित वायरिंग डिजाइन करने के लिए विद्युत चालकता को समझना आवश्यक है।',
        ),
      ],
    ),
  ],
};

/// HUD hint key of every step (HTML `hudKey`).
const List<List<String>> _hudKeys = [
  ['s1s1_h', 's1s2_h', 's1s3_h', 's1s4_h', 's1s5_h'],
  ['s2s1_h', 's2s2_h', 's2s3_h', 's2s4_h'],
];

/// Material block labels (scenario 1).
const Map<String, String> _matLabel = {
  'copper': 'lblCopper',
  'iron': 'lblIron',
  'wood': 'lblWood',
  'coal': 'lblCoal',
  'rubber': 'lblRubber',
};

/// Circuit test item labels (scenario 2).
const Map<String, String> _itemLabel = {
  'copper': 'lblCopWire',
  'iron': 'lblIrnNail',
  'wood': 'lblWdStick',
  'rubber': 'lblRubEraser',
  'coal': 'lblCoal',
};

/// Tray positions of the circuit test items (HTML `setupCircuitStage`).
const Map<String, _V3> _trayPos = {
  'copper': _V3(14, 0.5, -6),
  'iron': _V3(22, 0.4, -6),
  'coal': _V3(14, 1.4, 0),
  'rubber': _V3(22, 0.7, 0),
  'wood': _V3(18, 0.5, 5),
};

const List<String> _allItems = ['copper', 'iron', 'wood', 'rubber', 'coal'];

bool _isMetal(String? m) => m == 'copper' || m == 'iron';

/// Resting height of an item scaled x1.5 in the circuit gap.
double _gapY(String m) => switch (m) {
  'coal' => 2.3,
  'rubber' => 0.75,
  _ => 0.55,
};

// ============================================================== LOGIC

enum _Hud { info, success, error, warning }

class _Zone {
  const _Zone(this.type, this.x, this.z, this.threshold);
  final String type;
  final double x, z, threshold;
}

class _Tween {
  _Tween(this.start, this.dur, this.onT, this.onDone, this.owner);
  final double start, dur;
  final void Function(double t) onT;
  final VoidCallback? onDone;
  final Object? owner;
}

/// Pan recogniser that only claims pointers which start on a draggable
/// object, so empty-canvas drags still pan the (unlocked) camera.
class _PickPanRecognizer extends PanGestureRecognizer {
  _PickPanRecognizer({required this.canStart});

  bool Function(Offset global) canStart;

  @override
  bool isPointerAllowed(PointerEvent event) => super.isPointerAllowed(event) && canStart(event.position);
}

class _Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPageState
    extends State<Ch4A5EverydayApplicationsOfMetalsAndNonMetalsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _MetalsScene _sc = _MetalsScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  final math.Random _rng = math.Random();
  late final Ticker _ticker;

  // HUD flash (HTML flashHUD / setHUD).
  String? _flashKey;
  _Hud _flashType = _Hud.info;
  Timer? _flashTimer;

  // Dragging.
  _Obj? _drag;
  _V3 _dragOffset = _V3.zero;

  // Interval animations (the HTML setInterval loops) driven by the ticker.
  final List<_Tween> _tweens = [];
  double _smokeAcc = 0, _heatAcc = 0, _elecAcc = 0;

  // Virtual camera move between stages.
  _View _viewFrom = _vCraft, _viewTo = _vCraft;
  double _viewStart = -10;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_sc.scenario];
  int get _step => _sc.step;
  bool get _s1 => _sc.scenario == 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker(_onTick)..start();
    _build3D(instantView: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _flashTimer?.cancel();
    _sc.floorPic?.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _sc.time).clamp(0.0, 0.1);
    _sc.time = now;

    // Camera move.
    if (_viewStart >= 0) {
      final t = ((now - _viewStart) / 0.7).clamp(0.0, 1.0);
      _sc.view = _View.lerp(_viewFrom, _viewTo, Curves.easeInOutCubic.transform(t));
      if (t >= 1) _viewStart = -10;
    }

    // Tweens.
    if (_tweens.isNotEmpty) {
      for (final tw in List.of(_tweens)) {
        if (!_tweens.contains(tw)) continue;
        final t = ((now - tw.start) / tw.dur).clamp(0.0, 1.0);
        tw.onT(t);
        if (t >= 1) {
          _tweens.remove(tw);
          tw.onDone?.call();
        }
      }
    }

    _updateParticles(dt);
    _sc.effects.removeWhere((e) => now - e.start > e.dur);
    if (_sc.press > 0 && now > _sc.pressUntil) _sc.press = 0;
    _frame.value = now;
  }

  void _tween(int ms, void Function(double t) onT, {VoidCallback? onDone, Object? owner}) {
    _tweens.add(_Tween(_sc.time, ms / 1000, onT, onDone, owner));
  }

  /// HTML `updateParticles()`: char smoke for non-metal pans, heat waves for
  /// metal pans and electrons flowing along the circuit wires. The HTML ran
  /// once per frame at 60 fps, so rates are scaled by `dt * 60`.
  void _updateParticles(double dt) {
    final f = dt * 60;
    final list = _sc.particles;
    final px = _sc.stoveX;
    if (_sc.isSmoking) {
      _smokeAcc += 0.4 * f;
      while (_smokeAcc >= 1) {
        _smokeAcc -= 1;
        list.add(
          _Particle(_PKind.smoke, _V3(px + (_rng.nextDouble() - 0.5) * 3, _panY + 1.3, (_rng.nextDouble() - 0.5) * 3)),
        );
      }
    }
    if (_sc.isHeating) {
      _heatAcc += 0.6 * f;
      while (_heatAcc >= 1) {
        _heatAcc -= 1;
        list.add(
          _Particle(_PKind.heat, _V3(px + (_rng.nextDouble() - 0.5) * 5, _panY + 0.2, (_rng.nextDouble() - 0.5) * 5)),
        );
      }
    }
    if (_sc.isConducting) {
      _elecAcc += 0.7 * f;
      while (_elecAcc >= 1) {
        _elecAcc -= 1;
        list.add(
          _Particle(_PKind.electron, _V3.zero)
            ..curve = _rng.nextInt(3)
            ..speed = 0.01 + _rng.nextDouble() * 0.01,
        );
      }
    }
    for (final p in list) {
      switch (p.kind) {
        case _PKind.smoke:
          p.pos = _V3(p.pos.x + (_rng.nextDouble() - 0.5) * 0.05 * f, p.pos.y + 0.08 * f, p.pos.z);
          p.scale += 0.02 * f;
          p.life -= 0.012 * f;
        case _PKind.heat:
          final y = p.pos.y + 0.1 * f;
          p.pos = _V3(p.pos.x + math.sin(y * 5) * 0.05 * f, y, p.pos.z);
          p.life -= 0.02 * f;
        case _PKind.electron:
          p.t += p.speed * f;
          if (p.t > 1) p.life = 0;
      }
    }
    list.removeWhere((p) => p.life <= 0);
  }

  // ------------------------------------------------------------ HUD

  void _flashHud(String key, _Hud type, [int ms = 3500]) {
    _flashTimer?.cancel();
    setState(() {
      _flashKey = key;
      _flashType = type;
    });
    _flashTimer = _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() => _flashKey = null);
    });
  }

  // ------------------------------------------------------------ scenes

  /// HTML `build3DScene()`: clears the stage and runs the step's setup.
  void _build3D({bool instantView = false}) {
    _lab.cancelPending();
    _flashTimer?.cancel();
    _flashKey = null;
    _tweens.clear();
    _sc.resetStage();
    _drag = null;

    // Virtual camera framing for the stage (HTML `resetCamera()`).
    final target = _stageView();
    if (instantView) {
      _sc.view = target;
      _viewStart = -10;
    } else if (target != _sc.view) {
      _viewFrom = _sc.view;
      _viewTo = target;
      _viewStart = _sc.time;
    }
    _lab.camLocked = true;
    if (_lab.isLabActive) _lab.resetView(sound: false);

    if (_s1) {
      switch (_step) {
        case 1:
          _setupPanBodyStage();
        case 2:
          _setupHandleStage();
        case 3:
          _setupStoveStage();
        case 4:
          _setupTouchStage();
        default:
          _showConclusion1();
      }
    } else {
      switch (_step) {
        case 1:
          _setupCircuitStage();
        case 2:
          _setupObserveStage();
        case 3:
          _setupSortingStage();
        default:
          _showConclusion2();
      }
    }
  }

  _View _stageView() {
    if (_s1) {
      if (_step <= 2) return _vCraft;
      if (_step <= 4) return _vStove;
      return _vPanDone;
    }
    return _step <= 3 ? _vCircuit : _vWire;
  }

  static _Obj _block(String m, double x, double z) =>
      _Obj(_Kind.block, m, _V3(x, 1.1, z), labelKey: _matLabel[m], labelDy: 3);

  void _setupPanBodyStage() {
    _sc.objs.addAll([_block('copper', 5, -4), _block('iron', 15, -4), _block('wood', 5, 4), _block('coal', 15, 4)]);
  }

  void _setupHandleStage() {
    _sc.objs.addAll([_block('wood', 6, 0), _block('rubber', 12, 0), _block('iron', 18, 0)]);
  }

  void _setupStoveStage() {
    _sc.stoveX = -12;
    _sc.coilOn = _sc.stoveOn;
    _sc.objs.add(
      _sc.panOnStove
          ? _Obj(_Kind.pan, 'pan', const _V3(-12, _panY, 0), draggable: false)
          : _Obj(
              _Kind.pan,
              'pan',
              const _V3(4, 0.05, 10),
              labelKey: 'lblDragStove',
              labelColor: const Color(0xFFEAB308),
              labelDy: 4.6,
            ),
    );
    _sc.objs.add(
      _Obj(_Kind.butter, 'butter', const _V3(10, 1.0, -10), labelKey: 'lblButter', subKey: 'lblIngred', labelDy: 2.0),
    );
  }

  void _setupTouchStage() {
    _sc.stoveX = -12;
    _sc.coilOn = true;
    _sc.objs.add(_Obj(_Kind.pan, 'pan', const _V3(-12, _panY, 0), draggable: false));
    _sc.hotHandle = _sc.handleMaterial == 'iron';
    if (_isMetal(_sc.panMaterial)) {
      _sc.meltedDisc = true;
      _sc.isHeating = true;
    } else {
      _sc.panCharred = true;
      _sc.isSmoking = true;
    }
    _sc.objs.add(
      _Obj(
        _Kind.hand,
        'hand',
        const _V3(14, 4, 6),
        labelKey: 'lblDragHandle',
        labelColor: const Color(0xFF3B82F6),
        labelDy: 5,
      ),
    );
  }

  void _showConclusion1() {
    _sc.isSmoking = false;
    _sc.isHeating = false;
    _sc.stoveX = 0;
    _sc.coilOn = false;
    _sc.objs.add(_Obj(_Kind.pan, 'pan', const _V3(0, _panY, 0), draggable: false));
    if (!_isMetal(_sc.panMaterial)) _sc.panCharred = true;
  }

  /// Battery, bulb, wires, clips, gap, tray and bins (HTML
  /// `setupCircuitStage` + `renderBinsAndSortedItems`). The item under test
  /// sits in the gap and is no longer shown on the tray.
  void _setupCircuitStage({bool gapItem = false, bool gapDraggable = false}) {
    final inGap = gapItem ? _sc.circuitMaterial : null;
    for (final m in const ['copper', 'iron', 'coal', 'rubber', 'wood']) {
      if (!_sc.remaining.contains(m) || m == inGap) continue;
      _sc.objs.add(_Obj(_Kind.item, m, _trayPos[m]!, labelKey: _itemLabel[m], labelDy: 3.5));
    }
    if (inGap != null) {
      _sc.objs.add(
        _Obj(
          _Kind.item,
          inGap,
          _V3(0, _gapY(inGap), 4),
          labelKey: _itemLabel[inGap],
          labelDy: 3.5,
          scale: 1.5,
          inGap: true,
          draggable: gapDraggable,
        ),
      );
    }
  }

  void _setupObserveStage() {
    _setupCircuitStage(gapItem: true);
    final m = _sc.circuitMaterial;
    if (m == null) return;
    final at = _V3(0, _gapY(m), 4);
    if (_isMetal(m)) {
      _sc.isConducting = true;
      _sc.bulbOn = true;
      _Audio.play(_Sound.spark);
      _flashHud('hudCircComp', _Hud.success, 4000);
      _lab.after(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _sc.effects.add(_Fx(_FxKind.float, 'fxGlow', at, _sc.time, 1.5, const Color(0xFFFACC15)));
      });
    } else {
      _flashHud('hudCircBlock', _Hud.error, 4000);
      _lab.after(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _Audio.play(_Sound.wrong);
        _sc.effects.add(_Fx(_FxKind.float, 'fxThud', at, _sc.time, 1.5, Colors.white));
      });
    }
    // Auto advance to the sorting step.
    _lab.after(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      _sc.isConducting = false;
      _advanceStep();
    });
  }

  void _setupSortingStage() => _setupCircuitStage(gapItem: true, gapDraggable: true);

  void _showConclusion2() {
    // The wire cut-away model is drawn by the painter.
  }

  // ------------------------------------------------------------ flow

  void _resetData() {
    _sc
      ..panMaterial = null
      ..handleMaterial = null
      ..circuitMaterial = null
      ..panOnStove = false
      ..stoveOn = false
      ..isSmoking = false
      ..isHeating = false
      ..isConducting = false;
    _sc.remaining
      ..clear()
      ..addAll(_allItems);
    _sc.sorted.clear();
  }

  /// HTML `loadScenario()`.
  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _sc.scenario = index;
      _sc.step = 1;
      _resetData();
      _build3D();
    });
  }

  /// HTML `fullReset()` (after the shell restored its own state).
  void _fullReset() {
    setState(() {
      _sc.scenario = 0;
      _sc.step = 1;
      _resetData();
      _build3D(instantView: true);
    });
  }

  /// HTML `resetScenario1()` ("Try Another Combination").
  void _resetScenario1() {
    setState(() {
      _lab.hidePopup(sound: false);
      _sc.step = 1;
      _sc
        ..panMaterial = null
        ..handleMaterial = null
        ..panOnStove = false
        ..stoveOn = false
        ..isSmoking = false
        ..isHeating = false;
      _lab.openSidebar();
      _build3D();
    });
  }

  void _advanceStep() {
    if (_step < _data.steps.length) {
      setState(() {
        _sc.step++;
        _build3D();
      });
    }
  }

  /// HTML `finishScenario()`.
  void _finishScenario() {
    _Audio.play(_Sound.success);
    _advanceStep();
    _flashHud('scenComp', _Hud.success, 1500);
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _showOutcome();
    });
  }

  /// The "Analysis & Outcomes" popup. Also marks the scenario complete and
  /// offers Continue / Restart Lab like the shared conclusion flow.
  void _showOutcome() {
    final index = _sc.scenario;
    _lab.completedScenarios.add(index);
    _lab.openSidebar();
    _lab.showPopup(() {
      final allDone = _lab.completedScenarios.length >= 2;
      return LabPopupContent(
        title: _t('analysisTitle'),
        icon: Icons.lightbulb,
        accent: _Colors.zslYellow,
        extra: _outcomeBody(index),
        actions: [
          if (index == 0) LabAction(label: _t('btn_try_again'), icon: Icons.restart_alt, onTap: _resetScenario1),
          if (allDone)
            LabAction(
              label: _lab.t('btn_restart'),
              icon: Icons.replay,
              color: _Colors.indigo600,
              foreground: Colors.white,
              onTap: _lab.requestFullReset,
            )
          else
            LabAction(
              label: _lab.t('btn_continue'),
              icon: Icons.arrow_forward,
              color: _Colors.indigo600,
              foreground: Colors.white,
              onTap: () {
                _lab.hidePopup(sound: false);
                _lab.showToast(_lab.t('msg_scenario_complete'));
              },
            ),
        ],
      );
    }, sound: _Sound.pop);
  }

  // ------------------------------------------------------------ input

  bool _canStartDrag(Offset global) {
    if (!_lab.isLabActive || _sc.locked || _lab.popup != null) return false;
    final local = labGlobalToLocal(_stageKey, global);
    return local != null && _pick(local) != null;
  }

  /// Front-most draggable object under [q] (design coordinates).
  _Obj? _pick(Offset q) {
    if (_sc.locked) return null;
    _Obj? best;
    var bestDepth = -1e9;
    for (final o in _sc.objs) {
      if (!o.visible || !o.draggable) continue;
      if (!_hitObj(_sc.view, o, q)) continue;
      final d = o.depth;
      if (d > bestDepth) {
        bestDepth = d;
        best = o;
      }
    }
    return best;
  }

  void _onDragStart(Offset q) {
    final o = _pick(q);
    if (o == null) return;
    _Audio.play(_Sound.pickup);
    _tweens.removeWhere((t) => t.owner == o);
    final w = _unproj(_sc.view, q, o.pos.y);
    _dragOffset = w - o.pos;
    _drag = o;
    _sc.dragging = o;
  }

  void _onDragUpdate(Offset q) {
    final o = _drag;
    if (o == null) return;
    final w = _unproj(_sc.view, q, o.pos.y);
    o.pos = _V3(w.x - _dragOffset.x, o.pos.y, w.z - _dragOffset.z);
    // Hover highlight of the bins while sorting (HTML onMouseMove).
    if (!_s1 && _step == 3) {
      _sc.hoverBin = null;
      for (final good in const [true, false]) {
        final bx = good ? -10.0 : 10.0;
        if (_hitBox(_sc.view, _V3(bx, 2, 12), const _V3(9, 4, 7), q)) {
          _sc.hoverBin = good;
          _sc.hoverCorrect = good == _isMetal(o.mat);
        }
      }
    }
  }

  void _onDragEnd() {
    final o = _drag;
    _drag = null;
    _sc.dragging = null;
    _sc.hoverBin = null;
    if (o == null) return;
    var dropped = false;
    for (final z in _zones()) {
      final dx = o.pos.x - z.x, dz = o.pos.z - z.z;
      if (math.sqrt(dx * dx + dz * dz) <= z.threshold && _handleDrop(o, z)) {
        dropped = true;
        break;
      }
    }
    if (!dropped) {
      o.pos = o.orig;
      _Audio.play(_Sound.drop);
    }
    setState(() {});
  }

  List<_Zone> _zones() {
    if (_s1) {
      return switch (_step) {
        1 => const [_Zone('panBody', -8, 0, 5)],
        2 => const [_Zone('panHandle', -8, 0, 5), _Zone('panHandle', -3.5, 0, 5)],
        3 => const [_Zone('stove_top', -12, 0, 6), _Zone('panInner', -12, 0, 6)],
        4 => const [_Zone('touchHandle', -4.5, 0, 5)],
        _ => const [],
      };
    }
    return switch (_step) {
      1 => const [_Zone('circuitGap', 0, 4, 5)],
      3 => const [_Zone('binGood', -10, 12, 5), _Zone('binPoor', 10, 12, 5)],
      _ => const [],
    };
  }

  /// HTML `handleDrop(obj, zone)`.
  bool _handleDrop(_Obj o, _Zone zone) {
    final m = o.mat;
    switch (zone.type) {
      case 'panBody':
        if (!const ['copper', 'iron', 'wood', 'coal'].contains(m)) return false;
        _sc.panMaterial = m;
        _sc.locked = true;
        _animateMorphToPan(o);
        _flashHud('hudBody', _Hud.success);
        return true;

      case 'panHandle':
        if (!const ['wood', 'rubber', 'iron'].contains(m)) return false;
        _sc.handleMaterial = m;
        _sc.locked = true;
        _Audio.play(_Sound.correct);
        _flashHud('hudHandle', _Hud.success);
        o.visible = false;
        _lab.after(const Duration(milliseconds: 1500), () {
          if (mounted) _advanceStep();
        });
        return true;

      case 'stove_top':
        if (o.kind != _Kind.pan) return false;
        o.pos = const _V3(-12, _panY, 0);
        o.orig = o.pos;
        o.draggable = false;
        o.labelKey = null;
        _sc.panOnStove = true;
        _Audio.play(_Sound.correct);
        _flashHud('hudStove', _Hud.info, 4000);
        return true;

      case 'panInner':
        if (m != 'butter') return false;
        if (!_sc.panOnStove) {
          _Audio.play(_Sound.wrong);
          _flashHud('hudStoveFirst', _Hud.error);
          return false;
        }
        if (!_sc.stoveOn) {
          _Audio.play(_Sound.wrong);
          _flashHud('hudTurnOn', _Hud.error);
          return false;
        }
        o.draggable = false;
        _sc.butterInPan = true;
        _sc.locked = true;
        if (_isMetal(_sc.panMaterial)) {
          _Audio.play(_Sound.fire);
          _sc.isHeating = true;
          _sc.puddleR = 0.1;
          // 45 frames x 30 ms: butter shrinks, puddle spreads.
          _tween(
            1350,
            (t) {
              _sc.butterScaleY = 1 - 0.9 * t;
              _sc.puddleR = 0.1 + 1.8 * t;
            },
            onDone: () {
              if (!mounted) return;
              o.visible = false;
              _flashHud('hudMetHeat', _Hud.success, 4000);
              _lab.after(const Duration(milliseconds: 2500), () {
                if (mounted) _advanceStep();
              });
            },
          );
        } else {
          _Audio.play(_Sound.wrong);
          _flashHud('hudInsulBurn', _Hud.error, 4000);
          _lab.after(const Duration(milliseconds: 3000), () {
            if (mounted) _advanceStep();
          });
        }
        return true;

      case 'circuitGap':
        if (!_allItems.contains(m)) return false;
        _sc.circuitMaterial = m;
        _Audio.play(_Sound.drop);
        _advanceStep();
        return true;

      case 'binGood':
      case 'binPoor':
        final good = zone.type == 'binGood';
        if (good == _isMetal(m)) {
          _Audio.play(_Sound.correct);
          _sc.sorted.add((item: m, good: good));
          _sc.remaining.remove(m);
          _sc.locked = true;
          // Settle the item into its slot in the bin.
          final slot = _binSlot(_sc.sorted.length - 1);
          final from = o.pos;
          final s0 = o.scale;
          _sc.flyingItem = m;
          o.labelKey = null;
          _tween(
            350,
            (t) {
              final e = Curves.easeOutCubic.transform(t);
              o.pos = _V3.lerp(from, slot, e);
              o.scale = s0 + (0.8 - s0) * e;
            },
            onDone: () {
              o.visible = false;
              _sc.flyingItem = null;
            },
            owner: o,
          );
          if (_sc.remaining.isEmpty) {
            _finishScenario();
          } else {
            _flashHud('hudBinCorr', _Hud.success, 2000);
            _lab.after(const Duration(milliseconds: 2000), () {
              if (!mounted) return;
              setState(() {
                _sc.step = 1; // loops back to the testing phase
                _build3D();
              });
            });
          }
        } else {
          _Audio.play(_Sound.wrong);
          _flashHud('hudBinErr', _Hud.error);
          final from = o.pos;
          final to = _V3(0, _gapY(m), 4);
          _tween(200, (t) => o.pos = _V3.lerp(from, to, t), owner: o);
        }
        return true;

      case 'touchHandle':
        if (o.kind != _Kind.hand) return false;
        _sc.locked = true;
        o.labelKey = null;
        if (_isMetal(_sc.handleMaterial)) {
          _Audio.play(_Sound.spark);
          _Audio.play(_Sound.fire);
          _sc.effects.add(_Fx(_FxKind.zap, 'fxZap', o.pos, _sc.time, 0.6, const Color(0xFFEF4444)));
          _flashHud('hudZap', _Hud.error);
          final from = o.pos;
          _tween(100, (t) => o.pos = _V3.lerp(from, o.orig, t), owner: o);
          _lab.after(const Duration(milliseconds: 2500), () {
            if (mounted) _finishScenario();
          });
        } else {
          _Audio.play(_Sound.correct);
          _sc.effects.add(_Fx(_FxKind.check, '', o.pos, _sc.time, 1.2, _Colors.green));
          _flashHud('hudSafe', _Hud.success);
          o.pos = const _V3(-4.5, 3, 0);
          _lab.after(const Duration(milliseconds: 2000), () {
            if (mounted) _finishScenario();
          });
        }
        return true;
    }
    return false;
  }

  /// Slot of the n-th sorted item inside its bin (HTML grid of 4).
  _V3 _binSlot(int n) {
    final entry = _sc.sorted[n];
    var idx = 0;
    for (var i = 0; i < n; i++) {
      if (_sc.sorted[i].good == entry.good) idx++;
    }
    final bx = entry.good ? -10.0 : 10.0;
    return _V3(bx + (idx.isEven ? -1.5 : 1.5), 1.5, 12 + (idx > 1 ? -1.5 : 1.5));
  }

  /// HTML `animateMorphToPan`: the block shrinks away, then the pan body grows
  /// on the crafting station.
  void _animateMorphToPan(_Obj o) {
    _Audio.play(_Sound.magic);
    _tween(
      200,
      (t) => o.scale = 1 - t,
      owner: o,
      onDone: () {
        o.visible = false;
        _sc.newPanScale = 0;
        _Audio.play(_Sound.correct);
        _tween(
          200,
          (t) => _sc.newPanScale = t,
          onDone: () {
            _lab.after(const Duration(milliseconds: 1500), () {
              if (mounted) _advanceStep();
            });
          },
        );
      },
    );
  }

  void _onTap(Offset q) {
    if (!_lab.isLabActive || _lab.popup != null) return;
    if (_s1 && _step >= 3 && _hitButton(_sc.view, _sc.stoveX, q)) _pressButton();
  }

  /// HTML `handleButtonClick`: the round ON / OFF button on the stove.
  void _pressButton() {
    _Audio.play(_Sound.switchTap);
    _sc.press = 0.1;
    _sc.pressUntil = _sc.time + 0.15;
    if (_sc.coilOn) return;
    if (!_sc.panOnStove) {
      _Audio.play(_Sound.wrong);
      _flashHud('hudStoveFirst', _Hud.error);
      return;
    }
    setState(() {
      _sc.coilOn = true;
      _sc.stoveOn = true;
    });
    if (!_isMetal(_sc.panMaterial)) {
      _sc.isSmoking = true;
      _sc.panCharred = true;
      _Audio.play(_Sound.wrong);
      _flashHud('hudNoPanBurn', _Hud.error, 4000);
    } else if (_step == 3) {
      _flashHud('hudDragButter', _Hud.info);
    }
  }

  // ------------------------------------------------------------ UI

  List<LabAction> _actions() {
    if (_s1 && _step == 5) {
      return [LabAction(label: _t('btn_try_again'), icon: Icons.restart_alt, highlight: true, onTap: _resetScenario1)];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.soup_kitchen,
          title: _t('appTitle'),
          subtitle: _t('appSubtitle'),
          scenarioNames: [_t('scen1Opt'), _t('scen2Opt')],
          scenarioIndex: _sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          sidebarExtraTitle: _t('labRecord'),
          sidebarExtra: _record(p, s),
          onReset: _fullReset,
          showHud: false,
          overlays: [_hud(context, s)],
          stage: LayoutBuilder(
            builder: (context, box) => LabStage(
              designSize: _design,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  _PickPanRecognizer: GestureRecognizerFactoryWithHandlers<_PickPanRecognizer>(
                    () => _PickPanRecognizer(canStart: _canStartDrag),
                    (r) => r
                      ..canStart = _canStartDrag
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = ((d) => _onDragStart(d.localPosition))
                      ..onUpdate = ((d) => _onDragUpdate(d.localPosition))
                      ..onEnd = ((_) => _onDragEnd())
                      ..onCancel = _onDragEnd,
                  ),
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    TapGestureRecognizer.new,
                    (r) => r.onTapUp = (d) => _onTap(d.localPosition),
                  ),
                },
                child: CustomPaint(
                  key: _stageKey,
                  size: _design,
                  painter: _MetalsPainter(
                    sc: _sc,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    textScale: _labelScale(box),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Keeps canvas labels readable (>= ~10 px) when the stage is scaled down
  /// on small phones.
  double _labelScale(BoxConstraints box) {
    if (!box.hasBoundedWidth || !box.hasBoundedHeight) return 1;
    final fit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
    if (fit <= 0) return 1;
    return (10.5 / (14.5 * fit)).clamp(1.0, 1.7);
  }

  /// The HTML HUD pill (info / success / error / warning), always visible at
  /// the bottom of the canvas.
  Widget _hud(BuildContext context, double s) {
    final pad = MediaQuery.paddingOf(context);
    final hints = _hudKeys[_sc.scenario];
    final text = !_lab.isLabActive ? _t('hudDefault') : _t(_flashKey ?? hints[(_step - 1).clamp(0, hints.length - 1)]);
    final type = _flashKey != null ? _flashType : _Hud.info;
    final (Color bg, Color border, Color fg, IconData icon) = switch (type) {
      _Hud.info => (const Color(0xF23B82F6), const Color(0xFF3B82F6), Colors.white, Icons.info),
      _Hud.success => (const Color(0xF222C55E), const Color(0xFF22C55E), Colors.white, Icons.check_circle),
      _Hud.error => (const Color(0xF2EF4444), const Color(0xFFEF4444), Colors.white, Icons.cancel),
      _Hud.warning => (const Color(0xF2EAB308), const Color(0xFFEAB308), const Color(0xFF0F172A), Icons.error),
    };
    return Positioned(
      left: 12,
      right: 60 + pad.right,
      bottom: 8 + pad.bottom,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 540 * s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 7 * s),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: fg, size: 20 * s),
                  SizedBox(width: 8 * s),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5 * s,
                        height: 1.25,
                        shadows: const [Shadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
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

  /// Sidebar read-out of the current design / sorting progress.
  Widget _record(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    String mat(String? m) => m == null ? _t('notChosen') : _t(_matLabel[m]!);
    String first(String key) => _t(key).split('\n').first;
    String items(bool good) {
      final list = [
        for (final e in _sc.sorted)
          if (e.good == good) _t(_itemLabel[e.item]!),
      ];
      return list.isEmpty ? _t('noneYet') : list.join(', ');
    }

    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _s1
            ? [
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('lblPanBody'),
                  value: mat(_sc.panMaterial),
                  valueColor: _sc.panMaterial == null ? p.textMuted : null,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('lblHandle'),
                  value: mat(_sc.handleMaterial),
                  valueColor: _sc.handleMaterial == null ? p.textMuted : null,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('lblPower'),
                  value: _sc.coilOn ? _t('lblOn') : _t('lblOff'),
                  valueColor: _sc.coilOn ? _Colors.green : _Colors.red,
                ),
              ]
            : [
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: first('lblGoodCond'),
                  value: items(true),
                  valueColor: const Color(0xFF4ADE80),
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: first('lblPoorCond'),
                  value: items(false),
                  valueColor: const Color(0xFF2DD4BF),
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('lblTestMats'),
                  value: labFormat(_t('itemsLeft'), {'n': _sc.remaining.length}),
                ),
              ],
      ),
    );
  }

  /// Body of the "Analysis & Outcomes" popup (HTML `finishScenario`).
  Widget _outcomeBody(int index) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final base = TextStyle(color: p.text, fontSize: 14.3 * f, height: 1.5, fontWeight: FontWeight.w500);

    Widget para(String key, {TextStyle? style}) => Padding(
      padding: EdgeInsets.only(bottom: 10 * s),
      child: Text.rich(TextSpan(children: _rich(_t(key)), style: style ?? base)),
    );

    final IconData icon;
    final Color color;
    final String title;
    final List<Widget> body;
    if (index == 0) {
      final metalBody = _isMetal(_sc.panMaterial);
      final safeHandle = !_isMetal(_sc.handleMaterial);
      if (metalBody && safeHandle) {
        icon = Icons.check_circle;
        color = _Colors.green;
        title = _t('s1_perf_title');
        body = [para('s1_perf_d1'), para('s1_perf_d2')];
      } else {
        final reason = !metalBody && !safeHandle ? 's1_fail_r1' : (!metalBody ? 's1_fail_r2' : 's1_fail_r3');
        icon = Icons.warning_rounded;
        color = _Colors.red;
        title = _t('s1_fail_title');
        body = [
          para('s1_fail_d1'),
          para(
            reason,
            style: base.copyWith(
              fontStyle: FontStyle.italic,
              color: p.isDark ? _Colors.slate300 : _Colors.slate600,
            ),
          ),
          SizedBox(height: 4 * s),
          para(
            's1_fail_rem',
            style: base.copyWith(color: _Colors.zslYellow, fontWeight: FontWeight.w800, fontSize: 12.5 * f),
          ),
        ];
      }
    } else {
      icon = Icons.lightbulb;
      color = _Colors.zslYellow;
      title = _t('s2_done_title');
      body = [para('s2_done_d1'), para('s2_done_d2'), para('s2_done_d3')];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 36 * s, color: color),
            SizedBox(width: 10 * s),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color, fontSize: 19 * s, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * s),
        ...body,
      ],
    );
  }
}

/// Turns the HTML `<strong>` markup into bold spans.
List<InlineSpan> _rich(String text) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'<strong>(.*?)</strong>');
  var i = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
    spans.add(
      TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    i = m.end;
  }
  if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
  return spans;
}

// ============================================================ GEOMETRY
//
// The HTML used an orthographic Three.js camera at (30, 45, 30) looking at
// the origin. The same projection is used here, so every object keeps its
// HTML world position:  screen-x ∝ 0.707 (x - z),
//                       screen-down ∝ 0.514 (x + z) - 0.686 y.

const Size _design = Size(960, 540);
const Offset _center = Offset(480, 256);
const double _px = 0.70710678;
const double _pd = 0.51449576;
const double _py = 0.68599434;

/// Vertical squash of a horizontal circle seen by the camera.
const double _ellY = 0.72760688;

/// Unit vector from the scene towards the camera.
const _V3 _viewDir = _V3(0.48507125, 0.72760688, 0.48507125);

/// Height of a pan resting on the stove plate.
const double _panY = 1.6;

/// Per-stage camera framing (pixels per unit and screen-space centre).
const _View _vCraft = _View(16, 2.5, 1.2);
const _View _vStove = _View(16.5, 1.6, -0.8);
const _View _vPanDone = _View(21, 4.2, 1.4);
const _View _vCircuit = _View(14.2, 1.2, 2.2);
const _View _vWire = _View(19.5, -1.6, -3.4);

const Map<String, Color> _matColor = {
  'copper': Color(0xFFC87B5A),
  'iron': Color(0xFF555555),
  'wood': Color(0xFFCCA677),
  'coal': Color(0xFF1A1A1A),
  'rubber': Color(0xFF333333),
};
const Color _butterColor = Color(0xFFFFFCA8);
const Color _ghostColor = Color(0xFF60A5FA);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  static const _V3 zero = _V3(0, 0, 0);
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  double get length => math.sqrt(x * x + y * y + z * z);
  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

@immutable
class _View {
  const _View(this.k, this.cu, this.cw);
  final double k, cu, cw;
  static _View lerp(_View a, _View b, double t) =>
      _View(a.k + (b.k - a.k) * t, a.cu + (b.cu - a.cu) * t, a.cw + (b.cw - a.cw) * t);
  @override
  bool operator ==(Object other) => other is _View && other.k == k && other.cu == cu && other.cw == cw;
  @override
  int get hashCode => Object.hash(k, cu, cw);
}

Offset _proj(_View v, double x, double y, double z) => Offset(
      _center.dx + v.k * (_px * (x - z) - v.cu),
      _center.dy + v.k * (_pd * (x + z) - _py * y - v.cw),
    );

/// Inverse projection onto the horizontal plane at height [y] (the HTML drag
/// plane).
_V3 _unproj(_View v, Offset p, double y) {
  final u = (p.dx - _center.dx) / v.k + v.cu;
  final w = (p.dy - _center.dy) / v.k + v.cw;
  final a = u / _px; // x - z
  final b = (w + _py * y) / _pd; // x + z
  return _V3((a + b) / 2, y, (b - a) / 2);
}

List<Offset> _convexHull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Offset>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// True when [q] lies inside the projected outline of an axis-aligned box.
bool _hitBox(_View v, _V3 c, _V3 size, Offset q) {
  final pts = <Offset>[
    for (final dx in const [-0.5, 0.5])
      for (final dy in const [-0.5, 0.5])
        for (final dz in const [-0.5, 0.5])
          _proj(v, c.x + dx * size.x, c.y + dy * size.y, c.z + dz * size.z),
  ];
  return (Path()..addPolygon(_convexHull(pts), true)).contains(q);
}

_V3 _itemBox(String m, bool inGap) => switch (m) {
      'copper' => const _V3(4, 2, 4),
      'iron' || 'wood' => const _V3(6, 2, 2),
      'rubber' => inGap ? const _V3(5, 2, 4) : const _V3(4, 2, 5),
      _ => const _V3(4, 4, 4),
    };

/// Hit test of a draggable object (the HTML hit boxes, slightly enlarged
/// for touch).
bool _hitObj(_View v, _Obj o, Offset q) {
  const pad = _V3(0.6, 0.6, 0.6);
  switch (o.kind) {
    case _Kind.block:
      return _hitBox(v, o.pos, const _V3(2.5, 1.8, 2.5) * o.scale + pad, q);
    case _Kind.pan:
      return _hitBox(v, o.pos + const _V3(2.6, 0.75, 0), const _V3(14.6, 2.2, 9.4), q);
    case _Kind.butter:
      return _hitBox(v, o.pos, const _V3(5, 3, 4), q);
    case _Kind.hand:
      final c = _proj(v, o.pos.x, o.pos.y, o.pos.z);
      return (q - (c + Offset(-0.5, 0.2) * v.k)).distance < 3.4 * v.k;
    case _Kind.item:
      return _hitBox(v, o.pos, _itemBox(o.mat, o.inGap) * o.scale + pad, q);
  }
}

/// The round ON / OFF button on the stove's control pad.
bool _hitButton(_View v, double stoveX, Offset q) =>
    _hitBox(v, _V3(stoveX + 13, 1.3, 0), const _V3(4.4, 1.0, 4.4), q);

// ========================================================== SCENE MODEL

enum _Kind { block, pan, butter, hand, item }

class _Obj {
  _Obj(
    this.kind,
    this.mat,
    this.pos, {
    this.draggable = true,
    this.labelKey,
    this.subKey,
    this.labelColor = Colors.white,
    this.labelDy = 3,
    this.scale = 1,
    this.inGap = false,
  }) : orig = pos;

  final _Kind kind;

  /// Material name ('copper', 'iron', 'wood', 'coal', 'rubber') or the
  /// object type ('pan', 'butter', 'hand').
  final String mat;
  _V3 pos;
  _V3 orig;
  bool draggable;
  bool visible = true;
  String? labelKey;
  final String? subKey;
  final Color labelColor;
  final double labelDy;
  double scale;
  final bool inGap;

  /// Distance towards the camera (bigger = closer), used for picking and
  /// painter's-algorithm ordering.
  double get depth => pos.x + pos.z + pos.y * 1.5;
}

enum _PKind { smoke, heat, electron }

class _Particle {
  _Particle(this.kind, this.pos);
  final _PKind kind;
  _V3 pos;
  double life = 1;
  double scale = 1;
  double t = 0;
  double speed = 0.01;
  int curve = 0;
}

enum _FxKind { float, zap, check }

/// Screen effects ("GLOW!", "THUD!", "ZAP!", check mark).
class _Fx {
  const _Fx(this.kind, this.textKey, this.at, this.start, this.dur, this.color);
  final _FxKind kind;
  final String textKey;
  final _V3 at;
  final double start;
  final double dur;
  final Color color;
}

/// Mutable scene state shared by the State (logic) and the painter.
class _MetalsScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  _View view = _vCraft;

  // HTML State.data
  String? panMaterial, handleMaterial, circuitMaterial;
  bool panOnStove = false;
  bool stoveOn = false;
  bool isSmoking = false;
  bool isHeating = false;
  bool isConducting = false;
  final List<String> remaining = [..._allItems];
  final List<({String item, bool good})> sorted = [];

  // Current stage
  final List<_Obj> objs = [];
  _Obj? dragging;
  bool locked = false;
  double newPanScale = -1;
  double stoveX = -12;
  bool coilOn = false;
  double press = 0;
  double pressUntil = 0;
  bool panCharred = false;
  bool meltedDisc = false;
  bool hotHandle = false;
  bool butterInPan = false;
  double butterScaleY = 1;
  double puddleR = 0;
  bool bulbOn = false;
  bool? hoverBin;
  bool hoverCorrect = false;
  String? flyingItem;
  final List<_Particle> particles = [];
  final List<_Fx> effects = [];

  // Cached floor picture.
  ui.Picture? floorPic;
  _View? floorView;
  bool? floorDark;
  Size? floorSize;

  _Obj? obj(_Kind k) => objs.where((o) => o.kind == k).firstOrNull;

  /// HTML `clearScene()`.
  void resetStage() {
    objs.clear();
    particles.clear();
    effects.clear();
    dragging = null;
    locked = false;
    newPanScale = -1;
    coilOn = false;
    press = 0;
    panCharred = false;
    meltedDisc = false;
    hotHandle = false;
    butterInPan = false;
    butterScaleY = 1;
    puddleR = 0;
    bulbOn = false;
    hoverBin = null;
    flyingItem = null;
  }
}

/// Circuit wires (HTML `QuadraticBezierCurve3`): battery (+) to bulb (red),
/// bulb to the right clip and battery (-) to the left clip (black).
const List<List<_V3>> _wireCurves = [
  [_V3(-12, 1.2, -7), _V3(-1, 0.5, -14), _V3(7, 1.2, -4)],
  [_V3(9, 1.2, -4), _V3(12, 0.5, 4), _V3(4, 0.5, 4)],
  [_V3(-12, 1.2, -1.5), _V3(-14, 0.5, 4), _V3(-4, 0.5, 4)],
];

_V3 _bez(List<_V3> c, double t) {
  final u = 1 - t;
  return c[0] * (u * u) + c[1] * (2 * u * t) + c[2] * (t * t);
}

// Wire cut-away model (scenario 2 conclusion): local axis X from -16 to 7.
const double _wireRy = math.pi / 6;
const double _wireRz = 6 * math.pi / 180;
const double _wireS = 1.4;
const _V3 _wireP = _V3(2, 5, -2);

_V3 _wt(double lx, double ly, double lz) {
  final x = lx * _wireS, y = ly * _wireS, z = lz * _wireS;
  final x1 = x * math.cos(_wireRz) - y * math.sin(_wireRz);
  final y1 = x * math.sin(_wireRz) + y * math.cos(_wireRz);
  final x2 = x1 * math.cos(_wireRy) + z * math.sin(_wireRy);
  final z2 = -x1 * math.sin(_wireRy) + z * math.cos(_wireRy);
  return _V3(_wireP.x + x2, _wireP.y + y1, _wireP.z + z2);
}

/// The cartoon hand from the HTML SVG (viewBox 0..100).
final Path _handFill = Path()
  ..moveTo(40, 65)
  ..lineTo(40, 40)
  ..cubicTo(40, 36, 36, 36, 34, 40)
  ..lineTo(34, 60)
  ..moveTo(34, 60)
  ..lineTo(34, 25)
  ..cubicTo(34, 21, 29, 21, 27, 25)
  ..lineTo(27, 60)
  ..moveTo(27, 65)
  ..lineTo(27, 35)
  ..cubicTo(27, 31, 23, 31, 21, 35)
  ..lineTo(21, 65)
  ..moveTo(21, 65)
  ..lineTo(21, 45)
  ..cubicTo(21, 41, 17, 41, 15, 45)
  ..lineTo(15, 70)
  ..cubicTo(15, 80, 25, 90, 35, 90)
  ..lineTo(45, 90)
  ..cubicTo(55, 90, 65, 80, 65, 70)
  ..lineTo(60, 45)
  ..cubicTo(58, 41, 52, 43, 50, 47)
  ..lineTo(46, 62);

final Path _handOutline = Path()
  ..moveTo(40, 40)
  ..cubicTo(40, 36, 36, 36, 34, 40)
  ..moveTo(34, 25)
  ..cubicTo(34, 21, 29, 21, 27, 25)
  ..moveTo(27, 35)
  ..cubicTo(27, 31, 23, 31, 21, 35)
  ..moveTo(21, 45)
  ..cubicTo(21, 41, 17, 41, 15, 45)
  ..lineTo(15, 70)
  ..cubicTo(15, 80, 25, 90, 35, 90)
  ..lineTo(45, 90)
  ..cubicTo(55, 90, 65, 80, 65, 70)
  ..lineTo(60, 45)
  ..cubicTo(58, 41, 52, 43, 50, 47)
  ..lineTo(46, 62);

// ============================================================== PAINTER

class _MetalsPainter extends CustomPainter {
  _MetalsPainter({
    required this.sc,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    this.textScale = 1,
  }) : super(repaint: repaint);

  final _MetalsScene sc;
  final double textScale;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  _View _v = _vCraft;

  String _t(String key) => labTr(_i18n, lang, key);
  double get _k => _v.k;
  Offset _p(double x, double y, double z) => _proj(_v, x, y, z);
  Offset _pv(_V3 a) => _proj(_v, a.x, a.y, a.z);

  /// Floor point hit by the shadow of (x, y, z) (light at (10, 30, 20)).
  Offset _sh(double x, double y, double z) => _p(x - y / 3, 0, z - y * 2 / 3);

  Rect _ell(double x, double y, double z, double r) =>
      Rect.fromCenter(center: _p(x, y, z), width: 2 * r * _k, height: 2 * r * _k * _ellY);

  @override
  void paint(Canvas canvas, Size size) {
    _v = sc.view;
    _floor(canvas, size);
    if (sc.scenario == 0) {
      if (sc.step <= 2) {
        _craftStage(canvas);
      } else if (sc.step <= 4) {
        _stoveStage(canvas);
      } else {
        _doneStage(canvas);
      }
    } else if (sc.step <= 3) {
      _circuitStage(canvas);
    } else {
      _wireStage(canvas);
    }
    _paintEffects(canvas);
  }

  // ---------------------------------------------------------------- floor

  void _floor(Canvas canvas, Size size) {
    if (sc.floorPic == null || sc.floorView != _v || sc.floorDark != isDark || sc.floorSize != size) {
      sc.floorPic?.dispose();
      final rec = ui.PictureRecorder();
      _paintFloor(Canvas(rec), size);
      sc.floorPic = rec.endRecording();
      sc.floorView = _v;
      sc.floorDark = isDark;
      sc.floorSize = size;
    }
    canvas.drawPicture(sc.floorPic!);
  }

  /// The warm wooden floor (HTML floor plane #d98d58) with planks.
  void _paintFloor(Canvas c, Size size) {
    final b = labBleed(size);
    c.drawRect(b, Paint()..color = const Color(0xFFD98D58));
    const plank = 4.0;
    final seam = Paint()
      ..color = const Color(0x2E6B3410)
      ..strokeWidth = 1.2;
    final light = Paint()..color = const Color(0x0EFFFFFF);
    final dark = Paint()..color = const Color(0x0C5A2A08);
    var i = 0;
    for (var z = -64.0; z < 64; z += plank, i++) {
      c.drawPath(
        Path()..addPolygon([_p(-90, 0, z), _p(90, 0, z), _p(90, 0, z + plank), _p(-90, 0, z + plank)], true),
        i.isEven ? light : dark,
      );
      c.drawLine(_p(-90, 0, z), _p(90, 0, z), seam);
      final off = (i * 7.3) % 13;
      for (var x = -90.0 + off; x < 90; x += 13 + (i % 3) * 3) {
        c.drawLine(_p(x, 0, z), _p(x, 0, z + plank), seam);
      }
    }
    c.drawRect(
      b,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x00000000), Color(isDark ? 0x6B000000 : 0x38000000)],
          stops: const [0.45, 1],
        ).createShader(Rect.fromCircle(center: _center, radius: 640)),
    );
  }

  // ------------------------------------------------------------ primitives

  void _shadowPts(Canvas c, List<_V3> pts, {double opacity = 0.26, double blur = 5}) {
    final hull = _convexHull([for (final q in pts) _sh(q.x, q.y, q.z)]);
    if (hull.length < 3) return;
    c.drawPath(
      Path()..addPolygon(hull, true),
      Paint()
        ..color = Colors.black.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void _shadowBox(Canvas c, double cx, double cy, double cz, double sx, double sy, double sz,
      {double opacity = 0.26}) {
    _shadowPts(c, [
      for (final dx in const [-0.5, 0.5])
        for (final dy in const [-0.5, 0.5])
          for (final dz in const [-0.5, 0.5]) _V3(cx + dx * sx, cy + dy * sy, cz + dz * sz),
    ], opacity: opacity);
  }

  void _shadowCyl(Canvas c, double x, double z, double y0, double y1, double r, {double opacity = 0.26}) {
    final pts = <_V3>[];
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final dx = math.cos(a) * r, dz = math.sin(a) * r;
      pts
        ..add(_V3(x + dx, y0, z + dz))
        ..add(_V3(x + dx, y1, z + dz));
    }
    _shadowPts(c, pts, opacity: opacity);
  }

  /// Axis-aligned box: top, +Z (front-left) and +X (front-right) faces.
  ({Path top, Path left, Path right}) _box(
    Canvas c,
    double cx,
    double cy,
    double cz,
    double sx,
    double sy,
    double sz,
    Color color, {
    double opacity = 1,
    bool edges = true,
  }) {
    final x0 = cx - sx / 2, x1 = cx + sx / 2;
    final y0 = cy - sy / 2, y1 = cy + sy / 2;
    final z0 = cz - sz / 2, z1 = cz + sz / 2;
    final top = Path()..addPolygon([_p(x0, y1, z0), _p(x1, y1, z0), _p(x1, y1, z1), _p(x0, y1, z1)], true);
    final right = Path()..addPolygon([_p(x1, y1, z0), _p(x1, y1, z1), _p(x1, y0, z1), _p(x1, y0, z0)], true);
    final left = Path()..addPolygon([_p(x0, y1, z1), _p(x1, y1, z1), _p(x1, y0, z1), _p(x0, y0, z1)], true);
    Color a(Color col) => col.withValues(alpha: col.a * opacity);
    c.drawPath(
      left,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a(labShade(color, 0.08)), a(labShade(color, -0.1))],
        ).createShader(left.getBounds()),
    );
    c.drawPath(
      right,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a(labShade(color, -0.18)), a(labShade(color, -0.34))],
        ).createShader(right.getBounds()),
    );
    c.drawPath(top, Paint()..color = a(labShade(color, 0.16)));
    if (edges) {
      final e = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..color = a(labShade(color, -0.55).withValues(alpha: 0.45));
      c
        ..drawPath(top, e)
        ..drawPath(left, e)
        ..drawPath(right, e);
      // Bright front edge.
      c.drawLine(
        _p(x0, y1, z1),
        _p(x1, y1, z1),
        Paint()
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.22 * opacity),
      );
    }
    return (top: top, left: left, right: right);
  }

  /// Upright (optionally tapered) cylinder from y0 to y1.
  void _cylV(Canvas c, double x, double z, double y0, double y1, double rb, double rt, Color color,
      {Color? top, double opacity = 1}) {
    final b = _ell(x, y0, z, rb), t = _ell(x, y1, z, rt);
    Color a(Color col) => col.withValues(alpha: col.a * opacity);
    final side = Path()
      ..moveTo(t.left, t.center.dy)
      ..lineTo(b.left, b.center.dy)
      ..arcTo(b, math.pi, -math.pi, false)
      ..lineTo(t.right, t.center.dy)
      ..arcTo(t, 0, math.pi, false)
      ..close();
    final bounds = Rect.fromLTRB(math.min(b.left, t.left), t.top, math.max(b.right, t.right), b.bottom);
    c.drawPath(
      side,
      Paint()
        ..shader = LinearGradient(
          colors: [a(labShade(color, 0.22)), a(labShade(color, 0.06)), a(color), a(labShade(color, -0.4))],
          stops: const [0, 0.28, 0.58, 1],
        ).createShader(bounds),
    );
    c.drawOval(t, Paint()..color = a(top ?? labShade(color, 0.14)));
  }

  void _ring(Canvas c, double x, double y, double z, double r0, double r1, Color col) {
    c.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(_ell(x, y, z, r1))
        ..addOval(_ell(x, y, z, r0)),
      Paint()..color = col,
    );
  }

  /// Cylinder (or cone when one radius is 0) between two world points, with
  /// the end facing the camera capped.
  void _rod(Canvas c, _V3 a, _V3 b, double ra, double rb, Color color,
      {double opacity = 1, Color? capColor, Color? rim, bool sheen = true}) {
    final axis = b - a;
    final l3 = axis.length;
    if (l3 < 1e-6) return;
    final facing = axis.dot(_viewDir) / l3;
    final pa = _pv(a), pb = _pv(b);
    final d = pb - pa;
    final len = d.distance;
    final u = len < 1e-3 ? const Offset(1, 0) : d / len;
    var n = Offset(-u.dy, u.dx);
    if (n.dy > 0 || (n.dy == 0 && n.dx > 0)) n = -n; // points towards the light
    final wa = ra * _k, wb = rb * _k;
    final wm = math.max(wa, wb);
    Color o(Color x) => x.withValues(alpha: x.a * opacity);
    final body = Paint()
      ..shader = ui.Gradient.linear(
        pa + n * wm,
        pa - n * wm,
        [o(labShade(color, 0.4)), o(labShade(color, 0.06)), o(color), o(labShade(color, -0.45))],
        const [0, 0.3, 0.55, 1],
      );
    final ang = math.atan2(u.dy, u.dx);
    final minor = math.max(facing.abs(), 0.03);
    void cap(Offset ctr, double r, Paint paint) {
      if (r <= 0.01) return;
      c
        ..save()
        ..translate(ctr.dx, ctr.dy)
        ..rotate(ang)
        ..drawOval(Rect.fromCenter(center: Offset.zero, width: 2 * r * minor, height: 2 * r), paint)
        ..restore();
    }

    final frontIsB = facing >= 0;
    cap(frontIsB ? pa : pb, frontIsB ? wa : wb, body);
    c.drawPath(Path()..addPolygon([pa + n * wa, pb + n * wb, pb - n * wb, pa - n * wa], true), body);
    if (sheen && len > 2) {
      c.drawLine(
        pa + n * (wa * 0.45),
        pb + n * (wb * 0.45),
        Paint()
          ..strokeWidth = math.max(1.0, 0.22 * math.min(wa, wb))
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.26 * opacity),
      );
    }
    cap(frontIsB ? pb : pa, frontIsB ? wb : wa, Paint()..color = o(capColor ?? labShade(color, 0.12)));
    if (rim != null) {
      cap(
        frontIsB ? pb : pa,
        frontIsB ? wb : wa,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, 0.12 * wm)
          ..color = o(rim),
      );
    }
  }

  /// Wire / tube along a 3D polyline.
  void _tube(Canvas c, List<_V3> pts, double r, Color color) {
    final path = Path();
    final shadow = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = _pv(pts[i]);
      final s = _sh(pts[i].x, pts[i].y, pts[i].z);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
        shadow.moveTo(s.dx, s.dy);
      } else {
        path.lineTo(q.dx, q.dy);
        shadow.lineTo(s.dx, s.dy);
      }
    }
    final w = 2 * r * _k;
    Paint stroke(double width, Color col) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = col;
    c
      ..drawPath(
        shadow,
        stroke(w, Colors.black.withValues(alpha: 0.2))..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.5),
      )
      ..drawPath(path, stroke(w, labShade(color, -0.35)))
      ..drawPath(path, stroke(w * 0.7, color))
      ..drawPath(path.shift(Offset(-0.1 * w, -0.2 * w)), stroke(w * 0.22, labShade(color, 0.5).withValues(alpha: 0.6)));
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.annotation` chip (dark, rounded, bold) with an optional yellow
  /// uppercase subtitle.
  void _annot(Canvas c, String text, Offset at, {String? sub, Color color = Colors.white, double size = 14.5}) {
    TextPainter tp(String s, double fs, Color col, FontWeight w) => TextPainter(
          text: TextSpan(
            text: s,
            style: TextStyle(
              fontSize: fs,
              fontWeight: w,
              color: col,
              letterSpacing: 0.5,
              height: 1.15,
              fontFamily: LabFont.active.family,
              fontFamilyFallback: LabFont.active.fallback,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
    final fs = size * textScale;
    final main = tp(text, fs, color, FontWeight.w800);
    final st = sub == null ? null : tp(sub.toUpperCase(), fs * 0.74, _Colors.zslYellow, FontWeight.w700);
    final padH = 12.0 * textScale, padV = 6.0 * textScale;
    final w = math.max(main.width, st?.width ?? 0) + padH * 2;
    final h = main.height + (st == null ? 0 : st.height + 2) + padV * 2;
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: w, height: h), const Radius.circular(10));
    c
      ..drawRRect(
        r.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      )
      ..drawRRect(r, Paint()..color = const Color(0xE60F172A))
      ..drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: 0.15),
      );
    main.paint(c, Offset(at.dx - main.width / 2, r.top + padV));
    st?.paint(c, Offset(at.dx - st.width / 2, r.top + padV + main.height + 2));
  }

  void _objLabel(Canvas c, _Obj o) {
    if (!showLabels || !o.visible || o.labelKey == null) return;
    _annot(
      c,
      _t(o.labelKey!),
      _pv(o.pos + _V3(0, o.labelDy, 0)),
      sub: o.subKey == null ? null : _t(o.subKey!),
      color: o.labelColor,
    );
  }

  void _worldLabel(Canvas c, String key, _V3 at, {String? sub, Color color = Colors.white}) {
    if (!showLabels) return;
    _annot(c, _t(key), _pv(at), sub: sub, color: color);
  }

  // ------------------------------------------------------------- objects

  void _block(Canvas c, _Obj o) {
    final s = o.scale;
    if (s <= 0.02) return;
    final col = _matColor[o.mat]!;
    final p = o.pos;
    final sx = 2.5 * s, sy = 1.8 * s, sz = 2.5 * s;
    _shadowBox(c, p.x, p.y, p.z, sx, sy, sz);
    final faces = _box(c, p.x, p.y, p.z, sx, sy, sz, col);
    final y0 = p.y - sy / 2, y1 = p.y + sy / 2;
    final x0 = p.x - sx / 2, x1 = p.x + sx / 2;
    final z0 = p.z - sz / 2, z1 = p.z + sz / 2;
    switch (o.mat) {
      case 'wood':
        final g = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF8B6B3E).withValues(alpha: 0.55);
        for (var i = 1; i <= 4; i++) {
          final y = y0 + sy * i / 5;
          final wob = (i.isEven ? 0.06 : -0.05) * s;
          c
            ..drawPath(
              Path()
                ..moveTo(_p(x0, y, z1).dx, _p(x0, y, z1).dy)
                ..quadraticBezierTo(_p(p.x, y + wob, z1).dx, _p(p.x, y + wob, z1).dy, _p(x1, y, z1).dx,
                    _p(x1, y, z1).dy),
              g,
            )
            ..drawLine(_p(x1, y, z1), _p(x1, y - wob, z0), g);
        }
        for (final r in const [0.25, 0.5, 0.8]) {
          c.drawOval(
            Rect.fromCenter(center: _p(p.x - 0.3 * s, y1, p.z + 0.2 * s), width: r * _k * s * 1.4, height: r * _k * s),
            g,
          );
        }
      case 'copper':
      case 'iron':
        c
          ..save()
          ..clipPath(faces.top);
        final tb = faces.top.getBounds();
        c
          ..drawRect(
            tb,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: o.mat == 'copper' ? 0.35 : 0.22),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0.25, 0.5, 0.75],
              ).createShader(tb),
          )
          ..restore();
      case 'coal':
        final dot = Paint()..color = Colors.white.withValues(alpha: 0.12);
        for (var i = 0; i < 7; i++) {
          final fx = (i * 0.37) % 1, fy = (i * 0.61) % 1;
          c.drawCircle(_p(x0 + sx * fx, y0 + sy * fy, z1), 1.2, dot);
        }
    }
  }

  void _butter(Canvas c, double x, double yBottom, double z, double sy) {
    final h = 1.2 * sy;
    if (h <= 0.02) return;
    final faces = _box(c, x, yBottom + h / 2, z, 3, h, 1.8, _butterColor);
    final tb = faces.top.getBounds();
    c
      ..save()
      ..clipPath(faces.top)
      ..drawRect(
        tb,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0)],
          ).createShader(tb),
      )
      ..restore();
  }

  void _puddle(Canvas c, double x, double y, double z, double r) {
    final e = _ell(x, y, z, r);
    c
      ..drawOval(
        e,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.25, -0.3),
            colors: const [Color(0xFFFFFDE0), _butterColor, Color(0xFFF2D86B)],
            stops: const [0, 0.55, 1],
          ).createShader(e),
      )
      ..drawOval(
        Rect.fromCenter(center: e.center.translate(-e.width * 0.18, -e.height * 0.15), width: e.width * 0.25, height: e.height * 0.18),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
  }

  /// Pan body (HTML hollow tapered cylinder + base) with optional handle and
  /// contents drawn between the inner and the outer wall.
  void _pan(
    Canvas c,
    _V3 o, {
    required Color body,
    String? handle,
    bool ghost = false,
    bool ghostHandle = false,
    double scale = 1,
    bool charred = false,
    bool hot = false,
    bool metal = false,
    bool wood = false,
    VoidCallback? contents,
  }) {
    if (scale <= 0.01) return;
    final pivot = _p(o.x + 1, o.y + 0.75, o.z);
    if (scale != 1) {
      c
        ..save()
        ..translate(pivot.dx, pivot.dy)
        ..scale(scale)
        ..translate(-pivot.dx, -pivot.dy);
    }
    final op = ghost ? 0.38 : 1.0;
    final col = charred ? const Color(0xFF111111) : body;
    Color a(Color x) => x.withValues(alpha: x.a * op);
    if (!ghost) _shadowCyl(c, o.x, o.z, o.y, o.y + 1.5, 4.0);
    final top = _ell(o.x, o.y + 1.5, o.z, 4.5);
    final inner = _ell(o.x, o.y + 0.1, o.z, 3.5);
    final bottom = _ell(o.x, o.y, o.z, 3.5);

    // Inner wall and base seen through the opening.
    c.drawOval(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a(labShade(col, -0.45)), a(labShade(col, -0.12))],
        ).createShader(top),
    );
    c
      ..save()
      ..clipPath(Path()..addOval(top))
      ..drawOval(
        inner,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [a(labShade(col, 0.16)), a(labShade(col, -0.14))],
          ).createShader(inner),
      )
      ..restore();
    contents?.call();

    // Outer front wall.
    final wall = Path()
      ..moveTo(top.left, top.center.dy)
      ..lineTo(bottom.left, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(top.right, top.center.dy)
      ..arcTo(top, 0, math.pi, false)
      ..close();
    final wb = Rect.fromLTRB(top.left, top.top, top.right, bottom.bottom);
    c.drawPath(
      wall,
      Paint()
        ..shader = LinearGradient(
          colors: [a(labShade(col, 0.32)), a(labShade(col, 0.08)), a(col), a(labShade(col, -0.42))],
          stops: const [0, 0.25, 0.55, 1],
        ).createShader(wb),
    );
    if (!ghost && !charred && (metal || wood)) {
      c
        ..save()
        ..clipPath(wall);
      if (metal) {
        final band = Rect.fromLTRB(wb.left + wb.width * 0.14, wb.top, wb.left + wb.width * 0.32, wb.bottom);
        c.drawRect(
          band,
          Paint()
            ..shader = LinearGradient(colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.32),
              Colors.white.withValues(alpha: 0),
            ]).createShader(band),
        );
      } else {
        final g = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF8B6B3E).withValues(alpha: 0.5);
        for (final f in const [0.3, 0.55, 0.8]) {
          c.drawArc(_ell(o.x, o.y + 1.5 * f, o.z, 3.5 + f), 0.2, math.pi - 0.4, false, g);
        }
      }
      c.restore();
    }
    if (charred && !ghost) {
      // Embers on the charred wall.
      final ember = Paint()
        ..color = const Color(0xFFFF5A1F).withValues(alpha: 0.35 + 0.25 * math.sin(sc.time * 6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      for (var i = 0; i < 5; i++) {
        final ang = 0.5 + i * 0.5;
        final r = 3.9;
        c.drawCircle(_p(o.x + math.cos(ang) * r, o.y + 0.4 + (i % 2) * 0.5, o.z + math.sin(ang) * r), 2.2, ember);
      }
    }
    c.drawOval(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.16 * _k
        ..color = a(labShade(col, 0.38)),
    );
    if (handle != null || ghostHandle) _panHandle(c, o, handle, hot: hot, ghost: ghostHandle);
    if (scale != 1) c.restore();
  }

  void _panHandle(Canvas c, _V3 o, String? mat, {bool hot = false, bool ghost = false}) {
    final y = o.y + 0.75;
    // Connector is always iron (HTML createPanHandle).
    _rod(c, _V3(o.x + 3.6, y, o.z), _V3(o.x + 5.25, y, o.z), 0.3, 0.3, _matColor['iron']!);
    if (ghost) {
      final pulse = 0.5 + 0.5 * math.sin(sc.time * 4);
      _rod(c, _V3(o.x + 5.25, y, o.z), _V3(o.x + 9.75, y, o.z), 0.5, 0.4, _ghostColor,
          opacity: 0.3 + 0.2 * pulse, sheen: false);
      return;
    }
    final col = hot ? const Color(0xFFFF8F8F) : _matColor[mat] ?? _matColor['wood']!;
    if (hot) {
      labGlow(c, _p(o.x + 7.5, y, o.z), 3.4 * _k, const Color(0xFFFF2A00),
          intensity: 0.45 + 0.12 * math.sin(sc.time * 4));
    }
    _rod(c, _V3(o.x + 5.25, y, o.z), _V3(o.x + 9.75, y, o.z), 0.5, 0.4, col,
        capColor: mat == 'wood' ? const Color(0xFFE2C79A) : null);
    if (mat == 'wood' && !hot) {
      final g = Paint()
        ..strokeWidth = 1
        ..color = const Color(0xFF8B6B3E).withValues(alpha: 0.6);
      c
        ..drawLine(_p(o.x + 5.6, y + 0.15, o.z), _p(o.x + 9.2, y + 0.1, o.z), g)
        ..drawLine(_p(o.x + 6.0, y - 0.15, o.z), _p(o.x + 9.4, y - 0.12, o.z), g);
    }
  }

  void _panObj(Canvas c, _Obj pan) {
    final m = sc.panMaterial ?? 'copper';
    _pan(
      c,
      pan.pos,
      body: _matColor[m]!,
      handle: sc.handleMaterial,
      charred: sc.panCharred,
      hot: sc.hotHandle,
      metal: _isMetal(m),
      wood: m == 'wood',
      contents: () => _panContents(c, pan.pos),
    );
  }

  void _panContents(Canvas c, _V3 o) {
    final base = o.y + 0.12;
    if (sc.meltedDisc) _puddle(c, o.x, base, o.z, 3.0);
    if (sc.puddleR > 0) _puddle(c, o.x, base, o.z, sc.puddleR);
    final b = sc.obj(_Kind.butter);
    if (sc.butterInPan && b != null && b.visible) _butter(c, o.x, base, o.z, sc.butterScaleY);
  }

  void _hand(Canvas c, _Obj o) {
    final ctr = _pv(o.pos);
    labGroundShadow(c, _sh(o.pos.x, o.pos.y, o.pos.z), 4.5 * _k, 1.6 * _k, opacity: 0.22);
    final f = 8 * _k / 100;
    c
      ..save()
      ..translate(ctr.dx, ctr.dy)
      ..rotate(-0.42)
      ..scale(f)
      ..translate(-50, -50)
      ..drawPath(
        _handFill.shift(const Offset(2, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawPath(_handFill, Paint()..color = const Color(0xFFFAE8A4));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFA07A3C);
    c
      ..drawPath(_handFill, stroke)
      ..drawPath(_handOutline, stroke)
      ..restore();
  }

  // ------------------------------------------------------- kitchen stages

  void _tray(Canvas c, double x, double z, double w, double d) {
    _shadowBox(c, x, 0.1, z, w, 0.2, d, opacity: 0.18);
    _box(c, x, 0.1, z, w, 0.2, d, const Color(0xFF9CA3AF));
  }

  void _station(Canvas c) {
    final pulse = 0.5 + 0.5 * math.sin(sc.time * 3);
    _shadowBox(c, -8, 0.4, 0, 14, 0.8, 14);
    _box(c, -8, 0.4, 0, 14, 0.8, 14, const Color(0xFF1E293B));
    _ring(c, -8, 0.85, 0, 4.5, 5.0, const Color(0xFF3B82F6).withValues(alpha: 0.7 + 0.3 * pulse));
  }

  void _objects(Canvas c, Iterable<_Obj> list) {
    final sorted = list.where((o) => o.visible && o != sc.dragging).toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));
    for (final o in sorted) {
      _drawObj(c, o);
    }
    final d = sc.dragging;
    if (d != null && d.visible) _drawObj(c, d);
  }

  void _drawObj(Canvas c, _Obj o) {
    switch (o.kind) {
      case _Kind.block:
        _block(c, o);
      case _Kind.pan:
        _panObj(c, o);
      case _Kind.butter:
        if (!sc.butterInPan) _butter(c, o.pos.x, o.pos.y - 0.6, o.pos.z, 1);
      case _Kind.hand:
        _hand(c, o);
      case _Kind.item:
        _item(c, o.mat, o.pos, o.scale, o.inGap);
    }
  }

  void _craftStage(Canvas c) {
    const st = _V3(-8, 0.8, 0);
    _station(c);
    final mat = sc.panMaterial ?? 'copper';
    if (sc.step == 1) {
      if (sc.newPanScale >= 0) {
        _pan(c, st, body: _matColor[mat]!, scale: sc.newPanScale, metal: _isMetal(mat), wood: mat == 'wood');
      } else {
        final pulse = 0.5 + 0.5 * math.sin(sc.time * 3);
        _pan(c, st, body: _ghostColor.withValues(alpha: 0.75 + 0.25 * pulse), ghost: true);
      }
      _tray(c, 10, 0, 24, 14);
    } else {
      _pan(
        c,
        st,
        body: _matColor[mat]!,
        handle: sc.handleMaterial,
        ghostHandle: sc.handleMaterial == null,
        metal: _isMetal(mat),
        wood: mat == 'wood',
      );
      _tray(c, 12, 0, 18, 12);
    }
    _objects(c, sc.objs);
    _worldLabel(c, sc.step == 1 ? 'lblDropPan' : 'lblAttachHandle', const _V3(-8, 3, -3));
    // Tray title on the front edge (the back edge sits under the block labels).
    _worldLabel(c, sc.step == 1 ? 'lblAvail' : 'lblHandleMats',
        sc.step == 1 ? const _V3(9, 0.2, 9.2) : const _V3(11, 0.2, 8.2));
    for (final o in sc.objs) {
      _objLabel(c, o);
    }
  }

  void _stoveBase(Canvas c, double sx) {
    final on = sc.coilOn;
    _shadowBox(c, sx, 0.75, 0, 12, 1.5, 12);
    _box(c, sx, 0.75, 0, 12, 1.5, 12, const Color(0xFF94A3B8));
    _cylV(c, sx, 0, 1.5, 1.6, 4.5, 4.5, on ? const Color(0xFFFF3300) : const Color(0xFF111111),
        top: on ? const Color(0xFFE63A0E) : const Color(0xFF1B1B1B));
    final flick = 0.5 + 0.5 * math.sin(sc.time * 5);
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.22 * _k
      ..color = on ? Color.lerp(const Color(0xFFFF9A3C), const Color(0xFFFFD27A), flick)! : const Color(0xFF353535);
    for (final r in const [1.1, 2.0, 2.9, 3.8]) {
      c.drawOval(_ell(sx, 1.6, 0, r), groove);
    }
    if (on) {
      labGlow(c, _p(sx, 1.7, 0), 6.5 * _k, const Color(0xFFFF2200), intensity: 0.5 + 0.1 * flick);
    }
  }

  void _stovePad(Canvas c, double sx) {
    final bx = sx + 13;
    final on = sc.coilOn;
    _shadowBox(c, bx, 0.5, 0, 9, 1, 9);
    _box(c, bx, 0.5, 0, 9, 1, 9, const Color(0xFF94A3B8));
    _ring(c, bx, 1.05, 0, 3.0, 3.5, const Color(0xFF3B82F6));
    _cylV(c, bx, 0, 1.0, 1.2, 1.8, 1.8, const Color(0xFF94A3B8));
    final y1 = 1.6 - sc.press;
    final bc = on ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    // Pulsing hint while the pan waits on a cold stove.
    if (!on && sc.panOnStove && sc.step == 3) {
      final pulse = 0.5 + 0.5 * math.sin(sc.time * 5);
      labGlow(c, _p(bx, y1, 0), (2.4 + 0.6 * pulse) * _k, const Color(0xFFEF4444), intensity: 0.5);
    }
    _cylV(c, bx, 0, 1.2 - sc.press, y1, 1.4, 1.4, bc, top: labShade(bc, 0.08));
    final ctr = _p(bx, y1, 0);
    c
      ..save()
      ..translate(ctr.dx, ctr.dy)
      ..scale(1, _ellY);
    labText(
      c,
      on ? _t('lblOn') : _t('lblOff'),
      Offset.zero,
      size: 0.85 * _k,
      color: Colors.white,
      weight: FontWeight.w900,
      shadows: const [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 2))],
    );
    c.restore();
  }

  void _particlesPan(Canvas c) {
    for (final p in sc.particles) {
      final at = _pv(p.pos);
      if (p.kind == _PKind.smoke) {
        final r = 0.75 * p.scale * _k;
        c.drawCircle(
          at,
          r,
          Paint()
            ..color = const Color(0xFF6E6A66).withValues(alpha: (p.life * 0.6).clamp(0, 1))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35),
        );
      } else if (p.kind == _PKind.heat) {
        final rect = Rect.fromCenter(center: at, width: 1.0 * _k, height: 1.5 * _k);
        c.drawOval(
          rect,
          Paint()
            ..blendMode = BlendMode.plus
            ..shader = RadialGradient(colors: [
              const Color(0xFFFFAA00).withValues(alpha: (p.life * 0.45).clamp(0, 1)),
              const Color(0x00FFAA00),
            ]).createShader(rect),
        );
      }
    }
  }

  void _stoveStage(Canvas c) {
    final sx = sc.stoveX;
    _stoveBase(c, sx);
    _stovePad(c, sx);
    final onStove = sc.objs.where((o) => o.kind == _Kind.pan && !o.draggable && o != sc.dragging);
    for (final pan in onStove) {
      _panObj(c, pan);
    }
    _particlesPan(c);
    if (sc.step == 3) {
      _shadowBox(c, 10, 0.2, -10, 10, 0.4, 8, opacity: 0.18);
      _box(c, 10, 0.2, -10, 10, 0.4, 8, const Color(0xFF64748B));
    }
    _objects(c, sc.objs.where((o) => !(o.kind == _Kind.pan && !o.draggable)));
    for (final o in sc.objs) {
      if (o.kind == _Kind.butter && sc.butterInPan) {
        // Label follows the butter into the pan.
        if (showLabels && o.visible) {
          _annot(c, _t('lblButter'), _p(sx - 1, _panY + 5.2, -1), sub: _t('lblIngred'));
        }
        continue;
      }
      _objLabel(c, o);
    }
  }

  void _doneStage(Canvas c) {
    _stoveBase(c, sc.stoveX);
    _stovePad(c, sc.stoveX);
    final pan = sc.obj(_Kind.pan);
    if (pan == null) return;
    _panObj(c, pan);
    _particlesPan(c);
    final o = pan.pos;
    final m = sc.panMaterial;
    final h = sc.handleMaterial;
    _worldLabel(c, 'lblPanBody', o + const _V3(-0.5, 5.6, -0.5),
        sub: m == null ? null : _t(_matLabel[m]!), color: const Color(0xFFEAB308));
    if (h != null) {
      _worldLabel(c, 'lblHandle', o + const _V3(8.2, 3.6, 0),
          sub: _t(_matLabel[h]!), color: const Color(0xFF10B981));
    }
  }

  // ------------------------------------------------------- circuit stages

  void _itemShadow(Canvas c, _V3 p, double rx, double rz) {
    final s = _sh(p.x, p.y, p.z);
    labGroundShadow(c, s, 2 * rx * _k, 2 * rz * _k * _ellY, opacity: 0.25);
  }

  void _item(Canvas c, String m, _V3 p, double s, bool inGap) {
    switch (m) {
      case 'copper':
        _coil(c, p, s, inGap);
      case 'iron':
        _nail(c, p, s);
      case 'wood':
        _stick(c, p, s);
      case 'rubber':
        _eraser(c, p, s, inGap);
      default:
        _coal(c, p, s);
    }
  }

  /// Copper wire coil (HTML 270° torus lying flat).
  void _coil(Canvas c, _V3 p, double s, bool rotated) {
    final rr = 1.2 * s, tr = 0.3 * s;
    _itemShadow(c, p, rr + tr, rr + tr);
    final rect = _ell(p.x, p.y, p.z, rr);
    final start = (rotated ? 135 : 45) * math.pi / 180;
    const sweep = 1.5 * math.pi;
    final w = 2 * tr * _k;
    const cu = Color(0xFFC87B5A);
    Paint stroke(double width, Color col) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = col;
    c
      ..drawArc(rect, start, sweep, false, stroke(w, labShade(cu, -0.4)))
      ..drawArc(rect.deflate(w * 0.06), start, sweep, false, stroke(w * 0.72, cu))
      ..drawArc(rect.translate(-w * 0.08, -w * 0.18), start, sweep, false,
          stroke(w * 0.22, labShade(cu, 0.55).withValues(alpha: 0.7)));
  }

  void _nail(Canvas c, _V3 p, double s) {
    const iron = Color(0xFF555555);
    final y = p.y;
    _shadowPts(c, [
      _V3(p.x - 2.15 * s, y + 0.5 * s, p.z),
      _V3(p.x - 2.15 * s, y - 0.5 * s, p.z),
      _V3(p.x + 2.6 * s, y, p.z),
      _V3(p.x - 2.15 * s, y, p.z + 0.5 * s),
      _V3(p.x - 2.15 * s, y, p.z - 0.5 * s),
    ]);
    _rod(c, _V3(p.x - 2.15 * s, y, p.z), _V3(p.x - 1.85 * s, y, p.z), 0.5 * s, 0.5 * s, iron,
        capColor: const Color(0xFF7A7A7A));
    _rod(c, _V3(p.x - 1.85 * s, y, p.z), _V3(p.x + 2.0 * s, y, p.z), 0.2 * s, 0.2 * s, const Color(0xFF666666));
    _rod(c, _V3(p.x + 2.0 * s, y, p.z), _V3(p.x + 2.6 * s, y, p.z), 0.2 * s, 0.0, const Color(0xFF666666));
  }

  void _stick(Canvas c, _V3 p, double s) {
    const wood = Color(0xFFCCA677);
    _shadowPts(c, [
      _V3(p.x - 2.5 * s, p.y + 0.3 * s, p.z),
      _V3(p.x + 2.5 * s, p.y + 0.3 * s, p.z),
      _V3(p.x - 2.5 * s, p.y - 0.3 * s, p.z + 0.3 * s),
      _V3(p.x + 2.5 * s, p.y - 0.3 * s, p.z - 0.3 * s),
    ]);
    _rod(c, _V3(p.x - 2.5 * s, p.y, p.z), _V3(p.x + 2.5 * s, p.y, p.z), 0.3 * s, 0.3 * s, wood,
        capColor: const Color(0xFFE2C79A), rim: const Color(0xFFB08A55));
    final g = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF8B6B3E).withValues(alpha: 0.6);
    c.drawLine(_p(p.x - 2.2 * s, p.y + 0.1 * s, p.z), _p(p.x + 2.2 * s, p.y + 0.12 * s, p.z), g);
  }

  void _eraser(Canvas c, _V3 p, double s, bool rotated) {
    final sx = (rotated ? 4.0 : 2.5) * s, sz = (rotated ? 2.5 : 4.0) * s;
    _shadowBox(c, p.x, p.y, p.z, sx, 1.0 * s, sz);
    final faces = _box(c, p.x, p.y, p.z, sx, 1.0 * s, sz, const Color(0xFF333333));
    final tb = faces.top.getBounds();
    c
      ..save()
      ..clipPath(faces.top)
      ..drawRect(
        tb,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0)],
          ).createShader(tb),
      )
      ..restore();
  }

  /// Faceted coal lump (HTML DodecahedronGeometry).
  void _coal(Canvas c, _V3 p, double s) {
    final r = 1.8 * s * _k;
    final ctr = _pv(p);
    labGroundShadow(c, _sh(p.x, math.max(0, p.y - 1.4 * s), p.z), 3.6 * s * _k, 1.6 * s * _k, opacity: 0.3);
    const radii = [1.0, 0.9, 0.97, 0.88, 1.0, 0.93, 0.98, 0.9, 0.99, 0.92];
    final pts = <Offset>[
      for (var i = 0; i < 10; i++)
        ctr +
            Offset(math.cos(i * math.pi / 5 + 0.2), math.sin(i * math.pi / 5 + 0.2) * 0.9) * r * radii[i],
    ];
    final hub = ctr + Offset(-0.16, -0.2) * r;
    const base = Color(0xFF1A1A1A);
    for (var i = 0; i < 10; i++) {
      final a = pts[i], b = pts[(i + 1) % 10];
      final mid = (i + 0.5) * math.pi / 5 + 0.2;
      final light = math.cos(mid - (-2.3));
      c.drawPath(
        Path()..addPolygon([hub, a, b], true),
        Paint()..color = labShade(base, (0.12 + 0.16 * light).clamp(0.0, 1.0)),
      );
    }
    c
      ..drawPath(
        Path()..addPolygon(pts, true),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF050505),
      )
      ..drawCircle(hub + Offset(-0.1, -0.12) * r, 1.6, Paint()..color = Colors.white.withValues(alpha: 0.5))
      ..drawCircle(ctr + Offset(0.35, -0.3) * r, 1.2, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _battery(Canvas c) {
    const hx = -12.0, hz = -4.0;
    const dark = Color(0xFF333333);
    _shadowBox(c, hx, 1.25, hz, 6, 2.5, 5.5);
    _box(c, hx, 0.5, hz, 6, 1, 5.5, dark);
    _box(c, hx - 2.75, 1.25, hz, 0.5, 2.5, 5.5, dark);
    for (final cx in const [hx - 1.25, hx + 1.25]) {
      _rod(c, _V3(cx, 1.2, -6.8), _V3(cx, 1.2, -6.5), 1.2, 1.2, const Color(0xFF9CA3AF));
      _rod(c, _V3(cx, 1.2, -6.5), _V3(cx, 1.2, -2.0), 1.2, 1.2, const Color(0xFFEF4444),
          capColor: const Color(0xFF9CA3AF));
      // Printed band near the + end.
      c.drawLine(
        _p(cx - 0.9, 2.0, -2.6),
        _p(cx - 0.9, 2.0, -2.25),
        Paint()
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5),
      );
      _rod(c, _V3(cx, 1.2, -2.0), _V3(cx, 1.2, -1.7), 1.2, 1.2, const Color(0xFF9CA3AF));
      _rod(c, _V3(cx, 1.2, -1.7), _V3(cx, 1.2, -1.3), 0.4, 0.4, const Color(0xFF555555));
    }
    _box(c, hx + 2.75, 1.25, hz, 0.5, 2.5, 5.5, dark);
  }

  void _bulb(Canvas c) {
    const bx = 8.0, bz = -4.0;
    final on = sc.bulbOn;
    final flick = 0.5 + 0.5 * math.sin(sc.time * 9);
    if (on) {
      final pool = _ell(bx, 0, bz, 12);
      c.drawOval(
        pool,
        Paint()
          ..shader = const RadialGradient(colors: [Color(0x80FFE45C), Color(0x00FFE45C)]).createShader(pool),
      );
    }
    _shadowCyl(c, bx, bz, 0, 7.2, 3.0, opacity: on ? 0.12 : 0.26);
    _cylV(c, bx, bz, 0, 0.6, 3.0, 2.5, const Color(0xFF777777));
    _cylV(c, bx, bz, 0.6, 2.6, 1.5, 1.5, const Color(0xFF555555));
    final thread = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF8E8E8E);
    for (var y = 0.95; y < 2.5; y += 0.38) {
      c.drawArc(_ell(bx, y, bz, 1.52), 0.15, math.pi - 0.3, false, thread);
    }
    final gc = _p(bx, 4.2, bz);
    final r = 3 * _k;
    final f0 = _p(bx - 0.35, 2.7, bz), f1 = _p(bx + 0.35, 2.7, bz);
    final ft = _p(bx, 3.9, bz);
    final filament = Path()
      ..moveTo(f0.dx, f0.dy)
      ..lineTo(ft.dx - 0.35 * _k, ft.dy)
      ..lineTo(ft.dx + 0.35 * _k, ft.dy)
      ..lineTo(f1.dx, f1.dy);
    if (on) {
      labGlow(c, gc, r * 3.2, const Color(0xFFFFD700), intensity: 0.75 + 0.1 * flick);
      labSphere(c, gc, r, const Color(0xFFFFF6C2), highlight: 0.85, shade: 0.12);
      labGlow(c, ft, 1.3 * _k, Colors.white, intensity: 1);
      c.drawPath(
        filament,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFA726),
      );
    } else {
      c.drawPath(
        filament,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF9E9E9E),
      );
      labSphere(c, gc, r, const Color(0xFF444444), highlight: 0.5, shade: 0.6, opacity: 0.82);
    }
    c.drawOval(
      Rect.fromCenter(center: gc + Offset(-0.38 * r, -0.42 * r), width: 0.45 * r, height: 0.28 * r),
      Paint()..color = Colors.white.withValues(alpha: on ? 0.7 : 0.35),
    );
  }

  /// Alligator clips at both wire ends.
  void _clips(Canvas c) {
    const iron = Color(0xFF707070);
    for (final left in const [true, false]) {
      final base = left ? const _V3(-4.25, 0.5, 4) : const _V3(4.25, 0.5, 4);
      final tip = left ? const _V3(-1.75, 0.5, 4) : const _V3(1.75, 0.5, 4);
      _shadowPts(c, [base + const _V3(0, 0.5, 0), base - const _V3(0, 0.5, 0), tip]);
      _rod(c, base, tip, 0.5, 0.06, iron);
      // Serrated jaw.
      final a = _pv(_V3.lerp(base, tip, 0.35)), b = _pv(tip);
      final path = Path()..moveTo(a.dx, a.dy);
      for (var i = 1; i <= 6; i++) {
        final q = Offset.lerp(a, b, i / 6)!;
        path.lineTo(q.dx, q.dy + (i.isOdd ? -2.0 : 0.0));
      }
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFFD4D4D4),
      );
    }
  }

  void _bin(Canvas c, bool good) {
    final bx = good ? -10.0 : 10.0;
    const bz = 12.0;
    final col = good ? const Color(0xFF4ADE80) : const Color(0xFF0F766E);
    _shadowBox(c, bx, 1.5, bz, 10, 3, 8, opacity: 0.2);
    _box(c, bx, 0.1, bz, 10, 0.2, 8, col);
    _box(c, bx, 1.5, bz - 3.9, 10, 3, 0.2, col, opacity: 0.8);
    _box(c, bx - 4.9, 1.5, bz, 0.2, 3, 8, col, opacity: 0.8);
    // Items already sorted into this bin.
    final inBin = <({String m, _V3 pos})>[];
    var n = 0;
    for (final e in sc.sorted) {
      if (e.good != good) continue;
      final idx = n++;
      if (e.item == sc.flyingItem) continue;
      inBin.add((m: e.item, pos: _V3(bx + (idx.isEven ? -1.5 : 1.5), 1.5, bz + (idx > 1 ? -1.5 : 1.5))));
    }
    inBin.sort((a, b) => (a.pos.x + a.pos.z).compareTo(b.pos.x + b.pos.z));
    for (final e in inBin) {
      _item(c, e.m, e.pos, 0.8, false);
    }
    if (sc.hoverBin == good) {
      _box(c, bx, 2, bz, 9.5, 4.5, 7.5, sc.hoverCorrect ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
          opacity: 0.45, edges: false);
    }
    _box(c, bx + 4.9, 1.5, bz, 0.2, 3, 8, col, opacity: 0.55);
    _box(c, bx, 1.5, bz + 3.9, 10, 3, 0.2, col, opacity: 0.55);
  }

  void _circuitStage(Canvas c) {
    final pulse = 0.5 + 0.5 * math.sin(sc.time * 3);
    _tray(c, 18, -1, 14, 18);
    for (var i = 0; i < 3; i++) {
      _tube(c, [for (var t = 0; t <= 30; t++) _bez(_wireCurves[i], t / 30)], 0.25,
          i == 0 ? const Color(0xFFDC2626) : const Color(0xFF111111));
    }
    _battery(c);
    _bulb(c);
    _clips(c);
    final hasGap = sc.objs.any((o) => o.inGap && o.visible);
    if (!hasGap) {
      _box(c, 0, 1, 4, 6, 2, 3, _ghostColor, opacity: 0.25 + 0.15 * pulse);
    }
    _bin(c, true);
    _bin(c, false);
    _objects(c, sc.objs);

    // Electrons flowing along the wires (drawn on top, no depth test).
    for (final p in sc.particles) {
      if (p.kind != _PKind.electron) continue;
      final at = _pv(_bez(_wireCurves[p.curve], p.t));
      labGlow(c, at, 0.95 * _k, const Color(0xFFFFFF00), intensity: 0.9);
      c.drawCircle(at, 0.3 * _k, Paint()..color = const Color(0xFFFFFDE0));
    }

    _worldLabel(c, 'lblTestMats', const _V3(19, 0.2, 9.6));
    if (!hasGap) _worldLabel(c, 'lblDropConn', const _V3(0, 3.5, 4), color: const Color(0xFF60A5FA));
    for (final good in const [true, false]) {
      final parts = _t(good ? 'lblGoodCond' : 'lblPoorCond').split('\n');
      if (showLabels) {
        _annot(c, parts.first, _p(good ? -10 : 10, 6, 12),
            sub: parts.length > 1 ? parts[1] : null,
            color: good ? const Color(0xFF4ADE80) : const Color(0xFF34D399));
      }
    }
    for (final o in sc.objs) {
      _objLabel(c, o);
    }
  }

  /// Scenario 2 conclusion: cut-away of a household cable.
  void _wireStage(Canvas c) {
    const sheathR = 1.8 * _wireS;
    // Floor shadow.
    final s0 = _sh(_wt(-16, 0, 0).x, _wt(-16, 0, 0).y, _wt(-16, 0, 0).z);
    final s1 = _sh(_wt(7, 0, 0).x, _wt(7, 0, 0).y, _wt(7, 0, 0).z);
    c.drawLine(
      s0,
      s1,
      Paint()
        ..strokeWidth = sheathR * _k * 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sheathR * _k * 0.5),
    );
    // Outer sheath with an open (hollow) end.
    _rod(c, _wt(-16, 0, 0), _wt(0, 0, 0), sheathR, sheathR, const Color(0xFF555555),
        capColor: const Color(0xFF1F2937), rim: const Color(0xFF8A8F98));
    // HTML triangle formation inside the sheath (brown top, blue and green
    // below), fanning out at the cut end so every wire is visible.
    const wires = [
      (y: 0.7, z: 0.0, ey: 1.2, ez: -0.7, col: Color(0xFF8B4513)),
      (y: -0.4, z: 0.65, ey: -1.2, ez: 0.7, col: Color(0xFF3B82F6)),
      (y: -0.4, z: -0.65, ey: 0.0, ez: 0.0, col: Color(0xFF22C55E)),
    ];
    double depth(_V3 p) => p.x + p.z + 1.5 * p.y;
    final order = [...wires]..sort((a, b) => depth(_wt(3, a.ey, a.ez)).compareTo(depth(_wt(3, b.ey, b.ez))));
    const cu = Color(0xFFC87B5A);
    for (final w in order) {
      _rod(c, _wt(-0.8, w.y, w.z), _wt(3, w.ey, w.ez), 0.6 * _wireS, 0.6 * _wireS, w.col,
          capColor: labShade(w.col, 0.18));
      // Seven bare copper strands per wire.
      final strands = <_V3>[
        for (var i = 0; i < 7; i++)
          i == 0
              ? _V3(0, w.ey, w.ez)
              : _V3(0, w.ey + math.sin((i - 1) * math.pi / 3) * 0.3, w.ez + math.cos((i - 1) * math.pi / 3) * 0.3),
      ]..sort((a, b) => depth(_wt(3, a.y, a.z)).compareTo(depth(_wt(3, b.y, b.z))));
      for (final st in strands) {
        _rod(c, _wt(3, st.y, st.z), _wt(7, st.y, st.z), 0.08 * _wireS, 0.08 * _wireS, cu,
            capColor: const Color(0xFFF0B08F), sheen: false);
      }
    }
    if (!showLabels) return;
    final cond = _pv(_wt(6, 1.5, -0.7));
    final ins = _pv(_wt(-9, -1.8, 0));
    final condAt = cond + const Offset(-6, -80);
    final insAt = ins + const Offset(-10, 84);
    final lead = Paint()
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.85);
    c
      ..drawLine(cond, condAt, lead)
      ..drawCircle(cond, 4, Paint()..color = const Color(0xFFEAB308))
      ..drawLine(ins, insAt, lead)
      ..drawCircle(ins, 4, Paint()..color = const Color(0xFF10B981));
    _annot(c, _t('lblConductor'), condAt, sub: _t('lblCondSub'), color: const Color(0xFFEAB308), size: 16);
    _annot(c, _t('lblInsulator'), insAt, sub: _t('lblInsSub'), color: const Color(0xFF10B981), size: 16);
  }

  // ------------------------------------------------------------- effects

  void _paintEffects(Canvas c) {
    for (final fx in sc.effects) {
      final t = ((sc.time - fx.start) / fx.dur).clamp(0.0, 1.0);
      final at = _pv(fx.at);
      switch (fx.kind) {
        case _FxKind.float:
          // CSS floatUpAnim keyframes.
          double scale, dy, op;
          if (t < 0.2) {
            final e = Curves.easeOutBack.transform(t / 0.2);
            scale = 1.2 * e;
            dy = -20 * e;
            op = 1;
          } else if (t < 0.8) {
            final e = (t - 0.2) / 0.6;
            scale = 1.2;
            dy = -20 - 40 * e;
            op = 1;
          } else {
            final e = (t - 0.8) / 0.2;
            scale = 1.2 + 0.3 * e;
            dy = -60 - 20 * e;
            op = 1 - e;
          }
          final thud = fx.textKey == 'fxThud';
          c
            ..save()
            ..translate(at.dx + 24, at.dy - 46 + dy)
            ..scale(math.max(scale, 0.01));
          labText(
            c,
            _t(fx.textKey),
            Offset.zero,
            size: 40,
            color: fx.color,
            weight: FontWeight.w900,
            opacity: op,
            shadows: thud
                ? [
                    Shadow(color: Colors.black.withValues(alpha: op), blurRadius: 5),
                    Shadow(color: Colors.black.withValues(alpha: op), blurRadius: 10),
                  ]
                : [
                    Shadow(color: fx.color.withValues(alpha: op), blurRadius: 10),
                    Shadow(color: fx.color.withValues(alpha: op), blurRadius: 20),
                  ],
          );
          c.restore();
        case _FxKind.zap:
          // CSS zapAnim keyframes.
          double scale, rot, op;
          if (t < 0.5) {
            final e = Curves.easeOutBack.transform(t / 0.5);
            scale = 1.2 * e;
            rot = -20 + 30 * e;
            op = 1;
          } else {
            final e = (t - 0.5) / 0.5;
            scale = 1.2 + 0.3 * e;
            rot = 10 - 10 * e;
            op = 1 - e;
          }
          c
            ..save()
            ..translate(at.dx + 20, at.dy - 30)
            ..rotate(rot * math.pi / 180)
            ..scale(math.max(scale, 0.01))
            ..skew(-0.22, 0);
          labText(
            c,
            _t(fx.textKey),
            Offset.zero,
            size: 54,
            color: fx.color,
            weight: FontWeight.w900,
            opacity: op,
            shadows: [
              Shadow(color: const Color(0xFFFCA5A5).withValues(alpha: op), blurRadius: 10),
              Shadow(color: const Color(0xFFEF4444).withValues(alpha: op), blurRadius: 20),
              Shadow(color: const Color(0xFFB91C1C).withValues(alpha: op), blurRadius: 30),
            ],
          );
          c.restore();
        case _FxKind.check:
          // CSS checkAnim keyframes.
          final double scale, op;
          if (t < 0.42) {
            final e = t / 0.42;
            scale = 1.2 * Curves.easeOutBack.transform(e);
            op = e;
          } else {
            final e = ((t - 0.42) / 0.42).clamp(0.0, 1.0);
            scale = 1.2 - 0.2 * e;
            op = 1;
          }
          final r = 30.0 * math.max(scale, 0.01);
          final ctr = at + const Offset(0, -10);
          labGlow(c, ctr, r * 1.8, _Colors.green, intensity: 0.5 * op);
          c.drawCircle(
            ctr,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.16
              ..color = _Colors.green.withValues(alpha: op),
          );
          c.drawPath(
            Path()
              ..moveTo(ctr.dx - r * 0.42, ctr.dy + r * 0.02)
              ..lineTo(ctr.dx - r * 0.1, ctr.dy + r * 0.32)
              ..lineTo(ctr.dx + r * 0.45, ctr.dy - r * 0.3),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.18
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = _Colors.green.withValues(alpha: op),
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MetalsPainter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.textScale != textScale ||
      old.sc != sc;
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
